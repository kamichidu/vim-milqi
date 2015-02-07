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
let s:L= s:V.import('Data.List')
let s:BM= s:V.import('Vim.BufferManager')
unlet s:V

function! s:init(define, context) dict
    let self.__define= a:define
    let self.__context= a:context
    let self.__candidates= self.__define.init(self.__context)
    let self.__mappings= {}
    let self.__input= ''

    call milqi#ui#start(self)
endfunction

function! s:init_context() dict
endfunction

function! s:open_buffer() dict
    if !exists('s:milqi_buffer')
        let s:milqi_buffer= s:BM.new({
        \   'opener': 'botright split',
        \   'range': 'tabpage',
        \})
    endif
    call s:milqi_buffer.open('--- milqi ---')
endfunction

function! s:init_buffer() dict
    let b:milqi= self

    let max_size= get(self.__define, 'max_size', 20)
    execute 'resize' max_size

    setlocal nobuflisted buftype=nofile bufhidden=unload
    setlocal nonumber norelativenumber
    setlocal filetype=milqi

    setlocal cursorline

    let self.__bufvar= b:
endfunction

function! s:init_variable() dict
endfunction

function! s:refresh() dict
    let save_pos= getpos('.')
    try
        call self.refresh_candidates()

        let max_size= get(self.__define, 'max_size', 20)
        let candidates= reverse(copy(self.filter(self.__context, self.__candidates)))[ : (max_size - 1)]
        let self.__shown_candidates= candidates

        execute 'resize' max([len(self.__shown_candidates), 1])
        call self.refresh_statusline()

        %delete _
        call setline(1, map(copy(candidates), 'self.format_candidate(v:val)'))

        let self.__mappings= {}
        let lnum= 1
        for candidate in candidates
            let self.__mappings[lnum]= candidate
            let lnum+= 1
        endfor
    finally
        call setpos('.', save_pos)
        redraw
    endtry
endfunction

function! s:refresh_candidates() dict
    throw 'milqi: No implementation given.'
endfunction

function! s:refresh_statusline() dict
    let &l:statusline= printf('--- milqi --- (%s) --- (%d/%d)',
    \   self.__define.name,
    \   len(self.__shown_candidates),
    \   len(self.__candidates)
    \)
endfunction

function! s:filter(context, candidates) dict
    let candidates= map(copy(a:candidates), '[v:val, self.get_abbr(v:val)]')

    for pattern in split(self.__input, '\s\+')
        try
            if pattern =~# '^!'
                let pattern= strpart(pattern, 1)
                call filter(candidates, 'v:val[1] !~ pattern')
            else
                call filter(candidates, 'v:val[1] =~ pattern')
            endif
        catch /E\(51\|53\|54\|55\|56\|57\|58\|59\|60\|61\|62\|63\|64\|65\|68\|69\|70\|71\|76\|369\|383\|386\|476\|486\|554\|678\|769\|864\|865\|866\|867\|868\|869\|870\|871\|872\|873\|874\|875\|876\|877\|878\|888\):/
            " ignore
        endtry
    endfor

    return map(candidates, 'v:val[0]')
endfunction

function! s:format_candidate(candidate) dict
    return ' ' . self.get_abbr(a:candidate)
endfunction

function! s:accept() dict
    if has_key(self.__mappings, line('.'))
        call self.__define.accept(self.__context, self.__mappings[line('.')])
    endif
endfunction

function! s:exit() dict
    if has_key(self.__define, 'exit')
        call self.__define.exit(self.__context)
    endif
endfunction

function! s:get_abbr(candidate) dict
    if has_key(self.__define, 'get_abbr')
        return self.__define.get_abbr(self.__context, a:candidate)
    elseif type(a:candidate) == type('')
        return a:candidate
    else
        return string(a:candidate)
    endif
endfunction

function! s:on_text_changed(input, old_input) dict
    let self.__input= a:input

    call self.refresh()
endfunction

function! milqi#mode#base#new()
    return {
    \   'init': function('s:init'),
    \   'init_context': function('s:init_context'),
    \   'open_buffer': function('s:open_buffer'),
    \   'init_buffer': function('s:init_buffer'),
    \   'init_variable': function('s:init_variable'),
    \   'refresh': function('s:refresh'),
    \   'refresh_candidates': function('s:refresh_candidates'),
    \   'refresh_statusline': function('s:refresh_statusline'),
    \   'filter': function('s:filter'),
    \   'format_candidate': function('s:format_candidate'),
    \   'accept': function('s:accept'),
    \   'exit': function('s:exit'),
    \   'get_abbr': function('s:get_abbr'),
    \   'on_text_changed': function('s:on_text_changed'),
    \}
endfunction

let &cpo= s:save_cpo
unlet s:save_cpo
