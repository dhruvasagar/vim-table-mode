" vim: fdm=indent
source t/config/options.vim

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

    it 'should return the column number'
      call cursor(2,3)
      Expect tablemode#spreadsheet#ColumnNr('.') == 1
      call cursor(2,12)
      Expect tablemode#spreadsheet#ColumnNr('.') == 2
    end

    it 'should return true when in the first cell'
      call cursor(2,3)
      Expect tablemode#spreadsheet#IsFirstCell() to_be_true
      call cursor(2,12)
      Expect tablemode#spreadsheet#IsFirstCell() to_be_false
    end

    it 'should return true when in the last cell'
      call cursor(2,3)
      Expect tablemode#spreadsheet#IsLastCell() to_be_false
      call cursor(2,12)
      Expect tablemode#spreadsheet#IsLastCell() to_be_true
    end

    it 'should return the line number of the first row'
      Expect tablemode#spreadsheet#GetFirstRow(2) == 2
      Expect tablemode#spreadsheet#GetFirstRow(3) == 2
    end

    it 'should return the line nuber of the last row'
      Expect tablemode#spreadsheet#GetLastRow(2) == 3
      Expect tablemode#spreadsheet#GetLastRow(3) == 3
    end

    describe 'Math'
      before
        new
        read t/fixtures/cell/sample.txt
      end

      it 'should return the sum of cell range'
        call cursor(1,3)
        Expect tablemode#spreadsheet#Sum('1:2') == 4.0
        Expect tablemode#spreadsheet#Sum('1,1:1,2') == 3.0
        Expect tablemode#spreadsheet#Sum('1,1:2,2') == 10.0
        call cursor(2,7)
        Expect tablemode#spreadsheet#Sum('1:2') == 6.0
        Expect tablemode#spreadsheet#Sum('2,1:2,2') == 7.0
      end

      it 'should return the average of cell range'
        call cursor(1,3)
        Expect tablemode#spreadsheet#Average('1:2') == 2.0
        Expect tablemode#spreadsheet#Average('1,1:1,2') == 1.5
        Expect tablemode#spreadsheet#Average('1,1:2,2') == 5.0
        call cursor(2,7)
        Expect tablemode#spreadsheet#Average('1:2') == 3.0
        Expect tablemode#spreadsheet#Average('2,1:2,2') == 3.5
      end
    end
  end

  describe 'Manipulations'
    before
      new
      normal! ggdG
      read t/fixtures/sample.txt
      call cursor(2, 3)
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
