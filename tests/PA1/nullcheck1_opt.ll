; ModuleID = 'nullcheck1.bc'
source_filename = "nullcheck1.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @foo(i32* %arr) #0 {
entry:
  %arr.addr = alloca i32*, align 8
  %ptr = alloca i32*, align 8
  %x = alloca i32*, align 8
  %z = alloca i32, align 4
  store i32* %arr, i32** %arr.addr, align 8
  %call = call i8* @mymalloc(i32 4)
  %0 = bitcast i8* %call to i32*
  store i32* %0, i32** %ptr, align 8
  store i32* null, i32** %x, align 8
  %1 = load i32*, i32** %ptr, align 8
  %arrayidx = getelementptr inbounds i32, i32* %1, i64 0
  store i32 100, i32* %arrayidx, align 4
  %2 = load i32*, i32** %arr.addr, align 8
  store i32* %2, i32** %ptr, align 8
  %3 = load i32*, i32** %ptr, align 8
  %arrayidx1 = getelementptr inbounds i32, i32* %3, i64 100
  %4 = load i32, i32* %arrayidx1, align 4
  store i32 %4, i32* %z, align 4
  %5 = load i32*, i32** %ptr, align 8
  %arrayidx2 = getelementptr inbounds i32, i32* %5, i64 0
  store i32 100, i32* %arrayidx2, align 4
  %6 = load i32*, i32** %ptr, align 8
  %cmp = icmp eq i32* %6, null
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %call3 = call i8* @mymalloc(i32 4)
  %7 = bitcast i8* %call3 to i32*
  store i32* %7, i32** %ptr, align 8
  %8 = load i32*, i32** %ptr, align 8
  %arrayidx4 = getelementptr inbounds i32, i32* %8, i64 0
  store i32 100, i32* %arrayidx4, align 4
  br label %if.end

if.else:                                          ; preds = %entry
  %9 = load i32*, i32** %ptr, align 8
  %arrayidx5 = getelementptr inbounds i32, i32* %9, i64 0
  store i32 100, i32* %arrayidx5, align 4
  br label %if.end

if.end:                                           ; preds = %if.else, %if.then
  %10 = load i32*, i32** %ptr, align 8
  %arrayidx6 = getelementptr inbounds i32, i32* %10, i64 0
  store i32 100, i32* %arrayidx6, align 4
  ret void
}

declare dso_local i8* @mymalloc(i32) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  call void @foo(i32* null)
  ret i32 0
}

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 49d077240ba88639d805c42031ba63ca38f025b6)"}
