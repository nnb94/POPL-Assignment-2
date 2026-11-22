% Tests for P2 (code/15_q2.pl).
% Run from the repo root:
%   swipl -q -g run_tests -t halt tests/test_q2.pl
:- use_module(library(plunit)).
:- ensure_loaded('../code/15_q2').

spec_4253(["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
           "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"]).

:- begin_tests(split).
test(four) :- findall(L-R, split([4,2,5,3], L, R), X),
    X == [[4]-[2,5,3], [4,2]-[5,3], [4,2,5]-[3]].
test(empty, [fail]) :- split([], _, _).
test(single, [fail]) :- split([5], _, _).
:- end_tests(split).

:- begin_tests(expr).
test(leaf, [nondet]) :- expr([5], T), T == 5.
test(empty, [fail]) :- expr([], _).
test(count_two)   :- aggregate_all(count, expr([1,2], _), 4).
test(count_three) :- aggregate_all(count, expr([1,2,3], _), 32).
test(count_four)  :- aggregate_all(count, expr([4,2,5,3], _), 320).
test(no_duplicate_trees) :-
    findall(T, expr([1,2,3,4], T), Ts), length(Ts, N), sort(Ts, U), length(U, N).
:- end_tests(expr).

:- begin_tests(eval).
test(add) :- eval(4+2, 6).
test(nested_left) :- eval((8/4)*2, 4).
test(nested_right) :- eval(8/(4*2), 1).
test(negative_sub) :- eval(3-5, -2).
test(negative_div) :- eval((3-9)/2, -3).
test(zero_numerator) :- eval(0/5, 0).
test(inexact, [fail]) :- eval(1/2, _).
test(div_by_zero, [fail]) :- eval(5/0, _).
test(inner_div_by_zero, [fail]) :- eval(3/(2-2), _).
test(inner_inexact, [fail]) :- eval((1/2)*4, _).   % 1/2 is not exact even though *4 would fix it
test(integer_result) :- eval(6/3, V), integer(V).
:- end_tests(eval).

:- begin_tests(to_string).
ts(T, E) :- once(to_string(T, S)), string(S), S == E.
test(spec_1) :- ts((4+2)*3, "(4+2)*3").
test(spec_2) :- ts(4+2*3, "4+2*3").
test(spec_3) :- ts((8/4)*2, "8/4*2").
test(spec_4) :- ts(8/(4*2), "8/(4*2)").
test(spec_5) :- ts((1-2)-3, "1-2-3").
test(spec_6) :- ts(1-(2-3), "1-(2-3)").
test(spec_7) :- ts(1+(2+3), "1+(2+3)").
test(spec_8) :- ts((1+2)+3, "1+2+3").
test(number) :- ts(42, "42").
test(both_sides) :- ts((1+2)*(3+4), "(1+2)*(3+4)").
test(div_chain) :- ts(8/(2/2), "8/(2/2)").
test(distinct_strings) :-
    findall(S, (expr([1,2,3,4], T), to_string(T, S)), Ss),
    length(Ss, N), sort(Ss, U), length(U, N).
:- end_tests(to_string).

:- begin_tests(generate_equation).
test(empty, [fail])  :- generate_equation([], _).
test(single, [fail]) :- generate_equation([5], _).
test(none_234, [fail]) :- generate_equation([2,3,4], _).
test(one_of_spec, [nondet]) :-
    generate_equation([4,2,5,3], E), string(E), spec_4253(Es), memberchk(E, Es).
test(every_answer_valid) :-
    spec_4253(Es),
    forall(generate_equation([4,2,5,3], E), memberchk(E, Es)).
test(bound_check, [nondet]) :- generate_equation([4,2,5,3], "4=2+5-3").
test(bound_wrong, [fail]) :- generate_equation([4,2,5,3], "4+2=5+3").
test(only_248, [nondet]) :- generate_equation([2,4,8], E), E == "2*4=8".
test(equal_pair, [nondet]) :- generate_equation([3,3], "3=3").
test(no_spaces, [nondet]) :-
    generate_equation([4,2,5,3], E), \+ sub_string(E, _, _, _, " ").
:- end_tests(generate_equation).

:- begin_tests(all_equations).
test(spec_4253) :- spec_4253(X), all_equations([4,2,5,3], Es), Es == X.
test(spec_234) :- all_equations([2,3,4], Es), Es == [].
test(spec_248) :- all_equations([2,4,8], Es), Es == ["2*4=8"].
test(empty) :- all_equations([], Es), Es == [].
test(single) :- all_equations([5], Es), Es == [].
test(sorted_no_dups) :- all_equations([1,1,1,1,1], Es), sort(Es, S), Es == S.
test(all_strings) :- all_equations([4,2,5,3], Es), maplist(string, Es).
test(zeros) :- all_equations([0,0], Es), Es == ["0=0"].
:- end_tests(all_equations).

:- begin_tests(count_equations).
test(c_4253) :- count_equations([4,2,5,3], 7).
test(c_234)  :- count_equations([2,3,4], 0).
test(c_248)  :- count_equations([2,4,8], 1).
test(c_empty) :- count_equations([], 0).
test(c_single) :- count_equations([5], 0).
test(c_12345) :- count_equations([1,2,3,4,5], 14).
:- end_tests(count_equations).
