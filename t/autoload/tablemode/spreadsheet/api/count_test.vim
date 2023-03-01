source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/cell/counts.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestCountE()
  call cursor(3, 3)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#CountE('1:3'),
        \   'expected': 1,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#CountE('1,1:1,3'),
        \   'expected': 0,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#CountE('2,1:2,3'),
        \   'expected': 2,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#CountE('1,1:3,3'),
        \   'expected': 2,
        \ },
        \]
  call utils#TableTest(tests)

  call cursor(5, 11)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#CountE('1:3'),
        \   'expected': 1,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#CountE('3,1:3,3'),
        \   'expected': 0,
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('CountE should return the count of empty cells within cell range', function('s:TestCountE'))

function! s:TestCountNE()
  call cursor(3, 3)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#CountNE('1:3'),
        \   'expected': 2,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#CountNE('1,1:1,3'),
        \   'expected': 3,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#CountNE('2,1:2,3'),
        \   'expected': 1,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#CountNE('1,1:3,3'),
        \   'expected': 7,
        \ },
        \]
  call utils#TableTest(tests)

  call cursor(5, 11)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#CountNE('1:3'),
        \   'expected': 2,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#CountNE('3,1:3,3'),
        \   'expected': 3,
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('CountNE should return the count of non-empty cells within cell range', function('s:TestCountNE'))

function! s:TestPercentE()
  call cursor(3, 3)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#PercentE('1:3'),
        \   'expected': 33,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#PercentE('1,1:1,3'),
        \   'expected': 0,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#PercentE('2,1:2,3'),
        \   'expected': 66,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#PercentE('1,1:3,3'),
        \   'expected': 22,
        \ },
        \]
  call utils#TableTest(tests)

  call cursor(5, 11)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#PercentE('1:3'),
        \   'expected': 33,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#PercentE('3,1:3,3'),
        \   'expected': 0,
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('PercentE should return the percent count of empty cells within cell range', function('s:TestPercentE'))

function! s:TestPercentNE()
  call cursor(3, 3)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#PercentNE('1:3'),
        \   'expected': 66,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#PercentNE('1,1:1,3'),
        \   'expected': 100,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#PercentNE('2,1:2,3'),
        \   'expected': 33,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#PercentNE('1,1:3,3'),
        \   'expected': 77,
        \ },
        \]
  call utils#TableTest(tests)

  call cursor(5, 11)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#PercentNE('1:3'),
        \   'expected': 66,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#PercentNE('3,1:3,3'),
        \   'expected': 100,
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('PercentNE should return the percent count of non-empty cells within cell range', function('s:TestPercentNE'))

function! s:TestAverageNE()
  call cursor(3, 3)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#AverageNE('1:3'),
        \   'expected': 2.5,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#AverageNE('1,1:1,3'),
        \   'expected': 2.0,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#AverageNE('2,1:2,3'),
        \   'expected': 0.0,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#AverageNE('1,1:3,3'),
        \   'expected': 3.0,
        \ },
        \]
  call utils#TableTest(tests)

  call cursor(5, 11)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#AverageNE('1:3'),
        \   'expected': 4.5,
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#AverageNE('3,1:3,3'),
        \   'expected': 5.0,
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('AverageNE should return the average of non-empty cells within cell range', function('s:TestAverageNE'))
