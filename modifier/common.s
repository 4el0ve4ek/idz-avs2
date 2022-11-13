	.file	"common.c"
	.intel_syntax noprefix
	.text
	.globl	read_string
	.type	read_string, @function
read_string:
	push	rbp
	mov	rbp, rsp
	push	r15
	push	r14
	push	r13
	push	r12
	push	rbx
	sub	rsp, 8
	mov	r14, rdi				# str
	mov	r13d, esi				# max_size
	mov	r15, rdx				# input
	mov	ebx, 0					# i
.L3:
	# r12d := fgetc(input) // ch
	mov	rdi, r15				
	call	fgetc
	mov	r12d, eax
	mov	eax, ebx				# i
	lea	ebx, [rax+1]			# i + 1
	cdqe
	sal	rax, 2
	add	rax, r14
	mov	DWORD PTR [rax], r12d	# str[i] = ch
	cmp	r12d, -1				# ch != -11
	je	.L2
	cmp	ebx, r13d				# i != max_size
	jne	.L3
.L2:
	movsx	rax, ebx
	sal	rax, 2
	sub	rax, 4
	add	rax, r14
	mov	DWORD PTR [rax], 10		# str[i - 1] == '\n'
	cmp	ebx, r13d				# i == max_size
	jne	.L4
	cmp	r12d, -1				# ch != -1
	je	.L4
	mov	eax, -1					# return -1
	jmp	.L5
.L4:
	mov	eax, ebx				# return i
.L5:
	add	rsp, 8
	pop	rbx
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	ret


	.size	read_string, .-read_string
	.globl	print_string
	.type	print_string, @function
print_string:
	push	rbp
	mov	rbp, rsp
	push	r13
	push	r12
	push	rbx
	sub	rsp, 8
	mov	r12, rdi	 			# str
	mov	ebx, esi	 			# size
	mov	r13, rdx 	 			# output
	jmp	.L7
.L8:
	# fputc(output, *str++)
	mov	rax, r12				# str
	lea	r12, [rax+4]			# r12 := str + 1
	mov	eax, DWORD PTR [rax]	# *str
	mov	rsi, r13				# output
	mov	edi, eax				# *str
	call	fputc
.L7:
	mov	eax, ebx				# size
	lea	ebx, [rax-1]			# ebx := size -1
	test	eax, eax	
	jne	.L8
	nop
	add	rsp, 8
	pop	rbx
	pop	r12
	pop	r13
	pop	rbp
	ret
	.size	print_string, .-print_string
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
