" =============================================================================
" File:          autoload/tablemode.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       http://github.com/dhruvasagar/vim-table-mode
" Version:       2.1
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

function! s:UpdateLineBorder(line) "{{{2
  let cline = a:line
  let hf = '^\s*' . g:table_mode_corner . '[' . g:table_mode_corner . ' ' . g:table_mode_fillchar . ']*' . g:table_mode_corner . '\?\s*$'
  let curr_line_count = s:CountSeparator(cline, g:table_mode_separator)

  if getline(cline-1) =~# hf
    let prev_line_count = s:CountSeparator(cline-1, g:table_mode_corner)
    if curr_line_count > prev_line_count
      exec 'normal! kA' . repeat(g:table_mode_corner, curr_line_count - prev_line_count) . "\<Esc>j"
    endif
  else
    call append(cline-1, repeat(g:table_mode_corner, curr_line_count))
    let cline = a:line + 1
  endif

  if getline(cline+1) =~# hf
    let next_line_count = s:CountSeparator(cline+1, g:table_mode_corner)
    if curr_line_count > next_line_count
      exec 'normal! jA' . repeat(g:table_mode_corner, curr_line_count - next_line_count) . "\<Esc>k"
    end
  else
    call append(cline, repeat(g:table_mode_corner, curr_line_count))
  endif
endfunction
" }}}2

function! s:FillTableBorder() "{{{2
  let current_col = col('.')
  let current_line = line('.')
  execute 'silent! %s/' . g:table_mode_corner . ' \zs\([' . g:table_mode_fillchar . ' ]*\)\ze ' . g:table_mode_corner . '/\=repeat("' . g:table_mode_fillchar . '", s:Strlen(submatch(0)))/g'
  call cursor(current_line, current_col)
endfunction
" }}}2

function! s:Tableizeline(line) "{{{2
  call s:ConvertDelimiterToSeparator(a:line)
  call s:UpdateLineBorder(a:line)
  exec 'Tabularize/[' . g:table_mode_separator . g:table_mode_corner . ']/l1'
endfunction
" }}}2

function! s:ConvertDelimiterToSeparator(line) "{{{2
  execute 'silent! ' . a:line . 's/^\s*\zs\ze.\|' . g:table_mode_delimiter . '\|$/' . g:table_mode_separator . '/g'
endfunction
" }}}2

function! s:IsTableModeActive() "{{{2
  if g:table_mode_always_active | return 1 | endif

  call s:SetBufferOptDefault('table_mode_active', 0)
  return b:table_mode_active
endfunction
" }}}2

function! s:Tableize() "{{{2
  if s:IsTableModeActive() && getline('.') =~# ('^\s*' . g:table_mode_separator)
    let column = s:Strlen(substitute(getline('.')[0:col('.')], '[^' . g:table_mode_separator . ']', '', 'g'))
    let position = s:Strlen(matchstr(getline('.')[0:col('.')], '.*' . g:table_mode_separator . '\s*\zs.*'))
    if g:table_mode_border | call s:UpdateLineBorder(line('.')) | endif
    exec 'Tabularize/[' . g:table_mode_separator . g:table_mode_corner . ']/l1'
    if g:table_mode_border | call s:FillTableBorder() | endif
    normal! 0
    call search(repeat('[^' . g:table_mode_separator . ']*' . g:table_mode_separator, column) . '\s\{-\}' . repeat('.', position), 'ce', line('.'))
  endif
endfunction
" }}}2

function! s:TableModeSeparatorMap() "{{{2
  if g:table_mode_separator ==# '|'
    let table_mode_separator_map = '<Bar>'
  else
    let table_mode_separator_map = g:table_mode_separator
  endif
  return table_mode_separator_map
endfunction
" }}}2

function! s:ToggleMapping() "{{{2
  if exists('b:table_mode_active') && b:table_mode_active
    exec "inoremap <silent> " . s:TableModeSeparatorMap() . ' ' .
          \ s:TableModeSeparatorMap() . "<Esc>:call <SID>Tableize()<CR>a"
  else
    exec "iunmap <silent> " . s:TableModeSeparatorMap()
  endif
endfunction
" }}}2

function! s:SetActive(bool) "{{{2
  let b:table_mode_active = a:bool
  call s:ToggleMapping()
endfunction
" }}}2

" }}}1

" Public API {{{1

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

function! tablemode#TableizeRange() range "{{{2
  call s:Tableizeline(a:firstline)
  undojoin
  " The first one causes 2 extra lines for top & bottom border while the
  " following lines cause only 1 for the bottom border.
  let lnum = a:firstline+3
  while lnum <= (a:firstline + (a:lastline - a:firstline+1)*2)
    call s:Tableizeline(lnum)
    undojoin
    let lnum = lnum + 2
  endwhile
  call s:FillTableBorder()
endfunction
" }}}2

" }}}1

" ModeLine {{{
" vim:fdm=marker
