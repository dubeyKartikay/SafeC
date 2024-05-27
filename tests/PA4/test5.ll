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
  store i32 0, i32* %1, align 4, !tbaa !2
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #2 {
entry:
  %a = alloca [4 x %struct.A], align 16
  %0 = bitcast [4 x %struct.A]* %a to i8*
  call void @llvm.lifetime.start.p0i8(i64 192, i8* nonnull %0) #5
  %cmp = icmp eq i32 %argc, 2
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @str, i64 0, i64 0))
  br label %cleanup

if.end:                                           ; preds = %entry
  %call1 = tail call i32 @readArgv(i8** %argv, i32 1) #5
  %call2 = tail call i8* @mymalloc(i64 4) #5
  %arrayidx = getelementptr inbounds [4 x %struct.A], [4 x %struct.A]* %a, i64 0, i64 2
  %1 = bitcast %struct.A* %arrayidx to i8**
  store i8* %call2, i8** %1, align 16, !tbaa !6
  %call3 = tail call i8* @mymalloc(i64 4) #5
  %fld3 = getelementptr inbounds [4 x %struct.A], [4 x %struct.A]* %a, i64 0, i64 2, i32 2
  %2 = bitcast i32** %fld3 to i8**
  store i8* %call3, i8** %2, align 16, !tbaa !10
  %call5 = tail call i8* @mymalloc(i64 4) #5
  %fld5 = getelementptr inbounds [4 x %struct.A], [4 x %struct.A]* %a, i64 0, i64 2, i32 4
  %3 = bitcast i32** %fld5 to i8**
  store i8* %call5, i8** %3, align 16, !tbaa !11
  %call7 = tail call i8* @mymalloc(i64 4) #5
  %fld6 = getelementptr inbounds [4 x %struct.A], [4 x %struct.A]* %a, i64 0, i64 2, i32 5
  %4 = bitcast i32** %fld6 to i8**
  store i8* %call7, i8** %4, align 8, !tbaa !12
  %fld2 = getelementptr inbounds [4 x %struct.A], [4 x %struct.A]* %a, i64 0, i64 2, i32 1
  %5 = bitcast i64* %fld2 to %struct.A*
  call void @foo(%struct.A* nonnull %5, i32 %call1)
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then
  call void @llvm.lifetime.end.p0i8(i64 192, i8* nonnull %0) #5
  ret i32 0
}

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #3

declare dso_local i8* @mymalloc(i64) local_unnamed_addr #3

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #4

attributes #0 = { nofree noinline norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nofree nounwind }
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
