;; org-notmuch-clocking --- A library that automates e-mail clocking when using notmuch.
;; Copyright (C) 2015 seamus tuohy
;; Keywords: org time notmuch clocking
;; Author: seamus tuohy s2e@seamustuohy.com
;; Maintainer: seamus tuohy s2e@seamustuohy.com
;; Created: 2015 May 27

;; When sending an response to an e-mail add the email clocking hooks

;; (add-hook 'notmuch-mua-send-hook
;;           (lambda ()
;;             (add-hook 'focus-in-hook 'org-notmuch-clocking-email-clock-in nil 'make-it-local)
;;             (add-hook 'focus-out-hook 'org-notmuch-clocking-email-clock-out nil 'make-it-local)))

;; When opening an email add the email clocking hooks
;; (add-hook 'notmuch-show-hook
;;           (lambda ()
;;             (add-hook 'focus-in-hook 'org-notmuch-clocking-email-clock-in nil 'make-it-local)
;;             (add-hook 'focus-out-hook 'org-notmuch-clocking-email-clock-out nil 'make-it-local)))

; (add-hook 'notmuch-show-hook 'org-notmuch-clocking)


(require 'notmuch)
(require 'org)
(require 'org-agenda)
(require 'org-capture)

(defgroup org-notmuch-clocking nil
  "Settings for notmuch emails time clocking in org-mode."
  :group 'org)

(defcustom org-notmuch-clocking-file nil
  "The file to use to track emails."
  :type 'file
  :group 'org-notmuch-clocking)

(setq org-notmuch-clocking-clocked-email nil)

(defun org-notmuch-clocking-email-clock ()
  (interactive)
  (let ((message_id (notmuch-show-get-message-id))
        (if (condition-case nil
                (string-equal message_id (org-entry-get org-clock-marker "ID"))
              (error nil))
            (org-notmuch-clocking-email-clock-out message_id)
          (org-notmuch-clocking-email-clock-in)))))

(defun org-notmuch-clocking-email-clock-out ()
  "Clock out of a the currently clocked email. Only clocks out if the current e-mail is the active clocking task."
  (interactive)
  (if (and (org-clocking-p)
           (if org-notmuch-clocking-clocked-email
               'true
             'false))
      ;; If there is an interupted task clock into that
      (if (marker-buffer org-clock-interrupted-task)
          (org-with-point-at org-clock-interrupted-task
            (org-clock-in))
        ;; If no interupted task then find our email and clock out of it.
        (let* ((message_id org-notmuch-clocking-clocked-email)
               (email_loc (org-id-find-id-in-file message_id org-notmuch-clocking-file))
               (email_mrkr (make-marker)))
          (set-marker email_mrkr (cdr email_loc) (get-file-buffer (car email_loc)))
          (if (string-equal message_id (org-entry-get org-clock-marker "ID"))
              (org-with-point-at email_mrkr
                (org-clock-out)))))
        (setq org-notmuch-clocking-clocked-email nil)))

(defun org-notmuch-clocking-email-clock-in ()
  "Clock in to the header for the current email. If the header does not exist, this function will create it first."
  (interactive)
  (message "clocking message in")
  (if (org-id-find-id-in-file (notmuch-show-get-message-id) org-notmuch-clocking-file)
      (let* ((email_loc (org-id-find-id-in-file (notmuch-show-get-message-id) org-notmuch-clocking-file))
             (email_mrkr (make-marker)))
        (setq org-notmuch-clocking-clocked-email (notmuch-show-get-message-id))
        (set-marker email_mrkr (cdr email_loc) (get-file-buffer (car email_loc)))
        (org-with-point-at email_mrkr
          (org-clock-in)))
    (org-notmuch-clocking-add-email)))

(defun org-notmuch-clocking-add-email ()
  "This function will create a header at the end of the current org-notmuch-clocking file"
  (message "adding new email entry")
  (let ((org-capture-entry '("W" "org-notmuch-clocking-email" entry
                             (file org-notmuch-clocking-file)
                             "" :clock-in t :clock-keep t))
        (message_id (notmuch-show-get-message-id))
        (subject (notmuch-show-get-subject))
        (from (notmuch-show-get-from)))
    (org-capture nil "W")
    (org-insert-link nil (concat "notmuch:" message_id) (concat subject " From: " from))
    (org-insert-property-drawer)
    (org-entry-put nil "FROM" from)
    (org-entry-put nil "ID" message_id)
    (org-capture-finalize)
    (setq org-notmuch-clocking-clocked-email message_id)))

(provide 'org-notmuch-clocking)
