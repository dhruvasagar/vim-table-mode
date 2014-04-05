" ==============================  Header ======================================
" File:          autoload/tablemode/table.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       https://github.com/dhruvasagar/vim-table-mode
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
function! s:StartCommentExpr() "{{{2
  let cstartexpr = tablemode#table#GetCommentStart()
  if tablemode#utils#strlen(cstartexpr) > 0
    return '^\s*' . cstartexpr . '\s*'
  else
    return ''
  endif
endfunction

function! s:EndCommentExpr() "{{{2
  let cendexpr = tablemode#table#GetCommentEnd()
  if tablemode#utils#strlen(cendexpr) > 0
    return '.*\zs\s\+' . cendexpr . '\s*$'
  else
    return ''
  endif
endfunction

function! s:HeaderBorderExpr() "{{{2
  return tablemode#table#StartExpr() .
        \ '[' . g:table_mode_corner . g:table_mode_corner_corner . ']' .
        \ '[' . g:table_mode_fillchar . g:table_mode_corner . ']*' .
        \ '[' . g:table_mode_corner . g:table_mode_corner_corner . ']' .
        \ tablemode#table#EndExpr()
endfunction

function! s:DefaultHeaderBorder() "{{{2
  if s:IsTableModeActive()
    return g:table_mode_corner_corner . g:table_mode_fillchar . g:table_mode_corner . g:table_mode_fillchar . g:table_mode_corner_corner
  else
    return ''
  endif
endfunction

function! s:GenerateHeaderBorder(line) "{{{2
  let line = tablemode#utils#line(a:line)
  if tablemode#table#IsATableRow(line - 1) || tablemode#table#IsATableRow(line + 1)
    let line_val = ''
    if tablemode#table#IsATableRow(line + 1)
      let line_val = getline(line + 1)
    endif
    if tablemode#table#IsATableRow(line - 1) && tablemode#utils#strlen(line_val) < tablemode#utils#strlen(getline(line - 1))
      let line_val = getline(line - 1)
    endif
    if tablemode#utils#strlen(line_val) <= 1 | return s:DefaultHeaderBorder() | endif
    let border = substitute(line_val[stridx(line_val, g:table_mode_separator):strridx(line_val, g:table_mode_separator)], g:table_mode_separator, g:table_mode_corner, 'g')
    let border = substitute(border, '[^' . g:table_mode_corner . ']', g:table_mode_fillchar, 'g')
    let border = substitute(border, '^' . g:table_mode_corner . '\(.*\)' . g:table_mode_corner . '$', g:table_mode_corner_corner . '\1' . g:table_mode_corner_corner, '')

    let cstartexpr = s:StartCommentExpr()
    if tablemode#utils#strlen(cstartexpr) > 0 && getline(line) =~# cstartexpr
      let sce = matchstr(line_val, s:StartCommentExpr())
      let ece = matchstr(line_val, s:EndCommentExpr())
      return sce . border . ece
    elseif getline(line) =~# tablemode#table#StartExpr()
      let indent = matchstr(line_val, tablemode#table#StartExpr())
      return indent . border
    else
      return border
    endif
  else
    return s:DefaultHeaderBorder()
  endif
endfunction

function! s:IsFirstCell() "{{{2
  return tablemode#table#ColumnNr('.') ==# 1
endfunction

function! s:IsLastCell() "{{{2
  return tablemode#table#ColumnNr('.') ==# tablemode#table#ColumnCount('.')
endfunction

function! s:GetFirstRow(line) "{{{2
  if tablemode#table#IsATableRow(a:line)
    let line = tablemode#utils#line(a:line)

    while tablemode#table#IsATableRow(line - 1) || tablemode#table#IsATableHeader(line - 1)
      let line -= 1
    endwhile
    if tablemode#table#IsATableHeader(line) | let line += 1 | endif

    return line
  endif
endfunction

function! s:MoveToFirstRow() "{{{2
  if tablemode#table#IsATableRow('.')
    call cursor(s:GetFirstRow('.'), col('.'))
  endif
endfunction

function! s:GetLastRow(line) "{{{2
  if tablemode#table#IsATableRow(a:line)
    let line = tablemode#utils#line(a:line)

    while tablemode#table#IsATableRow(line + 1) || tablemode#table#IsATableHeader(line + 1)
      let line += 1
    endwhile
    if tablemode#table#IsATableHeader(line) | let line -= 1 | endif

    return line
  endif
endfunction

function! s:MoveToLastRow() "{{{2
  if tablemode#table#IsATableRow('.')
    call cursor(s:GetLastRow('.'), col('.'))
  endif
endfunction

function! s:MoveToStartOfCell() "{{{2
  if getline('.')[col('.')-1] ==# g:table_mode_separator && !s:IsLastCell()
    normal! 2l
  else
    execute 'normal! F' . g:table_mode_separator . '2l'
  endif
endfunction

function! s:LineNr(row) "{{{2
  if tablemode#table#IsATableRow('.')
    let line = s:GetFirstRow('.')
    let row_nr = 0

    while tablemode#table#IsATableRow(line + 1) || tablemode#table#IsATableHeader(line + 1)
      if tablemode#table#IsATableRow(line)
        let row_nr += 1
        if row ==# row_nr | break | endif
      endif
      let line += 1
    endwhile

    return line
  endif
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

" function! s:GetCells() - Function to get values of cells in a table {{{2
" s:GetCells(row) - Get values of all cells in a row as a List.
" s:GetCells(0, col) - Get values of all cells in a column as a List.
" s:GetCells(row, col) - Get the value of table cell by given row, col.
function! s:GetCells(line, ...) abort
  let line = tablemode#utils#line(a:line)

  if tablemode#table#IsATableRow(line)
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
      while tablemode#table#IsATableRow(line) || tablemode#table#IsATableHeader(line)
        if tablemode#table#IsATableRow(line)
          let row_line = getline(line)[stridx(getline(line), g:table_mode_separator):strridx(getline(line), g:table_mode_separator)]
          call add(values, tablemode#utils#strip(get(split(row_line, g:table_mode_separator), colm>0?colm-1:colm, '')))
        endif
        let line += 1
      endwhile
      return values
    else
      let row_nr = 0
      let line = first_row
      while tablemode#table#IsATableRow(line) || tablemode#table#IsATableHeader(line)
        if tablemode#table#IsATableRow(line)
          let row_nr += 1
          if row ==# row_nr | break | endif
        endif
        let line += 1
      endwhile

      let row_line = getline(line)[stridx(getline(line), g:table_mode_separator):strridx(getline(line), g:table_mode_separator)]
      if colm == 0
        return map(split(row_line, g:table_mode_separator), 'tablemode#utils#strip(v:val)')
      else
        let split_line = split(row_line, g:table_mode_separator)
        return tablemode#utils#strip(get(split(row_line, g:table_mode_separator), colm>0?colm-1:colm, ''))
      endif
    endif
  endif
endfunction

function! s:GetCell(...) "{{{2
  if a:0 == 0
    let [row, colm] = [tablemode#RowNr('.'), tablemode#table#ColumnNr('.')]
  elseif a:0 == 2
    let [row, colm] = [a:1, a:2]
  endif

  return s:GetCells('.', row, col)
endfunction

function! s:SetCell(val, ...) abort "{{{2
  if a:0 == 0
    let [line, row, colm] = ['.', tablemode#RowNr('.'), tablemode#table#ColumnNr('.')]
  elseif a:0 == 2
    let [line, row, colm] = ['.', a:1, a:2]
  elseif a:0 == 3
    let [line, row, colm] = a:000
  endif

  if tablemode#table#IsATableRow(line)
    let line = tablemode#utils#line(line) + (row - tablemode#RowNr(line)) * 1
    let line_val = getline(line)
    let cstartexpr = s:StartCommentExpr()
    let values = split(getline(line)[stridx(line_val, g:table_mode_separator):strridx(line_val, g:table_mode_separator)], g:table_mode_separator)
    if len(values) < colm | return | endif
    let values[colm-1] = a:val
    let line_value = g:table_mode_separator . join(values, g:table_mode_separator) . g:table_mode_separator
    if tablemode#utils#strlen(cstartexpr) > 0 && line_val =~# cstartexpr
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
  let col = tablemode#table#ColumnNr('.')
  return s:GetCells(line, a:row, col)
endfunction

function! s:ParseRange(range, ...) "{{{2
  if a:0 < 1
    let default_col = tablemode#table#ColumnNr('.')
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
    let [line, colm] = ['.', tablemode#table#ColumnNr('.')]
  elseif a:0 < 2
    let [line, colm] = [a:1, tablemode#table#ColumnNr('.')]
  elseif a:0 < 3
    let [line, colm] = [a:1, a:2]
  else
    call s:throw('Invalid Range')
  endif

  let values = []

  if tablemode#table#IsATableRow(line)
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
  let gap_length = a:length - tablemode#utils#strlen(a:string)
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
        let maxes += [ tablemode#utils#strlen(line[i]) ]
      else
        let maxes[i] = max([ maxes[i], tablemode#utils#strlen(line[i]) ])
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

" Public Functions {{{1
function! tablemode#table#sid() "{{{2
  return maparg('<sid>', 'n')
endfunction
nnoremap <sid> <sid>

function! tablemode#table#scope() "{{{2
  return s:
endfunction

function! tablemode#table#StartExpr() "{{{2
  let cstart = tablemode#table#GetCommentStart()
  if tablemode#utils#strlen(cstart) > 0
    return '^\s*\(' . cstart . '\)\?\s*'
  else
    return '^\s*'
  endif
endfunction

function! tablemode#table#EndExpr() "{{{2
  let cend = tablemode#table#GetCommentEnd()
  if tablemode#utils#strlen(cend) > 0
    return '\s*\(\s\+' . cend . '\)\?\s*$'
  else
    return '\s*$'
  endif
endfunction

function! tablemode#table#GetCommentStart() "{{{2
  let cstring = &commentstring
  if tablemode#utils#strlen(cstring) > 0
    return substitute(split(cstring, '%s')[0], '.', '\\\0', 'g')
  else
    return ''
  endif
endfunction

function! tablemode#table#GetCommentEnd() "{{{2
  let cstring = &commentstring
  if tablemode#utils#strlen(cstring) > 0
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

function! tablemode#table#RowCount(line) "{{{2
  let line = tablemode#utils#line(a:line)

  let [tline, totalRowCount] = [line, 0]
  while tablemode#table#IsATableRow(tline) || tablemode#table#IsATableHeader(tline)
    if tablemode#table#IsATableRow(tline) | let totalRowCount += 1 | endif
    let tline -= 1
  endwhile

  let tline = line + 1
  while tablemode#table#IsATableRow(tline) || tablemode#table#IsATableHeader(tline)
    if tablemode#table#IsATableRow(tline) | let totalRowCount += 1 | endif
    let tline += 1
  endwhile

  return totalRowCount
endfunction

function! tablemode#table#RowNr(line) "{{{2
  let line = tablemode#utils#line(a:line)

  let rowNr = 0
  while tablemode#table#IsATableRow(line) || tablemode#table#IsATableHeader(line)
    if tablemode#table#IsATableRow(line) | let rowNr += 1 | endif
    let line -= 1
  endwhile

  return rowNr
endfunction

function! tablemode#table#ColumnCount(line) "{{{2
  let line = tablemode#utils#line(a:line)

  return tablemode#utils#strlen(substitute(getline(line), '[^' . g:table_mode_separator . ']', '', 'g'))-1
endfunction

function! tablemode#table#ColumnNr(pos) "{{{2
  let pos = []
  if type(a:pos) == type('')
    let pos = [line(a:pos), col(a:pos)]
  elseif type(a:pos) == type([])
    let pos = a:pos
  else
    return 0
  endif
  let row_start = stridx(getline(pos[0]), g:table_mode_separator)
  return tablemode#utils#strlen(substitute(getline(pos[0])[(row_start):pos[1]-2], '[^' . g:table_mode_separator . ']', '', 'g'))
endfunction

function! tablemode#table#IsATableRow(line) "{{{2
  return getline(a:line) =~# (tablemode#table#StartExpr() . g:table_mode_separator . '[^' .
        \ g:table_mode_fillchar . ']*[^' . g:table_mode_corner . ']*$')
endfunction

function! tablemode#table#IsATableHeader(line) "{{{2
  return getline(a:line) =~# s:HeaderBorderExpr()
endfunction

function! tablemode#table#GetLastRow(line) "{{{2
  return s:GetLastRow(a:line)
endfunction

function! tablemode#table#GetFirstRow(line) "{{{2
  return s:GetFirstRow(a:line)
endfunction

function! tablemode#table#AddHeaderBorder(line) "{{{2
  call setline(a:line, s:GenerateHeaderBorder(a:line))
endfunction

function! tablemode#table#TableRealign(line) "{{{2
  let line = tablemode#utils#line(a:line)

  let [lnums, lines] = [[], []]
  let [tline, blines] = [line, []]
  while tablemode#table#IsATableRow(tline) || tablemode#table#IsATableHeader(tline)
    if tablemode#table#IsATableHeader(tline)
      call insert(blines, tline)
      let tline -= 1
      continue
    endif
    call insert(lnums, tline)
    call insert(lines, getline(tline))
    let tline -= 1
  endwhile

  let tline = line + 1

  while tablemode#table#IsATableRow(tline) || tablemode#table#IsATableHeader(tline)
    if tablemode#table#IsATableHeader(tline)
      call insert(blines, tline)
      let tline += 1
      continue
    endif
    call add(lnums, tline)
    call add(lines, getline(tline))
    let tline += 1
  endwhile

  let lines = s:Align(lines)

  for lnum in lnums
    let index = index(lnums, lnum)
    call setline(lnum, lines[index])
  endfor

  for bline in blines
    call tablemode#table#AddHeaderBorder(bline)
  endfor
endfunction

function! tablemode#table#DeleteColumn() "{{{2
  if tablemode#table#IsATableRow('.')
    for i in range(v:count1)
      call s:MoveToStartOfCell()
      call s:MoveToFirstRow()
      silent! execute "normal! h\<C-V>f" . g:table_mode_separator
      call s:MoveToLastRow()
      normal! d
    endfor

    call tablemode#table#TableRealign('.')
  endif
endfunction

function! tablemode#table#DeleteRow() "{{{2
  if tablemode#table#IsATableRow('.')
    for i in range(v:count1)
      if tablemode#table#IsATableRow('.')
        normal! dd
      endif

      if !tablemode#table#IsATableRow('.')
        normal! k
      endif
    endfor

    call tablemode#table#TableRealign('.')
  endif
endfunction

function! tablemode#table#GetCells(...) abort "{{{2
  let args = copy(a:000)
  call insert(args, '.')
  return call('s:GetCells', args)
endfunction

function! tablemode#table#SetCell(val, ...) "{{{2
  let args = copy(a:000)
  call insert(args, a:val)
  call call('s:SetCell', args)
endfunction

function! tablemode#table#GetCellRange(range, ...) abort "{{{2
  let args = copy(a:000)
  call insert(args, a:range)
  return call('s:GetCellRange', args)
endfunction

function! tablemode#table#TableMotion(direction, ...) "{{{2
  let l:count = a:0 ? a:1 : v:count1
  if tablemode#table#IsATableRow('.')
    for ii in range(l:count)
      if a:direction ==# 'l'
        if s:IsLastCell()
          if !tablemode#table#IsATableRow(line('.') + 1) || (tablemode#table#IsATableHeader(line('.') + 1) && !tablemode#table#IsATableRow(line('.') + 2 * 1))
            return
          endif
          call tablemode#table#TableMotion('j', 1)
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
          if !tablemode#table#IsATableRow(line('.') - 1) || (tablemode#table#IsATableHeader(line('.') - 1) && !tablemode#table#IsATableRow(line('.') - 2 * 1))
            return
          endif
          call tablemode#table#TableMotion('k', 1)
          normal! $
        endif

        " If line ends with g:table_mode_separator
        if getline('.')[col('.')-1] ==# g:table_mode_separator
          execute 'normal! F' . g:table_mode_separator . '2l'
        else
          execute 'normal! 2F' . g:table_mode_separator . '2l'
        endif
      elseif a:direction ==# 'j'
        if tablemode#table#IsATableRow(line('.') + 1)
          execute 'normal! ' . 1 . 'j'
        elseif tablemode#table#IsATableHeader(line('.') + 1) && tablemode#table#IsATableRow(line('.') + 2 * 1)
          execute 'normal! ' . (1 + 1) . 'j'
        endif
      elseif a:direction ==# 'k'
        if tablemode#table#IsATableRow(line('.') - 1)
          execute 'normal! ' . 1 . 'k'
        elseif tablemode#table#IsATableHeader(line('.') - 1) && tablemode#table#IsATableRow(line('.') - 2 * 1)
          execute 'normal! ' . (1 + 1) . 'k'
        endif
      endif
    endfor
  endif
endfunction

function! tablemode#table#TableMotion(direction, ...) "{{{2
  let l:count = a:0 ? a:1 : v:count1
  if tablemode#table#IsATableRow('.')
    for ii in range(l:count)
      if a:direction ==# 'l'
        if s:IsLastCell()
          if !tablemode#table#IsATableRow(line('.') + 1) || (tablemode#table#IsATableHeader(line('.') + 1) && !tablemode#table#IsATableRow(line('.') + 2 * 1))
            return
          endif
          call tablemode#table#TableMotion('j', 1)
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
          if !tablemode#table#IsATableRow(line('.') - 1) || (tablemode#table#IsATableHeader(line('.') - 1) && !tablemode#table#IsATableRow(line('.') - 2 * 1))
            return
          endif
          call tablemode#table#TableMotion('k', 1)
          normal! $
        endif

        " If line ends with g:table_mode_separator
        if getline('.')[col('.')-1] ==# g:table_mode_separator
          execute 'normal! F' . g:table_mode_separator . '2l'
        else
          execute 'normal! 2F' . g:table_mode_separator . '2l'
        endif
      elseif a:direction ==# 'j'
        if tablemode#table#IsATableRow(line('.') + 1)
          execute 'normal! ' . 1 . 'j'
        elseif tablemode#table#IsATableHeader(line('.') + 1) && tablemode#table#IsATableRow(line('.') + 2 * 1)
          execute 'normal! ' . (1 + 1) . 'j'
        endif
      elseif a:direction ==# 'k'
        if tablemode#table#IsATableRow(line('.') - 1)
          execute 'normal! ' . 1 . 'k'
        elseif tablemode#table#IsATableHeader(line('.') - 1) && tablemode#table#IsATableRow(line('.') - 2 * 1)
          execute 'normal! ' . (1 + 1) . 'k'
        endif
      endif
    endfor
  endif
endfunction

function! tablemode#table#CellTextObject() "{{{2
  if tablemode#table#IsATableRow('.')
    call s:MoveToStartOfCell()

    if v:operator ==# 'y'
      normal! v
      call search('[^' . g:table_mode_separator . ']\ze\s*' . g:table_mode_separator)
    else
      execute 'normal! vf' . g:table_mode_separator
    endif
  endif
endfunction

function! tablemode#table#Sum(range, ...) abort "{{{2
  let args = copy(a:000)
  call insert(args, a:range)
  return s:Sum(call('s:GetCellRange', args))
endfunction

function! tablemode#table#Average(range, ...) abort "{{{2
  let args = copy(a:000)
  call insert(args, a:range)
  return s:Average(call('s:GetCellRange', args))
endfunction

function! tablemode#table#AddFormula() "{{{2
  let fr = input('f=')
  let row = tablemode#table#RowNr('.')
  let colm = tablemode#table#ColumnNr('.')
  let indent = indent('.')
  let indent_str = repeat(' ', indent)

  if fr !=# ''
    let fr = '$' . row . ',' . colm . '=' . fr
    let fline = tablemode#table#GetLastRow('.') + 1
    if tablemode#table#IsATableHeader(fline) | let fline += 1 | endif
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
    call tablemode#table#EvaluateFormulaLine()
  endif
endfunction

function! tablemode#table#EvaluateExpr(expr, line) abort "{{{2
  let line = tablemode#utils#line(a:line)
  let [target, expr] = map(split(a:expr, '='), 'tablemode#utils#strip(v:val)')
  let cell = substitute(target, '\$', '', '')
  if cell =~# ','
    let [row, colm] = map(split(cell, ','), 'str2nr(v:val)')
  else
    let [row, colm] = [0, str2nr(cell)]
  endif

  if expr =~# 'Sum(.*)'
    let expr = substitute(expr, 'Sum(\([^)]*\))', 'tablemode#table#Sum("\1",'.line.','.colm.')', 'g')
  endif

  if expr =~# 'Average(.*)'
    let expr = substitute(expr, 'Average(\([^)]*\))', 'tablemode#table#Average("\1",'.line.','.colm.')', 'g')
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
    while tablemode#table#IsATableRow(line)
      let texpr = expr
      if expr =~# '\$'
        let texpr = substitute(texpr, '\$\(\d\+\)',
              \ '\=str2float(s:GetCells(line, row, submatch(1)))', 'g')
      endif

      call s:SetCell(eval(texpr), line, row, colm)
      let row += 1
      let line += 1
    endwhile
  endif
endfunction

function! tablemode#table#EvaluateFormulaLine() abort "{{{2
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
  if tablemode#table#IsATableRow('.') " We're inside the table
    let line = s:GetLastRow('.')
    let fline = line + 1
    if tablemode#table#IsATableHeader(fline) | let fline += 1 | endif
    if getline(fline) =~# 'tmf: '
      let exprs = split(matchstr(getline(fline), matchexpr), ';')
    endif
  elseif getline('.') =~# 'tmf: ' " We're on the formula line
    let line = line('.') - 1
    if tablemode#table#IsATableHeader(line) | let line -= 1 | endif
    if tablemode#table#IsATableRow(line)
      let exprs = split(matchstr(getline('.'), matchexpr), ';')
    endif
  endif

  for expr in exprs
    call tablemode#table#EvaluateExpr(expr, line)
  endfor
endfunction

" vim: sw=2 sts=2 fdl=0 fdm=marker
