" =============================================================================
" File:          autoload/tablemode.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       http://github.com/dhruvasagar/vim-table-mode
" Version:       2.4.0
" Note:          This plugin was heavily inspired by the 'CucumberTables.vim'
"                (https://gist.github.com/tpope/287147) plugin by Tim Pope and
"                uses a small amount of code from it.
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

function! s:SetBufferOptDefault(opt, val) "{{{2
  if !exists('b:' . a:opt)
    let b:{a:opt} = a:val
  endif
endfunction
" }}}2

" s:Strlen(text) For counting multibyte characters accurately {{{2
" See :h strlen() for more details
function! s:Strlen(text)
  return strlen(substitute(a:text, '.', 'x', 'g'))
endfunction
" }}}2

function! s:GetCommentStart() "{{{2
  let cstring = &commentstring
  if s:Strlen(cstring) > 0
    return substitute(split(substitute(cstring, '%s', ' ', 'g'))[0], '.', '\\\0', 'g')
  else
    return ''
  endif
endfunction
" }}}2

function! s:StartExpr() "{{{2
  let cstart = s:GetCommentStart()
  if s:Strlen(cstart) > 0
    return '^\s*\(' . cstart . '\)\?\s*'
  else
    return '^\s*'
  endif
endfunction
" }}}2

function! s:StartCommentExpr() "{{{2
  let cstartexpr = s:GetCommentStart()
  if s:Strlen(cstartexpr) > 0
    return '^\s*' . cstartexpr . '\s*'
  else
    return ''
  endif
endfunction
" }}}2

function! s:IsTableModeActive() "{{{2
  if g:table_mode_always_active | return 1 | endif

  call s:SetBufferOptDefault('table_mode_active', 0)
  return b:table_mode_active
endfunction
" }}}2

function! s:ToggleMapping() "{{{2
  if exists('b:table_mode_active') && b:table_mode_active
    call s:SetBufferOptDefault('table_mode_separator_map', g:table_mode_separator)
    " '|' is a special character, we need to map <Bar> instead
    if g:table_mode_separator ==# '|' | let b:table_mode_separator_map = '<Bar>' | endif

    execute "inoremap <silent> <buffer> " . b:table_mode_separator_map . ' ' .
          \ b:table_mode_separator_map . "<Esc>:call tablemode#TableizeInsertMode()<CR>a"
  else
    execute "iunmap <silent> <buffer> " . b:table_mode_separator_map
  endif
endfunction
" }}}2

function! s:SetActive(bool) "{{{2
  let b:table_mode_active = a:bool
  call s:ToggleMapping()
endfunction
" }}}2

function! s:Line(line) "{{{2
  if type(a:line) == type('')
    return line(a:line)
  else
    return a:line
  endif
endfunction
" }}}2

function! s:GenerateBorder(line) "{{{2
  let line = s:Line(a:line)

  let border = substitute(getline(line)[stridx(getline(line), g:table_mode_separator):-1], g:table_mode_separator, g:table_mode_corner, 'g')
  let border = substitute(border, '[^' . g:table_mode_corner . ']', g:table_mode_fillchar, 'g')

  let cstartexpr = s:StartCommentExpr()
  if s:Strlen(cstartexpr) > 0 && getline(line) =~# cstartexpr
    let indent = matchstr(getline(line), s:StartCommentExpr())
    return indent . border
  elseif getline(line) =~# s:StartExpr()
    let indent = matchstr(getline(line), s:StartExpr())
    return indent . border
  else
    return border
  endif
endfunction
" }}}2

function! s:UpdateLineBorder(line) "{{{2
  let line = s:Line(a:line)

  let hf = s:StartExpr() . g:table_mode_corner . '[' . g:table_mode_corner .
        \  g:table_mode_fillchar . ']*' . g:table_mode_corner . '\?\s*$'

  let rowgap = s:RowGap()
  let border = s:GenerateBorder(line)

  let [prev_line, next_line] = [getline(line-1), getline(line+1)]
  if next_line =~# hf
    if s:Strlen(border) > s:Strlen(s:GenerateBorder(line + rowgap)) || !tablemode#IsATableRow(line + rowgap)
      call setline(line+1, border)
    endif
  else
    call append(line, border)
  endif

  if prev_line =~# hf
    if s:Strlen(border) > s:Strlen(s:GenerateBorder(line - rowgap)) || !tablemode#IsATableRow(line - rowgap)
      call setline(line-1, border)
    endif
  else
    call append(line-1, border)
  endif
endfunction
" }}}2

function! s:ConvertDelimiterToSeparator(line, ...) "{{{2
  let delim = g:table_mode_delimiter
  if a:0 | let delim = a:1 | endif
  if delim ==# ','
    silent! execute a:line . 's/' . "[\'\"][^\'\"]*\\zs,\\ze[^\'\"]*[\'\"]/__COMMA__/g"
  endif
  silent! execute a:line . 's/' . s:StartExpr() . '\zs\ze.\|' . delim .  '\|$/' .
        \ g:table_mode_separator . '/g'
  if delim ==# ','
    silent! execute a:line . 's/' . "[\'\"][^\'\"]*\\zs__COMMA__\\ze[^\'\"]*[\'\"]/,/g"
  endif
endfunction
" }}}2

function! s:Tableizeline(line, ...) "{{{2
  let delim = g:table_mode_delimiter
  if a:0 && type(a:1) == type('') && !empty(a:1) | let delim = a:1[1:-1] | endif
  call s:ConvertDelimiterToSeparator(a:line, delim)
  if g:table_mode_border | call s:UpdateLineBorder(a:line) | endif
endfunction
" }}}2

function! s:IsFirstCell() "{{{2
  return tablemode#ColumnNr('.') ==# 1
endfunction
" }}}2

function! s:IsLastCell() "{{{2
  return tablemode#ColumnNr('.') ==# tablemode#ColumnCount('.')
endfunction
" }}}2

function! s:MoveToFirstRow() "{{{2
  if tablemode#IsATableRow('.')
    let line = s:Line('.')
    while line > 0
      if !tablemode#IsATableRow(line)
        break
      endif
      let line = line - s:RowGap()
    endwhile
    call cursor(line + s:RowGap(), col('.'))
  endif
endfunction
" }}}2

function! s:MoveToLastRow() "{{{2
  if tablemode#IsATableRow('.')
    let line = s:Line('.')
    while line <= line('$')
      if !tablemode#IsATableRow(line)
        break
      endif
      let line = line + s:RowGap()
    endwhile
    call cursor(line - s:RowGap(), col('.'))
  endif
endfunction
" }}}2

function! s:MoveToStartOfCell() "{{{2
  if getline('.')[col('.')-1] ==# g:table_mode_separator && !s:IsLastCell()
    normal! 2l
  else
    execute 'normal! F' . g:table_mode_separator . '2l'
  endif
endfunction
" }}}2

function! s:RowGap() "{{{2
  if g:table_mode_border
    return 2
  else
    return 1
  endif
endfunction
" }}}2

" }}}1

" Public API {{{1

function! tablemode#TableizeInsertMode() "{{{2
  if s:IsTableModeActive() && getline('.') =~# (s:StartExpr() . g:table_mode_separator)
    let column = s:Strlen(substitute(getline('.')[0:col('.')], '[^' . g:table_mode_separator . ']', '', 'g'))
    let position = s:Strlen(matchstr(getline('.')[0:col('.')], '.*' . g:table_mode_separator . '\s*\zs.*'))
    call tablemode#TableRealign('.')
    normal! 0
    call search(repeat('[^' . g:table_mode_separator . ']*' . g:table_mode_separator, column) . '\s\{-\}' . repeat('.', position), 'ce', line('.'))
  endif
endfunction
" }}}2

function! tablemode#TableModeEnable() "{{{2
  call s:SetActive(1)
endfunction
" }}}2

function! tablemode#TableModeDisable() "{{{2
  call s:SetActive(0)
endfunction
" }}}2

function! tablemode#TableModeToggle() "{{{2
  if g:table_mode_always_active
    return 1
  endif

  call s:SetBufferOptDefault('table_mode_active', 0)
  call s:SetActive(!b:table_mode_active)
endfunction
" }}}2

function! tablemode#TableizeRange(...) range "{{{2
  let shift = 1
  if g:table_mode_border | let shift = shift + 1 | endif
  call s:Tableizeline(a:firstline, a:1)
  undojoin
  " The first one causes 2 extra lines for top & bottom border while the
  " following lines cause only 1 for the bottom border.
  let lnum = a:firstline + shift + (g:table_mode_border > 0)
  while lnum < (a:firstline + (a:lastline - a:firstline + 1)*shift)
    call s:Tableizeline(lnum, a:1)
    undojoin
    let lnum = lnum + shift
  endwhile

  if g:table_mode_border | call tablemode#TableRealign(lnum - shift) | endif
endfunction
" }}}2

function! tablemode#TableizeByDelimiter() "{{{2
  let delim = input('/')
  if delim =~# "\<Esc>" || delim =~# "\<C-C>" | return | endif
  let vm = visualmode()
  if vm ==? 'line' || vm ==? 'V'
    exec line("'<") . ',' . line("'>") . "call tablemode#TableizeRange('/' . delim)"
  endif
endfunction
" }}}2

function! tablemode#TableRealign(line) "{{{2
  let line = s:Line(a:line)

  let [lnums, lines] = [[], []]
  let tline = line
  while tline > 0
    if tablemode#IsATableRow(tline)
      call insert(lnums, tline)
      call insert(lines, getline(tline))
    else
      break
    endif
    let tline = tline - s:RowGap()
  endwhile

  let tline = line + s:RowGap()
  while tline <= line('$')
    if tablemode#IsATableRow(tline)
      call add(lnums, tline)
      call add(lines, getline(tline))
    else
      break
    endif
    let tline = tline + s:RowGap()
  endwhile

  call tabular#TabularizeStrings(lines, g:table_mode_separator)

  for lnum in lnums
    let index = index(lnums, lnum)
    call setline(lnum, lines[index])
    undojoin
    call s:UpdateLineBorder(lnum)
  endfor
endfunction
" }}}2

function! tablemode#IsATableRow(line) "{{{2
  return getline(a:line) =~# (s:StartExpr() . g:table_mode_separator)
endfunction
" }}}2

function! tablemode#RowCount(line) "{{{2
  let line = s:Line(a:line)

  let [tline, totalRowCount] = [line, 0]
  while tline > 0
    if tablemode#IsATableRow(tline)
      let totalRowCount = totalRowCount + 1
    else
      break
    endif
    let tline = tline - s:RowGap()
  endwhile

  let tline = line + s:RowGap()
  while tline <= line('$')
    if tablemode#IsATableRow(tline)
      let totalRowCount = totalRowCount + 1
    else
      break
    endif
    let tline = tline + s:RowGap()
  endwhile

  return totalRowCount
endfunction
" }}}2

function! tablemode#RowNr(line) "{{{2
  let line = s:Line(a:line)

  let rowNr = 0
  while line > 0
    if tablemode#IsATableRow(line)
      let rowNr = rowNr + 1
    else
      break
    endif
    let line = line - s:RowGap()
  endwhile

  return rowNr
endfunction
" }}}2

function! tablemode#ColumnCount(line) "{{{2
  let line = s:Line(a:line)

  return s:Strlen(substitute(getline(line), '[^' . g:table_mode_separator . ']', '', 'g'))-1
endfunction
" }}}2

function! tablemode#ColumnNr(pos) "{{{2
  let pos = []
  if type(a:pos) == type('')
    let pos = [line(a:pos), col(a:pos)]
  elseif type(a:pos) == type([])
    let pos = a:pos
  else
    return 0
  endif

  return s:Strlen(substitute(getline(pos[0])[0:pos[1]-2], '[^' . g:table_mode_separator . ']', '', 'g'))
endfunction
" }}}2

function! tablemode#TableMotion(direction) "{{{2
  if tablemode#IsATableRow('.')
    if a:direction ==# 'l'
      if s:IsLastCell()
        if !tablemode#IsATableRow(line('.') + s:RowGap()) | return | endif
        call tablemode#TableMotion('j')
        normal! 0
      endif

      " If line starts with g:table_mode_separator
      if getline('.')[col('.')-1] ==# g:table_mode_separator
        normal! 2l
      else
        execute 'normal! f' . g:table_mode_separator . '2l'
      endif
    elseif a:direction ==# 'h'
      if s:IsFirstCell()
        if !tablemode#IsATableRow(line('.') - s:RowGap()) | return | endif
        call tablemode#TableMotion('k')
        normal! $
      endif

      " If line ends with g:table_mode_separator
      if getline('.')[col('.')-1] ==# g:table_mode_separator
        execute 'normal! F' . g:table_mode_separator . '2l'
      else
        execute 'normal! 2F' . g:table_mode_separator . '2l'
      endif
    elseif a:direction ==# 'j'
      if tablemode#IsATableRow(line('.') + s:RowGap()) | execute 'normal ' . s:RowGap() . 'j' | endif
    elseif a:direction ==# 'k'
      if tablemode#IsATableRow(line('.') - s:RowGap()) | execute 'normal ' . s:RowGap() . 'k' | endif
    endif
  endif
endfunction
" }}}2

function! tablemode#CellTextObject() "{{{2
  if tablemode#IsATableRow('.')
    call s:MoveToStartOfCell()

    if v:operator ==# 'y'
      normal! v
      call search('[^' . g:table_mode_separator . ']\ze\s*' . g:table_mode_separator)
    else
      execute 'normal! vf' . g:table_mode_separator
    endif
  endif
endfunction
" }}}2

function! tablemode#DeleteColumn() "{{{2
  if tablemode#IsATableRow('.')
    for i in range(v:count1)
      call s:MoveToFirstRow()
      call s:MoveToStartOfCell()
      silent! execute "normal! h\<C-V>f" . g:table_mode_separator
      call s:MoveToLastRow()
      normal! d
    endfor

    call tablemode#TableRealign('.')
  endif
endfunction
" }}}2

function! tablemode#DeleteRow() "{{{2
  if tablemode#IsATableRow('.')
    for i in range(v:count1)
      if tablemode#RowCount('.') ==# 1
        normal! kVjjd
      else
        normal! kVjd
      endif

      if tablemode#IsATableRow(line('.')+1)
        normal! j
      else
        normal! k
      endif
    endfor

    call tablemode#TableRealign('.')
  endif
endfunction
" }}}2

" }}}1
