" vim: fdm=indent
source t/config.vim

call vspec#hint({'scope': 'tablemode#table#scope()', 'sid': 'tablemode#table#sid()'})

describe 'table'
  describe 'API'
    before
      new
      normal! ggdG
      call tablemode#TableModeEnable()
      normal i|test11|test12||test21|test22|
    end

    it 'should return true when inside a table'
      Expect tablemode#table#IsATableRow(2) to_be_true
    end

    it 'should return false when outside a table'
      Expect tablemode#table#IsATableRow(4) to_be_false
    end

    it 'should return the row count'
      Expect tablemode#table#RowCount(2) == 2
      Expect tablemode#table#RowCount(3) == 2
    end

    it 'should return the row number'
      Expect tablemode#table#RowNr(2) == 1
      Expect tablemode#table#RowNr(3) == 2
    end

    it 'should return the column count'
      Expect tablemode#table#ColumnCount(2) == 2
      Expect tablemode#table#ColumnCount(3) == 2
    end

    it 'should return the line number of the first row'
      Expect tablemode#table#GetFirstRow(2) == 2
      Expect tablemode#table#GetFirstRow(3) == 2
    end

    it 'should return the line nuber of the last row'
      Expect tablemode#table#GetLastRow(2) == 3
      Expect tablemode#table#GetLastRow(3) == 3
    end

    it 'should return the cells'
      Expect Call('s:GetCells', 2, 1, 1) ==# 'test11'
      " Get Rows
      Expect Call('s:GetCells', 2, 1) == ['test11', 'test12']
      Expect Call('s:GetCells', 2, 2) == ['test21', 'test22']
      " Get Columns
      Expect Call('s:GetCells', 2, 0, 1) == ['test11', 'test21']
      Expect Call('s:GetCells', 2, 0, 2) == ['test12', 'test22']
    end

    it 'should return the cells in a range'
      " Entire table as range
      Expect Call('s:GetCellRange', '1,1:2,2', 2, 1) == [['test11', 'test21'], ['test12', 'test22']]

      " Get Rows given different seed lines and columns
      Expect Call('s:GetCellRange', '1,1:1,2', 2, 1) == ['test11', 'test12']
      Expect Call('s:GetCellRange', '1,1:1,2', 2, 2) == ['test11', 'test12']
      Expect Call('s:GetCellRange', '1,1:1,2', 3, 1) == ['test11', 'test12']
      Expect Call('s:GetCellRange', '1,1:1,2', 3, 2) == ['test11', 'test12']
      Expect Call('s:GetCellRange', '2,1:2,2', 2, 1) == ['test21', 'test22']
      Expect Call('s:GetCellRange', '2,1:2,2', 2, 2) == ['test21', 'test22']
      Expect Call('s:GetCellRange', '2,1:2,2', 3, 1) == ['test21', 'test22']
      Expect Call('s:GetCellRange', '2,1:2,2', 3, 2) == ['test21', 'test22']

      " Get Columns given different seed lines and column
      Expect Call('s:GetCellRange', '1:2', 2, 1) == ['test11', 'test21']
      Expect Call('s:GetCellRange', '1:2', 2, 2) == ['test12', 'test22']
      Expect Call('s:GetCellRange', '1:2', 3, 1) == ['test11', 'test21']
      Expect Call('s:GetCellRange', '1:2', 3, 2) == ['test12', 'test22']

      " Get Column given negative values in range for representing rows from
      " the end, -1 being the second last row.
      Expect Call('s:GetCellRange', '1:-1', 2, 1) == ['test11']
      Expect Call('s:GetCellRange', '1:-1', 3, 1) == ['test11']
      Expect Call('s:GetCellRange', '1:-1', 2, 2) == ['test12']
      Expect Call('s:GetCellRange', '1:-1', 3, 2) == ['test12']
    end
  end

  describe 'Tableize'
    before
      new
      normal! ggdG
      normal iasd,asd;asd,asdasd,asd;asd,asd
    end

    it 'should tableize with default delimiter'
      :2,3call tablemode#TableizeRange('')
      Expect tablemode#table#IsATableRow(2) to_be_true
      Expect tablemode#table#RowCount(2) == 2
      Expect tablemode#table#ColumnCount(2) == 3
    end

    it 'should tableize with given delimiter'
      :2,3call tablemode#TableizeRange('/;')
      Expect tablemode#table#IsATableRow(2) to_be_true
      Expect tablemode#table#RowCount(2) == 2
      Expect tablemode#table#ColumnCount(2) == 2
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
        Expect tablemode#table#ColumnNr('.') == 2
        call tablemode#table#TableMotion('h')
        Expect tablemode#table#ColumnNr('.') == 1
      end

      it 'should move to the previous row last column if it exists when on first column'
        call cursor(2, 3)
        Expect tablemode#table#RowNr('.') == 2
        Expect tablemode#table#ColumnNr('.') == 1
        call tablemode#table#TableMotion('h')
        Expect tablemode#table#RowNr('.') == 1
        Expect tablemode#table#ColumnNr('.') == 2
      end

      it 'should move right when not on last column'
        Expect tablemode#table#ColumnNr('.') == 1
        call tablemode#table#TableMotion('l')
        Expect tablemode#table#ColumnNr('.') == 2
      end

      it 'should move to the next row first column if it exists when on last column'
        call cursor(1, 12)
        Expect tablemode#table#RowNr('.') == 1
        Expect tablemode#table#ColumnNr('.') == 2
        call tablemode#table#TableMotion('l')
        Expect tablemode#table#RowNr('.') == 2
        Expect tablemode#table#ColumnNr('.') == 1
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
        Expect tablemode#table#RowNr('.') == 2
        call tablemode#table#TableMotion('k')
        Expect tablemode#table#RowNr('.') == 1
      end

      it 'should remain on first row when trying to move up'
        Expect tablemode#table#RowNr('.') == 1
        call tablemode#table#TableMotion('k')
        Expect tablemode#table#RowNr('.') == 1
      end

      it 'should move a row down unless on last row'
        Expect tablemode#table#RowNr('.') == 1
        call tablemode#table#TableMotion('j')
        Expect tablemode#table#RowNr('.') == 2
      end

      it 'should remain on last row when trying to move down'
        Expect tablemode#table#RowNr('.') == 1
        call tablemode#table#TableMotion('k')
        Expect tablemode#table#RowNr('.') == 1
      end
    end
  end

  describe 'Manipulations'
    before
      new
      normal! ggdG
      normal i|test11|test12||test21|test22|
      call cursor(1, 3)
    end

    it 'should delete a row successfully'
      Expect tablemode#table#RowCount('.') == 2
      call tablemode#table#DeleteRow()
      Expect tablemode#table#RowCount('.') == 1
    end

    it 'should successfully delete column'
      Expect tablemode#table#ColumnCount('.') == 2
      call tablemode#table#DeleteColumn()
      Expect tablemode#table#ColumnCount('.') == 1
    end
  end
end
