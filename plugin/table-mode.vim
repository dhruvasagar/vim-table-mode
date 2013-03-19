" =============================================================================
" File:          plugin/table-mode.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       http://github.com/dhruvasagar/vim-table-mode
" Version:       2.0
" Note:          This plugin was heavily inspired by the 'CucumberTables.vim'
"                (https://gist.github.com/tpope/287147) plugin by Tim Pope and
"                uses a small amount of code from it.
"
" Copyright Notice:
"                Permission is hereby granted to use and distribute this code,
"                with or without modifications, provided that this copyright
"                notice is copied with it. Like anything else that's free,
"                taglist.vim is provided *as is* and comes with no warranty of
"                any kind, either expressed or implied. In no event will the
"                copyright holder be liable for any damamges resulting from the
"                use of this software.
" =============================================================================

" Finish if already loaded {{{1
if exists('g:table_mode_loaded')
  finish
endif
let g:table_mode_loaded = 1
"}}}1

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
call s:SetGlobalOptDefault('table_mode_toggle_map', '<Leader>tm')
call s:SetGlobalOptDefault('table_mode_always_active', 0)
call s:SetGlobalOptDefault('table_mode_delimiter', ',')
call s:SetGlobalOptDefault('table_mode_tableize_map', '<Leader>T')
"}}}1

" Define Commands & Mappings {{{1
if !g:table_mode_always_active
  exec "nnoremap <silent> " . g:table_mode_toggle_map .
       \ " <Esc>:call tablemode#TableModeToggle()<CR>"
  command! -nargs=0 TableModeToggle call tablemode#TableModeToggle()
  command! -nargs=0 TableModeEnable call tablemode#TableModeEnable()
  command! -nargs=0 TableModeDisable call tablemode#TableModeDisable()
endif

command! -nargs=0 -range Tableize <line1>,<line2>call tablemode#TableizeRange()
exec "xnoremap <silent> " . g:table_mode_tableize_map . " :Tableize<CR>"
exec "nnoremap <silent> " . g:table_mode_tableize_map . " :Tableize<CR>"
"}}}1

" ModeLine {{{
" vim:fdm=marker
