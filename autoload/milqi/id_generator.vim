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

if printf('%d', 0xffffffff) ==# '-1'
    let s:min_value= 0x80000000
    let s:max_value= 0x7fffffff
else
    let s:min_value= 0x8000000000000000
    let s:max_value= 0x7fffffffffffffff
endif

function! s:generate() dict
    let self.__seq+= 1
    return self.__seq
endfunction

function! s:generate_batch(size) dict
    return map(range(a:size), 'self.generate()')
endfunction

function! milqi#id_generator#new()
    return {
    \   '__seq': s:min_value,
    \   'generate': function('s:generate'),
    \   'generate_batch': function('s:generate_batch'),
    \}
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
