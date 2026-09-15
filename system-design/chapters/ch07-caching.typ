#import "../../shared/lib/style.typ": *

#chapter(num: 7, title: "Caching & CDNs", tagline: "Keep the answer near the question")[

#section[The idea in one page]

#formulas(title: "The one idea")[
A cache is a *second copy of an answer, stored somewhere closer or faster than the place
that computed it.*

Every design question about caching is really three questions, always in this order:

+ *What do I put in?* (the key, the value, the size)
+ *When does it come out?* (eviction because the cache is full, expiry because the value got old)
+ *What breaks when it is wrong?* (stale data, a stampede on the database, one overheated key)

A student who can answer only the first question sounds like a beginner. A student who
answers all three sounds like an engineer. This chapter is mostly about questions 2 and 3.
]

#subsection[The numbers you must know by heart]

Caching only pays off because the gaps between these numbers are enormous. Memorise the
column on the right; every estimate in this chapter uses it.

#table(columns: (auto, auto, auto),
  [*Where the answer comes from*], [*Typical time*], [*How many fit in 1 second*],
  [CPU L1 cache], [1 nanosecond], [1,000,000,000],
  [Main memory (RAM) on the same box], [100 nanoseconds], [10,000,000],
  [In-process cache (a JS `Map`)], [\~0.1 microseconds], [\~10,000,000],
  [Redis in the same data centre], [0.5 -- 1 millisecond], [\~1,500 per connection],
  [SSD read], [0.1 millisecond], [10,000],
  [Indexed row from a SQL database], [5 -- 15 milliseconds], [\~100],
  [Same-region network round trip], [1 millisecond], [1,000],
  [India to US round trip], [180 milliseconds], [5],
  [CDN edge in the user's own city], [10 -- 30 milliseconds], [\~50],
)

#trick[
The whole business case for caching in one line: *RAM is about 100 times faster than a
database query, and a CDN edge is about 10 times closer than your origin.* If you remember
nothing else, remember "100x" and "10x".
]

#subsection[Where caches live]

#diagram(height: 5.4cm, caption: "The cache ladder. A request stops at the first layer that already has the answer.")[
  #dnode(0pt, 1.5cm, 2.0cm, 1.0cm, "Browser\ncache", fill: rgb("#f7efe4"))
  #darrow(2.05cm, 2.0cm, 2.85cm, 2.0cm)
  #dnode(2.9cm, 1.5cm, 2.0cm, 1.0cm, "CDN edge\n(POP)", fill: rgb("#f7efe4"))
  #darrow(4.95cm, 2.0cm, 5.75cm, 2.0cm)
  #dnode(5.8cm, 1.5cm, 2.0cm, 1.0cm, "Load\nbalancer")
  #darrow(7.85cm, 2.0cm, 8.65cm, 2.0cm)
  #dnode(8.7cm, 1.5cm, 2.2cm, 1.0cm, "App server\n+ local Map")
  #darrow(10.95cm, 2.0cm, 11.75cm, 2.0cm)
  #dnode(11.8cm, 1.5cm, 1.9cm, 1.0cm, "Redis", fill: rgb("#dce9f2"))
  #darrow(13.75cm, 2.0cm, 14.55cm, 2.0cm)
  #dnode(14.6cm, 1.5cm, 1.4cm, 1.0cm, "DB", fill: rgb("#f2dcdc"))

  #dnode(0pt, 0.1cm, 2.0cm, 0.55cm, "0 ms", fill: white)
  #dnode(2.9cm, 0.1cm, 2.0cm, 0.55cm, "20 ms", fill: white)
  #dnode(8.7cm, 0.1cm, 2.2cm, 0.55cm, "0.1 ms", fill: white)
  #dnode(11.8cm, 0.1cm, 1.9cm, 0.55cm, "1 ms", fill: white)
  #dnode(14.6cm, 0.1cm, 1.4cm, 0.55cm, "12 ms", fill: white)

  #dnode(0pt, 3.2cm, 7.0cm, 0.9cm, "static bytes live here:\nimages, JS, CSS, video", fill: rgb("#fbf6ee"))
  #dnode(8.7cm, 3.2cm, 7.3cm, 0.9cm, "dynamic answers live here:\nrows, lists, counts, sessions", fill: rgb("#eef3f7"))
]

#note[
Read that diagram left to right and ask at each box: *what does this layer know that the
next one does not?* The browser knows one user. The CDN knows one city. Redis knows one
region. The database knows the truth. Truth is the slowest thing in the picture.
]

#subsection[The four caching patterns]

#table(columns: (auto, auto, auto, auto),
  [*Pattern*], [*Read path*], [*Write path*], [*Pick it when*],
  [*Cache-aside* (lazy loading)],
  [app checks cache, on miss reads DB and fills cache],
  [app writes DB, then *deletes* the key],
  [default choice; 90% of interviews],
  [*Read-through*],
  [app asks the cache; the cache library fetches from DB itself],
  [same as cache-aside],
  [you use a library/CDN that does the fetch for you],
  [*Write-through*],
  [normal cache read],
  [write to cache *and* DB in one call, DB write is synchronous],
  [reads must never see stale data and writes are rare],
  [*Write-behind* (write-back)],
  [normal cache read],
  [write to cache only; flush to DB in batches later],
  [huge write volume, losing a few seconds of data is acceptable],
)

#trap[
Write-behind is the one that loses data. If the cache node dies before the flush, those
writes are gone forever. Never propose write-behind for money, orders, or inventory.
Propose it for view counts, "last seen at", and analytics rollups -- things where losing
3 seconds of updates costs nothing.
]

#subsection[The five failures, and their fixes]

#table(columns: (auto, auto, auto),
  [*Failure*], [*What it looks like*], [*Fix*],
  [*Stale read*], [user edits a price, still sees the old one], [delete the key on write, short TTL],
  [*Thundering herd* (stampede)], [one popular key expires, thousands of requests hit the DB at once], [singleflight lock, or refresh before expiry],
  [*Hot key*], [one key gets 40% of all traffic, one Redis node melts], [replicate the key with a suffix, or cache it in-process],
  [*Cache penetration*], [requests for keys that do not exist bypass the cache every time], [cache the "not found" answer with a short TTL, or a Bloom filter],
  [*Cache avalanche*], [a million keys expire in the same second, or the cache cluster restarts], [TTL jitter, warm-up on boot, a rate limit in front of the DB],
)

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
A service gets 4,000 requests per second. The cache hit rate is 92%. A cache hit takes
1 ms. A cache miss takes 1 ms (to check the cache) plus 12 ms (to read the DB).

(a) How many requests per second reach the database?
(b) What is the average response time?
]
#sol[
*(a)* A miss happens on $100% - 92% = 8%$ of requests.

$4000 times 0.08 = 320$ requests per second reach the database.

*(b)* Split the average into the two paths and weight each by how often it happens.

$ "avg" = 0.92 times 1 "ms" + 0.08 times (1 + 12) "ms" $
$ "avg" = 0.92 + 1.04 = 1.96 "ms" $
]
#ans[320 QPS to the database; 1.96 ms average response time.]

#note[
Notice how lopsided this is. The 8% of requests that miss contribute $1.04$ ms of the
$1.96$ ms average -- *more than half the average latency comes from less than a tenth of
the traffic.* That is why the tail (p99) of a cached service is so much worse than its
average, and why interviewers ask about p99 and not the mean.
]

#ex(2, tier: 0)[
The same service. The team improves the hit rate from 92% to 97%. Recompute both answers,
and say what changed by how much.
]
#sol[
*Database load:* $4000 times 0.03 = 120$ QPS.

Before it was 320 QPS. $320 / 120 = 2.67$, so the database now does *2.67 times less work*.

*Average latency:*
$ "avg" = 0.97 times 1 + 0.03 times 13 = 0.97 + 0.39 = 1.36 "ms" $

Before it was 1.96 ms. The saving is $1.96 - 1.36 = 0.6$ ms, about 31% faster.
]
#ans[120 QPS (2.67x less DB load); 1.36 ms average (31% faster).]

#trick[
Five percentage points of hit rate sounds small. It cut the database load by almost two
thirds. *Cache work is measured on the miss side, not the hit side.* Going from 92% to 97%
means the misses fell from 8 to 3 -- and $8/3 = 2.67$. Always do the arithmetic on misses.
]

#ex(3, tier: 0)[
A cache holds 3 items and uses LRU eviction. Trace it for this sequence of keys and say
what is in the cache after each step, plus the final hit count.

`A, B, C, A, D, B, A, C`

Every access is a `get`; on a miss, the item is loaded and inserted.
]
#sol[
Write the cache as a list, most-recently-used on the left.

#table(columns: (auto, auto, auto, auto),
  [*Step*], [*Key*], [*Hit or miss*], [*Cache after (MRU $arrow.r$ LRU)*],
  [1], [A], [miss], [A],
  [2], [B], [miss], [B, A],
  [3], [C], [miss], [C, B, A],
  [4], [A], [*hit*], [A, C, B],
  [5], [D], [miss -- evict B], [D, A, C],
  [6], [B], [miss -- evict C], [B, D, A],
  [7], [A], [*hit*], [A, B, D],
  [8], [C], [miss -- evict D], [C, A, B],
)

Hits at steps 4 and 7. That is 2 hits out of 8 accesses.
]
#ans[2 hits, 6 misses; final cache is C, A, B (C most recent).]

#trap[
The most common mistake in this trace is forgetting that a *hit also reorders* the list.
At step 4, A was the oldest item; after the hit it became the newest, which is exactly why
B (not A) got evicted at step 5. An LRU that does not reorder on read is not an LRU.
]

#ex(4, tier: 0)[
Same sequence, same size 3, but now use *LFU* (evict the least frequently used; break ties
by evicting the one inserted earlier). How many hits?
]
#sol[
Track a count for every key in the cache.

#table(columns: (auto, auto, auto, auto),
  [*Step*], [*Key*], [*Result*], [*Counts after*],
  [1], [A], [miss], [A:1],
  [2], [B], [miss], [A:1 B:1],
  [3], [C], [miss], [A:1 B:1 C:1],
  [4], [A], [*hit*], [A:2 B:1 C:1],
  [5], [D], [miss -- tie between B and C at 1, B is older, evict B], [A:2 C:1 D:1],
  [6], [B], [miss -- tie between C and D at 1, C is older, evict C], [A:2 D:1 B:1],
  [7], [A], [*hit*], [A:3 D:1 B:1],
  [8], [C], [miss -- tie between D and B, D is older, evict D], [A:3 B:1 C:1],
)

Same answer here: 2 hits.
]
#ans[2 hits. On this short trace LFU and LRU tie.]

#note[
On a *short* trace the two policies often tie. The difference shows up on long traces:
LFU protects a key that was popular for months, LRU throws it away after one quiet hour.
LFU's weakness is the mirror image -- a key that was hugely popular last year keeps its
high count forever and refuses to leave. Real systems use *LFU with decay*, or the
*TinyLFU / W-TinyLFU* idea: a tiny LRU window in front of an LFU main cache.
]

#ex(5, tier: 0)[
You must cache 500,000 product records. Each record is about 4 KB of JSON.

(a) How much memory for all of them?
(b) Traffic is skewed: 20% of products get 80% of the reads. How much memory for just
those 20%?
(c) Redis adds roughly 30% overhead for keys, pointers and its own structures. What do you
actually provision for the 20% case?
]
#sol[
Use $1 "KB" = 1000$ bytes for estimation. Interviewers expect round numbers, not exact
binary ones.

*(a)* $500{,}000 times 4 "KB" = 2{,}000{,}000 "KB" = 2{,}000 "MB" = 2 "GB"$

*(b)* $20%$ of $500{,}000 = 100{,}000$ records.

$100{,}000 times 4 "KB" = 400{,}000 "KB" = 400 "MB"$

*(c)* $400 "MB" times 1.3 = 520 "MB"$

Round up to a 1 GB instance so there is room to grow and room for replication buffers.
]
#ans[(a) 2 GB (b) 400 MB (c) provision about 520 MB, buy 1 GB.]

#trick[
*The 80/20 rule is the reason caching works at all.* You almost never need to cache
everything. Caching the hot 20% gets you most of the benefit for a fifth of the memory.
When an interviewer asks "how big should the cache be?", the answer is never "the size of
the database" -- it is "the size of the working set", and you estimate the working set
from the traffic skew.
]

#section[Tier 1 · Low-level design: build the cache]
#tier-header(1)

Service-company interviews rarely ask you to design a CDN. They ask you to *write an LRU
cache class*, then bend it: add TTL, make the eviction policy swappable, make it thread
safe. This section is that ladder.

#ex(6, tier: 1, asked: "TCS NQT · pattern")[
Design a class `LRUCache` with `get(key)` and `put(key, value)`, both in $O(1)$ average
time. When the cache is full, the least recently used entry is removed. Also expose hit,
miss and eviction counters.
]

#sol[
*Step 1 -- what does $O(1)$ force on us?*

We need two things at once:

- find a key fast $arrow.r$ that is a hash map
- know which key is oldest, and move a key to "newest" fast $arrow.r$ that is a
  doubly linked list

The classic answer is "hash map + doubly linked list", and in a Java or C++ interview you
would hand-write both. In JavaScript you get the linked list for free: *a `Map` remembers
insertion order*, and `delete` followed by `set` moves a key to the newest position.

*Step 2 -- the class.*
]

#code(lang: "js", caption: "An LRU cache in 25 lines, using Map insertion order")[
```js
class LRUCache {
  constructor(capacity) {
    this.cap = capacity;
    this.map = new Map();            // key -> value, oldest first
    this.hits = 0; this.misses = 0; this.evictions = 0;
  }

  get(key) {
    if (!this.map.has(key)) { this.misses++; return undefined; }
    const val = this.map.get(key);
    this.map.delete(key);            // pull it out...
    this.map.set(key, val);          // ...and put it back as the newest
    this.hits++;
    return val;
  }

  put(key, val) {
    if (this.map.has(key)) this.map.delete(key);
    else if (this.map.size >= this.cap) {
      const oldest = this.map.keys().next().value;   // first key = least recent
      this.map.delete(oldest);
      this.evictions++;
    }
    this.map.set(key, val);
  }

  get hitRate() {
    const total = this.hits + this.misses;
    return total === 0 ? 0 : this.hits / total;
  }
  keysNewestFirst() { return [...this.map.keys()].reverse(); }
}
```
]

#code(lang: "js", caption: "The test that proves it works")[
```js
const c = new LRUCache(3);
c.put(1, 'one'); c.put(2, 'two'); c.put(3, 'three');
c.get(1);                 // 1 is touched, so 2 is now the oldest
c.put(4, 'four');         // cache is full -> evict 2
console.log('newest -> oldest:', c.keysNewestFirst());
console.log('get(2) =', c.get(2));
console.log('hits', c.hits, 'misses', c.misses, 'evictions', c.evictions);
```
]

#code(lang: "text", caption: "node lru.js")[
```text
newest -> oldest: [ 4, 1, 3 ]
get(2) = undefined
hits 1 misses 1 evictions 1
```
]

#complexity(time: "get and put are O(1) average", space: "O(capacity)",
  note: "Map.delete and Map.set are both O(1) average. keys().next() is O(1) — it does not copy the key list.")

#trap[
`this.map.keys()` returns an *iterator*, not an array. `next().value` gives you the first
key in $O(1)$. If you write `[...this.map.keys()][0]` instead, you copy every key into a
new array on *every eviction* and your $O(1)$ becomes $O(n)$. This exact line is what
interviewers look at.
]

#trap[
In a Java or C++ interview you will be asked to write the doubly linked list by hand,
because `HashMap` there has no insertion order (`LinkedHashMap` does, and saying so scores
a point). Know both answers: *"in JS, Map order gives it to me; in Java I would use
`LinkedHashMap` with `accessOrder = true`, or hand-roll a `HashMap<K, Node>` plus a
doubly linked list."*
]

#ex(7, tier: 1, asked: "Infosys · pattern")[
Your reviewer says: "Good. Now the product team wants LFU instead of LRU on one endpoint,
and maybe FIFO on another. Do not copy-paste the class three times."

Redesign so the eviction rule can be swapped without touching the cache.
]

#sol[
*Step 1 -- name the thing that varies.* Only one thing changes between LRU, LFU and FIFO:
*who leaves next.* Storage, counters, capacity check -- all identical.

*Step 2 -- pull that one thing behind a small interface.* This is the *Strategy pattern*
from Chapter 4. The policy never touches values; it only tracks keys.

*Step 3 -- the interface has exactly four methods.* If you find yourself needing a fifth,
you have leaked storage concerns into the policy.
]

#code(lang: "js", caption: "Strategy pattern: the cache holds a policy it knows nothing about")[
```js
// ---- the plug: four small methods, nothing about storage ----
class EvictionPolicy {
  touched(key) {}          // key was read
  added(key)   {}          // key entered the cache
  removed(key) {}          // key left the cache
  victim()     { return null; }   // who leaves next
}

// ---- plug 1: least recently used ----
class LruPolicy extends EvictionPolicy {
  constructor() { super(); this.order = new Map(); }   // insertion order = recency
  touched(key) { this.order.delete(key); this.order.set(key, true); }
  added(key)   { this.order.set(key, true); }
  removed(key) { this.order.delete(key); }
  victim()     { return this.order.keys().next().value; }
}

// ---- plug 2: least frequently used ----
class LfuPolicy extends EvictionPolicy {
  constructor() { super(); this.count = new Map(); }
  touched(key) { this.count.set(key, this.count.get(key) + 1); }
  added(key)   { this.count.set(key, 1); }
  removed(key) { this.count.delete(key); }
  victim() {
    let best = null, low = Infinity;
    for (const [k, n] of this.count) if (n < low) { low = n; best = k; }
    return best;
  }
}

// ---- the cache never asks which plug it is holding ----
class Cache {
  constructor(capacity, policy) {
    this.cap = capacity; this.policy = policy; this.store = new Map();
    this.hits = 0; this.misses = 0; this.evictions = 0;
  }
  get(key) {
    if (!this.store.has(key)) { this.misses++; return undefined; }
    this.policy.touched(key); this.hits++;
    return this.store.get(key);
  }
  put(key, val) {
    if (this.store.has(key)) { this.store.set(key, val); this.policy.touched(key); return; }
    if (this.store.size >= this.cap) {
      const v = this.policy.victim();
      this.store.delete(v); this.policy.removed(v); this.evictions++;
    }
    this.store.set(key, val); this.policy.added(key);
  }
  has(key) { return this.store.has(key); }
}
```
]

#code(lang: "js", caption: "Same cache, two different plugs, two different survivors")[
```js
const lru = new Cache(2, new LruPolicy());
lru.put('a', 1); lru.put('b', 2);
lru.get('a');                     // a is recent, b is stale
lru.put('c', 3);                  // evicts b
console.log('LRU  keeps a?', lru.has('a'), ' keeps b?', lru.has('b'));

const lfu = new Cache(2, new LfuPolicy());
lfu.put('a', 1); lfu.put('b', 2);
lfu.get('a'); lfu.get('a');       // a used 3 times, b used 1 time
lfu.put('c', 3);                  // evicts b
console.log('LFU  keeps a?', lfu.has('a'), ' keeps b?', lfu.has('b'));
```
]

#code(lang: "text", caption: "node policy.js")[
```text
LRU  keeps a? true  keeps b? false
LFU  keeps a? true  keeps b? false
```
]

#complexity(time: "LRU: O(1). LFU as written: O(1) for get/put, O(n) for victim()",
  space: "O(capacity) for the store plus O(capacity) for the policy",
  note: "Say the O(n) out loud before the interviewer spots it, then say how you would fix it.")

#subsection[The follow-up you will get: make LFU $O(1)$]

#note[
*The interviewer's question:* "Your `victim()` scans every key. At 100,000 keys that is
100,000 steps per eviction. Fix it."

*The answer:* keep keys grouped by count. Maintain

- `countOf: Map<key, n>` -- the frequency of each key
- `buckets: Map<n, Set<key>>` -- all keys that currently have frequency `n`
- `minCount` -- the smallest `n` that has a non-empty bucket

`touched(key)`: move the key from `buckets[n]` to `buckets[n+1]`. If `buckets[minCount]`
became empty and `n === minCount`, then `minCount++`.

`added(key)`: put it in `buckets[1]` and set `minCount = 1`.

`victim()`: return any key from `buckets[minCount]`. A `Set` gives you one in $O(1)$ with
`values().next().value`.

Every operation is now $O(1)$. The trick is that `minCount` only ever goes up by one on a
touch, and resets to 1 on an insert -- so you never have to search for it.
]

#ex(8, tier: 1, asked: "Capgemini · pattern")[
Add *TTL* (time to live) to the cache: each entry expires after a number of milliseconds.
Then explain why you must add *jitter* to the TTL, with numbers.
]

#sol[
*Step 1 -- store an expiry timestamp, not a countdown.* A countdown needs a timer per key.
A timestamp needs nothing: you compare it on read. This is called *lazy expiry*.

*Step 2 -- delete on read.* If the entry is expired, remove it and report a miss. Do not
return it.

*Step 3 -- jitter.* Suppose 100,000 keys are loaded during a deploy at 10:00:00, all with
a 5-minute TTL. At 10:05:00 *all 100,000 expire in the same millisecond.* The next second
of traffic is a 100% miss rate, and every one of those misses becomes a database query.
That is a *cache avalanche*.

The fix is one line: pick each TTL randomly inside a band around the base value.
]

#code(lang: "js", caption: "TTL with lazy expiry, plus jitter")[
```js
const cacheGet = (k) => {
  const e = redis.get(k);
  if (!e) return undefined;
  if (Date.now() > e.expiresAt) { redis.delete(k); return undefined; }   // TTL expired
  return e.val;
};
const cacheSet = (k, val, ttlMs) => redis.set(k, { val, expiresAt: Date.now() + ttlMs });

// TTL with jitter: never let a million keys expire in the same millisecond.
const jitter = (baseMs, spreadPct = 0.2) => {
  const spread = baseMs * spreadPct;
  return Math.round(baseMs - spread + Math.random() * 2 * spread);
};
```
]

*The arithmetic that justifies jitter.* Base TTL 300,000 ms (5 minutes), spread $plus.minus 20%$.
Expiries now land anywhere in a window of

$ 2 times 0.20 times 300{,}000 = 120{,}000 "ms" = 120 "seconds" $

So 100,000 keys expire spread over 120 seconds instead of all at once:

$ 100{,}000 / 120 approx 833 "expiries per second" $

At a 12 ms database query each, that is $833 times 0.012 = 10$ database queries running
concurrently -- completely survivable. Without jitter it was 100,000 at once.

#ans[Store `expiresAt`, check it on read; jitter every TTL by $plus.minus 20%$ so a
100,000-key avalanche becomes a harmless 833 refreshes per second.]

#code(lang: "text", caption: "node aside.js — three jitter draws from a 300000 ms base")[
```text
three jitter draws from 300000: [ 281577, 266488, 266891 ]
```
]

#ex(9, tier: 1, asked: "Accenture · pattern")[
Write the *cache-aside* read and write paths against a real store. Explain why the write
path *deletes* the key instead of updating it.
]

#sol[
*Step 1 -- the read path.* Check cache. On a miss, read the source, fill the cache, return.

*Step 2 -- the write path.* Write the source *first*, then delete the key. Never the other
way round.

*Step 3 -- why delete and not update?* Two reasons, and you should give both.

*Reason A: a race.* Two writers, W1 setting price 100 and W2 setting price 200.

#table(columns: (auto, auto, auto),
  [*Time*], [*W1*], [*W2*],
  [t1], [writes DB = 100], [],
  [t2], [], [writes DB = 200],
  [t3], [], [sets cache = 200],
  [t4], [sets cache = 100], [],
)

The database says 200. The cache says 100. It stays wrong until the TTL expires. With
*delete* instead of *set*, both writers delete; the next reader loads 200 from the DB.
Delete is idempotent, set is not.

*Reason B: wasted work.* If a product is written 50 times an hour and read once a day,
"update the cache on write" computes and stores 50 values that nobody reads. Delete
computes nothing.
]

#code(lang: "js", caption: "Cache-aside, both paths")[
```js
// ---------- READ: cache-aside ----------
async function getProduct(id) {
  const key = `product:${id}`;
  const hit = cacheGet(key);
  if (hit !== undefined) return { data: hit, from: 'cache' };

  const row = await db.read(id);                  // miss -> go to the source
  cacheSet(key, row, jitter(300_000));            // 5 min, ±20%
  return { data: row, from: 'db' };
}

// ---------- WRITE: change the DB, then DELETE the key (never update it) ----------
async function setPrice(id, price) {
  const row = await db.write(id, price);
  redis.delete(`product:${id}`);                  // invalidate, do not rewrite
  return row;
}
```
]

#code(lang: "text", caption: "node aside.js")[
```text
1 [ 'db', 799 ]
2 [ 'cache', 799 ]
3 [ 'db', 649 ]
4 [ 'cache', 649 ]
db calls = 3
```
]

Read that output line by line. Call 1 misses and costs a DB read. Call 2 hits. Then the
price changes and the key is deleted, so call 3 misses again and picks up the new price
649. Call 4 hits. Four reads and one write cost three database calls instead of five.

#trap[
Order matters and it is a favourite trap. If you *delete the key first and then write the
DB*, a reader can slip in between: it misses, reads the OLD row from the DB, and writes
that old row back into the cache -- after your update. The cache is now stale forever.
*Always: write the source of truth first, invalidate second.*
]

#note[
Even "write DB, then delete" has a rare hole. A reader that missed *before* your write can
still be holding the old row in a local variable, and may write it into the cache *after*
your delete. The fix at serious scale is *delayed double delete*: delete the key, do the
write, wait a few hundred milliseconds, delete again. You should mention this only if the
interviewer pushes -- it signals you know that invalidation is genuinely hard.
]

#section[Tier 2 · Mid-scale: a cached product catalog]
#tier-header(2)

#ex(10, tier: 2, asked: "Shopee · pattern")[
Design the read path for the product catalog of a shopping app. 8 million daily active
users. Product pages must feel instant. The catalog itself changes rarely, but prices and
stock change often.

Walk all seven steps.
]

#sol[
#subsection[Step 1 -- Clarify]

Five questions, and what each one changes:

#table(columns: (auto, auto),
  [*Question I ask*], [*Why the answer changes the design*],
  [How stale may a *price* be?], [If the answer is "zero", I cannot cache the price at all and must split the object. If it is "up to 60 seconds", one short TTL solves it.],
  [How many products, and how big is one?], [This sets the memory bill. 500k x 4 KB is one Redis box; 500M x 4 KB is a cluster.],
  [Read to write ratio?], [200:1 means cache-aside is obviously right. 2:1 would mean the cache is mostly churn and may not be worth it.],
  [Is the traffic skewed, and how badly?], [If the top 1% of products is 50% of traffic, I can cache far less memory -- but I must plan for hot keys.],
  [What is the p99 latency target?], [A 50 ms p99 lets me go to the DB on a miss. A 10 ms p99 means misses must be rare, so I need a higher hit rate and pre-warming.],
)

I will assume: price may be up to 60 seconds stale; 500,000 products at \~4 KB; reads to
writes is 200 to 1; classic 80/20 skew; p99 target 50 ms.

#subsection[Step 2 -- Scale estimate]

*Reads.* Each active user opens about 25 product pages a day.

$ 8{,}000{,}000 times 25 = 200{,}000{,}000 "reads per day" $

$ "average QPS" = 200{,}000{,}000 / 86{,}400 = 2{,}314.8 approx 2{,}300 "QPS" $

Shopping traffic is spiky -- evenings and sale events. Use a 4x peak factor.

$ "peak QPS" = 2{,}314.8 times 4 = 9{,}259 approx 9{,}300 "QPS" $

*Writes.* 500,000 products, each updated about twice a day (price, stock).

$ 500{,}000 times 2 = 1{,}000{,}000 "writes per day" $

$ 1{,}000{,}000 / 86{,}400 = 11.6 "QPS" $

Read : write is $2314.8 : 11.6 approx 200 : 1$. Cache-aside is clearly correct.

*Memory.*

$ "everything" = 500{,}000 times 4 "KB" = 2{,}000{,}000 "KB" = 2 "GB" $
$ "hot" 20% = 100{,}000 times 4 "KB" = 400 "MB" $
$ "with Redis overhead" = 400 times 1.3 = 520 "MB" $

*Bandwidth out of Redis at peak.*

$ 9{,}259 "QPS" times 4 "KB" = 37{,}036 "KB/s" approx 37 "MB/s" = 296 "Mbit/s" $

That is comfortable on a 1 Gbit/s network card, and it tells me one Redis node is enough
for bandwidth. (Whether it is enough for a *hot key* is a different question -- Step 6.)

#subsection[Step 3 -- API surface]
]

#code(lang: "text", caption: "Read API")[
```text
GET /v1/products/{id}
  200 -> { "id":"p_1187", "title":"Steel Kettle 1.5L", "brand":"Nord",
           "images":[...], "attrs":{...},
           "price":{ "amount":64900, "currency":"IDR", "as_of":"2026-09-15T04:10:02Z" },
           "stock":{ "state":"in_stock", "as_of":"2026-09-15T04:10:02Z" } }
  Cache-Control: public, max-age=30, stale-while-revalidate=120
  ETag: "p_1187-v41"

GET /v1/products?ids=p_1,p_2,p_3        <- batch, up to 50 ids, one Redis MGET
  200 -> { "products":[ ... ], "missing":["p_3"] }

PATCH /internal/products/{id}/price      <- called by the pricing service
  body { "amount": 59900 }
  204 No Content   (and the cache key is deleted)
```
]

#note[
Two details that score points. First, `as_of` timestamps: the client can *see* how stale
the price is, which turns an invisible problem into a visible one. Second, the batch
endpoint: a category page showing 40 products would otherwise fire 40 HTTP calls. One
`MGET` of 40 keys costs one round trip instead of forty.
]

#subsection[Step 4 -- Data model]

#table(columns: (auto, auto, auto, auto),
  [*Store*], [*Key*], [*Value*], [*TTL*],
  [Postgres `products`], [`id` (PK)], [title, brand, attrs, images JSONB, `version` int], [--],
  [Postgres `prices`], [`(product_id, region)` (PK)], [amount, currency, `updated_at`], [--],
  [Redis], [`product:{id}:v{version}`], [the full JSON blob], [5 min $plus.minus$ 20%],
  [Redis], [`price:{id}:{region}`], [just the amount], [45 s $plus.minus$ 20%],
  [Redis], [`product:{id}:miss`], [the literal string `"404"`], [30 s],
)

*Three decisions worth defending out loud:*

*(a) Two keys, not one.* The stable part of a product (title, images, attributes) changes
maybe once a month. The price changes many times a day. If they share one key, every price
change throws away 4 KB of stable data that then has to be re-fetched. Splitting them
means a price change invalidates 20 bytes. *Decision: split.* The cost is a second Redis
round trip per page -- but `MGET` fetches both keys in one trip, so the real cost is zero.

*(b) The version in the key.* Writing `product:p_1187:v41` instead of `product:p_1187`
means an update does not have to delete anything: it just starts writing `v42`, and `v41`
ages out by TTL. This makes invalidation across many regions trivial, because there is
nothing to invalidate. *Decision: use versioned keys for the stable blob*, plain keys for
price (where the value is tiny and delete is cheap).

*(c) Caching the miss.* A crawler asking for 10,000 product IDs that do not exist would
otherwise put 10,000 queries a second on the database -- *cache penetration*. Storing the
string `"404"` for 30 seconds stops it dead.

#subsection[Step 5 -- Architecture]

#diagram(height: 7.6cm, caption: "Read path (solid) and invalidation path (dashed) for the catalog service.")[
  #dnode(0pt, 2.4cm, 1.9cm, 1.0cm, "Mobile\napp")
  #darrow(1.95cm, 2.9cm, 2.75cm, 2.9cm)
  #dnode(2.8cm, 2.4cm, 2.1cm, 1.0cm, "CDN\n(images only)", fill: rgb("#f7efe4"))
  #darrow(4.95cm, 2.9cm, 5.75cm, 2.9cm)
  #dnode(5.8cm, 2.4cm, 1.9cm, 1.0cm, "L7 load\nbalancer")
  #darrow(7.75cm, 2.9cm, 8.55cm, 2.9cm)

  #dnode(8.6cm, 1.6cm, 2.6cm, 0.8cm, "catalog-svc 1\n(local Map, 2s)")
  #dnode(8.6cm, 2.6cm, 2.6cm, 0.8cm, "catalog-svc 2\n(local Map, 2s)")
  #dnode(8.6cm, 3.6cm, 2.6cm, 0.8cm, "catalog-svc 3\n(local Map, 2s)")

  #darrow(11.25cm, 2.0cm, 12.15cm, 2.6cm)
  #darrow(11.25cm, 3.0cm, 12.15cm, 2.9cm)
  #darrow(11.25cm, 4.0cm, 12.15cm, 3.2cm)
  #dnode(12.2cm, 2.4cm, 1.9cm, 1.0cm, "Redis\n520 MB", fill: rgb("#dce9f2"))
  #darrow(13.15cm, 3.45cm, 13.15cm, 4.55cm, label: "miss 5%")
  #dnode(12.2cm, 4.6cm, 1.9cm, 0.9cm, "Postgres\nprimary", fill: rgb("#f2dcdc"))

  #dnode(2.8cm, 5.9cm, 2.8cm, 0.9cm, "pricing service")
  #darrow(5.65cm, 6.35cm, 11.6cm, 6.35cm, label: "PATCH price")
  #dnode(11.65cm, 5.9cm, 2.6cm, 0.9cm, "write DB,\nthen DEL key")
  #darrow(12.95cm, 5.85cm, 12.95cm, 5.55cm, dashed: true)
  #darrow(14.0cm, 5.4cm, 14.0cm, 3.5cm, dashed: true)

  #dnode(0pt, 0.0cm, 8.0cm, 0.9cm, "peak 9,300 QPS · 95% hit · Redis 8,835 · DB 465", fill: rgb("#fbf6ee"))
  #dnode(8.6cm, 0.0cm, 5.5cm, 0.9cm, "p99 target 50 ms · measured 1.6 ms avg", fill: rgb("#fbf6ee"))
]

#subsection[Step 6 -- Deep dive 1: how big should the cache be?]

Do not guess. Simulate the traffic skew and read the answer off a table. Here is a
30-line Python program that does it, and its real output.

#code(lang: "python", caption: "hitrate.py — LRU hit rate against a Zipf workload")[
```python
# How big should the cache be? Simulate, do not guess.
import random, bisect
from collections import OrderedDict

random.seed(7)
N, REQ = 100_000, 400_000          # 100k products, 400k reads in the sample

# Zipf: product #1 is asked for about 10x more than product #10.
H = sum(1.0 / i for i in range(1, N + 1))
cum, s = [], 0.0
for i in range(1, N + 1):
    s += 1.0 / i
    cum.append(s / H)
draw = lambda: bisect.bisect_left(cum, random.random()) + 1
reqs = [draw() for _ in range(REQ)]

def lru_hit_rate(capacity):
    c, hits = OrderedDict(), 0
    for k in reqs:
        if k in c:
            c.move_to_end(k); hits += 1
        else:
            c[k] = 1
            if len(c) > capacity:
                c.popitem(last=False)          # drop the least recently used
    return hits / REQ

unique = len(set(reqs))
print(f"distinct keys touched: {unique}  -> every one of them must miss once")
print(f"so the hit rate can never beat {(1 - unique / REQ) * 100:.1f}%")
PEAK = 9259
for cap in (1_000, 5_000, 10_000, 20_000, 50_000):
    hr = lru_hit_rate(cap)
    print(f"cache {cap:>6} keys = {cap * 4 / 1000:>5.0f} MB -> hit {hr*100:>4.1f}% "
          f"-> DB sees {round(PEAK * (1 - hr)):>5} QPS at peak")
```
]

#code(lang: "text", caption: "python3 hitrate.py")[
```text
distinct keys touched: 55840  -> every one of them must miss once
so the hit rate can never beat 86.0%
cache   1000 keys =     4 MB -> hit 50.7% -> DB sees  4567 QPS at peak
cache   5000 keys =    20 MB -> hit 66.4% -> DB sees  3113 QPS at peak
cache  10000 keys =    40 MB -> hit 73.2% -> DB sees  2479 QPS at peak
cache  20000 keys =    80 MB -> hit 79.8% -> DB sees  1870 QPS at peak
cache  50000 keys =   200 MB -> hit 85.9% -> DB sees  1305 QPS at peak
```
]

*Three things to read off that table, and say out loud:*

*(1) Diminishing returns are brutal.* Going from 1,000 to 5,000 keys (4 MB to 20 MB) buys
15.7 points of hit rate. Going from 20,000 to 50,000 keys (80 MB to 200 MB) buys only 6.1
points. Memory is linear; benefit is logarithmic.

*(2) There is a ceiling you cannot pass.* In this sample 55,840 distinct keys are touched,
and *each one must miss at least once* -- it has to be loaded before it can be hit. So

$ "best possible hit rate" = 1 - 55{,}840 / 400{,}000 = 1 - 0.1396 = 86.0% $

Any team promising 99% on this workload is either measuring over a longer window (where
each key gets more repeat reads) or is not measuring cold misses.

*(3) A longer window changes the answer.* The 86% ceiling is an artefact of only sampling
400,000 requests. In a day we serve 200 million requests against the same 500,000 products
-- 400 reads per product per day -- so the cold-miss share becomes tiny and real hit rates
of 95%+ are achievable.

*Decision:* provision 520 MB (the hot 20%, with overhead). It sits comfortably past the
knee of the curve, leaves headroom, and costs one small Redis instance. *We are choosing
the flat part of the curve on purpose: buying more memory past this point is paying linear
money for logarithmic benefit.*

At 95% hit rate and 9,300 peak QPS:

$ "Redis QPS" = 9{,}300 times 0.95 = 8{,}835 $
$ "DB QPS" = 9{,}300 times 0.05 = 465 $

A single Postgres primary with an index on the primary key handles 465 QPS without
noticing. *Without the cache it would face 9,300 QPS and fall over.*

Average latency:

$ 0.95 times 1 "ms" + 0.05 times (1 + 12) "ms" = 0.95 + 0.65 = 1.6 "ms" $

#subsection[Step 6 -- Deep dive 2: the thundering herd]

*The problem, with real numbers.* The homepage banner product `p_1187` is getting 1,200
QPS on its own during a flash sale. Its cache key expires. In the 12 ms it takes one
database query to come back, how many more requests arrive and also miss?

$ 1{,}200 "QPS" times 0.012 "s" = 14.4 "concurrent queries for the same row" $

That alone is survivable. Now do it for the whole service at peak, when a deploy flushes
the cache:

$ 9{,}259 "QPS" times 0.012 "s" = 111 "concurrent database queries" $

A typical Postgres connection pool is 50 connections. 111 > 50, so half the requests queue,
latency climbs, clients time out and *retry*, which adds more load. This is how a cache
flush takes down a database.

*The fix: singleflight.* Let exactly one request per key go to the database. Everyone else
waits on the same promise.

#code(lang: "js", caption: "singleflight.js — 500 callers, one database query")[
```js
class SingleFlight {
  constructor() { this.inFlight = new Map(); }   // key -> promise
  run(key, work) {
    if (this.inFlight.has(key)) return this.inFlight.get(key);   // join the queue
    const p = work().finally(() => this.inFlight.delete(key));   // always clean up
    this.inFlight.set(key, p);
    return p;
  }
}

async function getProduct(id) {
  const key = `product:${id}`;
  if (cache.has(key)) return cache.get(key);
  return sf.run(key, async () => {
    if (cache.has(key)) return cache.get(key);   // someone filled it while we waited
    const row = await loadFromDb(id);
    cache.set(key, row);
    return row;
  });
}
```
]

#code(lang: "text", caption: "node singleflight.js")[
```text
all callers got the same value: true
DB queries fired: 1
DB queries without singleflight: 500
```
]

#trap[
Two lines in that code are not decoration.

`.finally(() => this.inFlight.delete(key))` -- without it, a *failed* fetch leaves a
rejected promise in the map forever, and every future caller gets the same old error. The
cache becomes permanently broken for that key.

The *second* `cache.has(key)` check inside the worker -- the "double-check". Between
joining and running, another flight may have already filled the cache.
]

#note[
*Singleflight is per process.* With 3 app servers you get 3 database queries per expiry,
not 1. That is fine -- 3 is not 111. If you truly need exactly one, take a short Redis
lock (`SET lock:key token NX PX 5000`) and let the losers sleep 20 ms and re-read. Say
this only if asked; the per-process version is the right default because it needs no
extra network call.
]

*The better fix, when you can use it: refresh before expiry.* Instead of waiting for the
key to die, serve the slightly-old value and refresh in the background:

#table(columns: (auto, auto),
  [*Strategy*], [*What the user sees on an expiry*],
  [Plain TTL], [one user waits 12 ms; 110 others queue behind the DB],
  [Singleflight], [one user waits 12 ms; 110 others wait 12 ms on the *same* query, DB does 1 query],
  [Stale-while-revalidate], [*nobody waits.* Everyone gets the old value in 1 ms; one background job refreshes],
)

*Decision: use both.* Serve stale for up to 120 seconds past expiry (`stale-while-revalidate=120`
in the header, and the same rule inside Redis by storing a `softExpiresAt` next to
`expiresAt`), and guard the background refresh with singleflight. Prices may be 60 seconds
stale by requirement, so serving a 90-second-old price for one extra millisecond is inside
budget. *We accept up to 2 minutes of staleness in exchange for never making a user wait
on a database.*

#subsection[Step 7 -- Trade-offs, failures, and 10x]

#table(columns: (auto, auto, auto, auto),
  [*Decision*], [*Chosen*], [*Rejected*], [*Why*],
  [Pattern], [cache-aside], [write-through], [200:1 read ratio means most writes would cache data nobody reads; and write-through couples every write to cache availability],
  [Invalidate], [delete the key], [update the key], [delete is idempotent, so concurrent writers cannot interleave into a wrong final value],
  [Price storage], [separate short-TTL key], [inside the product blob], [a price change would otherwise throw away 4 KB of stable data],
  [Local in-process cache], [yes, 2-second TTL], [Redis only], [it absorbs hot keys for free; 2 seconds is short enough that price staleness stays inside the 60-second budget],
  [Herd control], [stale-while-revalidate + singleflight], [distributed Redis lock], [a lock adds a network round trip on the hot path; the cheaper pair already reduces 111 queries to 3],
)

*Failure modes, and what actually happens:*

#table(columns: (auto, auto, auto),
  [*What fails*], [*Blast radius*], [*Our response*],
  [Redis node dies], [hit rate goes to 0; DB faces 9,300 QPS against a 465 QPS budget -- *20x overload*], [the 2-second local cache absorbs repeats; a concurrency limiter caps DB calls at 300 and sheds the rest with `503 Retry-After: 2`; serve stale from local cache where we have it],
  [Redis is slow, not dead (worst case)], [every request pays the Redis timeout *and* the DB], [set a hard 50 ms Redis timeout and treat a timeout as a miss; a circuit breaker skips Redis entirely after 5 timeouts],
  [Postgres primary fails over], [30 -- 60 s of write errors; reads still served from cache], [raise TTLs automatically during a DB outage -- a stale catalog beats no catalog],
  [A bad deploy flushes the cache], [the 111-concurrent-query stampede above], [never flush on deploy; use versioned keys so old and new coexist; warm the top 10,000 products at boot before taking traffic],
  [One product goes viral], [one Redis key gets 3,000 QPS], [the local cache handles it; see Tier 3 for the general fix],
)

*What changes at 10x (80M DAU, 93,000 peak QPS)?*

$ 80{,}000{,}000 times 25 = 2{,}000{,}000{,}000 "reads/day" $
$ 2{,}000{,}000{,}000 / 86{,}400 = 23{,}148 "QPS average" $
$ 23{,}148 times 4 = 92{,}592 "QPS peak" $

Three things break, in this order:

+ *Redis bandwidth.* $92{,}592 times 4 "KB" = 370{,}368 "KB/s" = 370 "MB/s" = 2.96 "Gbit/s"$.
  That is past a single 1 Gbit/s node. *Fix: shard Redis by key hash across 4 nodes*
  ($2.96 / 4 = 0.74$ Gbit/s each), or add read replicas.
+ *Database misses.* $92{,}592 times 0.05 = 4{,}630$ QPS to Postgres. One primary cannot do
  that on 4 KB rows. *Fix: read replicas, 3 of them, $4{,}630 / 3 = 1{,}543$ QPS each.*
+ *Hot keys.* At 10x, a viral product is 10x hotter and the local cache alone will not save
  a single Redis shard. This is the Tier 3 problem.

#section[Tier 3 · Large-scale: a global CDN for images]
#tier-header(3)

#ex(11, tier: 3, asked: "Amazon · pattern")[
The same shopping company now serves 60 million daily active users across India, Indonesia
and Singapore. Each session loads about 40 images averaging 120 KB. Design the image
delivery system. Then handle the two hard cases: a single hot object, and a mistaken upload
that must be removed from every edge in under 60 seconds.
]

#sol[
#subsection[Step 1 -- Clarify]

#table(columns: (auto, auto),
  [*Question*], [*Why it matters*],
  [Are images immutable once uploaded?], [If yes, I can cache them for a year and never invalidate -- this is the single biggest simplification available.],
  [Who may see an image -- everyone, or only some users?], [Public images cache at the edge. Private images cannot, unless I use signed URLs.],
  [How many distinct images, and how skewed is access?], [Sets the edge disk size per POP.],
  [What is the hard purge requirement?], [A legal takedown in 60 seconds is a very different system from "it clears within a day".],
  [Which countries, and is there a data residency rule?], [Residency can forbid caching certain bytes outside a country.],
)

Assume: images are *immutable* (a new upload gets a new URL); public; 50 million distinct
images; 60-second purge requirement for takedowns.

#subsection[Step 2 -- Scale estimate]

*Request rate.*

$ 60{,}000{,}000 times 40 = 2{,}400{,}000{,}000 "image requests/day" $
$ 2.4 times 10^9 / 86{,}400 = 27{,}778 "QPS average" $
$ 27{,}778 times 3 = 83{,}333 "QPS peak" $

*Bytes.*

$ 2.4 times 10^9 times 120 "KB" = 2.88 times 10^14 "bytes/day" = 288 "TB/day" $

$ "bytes per second" = 288 times 10^12 / 86{,}400 = 3.33 times 10^9 = 3.33 "GB/s" $

$ "bits per second" = 3.33 "GB/s" times 8 = 26.7 "Gbit/s average" $

$ "peak" = 26.7 times 3 = 80 "Gbit/s" $

*This number is the whole design.* 80 Gbit/s out of one data centre is possible but
expensive and fragile. 80 Gbit/s spread over 40 edge locations is 2 Gbit/s each, which is
ordinary.

*Origin load, if the CDN hits 90%.*

$ 80 "Gbit/s" times 0.10 = 8 "Gbit/s peak out of origin" $
$ 83{,}333 "QPS" times 0.10 = 8{,}333 "QPS to origin" $

*Storage.*

$ 50{,}000{,}000 times 200 "KB" ("original + thumbnails") = 10 times 10^{12} = 10 "TB in object storage" $

Hot 5% at each edge:

$ 50{,}000{,}000 times 0.05 times 200 "KB" = 500 "GB per POP" $

Half a terabyte of SSD per POP is a normal edge server.

*Per-POP request load with 40 POPs:*

$ 27{,}778 / 40 = 694 "QPS average per POP", quad 83{,}333 / 40 = 2{,}083 "QPS peak per POP" $

*The money argument, which wins the interview.* Say origin egress costs \$0.09 per GB and
CDN egress costs \$0.02 per GB.

$ "bytes per day" = 288{,}000 "GB" $
$ "all from origin" = 288{,}000 times 0.09 = \$25{,}920 "per day" $
$ "90% CDN, 10% origin" = 288{,}000 times 0.9 times 0.02 + 288{,}000 times 0.1 times 0.09 $
$ = 5{,}184 + 2{,}592 = \$7{,}776 "per day" $

*The CDN saves about \$18,144 a day, roughly \$6.6 million a year.* Say that number. It
turns an architecture choice into a business decision, which is what a senior interviewer
is listening for.

#subsection[Step 3 -- API surface]
]

#code(lang: "text", caption: "Public read + private upload")[
```text
GET https://img.cdn.example.com/v1/{imageId}/{width}x{height}.webp
  200 OK
  Cache-Control: public, max-age=31536000, immutable
  ETag: "sha256-9f2c..."
  Vary: Accept
  304 Not Modified   (when If-None-Match matches)

POST /v1/images                       <- origin only, authenticated
  multipart body: file
  201 -> { "imageId":"im_8Kq2", "variants":["320x320","800x800","orig"],
           "url":"https://img.cdn.example.com/v1/im_8Kq2/800x800.webp" }

POST /internal/purge                  <- takedown, authenticated, rate limited
  body { "imageIds":["im_8Kq2"], "reason":"legal" }
  202 -> { "purgeId":"pg_44", "pops":40, "eta_seconds":25 }

GET /internal/purge/{purgeId}
  200 -> { "acked": 40, "pending": 0, "completed_at":"..." }
```
]

*Why `immutable` in the `Cache-Control` header?* It tells the browser not to even send a
revalidation request when the user hits reload. Without it, a reload fires an
`If-None-Match` request per image -- 40 requests that all return `304 Not Modified`. With
it, 40 requests become zero. Because our IDs are content-addressed (the URL contains a
hash), the image at a URL can never change, so this is safe.

#subsection[Step 4 -- Data model]

#table(columns: (auto, auto, auto),
  [*Store*], [*Key*], [*Holds*],
  [Object storage (S3-like)], [`images/{imageId}/{variant}.webp`], [the actual bytes; the source of truth],
  [Postgres `images`], [`image_id` (PK)], [owner, `sha256`, width, height, `uploaded_at`, `status`],
  [Postgres `purges`], [`purge_id` (PK)], [image ids, requested_at, `acked_pops` int],
  [Edge disk (each POP)], [the URL path], [the bytes, plus `last_used_at` for LRU],
  [Edge memory (each POP)], [the URL path], [the hottest \~2 GB],
)

*The key decision: the URL contains a content hash.* `imageId` is derived from the SHA-256
of the bytes. Two consequences:

+ The same image uploaded twice gets the same ID -- free deduplication.
+ An image at a given URL *can never change*, so we never need to invalidate for
  correctness, only for takedowns. Cache invalidation, the famously hard problem, is
  deleted from the design by choosing the right key.

#subsection[Step 5 -- Architecture]

#diagram(height: 8.6cm, caption: "Three POPs, an origin shield, and object storage. Dashed lines are the purge fan-out.")[
  #dnode(0pt, 0.5cm, 2.2cm, 0.85cm, "user · Jakarta")
  #dnode(0pt, 2.0cm, 2.2cm, 0.85cm, "user · Mumbai")
  #dnode(0pt, 3.5cm, 2.2cm, 0.85cm, "user · Singapore")

  #darrow(2.25cm, 0.92cm, 3.35cm, 0.92cm)
  #darrow(2.25cm, 2.42cm, 3.35cm, 2.42cm)
  #darrow(2.25cm, 3.92cm, 3.35cm, 3.92cm)

  #dnode(3.4cm, 0.35cm, 2.9cm, 1.15cm, "POP Jakarta\n500 GB SSD", fill: rgb("#f7efe4"))
  #dnode(3.4cm, 1.85cm, 2.9cm, 1.15cm, "POP Mumbai\n500 GB SSD", fill: rgb("#f7efe4"))
  #dnode(3.4cm, 3.35cm, 2.9cm, 1.15cm, "POP Singapore\n500 GB SSD", fill: rgb("#f7efe4"))

  #darrow(6.35cm, 0.92cm, 7.75cm, 2.1cm, label: "miss 10%")
  #darrow(6.35cm, 2.42cm, 7.75cm, 2.42cm)
  #darrow(6.35cm, 3.92cm, 7.75cm, 2.75cm)

  #dnode(7.8cm, 1.85cm, 2.8cm, 1.15cm, "Origin shield\n(one region)", fill: rgb("#dce9f2"))
  #darrow(10.65cm, 2.42cm, 11.75cm, 2.42cm, label: "miss 1%")
  #dnode(11.8cm, 1.85cm, 2.6cm, 1.15cm, "Object storage\n10 TB", fill: rgb("#f2dcdc"))

  #dnode(7.8cm, 5.3cm, 2.8cm, 0.95cm, "purge service")
  #darrow(8.2cm, 5.25cm, 5.5cm, 4.55cm, dashed: true)
  #darrow(8.9cm, 5.25cm, 5.5cm, 3.1cm, dashed: true)
  #darrow(9.6cm, 5.25cm, 5.5cm, 1.6cm, dashed: true)
  #darrow(9.2cm, 5.25cm, 9.2cm, 3.1cm, dashed: true)

  #dnode(0pt, 5.3cm, 6.9cm, 0.95cm, "moderation / legal takedown", fill: rgb("#fbf6ee"))
  #darrow(6.95cm, 5.75cm, 7.75cm, 5.75cm)

  #dnode(0pt, 6.9cm, 7.2cm, 1.2cm, "peak 83,333 QPS · 80 Gbit/s\n40 POPs → 2,083 QPS each", fill: rgb("#fbf6ee"))
  #dnode(7.5cm, 6.9cm, 6.9cm, 1.2cm, "edge hit 90% → origin 8 Gbit/s\nshield hit 90% → storage 0.8 Gbit/s", fill: rgb("#fbf6ee"))
]

#subsection[The origin shield: why the middle box exists]

Without a shield, every one of the 40 POPs independently misses on a *newly popular*
image and calls object storage. One new viral image costs 40 origin fetches. With a
shield, the first POP to miss pulls the object into the shield; the other 39 get it from
the shield.

$ "without shield" = 40 "origin fetches per new object" $
$ "with shield" = 1 "origin fetch" + 39 "shield fetches" $

At a 10% edge miss rate, the shield sees $83{,}333 times 0.10 = 8{,}333$ QPS. If the shield
itself hits 90%, object storage sees:

$ 8{,}333 times 0.10 = 833 "QPS" $

and bandwidth:

$ 80 "Gbit/s" times 0.10 times 0.10 = 0.8 "Gbit/s" $

*Decision: use a shield.* Cost: one extra hop, about 20 ms, on 10% of requests, which
moves the average by $0.10 times 20 = 2$ ms. Benefit: object storage load drops 10x and
the origin egress bill drops with it. Two milliseconds for a 10x reduction is an easy
trade.

#subsection[Step 6 -- Deep dive 1: the hot key]

*The problem.* A celebrity posts one product. That single image is now 25% of all image
traffic.

$ 83{,}333 "QPS" times 0.25 = 20{,}833 "QPS for one object" $
$ 20{,}833 times 120 "KB" = 2.5 times 10^9 "bytes/s" = 20 "Gbit/s for one object" $

At the *edge* this is fine -- it is spread over 40 POPs, so each POP serves
$20{,}833 / 40 = 521$ QPS of it from local SSD. Edges are built for exactly this.

The danger is in the *dynamic* cache, where the same object lives on exactly one Redis
shard. There, one key means one CPU core on one machine.

*Three fixes, and which to pick.*

#table(columns: (auto, auto, auto),
  [*Fix*], [*How it works*], [*Cost*],
  [*Local (in-process) cache*], [each app server keeps the hot value in its own `Map` for 1 -- 2 seconds], [staleness up to 2 s; zero network cost; needs no coordination],
  [*Key splitting / replication*], [store the value under `hot:{id}:0` .. `hot:{id}:9`; each reader picks a random suffix], [10x the memory for that key; invalidation must delete 10 keys],
  [*Client-side hedging*], [read from 2 replicas, take the first answer], [2x the read traffic -- makes the hot-key problem worse, not better],
)

*Decision: local cache first, key splitting only if that is not enough.*

The arithmetic for why local cache is usually enough. With 30 app servers each holding the
value for 2 seconds, the *maximum* number of Redis reads for that key is:

$ 30 "servers" / 2 "seconds" = 15 "reads per second" $

We went from 20,833 QPS on one Redis key to 15. No key splitting required, no extra
memory, no invalidation complexity. *The 2-second staleness is the entire price, and for
an image URL -- which is immutable -- the staleness costs nothing at all.*

Key splitting into 10 replicas would give:

$ 20{,}833 / 10 = 2{,}083 "QPS per replica key" $

which is also fine, but it costs 10x memory for that key and turns one `DEL` into ten.
Only reach for it when values must be fresher than a local cache allows.

#trap[
A local in-process cache is *not* a smaller Redis. Two differences bite people:

*(1) Every server has a different copy.* Two users refreshing at the same moment can see
different values for up to the local TTL. Make the local TTL short (1 -- 2 s) and only use
it for data where that is acceptable.

*(2) Memory is per process, not per machine.* Node running 8 workers with a 500 MB local
cache uses 4 GB, not 500 MB. Size it as `perProcess x workers`.
]

#subsection[Step 6 -- Deep dive 2: purge in under 60 seconds]

A takedown must remove an object from 40 POPs within 60 seconds. Three designs; pick one.

#table(columns: (auto, auto, auto, auto),
  [*Design*], [*How*], [*Time to clear*], [*Verdict*],
  [Short TTL everywhere], [set `max-age=60` on every object], [60 s], [*Rejected.* It destroys the hit rate: every object revalidates every minute, so origin traffic goes up roughly 100x. You pay for 50 million objects to solve a problem that affects a handful.],
  [Purge broadcast], [push a delete to all 40 POPs over a pub/sub fabric, collect acks], [1 -- 5 s], [*Chosen.* Costs nothing in steady state; only runs when a takedown happens.],
  [Generation counter], [prefix every path with a global generation number; bump it to invalidate], [instant], [*Rejected for takedowns* -- bumping the generation invalidates *everything*, a 288 TB re-fetch. It is the right tool for "deploy new site assets", not for one image.],
)

*The chosen design, step by step:*

+ Moderation calls `POST /internal/purge` with the image ids.
+ The purge service writes a row (`purge_id`, ids, `acked_pops = 0`) so the request survives
  a crash.
+ It publishes the ids on a fan-out topic that all 40 POPs subscribe to.
+ Each POP deletes the paths from memory and disk, then acks with its POP id.
+ The purge service counts acks. At 40/40 it marks the purge complete.
+ Any POP that has not acked within 10 seconds is *re-sent* the message. A POP that has been
  offline replays the purge log on boot before it starts serving.

*The hole you must mention before the interviewer does:* the bytes are also in *browser*
caches, with `max-age=31536000`. You cannot purge those. The only real answer is to make
the URL unreachable at the origin *and* rotate the signing key so old URLs stop verifying;
already-downloaded copies in a user's browser are simply gone from your control. Saying
this plainly -- "here is the part I cannot fix, and here is why" -- scores better than
pretending the purge is total.

#subsection[Step 6 -- Deep dive 3: consistent hashing, with measurements]

Inside a POP there are several cache servers, and the same problem appears one level down:
*which server holds which object?* If you use `hash(key) % N`, adding one server moves
almost every key.

#code(lang: "js", caption: "ring.js — a hash ring with virtual nodes")[
```js
// FNV-1a plus a mixing ("avalanche") tail. The tail matters — see the experiment below.
const hash32 = (s) => {
  let h = 0x811c9dc5;
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;        // >>> 0 keeps it unsigned 32-bit
  }
  h ^= h >>> 16; h = Math.imul(h, 0x85ebca6b) >>> 0;
  h ^= h >>> 13; h = Math.imul(h, 0xc2b2ae35) >>> 0;
  h ^= h >>> 16;
  return h >>> 0;
};

class HashRing {
  constructor(nodes = [], vnodes = 150) {
    this.v = vnodes;
    this.ring = [];                            // sorted list of { pos, node }
    nodes.forEach(n => this.addNode(n));
  }
  addNode(node) {
    for (let i = 0; i < this.v; i++) this.ring.push({ pos: hash32(`${node}#${i}`), node });
    this.ring.sort((a, b) => a.pos - b.pos);   // numeric compare — never a bare .sort()
  }
  removeNode(node) { this.ring = this.ring.filter(e => e.node !== node); }
  nodeFor(key) {
    const h = hash32(key);
    let lo = 0, hi = this.ring.length;         // first ring point with pos >= h
    while (lo < hi) { const m = (lo + hi) >> 1; this.ring[m].pos < h ? lo = m + 1 : hi = m; }
    return this.ring[lo % this.ring.length].node;   // wrap past the top of the circle
  }
}
```
]

#code(lang: "text", caption: "node ring.js — 4 nodes, 100,000 keys")[
```text
vnodes=  1  33.8%  5.2%  31.2%  29.8%
vnodes= 10  20.2%  19.3%  19.4%  41.1%
vnodes=150  25.4%  25.3%  22.4%  26.9%
add a 5th node -> 19.9% of keys move (ideal 1/5 = 20%)
plain modulo   -> 80.2% of keys move
```
]

*Read the output carefully; there are three lessons in five lines.*

*(1) One point per node is useless.* With `vnodes=1`, one node got 5.2% of the keys and
another got 33.8% -- a 6.5x imbalance. Four random points on a circle simply do not cut it
into four equal arcs.

*(2) Virtual nodes fix it, and 150 is the standard number.* At 150 points per node the
spread is 22.4% to 26.9% -- within a few points of the ideal 25%. The general rule:
imbalance shrinks roughly as $1/sqrt(V)$ where $V$ is virtual nodes per real node. Going
from 1 to 150 shrinks it by about $sqrt(150) approx 12$ times.

*(3) This is the entire point of the ring.* Adding a fifth node moved *19.9%* of keys --
essentially the theoretical minimum of $1/5 = 20%$. Plain `hash % N` moved *80.2%*.

At our scale, "moved" means "must be re-fetched from the shield". Adding one server to a
POP:

$ "consistent hashing:" 500 "GB" times 0.199 = 99.5 "GB re-fetched" $
$ "plain modulo:" 500 "GB" times 0.802 = 401 "GB re-fetched" $

*Decision: consistent hashing with 150 virtual nodes.* It costs a binary search per lookup
($log_2 600 approx 10$ steps -- nothing) and saves 300 GB of origin traffic *per server
added, per POP*.

#trap[
Look at the `.sort((a, b) => a.pos - b.pos)`. A bare `.sort()` in JavaScript sorts
*lexicographically*, so ring position 1000000000 would come before 999999999 and the ring
would be silently wrong -- not crashed, just wrong. Every key would go to the wrong node.
This is the single most expensive one-character mistake in JavaScript system design.
]

#note[
*Why the avalanche tail matters.* The first version of this code used plain FNV-1a with no
mixing tail. With 150 virtual nodes the split was 11.9% / 20.7% / 21.1% / *46.2%* -- one
node taking almost half the traffic. FNV-1a's final bits are not well mixed for short,
nearly identical strings like `cache-3#0`, `cache-3#1`, so the virtual points clustered.
Adding the three-step mixing tail fixed it completely. *When a hash ring is unbalanced,
suspect the hash before you suspect the ring.*
]

#subsection[Step 7 -- Trade-offs, failures, and 10x]

#table(columns: (auto, auto, auto, auto),
  [*Decision*], [*Chosen*], [*Rejected*], [*Why*],
  [Image URLs], [content hash, immutable, 1-year TTL], [mutable URLs with short TTL], [immutability removes invalidation from the design entirely; the cost is that an "edit" is really an upload, which we accept],
  [Origin protection], [origin shield in one region], [POPs talk to storage directly], [a shield turns 40 origin fetches per new object into 1; costs 2 ms of average latency],
  [Takedown], [purge broadcast with acks], [short TTL on everything], [short TTLs would raise origin traffic ~100x to solve a rare event],
  [POP sharding], [consistent hashing, 150 vnodes], [`hash % N`], [measured: 19.9% vs 80.2% of keys move when a server is added],
  [Hot object], [rely on 40-way edge spread + local cache], [key splitting], [edges already spread it 40 ways; splitting adds memory and invalidation cost for no gain],
)

*Failure modes:*

#table(columns: (auto, auto, auto),
  [*What fails*], [*Effect*], [*Response*],
  [One POP goes down], [its users are routed to the next nearest POP: latency goes from ~20 ms to ~60 ms; that POP's 2,083 peak QPS lands on a neighbour], [size every POP with 40% headroom so a neighbour can absorb one failure; anycast routing moves users automatically],
  [The shield region goes down], [all 8,333 miss-QPS hit object storage directly -- 10x its normal load], [run *two* shields in different regions, POPs pick by health; object storage can take 8,333 QPS, it is just slower and dearer],
  [Object storage is slow], [misses time out, users see broken images], [serve stale past expiry; a 6-hour-old image beats a broken one; circuit-break to a placeholder after 5 s],
  [A purge message is lost], [illegal content stays live at one POP], [acks + retry every 10 s + replay the purge log on POP boot; alert if any POP is unacked after 60 s],
  [Cache poisoning via a bad `Vary`], [one user's private image served to others], [never set `Vary: Cookie` on public paths; serve private media from a separate hostname with `Cache-Control: private`],
)

*At 10x (600M DAU):*

$ 600{,}000{,}000 times 40 = 24 times 10^9 "requests/day" $
$ 24 times 10^9 / 86{,}400 = 277{,}778 "QPS average"; quad times 3 = 833{,}333 "QPS peak" $
$ "bandwidth" = 26.7 times 10 = 267 "Gbit/s average"; quad "peak" = 800 "Gbit/s" $

With 40 POPs that is $800 / 40 = 20$ Gbit/s per POP -- too much for one edge server. Three
changes:

+ *More POPs, not bigger POPs.* Go to 200 POPs: $800 / 200 = 4$ Gbit/s each. This also cuts
  user latency, because more POPs means a closer POP.
+ *Push image resizing to the edge.* Today we store 4 variants per image (`50M x 200 KB = 10 TB`).
  At 10x with more device sizes that becomes unmanageable. Store *one* original and resize at
  the edge on first request, then cache the result. Storage drops from 10 TB to about
  $500 times 10^6 times 150 "KB" = 75 "TB"$ of originals instead of $4 times$ that in variants.
+ *Tiered edge caching.* A 500 GB POP at 10x traffic has a worse hit rate because the working
  set grew. Add a regional mid-tier between POP and shield: POP (hot 1%) $arrow.r$ region
  (hot 20%) $arrow.r$ shield $arrow.r$ storage.

#section[Interview drill]

These are the pushes that come *after* your first answer. The answer is what a strong
candidate says in 30 seconds.

#subsection[Push 1: "Your cache is 95% effective. Why not just add a read replica instead?"]

#note[
*Answer.* Because they solve different problems and the numbers are not close. A read
replica gives me another 12 ms path with maybe 500 QPS of headroom; Redis gives me a 1 ms
path with 100,000 QPS of headroom, for a fraction of the cost. Concretely: to absorb the
same 8,835 peak QPS I would need about 18 replicas at 500 QPS each, versus one Redis node.

But I would use *both*. The replica is what the cache falls back to on a miss, and it is
what protects the primary when Redis dies. They are layers, not alternatives.
]

#subsection[Push 2: "What is your cache key? Be exact."]

#note[
*Answer.* `product:{id}:v{version}` for the blob, `price:{id}:{region}` for the price.

Three rules I follow for any cache key:

+ *Everything the response depends on must be in the key.* If the response changes by
  region, region goes in the key. If it changes by user tier, tier goes in the key. A key
  that forgets a dimension serves one user's answer to another -- that is a correctness
  bug, not a performance bug.
+ *Prefix by entity type* so I can find, count and mass-delete a family of keys.
+ *No user-controlled strings unescaped.* A product title in a key lets an attacker create
  colliding or unbounded keys.
]

#subsection[Push 3: "A deploy flushed Redis at peak. Walk me through the next 60 seconds."]

#note[
*Answer, with numbers.*

*Second 0:* hit rate goes 95% $arrow.r$ 0%. Database demand jumps from 465 QPS to 9,300
QPS -- *20x over budget*.

*Second 0 -- 2:* the 2-second in-process cache is also cold, so it does not help yet. The
concurrency limiter in front of Postgres caps in-flight queries at 300. Everything above
that gets `503` with `Retry-After: 2`. We shed load on purpose rather than letting the
database queue and die.

*Second 2 -- 20:* each app server's local cache fills with the hottest products. Effective
DB demand drops fast because the top 1,000 products are most of the traffic. Singleflight
means each distinct key costs exactly one query per server, not one per request.

*Second 20 -- 60:* Redis refills from those misses. Hit rate climbs back through 60%, 80%,
90%.

*The real fix is prevention, and I would say so:* never flush on deploy. Use versioned
keys so the new code writes `v42` while `v41` is still serving, and warm the top 10,000
products before the new instances take traffic. A cache flush should never be a normal
part of a deploy.
]

#subsection[Push 4: "When would you NOT cache?"]

#note[
*Answer -- four cases, and I have hit all four.*

+ *When the read to write ratio is near 1.* You pay the write cost to invalidate and
  almost never get a hit. Below roughly 5:1, measure before you cache.
+ *When staleness is not allowed at all.* A bank balance on a transfer screen, remaining
  seats at the moment of booking, a one-time password. Here you read the primary, and you
  make the primary fast with an index instead.
+ *When the value is enormous and the hit rate is low.* Caching 5 MB search results with a
  20% hit rate spends a lot of memory to avoid a few queries.
+ *When the query is already fast.* A primary-key lookup on a small table that returns in
  0.4 ms does not need a 0.5 ms Redis round trip in front of it. *A cache can be slower
  than the thing it caches.* That surprises people, so it is worth saying.
]

#subsection[Push 5: "Redis or Memcached?"]

#note[
*Answer: Redis, and here is the deciding reason.*

Memcached is genuinely good at one thing -- a plain key-value string cache, multi-threaded,
very low overhead per key. If my need were literally that and nothing else, it wins on
memory efficiency.

But almost every real design needs at least one of: sorted sets (leaderboards, rate limit
windows), atomic increments with expiry, pub/sub for invalidation fan-out, or persistence
so a restart does not start cold. Redis has all four. The moment I need one of them,
running both systems is worse than running Redis alone.

*Decision: Redis.* I accept the single-threaded command loop -- one core per shard -- and
plan for it by sharding, which I have to do for memory anyway.
]

#subsection[Push 6: "How do you measure whether the cache is working?"]

#note[
*Answer -- four dashboards, not one.*

+ *Hit rate, per key prefix.* One global number hides everything. `product:*` at 97% and
  `search:*` at 12% is a completely different story from "the cache is at 90%".
+ *Origin QPS.* This is the number the cache exists to reduce. If hit rate is up but origin
  QPS is flat, the extra hits were on keys nobody was querying anyway.
+ *p99 latency, split by hit and miss.* The average lies. p99 is dominated by misses.
+ *Eviction rate.* If evictions are high while hit rate is fine, the cache is thrashing and
  is about to fall off a cliff when traffic grows 20%. This is the leading indicator.
]

#practice(tier: 0, time: "12 min")[
+ A service does 6,000 QPS with an 88% hit rate. Hits cost 1 ms, misses cost 1 ms plus a
  15 ms database read. Find the database QPS and the average latency.
+ The team wants the database at or below 300 QPS at the same 6,000 QPS of traffic. What
  hit rate is required?
+ A cache holds 4 items, LRU. Trace `A B C D A E B A C` and give the hit count and the
  final contents.
+ 2 million user sessions, 1.5 KB each. Compute total memory, and the provisioned size
  with 30% overhead.
+ A key with a 10-minute TTL is read 500 times a second. On expiry the database takes
  20 ms. How many concurrent database queries fire without singleflight?
]

#key[
*1.* Misses $= 12%$. DB QPS $= 6000 times 0.12 = 720$.
Average $= 0.88 times 1 + 0.12 times 16 = 0.88 + 1.92 = 2.80$ ms.

*2.* Allowed miss rate $= 300 / 6000 = 0.05 = 5%$. So the required hit rate is *95%*.
(Note this cuts DB load from 720 to 300, a 2.4x reduction, for 7 points of hit rate.)

*3.* Steps: A miss [A]; B miss [B,A]; C miss [C,B,A]; D miss [D,C,B,A]; A *hit* [A,D,C,B];
E miss, evict B [E,A,D,C]; B miss, evict C [B,E,A,D]; A *hit* [A,B,E,D]; C miss, evict D
[C,A,B,E]. *2 hits, 7 misses*; final contents C, A, B, E (C newest).

*4.* $2{,}000{,}000 times 1.5 "KB" = 3{,}000{,}000 "KB" = 3 "GB"$.
With overhead: $3 times 1.3 = 3.9$ GB. Provision a 4 GB instance.

*5.* $500 times 0.020 = 10$ concurrent queries for the same key. With singleflight: 1 per
process.
]

#practice(tier: 2, time: "35 min")[
+ Design the cache layer for a "recently viewed products" list: 8M DAU, each user's list
  holds 20 product ids, each user views 25 products a day. Give the key, the value type,
  the TTL, the memory, and the write QPS. Decide between Redis lists and a JSON blob, and
  justify the choice.
+ A category page shows 40 products. Today the service makes 40 separate Redis calls per
  page at 0.6 ms each. At 2,000 page-views per second, compute the Redis QPS and the time
  spent in Redis per page. Then redesign it and compute the new numbers.
+ Your `search:{query}` cache has a 12% hit rate and uses 8 GB. Decide whether to keep it,
  and say exactly what you would change. Show the arithmetic behind your decision.
]

#key[
*1.* Key `recent:{userId}`, value a Redis list of 20 ids ($20 times 12$ bytes $= 240$ B;
with overhead call it 400 B).

Memory: $8{,}000{,}000 times 400 "B" = 3.2 times 10^9 = 3.2$ GB. With 30% overhead,
provision 4.2 GB.

Writes: $8{,}000{,}000 times 25 = 200{,}000{,}000$ per day $= 200 times 10^6 / 86{,}400 = 2{,}315$
QPS average, peak 4x $= 9{,}260$ QPS.

TTL: 30 days, refreshed on every write.

*Decision: Redis list, not a JSON blob.* `LPUSH` + `LTRIM 0 19` is one atomic round trip
and writes 12 bytes. A JSON blob forces read-modify-write: 2 round trips, 400 bytes
written each time, *and* a lost-update race between two devices of the same user. At 9,260
peak write QPS the blob approach doubles the Redis op rate to 18,520 for no benefit.

*2.* Today: $2{,}000 times 40 = 80{,}000$ Redis QPS; time in Redis per page
$= 40 times 0.6 = 24$ ms (if sequential).

Redesign with `MGET` of 40 keys: *2,000 Redis QPS* (one call per page) and about
*0.9 ms* per page (one round trip; a 40-key MGET is barely slower than a 1-key GET because
the cost is dominated by the network hop).

That is a *40x* drop in Redis operations and a *26x* drop in page latency from one change.

*3. Decision: keep it, but shrink it and split the key space.*

A 12% hit rate is not automatically bad -- what matters is what those hits cost to produce.
A search query costs, say, 80 ms of database work. At 500 searches/second, 12% hits save
$500 times 0.12 = 60$ searches/second $times 80$ ms $= 4.8$ seconds of database time per
second -- the cache is doing the work of roughly 5 dedicated database cores. That is worth
keeping.

What I change: (a) 8 GB for 12% means most entries are never read again -- long-tail
queries. Cache only queries seen 2+ times in the last hour (a small count-min sketch in
front of the cache), which should drop memory to \~1 GB while keeping most of the hits.
(b) Split into `search:hot:*` with a 10-minute TTL and `search:cold:*` with 60 seconds, so
the tail expires quickly. (c) Alarm on hit rate per prefix, not globally.
]

#practice(tier: 3, time: "45 min")[
+ A video thumbnail service serves 200M requests/day at 45 KB average. Compute daily bytes,
  average and peak (4x) bandwidth in Gbit/s, and the daily cost difference between 0% and
  92% CDN hit rate at \$0.02/GB (CDN) and \$0.09/GB (origin).
+ You have 6 Redis shards. One key is receiving 35,000 QPS and its shard is at 100% CPU.
  The value is a counter that must be accurate within 1 second. Local caching for 2 seconds
  is therefore not allowed. Design a fix, show the arithmetic, and state the new staleness.
+ Your CDN hit rate dropped from 94% to 61% overnight with no traffic change and no deploy.
  List five possible causes, and for each say the *one* metric or log field that would
  confirm it.
]

#key[
*1.* Bytes: $200 times 10^6 times 45 "KB" = 9 times 10^{12} "B" = 9$ TB/day.

Average: $9 times 10^{12} / 86{,}400 = 1.042 times 10^8$ B/s $= 0.104$ GB/s
$times 8 = 0.833$ Gbit/s. Peak 4x $= 3.33$ Gbit/s.

Cost at 0% CDN: $9{,}000 "GB" times 0.09 = \$810$/day.
At 92%: $9{,}000 times 0.92 times 0.02 + 9{,}000 times 0.08 times 0.09 = 165.6 + 64.8 = \$230.40$/day.
*Saving \$579.60/day, about \$211,554/year.*

*2.* A counter that must be accurate within 1 second rules out a 2-second local cache, so
use *key splitting on the write side and a fan-in on the read side*.

Write path: shard the counter into 12 keys `count:{id}:0` .. `count:{id}:11`, each on a
different shard (put the suffix in the hash tag so Redis Cluster spreads them). Each
increment picks a random suffix. Write load per key:
$35{,}000 / 12 = 2{,}917$ QPS -- comfortable.

Read path: the true total is the sum of 12 keys. Do not sum on every read. Run one
background job per app server that does a 12-key `MGET`, sums, and stores the result in a
local variable *every 500 ms*. Reads then serve that local number at zero Redis cost.

New staleness: up to *500 ms*, inside the 1-second budget. Redis read load for the fan-in
with 30 servers: $30 times 2 = 60$ `MGET`s per second. We went from 35,000 QPS on one shard
to 2,917 QPS on each of 12, plus 60 reads.

*3.* Five causes and the confirming signal:

#table(columns: (auto, auto),
  [*Cause*], [*What confirms it*],
  [A new query string is being appended to URLs (analytics tag), so every URL is unique], [the `cache_key` field in edge logs -- look for `?utm_` or `?t=` suffixes; check distinct-URL count],
  [An origin change started sending `Cache-Control: no-store` or `private`], [the response header logged at the edge on a miss-fill],
  [`Vary` header widened (e.g. `Vary: Cookie` or `Vary: User-Agent`)], [the `Vary` value in edge logs; distinct variants per URL exploded],
  [A POP lost disk capacity or was rebuilt, so its working set is cold], [eviction rate and `cache_disk_free` per POP; hit rate will be bad at *one* POP, not all],
  [A crawler is walking the long tail of 50M objects], [unique-URL rate and the user-agent / ASN breakdown in edge logs],
)
]

#revision[
*The three questions for any cache*
+ What goes in? (key, value, size)
+ When does it come out? (eviction = full; expiry = old)
+ What breaks when it is wrong? (stale, herd, hot key, penetration, avalanche)

*Numbers to memorise*
#table(columns: (auto, auto, auto, auto),
  [in-process `Map`], [0.1 $mu$s], [Redis same DC], [0.5 -- 1 ms],
  [SSD read], [0.1 ms], [indexed SQL row], [5 -- 15 ms],
  [same-region RTT], [1 ms], [India $arrow.l.r$ US RTT], [180 ms],
  [CDN edge], [10 -- 30 ms], [RAM vs DB], [\~100x faster],
)

*The formulas*
- $"DB QPS" = "total QPS" times (1 - "hit rate")$
- $"avg latency" = h times t_"hit" + (1-h) times (t_"hit" + t_"miss")$
- $"concurrent misses on expiry" = "QPS on that key" times "DB latency in seconds"$
- $"cache memory" = "working set" times "value size" times 1.3$
- $"max hit rate" = 1 - ("distinct keys") / ("requests in the window")$
- $"bandwidth (Gbit/s)" = ("bytes/day") / 86400 times 8 / 10^9$

*Worked numbers from this chapter*
- 8M DAU $times$ 25 reads $=$ 200M/day $=$ 2,315 QPS avg, 9,259 peak (4x)
- 95% hit $arrow.r$ Redis 8,835 QPS, DB 465 QPS, avg 1.6 ms
- 60M DAU $times$ 40 images $=$ 2.4B/day $=$ 27,778 QPS, 288 TB/day, 26.7 Gbit/s (80 peak)
- CDN at 90% saves \$18,144/day on that traffic
- consistent hashing (150 vnodes): 19.9% of keys move when adding a node; `hash % N`: 80.2%

*The five failures and their one-line fixes*
+ stale $arrow.r$ delete on write (never update), short TTL
+ thundering herd $arrow.r$ singleflight + stale-while-revalidate
+ hot key $arrow.r$ in-process cache for 1 -- 2 s; key splitting if it must be fresher
+ penetration $arrow.r$ cache the 404 for 30 s
+ avalanche $arrow.r$ TTL jitter $plus.minus 20%$, warm on boot, never flush on deploy

*Order of operations on a write -- never get this wrong*
write the source of truth *first*, then delete the cache key. Never the reverse.

*Sentences that score points*
- "Let me do the miss-side arithmetic -- 92% to 97% cuts DB load 2.67x."
- "I'll split the price into its own short-TTL key so a price change does not throw away 4 KB."
- "Immutable content-hashed URLs mean I never invalidate for correctness, only for takedowns."
- "Here is the part I cannot fix: bytes already in a user's browser cache."
]

]
