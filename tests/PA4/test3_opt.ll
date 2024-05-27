; ModuleID = 'test3.bc'
source_filename = "test3.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.List = type { i32*, %struct.List* }

@node = common dso_local local_unnamed_addr global %struct.List zeroinitializer, align 8
@str = private unnamed_addr constant [24 x i8] c"Usage:: <size> <offset>\00", align 1

; Function Attrs: nofree noinline norecurse nounwind uwtable writeonly
define dso_local void @bar(i32* nocapture %arr, i32 %offset) local_unnamed_addr #0 {
entry:
  %idxprom = sext i32 %offset to i64
  %arrayidx = getelementptr inbounds i32, i32* %arr, i64 %idxprom
  %0 = bitcast i32* %arr to i8*
  %1 = bitcast i32* %arrayidx to i8*
  %2 = call i32 @checkBounds(i8* %0, i8* %1, i64 4)
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %Boundcheck.failure, label %4

4:                                                ; preds = %entry
  %5 = bitcast i32* %arrayidx to i8*
  %6 = call i32 @writeBarrier(i8* %5, i8* null)
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %WriteBarrier.failure, label %8

8:                                                ; preds = %4
  store i32 0, i32* %arrayidx, align 4, !tbaa !2
  ret void

Boundcheck.failure:                               ; preds = %entry
  call void @llvm.trap()
  ret void

WriteBarrier.failure:                             ; preds = %4
  call void @llvm.trap()
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32* @allocate_a(i32 %size, i32 %offset) local_unnamed_addr #1 {
entry:
  %conv = sext i32 %size to i64
  %call = tail call i8* @mymalloc(i64 %conv) #6
  %0 = bitcast i8* %call to i32*
  %1 = call i32* @mycast(i8* %call, i64 0, i32 4)
  %idx.ext = sext i32 %offset to i64
  %add.ptr = getelementptr inbounds i32, i32* %0, i64 %idx.ext
  %2 = bitcast i32* %add.ptr to i8*
  %3 = call i32 @isAddrOOB(i8* %call, i8* %2)
  %4 = icmp ne i32 %3, 0
  br i1 %4, label %OOBcheck.failure, label %5

5:                                                ; preds = %entry
  ret i32* %add.ptr

OOBcheck.failure:                                 ; preds = %entry
  call void @llvm.trap()
  ret i32* undef
}

declare dso_local i8* @mymalloc(i64) local_unnamed_addr #2

; Function Attrs: nofree noinline norecurse nounwind uwtable writeonly
define dso_local void @foo(i32* nocapture %arr, i32 %offset) local_unnamed_addr #0 {
entry:
  %idxprom = sext i32 %offset to i64
  %arrayidx = getelementptr inbounds i32, i32* %arr, i64 %idxprom
  %0 = bitcast i32* %arr to i8*
  %1 = bitcast i32* %arrayidx to i8*
  %2 = call i32 @checkBounds(i8* %0, i8* %1, i64 4)
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %Boundcheck.failure, label %4

4:                                                ; preds = %entry
  %5 = bitcast i32* %arrayidx to i8*
  %6 = call i32 @writeBarrier(i8* %5, i8* inttoptr (i32 20 to i8*))
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %WriteBarrier.failure, label %8

8:                                                ; preds = %4
  store i32 20, i32* %arrayidx, align 4, !tbaa !2
  %add = add nsw i32 %offset, 8
  %idxprom1 = sext i32 %add to i64
  %arrayidx2 = getelementptr inbounds i32, i32* %arr, i64 %idxprom1
  %9 = bitcast i32* %arr to i8*
  %10 = bitcast i32* %arrayidx2 to i8*
  %11 = call i32 @isAddrOOB(i8* %9, i8* %10)
  %12 = icmp ne i32 %11, 0
  br i1 %12, label %OOBcheck.failure, label %13

13:                                               ; preds = %8
  tail call void @bar(i32* %arrayidx2, i32 %offset)
  ret void

OOBcheck.failure:                                 ; preds = %8
  call void @llvm.trap()
  ret void

Boundcheck.failure:                               ; preds = %entry
  call void @llvm.trap()
  ret void

WriteBarrier.failure:                             ; preds = %4
  call void @llvm.trap()
  ret void
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #3 {
entry:
  %cmp = icmp eq i32 %argc, 3
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @str, i64 0, i64 0))
  br label %return

if.end:                                           ; preds = %entry
  %call1 = tail call i32 @readArgv(i8** %argv, i32 1) #6
  %mul = shl i32 %call1, 2
  %call3 = tail call i32 @readArgv(i8** %argv, i32 2) #6
  %call4 = tail call i32* @allocate_a(i32 %mul, i32 %call3)
  %add.ptr = getelementptr inbounds i32, i32* %call4, i64 1
  %0 = bitcast i32* %call4 to i8*
  %1 = bitcast i32* %add.ptr to i8*
  %2 = call i32 @isAddrOOB(i8* %0, i8* %1)
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %OOBcheck.failure1, label %4

4:                                                ; preds = %if.end
  %5 = call i32 @checkBoundsStack(i8* bitcast (%struct.List* @node to i8*), i8* bitcast (%struct.List* @node to i8*), i64 16, i64 16)
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %Boundcheck.failure, label %7

7:                                                ; preds = %4
  %8 = bitcast i32* %add.ptr to i8*
  %9 = call i32 @writeBarrierStack(i8* bitcast (%struct.List* @node to i8*), i8* bitcast (%struct.List* @node to i8*), i8* %8, i64 3)
  %10 = icmp ne i32 %9, 0
  br i1 %10, label %WriteBarrierStack.failure, label %11

11:                                               ; preds = %7
  store i32* %add.ptr, i32** getelementptr inbounds (%struct.List, %struct.List* @node, i64 0, i32 0), align 8, !tbaa !6
  %12 = bitcast i32* %call4 to i8*
  %13 = bitcast i32* %add.ptr to i8*
  %14 = call i32 @isAddrOOB(i8* %12, i8* %13)
  %15 = icmp ne i32 %14, 0
  br i1 %15, label %OOBcheck.failure, label %16

16:                                               ; preds = %11
  tail call void @foo(i32* nonnull %add.ptr, i32 %call3)
  br label %return

return:                                           ; preds = %16, %if.then
  ret i32 0

OOBcheck.failure:                                 ; preds = %11
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure1:                                ; preds = %if.end
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure:                               ; preds = %4
  call void @llvm.trap()
  ret i32 undef

WriteBarrierStack.failure:                        ; preds = %7
  call void @llvm.trap()
  ret i32 undef
}

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #4

declare i32 @checkBounds(i8*, i8*, i64)

; Function Attrs: cold noreturn nounwind
declare void @llvm.trap() #5

declare i32 @writeBarrier(i8*, i8*)

declare i32 @isAddrOOB(i8*, i8*)

declare i32 @checkBoundsStack(i8*, i8*, i64, i64)

declare i32 @writeBarrierStack(i8*, i8*, i8*, i64)

declare i32* @mycast(i8*, i64, i32)

attributes #0 = { nofree noinline norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nofree nounwind }
attributes #5 = { cold noreturn nounwind }
attributes #6 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 23fd0cc59a32d9b8e1837ee26b6a88eeea825a95)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"int", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !8, i64 0}
!7 = !{!"List", !8, i64 0, !8, i64 8}
!8 = !{!"any pointer", !4, i64 0}
