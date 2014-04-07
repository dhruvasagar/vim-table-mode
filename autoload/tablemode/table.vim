" ==============================  Header ======================================
" File:          autoload/tablemode/table.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       https://github.com/dhruvasagar/vim-table-mode
" Version:       4.1.0
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
        \ '[' . g:table_mode_fillchar . g:table_mode_corner . ']*' .
        \ '[' . g:table_mode_corner . g:table_mode_corner_corner . ']' .
        \ tablemode#table#EndExpr()
endfunction

function! s:DefaultHeaderBorder() "{{{2
  if s:IsTableModeActive()
    return g:table_mode_corner_corner . g:table_mode_fillchar . g:table_mode_corner . g:table_mode_fillchar . g:table_mode_corner_corner
  else
    return ''
  endif
endfunction

function! s:GenerateHeaderBorder(line) "{{{2
  let line = tablemode#utils#line(a:line)
  if tablemode#table#IsATableRow(line - 1) || tablemode#table#IsATableRow(line + 1)
    let line_val = ''
    if tablemode#table#IsATableRow(line + 1)
      let line_val = getline(line + 1)
    endif
    if tablemode#table#IsATableRow(line - 1) && tablemode#utils#strlen(line_val) < tablemode#utils#strlen(getline(line - 1))
      let line_val = getline(line - 1)
    endif
    if tablemode#utils#strlen(line_val) <= 1 | return s:DefaultHeaderBorder() | endif
    let border = substitute(line_val[stridx(line_val, g:table_mode_separator):strridx(line_val, g:table_mode_separator)], g:table_mode_separator, g:table_mode_corner, 'g')
    let border = substitute(border, '[^' . g:table_mode_corner . ']', g:table_mode_fillchar, 'g')
    let border = substitute(border, '^' . g:table_mode_corner . '\(.*\)' . g:table_mode_corner . '$', g:table_mode_corner_corner . '\1' . g:table_mode_corner_corner, '')

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

function! tablemode#table#StartCommentExpr() "{{{2
  let cstartexpr = tablemode#table#GetCommentStart()
  if tablemode#utils#strlen(cstartexpr) > 0
    return '^\s*' . cstartexpr . '\s*'
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

function! tablemode#table#GetCommentStart() "{{{2
  let cstring = &commentstring
  if tablemode#utils#strlen(cstring) > 0
    return substitute(split(cstring, '%s')[0], '.', '\\\0', 'g')
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

function! tablemode#table#IsATableRow(line) "{{{2
  return getline(a:line) =~# (tablemode#table#StartExpr() . g:table_mode_separator . '[^' .
        \ g:table_mode_fillchar . ']*[^' . g:table_mode_corner . ']*$')
endfunction

function! tablemode#table#IsATableHeader(line) "{{{2
  return getline(a:line) =~# s:HeaderBorderExpr()
endfunction

function! tablemode#table#AddHeaderBorder(line) "{{{2
  call setline(a:line, s:GenerateHeaderBorder(a:line))
endfunction

function! tablemode#table#TableRealign(line) "{{{2
  let line = tablemode#utils#line(a:line)

  let [lnums, lines] = [[], []]
  let [tline, blines] = [line, []]
  while tablemode#table#IsATableRow(tline) || tablemode#table#IsATableHeader(tline)
    if tablemode#table#IsATableHeader(tline)
      call insert(blines, tline)
      let tline -= 1
      continue
    endif
    call insert(lnums, tline)
    call insert(lines, getline(tline))
    let tline -= 1
  endwhile

  let tline = line + 1

  while tablemode#table#IsATableRow(tline) || tablemode#table#IsATableHeader(tline)
    if tablemode#table#IsATableHeader(tline)
      call insert(blines, tline)
      let tline += 1
      continue
    endif
    call add(lnums, tline)
    call add(lines, getline(tline))
    let tline += 1
  endwhile

  let lines = tablemode#align#Align(lines)

  for lnum in lnums
    let index = index(lnums, lnum)
    call setline(lnum, lines[index])
  endfor

  for bline in blines
    call tablemode#table#AddHeaderBorder(bline)
  endfor
endfunction

function! tablemode#table#TableMotion(direction, ...) "{{{2
  let l:count = a:0 ? a:1 : v:count1
  if tablemode#table#IsATableRow('.')
    for ii in range(l:count)
      if a:direction ==# 'l'
        if tablemode#spreadsheet#IsLastCell()
          if !tablemode#table#IsATableRow(line('.') + 1) && (tablemode#table#IsATableHeader(line('.') + 1) && !tablemode#table#IsATableRow(line('.') + 2 * 1))
            return
          endif
          call tablemode#table#TableMotion('j', 1)
          normal! 0
        endif

        " If line starts with g:table_mode_separator
        if getline('.')[col('.')-1] ==# g:table_mode_separator
          normal! 2l
        else
          execute 'normal! f' . g:table_mode_separator . '2l'
        endif
      elseif a:direction ==# 'h'
        if tablemode#spreadsheet#IsFirstCell()
          if !tablemode#table#IsATableRow(line('.') - 1) && (tablemode#table#IsATableHeader(line('.') - 1) && !tablemode#table#IsATableRow(line('.') - 2 * 1))
            return
          endif
          call tablemode#table#TableMotion('k', 1)
          normal! $
        endif

        " If line ends with g:table_mode_separator
        if getline('.')[col('.')-1] ==# g:table_mode_separator
          execute 'normal! F' . g:table_mode_separator . '2l'
        else
          execute 'normal! 2F' . g:table_mode_separator . '2l'
        endif
      elseif a:direction ==# 'j'
        if tablemode#table#IsATableRow(line('.') + 1)
          execute 'normal! ' . 1 . 'j'
        elseif tablemode#table#IsATableHeader(line('.') + 1) && tablemode#table#IsATableRow(line('.') + 2)
          execute 'normal! ' . (1 + 1) . 'j'
        endif
      elseif a:direction ==# 'k'
        if tablemode#table#IsATableRow(line('.') - 1)
          execute 'normal! ' . 1 . 'k'
        elseif tablemode#table#IsATableHeader(line('.') - 1) && tablemode#table#IsATableRow(line('.') - 2)
          execute 'normal! ' . (1 + 1) . 'k'
        endif
      endif
    endfor
  endif
endfunction

" vim: sw=2 sts=2 fdl=0 fdm=marker
