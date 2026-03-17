section .data
    filename db "num",0
    msg db "Hello, warld!",10
    len equ 14

section .bss
    buf resb 16

section .text
    global _start

_start:
    mov rax, 2
    mov rdi, filename
    xor rsi, rsi
    syscall

    mov r12, rax

    mov rax, 0
    mov rdi, r12
    mov rsi, buf
    mov rdx, 16
    syscall

    ; ASCII => integer
    ; work only with 0-9
    ; https://stackoverflow.com/questions/19309749/nasm-assembly-convert-input-to-integer
    movzx rax, byte [buf]
    sub rax, '0'

    ; rax = num
    mov rdi, 1
    mov rsi, msg
    mov rdx, len
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall