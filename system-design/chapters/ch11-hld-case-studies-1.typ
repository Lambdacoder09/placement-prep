#import "../../shared/lib/style.typ": *

#chapter(num: 11, title: "HLD Case Studies I",
  tagline: "The low-level pieces — base62, key blocks, token bucket, sliding window, dispatcher — then a URL shortener walked end to end")[

#section[The idea in one page]

You have learnt the parts. Chapters 6 to 10 gave you databases, caches, load balancers,
queues, sharding and replication. This chapter puts them together.

Five designs. Each one is walked end to end using the same seven steps from Chapter 1.
The steps never change. Only the numbers and the hard part change.

#formulas(title: "The seven steps — say them out loud before you draw anything")[
#table(columns: (auto, 1fr, auto),
  [*\#*], [*Step*], [*Minutes*],
  [1], [Clarify. Ask 4 to 6 questions. Write the answers on the board.], [5],
  [2], [Scale estimate. DAU $->$ QPS $->$ storage/year $->$ bandwidth. Show the division.], [5],
  [3], [API surface. Three to six real endpoints with real payloads.], [5],
  [4], [Data model. Tables, fields, and the *chosen key* (partition key + sort key).], [5],
  [5], [Architecture diagram. Boxes and arrows. Read path and write path separately.], [8],
  [6], [Deep dive on the one or two genuinely hard parts.], [10],
  [7], [Trade-offs, failure modes, what changes at 10x.], [7],
)
Total 45 minutes. If you are 20 minutes in and still clarifying, you will fail.
]

#subsection[What each design in this chapter teaches you]

#table(columns: (auto, 1fr, 1fr),
  [*Design*], [*The real lesson*], [*The trap*],
  [URL shortener], [Key generation without coordination], [Thinking hashing is enough],
  [Rate limiter], [Shared counters under concurrency], [Counting per-server, not globally],
  [Notifications], [Fan-out to unreliable third parties], [No dedupe, no retry budget],
  [News feed], [Push vs pull, and the celebrity problem], [One fan-out strategy for everyone],
  [Chat], [Stateful connections and message ordering], [Using request/response for a stream],
)

#subsection[The numbers you must have in your head]

#formulas(title: "The estimation card")[
- 1 day $= 86,400$ seconds. Round it to $10^5$ when you are in a hurry.
- *1 million per day $approx$ 11.6 per second.* This single fact does most of the work.
- 1 billion per day $approx$ 11,574 per second.
- Peak is *2x to 3x* the average for a global product, *5x to 10x* for one country or one
  event (a sale, a match, a festival).
- 1 KB $times$ 1 million $= 1$ GB. 1 KB $times$ 1 billion $= 1$ TB.
- 1 Mbps $= 0.125$ MB/s. So 3 Mbps $= 0.375$ MB/s.
- A single MySQL box: ~5,000 simple writes/s, ~20,000 indexed reads/s.
- A single Redis box: ~100,000 simple ops/s.
- One machine holds ~100,000 open WebSocket connections comfortably.
]

#trick[
*The divide-by-86,400 shortcut.* Do not reach for a calculator. Write the daily count in
millions, then multiply by 11.6.

- 10M/day $= 10 times 11.6 = 116$/s.
- 200M/day $= 200 times 11.6 = 2,320$/s.
- 2,000M/day $= 2000 times 11.6 = 23,200$/s.

Check: $2,000,000,000 \/ 86,400 = 23,148$. The shortcut is within $0.3%$. Good enough for
a whiteboard, and you did it in two seconds.
]

#trap[
Never say "it depends" and stop. That is the single most common way to lose a design round.
Say "it depends on X. I will assume X is true because Y, so I choose Z. If X were false I
would choose W instead." That is one sentence longer and it is the whole difference between
a hire and a no-hire.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[A service has 40 million daily active users. Each user makes 25 requests
per day. What is the average QPS, and the peak at 3x?
#sol[
Step 1 — total requests per day.
$40,000,000 times 25 = 1,000,000,000$ requests/day.

Step 2 — divide by seconds in a day.
$1,000,000,000 \/ 86,400 = 11,574$ requests/second.

Step 3 — peak.
$11,574 times 3 = 34,722$ requests/second.
]
#ans[~11,600 QPS average, ~34,700 QPS peak]
]

#ex(2, tier: 0)[Each stored row is 250 bytes. You write 10 million rows per day. How much
storage do you need for 5 years?
#sol[
Per day: $10,000,000 times 250 = 2,500,000,000$ bytes $= 2.5$ GB/day.

Per year: $2.5 times 365 = 912.5$ GB $= 0.9125$ TB.

Five years: $0.9125 times 5 = 4.56$ TB.

Add a replication factor of 3 for durability: $4.56 times 3 = 13.7$ TB of raw disk.
]
#ans[~4.6 TB of data, ~13.7 TB of raw disk at RF 3]
]

#ex(3, tier: 0)[Base62 uses the characters `0-9`, `a-z`, `A-Z`. How many distinct strings
of exactly 7 characters exist? At 10 million new strings per day, how long until you run out?
#sol[
Step 1 — count.
$62^7 = 3,521,614,606,208 approx 3.52 times 10^12$. About 3.5 trillion.

Step 2 — days.
$3,521,614,606,208 \/ 10,000,000 = 352,161$ days.

Step 3 — years.
$352,161 \/ 365 = 965$ years.

For comparison, 6 characters gives $62^6 = 56,800,235,584 approx 5.68 times 10^10$, which is
$56,800,235,584 \/ 10,000,000 = 5,680$ days $= 15.6$ years. Still fine, but 7 is the safe
answer because it survives a 50x growth in traffic.
]
#ans[$62^7 approx 3.52$ trillion; ~965 years of runway]
]

#ex(4, tier: 0)[A token bucket has capacity 5 and refills 1 token per second. It starts
full. Requests arrive at $t = 0$ (seven of them at once), then one at $t = 2.5$s. Trace it.
#sol[
#table(columns: (auto, auto, auto, auto),
  [*Event*], [*Tokens before*], [*Decision*], [*Tokens after*],
  [$t=0$ req 1], [5.0], [allow], [4.0],
  [$t=0$ req 2], [4.0], [allow], [3.0],
  [$t=0$ req 3], [3.0], [allow], [2.0],
  [$t=0$ req 4], [2.0], [allow], [1.0],
  [$t=0$ req 5], [1.0], [allow], [0.0],
  [$t=0$ req 6], [0.0], [*deny*], [0.0],
  [$t=0$ req 7], [0.0], [*deny*], [0.0],
  [$t=2.5$ req 8], [$0 + 2.5 times 1 = 2.5$], [allow], [1.5],
)
The bucket let a *burst* of 5 through instantly. That is the point of a token bucket: it
allows bursts up to the capacity, but the long-run rate is pinned to the refill rate.
]
#ans[5 allowed, 2 denied, then allowed again at $t=2.5$s with 1.5 tokens left]
]

#ex(5, tier: 0)[8 million posts are created per day. The average author has 200 followers.
If every post is copied into every follower's inbox, how many inbox rows are written per day
and per second?
#sol[
Rows per day: $8,000,000 times 200 = 1,600,000,000$ rows/day.

Per second: $1,600,000,000 \/ 86,400 = 18,518$ rows/second average.

At 3x peak: $18,518 times 3 = 55,555$ rows/second.

Now the thing that matters: the *post* rate is only
$8,000,000 \/ 86,400 = 92.6$ posts/second. The fan-out multiplies the write load by 200.
A design that looks tiny on the write API is huge behind it.
]
#ans[1.6 billion rows/day, ~18,500/s average, ~55,500/s peak]
]

#ex(6, tier: 0)[A redirect response is about 500 bytes on the wire. You serve 11,574
redirects per second. What is the outbound bandwidth?
#sol[
$11,574 times 500 = 5,787,000$ bytes/second $= 5.787$ MB/s.

In bits: $5.787 times 8 = 46.3$ Mbps.

That is nothing. A single 1 Gbps network card handles it 20 times over. This is worth
saying out loud in the interview, because it tells the interviewer you know the bottleneck
here is *request count*, not bandwidth.
]
#ans[~5.8 MB/s, about 46 Mbps]
]

#practice(tier: 0, time: "8 min")[
+ 25M DAU, 12 requests each per day. Average QPS? Peak at 2x?
+ Rows are 1.2 KB. 4 million rows/day. Storage for 3 years at RF 3?
+ A leaky bucket drains 10 requests/second and holds 50. A burst of 90 arrives at once.
  How many are dropped?
+ 500,000 concurrent WebSocket connections, 100,000 per machine. How many machines, and
  how many if you want to survive losing one whole availability zone out of three?
]
#key[
1. $25 times 12 = 300$M/day; $300,000,000\/86,400 = 3,472$/s; peak $6,944$/s.
2. $4,000,000 times 1200 = 4.8$ GB/day; $times 365 = 1,752$ GB/yr; $times 3$ yrs $= 5,256$ GB
   $= 5.26$ TB; $times 3$ RF $= 15.8$ TB.
3. Bucket holds 50, so 50 are queued, 40 are dropped immediately. The 50 drain over
   $50\/10 = 5$ seconds.
4. $500,000\/100,000 = 5$ machines. To survive one zone of three you must run the full load
   on two zones, so provision $5 \/ (2\/3) = 7.5 arrow.r 8$ machines, spread 3/3/2.
]

#section[Tier 1 — the low-level pieces first]
#tier-header(1)

Before you design a system, you must be able to write the two or three classes at its
centre. Service-company rounds often ask *only* this part. Product-company rounds ask the
big picture but will still say "code the key generator".

#subsection[Piece 1 — a base62 encoder]

#ex(7, tier: 1, asked: "Infosys · pattern")[Write a function that turns a number into a
short string using digits, lowercase and uppercase letters. Write the reverse too.
#sol[
62 characters means base 62. The algorithm is the same one you use for binary or hex:
repeatedly take the remainder, then divide.

#code(lang: "js", caption: "base62.js — run with: node base62.js")[
```js
const ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz" +
                 "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

function toBase62(n) {
  if (n === 0) return "0";
  let s = "";
  while (n > 0) {
    s = ALPHABET[n % 62] + s;   // remainder picks the character
    n = Math.floor(n / 62);     // integer divide, then repeat
  }
  return s;
}

function fromBase62(s) {
  let n = 0;
  for (const ch of s) n = n * 62 + ALPHABET.indexOf(ch);
  return n;
}

console.log(toBase62(0));           // 0
console.log(toBase62(61));          // Z
console.log(toBase62(62));          // 10
console.log(toBase62(123456789));   // 8m0Kx
console.log(fromBase62("8m0Kx"));   // 123456789
```
]
Hand-trace `toBase62(123456789)`:

$123456789 mod 62 = 45 arrow.r$ `ALPHABET[45]` is `x`; $123456789 div 62 = 1991238$ \
$1991238 mod 62 = 36 arrow.r$ `K`; $1991238 div 62 = 32116$ \
$32116 mod 62 = 0 arrow.r$ `0`; $32116 div 62 = 518$ \
$518 mod 62 = 22 arrow.r$ `m`; $518 div 62 = 8$ \
$8 mod 62 = 8 arrow.r$ `8`; $8 div 62 = 0$, stop.

Read the characters in the order they were prepended: `8m0Kx`. Matches.
]
#complexity(time: "O(log_62 n) — 7 loops for a 7-character code",
  space: "O(1) beyond the output string")
]

#trap[
`ALPHABET.indexOf(ch)` is a linear scan of 62 characters. That is fine for a demo but in a
hot loop build a `Map` from character to value once, outside the function. Also: the decode
side is only safe while `n` stays below $2^53$. $62^9 = 1.35 times 10^16$ already exceeds
it, so a 9-character code needs `BigInt`.
]

#subsection[Piece 2 — the key generator that does not need a lock]

#ex(8, tier: 1, asked: "Capgemini · pattern")[Ten application servers all create short
links. No two may ever produce the same code. You may not take a lock on every request.
Design it, then code it.
#sol[
*The idea: hand out blocks, not numbers.* A central counter (one row in a database, or a
ZooKeeper sequence) gives a server a *range* of 1,000 IDs in one round trip. The server then
serves 1,000 requests from memory with zero coordination. When the block runs out it asks
for the next one.

Cost of coordination drops by 1,000x. If the counter is hit 116 times/second without
blocks, with blocks of 1,000 it is hit $116 \/ 1000 = 0.116$ times per second — about once
every 9 seconds.

#code(lang: "js", caption: "shortener.js — run with: node shortener.js")[
```js
class CounterRange {
  constructor(start, size) { this.next = start; this.end = start + size; }
  take() {
    if (this.next >= this.end) return null;   // block exhausted
    return this.next++;
  }
}

class RangeAllocator {          // stands in for one row in a DB / ZooKeeper
  constructor(blockSize = 1000) { this.cursor = 0; this.blockSize = blockSize; }
  allocate() {
    const start = this.cursor;              // in reality: an atomic
    this.cursor += this.blockSize;          // UPDATE ... SET c = c + 1000
    return new CounterRange(start, this.blockSize);
  }
}

class ShortenerService {
  constructor(allocator) {
    this.allocator = allocator;
    this.range = allocator.allocate();
    this.store = new Map();     // code -> longUrl
    this.byUrl = new Map();     // owner|longUrl -> code   (dedupe)
  }
  #nextId() {
    let id = this.range.take();
    if (id === null) {                       // ran out: get a fresh block
      this.range = this.allocator.allocate();
      id = this.range.take();
    }
    return id;
  }
  shorten(owner, longUrl) {
    const dedupeKey = owner + "|" + longUrl;
    if (this.byUrl.has(dedupeKey)) return this.byUrl.get(dedupeKey);
    const code = toBase62(this.#nextId()).padStart(7, "0");
    this.store.set(code, longUrl);
    this.byUrl.set(dedupeKey, code);
    return code;
  }
  resolve(code) { return this.store.get(code) ?? null; }
}
```
]
Now run two servers against one allocator, with a tiny block size of 3 so you can see the
blocks:

#code(lang: "js", caption: "the test and its real output")[
```js
const alloc = new RangeAllocator(3);
const a = new ShortenerService(alloc);   // app server A: gets ids 0,1,2
const b = new ShortenerService(alloc);   // app server B: gets ids 3,4,5

a.shorten("u1", "https://example.com/p1");  // 0000000
a.shorten("u1", "https://example.com/p2");  // 0000001
a.shorten("u1", "https://example.com/p1");  // 0000000  <- same url, same code
b.shorten("u2", "https://example.com/p3");  // 0000003  <- B's block
a.shorten("u1", "https://example.com/p4");  // 0000002  <- A's block ends
a.shorten("u1", "https://example.com/p5");  // 0000006  <- A takes a NEW block
a.resolve("0000001");                       // https://example.com/p2
a.resolve("zzzzzzz");                       // null
```
]
Read the output carefully. Server A produced 0, 1, 2 then jumped to 6. It never collided
with B's 3, 4, 5. No lock was taken on any individual request.
]
#note[
The gap from 3 to 5 is *wasted* if server A dies while holding a block. That is fine.
Wasting 1,000 keys out of 3.5 trillion, once per server crash, costs nothing. Say this in
the interview before the interviewer asks — it shows you thought about it.
]
]

#subsection[Piece 3 — a token bucket]

#ex(9, tier: 1, asked: "TCS NQT · pattern")[Code a rate limiter that allows a burst but
holds the long-run rate at $r$ requests per second.
#sol[
Do not store a list of timestamps. Store *two numbers*: how many tokens are left, and when
you last looked. Refill lazily, at read time.

#code(lang: "js", caption: "tokenbucket.js — run with: node tokenbucket.js")[
```js
class TokenBucket {
  constructor(capacity, refillPerSec) {
    this.capacity = capacity;
    this.refillPerSec = refillPerSec;
    this.tokens = capacity;
    this.lastMs = 0;
  }
  allow(nowMs, cost = 1) {
    const elapsed = (nowMs - this.lastMs) / 1000;
    // refill first, but never above capacity
    this.tokens = Math.min(this.capacity, this.tokens + elapsed * this.refillPerSec);
    this.lastMs = nowMs;
    if (this.tokens >= cost) { this.tokens -= cost; return true; }
    return false;
  }
  retryAfterMs(cost = 1) {          // what you put in the Retry-After header
    if (this.tokens >= cost) return 0;
    return Math.ceil(((cost - this.tokens) / this.refillPerSec) * 1000);
  }
}
```
]
Real output for capacity 5, refill 1/s:

#code(lang: "js", caption: "output")[
```text
burst of 7 at t=0 : true true true true true false false
retry-after       : 1000 ms
at t=2.5s         : true true false
after 60s idle    : true, tokens left 4   <- capped at 5, not 60
```
]
Three things to point at:
+ Only *two* numbers per user are stored. 16 bytes, not a list.
+ Refill is lazy. Nothing runs in the background. There is no timer.
+ The cap stops an idle user from banking 60 tokens over a minute of silence.
]
#complexity(time: "O(1) per check", space: "O(1) per key — two numbers")
]

#subsection[Piece 4 — sliding window counter]

#ex(10, tier: 1, asked: "Wipro · pattern")[A fixed one-minute window lets a user send 2x
the limit — 100 at 11:59:59 and 100 at 12:00:00. Fix it without storing every timestamp.
#sol[
Keep the *previous* window's count and the *current* window's count. Blend them by how far
into the current window you are.

$ "estimate" = "prev count" times (1 - "fraction into window") + "current count" $

#code(lang: "js", caption: "sliding.js — run with: node sliding.js")[
```js
class SlidingWindowCounter {
  constructor(limit, windowMs) {
    this.limit = limit; this.windowMs = windowMs;
    this.curStart = 0; this.cur = 0; this.prev = 0;
  }
  allow(nowMs) {
    const w = Math.floor(nowMs / this.windowMs) * this.windowMs;
    if (w > this.curStart) {
      // if we skipped a whole window, the previous one is genuinely empty
      this.prev = (w - this.curStart === this.windowMs) ? this.cur : 0;
      this.cur = 0;
      this.curStart = w;
    }
    const intoWindow = (nowMs - this.curStart) / this.windowMs;   // 0.0 .. 1.0
    const estimate = this.prev * (1 - intoWindow) + this.cur;
    if (estimate < this.limit) { this.cur++; return true; }
    return false;
  }
}
```
]
Trace with limit 5 per 10 seconds. Five requests land at $t = 9$s — all allowed, the sixth
at $t = 9.5$s is denied. Now the window rolls over at $t = 10$s.

At $t = 11$s we are $1\/10 = 0.1$ into the new window. \
Estimate $= 5 times (1 - 0.1) + 0 = 4.5$. $4.5 < 5$, so *allow*, and `cur` becomes 1. \
Second request at $t = 11$s: estimate $= 4.5 + 1 = 5.5$. Not less than 5, so *deny*. \
At $t = 19$s we are 0.9 into the window: estimate $= 5 times 0.1 + 1 = 1.5$. *Allow*.

That matches the program's output exactly:
#code(lang: "js", caption: "output")[
```text
t=9s   allowed: 5 of 5
t=9.5s 6th    : false
t=11s  allowed: true    (estimate 4.5)
t=11s  again  : false   (estimate 5.5)
t=19s  allowed: true    (estimate 1.5)
```
]
]
#complexity(time: "O(1)", space: "O(1) per key — three numbers",
  note: "Exact sliding window needs a sorted set of timestamps: O(log n) and O(limit) memory.")
]

#table(columns: (auto, 1fr, 1fr, 1fr),
  [*Algorithm*], [*Memory per key*], [*Allows bursts?*], [*Accuracy*],
  [Fixed window], [1 counter], [yes, 2x at the seam], [poor],
  [Sliding window log], [one timestamp per request], [no], [exact],
  [Sliding window counter], [3 numbers], [slightly], [within ~1%],
  [Token bucket], [2 numbers], [yes, by design], [exact on long-run rate],
  [Leaky bucket], [queue + 2 numbers], [no — smooths output], [exact],
)

*Decision.* Use *token bucket* for user-facing APIs: bursts are normal human behaviour and
you want to allow them. Use *sliding window counter* when a hard "no more than N per minute"
promise was made to a partner. Use *leaky bucket* only when the downstream cannot absorb
bursts at all, such as an SMS gateway with a fixed contracted rate.

#subsection[Piece 5 — the notification dispatcher]

#ex(11, tier: 1, asked: "Cognizant · pattern")[Design classes for a system that sends the
same message by push, SMS or email, tries channels in order, respects opt-outs, and never
sends the same notification twice.
#sol[
This is the *Strategy* pattern from Chapter 4. One interface, three implementations, and a
dispatcher that does not know or care which one it is holding.

#code(lang: "js", caption: "notifier.js — run with: node notifier.js")[
```js
class Channel {
  get name() { throw new Error("override"); }
  costPaise() { return 0; }
  async send(user, rendered) { throw new Error("override"); }
}
class PushChannel extends Channel {
  get name() { return "push"; }
  async send(user, r) {
    return user.deviceToken ? { ok: true, via: "push" }
                            : { ok: false, why: "no device token" };
  }
}
class SmsChannel extends Channel {
  get name() { return "sms"; }
  costPaise() { return 12; }                 // money! this drives the design
  async send(user, r) {
    return user.phone ? { ok: true, via: "sms" } : { ok: false, why: "no phone" };
  }
}
class EmailChannel extends Channel {
  get name() { return "email"; }
  async send(user, r) {
    return user.email ? { ok: true, via: "email" } : { ok: false, why: "no email" };
  }
}

class Template {
  constructor(id, body) { this.id = id; this.body = body; }
  render(data) { return this.body.replace(/\{(\w+)\}/g, (_, k) => data[k] ?? ""); }
}

class Notifier {
  constructor(channels, templates) {
    this.channels  = new Map(channels.map(c => [c.name, c]));
    this.templates = templates;
    this.seen = new Set();          // idempotency keys already handled
  }
  async notify(user, templateId, data, order, idemKey) {
    if (this.seen.has(idemKey)) return { skipped: "duplicate" };
    this.seen.add(idemKey);
    const rendered = this.templates.get(templateId).render(data);
    const log = [];
    for (const chName of order) {
      if (user.optOut.includes(chName)) { log.push(chName + ": opted out"); continue; }
      const ch = this.channels.get(chName);
      const res = await ch.send(user, rendered);
      log.push(chName + ": " + (res.ok ? "sent" : "failed - " + res.why));
      if (res.ok) return { text: rendered, log, paise: ch.costPaise() };
    }
    return { text: rendered, log, paise: 0, delivered: false };
  }
}
```
]
Real output, for a user with no device token but a phone number:
#code(lang: "js", caption: "output")[
```text
{ text: 'Your code is 482913. It expires in 5 minutes.',
  log: [ 'push: failed - no device token', 'sms: sent' ],
  paise: 12 }
```
]
and when the same idempotency key arrives again:
#code(lang: "js", caption: "output")[
```text
{ skipped: 'duplicate' }
```
]
Four design points the interviewer is listening for:
+ Adding WhatsApp means adding *one class*. Nothing else changes. Open for extension,
  closed for modification.
+ `costPaise()` is on the channel, so the router can prefer free channels. That is a
  business rule expressed in the type system.
+ `seen` is a `Set` here; in production it is a Redis `SET key value NX EX 86400`.
+ The fallback loop stops at the first success. The order is data, not code — a campaign
  can pass `["push","email"]` and never spend money on SMS.
]
]

#practice(tier: 1, time: "25 min")[
+ Extend `TokenBucket` so a single request can cost more than one token (an expensive search
  costs 5, a cheap read costs 1). Show the trace for capacity 10, refill 2/s, and requests
  of cost 5, 5, 5 at $t=0$ and $t=1$.
+ Write `LeakyBucket` with `push(nowMs)` returning `true` if the request was queued and
  `false` if the queue was full, plus `drain(nowMs)` removing at the fixed rate.
+ Add a `WhatsAppChannel` to the notifier with `costPaise() = 4` and a `router` method that
  picks the cheapest channel the user actually has, instead of a fixed order.
+ The `ShortenerService` currently dedupes by owner and URL in memory. Say exactly what
  breaks when there are ten servers, and give two fixes with the cost of each.
]
#key[
1. Change `allow(now, cost)` to subtract `cost`. At $t=0$: 10 tokens, cost 5 $arrow.r$ allow
   (5 left), cost 5 $arrow.r$ allow (0 left), cost 5 $arrow.r$ deny. At $t=1$: refill
   $2 times 1 = 2$, tokens 2, cost 5 $arrow.r$ deny, `retryAfter` $= (5-2)\/2 = 1.5$s.
2. Keep `queue` (an array) plus `lastMs`. `drain` removes
   `floor((now - lastMs)/1000 * rate)` items. `push` first drains, then appends only if
   `queue.length < capacity`.
3. `router(user)` filters channels the user can receive (`deviceToken`, `phone`, `email`)
   then sorts by `costPaise()` ascending. Push (0) and email (0) come first, WhatsApp (4),
   SMS (12) last.
4. Each server has its own `byUrl` map, so the same URL shortened on two servers gets two
   codes. Fix A: move the dedupe map into Redis — one extra network hop (~1 ms) per write,
   which at 116 writes/s is free. Fix B: accept the duplicate. Two codes pointing at the
   same URL is *harmless* — the redirect still works. Choose B unless the product promises
   "one link per URL", because B costs nothing.
]

#section[Design 1 — a URL shortener]
#tier-header(2)

#ex(12, tier: 2, asked: "Shopee · pattern")[Design a service that turns a long link into a
short one and redirects. Support custom aliases, link expiry, and per-link click counts.
#sol[

#subsection[Step 1 — Clarify]

#table(columns: (1fr, 1fr),
  [*Question I ask*], [*Why the answer changes the design*],
  [How many new links per day?], [Decides the key length and whether one database is enough.],
  [What is the read-to-write ratio?], [If reads dominate, the whole design becomes a cache design.],
  [Do links ever expire?], [Expiry means a TTL and a background cleaner, or a lazy delete on read.],
  [Can users pick their own alias?], [Custom aliases need a uniqueness check — a different write path.],
  [Do we need click analytics in real time?], [Real time forces a stream. "Within 5 minutes" lets you batch.],
  [Must the same long URL always give the same short one?], [If yes, you need a global dedupe index, which is a second database.],
)

Answers I will assume, stated out loud: *10 million new links/day*, *read:write is 100:1*,
*links expire after a default 2 years*, *custom aliases allowed*, *click counts may lag by
5 minutes*, *no global dedupe required*.

#subsection[Step 2 — Scale estimate]

*Writes.*
$ 10,000,000 \/ 86,400 = 115.7 approx 116 "writes/second" $
Peak at 3x: $116 times 3 = 348$ writes/second.

*Reads.* 100:1 means $10,000,000 times 100 = 1,000,000,000$ redirects/day.
$ 1,000,000,000 \/ 86,400 = 11,574 "reads/second" $
Peak at 3x: $11,574 times 3 = 34,722$ reads/second.

*Storage.* One row: short code 7 B, long URL up to 2 KB but ~180 B typical, owner id 8 B,
created 8 B, expires 8 B, flags 4 B. Round to *250 bytes* with row overhead.
$ 10,000,000 times 250 = 2,500,000,000 "B" = 2.5 "GB/day" $
$ 2.5 times 365 = 912.5 "GB/year" approx 0.91 "TB/year" $
Five years: $0.91 times 5 = 4.6$ TB. At replication factor 3: $4.6 times 3 = 13.7$ TB raw.

*Key space.* 7 base62 characters give $62^7 = 3,521,614,606,208$ codes.
$ 3,521,614,606,208 \/ 10,000,000 = 352,161 "days" = 965 "years" $

*Bandwidth.* Redirect response ~500 B:
$11,574 times 500 = 5.79$ MB/s outbound. Trivial.

*Cache.* Suppose 20 million distinct links are hit on a given day and the hottest 20% serve
most traffic. Cache 20 million rows: $20,000,000 times 250 = 5,000,000,000$ B $= 5$ GB.
That fits in one Redis node's memory with room to spare.

#formulas(title: "The one-line summary you put on the board")[
348 writes/s peak · 34,722 reads/s peak · 0.91 TB/year · 5 GB hot cache · 965 years of keys.
*Read-heavy, tiny data, no bandwidth problem.* Therefore: cache first, database second.
]

#subsection[Step 3 — API surface]

#code(lang: "text", caption: "the four endpoints that matter")[
```text
POST /v1/links
  body   { "url": "https://example.com/a/very/long/path?x=1",
           "alias": "sale24",          // optional
           "expiresAt": "2027-01-01T00:00:00Z" }
  header Idempotency-Key: 9f2c-...     // safe to retry
  201    { "code": "8m0Kx2p", "shortUrl": "https://sho.rt/8m0Kx2p" }
  409    { "error": "alias_taken" }

GET  /{code}
  302    Location: https://example.com/a/very/long/path?x=1
         Cache-Control: private, max-age=0      // see the note on 301 below
  404    when the code does not exist
  410    when the link existed but has expired

GET  /v1/links/{code}/stats?from=2026-09-01&to=2026-09-15
  200    { "total": 48213, "byDay": [...], "topCountries": [...] }

DELETE /v1/links/{code}
  204
```
]

#trap[
*301 versus 302.* A 301 is a permanent redirect. Browsers cache it forever, so your click
counter stops counting after the first visit and you can never change or delete the link.
A 302 is temporary: the browser asks again every time. You pay in QPS and you get analytics
and the ability to revoke. *Decision: use 302.* We are read-heavy but our reads are cheap
(a cache hit) and analytics is a product requirement. If analytics were dropped and cost
mattered more, 301 would cut read traffic by perhaps 80%.
]

#subsection[Step 4 — Data model]

#table(columns: (auto, auto, 1fr),
  [*Field*], [*Type*], [*Note*],
  [`code`], [char(7)], [*partition key*. Random-looking, so writes spread evenly.],
  [`long_url`], [varchar(2048)], [the destination],
  [`owner_id`], [bigint], [null for anonymous links],
  [`created_at`], [timestamp], [],
  [`expires_at`], [timestamp], [null means never. Used as a TTL by the store.],
  [`is_custom`], [bool], [custom aliases cannot be recycled],
)

Second table, written by a stream job, never on the hot path:
#table(columns: (auto, auto, 1fr),
  [*Field*], [*Type*], [*Note*],
  [`code`], [char(7)], [*partition key*],
  [`day`], [date], [*sort key* — so a date-range query is one contiguous scan],
  [`clicks`], [counter], [incremented in batches],
  [`country`], [map], [country code $->$ count],
)

*Which database?* The access pattern is: given one key, fetch one row. There are no joins,
no range scans, no transactions across rows. That is the exact shape a key-value store is
best at. *Decision: a wide-column / KV store such as Cassandra or DynamoDB, partitioned on
`code`.* A relational database would also work at this size, but sharding it by hand at 10x
is work we can avoid by choosing right the first time.

*Why not hash the URL?* `md5(url)` truncated to 7 characters looks clever and fails. With
3.5 trillion slots and 10 million inserts per day, the birthday bound says collisions start
appearing after roughly $sqrt(3.5 times 10^12) approx 1.9$ million inserts — that is *within
the first day*. You would need a read-before-write on every insert to detect them, which is
exactly the coordination we were trying to avoid. The counter-block scheme from Example 8
has *zero* collisions by construction.

#subsection[Step 5 — Architecture]

#diagram(height: 5.4cm, caption: "Read path along the top, write path along the bottom. The two share nothing but the store.")[
  #dnode(0pt, 58pt, 70pt, 28pt, "Client")
  #dnode(95pt, 58pt, 70pt, 28pt, "API gateway\n+ LB")
  #dnode(190pt, 8pt, 70pt, 28pt, "Redirect\nservice")
  #dnode(190pt, 108pt, 70pt, 28pt, "Write\nservice")
  #dnode(285pt, 8pt, 70pt, 28pt, "Redis\n(LRU, 5 GB)")
  #dnode(285pt, 108pt, 70pt, 28pt, "ID block\nservice")
  #dnode(385pt, 58pt, 70pt, 28pt, "KV store\nRF 3")
  #darrow(70pt, 72pt, 95pt, 72pt)
  #darrow(160pt, 66pt, 190pt, 30pt, label: "GET")
  #darrow(160pt, 80pt, 190pt, 110pt, label: "POST")
  #darrow(260pt, 22pt, 285pt, 22pt)
  #darrow(355pt, 24pt, 385pt, 60pt, label: "miss")
  #darrow(260pt, 122pt, 285pt, 122pt, label: "block")
  #darrow(245pt, 108pt, 420pt, 88pt, label: "insert")
]

Trace one redirect:
+ `GET /8m0Kx2p` reaches the gateway.
+ The gateway routes it to a redirect service pod. No session, no state — any pod will do.
+ The pod asks Redis for key `u:8m0Kx2p`. *Hit (98% of the time)*: return `302` in ~1 ms.
+ *Miss*: read the KV store (~5 ms), write it back into Redis with a TTL, return `302`.
+ Either way, push a click event onto Kafka and return. The return does *not* wait for
  Kafka's ack — analytics is allowed to lose an event, the redirect is not allowed to be slow.

Trace one create:
+ `POST /v1/links` with an `Idempotency-Key`.
+ The write service checks its in-memory ID block; takes the next ID, or fetches a fresh
  block of 1,000 if empty.
+ Encode to base62, pad to 7 characters, insert into the KV store with
  `IF NOT EXISTS` (cheap, because a collision is impossible — it is a belt-and-braces check).
+ Return `201`. Do *not* warm the cache; a brand-new link is usually not read immediately,
  and if it is, the first read costs 5 ms once.

#subsection[Step 6 — Deep dive]

*Deep dive A: the cache is the system.*

At 34,722 peak reads/second, the KV store would need to serve all of them if the cache were
empty. Cassandra at ~20,000 reads/s/node would need
$34,722 \/ 20,000 = 1.74 arrow.r$ 2 nodes just for reads, before replication. With a 98% hit
rate the store only sees
$34,722 times 0.02 = 694$ reads/second. That is one node, half asleep.

So the interesting question is *what happens when the cache is cold* — a Redis restart, or a
new region coming online. All 34,722 reads/s hit the store at once. Two defences:

+ *Request coalescing.* If 500 requests for the same missing key arrive in the same
  millisecond, only one goes to the store; the other 499 wait on the same promise. This turns
  a thundering herd into a single read.
+ *Warm-start.* Before routing traffic to a restarted cache node, replay the top 1 million
  codes from a daily-generated list. $1,000,000 times 250 "B" = 250$ MB, which loads in well
  under a minute.

*Deep dive B: custom aliases without a lock.*

Generated codes cannot collide. Custom aliases *can* — two users both want `sale24`. The
fix is a conditional write, not a read-then-write:

#code(lang: "text", caption: "the only safe order")[
```text
WRONG:  if (!exists(alias)) { insert(alias) }      <- two writers both see "not exists"
RIGHT:  INSERT ... IF NOT EXISTS                    <- the store decides, atomically
        on failure -> 409 alias_taken
```
]
Reserve a separate namespace so a custom alias can never be handed out by the counter:
generated codes are always exactly 7 characters; custom aliases must be 4 to 6 characters or
8 or more. Now the two key spaces cannot overlap, and you never need to check one against
the other.

*Deep dive C: counting clicks without slowing redirects.*

A naive `UPDATE links SET clicks = clicks + 1` on every redirect adds 34,722 writes/second
to a store that was doing 116. It also makes every popular link a single hot row.

Instead: the redirect pod keeps a local `Map` of `code -> count` and flushes it to Kafka
every 10 seconds. With 200 pods and, say, 50,000 distinct codes per pod per flush, that is
$200 times 50,000 \/ 10 = 1,000,000$ counter-deltas per second sent as *batched* messages —
a few thousand Kafka messages per second, not a million. A stream job aggregates by
`(code, day)` and writes one row per code per hour.

Cost of this choice: counts lag by up to 10 seconds plus the stream lag, and a pod crash
loses at most 10 seconds of counts for that pod. We accepted a 5-minute lag in Step 1, and
losing 10 seconds of clicks out of a day is a $10\/86,400 = 0.012%$ error. Fine.

#subsection[Step 7 — Trade-offs, failures, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Code generation], [hash the URL], [counter + base62], [*B* — zero collisions, no read-before-write],
  [Redirect status], [301 permanent (cheap)], [302 temporary (countable)], [*B* — analytics and revocation are required],
  [Store], [relational], [key-value], [*B* — the access pattern is pure key lookup],
  [Click counting], [synchronous increment], [batch to a stream], [*B* — 300x fewer store writes for 10 s of lag],
  [Cache write policy], [write-through on create], [lazy fill on first read], [*B* — most new links are never read],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [Redis node dies], [Latency rises from 1 ms to 6 ms], [Consistent hashing spreads the loss;
   only $1\/N$ of keys are cold. Requests coalesce so the store is not flooded.],
  [Whole cache tier dies], [Slow but working], [Store is sized for 100% miss at *average*
   (11,574/s), not peak; shed 20% of traffic with 429s during the warm-up if needed.],
  [ID block service dies], [Creates fail, redirects fine], [Each write pod holds up to 1,000
   unused IDs — roughly 1,000 / 348 per second $approx$ 3 seconds of headroom at peak. Raise
   the block to 10,000 for ~29 seconds. Then fail writes with 503 and let clients retry.],
  [KV node dies], [Nothing], [RF 3 with quorum reads. Two replicas are enough.],
  [A single link goes viral], [Nothing], [It is one cache key served from memory; that is the
   best case, not the worst.],
)

*At 10x (100 million new links/day, 10 billion redirects/day):*
- Reads become $10,000,000,000 \/ 86,400 = 115,740$/s average, $347,222$/s at peak.
- The cache grows to ~50 GB. One Redis node no longer holds it: shard by `code` across
  8 nodes of ~8 GB each.
- Storage becomes $9.1$ TB/year. Still small. Add nodes for throughput, not capacity.
- The genuinely new problem is *geography*. At 347k reads/s worldwide, a user in Jakarta
  should not be redirected by a server in Virginia. Move redirect pods and cache to 5 regions,
  replicate the KV store asynchronously, and accept that a link created in one region may be
  unknown in another for a few seconds. Handle the miss by falling back to the home region
  once. The alternative — synchronous global replication — would add 150 ms to every *write*
  to save a rare 150 ms on a read. Wrong trade. *Decision: async replication with a
  cross-region fallback read.*
]
]

#section[Design 2 — a rate limiter for a public API]
#tier-header(2)

#ex(13, tier: 2, asked: "Agoda · pattern")[Design the rate limiter that sits in front of a
public API. 2 billion requests a day, 40 million distinct callers, and the limit must hold
across every gateway machine at once.
#sol[

#subsection[Step 1 — Clarify]

#table(columns: (1fr, 1fr),
  [*Question I ask*], [*Why the answer changes the design*],
  [What is limited — a user, an API key, an IP, or one endpoint?],
    [It decides the key, and therefore how many keys exist and how much memory they need.],
  [One global limit, or a limit per plan?],
    [Per plan means the limit is *data*, looked up per request, so it needs its own cache.],
  [Must the limit be exact, or is a 10% overshoot acceptable?],
    [Exact costs one round trip per request. 10% buys you a local cache and 20x less traffic.],
  [What happens if the limiter store is down — allow or block?],
    [This is a product decision, not an engineering one, and it must be made before the outage.],
  [Are bursts normal?],
    [Yes $->$ token bucket (Piece 3). "Never more than N per minute" $->$ sliding window (Piece 4).],
  [Does the limiter run inside the gateway or as its own service?],
    [A separate service adds a network hop to *every* request in the company.],
)

Answers I will assume, said out loud: *limit per API key per endpoint group*; *three plans —
free 60/min, paid 600/min, partner 6,000/min*; *up to 10% overshoot is acceptable*; *bursts
are allowed*; *the limiter is a library inside the gateway process*, with a shared store
behind it; *if the store is unreachable we fail open with a local fallback*.

#subsection[Step 2 — Scale estimate]

*Checks per second.* Every request is checked, so the check rate *is* the request rate.
$ 2,000,000,000 \/ 86,400 = 23,148 "checks/second" $
Peak at 3x: $23,148 times 3 = 69,444$ checks/second.

*How many keys.*
$ 2,000,000,000 \/ 40,000,000 = 50 "requests per caller per day" $
Traffic is not spread evenly over 24 hours. Take an eighth of the day's callers as active in
the busiest hour: $40,000,000 \/ 8 = 5,000,000$ live keys.

*Memory.* A token bucket is two numbers — tokens left and last-seen time, 16 bytes. With the
key string and store overhead, call it *100 bytes* per key.
$ 5,000,000 times 100 = 500,000,000 "B" = 500 "MB" $
That fits in one Redis node's memory easily.

*Throughput is the real constraint, not memory.* One Redis box does about 100,000 simple
ops/second.
$ 69,444 \/ 100,000 = 69% "of one box" $
69% leaves no headroom and no failover. Shard by key across 4 nodes:
$ 69,444 \/ 4 = 17,361 "ops/second per node" = 17% "loaded" $

*Latency.* The API promises a p99 of 80 ms. A same-datacentre Redis round trip is about
0.5 ms.
$ 0.5 \/ 80 = 0.6% "of the latency budget" $
Acceptable — but we will spend far less than that in Step 6.

#formulas(title: "The one-line summary you put on the board")[
69,444 checks/s peak · 5 million live keys · 500 MB of state · 4 store shards at 17% ·
0.5 ms added to an 80 ms budget.

*Memory is trivial. Throughput and the atomicity of one check are the whole problem.*
]

#subsection[Step 3 — API surface]

A rate limiter has almost no API of its own. Its interface is a *header contract*, and that
contract is what your users actually integrate against.

#code(lang: "text", caption: "the header contract, plus the two admin endpoints")[
```text
Every response from the gateway carries:
  X-RateLimit-Limit:      600            requests allowed in the window
  X-RateLimit-Remaining:  417            tokens left right now
  X-RateLimit-Reset:      1789412460     unix seconds when it is full again

When the caller is over the limit:
  HTTP 429 Too Many Requests
  Retry-After: 3                          seconds — computed, never guessed
  { "error": "rate_limited", "scope": "key:ak_31f2", "limit": 600,
    "window": "1m", "retryAfterMs": 2840 }

GET  /v1/limits/{apiKey}
  200  { "plan":"paid", "rules":[ {"group":"search","limit":600,"windowSec":60},
                                  {"group":"write", "limit":60, "windowSec":60} ] }

PUT  /v1/limits/{apiKey}
  body { "plan":"partner", "overrides":{ "search": 12000 } }
  200  { "appliedAt":"2026-09-15T04:10:00Z", "propagationSec":60 }
```
]

#trap[
*`Retry-After` must be computed, not invented.* A fixed `Retry-After: 60` makes every blocked
client wake up at the same second and hit you together — you have built a synchronised herd
out of your own error responses. Compute it from the bucket, as `retryAfterMs()` in Piece 3
does, and then add a random 0 to 20% jitter so two clients blocked in the same millisecond do
not return in the same millisecond.
]

#subsection[Step 4 — Data model]

#table(columns: (auto, auto, 1fr),
  [*Key*], [*Value*], [*Note*],
  [`rl:{apiKey}:{group}`], [hash: `tokens`, `lastMs`],
    [*the only hot key*. TTL 3600 s, so idle callers cost nothing.],
  [`plan:{apiKey}`], [string: plan name + overrides],
    [read once per minute per gateway pod, then cached in process],
  [`rules:{plan}:{group}`], [string: limit, windowSec],
    [changes a few times a year; a 60-second cache is plenty],
)

*Which store?* The access pattern is: one key, read-modify-write, 69,444 times a second,
with a hard requirement that the read and the write are one indivisible step. That is exactly
what a single-threaded in-memory store with server-side scripting is for.
*Decision: Redis, sharded by `apiKey`, with the whole check written as one Lua script.*

A relational database would give the same atomicity with `SELECT ... FOR UPDATE`, but at
69,444 row locks a second on the same few hot rows it would spend all its time in lock
contention, and a MySQL box does ~5,000 writes/s, so you would need
$69,444 \/ 5,000 = 14$ nodes to do what 4 Redis nodes do at 17% load.

#note[
Redis scripting is Lua, and that is not a JavaScript decision we can talk our way out of — it
is what the server runs. The rule from the language policy applies: the *concept* is a token
bucket, which you write in JavaScript to think about it, and the *deployment* is four lines
of Lua because atomicity has to happen inside the store.
]

#subsection[Step 5 — Architecture]

#diagram(height: 5.8cm, caption: "The check happens inside the gateway pod. The store is touched once per lease, not once per request. Plan config is cached in process for 60 seconds.")[
  #dnode(0pt, 46pt, 66pt, 26pt, "Callers\n40 M keys")
  #dnode(86pt, 6pt, 84pt, 26pt, "Gateway pod 1\n+ local lease")
  #dnode(86pt, 46pt, 84pt, 26pt, "Gateway pod 2\n+ local lease")
  #dnode(86pt, 86pt, 84pt, 26pt, "Gateway pod 20\n+ local lease")
  #dnode(206pt, 44pt, 84pt, 30pt, "Limiter store\n4 shards · 500 MB", fill: rgb("#dbe7c9"))
  #dnode(330pt, 6pt, 88pt, 26pt, "Upstream API")
  #dnode(330pt, 86pt, 88pt, 26pt, "429 + Retry-After", fill: rgb("#f7e3e3"))
  #dnode(0pt, 108pt, 84pt, 24pt, "Plan config\ncached 60 s", fill: rgb("#f0ece2"))

  #darrow(66pt, 52pt, 86pt, 19pt)
  #darrow(66pt, 59pt, 86pt, 59pt)
  #darrow(66pt, 66pt, 86pt, 99pt)
  #darrow(170pt, 19pt, 206pt, 50pt)
  #darrow(170pt, 59pt, 206pt, 59pt)
  #darrow(170pt, 99pt, 206pt, 68pt)
  #darrow(170pt, 12pt, 330pt, 12pt)
  #darrow(170pt, 106pt, 330pt, 99pt)
  #darrow(84pt, 116pt, 112pt, 112pt, dashed: true)

  #place(dx: 176pt, dy: 30pt)[#text(size: 7.5pt, fill: dc)[lease 20]]
  #place(dx: 176pt, dy: 84pt)[#text(size: 7.5pt, fill: dc)[lease 20]]
  #place(dx: 240pt, dy: 2pt)[#text(size: 7.5pt, fill: dc)[allow]]
  #place(dx: 240pt, dy: 86pt)[#text(size: 7.5pt, fill: dc)[deny]]

  #place(dx: 0pt, dy: 140pt)[#text(size: 8pt, fill: muted)[Every arrow into the store is a lease of 20 tokens, so 20 requests cost one round trip. Under the limit that is 20x fewer store calls.]]
]

Trace one request:
+ A request arrives at gateway pod 7 with `Authorization: Bearer ak_31f2`.
+ The pod resolves the plan from its in-process cache (refreshed every 60 s). Zero network.
+ The pod looks in its own memory for an unused lease of tokens for that key.
+ *Lease available:* decrement it and forward upstream. Cost: one map lookup, ~0.01 ms.
+ *No lease:* run the Lua script on the right shard, which refills the bucket and hands back
  up to 20 tokens in one round trip. Cost: ~0.5 ms, once per 20 requests.
+ *Store returns zero tokens:* return 429 with a computed `Retry-After`, and stop asking that
  shard for 200 ms so a blocked caller does not turn into a store-hammering loop.

#subsection[Step 6 — Deep dive]

*Deep dive A: counting per-server is the classic wrong answer.*

You have 20 gateway pods. Two tempting shortcuts, both broken:

#table(columns: (auto, 1fr, auto),
  [*Shortcut*], [*What happens*], [*Error*],
  [Each pod keeps the *full* limit],
    [A caller spread evenly across pods gets $20 times 600 = 12,000$/min instead of 600.],
    [*20x too many*],
  [Each pod keeps $"limit" \/ N$],
    [$600 \/ 20 = 30$ per pod. A caller on one keep-alive connection is pinned to one pod and
     gets 30 instead of 600.], [*95% too few*],
)

$1 - 30\/600 = 95%$. Both failures are large, and both are invisible in testing with one pod.
*The count has to be shared. The only question left is how often you touch the shared thing.*

*Deep dive B: a check is not a read followed by a write.*

Here is the bug, made visible. Two versions of the same limiter, both against the same fake
store, 50 concurrent requests, limit 10.

#code(lang: "js", caption: "ratelimit-race.js — run with: node ratelimit-race.js")[
```js
class FakeRedis {
  constructor() { this.m = new Map(); }
  async get(k) { await tick(); return this.m.get(k) ?? 0; }   // a network hop
  async set(k, v) { await tick(); this.m.set(k, v); }         // another one
  // ONE round trip that reads, decides and writes with nothing in between
  async incrIfBelow(k, limit) {
    await tick();
    const cur = this.m.get(k) ?? 0;
    if (cur >= limit) return { allowed: false, count: cur };
    this.m.set(k, cur + 1);
    return { allowed: true, count: cur + 1 };
  }
}
const tick = () => new Promise(r => setImmediate(r));

async function unsafe(redis, key, limit) {
  const n = await redis.get(key);        // <- the gap opens here
  if (n >= limit) return false;
  await redis.set(key, n + 1);           // <- everyone writes the same value
  return true;
}
async function safe(redis, key, limit) {
  return (await redis.incrIfBelow(key, limit)).allowed;
}

async function race(fn, label) {
  const redis = new FakeRedis();
  const results = await Promise.all(
    Array.from({ length: 50 }, () => fn(redis, "u:7", 10)));
  console.log(`${label}: limit 10, 50 concurrent -> allowed ` +
              `${results.filter(Boolean).length}, stored ${redis.m.get("u:7")}`);
}
await race(unsafe, "read-modify-write");
await race(safe,   "atomic check-and-incr ");
```
]

#code(lang: "js", caption: "actual output")[
```text
read-modify-write: limit 10, 50 concurrent -> allowed 50, stored 1
atomic check-and-incr : limit 10, 50 concurrent -> allowed 10, stored 10
```
]

Read that first line twice. Every one of the 50 requests was allowed against a limit of 10,
*and the stored counter says 1*. All 50 read 0, all 50 wrote 1. The limiter did not slow
anything down and did not know it had failed. In production this only appears under load,
which is precisely when you need it.

The fix is not a lock. It is doing the whole check *inside the store*:

#code(lang: "text", caption: "the token bucket of Piece 3, moved into the store")[
```text
-- KEYS[1] = rl:{apiKey}:{group}   ARGV = now_ms, capacity, refill_per_sec, want
local b       = redis.call('HMGET', KEYS[1], 'tokens', 'last')
local tokens  = tonumber(b[1]) or tonumber(ARGV[2])
local last    = tonumber(b[2]) or tonumber(ARGV[1])
local elapsed = (tonumber(ARGV[1]) - last) / 1000
tokens = math.min(tonumber(ARGV[2]), tokens + elapsed * tonumber(ARGV[3]))
local give = math.min(tonumber(ARGV[4]), math.floor(tokens))
tokens = tokens - give
redis.call('HMSET', KEYS[1], 'tokens', tokens, 'last', ARGV[1])
redis.call('EXPIRE', KEYS[1], 3600)
return give
```
]

It is the same arithmetic as the `TokenBucket` class in Piece 3, character for character. The
only thing that changed is *where it runs*. Redis executes one script start to finish before
touching another command, so there is no gap for a second request to slip into.

*Deep dive C: the lease — Piece 2's trick, applied to tokens.*

At 69,444 checks/second, one store call per check is 69,444 ops/s. The key-block idea from
Example 8 works here without modification: instead of asking for one token, ask for *twenty*
and spend them locally.

#code(lang: "js", caption: "lease-limiter.js — run with: node lease-limiter.js")[
```js
class CentralBucket {              // ONE Redis key, touched by one atomic script
  constructor(capacity, refillPerSec) {
    this.capacity = capacity; this.refillPerSec = refillPerSec;
    this.tokens = capacity; this.lastMs = 0; this.calls = 0;
  }
  lease(nowMs, want) {             // hand out up to `want` tokens in one round trip
    this.calls++;
    const elapsed = (nowMs - this.lastMs) / 1000;
    this.tokens = Math.min(this.capacity, this.tokens + elapsed * this.refillPerSec);
    this.lastMs = nowMs;
    const given = Math.min(want, Math.floor(this.tokens));
    this.tokens -= given;
    return given;
  }
}

class GatewayLimiter {             // lives inside each gateway process
  constructor(central, leaseSize = 20) {
    this.central = central; this.leaseSize = leaseSize;
    this.held = 0; this.quietUntil = -1;
  }
  allow(nowMs) {
    if (this.held === 0 && nowMs >= this.quietUntil) {
      this.held = this.central.lease(nowMs, this.leaseSize);
      if (this.held === 0) this.quietUntil = nowMs + 200;  // empty: stop asking
    }
    if (this.held === 0) return false;
    this.held--;
    return true;
  }
}

function run(total, label) {
  const central = new CentralBucket(600, 600);         // 600/s, burst 600
  const gws = Array.from({ length: 20 }, () => new GatewayLimiter(central, 20));
  let allowed = 0, denied = 0;
  for (let i = 0; i < total; i++) {
    const nowMs = (i / total) * 1000;                  // spread over one second
    gws[i % 20].allow(nowMs) ? allowed++ : denied++;
  }
  console.log(`${label}: allowed ${allowed}, denied ${denied}, ` +
    `central touched ${central.calls} -> ${(total / central.calls).toFixed(1)}x fewer`);
}
run(400,  "under the limit (400/s)");
run(2000, "over  the limit (2000/s)");
```
]

Twenty gateway pods, run twice. The demo uses a scaled-up limit of 600 per *second* with a
burst of 600, so that one simulated second shows the whole behaviour:

#code(lang: "js", caption: "actual output")[
```text
under the limit (400/s): allowed 400, denied 0,   central touched  20 -> 20.0x fewer
over  the limit (2000/s): allowed 1199, denied 801, central touched 410 ->  4.9x fewer
```
]

Three things to point at, and the third is the one that scores:
+ Under the limit the store is touched 20 times instead of 400. That is the $69,444 \/ 20
  = 3,472$ ops/second version of our peak, which is 3% of a single Redis box.
+ 1,199 allowed in the overload run is *correct*, not a bug: a full bucket of 600 plus 600
  refilled during that second is 1,200.
+ Over the limit the saving shrinks to 4.9x, because once the bucket is dry the leases come
  back partial and pods ask more often. *The lease helps most when you need it least.* That is
  why the 200 ms quiet period exists — without it, the one caller who is being blocked
  generates more store traffic than all the callers who are being served.

#formulas(title: "What the 10% overshoot actually buys, in one line")[
A pod holding an unused lease of 20 that crashes destroys those 20 tokens; a pod holding a
lease across a second boundary spends them slightly late. With 20 pods and leases of 20, the
worst-case error is $20 times 20 = 400$ tokens against the paid plan's limit of 600 per
minute — a 67% overshoot, far outside the 10% we promised. Set
the lease to $600 \/ (20 times 10) = 3$ for a 10% bound, or keep leases of 20 only for the
partner plan at 6,000/min. *Decision: lease size $= max(1, "limit" \/ (N times 10))$,
computed per plan.* The free plan at 60/min gets a lease of 1 and pays the full round trip;
it is 3% of traffic and nobody notices.
]

#subsection[Step 7 — Trade-offs, failures, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Where the count lives], [per gateway pod], [shared store],
    [*B* — per-pod is 20x too high or 95% too low, and both hide in testing],
  [The check itself], [read, decide, write], [one atomic script in the store],
    [*B* — the race is silent and only appears under load],
  [Algorithm], [sliding window counter], [token bucket],
    [*B* — bursts are normal for an API client; we promised a rate, not a shape],
  [Store traffic], [one call per request], [lease a block of tokens],
    [*B* — 20x fewer calls under the limit, for a bounded 10% overshoot],
  [Limiter placement], [its own service], [a library in the gateway],
    [*B* — a separate service adds a hop to every request in the company],
  [When the store is down], [fail closed], [fail open with a local cap],
    [*B* — see below; a limiter outage must not become an API outage],
)

*The fail-open decision, in full.* If the limiter store is unreachable, blocking everything
turns a limiter incident into a total outage — the limiter is now the least reliable thing in
the request path and it can take down a healthy API. Allowing everything invites abuse for
the length of the outage. *Decision: fail open, but not blindly.* Each pod falls back to a
purely local token bucket at $"limit" \/ N$ per key. With 20 pods that caps the worst case at
the true limit, penalises nobody in the normal case, and needs no store at all. The two
exceptions are hard-coded to fail *closed*: the login endpoint and the OTP endpoint, where
unlimited traffic is not a cost problem but a security one.

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the caller sees*], [*What we do*],
  [One store shard dies],
    [A quarter of keys lose their count],
    [Those keys fall back to the local bucket at $"limit"\/N$. The other three quarters are
     unaffected, because the shard key is the API key.],
  [The whole store tier dies],
    [Nothing, briefly],
    [Fail open with local caps. Alarm immediately: we are now enforcing an approximation, and
     that must never be allowed to be the quiet normal state.],
  [A gateway pod crashes holding leases],
    [Nothing],
    [Up to 20 tokens per key are lost. At a 600/s limit that is 3% of one second. Leases
     expire by refill anyway; no cleanup code exists or is needed.],
  [One API key sends 50,000 requests/second],
    [That key gets 429s],
    [It is one hot store key on one shard. Add a per-key circuit breaker: after 60 seconds
     over the limit, stop calling the store for it entirely and deny locally for 5 minutes.],
  [A plan change is made],
    [Takes effect within 60 s],
    [Config is cached per pod for 60 seconds. Instant propagation would mean reading config
     on every request — 69,444 extra reads/second to make a yearly event faster.],
  [Clock skew between pods],
    [Small overshoot],
    [The refill arithmetic uses *elapsed* time from the store's own clock inside the script,
     not the pod's clock. Pods never write a timestamp.],
)

*At 10x (20 billion requests/day):*
- Checks become $20,000,000,000 \/ 86,400 = 231,481$/s average and $694,444$/s at peak.
- Without leases that is $694,444 \/ 100,000 = 7$ Redis nodes saturated. With leases of 20 it
  is $694,444 \/ 20 = 34,722$ ops/s — *one node's worth of work*. Run 3 for failure
  tolerance, not for throughput. This is the whole payoff of Deep dive C.
- Live keys become 50 million, so state becomes $50,000,000 times 100 = 5$ GB. Still small,
  but now it must be sharded for memory as well as for throughput.
- The genuinely new problem is *geography*. With gateways in 5 regions, a globally exact
  limit needs a cross-region round trip of ~150 ms on every lease, which is 300x the local
  cost. *Decision: split the limit between regions in proportion to each region's traffic
  over the last 5 minutes, recomputed every minute, and enforce locally.* A caller who moves
  region can exceed their limit for up to one minute. We accept that: the alternative is
  putting a 150 ms intercontinental hop in front of every request in the company to make an
  approximate number slightly less approximate.
]
]

#section[Design 3 — a notification system]
#tier-header(2)

#ex(14, tier: 2, asked: "Grab · pattern")[Design the service that sends every push, SMS and
email in the company. 500 million notifications a day, three third parties that all fail
sometimes, and a marketing team that wants to send 20 million messages in ten minutes.
#sol[

#subsection[Step 1 — Clarify]

#table(columns: (1fr, 1fr),
  [*Question I ask*], [*Why the answer changes the design*],
  [What classes of notification exist?],
    [OTP, transactional and marketing have different deadlines. One queue cannot serve all three.],
  [What is the latency promise for each class?],
    [An OTP under 10 seconds is a hard product requirement. Marketing is "today".],
  [What is the biggest single send?],
    [The peak here is *self-inflicted*. A 20 million blast is scheduled by us, not by users.],
  [Who owns the opt-out, and is it per channel or global?],
    [It is a legal requirement, so it must be checked at send time, not at campaign time.],
  [Do the providers give delivery receipts?],
    [Yes $->$ a whole second inbound stream, and "sent" stops meaning "delivered".],
  [Do we pay per message?],
    [SMS costs money. That single fact reorders every channel decision in the system.],
)

Assumed and said out loud: *500 million notifications/day*; *70% push, 25% email, 5% SMS*;
*largest blast 20 million in 10 minutes*; *opt-out is per channel per category*; *receipts
arrive by webhook*; *SMS costs 12 paise a message*, as in Piece 5.

#subsection[Step 2 — Scale estimate]

*Average rate.*
$ 500,000,000 \/ 86,400 = 5,787 "notifications/second" $

*The blast.*
$ 20,000,000 \/ 600 "s" = 33,333 "notifications/second" $
$ 33,333 \/ 5,787 = 5.76 times "the average" $
Note what kind of peak this is. Nobody surprised us. *We* pressed the button. So the answer is
not "provision for 33,333/s" — it is "shape it", which is much cheaper.

*Channel volumes.*
$ 500,000,000 times 0.70 = 350,000,000 "push" quad times 0.25 = 125,000,000 "email" $
$ 500,000,000 times 0.05 = 25,000,000 "SMS" $

*What the SMS costs.*
$ 25,000,000 times 12 "paise" = 300,000,000 "paise" = 3,000,000 "rupees/day" $
$ 3,000,000 times 365 = 1,095,000,000 "rupees" = 109.5 "crore per year" $
Say that number out loud. It is the largest number in the design and it is not a
latency, a byte or a QPS — it is a bill. Moving 20% of non-OTP SMS to push saves
$17,000,000 times 0.2 times 12 = 40,800,000$ paise $= 408,000$ rupees a day, about
14.9 crore a year, which is why `costPaise()` sits on the channel class in Piece 5.

*SMS capacity is contracted, not elastic.* Two providers at 500 messages/second each
$= 1,000$/s total, and that number is in a contract you cannot exceed by asking nicely.
OTP volume is 8 million/day:
$ 8,000,000 \/ 86,400 = 92.6 "OTP/second average" quad times 5 = 463 "at peak" $
$ 1,000 - 463 = 537 "SMS/second left for everything else" $

*Storage.* One notification row (id, user, template, channel, state, timestamps, provider
reference) is about 400 bytes.
$ 500,000,000 times 400 = 200,000,000,000 "B" = 200 "GB/day" $
Seven days: $200 times 7 = 1,400$ GB $= 1.4$ TB. Thirty days: 6 TB.
*Decision: keep 7 days of full rows and roll everything older into one counter row per
(template, day).* Nobody has ever asked "did this exact promotional email send 25 days ago?"
and paid 4.6 TB for the answer.

*Dedupe memory.* A 24-hour idempotency window holds every key:
$ 500,000,000 times 70 "B" = 35,000,000,000 "B" = 35 "GB" $
A one-hour window holds $500,000,000 \/ 24 = 20,833,333$ keys $times 70 = 1.46$ GB.
The whole retry ladder finishes in 85 seconds, so an hour covers every retry with 42x margin.
*Decision: a one-hour Redis window for speed, plus a unique index on
`(user_id, dedupe_key)` in the notification log for the long tail.* 1.46 GB instead of 35 GB,
and the database still makes the guarantee.

#formulas(title: "The board summary")[
5,787/s average · a *self-inflicted* 33,333/s blast · 1,000 SMS/s of contracted capacity ·
200 GB/day · 109.5 crore a year of SMS.

*This system's hard parts are a queue-priority problem and a money problem, not a
throughput problem.*
]

#subsection[Step 3 — API surface]

#code(lang: "text", caption: "one call to send, one to schedule millions, one to be told what happened")[
```text
POST /v1/notifications
  header Idempotency-Key: otp-9f13-1789412400
  body   { "userId": 88214, "templateId": "otp_login",
           "data": { "code": "482913", "mins": 5 },
           "class": "otp",                    // otp | transactional | marketing
           "channels": ["sms", "push"],       // order = fallback order
           "expiresAt": "2026-09-15T04:20:00Z" }
  202    { "notificationId": "ntf_01J8...", "state": "QUEUED" }
  200    { "notificationId": "ntf_01J8...", "state": "SENT", "replayed": true }
  422    { "error": "opted_out", "channel": "sms" }

POST /v1/campaigns
  body   { "templateId":"sale_sep", "audienceId":"aud_412", "class":"marketing",
           "channels":["push","email"], "spreadOverMin": 120,
           "quietHours": { "from": "21:00", "to": "09:00", "tz": "user" } }
  202    { "campaignId":"cmp_77", "estimated": 20000000, "startsAt": "..." }

GET  /v1/notifications/{id}
  200    { state:"DELIVERED", channel:"sms", attempts:2,
           providerRef:"sm_77aa", deliveredAt:"..." }

POST /v1/webhooks/providers/{provider}     (inbound, from the provider)
  body   { providerRef, status:"delivered"|"bounced"|"blocked", at }
  200    always — never make a provider retry because our database was slow
```
]

#trap[
*`expiresAt` is not decoration.* An OTP that arrives 40 minutes late is worse than one that
never arrives: the user has already asked for a second code, and now two codes are valid.
Every message in the queue carries a deadline, and a worker that picks up an expired message
*drops it and records why*. Without this, a provider outage turns into a flood of stale,
confusing messages the moment it recovers.
]

#subsection[Step 4 — Data model]

#code(lang: "text", caption: "four tables and three queues")[
```text
notifications                       -- 7 days hot, then rolled into counters
  notification_id  ulid    PK       -- time-ordered, so the partition is the day
  user_id          bigint  SHARD KEY INPUT
  template_id, class, channel
  state            enum  QUEUED|SENT|DELIVERED|BOUNCED|FAILED|DROPPED
  attempts         int
  dedupe_key       text
  provider_ref     text            -- how the receipt finds its way back
  created_at, sent_at, settled_at
  UNIQUE (user_id, dedupe_key)      -- the guarantee, not the cache
  INDEX  (provider_ref)             -- the webhook's only lookup

preferences                         -- checked at SEND time, never at campaign time
  user_id, category, channel, allowed BOOL, updated_at
  PRIMARY KEY (user_id, category, channel)

devices
  user_id, device_id, platform, token, last_seen_at, invalid_at
  -- invalid_at set when a provider says the token is dead. Never retried.

templates
  template_id, locale, channel, body, version   -- rendered by Piece 5's Template

-- queues (Kafka topics or SQS queues, one per class)
  q.otp             partitions 12    workers reserved 20%
  q.transactional   partitions 24    workers reserved 30%
  q.marketing       partitions 48    workers reserved 50%
  q.dead            everything that exhausted its retries
```
]

*Why three queues and not one with a priority field?* Because a priority field inside one
queue still makes the OTP wait behind 20 million marketing messages that were *already
delivered to the queue*. You cannot re-order a log after the fact. Separate queues with
separately reserved workers is the only version that actually works, and Step 6 shows the
arithmetic.

#subsection[Step 5 — Architecture]

#diagram(height: 6.2cm, caption: "One ingest path, three queues, one worker pool per channel. Receipts come back on their own path and are the only thing that turns SENT into DELIVERED.")[
  #dnode(0pt, 40pt, 62pt, 26pt, "Producing\nservices")
  #dnode(78pt, 40pt, 74pt, 26pt, "Ingest API\nidempotency gate")
  #dnode(168pt, 40pt, 66pt, 26pt, "Router\nprefs + cost")
  #dnode(250pt, 4pt, 60pt, 22pt, "q.otp")
  #dnode(250pt, 40pt, 60pt, 22pt, "q.txn")
  #dnode(250pt, 76pt, 60pt, 22pt, "q.marketing")
  #dnode(324pt, 4pt, 64pt, 22pt, "SMS workers")
  #dnode(324pt, 40pt, 64pt, 22pt, "Push workers")
  #dnode(324pt, 76pt, 64pt, 22pt, "Email workers")
  #dnode(402pt, 4pt, 62pt, 22pt, "SMS gateway\n1,000/s")
  #dnode(402pt, 40pt, 62pt, 22pt, "APNs / FCM")
  #dnode(402pt, 76pt, 62pt, 22pt, "Email relay")
  #dnode(324pt, 116pt, 64pt, 24pt, "q.dead + alarm", fill: rgb("#f7e3e3"))
  #dnode(402pt, 116pt, 62pt, 24pt, "Receipt\nconsumer", fill: rgb("#f0ece2"))

  #darrow(62pt, 53pt, 78pt, 53pt)
  #darrow(152pt, 53pt, 168pt, 53pt)
  #darrow(234pt, 48pt, 250pt, 20pt)
  #darrow(234pt, 53pt, 250pt, 51pt)
  #darrow(234pt, 58pt, 250pt, 84pt)
  #darrow(310pt, 15pt, 324pt, 15pt)
  #darrow(310pt, 51pt, 324pt, 51pt)
  #darrow(310pt, 87pt, 324pt, 87pt)
  #darrow(388pt, 15pt, 402pt, 15pt)
  #darrow(388pt, 51pt, 402pt, 51pt)
  #darrow(388pt, 87pt, 402pt, 87pt)
  #darrow(356pt, 98pt, 356pt, 116pt)
  #darrow(433pt, 98pt, 433pt, 116pt)

  #place(dx: 390pt, dy: 28pt)[#text(size: 7.5pt, fill: dc)[shaped]]
  #place(dx: 252pt, dy: 102pt)[#text(size: 7.5pt, fill: dc)[retries exhausted]]

  #place(dx: 0pt, dy: 146pt)[#text(size: 8pt, fill: muted)[The SMS arrow is the only one that is rate-shaped, because it is the only one with a contracted ceiling and a per-message cost.]]
  #place(dx: 0pt, dy: 156pt)[#text(size: 8pt, fill: muted)[Receipts arrive minutes later and update the row by `provider_ref`. "SENT" is a claim; "DELIVERED" is evidence.]]
]

Trace one OTP:
+ The login service calls `POST /v1/notifications` with
  `Idempotency-Key: otp-9f13-1789412400`.
+ The ingest API claims the key with `SET key NX EX 3600`. If the claim fails, it returns the
  stored result and does nothing else. This is Piece 5's `seen` set, in Redis.
+ The router reads preferences, drops channels the user opted out of, and orders the rest by
  `costPaise()`. For class `otp` it keeps the order the caller asked for, because a free
  channel that the user will not see is not cheaper.
+ It writes one row and publishes to `q.otp`.
+ An SMS worker picks it up, checks `expiresAt`, passes the notification id to the provider as
  the provider's own idempotency reference, and records `provider_ref`.
+ Minutes later a webhook arrives with that reference. The receipt consumer moves the row from
  `SENT` to `DELIVERED`, or to `BOUNCED` — and a bounce on a push token sets `invalid_at` on
  the device so we never spend another attempt on it.

#subsection[Step 6 — Deep dive]

*Deep dive A: one queue kills the OTP, and here is the number.*

#code(lang: "js", caption: "queues.js — run with: node queues.js")[
```js
function waitSeconds(aheadOfYou, drainRate) { return aheadOfYou / drainRate; }

const BLAST = 20_000_000;      // a campaign fired at 11:00
const DRAIN = 5_787;           // messages/second the whole worker fleet can push

console.log("ONE shared queue");
console.log("  OTP queued behind the blast waits",
  (waitSeconds(BLAST, DRAIN) / 60).toFixed(1), "minutes");

console.log("THREE queues, workers reserved per class");
const reserved = { otp: 0.20, transactional: 0.30, marketing: 0.50 };
for (const [cls, share] of Object.entries(reserved)) {
  console.log(`  ${cls.padEnd(14)} drain ${(DRAIN * share).toFixed(0).padStart(5)}/s`);
}
console.log("  OTP queued behind 500 other OTPs waits",
  waitSeconds(500, DRAIN * reserved.otp).toFixed(2), "seconds");
console.log("  the same blast now takes",
  (waitSeconds(BLAST, DRAIN * reserved.marketing) / 3600).toFixed(2), "hours");
```
]

#code(lang: "js", caption: "actual output")[
```text
ONE shared queue
  OTP queued behind the blast waits 57.6 minutes
THREE queues, workers reserved per class
  otp            drain  1157/s
  transactional  drain  1736/s
  marketing      drain  2894/s
  OTP queued behind 500 other OTPs waits 0.43 seconds
  the same blast now takes 1.92 hours
```
]

57.6 minutes against a 10-second promise. And the arithmetic is embarrassingly simple:
$20,000,000 \/ 5,787 = 3,456$ seconds. The fix costs nothing except deciding to do it before
the campaign, rather than during it.

The second line matters just as much: the blast now takes 1.92 hours instead of 58 minutes.
*We made the unimportant thing slower on purpose.* That sentence, said out loud, is the whole
idea of quality of service.

*Deep dive B: shaping a 33,333/s blast into a 1,000/s pipe.*

The SMS gateway is contracted at 1,000 messages/second across two providers. OTP peak takes
463/s of that, leaving 537/s. If a campaign puts one million SMS into the queue:
$ 1,000,000 \/ 537 = 1,862 "seconds" = 31 "minutes of solid SMS" $
during which every OTP is competing for the same pipe.

Three mechanisms, all built from Tier 1 pieces:
+ *A token bucket per provider*, exactly Piece 3, with capacity 500 and refill 500/s. The
  worker calls `allow()` before every send and sleeps on `retryAfterMs()` when it is empty.
  This is the promise we made in the contract, enforced in our own code rather than discovered
  through the provider's 429s.
+ *A reservation.* The OTP worker pool has its own bucket of 500/s; the marketing pool gets
  what is left. A blast can never eat an OTP's capacity, because it is drawing from a
  different bucket.
+ *A spread.* `spreadOverMin: 120` in the campaign API means the scheduler releases
  $20,000,000 \/ 120 = 166,667$ messages per minute $= 2,778$/s instead of 33,333/s. The
  campaign finishes two hours later and costs a tenth of the peak capacity.

*Decision: marketing never uses SMS unless the user has no valid push token, and every
campaign is spread by default.* The cost side decides it: the same message costs 12 paise by
SMS and 0 by push.

*Deep dive C: retries that stop.*

#code(lang: "js", caption: "retries.js — run with: node retries.js")[
```js
const attempts = [0, 1, 4, 16, 64];          // seconds after the first try
console.log("retry schedule (seconds):", attempts.join(", "),
            "| total window", attempts.reduce((a, b) => a + b, 0), "s");
let live = 10_000_000;                        // messages that failed once, per day
const failAgain = 0.30;                       // 30% of retries fail again
for (let i = 1; i < attempts.length; i++) {
  live = Math.round(live * failAgain);
  console.log(`  attempt ${i + 1}: ${live.toLocaleString()} messages ` +
              `(${(live / 86400).toFixed(1)}/s)`);
}
console.log(`  dead-letter queue: ${live.toLocaleString()} per day`);
```
]

#code(lang: "js", caption: "actual output")[
```text
retry schedule (seconds): 0, 1, 4, 16, 64 | total window 85 s
  attempt 2: 3,000,000 messages (34.7/s)
  attempt 3: 900,000 messages (10.4/s)
  attempt 4: 270,000 messages (3.1/s)
  attempt 5: 81,000 messages (0.9/s)
  dead-letter queue: 81,000 per day
```
]

Start from a 2% first-attempt failure rate — $500,000,000 times 0.02 = 10,000,000$ failures a
day — and assume 30% of each retry fails again. The retry traffic *shrinks by 70% per round*,
so the extra load is 34.7/s on top of 5,787/s, which is 0.6%. Retries are cheap when they
back off and stop.

#formulas(title: "The four rules of a retry budget")[
+ *Exponential, with jitter.* 1, 4, 16, 64 seconds, each multiplied by a random 0.5 to 1.5.
  Without jitter, every message that failed during a 30-second outage retries at the same
  instant and re-creates the outage.
+ *A fixed number of attempts, then the dead-letter queue.* 81,000 a day land there. That is
  0.016% of volume and it is a number a human can look at.
+ *Never retry a permanent failure.* An invalid device token, an unsubscribed email, a
  blocked number: these fail identically every time. Mark the device `invalid_at` and stop.
  Retrying them is how a 2% failure rate quietly becomes a 20% one.
+ *Respect the deadline over the schedule.* If `expiresAt` passes mid-ladder, drop the
  message and record `DROPPED`. A retry that succeeds after the code has expired is a bug
  that looks like a success.
]

#subsection[Step 7 — Trade-offs, failures, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Queueing], [one queue, priority field], [one queue per class],
    [*B* — a priority field cannot re-order messages already in the log],
  [Blast handling], [provision for 33,333/s], [spread it over 120 minutes],
    [*B* — the peak is ours; shaping is free and capacity is not],
  [Dedupe window], [24 h in Redis, 35 GB], [1 h in Redis + a unique index],
    [*B* — the ladder is 85 s, so an hour is 42x margin at 4% of the memory],
  [Send call], [synchronous, in the caller's request], [202 and a queue],
    [*B* — a provider taking 800 ms must never hold a user's HTTP thread],
  [Delivery truth], [trust the provider's 200 OK], [wait for the receipt webhook],
    [*B* — "accepted by the gateway" is not "arrived on the phone"],
  [Channel order], [fixed per template], [cheapest channel the user can receive],
    [*B* — it is the 14.9 crore a year decision from Step 2],
  [Preferences check], [at campaign build time], [at send time],
    [*B* — a user who opts out during a 2-hour spread must stop receiving immediately],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [One SMS provider is down],
    [Nothing],
    [The router fails over to the second provider. Capacity halves to 500/s, so OTP keeps its
     reservation and marketing SMS pauses automatically — the reservation *is* the degradation
     plan.],
  [Both SMS providers are down],
    [OTP does not arrive],
    [Fall back to the next channel in the order: push, then email. An OTP by email is worse
     than by SMS and much better than nothing. Alarm at the first 30 seconds.],
  [A provider accepts everything and delivers nothing],
    [Silence],
    [This is why receipts exist. Alarm when the ratio of `DELIVERED` to `SENT` for a provider
     drops below its 7-day baseline by more than 20%.],
  [The same notification is enqueued twice],
    [One message],
    [The unique index on `(user_id, dedupe_key)` rejects the second row. Redis is the fast
     path; the index is the guarantee.],
  [A campaign targets the wrong audience],
    [Millions of wrong messages],
    [A kill switch that drains `q.marketing` without sending, plus a rule that any campaign
     over 1 million recipients sends to a 1% sample first and waits 10 minutes.],
  [The receipt webhook floods us],
    [Nothing],
    [Return 200 immediately and process asynchronously. Never make a provider retry because
     our database was slow — their retry policy is not ours to control.],
)

*At 10x (5 billion notifications/day):*
- Average becomes $5,000,000,000 \/ 86,400 = 57,870$/second, and the largest blast becomes
  200 million in 10 minutes $= 333,333$/second if unshaped. Shaping is no longer an
  optimisation; it is the only version that exists.
- Storage becomes 2 TB/day. The 7-day window is 14 TB. Partition by day and drop partitions.
- SMS becomes 250 million/day $= 3$ crore rupees *a day*. At that price the company builds
  its own aggregator relationships and negotiates per-country rates, and the routing decision
  becomes per-country as well as per-cost.
- The genuinely new problem is *provider capacity*, not ours. 57,870/s of push is fine — APNs
  and FCM are built for it. But no SMS aggregator will sell you 10,000/s in one country.
  *Decision: route SMS across a pool of 8 aggregators with a token bucket per aggregator per
  country, and treat the pool like a connection pool — health-checked, weighted by recent
  delivery rate, and drained rather than switched when one degrades.*
]
]

#practice(tier: 2, time: "40 min")[
+ The shortener's cache holds 20 million links in 5 GB. A competitor's link is spammed and
  one code receives 40% of all redirects. Compute the load on that single cache node and say
  whether anything breaks.
+ Rework the rate limiter for a *sliding window counter* instead of a token bucket. What
  changes in the store, in the memory per key, and in what a client can get away with?
+ A partner is on 6,000 requests/minute and complains that they see 429s at 5,200. Give three
  possible causes, and the one measurement that tells them apart.
+ Design the quiet-hours rule for notifications: a user in one time zone, a campaign spread
  over 2 hours, and a deadline. What happens to messages that fall inside quiet hours?
+ A template bug puts the wrong name in 4 million already-queued emails. Write the response:
  what you stop, what you cannot stop, and what you send afterwards.
]
#key[
+ 40% of 34,722 peak redirects/s $= 13,889$/s all landing on *one* Redis key on *one* node.
  A Redis box does ~100,000 ops/s, so that node is at 14% — it is fine. Nothing breaks,
  because a hot *read* key in memory is the best case in the whole system. What would break is
  the click counter if it were a synchronous increment on one row: 13,889 writes/s to a single
  row is a guaranteed hot-shard failure, which is exactly why Design 1 batches it.
+ Store three numbers per key instead of two, so memory goes from ~100 B to ~120 B per key —
  5 million keys is still 600 MB. The store script changes from a refill calculation to the
  blend in Piece 4. What the client loses is the *burst*: a token bucket lets a paid caller
  fire 600 requests in one second and then wait; a sliding window spreads them. Pick the
  window only when you promised a partner a hard ceiling.
+ Causes: (a) their traffic is bursty and the bucket capacity is smaller than their burst;
  (b) leases held by crashed pods are destroying tokens; (c) they are being counted across two
  endpoint groups that share a key. The measurement that separates them: log `given` from the
  lease script per key per second and compare its sum to 6,000. If the sum is 6,000 the limit
  is fine and the burst is the problem; if it is 5,200 tokens are being lost.
+ Convert the user's local quiet window to UTC at send time, not at campaign time, because
  time zones and the user's own setting can both change mid-campaign. A message that lands
  inside quiet hours is *rescheduled* to the window's end with jitter — not dropped, because
  it is marketing and the deadline is generous. If a message's `expiresAt` falls before the
  quiet window ends, drop it; a deadline always beats a schedule.
+ Stop: pause `q.marketing` and drain it without sending — that recovers everything not yet
  picked up by a worker. Cannot stop: whatever the email relay has already accepted, which is
  irreversible the moment the relay says 200. Measure that number exactly from the `SENT`
  count before you say anything. Afterwards: one correction email to the affected list only,
  never to the whole audience, and add a canary — any campaign over 1 million sends to 1%
  first and waits 10 minutes.
]

#section[Design 4 — a news feed]
#tier-header(3)

#ex(15, tier: 3, asked: "Amazon · pattern")[Design the feed a user sees when they open the
app. 200 million daily active users out of 600 million registered, 8 million posts a day, an
average of 200 followers — and 500 accounts with two million followers each.
#sol[

#subsection[Step 1 — Clarify]

#table(columns: (1fr, 1fr),
  [*Question I ask*], [*Why the answer changes the design*],
  [How many followers does the *biggest* account have?],
    [This one number decides whether a single fan-out strategy can work at all.],
  [Chronological or ranked?],
    [Ranked adds a scoring step and means the feed cannot be a simple append-only list.],
  [How far back can a user scroll?],
    [It caps the stored inbox. Unlimited scroll and a 200-item cap are different systems.],
  [How fresh must a post be?],
    [Seconds means push on write. Minutes lets you batch, which is 10x cheaper.],
  [How many registered users are active on a given day?],
    [It tells you what fraction of your fan-out writes will never be read.],
  [Can a post be deleted, or a follow undone?],
    [If yes, you can never treat a written inbox row as final.],
)

Assumed and said out loud: *200 million DAU of 600 million registered*; *8 million posts/day*;
*average 200 followers*; *the largest 500 accounts average 2 million followers and post 3
times a day*; *the feed is ranked*; *scroll is capped at 200 posts*; *a post should appear
within 60 seconds*; *deletes and unfollows are handled at read time*.

#subsection[Step 2 — Scale estimate]

*Reads.* 200 million users opening the feed 8 times a day:
$ 200,000,000 times 8 = 1,600,000,000 "feed reads/day" $
$ 1,600,000,000 \/ 86,400 = 18,518 "reads/second average" quad times 3 = 55,555 "at peak" $

*Writes look tiny.*
$ 8,000,000 \/ 86,400 = 92.6 "posts/second" $

*And then fan-out multiplies them by 200.*
$ 8,000,000 times 200 = 1,600,000,000 "inbox rows/day" $
$ 1,600,000,000 \/ 86,400 = 18,518 "row writes/second" quad times 3 = 55,555 "at peak" $

Stop and look at those two numbers. *The write path and the read path are the same size —
18,518 each.* That almost never happens. It happens here because one API call at 92.6/second
turns into 18,518 writes/second behind it, and saying that out loud is how you show you
understand fan-out.

*Now the 500 big accounts.* If their posts were fanned out the same way:
$ 500 times 3 times 2,000,000 = 3,000,000,000 "rows/day" $
$ 3,000,000,000 \/ (1,600,000,000 + 3,000,000,000) = 65.2% "of all fan-out writes" $
*Five hundred accounts out of six hundred million would generate 65% of the entire write
load of the system.* That is the celebrity problem, in one division.

*How much of the fan-out is wasted?*
$ 200,000,000 \/ 600,000,000 = 33% "of followers are active today" $
So *67% of every row we push is never read by anybody.*

*Inbox memory.* One inbox entry is post id 8 B + author id 8 B + score 4 B + timestamp 8 B
plus overhead $approx 50$ bytes. Cap at 200 entries per user:
$ 200,000,000 times 200 times 50 = 2,000,000,000,000 "B" = 2 "TB" $
$ 2,000,000,000,000 \/ 100 "GB per node" = 20 "nodes" $
That 2 TB is the *worst case*. The average inbox is much shorter:
$1,600,000,000 \/ 200,000,000 = 8$ new rows per active user per day, so a 200-entry cap holds
25 days. Cap by 14 days as well and the typical inbox is $14 times 8 = 112$ entries:
$ 200,000,000 times 112 times 50 = 1,120,000,000,000 "B" = 1.12 "TB" $

*Post storage.* One post row (text, author, media references, counters) is about 1 KB.
$ 8,000,000 times 1,000 = 8,000,000,000 "B" = 8 "GB/day" quad times 365 = 2.92 "TB/year" $
A hot cache of the last 3 days is $8 times 3 = 24$ GB, which is one node.

#formulas(title: "The board summary")[
55,555 feed reads/s peak · 55,555 inbox writes/s peak · 2 TB of inboxes · 24 GB of hot posts ·
*500 accounts would be 65% of the write load* · 67% of pushed rows are never read.

*This is not a throughput problem. It is a "who do you push to" problem.*
]

#note[
Eight new posts per active user per day is worth pausing on. A strictly chronological feed of
8 items would be empty by the second scroll, which is exactly why real feeds are *ranked and
padded* — with older posts the user has not seen and with recommended posts from accounts they
do not follow. The ranking is not a nice-to-have bolted on top; it is what makes a feed of 8
items into a feed you can scroll.
]

#subsection[Step 3 — API surface]

#code(lang: "text", caption: "one read endpoint that matters, and a cursor that is not a page number")[
```text
GET  /v1/feed?limit=20&cursor=eyJzIjoyLjE0LCJwIjoicF8zM...
  200  { "items": [ { "postId":"p_8812", "authorId":"u_71",
                      "text":"...", "media":[...], "score":2.14,
                      "createdAt":"2026-09-15T04:02:11Z" } ],
         "nextCursor":"eyJzIjowLjk4...", "asOf":"2026-09-15T04:11:02Z" }
  note cursor = last (score, postId) seen, NOT an offset. Offsets break
       the moment a new post arrives between page 1 and page 2.

POST /v1/posts
  header Idempotency-Key: 8c11-...
  body   { "text":"...", "mediaIds":[...], "audience":"followers" }
  201    { "postId":"p_8812", "fanout":"queued", "visibleWithinSec":60 }

DELETE /v1/posts/{postId}
  204    note this writes a tombstone. It does NOT delete inbox rows.

POST /v1/follows       { "targetId":"u_71" }    201
DELETE /v1/follows/{targetId}                   204
  note also a tombstone-style change: old rows stay, the read filters them.
```
]

#trap[
*Never paginate a feed with `offset` and `limit`.* Between page 1 and page 2 a new post
arrives at the top, every item shifts down by one, and the user sees item 20 twice and never
sees item 21. Use a cursor made of the last item's `(score, postId)` and ask for "strictly
after this". It is the same amount of code and it is correct.
]

#subsection[Step 4 — Data model]

#code(lang: "text", caption: "three stores, because three very different jobs")[
```text
-- IN MEMORY, the hot path
inbox:{userId}      sorted set   member = postId, score = rank score
                                 capped at 200, TTL 14 days
hot:{authorId}      list         last 50 post ids of a BIG account
                                 read at request time, never pushed

-- POST STORE, key-value, partitioned on post_id
posts
  post_id     ulid     PARTITION KEY   (time-ordered, so recent posts cluster)
  author_id   bigint
  body, media_ids, created_at
  deleted_at  timestamp null           -- the tombstone; rows are never removed
  counters    map                      -- likes/comments, updated by a stream job

-- GRAPH STORE, the two directions are two tables on purpose
follows_out   follower_id  PARTITION KEY, followee_id  SORT KEY   -- "who I follow"
follows_in    followee_id  PARTITION KEY, follower_id  SORT KEY   -- "who follows me"
  note: fan-out reads follows_in; the read path reads follows_out.
        Duplicating the edge costs 2x storage on a tiny table and removes
        a scan from both hot paths.
```
]

*Why a sorted set and not a list?* Because the feed is ranked, and a sorted set gives you
"top 20 by score" and "everything after this score" in one operation, plus an automatic way to
trim to 200. A list would force a full read and a sort on every request.

*Why is the biggest account's list stored separately?* Because it is read, not pushed. One
key, 50 post ids, read by however many followers open the app. It is a cache entry, not a
fan-out target.

#subsection[Step 5 — Architecture]

#diagram(height: 6.1cm, caption: "Write path along the top, read path along the bottom. A post from a normal account is pushed into 200 inboxes. A post from a big account is written once and pulled at read time.")[
  #dnode(0pt, 6pt, 60pt, 24pt, "Author")
  #dnode(80pt, 6pt, 70pt, 26pt, "Post service")
  #dnode(170pt, 6pt, 64pt, 26pt, "Post store")
  #dnode(254pt, 6pt, 64pt, 26pt, "Fan-out\nqueue")
  #dnode(338pt, 6pt, 70pt, 26pt, "Fan-out\nworkers")
  #dnode(338pt, 56pt, 70pt, 28pt, "Inbox store\n2 TB · 20 nodes", fill: rgb("#dbe7c9"))
  #dnode(170pt, 56pt, 88pt, 28pt, "Big-account\nrecent lists", fill: rgb("#f0ece2"))
  #dnode(0pt, 110pt, 60pt, 26pt, "Reader")
  #dnode(80pt, 110pt, 92pt, 28pt, "Feed service\n+ ranker")
  #dnode(254pt, 110pt, 70pt, 26pt, "Post cache\n24 GB")

  #darrow(60pt, 18pt, 80pt, 18pt)
  #darrow(150pt, 19pt, 170pt, 19pt)
  #darrow(234pt, 19pt, 254pt, 19pt)
  #darrow(318pt, 19pt, 338pt, 19pt)
  #darrow(373pt, 32pt, 373pt, 56pt, label: "200 rows")
  #darrow(148pt, 32pt, 200pt, 56pt, label: "over 100k")
  #darrow(60pt, 123pt, 80pt, 123pt)
  #darrow(172pt, 123pt, 254pt, 123pt, label: "hydrate 60")
  #darrow(172pt, 116pt, 338pt, 78pt, label: "read inbox")
  #darrow(172pt, 124pt, 214pt, 84pt)

  #place(dx: 236pt, dy: 36pt)[#text(size: 7.5pt, fill: dc)[under 100k]]

  #place(dx: 0pt, dy: 146pt)[#text(size: 8pt, fill: muted)[The threshold at 100,000 followers is the whole design. Below it, push. Above it, write once and let readers pull.]]
  #place(dx: 0pt, dy: 156pt)[#text(size: 8pt, fill: muted)[A deleted post is a tombstone checked during hydrate. No inbox row is ever deleted by anything except the 200-entry cap.]]
]

Trace one post by a normal account:
+ `POST /v1/posts` writes one row to the post store and returns `201` in about 20 ms. The user
  is done.
+ A message goes on the fan-out queue with the post id and the author id.
+ A worker reads `follows_in` for that author — 200 rows — filters to followers seen in the
  last 7 days, and pushes an entry into each of their sorted sets.
+ 67% of those followers are not active today. We push anyway for the active-7-day set, which
  is a compromise: filtering to *today's* actives would be cheaper but a user returning
  tomorrow would find an empty feed.

Trace one post by a big account:
+ The same `201` in 20 ms.
+ The fan-out service sees `followerCount > 100,000` and pushes *nothing*. It prepends the
  post id to `hot:{authorId}` and stops. One write instead of two million.

Trace one feed read:
+ Read the reader's inbox sorted set: top 200 by score, one operation.
+ Read `follows_out` for big accounts only — at most 50 of them for a typical user — and
  multi-get their `hot:` lists.
+ Merge the two lists, drop tombstoned and unfollowed authors, take the top 60 candidates.
+ Multi-get those 60 post bodies from the post cache.
+ Score, sort, return 20 with a cursor.

#subsection[Step 6 — Deep dive]

*Deep dive A: the hybrid, and where the threshold goes.*

#table(columns: (auto, 1fr, 1fr),
  [], [*Push on write (fan-out)*], [*Pull on read*],
  [Cost of one post], [$F$ writes, where $F$ is the follower count], [1 write],
  [Cost of one feed read], [1 read], [1 read per big account followed],
  [Latency when reading], [lowest — the answer is already built], [higher — a merge per read],
  [Waste], [67% of rows are never read], [none],
  [Worst case], [2,000,000 writes for one post], [a user following 500 big accounts],
)

*The threshold is where the burst stops being survivable, not where the totals cross.* A
2-million-follower post at a fan-out rate of, say, 200,000 rows/second across the worker fleet
takes $2,000,000 \/ 200,000 = 10$ seconds — and for those 10 seconds the queue is full of one
person's post while everybody else's waits. Three such posts in the same minute and the
60-second freshness promise is broken for all 600 million users.

*Decision: push below 100,000 followers, pull at or above it.* Two numbers justify it:
+ It removes 3 billion of 4.6 billion daily writes — 65% of the load — by changing the
  behaviour of 500 accounts.
+ A typical user follows at most a few dozen big accounts, so the pull side costs one
  multi-get of under 50 keys, which is 4 ms.

#code(lang: "js", caption: "feed-merge.js — run with: node feed-merge.js")[
```js
const HOUR = 3600_000;
const now  = 10 * HOUR;

// pushed at write time, newest first, capped at 200 entries
const inbox = [
  { postId: "p9", authorId: "friend_a", ts: now - 0.5 * HOUR },
  { postId: "p7", authorId: "friend_b", ts: now - 3 * HOUR },
  { postId: "p4", authorId: "friend_a", ts: now - 9 * HOUR },
];
// NOT pushed: one cached list per big account, read at request time
const celebrityRecent = new Map([
  ["star_x", [{ postId: "c3", authorId: "star_x", ts: now - 1 * HOUR },
              { postId: "c1", authorId: "star_x", ts: now - 7 * HOUR }]],
  ["star_y", [{ postId: "c9", authorId: "star_y", ts: now - 2 * HOUR }]],
]);
const deleted  = new Set(["p7"]);                 // tombstones, checked on read
const affinity = new Map([["friend_a", 3.0], ["friend_b", 2.0],
                          ["star_x", 1.0], ["star_y", 0.4]]);

function score(post, now) {
  const ageHours = (now - post.ts) / HOUR;
  const recency  = 1 / (1 + ageHours);            // 1.0 fresh, 0.5 at 1 h, 0.1 at 9 h
  return +(recency * (affinity.get(post.authorId) ?? 1)).toFixed(4);
}

function buildFeed(inbox, follows, now, pageSize) {
  const pulled = follows.flatMap(id => celebrityRecent.get(id) ?? []);
  return [...inbox, ...pulled]
    .filter(p => !deleted.has(p.postId))          // tombstone filter, not 30M deletes
    .map(p => ({ ...p, s: score(p, now) }))
    .sort((a, b) => b.s - a.s)                    // numeric comparator, always
    .slice(0, pageSize);
}

for (const p of buildFeed(inbox, ["star_x", "star_y"], now, 5)) {
  console.log(p.postId.padEnd(3), p.authorId.padEnd(9), "score", p.s);
}
```
]

#code(lang: "js", caption: "actual output")[
```text
p9  friend_a  score 2
c3  star_x    score 0.5
p4  friend_a  score 0.3
c9  star_y    score 0.1333
c1  star_x    score 0.125
```
]

`c3` is only one hour old and outranks `p4`, which is nine hours old from a closer friend.
`p7` does not appear at all: it was deleted, and the filter caught it without touching a single
inbox row.

*Deep dive B: spending the 200 ms read budget.*

#table(columns: (auto, auto, 1fr),
  [*Step*], [*Budget*], [*Why it costs that*],
  [TLS, auth, routing], [5 ms], [fixed cost of being on the internet],
  [Read inbox sorted set], [2 ms], [one range read of 200 entries $= 10$ KB from memory],
  [Multi-get big-account lists], [4 ms], [up to 50 keys in one pipelined round trip],
  [Filter tombstones and unfollows], [1 ms], [a set lookup per candidate, in process],
  [Multi-get 60 post bodies], [6 ms], [60 KB from the post cache, one round trip],
  [Score and sort 60 items], [2 ms], [60 multiplications and one sort],
  [Serialise 20 items], [3 ms], [about 20 KB of JSON],
  [*Server total*], [*23 ms*], [leaves 177 ms for the network and the phone],
)

23 ms against a 200 ms promise looks comfortable, and it is — *while the caches are warm*.
The number that actually needs defending is the cold one. A post-cache miss on all 60
candidates costs 60 key-value reads; issued in parallel that is one round trip of about 8 ms,
not 60 of them. *This is the single most important implementation detail on the read path:
never loop with `await` inside it.* Sixty sequential 5 ms reads is 300 ms and a broken promise.

*Deep dive C: deletes, unfollows, and why you never delete an inbox row.*

A user with 2 million followers deletes a post. If inbox rows had been pushed, removing them
would be 2 million deletes — the same burst we just spent Deep dive A avoiding, now happening
at the worst possible moment, because the user is watching and expects it to be instant.

*Decision: never delete inbox rows. Filter at read time.*
+ Deleting a post sets `deleted_at`. The hydrate step drops anything with it set.
+ Unfollowing writes the edge removal; the read path checks the candidate's author against
  `follows_out` and drops what is no longer followed.
+ A blocked user is the same check with a different set.
+ The stale rows cost 50 bytes each and vanish by themselves within 14 days or 200 posts,
  whichever comes first.

*What this costs.* Every read does a few set lookups it would not otherwise need — about 1 ms
of the 23 ms budget — and the inbox is slightly larger than its useful content. *What it
buys.* Deletion is one write, always, regardless of follower count, and it takes effect for
every reader on their very next request. That is a much better guarantee than a 2-million-row
cleanup job could ever give.

#subsection[Step 7 — Trade-offs, failures, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Fan-out], [push for everyone], [hybrid at 100k followers],
    [*B* — 500 accounts would otherwise be 65% of all writes],
  [Inbox storage], [rows in a database], [capped sorted sets in memory],
    [*B* — 55,555 writes/s and 55,555 reads/s of 50-byte rows is a memory workload],
  [Inbox contents], [full post bodies], [post ids only],
    [*B* — 50 B per entry instead of 1 KB; 2 TB instead of 40 TB],
  [Pagination], [offset and limit], [a `(score, postId)` cursor],
    [*B* — offsets duplicate and skip items whenever the feed changes],
  [Deletes], [remove every inbox row], [tombstone, filter on read],
    [*B* — one write instead of two million, and it is instant],
  [Who gets pushed to], [all followers], [followers active in 7 days],
    [*B* — 67% of all rows are never read; 7 days keeps returning users happy],
  [Ranking], [chronological], [score with recency and affinity],
    [*B* — 8 new posts a day is not a scrollable chronological feed],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [The fan-out queue backs up],
    [New posts appear late],
    [Freshness degrades, nothing breaks — the read path does not depend on the queue. Shed
     the *marketing-like* work first: stop pushing to 7-day-actives and push only to
     24-hour-actives until the lag clears.],
  [One inbox node dies],
    [$1\/20$ of users get an empty feed],
    [Rebuild that node's inboxes from `follows_out` plus recent posts — it is a cache, not a
     source of truth. Meanwhile serve those users a pure pull-based feed, slower but correct.],
  [The post cache is cold],
    [Feeds load in ~120 ms instead of 23 ms],
    [Every hydrate becomes a parallel multi-get against the post store. It is 8 ms, not
     300 ms, *because the reads are issued together*. Coalesce duplicate misses.],
  [A big account crosses 100,000 followers],
    [Nothing],
    [The threshold is evaluated per post, not cached per account, so the switch happens on the
     very next post. Their existing pushed rows stay and simply age out.],
  [A post goes viral],
    [Nothing],
    [It is one entry in the post cache, read by millions. The best case, not the worst — just
     like the viral link in Design 1.],
  [A user follows 5,000 big accounts],
    [Slow feed],
    [Cap the pull side at the 100 most-recently-interacted-with big accounts. Beyond that the
     marginal post never reaches the top 20 anyway.],
)

*At 10x — and note that 10x here is not 10x the humans:*
- Assume the same 200 million users open the feed 80 times a day instead of 8 (short video
  changes behaviour, not headcount) and posting rises to 80 million a day.
- Reads become $200,000,000 times 80 \/ 86,400 = 185,185$/s average, 555,555/s at peak.
- Fan-out becomes $80,000,000 times 200 \/ 86,400 = 185,185$ rows/second, 555,555 at peak.
  Twenty inbox nodes become roughly 60, sized for *write throughput* now rather than memory.
- The inbox does not get bigger, it gets *faster-moving*:
  $80,000,000 times 200 \/ 200,000,000 = 80$ rows per user per day, so a 200-entry cap now
  holds $200 \/ 80 = 2.5$ days instead of 25. That quietly changes the product — a user who
  opens the app twice a week no longer sees what they missed. *Decision: raise the cap to 600
  entries (6 TB of inboxes) for weekly-active users and keep 200 for daily-actives.*
- The genuinely new problem at 10x is *ranking cost*, not fan-out. Scoring 60 candidates with
  a formula is 2 ms; scoring 600 candidates with a learned model is not. *Decision: keep the
  cheap formula as a first-stage filter that cuts 600 candidates to 60, and run the expensive
  model only on those 60.* Two-stage ranking is how you buy a better feed without buying
  10x the machines.
]
]

#section[Design 5 — a chat system]
#tier-header(3)

#ex(16, tier: 3, asked: "Microsoft · pattern")[Design one-to-one and group messaging. 100
million daily active users sending 40 messages each, groups of up to 500, delivered and read
receipts, and up to four devices per account.
#sol[

#subsection[Step 1 — Clarify]

#table(columns: (1fr, 1fr),
  [*Question I ask*], [*Why the answer changes the design*],
  [One-to-one only, or groups? How big is the largest group?],
    [It multiplies every delivery. 1:1 is 1 copy; a 500-member group is 499.],
  [Does the server keep history, or does it live on the device?],
    [This is the biggest storage decision in the design, by a factor of 100.],
  [How many devices per account?],
    [More than one means the read cursor is per *device*, not per user. Easy to get wrong.],
  [Delivered and read receipts?],
    [Each one is another message class flowing the other way.],
  [End-to-end encrypted?],
    [If yes, the server cannot search, preview, or rank — and cannot help you recover a lost
     device's history.],
  [Must message order be identical for everyone in a chat?],
    [Yes $->$ one writer per chat assigns a sequence. Client timestamps can never do this.],
)

Assumed and said out loud: *100 million DAU sending 40 messages a day*; *30% of messages go to
groups averaging 25 members*, groups capped at 500; *the server keeps one year of history*;
*up to 4 devices per account*; *delivered and read receipts required*; *transport-encrypted,
not end-to-end* — and I say why that is a product choice, not a technical one, because
end-to-end would remove server-side search and multi-device history recovery.

#subsection[Step 2 — Scale estimate]

*Messages sent.*
$ 100,000,000 times 40 = 4,000,000,000 "messages/day" $
$ 4,000,000,000 \/ 86,400 = 46,296 "sends/second" quad times 3 = 138,888 "at peak" $

*Deliveries — the number that is 8x bigger than the one you were given.*
$ 0.70 times 1 + 0.30 times 24 = 0.7 + 7.2 = 7.9 "deliveries per message" $
$ 4,000,000,000 times 7.9 = 31,600,000,000 "deliveries/day" $
$ 31,600,000,000 \/ 86,400 = 365,741 "/second" quad times 3 = 1,097,222 "at peak" $

*Connections* — Little's Law, with users online 90 minutes a day:
$ 100,000,000 times 90 \/ 1,440 = 6,250,000 "concurrent on average" $
$ 6,250,000 times 2 = 12,500,000 "at peak" $
$ 12,500,000 \/ 100,000 "per box" = 125 "boxes of load" $
To survive losing one availability zone of three: $125 \/ (2\/3) = 188$ boxes, spread 63/63/62.

*Per box at peak*, which is the check that tells you the fleet is the right size:
$ 1,097,222 \/ 188 = 5,836 "pushes/second per box" $
$ 5,836 times 400 "B" = 2,334,400 "B/s" = 2.33 "MB/s" = 18.7 "Mbps" $
Both comfortable. A box holding 100,000 sockets and writing 5,836 small frames a second is
doing easy work.

*Storage — and the decision that saves 8x.* One message row (ids, sender, sequence, timestamp,
~200 bytes of body) is about 300 bytes.

If you store one copy *per recipient*:
$ 31,600,000,000 times 300 = 9,480,000,000,000 "B" = 9.48 "TB/day" $
$ 9.48 times 365 = 3,460 "TB" = 3.46 "PB/year" quad times 3 "RF" = 10.4 "PB" $

If you store one copy *per chat* and give each device a cursor:
$ 4,000,000,000 times 300 = 1,200,000,000,000 "B" = 1.2 "TB/day" $
$ 1.2 times 365 = 438 "TB/year" quad times 3 "RF" = 1.31 "PB" $

$3.46 \/ 0.438 = 7.9times$ less — exactly the fan-out factor, which is the point.

*The routing table.* Which box holds which user's socket:
$ 12,500,000 times 50 "B" = 625,000,000 "B" = 625 "MB" $
One Redis node, with a TTL so a dead connection cleans itself up.

#formulas(title: "The board summary")[
138,888 sends/s peak · *1,097,222 deliveries/s peak* · 12.5 million open sockets on 188 boxes
· 438 TB/year · 625 MB of routing state.

*Chat pulls where the feed pushes.* Design 4 wrote one row per reader because most readers
never come back. Chat writes one row per *chat* because every recipient is going to read it,
and there are only a handful of them. Say that comparison out loud — it is the same question
answered differently for a good reason.
]

#subsection[Step 3 — API surface]

#code(lang: "text", caption: "a WebSocket for the stream, plain HTTP for history and setup")[
```text
WS   /v1/stream                                  (one per device, always open)
  up   { t:"send", chatId, clientMsgId:"01J8X...", text, sentAtMs }
  down { t:"ack",  chatId, clientMsgId, seq: 40912, serverTsMs }
  down { t:"msg",  chatId, seq, senderId, text, serverTsMs }
  down { t:"receipt", chatId, seq, userId, kind:"delivered"|"read" }
  up   { t:"cursor", chatId, seq: 40912 }        -- "this device has seen up to here"
  up   { t:"typing", chatId }                    -- fire and forget, never stored
  up   { t:"hb" }  every 30 s                    -- heartbeat

GET  /v1/chats/{chatId}/messages?after=40880&limit=200
  200  { messages:[...], nextAfter: 41080 }
  note the ONLY history call. A reconnecting device sends its cursor and
       gets exactly what it missed, in order, with no duplicates.

POST /v1/chats            { type:"group", memberIds:[...], title }   201
POST /v1/chats/{id}/members                                          201
GET  /v1/chats?updatedAfter=...                                      200  -- the chat list
```
]

#trick[
*`clientMsgId` is generated by the sender, not the server.* It is what makes a retry safe: the
phone that did not get an ack re-sends the identical frame, the server recognises the id and
returns the *original* sequence number instead of creating a second message. Without it, every
flaky train tunnel produces duplicate messages, and users notice duplicates far more than they
notice delay.
]

#subsection[Step 4 — Data model]

#code(lang: "text", caption: "one message row per chat, one cursor per device")[
```text
messages
  chat_id     bigint    PARTITION KEY     -- all of a chat lives together
  seq         bigint    SORT KEY          -- assigned by the chat's owner, gapless
  message_id  ulid
  sender_id   bigint
  client_msg_id text                      -- the sender's idempotency key
  body        blob                        -- ~200 B
  created_at  timestamp
  UNIQUE (chat_id, client_msg_id)         -- the retry guarantee
  -- partitioned by month; older months move to cold storage

chat_members
  chat_id, user_id, role, joined_at_seq   -- joined_at_seq caps what a new
                                             member can read. Joining a group
                                             does not hand you its history.

device_cursor
  user_id, device_id  PRIMARY KEY
  chat_id, last_seq, updated_at           -- one row per device per chat
  note: per DEVICE, not per user. A phone and a laptop are at different places.

-- IN MEMORY
route:{userId}      set    deviceId -> gatewayBoxId      TTL 90 s
seq:{chatId}        int    the chat's current sequence   (owned by one writer)
presence:{userId}   string ONLINE | LAST_SEEN ts         TTL 90 s
```
]

*Why partition by `chat_id`?* Because every read is "give me this chat after this sequence",
and every write is "append to this chat". Both are single-partition. The cost is that one
enormous, very busy group is one hot partition — but a 500-member group at 20 messages a
minute is $20 \/ 60 = 0.33$ writes/second, which is nothing. Group *size* is a delivery
problem, not a storage problem.

#subsection[Step 5 — Architecture]

#diagram(height: 6.8cm, caption: "The sequence is assigned in exactly one place. Everything downstream — storage, delivery, receipts, offline push — reads it and never invents it.")[
  #dnode(0pt, 6pt, 58pt, 26pt, "Sender\ndevice")
  #dnode(76pt, 6pt, 74pt, 26pt, "WS gateway\n188 boxes")
  #dnode(168pt, 6pt, 76pt, 28pt, "Chat service\nassigns seq", fill: rgb("#dbe7c9"))
  #dnode(262pt, 6pt, 76pt, 28pt, "Message store\nchat_id + seq")
  #dnode(356pt, 6pt, 88pt, 28pt, "Session registry\nuser to box")
  #dnode(168pt, 62pt, 76pt, 26pt, "Delivery\nworkers")
  #dnode(262pt, 62pt, 76pt, 26pt, "Offline check")
  #dnode(356pt, 62pt, 88pt, 26pt, "Design 3\nnotifications", fill: rgb("#f0ece2"))
  #dnode(0pt, 112pt, 58pt, 26pt, "Recipient\ndevices")
  #dnode(76pt, 112pt, 74pt, 26pt, "WS gateway")
  #dnode(168pt, 112pt, 76pt, 26pt, "Cursor store\nper device", fill: rgb("#f0ece2"))

  #darrow(58pt, 19pt, 76pt, 19pt)
  #darrow(150pt, 19pt, 168pt, 19pt)
  #darrow(244pt, 20pt, 262pt, 20pt)
  #darrow(206pt, 34pt, 206pt, 62pt)
  #darrow(244pt, 75pt, 262pt, 75pt)
  #darrow(330pt, 68pt, 384pt, 34pt)
  #darrow(338pt, 75pt, 356pt, 75pt)
  #darrow(168pt, 80pt, 113pt, 112pt)
  #darrow(76pt, 125pt, 58pt, 125pt)
  #darrow(150pt, 125pt, 168pt, 125pt)

  #place(dx: 248pt, dy: 38pt)[#text(size: 7.5pt, fill: dc)[append]]
  #place(dx: 248pt, dy: 92pt)[#text(size: 7.5pt, fill: dc)[connected?]]
  #place(dx: 344pt, dy: 92pt)[#text(size: 7.5pt, fill: dc)[if offline]]
  #place(dx: 330pt, dy: 42pt)[#text(size: 7.5pt, fill: dc)[lookup]]
  #place(dx: 96pt, dy: 90pt)[#text(size: 7.5pt, fill: dc)[push]]
  #place(dx: 154pt, dy: 142pt)[#text(size: 7.5pt, fill: dc)[cursor]]
  #place(dx: 0pt, dy: 142pt)[#text(size: 7.5pt, fill: dc)[deliver]]

  #place(dx: 0pt, dy: 162pt)[#text(size: 8pt, fill: muted)[A reconnecting device sends only its cursor. The gateway replays what it missed from the message store — no per-user inbox exists.]]
  #place(dx: 0pt, dy: 172pt)[#text(size: 8pt, fill: muted)[If no device for a recipient is connected, the delivery worker hands the message to the notification system of Design 3.]]
]

Trace one group message:
+ The sender's device writes a `send` frame with a `clientMsgId` it generated itself.
+ Its gateway box forwards it to the chat service instance that *owns* that `chat_id`. Owning
  it is what makes the next step safe.
+ The chat service increments `seq:{chatId}` and appends one row. If the `clientMsgId` already
  exists, it skips the append and returns the original sequence. Either way the sender gets an
  `ack` with a number.
+ The delivery worker reads the 25 members, looks each up in the session registry, and for
  every connected device writes the frame to the box holding that socket.
+ Members with no connected device go to the notification system from Design 3, as a push with
  `class: "transactional"` and a short `expiresAt` — a chat notification that arrives an hour
  late is noise.
+ Each receiving device sends back a `delivered` receipt, and later a `read` receipt when the
  chat is on screen. Both are ordinary messages flowing the other way, and both are batched.

#subsection[Step 6 — Deep dive]

*Deep dive A: order comes from one writer, never from a clock.*

#code(lang: "js", caption: "chat-order.js — run with: node chat-order.js")[
```js
class ChatPartition {                 // ONE writer owns a chat_id, so seq is safe
  constructor() { this.seq = new Map(); this.log = []; this.seen = new Map(); }

  append(chatId, senderId, clientMsgId, text, clientTs) {
    const key = chatId + "|" + clientMsgId;
    if (this.seen.has(key)) return this.seen.get(key);   // the retry gets the SAME row
    const n = (this.seq.get(chatId) ?? 0) + 1;
    this.seq.set(chatId, n);
    const row = { chatId, seq: n, senderId, clientMsgId, text, clientTs };
    this.log.push(row);
    this.seen.set(key, row);
    return row;
  }
  since(chatId, cursor) {
    return this.log.filter(r => r.chatId === chatId && r.seq > cursor);
  }
}

const p = new ChatPartition();
// Asha's phone clock is 90 seconds FAST. Bo's is correct.
p.append("c1", "asha", "m1", "are you coming?",  1_000_090_000);
p.append("c1", "bo",   "m2", "coming now",       1_000_005_000);
p.append("c1", "asha", "m3", "great",            1_000_120_000);
p.append("c1", "bo",   "m2", "coming now",       1_000_005_000);  // network retry

console.log("by client clock (WRONG):");
for (const r of [...p.log].sort((a, b) => a.clientTs - b.clientTs))
  console.log("  ", r.senderId.padEnd(5), r.text);

console.log("by server sequence (RIGHT):");
for (const r of [...p.log].sort((a, b) => a.seq - b.seq))
  console.log("  ", String(r.seq).padEnd(2), r.senderId.padEnd(5), r.text);

console.log("rows stored:", p.log.length, "- the retry did not create a fourth");
console.log("Bo reconnects with cursor 1, gets:",
  p.since("c1", 1).map(r => r.seq).join(", "));
```
]

#code(lang: "js", caption: "actual output")[
```text
by client clock (WRONG):
   bo    coming now
   asha  are you coming?
   asha  great
by server sequence (RIGHT):
   1  asha  are you coming?
   2  bo    coming now
   3  asha  great
rows stored: 3 - the retry did not create a fourth
Bo reconnects with cursor 1, gets: 2, 3
```
]

Three things are proved by that output:
+ A 90-second clock skew — utterly normal on real phones — makes the answer appear *before*
  the question. Client timestamps are for display, never for ordering.
+ The duplicate `send` produced no fourth row, because `(chat_id, client_msg_id)` is unique.
+ A reconnecting device asks for "after 1" and gets exactly 2 and 3. No inbox, no per-user
  copy, no deduplication needed on the client.

#trap[
*One writer per chat is a real constraint, not a diagram detail.* If two chat-service
instances can both append to chat `c1`, they will both compute sequence 41, and two different
messages will share a number. Route by `chat_id` — consistent hashing, or a partition
assignment held in the coordination service — so that at any moment exactly one instance owns
a chat. When ownership moves, the new owner reads `MAX(seq)` from the store before accepting
anything, and the old owner must have stopped first. This is the same "single writer" rule
that makes Kafka partitions and database shards work.
]

*Deep dive B: at-least-once delivery that feels exactly-once.*

You cannot have exactly-once delivery over a network. What you can have is at-least-once
delivery plus an identifier that makes duplicates harmless. Three places need it, and they are
three different identifiers:

#table(columns: (auto, 1fr, 1fr),
  [*Duplicate source*], [*What stops it*], [*Where it lives*],
  [The sender retries after a lost ack],
    [`client_msg_id`, unique per chat],
    [a unique index on `(chat_id, client_msg_id)`],
  [A delivery worker retries after a lost push],
    [`seq` — the device ignores anything at or below its cursor],
    [the device, in one integer comparison],
  [Two delivery workers pick up the same message],
    [the push is idempotent by `(device_id, chat_id, seq)`],
    [nothing is stored; the device discards the second copy],
)

*The three ticks, and what each really means.* `sent` is "the server assigned a sequence".
`delivered` is "at least one of the recipient's devices acknowledged the frame". `read` is
"the chat was on screen". They are three different facts and users understand the difference,
so do not collapse them. Receipts are *batched*: a device that receives 40 messages sends one
receipt naming the highest sequence, not 40 receipts. Without batching, receipts would triple
the delivery load for no benefit —
$1,097,222 times 2 = 2,194,444$ extra frames/second at peak.

*Deep dive C: presence and typing, the two features that can melt the fleet.*

Naive presence: every device heartbeats every 30 seconds and the server fans the result out.
$ 12,500,000 \/ 30 = 416,667 "heartbeats/second" $
and if each one were broadcast to that user's contacts, multiply by a hundred. That is larger
than the entire message workload, for a green dot.

*Decision: the gateway already knows who is connected — derive presence from the connection,
publish only changes, and fan out only to people who currently have that chat open.*
+ The socket opening is the `ONLINE` event. The socket closing is the `OFFLINE` event. No
  separate heartbeat is needed for presence at all; the 30-second heartbeat exists only to
  detect dead sockets on the server side, and it never leaves the gateway box.
+ A state *change* is published, not a state. A user who stays online for an hour generates
  two events, not 120.
+ Fan-out is limited to sessions with that chat in the foreground. A user with 400 contacts
  generates presence traffic to the two people currently looking at their chat.
+ Typing indicators are fire-and-forget: never stored, never retried, never queued, and
  rate-limited to one per 5 seconds per chat with the token bucket from Piece 3. A dropped
  typing indicator costs nothing; a queued one is worse than useless, because it arrives
  after the message it was predicting.

#subsection[Step 7 — Trade-offs, failures, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Storage shape], [one row per recipient], [one row per chat + a cursor],
    [*B* — 438 TB/year instead of 3.46 PB, and no inbox to rebuild],
  [Ordering], [client timestamps], [a per-chat sequence from one writer],
    [*B* — phone clocks are wrong, often by minutes],
  [Transport], [HTTP long-poll], [WebSocket],
    [*B* — 12.5 million sockets is 188 boxes; long-polling the same users is far worse],
  [Cursor granularity], [per user], [per device],
    [*B* — a phone and a laptop are genuinely at different places in the chat],
  [Delivery guarantee], [exactly-once], [at-least-once + ids],
    [*B* — exactly-once over a network does not exist; make duplicates harmless instead],
  [Presence], [heartbeat and broadcast], [derive from the connection, publish changes],
    [*B* — 416,667 events/s versus a few thousand],
  [Receipts], [one per message], [batched to the highest sequence],
    [*B* — saves 2.19 million frames/second at peak],
  [Encryption], [end-to-end], [transport only],
    [*B* for this product, and I say the cost out loud: no server-side search, no history on a
     new device. If the product is privacy-first, choose A and lose those features.],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [One gateway box dies],
    [100,000 users reconnect],
    [Clients back off a random 0 to 30 s, so reconnects arrive at
     $100,000 \/ 30 = 3,333$/second instead of all at once. Each one replays from its cursor,
     so nothing is lost.],
  [A whole zone dies],
    [4.17 million reconnect],
    [The same mechanism, but 30 seconds is not enough:
     $4,166,666 \/ 30 = 138,889$/s would be a second outage. Widen the backoff to 300 s
     $arrow.r 13,889$/s. The backoff window must be sized for the *largest* failure, not the
     likeliest one.],
  [The chat-service owner of a chat crashes],
    [That chat stalls for a few seconds],
    [A new owner is assigned, reads `MAX(seq)` from the store, and resumes. Senders retry with
     the same `clientMsgId`, so nothing duplicates.],
  [A device is offline for a week],
    [A long catch-up],
    [It sends one cursor and pages history 200 at a time. Cap the replay at the last 1,000
     messages per chat and let the rest load on scroll.],
  [A 500-member group gets a burst],
    [Nothing],
    [500 pushes for one message is 500 socket writes across up to 188 boxes — a rounding
     error against 1.1 million/second. Group *size* was never the scaling problem.],
  [A user is added to a group with 5 years of history],
    [They see nothing before they joined],
    [`joined_at_seq` caps the read. This is a privacy decision as much as a storage one, and
     it must be explicit.],
  [The push provider is slow],
    [Offline users are notified late],
    [It is Design 3's problem, with Design 3's answer: its own queue, its own retry budget,
     and an `expiresAt` so a stale chat notification is dropped instead of delivered.],
)

*At 10x (40 billion messages/day, the same 100 million users messaging far more):*
- Sends become $40,000,000,000 \/ 86,400 = 462,963$/s average and $1,388,889$/s at peak.
- Deliveries become $40,000,000,000 times 7.9 \/ 86,400 = 3,657,407$/s average and
  $10,972,222$/s at peak.
- Users are online 3 hours a day rather than 90 minutes:
  $100,000,000 times 180 \/ 1,440 = 12,500,000$ average, 25 million at peak, which is
  $25,000,000 \/ 100,000 = 250$ boxes of load and 375 provisioned.
- Per box that is $10,972,222 \/ 375 = 29,259$ pushes/second and
  $29,259 times 400 = 11.7$ MB/s $= 94$ Mbps. The bandwidth is fine; 29,259 individual socket
  writes a second is not comfortable. *Decision: coalesce per socket — buffer up to 50 ms and
  send one frame containing several messages.* A 50 ms delay is invisible in a chat and it cuts
  the number of writes by roughly the number of messages per burst.
- Storage becomes 12 TB/day and 4.38 PB/year. *Decision: 30 days on fast storage, the rest in
  object storage behind the same history API, and a hard one-year server-side retention with
  the device keeping anything older.*
- The genuinely new problem at 10x is *geography*. A group with members in three continents
  cannot have its single writer near everybody. *Decision: give each chat a home region chosen
  by where the majority of its members are, forward writes there, and serve reads from a local
  async replica.* A member on the far side pays 150 ms extra to *send* and nothing to read.
  The alternative — a global consensus round per message — would put 150 ms on every message
  for everyone to make a rare case slightly fairer.
]
]

#section[Interview drill — what the interviewer pushes on]

#table(columns: 2, align: (left, left),
  [*They ask*], [*You answer*],
  ["Why not just hash the URL?"],
    ["Because hashes collide and detecting a collision is a read on the write path. With 3.5
     trillion slots and 10 million inserts a day, the birthday bound puts the first collision
     inside the first day. A counter handed out in blocks of 1,000 has zero collisions by
     construction and one coordination call per 1,000 links."],
  ["Where does the rate-limit count live?"],
    ["In a shared store, never per pod. Per-pod with the full limit lets 20 pods allow 20x the
     limit; per-pod with limit-over-N gives a pinned client 5% of what they paid for. Both
     mistakes are invisible with one pod in a test."],
  ["Show me the race in a rate limiter."],
    ["Read, decide, write is three steps with a gap. Fifty concurrent requests against a limit
     of 10 all read zero and all write one — 50 allowed, and the counter says 1. The fix is
     one atomic script in the store, which is the same token-bucket arithmetic moved to where
     the data is."],
  ["Your API does 70,000 checks a second. Is that 70,000 Redis calls?"],
    ["No. Each gateway pod leases a block of tokens, the same trick as the id blocks in the
     shortener. Under the limit that is 20x fewer calls. Over the limit the saving drops to
     about 5x, which is why a pod that gets an empty lease goes quiet for 200 ms."],
  ["What happens when the rate limiter's store is down?"],
    ["Fail open, with each pod falling back to a local bucket at limit-over-N so the worst
     case is still roughly the true limit — except for login and OTP, which fail closed in
     code. A limiter outage must never become an API outage."],
  ["A campaign sends 20 million messages. What happens to an OTP?"],
    ["With one queue it waits 20,000,000 divided by 5,787, which is 58 minutes against a
     10-second promise. With one queue per class and reserved workers it waits 0.43 seconds,
     and the campaign takes 1.92 hours instead — I made the unimportant thing slower on
     purpose."],
  ["Your SMS provider is contracted at 1,000 a second. Now what?"],
    ["A token bucket per provider enforces it in my code instead of discovering it through
     their 429s, OTP holds a reserved 500 a second of it, and campaigns are spread over a
     window. And marketing does not use SMS at all unless the user has no push token, because
     the same message costs 12 paise one way and nothing the other."],
  ["How do you know a notification arrived?"],
    ["I do not, until the receipt webhook says so. The provider's 200 means accepted, not
     delivered. I alarm when the delivered-to-sent ratio for a provider falls more than 20%
     below its 7-day baseline."],
  ["Fan out on write or on read?"],
    ["Both, split at 100,000 followers. Five hundred accounts would otherwise be 65% of all
     inbox writes, and a single two-million-follower post would occupy the fan-out queue for
     ten seconds while everyone else waits. Below the threshold push; above it write once and
     let readers pull."],
  ["Two thirds of your fan-out is never read. Fix it."],
    ["Push only to followers seen in the last 7 days. Filtering to today's actives would be
     cheaper still, but then a user returning tomorrow opens an empty app, and that is the one
     user you most want to keep."],
  ["Someone with two million followers deletes a post."],
    ["One write. `deleted_at` is set and the read path filters it during hydrate. Deleting two
     million inbox rows would be exactly the burst I designed the threshold to avoid, happening
     while the user watches and expects it to be instant."],
  ["Why does chat store one copy and the feed stores many?"],
    ["Because of who reads. A chat message has a handful of recipients and every one of them
     will read it, so a shared row plus a per-device cursor is 7.9 times less storage. A post
     has thousands of followers and two thirds never come back, so pre-building the answer is
     worth it only for the ones who will."],
  ["Who decides message order?"],
    ["One writer per chat, assigning a gapless sequence. Phone clocks are wrong by minutes, so
     ordering by client timestamp puts the answer before the question. When chat ownership
     moves, the new owner reads the max sequence first and the old owner must already have
     stopped."],
  ["Can you promise exactly-once delivery?"],
    ["No — nobody can, over a network. I deliver at-least-once and make duplicates harmless:
     a unique `(chat_id, client_msg_id)` stops the sender's retry, and the device ignores any
     sequence at or below its cursor."],
  ["A whole availability zone dies. Describe the next 60 seconds."],
    ["4.17 million sockets drop and every client wants to reconnect. Spread over 30 seconds
     that is 138,889 reconnects a second, which is a second outage, so the backoff window is
     300 seconds instead. Each device replays from its own cursor, so nothing is lost — only
     delayed."],
)

#trap[
The most common Tier-3 failure in this chapter is *choosing one fan-out strategy and defending
it*. Push and pull are both correct, for different users, in the same system, at the same
moment — and a candidate who says "I would use fan-out on write" without naming the follower
count at which they stop has not answered the question. The threshold, and the arithmetic that
picks it, *is* the answer.
]

#practice(tier: 3, time: "50 min")[
+ Design the rate limiter's *cost* dimension: a search request costs 5 tokens and a cheap read
  costs 1. Say what changes in the lease, in `Retry-After`, and in what a client sees.
+ A notification campaign must respect quiet hours in 40 countries, a per-user frequency cap
  of 3 marketing messages a week, and a legal opt-out. Say where each check happens and why it
  cannot happen anywhere else.
+ Compute the cost of raising the news-feed inbox cap from 200 to 1,000 entries: memory, write
  amplification, and what the user gains. Then decide.
+ Add message search to the chat design without end-to-end encryption, then say exactly what
  breaks if the product later adds it.
+ A bug pushed 400 million inbox rows pointing at a post that was deleted an hour ago. Write
  the runbook for the first hour, the first day and the first week.
]
#key[
+ The lease must be requested in *tokens*, not requests, so a pod leases 20 tokens and can
  serve twenty cheap reads or four searches with it. `Retry-After` uses the Piece 3 formula
  with the *cost* of the request that was refused, so a search waiting for 5 tokens at 10
  tokens/second waits 500 ms while a cheap read waits 100 ms. What the client sees is the
  honest part: publish the cost of each endpoint in the docs, or callers cannot predict their
  own limits and will assume you are broken.
+ Quiet hours: at *send* time, converted from the user's current time zone, because both the
  zone and the setting can change during a 2-hour spread. Frequency cap: at *send* time too,
  against a counter keyed by user and week — checking it at campaign-build time would let two
  overlapping campaigns each pass. Legal opt-out: at send time *and* enforced by the database,
  because it is the one check where being slightly stale is a legal problem rather than a
  product one.
+ Memory goes from $200,000,000 times 200 times 50 = 2$ TB to
  $200,000,000 times 1,000 times 50 = 10$ TB — 20 nodes become 100. Write amplification does
  *not* change: you still write the same number of rows, you just trim less often. The user
  gains 5x the scrollback, which at 8 new posts a day is 125 days instead of 25 — far more
  than anyone scrolls. *Decision: no.* Raise it to 600 only for weekly-active users, where the
  gap between visits genuinely exceeds the cap.
+ Search needs an inverted index per user over the chats they are in, built by a consumer of
  the same message stream, partitioned by `user_id` rather than `chat_id` — the only place in
  the design that is not chat-partitioned, and you should say so. If end-to-end encryption is
  added later, the server sees only ciphertext and this index becomes impossible: search must
  move onto the device, over the history that device holds, which means it can no longer find
  anything from before that device was added. That is the honest trade, and it is why the
  encryption decision has to be made in Step 1 and not bolted on.
+ *First hour:* stop the fan-out workers for that post id, confirm the post is really
  tombstoned, and verify that readers are *not* seeing it — the tombstone filter should already
  be hiding it, which turns an incident into a cleanup. *First day:* leave the rows alone.
  400 million rows at 50 bytes is 20 GB across 20 nodes, 1 GB each, and they age out within
  14 days by themselves. Deleting them would be 400 million writes to fix a cosmetic problem.
  *First week:* add the assertion that would have caught it — a fan-out worker must refuse any
  post whose `deleted_at` is set — and a metric on rows written per post id, alarming above
  100,000, which is exactly the threshold that should have sent it down the pull path anyway.
]

#revision[
*The seven steps, with minutes.* Clarify 5 · estimate 5 · API 5 · data model 5 · diagram 8
· deep dive 10 · trade-offs 7. Say the step name out loud before you do it.

*The estimation card.*
#table(columns: (auto, 1fr, auto, 1fr),
  [1 day], [86,400 s ($approx 10^5$)], [1 M/day], [$approx 11.6$/s],
  [1 B/day], [$approx 11,574$/s], [peak factor], [2--3x global, 5--10x one country],
  [1 KB $times$ 1 M], [1 GB], [1 KB $times$ 1 B], [1 TB],
  [1 Mbps], [0.125 MB/s], [MySQL box], [\~5,000 writes/s, \~20,000 reads/s],
  [Redis box], [\~100,000 ops/s], [WebSockets/box], [\~100,000 held],
)
The shortcut: write the daily count in millions and multiply by 11.6. It is within 0.3%
and it takes two seconds.

*The five pieces this chapter built, and what each is really for.*
#table(columns: (auto, 1fr),
  [base62 encoder], [turns a number into a short, URL-safe string. $62^7 approx 3.5$
  trillion codes — seven characters is plenty, and you should say the power out loud.],
  [key blocks], [ten servers generate unique ids with *no lock* by claiming a block of
  1,000 at a time. The only coordination is one increment per block, not one per id.
  *The same trick reappears as token leases in Design 2.*],
  [token bucket], [allows a burst up to the capacity, then settles to the refill rate.
  Tiny state: a count and a timestamp. *Used again to shape SMS in Design 3 and to
  rate-limit typing indicators in Design 5.*],
  [sliding window counter], [fixes the fixed-window flaw where a user sends 2x the limit
  across a boundary. More state, more accuracy — buy it only when you must.],
  [notification dispatcher], [one message, several channels, each of them unreliable.
  Dedupe key, retry budget, dead-letter queue. *It is the core of Design 3.*],
)

*The five designs, and the one number each turns on.*
#table(columns: (auto, auto, 1fr),
  [*Design*], [*The number*], [*What it forces*],
  [URL shortener], [100:1 read\:write, $62^7 = 3.5$ trillion],
    [cache first, database second; a counter, never a hash],
  [Rate limiter], [69,444 checks/s on *shared* state],
    [one atomic script in the store, plus leases to touch it 20x less],
  [Notifications], [20 M blast $= 33,333$/s versus a 10-second OTP],
    [one queue per class with reserved workers; shaping beats capacity],
  [News feed], [500 accounts $=$ 65% of all fan-out writes],
    [hybrid push/pull with the threshold at 100,000 followers],
  [Chat], [7.9 deliveries per message, 12.5 M open sockets],
    [store once per chat with a per-device cursor; a sequence from one writer],
)

*The URL shortener in six lines.*
+ *Hashing is not enough.* Hashes collide, and checking for a collision is a read on the
  write path. Generate ids from a coordinated *counter*, handed out in blocks.
+ Redirects outnumber creates by roughly 100 to 1. Design the read path first; it is a
  single cache lookup and a 301/302.
+ The data model is one KV row: `code -> long_url`, plus created-at and owner. There is no
  join anywhere in this system.
+ Cache with consistent hashing so one dead node costs $1\/N$ of keys, not all of them.
  Coalesce concurrent misses so the store is not flooded.
+ A viral link is the *best* case, not the worst — it is one hot key served from memory.
+ At 10x the new problem is *geography*, not load. Replicate asynchronously across regions
  and fall back to the home region on a miss. Synchronous global replication would add
  150 ms to every write to save a rare 150 ms on a read. Wrong trade.

*The rate limiter in five lines.*
+ *Counting per server is always wrong.* The full limit on each of 20 pods allows 20x; the
  limit divided by 20 gives a pinned client 5%. Both hide in a one-pod test.
+ *A check is not a read then a write.* Fifty concurrent requests against a limit of 10 all
  read 0 and all write 1 — 50 allowed, counter says 1. Run the whole check inside the store.
+ *Lease blocks of tokens*, exactly as the shortener leases blocks of ids. 20x fewer store
  calls under the limit, about 5x over it, and a 200 ms quiet period when a lease comes back
  empty.
+ *Fail open with a local cap* at limit-over-N — except login and OTP, which fail closed in
  code, because there the risk is abuse and not cost.
+ `Retry-After` is *computed and jittered*. A fixed value builds a synchronised herd out of
  your own error responses.

*The notification system in five lines.*
+ *One queue per class, with reserved workers.* One shared queue puts an OTP 58 minutes
  behind a 20 million blast: $20,000,000 \/ 5,787 = 3,456$ s. A priority field cannot
  reorder a log after the fact.
+ *The peak is self-inflicted, so shape it.* Spreading a blast over 120 minutes turns
  33,333/s into 2,778/s and costs nothing.
+ *Money is a design input.* 25 million SMS a day at 12 paise is 109.5 crore a year. Route
  to the cheapest channel the user can actually receive.
+ *Retries back off, jitter, and stop.* 1, 4, 16, 64 seconds, then a dead-letter queue.
  Never retry a permanent failure — mark the dead device token and stop.
+ *"Sent" is a claim, "delivered" is evidence.* Receipts arrive by webhook; alarm when the
  delivered-to-sent ratio drops 20% below its 7-day baseline.

*The news feed in five lines.*
+ *Fan-out multiplies a tiny write rate into a huge one.* 92.6 posts/second becomes 18,518
  inbox rows/second, which is the same size as the whole read path.
+ *No single strategy works.* Push below 100,000 followers, pull above it. 500 accounts
  would otherwise be 65% of all writes, and one post would block the queue for 10 seconds.
+ *Push only to followers seen in the last 7 days.* Two thirds of all rows are never read.
+ *Never delete an inbox row.* Tombstone the post and filter on read. One write instead of
  two million, effective on the reader's very next request.
+ *Hydrate in parallel.* Sixty post-cache misses issued together are 8 ms; sixty issued in
  an `await` loop are 300 ms and a broken promise.

*The chat system in five lines.*
+ *Store once per chat, not once per recipient.* 438 TB/year instead of 3.46 PB, and there
  is no inbox to rebuild after a failure.
+ *A cursor per device, not per user.* A phone and a laptop are genuinely in different
  places in the conversation.
+ *Order comes from one writer per chat*, as a gapless sequence. Phone clocks are wrong by
  minutes and will put the answer before the question.
+ *Exactly-once does not exist. Make duplicates harmless.* Unique `(chat_id,
  client_msg_id)` for the sender's retry; the device ignores any sequence at or below its
  cursor.
+ *Derive presence from the connection and publish only changes.* Heartbeat-and-broadcast is
  $12,500,000 \/ 30 = 416,667$ events a second for a green dot.

*Push or pull? The question this chapter answers twice, differently.*
#table(columns: (auto, 1fr, 1fr),
  [], [*News feed*], [*Chat*],
  [Recipients per item], [200, sometimes 2,000,000], [1, sometimes 24],
  [Fraction who will read it], [about a third], [essentially all],
  [Answer], [push — but only below 100,000 followers], [pull, from one shared copy],
  [Why], [pre-building the answer pays when many read it], [copying pays nothing when few do],
)

*Failure modes and the honest answer to each.*
#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*User sees*], [*What you say*],
  [one cache node], [1 ms becomes 6 ms], [consistent hashing; only $1\/N$ of keys go cold],
  [the whole cache tier], [slow but working], [the store is sized for 100% miss at
  *average*, and you shed traffic with 429s while it warms],
  [the id service], [creates fail, redirects fine], [each pod holds unused ids — raise the
  block size to buy seconds of headroom, then 503 and let clients retry],
  [the limiter store], [nothing, briefly], [fail open with a local cap and alarm at once;
  an approximate limit must never become the quiet normal state],
  [an SMS provider], [nothing], [fail over to the second; capacity halves, so the OTP
  reservation makes marketing pause by itself],
  [the fan-out queue], [new posts appear late], [freshness degrades, reads do not — the read
  path never touches the queue],
  [one inbox node], [$1\/20$ of feeds empty], [it is a cache; rebuild it from the follow
  graph and serve pull-based feeds meanwhile],
  [a whole zone of gateways], [4.17 M reconnect], [randomise the backoff over *300* seconds,
  not 30 — size the window for the largest failure, not the likeliest],
)

*JavaScript traps in this chapter.*
+ `sort()` with no comparator sorts numbers as text. Scores, counts and sequences all need
  `(a, b) => a - b`.
+ Read-modify-write across two `await`s is a race, even in single-threaded Node — the gap is
  the network, not the thread.
+ `await` inside a hydration loop turns 8 ms into 300 ms. Build the array of promises and
  `Promise.all` it.
+ `Map` and `Set` keep types and insertion order; a plain object stringifies its keys.
+ Numbers are exact only to $2^53 - 1$. $62^9 = 1.35 times 10^16$ already exceeds it, so a
  9-character code needs `BigInt`.

*Checklist before you say "done".*
+ Showed the division for every number you wrote on the board.
+ Named the *biggest* rate in the system and said where that data lives.
+ Named the atomic primitive that stops a double count or a double assignment.
+ Said which work is on the user's critical path and which is behind a queue.
+ For anything shared across servers: said what happens when the shared thing is down.
+ For anything fanned out: gave the threshold at which you switch strategy, with arithmetic.
+ Gave both sides of every trade-off and then *decided*.

*The sentence that separates a hire from a no-hire.* Never "it depends" and stop. Say
*"it depends on X; I will assume X because Y, so I choose Z; if X were false I would choose
W."* One sentence longer, and it is the whole difference.
]

]
