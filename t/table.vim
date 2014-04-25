" vim: fdm=indent
source t/config/options.vim

call vspec#hint({'scope': 'tablemode#table#scope()', 'sid': 'tablemode#table#sid()'})

describe 'table'
  describe 'API'
    describe 'IsRow'
      before
        new
        read t/fixtures/sample.txt
      end

      it 'should return true when inside a table'
        Expect tablemode#table#IsRow(2) to_be_true
        Expect tablemode#table#IsRow(3) to_be_true
      end

      it 'should return false when outside a table'
        Expect tablemode#table#IsRow(1) to_be_false
        Expect tablemode#table#IsRow(4) to_be_false
      end
    end

    describe 'IsHeader'
      before
        new
        read t/fixtures/sample_with_header.txt
      end

      it 'should return true when on a table header'
        Expect tablemode#table#IsHeader(3) to_be_true
        Expect tablemode#table#IsHeader(6) to_be_true
      end

      it 'should return false when not on a table header'
        Expect tablemode#table#IsHeader(1) to_be_false
        Expect tablemode#table#IsHeader(2) to_be_false
        Expect tablemode#table#IsHeader(4) to_be_false
        Expect tablemode#table#IsHeader(5) to_be_false
      end
    end
  end
end
