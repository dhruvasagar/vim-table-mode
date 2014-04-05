" Private Functions {{{1

" Public Functions {{{1
function! tablemode#utils#line(row) "{{{2
  if type(a:row) == type('')
    return line(a:row)
  else
    return a:row
  endif
endfunction

function! tablemode#utils#strip(string) "{{{2
  return matchstr(a:string, '^\s*\zs.\{-}\ze\s*$')
endfunction

" To count multibyte characters accurately {{{2
function! tablemode#utils#strlen(text)
  return strlen(substitute(a:text, '.', 'x', 'g'))
endfunction
