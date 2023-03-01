source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/formula/formula.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestEvalFormula()
  call cursor(7, 15)
  call tablemode#spreadsheet#formula#EvaluateFormulaLine()
  call testify#assert#equals(&modified, 1)
  let cell_value = tablemode#spreadsheet#cell#GetCell()
  call testify#assert#equals(cell_value, '125.0')
endfunction
call testify#it('Should evaluate the formula correctly', function('s:TestEvalFormula'))
