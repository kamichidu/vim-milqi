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

let s:V= vital#of('milqi')
let s:D= s:V.import('Data.Dict')
unlet s:V

let s:bridge= {}

function! s:bridge.init(context)
    return self.__source.gather_candidates([], a:context)
endfunction

function! s:bridge.async_init(context)
    if has_key(self.__source, 'async_gather_candidates')
        let candidates= self.__source.async_gather_candidates([], a:context)
        return {
        \   'done': !a:context.is_async,
        \   'candidates': candidates,
        \}
    else
        return {'done': 1, 'candidates': []}
    endif
endfunction

function! s:bridge.get_abbr(context, id)
    return get(a:id, 'abbr', a:id.word)
endfunction

function! s:bridge.accept(context, id)
    call milqi#exit()

    let kind= unite#get_kinds(a:id.kind)
    let default_action= kind.action_table[kind.default_action]

    if get(default_action, 'is_selectable', 0)
        call default_action.func([a:id])
    else
        call default_action.func(a:id)
    endif
endfunction

function! milqi#bridge#unite#new(source)
    let bridge= deepcopy(s:bridge)

    let bridge.name= a:source.name
    let bridge.__seq= milqi#id_generator#new()
    let bridge.__source= a:source

    return bridge
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
