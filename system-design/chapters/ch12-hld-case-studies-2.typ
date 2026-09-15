#import "../../shared/lib/style.typ": *

#chapter(num: 12, title: "HLD Case Studies II",
  tagline: "Ride-hailing · food delivery · video streaming · search autocomplete · payments")[

#section[The idea in one page]

Chapter 11 designed five systems whose data was small and whose hard part was
*coordination*. This chapter designs five whose data is awkward in a new way. One moves
(a driver's position). One is enormous (video). One must answer before you finish typing.
One must never, ever be wrong (money).

The seven steps do not change. What changes is *which step is hard*.

#formulas(title: "The five designs and what each one is really about")[
#table(columns: (auto, 1fr, 1fr),
  [*Design*], [*The real lesson*], [*The trap*],
  [Ride-hailing],
    [Indexing things that move, and matching two sides of a market],
    [Storing every GPS ping. It is 864 GB a day and nobody reads it.],
  [Food delivery],
    [A three-sided state machine with no distributed transaction],
    [Treating "restaurant accepted" and "courier assigned" as one atomic step],
  [Video streaming],
    [Bandwidth, not requests. The CDN *is* the system.],
    [Designing an origin that could serve the traffic. It cannot, and must not.],
  [Search autocomplete],
    [Precompute everything. The request must do no thinking.],
    [Searching a trie at request time under a 50 ms budget],
  [Payments],
    [Idempotency, a double-entry ledger, and never trusting a third party],
    [One row per payment that gets UPDATE-ed. Money is append-only.],
)
]

#subsection[The numbers card for this chapter]

#formulas(title: "Learn these before you walk in")[
*Geography*
- A geohash of 5 characters is about *4.9 km x 4.9 km*.
- 6 characters is about *1.2 km wide x 0.61 km tall*.
- 7 characters is about *153 m x 153 m*.
- 1 degree of latitude $approx 111.3$ km, everywhere. Longitude shrinks by $cos("lat")$.

*Media*
- Video bitrates: 240p ~0.4 Mbps, 360p ~0.8, 480p ~1.2, 720p ~2.5, 1080p ~5.0 Mbps.
- 1 Mbps for 1 hour $= 450$ MB. 1 Gbps $= 125$ MB/s.
- A 4-second HLS chunk at 3 Mbps is $4 times 3,000,000 \/ 8 = 1,500,000$ B $= 1.5$ MB.
- A good CDN offloads *95%* of bytes. The other 5% is your origin's whole job.

*Latency budgets a product actually promises*
- Autocomplete: *under 100 ms end to end*, so under 50 ms in your service.
- Driver dispatch: an offer on the driver's phone within *2 seconds* of the request.
- Payment authorisation: *under 3 seconds*, and the third party alone eats 800 ms of it.

*Money*
- Always integer minor units (cents, paise). *Never a float.*
- Double entry: every movement is two rows that sum to zero. Nothing is ever updated.
- 10 million payments/day $= 115.7$/s average; a sale day at 10x is 1,157/s.
]

#trap[
The most expensive mistake in this chapter is *persisting every event*. 400,000 drivers
pinging every 4 seconds is 100,000 writes/second and 864 GB/day — of data that is *stale one
second later*. A current position belongs in memory. Only the parts you will actually read
again — a trip's trail, for a receipt or a dispute — go to disk, and even then downsampled.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[400,000 drivers are online at peak. Each phone sends its
position every 4 seconds, in a 100-byte message. Find the write rate, the bandwidth, and
the storage cost if you saved every ping for one day.
#sol[
*Writes per second.* Each driver sends $1 \/ 4 = 0.25$ messages a second.
$ 400,000 \/ 4 = 100,000 "pings/second" $

*Bandwidth.*
$ 100,000 times 100 = 10,000,000 "bytes/second" = 10 "MB/s" = 80 "Mbps" $
That is small. The *count* is the problem, not the bytes.

*Storage if you kept them all.*
$ 10,000,000 times 86,400 = 864,000,000,000 "bytes/day" = 864 "GB/day" $
$ 864 times 365 \/ 1000 = 315.4 "TB/year" $

*What we actually store.* Only the *latest* position per driver, in memory:
$ 400,000 times 60 "B" = 24,000,000 "B" = 24 "MB" $
Twenty-four megabytes replaces three hundred terabytes a year. That comparison is the whole
answer to this design's first hard question.
]
#ans[100,000 writes/s, 10 MB/s, 864 GB/day if kept — so keep only the latest, which is 24 MB]
]

#ex(2, tier: 0, asked: "warm-up")[5 million rides a day. The average ride lasts 20 minutes.
How many rides are in progress at any moment, on average and at a 3x peak?
#sol[
*The trick:* concurrency $=$ rate $times$ duration. Work in the same unit, here minutes.

$ "ride-minutes per day" = 5,000,000 times 20 = 100,000,000 $
$ "minutes in a day" = 24 times 60 = 1,440 $
$ "average concurrent rides" = 100,000,000 \/ 1,440 = 69,444 $

*At a 3x peak:*
$ 69,444 times 3 = 208,333 "rides in progress" $

Sanity check against the fleet: with 400,000 drivers online at peak, 208,333 on a trip means
$208,333 \/ 400,000 = 52%$ utilisation. That is believable for a busy evening, so the two
numbers agree.
]
#ans[~69,444 average, ~208,333 at peak — about 52% of the online fleet]
]

#trick[
*Concurrency $=$ arrival rate $times$ holding time.* This one line answers "how many
simultaneous X" for rides, calls, video streams, open connections, and in-flight API calls.
It is called Little's Law. Use the same time unit on both sides and you cannot get it wrong.
]

#ex(3, tier: 0, asked: "warm-up")[100 million people watch 40 minutes of video a day at an
average 3 Mbps. Find the average and peak concurrent viewers, and the peak egress in Tbps.
#sol[
*Concurrent viewers* — Little's Law again.
$ "watch-minutes/day" = 100,000,000 times 40 = 4,000,000,000 $
$ "average concurrent" = 4,000,000,000 \/ 1,440 = 2,777,778 $
$ "peak at 3x" = 2,777,778 times 3 = 8,333,333 "viewers" $

*Peak egress.*
$ 8,333,333 times 3 "Mbps" = 25,000,000 "Mbps" = 25 "Tbps" $

*Daily bytes.*
$ 4,000,000,000 "min" times 60 "s" times 3,000,000 "bits" \/ 8 = 9.0 times 10^16 "B" $
$ = 90 "PB/day" $
]
#ans[8.33 million concurrent at peak, 25 Tbps, 90 PB/day]
]

#note[
25 Tbps is more than most countries' entire international capacity. This is why a video
design that draws "service $arrow.r$ database $arrow.r$ user" fails instantly. The right
first sentence is: *"the CDN serves 95% of the bytes and my origin serves 1.25 Tbps."*
]

#ex(4, tier: 0, asked: "warm-up")[A 10-minute video is transcoded into five renditions:
0.4, 0.8, 1.2, 2.5 and 5.0 Mbps. How many bytes does the finished video occupy? At 500,000
uploads a day, how much new storage per year?
#sol[
*Total bitrate across the ladder.*
$ 0.4 + 0.8 + 1.2 + 2.5 + 5.0 = 9.9 "Mbps" $

*Bytes for 10 minutes.* 10 minutes $= 600$ seconds.
$ 9.9 times 10^6 "bits/s" times 600 "s" = 5.94 times 10^9 "bits" $
$ 5.94 times 10^9 \/ 8 = 742,500,000 "B" = 742.5 "MB per video" $

*Per day.*
$ 500,000 times 742.5 "MB" = 371,250,000 "MB" = 371.25 "TB/day" $

*Per year.*
$ 371.25 times 365 = 135,506 "TB" = 135.5 "PB/year" $
]
#ans[742.5 MB per video, 371.25 TB/day, ~135.5 PB/year]
]

#ex(5, tier: 0, asked: "warm-up")[2 billion searches a day. The client debounces typing and
sends 4 prefix requests per search. What QPS must autocomplete serve at peak, and how many
in-memory nodes at 50,000 requests/s each?
#sol[
$ 2,000,000,000 times 4 = 8,000,000,000 "prefix requests/day" $
$ 8,000,000,000 \/ 86,400 = 92,593 "requests/second average" $
$ 92,593 times 3 = 277,778 "requests/second at peak" $
$ 277,778 \/ 50,000 = 5.6 arrow.r 6 "nodes" $

Add headroom to survive losing one: run *8*. Note how small that is — the whole reason it is
small is that a request does *no computation*, only a lookup. Change one word in the design
("we search the trie at request time") and this number becomes 60 nodes.
]
#ans[277,778 QPS at peak; 6 nodes of work, run 8]
]

#ex(6, tier: 0, asked: "warm-up")[10 million payments a day, peak 10x on a sale day. The
external payment provider takes 800 ms to answer. How many calls are in flight at peak?
#sol[
$ 10,000,000 \/ 86,400 = 115.7 "payments/second average" $
$ 115.7 times 10 = 1,157 "payments/second at peak" $

In-flight calls, by Little's Law:
$ 1,157 times 0.8 "s" = 926 "calls open at once" $

That number decides your architecture. 926 open sockets is fine for one Node process doing
I/O, but 926 *threads* would not be. And it means a 30-second provider stall parks
$1,157 times 30 = 34,710$ requests — which is why the call must be made by a worker reading
a queue, not by the thread holding the user's HTTP connection.
]
#ans[1,157 payments/s at peak, ~926 concurrent provider calls]
]

#ex(7, tier: 0, asked: "warm-up")[A city is about 50 km by 27 km. You index drivers in
6-character geohash cells (1.2 km x 0.61 km). 60,000 drivers are online in that city. How
many cells, how many drivers per cell, and how many candidates does a 9-cell search return?
#sol[
*Cells.*
$ 50 \/ 1.223 = 40.9 "cells across" $
$ 27 \/ 0.611 = 44.2 "cells down" $
$ 40.9 times 44.2 = 1,807 "cells" $

*Drivers per cell.*
$ 60,000 \/ 1,807 = 33.2 "drivers per cell" $

*A 9-cell search* (the cell you are in, plus its 8 neighbours):
$ 33.2 times 9 = 299 "candidates" $

299 candidates is nothing: you can run an exact distance calculation on every one of them in
well under a millisecond, then sort. *The cell index is a cheap filter, not the answer.*
]
#ans[~1,807 cells, ~33 drivers each, ~299 candidates from a 9-cell search]
]

#trap[
Why nine cells and not one? Because the rider may be standing 10 metres from a cell border,
and the nearest driver may be on the other side of it. Searching only your own cell finds a
driver 900 m away and misses one 30 m away. *Always search the ring of neighbours.* This is
the single most common bug in a geo-index answer.
]

#ex(8, tier: 0, asked: "warm-up")[400,000 drivers hold an open WebSocket. One machine
comfortably holds 100,000 connections. How many machines, and how many if you must survive
losing one of three availability zones?
#sol[
*Base.*
$ 400,000 \/ 100,000 = 4 "machines" $

*Surviving one zone of three.* When one zone dies you must carry all the load on the
remaining $2\/3$ of the fleet. So the fleet must be big enough that two thirds of it equals
4 machines' worth of capacity.
$ 4 \/ (2\/3) = 4 times 1.5 = 6 "machines" $
Spread them 2 / 2 / 2. Losing any one zone leaves 4, which is exactly enough.

*What actually happens during that failure* is the interesting part: 133,333 drivers
reconnect at once. If they all retry immediately, the surviving 4 machines get a
reconnect storm. Fix: the client waits a random 0 to 30 seconds before reconnecting, which
spreads $133,333 \/ 30 = 4,444$ reconnects per second instead of 133,333 in one instant.
]
#ans[4 machines of load, 6 provisioned as 2/2/2, plus randomised reconnect backoff]
]

#practice(tier: 0, time: "12 min")[
+ 3 million food orders a day, 35% of them in the 2-hour lunch window. Peak orders/second?
+ A courier fleet of 120,000 pings every 5 seconds. Write rate? If you keep 6 hours of trail
  at 40 bytes a point, how much memory?
+ A video service has 25 Tbps of peak egress and the CDN offloads 95%. What must the origin
  serve? If egress costs \$0.01 per GB, what is a day of traffic worth at 90 PB?
+ Autocomplete stores the top 10 suggestions at each of 50 million prefixes, 200 bytes per
  prefix. How much RAM, and over how many nodes at 32 GB each?
+ 10 million payments a day, two ledger rows each at 300 bytes. Storage per day, per year,
  and over a 7-year retention rule?
]
#key[
+ $3,000,000 times 0.35 = 1,050,000$ orders in the window;
  $1,050,000 \/ 7,200 "s" = 145.8$ orders/second.
+ $120,000 \/ 5 = 24,000$ writes/second. Six hours of trail is
  $24,000 times 3,600 times 6 = 518,400,000$ points $times 40$ B $= 20.7$ GB. Too much for
  one Redis node's comfort — downsample to one point per 15 seconds while on a trip and it
  becomes $20.7 times 5\/15 = 6.9$ GB. Or just do not keep the trail of an *idle* courier at
  all, which removes most of it.
+ Origin $= 25 times 0.05 = 1.25$ Tbps. $90$ PB $= 90,000,000$ GB;
  $90,000,000 times 0.01 = \$900,000$ per day. That number is why large video companies build
  their own CDN and peer directly with ISPs.
+ $50,000,000 times 200 = 10,000,000,000$ B $= 10$ GB. It fits on *one* 32 GB node — so
  shard for throughput and failure tolerance, not for size: 8 nodes each holding the full
  10 GB, any of which can answer any query. That is a much better design than 8 shards,
  because it removes the routing layer entirely.
+ $10,000,000 times 2 times 300 = 6,000,000,000$ B $= 6$ GB/day; $times 365 = 2,190$ GB
  $= 2.19$ TB/year; $times 7 = 15.33$ TB. Small. Money data is always small and always
  precious — the opposite shape from video.
]

#section[Tier 1 — the low-level pieces]
#tier-header(1)

Five pieces. Every one of them has been asked on its own in a service-company round, and
every one of them is the beating heart of a design later in this chapter.

#subsection[Piece 1 — a geohash encoder]

#ex(9, tier: 1, asked: "Infosys · pattern")[Write a function that turns a latitude and
longitude into a short string, such that two nearby points share a long prefix.
#sol[

*The idea.* Repeatedly cut the world in half and write down which half you are in.
Even-numbered bits cut *longitude*, odd-numbered bits cut *latitude*. Every 5 bits become one
character of a 32-letter alphabet.

#code(lang: "js", caption: "geohash.js")[
```js
const B32 = '0123456789bcdefghjkmnpqrstuvwxyz';   // no a, i, l or o

function geohash(lat, lng, precision = 6) {
  let latLo = -90, latHi = 90, lngLo = -180, lngHi = 180;
  let bit = 0, ch = 0, even = true, out = '';

  while (out.length < precision) {
    if (even) {
      // even bits split LONGITUDE
      const mid = (lngLo + lngHi) / 2;
      if (lng >= mid) { ch = (ch << 1) | 1; lngLo = mid; }
      else            { ch = ch << 1;       lngHi = mid; }
    } else {
      // odd bits split LATITUDE
      const mid = (latLo + latHi) / 2;
      if (lat >= mid) { ch = (ch << 1) | 1; latLo = mid; }
      else            { ch = ch << 1;       latHi = mid; }
    }
    even = !even;
    if (++bit === 5) { out += B32[ch]; bit = 0; ch = 0; }
  }
  return out;
}

// exact distance on a sphere, for the final filter
function haversineKm(a, b) {
  const R = 6371, toRad = d => d * Math.PI / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const h = Math.sin(dLat / 2) ** 2 +
            Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat)) *
            Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}
```
]

#code(lang: "text", caption: "actual output")[
```text
Changi   w21zy2k
Marina   w21z73t
Marina+  w21z73t  shares prefix with Marina: 7 chars
Changi shares with Marina: 4 chars
Changi -> Marina = 17.10 km
```
]

Two points 60 metres apart produce the *same* 7-character hash. Two points 17 km apart share
only 4 characters. That is the whole property: *prefix length is a proxy for closeness.*

#formulas(title: "Cell size by precision — memorise the middle three")[
#table(columns: (auto, auto, 1fr),
  [*Chars*], [*Cell size*], [*Good for*],
  [4], [19.6 km x 39.1 km], [country-level bucketing],
  [5], [4.9 km x 4.9 km], [a whole small city; too coarse for dispatch],
  [6], [1.22 km x 0.61 km], [*the dispatch default*],
  [7], [153 m x 153 m], [pickup-point clustering, "which building"],
)
The cell is a *rectangle*, not a square, and the aspect flips at every character, because
latitude and longitude do not get the same number of bits at every step.
]
]
]

#trap[
*Geohash has two real flaws and you should name both before you are asked.*
+ *Border blindness.* Neighbouring points can differ in the very first character. The fix is
  to always search the 8 neighbouring cells too.
+ *Uneven density.* A cell in a city centre may hold 5,000 drivers and one over water may
  hold zero. A fixed grid cannot adapt. If density varies by more than about 50x, use a
  *quadtree* (split a cell when it exceeds, say, 100 items) or an S2/H3 cell system instead.
  For a ride-hailing app inside one city, a fixed 6-character grid is honestly fine, and
  saying "fine, and here is when it stops being fine" is the answer that scores.
]

#subsection[Piece 2 — the live index of things that move]

#ex(10, tier: 1, asked: "Capgemini · pattern")[Build an in-memory index that answers "which
available drivers are within 5 km of this point?" while 100,000 position updates a second
are arriving.
#sol[

#diagram(height: 6.1cm, caption: "The 9-cell search. The cheap filter is the cell lookup; the exact filter is haversine. A driver just over a border is found because the ring is searched.")[
  #dnode(60pt, 8pt, 58pt, 34pt, "cell NW")
  #dnode(122pt, 8pt, 58pt, 34pt, "cell N")
  #dnode(184pt, 8pt, 58pt, 34pt, "cell NE")
  #dnode(60pt, 46pt, 58pt, 34pt, "cell W")
  #dnode(122pt, 46pt, 58pt, 34pt, "PICKUP", fill: rgb("#dbe7c9"))
  #dnode(184pt, 46pt, 58pt, 34pt, "cell E")
  #dnode(60pt, 84pt, 58pt, 34pt, "cell SW")
  #dnode(122pt, 84pt, 58pt, 34pt, "cell S")
  #dnode(184pt, 84pt, 58pt, 34pt, "cell SE")

  #place(dx: 132pt, dy: 52pt)[#circle(radius: 3pt, fill: rgb("#8c2f39"), stroke: none)]
  #place(dx: 172pt, dy: 36pt)[#circle(radius: 2.5pt, fill: dc, stroke: none)]
  #place(dx: 96pt, dy: 66pt)[#circle(radius: 2.5pt, fill: dc, stroke: none)]
  #place(dx: 206pt, dy: 92pt)[#circle(radius: 2.5pt, fill: dc, stroke: none)]
  #place(dx: 74pt, dy: 18pt)[#circle(radius: 2.5pt, fill: dc, stroke: none)]

  #place(dx: 260pt, dy: 6pt)[#text(size: 8.5pt)[*Step 1* cell lookup]]
  #place(dx: 260pt, dy: 20pt)[#text(size: 8pt)[9 cells x ~33 drivers]]
  #place(dx: 260pt, dy: 32pt)[#text(size: 8pt)[$= 299$ candidates]]
  #place(dx: 260pt, dy: 50pt)[#text(size: 8.5pt)[*Step 2* filter]]
  #place(dx: 260pt, dy: 64pt)[#text(size: 8pt)[drop `ON_TRIP`, drop stale]]
  #place(dx: 260pt, dy: 76pt)[#text(size: 8pt)[pings, older than 30 s]]
  #place(dx: 260pt, dy: 94pt)[#text(size: 8.5pt)[*Step 3* exact]]
  #place(dx: 260pt, dy: 108pt)[#text(size: 8pt)[haversine, keep $lt.eq 5$ km,]]
  #place(dx: 260pt, dy: 120pt)[#text(size: 8pt)[sort by distance]]

  #place(dx: 24pt, dy: 138pt)[#text(size: 8pt, fill: muted)[Searching only the centre cell would miss the driver just above its top border.]]
]

#code(lang: "js", caption: "driver-index.js")[
```js
const CELL = 5;                 // 5 chars ~ 4.9 km; 6 for a dense city

class DriverIndex {
  constructor() {
    this.cells = new Map();     // cell -> Set(driverId)
    this.drivers = new Map();   // driverId -> {lat,lng,cell,status,ts}
  }

  // the 8 neighbours, found by nudging the coordinates instead of
  // doing bit arithmetic. Slower to run, far easier to get right.
  static neighbourCells(lat, lng, stepDeg = 0.045) {
    const out = new Set();
    for (const dLat of [-stepDeg, 0, stepDeg])
      for (const dLng of [-stepDeg, 0, stepDeg])
        out.add(geohash(lat + dLat, lng + dLng, CELL));
    return [...out];
  }

  upsert(id, lat, lng, status, ts) {
    const cell = geohash(lat, lng, CELL);
    const old = this.drivers.get(id);
    // moved to a new cell: unlink from the old one FIRST
    if (old && old.cell !== cell) this.cells.get(old.cell).delete(id);
    if (!this.cells.has(cell)) this.cells.set(cell, new Set());
    this.cells.get(cell).add(id);
    this.drivers.set(id, { lat, lng, cell, status, ts });
  }

  remove(id) {
    const d = this.drivers.get(id);
    if (!d) return;
    this.cells.get(d.cell)?.delete(id);
    this.drivers.delete(id);
  }

  nearby(lat, lng, radiusKm, now, staleMs = 30_000) {
    const found = [];
    for (const cell of DriverIndex.neighbourCells(lat, lng)) {
      for (const id of this.cells.get(cell) ?? []) {
        const d = this.drivers.get(id);
        if (d.status !== 'AVAILABLE') continue;
        if (now - d.ts > staleMs) continue;     // a ghost: phone lost signal
        const km = haversineKm({ lat, lng }, d);
        if (km <= radiusKm) found.push({ id, km });
      }
    }
    return found.sort((a, b) => a.km - b.km);   // numeric comparator
  }
}
```
]

#code(lang: "text", caption: "actual output — d4 is busy, d5 is stale, d6 is 17 km away")[
```text
cells in use: [ 'w21z7', 'w21zy' ]
candidates within 5 km: [
  { id: 'd1', km: 0.07458808063127464 },
  { id: 'd2', km: 1.397664362032147 },
  { id: 'd3', km: 3.6540000323125237 }
]
candidates within 1 km: [ { id: 'd1', km: 0.07458808063127464 } ]
```
]

*Why the stale check matters more than it looks.* A driver whose phone lost signal is still
in the index at their last known position. Offering them a ride wastes 12 seconds of the
rider's life and then re-dispatches. A 30-second staleness cut-off means you only ever offer
to phones you have heard from recently. It costs one comparison.
]
]

#trap[
*The unlink-before-link order is a real bug source.* If you add the driver to the new cell
before removing them from the old one, and a concurrent read runs in between, the driver
appears *twice*. In JavaScript you get away with it inside one synchronous function, because
nothing interleaves — but the moment `upsert` contains an `await`, the gap becomes real.
Treat "remove from old, then add to new" as one indivisible step, and never put an `await`
inside it.
]

#subsection[Piece 3 — dispatch with a hold and a timeout]

#ex(11, tier: 1, asked: "TCS NQT · pattern")[Two riders request at the same second and the
same driver is nearest to both. Write the dispatcher so the driver is offered to exactly one
of them, and so that ignoring an offer does not strand the rider.
#sol[

*The rule:* an offer is a *hold*. While a driver is holding an offer, no other dispatcher may
offer them. The hold expires by itself.

#code(lang: "js", caption: "dispatcher.js")[
```js
class Dispatcher {
  constructor(index, offerMs = 12_000) {
    this.index = index;
    this.offerMs = offerMs;
    this.offers = new Map();          // rideId -> {driverId, expiresAt, tried}
  }

  offer(rideId, lat, lng, now, tried = new Set()) {
    const cands = this.index.nearby(lat, lng, 5, now)
                            .filter(c => !tried.has(c.id));
    if (cands.length === 0) return { rideId, status: 'NO_DRIVER' };

    const best = cands[0];
    const d = this.index.drivers.get(best.id);
    // the HOLD: status flips so no other dispatcher can pick him
    this.index.upsert(best.id, d.lat, d.lng, 'OFFERED', d.ts);
    this.offers.set(rideId, {
      driverId: best.id, expiresAt: now + this.offerMs, tried,
    });
    return {
      rideId, status: 'OFFERED', driverId: best.id,
      etaMin: +(best.km * 60 / 25).toFixed(1),   // 25 km/h city average
    };
  }

  accept(rideId, driverId, now) {
    const o = this.offers.get(rideId);
    if (!o || o.driverId !== driverId) return { ok: false, why: 'not yours' };
    if (now > o.expiresAt) return { ok: false, why: 'offer expired' };
    const d = this.index.drivers.get(driverId);
    this.index.upsert(driverId, d.lat, d.lng, 'ON_TRIP', d.ts);
    this.offers.delete(rideId);
    return { ok: true, status: 'MATCHED' };
  }

  timeout(rideId, lat, lng, now) {           // the driver ignored the ping
    const o = this.offers.get(rideId);
    if (!o) return null;
    const d = this.index.drivers.get(o.driverId);
    // release the hold, remember we tried him, go again
    this.index.upsert(o.driverId, d.lat, d.lng, 'AVAILABLE', d.ts);
    o.tried.add(o.driverId);
    this.offers.delete(rideId);
    return this.offer(rideId, lat, lng, now, o.tried);
  }
}
```
]

#code(lang: "text", caption: "actual output")[
```text
offer 1 : { rideId: 'ride1', status: 'OFFERED', driverId: 'd1', etaMin: 0.2 }
ignored -> { rideId: 'ride1', status: 'OFFERED', driverId: 'd2', etaMin: 3.4 }
accept  : { ok: true, status: 'MATCHED' }
second rider now gets: { rideId: 'ride2', status: 'OFFERED', driverId: 'd1',
                         etaMin: 0.2 }
```
]

Read the trace. `d1` was offered, ignored the ping, was released back to `AVAILABLE`, and
`d2` got the ride instead. When a *second* rider arrives, `d1` is free again and is offered
to them. Nobody was double-booked and nobody was lost.

#formulas(title: "The three numbers in a dispatch policy, and what each one trades")[
- *Offer window (12 s).* Longer means fewer re-dispatches but a slower rider experience.
  12 seconds is about as long as a person will stare at a "finding your driver" screen
  without losing faith.
- *Search radius (5 km).* Wider finds a driver in a quiet area but offers a 12-minute pickup.
  Start at 2 km, widen to 5 km after one failed round, then give up.
- *Staleness cut-off (30 s).* Tighter means fewer ghost offers but drops drivers in tunnels
  and underground car parks. 30 s is about 7 missed pings at a 4-second interval.
]
]
]

#subsection[Piece 4 — a trie that has already done the thinking]

#ex(12, tier: 1, asked: "Cognizant · pattern")[Return the 5 most popular completions of a
prefix in under a millisecond. You may spend as much time as you like building the structure
beforehand.
#sol[

*The move that makes this easy:* do not search at request time. Store the answer *at every
node* while building. A request then walks the prefix and reads a list.

#code(lang: "js", caption: "topk-trie.js")[
```js
class TrieNode {
  constructor() {
    this.children = new Map();
    this.top = [];                 // [{q, count}] kept sorted, length <= k
  }
}

class TopKTrie {
  constructor(k = 5) { this.root = new TrieNode(); this.k = k; }

  // insert one (query, count) pair, updating EVERY node on its path
  insert(query, count) {
    let node = this.root;
    this.#merge(node, query, count);
    for (const ch of query) {
      if (!node.children.has(ch)) node.children.set(ch, new TrieNode());
      node = node.children.get(ch);
      this.#merge(node, query, count);
    }
  }

  #merge(node, q, count) {
    const i = node.top.findIndex(e => e.q === q);
    if (i >= 0) node.top[i].count = count;
    else node.top.push({ q, count });
    // numeric sort desc, with an alphabetical tie-break for stability
    node.top.sort((a, b) => b.count - a.count || (a.q < b.q ? -1 : 1));
    if (node.top.length > this.k) node.top.length = this.k;
  }

  // the request path: walk, then READ. No search, no heap, no scan.
  suggest(prefix) {
    let node = this.root;
    for (const ch of prefix) {
      node = node.children.get(ch);
      if (!node) return [];
    }
    return node.top.map(e => e.q);
  }
}
```
]

#code(lang: "text", caption: "actual output for a food-search log")[
```text
"c"       -> [ 'chicken rice', 'chilli crab', 'char kway teow',
               'chicken biryani', 'chicken curry' ]
"chi"     -> [ 'chicken rice', 'chilli crab', 'chicken biryani',
               'chicken curry', 'chicken wings' ]
"chic"    -> [ 'chicken rice', 'chicken biryani', 'chicken curry',
               'chicken wings' ]
"cha"     -> [ 'char kway teow', 'chapati' ]
"z"       -> []

nodes for 9 queries: 75 | each node stores up to 5 entries
after a new query becomes #1: [ 'chicken rice stall', 'chicken rice',
                                'chilli crab', 'chicken biryani',
                                'chicken curry' ]
```
]

#complexity(time: "suggest: O(p) where p is the prefix length — typically 3 to 8 character steps",
  space: "O(N x L x k) — one top-k list per distinct prefix",
  note: "Build is the expensive side: O(Q x L x k log k) for Q queries of length L. Build offline, hourly, never on the request path.")

*The trade you just made.* You turned a request-time search of a whole subtree — which for
the prefix `"c"` could be a million queries — into a pointer walk of 1 character. You paid
for it in memory and in build time. That is the correct trade when reads outnumber writes by
80 million to one, which is exactly the case here.
]
]

#trap[
*Do not call `sort()` without a comparator on the counts.* `[100, 9, 1000].sort()` gives
`[1, 100, 9]` — wait, as strings it gives `["100","1000","9"]`, so 9 sorts *last*. Your most
popular suggestion silently disappears from the top-5. Always
`(a, b) => b.count - a.count`.
]

#subsection[Piece 5 — an idempotent, double-entry payment]

#ex(13, tier: 1, asked: "Accenture · pattern")[A phone on a bad network sends the same
payment request three times. Charge the user exactly once. Then prove, from the data, that
no money was created or destroyed.
#sol[

#formulas(title: "Three rules that are never negotiable")[
+ *Money is an integer of the smallest unit.* 129.50 SGD is `12950`. A float loses cents and
  no ledger will ever balance again.
+ *Every movement writes two rows that sum to zero.* One account is debited, another is
  credited. If the sum of every row in the whole system is not exactly zero, you have a bug,
  and you can detect it with one query.
+ *Nothing is ever updated or deleted.* A mistake is corrected by a *new* entry with the
  opposite sign. This is what makes an audit possible and what makes "who changed this?"
  answerable.
]

#code(lang: "js", caption: "ledger.js — the part that cannot be wrong")[
```js
class Ledger {
  constructor() { this.entries = []; this.seq = 0; }

  post(txnId, legs) {
    const sum = legs.reduce((s, l) => s + l.amount, 0);
    if (sum !== 0) throw new Error(`unbalanced: legs sum to ${sum}, must be 0`);
    for (const l of legs) {
      this.entries.push({ seq: ++this.seq, txnId, ...l });
    }
  }

  balance(account) {
    return this.entries
      .filter(e => e.account === account)
      .reduce((s, e) => s + e.amount, 0);
  }
}
```
]

#code(lang: "js", caption: "payment-service.js — the idempotency gate and the state machine")[
```js
const State = Object.freeze({
  CREATED: 'CREATED', AUTHORISED: 'AUTHORISED', CAPTURED: 'CAPTURED',
  FAILED: 'FAILED', REFUNDED: 'REFUNDED',
});

const ALLOWED = {
  CREATED:    new Set(['AUTHORISED', 'FAILED']),
  AUTHORISED: new Set(['CAPTURED', 'FAILED']),
  CAPTURED:   new Set(['REFUNDED']),
  FAILED:     new Set([]),
  REFUNDED:   new Set([]),
};

class PaymentService {
  constructor(psp) {
    this.psp = psp;
    this.byId = new Map();
    this.byIdemKey = new Map();
    this.ledger = new Ledger();
  }

  async pay({ idempotencyKey, payerId, merchantId, amountCents }) {
    // THE GATE. Check-and-claim must be one atomic step.
    // In a real system this is INSERT ... ON CONFLICT DO NOTHING.
    const seen = this.byIdemKey.get(idempotencyKey);
    if (seen) return { replayed: true, ...this.byId.get(seen) };

    const paymentId = `pay_${this.byId.size + 1}`;
    this.byIdemKey.set(idempotencyKey, paymentId);
    const p = {
      paymentId, payerId, merchantId, amountCents, state: State.CREATED,
    };
    this.byId.set(paymentId, p);

    // pass OUR id to the provider so the provider dedupes too
    let res;
    try {
      res = await this.psp.authorise({ ref: paymentId, amountCents });
    } catch (e) {
      return { replayed: false, ...this.#move(p, State.FAILED, e.message) };
    }
    if (!res.ok) {
      return { replayed: false, ...this.#move(p, State.FAILED, res.reason) };
    }

    this.#move(p, State.AUTHORISED);
    this.#move(p, State.CAPTURED);
    this.ledger.post(paymentId, [
      { account: `user:${payerId}`,         amount: -amountCents },
      { account: `merchant:${merchantId}`,  amount: +amountCents },
    ]);
    return { replayed: false, ...p };
  }

  refund(paymentId, amountCents) {
    const p = this.byId.get(paymentId);
    if (!p) return { ok: false, why: 'unknown payment' };
    if (amountCents > p.amountCents) return { ok: false, why: 'too large' };
    this.#move(p, State.REFUNDED);
    // a NEW entry with the opposite sign. The old one is untouched.
    this.ledger.post(`${paymentId}_rf`, [
      { account: `merchant:${p.merchantId}`, amount: -amountCents },
      { account: `user:${p.payerId}`,        amount: +amountCents },
    ]);
    return { ok: true, state: p.state };
  }

  #move(p, to, reason) {
    if (!ALLOWED[p.state].has(to)) {
      throw new Error(`illegal move ${p.state} -> ${to}`);
    }
    p.state = to;
    if (reason) p.reason = reason;
    return p;
  }
}
```
]

#code(lang: "text", caption: "actual output")[
```text
first  call: pay_1 CAPTURED replayed = false
retry  call: pay_1 CAPTURED replayed = true
provider was called 1 time(s) -> the user was charged once
declined  : pay_2 FAILED limit_exceeded

balances after one capture:
   merchant:42    12950
   user:7         -12950

refund 30.00: { ok: true, state: 'REFUNDED' }
   merchant:42    9950
   user:7         -9950
sum of every row in the ledger = 0 (must always be 0)
rejected: unbalanced: legs sum to -100, must be 0
rejected: illegal move REFUNDED -> REFUNDED
```
]

Four things are proved by that output, and you should say all four:
+ The retry returned the *same* payment and did not call the provider again.
+ The refund did not edit the original entry; it added an opposite one, and the balances
  moved from 12950 to 9950 as a result.
+ The sum of every row is zero — money was neither created nor destroyed.
+ Two classes of bug are impossible by construction: an unbalanced entry throws, and an
  illegal state move throws.
]
]

#trap[
*The idempotency key must be claimed atomically, in the same store as the payment.* If you
write `if (!exists(key)) { insert(key); charge(); }` as two statements, two retries arriving
in the same 5 ms both see "not exists" and both charge. The correct shape is a single
`INSERT ... ON CONFLICT DO NOTHING` (or `PUT IF NOT EXISTS`), and the *result of that insert*
tells you whether you are the first caller. Checking a Redis cache first is a performance
optimisation, never the guarantee.
]

#subsection[Piece 6 — a saga, because there is no distributed transaction]

#ex(14, tier: 1, asked: "Wipro · pattern")[A food order must hold the customer's payment,
reserve the food, assign a courier, and burn a promo code. Four different services. If the
third one fails, undo the first two.
#sol[
#code(lang: "js", caption: "saga.js")[
```js
class Saga {
  constructor(name) { this.name = name; this.steps = []; }

  step(name, run, compensate) {
    this.steps.push({ name, run, compensate });
    return this;                          // chainable
  }

  async execute(ctx) {
    const done = [];
    for (const s of this.steps) {
      try {
        const out = await s.run(ctx);
        Object.assign(ctx, out ?? {});
        done.push(s);
        ctx.trace.push(`OK   ${s.name}`);
      } catch (err) {
        ctx.trace.push(`FAIL ${s.name}: ${err.message}`);
        // undo in REVERSE order: last done, first undone
        for (const d of done.reverse()) {
          try {
            await d.compensate(ctx);
            ctx.trace.push(`UNDO ${d.name}`);
          } catch (e2) {
            ctx.trace.push(`UNDO-FAILED ${d.name} -> manual queue`);
          }
        }
        return { ok: false, failedAt: s.name, ctx };
      }
    }
    return { ok: true, ctx };
  }
}
```
]

#code(lang: "text", caption: "actual output — attempt 1 fails, attempt 2 succeeds")[
```text
--- attempt 1: no courier available ---
ORDER REJECTED at assign_courier
   OK   hold_payment
   OK   reserve_food
   FAIL assign_courier: no courier within 20 minutes
   UNDO reserve_food
   UNDO hold_payment
   world after rollback: {"held":0,"stock":{"biryani":2},
                          "couriersFree":0,"promoUses":0}

--- attempt 2: a courier comes online ---
ORDER PLACED
   OK   hold_payment
   OK   reserve_food
   OK   assign_courier
   OK   burn_promo
   world after success: {"held":2400,"stock":{"biryani":1},
                         "couriersFree":0,"promoUses":1}
```
]

After the rollback, `held` is back to 0 and `stock` is back to 2 — exactly the state before
the attempt. That is what a saga buys you: *eventual* atomicity, achieved by writing the
undo yourself.

#formulas(title: "The four rules of a saga that actually works")[
+ *Every step must be idempotent.* A retry of `hold_payment` must not hold twice. Give each
  step a deterministic key derived from the order id.
+ *Every compensation must be idempotent too*, and must tolerate being called for a step
  that may not have fully finished.
+ *Some things cannot be compensated.* You cannot un-send an email or un-deliver food. Put
  those steps *last*, after everything that can fail has already succeeded.
+ *A compensation that fails goes to a human queue with an alarm.* It never silently
  disappears. The `UNDO-FAILED` line in the trace is not decoration.
]
]
]

#practice(tier: 1, time: "35 min")[
+ Extend `geohash` with a `decode` that returns the centre of a cell and its error bounds.
  Verify that `decode(geohash(lat, lng, 7))` is within 100 m of the input.
+ `DriverIndex.neighbourCells` nudges by a fixed 0.045 degrees, which is right for
  5-character cells. Make the step depend on `CELL` so 6 and 7 also work, and prove it by
  checking that exactly 9 distinct cells come back for a point in the middle of a cell.
+ Add surge to the dispatcher: if `nearby()` returns fewer than 3 drivers, multiply the fare
  by a factor. Choose the factor curve and justify the highest value you allow.
+ Make `TopKTrie` support *deletion* of a query whose popularity has collapsed. Explain why
  this is much harder than insertion and what a real system does instead.
+ Add a `hold` and `capture` split to `PaymentService`: authorise now, capture when the food
  is delivered, and expire the authorisation after 7 days. Which ledger entries move, and
  when?
]
#key[
+ A 7-character cell is 153 m x 153 m, so the centre is at most
  $sqrt(76.5^2 + 76.5^2) = 108$ m from any point inside it. Your check should therefore
  allow 110 m, not 100 m. Getting the *error bound* right is the point of the exercise.
+ Step should be roughly the cell's own height in degrees: $180 \/ 2^("latbits")$. For
  6 characters latbits is 15, giving $180\/32768 = 0.0055$ degrees. Nudging by a full cell
  width guarantees you land in the neighbour and not back in your own cell.
+ A sane curve: 1.0x at 3+ drivers, 1.3x at 2, 1.6x at 1, and *refuse to quote* at 0 rather
  than showing 3x. Cap at 2.0x. The reason to cap is not technical — an uncapped multiplier
  during an emergency is a public-relations disaster and in several places is illegal.
+ Deletion is hard because a query sits in the `top` list of *every node along its path*, and
  removing it leaves a hole that must be refilled from the node's subtree — which is exactly
  the expensive search you built this structure to avoid. Real systems do not delete: they
  *rebuild* the whole trie from the last 24 hours of logs, hourly, and swap the new one in
  atomically. Rebuilding 10 GB in the background is far cheaper than supporting deletion.
+ `authorise` moves nothing in the ledger — it is a *promise*, recorded in the payment row
  only. `capture` posts the two legs. Expiry posts nothing either; it just moves the payment
  to `EXPIRED`. *Only capture and refund touch the ledger.* Candidates who post an entry at
  authorisation end up with a ledger whose balance includes money that was never taken.
]

#section[Design 1 — ride-hailing]
#tier-header(2)

#ex(15, tier: 2, asked: "Grab · pattern")[Design a service that matches riders with nearby
drivers, tracks the trip, and prices it. 5 million rides a day, 400,000 drivers online at
peak.
#sol[

#subsection[Step 1 — Clarify]

#table(columns: (1fr, 1fr),
  [*Question I ask*], [*Why the answer changes the design*],
  [How many drivers online at peak, and how often do they ping?],
    [This is the largest write rate in the system by 1000x. It sets the whole architecture.],
  [How fresh must a driver's position be?],
    [2 seconds means memory. 30 seconds means you can batch and relax.],
  [One city at a time, or cross-city trips?],
    [City-scoped means every query and every shard can be city-scoped. Huge simplification.],
  [Must I keep the route the car actually drove?],
    [Yes for disputes and receipts — but downsampled, and only while on a trip.],
  [Can a driver be offered two rides at once?],
    [No. That makes the offer a *hold*, which makes dispatch a locking problem.],
  [Is pricing fixed at request time or at drop-off?],
    [Fixed up front means you quote before you know the route, and eat the variance.],
)

*Answers assumed:* 400,000 drivers online at peak, pinging every 4 s; positions must be under
5 s old; trips are within one city; keep a downsampled trail for 90 days; one offer per
driver at a time; *the fare is quoted up front and honoured.*

#subsection[Step 2 — Scale estimate]

*The location firehose — the number that decides everything.*
$ 400,000 \/ 4 = 100,000 "position updates/second" $
$ 100,000 times 100 "B" = 10,000,000 "B/s" = 10 "MB/s" = 80 "Mbps" $
If every ping were stored:
$ 10,000,000 times 86,400 = 864,000,000,000 "B" = 864 "GB/day" $

*Ride requests — three orders of magnitude smaller.*
$ 5,000,000 \/ 86,400 = 57.9 "requests/second average" $
$ 57.9 times 5 = 289 "requests/second at a Friday-evening peak" $

*Trips in progress* (Little's Law, 20-minute rides):
$ 5,000,000 times 20 \/ 1,440 = 69,444 "average" quad 69,444 times 3 = 208,333 "at peak" $

*The trail we actually keep:* one point per 15 seconds, only while on a trip.
$ 208,333 \/ 15 = 13,889 "writes/second" $
$ 13,889 times 40 "B" = 555,560 "B/s" $
$ 555,560 times 86,400 = 48,000,000,000 "B" = 48 "GB/day" $
That is *18 times less* than storing every ping, and it is the only version anybody will ever
read.

*The live index in memory:*
$ 400,000 times 60 "B" = 24,000,000 "B" = 24 "MB" $

*Connections.* 400,000 driver WebSockets at 100,000 per machine $= 4$ machines of load;
provision 6 as 2/2/2 so one zone can be lost.

#formulas(title: "The board summary")[
100,000 pings/s · 289 ride requests/s at peak · 208,333 trips in progress ·
*24 MB of live index* · 48 GB/day of trail.

*The write load and the read load are in completely different systems.* The pings never touch
a database. The rides never touch the ping path. Say that sentence before you draw anything.
]

#subsection[Step 3 — API surface]

#code(lang: "text", caption: "WebSocket for the things that stream, HTTP for the things that decide")[
```text
WS   /v1/driver/stream                      (driver app, always open)
  up   { t:"ping", lat, lng, heading, speed, ts }      every 4 s
  down { t:"offer", rideId, pickup, dropoff, fareCents, expiresInMs }
  down { t:"cancelled", rideId, reason }

POST /v1/rides
  header Idempotency-Key: 3f9a-...
  body   { riderId, pickup:{lat,lng}, dropoff:{lat,lng}, productId }
  201    { rideId, state:"SEARCHING", quoteCents, quoteExpiresAt }

POST /v1/rides/{rideId}/offers/{offerId}/accept       (driver)
  200    { rideId, state:"MATCHED", riderName, pickup }
  409    { error:"offer_expired" }  |  409 { error:"already_taken" }

GET  /v1/rides/{rideId}
  200    { rideId, state, driver:{id,name,plate,lat,lng}, etaSec }
  note   the rider app polls this every 3 s, OR holds its own WS

POST /v1/rides/{rideId}/complete                      (driver)
  body   { endLat, endLng, distanceM, durationS }
  200    { fareCents, paymentState }
```
]

#trick[
*Say why the driver uses a WebSocket and the rider mostly does not.* The driver's phone must
*receive* an unsolicited offer within 2 seconds — that is a push, and polling for it 400,000
times over would be absurd. The rider is mostly *asking* ("where is my driver?"), which is a
poll, and polling every 3 seconds for the 5 minutes before pickup is 100 requests per ride —
cheap and far simpler to operate. Choose the transport per *direction of initiative*.
]

#subsection[Step 4 — Data model]

#code(lang: "text", caption: "three stores, because three very different access patterns")[
```text
-- IN MEMORY (Redis or an in-process index), never on disk
driver:{id}         hash   lat,lng,cell,status,ts     TTL 60 s
cell:{geohash6}     set    driverIds                  updated on cell change
offer:{rideId}      string driverId                   TTL 12 s (the HOLD)

-- OLTP, sharded by city_id then hashed on ride_id
rides
  ride_id      ulid       PK
  city_id      int        SHARD KEY INPUT
  rider_id     bigint
  driver_id    bigint     null until MATCHED
  state        enum  SEARCHING|MATCHED|ARRIVED|ON_TRIP|DONE|CANCELLED
  quote_cents  bigint     integers only
  fare_cents   bigint     null until DONE
  requested_at, matched_at, started_at, ended_at
  INDEX (rider_id, requested_at DESC)     -- "my trips"
  INDEX (driver_id, requested_at DESC)    -- "my earnings"

-- APPEND-ONLY, time-partitioned, cheap storage
ride_trail
  ride_id, seq, lat, lng, ts        one row per 15 s while ON_TRIP
  PARTITION BY month, dropped after 90 days
```
]

*Why `city_id` and not `rider_id`?* Because every interesting query is city-scoped: the
dispatcher for Singapore never needs a row from Jakarta. Sharding on city means a dispatcher
instance owns a city, holds that city's index in its own memory, and never makes a network
call to match. *The cost:* cities differ in size by 50x, so one shard is huge and another is
tiny. We accept that and give the big cities their own shard, using the directory-router
trick from Chapter 10.

#subsection[Step 5 — Architecture]

#diagram(height: 6.8cm, caption: "The location path (top) and the ride path (bottom) share nothing but the in-memory index. That separation is the design.")[
  #dnode(0pt, 4pt, 60pt, 26pt, "Driver app")
  #dnode(76pt, 4pt, 66pt, 26pt, "Location\ngateway (WS)")
  #dnode(158pt, 4pt, 62pt, 26pt, "Kafka\nlocations")
  #dnode(320pt, 4pt, 68pt, 26pt, "Live index\n(24 MB)", fill: rgb("#dbe7c9"))
  #dnode(236pt, 40pt, 66pt, 24pt, "Trail store", fill: rgb("#f0ece2"))

  #dnode(0pt, 74pt, 60pt, 26pt, "Rider app")
  #dnode(76pt, 74pt, 66pt, 26pt, "API gateway")
  #dnode(158pt, 74pt, 62pt, 26pt, "Trip\nservice")
  #dnode(236pt, 74pt, 66pt, 26pt, "Dispatcher\n(per city)")
  #dnode(320pt, 74pt, 68pt, 26pt, "Push to\ndriver (WS)")

  #dnode(158pt, 134pt, 62pt, 26pt, "Ride store\n(sharded)")
  #dnode(236pt, 134pt, 66pt, 26pt, "Pricing +\nsurge")
  #dnode(320pt, 134pt, 68pt, 26pt, "Payments")

  #darrow(60pt, 17pt, 76pt, 17pt)
  #darrow(142pt, 17pt, 158pt, 17pt)
  #darrow(220pt, 14pt, 320pt, 14pt, label: "upsert")
  #darrow(190pt, 30pt, 258pt, 40pt, dashed: true)
  #place(dx: 120pt, dy: 34pt)[#text(size: 7.5pt, fill: dc)[1 point / 15 s]]

  #darrow(60pt, 87pt, 76pt, 87pt)
  #darrow(142pt, 87pt, 158pt, 87pt)
  #darrow(220pt, 87pt, 236pt, 87pt)
  #darrow(300pt, 74pt, 350pt, 32pt, label: "nearby")
  #darrow(302pt, 87pt, 320pt, 87pt)
  #place(dx: 300pt, dy: 64pt)[#text(size: 7.5pt, fill: dc)[offer]]
  #darrow(189pt, 100pt, 189pt, 134pt)
  #darrow(212pt, 100pt, 250pt, 134pt, label: "quote")
  #darrow(302pt, 147pt, 320pt, 147pt)

  #place(dx: 0pt, dy: 172pt)[#text(size: 8pt, fill: muted)[Solid = on a user's critical path. Dashed = asynchronous. The ping path writes to memory, never to a database.]]
  #place(dx: 0pt, dy: 182pt)[#text(size: 8pt, fill: muted)[One dispatcher process owns one city and holds that city's index locally, so a match needs zero network calls.]]
]

*Trace one ride, end to end:*
+ Driver phones stream pings into the location gateway over their open WebSocket. The
  gateway does *no work* except validate and publish to Kafka.
+ A consumer applies each ping to the live index: update `driver:{id}`, and if the geohash
  cell changed, move the id between two sets. Cost per ping: two hash operations.
+ Separately, a second consumer writes one trail row every 15 seconds for drivers who are
  `ON_TRIP`. This is the only thing that touches a disk.
+ `POST /v1/rides` arrives. The trip service writes a `SEARCHING` row, asks pricing for a
  quote, and hands the request to the city's dispatcher.
+ The dispatcher runs `nearby()` in its own memory — 9 cells, ~299 candidates, exact
  distances, sorted. It places a 12-second hold on the best driver and pushes an offer down
  that driver's WebSocket.
+ Driver accepts: the ride row moves to `MATCHED`, the hold becomes `ON_TRIP`, the rider is
  told. Driver ignores: the hold expires, the driver returns to `AVAILABLE`, and the
  dispatcher offers the next candidate — excluding the one who just ignored it.
+ At drop-off the fare is finalised and the payment is a separate, idempotent call.

#subsection[Step 6a — Deep dive: never write a ping to a database]

Suppose you did. 100,000 writes/second against a store doing 5,000 writes/second per node
needs $100,000 \/ 5,000 = 20$ nodes, purely to record data that is *worthless one second
later*, and 864 GB a day to store it.

#formulas(title: "The three-layer answer, with the cost of each")[
+ *Layer 1 — the live index, in memory.* 24 MB. Answers every dispatch query. Lost on
  restart, which costs nothing: within 4 seconds every online driver has pinged again and
  the index has rebuilt itself. *This is the rarest kind of state: important and disposable.*
+ *Layer 2 — Kafka, for 24 hours.* $10 "MB/s" times 86,400 = 864$ GB of retention. This is
  the replay buffer: if the indexing consumer has a bug, you fix it and replay. Kafka is
  cheap for this because it is a sequential append and never a random write.
+ *Layer 3 — the trail, on disk, downsampled.* 48 GB/day, 90 days $= 4.32$ TB, partitioned by
  month so deleting old data is a partition drop, not 4 billion `DELETE`s.
]

*What we gave up.* You cannot ask "where was driver 55 at 10:04 last Tuesday if they were not
on a trip?" We decided that question has no business value that justifies 864 GB a day.
State the decision, not just the design.

#subsection[Step 6b — Deep dive: two riders, one driver]

At peak, 289 requests/second arrive across all cities. In a dense city centre at 6 p.m., two
requests 400 m apart can legitimately see the same nearest driver within the same 50 ms.

*Wrong fix:* "check if the driver is available, then offer". Two dispatchers both read
`AVAILABLE`, both offer, and the driver's phone shows two ride cards. Whichever they tap, the
other rider is now stranded and must be re-dispatched, having already waited.

*Right fix — the offer is a conditional write:*
#code(lang: "text", caption: "the only safe order")[
```text
WRONG:  if (status == AVAILABLE) { status = OFFERED; send(offer); }
RIGHT:  SET offer:{driverId} = rideId  NX  EX 12
        -> if the SET returns "already exists", this driver is taken:
           move to the next candidate, do not send anything
```
]

`NX` means "only if absent" and `EX 12` means "expire in 12 seconds". The store decides,
atomically, and the loser finds out in microseconds rather than after the driver taps.

*What if the dispatcher crashes while holding offers?* Nothing needs cleaning up. Every hold
has a 12-second TTL, so the whole system self-heals within 12 seconds with no recovery code
at all. *Expiry-based state is the cheapest form of fault tolerance there is.*

#subsection[Step 6c — Deep dive: the quote you promised before you knew the route]

The rider is quoted a fare before the trip starts. The trip then takes a different route,
hits traffic, and costs you more than you charged.

#formulas(title: "Where the money actually goes, per 1,000 rides")[
Suppose the quote is based on the predicted distance and duration, and the real trip differs.
If 1,000 rides average a quote of 1,200 cents and the realised cost averages 1,260 cents,
the loss is
$ 1,000 times (1,260 - 1,200) = 60,000 "cents" = 600 "currency units per 1,000 rides" $
$ "as a fraction" = 60 \/ 1,200 = 5% "of revenue" $
Five percent is not a rounding error; it is often the entire margin.

*Three ways to close it, and what each costs:*
+ *Quote a range, charge the actual.* Removes the risk entirely. *Cost:* riders hate it, and
  conversion drops measurably, because people will not tap a button that says "800 to 1,400".
+ *Quote fixed, and improve the prediction.* Feed the estimator real trail data: this road at
  this hour takes this long. *Cost:* a whole model and pipeline, and it is never perfect.
+ *Quote fixed, and add a variance buffer.* Price at the *75th percentile* of predicted cost
  instead of the mean. *Cost:* you are slightly expensive on typical trips, which loses some
  bookings.

*Decision: fixed quote priced at the 75th percentile, plus a hard rule that the fare only
changes if the rider changes the destination.* A fixed price is worth more in conversion than
the 5% costs, and the one exception — the rider moved the pin — is the one case where a
price change feels fair to a human.
]

#subsection[Step 7 — Trade-offs, failure modes, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Positions], [persist every ping], [memory + downsampled trail],
    [*B* — 24 MB versus 864 GB/day for data read once],
  [Geo index], [database `GEOSPATIAL` index], [geohash cells in memory],
    [*B* — 100,000 writes/s is not a database workload],
  [Driver transport], [HTTP polling], [WebSocket],
    [*B* — offers are pushes and must land in 2 s],
  [Rider transport], [WebSocket], [poll every 3 s],
    [*B* — the rider asks, never receives unsolicited; polling is 100 calls/ride],
  [Offer], [read-then-write], [`SET NX EX`],
    [*B* — atomic, self-expiring, needs no crash recovery],
  [Matching], [global optimiser over all pairs], [greedy nearest, per request],
    [*B* — greedy is 2 ms and within a few percent of optimal at this density],
  [Shard key], [`rider_id`], [`city_id`],
    [*B* — dispatch is city-scoped, so a match needs zero cross-shard work],
  [Fare], [meter at drop-off], [fixed quote at the 75th percentile],
    [*B* — conversion is worth more than the 5% variance],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [The live index process dies],
    [Dispatch stops in that city for ~5 s],
    [It rebuilds itself from the next round of pings — every driver pings within 4 s. Keep a
     hot standby consuming the same Kafka partitions so the gap is under a second.],
  [Kafka is slow],
    [Positions go stale, ETAs get worse],
    [The gateway drops the *oldest* ping per driver rather than buffering. A newer position
     makes an older one worthless, so dropping is correct here — the rare case where losing
     data is the right answer.],
  [A driver's phone loses signal mid-trip],
    [Rider's map freezes],
    [The trip does not cancel. The trail resumes when signal returns; the fare uses the
     completed-trip report, cross-checked against the trail.],
  [Two dispatchers offer the same driver],
    [Cannot happen],
    [`SET NX` makes it impossible. The loser never sends anything.],
  [Dispatcher crashes holding 50 offers],
    [50 riders wait up to 12 extra seconds],
    [Holds expire on their own. No recovery code, no cleanup job.],
  [Surge multiplier misconfigured to 9x],
    [Outrage],
    [A hard cap in code, not in config, and an alarm on any city exceeding 2.0x for more
     than 10 minutes.],
  [One city's shard is overloaded],
    [Slow matching in that city only],
    [The blast radius is exactly one city, which is *why* we sharded by city. Move that city
     to its own shard via the directory router.],
)

*At 10x (50 million rides/day, 4 million drivers online):*
- Pings become $4,000,000 \/ 4 = 1,000,000$/second and 100 MB/s. Kafka handles it with
  $100 \/ 10 = 10$ partitions of throughput, but we would use far more for consumer
  parallelism.
- The live index becomes $4,000,000 times 60 = 240$ MB. Still trivially in memory — *but not
  in one process's memory if that process must also serve dispatch for every city*. The fix
  is the one we already built in: one dispatcher per city, each holding only its own city.
  At 10x this stops being an optimisation and becomes the only way it works.
- Trips in progress become 2,083,333 and the trail becomes 480 GB/day, 43.2 TB over 90 days.
  Now storage is real: compress the trail (consecutive points differ by a few metres, so
  delta-encoding cuts it by roughly 4x) and drop to one point per 30 seconds for the middle
  of a trip while keeping 5-second resolution near pickup and drop-off, where disputes
  actually happen.
- The genuinely new problem at 10x is *matching quality*, not throughput. Greedy nearest
  leaves value on the table when 40 riders and 40 drivers are in the same square kilometre.
  Batch requests into 2-second windows and solve an assignment problem over the batch.
  *Cost:* every rider waits up to 2 extra seconds. *Benefit:* measurably shorter pickups
  fleet-wide. *Decision: batch only in the top 20 dense cells of a city, where the win is
  real, and stay greedy everywhere else.*
]
]

#section[Design 2 — food delivery]
#tier-header(2)

#ex(16, tier: 2, asked: "Shopee · pattern")[Design a food-delivery service: 2 million orders
a day, three parties per order (customer, restaurant, courier), and a lunch rush that
concentrates a third of the day into two hours.
#sol[

#subsection[Step 1 — Clarify]

*Questions and the assumptions I will state out loud:* 2 million orders/day; *35% of them
land in a 2-hour lunch window*; 120,000 couriers online at peak, pinging every 5 s; a courier
may carry up to 3 orders at once; restaurants confirm or reject within 90 seconds; payment is
authorised at order time and captured at delivery; the customer must see live status.

#subsection[Step 2 — Scale estimate]

$ 2,000,000 \/ 86,400 = 23.1 "orders/second average" $
$ 2,000,000 times 0.35 = 700,000 "orders in the lunch window" $
$ 700,000 \/ 7,200 "s" = 97.2 "orders/second at lunch" $

The peak factor here is $97.2 \/ 23.1 = 4.2 times$, and it is *predictable to the minute*.
That is a gift: you can scale up at 11:15 and down at 14:00 on a schedule, instead of
reacting.

*Courier pings.*
$ 120,000 \/ 5 = 24,000 "updates/second" $
A quarter of the ride-hailing firehose, handled by exactly the same three-layer design.

*Trips, with batching.* Three drops per trip:
$ 97.2 \/ 3 = 32.4 "courier trips/second at lunch" $

*Storage.* One order plus its items and status history: about 1.5 KB.
$ 2,000,000 times 1,500 = 3,000,000,000 "B" = 3 "GB/day" $
$ 3 times 365 = 1,095 "GB/year" approx 1.1 "TB/year" $

*Status reads.* A customer watches the map. Assume 60 status polls per order over 35 minutes:
$ 2,000,000 times 60 = 120,000,000 "reads/day" = 1,389 "reads/second average" $
At lunch, $1,389 times 4.2 = 5,834$ reads/second. Every one of them is served from a cache
keyed by order id, refreshed by the event stream.

#subsection[Step 3 — API surface]

#code(lang: "text", caption: "the transitions are the API")[
```text
POST /v1/orders
  header Idempotency-Key: 7c21-...
  body   { customerId, restaurantId, items[], addressId, promoCode,
           paymentMethodId }
  201    { orderId, state:"PLACED", etaMinutes, totalCents }
  409    { error:"restaurant_closed" | "item_unavailable" }

POST /v1/orders/{orderId}/transitions          (restaurant / courier app)
  body   { to:"CONFIRMED"|"PREPARING"|"READY"|"PICKED_UP"|"DELIVERED",
           actor, at }
  200    { orderId, state }
  409    { error:"illegal_transition", from, to }

GET  /v1/orders/{orderId}/live
  200    { state, courier:{lat,lng,etaSec}, preparedAt, asOf }
  note   served from cache; asOf tells the app how fresh it is

POST /v1/orders/{orderId}/cancel
  body   { by:"customer"|"restaurant", reason }
  200    { orderId, state:"CANCELLED", refundCents }
  note   refundCents depends on state: full before CONFIRMED,
         partial after PREPARING, none after PICKED_UP
```
]

#subsection[Step 4 — The state machine is the data model]

#diagram(height: 5.4cm, caption: "Every transition names who may trigger it. A transition not on this diagram returns 409, and that rule lives in one place in the code.")[
  #dnode(0pt, 22pt, 62pt, 26pt, "PLACED")
  #dnode(78pt, 22pt, 68pt, 26pt, "CONFIRMED")
  #dnode(162pt, 22pt, 68pt, 26pt, "PREPARING")
  #dnode(246pt, 22pt, 56pt, 26pt, "READY")
  #dnode(318pt, 22pt, 68pt, 26pt, "PICKED UP")
  #dnode(402pt, 22pt, 68pt, 26pt, "DELIVERED", fill: rgb("#dbe7c9"))

  #dnode(78pt, 96pt, 68pt, 26pt, "CANCELLED", fill: rgb("#f7e3e3"))
  #dnode(180pt, 96pt, 68pt, 26pt, "REFUNDED", fill: rgb("#f7e3e3"))

  #darrow(62pt, 35pt, 78pt, 35pt)
  #darrow(146pt, 35pt, 162pt, 35pt)
  #darrow(230pt, 35pt, 246pt, 35pt)
  #darrow(302pt, 35pt, 318pt, 35pt)
  #darrow(386pt, 35pt, 402pt, 35pt)

  #darrow(28pt, 48pt, 90pt, 96pt, label: "customer")
  #darrow(112pt, 48pt, 112pt, 96pt, label: "shop")
  #darrow(146pt, 109pt, 180pt, 109pt)

  #place(dx: 0pt, dy: 4pt)[#text(size: 7.5pt, fill: muted)[customer]]
  #place(dx: 80pt, dy: 4pt)[#text(size: 7.5pt, fill: muted)[restaurant]]
  #place(dx: 164pt, dy: 4pt)[#text(size: 7.5pt, fill: muted)[restaurant]]
  #place(dx: 248pt, dy: 4pt)[#text(size: 7.5pt, fill: muted)[restaurant]]
  #place(dx: 320pt, dy: 4pt)[#text(size: 7.5pt, fill: muted)[courier]]
  #place(dx: 404pt, dy: 4pt)[#text(size: 7.5pt, fill: muted)[courier]]

  #place(dx: 0pt, dy: 130pt)[#text(size: 8pt, fill: muted)[There is no arrow out of PICKED UP except DELIVERED: once food is in the bag, the order completes and a refund is a separate decision.]]
]

#code(lang: "text", caption: "the tables")[
```text
orders
  order_id      ulid     PK
  city_id       int      SHARD KEY INPUT
  customer_id, restaurant_id, courier_id (null until assigned)
  state         enum
  total_cents   bigint   integers
  placed_at, confirmed_at, ready_at, picked_at, delivered_at
  version       int      optimistic lock on transitions
  INDEX (customer_id, placed_at DESC)
  INDEX (restaurant_id, state)       -- the restaurant's tablet

order_events                          -- append-only, same shard
  order_id, seq, from_state, to_state, actor, at, note

courier_trips                         -- one row per batched trip
  trip_id, courier_id, order_ids[], started_at, ended_at
```
]

#subsection[Step 5 — Deep dive: there is no transaction across four services]

Placing an order must hold the payment, reserve the items, find a courier, and burn the
promo. Four services, four databases. A two-phase commit across them would block all four
whenever the coordinator died — during the lunch rush.

*We use the saga from Piece 6.* The order of the steps is the design decision:

#table(columns: (auto, 1fr, 1fr),
  [*Step*], [*Why it is here in the order*], [*Compensation*],
  [1 hold payment],
    [Fails most often (declined card). Fail early, before anyone does work.],
    [release the hold — free, instant],
  [2 reserve items],
    [Cheap and reversible. Must happen before the restaurant is told.],
    [return the stock],
  [3 assign courier],
    [The likeliest *capacity* failure at lunch. Still fully reversible.],
    [release the courier],
  [4 burn promo],
    [Reversible but annoying to reverse; do it once everything else succeeded.],
    [restore the promo use],
  [5 notify restaurant],
    [*Not compensable.* A printed ticket cannot be unprinted. Therefore last.],
    [none — this is why it is last],
)

#trap[
*Order your saga steps by "likely to fail" first and "impossible to undo" last.* Candidates
usually list the steps in the order a product manager says them, which puts "tell the
restaurant" early — and then the rollback has to phone a human. The ordering *is* the answer
to this question.
]

#subsection[Step 6 — Deep dive: batching three orders onto one courier]

A courier carrying 3 orders costs a third as much per order, but every extra stop makes the
*first* customer's food later.

#formulas(title: "The arithmetic of a batch, per order")[
Assume a single delivery is 18 minutes door to door and each extra stop adds 7 minutes.

#table(columns: (auto, auto, auto, auto),
  [*Batch size*], [*Total trip*], [*Cost per order (at 100 per trip)*], [*Worst customer waits*],
  [1], [18 min], [100], [18 min],
  [2], [25 min], [50], [25 min],
  [3], [32 min], [33.3], [32 min],
  [4], [39 min], [25], [39 min],
)

Going from 1 to 3 cuts cost per order by $(100 - 33.3)\/100 = 66.7%$ and adds 14 minutes to
the unluckiest customer. Going from 3 to 4 saves a further
$(33.3 - 25)\/33.3 = 25%$ and adds another 7 minutes.

*Decision: cap the batch at 3, and only batch orders whose restaurants are within 800 m of
each other and whose drop-offs are within 1.5 km.* The 1-to-3 step is where almost all the
saving is; the 3-to-4 step buys a quarter as much for the same 7-minute penalty. And the
distance rules are what make the "+7 minutes per stop" assumption true in the first place —
without them a batch is two trips pretending to be one.
]

#subsection[Step 7 — Trade-offs and failures]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Order placement], [two-phase commit], [saga with compensations],
    [*B* — 2PC blocks everyone when the coordinator dies, at lunch],
  [Restaurant notify], [first step], [last step],
    [*B* — it is the one step that cannot be undone],
  [Batch size], [up to 4], [up to 3, with distance rules],
    [*B* — 1-to-3 captures 67% of the saving; 3-to-4 adds 7 min for 8%],
  [Live status], [query the order shard], [cache keyed by order id, fed by events],
    [*B* — 5,834 reads/s at lunch against 97 writes/s],
  [Scaling for lunch], [autoscale on CPU], [scheduled scale-up at 11:15],
    [*B* — the spike is 4.2x in 15 minutes; reactive autoscaling is always late],
  [Cancellation], [always refundable], [refund depends on state],
    [*B* — after PREPARING the food is real and someone paid for it],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [Restaurant never confirms],
    [Order sits at PLACED],
    [A 90-second timer auto-cancels with a full refund and suggests three nearby
     alternatives. Silence must always have a deadline.],
  [No courier at lunch peak],
    [Longer ETA, or "we cannot deliver right now"],
    [Widen the search radius in stages, then raise courier pay for that zone, then stop
     accepting orders for it. Refusing an order beats accepting one you cannot deliver.],
  [Payment authorisation expires before delivery],
    [Charge fails at the end],
    [Authorisations last 7 days; a 35-minute order never comes close. Alarm if any order
     exceeds 6 hours between authorise and capture.],
  [A compensation fails],
    [Nothing, yet],
    [It goes to a human queue with an alarm. Never retried silently forever, never dropped.],
  [The same transition arrives twice],
    [Nothing],
    [Transitions are idempotent by `(order_id, to_state)`, and the state machine rejects
     anything not on the diagram with a 409.],
)
]
]

#practice(tier: 2, time: "40 min")[
+ Recompute the ride-hailing firehose for a 2-second ping interval instead of 4. What
  improves, what costs more, and would you do it?
+ A city has 2,000 drivers online and 900 ride requests in one minute. Compute the requests
  per available driver and say what the design should do when that ratio goes above 1.
+ Design the courier-batching decision as a function: given a new order and a list of
  in-progress trips, return the trip to join or `null`. State the inputs and the cut-offs.
+ The lunch peak is 4.2x and perfectly predictable. Write the scaling plan with times,
  target capacity and the rollback trigger.
+ A restaurant's tablet loses Wi-Fi for 20 minutes during lunch. Walk through every order
  that arrives in that window and what the system does with each.
]
#key[
+ Pings double to $400,000 \/ 2 = 200,000$/s and 20 MB/s; Kafka retention doubles to 1.73 TB
  a day. What improves is position freshness — the worst-case staleness halves from 4 s to
  2 s, which moves a map marker about 14 m at 25 km/h. *Decision: no.* Doubling the largest
  write rate in the system to move a dot 14 metres is not a trade worth making; spend that
  budget on interpolating the marker's movement client-side instead, which costs nothing.
+ $900 \/ 60 = 15$ requests/second against 2,000 drivers. Over one minute that is 900
  requests for 2,000 drivers, a ratio of 0.45 — comfortable. Above 1.0 you are *structurally*
  short of supply, and the honest responses in order are: widen the radius, raise the
  multiplier to pull more drivers online, then show longer ETAs, then stop quoting. Queuing
  riders invisibly is the one option that is always wrong.
+ Inputs: the new order's restaurant location, drop-off, ready time; each trip's current
  stops and courier position. Cut-offs: restaurants within 800 m, drop-offs within 1.5 km,
  resulting batch size $lt.eq 3$, and *no existing customer's ETA increases by more than 8
  minutes*. Return the trip with the smallest added distance that passes all four. That last
  cut-off is the one that keeps the batch honest.
+ Scale to 4.5x at 11:15, hold until 14:00, scale down in two steps by 14:30. Repeat for
  dinner. Rollback trigger: p99 order-placement latency above 800 ms, or saga step-3 failure
  rate above 2%, either of which means capacity is short despite the plan — then add 50% and
  page.
+ Orders arriving in that window get no confirmation, so each one hits the 90-second timer
  and auto-cancels with a full refund. That is correct but terrible for the restaurant. The
  fix is to detect the *tablet* being offline (it heartbeats every 30 s) and mark the whole
  restaurant temporarily closed after two missed heartbeats, so new orders are never accepted
  at all. Detecting the dependency is better than compensating 40 separate orders.
]

#section[Design 3 — video streaming]
#tier-header(3)

#ex(17, tier: 3, asked: "Google · pattern")[Design a video platform: 100 million daily
viewers watching 40 minutes each, 500,000 uploads a day. Make it work on a phone on a train.
#sol[

#subsection[Step 1 — Clarify]

*Questions and the answers I assume:* 100 million DAU, 40 minutes each; 500,000 uploads/day,
10 minutes average; playback must start in under 2 seconds; quality must adapt to a changing
network; live streaming is *out of scope* (say this — it is a completely different system);
content is global, so a viewer in Jakarta must not be served from Virginia.

#subsection[Step 2 — Scale estimate]

*Concurrent viewers.*
$ 100,000,000 times 40 = 4,000,000,000 "watch-minutes/day" $
$ 4,000,000,000 \/ 1,440 = 2,777,778 "average concurrent" $
$ times 3 = 8,333,333 "at peak" $

*Egress — the headline number.* At an average 3 Mbps:
$ 8,333,333 times 3 "Mbps" = 25,000,000 "Mbps" = 25 "Tbps at peak" $
$ 4,000,000,000 times 60 times 3,000,000 \/ 8 = 9.0 times 10^16 "B" = 90 "PB/day" $

*What the origin must serve,* if the CDN offloads 95%:
$ 25 times 0.05 = 1.25 "Tbps" $
That is still 20 machines' worth of 10 Gbps network cards, and it is the number the rest of
the design has to hit.

*Storage from uploads.* Ladder total 9.9 Mbps, 10-minute average:
$ 9.9 times 10^6 times 600 \/ 8 = 742,500,000 "B" = 742.5 "MB per video" $
$ 500,000 times 742.5 "MB" = 371.25 "TB/day" $
$ 371.25 times 365 = 135,506 "TB" = 135.5 "PB/year" $

*Transcoding compute.* Five renditions of a 10-minute video, at half real time per rendition:
$ 10 times 5 times 0.5 = 25 "CPU-minutes per video" $
$ 500,000 times 25 = 12,500,000 "CPU-minutes/day" $
$ 12,500,000 \/ 1,440 = 8,681 "cores running continuously" $

#formulas(title: "The board summary")[
25 Tbps peak · 90 PB/day egress · 1.25 Tbps of origin · 135.5 PB/year of new storage ·
8,681 cores of transcoding.

*The first sentence out loud:* "This is a bandwidth problem, not a request problem. The CDN
is not an optimisation here — it is the product. At \$0.01 per GB, 90 PB a day is
\$900,000 a day, which is why a platform this size builds its own edge and peers directly
with ISPs."
]

#subsection[Step 3 — API surface]

#code(lang: "text", caption: "note that no API ever returns video bytes")[
```text
POST /v1/videos
  body   { title, description, visibility }
  201    { videoId, uploadUrl, uploadToken }
  note   uploadUrl is a pre-signed URL straight to object storage.
         The bytes NEVER pass through your API. This is the whole trick.

PUT  <uploadUrl>            (client -> object storage, resumable, chunked)
  note   chunked so a phone on a train can resume, not restart

GET  /v1/videos/{videoId}/manifest.m3u8
  200    the HLS master manifest: one line per rendition, with bitrate
         and a URL to that rendition's own chunk list
  note   cached at the edge for 60 s; this is the only "API" playback hits

GET  <cdn>/v/{videoId}/{rendition}/{chunkNo}.ts
  200    a 4-second chunk, ~1.5 MB at 3 Mbps
  note   served by the CDN. Your origin sees this only on a cache miss.

POST /v1/videos/{videoId}/heartbeat
  body   { positionSec, rendition, bufferHealthMs, droppedFrames }
  204
  note   fire-and-forget analytics; never blocks playback
```
]

#subsection[Step 4 — Data model]

#code(lang: "text", caption: "metadata is tiny; the bytes live somewhere else entirely")[
```text
videos                                   (sharded by video_id, hashed)
  video_id     ulid    PK
  owner_id     bigint
  title, description, tags
  duration_s   int
  state        enum  UPLOADING|TRANSCODING|READY|FAILED|TAKEN_DOWN
  renditions   json  [{h:1080,bitrate:5000000,path:"..."}, ...]
  created_at

-- object storage, NOT a database. Path is the key.
/v/{video_id}/source.mp4                 -- deleted 30 days after READY
/v/{video_id}/1080p/{0000..NNNN}.ts      -- 4-second chunks
/v/{video_id}/1080p/index.m3u8
/v/{video_id}/master.m3u8

watch_events                             -- append-only stream, not a table
  video_id, user_id, position_s, rendition, ts
```
]

*Why the source file is deleted after 30 days:* it is 30--40% of all your stored bytes and it
is read exactly once, by the transcoder. Keeping it for 30 days covers "we need to re-encode
with a better codec". Keeping it forever costs roughly
$135.5 "PB/year" times 0.35 = 47$ PB a year for nothing.

#subsection[Step 5 — Architecture]

#diagram(height: 6.4cm, caption: "Upload and transcode along the top; playback along the bottom. The two paths meet only at object storage, and the viewer never touches your API for bytes.")[
  #dnode(0pt, 4pt, 62pt, 26pt, "Uploader")
  #dnode(80pt, 4pt, 70pt, 26pt, "Object store\n(source)", fill: rgb("#f0ece2"))
  #dnode(168pt, 4pt, 66pt, 26pt, "Transcode\nqueue")
  #dnode(252pt, 4pt, 70pt, 26pt, "Workers\n(8,681 cores)")
  #dnode(340pt, 4pt, 74pt, 26pt, "Packager\n(HLS chunks)")

  #dnode(168pt, 56pt, 74pt, 28pt, "Object store\n(renditions)", fill: rgb("#f0ece2"))
  #dnode(276pt, 56pt, 74pt, 28pt, "Metadata DB\n(videos)")

  #dnode(0pt, 108pt, 62pt, 26pt, "Player")
  #dnode(80pt, 108pt, 70pt, 26pt, "Edge CDN\n(95% of bytes)", fill: rgb("#dbe7c9"))
  #dnode(168pt, 108pt, 74pt, 26pt, "Origin shield\n(1.25 Tbps)")
  #dnode(276pt, 108pt, 74pt, 26pt, "Manifest API")

  #darrow(62pt, 17pt, 80pt, 17pt)
  #place(dx: 56pt, dy: 34pt)[#text(size: 7.5pt, fill: dc)[pre-signed URL]]
  #darrow(150pt, 17pt, 168pt, 17pt)
  #darrow(234pt, 17pt, 252pt, 17pt)
  #darrow(322pt, 17pt, 340pt, 17pt)
  #darrow(360pt, 30pt, 230pt, 56pt)
  #place(dx: 226pt, dy: 34pt)[#text(size: 7.5pt, fill: dc)[write chunks]]
  #darrow(300pt, 30pt, 300pt, 56pt, dashed: true)
  #place(dx: 304pt, dy: 36pt)[#text(size: 7.5pt, fill: dc)[mark READY]]

  #darrow(62pt, 121pt, 80pt, 121pt)
  #place(dx: 56pt, dy: 92pt)[#text(size: 7.5pt, fill: dc)[chunk request]]
  #darrow(150pt, 121pt, 168pt, 121pt)
  #place(dx: 148pt, dy: 92pt)[#text(size: 7.5pt, fill: dc)[5% miss]]
  #darrow(205pt, 108pt, 205pt, 84pt)
  #darrow(242pt, 115pt, 276pt, 115pt)
  #darrow(313pt, 108pt, 313pt, 84pt, dashed: true)

  #place(dx: 0pt, dy: 152pt)[#text(size: 8pt, fill: muted)[Bytes never pass through an application server: upload goes straight to object storage, playback comes straight from the CDN.]]
  #place(dx: 0pt, dy: 162pt)[#text(size: 8pt, fill: muted)[Your services only ever handle *metadata and manifests*, which are kilobytes.]]
]

#subsection[Step 6a — Deep dive: adaptive bitrate, and why the client decides]

The phone on the train has 6 Mbps, then 0.5 Mbps in a tunnel, then 6 Mbps again. A fixed
quality either stalls or looks bad.

#formulas(title: "How the switch actually works")[
+ The master manifest lists every rendition with its bitrate. The *player* picks.
+ The player measures how long the last chunk took. A 1.5 MB chunk that took 6 seconds means
  about $1.5 times 8 \/ 6 = 2$ Mbps of real throughput.
+ It also watches its *buffer*: how many seconds of video are already downloaded.
+ Rule of thumb: step *down* immediately when the buffer falls below ~10 seconds; step *up*
  only after several good chunks and a buffer above ~25 seconds. Down fast, up slow — because
  a stall is far worse than a soft-looking picture.
+ Chunk length is the knob: 4 seconds is the usual compromise. *2-second chunks* adapt faster
  and start faster but double the request count and hurt compression. *10-second chunks*
  compress better but mean 10 seconds of the wrong quality after a network change.

*Decision: 4-second chunks, with the first two chunks of every video also published at
2 seconds.* The short opening chunks cut time-to-first-frame, which is the metric viewers
actually feel, and the cost is two extra tiny files per video.
]

*Why the client and not the server?* Only the client knows its own buffer and its own screen.
A server-side decision would need a control loop over a network it cannot measure. Handing
the decision to the player also makes every chunk a plain, cacheable, immutable file — which
is what lets a CDN serve 95% of your bytes without asking you anything.

#subsection[Step 6b — Deep dive: making the CDN hit rate 95% and not 60%]

#formulas(title: "Where the hit rate actually comes from")[
Video viewing is extremely skewed: a small set of videos is most of the traffic. Suppose the
top 10,000 videos are 80% of all watch time.
$ 10,000 times 742.5 "MB" = 7,425,000 "MB" = 7.4 "TB" $
*Seven terabytes holds 80% of your traffic.* That fits on the SSDs of a single edge rack, in
every city you operate in. This one calculation is the argument for the whole CDN tier, and
it is the calculation candidates never do.

Three rules that get you from 80% to 95%:
+ *Immutable URLs.* A chunk's content never changes, so cache it for a year. If you need to
  replace a video, publish new paths. Never invalidate.
+ *An origin shield.* Edges do not each fetch from origin; they fetch from one regional
  shield. With 200 edges, this turns 200 misses for a new video into 1.
+ *Pre-warm the predictable.* A popular creator's upload, a scheduled release: push it to
  edges *before* anyone asks. The first 100,000 viewers then find it already there.
]

*What the remaining 5% costs.* $25 times 0.05 = 1.25$ Tbps. At 10 Gbps per machine,
$1,250 \/ 10 = 125$ machines of pure network, before any headroom. If the hit rate fell to
90%, that doubles to 250 machines. *A 5-point change in cache hit rate is 125 machines.* Say
the number; it makes the whole tier concrete.

#subsection[Step 6c — Deep dive: transcoding 500,000 videos a day without a queue backlog]

8,681 cores running continuously is the *average*. Uploads are not flat — assume a 3x peak,
so 26,043 cores at the busy hour.

#formulas(title: "Three decisions that make this affordable")[
+ *Split the video into chunks and transcode them in parallel.* A 10-minute video becomes 150
  four-second chunks, each independently encodable. One video's latency drops from 25 minutes
  of CPU to about *30 seconds of wall clock* on 50 workers, and the work is now perfectly
  parallel and perfectly retryable.
+ *Prioritise the ladder.* Publish 360p first and mark the video `READY` the moment it
  exists. 1080p can finish minutes later. The creator sees a working video in under a minute;
  the expensive rendition arrives while nobody is looking.
+ *Use spot / preemptible capacity for the high renditions.* A chunk that is killed halfway is
  simply re-queued — it is idempotent by construction, keyed by
  `(video_id, rendition, chunk_no)`. Typical saving is 60--80% of the compute bill for the
  renditions that are most of the cost.

*What this costs:* a video is briefly available only in 360p, so a viewer in the first
two minutes may see a soft picture. *Decision: accept it.* The alternative is making every
creator wait 25 minutes before their video exists at all.
]

#subsection[Step 7 — Trade-offs, failure modes, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Upload path], [through your API], [pre-signed URL to object storage],
    [*B* — 371 TB/day must never touch an application server],
  [Quality choice], [server decides], [client decides from buffer + throughput],
    [*B* — only the client can measure its own link, and chunks stay cacheable],
  [Chunk length], [10 s, better compression], [4 s, plus 2 s opening chunks],
    [*B* — time-to-first-frame is the metric viewers feel],
  [Source file], [keep forever], [delete 30 days after READY],
    [*B* — saves ~47 PB/year of write-once, read-once data],
  [Transcode unit], [whole video per worker], [per chunk, parallel],
    [*B* — 25 min of CPU becomes 30 s of wall clock, and retries are free],
  [High renditions], [on-demand, dedicated capacity], [spot capacity, re-queue on kill],
    [*B* — chunk work is idempotent, so preemption costs nothing but time],
  [Cache invalidation], [purge on change], [immutable paths, never purge],
    [*B* — a purge across 200 edges is slow and unreliable; new paths are instant],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [One edge node dies],
    [A brief rebuffer, then normal],
    [The player retries the same chunk URL; DNS or anycast routes it to a sibling edge.
     Immutable URLs mean any edge can serve it.],
  [Origin shield is overwhelmed],
    [Stalls on unpopular videos only],
    [Popular content is already at the edge. Shed misses for rare videos with a 503 and let
     the player retry — degrade the tail, protect the head.],
  [A transcode worker is preempted],
    [Nothing],
    [The chunk is re-queued. Keyed by `(video_id, rendition, chunk_no)`, so a duplicate
     simply overwrites an identical file.],
  [Transcoding backlog grows],
    [Uploads take longer to appear],
    [Alarm on queue age, not queue depth. Shed the 1080p work first: the video still becomes
     watchable, and the backlog clears 4x faster.],
  [A video must be taken down],
    [It disappears],
    [Flip the metadata state and the manifest returns 410. Then purge — but the manifest
     block is instant and the purge is best-effort cleanup.],
  [A region loses connectivity],
    [Viewers there fail over to a neighbouring region],
    [Latency rises, quality steps down, playback continues. Because bytes are immutable and
     stateless, failover is a routing change and nothing else.],
)

*At 10x (1 billion DAU-equivalent, 250 Tbps):*
- 250 Tbps is beyond what any commercial CDN will sell you as a line item. You *are* the CDN:
  your own hardware inside ISP networks, which also removes most of the \$9,000,000-a-day
  transit bill.
- Storage becomes 1.36 EB a year of new video. Tiering becomes the main design: keep the
  hot 1% on SSD, the warm 9% on disk, and move the cold 90% to archival storage where the
  first byte takes minutes. A video nobody has watched for two years can take 3 minutes to
  start, and no one will ever notice.
- Transcoding becomes 86,810 cores. At this scale you stop buying general CPUs for it and
  move to dedicated encoding hardware, which is roughly an order of magnitude cheaper per
  stream.
- The genuinely new problem is *the long tail*. At 10x, the number of videos watched once a
  month grows faster than the head does, and those are exactly the ones that always miss the
  cache. *Decision: do not try to cache them.* Serve the tail from the origin at a lower
  starting rendition, accept a 400 ms time-to-first-frame instead of 150 ms, and spend the
  saved money keeping the head at 99% hit rate.
]
]

#section[Design 4 — search autocomplete]
#tier-header(3)

#ex(18, tier: 3, asked: "Amazon · pattern")[Design search-as-you-type: 2 billion searches a
day, suggestions in under 100 ms, and new trending queries must appear within an hour.
#sol[

#subsection[Step 1 — Clarify]

*Assumptions stated out loud:* 2 billion searches/day; the client debounces and sends about 4
prefix requests per search; the budget is *100 ms end to end, so 50 ms in my service*; the
top 10 suggestions are enough; personalisation is out of scope for v1 (say this — it changes
the design completely); new trending queries must appear within *one hour*; offensive and
banned terms must never be suggested.

#subsection[Step 2 — Scale estimate]

$ 2,000,000,000 times 4 = 8,000,000,000 "prefix requests/day" $
$ 8,000,000,000 \/ 86,400 = 92,593 "requests/second average" $
$ 92,593 times 3 = 277,778 "requests/second at peak" $

*Serving nodes.* An in-memory lookup with no computation handles about 50,000 requests/s per
node:
$ 277,778 \/ 50,000 = 5.6 arrow.r 6 "nodes of work" $
Run *8* so losing one changes nothing.

*The data.* Say 100 million distinct queries are worth suggesting, and precomputing the top
10 for prefixes up to 8 characters yields about 50 million distinct prefixes at 200 bytes
each (10 suggestions, mostly shared string pointers):
$ 50,000,000 times 200 = 10,000,000,000 "B" = 10 "GB" $

#formulas(title: "The most important consequence of that 10 GB")[
*10 GB fits on one machine.* So do not shard by prefix. Put a *complete copy* on every one of
the 8 nodes, and let any node answer any request.

- No routing layer, no shard map, no rebalancing, no cross-shard query.
- A load balancer can send a request anywhere.
- Losing a node costs $1\/8$ of capacity and *zero* availability.

A candidate who shards a 10 GB dataset across 8 machines has added a distributed system to a
problem that did not have one. *Say the size first, then decide.*
]

*Write side.* Rebuilding hourly from a 24-hour rolling log of 2 billion searches: the build
job reads about $2 times 10^9$ rows, aggregates by query, and emits the trie. That is a batch
job of a few minutes on a modest cluster, run once an hour, entirely off the serving path.

#subsection[Step 3 — API surface]

#code(lang: "text", caption: "one endpoint, and every field on it exists for a reason")[
```text
GET /v1/suggest?q=chick&lang=en&country=SG&limit=10
  200  { suggestions: ["chicken rice", "chicken curry", ...],
         buildId: "2026-09-15T10", tookMs: 3 }
  headers  Cache-Control: public, max-age=60
  note  q is the RAW prefix; the server normalises (lowercase, trim,
        collapse spaces, strip accents) before looking up
  note  buildId lets the client and the CDN cache safely: when the
        hourly build changes, the id changes and caches turn over
  note  limit is capped at 10 server-side. A client asking for 1000
        would turn a pointer read into a scan.
```
]

#trick[
*Put the `buildId` in the response and in the cache key.* It turns cache invalidation — the
hardest problem in the chapter — into a non-problem: nothing is ever invalidated, old entries
simply stop being requested and expire. This is the same trick as immutable chunk URLs in the
video design. Notice that you have now used it twice; interviewers notice when a candidate
reuses a principle deliberately.
]

#subsection[Step 4 — Data model]

The serving structure is the `TopKTrie` from Piece 4, built offline and loaded as an
immutable blob. The interesting model is the *pipeline* that produces it.

#code(lang: "text", caption: "the build inputs")[
```text
search_log                      -- the stream, 2 billion rows/day
  ts, raw_query, lang, country, result_clicked (bool)

query_stats                     -- hourly aggregate, the build's input
  norm_query    text    PRIMARY KEY (norm_query, lang, country)
  count_24h     bigint
  ctr           float   clicks / impressions
  first_seen    timestamp
  blocked       bool    set by the safety pipeline, never by the build

trie_build                      -- one row per hourly build
  build_id      text    "2026-09-15T10"
  blob_path     text    object storage path of the serialised trie
  size_bytes    bigint
  query_count   bigint
  state         enum  BUILDING|VERIFIED|LIVE|ROLLED_BACK
```
]

#subsection[Step 5 — Architecture]

#diagram(height: 5.8cm, caption: "The request path (bottom) touches nothing that can be slow. Everything expensive happens on the build path (top), once an hour.")[
  #dnode(0pt, 4pt, 66pt, 26pt, "Search log\n(stream)")
  #dnode(84pt, 4pt, 70pt, 26pt, "Hourly\naggregate")
  #dnode(172pt, 4pt, 66pt, 26pt, "Safety\nfilter", fill: rgb("#f7e3e3"))
  #dnode(256pt, 4pt, 66pt, 26pt, "Trie\nbuilder")
  #dnode(340pt, 4pt, 74pt, 26pt, "Blob store\n+ buildId", fill: rgb("#f0ece2"))

  #dnode(256pt, 54pt, 66pt, 24pt, "Verifier")

  #dnode(0pt, 100pt, 66pt, 26pt, "Keystroke")
  #dnode(84pt, 100pt, 70pt, 26pt, "Edge cache\n(60 s)", fill: rgb("#dbe7c9"))
  #dnode(172pt, 100pt, 66pt, 26pt, "LB")
  #dnode(256pt, 100pt, 74pt, 26pt, "Suggest node\n(1 of 8)")
  #dnode(348pt, 100pt, 66pt, 26pt, "Full trie\n10 GB", fill: rgb("#dbe7c9"))

  #darrow(66pt, 17pt, 84pt, 17pt)
  #darrow(154pt, 17pt, 172pt, 17pt)
  #darrow(238pt, 17pt, 256pt, 17pt)
  #darrow(322pt, 17pt, 340pt, 17pt)
  #darrow(289pt, 30pt, 289pt, 54pt)
  #darrow(322pt, 62pt, 375pt, 100pt, dashed: true, label: "load")

  #darrow(66pt, 113pt, 84pt, 113pt)
  #darrow(154pt, 113pt, 172pt, 113pt)
  #place(dx: 150pt, dy: 84pt)[#text(size: 7.5pt, fill: dc)[~40% miss]]
  #darrow(238pt, 113pt, 256pt, 113pt)
  #darrow(330pt, 113pt, 348pt, 113pt)

  #place(dx: 0pt, dy: 140pt)[#text(size: 8pt, fill: muted)[A request does one prefix walk and one array read. No sorting, no scanning, no database, no network hop beyond the node itself.]]
  #place(dx: 0pt, dy: 150pt)[#text(size: 8pt, fill: muted)[Every node holds the complete 10 GB trie, so there is no shard map and any node can answer anything.]]
]

#subsection[Step 6a — Deep dive: the 50 ms budget, spent line by line]

#formulas(title: "Where the 100 ms actually goes")[
#table(columns: (1fr, auto, 1fr),
  [*Segment*], [*Budget*], [*How we hold it*],
  [Phone to edge (mobile network)], [30--50 ms], [nothing you can do; it is physics],
  [Edge cache hit], [1 ms], [~60% of prefixes are cached; these never reach you],
  [Edge to your region], [10--20 ms], [serve from the nearest region, always],
  [Load balancer + your node], [3 ms], [prefix walk plus one array read],
  [Response on the wire], [2 ms], [a suggestion list is under 1 KB],
)
*Total on a cache miss: about 70 ms. On a hit: about 40 ms.*

Two rules follow, and they are the whole design:
+ *The client must debounce.* Firing on every keystroke sends 12 requests for a 12-letter
  query, of which 11 are thrown away. Wait 120 ms after the last keystroke, and cancel the
  previous in-flight request. This alone cuts request volume by roughly two thirds.
+ *The client must cache locally.* When the user types `chick` and then deletes back to
  `chic`, the answer for `chic` is already in the phone's memory. Never ask twice.
]

#subsection[Step 6b — Deep dive: a new trending query in under an hour]

The hourly rebuild means a query that starts trending at 10:05 appears at 11:00 — fifty-five
minutes late. For a breaking news term that is far too slow.

#formulas(title: "The two-layer answer")[
+ *Layer 1 — the hourly trie.* Complete, safe, verified, 10 GB. It holds everything that was
  already popular.
+ *Layer 2 — a small hot overlay.* A separate structure, rebuilt every *60 seconds* from the
  last 15 minutes of the stream, holding only the few thousand queries whose rate has risen
  sharply. It is maybe 20 MB.
+ *At request time, merge:* look up the prefix in both, merge the two top-10 lists by score,
  take 10. This is a merge of two sorted lists of 10 — about 20 comparisons, well under
  0.1 ms.

*How you decide something is trending.* Compare the last 15 minutes against the same query's
previous hour, normalised per minute:
$ "score" = ("count in last 15 min" \/ 15) \/ ("count in previous hour" \/ 60 + 1) $
The $+1$ stops a query that appeared twice yesterday from scoring infinity. Promote anything
above, say, 5.0 with a minimum absolute count of 100 so that noise cannot trend.

*What it costs:* a second pipeline, a second structure in memory, and a merge on every
request. *Decision: build it.* "Why doesn't your search know about the thing that happened an
hour ago?" is a product failure that users notice immediately, and 20 MB plus 20 comparisons
is a very cheap fix.
]

#subsection[Step 6c — Deep dive: never suggesting something terrible]

Autocomplete says things *in your product's voice*. A suggestion is an endorsement, and this
is where these systems make the news.

#formulas(title: "Four filters, applied at build time, not at request time")[
+ *Blocklist by exact normalised term.* Cheap, exact, and auditable. Applied after
  normalisation, so tricks with spacing and accents do not get through.
+ *Pattern rules.* No suggestion may complete a person's name with a negative word. This is a
  rule about the *shape* of the suggestion, not about any single term.
+ *Minimum support.* Never suggest a query seen fewer than, say, 100 times in 24 hours across
  at least 20 distinct users. This alone removes almost all targeted manipulation, because
  making 20 real accounts is expensive and making 1 is not.
+ *A verification gate on every build.* The new trie is checked against a fixed set of test
  prefixes before it goes live. If any banned term appears, the build is marked
  `ROLLED_BACK` and the previous build stays live.

*Why at build time?* Because a request-time filter runs 277,778 times a second and a
build-time filter runs once an hour. And because a build-time filter can be *reviewed* — you
can look at the diff between two builds. You cannot review something that happens 24 billion
times a day.
]

#subsection[Step 7 — Trade-offs, failure modes, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Data layout], [shard the trie over 8 nodes], [full 10 GB copy on every node],
    [*B* — it fits; a full copy removes the routing layer entirely],
  [When to rank], [search the subtree per request], [precompute top-10 at every node],
    [*B* — turns a 50 ms scan into a 0.05 ms read],
  [Freshness], [hourly rebuild only], [hourly build + 60-second hot overlay],
    [*B* — 55 minutes late on breaking terms is a visible product failure],
  [Safety filtering], [at request time], [at build time, with a verification gate],
    [*B* — once an hour and reviewable, versus 24 billion times a day],
  [Cache], [none, the service is fast], [edge cache 60 s, keyed by buildId],
    [*B* — ~60% of requests never reach you, and invalidation is free],
  [Personalisation], [blend the user's history], [none in v1],
    [*A later.* Personalising kills the shared edge cache, so it must be a separate,
     smaller, opt-in path — not a change to this one],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [A build is corrupt],
    [Nothing],
    [The verifier catches it and the previous build stays live. A stale trie is completely
     acceptable; a wrong one is not.],
  [A suggest node dies],
    [Nothing],
    [7 of 8 remain, each holding the full data. Capacity drops 12.5%, availability does not
     move.],
  [The hot-overlay pipeline stops],
    [Trending terms stop appearing],
    [Suggestions silently fall back to the hourly trie, which is still correct. Alarm on
     overlay age above 5 minutes.],
  [Someone tries to manipulate a suggestion],
    [Nothing],
    [Minimum support of 100 searches from 20 distinct users, plus the build diff review.],
  [Traffic doubles in an instant],
    [Slightly slower],
    [The edge cache absorbs most of it. The 8 nodes have 8x headroom over the 6 required.],
)

*At 10x (20 billion searches/day, 2.8 million requests/s at peak):*
- $2,777,778 \/ 50,000 = 56$ nodes of work. Still small, because the request still does
  nothing. This is the payoff for the precompute decision, compounding.
- The trie grows with *distinct* queries, not with volume, so 10 GB becomes maybe 25 GB — not
  100 GB. *Say that.* It is the difference between a design that scales and one that does
  not, and it comes from the shape of the data, not from any clever engineering.
- The new problem is *languages and scripts*. Prefix matching in a language without spaces,
  or one typed via transliteration, is not a prefix walk at all. *Decision: one trie per
  language, not one global trie,* plus a transliteration step that maps what the user typed
  into the target script before the lookup. Twelve languages at 25 GB each will no longer fit
  on one machine — and *that* is the moment sharding becomes correct. Shard by language
  first, because it needs no routing logic beyond a field already in the request.
]
]

#section[Design 5 — payments]
#tier-header(3)

#ex(19, tier: 3, asked: "Microsoft · pattern")[Design the payment service behind the previous
four products: 10 million payments a day, 10x on sale days, several external providers, and
a rule that a customer must never be charged twice.
#sol[

#subsection[Step 1 — Clarify]

*Assumptions stated out loud:* 10 million payments/day, 10x peak on a sale day; three
external providers (card, wallet, bank transfer); the provider takes about 800 ms to answer;
authorisation and capture are separate; refunds are 0.1% of payments; records must be kept
*7 years*; and the absolute rule is *no double charge, ever, under any failure*.

#subsection[Step 2 — Scale estimate]

$ 10,000,000 \/ 86,400 = 115.7 "payments/second average" $
$ 115.7 times 10 = 1,157 "payments/second on a sale day" $

*In-flight provider calls* (Little's Law, 800 ms each):
$ 1,157 times 0.8 = 926 "open calls at peak" $

*Ledger rows.* Two per payment, 300 bytes each:
$ 10,000,000 times 2 times 300 = 6,000,000,000 "B" = 6 "GB/day" $
$ 6 times 365 = 2,190 "GB/year" = 2.19 "TB/year" $
$ 2.19 times 7 = 15.33 "TB over the 7-year retention" $

*Idempotency keys.* One per attempt, 100 bytes, kept 24 hours:
$ 10,000,000 times 100 = 1,000,000,000 "B" = 1 "GB/day" $

*Refunds.* $10,000,000 times 0.001 = 10,000$ a day $= 0.12$/second. Tiny, but they touch the
same ledger and must be just as correct.

#formulas(title: "The board summary")[
1,157 payments/s at peak · 926 concurrent provider calls · 2.19 TB/year · 15.3 TB over
7 years.

*The data is small and the correctness bar is absolute.* That is the exact opposite of the
video design, and the architecture should look opposite too: no cache on the write path, no
eventual consistency about money, and a single strongly-consistent store per shard.
]

#subsection[Step 3 — API surface]

#code(lang: "text", caption: "every write endpoint is idempotent; that is not optional here")[
```text
POST /v1/payments
  header Idempotency-Key: 9f10-...        REQUIRED. 400 if missing.
  body   { customerId, merchantId, amountCents, currency, method,
           orderRef, captureMode:"auto"|"manual" }
  201    { paymentId, state:"AUTHORISED"|"CAPTURED", providerRef }
  200    { ... }   <- a REPLAY: same key, same body, first answer returned
  409    { error:"idempotency_key_reused_with_different_body" }
  402    { paymentId, state:"FAILED", reason:"insufficient_funds" }

POST /v1/payments/{paymentId}/capture
  header Idempotency-Key: ...
  body   { amountCents }      // may be less than authorised, never more
  200    { paymentId, state:"CAPTURED", capturedCents }

POST /v1/payments/{paymentId}/refunds
  header Idempotency-Key: ...
  body   { amountCents, reason }
  201    { refundId, state:"REFUND_PENDING" }

POST /v1/webhooks/{provider}               (provider -> us)
  note   signature-verified, replay-safe, and ALWAYS returns 200 fast.
         The handler writes to a queue and does nothing else.

GET  /v1/payments/{paymentId}
  200    { paymentId, state, amountCents, capturedCents, refundedCents,
           events:[...] }
```
]

#trap[
*The 409 on a reused key with a different body is not pedantry.* If a client reuses a key by
accident and you quietly return the first payment, you have just told them their 5,000-rupee
charge succeeded when what actually succeeded was a 50-rupee one. Store a hash of the request
body alongside the key and compare. Same key and same body means replay; same key and
different body means a client bug, and you must say so loudly.
]

#subsection[Step 4 — Data model]

#code(lang: "text", caption: "append-only everywhere it matters")[
```text
payments                             (sharded by customer_id, hashed)
  payment_id      ulid    PK
  customer_id     bigint  SHARD KEY INPUT
  merchant_id     bigint
  amount_cents    bigint  INTEGER. Never a float. Never.
  currency        char(3)
  state           enum  CREATED|AUTHORISED|CAPTURED|FAILED|REFUNDED
  provider        text
  provider_ref    text
  version         int
  created_at, updated_at
  UNIQUE (customer_id, idempotency_key)     -- the gate, in the database

payment_events                       -- append-only, never updated
  payment_id, seq, from_state, to_state, actor, at, raw_provider_payload

ledger_entries                       -- append-only: never updated or deleted
  entry_id    bigserial
  txn_id      text      groups the legs of one movement
  account     text      "user:7" | "merchant:42" | "fees" | "provider:card"
  amount      bigint    signed minor units; legs of a txn SUM TO ZERO
  currency    char(3)
  posted_at   timestamp
  INDEX (account, posted_at)

outbox                               -- same shard, same transaction
  id, payment_id, payload, published_at NULL
```
]

#subsection[Step 5 — Architecture]

#diagram(height: 6.7cm, caption: "The user's request never waits on a provider retry. The gate, the ledger and the outbox all commit in one local transaction on one shard.")[
  #dnode(164pt, 4pt, 78pt, 30pt, "Idempotency\ngate (UNIQUE)", fill: rgb("#f7e3e3"))
  #dnode(350pt, 4pt, 66pt, 26pt, "Webhook\nreceiver")

  #dnode(0pt, 44pt, 62pt, 26pt, "Client")
  #dnode(78pt, 44pt, 70pt, 26pt, "Payment API")
  #dnode(164pt, 44pt, 78pt, 30pt, "Payments +\nledger + outbox")
  #dnode(266pt, 44pt, 66pt, 30pt, "Shard\n(1 of N)")

  #dnode(164pt, 92pt, 78pt, 26pt, "Outbox\nreader (CDC)")
  #dnode(266pt, 92pt, 66pt, 26pt, "Provider\nworker")
  #dnode(350pt, 92pt, 66pt, 26pt, "Provider\n(800 ms)", fill: rgb("#f0ece2"))

  #dnode(266pt, 138pt, 66pt, 26pt, "Recon job\n(daily)")
  #dnode(350pt, 138pt, 66pt, 26pt, "Break queue\n(humans)", fill: rgb("#f7e3e3"))

  #darrow(62pt, 57pt, 78pt, 57pt)
  #darrow(148pt, 50pt, 164pt, 28pt)
  #darrow(148pt, 60pt, 164pt, 60pt)
  #darrow(242pt, 59pt, 266pt, 59pt)
  #darrow(203pt, 74pt, 203pt, 92pt)
  #darrow(242pt, 105pt, 266pt, 105pt)
  #darrow(332pt, 105pt, 350pt, 105pt)
  #darrow(383pt, 92pt, 383pt, 32pt, label: "result")
  #darrow(350pt, 22pt, 246pt, 44pt, dashed: true, label: "settle")
  #darrow(299pt, 118pt, 299pt, 138pt)
  #darrow(332pt, 151pt, 350pt, 151pt)

  #place(dx: 96pt, dy: 24pt)[#text(size: 7.5pt, fill: dc)[claim the key]]
  #place(dx: 96pt, dy: 76pt)[#text(size: 7.5pt, fill: dc)[all in ONE txn]]

  #place(dx: 0pt, dy: 170pt)[#text(size: 8pt, fill: muted)[The API returns as soon as the local transaction commits. Talking to the provider is a worker's job,]]
  #place(dx: 0pt, dy: 180pt)[#text(size: 8pt, fill: muted)[so a provider stall never holds a user's connection, and a provider outage never loses a payment.]]
]

*Trace one payment:*
+ `POST /v1/payments` arrives with an `Idempotency-Key`.
+ The service opens one transaction on the customer's shard and does *all* of this in it:
  insert the idempotency key (unique constraint; a duplicate fails here and we return the
  first result), insert the `payments` row, insert the `payment_events` row, insert an
  `outbox` row. Commit.
+ Return `201` with state `CREATED`. Total: about 5 ms. *No provider has been contacted yet.*
+ A CDC reader tails the outbox and hands the job to a provider worker. The worker makes the
  800 ms call, passing our `payment_id` as the provider's own idempotency reference.
+ On success it posts the two ledger legs and moves the state to `AUTHORISED` — again in one
  local transaction on the same shard.
+ The provider's webhook arrives later and confirms. It is signature-verified, written to a
  queue, and processed idempotently by `(provider, provider_event_id)`.
+ Every night, the reconciliation job compares our ledger against the provider's settlement
  file, row by row. Anything that does not match goes to the break queue for a human.

#subsection[Step 6a — Deep dive: the three ways a double charge actually happens]

#formulas(title: "Name all three; candidates usually name one")[
+ *The client retried.* Handled by the idempotency key, claimed with a unique constraint in
  the same transaction as the payment. A duplicate insert fails and we return the stored
  first response.
+ *We retried, and the provider had already succeeded.* Our first call timed out at 5 s but
  the provider processed it at 6 s. Our retry creates a second charge. *Handled by passing
  our own `payment_id` to the provider as its idempotency reference* — every serious provider
  supports this, and a retry with the same reference returns the original result instead of
  charging again. If a provider does *not* support it, you must query the provider for the
  status of that reference before retrying, never retry blindly.
+ *Two of our own processes worked the same outbox row.* Handled by claiming the row with a
  conditional update (`UPDATE ... SET claimed_by = me WHERE claimed_by IS NULL`) and by the
  fact that the provider call itself is idempotent on `payment_id`. Belt and braces, because
  this is the one where the money is real.
]

*The fourth case nobody mentions:* the transaction committed but the response never reached
the client, so the user taps again with a *new* idempotency key. Now it is genuinely a second
request, correctly processed, and the customer is legitimately charged twice for what they
think is one thing. *The fix is not in the payment service.* The *order* service must derive
the idempotency key from the order, not generate a fresh one per tap — and the app must show
the pending charge. Being able to say where a fix does not belong is a senior answer.

#subsection[Step 6b — Deep dive: the provider is down for 20 minutes]

At 1,157 payments/second, 20 minutes of outage is
$ 1,157 times 20 times 60 = 1,388,400 "payments that cannot be authorised" $

#formulas(title: "Four responses, in increasing order of desperation")[
+ *Retry with backoff and a cap.* Base 1 s, doubling, 6 attempts, full jitter: total window
  $1 times (2^6 - 1) = 63$ s. This covers a blip, not an outage.
+ *Fail over to a second provider.* Requires that both are integrated and that routing is a
  config change, not a deploy. *Cost:* the second provider charges more, and its
  authorisation rates differ, so your success rate moves.
+ *Queue and authorise later.* Accept the order, tell the user "payment pending", authorise
  when the provider returns. *Cost:* some of those authorisations will decline afterwards,
  and you must then unwind an order the customer thinks is placed. Only acceptable for
  low-value, cancellable goods.
+ *Shed load honestly.* Return 503 with a retry-after. Ugly, but it does not create 1.4
  million ambiguous payments.

*Decision: (1) then (2) then (4). Never (3) for anything of real value.* An accepted order
with an unauthorised payment is a promise you may not be able to keep, and unwinding 1.4
million of them is a far worse day than 20 minutes of honest 503s. Route to the second
provider automatically when the primary's error rate exceeds 5% over 60 seconds, and route
back only after 10 clean minutes.
]

#subsection[Step 6c — Deep dive: reconciliation, the job that catches everything else]

Every night the provider sends a settlement file: everything they think happened.

#formulas(title: "The three-way match, and what each mismatch means")[
Match on `(provider_ref, amount, currency)` across three sources: *our ledger*, *the provider
file*, and *the merchant's expected payout*.

#table(columns: (auto, 1fr, 1fr),
  [*Mismatch*], [*What it means*], [*Action*],
  [In provider file, not in our ledger],
    [We charged and then crashed before posting the entry],
    [Post the missing entry with the provider's timestamp. This is *money we took and did
     not record* — the most dangerous kind.],
  [In our ledger, not in the provider file],
    [We recorded a charge that never happened],
    [Reverse it and alarm. A customer may be looking at a charge that does not exist.],
  [Amounts differ],
    [Fees, currency conversion, or a partial capture],
    [Expected for fees; post the fee leg. Unexpected for the rest; break queue.],
  [Duplicate provider_ref],
    [A genuine double charge slipped through],
    [Refund immediately, automatically, and page a human. Do not wait to be asked.],
)

*Scale of the job:* 10 million rows on each side. A sorted merge on `provider_ref` is
$O(n log n)$ to sort and $O(n)$ to walk — a few minutes. *Alarm threshold: any unexplained
break at all.* Money is the one place where "0.01% is fine" is not fine: 0.01% of 10 million
payments at an average of 800 rupees is
$10,000,000 times 0.0001 times 800 = 800,000$ rupees a day.
]

#subsection[Step 7 — Trade-offs, failure modes, 10x]

#table(columns: (auto, 1fr, 1fr, auto),
  [*Choice*], [*Option A*], [*Option B*], [*Decision*],
  [Payment record], [one row, UPDATE-ed through states],
    [append-only events plus a ledger],
    [*B* — you can answer "what happened and when", and an audit is possible],
  [Idempotency], [check a Redis key first], [unique constraint in the same transaction],
    [*B* — Redis is a speed-up, never the guarantee],
  [Provider call], [inside the user's request], [outbox plus a worker],
    [*B* — 926 in-flight calls must not be 926 held user connections],
  [Money type], [decimal or float], [integer minor units],
    [*B* — there is no defensible version of A],
  [Consistency], [eventual, like the profile store], [strongly consistent per shard],
    [*B* — the data is 2 TB/year; there is no scale argument for weakening it],
  [Provider outage], [queue and authorise later], [retry, fail over, then shed],
    [*B* — an unauthorised accepted order is a promise you may not keep],
  [Reconciliation], [sample 1%], [match every row, every night],
    [*B* — 0.01% of missed breaks is 800,000 rupees a day],
)

#table(columns: (auto, 1fr, 1fr),
  [*What fails*], [*What the user sees*], [*What we do*],
  [We crash after charging, before recording],
    [A charge with no order],
    [Reconciliation finds it that night and posts the entry. The provider reference is the
     link, which is why we send our own id as that reference.],
  [A webhook arrives twice],
    [Nothing],
    [Processed idempotently on `(provider, provider_event_id)`.],
  [A webhook never arrives],
    [Payment stuck at `CREATED`],
    [A sweeper polls the provider for anything older than 5 minutes in a non-terminal state.
     Never rely on a webhook as the only path.],
  [The shard leader fails mid-transaction],
    [One request errors; the client retries],
    [The transaction either committed or did not. The idempotency key makes the retry safe
     either way — this is exactly why the key is claimed *inside* the transaction.],
  [A refund is requested twice],
    [One refund],
    [`REFUNDED` has no outgoing transitions, and the refund itself carries an idempotency
     key.],
  [Sale day, 10x traffic],
    [Nothing],
    [1,157/s across N shards is small. The real constraint is the *provider's* rate limit —
     negotiate it in advance and implement a token bucket per provider so you shape your own
     traffic rather than being throttled mid-sale.],
)

*At 10x (100 million payments/day):*
- 1,157/s average, 11,574/s at peak. $11,574 \/ 5,000 = 2.3 arrow.r 3$ shards on write
  capacity; storage becomes 21.9 TB/year and 153 TB over 7 years, giving
  $153,000 \/ 500 = 306$ shards at a 500 GB shard size. *Storage decides, exactly as in
  Chapter 10* — so archive ledger entries older than 18 months to cold storage with the
  same append-only guarantees, and the online set stays small.
- In-flight provider calls become $11,574 times 0.8 = 9,259$. No single provider will accept
  that from one client. You *must* run several providers in parallel and route by cost,
  success rate and their individual rate limits.
- The genuinely new problem at 10x is *reconciliation time*. 100 million rows per side per
  night is still a sorted merge, but it no longer fits in one machine's memory and it no
  longer finishes before the morning. *Decision: reconcile continuously, in hourly windows,
  instead of nightly in one batch.* Same logic, 24 times smaller each run, and a break is
  found within an hour instead of within a day — which for money is the difference that
  matters.
]
]

#section[Interview drill — what the interviewer pushes on]

#table(columns: 2, align: (left, left),
  [*They ask*], [*You answer*],
  ["Where do you store driver locations?"],
    ["In memory, and nowhere else on the hot path. 400,000 drivers is 24 MB. Persisting
     every ping would be 100,000 writes a second and 864 GB a day of data that is worthless
     one second later. I keep a downsampled trail on disk only while a driver is on a trip,
     which is 48 GB a day."],
  ["Why nine geohash cells and not one?"],
    ["Because a rider standing at a cell border has their nearest driver on the other side of
     it. Searching one cell finds someone 900 metres away and misses someone 30 metres away.
     The cell lookup is a cheap filter — about 299 candidates — and haversine is the exact
     filter on top."],
  ["Two riders, one nearest driver. What happens?"],
    ["The offer is a hold, taken with `SET offer:driverId NX EX 12`. The store decides
     atomically and the loser moves to the next candidate in microseconds. The 12-second TTL
     also means a dispatcher crash needs no recovery code at all."],
  ["Why not a distributed transaction for a food order?"],
    ["Because a two-phase commit blocks every participant when the coordinator dies, and it
     will die during the lunch rush. I use a saga: steps ordered with the likeliest failure
     first and the impossible-to-undo step last, every step idempotent, and a failed
     compensation goes to a human queue with an alarm."],
  ["How do you serve 25 Tbps?"],
    ["I do not. The CDN serves 95% of it and my origin serves 1.25 Tbps. The top 10,000
     videos are 7.4 TB, which fits on one edge rack, and that is where 80% of watch time is.
     Chunks are immutable so nothing is ever invalidated."],
  ["Who chooses the video quality?"],
    ["The player, from its own buffer depth and the measured download time of the last chunk.
     Step down fast below 10 seconds of buffer, step up slowly above 25. Only the client can
     measure its own link — and letting it decide is what keeps every chunk a plain,
     cacheable file."],
  ["Autocomplete in 50 ms. How?"],
    ["By doing no work at request time. The top 10 are precomputed at every trie node by an
     hourly build job, so a request is a prefix walk and one array read. The whole structure
     is 10 GB, which fits on one machine, so every node holds a full copy and there is no
     shard map at all."],
  ["A term starts trending right now."],
    ["A second, tiny overlay rebuilt every 60 seconds from the last 15 minutes, merged with
     the hourly trie at request time. Twenty megabytes and about twenty comparisons. The
     hourly build alone would be up to 55 minutes late, which users notice."],
  ["Guarantee no double charge."],
    ["Three mechanisms, because there are three causes. The client's retry is stopped by a
     unique constraint on the idempotency key, claimed inside the same transaction as the
     payment. Our own retry is stopped by passing our payment id to the provider as its
     idempotency reference. Two workers on one outbox row are stopped by a conditional
     claim. And reconciliation catches whatever all three missed."],
  ["Why is your ledger append-only?"],
    ["Because an `UPDATE` destroys the evidence. Every movement is two rows summing to zero,
     a refund is a new opposite entry, and I can verify the whole system with one query: the
     sum of every row must be exactly zero."],
  ["Float or integer for money?"],
    ["Integer minor units, always. 0.1 plus 0.2 is not 0.3 in a double, and once your ledger
     is out by a fraction of a cent it never balances again."],
  ["Which of these five is hardest?"],
    ["They are hard in different places, and naming the place is the answer. Ride-hailing is
     hard at the write rate, video at the bandwidth, autocomplete at the latency budget,
     payments at correctness, and food delivery at coordination across parties who do not
     share a database."],
)

#trap[
The most common Tier-3 failure in this chapter is answering a *bandwidth* problem with a
*request* architecture. If a candidate draws "player $arrow.r$ load balancer $arrow.r$ video
service $arrow.r$ database" for a streaming question, the interview is effectively over,
because no arrangement of that picture carries 25 Tbps. Compute the egress in the first two
minutes and let the number choose the architecture.
]

#practice(tier: 3, time: "50 min")[
+ Design surge pricing end to end: what you measure, over what window, how you compute the
  multiplier, how you stop it oscillating, and what hard limits you enforce in code.
+ A food-delivery courier goes offline mid-trip with the food. Enumerate every state that
  must change, every party that must be told, and what the customer's refund is at each
  order state.
+ Compute the full cost of adding 4K (15 Mbps) to the video ladder: extra storage per year,
  extra transcode cores, and extra egress if 5% of watch time moves to it. Then decide.
+ Add personalised autocomplete for signed-in users without destroying the shared edge cache.
  Describe the two-path design and the extra latency it costs.
+ A provider's settlement file shows 412 charges we have no ledger entry for, totalling
  680,000 rupees. Write the runbook: what you do in the first hour, the first day, and the
  first week.
]
#key[
+ Measure *unfilled requests per available driver* in a cell over a rolling 5 minutes — not
  raw demand, because raw demand is high everywhere at 6 p.m. Multiplier steps at fixed
  thresholds (1.0 / 1.3 / 1.6 / 2.0), never a continuous function, so it cannot oscillate on
  noise. Add hysteresis: go up after 2 minutes above a threshold, come down only after 5
  minutes below it. Hard caps in *code*, not config: never above 2.0x, never during a
  declared emergency, and an alarm on any cell above 1.6x for more than 10 minutes.
+ States: the order goes to `DELIVERY_FAILED`, the courier trip is closed, the courier's
  other batched orders are *reassigned* (this is the part candidates forget), the payment
  authorisation is voided or refunded, and the restaurant is told only if they need to
  remake. Refunds: full before `PICKED_UP`; full plus an apology credit after, because the
  customer did nothing wrong and the food is gone either way. Trying to charge for
  undelivered food to protect margin costs far more in churn than the food did.
+ Ladder goes from 9.9 to 24.9 Mbps, a $24.9\/9.9 = 2.5 times$ increase in stored bytes:
  135.5 PB/year becomes 340.8 PB/year, so *+205 PB/year*. Transcode: 4K is roughly 4x the
  cost of 1080p per second, pushing per-video CPU from 25 to about 45 minutes, so cores go
  from 8,681 to $500,000 times 45 \/ 1,440 = 15,625$ — *+6,944 cores*. Egress: 5% of watch
  time at 15 Mbps instead of 3 Mbps adds
  $90 "PB" times 0.05 times (15\/3 - 1) = 18$ PB/day, which at \$0.01/GB is \$180,000 a day.
  *Decision: transcode 4K only for videos that pass a popularity threshold in their first 48
  hours.* Most uploads are never watched enough to justify 2.5x storage, and the ones that
  are will earn it.
+ Path 1 is the shared, cacheable, anonymous path exactly as designed. Path 2 runs *only for
  signed-in users*, fetches the shared top-10 from path 1 (still a cache hit) and re-ranks it
  against a small per-user history held in a fast store keyed by user id. Re-ranking 10 items
  costs under 1 ms; the extra fetch costs about 3 ms. *Never* put the user id in the shared
  cache key — that turns one cache entry into 200 million.
+ *First hour:* freeze nothing, page the on-call, confirm the file is genuine and not a
  duplicate delivery, and check whether those 412 references exist in `payment_events` but
  not in `ledger_entries` — that distinguishes "we crashed before posting" from "we never saw
  these at all". *First day:* post the missing entries with the provider's timestamps, notify
  the affected customers if they were charged for something they did not receive, and open an
  incident. *First week:* find the code path that lost them, add a metric that would have
  caught it in an hour instead of a night, and move reconciliation to hourly windows so the
  detection gap shrinks from 24 hours to 1.
]

#revision[
*The four numbers that start each design.*
- Ride-hailing: $400,000 \/ 4 = 100,000$ pings/s. Everything follows from this.
- Food delivery: 35% of the day in 2 hours $arrow.r$ a *predictable* 4.2x peak.
- Video: $8,333,333 times 3 "Mbps" = 25$ Tbps. It is a bandwidth problem.
- Autocomplete: 277,778 req/s against a *10 GB* dataset. It fits on one machine.
- Payments: 1,157/s at peak, 2.19 TB/year. Small data, absolute correctness.

*Little's Law is the workhorse.* concurrency $=$ rate $times$ duration.
Rides: $5,000,000 times 20 \/ 1,440 = 69,444$. Viewers:
$100,000,000 times 40 \/ 1,440 = 2,777,778$. Provider calls:
$1,157 times 0.8 = 926$. Same formula, three designs.

*Geohash card.* 5 chars $approx 4.9$ km; 6 chars $approx 1.22 times 0.61$ km;
7 chars $approx 153$ m. *Always search the 8 neighbours.* Cell lookup is the cheap filter;
haversine is the exact one. Drop pings older than 30 seconds.

*The three-layer rule for data that moves.* Memory for *now* (24 MB, disposable, rebuilds in
4 seconds). A log for *replay* (Kafka, 24 h). Disk for what will be *read again*, downsampled
(48 GB/day instead of 864 GB/day).

*Holds beat locks.* `SET key NX EX 12`. Atomic, self-expiring, no crash recovery, no cleanup
job. Used for dispatch offers; the same shape works for seat holds and inventory reservations.

*Saga ordering is the answer.* Likeliest-to-fail first; impossible-to-undo last. Every step
and every compensation idempotent. A failed compensation goes to a human queue with an alarm,
never a silent retry loop.

*Video: the CDN is the system.* 95% offload, immutable chunk paths so nothing is ever
invalidated, an origin shield so 200 edge misses become 1, and pre-warming for predictable
releases. Top 10,000 videos $= 7.4$ TB $=$ 80% of watch time. The player chooses quality;
down fast, up slow; 4-second chunks with shorter opening chunks.

*Autocomplete: precompute or lose.* Store the top-k *at every node* at build time. A request
is a prefix walk and one array read. Filter for safety at build time (once an hour, and
reviewable), never at request time (24 billion times a day). Hourly trie plus a 60-second hot
overlay, merged per request.

*Payments: four non-negotiables.*
+ Integer minor units. Never a float.
+ Double entry, two legs summing to zero, append-only. A refund is a new opposite entry.
+ Idempotency key claimed by a *unique constraint inside the same transaction*. Redis is a
  speed-up, never the guarantee.
+ Reconcile every row, every night — or better, every hour. 0.01% missed is 800,000 rupees
  a day.

*Three causes of a double charge, and the three different fixes.* Client retry $arrow.r$
idempotency key. Our retry $arrow.r$ send our own id as the provider's reference. Two workers
on one row $arrow.r$ conditional claim. Reconciliation catches the rest.

*JavaScript traps in this chapter.*
+ `sort()` without a comparator sorts numbers as text: distances, counts and timestamps all
  need `(a, b) => a - b`.
+ Unlink from the old cell *before* linking to the new one, and never put an `await` between
  the two.
+ `Map` and `Set` keep types and insertion order; a plain object stringifies keys.
+ Money as a float. `0.1 + 0.2 !== 0.3`.
+ 926 concurrent I/O calls in one Node process is fine; 926 CPU-bound ones is not — move
  those to `worker_threads` or a separate service.

*Checklist before you say "done".*
+ Computed the *biggest* write rate and said where it is stored — memory, log, or disk.
+ Said which transport each direction uses, and why (push versus poll).
+ Named the atomic primitive that stops a double assignment (`SET NX`, unique constraint).
+ Ordered the saga by failure likelihood and undoability.
+ For anything with media: computed egress in Tbps *before* drawing boxes.
+ For anything with a latency budget: spent the budget line by line.
+ For anything with money: integers, double entry, append-only, idempotency, reconciliation.
+ Gave both sides of every trade-off and then *decided*.

*Four sentences that score marks.*
+ "The current position of a driver is important and disposable — 24 megabytes in memory that
  rebuilds itself in four seconds."
+ "This is a bandwidth problem, not a request problem; the CDN serves 95% of the bytes and my
  origin serves 1.25 Tbps."
+ "The request does no thinking. The hourly build already did all of it."
+ "The idempotency key is claimed by a unique constraint inside the same transaction as the
  payment, so a retry cannot win a race it should lose."
]

]
