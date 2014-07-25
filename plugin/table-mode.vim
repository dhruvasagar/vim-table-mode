" =============================================================================
" File:          plugin/table-mode.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       http://github.com/dhruvasagar/vim-table-mode
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

" Finish if already loaded {{{1
if exists('g:loaded_table_mode')
  finish
endif
let g:loaded_table_mode = 1

" Avoiding side effects {{{1
let s:save_cpo = &cpo
set cpo&vim

function! s:SetGlobalOptDefault(opt, val) "{{{1
  if !exists('g:' . a:opt)
    let g:{a:opt} = a:val
  endif
endfunction

" Set Global Defaults {{{1
call s:SetGlobalOptDefault('table_mode_corner', '+')
call s:SetGlobalOptDefault('table_mode_separator', '|')
call s:SetGlobalOptDefault('table_mode_fillchar', '-')
call s:SetGlobalOptDefault('table_mode_map_prefix', '<Leader>t')
call s:SetGlobalOptDefault('table_mode_toggle_map', 'm')
call s:SetGlobalOptDefault('table_mode_always_active', 0)
call s:SetGlobalOptDefault('table_mode_delimiter', ',')
call s:SetGlobalOptDefault('table_mode_corner_corner', '|')
call s:SetGlobalOptDefault('table_mode_align_char', ':')
call s:SetGlobalOptDefault('table_mode_disable_mappings', 0)

function! s:TableEchoCell() "{{{1
  if tablemode#table#IsRow('.')
    echomsg '$' . tablemode#spreadsheet#RowNr('.') . ',' . tablemode#spreadsheet#ColumnNr('.')
  endif
endfunction

augroup TableMode
  au!

  autocmd Syntax * if tablemode#IsActive() | call tablemode#SyntaxEnable() | endif
augroup END

" Define Commands & Mappings {{{1
if !g:table_mode_always_active "{{{2
  exec "nnoremap <silent> " . g:table_mode_map_prefix . g:table_mode_toggle_map .
       \ " <Esc>:call tablemode#Toggle()<CR>"
  command! -nargs=0 TableModeToggle call tablemode#Toggle()
  command! -nargs=0 TableModeEnable call tablemode#Enable()
  command! -nargs=0 TableModeDisable call tablemode#Disable()
else
  let table_mode_separator_map = g:table_mode_separator
  " '|' is a special character, we need to map <Bar> instead
  if g:table_mode_separator ==# '|' | let table_mode_separator_map = '<Bar>' | endif

  execute "inoremap <silent> " . table_mode_separator_map . ' ' .
        \ table_mode_separator_map . "<Esc>:call tablemode#TableizeInsertMode()<CR>a"
  unlet table_mode_separator_map
endif
" }}}2

command! -nargs=? -range Tableize <line1>,<line2>call tablemode#TableizeRange(<q-args>)
command! TableAddFormula call tablemode#spreadsheet#formula#Add()
command! TableModeRealign call tablemode#table#Realign('.')
command! TableEvalFormulaLine call tablemode#spreadsheet#formula#EvaluateFormulaLine()

" '|' is a special character, we need to map <Bar> instead
if g:table_mode_separator ==# '|' | let separator_map = '<Bar>' | endif
execute 'inoremap <silent> <Plug>(table-mode-tableize)' separator_map . '<Esc>:call tablemode#TableizeInsertMode()<CR>a'

nnoremap <silent> <Plug>(table-mode-tableize) :Tableize<CR>
xnoremap <silent> <Plug>(table-mode-tableize) :Tableize<CR>
xnoremap <silent> <Plug>(table-mode-tableize-delimiter) :<C-U>call tablemode#TableizeByDelimiter()<CR>

nnoremap <silent> <Plug>(table-mode-realign) :call tablemode#table#Realign('.')<CR>

nnoremap <silent> <Plug>(table-mode-motion-up) :<C-U>call tablemode#spreadsheet#cell#Motion('k')<CR>
nnoremap <silent> <Plug>(table-mode-motion-down) :<C-U>call tablemode#spreadsheet#cell#Motion('j')<CR>
nnoremap <silent> <Plug>(table-mode-motion-left) :<C-U>call tablemode#spreadsheet#cell#Motion('h')<CR>
nnoremap <silent> <Plug>(table-mode-motion-right) :<C-U>call tablemode#spreadsheet#cell#Motion('l')<CR>

onoremap <silent> <Plug>(table-mode-cell-text-object-a) :<C-U>call tablemode#spreadsheet#cell#TextObject(0)<CR>
onoremap <silent> <Plug>(table-mode-cell-text-object-i) :<C-U>call tablemode#spreadsheet#cell#TextObject(1)<CR>
xnoremap <silent> <Plug>(table-mode-cell-text-object-a) :<C-U>call tablemode#spreadsheet#cell#TextObject(0)<CR>
xnoremap <silent> <Plug>(table-mode-cell-text-object-i) :<C-U>call tablemode#spreadsheet#cell#TextObject(1)<CR>

nnoremap <silent> <Plug>(table-mode-delete-row) :call tablemode#spreadsheet#DeleteRow()<CR>
nnoremap <silent> <Plug>(table-mode-delete-column) :call tablemode#spreadsheet#DeleteColumn()<CR>

nnoremap <silent> <Plug>(table-mode-add-formula) :call tablemode#spreadsheet#formula#Add()<CR>
nnoremap <silent> <Plug>(table-mode-eval-formula) :call tablemode#spreadsheet#formula#EvaluateFormulaLine()<CR>

nnoremap <silent> <Plug>(table-mode-echo-cell) :call <SID>TableEchoCell()<CR>

if !hasmapto('<Plug>(table-mode-tableize)')
  nmap <Leader>tt <Plug>(table-mode-tableize)
  xmap <Leader>tt <Plug>(table-mode-tableize)
endif

if !hasmapto('<Plug>(table-mode-tableize-delimiter)')
  xmap <Leader>T <Plug>(table-mode-tableize-delimiter)
endif

" Avoiding side effects {{{1
let &cpo = s:save_cpo

" ModeLine {{{
" vim: sw=2 sts=2 fdl=0 fdm=marker
