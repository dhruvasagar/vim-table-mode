source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/table/sample_with_header.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestIsHeader()
  call testify#assert#assert(tablemode#table#IsHeader(3))

  call testify#assert#assert(!tablemode#table#IsHeader(1))
  call testify#assert#assert(!tablemode#table#IsHeader(2))
  call testify#assert#assert(!tablemode#table#IsHeader(4))
  call testify#assert#assert(!tablemode#table#IsHeader(5))
  call testify#assert#assert(!tablemode#table#IsHeader(6))
  call testify#assert#assert(!tablemode#table#IsHeader(7))
endfunction
call testify#it('IsHeader should be correct', function('s:TestIsHeader'))
