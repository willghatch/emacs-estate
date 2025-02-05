;; -*- lexical-binding: t -*-
;;; estate-default-states.el --- Basic vim-like state definitions for estate-mode, with no key bindings.

;;; Author: William Hatch <william@hatch.uno>
;;; Maintainer: William Hatch <william@hatch.uno>
;;; Version: 0.0
;;; Homepage: https://github.com/willghatch/emacs-estate
;;; Git-Repository: git://github.com/willghatch/emacs-estate.git

;;; License:
;;; This is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;; <http://www.gnu.org/licenses/>

;;; Commentary:
;;; See https://github.com/willghatch/emacs-estate/README.md for details.

;;; Code:

;; Definitions for states that are similar to vim and evil-mode in spirit, though simpler and with no bindings.

(require 'estate)

(defun estate--activate-initialize-core-states ()
  (add-hook 'activate-mark-hook 'estate--mark-activate-hook 0 t)
  (add-hook 'deactivate-mark-hook 'estate--mark-deactivate-hook 0 t)
  )
(defun estate--deactivate-initialize-core-states ()
  (remove-hook 'activate-mark-hook 'estate--mark-activate-hook t)
  (remove-hook 'deactivate-mark-hook 'estate--mark-deactivate-hook t)
  )
(add-hook 'estate-activate-hook 'estate--activate-initialize-core-states)
(add-hook 'estate-deactivate-hook 'estate--deactivate-initialize-core-states)

(when (not estate-set-initial-state-function)
  (setq estate-set-initial-state-function 'estate--default-set-initial-state-function-for-vim-like-states))

(defun estate--default-set-initial-state-function-for-vim-like-states ()
  (if (minibufferp)
      (estate-insert-state)
    (estate-normal-state)))

;; Motion map is a core map that suppresses everything not bound, and is the basis for most non-insert modes.
(estate-define-state motion nil)
(suppress-keymap estate-motion-state-keymap)

(estate-define-state normal estate-motion-state-keymap)

;; A pager state is nice to have -- it's basically motion state but maybe with some extra keys.  The idea is that it's like normal mode but you won't accidentally hit editing keys or such, and maybe you bind things a bit differently, eg to scroll a page instead of moving by a line.
(estate-define-state pager estate-motion-state-keymap)
(add-hook 'estate-pager-state-enter-hook 'estate--pager-state-init)
(add-hook 'estate-pager-state-exit-hook 'estate--pager-state-exit)
(defvar-local estate--pre-pager-state-read-only-status nil)
(defun estate--pager-state-init ()
  (setq estate--pre-pager-state-read-only-status buffer-read-only)
  (setq buffer-read-only t))
(defun estate--pager-state-exit ()
  (setq buffer-read-only estate--pre-pager-state-read-only-status))

;; Insert state does not suppress the keymap, so it passes through to the global keymap.  It's basically emacs mode.  Except that you can define things that shadow the global keymap with it.
(estate-define-state insert nil)

(defvar-local estate--state-change-with-group-marker nil)

(defun estate--change-group-marker-init ()
  (when (not estate--state-change-with-group-marker)
    (setq-local estate--state-change-with-group-marker (prepare-change-group))))

(defun estate--state-with-change-group-handler ()
  (when estate--state-change-with-group-marker
    (undo-amalgamate-change-group estate--state-change-with-group-marker)
    (setq-local estate--state-change-with-group-marker nil)))

(add-hook 'estate-insert-state-enter-hook 'estate--change-group-marker-init)
(add-hook 'estate-insert-state-exit-hook 'estate--state-with-change-group-handler)

(defun estate--activate-state-with-change-group (new-state pre-change-thunk)
  "Do all operations in pre-change-thunk and new-state as one change group (undo group)."
  (estate--state-with-change-group-handler)
  (let ((estate-change-group-marker (prepare-change-group)))
    (setq-local estate--state-change-with-group-marker estate-change-group-marker)
    (funcall pre-change-thunk)
    (estate-activate-state new-state)))



(defun estate-insert-state-with-thunk (thunk)
  "Enter insert state, but execute thunk as part of the change group.
This allows you to create bindings like Vim's change operator that do some edit then leave you in insert mode, but treat both as one change group."
  (estate--activate-state-with-change-group 'insert thunk))



;; Visual states.
;; I've made visual state use a hook so that commands that activate the region will activate visual state.
;; visual mode presupposes that you are using and want to use transient-mark-mode.
(estate-define-state visual estate-normal-state-keymap)

(defun estate--mark-activate-hook ()
  (estate--visual-state-change 'activate))
(defun estate--mark-deactivate-hook ()
  (estate--visual-state-change 'deactivate))

(defvar-local estate--pre-visual-state 'normal)

(defun estate--visual-state-change (&optional reason)
  "Set estate state based on region and such."
  (unless (member estate-state '(visual))
    (setq-local estate--previous-state estate-state))
  (if (region-active-p)
      (estate-activate-state 'visual)
    (when (equal estate-state 'visual)
      (estate-normal-state))))

(defun estate--visual-mark-initialize ()
  (unless (region-active-p)
    (set-mark (point))))

(add-hook 'estate-visual-state-enter-hook 'estate--visual-mark-initialize)
(add-hook 'estate-visual-state-exit-hook 'deactivate-mark)

(provide 'estate-default-states)
