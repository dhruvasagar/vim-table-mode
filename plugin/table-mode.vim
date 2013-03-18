" =============================================================================
" File:          table-mode.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Notes:         This was inspired by Tim Pope's cucumbertables.vim
"                (https://gist.github.com/tpope/287147)
" =============================================================================

if exists('g:table_mode_loaded')
  finish
endif
let g:table_mode_loaded = 1

function! s:SetGlobalOptDefault(opt, val)
  if !exists('g:' . a:opt)
    let g:{a:opt} = a:val
  endif
endfunction

call s:SetGlobalOptDefault('table_mode_border', 1)
call s:SetGlobalOptDefault('table_mode_corner', '+')
call s:SetGlobalOptDefault('table_mode_separator', '|')
call s:SetGlobalOptDefault('table_mode_fillchar', '-')
call s:SetGlobalOptDefault('table_mode_toggle_map', '<Leader>tm')
call s:SetGlobalOptDefault('table_mode_always_active', 0)
call s:SetGlobalOptDefault('table_mode_delimiter', ',')
call s:SetGlobalOptDefault('table_mode_tableize_map', '<Leader>T')

function! s:SetBufferOptDefault(opt, val)
  if !exists('b:' . a:opt)
    let b:{a:opt} = a:val
  endif
endfunction

if g:table_mode_separator ==# '|'
  let s:table_mode_separator_map = '<Bar>'
else
  let s:table_mode_separator_map = g:table_mode_separator
endif

function! s:error(str)
  echohl ErrorMsg
  echomsg a:sr
  echohl None
  let v:errmsg = a:str
endfunction

" For counting multibyte characters accurately, see :h strlen() for more
" details
function! s:strlen(text)
  return strlen(substitute(a:text, '.', 'x', 'g'))
endfunction

function! s:CountSeparator(line, separator)
  return s:strlen(substitute(getline(a:line), '[^' . a:separator . ']', '', 'g'))
endfunction

function! s:UpdateLineBorder(...)
  let cline = a:0 ? a:1 : line('.')
  let hf = '^\s*' . g:table_mode_corner . '[' . g:table_mode_corner . ' ' . g:table_mode_fillchar . ']*' . g:table_mode_corner . '\?\s*$'
  let curr_line_count = s:CountSeparator(cline, g:table_mode_separator)

  if getline(cline-1) =~# hf
    let prev_line_count = s:CountSeparator(cline-1, g:table_mode_corner)
    if prev_line_count < curr_line_count
      exec 'normal! kA' . repeat(g:table_mode_corner, curr_line_count - prev_line_count) . "\<Esc>j"
    endif
  else
    call append(cline-1, repeat(g:table_mode_corner, curr_line_count))
    let cline = a:0 ? (a:1+1) : line('.')
  endif

  if getline(cline+1) =~# hf
    let next_line_count = s:CountSeparator(cline+1, g:table_mode_corner)
    if next_line_count < curr_line_count
      exec 'normal! jA' . repeat(g:table_mode_corner, curr_line_count - next_line_count) . "\<Esc>k"
    end
  else
    call append(cline, repeat(g:table_mode_corner, curr_line_count))
  endif
endfunction

function! s:FillTableBorder()
  let current_col = col('.')
  let current_line = line('.')
  execute 'silent! %s/' . g:table_mode_corner . ' \zs\([' . g:table_mode_fillchar . ' ]*\)\ze ' . g:table_mode_corner . '/\=repeat("' . g:table_mode_fillchar . '", s:strlen(submatch(0)))/g'
  call cursor(current_line, current_col)
endfunction

function! s:TableModeEnable()
  let b:table_mode_active = 1
endfunction

function! s:TableModeDisable()
  let b:table_mode_active = 0
endfunction

function! s:TableModeToggle()
  if g:table_mode_always_active
    return 1
  endif

  call s:SetBufferOptDefault('table_mode_active', 0)
  let b:table_mode_active = !b:table_mode_active
endfunction

function! s:IsTableModeActive()
  if g:table_mode_always_active
    return 1
  endif

  call s:SetBufferOptDefault('table_mode_active', 0)
  return b:table_mode_active
endfunction

function! s:ConvertDelimiterToSeparator(line)
  execute 'silent! ' . a:line . 's/^\|' . g:table_mode_delimiter . '\|$/' . g:table_mode_separator . '/g'
endfunction

function! s:Tableize()
  if s:IsTableModeActive() && exists(':Tabularize') && getline('.') =~# ('^\s*' . g:table_mode_separator)
    let column = s:strlen(substitute(getline('.')[0:col('.')], '[^' . g:table_mode_separator . ']', '', 'g'))
    let position = s:strlen(matchstr(getline('.')[0:col('.')], '.*' . g:table_mode_separator . '\s*\zs.*'))
    if g:table_mode_border
      call s:UpdateLineBorder()
    endif
    exec 'Tabularize/[' . g:table_mode_separator . g:table_mode_corner . ']/l1'
    if g:table_mode_border
      call s:FillTableBorder()
    endif
    normal! 0
    call search(repeat('[^' . g:table_mode_separator . ']*' . g:table_mode_separator, column) . '\s\{-\}' . repeat('.', position), 'ce', line('.'))
  endif
endfunction

function! s:Tableizeline(line)
  call s:ConvertDelimiterToSeparator(a:line)
  call s:UpdateLineBorder(a:line)
  exec 'Tabularize/[' . g:table_mode_separator . g:table_mode_corner . ']/l1'
endfunction

function! s:TableizeRange() range
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

if !g:table_mode_always_active
  exec "nnoremap <silent> " . g:table_mode_toggle_map .
       \ " <Esc>:call <SID>TableModeToggle()<CR>"
  command! -nargs=0 TableModeToggle call s:TableModeToggle()
  command! -nargs=0 TableModeEnable call s:TableModeEnable()
  command! -nargs=0 TableModeDisable call s:TableModeDisable()
endif
exec "inoremap <silent> " . s:table_mode_separator_map . ' ' .
      \ s:table_mode_separator_map . "<Esc>:call <SID>Tableize()<CR>a"

command! -nargs=0 -range Tableize <line1>,<line2>call s:TableizeRange()
exec "xnoremap <silent> " . g:table_mode_tableize_map . " :Tableize<CR>"
