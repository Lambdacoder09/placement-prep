#import "../../shared/lib/style.typ": *

#chapter(num: 2, title: "Back-of-the-Envelope Estimation",
  tagline: "Thirty seconds of arithmetic decides the next thirty minutes of design.")[

#section[The idea in one page]

In step 2 of the seven steps you turn a sentence into numbers. That is all estimation
is. You are not trying to be exact. You are trying to land in the right *order of
magnitude* so that the rest of the design is honest.

Here is why it matters. Two candidates design the same photo app.

- Candidate A says "we will need a lot of storage, so let us use a distributed file
  system". Twenty minutes later they are drawing replication protocols.
- Candidate B spends 40 seconds and says "3.2 million uploads a day at 600 KB stored
  is 1.9 TB a day, so 700 TB a year. That is too big for one disk but small enough that
  object storage plus a CDN is the whole answer. No custom file system."

Candidate B has *earned the right* to skip a hard problem. That is what the number
bought. Candidate A has to argue.

#formulas(title: "The one rule that makes estimation easy")[
*Keep one significant figure, and say out loud that you are rounding.*

$"4,166.67"$ becomes "about four thousand". $"1,752"$ GB becomes "under 2 TB".
You are choosing between "one server" and "one hundred servers". Being 20% off never
changes that choice. Being 100x off always does.

An estimate is *good* if it is within about 2x of the truth. It is *acceptable* at 3x.
It is *wrong* at 10x, because at 10x you pick the wrong architecture.
]

#subsection[The five quantities, always in this order]

#table(columns: (auto, auto, 1fr),
  align: (left, left, left),
  [*\#*], [*Quantity*], [*Why it is next*],
  [1], [Peak QPS], [decides how many servers, and whether you need a cache at all],
  [2], [Storage per year], [decides one database or many shards],
  [3], [Peak bandwidth], [decides CDN yes or no, and how big the network bill is],
  [4], [Memory for the hot set], [decides the cache size, which decides the cache cost],
  [5], [Machine count and cost], [the sentence that ends the estimate],
)

#diagram(height: 4.6cm, caption: "The estimation pipeline. One arrow, one multiplication. Never skip an arrow.")[
  #dnode(0cm, 0.15cm, 2.6cm, 0.8cm, "DAU\n12 M", fill: rgb("#dce9f2"))
  #dnode(3.4cm, 0.15cm, 3.0cm, 0.8cm, "requests/day\n360 M")
  #dnode(7.2cm, 0.15cm, 2.8cm, 0.8cm, "average QPS\n4,167")
  #dnode(10.8cm, 0.15cm, 2.8cm, 0.8cm, "peak QPS\n12,500", fill: rgb("#dce9f2"))

  #dnode(0cm, 1.7cm, 2.6cm, 0.8cm, "rows/day\n6 M")
  #dnode(3.4cm, 1.7cm, 3.0cm, 0.8cm, "bytes/day\n4.8 GB")
  #dnode(7.2cm, 1.7cm, 2.8cm, 0.8cm, "storage/year\n1.75 TB")
  #dnode(7.2cm, 3.1cm, 2.8cm, 0.8cm, "raw disk\n5.3 TB")

  #dnode(10.8cm, 1.7cm, 5.4cm, 0.8cm, "bandwidth = 12,500 × 4 KB = 50 MB/s = 400 Mbps")
  #dnode(10.8cm, 3.1cm, 5.4cm, 0.8cm, "servers = 12,500 / 800 × 1.5 = 24", fill: rgb("#f7efe4"))

  #darrow(2.6cm, 0.55cm, 3.4cm, 0.55cm, label: "×30")
  #darrow(6.4cm, 0.55cm, 7.2cm, 0.55cm, label: "÷86,400")
  #darrow(10.0cm, 0.55cm, 10.8cm, 0.55cm, label: "×3")
  #darrow(1.3cm, 0.95cm, 1.3cm, 1.7cm, dashed: true, label: "writes")
  #darrow(2.6cm, 2.1cm, 3.4cm, 2.1cm, label: "×800 B")
  #darrow(6.4cm, 2.1cm, 7.2cm, 2.1cm, label: "×365")
  #darrow(8.6cm, 2.5cm, 8.6cm, 3.1cm, label: "×3 RF")
  #darrow(12.2cm, 0.95cm, 12.2cm, 1.7cm, label: "×resp")
  #darrow(13.5cm, 2.5cm, 13.5cm, 3.1cm, label: "÷800")
]

#trap[
The most common estimation mistake is not arithmetic. It is *forgetting the
multiplier that lives behind the API*. A user posts once. The system writes 300 rows,
because 300 followers each get an inbox entry. The write API looks tiny; the write
load is 300x bigger. Always ask: "one user action equals how many stored rows?"
]

#section[The number cards]

You cannot derive these in the room. Memorise them. There are five cards and each one
fits on a postcard.

#subsection[Card 1 — time]

#formulas(title: "Seconds, and the divide-by-86,400 trick")[
#table(columns: (auto, auto, 1fr),
  [*Period*], [*Seconds*], [*Use it for*],
  [1 day],   [$"86,400" approx 10^5$], [turning a daily count into QPS],
  [1 month (30 d)], [$"2,592,000" approx 2.6 times 10^6$], [monthly bills],
  [1 year (365 d)], [$"31,536,000" approx 3.15 times 10^7$], [yearly storage],
)

*The single most useful fact in this book:*
$ 1 "million per day" = "1,000,000" / "86,400" = 11.574 approx bold(11.6) "per second" $

So: take the daily count *in millions* and multiply by 11.6.
]

#trick[
*Worked, three times, so the reflex sticks.*

- 5 million/day $arrow.r 5 times 11.6 = 58$ per second.
  #h(4pt) Check: $"5,000,000" \/ "86,400" = 57.87$. #sym.checkmark
- 360 million/day $arrow.r 360 times 11.6 = "4,176"$ per second.
  #h(4pt) Check: $"360,000,000" \/ "86,400" = "4,166.7"$. #sym.checkmark (0.2% high)
- 30 billion/day $= "30,000"$ million $arrow.r "30,000" times 11.6 = "348,000"$ per second.
  #h(4pt) Check: $30 times 10^9 \/ "86,400" = "347,222"$. #sym.checkmark

The trick is never more than 0.3% off, and you can do it in your head.
]

#subsection[Card 2 — bytes]

#formulas(title: "Powers of two, and the byte ladder")[
#table(columns: (auto, auto, auto, 1fr),
  [*Power*], [*Exact*], [*Call it*], [*Mental hook*],
  [$2^10$], [1,024], [1 thousand], [1 KB],
  [$2^20$], [1,048,576], [1 million], [1 MB],
  [$2^30$], [1,073,741,824], [1 billion], [1 GB],
  [$2^32$], [4,294,967,296], [4.3 billion], [the limit of a 32-bit id],
  [$2^40$], [$1.10 times 10^12$], [1 trillion], [1 TB],
  [$2^50$], [$1.13 times 10^15$], [1 quadrillion], [1 PB],
  [$2^63$], [$9.22 times 10^18$], [9.2 quintillion], [the limit of a signed 64-bit id],
)

*The ladder that does most of the work:*
$ 1 "KB" times 1 "million" = 1 "GB" quad quad 1 "KB" times 1 "billion" = 1 "TB" $
$ 1 "MB" times 1 "million" = 1 "TB" quad quad 1 "MB" times 1 "billion" = 1 "PB" $

In interviews use *decimal* units: 1 GB $= 10^9$ bytes. The 7% gap against $2^30$ is
inside your rounding error, and the arithmetic is ten times faster. Say "I am using
decimal GB" once and move on.
]

#trap[
`1 GB` and `1 Gb` are different by a factor of 8. Storage and disk are quoted in
*bytes* (capital B). Network links are quoted in *bits* (small b). A "1 Gbps" network
card moves $"1,000,000,000" \/ 8 = 125$ MB per second, not 1,000 MB per second.
Multiply by 8 when going from MB/s to Mbps; divide by 8 going the other way.
]

#subsection[Card 3 — latency]

These are the numbers that tell you whether a design can possibly meet its budget.
They are approximate and they change slowly with hardware, but the *ratios* between
them have been stable for twenty years, and the ratios are what you reason with.

#diagram(height: 5.7cm, caption: "The latency ladder. Each bar is one step of ten on a log scale — the bars are not to linear scale, no picture could be.")[
  #dnode(0cm, 0.10cm, 4.2cm, 0.44cm, "L1 cache reference", fill: white)
  #dnode(4.6cm, 0.10cm, 0.73cm, 0.44cm, "", fill: rgb("#dce9f2"))
  #place(dx: 5.5cm, dy: 0.17cm)[#text(size: 7.5pt)[0.5 ns]]

  #dnode(0cm, 0.66cm, 4.2cm, 0.44cm, "main memory read", fill: white)
  #dnode(4.6cm, 0.66cm, 3.15cm, 0.44cm, "", fill: rgb("#dce9f2"))
  #place(dx: 7.9cm, dy: 0.73cm)[#text(size: 7.5pt)[100 ns]]

  #dnode(0cm, 1.22cm, 4.2cm, 0.44cm, "compress 1 KB", fill: white)
  #dnode(4.6cm, 1.22cm, 4.52cm, 0.44cm, "", fill: rgb("#dce9f2"))
  #place(dx: 9.3cm, dy: 1.29cm)[#text(size: 7.5pt)[2 µs]]

  #dnode(0cm, 1.78cm, 4.2cm, 0.44cm, "read 1 MB from memory", fill: white)
  #dnode(4.6cm, 1.78cm, 5.75cm, 0.44cm, "", fill: rgb("#dce9f2"))
  #place(dx: 10.5cm, dy: 1.85cm)[#text(size: 7.5pt)[30 µs]]

  #dnode(0cm, 2.34cm, 4.2cm, 0.44cm, "SSD random read", fill: white)
  #dnode(4.6cm, 2.34cm, 6.30cm, 0.44cm, "", fill: rgb("#f7efe4"))
  #place(dx: 11.1cm, dy: 2.41cm)[#text(size: 7.5pt)[100 µs]]

  #dnode(0cm, 2.90cm, 4.2cm, 0.44cm, "round trip, same data centre", fill: white)
  #dnode(4.6cm, 2.90cm, 7.03cm, 0.44cm, "", fill: rgb("#f7efe4"))
  #place(dx: 11.8cm, dy: 2.97cm)[#text(size: 7.5pt)[500 µs]]

  #dnode(0cm, 3.46cm, 4.2cm, 0.44cm, "spinning-disk seek", fill: white)
  #dnode(4.6cm, 3.46cm, 8.40cm, 0.44cm, "", fill: rgb("#f0dede"))
  #place(dx: 13.2cm, dy: 3.53cm)[#text(size: 7.5pt)[10 ms]]

  #dnode(0cm, 4.02cm, 4.2cm, 0.44cm, "Mumbai to Singapore RTT", fill: white)
  #dnode(4.6cm, 4.02cm, 9.22cm, 0.44cm, "", fill: rgb("#f0dede"))
  #place(dx: 14.0cm, dy: 4.09cm)[#text(size: 7.5pt)[60 ms]]

  #dnode(0cm, 4.58cm, 4.2cm, 0.44cm, "Mumbai to Virginia RTT", fill: white)
  #dnode(4.6cm, 4.58cm, 9.87cm, 0.44cm, "", fill: rgb("#f0dede"))
  #place(dx: 14.6cm, dy: 4.65cm)[#text(size: 7.5pt)[250 ms]]
]

#formulas(title: "The same ladder, scaled to human time (1 nanosecond = 1 second)")[
This is the version you should actually remember, because it makes the gaps feel real.

#table(columns: (1fr, auto, auto),
  align: (left, right, right),
  [*Operation*], [*Real time*], [*If 1 ns were 1 second*],
  [read from L1 cache], [0.5 ns], [half a second],
  [read from main memory], [100 ns], [under 2 minutes],
  [read 1 MB from memory], [30 µs], [8 hours],
  [one random read from an SSD], [100 µs], [just over a day],
  [one network round trip inside a data centre], [500 µs], [6 days],
  [one seek on a spinning disk], [10 ms], [4 months],
  [Mumbai #sym.arrow.l.r Singapore round trip], [60 ms], [2 years],
  [Mumbai #sym.arrow.l.r Virginia round trip], [250 ms], [8 years],
)
]

#trick[
*Three sentences you can derive from that table, and they win arguments.*

+ *Memory is about 5,000x faster than a same-data-centre network hop*
  ($500 "µs" \/ 100 "ns" = "5,000"$). So one in-process cache lookup is free compared
  to one Redis call. Do not put a 40-byte value in Redis if you can hold it locally.
+ *A cross-continent round trip costs 250 ms, and you cannot fix it with a faster
  server.* Light in glass does about 200,000 km per second. Mumbai to Virginia and back
  is roughly 25,000 km of cable, so $"25,000" \/ "200,000" = 0.125$ s of pure physics,
  before any equipment. The only fix is a copy of the data near the user.
+ *Chatty beats nothing, batched beats chatty.* 100 sequential same-DC calls cost
  $100 times 0.5 "ms" = 50$ ms. One batched call costs 0.5 ms. Always say this when
  you draw a loop that calls a service.
]

#subsection[Card 4 — what one machine does]

#formulas(title: "Throughput of one ordinary box (safe interview figures)")[
#table(columns: (1fr, auto, auto),
  align: (left, right, left),
  [*Component*], [*Per second*], [*What limits it*],
  [Node.js API server, light work], [1,000--2,000 req], [one CPU core per process],
  [Node.js API server, per core, 2 ms of CPU], [500 req], [$1 \/ 0.002$],
  [Nginx / load balancer], [50,000+ req], [almost free, it just copies bytes],
  [MySQL / Postgres, simple indexed reads], [10,000--20,000], [buffer pool hit rate],
  [MySQL / Postgres, writes with fsync], [3,000--5,000], [disk flush, replication],
  [Redis, simple GET/SET], [80,000--100,000], [single-threaded command loop],
  [Kafka, one partition], [10 MB/s+], [sequential disk write, very fast],
  [One machine, open WebSocket connections], [#sym.approx 100,000 held], [memory per socket],
  [1 Gbps network card], [125 MB/s], [the link],
  [10 Gbps network card], [1,250 MB/s], [the link],
)

Use the *low* end of each range. If your design works at 3,000 database writes per
second, it also works at 5,000. The reverse is not true.
]

#note[
Nobody will check these to the decimal. What is checked is whether you *have* a number
at all, and whether you used it. "One Postgres box does about 5,000 writes a second;
I need 12,000, so one box is not enough and I shard into 4" is a complete, defensible
piece of reasoning. "The database might struggle" is not.
]

#subsection[Card 5 — how big is one of those?]

#formulas(title: "Sizes to quote without thinking")[
#table(columns: (1fr, auto, 1fr),
  align: (left, right, left),
  [*Thing*], [*Size*], [*Note*],
  [32-bit integer], [4 B], [id space only $4.29 times 10^9$],
  [64-bit integer / timestamp], [8 B], [use this for ids and times],
  [UUID, raw bytes], [16 B], [as text with dashes it is 36 B],
  [a short text post], [300 B], [140 characters plus metadata],
  [one chat message row], [400--600 B], [body + sender + room + time + index],
  [one feed/inbox row (ids only)], [50--80 B], [postId, authorId, ts, score],
  [a JSON API response], [2--10 KB], [this is what you bill bandwidth on],
  [a compressed phone photo], [300 KB -- 1 MB], [before thumbnails],
  [a photo thumbnail set], [50--150 KB], [3 sizes],
  [1 minute of 1080p video at 2.5 Mbps], [18.75 MB], [$2.5 times 60 \/ 8$],
  [1 hour of 1080p video at 2.5 Mbps], [1.125 GB], [$18.75 times 60$],
  [one log line], [200--500 B], [logs are usually bigger than your data],
)
]

#subsection[Card 6 — the peak factor]

Traffic is never flat. You size for the peak, not the average.

#formulas(title: "Which multiplier to use, and the sentence that defends it")[
#table(columns: (auto, auto, 1fr),
  [*Product shape*], [*Peak / average*], [*Why*],
  [global, many time zones], [2x], [one region's night is another's morning],
  [one country, consumer app], [3x], [everybody is awake in the same evening],
  [one country, work app], [4--5x], [nothing happens at night or on Sunday],
  [event-driven (sale, match, results day)], [10--50x], [everybody arrives in one minute],
)

*The defence, said in one breath:* "A perfectly flat day puts
$100% \/ 24 = 4.2%$ of traffic in each hour. A real Indian consumer app puts 12--15% of
its day into the 8--10 p.m. hour. $15 \/ 4.2 = 3.6$, so 3x is a conservative peak
factor." Now the number is yours, not a guess.
]

#section[The five-step estimate, as a template]

Every estimate in this book follows these five lines. Write them on the board as five
lines and fill them in. It takes 90 seconds.

#formulas(title: "The template — copy it exactly")[
```
1. traffic   DAU × actions/user            = ____ /day
             ÷ 86,400                      = ____ QPS average
             × peak factor                 = ____ QPS peak
2. storage   new rows/day × bytes/row      = ____ /day
             × 365 × years × replication   = ____ total
3. bandwidth peak QPS × response bytes     = ____ B/s   (×8 = bits/s)
4. memory    hot items × bytes/item        = ____ cache size
5. machines  peak QPS ÷ per-server QPS × 1.5 = ____ servers
```
Then one closing sentence: "so this is a *small / medium / large* system, and the
binding constraint is \_\_\_\_."
]

That last sentence is worth more than all the arithmetic. It tells the interviewer you
know what the numbers were *for*.

#code(lang: "js", caption: "The same template as code — run it and change the inputs")[
```js
const SEC_PER_DAY = 86_400;

function estimate({ dau, actionsPerUser, peakFactor = 3,
                    bytesPerRow, rowsPerDay, respBytes, qpsPerServer }) {
  const reqPerDay = dau * actionsPerUser;
  const avgQps    = reqPerDay / SEC_PER_DAY;
  const peakQps   = avgQps * peakFactor;
  const bytesDay  = rowsPerDay * bytesPerRow;
  const bytesYear = bytesDay * 365;
  const peakBps   = peakQps * respBytes;              // bytes per second
  const servers   = Math.ceil((peakQps / qpsPerServer) * 1.5);
  return { reqPerDay, avgQps, peakQps, bytesDay, bytesYear, peakBps, servers };
}

const fmt = n =>
  n >= 1e12 ? (n / 1e12).toFixed(2) + " T" :
  n >= 1e9  ? (n / 1e9).toFixed(2)  + " G" :
  n >= 1e6  ? (n / 1e6).toFixed(2)  + " M" :
  n >= 1e3  ? (n / 1e3).toFixed(2)  + " k" : n.toFixed(2) + " ";

const r = estimate({
  dau: 12_000_000, actionsPerUser: 30, peakFactor: 3,
  rowsPerDay: 6_000_000, bytesPerRow: 800,
  respBytes: 4_000, qpsPerServer: 800,
});

console.log("requests/day :", fmt(r.reqPerDay));
console.log("average QPS  :", fmt(r.avgQps));
console.log("peak QPS     :", fmt(r.peakQps));
console.log("storage/day  :", fmt(r.bytesDay) + "B");
console.log("storage/year :", fmt(r.bytesYear) + "B");
console.log("peak egress  :", fmt(r.peakBps) + "B/s  =", fmt(r.peakBps * 8) + "bit/s");
console.log("app servers  :", r.servers);
```
]

#code(lang: "text", caption: "node estimate.js")[
```text
requests/day : 360.00 M
average QPS  : 4.17 k
peak QPS     : 12.50 k
storage/day  : 4.80 GB
storage/year : 1.75 TB
peak egress  : 50.00 MB/s  = 400.00 Mbit/s
app servers  : 24
```
]

#note[
You will not run code in the interview. Write this once at home, change the inputs ten
times, and the five lines become muscle memory. That is the point of the snippet.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
How many seconds are in a day, a 30-day month, and a 365-day year? Give the rounded
version you would actually use.
]
#sol[
*Day.* $24 times 60 times 60$. Do it in two steps:
$24 times 60 = "1,440"$ minutes, then $"1,440" times 60 = "86,400"$ seconds.
Round to $10^5$ = 100,000.

*Month (30 days).* $"86,400" times 30 = "2,592,000"$. Round to $2.6 times 10^6$.

*Year (365 days).* $"86,400" times 365$.
Break it up: $"86,400" times 300 = "25,920,000"$ and
$"86,400" times 65 = "5,616,000"$. Add: $"31,536,000"$.
Round to $3.15 times 10^7$, or "about 31.5 million".

*Which rounding is safe?* Using 100,000 instead of 86,400 makes your QPS number
$"86,400" \/ "100,000" = 0.864$, so 13.6% *low*. That is fine for a first pass, but say
it: "I rounded the day to 100,000 seconds, so my real QPS is about 15% higher."
]
#ans[86,400 · 2,592,000 · 31,536,000]

#ex(2, tier: 0, asked: "warm-up")[
A service has 12 million daily active users. Each does 30 actions a day. Find requests
per day, average QPS, and peak QPS for a single-country consumer app.
]
#sol[
*Requests per day.*
$ "12,000,000" times 30 = "360,000,000" "requests/day" $

*Average QPS.* Use the 11.6 trick first, then check by division.
$ 360 "million/day" times 11.6 = "4,176" "QPS" $
$ "Check:" quad "360,000,000" / "86,400" = "4,166.7" "QPS" $
The trick was 0.2% high. Call it *4,200 QPS*.

*Peak QPS.* One country, consumer, so 3x.
$ "4,166.7" times 3 = "12,500" "QPS at peak" $
]
#ans[360 M/day · #sym.approx 4,170 QPS average · 12,500 QPS peak]

#ex(3, tier: 0, asked: "warm-up")[
That service writes 6 million new rows a day. A row is 800 bytes. How much storage for
five years, at replication factor 3?
]
#sol[
*Per day.*
$ "6,000,000" times 800 = "4,800,000,000" "bytes" = 4.8 "GB/day" $

*Per year.*
$ 4.8 times 365 = "1,752" "GB" approx 1.75 "TB/year" $

*Five years.*
$ 1.75 times 5 = 8.76 "TB" $

*Times replication factor 3* (three copies so a disk failure loses nothing):
$ 8.76 times 3 = 26.3 "TB of raw disk" $

*The sentence that matters:* 26 TB of raw disk is four or five ordinary servers. This
is a *small* system. No sharding needed for storage reasons for years. Say that.
]
#ans[8.76 TB of data, #sym.approx 26 TB of raw disk at RF 3 — small]

#trap[
Students forget the replication factor and then forget indexes. Two habits fix it:
(i) always multiply the final storage by 3, and (ii) add 30% for indexes if the table
has two or more secondary indexes. $8.76 times 1.3 times 3 = 34.2$ TB. Still small,
but now the number is honest.
]

#ex(4, tier: 0, asked: "warm-up")[
Peak is 12,500 QPS and the average response is 4 KB. What is the outbound bandwidth,
in MB/s and in Mbps?
]
#sol[
Use 4,000 bytes for 4 KB — decimal units, and say so.

$ "12,500" times "4,000" = "50,000,000" "bytes/second" = 50 "MB/s" $

To bits, multiply by 8:
$ 50 times 8 = 400 "Mbps" $

*Read it.* A single 1 Gbps network card does 125 MB/s. You are asking for 50 MB/s, so
one card covers it with room to spare. Bandwidth is *not* your problem here. Request
count is.
]
#ans[50 MB/s = 400 Mbps — comfortable on one 1 Gbps link]

#ex(5, tier: 0, asked: "warm-up")[
You are choosing the type of the `id` column. The service creates 50 million new rows a
day. Is a 32-bit integer enough? Is a 64-bit integer enough?
]
#sol[
*32-bit signed vs unsigned.* An unsigned 32-bit integer holds
$2^32 = "4,294,967,296" approx 4.29 times 10^9$ values.

$ "4,294,967,296" / "50,000,000" = 85.9 "days" $

Under three months. A 32-bit id is *not* enough. You would run out before the next
financial year, and the outage would come at 3 a.m. with no warning.

*64-bit signed.* $2^63 = 9.22 times 10^18$ values.

$ 9.22 times 10^18 / "50,000,000" = 1.84 times 10^11 "days" $
$ 1.84 times 10^11 / 365 = 5.05 times 10^8 "years" $

Five hundred million years. Use 64-bit.

*Cost of the choice:* 4 extra bytes per row. At 50 million rows a day that is
$"50,000,000" times 4 = 200$ MB a day, $73$ GB a year. Nothing. Take the 64-bit id.
]
#ans[32-bit lasts 86 days — no. 64-bit lasts #sym.approx 500 million years — yes.]

#ex(6, tier: 0, asked: "warm-up")[
Your code reads a value from main memory. Your colleague's code reads the same value
from a Redis server in the same data centre. How many times faster is yours?
]
#sol[
From the latency card: main memory read is about 100 ns. A round trip inside one data
centre is about 500 µs $= "500,000"$ ns.

$ "500,000" / 100 = "5,000" $

Yours is *five thousand times* faster.

*What to do with that fact.* It does not mean "never use Redis". Redis holds things
that must be *shared* between 24 servers. It means: do not put a value in Redis that
every server could just hold itself — a feature flag, a small config table, a currency
rate. Hold those in process and refresh them every 30 seconds.
]
#ans[About 5,000x faster]

#ex(7, tier: 0, asked: "warm-up")[
You want to cache 20 million hot items. Each cached entry is about 300 bytes including
the key. How much memory, and does it fit on one Redis node?
]
#sol[
$ "20,000,000" times 300 = "6,000,000,000" "bytes" = 6 "GB" $

A Redis node with 16 GB of memory holds this easily, and you should *not* fill a cache
node past about 70% because Redis needs headroom for its own structures and for
fragmentation.

$ 16 times 0.7 = 11.2 "GB usable" > 6 "GB needed" quad #sym.checkmark $

One node. Add a replica for failover, which is 2 nodes total, not 2x the data.
]
#ans[6 GB — one 16 GB node, plus one replica]

#ex(8, tier: 0, asked: "warm-up")[
Peak is 12,500 QPS. One application server handles 800 QPS. How many servers?
]
#sol[
*Raw count.*
$ "12,500" / 800 = 15.625 arrow.r 16 "servers" $

*But 16 is wrong to ship.* At exactly 16 servers you are at 100% capacity at peak, so:
one deploy, one crash, or one slightly bad day and you are over.

Multiply by 1.5 for headroom:
$ 15.625 times 1.5 = 23.4 arrow.r bold(24) "servers" $

*Sanity check against zones.* 24 splits evenly into 3 availability zones as 8+8+8. If
one whole zone dies you are left with 16, which is exactly the raw requirement. That is
a clean answer, and saying it earns a mark.
]
#ans[24 servers — 8 per zone in 3 zones]

#ex(9, tier: 0, asked: "warm-up")[
A candidate says "we get 1 billion requests a day, that's about 1 million per second."
Find the mistake and give the correct figure.
]
#sol[
They divided by 1,000 somewhere instead of by 86,400 — probably they thought
"a billion is a thousand millions, and a day is about a thousand seconds". A day is
86,400 seconds, not 1,000.

$ "1,000,000,000" / "86,400" = "11,574" "per second" $

Or with the trick: $"1,000"$ million $times 11.6 = "11,600"$. #sym.checkmark

*Why this matters so much.* 1 million QPS and 11,600 QPS are different *systems*.
11,600 QPS is roughly 15 ordinary servers and one sharded database. 1 million QPS is a
custom edge fleet, a global cache tier, and a team of fifty. An 86x error changes every
later decision. This is exactly the failure mode the "order of magnitude" rule exists
to prevent.
]
#ans[#sym.approx 11,600 QPS, not 1 million. The candidate was 86x high.]

#practice(tier: 0, time: "10 min")[
+ 3 million DAU, 18 actions each per day. Requests/day, average QPS, peak at 3x?
+ Rows are 1.4 KB, 2.5 million rows a day. Storage for one year, and raw disk at RF 3?
+ Peak 9,000 QPS, average response 2.5 KB. Bandwidth in MB/s and Mbps?
+ Peak 9,000 QPS, one server does 1,200 QPS. How many servers with 1.5x headroom?
+ 50 million hot keys, 120 bytes each. Cache size in GB?
+ Which is slower, and by how much: one SSD random read, or one round trip to a server
  in the same data centre?
]

#key[
*1.* $"3,000,000" times 18 = "54,000,000"$/day.
$"54,000,000" \/ "86,400" = 625$ QPS. Peak $625 times 3 = "1,875"$ QPS.
Tiny — two servers and one database.

*2.* $"2,500,000" times "1,400" = "3,500,000,000"$ B $= 3.5$ GB/day.
$3.5 times 365 = "1,277.5"$ GB $approx 1.28$ TB/year. At RF 3:
$1.28 times 3 = 3.83$ TB of raw disk.

*3.* $"9,000" times "2,500" = "22,500,000"$ B/s $= 22.5$ MB/s.
In bits: $22.5 times 8 = 180$ Mbps.

*4.* $"9,000" \/ "1,200" = 7.5$, so 8 raw. With headroom
$7.5 times 1.5 = 11.25 arrow.r 12$ servers (4 per zone across 3 zones).

*5.* $"50,000,000" times 120 = "6,000,000,000"$ B $= 6$ GB.

*6.* The network round trip: 500 µs against 100 µs for the SSD read, so the network is
*5x slower*. This surprises people. Reading from a local disk can beat asking another
machine that has the answer in memory.
]

#section[Tier 1 — estimation inside a low-level design]
#tier-header(1)

An LLD round has no servers and no QPS. But it still has numbers, and they still decide
the design. The three questions that come up are:

#table(columns: (auto, 1fr),
  [*How much memory does this structure take?*],
    [decides whether "just keep it all in a Map" is a real answer or a joke],
  [*How slow is this lookup, in seconds of CPU per second of wall clock?*],
    [decides whether you need an index map or a scan is fine],
  [*How many things are in flight at once?*],
    [decides pool sizes, queue sizes, and whether you need a lock at all],
)

#subsection[Measuring memory instead of guessing it]

You can measure exactly how much memory a JavaScript structure takes. Do this once at
home and you will never guess wrong again.

#code(lang: "js", caption: "mem.js — run with: node --expose-gc mem.js <which>")[
```js
const which = process.argv[2];
const N = 1_000_000;

function snap() {
  global.gc(); global.gc();                        // settle the heap twice
  const m = process.memoryUsage();
  return m.heapUsed + m.arrayBuffers;              // typed arrays live outside the heap
}

const before = snap();
let keep;                                          // keep a reference or GC eats it
if (which === "map")    { const m = new Map();
                          for (let i = 0; i < N; i++) m.set("user:" + i, i); keep = m; }
if (which === "array")  { const a = new Array(N);
                          for (let i = 0; i < N; i++) a[i] = i; keep = a; }
if (which === "typed")  { const a = new Int32Array(N);
                          for (let i = 0; i < N; i++) a[i] = i; keep = a; }
if (which === "obj")    { const a = new Array(N);
                          for (let i = 0; i < N; i++)
                            a[i] = { id: i, floor: i % 5, size: i % 3, free: true };
                          keep = a; }
if (which === "objmap") { const m = new Map();
                          for (let i = 0; i < N; i++)
                            m.set(i, { id: i, floor: i % 5, size: i % 3, free: true });
                          keep = m; }
const after = snap();

console.log(which.padEnd(7),
            ((after - before) / 1e6).toFixed(1).padStart(7), "MB ",
            ((after - before) / N).toFixed(1).padStart(6), "bytes each",
            keep ? "" : "");
```
]

#code(lang: "text", caption: "Measured on Node v24, one million entries each")[
```text
$ for w in map array typed obj objmap; do node --expose-gc mem.js $w; done
map        61.4 MB    61.4 bytes each
array       8.0 MB     8.0 bytes each
typed       4.0 MB     4.0 bytes each
obj        64.0 MB    64.0 bytes each
objmap     85.4 MB    85.4 bytes each
```
]

#formulas(title: "The JavaScript memory card — carry these five numbers")[
#table(columns: (1fr, auto, 1fr),
  [*Structure*], [*Bytes per item*], [*Where it goes*],
  [`Int32Array` element], [4], [exactly 4 — it is a raw buffer],
  [`Array` of small integers], [8], [one 64-bit tagged slot each],
  [object with 4 small fields], [#sym.approx 64], [header + 4 slots, rounded up],
  [`Map` entry, string key], [#sym.approx 61], [key string + hash slot + load factor],
  [`Map` entry, int key #sym.arrow.r object value], [#sym.approx 85], [#sym.approx 21 for the slot, #sym.approx 64 for the object],
)

*Rule of thumb for an interview:* "a JavaScript object costs about 60--90 bytes, a Map
entry adds about 20--30 bytes on top of what it holds, and a typed array costs exactly
the element size." That sentence is enough.
]

#ex(10, tier: 1, asked: "TCS NQT · pattern")[
You are designing the in-memory index for a parking lot. Every spot is an object with
`id`, `floor`, `size`, `free`. You also keep `Map<spotId, Spot>` so lookup is $O(1)$.
How much memory for 200,000 spots? For 20 million?
]
#sol[
Use the measured number for `Map<key, object>`: about 85 bytes per entry, which already
includes the object.

*200,000 spots.*
$ "200,000" times 85 = "17,000,000" "bytes" = 17 "MB" $

Nothing. Keep everything in memory, no question.

*20 million spots.*
$ "20,000,000" times 85 = "1,700,000,000" "bytes" = 1.7 "GB" $

Now it matters. Node's default old-space heap limit is often around 2--4 GB, and 1.7 GB
of live data plus garbage-collection headroom is uncomfortable. Two honest options:

#table(columns: (1fr, 1fr),
  [*Option A — keep objects*], [*Option B — columns of typed arrays*],
  [1.7 GB, code stays readable], [`Int32Array` for floor, size; `Uint8Array` for free],
  [GC must walk 20 M objects on every major collection], [GC walks 3 buffers, not 20 M objects],
  [ship it, it is simple], [$"20,000,000" times (4+4+1) = 180$ MB],
)

$ "Option B" = 180 "MB versus" 1.7 "GB" = 9.4 times "smaller" $

*Decision: Option A at 200,000 spots, Option B above about 5 million.* Below 5 million
($"5,000,000" times 85 = 425$ MB) the readability is worth more than the memory. Above
it, the garbage collector pause becomes the user-visible problem, not the memory, and
typed arrays remove the pause as well as the bytes.
]
#ans[17 MB at 200 K — trivial. 1.7 GB at 20 M — switch to typed arrays (180 MB).]

#ex(11, tier: 1, asked: "Infosys · pattern")[
An LRU cache must fit in 512 MB. Keys are 24-byte strings, values are 180-byte objects,
and the linked-list node overhead is about 80 bytes. How many entries fit? Write the
sizing function.
]
#sol[
*Per entry.*
$ 24 + 180 + 80 = 284 "bytes" $

*Entries.*
$ "512,000,000" / 284 = "1,802,816.9" arrow.r "1,802,816" "entries" $

Round down — a partial entry does not exist. Call it "about 1.8 million".

#code(lang: "js", caption: "cache.js — sizing and the hit rate the database needs")[
```js
function cacheFit({ budgetBytes, keyBytes, valueBytes, overheadBytes = 80 }) {
  const perEntry = keyBytes + valueBytes + overheadBytes;
  return { perEntry, entries: Math.floor(budgetBytes / perEntry) };
}

function neededHitRate({ peakQps, dbMaxQps }) {
  if (dbMaxQps >= peakQps) return 0;          // no cache needed at all
  return 1 - dbMaxQps / peakQps;
}

const c = cacheFit({ budgetBytes: 512e6, keyBytes: 24, valueBytes: 180 });
console.log("per entry :", c.perEntry, "bytes");
console.log("entries   :", c.entries.toLocaleString("en-US"));

for (const [peak, dbMax] of [[3000, 2000], [30000, 2000], [30000, 20000]]) {
  const h = neededHitRate({ peakQps: peak, dbMaxQps: dbMax });
  console.log(`peak ${peak} qps, db can do ${dbMax} -> cache must hit ${(h*100).toFixed(1)}%`);
}

const dbQps = (peak, hit) => Math.round(peak * (1 - hit));
console.log("peak 30,000 qps at 95% hit -> db sees", dbQps(30000, 0.95), "qps");
console.log("peak 30,000 qps at 90% hit -> db sees", dbQps(30000, 0.90), "qps  (2x more!)");
```
]

#code(lang: "text", caption: "node cache.js")[
```text
per entry : 284 bytes
entries   : 1,802,816
peak 3000 qps, db can do 2000 -> cache must hit 33.3%
peak 30000 qps, db can do 2000 -> cache must hit 93.3%
peak 30000 qps, db can do 20000 -> cache must hit 33.3%
peak 30,000 qps at 95% hit -> db sees 1500 qps
peak 30,000 qps at 90% hit -> db sees 3000 qps  (2x more!)
```
]

*The line worth saying out loud:* going from a 95% hit rate to a 90% hit rate does not
make the database 5% busier. It makes it *twice* as busy, because the database only ever
sees the misses, and misses went from 5% to 10%. Cache hit rate is a number about
*misses*, and misses are what you are paying for.
]
#ans[1,802,816 entries at 284 bytes each]

#trap[
A cache miss rate of 5% sounds excellent until you multiply it out. At 30,000 peak QPS
that is 1,500 database reads a second. If your database does 20,000 reads a second you
are fine. If it does 2,000, you are at 75% of the whole database on *misses alone*, and
the first cache restart takes you to 30,000 and kills it. Always compute the miss
traffic, never just quote the hit rate.
]

#ex(12, tier: 1, asked: "Capgemini · pattern")[
A library has 40,000 copies. The `return` operation finds the open loan by scanning a
list of all loans. 300 returns happen per second at the busiest minute. Is the scan
acceptable? Show the CPU arithmetic.
]
#sol[
*Cost of one scan.* A tight loop over an array of objects touches memory at roughly
100 ns per element once you include the pointer chase and the comparison.

$ "40,000" times 100 "ns" = "4,000,000" "ns" = 4 "ms per return" $

*Cost per second of wall clock.*
$ 300 "returns/s" times 4 "ms" = "1,200" "ms of CPU per second" = 1.2 "seconds" $

You need 1.2 seconds of CPU for every 1 second that passes. One core cannot do it. The
event loop falls behind, the queue grows, and latency climbs without limit. This is the
definition of *saturation*.

*The fix and its cost.* Keep `Map<barcode, Loan>` for open loans.

$ "lookup" = O(1) approx 100 "ns, so" 300 times 100 "ns" = 30 "µs of CPU per second" $

$ "1,200,000" "µs" arrow.r 30 "µs" = "40,000" times "less CPU" $

Memory cost of the map: at most 40,000 entries at #sym.approx 85 bytes $= 3.4$ MB. You traded
3.4 MB for 40,000x less CPU.

*The general rule you should state:* a linear scan is fine while
$ "items" times "rate" times 100 "ns" < 0.1 "second of CPU per second" $
which means $"items" times "rate" < "1,000,000"$. Here $"40,000" times 300 = 12$ million,
twelve times over budget. At 40,000 items and 20 returns per second
($= "800,000"$) a scan would have been perfectly fine.
]
#ans[No — 1.2 s of CPU per second. Index it with a Map: 3.4 MB buys a 40,000x saving.]

#trick[
*The items × rate < 1,000,000 rule.* Multiply how many things you scan by how often you
scan them. Under a million, scan away and keep the code simple. Over a million, build
the index. This one inequality answers "should I add a hash map here?" in every LLD
round you will ever sit.
]

#ex(13, tier: 1, asked: "Wipro · pattern")[
Your service handles 2,000 requests per second and each request takes 50 ms end to end.
How many requests are in flight at any instant? Now the database slows down and requests
take 500 ms. What happens to your connection pool of 200?
]
#sol[
This is *Little's Law*, and it is the only queueing formula you need:

$ L = lambda times W $

where $L$ is the number of items in the system, $lambda$ is the arrival rate, and $W$ is
the time each item spends inside.

*Healthy case.*
$ L = "2,000" "req/s" times 0.050 "s" = 100 "requests in flight" $

A pool of 200 connections is comfortable — you use half of it.

*Slow case.* Nothing about arrivals changed. Only $W$ changed.
$ L = "2,000" times 0.500 = "1,000" "requests in flight" $

You need 1,000 connections and you have 200. So 800 requests queue *for a connection*,
on top of the 500 ms they will then wait for the database. Latency does not go from
50 ms to 500 ms; it goes to 500 ms plus the queueing time, and the queue keeps growing
because arrivals never slowed down.

*This is why a small slowdown becomes an outage.* A 10x latency increase caused a 10x
concurrency increase, which blew a fixed-size pool, which turned "slow" into "failing".

#code(lang: "js", caption: "Little's Law and retry amplification — the two numbers that explain most outages")[
```js
const inFlight = (rps, seconds) => rps * seconds;
console.log("2000 rps x  50 ms =", inFlight(2000, 0.050), "in flight");
console.log("2000 rps x 500 ms =", inFlight(2000, 0.500), "in flight");

const amplify = layers => Math.pow(3, layers);      // 3 attempts at each layer
console.log("3 tries at each of 3 layers =", amplify(3), "x the original load");
console.log("1,000 rps of real traffic becomes", 1000 * amplify(3), "rps in an incident");
```
]
#code(lang: "text", caption: "node little.js")[
```text
2000 rps x  50 ms = 100 in flight
2000 rps x 500 ms = 1000 in flight
3 tries at each of 3 layers = 27 x the original load
1,000 rps of real traffic becomes 27000 rps in an incident
```
]

*The fix, and the decision.* Two options:

- *Grow the pool to 1,000.* Cheap to type. But now 1,000 connections hit a database that
  was already slow, and connection memory on the database side is real
  ($"1,000" times$ a few MB). You have moved the queue, not removed it.
- *Keep the pool at 200 and fail fast* — a 200 ms timeout on acquiring a connection,
  then return 503 and shed load.

*Decision: keep the pool small and shed load.* A bounded pool is a bulkhead. It means a
slow database makes 15% of requests fail quickly instead of making 100% of requests hang.
Fast failure is recoverable; a growing queue is not.
]
#ans[100 in flight healthy, 1,000 when slow. Bound the pool and shed load.]

#ex(14, tier: 1, asked: "Cognizant · pattern")[
You must store 20 million integer sensor readings in a Node process. Compare a plain
`Array` with an `Int32Array`. Which do you pick and when does the choice stop mattering?
]
#sol[
From the measured card: `Array` of small integers is 8 bytes per element,
`Int32Array` is exactly 4.

$ "Array:" quad "20,000,000" times 8 = "160,000,000" "bytes" = 160 "MB" $
$ "Int32Array:" quad "20,000,000" times 4 = "80,000,000" "bytes" = 80 "MB" $

Half the memory. But memory is not the real win.

*The real win is the garbage collector.* An `Int32Array` is one buffer outside the
JavaScript heap. The collector treats it as a single object. A plain `Array` of 20
million slots is 20 million things the collector must consider on a major collection.
That is what turns into a 200 ms pause that your p99 latency notices.

*When does the choice stop mattering?* Below about 100,000 elements:
$ "100,000" times 8 = 800 "KB versus" "100,000" times 4 = 400 "KB" $
A 400 KB difference is not worth losing `push`, `map`, `filter` and holes.

*Decision:* plain `Array` under 100,000 elements, `Int32Array` (or `Float64Array`)
above about 1 million. Between the two, pick whichever the surrounding code makes
cleaner, because neither number will ever appear in a bug report.
]
#ans[160 MB vs 80 MB. Typed array above #sym.approx 1 M elements, mostly for GC, not bytes.]

#practice(tier: 1, time: "18 min")[
+ A `Map<int, object>` holds 5 million entries, each object has four small fields.
  Memory, using the measured 85 bytes per entry?
+ A service does 600 requests per second and each takes 120 ms. How many are in flight?
  Is a pool of 50 enough?
+ You scan a list of 200,000 items on every call, 500 calls per second. Seconds of CPU
  per second? Does it pass the `items × rate < 1,000,000` rule?
+ 20 million integers: `Array` vs `Int32Array` in MB?
+ An in-memory seat map holds 5,000 shows × 200 seats, each seat 40 bytes. Total?
+ A cache budget is 2 GB, entries are 24 B key + 400 B value + 80 B overhead. Entries?
]

#key[
*1.* $"5,000,000" times 85 = "425,000,000"$ B $= 425$ MB. Fits in one Node process, but
it is over a third of a 1 GB container — size the container at 2 GB.

*2.* $L = 600 times 0.120 = 72$ in flight. A pool of 50 is *not* enough — 22 requests
queue at all times. Size it to at least 100, or cut the 120 ms.

*3.* $"200,000" times 100 "ns" = 20$ ms per call. $500 times 20 "ms" = "10,000"$ ms
$= 10$ seconds of CPU per second. You would need 10 cores just for the scan.
The rule: $"200,000" times 500 = 100$ million, which is 100x over the one-million
budget. Index it.

*4.* $"20,000,000" times 8 = 160$ MB against $"20,000,000" times 4 = 80$ MB.

*5.* $"5,000" times 200 = "1,000,000"$ seats. $"1,000,000" times 40 = "40,000,000"$ B
$= 40$ MB. Trivially in memory — which is exactly why a cinema booking system can hold
the whole seat map in Redis.

*6.* Per entry $24 + 400 + 80 = 504$ B.
$"2,000,000,000" \/ 504 = "3,968,253"$ entries, so "about 4 million".
]

#section[Tier 2 — estimating one real service]
#tier-header(2)

Now the numbers get big enough to change the architecture. Each example below is a full
step-2 of the seven steps: the arithmetic, and then the *one sentence* about what it
decided.

#ex(15, tier: 2, asked: "Shopee · pattern")[
*A photo-sharing feature.* 8 million daily users in one country. Each uploads 0.4 photos
a day and views 60 photos a day. An upload is stored at 500 KB plus a 100 KB thumbnail
set. A viewed photo sends about 150 KB over the wire (mostly thumbnails). Produce the
full step-2.
]
#sol[
*Line 1 — traffic.*

Uploads:
$ "8,000,000" times 0.4 = "3,200,000" "uploads/day" $
$ "3,200,000" / "86,400" = 37.0 "uploads/s average" $
Photo uploads cluster hard in the evening, so use 4x:
$ 37.0 times 4 = 148 "uploads/s at peak" $

Views:
$ "8,000,000" times 60 = "480,000,000" "views/day" $
$ "480,000,000" / "86,400" = "5,555.6" "views/s average" $
$ "5,555.6" times 3 = "16,667" "views/s at peak" $

*The read:write ratio* is $60 \/ 0.4 = 150 : 1$. Say that out loud. It immediately
justifies every cache and every read replica you are about to draw.

*Line 2 — storage.*
$ 500 "KB" + 100 "KB" = 600 "KB stored per upload" $
$ "3,200,000" times "600,000" = 1.92 times 10^12 "bytes" = 1.92 "TB/day" $
$ 1.92 times 365 = 700.8 "TB/year" $

*Line 3 — bandwidth (this is the number that decides the architecture).*
$ "16,667" "views/s" times "150,000" "bytes" = 2.5 times 10^9 "bytes/s" = "2,500" "MB/s" $
$ "2,500" times 8 = "20,000" "Mbps" = 20 "Gbps at peak" $

*Line 4 — memory.* The hot set is "photos posted in the last 24 hours", roughly
3.2 million objects of metadata at #sym.approx 400 B:
$ "3,200,000" times 400 = 1.28 "GB" $
Metadata cache: one small Redis node. The *images* are not cached in Redis; they are
cached in the CDN.

*Line 5 — machines.* At 95% CDN offload the origin serves 5% of the bytes:
$ 20 "Gbps" times 0.05 = 1 "Gbps at origin" $
and the API (metadata only, #sym.approx 2 KB responses) at 16,667 QPS with 800 QPS per server:
$ "16,667" / 800 times 1.5 = 31.3 arrow.r 32 "API servers" $

*The closing sentence.* "700 TB a year means object storage, not a database — the
database stores 400-byte metadata rows, roughly
$"3,200,000" times 400 times 365 = 467$ GB a year, which is one ordinary Postgres box.
20 Gbps of egress means a CDN is mandatory, not optional: without it I need 16 ten-gigabit
links at the origin. So the binding constraint here is *bandwidth*, and the whole design
is 'metadata in Postgres, bytes in object storage, delivery by CDN'."
]
#ans[3.2 M uploads/day · 16,700 views/s peak · 1.92 TB/day · 20 Gbps peak · CDN mandatory]

#diagram(height: 4.8cm, caption: "The same service with the numbers written on it. This is what the board should look like after step 2 and step 5.")[
  #dnode(0cm, 1.55cm, 2.4cm, 0.95cm, "Client\n8 M DAU")
  #dnode(3.2cm, 1.55cm, 2.4cm, 0.95cm, "Load\nbalancer")
  #dnode(6.4cm, 1.55cm, 2.8cm, 0.95cm, "API × 32\n16,700 qps", fill: rgb("#dce9f2"))
  #dnode(10.0cm, 0.15cm, 2.8cm, 0.95cm, "Redis\n1.3 GB", fill: rgb("#f7efe4"))
  #dnode(13.6cm, 0.15cm, 3.0cm, 0.95cm, "Postgres\n467 GB/yr")
  #dnode(13.6cm, 1.55cm, 3.0cm, 0.95cm, "read replica\n×2")
  #dnode(6.4cm, 3.35cm, 2.8cm, 0.95cm, "CDN\n19 Gbps", fill: rgb("#f0dede"))
  #dnode(10.0cm, 3.35cm, 2.8cm, 0.95cm, "Object store\n700 TB/yr", fill: rgb("#f7efe4"))

  #darrow(2.4cm, 2.02cm, 3.2cm, 2.02cm)
  #darrow(5.6cm, 2.02cm, 6.4cm, 2.02cm, label: "2 KB json")
  #darrow(9.2cm, 1.7cm, 10.0cm, 0.9cm, label: "93% hit")
  #darrow(12.8cm, 0.62cm, 13.6cm, 0.62cm, label: "miss")
  #darrow(15.1cm, 1.1cm, 15.1cm, 1.55cm)
  #darrow(1.2cm, 2.5cm, 6.4cm, 3.6cm, dashed: true, label: "images 20 Gbps")
  #darrow(9.2cm, 3.82cm, 10.0cm, 3.82cm, label: "5% miss")
  #darrow(7.8cm, 2.5cm, 10.6cm, 3.35cm, label: "148 uploads/s")
]

#ex(16, tier: 2, asked: "Grab · pattern")[
*A chat service.* 5 million daily users, 40 messages sent per user per day. A stored
message row is 500 bytes. At peak, 20% of daily users hold an open connection. One
machine holds 80,000 connections. Produce step-2 and say how many connection servers.
]
#sol[
*Line 1 — traffic.*
$ "5,000,000" times 40 = "200,000,000" "messages/day" $
$ "200,000,000" / "86,400" = "2,314.8" "messages/s average" $
$ "2,314.8" times 3 = "6,944" "messages/s at peak" $

*But that is only the send side.* Every message in a 1:1 chat is *delivered* once and
usually read once, and group chats multiply it. Take an average delivery fan-out of 2:
$ "6,944" times 2 = "13,889" "delivery pushes/s at peak" $

*Line 2 — storage.*
$ "200,000,000" times 500 = "100,000,000,000" "bytes" = 100 "GB/day" $
$ 100 times 365 = "36,500" "GB" = 36.5 "TB/year" $
Five years at RF 3:
$ 36.5 times 5 times 3 = 547.5 "TB of raw disk" $

*Line 3 — bandwidth.* A message on the wire is small, say 300 B including framing:
$ "13,889" times 300 = "4,166,700" "bytes/s" approx 4.2 "MB/s" = 33 "Mbps" $
Bandwidth is a non-issue. Do not spend a minute on it — say so and move on.

*Line 4 — connections.* This is the interesting number for chat.
$ "5,000,000" times 0.20 = "1,000,000" "concurrent connections at peak" $
$ "1,000,000" / "80,000" = 12.5 arrow.r 13 "connection servers" $

But a chat connection server holds *state* (which user is on which box), so losing one
matters. Size to survive losing one availability zone out of three, which means the
remaining two zones must carry everything:
$ 13 / (2\/3) = 19.5 arrow.r 20 "servers", "spread 7 / 7 / 6" $

*Memory per connection.* 1,000,000 connections over 13 boxes is 77,000 each. At roughly
20 KB of kernel and userspace buffers per socket:
$ "80,000" times "20,000" = 1.6 times 10^9 "bytes" = 1.6 "GB just for sockets" $
So a connection server needs 8 GB, not 2 GB. That is a real, specific requirement, and
it comes straight out of the arithmetic.

*The closing sentence.* "The binding constraint for chat is not QPS — 6,944 writes a
second is four database shards at 5,000 writes each with room to spare. It is the
*million open connections*, which is 20 stateful machines and a routing table that says
which machine holds which user. That routing table is the thing I would deep-dive."
]
#ans[6,944 msg/s peak · 36.5 TB/yr · 1 M connections · 20 connection servers]

#trap[
Do not compute a chat service's connection count from *daily* users directly. "5 million
DAU means 5 million connections" is wrong by 5x and it inflates the design into
something absurd. Concurrency is DAU times the fraction online *at the same moment*.
For a consumer messaging app, 15--25% at the evening peak is a defensible assumption.
State the fraction you are using, and why.
]

#ex(17, tier: 2, asked: "Agoda · pattern")[
*Driver location pings.* 200,000 drivers are online at peak. Each phone sends its
position every 4 seconds. A ping is 60 bytes. How many writes per second? How much
storage if you keep every raw ping? Decide a retention policy.
]
#sol[
*Writes per second.*
$ "200,000" "drivers" \/ 4 "seconds" = "50,000" "writes/s" $

This is a *huge* number and it arrives with no user pressing anything. Compare it with
the actual business events: maybe 3,000 ride requests a minute $= 50$ per second. The
telemetry is 1,000x the business traffic.

*Storage if you keep everything.*
$ "200,000" times "86,400" \/ 4 = "4,320,000,000" "pings/day" $
$ "4,320,000,000" times 60 = "259,200,000,000" "bytes" = 259.2 "GB/day" $
$ 259.2 times 365 = "94,608" "GB" = 94.6 "TB/year" $
At RF 3: $94.6 times 3 = 284$ TB a year, for data nobody reads after five minutes.

*Bandwidth.*
$ "50,000" times 60 = "3,000,000" "bytes/s" = 3 "MB/s" = 24 "Mbps" $
Tiny. The problem is *write operations*, not bytes.

*The decision, with both sides named.*

#table(columns: (1fr, 1fr),
  [*Keep every ping forever*], [*Keep the latest only, plus a downsample*],
  [replay any incident perfectly, any dispute answerable], [7 days raw, then 1 point per minute],
  [284 TB/year of disk and the backups to match], [$259.2 times 7 = 1.81$ TB raw window],
  [50,000 durable writes/s needs #sym.approx 10 database shards], [current position in Redis: 1 node does 100,000 ops/s],
)

*Decision: current position in Redis, raw pings to a 7-day log, then downsample to one
point per minute.*

Downsampled volume:
$ "200,000" times 1440 "minutes" = "288,000,000" "points/day" $
$ "288,000,000" times 60 = 17.3 "GB/day" = 6.3 "TB/year" $

$ 94.6 "TB/yr" arrow.r 6.3 "TB/yr" = 15 times "less" $

The reason: 99.9% of reads want *one* value — "where is driver 8812 right now?" — and
that is a single Redis key. History is a compliance and analytics need, and analytics is
happy with one point per minute. Paying 15x for a resolution nobody queries is the wrong
trade.
]
#ans[50,000 writes/s · 259 GB/day raw · keep current in Redis, 7-day raw, then downsample to 6.3 TB/yr]

#ex(18, tier: 2, asked: "DBS · pattern")[
*Catalogue reads.* Peak is 30,000 reads per second. One database replica serves 2,000
reads per second. Two choices: add replicas, or add a cache. Compute both and decide.
]
#sol[
*Option A — replicas only.*
$ "30,000" / "2,000" = 15 "replicas" $
With 1.5x headroom: $15 times 1.5 = 22.5 arrow.r 23$ replicas.

Each replica is a full copy of the data. If the catalogue is 800 GB:
$ 23 times 800 "GB" = 18.4 "TB of disk" $
And every write must be shipped to 23 machines, so replication lag gets worse as you add
replicas — the exact opposite of what you wanted.

*Option B — cache in front.* Required hit rate so the database sees at most 2,000:
$ "hit rate" = 1 - "2,000" / "30,000" = 1 - 0.0667 = 93.3% $

Is 93.3% realistic? Catalogue traffic is extremely skewed — a small number of products
get most of the views. Suppose 2 million products are "hot" and a row is 1.5 KB:
$ "2,000,000" times "1,500" = "3,000,000,000" "bytes" = 3 "GB" $

3 GB fits in one Redis node with a replica. So: 2 machines instead of 23.

*The numbers side by side.*
#table(columns: (auto, 1fr, 1fr),
  [], [*A: 23 replicas*], [*B: Redis + 2 replicas*],
  [machines], [23 database boxes], [2 Redis + 2 database],
  [disk], [18.4 TB], [3 GB memory + 1.6 TB disk],
  [reads at database], [30,000/s], [2,000/s],
  [failure if cache dies], [n/a], [30,000/s at 2 replicas — *it dies*],
  [staleness], [replication lag, #sym.approx 100 ms], [TTL, up to 60 s],
)

*Decision: Option B, with two protections.*

+ *Request coalescing.* When 5,000 requests miss the same key at once, only one goes to
  the database and the rest wait for its answer. Without this, one expired hot key sends
  5,000 simultaneous queries. With it, it sends 1.
+ *Enough replicas to survive a cold cache in a degraded mode.* Not 23 — that defeats
  the point — but 4, plus a rule that on a cold start the service serves a reduced
  catalogue (top 10,000 products) until the cache warms. Say this out loud; "what
  happens when the cache is empty" is the follow-up you will get.

*Why B and not A:* the access pattern is heavily skewed, and a cache is the correct tool
for skew. 23 replicas pay full price for every product, including the 90% of the
catalogue that is read once a week.
]
#ans[A = 23 replicas, 18.4 TB. B = one 3 GB Redis at 93.3% hit. Choose B + coalescing + 4 replicas.]

#ex(19, tier: 2, asked: "SCB · pattern")[
Turn the photo service of Example 15 into a monthly bill. CDN egress costs
\$0.02 per GB, object storage \$0.02 per GB-month, an application server \$60 a month.
Is bandwidth or storage the bigger line?
]
#sol[
*Egress.* Average (not peak) is what you are billed on.
$ "480,000,000" "views/day" times "150,000" "B" = 7.2 times 10^13 "bytes/day" = "72,000" "GB/day" $
$ "72,000" times 30 = "2,160,000" "GB/month" $
$ "2,160,000" times \$0.02 = \$"43,200" "/month" $

*Storage.* By the end of month 12 you are holding
$1.92 "TB/day" times 365 = 700.8$ TB.
$ "700,800" "GB" times \$0.02 = \$"14,016" "/month, and rising every month" $

*Servers.* 32 API servers:
$ 32 times \$60 = \$"1,920" "/month" $

#table(columns: (1fr, auto, auto),
  [*Line*], [*Per month*], [*Share*],
  [CDN egress], [\$43,200], [73%],
  [object storage (end of year 1)], [\$14,016], [24%],
  [application servers], [\$1,920], [3%],
  [*total*], [*\$59,136*], [],
)

*What the bill tells you to work on.* Not the servers. Three-quarters of the money is
bytes leaving the building. So the highest-value engineering is:

+ *Serve smaller images.* Going from 150 KB to 100 KB per view is a 33% cut:
  $\$"43,200" times 0.67 = \$"28,944"$, saving \$14,256 a month. Modern formats routinely
  do that.
+ *Raise the CDN hit rate.* Origin egress is usually charged more than CDN egress; every
  point of hit rate moves bytes to the cheaper meter.
+ *Lifecycle old photos to cold storage.* Photos older than 90 days are viewed rarely.
  Cold tiers cost roughly a quarter as much per GB.

*The interview sentence:* "Cost follows bytes, not requests. I would spend my first
engineering week on image size, because a 33% size reduction is worth more than deleting
the entire server fleet."
]
#ans[#sym.approx \$59 K/month; egress is 73% of it. Optimise image size first.]

#practice(tier: 2, time: "30 min")[
+ A messaging app has 4 million DAU sending 25 messages each per day. Rows are 400 B.
  Give messages/s average and peak (3x), GB/day and TB/year.
+ 150,000 drivers ping every 5 seconds. Writes per second?
+ Peak is 12,000 reads/s and one database does 4,000. What cache hit rate do you need?
+ A video service has 2 million DAU watching 20 minutes a day at 1.5 Mbps. Give the
  bytes delivered per day, the average and 3x peak egress in Gbps, and the CDN bill at
  \$0.02/GB.
+ A feed API returns 20 items of 300 B each plus 1 KB of envelope. At 25,000 peak QPS,
  what is the egress in Gbps?
+ A service is 95% reads. If you cache and get a 90% hit rate, by what factor does
  database read load drop?
]

#key[
*1.* $"4,000,000" times 25 = "100,000,000"$/day.
$"100,000,000" \/ "86,400" = "1,157"$/s average; $times 3 = "3,472"$/s peak.
$"100,000,000" times 400 = 40$ GB/day; $40 times 365 = "14,600"$ GB $= 14.6$ TB/year.

*2.* $"150,000" \/ 5 = "30,000"$ writes/s. Compare with "how many rides start per second"
— telemetry dwarfs business traffic, so it belongs in a different store.

*3.* $1 - "4,000"\/"12,000" = 1 - 0.333 = 66.7%$. Easy to hit — this is a case where a
modest cache removes the need for any replicas at all.

*4.* Seconds of video: $"2,000,000" times 20 times 60 = 2.4 times 10^9$ s/day.
Bits: $2.4 times 10^9 times 1.5 times 10^6 = 3.6 times 10^15$ bits/day.
Bytes: $3.6 times 10^15 \/ 8 = 4.5 times 10^14 = 0.45$ PB/day.
Average: $3.6 times 10^15 \/ "86,400" = 4.17 times 10^10$ bps $= 41.7$ Gbps; peak
$times 3 = 125$ Gbps.
Bill: $"450,000"$ GB/day $times \$0.02 = \$"9,000"$/day $approx \$"270,000"$/month.

*5.* Response $= 20 times 300 + "1,000" = "7,000"$ B.
$"25,000" times "7,000" = 1.75 times 10^8$ B/s $= 175$ MB/s $times 8 = 1.4$ Gbps.

*6.* The database sees only misses, so load drops from 100% to 10% of reads — a factor
of *10*. Note it is $1\/(1-h)$, not $1\/h$: at 99% it would be 100x.
]

#section[Tier 3 — estimation at large scale]
#tier-header(3)

At this tier the arithmetic is the same. What changes is that the numbers start
*forbidding* designs. A Tier-3 estimate ends with "and that is why the obvious approach
is impossible".

#ex(20, tier: 3, asked: "Google · pattern")[
*Video streaming egress.* 30 million daily users watch 45 minutes a day at an average
2.5 Mbps. Compute bytes per day, average and peak egress, and the CDN bill at
\$0.02/GB. Then say what the number forbids.
]
#sol[
*Step 1 — seconds of video delivered per day.*
$ "30,000,000" times 45 "min" times 60 = "81,000,000,000" "seconds of video/day" $

That is 81 billion seconds — about 2,570 years of video every day. Worth saying; it
makes the scale land.

*Step 2 — bits per day.*
$ 81 times 10^9 "s" times 2.5 times 10^6 "bits/s" = 2.025 times 10^17 "bits/day" $

*Step 3 — bytes per day.*
$ 2.025 times 10^17 / 8 = 2.53 times 10^16 "bytes/day" = 25.3 "PB/day" $

*Step 4 — average egress rate.*
$ 2.025 times 10^17 / "86,400" = 2.34 times 10^12 "bits/s" = 2.34 "Tbps" $

*Step 5 — peak.* Evening peak, one region, 3x:
$ 2.34 times 3 = 7.03 "Tbps at peak" $

*Step 6 — the bill.*
$ 25.3 "PB/day" = "25,312,500" "GB/day" $
$ "25,312,500" times \$0.02 = \$"506,250" "per day" $
$ \$"506,250" times 365 = \$"184,781,250" "per year" $

*What the number forbids.*

+ *It forbids a commercial CDN as the only answer.* \$185 million a year for delivery
  alone is larger than most companies' entire revenue. This is precisely why large video
  companies build their own caching boxes and place them inside internet providers.
  Making that point is the whole reason the interviewer asked.
+ *It forbids a single origin region.* 7 Tbps at peak is 700 ten-gigabit links running
  flat out. No single building takes that. Delivery must be distributed and near users.
+ *It makes bitrate the most valuable engineering lever in the company.* Cutting the
  average bitrate from 2.5 to 2.0 Mbps is a 20% cut:
  $ \$184.8 "M" times 0.8 = \$147.8 "M, a saving of" \$37 "M a year" $
  A better codec is worth more than the entire infrastructure team.

*The closing sentence.* "Storage here is almost free by comparison — the *catalogue* is
maybe a petabyte and it is written once. The constraint is egress, and egress is a
physical and commercial problem, not a software one. So my design spends its effort on
caching close to the user and on adaptive bitrate, not on the database."
]
#ans[25.3 PB/day · 2.34 Tbps average · 7 Tbps peak · #sym.approx \$185 M/year on a commercial CDN]

#ex(21, tier: 3, asked: "Amazon · pattern")[
*Feed fan-out.* 400 million daily users. 100 million posts a day. The average author has
300 followers. If every post is copied into every follower's inbox, compute the write
load. Then compute what one celebrity with 50 million followers does, and decide the
strategy.
]
#sol[
*Step 1 — inbox writes per day.*
$ "100,000,000" "posts" times 300 "followers" = 3.0 times 10^10 "inbox rows/day" $

Thirty billion rows a day, from only 100 million user actions. The fan-out multiplied
the write load by 300.

*Step 2 — writes per second.*
$ 3.0 times 10^10 / "86,400" = "347,222" "writes/s average" $
$ "347,222" times 3 = "1,041,667" "writes/s at peak" $

*Step 3 — can the storage take it?* A key-value store node absorbs about 5,000 durable
writes a second.
$ "1,041,667" / "5,000" = 208 "nodes" $
With 1.5x headroom: $208 times 1.5 = 312$ nodes, purely for inbox writes.

*Step 4 — storage.* An inbox row is ids only, about 60 bytes.
$ 3.0 times 10^10 times 60 = 1.8 times 10^12 "bytes" = 1.8 "TB/day" $
Keep 30 days of inbox:
$ 1.8 times 30 = 54 "TB" times 3 "(RF)" = 162 "TB" $
Storage is not the problem. Write *rate* is.

*Step 5 — the celebrity.* One post by an account with 50 million followers:
$ "50,000,000" "writes from one button press" $
At the cluster's peak capacity of 1,041,667 writes/s, and assuming this post could use
the entire cluster:
$ "50,000,000" / "1,041,667" = 48 "seconds" $

Forty-eight seconds during which the cluster does *nothing else*. And celebrities do not
post alone — ten of them posting in the same minute is 500 million writes, over eight
minutes of total cluster time, while 400 million ordinary users get nothing.

*The decision: hybrid fan-out.*

#table(columns: (auto, 1fr, 1fr),
  [], [*push (fan-out on write)*], [*pull (fan-out on read)*],
  [when], [author has $<$ 10,000 followers], [author has $>=$ 10,000 followers],
  [read cost], [one range scan of your inbox], [merge your inbox with $k$ celebrity timelines],
  [write cost], [300 rows per post], [1 row per post],
  [who it fits], [99.9% of accounts], [the few thousand huge accounts],
)

*The arithmetic that proves the hybrid works.* Suppose accounts above 10,000 followers
produce 1% of posts but hold 60% of the follower edges. Then push traffic becomes:
$ 3.0 times 10^10 times (1 - 0.60) = 1.2 times 10^10 "rows/day" $
$ 1.2 times 10^10 / "86,400" times 3 = "416,667" "writes/s at peak" $
$ "416,667" / "5,000" times 1.5 = 125 "nodes" $

$ 312 "nodes" arrow.r 125 "nodes" = 2.5 times "cheaper" $

And the read cost rises by a bounded amount: a user follows at most a handful of huge
accounts, so a feed read becomes one inbox scan plus (say) up to 20 timeline reads, all
of them cached, all of them in parallel. That is a latency cost of one extra round trip,
about 1 ms, against a 2.5x hardware saving and the removal of a 48-second stall.

*Decision: hybrid, with the threshold set by measurement, not by taste.* Start at 10,000
followers, watch the p99 of feed reads, and move the threshold until reads and writes
cost about the same.
]
#ans[30 B rows/day, 1.04 M writes/s peak, 312 nodes. Hybrid cuts it to 125 and removes the 48 s stall.]

#diagram(height: 4.6cm, caption: "Fan-out amplification. One button press on the left becomes N writes on the right — the number that breaks naive feed designs.")[
  #dnode(0cm, 1.6cm, 3.0cm, 0.95cm, "1 post written\n(100 M/day)", fill: rgb("#dce9f2"))
  #dnode(4.2cm, 1.6cm, 3.2cm, 0.95cm, "fan-out worker")
  #dnode(8.8cm, 0.10cm, 3.4cm, 0.62cm, "inbox: follower 1")
  #dnode(8.8cm, 0.88cm, 3.4cm, 0.62cm, "inbox: follower 2")
  #dnode(8.8cm, 1.66cm, 3.4cm, 0.62cm, "…")
  #dnode(8.8cm, 2.44cm, 3.4cm, 0.62cm, "inbox: follower 300")
  #dnode(13.0cm, 0.88cm, 3.5cm, 1.2cm, "30 billion\nrows/day\n1.04 M writes/s peak", fill: rgb("#f0dede"))

  #dnode(0cm, 3.5cm, 7.4cm, 0.8cm, "celebrity: 50,000,000 followers, one post", fill: rgb("#f7efe4"))
  #dnode(8.8cm, 3.5cm, 7.7cm, 0.8cm, "= 48 seconds of the entire cluster", fill: rgb("#f0dede"))

  #darrow(3.0cm, 2.07cm, 4.2cm, 2.07cm)
  #darrow(7.4cm, 1.9cm, 8.8cm, 0.41cm)
  #darrow(7.4cm, 1.95cm, 8.8cm, 1.19cm)
  #darrow(7.4cm, 2.07cm, 8.8cm, 1.97cm, label: "×300")
  #darrow(7.4cm, 2.2cm, 8.8cm, 2.75cm)
  #darrow(12.2cm, 1.5cm, 13.0cm, 1.5cm)
  #darrow(7.4cm, 3.9cm, 8.8cm, 3.9cm)
]

#ex(22, tier: 3, asked: "Microsoft · pattern")[
*How many shards?* A dataset grows 36.5 TB a year and you plan for five years. One shard
holds 2 TB of usable data. Peak write load is 1,041,667 writes/s. Choose the shard count
and justify the number you pick.
]
#sol[
*From storage.*
$ 36.5 times 5 = 182.5 "TB in five years" $
$ 182.5 / 2 = 91.25 arrow.r 92 "shards" $

*From write throughput.* One shard node does 5,000 durable writes/s:
$ "1,041,667" / "5,000" = 208.3 arrow.r 209 "shards" $

*Take the larger.* Throughput needs 209, storage needs 92. Shard count is
$max(92, 209) = 209$. Add 1.5x headroom: $209 times 1.5 = 313.5$.

*Now round to a power of two: 512.* Here is why that specific rounding, and it is worth
saying:

+ *Splitting is halving.* If shard count is a power of two and you route by
  `hash(key) mod 2^k`, then doubling from $2^k$ to $2^(k+1)$ moves exactly half of each
  shard's keys, and each key moves to exactly one new shard. With 313 shards, growing to
  314 re-maps almost every key in the cluster.
+ *`mod` on a power of two is a bit mask.* $h "mod" 512 = h "and" 511$. Free.
+ *It leaves room.* 512 shards at 2 TB each is 1,024 TB of capacity — over five times
  what five years needs — and 512 at 5,000 writes/s is 2.56 million writes/s, about 2.5x
  peak.

*Check it is not absurd.* 512 shards is not 512 machines. A machine can host 4--8 shards.
$ 512 / 8 = 64 "machines" $
64 machines to hold 182 TB and take a million writes a second is entirely reasonable.

*The alternative, named and rejected.* Virtual nodes with consistent hashing let you use
any count and add one node at a time. That is genuinely better for smooth growth. It
costs a routing table that every client must know and keep fresh, plus the operational
work of rebalancing ranges. *Decision: fixed 512 logical shards mapped onto a variable
number of physical machines.* You get the cheap `mod`, you get rebalancing by moving
whole logical shards (which is a file copy, not a key-by-key migration), and you can grow
machines one at a time even though the shard count never changes. Consistent hashing
solves a problem — arbitrary shard counts — that you chose not to have.
]
#ans[92 by storage, 209 by throughput; take 209, add headroom, round to 512 logical shards on #sym.approx 64 machines]

#ex(23, tier: 3, asked: "Uber · pattern")[
*Tail latency amplification.* A search request fans out to 50 shards and must wait for
all of them. Each shard answers within 20 ms 99% of the time. What fraction of requests
take longer than 20 ms? What do you do about it?
]
#sol[
*The probability.* The request is fast only if *every* shard is fast. Assuming the shards
are independent:

$ P("all 50 fast") = 0.99^50 $

Compute it step by step. $0.99^10 = 0.9044$. Then
$0.99^50 = (0.99^10)^5 = 0.9044^5 = 0.6050$.

$ P("at least one slow") = 1 - 0.6050 = 0.395 = bold(39.5%) $

*Read that again.* Every single shard is a 99th-percentile-20-ms component, which sounds
excellent, and yet *four requests in ten* are slow. The p99 of one shard has become
roughly the p60 of the whole request.

#code(lang: "js", caption: "tail.js — how fan-out turns a good p99 into a bad one")[
```js
const atLeastOneSlow = (n, pFast) => 1 - Math.pow(pFast, n);

console.log("shards   chance the whole request is slow (each shard p99 = 20 ms)");
for (const n of [1, 5, 10, 20, 50, 100])
  console.log(String(n).padStart(6), "  ", (atLeastOneSlow(n, 0.99) * 100).toFixed(1) + "%");

console.log("\nsame fan-out, but each shard is p99.9 instead:");
for (const n of [10, 50, 100])
  console.log(String(n).padStart(6), "  ", (atLeastOneSlow(n, 0.999) * 100).toFixed(1) + "%");
```
]
#code(lang: "text", caption: "node tail.js")[
```text
shards   chance the whole request is slow (each shard p99 = 20 ms)
     1    1.0%
     5    4.9%
    10    9.6%
    20    18.2%
    50    39.5%
   100    63.4%

same fan-out, but each shard is p99.9 instead:
    10    1.0%
    50    4.9%
   100    9.5%
```
]

*The three fixes, with numbers.*

+ *Reduce the fan-out.* 50 shards to 10 takes the slow fraction from 39.5% to 9.6%.
  Route by a key that lets you touch fewer shards. This is the cheapest fix and it is a
  *data model* decision, made in step 4, not a latency patch.
+ *Improve each shard's p99 to p99.9.* At 50 shards that takes 39.5% down to 4.9% — an
  8x improvement. This means fixing garbage-collection pauses, slow disks, and noisy
  neighbours. Expensive and slow, but it is the only fix that helps every query shape.
+ *Hedged requests.* Send to the shard; if no answer in 15 ms, send a second copy to a
  replica and take whichever returns first. Extra load is bounded by the fraction that
  are slow — under 5% more traffic — and the slow fraction collapses, because both copies
  must be slow for the request to be slow:
  $ 0.01 times 0.01 = 0.0001 "per shard, so" 1 - 0.9999^50 = 0.5% $

*Decision: do 1 and 3 now, 2 continuously.* Cut the fan-out in the data model because it
is free; add hedging because it is a small amount of code and buys an 80x improvement;
and treat per-shard p99.9 as an ongoing engineering programme, not an interview answer.
]
#ans[39.5% of requests are slow. Cut fan-out, hedge after 15 ms, and drive each shard to p99.9.]

#trick[
*The fan-out rule you can quote instantly:* if each of $n$ components is fast with
probability $p$, the whole request is fast with probability $p^n$. For $n$ around
$1\/(1-p)$ you lose about a third of your requests. So "p99 per shard" is only safe up
to about 10 shards. Beyond that you need p99.9, or hedging, or a smaller fan-out.
]

#ex(24, tier: 3, asked: "Goldman Sachs · pattern")[
*The retry storm.* A client retries 3 times. It calls an API gateway that retries 3
times. The gateway calls a service that retries 3 times against the database. Normal
traffic is 1,000 requests per second. What does the database see during a partial
outage, and what is the correct retry policy?
]
#sol[
*The amplification.* Each layer multiplies.
$ 3 times 3 times 3 = 3^3 = 27 times $

$ "1,000" "req/s" times 27 = "27,000" "req/s at the database" $

*Why this is a doom loop.* The database was slow because it was at its limit. The retries
make it 27 times more loaded, so it gets slower, so more requests time out, so more
retries fire. The system cannot recover even after the original cause is gone, because
the retries are now the cause. Engineers call this *metastable failure*: the system has
two stable states, "working" and "melted", and a small push moves it from one to the other
with no path back except turning traffic off.

*The correct policy, with the arithmetic for each rule.*

#table(columns: (auto, 1fr),
  [*Retry at one layer only*],
    [Pick the layer closest to the user that has the context to retry safely — usually the
     gateway. $3 times 1 times 1 = 3$x instead of 27x. A 9x reduction from one rule.],
  [*Cap total attempts at 3 and budget them*],
    [Give the whole request a 2 s budget. If 1.4 s is gone, do not start a retry that
     needs 1 s. Retries that cannot finish are pure waste.],
  [*Exponential backoff with full jitter*],
    [`delay = random(0, base × 2^attempt)`. Without jitter, 10,000 clients that failed
     together retry together, producing a spike exactly as large as the original one.],
  [*A retry budget: at most 10% of traffic may be retries*],
    [Track the ratio. Above 10%, stop retrying entirely and fail fast.
     $"1,000" times 1.1 = "1,100"$ req/s worst case, instead of 27,000. That is a *24x*
     reduction against the naive design.],
  [*Circuit breaker*],
    [After $N$ consecutive failures, stop calling for 30 seconds and fail immediately.
     This gives the database an idle window to catch up, which is the only thing that
     actually ends the storm.],
)

*The decision, stated plainly.* Retry once, at the gateway, with jittered backoff, inside
a 10% budget, behind a circuit breaker. That turns a 27x amplifier into a 1.1x one.

*The trade-off, named honestly.* Retrying less means more requests fail during a small,
genuinely transient glitch — the user sees an error that a retry would have hidden. That
is the price. It is worth paying, because the alternative is that a 30-second glitch
becomes a 3-hour outage. *Choose a few visible failures over a metastable collapse.*
]
#ans[27,000 req/s — 27x. Retry at one layer, jittered, inside a 10% budget, behind a breaker: 1.1x.]

#ex(25, tier: 3, asked: "Adobe · pattern")[
*Cross-region replication.* A region takes 200,000 writes per second, each 500 bytes on
the replication stream. You replicate to two other regions. What bandwidth? What does the
250 ms round trip do to a synchronous design?
]
#sol[
*Bandwidth per region pair.*
$ "200,000" times 500 = "100,000,000" "bytes/s" = 100 "MB/s" $
$ 100 times 8 = 800 "Mbps" $

*To two regions.*
$ 800 times 2 = 1.6 "Gbps of cross-region traffic, continuously" $

That is affordable — a couple of dedicated links — but note it runs 24 hours a day and
inter-region traffic is billed at a much higher rate than traffic inside one region.
Monthly volume:
$ 100 "MB/s" times "86,400" times 30 times 2 = 5.18 times 10^14 "bytes" = 518 "TB/month" $
At \$0.02 per GB that is $"518,000" times \$0.02 = \$"10,360"$ a month, just to keep
copies in step.

*Now the latency question — this is the real answer.*

*Synchronous replication* means the write is not acknowledged until the remote regions
have it. The floor is one round trip:
$ "write latency" >= 250 "ms" $

Apply Little's Law to see what that does to concurrency:
$ L = "200,000" "writes/s" times 0.250 "s" = "50,000" "writes in flight" $

Fifty thousand simultaneously open write transactions. No ordinary database holds that.
Synchronous cross-continent replication at this write rate is *not slow — it is
impossible*, and that is the sentence to say.

*Asynchronous replication* acknowledges locally (say 5 ms) and ships the change after.
$ L = "200,000" times 0.005 = "1,000" "in flight" quad #sym.checkmark $

The cost is a *replication lag window*. At 100 MB/s of changes and a healthy link, lag is
usually under a second, but during a network incident it grows. If the region dies with
3 seconds of lag:
$ "200,000" times 3 = "600,000" "writes lost" $

*The decision, split by data type — this is what a senior answer looks like.*

#table(columns: (auto, 1fr, 1fr),
  [*Data*], [*Mode*], [*Why*],
  [money movement, ledger], [synchronous, but only within one region's 3 zones],
    [$approx 1$ ms between zones, so $L = 200$ in flight. Durable and fast. Cross-region
     is async — a bank accepts a recovery procedure, not a 250 ms write.],
  [user profile, settings], [asynchronous, last-write-wins on a timestamp], [a 2-second-old
     display name harms nobody],
  [counters, view counts], [asynchronous, merge by addition], [order does not matter; the
     sum is the same],
  [session tokens], [not replicated at all], [re-login on failover is cheaper than
     replicating them],
)

*Decision: asynchronous across regions, synchronous across zones within a region, and
accept a bounded loss window that you measure and alarm on.* The alternative — global
synchronous writes — buys zero data loss and costs you the ability to serve traffic at
all. Every large system that claims otherwise has quietly restricted synchronous writes
to a small, low-rate subset of its data.
]
#ans[1.6 Gbps, #sym.approx 518 TB/month. Sync across zones (1 ms), async across regions (250 ms is impossible at 200 K writes/s).]

#practice(tier: 3, time: "40 min")[
+ 50 million posts a day, average 500 followers. Inbox writes per day, per second, and
  at 3x peak. How many 5,000-writes/s nodes with 1.5x headroom?
+ A dataset is 300 TB and a shard holds 3 TB. Minimum shards? Round to a power of two.
+ A request fans out to 30 shards, each fast 99% of the time. What fraction of requests
  are slow?
+ Two layers each retry 4 times. Amplification factor? At 2,000 req/s of real traffic,
  what does the bottom layer see?
+ 500,000 writes/s at 300 bytes replicate to one other region. Bandwidth in Gbps?
+ A global service has a 2x peak factor, a single-country one has 3x. At 20 million
  requests a day, what is each peak QPS, and why does the global one get the smaller
  multiplier?
]

#key[
*1.* $"50,000,000" times 500 = 2.5 times 10^10$ rows/day.
$2.5 times 10^10 \/ "86,400" = "289,352"$/s average; $times 3 = "868,056"$/s peak.
Nodes: $"868,056" \/ "5,000" = 173.6 arrow.r 174$; $times 1.5 = 261$ nodes.

*2.* $300 \/ 3 = 100$ shards minimum; round up to *128*.

*3.* $0.99^30$. Using $0.99^10 = 0.9044$: $0.9044^3 = 0.7397$. So
$1 - 0.7397 = 0.260 = 26.0%$ of requests are slow. At 30 shards a per-shard p99 is
already not good enough.

*4.* $4 times 4 = 16$x. $"2,000" times 16 = "32,000"$ req/s at the bottom layer.

*5.* $"500,000" times 300 = "150,000,000"$ B/s $= 150$ MB/s $times 8 = 1.2$ Gbps.

*6.* $"20,000,000" \/ "86,400" = 231.5$ QPS average.
Global at 2x $= 463$ QPS. Single-country at 3x $= 694$ QPS.
The global service gets the smaller multiplier because its users are spread across time
zones: while India sleeps, Brazil is awake, so the daily curve is flatter. One country
has one evening, and everybody arrives in it.
]

#section[Interview drill — what the interviewer pushes on]

#table(columns: (1fr, 1.6fr),
  align: (left, left),
  [*The push*], [*The answer that scores*],
  ["Where did that number come from?"],
    ["I assumed 30 actions per user per day. If it is 10, every number below divides by
      3 and I need 8 servers instead of 24. Tell me if you have a better figure and I
      will redo it in ten seconds."],
  ["Isn't 3x peak too high / too low?"],
    ["A flat day puts 4.2% of traffic in each hour. A single-country consumer app puts
      12--15% in the evening hour, so 3x. For a global product I would use 2x; for a
      flash sale, 10x or more."],
  ["You rounded 86,400 to 100,000. Isn't that wrong?"],
    ["It makes my QPS about 14% low, and I said so. For choosing between 20 servers and
      200 that does not matter. If we are sizing the actual order I will use 86,400."],
  ["Do you need a cache here?"],
    ["Peak is (number) and one database replica does about (number). The ratio is
      (number). If it is under 1, no cache. Here it is (number), so I need a hit rate of
      $1 - "db capacity" \/ "peak"$ = (number)%."],
  ["How much will this cost?"],
    ["Egress is (GB/month) at about \$0.02 per GB = \$(number). Storage is (TB) at
      \$0.02 per GB-month = \$(number). Servers are (n) at \$60 = \$(number). The
      biggest line is (which), so that is where I would optimise."],
  ["Your storage number ignores indexes."],
    ["Correct. Add 30% for two secondary indexes: (number) becomes (number). It does not
      change the conclusion that this is (small/large), but the corrected number is
      (value)."],
  ["What breaks first at 10x?"],
    ["At 10x, peak goes from (number) to (number). The application tier just needs more
      machines. The first *structural* break is (component) at (its limit), because
      (reason). I would fix it by (change)."],
  ["Why is bandwidth not your bottleneck?"],
    ["Peak QPS times response size is (number) MB/s. A single 1 Gbps card does 125 MB/s.
      I am at (percent) of one card, so the bottleneck is request count, not bytes."],
  ["Is your fan-out number right?"],
    ["One user action writes (n) rows because of (followers / replicas / indexes). So the
      API sees (number) writes a second and the storage sees (number times n). That
      multiplier is the whole reason I chose (design)."],
  ["Can't you just use a bigger machine?"],
    ["Yes, up to a point, and it is cheaper than my time. One box tops out near 5,000
      durable writes a second. I need (number). So vertical scaling works until
      (number) and then I shard."],
  ["How confident are you in these numbers?"],
    ["Within about 2x. The assumption I am least sure about is (which), and if it is
      wrong by 5x then (what changes). Everything else survives being wrong by 2x."],
  ["Estimate it again, differently."],
    ["Sure — instead of DAU times actions, let me work backwards from storage: the
      database is (size) and rows are (bytes), so there are (n) rows, over (years) that
      is (rows/day), which agrees with my first number within (factor)."],
)

#trick[
*The two-way check.* Whenever you have time, estimate the same quantity from a different
direction and see if the two agree. Forwards: users $times$ actions $arrow.r$ rows.
Backwards: disk size $div$ row size $arrow.r$ rows. If the two land within 2x of each
other, your numbers are sound and you can say so. If they are 20x apart, one of your
assumptions is wrong and you have just caught it yourself — which scores higher than
never making the mistake.
]

#trap[
Three estimation habits that lose marks:
+ *Precision theatre.* "4,166.67 QPS" is worse than "about 4,200". The extra digits claim
  an accuracy your assumptions do not have, and interviewers notice.
+ *No assumption list.* If you never say "I am assuming 30 actions per user", the
  interviewer cannot correct you, and every later number looks like a guess.
+ *Numbers with no conclusion.* Computing 1.75 TB and then saying nothing is half a mark.
  "1.75 TB a year, so one database for five years, no sharding" is the full mark. Always
  end an estimate with the decision it just made.
]

#revision[
*The rule.* One significant figure. Within 2x is good, 3x is acceptable, 10x is a fail.
Always end with "so the binding constraint is \_\_\_".

*Time.*
#table(columns: (auto, auto, auto),
  [day], [86,400 s], [round to $10^5$],
  [month (30 d)], [2.59 M s], [],
  [year], [31.5 M s], [],
  [*1 M/day*], [*11.6 /s*], [multiply daily millions by 11.6],
  [1 B/day], [11,574 /s], [],
)

*Bytes.* $2^10 approx 10^3$, $2^20 approx 10^6$, $2^30 approx 10^9$,
$2^32 = 4.29 times 10^9$, $2^63 = 9.2 times 10^18$.
1 KB $times$ 1 M $=$ 1 GB. 1 KB $times$ 1 B $=$ 1 TB. 1 MB $times$ 1 M $=$ 1 TB.
Bytes are capital B, bits are small b: 1 Gbps $=$ 125 MB/s.

*Latency.* L1 0.5 ns · memory 100 ns · 1 MB from memory 30 µs · SSD random read 100 µs ·
same-DC round trip 500 µs · disk seek 10 ms · Mumbai#sym.arrow.l.r Singapore 60 ms ·
Mumbai#sym.arrow.l.r Virginia 250 ms.
Memory is #sym.approx 5,000x faster than a network hop. Physics sets 250 ms cross-ocean; only a
nearby copy fixes it.

*One machine does.* App server 1,000--2,000 req/s · Postgres reads 10--20 k/s · Postgres
durable writes 3--5 k/s · Redis 100 k ops/s · 100 k WebSockets held · 1 Gbps card
125 MB/s.

*JavaScript memory.* `Int32Array` 4 B/elem · `Array` of ints 8 B/elem · object with 4
fields #sym.approx 64 B · `Map` entry with string key #sym.approx 61 B · `Map<int, object>` #sym.approx 85 B.

*Peak factors.* Global 2x · one country consumer 3x · one country work app 4--5x ·
event/sale 10--50x. Defence: flat is 4.2% per hour, real evening peak is 12--15%.

*The five lines.*
```
traffic    DAU × actions ÷ 86,400 × peak
storage    rows/day × bytes/row × 365 × years × RF (× 1.3 for indexes)
bandwidth  peak QPS × response bytes  (× 8 for bits)
memory     hot items × bytes/item
machines   peak QPS ÷ per-server QPS × 1.5
```

*Four formulas that decide designs.*
#table(columns: (auto, 1fr),
  [Little's Law], [$L = lambda W$ — in flight $=$ rate $times$ latency. Sizes every pool.],
  [cache relief], [database load drops by $1\/(1-h)$. 90% hit $=$ 10x; 99% $=$ 100x.],
  [needed hit rate], [$1 - "db capacity" \/ "peak QPS"$],
  [fan-out tail], [$P("slow") = 1 - p^n$. 50 shards at p99 $=$ 39.5% slow.],
)

*Amplifiers to look for.* Followers (1 post $arrow.r$ 300 rows) · replication (×3) ·
indexes (+30%) · retries ($3^"layers"$) · logs (often bigger than the data) ·
telemetry (pings can be 1,000x business traffic).

*Things that gain marks.* Stating assumptions before the arithmetic. Doing one division
out loud. Saying "this is small, one server is enough" when it is true. Ending with the
binding constraint. Estimating the same thing twice from two directions.

*Things that lose marks.* Precision theatre. No assumptions. Numbers with no conclusion.
Forgetting the write amplifier. Quoting a hit rate without computing the miss traffic.

*The recovery line.* "Let me redo that division out loud."
]

]
