; Create the X11 window.
; @param rdi The socket file descriptor.
; @param esi The new window id.
; @param edx The window root id.
; @param ecx The root visual id.
; @param r8d Packed x and y.
; @param r9d Packed w and h.
create_window:
static create_window:function
push rbp
mov rbp, rsp

%define OP_REQ_CREATE_WINDOW 0x01 ; Op code to create a window
%define FLAG_WIN_BG_COLOR 0x00000002 ; Flag to indicate that we are gonna use bg color
%define X11_EVENT_MASK_BUTTON_PRESS   0x00000004  ; ButtonPressMask
%define X11_EVENT_MASK_BUTTON_RELEASE 0x00000008  ; ButtonReleaseMask
%define X11_EVENT_MASK_EXPOSURE       0x00008000  ; Expose event
%define X11_EVENT_KEY_RELEASE 0x0002 ; We are telling to X11 to send us an event each time a key is released
%define X11_EVENT_KEY_PRESS 0x0001 ; We are telling to X11 to send us an event each time a key is released

%define FLAG_WIN_EVENT 0x00000800   ; This enables event processing for the window

%define CREATE_WINDOW_FLAG_COUNT 2 ; Total number of flag
%define CREATE_WINDOW_PACKET_U32_COUNT (8 + CREATE_WINDOW_FLAG_COUNT) ; Total size of the packet
%define CREATE_WINDOW_BORDER 1                                        ; Define the border width
%define CREATE_WINDOW_GROUP 1                                         ; In x11, windows belong to groups, here we are saying that the window is in the group 1

sub rsp, 12*8

mov DWORD [rsp + 0*4], OP_REQ_CREATE_WINDOW | (CREATE_WINDOW_PACKET_U32_COUNT << 16) ; Open window flag and size of the entire transcript
mov DWORD [rsp + 1*4], esi      ; Window id
mov DWORD [rsp + 2*4], edx      ; Window root id
mov DWORD [rsp + 3*4], r8d      ; x and y packed (first part of the bytes are for x ther for y)
mov DWORD [rsp + 4*4], r9d      ; Width and height packed (first part of the bytes are for w ther for h)
mov DWORD [rsp + 5*4], CREATE_WINDOW_GROUP | (CREATE_WINDOW_BORDER << 16) ; Window design and groups parameters
mov DWORD [rsp + 6*4], ecx                                                ; root visual id
mov DWORD [rsp + 7*4], FLAG_WIN_BG_COLOR | FLAG_WIN_EVENT                 ; Flags
mov DWORD [rsp + 8*4], 0                                                  ; Unused flags
mov DWORD [rsp + 9*4], X11_EVENT_MASK_BUTTON_PRESS | X11_EVENT_MASK_BUTTON_RELEASE | X11_EVENT_MASK_EXPOSURE | X11_EVENT_KEY_RELEASE | X11_EVENT_KEY_PRESS

mov rax, SYSCALL_WRITE
mov rdi, rdi
lea rsi, [rsp]
mov rdx, CREATE_WINDOW_PACKET_U32_COUNT*4
syscall

cmp rax, CREATE_WINDOW_PACKET_U32_COUNT*4
jnz die

add rsp, 12*8

pop rbp
ret
