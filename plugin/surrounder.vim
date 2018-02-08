" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: surrounder.vim
" Last Modified: 2018-02-08 16:24:56
" Vim: enc=utf-8

let s:patmap={"'": "'", '"': '"', '(': ')', '[': ']', '{': '}', '<': '>'}


" Function: s:ShowInfo(str) function
" 印出字串用
"
" Args:
"   -str: 要印出的字串
function! s:ShowInfo(str)
    if g:surrounder_show_info
        redraw
        echohl WarningMsg
        echo a:str
        echohl NONE
    else
        return
    endif
endfunction


function! s:GetBracketsMap(pat)
    return s:patmap[a:pat]
endfunction


function! s:IsBrackets(pat)
    if has_key(s:patmap, a:pat)
        return 1
    endif
    call s:ShowInfo("   ❖  不支援字元".a:pat." ❖ ")
    return 0
endfunction


function! s:IsInSurround(pat)
    let nofound = 0
    let b:curcol = col(".")
    let b:curline = line(".")
    execute "normal! F".a:pat
    if matchstr(getline('.'), '\%' . col('.') . 'c.') !=# a:pat
        " Ref: https://stackoverflow.com/questions/23323747/vim-vimscript-get-exact-character-under-the-cursor
        let nofound = 1
    endif
    let leftcol=col(".")
    execute "normal! f".s:GetBracketsMap(a:pat)
    if matchstr(getline('.'), '\%' . col('.') . 'c.') !=# s:GetBracketsMap(a:pat)
        let nofound = 1
    endif
    let rightcol=col(".")
    if nofound ==# 0 && leftcol <= b:curcol && rightcol >= b:curcol && leftcol !=# rightcol
        return 1
    else
        call s:ShowInfo("   ❖  沒有在".a:pat.s:GetBracketsMap(a:pat)."裡喔 ❖ ")
    endif
    " recover sorcur position
    call cursor(b:curline, b:curcol)
    return 0
endfunction


function! s:SaveMap(pat)
    let s:save=maparg(a:pat, 'i')
    execute 'inoremap ' . a:pat . ' ' . a:pat."\<CR>"
endfunction


function! s:RestoreMap(pat)
    execute 'inoremap ' . a:pat . ' ' . s:save."\<CR>"
endfunction


function! s:Surround(num, pat)
    if s:IsBrackets(a:pat) ==# 0
        return
    endif
    let b:curcol = col(".")
    let b:curline = line(".")
    call s:SaveMap(a:pat)
    execute "normal! viw\<ESC> bi".a:pat
    for i in range(a:num)
        execute "normal! e"
    endfor
    execute "normal! a".s:GetBracketsMap(a:pat)
    call s:RestoreMap(a:pat)
    call s:ShowInfo("   ❖  加入".a:pat.s:GetBracketsMap(a:pat)." ❖ ")
    call cursor(b:curline, b:curcol + 1)
endfunction


function! s:SurroundNadd(num)
    let pat = nr2char(getchar())
    call s:Surround(a:num, pat)
endfunction


function! s:SurroundVadd(vmode)
    " Ref: https://stackoverflow.com/questions/29091614/vim-determine-if-function-called-from-visual-block-mode
    let pat = nr2char(getchar())
    let b:curcol = col(".")
    let b:curline = line(".")
    " check is can be added
    if s:IsBrackets(pat) ==# 0
        return
    endif
    let b:curcol = col(".")
    call s:SaveMap(pat)
    if a:vmode ==# 'v'
        execute "normal! `>a".s:GetBracketsMap(pat)
        execute "normal! `<i".pat
    elseif a:vmode ==# 'V'
        execute "normal! `>a".s:GetBracketsMap(pat)
        execute "normal! `<i".pat
    else
        execute "normal! gvOI".pat
        execute "normal! gvlOlA".s:GetBracketsMap(pat)."\<ESC>"
    endif
    call s:RestoreMap(pat)
    call s:ShowInfo("   ❖  加入".pat.s:GetBracketsMap(pat)." ❖ ")
    " recover sorcur position
    call cursor(b:curline, b:curcol + 1)
endfunction


function! s:SurroundNdel()
    let pat = nr2char(getchar())
    let b:curcol = col(".")
    let b:curline = line(".")
    " check is can be deleted
    if s:IsBrackets(pat) ==# 0 || s:IsInSurround(pat) ==# 0
        return
    endif
    " delete
    execute "normal! F".pat."xf".s:GetBracketsMap(pat)."x"
    call s:ShowInfo("   ❖  刪除".pat.s:GetBracketsMap(pat)." ❖ ")
    " recover sorcur position
    call cursor(b:curline, b:curcol - 1)
endfunction


function! s:SurroundNrep()
    let pat1 = nr2char(getchar())
    let pat2 = nr2char(getchar())
    let b:curcol = col(".")
    let b:curline = line(".")
    " check is can be deleted
    if s:IsBrackets(pat1) ==# 0 || s:IsBrackets(pat2) ==# 0 || s:IsInSurround(pat1) ==# 0
        return
    endif
    " replace
    execute "normal! F".pat1."r".pat2."f".s:GetBracketsMap(pat1)."r".s:GetBracketsMap(pat2)
    call s:ShowInfo("   ❖  取代".pat1.s:GetBracketsMap(pat1)."為".pat2.s:GetBracketsMap(pat2)." ❖ ")
    " recover sorcur position
    call cursor(b:curline, b:curcol)
endfunction


" Function: s:InitVariable() function
" 初始化變數
" Ref: https://github.com/scrooloose/nerdcommenter/blob/master/plugin/NERD_commenter.vim#L26
" Args:
"   -var: the name of the var to be initialised
"   -value: the value to initialise var to
"
" Returns:
"   1 if the var is set, 0 otherwise
function! s:InitVariable(var, value)
    if !exists(a:var)
        execute 'let ' . a:var . ' = ' . "'" . a:value . "'"
        return 1
    endif
    return 0
endfunction


" Section: variable initialization
call s:InitVariable("g:surrounder_use_default_mapping", 1)
call s:InitVariable("g:surrounder_n_add_key",           "<leader>s")
call s:InitVariable("g:surrounder_v_add_key",           "<leader>s")
call s:InitVariable("g:surrounder_n_del_key",           "<leader>d")
call s:InitVariable("g:surrounder_n_rep_key",           "<leader>f")
call s:InitVariable("g:surrounder_show_info",           1)



" Section: key map設定
command! -nargs=+ S call s:Surround(<f-args>)
function! s:SetUpKeyMap()
    execute "nnoremap <silent> ".g:surrounder_n_add_key." :<C-u>call <SID>SurroundNadd(v:count1)<CR>"
    execute "vnoremap <silent> ".g:surrounder_v_add_key." :<C-u>call <SID>SurroundVadd(visualmode())<CR>"
    execute "nnoremap <silent> ".g:surrounder_n_del_key." :<C-u>call <SID>SurroundNdel()<CR>"
    execute "nnoremap <silent> ".g:surrounder_n_rep_key." :<C-u>call <SID>SurroundNrep()<CR>"
endfunction
if g:surrounder_use_default_mapping
    call s:SetUpKeyMap()
endif
