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
