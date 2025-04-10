%include "src/header.asm"
%include "src/global.asm"
%include "src/macros.asm"

%include "src/connect.asm"
%include "src/send.asm"
%include "src/next_id.asm"
%include "src/open_font.asm"
%include "src/create_gc.asm"
%include "src/create_window.asm"
%include "src/map_window.asm"
%include "src/set_fd_non_blocking.asm"
%include "src/event_loop.asm"
%include "src/draw_text.asm"

section .rodata

_ascii db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, " !", 34, "#$%&", 39, "()*+,-./0123456789:", 59, "<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
_newline: db 10


sun_path: db "/tmp/.X11-unix/X0", 0
static sun_path:data

hello_world: db "Hello, world!", 10, 0
static hello_world:data

section .text

global _start:

die:
mov rax, SYSCALL_EXIT
mov rdi, 1
syscall

_start:
call connect_to_server
mov r15, rax ; Store the socket file descriptor in r15.

mov rdi, rax
call send

mov r12d, eax ; Store the window root id in r12.

call next_id
mov r13d, eax ; Store the gc_id in r13.

call next_id
mov r14d, eax ; Store the font_id in r14.

mov rdi, r15
mov esi, r14d
call open_font


mov rdi, r15
mov esi, r13d
mov edx, r12d
mov ecx, r14d
call create_gc

call next_id

mov ebx, eax ; Store the window id in ebx.

mov rdi, r15 ; socket fd
mov esi, eax
mov edx, r12d
mov ecx, [root_visual_id]
mov r8d, 200 | (200 << 16) ; x and y are 200

mov r9d, WINDOW_W | (WINDOW_H << 16)
call create_window

mov rdi, r15 ; socket fd
mov esi, ebx
call map_window

mov rdi, r15 ; socket fd
call set_fd_non_blocking

mov rdi, r15 ; socket fd
mov esi, ebx ; window id
mov edx, r13d ; gc id
call event_loop


; The end.
mov rax, SYSCALL_EXIT
mov rdi, 0
syscall
