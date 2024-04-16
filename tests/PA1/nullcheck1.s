	.text
	.file	"nullcheck1.c"
	.globl	foo                     # -- Begin function foo
	.p2align	4, 0x90
	.type	foo,@function
foo:                                    # @foo
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	movq	%rdi, -16(%rbp)
	movl	$4, %edi
	callq	mymalloc
	movq	%rax, -8(%rbp)
	movq	$0, -32(%rbp)
	movq	-8(%rbp), %rax
	movl	$100, (%rax)
	movq	-16(%rbp), %rax
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	400(%rax), %eax
	movl	%eax, -20(%rbp)
	movq	-8(%rbp), %rax
	movl	$100, (%rax)
	cmpq	$0, -8(%rbp)
	jne	.LBB0_2
# %bb.1:                                # %if.then
	movl	$4, %edi
	callq	mymalloc
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movl	$100, (%rax)
	jmp	.LBB0_3
.LBB0_2:                                # %if.else
	movq	-8(%rbp), %rax
	movl	$100, (%rax)
.LBB0_3:                                # %if.end
	movq	-8(%rbp), %rax
	movl	$100, (%rax)
	addq	$32, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
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
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$16, %rsp
	movl	$0, -4(%rbp)
	xorl	%edi, %edi
	callq	foo
	xorl	%eax, %eax
	addq	$16, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
	.cfi_endproc
                                        # -- End function

	.ident	"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 49d077240ba88639d805c42031ba63ca38f025b6)"
	.section	".note.GNU-stack","",@progbits
