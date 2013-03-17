# VIM Table Mode

An awesome automatic table creator & formatter allowing one to create neat
tables as you type.

# Installation

There are 2 ways to do this

1. I recommend installing <a
   href="https://github.com/tpope/vim-pathogen">pathogen.vim</a> and then
   adding a git submodule for your plugin:

   ```sh
$ cd ~/.vim
$ git submodule add git@github.com:dhruvasagar/vim-table-mode.git bundle/table-mode
   ```
2. Copy table-mode.vim into ~/.vim/plugin/ (Unix) or vimfiles/plugin/ (Windows)
   as with other plugins.

# Requirements

Depends on <a href="https://github.com/godlygeek/tabular">Tabular</a>. Make
sure Tabular is installed and loaded into your runtime to ensure this works.

# Usage

By default the table column separator is '|' (it can be changed). As soon as
you type it on a new line (ignores indentation) the script gets to work on
creating the table around it. As you type and define more columns, the table is
completed, formatted and aligned automatically.

Since this could lead to unwanted behavior I have disabled table mode by
default. You would have to use `:TableModeToggle` command or the table mode
toggle mapping, which is `<Leader>tm` by default. This is on a per buffer basis
and so it does not mess up unless enabled explicitly. Please read `:h table-mode`
for further information.

Demo:

<img src="https://raw.github.com/dhruvasagar/vim-table-mode/master/demo.gif"
height="500" />
