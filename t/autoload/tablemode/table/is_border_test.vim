source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/table/sample_with_header.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestIsBorder()
  call testify#assert#assert(tablemode#table#IsBorder(2))
  call testify#assert#assert(tablemode#table#IsBorder(4))
  call testify#assert#assert(tablemode#table#IsBorder(7))

  call testify#assert#assert(!tablemode#table#IsBorder(1))
  call testify#assert#assert(!tablemode#table#IsBorder(3))
  call testify#assert#assert(!tablemode#table#IsBorder(5))
  call testify#assert#assert(!tablemode#table#IsBorder(6))
endfunction
call testify#it('IsBorder should be correct', function('s:TestIsBorder'))
