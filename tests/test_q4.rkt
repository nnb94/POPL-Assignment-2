#lang racket/base
;; Tests for S2 (code/15_q4.rkt).
;; Run from anywhere:  racket tests/test_q4.rkt
;; Prints nothing but rackunit failures; ends with a summary line.
;;
;; The solution file may not use provide, so instead of require we load it
;; and evaluate calls inside its module namespace, the same way the grader's
;; appended calls see its definitions. One test also runs the file the way
;; the grader does: a copy with (print-insert-result) appended, fed on stdin.
;; This test file itself is not bound by the S2 built-in restrictions.

(require rackunit racket/port racket/runtime-path racket/list
         racket/file racket/system)

(define-runtime-path solution "../code/15_q4.rkt")

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

;; (call expr) -> the value of expr, evaluated inside the solution module.
(define (call expr) (eval expr mod-ns))

;; (run-stdin input) -> what (print-insert-result) prints when input is stdin.
(define (run-stdin input)
  (with-input-from-string input
    (lambda () (out '(print-insert-result)))))

;; The forms of the solution file, read as data (the #lang line is skipped).
(define forms
  (with-input-from-file solution
    (lambda ()
      (read-line)
      (let loop ([acc '()])
        (define x (read))
        (if (eof-object? x) (reverse acc) (loop (cons x acc)))))))

;; --- file hygiene -----------------------------------------------------------
(test-case "loading the file prints nothing"
  (check-equal? loading-output ""))

(test-case "every top-level form is a define"
  (check-true (andmap (lambda (f) (and (pair? f) (eq? (car f) 'define))) forms)))

(test-case "exactly one definition of insert-if-short, and it uses make-inserter"
  (define defs
    (filter (lambda (f) (and (pair? (cadr f)) (eq? (car (cadr f)) 'insert-if-short)))
            forms))
  (check-equal? (length defs) 1)
  (check-not-false (memq 'make-inserter (flatten defs))))

(test-case "solution uses only allowed built-ins (S2 also allows read)"
  (define allowed
    '(define lambda let let* letrec if cond else and or not begin quote
      cons car cdr list null? pair? eq? assq assoc + - * < > <= >= = max
      display newline read))
  (define (cxr-ok? s)
    (regexp-match? #rx"^c[ad][ad]?[ad]?[ad]?r$" (symbol->string s)))
  ;; every name this file binds: defined names and their parameters, lambda
  ;; parameters, let/let*/letrec variables and named-let names
  (define (binders x)
    (cond
      [(not (pair? x)) '()]
      [else
       (append
        (case (car x)
          [(define) (if (pair? (cadr x)) (flatten (cadr x)) (list (cadr x)))]
          [(lambda) (flatten (cadr x))]
          [(let let* letrec)
           (if (symbol? (cadr x))
               (cons (cadr x) (map car (caddr x)))
               (map car (cadr x)))]
          [else '()])
        (append-map binders (filter pair? x)))]))
  (define ok (append allowed (append-map binders forms)))
  (define bad
    (remove-duplicates
     (filter (lambda (s) (and (symbol? s) (not (memq s ok)) (not (cxr-ok? s))))
             (flatten forms))))
  (check-equal? bad '() (format "forbidden identifiers: ~a" bad)))

;; --- S2.a print-insert-result: the four examples of the spec ---------------
(test-case "spec examples through stdin"
  (check-equal? (run-stdin "42 ((1 2) (3 4 5) (6) ()) 3")
                "((42 1 2) (3 4 5) (42 6) (42))\n")
  (check-equal? (run-stdin "0 (((1) 2) (3) ((4 5 6) ())) 3")
                "((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))\n")
  (check-equal? (run-stdin "7 () 3") "(7)\n")
  (check-equal? (run-stdin "7 () 0") "()\n"))

(test-case "input may be spread over several lines"
  ;; the top-level list has length 2 < 3, so it gets 42 too
  (check-equal? (run-stdin "42\n((1 2)\n (3 4 5))\n3\n") "(42 (42 1 2) (3 4 5))\n"))

(test-case "symbols as x and as elements"
  (check-equal? (run-stdin "a (b (c d) e) 2") "(b (c d) e)\n")
  (check-equal? (run-stdin "x (a (b) ((c))) 2") "(a (x b) (x (x c)))\n"))

(test-case "grader-style run: file + appended call, input on stdin"
  (define tmp (make-temporary-file "s2-~a.rkt"))
  (call-with-output-file tmp #:exists 'truncate
    (lambda (o)
      (write-string (file->string solution) o)
      (write-string "\n(print-insert-result)\n" o)))
  (define racket-exe (find-system-path 'exec-file))
  (define result
    (with-output-to-string
      (lambda ()
        (parameterize ([current-input-port
                        (open-input-string "42 ((1 2) (3 4 5) (6) ()) 3")])
          (system* (find-executable-path racket-exe) (path->string tmp))))))
  (delete-file tmp)
  (check-equal? result "((42 1 2) (3 4 5) (42 6) (42))\n"))

;; --- S2.b helpers ----------------------------------------------------------
(test-case "my-length"
  (check-equal? (call '(my-length '())) 0)
  (check-equal? (call '(my-length '(1 (2 3) () 4))) 4))

(test-case "my-reverse"
  (check-equal? (call '(my-reverse '())) '())
  (check-equal? (call '(my-reverse '(1 (2 3) 4))) '(4 (2 3) 1)))

(test-case "my-map keeps order"
  (check-equal? (call '(my-map (lambda (v) (* v 10)) '(1 2 3))) '(10 20 30))
  (check-equal? (call '(my-map (lambda (v) v) '())) '()))

;; --- S2.b insert-if-short: length rules and edge cases --------------------
(test-case "length is measured on the original list"
  ;; (1 2) has length 2 < 3 and gets x; after insertion it would be 3,
  ;; which must not matter
  (check-equal? (call '(insert-if-short 'x '(1 2) 3)) '(x 1 2))
  ;; boundary: length = n is not short
  (check-equal? (call '(insert-if-short 'x '(1 2 3) 3)) '(1 2 3)))

(test-case "top-level list is treated like every other list"
  (check-equal? (call '(insert-if-short 'x '(1) 2)) '(x 1))
  (check-equal? (call '(insert-if-short 'x '((1)) 2)) '(x (x 1))))

(test-case "empty lists are not special"
  (check-equal? (call '(insert-if-short 'x '() 1)) '(x))
  (check-equal? (call '(insert-if-short 'x '(() ()) 1)) '((x) (x)))
  ;; top level has length 2 (not < 2); (()) has length 1; () has length 0
  (check-equal? (call '(insert-if-short 'x '(() (())) 2))
                '((x) (x (x))))
  (check-equal? (call '(insert-if-short 'x '(() (())) 3))
                '(x (x) (x (x)))))

(test-case "n = 0 never inserts"
  (check-equal? (call '(insert-if-short 'x '(() (1) ((2))) 0)) '(() (1) ((2)))))

(test-case "nested symbols"
  (check-equal? (call '(insert-if-short 'x '(a (b) ((c))) 2))
                '(a (x b) (x (x c)))))

;; --- S2.c make-inserter with other length tests ---------------------------
(test-case "make-inserter with an equality test"
  (check-equal? (call '((make-inserter 'z (lambda (len) (= len 2)))
                        '(1 (2 3) (4 (5 6) 7) ())))
                '(1 (z 2 3) (4 (z 5 6) 7) ())))

(test-case "make-inserter with a test that is always true / never true"
  (check-equal? (call '((make-inserter 'z (lambda (len) #t)) '(1 (2) ())))
                '(z 1 (z 2) (z)))
  (check-equal? (call '((make-inserter 'z (lambda (len) #f)) '(1 (2) ())))
                '(1 (2) ())))

;; --- hidden-test sizes: depth 100 and 10,000 elements ----------------------
;; (nest k) -> (((...(a)...))) with k levels of parentheses
(define (nest k) (if (= k 1) '(a) (list (nest (- k 1)))))
;; (nest-x k) -> the same tree with x at the front of every list
(define (nest-x k) (if (= k 1) '(x a) (list 'x (nest-x (- k 1)))))

(test-case "nesting depth 100"
  (check-equal? (call `(insert-if-short 'x ',(nest 100) 2)) (nest-x 100))
  (check-equal? (call `(insert-if-short 'x ',(nest 100) 1)) (nest 100)))

(test-case "nesting depth 10,000 does not fail"
  (check-equal? (call `(insert-if-short 'x ',(nest 10000) 2)) (nest-x 10000)))

(test-case "10,000 top-level elements"
  (define big (range 1 10001))
  (check-equal? (call `(insert-if-short 'x ',big 10001)) (cons 'x big))
  (check-equal? (call `(insert-if-short 'x ',big 10000)) big)
  (check-equal? (call `(my-length ',big)) 10000))

(test-case "10,000 empty sublists"
  (define big (make-list 10000 '()))
  (check-equal? (call `(insert-if-short 'x ',big 1)) (make-list 10000 '(x))))

(test-case "1,000,000 elements (well past the hidden test size)"
  (define huge (range 1000000))
  (check-equal? (length (call `(insert-if-short 'x ',huge 5))) 1000000))

(test-case "10,000 elements through stdin"
  (define big (range 1 10001))
  (check-equal? (run-stdin (format "x ~a 10001" big))
                (format "~a\n" (cons 'x big))))

(displayln "test_q4: done")
