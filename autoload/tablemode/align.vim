" ==============================  Header ======================================
" File:          autoload/tablemode/align.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       https://github.com/dhruvasagar/vim-table-mode
" Version:       4.0.0
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

" Borrowed from Tabular
" Private Functions {{{1
" Return the number of bytes in a string after expanding tabs to spaces.  {{{2
" This expansion is done based on the current value of 'tabstop'
if exists('*strdisplaywidth')
  " Needs vim 7.3
  let s:Strlen = function("strdisplaywidth")
else
  function! s:Strlen(string)
    " Implement the tab handling part of strdisplaywidth for vim 7.2 and
    " earlier - not much that can be done about handling doublewidth
    " characters.
    let rv = 0
    let i = 0

    for char in split(a:string, '\zs')
      if char == "\t"
        let rv += &ts - i
        let i = 0
      else
        let rv += 1
        let i = (i + 1) % &ts
      endif
    endfor

    return rv
  endfunction
endif
" function! s:StripTrailingSpaces(string) - Remove all trailing spaces {{{2
" from a string.
function! s:StripTrailingSpaces(string)
  return matchstr(a:string, '^.\{-}\ze\s*$')
endfunction

function! s:Padding(string, length, where) "{{{3
  let gap_length = a:length - s:Strlen(a:string)
  if a:where =~# 'l'
    return a:string . repeat(" ", gap_length)
  elseif a:where =~# 'r'
    return repeat(" ", gap_length) . a:string
  elseif a:where =~# 'c'
    let right = spaces / 2
    let left = right + (right * 2 != gap_length)
    return repeat(" ", left) . a:string . repeat(" ", right)
  endif
endfunction

" function! s:Split() - Split a string into fields and delimiters {{{2
" Like split(), but include the delimiters as elements
" All odd numbered elements are delimiters
" All even numbered elements are non-delimiters (including zero)
function! s:Split(string, delim)
  let rv = []
  let beg = 0

  let len = len(a:string)
  let searchoff = 0

  while 1
    let mid = match(a:string, a:delim, beg + searchoff, 1)
    if mid == -1 || mid == len
      break
    endif

    let matchstr = matchstr(a:string, a:delim, beg + searchoff, 1)
    let length = strlen(matchstr)

    if length == 0 && beg == mid
      " Zero-length match for a zero-length delimiter - advance past it
      let searchoff += 1
      continue
    endif

    if beg == mid
      let rv += [ "" ]
    else
      let rv += [ a:string[beg : mid-1] ]
    endif

    let rv += [ matchstr ]

    let beg = mid + length
    let searchoff = 0
  endwhile

  let rv += [ strpart(a:string, beg) ]

  return rv
endfunction

" Public Functions {{{1
function! tablemode#align#sid() "{{{2
  return maparg('<sid>', 'n')
endfunction
nnoremap <sid> <sid>

function! tablemode#align#scope() "{{{2
  return s:
endfunction

function! tablemode#align#Align(lines) "{{{2
  let lines = map(a:lines, 's:Split(v:val, g:table_mode_separator)')

  for line in lines
    if len(line) <= 1 | continue | endif

    if line[0] !~ tablemode#table#StartExpr()
      let line[0] = s:StripTrailingSpaces(line[0])
    endif
    if len(line) >= 2
      for i in range(1, len(line)-1)
        let line[i] = tablemode#utils#strip(line[i])
      endfor
    endif
  endfor

  let maxes = []
  for line in lines
    if len(line) <= 1 | continue | endif
    for i in range(len(line))
      if i == len(maxes)
        let maxes += [ s:Strlen(line[i]) ]
      else
        let maxes[i] = max([ maxes[i], s:Strlen(line[i]) ])
      endif
    endfor
  endfor

  for idx in range(len(lines))
    let line = lines[idx]

    if len(line) <= 1 | continue | endif
    for i in range(len(line))
      if line[i] !~# '[^0-9\.]'
        let field = s:Padding(line[i], maxes[i], 'r')
      else
        let field = s:Padding(line[i], maxes[i], 'l')
      endif

      let line[i] = field . (i == 0 || i == len(line) ? '' : ' ')
    endfor

    let lines[idx] = s:StripTrailingSpaces(join(line, ''))
  endfor

  return lines
endfunction
