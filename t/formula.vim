" vim: fdm=indent
source t/config/options.vim

call vspec#hint({'scope': 'tablemode#spreadsheet#formula#scope()', 'sid': 'tablemode#spreadsheet#formula#sid()'})

describe 'Formulas'
  describe 'Add Formula'
    before
      new
      read t/fixtures/formula/sample.txt
    end

    it 'should add a formula successfully'
      call cursor(6, 15)
      call tablemode#spreadsheet#formula#Add("Sum(1:4)")
      Expect tablemode#spreadsheet#cell#GetCell() == '125.0'
      call cursor(8, 15)
      Expect getline('.') == '/* tmf: $5,2=Sum(1:4) */'

      call cursor(7, 15)
      call tablemode#spreadsheet#formula#Add("Sum(1:-1)")
      Expect tablemode#spreadsheet#cell#GetCell() == '250.0'
      call cursor(8, 15)
      Expect getline('.') == '/* tmf: $5,2=Sum(1:4) ; $6,2=Sum(1:-1) */'
    end
  end

  describe 'Evaluate Formula'
    before
      new
      read t/fixtures/formula/formula.txt
    end

    it 'should evaluate the formula successfull'
      call cursor(6, 15)
      call tablemode#spreadsheet#formula#EvaluateFormulaLine()
      Expect &modified == 1
      Expect tablemode#spreadsheet#cell#GetCell() == '125.0'
    end
  end
end
