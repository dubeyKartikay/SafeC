; ModuleID = 'array.bc'
source_filename = "array.c"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%struct.list = type { i32, %struct.list* }

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @cmp(%struct.list* %node1, %struct.list* %node2) #0 {
entry:
  %node1.addr = alloca %struct.list*, align 8
  %node2.addr = alloca %struct.list*, align 8
  store %struct.list* %node1, %struct.list** %node1.addr, align 8
  store %struct.list* %node2, %struct.list** %node2.addr, align 8
  %0 = load %struct.list*, %struct.list** %node1.addr, align 8
  %info = getelementptr inbounds %struct.list, %struct.list* %0, i32 0, i32 0
  %1 = load i32, i32* %info, align 8
  %2 = load %struct.list*, %struct.list** %node2.addr, align 8
  %info1 = getelementptr inbounds %struct.list, %struct.list* %2, i32 0, i32 0
  %3 = load i32, i32* %info1, align 8
  %cmp = icmp eq i32 %1, %3
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local %struct.list* @find(%struct.list* %head, i32 %val, i32 (%struct.list*, %struct.list*)* %cmp) #0 {
entry:
  %retval = alloca %struct.list*, align 8
  %head.addr = alloca %struct.list*, align 8
  %val.addr = alloca i32, align 4
  %cmp.addr = alloca i32 (%struct.list*, %struct.list*)*, align 8
  %cur = alloca %struct.list*, align 8
  %aux = alloca %struct.list, align 8
  store %struct.list* %head, %struct.list** %head.addr, align 8
  store i32 %val, i32* %val.addr, align 4
  store i32 (%struct.list*, %struct.list*)* %cmp, i32 (%struct.list*, %struct.list*)** %cmp.addr, align 8
  %0 = load %struct.list*, %struct.list** %head.addr, align 8
  store %struct.list* %0, %struct.list** %cur, align 8
  %1 = load i32, i32* %val.addr, align 4
  %info = getelementptr inbounds %struct.list, %struct.list* %aux, i32 0, i32 0
  store i32 %1, i32* %info, align 8
  br label %while.cond

while.cond:                                       ; preds = %if.end, %entry
  %2 = load %struct.list*, %struct.list** %cur, align 8
  %tobool = icmp ne %struct.list* %2, null
  br i1 %tobool, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %3 = load i32 (%struct.list*, %struct.list*)*, i32 (%struct.list*, %struct.list*)** %cmp.addr, align 8
  %4 = load %struct.list*, %struct.list** %cur, align 8
  %call = call i32 %3(%struct.list* %4, %struct.list* %aux)
  %tobool1 = icmp ne i32 %call, 0
  br i1 %tobool1, label %if.then, label %if.end

if.then:                                          ; preds = %while.body
  %5 = load %struct.list*, %struct.list** %cur, align 8
  store %struct.list* %5, %struct.list** %retval, align 8
  br label %return

if.end:                                           ; preds = %while.body
  br label %while.cond

while.end:                                        ; preds = %while.cond
  store %struct.list* null, %struct.list** %retval, align 8
  br label %return

return:                                           ; preds = %while.end, %if.then
  %6 = load %struct.list*, %struct.list** %retval, align 8
  ret %struct.list* %6
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local %struct.list* @insert(%struct.list* %head, i32 %val) #0 {
entry:
  %retval = alloca %struct.list*, align 8
  %head.addr = alloca %struct.list*, align 8
  %val.addr = alloca i32, align 4
  %node = alloca %struct.list*, align 8
  store %struct.list* %head, %struct.list** %head.addr, align 8
  store i32 %val, i32* %val.addr, align 4
  %call = call noalias i8* @malloc(i64 16) #2
  %0 = bitcast i8* %call to %struct.list*
  store %struct.list* %0, %struct.list** %node, align 8
  %1 = load %struct.list*, %struct.list** %node, align 8
  %cmp = icmp eq %struct.list* %1, null
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store %struct.list* null, %struct.list** %retval, align 8
  br label %return

if.end:                                           ; preds = %entry
  %2 = load i32, i32* %val.addr, align 4
  %3 = load %struct.list*, %struct.list** %node, align 8
  %info = getelementptr inbounds %struct.list, %struct.list* %3, i32 0, i32 0
  store i32 %2, i32* %info, align 8
  %4 = load %struct.list*, %struct.list** %head.addr, align 8
  %5 = load %struct.list*, %struct.list** %node, align 8
  %next = getelementptr inbounds %struct.list, %struct.list* %5, i32 0, i32 1
  store %struct.list* %4, %struct.list** %next, align 8
  %6 = load %struct.list*, %struct.list** %node, align 8
  store %struct.list* %6, %struct.list** %retval, align 8
  br label %return

return:                                           ; preds = %if.end, %if.then
  %7 = load %struct.list*, %struct.list** %retval, align 8
  ret %struct.list* %7
}

; Function Attrs: nounwind
declare dso_local noalias i8* @malloc(i64) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %head = alloca [100 x %struct.list*], align 16
  %i = alloca i32, align 4
  %sum = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 0, i32* %sum, align 4
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp slt i32 %0, 100
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %1 = load i32, i32* %i, align 4
  %call = call %struct.list* @insert(%struct.list* null, i32 %1)
  %2 = load i32, i32* %i, align 4
  %idxprom = sext i32 %2 to i64
  %arrayidx = getelementptr inbounds [100 x %struct.list*], [100 x %struct.list*]* %head, i64 0, i64 %idxprom
  store %struct.list* %call, %struct.list** %arrayidx, align 8
  %3 = load i32, i32* %i, align 4
  %idxprom1 = sext i32 %3 to i64
  %arrayidx2 = getelementptr inbounds [100 x %struct.list*], [100 x %struct.list*]* %head, i64 0, i64 %idxprom1
  %4 = load %struct.list*, %struct.list** %arrayidx2, align 8
  %cmp3 = icmp eq %struct.list* %4, null
  br i1 %cmp3, label %cond.true, label %cond.false

cond.true:                                        ; preds = %for.body
  br label %cond.end

cond.false:                                       ; preds = %for.body
  %5 = load i32, i32* %i, align 4
  %idxprom4 = sext i32 %5 to i64
  %arrayidx5 = getelementptr inbounds [100 x %struct.list*], [100 x %struct.list*]* %head, i64 0, i64 %idxprom4
  %6 = load %struct.list*, %struct.list** %arrayidx5, align 8
  %info = getelementptr inbounds %struct.list, %struct.list* %6, i32 0, i32 0
  %7 = load i32, i32* %info, align 8
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ 0, %cond.true ], [ %7, %cond.false ]
  %8 = load i32, i32* %sum, align 4
  %add = add nsw i32 %8, %cond
  store i32 %add, i32* %sum, align 4
  br label %for.inc

for.inc:                                          ; preds = %cond.end
  %9 = load i32, i32* %i, align 4
  %inc = add nsw i32 %9, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %10 = load i32, i32* %sum, align 4
  ret i32 %10
}

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0 (https://github.com/Systems-IIITD/CSE601.git 49d077240ba88639d805c42031ba63ca38f025b6)"}
