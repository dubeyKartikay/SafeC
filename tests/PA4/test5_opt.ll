; ModuleID = 'test5.bc'
source_filename = "test5.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.A = type { i32*, i64, i32*, i64, i32*, i32* }

@str = private unnamed_addr constant [16 x i8] c"usage: <offset>\00", align 1

; Function Attrs: nofree noinline norecurse nounwind uwtable writeonly
define dso_local void @foo(%struct.A* nocapture %node, i32 %offset) local_unnamed_addr #0 {
entry:
  %0 = bitcast %struct.A* %node to i8*
  %idxprom = sext i32 %offset to i64
  %arrayidx = getelementptr inbounds i8, i8* %0, i64 %idxprom
  %1 = bitcast i8* %arrayidx to i32*
  %2 = bitcast %struct.A* %node to i8*
  %3 = bitcast i32* %1 to i8*
  %4 = call i32 @checkBounds(i8* %2, i8* %3, i64 4)
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %Boundcheck.failure, label %6

6:                                                ; preds = %entry
  %7 = bitcast i32* %1 to i8*
  %8 = call i32 @writeBarrier(i8* %7, i8* null)
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %WriteBarrier.failure, label %10

10:                                               ; preds = %6
  store i32 0, i32* %1, align 4, !tbaa !2
  ret void

Boundcheck.failure:                               ; preds = %entry
  call void @llvm.trap()
  ret void

WriteBarrier.failure:                             ; preds = %6
  call void @llvm.trap()
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #2 {
entry:
  %0 = call i8* @mymalloc(i64 192)
  %1 = bitcast i8* %0 to [4 x %struct.A]*
  %2 = call [4 x %struct.A]* @mycast(i8* %0, i64 117, i32 48)
  %3 = bitcast [4 x %struct.A]* %1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 192, i8* nonnull %3) #6
  %cmp = icmp eq i32 %argc, 2
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @str, i64 0, i64 0))
  br label %cleanup

if.end:                                           ; preds = %entry
  %call1 = tail call i32 @readArgv(i8** %argv, i32 1) #6
  %call2 = tail call i8* @mymalloc(i64 4) #6
  %4 = call i8* bitcast ([4 x %struct.A]* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call2, i64 0, i32 1)
  %arrayidx = getelementptr inbounds [4 x %struct.A], [4 x %struct.A]* %1, i64 0, i64 2
  %5 = bitcast %struct.A* %arrayidx to i8**
  %6 = call i32 @isAddrOOB(i8* %call2, i8* %call2)
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %OOBcheck.failure2, label %8

8:                                                ; preds = %if.end
  %9 = bitcast i8** %5 to i8*
  %10 = call i32 @checkBounds(i8* %0, i8* %9, i64 8)
  %11 = icmp ne i32 %10, 0
  br i1 %11, label %Boundcheck.failure, label %12

12:                                               ; preds = %8
  %13 = bitcast i8** %5 to i8*
  %14 = call i32 @writeBarrier(i8* %13, i8* %call2)
  %15 = icmp ne i32 %14, 0
  br i1 %15, label %WriteBarrier.failure, label %16

16:                                               ; preds = %12
  store i8* %call2, i8** %5, align 16, !tbaa !6
  %call3 = tail call i8* @mymalloc(i64 4) #6
  %17 = call i8* bitcast ([4 x %struct.A]* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call3, i64 0, i32 1)
  %fld3 = getelementptr inbounds [4 x %struct.A], [4 x %struct.A]* %1, i64 0, i64 2, i32 2
  %18 = bitcast i32** %fld3 to i8**
  %19 = call i32 @isAddrOOB(i8* %call3, i8* %call3)
  %20 = icmp ne i32 %19, 0
  br i1 %20, label %OOBcheck.failure3, label %21

21:                                               ; preds = %16
  %22 = bitcast i8** %18 to i8*
  %23 = call i32 @checkBounds(i8* %0, i8* %22, i64 8)
  %24 = icmp ne i32 %23, 0
  br i1 %24, label %Boundcheck.failure6, label %25

25:                                               ; preds = %21
  %26 = bitcast i8** %18 to i8*
  %27 = call i32 @writeBarrier(i8* %26, i8* %call3)
  %28 = icmp ne i32 %27, 0
  br i1 %28, label %WriteBarrier.failure9, label %29

29:                                               ; preds = %25
  store i8* %call3, i8** %18, align 16, !tbaa !10
  %call5 = tail call i8* @mymalloc(i64 4) #6
  %30 = call i8* bitcast ([4 x %struct.A]* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call5, i64 0, i32 1)
  %fld5 = getelementptr inbounds [4 x %struct.A], [4 x %struct.A]* %1, i64 0, i64 2, i32 4
  %31 = bitcast i32** %fld5 to i8**
  %32 = call i32 @isAddrOOB(i8* %call5, i8* %call5)
  %33 = icmp ne i32 %32, 0
  br i1 %33, label %OOBcheck.failure4, label %34

34:                                               ; preds = %29
  %35 = bitcast i8** %31 to i8*
  %36 = call i32 @checkBounds(i8* %0, i8* %35, i64 8)
  %37 = icmp ne i32 %36, 0
  br i1 %37, label %Boundcheck.failure7, label %38

38:                                               ; preds = %34
  %39 = bitcast i8** %31 to i8*
  %40 = call i32 @writeBarrier(i8* %39, i8* %call5)
  %41 = icmp ne i32 %40, 0
  br i1 %41, label %WriteBarrier.failure10, label %42

42:                                               ; preds = %38
  store i8* %call5, i8** %31, align 16, !tbaa !11
  %call7 = tail call i8* @mymalloc(i64 4) #6
  %43 = call i8* bitcast ([4 x %struct.A]* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call7, i64 0, i32 1)
  %fld6 = getelementptr inbounds [4 x %struct.A], [4 x %struct.A]* %1, i64 0, i64 2, i32 5
  %44 = bitcast i32** %fld6 to i8**
  %45 = call i32 @isAddrOOB(i8* %call7, i8* %call7)
  %46 = icmp ne i32 %45, 0
  br i1 %46, label %OOBcheck.failure5, label %47

47:                                               ; preds = %42
  %48 = bitcast i8** %44 to i8*
  %49 = call i32 @checkBounds(i8* %0, i8* %48, i64 8)
  %50 = icmp ne i32 %49, 0
  br i1 %50, label %Boundcheck.failure8, label %51

51:                                               ; preds = %47
  %52 = bitcast i8** %44 to i8*
  %53 = call i32 @writeBarrier(i8* %52, i8* %call7)
  %54 = icmp ne i32 %53, 0
  br i1 %54, label %WriteBarrier.failure11, label %55

55:                                               ; preds = %51
  store i8* %call7, i8** %44, align 8, !tbaa !12
  %fld2 = getelementptr inbounds [4 x %struct.A], [4 x %struct.A]* %1, i64 0, i64 2, i32 1
  %56 = bitcast i64* %fld2 to %struct.A*
  %57 = bitcast %struct.A* %56 to i8*
  %58 = call i32 @isAddrOOB(i8* %0, i8* %57)
  %59 = icmp ne i32 %58, 0
  br i1 %59, label %OOBcheck.failure, label %60

60:                                               ; preds = %55
  call void @foo(%struct.A* nonnull %56, i32 %call1)
  br label %cleanup

cleanup:                                          ; preds = %60, %if.then
  call void @llvm.lifetime.end.p0i8(i64 192, i8* nonnull %3) #6
  %61 = call i32 @isAddrOOB(i8* %0, i8* %0)
  %62 = icmp ne i32 %61, 0
  br i1 %62, label %OOBcheck.failure1, label %63

63:                                               ; preds = %cleanup
  %64 = call i8* @myfree(i8* %0)
  ret i32 0

OOBcheck.failure:                                 ; preds = %55
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure1:                                ; preds = %cleanup
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure2:                                ; preds = %if.end
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure3:                                ; preds = %16
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure4:                                ; preds = %29
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure5:                                ; preds = %42
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure:                               ; preds = %8
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure6:                              ; preds = %21
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure7:                              ; preds = %34
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure8:                              ; preds = %47
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure:                             ; preds = %12
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure9:                            ; preds = %25
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure10:                           ; preds = %38
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure11:                           ; preds = %51
  call void @llvm.trap()
  ret i32 undef
}

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #3

declare dso_local i8* @mymalloc(i64) local_unnamed_addr #3

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #4

declare i32 @checkBounds(i8*, i8*, i64)

; Function Attrs: cold noreturn nounwind
declare void @llvm.trap() #5

declare i32 @writeBarrier(i8*, i8*)

declare i8* @myfree(i8*)

declare i32 @isAddrOOB(i8*, i8*)

declare [4 x %struct.A]* @mycast(i8*, i64, i32)

attributes #0 = { nofree noinline norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
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
!7 = !{!"A", !8, i64 0, !9, i64 8, !8, i64 16, !9, i64 24, !8, i64 32, !8, i64 40}
!8 = !{!"any pointer", !4, i64 0}
!9 = !{!"long long", !4, i64 0}
!10 = !{!7, !8, i64 16}
!11 = !{!7, !8, i64 32}
!12 = !{!7, !8, i64 40}
