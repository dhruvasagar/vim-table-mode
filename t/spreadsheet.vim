" vim: fdm=indent
source t/config/options.vim

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
