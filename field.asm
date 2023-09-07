; field.asm

extern printf

section .data
	WRITE		equ	0x01

	HOME_SEQ	db	0x1b, "[H"
	HOME_LEN	equ	$ - HOME_SEQ
	CLSC_SEQ	db	0x1b, "[2J"
	CLSC_LEN	equ	$ - CLSC_SEQ
	MVCR_SEQ	db	0x1b, "[%d;%dH"
	MVCR_LEN	equ	$ - MVCR_SEQ

section .bss
	board		resb 	1024
	MV_CRSR		resb	9
section .text
	global 		clear_screen
	global		draw_field

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
	sub  	r12, 0x04		; Without borders
	mov  	r13, rsi		; Number of columns
	sub  	r13, 0x04		; Without borders

	mov  	rdi, MVCR_SEQ
	mov  	rsi, 0x02
	mov  	rdx, 0x02
	mov  	rax, 0x00
	call 	printf

	mov	rax, board		; String pointer
	mov	byte[rax], 0x2b		; First '+'

	mov	rdi, 0x00		; Counter
fill_top:
	inc	rax			; Move on string
	mov	byte[rax], 0x2d		; Filling it with '-'
	inc	rdi			; Updating counter
	cmp	rdi, r13		; If string filled...
	jnz	fill_top		; ...Moving on

	inc	rax			; Next
	mov	byte[rax], 0x2b		; Putting second '+'
	inc	rax			; And
	mov  	byte[rax], 0x00		; End of line

	mov	rax, WRITE
	mov	rdi, 0x01
	mov	rsi, board
	mov	rdx, r13
	add	rdx, 2
	syscall

	mov  	rsp, rbp
	pop  	rbp
	ret
