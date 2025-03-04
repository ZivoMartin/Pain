    ;;  Set a file descriptor in non-blocking mode.
    ;;  @param rdi The file descriptor.
set_fd_non_blocking:
static set_fd_non_blocking:function
push rbp
mov rbp, rsp

%define F_GETFL 3             ; Flag indicates that we wanna get the current flags of the given fd
%define F_SETFL 4             ; Flag indicates that we wanna modify the current flags of the given fd

%define O_NONBLOCK 2048       ; Flag for non block

  ;; We wanna first get the current flag to modify it without changing other states
mov rax, SYSCALL_FCNTL        ; fcntl is the syscall to change mode on a fd
mov rdi, rdi                  ; The fd
mov rsi, F_GETFL              ; We wanna first get the flag
mov rdx, 0                    ; No need an extra aargument are we are getting
syscall

cmp rax, 0
jl die

; `or` the current file status flag with O_NONBLOCK.
mov rdx, rax
or rdx, O_NONBLOCK              ; We are adding NONBLOCK to the current flag

    ;; Now, we wanna set the new modified flag
mov rax, SYSCALL_FCNTL          ; Same syscall
mov rdi, rdi                    ; Same fd
mov rsi, F_SETFL                ; This time we are using the set flag
mov rdx, rdx                    ; The third parameter contains the new flag to set
syscall

cmp rax, 0
jl die

pop rbp
ret
