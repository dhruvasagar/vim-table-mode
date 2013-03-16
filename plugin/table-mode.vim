" =============================================================================
" File:          table-mode.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Notes:         This was inspired by Tim Pope's cucumbertables.vim
"                (https://gist.github.com/tpope/287147)
" =============================================================================
"
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

function! s:CountSeparator(line, separator)
  return strlen(substitute(getline(a:line), '[^' . a:separator . ']', '', 'g'))
endfunction

function! s:UpdateTableBorder()
  let hf = '^\s*' . g:table_mode_corner . '[' . g:table_mode_corner . ' ' . g:table_mode_fillchar . ']*' . g:table_mode_corner . '\?\s*$'
  
  if getline(line('.')-1) =~# hf
    if s:CountSeparator(line('.')-1, g:table_mode_corner) < s:CountSeparator(line('.'), g:table_mode_separator)
      exec 'normal! kA' . g:table_mode_corner . "\<Esc>j"
    endif
  else
    call append(line('.')-1, g:table_mode_corner)
  endif

  if getline(line('.')+1) =~# hf
    if s:CountSeparator(line('.')+1, g:table_mode_corner) < s:CountSeparator(line('.'), g:table_mode_separator)
      exec 'normal! jA' . g:table_mode_corner . "\<Esc>k"
    end
  else
    call append(line('.'), g:table_mode_corner)
  endif
endfunction

function! s:FillTableBorder()
  let current_col = col('.')
  let current_line = line('.')
  execute '%s/' . g:table_mode_corner . ' \zs\([\' . g:table_mode_fillchar . ' ]*\)\ze ' . g:table_mode_corner . '/\=repeat("' . g:table_mode_fillchar . '", strlen(submatch(0)))/ge'
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

function! s:Tableize()
  if s:IsTableModeActive() && exists(':Tabularize') && getline('.') =~# ('^\s*' . g:table_mode_separator)
    let column = strlen(substitute(getline('.')[0:col('.')], '[^' . g:table_mode_separator . ']', '', 'g'))
    let position = strlen(matchstr(getline('.')[0:col('.')], '.*' . g:table_mode_separator . '\s*\zs.*'))
    if g:table_mode_border
      call s:UpdateTableBorder()
    endif
    exec 'Tabularize/[' . g:table_mode_separator . g:table_mode_corner . ']/l1'
    if g:table_mode_border
      call s:FillTableBorder()
    endif
    normal! 0
    call search(repeat('[^' . g:table_mode_separator . ']*' . g:table_mode_separator, column) . '\s\{-\}' . repeat('.', position), 'ce', line('.'))
  endif
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
