" vim: fdm=indent
source t/config/options.vim

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
end
