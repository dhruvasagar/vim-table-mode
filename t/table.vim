" vim: fdm=indent
source t/config/options.vim

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
end
