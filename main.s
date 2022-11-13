	.file	"main.c"
	.intel_syntax noprefix


	.text
	.globl	count_words
	.type	count_words, @function
	# функция для подсчета "слов"
	# словами в условиях данной задачи называются последовательности букв,
	# с обеих сторон огранниченные пробельными символами
count_words:
	push	rbp								# типовое начало функции
	mov	rbp, rsp
	sub	rsp, 32
	mov	QWORD PTR [rbp-24], rdi				# str
	mov	DWORD PTR [rbp-28], esi				# size
	mov	DWORD PTR [rbp-8], 0				# result
	mov	DWORD PTR [rbp-4], 0				# i
	jmp	.L2									# jump к условию цикла
.L4:
	# if(isspace(str[i + 1]) && !isspace(str[i]))
	# подробнее про __ctype_b_loc и то, как отрабатывает функция isspace
	# можно почитать ниже около отметки .L2
	
	# isspace(str[i + 1])
	# вспомогательный массив symbols
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]

	# кладем в edx = str[i + 1]
	mov	edx, DWORD PTR [rbp-4]
	movsx	rdx, edx
	add	rdx, 1
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	
	# достаем из массива symbols два бита, которые несут вспомогательную информацию о 
	# символе str[i + 1]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	# проверяем, является ли символ пробельным
	and	eax, 8192
	test	eax, eax
	je	.L3  # если нет -> скипаем условие

	# !isspace(str[i])
	# вспомогательный массив symbols
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	# кладем в edx = str[i]
	mov	edx, DWORD PTR [rbp-4]
	movsx	rdx, edx
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	# достаем из массива symbols два бита, которые несут вспомогательную информацию о 
	# символе str[i]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	# проверяем, является ли символ пробельным
	and	eax, 8192
	test	eax, eax
	jne	.L3	 # если да -> скипаем условие
	add	DWORD PTR [rbp-8], 1				# ++result;
.L3:
	add	DWORD PTR [rbp-4], 1				# ++i;
.L2:
	# i + 1 < size ?
	mov	eax, DWORD PTR [rbp-4]
	add	eax, 1
	cmp	eax, DWORD PTR [rbp-28]
	jl	.L4 								# если истинна, переходим к телу цикла 
	# if (size != 0 && !isspace(str[size-1])))
	cmp	DWORD PTR [rbp-28], 0				
	je	.L5									# size == 0 -> skip block
	# isspace делает вспомогательнный вызов функции __ctype_b_loc
	# которая вызвращает указатель на указатель начала массива (rax := unsigned short int**)
	# в это массиве в каждой ячейке лежат свойства соответствующего символа ascii
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax] 				# cast rax to (unsigned short int*)
	# для простоты повествования в регистре rax указатель на массив symbols

 	# taking str[size-1]
	mov	edx, DWORD PTR [rbp-28] 			# size
	movsx	rdx, edx						# расширяем edx->rdx с сохранением знака
	sal	rdx, 2								# rdx *= sizeof(int)
	lea	rcx, [rdx-4]						# rcx := rdx - 4 == (size - 1) * sizeof(int) 
	mov	rdx, QWORD PTR [rbp-24]				# rdx := str
	add	rdx, rcx							# rdx += scx -> rdx = str + size - 1 
	mov	edx, DWORD PTR [rdx]				# edx = str[size - 1]
	
	movsx	rdx, edx						# edx -> rx с сохранением знака
	add	rdx, rdx							# rdx *= 2
	add	rax, rdx							# rax += rdx -> rax = symbols + str[size - 1] * 2
	# массив symbols типа short int, там выделено по 2 последовательных байта под символ, поэтому нужно умножать на 2
	movzx	eax, WORD PTR [rax] 			# берем эти 2 байта и кладем их в eax, но в eax 4 байта, поэтому зануляем первые два 
	movzx	eax, ax							# кажется это лишнее, но все же мы еще раз зануляем два верхних байта
	and	eax, 8192							# 8192 == 2**13 -> 13 бит содержит информацию о том, является ли символ пробельным
	test	eax, eax						# проверяем, выставлен ли 13 бит, сравнивая 0 и (2**13) & eax
	jne	.L5									# если выставлен -> !=0 -> пропускаем след строчку
	add	DWORD PTR [rbp-8], 1				# ++result
.L5:
	mov	eax, DWORD PTR [rbp-8]				# return result;
	leave
	ret




	.size	count_words, .-count_words
	.globl	put_words
	.type	put_words, @function
	# функция которая кладет в массив words_start указатели на места, где начинаются слова в строке str
put_words:
	push	rbp								# типовое начало функции
	mov	rbp, rsp							
	sub	rsp, 48
	mov	QWORD PTR [rbp-24], rdi				# str
	mov	DWORD PTR [rbp-28], esi				# size
	mov	QWORD PTR [rbp-40], rdx				# words_start
	cmp	DWORD PTR [rbp-28], 0				# if size == 0
	je	.L14								# return;
	
	mov	DWORD PTR [rbp-8], 0				# j = 0
	# !isspace(str[0]) | подробнее можно почитать у отметки .L2
	# вспомогательный массив symbols
	call	__ctype_b_loc
	mov	rdx, QWORD PTR [rax]
	# кладем в eax := str[0]
	mov	rax, QWORD PTR [rbp-24]
	mov	eax, DWORD PTR [rax]
	# достаем из массива symbols два бита, которые несут вспомогательную информацию о 
	# символе str[0]
	cdqe
	add	rax, rax
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	# проверяем, является ли символ пробельным
	and	eax, 8192
	test	eax, eax
	jne	.L10 # если да -> то пропускаем блок
	
	# words[j++] = str;
	# в eax кладем старое значение j, обновляем значение на стеке на j + 1
	mov	eax, DWORD PTR [rbp-8]
	lea	edx, [rax+1]
	mov	DWORD PTR [rbp-8], edx
	cdqe
	# rdx = words + j // указатель на место, куда встатить начало нового слова
	lea	rdx, [0+rax*8]
	mov	rax, QWORD PTR [rbp-40]
	add	rdx, rax
	mov	rax, QWORD PTR [rbp-24] # str
	# words[j] = str + 0
	mov	QWORD PTR [rdx], rax
.L10:
	# i = 1
	mov	DWORD PTR [rbp-4], 1
	# переход к условию цикла
	jmp	.L11
.L13:
	# ниже идет проверка условий 
	# if (isspace(str[i - 1]) && !isspace(str[i]))
	# но они почти точь-в-точь похожи на условия в функции count_words, поэтому комментариев будет меньше
	
	# isspace(str[i - 1])
	# вспомогательный массив symbols
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	# кладем в edx := str[i - 1]
	mov	edx, DWORD PTR [rbp-4]
	movsx	rdx, edx
	sal	rdx, 2
	lea	rcx, [rdx-4]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	# достаем из массива symbols два бита, которые несут вспомогательную информацию о 
	# символе str[i - 1]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	# проверяем, является ли символ пробельным
	and	eax, 8192
	test	eax, eax
	je	.L12 # если нет -> то пропускаем блок

	# !isspace(str[i])
	# вспомогательный массив symbols
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	# кладем в edx := str[i]
	mov	edx, DWORD PTR [rbp-4]
	movsx	rdx, edx
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	# достаем из массива symbols два бита, которые несут вспомогательную информацию о 
	# символе str[i - 1]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	# проверяем, является ли символ пробельным
	and	eax, 8192
	test	eax, eax
	jne	.L12 # если да -> то пропускаем блок

	# words_start[j++] = str + i;
	mov	eax, DWORD PTR [rbp-8]	# j
	lea	edx, [rax+1]
	mov	DWORD PTR [rbp-8], edx	# j + 1
	cdqe
	lea	rdx, [0+rax*8]
	mov	rax, QWORD PTR [rbp-40] # words
	add	rax, rdx				# rax := words + j
	mov	edx, DWORD PTR [rbp-4]	# i
	movsx	rdx, edx		
	lea	rcx, [0+rdx*4]			
	mov	rdx, QWORD PTR [rbp-24] # str
	add	rdx, rcx				# str + i
	mov	QWORD PTR [rax], rdx	# words[j] = str + i
.L12:
	add	DWORD PTR [rbp-4], 1
.L11:
	# i < size ?
	mov	eax, DWORD PTR [rbp-4]
	cmp	eax, DWORD PTR [rbp-28]
	jl	.L13 # да -> идем в тело цикла
	jmp	.L7  # return
.L14:
	nop		# интересная конструкция, ведь 'nop' не делает ровно ничего (No OPeration)
.L7:
	leave
	ret



	.size	put_words, .-put_words
	.globl	reverse_words
	.type	reverse_words, @function

	# функция, которая меняет порядок слов на обратный.
	# изменяет порядок символов во входящей строке
reverse_words:
	push	rbp								# типовое начало
	mov	rbp, rsp
	sub	rsp, 48
	mov	QWORD PTR [rbp-40], rdi				# str
	mov	DWORD PTR [rbp-44], esi				# size

	# int cnt = count_words(str, size)
	mov	edx, DWORD PTR [rbp-44]
	mov	rax, QWORD PTR [rbp-40]
	mov	esi, edx
	mov	rdi, rax
	call	count_words
	mov	DWORD PTR [rbp-32], eax				# rbp-32 := cnt

	# int** words = malloc(cnt * sizeof(int*))
	mov	eax, DWORD PTR [rbp-32]
	cdqe
	sal	rax, 3
	mov	rdi, rax
	call	malloc
	mov	QWORD PTR [rbp-16], rax 			# rbp-16 := words

	# put_words(str, size, words);
	mov	rdx, QWORD PTR [rbp-16]				# words
	mov	ecx, DWORD PTR [rbp-44]				# size
	mov	rax, QWORD PTR [rbp-40]				# str
	mov	esi, ecx			
	mov	rdi, rax
	call	put_words

	# int* tmp = malloc(size * sizeof(int))
	mov	eax, DWORD PTR [rbp-44]
	cdqe
	sal	rax, 2
	mov	rdi, rax
	call	malloc
	mov	QWORD PTR [rbp-8], rax 				# rbp-8 := tmp

	mov	DWORD PTR [rbp-28], 0				# j = 0
	mov	DWORD PTR [rbp-24], 0				# i = 0;
	# переходим к условию цикла
	jmp	.L16
.L22:
	# (i == 0 || isspace(str[i - 1])) && !isspace(str[i])

	cmp	DWORD PTR [rbp-24], 0
	je	.L17						# i == 0
	
	# isspace(str[i - 1])
	# вспомогательный массив symbols
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	# кладем в edx := str[i - 1]
	mov	edx, DWORD PTR [rbp-24]
	movsx	rdx, edx
	sal	rdx, 2
	lea	rcx, [rdx-4]
	mov	rdx, QWORD PTR [rbp-40]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	# достаем из массива symbols два бита, которые несут вспомогательную информацию о 
	# символе str[i - 1]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	# проверяем, является ли символ пробельным
	and	eax, 8192
	test	eax, eax
	je	.L18						# если не пробельный -> переходи к else 
.L17:

	# !isspace(str[i])
	# вспомогательный массив symbols
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	# кладем в edx := str[i]
	mov	edx, DWORD PTR [rbp-24]
	movsx	rdx, edx
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-40]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	# достаем из массива symbols два бита, которые несут вспомогательную информацию о 
	# символе str[i]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	# проверяем, является ли символ пробельным
	and	eax, 8192
	test	eax, eax
	jne	.L18						# если пробельный -> переходим к блоку else
	sub	DWORD PTR [rbp-32], 1		# --cnt;
	jmp	.L19						# переходим к условию в блоке while
.L20:
	# tmp[j++] = *words[cnt]++;
	mov	eax, DWORD PTR [rbp-28]		#
	lea	edx, [rax+1]
	mov	DWORD PTR [rbp-28], edx		# j + 1
	# rsi := tmp + j
	cdqe
	lea	rdx, [0+rax*4]
	mov	rax, QWORD PTR [rbp-8]
	lea	rsi, [rdx+rax]
	#
	mov	eax, DWORD PTR [rbp-32] 	# cnt
	cdqe						
	lea	rdx, [0+rax*8]
	mov	rax, QWORD PTR [rbp-16]		# words
	add	rdx, rax					# words + cnt
	mov	rax, QWORD PTR [rdx]		# rax = words[cnt]
	lea	rcx, [rax+4]				# rcx := words[cnt] + 1
	mov	QWORD PTR [rdx], rcx		# words[cnt] = words[cnt] + 1
	mov	eax, DWORD PTR [rax]		# eax = *words[cnt]
	mov	DWORD PTR [rsi], eax		# tmp[j] = words[cnt]
.L19:
	# !isspace(*words[cnt])
	# вспомогательный массив symbols
	call	__ctype_b_loc
	mov	rdx, QWORD PTR [rax]
	# eax := words[cnt]
	mov	eax, DWORD PTR [rbp-32]
	cdqe
	lea	rcx, [0+rax*8]
	mov	rax, QWORD PTR [rbp-16]
	add	rax, rcx
	mov	rax, QWORD PTR [rax]
	mov	eax, DWORD PTR [rax]
	# достаем из массива symbols два бита, которые несут вспомогательную информацию о 
	# символе words[cnt]
	cdqe
	add	rax, rax
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	# проверяем, является ли символ пробельным
	and	eax, 8192
	test	eax, eax
	je	.L20 # если нет -> переходим к телу цикла
	jmp	.L21 # выходи из тела if, к новому циклу for-a
.L18:
	# if isspace(str[i])
	# вспомогательный массив symbols
	call	__ctype_b_loc
	mov	rax, QWORD PTR [rax]
	# edx := str[i]
	mov	edx, DWORD PTR [rbp-24]
	movsx	rdx, edx
	lea	rcx, [0+rdx*4]
	mov	rdx, QWORD PTR [rbp-40]
	add	rdx, rcx
	mov	edx, DWORD PTR [rdx]
	# достаем из массива symbols два бита, которые несут вспомогательную информацию о 
	# символе words[cnt]
	movsx	rdx, edx
	add	rdx, rdx
	add	rax, rdx
	movzx	eax, WORD PTR [rax]
	movzx	eax, ax
	# проверяем, является ли символ пробельным
	and	eax, 8192
	test	eax, eax
	je	.L21 	# если не является -> пропускаем блок
	# tmp[j++] = str[i]
	mov	eax, DWORD PTR [rbp-28]		# j
	lea	edx, [rax+1]
	mov	DWORD PTR [rbp-28], edx		# j + 1
	# rdx := tmp + j;
	cdqe
	lea	rdx, [0+rax*4]
	mov	rax, QWORD PTR [rbp-8]		
	add	rdx, rax
	# eax := str[i]
	mov	eax, DWORD PTR [rbp-24]
	cdqe
	lea	rcx, [0+rax*4]
	mov	rax, QWORD PTR [rbp-40]
	add	rax, rcx
	mov	eax, DWORD PTR [rax]
	mov	DWORD PTR [rdx], eax
.L21:
	add	DWORD PTR [rbp-24], 1		# ++i
.L16:
	# i < size ?
	mov	eax, DWORD PTR [rbp-24]	
	cmp	eax, DWORD PTR [rbp-44]
	jl	.L22 # if i < size ->  в тело цикла

	# начало второго цикла, по переносу значений из tmp в str
	# i = 0;
	mov	DWORD PTR [rbp-20], 0
	jmp	.L23 # i < size;
.L24:
	# кладем в rdx := str + i
	mov	eax, DWORD PTR [rbp-20]
	cdqe
	lea	rdx, [0+rax*4]
	mov	rax, QWORD PTR [rbp-40]
	add	rdx, rax

	# кладем в eax := tmp[j]
	mov	eax, DWORD PTR [rbp-20]
	cdqe
	lea	rcx, [0+rax*4]
	mov	rax, QWORD PTR [rbp-8]
	add	rax, rcx
	mov	eax, DWORD PTR [rax]
	# str[i] = tmp[j]
	mov	DWORD PTR [rdx], eax
	add	DWORD PTR [rbp-20], 1 # ++i;
.L23:
	mov	eax, DWORD PTR [rbp-20]
	cmp	eax, DWORD PTR [rbp-44]
	jl	.L24 # i < size ? -> repeat
	
	# free(words); | не  забываем освободить память!
	mov	rax, QWORD PTR [rbp-16]
	mov	rdi, rax
	call	free
	# free(tmp);   | не  забываем освободить память!
	mov	rax, QWORD PTR [rbp-8]
	mov	rdi, rax
	call	free
	nop
	leave
	ret



	.size	reverse_words, .-reverse_words
	.section	.rodata
.LC0:
	.string	"r"
.LC1:
	.string	"w"
.LC2:
	.string	"text to big to process!"
	.text
	.globl	main
	.type	main, @function
main:										# начало программы, отсюда все начинается
	push	rbp								# кладем указатель на начало стека вызывающей фукнции
	mov	rbp, rsp							# начало нашего стека - это конец вызывающего
	sub	rsp, 48								# занимаем 48 битов памяти
	
	mov	DWORD PTR [rbp-36], edi				# rbp-36 := argc
	mov	QWORD PTR [rbp-48], rsi				# rbp-48 := argv
	
	mov	DWORD PTR [rbp-32], 100000			# rbp-32 := N := 100000 <- max string size
	
	# выделяем память размера N под строку которая будет читаться 
	mov	eax, DWORD PTR [rbp-32]				# eax := N
	cdqe									# расширение eax до восьмибайтового
	sal	rax, 2								# байтовый сдвиг на 2 влево, что равносильно умножению на 4 == (sizeof(int)); 
	mov	rdi, rax							# первый параметр вызова функции malloc rdi := n * sizeof(int)
	call	malloc							# вызов функции, выделяем память под массив str
	mov	QWORD PTR [rbp-8], rax				# сохраняем массив на стеке в rbp-8
	
	# выбор потока ввода и ввывода, изначально в rbp-24 кладется stdin в rbp-16 кладется stdout
	mov	rax, QWORD PTR stdin[rip]
	mov	QWORD PTR [rbp-24], rax
	mov	rax, QWORD PTR stdout[rip]
	mov	QWORD PTR [rbp-16], rax

	# if (argc > 2) -- если ввели названия файла для ввода и вывода
	cmp	DWORD PTR [rbp-36], 2
	jle	.L26								# если не ввели, то пропускаем блок
	# в rax кладем argv[1] - имя файла ввода
	mov	rax, QWORD PTR [rbp-48]
	add	rax, 8
	mov	rax, QWORD PTR [rax]
	# формируем входые параметры для функции fopen
	mov	esi, OFFSET FLAT:.LC0				# открываем файл для чтения 
	mov	rdi, rax
	call	fopen							# вызов функции "открывать файл"
	mov	QWORD PTR [rbp-24], rax				# открытый файл теперь является потоком ввода
	# в rax кладем argv[2] - имя файла вывода
	mov	rax, QWORD PTR [rbp-48]
	add	rax, 16
	mov	rax, QWORD PTR [rax]
	# формируем входные параметры для функции fopen
	mov	esi, OFFSET FLAT:.LC1				# открываем файл для записи
	mov	rdi, rax
	call	fopen							# вызов функции "открыть файл"
	mov	QWORD PTR [rbp-16], rax				# открытый файл теперь является потоком вывода

.L26:
	# формируем параметры для чтения строки 
	mov	rdx, QWORD PTR [rbp-24]				# третий параметр - поток ввода (input)
	mov	ecx, DWORD PTR [rbp-32]				# второй - N - макс размер
	mov	rax, QWORD PTR [rbp-8]				# первый - ссылка на массив куда будет записываться строка
	mov	esi, ecx							# esi = ecx = N
	mov	rdi, rax							# rdi = rax = str
	call	read_string						# читаем строку
	mov	DWORD PTR [rbp-28], eax				# значение, которое вернулось, это размер, сохраняем его на стеке
	# if(size == -1)
	cmp	DWORD PTR [rbp-28], -1
	jne	.L27								# if size != -1 -> skip block
	# pritf("text to big to process!")
	mov	edi, OFFSET FLAT:.LC2
	mov	eax, 0 # нет переменного числа аргументов (в al количество векторных регистров, используемых для хранения аргументов)
	call	printf
	# return 0 and quit
	mov	eax, 0
	jmp	.L28

.L27:
	# reverse_words(str, size)
	mov	edx, DWORD PTR [rbp-28]				# size
	mov	rax, QWORD PTR [rbp-8]				# str
	mov	esi, edx				
	mov	rdi, rax
	call	reverse_words

	# print_string(str, size, output)	
	mov	rdx, QWORD PTR [rbp-16]				# output
	mov	ecx, DWORD PTR [rbp-28]				# size
	mov	rax, QWORD PTR [rbp-8]				# str
	mov	esi, ecx
	mov	rdi, rax
	call	print_string
	# free(str) -- незабываем освободить использованную память 
	mov	rax, QWORD PTR [rbp-8]
	mov	rdi, rax
	call	free
	# if (argc > 2) -- если ввели названия файла для ввода и вывода, их надо закрыть
	cmp	DWORD PTR [rbp-36], 2
	jle	.L29
	# fclose(input)
	mov	rax, QWORD PTR [rbp-24]
	mov	rdi, rax
	call	fclose
	# fclose(output)
	mov	rax, QWORD PTR [rbp-16]
	mov	rdi, rax
	call	fclose
.L29:
	mov	eax, 0	# return 0
.L28:
	leave
	ret
	.size	main, .-main
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.12) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
