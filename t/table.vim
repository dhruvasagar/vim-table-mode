" vim: fdm=indent
source t/config/options.vim

call vspec#hint({'scope': 'tablemode#table#scope()', 'sid': 'tablemode#table#sid()'})

describe 'table'
  describe 'IsRow'
    before
      new
      read t/fixtures/table/sample.txt
    end

    it 'should be true when on a table row'
      Expect tablemode#table#IsRow(2) to_be_true
      Expect tablemode#table#IsRow(3) to_be_true
    end

    it 'should be false when not on a table row'
      Expect tablemode#table#IsRow(1) to_be_false
      Expect tablemode#table#IsRow(4) to_be_false
    end
  end

  describe 'IsBorder'
    before
      new
      read t/fixtures/table/sample_with_header.txt
    end

    it 'should be true on a table border'
      Expect tablemode#table#IsBorder(1) to_be_true
      Expect tablemode#table#IsBorder(3) to_be_true
      Expect tablemode#table#IsBorder(6) to_be_true
    end

    it 'should be false when not on a table border'
      Expect tablemode#table#IsBorder(2) to_be_false
      Expect tablemode#table#IsBorder(4) to_be_false
      Expect tablemode#table#IsBorder(5) to_be_false
    end
  end

  describe 'IsHeader'
    before
      new
      read t/fixtures/table/sample_with_header.txt
    end

    it 'should be true on the table header'
      Expect tablemode#table#IsHeader(2) to_be_true
    end

    it 'should be false anywhere else'
      Expect tablemode#table#IsHeader(1) to_be_false
      Expect tablemode#table#IsHeader(4) to_be_false
      Expect tablemode#table#IsHeader(5) to_be_false
      Expect tablemode#table#IsHeader(6) to_be_false
      Expect tablemode#table#IsHeader(7) to_be_false
    end
  end

  describe 'AddBorder'
    before
      new
      read t/fixtures/table/sample_for_header.txt
    end

    it 'should add border to line'
      call tablemode#table#AddBorder(2)
      Expect tablemode#table#IsHeader(1) to_be_true
      Expect tablemode#table#IsBorder(2) to_be_true
    end
  end

  describe 'Realign'
    describe 'without header alignments'
      before
        new
        read t/fixtures/table/sample_realign_before.txt
      end

      it 'should be aligned properly'
        call tablemode#table#Realign(1)
        Expect getline(1,'$') == readfile('t/fixtures/table/sample_realign_after.txt')
      end
    end

    describe 'with header alignments'
      before
        new
        read t/fixtures/table/sample_header_realign_before.txt
      end

      it 'should be aligned properly'
        call tablemode#table#Realign(1)
        Expect getline(1,'$') == readfile('t/fixtures/table/sample_header_realign_after.txt')
      end
    end
  end
end
