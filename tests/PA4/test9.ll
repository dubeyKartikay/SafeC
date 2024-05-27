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
  store i8 0, i8* %arrayidx, align 1, !tbaa !2
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #2 {
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
  %1 = ptrtoint i8* %call2 to i64
  %fld1 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 0
  store i64 %1, i64* %fld1, align 8, !tbaa !5
  %call3 = tail call i8* @mymalloc(i64 4) #5
  %2 = ptrtoint i8* %call3 to i64
  %fld3 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 2
  store i64 %2, i64* %fld3, align 8, !tbaa !8
  %call4 = tail call i8* @mymalloc(i64 4) #5
  %3 = ptrtoint i8* %call4 to i64
  %fld5 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 4
  store i64 %3, i64* %fld5, align 8, !tbaa !9
  %call5 = tail call i8* @mymalloc(i64 4) #5
  %4 = ptrtoint i8* %call5 to i64
  %fld6 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 5
  store i64 %4, i64* %fld6, align 8, !tbaa !10
  %fld2 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 1
  %5 = bitcast i64* %fld2 to %struct.A*
  call void @foo(%struct.A* nonnull %5, i32 %call1)
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %0) #5
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
!3 = !{!"omnipotent char", !4, i64 0}
!4 = !{!"Simple C/C++ TBAA"}
!5 = !{!6, !7, i64 0}
!6 = !{!"A", !7, i64 0, !7, i64 8, !7, i64 16, !7, i64 24, !7, i64 32, !7, i64 40}
!7 = !{!"long long", !3, i64 0}
!8 = !{!6, !7, i64 16}
!9 = !{!6, !7, i64 32}
!10 = !{!6, !7, i64 40}
