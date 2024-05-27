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
	jne	.LBB1_4
# %bb.1:
	movq	(%rbx), %rbx
	movslq	%r14d, %r15
	leaq	(%rbx,%r15,4), %rbp
	movl	$4, %edx
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB1_4
# %bb.2:
	movl	$20, %esi
	movq	%rbp, %rdi
	callq	writeBarrier
	testl	%eax, %eax
	jne	.LBB1_4
# %bb.3:
	movl	$20, (%rbp)
	leaq	(%rbx,%r15,4), %rbp
	addq	$32, %rbp
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB1_5
.LBB1_4:                                # %OOBcheck.failure
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
.LBB1_5:
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
	pushq	%r13
	.cfi_def_cfa_offset 40
	pushq	%r12
	.cfi_def_cfa_offset 48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	pushq	%rax
	.cfi_def_cfa_offset 64
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	movq	%rsi, %rbp
	movl	%edi, %ebx
	movl	$16, %edi
	callq	mymalloc
	movq	%rax, %r12
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
	movl	%eax, %r15d
	movq	%rsp, %r13
	movl	%ebx, %edi
	shlq	$2, %rdi
	callq	mymalloc
	movq	%rax, %r14
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$4, %edx
	callq	mycast
	movslq	%r15d, %rax
	leaq	(%r14,%rax,4), %rbp
	addq	$4, %rbp
	movq	%r14, %rdi
	movq	%rbp, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB2_10
# %bb.3:
	movl	$8, %edx
	movq	%r12, %rdi
	movq	%r12, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB2_10
# %bb.4:
	movq	%r12, %rdi
	movq	%rbp, %rsi
	callq	writeBarrier
	testl	%eax, %eax
	jne	.LBB2_10
# %bb.5:
	movq	%rbp, (%r12)
	movq	%r12, %rdi
	movq	%r12, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB2_10
# %bb.6:
	movq	%r12, %rdi
	movl	%r15d, %esi
	callq	foo
	movq	%r13, %rsp
	movq	%r14, %rdi
	movq	%r14, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB2_10
# %bb.7:
	movq	%r14, %rdi
	callq	myfree
	jmp	.LBB2_8
.LBB2_1:                                # %if.then
	movl	$.Lstr, %edi
	callq	puts
.LBB2_8:                                # %return
	movq	%r12, %rdi
	movq	%r12, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB2_9
.LBB2_10:                               # %OOBcheck.failure
	ud2
                                        # implicit-def: $ax
                                        # implicit-def: $al
                                        # implicit-def: $ah
                                        # implicit-def: $eax
                                        # implicit-def: $hax
.LBB2_11:                               # %OOBcheck.failure
	addq	$8, %rsp
	.cfi_def_cfa_offset 56
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%r12
	.cfi_def_cfa_offset 40
	popq	%r13
	.cfi_def_cfa_offset 32
	popq	%r14
	.cfi_def_cfa_offset 24
	popq	%r15
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.LBB2_9:
	.cfi_def_cfa_offset 64
	movq	%r12, %rdi
	callq	myfree
	xorl	%eax, %eax
	jmp	.LBB2_11
.Lfunc_end2:
	.size	main, .Lfunc_end2-main
	.cfi_endproc
                                        # -- End function
	.type	.Lstr,@object           # @str
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lstr:
	.asciz	"Usage:: <size> <offset>"
	.size	.Lstr, 24


	.ident	"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 23fd0cc59a32d9b8e1837ee26b6a88eeea825a95)"
	.section	".note.GNU-stack","",@progbits