;;; moonscript-repl.el --- Major mode to interact with MoonScript REPL  -*- lexical-binding: t; -*-
;;
;; Author: @GriffinSchneider, @k2052, @EmacsFodder
;; Maintainer: k2052
;; URL: https://github.com/k2052/moonscript-mode
;; Keywords: languages moonscript lua
;; Version: 20140803-0.1.0
;; Package-Requires: ((emacs "24") (cl-lib "0.5"))
;; SPDX-License-Identifier: MIT
;;; Commentary:
;;
;;  A basic major mode for MoonScript REPL
;;
;;; License: MIT Licence
;;
;;; Code:

(require 'comint)
(require 'moonscript)

(define-derived-mode moonscript-repl-mode comint-mode "MoonScript REPL"
  "Major mode to interact with a MoonScript REPL.

See https://github.com/leafo/moonscript/wiki/Moonscriptrepl"
  (set-syntax-table moonscript-mode-syntax-table)
  (setq font-lock-defaults '(moonscript-font-lock-defaults)))

(provide 'moonscript-repl)

;;; moonscript-repl.el ends here
