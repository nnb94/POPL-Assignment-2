#lang racket/base

;; S1: Binary tree traversals (CS F301 Assignment 2, group 15)
;; A binary tree is either () or a three-element list (value left right).
;; Subtrees are always visited left first, then right.
;; No append is used: every traversal walks the tree right-to-left and
;; conses values onto an accumulator, so the finished list comes out in order.

;; (inorder-acc t acc) -> the inorder values of t, followed by acc.
;; Reading: inorder of () is acc; inorder of (v l r) is
;; inorder of l, in front of v, in front of (inorder of r followed by acc).
(define (inorder-acc t acc)
  (if (null? t)
      acc
      (inorder-acc (cadr t)
                   (cons (car t) (inorder-acc (caddr t) acc)))))

;; (preorder-acc t acc) -> the preorder values of t, followed by acc.
;; Reading: preorder of () is acc; preorder of (v l r) is
;; v, in front of preorder of l, in front of (preorder of r followed by acc).
(define (preorder-acc t acc)
  (if (null? t)
      acc
      (cons (car t)
            (preorder-acc (cadr t) (preorder-acc (caddr t) acc)))))

;; (postorder-acc t acc) -> the postorder values of t, followed by acc.
;; Reading: postorder of () is acc; postorder of (v l r) is
;; postorder of l, in front of postorder of r, in front of (v followed by acc).
(define (postorder-acc t acc)
  (if (null? t)
      acc
      (postorder-acc (cadr t)
                     (postorder-acc (caddr t) (cons (car t) acc)))))

;; (inorder-list t) -> list of values of t in inorder (left, node, right).
(define (inorder-list t) (inorder-acc t '()))

;; (preorder-list t) -> list of values of t in preorder (node, left, right).
(define (preorder-list t) (preorder-acc t '()))

;; (postorder-list t) -> list of values of t in postorder (left, right, node).
(define (postorder-list t) (postorder-acc t '()))

;; S1.a (print-inorder tree): prints the inorder list of tree on one line.
(define (print-inorder tree)
  (display (inorder-list tree))
  (newline))

;; S1.b (print-all-traversals tree): prints the inorder, preorder and
;; postorder lists of tree, one per line, in that order.
(define (print-all-traversals tree)
  (display (inorder-list tree))
  (newline)
  (display (preorder-list tree))
  (newline)
  (display (postorder-list tree))
  (newline))
