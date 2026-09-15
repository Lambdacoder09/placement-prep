#import "../../shared/lib/style.typ": *

#chapter(num: 2, title: "OS: Synchronisation & Deadlock",
  tagline: "Two workers, one shared thing, and every way that can go wrong.")[

#section[What this round actually looks like]

Chapter 1 gave the CPU to one process at a time. The moment two of them touch the same
variable, a new class of bug appears — one that passes every test on your laptop and fails
once a week in production. Interviewers love this topic because the answers are short,
checkable, and reveal instantly whether you have actually written concurrent code.

The four questions that come up almost every time:

- "What is a race condition? Give an example."
- "Difference between a mutex and a semaphore?"
- "What are the four necessary conditions for deadlock?"
- "Explain the Banker's algorithm." (then: "run it on this table")

#formulas(title: "Everything this chapter needs, in one box")[

*Race condition.* Two or more threads access shared data at the same time, and the final
result depends on the *order* in which they happen to run. The bug is the *order
dependence*, not the sharing.

*Critical section.* The part of the code that touches the shared data. The structure is
always the same four parts:

#align(center)[`entry section` $->$ *critical section* $->$ `exit section` $->$ `remainder`]

*Any correct solution must satisfy all three:*
+ *Mutual exclusion* — at most one process inside the critical section at a time.
+ *Progress* — if nobody is inside and somebody wants in, the choice of who enters cannot be
  postponed forever, and a process in its remainder section must not take part in the choice.
+ *Bounded waiting* — there is a limit on how many times others can enter ahead of you after
  you have asked.

*Semaphore.* An integer $S$ with two atomic operations:
#align(center)[`wait(S)` (also called P / down / acquire): block while $S <= 0$, then $S = S - 1$]
#align(center)[`signal(S)` (also called V / up / release): $S = S + 1$, wake one waiter]

*The four necessary conditions for deadlock.* All four must hold at once:
+ *Mutual exclusion* — at least one resource is non-shareable.
+ *Hold and wait* — a process holds one resource while waiting for another.
+ *No preemption* — a resource can only be released voluntarily by its holder.
+ *Circular wait* — a cycle $P_1 -> P_2 -> dots -> P_n -> P_1$ where each waits for the next.

*Banker's algorithm.*
$ "Need"[i][j] = "Max"[i][j] - "Allocation"[i][j] $
$ "Available"[j] = "Total"[j] - sum_i "Allocation"[i][j] $
A state is *safe* if some ordering of all processes exists in which each can get its Need
from Available plus what the earlier ones release.
]

#section[Part 1 — The race condition]

#subsection[The smallest possible example]

Two threads run `counter = counter + 1` on a shared `counter` that starts at 5. That single
line is really three machine instructions:

#code(lang: "text", caption: "One line of source, three machine steps")[
```text
LOAD  R1, counter     ; read
ADD   R1, 1           ; modify
STORE counter, R1     ; write
```
]

If the scheduler switches threads between the LOAD and the STORE, both threads read 5, both
compute 6, both store 6. Two increments, one result.

#diagram(height: 4.4cm, caption: "The lost update. Both threads read 100, both decide they can afford 100, and the account pays twice.")[
  #dnode(0cm, 0cm, 2.9cm, 0.75cm, "step", fill: rgb("#e8e8e4"))
  #dnode(3cm, 0cm, 2.6cm, 0.75cm, "t1", fill: rgb("#e8e8e4"))
  #dnode(5.7cm, 0cm, 2.6cm, 0.75cm, "t2", fill: rgb("#e8e8e4"))
  #dnode(8.4cm, 0cm, 2.6cm, 0.75cm, "t3", fill: rgb("#e8e8e4"))
  #dnode(11.1cm, 0cm, 2.6cm, 0.75cm, "t4", fill: rgb("#e8e8e4"))
  #dnode(13.8cm, 0cm, 2.6cm, 0.75cm, "t5", fill: rgb("#e8e8e4"))

  #dnode(0cm, 0.95cm, 2.9cm, 0.75cm, "Thread A", fill: rgb("#f2e9df"))
  #dnode(3cm, 0.95cm, 2.6cm, 0.75cm, "read 100")
  #dnode(5.7cm, 0.95cm, 2.6cm, 0.75cm, "—", fill: white)
  #dnode(8.4cm, 0.95cm, 2.6cm, 0.75cm, "—", fill: white)
  #dnode(11.1cm, 0.95cm, 2.6cm, 0.75cm, "write 100−100")
  #dnode(13.8cm, 0.95cm, 2.6cm, 0.75cm, "—", fill: white)

  #dnode(0cm, 1.9cm, 2.9cm, 0.75cm, "Thread B", fill: rgb("#f2e9df"))
  #dnode(3cm, 1.9cm, 2.6cm, 0.75cm, "—", fill: white)
  #dnode(5.7cm, 1.9cm, 2.6cm, 0.75cm, "read 100")
  #dnode(8.4cm, 1.9cm, 2.6cm, 0.75cm, "—", fill: white)
  #dnode(11.1cm, 1.9cm, 2.6cm, 0.75cm, "—", fill: white)
  #dnode(13.8cm, 1.9cm, 2.6cm, 0.75cm, "write 100−100")

  #dnode(0cm, 2.85cm, 2.9cm, 0.75cm, "balance after", fill: rgb("#dfe9f2"))
  #dnode(3cm, 2.85cm, 2.6cm, 0.75cm, "100")
  #dnode(5.7cm, 2.85cm, 2.6cm, 0.75cm, "100")
  #dnode(8.4cm, 2.85cm, 2.6cm, 0.75cm, "100")
  #dnode(11.1cm, 2.85cm, 2.6cm, 0.75cm, "0")
  #dnode(13.8cm, 2.85cm, 2.6cm, 0.75cm, "0")
]

#subsection[You can reproduce it in Node — twice, two different ways]

*Way 1: one thread, but `await` yields control.* People assume JavaScript is safe because it
is single-threaded. It is not. Every `await` is a place where the scheduler can switch to
another task.

#code(lang: "js", caption: "A real lost update in single-threaded Node. Run: node c1.js")[
```js
let balance = 100;
const sleep = (ms) => new Promise(r => setTimeout(r, ms));

async function withdraw(name, amount) {
  const seen = balance;                 // READ
  await sleep(10);                      // <-- the scheduler can switch here
  if (seen >= amount) {
    balance = seen - amount;            // MODIFY + WRITE, using a STALE read
    console.log(`${name}: took ${amount}, balance now ${balance}`);
  } else {
    console.log(`${name}: refused, only ${seen} available`);
  }
}

(async () => {
  await Promise.all([withdraw('A', 100), withdraw('B', 100)]);
  console.log('final balance =', balance);
})();
```
]

#code(lang: "text", caption: "Actual output")[
```text
A: took 100, balance now 0
B: took 100, balance now 0
final balance = 0
```
]

The account had 100. It paid out 200. The balance says 0 and nobody notices.

*Way 2: real OS threads, real lost writes.* Four worker threads each increment a shared
32-bit integer 200,000 times.

#code(lang: "js", caption: "Lost updates across real threads, then two fixes. Run: node c7.js")[
```js
const { Worker, isMainThread, workerData } = require('worker_threads');
const ITER = 200000, WORKERS = 4;

if (isMainThread) {
  const run = (mode) => new Promise(res => {
    const sab = new SharedArrayBuffer(8);
    const a = new Int32Array(sab);            // a[0] = counter, a[1] = lock flag
    let left = WORKERS;
    for (let i = 0; i < WORKERS; i++) {
      const w = new Worker(__filename, { workerData: { sab, mode } });
      w.on('exit', () => { if (--left === 0) res(a[0]); });
    }
  });
  (async () => {
    console.log('expected           =', ITER * WORKERS);
    console.log('plain  a[0]++      =', await run('plain'));
    console.log('Atomics.add        =', await run('atomic'));
    console.log('spinlock (CAS)     =', await run('lock'));
  })();
} else {
  const { sab, mode } = workerData;
  const a = new Int32Array(sab);
  for (let i = 0; i < ITER; i++) {
    if (mode === 'plain') { a[0] = a[0] + 1; }
    else if (mode === 'atomic') { Atomics.add(a, 0, 1); }
    else {
      while (Atomics.compareExchange(a, 1, 0, 1) !== 0) { /* spin */ }  // test-and-set
      a[0] = a[0] + 1;                                                  // critical section
      Atomics.store(a, 1, 0);                                           // release
    }
  }
}
```
]

#code(lang: "text", caption: "Actual output on the machine this book was written on")[
```text
expected           = 800000
plain  a[0]++      = 500453
Atomics.add        = 800000
spinlock (CAS)     = 800000
```
]

Almost 300,000 increments vanished. Run it again and you get a different number — that
non-determinism *is* the definition of a race condition.

#trap[
"JavaScript is single-threaded so it cannot have race conditions." Wrong on both halves.
Your JS *code* runs on one thread, but (a) `await` and callbacks interleave tasks on that
one thread, so a read-check-write split across an `await` races with itself, and
(b) `worker_threads` plus `SharedArrayBuffer` gives you genuine parallel threads on
different cores. The output above is the proof.
]

#ex(1, tier: 0, asked: "warm-up")[
`counter` starts at 5. Two threads each run `counter = counter + 1`. List every possible
final value.
]
#sol[
+ If thread A completes all three steps (load, add, store) before B starts: A stores 6, B
  loads 6, stores 7. Final = 7.
+ Same if B goes completely first. Final = 7.
+ If they interleave — both load 5 before either stores — both compute 6 and both store 6.
  Final = 6.

#ans[6 or 7. The correct answer is 7; 6 is the lost update.]
]

#section[Part 2 — Solving the critical-section problem]

#subsection[The three requirements, restated in plain words]

+ *Mutual exclusion* — "only one at a time." Easy to get.
+ *Progress* — "if the room is empty, somebody who wants in gets in, and soon." A solution
  that makes two processes strictly alternate fails this: if A finishes and never comes back,
  B can only enter once more and then waits forever, even though the room is empty.
+ *Bounded waiting* — "no one waits forever while others cycle through." This rules out
  starvation.

#trap[
The classic wrong answer is "mutual exclusion is enough." A solution that simply says
"nobody ever enters" gives perfect mutual exclusion and is useless. *Progress* is the
requirement most broken solutions fail, and it is the one interviewers probe.
]

#subsection[Attempt 1: a single `turn` variable — fails progress]

#code(lang: "c", caption: "Strict alternation — correct but not usable")[
```c
/* shared */ int turn = 0;

/* process i */
while (turn != i) ;      /* entry: busy wait */
   /* critical section */
turn = 1 - i;            /* exit */
```
]

Mutual exclusion: yes, `turn` can only hold one value. Progress: *no*. Process 0 must go,
then 1, then 0, strictly. If process 1 never wants to enter again, process 0 is stuck
forever at its second attempt even though the critical section is empty.

#subsection[Attempt 2: a `flag` array — fails progress differently]

#code(lang: "c", caption: "Both raise a flag — this deadlocks")[
```c
/* shared */ bool flag[2] = { false, false };

/* process i */
flag[i] = true;          /* "I want in" */
while (flag[1-i]) ;      /* wait while the other also wants in */
   /* critical section */
flag[i] = false;
```
]

If both set their flag before either checks, both loop forever. That is a *deadlock*, and
deadlock is a progress failure.

#subsection[Peterson's solution — flag AND turn together]

#code(lang: "c", caption: "Peterson's algorithm for two processes — what the interviewer wants to see")[
```c
/* shared */ bool flag[2] = { false, false };
             int  turn;

/* process i, with the other one called j */
flag[i] = true;                     /* 1. I want in            */
turn = j;                           /* 2. but YOU go first     */
while (flag[j] && turn == j) ;      /* 3. wait only if you want in AND it is your turn */
   /* critical section */
flag[i] = false;                    /* 4. I am done            */
```
]

Why it works, in the three words the interviewer is listening for:

- *Mutual exclusion*: for both to be inside we would need `flag[0] && flag[1]` true and
  `turn` equal to both 0 and 1 at once. `turn` holds one value. Impossible.
- *Progress*: if process $j$ does not want in, `flag[j]` is false and process $i$ walks
  straight through. No alternation is forced.
- *Bounded waiting*: after $j$ leaves it sets `flag[j] = false`; if it immediately tries
  again it must set `turn = i`, which lets $i$ in. So $i$ waits at most one turn.

#trick[
The whole trick is line 2: *`turn = j`*, not `turn = i`. Each process *politely gives the
turn away*. If both are polite at once, the last writer's value decides, and exactly one of
them loses the tie. Writing `turn = i` breaks mutual exclusion, and it is the single most
common slip.
]

#trap[
Peterson's algorithm assumes writes become visible in program order. Real CPUs *reorder*
stores, so on modern hardware Peterson's needs memory fences to be correct. Say this if
pushed — and say that in practice nobody hand-rolls it, because the hardware gives us
atomic instructions instead.
]

#subsection[The hardware answer: test-and-set and compare-and-swap]

The CPU provides instructions that do read-and-write *as one indivisible step*.

#code(lang: "c", caption: "What the hardware instruction does, written as if it were code")[
```c
/* All of this happens atomically - no thread can get in between. */
bool test_and_set(bool *target) {
    bool old = *target;
    *target = true;
    return old;
}

int compare_and_swap(int *word, int expected, int newval) {
    int old = *word;
    if (old == expected) *word = newval;
    return old;                 /* caller checks: old == expected means I won */
}
```
]

A spinlock built on it:

#code(lang: "c", caption: "The simplest possible lock")[
```c
/* shared */ bool lock = false;

while (test_and_set(&lock)) ;   /* spin until we are the one who flipped it */
   /* critical section */
lock = false;
```
]

In JavaScript that exact instruction is `Atomics.compareExchange` — used in the `'lock'`
branch of the program above, and it produced the correct 800000.

#trap[
A spinlock gives mutual exclusion but *not* bounded waiting: an unlucky thread can lose the
race every single time. A real lock adds a queue. Also: spinning burns CPU. Spinlocks are
right only when the critical section is *shorter than a context switch* (a few hundred
nanoseconds) — otherwise use a blocking lock that puts the waiter to sleep.
]

#section[Part 3 — Mutex and semaphore]

#subsection[The definitions]

*Mutex* (mutual exclusion lock): a lock with an *owner*. `lock()` and `unlock()`. Only the
thread that locked it may unlock it.

*Semaphore*: an integer with `wait()` and `signal()`, and *no owner*. Any thread may signal.

#code(lang: "c", caption: "Semaphore operations — the blocking version, which is what real systems use")[
```c
wait(S) {                       /* P, down, acquire */
    S->value--;
    if (S->value < 0) {
        add this process to S->queue;
        block();                /* go to WAITING state - no busy waiting */
    }
}

signal(S) {                     /* V, up, release */
    S->value++;
    if (S->value <= 0) {
        remove a process P from S->queue;
        wakeup(P);              /* move P to READY */
    }
}
```
]

#note[
In this version a *negative* value has a meaning: $|S|$ is the number of processes waiting
in the queue. If $S = -3$, three processes are blocked. That is a favourite follow-up
question.
]

#subsection[Mutex vs binary semaphore — the difference that gets marks]

A binary semaphore is a semaphore whose value is only 0 or 1. It *looks* like a mutex.
It is not.

#table(columns: 3, align: (left, left, left),
  [], [*Mutex*], [*Binary semaphore*],
  [Ownership], [yes — the locker must be the unlocker], [none — anyone may signal],
  [Purpose], [mutual exclusion], [mutual exclusion *or signalling between threads*],
  [Can it be released by another thread?], [no (an error)], [yes, and that is the point],
  [Counting], [no], [a counting semaphore can go above 1],
  [Priority inheritance], [usually supported], [usually not],
  [Typical use], [protect a shared variable], ["the data is ready" signal; limit to $N$ users],
)

#trick[
Say it in one line: *"A mutex is a lock — it has an owner and the owner must release it.
A semaphore is a counter — it has no owner, so one thread can wait and a completely
different thread can signal. Use a mutex to protect data; use a semaphore to signal an event
or to cap concurrency at N."*
]

#subsection[A mutex you can read]

#code(lang: "js", caption: "A promise-based mutex, and the race from Part 1 fixed. Run: node c2.js")[
```js
class Mutex {
  constructor() { this.locked = false; this.waiters = []; }
  lock() {
    if (!this.locked) { this.locked = true; return Promise.resolve(); }
    return new Promise(resolve => this.waiters.push(resolve));
  }
  unlock() {
    const next = this.waiters.shift();
    if (next) next();            // hand the lock straight to the next waiter
    else this.locked = false;
  }
}

let balance = 100;
const m = new Mutex();
const sleep = (ms) => new Promise(r => setTimeout(r, ms));

async function withdraw(name, amount) {
  await m.lock();                       // ENTRY
  try {                                 // ---- critical section ----
    const seen = balance;
    await sleep(10);
    if (seen >= amount) { balance = seen - amount; console.log(`${name}: took ${amount}, balance now ${balance}`); }
    else { console.log(`${name}: refused, only ${seen} available`); }
  } finally { m.unlock(); }             // EXIT - finally, so a throw cannot leak the lock
}

(async () => {
  await Promise.all([withdraw('A', 100), withdraw('B', 100)]);
  console.log('final balance =', balance);
})();
```
]

#code(lang: "text", caption: "Actual output — now correct")[
```text
A: took 100, balance now 0
B: refused, only 0 available
final balance = 0
```
]

#trap[
`try { ... } finally { m.unlock(); }` is not decoration. If the critical section throws and
you unlock outside a `finally`, the lock is never released and *every* future caller blocks
forever. That is a self-inflicted deadlock, and it is the number one concurrency bug in real
code.
]

#subsection[A counting semaphore you can read]

#code(lang: "js", caption: "Cap concurrency at 2. Run: node c3.js")[
```js
class Semaphore {
  constructor(count) { this.count = count; this.waiters = []; }
  async wait() {                       // P / down / acquire
    if (this.count > 0) { this.count--; return; }
    await new Promise(resolve => this.waiters.push(resolve));
  }
  signal() {                           // V / up / release
    const next = this.waiters.shift();
    if (next) next();                  // do NOT raise count: pass the permit on
    else this.count++;
  }
}

const sem = new Semaphore(2);
const sleep = (ms) => new Promise(r => setTimeout(r, ms));
let inside = 0, peak = 0;

async function job(id) {
  await sem.wait();
  inside++; peak = Math.max(peak, inside);
  console.log(`job ${id} entered   (inside now ${inside})`);
  await sleep(30);
  inside--;
  console.log(`job ${id} left      (inside now ${inside})`);
  sem.signal();
}

(async () => {
  await Promise.all([1, 2, 3, 4, 5].map(job));
  console.log(`peak concurrent = ${peak}  (limit was 2)`);
})();
```
]

#code(lang: "text", caption: "Actual output (trimmed)")[
```text
job 1 entered   (inside now 1)
job 2 entered   (inside now 2)
job 1 left      (inside now 1)
job 3 entered   (inside now 2)
...
peak concurrent = 2  (limit was 2)
```
]

Note the line in `signal()`: when a waiter exists we hand it the permit directly instead of
incrementing the count. Incrementing *and* waking would let a third job slip in. That single
line is the difference between a working semaphore and a subtly broken one.

#ex(2, tier: 1, asked: "Capgemini · pattern")[
A counting semaphore is initialised to 3. Then 5 `wait()` calls happen, followed by 2
`signal()` calls. What is the value of the semaphore, and how many processes are blocked?
]
#sol[
Use the version where the value can go negative.

#table(columns: 4, align: (left, right, right, left),
  [*Operation*], [*Value after*], [*Blocked*], [*Why*],
  [start],       [3],  [0], [three permits free],
  [wait 1],      [2],  [0], [$3 - 1$, still $>= 0$, so it proceeds],
  [wait 2],      [1],  [0], [proceeds],
  [wait 3],      [0],  [0], [proceeds — permits now exhausted],
  [wait 4],      [−1], [1], [value went below 0, so this one blocks],
  [wait 5],      [−2], [2], [blocks],
  [signal 1],    [−1], [1], [value $<= 0$, so wake one waiter],
  [signal 2],    [0],  [0], [wake the other],
)

#ans[Value $= 0$, and *0* processes are blocked.]

Follow-up they will ask: "what would it be after only the five waits?" $-2$, with 2 blocked —
and the absolute value of a negative semaphore is always the number of waiters.
]

#section[Part 4 — The three classic problems]

Every OS syllabus has the same three. Know the shape of each and the failure mode of each.

#subsection[4.1 Producer–Consumer (bounded buffer)]

A producer adds items to a buffer of $N$ slots; a consumer removes them. The producer must
not write to a full buffer; the consumer must not read from an empty one.

#diagram(height: 4.6cm, caption: "Bounded buffer with three semaphores. `empty` counts free slots, `full` counts items, `mutex` protects the buffer itself.")[
  #dnode(0cm, 1.6cm, 3cm, 1cm, "PRODUCER", fill: rgb("#f2e9df"))
  #dnode(4.8cm, 1.6cm, 1.5cm, 1cm, "D1")
  #dnode(6.4cm, 1.6cm, 1.5cm, 1cm, "D2")
  #dnode(8cm, 1.6cm, 1.5cm, 1cm, "", fill: white)
  #dnode(9.6cm, 1.6cm, 1.5cm, 1cm, "", fill: white)
  #dnode(12.9cm, 1.6cm, 3cm, 1cm, "CONSUMER", fill: rgb("#f2e9df"))
  #darrow(3cm, 2.1cm, 4.8cm, 2.1cm, label: "put")
  #darrow(11.1cm, 2.1cm, 12.9cm, 2.1cm, label: "take")
  #dnode(4.8cm, 0.25cm, 6.3cm, 0.75cm, "empty = 2   (free slots)", fill: rgb("#dfe9f2"))
  #dnode(4.8cm, 3.05cm, 3cm, 0.75cm, "full = 2  (items)", fill: rgb("#dfe9f2"))
  #dnode(8.1cm, 3.05cm, 3cm, 0.75cm, "mutex = 1", fill: rgb("#dfe9f2"))
]

#code(lang: "c", caption: "The standard solution — memorise this shape")[
```c
semaphore empty = N;    /* free slots  */
semaphore full  = 0;    /* used slots  */
semaphore mutex = 1;    /* protects the buffer */

producer() {                       consumer() {
  while (true) {                     while (true) {
    item = produce();                  wait(full);     /* is there anything? */
    wait(empty);   /* is there room? */ wait(mutex);
    wait(mutex);                       item = remove();
    insert(item);                      signal(mutex);
    signal(mutex);                     signal(empty);  /* a slot is free now */
    signal(full);  /* one more item */ consume(item);
  }                                  }
}                                  }
```
]

#trap[
*Swap the order of the two `wait`s and you get a deadlock.* If the producer does
`wait(mutex)` before `wait(empty)` and the buffer is full, the producer holds `mutex` and
sleeps on `empty`. The consumer needs `mutex` to remove an item, so it blocks too. Nobody
can ever signal `empty`. Both sleep forever.

The rule to state out loud: *always acquire the counting semaphore before the mutex, and
release in the reverse order.* Never sleep while holding a lock.
]

#code(lang: "js", caption: "The same solution, runnable. Run: node c4.js")[
```js
class Semaphore {
  constructor(c) { this.count = c; this.waiters = []; }
  async wait() { if (this.count > 0) { this.count--; return; }
    await new Promise(r => this.waiters.push(r)); }
  signal() { const n = this.waiters.shift(); if (n) n(); else this.count++; }
}
const N = 3, buf = [];
const empty = new Semaphore(N);   // how many free slots
const full  = new Semaphore(0);   // how many filled slots
const mutex = new Semaphore(1);   // protects buf itself
const sleep = ms => new Promise(r => setTimeout(r, ms));

async function producer(items) {
  for (const it of items) {
    await empty.wait(); await mutex.wait();
    buf.push(it); console.log(`produced ${it}  buffer=[${buf}] size=${buf.length}`);
    mutex.signal(); full.signal();
    await sleep(5);
  }
}
async function consumer(n) {
  for (let i = 0; i < n; i++) {
    await full.wait(); await mutex.wait();
    const it = buf.shift(); console.log(`         consumed ${it}  buffer=[${buf}] size=${buf.length}`);
    mutex.signal(); empty.signal();
    await sleep(20);
  }
}
(async () => {
  await Promise.all([producer([1,2,3,4,5,6]), consumer(6)]);
  console.log('done. buffer never exceeded', N);
})();
```
]

#code(lang: "text", caption: "Actual output — the producer is faster, so the buffer fills to 3 and stops")[
```text
produced 1  buffer=[1] size=1
         consumed 1  buffer=[] size=0
produced 2  buffer=[2] size=1
produced 3  buffer=[2,3] size=2
produced 4  buffer=[2,3,4] size=3
         consumed 2  buffer=[3,4] size=2
produced 5  buffer=[3,4,5] size=3
         consumed 3  buffer=[4,5] size=2
produced 6  buffer=[4,5,6] size=3
         consumed 4  buffer=[5,6] size=2
         consumed 5  buffer=[6] size=1
         consumed 6  buffer=[] size=0
done. buffer never exceeded 3
```
]

The producer pushes every 5 ms, the consumer pulls every 20 ms, yet the buffer never grows
past 3. The `empty` semaphore forced the producer to wait. That is back-pressure, and it is
the same mechanism a message queue uses at scale.

#subsection[4.2 Readers–Writers]

Many readers may read at once. A writer needs exclusive access — no other writer, no readers.

#code(lang: "c", caption: "First readers-writers solution (reader preference) — shared state")[
```c
semaphore rw_mutex   = 1;   /* exclusive access to the data */
semaphore mutex      = 1;   /* protects read_count only     */
int       read_count = 0;   /* how many readers are inside  */
```
]

#code(lang: "c", caption: "The writer — the simple half")[
```c
writer() {
    wait(rw_mutex);
        /* ... write the data ... */
    signal(rw_mutex);
}
```
]

#code(lang: "c", caption: "The reader — all the cleverness is here")[
```c
reader() {
    wait(mutex);
    read_count++;
    if (read_count == 1)
        wait(rw_mutex);        /* the FIRST reader locks writers out */
    signal(mutex);

        /* ... read the data ... */

    wait(mutex);
    read_count--;
    if (read_count == 0)
        signal(rw_mutex);      /* the LAST reader lets writers back in */
    signal(mutex);
}
```
]

The key idea: only the *first* reader takes `rw_mutex` and only the *last* reader releases
it. Readers in between just adjust the counter.

#table(columns: 3, align: (left, left, left),
  [*Variant*], [*Rule*], [*Who starves*],
  [First (reader preference)], [a reader never waits unless a writer is already writing],
    [*writers* — a steady stream of readers blocks them forever],
  [Second (writer preference)], [once a writer is waiting, no new reader may start],
    [*readers*],
  [Third (fair)], [an extra queue semaphore serves requests in arrival order], [nobody],
)

#ex(3, tier: 2, asked: "GIC · pattern")[
A price table is read by 200 client threads every few milliseconds and written by one
updater thread once a second. The team uses the first readers-writers solution. After a
week, the updater has applied almost no updates. Explain exactly why, and give the smallest
fix.
]
#sol[
+ In the first solution, `rw_mutex` is held from the moment the *first* reader arrives until
  the moment the *last* reader leaves.
+ With 200 readers arriving every few milliseconds, `read_count` essentially never returns
  to 0.
+ So `signal(rw_mutex)` is essentially never executed, and the writer's `wait(rw_mutex)`
  never returns.
+ This is *starvation*, not deadlock: the system is making progress — readers are being
  served — just never the writer.

Smallest fix: switch to the *second* (writer-preference) variant, so that as soon as the
writer is waiting, newly arriving readers queue behind it. The 200 readers already inside
finish, `read_count` reaches 0, and the writer gets in.

#ans[Reader preference starves the writer. Use writer preference, or a fair queue.]

The follow-up: *"what does writer preference cost?"* Read latency spikes once a second while
the writer drains the readers. Naming that trade is the point.
]

#trap[
*Starvation is not deadlock.* In deadlock, nothing at all progresses and no amount of
waiting helps. In starvation, the system is busy and productive — one unlucky process just
never gets served. Deadlock is fixed by breaking a cycle; starvation is fixed by adding
fairness (aging, FIFO queues, priority boosts).
]

#subsection[4.3 Dining philosophers]

Five philosophers sit around a table. Between each pair is one fork. To eat, a philosopher
needs the fork on the left *and* the fork on the right.

The naive solution — everybody picks up the left fork, then the right — deadlocks the moment
all five pick up their left fork at the same instant. Every fork is held; every philosopher
waits for a neighbour.

#code(lang: "js", caption: "The deadlock and the one-line fix. Run: node c8.js")[
```js
const N = 5, fork = Array.from({length:N}, () => new Mutex());

async function philosopher(i, asymmetric) {
  const left = i, right = (i + 1) % N;
  let [a, b] = [left, right];
  if (asymmetric && i === N - 1) [a, b] = [right, left];   // the one lefty
  for (let k = 0; k < 3; k++) {
    await fork[a].lock(); await sleep(1); await fork[b].lock();
    meals++;                                   // eating
    await sleep(1);
    fork[b].unlock(); fork[a].unlock();
    await sleep(1);
  }
}
```
]

#code(lang: "text", caption: "Actual output")[
```text
everyone grabs left first : STUCK after 0 meals
one philosopher reversed  : finished all 15 meals
```
]

*Four accepted fixes — know all four, they are separate questions:*

#table(columns: 3, align: (left, left, left),
  [*Fix*], [*How*], [*Which condition it breaks*],
  [Allow only 4 at the table], [a semaphore initialised to $N-1$ guards the table],
    [circular wait — with 4 philosophers and 5 forks, someone always gets both],
  [Pick up both or neither], [test both forks inside one mutex; if both free, take both],
    [hold and wait],
  [Asymmetry], [odd-numbered philosophers take right first, even take left first],
    [circular wait],
  [Global ordering], [number the forks; always take the lower number first],
    [circular wait],
)

#trick[
Global lock ordering is the fix you should name *first* in a real-world question, because it
generalises: give every lock in the system a rank, and require every thread to acquire locks
in increasing rank. A cycle needs somebody to go "down" in rank, and nobody is allowed to.
]

#section[Part 5 — Deadlock]

#subsection[The four necessary conditions]

#table(columns: 3, align: (left, left, left),
  [*Condition*], [*Meaning*], [*How you would break it*],
  [Mutual exclusion], [at least one resource cannot be shared], [make it shareable — e.g. a
    spooler so nobody holds the printer],
  [Hold and wait], [a process holds one resource and waits for another], [require all
    resources to be requested at once; or release everything before asking for more],
  [No preemption], [a resource is only released voluntarily], [let the OS take it back —
    works for CPU and memory, not for a half-written file],
  [Circular wait], [a cycle of waiting processes], [impose a global ordering on resource
    types and require increasing order],
)

#trap[
Two mistakes, both fatal:

*(1)* "Deadlock needs all four conditions, so if any one is missing there is no deadlock."
The first half is right, the second half is the *useful* half — but students often state the
reverse: "if all four hold, deadlock happens." That is *false*. The four conditions are
*necessary, not sufficient*. All four can hold and the system may still run fine; it only
*can* deadlock. The RAG cycle test is what makes it sufficient in the single-instance case.

*(2)* Circular wait is the easiest one to attack in practice, and the *only* one most real
systems bother with. Breaking mutual exclusion is usually impossible.
]

#subsection[The resource allocation graph]

#diagram(height: 5.2cm, caption: "A resource allocation graph. Process-to-resource = a request. Resource-to-process = an assignment. This graph has a cycle.")[
  #dnode(1.2cm, 0.4cm, 2.2cm, 0.9cm, "P1", fill: rgb("#f2e9df"))
  #dnode(5.6cm, 0.4cm, 2.4cm, 0.9cm, "R1 · 1 instance")
  #dnode(10.2cm, 0.4cm, 2.2cm, 0.9cm, "P2", fill: rgb("#f2e9df"))
  #dnode(5.6cm, 3.2cm, 2.4cm, 0.9cm, "R2 · 1 instance")
  #darrow(3.4cm, 0.85cm, 5.6cm, 0.85cm, label: "requests")
  #darrow(8cm, 0.85cm, 10.2cm, 0.85cm, label: "held by")
  #darrow(10.8cm, 1.3cm, 7.6cm, 3.2cm, label: "requests")
  #darrow(5.6cm, 3.4cm, 2.6cm, 1.3cm, label: "held by")
  #dnode(13cm, 1.1cm, 3.4cm, 2.2cm, "Cycle:\nP1 → R1 → P2 → R2 → P1.\nSingle instances, so this\nIS a deadlock.", fill: rgb("#fdf4f4"))
]

The rule has two halves, and the second half is the one that gets marks:

- *Single instance of every resource type*: a cycle in the graph means deadlock, and no
  cycle means no deadlock. Cycle $<=>$ deadlock.
- *Multiple instances of some type*: a cycle is only a *possibility* of deadlock. You must
  run the detection algorithm to be sure.

#ex(4, tier: 1, asked: "Wipro · pattern")[
A resource allocation graph has a cycle. Can you conclude the system is deadlocked? Explain
in two lines.
]
#sol[
Only if *every resource type in the cycle has exactly one instance*. With one instance each,
a cycle means each process is waiting for a resource that can only be freed by the next
process in the cycle, which is itself waiting — nothing can move.

If some resource type in the cycle has two or more instances, the extra instance might be
held by a process *outside* the cycle that will finish and release it, breaking the cycle.

#ans[No — a cycle is necessary but sufficient only when all resources in it are
single-instance.]
]

#subsection[A deadlock you can run, and the fix]

#code(lang: "js", caption: "Two locks, two orders. Run: node c5.js")[
```js
const A = new Mutex('A'), B = new Mutex('B');

async function taskAB() {          // takes A, then B
  await A.lock();  console.log('T1 holds A');
  await sleep(20);
  console.log('T1 wants B ...');
  await B.lock();  console.log('T1 holds B');
  B.unlock(); A.unlock();
}

async function taskBA() {          // takes B, then A  <-- the opposite order
  await B.lock();  console.log('T2 holds B');
  await sleep(20);
  console.log('T2 wants A ...');
  await A.lock();  console.log('T2 holds A');
  A.unlock(); B.unlock();
}
```
]

#code(lang: "text", caption: "Actual output")[
```text
T1 holds A
T2 holds B
T1 wants B ...
T2 wants A ...
--- 300 ms later: nothing moved. DEADLOCK. ---
A.locked = true  waiters: 1
B.locked = true  waiters: 1
```
]

All four conditions are visible in those six lines: the mutexes are exclusive (1), each task
holds one and waits for the other (2), neither can be forced to let go (3), and T1 waits on
T2 which waits on T1 (4).

#code(lang: "js", caption: "The fix: a global ranking of locks. Run: node c6.js")[
```js
const ORDER = { A: 1, B: 2 };          // one global ranking of every lock

async function withBoth(who, m1, m2, work) {
  const lower = ORDER[m1.name] < ORDER[m2.name];
  const first  = lower ? m1 : m2;      // always take the lower rank first
  const second = lower ? m2 : m1;

  await first.lock();
  console.log(`${who} holds ${first.name}`);
  await sleep(20);
  await second.lock();
  console.log(`${who} holds ${second.name}`);

  await work();
  second.unlock();                     // release in reverse order
  first.unlock();
  console.log(`${who} released both`);
}
```
]

#code(lang: "text", caption: "Actual output — T2 asked for B then A, but the helper reordered it")[
```text
T1 holds A
T1 holds B
T1 released both
T2 holds A
T2 holds B
T2 released both
both finished - circular wait was impossible
```
]

#subsection[The four ways an OS can handle deadlock]

#table(columns: 4, align: (left, left, left, left),
  [*Strategy*], [*When it acts*], [*Cost*], [*Used by*],
  [Prevention], [before anything runs — design the rules so a condition cannot hold],
    [low resource utilisation; awkward to program], [real-time and embedded systems],
  [Avoidance], [at each request — grant only if the state stays safe],
    [needs each process to declare its maximum need in advance], [almost nothing in practice],
  [Detection + recovery], [after the fact — run a check, then kill or roll back],
    [the check costs CPU; recovery loses work], [database engines],
  [Ignore it (the "ostrich algorithm")], [never], [a rare hang; reboot], [Linux, Windows,
    macOS for user processes],
)

#ans[If asked "what does Linux do about deadlock between user processes?" the correct answer
is *nothing*. It is cheaper to reboot once a year than to slow every allocation down.]

#subsection[Banker's algorithm — deadlock avoidance, worked in full]

The idea: before granting a request, *pretend* to grant it and check whether the resulting
state is *safe*. Safe means "there exists an order in which all processes can finish".
If the pretend-state is unsafe, do not grant; make the process wait.

#formulas(title: "The state we will work with")[
Four transactions T1–T4 compete for three pools:
*A* = database connections (8 total), *B* = file locks (6 total), *C* = memory blocks (9 total).

#table(columns: 7, align: (left, right, right, right, right, right, right),
  table.cell(colspan: 1)[], table.cell(colspan: 3, align: center)[*Allocation*],
  table.cell(colspan: 3, align: center)[*Max*],
  [], [*A*], [*B*], [*C*], [*A*], [*B*], [*C*],
  [T1], [1], [2], [2], [4], [3], [3],
  [T2], [2], [0], [1], [5], [2], [4],
  [T3], [3], [1], [3], [4], [3], [5],
  [T4], [1], [1], [1], [3], [2], [3],
)
]

*Step 1 — compute Need = Max − Allocation, cell by cell.*

#table(columns: 4, align: (left, left, left, left),
  [*Process*], [*A*], [*B*], [*C*],
  [T1], [$4 - 1 = 3$], [$3 - 2 = 1$], [$3 - 2 = 1$],
  [T2], [$5 - 2 = 3$], [$2 - 0 = 2$], [$4 - 1 = 3$],
  [T3], [$4 - 3 = 1$], [$3 - 1 = 2$], [$5 - 3 = 2$],
  [T4], [$3 - 1 = 2$], [$2 - 1 = 1$], [$3 - 1 = 2$],
)

*Step 2 — compute Available = Total − (sum of the Allocation column).*

- A: allocated $= 1 + 2 + 3 + 1 = 7$. Available $= 8 - 7 = 1$.
- B: allocated $= 2 + 0 + 1 + 1 = 4$. Available $= 6 - 4 = 2$.
- C: allocated $= 2 + 1 + 3 + 1 = 7$. Available $= 9 - 7 = 2$.

#ans[Available $= (1, 2, 2)$]

*Step 3 — the safety check.* Keep a running vector `Work`, starting at Available. Walk the
list; whenever `Need <= Work`, that process can finish, so add its Allocation to `Work`.

#table(columns: 4, align: (left, left, left, left),
  [*Try*], [*Need vs Work*], [*Verdict*], [*Work becomes*],
  [T1], [$(3,1,1)$ vs $(1,2,2)$ — A: $3 > 1$], [blocked], [$(1,2,2)$],
  [T2], [$(3,2,3)$ vs $(1,2,2)$ — A: $3 > 1$], [blocked], [$(1,2,2)$],
  [T3], [$(1,2,2)$ vs $(1,2,2)$ — all $<=$], [*finishes*, releases $(3,1,3)$], [$(4,3,5)$],
  [T4], [$(2,1,2)$ vs $(4,3,5)$ — all $<=$], [*finishes*, releases $(1,1,1)$], [$(5,4,6)$],
  [T1], [$(3,1,1)$ vs $(5,4,6)$ — all $<=$], [*finishes*, releases $(1,2,2)$], [$(6,6,8)$],
  [T2], [$(3,2,3)$ vs $(6,6,8)$ — all $<=$], [*finishes*, releases $(2,0,1)$], [$(8,6,9)$],
)

`Work` ends at $(8, 6, 9)$, which is exactly Total — every resource is back. All four
finished.

#ans[The state is SAFE. Safe sequence: T3 $->$ T4 $->$ T1 $->$ T2]

Notice that *T3 is the only process that can start*. Availability $(1,2,2)$ matches T3's
need exactly. If T3 had needed one more of anything, the state would have been unsafe.

#ex(5, tier: 2, asked: "Grab · pattern")[
From the state above, T2 requests $(1, 1, 1)$. Should the banker grant it?
]
#sol[
Three checks, in this order. Skipping the order is how students lose the mark.

*Check 1 — is the request within what T2 declared?*
$"Request" = (1,1,1)$, $"Need"["T2"] = (3,2,3)$. $1 <= 3$, $1 <= 2$, $1 <= 3$ ✓. Legal.

*Check 2 — is there enough available right now?*
$"Available" = (1,2,2)$. $1 <= 1$, $1 <= 2$, $1 <= 2$ ✓. Physically possible.

*Check 3 — pretend to grant it, then test safety.*
- Available becomes $(1,2,2) - (1,1,1) = (0,1,1)$.
- Allocation[T2] becomes $(2,0,1) + (1,1,1) = (3,1,2)$.
- Need[T2] becomes $(3,2,3) - (1,1,1) = (2,1,2)$.

Now run the safety check with $"Work" = (0,1,1)$:

#table(columns: 3, align: (left, left, left),
  [*Try*], [*Need vs Work $= (0,1,1)$*], [*Verdict*],
  [T1], [$(3,1,1)$ — A: $3 > 0$], [blocked],
  [T2], [$(2,1,2)$ — A: $2 > 0$], [blocked],
  [T3], [$(1,2,2)$ — A: $1 > 0$], [blocked],
  [T4], [$(2,1,2)$ — A: $2 > 0$], [blocked],
)

No process can proceed. `Work` never grows. The state is *unsafe*.

#ans[DENY. T2 must wait, even though the resources are physically available.]

That last clause is the whole lesson of the Banker's algorithm and the follow-up question
you should answer before it is asked: *the banker refuses requests it could physically
satisfy, because satisfying them would leave no guaranteed way out.*
]

#ex(6, tier: 2, asked: "SCB · pattern")[
Back to the original state. Now T3 requests $(0, 2, 2)$. Grant or deny?
]
#sol[
*Check 1 — within Need?* $"Need"["T3"] = (1,2,2)$. $0 <= 1$, $2 <= 2$, $2 <= 2$ ✓.

*Check 2 — available?* $"Available" = (1,2,2)$. $0 <= 1$, $2 <= 2$, $2 <= 2$ ✓.

*Check 3 — pretend and test.*
- Available $= (1,2,2) - (0,2,2) = (1,0,0)$.
- Allocation[T3] $= (3,1,3) + (0,2,2) = (3,3,5)$.
- Need[T3] $= (1,2,2) - (0,2,2) = (1,0,0)$.

Safety check with $"Work" = (1,0,0)$:

#table(columns: 4, align: (left, left, left, left),
  [*Try*], [*Need vs Work*], [*Verdict*], [*Work becomes*],
  [T1], [$(3,1,1)$ vs $(1,0,0)$], [blocked], [$(1,0,0)$],
  [T2], [$(3,2,3)$ vs $(1,0,0)$], [blocked], [$(1,0,0)$],
  [T3], [$(1,0,0)$ vs $(1,0,0)$ — equal], [*finishes*, releases $(3,3,5)$], [$(4,3,5)$],
  [T4], [$(2,1,2)$ vs $(4,3,5)$], [*finishes*, releases $(1,1,1)$], [$(5,4,6)$],
  [T1], [$(3,1,1)$ vs $(5,4,6)$], [*finishes*, releases $(1,2,2)$], [$(6,6,8)$],
  [T2], [$(3,2,3)$ vs $(6,6,8)$], [*finishes*, releases $(2,0,1)$], [$(8,6,9)$],
)

#ans[GRANT. Safe sequence T3 $->$ T4 $->$ T1 $->$ T2.]

Compare with Example 5: T2's request took away the last unit of A and left nobody able to
move. T3's request took B and C but *left A alone* — and A was the scarce one.
]

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
Back to the original state. T1 requests $(2, 0, 0)$. What happens?
]
#sol[
*Check 1 — within Need?* $"Need"["T1"] = (3,1,1)$. $2 <= 3$ ✓.

*Check 2 — available?* $"Available" = (1,2,2)$. Is $2 <= 1$? *No.*

The check fails at step 2. We never reach the safety test.

#ans[T1 must WAIT — not because the state would be unsafe, but because the resources are
not there right now.]

#trap[
"Wait because unsafe" and "wait because unavailable" are different answers, and examiners
check which one you gave. Step 2 failing means *"come back later"*. Step 3 failing means
*"I have the resources but I refuse"*. Only the second one is the Banker's algorithm doing
anything interesting.
]
]

#subsection[Deadlock detection — when there is no Max matrix]

If processes never declare a maximum, avoidance is impossible. Instead, let deadlock happen
and detect it. The algorithm is the safety check with `Request` in place of `Need`.

Four transactions, three resource pools with totals $A = 4$, $B = 3$, $C = 3$:

#table(columns: 7, align: (left, right, right, right, right, right, right),
  table.cell(colspan: 1)[], table.cell(colspan: 3, align: center)[*Allocation*],
  table.cell(colspan: 3, align: center)[*Request (outstanding)*],
  [], [*A*], [*B*], [*C*], [*A*], [*B*], [*C*],
  [Q1], [1], [1], [0], [2], [0], [1],
  [Q2], [1], [0], [2], [0], [1], [0],
  [Q3], [1], [1], [0], [2], [0], [1],
  [Q4], [1], [0], [1], [0], [0], [0],
)

Available: A $= 4 - 4 = 0$, B $= 3 - 2 = 1$, C $= 3 - 3 = 0$, so $"Available" = (0,1,0)$.

*Case 1 — the table as shown.*

#table(columns: 4, align: (left, left, left, left),
  [*Try*], [*Request vs Work*], [*Verdict*], [*Work becomes*],
  [Q1], [$(2,0,1)$ vs $(0,1,0)$], [stuck], [$(0,1,0)$],
  [Q2], [$(0,1,0)$ vs $(0,1,0)$], [*can finish*, releases $(1,0,2)$], [$(1,1,2)$],
  [Q3], [$(2,0,1)$ vs $(1,1,2)$ — A: $2 > 1$], [stuck], [$(1,1,2)$],
  [Q4], [$(0,0,0)$ vs $(1,1,2)$], [*can finish*, releases $(1,0,1)$], [$(2,1,3)$],
  [Q1], [$(2,0,1)$ vs $(2,1,3)$], [*can finish*, releases $(1,1,0)$], [$(3,2,3)$],
  [Q3], [$(2,0,1)$ vs $(3,2,3)$], [*can finish*, releases $(1,1,0)$], [$(4,3,3)$],
)

All four completed. #ans[No deadlock. Completion order Q2, Q4, Q1, Q3.]

*Case 2 — identical table, except Q2 now requests $(0, 3, 0)$ instead of $(0, 1, 0)$.*

#table(columns: 4, align: (left, left, left, left),
  [*Try*], [*Request vs Work*], [*Verdict*], [*Work becomes*],
  [Q1], [$(2,0,1)$ vs $(0,1,0)$], [stuck], [$(0,1,0)$],
  [Q2], [$(0,3,0)$ vs $(0,1,0)$ — B: $3 > 1$], [stuck], [$(0,1,0)$],
  [Q3], [$(2,0,1)$ vs $(0,1,0)$], [stuck], [$(0,1,0)$],
  [Q4], [$(0,0,0)$ vs $(0,1,0)$], [*can finish*, releases $(1,0,1)$], [$(1,1,1)$],
  [Q1], [$(2,0,1)$ vs $(1,1,1)$ — A: $2 > 1$], [stuck], [$(1,1,1)$],
  [Q2], [$(0,3,0)$ vs $(1,1,1)$ — B: $3 > 1$], [stuck], [$(1,1,1)$],
  [Q3], [$(2,0,1)$ vs $(1,1,1)$ — A: $2 > 1$], [stuck], [$(1,1,1)$],
)

`Work` stops growing at $(1,1,1)$ and three processes never finish.

#ans[DEADLOCKED: Q1, Q2 and Q3. Only Q4 completed.]

One extra unit of demand from Q2 turned a working system into a three-way deadlock. That is
how sudden real deadlocks are.

#subsection[Recovery]

Once detected, something has to give:

+ *Abort every deadlocked process.* Always works, maximum damage.
+ *Abort one at a time* until the cycle breaks, re-running detection after each. Cheaper,
  slower. Choose the victim by: lowest priority, least CPU used so far, fewest resources
  held, least work lost.
+ *Preempt resources* and roll a process back to a safe checkpoint. This is what database
  engines do — they pick the transaction that has done the least work and abort it with a
  "deadlock victim" error, and the application retries.

#trap[
Rolling back can cause *starvation*: the same process is chosen as victim every time, is
rolled back every time, and never completes. Real systems fix this by including "how many
times have you already been the victim" in the victim-selection cost.
]

#section[Part 6 — Monitors and condition variables]

Semaphores work, but they are *easy to get wrong*. Miss a `signal` and the system hangs.
Miss a `wait` and mutual exclusion is gone. Swap two lines and you deadlock. All of those
bugs are invisible in a code review, because a semaphore is just an integer and nothing
connects it to the data it is supposed to protect.

A *monitor* fixes that by construction. It is a language feature: a bundle of shared data
plus the procedures that operate on it, with the rule that *only one thread can be executing
inside the monitor at any time*. The compiler inserts the locking; you cannot forget it.

#code(lang: "c", caption: "The shape of a monitor")[
```c
monitor Account {
    int balance = 0;            /* data is PRIVATE to the monitor */
    condition enough;           /* a condition variable           */

    void deposit(int n) {
        balance += n;
        signal(enough);         /* wake one waiter, if any        */
    }

    void withdraw(int n) {
        while (balance < n)     /* while, NOT if - see the trap   */
            wait(enough);       /* release the monitor and sleep  */
        balance -= n;
    }
}
```
]

#subsection[Condition variables — two operations, and they are not semaphores]

- `wait(c)` — release the monitor lock and sleep on `c`. The thread is suspended.
- `signal(c)` — wake *one* thread waiting on `c`. If nobody is waiting, *nothing happens*.

#table(columns: 3, align: (left, left, left),
  [], [*Semaphore*], [*Condition variable*],
  [Has a value?], [yes — an integer], [no — it is only a waiting list],
  [`signal` with no waiter], [increments; the next `wait` passes straight through],
    [*is lost forever* — nothing is remembered],
  [Used with a lock?], [it is the lock], [always used *inside* a monitor / with a mutex],
  [What it means], ["there are $N$ permits"], ["a condition may have become true"],
)

#trap[
Two mistakes, both extremely common:

*(1) `if` instead of `while`.* After `wait(c)` returns, the condition you were waiting for
may already be false again — another thread could have run between the `signal` and your
wake-up, or the wake-up could be spurious. Always re-check in a loop:
`while (!condition) wait(c);` Writing `if` produces a bug that appears once in ten thousand
runs.

*(2) "A condition variable is a binary semaphore."* No. A `signal` on a condition variable
with no waiter is *thrown away*. A `signal` on a semaphore is *remembered* as a count. That
difference is exactly why condition variables must always be paired with a re-checked
predicate.
]

#subsection[Signal-and-wait vs signal-and-continue]

When thread A signals and thread B was waiting, who holds the monitor next?

- *Hoare (signal-and-wait)*: B runs immediately; A steps aside and waits. B is guaranteed
  the condition still holds. Harder to implement, costs an extra context switch.
- *Mesa (signal-and-continue)*: A keeps running; B becomes merely *ready*. Simpler and
  faster — and it is why the condition can be false again by the time B wakes, and why the
  `while` loop is mandatory.

Every real system (Java's `synchronized`/`wait`/`notify`, POSIX condition variables, C\#
monitors) uses *Mesa* semantics.

#ex(8, tier: 2, asked: "LINE MAN · pattern")[
A job queue uses a monitor. A worker does:
```
if (queue.isEmpty()) wait(notEmpty);
job = queue.removeFirst();
```
With one worker it is fine. With eight workers, `removeFirst()` sometimes throws "empty
queue". Explain and fix.
]
#sol[
+ A producer adds one job and calls `signal(notEmpty)`.
+ Under Mesa semantics the producer *keeps running*; the woken worker W1 only becomes READY.
+ Before W1 is scheduled, another worker W2 — which arrived fresh and never waited — enters
  the monitor, sees a non-empty queue, and takes the job.
+ W1 finally runs. Its `wait` has returned, the `if` is not re-evaluated, and the queue is
  empty again. `removeFirst()` throws.

With one worker there is no W2, so the bug never shows.

Fix — one character of meaning, three of text:
```
while (queue.isEmpty()) wait(notEmpty);
job = queue.removeFirst();
```

#ans[Mesa semantics mean the condition can go false between `signal` and wake-up. Use
`while`, never `if`.]

Follow-up to volunteer: *"and this is also why `signal` versus `broadcast` matters"* — if
several waiters are waiting for different conditions on the same variable, `signal` may wake
the wrong one, and it goes back to sleep while the right one is never woken. Use `broadcast`
(`notifyAll`) when waiters are not interchangeable.
]

#note[
JavaScript has no monitors, but the `Mutex` class from Part 3 plus a `while` re-check is
exactly the same pattern. In Java the keywords are `synchronized`, `wait()`, `notify()` and
`notifyAll()`, and the standard advice — "always call `wait()` inside a loop" — is this rule.
]

#section[Part 7 — Three more hazards with similar names]

#table(columns: 3, align: (left, left, left),
  [*Name*], [*What is happening*], [*Are threads making progress?*],
  [Deadlock], [a cycle of waiting; nobody can move], [no — CPU idle or doing other work],
  [Livelock], [threads keep changing state in response to each other but never advance],
    [*yes* — they are busy, and achieving nothing],
  [Starvation], [the system works, but one process never gets served], [yes, for everyone else],
)

*Livelock* in one image: two people meet in a corridor, both step left, both step right,
both step left. They are moving. They are not getting past. In code it appears with
"try-lock and back off" schemes where both threads back off by the same amount, retry at the
same moment, and collide again. The fix is *randomised* back-off.

#subsection[Priority inversion]

Three threads, priorities High, Medium, Low:

+ *L* (low) acquires a lock on a shared resource.
+ *H* (high) wakes up, tries to take the same lock, and blocks behind L. So far, correct.
+ *M* (medium) wakes up. It needs no lock. It preempts L, because M outranks L.
+ Now M runs, L cannot run, so L cannot release the lock, so H cannot run.

The result: a *medium*-priority thread has effectively blocked a *high*-priority one. That
is priority inversion, and in a real-time system it is a missed deadline.

#table(columns: 2, align: (left, left),
  [*Fix*], [*How it works*],
  [Priority inheritance], [while H is blocked on L's lock, L temporarily runs at H's
    priority. M can no longer preempt L. L finishes fast, releases, and drops back down.],
  [Priority ceiling], [every lock is tagged with the highest priority of any thread that may
    ever take it. A thread holding the lock immediately runs at that ceiling.],
)

#ex(9, tier: 3, asked: "Goldman Sachs · pattern")[
A trading system has a high-priority risk-check thread, a medium-priority logging thread,
and a low-priority metrics thread. Risk checks occasionally take 400 ms instead of the usual
2 ms. Metrics and risk both use a shared configuration object behind a mutex. Explain the
mechanism, and give two fixes with their trade-offs.
]
#sol[
*Mechanism — priority inversion.*
+ The metrics thread (low) takes the config mutex.
+ A risk check (high) starts, needs the config, and blocks on that mutex.
+ The logging thread (medium) becomes runnable. It does not need the mutex, and it outranks
  metrics, so it preempts metrics.
+ Metrics cannot run, so it cannot release the mutex, so risk stays blocked — for as long as
  logging keeps running. The 400 ms is the logging burst, not the risk check itself.

The tell-tale sign is that the delay is *bimodal*: usually 2 ms, occasionally a fixed large
value that matches some other thread's work, never anything in between.

*Fix 1 — priority inheritance on that mutex.* While risk is blocked on it, metrics runs at
risk's priority, so logging cannot preempt it.
Trade-off: the delay drops to the length of the metrics critical section, but it is no
longer possible to reason about the priority of a thread by reading its declaration —
priorities change at runtime, and that makes the system harder to analyse and test.

*Fix 2 — remove the sharing.* Give the risk thread its own immutable snapshot of the
configuration, swapped atomically by a single pointer write when config changes. Readers
take no lock at all.
Trade-off: a risk check may briefly use a configuration that is one version old, and memory
use doubles while both versions are live. For a risk check running every few milliseconds,
one stale version is almost always acceptable — and this fix removes the whole class of bug
rather than softening it.

#ans[Priority inversion; fix with priority inheritance, or better, by removing the shared
mutable state.]

The sentence that wins this question: *"The correct long-term fix is to not share mutable
state across priority levels. Priority inheritance treats the symptom."*
]

#section[Practice]

#tier-header(0)

#practice(tier: 0, time: "8 min")[
+ Define a race condition in one sentence.
+ Name the three requirements of a correct critical-section solution.
+ A counting semaphore starts at 1. What is it usually called?
+ Which semaphore operation decreases the value?
+ Name the four necessary conditions for deadlock.
+ A binary semaphore is at 0. A thread calls `wait()`. What happens to it?
+ True or false: a spinlock puts the waiting thread to sleep.
+ In the bounded-buffer solution, what does the `full` semaphore count?
]

#key[
1. Two or more threads access shared data concurrently and the final result depends on the
   order in which they run.
2. Mutual exclusion, progress, bounded waiting.
3. A binary semaphore (used as a lock).
4. `wait()` — also called P, down, or acquire.
5. Mutual exclusion, hold and wait, no preemption, circular wait.
6. It blocks — it is added to the semaphore's queue and moved to the WAITING state.
7. False. A spinlock *busy-waits*, burning CPU. A blocking lock sleeps.
8. The number of *filled* slots, i.e. items available to consume.
]

#tier-header(1)

#practice(tier: 1, time: "20 min")[
+ Give three differences between a mutex and a semaphore.
+ A semaphore starts at 4. Operations happen in this order: wait, wait, signal, wait, wait,
  wait, wait. Give the final value and the number of blocked processes.
+ Explain why the producer must call `wait(empty)` before `wait(mutex)` and not the other
  way round.
+ Which of the four deadlock conditions does "request all your resources at once" break?
+ Why is starvation not the same as deadlock?
+ Write the entry and exit sections of Peterson's algorithm from memory.
+ A system has 1 printer, 1 scanner. P1 holds the printer and wants the scanner; P2 holds the
  scanner and wants the printer. Draw the RAG and say whether this is a deadlock.
]

#key[
*1.* (i) A mutex has an *owner* — only the locking thread may unlock; a semaphore has none.
(ii) A mutex is binary; a counting semaphore can hold any non-negative count.
(iii) A mutex is for mutual exclusion only; a semaphore is also used for *signalling*
between threads and for capping concurrency at $N$.
(Bonus fourth: mutexes usually support priority inheritance; semaphores usually do not.)

*2.* Start 4. wait $->$ 3, wait $->$ 2, signal $->$ 3, wait $->$ 2, wait $->$ 1,
wait $->$ 0, wait $->$ −1.
Final value $= -1$, so *1 process is blocked*.

*3.* If the producer takes `mutex` first and the buffer is full, it will then block on
`wait(empty)` *while still holding the mutex*. The consumer needs the mutex to remove an
item and free a slot, so it blocks too. Neither can proceed — deadlock. The general rule:
never go to sleep while holding a lock.

*4.* Hold and wait. (If you get everything at once, you never hold one thing while waiting
for another.)

*5.* In deadlock nothing progresses and waiting will never help, because every process in
the cycle waits on another in the cycle. In starvation the system *is* progressing — other
processes are being served — one particular process just keeps losing. Deadlock needs the
cycle broken; starvation needs fairness added.

*6.* Entry: `flag[i] = true; turn = j; while (flag[j] && turn == j) ;`
Exit: `flag[i] = false;`

*7.* Graph: P1 $->$ scanner, scanner $->$ P2, P2 $->$ printer, printer $->$ P1. That is a
cycle, and each resource has exactly one instance. *Yes, it is a deadlock.*
]

#tier-header(2)

#practice(tier: 2, time: "25 min")[
+ Given Allocation, Max and Total below, compute Need and Available, then find a safe
  sequence or show none exists.
  Total $= (6, 5, 7)$.
  #table(columns: 7, align: (left, right, right, right, right, right, right),
    [], [*Alloc A*], [*B*], [*C*], [*Max A*], [*B*], [*C*],
    [X1], [1], [1], [2], [3], [2], [4],
    [X2], [2], [1], [1], [4], [2], [3],
    [X3], [1], [1], [2], [2], [3], [4],
  )
+ From that state, X1 requests $(1, 0, 1)$. Grant or deny? Show all three checks.
+ A logging library takes lock `L` then lock `M`. A metrics library takes `M` then `L`. Both
  are called from the same request handler. Describe the failure and give two fixes.
+ Explain how a database engine handles deadlock, and why it does not use the Banker's
  algorithm.
]

#key[
*1.* Need = Max − Alloc:
- X1: $(3-1, 2-1, 4-2) = (2, 1, 2)$
- X2: $(4-2, 2-1, 3-1) = (2, 1, 2)$
- X3: $(2-1, 3-1, 4-2) = (1, 2, 2)$

Allocated totals: A $= 1+2+1 = 4$; B $= 1+1+1 = 3$; C $= 2+1+2 = 5$.
Available $= (6-4, 5-3, 7-5) = (2, 2, 2)$.

Safety check, Work $= (2,2,2)$:
- X1: Need $(2,1,2) <= (2,2,2)$ ✓ $->$ finishes, releases $(1,1,2)$ $->$ Work $= (3,3,4)$.
- X2: Need $(2,1,2) <= (3,3,4)$ ✓ $->$ finishes, releases $(2,1,1)$ $->$ Work $= (5,4,5)$.
- X3: Need $(1,2,2) <= (5,4,5)$ ✓ $->$ finishes, releases $(1,1,2)$ $->$ Work $= (6,5,7)$ =
  Total ✓

*Safe.* Sequence X1 $->$ X2 $->$ X3. (X3 $->$ X1 $->$ X2 also works — any valid sequence
scores.)

*2.* Request $(1,0,1)$ from X1.
- Check 1: Need[X1] $= (2,1,2)$. $1 <= 2$, $0 <= 1$, $1 <= 2$ ✓.
- Check 2: Available $= (2,2,2)$. $1 <= 2$, $0 <= 2$, $1 <= 2$ ✓.
- Check 3: pretend. Available $= (1,2,1)$; Alloc[X1] $= (2,1,3)$; Need[X1] $= (1,1,1)$.
  - X1: $(1,1,1) <= (1,2,1)$ ✓ $->$ releases $(2,1,3)$ $->$ Work $= (3,3,4)$.
  - X2: $(2,1,2) <= (3,3,4)$ ✓ $->$ releases $(2,1,1)$ $->$ Work $= (5,4,5)$.
  - X3: $(1,2,2) <= (5,4,5)$ ✓ $->$ releases $(1,1,2)$ $->$ Work $= (6,5,7)$ ✓

*GRANT.* Safe sequence X1 $->$ X2 $->$ X3.

*3.* Two threads in the same handler can take `L` and `M` in opposite orders. Thread 1 holds
`L` and waits for `M`; thread 2 holds `M` and waits for `L`. Circular wait, and the handler
hangs — usually under load, when the two libraries are called close together.

Fix 1: *global lock ordering.* Rank every lock in the process and require increasing order;
wrap both libraries in a helper that acquires in rank order. Cost: you must know every lock
in every dependency, which is hard with third-party code.

Fix 2: *lock with a timeout* (`try_lock` with a deadline). On timeout, release everything
you hold, back off a *random* interval, and retry. Cost: this converts a hang into a retry
storm unless the back-off is randomised, and it turns deadlock into possible livelock.

(A third, best answer: do not hold two library locks at once — copy what you need out from
under the first lock before taking the second.)

*4.* A database engine uses *detection plus recovery*. It maintains a wait-for graph of
transactions and periodically looks for a cycle (or simply uses a lock-wait timeout). When
it finds one, it picks a *victim* — usually the transaction that has done the least work or
holds the fewest locks — aborts it, rolls it back, and returns a "deadlock detected" error
so the application can retry.

It cannot use the Banker's algorithm because the Banker's algorithm requires each process to
declare its *maximum* resource claim in advance. A transaction does not know in advance
which rows it will lock; that depends on the data it reads. Without a Max matrix, avoidance
is impossible, so detection is the only option left.
]

#tier-header(3)

#practice(tier: 3, time: "30 min")[
+ Prove that a safe state can never be a deadlocked state, and give an example of an *unsafe*
  state that does not deadlock.
+ Design the locking for a transfer function `transfer(from, to, amount)` used by thousands
  of threads over a million accounts. It must be deadlock-free and must not serialise all
  transfers behind one global lock. State the failure mode your design still has.
+ A service uses a bounded work queue with `empty`/`full`/`mutex` semaphores. Under load, CPU
  is 8% and throughput has collapsed, but nothing is deadlocked. Give three possible causes
  and how you would tell them apart.
+ Why does the Banker's algorithm see almost no use in real operating systems? Give three
  separate reasons.
]

#key[
*1.* Safe means there is an ordering $P_1, P_2, dots, P_n$ in which each $P_i$ can obtain its
Need from Available plus everything released by $P_1 dots P_(i-1)$. Deadlock means a set of
processes exists where none can ever proceed. If the state is safe, $P_1$ can proceed right
now with what is available, so at least one process is not blocked — so no process is in a
permanent wait cycle. A safe state therefore cannot be deadlocked.

Unsafe that does not deadlock: three processes each hold 2 units of a 7-unit pool and each
*may* eventually need 4 more, so Available $= 1$ and no single process is guaranteed to
finish — the state is unsafe. But if one of them happens to never request its full maximum
and instead finishes and releases its 2 units, everything resolves. Unsafe means "no
guarantee", not "certain failure".

*2.* Per-account locks, acquired in a *global order* derived from the account id.

```
transfer(from, to, amount):
    if from.id == to.id: return
    first, second = (from, to) if from.id < to.id else (to, from)
    lock(first); lock(second)
    try:   if from.balance >= amount: from -= amount; to += amount
    finally: unlock(second); unlock(first)
```

- Circular wait is impossible: every thread takes the lower id first, so a cycle would need
  some thread to go from a higher id to a lower one.
- Contention stays low: two transfers touching four different accounts never meet.
- The `from.id == to.id` guard matters — without it a self-transfer locks the same mutex
  twice and self-deadlocks.

Remaining failure mode: *hot accounts*. If one account (a merchant, an exchange float) is in
half of all transfers, its lock serialises those transfers, and the per-account scheme buys
nothing for them. The fix is to shard that one account's balance into $k$ sub-balances and
pick one at random, summing them when a total is needed — which trades exact instantaneous
balance readability for throughput. Say that trade out loud.

*3.* Low CPU plus low throughput means threads are *blocked*, not busy.
- *(a) The queue is empty* — producers are the bottleneck. Check: the `full` semaphore sits
  at 0 and consumers are all parked in `wait(full)`. Look upstream.
- *(b) The queue is full* — consumers are the bottleneck, and `empty` sits at 0 with
  producers parked. Check whether consumers are blocked on something downstream (a slow
  database, an exhausted connection pool). Symptom: queue depth pinned at $N$.
- *(c) Convoying on the mutex* — a consumer is holding `mutex` across a slow operation
  (logging, I/O, a JSON parse), so everyone queues behind it. Check: `mutex` is held far
  longer than it should be; thread dumps show many threads waiting on the same lock and one
  thread inside it doing something slow.

How to tell them apart in one measurement: *sample the queue depth*. Pinned at 0 $->$ (a).
Pinned at $N$ $->$ (b). Oscillating with threads stacked on `mutex` $->$ (c).

*4.* Three reasons:
- *It needs a Max declaration.* A process must state its maximum need for every resource
  type before it starts. Real programs do not know this — memory use depends on input, file
  handles depend on user actions.
- *It assumes a fixed resource count.* Devices are plugged in and removed, memory is added
  to a VM, processes are created and destroyed constantly. The Banker's model assumes a
  static set of processes and resources.
- *It is too slow and too conservative.* The safety check is $O(n^2 m)$ for $n$ processes and
  $m$ resource types, and it must run on *every single request*. Worse, it refuses requests
  it could safely have granted, so utilisation drops — for a problem that, on a desktop or
  server, happens rarely enough that a reboot is cheaper.

Where the idea does survive: systems with a small, fixed, known set of tasks — avionics,
industrial controllers — which is exactly the environment the algorithm was designed for.
]

#section[Rapid fire — one-line answers]

#table(columns: 2, align: (left, left),
  [*Question*], [*Answer*],
  [What is a race condition?], [Shared data accessed concurrently, where the result depends on the order of execution.],
  [What is a critical section?], [The part of a program that accesses shared data and must not run concurrently with itself.],
  [Three requirements of a CS solution?], [Mutual exclusion, progress, bounded waiting.],
  [The key line in Peterson's?], [`turn = j` — you give the turn to the *other* process.],
  [Test-and-set vs compare-and-swap?], [Both are atomic. Test-and-set sets a flag to true and returns the old value; CAS writes only if the current value matches the expected one.],
  [Spinlock vs blocking lock?], [Spinlock busy-waits (good for very short sections); a blocking lock sleeps.],
  [What does a negative semaphore value mean?], [Its absolute value is the number of blocked processes.],
  [Mutex vs semaphore in one line?], [A mutex has an owner and is for locking; a semaphore is a counter with no owner and is also for signalling.],
  [In producer-consumer, what does `empty` count?], [Free slots. `full` counts items.],
  [What breaks if you take `mutex` before `empty`?], [Deadlock — the producer sleeps holding the mutex.],
  [Who starves in the first readers-writers solution?], [Writers.],
  [Dining philosophers: the simplest fix?], [Make one philosopher pick up the right fork first (asymmetry).],
  [Four necessary conditions for deadlock?], [Mutual exclusion, hold and wait, no preemption, circular wait.],
  [Are the four conditions sufficient?], [No — necessary only. All four can hold without a deadlock occurring.],
  [When does a RAG cycle prove deadlock?], [Only when every resource type in the cycle has a single instance.],
  [Four strategies for handling deadlock?], [Prevention, avoidance, detection and recovery, ignore it.],
  [What does Linux do about deadlock?], [Nothing — the ostrich algorithm.],
  [What does the Banker's algorithm need in advance?], [Each process's maximum claim for every resource type.],
  [Need formula?], [$"Need" = "Max" - "Allocation"$.],
  [Available formula?], [$"Available" = "Total" - sum "Allocation"$.],
  [What is a safe state?], [One where some ordering lets every process finish.],
  [Is every unsafe state a deadlock?], [No — unsafe means no guarantee, not certain failure.],
  [What is a monitor?], [Shared data plus its procedures, with automatic mutual exclusion — only one thread inside at a time.],
  [Condition variable vs semaphore?], [A semaphore remembers a `signal` as a count; a condition variable throws it away if nobody is waiting.],
  [Why `while` and not `if` around `wait()`?], [Mesa semantics — the condition can be false again by the time you wake up.],
  [Deadlock vs livelock?], [In deadlock threads are blocked; in livelock they keep running and keep undoing each other.],
  [Deadlock vs starvation?], [Deadlock: nobody progresses. Starvation: everybody but one progresses.],
  [What is priority inversion?], [A low-priority thread holding a lock blocks a high-priority one, and a medium one preempts the low.],
  [Fix for priority inversion?], [Priority inheritance (or a priority ceiling).],
  [How do databases handle deadlock?], [Detect a cycle in the wait-for graph, abort a victim transaction, let the client retry.],
)

#revision[
*Race condition* = shared data + concurrent access + order-dependent result. Fix by making
the read-modify-write atomic.

*Critical section* needs all three: mutual exclusion, *progress*, bounded waiting. Progress
is the one broken solutions fail.

*Peterson's:* `flag[i] = true; turn = j; while (flag[j] && turn == j) ;` $->$ CS $->$
`flag[i] = false;`

*Semaphore:* `wait` decrements and may block; `signal` increments and wakes one. A negative
value means that many waiters.
*Mutex vs semaphore:* mutex has an owner and is a lock; semaphore has no owner and is a
counter and a signal.

*Producer-consumer order:* `wait(empty); wait(mutex); ... signal(mutex); signal(full);`
Reverse the two waits and you deadlock.

*Readers-writers:* reader preference starves writers; writer preference starves readers; a
fair queue starves nobody.

*Dining philosophers fixes:* at most $N-1$ at the table · both-or-neither · asymmetry ·
global fork ordering.

*Monitor* = data + procedures + automatic mutual exclusion. Condition variables inside it:
`wait` sleeps and releases, `signal` wakes one and is *lost* if nobody waits. Everything real
uses Mesa semantics, so the predicate goes in a `while` loop, never an `if`.

*Deadlock — four necessary conditions:* mutual exclusion, hold and wait, no preemption,
circular wait. Necessary, *not* sufficient. Circular wait is the one you attack.

*RAG:* cycle $<=>$ deadlock only for single-instance resources.

*Banker's:* $"Need" = "Max" - "Alloc"$; $"Available" = "Total" - sum "Alloc"$;
then repeatedly find a process with $"Need" <= "Work"$ and add its Allocation to `Work`.
Three checks on a request: within Need? within Available? still safe after a pretend grant?

*The worked state to remember the shape of:* Total $(8,6,9)$, Available $(1,2,2)$,
safe sequence T3 $->$ T4 $->$ T1 $->$ T2. T2 asking for $(1,1,1)$ makes it unsafe — deny.
T3 asking for $(0,2,2)$ keeps it safe — grant.

*Three lookalikes.* Deadlock: blocked cycle. Livelock: busy, no progress. Starvation:
others progress, you do not.

*Priority inversion:* low holds the lock, high blocks on it, medium preempts low. Fix with
priority inheritance — or by not sharing mutable state across priority levels.
]

]
