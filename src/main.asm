%include "src/header.asm"
%include "src/global.asm"

%include "src/connect.asm"
%include "src/send.asm"
%include "src/next_id.asm"
%include "src/open_font.asm"
%include "src/create_gc.asm"
%include "src/create_window.asm"
%include "src/map_window.asm"

section .rodata
sun_path: db "/tmp/.X11-unix/X0", 0
static sun_path:data

section .text

global _start:

die:
  mov rax, SYSCALL_EXIT
  mov rdi, 1
  syscall

_start:
global _start:function
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
  %define WINDOW_W 800
  %define WINDOW_H 600
  mov r9d, WINDOW_W | (WINDOW_H << 16)
  call create_window

  mov rdi, r15 ; socket fd
  mov esi, ebx
  call map_window

loop:
jmp loop

  ; The end.
  mov rax, SYSCALL_EXIT
  mov rdi, 0
  syscall
