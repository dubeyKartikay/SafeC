; ModuleID = 'test10.bc'
source_filename = "test10.c"
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

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #1 {
entry:
  %call = tail call i8* @mymalloc(i64 192) #5
  %cmp = icmp eq i32 %argc, 2
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @str, i64 0, i64 0))
  br label %cleanup

if.end:                                           ; preds = %entry
  %0 = bitcast i8* %call to %struct.A*
  %1 = call %struct.A* @mycast(i8* %call, i64 117, i32 48)
  %call2 = tail call i32 @readArgv(i8** %argv, i32 1) #5
  %call3 = tail call i8* @mymalloc(i64 4) #5
  %2 = call i8* bitcast (%struct.A* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call3, i64 0, i32 1)
  %arrayidx = getelementptr inbounds i8, i8* %call, i64 96
  %3 = bitcast i8* %arrayidx to i8**
  %4 = call i32 @isAddrOOB(i8* %call3, i8* %call3)
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %OOBcheck.failure1, label %6

6:                                                ; preds = %if.end
  %7 = bitcast i8** %3 to i8*
  %8 = call i32 @checkBounds(i8* %call, i8* %7, i64 8)
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %Boundcheck.failure, label %10

10:                                               ; preds = %6
  %11 = bitcast i8** %3 to i8*
  %12 = call i32 @writeBarrier(i8* %11, i8* %call3)
  %13 = icmp ne i32 %12, 0
  br i1 %13, label %WriteBarrier.failure, label %14

14:                                               ; preds = %10
  store i8* %call3, i8** %3, align 8, !tbaa !6
  %call4 = tail call i8* @mymalloc(i64 4) #5
  %15 = call i8* bitcast (%struct.A* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call4, i64 0, i32 1)
  %fld3 = getelementptr inbounds i8, i8* %call, i64 112
  %16 = bitcast i8* %fld3 to i8**
  %17 = call i32 @isAddrOOB(i8* %call4, i8* %call4)
  %18 = icmp ne i32 %17, 0
  br i1 %18, label %OOBcheck.failure2, label %19

19:                                               ; preds = %14
  %20 = bitcast i8** %16 to i8*
  %21 = call i32 @checkBounds(i8* %call, i8* %20, i64 8)
  %22 = icmp ne i32 %21, 0
  br i1 %22, label %Boundcheck.failure5, label %23

23:                                               ; preds = %19
  %24 = bitcast i8** %16 to i8*
  %25 = call i32 @writeBarrier(i8* %24, i8* %call4)
  %26 = icmp ne i32 %25, 0
  br i1 %26, label %WriteBarrier.failure8, label %27

27:                                               ; preds = %23
  store i8* %call4, i8** %16, align 8, !tbaa !10
  %call6 = tail call i8* @mymalloc(i64 4) #5
  %28 = call i8* bitcast (%struct.A* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call6, i64 0, i32 1)
  %fld5 = getelementptr inbounds i8, i8* %call, i64 128
  %29 = bitcast i8* %fld5 to i8**
  %30 = call i32 @isAddrOOB(i8* %call6, i8* %call6)
  %31 = icmp ne i32 %30, 0
  br i1 %31, label %OOBcheck.failure3, label %32

32:                                               ; preds = %27
  %33 = bitcast i8** %29 to i8*
  %34 = call i32 @checkBounds(i8* %call, i8* %33, i64 8)
  %35 = icmp ne i32 %34, 0
  br i1 %35, label %Boundcheck.failure6, label %36

36:                                               ; preds = %32
  %37 = bitcast i8** %29 to i8*
  %38 = call i32 @writeBarrier(i8* %37, i8* %call6)
  %39 = icmp ne i32 %38, 0
  br i1 %39, label %WriteBarrier.failure9, label %40

40:                                               ; preds = %36
  store i8* %call6, i8** %29, align 8, !tbaa !11
  %call8 = tail call i8* @mymalloc(i64 4) #5
  %41 = call i8* bitcast (%struct.A* (i8*, i64, i32)* @mycast to i8* (i8*, i64, i32)*)(i8* %call8, i64 0, i32 1)
  %fld6 = getelementptr inbounds i8, i8* %call, i64 136
  %42 = bitcast i8* %fld6 to i8**
  %43 = call i32 @isAddrOOB(i8* %call8, i8* %call8)
  %44 = icmp ne i32 %43, 0
  br i1 %44, label %OOBcheck.failure4, label %45

45:                                               ; preds = %40
  %46 = bitcast i8** %42 to i8*
  %47 = call i32 @checkBounds(i8* %call, i8* %46, i64 8)
  %48 = icmp ne i32 %47, 0
  br i1 %48, label %Boundcheck.failure7, label %49

49:                                               ; preds = %45
  %50 = bitcast i8** %42 to i8*
  %51 = call i32 @writeBarrier(i8* %50, i8* %call8)
  %52 = icmp ne i32 %51, 0
  br i1 %52, label %WriteBarrier.failure10, label %53

53:                                               ; preds = %49
  store i8* %call8, i8** %42, align 8, !tbaa !12
  %54 = bitcast %struct.A* %0 to i8*
  %55 = call i32 @isAddrOOB(i8* %call, i8* %54)
  %56 = icmp ne i32 %55, 0
  br i1 %56, label %OOBcheck.failure, label %57

57:                                               ; preds = %53
  tail call void @foo(%struct.A* %0, i32 %call2)
  br label %cleanup

cleanup:                                          ; preds = %57, %if.then
  ret i32 0

OOBcheck.failure:                                 ; preds = %53
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure1:                                ; preds = %if.end
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure2:                                ; preds = %14
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure3:                                ; preds = %27
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure4:                                ; preds = %40
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure:                               ; preds = %6
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure5:                              ; preds = %19
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure6:                              ; preds = %32
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure7:                              ; preds = %45
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure:                             ; preds = %10
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure8:                            ; preds = %23
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure9:                            ; preds = %36
  call void @llvm.trap()
  ret i32 undef

WriteBarrier.failure10:                           ; preds = %49
  call void @llvm.trap()
  ret i32 undef
}

declare dso_local i8* @mymalloc(i64) local_unnamed_addr #2

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #3

declare i32 @checkBounds(i8*, i8*, i64)

; Function Attrs: cold noreturn nounwind
declare void @llvm.trap() #4

declare i32 @writeBarrier(i8*, i8*)

declare i32 @isAddrOOB(i8*, i8*)

declare %struct.A* @mycast(i8*, i64, i32)

attributes #0 = { nofree noinline norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nofree nounwind }
attributes #4 = { cold noreturn nounwind }
attributes #5 = { nounwind }

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
