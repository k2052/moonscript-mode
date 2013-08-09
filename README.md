# moonscript-mode

An Emacs major mode for moonscript source files and for [moonscript
repl](https://github.com/leafo/moonscript/wiki/Moonscriptrepl). 
Modified from stuff I found in [@GriffinSchneider's Emacs configs](https://github.com/GriffinSchneider/emacs-config)

# Installation

## Manual

    $ cd ~/.emacs.d/vendor
    $ git clone https://github.com/k2052/moonscript-mode.git

And add following to your .emacs file:

    (add-to-list 'load-path "~/.emacs.d/vendor/moonscript-mode")
    (require 'moonscript-mode)
    (require 'moonscriptrepl-mode)

## Via Package.el

I've not pushed this to any package sites yet but will as I soon as I figure out the package definitions. 
This is my first emacs package :)

# Usage

## With a REPL

If you load up a moonscript REPL (see https://github.com/leafo/moonscript/wiki/Moonscriptrepl) you can 
then hit:

<key>M</key>-<key>X</key> `moonscriptrepl-mode`

to activate.

Improvements and more docs will come as I need them.
