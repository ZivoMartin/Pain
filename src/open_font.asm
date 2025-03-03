    ;;  This function open a font on the server side
    ;;  @param rdi The socket fd
    ;;  @param esi The font id
open_font:
static x11_open_font:function

push rbp
mov rbp, rsp

sub rsp, 6*8

%define OPEN_FONT_NAME_LEN 5        ; Len in bit of the font name
%define OPEN_FONT_PADDING ((4 - (OPEN_FONT_NAME_LEN % 4)) % 4) ; Number ofbit to add after the name in the transcript
%define OPEN_FONT_PACKET_LEN (3 + (OPEN_FONT_NAME_LEN + OPEN_FONT_PADDING) / 4); Total transcript len as u32
%define OPEN_FONT_OP_CODE 0x2d                                       ; X11 op code to open a font

mov DWORD [rsp + 0*4], OPEN_FONT_OP_CODE | (OPEN_FONT_NAME_LEN << 16) ; The first byte is storing the op code, the next is storing nothing, and the two last bytes contain the name len
mov DWORD [rsp + 1*4], esi      ; Id of the font we are opening
mov DWORD [rsp + 2*4], OPEN_FONT_NAME_LEN ; Len of the font name, we have to store it twice, x11 standart

    ;; Storing the name of the font
mov BYTE [rsp + 3*4 + 0], 'f'
mov BYTE [rsp + 3*4 + 1], 'i'
mov BYTE [rsp + 3*4 + 2], 'x'
mov BYTE [rsp + 3*4 + 3], 'e'
mov BYTE [rsp + 3*4 + 4], 'd'


    ;; Now, we wanna write it on the socket
mov rax, SYSCALL_WRITE
mov rdi, rdi                    ; The socket
lea rsi, [rsp]                  ; Pointer on the struct
mov rdx, OPEN_FONT_PACKET_LEN*4 ; The len of the entire transcript in byte
syscall

cmp rax, OPEN_FONT_PACKET_LEN*4 ; Check that we wrote everything
jnz die

add rsp, 6*8
pop rbp
ret
