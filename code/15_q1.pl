% CS F301 Assignment 2 - P1: Department Assignment Puzzle, Reloaded
:- use_module(library(lists)).

%% depts(-Ds), langs(-Ls), projects(-Ps)
%  The four values of each attribute, exactly as given in the spec.
depts([research, development, design, testing]).
langs([python, java, 'c++', javascript]).
projects(['AI', web, embedded, data]).

%% solution(-S)
%  S is a candidate solution: four terms p(Name, Dept, Lang, Project)
%  in the order Alex, Ben, Carla, Dana, where each attribute's values
%  are a permutation of its four values (so every value is used once).
%  Declarative reading: S is a solution if its departments, languages
%  and projects are each some ordering of the allowed values.
%  On backtracking it enumerates all 4! * 4! * 4! = 13824 candidates.
solution([p('Alex',  D1, L1, P1),
          p('Ben',   D2, L2, P2),
          p('Carla', D3, L3, P3),
          p('Dana',  D4, L4, P4)]) :-
    depts(Ds),    permutation(Ds, [D1, D2, D3, D4]),
    langs(Ls),    permutation(Ls, [L1, L2, L3, L4]),
    projects(Ps), permutation(Ps, [P1, P2, P3, P4]).

%% clue(+N, +S)
%  clue(N, S) holds when clue number N is true in the fully
%  filled-in solution S. Each clue is checked on a ground S
%  (generate with solution/1 first, then test), so negations are safe.

% CLUE 1: The friend who prefers the AI project does not work in
% research and is not Dana.
clue(1, S) :-
    member(p(Name, Dept, _, 'AI'), S),
    Dept \== research,
    Name \== 'Dana'.

% CLUE 2: Alex does not work in development and does not prefer C++.
clue(2, S) :-
    member(p('Alex', Dept, Lang, _), S),
    Dept \== development,
    Lang \== 'c++'.

% CLUE 3: The friend working in the testing department likes Python.
clue(3, S) :-
    member(p(_, testing, Lang, _), S),
    Lang == python.

% CLUE 4: Ben prefers web projects and does not work in testing.
clue(4, S) :-
    member(p('Ben', Dept, _, Proj), S),
    Proj == web,
    Dept \== testing.
