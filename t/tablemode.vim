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
      normal! ggdG
      call tablemode#TableModeEnable()
      normal! i|test11|test12||test21|test22|
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
      normal! ggdG
      normal! iasd,asd;asd,asdasd,asd;asd,asd
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
    it 'should work'
      TODO
    end
  end

  describe 'Manipulations'
    it 'should work'
      TODO
    end
  end
end
