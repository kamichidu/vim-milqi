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
if exists('g:loaded_milqi') && g:loaded_milqi
    finish
endif
let g:loaded_milqi= 1

let s:save_cpo= &cpo
set cpo&vim

function! s:start_unite(name)
    let sources= unite#sources#{a:name}#define()

    if type(sources) == type([])
        let number= inputlist(map(copy(sources), 'printf("%d - %s", index(sources, v:val) + 1, v:val.name)'))

        if number == 0
            return
        endif
        let source= sources[number - 1]
    else
        let source= sources
    endif

    call milqi#candidate_first(milqi#bridge#unite#new(source))
endfunction

function! s:complete_unite_source(arglead, cmdline, curpos)
    let files= split(globpath(&runtimepath, 'autoload/unite/sources/*.vim'), "\n")
    let names= map(files, 'fnamemodify(v:val, ":t:r")')
    return join(names, "\n")
endfunction

command!
\   -nargs=1 -complete=custom,s:complete_unite_source
\   MilqiFromUnite
\   call s:start_unite(<q-args>)

let &cpo= s:save_cpo
unlet s:save_cpo
