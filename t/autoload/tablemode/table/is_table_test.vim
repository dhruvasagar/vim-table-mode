source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/table/sample_with_header.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestIsTable()
  " when on row
  call testify#assert#assert(tablemode#table#IsTable(2))
  call testify#assert#assert(tablemode#table#IsTable(4))
  call testify#assert#assert(tablemode#table#IsTable(7))

  " when on border
  call testify#assert#assert(tablemode#table#IsTable(3))
  call testify#assert#assert(tablemode#table#IsTable(5))
  call testify#assert#assert(tablemode#table#IsTable(6))

  " when not in a table
  call testify#assert#assert(!tablemode#table#IsTable(1))
endfunction
call testify#it('IsTable should be correct', function('s:TestIsTable'))
