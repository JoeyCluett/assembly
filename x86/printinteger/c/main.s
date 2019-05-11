	.file	"main.c"
	.section	.rodata
.LC0:
	.string	""
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	leal	4(%esp), %ecx
	.cfi_def_cfa 1, 0
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	movl	%esp, %ebp
	pushl	%ecx
	.cfi_escape 0xf,0x3,0x75,0x7c,0x6
	subl	$20, %esp
	movl	$0, -20(%ebp)
	jmp	.L2
.L7:
	movl	$0, -16(%ebp)
	jmp	.L3
.L6:
	movl	$0, -12(%ebp)
	jmp	.L4
.L5:
	subl	$4, %esp
	pushl	-12(%ebp)
	pushl	-16(%ebp)
	pushl	-20(%ebp)
	call	print_int
	addl	$16, %esp
	subl	$12, %esp
	pushl	$.LC0
	call	puts
	addl	$16, %esp
	addl	$19, -12(%ebp)
.L4:
	cmpl	$99, -12(%ebp)
	jle	.L5
	addl	$14, -16(%ebp)
.L3:
	cmpl	$13, -16(%ebp)
	jle	.L6
	addl	$14, -20(%ebp)
.L2:
	cmpl	$13, -20(%ebp)
	jle	.L7
	movl	$0, %eax
	movl	-4(%ebp), %ecx
	.cfi_def_cfa 1, 0
	leave
	.cfi_restore 5
	leal	-4(%ecx), %esp
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.11) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
