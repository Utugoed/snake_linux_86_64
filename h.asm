; h.asm

extern printf

section .data
	SLEEP			equ	0x23
	IOCTL			equ	0x20

	ICANON			equ	0x02
	ECHO			equ	0x08
	TCGETS			equ	0x5401
	TCSETS			equ	0x5402

	STDIN			equ	0x00

	msg2			db	"SG2", 0x0a, 0x00
	msg			db	"Number of pressed btns - ", 0x0a, 0x0a, 0x00
	fd_set			dd	0x00
	timer:
		tv_sec		dq	0x01
		tv_nsec		dq	0x00
	remtimer:
		tv_sec_rem	dq	0x00
		tv_nsec_rem	dq	0x00
	pollfd:
		fd		dd	0
		events		dw	1
		revents		dw	0

section .bss
	content			resb	4
	char			resb	1
	sigaction:
		sa_handler	resq	1
		sa_sigaction	resq	1
		sa_mask		resq	1
		sa_flags	resq	1
		sa_restorer	resq	1

	canon_terminal:
		stty		resb	12
		slflag		resb	4
		srest		resb	44
	noncan_terminal:
		tty		resb	12
		lflag		resb	4
		nrest		resb	44
section .text
	global main
	global	setcanon
	global	setnoncan

setnoncan:
	push	rbp
	mov	rbp, rsp

	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCGETS
	mov	rdx, canon_terminal
	syscall

	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCGETS
	mov	rdx, noncan_terminal
	syscall

	and	dword[lflag], (~ICANON)
	and	dword[lflag], (~ECHO)

	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCSETS
	mov	rdx, noncan_terminal
	syscall

	mov	rsp, rbp
	pop	rbp

setcanon:
	push	rbp
	mov	rbp, rsp

	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCSETS
	mov	rdx, canon_terminal
	syscall

	mov	rsp, rbp
	pop	rbp

main:
	push	rbp
	mov	rbp, rsp

	call	setnoncan

.snd_msg:
	mov	dword[tv_sec], 0x00
	mov	dword[tv_nsec], 0x080000

	mov	rax, 0x07
	mov	rdi, pollfd
	mov	rsi, 0x01
	mov	rdx, 0x00
	syscall

	test	rax, rax
	jz	.end

;	mov	rax, 0x00
;	mov	rdi, 0x00
;	mov	rsi, char
;	mov	rdx, 0x01
;	syscall

	add	ah, 0x30

.print:
	mov	byte[msg+25], al
	mov	rax, 0x01
	mov	rdi, 0x01
	mov	rsi, msg
	mov	rdx, 26
	syscall

	jmp	.snd_msg
.end:

	mov	rsp, rbp
	pop	rbp
	ret
