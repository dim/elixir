% Grammar for the Elixir language done with yecc
% Copyright (C) 2011 Jose Valim

Nonterminals
  grammar expr_list
  expr stab_expr bracket_expr call_expr max_expr
  base_expr op_expr
  comma_separator
  add_op mult_op unary_op addadd_op multmult_op bin_concat_op
  match_op arrow_op default_op when_op pipe_op in_op rocket_op
  andand_op oror_op and_op or_op comp_expr_op
  open_paren close_paren
  open_bracket close_bracket
  open_curly close_curly
  open_bit close_bit
  comma_expr call_args_comma_expr
  call_args call_args_parens call_args_no_parens
  rocket_expr rocket_expr_list
  kw_eol kw_expr kw_item kw_list kw_any kw_comma kw_base
  stab_eol stab_block end_eol
  parens_call dot_op dot_identifier dot_ref
  dot_paren_identifier dot_punctuated_identifier dot_bracket_identifier
  var list bracket_access bit_string tuple
  .

Terminals
  'end' '__ref__'
  identifier kw_identifier punctuated_identifier
  bracket_identifier paren_identifier
  number signed_number atom bin_string list_string sigil
  dot_call_op special_op comp_op
  'not' 'and' 'or' 'xor' 'when' 'in'
  'true' 'false' 'nil'
  '=' '+' '-' '*' '/' '++' '--' '**' '//'
  '(' ')' '[' ']' '{' '}' '<<' '>>'
  eol ','  '&' '|'  '.' '^' '@' '<-' '<>' '->' '=>'
  '&&' '||' '!'
  .

Rootsymbol grammar.

Right     10 rocket_op.
Left      20 ','.  % Solve nested call_args conflicts
Right     30 default_op.
Right     40 when_op.
Left      50 pipe_op.
Right     80 match_op.
Right     90 arrow_op.
Left     100 oror_op.
Left     110 andand_op.
Left     140 or_op.
Left     150 and_op.
Left     160 comp_expr_op.
Left     170 add_op.
Left     180 mult_op.
Right    190 bin_concat_op.
Right    200 addadd_op.
Right    210 multmult_op.
Nonassoc 280 unary_op.
Nonassoc 290 special_op.
Left     300 in_op.
Left     310 dot_call_op.
Left     310 dot_op.
Nonassoc 320 var.

%%% MAIN FLOW OF EXPRESSIONS

grammar -> eol : [nil].
grammar -> expr_list : lists:reverse('$1').
grammar -> eol expr_list : lists:reverse('$2').
grammar -> expr_list eol : lists:reverse('$1').
grammar -> eol expr_list eol : lists:reverse('$2').
grammar -> '$empty' : [nil].

% Note expressions are on reverse order
expr_list -> expr : ['$1'].
expr_list -> expr_list eol expr : ['$3'|'$1'].

expr -> expr op_expr : build_op(element(1, '$2'), '$1', element(2, '$2')).
expr -> unary_op expr : build_unary_op('$1', '$2').
expr -> special_op expr : build_special_op('$1', '$2').
expr -> stab_expr : '$1'.

op_expr -> match_op expr : { '$1', '$2' }.
op_expr -> add_op expr : { '$1', '$2' }.
op_expr -> mult_op expr : { '$1', '$2' }.
op_expr -> addadd_op expr : { '$1', '$2' }.
op_expr -> multmult_op expr : { '$1', '$2' }.
op_expr -> andand_op expr : { '$1', '$2' }.
op_expr -> oror_op expr : { '$1', '$2' }.
op_expr -> and_op expr : { '$1', '$2' }.
op_expr -> or_op expr : { '$1', '$2' }.
op_expr -> pipe_op expr : { '$1', '$2' }.
op_expr -> bin_concat_op expr : { '$1', '$2' }.
op_expr -> in_op expr : { '$1', '$2' }.
op_expr -> when_op expr : { '$1', '$2' }.
op_expr -> arrow_op expr : { '$1', '$2' }.
op_expr -> default_op expr : { '$1', '$2' }.
op_expr -> comp_expr_op expr : { '$1', '$2' }.

stab_expr -> parens_call call_args_parens stab_block : build_identifier('$1', '$2', '$3').
stab_expr -> dot_punctuated_identifier stab_block : build_identifier('$1', [], '$2').
stab_expr -> dot_identifier stab_block : build_identifier('$1', [], '$2').
stab_expr -> call_expr : '$1'.

call_expr -> dot_punctuated_identifier call_args_no_parens : build_identifier('$1', '$2').
call_expr -> dot_identifier call_args_no_parens : build_identifier('$1', '$2').
call_expr -> dot_punctuated_identifier : build_identifier('$1', []).
call_expr -> var : build_identifier('$1', nil).
call_expr -> bracket_expr : '$1'.

bracket_expr -> dot_bracket_identifier bracket_access : build_access(build_identifier('$1', nil), '$2').
bracket_expr -> max_expr bracket_access : build_access('$1', '$2').
bracket_expr -> max_expr : '$1'.

max_expr -> parens_call call_args_parens : build_identifier('$1', '$2').
max_expr -> dot_ref : build_identifier('$1', nil).
max_expr -> base_expr : '$1'.
max_expr -> open_paren ')' : build_block([]).
max_expr -> open_paren expr_list close_paren : build_block('$2').

base_expr -> number : ?exprs('$1').
base_expr -> signed_number : { element(4, '$1'), ?line('$1'), ?exprs('$1') }.
base_expr -> atom : build_atom('$1').
base_expr -> list : '$1'.
base_expr -> tuple : '$1'.
base_expr -> '__ref__' : '$1'.
base_expr -> 'true' : ?op('$1').
base_expr -> 'false' : ?op('$1').
base_expr -> 'nil' : ?op('$1').
base_expr -> bin_string  : build_bin_string('$1').
base_expr -> list_string : build_list_string('$1').
base_expr -> bit_string : '$1'.
base_expr -> '&' : '$1'.
base_expr -> sigil : build_sigil('$1').

%% Helpers

var -> dot_identifier : '$1'.

comma_separator -> ','     : '$1'.
comma_separator -> ',' eol : '$1'.

open_paren -> '('      : '$1'.
open_paren -> '(' eol  : '$1'.
close_paren -> ')'     : '$1'.
close_paren -> eol ')' : '$2'.

open_bracket  -> '['     : '$1'.
open_bracket  -> '[' eol : '$1'.
close_bracket -> ']'     : '$1'.
close_bracket -> eol ']' : '$2'.

open_bit  -> '<<'     : '$1'.
open_bit  -> '<<' eol : '$1'.
close_bit -> '>>'     : '$1'.
close_bit -> eol '>>' : '$2'.

open_curly  -> '{'     : '$1'.
open_curly  -> '{' eol : '$1'.
close_curly -> '}'     : '$1'.
close_curly -> eol '}' : '$2'.

% Operators

add_op -> '+' : '$1'.
add_op -> '-' : '$1'.
add_op -> '+' eol : '$1'.
add_op -> '-' eol : '$1'.

mult_op -> '*' : '$1'.
mult_op -> '/' : '$1'.
mult_op -> '*' eol : '$1'.
mult_op -> '/' eol : '$1'.

addadd_op -> '++' : '$1'.
addadd_op -> '--' : '$1'.
addadd_op -> '++' eol : '$1'.
addadd_op -> '--' eol : '$1'.

multmult_op -> '**' : '$1'.
multmult_op -> '**' eol : '$1'.

default_op -> '//' : '$1'.
default_op -> '//' eol : '$1'.

unary_op -> '+' : '$1'.
unary_op -> '+' eol : '$1'.
unary_op -> '-' : '$1'.
unary_op -> '-' eol : '$1'.
unary_op -> '!' : '$1'.
unary_op -> '!' eol : '$1'.
unary_op -> '^' : '$1'.
unary_op -> '^' eol : '$1'.
unary_op -> 'not' : '$1'.
unary_op -> 'not' eol : '$1'.
unary_op -> '@' : '$1'.
unary_op -> '@' eol : '$1'.

match_op -> '=' : '$1'.
match_op -> '=' eol : '$1'.

andand_op -> '&&' : '$1'.
andand_op -> '&&' eol : '$1'.

oror_op -> '||' : '$1'.
oror_op -> '||' eol : '$1'.

and_op -> 'and' : '$1'.
and_op -> 'and' eol : '$1'.

or_op -> 'or' : '$1'.
or_op -> 'or' eol : '$1'.
or_op -> 'xor' : '$1'.
or_op -> 'xor' eol : '$1'.

pipe_op -> '|' : '$1'.
pipe_op -> '|' eol : '$1'.

bin_concat_op -> '<>' : '$1'.
bin_concat_op -> '<>' eol : '$1'.

in_op -> 'in' : '$1'.
in_op -> 'in' eol : '$1'.

when_op -> 'when' : '$1'.
when_op -> 'when' eol : '$1'.

rocket_op -> '=>' : '$1'.
rocket_op -> '=>' eol : '$1'.

arrow_op -> '<-' : '$1'.
arrow_op -> '<-' eol : '$1'.

comp_expr_op -> comp_op : '$1'.
comp_expr_op -> comp_op eol : '$1'.

% Dot operator

dot_op -> '.' : '$1'.
dot_op -> '.' eol : '$1'.

dot_identifier -> identifier : '$1'.
dot_identifier -> expr dot_op identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_ref -> expr dot_op '__ref__' : { '.', ?line('$2'), ['$1', '$3'] }.

dot_bracket_identifier -> bracket_identifier : '$1'.
dot_bracket_identifier -> expr dot_op bracket_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_paren_identifier -> paren_identifier : '$1'.
dot_paren_identifier -> expr dot_op paren_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_punctuated_identifier -> punctuated_identifier : '$1'.
dot_punctuated_identifier -> expr dot_op punctuated_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

parens_call -> dot_paren_identifier : '$1'.
parens_call -> expr dot_call_op : { '.', ?line('$2'), ['$1'] }. % Fun/local calls

% Function calls

call_args_no_parens -> comma_expr : lists:reverse('$1').
call_args_no_parens -> kw_base : ['$1'].
call_args_no_parens -> comma_expr comma_separator kw_base : lists:reverse(['$3'|'$1']).

comma_expr -> expr : ['$1'].
comma_expr -> comma_expr comma_separator expr : ['$3'|'$1'].

call_args_comma_expr -> comma_expr : lists:reverse('$1').
call_args_comma_expr -> kw_base : ['$1'].
call_args_comma_expr -> comma_expr comma_separator kw_base : lists:reverse(['$3'|'$1']).

call_args_parens -> open_paren ')' : [].
call_args_parens -> open_paren call_args_comma_expr close_paren : '$2'.

call_args -> call_args_comma_expr : build_args('$1').

% KV

kw_expr -> kw_identifier expr : {?exprs('$1'),'$2'}.
kw_eol  -> kw_identifier eol : '$1'.

rocket_expr_list -> rocket_expr : ['$1'].
rocket_expr_list -> rocket_expr_list eol rocket_expr : ['$3'|'$1'].

rocket_expr -> expr : '$1'.
rocket_expr -> expr rocket_op expr : build_op('$2', '$1', '$3').

kw_item -> kw_eol rocket_expr_list eol : { ?exprs('$1'), build_kw(lists:reverse('$2')) }.
kw_item -> kw_eol : { ?exprs('$1'), nil }.

kw_list -> kw_item : ['$1'].
kw_list -> kw_item kw_list : ['$1'|'$2'].

kw_any -> kw_expr : ['$1'].
kw_any -> kw_list 'end' : '$1'.

kw_comma -> kw_any : '$1'.
kw_comma -> kw_any comma_separator kw_comma : '$1' ++ '$3'.

kw_base -> kw_comma : sort_kw('$1').

%% Stab block

stab_eol -> '->' : '$1'.
stab_eol -> '->' eol : '$1'.

end_eol -> 'end' : '$1'.
end_eol -> eol 'end' : '$2'.

stab_block -> stab_eol 'end'             : [{do,nil}].
stab_block -> stab_eol expr_list end_eol : [{do,build_block('$2')}].

% Lists

bracket_access -> open_bracket ']' : { [], ?line('$1') }.
bracket_access -> open_bracket expr close_bracket : { '$2', ?line('$1') }.
bracket_access -> open_bracket kw_base close_bracket : { '$2', ?line('$1') }.

list -> open_bracket ']' : [].
list -> open_bracket kw_base close_bracket : '$2'.
list -> open_bracket expr close_bracket : ['$2'].
list -> open_bracket expr comma_separator call_args close_bracket : ['$2'|'$4'].

% Tuple

tuple -> open_curly '}' : build_tuple('$1', []).
tuple -> open_curly call_args close_curly :  build_tuple('$1', '$2').

% Bitstrings

bit_string -> open_bit '>>' : { '<<>>', ?line('$1'), [] }.
bit_string -> open_bit call_args close_bit : { '<<>>', ?line('$1'), '$2' }.

Erlang code.

-define(op(Node), element(1, Node)).
-define(line(Node), element(2, Node)).
-define(exprs(Node), element(3, Node)).

% The following directive is needed for (significantly) faster compilation
% of the generated .erl file by the HiPE compiler. Please do not remove.
-compile([{hipe,[{regalloc,linear_scan}]}]).

%% Operators

build_op(Op, Left, Right) when tuple_size(Op) == 3 ->
  { ?exprs(Op), ?line(Op), [Left, Right] };

build_op(Op, Left, Right) ->
  { ?op(Op), ?line(Op), [Left, Right] }.

build_unary_op(Op, Expr) ->
  { ?op(Op), ?line(Op), [Expr] }.

build_special_op(Op, Expr) ->
  { ?exprs(Op), ?line(Op), [Expr] }.

build_tuple(_Marker, [Left, Right]) ->
  { Left, Right };

build_tuple(Marker, Args) ->
  { '{}', ?line(Marker), Args }.

%% Blocks

build_block(Exprs) -> build_block(Exprs, true).

build_block([], _)                            -> nil;
build_block([nil], _)                         -> { '__block__', 0, [nil] };
build_block([Expr], _) when not is_list(Expr) -> Expr;
build_block(Exprs, true)                      -> { '__block__', 0, lists:reverse(Exprs) };
build_block(Exprs, false)                     -> { '__block__', 0, Exprs }.

%% Args

build_args(Args) -> Args.

%% Identifiers

build_identifier(Expr, [], Block) ->
  build_identifier(Expr, [Block]);

build_identifier(Expr, Args, Block) ->
  build_identifier(Expr, Args ++ [Block]).

build_identifier({ '.', DotLine, [Expr, { Kind, _, Identifier }] }, Args) when
  Kind == identifier; Kind == punctuated_identifier; Kind == bracket_identifier;
  Kind == paren_identifier ->
  build_identifier({ '.', DotLine, [Expr, Identifier] }, Args);

build_identifier({ '.', Line, _ } = Dot, Args) ->
  FArgs = case Args of
    nil -> [];
    _ -> Args
  end,
  { Dot, Line, build_args(FArgs) };

build_identifier({ _, Line, Identifier }, nil) ->
  { Identifier, Line, nil };

build_identifier({ _, Line, Identifier }, Args) ->
  { Identifier, Line, build_args(Args) }.

%% Access

build_access(Expr, Access) ->
  { access, ?line(Access), [ Expr, ?op(Access) ] }.

%% Interpolation aware

build_sigil({ sigil, Line, Sigil, Parts, Modifiers }) ->
  { list_to_atom([$_,$_,Sigil,$_,$_]), Line, [ { '<<>>', Line, Parts }, Modifiers ] }.

build_bin_string({ bin_string, _Line, [H] }) when is_binary(H) -> H;
build_bin_string({ bin_string, Line, Args }) -> { '<<>>', Line, Args }.

build_list_string({ list_string, _Line, [H] }) when is_binary(H) -> binary_to_list(H);
build_list_string({ list_string, Line, Args }) -> { binary_to_list, Line, [{ '<<>>', Line, Args}] }.

build_atom({ atom, _Line, [H] }) when is_atom(H) -> H;
build_atom({ atom, _Line, [H] }) when is_binary(H) -> binary_to_atom(H, utf8);
build_atom({ atom, Line, Args }) -> { binary_to_atom, Line, [{ '<<>>', Line, Args}, utf8] }.

%% build_kw
%% TODO: Pass the line forward

build_kw([{ '=>', Line, [Left, Right] }|T]) ->
  { '=>', Line, build_kw(T, Left, [Right], []) };

build_kw(Else) ->
  build_block(Else, false).

build_kw([{ '=>', _, [Left, Right] }|T], Marker, Temp, Acc) ->
  H = { Marker, build_block(Temp) },
  build_kw(T, Left, [Right], [H|Acc]);

build_kw([H|T], Marker, Temp, Acc) ->
  build_kw(T, Marker, [H|Temp], Acc);

build_kw([], Marker, Temp, Acc) ->
  H = { Marker, build_block(Temp) },
  lists:reverse([H|Acc]).

sort_kw(List) -> lists:sort(fun sort_kw/2, List).
sort_kw({ A, _ }, { B, _ }) -> A =< B.