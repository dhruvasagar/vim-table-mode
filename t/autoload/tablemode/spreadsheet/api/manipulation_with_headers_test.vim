source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/complex_header.txt'
function! s:setup()
  let g:table_mode_header_fillchar = '='
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))

function! s:teardown()
  let g:table_mode_header_fillchar = '-'
  bw!
endfunction
call testify#teardown(function('s:teardown'))

function! s:TestDeleteRow()
  call cursor(5, 7)
  call testify#assert#equals(tablemode#spreadsheet#RowCount('.'), 5)
  call tablemode#spreadsheet#DeleteRow()
  call testify#assert#equals(tablemode#spreadsheet#RowCount('.'), 4)
  call testify#assert#equals(getline(5), '|     2    | 8        |        b | y        |')
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('DeleteRow should delete a row in a table with headers', function('s:TestDeleteRow'))

function! s:TestDeleteColumn()
  call cursor(5, 7)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 4)
  call tablemode#spreadsheet#DeleteColumn()
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 3)
  call testify#assert#equals(getline(5), '| 9        |        a | z        |')
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('DeleteColumn should delete a column in a table with headers', function('s:TestDeleteColumn'))

function! s:TestInsertColumn()
  call cursor(5, 7)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 4)
  call tablemode#spreadsheet#InsertColumn(0)
  stopinsert
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 5)
  call testify#assert#equals(getline(5), '|  |     1    | 9        |        a | z        |')
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('InsertColumn should insert a new column before the current column in a table with headers in a table with headers', function('s:TestInsertColumn'))

function! s:TestInserColumnAfter()
  call cursor(5, 7)
  normal! $
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 4)
  call tablemode#spreadsheet#InsertColumn(1)
  stopinsert
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount('.'), 5)
  call testify#assert#equals(getline(5), '|     1    | 9        |        a | z        |  |')
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('InsertColumn should be able to insert a new column after the current column in a table with headers', function('s:TestInserColumnAfter'))
