    ;;  Sending data to the server
send:
push rbp
mov rbp, rsp

    ;;  Constructing handshake struct
sub rsp, 1<<15                  ; Reserving space for the response
mov BYTE [rsp], 'l'             ; Little endian
mov BYTE [rsp + 2], 11          ; Version, 11 as we are using X11

mov rax, SYSCALL_WRITE          ; Wanna write on the socket
mov rdi, rdi                    ; Placing x11 socket into rdi (it is already in rdi but keep this line here for modularity)
lea rsi, [rsp]                  ; Pointer to the struct
mov rdx, 12                     ; Size of the struct
syscall

cmp rax, 12                     ; Check that all bytes were written
jnz die

    ;;  Now, we wanna read the server response
    ;;   normally it should send first 8 bytes before the bigger message

mov rax, SYSCALL_READ           ; We are gonna read on the socket
mov rdi, rdi                    ; We put the socket in rdi
lea rsi, [rsp]                  ; We are gonna read the response directly on the stack where we reserved the space
mov rdx, 8                      ; We are reading only the first 8 bytes
syscall

cmp rax, 8 ; Check that the server replied with 8 bytes.
jnz die

cmp BYTE [rsp], 1               ; Confirm that the server returned success, the first byte should be 1
jnz die

mov rax, SYSCALL_READ           ; We are gonna read the rest of the message on the socket
mov rdi, rdi                    ; We put the socket in rdi
lea rsi, [rsp]                  ; We are gonna read the response directly on the stack where we reserved the space
mov rdx, 1<<15                  ; We wanna read everything
syscall

cmp rax, 0 ; Check that the server replied with something
jle die

    ;;  We first get the id_base,
    ;;  We are gonna use it as a seed to generate x11 objects
mov edx, DWORD [rsp + 4]
mov DWORD [id_base], edx

    ;; Then comes the mask, it basically helps us modifing id_base without making it invalid
mov edx, DWORD [rsp + 8]
mov DWORD [id_mask], edx

lea rdi, [rsp]                  ; rdi will be a pointer to the response used to skip vendor and formats info

    ;; We wanna skip first the vendor string
    ;; It indicates which kind of x11 server protocol is running behind the
mov cx, WORD [rsp + 16]         ; Vendor length
movzx rcx, cx                   ; Filling rcx with zero so the length is clean

    ;; Then we wanna skip formats, it is some information on how the images datas are formating
    ;; For exemple how to interpret pixels
mov al, BYTE [rsp + 21]         ; There is multiple format, the number of format is now stored in ax
movzx rax, ax                   ; Zero-extends `al` (8-bit) into full `rax`
imul rax, 8                     ; As the size of a single format is 8, we are getting the size of all format like this

add rdi, 32                     ; Skip the connection setup (id_base, id_mask, vendor length etc...)
add rdi, rcx                    ; Skip Vendor string

add rdi, 3                      ; Skip some padding
and rdi, -4                     ; Ensure that we are 4 bits alligned. We basically want rdi to be a multiple of 4, so we are clearing the 2 first bits of rdi to ensure that it is. As we began by skipping 3 padding bits we are sure thats we are on the next 4 bits block.

add rdi, rax                    ; Skip the formats information

    ;; So we wanna extract the root window id. The root window is the orgiginal window, generally the desktop window and is the parent of all the applications's window. When we are gonna create our window we are gonna provide this root id to indicates that we want it to be our parent. It also allows us to keep track of events.
mov eax, DWORD [rdi]            ; Store the window root id, stored on 32 bits. We are returning it through rax.

    ;;  The last thing we wanna do is getting the root_visual_id, basically each window has its own way to display things, and we wanna be aware on how the root window displays its x11 object to generate ours the same way to be compatible.
mov edx, DWORD [rdi + 32]
mov DWORD [root_visual_id], edx

add rsp, 1<<15
pop rbp
ret
