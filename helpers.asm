; helpers.asm


section .data
	GETTIME			dq	0x60

	divisor1		dq	0x3e7
	divisor2		dq	0x00

	timeval:
		tv_sec		dw	0x00
		tv_usec		dw	0x00
	timezone:
		tv_minuteswest	dq	0x00
		tz_dsttime	dq	0x00
section .bss
section .text
	global	gen_pos
	global	main

gen_pos:
	push	rbp
	mov	rbp, rsp

	mov	qword[divisor2], rdi		; Count y
	push	rsi				; Save the width
	push	rdx				; And fruit pointer

	mov	rax, GETTIME			; Get the current time
	mov	rdi, timeval
	mov	rsi, timezone
	syscall

	mov	rax, qword[timeval+4]		; Divide with 999

	xor	rdx, rdx
	mov	rdi, divisor1
	idiv	qword[divisor1]

	mov	rax, rdx			; Divide with height
	xor	rdx, rdx
	mov	rdi, divisor2
	idiv	rdi

	pop	rax				; Pop the fruit pointer
	mov	word[rax], dx			; Put the Y to fruit
	pop	rdi				; Pop the width
	push	rax				; Save the fruit pointer

	mov	qword[divisor2], rdi		; We will divide time with width

	mov	rax, 0x60
	mov	rdi, timeval
	mov	rsi, timezone
	syscall

	mov	rax, qword[timeval+4]

	xor	rdx, rdx			; With 999 at first
	mov	rdi, divisor1
	idiv	qword[divisor1]

	mov	rax, rdx			; And with width
	xor	rdx, rdx
	mov	rdi, divisor2
	idiv	rdi

	pop	rax				; Then put the result
	mov	word[rax+2], dx			; To the fruit

	mov	rsp, rbp
	pop	rbp
	ret

main:
	push	rbp
	mov	rbp, rsp

	mov	rax, 0x60			; Get the current time
	mov	rdi, timeval
	mov	rsi, timezone
	syscall

	mov	rsp, rbp
	pop	rbp
