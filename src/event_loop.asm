%define KEYPRESS 2
%define MOUSEPRESS 4

    ;; This macro changes one element of the bit set to the one gicven inparameter
    ;; @param rax x
    ;; @param rax y
%macro dn 3

mov [rsp + 64 + WINDOW_W * %2],

%end

; Poll indefinitely messages from the X11 server with poll(2).
; @param rdi The socket file descriptor.
; @param esi The window id.
; @param edx The gc id.
event_loop:
static poll_messages:function
push rbp
mov rbp, rsp

mov r15, WINDOW_W
mov rax, WINDOW_H
imul r15, rax
add r15, 64

sub rsp, 64

%define POLLIN 0x001
%define POLLPRI 0x002
%define POLLOUT 0x004
%define POLLERR  0x008
%define POLLHUP  0x010
%define POLLNVAL 0x020

mov DWORD [rsp + 0*4], edi
mov DWORD [rsp + 1*4], POLLIN

mov DWORD [rsp + 16], esi ; window id
mov DWORD [rsp + 20], edx ; gc id
mov BYTE [rsp + 24], 0 ; exposed? (boolean)

.loop:
mov rax, SYSCALL_POLL
lea rdi, [rsp]
mov rsi, 1
mov rdx, -1
syscall

cmp rax, 0
jle die


cmp DWORD [rsp + 2*4], POLLERR
je die

cmp DWORD [rsp + 2*4], POLLHUP
je die

;; As x11 messages are rarely longer than 32 bytes, we are reading only 32 bytes
mov rax, SYSCALL_READ
mov rdi, [rsp + 0*4]
lea rsi, [rsp + 32]
mov rdx, 32
syscall

mov al, BYTE [rsp + 32]
movzx rax, al

%define X11_EVENT_EXPOSURE 12
cmp eax, X11_EVENT_EXPOSURE
jnz .received_other_event

.received_exposed_event:
mov BYTE [rsp + 24], 1 ; Mark as exposed.

.received_other_event:

cmp BYTE [rsp + 24], 1 ; exposed?
jnz .loop


cmp eax, MOUSEPRESS
jnz .loop

.draw_text:
mov rdi, [rsp + 0*4] ; socket fd
lea rsi, [hello_world] ; string
mov edx, 14 ; length
mov ecx, [rsp + 16] ; window id
mov r8d, [rsp + 20] ; gc id
mov r9d, 100 ; x
shl r9d, 16
or r9d, 100 ; y
call x11_draw_text

jmp .loop

add rsp, 80
pop rbp
ret
