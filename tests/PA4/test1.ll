; ModuleID = 'test1.bc'
source_filename = "test1.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.List = type { i32*, %struct.List* }

@str = private unnamed_addr constant [24 x i8] c"Usage:: <size> <offset>\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local %struct.List* @allocate_n() local_unnamed_addr #0 {
entry:
  %call = tail call i8* @mymalloc(i64 16) #6
  %0 = bitcast i8* %call to %struct.List*
  ret %struct.List* %0
}

declare dso_local i8* @mymalloc(i64) local_unnamed_addr #1

; Function Attrs: nofree noinline norecurse nounwind uwtable writeonly
define dso_local void @bar(i32* nocapture %arr, i32 %offset) local_unnamed_addr #2 {
entry:
  %idxprom = sext i32 %offset to i64
  %arrayidx = getelementptr inbounds i32, i32* %arr, i64 %idxprom
  store i32 0, i32* %arrayidx, align 4, !tbaa !2
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32* @allocate_a(i32 %size, i32 %offset) local_unnamed_addr #0 {
entry:
  %conv = sext i32 %size to i64
  %call = tail call i8* @mymalloc(i64 %conv) #6
  %0 = bitcast i8* %call to i32*
  %idx.ext = sext i32 %offset to i64
  %add.ptr = getelementptr inbounds i32, i32* %0, i64 %idx.ext
  ret i32* %add.ptr
}

; Function Attrs: nofree noinline norecurse nounwind uwtable
define dso_local void @foo(%struct.List* nocapture readonly %node, i32 %offset) local_unnamed_addr #3 {
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
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #4 {
entry:
  %cmp = icmp eq i32 %argc, 3
  br i1 %cmp, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  %puts = tail call i32 @puts(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @str, i64 0, i64 0))
  br label %return

if.end:                                           ; preds = %entry
  %call1 = tail call i32 @readArgv(i8** %argv, i32 1) #6
  %mul = shl i32 %call1, 2
  %call3 = tail call i32 @readArgv(i8** %argv, i32 2) #6
  %call4 = tail call i32* @allocate_a(i32 %mul, i32 %call3)
  %call5 = tail call %struct.List* @allocate_n()
  %add.ptr = getelementptr inbounds i32, i32* %call4, i64 1
  %arr = getelementptr inbounds %struct.List, %struct.List* %call5, i64 0, i32 0
  store i32* %add.ptr, i32** %arr, align 8, !tbaa !6
  tail call void @foo(%struct.List* %call5, i32 %call3)
  br label %return

return:                                           ; preds = %if.end, %if.then
  ret i32 0
}

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #1

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #5

attributes #0 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nofree noinline norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nofree noinline norecurse nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nofree nounwind }
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
!7 = !{!"List", !8, i64 0, !8, i64 8}
!8 = !{!"any pointer", !4, i64 0}
