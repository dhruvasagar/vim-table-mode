source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/table/sample_for_header.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestAddBorder()
  call testify#assert#assert(!tablemode#table#IsHeader(2))
  call tablemode#table#AddBorder(3)
  call testify#assert#assert(tablemode#table#IsHeader(2))
  call testify#assert#assert(tablemode#table#IsBorder(3))
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('AddBorder should be able to add borders correctly', function('s:TestAddBorder'))
