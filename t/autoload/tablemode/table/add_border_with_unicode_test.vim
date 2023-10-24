source t/config/options.vim
source t/utils.vim

let s:test_file = 't/fixtures/table/sample_for_header_unicode.txt'
function! s:setup()
  call utils#TestSetup(s:test_file)
endfunction
call testify#setup(function('s:setup'))
call testify#teardown(function('utils#TestTeardown'))

function! s:TestAddBorder()
  call tablemode#table#AddBorder(2)
  call tablemode#table#AddBorder(4)
  call tablemode#table#AddBorder(6)
  call tablemode#table#AddBorder(8)
  call tablemode#table#AddBorder(10)

  call testify#assert#assert(tablemode#table#IsHeader(3))

  call testify#assert#assert(tablemode#table#IsBorder(2))
  call testify#assert#assert(tablemode#table#IsBorder(4))
  call testify#assert#assert(tablemode#table#IsBorder(6))
  call testify#assert#assert(tablemode#table#IsBorder(8))
  call testify#assert#assert(tablemode#table#IsBorder(10))

  call testify#assert#equals(tablemode#utils#StrDisplayWidth(getline(2)), tablemode#utils#StrDisplayWidth(getline(3)))
  call testify#assert#equals(tablemode#utils#StrDisplayWidth(getline(3)), tablemode#utils#StrDisplayWidth(getline(4)))
  call testify#assert#equals(tablemode#utils#StrDisplayWidth(getline(4)), tablemode#utils#StrDisplayWidth(getline(5)))
  call testify#assert#equals(tablemode#utils#StrDisplayWidth(getline(5)), tablemode#utils#StrDisplayWidth(getline(6)))
  call testify#assert#equals(tablemode#utils#StrDisplayWidth(getline(6)), tablemode#utils#StrDisplayWidth(getline(7)))
  call testify#assert#equals(tablemode#utils#StrDisplayWidth(getline(7)), tablemode#utils#StrDisplayWidth(getline(8)))
  call testify#assert#equals(tablemode#utils#StrDisplayWidth(getline(8)), tablemode#utils#StrDisplayWidth(getline(9)))
  call testify#assert#equals(tablemode#utils#StrDisplayWidth(getline(9)), tablemode#utils#StrDisplayWidth(getline(10)))

  call utils#TestUndo(s:test_file)
endfunction
call testify#it('AddBorder should be able to add borders correctly with unicode characters', function('s:TestAddBorder'))
