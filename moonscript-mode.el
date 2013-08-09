;;; moonscript-mode.el --- a simplistic major-mode for editing Moonscript

(defvar moonscript-keywords
  '("class" "extends" "with" "export" "import" "from" "for" "in"))

(defvar moonscript-keywords-regex (regexp-opt moonscript-keywords 'symbols))

;; Class names - just match any word starting with a capital letter
(defvar moonscript-class-name-regex "\\<[A-Z]\\w*\\>")

(defvar moonscript-function-keywords
  '("->" "=>" "(" ")" "[" "]" "{" "}"))
(defvar moonscript-function-regex (regexp-opt moonscript-function-keywords))

(defvar moonscript-octal-number-regex
  "\\_<0x[[:xdigit:]]+\\_>")

(defvar moonscript-table-key-regex
  "\\_<\\w+:")

(defvar moonscript-ivar-regex
  "@\\_<\\w+\\_>")

(defvar moonscript-assignment-regex
  "\\([-+/*%]\\|\\.\\.\\)?=")

(defvar moonscript-number-regex
  (mapconcat 'identity '("[0-9]+\\.[0-9]*" "[0-9]*\\.[0-9]+" "[0-9]+") "\\|"))

(defvar moonscript-assignment-var-regex
  (concat "\\(\\_<\\w+\\) = "))
  
(defvar moonscript-font-lock-defaults
  (eval-when-compile
    `((,moonscript-class-name-regex     . font-lock-type-face)
      (,moonscript-function-regex       . font-lock-builtin-face)
      (,moonscript-assignment-regex     . font-lock-preprocessor-face)
      (,moonscript-keywords-regex       . font-lock-keyword-face)
      (,moonscript-ivar-regex           . font-lock-variable-name-face)
      (,moonscript-assignment-var-regex . (1 font-lock-variable-name-face))
      (,moonscript-octal-number-regex   . font-lock-constant-face)
      (,moonscript-number-regex         . font-lock-constant-face)
      (,moonscript-table-key-regex      . font-lock-variable-name-face)
      ("!"                              . font-lock-warning-face))))

(define-derived-mode moonscript-mode fundamental-mode "moonscript"
  (setq font-lock-defaults '(moonscript-font-lock-defaults))

  (modify-syntax-entry ?\- ". 12b" moonscript-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" moonscript-mode-syntax-table)
  (modify-syntax-entry ?\_ "w" moonscript-mode-syntax-table))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.moon$" . moonscript-mode))

(provide 'moonscript-mode)
