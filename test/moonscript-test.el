;;; moonscript-test.el --- Tests for moonscript-mode  -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; ERT test suite for `moonscript' and `moonscript-repl'.  Run with
;;     make test
;; or directly:
;;     emacs --batch -L . -L test -l moonscript-test -f ert-run-tests-batch-and-exit

;;; Code:

(require 'ert)
(require 'moonscript)
(require 'comint)
(require 'moonscript-repl)

(defun moonscript-test--buffer (content)
  "Return a new temp buffer in `moonscript-mode' holding CONTENT."
  (let ((buf (generate-new-buffer " *moonscript-test*")))
    (with-current-buffer buf
      (insert content)
      (goto-char (point-min))
      (moonscript-mode))
    buf))

;;; ---------------------------------------------------------------------------
;;; moonscript-indent-level
;;; ---------------------------------------------------------------------------

(ert-deftest moonscript-indent-level/zero-at-column-0 ()
  "A line with no leading indentation has level 0."
  (with-temp-buffer
    (insert "a = 1\n")
    (goto-char (point-min))
    (should (= 0 (moonscript-indent-level)))))

(ert-deftest moonscript-indent-level/spaces ()
  "N*`moonscript-indent-offset' spaces of indentation maps to level N."
  (let ((moonscript-indent-offset 2))
    (with-temp-buffer
      (insert "    a\n")            ; 4 spaces => level 2
      (goto-char (point-min))
      (should (= 2 (moonscript-indent-level))))))

(ert-deftest moonscript-indent-level/tab-counts-as-one-space ()
  "Per the docstring, one tab counts as one space, not one `offset'."
  (let ((moonscript-indent-offset 2))
    (with-temp-buffer
      (insert "\ta\n")               ; 1 tab => floor(1/2) = 0
      (goto-char (point-min))
      (should (= 0 (moonscript-indent-level))))))

(ert-deftest moonscript-indent-level/blank-line-returns-blankval ()
  "A fully blank line returns BLANKVAL instead of its measured level."
  (let ((moonscript-indent-offset 2))
    (with-temp-buffer
      (insert "    \n")              ; blank line of spaces
      (goto-char (point-min))
      (should (eq :blank (moonscript-indent-level :blank))))))

(ert-deftest moonscript-indent-level/nonblank-ignores-blankval ()
  "BLANKVAL is only returned for actually blank lines."
  (with-temp-buffer
    (insert "  a\n")
    (goto-char (point-min))
    (should (= 1 (moonscript-indent-level :blank)))))

(ert-deftest moonscript-indent-level/asserts-bol ()
  "Calling away from BOL triggers `cl-assert'."
  (with-temp-buffer
    (insert "  a\n")
    (goto-char (point-min))
    (forward-char 2)
    (should-error (moonscript-indent-level) :type 'cl-assertion-failed)))

;;; ---------------------------------------------------------------------------
;;; moonscript-indent-line
;;; ---------------------------------------------------------------------------

(ert-deftest moonscript-indent-line/indents-relative-to-prev ()
  "A 0-indent line jumps to `prev+1' levels."
  (let ((moonscript-indent-offset 2))
    (with-temp-buffer
      (insert "a = 1\nb = 2\n")
      (goto-char (point-min))
      (forward-line 1)             ; BOL of the `b = 2' line
      (moonscript-indent-line)
      (should (string= "  b = 2"
                       (buffer-substring-no-properties
                        (line-beginning-position) (line-end-position)))))))

(ert-deftest moonscript-indent-line/dedents-by-one ()
  "Re-invoking on an already-indented line drops one level."
  (let ((moonscript-indent-offset 2))
    (with-temp-buffer
      (insert "a = 1\n  b = 2\n")
      (goto-char (point-min))
      (forward-line 1)
      (moonscript-indent-line)
      (should (string= "b = 2"
                       (buffer-substring-no-properties
                        (line-beginning-position) (line-end-position)))))))

(ert-deftest moonscript-indent-line/skips-blank-prev-line ()
  "Blank intervening lines are ignored when finding the previous line."
  (let ((moonscript-indent-offset 2))
    (with-temp-buffer
      (insert "a = 1\n\nb = 2\n")
      (goto-char (point-min))
      (forward-line 2)            ; BOL of the `b = 2' line
      (moonscript-indent-line)
      (should (string= "  b = 2"
                       (buffer-substring-no-properties
                        (line-beginning-position) (line-end-position)))))))

(ert-deftest moonscript-indent-line/first-line-stays-at-0 ()
  "With no previous line, a 0-indent line stays at 0."
  (let ((moonscript-indent-offset 2))
    (with-temp-buffer
      (insert "a = 1\n")
      (goto-char (point-min))
      (moonscript-indent-line)
      (should (string= "a = 1\n" (buffer-string))))))

;;; ---------------------------------------------------------------------------
;;; Font-lock regexes
;;; ---------------------------------------------------------------------------

(ert-deftest moonscript-font-lock-keywords-regex/matches-all-keywords ()
  "Every keyword in `moonscript-keywords' is recognized by the regex."
  (dolist (kw moonscript-keywords)
    (should (string-match-p moonscript-keywords-regex kw))))

(ert-deftest moonscript-font-lock-keywords-regex/rejects-non-keyword ()
  "An ordinary identifier is not a keyword."
  (should-not (string-match-p moonscript-keywords-regex "ordinaryName")))

(ert-deftest moonscript-font-lock-constants-regex ()
  (dolist (c moonscript-constants)
    (should (string-match-p moonscript-constants-regex c))))

(ert-deftest moonscript-font-lock-class-name-regex ()
  ;; Font-lock matches case-sensitively; emulate that here.
  (let ((case-fold-search nil))
    (should (string-match-p moonscript-class-name-regex "MyClass"))
    (should-not (string-match-p moonscript-class-name-regex "lowercase"))))

(ert-deftest moonscript-font-lock-ivar-regex ()
  (should (string-match-p moonscript-ivar-regex "@foo"))
  (should-not (string-match-p moonscript-ivar-regex "foo")))

(ert-deftest moonscript-font-lock-octal/hex-number-regex ()
  "Despite the `octal' name, the regex matches hex literals."
  (should (string-match-p moonscript-octal-number-regex "0xff"))
  (should (string-match-p moonscript-octal-number-regex "0xDEADBEEF"))
  (should-not (string-match-p moonscript-octal-number-regex "123")))

(ert-deftest moonscript-font-lock-number-regex ()
  (dolist (n '("0" "42" "3.14" ".5" "10."))
    (should (string-match-p moonscript-number-regex n))))

(ert-deftest moonscript-font-lock-table-key-regex ()
  (should (string-match-p moonscript-table-key-regex "key:"))
  (should-not (string-match-p moonscript-table-key-regex "key")))

(ert-deftest moonscript-font-lock-assignment-regex ()
  (should (string-match-p moonscript-assignment-regex "="))
  (should (string-match-p moonscript-assignment-regex "+="))
  (should (string-match-p moonscript-assignment-regex "..=")))

(ert-deftest moonscript-font-lock-assignment-var-regex/captures-name ()
  "The assignment-var regex captures the variable name in group 1."
  (with-temp-buffer
    (insert "foo = 1")
    (goto-char (point-min))
    (should (looking-at moonscript-assignment-var-regex))
    (should (string= "foo" (match-string 1)))))

;;; ---------------------------------------------------------------------------
;;; Mode registration & behaviour
;;; ---------------------------------------------------------------------------

(ert-deftest moonscript-mode/auto-mode-alist ()
  "`moonscript-mode' is registered for `.moon' files."
  (should (eq 'moonscript-mode
              (cdr (assoc "\\.moon\\'" auto-mode-alist)))))

(ert-deftest moonscript-mode/derives-from-prog-mode ()
  (with-temp-buffer
    (moonscript-mode)
    (should (derived-mode-p 'moonscript-mode 'prog-mode))))

(ert-deftest moonscript-mode/sets-comment-start ()
  (with-temp-buffer
    (moonscript-mode)
    (should (string= "-- " comment-start))))

(ert-deftest moonscript-mode/sets-indent-function ()
  (with-temp-buffer
    (moonscript-mode)
    (should (eq 'moonscript-indent-line indent-line-function))))

(ert-deftest moonscript-mode/inhibits-electric-indent ()
  (with-temp-buffer
    (moonscript-mode)
    (should (eq t electric-indent-inhibit))))

(ert-deftest moonscript-mode/underscore-is-word ()
  "Underscore has word syntax in `moonscript-mode'."
  (with-temp-buffer
    (insert "_")
    (moonscript-mode)
    (should (eq ?w (char-syntax ?_)))))

(ert-deftest moonscript-mode/double-dash-is-comment ()
  "`--' starts a line comment in `moonscript-mode'."
  (with-temp-buffer
    (insert "-- hello\nworld\n")
    (moonscript-mode)
    (goto-char (point-min))
    (forward-comment 1)
    (should (looking-at "world"))))

;;; ---------------------------------------------------------------------------
;;; moonscript-repl-mode
;;; ---------------------------------------------------------------------------

(ert-deftest moonscript-repl-mode/derives-from-comint ()
  (with-temp-buffer
    (moonscript-repl-mode)
    (should (derived-mode-p 'moonscript-repl-mode 'comint-mode))))

(ert-deftest moonscript-repl-mode/uses-moonscript-syntax-table ()
  (with-temp-buffer
    (moonscript-repl-mode)
    (should (eq (syntax-table) moonscript-mode-syntax-table))))

(ert-deftest moonscript-repl-mode/uses-moonscript-font-lock ()
  (with-temp-buffer
    (moonscript-repl-mode)
    (should (equal '(moonscript-font-lock-defaults)
                   font-lock-defaults))))

(provide 'moonscript-test)

;;; moonscript-test.el ends here