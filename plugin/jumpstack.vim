function! jumpstack#InitVar()
    if !exists("w:jumpstack_stack")
        let w:jumpstack_stack = []
    endif
    if !exists("w:jumpstack_current")
        let w:jumpstack_current = -1
    endif
    if !exists("g:jumpstack_diff_level")
        let g:jumpstack_diff_level = 1
    endif
endfunction()

function! jumpstack#Mark(...)
    call jumpstack#InitVar()
    let diff_level = g:jumpstack_diff_level
    if a:0 == 1
        let diff_level = a:1
    endif
    call jumpstack#MarkPos(expand('%:p'), getpos('.'), diff_level)
endfunction

function! jumpstack#MarkPos(file, pos, diff_level)
    call jumpstack#InitVar()
    let w:jumpstack_stack = w:jumpstack_stack[:w:jumpstack_current]
    if len(w:jumpstack_stack) > 0
        let last = w:jumpstack_stack[-1]
        if a:diff_level == 0 && last[0] == a:file
            return
        elseif a:diff_level == 1 && last[0] == a:file && last[1][1] == a:pos[1]
            return
        elseif a:diff_level == 2 && last[0] == a:file && last[1][1] == a:pos[1] && last[1][0] == a:pos[0]
            return
        endif
    endif
    call add(w:jumpstack_stack, [expand('%:p'), getpos('.')])
    let w:jumpstack_current =  w:jumpstack_current + 1
endfunction

function! jumpstack#JumpNext()
    call jumpstack#InitVar()
    call jumpstack#Jump(w:jumpstack_current + 1)
endfunction

function! jumpstack#JumpPrevious()
    call jumpstack#InitVar()
    call jumpstack#Jump(w:jumpstack_current - 1)
endfunction

function! jumpstack#Jump(index)
    call jumpstack#InitVar()
    if a:index < 0 || a:index >= len(w:jumpstack_stack)
        return
    endif
    let target = w:jumpstack_stack[a:index]
    let file = target[0]
    let pos = target[1]
    if empty(glob(file))
        return
    endif
    exec "edit ".file
    call setpos('.', pos)
    let w:jumpstack_current = a:index
endfunction

function! jumpstack#EchoStack()
    let i = 0
    while i < len(w:jumpstack_stack)
        let item = w:jumpstack_stack[i]
        if i == w:jumpstack_current
            echomsg join(['> ', item[0], item[1][1]], ':')
        else
            echomsg join([item[0], item[1][1]], ':')
        endif
        let i = i + 1
    endwhile
endfunction
