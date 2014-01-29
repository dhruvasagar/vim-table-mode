" vim: fdm=indent
let g:table_mode_corner = '+'
let g:table_mode_separator = '|'
let g:table_mode_fillchar = '-'
let g:table_mode_map_prefix = '<Leader>t'
let g:table_mode_toggle_map = 'm'
let g:table_mode_always_active = 0
let g:table_mode_delimiter = ','
let g:table_mode_tableize_map = 't'
let g:table_mode_tableize_op_map = '<Leader>T'
let g:table_mode_realign_map = 'r'
let g:table_mode_cell_text_object = 'tc'
let g:table_mode_delete_row_map = 'dd'
let g:table_mode_delete_column_map = 'dc'
let g:table_mode_add_formula_map = 'fa'
let g:table_mode_eval_expr_map = 'fe'
let g:table_mode_corner_corner = '|'

call vspec#hint({'scope': 'tablemode#scope()', 'sid': 'tablemode#sid()'})

describe 'tablemode'
  describe 'Activation'
    describe 'tablemode#TableModeEnable()'
      before
        call tablemode#TableModeEnable()
      end

      it 'should enable table mode'
        Expect b:table_mode_active to_be_true
      end
    end

    describe 'tablemode#TableModeDisable()'
      before
        call tablemode#TableModeDisable()
      end

      it 'should disable table mode'
        Expect b:table_mode_active to_be_false
      end
    end

    describe 'tablemode#TableModeToggle()'
      it 'should toggle table mode'
        call tablemode#TableModeToggle()
        Expect b:table_mode_active to_be_true
        call tablemode#TableModeToggle()
        Expect b:table_mode_active to_be_false
      end
    end
  end

  describe 'API'
    before
      new
      normal! ggdG
      call tablemode#TableModeEnable()
      normal i|test11|test12||test21|test22|
    end

    it 'should return true when inside a table'
      Expect tablemode#IsATableRow(2) to_be_true
    end

    it 'should return false when outside a table'
      Expect tablemode#IsATableRow(4) to_be_false
    end

    it 'should return the row count'
      Expect tablemode#RowCount(2) == 2
      Expect tablemode#RowCount(3) == 2
    end

    it 'should return the row number'
      Expect tablemode#RowNr(2) == 1
      Expect tablemode#RowNr(3) == 2
    end

    it 'should return the column count'
      Expect tablemode#ColumnCount(2) == 2
      Expect tablemode#ColumnCount(3) == 2
    end

    it 'should return the line number of the first row'
      Expect tablemode#GetFirstRow(2) == 2
      Expect tablemode#GetFirstRow(3) == 2
    end

    it 'should return the line nuber of the last row'
      Expect tablemode#GetLastRow(2) == 3
      Expect tablemode#GetLastRow(3) == 3
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
      Expect tablemode#IsATableRow(2) to_be_true
      Expect tablemode#RowCount(2) == 2
      Expect tablemode#ColumnCount(2) == 3
    end

    it 'should tableize with given delimiter'
      :2,3call tablemode#TableizeRange('/;')
      Expect tablemode#IsATableRow(2) to_be_true
      Expect tablemode#RowCount(2) == 2
      Expect tablemode#ColumnCount(2) == 2
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
        Expect tablemode#ColumnNr('.') == 2
        call tablemode#TableMotion('h')
        Expect tablemode#ColumnNr('.') == 1
      end

      it 'should move to the previous row last column if it exists when on first column'
        call cursor(2, 3)
        Expect tablemode#RowNr('.') == 2
        Expect tablemode#ColumnNr('.') == 1
        call tablemode#TableMotion('h')
        Expect tablemode#RowNr('.') == 1
        Expect tablemode#ColumnNr('.') == 2
      end

      it 'should move right when not on last column'
        Expect tablemode#ColumnNr('.') == 1
        call tablemode#TableMotion('l')
        Expect tablemode#ColumnNr('.') == 2
      end

      it 'should move to the next row first column if it exists when on last column'
        call cursor(1, 12)
        Expect tablemode#RowNr('.') == 1
        Expect tablemode#ColumnNr('.') == 2
        call tablemode#TableMotion('l')
        Expect tablemode#RowNr('.') == 2
        Expect tablemode#ColumnNr('.') == 1
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
        Expect tablemode#RowNr('.') == 2
        call tablemode#TableMotion('k')
        Expect tablemode#RowNr('.') == 1
      end

      it 'should remain on first row when trying to move up'
        Expect tablemode#RowNr('.') == 1
        call tablemode#TableMotion('k')
        Expect tablemode#RowNr('.') == 1
      end

      it 'should move a row down unless on last row'
        Expect tablemode#RowNr('.') == 1
        call tablemode#TableMotion('j')
        Expect tablemode#RowNr('.') == 2
      end

      it 'should remain on last row when trying to move down'
        Expect tablemode#RowNr('.') == 1
        call tablemode#TableMotion('k')
        Expect tablemode#RowNr('.') == 1
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
      Expect tablemode#RowCount('.') == 2
      call tablemode#DeleteRow()
      Expect tablemode#RowCount('.') == 1
    end

    it 'should successfully delete column'
      Expect tablemode#ColumnCount('.') == 2
      call tablemode#DeleteColumn()
      Expect tablemode#ColumnCount('.') == 1
    end
  end
end
