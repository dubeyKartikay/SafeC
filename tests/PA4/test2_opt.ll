; ModuleID = 'test2.bc'
source_filename = "test2.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.List = type { i32*, %struct.List* }

@str = private unnamed_addr constant [24 x i8] c"Usage:: <size> <offset>\00", align 1

; Function Attrs: nofree noinline norecurse nounwind uwtable writeonly
define dso_local void @bar(i32* nocapture %arr, i32 %offset) local_unnamed_addr #0 {
entry:
  %0 = bitcast i32* %arr to i64*
  %idxprom = sext i32 %offset to i64
  %arrayidx = getelementptr inbounds i64, i64* %0, i64 %idxprom
  %1 = bitcast i32* %arr to i8*
  %2 = bitcast i64* %arrayidx to i8*
  %3 = call i32 @checkBounds(i8* %1, i8* %2, i64 8)
  %4 = icmp ne i32 %3, 0
  br i1 %4, label %Boundcheck.failure, label %5

5:                                                ; preds = %entry
  store i64 0, i64* %arrayidx, align 8, !tbaa !2
  ret void

Boundcheck.failure:                               ; preds = %entry
  call void @llvm.trap()
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nofree noinline norecurse nounwind uwtable
define dso_local void @foo(%struct.List* nocapture readonly %node, i32 %offset) local_unnamed_addr #2 {
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
  store i32 20, i32* %arrayidx, align 4, !tbaa !9
  %add = add nsw i32 %offset, 8
  %idxprom2 = sext i32 %add to i64
  %arrayidx3 = getelementptr inbounds i32, i32* %5, i64 %idxprom2
  %11 = bitcast i32* %5 to i8*
  %12 = bitcast i32* %arrayidx3 to i8*
  %13 = call i32 @isAddrOOB(i8* %11, i8* %12)
  %14 = icmp ne i32 %13, 0
  br i1 %14, label %OOBcheck.failure, label %15

15:                                               ; preds = %10
  tail call void @bar(i32* %arrayidx3, i32 %offset)
  ret void

OOBcheck.failure:                                 ; preds = %10
  call void @llvm.trap()
  ret void

Boundcheck.failure:                               ; preds = %entry
  call void @llvm.trap()
  ret void

Boundcheck.failure1:                              ; preds = %4
  call void @llvm.trap()
  ret void
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #3 {
entry:
  %0 = call i8* @mymalloc(i64 16)
  %1 = bitcast i8* %0 to %struct.List*
  %2 = call %struct.List* @mycast(i8* %0, i64 7, i32 16)
  %cmp = icmp eq i32 %argc, 3
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @str, i64 0, i64 0))
  br label %return

if.end:                                           ; preds = %entry
  %call1 = tail call i32 @readArgv(i8** %argv, i32 1) #5
  %call2 = tail call i32 @readArgv(i8** %argv, i32 2) #5
  %3 = zext i32 %call1 to i64
  %4 = tail call i8* @llvm.stacksave()
  %5 = mul i64 %3, 4
  %6 = call i8* @mymalloc(i64 %5)
  %7 = bitcast i8* %6 to i32*
  %8 = call i32* bitcast (%struct.List* (i8*, i64, i32)* @mycast to i32* (i8*, i64, i32)*)(i8* %6, i64 0, i32 4)
  %9 = bitcast %struct.List* %1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %9) #5
  %add = add nsw i32 %call2, 1
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds i32, i32* %7, i64 %idxprom
  %arr = getelementptr inbounds %struct.List, %struct.List* %1, i64 0, i32 0
  %10 = bitcast i32* %arrayidx to i8*
  %11 = call i32 @isAddrOOB(i8* %6, i8* %10)
  %12 = icmp ne i32 %11, 0
  br i1 %12, label %OOBcheck.failure1, label %13

13:                                               ; preds = %if.end
  %14 = bitcast i32** %arr to i8*
  %15 = call i32 @checkBounds(i8* %0, i8* %14, i64 8)
  %16 = icmp ne i32 %15, 0
  br i1 %16, label %Boundcheck.failure, label %17

17:                                               ; preds = %13
  store i32* %arrayidx, i32** %arr, align 8, !tbaa !6
  %18 = bitcast %struct.List* %1 to i8*
  %19 = call i32 @isAddrOOB(i8* %0, i8* %18)
  %20 = icmp ne i32 %19, 0
  br i1 %20, label %OOBcheck.failure, label %21

21:                                               ; preds = %17
  call void @foo(%struct.List* nonnull %1, i32 %call2)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %9) #5
  call void @llvm.stackrestore(i8* %4)
  br label %return

return:                                           ; preds = %21, %if.then
  ret i32 0

OOBcheck.failure:                                 ; preds = %17
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure1:                                ; preds = %if.end
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure:                               ; preds = %13
  call void @llvm.trap()
  ret i32 undef
}

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #4

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #5

; Function Attrs: nounwind
declare void @llvm.stackrestore(i8*) #5

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #6

declare i32 @checkBounds(i8*, i8*, i64)

; Function Attrs: cold noreturn nounwind
declare void @llvm.trap() #7

declare i32 @isAddrOOB(i8*, i8*)

declare i8* @mymalloc(i64)

declare %struct.List* @mycast(i8*, i64, i32)

attributes #0 = { nofree noinline norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nofree noinline norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind }
attributes #6 = { nofree nounwind }
attributes #7 = { cold noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 49d077240ba88639d805c42031ba63ca38f025b6)"}
!2 = !{!3, !3, i64 0}
!3 = !{!"long long", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C/C++ TBAA"}
!6 = !{!7, !8, i64 0}
!7 = !{!"List", !8, i64 0, !8, i64 8}
!8 = !{!"any pointer", !4, i64 0}
!9 = !{!10, !10, i64 0}
!10 = !{!"int", !4, i64 0}
