" ==============================  Header ======================================
" File:          autoload/tablemode.vim
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

" Private Functions {{{1

if exists('g:autoloaded_table_mode') "{{{2
  finish
endif
let g:autoloaded_table_mode = 1

function! s:throw(string) abort "{{{2
  let v:errmsg = 'table-mode: ' . a:string
  throw v:errmsg
endfunction

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

function! s:Line(line) "{{{2
  if type(a:line) == type('')
    return line(a:line)
  else
    return a:line
  endif
endfunction

" function! s:Strlen(text) - Count multibyte characters accurately {{{2
" See :h strlen() for more details
function! s:Strlen(text)
  return strlen(substitute(a:text, '.', 'x', 'g'))
endfunction

function! s:Strip(string) "{{{2
  return matchstr(a:string, '^\s*\zs.\{-}\ze\s*$')
endfunction

function! s:Sum(list) "{{{2
  let result = 0.0
  for item in a:list
    if type(item) == type(1) || type(item) == type(1.0)
      let result += item
    elseif type(item) == type('')
      let result += str2float(item)
    elseif type(item) == type([])
      let result += s:Sum(item)
    endif
  endfor
  return result
endfunction

function! s:Average(list) "{{{2
  return s:Sum(a:list)/len(a:list)
endfunction

function! s:GetCommentStart() "{{{2
  let cstring = &commentstring
  if s:Strlen(cstring) > 0
    return substitute(split(cstring, '%s')[0], '.', '\\\0', 'g')
  else
    return ''
  endif
endfunction

function! s:GetCommentEnd() "{{{2
  let cstring = &commentstring
  if s:Strlen(cstring) > 0
    let cst = split(cstring, '%s')
    if len(cst) == 2
      return substitute(cst[1], '.', '\\\0', 'g')
    else
      return ''
    endif
  else
    return ''
  endif
endfunction

function! s:StartExpr() "{{{2
  let cstart = s:GetCommentStart()
  if s:Strlen(cstart) > 0
    return '^\s*\(' . cstart . '\)\?\s*'
  else
    return '^\s*'
  endif
endfunction


function! s:EndExpr() "{{{2
  let cend = s:GetCommentEnd()
  if s:Strlen(cend) > 0
    return '\s*\(\s\+' . cend . '\)\?\s*$'
  else
    return '\s*$'
  endif
endfunction

function! s:HeaderBorderExpr() "{{{2
  return s:StartExpr() .
        \ '[' . g:table_mode_corner . g:table_mode_corner_corner . ']' .
        \ '[' . g:table_mode_fillchar . g:table_mode_corner . ']*' .
        \ '[' . g:table_mode_corner . g:table_mode_corner_corner . ']' .
        \ s:EndExpr()
endfunction

function! s:StartCommentExpr() "{{{2
  let cstartexpr = s:GetCommentStart()
  if s:Strlen(cstartexpr) > 0
    return '^\s*' . cstartexpr . '\s*'
  else
    return ''
  endif
endfunction

function! s:EndCommentExpr() "{{{2
  let cendexpr = s:GetCommentEnd()
  if s:Strlen(cendexpr) > 0
    return '.*\zs\s\+' . cendexpr . '\s*$'
  else
    return ''
  endif
endfunction

function! s:IsTableModeActive() "{{{2
  if g:table_mode_always_active | return 1 | endif

  call s:SetBufferOptDefault('table_mode_active', 0)
  return b:table_mode_active
endfunction

function! s:RowGap() "{{{2
  " Getting rid of borders, so the row gap is now just 1
  return 1
endfunction

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

function! s:SetActive(bool) "{{{2
  let b:table_mode_active = a:bool
  call s:ToggleMapping()
endfunction

function! s:DefaultHeaderBorder() "{{{2
  if s:IsTableModeActive()
    return g:table_mode_corner_corner . g:table_mode_fillchar . g:table_mode_corner . g:table_mode_fillchar . g:table_mode_corner_corner
  else
    return ''
  endif
endfunction

function! s:GenerateHeaderBorder(line) "{{{2
  let line = s:Line(a:line)
  if tablemode#IsATableRow(line - s:RowGap()) || tablemode#IsATableRow(line + s:RowGap())
    let line_val = ''
    if tablemode#IsATableRow(line + s:RowGap())
      let line_val = getline(line + s:RowGap())
    endif
    if tablemode#IsATableRow(line - s:RowGap()) && s:Strlen(line_val) < s:Strlen(getline(line - s:RowGap()))
      let line_val = getline(line - s:RowGap())
    endif
    if s:Strlen(line_val) <= 1 | return s:DefaultHeaderBorder() | endif
    let border = substitute(line_val[stridx(line_val, g:table_mode_separator):strridx(line_val, g:table_mode_separator)], g:table_mode_separator, g:table_mode_corner, 'g')
    let border = substitute(border, '[^' . g:table_mode_corner . ']', g:table_mode_fillchar, 'g')
    let border = substitute(border, '^' . g:table_mode_corner . '\(.*\)' . g:table_mode_corner . '$', g:table_mode_corner_corner . '\1' . g:table_mode_corner_corner, '')

    let cstartexpr = s:StartCommentExpr()
    if s:Strlen(cstartexpr) > 0 && getline(line) =~# cstartexpr
      let sce = matchstr(line_val, s:StartCommentExpr())
      let ece = matchstr(line_val, s:EndCommentExpr())
      return sce . border . ece
    elseif getline(line) =~# s:StartExpr()
      let indent = matchstr(line_val, s:StartExpr())
      return indent . border
    else
      return border
    endif
  else
    return s:DefaultHeaderBorder()
  endif
endfunction

function! s:ConvertDelimiterToSeparator(line, ...) "{{{2
  let gflag = 'g'
  if &gdefault | let gflag = 'gg' | endif

  let delim = g:table_mode_delimiter
  if a:0 | let delim = a:1 | endif
  if delim ==# ','
    silent! execute a:line . 's/' . "[\'\"][^\'\"]*\\zs,\\ze[^\'\"]*[\'\"]/__COMMA__/" . gflag
  endif

  let [cstart, cend] = [s:GetCommentStart(), s:GetCommentEnd()]
  let [match_char_start, match_char_end] = ['.', '.']
  if s:Strlen(cend) > 0 | let match_char_end = '[^' . cend . ']' | endif
  if s:Strlen(cstart) > 0 | let match_char_start = '[^' . cstart . ']' | endif

  silent! execute a:line . 's/' . s:StartExpr() . '\zs\ze' . match_char_start .
        \ '\|' . delim .  '\|' . match_char_end . '\zs\ze' . s:EndExpr() . '/' .
        \ g:table_mode_separator . '/' . gflag

  if delim ==# ','
    silent! execute a:line . 's/' . "[\'\"][^\'\"]*\\zs__COMMA__\\ze[^\'\"]*[\'\"]/,/" . gflag
  endif
endfunction

function! s:Tableizeline(line, ...) "{{{2
  let delim = g:table_mode_delimiter
  if a:0 && type(a:1) == type('') && !empty(a:1) | let delim = a:1[1:-1] | endif
  call s:ConvertDelimiterToSeparator(a:line, delim)
endfunction

function! s:IsFirstCell() "{{{2
  return tablemode#ColumnNr('.') ==# 1
endfunction

function! s:IsLastCell() "{{{2
  return tablemode#ColumnNr('.') ==# tablemode#ColumnCount('.')
endfunction

function! s:GetFirstRow(line) "{{{2
  if tablemode#IsATableRow(a:line)
    let line = s:Line(a:line)

    while tablemode#IsATableRow(line - s:RowGap()) || tablemode#IsATableHeader(line - s:RowGap())
      let line -= s:RowGap()
    endwhile
    if tablemode#IsATableHeader(line) | let line += s:RowGap() | endif

    return line
  endif
endfunction

function! s:MoveToFirstRow() "{{{2
  if tablemode#IsATableRow('.')
    call cursor(s:GetFirstRow('.'), col('.'))
  endif
endfunction

function! s:GetLastRow(line) "{{{2
  if tablemode#IsATableRow(a:line)
    let line = s:Line(a:line)

    while tablemode#IsATableRow(line + s:RowGap()) || tablemode#IsATableHeader(line + s:RowGap())
      let line += s:RowGap()
    endwhile
    if tablemode#IsATableHeader(line) | let line -= s:RowGap() | endif

    return line
  endif
endfunction

function! s:MoveToLastRow() "{{{2
  if tablemode#IsATableRow('.')
    call cursor(s:GetLastRow('.'), col('.'))
  endif
endfunction

function! s:LineNr(row) "{{{2
  if tablemode#IsATableRow('.')
    let line = s:GetFirstRow('.')
    let row_nr = 0

    while tablemode#IsATableRow(line + s:RowGap()) || tablemode#IsATableHeader(line + s:RowGap())
      if tablemode#IsATableRow(line)
        let row_nr += 1
        if row ==# row_nr | break | endif
      endif
      let line += s:RowGap()
    endwhile

    return line
  endif
endfunction

function! s:MoveToStartOfCell() "{{{2
  if getline('.')[col('.')-1] ==# g:table_mode_separator && !s:IsLastCell()
    normal! 2l
  else
    execute 'normal! F' . g:table_mode_separator . '2l'
  endif
endfunction

" function! s:GetCells() - Function to get values of cells in a table {{{2
" s:GetCells(row) - Get values of all cells in a row as a List.
" s:GetCells(0, col) - Get values of all cells in a column as a List.
" s:GetCells(row, col) - Get the value of table cell by given row, col.
function! s:GetCells(line, ...) abort
  let line = s:Line(a:line)

  if tablemode#IsATableRow(line)
    if a:0 < 1
      let [row, colm] = [line, 0]
    elseif a:0 < 2
      let [row, colm] = [a:1, 0]
    elseif a:0 < 3
      let [row, colm] = a:000
    endif

    let first_row = s:GetFirstRow(line)
    if row == 0
      let values = []
      let line = first_row
      while tablemode#IsATableRow(line) || tablemode#IsATableHeader(line)
        if tablemode#IsATableRow(line)
          let row_line = getline(line)[stridx(getline(line), g:table_mode_separator):strridx(getline(line), g:table_mode_separator)]
          call add(values, s:Strip(get(split(row_line, g:table_mode_separator), colm>0?colm-1:colm, '')))
        endif
        let line += s:RowGap()
      endwhile
      return values
    else
      let row_nr = 0
      let line = first_row
      while tablemode#IsATableRow(line) || tablemode#IsATableHeader(line)
        if tablemode#IsATableRow(line)
          let row_nr += 1
          if row ==# row_nr | break | endif
        endif
        let line += s:RowGap()
      endwhile

      let row_line = getline(line)[stridx(getline(line), g:table_mode_separator):strridx(getline(line), g:table_mode_separator)]
      if colm == 0
        return map(split(row_line, g:table_mode_separator), 's:Strip(v:val)')
      else
        let split_line = split(row_line, g:table_mode_separator)
        return s:Strip(get(split(row_line, g:table_mode_separator), colm>0?colm-1:colm, ''))
      endif
    endif
  endif
endfunction

function! s:GetCell(...) "{{{2
  if a:0 == 0
    let [row, colm] = [tablemode#RowNr('.'), tablemode#ColumnNr('.')]
  elseif a:0 == 2
    let [row, colm] = [a:1, a:2]
  endif

  return s:GetCells('.', row, col)
endfunction

function! s:SetCell(val, ...) abort "{{{2
  if a:0 == 0
    let [line, row, colm] = ['.', tablemode#RowNr('.'), tablemode#ColumnNr('.')]
  elseif a:0 == 2
    let [line, row, colm] = ['.', a:1, a:2]
  elseif a:0 == 3
    let [line, row, colm] = a:000
  endif

  if tablemode#IsATableRow(line)
    let line = s:Line(line) + (row - tablemode#RowNr(line)) * s:RowGap()
    let line_val = getline(line)
    let cstartexpr = s:StartCommentExpr()
    let values = split(getline(line)[stridx(line_val, g:table_mode_separator):strridx(line_val, g:table_mode_separator)], g:table_mode_separator)
    if len(values) < colm | return | endif
    let values[colm-1] = a:val
    let line_value = g:table_mode_separator . join(values, g:table_mode_separator) . g:table_mode_separator
    if s:Strlen(cstartexpr) > 0 && line_val =~# cstartexpr
      let sce = matchstr(line_val, s:StartCommentExpr())
      let ece = matchstr(line_val, s:EndCommentExpr())
      let line_value = sce . line_value . ece
    endif
    call setline(line, line_value)
    call tablemode#TableRealign(line)
  endif
endfunction

function! s:GetRow(row, ...) abort "{{{2
  let line = a:0 < 1 ? '.' : a:1
  return s:GetCells(line, a:row)
endfunction

function! s:GetRowColumn(col, ...) abort "{{{2
  let line = a:0 < 1 ? '.' : a:1
  let row = tablemode#RowNr('.')
  return s:GetCells(line, row, a:col)
endfunction

function! s:GetColumn(col, ...) abort "{{{2
  let line = a:0 < 1 ? '.' : a:1
  return s:GetCells(line, 0, a:col)
endfunction

function! s:GetColumnRow(row, ...) abort "{{{2
  let line = a:0 < 1 ? '.' : a:1
  let col = tablemode#ColumnNr('.')
  return s:GetCells(line, a:row, col)
endfunction

function! s:ParseRange(range, ...) "{{{2
  if a:0 < 1
    let default_col = tablemode#ColumnNr('.')
  elseif a:0 < 2
    let default_col = a:1
  endif

  if type(a:range) != type('')
    let range = string(a:range)
  else
    let range = a:range
  endif

  let [rowcol1, rowcol2] = split(range, ':')
  let [rcs1, rcs2] = [map(split(rowcol1, ','), 'str2nr(v:val)'), map(split(rowcol2, ','), 'str2nr(v:val)')]

  if len(rcs1) == 2
    let [row1, col1] = rcs1
  else
    let [row1, col1] = [rcs1[0], default_col]
  endif

  if len(rcs2) == 2
    let [row2, col2] = rcs2
  else
    let [row2, col2] = [rcs2[0], default_col]
  endif

  return [row1, col1, row2, col2]
endfunction

" function! s:GetCellRange(range, ...) {{{2
" range: A string representing range of cells.
"        - Can be row1:row2 for values in the current columns in those rows.
"        - Can be row1,col1:row2,col2 for range between row1,col1 till
"          row2,col2.
function! s:GetCellRange(range, ...) abort
  if a:0 < 1
    let [line, colm] = ['.', tablemode#ColumnNr('.')]
  elseif a:0 < 2
    let [line, colm] = [a:1, tablemode#ColumnNr('.')]
  elseif a:0 < 3
    let [line, colm] = [a:1, a:2]
  else
    call s:throw('Invalid Range')
  endif

  let values = []

  if tablemode#IsATableRow(line)
    let [row1, col1, row2, col2] = s:ParseRange(a:range, colm)

    if row1 == row2
      if col1 == col2
        call add(values, s:GetCells(line, row1, col1))
      else
        let values = s:GetRow(row1, line)[(col1-1):(col2-1)]
      endif
    else
      if col1 == col2
        let values = s:GetColumn(col1, line)[(row1-1):(row2-1)]
      else
        let tcol = col1
        while tcol <= col2
          call add(values, s:GetColumn(tcol, line)[(row1-1):(row2-1)])
          let tcol += 1
        endwhile
      endif
    endif
  endif

  return values
endfunction

" Borrowed from Tabular : {{{2

" function! s:StripTrailingSpaces(string) - Remove all trailing spaces {{{3
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

" function! s:Split() - Split a string into fields and delimiters {{{3
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

function! s:Align(lines) "{{{3
  let lines = map(a:lines, 's:Split(v:val, g:table_mode_separator)')

  for line in lines
    if len(line) <= 1 | continue | endif

    if line[0] !~ s:StartExpr()
      let line[0] = s:StripTrailingSpaces(line[0])
    endif
    if len(line) >= 2
      for i in range(1, len(line)-1)
        let line[i] = s:Strip(line[i])
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

" Public API {{{1

function! tablemode#sid() "{{{2
  return maparg('<SID>', 'n')
endfunction
nnoremap <SID> <SID>

function! tablemode#scope() "{{{2
  return s:
endfunction

function! tablemode#GetLastRow(line) "{{{2
  return s:GetLastRow(a:line)
endfunction

function! tablemode#GetFirstRow(line) "{{{2
  return s:GetFirstRow(a:line)
endfunction

function! tablemode#TableizeInsertMode() "{{{2
  if s:IsTableModeActive() && getline('.') =~# (s:StartExpr() . g:table_mode_separator . g:table_mode_separator)
    call tablemode#AddHeaderBorder('.')
    normal! A
  elseif s:IsTableModeActive() && getline('.') =~# (s:StartExpr() . g:table_mode_separator)
    let column = s:Strlen(substitute(getline('.')[0:col('.')], '[^' . g:table_mode_separator . ']', '', 'g'))
    let position = s:Strlen(matchstr(getline('.')[0:col('.')], '.*' . g:table_mode_separator . '\s*\zs.*'))
    call tablemode#TableRealign('.')
    normal! 0
    call search(repeat('[^' . g:table_mode_separator . ']*' . g:table_mode_separator, column) . '\s\{-\}' . repeat('.', position), 'ce', line('.'))
  endif
endfunction

function! tablemode#TableModeEnable() "{{{2
  call s:SetActive(1)
endfunction

function! tablemode#TableModeDisable() "{{{2
  call s:SetActive(0)
endfunction

function! tablemode#TableModeToggle() "{{{2
  if g:table_mode_always_active
    return 1
  endif

  call s:SetBufferOptDefault('table_mode_active', 0)
  call s:SetActive(!b:table_mode_active)
endfunction

function! tablemode#TableizeRange(...) range "{{{2
  let lnum = a:firstline
  while lnum < (a:firstline + (a:lastline - a:firstline + 1)*s:RowGap())
    call s:Tableizeline(lnum, a:1)
    undojoin
    let lnum += s:RowGap()
  endwhile

  call tablemode#TableRealign(lnum - s:RowGap())
endfunction

function! tablemode#TableizeByDelimiter() "{{{2
  let delim = input('/')
  if delim =~# "\<Esc>" || delim =~# "\<C-C>" | return | endif
  let vm = visualmode()
  if vm ==? 'line' || vm ==? 'V'
    exec line("'<") . ',' . line("'>") . "call tablemode#TableizeRange('/' . delim)"
  endif
endfunction

function! tablemode#AddHeaderBorder(line) "{{{2
  call setline(a:line, s:GenerateHeaderBorder(a:line))
endfunction

function! tablemode#TableRealign(line) "{{{2
  let line = s:Line(a:line)

  let [lnums, lines] = [[], []]
  let [tline, blines] = [line, []]
  while tablemode#IsATableRow(tline) || tablemode#IsATableHeader(tline)
    if tablemode#IsATableHeader(tline)
      call insert(blines, tline)
      let tline -= s:RowGap()
      continue
    endif
    call insert(lnums, tline)
    call insert(lines, getline(tline))
    let tline -= s:RowGap()
  endwhile

  let tline = line + s:RowGap()

  while tablemode#IsATableRow(tline) || tablemode#IsATableHeader(tline)
    if tablemode#IsATableHeader(tline)
      call insert(blines, tline)
      let tline += s:RowGap()
      continue
    endif
    call add(lnums, tline)
    call add(lines, getline(tline))
    let tline += s:RowGap()
  endwhile

  let lines = s:Align(lines)

  for lnum in lnums
    let index = index(lnums, lnum)
    call setline(lnum, lines[index])
  endfor

  for bline in blines
    call tablemode#AddHeaderBorder(bline)
  endfor
endfunction

function! tablemode#IsATableRow(line) "{{{2
  return getline(a:line) =~# (s:StartExpr() . g:table_mode_separator . '[^' .
        \ g:table_mode_fillchar . ']*[^' . g:table_mode_corner . ']*$')
endfunction

function! tablemode#IsATableHeader(line) "{{{2
  return getline(a:line) =~# s:HeaderBorderExpr()
endfunction

function! tablemode#LineNr(row) "{{{2
  return s:LineNr(row)
endfunction

function! tablemode#RowCount(line) "{{{2
  let line = s:Line(a:line)

  let [tline, totalRowCount] = [line, 0]
  while tablemode#IsATableRow(tline) || tablemode#IsATableHeader(tline)
    if tablemode#IsATableRow(tline) | let totalRowCount += 1 | endif
    let tline -= s:RowGap()
  endwhile

  let tline = line + s:RowGap()
  while tablemode#IsATableRow(tline) || tablemode#IsATableHeader(tline)
    if tablemode#IsATableRow(tline) | let totalRowCount += 1 | endif
    let tline += s:RowGap()
  endwhile

  return totalRowCount
endfunction

function! tablemode#RowNr(line) "{{{2
  let line = s:Line(a:line)

  let rowNr = 0
  while tablemode#IsATableRow(line) || tablemode#IsATableHeader(line)
    if tablemode#IsATableRow(line) | let rowNr += 1 | endif
    let line -= s:RowGap()
  endwhile

  return rowNr
endfunction

function! tablemode#ColumnCount(line) "{{{2
  let line = s:Line(a:line)

  return s:Strlen(substitute(getline(line), '[^' . g:table_mode_separator . ']', '', 'g'))-1
endfunction

function! tablemode#ColumnNr(pos) "{{{2
  let pos = []
  if type(a:pos) == type('')
    let pos = [line(a:pos), col(a:pos)]
  elseif type(a:pos) == type([])
    let pos = a:pos
  else
    return 0
  endif
  let row_start = stridx(getline(pos[0]), g:table_mode_separator)
  return s:Strlen(substitute(getline(pos[0])[(row_start):pos[1]-2], '[^' . g:table_mode_separator . ']', '', 'g'))
endfunction

function! tablemode#TableMotion(direction) "{{{2
  if tablemode#IsATableRow('.')
    if a:direction ==# 'l'
      if s:IsLastCell()
        if !tablemode#IsATableRow(line('.') + s:RowGap()) || (tablemode#IsATableHeader(line('.') + s:RowGap()) && tablemode#IsATableRow(line('.') + 2 * s:RowGap()))
          return
        endif
        call tablemode#TableMotion('j')
        normal! 0
      endif

      " If line starts with g:table_mode_separator
      if getline('.')[col('.')-1] ==# g:table_mode_separator
        normal! 2l
      else
        execute 'normal! f' . g:table_mode_separator . '2l'
      endif
    elseif a:direction ==# 'h'
      if s:IsFirstCell()
        if !tablemode#IsATableRow(line('.') - s:RowGap()) || (tablemode#IsATableHeader(line('.') - s:RowGap()) && tablemode#IsATableRow(line('.') - 2 * s:RowGap()))
          return
        endif
        call tablemode#TableMotion('k')
        normal! $
      endif

      " If line ends with g:table_mode_separator
      if getline('.')[col('.')-1] ==# g:table_mode_separator
        execute 'normal! F' . g:table_mode_separator . '2l'
      else
        execute 'normal! 2F' . g:table_mode_separator . '2l'
      endif
    elseif a:direction ==# 'j'
      if tablemode#IsATableRow(line('.') + s:RowGap())
        execute 'normal! ' . s:RowGap() . 'j'
      elseif tablemode#IsATableHeader(line('.') + s:RowGap()) && tablemode#IsATableRow(line('.') + 2 * s:RowGap())
        execute 'normal! ' . (s:RowGap() + 1) . 'j'
      endif
    elseif a:direction ==# 'k'
      if tablemode#IsATableRow(line('.') - s:RowGap())
        execute 'normal! ' . s:RowGap() . 'k'
      elseif tablemode#IsATableHeader(line('.') - s:RowGap()) && tablemode#IsATableRow(line('.') - 2 * s:RowGap())
        execute 'normal! ' . (s:RowGap() + 1) . 'k'
      endif
    endif
  endif
endfunction

function! tablemode#CellTextObject() "{{{2
  if tablemode#IsATableRow('.')
    call s:MoveToStartOfCell()

    if v:operator ==# 'y'
      normal! v
      call search('[^' . g:table_mode_separator . ']\ze\s*' . g:table_mode_separator)
    else
      execute 'normal! vf' . g:table_mode_separator
    endif
  endif
endfunction

function! tablemode#DeleteColumn() "{{{2
  if tablemode#IsATableRow('.')
    for i in range(v:count1)
      call s:MoveToStartOfCell()
      call s:MoveToFirstRow()
      silent! execute "normal! h\<C-V>f" . g:table_mode_separator
      call s:MoveToLastRow()
      normal! d
    endfor

    call tablemode#TableRealign('.')
  endif
endfunction

function! tablemode#DeleteRow() "{{{2
  if tablemode#IsATableRow('.')
    for i in range(v:count1)
      if tablemode#IsATableRow('.')
        normal! dd
      endif

      if !tablemode#IsATableRow('.')
        normal! k
      endif
    endfor

    call tablemode#TableRealign('.')
  endif
endfunction

function! tablemode#GetCells(...) abort "{{{2
  let args = copy(a:000)
  call insert(args, '.')
  return call('s:GetCells', args)
endfunction

function! tablemode#SetCell(val, ...) "{{{2
  let args = copy(a:000)
  call insert(args, a:val)
  call call('s:SetCell', args)
endfunction

function! tablemode#GetCellRange(range, ...) abort "{{{2
  let args = copy(a:000)
  call insert(args, a:range)
  return call('s:GetCellRange', args)
endfunction

function! tablemode#Sum(range, ...) abort "{{{2
  let args = copy(a:000)
  call insert(args, a:range)
  return s:Sum(call('s:GetCellRange', args))
endfunction

function! tablemode#Average(range, ...) abort "{{{2
  let args = copy(a:000)
  call insert(args, a:range)
  return s:Average(call('s:GetCellRange', args))
endfunction

function! tablemode#AddFormula() "{{{2
  let fr = input('f=')
  let row = tablemode#RowNr('.')
  let colm = tablemode#ColumnNr('.')
  let indent = indent('.')
  let indent_str = repeat(' ', indent)

  if fr !=# ''
    let fr = '$' . row . ',' . colm . '=' . fr
    let fline = tablemode#GetLastRow('.') + s:RowGap()
    if tablemode#IsATableHeader(fline) | let fline += s:RowGap() | endif
    let cursor_pos = [line('.'), col('.')]
    if getline(fline) =~# 'tmf: '
      " Comment line correctly
      let line_val = getline(fline)
      let line_expr = line_val[match(line_val, s:StartCommentExpr()):match(line_val, s:EndCommentExpr())]
      let sce = matchstr(line_val, s:StartCommentExpr() . '\zs')
      let ece = matchstr(line_val, s:EndCommentExpr())
      call setline(fline, sce . line_expr . '; ' . fr . ece)
    else
      let cstring = &commentstring
      let [cmss, cmse] = ['', '']
      if len(cstring) > 0
        let cms = split(cstring, '%s')
        if len(cms) == 2
          let [cmss, cmse] = cms
        else
          let [cmss, cmse] = [cms[0], '']
        endif
      endif
      let fr = indent_str . cmss . ' tmf: ' . fr . ' ' . cmse
      call append(fline-1, fr)
      call cursor(cursor_pos)
    endif
    call tablemode#EvaluateFormulaLine()
  endif
endfunction

function! tablemode#EvaluateExpr(expr, line) abort "{{{2
  let line = s:Line(a:line)
  let [target, expr] = map(split(a:expr, '='), 's:Strip(v:val)')
  let cell = substitute(target, '\$', '', '')
  if cell =~# ','
    let [row, colm] = map(split(cell, ','), 'str2nr(v:val)')
  else
    let [row, colm] = [0, str2nr(cell)]
  endif

  if expr =~# 'Sum(.*)'
    let expr = substitute(expr, 'Sum(\([^)]*\))', 'tablemode#Sum("\1",'.line.','.colm.')', 'g')
  endif

  if expr =~# 'Average(.*)'
    let expr = substitute(expr, 'Average(\([^)]*\))', 'tablemode#Average("\1",'.line.','.colm.')', 'g')
  endif

  if expr =~# '\$\d\+,\d\+'
    let expr = substitute(expr, '\$\(\d\+\),\(\d\+\)',
          \ '\=str2float(s:GetCells(line, submatch(1), submatch(2)))', 'g')
  endif

  if cell =~# ','
    if expr =~# '\$'
      let expr = substitute(expr, '\$\(\d\+\)',
          \ '\=str2float(s:GetCells(line, row, submatch(1)))', 'g')
    endif
    call s:SetCell(eval(expr), line, row, colm)
  else
    let [row, line] = [1, s:GetFirstRow(line)]
    while tablemode#IsATableRow(line)
      let texpr = expr
      if expr =~# '\$'
        let texpr = substitute(texpr, '\$\(\d\+\)',
              \ '\=str2float(s:GetCells(line, row, submatch(1)))', 'g')
      endif

      call s:SetCell(eval(texpr), line, row, colm)
      let row += 1
      let line += s:RowGap()
    endwhile
  endif
endfunction

function! tablemode#EvaluateFormulaLine() abort "{{{2
  let exprs = []
  let cstring = &commentstring
  let matchexpr = ''
  if len(cstring) > 0
    let cms = split(cstring, '%s')
    if len(cms) == 2
      let matchexpr = '^\s*' . escape(cms[0], '/*') . '\s*tmf: \zs.*\ze' . escape(cms[1], '/*') . '\s*$'
    else
      let matchexpr = '^\s*' . escape(cms[0], '/*') . '\s*tmf: \zs.*$'
    endif
  else
    let matchexpr = '^\s* tmf: \zs.*$'
  endif
  if tablemode#IsATableRow('.') " We're inside the table
    let line = s:GetLastRow('.')
    let fline = line + s:RowGap()
    if tablemode#IsATableHeader(fline) | let fline += s:RowGap() | endif
    if getline(fline) =~# 'tmf: '
      let exprs = split(matchstr(getline(fline), matchexpr), ';')
    endif
  elseif getline('.') =~# 'tmf: ' " We're on the formula line
    let line = line('.') - s:RowGap()
    if tablemode#IsATableHeader(line) | let line -= s:RowGap() | endif
    if tablemode#IsATableRow(line)
      let exprs = split(matchstr(getline('.'), matchexpr), ';')
    endif
  endif

  for expr in exprs
    call tablemode#EvaluateExpr(expr, line)
  endfor
endfunction

" vim: sw=2 sts=2 fdl=0 fdm=marker
