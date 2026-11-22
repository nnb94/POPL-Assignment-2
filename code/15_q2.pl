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
