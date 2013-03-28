# Change Log
## Version 2.2
* Improved :Tableize to now accept a {pattern} just like :Tabular to match the
  delimiter.

## Version 2.1.3 :
* Bug Fix #1, added new option `g:table_mode_no_border_padding` which removes
  padding from the border.

## Version 2.1.2 :
* Bug Fixes #2, #3 & #4

## Version 2.1.1 :
* Added option g:table_mode_align to allow setting Tabular format option for
  more control on how Tabular aligns text.

## Version 2.1 :
* VIM loads plugins in alphabetical order and so table-mode would be loaded
  before Tabularize which it depends on. Hence Moved plugin into an after
  plugin. Checking if Tabularize is available and finish immidiately if it's
  not.

## Version 2.0 :
* Moved bulk of code to autoload for vimscript optimisation.

## Version 1.1 :
* Added Tableize command and mapping to convert existing content into a table.

## Version 1.0 :
* First stable release, create tables as you type.
