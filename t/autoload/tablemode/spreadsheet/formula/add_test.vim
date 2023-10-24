source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/formula/sample.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestAddFormula()
  call cursor(7, 15)
  call tablemode#spreadsheet#formula#Add('Sum(1:3)')
  let cell_value = tablemode#spreadsheet#cell#GetCell()
  call testify#assert#equals(cell_value, '125.0')

  call cursor(9, 15)
  call testify#assert#equals(getline('.'), ' tmf: $4,2=Sum(1:3) ')

  call cursor(8, 15)
  call tablemode#spreadsheet#formula#Add('Sum(1:-1)')
  let cell_value = tablemode#spreadsheet#cell#GetCell()
  call testify#assert#equals(cell_value, '250.0')

  call cursor(9, 15)
  call testify#assert#equals(getline('.'), ' tmf: $4,2=Sum(1:3) ; $5,2=Sum(1:-1)')
endfunction
call testify#it('Should Add a formula to the table correctly', function('s:TestAddFormula'))
