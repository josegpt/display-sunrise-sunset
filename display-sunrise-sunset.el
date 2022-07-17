;;; display-sunrise-sunset.el --- Display sunrise sunset in the mode line 🌅 -*- lexical-binding: t -*-

;; Copyright (C) 2022 Jose G Perez Taveras <josegpt27@gmail.com>

;; Author: Jose G Perez Taveras <josegpt27@gmail.com>
;; Maintainer: Jose G Perez Taveras <josegpt27@gmail.com>
;; Version: 0.0.1
;; Package-Requires: ((emacs "27.1"))
;; URL: https://github.com/josegpt/display-sunrise-sunset
;; SPDX-License-Identifier: GPL-3.0-only

;;; Commentary:

;; Display-sunrise-sunset package contains a minor mode that can be
;; toggled on/off.  It displays sunrise and sunset times on the mode
;; line The entrypoint is`display-sunrise-sunset'.

;;; Code:

(require 'solar)
(require 'calendar)

(defgroup display-sunrise-sunset ()
  "Display sunrise sunset in the modeline 🌅."
  :prefix "display-sunrise-sunset-"
  :group 'mode-line)

(defcustom display-sunrise-sunset-interval (* 60 60 24)
  "Seconds between updates of sunrise-sunset in the mode line."
  :type 'integer)

(defcustom display-sunrise-sunset-hook nil
  "List of functions to be called when sunrise-sunset is updated in the
mode line."
  :type 'hook)

(defvar display-sunrise-sunset-string nil
  "String used in mode line to display sunrise sunset string.  It should
not be set directly, but is instead updated by the
`display-sunrise-sunset' function.")
;;;###autoload(put 'display-sunrise-sunset-string 'risky-local-variable t)

(defvar display-sunrise-sunset-timer nil
  "Timer used by `display-sunrise-sunset'.")
;;;###autoload(put 'display-sunrise-sunset-timer 'risky-local-variable t)

(defun display-sunrise-sunset-update-handler ()
  "Update sunrise-sunset in mode line.  Calcalutes and sets up the timer
for the next update of sunrise-sunset with the specified
`display-sunrise-sunset-interval'"
  (display-sunrise-sunset-update)
  (let* ((current (current-time))
         (timer display-sunrise-sunset-timer)
         (next-time (timer-relative-time
                     (list (aref timer 1) (aref timer 2) (aref timer 3))
                     (* 5 (aref timer 4)) 0)))
    (or (time-less-p current next-time)
        (progn
          (timer-set-time timer (timer-next-integral-multiple-of-time
                                 current display-sunrise-sunset-interval)
                          (timer-activate timer))))))

(defun display-sunrise-sunset-update ()
  "Update `display-sunrise-sunset' in mode line."
  (let* ((calendar-time-display-form '(12-hours ":" minutes am-pm))
         (l (solar-sunrise-sunset (calendar-current-date)))
         (sunrise (apply #'solar-time-string (car l)))
         (sunset (apply #'solar-time-string (cadr l))))
    (setq display-sunrise-sunset-string
          (format "[↑%s ↓%s] " sunrise sunset))
    (run-hooks 'display-sunrise-sunset-hook))
  (force-mode-line-update 'all))

;;;###autoload
(defun display-sunrise-sunset ()
  "Enable display of sunrise-sunset in mode line.  This display updates
automatically every day.  This runs the normal hook
`display-sunrise-sunset-hook' after each update."
  (interactive)
  (display-sunrise-sunset-mode 1))

;;;###autoload
(define-minor-mode display-sunrise-sunset-mode
  "Toggle display of sunrise-sunset.  When Display Sunrise-Sunset mode
is enabled, it updates every day (you can control the number of seconds
between updates by customizing `display-sunrise-sunset-interval'"
  :global t
  :group 'display-sunrise-sunset
  (and display-sunrise-sunset-timer (cancel-timer display-sunrise-sunset-timer))
  (setq display-sunrise-sunset-string "")
  (or global-mode-string (setq global-mode-string '("")))
  (when display-sunrise-sunset-mode
    (or (memq 'display-sunrise-sunset-string global-mode-string)
        (setq global-mode-string
              (append global-mode-string '(display-sunrise-sunset-string))))
    (setq display-sunrise-sunset-timer
          (run-at-time t display-sunrise-sunset-interval
                       'display-sunrise-sunset-update-handler))
    (display-sunrise-sunset-update)))

(provide 'display-sunrise-sunset)

;;; display-sunrise-sunset.el ends here
