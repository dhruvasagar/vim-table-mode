source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/cell/sample.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestSum()
  call cursor(3, 3)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#Sum('1:2'),
        \   'expected': 4.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Sum('1,1:1,2'),
        \   'expected': 3.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Sum('1,1:2,2'),
        \   'expected': 10.0
        \ },
        \]
  call utils#TableTest(tests)

  call cursor(4, 7)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#Sum('1:2'),
        \   'expected': 6.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Sum('2,1:2,2'),
        \   'expected': 7.0
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('Sum should return the sum of cell range', function('s:TestSum'))

function! s:TestAverage()
  call cursor(3, 3)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#Average('1:2'),
        \   'expected': 2.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Average('1,1:1,2'),
        \   'expected': 1.5
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Average('1,1:2,2'),
        \   'expected': 2.5
        \ },
        \]
  call utils#TableTest(tests)

  call cursor(4, 7)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#Average('1:2'),
        \   'expected': 3.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Average('2,1:2,2'),
        \   'expected': 3.5
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('Average should return the average of cell range', function('s:TestAverage'))

function! s:TestMin()
  call cursor(3, 3)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#Min('1:2'),
        \   'expected': 1.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Min('1,1:1,2'),
        \   'expected': 1.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Min('1,1:2,2'),
        \   'expected': 1.0
        \ },
        \]
  call utils#TableTest(tests)

  call cursor(4, 7)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#Min('1:2'),
        \   'expected': 2.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Min('2,1:2,2'),
        \   'expected': 3.0
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('Min should return the min of cell range', function('s:TestMin'))

function! s:TestMax()
  call cursor(3, 3)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#Max('1:2'),
        \   'expected': 3.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Max('1,1:1,2'),
        \   'expected': 2.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Max('1,1:2,2'),
        \   'expected': 4.0
        \ },
        \]
  call utils#TableTest(tests)

  call cursor(4, 7)
  let tests = [
        \ {
        \   'actual': tablemode#spreadsheet#Max('1:2'),
        \   'expected': 4.0
        \ },
        \ {
        \   'actual': tablemode#spreadsheet#Max('2,1:2,2'),
        \   'expected': 4.0
        \ },
        \]
  call utils#TableTest(tests)
endfunction
call testify#it('Max should return the max of cell range', function('s:TestMax'))
