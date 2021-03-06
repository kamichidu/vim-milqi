" The MIT License (MIT)
"
" Copyright (c) 2014 kamichidu
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

let s:milqi= milqi#mode#base#new()

let s:milqi.__done= 0

function! s:refresh_candidates() dict
    if has_key(self.__define, 'async_init') && !self.__done
        let response= self.__define.async_init(self.__context)

        let self.__done= response.done
        let self.__candidates+= response.candidates
    endif
endfunction
let s:milqi.refresh_candidates= function('s:refresh_candidates')

function! s:refresh_statusline() dict
    let &l:statusline= printf('--- milqi --- (%s) --- (%d/%d) --- %s',
    \   self.__define.name,
    \   len(self.__shown_candidates),
    \   len(self.__candidates),
    \   (self.__done ? 'Finished' : 'Executing...')
    \)
endfunction
let s:milqi.refresh_statusline= function('s:refresh_statusline')

function! milqi#mode#candidate_first#init(define, context)
    let milqi= deepcopy(s:milqi)

    call milqi.init(a:define, a:context)
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
