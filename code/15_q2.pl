% CS F301 Assignment 2 - P2: Form a Valid Arithmetic Equation
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).

%% split(+List, -Left, -Right)
%  Left and Right are both non-empty and append(Left, Right, List),
%  i.e. List is cut once, keeping the original order of the numbers.
%  Declarative reading: Left is a non-empty proper prefix of List and
%  Right is the non-empty rest.
%  On backtracking it gives the k-1 splits of a list of length k,
%  shortest Left first. It fails (finitely) for lists of length 0 or 1.
split(List, Left, Right) :-
    Left = [_|_],
    Right = [_|_],
    append(Left, Right, List).

%% op(?Op)
%  The four binary operators that may join two sub-expressions.
op(+).
op(-).
op(*).
op(/).

%% expr(+Nums, -Tree)
%  Tree is an expression tree that uses every number of Nums exactly once,
%  in the given order. A tree is either a number (leaf) or a term
%  Op(Left, Right) such as 4+(2*3), built with an operator from op/1.
%  Declarative reading: a single number is an expression; otherwise
%  Tree joins an expression over a non-empty prefix of Nums and an
%  expression over the non-empty rest with one operator.
%  Each recursive call is on a strictly shorter list, so it terminates.
%  It fails for []. Parentheses are implicit in the tree shape.
expr([N], N) :-
    integer(N).
expr(Nums, Tree) :-
    split(Nums, LeftNums, RightNums),
    expr(LeftNums, Left),
    expr(RightNums, Right),
    op(Op),
    Tree =.. [Op, Left, Right].

%% eval(+Tree, -Value)
%  Value is the integer value of the expression tree Tree.
%  Declarative reading: a number evaluates to itself; Op(L, R) evaluates
%  to the result of applying Op to the values of L and R.
%  Division is allowed only when it is exact: the divisor is not zero and
%  leaves no remainder. This is checked at every / node, so eval fails
%  (it never raises an error and never produces a float) for trees like
%  1/2 or 3/(2-2). Values of sub-expressions may be negative.
eval(N, N) :-
    integer(N).
eval(L + R, V) :- eval(L, A), eval(R, B), V is A + B.
eval(L - R, V) :- eval(L, A), eval(R, B), V is A - B.
eval(L * R, V) :- eval(L, A), eval(R, B), V is A * B.
eval(L / R, V) :-
    eval(L, A), eval(R, B),
    B =\= 0,
    A mod B =:= 0,
    V is A // B.

%% prec(?Op, ?P)
%  Precedence of each operator: * and / bind tighter than + and -.
prec(+, 1).
prec(-, 1).
prec(*, 2).
prec(/, 2).

%% to_string(+Tree, -String)
%  String is the canonical text of Tree (an SWI-Prolog string, no spaces).
%  Declarative reading: a number is written in decimal; Op(L, R) is the
%  text of L, then Op, then the text of R, where
%    - L is wrapped in parentheses only if its top operator has LOWER
%      precedence than Op (operators are left-associative), and
%    - R is wrapped if its top operator has the SAME OR LOWER precedence.
%  A number is never wrapped. So every distinct tree gets a distinct string,
%  e.g. 1+2+3 is (1+2)+3 while 1+(2+3) keeps its parentheses.
to_string(N, S) :-
    integer(N),
    number_string(N, S).
to_string(Tree, S) :-
    Tree =.. [Op, L, R],
    prec(Op, P),
    operand_string(L, P, left, LS),
    operand_string(R, P, right, RS),
    atomic_list_concat([LS, Op, RS], A),
    atom_string(A, S).

%% operand_string(+Tree, +ParentPrec, +Side, -String)
%  String is the text of Tree as an operand on Side (left or right) of an
%  operator with precedence ParentPrec, with parentheses added by the rule.
operand_string(T, ParentP, Side, S) :-
    to_string(T, S0),
    (   needs_parens(T, ParentP, Side)
    ->  string_concat("(", S0, S1),
        string_concat(S1, ")", S)
    ;   S = S0
    ).

%% needs_parens(+Tree, +ParentPrec, +Side)
%  True when Tree must be parenthesised as a Side operand of a parent with
%  precedence ParentPrec. Numbers never need parentheses.
needs_parens(T, ParentP, left) :-
    \+ integer(T),
    T =.. [Op, _, _], prec(Op, P),
    P < ParentP.
needs_parens(T, ParentP, right) :-
    \+ integer(T),
    T =.. [Op, _, _], prec(Op, P),
    P =< ParentP.
