" ==============================  Header ======================================
" File:          autoload/tablemode/spreadsheet/formula.vim
" Description:   Table mode for vim for creating neat tables.
" Author:        Dhruva Sagar <http://dhruvasagar.com/>
" License:       MIT (http://www.opensource.org/licenses/MIT)
" Website:       https://github.com/dhruvasagar/vim-table-mode
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

" Public Functions {{{1
function! tablemode#spreadsheet#formula#sid() "{{{2
  return maparg('<sid>', 'n')
endfunction
nnoremap <sid> <sid>

function! tablemode#spreadsheet#formula#scope() "{{{2
  return s:
endfunction

function! tablemode#spreadsheet#formula#Add(...) "{{{2
  let fr = a:0 ? a:1 : input('f=')
  let row = tablemode#spreadsheet#RowNr('.')
  let colm = tablemode#spreadsheet#ColumnNr('.')
  let indent = indent('.')
  let indent_str = repeat(' ', indent)

  if fr !=# ''
    let fr = '$' . row . ',' . colm . '=' . fr
    let fline = tablemode#spreadsheet#GetLastRow('.') + 1
    if tablemode#table#IsBorder(fline) | let fline += 1 | endif
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
    call tablemode#spreadsheet#formula#EvaluateFormulaLine()
  endif
endfunction

function! tablemode#spreadsheet#formula#EvaluateExpr(expr, line) abort "{{{2
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
          \ '\=str2float(tablemode#spreadsheet#cell#GetCells(line, submatch(1), submatch(2)))', 'g')
  endif

  if cell =~# ','
    if expr =~# '\$'
      let expr = substitute(expr, '\$\(\d\+\)',
          \ '\=str2float(tablemode#spreadsheet#cell#GetCells(line, row, submatch(1)))', 'g')
    endif
    call tablemode#spreadsheet#cell#SetCell(eval(expr), line, row, colm)
  else
    let [row, line] = [tablemode#spreadsheet#RowCount(line), tablemode#spreadsheet#GetLastRow(line)]
    while tablemode#table#IsRow(line)
      let texpr = expr
      if expr =~# '\$'
        let texpr = substitute(texpr, '\$\(\d\+\)',
              \ '\=str2float(tablemode#spreadsheet#cell#GetCells(line, row, submatch(1)))', 'g')
      endif

      call tablemode#spreadsheet#cell#SetCell(eval(texpr), line, row, colm)
      let row -= 1
      let line -= 1
    endwhile
  endif
endfunction

function! tablemode#spreadsheet#formula#EvaluateFormulaLine() abort "{{{2
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
  if tablemode#table#IsRow('.') " We're inside the table
    let line = tablemode#spreadsheet#GetLastRow('.')
    let fline = line + 1
    if tablemode#table#IsBorder(fline) | let fline += 1 | endif
    if getline(fline) =~# 'tmf: '
      let exprs = split(matchstr(getline(fline), matchexpr), ';')
    endif
  elseif getline('.') =~# 'tmf: ' " We're on the formula line
    let line = line('.') - 1
    if tablemode#table#IsBorder(line) | let line -= 1 | endif
    if tablemode#table#IsRow(line)
      let exprs = split(matchstr(getline('.'), matchexpr), ';')
    endif
  endif

  for expr in exprs
    call tablemode#spreadsheet#formula#EvaluateExpr(expr, line)
  endfor
endfunction
