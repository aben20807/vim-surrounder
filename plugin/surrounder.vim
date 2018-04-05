" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: surrounder.vim
" Last Modified: 2018-04-05 17:37:36
" Vim: enc=utf-8


" Section: variable initialization
call surrounder#InitVariable("g:surrounder_use_default_mapping", 1)
call surrounder#InitVariable("g:surrounder_n_add_key",           "<leader>s")
call surrounder#InitVariable("g:surrounder_v_add_key",           "<leader>s")
call surrounder#InitVariable("g:surrounder_n_del_key",           "<leader>d")
call surrounder#InitVariable("g:surrounder_n_rep_key",           "<leader>f")
call surrounder#InitVariable("g:surrounder_show_info",           1)
call surrounder#InitVariable("g:surrounder_auto_detect",         1)


" Section: key map設定
command! -nargs=+ S call surrounder#Surround(<f-args>)
function! s:SetUpKeyMap()
    execute "nnoremap <silent> ".g:surrounder_n_add_key." :<C-u>call surrounder#SurroundNadd(v:count1)<CR>"
    execute "vnoremap <silent> ".g:surrounder_v_add_key." :<C-u>call surrounder#SurroundVadd(visualmode())<CR>"
    execute "nnoremap <silent> ".g:surrounder_n_del_key." :<C-u>call surrounder#SurroundNdel()<CR>"
    execute "nnoremap <silent> ".g:surrounder_n_rep_key." :<C-u>call surrounder#SurroundNrep()<CR>"
endfunction
if g:surrounder_use_default_mapping
    call s:SetUpKeyMap()
    call surrounder#CheckAllPat()
endif
