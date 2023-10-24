source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/table//sample_realign_unicode_after.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestDeleteRow()
  call cursor(3, 19)
  call testify#assert#equals(tablemode#spreadsheet#RowCount('.'), 4)
  call tablemode#spreadsheet#DeleteRow()
  call testify#assert#equals(tablemode#spreadsheet#RowCount('.'), 3)
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('DeleteRow should be able to delete a row with unicode characters', function('s:TestDeleteRow'))

function! s:TestDeleteColumn()
  call cursor(3, 19)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 3)
  call tablemode#spreadsheet#DeleteColumn()
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 2)
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('DeleteColumn should be able to delete a column with unicode characters', function('s:TestDeleteColumn'))

function! s:TestInsertColumnBefore()
  call cursor(3, 19)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 3)
  call tablemode#spreadsheet#InsertColumn(0)
  stopinsert
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 4)
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('InsertColumn should be able to insert a column before the current column with unicode characters', function('s:TestInsertColumnBefore'))

function! s:TestInsertColumnAfter()
  call cursor(3, 19)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 3)
  call tablemode#spreadsheet#InsertColumn(1)
  stopinsert
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 4)
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('InsertColumn should be able to insert a column after the current column with unicode characters', function('s:TestInsertColumnAfter'))
