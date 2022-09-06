;;; dired-queue.el --- Mark and enqueue files in Dired  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Arthur Miller

;; Author: Arthur Miller <arthur.miller@live.com>
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Add simple queue to Dired to preserve the order in which files are marked. To
;; act on the queue either Dired with marked files in other window, by default
;; bount to '#', or do it programmatically on `dired-queue' directly.

;;; Code:

(require 'dired)

(defvar-local dired-queue nil
  "Add queue for marked files.")

(defvar dired-queue-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [M-up] #'dired-line-up)
    (define-key map [M-down] #'dired-line-down)
    (define-key map (kbd "#") #'dired-display-queue)
    (define-key map [remap dired-mark] 'dired--mark-enqueue)
    (define-key map [remap dired-unmark] 'dired--unmark-dequeue)
    (define-key map [remap dired-unmark-all-marks] 'dired--unmark-all-dequeue)
  map)
"Mode map for dired-mark-and-enqueue-mode.")

(defun dired--mark-enqueue (arg &optional interactive)
  "Like `dired-mark' but add filename to the queue."
  (interactive (list current-prefix-arg t))
  (dired-mark arg interactive)
  (dolist (file (dired-get-marked-files))
    (add-to-list 'dired-queue file 'append)))

(defun dired--unmark-dequeue (arg &optional interactive)
"Like dired-unmark but remove filename from the queue too."
  (interactive (list current-prefix-arg t))
  (setq dired-queue (delete (expand-file-name (dired-file-name-at-point))
                            dired-queue))
    (dired-unmark arg interactive))

(defun dired--unmark-all-dequeue ()
  (interactive)  
  (dolist (file (dired-get-marked-files))
    (setq dired-queue (delete file dired-queue)))
  (dired-unmark-all-marks))

(defun dired-display-queue ()
  (interactive)
  (dired-other-window
   (apply #'list (concat (buffer-name) "-queue") default-directory dired-queue)))

(defun dired-line-up ()
  (interactive)
  (let ((inhibit-read-only t))
    (save-excursion
      (when (dired-get-file-for-visit)
        (forward-line -1)
        (when (dired-get-file-for-visit)
          (transpose-lines 1))))))

(defun dired-line-down ()
  (interactive)
  (let ((inhibit-read-only t))
    (when (dired-get-file-for-visit)
      (save-excursion
        (forward-line 1)
        (when (dired-get-file-for-visit)
          (transpose-lines 1))))))

(defun dired-queue ()
  "Return list of marked files in marking order."
  dired-queue)

(define-minor-mode dired-queue-mode
  "Enqueue files in Dired."
  :lighter "Dired with Queue"
  (unless (eq major-mode 'dired-mode)
    (user-error "Not in Dired buffer"))
  ;; make sure we always start with empty qeue
  (setq dired-queue nil))

(provide 'dired-queue)
;;; dired-queue.el ends here

