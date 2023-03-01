source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/sample.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestDeleteRow()
  call cursor(3, 3)
  call testify#assert#equals(tablemode#spreadsheet#RowCount('.'), 2)
  call tablemode#spreadsheet#DeleteRow()
  call testify#assert#equals(tablemode#spreadsheet#RowCount('.'), 1)
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('DeleteRow should delete a row', function('s:TestDeleteRow'))

function! s:TestDeleteColumn()
  call cursor(3, 3)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 2)
  call tablemode#spreadsheet#DeleteColumn()
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 1)
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('DeleteColumn should delete a column', function('s:TestDeleteColumn'))

function! s:TestInsertColumn()
  call cursor(3, 3)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 2)
  call tablemode#spreadsheet#InsertColumn(0)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 3)
  " InsertColumn leaves us in insert mode
  stopinsert
  call testify#assert#equals(getline('.'), '|  | test11 | test12 |')
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('InsertColumn should insert a new column before the current column', function('s:TestInsertColumn'))

function! s:TestInserColumnAfter()
  call cursor(3, 3)
  normal! $
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 2)
  call tablemode#spreadsheet#InsertColumn(1)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 3)
  " InsertColumn leaves us in insert mode
  stopinsert
  call testify#assert#equals(getline('.'), '| test11 | test12 |  |')
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('InsertColumn should be able to insert a new column after the current column', function('s:TestInserColumnAfter'))
