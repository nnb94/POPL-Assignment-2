# P1 Report — Department Assignment Puzzle, Reloaded

Group 15 · code: `code/15_q1.pl` · tests: `tests/test_q1.pl`

## P1.b: value of N for clues 1 to 8

```
?- count_solutions([1,2,3,4,5,6,7,8], N).
N = 3.
```

**N = 3.** Out of the 4! × 4! × 4! = 13,824 candidate assignments, exactly three satisfy all eight clues:

| Solution | Alex | Ben | Carla | Dana |
|---|---|---|---|---|
| A | design, java, AI | development, javascript, web | research, c++, data | testing, python, embedded |
| B | design, java, embedded | development, javascript, web | testing, python, AI | research, c++, data |
| C | testing, python, embedded | development, javascript, web | design, java, AI | research, c++, data |

How the count narrows as clues are added (from `count_solutions/2`):

| Active clues | N |
|---|---|
| none | 13,824 |
| 1–4 | 208 |
| 1–7 | 16 |
| 1–8 | 3 |

## What N = 3 tells us about the puzzle

- **The original puzzle is under-determined.** Clues 1–8 are consistent (N > 0), but they do not have a unique answer, so "the" solution cannot be derived from them. `main/0` (P1.a) therefore prints just the first solution Prolog finds (solution A), which is a valid answer but not the only one.
- **Some facts are fixed anyway.** Ben is development / javascript / web in all three solutions. The friend in testing always uses Python, the Java user is always in design and the data project always goes with research and C++. These follow from clues 3, 5 and 8.
- **What stays open is who gets which combination** for Alex, Carla and Dana.
- **Solutions A and C cannot be told apart without names.** In both, the three non-Ben friends hold exactly the same three combinations: design+java+AI, research+c+++data and testing+python+embedded. The only difference is which person holds which. Any clue that refers to friends only through attribute values (as P1.c requires) is either true in both A and C or false in both. So the only solution a name-free ninth clue can keep is **B**, the one where Python goes with AI instead of embedded.

## P1.c: the repair

```prolog
% CLUE 9: The friend whose favorite language is Python prefers the AI project.
clue(9, S) :-
    member(p(_, _, python, Proj), S),
    Proj == 'AI'.
```

It is true in B (Carla: python, AI) and false in A and C, where the Python user prefers embedded. With it:

```
?- count_solutions([1,2,3,4,5,6,7,8,9], N).
N = 1.
```

The unique solution is:

```
Alex = [design, java, embedded]
Ben = [development, javascript, web]
Carla = [testing, python, AI]
Dana = [research, c++, data]
```

## How to reproduce

```
swipl -q -f code/15_q1.pl -g main -t halt
swipl -q -f code/15_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), print(N), nl" -t halt
swipl -q -f code/15_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8,9],N), print(N), nl" -t halt
swipl -q -g run_tests -t halt tests/test_q1.pl
```
