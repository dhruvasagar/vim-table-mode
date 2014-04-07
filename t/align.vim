" vim: fdm=indent
source t/config.vim

call vspec#hint({'scope': 'tablemode#align#scope()', 'sid': 'tablemode#align#sid()'})

describe 'Align'
  it 'should align table content correctly'
    let lines = ['| This | is a | table |', '| This | is also | a table |']
    let result = ['| This | is a    | table   |', '| This | is also | a table |']
    Expect tablemode#align#Align(lines) == result
  end

  it 'should align table content with unicode characters correctly'
    let lines = ['| This | is 測試 | table |', '| This | is also | a table |']
    let result = ['| This | is 測試 | table   |', '| This | is also | a table |']
    Expect tablemode#align#Align(lines) == result
  end
end
