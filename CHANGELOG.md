# Change Log
## Version 3.3.2
* Added new mapping \t? to echo a cells representation for use while defining
  formulas.

## Version 3.3.1
* Improved logic to ignore table borders (add as many as you'd like), the
  first row is not treated special, it is row # 1. Keep that in mind while
  defining Formulas
* Improved test coverage

## Version 3.3
* Dropped +- mapping to create table border instead now using ||
* You can now have a top table border (before header) as well as a bottom
  table border.

## Version 3.2
* Added tests to test various use cases using <a
  href='https://github.com/kana/vim-vspec'>Vspec</a>..
* Added travis integration for automated tests.

## Version 3.1
* Removed borders. You can now optionally create a table header by simply
  adding a header border immidiately after the header line by using the
  iabbrev trigger '+-'. Just type that on the line immidiately after the
  header and press space / \<CR\> to complete the header border.
* Some Bug Fixes

## Version 3.0
* Removed dependence on Tabular and added code borrowed from Tabular for
  aligning the table rows.
* Added feature to be able to define & evaluate formulas.

## Version 2.4.0
* Added Table Cell text object.
* Added api to delete entire table row.
* Added api to delete entire table column.

## Version 2.3.0
* Refactored realignment logic. Generating borders by hand.

## Version 2.2.2
* Added mapping for realigning table columns.
* Added table motions to move around in the table.

## Version 2.2.1
* Added feature to allow Table-Mode to work within comments. Uses
  'commentstring' option of vim to identify comments, so it should work for
  most filetypes as long as 'commentstring' option has been set. This is
  usually done appropriately in filetype plugins.

## Version 2.2
* Improved :Tableize to now accept a {pattern} just like :Tabular to match the
  delimiter.

## Version 2.1.3 :
* Bug Fix #1, added new option `g:table_mode_no_border_padding` which removes
  padding from the border.

## Version 2.1.2 :
* Bug Fixes #2, #3 & #4

## Version 2.1.1 :
* Added option `g:table_mode_align` to allow setting Tabular format option for
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
