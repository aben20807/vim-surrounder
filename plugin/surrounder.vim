" Author: Huang Po-Hsuan <aben20807@gmail.com>
" Filename: surrounder.vim
" Last Modified: 2018-01-31 20:08:37
" Vim: enc=utf-8

let s:patmap={"'": "'", '"': '"', '(': ')', '[': ']', '{': '}', '<': '>'}

function! s:getBracketsMap(pat)
    return s:patmap[a:pat]
endfunction


function! s:isBrackets(pat)
    if has_key(s:patmap, a:pat)
        return 1
    endif
    redraw
    echohl WarningMsg
        echo "   ❖  不支援字元".a:pat." ❖ "
    echohl NONE
    return 0
endfunction


function! s:isInSurround(pat)
    let nofound = 0
    let b:curcol = col(".")
    let b:curline = line(".")
    execute "normal F".a:pat
    if matchstr(getline('.'), '\%' . col('.') . 'c.') !=# a:pat
        " Ref: https://stackoverflow.com/questions/23323747/vim-vimscript-get-exact-character-under-the-cursor
        let nofound = 1
    endif
    let leftcol=col(".")
    execute "normal f".s:getBracketsMap(a:pat)
    if matchstr(getline('.'), '\%' . col('.') . 'c.') !=# s:getBracketsMap(a:pat)
        let nofound = 1
    endif
    let rightcol=col(".")
    if nofound ==# 0 && leftcol <= b:curcol && rightcol >= b:curcol && leftcol !=# rightcol
        return 1
    else
        redraw
        echohl WarningMsg
            echo "   ❖  沒有在".a:pat.s:getBracketsMap(a:pat)."裡喔 ❖ "
        echohl NONE
    endif
    " recover sorcur position
    call cursor(b:curline, b:curcol)
    return 0
endfunction


function! s:saveMap(pat)
    let s:save=maparg(a:pat, 'i')
    execute 'inoremap ' . a:pat . ' ' . a:pat
endfunction


function! s:restoreMap(pat)
    execute 'inoremap ' . a:pat . ' ' . s:save
endfunction


function! s:surround(num, pat)
    " check is can delete
    if s:isBrackets(a:pat) ==# 0
        return
    endif
    let b:curcol = col(".")
    let b:curline = line(".")
    call s:saveMap(a:pat)
    execute "normal viw\<ESC> bi".a:pat
    for i in range(a:num)
        execute "normal e"
    endfor
    execute "normal a".s:getBracketsMap(a:pat)
    call s:restoreMap(a:pat)
    redraw
    echohl WarningMsg
        echo "   ❖  加入".a:pat.s:getBracketsMap(a:pat)." ❖ "
    echohl NONE
    call cursor(b:curline, b:curcol + 1)
endfunction


function! s:surroundNadd(num)
    let pat = nr2char(getchar())
    call s:surround(a:num, pat)
endfunction


function! s:surroundVadd(vmode)
    " Ref: https://stackoverflow.com/questions/29091614/vim-determine-if-function-called-from-visual-block-mode
    " FIXME v 模式多行最後會多一個字元
    " FIXME V 模式往上選會把上面當成尾端
    " FIXME v 模式往前選會括錯
    let pat = nr2char(getchar())
    let b:curcol = col(".")
    let b:curline = line(".")
    " check is can be added
    if s:isBrackets(pat) ==# 0
        return
    endif
    let b:curcol = col(".")
    call s:saveMap(pat)
    if a:vmode ==# 'v'
        execute "normal gvO\<ESC> hi".pat
        execute "normal gvO\<ESC> a".s:getBracketsMap(pat)."\<ESC>"
    elseif a:vmode ==# 'V'
        execute "normal gvO\<ESC> I".pat
        execute "normal gvO\<ESC> A".s:getBracketsMap(pat)."\<ESC>"
    else
        execute "normal gvOI".pat
        execute "normal gvlOlA".s:getBracketsMap(pat)."\<ESC>"
    endif
    call s:restoreMap(pat)
    redraw
    echohl WarningMsg
        echo "   ❖  加入".pat.s:getBracketsMap(pat)." ❖ "
    echohl NONE
    " recover sorcur position
    call cursor(b:curline, b:curcol + 1)
endfunction


function! s:surroundNdel()
    let pat = nr2char(getchar())
    let b:curcol = col(".")
    let b:curline = line(".")
    " check is can be deleted
    if s:isBrackets(pat) ==# 0
        return
    endif
    if s:isInSurround(pat) ==# 0
        return
    endif
    " delete
    execute "normal F".pat."xf".s:getBracketsMap(pat)."x"
    redraw
    echohl WarningMsg
        echo "   ❖  刪除".pat.s:getBracketsMap(pat)." ❖ "
    echohl NONE
    " recover sorcur position
    call cursor(b:curline, b:curcol - 1)
endfunction


function! s:surroundNrep()
    let pat1 = nr2char(getchar())
    let pat2 = nr2char(getchar())
    let b:curcol = col(".")
    let b:curline = line(".")
    " check is can be deleted
    if s:isBrackets(pat1) ==# 0
        return
    endif
    if s:isBrackets(pat2) ==# 0
        return
    endif
    if s:isInSurround(pat1) ==# 0
        return
    endif
    " replace
    execute "normal F".pat1."r".pat2."f".s:getBracketsMap(pat1)."r".s:getBracketsMap(pat2)
    redraw
    echohl WarningMsg
        echo "   ❖  取代".pat1.s:getBracketsMap(pat1)."為".pat2.s:getBracketsMap(pat2)." ❖ "
    echohl NONE
    " recover sorcur position
    call cursor(b:curline, b:curcol)
endfunction


" Function: s:initVariable() function
" 初始化變數
" Ref: https://github.com/scrooloose/nerdcommenter/blob/master/plugin/NERD_commenter.vim#L26
" Args:
"   -var: the name of the var to be initialised
"   -value: the value to initialise var to
"
" Returns:
"   1 if the var is set, 0 otherwise
function! s:initVariable(var, value)
    if !exists(a:var)
        execute 'let ' . a:var . ' = ' . "'" . a:value . "'"
        return 1
    endif
    return 0
endfunction


" Section: variable initialization
call s:initVariable("g:surrounder_n_add_key", "<leader>s")
call s:initVariable("g:surrounder_v_add_key", "<leader>s")
call s:initVariable("g:surrounder_n_del_key", "<leader>d")
call s:initVariable("g:surrounder_n_rep_key", "<leader>f")


" Section: key map設定
command! -nargs=+ S call s:surround(<f-args>)
function! s:setUpKeyMap()
    execute "nnoremap <silent> ".g:surrounder_n_add_key." :<C-u>call <SID>surroundNadd(v:count1)<CR>"
    execute "vnoremap <silent> ".g:surrounder_v_add_key." :<C-u>call <SID>surroundVadd(visualmode())<CR>"
    execute "nnoremap <silent> ".g:surrounder_n_del_key." :<C-u>call <SID>surroundNdel()<CR>"
    execute "nnoremap <silent> ".g:surrounder_n_rep_key." :<C-u>call <SID>surroundNrep()<CR>"
endfunction
call s:setUpKeyMap()
