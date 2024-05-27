	.text
	.file	"test10.c"
	.globl	foo                     # -- Begin function foo
	.p2align	4, 0x90
	.type	foo,@function
foo:                                    # @foo
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	movslq	%esi, %rbx
	addq	%rdi, %rbx
	movl	$4, %edx
	movq	%rbx, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB0_3
# %bb.1:
	movq	%rbx, %rdi
	xorl	%esi, %esi
	callq	writeBarrier
	testl	%eax, %eax
	je	.LBB0_2
.LBB0_3:                                # %WriteBarrier.failure
	ud2
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.LBB0_2:
	.cfi_def_cfa_offset 16
	movl	$0, (%rbx)
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	foo, .Lfunc_end0-foo
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r15
	.cfi_def_cfa_offset 24
	pushq	%r14
	.cfi_def_cfa_offset 32
	pushq	%r12
	.cfi_def_cfa_offset 40
	pushq	%rbx
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -48
	.cfi_offset %r12, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rsi, %rbp
	movl	%edi, %ebx
	movl	$192, %edi
	callq	mymalloc
	cmpl	$2, %ebx
	jne	.LBB1_1
# %bb.2:                                # %if.end
	movq	%rax, %r12
	movl	$117, %esi
	movq	%rax, %rdi
	movl	$48, %edx
	callq	mycast
	movq	%rbp, %rdi
	movl	$1, %esi
	callq	readArgv
	movl	%eax, %r15d
	movl	$4, %edi
	callq	mymalloc
	movq	%rax, %rbp
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$1, %edx
	callq	mycast
	movq	%rbp, %rdi
	movq	%rbp, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.3:
	leaq	96(%r12), %rbx
	movl	$8, %edx
	movq	%r12, %rdi
	movq	%rbx, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.4:
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	writeBarrier
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.5:
	movq	%rbp, 96(%r12)
	movl	$4, %edi
	callq	mymalloc
	movq	%rax, %r14
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$1, %edx
	callq	mycast
	movq	%r14, %rdi
	movq	%r14, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.6:
	leaq	112(%r12), %rbx
	movl	$8, %edx
	movq	%r12, %rdi
	movq	%rbx, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.7:
	movq	%rbx, %rdi
	movq	%r14, %rsi
	callq	writeBarrier
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.8:
	movq	%r14, 112(%r12)
	movl	$4, %edi
	callq	mymalloc
	movq	%rax, %r14
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$1, %edx
	callq	mycast
	movq	%r14, %rdi
	movq	%r14, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.9:
	leaq	128(%r12), %rbx
	movl	$8, %edx
	movq	%r12, %rdi
	movq	%rbx, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.10:
	movq	%rbx, %rdi
	movq	%r14, %rsi
	callq	writeBarrier
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.11:
	movq	%r14, 128(%r12)
	movl	$4, %edi
	callq	mymalloc
	movq	%rax, %r14
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$1, %edx
	callq	mycast
	movq	%r14, %rdi
	movq	%r14, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.12:
	movq	%r12, %rbp
	addq	$136, %rbp
	movl	$8, %edx
	movq	%r12, %rdi
	movq	%rbp, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.13:
	movq	%rbp, %rdi
	movq	%r14, %rsi
	callq	writeBarrier
	testl	%eax, %eax
	jne	.LBB1_18
# %bb.14:
	movq	%r14, 136(%r12)
	movq	%r12, %rdi
	movq	%r12, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB1_15
.LBB1_18:                               # %OOBcheck.failure
	ud2
                                        # implicit-def: $eax
	jmp	.LBB1_17
.LBB1_1:                                # %if.then
	movl	$.Lstr, %edi
	callq	puts
.LBB1_16:                               # %cleanup
	xorl	%eax, %eax
.LBB1_17:                               # %cleanup
	popq	%rbx
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB1_15:
	.cfi_def_cfa_offset 48
	movq	%r12, %rdi
	movl	%r15d, %esi
	callq	foo
	jmp	.LBB1_16
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function
	.type	.Lstr,@object           # @str
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lstr:
	.asciz	"usage: <offset>"
	.size	.Lstr, 16


	.ident	"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 23fd0cc59a32d9b8e1837ee26b6a88eeea825a95)"
	.section	".note.GNU-stack","",@progbits
