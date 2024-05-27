	.text
	.file	"test6.c"
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
	pushq	%rbx
	.cfi_def_cfa_offset 40
	subq	$56, %rsp
	.cfi_def_cfa_offset 96
	.cfi_offset %rbx, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	cmpl	$2, %edi
	jne	.LBB0_1
# %bb.2:                                # %if.end
	movq	%rsi, %rdi
	movl	$1, %esi
	callq	readArgv
	movl	%eax, %ebp
	movl	$4, %edi
	callq	mymalloc
	movq	%rax, %rbx
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$1, %edx
	callq	mycast
	movq	%rbx, %rdi
	movq	%rbx, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.3:
	leaq	8(%rsp), %rdi
	movl	$8, %edx
	movl	$48, %ecx
	movq	%rdi, %rsi
	callq	checkBoundsStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.4:
	leaq	8(%rsp), %rdi
	movl	$53, %ecx
	movq	%rdi, %rsi
	movq	%rbx, %rdx
	callq	writeBarrierStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.5:
	movq	%rbx, 8(%rsp)
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
	jne	.LBB0_20
# %bb.6:
	leaq	24(%rsp), %rbx
	leaq	8(%rsp), %rdi
	movl	$8, %edx
	movl	$48, %ecx
	movq	%rbx, %rsi
	callq	checkBoundsStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.7:
	leaq	8(%rsp), %rdi
	movl	$53, %ecx
	movq	%rbx, %rsi
	movq	%r14, %rdx
	callq	writeBarrierStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.8:
	movq	%r14, 24(%rsp)
	movl	$4, %edi
	callq	mymalloc
	movq	%rax, %r15
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$1, %edx
	callq	mycast
	movq	%r15, %rdi
	movq	%r15, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.9:
	leaq	40(%rsp), %r14
	leaq	8(%rsp), %rdi
	movl	$8, %edx
	movl	$48, %ecx
	movq	%r14, %rsi
	callq	checkBoundsStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.10:
	leaq	8(%rsp), %rdi
	movl	$53, %ecx
	movq	%r14, %rsi
	movq	%r15, %rdx
	callq	writeBarrierStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.11:
	movq	%r15, 40(%rsp)
	movl	$4, %edi
	callq	mymalloc
	movq	%rax, %r15
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$1, %edx
	callq	mycast
	movq	%r15, %rdi
	movq	%r15, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.12:
	leaq	48(%rsp), %rbx
	leaq	8(%rsp), %rdi
	movl	$8, %edx
	movl	$48, %ecx
	movq	%rbx, %rsi
	callq	checkBoundsStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.13:
	leaq	8(%rsp), %rdi
	movl	$53, %ecx
	movq	%rbx, %rsi
	movq	%r15, %rdx
	callq	writeBarrierStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.14:
	movq	%r15, 48(%rsp)
	movslq	%ebp, %rax
	leaq	(%rsp,%rax), %rbx
	addq	$16, %rbx
	leaq	8(%rsp), %rdi
	movl	$1, %edx
	movl	$48, %ecx
	movq	%rbx, %rsi
	callq	checkBoundsStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.15:
	leaq	8(%rsp), %rdi
	movl	$1, %edx
	movl	$53, %ecx
	movq	%rbx, %rsi
	callq	writeBarrierStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.16:
	movb	$1, (%rbx)
	leaq	8(%rsp), %rdi
	movl	$8, %edx
	movl	$48, %ecx
	movq	%rdi, %rsi
	callq	checkBoundsStack
	testl	%eax, %eax
	jne	.LBB0_20
# %bb.17:
	movq	8(%rsp), %rbx
	leaq	8(%rsp), %rdi
	movl	$8, %edx
	movl	$48, %ecx
	movq	%r14, %rsi
	callq	checkBoundsStack
	testl	%eax, %eax
	je	.LBB0_18
.LBB0_20:                               # %OOBcheck.failure
	ud2
                                        # implicit-def: $eax
	jmp	.LBB0_19
.LBB0_1:                                # %if.then
	movl	$.Lstr, %edi
	callq	puts
	xorl	%eax, %eax
.LBB0_19:                               # %cleanup
	addq	$56, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB0_18:
	.cfi_def_cfa_offset 96
	xorl	%eax, %eax
	cmpq	40(%rsp), %rbx
	sete	%al
	jmp	.LBB0_19
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.Lstr,@object           # @str
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lstr:
	.asciz	"usage: <offset>"
	.size	.Lstr, 16


	.ident	"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 23fd0cc59a32d9b8e1837ee26b6a88eeea825a95)"
	.section	".note.GNU-stack","",@progbits
