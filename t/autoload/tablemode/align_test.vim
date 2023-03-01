source t/config/options.vim

function! ConvertLines2Dict(lines)
  let lines = []
  for idx in range(len(a:lines))
    call insert(lines, {"lnum": idx+1, "text": a:lines[idx]})
  endfor
  return lines
endfunction

function! s:TestAlignTable()
  let actual = tablemode#align#Align(ConvertLines2Dict(readfile('t/fixtures/align/simple_before.txt')))
  let expected = ConvertLines2Dict(readfile('t/fixtures/align/simple_after.txt'))
  call testify#assert#equals(actual, expected)
endfunction
call testify#it('Align should align table content', function('s:TestAlignTable'))

function! s:TestAlignTableUnicode()
  let actual = tablemode#align#Align(ConvertLines2Dict(readfile('t/fixtures/align/unicode_before.txt')))
  let expected = ConvertLines2Dict(readfile('t/fixtures/align/unicode_after.txt'))
  call testify#assert#equals(actual, expected)
endfunction
call testify#it('Align should align table content with unicode characters', function('s:TestAlignTableUnicode'))
