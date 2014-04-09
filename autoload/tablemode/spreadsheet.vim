" ==============================  Header ======================================
" File:          autoload/tablemode/spreadsheet.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       https://github.com/dhruvasagar/vim-table-mode
" Version:       4.1.0
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

" function! s:ParseRange(range, ...) {{{2
" range: A string representing range of cells.
"        - Can be row1:row2 for values in the current columns in those rows.
"        - Can be row1,col1:row2,col2 for range between row1,col1 till
"          row2,col2.
function! s:ParseRange(range, ...)
  if a:0 < 1
    let default_col = tablemode#spreadsheet#ColumnNr('.')
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

" Public Functions {{{1
function! tablemode#spreadsheet#sid() "{{{2
  return maparg('<sid>', 'n')
endfunction
nnoremap <sid> <sid>

function! tablemode#spreadsheet#scope() "{{{2
  return s:
endfunction

function! tablemode#spreadsheet#GetFirstRow(line) "{{{2
  if tablemode#table#IsATableRow(a:line)
    let line = tablemode#utils#line(a:line)

    while tablemode#table#IsATableRow(line - 1) || tablemode#table#IsATableHeader(line - 1)
      let line -= 1
    endwhile
    if tablemode#table#IsATableHeader(line) | let line += 1 | endif

    return line
  endif
endfunction

function! tablemode#spreadsheet#MoveToFirstRow() "{{{2
  if tablemode#table#IsATableRow('.')
    call cursor(tablemode#spreadsheet#GetFirstRow('.'), col('.'))
  endif
endfunction

function! tablemode#spreadsheet#GetLastRow(line) "{{{2
  if tablemode#table#IsATableRow(a:line)
    let line = tablemode#utils#line(a:line)

    while tablemode#table#IsATableRow(line + 1) || tablemode#table#IsATableHeader(line + 1)
      let line += 1
    endwhile
    if tablemode#table#IsATableHeader(line) | let line -= 1 | endif

    return line
  endif
endfunction

function! tablemode#spreadsheet#MoveToLastRow() "{{{2
  if tablemode#table#IsATableRow('.')
    call cursor(tablemode#spreadsheet#GetLastRow('.'), col('.'))
  endif
endfunction

function! tablemode#spreadsheet#LineNr(row) "{{{2
  if tablemode#table#IsATableRow('.')
    let line = tablemode#spreadsheet#GetFirstRow('.')
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

function! tablemode#spreadsheet#RowNr(line) "{{{2
  let line = tablemode#utils#line(a:line)

  let rowNr = 0
  while tablemode#table#IsATableRow(line) || tablemode#table#IsATableHeader(line)
    if tablemode#table#IsATableRow(line) | let rowNr += 1 | endif
    let line -= 1
  endwhile

  return rowNr
endfunction

function! tablemode#spreadsheet#RowCount(line) "{{{2
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

function! tablemode#spreadsheet#ColumnNr(pos) "{{{2
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

function! tablemode#spreadsheet#ColumnCount(line) "{{{2
  let line = tablemode#utils#line(a:line)

  return tablemode#utils#strlen(substitute(getline(line), '[^' . g:table_mode_separator . ']', '', 'g'))-1
endfunction

function! tablemode#spreadsheet#IsFirstCell() "{{{2
  return tablemode#spreadsheet#ColumnNr('.') ==# 1
endfunction

function! tablemode#spreadsheet#IsLastCell() "{{{2
  return tablemode#spreadsheet#ColumnNr('.') ==# tablemode#spreadsheet#ColumnCount('.')
endfunction

function! tablemode#spreadsheet#MoveToStartOfCell() "{{{2
  if getline('.')[col('.')-1] ==# g:table_mode_separator && !tablemode#spreadsheet#IsLastCell()
    normal! 2l
  else
    execute 'normal! F' . g:table_mode_separator . '2l'
  endif
endfunction

function! tablemode#spreadsheet#GetLastRow(line) "{{{2
  if tablemode#table#IsATableRow(a:line)
    let line = tablemode#utils#line(a:line)

    while tablemode#table#IsATableRow(line + 1) || tablemode#table#IsATableHeader(line + 1)
      let line += 1
    endwhile
    if tablemode#table#IsATableHeader(line) | let line -= 1 | endif

    return line
  endif
endfunction

function! tablemode#spreadsheet#GetFirstRow(line) "{{{2
  if tablemode#table#IsATableRow(a:line)
    let line = tablemode#utils#line(a:line)

    while tablemode#table#IsATableRow(line - 1) || tablemode#table#IsATableHeader(line - 1)
      let line -= 1
    endwhile
    if tablemode#table#IsATableHeader(line) | let line += 1 | endif

    return line
  endif
endfunction

" function! tablemode#spreadsheet#GetCells() - Function to get values of cells in a table {{{2
" tablemode#spreadsheet#GetCells(row) - Get values of all cells in a row as a List.
" tablemode#spreadsheet#GetCells(0, col) - Get values of all cells in a column as a List.
" tablemode#spreadsheet#GetCells(row, col) - Get the value of table cell by given row, col.
function! tablemode#spreadsheet#GetCells(line, ...) abort
  let line = tablemode#utils#line(a:line)

  if tablemode#table#IsATableRow(line)
    if a:0 < 1
      let [row, colm] = [line, 0]
    elseif a:0 < 2
      let [row, colm] = [a:1, 0]
    elseif a:0 < 3
      let [row, colm] = a:000
    endif

    let first_row = tablemode#spreadsheet#GetFirstRow(line)
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

function! tablemode#spreadsheet#GetCell(...) "{{{2
  if a:0 == 0
    let [row, colm] = [tablemode#spreadsheet#RowNr('.'), tablemode#spreadsheet#ColumnNr('.')]
  elseif a:0 == 2
    let [row, colm] = [a:1, a:2]
  endif

  return tablemode#spreadsheet#GetCells('.', row, colm)
endfunction

function! tablemode#spreadsheet#GetRow(row, ...) abort "{{{2
  let line = a:0 < 1 ? '.' : a:1
  return tablemode#spreadsheet#GetCells(line, a:row)
endfunction

function! tablemode#spreadsheet#GetRowColumn(col, ...) abort "{{{2
  let line = a:0 < 1 ? '.' : a:1
  let row = tablemode#RowNr('.')
  return tablemode#spreadsheet#GetCells(line, row, a:col)
endfunction

function! tablemode#spreadsheet#GetColumn(col, ...) abort "{{{2
  let line = a:0 < 1 ? '.' : a:1
  return tablemode#spreadsheet#GetCells(line, 0, a:col)
endfunction

function! tablemode#spreadsheet#GetColumnRow(row, ...) abort "{{{2
  let line = a:0 < 1 ? '.' : a:1
  let col = tablemode#spreadsheet#ColumnNr('.')
  return tablemode#spreadsheet#GetCells(line, a:row, col)
endfunction

function! tablemode#spreadsheet#SetCell(val, ...) "{{{2
  if a:0 == 0
    let [line, row, colm] = ['.', tablemode#spreadsheet#RowNr('.'), tablemode#spreadsheet#ColumnNr('.')]
  elseif a:0 == 2
    let [line, row, colm] = ['.', a:1, a:2]
  elseif a:0 == 3
    let [line, row, colm] = a:000
  endif

  if tablemode#table#IsATableRow(line)
    let line = tablemode#utils#line(line) + (row - tablemode#spreadsheet#RowNr(line)) * 1
    let line_val = getline(line)
    let cstartexpr = tablemode#table#StartCommentExpr()
    let values = split(getline(line)[stridx(line_val, g:table_mode_separator):strridx(line_val, g:table_mode_separator)], g:table_mode_separator)
    if len(values) < colm | return | endif
    let values[colm-1] = a:val
    let line_value = g:table_mode_separator . join(values, g:table_mode_separator) . g:table_mode_separator
    if tablemode#utils#strlen(cstartexpr) > 0 && line_val =~# cstartexpr
      let sce = matchstr(line_val, tablemode#table#StartCommentExpr())
      let ece = matchstr(line_val, tablemode#table#EndCommentExpr())
      let line_value = sce . line_value . ece
    endif
    call setline(line, line_value)
    call tablemode#table#TableRealign(line)
  endif
endfunction

function! tablemode#spreadsheet#DeleteColumn() "{{{2
  if tablemode#table#IsATableRow('.')
    for i in range(v:count1)
      call tablemode#spreadsheet#MoveToStartOfCell()
      call tablemode#spreadsheet#MoveToFirstRow()
      silent! execute "normal! h\<C-V>f" . g:table_mode_separator
      call tablemode#spreadsheet#MoveToLastRow()
      normal! d
    endfor

    call tablemode#table#TableRealign('.')
  endif
endfunction

function! tablemode#spreadsheet#DeleteRow() "{{{2
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

function! tablemode#spreadsheet#GetCellRange(range, ...) abort "{{{2
  if a:0 < 1
    let [line, colm] = ['.', tablemode#spreadsheet#ColumnNr('.')]
  elseif a:0 < 2
    let [line, colm] = [a:1, tablemode#spreadsheet#ColumnNr('.')]
  elseif a:0 < 3
    let [line, colm] = [a:1, a:2]
  else
    call tablemode#utils#throw('Invalid Range')
  endif

  let values = []

  if tablemode#table#IsATableRow(line)
    let [row1, col1, row2, col2] = s:ParseRange(a:range, colm)

    if row1 == row2
      if col1 == col2
        call add(values, tablemode#spreadsheet#GetCells(line, row1, col1))
      else
        let values = tablemode#spreadsheet#GetRow(row1, line)[(col1-1):(col2-1)]
      endif
    else
      if col1 == col2
        let values = tablemode#spreadsheet#GetColumn(col1, line)[(row1-1):(row2-1)]
      else
        let tcol = col1
        while tcol <= col2
          call add(values, tablemode#spreadsheet#GetColumn(tcol, line)[(row1-1):(row2-1)])
          let tcol += 1
        endwhile
      endif
    endif
  endif

  return values
endfunction

function! tablemode#spreadsheet#Sum(range, ...) abort "{{{2
  let args = copy(a:000)
  call insert(args, a:range)
  return s:Sum(call('tablemode#spreadsheet#GetCellRange', args))
endfunction

function! tablemode#spreadsheet#Average(range, ...) abort "{{{2
  let args = copy(a:000)
  call insert(args, a:range)
  return s:Average(call('tablemode#spreadsheet#GetCellRange', args))
endfunction

function! tablemode#spreadsheet#AddFormula(...) "{{{2
  let fr = a:0 ? a:1 : input('f=')
  let row = tablemode#spreadsheet#RowNr('.')
  let colm = tablemode#spreadsheet#ColumnNr('.')
  let indent = indent('.')
  let indent_str = repeat(' ', indent)

  if fr !=# ''
    let fr = '$' . row . ',' . colm . '=' . fr
    let fline = tablemode#spreadsheet#GetLastRow('.') + 1
    if tablemode#table#IsATableHeader(fline) | let fline += 1 | endif
    let cursor_pos = [line('.'), col('.')]
    if getline(fline) =~# 'tmf: '
      " Comment line correctly
      let line_val = getline(fline)
      let line_expr = line_val[match(line_val, tablemode#table#StartCommentExpr()):match(line_val, tablemode#table#EndCommentExpr())]
      let sce = matchstr(line_val, tablemode#table#StartCommentExpr() . '\zs')
      let ece = matchstr(line_val, tablemode#table#EndCommentExpr())
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
    call tablemode#spreadsheet#EvaluateFormulaLine()
  endif
endfunction

function! tablemode#spreadsheet#EvaluateExpr(expr, line) abort "{{{2
  let line = tablemode#utils#line(a:line)
  let [target, expr] = map(split(a:expr, '='), 'tablemode#utils#strip(v:val)')
  let cell = substitute(target, '\$', '', '')
  if cell =~# ','
    let [row, colm] = map(split(cell, ','), 'str2nr(v:val)')
  else
    let [row, colm] = [0, str2nr(cell)]
  endif

  if expr =~# 'Sum(.*)'
    let expr = substitute(expr, 'Sum(\([^)]*\))', 'tablemode#spreadsheet#Sum("\1",'.line.','.colm.')', 'g')
  endif

  if expr =~# 'Average(.*)'
    let expr = substitute(expr, 'Average(\([^)]*\))', 'tablemode#spreadsheet#Average("\1",'.line.','.colm.')', 'g')
  endif

  if expr =~# '\$\d\+,\d\+'
    let expr = substitute(expr, '\$\(\d\+\),\(\d\+\)',
          \ '\=str2float(tablemode#spreadsheet#GetCells(line, submatch(1), submatch(2)))', 'g')
  endif

  if cell =~# ','
    if expr =~# '\$'
      let expr = substitute(expr, '\$\(\d\+\)',
          \ '\=str2float(tablemode#spreadsheet#GetCells(line, row, submatch(1)))', 'g')
    endif
    call tablemode#spreadsheet#SetCell(eval(expr), line, row, colm)
  else
    let [row, line] = [1, tablemode#spreadsheet#GetFirstRow(line)]
    while tablemode#table#IsATableRow(line)
      let texpr = expr
      if expr =~# '\$'
        let texpr = substitute(texpr, '\$\(\d\+\)',
              \ '\=str2float(tablemode#spreadsheet#GetCells(line, row, submatch(1)))', 'g')
      endif

      call tablemode#spreadsheet#SetCell(eval(texpr), line, row, colm)
      let row += 1
      let line += 1
    endwhile
  endif
endfunction

function! tablemode#spreadsheet#EvaluateFormulaLine() abort "{{{2
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
    let line = tablemode#spreadsheet#GetLastRow('.')
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
    call tablemode#spreadsheet#EvaluateExpr(expr, line)
  endfor
endfunction

function! tablemode#spreadsheet#CellTextObject(inner) "{{{2
  if tablemode#table#IsATableRow('.')
    call tablemode#spreadsheet#MoveToStartOfCell()
    if a:inner
      normal! v
      call search('[^' . g:table_mode_separator . ']\ze\s*' . g:table_mode_separator)
    else
      execute 'normal! vf' . g:table_mode_separator . 'l'
    endif
  endif
endfunction
