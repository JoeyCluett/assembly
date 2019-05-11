	.file	"main.c"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"callback: %d\n"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB1:
	.text
.LHOTB1:
	.globl	list_iter_callback
	.type	list_iter_callback, @function
list_iter_callback:
.LFB21:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$12, %esp
	pushl	8(%ebp)
	pushl	$.LC0
	pushl	$1
	call	__printf_chk
	addl	$16, %esp
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE21:
	.size	list_iter_callback, .-list_iter_callback
	.section	.text.unlikely
.LCOLDE1:
	.text
.LHOTE1:
	.section	.text.unlikely
.LCOLDB2:
	.text
.LHOTB2:
	.globl	new_node
	.type	new_node, @function
new_node:
.LFB22:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$20, %esp
	pushl	$8
	call	malloc
	movl	8(%ebp), %edx
	movl	%edx, (%eax)
	movl	12(%ebp), %edx
	movl	%edx, 4(%eax)
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE22:
	.size	new_node, .-new_node
	.section	.text.unlikely
.LCOLDE2:
	.text
.LHOTE2:
	.section	.rodata.str1.1
.LC3:
	.string	"From sumargvec: %d\n"
.LC4:
	.string	"\nSize of list:      %d\n"
.LC5:
	.string	"Size of new list:  %d\n"
.LC6:
	.string	"Size of NULL list: %d\n"
	.section	.text.unlikely
.LCOLDB7:
	.section	.text.startup,"ax",@progbits
.LHOTB7:
	.globl	main
	.type	main, @function
main:
.LFB20:
	.cfi_startproc
	leal	4(%esp), %ecx
	.cfi_def_cfa 1, 0
	andl	$-16, %esp
	pushl	-4(%ecx)
	pushl	%ebp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	movl	%esp, %ebp
	pushl	%esi
	pushl	%ebx
	pushl	%ecx
	.cfi_escape 0xf,0x3,0x75,0x74,0x6
	.cfi_escape 0x10,0x6,0x2,0x75,0x7c
	.cfi_escape 0x10,0x3,0x2,0x75,0x78
	xorl	%ebx, %ebx
	subl	$12, %esp
.L6:
	pushl	%eax
	pushl	$5
	pushl	$4
	pushl	$3
	pushl	$2
	pushl	$1
	pushl	%ebx
	pushl	$6
	incl	%ebx
	call	sumargvec
	addl	$28, %esp
	pushl	%eax
	pushl	$.LC3
	pushl	$1
	call	__printf_chk
	addl	$16, %esp
	cmpl	$10, %ebx
	jne	.L6
	pushl	%eax
	pushl	%eax
	movl	$1, %esi
	pushl	$0
	pushl	$0
	call	new_node
	addl	$16, %esp
	movl	%eax, %ebx
.L7:
	pushl	%eax
	pushl	%eax
	pushl	%esi
	pushl	%ebx
	incl	%esi
	call	new_node
	addl	$16, %esp
	cmpl	$10, %esi
	movl	%eax, %ebx
	jne	.L7
	subl	$12, %esp
	pushl	%eax
	call	listiter
	popl	%edx
	popl	%ecx
	pushl	$list_iter_callback
	pushl	%ebx
	call	listitercall
	movl	%ebx, (%esp)
	call	listsize
	addl	$12, %esp
	pushl	%eax
	pushl	$.LC4
	pushl	$1
	call	__printf_chk
	addl	$16, %esp
.L8:
	pushl	%eax
	pushl	%eax
	pushl	%esi
	pushl	%ebx
	incl	%esi
	call	new_node
	addl	$16, %esp
	cmpl	$20, %esi
	movl	%eax, %ebx
	jne	.L8
	subl	$12, %esp
	pushl	%eax
	call	listsize
	addl	$12, %esp
	pushl	%eax
	pushl	$.LC5
	pushl	$1
	call	__printf_chk
	movl	$0, (%esp)
	call	listsize
	addl	$12, %esp
	pushl	%eax
	pushl	$.LC6
	pushl	$1
	call	__printf_chk
	leal	-12(%ebp), %esp
	xorl	%eax, %eax
	popl	%ecx
	.cfi_restore 1
	.cfi_def_cfa 1, 0
	popl	%ebx
	.cfi_restore 3
	popl	%esi
	.cfi_restore 6
	popl	%ebp
	.cfi_restore 5
	leal	-4(%ecx), %esp
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE20:
	.size	main, .-main
	.section	.text.unlikely
.LCOLDE7:
	.section	.text.startup
.LHOTE7:
	.section	.rodata.str1.1
.LC8:
	.string	"%d\n"
	.section	.text.unlikely
.LCOLDB9:
	.text
.LHOTB9:
	.globl	print_list
	.type	print_list, @function
print_list:
.LFB23:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	pushl	%ebx
	pushl	%edx
	.cfi_offset 3, -12
	movl	8(%ebp), %ebx
.L15:
	testl	%ebx, %ebx
	je	.L18
	pushl	%eax
	pushl	4(%ebx)
	pushl	$.LC8
	pushl	$1
	call	__printf_chk
	movl	(%ebx), %ebx
	addl	$16, %esp
	jmp	.L15
.L18:
	movl	-4(%ebp), %ebx
	leave
	.cfi_restore 5
	.cfi_restore 3
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE23:
	.size	print_list, .-print_list
	.section	.text.unlikely
.LCOLDE9:
	.text
.LHOTE9:
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.11) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
