; h.asm

extern printf

section .data
	SLEEP			equ	0x23

	msg2			db	"SG2", 0x0a, 0x00
	msg			db	"Number of pressed btns - ", 0x00, 0x00
	fd_set			dd	0x00
	timer:
		tv_sec		dq	0x01
		tv_nsec		dq	0x00
	remtimer:
		tv_sec_rem	dq	0x00
		tv_nsec_rem	dq	0x00

section .bss
	content			resb	4
	char			resb	1
	sigaction:
		sa_handler	resq	1
		sa_sigaction	resq	1
		sa_mask		resq	1
		sa_flags	resq	1
		sa_restorer	resq	1

section .text
	global main

main:
	push	rbp
	mov	rbp, rsp

.snd_msg:
	mov	dword[tv_sec], 0x00
	mov	dword[tv_nsec], 0x080000

	mov	rax, 0x17
	mov	rdi, 0x01
	mov	rsi, fd_set
	mov	rdx, 0x00
	mov	r10, 0x00
	mov	r8,  timer
	syscall

	cmp	rax, 0x00
	je	.print

	mov	rax, 0x00
	mov	rdi, 0x00
	mov	rsi, char
	mov	rdx, 0x01
	syscall

.print:
	mov	byte[msg+25], al
	mov	rax, 0x01
	mov	rdi, 0x01
	mov	rsi, msg
	mov	rdx, 26
	syscall

	jmp	.snd_msg

	mov	rsp, rbp
	pop	rbp
	ret
