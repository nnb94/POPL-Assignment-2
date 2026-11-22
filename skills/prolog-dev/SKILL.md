---
name: prolog-dev
description: Conventions, run/test commands, self-review checklist and known AI failure modes for SWI-Prolog 9.x work in CS F301 Assignment 2 (P1 puzzle, P2 equations). Use for any Prolog predicate, test or review in this repo.
---

# Prolog development (CS F301, Assignment 2)

## Language and environment
- SWI-Prolog 9.x only.
- Allowed libraries: `lists`, `apply`, `yall`, `aggregate`. Load them with `:- use_module(library(...)).` and nothing else.
- Forbidden: `assert*`, `retract*`, `b_setval`, `nb_setval`, any global state, and any `initialization` directive. Never call `halt/0` in the file.
- The file contains only definitions (plus `use_module` directives).

## How code is run
```
swipl -q -f code/id_q1.pl -g main -t halt
swipl -q -f code/id_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), print(N), nl" -t halt
swipl -q -f code/id_q2.pl -g "all_equations([4,2,5,3],Es), print(Es), nl" -t halt
```
Tests live in `tests/` (e.g. `tests/test_q1.pl`) and use `plunit`-free plain goals or `library(plunit)` only inside the test file, never in `code/`. Run them with:
```
swipl -q -f code/id_q1.pl -g "consult('tests/test_q1.pl'), run_tests" -t halt
```

## Coding conventions
- Predicate names in `snake_case`; variables in `CamelCase`. Group predicates with all their clauses next to each other.
- Every predicate has a header comment: `%% name(+In, -Out)` with mode annotations, then **one line of declarative reading** ("`clue(5, S)` holds when the friend whose language is java has department design").
- One unit of work per answer: write only the predicate(s) asked for, plus any small helper it needs. Do not rewrite unrelated predicates.
- Output only what the spec says. `main/0` prints exactly the required lines; no debug `format` left in.
- Strings vs atoms: P2 equations must be SWI strings (`"4*2=5+3"`), built with `format(string(S), ...)` or `string_concat/3`, never `atom_codes` round-trips or `term_to_atom` parsing.

## P1-specific rules
- Solution shape: `[p('Alex',D1,L1,P1), p('Ben',...), p('Carla',...), p('Dana',...)]`.
- Atoms exactly: `research, development, design, testing`; `python, java, 'c++', javascript`; `'AI', web, embedded, data`. Note the quotes on `'c++'` and `'AI'`.
- Each clue is its own `clue(N, S)` clause that is **checked on a fully ground solution** (generate with `permutation/2`, then test).
- `count_solutions/2` must enforce exactly the clues in `Active` and ignore the rest; use `forall/2` or `maplist` over `Active` inside `aggregate_all(count, ...)` / `findall/3`.
- Clue 9 must not name a friend; comment line directly above it starts `% CLUE 9:`.

## P2-specific rules
- Split the list at every `j` with `1 =< j < k`; build every expression tree over each part.
- Evaluate on the tree (`eval/2`), never by building a string and parsing it.
- Division: fail unless divisor `=\= 0` and `X mod Y =:= 0`; apply at **every** `/` node. Use integer arithmetic (`//`), never `/` that yields floats.
- Printing follows the canonical-parenthesis rule: left operand in parens only if lower precedence than parent; right operand in parens if same or lower precedence. Numbers never parenthesised.
- `all_equations/2`: `findall` then `sort/2` (removes duplicates). Empty list when none. Lists of length 0 or 1 must fail/return `[]` cleanly.

## Self-review checklist (apply before answering)
1. Does every requested predicate exist with the exact name and arity?
2. Any `assert`, `retract`, global variable, `initialization`, or `halt`? Remove it.
3. Any library outside lists/apply/yall/aggregate? Remove it.
4. Are atoms spelled and quoted exactly as in the spec (`'c++'`, `'AI'`, `'Alex'`)?
5. Does the predicate terminate and fail (not error, not loop) on edge inputs (`[]`, one element, no solution)?
6. Does `is/2` ever see an unbound variable? Is integer division exact-checked?
7. Is output exactly the specified format, with no extra prints or trailing spaces?
8. Run the spec examples mentally (or actually) and state the result.

## Known AI failure modes in Prolog
- Writing clues as constraints on partially bound terms, so `\=`/`\+` succeed or fail wrongly before variables are bound. Always generate first, then test.
- Using `member/2` instead of `permutation/2`, which allows repeated attribute values.
- Forgetting quotes on `'c++'` / `'AI'` (unquoted `c++` is a syntax error; `AI` is a variable).
- Using `/` instead of `//`, giving floats like `2.0` that never unify with integers.
- Producing duplicate solutions or forgetting `sort/2`.
- Left recursion in expression grammars causing infinite loops; always split the number list so each recursive call is on a strictly shorter list.
- Printing atoms with `print/1` (adds quotes) when `write/1` or `format("~w")` is wanted.
- Leaving choice points or debug output; adding `halt` or `initialization(main)` "for convenience".
- Hard-coding the puzzle answer in `main/0`.
