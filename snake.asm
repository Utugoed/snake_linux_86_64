; snake.asm

; main - 215
; draw_fruit - 243
; move_point - 135
; move_worm - 284

extern printf

extern	clear_screen
extern	draw_field
extern	move_cursor

extern	setcanon
extern	setnoncan

extern	check_redirection
extern	check_outside

extern	gen_pos
extern	print_decimal


section .data
	IOCTL     	equ	0x10
	TIOCGWS   	equ	0x5413

	READ      	equ	0x00
	WRITE     	equ	0x01
	POLL    	equ	0x07
	NANOSLEEP	equ	0x23

	MVCR_SEQ  	db	0x1b, "[%d;%dH"
	MVCR_LEN  	equ	$ - MVCR_SEQ

	fd_set   	dd	0x00
	up_code   	dw	0xe048

	wrmpnt		db	0x2a
	emptpnt		db	0x20

	score		dq	0x00
	nbf		db	0x00
	bias:
		bias_x	dw	0x02
		bias_y	dw	0x00
	pollfd:
		pfd	dd	0x00
		events	dw	0x01
		revents	dw	0x00
	timer:
		t_sec	dq	0x00
		t_nsec	dq	0x06000000
	remtimer:
		rt_sec	dq	0x00
		rt_nsec	dq	0x00

section .bss
	char resb 1
	winsize:
	    ws_row      resw	0x01
	    ws_col      resw	0x01
	    ws_xpixel   resw	0x01
	    ws_ypixel   resw	0x01

	canon_terminal:
		ciflag	resb	0x04
		coflag	resb	0x04
		ccflag	resb	0x04
		clflag	resb	0x04
		crest	resb	0x2c
	noncan_terminal:
		niflag	resb	0x04
		noflag	resb	0x04
		ncflag	resb	0x04
		nlflag	resb	0x04
		nrest	resb	0x2c

	worm:
		worm_x	resw	0x01
		worm_y	resw	0x01
		tail	resd	0xff
	fruit:
		fruit_x	resw	0x01
		fruit_y	resw	0x01

section .text
	global main

get_winsize:
	push 	rbp
	mov 	rbp, rsp

	mov 	rax, IOCTL
	mov 	rdi, 0x00
	mov 	rsi, TIOCGWS
	mov 	rdx, winsize
	syscall

	leave
	ret

draw_point:
	push	rbp
	mov	rbp, rsp

	call	move_cursor

	mov	rax, WRITE
	mov	rdi, 0x01
	mov	rsi, wrmpnt
	mov	rdx, 0x01
	syscall

	mov	rsp, rbp
	pop	rbp
	ret

erase_point:
	push	rbp
	mov	rbp, rsp

	call	move_cursor

	mov	rax, WRITE
	mov	rdi, 0x01
	mov	rsi, emptpnt
	mov	rdx, 0x01
	syscall

	mov	rsp, rbp
	pop	rbp
	ret

move_point:
	push	rbp
	mov	rbp, rsp

	mov	rcx, worm
	mov	rax, qword[score]	; Score number is equivalent
	sal	rax, 2			; To the number of additional snake blocks
	add	rcx, rax		; Pointer to the snakes last element

	xor	r13, r13
	mov	r13w, word[fruit_y]

	xor	rax, rax			; Erasing the last element
	mov	ax, word[rcx]
	mov	rsi, rax
	mov	ax, word[rcx+2]
	mov	rdi, rax
	call	erase_point

	mov	r13w, word[fruit_y]

	mov	rcx, worm
	mov	rax, qword[score]		; Score number is equivalent
	sal	rax, 2				; To the number of additional snake blocks
	add	rcx, rax			; Pointer to the snakes last element
	mov	rax, qword[score]		; Additional blocks number
	xor	rdx, rdx

	mov	r13w, word[fruit_y]

	.move_the_que:
		test	rax, rax		; If no more
		jz	.move_first_el		; Go move first block
		mov	rbx, rcx		; Current block coors addr
		sub	rbx, 0x04		; Previous block coors addr
		mov	edx, dword[rbx]		; Put the value of previous block
		mov	dword[rcx], edx		; to the current block
		mov	rcx, rbx		; New current block is a previous
		dec	rax
		jmp	.move_the_que

	mov	r13w, word[fruit_y]

	.move_first_el:
		xor	rax, rax
		mov	ax, word[bias_x]
		add	word[worm_x], ax
		mov	ax, word[bias_y]
		add	word[worm_y], ax

		xor	rax, rax		; Draw point
		mov	ax, word[worm_y]	; With coordinates
		mov	rdi, rax
		mov	ax, word[worm_x]
		mov	rsi, rax
		call	draw_point

	mov	r13w, word[fruit_y]

		cmp	byte[nbf], 0x01
		jnz	.end_moving

		mov	byte[nbf], 0x00
		mov	rax, worm		; Worm start
		mov	rbx, qword[score]	; Worm length
		sal	rbx, 2			; 4byte for a block
		add	rax, rbx		; Worm's tail pointer
		mov	ebx, dword[rax]		; Tails coors

		xor	rsi, rsi		; Draw tail
		mov	si, bx			; There is an X in bx
		sar	ebx, 16			; Replacing bx with Y
		xor	rdi, rdi
		mov	di, bx
		call	draw_point

	.end_moving:
		mov	rsp, rbp
		pop	rbp
		ret

main:
	push 	rbp
	mov 	rbp, rsp

	mov	rdi, canon_terminal
	mov	rsi, noncan_terminal
	call	setnoncan

	call 	clear_screen
	call 	get_winsize

	xor 	rdi, rdi
	xor 	rsi, rsi
	mov 	di, word[ws_row]
	mov 	si, word[ws_col]
	call 	draw_field

	mov	word[worm_y], 0x03	; Start point
	mov	word[worm_x], 0x03

	xor	rax, rax		; Draw point
	mov	ax, word[worm_y]	; With coordinates
	mov	rdi, rax
	mov	ax, word[worm_x]
	mov	rsi, rax
	call	draw_point

	.draw_fruit:
		xor	rdi, rdi
		mov	di, word[ws_row]
		sub	rdi, 0x06		; Without top and bott borders
		xor	rsi, rsi
		mov	si, word[ws_col]
		sub	rsi, 0x06		; Without left and right
		mov	rdx, fruit
		call	gen_pos

		add	word[fruit_y], 0x03
		add	word[fruit_x], 0x03

		xor	rax, rax
		mov	ax, word[fruit_y]
		mov	rdi, rax
		mov	ax, word[fruit_x]
		mov	rsi, rax
		call	draw_point

	.write_score:
		xor 	rdi, rdi
		xor 	rsi, rsi
		mov 	di, word[ws_row]
		mov 	si, word[ws_col]
		sub	rsi, 0x0d
		call	move_cursor

		mov	rdi, [score]
		call	print_decimal

	.select:
		xor	rdi, rdi		; Move cursor
		mov	di, word[ws_row]	; To the place
		mov	rsi, 0x01		; For input
		call	move_cursor

		mov	rax, NANOSLEEP
		mov	rdi, timer
		mov	rsi, remtimer
		syscall

		mov 	rax, POLL		;Checking buttons were pressed
		mov 	rdi, pfd
		mov 	rsi, 0x01
		mov 	rdx, 0x00
		syscall

		test 	rax, rax		;If not pressed go again
		jz 	.move_worm

	.getkey:
		mov 	rax, READ
		mov 	edi, 0x00
		mov 	rsi, char
		mov 	rdx, 0x01
		syscall

		mov 	rax, WRITE		;Source Index is already filled
		mov 	rdi, 0x01		;Just print pressed button
		mov	rdx, 0x01
		syscall

		mov	rdi, char
		mov	rsi, bias_y
		mov	rdx, bias_x
		call	check_redirection

		cmp 	byte[char], 0x0a	; '\n'
		jz	.end

	.move_worm:
		call	move_point

		xor	rdi, rdi
		xor	rsi, rsi

		mov	di, word[worm_y]		; If fruit Y
		mov	si, word[fruit_y]		; Is equivalent
		cmp	rdi, rsi			; To worm Y
		jnz	.loop_end

		mov	di, word[worm_x]		; And fruit X
		mov	si, word[fruit_x]		; Is equivalent
		cmp	rdi, rsi			; To worm Y
		jnz	.loop_end

		mov	rax, [score]			; Total score
		inc	rax				; Is increasing
		mov	[score], rax
							; And worm receives a new block
		mov	rbx, worm			; Pointer to the worms
		sal	rax, 2
		add	rbx, rax			; tail
		xor	rax, rax
		mov	eax, dword[winsize]
		mov	dword[rbx], eax
		mov	byte[nbf], 0x01			; New block flag
		jmp	.draw_fruit

	.loop_end:
		xor	rdi, rdi
		mov	di, word[worm_y]
		xor	rsi, rsi
		mov	si, word[worm_x]
		xor	rdx, rdx
		mov	dx, word[ws_row]
		xor	r10, r10
		mov	r10w, word[ws_col]
		call	check_outside

		cmp	rax, 0x01
		jz	.end
		jmp	.select

	.end:
		mov	rdi, canon_terminal
		call	setcanon

	mov	rsp, rbp
	pop	rbp
	ret
