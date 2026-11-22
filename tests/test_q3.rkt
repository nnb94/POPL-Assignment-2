#lang racket/base
;; Tests for S1 (code/15_q3.rkt).
;; Run from anywhere:  racket tests/test_q3.rkt
;; Prints nothing but rackunit failures; ends with a summary line.
;;
;; The solution file may not use provide, so instead of require we load it
;; and evaluate calls inside its module namespace, the same way the grader's
;; appended calls see its definitions. This test file itself is not bound by
;; the S1 built-in restrictions.

(require rackunit racket/port racket/runtime-path racket/list)

(define-runtime-path solution "../code/15_q3.rkt")

(define ns (make-base-namespace))
(define loading-output
  (with-output-to-string
    (lambda ()
      (parameterize ([current-namespace ns])
        (dynamic-require solution #f)))))
(define mod-ns (parameterize ([current-namespace ns]) (module->namespace solution)))

;; (out expr) -> everything expr prints, as a string.
(define (out expr)
  (with-output-to-string (lambda () (eval expr mod-ns))))

(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))
(define t2 '(1 () (2 () (3 () ()))))
(define t3 '(a (b () ()) (c () ())))

;; --- file hygiene -----------------------------------------------------------
(test-case "loading the file prints nothing"
  (check-equal? loading-output ""))

(test-case "solution uses only allowed built-ins"
  (define allowed
    '(define lambda let let* letrec if cond else and or not begin quote
      cons car cdr list null? pair? eq? assq assoc + - * < > <= >= = max
      display newline))
  (define cxr-ok? ; c[ad]{1,4}r
    (lambda (s)
      (regexp-match? #rx"^c[ad][ad]?[ad]?[ad]?r$" (symbol->string s))))
  (define forms
    (with-input-from-file solution
      (lambda ()
        (read-line) ; skip #lang line
        (let loop ([acc '()])
          (define x (read))
          (if (eof-object? x) (reverse acc) (loop (cons x acc)))))))
  ;; names this file defines itself, and parameter names, are fine
  (define (defined-names fs)
    (for/list ([f fs] #:when (and (pair? f) (eq? (car f) 'define)))
      (if (pair? (cadr f)) (car (cadr f)) (cadr f))))
  (define (params fs)
    (flatten
     (for/list ([f (flatten-forms fs)] #:when (and (pair? f) (eq? (car f) 'define) (pair? (cadr f))))
       (cdr (cadr f)))))
  (define (flatten-forms x)
    (if (pair? x) (cons x (append-map flatten-forms (filter pair? x))) '()))
  (define ok (append allowed (defined-names forms) (params forms)))
  (define bad
    (remove-duplicates
     (filter (lambda (s) (and (symbol? s) (not (memq s ok)) (not (cxr-ok? s))))
             (flatten forms))))
  (check-equal? bad '() (format "forbidden identifiers: ~a" bad)))

;; --- S1.a print-inorder ----------------------------------------------------
(test-case "print-inorder"
  (check-equal? (out `(print-inorder ',t1)) "(1 2 3 4 5 6 7)\n")
  (check-equal? (out `(print-inorder ',t2)) "(1 2 3)\n")
  (check-equal? (out `(print-inorder ',t3)) "(b a c)\n")
  (check-equal? (out `(print-inorder '())) "()\n"))

;; --- S1.b print-all-traversals ---------------------------------------------
(test-case "print-all-traversals"
  (check-equal? (out `(print-all-traversals ',t1))
                "(1 2 3 4 5 6 7)\n(4 2 1 3 6 5 7)\n(1 3 2 5 7 6 4)\n")
  (check-equal? (out `(print-all-traversals ',t2)) "(1 2 3)\n(1 2 3)\n(3 2 1)\n")
  (check-equal? (out `(print-all-traversals ',t3)) "(b a c)\n(a b c)\n(b c a)\n")
  (check-equal? (out `(print-all-traversals '())) "()\n()\n()\n"))

;; --- S1.c print-height-and-leaves ------------------------------------------
(test-case "print-height-and-leaves"
  (check-equal? (out `(print-height-and-leaves ',t1)) "(3 4)\n")
  (check-equal? (out `(print-height-and-leaves ',t2)) "(3 1)\n")
  (check-equal? (out `(print-height-and-leaves ',t3)) "(2 2)\n")
  (check-equal? (out `(print-height-and-leaves '())) "(0 0)\n"))

;; --- extra edge cases ------------------------------------------------------
(test-case "single node"
  (check-equal? (out `(print-all-traversals '(9 () ()))) "(9)\n(9)\n(9)\n")
  (check-equal? (out `(print-height-and-leaves '(9 () ()))) "(1 1)\n"))

(test-case "left-skewed tree"
  (define t '(3 (2 (1 () ()) ()) ()))
  (check-equal? (out `(print-all-traversals ',t)) "(1 2 3)\n(3 2 1)\n(1 2 3)\n")
  (check-equal? (out `(print-height-and-leaves ',t)) "(3 1)\n"))

(test-case "node with one child is not a leaf"
  (check-equal? (out `(print-height-and-leaves '(1 (2 () ()) ()))) "(2 1)\n"))

(test-case "helper lists"
  (check-equal? (eval `(inorder-list ',t1) mod-ns) '(1 2 3 4 5 6 7))
  (check-equal? (eval `(preorder-list ',t1) mod-ns) '(4 2 1 3 6 5 7))
  (check-equal? (eval `(postorder-list ',t1) mod-ns) '(1 3 2 5 7 6 4))
  (check-equal? (eval `(height '()) mod-ns) 0)
  (check-equal? (eval `(leaf-count '()) mod-ns) 0))

(test-case "deep tree (depth 10,000) does not fail"
  ;; right-skewed chain 1 -> 2 -> ... -> 10000
  (define deep
    (let loop ([i 10000] [t '()])
      (if (= i 0) t (loop (- i 1) (list i '() t)))))
  (check-equal? (length (eval `(inorder-list ',deep) mod-ns)) 10000)
  (check-equal? (eval `(height ',deep) mod-ns) 10000))

(displayln "test_q3: done")
