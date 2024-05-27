; ModuleID = 'test9.bc'
source_filename = "test9.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.A = type { i64, i64, i64, i64, i64, i64 }

@str = private unnamed_addr constant [16 x i8] c"usage: <offset>\00", align 1

; Function Attrs: nofree noinline norecurse nounwind uwtable writeonly
define dso_local void @foo(%struct.A* nocapture %node, i32 %offset) local_unnamed_addr #0 {
entry:
  %0 = bitcast %struct.A* %node to i8*
  %idxprom = sext i32 %offset to i64
  %arrayidx = getelementptr inbounds i8, i8* %0, i64 %idxprom
  %1 = bitcast %struct.A* %node to i8*
  %2 = call i32 @checkBounds(i8* %1, i8* %arrayidx, i64 1)
  %3 = icmp ne i32 %2, 0
  br i1 %3, label %Boundcheck.failure, label %4

4:                                                ; preds = %entry
  %5 = call i32 @writeBarrier(i8* %arrayidx, i8* null)
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %WriteBarrier.failure, label %7

7:                                                ; preds = %4
  store i8 0, i8* %arrayidx, align 1, !tbaa !2
  ret void

Boundcheck.failure:                               ; preds = %entry
  call void @llvm.trap()
  ret void

WriteBarrier.failure:                             ; preds = %4
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
  %0 = call i8* @mymalloc(i64 48)
  %1 = bitcast i8* %0 to %struct.A*
  %2 = call %struct.A* @mycast(i8* %0, i64 0, i32 48)
  %3 = bitcast %struct.A* %1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 48, i8* nonnull %3) #6
  %cmp = icmp eq i32 %argc, 2
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @str, i64 0, i64 0))
  br label %cleanup

if.end:                                           ; preds = %entry
  %call1 = tail call i32 @readArgv(i8** %argv, i32 1) #6
  %call2 = tail call i8* @mymalloc(i64 4) #6
  %4 = call i8* bitcast (%struct.A* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call2, i64 0, i32 1)
  %5 = ptrtoint i8* %call2 to i64
  %fld1 = getelementptr inbounds %struct.A, %struct.A* %1, i64 0, i32 0
  %6 = bitcast i64* %fld1 to i8*
  %7 = call i32 @checkBounds(i8* %0, i8* %6, i64 8)
  %8 = icmp ne i32 %7, 0
  br i1 %8, label %Boundcheck.failure, label %9

9:                                                ; preds = %if.end
  %10 = bitcast i64* %fld1 to i8*
  %11 = inttoptr i64 %5 to i8*
  %12 = call i32 @writeBarrier(i8* %10, i8* %11)
  %13 = icmp ne i32 %12, 0
  br i1 %13, label %WriteBarrier.failure, label %14

14:                                               ; preds = %9
  store i64 %5, i64* %fld1, align 8, !tbaa !5
  %call3 = tail call i8* @mymalloc(i64 4) #6
  %15 = call i8* bitcast (%struct.A* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call3, i64 0, i32 1)
  %16 = ptrtoint i8* %call3 to i64
  %fld3 = getelementptr inbounds %struct.A, %struct.A* %1, i64 0, i32 2
  %17 = bitcast i64* %fld3 to i8*
  %18 = call i32 @checkBounds(i8* %0, i8* %17, i64 8)
  %19 = icmp ne i32 %18, 0
  br i1 %19, label %Boundcheck.failure2, label %20

20:                                               ; preds = %14
  %21 = bitcast i64* %fld3 to i8*
  %22 = inttoptr i64 %16 to i8*
  %23 = call i32 @writeBarrier(i8* %21, i8* %22)
  %24 = icmp ne i32 %23, 0
  br i1 %24, label %WriteBarrier.failure5, label %25

25:                                               ; preds = %20
  store i64 %16, i64* %fld3, align 8, !tbaa !8
  %call4 = tail call i8* @mymalloc(i64 4) #6
  %26 = call i8* bitcast (%struct.A* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call4, i64 0, i32 1)
  %27 = ptrtoint i8* %call4 to i64
  %fld5 = getelementptr inbounds %struct.A, %struct.A* %1, i64 0, i32 4
  %28 = bitcast i64* %fld5 to i8*
  %29 = call i32 @checkBounds(i8* %0, i8* %28, i64 8)
  %30 = icmp ne i32 %29, 0
  br i1 %30, label %Boundcheck.failure3, label %31

31:                                               ; preds = %25
  %32 = bitcast i64* %fld5 to i8*
  %33 = inttoptr i64 %27 to i8*
  %34 = call i32 @writeBarrier(i8* %32, i8* %33)
  %35 = icmp ne i32 %34, 0
  br i1 %35, label %WriteBarrier.failure6, label %36

36:                                               ; preds = %31
  store i64 %27, i64* %fld5, align 8, !tbaa !9
  %call5 = tail call i8* @mymalloc(i64 4) #6
  %37 = call i8* bitcast (%struct.A* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call5, i64 0, i32 1)
  %38 = ptrtoint i8* %call5 to i64
  %fld6 = getelementptr inbounds %struct.A, %struct.A* %1, i64 0, i32 5
  %39 = bitcast i64* %fld6 to i8*
  %40 = call i32 @checkBounds(i8* %0, i8* %39, i64 8)
  %41 = icmp ne i32 %40, 0
  br i1 %41, label %Boundcheck.failure4, label %42

42:                                               ; preds = %36
  %43 = bitcast i64* %fld6 to i8*
  %44 = inttoptr i64 %38 to i8*
  %45 = call i32 @writeBarrier(i8* %43, i8* %44)
  %46 = icmp ne i32 %45, 0
  br i1 %46, label %WriteBarrier.failure7, label %47

47:                                               ; preds = %42
  store i64 %38, i64* %fld6, align 8, !tbaa !10
  %fld2 = getelementptr inbounds %struct.A, %struct.A* %1, i64 0, i32 1
  %48 = bitcast i64* %fld2 to %struct.A*
  %49 = bitcast %struct.A* %48 to i8*
  %50 = call i32 @isAddrOOB(i8* %0, i8* %49)
  %51 = icmp ne i32 %50, 0
  br i1 %51, label %OOBcheck.failure, label %52

52:                                               ; preds = %47
  call void @foo(%struct.A* nonnull %48, i32 %call1)
  br label %cleanup

cleanup:                                          ; preds = %52, %if.then
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %3) #6
  %53 = call i32 @isAddrOOB(i8* %0, i8* %0)
  %54 = icmp ne i32 %53, 0
  br i1 %54, label %OOBcheck.failure1, label %55

55:                                               ; preds = %cleanup
  %56 = call i8* @myfree(i8* %0)
  ret i32 0

OOBcheck.failure:                                 ; preds = %47
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure1:                                ; preds = %cleanup
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure:                               ; preds = %if.end
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure2:                              ; preds = %14
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure3:                              ; preds = %25
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure4:                              ; preds = %36
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure:                             ; preds = %9
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure5:                            ; preds = %20
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure6:                            ; preds = %31
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure7:                            ; preds = %42
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

declare %struct.A* @mycast(i8*, i64, i32)

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
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!6, !7, i64 0}
!6 = !{!"A", !7, i64 0, !7, i64 8, !7, i64 16, !7, i64 24, !7, i64 32, !7, i64 40}
!7 = !{!"long long", !3, i64 0}
!8 = !{!6, !7, i64 16}
!9 = !{!6, !7, i64 32}
!10 = !{!6, !7, i64 40}
