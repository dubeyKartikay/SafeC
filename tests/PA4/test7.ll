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
  store i32 0, i32* %arrayidx, align 4, !tbaa !2
  ret void
}

; Function Attrs: nofree noinline norecurse nounwind uwtable
define dso_local void @foo(%struct.List* nocapture readonly %node, i32 %offset) local_unnamed_addr #1 {
entry:
  %arr1 = getelementptr inbounds %struct.List, %struct.List* %node, i64 0, i32 0
  %0 = load i32*, i32** %arr1, align 8, !tbaa !6
  %idxprom = sext i32 %offset to i64
  %arrayidx = getelementptr inbounds i32, i32* %0, i64 %idxprom
  store i32 20, i32* %arrayidx, align 4, !tbaa !2
  %add = add nsw i32 %offset, 8
  %idxprom2 = sext i32 %add to i64
  %arrayidx3 = getelementptr inbounds i32, i32* %0, i64 %idxprom2
  tail call void @bar(i32* %arrayidx3, i32 %offset)
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
  %vla = alloca i32, i64 %0, align 16
  %vla3 = alloca %struct.List, i64 %0, align 16
  %2 = bitcast %struct.List* %vla3 to i8*
  %conv = sext i32 %call1 to i64
  %mul = shl nsw i64 %conv, 4
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 %2, i8 0, i64 %mul, i1 false)
  %add = add nsw i32 %call2, 10
  %idxprom = sext i32 %add to i64
  %arrayidx = getelementptr inbounds i32, i32* %vla, i64 %idxprom
  %idxprom4 = sext i32 %call2 to i64
  %arr = getelementptr inbounds %struct.List, %struct.List* %vla3, i64 %idxprom4, i32 0
  store i32* %arrayidx, i32** %arr, align 16, !tbaa !6
  %call6 = call i32 @rand() #4
  %rem = srem i32 %call6, %call1
  %idxprom7 = sext i32 %rem to i64
  %arr9 = getelementptr inbounds %struct.List, %struct.List* %vla3, i64 %idxprom7, i32 0
  %3 = load i32*, i32** %arr9, align 16, !tbaa !6
  %tobool = icmp eq i32* %3, null
  br i1 %tobool, label %cleanup, label %if.then10

if.then10:                                        ; preds = %if.end
  %arr12 = getelementptr inbounds %struct.List, %struct.List* %vla3, i64 0, i32 0
  %4 = load i32*, i32** %arr12, align 16, !tbaa !6
  %5 = load i32, i32* %4, align 4, !tbaa !2
  br label %cleanup

cleanup:                                          ; preds = %if.end, %if.then10
  %retval.0 = phi i32 [ %5, %if.then10 ], [ 0, %if.end ]
  call void @llvm.stackrestore(i8* %1)
  br label %return

return:                                           ; preds = %cleanup, %if.then
  %retval.1 = phi i32 [ 0, %if.then ], [ %retval.0, %cleanup ]
  ret i32 %retval.1
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

attributes #0 = { nofree noinline norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree noinline norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }
attributes #5 = { argmemonly nounwind }
attributes #6 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nofree nounwind }

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
