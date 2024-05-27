; ModuleID = 'test4.bc'
source_filename = "test4.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.List = type { i32*, %struct.List* }

@node = common dso_local local_unnamed_addr global %struct.List zeroinitializer, align 8
@str = private unnamed_addr constant [24 x i8] c"Usage:: <size> <offset>\00", align 1

; Function Attrs: nofree noinline norecurse nounwind uwtable writeonly
define dso_local void @bar(i32* nocapture %arr, i32 %offset) local_unnamed_addr #0 {
entry:
  %idxprom = sext i32 %offset to i64
  %arrayidx = getelementptr inbounds i32, i32* %arr, i64 %idxprom
  store i32 0, i32* %arrayidx, align 4, !tbaa !2
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32* @allocate_a(i32 %size, i32 %offset) local_unnamed_addr #1 {
entry:
  %conv = sext i32 %size to i64
  %call = tail call i8* @mymalloc(i64 %conv) #4
  %0 = bitcast i8* %call to i32*
  %idx.ext = sext i32 %offset to i64
  %add.ptr = getelementptr inbounds i32, i32* %0, i64 %idx.ext
  ret i32* %add.ptr
}

declare dso_local i8* @mymalloc(i64) local_unnamed_addr #2

; Function Attrs: nofree noinline norecurse nounwind uwtable writeonly
define dso_local void @foo(i32* nocapture %arr, i32 %offset) local_unnamed_addr #0 {
entry:
  %idxprom = sext i32 %offset to i64
  %arrayidx = getelementptr inbounds i32, i32* %arr, i64 %idxprom
  store i32 20, i32* %arrayidx, align 4, !tbaa !2
  %add = add nsw i32 %offset, 8
  %idxprom1 = sext i32 %add to i64
  %arrayidx2 = getelementptr inbounds i32, i32* %arr, i64 %idxprom1
  tail call void @bar(i32* %arrayidx2, i32 %offset)
  ret void
}

; Function Attrs: nounwind uwtable
define dso_local i32 @main(i32 %argc, i8** %argv) local_unnamed_addr #3 {
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
  %idx.ext = sext i32 %call2 to i64
  %add.ptr = getelementptr inbounds i32, i32* %vla, i64 %idx.ext
  %add.ptr3 = getelementptr inbounds i32, i32* %add.ptr, i64 1
  store i32* %add.ptr3, i32** getelementptr inbounds (%struct.List, %struct.List* @node, i64 0, i32 0), align 8, !tbaa !6
  call void @foo(i32* nonnull %add.ptr3, i32 %call2)
  call void @llvm.stackrestore(i8* %1)
  br label %return

return:                                           ; preds = %if.end, %if.then
  ret i32 0
}

declare dso_local i32 @readArgv(i8**, i32) local_unnamed_addr #2

; Function Attrs: nounwind
declare i8* @llvm.stacksave() #4

; Function Attrs: nounwind
declare void @llvm.stackrestore(i8*) #4

; Function Attrs: nofree nounwind
declare i32 @puts(i8* nocapture readonly) local_unnamed_addr #5

attributes #0 = { nofree noinline norecurse nounwind uwtable writeonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }
attributes #5 = { nofree nounwind }

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
