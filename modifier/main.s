	.file	"main.c"
	.intel_syntax noprefix



	.text
	.globl	count_words
	.type	count_words, @function
count_words:
	push	rbp
	mov	rbp, rsp
	push	r13						# i
	push	r12						# result
	sub	rsp, 16
	mov	QWORD PTR [rbp-24], rdi		# str
	mov	DWORD PTR [rbp-28], esi		# size
	mov	r12d, 0
	mov	r13d, 0
	jmp	.L2
.L4:
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	mov	edx, r13d
	movsx	rdx, edx
	add	rdx, 1
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 8192
	test	eax, eax
	je	.L3
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	mov	edx, r13d
	movsx	rdx, edx
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 8192
	test	eax, eax
	jne	.L3
	mov	eax, r12d
	add	eax, 1
	mov	r12d, eax
.L3:
	mov	eax, r13d
	add	eax, 1
	mov	r13d, eax
.L2:
	mov	eax, r13d
	add	eax, 1
	cmp	eax, DWORD PTR [rbp-28]
	jl	.L4
	cmp	DWORD PTR [rbp-28], 0
	je	.L5
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	mov	edx, DWORD PTR [rbp-28]
	movsx	rdx, edx
	sal	rdx, 2
	lea	rcx, [rdx-4]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 8192
	test	eax, eax
	jne	.L5
	mov	eax, r12d
	add	eax, 1
	mov	r12d, eax
.L5:
	mov	eax, r12d				# return result;
	add	rsp, 16
	pop	r12
	pop	r13
	pop	rbp
	ret



	.size	count_words, .-count_words
	.globl	put_words
	.type	put_words, @function
put_words:
	push	rbp
	mov	rbp, rsp
	push	r15					# i
	push	r14					# j
	sub	rsp, 32
	mov	QWORD PTR [rbp-24], rdi	# str
	mov	DWORD PTR [rbp-28], esi	# size
	mov	QWORD PTR [rbp-40], rdx # words_start
	cmp	DWORD PTR [rbp-28], 0	# size == 0
	je	.L14
	mov	r14d, 0
	call	__ctype_b_loc
	mov	rdx, QWORD PTR [rax]
	mov	rax, QWORD PTR [rbp-24]
	mov	eax, DWORD PTR [rax]
	cdqe
	add	rax, rax
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 8192
	test	eax, eax
	jne	.L10
	mov	eax, r14d
	lea	edx, [rax+1]
	mov	r14d, edx
	cdqe
	lea	rdx, [0+rax*8]
	mov	rax, QWORD PTR [rbp-40]
	add	rdx, rax
	mov	rax, QWORD PTR [rbp-24]
	mov	QWORD PTR [rdx], rax
.L10:
	mov	r15d, 1
	jmp	.L11
.L13:
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	mov	edx, r15d
	movsx	rdx, edx
	sal	rdx, 2
	lea	rcx, [rdx-4]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 8192
	test	eax, eax
	je	.L12
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	mov	edx, r15d
	movsx	rdx, edx
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 8192
	test	eax, eax
	jne	.L12
	mov	eax, r14d
	lea	edx, [rax+1]
	mov	r14d, edx
	cdqe
	lea	rdx, [0+rax*8]
	mov	rax, QWORD PTR [rbp-40]
	add	rax, rdx
	mov	edx, r15d
	movsx	rdx, edx
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	QWORD PTR [rax], rdx
.L12:
	mov	eax, r15d
	add	eax, 1
	mov	r15d, eax
.L11:
	mov	eax, r15d
	cmp	eax, DWORD PTR [rbp-28]
	jl	.L13
	jmp	.L7
.L14:
	nop
.L7:
	add	rsp, 32
	pop	r14
	pop	r15
	pop	rbp
	ret



	.size	put_words, .-put_words
	.globl	reverse_words
	.type	reverse_words, @function
reverse_words:
	push	rbp
	mov	rbp, rsp
	push	r15					# j
	push	r14					# tmp
	push	r13					# words
	push	r12					# cnt	
	push	rbx
	sub	rsp, 24
	mov	QWORD PTR [rbp-56], rdi	# str
	mov	DWORD PTR [rbp-60], esi	# size
	# count_words(str, size) 
	call	count_words
	mov	r12d, eax				# cnt
	# r13 := malloc(cnt * sizeof(int*))
	cdqe
	sal	rax, 3
	mov	rdi, rax
	call	malloc
	mov	r13, rax				# words
	# put_words(str, size, words);
	mov	rdx, r13
	mov	ecx, DWORD PTR [rbp-60]
	mov	rax, QWORD PTR [rbp-56]
	mov	esi, ecx
	mov	rdi, rax
	call	put_words
	# r14 := malloc(size * sizeof(int))
	mov	eax, DWORD PTR [rbp-60]
	cdqe
	sal	rax, 2
	mov	rdi, rax
	call	malloc
	mov	r14, rax				# tmp
	mov	r15d, 0					# j
	mov	ebx, 0					# i
	jmp	.L16
.L22:
	test	ebx, ebx
	je	.L17
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	movsx	rdx, ebx
	sal	rdx, 2
	lea	rcx, [rdx-4]
	mov	rdx, QWORD PTR [rbp-56]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 8192
	test	eax, eax
	je	.L18
.L17:
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	movsx	rdx, ebx
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-56]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 8192
	test	eax, eax
	jne	.L18
	mov	eax, r12d
	sub	eax, 1
	mov	r12d, eax
	jmp	.L19
.L20:
	mov	rcx, r14
	mov	eax, r15d
	lea	edx, [rax+1]
	mov	r15d, edx
	cdqe
	sal	rax, 2
	lea	rsi, [rcx+rax]
	mov	rdx, r13
	mov	eax, r12d
	cdqe
	sal	rax, 3
	add	rdx, rax
	mov	rax, QWORD PTR [rdx]
	lea	rcx, [rax+4]
	mov	QWORD PTR [rdx], rcx
	mov	eax, DWORD PTR [rax]
	mov	DWORD PTR [rsi], eax
.L19:
	call	__ctype_b_loc
	mov	rdx, QWORD PTR [rax]
	mov	rcx, r13
	mov	eax, r12d
	cdqe
	sal	rax, 3
	add	rax, rcx
	mov	rax, QWORD PTR [rax]
	mov	eax, DWORD PTR [rax]
	cdqe
	add	rax, rax
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 8192
	test	eax, eax
	je	.L20
	jmp	.L21
.L18:
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	movsx	rdx, ebx
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-56]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	and	eax, 8192
	test	eax, eax
	je	.L21
	mov	rcx, r14
	mov	eax, r15d
	lea	edx, [rax+1]
	mov	r15d, edx
	cdqe
	sal	rax, 2
	lea	rdx, [rcx+rax]
	movsx	rax, ebx
	lea	rcx, [0+rax*4]
	mov	rax, QWORD PTR [rbp-56]
	add	rax, rcx
	mov	eax, DWORD PTR [rax]
	mov	DWORD PTR [rdx], eax
.L21:
	add	ebx, 1
.L16:
	cmp	ebx, DWORD PTR [rbp-60]
	jl	.L22
	mov	r12d, 0
	jmp	.L23
.L24:
	mov	eax, r12d
	cdqe
	lea	rdx, [0+rax*4]
	mov	rax, QWORD PTR [rbp-56]
	add	rdx, rax
	mov	rcx, r14
	mov	eax, r12d
	cdqe
	sal	rax, 2
	add	rax, rcx
	mov	eax, DWORD PTR [rax]
	mov	DWORD PTR [rdx], eax
	mov	eax, r12d
	add	eax, 1
	mov	r12d, eax
.L23:
	mov	eax, r12d
	cmp	eax, DWORD PTR [rbp-60]
	jl	.L24
	mov	rax, r13
	mov	rdi, rax
	call	free
	mov	rax, r14
	mov	rdi, rax
	call	free
	nop
	add	rsp, 24
	pop	rbx
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	ret



	.size	reverse_words, .-reverse_words
	.globl	N
	.section	.rodata
	.align 4
	.type	N, @object
	.size	N, 4
N:
	.long	100000
.LC0:
	.string	"r"
.LC1:
	.string	"w"
.LC2:
	.string	"text to big to process!"
	.text
	.globl	main
	.type	main, @function
main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	mov	DWORD PTR [rbp-36], edi
	mov	QWORD PTR [rbp-48], rsi
	mov	eax, 100000
	cdqe
	sal	rax, 2
	mov	rdi, rax
	call	malloc
	mov	QWORD PTR [rbp-8], rax
	mov	rax, QWORD PTR stdin[rip]
	mov	QWORD PTR [rbp-24], rax
	mov	rax, QWORD PTR stdout[rip]
	mov	QWORD PTR [rbp-16], rax
	cmp	DWORD PTR [rbp-36], 2
	jle	.L26
	mov	rax, QWORD PTR [rbp-48]
	add	rax, 8
	mov	rax, QWORD PTR [rax]
	mov	esi, OFFSET FLAT:.LC0
	mov	rdi, rax
	call	fopen
	mov	QWORD PTR [rbp-24], rax
	mov	rax, QWORD PTR [rbp-48]
	add	rax, 16
	mov	rax, QWORD PTR [rax]
	mov	esi, OFFSET FLAT:.LC1
	mov	rdi, rax
	call	fopen
	mov	QWORD PTR [rbp-16], rax
.L26:
	mov	ecx, 100000
	mov	rdx, QWORD PTR [rbp-24]
	mov	rax, QWORD PTR [rbp-8]
	mov	esi, ecx
	mov	rdi, rax
	call	read_string
	mov	DWORD PTR [rbp-28], eax
	cmp	DWORD PTR [rbp-28], -1
	jne	.L27
	mov	edi, OFFSET FLAT:.LC2
	mov	eax, 0
	call	printf
	mov	eax, 0
	jmp	.L28
.L27:
	mov	edx, DWORD PTR [rbp-28]
	mov	rax, QWORD PTR [rbp-8]
	mov	esi, edx
	mov	rdi, rax
	call	reverse_words
	mov	rdx, QWORD PTR [rbp-16]
	mov	ecx, DWORD PTR [rbp-28]
	mov	rax, QWORD PTR [rbp-8]
	mov	esi, ecx
	mov	rdi, rax
	call	print_string
	mov	rax, QWORD PTR [rbp-8]
	mov	rdi, rax
	call	free
	cmp	DWORD PTR [rbp-36], 2
	jle	.L29
	mov	rax, QWORD PTR [rbp-24]
	mov	rdi, rax
	call	fclose
	mov	rax, QWORD PTR [rbp-16]
	mov	rdi, rax
	call	fclose
.L29:
	mov	eax, 0
.L28:
	leave
	ret
	.size	main, .-main
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
