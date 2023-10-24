source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/table/sample.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestIsRow()
  call testify#assert#assert(tablemode#table#IsRow(3))
  call testify#assert#assert(tablemode#table#IsRow(4))

  call testify#assert#assert(!tablemode#table#IsRow(1))
  call testify#assert#assert(!tablemode#table#IsRow(5))
endfunction
call testify#it('IsRow should be correct', function('s:TestIsRow'))
