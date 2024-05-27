	.text
	.file	"test4.c"
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
	leaq	(%rdi,%rax,4), %rbx
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
	.size	bar, .Lfunc_end0-bar
	.cfi_endproc
                                        # -- End function
	.globl	allocate_a              # -- Begin function allocate_a
	.p2align	4, 0x90
	.type	allocate_a,@function
allocate_a:                             # @allocate_a
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%r14
	.cfi_def_cfa_offset 24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset %rbx, -32
	.cfi_offset %r14, -24
	.cfi_offset %rbp, -16
	movl	%esi, %ebp
	movslq	%edi, %rdi
	callq	mymalloc
	movq	%rax, %rbx
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$4, %edx
	callq	mycast
	movslq	%ebp, %rax
	leaq	(%rbx,%rax,4), %r14
	movq	%rbx, %rdi
	movq	%r14, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB1_1
# %bb.3:                                # %OOBcheck.failure
	ud2
                                        # implicit-def: $rax
	jmp	.LBB1_2
.LBB1_1:
	movq	%r14, %rax
.LBB1_2:
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	allocate_a, .Lfunc_end1-allocate_a
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
	movslq	%esi, %r15
	leaq	(%rdi,%r15,4), %rbp
	movl	$4, %edx
	movq	%rbp, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB2_3
# %bb.1:
	movl	$20, %esi
	movq	%rbp, %rdi
	callq	writeBarrier
	testl	%eax, %eax
	jne	.LBB2_3
# %bb.2:
	movl	$20, (%rbp)
	leaq	(%rbx,%r15,4), %rbp
	addq	$32, %rbp
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB2_4
.LBB2_3:                                # %OOBcheck.failure
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
.LBB2_4:
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
.Lfunc_end2:
	.size	foo, .Lfunc_end2-foo
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
	pushq	%rbx
	.cfi_def_cfa_offset 40
	pushq	%rax
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	.cfi_offset %rbp, -16
	cmpl	$3, %edi
	jne	.LBB3_1
# %bb.2:                                # %if.end
	movq	%rsi, %rbx
	movq	%rsi, %rdi
	movl	$1, %esi
	callq	readArgv
	movl	%eax, %ebp
	movq	%rbx, %rdi
	movl	$2, %esi
	callq	readArgv
	movl	%eax, %r14d
	movq	%rsp, %r15
	movl	%ebp, %edi
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
	jne	.LBB3_10
# %bb.3:
	movl	$node, %edi
	movl	$node, %esi
	movl	$16, %edx
	movl	$16, %ecx
	callq	checkBoundsStack
	testl	%eax, %eax
	jne	.LBB3_10
# %bb.4:
	movl	$node, %edi
	movl	$node, %esi
	movl	$3, %ecx
	movq	%rbp, %rdx
	callq	writeBarrierStack
	testl	%eax, %eax
	jne	.LBB3_10
# %bb.5:
	movq	%rbp, node(%rip)
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB3_10
# %bb.6:
	movq	%rbp, %rdi
	movl	%r14d, %esi
	callq	foo
	movq	%r15, %rsp
	movq	%rbx, %rdi
	movq	%rbx, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB3_7
.LBB3_10:                               # %OOBcheck.failure
	ud2
                                        # implicit-def: $eax
	jmp	.LBB3_9
.LBB3_1:                                # %if.then
	movl	$.Lstr, %edi
	callq	puts
.LBB3_8:                                # %return
	xorl	%eax, %eax
.LBB3_9:                                # %return
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
.LBB3_7:
	.cfi_def_cfa_offset 48
	movq	%rbx, %rdi
	callq	myfree
	jmp	.LBB3_8
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
	.cfi_endproc
                                        # -- End function
	.type	node,@object            # @node
	.comm	node,16,8
	.type	.Lstr,@object           # @str
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lstr:
	.asciz	"Usage:: <size> <offset>"
	.size	.Lstr, 24


	.ident	"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 23fd0cc59a32d9b8e1837ee26b6a88eeea825a95)"
	.section	".note.GNU-stack","",@progbits
