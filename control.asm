; h.asm

extern printf

section .data
	SLEEP			equ	0x23
	IOCTL			equ	0x10

	ECHO			equ	0x8
	ICANON			equ	0x2

	TCGETS			equ	0x5401
	TCSETS			equ	0x5402

	STDIN			equ	0x00

	fd_set			dd	0x00

	pollfd:
		fd		dd	0x00
		events		dw	0x01
		revents		dw	0x00

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
		ciflag		resb	4
		coflag		resb	4
		ccflag		resb	4
		slflag		resb	4
		srest		resb	44
	noncan_terminal:
		iflag		resb	4
		oflag		resb	4
		cflag		resb	4
		lflag		resb	4
		nrest		resb	44
section .text
	global	setcanon
	global	setnoncan
	global	check_redirection

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

	and	dword[lflag], (~ECHO)
	and	dword[lflag], (~ICANON)

	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCSETS
	mov	rdx, noncan_terminal
	syscall

	mov	rsp, rbp
	pop	rbp
	ret

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
	ret

check_redirection:
	push	rbp
	mov	rbp, rsp

	cmp	byte[rdi], 0x77			; 'w'
	jne	.ch_red_a

	cmp	word[rsi], 0x01
	jz	.ch_red_end
	mov	word[rsi], 0xffff
	mov	word[rdx], 0x00

	.ch_red_a:
		cmp	byte[rdi], 0x61	; 	'a'
		jne	.ch_red_s

		cmp	word[rdx], 0x02
		jz	.ch_red_end
		mov	word[rsi], 0x00
		mov	word[rdx], 0xfffe

	.ch_red_s:
		cmp	byte[rdi], 0x73	;	's'
		jne	.ch_red_d

		cmp	word[rsi], 0xffff
		jz	.ch_red_end
		mov	word[rsi], 0x01
		mov	word[rdx], 0x00

	.ch_red_d:
		cmp	byte[rdi], 0x64	; 	'd'
		jne	.ch_red_end

		cmp	word[rdx], 0xfffe
		jz	.ch_red_end
		mov	word[rsi], 0x00
		mov	word[rdx], 0x02

	.ch_red_end:
		mov	rsp, rbp
		pop	rbp
		ret

