let s:save_cpo= &cpo
set cpo&vim

"
" Example1 - listing files by candidate-first mode
"
let s:define= {
\   'name': 'ex-files',
\}

function! s:define.init(context)
    if has('win32')
        let self.__proc= vimproc#popen2('DIR /S /B /A:A')
    else
        let self.__proc= vimproc#popen2('find -type f -a -not -regex "\.git"')
    endif
    return []
endfunction

function! s:define.async_init(context)
    if self.__proc.stdout.eof
        call self.__proc.waitpid()
        call remove(self, '__proc')
        return {
        \   'done': 1,
        \   'candidates': [],
        \}
    endif

    try
        let files= self.__proc.stdout.read_lines()
        return {
        \   'done': 0,
        \   'candidates': files,
        \}
    catch
        echoerr v:exception
        call self.__proc.waitpid()
        call remove(self, '__proc')
        return {'done': 1, 'candidates': []}
    endtry
endfunction

function! s:define.accept(context, str)
    call milqi#exit()

    execute 'edit' a:str
endfunction

function! s:define.exit(context)
    if has_key(self, '__proc')
        call self.__proc.waitpid()
    endif
endfunction

command!
\   MilqiExFiles
\   call milqi#candidate_first(s:define)

let &cpo= s:save_cpo
unlet s:save_cpo
