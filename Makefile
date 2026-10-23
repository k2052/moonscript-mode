# moonscript-mode Makefile
#
# Common targets:
#   make check     byte-compile (warnings are errors) then run the test suite
#   make test      run the ERT test suite
#   make compile   byte-compile, treating warnings as errors
#   make clean      remove generated *.elc files

EMACS       ?= emacs
EMACSFLAGS   = --batch -L . -L test

SOURCES      = moonscript.el moonscript-repl.el
TEST_SOURCE  = test/moonscript-test.el
ELC         := $(SOURCES:.el=.elc) $(TEST_SOURCE:.el=.elc)

.PHONY: check test compile clean

check: compile test

compile:
	@echo "Byte-compiling $(SOURCES)..."
	$(EMACS) $(EMACSFLAGS) \
	  --eval "(setq byte-compile-error-on-warn t)" \
	  -f batch-byte-compile $(SOURCES)

test:
	$(EMACS) $(EMACSFLAGS) -l moonscript-test \
	  -f ert-run-tests-batch-and-exit

clean:
	rm -f $(ELC)