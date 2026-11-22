# POPL-Assignment-2
Group assignment for CS F301 Principles of Programming Languages – Assignment 2, covering Logic Programming in Prolog and Functional Programming in Scheme (Racket).

Group ID: **15** (so the spec's `id_q1.pl` is `15_q1.pl`, and so on). Tested with SWI-Prolog 9.2.9 and Racket 8.18.

## Layout

```
code/      15_q1.pl  15_q2.pl  15_q3.rkt  15_q4.rkt
tests/     test_q1.pl  test_q2.pl  test_q3.rkt  test_q4.rkt
skills/    prolog-dev/SKILL.md  scheme-dev/SKILL.md
prompts/   P1.md  P2.md  S1.md  S2.md   (prompts used, word for word)
P1_REPORT.md
```

## Running (from the repo root)

```
swipl -q -f code/15_q1.pl -g main -t halt
swipl -q -f code/15_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), print(N), nl" -t halt
swipl -q -f code/15_q2.pl -g "all_equations([4,2,5,3],Es), print(Es), nl" -t halt
racket code/15_q3.rkt      # definitions only; the grader appends its calls
racket code/15_q4.rkt      # definitions only; the grader appends its calls
```

## Tests

```
swipl -q -g run_tests -t halt tests/test_q1.pl
swipl -q -g run_tests -t halt tests/test_q2.pl
racket tests/test_q3.rkt
racket tests/test_q4.rkt
```
