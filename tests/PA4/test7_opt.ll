; ModuleID = 'test7.bc'
source_filename = "test7.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.List = type { i32*, %struct.List* }

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

; Function Attrs: nofree noinline norecurse nounwind uwtable
define dso_local void @foo(%struct.List* nocapture readonly %node, i32 %offset) local_unnamed_addr #1 {
entry:
  %arr1 = getelementptr inbounds %struct.List, %struct.List* %node, i64 0, i32 0
  %0 = bitcast %struct.List* %node to i8*
  %1 = bitcast i32** %arr1 to i8*
  %2 = call i32 @checkBounds(i8* %0, i8* %1, i64 8)
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %Boundcheck.failure, label %4

4:                                                ; preds = %entry
  %5 = load i32*, i32** %arr1, align 8, !tbaa !6
  %idxprom = sext i32 %offset to i64
  %arrayidx = getelementptr inbounds i32, i32* %5, i64 %idxprom
  %6 = bitcast i32* %5 to i8*
  %7 = bitcast i32* %arrayidx to i8*
  %8 = call i32 @checkBounds(i8* %6, i8* %7, i64 4)
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %Boundcheck.failure1, label %10

10:                                               ; preds = %4
  %11 = bitcast i32* %arrayidx to i8*
  %12 = call i32 @writeBarrier(i8* %11, i8* inttoptr (i32 20 to i8*))
  %13 = icmp ne i32 %12, 0
  br i1 %13, label %WriteBarrier.failure, label %14

14:                                               ; preds = %10
  store i32 20, i32* %arrayidx, align 4, !tbaa !2
  %add = add nsw i32 %offset, 8
  %idxprom2 = sext i32 %add to i64
  %arrayidx3 = getelementptr inbounds i32, i32* %5, i64 %idxprom2
  %15 = bitcast i32* %5 to i8*
  %16 = bitcast i32* %arrayidx3 to i8*
  %17 = call i32 @isAddrOOB(i8* %15, i8* %16)
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %OOBcheck.failure, label %19

19:                                               ; preds = %14
  tail call void @bar(i32* %arrayidx3, i32 %offset)
  ret void

OOBcheck.failure:                                 ; preds = %14
  call void @llvm.trap()
  ret void

Boundcheck.failure:                               ; preds = %entry
  call void @llvm.trap()
  ret void

Boundcheck.failure1:                              ; preds = %4
  call void @llvm.trap()
  ret void

WriteBarrier.failure:                             ; preds = %10
  call void @llvm.trap()
  ret void
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #2 {
entry:
  %cmp = icmp eq i32 %argc, 3
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @str, i64 0, i64 0))
  br label %return

if.end:                                           ; preds = %entry
  %call1 = tail call i32 @readArgv(i8** %argv, i32 1) #4
  %call2 = tail call i32 @readArgv(i8** %argv, i32 2) #4
  %0 = zext i32 %call1 to i64
  %1 = tail call i8* @llvm.stacksave()
  %2 = mul i64 %0, 4
  %3 = call i8* @mymalloc(i64 %2)
  %4 = bitcast i8* %3 to i32*
  %5 = call i32* @mycast(i8* %3, i64 0, i32 4)
  %vla3 = alloca %struct.List, i64 %0, align 16
  %6 = bitcast %struct.List* %vla3 to i8*
  %conv = sext i32 %call1 to i64
  %mul = shl nsw i64 %conv, 4
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 %6, i8 0, i64 %mul, i1 false)
  %add = add nsw i32 %call2, 10
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds i32, i32* %4, i64 %idxprom
  %idxprom4 = sext i32 %call2 to i64
  %arr = getelementptr inbounds %struct.List, %struct.List* %vla3, i64 %idxprom4, i32 0
  %7 = bitcast i32* %arrayidx to i8*
  %8 = call i32 @isAddrOOB(i8* %3, i8* %7)
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %OOBcheck.failure1, label %10

10:                                               ; preds = %if.end
  %11 = mul i64 %0, 16
  %12 = bitcast %struct.List* %vla3 to i8*
  %13 = bitcast i32** %arr to i8*
  %14 = call i32 @checkBoundsStack(i8* %12, i8* %13, i64 8, i64 %11)
  %15 = icmp ne i32 %14, 0
  br i1 %15, label %Boundcheck.failure4, label %16

16:                                               ; preds = %10
  %17 = bitcast i32** %arr to i8*
  %18 = bitcast %struct.List* %vla3 to i8*
  %19 = bitcast i32* %arrayidx to i8*
  %20 = call i32 @writeBarrierStack(i8* %18, i8* %17, i8* %19, i64 3)
  %21 = icmp ne i32 %20, 0
  br i1 %21, label %WriteBarrierStack.failure, label %22

22:                                               ; preds = %16
  store i32* %arrayidx, i32** %arr, align 16, !tbaa !6
  %call6 = call i32 @rand() #4
  %rem = srem i32 %call6, %call1
  %idxprom7 = sext i32 %rem to i64
  %arr9 = getelementptr inbounds %struct.List, %struct.List* %vla3, i64 %idxprom7, i32 0
  %23 = mul i64 %0, 16
  %24 = bitcast %struct.List* %vla3 to i8*
  %25 = bitcast i32** %arr9 to i8*
  %26 = call i32 @checkBoundsStack(i8* %24, i8* %25, i64 8, i64 %23)
  %27 = icmp ne i32 %26, 0
  br i1 %27, label %Boundcheck.failure, label %28

28:                                               ; preds = %22
  %29 = load i32*, i32** %arr9, align 16, !tbaa !6
  %tobool = icmp eq i32* %29, null
  br i1 %tobool, label %cleanup, label %if.then10

if.then10:                                        ; preds = %28
  %arr12 = getelementptr inbounds %struct.List, %struct.List* %vla3, i64 0, i32 0
  %30 = mul i64 %0, 16
  %31 = bitcast %struct.List* %vla3 to i8*
  %32 = bitcast i32** %arr12 to i8*
  %33 = call i32 @checkBoundsStack(i8* %31, i8* %32, i64 8, i64 %30)
  %34 = icmp ne i32 %33, 0
  br i1 %34, label %Boundcheck.failure2, label %35

35:                                               ; preds = %if.then10
  %36 = load i32*, i32** %arr12, align 16, !tbaa !6
  %37 = bitcast i32* %36 to i8*
  %38 = bitcast i32* %36 to i8*
  %39 = call i32 @checkBounds(i8* %37, i8* %38, i64 4)
  %40 = icmp ne i32 %39, 0
  br i1 %40, label %Boundcheck.failure3, label %41

41:                                               ; preds = %35
  %42 = load i32, i32* %36, align 4, !tbaa !2
  %43 = call i32 @isAddrOOB(i8* %3, i8* %3)
  %44 = icmp ne i32 %43, 0
  br i1 %44, label %OOBcheck.failure, label %45

45:                                               ; preds = %41
  %46 = call i8* @myfree(i8* %3)
  br label %cleanup

cleanup:                                          ; preds = %28, %45
  %retval.0 = phi i32 [ %42, %45 ], [ 0, %28 ]
  call void @llvm.stackrestore(i8* %1)
  br label %return

return:                                           ; preds = %cleanup, %if.then
  %retval.1 = phi i32 [ 0, %if.then ], [ %retval.0, %cleanup ]
  ret i32 %retval.1

OOBcheck.failure:                                 ; preds = %41
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure1:                                ; preds = %if.end
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure:                               ; preds = %22
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure2:                              ; preds = %if.then10
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure3:                              ; preds = %35
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure4:                              ; preds = %10
  call void @llvm.trap()
  ret i32 undef

WriteBarrierStack.failure:                        ; preds = %16
  call void @llvm.trap()
  ret i32 undef
}

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #3

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #4

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #5

; Function Attrs: nounwind
declare dso_local i32 @rand() local_unnamed_addr #6

; Function Attrs: nounwind
declare void @llvm.stackrestore(i8*) #4

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #7

declare i32 @checkBounds(i8*, i8*, i64)

; Function Attrs: cold noreturn nounwind
declare void @llvm.trap() #8

declare i32 @writeBarrier(i8*, i8*)

declare i32 @isAddrOOB(i8*, i8*)

declare i8* @mymalloc(i64)

declare i8* @myfree(i8*)

declare i32 @checkBoundsStack(i8*, i8*, i64, i64)

declare i32 @writeBarrierStack(i8*, i8*, i8*, i64)

declare i32* @mycast(i8*, i64, i32)

attributes #0 = { nofree noinline norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree noinline norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }
attributes #5 = { argmemonly nounwind }
attributes #6 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nofree nounwind }
attributes #8 = { cold noreturn nounwind }

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
