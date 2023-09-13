; snake.asm

extern printf

extern	clear_screen
extern	draw_field
extern	move_cursor

extern	setcanon
extern	setnoncan

extern	check_redirection
extern	check_outside

extern	gen_pos


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

	bias:
		bias_x	dw	0x02
		bias_y	dw	0x00
	pollfd:
		pfd	dd	0x00
		events	dw	0x01
		revents	dw	0x00
	timer:
		t_sec	dq	0x00
		t_nsec	dq	0x04000000
	remtimer:
		rt_sec	dq	0x00
		rt_nsec	dq	0x00

section .bss
	char resb 1
	winsize:
	    ws_row      resw	1
	    ws_col      resw	1
	    ws_xpixel   resw	1
	    ws_ypixel   resw	1

	canon_terminal:
		ciflag	resb	4
		coflag	resb	4
		ccflag	resb	4
		clflag	resb	4
		crest	resb	44

	noncan_terminal:
		niflag	resb	4
		noflag	resb	4
		ncflag	resb	4
		nlflag	resb	4
		nrest	resb	44

	worm:
		worm_x	resw	1
		worm_y	resw	1
	fruit:
		fruit_x	resw	1
		fruit_y	resw	1

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

	xor	rax, rax
	mov	ax, word[worm_x]
	mov	rsi, rax
	mov	ax, word[worm_y]
	mov	rdi, rax
	call	erase_point

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

	mov	rdi, qword[ws_row]
	sub	rdi, 0x06
	mov	rsi, qword[ws_col]
	sub	rsi, 0x06
	mov	rdx, fruit
	call	gen_pos

	add	qword[fruit_y], 0x03
	add	qword[fruit_x], 0x03

	xor	rax, rax
	mov	ax, word[fruit_y]
	mov	rdi, rax
	mov	ax, word[fruit_x]
	mov	rsi, rax
	call	draw_point

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
