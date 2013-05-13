" =============================================================================
" File:          plugin/table-mode.vim
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

" Finish if already loaded {{{1
if exists('g:table_mode_loaded')
  finish
endif
let g:table_mode_loaded = 1
"}}}1
"
" Finish if Tabularize plugin is not available {{{1
if !exists(':Tabularize')
  echoerr 'Table Mode depends on Tabularize, ensure that is installed first.'
  finish
endif
" }}}1

" Avoiding side effects {{{1
let s:save_cpo = &cpo
set cpo&vim
" }}}1

function! s:SetGlobalOptDefault(opt, val) "{{{1
  if !exists('g:' . a:opt)
    let g:{a:opt} = a:val
  endif
endfunction
" }}}1

" Set Global Defaults {{{1
call s:SetGlobalOptDefault('table_mode_border', 1)
call s:SetGlobalOptDefault('table_mode_corner', '+')
call s:SetGlobalOptDefault('table_mode_separator', '|')
call s:SetGlobalOptDefault('table_mode_fillchar', '-')
call s:SetGlobalOptDefault('table_mode_toggle_map', '<LocalLeader>tm')
call s:SetGlobalOptDefault('table_mode_always_active', 0)
call s:SetGlobalOptDefault('table_mode_delimiter', ',')
call s:SetGlobalOptDefault('table_mode_tableize_map', '<Leader>tt')
call s:SetGlobalOptDefault('table_mode_tableize_op_map', '<Leader>T')
call s:SetGlobalOptDefault('table_mode_align', 'l1')
call s:SetGlobalOptDefault('table_mode_realign_map', '<Leader>tr')
call s:SetGlobalOptDefault('table_mode_motion_prefix', '<Leader>t')
call s:SetGlobalOptDefault('table_mode_cell_text_object', 'tc')
call s:SetGlobalOptDefault('table_mode_delete_row_map', '<Leader>tdd')
call s:SetGlobalOptDefault('table_mode_delete_column_map', '<Leader>tdc')
"}}}1

function! s:TableMotion() "{{{1
  let direction = nr2char(getchar())
  for i in range(v:count1)
    call tablemode#TableMotion(direction)
  endfor
endfunction
" }}}1

let s:tables = {}

function! s:AddFormula(formula, range) abort "{{{1
  let line = line('.')
  let colm = tablemode#ColumnNr('.')
  let bufnr = bufnr('%')
  let formula = 'tablemode#'.a:formula.'('.a:range.','.line.','.colm.')'

  if has_key(s:tables, bufnr)
    if has_key(s:tables[bufnr], line)
      let s:tables[bufnr][line][colm] = formula
    else
      let s:tables[bufnr][line] = { colm: formula }
    endif
  else
    let s:tables[bufnr] = {}
    let s:tables[bufnr][line] = {}
    let s:tables[bufnr][line][colm] = formula
  endif
endfunction
" }}}1

function! s:RecalculateFormulas() "{{{1
  let bufnr = bufnr('%')
  if has_key(s:tables, bufnr)
    let formulas = s:tables[bufnr]
    for [line, cform] in items(formulas)
      let line = str2nr(line)
      for [colm, formula] in items(cform)
        let colm = str2nr(colm)
        let row = tablemode#RowNr(line)
        call tablemode#SetCell(eval(formula), line, row, colm)
      endfor
    endfor
  endif
endfunction
" }}}1

" Define Commands & Mappings {{{1
if !g:table_mode_always_active "{{{2
  exec "nnoremap <silent> " . g:table_mode_toggle_map .
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

execute "xnoremap <silent> " . g:table_mode_tableize_map . " :Tableize<CR>"
execute "nnoremap <silent> " . g:table_mode_tableize_map . " :Tableize<CR>"
execute "xnoremap <silent> " . g:table_mode_tableize_op_map . " :<C-U>call tablemode#TableizeByDelimiter()<CR>"
execute "nnoremap <silent> " . g:table_mode_realign_map . " :<C-U>call tablemode#TableRealign('.')<CR>"
execute "nnoremap <silent> " . g:table_mode_motion_prefix . " :<C-U>call <SID>TableMotion()<CR>"
execute "onoremap <silent> " . g:table_mode_cell_text_object . " :<C-U>call tablemode#CellTextObject()<CR>"
execute "nnoremap <silent> " . g:table_mode_delete_row_map . " :<C-U>call tablemode#DeleteRow()<CR>"
execute "nnoremap <silent> " . g:table_mode_delete_column_map . " :<C-U>call tablemode#DeleteColumn()<CR>"

command! -nargs=* TableForumla call s:AddFormula(<f-args>)
command! TableRecalc call s:RecalculateFormulas()
"}}}1

" Avoiding side effects {{{1
let &cpo = s:save_cpo
" }}}1

" ModeLine {{{
" vim:fdl=0 fdm=marker
