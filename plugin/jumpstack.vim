let s:stack = []
let s:current = -1

function! jumpstack#Mark()
    let s:stack = s:stack[:s:current]
    if len(s:stack) > 0
        let last = s:stack[-1]
        let file = expand('%:p')
        let line = getpos('.')[1]
        if last[0] == file && last[1][1] == line
            return
        endif
    endif
    call add(s:stack, [expand('%:p'), getpos('.')])
    let s:current =  s:current + 1
endfunction

function! jumpstack#JumpNext()
    call jumpstack#Jump(s:current + 1)
endfunction

function! jumpstack#JumpPrevious()
    call jumpstack#Jump(s:current - 1)
endfunction

function! jumpstack#Jump(index)
    if a:index < 0 || a:index >= len(s:stack)
        return
    endif
    let target = s:stack[a:index]
    let file = target[0]
    let pos = target[1]
    if empty(glob(file))
        return
    endif
    exec "edit ".file
    call setpos('.', pos)
    let s:current = a:index
endfunction

function! jumpstack#EchoStack()
    let i = 0
    while i < len(s:stack)
        let item = s:stack[i]
        if i == s:current
            echomsg join(['> ', item[0], item[1][1]], ':')
        else
            echomsg join([item[0], item[1][1]], ':')
        endif
        let i = i + 1
    endwhile
endfunction
