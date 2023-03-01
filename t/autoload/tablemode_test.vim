source t/config/options.vim

function! s:TestTablemodeEnable()
  silent call tablemode#Enable()
  call testify#assert#assert(b:table_mode_active)
endfunction
call testify#it('tablemode#Enable should work', function('s:TestTablemodeEnable'))

function! s:TestTablemodeDisable()
  silent call tablemode#Disable()
  call testify#assert#assert(!b:table_mode_active)
endfunction
call testify#it('tablemode#Disable should work', function('s:TestTablemodeDisable'))

function! s:TestTablemodeToggle()
  if exists('b:table_mode_active')
    call testify#assert#assert(!b:table_mode_active)
  endif
  silent call tablemode#Toggle()
  call testify#assert#assert(b:table_mode_active)
  silent call tablemode#Toggle()
  call testify#assert#assert(!b:table_mode_active)
endfunction
call testify#it('tablemode#Toggle should work', function('s:TestTablemodeToggle'))
