" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: surrounder.vim
" Last Modified: 2018-04-05 17:42:08
" Vim: enc=utf-8

let s:patmap={"'": "'", '"': '"', '(': ')', '[': ']', '{': '}', '<': '>'}


" Function: surrounder#ShowInfo(str) function
" 印出字串用
"
" Args:
"   -str: 要印出的字串
function! surrounder#ShowInfo(str) abort
    if g:surrounder_show_info
        redraw
        echohl WarningMsg
        echo a:str
        echohl NONE
    else
        return
    endif
endfunction


function! surrounder#GetBracketsMap(pat) abort
    return s:patmap[a:pat]
endfunction


function! surrounder#IsBrackets(pat) abort
    if has_key(s:patmap, a:pat)
        return 1
    endif
    call surrounder#ShowInfo("   ❖  不支援字元".a:pat." ❖ ")
    return 0
endfunction


function! surrounder#IsInSurround(pat, is_foreach) abort
    let l:nofound = 0
    let b:curcol = col(".")
    let b:curline = line(".")
    execute "normal! F".a:pat
    if matchstr(getline('.'), '\%' . col('.') . 'c.') !=# a:pat
        " Ref: https://stackoverflow.com/questions/23323747/vim-vimscript-get-exact-character-under-the-cursor
        let l:nofound = 1
    endif
    let l:leftcol=col(".")
    execute "normal! f".surrounder#GetBracketsMap(a:pat)
    if matchstr(getline('.'), '\%' . col('.') . 'c.') !=#
                \surrounder#GetBracketsMap(a:pat)
        let l:nofound = 1
    endif
    let l:rightcol=col(".")
    if l:nofound ==# 0 && l:leftcol <= b:curcol &&
                \l:rightcol >= b:curcol && l:leftcol !=# l:rightcol
        return 1
    else
        if !a:is_foreach
            call surrounder#ShowInfo("   ❖  沒有在"
                        \.a:pat.surrounder#GetBracketsMap(a:pat)."裡喔 ❖ ")
        endif
    endif
    " recover sorcur position
    call cursor(b:curline, b:curcol)
    return 0
endfunction


function! surrounder#CheckAllPat() abort
    let l:patkeys = keys(s:patmap)
    for i in range(len(l:patkeys))
        if surrounder#IsInSurround(l:patkeys[i], 1) ==# 1
            call surrounder#ShowInfo("   ❖  偵測到".l:patkeys[i].
                        \surrounder#GetBracketsMap(l:patkeys[i])." ❖ ")
            return l:patkeys[i]
        endif
    endfor
    return "0"
endfunction


function! surrounder#SaveMap(pat) abort
    let s:save=maparg(a:pat, 'i')
    execute 'inoremap ' . a:pat . ' ' . a:pat."\<CR>"
endfunction


function! surrounder#RestoreMap(pat) abort
    execute 'inoremap ' . a:pat . ' ' . s:save."\<CR>"
endfunction


function! surrounder#Surround(num, pat) abort
    if surrounder#IsBrackets(a:pat) ==# 0
        return
    endif
    let b:curcol = col(".")
    let b:curline = line(".")
    call surrounder#SaveMap(a:pat)
    execute "normal! viw\<ESC> bi".a:pat
    for i in range(a:num)
        execute "normal! e"
    endfor
    execute "normal! a".surrounder#GetBracketsMap(a:pat)
    call surrounder#RestoreMap(a:pat)
    call surrounder#ShowInfo("   ❖  加入".a:pat.
                \surrounder#GetBracketsMap(a:pat)." ❖ ")
    call cursor(b:curline, b:curcol + 1)
endfunction


function! surrounder#SurroundNadd(num) abort
    call surrounder#ShowInfo("   ❖  surround add : ")
    let l:pat = nr2char(getchar())
    if l:pat ==? "\<ESC>"
        call surrounder#ShowInfo("   ❖  取消 ❖ ")
        return
    endif
    call surrounder#Surround(a:num, l:pat)
endfunction


function! surrounder#SurroundVadd(vmode) abort
    " Ref: https://stackoverflow.com/questions/29091614/vim-determine-if-function-called-from-visual-block-mode
    call surrounder#ShowInfo("   ❖  surround add : ")
    let l:pat = nr2char(getchar())
    if l:pat ==? "\<ESC>"
        call surrounder#ShowInfo("   ❖  取消 ❖ ")
        return
    endif
    let b:curcol = col(".")
    let b:curline = line(".")
    " check is can be added
    if surrounder#IsBrackets(l:pat) ==# 0
        return
    endif
    let b:curcol = col(".")
    call surrounder#SaveMap(l:pat)
    if a:vmode ==# 'v'
        execute "normal! `>a".surrounder#GetBracketsMap(l:pat)
        execute "normal! `<i".l:pat
    elseif a:vmode ==# 'V'
        execute "normal! `>a".surrounder#GetBracketsMap(l:pat)
        execute "normal! `<i".l:pat
    else
        execute "normal! gvOI".l:pat
        execute "normal! gvlOlA".surrounder#GetBracketsMap(l:pat)."\<ESC>"
    endif
    call surrounder#RestoreMap(l:pat)
    call surrounder#ShowInfo("   ❖  加入".l:pat.
                \surrounder#GetBracketsMap(l:pat)." ❖ ")
    " recover sorcur position
    call cursor(b:curline, b:curcol + 1)
endfunction


function! surrounder#SurroundNdel() abort
    let b:curcol = col(".")
    let b:curline = line(".")
    if g:surrounder_auto_detect
        let l:pat = surrounder#CheckAllPat()
        if l:pat ==# "0"
            call surrounder#ShowInfo("   ❖  沒有在任何符號裡喔 ❖ ")
            return
        endif
    else
        call surrounder#ShowInfo("   ❖  surround delete : ")
        let l:pat = nr2char(getchar())
        if l:pat ==? "\<ESC>"
            call surrounder#ShowInfo("   ❖  取消 ❖ ")
            return
        endif
        " check is can be deleted
        if surrounder#IsBrackets(l:pat) ==# 0 ||
                    \surrounder#IsInSurround(l:pat, 0) ==# 0
            return
        endif
    endif
    " delete
    execute "normal! F".l:pat."xf".surrounder#GetBracketsMap(l:pat)."x"
    call surrounder#ShowInfo("   ❖  刪除".l:pat.
                \surrounder#GetBracketsMap(l:pat)." ❖ ")
    " recover sorcur position
    call cursor(b:curline, b:curcol - 1)
endfunction


function! surrounder#SurroundNrep() abort
    let b:curcol = col(".")
    let b:curline = line(".")
    if g:surrounder_auto_detect
        let l:pat1 = surrounder#CheckAllPat()
        if l:pat1 ==# "0"
            call surrounder#ShowInfo("   ❖  沒有在任何符號裡喔 ❖ ")
            return
        endif
    else
        call surrounder#ShowInfo("   ❖  surround replace : ")
        let l:pat1 = nr2char(getchar())
        if l:pat1 ==? "\<ESC>"
            call surrounder#ShowInfo("   ❖  取消 ❖ ")
            return
        endif
        " check is can be deleted
        if surrounder#IsBrackets(l:pat1) ==# 0 ||
                    \surrounder#IsInSurround(l:pat1, 0) ==# 0
            return
        endif
    endif
    call surrounder#ShowInfo("   ❖  surround replace : ")
    let l:pat2 = nr2char(getchar())
    if l:pat2 ==? "\<ESC>"
        call surrounder#ShowInfo("   ❖  取消 ❖ ")
        return
    endif
    if surrounder#IsBrackets(l:pat2) ==# 0
        return
    endif
    " replace
    execute "normal! F".l:pat1."r".l:pat2."f".
                \surrounder#GetBracketsMap(l:pat1)."r".
                \surrounder#GetBracketsMap(l:pat2)
    call surrounder#ShowInfo("   ❖  取代".l:pat1.
                \surrounder#GetBracketsMap(l:pat1)."為".l:pat2.
                \surrounder#GetBracketsMap(l:pat2)." ❖ ")
    " recover sorcur position
    call cursor(b:curline, b:curcol)
endfunction


" Function: surrounder#InitVariable() function
" 初始化變數
" Ref: https://github.com/scrooloose/nerdcommenter/blob/master/plugin/NERD_commenter.vim#L26
" Args:
"   -var: the name of the var to be initialised
"   -value: the value to initialise var to
"
" Returns:
"   1 if the var is set, 0 otherwise
function! surrounder#InitVariable(var, value) abort
    if !exists(a:var)
        execute 'let ' . a:var . ' = ' . "'" . a:value . "'"
        return 1
    endif
    return 0
endfunction
