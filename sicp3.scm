;; -*- mode: scheme; fill-column: 75; comment-column: 50; coding: utf-8; -*-
;; TODO: DEADLOCK
;; TODO: 3.4
;; Chapter 3 of SICP
(use-modules (ice-9 format))
(use-modules (ice-9 q))
(use-modules (oop goops))

;; utilities
(define (inc n) (+ n 1))
(define (dec n) (- n 1))
(define (square n) (* x x))


;; Section 3.1


#| Exercise 3.1
An accumulator is a procedure that is called repeatedly with a single numeric
argument and accumulates its arguments into a sum. Each time it is called, it
returns the currently accumulated sum. Write a procedure make-accumulator that
generates accumulators, each maintaining an independent sum. The input to
make-accumulator should specify the initial value of the sum;

(define A (make-accumulator 5)) |#
(define (make-accumulator x)
  (lambda (n)
    (+ x n)))



#| Exercise 3.2
In software-testing applications, it is useful to be able to count
the number of times a given procedure is called during the course of a
computation. Write a procedure make-monitored that takes as input a procedure,
f, that itself takes one input. The result returned by make-monitored is a third
procedure, say mf, that keeps track of the number of times it has been called by
maintaining an internal counter. If the input to mf is the special symbol
how-many-calls?, then mf returns the value of the counter. If the input is the
special symbol reset-count, then mf resets the counter to zero. For any other
input, mf returns the result of calling f on that input and increments the
counter. For instance, we could make a monitored version of the sqrt procedure: |#
(define (make-monitored f)
  (define calls 0)
  (lambda (n)
    (if (eq? n 'how-many-calls?)
        calls
        (begin
          (set! calls (inc calls))
          (f n)))))




#| Exercise 3.3
Modify the make-account procedure so that it creates password-protected
accounts. That is, make-account should take a symbol as an additional argument,
as in

(define acc (make-account 100 'secret-password))
(define (zv-make-account acct# passwd)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance
                     (- balance amount))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (define (dispatch m)
    (cond ((eq? m 'withdraw) withdraw)
          ((eq? m 'deposit) deposit)
          (else (error "Unknown request:
                 MAKE-ACCOUNT" m))))
  dispatch)
|#


#| Exercise 3.5
Monte Carlo integration is a method of estimating definite integrals by means of
Monte Carlo simulation. Consider computing the area of a region of space
described by a predicate p ( x , y ) that is true for points ( x , y ) in the
region and #f for points not in the region. For example, the region contained
within a circle of radius 3 centered at (5, 7) is described by the predicate
that tests whether ( x − 5 ) 2 + ( y − 7 ) 2 ≤ 3 2 . To estimate the area of the
region described by such a predicate, begin by choosing a rectangle that
contains the region. For example, a rectangle with diagonally opposite corners
at (2, 4) and (8, 10) contains the circle above. The desired integral is the
area of that portion of the rectangle that lies in the region. We can estimate
the integral by picking, at random, points ( x , y ) that lie in the rectangle,
and testing p ( x , y ) for each point to determine whether the point lies in
the region. If we try this with many points, then the fraction of points that
fall in the region should give an estimate of the proportion of the rectangle
that lies in the region. Hence, multiplying this fraction by the area of the
entire rectangle should produce an estimate of the integral.

Implement Monte Carlo integration as a procedure estimate-integral that takes as
arguments a predicate p, upper and lower bounds x1, x2, y1, and y2 for the
rectangle, and the number of trials to perform in order to produce the estimate.
Your procedure should use the same monte-carlo procedure that was used above to
estimate π . Use your estimate-integral to produce an estimate of π by measuring
the area of a unit circle.

You will find it useful to have a procedure that returns a number chosen at
random from a given range. The following random-in-range procedure implements
this in terms of the random procedure used in 1.2.6, which returns a nonnegative
number less than its input.136 |#
(define (random-in-range low high)
  ;; had to write my own
  (+ low (random high)))

(define (estimate-integral p x1 x2 y1 y2 trials)
  (define width (abs (- x2 x1)))
  (define height (abs (- y2 y1)))
  (define area (* width height))
  (define (iter remaining passed)
    (let* ((x (random-in-range x1 x2))
           (y (random-in-range y1 y2))
           (is-contained? (p x y)))
      (cond ((= remaining 0) (/ passed trials))
            (is-contained? (iter (dec remaining)
                                 (inc passed)))
            (else
             (iter (dec remaining) passed)))))
  (* area
     (iter trials 0)))

(define (unit-circle-pred x y)
  (<= (+ (* x x) (* y y)) 1))


#| Exercise 3.6

It is useful to be able to reset a random-number generator to produce a sequence
starting from a given value. Design a new rand procedure that is called with an
argument that is either the symbol generate or the symbol reset and behaves as
follows: (rand 'generate) produces a new random number; ((rand 'reset)
⟨new-value⟩) resets the internal state variable to the designated ⟨new-value⟩.
Thus, by resetting the state, one can generate repeatable sequences. These are
very handy to have when testing and debugging programs that use random numbers. |#

;; This is what I assume he meant??
(define (rand command)
  (case command
    ('generate (random 10))
    (else (λ (new) (seed->random-state new)))))

;; Utilities
(define (count-pairs x)
  (if (not (pair? x))
      0
      (+ (count-pairs (car x))
         (count-pairs (cdr x))
         1)))

;; (define (append! x y)
;;   (set-cdr! (last-pair x) y)
;;   x)



#| Exercise 3.12: The following procedure for appending lists was introduced in 2.2.1:

(define (append x y)
  (if (null? x)
      y
      (cons (car x) (append (cdr x) y))))

Append forms a new list by successively consing the elements of x onto y. The
procedure append! is similar to append, but it is a mutator rather than a
constructor. It appends the lists by splicing them together, modifying the final
pair of x so that its cdr is now y. (It is an error to call append! with an
empty x.)
|#

(define (last-pair x)
  (if (null? (cdr x))
      x
      (last-pair (cdr x))))

(define x (list 'a 'b))
(define y (list 'c 'd))
(define z (append x y))

;; Exercise 3.13
;; What happens if we try to compute (last-pair z)?
(define (make-cycle x)
  (set-cdr! (last-pair x) x)
  x)

;;; Answer: An infinite loop occurs (a cycle in the linked list has been made)


#| Exercise 3.14: The following procedure is quite useful, although obscure:
|#

(define (mystery x)
  (define (loop x y)
    (if (null? x)
        y
        (let ((temp (cdr x)))
          (set-cdr! x y)
          (loop temp x))))
  (loop x '()))

#|
Loop uses the “temporary” variable temp to hold the old value of the cdr of x,
since the set-cdr! on the next line destroys the cdr. Explain what mystery does
in general. Suppose v is defined by (define v (list 'a 'b 'c 'd)). Draw the
box-and-pointer diagram that represents the list to which v is bound. Suppose
that we now evaluate (define w (mystery v)). Draw box-and-pointer diagrams that
show the structures v and w after evaluating this expression. What would be
printed as the values of v and w?
|#

#|
Answer:

Mystery reverses an array "in-place"
|#



#| Exercise 3.16
Ben Bitdiddle decides to write a procedure to count the number of pairs in any
list structure. “It’s easy,” he reasons. “The number of pairs in any structure
is the number in the car plus the number in the cdr plus one more to count the
current pair.” So Ben writes the following procedure:
|#

(define (count-pairs x)
  (if (not (pair? x))
      0
      (+ (count-pairs (car x))
         (count-pairs (cdr x))
         1)))

#|
Show that this procedure is not correct. In particular, draw box-and-pointer
diagrams representing list structures made up of exactly three pairs for which
Ben’s procedure would return 3; return 4; return 7; never return at all.
|#

(define count-three-pairs '(a b c))
(define count-four-pairs '(a b c))
(define count-seven-pairs '(a b c))
(set-car! (cdr count-four-pairs) (cdr (cdr count-four-pairs)))
(set-car! count-seven-pairs (cdr count-seven-pairs))

#|
Answer:
(count-pairs count-three-pairs) => 3
(count-pairs count-four-pairs)  => 4
(count-pairs count-seven-pairs) => 7
|#



#| Exercise 3.17

Devise a correct version of the count-pairs procedure of Exercise 3.16 that
returns the number of distinct pairs in any structure.

(Hint: Traverse the structure, maintaining an auxiliary data structure that is
       used to keep track of which pairs have already been counted.)
|#

(define (zv-count-pairs xs)
  (define counted '())
  (define (loop xs)
    (cond ((not (pair? xs)) 1)
          ((null? xs) 0)
          ((memq (car xs) counted) 0)
          (else
           (begin
             (set! counted (cons (car xs) counted))
             (+ (loop (car xs))
                (loop (cdr xs)))))))
  (loop xs))


#| Exercise 3.18
Write a procedure that examines a list and determines whether it contains a
cycle, that is, whether a program that tried to find the end of the list by
taking successive cdrs would go into an infinite loop. Exercise 3.13 constructed
such lists.
|#
(define (has-cycles? xs)
  (define visited '())
  (define (search ys)
    (cond ((null? ys) #f)
          ((memq (car ys) visited) #t)
          (else
           (begin
             (set! visited (cons (car ys) visited))
             (search (cdr ys))))))
  (search xs))



#| Exercise 3.19
Redo Exercise 3.18 using an algorithm that takes only a constant amount of
space. (This requires a very clever idea.)
|#
(define* (linear-cycle-search x1
                             #:optional (x2 (cdr x1)))
  (cond ((or (null? (cdr x1)) (null? (cdr x2))) #f)
        ((eq? x1 x2) #t)
        (else (linear-cycle-search (cdr x1) (cdr (cdr x2))))))


;; -- Section 3.3.2 - Queues -----------------------
;; ---( Utility Functions )--------------------------
(define (make-queue) (cons '() '()))

(define (front-ptr queue) (car queue))

(define (rear-ptr queue) (cdr queue))

(define (set-front-ptr! queue item)
  (set-car! queue item))

(define (set-rear-ptr! queue item)
  (set-cdr! queue item))

(define (empty-queue? queue)

  (null? (front-ptr queue)))
(define (front-queue queue)
  (if (empty-queue? queue)
      (error "FRONT called with an empty queue" queue)
      (car (front-ptr queue))))

(define (insert-queue! queue item)
  (let ((new-pair (cons item '())))
    (cond ((empty-queue? queue)
           (set-front-ptr! queue new-pair)
           (set-rear-ptr! queue new-pair)
           queue)
          (else (set-cdr! (rear-ptr queue) new-pair)
                (set-rear-ptr! queue new-pair)
                queue))))

(define (delete-queue! queue)
  (cond ((empty-queue? queue)
         (error "DELETE! called with an empty queue" queue))
        (else
         (set-front-ptr! queue (cdr (front-ptr queue)))
         queue)))

#| Exercise 3.21
Ben Bitdiddle decides to test the queue implementation described above. He types
in the procedures to the Lisp interpreter and proceeds to try them out:
|#

(define q1 (make-queue))

(insert-queue! q1 'a)
;; ((a) a)

(insert-queue! q1 'b)
;; ((a b) b)

(delete-queue! q1)
;; ((b) b)

(delete-queue! q1)
;; (() b)

#|
“It’s all wrong!” he complains. “The interpreter’s response shows that the last
item is inserted into the queue twice. And when I delete both items, the second
b is still there, so the queue isn’t empty, even though it’s supposed to be.”
Eva Lu Ator suggests that Ben has misunderstood what is happening. “It’s not
that the items are going into the queue twice,” she explains. “It’s just that
the standard Lisp printer doesn’t know how to make sense of the queue
representation. If you want to see the queue printed correctly, you’ll have to
define your own print procedure for queues.” Explain what Eva Lu is talking
about. In particular, show why Ben’s examples produce the printed results that
they do. Define a procedure print-queue that takes a queue as input and prints
the sequence of items in the queue.
|#
(define (print-queue qs)
  (format #t "~a~%" (car qs)))



#| Exercise 3.22
Instead of representing a queue as a pair of pointers, we can build a queue as a
procedure with local state. The local state will consist of pointers to the
beginning and the end of an ordinary list. Thus, the make-queue procedure will
have the form

(define (make-queue)
  (let ((front-ptr … )
        (rear-ptr … ))
    ⟨definitions of internal procedures⟩
    (define (dispatch m) …)
    dispatch))

Complete the definition of make-queue and provide implementations of the queue
operations using this representation.
|#
(define (make-curryq)
  (let ((front-ptr '())
        (rear-ptr '()))
    (define (set-fptr! item) (set! front-ptr item))
    (define (set-rptr! item) (set! rear-ptr item))
    (define (empty-curryq?)
      (null? front-ptr))
    (define (front-curryq)
      (if (empty-curryq?)
          (error "FRONT on empty queue")
          (car front-ptr)))
    (define (insert-curryq! item)
      (let ((new-pair (cons item '())))
        (cond [(empty-curryq?)
               (set-fptr! item)
               (set-rptr! item)]
              [else
               (set! rear-ptr new-pair)
               (set-rptr! new-pair)])))
    (define (print-queue)
      (format #t "~a~%" front-ptr))
    (define (dispatch m)
      (cond [(eq? m 'front-ptr) front-ptr]
            [(eq? m 'rear-ptr) rear-ptr]
            [(eq? m 'insert-queue!) insert-curryq!]
            [(eq? m 'print-queue) print-queue]))
    dispatch))


#| TODO: Exercise 3.23
A deque (“double-ended queue”) is a sequence in which items can be inserted and
deleted at either the front or the rear. Operations on deques are the
constructor make-deque, the predicate empty-deque?, selectors front-deque and
rear-deque, and mutators front-insert-deque!, rear-insert-deque!,
front-delete-deque!, rear-delete-deque!. Show how to represent deques using
pairs, and give implementations of the operations.151 All operations should be
accomplished in Θ(1) steps.
|#

;; -- 3.3.3 | Representing Tables  -------------------
;; --( Utility Functions )----------------------------
(define (lookup key table)
  (let ((record (assoc key (cdr table))))
    (if record
        (cdr record)
        #f)))

(define (assoc key records)
  (cond ((null? records) #f)
        ((equal? key (caar records))
         (car records))
        (else (assoc key (cdr records)))))

(define (insert! key value table)
  (let ((record (assoc key (cdr table))))
    (if record
        (set-cdr! record value)
        (set-cdr! table
                  (cons (cons key value)
                        (cdr table)))))
  'ok)

(define (make-table)
  (let ((local-table (list '*table*)))
    (define (lookup key-1 key-2)
      (let ((subtable
             (assoc key-1 (cdr local-table))))
        (if subtable
            (let ((record (assoc key-2 (cdr subtable))))
              (if record (cdr record) #f))
            #f)))
    (define (insert! key-1 key-2 value)
      (let ((subtable
             (assoc key-1 (cdr local-table))))
        (if subtable
            (let ((record (assoc key-2 (cdr subtable))))
              (if record
                  (set-cdr! record value)
                  (set-cdr! subtable
                            (cons (cons key-2 value)
                                  (cdr subtable)))))
            (set-cdr!
             local-table
             (cons (list key-1 (cons key-2 value))
                   (cdr local-table)))))
      'ok)
    (define (dispatch m)
      (cond ((eq? m 'lookup-proc) lookup)
            ((eq? m 'insert-proc!) insert!)
            (else (error "Unknown operation: TABLE" m))))
    dispatch))

(define operation-table (make-table))
(define get (operation-table 'lookup-proc))
(define put (operation-table 'insert-proc!))



;; -- 3.3.4 | Constraint Satisfaction ----------------
;; --( Utility Functions )----------------------------
(define-class <wire> ()
  (signal-value
   #:init-value 0
   #:setter set-signal!
   #:getter signal-value)

  (action-procedures #:init-form '()
                     #:accessor action-procedures
                     #:setter set-action-procedures))
(define (make-wire)
  (make <wire>))

(define-method (set-signal! (w <wire>) new-value)
    (let ([old-value (signal-value w)]
         [result (slot-set! w 'signal-value new-value)])
      (unless (equal? old-value new-value)
        (map (λ (x) (x)) (action-procedures w)))))

;; (define-generic add-action!)
(define-method (add-action! (w <wire>) proc)
  (set-action-procedures w (cons proc (action-procedures w)))
  (proc))

(define inverter-delay 2)
(define (inverter input output)
  (define (invert-input)
    (let ([new-value (logical-not (signal-value input))])
      (after-delay inverter-delay
                   (λ ()
                     (set-signal! output
                                       new-value)))))
  (add-action! input invert-input)
  'ok)

(define (logical-not s)
  (cond [0 1]
        [1 0]
        (else (error "Invalid signal"))))

(define and-gate-delay 3)

(define (and-gate a1 a2 output)
  (define (and-action-procedure)
    (let ((new-value
           (logand (signal-value a1)
                   (signal-value a2))))
      (after-delay
       and-gate-delay
       (λ ()
         (set-signal! output new-value)))))
  (add-action! a1 and-action-procedure)
  (add-action! a2 and-action-procedure)
  'ok)

(define (after-delay delay action)
  (add-to-agenda!
   (+ delay (current-time the-agenda))
   action
   the-agenda))

(define (propagate)
  (if (empty-agenda? the-agenda) 'done
      (let ([first-item (first-agenda-item the-agenda)])
        (first-item)
        (remove-first-agenda-item! the-agenda)
        (propagate))))



(define (make-time-segment time queue)
  (cons time queue))
(define (segment-time s) (car s))
(define (segment-queue s) (cdr s))
(define (make-agenda) (list 0))
(define (current-time agenda) (car agenda))
(define (set-current-time! agenda time)
  (set-car! agenda time))
(define (segments agenda) (cdr agenda))
(define (set-segments! agenda segments)
  (set-cdr! agenda segments))
(define (first-segment agenda)
  (car (segments agenda)))
(define (rest-segments agenda)
  (cdr (segments agenda)))
(define (empty-agenda? agenda)
  (null? (segments agenda)))

(define (add-to-agenda! time action agenda)
  (define (belongs-before? segments)
    (or (null? segments)
        (< time
           (segment-time (car segments)))))
  (define (make-new-time-segment time action)
    (let ((q (make-q)))
      (enq! q action)
      (make-time-segment time q)))
  (define (add-to-segments! segments)
    (if (= (segment-time (car segments)) time)
        (q-push! (segment-queue (car segments))
         action)
        (let ((rest (cdr segments)))
          (if (belongs-before? rest)
              (set-cdr! segments
               (cons (make-new-time-segment time action)
                     (cdr segments)))
              (add-to-segments! rest)))))
  (let ((segments (segments agenda)))
    (if (belongs-before? segments)
        (set-segments! agenda
         (cons (make-new-time-segment time action)
               segments))
        (add-to-segments! segments))))

(define (remove-first-agenda-item! agenda)
  (let ((q (segment-queue
            (first-segment agenda))))
    (deq! q)
    (if (q-empty? q)
        (set-segments!
         agenda
         (rest-segments agenda)))))

(define (first-agenda-item agenda)
  (if (empty-agenda? agenda)
      (error "Agenda is empty: FIRST-AGENDA-ITEM")
      (let ((first-seg
             (first-segment agenda)))
        (set-current-time!
         agenda
         (segment-time first-seg))
        (q-front
         (segment-queue first-seg)))))

(define the-agenda (make-agenda))


(define (half-adder a b s c)
  (let ((d (make-wire)) (e (make-wire)))
    (or-gate a b d)
    (and-gate a b c)
    (inverter c e)
    (and-gate d e s)
    'ok))

(define (full-adder a b c-in sum c-out)
  (let ((c1 (make-wire))
        (c2 (make-wire))
        (s  (make-wire)))
    (half-adder b c-in s c1)
    (half-adder a s sum c2)
    (or-gate c1 c2 c-out)
    'ok))

(define (zv-probe name wire)
  (add-action!
   wire
   (lambda ()
     (newline)
     (display name)
     (display " ")
     (display (current-time the-agenda))
     (display "  New-value = ")
     (display (signal-value wire))
     (display "\n"))))


(define input-1 (make-wire))
(define input-2 (make-wire))
(define sum (make-wire))
(define carry (make-wire))



#| Exercise 3.28
Define an or-gate as a primitive function box. Your or-gate constructor should
be similar to and-gate.
|#
(define or-gate-delay 5)
(define (or-gate a1 a2 output)
  (define (or-action-procedure)
    (let ((new-value
           (logior (signal-value a1)
                   (signal-value a2))))
      (after-delay
       or-gate-delay
       (λ ()
         (set-signal! output new-value)))))
  (add-action! a1 or-action-procedure)
  (add-action! a2 or-action-procedure)
  'ok)


#| Exercise 3.29
Another way to construct an or-gate is as a compound digital logic device, built
from and-gates and inverters. Define a procedure or-gate that accomplishes this.
What is the delay time of the or-gate in terms of and-gate-delay and
inverter-delay? |#

;; (!a1) && a2 is congruent to a1 || a2, it is as fast as (AND-DELAY + INVERTER_DELAY)


#| TODO: Exercise 3.30
Figure 3.27 shows a ripple-carry adder formed by stringing together n
full-adders. This is the simplest form of parallel adder for adding two n -bit
binary numbers. The inputs A 1 , A 2 , A 3 , …, A n and B 1 , B 2 , B 3 , …, B n
are the two binary numbers to be added (each A k and B k is a 0 or a 1). The
circuit generates S 1 , S 2 , S 3 , …, S n , the n bits of the sum, and C , the
carry from the addition. Write a procedure ripple-carry-adder that generates
this circuit. The procedure should take as arguments three lists of n wires
each—the A k , the B k , and the S k —and also another wire C . The major
drawback of the ripple-carry adder is the need to wait for the carry signals to
propagate. What is the delay needed to obtain the complete output from an n -bit
ripple-carry adder, expressed in terms of the delays for and-gates, or-gates,
and inverters?
|#


#| Exercise 3.31
The internal procedure `accept-action-procedure!' defined in make-wire specifies
that when a new action procedure is added to a wire, the procedure is
immediately run. Explain why this initialization is necessary. In particular,
trace through the half-adder example in the paragraphs above and say how the
system’s response would differ if we had defined accept-action-procedure! as

(define (accept-action-procedure! proc)
  (set! action-procedures
    (cons proc action-procedures)))
|#

#| Answer:
the signal value must be initialized or the entire system will run the action
procedures (no matter what has changed)
|#


#| TODO: Exercise 3.32
The procedures to be run during each time segment of the agenda are kept in a
queue. Thus, the procedures for each segment are called in the order in which
they were added to the agenda (first in, first out). Explain why this order must
be used. In particular, trace the behavior of an and-gate whose inputs change
from 0, 1 to 1, 0 in the same segment and say how the behavior would differ if
we stored a segment’s procedures in an ordinary list, adding and removing
procedures only at the front (last in, first out).
|#


;; ------- 3.3.5 - Propagation of Contraints --------
;; -----------( Utility Functions )------------------

;; ;; ;; macro to define the set-value terms
;; (define-syntax define-constraint-fns
;;   (syntax-rules (value c)
;;     ([_ elt ...]
;;      [begin
;;        (eval ;; (set-total c value) => (set-value! total value c)
;;         `(define elt
;;            (lambda (value c)
;;              (set-value! elt value c)))
;;         (interaction-environment)) ...])))

;; (define-constraint-fns set-total set-lhs set-rhs)


(define (for-each-except exception procedure list)
  (define (loop items)
    (cond ((null? items) 'done)
          ((equal? (car items) exception)
           (loop (cdr items)))
          (else (procedure (car items))
                (loop (cdr items)))))
  (loop list))

(define-class <connector> ()
  (value #:init-value #f
         #:accessor connector-value
         #:setter set-connector-value)

  (informant #:init-value #f
             #:accessor informant
             #:setter set-informant)

  (constraints #:accessor constraints
               #:setter set-constraints
               #:init-form '()))

(define (make-connector)
  (make <connector>))

(define-method (has-value? (connxn <connector>))
  (if (informant connxn) #t
      #f))

(define-method (set-value! (connxn <connector>) newval setter)
  ;; (format #t "\nhas-value: ~a\n" (not (has-value? connxn) ))
  (cond [(not (has-value? connxn))
         (set-connector-value  connxn newval)
         (set-informant        connxn setter)
         (for-each-except setter
                          process-new-value
                          (constraints connxn))]
        [(not (= (connector-value connxn) newval))
         (error "contradiction" `(,(connector-value connxn) ,newval))]
        [else 'ignored]))

(define-method (forget-value! (connxn <connector>) retractor)
  (if (eq? retractor (informant connxn))
      (begin (set-informant connxn #nil)
             (for-each-except retractor
                              process-forget-value
                              (constraints connxn)))))

(define (connect connxn new-constraint)
  (let ([constraints (constraints connxn)])
    (if (not (memq new-constraint constraints))
        (set-constraints connxn (cons new-constraint constraints))
        (if (has-value? connxn)
            (process-new-value new-constraint)))))

(define-class <constraint> ()
  (lhs #:getter lhs
       #:init-keyword #:lhs)
  (rhs #:getter rhs
       #:init-keyword #:rhs)
  (total #:getter total
         #:init-keyword #:total)
  (operator #:getter constraint-operator)
  (inverse-operator #:getter constraint-inv-operator))

(define-class <constant> ())

(define (constant value connxn)
  (let ([cs (make <constant>)])
    (connect connxn cs)
    (set-value! connxn value cs)
    cs))

(define-method (process-new-value (c <constant>)) (error "Unable to set new value for constant"))
(define-method (process-forget-value (c <constant>)) (error "Unable to forget value for constant"))

;; Multiplier constructs a product constraint among total connectors rhs, lhs and total
(define-class <multiplier> (<constraint>)
  (operator #:init-value * )
  (inverse-operator #:init-value / ))
(define (multiplier m1 m2 product)
  (let ((cs (make <multiplier> #:lhs m1 #:rhs m2 #:total product)))
    (connect m1 cs) (connect m2 cs) (connect product cs)
    cs))

;; Adder constructs an adder constraint among summand connectors (rhs and lhs)
(define-class <adder> (<constraint>)
  (operator #:init-value + )
  (inverse-operator #:init-value - ))
(define (adder a1 a2 sum)
  (let ((cs (make <adder> #:lhs a1 #:rhs a2 #:total sum)))
    (connect a1 cs) (connect a2 cs) (connect sum cs)
    cs))

;; Processed whenever a new connection exists
(define-method (process-new-value (c <constraint>))
  (let* ([lhs-conn (lhs c)]
         [rhs-conn (rhs c)]
         [total-conn (total c)]
         [has-total? (has-value? total-conn)]
         [has-lhs? (has-value? lhs-conn)]
         [has-rhs? (has-value? rhs-conn)])

    ;; (format #t "r:~a l:~a t:~a\n" has-rhs? has-lhs? has-total?)
    ;; (format #t "and lt ~a\n" (and has-lhs? has-total?))

    ;; Determine what values *are* known and set the appropriate connector.
    (cond [(and has-lhs? has-rhs?)
            (set-value! total-conn
                        ((constraint-operator c)
                         (connector-value lhs-conn)
                         (connector-value rhs-conn))
                        c)]

          [(and has-lhs? has-total?)
           (set-value! rhs-conn
                       ((constraint-inv-operator c)
                        (connector-value total-conn)
                        (connector-value lhs-conn))
                       c)]

          [(and has-rhs? has-total?)
           (set-value! lhs-conn
                       ((constraint-inv-operator c)
                        (connector-value total-conn)
                        (connector-value rhs-conn))
                       c)])))

;; This is a specialized implementation for multiplication.
(define-method (process-new-value (c <multiplier>))
  ;; If either the lhs or rhs is 0, the value is 0
  (let ([lhs-connector (lhs c)]
        [rhs-connector (rhs c)])
    (if (or (and
             (has-value? lhs-connector)
             (= (connector-value lhs-connector) 0))
            (and
             (has-value? rhs-connector)
             (= (connector-value rhs-connector) 0)))
        ;; true: We can safely set to 0
        (set-value! (total c) 0 c)
        ;; false: Otherwise proceed to the next method
        (next-method))))

(define-method (process-forget-value (c <constraint>))
  (forget-value! (rhs c) c)
  (forget-value! (lhs c) c)
  (forget-value! (total c) c)
  (process-new-value c))

;; a probe is a special connector that prints a message about the setting or unsetting of the designated connector
(define-class <probe> (<constraint>)
  (name #:getter name
        #:setter set-name
        #:init-keyword #:name)
  (connector #:getter connector
             #:setter set-connector
             #:init-keyword #:connector))
(define (probe name connector)
  (let ((cs (make <probe> #:name name #:connector connector)))
    (connect connector cs) cs))

;; Probe internal methods
(define-method (print-probe (c <probe>) pval) (format #t "~%Probe: ~a = ~a" (name c) pval))
(define-method (process-new-value (c <probe>)) (print-probe c (connector-value (connector c))))
(define-method (process-forget-value (c <probe>)) (print-probe c "?"))


;;; driver fns
;; Function tha
(define-syntax with-connectors
  (syntax-rules ()
    ([with-connectors () form . forms]
     [begin form . forms])
    ([with-connectors (name . more) form . forms]
     (let ((name (make-connector)))
       (with-connectors more form . forms)))))

(define (celsius-fahrenheit-converter c f)
  (with-connectors (u v w x y)
                   (multiplier c w u)
                   (multiplier v x u)
                   (adder v y f)
                   (constant 9 w)
                   (constant 5 x)
                   (constant 32 y)
                   'ok))

;;c
(define c (make-connector))
(define f (make-connector))
(celsius-fahrenheit-converter c f)

(probe "celsius temp" c)
(probe "Fahrenheit temp" f)


#| Exercise 3.33
Using primitive multiplier, adder, and constant constraints, define a procedure
averager that takes three connectors a, b, and c as inputs and establishes the
constraint that the value of c is the average of the values of a and b. |#
(define (averager a b c)
  (with-connectors (half sum)
                   (constant 0.5 half)
                   (adder a b sum)
                   (multiplier half sum c)
                   'ok))


#| Exercise 3.34
Louis Reasoner wants to build a squarer, a constraint device with two terminals
such that the value of connector b on the second terminal will always be the
square of the value a on the first terminal. He proposes the following simple
device made from a multiplier:

  (define (squarer a b) (multiplier a a b))

There is a serious flaw in this idea. Explain.
|#
;; Answer: The value of `a' is not "duplicated" across -- so `process-new-value' only
;; reads either `rhs' or `lhs''s value


#| Exercise 3.35
Ben Bitdiddle tells Louis that one way to avoid the trouble in
Exercise 3.34 is to define a squarer as a new primitive constraint. Fill in the
missing portions in Ben’s outline for a procedure to implement such a
constraint:

(define (squarer a b)
  (define (process-new-value)
    (if (has-value? b)
        (if (< (get-value b) 0)
            (error "square less than 0:
                    SQUARER"
                   (get-value b))
            ⟨alternative1⟩)
        ⟨alternative2⟩))
  (define (process-forget-value) ⟨body1⟩)
  (define (me request) ⟨body2⟩)
  ⟨rest of definition⟩
  me)
|#

(define-class <squarer> (<constraint>)
  ;; in squarer, there is essentially only one value
  (rhs #:allocation #:virtual
       #:slot-ref (lambda (o) (slot-ref o 'lhs))
       #:slot-set! (lambda (o s) (slot-set! o 'lhs s)))
  ;; strictly speaking these are not nessasary, as they are defined directly in
  ;; `process-new-value', they are kept for posteriety.
  (operator #:init-value square)
  (inverse-operator #:init-value sqrt))

(define-method (process-new-value (c <squarer>))
  (let* ([lhs-conn (lhs c)]
         [total-conn (total c)]
         [has-total? (has-value? total-conn)]
         [has-lhs? (has-value? lhs-conn)])
    ;; Determine what values *are* known and set the appropriate connector.
    (cond
     ;; (lhs < 0) => error
     [(and (has-lhs?
            (< (connector-value lhs-conn) 0)))
      (error "square less than 0: SQUARER" (connector-value lhs-conn))]

     ;; lhs = √total
     [has-total?
      (set-value! lhs-conn (sqrt (connector-value total-conn)) c)]

     ;; total = lh²
     [has-lhs?
      (set-value! total-conn (square (connector-value lhs-conn)) c)])))

(define-method (process-forget-value (c <squarer>))
  (forget-value! (lhs c) c)
  (forget-value! (total c) c)
  (process-new-value c))


#| Exercise 3.36 WONTFIX
Suppose we evaluate the following sequence of expressions in the global
environment:

  (define a (make-connector)) (define b (make-connector)) (set-value! a 10 'user)

At some time during evaluation of the set-value!, the following expression from
the connector’s local procedure is evaluated:

  (for-each-except setter inform-about-value constraints)

Draw an environment diagram showing the environment in which the above
expression is evaluated. |#



#| Exercise 3.37
The celsius-fahrenheit-converter procedure is cumbersome when compared with a
more expression-oriented style of definition, such as

(define (celsius-fahrenheit-converter x)
  (c+ (c* (c/ (cv 9) (cv 5))
          x)
      (cv 32)))

(define C (make-connector))
(define F (celsius-fahrenheit-converter C))

Here c+, c*, etc. are the “constraint” versions of the arithmetic operations.
For example, c+ takes two connectors as arguments and returns a connector that
is related to these by an adder constraint:

(define (c+ x y)
  (let ((z (make-connector)))
    (adder x y z)
    z))

Define analogous procedures c-, c*, c/, and cv (constant value) that enable us
to define compound constraints as in the converter example above.
|#
(define (c+ augend addend)
  (with-connectors (sum)
                   (adder augend addend sum)
                   sum))

(define (c- minuend subtrahend)
  (with-connectors (difference)
                   (adder difference subtrahend minuend)
                   difference))

(define (c* multiplicand m2)
  (with-connectors (product)
                   (multiplier multiplicand  m2 product)
                   product))

(define (c/ dividend divisor)
  (with-connectors (quotient)
                   (multiplier quotient divisor dividend)
                   quotient))
(define (cv value)
  (with-connectors (result)
                   (constant value result)
                   result))


#| --------------------------------------------------
                  Section 3.4
  ------------------------------------------------- |#
;; (use-modules (ice-9 threads))
(define (parallel-execute . thunks)
  (for-each call-with-new-thread thunks))

(define x 10)
(define xsq (lambda ()
              (let ([y x])
                (set! x (* y 2)))))

(define xadd (lambda ()
               (sleep 1)
               (format #t "running")
               (let ([y x])
                 (set! x (+ y 1)))))

(define (make-serializer)
  (let ((mutex (make-mutex)))
    (λ (fn)
      (λ args
        (with-mutex mutex
          (apply fn args))))))

(define s (make-serializer))

#| Exercise 3.38
Suppose that Peter, Paul, and Mary share a joint bank account that initially
contains $100. Concurrently, Peter deposits $10, Paul withdraws $20, and Mary
withdraws half the money in the account, by executing the following commands:

  Peter: (set! balance (+ balance 10))
  Paul:  (set! balance (- balance 20))
  Mary:  (set! balance (- balance (/ balance 2)))

1.  List all the different possible values for balance after these three
    transactions have been completed, assuming that the banking system forces the
    three processes to run sequentially in some order.

2.  What are some other values that could be produced if the system allows the
    processes to be interleaved? Draw timing diagrams like the one in Figure 3.29 to
    explain how these values can occur.
|#

#| Answer (1):
  Peter->Paul->Mary: (calc-eval "((100+10)-20)/2")       => 45
  Peter->Mary->Paul: (calc-eval "((100+10)/2)-20")       => 35
  Mary->Paul->Peter: (calc-eval "((100 / 2) - 20) + 20") => 50
  Mary->Peter->Paul: (calc-eval "((100 / 2) + 10) - 20") => 40
  Paul->Peter->Mary: (calc-eval "((100 - 20) + 10) / 2") => 45
  Paul->Mary->Peter: (calc-eval "((100 - 20) / 2) + 10") => 50
|#




#| Exercise 3.39
Which of the five possibilities in the parallel execution shown above remain if
we instead serialize execution as follows:

(define x 10)
(define s (make-serializer))
(parallel-execute
 (lambda ()
   (set! x ((s (lambda () (* x x))))))
 (s (lambda () (set! x (+ x 1)))))
|#

;; ANSWER: 101, 100, 121



#| Exercise 3.40
Give all possible values of x that can result from executing

(define x 10)
(parallel-execute
 (lambda () (set! x (* x x)))
 (lambda () (set! x (* x x x))))

Which of these possibilities remain if we instead use serialized procedures:

(define x 10)
(define s (make-serializer))
(parallel-execute
 (s (lambda () (set! x (* x x))))
 (s (lambda () (set! x (* x x x)))))
|#

;; Answer: x*6 (multiplication is commutative)



#| Exercise 3.41
Ben Bitdiddle worries that it would be better to implement the bank account as
follows (where the commented line has been changed):

(define (make-account balance)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin
          (set! balance
                (- balance amount))
          balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (let ((protected (make-serializer)))
    (define (dispatch m)
      (cond ((eq? m 'withdraw)
             (protected withdraw))
            ((eq? m 'deposit)
             (protected deposit))
            ((eq? m 'balance)
             ((protected
                (lambda ()
                  balance)))) ; serialized
            (else
             (error
              "Unknown request:
               MAKE-ACCOUNT"
              m))))
    dispatch))

because allowing unserialized access to the bank balance can result in anomalous
behavior. Do you agree? Is there any scenario that demonstrates Ben’s concern?
|#

;; First off, this question is phrased in a really shitty way. Second off, no
;; *BALANCE* is safe. the other functions are *UNSAFE*



#| Exercise 3.42
Ben Bitdiddle suggests that it’s a waste of time to create a new serialized
procedure in response to every withdraw and deposit message. He says that
make-account could be changed so that the calls to protected are done outside
the dispatch procedure. That is, an account would return the same serialized
procedure (which was created at the same time as the account) each time it is
asked for a withdrawal procedure.

(define (make-account balance)
  (define (withdraw amount)
    (if (>= balance amount)
        (begin (set! balance
                     (- balance amount))
               balance)
        "Insufficient funds"))
  (define (deposit amount)
    (set! balance (+ balance amount))
    balance)
  (let ((protected (make-serializer)))
    (let ((protected-withdraw
           (protected withdraw))
          (protected-deposit
           (protected deposit)))
      (define (dispatch m)
        (cond ((eq? m 'withdraw)
               protected-withdraw)
              ((eq? m 'deposit)
               protected-deposit)
              ((eq? m 'balance)
               balance)
              (else
               (error "Unknown request:
                       MAKE-ACCOUNT"
                      m))))
      dispatch)))
|#

;; This is fine


#| Exercise 3.47
A semaphore (of size n ) is a generalization of a mutex. Like a mutex, a
semaphore supports acquire and release operations, but it is more general in
that up to n processes can acquire it concurrently. Additional processes that
attempt to acquire the semaphore must wait for release operations. Give
implementations of semaphores

1. In terms of mutexes
2. In terms of atomic test-and-set! operations.
|#

;; ok, this is really irritating me.
(define (zv-semaphore n)
  (define current 0)
  (define mutex (make-mutex))
  (define (acquire)
    (if (or (mutex-locked? mutex) (>= current n)) #f
        (begin
          (monitor
           (set! current (+ current 1)))
          (if (>= current n)
              (lock-mutex mutex)))))
  (define (release)
    (if (= n 0) (error "called on 0 semaphore")
        (begin
          (if (mutex-locked?)
              (unlock-mutex mutex))
          (set! current (- current 1))))))


