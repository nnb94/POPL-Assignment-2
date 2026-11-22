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

;; (height t) -> height of t.
;; Reading: the height of () is 0; the height of (v l r) is
;; 1 plus the larger of the heights of l and r. (A single node has height 1.)
(define (height t)
  (if (null? t)
      0
      (+ 1 (max (height (cadr t)) (height (caddr t))))))

;; (leaf? t) -> #t when t is a node whose left and right subtrees are both ().
(define (leaf? t)
  (and (pair? t) (null? (cadr t)) (null? (caddr t))))

;; (leaf-count-acc t acc) -> number of leaves in t, plus acc.
;; Reading: () adds nothing; a leaf adds 1; any other node adds the leaves
;; of its left subtree and then of its right subtree.
(define (leaf-count-acc t acc)
  (cond ((null? t) acc)
        ((leaf? t) (+ acc 1))
        (else (leaf-count-acc (cadr t) (leaf-count-acc (caddr t) acc)))))

;; (leaf-count t) -> number of leaves in t. The empty tree has 0 leaves.
(define (leaf-count t) (leaf-count-acc t 0))

;; S1.c (print-height-and-leaves tree): prints the list (height leaf-count).
(define (print-height-and-leaves tree)
  (display (list (height tree) (leaf-count tree)))
  (newline))
