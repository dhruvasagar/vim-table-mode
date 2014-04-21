" vim: fdm=indent
source t/config/options.vim

call vspec#hint({'scope': 'tablemode#table#scope()', 'sid': 'tablemode#table#sid()'})

describe 'table'
  describe 'API'
    describe 'IsATableRow'
      before
        new
        read t/fixtures/sample.txt
      end

      it 'should return true when inside a table'
        Expect tablemode#table#IsATableRow(2) to_be_true
        Expect tablemode#table#IsATableRow(3) to_be_true
      end

      it 'should return false when outside a table'
        Expect tablemode#table#IsATableRow(1) to_be_false
        Expect tablemode#table#IsATableRow(4) to_be_false
      end
    end

    describe 'IsATableHeader'
      before
        new
        read t/fixtures/sample_with_header.txt
      end

      it 'should return true when on a table header'
        Expect tablemode#table#IsATableHeader(3) to_be_true
        Expect tablemode#table#IsATableHeader(6) to_be_true
      end

      it 'should return false when not on a table header'
        Expect tablemode#table#IsATableHeader(1) to_be_false
        Expect tablemode#table#IsATableHeader(2) to_be_false
        Expect tablemode#table#IsATableHeader(4) to_be_false
        Expect tablemode#table#IsATableHeader(5) to_be_false
      end
    end
  end
end
