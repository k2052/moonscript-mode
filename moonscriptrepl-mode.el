;;; moonscriptrepl-mode.el --- a simplistic major-mode for editing Moonscript in a repl

(require 'moonscript-mode)

(define-derived-mode moonscriptrepl-mode comint-mode "moonscriptrepl"
  (setq font-lock-defaults '(moonscript-font-lock-defaults))

  (modify-syntax-entry ?\- ". 12b" moonscript-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" moonscript-mode-syntax-table)
  (modify-syntax-entry ?\_ "w" moonscript-mode-syntax-table))

(provide 'moonscriptrepl-mode)
