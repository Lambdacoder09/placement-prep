#import "../../shared/lib/style.typ": *

#chapter(num: 8, title: "Load Balancing, Proxies & API Design",
  tagline: "Everything between the user's finger and your code — and the contract your code promises back.")[

#section[The idea in one page]

Between a user's phone and your function there are four boxes, and every one of them is a
place where a design interview goes wrong. This chapter names them, sizes them with real
arithmetic, and then writes the contract your service hands back: the endpoints, the
status codes, the pagination, the retry rules.

#formulas(title: "The four boxes, and what each one is allowed to know")[
#table(columns: (auto, auto, 1fr),
  [*Box*], [*Sees*], [*Can therefore do*],
  [*L4 load balancer*], [IP address and TCP port only],
    [pick a server, forward packets. Extremely fast (millions of connections), knows nothing about your API. Cannot retry, cannot read a path.],
  [*L7 reverse proxy*], [the whole HTTP request: method, path, headers, body],
    [route `/images` to one pool and `/api` to another, terminate TLS, retry a failed `GET`, compress, cache, add request ids.],
  [*API gateway*], [the request *and who sent it*],
    [authenticate, rate limit per customer, check the quota, validate the schema, record usage for billing.],
  [*the service*], [the business problem],
    [nothing about load balancing. A service that knows which replica it is has a bug.],
)

The single sentence that earns marks: *"I terminate TLS at the L7 proxy, authenticate and
rate limit at the gateway, and my service never sees a client IP except in a header."*
]

#subsection[Forward proxy and reverse proxy are not the same word twice]

#diagram(height: 5.0cm, caption: "A forward proxy works for the client. A reverse proxy works for the server. Same machine, opposite job.")[
  #place(dx: 0pt, dy: 0pt)[#text(size: 9pt, weight: "bold")[Forward proxy --- stands with the CLIENT]]
  #dnode(0.2cm, 0.7cm, 2.6cm, 0.9cm, "many clients")
  #darrow(2.85cm, 1.15cm, 3.35cm, 1.15cm)
  #dnode(3.4cm, 0.7cm, 3.0cm, 0.9cm, "forward proxy", fill: rgb("#dce9f2"))
  #darrow(6.45cm, 1.15cm, 6.95cm, 1.15cm)
  #dnode(7.0cm, 0.7cm, 2.6cm, 0.9cm, "the internet")
  #darrow(9.65cm, 1.15cm, 10.15cm, 1.15cm)
  #dnode(10.2cm, 0.7cm, 3.4cm, 0.9cm, "any server\nout there")
  #place(dx: 0.2cm, dy: 1.75cm)[#text(size: 7.5pt, fill: muted)[The *server* sees the proxy's IP, not the client's. Used for office filtering, outbound caching, hiding who is asking.]]

  #place(dx: 0pt, dy: 2.5cm)[#text(size: 9pt, weight: "bold")[Reverse proxy --- stands with the SERVER]]
  #dnode(0.2cm, 3.2cm, 2.6cm, 0.9cm, "many clients")
  #darrow(2.85cm, 3.65cm, 3.35cm, 3.65cm)
  #dnode(3.4cm, 3.2cm, 2.6cm, 0.9cm, "the internet")
  #darrow(6.05cm, 3.65cm, 6.55cm, 3.65cm)
  #dnode(6.6cm, 3.2cm, 3.2cm, 0.9cm, "reverse proxy\n(nginx, Envoy, ALB)", fill: rgb("#dce9f2"))
  #darrow(9.85cm, 3.65cm, 10.35cm, 3.65cm)
  #dnode(10.4cm, 3.2cm, 3.4cm, 0.9cm, "your server pool")
  #place(dx: 0.2cm, dy: 4.25cm)[#text(size: 7.5pt, fill: muted)[The *client* sees one address for many servers. Used for load balancing, TLS termination, caching, and hiding how many servers you have.]]
]

#note[
A load balancer *is* a reverse proxy with a particular job. "Reverse proxy" describes where
it stands; "load balancer" describes what it decides. Nginx, Envoy and HAProxy are all
three things at once, which is why the words get mixed up.
]

#subsection[The numbers you must know by heart]

#table(columns: (1fr, auto, 1fr, auto),
  [TCP handshake (same region)], [1 RTT, \~1 ms], [TLS 1.3 full handshake], [1 RTT],
  [TLS 1.2 full handshake], [2 RTT], [TLS session resumption], [0 RTT],
  [TLS CPU cost, one handshake], [1--2 ms], [requests per kept-alive conn], [20--100],
  [one L7 proxy node], [20--50k RPS], [one L4 load balancer], [millions of conns],
  [one app node, JSON API], [1--3k RPS], [DNS TTL for failover], [30--60 s],
  [health check interval], [2 s, 3 strikes], [connection drain time], [30--60 s],
  [safe steady-state utilisation], [60--70%], [autoscaler reaction time], [2--5 min],
)

#subsection[The one law that explains every load-balancing decision]

A server is a queue. As you push utilisation towards 100%, the *waiting* time explodes ---
not gently, but as $1 \/ (1 - rho)$. This is why you never size a fleet at 90%.

#code(lang: "python", caption: "utilisation.py — why you never run a server at 90%")[
```python
S = 20.0                                  # ms of real work per request
print(" util   avg wait   total time   multiplier")
for rho in (0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99):
    wait  = S * rho / (1 - rho)           # average queueing delay
    total = S + wait
    print(f" {rho:4.0%}   {wait:7.1f}ms   {total:8.1f}ms   {total / S:6.1f}x")
```
]

#code(lang: "text", caption: "$ python3 utilisation.py  — real output")[
```text
 util   avg wait   total time   multiplier
  50%      20.0ms       40.0ms      2.0x
  60%      30.0ms       50.0ms      2.5x
  70%      46.7ms       66.7ms      3.3x
  80%      80.0ms      100.0ms      5.0x
  90%     180.0ms      200.0ms     10.0x
  95%     380.0ms      400.0ms     20.0x
  99%    1980.0ms      2000.0ms   100.0x
```
]

#trick[
*Read the jump from 70% to 90%.* You added 29% more traffic and latency went up *3x*. That
is the whole reason for the "provision at 60--70%" rule, and it is the answer to
"why not just run fewer, busier servers?"

$ "latency multiplier" = 1 / (1 - rho) $

Memorise three points: 50% is 2x, 80% is 5x, 90% is 10x. If you can say those three
numbers, you never have to argue about headroom again.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
Name the load-balancing algorithm for each situation, in one line each.
(a) five identical servers, all requests cost the same;
(b) servers of two different sizes;
(c) requests vary wildly --- some take 5 ms, some take 5 seconds;
(d) each user's session data lives in one server's memory;
(e) a cache tier where the same key must reach the same node.
#sol[
- *(a) Round robin.* Nothing to be clever about. Cheapest possible decision: one counter.
- *(b) Weighted round robin.* Give the 8-core box weight 2 and the 4-core box weight 1.
- *(c) Least connections.* With wildly different costs, counting *requests* is meaningless;
  counting *work currently in flight* is not. A server stuck on three 5-second requests
  stops receiving new ones automatically.
- *(d) Sticky sessions* (a cookie or a source-IP hash). And say the cost out loud: sticky
  sessions break your ability to remove a server, and they make load uneven. The better
  answer is to make the servers stateless and put the session in Redis.
- *(e) Consistent hashing.* A plain `hash % N` reshuffles almost every key when N changes;
  consistent hashing moves roughly $1 \/ N$ of them.
]
#ans[round robin · weighted RR · least connections · sticky (but fix the state instead) · consistent hashing]
]

#ex(2, tier: 0)[
Your service peaks at 5,000 requests per second. One node comfortably serves 800 RPS.
How many nodes do you run? Show every step.
#sol[
*Step 1 --- the raw number.*
$ "5,000" / 800 = 6.25 arrow.r 7 "nodes" $

*Step 2 --- but 7 nodes at peak means each node is at*
$ "5,000" / 7 = 714 "RPS, which is" 714/800 = 89% "utilisation" $
and the utilisation law says 89% is a 9x latency multiplier. Too hot.

*Step 3 --- size for 65% instead.*
$ "capacity needed" = "5,000" / 0.65 = "7,692 RPS" $
$ "7,692" / 800 = 9.6 arrow.r 10 "nodes" $

*Step 4 --- N+1 for a node failure.* If one node dies, the other 9 must carry 5,000:
$ "5,000" / 9 = 555 "RPS each" = 69% "utilisation" checkmark $

*Step 5 --- spread across 2 availability zones*, 5 per zone. If one whole zone fails,
5 nodes carry 5,000:
$ "5,000" / 5 = "1,000 RPS each" > 800 arrow.r "overloaded" $
So to survive a zone failure you need 7 per zone, 14 total.

*The answer depends on what you promise to survive*, and saying that sentence is the point
of the question.
]
#ans[7 to merely serve it; 10 for healthy utilisation; 14 (7 per zone) to survive losing an entire zone.]
]

#ex(3, tier: 0)[
A health check runs every 2 seconds and marks a node dead after 3 consecutive failures.
A node dies at t=0. How long do users see errors, and how many requests fail at 5,000 RPS
across 10 nodes?
#sol[
*Detection time.* The worst case is that the node dies just after a successful check:
$ "up to " 2 "s (wait for the next check)" + 3 times 2 "s (three strikes)" = 8 "s" $
The typical case is $3 times 2 = 6$ s.

*Requests lost.* The dead node was receiving its share:
$ "5,000" / 10 = 500 "RPS" $
$ 500 times 6 = "3,000 failed requests" $

*How to make it smaller --- and what each fix costs.*
- Check every 0.5 s with 2 strikes: detection falls to 1 s, so 500 failed requests. Cost:
  4x the health-check traffic, and a higher chance of ejecting a healthy-but-slow node.
- *Passive* health checks: the proxy watches real traffic and ejects a node after 5
  consecutive 5xx responses. Detection is now *sub-second* and costs nothing extra,
  because it uses requests you were sending anyway.
- *Retry the failed request on another node.* The user sees nothing at all. This is the
  real fix, and it is why an L7 proxy is worth more than an L4 one.

*Decision:* passive ejection plus a retry on a different node for idempotent requests.
Active checks stay, but as the slower safety net.
]
#ans[6--8 s of errors, about 3,000 failed requests. Fix with passive ejection + retry elsewhere.]
]

#ex(4, tier: 0)[
Which HTTP methods are safe? Which are idempotent? Why does a load balancer care?
#sol[
#table(columns: (auto, auto, auto, 1fr),
  [*Method*], [*Safe?*], [*Idempotent?*], [*Meaning*],
  [`GET`], [yes], [yes], [changes nothing. Free to retry, free to cache.],
  [`HEAD`], [yes], [yes], [like `GET` with no body.],
  [`PUT`], [no], [yes], ["make the resource equal to this". Doing it twice leaves the same state.],
  [`DELETE`], [no], [yes], [deleting twice leaves it deleted. The second call returns 404 or 204; either is fine.],
  [`POST`], [no], [*no*], [ "create another one". Twice means two.],
  [`PATCH`], [no], [*usually not*], [`{"qty": 5}` is idempotent; `{"qty": "+1"}` is not.],
)

*Why the proxy cares.* A proxy may automatically retry a request when a backend times out
or returns a connection error. Retrying a `GET` is free. Retrying a `POST` can charge a
card twice. So a correctly configured proxy retries safe methods automatically and retries
`POST` *only* when the client sent an `Idempotency-Key` --- or never.
]
#ans[Safe: GET, HEAD. Idempotent: GET, HEAD, PUT, DELETE. POST is neither, so it must never be auto-retried without an idempotency key.]
]

#ex(5, tier: 0)[
Give the right status code, in one line each: the resource does not exist; the client sent
bad JSON; the client is not logged in; the client is logged in but not allowed; the client
sent 200 requests in a minute against a 60-per-minute limit; your database is down; a
`POST` succeeded and created something; a `PATCH` succeeded but you have nothing to return.
#sol[
#table(columns: (auto, auto, 1fr),
  [*Situation*], [*Code*], [*Note*],
  [resource missing], [404 Not Found], [use it for "you may not see it" too, so you do not leak existence],
  [bad JSON / bad field], [400 Bad Request], [422 Unprocessable Content if the JSON parsed but a value is invalid],
  [not logged in], [401 Unauthorized], [badly named: it means *unauthenticated*],
  [logged in, not allowed], [403 Forbidden], [the one that actually means unauthorised],
  [over the rate limit], [429 Too Many Requests], [*must* carry a `Retry-After` header],
  [database down], [503 Service Unavailable], [503 says "try later"; 500 says "I am broken"],
  [created], [201 Created], [with a `Location` header pointing at the new resource],
  [nothing to return], [204 No Content], [and truly no body --- not `{}`],
)

*The rule that matters most:* 4xx means *the client can fix it*, 5xx means *only you can*.
Getting that backwards makes every client retry forever on a bug they could have fixed.
]
#ans[404 · 400/422 · 401 · 403 · 429 + Retry-After · 503 · 201 + Location · 204]
]

#ex(6, tier: 0)[
An API returns 20 items per page. A client asks for `?page=2` while new items keep arriving
at the top. Show exactly what goes wrong, with rows.
#sol[
Ten items exist, newest first: `e10 e9 e8 e7 e6 e5 e4 e3 e2 e1`, page size 5.

*Page 1* (`OFFSET 0 LIMIT 5`) returns `e10 e9 e8 e7 e6`.

Now `e11` arrives. The list is `e11 e10 e9 e8 e7 e6 e5 e4 e3 e2 e1`.

*Page 2* (`OFFSET 5 LIMIT 5`) returns items 6 to 10 of the *new* list:
`e6 e5 e4 e3 e2`.

The client has now seen `e6` twice and has never seen `e11`. With deletions the opposite
happens: items get *skipped* entirely.

*The fix: a cursor.* Page 1 returns
`nextCursor = encode({createdAt: e6.createdAt, id: "e6"})`, and page 2 asks for
"everything strictly older than that". New arrivals at the top change nothing, because the
question was never "skip 5 items" --- it was "continue from e6".
]
#ans[Page 2 repeats e6 and skips e11. Offsets count positions; cursors remember a place.]
]

#ex(7, tier: 0)[
A tier allows 60 requests per minute. A client sends 60 requests in the first second, then
waits. Is that allowed? Compare a fixed window, a sliding window and a token bucket.
#sol[
- *Fixed window (per minute).* Allowed --- the counter only cares about the total inside the
  minute. Now the *boundary problem*: the client can send 60 at 11:59:59 and 60 more at
  12:00:00. That is *120 requests in one second* while never breaking "60 per minute".
- *Sliding window.* Not allowed after the first 60: any 60-second span is counted, so the
  boundary trick fails. Costs more memory (a log of timestamps, or two counters blended).
- *Token bucket (capacity 60, refill 1/s).* Allowed once --- the bucket starts full, so a
  burst of 60 goes through, and then the client is limited to 1 per second. *This is
  usually what you want*, because it permits a genuine burst (an app starting up and
  loading ten screens) while capping the long-run rate.

*Decision: token bucket*, stated as "60 per minute, burst 60". Then be explicit in the
docs, because a client that does not know the burst size cannot pace itself.
]
#ans[Fixed window: yes, and it allows 120 in a second at the boundary. Sliding window: no. Token bucket: yes once, then 1/s. Choose the token bucket.]
]

#ex(8, tier: 0)[
A service handles 3,000 RPS. Each request takes 250 ms. How many requests are in flight at
any moment? If each in-flight request holds a thread using 1 MB of stack, how much memory
is that?
#sol[
*Little's law.* For any stable system:
$ "items in the system" = "arrival rate" times "time each item spends inside" $

$ "3,000" "req/s" times 0.250 "s" = 750 "requests in flight" $

*Memory.*
$ 750 times 1 "MB" = 750 "MB of thread stacks" $

*Why this is the most useful formula in the chapter.* It converts a latency problem into a
capacity problem. If a downstream call gets slower --- 250 ms becomes 1 second --- then

$ "3,000" times 1.0 = "3,000" "in flight" arrow.r 3 "GB of stacks" $

with no change in traffic at all. The server runs out of threads and starts refusing
*healthy* requests. That is how one slow dependency takes down a whole service, and Little's
law is how you predict it before it happens.
]
#ans[750 in flight, 750 MB. Four times the latency means four times the memory at the same traffic.]
]

#ex(9, tier: 0)[
Your API does 200,000 RPS. Keep-alive gives you 50 requests per connection. How many new
TLS handshakes per second? At 1.5 ms of CPU each, how many CPU cores does TLS alone need?
#sol[
$ "new connections/s" = "200,000" / 50 = "4,000 per second" $
$ "CPU seconds per second" = "4,000" times 0.0015 = 6 $

Six CPU-seconds of work arrive every second, so *6 cores are busy doing nothing but TLS
handshakes*.

*Now turn on session resumption*, where a returning client skips the expensive part. If 80%
of connections resume:
$ "full handshakes" = "4,000" times 0.20 = 800 "per second" $
$ 800 times 0.0015 = 1.2 "cores" $

$ 6 / 1.2 = 5 times "less CPU, for one configuration flag." $

*And the trap:* if keep-alive is off, every request opens a connection:
$ "200,000" times 0.0015 = 300 "cores" $
That is the difference between one machine and a rack.
]
#ans[4,000 handshakes/s = 6 cores; 1.2 cores with 80% resumption; 300 cores with no keep-alive.]
]

#ex(10, tier: 0)[
A client calls service A, which calls B, which calls C. Each sets a 3-second timeout and
retries twice. C hangs. How long does the user wait, and how many requests does C receive?
#sol[
*Work upward from C.*

C's caller is B. B tries, waits 3 s, retries, waits 3 s, retries, waits 3 s:
$ "B spends" 3 times 3 = 9 "s per attempt, and sends 3 requests to C" $

A does the same to B, three times:
$ "A spends" 3 times 9 = 27 "s, and B sends" 3 times 3 = 9 "requests to C" $

The client does the same to A:
$ "the user waits" 3 times 27 = 81 "s" $
$ "C receives" 3 times 9 = 27 "requests for one user action" $

*That is retry amplification: $3^3 = 27$.* Three layers of "harmless" double-retry turned
one click into 27 requests on the already-dying service.

*The two fixes, both required.*
+ *A timeout budget.* The client's deadline (say 3 s) travels down in a header. Each hop
  passes on what is left. When the budget is gone, nobody retries. The user waits 3 s, not
  81.
+ *Retry only at ONE layer* --- the edge --- and use a *retry budget*: allow retries only
  while they are under 10% of traffic. Never retry in the middle of a chain.
]
#ans[81 seconds, 27 requests on C. Fix: pass a deadline down the chain, and retry at one layer only, under a 10% budget.]
]

#ex(11, tier: 0)[
Why is `POST /createUser`, `POST /getUser`, `POST /deleteUser` a bad API? Rewrite it.
#sol[
*What is wrong.*
+ *Every call is a `POST`,* so nothing is cacheable, nothing is safely retryable, and a
  proxy cannot tell a read from a write.
+ *Verbs in the path.* The URL names an *action*, so the vocabulary grows forever:
  `createUser`, `createUserV2`, `createUserWithPhoto`. With nouns, `POST /users` already
  covers all three.
+ *No hierarchy.* "The orders of user 7" has no obvious spelling.

*The rewrite.*

```text
POST   /v1/users            201 + Location: /v1/users/1187
GET    /v1/users/1187       200
GET    /v1/users?limit=20&cursor=...   200
PATCH  /v1/users/1187       200      (partial update)
PUT    /v1/users/1187       200      (full replace, idempotent)
DELETE /v1/users/1187       204
GET    /v1/users/1187/orders?limit=20&cursor=...
```

*The honest exception.* Some operations are genuinely not nouns: "send the password reset
email", "cancel the order", "retry the payment". Forcing those into nouns produces worse
APIs than admitting it. The accepted pattern is a sub-resource that *is* the action's
record:

```text
POST /v1/orders/887/cancellation      201 { cancellationId, status }
POST /v1/users/1187/password-resets   202
```

Now the action is a thing, it has an id, you can look it up later, and it can carry an
idempotency key.
]
#ans[Nouns and HTTP methods, not verbs in paths. For genuine actions, make the action a sub-resource that has its own id.]
]

#section[Tier 1 · LLD: build the load balancer]
#tier-header(1)

A very common low-level design round: "write a load balancer". Same six moves as any LLD ---
cut scope, nouns to classes, draw, name the hard part, write the core method, handle
concurrency and change.

#formulas(title: "The scope you cut, out loud, in 30 seconds")[
*In:* a pool of backends, pluggable selection strategies, health tracking, a circuit
breaker, and request counting.

*Out:* TLS, HTTP parsing, config reloading, and the actual socket code. "I will model it
synchronously with a tick-based simulation so the behaviour is testable."

*The one hard part:* selection must stay correct while the pool changes underneath it, and
a sick backend must be removed *before* it hurts users.
]

#subsection[Move 2 and 3 --- the classes]

#table(columns: (auto, 1fr),
  [`Backend`], [one server: id, weight, capacity, in-flight count, healthy flag, counters],
  [`Strategy`], [the interface: `pick(pool) -> Backend`. One class per algorithm.],
  [`LoadBalancer`], [owns the backends, filters to the healthy pool, delegates to the strategy, tracks in-flight],
  [`CircuitBreaker`], [per backend: CLOSED / OPEN / HALF\_OPEN, with a cooldown],
)

#trick[
Notice `Strategy` is the *strategy pattern*, and it is the correct answer here for a reason
you can state: the set of algorithms is open (someone will invent another one) but the
*interface* is closed --- every algorithm answers exactly "which backend?". That is
precisely the shape the strategy pattern exists for. Say that sentence instead of just
naming the pattern.
]

#subsection[Move 5 --- the code]

#code(lang: "js", caption: "lb.js — backends and four strategies")[
```js
class Backend {
  constructor(id, { weight = 1, capacity = 100 } = {}) {
    this.id = id; this.weight = weight; this.capacity = capacity;
    this.inFlight = 0; this.healthy = true;
    this.served = 0; this.failed = 0;
    this.cw = 0;                         // current weight, for smooth weighted RR
  }
}

class Strategy { pick(pool) { throw new Error("implement pick()"); } }

class RoundRobin extends Strategy {
  constructor() { super(); this.i = 0; }
  pick(pool) { const b = pool[this.i % pool.length]; this.i++; return b; }
}

// weights 5,1,1 must give A B A C A A A ... not A A A A A B C
class SmoothWeighted extends Strategy {
  pick(pool) {
    const total = pool.reduce((s, b) => s + b.weight, 0);
    let best = pool[0];
    for (const b of pool) { b.cw += b.weight; if (b.cw > best.cw) best = b; }
    best.cw -= total;
    return best;
  }
}

class LeastConnections extends Strategy {
  pick(pool) { return pool.reduce((a, b) => (b.inFlight < a.inFlight ? b : a)); }
}

// power of two choices: sample 2 at random, take the emptier one
class PowerOfTwo extends Strategy {
  constructor(rnd) { super(); this.rnd = rnd; }
  pick(pool) {
    if (pool.length === 1) return pool[0];
    const a = pool[Math.floor(this.rnd() * pool.length)];
    let b = pool[Math.floor(this.rnd() * pool.length)];
    if (a === b) b = pool[(pool.indexOf(a) + 1) % pool.length];
    return a.inFlight <= b.inFlight ? a : b;
  }
}

class LoadBalancer {
  constructor(backends, strategy) {
    this.backends = backends; this.strategy = strategy;
  }
  get pool() { return this.backends.filter(b => b.healthy); }
  route() {
    const pool = this.pool;
    if (pool.length === 0) return { status: 503, backend: null };
    const b = this.strategy.pick(pool);
    b.inFlight++;
    if (b.inFlight > b.capacity) {  // the backend is full: shed, do not queue
      b.inFlight--; b.failed++;
      return { status: 503, backend: b };
    }
    b.served++;
    return { status: 200, backend: b };
  }
  done(b) { if (b) b.inFlight = Math.max(0, b.inFlight - 1); }
}
```
]

#code(lang: "js", caption: "lb.js — the experiment: three backends, one of them 5x slower")[
```js
let seed = 20260915;
const rnd = () => (seed = (seed * 48271) % 2147483647) / 2147483647;

function simulate(name, makeStrategy) {
  seed = 20260915;  // same randomness for every run
  const backends = [new Backend("a", { capacity: 60 }),
                    new Backend("b", { capacity: 60 }),
                    new Backend("c", { capacity: 60 })];
  const lb = new LoadBalancer(backends, makeStrategy());
  const holdTicks = { a: 1, b: 1, c: 5 };            // c is 5x slower
  const busy = [];
  let ok = 0, rejected = 0;

  for (let tick = 0; tick < 5000; tick++) {
    for (let i = busy.length - 1; i >= 0; i--)       // finish what is done
      if (--busy[i].left === 0) { lb.done(busy[i].b); busy.splice(i, 1); }

    for (let r = 0; r < 40; r++) {                   // 40 new requests per tick
      const res = lb.route();
      if (res.status !== 200) { rejected++; continue; }
      ok++;
      busy.push({ b: res.backend, left: holdTicks[res.backend.id] });
    }
  }
  console.log(name.padEnd(18), "ok:", String(ok).padStart(6),
              " 503s:", String(rejected).padStart(6), " ",
              backends.map(b => b.id + "=" + b.served).join("  "));
}

console.log("3 backends, capacity 60 in-flight each; backend c is 5x slower\n");
simulate("round robin",       () => new RoundRobin());
simulate("least connections", () => new LeastConnections());
simulate("power of two",      () => new PowerOfTwo(rnd));

console.log("\nsmooth weighted round robin, weights a=5 b=1 c=1:");
const w = [new Backend("a", { weight: 5 }), new Backend("b", { weight: 1 }),
           new Backend("c", { weight: 1 })];
const sw = new SmoothWeighted();
const picks = Array.from({ length: 14 }, () => sw.pick(w).id);
console.log("  first 14 picks ->", picks.join(" "));
```
]

#code(lang: "text", caption: "$ node lb.js  — real output")[
```text
3 backends, capacity 60 in-flight each; backend c is 5x slower

round robin        ok: 193334  503s:   6666   a=66667  b=66667  c=60000
least connections  ok: 200000  503s:      0   a=91997  b=89999  c=18004
power of two       ok: 200000  503s:      0   a=90913  b=90877  c=18210

smooth weighted round robin, weights a=5 b=1 c=1:
  first 14 picks -> a a b a c a a a a b a c a a
```
]

*Four things that output proves, and each one is an interview answer.*

+ *Round robin dropped 6,666 requests --- 3.3% of all traffic.* It kept sending one third of
  requests to a backend that could not keep up, and that backend filled and started
  refusing. Round robin is correct only when every request costs the same *and* every
  server is the same speed.
+ *Least connections dropped nothing* and automatically gave the slow backend
  $"18,004" \/ "200,000" = 9%$ of traffic instead of 33%. Nobody configured that. It is a
  consequence of counting in-flight work rather than requests.
+ *Power of two choices matched it* --- 18,210 versus 18,004 --- while looking at only *two*
  backends per decision instead of all of them. With 3 backends that saves nothing. With
  2,000 backends it is the difference between an $O(n)$ scan and $O(1)$ per request, and it
  is why every large proxy uses it.
+ *Smooth weighting matters.* Weights 5,1,1 produce `a a b a c a a a a b a c a a` --- the
  small backends are spread through the sequence. The naive implementation would send
  `a a a a a b c`, giving `a` a five-request burst every seven requests.

#complexity(time: "round robin $O(1)$ · least connections $O(n)$ · power of two $O(1)$ · smooth weighted $O(n)$",
  space: "$O(n)$ for the pool",
  note: "At n = 2,000 backends and 50,000 RPS, an $O(n)$ pick costs 100 million comparisons a second. That is the whole argument for power of two choices.")

#trap[
`pool.reduce((a, b) => b.inFlight < a.inFlight ? b : a)` throws on an empty array. The
`LoadBalancer.route` guard (`if (pool.length === 0) return 503`) is not decoration --- it is
the difference between returning 503 and crashing the proxy the moment every backend goes
unhealthy at once. That is exactly the moment you least want the proxy to crash.
]

#subsection[The circuit breaker --- stop calling a service that is already down]

#diagram(height: 3.8cm, caption: "Three states. The cooldown is what stops a retry storm from re-killing a recovering service.")[
  #dnode(0.4cm, 1.0cm, 3.6cm, 1.0cm, "CLOSED\ntraffic flows", fill: rgb("#e7f0e7"))
  #dnode(6.4cm, 1.0cm, 3.6cm, 1.0cm, "OPEN\nfail instantly", fill: rgb("#f2dcdc"))
  #dnode(12.4cm, 1.0cm, 3.8cm, 1.0cm, "HALF-OPEN\nlet 1 probe through", fill: rgb("#fbf6ee"))

  #darrow(4.05cm, 1.35cm, 6.35cm, 1.35cm, label: "5 failures")
  #darrow(10.05cm, 1.35cm, 12.35cm, 1.35cm, label: "after 2 s")
  #darrow(12.35cm, 1.75cm, 10.05cm, 1.75cm, label: "probe fails")

  #darrow(14.3cm, 2.0cm, 14.3cm, 2.9cm)
  #darrow(14.3cm, 2.9cm, 2.2cm, 2.9cm, label: "2 probes pass")
  #darrow(2.2cm, 2.9cm, 2.2cm, 2.05cm)
]

#code(lang: "js", caption: "breaker.js — the state machine")[
```js
class CircuitBreaker {
  constructor({ failureThreshold = 5, cooldownMs = 2000,
                probeSuccesses = 2 } = {}) {
    this.state = "CLOSED"; this.fails = 0; this.probeOk = 0; this.openedAt = 0;
    this.failureThreshold = failureThreshold;
    this.cooldownMs = cooldownMs; this.probeSuccesses = probeSuccesses;
  }
  allow(now) {
    if (this.state === "CLOSED") return true;
    if (this.state === "OPEN") {
      if (now - this.openedAt >= this.cooldownMs) {   // cooldown over: probe
        this.state = "HALF_OPEN"; this.probeOk = 0; return true;
      }
      return false;  // fail fast, no call made
    }
    return true;  // HALF_OPEN: probes pass through
  }
  onSuccess() {
    if (this.state === "HALF_OPEN") {
      if (++this.probeOk >= this.probeSuccesses) {
        this.state = "CLOSED"; this.fails = 0;
      }
    } else this.fails = 0;
  }
  onFailure(now) {
    if (this.state === "HALF_OPEN") {
      this.state = "OPEN"; this.openedAt = now; return;
    }
    if (++this.fails >= this.failureThreshold) {
      this.state = "OPEN"; this.openedAt = now;
    }
  }
}
```
]

#code(lang: "js", caption: "breaker.js — a backend that is broken from t=0 to t=6000 ms")[
```js
const brokenUntil = 6000;
const cb = new CircuitBreaker({ failureThreshold: 5, cooldownMs: 2000,
                                probeSuccesses: 2 });
let sentToBackend = 0, refusedFast = 0;
const log = [];

for (let now = 0; now <= 9000; now += 500) {
  const before = cb.state;
  if (!cb.allow(now)) {
    refusedFast++; log.push([now, before, "-- refused, no call made"]); continue;
  }
  sentToBackend++;
  const ok = now >= brokenUntil;
  if (ok) cb.onSuccess(); else cb.onFailure(now);
  log.push([now, cb.state === before ? before : before + " -> " + cb.state,
            ok ? "200 OK" : "500 error"]);
}
console.log("  ms   state              what happened");
for (const [t, st, r] of log)
  console.log(String(t).padStart(5), " ", st.padEnd(18), r);
console.log("\ncalls that reached the sick backend  :", sentToBackend);
console.log("calls refused instantly by the breaker:", refusedFast);
```
]

#code(lang: "text", caption: "$ node breaker.js  — real output")[
```text
  ms   state              what happened
    0   CLOSED             500 error
  500   CLOSED             500 error
 1000   CLOSED             500 error
 1500   CLOSED             500 error
 2000   CLOSED -> OPEN     500 error
 2500   OPEN               -- refused, no call made
 3000   OPEN               -- refused, no call made
 3500   OPEN               -- refused, no call made
 4000   OPEN               500 error
 4500   OPEN               -- refused, no call made
 5000   OPEN               -- refused, no call made
 5500   OPEN               -- refused, no call made
 6000   OPEN -> HALF_OPEN  200 OK
 6500   HALF_OPEN -> CLOSED 200 OK
 7000   CLOSED             200 OK
 7500   CLOSED             200 OK
 8000   CLOSED             200 OK
 8500   CLOSED             200 OK
 9000   CLOSED             200 OK

calls that reached the sick backend  : 13
calls refused instantly by the breaker: 6
```
]

Read the trace line by line --- it contains every idea in the pattern.

- *0 to 1,500 ms:* the breaker is CLOSED, so all five calls go through and all five fail.
  This is the cost of the pattern: *you always pay the threshold in real failures* before
  it engages.
- *2,000 ms:* the fifth consecutive failure trips it to OPEN.
- *2,500 to 3,500 ms:* three calls are refused *instantly*, with no network call at all.
  The user gets a fast 503 instead of a 30-second timeout, and the sick service gets peace
  to recover.
- *4,000 ms:* the 2-second cooldown has expired, so exactly *one* probe is let through. It
  fails, and the breaker snaps straight back to OPEN. Note what did *not* happen: a
  thundering herd of every waiting client retrying at once.
- *6,000 ms:* the backend recovers. The next probe succeeds.
- *6,500 ms:* the second consecutive probe succeeds, so the breaker closes and normal
  traffic resumes.

*The number to quote:* 6 of 19 calls never touched the sick backend. Under real load ---
say 5,000 RPS --- the OPEN state would have removed roughly
$"5,000" times 3.5 "s" = "17,500"$ pointless requests from a service that was already
struggling.

#ex(12, tier: 1, asked: "TCS NQT · pattern")[
Your proxy retries any failed request twice. During an outage, traffic is 1,000 RPS. How
much load does the failing backend see, and what do you change?
#sol[
$ "attempts per request" = 1 + 2 "retries" = 3 $
$ "load on the failing backend" = "1,000" times 3 = "3,000" "RPS" $

You have tripled the load on the one machine that is already failing. This is called a
*retry storm*, and it is how a small blip becomes an outage.

*Fix 1 --- exponential backoff with full jitter.* Not "wait 100 ms, then 200 ms" (every
client then retries at exactly the same moments, which is another spike), but a random
wait in the whole window:

```js
function fullJitter(attempt, baseMs = 100, capMs = 20000, rnd = Math.random) {
  return Math.floor(rnd() * Math.min(capMs, baseMs * 2 ** attempt));
}
// attempts 0..5 produced: 0, 119, 83, 193, 1241, 1049 ms
```

The word *full* matters: picking uniformly in $[0, "window"]$ spreads the retries across
the whole window, where picking the window's end would bunch them at one instant.

*Fix 2 --- a retry budget.* Allow retries only while they stay under 10% of total traffic.
$ "1,000" times 1.1 = "1,100" "RPS, not 3,000" $
When the backend is failing *everywhere*, retrying cannot help anybody, so the budget shuts
retries off automatically.

*Fix 3 --- the circuit breaker above*, which stops calls entirely rather than slowing them.

*Decision: all three, in that order of importance.* The budget is the one most teams
forget, and it is the one that converts a 3x amplification into 1.1x.
]
#ans[3,000 RPS --- 3x amplification. Fix with full-jitter backoff, a 10% retry budget, and a circuit breaker.]
]

#ex(13, tier: 1, asked: "Capgemini · pattern")[
Why does "power of two choices" work so well, when picking the *single* least-loaded
backend is obviously better? Explain with 2,000 backends.
#sol[
*Why not just pick the least loaded?* Two reasons.

+ *Cost.* Scanning 2,000 backends per request at 50,000 RPS is
  $"50,000" times "2,000" = "100,000,000"$ comparisons a second, on every proxy node.
+ *The herd.* If you run 20 proxy nodes, they all see the same "least loaded" backend at
  the same moment and all send to it. The emptiest server becomes the fullest server
  instantly. This is a real failure mode, and it has a name: *herd behaviour on stale
  state*.

*Why two random choices is enough.* Picking one at random gives an expected maximum load
that grows like $log n \/ log log n$. Picking the better of *two* random choices drops it to
$log log n \/ log 2$. Put numbers on it for $n = "2,000"$:

$ log_2(log_2 2000) = log_2(10.97) = 3.5 $

versus $log_2(2000) \/ log_2 log_2 (2000) = 10.97 \/ 3.46 = 3.2$ --- the point is not the
exact constants but the *shape*: one extra sample turns a logarithmic imbalance into a
double-logarithmic one. Doubling to three or four choices buys almost nothing more.

*And the measurement from this chapter's own simulation:* with a 5x-slow backend, least
connections gave it 18,004 requests and power of two gave it 18,210 --- a difference of
1.1%, for $O(1)$ work instead of $O(n)$ and with no herd.

*Decision: power of two choices* for any pool above about 20 backends. Plain least
connections below that, where the scan is free and the herd is small.
]
#ans[It is $O(1)$ instead of $O(n)$, it cannot herd, and it lands within about 1% of true least-connections (measured: 18,210 vs 18,004).]
]

#section[Tier 1 · LLD: the four API pieces every service needs]
#tier-header(1)

#subsection[Piece 1 --- a rate limiter with one number per client]

The token bucket needs two numbers per client (tokens left, last refill time). GCRA --- the
*generic cell rate algorithm* --- needs one, which matters when "per client" means 40 million
entries in Redis.

#code(lang: "js", caption: "api.js — GCRA: store one timestamp, get burst plus rate")[
```js
class Gcra {
  // rate = requests per second on average; burst = how many may arrive together
  constructor(rate, burst) {
    this.T = 1000 / rate;              // ms that one request "costs"
    this.tau = this.T * (burst - 1);  // how far ahead of now a client may run
    this.tat = new Map();              // theoretical arrival time, one per client
  }
  check(key, now) {
    const tat = Math.max(this.tat.get(key) ?? now, now);
    if (tat - now > this.tau) {  // this client is too far ahead
      const wait = Math.ceil(tat - this.tau - now);
      return { allowed: false, retryAfterMs: wait, remaining: 0 };
    }
    this.tat.set(key, tat + this.T);
    return { allowed: true, retryAfterMs: 0,
             remaining: Math.floor((this.tau - (tat - now)) / this.T) };
  }
}
```
]

#code(lang: "text", caption: "$ node api.js  — GCRA at 2 req/s with burst 5")[
```text
GCRA: 2 req/s, burst 5
  t=   0ms  req 1  -> 200  X-RateLimit-Remaining: 4
  t=   0ms  req 2  -> 200  X-RateLimit-Remaining: 3
  t=   0ms  req 3  -> 200  X-RateLimit-Remaining: 2
  t=   0ms  req 4  -> 200  X-RateLimit-Remaining: 1
  t=   0ms  req 5  -> 200  X-RateLimit-Remaining: 0
  t=   0ms  req 6  -> 429  Retry-After: 500ms
  t=   0ms  req 7  -> 429  Retry-After: 500ms
  t=   0ms  req 8  -> 429  Retry-After: 500ms
  ... wait 1500 ms ...
  t=1500ms  req 9  -> 200  X-RateLimit-Remaining: 2
  t=1500ms  req 10 -> 200  X-RateLimit-Remaining: 1
  t=1500ms  req 11 -> 200  X-RateLimit-Remaining: 0
```
]

Check the arithmetic yourself: at 2 req/s, one request costs $T = 500$ ms. After 1,500 ms of
waiting the client has earned $"1,500" \/ 500 = 3$ requests back, and the output shows
exactly three allowed. The `Retry-After: 500ms` on the first rejection is also exactly $T$:
the time until one request is affordable again.

#trick[
*Always return three headers with a 429*, and say so unprompted:

```text
X-RateLimit-Limit: 120
X-RateLimit-Remaining: 0
Retry-After: 1
```

Without `Retry-After`, every client guesses --- and their guesses cluster, producing the
exact spike you were limiting. A rate limiter without `Retry-After` creates the problem it
was installed to fix.
]

#subsection[Piece 2 --- a concurrency limiter, which is not a rate limiter]

#code(lang: "js", caption: "api.js — cap the work in flight, not the arrival rate")[
```js
class ConcurrencyLimiter {
  constructor(max) { this.max = max; this.inFlight = 0; this.shed = 0; }
  tryAcquire() {
    if (this.inFlight >= this.max) {   // 503, immediately
      this.shed++; return false;
    }
    this.inFlight++; return true;
  }
  release() { this.inFlight--; }
}

const cl = new ConcurrencyLimiter(100);
for (const [rps, latency] of [[1000, 0.05], [1000, 0.20], [4000, 0.05]]) {
  const inFlight = rps * latency;
  console.log(`${rps} rps x ${latency}s = ${inFlight} in flight`,
    inFlight > cl.max ? `-> over the cap of ${cl.max}: shed the excess`
                      : "-> fits under the cap");
}
```
]

#code(lang: "text", caption: "$ node api.js  — output")[
```text
1000 rps x 0.05s = 50 in flight -> fits under the cap
1000 rps x 0.2s = 200 in flight -> over the cap of 100: shed the excess
4000 rps x 0.05s = 200 in flight -> over the cap of 100: shed the excess
```
]

#note[
Read rows 1 and 2. *The traffic did not change.* Only the latency did --- a downstream
dependency got slower --- and the service went from comfortable to overloaded. A rate
limiter counting requests per second would have seen nothing wrong. A *concurrency* limiter
sees it immediately, because it measures the thing that actually runs out: threads,
sockets, memory.

Use both: a rate limiter to be fair between customers, and a concurrency limiter to protect
the process from itself.
]

#subsection[Piece 3 --- cursor pagination]

#code(lang: "js", caption: "api.js — keyset pages, and why OFFSET is wrong")[
```js
const encode = (o) => Buffer.from(JSON.stringify(o)).toString("base64url");
const decode = (s) => JSON.parse(Buffer.from(s, "base64url").toString());

function page(rows, limit, cursor) {
  // rows sorted by (createdAt DESC, id DESC) - a TOTAL order, no ties
  let start = 0;
  if (cursor) {
    const c = decode(cursor);
    start = rows.findIndex(r => r.createdAt < c.createdAt ||
                               (r.createdAt === c.createdAt && r.id < c.id));
    if (start < 0) start = rows.length;
  }
  const slice = rows.slice(start, start + limit);
  const last = slice[slice.length - 1];
  return {
    items: slice.map(r => r.id),
    nextCursor: slice.length === limit && last
      ? encode({ createdAt: last.createdAt, id: last.id }) : null
  };
}
```
]

#code(lang: "text", caption: "$ node api.js  — a row is inserted between page 1 and page 2")[
```text
keyset pagination, limit 5
  page 1: e20,e19,e18,e17,e16  cursor: eyJjcmVhdGVkQXQiOj...
  (a new row e99 is inserted at the top here)
  page 2: e15,e14,e13,e12,e11  cursor: eyJjcmVhdGVkQXQiOj...
  page 3: e10,e9,e8,e7,e6      cursor: eyJjcmVhdGVkQXQiOj...

OFFSET pagination, limit 5
  page 1: e20,e19,e18,e17,e16
  (same new row e99 inserted)
  page 2: e16,e15,e14,e13,e12  <- e16 is shown twice
```
]

#trap[
The cursor must encode a *total* order. `{createdAt}` alone is not enough: two rows created
in the same millisecond make the comparison ambiguous, and the page either repeats one or
skips one. Always append the primary key, and compare as a pair:
`(createdAt, id) < (cursorCreatedAt, cursorId)`.

Also: *the cursor is opaque*. Base64 it, do not document its contents, and treat it as a
value you produced. The moment a client parses it, you can never change it.
]

#subsection[Piece 4 --- idempotency]

#code(lang: "js", caption: "api.js — the three states of an idempotency key")[
```js
class IdempotencyStore {
  constructor(ttlMs = 24 * 3600 * 1000) {
    this.m = new Map(); this.ttlMs = ttlMs;
  }
  // "new" | "in_progress" | "done" (with the saved response) | "conflict"
  begin(key, fingerprint, now) {
    const e = this.m.get(key);
    if (!e || now - e.at > this.ttlMs) {
      this.m.set(key, { state: "in_progress", fingerprint, at: now });
      return { state: "new" };
    }
    if (e.fingerprint !== fingerprint) return { state: "conflict" };   // 422
    return e.state === "done" ? { state: "done", response: e.response }
                              : { state: "in_progress" };  // 409, retry later
  }
  finish(key, response, now) {
    const e = this.m.get(key);
    this.m.set(key, { ...e, state: "done", response, at: now });
  }
}
```
]

#code(lang: "text", caption: "$ node api.js  — output")[
```text
idempotency, key = k_a1
  1st POST : { state: 'new' }
  retry    : { state: 'done', response: { status: 201, id: 'job_5512' } }
  same key, different body: { state: 'conflict' }
```
]

*Three details that separate a real implementation from a toy.*

+ *The fingerprint.* Store a hash of the request body with the key. If a client reuses a key
  with a *different* body, that is a client bug, and returning the old response would be
  worse than an error. Return 422 and say why.
+ *The `in_progress` state.* Without it, two retries arriving 5 ms apart both see "no entry"
  and both create the order. The row must be written *before* the work starts, using an
  insert that fails if the key exists.
+ *The TTL.* 24 hours is the usual choice: long enough to cover every client retry policy,
  short enough that the table does not grow forever.

#section[Tier 2 · Mid-scale: a public parcel-tracking API]
#tier-header(2)

#ex(14, tier: 2, asked: "Shopee · pattern")[
A logistics company wants a public API. Merchants create shipments, their buyers track
parcels, and partner apps integrate. Design it --- all seven steps.
]

#sol[
#subsection[Step 1 --- Clarify]

#table(columns: (1fr, 1fr),
  [*Question I ask*], [*Why the answer changes the design*],
  [Who calls this --- browsers, or partner servers?],
    [Browsers mean CORS, short-lived tokens and a CDN. Partner servers mean API keys, per-key quotas and webhooks. The answer changes authentication, caching and the whole rate-limit design.],
  [How fresh must a tracking status be?],
    [If 60 seconds of staleness is fine, I can put a CDN in front and drop read load by 90%. If it must be exact, every read hits the service.],
  [Do partners poll, or do they want to be pushed to?],
    [Polling is simple but wasteful. Webhooks cut the read traffic enormously but bring delivery retries, signatures and a whole failure surface.],
  [Is the tracking number secret?],
    [If a tracking number is guessable, anyone can enumerate other people's parcels. That decides whether the endpoint is public or needs a second factor such as the destination pincode.],
  [What happens if the same scan event is sent twice?],
    [Handheld scanners retry over bad networks constantly. This decides whether scan ingestion needs an idempotency key --- it does.],
)

*Assumptions:* partner servers and buyer browsers both; 60 seconds of staleness is
acceptable; both polling and webhooks; tracking numbers include a check digit and a random
suffix; scan ingestion is idempotent.

#subsection[Step 2 --- Scale estimate]

*Reads.* 12 million parcels are in transit at any time; a buyer or merchant checks each
about 6 times a day.

$ "12,000,000" times 6 = "72,000,000 reads/day" $
$ "average" = "72,000,000" / "86,400" = 833.3 "RPS" $

Tracking is checked in bursts (people check after work, and after a "your parcel is out for
delivery" message). Use a 4x peak factor.

$ "peak" = 833.3 times 4 = "3,333 RPS" $

*Writes.* 3 million parcels are shipped per day, each producing about 9 scan events
(collected, hub-in, hub-out, ... , delivered).

$ "3,000,000" times 9 = "27,000,000 writes/day" $
$ "average" = "27,000,000" / "86,400" = 312.5 "RPS" $
$ "peak" = 312.5 times 3 = 937.5 approx 938 "RPS" $

*Total at peak.*
$ "3,333" + 938 = "4,271 RPS" $

*Nodes.* One node serves about 2,000 RPS of this workload.
$ "4,271" / "2,000" = 2.14 arrow.r 3 "nodes" $
But three nodes in two zones cannot survive a zone failure. Spread 3 per zone across 2
zones = 6 nodes; if a whole zone dies the remaining 3 carry
$ "4,271" / 3 = "1,424 RPS each" = 71% "of capacity" checkmark $

*Bandwidth.* A tracking response is about 1.8 KB.
$ "3,333" times "1,800" = "5,999,400 bytes/s" approx 6 "MB/s" = 48 "Mbit/s" $
Trivial. The bytes are never the problem for a JSON API; the request rate is.

*Storage.* A scan event row is about 200 bytes.
$ "27,000,000" times 200 = "5,400,000,000" = 5.4 "GB/day" $
$ 5.4 times 365 = "1,971 GB" = 1.97 "TB/year" $
Small enough for one database with monthly partitions.

#subsection[Step 3 --- API surface]

#code(lang: "text", caption: "The public contract")[
```text
GET /v1/parcels/{trackingNumber}
  auth  API key (partner) OR tracking number + pincode (public browser)
  200   { trackingNumber, status, statusUpdatedAt, estimatedDelivery,
          origin:{city}, destination:{city}, lastEvent:{code, city, at} }
  headers  Cache-Control: public, max-age=60
           ETag: "p_77Q2-e9"
  404   unknown OR not yours — deliberately the same response for both

GET /v1/parcels/{trackingNumber}/events?limit=50&cursor=<opaque>
  200   { events:[ {eventId, code, city, at, note} ], nextCursor }

POST /v1/shipments
  header Idempotency-Key: <uuid>           <- REQUIRED, not optional
  body   { reference, from:{...}, to:{...}, weightGrams, service }
  201    { trackingNumber, labelUrl }   Location: /v1/parcels/IN77Q2K91X

POST /v1/webhooks
  body   { url, events:["parcel.delivered","parcel.exception"], secret }
  201    { webhookId }

POST /internal/scans                      <- scanners and hub systems only
  header Idempotency-Key: <scannerId>-<seq>
  body   { trackingNumber, code, at, hubId }
  202    Accepted
```
]

*Five rules I follow and can defend:*

#table(columns: (auto, 1fr),
  [version in the path], [`/v1/`. Two characters. Header versioning is theoretically nicer and practically unusable from a browser address bar or a curl example in the docs.],
  [404 for "not yours"], [returning 403 tells an attacker the tracking number exists. Same body, same code, for unknown and forbidden.],
  [idempotency on every create], [a merchant's retry must not print two labels for one parcel.],
  [cursors, never page numbers], [scan events arrive constantly; offsets would repeat rows.],
  [`202` for scans], [the scan is accepted into a queue, not written synchronously. Saying `201` would be a lie about durability of the *processing*.],
)

#subsection[Step 4 --- Data model]

#code(lang: "sql", caption: "Five tables, and the one unique index that makes scans idempotent")[
```sql
CREATE TABLE parcels (
  tracking_number  TEXT PRIMARY KEY,  -- IN77Q2K91X: prefix + random + check digit
  merchant_id      BIGINT      NOT NULL,
  status           SMALLINT    NOT NULL,
  status_at        TIMESTAMPTZ NOT NULL,
  dest_pincode     TEXT        NOT NULL,
  eta              TIMESTAMPTZ,
  version          INT         NOT NULL DEFAULT 1
);
CREATE INDEX ix_parcels_merchant ON parcels (merchant_id, status_at DESC);

CREATE TABLE scan_events (
  tracking_number TEXT        NOT NULL,
  event_id        BIGINT      NOT NULL,
  code            SMALLINT    NOT NULL,
  hub_id          INT         NOT NULL,
  at              TIMESTAMPTZ NOT NULL,
  scanner_seq     TEXT        NOT NULL,        -- "<scannerId>-<seq>"
  PRIMARY KEY (tracking_number, event_id)
) PARTITION BY RANGE (at);

-- a scanner retrying over a bad network must NOT create a second event
CREATE UNIQUE INDEX ux_scan_dedupe ON scan_events (scanner_seq);

CREATE TABLE api_keys (
  key_hash   TEXT PRIMARY KEY,                 -- store the HASH, never the key
  partner_id BIGINT NOT NULL,
  tier       SMALLINT NOT NULL,                -- 0 free, 1 pro, 2 enterprise
  revoked_at TIMESTAMPTZ
);

CREATE TABLE webhooks (
  webhook_id BIGINT PRIMARY KEY,
  partner_id BIGINT NOT NULL,
  url        TEXT   NOT NULL,
  secret_enc BYTEA  NOT NULL,
  events     TEXT[] NOT NULL,
  state      SMALLINT NOT NULL  -- 0 active 1 backing-off 2 disabled
);

CREATE TABLE webhook_deliveries (
  delivery_id BIGINT PRIMARY KEY,
  webhook_id  BIGINT NOT NULL,
  event_id    BIGINT NOT NULL,
  attempts    SMALLINT NOT NULL DEFAULT 0,
  next_try_at TIMESTAMPTZ NOT NULL,
  state       SMALLINT NOT NULL,               -- 0 pending 1 delivered 2 dead
  UNIQUE (webhook_id, event_id)  -- one delivery row per event per webhook
);
```
]

*Two decisions worth defending out loud.*

*(a) `ux_scan_dedupe` on `scanner_seq`.* The scanner generates
`<scannerId>-<sequenceNumber>` and retries with the *same* value. The second insert fails
with a unique violation, which the ingest code catches and turns into `202 Accepted`. The
deduplication is done by the database, so no race between two retries can slip through.
This is the same move as the library's "one open loan per copy" index: *turn the rule into
a constraint.*

*(b) `api_keys.key_hash`, never the key.* An API key is a password. Store
`sha256(key)` and compare hashes. If the table leaks, nobody can call your API with it.
Candidates almost never say this, and it is free marks.

#subsection[Step 5 --- Architecture]

#diagram(height: 6.8cm, caption: "Read path through the CDN and gateway; write path through a queue. The webhook sender is separate so a slow partner cannot slow ingestion.")[
  #dnode(0.2cm, 0.1cm, 8.8cm, 0.9cm, "peak 3,333 reads/s + 938 writes/s = 4,271 RPS · 6 nodes over 2 zones", fill: rgb("#fbf6ee"))

  #dnode(0.2cm, 1.3cm, 2.3cm, 1.0cm, "buyer\nbrowser")
  #dnode(0.2cm, 2.6cm, 2.3cm, 1.0cm, "partner\nserver")
  #darrow(2.55cm, 1.8cm, 3.05cm, 2.0cm)
  #darrow(2.55cm, 3.1cm, 3.05cm, 2.6cm)
  #dnode(3.1cm, 1.8cm, 2.4cm, 1.0cm, "CDN\n60 s TTL", fill: rgb("#f0ece2"))
  #darrow(5.55cm, 2.3cm, 6.05cm, 2.3cm, label: "miss")
  #dnode(6.1cm, 1.8cm, 2.7cm, 1.0cm, "API gateway\nauth + quota", fill: rgb("#dce9f2"))
  #darrow(8.85cm, 2.3cm, 9.35cm, 2.3cm)
  #dnode(9.4cm, 1.8cm, 2.7cm, 1.0cm, "L7 proxy\n6 app nodes")
  #darrow(12.15cm, 2.3cm, 12.65cm, 2.3cm)
  #dnode(12.7cm, 1.8cm, 3.6cm, 1.0cm, "tracking service", fill: rgb("#dce9f2"))

  #dnode(12.7cm, 3.5cm, 3.6cm, 0.9cm, "Postgres\n1.97 TB/yr", fill: rgb("#f2dcdc"))
  #darrow(14.5cm, 2.8cm, 14.5cm, 3.5cm)

  #dnode(0.2cm, 4.6cm, 2.6cm, 1.0cm, "hub\nscanners")
  #darrow(2.85cm, 5.1cm, 3.35cm, 5.1cm, label: "938/s")
  #dnode(3.4cm, 4.6cm, 2.8cm, 1.0cm, "scan ingest\n202 Accepted")
  #darrow(6.25cm, 5.1cm, 6.75cm, 5.1cm)
  #dnode(6.8cm, 4.6cm, 2.6cm, 1.0cm, "queue", fill: rgb("#fbf6ee"))
  #darrow(9.45cm, 5.1cm, 9.95cm, 5.1cm)
  #dnode(10.0cm, 4.6cm, 2.4cm, 1.0cm, "scan worker")
  #darrow(12.45cm, 4.9cm, 14.3cm, 4.45cm)

  #dnode(10.0cm, 6.0cm, 6.3cm, 0.8cm, "webhook sender (own pool, own retries)", fill: rgb("#f0ece2"))
  #darrow(9.95cm, 6.4cm, 9.45cm, 6.4cm)
  #dnode(6.8cm, 6.0cm, 2.6cm, 0.8cm, "partner URL", fill: rgb("#f0ece2"))
  #darrow(11.2cm, 5.6cm, 11.2cm, 6.0cm)
]

#subsection[Step 6 --- Deep dive 1: rate limiting that survives contact with reality]

*The tiers.*

#table(columns: (auto, auto, auto, auto, auto),
  [*Tier*], [*Partners*], [*Limit*], [*= RPS each*], [*Sum*],
  [free], [3,600], [60 / min], [1], [3,600],
  [pro], [380], [600 / min], [10], [3,800],
  [enterprise], [20], [6,000 / min], [100], [2,000],
  [], [*4,000*], [], [], [*9,400 RPS*],
)

Check the arithmetic:
$ "3,600" times 1 + 380 times 10 + 20 times 100 = "3,600" + "3,800" + "2,000" = "9,400" $

*Now the sentence almost nobody says:* my fleet serves 4,000 RPS at healthy utilisation, but
the sum of the limits I have promised is 9,400 RPS.

$ "oversubscription" = "9,400" / "4,000" = 2.35 times $

I am *2.35x oversubscribed*. That is normal --- airlines and ISPs do the same --- but it
must be a *decision*, not an accident, and it carries three obligations:

+ *A global limiter as well as a per-key one.* If total traffic crosses 4,000 RPS, start
  shedding the *lowest tier first*. A free-tier 429 is a broken sample script; an
  enterprise 429 is a broken business.
+ *A concurrency cap per node,* because the failure mode is not "too many requests", it is
  "requests got slow" (Piece 2).
+ *Alert on the oversubscription ratio itself.* When sales sign 200 more pro partners, the
  ratio becomes
  $("9,400" + 200 times 10) \/ "4,000" = "11,400" \/ "4,000" = 2.85$, and somebody has to
  decide whether to buy nodes.

*Where the limiter runs.* Not in the app --- with 6 nodes, a local limit of 60/min per key
would let a client do $6 times 60 = 360$/min by getting unlucky across nodes. It runs in
the *gateway*, backed by a shared counter in Redis.

$ "Redis ops at peak" = "4,271 RPS" times 1 "op" = "4,271 ops/s" $

which is under 5% of one Redis node. The GCRA algorithm from Piece 1 fits this perfectly:
one `GETSET`-style operation, one small value per key.

$ "memory" = "4,000 keys" times 100 "bytes" = "400 KB" $

*Decision:* GCRA in the gateway on shared Redis, plus a per-node concurrency cap, plus a
global shed-by-tier rule. The failure mode of Redis being down is "fail open" --- allow the
request --- because a rate limiter must never become the reason the API is down.

#subsection[Step 6 --- Deep dive 2: webhooks, which are an API you call]

Polling costs 833 RPS of mostly-unchanged answers. A webhook fires only on change:

$ "changes/day" = "27,000,000 scans" arrow.r "but only 2 of 9 codes are interesting" $
$ "27,000,000" times (2/9) = "6,000,000 webhook events/day" $
$ "6,000,000" / "86,400" = 69.4 "deliveries per second" $

That is 12x less traffic than polling --- but now *you* are the client, and every mistake a
bad API client makes is now yours to avoid.

#formulas(title: "The five rules of sending a webhook")[
+ *Sign the body.* `X-Signature: sha256=<hmac(secret, timestamp + "." + body)>`, with the
  timestamp inside the signed material so an old capture cannot be replayed. Without this,
  anyone who learns the URL can post fake "delivered" events.
+ *At-least-once, with an id.* Include `eventId` and tell partners to ignore duplicates. You
  cannot promise exactly-once across a network you do not control; promising it is a lie
  that breaks their accounting.
+ *Timeout hard --- 5 seconds --- and retry with backoff:* 1 s, 10 s, 1 min, 10 min, 1 h, 6 h.
  Six attempts across about 7 hours, then dead-letter.
+ *Isolate slow partners.* One partner whose endpoint takes 5 seconds must not consume the
  sender pool. Give each webhook its own small concurrency budget, and use the circuit
  breaker from earlier: after 20 consecutive failures, mark the webhook `backing-off` and
  stop trying for an hour.
+ *Give them a replay endpoint.* `POST /v1/webhooks/{id}/replay?from=...` lets a partner
  recover from their own outage without emailing support. This single endpoint removes most
  webhook support tickets.
]

*The arithmetic that decides the sender pool size.* Little's law again:

$ "in flight" = 69.4 "deliveries/s" times 0.4 "s average" = 27.8 $

So about 28 concurrent HTTP calls in steady state --- one small worker handles it. But size
for the bad day: if 10% of partners go slow and take the full 5-second timeout,

$ 69.4 times 0.1 times 5 = 34.7 "in flight on the slow path alone" $

so provision roughly $28 + 35 = 63$ concurrent slots, with the slow ones *capped per
partner* so they cannot take all 63.

#subsection[Step 6 --- Deep dive 3: caching a tracking page at the edge]

The 60-second `Cache-Control` is worth an explicit number.

$ "requests/day" = "72,000,000" $
$ "distinct parcels checked" = "12,000,000" $

If each parcel is checked 6 times a day and the cache holds an answer for 60 seconds, the
cache only helps when two checks fall inside the same minute. Bursty checking makes that
common; assume a measured 70% hit rate.

$ "origin RPS at peak" = "3,333" times (1 - 0.70) = "1,000 RPS" $

$ "3,333" / "1,000" = 3.3 times "less origin traffic" $

That changes the node count:
$ ("1,000" + 938) / "2,000" = 0.97 arrow.r 1 "node of work" $
which, with the same zone-failure rule, becomes 2 per zone = 4 nodes instead of 6.

*The cost, stated honestly:* a buyer may see a status up to 60 seconds old. For "out for
delivery" that is fine. For the *final* "delivered" event it is annoying. So: shorten the
TTL to 10 seconds once the parcel enters "out for delivery", and purge the key when the
`delivered` event is processed. Say both halves --- the saving *and* the staleness you chose
to accept.

#subsection[Step 7 --- Trade-offs, failure modes, and 10x]

#table(columns: (auto, 1fr, 1fr, 1fr),
  [*Decision*], [*Chosen*], [*Rejected*], [*Why in one line*],
  [scan writes], [queue, return 202], [write synchronously, 201],
    [a database blip must never make a hub scanner retry a truck-load of parcels],
  [dedupe], [unique index on `scanner_seq`], [check-then-insert in code],
    [two retries 5 ms apart both pass a check; only a constraint is race-free],
  [rate limiting], [GCRA in the gateway on shared Redis], [per-node counters],
    [6 nodes would silently allow 6x the published limit],
  [Redis unavailable], [fail *open*], [fail closed],
    [the limiter must never be the reason the API is down],
  [notifications], [webhooks + polling both], [webhooks only],
    [some partners cannot accept inbound calls; polling is their only option],
  [read freshness], [60 s CDN TTL, 10 s when out for delivery], [no caching],
    [3.3x less origin traffic for a staleness nobody notices until the last hop],
)

*Failure modes.*

#table(columns: (auto, 1fr, 1fr),
  [*Failure*], [*Symptom*], [*What I do*],
  [one app node dies], [passive ejection after 5 errors],
    [the proxy retries the `GET` on another node; users see nothing. Writes are already in the queue.],
  [a whole zone dies], [half the nodes gone],
    [3 remaining nodes at 71% (computed above). DNS/ALB stops sending to the dead zone in 30--60 s.],
  [queue backs up], [scans appear minutes late],
    [tracking shows a stale status but *never a wrong* one. Alert on queue age, not queue length.],
  [one partner polls 50x their quota], [429s for them only],
    [per-key limiting contains it by construction. If they persist, revoke the key.],
  [a partner's webhook URL hangs for 30 s], [sender pool fills],
    [5 s timeout + per-partner concurrency cap + circuit breaker after 20 failures],
  [Redis (limiter) dies], [no limiting],
    [fail open, alert loudly. The concurrency cap per node is the backstop that keeps nodes alive.],
)

*At 10x (120 million parcels in flight, 33,330 reads/s peak).*
+ The CDN does more of the work, not less: at 10x the traffic on the same 12 million hot
  parcels, the hit rate rises. Measure it before buying nodes.
+ Split reads and writes into separate services and separate pools. Today they share nodes;
  at 10x a scan-ingest spike would hurt buyer reads.
+ Move `scan_events` out of Postgres --- at 10x it is 19.7 TB/year and is only ever read by
  tracking number, which is exactly the wide-column access pattern.
+ Regionalise: put read replicas and a gateway in each major market, keep writes in one
  region. Tracking reads tolerate replica lag; label creation does not.
]

#ex(15, tier: 2, asked: "Grab · pattern")[
A partner complains: "your API returned 200 OK but the shipment was created twice." Your
code has an idempotency key. Find the bug.
#sol[
There are exactly three places this can break. Walk them in order.

*Bug A --- the key is stored after the work, not before.*

```js
// WRONG
const existing = await store.get(key);
if (existing) return existing.response;
const shipment = await createShipment(body);   // <- two retries are both here
await store.put(key, { response: shipment });
```
Two retries 5 ms apart both find nothing, both create. The window is the whole duration of
`createShipment`.

*Fix:* claim the key *first*, with an insert that fails if it exists.
```js
// begin() is an INSERT ... ON CONFLICT DO NOTHING
const claim = await store.begin(key, fingerprint, now);
if (claim.state === "done")        return claim.response;
if (claim.state === "in_progress") return { status: 409, retryAfter: 1 };
```

*Bug B --- the key is scoped globally instead of per partner.* If two partners happen to
send the same UUID, one sees the other's shipment. The key must be
`(partner_id, idempotency_key)`.

*Bug C --- the client generates a new key per attempt.* This is the most common cause and
it is *not your bug* --- but it is your documentation's bug. A client that calls
`uuid()` inside the retry loop defeats the whole mechanism. The docs must show the key
being generated *before* the first attempt and reused for every retry, and the API should
reject a `POST /v1/shipments` that arrives with no key at all, so the mistake is impossible
to make silently.

*How I would find which one it is:* log `idempotency_key`, `partner_id` and
`request_fingerprint` on every create. Two rows with the same key means A or B. Two rows
with different keys and the same fingerprint means C.
]
#ans[Claim the key before doing the work (insert-or-fail), scope it per partner, and require the key so a client cannot silently omit it. The "different key per retry" case is a docs bug.]
]

#ex(16, tier: 2, asked: "Agoda · pattern")[
Your p50 is 30 ms and p99 is 900 ms. The gateway timeout is 1 second. Traffic doubles and
everything falls over. Explain why, with Little's law.
#sol[
*Before.* Average latency with a 99/1 split:
$ 0.99 times 30 + 0.01 times 900 = 29.7 + 9 = 38.7 "ms" $
At 2,000 RPS:
$ "in flight" = "2,000" times 0.0387 = 77.4 $
Comfortable against, say, a 200-slot worker pool.

*After doubling to 4,000 RPS,* if latency stayed the same:
$ "4,000" times 0.0387 = 154.8 arrow.r "still under 200" $
So on paper it should be fine. It is not, and here is why.

*The utilisation law bites.* At 2,000 RPS the fleet was at, say, 50% utilisation, so the
queueing multiplier was $1\/(1-0.5) = 2$. At 4,000 RPS it is at 100% --- the multiplier goes
to infinity. Real latency does not stay at 38.7 ms; it climbs.

Suppose average latency rises to 300 ms:
$ "in flight" = "4,000" times 0.300 = "1,200" $
against 200 slots. *Six times oversubscribed.* Requests queue for slots, which raises
latency further, which raises the in-flight count further. This loop is called *congestion
collapse*, and it never recovers on its own.

*Then the timeout makes it worse.* Requests that queue for more than 1 second are abandoned
by the gateway --- but the *server is still working on them*. You are now spending 100% of
your CPU producing responses that nobody will read.

*The three fixes, in order of effect.*
+ *Shed load at the door.* The concurrency limiter: if in-flight is at 200, return 503
  immediately. 503 in 1 ms is enormously better than 200 OK in 4 seconds, because the
  client can retry elsewhere and the server stays healthy.
+ *Drop work whose deadline has passed.* Before starting a request, check whether the
  caller's deadline is already gone; if so, discard it without doing the work.
+ *Add nodes so peak utilisation is 65%*, which is the whole point of the earlier
  arithmetic.

*The sentence to say:* "The system did not fail because of the extra traffic; it failed
because it had no way to say no."
]
#ans[Utilisation crossed 100%, so latency rose, so in-flight requests (Little's law) exploded past the worker pool. Fix by shedding at the door, dropping expired work, and sizing for 65%.]
]

#section[Tier 3 · Large-scale: the global edge at one million requests per second]
#tier-header(3)

#ex(17, tier: 3, asked: "Google · pattern")[
Design the edge --- everything from the user's DNS lookup to your service --- for a product
serving 1 million requests per second across four regions. All seven steps.
]

#sol[
#subsection[Step 1 --- Clarify]

#table(columns: (1fr, 1fr),
  [*Question*], [*What it changes*],
  [Must a user always reach the *nearest* region, or the *fastest healthy* one?],
    [Nearest is DNS geo-routing, simple and static. Fastest healthy needs anycast plus live health data, and it is what makes failover invisible.],
  [Is any request sticky to a region (session state, a write leader)?],
    [If yes, a region failover is a correctness problem, not just a capacity one. If no --- fully stateless --- failover is only arithmetic.],
  [What is the p99 latency target?],
    [200 ms lets me terminate TLS at a regional edge. 50 ms forces edge points of presence close to users, which is a much bigger build.],
  [What must survive: one node, one zone, or one whole region?],
    [This is the single most expensive question in the design. Surviving a region costs 33% more hardware --- computed below.],
  [Are there long-lived connections (WebSocket, gRPC streams)?],
    [Long connections make deploys hard: draining a node means waiting out connections that may last hours, so I need connection lifetime limits.],
)

*Assumptions:* fastest healthy region via anycast; fully stateless requests; p99 target
150 ms; must survive the loss of one entire region; mostly short HTTP requests with
keep-alive.

#subsection[Step 2 --- Scale estimate]

*Per region, in the normal case.*
$ "1,000,000" / 4 = "250,000 RPS per region" $

*L7 proxy nodes.* One tuned L7 node handles about 25,000 RPS.
$ "250,000" / "25,000" = 10 "nodes per region" $

*But we promised to survive losing a region.* The other three must carry everything:
$ "1,000,000" / 3 = "333,333 RPS per surviving region" $
$ "333,333" / "25,000" = 13.3 arrow.r 14 "nodes per region" $
$ 14 times 4 = "56 nodes total" $

$ "the cost of region redundancy" = (56 - 40) / 40 = 40% "more hardware" $

Name that number out loud. "Surviving one region costs 40% more edge hardware" is a
business decision, not an engineering one, and showing you know its price is the point.

*Connections in flight.* Little's law, with an average request lifetime of 60 ms:
$ "1,000,000" times 0.060 = "60,000 requests in flight globally" $
$ "60,000" / 56 = "1,071 concurrent requests per node" $
Fine for an event-driven proxy; impossible for a thread-per-request one at 1 MB of stack
each ($"1,071"$ MB per node).

*TLS cost.* With keep-alive at 50 requests per connection:
$ "new connections/s" = "1,000,000" / 50 = "20,000 globally" $
$ "per region" = "20,000" / 4 = "5,000 per second" $
$ "CPU at 1.5 ms per full handshake" = "5,000" times 0.0015 = 7.5 "cores per region" $
With 80% session resumption:
$ "5,000" times 0.20 times 0.0015 = 1.5 "cores per region" $

*Bandwidth.* An average response of 1.5 KB:
$ "1,000,000" times "1,500" = 1.5 times 10^9 "bytes/s" = 1.5 "GB/s" $
$ times 8 = 12 "Gbit/s globally" = 3 "Gbit/s per region" $

#note[
Notice which of those numbers is the binding constraint. Not bandwidth (3 Gbit/s per region
is one network card). Not TLS (1.5 cores). It is *request rate*: 25,000 RPS per node is
what sets the fleet size. Say which number binds and why --- it proves the estimate was
thinking, not ritual.
]

#subsection[Step 3 --- The edge contract]

An edge has an API too. It is just not the product's API.

#code(lang: "text", caption: "What every backend must implement, and what the edge adds")[
```text
Every backend MUST serve:
  GET /_health/live     200 if the process is alive        (restart me if not)
  GET /_health/ready    200 if it should get traffic       (route to me or not)
  POST /_lb/drain       stop passing readiness, finish open requests

Every request the edge forwards CARRIES:
  X-Request-Id:      <uuid>       made at the edge if absent, logged everywhere
  X-Forwarded-For:   <client ip>   appended, never trusted from the client
  X-Forwarded-Proto: https
  X-Request-Deadline: <unix ms>    the budget; every hop must honour it
  traceparent:       <w3c trace>   so one request is one trace across services

Every response the edge adds:
  Server-Timing: edge;dur=2, origin;dur=41
  X-Cache: HIT | MISS | BYPASS

Edge policy, per route:
  timeout           2s connect, 10s total
  retries           GET/HEAD/PUT/DELETE: 1 retry on connect-error or 502/503/504
                    POST: never, unless Idempotency-Key is present
  retry budget      retries may not exceed 10% of requests to that pool
  outlier ejection  5 consecutive 5xx -> eject for 30s, doubling each time
```
]

#trap[
`/_health/live` and `/_health/ready` must be *different*. `live` answers "is the process
broken?" --- if it fails, restart the container. `ready` answers "should I get traffic right
now?" --- it can go false while the process is perfectly healthy, during warm-up or draining.

Teams that use one endpoint for both get a very specific disaster: a database blip makes
health checks fail, the orchestrator decides every container is dead, and it restarts the
*entire fleet* at once. The application was fine. The health check killed it.
]

#subsection[Step 4 --- The data model of an edge]

An edge is mostly stateless, but not entirely. Three pieces of state, with very different
freshness needs:

#table(columns: (auto, 1fr, auto, 1fr),
  [*State*], [*What it is*], [*Freshness*], [*Where it lives*],
  [routing config], [route patterns, backend pools, weights, timeouts], [seconds],
    [pushed from a control plane; each node keeps the last good copy on disk],
  [health state], [which backends are up, per node], [milliseconds],
    [*local to each node*, from its own observations --- never shared],
  [rate-limit counters], [per API key], [milliseconds],
    [a shared store, with a local pre-filter],
  [TLS certificates], [per domain], [hours], [pushed, cached, auto-renewed],
)

*The decision worth defending: health state is local, not shared.* A shared health
registry sounds better --- "every node knows everything" --- and is worse for two reasons.
*One:* it is a single point of failure that can declare your entire fleet dead.
*Two:* health is not global. Node 7 may genuinely be unable to reach backend B because of a
broken link between them, while node 8 reaches it fine. A local view is *more correct*, not
less. Active checks from a central place are a useful *slow* signal; the fast signal is
each node watching its own traffic.

#subsection[Step 5 --- Architecture]

#diagram(height: 7.2cm, caption: "One anycast address, four regions. Health is decided locally at each L7 node, not centrally.")[
  #dnode(0.2cm, 0.1cm, 8.8cm, 0.9cm, "1M RPS peak · 56 L7 nodes · 12 Gbit/s · survive one region loss", fill: rgb("#fbf6ee"))

  #dnode(0.2cm, 1.4cm, 2.4cm, 1.0cm, "user")
  #darrow(2.65cm, 1.9cm, 3.15cm, 1.9cm, label: "DNS")
  #dnode(3.2cm, 1.4cm, 3.0cm, 1.0cm, "one anycast IP\nTTL 60 s", fill: rgb("#f0ece2"))
  #darrow(6.25cm, 1.7cm, 6.75cm, 1.4cm)
  #darrow(6.25cm, 1.9cm, 6.75cm, 3.3cm)
  #darrow(6.25cm, 2.1cm, 6.75cm, 4.7cm)
  #darrow(6.25cm, 2.3cm, 6.75cm, 6.1cm)

  #dnode(6.8cm, 0.9cm, 3.2cm, 1.0cm, "REGION sg\n14 L7 nodes", fill: rgb("#dce9f2"))
  #dnode(6.8cm, 3.0cm, 3.2cm, 1.0cm, "REGION in\n14 L7 nodes", fill: rgb("#dce9f2"))
  #dnode(6.8cm, 4.4cm, 3.2cm, 1.0cm, "REGION eu\n14 L7 nodes", fill: rgb("#dce9f2"))
  #dnode(6.8cm, 5.8cm, 3.2cm, 1.0cm, "REGION us\n14 L7 nodes", fill: rgb("#dce9f2"))

  #dnode(10.8cm, 0.9cm, 2.6cm, 1.0cm, "L4 LB\n(zone A+B)")
  #darrow(10.05cm, 1.4cm, 10.75cm, 1.4cm)
  #dnode(13.8cm, 0.3cm, 2.6cm, 0.9cm, "service pool 1")
  #dnode(13.8cm, 1.4cm, 2.6cm, 0.9cm, "service pool 2")
  #darrow(13.45cm, 1.2cm, 13.75cm, 0.75cm)
  #darrow(13.45cm, 1.5cm, 13.75cm, 1.85cm)

  #place(dx: 10.8cm, dy: 2.7cm)[#text(size: 7.5pt, fill: muted)[each region has the same\ inside; drawn once]]

  #dnode(10.8cm, 4.0cm, 5.6cm, 0.9cm, "control plane: routes, weights, certs (push, seconds)", fill: rgb("#fbf6ee"))
  #darrow(10.75cm, 4.45cm, 10.05cm, 4.45cm, dashed: true)

  #dnode(10.8cm, 5.2cm, 5.6cm, 0.9cm, "rate-limit store (shared counters)", fill: rgb("#fbf6ee"))
  #darrow(10.75cm, 5.65cm, 10.05cm, 5.65cm, dashed: true)

  #dnode(0.2cm, 4.4cm, 6.0cm, 1.8cm, "health is decided LOCALLY on each L7 node:\n5 consecutive 5xx -> eject that backend 30 s\n(doubling). No shared health registry.", fill: rgb("#e7f0e7"))
]

#subsection[Step 6 --- Deep dive 1: what actually happens when a region dies]

Walk the clock. This is the answer an interviewer is really asking for.

#table(columns: (auto, 1fr),
  [*t = 0 s*], [Region `sg` loses power. 250,000 RPS of users are mid-request; they get connection resets.],
  [*t = 0--10 s*], [Anycast withdraws the route (BGP). New packets to the same IP are delivered to the next closest region. Users who retry immediately already succeed. Users on a pinned TCP connection wait for their timeout.],
  [*t = 10 s*], [`in` and `eu` each gain roughly 125,000 RPS. `in` was at $"250,000"\/(14 times "25,000") = 71%$; it is now at $"375,000" \/ "350,000" = 107%$ --- *over capacity*.],
  [*t = 10--60 s*], [Load shedding engages: the concurrency limiter returns 503 for traffic above capacity, protecting latency for the rest. Roughly 7% of requests are shed. This is the design working, not failing.],
  [*t = 60 s*], [The three surviving regions were provisioned for $"333,333"$ RPS each --- that is why we bought 14 nodes instead of 10 --- so once traffic settles evenly, all of it fits: $"333,333" \/ "350,000" = 95%$.],
  [*t = 2--5 min*], [Autoscaling adds nodes if configured, bringing utilisation back under 70%.],
)

*Two honest admissions to make unprompted.*

*One:* at $t = 60$ s the surviving regions are at 95% utilisation, and the utilisation law
says that is a 20x latency multiplier. Surviving a region at *full quality* would need
$ "1,000,000" / (3 times 0.65 times "25,000") = 20.5 arrow.r 21 "nodes per region" $
$ 21 times 4 = 84 "nodes" = 110% "more than the 40 we need for a normal day" $
*Decision:* buy 14, not 21. Accept degraded latency for the first few minutes of a
region-loss event, because it happens perhaps once a year and paying 110% extra every day
to make it invisible is not worth it. State the trade with the numbers; do not pretend it
is free.

*Two:* traffic does not redistribute evenly. Anycast sends `sg`'s users to whichever region
is closest *by network topology*, which may be `in` for almost all of them. Plan for the
worst split (one region absorbs everything) by making the load-shedding rule per region, not
global.

#subsection[Step 6 --- Deep dive 2: deploys without dropping a request]

56 nodes, deployed one at a time, is slow. Deployed all at once, it is an outage. The
arithmetic decides the batch size.

*Capacity during a rolling deploy.* With 14 nodes per region and batch size $b$:
$ "capacity during the deploy" = (14 - b) / 14 $

#table(columns: (auto, auto, auto, auto),
  [*Batch*], [*Capacity left*], [*Utilisation at 250k RPS*], [*Verdict*],
  [1], [92.9%], [76.9%], [safe, but 14 rounds],
  [2], [85.7%], [83.3%], [acceptable, 7 rounds],
  [3], [78.6%], [90.9%], [10x latency multiplier --- no],
  [7], [50%], [143%], [outage],
)

$ "utilisation at batch" b = "250,000" / ((14 - b) times "25,000") $

Check batch 2: $"250,000" \/ (12 times "25,000") = "250,000" \/ "300,000" = 83.3%$. Correct.

*Decision: batch size 2*, seven rounds per region. And the sequence for each node matters
more than the batch size:

+ `POST /_lb/drain` --- the node starts failing `ready`, so the L4 layer stops sending *new*
  connections. It is still serving the ones it has.
+ *Wait the drain window.* How long? Long enough for in-flight requests to finish:
  $"p99.9 request time" approx 2$ s, so wait 30 s to be safe. For long-lived connections,
  send `Connection: close` on responses so clients reconnect elsewhere naturally.
+ *Then* stop the process. Now zero requests are lost.
+ Start the new version; it fails `ready` while it warms up (JIT, connection pools, caches).
  *Only then* does it get traffic.

#trap[
Skipping step 2 is the single most common cause of "we see 502s during every deploy". The
orchestrator says the pod is terminating and the load balancer has not yet noticed --- there
is a gap of a few seconds in which traffic is still being sent to a process that is exiting.
The fix is boring and reliable: fail readiness *first*, wait longer than you think, *then*
exit.
]

#subsection[Step 6 --- Deep dive 3: choosing the algorithm at 2,000 backends]

Behind the 56 L7 nodes sit thousands of service instances. The simulation from Tier 1 said
least-connections and power-of-two-choices perform within 1% of each other. At this scale
the tie is broken by two other facts.

*Fact 1 --- cost per decision.*
$ "least connections at 2,000 backends" = "1,000,000" times "2,000" = 2 times 10^9 "comparisons/s" $
$ "power of two" = "1,000,000" times 2 = 2 times 10^6 "comparisons/s" $
A factor of 1,000.

*Fact 2 --- each proxy node has a different view.* With 56 nodes, "least loaded" is computed
from 56 separate, slightly stale pictures. They agree often enough to all pick the same
backend at the same moment --- and then that backend is the *most* loaded one, a millisecond
later. Power of two choices cannot herd, because the two candidates are random.

*Decision: power of two choices, plus a bounded-load guard.* The guard is one line: never
send to a backend whose in-flight count exceeds $c times "average"$, with $c = 1.25$. If both
random picks are over the bound, sample again. This gives you P2C's $O(1)$ cost with a hard
ceiling on how bad any single backend's queue can get.

*And one exception I would carve out:* requests that must reach a specific instance --- a
cache shard, a WebSocket session --- use consistent hashing with bounded loads instead, keyed
on the session or shard id. Different question, different algorithm; say which one you are
answering.

#subsection[Step 7 --- Trade-offs, failure modes, and 10x]

#table(columns: (auto, 1fr, 1fr, 1fr),
  [*Decision*], [*Chosen*], [*Rejected*], [*Why*],
  [region routing], [anycast], [DNS geo-routing],
    [failover in \~10 s (BGP) versus 60+ s (DNS TTL), and clients cache DNS badly],
  [region redundancy], [14 nodes/region (N+1 region)], [10 nodes/region],
    [40% more hardware buys survival of a full region loss],
  [failover quality], [degraded for minutes], [21 nodes/region for full quality],
    [110% extra cost every day to make a once-a-year event invisible is bad value],
  [backend selection], [power of two + bounded load], [least connections],
    [1,000x cheaper per decision and immune to cross-node herding],
  [health decisions], [local per node], [a shared health registry],
    [a shared registry is a single point of failure that can declare the fleet dead],
  [deploys], [batch of 2, drain 30 s first], [batch of 3+],
    [batch 3 puts the region at 91% utilisation --- a 10x latency multiplier],
  [overload], [shed at the door with 503], [queue everything],
    [a fast 503 is recoverable; congestion collapse is not],
)

*Failure modes.*

#table(columns: (auto, 1fr, 1fr),
  [*Failure*], [*Symptom*], [*What happens*],
  [one L7 node dies], [1/14 of a region's capacity gone],
    [L4 health check ejects it in \~2 s; region goes from 71% to 77% utilisation. Invisible.],
  [one backend goes slow, not down], [p99 climbs, no errors],
    [*the hardest case.* Passive ejection only counts 5xx, and a slow backend returns 200. Fix: eject on latency outliers too --- eject a backend whose p99 is over 3x the pool median.],
  [a retry storm after a blip], [3x traffic on a recovering service],
    [retry budget caps retries at 10% of traffic; circuit breakers open; full-jitter backoff spreads what remains],
  [control plane pushes a bad route], [every node breaks at once],
    [*the scariest failure in this design.* Mitigate: canary the config to 1 node for 60 s before the fleet, validate the config on each node before applying, and keep the last good copy on disk so a node can boot without the control plane.],
  [certificate expires], [total outage on one domain],
    [alert at 30 days, auto-renew at 30 days, page at 7. This is a boring, extremely common, entirely preventable outage.],
  [an anycast region is up but its backends are down], [users routed into a black hole],
    [the edge must withdraw its own anycast announcement when its backends fail health checks. *An edge that is healthy but has nothing to serve must stop attracting traffic.*],
)

*At 10x (10 million RPS).*
+ 56 nodes becomes 560 by the same arithmetic --- edge scales linearly because it is
  stateless. The thing that does *not* scale linearly is the control plane pushing config to
  560 nodes; move from push to pull-with-jitter so 560 nodes do not all fetch at once.
+ Add edge points of presence: terminate TLS within 30 ms of the user even when the service
  is 200 ms away. This turns 2 RTT of handshake from 400 ms into 60 ms.
+ Move static and cacheable responses to the CDN entirely, so the 10x applies only to the
  dynamic remainder. Measure what fraction that is before buying 560 nodes.
+ At 10 million RPS, per-key rate-limit counters become the bottleneck: switch to a local
  token bucket per node with periodic reconciliation, accepting a small overshoot in
  exchange for zero shared-store round trips on the hot path.
]

#ex(18, tier: 3, asked: "Amazon · pattern")[
One backend in a 500-instance pool responds in 4 seconds instead of 40 ms, but always
returns 200. Your ejection rule counts 5xx responses. What happens, and how do you fix it?
#sol[
*What happens.* The 5xx-based ejection never fires, because there are no 5xx responses. So
the slow instance stays in the pool and keeps receiving traffic.

With *round robin* it receives $1\/500$ of traffic, and $0.2%$ of all requests take 4
seconds. If the pool serves 100,000 RPS, that is 200 requests per second at 4 seconds ---
and those 200 requests *hold resources*. Little's law:
$ 200 times 4 = 800 "requests permanently in flight on one instance" $
It will hit its connection limit and then start actually failing.

With *least connections or P2C*, the effect is much smaller and this is a real argument for
those algorithms: the slow instance accumulates in-flight requests, so it is chosen less and
less. It self-limits. But it never reaches zero, so a slice of users still waits 4 seconds.

*The p99 arithmetic.* Even at $0.2%$ of requests, this instance alone puts a 4-second answer
at the 99.8th percentile. Your p99.9 SLO is dead, and every dashboard looks fine.

*The fixes, in order.*
+ *Eject on latency, not only on errors.* Compute the pool's median p99 continuously and
  eject any instance whose p99 exceeds 3x it. This is the actual fix and it is what every
  serious proxy calls "outlier detection".
+ *Hedged requests for read-only calls.* If a `GET` has not responded in the pool's p95
  (say 80 ms), send a second copy to a different instance and take whichever answers first.
  Cost:
  $ "extra load" = 5% "of reads" $
  Benefit: the 4-second tail disappears entirely, because the hedge answers in 40 ms. Cap
  hedging at 5% of traffic so it cannot amplify during a general slowdown.
+ *A per-request deadline* so nothing can take 4 seconds in the first place --- it becomes a
  fast failure that the retry logic can handle.

*Decision: all three.* Outlier ejection removes the cause, hedging hides the tail while
detection happens, and deadlines bound the damage. Say why hedging must be capped: without a
cap, a slow *pool* would cause every request to be duplicated, doubling load on something
that is already struggling.
]
#ans[Error-based ejection never fires. Add latency-based outlier ejection (3x pool p99), capped hedged reads at 5%, and per-request deadlines.]
]

#ex(19, tier: 3, asked: "Microsoft · pattern")[
Your autoscaler adds nodes when CPU exceeds 70%, and takes 3 minutes to boot one. Traffic
doubles in 30 seconds. Compute what happens and design around it.
#sol[
*The setup.* 14 nodes per region at 250,000 RPS, so $"250,000" \/ 14 = "17,857"$ RPS per
node against a 25,000 capacity $= 71%$ utilisation.

*t = 0 to 30 s:* traffic doubles to 500,000 RPS.
$ "500,000" / (14 times "25,000") = "500,000" / "350,000" = 143% "of capacity" $

*t = 30 s:* the autoscaler notices and asks for more nodes. How many does it need?
$ "500,000" / (0.65 times "25,000") = 30.8 arrow.r 31 "nodes" $
It must add 17 nodes.

*t = 30 s to 3 min 30 s:* the nodes are booting. For *three minutes*, the region is at 143%
of capacity. Without protection, this is congestion collapse: queues grow, latency grows,
in-flight count grows, and the nodes fall over one by one.

$ "requests arriving during the gap" = "500,000" times 180 "s" = "90,000,000" $
$ "requests the fleet can serve" = "350,000" times 180 = "63,000,000" $
$ "excess" = "27,000,000" "requests with nowhere to go" $

*The design, in four parts.*

+ *Shed immediately, do not queue.* The concurrency limiter returns 503 for everything above
  350,000 RPS. 63 million requests are served correctly at normal latency; 27 million get a
  fast 503 and a `Retry-After`. Compare that to the alternative, where *all 90 million* get
  a slow timeout. Shedding is not failure; it is choosing who gets a good answer.
+ *Scale on the right signal, earlier.* CPU is a lagging indicator. Scale on *in-flight
  requests* or *queue depth*, which move within milliseconds. And set the threshold at 60%,
  not 70%, buying
  $ (0.70 - 0.60) times 14 times "25,000" = "35,000 RPS" "of extra warning" $
  --- worth roughly 30 extra seconds of runway at this growth rate.
+ *Keep warm capacity.* Pre-booted nodes sitting at zero traffic cost money but respond in
  seconds instead of minutes. Two warm nodes per region is
  $ 2 / 14 = 14% "extra cost" $
  and covers a 14% traffic jump instantly.
+ *Attack the 3 minutes.* Most of a 3-minute boot is image pull and application warm-up.
  Pre-pulled images and a smaller startup path routinely get this to 40 seconds, which
  shrinks the danger window by 4.5x. This is usually the cheapest fix of the four and the
  one nobody mentions.

*Decision:* shed first (correctness), scale on in-flight (speed), keep 2 warm nodes
(insurance), and fix the boot time (root cause). The order matters: without shedding, the
other three only change how long the outage lasts.
]
#ans[143% of capacity for 3 minutes, 27 million excess requests. Shed at the door, scale on in-flight rather than CPU, keep 2 warm nodes, and cut boot time from 3 min to 40 s.]
]

#section[Interview drill]

#subsection[Push 1: "L4 or L7? Pick one and defend it."]

#note[
*Answer.* Both, in layers, and I can say what each one buys.

*L4 in front:* it handles millions of connections on modest hardware, survives traffic
floods, and has nothing to parse, so there is very little that can go wrong with it. It is
what receives the anycast address.

*L7 behind it:* it is the only layer that can read a path, so it is the only layer that can
route `/api` and `/static` to different pools, retry an idempotent request on a different
backend, add a request id, and eject a backend on the *content* of its responses.

*If forced to choose one:* L7. Everything in this chapter that saves users --- retries,
outlier ejection, header propagation, per-route timeouts --- requires reading the request. L4
alone would mean every failure is visible to the user.

*The concrete cost of L7:* it must terminate TLS, which is 1.5 cores per region in our
numbers, and it can handle 25,000 RPS per node instead of millions of connections. Worth it.
]

#subsection[Push 2: "You have sticky sessions. Now you cannot deploy. What now?"]

#note[
*Answer.* Sticky sessions are a symptom; the disease is state in the process.

*The real fix:* move the session out --- a signed token in a cookie for small state, or Redis
for large state. Then any node can serve any request, deploys are trivial, and the load
balancer goes back to being free to choose.

*If I cannot change the application today,* the interim plan is:
+ switch stickiness from source-IP hashing to a *cookie*, so a shared office NAT does not
  pin thousands of users to one node;
+ use consistent hashing so adding or removing a node moves $1\/N$ of sessions, not all of
  them;
+ during deploys, drain a node for the full session timeout (say 30 minutes) rather than
  30 seconds --- which means deploys take hours, and that pain is the argument that finally
  gets the real fix funded.

*And the honest exception:* long-lived connections (WebSocket, server-sent events) are
inherently sticky, and that is fine. There, plan for connection lifetime limits --- force a
reconnect every hour --- so a deploy never has to wait for a connection that lasts all day.
]

#subsection[Push 3: "Rate limit by what --- IP, user, or API key?"]

#note[
*Answer.* By API key where there is one, by user id where there is a login, and by IP only
as the outermost, loosest net --- and I will say why IP is nearly useless on its own.

*IP is wrong* because thousands of users share one NAT address on a mobile network or in an
office. An IP limit strict enough to stop an attacker will block a whole college campus.
And an attacker with a botnet has more IPs than your limit has meaning.

*The layered answer I actually deploy:*
+ *per API key or user:* the real limit, generous (60/min free tier).
+ *per IP:* a very loose net, maybe 600/min, to catch unauthenticated abuse on login
  endpoints.
+ *global per endpoint:* protects the backend regardless of who is calling.
+ *per expensive operation:* search and export get their own, much smaller budget, because
  one search costs what fifty reads cost.

The last one is the one candidates miss. *Limit by cost, not by count*: charge a search
10 tokens and a read 1 token from the same bucket.
]

#subsection[Push 4: "Your API returns 200 with an error inside the body. Comment."]

#note[
*Answer.* It is wrong, and here is the specific damage.

Everything in the path --- the proxy, the CDN, the client library, the monitoring --- reads
the status code. A 200 that means failure gets *cached*, is never *retried*, never trips a
circuit breaker, and never appears on an error dashboard. You have hidden your own outage
from yourself.

*What I return instead:* the right status code, plus one consistent error body:

```json
{ "error": { "code": "parcel_not_found",
             "message": "No parcel with that tracking number.",
             "requestId": "01J9Z4K2QW",
             "docs": "https://api.example.com/errors/parcel_not_found" } }
```

Four rules: a *stable machine-readable `code`* (clients switch on it; never on the message
text), a human message, the `requestId` so support can find the log line, and a docs link.

*The one genuine exception:* batch endpoints. `POST /v1/parcels/batch` with 50 items where 3
fail is legitimately `207 Multi-Status` or a 200 with per-item results --- because the request
as a whole succeeded. Say the exception; it shows you know the rule rather than repeating it.
]

#subsection[Push 5: "How do you version an API without breaking anyone?"]

#note[
*Answer.* I version only when I must, and I define "must" precisely.

*Breaking changes* (need a new version): removing a field, renaming a field, making an
optional request field required, narrowing a type, changing the meaning of a value, adding a
new required error case.

*Non-breaking* (no new version): adding a response field, adding an optional request field,
adding a new endpoint, adding a new enum value *if the docs always said "ignore values you
do not know"*.

*The mechanism:* `/v1/` in the path, and both versions live at once, served by the same code
with a translation layer at the edge. I do *not* fork the service.

*The part people forget --- the exit plan.* A version you cannot delete is a version you pay
for forever. So: publish a sunset date the day v2 launches, return the `Sunset` and
`Deprecation` headers on every v1 response, measure v1 usage per API key, and email the top
callers directly. Turn it off in stages --- an hour of "brownout" a week before the date is
worth ten emails.
]

#subsection[Push 6: "A single customer sends 100x their normal traffic. Walk me through it."]

#note[
*Answer.* Four layers catch it, in order, and each one has a number.

+ *Their per-key limit* (60/min) rejects the excess at the gateway with 429 and a
  `Retry-After`. Everyone else is unaffected. *This should be the end of the story.*
+ *If they are an enterprise key* with a 6,000/min limit, 100x is 600,000/min = 10,000 RPS
  against a fleet sized for 4,271. Now the global limiter engages and sheds by tier ---
  free first, enterprise last.
+ *The per-node concurrency cap* is the backstop: whatever gets through, no node accepts
  more work than it can hold, so nothing collapses.
+ *Bulkheads:* expensive endpoints run on their own pool, so a customer hammering search
  cannot take down tracking reads.

*Then the human part, which is half the answer:* I look at the request pattern before
revoking anything. A 100x spike is usually a retry loop in their code caused by *our* 500s,
not an attack. Killing their key would be punishing them for our bug. So: contain it
automatically, then look at whether their retries started right after one of our errors.
]

#subsection[Push 7: "Why do you cap retries at one, not three?"]

#note[
*Answer.* Because of the arithmetic in Example 12 and one more fact.

*The arithmetic:* three attempts means 3x load on a service that is already failing, and
across three service hops it is $3^3 = 27$x.

*The extra fact:* the second retry almost never helps. If a request failed twice against two
*different* backends, the problem is not that backend --- it is the request, the dependency,
or the whole pool. A third attempt is load without information.

*So my configuration is:* 1 retry, on a *different* backend, only for idempotent methods,
only on connect errors and 502/503/504 (never on a timeout after the request was sent ---
the work may have happened), under a 10% retry budget, with full jitter.

*And the number that proves it:* with a 10% budget, a total outage takes traffic from 1,000
RPS to 1,100 RPS. Without a budget, it takes it to 3,000. The budget is the difference
between a service that can recover when you fix it and one that cannot.
]

#subsection[Push 8: "What does your load balancer do when EVERY backend is unhealthy?"]

#note[
*Answer.* This is the question that finds out whether I have run one.

*The naive behaviour --- eject them all, then have an empty pool --- is the worst possible
outcome*, because the pool is empty only when the health check is wrong. A network blip
between the proxy and the backends makes every check fail while every backend is perfectly
fine. Ejecting all of them turns a partial problem into a total outage that the proxy caused.

*So the rule is "panic mode":* if more than 50% of backends are unhealthy, *stop honouring
health status entirely* and load balance across all of them. The reasoning: once half the
fleet looks dead, the health signal is more likely to be broken than the fleet.

Concretely, in this design:
- under 50% unhealthy: route only to healthy backends;
- over 50% unhealthy: ignore health, spread across everything, keep shedding at the
  concurrency cap, and page a human;
- pool genuinely empty: return 503 with `Retry-After`, and *never* crash the proxy --- the
  `pool.length === 0` guard in the Tier 1 code exists for exactly this second.
]

#practice(tier: 0, time: "15 min")[
+ Peak is 12,000 RPS. One node does 900 RPS. How many nodes for 65% utilisation? How many to
  also survive losing one of two zones?
+ At 85% utilisation, what is the latency multiplier? At 70%? How much more traffic took you
  from 70% to 85%?
+ 400,000 RPS, 25 requests per keep-alive connection, 1.2 ms of CPU per full handshake, 75%
  session resumption. Give new connections per second and CPU cores for TLS.
+ A service does 8,000 RPS with 180 ms average latency. How many requests are in flight? If
  latency triples, what is the new number?
+ A client sends 30 requests instantly against a limit of "10 per second, burst 10". How many
  succeed, and what `Retry-After` does request 11 get?
+ Three services chained, each with 2 retries, innermost one hanging. How many requests does
  the innermost service receive per user action?
+ A health check runs every 3 s with 2 strikes. Worst-case detection time? At 20,000 RPS
  across 25 nodes, how many requests fail?
]

#key[
*1.* $"12,000" \/ 900 = 13.3 arrow.r 14$ bare minimum.
For 65%: $"12,000" \/ 0.65 = "18,462"$ RPS of capacity, and $"18,462" \/ 900 = 20.5$, so *21 nodes*.
Zone survival: one zone must carry 12,000 alone at a safe level,
$"12,000" \/ (0.65 times 900) = 20.5 arrow.r 21$ per zone, so *42 nodes*.

*2.* $1\/(1-0.85) = 6.7$ so *6.7x*; $1\/(1-0.70) = 3.3$ so *3.3x*.
Traffic increase: $0.85\/0.70 = 1.214$, so *21% more traffic doubled the latency*.

*3.* $"400,000" \/ 25 = "16,000"$ *new connections per second*.
Full handshakes: $"16,000" times 0.25 = "4,000"$/s.
CPU: $"4,000" times 0.0012 = 4.8$, so *4.8 cores*. (Without resumption it would be
$"16,000" times 0.0012 = 19.2$ cores.)

*4.* $"8,000" times 0.180 = "1,440"$ *in flight*. Tripled: $"8,000" times 0.540 = "4,320"$.
Same traffic, 3x the resources.

*5.* *10 succeed* (the burst), 20 get 429. At 10 per second one request costs
$1000\/10 = 100$ ms, so request 11 gets *`Retry-After: 100ms`*.

*6.* $3 times 3 times 3 = 27$ *requests* for one user action.

*7.* Worst case $3 + 2 times 3 = 9$ *seconds*. Per-node share $"20,000"\/25 = 800$ RPS; typical
detection $2 times 3 = 6$ s, so $800 times 6 = "4,800"$ *failed requests* (7,200 in the worst
case).
]

#practice(tier: 2, time: "40 min")[
+ Design the public API for a "restaurant table booking" service: search availability,
  hold a table for 5 minutes, confirm, cancel. Give 5 endpoints with payloads, say which
  need idempotency keys and why, give the rate-limit tiers, and give the status code for
  "the table was taken while you were holding the form open". Then compute: 2 million
  searches a day with a 5x evening peak --- what is the peak search RPS, and how many nodes
  at 1,200 RPS each with 65% utilisation?
+ Your API has one endpoint that is 40x more expensive than the others (a report). It is 1%
  of requests. Compute what share of your total CPU it consumes, then design the protection
  around it. Give three specific mechanisms and the numbers that justify each.
+ Take the parcel-tracking design and replace polling entirely with webhooks. Compute the
  traffic saved, then list everything that gets *harder*, and say whether you would actually
  do it.
]

#key[
*1.* Endpoints:
`GET /v1/availability?restaurantId=&date=&partySize=&limit=&cursor=` (no key --- it is a
read);
`POST /v1/holds` body `{slotId, partySize}` $arrow.r$ `201 {holdId, expiresAt}` *needs an
idempotency key* --- a retry must not consume two tables;
`POST /v1/bookings` body `{holdId, contact}` $arrow.r$ `201 {bookingId}` *needs one* --- it is
a create;
`DELETE /v1/holds/{holdId}` $arrow.r$ `204` (idempotent by nature);
`DELETE /v1/bookings/{bookingId}` $arrow.r$ `204`.

"The table was taken while you held the form open": *409 Conflict*, with the error code
`slot_no_longer_available` and a suggested alternative in the body. Not 400 (the client's
request was well-formed) and not 404 (the slot exists).

Tiers: anonymous search 30/min per IP; logged-in user 120/min; partner key 1,200/min. Holds
are separately limited at 5 per user per 10 minutes, because a hold consumes inventory --- a
clear case of *limiting by cost, not by count*.

Peak: $"2,000,000" \/ "86,400" = 23.1$ RPS average; $times 5 = 115.7$ *RPS peak*.
Nodes: $115.7 \/ (0.65 times "1,200") = 0.148 arrow.r 1$ node of work, so *2 nodes for redundancy*, and 4 if a zone must survive. The honest answer here is "this does not need a
big fleet" --- say so rather than inventing scale.

*2.* If the report costs 40x and is 1% of requests, then out of 100 requests the cost is
$99 times 1 + 1 times 40 = 139$ units.
$ "report share" = 40/139 = 28.8% "of all CPU" $
1% of requests, 29% of the machine.

Three mechanisms:
(a) *Its own pool (bulkhead).* Size it from the arithmetic: 29% of the work gets its own
nodes, so a report spike cannot touch the other 71%.
(b) *A separate, much smaller rate limit* --- 5/min per key rather than 600/min --- justified
by the 40x cost. Or one shared bucket where a report costs 40 tokens.
(c) *Make it asynchronous:* `POST /v1/reports` $arrow.r$ `202 {jobId}`, then poll or webhook.
This removes it from the request path entirely, so a slow report cannot consume a request
slot (Little's law: a 20-second report at 5 RPS is $5 times 20 = 100$ permanently in flight).

*3.* Traffic saved: polling is 72M reads/day. Real status changes are about
$"27,000,000" times (2\/9) = "6,000,000"$/day.
$ "72,000,000" / "6,000,000" = 12 times "less traffic" $
and the peak read rate falls from 3,333 RPS to $"6,000,000"\/"86,400" = 69.4$ per second of
outbound deliveries.

What gets harder: you now run an HTTP *client* fleet with retries, backoff, signing, secret
rotation, dead-letter handling and per-partner isolation; partners must expose a public
HTTPS endpoint (many cannot); debugging moves to *their* logs, which you cannot see; every
delivery is at-least-once so partners must deduplicate; a partner's outage becomes your
queue backlog; and you need a replay endpoint or you will drown in support tickets.

*Decision: no --- keep both.* Offer webhooks as the efficient path and keep polling for
partners who cannot receive calls, with a cheap conditional-GET path (`If-None-Match`
$arrow.r$ `304 Not Modified`) so polling costs bytes but not database work. Removing polling
saves 12x traffic you were already serving cheaply from a CDN, and buys a support burden.
]

#practice(tier: 3, time: "50 min")[
+ Design the edge for 4 million RPS across 6 regions, surviving the loss of any *two*
  regions simultaneously. Give: RPS per region normally, RPS per surviving region, nodes per
  region at 30,000 RPS each with 65% target utilisation, total nodes, and the percentage cost
  of two-region redundancy versus none. Then say whether you would actually buy it.
+ Your p99 is 90 ms but p99.9 is 6 seconds. Traffic is 200,000 RPS. Compute how many requests
  per second are in the p99.9 tail and how many are in flight because of them. Design the
  three mechanisms that would remove that tail and say what each costs.
+ A config push breaks routing on all 300 edge nodes at once. Design the release process that
  makes this impossible, with specific time windows and the blast radius at each stage.
]

#key[
*1.* Normal: $"4,000,000" \/ 6 = "666,667"$ *RPS per region*.
Losing two: $"4,000,000" \/ 4 = "1,000,000"$ *RPS per surviving region*.
Nodes: $"1,000,000" \/ (0.65 times "30,000") = 51.3 arrow.r 52$ *nodes per region*, and
$52 times 6 = 312$ *nodes*.
With no redundancy: $"666,667" \/ (0.65 times "30,000") = 34.2 arrow.r 35$ per region,
$35 times 6 = 210$ nodes.
$ "cost of surviving two regions" = (312 - 210)/210 = 48.6% $

Would I buy it? *No, not as stated.* Two simultaneous region failures are overwhelmingly
likely to be *correlated* --- a bad deploy, a bad config, an expired certificate --- and extra
hardware does not help with any of those. I would buy single-region redundancy
($"4,000,000"\/5 = "800,000"$ per region $arrow.r 41$ nodes each $arrow.r 246$ total,
*17% extra*) and spend the difference on the things that actually cause correlated failure:
staged config rollout, canary deploys, and certificate automation. *Say the reasoning, not
just the number.*

*2.* p99.9 tail: $"200,000" times 0.001 = 200$ *requests per second at 6 seconds*.
In flight because of them: $200 times 6 = "1,200"$ *requests permanently occupied* --- versus
the healthy traffic's $"199,800" times 0.09 = "17,982"$. So *0.1% of requests hold 6.3% of all
in-flight capacity*.

Three mechanisms:
(a) *Latency-based outlier ejection* (eject a backend whose p99 is 3x the pool median).
Cost: you may eject a healthy backend during a general slowdown, so it needs the same
"panic mode" guard as health checks --- never eject more than 50% of the pool.
(b) *Hedged requests at the p95* for idempotent reads. Cost: 5% extra load; benefit: the
6-second tail collapses to roughly the p95. Must be capped so a slow *pool* does not double
its own traffic.
(c) *A hard per-request deadline* below 6 s --- say 1 s. Cost: those 200 requests per second
now *fail* instead of succeeding slowly. That is the right trade, because a 6-second answer
was already useless to the user and was holding capacity hostage.

*3.* Stages, with blast radius at each:
+ *Validate locally on the node before applying.* A config that does not parse or that
  removes all backends from a route is rejected, and the node keeps its last good copy.
  Blast radius: 0.
+ *Canary to 1 node for 5 minutes.* Watch 5xx rate, p99 and request rate on that node
  against the fleet median. Blast radius: $1\/300 = 0.33%$ of traffic.
+ *1% of the fleet (3 nodes) for 10 minutes.* Blast radius 1%.
+ *One region for 15 minutes.* Blast radius $1\/6 = 16.7%$, and it is a region the anycast
  layer can withdraw in 10 seconds if it goes bad.
+ *The rest, one region at a time, 10 minutes apart.*
+ *Automatic rollback* on any stage where the 5xx rate exceeds 2x the baseline for 60
  seconds --- rollback must not require a human to be awake.

Total rollout: about 90 minutes. That feels slow until you compare it with the alternative,
which is a 300-node outage. And the non-negotiable rule: *the last good config is on every
node's disk*, so a node that reboots while the control plane is broken still serves traffic.
]

#revision[
*The four boxes and what each may know*
L4 (IP + port) $arrow.r$ L7 (the whole HTTP request) $arrow.r$ gateway (request + who sent it)
$arrow.r$ service (the business problem, and nothing about load balancing).

*Numbers to memorise*
#table(columns: (auto, auto, auto, auto),
  [one L7 proxy node], [20--50k RPS], [one app node, JSON], [1--3k RPS],
  [TLS full handshake CPU], [1--2 ms], [requests per kept-alive conn], [20--100],
  [safe utilisation], [60--70%], [health check], [2 s, 3 strikes],
  [drain before shutdown], [30--60 s], [DNS TTL for failover], [30--60 s],
  [anycast failover], [\~10 s], [autoscaler boot], [2--5 min],
  [retry budget], [10% of traffic], [hedge cap], [5% of reads],
)

*The formulas*
- $"latency multiplier" = 1 \/ (1 - rho)$ --- 50% is 2x, 80% is 5x, 90% is 10x
- $"in flight" = "RPS" times "latency (s)"$ (Little's law)
- $"nodes" = "peak RPS" \/ ("target utilisation" times "RPS per node")$
- $"surviving-region RPS" = "total" \/ ("regions" - "failures survived")$
- $"retry amplification" = ("attempts")^("hops")$
- $"new connections/s" = "RPS" \/ "requests per connection"$
- $"TLS cores" = "full handshakes/s" times "handshake CPU seconds"$
- $"sum of limits" = sum ("partners in tier" times "tier RPS")$; compare it with capacity

*Worked numbers from this chapter*
- round robin with one 5x-slow backend: 6,666 of 200,000 requests dropped (3.3%);
  least-connections and power-of-two dropped 0
- P2C gave the slow backend 18,210 requests; least-connections gave it 18,004 --- 1.1% apart
- circuit breaker: 6 of 19 calls never touched the sick backend
- 3 hops x 3 attempts = 27 requests and 81 seconds for one user action
- tracking API: 72M reads/day $arrow.r$ 833 RPS avg, 3,333 peak; 27M scans $arrow.r$ 938 peak
- 4,271 peak RPS $arrow.r$ 3 nodes per zone x 2 zones; a zone loss leaves each at 71%
- sum of published limits 9,400 RPS against 4,000 of capacity = 2.35x oversubscribed
- edge: 1M RPS, 4 regions; 10 nodes/region normally, *14* to survive a region (+40%)
- 60,000 requests in flight globally; 1,071 per node
- TLS: 20,000 new conns/s $arrow.r$ 7.5 cores/region, or 1.5 with 80% resumption
- deploy batch of 2 of 14 leaves 85.7% capacity = 83.3% utilisation; batch of 3 = 91%, too hot

*API rules that score points*
+ nouns and HTTP methods; for real actions, a sub-resource with its own id
+ `/v1/` in the path; add fields freely, never remove or rename
+ cursors, never offsets; the cursor is opaque and encodes a *total* order
+ `Idempotency-Key` required on every create; claim the key *before* doing the work
+ 429 always carries `Retry-After`; 4xx = the client can fix it, 5xx = only you can
+ one error shape everywhere: stable `code`, human `message`, `requestId`, docs link
+ never return 200 with an error inside

*Sentences that score points*
- "I terminate TLS at the L7 proxy, rate limit at the gateway, and my service never load balances."
- "Least connections is $O(n)$ and herds; power of two choices is $O(1)$ and cannot."
- "Health is decided locally on each node --- a shared health registry can declare the whole fleet dead."
- "Over 50% unhealthy, I enter panic mode and ignore health, because the checker is now the likelier fault."
- "A fast 503 is recoverable. Congestion collapse is not."
- "I promised 9,400 RPS of limits against 4,000 of capacity --- that is a deliberate 2.35x oversubscription."
- "Surviving a full region costs 40% more hardware. Surviving it at full latency costs 110%. I chose 40%."
- "Fail readiness first, wait 30 seconds, then exit. That is why we have no 502s on deploy."
]

]
