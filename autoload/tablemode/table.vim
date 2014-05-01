" ==============================  Header ======================================
" File:          autoload/tablemode/table.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       https://github.com/dhruvasagar/vim-table-mode
" Note:          This plugin was heavily inspired by the 'CucumberTables.vim'
"                (https://gist.github.com/tpope/287147) plugin by Tim Pope.
"
" Copyright Notice:
"                Permission is hereby granted to use and distribute this code,
"                with or without modifications, provided that this copyright
"                notice is copied with it. Like anything else that's free,
"                table-mode.vim is provided *as is* and comes with no warranty
"                of any kind, either expressed or implied. In no event will
"                the copyright holder be liable for any damamges resulting
"                from the use of this software.
" =============================================================================

" Private Functions {{{1
function! s:HeaderBorderExpr() "{{{2
  return tablemode#table#StartExpr() .
        \ '[' . g:table_mode_corner . g:table_mode_corner_corner . ']' .
        \ '[' . g:table_mode_fillchar . g:table_mode_corner . g:table_mode_align_char . ']*' .
        \ '[' . g:table_mode_corner . g:table_mode_corner_corner . ']' .
        \ tablemode#table#EndExpr()
endfunction

function! s:DefaultHeaderBorder() "{{{2
  if tablemode#IsActive()
    return g:table_mode_corner_corner . g:table_mode_fillchar . g:table_mode_corner . g:table_mode_fillchar . g:table_mode_corner_corner
  else
    return ''
  endif
endfunction

function! s:GenerateHeaderBorder(line) "{{{2
  let line = tablemode#utils#line(a:line)
  if tablemode#table#IsRow(line - 1) || tablemode#table#IsRow(line + 1)
    let line_val = ''
    if tablemode#table#IsRow(line + 1)
      let line_val = getline(line + 1)
    endif
    if tablemode#table#IsRow(line - 1) && tablemode#utils#strlen(line_val) < tablemode#utils#strlen(getline(line - 1))
      let line_val = getline(line - 1)
    endif
    if tablemode#utils#strlen(line_val) <= 1 | return s:DefaultHeaderBorder() | endif

    let border = substitute(line_val[stridx(line_val, g:table_mode_separator):strridx(line_val, g:table_mode_separator)], g:table_mode_separator, g:table_mode_corner, 'g')
    " To accurately deal with unicode double width characters
    let fill_columns = map(split(border, g:table_mode_corner),  'repeat(g:table_mode_fillchar, tablemode#utils#StrDisplayWidth(v:val))')
    let border = g:table_mode_corner . join(fill_columns, g:table_mode_corner) . g:table_mode_corner
    let border = substitute(border, '^' . g:table_mode_corner . '\(.*\)' . g:table_mode_corner . '$', g:table_mode_corner_corner . '\1' . g:table_mode_corner_corner, '')

    " Incorporate header alignment chars
    if getline(line) =~# g:table_mode_align_char
      let pat = '[' . g:table_mode_corner_corner . g:table_mode_corner . ']'
      let hcols = tablemode#align#Split(getline(line), pat)
      let gcols = tablemode#align#Split(border, pat)

      for idx in range(len(hcols))
        if hcols[idx] =~# g:table_mode_align_char
          if hcols[idx] =~# g:table_mode_align_char . '$'
            let gcols[idx] = gcols[idx][:-2] . g:table_mode_align_char
          else
            let gcols[idx] = g:table_mode_align_char . gcols[idx][1:]
          endif
        endif
      endfor
      let border = join(gcols, '')
    endif

    let cstartexpr = tablemode#table#StartCommentExpr()
    if tablemode#utils#strlen(cstartexpr) > 0 && getline(line) =~# cstartexpr
      let sce = matchstr(line_val, tablemode#table#StartCommentExpr())
      let ece = matchstr(line_val, tablemode#table#EndCommentExpr())
      return sce . border . ece
    elseif getline(line) =~# tablemode#table#StartExpr()
      let indent = matchstr(line_val, tablemode#table#StartExpr())
      return indent . border
    else
      return border
    endif
  else
    return s:DefaultHeaderBorder()
  endif
endfunction

" Public Functions {{{1
function! tablemode#table#sid() "{{{2
  return maparg('<sid>', 'n')
endfunction
nnoremap <sid> <sid>

function! tablemode#table#scope() "{{{2
  return s:
endfunction

function! tablemode#table#GetCommentStart() "{{{2
  let cstring = &commentstring
  if tablemode#utils#strlen(cstring) > 0
    return substitute(split(cstring, '%s')[0], '.', '\\\0', 'g')
  else
    return ''
  endif
endfunction

function! tablemode#table#StartCommentExpr() "{{{2
  let cstartexpr = tablemode#table#GetCommentStart()
  if tablemode#utils#strlen(cstartexpr) > 0
    return '^\s*' . cstartexpr . '\s*'
  else
    return ''
  endif
endfunction

function! tablemode#table#GetCommentEnd() "{{{2
  let cstring = &commentstring
  if tablemode#utils#strlen(cstring) > 0
    let cst = split(cstring, '%s')
    if len(cst) == 2
      return substitute(cst[1], '.', '\\\0', 'g')
    else
      return ''
    endif
  else
    return ''
  endif
endfunction

function! tablemode#table#EndCommentExpr() "{{{2
  let cendexpr = tablemode#table#GetCommentEnd()
  if tablemode#utils#strlen(cendexpr) > 0
    return '.*\zs\s\+' . cendexpr . '\s*$'
  else
    return ''
  endif
endfunction

function! tablemode#table#StartExpr() "{{{2
  let cstart = tablemode#table#GetCommentStart()
  if tablemode#utils#strlen(cstart) > 0
    return '^\s*\(' . cstart . '\)\?\s*'
  else
    return '^\s*'
  endif
endfunction

function! tablemode#table#EndExpr() "{{{2
  let cend = tablemode#table#GetCommentEnd()
  if tablemode#utils#strlen(cend) > 0
    return '\s*\(\s\+' . cend . '\)\?\s*$'
  else
    return '\s*$'
  endif
endfunction

function! tablemode#table#IsBorder(line) "{{{2
  return getline(a:line) =~# s:HeaderBorderExpr()
endfunction

function! tablemode#table#IsHeader(line) "{{{2
  let line = tablemode#utils#line(a:line)
  return tablemode#table#IsBorder(line+1) && !tablemode#table#IsRow(line-1) && !tablemode#table#IsRow(line-2)
endfunction

function! tablemode#table#IsRow(line) "{{{2
  return !tablemode#table#IsBorder(a:line) && getline(a:line) =~# (tablemode#table#StartExpr() . g:table_mode_separator)
endfunction

function! tablemode#table#AddBorder(line) "{{{2
  call setline(a:line, s:GenerateHeaderBorder(a:line))
endfunction

function! tablemode#table#Realign(line) "{{{2
  let line = tablemode#utils#line(a:line)

  let lines = []
  let [lnum, blines] = [line, []]
  while tablemode#table#IsRow(lnum) || tablemode#table#IsBorder(lnum)
    if tablemode#table#IsBorder(lnum)
      call insert(blines, lnum)
      let lnum -= 1
      continue
    endif
    call insert(lines, {'lnum': lnum, 'text': getline(lnum)})
    let lnum -= 1
  endwhile

  let lnum = line + 1
  while tablemode#table#IsRow(lnum) || tablemode#table#IsBorder(lnum)
    if tablemode#table#IsBorder(lnum)
      call add(blines, lnum)
      let lnum += 1
      continue
    endif
    call add(lines, {'lnum': lnum, 'text': getline(lnum)})
    let lnum += 1
  endwhile

  let lines = tablemode#align#Align(lines)

  for aline in lines
    call setline(aline.lnum, aline.text)
  endfor

  for bline in blines
    call tablemode#table#AddBorder(bline)
  endfor
endfunction
