; ModuleID = 'test6.bc'
source_filename = "test6.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.A = type { i32*, i64, i32*, i64, i32*, i32* }

@str = private unnamed_addr constant [16 x i8] c"usage: <offset>\00", align 1

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #0 {
entry:
  %a = alloca %struct.A, align 8
  %0 = bitcast %struct.A* %a to i8*
  call void @llvm.lifetime.start.p0i8(i64 48, i8* nonnull %0) #5
  %cmp = icmp eq i32 %argc, 2
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @str, i64 0, i64 0))
  br label %cleanup

if.end:                                           ; preds = %entry
  %call1 = tail call i32 @readArgv(i8** %argv, i32 1) #5
  %call2 = tail call i8* @mymalloc(i64 4) #5
  %1 = call i8* @mycast(i8* %call2, i64 0, i32 1)
  %fld1 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 0
  %2 = bitcast %struct.A* %a to i8**
  %3 = call i32 @isAddrOOB(i8* %call2, i8* %call2)
  %4 = icmp ne i32 %3, 0
  br i1 %4, label %OOBcheck.failure, label %5

5:                                                ; preds = %if.end
  %6 = bitcast %struct.A* %a to i8*
  %7 = bitcast i8** %2 to i8*
  %8 = call i32 @checkBoundsStack(i8* %6, i8* %7, i64 8, i64 48)
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %Boundcheck.failure5, label %10

10:                                               ; preds = %5
  %11 = bitcast i8** %2 to i8*
  %12 = bitcast %struct.A* %a to i8*
  %13 = call i32 @writeBarrierStack(i8* %12, i8* %11, i8* %call2, i64 53)
  %14 = icmp ne i32 %13, 0
  br i1 %14, label %WriteBarrierStack.failure, label %15

15:                                               ; preds = %10
  store i8* %call2, i8** %2, align 8, !tbaa !2
  %call3 = tail call i8* @mymalloc(i64 4) #5
  %16 = call i8* @mycast(i8* %call3, i64 0, i32 1)
  %fld3 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 2
  %17 = bitcast i32** %fld3 to i8**
  %18 = call i32 @isAddrOOB(i8* %call3, i8* %call3)
  %19 = icmp ne i32 %18, 0
  br i1 %19, label %OOBcheck.failure1, label %20

20:                                               ; preds = %15
  %21 = bitcast %struct.A* %a to i8*
  %22 = bitcast i8** %17 to i8*
  %23 = call i32 @checkBoundsStack(i8* %21, i8* %22, i64 8, i64 48)
  %24 = icmp ne i32 %23, 0
  br i1 %24, label %Boundcheck.failure6, label %25

25:                                               ; preds = %20
  %26 = bitcast i8** %17 to i8*
  %27 = bitcast %struct.A* %a to i8*
  %28 = call i32 @writeBarrierStack(i8* %27, i8* %26, i8* %call3, i64 53)
  %29 = icmp ne i32 %28, 0
  br i1 %29, label %WriteBarrierStack.failure10, label %30

30:                                               ; preds = %25
  store i8* %call3, i8** %17, align 8, !tbaa !8
  %call4 = tail call i8* @mymalloc(i64 4) #5
  %31 = call i8* @mycast(i8* %call4, i64 0, i32 1)
  %fld5 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 4
  %32 = bitcast i32** %fld5 to i8**
  %33 = call i32 @isAddrOOB(i8* %call4, i8* %call4)
  %34 = icmp ne i32 %33, 0
  br i1 %34, label %OOBcheck.failure2, label %35

35:                                               ; preds = %30
  %36 = bitcast %struct.A* %a to i8*
  %37 = bitcast i8** %32 to i8*
  %38 = call i32 @checkBoundsStack(i8* %36, i8* %37, i64 8, i64 48)
  %39 = icmp ne i32 %38, 0
  br i1 %39, label %Boundcheck.failure7, label %40

40:                                               ; preds = %35
  %41 = bitcast i8** %32 to i8*
  %42 = bitcast %struct.A* %a to i8*
  %43 = call i32 @writeBarrierStack(i8* %42, i8* %41, i8* %call4, i64 53)
  %44 = icmp ne i32 %43, 0
  br i1 %44, label %WriteBarrierStack.failure11, label %45

45:                                               ; preds = %40
  store i8* %call4, i8** %32, align 8, !tbaa !9
  %call5 = tail call i8* @mymalloc(i64 4) #5
  %46 = call i8* @mycast(i8* %call5, i64 0, i32 1)
  %fld6 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 5
  %47 = bitcast i32** %fld6 to i8**
  %48 = call i32 @isAddrOOB(i8* %call5, i8* %call5)
  %49 = icmp ne i32 %48, 0
  br i1 %49, label %OOBcheck.failure3, label %50

50:                                               ; preds = %45
  %51 = bitcast %struct.A* %a to i8*
  %52 = bitcast i8** %47 to i8*
  %53 = call i32 @checkBoundsStack(i8* %51, i8* %52, i64 8, i64 48)
  %54 = icmp ne i32 %53, 0
  br i1 %54, label %Boundcheck.failure8, label %55

55:                                               ; preds = %50
  %56 = bitcast i8** %47 to i8*
  %57 = bitcast %struct.A* %a to i8*
  %58 = call i32 @writeBarrierStack(i8* %57, i8* %56, i8* %call5, i64 53)
  %59 = icmp ne i32 %58, 0
  br i1 %59, label %WriteBarrierStack.failure12, label %60

60:                                               ; preds = %55
  store i8* %call5, i8** %47, align 8, !tbaa !10
  %fld2 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 1
  %61 = bitcast i64* %fld2 to i8*
  %idxprom = sext i32 %call1 to i64
  %arrayidx = getelementptr inbounds i8, i8* %61, i64 %idxprom
  %62 = bitcast %struct.A* %a to i8*
  %63 = call i32 @checkBoundsStack(i8* %62, i8* %arrayidx, i64 1, i64 48)
  %64 = icmp ne i32 %63, 0
  br i1 %64, label %Boundcheck.failure9, label %65

65:                                               ; preds = %60
  %66 = bitcast %struct.A* %a to i8*
  %67 = call i32 @writeBarrierStack(i8* %66, i8* %arrayidx, i8* inttoptr (i8 1 to i8*), i64 53)
  %68 = icmp ne i32 %67, 0
  br i1 %68, label %WriteBarrierStack.failure13, label %69

69:                                               ; preds = %65
  store i8 1, i8* %arrayidx, align 1, !tbaa !11
  %70 = bitcast %struct.A* %a to i8*
  %71 = bitcast i32** %fld1 to i8*
  %72 = call i32 @checkBoundsStack(i8* %70, i8* %71, i64 8, i64 48)
  %73 = icmp ne i32 %72, 0
  br i1 %73, label %Boundcheck.failure, label %74

74:                                               ; preds = %69
  %75 = load i32*, i32** %fld1, align 8, !tbaa !2
  %76 = bitcast %struct.A* %a to i8*
  %77 = bitcast i32** %fld5 to i8*
  %78 = call i32 @checkBoundsStack(i8* %76, i8* %77, i64 8, i64 48)
  %79 = icmp ne i32 %78, 0
  br i1 %79, label %Boundcheck.failure4, label %80

80:                                               ; preds = %74
  %81 = load i32*, i32** %fld5, align 8, !tbaa !9
  %cmp8 = icmp eq i32* %75, %81
  %conv = zext i1 %cmp8 to i32
  br label %cleanup

cleanup:                                          ; preds = %80, %if.then
  %retval.0 = phi i32 [ 0, %if.then ], [ %conv, %80 ]
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %0) #5
  ret i32 %retval.0

OOBcheck.failure:                                 ; preds = %if.end
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure1:                                ; preds = %15
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure2:                                ; preds = %30
  call void @llvm.trap()
  ret i32 undef

OOBcheck.failure3:                                ; preds = %45
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure:                               ; preds = %69
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure4:                              ; preds = %74
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure5:                              ; preds = %5
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure6:                              ; preds = %20
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure7:                              ; preds = %35
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure8:                              ; preds = %50
  call void @llvm.trap()
  ret i32 undef

Boundcheck.failure9:                              ; preds = %60
  call void @llvm.trap()
  ret i32 undef

WriteBarrierStack.failure:                        ; preds = %10
  call void @llvm.trap()
  ret i32 undef

WriteBarrierStack.failure10:                      ; preds = %25
  call void @llvm.trap()
  ret i32 undef

WriteBarrierStack.failure11:                      ; preds = %40
  call void @llvm.trap()
  ret i32 undef

WriteBarrierStack.failure12:                      ; preds = %55
  call void @llvm.trap()
  ret i32 undef

WriteBarrierStack.failure13:                      ; preds = %65
  call void @llvm.trap()
  ret i32 undef
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #2

declare dso_local i8* @mymalloc(i64) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #3

declare i32 @isAddrOOB(i8*, i8*)

; Function Attrs: cold noreturn nounwind
declare void @llvm.trap() #4

declare i32 @checkBoundsStack(i8*, i8*, i64, i64)

declare i32 @writeBarrierStack(i8*, i8*, i8*, i64)

declare i8* @mycast(i8*, i64, i32)

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nofree nounwind }
attributes #4 = { cold noreturn nounwind }
attributes #5 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 23fd0cc59a32d9b8e1837ee26b6a88eeea825a95)"}
!2 = !{!3, !4, i64 0}
!3 = !{!"A", !4, i64 0, !7, i64 8, !4, i64 16, !7, i64 24, !4, i64 32, !4, i64 40}
!4 = !{!"any pointer", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = !{!"long long", !5, i64 0}
!8 = !{!3, !4, i64 16}
!9 = !{!3, !4, i64 32}
!10 = !{!3, !4, i64 40}
!11 = !{!5, !5, i64 0}
