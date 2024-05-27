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
  store i32 0, i32* %1, align 4, !tbaa !2
  ret void
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #1 {
entry:
  %call = tail call i8* @mymalloc(i64 192) #4
  %cmp = icmp eq i32 %argc, 2
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @str, i64 0, i64 0))
  br label %cleanup

if.end:                                           ; preds = %entry
  %0 = bitcast i8* %call to %struct.A*
  %call2 = tail call i32 @readArgv(i8** %argv, i32 1) #4
  %call3 = tail call i8* @mymalloc(i64 4) #4
  %arrayidx = getelementptr inbounds i8, i8* %call, i64 96
  %1 = bitcast i8* %arrayidx to i8**
  store i8* %call3, i8** %1, align 8, !tbaa !6
  %call4 = tail call i8* @mymalloc(i64 4) #4
  %fld3 = getelementptr inbounds i8, i8* %call, i64 112
  %2 = bitcast i8* %fld3 to i8**
  store i8* %call4, i8** %2, align 8, !tbaa !10
  %call6 = tail call i8* @mymalloc(i64 4) #4
  %fld5 = getelementptr inbounds i8, i8* %call, i64 128
  %3 = bitcast i8* %fld5 to i8**
  store i8* %call6, i8** %3, align 8, !tbaa !11
  %call8 = tail call i8* @mymalloc(i64 4) #4
  %fld6 = getelementptr inbounds i8, i8* %call, i64 136
  %4 = bitcast i8* %fld6 to i8**
  store i8* %call8, i8** %4, align 8, !tbaa !12
  tail call void @foo(%struct.A* %0, i32 %call2)
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then
  ret i32 0
}

declare dso_local i8* @mymalloc(i64) local_unnamed_addr #2

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #3

attributes #0 = { nofree noinline norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nofree nounwind }
attributes #4 = { nounwind }

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
