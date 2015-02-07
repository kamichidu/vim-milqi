" The MIT License (MIT)
"
" Copyright (c) 2015 kamichidu
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
let s:save_cpo= &cpo
set cpo&vim

let s:ui= {
\   '__handler': {},
\   '__finish': 0,
\   '__input': milqi#ui#input#new(),
\}

function! s:init_buffer() abort
    let mappings= {
    \   'PrtBS()':              ['<BS>', '<C-]>'],
    \   'PrtDelete()':          ['<Del>'],
    \   'PrtDeleteWord()':      ['<C-W>'],
    \   'PrtClear()':           ['<C-U>'],
    \   'PrtSelectMove("j")':   ['<C-J>', '<Down>'],
    \   'PrtSelectMove("k")':   ['<C-K>', '<Up>'],
    \   'PrtSelectMove("t")':   ['<Home>', '<kHome>'],
    \   'PrtSelectMove("b")':   ['<End>', '<kEnd>'],
    \   'PrtSelectMove("u")':   ['<PageUp>', '<kPageUp>'],
    \   'PrtSelectMove("d")':   ['<PageDown>', '<kPageDown>'],
    \   'PrtHistory(-1)':       ['<C-N>'],
    \   'PrtHistory(1)':        ['<C-P>'],
    \   'AcceptSelection("e")': ['<CR>', '<2-LeftMouse>'],
    \   'AcceptSelection("h")': ['<C-X>', '<C-CR>', '<C-S>'],
    \   'AcceptSelection("t")': ['<C-T>'],
    \   'AcceptSelection("v")': ['<C-V>', '<RightMouse>'],
    \   'ToggleFocus()':        ['<S-Tab>'],
    \   'ToggleRegex()':        ['<C-R>'],
    \   'ToggleByFname()':      ['<C-D>'],
    \   'ToggleType(1)':        ['<C-F>', '<C-UP>'],
    \   'ToggleType(-1)':       ['<C-B>', '<C-Down>'],
    \   'PrtExpandDir()':       ['<Tab>'],
    \   'PrtInsert("c")':       ['<MiddleMouse>', '<Insert>'],
    \   'PrtInsert()':          ['<C-\>'],
    \   'PrtCurStart()':        ['<C-A>'],
    \   'PrtCurEnd()':          ['<C-E>'],
    \   'PrtCurLeft()':         ['<C-H>', '<Left>', '<C-^>'],
    \   'PrtCurRight()':        ['<C-L>', '<Right>'],
    \   'PrtClearCache()':      ['<F5>'],
    \   'PrtDeleteEnt()':       ['<F7>'],
    \   'CreateNewFile()':      ['<C-Y>'],
    \   'MarkToOpen()':         ['<C-Z>'],
    \   'OpenMulti()':          ['<C-O>'],
    \   'PrtExit()':            ['<Esc>', '<C-C>', '<C-G>'],
    \}

    for [fun, keys] in items(mappings)
        for key in keys
            execute 'nnoremap <buffer><silent>' key ':<C-U>call <SID>' . fun . '<CR>'
        endfor
    endfor
endfunction

function! s:start() dict abort
    let save_t_ve= &t_ve
    set t_ve=
    try
        call self.__handler.open_buffer()
        call self.__handler.init_buffer()
        call s:init_buffer()

        let b:ui= self

        call self.__input.on_changed(self.__handler, 'on_text_changed')

        call self.__handler.init_variable()
        call self.__handler.init_context()
        call self.__handler.refresh()

        while !self.__finish
            echo
            echohl Comment | echon '>>> ' |
            \   echohl Comment | echon join(self.__input.left_part(), '') |
            \   echohl Cursor  | echon join(self.__input.cursor_part(), '') |
            \   echohl Comment | echon join(self.__input.right_part(), '') |
            \   echohl None
            redraw

            let base_time= reltime()
            while 1
                let nr= getchar(0)
                if type(nr) != type(0) || nr != 0
                    break
                endif
                if str2float(reltimestr(reltime(base_time))) >= 0.5
                    call self.__handler.refresh()
                    let base_time= reltime()
                endif
            endwhile
            let ch= (type(nr) == type(0)) ? nr2char(nr) : nr

            if nr >= 0x20
                call self.__input.append(ch)
            else
                let cmd= matchstr(maparg(ch), ':<C-U>\zs.\+\ze<CR>$')
                if cmd !=# ''
                    execute cmd
                else
                    execute 'normal ' . ch
                endif
            endif
        endwhile

        call self.__handler.exit()
        if exists('b:ui') && b:ui is self
            call s:PrtExit()
        endif
    finally
        let &t_ve= save_t_ve
    endtry
endfunction

let s:ui.start= function('s:start')

function! s:stop()
    call s:PrtExit()
endfunction

let s:ui.stop= function('s:stop')

function! milqi#ui#start(handler) abort
    let ui= deepcopy(s:ui)

    let ui.__handler= a:handler

    call ui.start()
endfunction

" ==================================================================================================

function! s:PrtBS()
    call b:ui.__input.backspace()
endfunction

function! s:PrtDelete()
    call b:ui.__input.delete()
endfunction

function! s:PrtDeleteWord()
    call b:ui.__input.delete_word()
endfunction

function! s:PrtClear()
    call b:ui.__input.clear()
endfunction

function! s:PrtSelectMove(mode)
    if a:mode ==# 'j'
        keepjumps normal j
    elseif a:mode ==# 'k'
        keepjumps normal k
    elseif a:mode ==# 't'
        keepjumps normal H
    elseif a:mode ==# 'b'
        keepjumps normal L
    endif
endfunction

function! s:PrtHistory(n)
endfunction

function! s:AcceptSelection(mode)
    let b:ui.__finish= 1

    if a:mode ==# 'e'
        call b:ui.__handler.accept()
    elseif a:mode ==# 'h'
        call b:ui.__handler.accept()
    elseif a:mode ==# 't'
        call b:ui.__handler.accept()
    elseif a:mode ==# 'v'
        call b:ui.__handler.accept()
    else
        call b:ui.__handler.accept()
    endif
endfunction

function! s:ToggleFocus()
endfunction

function! s:ToggleRegex()
endfunction

function! s:ToggleByFname()
endfunction

function! s:ToggleType(n)
endfunction

function! s:PrtExpandDir()
endfunction

function! s:PrtInsert(...)
endfunction

function! s:PrtCurStart()
    call b:ui.__input.move_cursor("\<Home>")
endfunction

function! s:PrtCurEnd()
    call b:ui.__input.move_cursor("\<End>")
endfunction

function! s:PrtCurLeft()
    call b:ui.__input.move_cursor("h")
endfunction

function! s:PrtCurRight()
    call b:ui.__input.move_cursor("l")
endfunction

function! s:PrtClearCache()
endfunction

function! s:PrtDeleteEnt()
endfunction

function! s:CreateNewFile()
endfunction

function! s:MarkToOpen()
endfunction

function! s:OpenMulti()
endfunction

function! s:PrtExit()
    let b:ui.__finish= 1
    noautocmd call s:close()
    noautocmd wincmd p
endfunction

function! s:close()
    if winnr('$') == 1
        bwipeout!
    else
        try
            bunload!
        catch
            close!
        endtry
    endif
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
