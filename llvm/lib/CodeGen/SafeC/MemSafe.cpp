#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/CodeGen/Analysis.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Dominators.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Use.h"
#include "llvm/IR/User.h"
#include "llvm/IR/Value.h"
#include "llvm/Pass.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/LowLevelTypeImpl.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

#include <algorithm>
#include <deque>
#include <format>
#include <iostream>
#include <queue>
#include <vector>

// #define DEBUG

#ifdef DEBUG
#define PRINT(x) dbgs() << ((x))
#define ENDL(x) dbgs() << '\n'
#else
#define PRINT(x)
#define ENDL(x)
#endif // DEBUG
using namespace llvm;
namespace {
struct MemSafe : public FunctionPass {
  static char ID;
  const TargetLibraryInfo *TLI = nullptr;
  MemSafe() : FunctionPass(ID) {}
  void allocaToMyMallocPass(Function &F);
  void noOutOfBoundsPass(Function &F);
  void addWriteBarrier(Instruction *I, Value *Dst, Value *Src);
  void addCheckForBoundsGlobal(Instruction *I, Value *Base, Value *Accessed);
  void addWriteBarrierStack(Instruction *I, Value *Dst, Value *Src);
  void boundsCheck(Function &F);
  void writeBarrier(Function &F);
  Instruction *lastDominatedInstruction(Instruction *I);
  void addCheckForOOB(Instruction *I, Value *Base, Value *Accessed);
  void addCheckForBounds(Instruction *I, Value *Base, Value *Accessed);
  void addCheckForBoundsStack(Instruction *I, Value *Base, Value *Accessed);
  std::vector<BasicBlock *> reversePostOrder(Function &F);
  Value *walkBackAddressComputation(Value *Operand);
  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.addRequired<TargetLibraryInfoWrapperPass>();
  }

  bool runOnFunction(Function &F) override;

}; // end of struct MemSafe
} // end of anonymous namespace

static bool isLibraryCall(const CallInst *CI, const TargetLibraryInfo *TLI) {
  LibFunc Func;
  if (TLI->getLibFunc(ImmutableCallSite(CI), Func)) {
    return true;
  }
  auto Callee = CI->getCalledFunction();
  if (Callee && Callee->getName() == "readArgv") {
    return true;
  }
  if (isa<IntrinsicInst>(CI)) {
    return true;
  }
  return false;
}

std::vector<BasicBlock *> MemSafe::reversePostOrder(Function &F) {
  std::set<BasicBlock *> Visited;
  std::queue<BasicBlock *> Q;
  std::vector<BasicBlock *> ReverseOrder;
  for (BasicBlock &BB : F) {
    if (Visited.find(&BB) == Visited.end()) {
      Q.push(&BB);

      while (!Q.empty()) {
        BasicBlock *Curr = Q.front();
        Q.pop();

        if (Visited.find(Curr) == Visited.end()) {
          Visited.insert(Curr);

          for (BasicBlock *Succ : successors(Curr)) {
            Q.push(Succ);
          }

          ReverseOrder.push_back(Curr);
        }
      }
    }
  }
  return ReverseOrder;
}
bool MemSafe::runOnFunction(Function &F) {
  TLI = &getAnalysis<TargetLibraryInfoWrapperPass>().getTLI();
  allocaToMyMallocPass(F);
  // noOutOfBoundsPass(F);
  // boundsCheck(F);
  // writeBarrier(F);
  PRINT("===========START==========\\n");
  for (auto *Block : reversePostOrder(F)) {
    PRINT(Block->getName());
    ENDL();
    for (auto &Ins : *Block) {
      PRINT(Ins);
      ENDL();
    }
  }

  PRINT("==========END========\\n");
  return true;
}
Instruction *MemSafe::lastDominatedInstruction(Instruction *I) {
  std::vector<BasicBlock *> BBS = reversePostOrder(*I->getFunction());
  std::reverse(BBS.begin(), BBS.end());
  DominatorTree DT(*I->getFunction());
  for (BasicBlock *BB : BBS) {
    if (DT.dominates(I, BB)) {
      Instruction *Terminator = BB->getTerminator();
      return Terminator;
    }
  }
  return I->getParent()->getTerminator();
}
Value *MemSafe::walkBackAddressComputation(Value *PointerOp) {
  if (GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(PointerOp)) {
    return walkBackAddressComputation(GEP->getPointerOperand());
  }

  if (BitCastInst *BCInst = dyn_cast<BitCastInst>(PointerOp)) {
    if (BCInst->getOperand(0)->getType()->isPointerTy()) {
      return walkBackAddressComputation(BCInst->getOperand(0));
    }
  }
  return PointerOp;
}

void MemSafe::allocaToMyMallocPass(Function &F) {
  std::vector<BasicBlock *> Traversal = reversePostOrder(F);
  std::vector<AllocaInst *> AllocaInstructions;
  std::vector<ReturnInst *> RetInstructions;
  std::set<Value *> AllocaOperands;
  LLVMContext &Ctx = F.getContext();
  IRBuilder<> Builder(Ctx);
  Module *Mod = F.getParent();
  DataLayout *DL = new DataLayout(Mod);

  for (auto *Block : Traversal) {
    for (auto &Ins : *Block) {
      if (AllocaInst *Ai = dyn_cast<AllocaInst>(&Ins)) {
        AllocaInstructions.push_back(Ai);
        AllocaOperands.insert((Value *)Ai);
        continue;
      }
      if (ReturnInst *Ri = dyn_cast<ReturnInst>(&Ins)) {
        RetInstructions.push_back(Ri);
        continue;
      }
    }
  }
  std::set<Value *> UnsafeAllocaOperands;
  for (auto *Block : Traversal) {
    for (auto &Ins : *Block) {
      if (CallInst *Ci = dyn_cast<CallInst>(&Ins)) {
        Function *CalledFunction = Ci->getCalledFunction();
        if (CalledFunction && !isLibraryCall(Ci, this->TLI)) {
          for (auto &Arg : CalledFunction->args()) {
            if (Arg.getType()->isPointerTy()) {
              Value *BaseOperand =
                  walkBackAddressComputation(Ci->getArgOperand(Arg.getArgNo()));
              if (AllocaOperands.count(BaseOperand) > 0) {
                PRINT("Call instruction ");
                PRINT(*Ci);
                PRINT("Operand ");
                PRINT(Ci->getArgOperand(Arg.getArgNo()));
                PRINT("Translates to: ");
                PRINT(BaseOperand->getName());
                ENDL();
                UnsafeAllocaOperands.insert(BaseOperand);
              }
            }
          }
        }
        continue;
      }

      if (StoreInst *Si = dyn_cast<StoreInst>(&Ins)) {
        Value *StoredValue = Si->getValueOperand();
        if (StoredValue->getType()->isPointerTy()) {
          Value *BaseOperand = walkBackAddressComputation(StoredValue);
          if (AllocaOperands.count(BaseOperand) > 0) {
            PRINT("Store instruction ");
            PRINT(*Si);
            PRINT("Operand ");
            PRINT(Si->getPointerOperand());
            PRINT("Translates to: ");
            PRINT(BaseOperand->getName());
            ENDL();
            UnsafeAllocaOperands.insert(BaseOperand);
          }
        }
      }
    }
  }
  for (AllocaInst *AlocInst : AllocaInstructions) {
    if (UnsafeAllocaOperands.count(AlocInst) == 0) {
      continue;
    }
    Builder.SetInsertPoint(AlocInst);
    Value *AllocSize = NULL;
    if (AlocInst->isStaticAlloca()) {
      uint64_t SizeBytes = DL->getTypeAllocSize(AlocInst->getAllocatedType());
      AllocSize = ConstantInt::get(Type::getInt64Ty(Ctx), SizeBytes);

    } else {
      Value *ArrayLength = AlocInst->getArraySize();
      uint64_t TypeSizeBytes =
          DL->getTypeAllocSize(AlocInst->getAllocatedType());
      AllocSize = Builder.CreateMul(
          ArrayLength, ConstantInt::get(Type::getInt64Ty(Ctx), TypeSizeBytes));
    }

    Function *MallocFunc = Mod->getFunction("mymalloc");
    if (!MallocFunc) {
      FunctionType *MallocFuncType = FunctionType::get(
          Builder.getInt8PtrTy(), {Builder.getInt64Ty()}, false);
      MallocFunc = Function::Create(MallocFuncType, Function::ExternalLinkage,
                                    "mymalloc", Mod);
    }
    CallInst *MallocCall = Builder.CreateCall(MallocFunc, AllocSize);
    Value *MallocCast = Builder.CreateBitCast(MallocCall, AlocInst->getType());
    AlocInst->replaceAllUsesWith(MallocCast);
    AlocInst->eraseFromParent();
    BitCastInst *BT = cast<BitCastInst>(MallocCast);
    Instruction *LastDominated = lastDominatedInstruction(BT);
    if (!LastDominated) {
      PRINT("YEH KYA HUAAAAA\n");
    } else {
      PRINT("SAHI HUAA\n");
    }
    Builder.SetInsertPoint(LastDominated);

    Function *FreeFunc = Mod->getFunction("myfree");
    if (!FreeFunc) {
      FunctionType *FreeFuncType = FunctionType::get(
          Builder.getInt8PtrTy(), {Builder.getInt8PtrTy()}, false);
      FreeFunc = Function::Create(FreeFuncType, Function::ExternalLinkage,
                                  "myfree", Mod);
    }
    Value *MallocValue = MallocCall;

    Type *AccessedPtrType = Type::getInt8PtrTy(Ctx);
    if (MallocValue->getType() != AccessedPtrType) {
      MallocValue = Builder.CreateBitCast(MallocValue, AccessedPtrType);
    }
    Builder.CreateCall(FreeFunc, MallocValue);
  }
  delete DL;
  PRINT("ALLOCA TO MYMALLOC PASS DONE\n");
}
void MemSafe::addCheckForOOB(Instruction *I, Value *Base, Value *Accessed) {

  PRINT("ADDING CHECK TO ");
  PRINT(*I);
  ENDL();
  LLVMContext &Context = I->getContext();
  Module *M = I->getModule();
  IRBuilder<> Builder(Context);

  Function *IsAddrOobFunc = M->getFunction("isAddrOOB");
  if (!IsAddrOobFunc) {
    PRINT("EHH?\n");
    FunctionType *IsAddrOobType = FunctionType::get(
        Type::getInt32Ty(Context),
        {Type::getInt8PtrTy(Context), Type::getInt8PtrTy(Context)}, false);
    IsAddrOobFunc = Function::Create(IsAddrOobType, Function::ExternalLinkage,
                                     "isAddrOOB", M);
  }
  Builder.SetInsertPoint(I);
  Type *BasePtrType = Type::getInt8PtrTy(Context);
  if (Base->getType() != BasePtrType) {
    Base = Builder.CreateBitCast(Base, BasePtrType);
  }

  // Cast Accessed to the appropriate type
  Type *AccessedPtrType = Type::getInt8PtrTy(Context);
  if (Accessed->getType() != AccessedPtrType) {
    Accessed = Builder.CreateBitCast(Accessed, AccessedPtrType);
  }
  Value *Args[] = {Base, Accessed};
  PRINT("CALLING isAddrOOB\n");
  CallInst *IsAddrOOBCall = Builder.CreateCall(IsAddrOobFunc, Args);
  Value *Condition = Builder.CreateICmpNE(
      IsAddrOOBCall, ConstantInt::get(Type::getInt32Ty(Context), 0));

  Instruction *ICMP = cast<Instruction>(Condition);
  BasicBlock *BB = I->getParent();
  BasicBlock *FailureBB =
      BasicBlock::Create(BB->getContext(), "OOBcheck.failure", BB->getParent());
  IRBuilder<> FailureBuilder(FailureBB);
  FailureBuilder.CreateCall(
      Intrinsic::getDeclaration(BB->getParent()->getParent(), Intrinsic::trap));
  if (Function *Func = BB->getParent()) {
    Type *ReturnType = Func->getReturnType();
    if (ReturnType->isVoidTy()) {
      ReturnInst::Create(BB->getContext(), FailureBB);
    } else {
      Value *DefaultValue = UndefValue::get(ReturnType);
      ReturnInst::Create(BB->getContext(), DefaultValue, FailureBB);
    }
  }
  SplitBlockAndInsertIfThen(ICMP, ICMP->getNextNode(), false, nullptr, nullptr,
                            nullptr, FailureBB);
}
void MemSafe::noOutOfBoundsPass(Function &F) {

  std::vector<BasicBlock *> Traversal = reversePostOrder(F);
  std::vector<CallInst *> CallInstructions;
  std::vector<ReturnInst *> RetInstructions;
  std::vector<StoreInst *> StoreInstructions;
  for (auto *Block : Traversal) {
    for (auto &Ins : *Block) {
      if (auto *CI = dyn_cast<CallInst>(&Ins)) {
        CallInstructions.push_back(CI);
      } else if (auto *RI = dyn_cast<ReturnInst>(&Ins)) {
        RetInstructions.push_back(RI);
      } else if (auto *SI = dyn_cast<StoreInst>(&Ins)) {
        StoreInstructions.push_back(SI);
      }
    }
  }
  for (CallInst *CI : CallInstructions) {
    if (isLibraryCall(CI, this->TLI)) {
      continue;
    }
    Function *CalledFunction = CI->getCalledFunction();
    for (auto &Arg : CalledFunction->args()) {
      if (Arg.getType()->isPointerTy()) {
        Value *BaseOperand =
            walkBackAddressComputation(CI->getArgOperand(Arg.getArgNo()));
        addCheckForOOB(CI, BaseOperand, CI->getArgOperand(Arg.getArgNo()));
      }
    }
  }

  for (StoreInst *SI : StoreInstructions) {
    Value *StoredValue = SI->getValueOperand();
    if (!(StoredValue->getType()->isPointerTy())) {
      continue;
    }
    Value *BaseOperand = walkBackAddressComputation(StoredValue);
    addCheckForOOB(SI, BaseOperand, StoredValue);
  }

  for (ReturnInst *RI : RetInstructions) {
    if (F.getReturnType() == Type::getVoidTy(F.getContext())) {
      break;
    }
    Value *ReturnValue = RI->getReturnValue();
    if (!ReturnValue->getType()->isPointerTy()) {
      continue;
    }
    Value *BaseOperand = walkBackAddressComputation(ReturnValue);
    addCheckForOOB(RI, BaseOperand, ReturnValue);
  }

  // PRINT("===========BEFORE FREE==========\\n");
  // for (auto *Block : Traversal) {
  //   for (auto &Ins : *Block) {
  //     PRINT(Ins);
  //     ENDL();
  //   }
  // }
  //
  // PRINT("==========BEFORE FREE========\\n");
}
void MemSafe::addCheckForBounds(Instruction *I, Value *Base, Value *Accessed) {
  PRINT("Bounds Check On: ");
  PRINT(*I);
  ENDL();
  LLVMContext &Context = I->getContext();
  Module *M = I->getModule();
  DataLayout *DL = new DataLayout(M);
  IRBuilder<> Builder(Context);

  Function *CheckBoundsFunc = M->getFunction("checkBounds");
  if (!CheckBoundsFunc) {
    FunctionType *CheckBoundsFuncType = FunctionType::get(
        Type::getInt32Ty(Context),
        {Type::getInt8PtrTy(Context), Type::getInt8PtrTy(Context),
         Type::getInt64Ty(Context)},
        false);
    CheckBoundsFunc = Function::Create(
        CheckBoundsFuncType, Function::ExternalLinkage, "checkBounds", M);
  }
  PointerType *PtrType = cast<PointerType>(Accessed->getType());
  if (!PtrType) {
    std::cout << "Accessed Value ptr is not a pointer" << std::endl;
  }
  uint64_t SizeBytes = DL->getTypeAllocSize(PtrType->getElementType());
  ConstantInt *SizeConstant =
      ConstantInt::get(Type::getInt64Ty(Context), SizeBytes);
  Builder.SetInsertPoint(I);
  Type *BasePtrType = Type::getInt8PtrTy(Context);
  if (Base->getType() != BasePtrType) {
    Base = Builder.CreateBitCast(Base, BasePtrType);
  }

  // Cast Accessed to the appropriate type
  Type *AccessedPtrType = Type::getInt8PtrTy(Context);
  if (Accessed->getType() != AccessedPtrType) {
    Accessed = Builder.CreateBitCast(Accessed, AccessedPtrType);
  }
  Value *Args[] = {Base, Accessed, SizeConstant};
  PRINT("CALLING checkBounds\n");
  CallInst *CheckBoundsCall = Builder.CreateCall(CheckBoundsFunc, Args);
  Value *Condition = Builder.CreateICmpNE(
      CheckBoundsCall, ConstantInt::get(Type::getInt32Ty(Context), 0));

  Instruction *ICMP = cast<Instruction>(Condition);
  BasicBlock *BB = I->getParent();
  BasicBlock *FailureBB = BasicBlock::Create(
      BB->getContext(), "Boundcheck.failure", BB->getParent());
  IRBuilder<> FailureBuilder(FailureBB);
  FailureBuilder.CreateCall(
      Intrinsic::getDeclaration(BB->getParent()->getParent(), Intrinsic::trap));
  if (Function *Func = BB->getParent()) {
    Type *ReturnType = Func->getReturnType();
    if (ReturnType->isVoidTy()) {
      ReturnInst::Create(BB->getContext(), FailureBB);
    } else {
      Value *DefaultValue = UndefValue::get(ReturnType);
      ReturnInst::Create(BB->getContext(), DefaultValue, FailureBB);
    }
  }
  SplitBlockAndInsertIfThen(ICMP, ICMP->getNextNode(), false, nullptr, nullptr,
                            nullptr, FailureBB);
  delete DL;
}
void MemSafe::boundsCheck(Function &F) {
  std::vector<BasicBlock *> Traversal = reversePostOrder(F);
  std::vector<StoreInst *> StoreInstructions;
  std::vector<LoadInst *> LoadInstructions;
  std::set<Value *> AllocaOperands;
  LLVMContext &Ctx = F.getContext();
  IRBuilder<> Builder(Ctx);
  Module *Mod = F.getParent();
  DataLayout *DL = new DataLayout(Mod);
  for (auto *Block : Traversal) {
    for (auto &Ins : *Block) {
      if (AllocaInst *Ai = dyn_cast<AllocaInst>(&Ins)) {
        AllocaOperands.insert((Value *)Ai);
        continue;
      }
      if (StoreInst *SI = dyn_cast<StoreInst>(&Ins)) {
        StoreInstructions.push_back(SI);
        continue;
      }
      if (LoadInst *LI = dyn_cast<LoadInst>(&Ins)) {
        LoadInstructions.push_back(LI);
      }
    }
  }

  for (LoadInst *LI : LoadInstructions) {
    Value *LoadedValue = LI->getPointerOperand();
    Value *BaseOperand = walkBackAddressComputation(LoadedValue);
    Value *BaseBase = BaseOperand->stripInBoundsOffsets();
    if (GlobalValue *GV = dyn_cast<GlobalValue>(BaseBase))
      addCheckForBoundsGlobal(LI, BaseBase, LoadedValue);
    else if (AllocaOperands.count(BaseOperand) == 0)
      addCheckForBounds(LI, BaseOperand, LoadedValue);
    else
      addCheckForBoundsStack(LI, BaseOperand, LoadedValue);
  }

  for (StoreInst *SI : StoreInstructions) {
    Value *StoredAt = SI->getPointerOperand();
    Value *BaseOperand = walkBackAddressComputation(StoredAt);
    Value *BaseBase = BaseOperand->stripInBoundsOffsets();
    if (GlobalValue *GV = dyn_cast<GlobalValue>(BaseBase))
      addCheckForBoundsGlobal(SI, BaseBase, StoredAt);
    else if (AllocaOperands.count(BaseOperand) == 0)
      addCheckForBounds(SI, BaseOperand, StoredAt);
    else
      addCheckForBoundsStack(SI, BaseOperand, StoredAt);
  }
}

void MemSafe::addCheckForBoundsGlobal(Instruction *I, Value *Base,
                                      Value *Accessed) {

  Module *M = I->getModule();
  DataLayout *DL = new DataLayout(I->getModule());
  LLVMContext &Context = I->getContext();
  IRBuilder<> Builder(I);
  GlobalVariable *GV = dyn_cast<GlobalVariable>(Base);
  Type *VarType = GV->getValueType();
  auto SizeBytes = DL->getTypeAllocSize(VarType);
  Function *CheckBoundsStackFunc = M->getFunction("checkBoundsStack");
  if (!CheckBoundsStackFunc) {
    FunctionType *CheckBoundsFuncType = FunctionType::get(
        Type::getInt32Ty(Context),
        {Type::getInt8PtrTy(Context), Type::getInt8PtrTy(Context),
         Type::getInt64Ty(Context), Type::getInt64Ty(Context)},
        false);
    CheckBoundsStackFunc = Function::Create(
        CheckBoundsFuncType, Function::ExternalLinkage, "checkBoundsStack", M);
  }
  PointerType *PtrType = cast<PointerType>(Accessed->getType());
  if (!PtrType) {
    std::cout << "Accessed Value ptr is not a pointer" << std::endl;
  }
  ConstantInt *SizeConstant =
      ConstantInt::get(Type::getInt64Ty(Context), SizeBytes);
  Builder.SetInsertPoint(I);
  Type *BasePtrType = Type::getInt8PtrTy(Context);
  if (Base->getType() != BasePtrType) {
    Base = Builder.CreateBitCast(Base, BasePtrType);
  }

  // Cast Accessed to the appropriate type
  Type *AccessedPtrType = Type::getInt8PtrTy(Context);
  if (Accessed->getType() != AccessedPtrType) {
    Accessed = Builder.CreateBitCast(Accessed, AccessedPtrType);
  }
  Value *Args[] = {Base, Accessed, SizeConstant, SizeConstant};
  PRINT("CALLING checkBoundsStack\n");
  CallInst *CheckBoundsCall = Builder.CreateCall(CheckBoundsStackFunc, Args);
  Value *Condition = Builder.CreateICmpNE(
      CheckBoundsCall, ConstantInt::get(Type::getInt32Ty(Context), 0));

  Instruction *ICMP = cast<Instruction>(Condition);
  BasicBlock *BB = I->getParent();
  BasicBlock *FailureBB = BasicBlock::Create(
      BB->getContext(), "Boundcheck.failure", BB->getParent());
  IRBuilder<> FailureBuilder(FailureBB);
  FailureBuilder.CreateCall(
      Intrinsic::getDeclaration(BB->getParent()->getParent(), Intrinsic::trap));
  if (Function *Func = BB->getParent()) {
    Type *ReturnType = Func->getReturnType();
    if (ReturnType->isVoidTy()) {
      ReturnInst::Create(BB->getContext(), FailureBB);
    } else {
      Value *DefaultValue = UndefValue::get(ReturnType);
      ReturnInst::Create(BB->getContext(), DefaultValue, FailureBB);
    }
  }
  SplitBlockAndInsertIfThen(ICMP, ICMP->getNextNode(), false, nullptr, nullptr,
                            nullptr, FailureBB);
  delete DL;
}

void MemSafe::addCheckForBoundsStack(Instruction *I, Value *Base,
                                     Value *Accessed) {
  AllocaInst *AlocInst = dyn_cast<AllocaInst>(Base);
  Module *M = I->getModule();
  DataLayout *DL = new DataLayout(I->getModule());
  LLVMContext &Context = I->getContext();
  IRBuilder<> Builder(I);
  Value *AllocSize = NULL;
  if (AlocInst->isStaticAlloca()) {
    uint64_t SizeBytes = DL->getTypeAllocSize(AlocInst->getAllocatedType());
    AllocSize = ConstantInt::get(Type::getInt64Ty(Context), SizeBytes);
  } else {
    Value *ArrayLength = AlocInst->getArraySize();
    uint64_t TypeSizeBytes = DL->getTypeAllocSize(AlocInst->getAllocatedType());
    AllocSize = Builder.CreateMul(
        ArrayLength,
        ConstantInt::get(Type::getInt64Ty(Context), TypeSizeBytes));
  }
  Function *CheckBoundsStackFunc = M->getFunction("checkBoundsStack");
  if (!CheckBoundsStackFunc) {
    FunctionType *CheckBoundsFuncType = FunctionType::get(
        Type::getInt32Ty(Context),
        {Type::getInt8PtrTy(Context), Type::getInt8PtrTy(Context),
         Type::getInt64Ty(Context), Type::getInt64Ty(Context)},
        false);
    CheckBoundsStackFunc = Function::Create(
        CheckBoundsFuncType, Function::ExternalLinkage, "checkBoundsStack", M);
  }
  PointerType *PtrType = cast<PointerType>(Accessed->getType());
  if (!PtrType) {
    std::cout << "Accessed Value ptr is not a pointer" << std::endl;
  }
  uint64_t SizeBytes = DL->getTypeAllocSize(PtrType->getElementType());
  ConstantInt *SizeConstant =
      ConstantInt::get(Type::getInt64Ty(Context), SizeBytes);
  Builder.SetInsertPoint(I);
  Type *BasePtrType = Type::getInt8PtrTy(Context);
  if (Base->getType() != BasePtrType) {
    Base = Builder.CreateBitCast(Base, BasePtrType);
  }

  // Cast Accessed to the appropriate type
  Type *AccessedPtrType = Type::getInt8PtrTy(Context);
  if (Accessed->getType() != AccessedPtrType) {
    Accessed = Builder.CreateBitCast(Accessed, AccessedPtrType);
  }
  Value *Args[] = {Base, Accessed, SizeConstant, AllocSize};
  PRINT("CALLING checkBoundsStack\n");
  CallInst *CheckBoundsCall = Builder.CreateCall(CheckBoundsStackFunc, Args);
  Value *Condition = Builder.CreateICmpNE(
      CheckBoundsCall, ConstantInt::get(Type::getInt32Ty(Context), 0));

  Instruction *ICMP = cast<Instruction>(Condition);
  BasicBlock *BB = I->getParent();
  BasicBlock *FailureBB = BasicBlock::Create(
      BB->getContext(), "Boundcheck.failure", BB->getParent());
  IRBuilder<> FailureBuilder(FailureBB);
  FailureBuilder.CreateCall(
      Intrinsic::getDeclaration(BB->getParent()->getParent(), Intrinsic::trap));
  if (Function *Func = BB->getParent()) {
    Type *ReturnType = Func->getReturnType();
    if (ReturnType->isVoidTy()) {
      ReturnInst::Create(BB->getContext(), FailureBB);
    } else {
      Value *DefaultValue = UndefValue::get(ReturnType);
      ReturnInst::Create(BB->getContext(), DefaultValue, FailureBB);
    }
  }
  SplitBlockAndInsertIfThen(ICMP, ICMP->getNextNode(), false, nullptr, nullptr,
                            nullptr, FailureBB);
  delete DL;
}

void MemSafe::writeBarrier(Function &F) {
  std::vector<BasicBlock *> Traversal = reversePostOrder(F);
  std::vector<StoreInst *> StoreInstructions;
  std::set<Value *> AllocaOperands;
  for (auto *Block : Traversal) {
    for (auto &Ins : *Block) {
      if (AllocaInst *Ai = dyn_cast<AllocaInst>(&Ins)) {
        AllocaOperands.insert((Value *)Ai);
        continue;
      }
      if (StoreInst *SI = dyn_cast<StoreInst>(&Ins)) {
        StoreInstructions.push_back(SI);
        continue;
      }
    }
  }

  for (StoreInst *SI : StoreInstructions) {
    Value *StoredAt = SI->getPointerOperand();
    Value *BaseOperand = walkBackAddressComputation(StoredAt);
    Value *BaseBase = BaseOperand->stripInBoundsOffsets();
    PRINT(isa<GlobalVariable>(BaseBase));
    if (isa<GlobalVariable>(BaseBase))
      addWriteBarrierStack(SI, StoredAt, SI->getValueOperand());
    else if (AllocaOperands.count(BaseOperand) == 0)
      addWriteBarrier(SI, StoredAt, SI->getValueOperand());
    else
      addWriteBarrierStack(SI, StoredAt, SI->getValueOperand());
  }
}

void MemSafe::addWriteBarrier(Instruction *I, Value *Dst, Value *Src) {
  PRINT("writeBarrier On: ");
  PRINT(*I);
  ENDL();
  LLVMContext &Context = I->getContext();
  Module *M = I->getModule();
  IRBuilder<> Builder(Context);

  Function *WriteBarrierFunc = M->getFunction("writeBarrier");
  if (!WriteBarrierFunc) {
    FunctionType *WriteBarrierFuncType = FunctionType::get(
        Type::getInt32Ty(Context),
        {Type::getInt8PtrTy(Context), Type::getInt8PtrTy(Context)}, false);
    WriteBarrierFunc = Function::Create(
        WriteBarrierFuncType, Function::ExternalLinkage, "writeBarrier", M);
  }
  Builder.SetInsertPoint(I);
  Type *BasePtrType = Type::getInt8PtrTy(Context);
  if (Dst->getType() != BasePtrType) {
    Dst = Builder.CreateBitCast(Dst, BasePtrType);
  }

  Type *AccessedPtrType = Type::getInt8PtrTy(Context);
  PointerType *PtrType = dyn_cast<PointerType>(Src->getType());
  if (!PtrType) {
    std::cout << "Accessed Value ptr is not a pointer" << std::endl;
  }
  if (PtrType && Src->getType() != AccessedPtrType) {
    Src = Builder.CreateBitCast(Src, AccessedPtrType);
  }
  if (!PtrType && Src->getType()->isIntegerTy()) {
    Src = Builder.CreateIntToPtr(Src, AccessedPtrType);
  }

  PRINT("HERE\n");
  Value *Args[] = {Dst, Src};
  PRINT("CALLING writeBarrier\n");
  CallInst *WriteBarrierCall = Builder.CreateCall(WriteBarrierFunc, Args);
  Value *Condition = Builder.CreateICmpNE(
      WriteBarrierCall, ConstantInt::get(Type::getInt32Ty(Context), 0));

  Instruction *ICMP = cast<Instruction>(Condition);
  BasicBlock *BB = I->getParent();
  BasicBlock *FailureBB = BasicBlock::Create(
      BB->getContext(), "WriteBarrier.failure", BB->getParent());
  IRBuilder<> FailureBuilder(FailureBB);
  FailureBuilder.CreateCall(
      Intrinsic::getDeclaration(BB->getParent()->getParent(), Intrinsic::trap));
  if (Function *Func = BB->getParent()) {
    Type *ReturnType = Func->getReturnType();
    if (ReturnType->isVoidTy()) {
      ReturnInst::Create(BB->getContext(), FailureBB);
    } else {
      Value *DefaultValue = UndefValue::get(ReturnType);
      ReturnInst::Create(BB->getContext(), DefaultValue, FailureBB);
    }
  }
  SplitBlockAndInsertIfThen(ICMP, ICMP->getNextNode(), false, nullptr, nullptr,
                            nullptr, FailureBB);
}

void MemSafe::addWriteBarrierStack(Instruction *I, Value *Dst, Value *Src) {
  PRINT("Calling addWriteBarrierStack on: ");
  PRINT(*I);
  ENDL();
  PRINT("Is Type Struct: ");
  Value *BaseOperand = walkBackAddressComputation(Dst);
  BaseOperand = BaseOperand->stripInBoundsOffsets();
  Type *BaseType = BaseOperand->getType()->getPointerElementType();
  PRINT(BaseType->isStructTy());
  ENDL();
  PRINT("OFFSET FROM BASE : ");
  DataLayout *DL = new DataLayout(I->getModule());
  unsigned BitWidth = DL->getIndexTypeSizeInBits(Dst->getType());
  APInt Offset(BitWidth, 0);
  Value *Off = Dst->stripAndAccumulateInBoundsConstantOffsets(*DL, Offset);
  PRINT(Offset);
  PRINT("Value * :");
  PRINT(Off->getName());
  ENDL();
  if (!BaseType->isStructTy()) {
    return;
  }
  StructType *StructTy = dyn_cast<StructType>(BaseType);
  APInt BitMask(StructTy->getNumElements(), 0);
  for (unsigned i = 0; i < StructTy->getNumElements(); ++i) {
    if (StructTy->getElementType(i)->isPointerTy()) {
      BitMask.setBit(i);
    }
  }
  PRINT("ADDING DYN CHECK\n");
  LLVMContext &Context = I->getContext();
  Module *M = I->getModule();
  IRBuilder<> Builder(Context);

  Function *WriteBarrierFunc = M->getFunction("writeBarrierStack");
  if (!WriteBarrierFunc) {
    FunctionType *WriteBarrierFuncType = FunctionType::get(
        Type::getInt32Ty(Context),
        {Type::getInt8PtrTy(Context), Type::getInt8PtrTy(Context),
         Type::getInt8PtrTy(Context), Type::getInt64Ty(Context)},
        false);
    WriteBarrierFunc =
        Function::Create(WriteBarrierFuncType, Function::ExternalLinkage,
                         "writeBarrierStack", M);
  }
  Builder.SetInsertPoint(I);
  Type *BasePtrType = Type::getInt8PtrTy(Context);
  if (Dst->getType() != BasePtrType) {
    Dst = Builder.CreateBitCast(Dst, BasePtrType);
  }

  if (BaseOperand->getType() != BasePtrType) {
    BaseOperand = Builder.CreateBitCast(BaseOperand, BasePtrType);
  }

  Type *AccessedPtrType = Type::getInt8PtrTy(Context);
  PointerType *PtrType = dyn_cast<PointerType>(Src->getType());
  if (!PtrType) {
    std::cout << "Accessed Value ptr is not a pointer" << std::endl;
  }
  if (PtrType && Src->getType() != AccessedPtrType) {
    Src = Builder.CreateBitCast(Src, AccessedPtrType);
  }
  if (!PtrType && Src->getType()->isIntegerTy()) {
    Src = Builder.CreateIntToPtr(Src, AccessedPtrType);
  }
  Type *Int64Ty = Type::getInt64Ty(Builder.getContext());
  Value *BitMaskValue = Builder.getInt(APInt(64, BitMask.getZExtValue()));

  PRINT("HERE\n");
  Value *Args[] = {BaseOperand, Dst, Src, BitMaskValue};
  PRINT("CALLING writeBarrierStack\n");
  CallInst *WriteBarrierCall = Builder.CreateCall(WriteBarrierFunc, Args);
  Value *Condition = Builder.CreateICmpNE(
      WriteBarrierCall, ConstantInt::get(Type::getInt32Ty(Context), 0));

  Instruction *ICMP = cast<Instruction>(Condition);
  BasicBlock *BB = I->getParent();
  BasicBlock *FailureBB = BasicBlock::Create(
      BB->getContext(), "WriteBarrierStack.failure", BB->getParent());
  IRBuilder<> FailureBuilder(FailureBB);
  FailureBuilder.CreateCall(
      Intrinsic::getDeclaration(BB->getParent()->getParent(), Intrinsic::trap));
  if (Function *Func = BB->getParent()) {
    Type *ReturnType = Func->getReturnType();
    if (ReturnType->isVoidTy()) {
      ReturnInst::Create(BB->getContext(), FailureBB);
    } else {
      Value *DefaultValue = UndefValue::get(ReturnType);
      ReturnInst::Create(BB->getContext(), DefaultValue, FailureBB);
    }
  }
  SplitBlockAndInsertIfThen(ICMP, ICMP->getNextNode(), false, nullptr, nullptr,
                            nullptr, FailureBB);
}
char MemSafe::ID = 0;
static RegisterPass<MemSafe> X("memsafe", "Memory Safety Pass",
                               false /* Only looks at CFG */,
                               false /* Analysis Pass */);

static RegisterStandardPasses Y(PassManagerBuilder::EP_EarlyAsPossible,
                                [](const PassManagerBuilder &Builder,
                                   legacy::PassManagerBase &PM) {
                                  PM.add(new MemSafe());
                                });
