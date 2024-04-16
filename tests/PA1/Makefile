CLANG=../../build/bin/clang
OPT=../../build/bin/opt
LLC=../../build/bin/llc
DIS=../../build/bin/llvm-dis
SLIB=../../build/lib/LLVMCSE301.so

SRCS=$(filter-out support.c,$(wildcard *.c))
TARGETS=$(patsubst %.c,%,$(SRCS))

default: $(TARGETS)

% : %.c support.o
	@$(CLANG) -c -emit-llvm $<
	@$(DIS) $*.bc
	@$(OPT) -load $(SLIB) -f -nullcheck -o $*.bc < $*.bc
	@$(DIS) -o $*_opt.ll $*.bc
	@$(LLC) $*.bc -o $*.s
	@$(CLANG) support.o $*.s -o $@
single : nullcheck1.c support.o	
	@$(CLANG) -c -emit-llvm $<
	@$(DIS) nullcheck1.bc
	@$(OPT) -load $(SLIB) -f -nullcheck -o nullcheck1.bc < nullcheck1.bc
	@$(DIS) -o nullcheck1_opt.ll nullcheck1.bc
	@$(LLC) nullcheck1.bc -o nullcheck1.s
	@$(CLANG) support.o nullcheck1.s -o $@
seven : nullcheck7.c support.o	
	@$(CLANG) -c -emit-llvm $<
	@$(DIS) nullcheck7.bc
	@$(OPT) -load $(SLIB) -f -nullcheck -o nullcheck7.bc < nullcheck7.bc
	@$(DIS) -o nullcheck7_opt.ll nullcheck7.bc
	@$(LLC) nullcheck7.bc -o nullcheck7.s
	@$(CLANG) support.o nullcheck7.s -o $@
support.o: support.c
	gcc -c support.c

clean:
	rm -f *.bc *.s *.ll $(TARGETS) *.o
