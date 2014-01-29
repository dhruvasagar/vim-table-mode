" =============================================================================
" File:          plugin/table-mode.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       http://github.com/dhruvasagar/vim-table-mode
" Version:       3.3.3
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
call s:SetGlobalOptDefault('table_mode_tableize_map', 't')
call s:SetGlobalOptDefault('table_mode_tableize_op_map', '<Leader>T')
call s:SetGlobalOptDefault('table_mode_realign_map', 'r')
call s:SetGlobalOptDefault('table_mode_cell_text_object', 'tc')
call s:SetGlobalOptDefault('table_mode_delete_row_map', 'dd')
call s:SetGlobalOptDefault('table_mode_delete_column_map', 'dc')
call s:SetGlobalOptDefault('table_mode_add_formula_map', 'fa')
call s:SetGlobalOptDefault('table_mode_eval_expr_map', 'fe')
call s:SetGlobalOptDefault('table_mode_echo_cell_map', '?')
call s:SetGlobalOptDefault('table_mode_corner_corner', '|')

function! s:TableMotion() "{{{1
  let direction = nr2char(getchar())
  for i in range(v:count1)
    call tablemode#TableMotion(direction)
  endfor
endfunction

function! s:TableEchoCell() "{{{1
  if tablemode#IsATableRow('.')
    echomsg '$' . tablemode#RowNr('.') . ',' . tablemode#ColumnNr('.')
  endif
endfunction

" Define Commands & Mappings {{{1
if !g:table_mode_always_active "{{{2
  exec "nnoremap <silent> " . g:table_mode_map_prefix . g:table_mode_toggle_map .
       \ " <Esc>:call tablemode#TableModeToggle()<CR>"
  command! -nargs=0 TableModeToggle call tablemode#TableModeToggle()
  command! -nargs=0 TableModeEnable call tablemode#TableModeEnable()
  command! -nargs=0 TableModeDisable call tablemode#TableModeDisable()
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

command! TableAddFormula call tablemode#AddFormula()
command! TableEvalFormulaLine call tablemode#EvaluateFormulaLine()

execute "xnoremap <silent> " . g:table_mode_map_prefix . g:table_mode_tableize_map .
      \ " :Tableize<CR>"
execute "nnoremap <silent> " . g:table_mode_map_prefix . g:table_mode_tableize_map .
      \ " :Tableize<CR>"
execute "xnoremap <silent> " . g:table_mode_tableize_op_map .
      \ " :<C-U>call tablemode#TableizeByDelimiter()<CR>"
execute "nnoremap <silent> " . g:table_mode_map_prefix . g:table_mode_realign_map .
      \ " :call tablemode#TableRealign('.')<CR>"
execute "nnoremap <silent> " . g:table_mode_map_prefix .
      \ " :call <SID>TableMotion()<CR>"
execute "onoremap <silent> " . g:table_mode_cell_text_object .
      \ " :<C-U>call tablemode#CellTextObject()<CR>"
execute "nnoremap <silent> " . g:table_mode_map_prefix . g:table_mode_delete_row_map .
      \ " :call tablemode#DeleteRow()<CR>"
execute "nnoremap <silent> " . g:table_mode_map_prefix . g:table_mode_delete_column_map .
      \ " :call tablemode#DeleteColumn()<CR>"
execute "nnoremap <silent> " . g:table_mode_map_prefix . g:table_mode_add_formula_map .
      \ " :TableAddFormula<CR>"
execute "nnoremap <silent> " . g:table_mode_map_prefix . g:table_mode_eval_expr_map .
      \ " :TableEvalFormulaLine<CR>"
execute "nnoremap <silent> " . g:table_mode_map_prefix . g:table_mode_echo_cell_map .
      \ " :call <SID>TableEchoCell()<CR>"

" Avoiding side effects {{{1
let &cpo = s:save_cpo

" ModeLine {{{
" vim: sw=2 sts=2 fdl=0 fdm=marker
