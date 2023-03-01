source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/big_sample.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestDeleteRowWithRange()
  call cursor(3, 3)
  call testify#assert#equals(tablemode#spreadsheet#RowCount('.'), 5)
  .,.+1 call tablemode#spreadsheet#DeleteRow()
  call testify#assert#equals(tablemode#spreadsheet#RowCount('.'), 3)
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('DeleteRow should work with a range', function('s:TestDeleteRowWithRange'))

function! s:TestDeleteColumnWithRange()
  call cursor(3, 3)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 4)
  .,.+1 call tablemode#spreadsheet#DeleteColumn()
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 2)
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('DeleteColumn should work with a range', function('s:TestDeleteColumnWithRange'))

function! s:TestInsertColumnWithCountBefore()
  call cursor(3, 7)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 4)
  execute "normal! 2:\<C-U>call tablemode#spreadsheet#InsertColumn(0)\<CR>"
  stopinsert
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 6)
  call testify#assert#equals(getline('.'), '| 1 |  |  | 9 | a | z |')
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('InsertColumn should work with a count to add columns before current column', function('s:TestInsertColumnWithCountBefore'))

function! s:TestInsertColumnWithCountAfter()
  call cursor(3, 7)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 4)
  execute "normal! 2:\<C-U>call tablemode#spreadsheet#InsertColumn(1)\<CR>"
  stopinsert
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 6)
  call testify#assert#equals(getline('.'), '| 1 | 9 |  |  | a | z |')
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('InsertColumn should work with a count to add columns after current column', function('s:TestInsertColumnWithCountAfter'))
