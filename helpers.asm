; helpers.asm

; main = 117


section .data
	GETTIME			equ	0x60

	divisor1		dq	0x3e7

	timeval:
		tv_sec		dq	0x00
		tv_usec		dq	0x00
	timezone:
		tv_minuteswest	dq	0x00
		tz_dsttime	dq	0x00
	pos:
		y		dw	0x00
		x		dw	0x00

	decimal_divisor		dq	0x0a
	msg			db	0x20
section .bss
	divisor2		resq	0x01

	decimal			resb	0x0a

section .text
;	global	main
	global	gen_pos
	global	print_decimal

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

	mov	rax, qword[tv_usec]		; Divide with 999

	xor	rdx, rdx
	idiv	qword[divisor1]

	mov	rax, rdx			; Divide the remainder
	xor	rdx, rdx			; with height
	idiv	qword[divisor2]

	pop	rax				; Pop the fruit pointer
	mov	word[rax+2], dx			; Put the Y to fruit
	pop	rdi				; Pop the width
	push	rax				; Save the fruit pointer

	sar	rdi, 1				; Fruit must be at every 2nd x
	mov	qword[divisor2], rdi		; We will divide time with width

	mov	rax, GETTIME
	mov	rdi, timeval
	mov	rsi, timezone
	syscall

	mov	rax, qword[timeval+4]

	xor	rdx, rdx			; With 999 at first
	mov	rdi, divisor1
	idiv	qword[divisor1]

	mov	rax, rdx			; And with width
	xor	rdx, rdx
	idiv	qword[divisor2]

	sal	rdx, 1				; Fruit must be at every 2nd x
	pop	rax				; Then put the result
	mov	word[rax], dx			; To the fruit

	mov	rsp, rbp
	pop	rbp
	ret

print_decimal:
	push	rbp
	mov	rbp, rsp

	mov	rax, rdi			; Our number
	mov	r10, decimal			; String pointer
	add	r10, 0x09			; To the end of the string
	mov	r9, 0x00
	.division_loop:
		xor	rdx, rdx		; Divide with 10
		idiv	qword[decimal_divisor]

		add	rdx, 0x30		; Make it digit
		mov	byte[r10], dl		; Put to the end of string
		inc	r9
		test	rax, rax		; Have smth to divide
		jz	.print			; If not go print
		dec	r10			; Pointer moves
		jmp	.division_loop		; If we do - go again

	.print:
		mov	rax, 0x01
		mov	rdi, 0x01
		mov	rsi, r10
		mov	rdx, r9
		syscall

	mov	rsp, rbp
	pop	rbp
	ret

;main:
;	push	rbp
;	mov	rbp, rsp
;
;	mov	rdi, 0xa
;	mov	rsi, 0x14
;	mov	rdx, pos
;	call	gen_pos
;
;	xor	rdi, rdi
;	mov	di, word[y]
;	call	print_decimal
;
;	mov	rax, 0x01
;	mov	rdi, 0x01
;	mov	rsi, msg
;	mov	rdx, 0x01
;	syscall
;
;	mov	di, word[x]
;	call	print_decimal
;
;	mov	rsp, rbp
;	pop	rbp
;
