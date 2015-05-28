;; org-notmuch-clocking
;; Copyright (C) 2015 seamus tuohy
;; Keywords: org time notmuch clocking
;; Author: seamus tuohy s2e@seamustuohy.com
;; Maintainer: seamus tuohy s2e@seamustuohy.com
;; Created: 2015 May 27

(require 'notmuch)
(require 'org)
(require 'org-agenda)
(require 'org-capture)

(defgroup org-notmuch-clocking nil
  "Settings for notmuch emails time clocking in org-mode."
  :group 'org)

(defcustom
  "The file to use to track emails."
  :type 'file
  :group 'org-notmuch-clocking
  org-notmuch-clocking-file "~/.org/email_clocking")

;; Declare external functions and variables
(declare-function notmuch-mua-send-hook "notmuch")
(declare-function notmuch-show-hook "notmuch")
(declare-function notmuch-show-get-message-id "notmuch")
(declare-function notmuch-show-get-from "notmuch")

(defun org-notmuch-clocking-email-clock-out (message_id subject from)
  "Clock out of a the current email. Only clocks out if the current e-mail is the active clocking task."
  (interactive (list (notmuch-show-get-message-id) (notmuch-show-get-subject) (notmuch-show-get-from)))
  (if (org-clocking-p)
      (let ((location (org-id-find-in-file message_id org-notmuch-clocking-file))
            (clocked-task (org-clock-marker)))
        (if (org-notmuch-clocking-email-is-clocked-task)
            (org-with-point-at location
              (org-clock-out)))))
  (message message_id) ;;TODO FIX STUB CODE HERE
  (message from)) ;;TODO FIX STUB CODE HERE

(defun org-notmuch-clocking-email-clock-in (message_id subject from)
  "Clock in to the header for the current email. If the header does not exist, this function will create it first."
   (interactive (list (notmuch-show-get-message-id) (notmuch-show-get-subject) (notmuch-show-get-from)))
   (let (location (org-id-find-in-file message_id org-notmuch-clocking-file)))
   (if not location
     ((org-notmuch-clocking-add-email message_id subject from)
      (org-notmuch-clocking-email-clock-in message_id subject from))
     (org-with-point-at location
       (org-clock-in))))

(defun org-notmuch-clocking-add-email (message_id subject from)
  "This function will create a header at the end of the current org-notmuch-clocking file"
;(org-insert-heading &optional ARG INVISIBLE-OK)
;; ;;If point is at the beginning of a heading or a list item, insert a new heading or a new item above the current one.  If point is at the beginning of a normal line, turn the line into a heading.
; (org-insert-property-drawer)
; (org-insert-drawer &optional ARG DRAWER)


  ;
  )

(defun org-notmuch-clocking-email-is-clocked-task (email_mrkr clocked_loc)
  (let ((clocked_mrkr make-marker))
    (set-marker clocked_mrkr (cdr clocked_loc) (car clocked_loc))
    (if (eq (

             )


    )
;;When sending an response to an e-mail add the email clocking hooks
(add-hook 'notmuch-mua-send-hook
          (lambda ()
            (add-hook 'focus-in-hook 'org-notmuch-clocking-email-clock-in nil 'make-it-local)
            (add-hook 'focus-out-hook 'org-notmuch-clocking-email-clock-out nil 'make-it-local)))

;;When opening an email add the email clocking hooks
(add-hook 'notmuch-show-hook
          (lambda ()
            (add-hook 'focus-in-hook 'org-notmuch-clocking-email-clock-in nil 'make-it-local)
            (add-hook 'focus-out-hook 'org-notmuch-clocking-email-clock-out nil 'make-it-local)))

(set-marker MARKER POSITION &optional BUFFER)
(provide org-notmuch-clocking)

;;; XXX.el ends here
