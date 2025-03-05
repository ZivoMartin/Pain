%macro print_char 1

    mov rax, 1
    mov rdi, 1
    mov rsi, _ascii
    mov rbx, %1
    add rsi, rbx
    mov rdx, 1
    syscall

%endmacro


%macro dn 1
    mov rax, %1
    xor r10, r10
    and rax, rax
    jl %%_neg

    %%_local_label_stock_loop:
        inc r10
        xor rdx, rdx
        mov rcx, 10
        idiv rcx
        push rdx
        and rax, rax
        jne %%_local_label_stock_loop

    %%_local_label_display:
        and r10, r10
        je %%_local_label_end_loop_display_number
        pop rbx
        add rbx, 48

        print_char rbx

        dec r10
        jmp %%_local_label_display

    %%_neg:
        neg rax
        push rax
        print_char '-'
        pop rax
        jmp %%_local_label_stock_loop

    %%_local_label_end_loop_display_number:
    mov rax, 1
    mov rdi, 1
    mov rsi, _newline
    mov rdx, 1
    syscall


%endmacro
