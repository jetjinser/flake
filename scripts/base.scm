#!/usr/bin/env -S scsh \\
-e main -s
!#

(define (main prog+args)
  (let ((prog-name (car prog+args)))
    (case (length prog+args)
      ((2) (of-base (second prog+args)))
      (else (usage prog-name)))))

(define (usage program-name)
  (format (error-output-port) "~a <number>~%"
          program-name)
  (exit 1))

(define (of-base number-string)
  (let* ((readable-string (clarify number-string))
         (decimal (string->number readable-string))
         (binary (number->string decimal 2))
         (octal (number->string decimal 8))
         (hexadecimal (number->string decimal 16)))
    (format #t "\t\t~a~%" number-string)
    (format #t "binary:\t\t~a~%" binary)
    (format #t "octal:\t\t~a~%" octal)
    (format #t "decimal:\t~a~%" decimal)
    (format #t "hexadecimal:\t~a~%" hexadecimal)))

(define (clarify number-string)
  (regexp-substitute/global #f (rx bos "0" (submatch (| "b" "o" "d" "x" "e" (+ num "r"))))
                            number-string
                            'pre "#" 1 'post))
