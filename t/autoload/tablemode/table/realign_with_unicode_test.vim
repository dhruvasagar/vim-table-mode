source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/table/sample_realign_unicode_before.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestRealign()
  call tablemode#table#Realign(2)
  call testify#assert#equals(getline(2, '$'), readfile('t/fixtures/table/sample_realign_unicode_after.txt'))
  call utils#TestUndo(s:test_file)
endfunction
call testify#it('Realign should align table properly with unicode characters', function('s:TestRealign'))
