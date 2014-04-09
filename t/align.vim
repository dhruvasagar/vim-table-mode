" vim: fdm=indent
source t/config/options.vim

call vspec#hint({'scope': 'tablemode#align#scope()', 'sid': 'tablemode#align#sid()'})

describe 'Align'
  it 'should align table content correctly'
    Expect tablemode#align#Align(readfile('t/fixtures/align/simple_before.txt')) == readfile('t/fixtures/align/simple_after.txt')
  end

  it 'should align table content with unicode characters correctly'
    Expect tablemode#align#Align(readfile('t/fixtures/align/unicode_before.txt')) == readfile('t/fixtures/align/unicode_after.txt')
  end
end
