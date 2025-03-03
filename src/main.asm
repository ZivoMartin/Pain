section .rodata
sun_path: db "/tmp/.X11-unix/X0", 0
static sun_path:data

section .text

%define SYSCALL_EXIT 60
%define AF_UNIX 1
%define SOCK_STREAM 1
%define SYSCALL_SOCKET 41
%define SYSCALL_CONNECT 42

global _start:

; Create a UNIX domain socket and connect to the X11 server.
; @returns The socket file descriptor.
x11_connect_to_server:
static x11_connect_to_server:function
  push rbp
  mov rbp, rsp

  ; Open a Unix socket: socket(2).
  mov rax, SYSCALL_SOCKET
  mov rdi, AF_UNIX ; Unix socket.
  mov rsi, SOCK_STREAM ; Stream oriented.
  mov rdx, 0 ; Automatic protocol.
  syscall

  cmp rax, 0
  jle die

  mov rdi, rax ; Store socket fd in `rdi` for the remainder of the function.

  sub rsp, 112 ; Store struct sockaddr_un on the stack.
  mov WORD [rsp], AF_UNIX ; Set sockaddr_un.sun_family to AF_UNIX

  ; Fill sockaddr_un.sun_path with: "/tmp/.X11-unix/X0".
  lea rsi, sun_path
  mov r12, rdi ; Save the socket file descriptor in `rdi` in `r12`.
  lea rdi, [rsp + 2]
  cld ; Move forward
  mov ecx, 19 ; Length is 19 with the null terminator.
  rep movsb ; Copy.

  ; Connect to the server: connect(2).
  mov rax, SYSCALL_CONNECT
  mov rdi, r12
  lea rsi, [rsp]

  %define SIZEOF_SOCKADDR_UN 2+108
  mov rdx, SIZEOF_SOCKADDR_UN
  syscall

  cmp rax, 0
  jne die

  mov rax, rdi ; Return the socket fd.

  add rsp, 112
  pop rbp
  ret

die:
  mov rax, SYSCALL_EXIT
  mov rdi, 1
  syscall

_start:
global _start:function
  call x11_connect_to_server

  mov rax, SYSCALL_EXIT
  mov rdi, 0
  syscall
