    ;; Create a X11 graphical context.
    ;; @param rdi The socket file descriptor.
    ;; @param esi The graphical context id.
    ;; @param edx The window root id.
    ;; @param ecx The font id.
    ;; We wanna create here a graphical context, it will be an X11 object with its own id representing drawing parameters. We just declare it once and after we can re use it each time we wanna draw something
create_gc:
static x11_create_gc:function
push rbp
mov rbp, rsp

sub rsp, 8*8

%define OP_REQ_CREATE_GC 0x37   ; CreateGC opcode (0x37)
%define FLAG_GC_BG 0x00000004   ; Use background color flag
%define FLAG_GC_FG 0x00000008   ; Use foreground color flag
%define FLAG_GC_FONT 0x00004000 ; Use font flag
%define FLAG_GC_EXPOSE 0x00010000 ; Generate expose events

%define CREATE_GC_FLAGS FLAG_GC_BG | FLAG_GC_FG | FLAG_GC_FONT ; We are simply putting the flags togeither with a binary or
%define CREATE_GC_PACKET_FLAG_COUNT 3                          ; Number of flags
%define CREATE_GC_PACKET_U32_COUNT (4 + CREATE_GC_PACKET_FLAG_COUNT) ;Size of the packet in u32
%define MY_COLOR_RGB 0x0000ffff                                      ; Blue color


mov DWORD [rsp + 0*4], OP_REQ_CREATE_GC | (CREATE_GC_PACKET_U32_COUNT<<16) ; We put here the op code and the
mov DWORD [rsp + 1*4], esi                                                     ; gc id
mov DWORD [rsp + 2*4], edx                                                     ; root window id
mov DWORD [rsp + 3*4], CREATE_GC_FLAGS                                         ; flags
mov DWORD [rsp + 4*4], MY_COLOR_RGB                                            ; Forground color
mov DWORD [rsp + 5*4], 0                                                       ; Background color (default)
mov DWORD [rsp + 6*4], ecx                                                     ; Font id (should be known by the server)

    ;; Now, we write everything on the socket
mov rax, SYSCALL_WRITE
mov rdi, rdi
lea rsi, [rsp]
mov rdx, CREATE_GC_PACKET_U32_COUNT * 4
syscall

cmp rax, CREATE_GC_PACKET_U32_COUNT*4
jnz die

add rsp, 8*8
pop rbp
ret
