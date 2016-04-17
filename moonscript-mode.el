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

(defcustom moonscript-indent-offset 2
  "How many spaces to indent MoonScript code per level of nesting."
  :group 'moonscript
  :type 'integer
  :safe 'integerp)

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
    ("!"                              . font-lock-warning-face)))

(defun moonscript-indent-level (&optional blankval)
  "Return nesting depth of current line.

If BLANKVAL is non-nil, return that instead if the line is blank.
Upon return, regexp match data is set to the leading whitespace."
  (assert (= (point) (point-at-bol)))
  (looking-at "^[ \t]*")
  (if (and blankval (= (match-end 0) (point-at-eol)))
      blankval
    (floor (/ (- (match-end 0) (match-beginning 0))
              moonscript-indent-offset))))

(defun moonscript-indent-line ()
  "Cycle indentation levels for the current line of MoonScript code.

Looks at how deeply the previous non-blank line is nested. The
maximum indentation level for the current line is that level plus
one.

When computing indentation depth, one tab is currently considered
equal to one space. Tabs are currently replaced with spaces when
re-indenting a line."
  (goto-char (point-at-bol))
  (let ((curlinestart (point))
        (prevlineindent -1))
    ;; Find indent level of previous non-blank line.
    (while (and (< prevlineindent 0) (> (point) (point-min)))
      (goto-char (1- (point)))
      (goto-char (point-at-bol))
      (setq prevlineindent (moonscript-indent-level -1)))
    ;; Re-indent current line based on what we know.
    (goto-char curlinestart)
    (let* ((oldindent (moonscript-indent-level))
           (newindent (if (= oldindent 0) (1+ prevlineindent)
                        (1- oldindent))))
      (replace-match (make-string (* newindent moonscript-indent-offset)
                                  ? )))))

(define-derived-mode moonscript-mode fundamental-mode "moonscript"
  (set (make-local-variable 'font-lock-defaults)
       '(moonscript-font-lock-defaults))

  (set (make-local-variable 'indent-line-function) 'moonscript-indent-line)
  (when (fboundp 'electric-indent-local-mode)
    ;; The electric indent feature re-indents the current line
    ;; whenever the user types a newline. That doesn't mesh well with
    ;; languages such as MoonScript that have significant whitespace.
    (electric-indent-local-mode 0))
  (modify-syntax-entry ?\- ". 12b" moonscript-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" moonscript-mode-syntax-table)
  (modify-syntax-entry ?\_ "w" moonscript-mode-syntax-table))

(provide 'moonscript-mode)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.moon\\'" . moonscript-mode))

;;; moonscript.el ends here
