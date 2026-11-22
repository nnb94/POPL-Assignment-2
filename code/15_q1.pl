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

% CLUE 5: The friend whose favorite language is Java works in the
% design department.
clue(5, S) :-
    member(p(_, Dept, java, _), S),
    Dept == design.

% CLUE 6: Carla's project preference is not embedded, and her
% department is not development.
clue(6, S) :-
    member(p('Carla', Dept, _, Proj), S),
    Proj \== embedded,
    Dept \== development.

% CLUE 7: Dana's favorite language is not Java, and she works in
% research or testing.
clue(7, S) :-
    member(p('Dana', Dept, Lang, _), S),
    Lang \== java,
    ( Dept == research ; Dept == testing ).

% CLUE 8: The friend who prefers data projects works in research and
% does not use JavaScript.
clue(8, S) :-
    member(p(_, Dept, Lang, data), S),
    Dept == research,
    Lang \== javascript.

%% solves(+Active, -S)
%  S is a candidate solution in which every clue numbered in Active holds.
%  Declarative reading: S solves Active if S is a candidate and no clue
%  in Active fails for S.
solves(Active, S) :-
    solution(S),
    forall(member(N, Active), clue(N, S)).

%% print_friend(+P)
%  Prints one friend as   Name = [Dept, Lang, Project]   on its own line.
%  ~w writes atoms without quotes, so 'c++' prints as c++ and 'AI' as AI.
print_friend(p(Name, Dept, Lang, Proj)) :-
    format("~w = [~w, ~w, ~w]~n", [Name, Dept, Lang, Proj]).

%% main
%  Finds the first solution satisfying clues 1 to 8 (derived from the
%  clues, not hard-coded) and prints it as four lines, Alex to Dana.
%  once/1 commits to that first solution so main leaves no choice point.
main :-
    once(solves([1,2,3,4,5,6,7,8], S)),
    maplist(print_friend, S).
