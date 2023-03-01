function! utils#TestSetup(file) abort
  new
  silent! exec 'read' a:file
endfunction

function! utils#TestTeardown() abort
  bw!
endfunction

function! utils#TestUndo(file) abort
  :%delete
  silent! exec 'read' a:file
endfunction

function! utils#TableTest(tests) abort
  for test in a:tests
    call testify#assert#equals(test.actual, test.expected)
  endfor
endfunction
