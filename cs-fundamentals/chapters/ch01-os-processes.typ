#import "../../shared/lib/style.typ": *

#chapter(num: 1, title: "OS: Processes, Threads & Scheduling",
  tagline: "The CPU has one seat. This chapter is about who sits in it, and for how long.")[

#section[What this round actually looks like]

You sit down. The interviewer has your resume in one hand and a list in the other. Then:

- "What is the difference between a process and a thread?"
- "Draw the process state diagram."
- "Here are four processes with arrival and burst times. Give me the average waiting time
  under SJF."
- "Why is Round Robin fair but slow?"

Three of those four are *definition* questions. One is *arithmetic*. Neither needs
cleverness. Both need practice. That is what this chapter gives you: the words to say, and
the tables to fill in without a single slip.

#formulas(title: "Every formula this chapter needs")[

*The five per-process numbers.* Let $"AT"$ be arrival time, $"BT"$ be burst time (how much
CPU the process needs in total), $"CT"$ be completion time.

$ "Turnaround Time (TAT)" = "CT" - "AT" $
$ "Waiting Time (WT)" = "TAT" - "BT" $
$ "Response Time (RT)" = ("time the CPU first runs it") - "AT" $

Read them in English:
- TAT = total time inside the system, from the moment it walked in to the moment it left.
- WT = the part of that time it spent *not* on the CPU.
- RT = how long before the user saw *anything* happen.

*The two system-wide numbers.*

$ "Throughput" = ("number of processes finished") / ("total time") $
$ "CPU utilisation" = ("time CPU was doing useful work") / ("total time") times 100% $

*Averages.* Add the column, divide by the number of processes. Nothing more.

*CPU utilisation with $n$ processes in memory*, each blocked on I/O a fraction $p$ of the
time: $ "utilisation" = 1 - p^n $

*Amdahl's law* — the ceiling on what more cores can buy you. If a fraction $f$ of the work
can run in parallel and the rest cannot:
$ "speedup"(n) = 1 / ((1 - f) + f/n) quad "and as" n -> infinity, quad "speedup" -> 1/(1-f) $

*Next-burst prediction (exponential average)*, used by practical SJF:
$ tau_(n+1) = alpha t_n + (1 - alpha) tau_n quad "with" 0 <= alpha <= 1 $

*Response ratio*, used by HRRN:
$ "RR" = ("waiting time" + "burst time") / ("burst time") $
]

#section[Part 1 — The process]

#subsection[Program vs process]

A *program* is a file on disk. Bytes. It does nothing.

A *process* is that program *in execution*: the code, plus its current memory, plus the
value of every CPU register, plus its open files. It is *active*.

#trick[
One-line answer to memorise: *"A program is passive — it is a file. A process is active —
it is a program that has been loaded into memory and given resources by the OS. One program
can produce many processes: three browser tabs, three processes, one `chrome` binary."*
]

#subsection[The Process Control Block (PCB)]

The PCB is the OS's record card for one process. When the interviewer asks "what does the OS
store about a process?", say these seven:

#table(columns: 2,
  align: (left, left),
  [*Field*], [*Why it exists*],
  [PID (process id)], [a unique number to name it],
  [Process state], [new / ready / running / waiting / terminated],
  [Program counter], [which instruction to resume at],
  [CPU registers], [the values that were in the registers when it was thrown off the CPU],
  [Scheduling info], [priority, how long it has waited, which queue it is in],
  [Memory info], [page table or base and limit registers],
  [I/O and accounting], [open file table, CPU time used, parent PID],
)

#note[
The PCB is *in kernel memory*, not in the process's own memory. That is on purpose — if a
buggy process could overwrite its own PCB it could give itself any priority it liked.
]

#subsection[The five states]

#diagram(height: 6.2cm, caption: "The five-state process model. Only ONE arrow enters Running, and it comes from Ready.")[
  #dnode(0cm, 2cm, 2.2cm, 1cm, "NEW")
  #dnode(4cm, 2cm, 2.2cm, 1cm, "READY")
  #dnode(8.5cm, 2cm, 2.4cm, 1cm, "RUNNING", fill: rgb("#dfe9f2"))
  #dnode(13.2cm, 2cm, 2.6cm, 1cm, "TERMINATED")
  #dnode(5.8cm, 4.4cm, 3.2cm, 1cm, "WAITING / BLOCKED")
  #darrow(2.2cm, 2.5cm, 4cm, 2.5cm, label: "admit")
  #darrow(6.2cm, 2.15cm, 8.5cm, 2.15cm, label: "dispatch")
  #darrow(8.5cm, 2.85cm, 6.2cm, 2.85cm, label: "preempt")
  #darrow(10.9cm, 2.5cm, 13.2cm, 2.5cm, label: "exit")
  #darrow(9.2cm, 3cm, 8.2cm, 4.4cm, label: "I/O request")
  #darrow(5.8cm, 4.6cm, 4.4cm, 3cm, label: "I/O done")
]

Read the diagram out loud, because that is exactly how you answer it:

+ *New* — the PCB has been created, the process is not yet in memory.
+ *Ready* — in memory, has everything it needs, waiting only for the CPU.
+ *Running* — actually on the CPU. On a single-core machine, exactly one process is here.
+ *Waiting / Blocked* — it asked for something slow (a disk read, a network packet, a
  keypress) and cannot use the CPU until that arrives.
+ *Terminated* — finished; the OS is reclaiming its resources.

#trap[
The single most common wrong answer in this round: *"Waiting goes back to Running."*
It does not. A blocked process whose I/O completes goes to *READY*, and then must be
*dispatched* like everybody else. There is no shortcut back onto the CPU.

Also: there is *no arrow from Ready to Waiting*. A process cannot block on I/O without
first running the instruction that asks for the I/O — and to run an instruction it must be
Running.
]

#ex(1, tier: 0, asked: "warm-up")[
A process is in the RUNNING state. Its time quantum expires. Which state does it move to?
#opts([New], [Ready], [Waiting], [Terminated])
]
#sol[
A quantum expiry means "your turn is over", not "you are waiting for a device". The process
still has everything it needs. It goes back into the queue of things that could run.
#ans[(b) Ready]
]

#ex(2, tier: 1, asked: "Infosys · pattern")[
A process issues a `read()` on a file that is not in the page cache, and later the disk
delivers the data. Write the full sequence of states from just before the `read()` to just
after the process resumes using the data.
]
#sol[
Step by step:

+ Before the call the process is on the CPU: *RUNNING*.
+ `read()` is a system call. The data is not ready, so the kernel cannot return. It marks
  the process *WAITING* and puts its PCB on the disk device's wait queue.
+ The scheduler now picks somebody else. Our process is off the CPU.
+ The disk finishes and raises an interrupt. The interrupt handler moves our process from
  the device queue to the ready queue: *READY*.
+ Some time later the scheduler dispatches it: *RUNNING* again, resuming at the instruction
  after `read()`.

#ans[RUNNING $->$ WAITING $->$ READY $->$ RUNNING]

Notice step 4 and step 5 are separate. Being unblocked is not the same as being scheduled.
]

#subsection[Two more states you should name]

Some textbooks and most real systems add *suspended* states, reached when the OS swaps a
process out to disk to free memory:

- *Ready-suspended*: was ready, now swapped out to disk.
- *Blocked-suspended*: was blocked, now swapped out to disk.

Say this only if asked "are there any other states?" — otherwise five is the expected answer.

#section[Part 2 — What a process looks like in memory]

#diagram(height: 6.4cm, caption: "Left: the address space of one process. Right: two threads inside one process — everything is shared except the stack (and the registers).")[
  #dnode(0.2cm, 0cm, 6.6cm, 0.55cm, "ONE PROCESS", fill: rgb("#e8e8e4"))
  #dnode(0.2cm, 0.75cm, 6.6cm, 0.85cm, "STACK — locals, return addresses (grows DOWN)")
  #dnode(0.2cm, 1.75cm, 6.6cm, 0.7cm, "free space", fill: white)
  #dnode(0.2cm, 2.55cm, 6.6cm, 0.85cm, "HEAP — malloc / new / objects (grows UP)")
  #dnode(0.2cm, 3.5cm, 6.6cm, 0.85cm, "DATA + BSS — globals and statics")
  #dnode(0.2cm, 4.45cm, 6.6cm, 0.85cm, "TEXT — the machine code (read-only)")

  #dnode(8.4cm, 0cm, 7.4cm, 0.55cm, "ONE PROCESS, TWO THREADS", fill: rgb("#e8e8e4"))
  #dnode(8.4cm, 0.75cm, 3.5cm, 0.85cm, "T1 stack (private)", fill: rgb("#f2e9df"))
  #dnode(12.3cm, 0.75cm, 3.5cm, 0.85cm, "T2 stack (private)", fill: rgb("#f2e9df"))
  #dnode(8.4cm, 1.75cm, 7.4cm, 0.7cm, "free space", fill: white)
  #dnode(8.4cm, 2.55cm, 7.4cm, 0.85cm, "HEAP — SHARED by T1 and T2", fill: rgb("#dfe9f2"))
  #dnode(8.4cm, 3.5cm, 7.4cm, 0.85cm, "DATA + BSS — SHARED", fill: rgb("#dfe9f2"))
  #dnode(8.4cm, 4.45cm, 7.4cm, 0.85cm, "TEXT — SHARED", fill: rgb("#dfe9f2"))
]

#table(columns: 3,
  align: (left, left, left),
  [*Segment*], [*Holds*], [*Lifetime*],
  [Text], [compiled instructions], [whole run; usually read-only and shareable],
  [Data], [initialised globals, e.g. `int n = 5;`], [whole run],
  [BSS], [uninitialised globals, e.g. `int n;`], [whole run; zero-filled at load],
  [Heap], [memory you asked for at run time], [until you free it],
  [Stack], [one frame per function call: parameters, locals, return address], [until the function returns],
)

#trap[
"Stack overflow" and "heap overflow" are different bugs.
*Stack overflow* = too many nested calls (usually runaway recursion) so the stack grows
down into the heap's space. *Heap exhaustion* = you keep allocating and never free, so
allocation fails. In Node the first shows as `RangeError: Maximum call stack size exceeded`
and the second as `JavaScript heap out of memory`.
]

#ex(3, tier: 1, asked: "TCS NQT · pattern")[
Where does each of these live?
(i) a `const` array created with `new Array(1000)` inside a function,
(ii) the variable that holds the reference to it,
(iii) the function's compiled code.
]
#sol[
In a language with a heap and a stack — which is every language you will be asked about:

+ *(i)* The 1000-element array itself is an object created at run time. Objects go on the
  *heap*.
+ *(ii)* The variable is a local of the function, so the *reference* (a pointer-sized value)
  lives in that function's *stack frame*.
+ *(iii)* The instructions are fixed at compile time: *text segment*.

#ans[heap / stack / text]

This is why "pass by reference vs pass by value" gets confusing: JS always copies the
*value in the stack slot*, and for an object that value is a reference to the heap.
]

#section[Part 3 — Making processes: fork, exec, wait]

This is one place where the language policy of this series bends, on purpose. `fork()` is a
C idea and interviewers ask it in C. Learn the shape; the Node version comes right after.

#code(lang: "c", caption: "The classic fork shape — what the interviewer expects to see")[
```c
pid_t pid = fork();          /* ONE call, TWO returns */

if (pid < 0) {
    /* fork failed */
} else if (pid == 0) {
    /* CHILD: fork() returned 0 here */
    execlp("ls", "ls", "-l", NULL);   /* replaces this process image */
} else {
    /* PARENT: fork() returned the child's PID here */
    wait(NULL);              /* sleep until the child exits; reaps the zombie */
}
```
]

Four facts, and each one is a question on its own:

+ *`fork()` returns twice.* Once in the parent (returning the child's PID, a positive
  number) and once in the child (returning `0`). That is how each one knows who it is.
+ *The child is a copy* of the parent: same code, same data, same open file descriptors,
  different PID. Modern systems use *copy-on-write* — the pages are shared read-only until
  one side writes, and only then is a real copy made.
+ *`exec()` does not create a process.* It *replaces* the current process image with a new
  program. Same PID, brand new text/data/heap/stack. On success `exec` never returns,
  because there is no longer any code to return to.
+ *`wait()`* blocks the parent until a child exits and collects the child's exit status.

#subsection[Zombie and orphan — the two words you must get right]

#table(columns: 3,
  align: (left, left, left),
  [], [*Zombie*], [*Orphan*],
  [Who died], [the *child* died], [the *parent* died],
  [What is wrong], [parent never called `wait()`, so the exit status is still sitting in the
   process table], [child is still running but has no parent to report to],
  [What it costs], [one process-table entry (a PID) — leaks if repeated], [nothing],
  [Who fixes it], [the parent, by calling `wait()`; if the parent dies the zombie is
   re-parented to `init` which reaps it], [`init` (PID 1) adopts it],
)

#trap[
A zombie is *not* consuming CPU or memory. It is a dead process whose *table entry* has not
been removed. The damage is PID exhaustion, not slowness. Saying "a zombie eats CPU" is the
classic wrong answer.
]

#ex(4, tier: 2, asked: "Shopee · pattern")[
How many *new* processes does this create, and how many lines does it print?
```c
int main() {
    fork();
    fork();
    fork();
    printf("hi\n");
}
```
]
#sol[
Track the count after each `fork()`. Every existing process splits into two.

#table(columns: 3, align: (left, right, right),
  [*After*], [*Processes alive*], [*Reason*],
  [start], [1], [the original],
  [1st `fork()`], [2], [$1 times 2$],
  [2nd `fork()`], [4], [$2 times 2$ — the child forks too],
  [3rd `fork()`], [8], [$4 times 2$],
)

All 8 reach the `printf`.

#ans[$2^3 = 8$ processes total, so *7 new* children, and *8* lines printed]

General rule: $n$ unconditional `fork()` calls in a row give $2^n$ processes, i.e. $2^n - 1$
new ones.
]

#ex(5, tier: 3, asked: "Amazon · pattern")[
Same question, but now the calls are:
```c
fork();
if (fork() == 0) { fork(); }
printf("hi\n");
```
How many lines are printed?
]
#sol[
Do it in layers. Do not guess.

*After line 1* (`fork()`): 2 processes. Call them A and B.

*Line 2* (`if (fork() == 0)`): each of A and B forks, giving 4 processes:
- A (parent side, `fork` returned a PID $!= 0$) — condition false
- A's child (`fork` returned 0) — condition *true*
- B (parent side) — condition false
- B's child — condition *true*

*Line 3*: only the two processes with a true condition run the inner `fork()`. Each becomes
two. So those 2 become 4, and the 2 false-side processes stay as they are.

Total $= 2 + 4 = 6$.

#ans[6 lines]

#trick[
Method that never fails: draw a tree. Each `fork()` node has two children — the "parent
return" branch and the "child return" branch. Count the *leaves* that reach the print.
]
]

#subsection[The Node equivalent]

Node cannot `fork()` in the Unix sense. It gives you two different tools, and the difference
between them *is* the process-vs-thread difference:

#code(lang: "js", caption: "Threads share memory. Processes do not. Run with: node s2.js")[
```js
const { Worker, isMainThread, workerData } = require('worker_threads');
const { fork } = require('child_process');

if (isMainThread && !process.env.CHILD) {
  // 1) two THREADS, one shared buffer
  const shared = new Int32Array(new SharedArrayBuffer(4));
  shared[0] = 100;
  const w = new Worker(__filename, { workerData: shared });
  w.on('exit', () => {
    console.log('THREAD  : parent sees shared[0] =', shared[0]);
    // 2) a child PROCESS gets a COPY, not the same memory
    const child = fork(__filename, [], { env: { ...process.env, CHILD: '1' } });
    let myCounter = 100;
    child.on('message', (m) => {
      console.log('PROCESS : child set its counter to', m.counter);
      console.log('PROCESS : parent still sees myCounter =', myCounter);
      child.kill();
    });
  });
} else if (!isMainThread) {
  workerData[0] = 999;          // writes the PARENT's memory
} else {
  let myCounter = 100;
  myCounter = 999;              // writes only THIS process's copy
  process.send({ counter: myCounter });
}
```
]

#code(lang: "text", caption: "Actual output")[
```text
THREAD  : parent sees shared[0] = 999
PROCESS : child set its counter to 999
PROCESS : parent still sees myCounter = 100
```
]

That output is the whole lesson. The thread changed the parent's number. The process could
not, and had to *send a message* instead.

#section[Part 4 — Threads]

A *thread* is one flow of execution inside a process. Every process starts with one thread.
A multithreaded process has several, all inside the same address space.

#subsection[The table the interviewer wants]

#table(columns: 3,
  align: (left, left, left),
  [], [*Process*], [*Thread*],
  [Address space], [its own], [shared with its siblings],
  [Code / data / heap], [private], [*shared*],
  [Stack and registers], [private], [*private* — each thread has its own],
  [Creation cost], [high (new page tables, new PCB)], [low],
  [Context switch cost], [high — must switch page tables, flush the TLB], [low — same page tables],
  [Communication], [IPC: pipes, sockets, shared-memory segments, message queues], [just read the same variable],
  [If one crashes], [the others survive], [the whole process usually dies],
  [Protection], [OS isolates them], [none between threads — they can corrupt each other],
)

#trick[
Compress the whole table into one sentence you can say in five seconds:
*"Threads share the address space; processes do not. So threads are cheap to create and
cheap to switch between, but one bad thread can corrupt the others; processes are expensive
and isolated."*
]

#trap[
"Threads share the stack" — wrong, and it is the answer that ends the round. Each thread
gets its *own* stack, because each thread is in the middle of its own chain of function
calls. What they share is text, data and *heap*.
]

#subsection[User threads vs kernel threads]

- *Kernel-level threads*: the OS knows about each thread and schedules each one. Real
  parallelism on multiple cores. Slower to create (a system call).
- *User-level threads*: a library in user space multiplexes many threads onto fewer kernel
  threads. Very fast to create and switch (no system call). *But* if one user thread makes
  a blocking system call, the kernel blocks the whole kernel thread, and every user thread
  on it stops.

The three mapping models:

#table(columns: 3,
  align: (left, left, left),
  [*Model*], [*Meaning*], [*Main weakness*],
  [Many-to-one], [many user threads on 1 kernel thread], [one blocking call freezes all; no multi-core use],
  [One-to-one], [each user thread has its own kernel thread], [creating threads is expensive, so the OS caps the count],
  [Many-to-many], [$m$ user threads on $n$ kernel threads, $n <= m$], [complex to implement],
)

#ex(6, tier: 2, asked: "Grab · pattern")[
A service uses a many-to-one threading library. One of its 50 threads calls a synchronous
file read that takes 200 ms. How long are the other 49 threads stalled, and why?
]
#sol[
+ In many-to-one, all 50 user threads are multiplexed onto *one* kernel thread.
+ A synchronous read is a *blocking system call*. The kernel does not know about user
  threads; it only sees the one kernel thread that made the call.
+ So the kernel moves that kernel thread to the WAITING state.
+ The user-level scheduler lives *inside* that kernel thread. With the kernel thread
  blocked, nothing in user space runs — not even the thread scheduler.

#ans[All 49 stall for the full 200 ms.]

The fix in an interview answer: use one-to-one (or many-to-many) mapping, or use
non-blocking / asynchronous I/O so the call never blocks the kernel thread. That second
option is exactly what Node does.
]

#subsection[Why Node is "single-threaded" and what that really means]

Your JavaScript runs on *one* thread. I/O does not — libuv keeps a pool of worker threads
(4 by default) for file system work, and the kernel handles sockets asynchronously.

Consequence: a long synchronous loop blocks *everything*.

#code(lang: "js", caption: "One thread means one blocker stops the world. Run with: node s3.js")[
```js
const t0 = Date.now();
const stamp = (msg) => console.log(`t=${String(Date.now() - t0).padStart(4)} ms  ${msg}`);

setTimeout(() => stamp('timer that asked for 0 ms finally ran'), 0);
stamp('main line starts a 600 ms busy loop');
const end = Date.now() + 600;
while (Date.now() < end) { /* burn CPU - no yield */ }
stamp('busy loop finished');
```
]

#code(lang: "text", caption: "Actual output")[
```text
t=   0 ms  main line starts a 600 ms busy loop
t= 603 ms  busy loop finished
t= 603 ms  timer that asked for 0 ms finally ran
```
]

The timer asked for 0 ms and waited 603 ms. Nothing was broken; the one thread was busy.
This is cooperative scheduling: Node cannot preempt your loop the way the OS preempts a
process.

#subsection[Amdahl's law — the answer to "just add more cores"]

Suppose 75% of a job can be split across cores and 25% cannot.

#table(columns: 3, align: (left, right, left),
  [*Cores $n$*], [*Speedup*], [*Working*],
  [1], [1.00], [$1 slash (0.25 + 0.75 slash 1)$],
  [2], [1.60], [$1 slash (0.25 + 0.375) = 1 slash 0.625$],
  [4], [2.29], [$1 slash (0.25 + 0.1875) = 1 slash 0.4375$],
  [8], [2.91], [$1 slash (0.25 + 0.09375)$],
  [16], [3.37], [$1 slash (0.25 + 0.046875)$],
  [1000], [3.99], [$1 slash (0.25 + 0.00075)$],
)

A thousand cores buys you less than 4$times$. The ceiling is $1/(1-f) = 1/0.25 = 4$.

#ans[If 25% is serial, you can never beat 4$times$, no matter how many cores you buy.]

#section[Part 5 — The context switch]

#diagram(height: 4.2cm, caption: "A context switch. Everything between the two user-mode boxes is pure overhead: the CPU is busy but no user work is done.")[
  #dnode(0cm, 1.3cm, 3.4cm, 1cm, "P1 running\n(user mode)")
  #dnode(3.7cm, 1.3cm, 3.3cm, 1cm, "save P1 registers\ninto PCB1", fill: rgb("#f2e9df"))
  #dnode(7.3cm, 1.3cm, 2.9cm, 1cm, "scheduler picks\nthe next process", fill: rgb("#f2e9df"))
  #dnode(10.5cm, 1.3cm, 2.9cm, 1cm, "load PCB2\ninto registers", fill: rgb("#f2e9df"))
  #dnode(13.7cm, 1.3cm, 2.9cm, 1cm, "P2 running\n(user mode)")
  #dnode(3.7cm, 0.35cm, 9.7cm, 0.6cm, "KERNEL MODE — overhead, zero useful work", fill: rgb("#e8e8e4"))
  #darrow(0cm, 3.1cm, 16.6cm, 3.1cm)
  #dnode(6.2cm, 3.2cm, 4.2cm, 0.6cm, "time", fill: white)
]

*What gets saved and restored:* program counter, all general registers, the stack pointer,
the processor status word, and memory-management state (the page-table base register).

*What it costs:* typically 1 to 10 microseconds of direct cost. The *indirect* cost is
worse: the new process finds the CPU caches and the TLB full of the old process's data, so
it runs slowly until they refill. This is called *cache pollution*.

#ex(7, tier: 2, asked: "Agoda · pattern")[
A context switch costs 5 microseconds. Compare the CPU cost at 1,000 switches per second
and at 100,000 switches per second.
]
#sol[
+ At 1,000 per second:
  $5 "μs" times 1000 = 5000 "μs" = 5 "ms"$ of every 1000 ms.
  $5/1000 = 0.5%$ of the CPU.
+ At 100,000 per second:
  $5 "μs" times 100000 = 500000 "μs" = 0.5 "s"$ of every 1 s.
  $= 50%$ of the CPU.

#ans[0.5% vs 50%. Switching 100$times$ more often costs half the machine.]

That is the whole argument for not making the Round Robin quantum tiny.
]

#trap[
A *context switch* (between processes) is not the same as a *mode switch* (user mode to
kernel mode and back, which happens on every system call). A mode switch is much cheaper and
does not change which process is running. Every context switch involves mode switches; not
every mode switch is a context switch.
]

#section[Part 6 — Who schedules what]

#table(columns: 4,
  align: (left, left, left, left),
  [*Scheduler*], [*Decides*], [*Runs*], [*Controls*],
  [Long-term (job)], [which jobs enter the ready queue at all], [rarely (seconds/minutes)],
    [the degree of multiprogramming],
  [Medium-term], [which processes to swap out to disk], [sometimes], [memory pressure],
  [Short-term (CPU)], [which ready process gets the CPU next], [very often (milliseconds)],
    [responsiveness],
)

The *dispatcher* is not a scheduler. The scheduler *chooses*; the dispatcher *does the
handover* — switch context, switch to user mode, jump to the right instruction. The time it
takes is *dispatch latency*.

#subsection[Preemptive vs non-preemptive]

- *Non-preemptive*: once a process has the CPU it keeps it until it finishes or blocks.
  Simple. A long job can hold everyone up.
- *Preemptive*: the OS can take the CPU away (timer interrupt, or a higher-priority process
  arrives). Responsive. Costs more switches, and opens the door to race conditions on
  shared kernel data.

Scheduling decisions happen at four moments. Two are unavoidable, two are optional:

#table(columns: 3, align: (left, left, left),
  [*Moment*], [*Transition*], [*Preemptive only?*],
  [Process blocks on I/O], [Running $->$ Waiting], [no],
  [Process terminates], [Running $->$ Terminated], [no],
  [Quantum expires / higher priority arrives], [Running $->$ Ready], [*yes*],
  [I/O completes for some other process], [Waiting $->$ Ready], [*yes*],
)

#trick[
If *only* the first two cause a scheduling decision, the scheme is non-preemptive.
]

#section[Part 7 — The algorithms, with the arithmetic done in full]

Everything from here is the part you will actually be asked to *compute*. One worked set
runs through all of them so you can see the numbers move.

#formulas(title: "The master set used below")[
#table(columns: 5, align: (left, right, right, right, right),
  [*Process*], [*P1*], [*P2*], [*P3*], [*P4*],
  [Arrival time], [0], [1], [2], [3],
  [Burst time], [8], [4], [9], [5],
)
Total burst $= 8 + 4 + 9 + 5 = 26$. Nobody is idle, so *every* algorithm finishes at
$t = 26$. Only the order inside changes.
]

#subsection[7.1 FCFS — First Come First Served]

Rule: run in order of arrival. Non-preemptive. One queue, no thinking.

#code(lang: "text", caption: "FCFS Gantt chart")[
```text
|   P1   | P2 |    P3   |  P4 |
0        8    12        21    26
```
]

Now fill the table. Take one row at a time and show the subtraction.

#table(columns: 6, align: (left, right, right, right, right, right),
  [*P*], [*AT*], [*BT*], [*CT*], [*TAT = CT − AT*], [*WT = TAT − BT*],
  [P1], [0], [8], [8],  [$8 - 0 = 8$],   [$8 - 8 = 0$],
  [P2], [1], [4], [12], [$12 - 1 = 11$], [$11 - 4 = 7$],
  [P3], [2], [9], [21], [$21 - 2 = 19$], [$19 - 9 = 10$],
  [P4], [3], [5], [26], [$26 - 3 = 23$], [$23 - 5 = 18$],
)

Averages: $"TAT" = (8 + 11 + 19 + 23)/4 = 61/4 = 15.25$ and
$"WT" = (0 + 7 + 10 + 18)/4 = 35/4 = 8.75$.

Response time equals waiting time here, because FCFS never preempts: the first time a
process touches the CPU is the only time it starts.

#ans[FCFS: avg TAT $= 15.25$, avg WT $= 8.75$, avg RT $= 8.75$]

#subsection[The convoy effect]

#code(lang: "text", caption: "One long job first — AT/BT: P1(0,20), P2(1,3), P3(2,3)")[
```text
|         P1         | P2 | P3 |
0                    20   23   26
```
]

$"WT" = (0 + 19 + 21)/3 = 40/3 = 13.33$. Two three-unit jobs waited about 20 units each
behind one 20-unit job. That is the *convoy effect*: short jobs stuck behind a long one,
like cars behind a truck on a single-lane road.

#trap[
FCFS is the only algorithm with *no starvation at all* — everyone eventually reaches the
front of one queue. Do not confuse "bad average waiting time" with "starvation". FCFS is bad
but fair; Priority is good but can starve.
]

#subsection[7.2 SJF — Shortest Job First (non-preemptive)]

Rule: when the CPU is free, among the processes that *have arrived*, pick the smallest burst.
Once started, a process runs to completion.

Walk the clock:

+ $t = 0$: only P1 has arrived. Run P1 for its full 8. CPU busy until $t = 8$.
+ $t = 8$: arrived and unfinished are P2 (4), P3 (9), P4 (5). Smallest is *P2* (4). Runs
  to $t = 12$.
+ $t = 12$: P3 (9) and P4 (5) remain. Smallest is *P4*. Runs to $t = 17$.
+ $t = 17$: only *P3*. Runs to $t = 26$.

#code(lang: "text", caption: "SJF (non-preemptive) Gantt chart")[
```text
|   P1   | P2 |  P4 |    P3   |
0        8    12    17        26
```
]

#table(columns: 6, align: (left, right, right, right, right, right),
  [*P*], [*AT*], [*BT*], [*CT*], [*TAT*], [*WT*],
  [P1], [0], [8], [8],  [8],  [0],
  [P2], [1], [4], [12], [11], [7],
  [P3], [2], [9], [26], [24], [15],
  [P4], [3], [5], [17], [14], [9],
)

$"avg TAT" = 57/4 = 14.25$, $"avg WT" = 31/4 = 7.75$.

#ans[SJF: avg TAT $= 14.25$, avg WT $= 7.75$]

Better than FCFS ($8.75 -> 7.75$) but not by much, because P1's 8 units still blocked
everyone at the start.

#trap[
"SJF is optimal" is true *only* for non-preemptive scheduling of a fixed set of jobs
available at the same time, and only for *average waiting time*. In this example SJF gives
7.75 and preemptive SRTF gives 6.50 — SRTF is the optimal one when arrivals are staggered.
Say: *"SJF gives the minimum average waiting time among non-preemptive schemes; SRTF is its
preemptive version and does better when jobs arrive at different times."*
]

#subsection[The real problem with SJF: you do not know the burst]

The OS cannot see the future. It *predicts* the next burst from the previous ones with an
exponential average:

$ tau_(n+1) = alpha t_n + (1 - alpha) tau_n $

With $alpha = 0.5$ and a starting guess $tau_0 = 10$:

#table(columns: 4, align: (left, right, right, left),
  [*Burst no.*], [*Actual $t_n$*], [*New guess $tau_(n+1)$*], [*Working*],
  [1], [6],  [8.000],  [$0.5(6) + 0.5(10) = 3 + 5$],
  [2], [4],  [6.000],  [$0.5(4) + 0.5(8) = 2 + 4$],
  [3], [6],  [6.000],  [$0.5(6) + 0.5(6) = 3 + 3$],
  [4], [13], [9.500],  [$0.5(13) + 0.5(6) = 6.5 + 3$],
  [5], [13], [11.250], [$0.5(13) + 0.5(9.5)$],
  [6], [13], [12.125], [$0.5(13) + 0.5(11.25)$],
)

Notice row 4: the guess jumps only halfway towards the new reality, then creeps closer.
That is the point of $alpha$.

- $alpha = 0$: $tau_(n+1) = tau_n$. History never changes the guess.
- $alpha = 1$: $tau_(n+1) = t_n$. Only the most recent burst matters.

#subsection[7.3 SRTF — Shortest Remaining Time First (preemptive SJF)]

Rule: at *every* arrival, compare the new arrival's burst with the *remaining* time of the
running process. Smaller remaining wins.

Walk the clock. This is where students lose marks, so every tick is shown.

+ $t = 0$: only P1 (rem 8). Run P1.
+ $t = 1$: P2 arrives with 4. P1 has $8 - 1 = 7$ left. $4 < 7$, so *preempt*. Run P2.
+ $t = 2$: P3 arrives with 9. P2 has $4 - 1 = 3$ left. $9 > 3$, no preemption. P2 continues.
+ $t = 3$: P4 arrives with 5. P2 has 2 left. $5 > 2$, no preemption. P2 continues.
+ $t = 5$: P2 finishes. Remaining now: P1 = 7, P3 = 9, P4 = 5. Smallest is *P4* (5).
+ $t = 10$: P4 finishes. Remaining: P1 = 7, P3 = 9. Smallest is *P1*.
+ $t = 17$: P1 finishes. Only *P3* left; it runs to 26.

#code(lang: "text", caption: "SRTF Gantt chart")[
```text
| P1 | P2 |  P4 |   P1  |    P3   |
0    1    5     10      17        26
```
]

#table(columns: 7, align: (left, right, right, right, right, right, right),
  [*P*], [*AT*], [*BT*], [*CT*], [*TAT*], [*WT*], [*RT*],
  [P1], [0], [8], [17], [17], [9],  [0],
  [P2], [1], [4], [5],  [4],  [0],  [0],
  [P3], [2], [9], [26], [24], [15], [15],
  [P4], [3], [5], [10], [7],  [2],  [2],
)

Check P1 by hand: it ran 0–1 and 10–17, which is $1 + 7 = 8$ units. Correct.
$"TAT" = 17 - 0 = 17$, $"WT" = 17 - 8 = 9$. RT is 0 because it started at $t = 0$.

$"avg TAT" = 52/4 = 13.00$, $"avg WT" = 26/4 = 6.50$, $"avg RT" = 17/4 = 4.25$.

#ans[SRTF: avg TAT $= 13.00$, avg WT $= 6.50$ — the best of all five here]

#trap[
Response time is *not* waiting time once preemption exists. P1 above has RT $= 0$ and
WT $= 9$. If a question says "response time" and you hand in waiting time, you lose the mark.
]

#subsection[7.4 Priority scheduling]

Rule: smallest priority number = highest priority (this is the usual convention; *state your
convention in the interview*, because some books reverse it).

New data set — AT/BT/priority: P1(0, 4, 3), P2(1, 3, 1), P3(2, 5, 4), P4(3, 2, 2).

*Non-preemptive:*

+ $t = 0$: only P1. Run it to completion, $t = 4$.
+ $t = 4$: P2(1), P3(4), P4(2) waiting. Best is P2. Run to $t = 7$.
+ $t = 7$: P3(4), P4(2). Best is P4. Run to $t = 9$.
+ $t = 9$: P3 runs to $t = 14$.

#code(lang: "text", caption: "Priority, non-preemptive")[
```text
| P1 | P2 | P4 |  P3 |
0    4    7    9     14
```
]

#table(columns: 6, align: (left, right, right, right, right, right),
  [*P*], [*prio*], [*BT*], [*CT*], [*TAT*], [*WT*],
  [P1], [3], [4], [4],  [4],  [0],
  [P2], [1], [3], [7],  [6],  [3],
  [P3], [4], [5], [14], [12], [7],
  [P4], [2], [2], [9],  [6],  [4],
)
$"avg TAT" = 28/4 = 7.00$, $"avg WT" = 14/4 = 3.50$.

*Preemptive, same data:*

+ $t = 0$: P1 (prio 3) runs.
+ $t = 1$: P2 (prio 1) arrives. $1 < 3$: preempt. P1 has 3 left.
+ $t = 2$: P3 (prio 4) arrives. $4 > 1$: no.
+ $t = 3$: P4 (prio 2) arrives. $2 > 1$: no. P2 keeps going.
+ $t = 4$: P2 done. Waiting: P1(3, rem 3), P3(4, rem 5), P4(2, rem 2). Best is P4.
+ $t = 6$: P4 done. P1(3) beats P3(4). P1 runs its remaining 3 to $t = 9$.
+ $t = 9$: P3 runs to $t = 14$.

#code(lang: "text", caption: "Priority, preemptive")[
```text
| P1 | P2 | P4 | P1 |  P3 |
0    1    4    6    9     14
```
]

#table(columns: 7, align: (left, right, right, right, right, right, right),
  [*P*], [*prio*], [*BT*], [*CT*], [*TAT*], [*WT*], [*RT*],
  [P1], [3], [4], [9],  [9],  [5], [0],
  [P2], [1], [3], [4],  [3],  [0], [0],
  [P3], [4], [5], [14], [12], [7], [7],
  [P4], [2], [2], [6],  [3],  [1], [1],
)
$"avg TAT" = 27/4 = 6.75$, $"avg WT" = 13/4 = 3.25$, $"avg RT" = 8/4 = 2.00$.

#ans[Preemptive priority beats non-preemptive here: WT $3.25$ vs $3.50$, RT $2.00$ vs $3.50$]

#subsection[Starvation and aging]

If high-priority work keeps arriving, a low-priority process may *never* run. That is
*starvation* (also called indefinite blocking).

The fix is *aging*: increase a process's priority by 1 for every fixed period it spends
waiting. A priority-10 process that waits long enough becomes priority 0 and must run.

#ex(8, tier: 2, asked: "DBS · pattern")[
A batch job has priority 15 (lowest). The scheduler ages waiting processes by one level
every 30 seconds. Highest priority is 0. What is the longest the job can wait before it is
*guaranteed* to be the highest-priority process in the queue?
]
#sol[
+ It must climb from 15 to 0. That is 15 steps.
+ Each step takes 30 seconds.
+ $15 times 30 = 450$ seconds $= 7.5$ minutes.

#ans[7.5 minutes to reach priority 0]

Careful reading: reaching priority 0 makes it *tied* for highest, not automatically first.
It is guaranteed to run only if ties are broken by waiting time (FCFS within a level), which
is what real agers do. Say that out loud — it is the follow-up question.
]

#subsection[7.5 Round Robin]

Rule: FCFS with a time limit. Each process gets at most one *quantum* $q$. If it is not
finished, it goes to the *back* of the ready queue.

The one rule people get wrong: *when a process's quantum expires at the same instant another
process arrives, the arriving process joins the queue FIRST*, then the preempted one. Say
your convention; most textbooks and most papers use this one.

Back to the master set, $q = 2$. Here is the queue after *every* slice. Copy this habit —
write the queue down, do not keep it in your head.

#table(columns: 5, align: (right, left, right, left, left),
  [*Time*], [*Runs*], [*Its rem.*], [*Arrives during the slice*], [*Ready queue after*],
  [0–2],   [P1], [6], [P2 at 1, P3 at 2], [P2, P3, P1],
  [2–4],   [P2], [2], [P4 at 3],          [P3, P1, P4, P2],
  [4–6],   [P3], [7], [—],                [P1, P4, P2, P3],
  [6–8],   [P1], [4], [—],                [P4, P2, P3, P1],
  [8–10],  [P4], [3], [—],                [P2, P3, P1, P4],
  [10–12], [P2], [0], [—],                [P3, P1, P4 #h(3pt) (P2 done, CT 12)],
  [12–14], [P3], [5], [—],                [P1, P4, P3],
  [14–16], [P1], [2], [—],                [P4, P3, P1],
  [16–18], [P4], [1], [—],                [P3, P1, P4],
  [18–20], [P3], [3], [—],                [P1, P4, P3],
  [20–22], [P1], [0], [—],                [P4, P3 #h(3pt) (P1 done, CT 22)],
  [22–23], [P4], [0], [—],                [P3 #h(3pt) (P4 done, CT 23; only 1 unit left)],
  [23–26], [P3], [0], [—],                [empty (P3 done, CT 26)],
)

Two things to notice. At $t = 2$, P3 arrives at exactly the moment P1's quantum ends, and
our convention puts the *arrival* into the queue before the *preempted* process — that is
why the queue reads "P2, P3, P1" and not "P2, P1, P3". And at $t = 22$, P4 has only 1 unit
left, so its slice is shorter than the quantum. A process never runs longer than it needs.

Collapsed into a chart:

#code(lang: "text", caption: "Round Robin, q = 2")[
```text
| P1 | P2 | P3 | P1 | P4 | P2 | P3 | P1 | P4 | P3 | P1 | P4 | P3 |
0    2    4    6    8    10   12   14   16   18   20   22   23   26
```
]

#table(columns: 7, align: (left, right, right, right, right, right, right),
  [*P*], [*AT*], [*BT*], [*CT*], [*TAT*], [*WT*], [*RT*],
  [P1], [0], [8], [22], [22], [14], [0],
  [P2], [1], [4], [12], [11], [7],  [1],
  [P3], [2], [9], [26], [24], [15], [2],
  [P4], [3], [5], [23], [20], [15], [5],
)
$"avg TAT" = 77/4 = 19.25$, $"avg WT" = 51/4 = 12.75$, $"avg RT" = 8/4 = 2.00$.

#ans[RR ($q=2$): worst average waiting time (12.75) but the *best* average response time (2.00)]

That trade is the entire point of Round Robin. Nobody finishes early; everybody starts early.

#subsection[Choosing the quantum]

Same data, three quantum values:

#table(columns: 5, align: (left, right, right, right, left),
  [*Quantum*], [*avg TAT*], [*avg WT*], [*avg RT*], [*Comment*],
  [$q = 2$], [19.25], [12.75], [2.00], [snappiest start, most switching],
  [$q = 3$], [20.00], [13.50], [3.00], [middle],
  [$q = 4$], [18.25], [11.75], [4.50], [fewer switches, slower first response],
  [$q >= 9$], [15.25], [8.75],  [8.75], [identical to FCFS],
)

#trick[
Two limits to memorise:
*$q -> infinity$ turns Round Robin into FCFS.* (Nobody is ever preempted.)
*$q -> 0$ turns it into "processor sharing"* — in theory everybody progresses at $1/n$
speed; in practice the machine dies of context-switch overhead.
]

Here is that overhead, computed. Four processes, 10 units of burst each (40 units of useful
work), context switch cost $s = 1$ unit:

#table(columns: 5, align: (right, right, right, right, right),
  [*$q$*], [*slices*], [*switches*], [*total time*], [*efficiency*],
  [1],  [40], [39], [79], [50.6%],
  [2],  [20], [19], [59], [67.8%],
  [5],  [8],  [7],  [47], [85.1%],
  [10], [4],  [3],  [43], [93.0%],
)

Working for $q = 2$: each process needs $ceil(10/2) = 5$ slices, so $4 times 5 = 20$ slices
and 19 switches between them. Useful work 40, overhead $19 times 1 = 19$, total 59.
Efficiency $= 40/59 = 67.8%$.

#ans[Rule of thumb: pick $q$ so that about 80% of bursts finish inside one quantum. Real
systems use 10–100 ms.]

#subsection[7.6 HRRN — Highest Response Ratio Next]

Non-preemptive. At each decision point compute, for every waiting process,

$ "RR" = ("waiting so far" + "burst") / "burst" $

and run the largest. Short jobs get a big ratio immediately (good, like SJF); long jobs get
a big ratio eventually (good, no starvation).

New data — AT/BT: P1(0, 6), P2(2, 2), P3(3, 1), P4(5, 4).

+ $t = 0$: only P1. Run 0–6.
+ $t = 6$: P2 waited $6 - 2 = 4$, P3 waited $6 - 3 = 3$, P4 waited $6 - 5 = 1$.
  - P2: $(4 + 2)/2 = 3.000$
  - P3: $(3 + 1)/1 = 4.000$ #h(4pt) $<-$ largest
  - P4: $(1 + 4)/4 = 1.250$
  Run P3, 6–7.
+ $t = 7$: P2: $(5 + 2)/2 = 3.500$; P4: $(2 + 4)/4 = 1.500$. Run P2, 7–9.
+ $t = 9$: only P4. Runs 9–13.

#code(lang: "text", caption: "HRRN Gantt chart")[
```text
|  P1  | P3 | P2 | P4 |
0      6    7    9    13
```
]

#table(columns: 6, align: (left, right, right, right, right, right),
  [*P*], [*AT*], [*BT*], [*CT*], [*TAT*], [*WT*],
  [P1], [0], [6], [6],  [6], [0],
  [P2], [2], [2], [9],  [7], [5],
  [P3], [3], [1], [7],  [4], [3],
  [P4], [5], [4], [13], [8], [4],
)
$"avg TAT" = 25/4 = 6.25$, $"avg WT" = 12/4 = 3.00$.

#ans[HRRN: avg WT $= 3.00$, and no process can starve]

#subsection[7.7 Multilevel Queue and Multilevel Feedback Queue]

*Multilevel Queue (MLQ).* Split processes permanently into classes, each with its own queue
and its own algorithm. For example: system processes (RR, $q = 8$), interactive (RR,
$q = 16$), batch (FCFS). Scheduling *between* queues is usually fixed priority — nothing in
the batch queue runs while anything interactive is ready. A process *cannot change queue*.
Risk: starvation of the lowest queue.

*Multilevel Feedback Queue (MLFQ).* Same idea, but a process *can move between queues*.
That one word — feedback — is the whole difference, and it is the answer to
"what is the difference between MLQ and MLFQ?".

The usual rules:

+ A new process enters the *highest* queue.
+ If it uses its whole quantum, it is demoted one level (it looks CPU-bound).
+ If it blocks for I/O before the quantum ends, it stays (it looks interactive).
+ Every so often, everything is promoted back to the top (that is aging — it prevents
  starvation).

#ex(9, tier: 3, asked: "Microsoft · pattern")[
An MLFQ has three levels: Q0 (RR, $q = 4$), Q1 (RR, $q = 8$), Q2 (FCFS). A process needs
20 units of CPU and never does I/O. Trace which queues it visits, and how much CPU it gets
in each.
]
#sol[
+ *Enters Q0.* Runs 4 units (its whole quantum). Remaining $20 - 4 = 16$. Demoted to Q1.
+ *In Q1.* Runs 8 units. Remaining $16 - 8 = 8$. Demoted to Q2.
+ *In Q2.* FCFS, no quantum. It runs its last 8 units to completion whenever it reaches the
  front.

#ans[Q0: 4 units, Q1: 8 units, Q2: 8 units. Total 20.]

The follow-up: *"why is this good?"* Because a CPU-bound job sinks to the bottom after only
$4 + 8 = 12$ units of measurement, and from then on interactive jobs — which block quickly
and stay in Q0 — get the CPU almost immediately. MLFQ *learns* which jobs are interactive
without being told.

Second follow-up: *"can that job starve?"* Yes, in Q2, if interactive work keeps arriving.
The standard fix is periodic promotion of every process back to Q0.
]

#subsection[7.8 The comparison table — memorise this shape]

All five algorithms on the same master set (P1 0/8, P2 1/4, P3 2/9, P4 3/5):

#table(columns: 5, align: (left, right, right, right, left),
  [*Algorithm*], [*avg TAT*], [*avg WT*], [*avg RT*], [*Character*],
  [FCFS],           [15.25], [8.75],  [8.75], [simple, convoy effect],
  [SJF (non-pre.)], [14.25], [7.75],  [7.75], [good average, needs burst estimate],
  [SRTF (pre.)],    [*13.00*], [*6.50*], [4.25], [best averages, can starve long jobs],
  [RR $q = 2$],     [19.25], [12.75], [*2.00*], [fairest, best response, most overhead],
  [RR $q = 4$],     [18.25], [11.75], [4.50], [less overhead, slower response],
)

#trick[
The sentence that answers most comparison questions:
*"SRTF minimises average waiting time. Round Robin minimises response time. FCFS minimises
implementation effort. You pick based on whether the machine serves batch jobs or humans."*
]

#subsection[A scheduler you can run]

#code(lang: "js", caption: "Round-Robin simulator. Run with: node s1.js")[
```js
function roundRobin(procs, q) {
  const p = procs.map(x => ({ ...x, rem: x.bt, ct: 0, first: -1 }));
  const byArrival = [...p].sort((a, b) => a.at - b.at);
  const gantt = [], queue = [];
  let t = 0, i = 0, doneCount = 0;
  while (i < byArrival.length && byArrival[i].at <= t) queue.push(byArrival[i++]);
  while (doneCount < p.length) {
    if (queue.length === 0) {                 // CPU idle: jump to next arrival
      t = byArrival[i].at;
      while (i < byArrival.length && byArrival[i].at <= t) queue.push(byArrival[i++]);
      continue;
    }
    const cur = queue.shift();
    if (cur.first < 0) cur.first = t;         // first touch -> response time
    const run = Math.min(q, cur.rem);
    gantt.push([cur.id, t, t + run]);
    t += run; cur.rem -= run;
    // arrivals during this slice enter the queue BEFORE the preempted process
    while (i < byArrival.length && byArrival[i].at <= t) queue.push(byArrival[i++]);
    if (cur.rem > 0) queue.push(cur); else { cur.ct = t; doneCount++; }
  }
  return { gantt, p };
}

const procs = [
  { id: 'P1', at: 0, bt: 8 }, { id: 'P2', at: 1, bt: 4 },
  { id: 'P3', at: 2, bt: 9 }, { id: 'P4', at: 3, bt: 5 },
];
const { gantt, p } = roundRobin(procs, 2);
console.log('Gantt:', gantt.map(([id, s, e]) => `${id}[${s}-${e}]`).join(' '));
let sumT = 0, sumW = 0, sumR = 0;
for (const x of p) {
  const tat = x.ct - x.at, wt = tat - x.bt, rt = x.first - x.at;
  sumT += tat; sumW += wt; sumR += rt;
  console.log(`${x.id} CT=${x.ct} TAT=${tat} WT=${wt} RT=${rt}`);
}
const n = p.length;
console.log(`avg TAT=${(sumT/n).toFixed(2)} avg WT=${(sumW/n).toFixed(2)} avg RT=${(sumR/n).toFixed(2)}`);
```
]

#code(lang: "text", caption: "Actual output — matches the table above")[
```text
P1 CT=22 TAT=22 WT=14 RT=0
P2 CT=12 TAT=11 WT=7 RT=1
P3 CT=26 TAT=24 WT=15 RT=2
P4 CT=23 TAT=20 WT=15 RT=5
avg TAT=19.25 avg WT=12.75 avg RT=2.00
```
]

#trap[
Line 3 of that program: `[...p].sort((a, b) => a.at - b.at)`. Two JS traps in one line.
*(1)* `sort()` with no comparator sorts *lexicographically*, so arrival times
$[10, 9, 1]$ would come out as $[1, 10, 9]$. Numbers always need `(a, b) => a - b`.
*(2)* `.sort()` sorts *in place*. Without the `[...p]` copy you would silently reorder the
array you are also reporting from.
]

#section[Part 8 — I/O bound vs CPU bound]

- *CPU-bound* process: long CPU bursts, few I/O requests. A video encoder.
- *I/O-bound* process: short CPU bursts, many I/O requests. A text editor, a web server.

A good mix matters. If all processes are CPU-bound the I/O devices sit idle. If all are
I/O-bound the CPU sits idle. The *long-term scheduler* exists to keep the mix balanced.

The utilisation formula makes this concrete. If each process is blocked on I/O 20% of the
time ($p = 0.2$):

#table(columns: 3, align: (right, right, left),
  [*Processes in memory $n$*], [*CPU utilisation*], [*Working*],
  [1], [80.00%], [$1 - 0.2^1$],
  [2], [96.00%], [$1 - 0.04$],
  [3], [99.20%], [$1 - 0.008$],
  [4], [99.84%], [$1 - 0.0016$],
)

Diminishing returns arrive fast. Going from 3 to 4 processes buys 0.64%.

#trap[
$1 - p^n$ assumes the processes block *independently*. If they all wait on the same slow
disk, they are not independent and the real number is far worse. If an interviewer pushes,
say that: it shows you know it is a model, not a law.
]

#section[Part 9 — Inter-process communication (IPC)]

Threads talk by sharing a variable. Processes cannot — their address spaces are separate.
So the OS provides channels. Know these five and one sentence each.

#table(columns: 4,
  align: (left, left, left, left),
  [*Mechanism*], [*Shape*], [*Good at*], [*Catch*],
  [Pipe (anonymous)], [byte stream, one direction], [parent-to-child, e.g. a shell `|`],
    [only between related processes],
  [Named pipe (FIFO)], [byte stream with a filename], [unrelated processes on one machine],
    [still one machine, still a stream],
  [Message queue], [discrete messages with types], [structured, no ordering worries],
    [kernel copies every message — slower],
  [Shared memory], [a memory region mapped into both], [the *fastest* IPC — no copying],
    [you must add your own locking],
  [Socket], [byte stream or datagrams], [works across machines], [slowest; needs serialising],
)

#trap[
"Shared memory is the fastest IPC" is the expected answer — but the follow-up is *"why?"*
Because every other mechanism copies the data through the kernel (user $->$ kernel $->$
user). Shared memory copies nothing: both processes map the *same* physical pages, so a
write by one is instantly visible to the other. The price is that the kernel gives you no
synchronisation at all; you must add a semaphore or mutex yourself. That is Chapter 2.
]

#subsection[Two models, one sentence each]

- *Message passing*: `send(destination, message)` and `receive(source, message)`. Easy to
  reason about, works over a network, the kernel does the copying.
- *Shared memory*: both processes agree on a region; after setup the kernel is not involved
  at all.

Blocking vs non-blocking matters here:

#table(columns: 3, align: (left, left, left),
  [], [*Blocking (synchronous)*], [*Non-blocking (asynchronous)*],
  [`send`], [sender waits until the message is received], [sender returns immediately],
  [`receive`], [receiver waits until a message arrives], [receiver gets a message or nothing],
)

A *rendezvous* is blocking send plus blocking receive: neither side moves until both are
ready.

#ex(10, tier: 2, asked: "Sea/Shopee · pattern")[
Two Node processes on the same server must exchange 500 MB of image data 100 times a second.
An engineer proposes `child.send(buffer)` over the built-in IPC channel. Why is that a bad
choice, and what should be used instead?
]
#sol[
+ `child.send()` is *message passing*. Node serialises the buffer, the kernel copies it from
  the sender's address space into kernel space, then copies it again into the receiver's.
+ That is two full copies of 500 MB, 100 times a second $= 100 "GB/s"$ of pure memory
  copying, before any real work.
+ Shared memory copies nothing. Both processes map the same physical pages.

In Node the concrete tool is a `SharedArrayBuffer` passed to a `Worker` (threads, same
process) or a memory-mapped file for separate processes.

#ans[Use shared memory; message passing costs two copies per transfer.]

Follow-up you should volunteer: *"and then I need locking, because shared memory gives no
mutual exclusion."* That sentence is what separates a memorised answer from an understood
one.
]

#section[Part 10 — System calls, modes and interrupts]

#subsection[Two modes]

The CPU runs in one of two privilege levels:

- *User mode*: your code. Cannot touch I/O devices, cannot change page tables, cannot
  disable interrupts.
- *Kernel mode (supervisor mode)*: the OS. Can do everything.

A single bit in a status register says which mode you are in. Your program cannot set that
bit — if it could, the whole protection scheme would be decoration.

#subsection[The system call]

A *system call* is the only legal door from user mode into kernel mode. The sequence:

+ Your code puts a call number and arguments in registers.
+ It executes a special instruction (`syscall` on x86-64, `svc` on ARM).
+ The CPU switches to kernel mode and jumps to a *fixed* address — the syscall handler.
  Fixed, because the user must not choose where the kernel starts running.
+ The kernel checks the call number, does the work, puts a result in a register.
+ It switches back to user mode and returns.

The five families to name: *process control* (`fork`, `exec`, `exit`, `wait`),
*file management* (`open`, `read`, `write`, `close`), *device management*, *information
maintenance* (`getpid`, `time`), and *communication* (`pipe`, `socket`, `shmget`).

#subsection[Interrupt vs trap vs fault]

#table(columns: 4, align: (left, left, left, left),
  [], [*Caused by*], [*Timing*], [*Example*],
  [Interrupt], [hardware, outside the CPU], [asynchronous — any time], [disk finished, key pressed, timer tick],
  [Trap (software interrupt)], [the running instruction, on purpose], [synchronous], [a system call, a debugger breakpoint],
  [Fault / exception], [the running instruction, by accident], [synchronous], [divide by zero, page fault, bad pointer],
)

#trick[
One-line separator: *"An interrupt comes from outside and is a surprise. A trap comes from
inside and is deliberate. A fault comes from inside and is a mistake."*
]

#trap[
A *page fault* is not an error. It is a normal, expected event: the page you touched is not
in RAM right now, so the kernel fetches it and restarts your instruction. Calling it a crash
is a common mistake, and Chapter 3 spends a whole section on it.
]

The *timer interrupt* deserves its own line, because it is what makes preemption possible at
all. The hardware timer fires every few milliseconds, forces a trip into kernel mode, and
gives the scheduler a chance to say "your quantum is over". Without it, a process that never
makes a system call could hold the CPU forever.

#section[Part 11 — More than one CPU, and hard deadlines]

#subsection[Multiprocessor scheduling]

With $m$ cores, two designs:

- *Asymmetric*: one core runs all kernel code and scheduling; the others run user code only.
  Simple, no locking on kernel data, but that one core is a bottleneck.
- *Symmetric (SMP)*: every core schedules itself. This is what everything real uses.

SMP brings two new words:

- *Processor affinity*: keep a process on the core whose cache is already warm with its
  data. *Soft affinity* = the OS tries; *hard affinity* = you pin it and it cannot move.
- *Load balancing*: keep every run queue busy. *Push migration* — a periodic task moves work
  off an overloaded core. *Pull migration* — an idle core steals work from a busy one.

These two goals *fight each other*. Migrating a process balances load but throws away its
warm cache. Naming that tension is the answer the interviewer is fishing for.

#subsection[Real-time scheduling]

*Hard real-time*: missing a deadline is a failure (an airbag controller).
*Soft real-time*: missing a deadline degrades quality (a video player drops a frame).

Each periodic task $i$ has period $p_i$ and worst-case execution time $t_i$. Its CPU share is
$t_i / p_i$, and the total utilisation is

$ U = sum_(i=1)^n t_i / p_i $

*Rate-Monotonic (RM)* gives the highest static priority to the *shortest period*. It is
guaranteed to work if

$ U <= n (2^(1 slash n) - 1) $

#table(columns: 2, align: (right, right),
  [*$n$ tasks*], [*RM bound*],
  [1], [1.0000],
  [2], [0.8284],
  [3], [0.7798],
  [4], [0.7568],
  [5], [0.7435],
  [$-> infinity$], [$ln 2 = 0.6931$],
)

*Earliest-Deadline-First (EDF)* is dynamic: whoever's deadline is nearest runs. Its bound is
simply $U <= 1$ — it can use the whole CPU.

#ex(11, tier: 3, asked: "D. E. Shaw · pattern")[
Three periodic tasks on one core:
T1 (period 20 ms, needs 6 ms), T2 (period 30 ms, needs 8 ms), T3 (period 50 ms, needs 10 ms).
Is this schedulable under Rate-Monotonic? Under EDF? Now T3's work grows to 15 ms — redo
both answers.
]
#sol[
*Step 1 — utilisation.*
$ U = 6/20 + 8/30 + 10/50 = 0.3000 + 0.2667 + 0.2000 = 0.7667 $

*Step 2 — the RM bound for $n = 3$.*
$ 3(2^(1 slash 3) - 1) = 3(1.2599 - 1) = 3 times 0.2599 = 0.7798 $

*Step 3 — compare.* $0.7667 <= 0.7798$ ✓ — RM is *guaranteed* to meet every deadline.
Priorities: T1 highest (shortest period 20), then T2, then T3.

*Step 4 — EDF.* $0.7667 <= 1$ ✓ — schedulable, with room to spare.

*Now $t_3 = 15$ ms.*
$ U = 0.3000 + 0.2667 + 15/50 = 0.3000 + 0.2667 + 0.3000 = 0.8667 $
- RM bound is still $0.7798$. $0.8667 > 0.7798$, so the RM *guarantee fails*.
- EDF bound is $1$. $0.8667 <= 1$ ✓, so EDF still meets every deadline.

#ans[Both work at $U = 0.7667$. At $U = 0.8667$ only EDF is guaranteed.]

#trap[
The RM test is *sufficient, not necessary*. Failing it does not prove the task set misses a
deadline — it only means RM cannot promise. Some sets above the bound still run fine, and
you would have to simulate the whole hyperperiod to know. Say "the guarantee fails", never
"it will miss a deadline".
]

Why use RM at all if EDF is better on paper? Because RM priorities are *fixed*, so the
runtime is trivial and cheap; EDF has to re-sort by deadline constantly, and when EDF is
overloaded it degrades badly — one late task can cascade into everything missing.
]

#subsection[Linux in one paragraph]

Modern Linux uses *CFS*, the Completely Fair Scheduler. It has no fixed quantum. It tracks
each task's *virtual runtime* — CPU time used, weighted by the task's `nice` value — and
always runs the task with the smallest virtual runtime, keeping them in a red-black tree so
"smallest" is $O(log n)$. A lower `nice` number (down to $-20$) means a larger weight, so
virtual runtime grows more slowly, so the task is picked more often. Real-time tasks
(`SCHED_FIFO`, `SCHED_RR`) sit in a separate class that always beats CFS.

#ans[One line to say: *"CFS approximates giving every runnable task an equal share of the
CPU, by always running whichever task is furthest behind on its fair share."*]

#section[Practice]

#tier-header(0)

#practice(tier: 0, time: "8 min")[
+ Name the five process states.
+ TAT $= 14$, BT $= 6$. Find WT.
+ AT $= 3$, CT $= 19$. Find TAT.
+ Which scheduler decides the degree of multiprogramming?
+ Which is cheaper to create: a process or a thread?
+ True or false: two threads of the same process share the stack.
+ A process makes a system call. Is that a context switch?
+ In Round Robin, what happens when $q$ is larger than every burst time?
]

#key[
1. New, Ready, Running, Waiting/Blocked, Terminated.
2. $"WT" = "TAT" - "BT" = 14 - 6 = 8$.
3. $"TAT" = "CT" - "AT" = 19 - 3 = 16$.
4. The long-term (job) scheduler.
5. A thread — no new address space or page tables.
6. False. Shared: text, data, heap. Private: stack and registers.
7. No. It is a *mode* switch (user $->$ kernel). The same process continues.
8. It behaves exactly like FCFS.
]

#tier-header(1)

#practice(tier: 1, time: "20 min")[
+ Processes A(AT 0, BT 4), B(AT 1, BT 3), C(AT 2, BT 5). Draw the FCFS Gantt chart and give
  average waiting time.
+ Same data under non-preemptive SJF. Average waiting time?
+ Same data under Round Robin with $q = 2$. Average turnaround time?
+ Explain a zombie process in three lines, and say how to prevent one.
+ Three `fork()` calls run one after another with no conditions. How many processes exist at
  the end?
+ A process in WAITING has its I/O complete. Which state does it enter, and why not RUNNING?
+ Give one advantage and one disadvantage of preemptive scheduling.
]

#key[
*1.* FCFS order A, B, C. A: 0–4, B: 4–7, C: 7–12.
WT: A $= 0$; B $= (7-1) - 3 = 3$; C $= (12-2) - 5 = 5$. Average $= 8/3 = 2.67$.

*2.* At $t = 0$ only A has arrived, so A runs 0–4 regardless. At $t = 4$, B (3) and C (5)
are waiting; B is shorter. B: 4–7, C: 7–12. Same chart as FCFS here.
Average WT $= 2.67$. (A good reminder: SJF is not always different.)

*3.* $q = 2$. A 0–2 (2 left). B arrives at 1, C at 2. Queue after A's slice: [B, C, A].
B 2–4 (1 left) $->$ queue [C, A, B]. C 4–6 (3 left) $->$ [A, B, C]. A 6–8 (done, CT 8).
B 8–9 (done, CT 9). C 9–11 (1 left) $->$ C 11–12 (done, CT 12).
TAT: A $= 8$, B $= 9 - 1 = 8$, C $= 12 - 2 = 10$. Average $= 26/3 = 8.67$.

*4.* A zombie is a child that has terminated but whose parent has not called `wait()`, so
its exit status and PID still occupy a slot in the process table. It uses no CPU and no
memory — only a PID. Prevent it by having the parent call `wait()` / `waitpid()`, or by
handling `SIGCHLD`.

*5.* $2^3 = 8$.

*6.* READY. The CPU may be busy with someone else; completing I/O only makes the process
*eligible* to run. The dispatcher still has to choose it.

*7.* Advantage: a single long process cannot monopolise the CPU, so response time stays low.
Disadvantage: extra context-switch overhead, and shared kernel data can be left inconsistent
mid-update, which forces locking.
]

#tier-header(2)

#practice(tier: 2, time: "25 min")[
+ Four jobs: J1(0, 7), J2(2, 4), J3(4, 1), J4(5, 4) as (AT, BT). Compute average waiting
  time under SRTF, showing every preemption point.
+ The same four jobs under Round Robin $q = 2$. Which algorithm gives the better average
  response time, and by how much?
+ A web server handles requests that each spend 5 ms on CPU and 45 ms waiting on the
  database. Using $1 - p^n$, how many concurrent requests are needed to keep the CPU above
  95% busy?
+ A team replaces 8 OS processes with 8 threads in one process. Name two things that get
  better and two new risks.
]

#key[
*1. SRTF on J1(0,7), J2(2,4), J3(4,1), J4(5,4).*
- $t=0$: only J1. Runs.
- $t=2$: J2 arrives with 4. J1 has $7-2 = 5$ left. $4 < 5$ $->$ preempt. J2 runs.
- $t=4$: J3 arrives with 1. J2 has 2 left. $1 < 2$ $->$ preempt. J3 runs 4–5 and finishes.
- $t=5$: J4 arrives with 4. Remaining: J1 = 5, J2 = 2, J4 = 4. Smallest is J2. J2 runs 5–7,
  finishes.
- $t=7$: J1 = 5, J4 = 4. J4 runs 7–11, finishes.
- $t=11$: J1 runs its last 5, 11–16.

Chart: `| J1 | J2 | J3 | J2 | J4 | J1 |` with boundaries 0, 2, 4, 5, 7, 11, 16.

CT: J1 = 16, J2 = 7, J3 = 5, J4 = 11.
TAT: 16, 5, 1, 6. WT: $16-7=9$, $5-4=1$, $1-1=0$, $6-4=2$.
Average WT $= 12/4 = 3.00$. Average TAT $= 28/4 = 7.00$.

*2. RR $q=2$ on the same jobs.*
Chart: `| J1 | J2 | J1 | J3 | J2 | J4 | J1 | J4 | J1 |`
with boundaries 0, 2, 4, 6, 7, 9, 11, 13, 15, 16.
CT: J1 = 16, J2 = 9, J3 = 7, J4 = 15.
TAT: 16, 7, 3, 10 $->$ average $= 36/4 = 9.00$. WT: 9, 3, 2, 6 $->$ average $= 20/4 = 5.00$.
First CPU touch: J1 at 0, J2 at 2, J3 at 6, J4 at 9.
RT: $0-0 = 0$, $2-2 = 0$, $6-4 = 2$, $9-5 = 4$ $->$ average $= 6/4 = 1.50$.
For SRTF, first touches are J1 at 0, J2 at 2, J3 at 4, J4 at 7, so
RT $= 0, 0, 0, 2 -> 2/4 = 0.50$.

Answer: SRTF wins on response time here, $0.50$ vs $1.50$ — a difference of $1.00$ unit.
(SRTF also wins on waiting time, 3.00 vs 5.00. RR's response-time advantage shows up when
bursts are long and unequal, not when several jobs are already tiny.)

*3.* Each request is on the CPU 5 ms out of 50 ms, so it is blocked $p = 45/50 = 0.9$ of the
time. Solve $1 - 0.9^n >= 0.95$, i.e. $0.9^n <= 0.05$.
- $0.9^10 = 0.3487$
- $0.9^20 = 0.1216$
- $0.9^28 = 0.0523$
- $0.9^29 = 0.0471$ $<= 0.05$ ✓

Answer: *29 concurrent requests*. (In practice you would round to 30 and check memory.)

*4.* Better: (i) creation and context switching get much cheaper — no page-table switch, no
TLB flush; (ii) sharing data is free, no serialisation through pipes or sockets.
New risks: (i) no memory isolation — one thread's bad pointer or unhandled exception can
take down all 8; (ii) every shared variable is now a potential race condition, so you need
locks, and locks bring deadlock and priority inversion.
]

#tier-header(3)

#practice(tier: 3, time: "30 min")[
+ Prove, in words an interviewer will accept, that SRTF gives the minimum possible average
  waiting time for a given set of arrivals and bursts. Then give one reason a real OS still
  does not use it.
+ A 16-core machine runs a job that is 92% parallelisable. Management asks for a 10$times$
  speedup. Is it possible with any number of cores? Give the number.
+ Design a scheduler for a food-delivery dispatch service: thousands of short "assign a
  rider" tasks and a few long "recompute all zones" tasks. Which algorithm, which quantum,
  and what stops the long tasks from starving?
+ Round Robin with quantum $q$ and $n$ processes. Give the worst-case time a process waits
  before its *first* CPU slice, including a context-switch cost $s$. State your assumptions.
]

#key[
*1.* Exchange argument. Suppose at some decision point the scheduler runs job X when job Y
is available and Y has a strictly smaller remaining time. Swap them: run Y first, then X.
Y now finishes earlier by the length of X's run, and X finishes no later than Y did before,
so the *sum* of completion times does not increase — and it strictly decreases whenever the
remaining times differ. Since average waiting time $= ("sum of CT" - "sum of AT" -
"sum of BT")/n$ and only the sum of CT can change, always picking the smallest remaining
time minimises it.

Why no real OS uses it: the OS cannot know the remaining time. It can only estimate it, and
a wrong estimate makes the guarantee worthless. SRTF also starves long jobs, and it requires
a comparison at *every* arrival, which costs CPU.

*2.* $f = 0.92$, so the ceiling is $1/(1 - 0.92) = 1/0.08 = 12.5$.
- 10 is below 12.5, so it *is* possible.
- Solve $1/(0.08 + 0.92/n) = 10$ $->$ $0.08 + 0.92/n = 0.1$ $->$ $0.92/n = 0.02$
  $->$ $n = 46$.
- Check: $1/(0.08 + 0.92/46) = 1/(0.08 + 0.02) = 1/0.1 = 10$ ✓
- At 16 cores you only get $1/(0.08 + 0.0575) = 7.27$.

Answer: yes, with *46 cores*. Ask for 12$times$ and it needs 276 cores; ask for 13$times$
and no number of cores will do it.

*3.* Use a *multilevel feedback queue* with two or three levels.
- New tasks enter Q0 with a short quantum (say 10 ms). A rider assignment finishes inside
  one quantum and leaves; it never gets demoted, so the common case is nearly FCFS with
  almost no preemption cost.
- A zone recomputation uses its whole quantum, gets demoted to Q1 (quantum 50 ms) and then
  to Q2 (FCFS). It stops competing with the short tasks.
- Anti-starvation: promote every process in Q1 and Q2 back to Q0 every, say, 2 seconds; or
  reserve a fixed share (e.g. 10% of slices) for the bottom queue.
- Quantum choice: pick it so most assignment tasks finish in one slice. If an assignment
  costs 2–8 ms of CPU, $q = 10$ ms means about 95% of them never get preempted.
- Trade-off to name out loud: this optimises response time for the many, at the cost of
  turnaround time for the few long jobs. If the zone recomputation has a deadline, it needs
  a reserved share, not just aging.

*4.* Assumptions: all $n$ processes are already in the ready queue, our process is last,
each of the others uses a full quantum, and one context switch of cost $s$ happens before
each slice.
- $n - 1$ processes run ahead of us, each taking $q$ of CPU plus $s$ of switching.
- Then one more switch brings us in.
- Worst-case wait $= (n - 1)(q + s) + s$.
- Sanity check with $n = 1$: wait $= s$, just the switch onto the CPU. Correct.
- If you ignore switch cost, the familiar textbook form is $(n - 1) q$.
]

#section[Rapid fire — one-line answers]

#table(columns: 2, align: (left, left),
  [*Question*], [*Answer*],
  [Program vs process?], [Program = passive file on disk; process = program in execution with memory and resources.],
  [What is stored in a PCB?], [PID, state, program counter, registers, scheduling info, memory info, open files.],
  [Five process states?], [New, Ready, Running, Waiting, Terminated.],
  [Can Waiting go straight to Running?], [No — it must pass through Ready.],
  [Process vs thread in one line?], [Threads share the address space; processes do not.],
  [What do threads NOT share?], [Stack, registers, program counter, thread ID.],
  [What do threads share?], [Text, data, heap, open files, signals.],
  [What does `fork()` return?], [0 in the child, the child's PID in the parent, negative on failure.],
  [Does `exec()` create a process?], [No. It replaces the current process image; the PID stays the same.],
  [What is a zombie?], [A terminated child whose parent has not called `wait()`; its table entry remains.],
  [What is an orphan?], [A running process whose parent died; `init` (PID 1) adopts it.],
  [Context switch vs mode switch?], [Context switch changes which process runs; mode switch only changes privilege level.],
  [What is saved on a context switch?], [PC, registers, stack pointer, status word, memory-management registers.],
  [Which scheduler runs most often?], [The short-term (CPU) scheduler — every few milliseconds.],
  [What is the dispatcher?], [The module that actually hands the CPU over; its cost is dispatch latency.],
  [TAT formula?], [$"CT" - "AT"$.],
  [WT formula?], [$"TAT" - "BT"$.],
  [RT formula?], [First time on CPU minus arrival time.],
  [Which algorithm has the convoy effect?], [FCFS.],
  [Which minimises average waiting time?], [SRTF (preemptive SJF); SJF is optimal among non-preemptive schemes.],
  [Which minimises response time?], [Round Robin with a small quantum.],
  [What is starvation?], [A process never gets the CPU because higher-priority work keeps arriving.],
  [What is aging?], [Raising a waiting process's priority over time so it cannot starve forever.],
  [RR with a huge quantum behaves like?], [FCFS.],
  [MLQ vs MLFQ?], [MLQ queues are fixed; in MLFQ a process can move between queues (feedback).],
  [Preemptive vs non-preemptive, one line?], [Preemptive can take the CPU away mid-burst; non-preemptive waits for a block or an exit.],
  [CPU-bound vs I/O-bound?], [CPU-bound has long CPU bursts; I/O-bound has short bursts and many I/O waits.],
  [CPU utilisation with $n$ processes?], [$1 - p^n$, where $p$ is the fraction of time each is blocked.],
  [Amdahl's ceiling?], [$1/(1-f)$ where $f$ is the parallel fraction.],
  [Why is Node called single-threaded?], [Your JS runs on one thread; libuv and the kernel do I/O on others.],
)

#revision[
*States.* New $->$ Ready $->$ Running $->$ (Waiting $->$ Ready) $->$ Terminated.
Only Ready $->$ Running exists as an entry to the CPU.

*Formulas.* $"TAT" = "CT" - "AT"$; #h(6pt) $"WT" = "TAT" - "BT"$; #h(6pt)
$"RT" = "first CPU" - "AT"$; #h(6pt) utilisation $= 1 - p^n$; #h(6pt)
speedup $= 1/((1-f) + f/n)$.

*Process vs thread.* Shared by threads: text, data, heap, files. Private to each thread:
stack, registers, PC. Threads are cheap and unprotected; processes are costly and isolated.

*fork/exec.* `fork` = one call two returns (0 = child). `exec` = same PID, new program.
Zombie = dead child, unreaped. Orphan = live child, dead parent.

*Algorithms.*
#table(columns: 4, align: (left, left, left, left),
  [*Name*], [*Preempt?*], [*Best at*], [*Weakness*],
  [FCFS], [no], [simplicity], [convoy effect],
  [SJF], [no], [avg waiting], [needs burst estimate],
  [SRTF], [yes], [avg waiting (optimal)], [starves long jobs],
  [Priority], [either], [importance], [starvation — fix with aging],
  [Round Robin], [yes], [response time], [overhead; worst avg TAT],
  [HRRN], [no], [balance], [non-preemptive only],
  [MLFQ], [yes], [learns job type], [many knobs to tune],
)

*Master numbers to remember the shape of* (P1 0/8, P2 1/4, P3 2/9, P4 3/5):
FCFS WT 8.75 · SJF 7.75 · SRTF 6.50 · RR($q$=2) 12.75 but RT only 2.00.

*Three traps.* (1) Waiting goes to Ready, never straight to Running. (2) Threads do NOT
share the stack. (3) Response time $!=$ waiting time once preemption exists.
]

]
