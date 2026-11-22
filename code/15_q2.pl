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
