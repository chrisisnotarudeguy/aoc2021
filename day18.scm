(define (ceil-div x y) (quotient (- (+ x y) 1) y))
(define (split n) (list (quotient n 2) (ceil-div n 2)))

(define (try-split t)
  (define got-split #f)
  (define (split-loop t)
    (if (number? t)
      (if (and (not got-split) (>= t 10))
        (begin (set! got-split #t) (split t))
        t)
      (list (split-loop (car t)) (split-loop (cadr t)))))
  (list (split-loop t) got-split))

(define (update-lrmost tree n which)
  (cond ((number? tree) (+ tree n))
        ((eq? which 'left) (list (update-lrmost (car tree) n which) (cadr tree)))
        (else              (list (car tree) (update-lrmost (cadr tree) n which)))))

(define (exploded? t) (and (list? t) (eq? (cadr t) 'exploded)))

(define (explode tree)
  (define exploded #f)
  (define exploding-pair '())
  (define (update node i)
    (cond ((eq? node 'exploded) 0)
          ((= (list-ref exploding-pair i) -1) node)
          (else (let ((res (update-lrmost node (list-ref exploding-pair i) (if (= i 0) 'right 'left))))
            (set! exploding-pair (list-set exploding-pair i -1))
            res))))
  (define (visit tree [nest 0])
    (cond ((number? tree) tree)
          ((and (not exploded) (>= nest 4) (number? (car tree)) (number? (cadr tree)))
           (begin (set! exploded #t)
                  (set! exploding-pair tree)
                  (list 0 'exploded)))
          (else
            (let* ([left  (visit (car  tree) (add1 nest))]
                   [right (visit (cadr tree) (add1 nest))])
              (cond ((exploded? left ) (list (list (car left) (update right 1)) 'exploded))
                    ((exploded? right) (list (list (update left 0) (car right))  'exploded))
                    (else (list left right)))))))
  (visit tree))

(define (snail-to-list str)
  (let* ([tmp1 (string-replace str "[" "(")]
         [tmp2 (string-replace str "]" ")")]
         [tmp3 (string-replace str "," " ")])
    (read (open-input-string tmp3))))

(define (snail-reduce x)
  (let ([explode-result (explode x)])
    (if (not (exploded? explode-result))
      (let ([split-result (try-split x)])
        (if (not (cadr split-result))
          x
          (snail-reduce (car split-result))))
      (snail-reduce (car explode-result)))))

(define (snail-add a b) (list a b))

(define (magnitud x)
  (if (number? x)
    x
    (+ (* 3 (magnitud (car x))) (* 2 (magnitud (cadr x))))))

(define (sol1 name)
  (define input (map snail-to-list (file->lines name)))
  (define result (foldl (lambda (x r) (snail-reduce (snail-add r x))) (car input) (cdr input)))
  (displayln (magnitud result)))

(define (sol2 name)
  (define input (map snail-to-list (file->lines name)))
  (define perms (filter (lambda (x) (not (equal? (car x) (cadr x)))) (cartesian-product input input)))
  (define results (map (lambda (x) (magnitud (snail-reduce (snail-add (car x) (cadr x))))) perms))
  (displayln (apply max results)))

(sol1 "input18-1.txt")
(sol1 "input18-2.txt")
(sol2 "input18-1.txt")
(sol2 "input18-2.txt")
