	.text
	.file	"test7.c"
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
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset %rbx, -56
	.cfi_offset %r12, -48
	.cfi_offset %r13, -40
	.cfi_offset %r14, -32
	.cfi_offset %r15, -24
	cmpl	$3, %edi
	jne	.LBB2_1
# %bb.2:                                # %if.end
	movq	%rsi, %rbx
	movq	%rsi, %rdi
	movl	$1, %esi
	callq	readArgv
	movl	%eax, %r12d
	movq	%rbx, %rdi
	movl	$2, %esi
	callq	readArgv
	movl	%eax, %ebx
	movq	%rsp, -64(%rbp)         # 8-byte Spill
	movl	%r12d, %r15d
	leaq	(,%r15,4), %rdi
	callq	mymalloc
	movq	%rax, %r13
	movq	%rax, %rdi
	xorl	%esi, %esi
	movl	$4, %edx
	callq	mycast
	movq	%r15, -56(%rbp)         # 8-byte Spill
	shlq	$4, %r15
	movq	%rsp, %r14
	subq	%r15, %r14
	movq	%r14, %rsp
	movslq	%r12d, %rdx
	shlq	$4, %rdx
	movq	%r14, %rdi
	xorl	%esi, %esi
	callq	memset
	movslq	%ebx, %r12
	leaq	40(,%r12,4), %rbx
	addq	%r13, %rbx
	movq	%r13, %rdi
	movq	%rbx, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB2_15
# %bb.3:
	movq	%r13, -48(%rbp)         # 8-byte Spill
	movq	-64(%rbp), %r13         # 8-byte Reload
	shlq	$4, %r12
	addq	%r14, %r12
	movl	$8, %edx
	movq	%r14, %rdi
	movq	%r12, %rsi
	movq	%r15, %rcx
	callq	checkBoundsStack
	testl	%eax, %eax
	jne	.LBB2_15
# %bb.4:
	movl	$3, %ecx
	movq	%r14, %rdi
	movq	%r12, %rsi
	movq	%rbx, %rdx
	callq	writeBarrierStack
	testl	%eax, %eax
	jne	.LBB2_15
# %bb.5:
	movq	%rbx, (%r12)
	callq	rand
	cltd
	idivl	-56(%rbp)               # 4-byte Folded Reload
	movslq	%edx, %rbx
	shlq	$4, %rbx
	addq	%r14, %rbx
	movl	$8, %edx
	movq	%r14, %rdi
	movq	%rbx, %rsi
	movq	%r15, %r12
	movq	%r15, %rcx
	callq	checkBoundsStack
	testl	%eax, %eax
	je	.LBB2_6
.LBB2_15:                               # %OOBcheck.failure
	ud2
                                        # implicit-def: $eax
	jmp	.LBB2_14
.LBB2_1:                                # %if.then
	movl	$.Lstr, %edi
	callq	puts
	xorl	%ebx, %ebx
.LBB2_13:                               # %return
	movl	%ebx, %eax
.LBB2_14:                               # %return
	leaq	-40(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.LBB2_6:
	.cfi_def_cfa %rbp, 16
	cmpq	$0, (%rbx)
	je	.LBB2_7
# %bb.8:                                # %if.then10
	movl	$8, %edx
	movq	%r14, %rdi
	movq	%r14, %rsi
	movq	%r12, %rcx
	callq	checkBoundsStack
	testl	%eax, %eax
	jne	.LBB2_15
# %bb.9:
	movq	(%r14), %rbx
	movl	$4, %edx
	movq	%rbx, %rdi
	movq	%rbx, %rsi
	callq	checkBounds
	testl	%eax, %eax
	jne	.LBB2_15
# %bb.10:
	movl	(%rbx), %ebx
	movq	-48(%rbp), %r15         # 8-byte Reload
	movq	%r15, %rdi
	movq	%r15, %rsi
	callq	isAddrOOB
	testl	%eax, %eax
	jne	.LBB2_15
# %bb.11:
	movq	%r15, %rdi
	callq	myfree
	jmp	.LBB2_12
.LBB2_7:
	xorl	%ebx, %ebx
.LBB2_12:                               # %cleanup
	movq	%r13, %rsp
	jmp	.LBB2_13
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
