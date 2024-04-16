	.text
	.file	"test2.c"
	.globl	bar                     # -- Begin function bar
	.p2align	4, 0x90
	.type	bar,@function
bar:                                    # @bar
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	movslq	%esi, %rax
	leaq	(%rdi,%rax,8), %rbx
	movl	$8, %edx
	movq	%rbx, %rsi
	callq	checkBounds
	testl	%eax, %eax
	je	.LBB0_1
# %bb.2:                                # %Boundcheck.failure
	ud2
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.LBB0_1:
	.cfi_def_cfa_offset 16
	movq	$0, (%rbx)
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	bar, .Lfunc_end0-bar
	.cfi_endproc
                                        # -- End function
	.globl	foo                     # -- Begin function foo
	.p2align	4, 0x90
	.type	foo,@function
foo:                                    # @foo
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
	pushq	%rax
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movl	%esi, %r14d
	movq	%rdi, %rbx
	movl	$8, %edx
	movq	%rdi, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB1_3
# %bb.1:
	movq	(%rbx), %rbx
	movslq	%r14d, %r15
	leaq	(%rbx,%r15,4), %rbp
	movl	$4, %edx
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB1_3
# %bb.2:
	movl	$20, (%rbp)
	leaq	(%rbx,%r15,4), %rbp
	addq	$32, %rbp
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB1_4
.LBB1_3:                                # %OOBcheck.failure
	ud2
	addq	$8, %rsp
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
.LBB1_4:
	.cfi_def_cfa_offset 48
	movq	%rbp, %rdi
	movl	%r14d, %esi
	addq	$8, %rsp
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	jmp	bar                     # TAILCALL
.Lfunc_end1:
	.size	foo, .Lfunc_end1-foo
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
	movl	$16, %edi
	callq	mymalloc
	movq	%rax, %r15
	movl	$7, %esi
	movq	%rax, %rdi
	movl	$16, %edx
	callq	mycast
	cmpl	$3, %ebx
	jne	.LBB2_1
# %bb.2:                                # %if.end
	movq	%rbp, %rdi
	movl	$1, %esi
	callq	readArgv
	movl	%eax, %ebx
	movq	%rbp, %rdi
	movl	$2, %esi
	callq	readArgv
	movl	%eax, %r14d
	movq	%rsp, %r12
	movl	%ebx, %edi
	shlq	$2, %rdi
	callq	mymalloc
	movq	%rax, %rbx
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$4, %edx
	callq	mycast
	movslq	%r14d, %rax
	leaq	(%rbx,%rax,4), %rbp
	addq	$4, %rbp
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB2_8
# %bb.3:
	movl	$8, %edx
	movq	%r15, %rdi
	movq	%r15, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB2_8
# %bb.4:
	movq	%rbp, (%r15)
	movq	%r15, %rdi
	movq	%r15, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB2_5
.LBB2_8:                                # %OOBcheck.failure
	ud2
                                        # implicit-def: $eax
	jmp	.LBB2_7
.LBB2_1:                                # %if.then
	movl	$.Lstr, %edi
	callq	puts
.LBB2_6:                                # %return
	xorl	%eax, %eax
.LBB2_7:                                # %return
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
.LBB2_5:
	.cfi_def_cfa_offset 48
	movq	%r15, %rdi
	movl	%r14d, %esi
	callq	foo
	movq	%r12, %rsp
	jmp	.LBB2_6
.Lfunc_end2:
	.size	main, .Lfunc_end2-main
	.cfi_endproc
                                        # -- End function
	.type	.Lstr,@object           # @str
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lstr:
	.asciz	"Usage:: <size> <offset>"
	.size	.Lstr, 24


	.ident	"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 49d077240ba88639d805c42031ba63ca38f025b6)"
	.section	".note.GNU-stack","",@progbits
