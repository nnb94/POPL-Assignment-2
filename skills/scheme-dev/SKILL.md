---
name: scheme-dev
description: Conventions, allowed built-ins, run/test commands, self-review checklist and known AI failure modes for Racket 8.x (#lang racket/base) work in CS F301 Assignment 2 (S1 tree traversals, S2 nested insert). Use for any Scheme function, test or review in this repo.
---

# Scheme development (CS F301, Assignment 2)

## Language and environment
- Racket 8.x, every file starts with `#lang racket/base`.
- **Only these built-ins** may appear: `define`, `lambda`, `let`, `let*`, `letrec`, named `let`, `if`, `cond` (with `else`), `and`, `or`, `not`, `begin`, `quote` / `'`, `cons`, `car`, `cdr`, `list`, c[ad]{1,4}r compositions, `null?`, `pair?`, `eq?`, `assq`, `assoc`, `+ - * < > <= >= =`, `max`, `display`, `newline`. S2 additionally allows `read`.
- **Forbidden**: `set!` and relatives, vectors, hash tables, strings, `do`/`for` loops, `length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`, `list-tail`, `apply`, `foldl`, `when`, `unless`, `case`, `number?`, `symbol?`, `list?`, `error`, `printf`. Write helpers instead (`my-reverse`, `my-append`, `my-length`, `my-map`).

## How code is run
```
racket code/15_q3.rkt          ; grader appends its own calls; loading alone prints nothing
# grader-style check of S2: append the call, feed x lst n on stdin
(cat code/15_q4.rkt; echo "(print-insert-result)") > /tmp/t.rkt
echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket /tmp/t.rkt
```
(Group 15, so the spec's `id_q3.rkt` is `15_q3.rkt`.)
Tests live in `tests/test_q3.rkt` / `tests/test_q4.rkt` and run with `racket tests/test_q3.rkt` and `racket tests/test_q4.rkt`. The solution files have no `provide` (only definitions are allowed), so the tests `dynamic-require` the file and evaluate calls inside its module namespace (`module->namespace`), the same way the grader's appended calls see the definitions. A passing run prints only the final `test_qN: done` line.

## Coding conventions
- Names in `kebab-case`; predicates end in `?`; helpers prefixed `my-` when replacing a forbidden built-in.
- Each function has a comment: signature, then a **recursive reading** ("the inorder list of a node is inorder(left) ++ (value) ++ inorder(right)").
- The file contains **only definitions**: no top-level calls, no top-level `display`.
- All state passes through arguments (accumulators). No mutation.
- Prefer tail recursion with accumulators where natural (e.g. `my-length`, `my-reverse`, traversals built with an accumulator to avoid `append`).
- Every printing function ends with `(newline)`.
- One unit of work per answer: write only the function(s) asked for plus needed helpers.

## S1 notes
- Tree: `()` or `(value left right)`; `value` = `car`, `left` = `cadr`, `right` = `caddr`.
- Height of `()` is 0; leaf = node with both subtrees `()`; empty tree has 0 leaves.
- Build traversal lists with an accumulator walking right-to-left to avoid `append` (e.g. inorder: `(walk left (cons v (walk right acc)))`).

## S2 notes
- Length is measured on the **original** list, before inserting.
- Top-level list is treated like any other; `()` becomes `(x)` when `0 < n`.
- Atom test: not `pair?` and not `null?` (no `symbol?`/`number?`).
- Hidden tests: depth 100 and 10,000-element lists — `my-length` and `my-map` must not blow up; make `my-length` tail-recursive, and make `my-map` iterative (accumulate then `my-reverse`).
- Final file contains exactly **one** `insert-if-short`, defined via `make-inserter`.
- `print-insert-result` reads `x`, `lst`, `n` with `read` in that order and prints only the result plus newline.

## Self-review checklist (apply before answering)
1. Scan every identifier: is it on the allowed list or defined in this file? Flag anything else.
2. Any `set!`, string, vector, loop, `append`, `length`, `map`, `reverse`, `member`? Replace.
3. Any top-level expression other than `define`? Remove it.
4. Does every printing function end with `newline` and print exactly the spec format?
5. Edge cases: empty tree / empty list, single node, `n = 0`, deeply nested input.
6. Is recursion depth safe for 10,000 elements (tail recursion / accumulator)?
7. Run the spec examples and show actual vs expected output.

## Known AI failure modes in Scheme/Racket
- Reaching for `append`, `map`, `length`, `reverse`, `filter`, `foldl` out of habit.
- Using `when`/`unless`, `printf`, `format`, `list?`, `symbol?`, `number?`, `case`, `length` — all outside the allowed set.
- Using `define` inside a body in ways that rely on `racket` (not `racket/base`) features; or writing `#lang racket` instead of `#lang racket/base`.
- Measuring length after insertion in S2 (off-by-one on boundary cases like length `n-1`).
- Treating `()` as an atom, or skipping insertion into empty lists.
- Leaving test calls at the top level of the solution file.
- Defining `insert-if-short` twice (old and new version) in S2.
- Non-tail-recursive helpers that stack-overflow on large hidden tests.
