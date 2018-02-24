;;; duplicate-region.el --- duplicate a region or line & and activate it.

;; filename: duplicate-region.el
;; Description: Duplicate an active region or the current line, above or below the current location, and activate it as a region.
;; Author: Craig Lyons <craiglyons.dev@gmail.com>
;; Keywords: convenience
;; Url: https://github.com/craiglyonsdev/duplicate-region
;; Compatibility: GNU Emacs 25.1
;; Version: 1.0.0
;;
;;; This file is NOT part of GNU Emacs

;;; License
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;; Usage:
;;
;; Only 2 functions should be used, and those should probably be bound to keystrokes.
;; Default bindings to s-m-<up> and s-m-<down> are available via duplicate-region-default-bindings.
;; duplicate-region-above
;; duplicate-region-below

;;; Commentary:
;;
;; duplicate-region is a clone of behavior from other popular editors, such as Visual Studio Code.
;; The expectation is that when a region is selected, you key shift-alt-up to duplicate the region & put it above the source, or shift-alt-down to put it below.
;; If no region is selected, it should perform the above actions on the line where the cursor lies.
;; One other bit of complexity is that it should assume the intent was to duplicate entire lines, even if only a portion of each line is selected.

;;; Installation:
;;
;; Put duplicate-region.el to your load-path.
;; The load-path is usually ~/elisp/.
;; It's set in your ~/.emacs like this:
;; (add-to-list 'load-path (expand-file-name "~/elisp"))
;;
;; And the following to your ~/.emacs startup file.
;;
;; (require 'duplicate-region)
;; (duplicate-region-default-bindings-default-bindings)

;;; Code:


(defun duplicate-region-above()
  "Duplicate the selected region above the cursor."
  (interactive) (duplicate-region "above"))

(defun duplicate-region-below()
  "Duplicate the selected region below the cursor."
  (interactive) (duplicate-region "below"))

(defun duplicate-region(direction)
  "Perform the region duplication based on the direction given."
  (duplicate-region-extend-region-to-line-boundaries)
  (let
      ((p1 (region-beginning))
       (p2 (region-end)))
    (copy-region-as-kill p1 p2)
    (goto-char (region-end))
    (newline)
    (yank)
    (duplicate-region-highlight-region direction p1 p2)))

(defun duplicate-region-extend-region-to-line-boundaries ()
  "Given a selection or line, activate a region that extends to the beginning & end of each line in the region."
  (let
      ((p1 (region-beginning))
       (p2 (region-end)))
    (if mark-active
        (progn
          (goto-char p1)
          (push-mark (line-beginning-position))
          (goto-char p2)
          (goto-char (line-end-position)))
      (push-mark (line-beginning-position))
      (goto-char (line-end-position)))))

(defun duplicate-region-highlight-region (direction p1 p2)
  "Based on DIRECTION, activate the intended region at original P1 and P2."
  (let
      ((region-length (- p2 p1)))
    (cond
     ((equal direction "above")
      (goto-char p1)
      (push-mark p2))
     ((equal direction "below")
      (goto-char (+ p2 1))
      (push-mark (+ (point) (+ region-length 1))))))
  (setq deactivate-mark nil))

(defun duplicate-region-default-bindings ()
  "Use default bindings for \"duplicate-region-above\" and \"duplicate-region-below\" (S-M-up / S-M-down)."
  (interactive)
  "Bind `duplicate-region-above' and `duplicate-region-below' to S-M-up & S-M-down."
  ;; unset & re-bind translations (i.e. drag-stuff translates M-down to S-M-down)
  (global-unset-key [S-M-down])
  (global-unset-key [S-M-up])
  (global-set-key [S-M-down] 'duplicate-region-below)
  (global-set-key [S-M-up]   'duplicate-region-above))

(provide 'duplicate-region)
;;; duplicate-region.el ends here
