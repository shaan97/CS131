#lang scheme

(define (null-ld? obj) (and (pair? obj) eq? (car obj) (cdr obj)))

(define (listdiff? obj) 
	(cond
		[(not(pair? obj)) #f]
		[(eq? (car obj) (cdr obj)) #t]
		[(not(pair? (car obj))) #f]
		[else (listdiff? (cons (cdar obj) (cdr obj)))])
)

(define (cons-ld obj listdiff)
	(cons (cons obj (car listdiff)) (cdr listdiff)) 
)

(define (car-ld listdiff)
	(caar listdiff)
)

(define (cdr-ld listdiff)
	(cons (cdar listdiff) (cdr listdiff))
)

(define (listdiff obj . args)
	(cons (cons obj args) '())
)

(define (length-ld listdiff)
	(let len ((listdiff listdiff) (count 0))
		(cond
			[(null-ld? listdiff) count]
			[else (len (cdr-ld listdiff) (+ count 1))]
		)
	)
)

(define (append-ld listdiff . args)
	(if (null? args) listdiff
		(cons (append (take (car listdiff) (length-ld listdiff)) (car (apply append-ld args))) (cdr (apply append-ld args)))
	)
)

(define (list-tail-ld listdiff k)
	(cond
		[(= k 0) listdiff]
		[else (list-tail-ld (cdr-ld listdiff) (- k 1))]
	)
)

(define (list->listdiff list)
	(listdiff list)
)

(define (listdiff->list listdiff)
	(take (car listdiff) (length-ld listdiff))
)

(define (expr-returning listdiff) 
	`(list ',(listdiff->list listdiff))
)