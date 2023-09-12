; snake.asm

extern printf

extern	clear_screen
extern	draw_field
extern	move_cursor

extern	setcanon
extern	setnoncan


section .data
	IOCTL     	equ  0x10
	TIOCGWS   	equ  0x5413

	READ      	equ  0x00
	WRITE     	equ  0x01
	POLL    	equ  0x07

	MVCR_SEQ  	db   0x1b, "[%d;%dH"
	MVCR_LEN  	equ  $ - MVCR_SEQ

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

check_redirection:
	push	rbp
	mov	rbp, rsp

	cmp	byte[char], 0x77		; 'w'
	jne	.ch_red_a
	mov	word[bias_y], 0xffff
	mov	word[bias_x], 0x00

	.ch_red_a:
		cmp	byte[char], 0x61	; 'a'
		jne	.ch_red_s
		mov	word[bias_y], 0x00
		mov	word[bias_x], 0xfffe

	.ch_red_s:
		cmp	byte[char], 0x73	; 's'
		jne	.ch_red_d
		mov	word[bias_y], 0x01
		mov	word[bias_x], 0x00

	.ch_red_d:
		cmp	byte[char], 0x64	; 'd'
		jne	.ch_red_end
		mov	word[bias_y], 0x00
		mov	word[bias_x], 0x02

	.ch_red_end:
		mov	rsp, rbp
		pop	rbp
		ret

check_outside:
	push	rbp
	mov	rbp, rsp

	cmp	word[worm_x], 0x02
	mov	rax, 0x01
	mov	rsp, rbp
	pop	rbp
	ret

	.ch_put_r:
		xor	rdi, rdi
		mov	
		cmp	word[worm_x], 
		mov	rax, 0x01
		mov	rsp, rbp
		pop	rbp
		ret

	.ch_out_t:
		cmp	word[worm_x], 0x02
		mov	rax, 0x01
		mov	rsp, rbp
		pop	rbp
		ret

	.ch_out_b:
		cmp	word[worm_x], 0x02
		mov	rax, 0x01
		mov	rsp, rbp
		pop	rbp
		ret

	mov	rax, 0x00
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

.select:
	xor	rdi, rdi		; Move cursor
	mov	di, word[ws_row]	; To the place
	mov	rsi, 0x01		; For input
	call	move_cursor

	mov 	rax, POLL		;Checking buttons were pressed
	mov 	rdi, pfd
	mov 	rsi, 0x01
	mov 	rdx, 0x0100
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

	call	check_redirection
	cmp 	byte[char], 0x0a	; '\n'
	jz	.end

.move_worm:
	call	move_point
	jmp	.select

.end:
	mov	rdi, canon_terminal
	call	setcanon

	mov	rsp, rbp
	pop	rbp
	ret
