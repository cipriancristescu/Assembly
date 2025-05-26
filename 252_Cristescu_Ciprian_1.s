.data
    memory: .space 1048576
    lineBuffer: .space 256  
    operationsCount: .long 0
    file_size: .long 0
    file_descriptor: .long 0
    num_add: .long 0
    formatRead: .asciz "%d\n"
    formatResult: .asciz "%d: ((%d, %d), (%d, %d))\n"
    formatGet: .asciz "((%d, %d), (%d, %d))\n"
    errorMsg: .asciz "%d: ((0, 0), (0, 0))\n"
.text
.global main

main:
    movl $0, %edi
init_memory:
    cmpl $1048576, %edi           
    # 1024*1024 = 1048576
    je read_operations_count
    movb $0, memory(,%edi,1)
    incl %edi
    jmp init_memory

read_operations_count:
    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp
    movl lineBuffer, %eax
    movl %eax, operationsCount

process_operations:
    movl operationsCount, %eax
    cmpl $0, %eax
    je exit_program

    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp

    movl lineBuffer, %eax
    cmpl $1, %eax
    je do_add
    cmpl $2, %eax
    je do_get

    movl operationsCount, %eax
    decl %eax
    movl %eax, operationsCount
    jmp process_operations

#########################ADD#############

do_add:
    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp
    movl lineBuffer, %eax
    movl %eax, num_add

add_files_loop:
    movl num_add, %eax
    cmpl $0, %eax
    je decrement_operations

    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp
    movl lineBuffer, %eax
    movl %eax, file_descriptor

    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp
    movl lineBuffer, %eax
    addl $7, %eax
    shrl $3, %eax
    movl %eax, file_size

    movl $0, %edx
    movl $0, %ecx

find_free_space:
    cmpl $1048576, %edx           # capatul liniei
    je add_fail

    movl %edx, %eax
    andl $1023, %eax  
    cmpl $0, %eax
    jne check_memory_block
    movl $0, %ecx

check_memory_block:
    movb memory(,%edx,1), %al
    cmpb $0, %al
    jne reset_interval

    incl %ecx
    movl file_size, %eax
    cmpl %eax, %ecx
    je allocate_blocks
    incl %edx
    jmp find_free_space

reset_interval:
    movl $0, %ecx
    incl %edx
    jmp find_free_space

allocate_blocks:
    subl %ecx, %edx
    incl %edx
    movl %edx, %ebx
    movl file_size, %ecx

allocate_loop:
    cmpl $0, %ecx
    je allocation_done
    movl file_descriptor, %eax
    movb %al, memory(,%edx,1)
    incl %edx
    decl %ecx
    jmp allocate_loop

allocation_done:
    movl %ebx, %esi
    decl %edx

    movl %edx, %eax
    movl $1024, %ecx
    xorl %edx, %edx
    divl %ecx
    pushl %edx
    pushl %eax

    movl %esi, %eax
    movl $1024, %ecx
    xorl %edx, %edx
    divl %ecx
    pushl %edx
    pushl %eax

    pushl file_descriptor
    pushl $formatResult
    call printf
    addl $20, %esp

    movl num_add, %eax
    decl %eax
    movl %eax, num_add
    jmp add_files_loop

add_fail:
    pushl $0
    pushl $0
    pushl $0
    pushl $0
    pushl file_descriptor
    pushl $errorMsg
    call printf
    addl $20, %esp

    movl num_add, %eax
    decl %eax
    movl %eax, num_add
    jmp add_files_loop

######################GET######

do_get:
    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp
    movl lineBuffer, %ebx

    movl $0, %esi
    movl $-1, %edi
    movl $0, %edx
    movl $0, %ecx

find_descriptor:
    cmpl $1048576, %edx
    je finalize_get

    movb memory(,%edx,1), %al
    cmpb %bl, %al
    jne next_block_get

    cmpl $0, %ecx
    jne update_end
    movl %edx, %esi
    movl $1, %ecx

update_end:
    movl %edx, %edi

next_block_get:
    incl %edx
    jmp find_descriptor

finalize_get:
    cmpl $0, %ecx
    je print_not_found

    movl %edi, %eax
    movl $1024, %ebx
    xorl %edx, %edx
    divl %ebx
    pushl %edx
    pushl %eax

    movl %esi, %eax
    movl $1024, %ebx
    xorl %edx, %edx
    divl %ebx
    pushl %edx
    pushl %eax

    pushl $formatGet
    call printf
    addl $16, %esp
    jmp decrement_operations

print_not_found:
    pushl $0
    pushl $0
    pushl $0
    pushl $0
    pushl $formatGet
    call printf
    addl $20, %esp
    jmp decrement_operations

decrement_operations:
    movl operationsCount, %eax
    decl %eax
    movl %eax, operationsCount
    jmp process_operations

exit_program:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

