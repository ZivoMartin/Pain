; Draw text in a X11 window with server-side text rendering.
; @param rdi The socket file descriptor.
; @param rsi The text string.
; @param edx The text string length in bytes.
; @param ecx The window id.
; @param r8d The gc id.
; @param r9d Packed x and y.
x11_draw_text:
static x11_draw_text:function
push rbp
mov rbp, rsp

sub rsp, 1024

mov DWORD [rsp + 1*4], ecx ; Store the window id directly in the packet data on the stack.
mov DWORD [rsp + 2*4], r8d ; Store the gc id directly in the packet data on the stack.
mov DWORD [rsp + 3*4], r9d ; Store x, y directly in the packet data on the stack.

mov r8d, edx ; Store the string length in r8 since edx will be overwritten next.
mov QWORD [rsp + 1024 - 8], rdi ; Store the socket file descriptor on the stack to free the register.

; Compute padding and packet u32 count with division and modulo 4.
mov eax, edx ; Put dividend in eax.
mov ecx, 4 ; Put divisor in ecx.
cdq ; Sign extend.
idiv ecx ; Compute eax / ecx, and put the remainder (i.e. modulo) in edx.
; LLVM optimizer magic: `(4-x)%4 == -x & 3`, for some reason.
neg edx
and edx, 3
mov r9d, edx ; Store padding in r9.

mov eax, r8d
add eax, r9d
shr eax, 2 ; Compute: eax /= 4
add eax, 4 ; eax now contains the packet u32 count.


%define X11_OP_REQ_IMAGE_TEXT8 0x4c
mov DWORD [rsp + 0*4], r8d
shl DWORD [rsp + 0*4], 8
or DWORD [rsp + 0*4], X11_OP_REQ_IMAGE_TEXT8
mov ecx, eax
shl ecx, 16
or [rsp + 0*4], ecx

; Copy the text string into the packet data on the stack.
mov rsi, rsi ; Source string in rsi.
lea rdi, [rsp + 4*4] ; Destination
cld ; Move forward
mov ecx, r8d ; String length.
rep movsb ; Copy.

mov rdx, rax ; packet u32 count
imul rdx, 4
mov rax, SYSCALL_WRITE
mov rdi, QWORD [rsp + 1024 - 8] ; fd
lea rsi, [rsp]
syscall

cmp rax, rdx
jnz die

add rsp, 1024

pop rbp
ret
