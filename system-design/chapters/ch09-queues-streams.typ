#import "../../shared/lib/style.typ": *

#chapter(num: 9, title: "Queues, Streams & Async Processing",
  tagline: "Do the slow work later, and prove you did it exactly once")[

#section[The idea in one page]

A user taps *Place order*. Five things must happen:

#table(columns: 3,
  align: (left, right, left),
  [*Step*], [*Time*], [*Does the user care right now?*],
  [charge the card], [300 ms], [yes — they must know it worked],
  [write the order row], [20 ms], [yes — they need an order id],
  [send the confirmation e-mail], [800 ms], [no — 10 seconds later is fine],
  [update the analytics warehouse], [150 ms], [no],
  [warm the recommendation cache], [50 ms], [no],
)

Do all five inside the request and the user waits
$300 + 20 + 800 + 150 + 50 = 1320$ ms.

Do the first two inside the request, and *drop a note in a queue* for the other three.
Dropping a note costs about 2 ms each. The user now waits
$300 + 20 + 2 + 2 + 2 = 326$ ms.

$1320 slash 326 = 4.05$. The page got about *4 times faster* and nothing was deleted —
the slow work still runs, just not while a human stares at a spinner.

#formulas(title: "The five words you must be able to define")[
*Queue.* A line of messages. A consumer takes a message, works on it, and the message is
*deleted*. One message goes to exactly one worker. Example use: "send this e-mail".

*Topic (a stream / log).* An append-only list of messages kept on disk for a set time
(say 7 days). Nothing is deleted when it is read. Many different consumers can read the
same message for their own reasons. Example use: "an order was placed" — billing, search
and analytics all want to know.

*Offset.* A number that says "I have read up to here". Each consumer group keeps its own
offset. This is why a stream can be replayed: set the offset back and read again.

*Partition.* A topic is cut into $P$ independent logs. Order is guaranteed *inside* one
partition only, never across partitions. Messages with the same *partition key* always
land in the same partition.

*Consumer group.* A set of worker processes that share the partitions of a topic. Each
partition is owned by exactly one member of the group at a time. So:
*max useful workers in one group = number of partitions.* Memorise this line. It decides
your partition count.
]

#subsection[Queue or stream? Decide with this table]

#table(columns: 3,
  align: (left, left, left),
  [*Question*], [*Queue (SQS / RabbitMQ style)*], [*Stream (Kafka style)*],
  [after reading, the message is], [gone], [still there until retention ends],
  [same message to 3 teams?], [needs 3 copies / fan-out], [free — 3 consumer groups],
  [can I replay yesterday?], [no], [yes, rewind the offset],
  [ordering], [usually none, or a FIFO queue], [strict inside a partition],
  [throughput per unit], [thousands/s per queue], [tens of MB/s per partition],
  [operational weight], [light, usually managed], [heavy — brokers, replicas, rebalances],
  [best fit], [jobs, tasks, retries], [events, audit, analytics, change capture],
)

#trick[
*The one-line rule.* If the message is an *order to do something* to one worker
("resize this image"), use a queue. If the message is a *fact that already happened*
that several teams want ("user 42 placed order 99"), use a stream.
]

#subsection[Delivery semantics — the three phrases interviewers grade you on]

#table(columns: 4,
  align: (left, left, left, left),
  [*Name*], [*How it is built*], [*What goes wrong*], [*When to pick it*],
  [At most once], [ack the message *before* doing the work], [work is lost on a crash],
    [metrics, logs, anything you can lose],
  [At least once], [ack *after* the work succeeds], [work runs twice on a crash],
    [almost everything — the default],
  [Exactly once], [at-least-once *plus* a dedup or a transaction],
    [costs latency and state], [money movement, stock counts],
)

#trap[
"Exactly once delivery" over a network is impossible. The sender can never tell the
difference between "you did not get my message" and "you got it but your reply was lost",
so it must resend. What is possible is *exactly once effect*: deliver many times, but make
the *effect* happen once. You get that from an idempotent consumer, not from the broker.
Say it in those words in the interview.
]

#diagram(height: 5.8cm, caption: "Synchronous path vs. async path. The user only waits for the solid boxes.")[
  #dnode(0pt, 0.9cm, 2.0cm, 0.9cm, [User])
  #dnode(2.8cm, 0.9cm, 2.4cm, 0.9cm, [API server])
  #dnode(6.0cm, 0.1cm, 2.4cm, 0.8cm, [Payment 300 ms])
  #dnode(6.0cm, 1.1cm, 2.4cm, 0.8cm, [Orders DB 20 ms])
  #dnode(6.0cm, 2.1cm, 2.4cm, 0.8cm, [Queue 2 ms], fill: rgb("#e8f0e8"))
  #darrow(2.0cm, 1.35cm, 2.75cm, 1.35cm)
  #darrow(5.2cm, 1.2cm, 5.95cm, 0.5cm)
  #darrow(5.2cm, 1.35cm, 5.95cm, 1.5cm)
  #darrow(5.2cm, 1.5cm, 5.95cm, 2.5cm)
  #dnode(6.0cm, 3.4cm, 2.4cm, 0.8cm, [E-mail worker], fill: rgb("#f3f3ef"))
  #dnode(9.0cm, 3.4cm, 2.4cm, 0.8cm, [Analytics worker], fill: rgb("#f3f3ef"))
  #dnode(9.0cm, 2.1cm, 2.4cm, 0.8cm, [Cache worker], fill: rgb("#f3f3ef"))
  #darrow(7.2cm, 2.9cm, 7.2cm, 3.35cm)
  #darrow(8.4cm, 2.5cm, 8.95cm, 2.5cm)
  #darrow(8.4cm, 2.7cm, 9.6cm, 3.35cm)
  #dnode(0pt, 4.7cm, 11.4cm, 0.8cm,
    [User-visible latency = 300 + 20 + 3 x 2 = 326 ms. The grey work finishes within seconds.],
    fill: rgb("#f7f7f5"))
]

#subsection[The five failure words]

#table(columns: 2,
  align: (left, left),
  [*Word*], [*Plain meaning*],
  [Backpressure], [producers are faster than consumers; you must slow the producer or
    drop, not silently pile up forever],
  [Consumer lag], [how many messages sit between the newest offset and my offset],
  [Poison pill], [one bad message that crashes the consumer every time it is retried,
    blocking the whole partition],
  [DLQ (dead letter queue)], [a side queue where a message goes after $n$ failed tries,
    so the main line keeps moving],
  [Head-of-line blocking], [message 1 is stuck, so messages 2..1000 behind it wait,
    even though they are fine],
)

#note[
Every question in this chapter is written by the author as a *pattern* — the shape of
problem these companies ask. None of them is a transcript of a real interview. Every code
block was run with `node` before it was printed here, and the output shown is the real
output.
]

#section[Warm-up — the mechanics]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
A producer writes 5,000 messages per second. One consumer processes 3,000 per second.
The system runs for 10 minutes. How many messages are waiting at the end?
]
#sol[
Messages in: $5{,}000 times 600 = 3{,}000{,}000$.

Messages out: $3{,}000 times 600 = 1{,}800{,}000$.

Waiting = $3{,}000{,}000 - 1{,}800{,}000 = 1{,}200{,}000$.

Shortcut: the gap grows at $5{,}000 - 3{,}000 = 2{,}000$ per second, and
$2{,}000 times 600 = 1{,}200{,}000$.
]
#ans[1.2 million messages of lag]

#ex(2, tier: 0, asked: "warm-up")[
Same system. You add consumers until the group can handle 8,000 messages per second.
The producer stays at 5,000 per second. How long until the lag reaches zero?
]
#sol[
Drain rate = out $-$ in = $8{,}000 - 5{,}000 = 3{,}000$ per second.

Time = $1{,}200{,}000 slash 3{,}000 = 400$ seconds $= 6$ minutes 40 seconds.
]
#ans[400 s, about 6 min 40 s]

Here is the same thing as a program, so you can change the numbers and check yourself.

#code(lang: "js", caption: "lag-sim.js — build up the lag, then drain it")[
```js
function simulateLag({ produce, consume, seconds }) {
  let lag = 0;
  for (let t = 0; t < seconds; t++) {
    lag += produce(t) - consume(t);
    if (lag < 0) lag = 0;               // cannot consume what is not there
  }
  return lag;
}

const lag10min = simulateLag({ produce: () => 5000, consume: () => 3000, seconds: 600 });
console.log('lag after 10 min at 5000 in / 3000 out =', lag10min.toLocaleString());

let drain = 0, l = lag10min;
while (l > 0) { l += 5000 - 8000; drain++; }   // still 5000 arriving every second
console.log('seconds to drain once capacity is 8000/s =', drain);
console.log('check: 1,200,000 / (8000 - 5000) =', 1200000 / (8000 - 5000));
```
]

#code(lang: "text", caption: "Real output of node lag-sim.js")[
```text
lag after 10 min at 5000 in / 3000 out = 1,200,000
seconds to drain once capacity is 8000/s = 400
check: 1,200,000 / (8000 - 5000) = 400
```
]

#trap[
Students write "8,000 per second, so $1{,}200{,}000 slash 8{,}000 = 150$ s". Wrong — new
messages keep arriving during the drain. Always subtract the incoming rate first. The
`l += 5000 - 8000` line in the program is exactly that subtraction.
]

#ex(3, tier: 0, asked: "warm-up")[
A topic has 12 partitions. A consumer group has 20 processes. How many are actually
working? What if the group has 5 processes?
]
#sol[
A partition is owned by exactly one member of a group.

*20 processes:* 12 get one partition each. The other 8 are *idle* — they hold no
partition and read nothing. You paid for 8 machines that do nothing.

*5 processes:* 12 partitions shared by 5. Split is $12 = 3+3+2+2+2$. Every process works,
but the two holding 3 partitions carry 50% more load than those holding 2.
]
#ans[With 20: only 12 work, 8 idle. With 5: all 5 work, unevenly (3,3,2,2,2).]

#trick[
Pick a partition count that is *divisible by* the consumer counts you expect to run:
12 splits evenly among 1, 2, 3, 4, 6, 12 workers. 64 and 128 are popular for the same
reason. Choosing a prime like 13 is a small, silly, permanent tax.
]

#ex(4, tier: 0, asked: "warm-up")[
Retry with exponential backoff: first retry after 1 s, then double each time, 6 retries
total. What is the total wait before the message gives up?
]
#sol[
Waits: 1, 2, 4, 8, 16, 32 seconds.

Sum $= 1+2+4+8+16+32 = 63$ seconds.

General form: with base $b$ and $n$ retries, total $= b(2^n - 1)$. Check:
$1 times (2^6 - 1) = 63$. Matches.
]
#ans[63 seconds]

#ex(5, tier: 0, asked: "warm-up")[
Why do we add *jitter* (a random amount) to the backoff?
]
#sol[
Suppose a database goes down and 10,000 in-flight messages all fail at time $t$.

Without jitter, all 10,000 retry at $t+1$, then all at $t+3$, then all at $t+7$. The
database gets hit by 10,000 requests in the same millisecond, falls over again, and the
cycle repeats forever. This is a *thundering herd*.

With jitter, each retry happens at a random point in $[0, 2^k]$ seconds. The same 10,000
retries now spread over a window, and the database sees a smooth load it can survive.

Full jitter in one line:

```js
const sleepMs = Math.floor(Math.random() * base * 2 ** k);
```
]
#ans[To spread the retries out so the recovering service is not killed again]

#ex(6, tier: 0, asked: "warm-up")[
A consumer stores a dedup key for every message it has processed, so it can skip repeats.
Rate is 5,000 messages per second. Each key costs 100 bytes in Redis (the key string plus
overhead). How much memory does a 24-hour dedup window need? Is that sensible?
]
#sol[
Keys per day $= 5{,}000 times 86{,}400 = 432{,}000{,}000$.

Memory $= 432{,}000{,}000 times 100 "B" = 43{,}200{,}000{,}000 "B" = 43.2$ GB.

That is a big, expensive Redis cluster whose only job is remembering the past.

Now try a *1-hour* window: $5{,}000 times 3{,}600 = 18{,}000{,}000$ keys;
$18{,}000{,}000 times 100 = 1{,}800{,}000{,}000 "B" = 1.8$ GB. That fits on one node.

*Decision:* 1-hour window, and make the *database write itself* idempotent (a unique
constraint) as the real safety net. The cache is an optimisation, not the guarantee.
]
#ans[43.2 GB for 24 h — too much. Use a 1-hour window (1.8 GB) plus a unique key in the DB.]

#subsection[Warm-up drill: name the semantic]

#table(columns: 3,
  align: (left, left, left),
  [*What the consumer does*], [*Semantic*], [*Why*],
  [`ack()` then `work()`], [at most once], [crash after ack loses the work],
  [`work()` then `ack()`], [at least once], [crash before ack replays the work],
  [`work()` then `ack()`, where work is an insert with a unique key],
    [exactly once *effect*], [the replay inserts nothing the second time],
  [`work()` then `ack()`, where work is `balance += 10`],
    [at least once, and *wrong*], [the replay adds 10 again],
  [`work()` then `ack()`, where work is `balance = 250`],
    [at least once, and *safe*], [setting the same value twice is harmless],
)

#trick[
*Idempotent means: doing it twice gives the same result as doing it once.*
`x = 5` is idempotent. `x += 5` is not. When you can, turn increments into
"write the computed absolute value" or "insert a row with a unique key".
]

#section[Tier 1 — LLD: build the job queue yourself]
#tier-header(1)

The Tier-1 interviewer does not want Kafka. They want classes. The question sounds like:
"Design a background job system. I should be able to submit a job, retry it if it fails,
and move it to a dead letter queue after 3 failures."

#subsection[Step 1 — the objects on the table]

Read the sentence and underline the nouns. Each noun that has *state* becomes a class.

#table(columns: 3,
  align: (left, left, left),
  [*Noun*], [*Class*], [*What it owns*],
  [job], [`Job`], [id, payload, attempt count, state, run-after time],
  [queue], [`InMemoryJobQueue`], [push, poll, ack, nack],
  [retry rule], [`ExponentialBackoff` / `NoRetry`], [should we retry? how long to wait?],
  [worker], [`Worker`], [a loop: poll, run, ack or nack],
  [handler], [a function per job type], [the actual business code],
  [dead letters], [`DeadLetterStore`], [jobs that gave up],
)

#trap[
The number one Tier-1 mistake: putting the retry maths *inside* `Worker` as an `if`
ladder. Then every new rule (fixed delay, exponential, retry only on network errors)
edits `Worker`. That breaks the Open--Closed Principle. Make the retry policy a separate
object with a fixed shape and pass it in — the Strategy pattern. This single move is worth
several marks.
]

#subsection[Step 2 — the code, in JavaScript]

#note[
JavaScript has no `interface` keyword. The interviewer still wants to hear the word. Say:
"In Java this would be an `interface RetryPolicy`. In JS I express the same contract as a
duck-typed object with `shouldRetry(job, cause)` and `delayMs(attempt)`, and any object
with those two methods can be passed in." That answer scores in both rounds.
]

#code(lang: "js", caption: "job.js — the message and its state")[
```js
const JobState = Object.freeze({
  READY: 'READY', RUNNING: 'RUNNING', DONE: 'DONE', DEAD: 'DEAD',
});

class Job {
  constructor(id, type, payload, priority = 1) {
    this.id = id;                  // unique: this is what dedup keys on
    this.type = type;              // 'send_email', 'resize_image'
    this.payload = payload;
    this.priority = priority;      // 0 high, 1 normal, 2 low
    this.attempts = 0;             // how many times we have tried
    this.runAfter = Date.now();    // do not run before this clock time
    this.state = JobState.READY;
  }

  recordFailure(delayMs) {
    this.attempts += 1;
    this.state = JobState.READY;
    this.runAfter = Date.now() + delayMs;
  }
}
```
]

#code(lang: "js", caption: "retry.js — Strategy pattern, so a new rule is a new class")[
```js
class PermanentError extends Error {}          // bad input: retrying cannot help

class ExponentialBackoff {
  constructor(baseMs, maxAttempts, rng = Math.random) {
    this.baseMs = baseMs;
    this.maxAttempts = maxAttempts;
    this.rng = rng;                            // injected so tests are deterministic
  }

  shouldRetry(job, cause) {
    if (cause instanceof PermanentError) return false;
    return job.attempts < this.maxAttempts;
  }

  delayMs(attemptNumber) {                     // attemptNumber starts at 1
    const ceiling = this.baseMs * 2 ** (attemptNumber - 1);   // base * 2^(k-1)
    return Math.floor(this.rng() * ceiling);                  // full jitter
  }
}

class NoRetry {
  shouldRetry() { return false; }
  delayMs() { return 0; }
}
```
]

#note[
`2 ** (attemptNumber - 1)` is $2^(k-1)$. For $k = 1,2,3,4$ it gives $1,2,4,8$. In JS you
can safely go to $2^53$ with a normal number, so unlike Java there is no `1L` to remember.
Past $2^53$ you would need `BigInt` — but a backoff that long is a bug anyway.
]

#code(lang: "js", caption: "queue.js — the heap comes from the shared toolkit")[
```js
const { MinHeap } = require('../shared/js/toolkit');   // JS has no built-in heap

class InMemoryJobQueue {
  constructor(policy, dlq) {
    // ordered by runAfter ascending, so delayed jobs sort to the back
    this.ready = new MinHeap((x, y) => x.runAfter - y.runAfter);
    this.policy = policy;
    this.dlq = dlq;
    this.seen = new Set();
  }

  push(job) {
    if (this.seen.has(job.id)) return false;   // dedup on the producer side
    this.seen.add(job.id);
    this.ready.push(job);
    return true;
  }

  poll(now = Date.now()) {
    const head = this.ready.peek();
    if (!head) return null;
    if (head.runAfter > now) return null;      // the earliest job is not due yet
    const job = this.ready.pop();
    job.state = JobState.RUNNING;
    return job;
  }

  ack(job) { job.state = JobState.DONE; }

  nack(job, cause) {
    if (!this.policy.shouldRetry(job, cause)) {
      job.state = JobState.DEAD;
      this.dlq.store(job, cause);
      return;
    }
    const delay = this.policy.delayMs(job.attempts + 1);
    job.recordFailure(delay);
    this.ready.push(job);
  }

  msUntilNextDue(now = Date.now()) {
    const head = this.ready.peek();
    if (!head) return Infinity;
    return Math.max(0, head.runAfter - now);
  }
}

class DeadLetterStore {
  constructor() { this.dead = []; }
  store(job, cause) { this.dead.push({ job, reason: String(cause && cause.message) }); }
  get size() { return this.dead.length; }
}
```
]

#trap[
*JS trap 1 — `sort()` is lexicographic.* If you had used a plain array and written
`this.ready.sort()`, then run-after times `[10, 9, 1]` sort to `[1, 10, 9]`, because
`sort()` compares them as *text*. Numbers always need a comparator: `(a, b) => a - b`.

*JS trap 2 — there is no built-in priority queue.* Java has `PriorityQueue`, C++ has
`priority_queue`, JS has nothing. Use the `MinHeap` from the shared toolkit. Re-sorting an
array on every `push` is $O(n log n)$ per insert instead of $O(log n)$ — 100 times slower
at $n = 10^5$.
]

#code(lang: "js", caption: "worker.js — the loop. Look hard at the last five lines.")[
```js
class Worker {
  constructor(queue, handlers) {
    this.queue = queue;
    this.handlers = handlers;     // Map<string, async (job) => void>
    this.running = true;
  }

  stop() { this.running = false; }

  async run() {
    while (this.running) {
      const job = this.queue.poll();
      if (!job) {
        const wait = Math.min(50, this.queue.msUntilNextDue());
        await new Promise(r => setTimeout(r, wait));
        continue;
      }
      const handler = this.handlers.get(job.type);
      if (!handler) {
        this.queue.nack(job, new PermanentError(`no handler: ${job.type}`));
        continue;
      }
      try {
        await handler(job);       // do the work FIRST
        this.queue.ack(job);      // then ack  ->  at least once
      } catch (err) {
        this.queue.nack(job, err);
      }
    }
  }
}
```
]

#code(lang: "js", caption: "The test that proves all four paths work")[
```js
const dlq = new DeadLetterStore();
const policy = new ExponentialBackoff(10, 3, () => 0.999);  // fixed rng, tiny delays
const q = new InMemoryJobQueue(policy, dlq);

const delivered = [];
let failCount = 0;
const handlers = new Map([
  ['send_email', async (job) => { delivered.push(job.id); }],
  ['flaky',      async ()    => { failCount++; throw new Error('smtp timeout'); }],
  ['bad_input',  async ()    => { throw new PermanentError('email missing @'); }],
]);

q.push(new Job('j1', 'send_email', '{}'));
q.push(new Job('j1', 'send_email', '{}'));   // duplicate id -> ignored
q.push(new Job('j2', 'flaky', '{}'));
q.push(new Job('j3', 'bad_input', '{}'));
q.push(new Job('j4', 'unknown_type', '{}'));

const w = new Worker(q, handlers);
const loop = w.run();
await new Promise(r => setTimeout(r, 400));
w.stop(); await loop;

console.log('delivered      =', delivered);
console.log('flaky attempts =', failCount);
console.log('dlq size       =', dlq.size);
console.log('dlq reasons    =', dlq.dead.map(d => `${d.job.id}:${d.reason}`));
```
]

#code(lang: "text", caption: "Real output")[
```text
delivered      = [ 'j1' ]
flaky attempts = 4
dlq size       = 3
dlq reasons    = [
  'j4:no handler: unknown_type',
  'j3:email missing @',
  'j2:smtp timeout'
]
```
]

Read the output line by line. `delivered` has *one* `j1`, not two — the `seen` set
rejected the duplicate push. `flaky attempts = 4` is one first try plus three retries,
which is exactly `maxAttempts = 3`. `bad_input` went straight to the DLQ after *one* try,
because `PermanentError` short-circuits `shouldRetry`. The unknown type also went to the
DLQ instead of crashing the worker.

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
Point at the exact two lines in `Worker.run()` that decide the delivery semantic. What
would you change to make it *at most once*, and why would that be a bad idea for e-mail?
]
#sol[
The two lines are:

```js
await handler(job);    // work
this.queue.ack(job);   // ack
```

Work happens first, ack second. If the process dies between them, the job is still in the
queue and will run again. That is *at least once*.

To get *at most once*, swap them:

```js
this.queue.ack(job);
await handler(job);
```

Now a crash after `ack` loses the job forever.

For e-mail, losing an order confirmation is worse than sending it twice. A customer who
gets two identical e-mails is mildly annoyed. A customer who gets none opens a support
ticket and may believe the order failed.

*Decision:* keep at-least-once (work then ack), and make the handler idempotent by
recording `sent_email(job_id)` in a table with a unique key before sending.
]

#ex(8, tier: 1, asked: "Infosys · pattern")[
In Java this queue would need `synchronized` on `poll()`. Node is single-threaded — so is
the JS version automatically safe? Prove your answer with code.
]
#sol[
*Half safe, and the half that is not safe is the dangerous half.*

A JS function that contains *no* `await` runs start to finish without interruption. Our
`poll()` has no `await`, so two callers can never interleave inside it. No lock needed.

But the moment you add an `await` in the middle of a look-then-take sequence, another task
runs in the gap. Here is the bug, made to happen on purpose:

#code(lang: "js", caption: "The await in the middle is the whole bug")[
```js
class BrokenQueue {
  constructor(items) { this.items = items; }
  async pollAndLog() {
    const head = this.items[0];                 // 1. LOOK
    if (!head) return null;
    await new Promise(r => setTimeout(r, 0));   // 2. YIELD — another task runs here
    return this.items.shift();                  // 3. TAKE — may not be `head` any more
  }
}

const q = new BrokenQueue(['A', 'B']);
const [x, y] = await Promise.all([q.pollAndLog(), q.pollAndLog()]);
console.log('two concurrent polls got:', x, y, '| remaining =', q.items);

const q2 = new BrokenQueue(['A']);
const [p, r] = await Promise.all([q2.pollAndLog(), q2.pollAndLog()]);
console.log('one item, two pollers  :', p, r, '| remaining =', q2.items);
```
]

#code(lang: "text", caption: "Real output")[
```text
two concurrent polls got: A B | remaining = []
one item, two pollers  : A undefined | remaining = []
```
]

Look at the second line. There was *one* item. Both pollers saw `head = 'A'` at step 1.
Both then called `shift()`. One got `'A'`, the other got `undefined`. In a real queue that
`undefined` becomes a `TypeError` inside the worker, and the worker dies.

*The rule to say out loud:* "In Node the unit of atomicity is the stretch of code between
two `await`s. Keep check-then-act in one such stretch, or protect it with an explicit
async mutex."
]
#ans[Safe only because `poll()` has no `await`. Add one `await` between the check and the take and you get the same race Java needs `synchronized` for.]

#ex(9, tier: 1, asked: "Accenture · pattern")[
The `seen` set in `InMemoryJobQueue` grows forever. In a 30-day run at 200 jobs per
second, how many ids does it hold, and roughly how much heap is that if a string id plus
`Set` overhead is 120 bytes? Fix the design.
]
#sol[
Ids $= 200 times 86{,}400 times 30$.

Step 1: $200 times 86{,}400 = 17{,}280{,}000$ per day.

Step 2: $17{,}280{,}000 times 30 = 518{,}400{,}000$ ids.

Heap $= 518{,}400{,}000 times 120 "B" = 62{,}208{,}000{,}000 "B" approx 62.2$ GB.

Node's default old-space heap is about 4 GB. The process dies long before 62 GB. This is
an *unbounded memory leak*, and interviewers look for it.

*Fix — three options, then a decision.*

+ *Bounded LRU set* holding the last $N$ ids, say $N = 2$ million ($approx 240$ MB).
  Duplicates older than the window slip through.
+ *Time-windowed set*: drop ids older than 1 hour. That is
  $200 times 3{,}600 = 720{,}000$ ids $approx 86$ MB.
+ *Push the dedup to the store that matters*: a `UNIQUE` index on `job_id` in the jobs
  table. Costs one index lookup per insert, never leaks, and survives a restart.

*Decision: option 3 as the correctness guarantee, option 2 as a cheap front filter* so we
do not hit the database for obvious repeats. Worker memory is now capped at about 86 MB
and correctness no longer depends on worker memory at all.

#code(lang: "js", caption: "The 1-hour windowed set, ~86 MB instead of 62 GB")[
```js
class WindowedSet {
  constructor(windowMs) { this.windowMs = windowMs; this.m = new Map(); }
  has(id) { this.#evict(); return this.m.has(id); }
  add(id) { this.#evict(); this.m.set(id, Date.now()); }
  #evict() {
    const cutoff = Date.now() - this.windowMs;
    // Map keeps INSERTION order, so the oldest entries are at the front.
    for (const [id, t] of this.m) { if (t >= cutoff) break; this.m.delete(id); }
  }
  get size() { return this.m.size; }
}
```
]

That eviction loop is only correct because `Map` iterates in insertion order and every
`add` uses the current time, so times are non-decreasing. A plain object gives no such
guarantee — this is *JS trap 6*, `Map` versus object, and here it is load-bearing.
]
#ans[518.4 million ids, about 62 GB. Cap it with a 1-hour window and rely on a UNIQUE index in the database.]

#ex(10, tier: 1, asked: "Capgemini · pattern")[
Add *priority* to this design. High-priority jobs (password-reset e-mails) must be picked
before low-priority ones (weekly digest), but a flood of high-priority jobs must not
starve low ones for more than about 60 seconds. Write the comparator and prove it works.
]
#sol[
*Naive idea:* sort by `(priority, runAfter)`. This starves low-priority jobs completely.
If high-priority jobs never stop arriving, a low job never reaches the head. Forever.

*Fix: ageing.* Give every job an *effective time* that slides earlier the longer it waits.

#code(lang: "js", caption: "Comparator with ageing — bounded starvation")[
```js
const BOOST_MS = [60_000, 20_000, 0];    // index = priority: 0 high, 1 normal, 2 low

const effectiveTime = (j) => j.runAfter - BOOST_MS[j.priority];
const byUrgency = (a, b) => effectiveTime(a) - effectiveTime(b);

const now = 1_000_000;
const jobs = [
  { id: 'low-waited-61s',   priority: 2, runAfter: now - 61_000 },
  { id: 'high-just-now',    priority: 0, runAfter: now },
  { id: 'normal-waited-5s', priority: 1, runAfter: now - 5_000 },
  { id: 'low-just-now',     priority: 2, runAfter: now },
];
console.log('order =', [...jobs].sort(byUrgency).map(j => j.id));
console.log('effective times =',
  jobs.map(j => `${j.id}:${effectiveTime(j) - now}`).join('  '));
```
]

#code(lang: "text", caption: "Real output")[
```text
order = [ 'low-waited-61s', 'high-just-now', 'normal-waited-5s', 'low-just-now' ]
effective times = low-waited-61s:-61000  high-just-now:-60000
                  normal-waited-5s:-25000  low-just-now:0
```
]

*Read the proof in the numbers.* A brand-new high job has effective time $-60{,}000$.
A low job that has waited 61 s has effective time $-61{,}000$, which is *smaller*, so it
sorts first and finally runs. A low job that just arrived is at $0$ and waits, correctly.

Worst-case extra wait for a low job is therefore about 60 seconds — exactly what was
asked for.

*Trade-off named and decided.* Strict priority gives the lowest possible latency for
urgent jobs but allows infinite starvation. Ageing adds at most 60 s of delay to an urgent
job in the worst case, but bounds the low-priority wait. *We pick ageing*, because a
weekly digest that never sends is a bug, while a password e-mail arriving in 60 s instead
of 0 s is still acceptable.
]

#subsection[The LLD scorecard]

#table(columns: 2,
  align: (left, left),
  [*Principle*], [*Where it shows up above*],
  [Single Responsibility], [the retry policy decides waiting; `Worker` only loops;
    `DeadLetterStore` only stores],
  [Open--Closed], [a new retry rule is a new class, not an edit to `Worker`],
  [Liskov], [any object with `push/poll/ack/nack` can replace `InMemoryJobQueue` —
    `Worker` never inspects its type],
  [Interface Segregation], [a handler is one function; handlers are not forced to
    implement `retry()` or `serialize()`],
  [Dependency Inversion], [`Worker` receives the queue and the handler map in its
    constructor, so tests inject fakes — that is why the test above runs with no broker],
  [Strategy pattern], [`ExponentialBackoff` vs `NoRetry`, swapped at construction],
  [Registry over `switch`], [`Map<string, handler>` instead of `switch (job.type)`],
)

#practice(tier: 1, time: "25 min")[
+ Add a `visibilityTimeout` to `InMemoryJobQueue`: if a worker polls a job and does not
  ack within 30 seconds, the job becomes pollable again. Which field and which methods
  change?
+ Rewrite `poll()` so that it *does* contain an `await` (say, a database read). Show the
  race that appears, and write the four-line async mutex that fixes it.
+ Write a retry policy that retries only on a network error, at most 5 times, with a fixed
  2-second delay.
+ `DeadLetterStore` currently just stores. Add `replay(jobId, queue)`. What must you reset
  on the `Job` before pushing it back?
]

#key[
+ Add `leaseUntil` to `Job`. `poll()` sets `job.leaseUntil = now + 30_000` and keeps the
  job in a separate `inFlight` map; a sweeper moves anything whose `leaseUntil` has passed
  back into `ready`. `ack()` deletes it from `inFlight`.
+ The race is the one in Example 8: two pollers read the same head across the `await`.
  Fix: `this.lock = this.lock.then(() => this.#pollInner());  return this.lock;` — a
  promise chain is a one-slot mutex, because each call waits for the previous chain link.
+ `shouldRetry(job, cause)` returns `cause.code === 'ECONNRESET' || cause.code === 'ETIMEDOUT'`
  combined with `job.attempts < 5`; `delayMs()` returns `2000` always.
+ Reset `attempts` to 0, set `state` back to `READY`, and set `runAfter` to `Date.now()`.
  Otherwise the policy immediately declares it dead again and it bounces straight back
  into the DLQ.
]

#section[Tier 2 — mid-scale: a notification service]
#tier-header(2)

*The question.* "Our shopping app needs to send order updates to users by e-mail and push
notification. Design it."

We now walk the seven steps. Do not skip one, even when you are short of time — say the
step name out loud and give it one sentence.

#subsection[Step 1 — Clarify]

#table(columns: 3,
  align: (left, left, left),
  [*Ask this*], [*Suppose the answer is*], [*What it changes*],
  [How many users, how many notes each per day?], [40 M DAU, 3 per user per day],
    [fixes every number below],
  [Which channels?], [e-mail and push now; SMS later], [forces a channel *interface*],
  [How fast must a note arrive?], [under 60 s for order updates],
    [rules out a batch job; keeps a queue],
  [Is duplicate delivery acceptable?], [no — users complain], [forces an idempotency key],
  [Do users have quiet hours or preferences?], [yes, per channel],
    [adds a preference lookup on the path],
  [Can we drop marketing notes under load?], [yes], [gives us a priority lane],
  [Must we show delivery status?], [yes, 30-day history],
    [adds a status store, adds storage],
)

#trick[
In Tier 2 the marks are in the *why*, not the *what*. "How many users" is worth nothing.
"How many users, because that decides whether this is one queue or thirty-two partitions"
is worth the mark.
]

#subsection[Step 2 — Scale estimate (show every division)]

*Traffic.*

$40{,}000{,}000 "DAU" times 3 "notes" = 120{,}000{,}000$ notes per day.

Average rate $= 120{,}000{,}000 slash 86{,}400 = 1{,}388.9 approx 1{,}390$ notes/s.

Peak is spiky — most orders happen in the evening. Take $4 times$ average:
$1{,}390 times 4 = 5{,}560$ notes/s at peak.

*Storage of delivery status.* One status row is about 250 bytes (id, user, channel,
template, state, timestamps).

Per day: $120{,}000{,}000 times 250 "B" = 30{,}000{,}000{,}000 "B" = 30$ GB/day.

30-day history: $30 times 30 = 900$ GB. One well-sized database. No sharding needed yet.

*Queue depth if all workers die for 10 minutes.*

Messages piled up $= 1{,}390 times 600 = 834{,}000$.

At 400 bytes per message:
$834{,}000 times 400 "B" = 333{,}600{,}000 "B" approx 334$ MB. A managed queue holds that
without noticing. Good — a 10-minute outage is survivable.

*How many worker processes?*

An SMTP call to the e-mail provider takes about 200 ms. One *concurrent slot* therefore
does $1 slash 0.2 = 5$ sends per second.

Slots needed at peak $= 5{,}560 slash 5 = 1{,}112$ concurrent sends.

A Node process handles network-waiting work with `Promise` concurrency, not threads. At
200 in-flight sends per process (they are almost all just waiting on a socket, so the CPU
is nearly idle):

$1{,}112 slash 200 = 5.56 arrow 6$ processes.

Add one for headroom and one so a rolling deploy never drops below 6: *8 processes*.

#formulas(title: "The estimate in one block — copy this shape")[
- 40 M DAU x 3 = 120 M notes/day
- 120 M / 86,400 = 1,390/s average
- x4 peak = 5,560/s
- 250 B status row x 120 M = 30 GB/day, x30 days = 900 GB
- 10-min outage backlog = 1,390 x 600 = 834 K msgs = 334 MB
- 200 ms per send -> 5 sends/s per slot -> 5,560 / 5 = 1,112 slots
- 1,112 / 200 slots per process = 5.56 -> 6, round to 8 for headroom
]

#ex(11, tier: 2, asked: "Shopee · pattern")[
Marketing wants a campaign: one push to all 40 M users, to go out "as fast as possible".
Your peak capacity is 5,560 sends/s. How long does the campaign take, and what breaks?
]
#sol[
Time $= 40{,}000{,}000 slash 5{,}560 = 7{,}194$ seconds.

$7{,}194 slash 60 = 119.9$ minutes $approx 2$ hours.

*What breaks:* for those 2 hours the workers are 100% busy on marketing. Order-update
notes, which promised under 60 s, queue behind the campaign — classic head-of-line
blocking. A user who cancels an order gets the confirmation an hour later.

*Fix, with both sides named.*

- *Option A — one queue with a priority field.* Cheap, but a single slow marketing batch
  still holds the connection pool; a priority field inside one queue does not stop
  resource starvation.
- *Option B — two separate queues and two separate worker pools*, split
  transactional : marketing $= 70 : 30$. Transactional latency is protected by hard
  isolation. Costs a second pool, and 30% of capacity sits idle when no campaign runs.

*Decision: Option B.* The 60-second promise is a product guarantee; idle capacity is only
money. With $30%$ of 5,560 $= 1{,}668$ sends/s for marketing, the campaign takes
$40{,}000{,}000 slash 1{,}668 = 23{,}981$ s $approx 6.7$ hours — and we tell marketing to
schedule it overnight, which is what they wanted anyway.
]
#ans[About 2 hours on a shared pool, and it starves order updates. Split the pools 70/30; the campaign then takes ~6.7 h overnight.]

#subsection[Step 3 — API surface]

#code(lang: "http", caption: "Public API — note the idempotency header")[
```http
POST /v1/notifications
Idempotency-Key: ord-99213-shipped-v1
Content-Type: application/json

{
  "user_id": "u_4412",
  "template": "order_shipped",
  "channels": ["push", "email"],
  "priority": "transactional",
  "params": { "order_id": "99213", "eta": "2026-03-04" }
}

202 Accepted
{ "notification_id": "n_8f31c2", "state": "queued" }
```
]

#code(lang: "http", caption: "Read the status, and manage preferences")[
```http
GET /v1/notifications/n_8f31c2
200 OK
{
  "notification_id": "n_8f31c2",
  "user_id": "u_4412",
  "attempts": [
    { "channel": "push",  "state": "delivered", "at": "2026-03-03T10:02:11Z" },
    { "channel": "email", "state": "bounced",   "at": "2026-03-03T10:02:14Z",
      "reason": "mailbox_full" }
  ]
}

PUT /v1/users/u_4412/preferences
{ "email": { "marketing": false, "transactional": true },
  "push":  { "quiet_hours": ["22:00", "07:00"], "timezone": "Asia/Kolkata" } }
```
]

#note[
`202 Accepted`, not `200 OK`. We have accepted the job, not delivered the message. Using
`200` here is a small lie that confuses every caller later. Interviewers notice.
]

#subsection[Step 4 — Data model]

#code(lang: "sql", caption: "notifications — the status store")[
```sql
CREATE TABLE notifications (
  id               CHAR(16)     PRIMARY KEY,
  idempotency_key  VARCHAR(128) NOT NULL,
  user_id          VARCHAR(32)  NOT NULL,
  template         VARCHAR(64)  NOT NULL,
  priority         TINYINT      NOT NULL,     -- 0 transactional, 1 marketing
  params_json      JSON         NOT NULL,
  created_at       DATETIME(3)  NOT NULL,
  UNIQUE KEY uk_idem (idempotency_key),       -- this line IS the dedup guarantee
  KEY idx_user_time (user_id, created_at)
);

CREATE TABLE delivery_attempts (
  id               BIGINT       AUTO_INCREMENT PRIMARY KEY,
  notification_id  CHAR(16)     NOT NULL,
  channel          VARCHAR(16)  NOT NULL,     -- 'email' | 'push' | 'sms'
  attempt_no       SMALLINT     NOT NULL,
  state            VARCHAR(16)  NOT NULL,     -- queued|sent|delivered|bounced|dead
  provider_id      VARCHAR(64),               -- id returned by the e-mail provider
  reason           VARCHAR(128),
  updated_at       DATETIME(3)  NOT NULL,
  UNIQUE KEY uk_attempt (notification_id, channel, attempt_no),
  KEY idx_state_time (state, updated_at)
);
```
]

*Why each key was chosen.*

#table(columns: 2,
  align: (left, left),
  [*Choice*], [*Reason*],
  [`UNIQUE (idempotency_key)`], [a retried `POST` hits the unique index and we return the
    existing id — dedup that survives a restart, unlike a Redis set],
  [attempts in their own table], [one notification can have 2 channels x 4 tries = 8 rows;
    keeping them in one row would need arrays and a rewrite of the row on every try],
  [`(state, updated_at)` index], [the sweeper query "find everything stuck in `sent` for
    over 10 minutes" must not scan the table],
  [`(user_id, created_at)` index], [the notification-history screen],
  [monthly partition on `created_at`], [dropping a partition is instant; a
    `DELETE WHERE created_at < ...` over 30 GB/day is a nightmare],
)

#subsection[Step 5 — Architecture]

#diagram(height: 7.8cm, caption: "Notification service. The API never talks to a provider directly.")[
  #dnode(0pt, 0.2cm, 2.2cm, 0.9cm, [Order service])
  #dnode(0pt, 1.5cm, 2.2cm, 0.9cm, [Other services])
  #dnode(2.9cm, 0.8cm, 2.3cm, 1.0cm, [Notification\ API], fill: rgb("#e8f0e8"))
  #darrow(2.2cm, 0.65cm, 2.85cm, 1.1cm)
  #darrow(2.2cm, 1.95cm, 2.85cm, 1.6cm)
  #dnode(2.9cm, 2.6cm, 2.3cm, 0.8cm, [Postgres\ status store])
  #darrow(4.05cm, 1.85cm, 4.05cm, 2.55cm, label: "insert")
  #dnode(6.0cm, 0.1cm, 2.4cm, 0.8cm, [Queue: txn], fill: rgb("#f0ece4"))
  #dnode(6.0cm, 1.6cm, 2.4cm, 0.8cm, [Queue: marketing], fill: rgb("#f0ece4"))
  #darrow(5.25cm, 1.1cm, 5.95cm, 0.5cm)
  #darrow(5.25cm, 1.5cm, 5.95cm, 2.0cm)
  #dnode(9.2cm, 0.1cm, 2.2cm, 0.8cm, [Worker pool A\ (70%)])
  #dnode(9.2cm, 1.6cm, 2.2cm, 0.8cm, [Worker pool B\ (30%)])
  #darrow(8.45cm, 0.5cm, 9.15cm, 0.5cm)
  #darrow(8.45cm, 2.0cm, 9.15cm, 2.0cm)
  #dnode(9.2cm, 3.0cm, 2.2cm, 0.8cm, [Preference\ service], fill: rgb("#f7f7f5"))
  #darrow(10.3cm, 0.95cm, 10.3cm, 2.95cm, label: "check", dashed: true)
  #dnode(6.0cm, 4.5cm, 2.4cm, 0.9cm, [E-mail provider], fill: rgb("#f7f7f5"))
  #dnode(9.2cm, 4.5cm, 2.2cm, 0.9cm, [Push gateway], fill: rgb("#f7f7f5"))
  #darrow(9.8cm, 2.45cm, 7.6cm, 4.45cm)
  #darrow(10.3cm, 3.85cm, 10.3cm, 4.45cm)
  #dnode(2.9cm, 4.5cm, 2.4cm, 0.9cm, [DLQ + alarm], fill: rgb("#f7ecec"))
  #darrow(9.15cm, 0.9cm, 5.35cm, 4.55cm, label: "3 fails")
  #dnode(0pt, 6.4cm, 11.4cm, 0.9cm,
    [Two queues, two pools: a marketing flood can never delay an order update,
     because they do not share a single connection pool.],
    fill: rgb("#f7f7f5"))
]

#subsection[Step 6 — Deep dive: making duplicates impossible]

The hard part is *not* the queue. It is this: the order service is also at-least-once, so
it may call `POST /v1/notifications` twice for the same event. Then our own queue is
at-least-once, so the worker may run twice. Two independent sources of doubles.

*The dedup ladder — four gates, cheapest first.*

#table(columns: 4,
  align: (left, left, left, left),
  [*Gate*], [*Where*], [*Catches*], [*Cost*],
  [1. Redis `SET NX` on the idempotency key, 1-hour TTL], [API], [the fast retry storm],
    [0.3 ms, and it may miss],
  [2. `UNIQUE (idempotency_key)`], [Postgres], [every duplicate `POST`, forever],
    [one index write],
  [3. `UNIQUE (notification_id, channel, attempt_no)`], [Postgres],
    [a worker replaying the same attempt], [one index write],
  [4. Provider-side key], [e-mail provider], [our retry after their timeout],
    [free, if the provider supports it],
)

Gates 2 and 3 are the *guarantees*. Gate 1 is only a cost saver. Never present a cache as
a correctness guarantee — that is the trap.

#code(lang: "js", caption: "create-notification.js — dedup done right")[
```js
class DuplicateKeyError extends Error {}

async function createNotification(req, idemKey) {
  // Gate 1: cheap filter. A miss is fine; a hit saves a database round trip.
  const cached = await redis.get(`idem:${idemKey}`);
  if (cached) return { status: 202, notification_id: cached, deduped: 'cache' };

  const id = nextId();
  try {
    await db.insertNotification(id, idemKey, req);   // Gate 2: UNIQUE (idempotency_key)
  } catch (err) {
    if (!(err instanceof DuplicateKeyError)) throw err;
    const existing = await db.findIdByIdemKey(idemKey);   // someone beat us to it
    await redis.setex(`idem:${idemKey}`, 3600, existing);
    return { status: 202, notification_id: existing, deduped: 'db' };  // SAME id
  }
  await redis.setex(`idem:${idemKey}`, 3600, id);
  await queue.publish(req.priority, { id, ...req });
  return { status: 202, notification_id: id, deduped: null };
}
```
]

#code(lang: "js", caption: "The test: same key four times, and three callers racing")[
```js
const req = { user_id: 'u_4412', template: 'order_shipped', priority: 'transactional' };
console.log(await createNotification(req, 'ord-99213-shipped-v1'));   // fresh
redis.m.clear();                                                      // cache wiped
console.log(await createNotification(req, 'ord-99213-shipped-v1'));   // caught by the DB
console.log(await createNotification(req, 'ord-99213-shipped-v1'));   // caught by cache
console.log('messages actually published =', queue.published.length);

redis.m.clear(); db.rows.clear(); queue.published.length = 0;
const out = await Promise.all([1,2,3].map(() => createNotification(req, 'race-key')));
console.log('race ids =', out.map(o => o.notification_id),
            '| published =', queue.published.length);
```
]

#code(lang: "text", caption: "Real output")[
```text
{ status: 202, notification_id: 'n_0001', deduped: null }
{ status: 202, notification_id: 'n_0001', deduped: 'db' }
{ status: 202, notification_id: 'n_0001', deduped: 'cache' }
messages actually published = 1
race ids = [ 'n_0003', 'n_0003', 'n_0003' ] | published = 1
```
]

Three callers raced with an empty cache. All three got the *same* id, and exactly *one*
message was published. That is what "idempotent endpoint" means, and now you have seen it
rather than been told it.

#trap[
Look closely at the order inside the happy path: *insert into the database, then publish
to the queue.* If the process dies between those two `await`s, the row exists but nothing
was queued and the note is never sent. Silent loss.

Publishing first is worse: a worker may read the message before the row is committed and
find nothing.

The clean fix is the *transactional outbox*, next. For Tier 2 an acceptable answer is:
"insert the row with `state = 'queued'`, publish, and run a sweeper every 30 seconds that
re-publishes anything still `queued` and older than 60 seconds." That turns silent loss
into a 60-second delay, which we can live with.
]

#subsection[The transactional outbox, drawn]

#diagram(height: 6.6cm, caption: "Outbox: one transaction writes both the row and the message, so they cannot disagree.")[
  #dnode(0pt, 0.5cm, 2.2cm, 0.9cm, [API handler])
  #dnode(3.0cm, 0pt, 5.2cm, 2.3cm, [ ], fill: rgb("#f3f8f4"))
  #place(dx: 3.1cm, dy: 0.08cm)[#text(size: 7.5pt, fill: rgb("#2f6b3f"))[ONE DATABASE TRANSACTION]]
  #dnode(3.3cm, 0.55cm, 2.2cm, 0.8cm, [INSERT\ notifications])
  #dnode(5.8cm, 0.55cm, 2.2cm, 0.8cm, [INSERT\ outbox])
  #darrow(2.2cm, 0.95cm, 3.25cm, 0.95cm)
  #darrow(5.5cm, 0.95cm, 5.75cm, 0.95cm)
  #place(dx: 3.35cm, dy: 1.5cm)[#text(size: 7.5pt)[both commit, or neither does]]
  #dnode(3.3cm, 3.0cm, 2.6cm, 0.9cm, [Relay reads\ unpublished rows])
  #darrow(4.6cm, 2.35cm, 4.6cm, 2.95cm, label: "poll")
  #dnode(6.6cm, 3.0cm, 2.2cm, 0.9cm, [Queue])
  #darrow(5.95cm, 3.45cm, 6.55cm, 3.45cm)
  #dnode(9.3cm, 3.0cm, 2.1cm, 0.9cm, [Worker])
  #darrow(8.85cm, 3.45cm, 9.25cm, 3.45cm)
  #dnode(3.3cm, 4.9cm, 8.1cm, 0.9cm,
    [The relay may publish twice after its own crash, so the worker must still be
     idempotent. Outbox removes *loss*, not *duplication*.], fill: rgb("#f7f7f5"))
  #darrow(7.7cm, 3.95cm, 7.7cm, 4.85cm, dashed: true)
]

#code(lang: "sql", caption: "The outbox table and the relay query")[
```sql
CREATE TABLE outbox (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  topic       VARCHAR(64) NOT NULL,
  msg_key     VARCHAR(64) NOT NULL,
  payload     JSON        NOT NULL,
  created_at  DATETIME(3) NOT NULL,
  published   BOOLEAN     NOT NULL DEFAULT FALSE,
  KEY idx_unpublished (published, id)
);

-- the relay, every 200 ms:
SELECT id, topic, msg_key, payload
  FROM outbox
 WHERE published = FALSE
 ORDER BY id
 LIMIT 500;
-- ... publish each one to the broker ...
UPDATE outbox SET published = TRUE WHERE id IN (...);

-- and a nightly job:
DELETE FROM outbox WHERE published = TRUE AND created_at < NOW() - INTERVAL 2 DAY;
```
]

#ex(12, tier: 2, asked: "Grab · pattern")[
The relay publishes a batch of 500, then crashes before the `UPDATE`. What happens on
restart? Give the number of duplicate messages, and say why the system is still correct.
]
#sol[
On restart the relay runs the same `SELECT`. Those 500 rows still have
`published = FALSE`, so it publishes all 500 *again*.

Duplicates $= 500$ messages, in the worst case, per relay crash.

The system is still correct because the worker is idempotent: each duplicate carries the
same `notification_id`, and gate 3 — `UNIQUE (notification_id, channel, attempt_no)` —
rejects the second write. The user receives one e-mail.

*The cost, stated honestly:* 500 extra broker writes and 500 extra unique-index
violations. At a crash rate of once a week, that is noise. If the relay crashed every
minute we would shrink the batch to 50 and update `published` in smaller chunks, trading
throughput for a smaller duplicate blast radius.
]
#ans[500 duplicate publishes; harmless, because the unique key on (notification_id, channel, attempt_no) absorbs them.]

#subsection[Step 7 — Trade-offs, failure modes, and 10x]

#table(columns: 4,
  align: (left, left, left, left),
  [*Choice*], [*Side A*], [*Side B*], [*Decision and why*],
  [Managed queue vs self-run Kafka], [Managed: no ops, priced per message],
    [Kafka: cheap at volume, gives replay, heavy ops],
    [*Managed.* At 1,390/s the bill is small and we have no streaming team.
     Revisit above 20,000/s.],
  [One queue with priority vs two queues], [One: simpler, one pool],
    [Two: hard isolation, some idle capacity],
    [*Two.* The 60-second promise must not depend on marketing behaving.],
  [Postgres vs a wide-column store for status], [Postgres: joins, transactions, familiar],
    [Cassandra: cheaper at 30 GB/day],
    [*Postgres* with monthly partitions. 900 GB fits comfortably on one box; do not buy a
     distributed database for 900 GB.],
  [Retry by sleeping in the worker vs a delay queue],
    [Sleep: simple, but the concurrency slot is held for up to 32 s],
    [Delay queue: the slot is freed immediately],
    [*Delay queue.* With only 1,112 slots in total, a held slot is real lost capacity.],
  [Sync provider call vs webhook callback],
    [Sync: we know the result now, but 200 ms per send],
    [Webhook: the provider calls us back, slot freed in 20 ms],
    [*Webhook* for e-mail (they support it), sync for push (the gateway answers in 15 ms
     anyway).],
)

*Failure modes and the response.*

#table(columns: 3,
  align: (left, left, left),
  [*Failure*], [*Symptom*], [*Response*],
  [E-mail provider down], [every send throws, retries pile up],
    [circuit breaker opens after 50 failures in 10 s; stop calling; keep the queue;
     fail over to the secondary provider],
  [Poison message], [one worker crashes repeatedly on the same id],
    [3 failures then DLQ; alarm if DLQ depth > 100],
  [Queue backlog grows], [lag over 5 minutes of traffic],
    [autoscale pool A on *lag*, not on CPU — CPU is low because the work is all waiting],
  [Database down], [status writes fail],
    [keep sending; buffer status locally and replay. Losing a status row is far better
     than losing a notification.],
  [Bad template deployed], [wrong text sent to millions],
    [canary: send a new template to 0.1% of traffic for 10 minutes before the rest],
)

*At 10x (400 M DAU, 1.2 B notes/day).*

$1{,}200{,}000{,}000 slash 86{,}400 = 13{,}889$/s average; $times 4 = 55{,}556$/s peak.

Slots $= 55{,}556 slash 5 = 11{,}111$; processes $= 11{,}111 slash 200 = 55.6 arrow 56$,
call it 70 with headroom.

Status storage $= 300$ GB/day, $times 30 = 9$ TB. Now one Postgres box is finished.

*At 10x we shard the status store by `user_id` and move the queue to a partitioned log*,
because at 55,556/s the per-message price of a managed queue overtakes the cost of a small
streaming team. That is the honest 10x answer: the design does not survive unchanged, and
saying so is a plus, not a minus.

#practice(tier: 2, time: "35 min")[
+ A user has quiet hours 22:00--07:00. An order-shipped note arrives at 23:10. What do you
  do with it, and where is that decision made — API, queue, or worker? Defend the choice.
+ Recompute the process count if provider latency drops from 200 ms to 50 ms. Show the
  division.
+ The DLQ has 40,000 messages after a provider outage. Write the replay plan, including
  the rate you replay at and why.
+ Design the API for "send to a segment of 2 million users". Should the API expand the
  segment, or should a worker? Give both sides, then decide.
]

#key[
+ Transactional notes ignore quiet hours (the user wants to know their order shipped);
  marketing respects them. The decision belongs in the *worker*, not the API, because
  quiet hours depend on the user's local time *at delivery*, and the message may have sat
  in the queue for a while. A marketing note in quiet hours is re-queued with a delay
  until 07:00 local.
+ 50 ms per send -> $1 slash 0.05 = 20$ sends/s per slot. Slots $= 5{,}560 slash 20 = 278$.
  Processes $= 278 slash 200 = 1.39 arrow 2$. Keep 3 so one can fail.
+ Replay at a *capped* rate, not full speed — the provider has only just recovered. A
  replay pool limited to 500/s gives $40{,}000 slash 500 = 80$ seconds. Also check each
  message's age: an order-shipped note 6 hours late may be worse than useless, so drop it
  with a log line rather than send it.
+ *API expands:* one call must write 2 M rows before returning — it times out.
  *Worker expands:* the API writes one `campaign` row and returns in 5 ms; a fan-out
  worker reads the segment in pages of 10,000 and publishes 2 M messages.
  *Decision: the worker.* The API must stay a constant-time call; anything whose cost
  grows with the segment size belongs behind the queue.
]

#section[Tier 3 — large scale: the event backbone]
#tier-header(3)

*The question.* "Every service in the company should be able to publish events and every
other service should be able to read them. Build that. We do about 5 billion events a day.
Some of them move money."

#subsection[Step 1 — Clarify]

#table(columns: 3,
  align: (left, left, left),
  [*Ask*], [*Answer we will assume*], [*Why it matters*],
  [Events per day and average size?], [5 B/day, 1 KB], [sets partitions and brokers],
  [Retention?], [7 days hot, 90 days in object storage], [sets disk],
  [Ordering needed?], [per entity (per account), not global],
    [partition key = entity id; global order is impossible at this size],
  [Who reads?], [about 4 major consumer groups], [sets the read bandwidth],
  [Is any event money?], [yes, `payment.captured`], [forces exactly-once *effect*],
  [Latency target?], [p99 under 2 s end to end], [rules out 30-second micro-batching],
  [Multi-region?], [two regions, active-active for reads], [forces a replication story],
)

#subsection[Step 2 — Scale estimate]

*Events per second.*

$5{,}000{,}000{,}000 slash 86{,}400 = 57{,}870$ events/s average.

Peak $= 3 times 57{,}870 = 173{,}611$ events/s.

*Bytes per second at peak.* Using 1 KB $= 1{,}000$ B:

$173{,}611 times 1{,}000 "B" = 173{,}611{,}000 "B/s" = 173.6$ MB/s written.

*Partition count — the two constraints.*

Constraint A, *write throughput*. One partition safely takes about 10 MB/s.

$173.6 slash 10 = 17.36 arrow 18$ partitions minimum.

Constraint B, *consumer parallelism*. One consumer process handles about 2,000 events/s
(it does real work, not just counting).

$173{,}611 slash 2{,}000 = 86.8 arrow 87$ consumer processes needed.

And a consumer group can never have more *working* members than partitions. So we need at
least 87 partitions.

Constraint B is almost 5 times stricter than constraint A. *Take the maximum, then round
up to a power of two for clean splits: 128 partitions.*

#trap[
Almost everyone computes only constraint A, says "18 partitions", and is then asked
"you have 18 partitions and need 87 consumers — now what?" and has no answer. Partition
count is very hard to change later, because increasing it changes which partition a key
hashes to and *breaks per-key ordering*. Compute both constraints, take the max, add room.
]

Here is the "hard to change later" claim, measured rather than asserted:

#code(lang: "js", caption: "partitioning.js — what happens when you grow P")[
```js
function fnv1a(str) {                       // small stable hash, no library needed
  let h = 0x811c9dc5;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;     // >>> 0 keeps it an unsigned 32-bit int
  }
  return h >>> 0;
}
const partitionOf = (key, P) => fnv1a(key) % P;

const keys = ['acct_7781', 'acct_77', 'acct_888', 'acct_101', 'acct_42'];
console.log('P=128 :', keys.map(k => `${k}->${partitionOf(k, 128)}`).join('  '));
console.log('P=256 :', keys.map(k => `${k}->${partitionOf(k, 256)}`).join('  '));

let moved = 0;
for (let i = 0; i < 100000; i++) {
  if (partitionOf('acct_' + i, 128) !== partitionOf('acct_' + i, 256)) moved++;
}
console.log(`keys that change partition when 128 -> 256: ` +
            `${moved}/100000 = ${(moved / 1000).toFixed(1)}%`);
```
]

#code(lang: "text", caption: "Real output")[
```text
P=128 : acct_7781->90  acct_77->109  acct_888->93  acct_101->29  acct_42->73
P=256 : acct_7781->90  acct_77->237  acct_888->221  acct_101->157  acct_42->73
keys that change partition when 128 -> 256: 49891/100000 = 49.9%
```
]

Half the keys move. For every one of those keys, its old events sit in one log and its new
events in another, and no consumer can see them in order ever again. *That* is why you get
the partition count right on day one.

*Storage.*

Raw per day $= 5{,}000{,}000{,}000 times 1{,}000 "B" = 5{,}000{,}000{,}000{,}000 "B" = 5$ TB.

With replication factor 3: $5 times 3 = 15$ TB/day.

7-day hot retention: $15 times 7 = 105$ TB.

*Brokers.* Give each broker 20 TB of usable disk.

By storage: $105 slash 20 = 5.25 arrow 6$ brokers.

But check the *network*, which usually binds first:

- Producers in: 173.6 MB/s.
- Replication: each message is copied to 2 followers $= 173.6 times 2 = 347.2$ MB/s.
- Total broker inbound $= 173.6 + 347.2 = 520.8$ MB/s.
- Consumers out: 4 groups each read everything $= 173.6 times 4 = 694.4$ MB/s.

With 12 brokers:

In per broker $= 520.8 slash 12 = 43.4$ MB/s.

Out per broker $= 694.4 slash 12 = 57.9$ MB/s.

Total per broker $= 43.4 + 57.9 = 101.3$ MB/s $= 101.3 times 8 = 810$ Mbps.

A 10 Gbps NIC is 10,000 Mbps, so we sit at about 8% of the card. That leaves room for the
doubled traffic of a replica rebuild after a broker dies.

Disk per broker $= 105 slash 12 = 8.75$ TB. Comfortable.

*Decision: 12 brokers, 128 partitions, replication factor 3.* Storage alone says 6 brokers;
we take 12 for network headroom and smaller blast radius per node.

#formulas(title: "Tier-3 estimate, one block")[
- 5 B/day / 86,400 = 57,870/s avg; x3 peak = 173,611/s
- x 1 KB = 173.6 MB/s in
- partitions: max(173.6 / 10 = 18, 173,611 / 2,000 = 87) = 87 -> round to *128*
- storage: 5 TB/day raw, x3 replicas = 15 TB/day, x7 days = *105 TB*
- brokers: 105 / 20 = 5.25 by disk; take *12* for network headroom
- per broker: (520.8 + 694.4) / 12 = 101.3 MB/s = 810 Mbps on a 10 Gbps NIC
]

#subsection[Step 3 — API surface]

#code(lang: "http", caption: "Publish — the envelope is fixed for the whole company")[
```http
POST /v1/events
Content-Type: application/json

{
  "event_id":    "evt_01HQ8ZK4F2",     // unique, generated by the producer
  "type":        "payment.captured",
  "version":     3,                     // schema version
  "key":         "acct_7781",           // partition key: ordering is per account
  "occurred_at": "2026-03-03T10:02:11.481Z",
  "producer":    "payments-api",
  "trace_id":    "4bf92f3577b34da6",
  "data": { "amount_minor": 249900, "currency": "INR", "order_id": "99213" }
}

202 Accepted
{ "partition": 41, "offset": 90210411 }
```
]

#code(lang: "js", caption: "Consumer-side contract, as code")[
```js
subscribe({
  topic:   'payments',
  groupId: 'ledger',
  // handler MUST be idempotent: the same batch can arrive twice
  handler: async (batch) => { /* ... */ },
  autoCommit: false,          // we commit ourselves, after the handler returns
  maxPollIntervalMs: 300_000, // 5 min: longer than this and the group evicts us
});
```
]

#note[
Fixing one envelope for the whole company (`event_id`, `type`, `version`, `key`,
`occurred_at`, `trace_id`) is the single highest-value decision in this design. Without it
every consumer writes its own parser, and a schema change breaks six teams silently.
]

#subsection[Step 4 — Data model: the log itself]

#table(columns: 3,
  align: (left, left, left),
  [*Field*], [*Type*], [*Note*],
  [`topic`], [string], [one per event family: `payments`, `orders`, `users`],
  [`partition`], [int 0..127], [`hash(key) mod 128`],
  [`offset`], [int64], [strictly increasing *inside one partition*; never global],
  [`key`], [bytes], [decides the partition; same key -> same partition -> ordered],
  [`value`], [bytes], [the envelope above, serialized],
  [`timestamp`], [int64 ms], [store both the broker time and the producer time],
  [`headers`], [map], [`trace_id`, `schema_version`, `retry_count`],
)

*Consumer offsets* live in a compacted topic of their own:

#table(columns: 2,
  align: (left, left),
  [*Key*], [*Value*],
  [`(group_id, topic, partition)`], [`(offset, commit_time, member_id)`],
)

Compaction keeps only the newest value per key, so this topic stays small forever even
though it is written to constantly.

#subsection[Step 5 — Architecture]

#diagram(height: 8.4cm, caption: "One topic, 128 partitions, three copies of each, four independent consumer groups.")[
  #dnode(0pt, 0.3cm, 2.0cm, 0.8cm, [Payments svc])
  #dnode(0pt, 1.4cm, 2.0cm, 0.8cm, [Orders svc])
  #dnode(0pt, 2.5cm, 2.0cm, 0.8cm, [Users svc])
  #dnode(2.6cm, 1.4cm, 1.9cm, 0.9cm, [Producer\ SDK], fill: rgb("#e8f0e8"))
  #darrow(2.0cm, 0.7cm, 2.55cm, 1.6cm)
  #darrow(2.0cm, 1.8cm, 2.55cm, 1.85cm)
  #darrow(2.0cm, 2.9cm, 2.55cm, 2.1cm)
  #dnode(5.2cm, 0pt, 3.2cm, 3.5cm, [ ], fill: rgb("#f4f6f8"))
  #place(dx: 5.3cm, dy: 0.08cm)[#text(size: 7.5pt, fill: dc)[BROKER CLUSTER (12)]]
  #dnode(5.4cm, 0.55cm, 2.8cm, 0.6cm, [P0 leader b3 · copies b7,b11])
  #dnode(5.4cm, 1.3cm, 2.8cm, 0.6cm, [P1 leader b7 · copies b3,b9])
  #dnode(5.4cm, 2.05cm, 2.8cm, 0.6cm, [... 128 partitions ...])
  #dnode(5.4cm, 2.8cm, 2.8cm, 0.6cm, [P127 leader b11 · copies b1,b5])
  #darrow(4.5cm, 1.85cm, 5.35cm, 1.6cm, label: "hash(key)")
  #dnode(9.2cm, 0.2cm, 2.2cm, 0.65cm, [Group: ledger])
  #dnode(9.2cm, 1.05cm, 2.2cm, 0.65cm, [Group: search])
  #dnode(9.2cm, 1.9cm, 2.2cm, 0.65cm, [Group: fraud])
  #dnode(9.2cm, 2.75cm, 2.2cm, 0.65cm, [Group: warehouse])
  #darrow(8.45cm, 1.5cm, 9.15cm, 0.5cm)
  #darrow(8.45cm, 1.6cm, 9.15cm, 1.35cm)
  #darrow(8.45cm, 1.9cm, 9.15cm, 2.2cm)
  #darrow(8.45cm, 2.0cm, 9.15cm, 3.05cm)
  #dnode(5.4cm, 4.5cm, 2.8cm, 0.8cm, [Tiered storage\ (90 days, object store)],
    fill: rgb("#f7f7f5"))
  #darrow(6.8cm, 3.55cm, 6.8cm, 4.45cm, label: "age out", dashed: true)
  #dnode(9.2cm, 4.5cm, 2.2cm, 0.8cm, [Retry topics\ + DLQ], fill: rgb("#f7ecec"))
  #darrow(10.3cm, 3.45cm, 10.3cm, 4.45cm, label: "fail")
  #dnode(0pt, 4.5cm, 4.6cm, 0.8cm, [Schema registry\ (rejects bad events)],
    fill: rgb("#f7f7f5"))
  #darrow(3.5cm, 2.4cm, 2.3cm, 4.45cm, dashed: true)
  #dnode(0pt, 6.5cm, 11.4cm, 1.0cm,
    [Each group keeps its own offset, so the warehouse can be 3 hours behind while fraud
     stays 200 ms behind. One log, four speeds, no copies.], fill: rgb("#f7f7f5"))
]

#subsection[Step 6a — Deep dive: exactly-once for money]

`payment.captured` must post to the ledger exactly once. Here is the chain of places a
duplicate can be born, and the fix for each.

#table(columns: 3,
  align: (left, left, left),
  [*Where a duplicate is born*], [*How*], [*Fix*],
  [Producer], [publish times out, the SDK resends],
    [producer sequence numbers: the broker remembers `(producer_id, seq)` and drops a
     repeat],
  [Broker], [leader fails after writing but before acking; producer resends],
    [the same sequence-number dedup, plus `acks=all`],
  [Consumer], [handler succeeds, process dies before the commit; the batch replays],
    [*this is the one you must solve in your own code*],
)

The consumer fix, in order of strength:

#table(columns: 4,
  align: (left, left, left, left),
  [*Technique*], [*How it works*], [*Strength*], [*Cost*],
  [Natural idempotency], [write an absolute value, not a delta],
    [perfect when it applies], [rarely applies to money],
  [Unique key on the effect], [insert into `ledger_entries` with `UNIQUE(event_id)`],
    [perfect], [one index, one row per event],
  [Offset in the same transaction], [write the business row *and* the consumed offset in
    one DB transaction], [perfect], [offsets now live in your DB, not the broker],
  [Redis dedup set], [`SET NX event_id`], [best effort only],
    [cheap, but a Redis failure silently lets a duplicate through],
)

#code(lang: "sql", caption: "The pattern that actually works: a unique key on the effect")[
```sql
CREATE TABLE ledger_entries (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  event_id    CHAR(26)    NOT NULL,        -- the id from the envelope
  account_id  VARCHAR(32) NOT NULL,
  delta_minor BIGINT      NOT NULL,
  created_at  DATETIME(3) NOT NULL,
  UNIQUE KEY uk_event (event_id)           -- the whole guarantee is this one line
);

CREATE TABLE consumed_offsets (
  group_id VARCHAR(64), topic VARCHAR(64), part INT, off BIGINT,
  PRIMARY KEY (group_id, topic, part)
);
```
]

#code(lang: "js", caption: "consumer.js — business write and offset write in ONE transaction")[
```js
function onBatch(db, batch) {
  const tx = db.begin();
  for (const rec of batch) {
    const e = rec.value;
    const n = tx.insertIgnoreLedger(e.event_id, e.data.account_id, e.data.amount_minor);
    if (n === 0) metrics.duplicate_skipped++;     // already applied on an earlier pass
  }
  const last = batch[batch.length - 1];
  tx.setOffset(GROUP, last.topic, last.partition, last.offset + 1);
  tx.commit();        // the business effect and the offset become durable TOGETHER
}
```
]

#code(lang: "js", caption: "The test: run the SAME batch twice, as a crash would")[
```js
const db = new FakeDb();
const batch = [mk(100, 'evt_A', 1000), mk(101, 'evt_B', 2500), mk(102, 'evt_C', 400)];

onBatch(db, batch);
console.log('after first pass : balance =', db.balanceOf('acct_7781'),
            'offset =', db.offsets.get('ledger|payments|41'));

onBatch(db, batch);        // the broker redelivers the WHOLE batch after a crash
console.log('after replay     : balance =', db.balanceOf('acct_7781'),
            'offset =', db.offsets.get('ledger|payments|41'));
console.log('duplicates skipped =', metrics.duplicate_skipped);

let naive = 0;             // what a non-idempotent consumer would have done
for (const r of batch) naive += r.value.data.amount_minor;
console.log('naive "balance += amount" after two passes =', naive * 2);
```
]

#code(lang: "text", caption: "Real output")[
```text
after first pass : balance = 3900 offset = 103
after replay     : balance = 3900 offset = 103
duplicates skipped = 3
naive "balance += amount" after two passes = 7800
```
]

The balance is 3,900 after one pass and still 3,900 after the replay. The naive version
would have said 7,800. That gap — 3,900 rupees of invented money per replayed batch — is
what `UNIQUE(event_id)` is buying you.

#ex(13, tier: 3, asked: "Amazon · pattern")[
The consumer commits offsets to the *broker* every 5 seconds, in the background, while it
is still processing. Show a concrete sequence where money is lost, and one where money is
doubled. Then say which is worse and why.
]
#sol[
Let the batch be offsets 100..199.

*Money doubled — commit happens after the work, but the process dies first.*

+ $t=0$: the consumer fetches 100..199.
+ $t=1$: it writes 100 ledger rows (offsets 100..149 applied).
+ $t=2$: the process is killed. The last committed offset is still 99.
+ $t=3$: a new member takes the partition and starts at 100.
+ Offsets 100..149 are applied *a second time*. Fifty accounts are credited twice.

*Money lost — the auto-commit timer fires too early.*

+ $t=0$: the consumer fetches 100..199.
+ $t=5$: the 5-second timer fires and commits offset 200, because the *fetch* position has
  moved on — even though the handler has only reached offset 130.
+ $t=6$: the process is killed.
+ $t=7$: a new member starts at 200. Offsets 131..199 are *never processed*. Sixty-nine
  payments vanish.

*Which is worse?* Loss is worse. A duplicate credit is visible in the ledger and a
reconciliation job can find two entries carrying one `event_id` and reverse one. A lost
event leaves *no trace anywhere* — there is nothing to reconcile against, and you learn
about it from an angry customer weeks later.

*Decision:* turn auto-commit off, commit manually after the handler returns, and store the
offset in the same transaction as the effect. Then both sequences above become impossible,
because the offset can be neither ahead of nor behind the work.
]
#ans[Auto-commit can commit past unprocessed records (loss) or lag behind applied ones (doubles). Loss is worse. Use manual commit inside the business transaction.]

#subsection[Step 6b — Deep dive: backpressure and the retry ladder]

A consumer that cannot keep up has four honest options and one dishonest one.

#table(columns: 3,
  align: (left, left, left),
  [*Option*], [*Effect*], [*When it is right*],
  [Slow the producer (block on publish)],
    [the pain moves upstream to a service that can shed load],
    [internal producers you control],
  [Add consumers], [works only up to the partition count], [the first thing to try],
  [Shed load: drop low-value events], [some data is lost, on purpose, with a metric],
    [metrics, click streams],
  [Spill to a slower cheaper store and catch up later], [latency rises, nothing is lost],
    [analytics],
  [*Silently buffer in memory*],
    [the consumer runs out of heap and dies, losing everything in flight], [*never*],
)

#trap[
An unbounded in-memory buffer is not backpressure. It is a delayed crash. In Node this is
especially easy to write by accident: `stream.on('data', d => queue.push(d))` never
applies backpressure, because the array grows as fast as the socket delivers. Use
`for await (const chunk of stream)` or `pipeline()`, which pause the socket when you stop
consuming. Every queue inside your process must have a fixed size, and a full queue must
*block or reject*, never grow.
]

*The retry ladder.* Never retry a failed message in a tight loop on the main partition —
that is head-of-line blocking, and one bad account stops 40,000 good ones.

#diagram(height: 6.2cm, caption: "Retry topics: a slow or broken message leaves the main partition immediately.")[
  #dnode(0pt, 0.6cm, 2.3cm, 0.9cm, [main topic])
  #dnode(3.0cm, 0.6cm, 2.0cm, 0.9cm, [consumer])
  #darrow(2.3cm, 1.05cm, 2.95cm, 1.05cm)
  #dnode(5.8cm, 0pt, 1.9cm, 0.75cm, [commit\ offset], fill: rgb("#e8f0e8"))
  #darrow(5.0cm, 0.95cm, 5.75cm, 0.4cm, label: "ok")
  #dnode(5.8cm, 1.3cm, 1.9cm, 0.75cm, [retry-5s])
  #darrow(5.0cm, 1.15cm, 5.75cm, 1.65cm, label: "fail")
  #dnode(8.2cm, 1.3cm, 1.6cm, 0.75cm, [retry-1m])
  #darrow(7.7cm, 1.68cm, 8.15cm, 1.68cm)
  #dnode(8.2cm, 2.5cm, 1.6cm, 0.75cm, [retry-15m])
  #darrow(9.0cm, 2.1cm, 9.0cm, 2.45cm)
  #dnode(5.8cm, 2.5cm, 1.9cm, 0.75cm, [DLQ], fill: rgb("#f7ecec"))
  #darrow(8.15cm, 2.9cm, 7.75cm, 2.9cm, label: "4th fail")
  #dnode(0pt, 2.5cm, 4.6cm, 0.9cm, [Main partition keeps moving\ the whole time],
    fill: rgb("#f3f8f4"))
  #darrow(4.0cm, 1.55cm, 2.6cm, 2.45cm, dashed: true)
  #dnode(0pt, 4.5cm, 11.4cm, 0.9cm,
    [Each retry topic has its own consumers, so a 15-minute wait costs nothing on the hot
     path. The DLQ is replayed by hand after the bug is fixed.], fill: rgb("#f7f7f5"))
]

#ex(14, tier: 3, asked: "Google · pattern")[
A schema bug makes 0.5% of `payment.captured` events unparseable. Traffic is 173,611
events/s at peak. The bug lives for 40 minutes. How many events reach the DLQ? At a replay
rate of 5,000/s, how long does the cleanup take? What is the risk during the replay?
]
#sol[
*Bad events per second* $= 173{,}611 times 0.005 = 868.06 approx 868$/s.

*Duration* $= 40 times 60 = 2{,}400$ seconds.

*Total in the DLQ* $= 868 times 2{,}400 = 2{,}083{,}200$ events.

*Replay time* $= 2{,}083{,}200 slash 5{,}000 = 416.6$ seconds $approx 7$ minutes.

*The risk during the replay — and this is the real answer.* These are 40-minute-old money
events. If the ledger consumer applies them by `occurred_at`, fine. But if any downstream
consumer assumes "a newer offset means a newer event", the replay injects 2 million old
events *after* newer ones for the same account, and a naive last-write-wins balance update
rolls accounts backwards.

*Three protections:*

+ Replay into a *separate* topic that only the ledger consumer reads, not the shared topic
  every team reads.
+ Make the ledger append-only — rows in `ledger_entries`, balance computed as a sum — so
  order does not matter at all. Addition is commutative; last-write-wins is not.
+ Cap the replay at 5,000/s, about 3% of peak, so the ledger database is not pushed over
  while it is still serving live traffic.
]
#ans[2,083,200 events; about 417 s (7 min) to replay. The main risk is out-of-order application; fix it by making the ledger append-only and replaying on a private topic.]

#ex(15, tier: 3, asked: "Microsoft · pattern")[
Your consumer group has 87 members on 128 partitions. A "stop the world" rebalance pauses
*every* member for 8 seconds. You deploy by restarting one member at a time. How long is
the group paused in total, and what do you change?
]
#sol[
Restarts $= 87$. Each restart triggers *two* rebalances: one when the member leaves, one
when it rejoins.

Rebalances $= 87 times 2 = 174$.

Pause $= 174 times 8 = 1{,}392$ seconds $= 23.2$ minutes of total stoppage.

During those 23 minutes, at 173,611 events/s, the backlog grows by
$1{,}392 times 173{,}611 = 241{,}666{,}512$ events — about 242 million. Draining that
alone takes many minutes after the deploy has finished.

*Three fixes, in order of value.*

+ *Static membership.* Give each member a fixed instance id. A restart inside the session
  timeout (say 5 minutes) triggers *no rebalance at all* — the member reclaims its own
  partitions. This alone removes almost all 174 rebalances.
+ *Cooperative (incremental) rebalancing.* Only the partitions that actually move are
  paused, instead of all 128. A one-member change moves about
  $128 slash 87 approx 1.5$ partitions, so roughly 1% of the group pauses instead of 100%.
+ *Deploy in batches.* Restarting 9 members at a time gives
  $87 slash 9 = 9.67 arrow 10$ batches, so 20 rebalances instead of 174 — a
  $174 slash 20 = 8.7 times$ reduction, at the cost of losing 10% of capacity at once.

*Decision:* static membership first — it is a configuration change and it removes the
problem. Cooperative rebalancing second. Batching third. Do not accept a 23-minute deploy
pause as normal.
]
#ans[174 rebalances x 8 s = 1,392 s = 23.2 min paused, about 242 M events of backlog. Fix with static membership, then cooperative rebalancing.]

#subsection[Step 6c — Ordering: what you can and cannot promise]

#table(columns: 3,
  align: (left, left, left),
  [*Promise*], [*Possible?*], [*How, or why not*],
  [All events for one account in order], [yes], [partition key = `account_id`],
  [All events in the whole topic in order], [no, at this scale],
    [that needs 1 partition = a 10 MB/s ceiling; we need 173.6 MB/s],
  [Order across two topics], [no], [no shared clock, no shared log],
  [Order after a key changes partition], [no],
    [changing the partition count re-maps keys, as the 49.9% measurement showed],
  [Detect out-of-order at the consumer], [yes],
    [carry a per-key `sequence` in the envelope and drop anything with
     `seq <= lastSeenSeq`],
)

#trick[
When an interviewer asks for global ordering, do not say "impossible" and stop. Say:
"Global order caps us at one partition and 10 MB/s, and we need 173.6 MB/s — 17 times
more. So I will give *per-account* order, which is what the business actually needs, and
add a per-key sequence number so consumers can *detect* any gap." That sentence is the
whole answer.
]

#subsection[Step 7 — Trade-offs, failure modes, 10x]

#table(columns: 4,
  align: (left, left, left, left),
  [*Choice*], [*Side A*], [*Side B*], [*Decision*],
  [`acks=1` vs `acks=all`],
    [`acks=1`: about 2 ms to publish, loses data if the leader dies before replication],
    [`acks=all`: about 9 ms, survives a leader loss],
    [*`acks=all` for money topics, `acks=1` for click streams.* Do not use one setting
     everywhere; the cost is 7 ms and the benefit is not losing payments.],
  [Replication factor 2 vs 3],
    [RF2: 33% less disk, one failure away from data loss],
    [RF3: survives two failures, costs 15 TB/day],
    [*RF3.* With 12 brokers a single-node failure during a rolling restart is routine;
     RF2 turns that routine event into a data-loss event.],
  [128 vs 512 partitions],
    [128: fewer files, faster rebalance, caps consumers at 128],
    [512: room for 512 consumers, far more metadata and open files],
    [*128 now.* We need 87. Going to 512 quadruples rebalance time to buy capacity we will
     not use for two years — and a brand-new topic is always available later.],
  [Broker-managed offsets vs offsets in the consumer's own database],
    [Broker: simple, built-in tooling],
    [Own DB: allows exactly-once together with the business write],
    [*Own DB for money consumers, broker for the rest.* Pay the complexity only where it
     buys correctness.],
  [Active-active vs active-passive across regions],
    [Active-active: both regions publish, but the same key can be written in two places
     and ordering is broken],
    [Active-passive: one region publishes, the other mirrors],
    [*Active-passive for writes, active-active for reads.* Cross-region write ordering has
     no cheap correct answer; reading from a local mirror gets 90% of the benefit for 10%
     of the risk.],
)

*Failure modes.*

#table(columns: 3,
  align: (left, left, left),
  [*Failure*], [*What happens*], [*What you do*],
  [Broker dies], [its leader partitions are re-elected from the in-sync copies in seconds],
    [require 2 in-sync replicas so a write is never acked by a lone survivor],
  [Disk fills], [the broker stops accepting writes, producers block],
    [alarm at 70% and enforce retention by size as well as by time],
  [Slow consumer], [lag grows; retention may delete data it has not read],
    [alarm on lag *in seconds*, not in messages; 105 TB of retention is your margin],
  [Zombie producer], [an old process that was replaced keeps publishing],
    [epoch fencing on the producer id; the broker rejects the stale epoch],
  [Whole region down], [publishes fail],
    [producers buffer to local disk for 15 minutes, then fail fast to the caller],
  [Schema change breaks consumers], [parse errors everywhere],
    [the registry enforces backward compatibility: a field may be added, never removed
     and never re-typed],
)

*At 10x — 50 billion events/day.*

$50{,}000{,}000{,}000 slash 86{,}400 = 578{,}704$/s average; peak $times 3 = 1{,}736{,}111$/s.

Bytes $= 1{,}736{,}111 times 1{,}000 = 1{,}736$ MB/s $approx 1.74$ GB/s.

Consumers needed $= 1{,}736{,}111 slash 2{,}000 = 868$. Partitions must exceed 868, so
choose *1,024*.

Storage $= 50$ TB/day raw, $times 3 = 150$ TB/day, $times 7 = 1{,}050$ TB $= 1.05$ PB hot.

Brokers by disk at 20 TB each $= 1{,}050 slash 20 = 52.5 arrow 53$; by network we would
want more — say *80*.

*What changes at 10x, honestly:*

+ Seven days of hot retention becomes unaffordable. Move to *1 day hot plus tiered object
  storage*: hot drops from 1.05 PB to $150 times 1 = 150$ TB, and older data lives in
  object storage at roughly a tenth of the price.
+ One cluster becomes a blast-radius problem. Split into *per-domain clusters* —
  payments, click stream, logs — so a click-stream flood cannot slow payments down.
+ At 1,024 partitions rebalances get slow. Static membership stops being optional.
+ Compression stops being optional too. A modern compressor gets roughly 4:1 on JSON,
  turning 1.74 GB/s into about 0.44 GB/s on the wire and on disk. That one flag is worth
  more than 20 extra brokers.

#section[Interview drill — what the interviewer pushes on]

#table(columns: 2,
  align: (left, left),
  [*They ask*], [*You answer*],
  ["Guarantee exactly-once."], ["The broker cannot. I get exactly-once *effect*:
    at-least-once delivery, plus a unique key on the effect, plus the offset committed in
    the same transaction as the business write."],
  ["Why not just use a database table as a queue?"], ["It works to a few hundred jobs per
    second — `SELECT ... FOR UPDATE SKIP LOCKED` is a real pattern. It breaks when polling
    load and cleanup pressure start hurting the main database. At 1,390/s I would still
    consider it; at 173,611/s never."],
  ["How many partitions?"], ["The max of two constraints: throughput (MB/s divided by
    about 10 MB/s per partition) and consumer parallelism (peak rate divided by
    per-consumer rate). Here max(18, 87) = 87, rounded up to 128."],
  ["A consumer is 4 hours behind. What do you do?"], ["First check whether retention will
    delete unread data — that is the real deadline. Then find out whether it is slow code
    or too few members. If members already equal partitions I cannot scale out, so I must
    make the handler faster or spin up a temporary parallel group writing into a side
    store."],
  ["Kafka or SQS?"], ["Replay or multiple independent readers -> Kafka. Independent tasks
    with no replay and no ops team -> SQS. For this notification service, SQS; for the
    event backbone, Kafka."],
  ["Your DLQ has 2 million messages. Now what?"], ["Do not replay blindly. Group by error
    reason first — usually three causes cover 95%. Fix the code, replay at a capped rate
    into a private topic, and drop anything whose business value has expired."],
  ["Does a queue reduce total work?"], ["No. It moves work off the user's critical path
    and makes it retryable. Total CPU is the same or slightly more."],
  ["When would you NOT use a queue?"], ["When the caller needs the result in order to
    continue (a payment authorisation), when the work takes under 10 ms anyway, or when
    the added failure modes — dedup, ordering, DLQ, lag alarms — cost more than the 20 ms
    you saved."],
  ["Node is single-threaded — can it even do this?"], ["Yes, because this work is
    I/O-bound, not CPU-bound. One process holds 200 in-flight sends while the CPU idles.
    If the handler were CPU-heavy — image resizing, for example — I would move it to
    `worker_threads` or a separate service, because then one process really does give me
    one core."],
)

#trap[
The most common Tier-3 failure is answering "we use Kafka" to every question. Kafka is a
*log*. It is a poor fit for per-message delays, per-message acks, priority, and a million
low-rate queues. If the question asks "retry this one message in 15 minutes", the honest
answer is a delay queue or a retry-topic ladder, not Kafka alone.
]

#practice(tier: 3, time: "45 min")[
+ A topic has 64 partitions, 173,611 events/s at peak, and one key (`acct_super`) carries
  8% of all traffic. Compute the load on its partition, compare with the average, propose
  a fix, and state what the fix costs.
+ Design a delayed-job service: "run this task at exactly 09:00 next Tuesday", with 50
  million scheduled tasks live at any time. Which parts of this chapter apply and which
  do not?
+ Your team wants to move the click-stream topic from at-least-once to at-most-once to
  save money. Compute what you save and what you lose, then decide.
+ A consumer group of 40 members reads 128 partitions. A deploy costs 8 rebalances of 6 s
  each. Compute the pause and propose a target.
+ Explain to a junior engineer, in five sentences, why a queue does not make the system
  faster.
]

#key[
+ Average per partition $= 173{,}611 slash 64 = 2{,}712.7$ events/s. The hot key's
  partition gets $173{,}611 times 0.08 = 13{,}889$/s from that key alone, plus its share
  of the rest: $173{,}611 times 0.92 slash 64 = 2{,}495.9$/s. Total $approx 16{,}385$/s,
  which is $16{,}385 slash 2{,}712.7 approx 6.0 times$ the average. One consumer cannot
  keep up. *Fix:* salt the key — use `acct_super#0` .. `acct_super#7` to spread over 8
  partitions. *Cost:* you lose ordering for that account, so this is acceptable only if
  that account's events are commutative (an append-only ledger, yes; a state machine, no).
+ *Applies:* idempotency, DLQ, at-least-once. *Does not apply:* a log is the wrong store —
  you cannot ask a log "what is due at 09:00". Use a store sorted by due time (a database
  index on `run_at`, or one Redis sorted set per minute bucket) and a poller that moves
  due tasks into a normal work queue. 50 M rows with an index on `run_at` is easy; the
  queue then only ever sees tasks that are due *now*.
+ *Save:* the ack round trip and the dedup store — at 5 B events/day, maybe 10--15% of
  consumer cost. *Lose:* on every consumer crash you lose the in-flight batch. At a batch
  of 500 and 20 crashes a month that is $500 times 20 = 10{,}000$ lost events per month
  out of $5 times 10^9 times 30 = 1.5 times 10^11$ — a loss rate of about
  $6.7 times 10^(-8)$. *Decision: accept it for the click stream.* The analytics numbers
  move by far less than their own sampling error. Never accept it for payments.
+ A deploy as described costs $8 times 6 = 48$ s. But restarting all 40 members one at a
  time actually causes $40 times 2 = 80$ rebalances $= 480$ s. Target: static membership,
  so a restart inside the session timeout causes *zero* rebalances — under 10 s in total.
+ "The work still has to be done, and it still costs the same CPU. A queue only changes
  *who waits*. The user stops waiting; a background worker waits instead. That is why the
  page feels four times faster while the servers do slightly more work than before. The
  real prizes are that the slow part can now be retried, batched, and scaled on its own."
]

#revision[
*Definitions.* Queue = one consumer, message deleted after work. Stream = many consumer
groups, message kept for a retention period, each group holds its own offset. Partition =
an independent ordered log. *Max working consumers in a group = partition count.*

*Delivery.* At-most-once = ack then work (loses). At-least-once = work then ack
(duplicates) — the default. Exactly-once *delivery* does not exist; exactly-once *effect*
does, via a unique key on the effect plus the offset written in the same transaction.

*Numbers to memorise.*
- one partition $approx$ 10 MB/s of writes
- one network-bound concurrency slot $approx 1 slash$ (latency in seconds) jobs/s;
  200 ms -> 5/s
- about 200 in-flight I/O-bound operations per Node process
- backoff total with base $b$ and $n$ retries $= b(2^n - 1)$; base 1 s, 6 tries = 63 s
- lag drain time = lag / (consumer rate $-$ producer rate)
- doubling the partition count moves about 50% of keys (measured: 49.9%)

*The partition formula.*
$P = max("peak MB/s" slash 10, "peak events/s" slash "per-consumer rate")$, rounded up to
a power of two. Worked here:
$max(173.6 slash 10, 173{,}611 slash 2{,}000) = max(18, 87) = 87 arrow 128$.

*The estimate skeleton.* DAU x actions = per day -> $slash 86{,}400$ = average/s ->
x peak factor -> x bytes = MB/s -> x retention = storage -> $slash$ per-node capacity =
node count. Always show the division.

*JavaScript traps that bite in this chapter.*
+ `sort()` is lexicographic. Times and offsets need `(a, b) => a - b`.
+ No built-in priority queue. Use the toolkit `MinHeap`.
+ Atomicity in Node is the stretch between two `await`s. Check-then-act must live in one
  such stretch, or take an explicit async mutex.
+ `Map` keeps insertion order; a plain object does not promise it. The windowed-dedup
  eviction loop depends on that.
+ `stream.on('data', d => arr.push(d))` is not backpressure. Use `for await` or
  `pipeline()`.

*Checklist before you say "done".*
+ Named the delivery semantic out loud.
+ Showed where duplicates are absorbed (a unique key, not a cache).
+ Gave a DLQ with a retry count and an alarm on depth.
+ Said what happens when consumers fall behind (backpressure, not silent buffering).
+ Chose a partition key and said what ordering it does and does not give.
+ Named both sides of every trade-off and then *decided*.
+ Said what breaks at 10x and what you would change.

*Three sentences that score marks.*
+ "The broker gives me at-least-once; my unique key on `event_id` gives me exactly-once
  effect."
+ "Partition count is set by consumer parallelism, not by throughput, and it is very hard
  to change later — about half the keys move when you double it."
+ "An unbounded in-memory buffer is not backpressure, it is a delayed crash."
]

]
