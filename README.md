# VIM Table Mode

An awesome automatic table creator & formatter allowing one to create neat
tables as you type.

### Change Log
#### version 1.1 :
* Added Tableize command and mapping to convert existing content into a table.

#### version 1.0 :
* First stable release, create tables as you type.

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
toggle mapping, which is `<Leader>tm` by default to toggle the table mode or
you can directly use `:TableModeEnable` and `:TableModeDisable` to enable or
disable the table mode. This is on a per buffer basis and so it does not cause
any unusual behavior unless enabled explicitly. Please read `:h table-mode`
for further information.

Demo:

<a href="http://www.youtube.com/watch?v=sK2IH1hiDkw"><img
src="https://raw.github.com/dhruvasagar/vim-table-mode/master/youtube.png"/></a>

# Credits

I must thank Tim Pope for inspiration. The initial concept was created by him
named <a href="https://gist.github.com/tpope/287147">cucumbertables.vim</a>.

Also a shout out to godlygeek who developed the incredible <a
href="http://github.com/godlygeek/tabular">Tabular</a> plugin which does most
of the grunt work behind the scenes.
