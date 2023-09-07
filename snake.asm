; snake.asm

extern printf

extern clear_screen
extern draw_field

section .data
	IOCTL     equ  0x10
	TIOCGWS   equ  0x5413

	READ      equ  0x00
	WRITE     equ  0x01
	SELECT    equ  0x17

	MVCR_SEQ  db   0x1b, "[%d;%dH"
	MVCR_LEN  equ  $ - MVCR_SEQ

	msg       db   "Waiting for a button", 0x0a, 0x00
	msg_len   equ  $-msg-1
	msg2      db   0x0a, "%x", 0x00
	msgd      db   "%d", 0x00

	fd_set    dd   0x00
	up_code   dw   0xe048

section .bss
	char resb 1
	timeval:
	    time_t      resq 1
	    suseconds_t resq 1
	winsize:
	    ws_row      resw 1
	    ws_col      resw 1
	    ws_xpixel   resw 1
	    ws_ypixel   resw 1

section .text
	global main
	global get_winsize

get_winsize:
	push rbp
	mov rbp, rsp

	mov rax, IOCTL
	mov rdi, 0x00
	mov rsi, TIOCGWS
	mov rdx, winsize
	syscall

	leave
	ret

main:
	push rbp
	mov rbp, rsp

	call clear_screen
	call get_winsize

	xor rdi, rdi
	xor rsi, rsi
	mov di, [winsize]
	mov si, [winsize + 2]
	call draw_field

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

