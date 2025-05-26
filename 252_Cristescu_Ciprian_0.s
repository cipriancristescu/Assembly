.data
    memory: .space 1024
    lineBuffer: .space 256
    operationsCount: .long 0
    formatRead: .asciz "%d\n"
    formatAdd: .asciz "%d: (%d, %d)\n"
    formatGet: .asciz "(%d, %d)\n"
#    formatDelete: .asciz "DELETE: Success\n"
#   formatDefrag: .asciz "DEFRAGMENT: Done\n"
    formatBlock: .asciz "%d: (%d, %d)\n"
#    errorMsg: .asciz "Error: Operation failed or no space available!\n"

.text
.global main

main:
    movl $0, %edi
init_memory:
    cmpl $1024, %edi
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
    cmpl $3, %eax
    je do_delete
    cmpl $4, %eax
    je do_defragmentation

    movl operationsCount, %eax
    decl %eax
    movl %eax, operationsCount
    jmp process_operations
    
###################ADD################
do_add:
    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp
    movl lineBuffer, %esi

add_files_loop:
    cmpl $0, %esi
    je decrement_operations

    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp
    movl lineBuffer, %ebx

    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp
    movl lineBuffer, %edi
    addl $7, %edi
    shrl $3, %edi

    movl $0, %edx
    movl $0, %ecx

find_free_space:
    cmpl $1024, %edx
    je add_fail
    movb memory(,%edx,1), %al
    cmpb $0, %al
    jne reset_interval

    incl %ecx
    cmpl %edi, %ecx
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
    movl %edx, %ebp
    movl %edi, %ecx

allocate_loop:
    cmpl $0, %ecx
    je add_success
    movb %bl, memory(,%ebp,1)
    incl %ebp
    decl %ecx
    jmp allocate_loop

add_success:
    movl %ebp, %eax
    decl %eax
    pushl %eax
    movl %edx, %eax
    pushl %eax
    pushl %ebx
    pushl $formatAdd
    call printf
    addl $16, %esp
    decl %esi
    jmp add_files_loop

add_fail:
    pushl $0
    pushl $0
    pushl %ebx
    pushl $formatAdd
    call printf
    addl $16, %esp
    decl %esi
    jmp add_files_loop

decrement_operations:
    movl operationsCount, %eax
    decl %eax
    movl %eax, operationsCount
    jmp process_operations
    
########################GET###################

do_get:
    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp
    movl lineBuffer, %ebx

    movl $-1, %esi
    movl $-1, %edi
    movl $0, %edx

find_file:
    cmpl $1024, %edx
    je print_get_result
    movb memory(,%edx,1), %al
    cmpb %bl, %al
    jne next_block_get
    cmpl $-1, %esi
    jne update_end_get
    movl %edx, %esi

update_end_get:
    movl %edx, %edi
next_block_get:
    incl %edx
    jmp find_file

print_get_result:
    cmpl $-1, %esi
    je get_not_found
    pushl %edi
    pushl %esi
    pushl $formatGet
    call printf
    addl $12, %esp
    jmp decrement_operations

get_not_found:
    pushl $0
    pushl $0
    pushl $formatGet
    call printf
    addl $12, %esp
    jmp decrement_operations
 
#####################DELETE#################

do_delete:
    leal lineBuffer, %eax
    pushl %eax
    pushl $formatRead
    call scanf
    addl $8, %esp
    movl lineBuffer, %ebx

    movl $0, %edx

find_file_delete:
    cmpl $1024, %edx
    je delete_done
    movb memory(,%edx,1), %al
    cmpb %bl, %al
    jne next_block_delete
    movb $0, memory(,%edx,1)
next_block_delete:
    incl %edx
    jmp find_file_delete

delete_done:
    call display_memory
    jmp decrement_operations

#####################DEFRAGMENTATION###################

do_defragmentation:
    movl $0, %esi
    movl $0, %edi

defrag_loop:
    cmpl $1024, %esi
    je clear_remaining
    movb memory(,%esi,1), %al
    cmpb $0, %al
    je skip_defrag
    movb %al, memory(,%edi,1)
    incl %edi
skip_defrag:
    incl %esi
    jmp defrag_loop

clear_remaining:
    cmpl $1024, %edi
    je defrag_done
    movb $0, memory(,%edi,1)
    incl %edi
    jmp clear_remaining

defrag_done:
    call display_memory
    jmp decrement_operations

#########afisare memory
display_memory:
    movl $0, %edi

display_loop:
    cmpl $1024, %edi
    je display_end

    movb memory(,%edi,1), %al
    cmpb $0, %al
    je skip_block

    movl %edi, %esi
check_block:
    movb memory(,%edi,1), %bl
    cmpb %al, %bl
    jne print_block
    incl %edi
    cmpl $1024, %edi
    je print_block
    jmp check_block

print_block:
    movl %edi, %ebx
    decl %ebx
    pushl %ebx
    pushl %esi
    movzbl %al, %eax
    pushl %eax
    pushl $formatBlock
    call printf
    addl $16, %esp
    jmp display_loop

skip_block:
    incl %edi
    jmp display_loop

display_end:
    ret

exit_program:
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

