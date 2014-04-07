" vim: fdm=indent
source t/config.vim

call vspec#hint({'scope': 'tablemode#spreadsheet#scope()', 'sid': 'tablemode#spreadsheet#sid()'})

describe 'spreadsheet'
  describe 'API'
    before
      new
      read t/fixtures/sample.txt
    end

    it 'should return the row count'
      Expect tablemode#spreadsheet#RowCount(2) == 2
      Expect tablemode#spreadsheet#RowCount(3) == 2
    end

    it 'should return the row number'
      Expect tablemode#spreadsheet#RowNr(2) == 1
      Expect tablemode#spreadsheet#RowNr(3) == 2
    end

    it 'should return the column count'
      Expect tablemode#spreadsheet#ColumnCount(2) == 2
      Expect tablemode#spreadsheet#ColumnCount(3) == 2
    end

    it 'should return the line number of the first row'
      Expect tablemode#spreadsheet#GetFirstRow(2) == 2
      Expect tablemode#spreadsheet#GetFirstRow(3) == 2
    end

    it 'should return the line nuber of the last row'
      Expect tablemode#spreadsheet#GetLastRow(2) == 3
      Expect tablemode#spreadsheet#GetLastRow(3) == 3
    end

    it 'should return the cells'
      Expect tablemode#spreadsheet#GetCells(2, 1, 1) ==# 'test11'
      " Get Rows
      Expect tablemode#spreadsheet#GetCells(2, 1) == ['test11', 'test12']
      Expect tablemode#spreadsheet#GetCells(2, 2) == ['test21', 'test22']
      " Get Columns
      Expect tablemode#spreadsheet#GetCells(2, 0, 1) == ['test11', 'test21']
      Expect tablemode#spreadsheet#GetCells(2, 0, 2) == ['test12', 'test22']
    end

    it 'should return the cells in a range'
      " Entire table as range
      Expect tablemode#spreadsheet#GetCellRange('1,1:2,2', 2, 1) == [['test11', 'test21'], ['test12', 'test22']]

      " Get Rows given different seed lines and columns
      Expect tablemode#spreadsheet#GetCellRange('1,1:1,2', 2, 1) == ['test11', 'test12']
      Expect tablemode#spreadsheet#GetCellRange('1,1:1,2', 2, 2) == ['test11', 'test12']
      Expect tablemode#spreadsheet#GetCellRange('1,1:1,2', 3, 1) == ['test11', 'test12']
      Expect tablemode#spreadsheet#GetCellRange('1,1:1,2', 3, 2) == ['test11', 'test12']
      Expect tablemode#spreadsheet#GetCellRange('2,1:2,2', 2, 1) == ['test21', 'test22']
      Expect tablemode#spreadsheet#GetCellRange('2,1:2,2', 2, 2) == ['test21', 'test22']
      Expect tablemode#spreadsheet#GetCellRange('2,1:2,2', 3, 1) == ['test21', 'test22']
      Expect tablemode#spreadsheet#GetCellRange('2,1:2,2', 3, 2) == ['test21', 'test22']

      " Get Columns given different seed lines and column
      Expect tablemode#spreadsheet#GetCellRange('1:2', 2, 1) == ['test11', 'test21']
      Expect tablemode#spreadsheet#GetCellRange('1:2', 2, 2) == ['test12', 'test22']
      Expect tablemode#spreadsheet#GetCellRange('1:2', 3, 1) == ['test11', 'test21']
      Expect tablemode#spreadsheet#GetCellRange('1:2', 3, 2) == ['test12', 'test22']

      " Get Column given negative values in range for representing rows from
      " the end, -1 being the second last row.
      Expect tablemode#spreadsheet#GetCellRange('1:-1', 2, 1) == ['test11']
      Expect tablemode#spreadsheet#GetCellRange('1:-1', 3, 1) == ['test11']
      Expect tablemode#spreadsheet#GetCellRange('1:-1', 2, 2) == ['test12']
      Expect tablemode#spreadsheet#GetCellRange('1:-1', 3, 2) == ['test12']
    end
  end

  describe 'Manipulations'
    before
      new
      normal i|test11|test12||test21|test22|
      call cursor(1, 3)
    end

    it 'should delete a row successfully'
      Expect tablemode#spreadsheet#RowCount('.') == 2
      call tablemode#spreadsheet#DeleteRow()
      Expect tablemode#spreadsheet#RowCount('.') == 1
    end

    it 'should successfully delete column'
      Expect tablemode#spreadsheet#ColumnCount('.') == 2
      call tablemode#spreadsheet#DeleteColumn()
      Expect tablemode#spreadsheet#ColumnCount('.') == 1
    end
  end
end
