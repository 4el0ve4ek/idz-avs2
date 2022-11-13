	.file	"common.c"
	.intel_syntax noprefix
	.text
	.globl	read_string
	.type	read_string, @function
# функция для посимвольного чтения строки из потока rdx 
read_string:
	push	rbp								# типовое начало функции
	mov	rbp, rsp
	sub	rsp, 48
	mov	QWORD PTR [rbp-24], rdi				# rbp-24 := str
	mov	DWORD PTR [rbp-28], esi				# rbp-28 := max_size
	mov	QWORD PTR [rbp-40], rdx				# rbp-40 := input
	mov	DWORD PTR [rbp-8], 0				# rbp-8 := i := 0 // size
	# do {
.L3:
	# int ch = fgets(input)
	mov	rax, QWORD PTR [rbp-40]				# input
	mov	rdi, rax
	call	fgetc
	mov	DWORD PTR [rbp-4], eax				# ch кладем на стек
	# str[i++] = ch
	mov	eax, DWORD PTR [rbp-8]				# eax := i
	lea	edx, [rax+1]						# edx = i + 1
	mov	DWORD PTR [rbp-8], edx				# возвращаем на стек i + 1
	cdqe									# eax -> rax
	lea	rdx, [0+rax*4]						# rdx := i * 4
	mov	rax, QWORD PTR [rbp-24]				# rax = str
	add	rdx, rax							# rdx := str + i // указатель на i элемент в строке
	mov	eax, DWORD PTR [rbp-4]				# eax = ch
	mov	DWORD PTR [rdx], eax				# str[i] = ch
# } while (ch != -1 && i != max_size)
	cmp	DWORD PTR [rbp-4], -1
	je	.L2	# ch == 1 -> выходим из цикла
	mov	eax, DWORD PTR [rbp-8]
	cmp	eax, DWORD PTR [rbp-28]
	jne	.L3	# i != max_size && ch != -1 -> крутимся в цикле дальше

.L2:
	# str[i-1] = '\n'
	mov	eax, DWORD PTR [rbp-8]
	cdqe
	sal	rax, 2
	lea	rdx, [rax-4]
	mov	rax, QWORD PTR [rbp-24]
	add	rax, rdx
	mov	DWORD PTR [rax], 10

	# if (i == max_size && ch != -1)
	mov	eax, DWORD PTR [rbp-8]
	cmp	eax, DWORD PTR [rbp-28]
	jne	.L4		# i != max_size -> не наш случай
	cmp	DWORD PTR [rbp-4], -1
	je	.L4		# ch == -1 -> не наш случай
	mov	eax, -1	# return -1
	jmp	.L5		# jump to end of func
.L4:
	mov	eax, DWORD PTR [rbp-8] 	# return i
.L5:
	leave
	ret
	.size	read_string, .-read_string
	.globl	print_string
	.type	print_string, @function

# выводит строку в output
print_string:
	push	rbp								# типовое начало функции
	mov	rbp, rsp
	sub	rsp, 32
	mov	QWORD PTR [rbp-8], rdi				# rbp-8 := str
	mov	DWORD PTR [rbp-12], esi				# rbp-12 := size
	mov	QWORD PTR [rbp-24], rdx				# rbp-24 := output
	jmp	.L7									# переходим к условию цикла
.L8: # тело цикла
	# str++ -> в rax старое значение, на стеке новое
	mov	rax, QWORD PTR [rbp-8]				# str
	lea	rdx, [rax+4]						# rdx := str + 1
	mov	QWORD PTR [rbp-8], rdx				# rbp-8 := str + 1
	# fputs(output, *str)
	mov	eax, DWORD PTR [rax]				# *str
	mov	rdx, QWORD PTR [rbp-24]				# output
	mov	rsi, rdx
	mov	edi, eax
	call	fputc
# size-- != 0
.L7:
	mov	eax, DWORD PTR [rbp-12]				# size
	lea	edx, [rax-1]
	mov	DWORD PTR [rbp-12], edx				# rbp-12 := size - 1
	test	eax, eax						# size == 0?
	jne	.L8									# если size != 0 то идем в тело цикло
	# выход из функции
	nop										# ничего не делает
	leave									#
	ret										# функция типа void ничего не возвращает
	.size	print_string, .-print_string
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
