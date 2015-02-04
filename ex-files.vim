let s:define= {
\   'name': 'ex-files',
\}

function! s:define.init(context)
    if has('win32')
        let self.__proc= vimproc#popen2('dir /s /b')
    else
        let self.__proc= vimproc#popen2('find')
    endif
    return []
endfunction

function! s:define.async_init(context)
    try
        let files= self.__proc.stdout.read_lines()
    catch
        echoerr v:exception
        call self.__proc.waitpid()
        return {'done': 1, 'candidates': []}
    endtry

    return {
    \   'done': !self.__proc.stdout.eof,
    \   'candidates': files,
    \}
endfunction

function! s:define.accept(context, str)
    call milqi#exit()

    echo "You choose " . a:str
endfunction

command! MilqiExFiles call milqi#candidate_first(s:define)
