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
  call void @llvm.lifetime.start.p0i8(i64 48, i8* nonnull %0) #4
  %cmp = icmp eq i32 %argc, 2
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([16 x i8], [16 x i8]* @str, i64 0, i64 0))
  br label %cleanup

if.end:                                           ; preds = %entry
  %call1 = tail call i32 @readArgv(i8** %argv, i32 1) #4
  %call2 = tail call i8* @mymalloc(i64 4) #4
  %fld1 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 0
  %1 = bitcast %struct.A* %a to i8**
  store i8* %call2, i8** %1, align 8, !tbaa !2
  %call3 = tail call i8* @mymalloc(i64 4) #4
  %fld3 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 2
  %2 = bitcast i32** %fld3 to i8**
  store i8* %call3, i8** %2, align 8, !tbaa !8
  %call4 = tail call i8* @mymalloc(i64 4) #4
  %fld5 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 4
  %3 = bitcast i32** %fld5 to i8**
  store i8* %call4, i8** %3, align 8, !tbaa !9
  %call5 = tail call i8* @mymalloc(i64 4) #4
  %fld6 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 5
  %4 = bitcast i32** %fld6 to i8**
  store i8* %call5, i8** %4, align 8, !tbaa !10
  %fld2 = getelementptr inbounds %struct.A, %struct.A* %a, i64 0, i32 1
  %5 = bitcast i64* %fld2 to i8*
  %idxprom = sext i32 %call1 to i64
  %arrayidx = getelementptr inbounds i8, i8* %5, i64 %idxprom
  store i8 1, i8* %arrayidx, align 1, !tbaa !11
  %6 = load i32*, i32** %fld1, align 8, !tbaa !2
  %7 = load i32*, i32** %fld5, align 8, !tbaa !9
  %cmp8 = icmp eq i32* %6, %7
  %conv = zext i1 %cmp8 to i32
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then
  %retval.0 = phi i32 [ 0, %if.then ], [ %conv, %if.end ]
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %0) #4
  ret i32 %retval.0
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #2

declare dso_local i8* @mymalloc(i64) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #3

attributes #0 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nofree nounwind }
attributes #4 = { nounwind }

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
