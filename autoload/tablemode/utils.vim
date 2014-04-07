" Private Functions {{{1

" Public Functions {{{1
function! tablemode#utils#sid() "{{{2
  return maparg('<sid>', 'n')
endfunction
nnoremap <sid> <sid>

function! tablemode#utils#scope() "{{{2
  return s:
endfunction

function! tablemode#utils#throw(string) abort "{{{2
  let v:errmsg = 'table-mode: ' . a:string
  throw v:errmsg
endfunction

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

" function! tablemode#utils#strlen {{{2
" To count multibyte characters accurately
function! tablemode#utils#strlen(text)
  return strlen(substitute(a:text, '.', 'x', 'g'))
endfunction
