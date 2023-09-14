; field.asm

extern printf

section .data
	WRITE		equ	0x01

	HOME_SEQ	db	0x1b, "[H"
	HOME_LEN	equ	$ - HOME_SEQ
	CLSC_SEQ	db	0x1b, "[2J"
	CLSC_LEN	equ	$ - CLSC_SEQ

	board		db	"--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------", 0x00
	plots		db	"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ", 0x00
	total_label	db	"Total: ", 0x00
	total_len	dq	$ - total_label

section .bss
	MVCR_SEQ	resb	10	; 0x1b, "[%d;%dH", 0x00
	MVCR_LEN	resq	1
	divisor		resq	1
section .text
	global 		clear_screen
	global		draw_field
	global		move_cursor
	global		check_outside

move_cursor:
	push	rbp
	mov	rbp, rsp

	mov	byte[MVCR_SEQ], 0x1b		; <ESC>
	mov	byte[MVCR_SEQ+1], 0x5b		; '['

	push	rsi				; Columns number
	mov	qword[divisor], 0x0a

	xor	rdx, rdx			; Fill the line number
	mov	rax, rdi			; Divide to 10
	idiv	qword[divisor]			; Leftovers to string
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+4], dl

	xor	rdx, rdx
	idiv	qword[divisor]
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+3], dl


	xor	rdx, rdx
	idiv	qword[divisor]
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+2], dl

	mov	byte[MVCR_SEQ+5], 0x3b		; Put the ';'

	xor	rdx, rdx			; Fill the column number
	pop	rax				; Similar scheme
	idiv	qword[divisor]
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+8], dl

	xor	rdx, rdx
	idiv	qword[divisor]
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+7], dl


	xor	rdx, rdx
	idiv	qword[divisor]
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+6], dl

	mov	byte[MVCR_SEQ+9], 0x48		; Put the 'H'
	mov	byte[MVCR_SEQ+10], 0x00		; Put the EOL

	mov	rax, WRITE			; Write
	mov	rdi, 0x01			; move_cursor
	mov	rsi, MVCR_SEQ			; command
	mov	rdx, 0x0a
	syscall

	mov	rsp, rbp
	pop	rbp
	ret

clear_screen:
	push	rbp
	mov 	rbp, rsp

	mov	rax, WRITE
	mov  	rdi, 0x01
	mov  	rsi, HOME_SEQ
	mov  	rdx, HOME_LEN
	syscall

	mov  	rax, WRITE
	mov  	rdi, 0x01
	mov  	rsi, CLSC_SEQ
	mov  	rdx, CLSC_LEN
	syscall

	mov  	rsp, rbp
	pop  	rbp
	ret

draw_field:
	push 	rbp
	mov  	rbp, rsp

	mov  	r12, rdi		; Number of rows
	sub  	r12, 0x02		; Without last border
	mov  	r13, rsi		; Number of columns
	sub  	r13, 0x04		; Without borders

	.crt_tnb:
		mov	rax, board		; String pointer
		mov	byte[rax], 0x2b		; First '+'
		add	rax, r13
		inc	rax
		mov	byte[rax], 0x2b		; Last '+'
		inc	rax
		mov	byte[rax], 0x00

	.crt_mid:
		mov	rax, plots		; String pointer
		mov	byte[rax], 0x7c		; First '|'
		add	rax, r13
		inc	rax
		mov	byte[rax], 0x7c		; Last '|'
		inc	rax
		mov	byte[rax], 0x00

		add	r13, 0x02		; It is with visible borders now

	.strt_drw:
		mov	r14, 0x02

		mov	rdi, r14
		mov	rsi, 0x02
		call	move_cursor

		mov	rax, WRITE
		mov	rdi, 0x01
		mov	rsi, board
		mov	rdx, r13
		syscall

	.drw_mid:
		inc	r14

		mov	rdi, r14
		mov	rsi, 0x02
		call	move_cursor

		mov	rax, WRITE
		mov	rdi, 0x01
		mov	rsi, plots
		mov	rdx, r13
		syscall

		cmp	r14, r12
		jnz	.drw_mid

	.draw_bot:
		inc	r14		; Drawing bottom board
		mov	rdi, r14	; 
		mov	rsi, 0x02
		call	move_cursor

		mov	rax, WRITE
		mov	rdi, 0x01
		mov	rsi, board
		mov	rdx, r13
		syscall

	inc	r14			; Writing 'Total: '
	mov	rdi, r14
	mov	rsi, r13		; Move cursor to
	sub	rsi, 0x14		; the right bottom
	call	move_cursor

	mov	rax, WRITE
	mov	rdi, 0x01
	mov	rsi, total_label
	mov	rdx, [total_len]
	syscall

	mov  	rsp, rbp
	pop  	rbp
	ret

check_outside:
	push	rbp
	mov	rbp, rsp

	cmp	rsi, 0x02
	jg	.ch_out_r

	mov	rax, 0x01
	mov	rsp, rbp
	pop	rbp
	ret

	.ch_out_r:
		xor	rax, rax
		mov	rax, r10
		sub	rax, 0x02
		cmp	rsi, rax
		jle	.ch_out_t

		mov	rax, 0x01
		mov	rsp, rbp
		pop	rbp
		ret

	.ch_out_t:
		cmp	rdi, 0x02
		jg	.ch_out_b

		mov	rax, 0x01
		mov	rsp, rbp
		pop	rbp
		ret

	.ch_out_b:
		mov	rax, rdx
		sub	rax, 0x02
		cmp	rdi, rax
		jle	.ch_out_end

		mov	rax, 0x01
		mov	rsp, rbp
		pop	rbp
		ret

	.ch_out_end:
		mov	rax, 0x00
		mov	rsp, rbp
		pop	rbp
		ret

