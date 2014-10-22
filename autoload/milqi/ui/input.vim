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

function! milqi#ui#input#move_cursor(expr) dict
    if a:expr ==# 'h'
        let self.__curpos= max([self.__curpos - 1, 0])
    elseif a:expr ==# 'l'
        let self.__curpos= min([self.__curpos + 1, len(self.__input)])
    elseif a:expr ==# "\<Home>"
        let self.__curpos= 0
    elseif a:expr ==# "\<End>"
        let self.__curpos= len(self.__input)
    else
        throw printf("milqi: Not supported `%s'.", a:expr)
    endif
endfunction

function! milqi#ui#input#append(text) dict
    let old_value= self.text()
    let text= split(a:text, '\zs')

    let left= self.left_part()
    let cursor= self.cursor_part([])
    let right= self.right_part()

    let self.__input= left + text + cursor + right
    let self.__curpos+= len(text)

    if !empty(self.__listener)
        call call(self.__listener[0][self.__listener[1]], [self.text(), old_value], self.__listener[0])
    endif
endfunction

function! milqi#ui#input#backspace() dict
    if self.__curpos > 0
        let old_value= self.text()

        call remove(self.__input, self.__curpos - 1)
        let self.__curpos-= 1

        if !empty(self.__listener)
            call call(self.__listener[0][self.__listener[1]], [self.text(), old_value], self.__listener[0])
        endif
    endif
endfunction

function! milqi#ui#input#delete() dict
    if self.__curpos < len(self.__input)
        let old_value= self.text()

        call remove(self.__input, self.__curpos)

        if !empty(self.__listener)
            call call(self.__listener[0][self.__listener[1]], [self.text(), old_value], self.__listener[0])
        endif
    endif
endfunction

function! milqi#ui#input#delete_word() dict
    let old_value= self.text()

    let text= join(self.left_part(), '')

    if text =~# '\W\w\+$'
        let text= matchstr(text, '^.\+\W\ze\w\+$')
    elseif text =~# '\w\W\+$'
        let text= matchstr(text, '^.\+\w\ze\W\+$')
    elseif text =~# '\s\+$'
        let text= matchstr(text, '^.*\S\ze\s\+$')
    elseif text =~# '^\(\S\+\|\s\+\)$'
        let text= ''
    endif

    let left= split(text, '\zs')
    let cursor= self.cursor_part([])
    let right= self.right_part()

    let self.__input= left + cursor + right
    let self.__curpos= len(left)

    let value= self.text()
    if !empty(self.__listener) && old_value !=# value
        call call(self.__listener[0][self.__listener[1]], [self.text(), old_value], self.__listener[0])
    endif
endfunction

function! milqi#ui#input#clear() dict
    let old_value= self.text()

    let self.__input= []
    let self.__curpos= 0

    let value= self.text()
    if !empty(self.__listener) && old_value !=# value
        call call(self.__listener[0][self.__listener[1]], [self.text(), old_value], self.__listener[0])
    endif
endfunction

function! milqi#ui#input#left_part() dict
    if self.__curpos > 0
        return self.__input[ : self.__curpos - 1]
    else
        return []
    endif
endfunction

function! milqi#ui#input#cursor_part(...) dict
    if self.__curpos == len(self.__input)
        return get(a:000, 0, ['_'])
    else
        return self.__input[self.__curpos : self.__curpos]
    endif
endfunction

function! milqi#ui#input#right_part() dict
    return self.__input[self.__curpos + 1 : ]
endfunction

function! milqi#ui#input#text() dict
    return join(self.__input, '')
endfunction

function! milqi#ui#input#on_changed(dict, funcname) dict
    let self.__listener= [a:dict, a:funcname]
endfunction

function! milqi#ui#input#new()
    return {
    \   '__curpos': 0,
    \   '__input': [],
    \   '__listener': [],
    \   'append': function('milqi#ui#input#append'),
    \   'backspace': function('milqi#ui#input#backspace'),
    \   'delete': function('milqi#ui#input#delete'),
    \   'delete_word': function('milqi#ui#input#delete_word'),
    \   'clear': function('milqi#ui#input#clear'),
    \   'move_cursor': function('milqi#ui#input#move_cursor'),
    \   'left_part': function('milqi#ui#input#left_part'),
    \   'cursor_part': function('milqi#ui#input#cursor_part'),
    \   'right_part': function('milqi#ui#input#right_part'),
    \   'text': function('milqi#ui#input#text'),
    \   'on_changed': function('milqi#ui#input#on_changed'),
    \}
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
