;;; moonscript-mode.el --- a major-mode for editing Moonscript
;;;
;;; Author: @GriffinSchneider, @k2052, @EmacsFodder
;;; Version: 20140803-0.1.0
;;; Commentary:
;;
;;  A basic major mode for editing MoonScript, a preprocessed language
;;  for Lua which shares many similarities with CoffeeScript.
;;
;;; License: MIT Licence
;;
;;; Code:

(defgroup moonscript nil
  "MoonScript (for Lua) language support for Emacs."
  :tag "MoonScript"
  :group 'languages)

(defvar moonscript-mode-hook nil
  "List of functions to be executed with web-mode.")

(defvar moonscript-statement
  '("return" "break" "continue"))

(defvar moonscript-repeat
  '("for" "while"))

(defvar moonscript-conditional
  '("if" "else" "elseif" "then" "switch" "when" "unless"))

(defvar moonscript-keyword
  '("export" "local" "import" "from" "with" "in" "and" "or" "not"
    "class" "extends" "super" "using" "do"))

(defvar moonscript-keywords
  (append moonscript-statement moonscript-repeat moonscript-conditional moonscript-keyword))

(defvar moonscript-constants
  '("nil" "true" "false" "self"))

(defvar moonscript-keywords-regex (regexp-opt moonscript-keywords 'symbols))

(defvar moonscript-constants-regex (regexp-opt moonscript-constants 'symbols))

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
      (,moonscript-function-regex       . font-lock-function-name-face)
      (,moonscript-assignment-regex     . font-lock-preprocessor-face)
      (,moonscript-constants-regex      . font-lock-constant-face)
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

(provide 'moonscript-mode)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.moon\\'" . moonscript-mode))

;;; moonscript.el ends here
