; h.asm

extern printf

section .data
	SLEEP			equ	0x23
	IOCTL			equ	0x10

	TCGETS			equ	0x5401
	TCSETS			equ	0x5402

	STDIN			equ	0x00

	msg2			db	"SG2", 0x0a, 0x00
	msg			db	"Number of pressed btns - ", 0x0a, 0x0a, 0x00
	fd_set			dd	0x00

	divisor1		dq	0x3e7
	divisor2		equ	0x0a

	timer:
		tv_sec		dw	0x00
		tv_nsec		dw	0x00
	timer2:
		t2v_sec		dq	0x00
		t2v_nsec	dq	0x01000000
	remtimer:
		tv_sec_rem	dq	0x00
		tv_nsec_rem	dq	0x00
section .bss
section .text
	global main

main:
	push	rbp
	mov	rbp, rsp

	mov	rax, 0x60
	mov	rdi, timer
	mov	rsi, remtimer
	syscall

	mov	rsp, rbp
	pop	rbp
	ret
