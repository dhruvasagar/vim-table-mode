" vim: fdm=indent
source t/config.vim

call vspec#hint({'scope': 'tablemode#table#scope()', 'sid': 'tablemode#table#sid()'})

describe 'table'
  describe 'API'
    before
      new
      read t/fixtures/sample.txt
    end

    it 'should return true when inside a table'
      Expect tablemode#table#IsATableRow(2) to_be_true
    end

    it 'should return false when outside a table'
      Expect tablemode#table#IsATableRow(4) to_be_false
    end
  end

  describe 'Tableize'
    before
      new
      read t/fixtures/tableize.txt
    end

    it 'should tableize with default delimiter'
      :2,3call tablemode#TableizeRange('')
      Expect tablemode#table#IsATableRow(2) to_be_true
      Expect tablemode#spreadsheet#RowCount(2) == 2
      Expect tablemode#spreadsheet#ColumnCount(2) == 3
    end

    it 'should tableize with given delimiter'
      :2,3call tablemode#TableizeRange('/;')
      Expect tablemode#table#IsATableRow(2) to_be_true
      Expect tablemode#spreadsheet#RowCount(2) == 2
      Expect tablemode#spreadsheet#ColumnCount(2) == 2
    end
  end

  describe 'Motions'
    describe 'left or right'
      before
        new
        normal! ggdG
        call tablemode#TableModeEnable()
        normal i|test11|test12||test21|test22|
        call cursor(1, 3)
      end

      it 'should move left when not on first column'
        call cursor(1, 12)
        Expect tablemode#spreadsheet#ColumnNr('.') == 2
        call tablemode#table#TableMotion('h')
        Expect tablemode#spreadsheet#ColumnNr('.') == 1
      end

      it 'should move to the previous row last column if it exists when on first column'
        call cursor(2, 3)
        Expect tablemode#spreadsheet#RowNr('.') == 2
        Expect tablemode#spreadsheet#ColumnNr('.') == 1
        call tablemode#table#TableMotion('h')
        Expect tablemode#spreadsheet#RowNr('.') == 1
        Expect tablemode#spreadsheet#ColumnNr('.') == 2
      end

      it 'should move right when not on last column'
        Expect tablemode#spreadsheet#ColumnNr('.') == 1
        call tablemode#table#TableMotion('l')
        Expect tablemode#spreadsheet#ColumnNr('.') == 2
      end

      it 'should move to the next row first column if it exists when on last column'
        call cursor(1, 12)
        Expect tablemode#spreadsheet#RowNr('.') == 1
        Expect tablemode#spreadsheet#ColumnNr('.') == 2
        call tablemode#table#TableMotion('l')
        Expect tablemode#spreadsheet#RowNr('.') == 2
        Expect tablemode#spreadsheet#ColumnNr('.') == 1
      end
    end

    describe 'up or down'
      before
        new
        normal! ggdG
        call tablemode#TableModeEnable()
        normal i|test11|test12||test21|test22|
        call cursor(1, 3)
      end

      it 'should move a row up unless on first row'
        call cursor(2, 3)
        Expect tablemode#spreadsheet#RowNr('.') == 2
        call tablemode#table#TableMotion('k')
        Expect tablemode#spreadsheet#RowNr('.') == 1
      end

      it 'should remain on first row when trying to move up'
        Expect tablemode#spreadsheet#RowNr('.') == 1
        call tablemode#table#TableMotion('k')
        Expect tablemode#spreadsheet#RowNr('.') == 1
      end

      it 'should move a row down unless on last row'
        Expect tablemode#spreadsheet#RowNr('.') == 1
        call tablemode#table#TableMotion('j')
        Expect tablemode#spreadsheet#RowNr('.') == 2
      end

      it 'should remain on last row when trying to move down'
        Expect tablemode#spreadsheet#RowNr('.') == 1
        call tablemode#table#TableMotion('k')
        Expect tablemode#spreadsheet#RowNr('.') == 1
      end
    end
  end
end
