%% Helpers related to keywords blocks.
-module(elixir_kw_block).
-export([sort/1, normalize/1, normalize/2, decouple/1]).
-include("elixir.hrl").

sort(List) -> lists:sort(fun sort/2, List).
sort({ A, _ }, { B, _ }) -> A =< B.

%% Normalize the list of keywords so at the
%% end all values are keywords blocks
normalize(List) -> normalize(0, List).
normalize(Line, List) -> normalize(Line, List, []).

normalize(Line, [{ Key, { '=>', PairLine, Pairs } }|T], Acc) ->
  NewAcc = 
    lists:foldl(fun({Left,Right}, List) ->
      [{ Key, { '__kwblock__', PairLine, [Left, Right] } }|List]
    end, Acc, Pairs),
  normalize(Line, T, NewAcc);

normalize(Line, [{ Key, { '__kwblock__', _, _} = Value }|T], Acc) ->
  normalize(Line, T, [{Key,Value}|Acc]);

normalize(Line, [{Key,Value}|T], Acc) ->
  normalize(Line, T, [{Key,{ '__kwblock__', Line, [[],Value] }}|Acc]);

normalize(_Line, [], Acc) -> lists:reverse(Acc).

%% Decouple clauses from kv_blocks
decouple(List) -> decouple_each(normalize(List)).
decouple_each([{Key,{'__kwblock__',_,[K,V]}}|T]) -> [{Key,hd(K),V}|decouple_each(T)];
decouple_each([]) -> [].