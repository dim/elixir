%% Helpers related to keywords blocks.
-module(elixir_kw_block).
-export([sort/1, normalize/1, normalize/2, decouple/1, validate/4, pivot/3]).
-include("elixir.hrl").

sort(List) -> lists:sort(fun sort/2, List).
sort({ A, _ }, { B, _ }) -> A =< B.

%% Normalize the list of keywords so at the
%% end all values are keywords blocks
normalize(List) -> normalize(0, List).
normalize(Line, List) ->
  [{Key,normalize_each(Line, Value)} || {Key,Value} <- List].

normalize_each(_Line, { '__kwblock__', _, _} = Value) -> Value;
normalize_each(Line, Value) -> { '__kwblock__', Line, [[],Value] }.

%% Decouple clauses from kv_blocks
decouple(List) -> decouple_each(normalize(List)).
decouple_each([{Key,{'__kwblock__',_,[K,V]}}|T]) -> [{Key,K,V}|decouple_each(T)];
decouple_each([]) -> [].

%% validate
validate(Line, {Key,[],_}, Count, S) when Count > 0 ->
  elixir_errors:syntax_error(Line, S#elixir_scope.filename, "no condition given for ~s", [Key]);

validate(Line, {Key,List,_}, 0, S) when List /= [] ->
  elixir_errors:syntax_error(Line, S#elixir_scope.filename, "invalid conditions for ~s", [Key]);

validate(Line, {Key,List,_}, 1, S) when length(List) > 1 ->
  elixir_errors:syntax_error(Line, S#elixir_scope.filename, "invalid comma arguments for ~s", [Key]);

validate(Line, {Key,List,_}, Count, S) when length(List) > Count ->
  elixir_errors:syntax_error(Line, S#elixir_scope.filename, "too many conditions given for ~s", [Key]);

validate(_, _, _, _) -> ok.

%% pivot

pivot([{do, { '__block__', Line, Block }}], Args, File) ->
  pivot_each(Block, Args, { do, 0, Line, [] }, [], [], File);

pivot([{do, Else}], Args, File) ->
  pivot_each([Else], Args, { do, 0, 0, [] }, [], [], File);

pivot({ '__block__', Line, Block }, Args, File) ->
  pivot_each(Block, Args, { do, 0, Line, [] }, [], [], File);

pivot(Else, _Args, _File) -> Else.

pivot_each([{ Name, Line, Args } = H|T], Pivots, Current, Temp, Acc, File) when is_atom(Name) ->
  case lists:keyfind(Name, 1, Pivots) of
    { Name, Validation } ->
      KW = normalize_kw(Current, Temp, File),
      pivot_each(T, Pivots, { Name, Validation, Line, normalize_args(Args) }, [], [KW|Acc], File);
    _ ->
      pivot_each(T, Pivots, Current, [H|Temp], Acc, File)
  end;

pivot_each([H|T], Pivots, Current, Temp, Acc ,File) ->
  pivot_each(T, Pivots, Current, [H|Temp], Acc, File);

pivot_each([], _Pivots, Current, Temp, Acc, File) ->
  KW = normalize_kw(Current, Temp, File),
  sort(lists:reverse([KW|Acc])).

normalize_args(Atom) when is_atom(Atom) -> [];
normalize_args(Args) when is_list(Args) -> Args.

%% Both "else: foo\nbar" or "else: \nbar" should be acceptable.
%% TODO: Today this returns the shortcut syntax, we should fix it.
normalize_kw({ Key, 0, Line, Args }, Temp, _File) when length(Args) < 2 ->
  { Key, normalize_block(Line, Temp ++ Args) };

normalize_kw({ Key, Validation, Line, Args }, Temp, File) ->
  validate(Line, Key, Args, Validation, File),
  { Key, { '__kwblock__', Line, [Args, normalize_block(Line, Temp)] } }.
  
normalize_block(_Line, [])               -> nil;
normalize_block(_Line, [H])              -> H;
normalize_block(Line, H) when is_list(H) -> { '__block__', Line, lists:reverse(H) }.

%% Blocks validation

validate(Line, Key, Args, { Min, Max }, File) ->
  validate(Line, Key, Args, Min, Max, File);

validate(Line, Key, Args, Int, File) when is_integer(Int) ->
  validate(Line, Key, Args, Int, Int, File).

validate(Line, Key, [], Min, _Max, File) when Min > 0 ->
  elixir_errors:syntax_error(Line, normalize_file(File), "no conditions given for ~s", [Key]);

validate(Line, Key, List, _Min, 1, File) when length(List) > 1 ->
  elixir_errors:syntax_error(Line, normalize_file(File), "invalid comma arguments for ~s", [Key]);

validate(Line, Key, List, _Min, Max, File) when length(List) > Max ->
  elixir_errors:syntax_error(Line, normalize_file(File), "too many conditions given for ~s", [Key]);

validate(Line, Key, List, Min, _Max, File) when length(List) < Min ->
  elixir_errors:syntax_error(Line, normalize_file(File), "too few conditions given for ~s", [Key]);

validate(_, _, _, _, _, _) -> ok.

normalize_file(File) when is_binary(File) -> binary_to_list(File);
normalize_file(File) when is_list(File) -> File.