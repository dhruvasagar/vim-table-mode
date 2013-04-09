" =============================================================================
" File:          autoload/tablemode.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       http://github.com/dhruvasagar/vim-table-mode
" Version:       2.2.1
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

function! s:CountSeparator(line, separator) "{{{2
  return s:Strlen(substitute(getline(a:line), '[^' . a:separator . ']', '', 'g'))
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

function! s:UpdateLineBorder(line) "{{{2
  let cline = a:line
  let hf = s:StartExpr() . g:table_mode_corner . '[' . g:table_mode_corner . ' ' .
         \ g:table_mode_fillchar . ']*' . g:table_mode_corner . '\?\s*$'
  let curr_line_count = s:CountSeparator(cline, g:table_mode_separator)

  if getline(cline-1) =~# hf
    let prev_line_count = s:CountSeparator(cline-1, g:table_mode_corner)
    if curr_line_count > prev_line_count
      silent! execute 'normal! kA' . repeat(g:table_mode_corner, curr_line_count - prev_line_count) . "\<Esc>j"
    endif
  else
    let cstartexpr = s:StartCommentExpr()
    if s:Strlen(cstartexpr) > 0 && getline(cline) =~# cstartexpr
      let indent = matchstr(getline(cline), s:StartCommentExpr())
      call append(cline-1, indent . repeat(g:table_mode_corner, curr_line_count))
    else
      call append(cline-1, repeat(g:table_mode_corner, curr_line_count))
    endif
    let cline = a:line + 1 " because of the append, the current line moved down
  endif

  if getline(cline+1) =~# hf
    let next_line_count = s:CountSeparator(cline+1, g:table_mode_corner)
    if curr_line_count > next_line_count
      silent! execute 'normal! jA' . repeat(g:table_mode_corner, curr_line_count - next_line_count) . "\<Esc>k"
    end
  else
    let cstartexpr = s:StartCommentExpr()
    if s:Strlen(cstartexpr) > 0 && getline(cline) =~# cstartexpr
      let indent = matchstr(getline(cline), s:StartCommentExpr())
      call append(cline, indent . repeat(g:table_mode_corner, curr_line_count))
    else
      call append(cline, repeat(g:table_mode_corner, curr_line_count))
    endif
  endif
endfunction
" }}}2

function! s:FillTableBorder() "{{{2
  let [ current_col, current_line ] = [ col('.'), line('.') ]
  if g:table_mode_no_border_padding
    silent! execute '%s/' . g:table_mode_corner . '\zs\([' .
          \ g:table_mode_fillchar . ' ]*\)\ze' . g:table_mode_corner .
          \ '/\=repeat("' . g:table_mode_fillchar . '", s:Strlen(submatch(0)))/g'
  else
    silent! execute '%s/' . g:table_mode_corner . ' \zs\([' .
          \ g:table_mode_fillchar . ' ]*\)\ze ' . g:table_mode_corner .
          \ '/\=repeat("' . g:table_mode_fillchar . '", s:Strlen(submatch(0)))/g'
  endif
  call cursor(current_line, current_col)
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
  execute 'Tabularize/[' . g:table_mode_separator . g:table_mode_corner . ']/' . g:table_mode_align
endfunction
" }}}2

" }}}1

" Public API {{{1

function! tablemode#TableizeInsertMode() "{{{2
  if s:IsTableModeActive() && getline('.') =~# (s:StartExpr() . g:table_mode_separator)
    let column = s:Strlen(substitute(getline('.')[0:col('.')], '[^' . g:table_mode_separator . ']', '', 'g'))
    let position = s:Strlen(matchstr(getline('.')[0:col('.')], '.*' . g:table_mode_separator . '\s*\zs.*'))
    if g:table_mode_border | call s:UpdateLineBorder(line('.')) | endif
    if g:table_mode_no_border_padding && g:table_mode_align !=# 'c0' | let g:table_mode_align = 'c0' | endif
    execute 'Tabularize/[' . g:table_mode_separator . g:table_mode_corner . ']/' . g:table_mode_align
    if g:table_mode_border | call s:FillTableBorder() | endif
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
  if g:table_mode_border | call s:FillTableBorder() | endif
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

" }}}1

" ModeLine {{{
" vim:fdm=marker
