; h.asm

extern printf

section .data
	SLEEP			equ	0x23
	IOCTL			equ	0x10

	IGNBRK 			equ	0x1
	BRKINT			equ	0x2
	PARMRK			equ	0x8
	ISTRIP			equ	0x20
	INLCR			equ	0x40
	IGNCR			equ	0x80
	ICRNL			equ	0x100
	IXON			equ	0x400

	OPOST			equ	0x1
	ECHO			equ	0x8
	ECHONL			equ	0x40
	ICANON			equ	0x2
	ISIG			equ	0x1
	IEXTEN			equ	0x8000
	CSIZE			equ	0x30
	PARENB			equ	0x100
	CS8			equ	0x30


	TCGETS			equ	0x5401
	TCSETS			equ	0x5402

	STDIN			equ	0x00

	msg2			db	"SG2", 0x0a, 0x00
	msg			db	"Number of pressed btns - ", 0x0a, 0x0a, 0x00
	fd_set			dd	0x00
	timer:
		tv_sec		dq	0x01
		tv_nsec		dq	0x00
	remtimer:
		tv_sec_rem	dq	0x00
		tv_nsec_rem	dq	0x00
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
	global main
	global	setcanon
	global	setnoncan

setnoncan:
	push	rbp
	mov	rbp, rsp

	push	rsi

	mov	rdx, rdi
	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCGETS
	syscall

	pop	rdx
	push	rdx
	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCGETS
	syscall

	pop	rdx
	and	dword[rdx+3], (~ECHO)
	and	dword[rdx+3], (~ICANON)

	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCSETS
	mov	rdx, noncan_terminal
	syscall

	mov	rsp, rbp
	pop	rbp
	ret

;	and	dword[iflag], (~IGNBRK)
;	and	dword[iflag], (~BRKINT)
;	and	dword[iflag], (~PARMRK)
;	and	dword[iflag], (~ISTRIP)
;	and	dword[iflag], (~INLCR)
;	and	dword[iflag], (~IGNCR)
;	and	dword[iflag], (~ICRNL)
;	and	dword[iflag], (~IXON)

;	and	dword[oflag], (~OPOST)

;	and	dword[lflag], (~ECHONL)
;	and	dword[lflag], (~ISIG)
;	and	dword[lflag], (~IEXTEN)

;	and	dword[cflag], (~CSIZE)
;	and	dword[cflag], (~PARENB)
;	or	dword[cflag], (CS8)


setcanon:
	push	rbp
	mov	rbp, rsp

	mov	rdx, rdi
	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCSETS
	syscall

	mov	rsp, rbp
	pop	rbp
	ret

main:
	push	rbp
	mov	rbp, rsp

	call	setcanon

	mov	rsp, rbp
	pop	rbp
	ret
