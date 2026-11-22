#lang racket/base

;; S2: Conditionally insert into a nested list (CS F301 Assignment 2, group 15)
;; Only the allowed built-ins are used (S2 also allows read). length, map and
;; reverse are forbidden, so my-length, my-map and my-reverse replace them.
;; Hidden tests use lists of 10,000 elements, so every list walk below is a
;; tail call (named let with an accumulator): the stack does not grow with
;; the length of the list.

;; (my-length lst) -> number of top-level elements of lst.
;; Reading: the length of () is acc; the length of (a . rest) is the length
;; of rest with acc + 1. Tail-recursive: the recursive call is the last step.
(define (my-length lst)
  (let loop ((l lst) (acc 0))
    (if (null? l)
        acc
        (loop (cdr l) (+ acc 1)))))

;; (my-reverse lst) -> the top-level elements of lst in reverse order.
;; Reading: reversing () onto acc gives acc; reversing (a . rest) onto acc
;; is reversing rest onto (a . acc). Tail-recursive.
(define (my-reverse lst)
  (let loop ((l lst) (acc '()))
    (if (null? l)
        acc
        (loop (cdr l) (cons (car l) acc)))))

;; (my-map f lst) -> the list of (f a) for every top-level element a of lst,
;; in the original order.
;; Reading: walk lst once, consing (f a) onto acc (so acc is the result
;; reversed), then reverse acc at the end. Iterative: both the walk and
;; my-reverse are tail calls, so a 10,000-element list is safe.
(define (my-map f lst)
  (let loop ((l lst) (acc '()))
    (if (null? l)
        (my-reverse acc)
        (loop (cdr l) (cons (f (car l)) acc)))))

;; (list-value? e) -> #t when e is a list: () or a pair. Atoms are everything
;; else (numbers and symbols); symbol? and number? are not allowed, so an
;; atom is recognised as "neither a pair nor ()". There are no dotted pairs.
(define (list-value? e)
  (or (null? e) (pair? e)))

;; (insert-if-short x lst n) -> lst with x inserted at the front of every
;; list (lst itself included, at every level of nesting) whose length is < n.
;; Reading: first rebuild every element of lst (sublists recursively, atoms
;; unchanged) with my-map; then, if the ORIGINAL lst has fewer than n
;; top-level elements, cons x in front of the rebuilt list.
;; The length is taken on lst before anything is inserted, and () is not
;; special: it has length 0, so it becomes (x) whenever 0 < n.
(define (insert-if-short x lst n)
  (let ((rebuilt (my-map (lambda (e)
                           (if (list-value? e)
                               (insert-if-short x e n)
                               e))
                         lst)))
    (if (< (my-length lst) n)
        (cons x rebuilt)
        rebuilt)))

;; S2.a (print-insert-result): reads x, then lst, then n from standard input
;; with read, and prints (insert-if-short x lst n) followed by a newline.
;; let* evaluates its bindings in order, so the three reads happen in the
;; order the spec gives. No prompt or other text is printed.
(define (print-insert-result)
  (let* ((x (read))
         (lst (read))
         (n (read)))
    (display (insert-if-short x lst n))
    (newline)))
