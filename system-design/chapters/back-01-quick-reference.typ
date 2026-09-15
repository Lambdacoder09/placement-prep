#import "../../shared/lib/style.typ": *

#pagebreak(weak: true)
#toc-entry("Appendix · Last-Week Quick Reference")

#block(width: 100%, inset: (bottom: 10pt))[
  #text(size: 9pt, fill: muted, weight: "bold", tracking: 1.5pt)[APPENDIX]
  #v(-4pt)
  #text(size: 22pt, weight: "bold")[Last-Week Quick Reference]
  #v(-3pt)
  #text(size: 10pt, fill: muted, style: "italic")[
    Everything in this book compressed to what you can hold in your head on the day.
  ]
]
#line(length: 100%, stroke: 1.2pt + ink)
#v(6pt)

This appendix repeats nothing new. Every number here was derived in a chapter. Read it
twice the night before and once on the morning of the round. If a line surprises you, go
back to the chapter it came from --- the chapter number is in the margin of each block.

#section[A.1 · Latency numbers to memorise]

These are the ones that actually change a design decision. Round numbers on purpose;
an interviewer wants the *order of magnitude*, not three decimal places.

#table(
  columns: (1fr, auto, auto, 1fr),
  inset: (x: 5pt, y: 4pt),
  align: (left, right, right, left),
  [*Operation*], [*Time*], [*vs. memory*], [*What it means for the design*],

  [L1 cache read], [0.5 ns], [0.005x], [free; never a bottleneck],
  [main memory read], [100 ns], [1x], [the unit everything else is measured in],
  [read 1 MB from memory], [30 µs], [300x], [serialising a big object is not free],
  [in-process `Map` lookup], [0.1 µs], [1x], [a local cache is \~5,000x a network hop],
  [SSD random read], [100 µs], [1,000x], [one uncached row read],
  [same-DC network round trip], [500 µs], [5,000x], [every extra service hop costs this],
  [Redis GET, same DC], [0.5--1 ms], [\~10,000x], [dominated by the round trip, not Redis],
  [indexed SQL row, cached], [0.1--0.5 ms], [--], [the good case],
  [indexed SQL row, from SSD], [1--5 ms], [--], [the normal case],
  [disk seek (spinning)], [10 ms], [100,000x], [why nobody puts a hot index on one],
  [scan 1 M rows], [0.2--1 s], [--], [a missing index, visible to the user],
  [CDN edge hit], [10--30 ms], [--], [physics of the last mile, not of your server],
  [Mumbai #sym.arrow.l.r Singapore RTT], [\~60 ms], [--], [one sync cross-region write per request is too many],
  [Mumbai #sym.arrow.l.r Virginia RTT], [\~250 ms], [--], [only a nearby *copy* fixes this],
)

#trick[
Two sentences carry most of the marks here. *"Memory is about 5,000 times faster than a
network hop, so I will keep the hot set in-process."* And *"250 ms across an ocean is
physics; I cannot optimise it away, I can only put a copy closer."*
]

#subsection[What one machine does --- the capacity table]

#table(
  columns: (1fr, auto, 1fr, auto),
  inset: (x: 5pt, y: 4pt),
  align: (left, right, left, right),
  [app server, JSON], [1,000--3,000 RPS], [L7 proxy node], [20,000--50,000 RPS],
  [SQL node, indexed reads], [10,000--20,000/s], [SQL node, durable writes], [2,000--5,000/s],
  [SQL, single locked row], [\~500 updates/s], [Redis], [\~100,000 ops/s],
  [one Kafka-style partition], [\~10 MB/s], [WebSockets held per box], [\~100,000],
  [1 Gbps NIC], [125 MB/s], [restore from backup], [\~200 MB/s],
)

#note[
Two consequences you should be able to state instantly. *Shard size:* at 200 MB/s a 1 TB
shard restores in about 83 minutes and a 6.5 TB one in about 9 hours --- so keep shards
between 200 GB and 1 TB. *Consumer count:* a consumer group can never have more working
consumers than the topic has partitions.
]

#section[A.2 · Estimation cheat-sheet]

#formulas(title: "The five lines — write these on the board in this order")[
```
traffic    DAU × actions ÷ 86,400 × peak factor        → QPS
storage    rows/day × bytes/row × 365 × years × RF     → bytes  (× 1.3 for indexes)
bandwidth  peak QPS × response bytes                   → B/s    (× 8 for bits)
memory     hot items × bytes/item × 1.3                → cache size
machines   peak QPS ÷ per-server QPS ÷ 0.65            → node count
```
]

#subsection[Conversions you must not stop to derive]

#table(
  columns: (auto, 1fr, auto, 1fr),
  inset: (x: 5pt, y: 4pt),
  [*1 M/day*], [$= 11.6$/s], [*1 B/day*], [$= 11,574$/s],
  [$2^10$], [$approx 10^3$ (KB)], [$2^20$], [$approx 10^6$ (MB)],
  [$2^30$], [$approx 10^9$ (GB)], [$2^32$], [$= 4.29 times 10^9$],
  [1 KB $times$ 1 M], [$=$ 1 GB], [1 KB $times$ 1 B], [$=$ 1 TB],
  [1 MB $times$ 1 M], [$=$ 1 TB], [1 Gbps], [$=$ 125 MB/s],
  [1 day], [86,400 s], [1 month], [$approx 2.6 times 10^6$ s],
  [1 year], [$approx 3.15 times 10^7$ s], [bits vs bytes], [capital B is bytes],
)

#subsection[Peak factors --- pick one and say why]

#table(
  columns: (auto, auto, 1fr),
  inset: (x: 5pt, y: 4pt),
  align: (left, center, left),
  [*Traffic shape*], [*Peak / average*], [*Why*],
  [global consumer app], [2x], [users spread across time zones flatten the curve],
  [one-country consumer app], [3x], [one evening peak, roughly 12--15% of the day in one hour],
  [one-country work app], [4--5x], [everyone logs in inside the same 30 minutes],
  [sale, match, or ticket drop], [10--50x], [the peak *is* the product; design for it explicitly],
)

#trap[
Flat traffic would be $100% \/ 24 = 4.2%$ per hour. A real consumer evening peak is
12--15% in the busiest hour. That is where the 3x comes from --- say the derivation, do
not just say "3x".
]

#subsection[The four formulas that decide designs]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 4.5pt),
  [*Little's Law*], [$L = lambda W$. Things in flight $=$ arrival rate $times$ time each one
  stays. Sizes every thread pool, connection pool and queue. 10,000 RPS at 200 ms $=$ 2,000
  in flight.],

  [*Cache relief*], [Database load falls by $1\/(1-h)$. A 90% hit rate is 10x relief; 99% is
  100x. Going 92% $arrow.r$ 97% is a 2.67x cut, which is why the last few points are worth
  fighting for.],

  [*Needed hit rate*], [$h = 1 - "db capacity" \/ "peak QPS"$. Work backwards from what the
  database can take, and you get the cache target instead of guessing it.],

  [*Fan-out tail*], [$P("slow") = 1 - p^n$. At p99 per shard, 16 shards give 14.9% slow
  requests and 64 shards give 47.4%. Scatter-gather turns a good p99 into a bad one.],

  [*Utilisation tax*], [$"latency multiplier" = 1\/(1-rho)$. 50% busy is 2x, 80% is 5x, 90%
  is 10x. This is why you size for 60--70%, not 95%.],

  [*Quorum*], [$W + R > N$. Overlap $= W + R - N$ nodes. Survives $N - W$ failures for
  writes, $N - R$ for reads. $N = 5, W = 3, R = 3$ is the balanced default.],
)

#subsection[Amplifiers --- the things that multiply your estimate]

#table(
  columns: (auto, auto, 1fr),
  inset: (x: 5pt, y: 4pt),
  align: (left, center, left),
  [*Amplifier*], [*Factor*], [*Where it hides*],
  [replication], [x3], [every byte you store is three bytes of disk],
  [indexes], [+30%], [and one extra write per index on every insert],
  [fan-out on write], [x followers], [one post becomes one row per follower's feed],
  [retries at $n$ layers], [$3^n$], [3 hops x 3 attempts $=$ 27 requests for one user action],
  [compaction headroom], [x1.5], [LSM stores need free space to merge],
  [logs and telemetry], [often > the data], [a 1 KB event with 2 KB of logs around it],
)

#pagebreak(weak: true)

#section[A.3 · The seven-step checklist]

Say the step name out loud before you do it. The interviewer is ticking boxes, and an
unspoken step is an unticked box.

#table(
  columns: (auto, auto, 1fr, 1fr),
  inset: (x: 5pt, y: 5pt),
  align: (center, center, left, left),
  [*\#*], [*Min*], [*What you leave on the board*], [*The sentence that scores the mark*],

  [1], [5], [3 features in scope, 3 out. One non-functional target (latency or
  availability).],
  ["Let me fix the boundary first: X, Y and Z are in; auth and analytics are out."],

  [2], [5], [Peak QPS, storage per year, peak bandwidth --- with the division shown.],
  ["50 M DAU x 20 actions $=$ 1 B/day $=$ 11,600/s average, 3x peak $approx$ 35,000/s."],

  [3], [5], [3--5 endpoints with request and response fields.],
  ["Creates take an idempotency key; lists take a cursor, never an offset."],

  [4], [5], [2--4 tables or classes, with the key circled and one index named per query.],
  ["The partition key is `user_id` because the hot query is 'my last 50', which then
  touches one shard."],

  [5], [10], [One diagram. Read path and write path marked separately.],
  ["Write path is solid, read path is dashed. The cache sits here, and here is what
  invalidates it."],

  [6], [10], [The one or two genuinely hard parts, solved, with the failure case handled.],
  ["The hard part is X. Here is the mechanism, and here is what happens when it fails
  mid-way."],

  [7], [5], [Two options, one decision, one 10x remark.],
  ["I chose A over B, and I paid for it with C. At 10x, the first thing to break is D."],
)

#formulas(title: "The closing 60 seconds — say all four")[
+ *The bottleneck.* "The binding constraint here is write throughput on the orders table."
+ *The failure.* "If the cache region dies, reads fall back to the database at 5x load; I
  shed the feed endpoint first to protect checkout."
+ *The 10x.* "At 10x, the single-leader write path is what breaks. I would shard by
  merchant next."
+ *The regret.* "If I had another hour, I would revisit the fan-out choice --- I picked
  write-time fan-out, and celebrity accounts make that expensive."
]

#subsection[The LLD version of the same seven steps]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 4pt),
  [1 Clarify], [Which rules change often? Those become strategy objects. Which never
  change? Those become constants.],
  [2 Estimate], [Not QPS --- *cardinality*. "10,000 items, 50 users" tells you a `Map` is
  enough and a scan is not.],
  [3 API], [The public methods of the main class, with arguments and return types.],
  [4 Data model], [Classes, fields, and the maps that index them. State the invariant that
  must always hold.],
  [5 Draw], [A class sketch: boxes, arrows for "has-a" and "is-a". Or write the code ---
  code *is* the picture in LLD.],
  [6 Deep dive], [The concurrency case, or the rule that changes most often. Usually one of
  those two.],
  [7 Trade-offs], [Why this pattern and not that one. What a new requirement would cost you
  in edits.],
)

#trap[
The most common LLD failure is designing for requirements nobody gave you. Six interfaces
for a vending machine is not senior --- it is slow. Add an abstraction only when you can
name the *second* thing that will use it.
]

#section[A.4 · The trade-off table]

Every row is a real decision. Learn the *Decide when* column --- that is the half people
forget, and it is the half that scores.

#table(
  columns: (auto, 1fr, 1fr, 1fr),
  inset: (x: 5pt, y: 4.5pt),
  [*Decision*], [*Option A*], [*Option B*], [*Decide when*],

  [SQL vs NoSQL],
  [SQL: joins, constraints, real transactions],
  [NoSQL: one access pattern, huge volume, easy sharding],
  [SQL unless you can name the *one* query shape and the volume that breaks a single
  node. Default to SQL.],

  [Normalise vs de-normalise],
  [Normalised: one source of truth, no drift],
  [De-normalised: fewer joins, faster reads],
  [Normalise first. De-normalise only for a price snapshot, a constraint, or a *measured*
  hot join.],

  [Strong vs eventual consistency],
  [Strong: correct, slower, fails on partition],
  [Eventual: available, stale, needs merge rules],
  [Money, inventory and usernames are strong. Profiles, counts and feeds are eventual.
  Different data, different answer, same product.],

  [Cache-aside vs write-through],
  [Aside: simple, a miss costs one DB read],
  [Through: always warm, every write costs more],
  [Cache-aside as the default. Write-through only for a small, always-hot set that must
  never miss.],

  [Update cache vs delete cache],
  [Update: no miss after the write],
  [Delete: cannot go stale, one miss],
  [*Always delete.* Two concurrent updates can land in the wrong order; two deletes
  cannot.],

  [Fan-out on write vs on read],
  [On write: feed reads are one lookup],
  [On read: cheap writes, expensive reads],
  [Fan-out on write for ordinary users; on read for accounts above \~100 k followers.
  Hybrid, and say so.],

  [Sync vs async work],
  [Sync: user sees the result and the error],
  [Async: fast response, needs status and retries],
  [Sync only for what the user must see to trust the action. Everything else goes on a
  queue with a DLQ.],

  [At-least-once vs exactly-once],
  [At-least-once: duplicates, simple, the default],
  [Exactly-once *effect*: unique key on the effect],
  [Always at-least-once delivery. Buy exactly-once *effect* with a unique constraint, not
  with a cache.],

  [Single leader vs multi-leader],
  [Single: no write conflicts, one region is far],
  [Multi: local writes, real conflicts to merge],
  [Single leader unless cross-region write latency is the product problem. Conflicts cost
  more than you expect.],

  [Optimistic vs pessimistic locking],
  [Optimistic: no waiting, retries under contention],
  [Pessimistic: one waits, throughput \~1/hold time],
  [Optimistic below \~10% conflict rate. Above it, retries storm --- 200 buyers on one row
  produced 19,900 retries.],

  [`hash % N` vs consistent hashing],
  [Modulo: trivial, moves \~$N\/(N+1)$ of keys],
  [Consistent: moves \~$1\/(N+1)$ of keys],
  [Consistent hashing with 100--200 vnodes, or fixed buckets with a `bucket -> shard`
  map. Never plain modulo on a growing cluster.],

  [Vertical vs horizontal scaling],
  [Vertical: no code change, a hard ceiling],
  [Horizontal: no ceiling, distributed problems],
  [Vertical first --- it is cheaper than you think. Go horizontal when the blast radius,
  not the QPS, is the reason.],

  [Retry vs fail fast],
  [Retry: hides a blip, can amplify $3^n$],
  [Fail fast: honest, user sees the error],
  [Retry only idempotent calls, with jitter, a budget of \~10% of traffic, and a circuit
  breaker above it.],

  [Rate limit: token vs sliding window],
  [Token bucket: allows bursts, tiny state],
  [Sliding window: accurate, more state],
  [Token bucket by default; sliding window log only when the limit is a contractual
  promise you must be exact about.],
)

#section[A.5 · The failure list --- and the one-line fix]

#table(
  columns: (auto, 1fr, 1fr),
  inset: (x: 5pt, y: 4pt),
  [*Failure*], [*What the user sees*], [*The fix you name*],
  [stale cache], [an old price, an old name], [delete on write, never update; short TTL],
  [thundering herd], [a latency spike every TTL], [singleflight + stale-while-revalidate],
  [hot key], [one shard at 100%, rest idle], [in-process cache for 1--2 s; split the key],
  [cache penetration], [DB load from keys that do not exist], [cache the 404 for 30 s],
  [cache avalanche], [everything expires together], [TTL jitter $plus.minus 20%$, warm on boot],
  [retry storm], [the outage lasts longer than the cause], [budget, jitter, circuit breaker],
  [hot shard], [p99 fine, p99.9 terrible], [pick a key with no time prefix; measure skew],
  [split brain], [two leaders, lost writes], [majority election, leases, fencing tokens],
  [queue lag], [work is done, but hours late], [alarm on lag, autoscale consumers, shed],
  [poison message], [one consumer stuck forever], [retry count, then DLQ, then alarm],
  [scatter-gather tail], [everything is slow at once], [fewer shards per query, or hedge],
  [unbounded growth], [it works, then it stops], [TTL, archive, or partition-and-drop from day one],
)

#section[A.6 · The night-before self-test]

Twelve questions. If you can answer all twelve out loud in ten minutes, you are ready.

#practice(tier: 3, time: "10 min, spoken, no notes")[
+ Say the seven steps in order, with the minute budget.
+ 30 M DAU, 12 actions each. Average QPS? Peak at 3x?
+ How many bytes is 1 KB per row, 5 M rows per day, kept 3 years, RF 3?
+ Memory read vs same-DC round trip --- what is the ratio, and what does it tell you to do?
+ Give the quorum that survives two node failures for reads and writes at $N = 5$.
+ You cache at 92%. What hit rate halves the database load again?
+ Name a shard key that fails the "must never change" test, and what you would use instead.
+ On a write: cache first or database first? Delete or update? Why?
+ Exactly-once: what exactly does not exist, and what do you build instead?
+ Name two pieces of data in one product that sit on opposite sides of CAP.
+ 16 shards, p99 per shard. What fraction of scatter-gather reads are slow?
+ Your design at 10x --- what breaks first, and what do you change?
]

#key[
*1.* Clarify 5, estimate 5, API 5, data model 5, draw 10, deep dive 10, trade-offs 5.
*2.* $30 "M" times 12 = 360 "M/day"$; $360 \/ 86,400 = 4,167$/s; peak $approx 12,500$/s.
*3.* $5 "M" times 1 "KB" = 5 "GB/day"$; $times 365 times 3 = 5.48 "TB"$; $times 3 = 16.4 "TB"$;
with indexes $approx 21.4$ TB.
*4.* 100 ns vs 500 µs $=$ 5,000x. Keep the hot set in-process; batch what must cross the
network.
*5.* $N=5$, $W=3$, $R=3$: $W+R = 6 > 5$, survives $N-W = 2$ write failures and $N-R = 2$
read failures.
*6.* Relief is $1\/(1-h)$. At 92% it is 12.5x; halving DB load needs 25x, so
$h = 1 - 1\/25 = 96%$.
*7.* Anything mutable --- `city`, `plan_tier`, `merchant_region`. Use an immutable id
(`user_id`, `order_id`), or a bucket derived from one.
*8.* Database first, then *delete* the cache key. Never the reverse, never an update.
*9.* Exactly-once *delivery* does not exist. Build exactly-once *effect*: a unique key on
the effect, written in the same transaction as the offset.
*10.* Payment ledger is CP (refuse rather than double-charge); profile photo is AP (serve
a stale one). Usernames CP, follower counts AP.
*11.* $1 - 0.99^16 = 14.9%$.
*12.* Any honest answer with a named component, a named symptom, and a named change.
"Single-leader writes on `orders`; I see it as lock waits above 500/s; I shard by
merchant and move the ledger to its own cluster."
]

#note[
One last thing, and it matters more than any table on these pages. An interviewer is not
checking whether you already know the answer. They are checking whether they would want
you in the room when the system is on fire at 3 a.m. Think out loud, write the numbers
down, name the failure before they ask, and *decide*. That is the whole book.
]
