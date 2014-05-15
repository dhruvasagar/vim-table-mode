" ==============================  Header ======================================
" File:          autoload/tablemode.vim
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
function! s:sub(str,pat,rep) abort "{{{2
  return substitute(a:str,'\v\C'.a:pat,a:rep,'')
endfunction

function! s:gsub(str,pat,rep) abort "{{{2
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:SetBufferOptDefault(opt, val) "{{{2
  if !exists('b:' . a:opt)
    let b:{a:opt} = a:val
  endif
endfunction

function! s:ToggleMapping() "{{{2
  let separator_map = g:table_mode_separator
  " '|' is a special character, we need to map <Bar> instead
  if g:table_mode_separator ==# '|' | let separator_map = '<Bar>' | endif

  if tablemode#IsActive()
    execute 'inoremap <silent> <buffer>' separator_map
          \ separator_map . '<Esc>:call tablemode#TableizeInsertMode()<CR>a'

    if !hasmapto('<Plug>(table-mode-motion-up)', 'n')
      nmap <buffer> {<Bar> <Plug>(table-mode-motion-up)
    endif
    if !hasmapto('<Plug>(table-mode-motion-down)', 'n')
      nmap <buffer> }<Bar> <Plug>(table-mode-motion-down)
    endif
    if !hasmapto('<Plug>(table-mode-motion-left)', 'n')
      nmap <buffer> [<Bar> <Plug>(table-mode-motion-left)
    endif
    if !hasmapto('<Plug>(table-mode-motion-right)', 'n')
      nmap <buffer> ]<Bar> <Plug>(table-mode-motion-right)
    endif
    if !hasmapto('<Plug>(table-mode-cell-text-object-a)', 'o')
      omap <buffer> a<Bar> <Plug>(table-mode-cell-text-object-a)
      xmap <buffer> a<Bar> <Plug>(table-mode-cell-text-object-a)
    endif
    if !hasmapto('<Plug>(table-mode-cell-text-object-i)', 'o')
      omap <buffer> i<Bar> <Plug>(table-mode-cell-text-object-i)
      xmap <buffer> i<Bar> <Plug>(table-mode-cell-text-object-i)
    endif
    if !hasmapto('<Plug>(table-mode-realign)', 'n')
      nmap <buffer> <Leader>tr <Plug>(table-mode-realign)
    endif
    if !hasmapto('<Plug>(table-mode-delete-row)', 'n')
      nmap <buffer> <Leader>tdd <Plug>(table-mode-delete-row)
    endif
    if !hasmapto('<Plug>(table-mode-delete-column)', 'n')
      nmap <buffer> <Leader>tdc <Plug>(table-mode-delete-column)
    endif
    if !hasmapto('<Plug>(table-mode-add-formula)', 'n')
      nmap <buffer> <Leader>tfa <Plug>(table-mode-add-formula)
    endif
    if !hasmapto('<Plug>(table-mode-eval-formula)', 'n')
      nmap <buffer> <Leader>tfe <Plug>(table-mode-eval-formula)
    endif
    if !hasmapto('<Plug>(table-mode-echo-cell)', 'n')
      nmap <buffer> <Leader>t? <Plug>(table-mode-echo-cell)
    endif
  else
    if !empty(maparg(separator_map, 'i'))
      execute "iunmap <silent> <buffer> " . separator_map
    endif
    if !empty(maparg('{<Bar>', 'n'))
      nunmap <buffer> {<Bar>
    endif
    if !empty(maparg('}<Bar>', 'n'))
      nunmap <buffer> }<Bar>
    endif
    if !empty(maparg('[<Bar>', 'n'))
      nunmap <buffer> [<Bar>
    endif
    if !empty(maparg(']<Bar>', 'n'))
      nunmap <buffer> ]<Bar>
    endif
    if !empty(maparg('a<Bar>', 'o'))
      ounmap <buffer> a<Bar>
    endif
    if !empty(maparg('i<Bar>', 'o'))
      ounmap <buffer> i<Bar>
    endif
    if !empty(maparg('<Leader>tdd', 'n'))
      nunmap <buffer> <Leader>tdd
    endif
    if !empty(maparg('<Leader>tdc', 'n'))
      nunmap <buffer> <Leader>tdc
    endif
    if !empty(maparg('<Leader>tfa', 'n'))
      nunmap <buffer> <Leader>tfa
    endif
    if !empty(maparg('<Leader>tfe', 'n'))
      nunmap <buffer> <Leader>tfe
    endif
    if !empty(maparg('<Leader>t?', 'n'))
      nunmap <buffer> <Leader>t?
    endif
  endif
endfunction

function! s:SetActive(bool) "{{{2
  let b:table_mode_active = a:bool
  call s:ToggleMapping()
endfunction

function! s:ConvertDelimiterToSeparator(line, ...) "{{{2
  let old_gdefault = &gdefault
  set nogdefault

  let delim = g:table_mode_delimiter
  if a:0 | let delim = a:1 | endif
  if delim ==# ','
    silent! execute a:line . 's/' . "[\'\"][^\'\"]*\\zs,\\ze[^\'\"]*[\'\"]/__COMMA__/g"
  endif

  let [cstart, cend] = [tablemode#table#GetCommentStart(), tablemode#table#GetCommentEnd()]
  let [match_char_start, match_char_end] = ['.', '.']
  if tablemode#utils#strlen(cend) > 0 | let match_char_end = '[^' . cend . ']' | endif
  if tablemode#utils#strlen(cstart) > 0 | let match_char_start = '[^' . cstart . ']' | endif

  silent! execute a:line . 's/' . tablemode#table#StartExpr() . '\zs\ze' . match_char_start .
        \ '\|' . delim .  '\|' . match_char_end . '\zs\ze' . tablemode#table#EndExpr() . '/' .
        \ g:table_mode_separator . '/g'

  if delim ==# ','
    silent! execute a:line . 's/' . "[\'\"][^\'\"]*\\zs__COMMA__\\ze[^\'\"]*[\'\"]/,/g"
  endif

  let &gdefault=old_gdefault
endfunction

function! s:Tableizeline(line, ...) "{{{2
  let delim = g:table_mode_delimiter
  if a:0 && type(a:1) == type('') && !empty(a:1) | let delim = a:1[1:-1] | endif
  call s:ConvertDelimiterToSeparator(a:line, delim)
endfunction

" Public API {{{1
function! tablemode#sid() "{{{2
  return maparg('<SID>', 'n')
endfunction
nnoremap <SID> <SID>

function! tablemode#scope() "{{{2
  return s:
endfunction

function! tablemode#IsActive() "{{{2
  if g:table_mode_always_active | return 1 | endif

  call s:SetBufferOptDefault('table_mode_active', 0)
  return b:table_mode_active
endfunction

function! tablemode#TableizeInsertMode() "{{{2
  if tablemode#IsActive() && getline('.') =~# (tablemode#table#StartExpr() . g:table_mode_separator . g:table_mode_separator)
    call tablemode#table#AddBorder('.')
    normal! A
  elseif tablemode#IsActive() && getline('.') =~# (tablemode#table#StartExpr() . g:table_mode_separator)
    let column = tablemode#utils#strlen(substitute(getline('.')[0:col('.')], '[^' . g:table_mode_separator . ']', '', 'g'))
    let position = tablemode#utils#strlen(matchstr(getline('.')[0:col('.')], '.*' . g:table_mode_separator . '\s*\zs.*'))
    call tablemode#table#Realign('.')
    normal! 0
    call search(repeat('[^' . g:table_mode_separator . ']*' . g:table_mode_separator, column) . '\s\{-\}' . repeat('.', position), 'ce', line('.'))
  endif
endfunction

function! tablemode#Enable() "{{{2
  call s:SetActive(1)
endfunction

function! tablemode#Disable() "{{{2
  call s:SetActive(0)
endfunction

function! tablemode#Toggle() "{{{2
  if g:table_mode_always_active
    return 1
  endif

  call s:SetBufferOptDefault('table_mode_active', 0)
  call s:SetActive(!b:table_mode_active)
endfunction

function! tablemode#TableizeRange(...) range "{{{2
  let lnum = a:firstline
  while lnum < (a:firstline + (a:lastline - a:firstline + 1))
    call s:Tableizeline(lnum, a:1)
    undojoin
    let lnum += 1
  endwhile

  call tablemode#table#Realign(lnum - 1)
endfunction

function! tablemode#TableizeByDelimiter() "{{{2
  let delim = input('/')
  if delim =~# "\<Esc>" || delim =~# "\<C-C>" | return | endif
  let vm = visualmode()
  if vm ==? 'line' || vm ==? 'V'
    exec line("'<") . ',' . line("'>") . "call tablemode#TableizeRange('/' . delim)"
  endif
endfunction
