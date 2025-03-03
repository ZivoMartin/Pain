    ;; Increment the global_id and returns the new_id
    ;; In this function we wanna get a new id to generate a new item. To process we have 3 global variable. id stands for our local id, each time we are creating an item we are gonna increment it. Then global_id is the id of x11, the things we wanna return should be build on top of it. Then the mask allows us to remain in the boundary of the x11 base id. So to have a new id we just return id_mask & id | id_base and increment id.
next_id:
static x11_next_id:function
push rbp
mov rbp, rsp


    ;;  Loading all the global variables
mov eax, DWORD[id]

mov edi, DWORD[id_base]
mov edx, DWORD[id_mask]

    ;; id_mask & id | id_base
and eax, edx
or eax, edi

add DWORD [id], 1               ; Incrementing local id

pop rbp
ret
