% Tests for P1 (code/15_q1.pl).
% Run from the repo root:
%   swipl -q -g run_tests -t halt tests/test_q1.pl
:- use_module(library(plunit)).
:- ensure_loaded('../code/15_q1').

% The unique solution kept by clue 9, and the two it rules out.
kept([p('Alex',design,java,embedded), p('Ben',development,javascript,web),
      p('Carla',testing,python,'AI'), p('Dana',research,'c++',data)]).
dropped_a([p('Alex',design,java,'AI'), p('Ben',development,javascript,web),
           p('Carla',research,'c++',data), p('Dana',testing,python,embedded)]).
dropped_c([p('Alex',testing,python,embedded), p('Ben',development,javascript,web),
           p('Carla',design,java,'AI'), p('Dana',research,'c++',data)]).

clues_1_8([1,2,3,4,5,6,7,8]).

:- begin_tests(generator).

test(candidate_count) :-
    aggregate_all(count, solution(_), 13824).

test(names_in_order) :-
    once(solution(S)),
    findall(N, member(p(N,_,_,_), S), ['Alex','Ben','Carla','Dana']).

% Every candidate uses each attribute value exactly once.
test(each_value_used_once) :-
    forall(solution(S),
           ( findall(D, member(p(_,D,_,_), S), Ds), msort(Ds, [design,development,research,testing]),
             findall(L, member(p(_,_,L,_), S), Ls), msort(Ls, ['c++',java,javascript,python]),
             findall(P, member(p(_,_,_,P), S), Ps), msort(Ps, ['AI',data,embedded,web]) )).

:- end_tests(generator).

:- begin_tests(clues).

% Each clue on its own: counts follow from simple probability over 13824.
test(clue1) :- count_solutions([1], 7776).
test(clue2) :- count_solutions([2], 7776).
test(clue3) :- count_solutions([3], 3456).
test(clue4) :- count_solutions([4], 2592).
test(clue5) :- count_solutions([5], 3456).
test(clue6) :- count_solutions([6], 7776).
test(clue7) :- count_solutions([7], 5184).
test(clue8) :- count_solutions([8], 2592).

% All of clues 1-8 hold in all three surviving solutions.
test(kept_satisfies_1_8)   :- kept(S),      clues_1_8(A), forall(member(N,A), clue(N,S)).
test(dropped_a_satisfies)  :- dropped_a(S), clues_1_8(A), forall(member(N,A), clue(N,S)).
test(dropped_c_satisfies)  :- dropped_c(S), clues_1_8(A), forall(member(N,A), clue(N,S)).

% A clearly wrong assignment fails a clue (AI preferred by Dana -> clue 1 fails).
test(clue1_rejects, [fail]) :-
    clue(1, [p('Alex',research,python,web), p('Ben',development,java,embedded),
             p('Carla',design,'c++',data),  p('Dana',testing,javascript,'AI')]).

:- end_tests(clues).

:- begin_tests(count).

test(empty_active)  :- count_solutions([], 13824).
test(clues_1_to_4)  :- count_solutions([1,2,3,4], 208).
test(clues_1_to_7)  :- count_solutions([1,2,3,4,5,6,7], 16).
test(clues_1_to_8)  :- count_solutions([1,2,3,4,5,6,7,8], 3).
test(order_irrelevant) :- count_solutions([8,7,6,5,4,3,2,1], 3).
test(duplicates_irrelevant) :- count_solutions([1,1,2,3,4,5,6,7,8], 3).

:- end_tests(count).

:- begin_tests(repair).

test(clues_1_to_9_unique) :- count_solutions([1,2,3,4,5,6,7,8,9], 1).
test(clue9_true_in_kept, [nondet]) :- kept(S), clue(9, S).
test(clue9_false_in_a, [fail]) :- dropped_a(S), clue(9, S).
test(clue9_false_in_c, [fail]) :- dropped_c(S), clue(9, S).
test(unique_is_kept) :-
    kept(K), findall(S, solves([1,2,3,4,5,6,7,8,9], S), [K]).

:- end_tests(repair).

:- begin_tests(main_output).

% main/0 prints four lines in the required format and nothing else,
% and the printed assignment satisfies clues 1-8.
test(format, [nondet]) :-
    with_output_to(string(Out), main),
    split_string(Out, "\n", "", Lines0),
    append(Lines, [""], Lines0),
    length(Lines, 4),
    maplist([L]>>sub_string(L, _, _, _, " = ["), Lines),
    Lines = [A,B,C,D],
    sub_string(A, 0, _, _, "Alex = "),
    sub_string(B, 0, _, _, "Ben = "),
    sub_string(C, 0, _, _, "Carla = "),
    sub_string(D, 0, _, _, "Dana = ").

test(exact_output) :-
    with_output_to(string(Out), main),
    Out == "Alex = [design, java, AI]\nBen = [development, javascript, web]\nCarla = [research, c++, data]\nDana = [testing, python, embedded]\n".

% main must succeed exactly once (once/1 inside main removes choice points).
test(deterministic) :- with_output_to(string(_), main).

:- end_tests(main_output).
