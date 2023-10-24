source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/tableize.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestTabelize()
  :3,4call tablemode#TableizeRange('')
  call testify#assert#assert(tablemode#table#IsRow(3))
  call testify#assert#equals(tablemode#spreadsheet#RowCount(3), 2)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount(3), 3)
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('Tableize should tableize with default delimiter correctly', function('s:TestTabelize'))

function! s:TestTabelizeCustomDelimiter()
  :3,4call tablemode#TableizeRange('/;')
  call testify#assert#assert(tablemode#table#IsRow(3))
  call testify#assert#equals(tablemode#spreadsheet#RowCount(3), 2)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount(3), 2)
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('Tableize should tableize with custom delimiter correctly', function('s:TestTabelizeCustomDelimiter'))
