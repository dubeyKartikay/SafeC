#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/IR/MDBuilder.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Use.h"
#include "llvm/IR/User.h"
#include "llvm/IR/Value.h"
#include "llvm/Pass.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include <deque>
#include <map>
#include <queue>
#include <set>
#include <stack>
#include <string>
#include <vector>
#define DEBUG

#define safe true
#define unsafe false

#ifdef DEBUG
#define PRINT(x) dbgs() << ((x)) << '\n'
#else
#define PRINT(x)
#endif // DEBUG

using namespace llvm;

typedef std::map<Value *, bool> BBValueMap;
typedef std::map<BasicBlock *, std::map<Value *, bool>> FunctionValueMap;
typedef std::set<Instruction *> InstructionSet;
typedef std::set<Value *> ArgumentsSet;
typedef std::map<BasicBlock *, InstructionSet>
    BBInstructionMap; // store unsafe Instructions for each BB; We need a
                      // refrence to BB to add new Instructions
struct NullCheck : public FunctionPass {
private:
  // DONE
  void processBasicBlock(BasicBlock *, BBValueMap &);
  // DONE
  bool didValMapChange(const FunctionValueMap &, const FunctionValueMap &);
  // TODO
  InstructionSet getOptimizedUnsafeInstructions(
      BasicBlock *, BBValueMap &,
      ArgumentsSet
          &); // coud not come up with a better name, this function identifies
              // the instructions that need a dynamic check and then marks the
              // checked variable as safe for optimization reasons
  void walkBackAddressCompute(CallInst &, BBValueMap &, ArgumentsSet &);
  void walkBackAddressCompute(StoreInst &, BBValueMap &, ArgumentsSet &);
  void walkBackAddressCompute(LoadInst &, BBValueMap &, ArgumentsSet &);

  bool isInstructionUnsafe(Instruction &Ins, BBValueMap &, ArgumentsSet &);
  // DONE
  void applyTransferFunction(Instruction &, BBValueMap &);
  // DONE
  void storeTransferFunction(StoreInst &, BBValueMap &);
  // DONE
  void loadTransferFunction(LoadInst &, BBValueMap &);
  // DOBE
  void callTransferFunction(CallInst &, BBValueMap &);
  // DONE
  void getElementPointerTransferFunction(GetElementPtrInst &, BBValueMap &);
  // DONE
  void genericTransferFunction(Instruction &Ins, BBValueMap &BbVAlMap);
  std::map<Value *, bool>
  meet(BasicBlock *BB,
       std::map<BasicBlock *, std::map<Value *, bool>> BlocksOut);
  std::vector<BasicBlock *> reversePostOrder(Function &F);

  // DONE
  BBInstructionMap dataFlowAnalysis(Function &F);
  // TODO
  void addDynamicChecks(BBInstructionMap &);

public:
  static char ID;
  NullCheck() : FunctionPass(ID) {}
  bool runOnFunction(Function &F) override {
    dbgs() << ("running nullcheck pass on: " + F.getName()) << "\n";
    BBInstructionMap BBUnsafeInstructionMap = dataFlowAnalysis(F);
    dbgs() << "Optimized Unsafe Instructions:" << '\n';
    for (auto &iter : BBUnsafeInstructionMap) {
      for (auto &iter2 : iter.second) {
        dbgs() << *iter2 << '\n';
      }
    }
    PRINT("===== Dynamic Check ======");
    addDynamicChecks(BBUnsafeInstructionMap);
    PRINT("======FINAL IR===========");
    for (auto &BB : F) {
      PRINT(BB.getName());
      for (auto &I : BB) {
        PRINT(I);
      }
    }
    return false;
  }
};
char NullCheck::ID = 0;
static RegisterPass<NullCheck> X("nullcheck", "Null Check Pass",
                                 false /* Only looks at CFG */,
                                 false /* Analysis Pass */);

static RegisterStandardPasses Y(PassManagerBuilder::EP_EarlyAsPossible,
                                [](const PassManagerBuilder &Builder,
                                   legacy::PassManagerBase &PM) {
                                  PM.add(new NullCheck());
                                });
std::map<Value *, bool>
NullCheck::meet(BasicBlock *BB,
                std::map<BasicBlock *, std::map<Value *, bool>> BlocksOut) {
  std::map<Value *, bool> IN;
  std::vector<BasicBlock *> Preds;

  // List of Predecessors
  for (BasicBlock *Pred : predecessors(BB)) {
    Preds.push_back(Pred);
  }

  IN = BlocksOut[BB];

  // Performing an AND operation for common elements and union for unique
  // elements
  for (size_t I = 0; I < Preds.size(); I++) {
    for (auto &Var : BlocksOut[Preds[I]]) {
      // dbgs() << Var.first->getName() << " in basic block is initially
      // "<<IN[Var.first]<<"\n";
      if (IN.find(Var.first) != IN.end()) {
        // dbgs() <<Var.first->getName() <<" in predecessor is initially
        // "<<Var.second<<"\n";
        IN[Var.first] = IN[Var.first] && Var.second;
      } else {
        IN[Var.first] = Var.second;
      }
    }
  }
  return IN;
}

BBInstructionMap NullCheck::dataFlowAnalysis(Function &F) {
  std::vector<BasicBlock *> Traversal = reversePostOrder(F);

  // Initialisations
  bool Change = true; // To check if an iteration has caused change to the OUT

  /*Map that stores OUT for each block. Each block has a map that
    says if a variable is safe or not safe
  */
  std::map<BasicBlock *, std::map<Value *, bool>> BlocksOut;
  BBInstructionMap BBUnsafeInstructionMap;
  ArgumentsSet AllocaOperands;
  // Initialising all the OUTs
  for (BasicBlock *BB : Traversal) {
    std::map<Value *, bool> OUT;
    for (auto Ii = BB->begin(); Ii != BB->end(); ++Ii) {
      Instruction *Ip = &(*Ii);

      for (auto &Op : Ip->operands()) {
        Value *Operand = &(*Op);
        if (CallInst *Ci = dyn_cast<CallInst>(Ip)) {
          continue;
        }
        if (AllocaInst *Ci = dyn_cast<AllocaInst>(Ip)) {
          AllocaOperands.insert(Ci);
          continue;
        }
        if (BranchInst *Ci = dyn_cast<BranchInst>(Ip)) {
          continue;
        }
        if (ReturnInst *Ci = dyn_cast<ReturnInst>(Ip)) {
          continue;
        }
        if (Argument *Arg = dyn_cast<Argument>(Operand)) {
          OUT[Operand] = unsafe;
        } else if (GlobalValue *GV = dyn_cast<GlobalValue>(Operand)) {
          if (Function *F = dyn_cast<Function>(GV)) {
            OUT[Operand] = safe;
          } else {
            OUT[Operand] = unsafe;
          }
        } else {
          OUT[Operand] = safe;
        }
      }
      if (StoreInst *Ci = dyn_cast<StoreInst>(Ip)) {
        continue;
      }
      if (BranchInst *Ci = dyn_cast<BranchInst>(Ip)) {
        continue;
      }
      if (ReturnInst *Ci = dyn_cast<ReturnInst>(Ip)) {
        continue;
      }
      Value *ReturnValue = Ip;
      OUT[ReturnValue] = safe;
    }
    BlocksOut[BB] = OUT;
  }

  while (Change) {
    FunctionValueMap Initial = BlocksOut;
    for (BasicBlock *BB : Traversal) {
      BBValueMap BbValMap = meet(BB, BlocksOut);
      processBasicBlock(BB, BbValMap);
      BBUnsafeInstructionMap[BB] =
          getOptimizedUnsafeInstructions(BB, BbValMap, AllocaOperands);
      BlocksOut[BB] = BbValMap;
    }
    Change = Change && didValMapChange(Initial, BlocksOut);
  }
  return BBUnsafeInstructionMap;
}
/*Function for traversal of blocks. It ensures that all predecessors are
  visited before visiting a particular block.
*/
std::vector<BasicBlock *> NullCheck::reversePostOrder(Function &F) {
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
void NullCheck::processBasicBlock(BasicBlock *BB, BBValueMap &BbVAlMap) {
  for (Instruction &Instruction : *BB) {
    applyTransferFunction(Instruction, BbVAlMap);
  }
}

void NullCheck::applyTransferFunction(Instruction &Ins, BBValueMap &BbValMap) {
  if (LoadInst *Li = dyn_cast<LoadInst>(&Ins)) {
    loadTransferFunction(*Li, BbValMap);
    return;
  }

  if (StoreInst *Si = dyn_cast<StoreInst>(&Ins)) {
    storeTransferFunction(*Si, BbValMap);
    return;
  }
  if (CallInst *Ci = dyn_cast<CallInst>(&Ins)) {
    callTransferFunction(*Ci, BbValMap);
    return;
  }
  if (GetElementPtrInst *Gepi = dyn_cast<GetElementPtrInst>(&Ins)) {
    getElementPointerTransferFunction(*Gepi, BbValMap);
    return;
  }

  if (BitCastInst *Biti = dyn_cast<BitCastInst>(&Ins)) {
    genericTransferFunction(*Biti, BbValMap);
    return;
  }
  Value *Ret = &Ins;
  BbValMap[Ret] = safe;
}

void NullCheck::getElementPointerTransferFunction(GetElementPtrInst &GetElePtr,
                                                  BBValueMap &BbValMap) {
  Value &ReturnVal = GetElePtr;
  Value *Pointer = GetElePtr.getPointerOperand();
  BbValMap[&ReturnVal] = BbValMap[Pointer];
}

void NullCheck::loadTransferFunction(LoadInst &LoadInst, BBValueMap &BbValMap) {
  Value &ReturnVal = LoadInst;
  Value *Pointer = LoadInst.getPointerOperand();
  BbValMap[&ReturnVal] = BbValMap[Pointer];
}

void NullCheck::storeTransferFunction(StoreInst &StoreInst,
                                      BBValueMap &BbValMap) {
  Value *ReturnVal = StoreInst.getPointerOperand();
  Value *Pointer = StoreInst.getValueOperand();
  // if(Function * F = dyn_cast<Function>(ReturnVal)){
  //   PRINT(ReturnVal->getName());
  //   PRINT("IS A FUNCTION");
  // }
  if (Constant *C = dyn_cast<Constant>(Pointer)) {
    if (C->isNullValue()) {
      BbValMap[ReturnVal] = unsafe;
      return;
    }
  }
  BbValMap[ReturnVal] = BbValMap[Pointer];
}

void NullCheck::genericTransferFunction(Instruction &Ins,
                                        BBValueMap &BbVAlMap) {
  bool IsSafe = safe;
  for (auto &Op : Ins.operands()) {
    Value *OperandVal = &(*Op);
    IsSafe = IsSafe && BbVAlMap[OperandVal];
  }
  Value *ReturnVal = (Value *)(&Ins);
  BbVAlMap[ReturnVal] = IsSafe;
  if (!IsSafe) {
  }
}

void NullCheck::callTransferFunction(CallInst &CallInst, BBValueMap &BbValMap) {
  Value &ReturnVal = CallInst;
  // StringRef callee_name = CallInst.getCalledFunction()->getName();
  Function *CalleeFunc = CallInst.getCalledFunction();
  if (CalleeFunc) {
    StringRef CalleeName = CalleeFunc->getName();
    if (CalleeName.equals(StringRef("mymalloc"))) {
      BbValMap[&ReturnVal] = safe;
    } else {
      BbValMap[&ReturnVal] = unsafe;
    }
  } else {
    BbValMap[&ReturnVal] = unsafe;
  }
}

bool NullCheck::didValMapChange(const FunctionValueMap &Current,
                                const FunctionValueMap &Previous) {

  // for (auto &Pair : Current) {
  //   Value *Val = Pair.first;
  //   if (Previous.find(Val) == Previous.end() || Previous.find(Val)->second !=
  //   Pair.second) {
  //     return true;
  //   }
  // }
  for (auto &BB : Current) {
    BasicBlock *block = BB.first;
    auto it2 = Previous.find(block);
    if (it2 == Previous.end()) {
      return true;
    }
    auto &ValMap1 = BB.second;
    auto &ValMap2 = it2->second;

    if (ValMap1 != ValMap2) {
      return true;
    }
  }

  return false;
}

void NullCheck::walkBackAddressCompute(CallInst &Si, BBValueMap &BbValMap,
                            ArgumentsSet &AllocaOperands) {
  PRINT(Si);
  Value *PointerOp = Si.getOperand(1);
  if (AllocaOperands.count(PointerOp) > 0) {
    BbValMap[PointerOp] = safe;
    return;
  }
  auto *Li = dyn_cast<LoadInst>(PointerOp);
  if (!Li)
    return;
  auto *LiPointerOp = Li->getPointerOperand();
  if (AllocaOperands.count(LiPointerOp) > 0) {
    BbValMap[LiPointerOp] = safe;
  }
}
void NullCheck::walkBackAddressCompute(StoreInst &Si, BBValueMap &BbValMap,
                            ArgumentsSet &AllocaOperands) {
  PRINT(Si);
  Value *PointerOp = Si.getPointerOperand();
  if (AllocaOperands.count(PointerOp) > 0) {
    BbValMap[PointerOp] = safe;
    return;
  }
  GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(PointerOp);
  if (!GEP) {
    return;
  }
  auto *GEPPointerOp = GEP->getPointerOperand();
  if (AllocaOperands.count(GEPPointerOp) > 0) {
    BbValMap[GEPPointerOp] = safe;
    return;
  }
  auto *Li = dyn_cast<LoadInst>(GEPPointerOp);
  if (!Li)
    return;
  auto *LiPointerOp = Li->getPointerOperand();
  if (AllocaOperands.count(LiPointerOp) > 0) {
    BbValMap[LiPointerOp] = safe;
  }
}

void NullCheck::walkBackAddressCompute(LoadInst &Si, BBValueMap &BbValMap,
                            ArgumentsSet &AllocaOperands) {
  PRINT(Si);
  Value *PointerOp = Si.getPointerOperand();
  if (AllocaOperands.count(PointerOp) > 0) {
    BbValMap[PointerOp] = safe;
    return;
  }
  GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(PointerOp);
  if (!GEP) {
    return;
  }
  auto *GEPPointerOp = GEP->getPointerOperand();
  if (AllocaOperands.count(GEPPointerOp) > 0) {
    BbValMap[GEPPointerOp] = safe;
    return;
  }
  auto *Li = dyn_cast<LoadInst>(GEPPointerOp);
  if (!Li)
    return;
  auto *LiPointerOp = Li->getPointerOperand();
  if (AllocaOperands.count(LiPointerOp) > 0) {
    BbValMap[LiPointerOp] = safe;
  }
}
InstructionSet
NullCheck::getOptimizedUnsafeInstructions(BasicBlock *BB, BBValueMap &BbValMap,
                                          ArgumentsSet &AllocaOperands) {
  InstructionSet UnsafeInstructions;
  for (Instruction &Instruction : *BB) {
    if (isInstructionUnsafe(Instruction, BbValMap, AllocaOperands)) {
      if (auto *Li = dyn_cast<LoadInst>(&Instruction)) {
        walkBackAddressCompute(*Li,BbValMap,AllocaOperands);
      } else if (auto *Si = dyn_cast<StoreInst>(&Instruction)) {
        walkBackAddressCompute(*Si,BbValMap,AllocaOperands);
      }else if (auto *Ci = dyn_cast<CallInst>(&Instruction)) {
        walkBackAddressCompute(*Ci,BbValMap,AllocaOperands);
      }
      UnsafeInstructions.insert(&Instruction);
    }
    applyTransferFunction(Instruction, BbValMap);
  }
  return UnsafeInstructions;
}

bool NullCheck::isInstructionUnsafe(Instruction &Ins, BBValueMap &BbValMap,
                                    ArgumentsSet &AllocaOperands) {
  if (LoadInst *Li = dyn_cast<LoadInst>(&Ins)) {
    auto * IsGlobal =Ins.getModule()->getNamedGlobal(Li->getPointerOperand()->getName());
    return BbValMap[Li->getPointerOperand()] == unsafe &&
           AllocaOperands.find(Li->getPointerOperand()) == AllocaOperands.end() && !IsGlobal;
  }
  if (StoreInst *Si = dyn_cast<StoreInst>(&Ins)) {
    return BbValMap[Si->getPointerOperand()] == unsafe &&
           AllocaOperands.find(Si->getPointerOperand()) == AllocaOperands.end();
  }
  if (auto  *Call = dyn_cast<CallInst>(&Ins)) {
    return Call->isIndirectCall() && BbValMap[(Call->getOperand(1))] == unsafe;
  }
  // if (BitCastInst *Biti = dyn_cast<BitCastInst>(&Ins)) {
  //   return BbValMap[Biti->getOperand(0)] == unsafe;
  // }
  return false;
}

void NullCheck::addDynamicChecks(BBInstructionMap &BBUnsafeInstructionMap) {
  // Collect basic blocks to be split
  std::vector<Instruction *> InstructionsToSplit;

  // Iterate over unsafe instructions
  for (auto &BBUnsafeInstructions : BBUnsafeInstructionMap) {
    for (Instruction *UnsafeInstruction : BBUnsafeInstructions.second) {
      if (auto *Ins = dyn_cast<StoreInst>(UnsafeInstruction)) {
        auto *Operand = Ins->getPointerOperand();
        IRBuilder<> Builder(Ins);
        Value *OperandVal = &(*Operand);
        Value *Condition = Builder.CreateICmpEQ(
            OperandVal,
            ConstantPointerNull::get(cast<PointerType>(OperandVal->getType())));
        Instruction *CheckInst = cast<Instruction>(Condition);

        // Collect the basic block and instruction for later splitting
        InstructionsToSplit.emplace_back(CheckInst);
        Value *ValOperand = Ins->getValueOperand();
        if (ValOperand->getType()->isPointerTy()) {

          IRBuilder<> Builder(Ins);

          Value *Condition = Builder.CreateICmpEQ(
              ValOperand, ConstantPointerNull::get(
                              cast<PointerType>(ValOperand->getType())));

          Instruction *CheckInst = cast<Instruction>(Condition);
          InstructionsToSplit.emplace_back(CheckInst);
        }
      }

      if (auto *Ins = dyn_cast<LoadInst>(UnsafeInstruction)) {
        auto *Operand = Ins->getPointerOperand();
        IRBuilder<> Builder(Ins);
        Value *OperandVal = &(*Operand);
        Value *Condition = Builder.CreateICmpEQ(
            OperandVal,
            ConstantPointerNull::get(cast<PointerType>(OperandVal->getType())));
        Instruction *CheckInst = cast<Instruction>(Condition);

        // Collect the basic block and instruction for later splitting
        InstructionsToSplit.emplace_back(CheckInst);

        Value *ValOperand = Ins;
        if (ValOperand->getType()->isPointerTy()) {

          IRBuilder<> Builder(Ins->getNextNode());

          Value *Condition = Builder.CreateICmpEQ(
              ValOperand, ConstantPointerNull::get(
                              cast<PointerType>(ValOperand->getType())));

          Instruction *CheckInst = cast<Instruction>(Condition);
          InstructionsToSplit.emplace_back(CheckInst);
        }
      }
    }
  }

  for (Instruction *CheckInst : InstructionsToSplit) {

    BasicBlock *BB = CheckInst->getParent();
    BasicBlock *FailureBB =
        BasicBlock::Create(BB->getContext(), "check.failure", BB->getParent());

    IRBuilder<> FailureBuilder(FailureBB);
    FailureBuilder.CreateCall(Intrinsic::getDeclaration(
        BB->getParent()->getParent(), Intrinsic::trap));
    if (Function *Func = BB->getParent()) {
      Type *ReturnType = Func->getReturnType();
      if (ReturnType->isVoidTy()) {
        // Void return type, create RetVoid
        ReturnInst::Create(BB->getContext(), FailureBB);
      } else {
        Value *DefaultValue = UndefValue::get(ReturnType);
        ReturnInst::Create(BB->getContext(), DefaultValue, FailureBB);
      }
    }
    SplitBlockAndInsertIfThen(CheckInst, CheckInst->getNextNode(), false,
                              nullptr, nullptr, nullptr, FailureBB);
  }
}
