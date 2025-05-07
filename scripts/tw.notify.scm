#!/usr/bin/env guile
!#

(use-modules (json)
             (ice-9 popen)
             (ice-9 match)
             (srfi srfi-43) ; Vector
             (srfi srfi-19)) ; Date to string

;; === json model ===

(define-json-type <task>
  (id)
  (description)
  (due)
  (project)
  (status)
  (urgency))

;; === constant ===

(define +iso-8601+ "~Y~m~dT~H~M~S~z")

;; === markup ===

(define (i s) (string-append "<i>" s "</i>"))
(define (b s) (string-append "<b>" s "</b>"))
(define (u s) (string-append "<u>" s "</u>"))

;; === tasks importer ===

(define (tasks-due-in time)
  (let* ([tasks-export (string-append "task due.before:now+" time " export")]
         [port (open-input-pipe tasks-export)]
         [tasks (vector-map (λ (i s) (scm->task s)) (json->scm port))])
    (close-port port)
    tasks))

;; === helper ===

(define (urgency-level urg)
  (cond [(< urg 0) "low"]
        [(> urg 10) "critical"]
        [else "normal"]))

(define (set-duration-time time)
  (make-time time-duration (time-nanosecond time) (time-second time)))

(define (due-delta task)
 (let ([now-time-as-duration (set-duration-time (current-time time-utc))]
       [due-date (string->date (task-due task) +iso-8601+)])
   (time-utc->date (subtract-duration (date->time-utc due-date)
                                      now-time-as-duration) 0)))

;; === notifier ===

(define (notify-task-due _idx task)
  (let* ([dd (due-delta task)]
         [title (string-append "Project " (task-project task) " has a task due soon!")]
         [content (string-append (i (task-description task)) "\n\n"
                                 "From now: "
                                 (b (date->string dd "~Hh ~Mmin"))
                                 " left" "\n\n"
                                 "urgency " (u (number->string (task-urgency task))))]
         [urg-level (urgency-level (task-urgency task))])
    (if (< (date-minute dd) 10)
        (and (= (date-day dd) 1)
             (system* "notify-send" "--urgency" urg-level title content))
        (format (current-error-port) "delta minute: ~a, ignored" (date-minute dd)))))


;; === main ===

(define tasks (tasks-due-in "10h"))
(vector-map notify-task-due tasks)
