source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/sample.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestRowCount()
  call testify#assert#equals(tablemode#spreadsheet#RowCount(3), 2)
  call testify#assert#equals(tablemode#spreadsheet#RowCount(4), 2)
endfunction
call testify#it('RowCount should return the correct row count', function('s:TestRowCount'))

function! s:TestRowNr()
  call testify#assert#equals(tablemode#spreadsheet#RowNr(3), 1)
  call testify#assert#equals(tablemode#spreadsheet#RowNr(4), 2)
endfunction
call testify#it('RowNr should return the correct row number', function('s:TestRowNr'))

function! s:TestColumnCount()
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount(3), 2)
  call testify#assert#equals(tablemode#spreadsheet#ColumnCount(4), 2)
endfunction
call testify#it('ColumnCount should return the correct column count', function('s:TestColumnCount'))

function! s:TestColumnNr()
  call cursor(3, 3)
  call testify#assert#equals(tablemode#spreadsheet#ColumnNr('.'), 1)

  call cursor(3, 12)
  call testify#assert#equals(tablemode#spreadsheet#ColumnNr('.'), 2)
endfunction
call testify#it('ColumnNr should return the correct column number', function('s:TestColumnNr'))

function! s:TestIsFirstCell()
  call cursor(3, 3)
  call testify#assert#assert(tablemode#spreadsheet#IsFirstCell())

  call cursor(3, 12)
  call testify#assert#assert(!tablemode#spreadsheet#IsFirstCell())
endfunction
call testify#it('IsFirstCell should return true when in the first cell', function('s:TestIsFirstCell'))

function! s:TestIsLastCell()
  call cursor(3, 3)
  call testify#assert#assert(!tablemode#spreadsheet#IsLastCell())

  call cursor(3, 12)
  call testify#assert#assert(tablemode#spreadsheet#IsLastCell())
endfunction
call testify#it('IsLastCell should return true when in the last cell', function('s:TestIsLastCell'))

function! s:TestGetFirstRow()
  call testify#assert#equals(tablemode#spreadsheet#GetFirstRow(3), 3)
  call testify#assert#equals(tablemode#spreadsheet#GetFirstRow(4), 3)
endfunction
call testify#it('GetFirstRow should return the line number of the first row', function('s:TestGetFirstRow'))

function! s:TestGetLastRow()
  call testify#assert#equals(tablemode#spreadsheet#GetLastRow(3), 4)
  call testify#assert#equals(tablemode#spreadsheet#GetLastRow(4), 4)
endfunction
call testify#it('GetLastRow should return the line number of the last row', function('s:TestGetLastRow'))
