# moonscript-mode

## Overview

A basic major mode for editing [MoonScript](http://moonscript.org/), a
preprocessed language for [Lua](https://www.lua.org/) which shares
many similarities with [CoffeeScript](http://coffeescript.org/).

Also includes a very basic major mode for the experimental
[MoonScript REPL](https://github.com/leafo/moonscript/wiki/Moonscriptrepl).

## History

This mode started out as a modification of stuff found in
[@GriffinSchneider's Emacs configs](https://github.com/GriffinSchneider/emacs-config).

## Installation

### From MELPA

The easiest way to get the mode is to install the `moonscript` package from the [MELPA](https://melpa.org/) package archive.

### Manual

    $ cd ~/.emacs.d/vendor
    $ git clone https://github.com/k2052/moonscript-mode.git

And add following to your .emacs file:

    (add-to-list 'load-path "~/.emacs.d/vendor/moonscript-mode")
    (require 'moonscript)
    (require 'moonscript-repl)

## Usage

### With a REPL

If you load up a moonscript REPL (see https://github.com/leafo/moonscript/wiki/Moonscriptrepl) you can 
then hit:

<key>M</key>-<key>X</key> `moonscript-repl-mode`

to activate.

Improvements and more docs will come as we need them.

## Development

The package ships with an ERT test suite and a `Makefile`.
Assuming a recent Emacs is on your `PATH`:

```sh
make check      # byte-compile (warnings are errors) and run tests
make test       # run the ERT test suite only
make compile    # byte-compile the sources only
```

To run a single test from within Emacs:

```elisp
M-x ert RET moonscript-indent-line/indents-relative-to-prev RET
```

The suite has no external dependencies beyond Emacs itself; ERT is
part of the standard distribution.

### Support

If you found this repo useful please consider supporting me on [Gittip](https://www.gittip.com/k2052) or sending me some
bitcoin `1csGsaDCFLRPPqugYjX93PEzaStuqXVMu`
