	.text
	.file	"test1.c"
	.globl	allocate_n              # -- Begin function allocate_n
	.p2align	4, 0x90
	.type	allocate_n,@function
allocate_n:                             # @allocate_n
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	movl	$16, %edi
	callq	mymalloc
	movq	%rax, %rbx
	movl	$7, %esi
	movq	%rax, %rdi
	movl	$16, %edx
	callq	mycast
	movq	%rbx, %rdi
	movq	%rbx, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB0_1
# %bb.2:                                # %OOBcheck.failure
	ud2
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.LBB0_1:
	.cfi_def_cfa_offset 16
	movq	%rbx, %rax
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	allocate_n, .Lfunc_end0-allocate_n
	.cfi_endproc
                                        # -- End function
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
	jne	.LBB1_3
# %bb.1:
	movq	%rbx, %rdi
	xorl	%esi, %esi
	callq	writeBarrier
	testl	%eax, %eax
	je	.LBB1_2
.LBB1_3:                                # %WriteBarrier.failure
	ud2
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.LBB1_2:
	.cfi_def_cfa_offset 16
	movl	$0, (%rbx)
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	bar, .Lfunc_end1-bar
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
	je	.LBB2_1
# %bb.3:                                # %OOBcheck.failure
	ud2
                                        # implicit-def: $rax
	jmp	.LBB2_2
.LBB2_1:
	movq	%r14, %rax
.LBB2_2:
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	allocate_a, .Lfunc_end2-allocate_a
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
	jne	.LBB3_4
# %bb.1:
	movq	(%rbx), %rbx
	movslq	%r14d, %r15
	leaq	(%rbx,%r15,4), %rbp
	movl	$4, %edx
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB3_4
# %bb.2:
	movl	$20, %esi
	movq	%rbp, %rdi
	callq	writeBarrier
	testl	%eax, %eax
	jne	.LBB3_4
# %bb.3:
	movl	$20, (%rbp)
	leaq	(%rbx,%r15,4), %rbp
	addq	$32, %rbp
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB3_5
.LBB3_4:                                # %OOBcheck.failure
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
.LBB3_5:
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
.Lfunc_end3:
	.size	foo, .Lfunc_end3-foo
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
	jne	.LBB4_1
# %bb.2:                                # %if.end
	movq	%rsi, %rbx
	movq	%rsi, %rdi
	movl	$1, %esi
	callq	readArgv
                                        # kill: def $eax killed $eax def $rax
	leal	(,%rax,4), %ebp
	movq	%rbx, %rdi
	movl	$2, %esi
	callq	readArgv
	movl	%eax, %r14d
	movl	%ebp, %edi
	movl	%eax, %esi
	callq	allocate_a
	movq	%rax, %rbx
	callq	allocate_n
	movq	%rax, %r15
	leaq	4(%rbx), %rbp
	movq	%rbx, %rdi
	movq	%rbp, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB4_9
# %bb.3:
	movl	$8, %edx
	movq	%r15, %rdi
	movq	%r15, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB4_9
# %bb.4:
	movq	%r15, %rdi
	movq	%rbp, %rsi
	callq	writeBarrier
	testl	%eax, %eax
	jne	.LBB4_9
# %bb.5:
	movq	%rbp, (%r15)
	movq	%r15, %rdi
	movq	%r15, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	je	.LBB4_6
.LBB4_9:                                # %OOBcheck.failure
	ud2
                                        # implicit-def: $eax
	jmp	.LBB4_8
.LBB4_1:                                # %if.then
	movl	$.Lstr, %edi
	callq	puts
.LBB4_7:                                # %return
	xorl	%eax, %eax
.LBB4_8:                                # %return
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
.LBB4_6:
	.cfi_def_cfa_offset 48
	movq	%r15, %rdi
	movl	%r14d, %esi
	callq	foo
	jmp	.LBB4_7
.Lfunc_end4:
	.size	main, .Lfunc_end4-main
	.cfi_endproc
                                        # -- End function
	.type	.Lstr,@object           # @str
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lstr:
	.asciz	"Usage:: <size> <offset>"
	.size	.Lstr, 24


	.ident	"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 23fd0cc59a32d9b8e1837ee26b6a88eeea825a95)"
	.section	".note.GNU-stack","",@progbits
