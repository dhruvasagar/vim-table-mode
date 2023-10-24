source t/config/options.vim
source t/utils.vim

function! s:setup()
  call utils#TestSetup('t/fixtures/sample.txt')
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestGetCells()
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCells(3, 1, 1),
        \   'expected': 'test11'
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCells(3, 1),
        \   'expected': ['test11', 'test12']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCells(3, 2),
        \   'expected': ['test21', 'test22']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCells(3, 0, 1),
        \   'expected': ['test11', 'test21']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCells(3, 0, 2),
        \   'expected': ['test12', 'test22']
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('GetCells should return correct cell value', function('s:TestGetCells'))

function! s:TestGetRow()
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetRow(1, 3),
        \   'expected': ['test11', 'test12']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetRow(2, 3),
        \   'expected': ['test21', 'test22']
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('GetRow should return the row', function('s:TestGetRow'))

function! s:TestGetColumn()
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetColumn(1, 3),
        \   'expected': ['test11', 'test21']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetRow(2, 3),
        \   'expected': ['test21', 'test22']
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('GetColumn should return the column', function('s:TestGetColumn'))

function! s:TestGetCellRange()
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1,1:2,2', 3, 1),
        \   'expected': [['test11', 'test21'], ['test12', 'test22']]
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1,1:1,2', 3, 1),
        \   'expected': ['test11', 'test12']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1,1:1,2', 3, 2),
        \   'expected': ['test11', 'test12']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1,1:1,2', 4, 1),
        \   'expected': ['test11', 'test12']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1,1:1,2', 4, 2),
        \   'expected': ['test11', 'test12']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('2,1:2,2', 3, 1),
        \   'expected': ['test21', 'test22']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('2,1:2,2', 3, 2),
        \   'expected': ['test21', 'test22']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('2,1:2,2', 4, 1),
        \   'expected': ['test21', 'test22']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('2,1:2,2', 4, 2),
        \   'expected': ['test21', 'test22']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1:2', 3, 1),
        \   'expected': ['test11', 'test21']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1:2', 3, 2),
        \   'expected': ['test12', 'test22']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1:2', 4, 1),
        \   'expected': ['test11', 'test21']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1:2', 4, 2),
        \   'expected': ['test12', 'test22']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1:-1', 3, 1),
        \   'expected': ['test11']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1:-1', 4, 1),
        \   'expected': ['test11']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1:-1', 3, 2),
        \   'expected': ['test12']
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#cell#GetCellRange('1:-1', 4, 2),
        \   'expected': ['test12']
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('GetCellRange should return the cell values in given range', function('s:TestGetCellRange'))

function! s:TestLeftMotion()
  call cursor(3, 12)
  call testify#assert#equals(tablemode#spreadsheet#ColumnNr('.'), 2)
  call tablemode#spreadsheet#cell#Motion('h')
  call testify#assert#equals(tablemode#spreadsheet#ColumnNr('.'), 1)
endfunction
call testify#it('Motion "h" should move cursor to the left column', function('s:TestLeftMotion'))

function! s:TestLeftMotionFirstColumn() abort
  call cursor(4, 3)
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 2)
  call testify#assert#equals(tablemode#spreadsheet#ColumnNr('.'), 1)
  call tablemode#spreadsheet#cell#Motion('h')
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 1)
  call testify#assert#equals(tablemode#spreadsheet#ColumnNr('.'), 2)
endfunction
call testify#it('Motion "h" should move cursor to the last column of previous row when on first column', function('s:TestLeftMotionFirstColumn'))

function! s:TestRightMotion()
  call cursor(3, 3)
  call testify#assert#equals(tablemode#spreadsheet#ColumnNr('.'), 1)
  call tablemode#spreadsheet#cell#Motion('l')
  call testify#assert#equals(tablemode#spreadsheet#ColumnNr('.'), 2)
endfunction
call testify#it('Motion "l" should move cursor to the right column', function('s:TestRightMotion'))

function! s:TestRightMotionLastColumn()
  call cursor(3, 12)
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 1)
  call testify#assert#equals(tablemode#spreadsheet#ColumnNr('.'), 2)
  call tablemode#spreadsheet#cell#Motion('l')
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 2)
  call testify#assert#equals(tablemode#spreadsheet#ColumnNr('.'), 1)
endfunction
call testify#it('Motion "l" should move cursor to the first column of next row when on last column', function('s:TestRightMotionLastColumn'))

function! s:TestUpMotion()
  call cursor(4, 3)
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 2)
  call tablemode#spreadsheet#cell#Motion('k')
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 1)
endfunction
call testify#it('Motion "k" should move cursor to the column above', function('s:TestUpMotion'))

function! s:TestUpMotionFirstRow()
  call cursor(3, 3)
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 1)
  call tablemode#spreadsheet#cell#Motion('k')
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 1)
endfunction
call testify#it('Motion "k" should remain on first row when trying to move up', function('s:TestUpMotionFirstRow'))

function! s:TestDownMotion()
  call cursor(3, 3)
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 1)
  call tablemode#spreadsheet#cell#Motion('j')
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 2)
endfunction
call testify#it('Motion "j" should move cursor to the column above', function('s:TestDownMotion'))

function! s:TestDownMotionFirstRow()
  call cursor(4, 3)
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 2)
  call tablemode#spreadsheet#cell#Motion('j')
  call testify#assert#equals(tablemode#spreadsheet#RowNr('.'), 2)
endfunction
call testify#it('Motion "j" should remain on last row when trying to move down', function('s:TestDownMotionFirstRow'))
