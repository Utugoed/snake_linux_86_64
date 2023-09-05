; snake.asm

extern printf

section .data
	IOCTL  equ 0x10
	TCGETS equ 0x5401
	TCSETS equ 0x5402

	READ equ 0x00
	WRITE equ 0x01
	SELECT equ 0x17

	msg db "Waiting for a button", 0x00
	msg_len equ $-msg-1
	msg2 db 0x0a, "%x", 0x00

	fd_set dd 0x00
	up_code dw 0xe048

section .bss
	char resb 1
	termios:
	    c_iflag     resd 1
	    c_oflag     resd 1
	    c_cflag     resd 1
	    c_lflag     resd 1
	    c_line      resb 1
	    c_cc        resb 19
	timeval:
	    time_t      resq 1
	    suseconds_t resq 1

section .text
	global main
	global save_settings
	global set_settings

save_settings:
	push rbp
	mov rbp, rsp

	mov rax, IOCTL
	mov rdi, 0x00
	mov rsi, TCGETS
	mov rdx, termios
	syscall

	leave
	ret

set_settings:
	push rbp
	mov rbp, rsp

	mov rax, IOCTL
	mov rdi, 0x00
	mov rsi, TCSETS
	mov rdx, termios
	syscall

	leave
	ret

main:
	push rbp
	mov rbp, rsp

	call save_settings
	and byte[c_lflag], 0xfd; Non-canonical terminal
	call set_settings

.select:
	mov byte[time_t],      0x00
	mov byte[suseconds_t+2], 0x08

	mov rax, WRITE      ;Message about waiting button
	mov rdi, 0x01
	mov rsi, msg
	mov rdx, msg_len
	syscall

	mov rax, SELECT     ;Checking buttons were pressed
	mov rdi, 0x01
	mov rsi, fd_set
	mov rdx, 0x00
	mov r10, 0x00
	mov r8,  timeval
	syscall

	cmp rax, 0x00       ;If not pressed go again
	jne .getkey
	jmp .select

.getkey:
	mov rax, READ
	mov edi, 0x00
	mov rsi, char
	mov rdx, 0x01
	syscall

	mov rax, WRITE      ;Source Index is already filled
	mov rdi, 0x01       ;Just print pressed button
	mov rdx, 0x01
	syscall

	cmp byte[char], 13
	jz .end
	jmp .select

.end:

	leave
	ret

