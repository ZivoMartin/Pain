; Map a X11 window.
; @param rdi The socket file descriptor.
; @param esi The window id.
map_window:
static x11_map_window:function
push rbp
mov rbp, rsp

sub rsp, 16

%define OP_REQ_MAP_WINDOW 0x08  ; Map window op
mov DWORD [rsp + 0*4], OP_REQ_MAP_WINDOW | (2<<16) ; Size of the packet and op code
mov DWORD [rsp + 1*4], esi                             ; Window code

    ;;  Writing to the socket
mov rax, SYSCALL_WRITE
mov rdi, rdi
lea rsi, [rsp]
mov rdx, 2*4
syscall

    ;; Checking that everything has been wrote
cmp rax, 2*4
jnz die

add rsp, 16

pop rbp
ret
