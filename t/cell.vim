" vim: fdm=indent
source t/config/options.vim

call vspec#hint({'scope': 'tablemode#spreadsheet#cell#scope()', 'sid': 'tablemode#spreadsheet#cell#sid()'})

describe 'cell API'
  before
    new
    read t/fixtures/sample.txt
  end

  it 'should return the cells'
    Expect tablemode#spreadsheet#cell#GetCells(2, 1, 1) ==# 'test11'
    " Get Rows
    Expect tablemode#spreadsheet#cell#GetCells(2, 1) == ['test11', 'test12']
    Expect tablemode#spreadsheet#cell#GetCells(2, 2) == ['test21', 'test22']
    " Get Columns
    Expect tablemode#spreadsheet#cell#GetCells(2, 0, 1) == ['test11', 'test21']
    Expect tablemode#spreadsheet#cell#GetCells(2, 0, 2) == ['test12', 'test22']
  end

  it 'should return the cells in a range'
    " Entire table as range
    Expect tablemode#spreadsheet#cell#GetCellRange('1,1:2,2', 2, 1) == [['test11', 'test21'], ['test12', 'test22']]

    " Get Rows given different seed lines and columns
    Expect tablemode#spreadsheet#cell#GetCellRange('1,1:1,2', 2, 1) == ['test11', 'test12']
    Expect tablemode#spreadsheet#cell#GetCellRange('1,1:1,2', 2, 2) == ['test11', 'test12']
    Expect tablemode#spreadsheet#cell#GetCellRange('1,1:1,2', 3, 1) == ['test11', 'test12']
    Expect tablemode#spreadsheet#cell#GetCellRange('1,1:1,2', 3, 2) == ['test11', 'test12']
    Expect tablemode#spreadsheet#cell#GetCellRange('2,1:2,2', 2, 1) == ['test21', 'test22']
    Expect tablemode#spreadsheet#cell#GetCellRange('2,1:2,2', 2, 2) == ['test21', 'test22']
    Expect tablemode#spreadsheet#cell#GetCellRange('2,1:2,2', 3, 1) == ['test21', 'test22']
    Expect tablemode#spreadsheet#cell#GetCellRange('2,1:2,2', 3, 2) == ['test21', 'test22']

    " Get Columns given different seed lines and column
    Expect tablemode#spreadsheet#cell#GetCellRange('1:2', 2, 1) == ['test11', 'test21']
    Expect tablemode#spreadsheet#cell#GetCellRange('1:2', 2, 2) == ['test12', 'test22']
    Expect tablemode#spreadsheet#cell#GetCellRange('1:2', 3, 1) == ['test11', 'test21']
    Expect tablemode#spreadsheet#cell#GetCellRange('1:2', 3, 2) == ['test12', 'test22']

    " Get Column given negative values in range for representing rows from
    " the end, -1 being the second last row.
    Expect tablemode#spreadsheet#cell#GetCellRange('1:-1', 2, 1) == ['test11']
    Expect tablemode#spreadsheet#cell#GetCellRange('1:-1', 3, 1) == ['test11']
    Expect tablemode#spreadsheet#cell#GetCellRange('1:-1', 2, 2) == ['test12']
    Expect tablemode#spreadsheet#cell#GetCellRange('1:-1', 3, 2) == ['test12']
  end
end
