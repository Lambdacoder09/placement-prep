#import "../../shared/lib/style.typ": *

#chapter(num: 10, title: "Replication, Sharding & Consistency",
  tagline: "Copies keep you alive. Splits keep you fast. Consistency is the promise you make to the reader.")[

#section[The idea in one page]

One database machine can do three things badly at scale. It can *die* and take your data
with it. It can *fill up*. It can *run out of CPU*. Each problem has exactly one family of
answers, and beginners mix them up constantly.

#formulas(title: "Three words, three different jobs")[
#table(columns: (auto, 1fr, 1fr),
  [*Word*], [*What it does*], [*What it does NOT do*],
  [*Replication*],
    [Keeps N complete copies of the same data. Survives a dead machine. Adds read capacity.],
    [Does not add write capacity. Does not add storage capacity. Every copy is the full data.],
  [*Sharding*],
    [Splits the data into pieces. Adds write capacity and storage capacity.],
    [Does not add safety. A shard with one copy is one dead disk away from lost data.],
  [*Consistency model*],
    [The sentence you can honestly tell a reader about what they will see.],
    [Not a tuning knob you turn to "high". It is a promise with a price.],
)

*You almost always need all three, and in this order:*
+ Replicate first. Three copies. This is not optional; it is how you sleep at night.
+ Cache and add read replicas. This buys you 10x reads for almost no design cost.
+ Shard last, when one machine genuinely cannot hold the data or take the writes.

Sharding is the expensive one. It breaks joins, breaks transactions, breaks
`ORDER BY` across the whole table, and it is very hard to undo. Do it when you must,
not when you can.
]

#trap[
The single most common wrong sentence in a design interview: "we will shard the database
so it can handle more traffic". Traffic is usually *reads*. Reads are fixed by a cache and
read replicas — no sharding needed. Sharding is for *writes* and for *size*. Say which one
you are solving, every time.
]

#subsection[The vocabulary — say these words correctly]

#formulas(title: "Say it exactly like this")[
- *Leader (primary).* The one copy that accepts writes. Also called master in old books.
- *Follower (replica, secondary).* Copies that apply the leader's log. Usually read-only.
- *Replication lag.* How far behind a follower is, measured in *seconds* or in *writes*.
- *Synchronous replication.* The leader waits for a follower's ack before answering the
  client. No data loss on failover; slower writes.
- *Asynchronous replication.* The leader answers immediately. Fast writes; a crash loses
  whatever was still in flight.
- *Semi-synchronous.* Wait for *one* follower, not all. The usual real answer.
- *Failover.* Promoting a follower to leader after the leader dies.
- *Split brain.* Two nodes both think they are leader. Both accept writes. You now have
  two truths and no way to merge them.
- *Shard (partition).* One slice of the data, holding a disjoint set of rows.
- *Shard key (partition key).* The field that decides which shard a row lives on.
- *Quorum.* A count of nodes that must agree. $N$ replicas, $W$ to write, $R$ to read.
- *Hot shard / hot key.* One shard or one row taking far more than its fair share.
- *Rebalancing / resharding.* Moving data because the shard count changed.
]

#subsection[What "consistent" actually means — six levels, weakest first]

"Consistent" is not one thing. It is a ladder. Every step up costs latency or availability.
Learn to name the step you are standing on.

#table(columns: (auto, 1fr, 1fr),
  [*Level*], [*The promise to the reader*], [*Typical use*],
  [Eventual], [If writes stop, every replica converges — eventually. Until then, anything.],
    [view counts, "likes", search index],
  [Read-your-writes], [You always see *your own* last write. You may not see mine.],
    [profile edit, "my orders"],
  [Monotonic reads], [You never go backwards in time. Once you saw v5, you never see v4.],
    [a feed you scroll],
  [Consistent prefix], [You see writes in causal order. No reply before its question.],
    [chat, comment threads],
  [Linearizable], [Every read sees the latest committed write, as if there were one machine.],
    [inventory count, username claim],
  [Serializable], [Whole transactions behave as if run one after another.],
    [bank transfer, seat booking],
)

#note[
*Linearizable* is about one object at a time ("this counter behaves like one counter").
*Serializable* is about whole transactions over many objects. A store can be one and not
the other. Saying the right word here is a genuine senior signal.
]

#subsection[CAP, stated correctly]

Most candidates say "CAP means pick two of three". That sentence loses marks because it is
not true. You do not get to choose whether a network partition happens. It happens.

#formulas(title: "CAP, the honest version")[
$ P "(partition)" "is not a choice. It is weather." $

When a partition splits your cluster in two, and a client talks to the minority side,
you have *exactly two options*:

+ *CP:* refuse to answer. Return an error or block. The data stays correct, the service is
  down for that client.
+ *AP:* answer with what you have. The service stays up, the answer may be stale or may
  later conflict with the other side.

There is no third door. So CAP is really: *"during a partition, do you prefer an error or a
stale answer?"*

And the part the interviewer is actually waiting for --- *PACELC*:
$ "if" P "then" (A "or" C) ", " E "lse" (L "or" C) $
"Else" means: when the network is *fine* (which is 99.9% of the time), you still trade
*Latency* against *Consistency*. Waiting for a quorum in another region costs real
milliseconds even when nothing is broken. That "else" branch is where your users actually
live.
]

#trick[
The sentence that scores the CAP mark, every time:
"Partitions are not optional, so the real question is what I do during one. For the
*shopping cart* I choose AP --- showing a slightly old cart beats showing an error, and I
merge by union so nothing is lost. For the *inventory counter* I choose CP --- I would
rather return 503 than sell the last phone twice. Different data in the same product can
sit on different sides of CAP."
]

#subsection[The numbers card — memorise these]

#formulas(title: "Replication and sharding numbers")[
- 1 day $= 86,400$ s. *1 million/day $approx 11.6$/s.*
- Same-datacentre network round trip: *0.5 ms*. Across a region: *1--2 ms*.
- Singapore $<->$ Mumbai round trip: *#h(0pt)~60 ms*. Singapore $<->$ Virginia: *#h(0pt)~230 ms*.
- One SSD disk read: *#h(0pt)~0.1 ms*. One `fsync`: *#h(0pt)~1--2 ms*.
- One mid-size SQL node: *#h(0pt)~5,000 writes/s*, *#h(0pt)~20,000 indexed reads/s*.
- One Redis node: *#h(0pt)~100,000 simple ops/s*.
- Disk restore/rebuild speed: *#h(0pt)~200 MB/s*. This is what sets your shard *size*.
- Comfortable shard size: *200 GB to 1 TB*. Bigger and a rebuild takes hours.
- *Quorum rule:* $W + R > N$ gives you a guaranteed overlap of at least one node.
- *Write availability:* you survive $N - W$ node failures for writes, $N - R$ for reads.
- Consistent hashing moves $1 slash (N+1)$ of keys when you add the $(N+1)$-th node.
  Modulo hashing moves about $N slash (N+1)$ --- nearly everything.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[A leader takes 10,000 writes/s for 60 seconds during a
sale. Its follower can only apply 8,000 writes/s. After the sale the leader drops to
5,000 writes/s. How big does the backlog get, and how long until the follower catches up?
#sol[
*Step 1 --- the gap while the sale runs.*
$ 10,000 - 8,000 = 2,000 "writes/s of backlog growth" $

*Step 2 --- backlog at the end of 60 seconds.*
$ 2,000 times 60 = 120,000 "writes behind" $

*Step 3 --- drain rate after the sale.* The follower still applies 8,000/s, but 5,000/s of
new work keeps arriving.
$ 8,000 - 5,000 = 3,000 "writes/s of catch-up" $

*Step 4 --- time to catch up.*
$ 120,000 \/ 3,000 = 40 "seconds" $

So for 100 seconds in total, any read served from that follower can be stale --- at the
worst moment, by $120,000 \/ 10,000 = 12$ seconds of real time.
]
#ans[120,000 writes of backlog, 40 seconds to drain, up to ~12 s of staleness]
]

#trap[
Notice the follower *never fell over*. It just fell behind. That is the danger: a lagging
replica looks perfectly healthy in every dashboard except the one that measures lag. Alarm
on lag in *seconds*, not on CPU.
]

#ex(2, tier: 0, asked: "warm-up")[You have $N = 5$ replicas. For each pair below, say
whether a read is guaranteed to see the newest committed write, and how many node failures
the system survives.
#table(columns: 4, [*$W$*], [*$R$*], [*$W+R$*], [*?*],
  [3], [3], [], [], [5], [1], [], [], [1], [1], [], [], [4], [2], [], [])
#sol[
The rule is $W + R > N$. If the write quorum and the read quorum must overlap in at least
one node, then that node has the newest value, and the reader can pick the highest version.

#table(columns: (auto, auto, auto, 1fr, 1fr),
  [*$W$*], [*$R$*], [*$W+R$*], [*Sees newest?*], [*Survives*],
  [3], [3], [6 > 5], [*yes* --- overlap of $6-5 = 1$ node],
    [writes: $5-3 = 2$ down; reads: $5-3 = 2$ down],
  [5], [1], [6 > 5], [*yes* --- every node has it, so any one node answers],
    [writes: $5-5 = 0$ down (fragile!); reads: 4 down],
  [1], [1], [2 $lt.eq$ 5], [*no* --- the one writer and the one reader can be different nodes],
    [writes: 4 down; reads: 4 down],
  [4], [2], [6 > 5], [*yes*], [writes: 1 down; reads: 3 down],
)

Read the second row again. $W = 5$ looks "safest" and is in fact the *worst* choice for
availability: a single node reboot for a security patch stops all writes.
]
#ans[Rows 1, 2 and 4 are strongly consistent; row 3 is not. $W=3, R=3$ is the balanced pick.]
]

#ex(3, tier: 0, asked: "warm-up")[A dataset is 20 TB. One node holds 2 TB comfortably. Peak
write load is 60,000 writes/s and one node handles 5,000 writes/s. How many shards, and how
many machines at replication factor 3?
#sol[
Two constraints. Compute both, take the larger.

*Constraint A --- size.*
$ 20 "TB" \/ 2 "TB per node" = 10 "shards" $

*Constraint B --- write throughput.*
$ 60,000 \/ 5,000 = 12 "shards" $

*Shards needed* $= max(10, 12) = 12$.

*Machines.* Each shard needs 3 copies:
$ 12 times 3 = 36 "database instances" $
Those 36 instances do not need 36 physical machines --- you can pack 2 per machine, giving
18 machines, as long as *no two copies of the same shard sit on the same machine or the
same rack*. That last clause is the whole point of replication.
]
#ans[12 shards, 36 instances, packed onto $gt.eq$ 18 machines with anti-affinity]
]

#ex(4, tier: 0, asked: "warm-up")[You have 10 cache nodes and route keys with
`hash(key) % 10`. You add an eleventh node. What fraction of keys move? What if you use
consistent hashing instead?
#sol[
*Modulo.* A key stays put only if $h mod 10 = h mod 11$. For a uniform hash that happens
for roughly $1 slash 11$ of keys.
$ "moved" approx 1 - 1\/11 = 10\/11 = 90.9% $

*Consistent hashing.* The new node claims one arc of the ring. Only the keys inside that arc
move, and only from the one node that owned the arc.
$ "moved" approx 1\/11 = 9.09% $

*Why it matters in real money.* Suppose the cache holds 50 GB and serves a 95% hit rate.
Moving 90.9% of keys means $50 times 0.909 = 45.5$ GB of cache goes cold at once, and
every one of those keys becomes a database read until it is refilled. Moving 9.09% means
$50 times 0.0909 = 4.5$ GB goes cold. That is a 10x difference in the size of the stampede
you hand to your database.
]
#ans[Modulo: ~90.9% move. Consistent hashing: ~9.1% move.]
]

#ex(5, tier: 0, asked: "warm-up")[Your logical data is 4 TB and grows 40% a year. You run
replication factor 3, and the storage engine needs 50% free space for compaction. How much
raw disk do you buy for year one, and for year three?
#sol[
*Year 1.*
$ 4 "TB" times 3 "(RF)" = 12 "TB of replicated data" $
$ 12 times 1.5 "(compaction headroom)" = 18 "TB of raw disk" $

*Year 3.* Grow the logical size first.
$ 4 times 1.4 = 5.6 "TB (end of year 1)" $
$ 5.6 times 1.4 = 7.84 "TB (end of year 2)" $
$ 7.84 times 1.4 = 10.976 approx 11.0 "TB (end of year 3)" $
Then apply the same two multipliers:
$ 11.0 times 3 times 1.5 = 49.5 "TB of raw disk" $
]
#ans[18 TB now, ~49.5 TB by end of year three]
]

#trap[
Candidates quote the *logical* size and stop. The interviewer is waiting for
$times "RF" times "headroom"$. Forgetting the 1.5x is how real clusters run out of disk at
2 a.m., because a log-structured store needs free space to merge files, and a full disk
means it cannot even delete data.
]

#ex(6, tier: 0, asked: "warm-up")[16 shards. Peak load 40,000 writes/s. One enterprise
customer generates 12% of all writes and all of their rows land on one shard. How loaded is
that shard compared with the average?
#sol[
*Average shard.*
$ 40,000 \/ 16 = 2,500 "writes/s" $

*The hot shard* gets the big customer plus its normal share of everyone else.
$ "from the big customer" = 40,000 times 0.12 = 4,800 "writes/s" $
$ "its share of the rest" = 40,000 times 0.88 \/ 16 = 2,200 "writes/s" $
$ "total" = 4,800 + 2,200 = 7,000 "writes/s" $

*Ratio.*
$ 7,000 \/ 2,500 = 2.8 times "the average" $

If one node handles 5,000 writes/s, this shard is over capacity while the other 15 sit at
half load. You cannot fix that by adding shards: 32 shards would give the hot one
$4,800 + 40,000 times 0.88 \/ 32 = 4,800 + 1,100 = 5,900$/s. Still over. The big
customer must be *split*, not the cluster.
]
#ans[7,000 writes/s, which is 2.8x the average --- adding shards does not fix it]
]

#ex(7, tier: 0, asked: "warm-up")[A write takes 2 ms to commit locally. You want it
replicated synchronously to a second region 60 ms round trip away. Each API server holds
200 concurrent database connections. What is the maximum write throughput per server,
before and after?
#sol[
*Before (async, local only).* Time per write $= 2$ ms $= 0.002$ s.
$ 200 \/ 0.002 = 100,000 "writes/s per server" $

*After (sync across regions).* Time per write $= 2 + 60 = 62$ ms $= 0.062$ s.
$ 200 \/ 0.062 = 3,225.8 approx 3,226 "writes/s per server" $

*The cost.*
$ 100,000 \/ 3,226 = 31 times "less throughput" $

To keep 100,000 writes/s you would need $100,000 \/ 3,226 = 31$ servers instead of 1,
*or* far more connections, which just moves the queue somewhere else.
]
#ans[100,000/s drops to ~3,226/s --- a 31x loss of throughput for cross-region sync]
]

#note[
This one number is why nobody replicates synchronously across continents for ordinary data.
It is also why the systems that *do* (global databases with consensus) charge a lot and are
used only for the small, precious slice of data that truly needs it.
]

#ex(8, tier: 0, asked: "warm-up")[A user edits her profile, then the app immediately reloads
the profile page. Replication lag is 50 ms most of the time but occasionally 3 seconds.
What breaks, and give three fixes.
#sol[
*What breaks.* The write goes to the leader. The reload is a read, and a read balancer
sends it to a follower. If that follower has not applied the write, the user sees her *old*
name and thinks the save failed. She saves again. Now you have duplicate work and an angry
user.

*Fix 1 --- read from the leader for a window.* After a write, pin that user's reads to the
leader for, say, 5 seconds. Cost: the leader takes extra read load, but only from users who
just wrote --- a tiny fraction.

*Fix 2 --- read your own writes by version.* The write returns a version number
(`v=8124`). The client sends `If-Version-At-Least: 8124` with the read. A follower that is
behind either waits or replies "ask the leader". Cost: one extra field everywhere.

*Fix 3 --- do not read at all.* The write response *contains* the new profile. The client
renders that and never issues the read. Cost: nothing. This is the best fix and candidates
almost never say it.

*Decision:* Fix 3 first because it is free, Fix 1 as the general safety net for pages you
cannot control. Fix 2 only if you already carry versions for another reason --- otherwise it
touches every endpoint.
]
#ans[Read-your-writes is violated. Best fix: return the new value from the write; back it up with leader-pinning for 5 s.]
]

#practice(tier: 0, time: "12 min")[
+ $N = 7$. You want to survive 2 node failures for both reads and writes, and still read the
  newest write. Give a $(W, R)$ pair and prove it.
+ Logical data 12 TB, RF 3, 40% compaction headroom, one node holds 3 TB. How many nodes?
+ A follower is 45 minutes behind at 9 a.m. and gains 400 writes/s of ground while the
  leader takes 1,200 writes/s. When does it catch up?
+ You shard by `hash(user_id)` into 8 shards. A celebrity user has 2% of all reads. Is that
  a hot shard problem? Show the arithmetic.
+ Cross-region round trip is 230 ms. A checkout does 4 sequential database calls. Compare
  total latency for a local leader versus a remote leader.
]
#key[
+ Survive 2 failures means $W lt.eq 5$ and $R lt.eq 5$. Newest write means $W + R > 7$, so
  $W + R gt.eq 8$. Take $W = 4, R = 4$: $4 + 4 = 8 > 7$ #sym.checkmark, survives $7-4 = 3$
  failures for both. Even better than asked.
+ $12 times 3 = 36$ TB replicated; $36 times 1.4 = 50.4$ TB raw;
  $50.4 \/ 3 = 16.8 arrow.r 17$ nodes.
+ 45 min $= 2,700$ s of lag at 1,200 writes/s $= 3,240,000$ writes behind.
  Catch-up rate 400/s. $3,240,000 \/ 400 = 8,100$ s $= 2.25$ hours. It catches up at
  about 11:15 a.m. --- *if* the leader's rate does not rise at lunchtime, which it will.
+ Average shard read share $= 100% \/ 8 = 12.5%$. The celebrity adds 2% to one shard, giving
  it $2 + 98\/8 = 2 + 12.25 = 14.25%$, which is $14.25 \/ 12.5 = 1.14 times$ the average.
  *Not* a hot shard problem. A hot *key* problem, yes --- fixed by caching that one user's
  row, not by resharding. Reserve the word "hot shard" for ratios above about 2x.
+ Local: $4 times 2 "ms" = 8$ ms. Remote: $4 times 230 = 920$ ms, just under a second, and
  that is before any application work. Fix: make the calls in one round trip (a stored
  procedure or a batched API), which brings the remote case to ~230 ms.
]

#section[Tier 1 --- build the pieces yourself]
#tier-header(1)

Service-company rounds rarely say "design a sharded cluster". They say "write a consistent
hashing class" or "how would you code a quorum read". These five pieces are the ones that
actually get asked. Every one of them runs.

#subsection[Piece 1 --- a consistent hash ring]

#ex(9, tier: 1, asked: "Infosys · pattern")[Write a class that maps keys to N nodes so that
adding or removing a node moves as few keys as possible. Then *measure* how many keys move.
#sol[

*The idea.* Imagine the hash space $0 .. 2^32 - 1$ bent into a circle. Every node is placed
at several points on that circle. To find a key's node, hash the key and walk *clockwise*
to the first node point you meet.

#diagram(height: 6.9cm, caption: "The ring. Each node owns the arc that ends at its point. A key walks clockwise to its owner.")[
  #place(dx: 130pt, dy: 20pt)[#circle(radius: 70pt, stroke: (paint: rgb("#9bb3c2"), thickness: 0.8pt, dash: "dashed"))]
  #place(dx: 253pt, dy: 81pt)[#block(width: 34pt, height: 18pt, fill: rgb("#eef3f7"), stroke: 0.8pt + dc, radius: 3pt)[#align(center + horizon)[#text(size: 8pt)[n0]]]]
  #place(dx: 232pt, dy: 31pt)[#block(width: 34pt, height: 18pt, fill: rgb("#eef3f7"), stroke: 0.8pt + dc, radius: 3pt)[#align(center + horizon)[#text(size: 8pt)[n1]]]]
  #place(dx: 183pt, dy: 11pt)[#block(width: 34pt, height: 18pt, fill: rgb("#eef3f7"), stroke: 0.8pt + dc, radius: 3pt)[#align(center + horizon)[#text(size: 8pt)[n2]]]]
  #place(dx: 134pt, dy: 31pt)[#block(width: 34pt, height: 18pt, fill: rgb("#eef3f7"), stroke: 0.8pt + dc, radius: 3pt)[#align(center + horizon)[#text(size: 8pt)[n3]]]]
  #place(dx: 113pt, dy: 81pt)[#block(width: 34pt, height: 18pt, fill: rgb("#eef3f7"), stroke: 0.8pt + dc, radius: 3pt)[#align(center + horizon)[#text(size: 8pt)[n0']]]]
  #place(dx: 134pt, dy: 131pt)[#block(width: 34pt, height: 18pt, fill: rgb("#eef3f7"), stroke: 0.8pt + dc, radius: 3pt)[#align(center + horizon)[#text(size: 8pt)[n1']]]]
  #place(dx: 183pt, dy: 151pt)[#block(width: 34pt, height: 18pt, fill: rgb("#eef3f7"), stroke: 0.8pt + dc, radius: 3pt)[#align(center + horizon)[#text(size: 8pt)[n2']]]]
  #place(dx: 232pt, dy: 131pt)[#block(width: 34pt, height: 18pt, fill: rgb("#eef3f7"), stroke: 0.8pt + dc, radius: 3pt)[#align(center + horizon)[#text(size: 8pt)[n3']]]]

  #place(dx: 172pt, dy: 82pt)[#text(size: 8pt, fill: muted)[hash space]]
  #place(dx: 176pt, dy: 94pt)[#text(size: 8pt, fill: muted)[$0 .. 2^32$]]

  #darrow(200pt, 70pt, 246pt, 46pt, label: "key k")
  #place(dx: 258pt, dy: 52pt)[#text(size: 7.5pt, fill: dc)[k lands here,]]
  #place(dx: 258pt, dy: 62pt)[#text(size: 7.5pt, fill: dc)[walks to n1]]

  #place(dx: 0pt, dy: 176pt)[#text(size: 8pt)[Add a node: it lands somewhere on the circle and steals *one arc* from *one* neighbour.]]
  #place(dx: 0pt, dy: 188pt)[#text(size: 8pt)[Every other key keeps its owner. `n0'` and `n0` are two *virtual points* for the same machine.]]
]

*Why virtual nodes?* With one point per machine, the arcs come out wildly uneven --- one
machine can own 20 times what another owns. Giving each machine 150 points averages the
unevenness away. The measurement below shows both.

#code(lang: "js", caption: "ring.js — runs as written")[
```js
function fnv1a(str) {
  let h = 0x811c9dc5;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;     // imul keeps it a 32-bit multiply
  }
  // avalanche: without this, "n0#1" and "n0#2" land next to each other
  h ^= h >>> 16; h = Math.imul(h, 0x7feb352d) >>> 0;
  h ^= h >>> 15; h = Math.imul(h, 0x846ca68b) >>> 0;
  h ^= h >>> 16;
  return h >>> 0;
}

// first index whose key >= target
function lowerBound(arr, target, key = x => x) {
  let lo = 0, hi = arr.length;
  while (lo < hi) {
    const mid = (lo + hi) >> 1;
    if (key(arr[mid]) < target) lo = mid + 1; else hi = mid;
  }
  return lo;
}

class ConsistentHashRing {
  constructor(vnodes = 150) {
    this.vnodes = vnodes;
    this.ring = [];                 // sorted array of { hash, node }
    this.nodes = new Set();
  }

  addNode(name) {
    if (this.nodes.has(name)) return;
    this.nodes.add(name);
    for (let i = 0; i < this.vnodes; i++) {
      this.ring.push({ hash: fnv1a(`${name}#${i}`), node: name });
    }
    // numeric comparator, never bare sort()
    this.ring.sort((a, b) => a.hash - b.hash);
  }

  removeNode(name) {
    if (!this.nodes.delete(name)) return;
    this.ring = this.ring.filter(e => e.node !== name);
  }

  // clockwise walk = binary search + wrap
  locate(key) {
    if (this.ring.length === 0) return null;
    let i = lowerBound(this.ring, fnv1a(key), e => e.hash);
    // past the last point: wrap to the first
    if (i === this.ring.length) i = 0;
    return this.ring[i].node;
  }

  locateN(key, n) {                              // the n replicas for this key
    const out = [];
    if (this.ring.length === 0) return out;
    const h = fnv1a(key);
    const start = lowerBound(this.ring, h, e => e.hash) % this.ring.length;
    for (let s = 0; s < this.ring.length && out.length < n; s++) {
      const nd = this.ring[(start + s) % this.ring.length].node;
      // skip vnodes of a node already chosen
      if (!out.includes(nd)) out.push(nd);
    }
    return out;
  }
}
```
]

#code(lang: "js", caption: "the measurement — this is the part that earns the mark")[
```js
const KEYS = Array.from({ length: 100000 }, (_, i) => `user:${i}`);

const ring = new ConsistentHashRing(150);
for (let i = 0; i < 10; i++) ring.addNode(`n${i}`);
const before = KEYS.map(k => ring.locate(k));
ring.addNode('n10');
const after  = KEYS.map(k => ring.locate(k));

let moved = 0;
for (let i = 0; i < KEYS.length; i++) if (before[i] !== after[i]) moved++;
console.log('consistent: moved', (100 * moved / KEYS.length).toFixed(2) + '%',
            ' ideal 1/11 =', (100 / 11).toFixed(2) + '%');

let movedMod = 0;
for (const k of KEYS) if (fnv1a(k) % 10 !== fnv1a(k) % 11) movedMod++;
console.log('modulo  : moved', (100 * movedMod / KEYS.length).toFixed(2) + '%');

// how evenly are the keys spread over the 11 nodes?
const count = new Map();
for (const k of KEYS) {
  const n = ring.locate(k);
  count.set(n, (count.get(n) || 0) + 1);
}
const v = [...count.values()].sort((a, b) => a - b);
console.log('vnodes=150: min', v[0], 'max', v[v.length - 1],
            'ideal', Math.round(KEYS.length / 11));

// the same measurement with ONE point per machine
const ring1 = new ConsistentHashRing(1);
for (let i = 0; i < 11; i++) ring1.addNode(`n${i}`);
const c1 = new Map();
for (const k of KEYS) {
  const n = ring1.locate(k);
  c1.set(n, (c1.get(n) || 0) + 1);
}
const v1 = [...c1.values()].sort((a, b) => a - b);
console.log('vnodes=1  : min', v1[0], 'max', v1[v1.length - 1],
            'spread', (v1[v1.length - 1] / v1[0]).toFixed(1) + 'x');

console.log('replicas for user:42 ->', ring.locateN('user:42', 3));
```
]

#code(lang: "text", caption: "actual output")[
```text
consistent: moved 8.25%  ideal 1/11 = 9.09%
modulo  : moved 91.05%
vnodes=150: min 8246 max 10870 ideal 9091
vnodes=1  : min 301 max 19410 spread 64.5x
replicas for user:42 -> [ 'n7', 'n10', 'n9' ]
```
]

Read the last three lines carefully. With 150 virtual nodes the busiest machine holds
$10,870 \/ 8,246 = 1.32$ times the quietest. With *one* virtual node per machine, the
busiest holds $19,410 \/ 301 = 64.5$ times the quietest --- one machine melts while
another is idle. Virtual nodes are not a detail; they are the whole trick.
]
]

#trap[
*JS trap.* `this.ring.sort()` with no comparator sorts the 32-bit hashes as *text*.
`[10, 9, 1]` becomes `[1, 10, 9]`. Your binary search then returns garbage and the ring
silently sends keys to the wrong node. Always `(a, b) => a - b`.
]

#note[
Interviewers sometimes ask "why not just `hash(key) % N`?" The answer in one sentence:
"because $N$ changes, and modulo makes almost every key change owner when it does, which
turns one added node into a full cache flush and a database stampede."
]

#subsection[Piece 2 --- a quorum store]

#ex(10, tier: 1, asked: "Capgemini · pattern")[Code a key-value store over $N$ replicas
with tunable $W$ and $R$. Show that $W + R > N$ really does prevent a stale read, and that
$W + R lt.eq N$ really does allow one.
#sol[

#diagram(height: 4.4cm, caption: "N = 5, W = 3, R = 3. The two quorums must share at least 6 - 5 = 1 node. That node holds the newest value.")[
  #dnode(0pt, 40pt, 52pt, 26pt, "r0", fill: rgb("#e3eef3"))
  #dnode(60pt, 40pt, 52pt, 26pt, "r1", fill: rgb("#e3eef3"))
  #dnode(120pt, 40pt, 52pt, 26pt, "r2", fill: rgb("#dbe7c9"))
  #dnode(180pt, 40pt, 52pt, 26pt, "r3", fill: rgb("#f2e6d6"))
  #dnode(240pt, 40pt, 52pt, 26pt, "r4", fill: rgb("#f2e6d6"))

  #place(dx: 0pt, dy: 16pt)[#line(start: (0pt, 0pt), end: (172pt, 0pt), stroke: 1.4pt + rgb("#33556b"))]
  #place(dx: 55pt, dy: 2pt)[#text(size: 8pt, fill: dc)[write quorum W = 3]]
  #place(dx: 120pt, dy: 76pt)[#line(start: (0pt, 0pt), end: (172pt, 0pt), stroke: 1.4pt + rgb("#8c2f39"))]
  #place(dx: 172pt, dy: 80pt)[#text(size: 8pt, fill: t3col)[read quorum R = 3]]

  #place(dx: 122pt, dy: 96pt)[#text(size: 8pt, fill: rgb("#2f6b3f"))[overlap: r2]]

  #place(dx: 310pt, dy: 20pt)[#text(size: 8.5pt)[$W + R = 6 > N = 5$]]
  #place(dx: 310pt, dy: 36pt)[#text(size: 8.5pt)[overlap $= 6 - 5 = 1$]]
  #place(dx: 310pt, dy: 52pt)[#text(size: 8.5pt)[survives 2 dead nodes]]
  #place(dx: 310pt, dy: 68pt)[#text(size: 8.5pt)[for reads *and* writes]]

  #place(dx: 0pt, dy: 112pt)[#text(size: 8pt, fill: muted)[If W were 3 and R were 2, the sum is 5, which is not greater than 5 --- the two ranges could sit side by side]]
  #place(dx: 0pt, dy: 124pt)[#text(size: 8pt, fill: muted)[with no shared node, and the reader would return an old value with a clear conscience.]]
]

#code(lang: "js", caption: "quorum.js — a replica and the coordinator above it")[
```js
class Replica {
  constructor(id) { this.id = id; this.data = new Map(); this.up = true; }
  put(key, value, version) {
    if (!this.up) throw new Error(`${this.id} down`);
    const cur = this.data.get(key);
    if (!cur || version > cur.version) this.data.set(key, { value, version });
    // an older version arriving late is simply ignored
    return true;
  }
  get(key) {
    if (!this.up) throw new Error(`${this.id} down`);
    return this.data.get(key) || null;
  }
}

class QuorumStore {
  constructor(n, w, r) {
    if (w + r <= n) console.warn(`W+R=${w+r} <= N=${n}: stale reads`);
    this.replicas = Array.from({ length: n }, (_, i) => new Replica(`r${i}`));
    this.N = n; this.W = w; this.R = r;
    this.clock = 0;
  }

  write(key, value) {
    // stands in for a real timestamp or counter
    const version = ++this.clock;
    let ok = 0; const failed = [];
    for (const rep of this.replicas) {
      try { rep.put(key, value, version); ok++; } catch { failed.push(rep.id); }
    }
    if (ok < this.W) return { ok: false, acks: ok, need: this.W };
    return { ok: true, acks: ok, version, hintedFor: failed };
  }

  read(key) {
    const seen = [];
    for (const rep of this.replicas) {
      try { seen.push({ id: rep.id, v: rep.get(key) }); } catch { /* down */ }
      // stop as soon as R replicas answered
      if (seen.length === this.R) break;
    }
    if (seen.length < this.R) {
      return { ok: false, replies: seen.length, need: this.R };
    }

    let best = null;
    for (const s of seen) {
      if (s.v && (!best || s.v.version > best.version)) best = s.v;
    }

    // read repair: quietly fix any replica in this quorum that was behind
    for (const s of seen) if (best && (!s.v || s.v.version < best.version)) {
      const r = this.replicas.find(x => x.id === s.id);
      try { r.put(key, best.value, best.version); }
      catch {}
    }
    if (!best) return { ok: true, value: null, version: 0 };
    return { ok: true, value: best.value, version: best.version };
  }
}
```
]

#code(lang: "text", caption: "actual output")[
```text
--- N=5, W=3, R=3  (W+R=6 > 5) ---
write: { ok: true, acks: 5, version: 1, hintedFor: [] }
write, 2 nodes down: { ok: true, acks: 3, version: 2, hintedFor: ['r0','r1'] }
read  with 2 nodes down: { ok: true, value: 250, version: 2 }
write with 3 nodes down: { ok: false, acks: 2, need: 3 }
read  with 3 nodes down: { ok: false, replies: 2, need: 3 }

--- N=5, W=1, R=1  (W+R=2 <= 5): stale read is possible ---
W+R=2 <= N=5: stale reads
read sees: { ok: true, value: null, version: 0 }
```
]

Line by line:
- With 2 of 5 nodes dead, writes and reads both still work, and the read returns the *new*
  value (250). That is $W + R > N$ doing its job.
- With 3 dead, $W = 3$ can no longer be met. The store *refuses the write*. It did not
  quietly accept it on 2 nodes and hope. That refusal is the CP choice, made by arithmetic.
- In the second block, $W = 1$ and $R = 1$: the write landed only on `r0`, `r0` then went
  away, and the reader asked `r1`, which had never heard of the key. The value did not just
  look old --- *it was gone*.

*`hintedFor`* is the hook for hinted handoff: a live node holds the write on behalf of the
dead one and replays it when that node returns. Say the phrase; it is the standard answer to
"what happens to the two nodes that missed the write?"
]
]

#note[
*Read repair* is why an eventually-consistent store converges without a background job doing
all the work: every read quietly fixes the replicas it touched. Popular keys self-heal in
milliseconds. Cold keys need the background repair process --- that is what *anti-entropy*
and *Merkle trees* are for. Name-drop both; one sentence each is enough.
]

#subsection[Piece 3 --- version vectors: a real conflict versus a stale copy]

#ex(11, tier: 1, asked: "Cognizant · pattern")[Two regions accept a write to the same key at
the same moment. How does the store know whether one write simply *came later*, or whether
the two writes genuinely *conflict*? Code it.
#sol[

*Why a timestamp is not enough.* Two servers' clocks differ. If Singapore's clock is 40 ms
ahead of Mumbai's, then a write made in Mumbai *after* the Singapore one still carries a
smaller timestamp, and last-write-wins throws away the newer change. Silently. Forever.

*The fix.* Each writer keeps its own counter. A value carries the whole map
$\{"writer" -> "counter"\}$. Now comparison is mechanical.

#formulas(title: "Comparing two version vectors A and B")[
- Every counter in A is $gt.eq$ B's, and at least one is bigger $arrow.r$ *A is newer*.
- The mirror image $arrow.r$ *B is newer*.
- A is bigger somewhere *and* B is bigger somewhere else $arrow.r$ *CONCURRENT*.
  This is a true conflict. Somebody has to decide what to do.
- All equal $arrow.r$ same version.
]

#code(lang: "js", caption: "vv.js — the whole idea in 30 lines")[
```js
class VersionVector {
  constructor(map = new Map()) { this.v = new Map(map); }
  bump(node) {
    const c = new Map(this.v);
    c.set(node, (c.get(node) || 0) + 1);
    // immutable: a new version, not a mutation
    return new VersionVector(c);
  }
  get(node) { return this.v.get(node) || 0; }
  keys() { return new Set([...this.v.keys()]); }
  merge(o) {
    const c = new Map(this.v);
    for (const k of o.v.keys()) c.set(k, Math.max(this.get(k), o.get(k)));
    return new VersionVector(c);
  }
  toString() {
    const parts = [...this.v.entries()].sort().map(([k, n]) => `${k}:${n}`);
    return '{' + parts.join(' ') + '}';
  }
}

function compare(a, b) {
  const all = new Set([...a.keys(), ...b.keys()]);
  let aBigger = false, bBigger = false;
  for (const k of all) {
    if (a.get(k) > b.get(k)) aBigger = true;
    if (b.get(k) > a.get(k)) bBigger = true;
  }
  if (aBigger && bBigger) return 'CONCURRENT';   // a real conflict
  if (aBigger) return 'A_NEWER';
  if (bBigger) return 'B_NEWER';
  return 'EQUAL';
}
```
]

#code(lang: "text", caption: "actual output")[
```text
sg = {sg:2}  in = {in:1 sg:1}
sg vs base  -> A_NEWER
sg vs in    -> CONCURRENT
merged      -> {in:1 sg:2}
LWW keeps   -> [ 'shoes', 'hat' ]
union keeps -> [ 'hat', 'shoes', 'socks' ]
```
]

The last two lines are the punchline. A user added `socks` in Singapore and `hat` in Mumbai
to the same cart. Last-write-wins keeps one and *deletes the other item the user chose*.
Merging by union keeps both. For a cart, union is obviously right.

#formulas(title: "How to resolve a CONCURRENT pair --- pick one and say why")[
#table(columns: (auto, 1fr, 1fr),
  [*Strategy*], [*Good for*], [*Cost*],
  [Last-write-wins],
    [values where the newest genuinely replaces the old: "display theme = dark"],
    [silently loses data; depends on clocks you do not control],
  [Merge function (union, max, sum)],
    [sets and counters: carts, tags, seen-lists, like counts],
    [you must write the function, and it must be commutative],
  [Keep both, ask the user],
    [documents, text a human wrote],
    [product work: a UI for "you have two versions"],
  [Refuse to have conflicts],
    [money, inventory, username claims],
    [one leader per key, and the latency that comes with it],
)
*Decision for a shopping cart: merge by union, plus a tombstone for removals* so that
"I deleted the hat" is itself a write that can win, rather than being undone by the union.
]
]
]

#trap[
Version vectors grow. One entry per *writer*, forever. If your writer id is the server
process, a cluster that has ever run 4,000 pods carries 4,000 entries on every value. Use a
small, stable set of writer ids --- one per *replica* or one per *region*, not one per
process --- and prune entries that have not changed in a long time.
]

#subsection[Piece 4 --- the shard router]

#ex(12, tier: 1, asked: "TCS NQT · pattern")[Write three routers --- range, hash, and
directory --- and show, with real keys, what each one gets right and wrong.
#sol[
#code(lang: "js", caption: "router.js")[
```js
class RangeRouter {                    // bounds sorted by upTo
  constructor(bounds) { this.bounds = bounds; }
  route(key) {
    for (const b of this.bounds) if (key <= b.upTo) return b.shard;
    return 'overflow';
  }
}

class HashRouter {
  constructor(n) { this.n = n; }
  route(key) {
    let h = 0;
    for (const c of key) h = (h * 31 + c.charCodeAt(0)) >>> 0;
    return `s${h % this.n}`;
  }
}

// an editable lookup table in front of a default
class DirectoryRouter {
  constructor() { this.map = new Map(); this.fallback = new HashRouter(4); }
  pin(key, shard) { this.map.set(key, shard); }
  route(key) { return this.map.get(key) ?? this.fallback.route(key); }
}
```
]

#code(lang: "text", caption: "actual output, with keys that start with a date")[
```text
range routing (all of today lands on ONE shard):
   order_2026_09_15_a -> s0
   order_2026_09_15_b -> s0
   order_2026_09_15_c -> s0
   order_2026_09_16_a -> s1
   order_2026_09_16_b -> s1
hash routing (today is spread):
   order_2026_09_15_a -> s0
   order_2026_09_15_b -> s1
   order_2026_09_15_c -> s2
   order_2026_09_16_a -> s1
   order_2026_09_16_b -> s2
directory: tenant:mega_corp -> s_dedicated | tenant:small_shop -> s2
```
]

#table(columns: (auto, 1fr, 1fr, 1fr),
  [*Router*], [*Wins at*], [*Loses at*], [*Use when*],
  [Range],
    [range scans: "all orders in September" is one shard, one scan],
    [*every new write goes to the last shard.* A date-ordered key makes a permanent hot shard.],
    [time-series you mostly read by range, and you accept the write hotspot],
  [Hash],
    [even spread of writes; no hotspot from ordered keys],
    [a range scan must ask *every* shard and merge],
    [the default. Pick this unless you have a scan-shaped workload],
  [Directory],
    [you can move one noisy tenant to its own shard without touching anyone else],
    [the directory itself must be highly available and cached everywhere],
    [multi-tenant systems where tenants differ in size by 1000x],
)

*Decision for a general OLTP service: hash routing, with a directory override table for the
handful of keys that misbehave.* You get an even spread by default and an escape hatch for
the one customer who is 12% of your traffic --- which is Example 6, solved.
]
]

#trick[
The trick that makes resharding survivable: *never hash directly to a shard*. Hash to a
large fixed number of *virtual buckets* --- say 1,024 --- and keep a small map from bucket to
shard.
$ "bucket" = "hash"("key") mod 1024, quad "shard" = "bucketMap"["bucket"] $
The bucket of a key *never changes*, for the life of the system. Growing from 16 to 32
shards is now a change to a 1,024-entry map plus the copying of 512 buckets. No key is ever
rehashed. Every serious sharded system does this.
]

#subsection[Piece 5 --- leases and fencing tokens (how failover does not corrupt data)]

#ex(13, tier: 1, asked: "Accenture · pattern")[Node A is the leader. A pauses for 12 seconds
(garbage collection, a slow disk, a paused VM). The cluster promotes B. Then A wakes up,
still believing it is the leader, and writes. Stop the corruption.
#sol[

*Why a simple lock fails.* A held a lock. The lock timed out. But A never found out --- it
was frozen, not disconnected. When A resumes it does not check; it just writes. No amount of
"but the lock expired" helps, because the write is already on its way to the disk.

*The fix: a fencing token.* Every time leadership changes, the token goes *up*. The storage
layer remembers the highest token it has seen and refuses anything lower. Now a late write
from an old leader is rejected *by the storage*, not by the sender's good manners.

#code(lang: "js", caption: "lease.js")[
```js
class LeaseService {
  constructor(ttlMs) {
    this.ttlMs = ttlMs;
    this.holder = null;
    this.expiresAt = 0;
    this.token = 0;
  }

  acquire(node, now) {
    if (this.holder !== null && now < this.expiresAt && this.holder !== node) {
      const msLeft = this.expiresAt - now;
      return { granted: false, holder: this.holder, msLeft };
    }
    // a NEW leader gets a NEW, higher token
    if (this.holder !== node) this.token += 1;
    this.holder = node;
    this.expiresAt = now + this.ttlMs;
    return { granted: true, token: this.token, expiresAt: this.expiresAt };
  }

  renew(node, now) {
    const dead = this.holder !== node || now >= this.expiresAt;
    if (dead) return { granted: false };
    this.expiresAt = now + this.ttlMs;
    return { granted: true, token: this.token };
  }
}

class FencedStorage {
  constructor() { this.highestSeen = 0; this.log = []; }
  write(token, what) {
    if (token < this.highestSeen) {
      return { ok: false, why: `stale token ${token} < ${this.highestSeen}` };
    }
    this.highestSeen = token;
    this.log.push(`${what} (token ${token})`);
    return { ok: true };
  }
}
```
]

#code(lang: "text", caption: "actual output — A's late write is rejected")[
```text
t=0     A acquires: { granted: true, token: 1, expiresAt: 10000 }
t=0     A writes  : { ok: true }
t=12000 B acquires: { granted: true, token: 2, expiresAt: 22000 }
t=12000 B writes  : { ok: true }
t=12001 A writes  : { ok: false, why: 'stale token 1 < 2' }
log: [ 'A: set x=1 (token 1)', 'B: set x=2 (token 2)' ]
```
]

#formulas(title: "Three rules for safe failover")[
+ *Lease, not lock.* A lease expires by itself. The holder must keep renewing. If the
  holder freezes, the lease dies on its own with no help from anybody.
+ *Fencing token, always increasing.* Storage rejects anything below the highest token it
  has seen. This is what actually prevents corruption.
+ *Lease TTL > 2 x renew interval, and TTL > worst expected pause.* If TTL is 10 s, renew
  every 3 s. A 4-second GC pause must not cost you leadership --- but a 12-second one must.
]
]
]

#trap[
*Split brain is not prevented by "the other node should have known".* It is prevented by
arithmetic: a leader must be elected by a *majority* ($floor(N\/2) + 1$ nodes), so
two majorities cannot exist at once, and by a fencing token so that even a confused old
leader cannot land a write. With 5 nodes the majority is 3, so a 2-node minority can never
elect anybody. *This is why consensus clusters have an odd number of members.*
]

#practice(tier: 1, time: "30 min")[
+ Extend `ConsistentHashRing` with `removeNode` and measure what fraction of keys move when
  you remove 1 node of 11. Predict the answer before you run it.
+ In `QuorumStore`, add *sloppy quorum*: if a replica is down, write to the next healthy
  node on the ring instead, tagged with the intended owner. Then write `handoff()` to replay
  those writes when the owner returns.
+ Write `resolveCart(a, b)` that takes two carts with version vectors, returns the merged
  cart when they are CONCURRENT, and returns the newer one otherwise. Handle removals with
  tombstones.
+ Convert `HashRouter` to the 1,024-bucket scheme. Then write `split(fromShard, toShard, n)`
  that moves `n` buckets and prints which key ranges moved.
+ In `LeaseService`, add a `now` that you control, and write a test proving that a node whose
  renew is delayed by 11 s with a 10 s TTL loses leadership and is then fenced.
]
#key[
+ Removing 1 of 11 moves about $1\/11 = 9.1%$ of keys --- all of them from the removed node,
  spread over the other 10. Removal is the mirror image of addition.
+ Sloppy quorum trades consistency for write availability: the write is durable but is *not*
  on a node a normal read would ask. You must run handoff, and until you do,
  $W + R > N$ no longer guarantees an overlap. Say that cost out loud; it is the whole point.
+ CONCURRENT $arrow.r$ union of items, sum of quantities, and a removed item stays removed if
  its tombstone version is newer than its add. Not CONCURRENT $arrow.r$ take the newer whole
  cart. Never blend a newer and an older cart field by field.
+ Moving $n$ buckets moves exactly $n\/1024$ of the keys and *no key changes bucket*. That is
  the property you are buying.
+ The renew at $t = 11,000$ must fail because `now >= this.expiresAt` (10,000). The node
  must then stop serving *immediately*, before it even learns who the new leader is. Code
  that keeps serving "until it hears otherwise" is the bug.
]

#section[Tier 2 --- mid-scale: shard a marketplace order database]
#tier-header(2)

#ex(14, tier: 2, asked: "Shopee · pattern")[A marketplace has outgrown a single Postgres
box for orders. Design the sharded order store. Buyers check "my orders" constantly; sellers
need a dashboard; flash sales create 10x spikes.
#sol[

#subsection[Step 1 --- Clarify]

#table(columns: (1fr, 1fr),
  [*Question I ask*], [*Why the answer changes the design*],
  [How many orders per day, and what is the flash-sale peak?],
    [Decides shard count and whether the peak or the average sizes the cluster.],
  [What are the top three queries?],
    [The shard key must make the *most frequent* query a single-shard query.],
  [How long must orders stay online?],
    [Sets total size, which is usually what actually forces sharding.],
  [Do sellers need live dashboards or 5-minute-old ones?],
    [Live means cross-shard fan-out on the hot path. Stale means a separate read model.],
  [Is there a cross-order transaction? (a basket paid as one payment)],
    [If yes, those orders must share a shard, or we need a saga.],
  [Can an order ever change buyer?],
    [If the shard key can change, a row must *move* shards --- a much harder design.],
)

*Answers I will assume, said out loud:* *6 million orders/day*; *peak is 10x average during
a 2-hour flash sale*; *top queries are (a) one order by id, (b) my last 20 orders,
(c) a seller's orders today*; *3 years of orders stay online, older go to cold storage*;
*seller dashboards may lag 60 seconds*; *a basket is one order, so no cross-order
transaction*; *an order's buyer never changes*.

#subsection[Step 2 --- Scale estimate]

*Writes.*
$ 6,000,000 \/ 86,400 = 69.4 "orders/second average" $
$ 69.4 times 10 = 694 "orders/second at flash-sale peak" $
Each order also writes about 3 item rows and 1 payment row, so the true row rate is
$694 times 5 = 3,470$ rows/second at peak.

*Reads.* Buyers poll order status. Assume 20 status reads over an order's life:
$ 6,000,000 times 20 = 120,000,000 "reads/day" $
$ 120,000,000 \/ 86,400 = 1,388.9 approx 1,389 "reads/second average" $
$ 1,389 times 3 = 4,167 "reads/second at peak" $

*Storage.* One order plus its items and payment row: about 1,000 bytes.
$ 6,000,000 times 1,000 = 6,000,000,000 "B" = 6 "GB/day" $
$ 6 times 365 = 2,190 "GB/year" = 2.19 "TB/year" $
$ 2.19 times 3 = 6.57 "TB online" $
At replication factor 3: $6.57 times 3 = 19.71$ TB of replicated data.

*Now the shard count --- and this is the interesting part.*
$ "shards needed for writes" = 3,470 \/ 5,000 = 0.69 arrow.r 1 $
$ "shards needed for reads" = 4,167 \/ 20,000 = 0.21 arrow.r 1 $
$ "shards needed for size" = 6.57 "TB" \/ 0.5 "TB per shard" = 13.1 arrow.r 16 $

#formulas(title: "The one-line summary for the board")[
694 orders/s peak · 4,167 reads/s peak · 6.57 TB online · *16 shards of ~411 GB each*.

*We are not sharding for throughput. One machine could take this load.* We are sharding for
*size and blast radius*. Say that sentence; it is the difference between a candidate who
read a blog and one who has operated a database.
]

#subsection[Why size, not QPS, is the real reason]

$ 6,570 "GB" \/ 16 = 410.6 approx 411 "GB per shard" $

Restore speed from backup is about 200 MB/s.

$ "one 6.57 TB database" : 6,570,000 "MB" \/ 200 = 32,850 "s" = 9.1 "hours" $
$ "one 411 GB shard" : 410,600 "MB" \/ 200 = 2,053 "s" = 34 "minutes" $

Nine hours of downtime versus 34 minutes, and in the sharded case only $1\/16$ of your
buyers are affected while it happens. *That* is the argument for sharding at this scale, and
it is an argument about operations, not about QPS.

#subsection[Step 3 --- API surface]

#code(lang: "text", caption: "five endpoints; note which ones carry the shard key")[
```text
POST /v1/orders
  header Idempotency-Key: 5f1c-...        // retry-safe: no duplicate orders
  body   { buyerId, sellerId, items:[{sku,qty,priceCents}], addressId, promo }
  201    { orderId, state: "CREATED", totalCents }
  note   orderId ENCODES the shard: "16-3f2a9c..." = bucket 16. See step 4.

GET  /v1/orders/{orderId}
  200    { orderId, buyerId, sellerId, state, items[], totalCents, updatedAt }
  note   single shard: the id tells the router where to go. ~2 ms.

GET  /v1/buyers/{buyerId}/orders?limit=20&cursor=<opaque>
  200    { orders:[...], nextCursor }
  note   single shard: buyerId IS the shard key. The query we optimised for.

GET  /v1/sellers/{sellerId}/orders?day=2026-09-15&limit=50&cursor=<opaque>
  200    { orders:[...], nextCursor, asOf: "2026-09-15T10:02:00Z" }
  note   served from the SELLER READ MODEL, not the order shards. May lag 60 s.

POST /v1/orders/{orderId}/transitions
  body   { to: "PAID" | "SHIPPED" | "CANCELLED", reason }
  200    { orderId, state }
  409    { error: "illegal_transition", from: "CANCELLED", to: "SHIPPED" }
```
]

#subsection[Step 4 --- Data model and the shard key]

*The shard key is the whole design.* Four candidates:

#table(columns: (auto, 1fr, 1fr, auto),
  [*Candidate*], [*What it makes fast*], [*What it breaks*], [*Verdict*],
  [`order_id` (random)],
    [even spread; "get one order" is single-shard],
    ["my orders" hits all 16 shards --- 16 calls for the most common screen],
    [no],
  [`created_at` (range)],
    ["all orders today" is one scan],
    [*every* write goes to the newest shard: a permanent 100% hotspot],
    [no],
  [`seller_id`],
    [seller dashboard is single-shard],
    [one flash-sale seller puts most of the day's writes on one shard],
    [no],
  [`buyer_id` (hashed)],
    ["my orders" is single-shard; buyers are many and roughly equal in size],
    [seller queries need a second read path],
    [*yes*],
)

*Decision: hash `buyer_id` into 1,024 buckets; map buckets to 16 shards.* Buyers are the
natural unit of isolation --- there are millions of them, none is 1% of traffic, and the
highest-frequency query is scoped to exactly one.

#code(lang: "text", caption: "the tables, with the keys marked")[
```text
orders
  order_id      char(26)   PK.  Format: <bucket:4><ulid:22>
  -- bucket is stored once and NEVER changes for the life of the row
  bucket        smallint   = hash(buyer_id) % 1024     SHARD KEY INPUT
  buyer_id      bigint     the logical shard key
  seller_id     bigint
  state         enum       CREATED|PAID|SHIPPED|DELIVERED|CANCELLED|REFUNDED
  total_cents   bigint     integers only. Never a float for money.
  created_at    timestamp
  updated_at    timestamp
  version       int        optimistic lock for state transitions
  -- "my last 20 orders", single shard, one scan
  INDEX (buyer_id, created_at DESC)

order_items                                 -- SAME shard as its order
  order_id      char(26)   PK part 1
  line_no       smallint   PK part 2
  sku, qty, price_cents, seller_id

order_events                                -- append-only, SAME shard
  order_id, seq, from_state, to_state, actor, at
```
]

#trick[
*Put the bucket inside the id.* `order_id = "0417" + ulid()` means any service holding an
order id can route to the right shard with a substring, *with no lookup at all*. This one
trick removes an entire directory service from the design. Say it; interviewers love it
because it is cheap and obviously correct.
]

*The seller read model* is a separate store, written by a stream job:
#code(lang: "text", caption: "a second copy of the data, shaped for the other query")[
```text
seller_orders            (sharded by seller_id, in its own cluster)
  seller_id     bigint     SHARD KEY
  day           date       SORT KEY part 1
  order_id      char(26)   SORT KEY part 2
  state, total_cents, buyer_masked, updated_at
  -- one row per order, written by a consumer of the order_events stream
```
]

This is denormalisation on purpose. The same order exists twice, in two shapes, on two shard
keys. That is the standard answer to "a sharded system cannot serve two different access
patterns from one table" --- *it cannot, so you keep two tables.*

#subsection[Step 5 --- Architecture]

#diagram(height: 6.6cm, caption: "Write path across the top. The seller read model is fed asynchronously, so it never slows an order down.")[
  #dnode(0pt, 54pt, 56pt, 28pt, "Client")
  #dnode(72pt, 54pt, 60pt, 28pt, "API +\nrate limit")
  #dnode(148pt, 54pt, 66pt, 28pt, "Order\nservice")
  #dnode(148pt, 4pt, 66pt, 26pt, "Bucket map\n(1024 -> 16)", fill: rgb("#f0ece2"))

  #dnode(240pt, 2pt, 58pt, 24pt, "shard 0")
  #dnode(240pt, 30pt, 58pt, 24pt, "shard 1")
  #dnode(240pt, 58pt, 58pt, 24pt, "...")
  #dnode(240pt, 86pt, 58pt, 24pt, "shard 15")
  #place(dx: 306pt, dy: 6pt)[#text(size: 7.5pt, fill: muted)[each shard: 1 leader]]
  #place(dx: 306pt, dy: 16pt)[#text(size: 7.5pt, fill: muted)[and 2 followers, in 3 zones]]

  #dnode(148pt, 108pt, 66pt, 26pt, "Outbox +\nCDC", fill: rgb("#f0ece2"))
  #dnode(240pt, 140pt, 58pt, 26pt, "Kafka\norder_events")
  #dnode(330pt, 140pt, 62pt, 26pt, "Projector")
  #dnode(412pt, 140pt, 62pt, 26pt, "Seller store\n(by seller_id)")
  #dnode(412pt, 54pt, 62pt, 28pt, "Redis\norder cache", fill: rgb("#f0ece2"))

  #darrow(56pt, 68pt, 72pt, 68pt)
  #darrow(132pt, 68pt, 148pt, 68pt)
  #darrow(181pt, 54pt, 181pt, 30pt, label: "route")
  #darrow(214pt, 62pt, 240pt, 40pt, label: "write")
  #darrow(214pt, 74pt, 240pt, 92pt)
  #darrow(181pt, 82pt, 181pt, 108pt)
  #darrow(214pt, 121pt, 240pt, 145pt)
  #darrow(298pt, 153pt, 330pt, 153pt)
  #darrow(392pt, 153pt, 412pt, 153pt)
  #darrow(298pt, 70pt, 412pt, 68pt, label: "fill", dashed: true)
  #place(dx: 0pt, dy: 172pt)[#text(size: 8pt, fill: muted)[Solid = on the order's critical path. Dashed = asynchronous, so a slow projector never slows a checkout.]]
]

*Trace one order creation:*
+ `POST /v1/orders` arrives with an `Idempotency-Key`.
+ The order service computes `bucket = hash(buyerId) % 1024`, looks up
  `bucketMap[bucket] = shard 7`, and opens a transaction on shard 7's leader.
+ Inside *one* transaction on *one* shard it writes: the `orders` row, the `order_items`
  rows, the first `order_events` row, and an `outbox` row. All four are on the same shard
  because they all key off the same `buyer_id`. This is a plain local ACID transaction ---
  no two-phase commit anywhere.
+ Commit. Return `201` with the order id. Total: about 4 ms.
+ Separately, a CDC reader tails the outbox and publishes to Kafka. The projector builds the
  seller read model. If that pipeline is 60 seconds behind, no buyer notices.

*Trace one "my orders":* the buyer id gives the bucket gives the shard. One query,
`WHERE buyer_id = ? ORDER BY created_at DESC LIMIT 20`, served by an index on one shard, from
a *follower*, in about 2 ms.

#subsection[Step 6a --- Deep dive: the cross-shard query you cannot avoid]

Some queries genuinely need every shard: "find the order with this payment reference",
support tools, fraud sweeps. Scatter-gather is the only answer. Understand its cost.

#formulas(title: "Why scatter-gather is slower than any single shard")[
You wait for the *slowest* of 16 answers, not the average.

If each shard independently answers within 20 ms with probability 0.99, then
$ P("all 16 within 20 ms") = 0.99^16 = 0.851 $
So $1 - 0.851 = 14.9%$ of scatter-gather requests are slower than 20 ms, even though only
1% of single-shard requests are.

With 64 shards it gets worse:
$ 0.99^64 = 0.526 $
Nearly *half* of all requests hit at least one slow shard.
]

*What we do about it:*
+ *Do not do it on the hot path.* Buyer and seller screens are single-shard by design. The
  fan-out is for support and batch tools only.
+ *Give it a hedge.* If a shard has not answered in 15 ms, send the same query to that
  shard's follower too and take whichever returns first. This cuts the tail hard and costs
  about 5% extra read load.
+ *Give it a secondary index table.* Payment reference $arrow.r$ order id, stored in its own
  small table sharded by payment reference. Then "find by payment ref" becomes *two*
  single-shard lookups instead of 16 parallel ones.

*Decision: build the payment-reference index table.* Two lookups at 2 ms each beats a 16-way
fan-out with a 15% slow tail, and the index is 26 bytes per order --- $6,000,000 times
26 = 156$ MB/day, $156 times 365 \/ 1000 = 56.9$ GB/year. Cheap.

#subsection[Step 6b --- Deep dive: growing from 16 shards to 32 with no downtime]

Because keys hash to *buckets* and buckets map to shards, no key is ever rehashed. We move
whole buckets.

#diagram(height: 4.9cm, caption: "Split shard 7. Move 32 of its 64 buckets to the new shard 16. Keys never change bucket, so nothing is rehashed.")[
  #dnode(0pt, 8pt, 96pt, 30pt, "hash(buyer_id)\n% 1024 = bucket")
  #dnode(118pt, 8pt, 96pt, 30pt, "bucketMap[]\n1024 entries")
  #dnode(240pt, 0pt, 74pt, 22pt, "shard 7\nbuckets 448-511", fill: rgb("#f2e6d6"))
  #dnode(240pt, 30pt, 74pt, 22pt, "shard 16 (new)", fill: rgb("#dbe7c9"))

  #darrow(96pt, 23pt, 118pt, 23pt)
  #darrow(214pt, 18pt, 240pt, 11pt)
  #darrow(214pt, 28pt, 240pt, 41pt, dashed: true)

  #place(dx: 0pt, dy: 52pt)[#text(size: 8.5pt, weight: "bold")[The four phases, in order:]]
  #dnode(0pt, 68pt, 108pt, 34pt, "1 COPY\nsnapshot buckets\n480-511 to shard 16")
  #dnode(116pt, 68pt, 108pt, 34pt, "2 CATCH UP\nreplay the change log\nuntil lag < 1 s")
  #dnode(232pt, 68pt, 108pt, 34pt, "3 DUAL WRITE\nwrite both, read old,\ncompare in the dark")
  #dnode(348pt, 68pt, 108pt, 34pt, "4 FLIP\nupdate bucketMap,\nthen stop dual write")

  #darrow(108pt, 85pt, 116pt, 85pt)
  #darrow(224pt, 85pt, 232pt, 85pt)
  #darrow(340pt, 85pt, 348pt, 85pt)

  #place(dx: 0pt, dy: 112pt)[#text(size: 8pt, fill: muted)[Rollback is available at every phase up to the flip: the old shard still holds a complete, current copy.]]
  #place(dx: 0pt, dy: 124pt)[#text(size: 8pt, fill: muted)[After the flip, keep the old copy read-only for 24 hours before deleting it. Deletion is the only irreversible step.]]
]

*The numbers.* Moving 32 of 1,024 buckets is $32 \/ 1024 = 3.1%$ of the data:
$ 6,570 "GB" times 0.031 = 203.7 "GB to copy" $
At 200 MB/s that is $203,700 \/ 200 = 1,018$ s $approx 17$ minutes of copying, done in
the background while the system serves traffic normally.

#trap[
*The flip must be atomic across every process that routes.* If pod A thinks bucket 500 is on
shard 7 and pod B thinks it is on shard 16, two buyers' orders land in two places and your
"my orders" screen loses rows. Publish the bucket map with a *version number*, have every
router refuse to serve with a stale version, and flip by bumping the version in one place
(a config store with a watch). Dual-writing during phase 3 is exactly what makes a
non-atomic flip survivable.
]

#subsection[Step 6c --- Deep dive: the flash sale, and where the hotspot really is]

A seller starts a flash sale. 60% of the peak write load --- $694 times 0.6 = 416$
orders/second --- is for that one seller's products.

*Does that create a hot shard?* No. We shard by `buyer_id`, and those 416 orders/s come from
416 *different buyers* spread over 1,024 buckets. Each shard sees about
$416 \/ 16 = 26$ extra orders/second. Nothing notices.

*So where is the pain?* On the *stock counter* for one SKU. That is a single row that every
one of those 416 buyers wants to decrement, and it lives in exactly one place. 416
transactions per second all locking the same row means they serialise: if the lock is held
for 2 ms, the maximum possible rate on that row is $1 \/ 0.002 = 500$/s. We are at 416. One
slow disk flush and we are over.

#formulas(title: "Three fixes for a single hot row, with costs")[
+ *Split the counter.* Replace `stock = 1000` with 20 rows of `stock_shard(sku, i, qty=50)`.
  A buyer picks `i = random(0..19)` and decrements that row. Capacity becomes
  $20 times 500 = 10,000$/s. *Cost:* "how many left?" is now a sum over 20 rows, and near
  the end some sub-counters are empty while others are not, so you must retry on a different
  `i` before declaring sold out.
+ *Reserve in Redis, settle in the database.* Decrement an in-memory counter (100,000 ops/s),
  and write the durable row asynchronously. *Cost:* if Redis dies you may oversell by the
  size of the in-flight window. Acceptable for T-shirts, not for concert seats.
+ *Queue the sale.* All flash-sale orders go into a single-partition queue keyed by SKU and
  are processed in order at whatever rate the row allows. *Cost:* buyers wait, and you must
  show them an honest "you are number 812 in the queue" screen.

*Decision: fix 1 (split the counter into 20) as the default, plus fix 3 for sales of fewer
than 100 units.* Splitting is simple and gives 24x headroom. When the item count is tiny the
sub-counter arithmetic gets fiddly and fairness matters more than throughput, so the queue
wins there.
]

#subsection[Step 7 --- Trade-offs, failure modes, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Shard key], [`order_id`, perfect spread], [`buyer_id`, hashed],
    [*B* --- the top query becomes single-shard],
  [Routing], [hash directly to 16 shards], [hash to 1,024 buckets, map to shards],
    [*B* --- resharding stops being a rewrite],
  [Seller queries], [scatter-gather over 16 shards], [a second store sharded by `seller_id`],
    [*B* --- 60 s of lag is cheaper than a 15% slow tail],
  [Shard count], [4 big shards], [16 medium shards],
    [*B* --- 34-minute restore beats 9 hours; blast radius is $1\/16$],
  [Replication], [async only], [semi-sync: wait for 1 of 2 followers],
    [*B* --- bounded data loss on failover for ~1 ms of extra write latency],
  [Cross-shard order], [two-phase commit], [one shard per order + saga if ever needed],
    [*B* --- 2PC blocks when the coordinator dies; we designed the need away],
  [ID format], [random UUID], [bucket prefix + ULID],
    [*B* --- routing with no lookup, and ULIDs sort by time],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [One shard's leader dies],
    [$1\/16$ of buyers get errors for ~20 s],
    [Semi-sync means a follower has every committed write. Promote it, bump the fencing
     token, repoint the bucket map. Lost data: none committed.],
  [A follower lags 5 minutes],
    [Some buyers see an old order state],
    [Health check on *lag seconds*, not CPU. Pull a lagging follower out of the read pool
     automatically at 10 s.],
  [The projector stops],
    [Seller dashboards freeze at a timestamp],
    [The `asOf` field in the API means the UI can *say* "as of 10:02". Kafka retains the
     events, so the projector catches up with no data loss.],
  [Bucket map flip is half-applied],
    [Some orders written to the wrong shard],
    [Routers refuse to serve on a stale map version. Dual-write during migration means the
     old shard still has everything, so recovery is a re-copy, not a data-loss event.],
  [Flash sale on one SKU],
    [Checkout slows for that item only],
    [Split counter (20 sub-rows) gives 10,000/s of headroom against 416/s of demand.],
  [Whole availability zone dies],
    [Nothing, if replicas are placed correctly],
    [Each shard's 3 replicas live in 3 different zones. A zone loss costs every shard one
     replica and no shard its quorum.],
)

*At 10x (60 million orders/day):*
- Writes become $60,000,000 \/ 86,400 = 694$/s average, $6,944$/s at flash peak, and
  $6,944 times 5 = 34,720$ rows/second. Now throughput *does* matter:
  $34,720 \/ 5,000 = 6.9 arrow.r 7$ shards minimum on write capacity alone.
- Storage becomes $21.9$ TB/year and $65.7$ TB over 3 years.
  $65,700 \/ 411 = 160$ shards at the same shard size. Round to *128 or 256* (powers of
  two keep bucket splits clean), with 1,024 buckets still the routing unit --- at 256 shards
  that is only 4 buckets per shard, so *raise the bucket count to 8,192 before you get
  there*. Bucket count is the one number that is genuinely painful to change later, so
  over-provision it on day one: 8,192 buckets cost nothing today.
- The genuinely new problem at 10x is *archival*. 65.7 TB is mostly orders nobody will ever
  read again. Move anything older than 90 days and in a terminal state to cold object
  storage, keyed by order id, and leave a 40-byte stub row behind. If 85% of rows qualify,
  the online set drops to $65.7 times 0.15 = 9.9$ TB, and the shard count drops back to
  $9,900 \/ 411 = 24$. *One archival policy saved you 130 shards.* That is a better answer
  than any amount of clever sharding.
]
]

#ex(15, tier: 2, asked: "Grab · pattern")[Your shard key is `buyer_id`. Product now wants
"show me every order from my *household*", where a household is up to 6 buyer accounts that
can be linked and unlinked at any time. What breaks and what do you do?
#sol[
*What breaks.* Six buyer ids hash to six buckets, which can sit on up to six different
shards. "Household orders" becomes a 6-way scatter-gather with a merge and a re-sort, on
what the product team thinks is a normal screen.

*Option A --- fan out at read time.* Query up to 6 shards in parallel, merge by
`created_at`, paginate in the application. Works immediately, no data moves.
*Cost:* the tail. With per-shard 99th percentile at 20 ms,
$P("all 6 fast") = 0.99^6 = 0.941$, so 5.9% of these requests are slow. And cursor
pagination across a merge is genuinely fiddly --- the cursor must carry a position *per
shard*.

*Option B --- shard by `household_id` instead.* Every household is one shard, one query.
*Cost:* households are created and *changed* after the fact. Linking two accounts would mean
physically moving one person's entire order history between shards. A shard key that can
change is the one thing you must never choose.

*Option C --- a household read model.* Same trick as the seller dashboard: a projector
consumes order events and writes `household_orders`, sharded by `household_id`. Linking a
new member triggers a backfill job for that one household.
*Cost:* one more store, 60 s of lag, and a backfill on link.

*Decision: C, with A as the fallback for the first 90 days.* Ship A because it needs no new
infrastructure and households are rare enough that 5.9% slow requests on a rarely-used screen
is survivable. Build C once usage proves the screen matters. *Never B* --- the moment a shard
key can change, every design gets ten times harder, and "unlink" would leave orphaned rows on
the wrong shard forever.
]
]

#practice(tier: 2, time: "35 min")[
+ Redo the shard-count arithmetic for 20 million orders/day, 5 years online, 1.4 KB per
  order, and a target shard size of 600 GB. Show every division.
+ You must add "search orders by phone number" for support staff. Compare a 16-way
  scatter-gather against a `phone -> order_id` index table: latency, storage, and write cost.
  Decide.
+ Your bucket count is 1,024 and you now need 300 shards. Explain exactly what goes wrong and
  what the migration to 8,192 buckets looks like.
+ Semi-sync replication waits for 1 of 2 followers. Compute the write latency if the local
  follower is 0.5 ms away and the remote one is 60 ms away, and say how much data a failover
  can lose.
+ Design the dual-write verification for step 3 of the resharding plan: what do you compare,
  how often, and what do you do on a mismatch?
]
#key[
+ $20,000,000 times 1,400 = 28,000,000,000$ B $= 28$ GB/day;
  $times 365 = 10,220$ GB $= 10.22$ TB/year; $times 5 = 51.1$ TB;
  $51,100 \/ 600 = 85.2 arrow.r$ *128 shards* (round up to a power of two).
  Writes: $20,000,000 \/ 86,400 = 231.5$/s average, $2,315$/s at 10x peak,
  $times 5$ rows $= 11,575$ rows/s, needing only $11,575 \/ 5,000 = 2.3 arrow.r 3$
  shards. Size wins again, by 40x.
+ Index table: 2 lookups $times 2$ ms $= 4$ ms, ~30 B per order, and one extra write per
  order. Scatter-gather: 16 parallel queries, $0.99^16 = 0.851$ so 14.9% are slow, no extra
  storage, no extra writes. *Decision: index table.* Support tools are used by humans who
  wait, but a 15% slow rate on a tool used 500 times a day is 75 slow lookups a day and the
  storage cost is $20,000,000 times 30 = 600$ MB/day. Cheap enough.
+ 1,024 buckets over 300 shards is 3.4 buckets per shard, so the *smallest unit you can move
  is 0.33% of the data* and shard sizes cannot be balanced to better than $plus.minus 15%$.
  Migration: add a second level --- `bucket8k = hash(key) % 8192`, and
  `bucket1k = bucket8k % 1024`, so every old bucket splits into exactly 8 new ones with no
  key changing shard. Deploy the new map, verify it is identical in effect, then start moving
  the finer buckets.
+ Semi-sync waits for the *first* ack, which is the local follower at 0.5 ms. Write latency
  $approx 2 + 0.5 = 2.5$ ms. A failover to the *local* follower loses nothing. A failover to
  the *remote* one, which may be 60 ms behind, loses up to $60 "ms" times 3,470$ rows/s
  $= 208$ rows. Mitigation: only ever promote a follower whose lag is under 100 ms, and if
  none qualifies, stay down and wait rather than silently losing 208 orders.
+ Compare row counts per bucket every 60 s, and a checksum of `(order_id, updated_at,
  version)` for a random 1% sample every 5 minutes. On mismatch: stop the flip, do not roll
  back writes (the old shard is still authoritative), log the differing ids, re-copy just
  those buckets. Alarm if mismatches exceed 0 --- for this comparison the only acceptable
  number is zero.
]

#section[Tier 3 --- large scale: a four-region profile store]
#tier-header(3)

#ex(16, tier: 3, asked: "Google · pattern")[800 million users. Every service call reads the
user's profile and settings. Users travel. Design a store replicated across Singapore,
Mumbai, Frankfurt and Virginia. Decide where it sits on CAP, and defend it.
#sol[

#subsection[Step 1 --- Clarify]

#table(columns: (1fr, 1fr),
  [*Question I ask*], [*Why it changes the design*],
  [What exactly is in a "profile"?],
    [Display data is AP-safe. A *username* is a global uniqueness claim and is not.],
  [Read-to-write ratio?],
    [If it is 80:1, this is a read-path problem and the write path can be slow.],
  [Do users move between regions often?],
    [Rarely $arrow.r$ pin a home region. Often $arrow.r$ every region must serve everybody.],
  [How stale may a read be, in seconds?],
    [Sets whether local reads are allowed at all.],
  [What happens if two regions write the same field at once?],
    [Decides last-write-wins versus a merge function versus a single leader.],
  [Is there any field that must be globally unique?],
    [If yes, that one field needs consensus and the rest do not.],
)

*Answers assumed:* profile = display name, avatar URL, language, 40-ish settings, plus
*username* (globally unique) and *email* (globally unique). 200 million DAU, 40 profile reads
per active user per day, 0.5 writes. *5 seconds of staleness is acceptable for display
fields.* *Username and email must never be issued twice.* A user's home region rarely
changes.

#subsection[Step 2 --- Scale estimate]

*Reads.*
$ 200,000,000 times 40 = 8,000,000,000 "reads/day" $
$ 8,000,000,000 \/ 86,400 = 92,592.6 approx 92,593 "reads/second average" $
$ 92,593 times 3 = 277,779 "reads/second at peak" $

*Writes.*
$ 200,000,000 times 0.5 = 100,000,000 "writes/day" $
$ 100,000,000 \/ 86,400 = 1,157.4 approx 1,157 "writes/second average" $
$ 1,157 times 3 = 3,471 "writes/second at peak" $

Read-to-write ratio: $92,593 \/ 1,157 = 80.0$. *Eighty to one.* This is a read-path
design and we should spend our whole latency budget there.

*Storage.* 2 KB per user.
$ 800,000,000 times 2,048 = 1,638,400,000,000 "B" = 1.64 "TB logical" $
Three replicas per region, four regions:
$ 1.64 times 3 times 4 = 19.7 "TB of raw replicated data" $
That is small. *The problem here is not size. It is latency and coordination.*

*Nodes for reads.* At 20,000 reads/s/node, per region at peak:
$ 277,779 \/ 20,000 = 13.9 arrow.r 16 "nodes per region for the store" $
But most reads should never reach the store at all --- see the cache arithmetic in step 6.

*Shards.* $1.64 "TB" \/ 0.5 "TB per shard" = 3.3 arrow.r$ 4 shards is enough for *size*,
but $277,779 \/ 20,000 = 13.9$ shards is what *throughput* needs. Take 16.

#formulas(title: "The board summary")[
92,593 reads/s average · 277,779 at peak · 1,157 writes/s · 80:1 read-heavy ·
1.64 TB logical · 16 shards x 3 replicas x 4 regions.

*Small data, enormous read rate, four regions.* Therefore the design is about *where a read
is allowed to be answered*, and nothing else.
]

#subsection[Step 3 --- API surface]

#code(lang: "text", caption: "note the consistency parameter — this is the interesting field")[
```text
GET  /v1/profiles/{userId}?consistency=local|quorum
  200  { userId, displayName, avatarUrl, lang, settings{}, version, asOf }
  note local  = read from this region's replicas.  ~2 ms.  may be ~1 s stale
       quorum = read a majority across regions.    ~120 ms. never stale
       DEFAULT is local. The caller opts in to the slow, correct one.

PATCH /v1/profiles/{userId}
  body   { displayName?, avatarUrl?, lang?, settings? , ifVersion: 8124 }
  200    { version: 8125, asOf }
  409    { error: "version_conflict", current: {...} }
  note   returns the FULL new profile: the client needs no read-after-write

POST /v1/usernames
  body   { userId, username }
  201    { username, userId }
  409    { error: "taken" }
  note   this endpoint is LINEARIZABLE and costs ~200 ms. It is rare, so fine.

GET  /v1/usernames/{username}
  // served from a local cache; a stale hit is harmless here
  200    { userId }
  404
```
]

#trick[
*Putting `consistency` in the API is a senior move.* It says out loud that consistency is a
per-call decision with a price, not a global setting. Then give the default: `local`, because
80 of every 81 calls are reads of display data where one second of staleness is invisible.
]

#subsection[Step 4 --- Data model, split by CAP requirement]

#code(lang: "text", caption: "two stores, because two kinds of data")[
```text
-- STORE 1: profiles. AP. Leaderless, quorum-tunable, in all 4 regions.
profiles
  user_id        bigint     PARTITION KEY (hashed)
  display_name   text
  avatar_url     text
  lang           text
  settings       map<text,text>
  -- version vector: {"sg":12,"in":3,"de":0,"us":7}
  vv             map<text,int>
  -- for humans and debugging, NOT for conflict resolution
  updated_at     timestamp
  home_region    text             -- where this user usually is

-- STORE 2: unique claims. CP. One consensus group per shard, majority writes.
username_claims
  username       text       PRIMARY KEY (lowercased, normalised)
  user_id        bigint
  claimed_at     timestamp
-- written ONLY with compare-and-set: "insert if absent". Never LWW.


email_claims                 -- same shape, same rules
```
]

#formulas(title: "The split is the answer to the CAP question")[
- *Profiles: AP.* During a partition, Frankfurt keeps serving and keeps accepting writes. A
  German user sees her own change instantly; a Singapore reader may be a few seconds behind.
  Conflicts are resolved per field by version vector, with LWW on scalars and union on the
  settings map.
- *Username claims: CP.* During a partition, a minority region *cannot* issue a username. It
  returns `503 try_again`. We would rather a user wait 30 seconds than discover that two
  people own `@asha`.

Same product. Same request, almost. *Different answers, because the cost of being wrong is
different.* This is the whole content of CAP as an interview topic.
]

#subsection[Step 5 --- Architecture]

#diagram(height: 6.8cm, caption: "Reads stay inside a region. Profile writes replicate asynchronously. Only a username claim leaves the region synchronously.")[
  #dnode(0pt, 30pt, 58pt, 26pt, "SG client")
  #dnode(70pt, 30pt, 62pt, 26pt, "SG edge\n+ cache", fill: rgb("#f0ece2"))
  #dnode(144pt, 30pt, 62pt, 26pt, "SG profile\nservice")
  #dnode(218pt, 30pt, 66pt, 26pt, "SG store\n16xRF3 · 2 ms")

  #dnode(0pt, 112pt, 58pt, 26pt, "IN client")
  #dnode(70pt, 112pt, 62pt, 26pt, "IN edge\n+ cache", fill: rgb("#f0ece2"))
  #dnode(144pt, 112pt, 62pt, 26pt, "IN profile\nservice")
  #dnode(218pt, 112pt, 66pt, 26pt, "IN store\n16xRF3 · 2 ms")

  #dnode(218pt, 0pt, 66pt, 22pt, "DE store", fill: rgb("#f7f7f5"))
  #dnode(218pt, 146pt, 66pt, 22pt, "US store", fill: rgb("#f7f7f5"))

  #dnode(330pt, 56pt, 104pt, 46pt, "Username\nconsensus group\n(majority of 5)", fill: rgb("#f2e6d6"))

  #darrow(58pt, 43pt, 70pt, 43pt)
  #darrow(132pt, 43pt, 144pt, 43pt)
  #darrow(206pt, 43pt, 218pt, 43pt)
  #darrow(58pt, 125pt, 70pt, 125pt)
  #darrow(132pt, 125pt, 144pt, 125pt)
  #darrow(206pt, 125pt, 218pt, 125pt)

  #darrow(251pt, 30pt, 251pt, 22pt, dashed: true)
  #darrow(251pt, 56pt, 251pt, 112pt, dashed: true, label: "60 ms")
  #darrow(251pt, 138pt, 251pt, 146pt, dashed: true)

  #darrow(284pt, 40pt, 330pt, 68pt)
  #darrow(284pt, 118pt, 330pt, 92pt)
  #place(dx: 295pt, dy: 40pt)[#text(size: 7.5pt, fill: dc)[claim]]
  #place(dx: 295pt, dy: 108pt)[#text(size: 7.5pt, fill: dc)[claim]]
  #place(dx: 330pt, dy: 106pt)[#text(size: 7.5pt, fill: muted)[~200 ms, and rare]]

  #place(dx: 0pt, dy: 174pt)[#text(size: 8pt, fill: muted)[Solid = synchronous, on the user's critical path. Dashed = asynchronous replication between regions.]]
  #place(dx: 0pt, dy: 184pt)[#text(size: 8pt, fill: muted)[A read never crosses an ocean. A username claim always does. 80 of every 81 calls take the fast path.]]
]

#subsection[Step 6a --- Deep dive: making 277,779 reads/second cheap]

The store at 16 nodes per region can serve $16 times 20,000 = 320,000$ reads/s, which
covers peak --- but only just, and only if the load is perfectly even. Put a cache in front
and the arithmetic stops being scary.

*Cache sizing.* Assume in any 10-minute window, 30 million distinct users are active in a
region.
$ 30,000,000 times 2,048 "B" = 61,440,000,000 "B" = 61.4 "GB" $
Split over 8 Redis nodes: $61.4 \/ 8 = 7.7$ GB each. Comfortable.

*Hit rate and what reaches the store.* At a 95% hit rate:
$ 277,779 times 0.05 = 13,889 "reads/second reach the store" $
$ 13,889 \/ 20,000 = 0.69 arrow.r 1 "node's worth of work" $
We keep 16 nodes for *storage* and *failure tolerance*, not for read throughput. Now a bad
day --- a cache node loss, say --- has 16x headroom instead of 1.15x.

*The cold-cache case, which is the one that actually breaks systems.* If the whole cache
tier restarts, all 277,779 reads/s hit a store sized to comfortably do 320,000. It survives,
but with no margin. Two defences, both cheap:
+ *Request coalescing.* 4,000 simultaneous requests for the same missing key become *one*
  store read; the rest wait on the same in-flight promise.
+ *Staggered restart.* Never restart more than 2 of 8 cache nodes at once, and warm each one
  from the most-read-1-million list before putting it in rotation:
  $1,000,000 times 2,048 = 2.05$ GB, which loads in well under a minute.

#subsection[Step 6b --- Deep dive: read-your-writes across 60 ms of ocean]

A user in Mumbai changes her display name. Replication to Singapore takes ~60 ms, sometimes
2 s. She reloads. What does she see?

#table(columns: (auto, 1fr, 1fr, auto),
  [*Approach*], [*How*], [*Cost*], [*Verdict*],
  [Return the new value],
    [`PATCH` responds with the complete new profile],
    [nothing],
    [*always do this*],
  [Sticky region],
    [her session pins to her home region for all reads and writes],
    [a user who travels gets 200 ms reads until the pin moves],
    [*yes*, with a 24 h pin],
  [Version token],
    [the write returns `version: 8125`; reads send `minVersion: 8125`; a behind replica
     forwards to the leader],
    [one header everywhere, plus a forward path],
    [*yes*, for the 3 screens that matter],
  [Quorum read always],
    [every read waits for a majority across regions],
    [$92,593$ reads/s $times 120$ ms of extra latency, and a 4x cost increase],
    [*no*],
)

*Decision: all three of the first three, in that order.* They are cumulative and cheap. The
fourth costs 120 ms on 8 billion daily reads to fix a problem that affects the 100 million
daily *writers* for about one second each. That is a 60:1 bad trade and you should say the
ratio out loud.

#subsection[Step 6c --- Deep dive: why last-write-wins on wall clocks loses data]

Two servers write the same field. LWW keeps the one with the larger timestamp.

#formulas(title: "The failure, in numbers")[
Singapore's clock reads 10:00:00.100. Mumbai's clock reads 10:00:00.060 --- it is 40 ms
behind, which is *normal* for NTP-synchronised machines and can be far worse.

+ At true time $T$, Singapore writes `lang = en`, stamped 10:00:00.100.
+ At true time $T + 20$ ms --- genuinely *later* --- Mumbai writes `lang = hi`, stamped
  10:00:00.080.
+ LWW compares 100 versus 80 and keeps `en`.

*The newer write was silently deleted.* No error, no log line, no conflict. The user set her
language to Hindi and the system quietly set it back.
]

*What we do instead:*
+ *Per-field version vectors.* Only fields that were *actually* written concurrently are
  conflicts. Two regions editing two different settings is not a conflict at all, and
  field-level vectors make that free.
+ *For the settings map, merge by union with per-key vectors.* Losing a setting is worse than
  keeping a stale one.
+ *For true scalars where a merge makes no sense (display name), LWW is acceptable*, but use
  a *logical* timestamp (the version vector's own counters plus a region tiebreak), never the
  wall clock.
+ *For anything where a lost write costs money or identity, do not resolve at all --- prevent
  it.* That data belongs in store 2 with consensus.

#trap[
"We will just use NTP and keep clocks within 10 ms" is not a fix, it is a hope. NTP fails
silently, virtual machines get paused and resume with a jumped clock, and leap seconds
exist. Systems that *do* use clocks for ordering (Google's TrueTime is the famous one) do not
trust a timestamp --- they carry an explicit *uncertainty interval* and deliberately *wait*
until the interval has passed before committing. Waiting on purpose is the price of trusting
a clock. Say that; it shows you know why the naive version fails.
]

#subsection[Step 6d --- Deep dive: the username claim, which is the only CP thing here]

A username claim must be linearizable: if `@asha` is issued once, it is never issued again,
even during a partition, even if two regions get the request in the same millisecond.

#formulas(title: "The claim path, step by step")[
+ The username is *normalised* first: lowercase, strip zero-width characters, map confusable
  characters (`rn` looks like `m`, Cyrillic `а` looks like Latin `a`). Normalise *before*
  hashing, or two different byte strings claim "the same" name.
+ Hash the normalised name to one of 16 consensus groups. Each group is 5 nodes spread over
  the 4 regions (2 + 1 + 1 + 1).
+ The claim is a *compare-and-set*: "create this key only if absent". The group's leader
  proposes it; a majority of 3 of 5 must accept.
+ Latency: the leader must hear from 2 more nodes. The second-nearest is typically
  60--180 ms away, so a claim costs roughly *200 ms*.
+ Availability: a region cut off from the others holds at most 2 of 5 nodes, cannot reach 3,
  and therefore *cannot issue a username*. It returns `503`. That is the CP choice, working
  exactly as designed.
]

*Is 200 ms acceptable?* A user claims a username once, at sign-up, on a screen where they
are already typing. 200 ms is invisible there. Compare with profile reads: 8 billion a day,
where 200 ms would be catastrophic. *Same system, two answers, and the reason is the request
rate and the cost of being wrong.*

#subsection[Step 7 --- Trade-offs, failure modes, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Profile CAP side], [CP: quorum across regions],
    [AP: local quorum, async cross-region],
    [*B* --- 80:1 reads; 1 s of staleness on a display name harms nobody],
  [Username CAP side], [AP with conflict resolution], [CP with consensus],
    [*A* is not even coherent --- two owners of one name cannot be merged. *B*],
  [Conflict resolution], [wall-clock LWW], [per-field version vectors],
    [*B* --- clock skew silently deletes newer writes],
  [Read default], [quorum, always correct], [local, opt-in quorum],
    [*B* --- and *put the knob in the API* so callers choose per call],
  [Cache], [none, the store is fast], [8-node regional cache at 95% hit],
    [*B* --- it turns 1.15x headroom into 16x for a few GB of RAM],
  [Settings merge], [replace the whole map], [union with per-key vectors],
    [*B* --- replacing a map loses a setting the other region just added],
  [Region routing], [nearest region by latency], [home region, re-pinned after 24 h],
    [*B* --- stable routing gives free read-your-writes for 99% of users],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [One region is cut off],
    [Profiles: fully working, slightly stale. Usernames: `503` in that region.],
    [This is the design working. Announce it, do not "fix" it --- the alternative is
     duplicate usernames.],
  [Cross-region link is slow (60 ms $arrow.r$ 900 ms)],
    [Nothing, for reads. Cross-region convergence takes ~1 s instead of 60 ms.],
    [Alarm on replication lag in seconds. Async replication absorbs this completely;
     it is exactly why we chose it.],
  [Clocks skew by 5 minutes],
    [Nothing],
    [Because we resolve with version vectors, not clocks. If we had used LWW, five minutes
     of one region's writes would vanish.],
  [A consensus group loses its leader],
    [Username claims pause for ~5 s in every region],
    [Election takes one or two election timeouts. Keep the timeout at 1--2 s, and the
     fencing token stops the old leader's late writes.],
  [Cache tier restarts],
    [p99 read goes from 3 ms to 15 ms for ~60 s],
    [Coalescing plus staggered warm restart. The store has 16x headroom because we sized
     it for storage.],
  [A "hot" celebrity profile],
    [Nothing],
    [It is one cache key in every region --- the best case. Add a 5-second in-process
     cache on the service if a single Redis key exceeds ~50,000 ops/s.],
  [Two regions rename the same user at once],
    [One name wins for display; nothing is lost in settings],
    [Version vectors mark it CONCURRENT; scalars take the region-tiebreak winner, the
     settings map takes the union.],
)

*At 10x (2 billion DAU-equivalent reads $times$ 10 = 80 billion reads/day):*
- $80,000,000,000 \/ 86,400 = 925,926$ reads/s average, $2,777,778$ at peak.
- No cache tier answers 2.8 million requests/s cheaply from 8 nodes. The fix is not a bigger
  cache; it is *moving the read closer*: an in-process LRU inside every profile-service pod,
  holding the 100,000 hottest users. At a 60% in-process hit rate, the Redis tier sees
  $2,777,778 times 0.4 = 1,111,111$/s, and at Redis's 95% hit rate the store sees
  $1,111,111 times 0.05 = 55,556$/s, which is $55,556 \/ 20,000 = 2.8 arrow.r 3$
  nodes of real work. *Three cache layers, each removing an order of magnitude.*
- The new hard problem is *invalidation*. With an in-process cache in 3,000 pods, a profile
  edit must reach 3,000 processes. Broadcasting every edit is $3,471 times 3,000 =
  10,413,000$ messages/second at peak, which is absurd. *Decision: do not invalidate ---
  expire.* A 5-second TTL on the in-process layer bounds staleness to 5 seconds with zero
  messages, and we already agreed that 5 seconds is acceptable for display fields. The three
  screens that need better use the version-token path from step 6b and skip the in-process
  layer entirely.
- Storage is still tiny (16.4 TB logical at 10x users). *Say that out loud* --- it stops the
  interviewer from expecting a storage answer and keeps the conversation on latency, which
  is where the real design is.
]
]

#ex(17, tier: 3, asked: "Amazon · pattern")[Your AP profile store is asked to also hold a
per-user *credit balance* that services deduct from. A product manager says "just put it in
the profile, it is one more field". Explain, with arithmetic, why that is wrong, and give the
design that works.
#sol[
*Why it is wrong.* A balance is not a value you overwrite; it is a value you *modify based on
what you last read*. Under AP replication two regions can both read 100, both deduct 30, and
both write 70. The user spent 60 and lost 30.

*How often would that actually happen?* Suppose a user spends twice a day and replication
convergence takes 1 second. The window in which a second deduction can see a stale balance is
1 second out of the gap between the two spends. If the two spends are independent within a
day:
$ P("second spend lands inside the 1 s window") approx 1 \/ 86,400 = 1.16 times 10^(-5) $
With 200 million daily active users spending twice a day, that is
$ 200,000,000 times 1.16 times 10^(-5) = 2,320 "lost deductions per day" $
At an average 50 rupees each, that is 116,000 rupees a day of money given away, every day,
silently. "Rare" is not the same as "acceptable" when you multiply by 200 million.

*What works.*
+ *Move balances into store 2* (the CP store), sharded by `user_id`, one consensus group per
  shard. A deduction is a compare-and-set on `(balance, version)`, retried on conflict.
  Cost: ~200 ms for a cross-region write, and unavailability in a cut-off region.
+ *Or make the operation commutative.* Store the balance as an append-only *ledger* of signed
  entries, and define the balance as their sum. Two concurrent deductions are then two
  entries, and the sum is correct with no coordination at all. Cost: you must still refuse a
  spend that would go below zero, and *that* check needs coordination --- unless you
  pre-allocate.
+ *Or pre-allocate.* Each region holds a *reservation* of the user's balance --- say 40% each
  for the two regions the user actually uses. A spend inside your region's reservation needs
  no coordination at all. Running low triggers a slow, coordinated top-up.

*Decision: the ledger (option 2) plus a reservation (option 3), with the balance floor
enforced by the reservation.* Spends are then local and fast in the normal case, the ledger
means no deduction is ever lost, and coordination happens only when a region's reservation
runs low --- which for a typical user is a few times a month, not twice a day. Option 1 is
the honest fallback if the product cannot tolerate a user being told "insufficient balance"
while 60% of their money is reserved in a region they are not in.
]
]

#ex(18, tier: 3, asked: "Microsoft · pattern")[Your 5-node consensus group is spread 2-1-1-1
over four regions. The link between Singapore (2 nodes) and everywhere else fails. Walk
through exactly what happens, and then explain why a 2-2-1 layout would have been worse.
#sol[
*What happens with 2-1-1-1.*
+ Majority is $floor(5\/2) + 1 = 3$.
+ Singapore's side has 2 nodes. $2 < 3$, so it *cannot* elect a leader and cannot commit
  anything. If the old leader was in Singapore, it loses its lease within one TTL and steps
  down.
+ The other side has $1 + 1 + 1 = 3$ nodes. $3 gt.eq 3$, so it elects a leader and keeps
  committing. The service is *available* everywhere except for clients that can only reach
  Singapore.
+ Writes committed by the majority before the split are safe. Writes the Singapore leader had
  proposed but not committed are discarded when it rejoins --- which is correct, because they
  were never acknowledged to any client.
+ Fencing: the new leader's term is higher, so the old Singapore leader's late messages are
  rejected on arrival.

*Why 2-2-1 is worse.* Now suppose the split puts the two 2-node regions on one side and
everything else on the other. One side has $2 + 1 = 3$ and can still work --- fine. But the
*other* common failure, losing the single 1-node region entirely, leaves $2 + 2 = 4$ nodes
which is still a majority, so that case is fine too. The real problem with 2-2-1 is
different: *any two-region outage* can leave $2 + 1 = 3$ or $2 + 2 = 4$, but the combination
of "lose the 1-node region" *and* "one node in a 2-node region reboots for patching" leaves
$2 + 1 = 3$ --- exactly at the edge, with zero spare. With 2-1-1-1 the same double event
leaves $2 + 1 + 1 = 4$ or $1 + 1 + 1 = 3$ depending on which pieces are lost, and crucially
*no single region holds more than 2 of 5*, so no single region's loss can ever take you below
3.

*The rule to state:* place consensus members so that *no single failure domain holds a
majority, and no single failure domain's loss drops you below a majority*. With 5 nodes and 4
regions, 2-1-1-1 is the only layout that satisfies both. With 3 regions, use 5 nodes as
2-2-1 and accept that losing a 2-node region leaves you with exactly 3 --- then *add a
sixth node? No.* Six is worse than five: majority becomes 4, so you still only tolerate 2
failures, and you have paid for an extra node and an extra round trip. *Consensus group sizes
should be odd. Always.*
]
]

#practice(tier: 3, time: "45 min")[
+ Recompute the whole read path if the cache hit rate is 85% instead of 95%. How many store
  nodes per region do you now need at peak, and what does that do to the cost argument?
+ A partition lasts 20 minutes. Mumbai took 1,157 writes/s locally the whole time. How many
  writes must converge when the link returns, how long does convergence take at 3,000
  writes/s of repair bandwidth, and what does the user see meanwhile?
+ Design the migration that moves `credit_balance` out of the AP profile store and into the
  CP store with zero lost money and zero downtime. List the phases and the verification.
+ Your consensus group's leader is in Virginia but 70% of username claims originate in
  Singapore. Compute the latency each way and decide whether to move the leader, shard
  differently, or leave it.
+ Write the exact sentence you would say when an interviewer asks "is your system CP or AP?"
  --- in under 40 words, covering both stores.
]
#key[
+ Store load $= 277,779 times 0.15 = 41,667$/s, so $41,667 \/ 20,000 = 2.1 arrow.r 3$
  nodes of *read work*, against 16 nodes provisioned. Headroom falls from 16x to 5.3x. Still
  fine --- which is the real lesson: when the store is sized by *storage and replication*
  rather than by QPS, a 10-point swing in hit rate is a non-event. Design so that your
  scariest number is not the one you can least predict.
+ $1,157 times 20 times 60 = 1,388,400$ writes to ship. At 3,000/s of repair capacity
  *on top of* the live 1,157/s, the spare is $3,000 - 1,157 = 1,843$/s, so
  $1,388,400 \/ 1,843 = 753$ s $approx 12.6$ minutes. Meanwhile users outside Mumbai
  see up to 20 minutes of staleness on profiles edited in Mumbai, and Mumbai users see
  staleness on everyone else's. Nobody sees an error. That is AP behaving as designed.
+ Phases: (1) dual-write every balance change to both stores, CP store authoritative for
  *nothing* yet; (2) backfill by replaying the ledger into the CP store and compare totals per
  user; (3) flip reads to the CP store, keep dual-writing; (4) flip writes, keep the AP field
  updated for rollback; (5) after 7 clean days, stop writing the AP field; (6) delete it.
  Verification: a daily job summing both stores per user and alarming on *any* non-zero
  difference. Money tolerates no sampling --- check every row.
+ Singapore $arrow.r$ Virginia is ~230 ms one way region-to-region round trip, so a claim from
  Singapore costs roughly $230 + 60 = 290$ ms (reach the leader, then the leader reaches a
  majority). Moving the leader to Singapore makes Singapore claims ~120 ms and Virginia claims
  ~290 ms. Weighted: leader in Virginia $= 0.7 times 290 + 0.3 times 120 = 239$ ms; leader in
  Singapore $= 0.7 times 120 + 0.3 times 290 = 171$ ms. *Decision: move the leader to
  Singapore* --- 68 ms saved on average, no design change, just leader placement. Better still,
  shard usernames by region-of-origin prefix so each shard's leader sits where its traffic is.
+ "Both, on purpose. Profiles are AP --- during a partition every region keeps serving and
  writing, and conflicts merge by version vector. Username and balance claims are CP --- a
  minority region returns 503 rather than issue a name twice."
]

#section[Interview drill --- what the interviewer pushes on]

#table(columns: 2, align: (left, left),
  [*They ask*], [*You answer*],
  ["Why not just shard from day one?"],
    ["Because sharding costs me joins, cross-shard transactions, global ordering and easy
     schema changes, and it is very hard to reverse. I shard when one machine cannot hold
     the data or take the writes. At 6 million orders a day I sharded for *restore time*,
     not for QPS, and I said so."],
  ["Pick a shard key for a chat app."],
    ["`conversation_id`, hashed. Every message read and write is scoped to one conversation,
     so that is a single-shard operation. Not `user_id`, because a two-person chat would
     then live on two shards and every message would be a cross-shard write."],
  ["What is wrong with `hash(key) % N`?"],
    ["$N$ changes. Going from 10 to 11 nodes moves about 91% of keys instead of 9%. I hash
     into 1,024 fixed buckets and map buckets to shards, so a key's bucket never changes for
     the life of the system."],
  ["Your follower is 20 minutes behind. Now what?"],
    ["First, take it out of the read pool --- health checks must watch lag in seconds, not
     CPU. Then find out which of three causes it is: a single long transaction on the leader,
     replication being single-threaded while the leader writes in parallel, or the follower's
     disk being slower than the leader's. Only the third is fixed by hardware."],
  ["Is your system CP or AP?"],
    ["Per data type. Display data is AP because staleness is invisible and downtime is not.
     Unique claims and money are CP because two owners of one username cannot be merged.
     Saying 'the system is AP' would be a design error, not a summary."],
  ["Exactly-once across shards?"],
    ["Not with a distributed transaction if I can avoid one. I make the operation land on a
     single shard by choosing the shard key well; when I genuinely cannot, I use a saga with
     idempotent steps and compensations, because a two-phase commit blocks every participant
     when the coordinator dies."],
  ["How do you prevent split brain?"],
    ["Arithmetic, not etiquette. A leader needs a majority, so two majorities cannot exist.
     A leader holds a *lease* it must renew, so a frozen leader loses it without needing to
     be told. And every write carries a fencing token that storage rejects if it is lower
     than the highest seen."],
  ["Why is the consensus group size always odd?"],
    ["Because 6 nodes tolerate the same 2 failures as 5 --- majority goes from 3 to 4 --- so
     the sixth node costs money and latency and buys nothing."],
  ["Can you just turn on synchronous replication everywhere?"],
    ["You can, and a write to a region 60 ms away then takes 62 ms instead of 2 ms. With 200
     connections per server that is 3,226 writes/s instead of 100,000 --- 31 times less
     throughput. I use semi-sync to a *local* follower, which costs about 0.5 ms and still
     bounds data loss on failover."],
  ["Two regions wrote the same field. Who wins?"],
    ["First I ask whether it is a real conflict: version vectors tell me CONCURRENT apart
     from merely stale. If it is real, the resolution depends on the field --- union for
     sets, sum for counters, region-tiebreak for scalars, and for money I prevent the
     conflict instead of resolving it."],
  ["What breaks first as you add shards?"],
    ["Anything that touches all of them. Scatter-gather tail latency: at 16 shards with a 1%
     slow rate, 14.9% of fan-out requests are slow; at 64 shards, 47%. Also schema migrations,
     backups, and the number of connections every service holds."],
)

#trap[
The classic Tier-3 trap: the interviewer says "now make it strongly consistent globally" and
waits to see whether you just say yes. The right answer names the price first. "I can, with a
consensus group per shard. Writes go from 2 ms to about 200 ms, throughput per server drops
roughly 30x, and a region cut off from the majority stops accepting writes entirely. For
usernames that is the right price. For 8 billion profile reads a day it is not. Which data
did you mean?"
]

#practice(tier: 3, time: "40 min")[
+ A social product shards by `user_id`. Product adds "group chat with up to 500 members".
  Choose the shard key for messages, and prove your choice beats the two alternatives with
  arithmetic on the number of shards touched per send and per read.
+ Design the lag alarm. What do you measure, what threshold, and what does the system do
  automatically at each level?
+ You have 32 shards and must run a schema migration adding a column with a backfill. Write
  the plan so that no shard is ever locked for more than 1 second and the migration can be
  stopped at any point.
+ Compute the expected number of *simultaneously unavailable* shards if each node has a 0.1%
  chance of being down at any moment, you run 128 shards at RF 3, and a shard is unavailable
  when 2 of its 3 replicas are down.
+ Your store offers `W=1, R=1` for speed. Write the one-paragraph explanation you would give
  a product manager about what they are actually buying and what they are giving up.
]
#key[
+ *Shard by `conversation_id`.* Send: 1 shard (write one message row). Read the last 50
  messages: 1 shard. Alternative A, shard by `sender_id`: send is 1 shard, but reading a
  conversation must gather from up to 500 shards --- with 0.99 per-shard fast probability,
  $0.99^500 = 0.0066$, so *99.3%* of reads hit a slow shard. Dead. Alternative B, fan-out on
  write to each member's inbox: send touches up to 500 shards, so at 100 group messages/s that
  is 50,000 shard writes/s. Reading is then 1 shard. *Decision: `conversation_id`,* with a
  small per-user index of "conversations I am in" (one row per membership) so the chat list
  is also a single-shard read.
+ Measure *seconds of lag* (the leader's newest commit timestamp minus the follower's last
  applied timestamp), not bytes and not CPU. Thresholds: >2 s warn; >10 s automatically
  remove from the read pool; >60 s page a human; >retention-window/2 is a data-loss emergency
  because the leader may drop log segments the follower still needs. Every one of those is an
  automatic action except the last.
+ Add the column as nullable with a default *at the metadata level only* (no table rewrite).
  Backfill in batches of 1,000 rows per shard with a sleep between batches, shard by shard,
  never more than 4 shards in flight. Application code must tolerate both null and filled for
  the whole migration --- write the new column, read with a fallback. Stop = stop the backfill
  job; nothing is inconsistent because nothing read it as required yet. Only after 100% is
  backfilled and verified do you add the NOT NULL constraint.
+ $P("one node down") = 0.001$. $P("2 specific of 3 down") = 0.001^2 = 10^(-6)$, and there
  are $binom(3,2) = 3$ such pairs, so $P(gt.eq 2 "down") approx 3 times 10^(-6)$ (the
  all-three case is negligible). Expected unavailable shards
  $= 128 times 3 times 10^(-6) = 3.84 times 10^(-4)$. So on average about 0.0004 shards are
  unavailable at any moment --- roughly 34 seconds per day across the whole fleet. That is the
  argument for RF 3: at RF 2 a *single* node failure loses a shard, giving
  $128 times 2 times 0.001 = 0.256$ expected unavailable shards, which is 670 times worse.
+ "You are buying about 2 ms instead of 6 ms on a write, and about 2 ms instead of 5 ms on a
  read. You are giving up the guarantee that a read sees the latest write at all: with five
  copies, one writer and one reader, they can simply be different machines. Concretely, a user
  can save a setting, reload, and see the old value --- not for a second, but until the
  background repair catches up, which can be minutes. For a view counter that is fine. For
  anything a user will complain about, it is not, and the fix costs 4 ms."
]

#revision[
*The three words.* Replication = copies (safety + read capacity, *not* write capacity).
Sharding = splits (write capacity + storage, *not* safety). Consistency model = the promise
you make the reader. You need all three, in that order, and you shard *last*.

*Why you shard.* Size and blast radius far more often than QPS. 6.57 TB restores in
9.1 hours; a 411 GB shard restores in 34 minutes and takes only $1\/16$ of users with it.

*The quorum rule.* $W + R > N$ guarantees an overlap of $W + R - N$ nodes, so a read sees the
newest write. You survive $N - W$ failures for writes and $N - R$ for reads. $N=5, W=3, R=3$
is the balanced default. $W = N$ looks safe and is the most fragile choice on the table.

*Consistent hashing.* Adding the $(N+1)$-th node moves $1\/(N+1)$ of keys; modulo moves
$N\/(N+1)$. Measured for 10 $arrow.r$ 11: *8.25% versus 91.05%*. Use 100--200 virtual nodes
per machine --- with 1, the busiest node held 64.5x the quietest.

*The bucket trick.* Never hash to a shard. Hash to 1,024 (or 8,192) fixed buckets, and keep a
versioned `bucket -> shard` map. A key's bucket never changes, so resharding copies buckets
instead of rehashing keys. Put the bucket in the id and routing needs no lookup at all.

*Choosing a shard key --- four tests.*
+ Does it make the *most frequent* query single-shard?
+ Is it evenly distributed, with no entity above ~2x the average?
+ Can it *never change* for a row? (If it can, stop. Choose again.)
+ Do the things that must be transactional share it?

*CAP, said correctly.* Partitions are not a choice. During one you pick an error (CP) or a
stale answer (AP). PACELC adds: even with no partition, you trade latency against consistency.
*Different data in one product sits on different sides.* Profiles AP, usernames CP.

*Failover safety --- three rules.* Majority election (so two leaders cannot both win).
Leases, not locks (so a frozen leader loses it without being told). Fencing tokens that always
increase (so storage rejects a late write from an old leader). Consensus groups are always an
*odd* size: 6 tolerates the same 2 failures as 5.

*Numbers to memorise.*
- 1 million/day $approx 11.6$/s; 1 billion/day $approx 11,574$/s
- same-DC round trip 0.5 ms; SG$<->$Mumbai ~60 ms; SG$<->$Virginia ~230 ms
- one SQL node ~5,000 writes/s, ~20,000 indexed reads/s; Redis ~100,000 ops/s
- restore speed ~200 MB/s $arrow.r$ keep shards between 200 GB and 1 TB
- sync-to-a-far-region costs 31x throughput: 100,000/s $arrow.r$ 3,226/s at 200 connections
- scatter-gather tail: $0.99^16 = 0.851$, so 14.9% slow at 16 shards; $0.99^64 = 0.526$
- raw disk $=$ logical $times$ RF $times$ 1.5 for compaction headroom

*Conflict resolution ladder.* Prevent (single leader / consensus) > merge function (union,
sum, max) > keep both and ask > last-write-wins. Never LWW on a wall clock: a 40 ms skew
silently deletes the newer write.

*Read-your-writes, cheapest first.* (1) The write response contains the new value --- free.
(2) Pin the session to one region or the leader for a few seconds. (3) Version token on the
read. (4) Quorum read everywhere --- almost never worth it at an 80:1 read ratio.

*JavaScript traps in this chapter.*
+ `ring.sort()` with no comparator sorts 32-bit hashes as text and silently corrupts routing.
+ A weak hash without an avalanche step puts `n0#1` and `n0#2` next to each other, which
  defeats virtual nodes entirely.
+ `Map` keeps insertion order and real key types; a plain object stringifies keys, which
  breaks numeric bucket ids.
+ Money is integer cents. A float balance drifts and no ledger will ever balance again.

*Checklist before you say "done".*
+ Said whether you are solving reads, writes, or size --- and sharded only for the last two.
+ Named the shard key and passed all four tests on it out loud.
+ Gave $N$, $W$, $R$ and showed $W + R > N$.
+ Said which data is CP and which is AP, and why the cost of being wrong differs.
+ Explained resharding *before* being asked, using buckets.
+ Named the hot key or hot shard and gave a fix with its cost.
+ Covered failover: majority, lease, fencing token.
+ Gave both sides of every trade-off and then *decided*.

*Three sentences that score marks.*
+ "I am sharding for restore time and blast radius, not for QPS --- one machine could take
  this write load."
+ "Partitions are not a choice, so the question is what I do during one; profiles answer
  stale, username claims answer 503."
+ "A lease expires by itself and a fencing token is checked by the storage, so a frozen
  leader cannot corrupt anything even though it never found out it was replaced."
]

]
