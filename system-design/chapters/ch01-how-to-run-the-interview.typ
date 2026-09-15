#import "../../shared/lib/style.typ": *

#chapter(num: 1, title: "How to Run a Design Interview",
  tagline: "You are not asked to be right. You are asked to be organised.")[

#section[The idea in one page]

A design interview is 45 minutes long. You are given one line of problem
("design a service that shortens links"), a whiteboard, and silence.
Most candidates fail not because they lack knowledge, but because they have no
*procedure*. They talk for 30 minutes, draw six boxes, and never produce a number,
an endpoint, or a table.

This chapter gives you the procedure. It is seven steps. You will use the same
seven steps for a 40-line class design and for a 40-machine cluster. Only the
size of the numbers changes.

#formulas(title: "The seven steps — memorise this list")[
+ *Clarify.* Ask questions until the problem has a boundary. Write the boundary down.
+ *Estimate.* Turn users into requests per second, bytes per year, bits per second.
+ *API.* Write 3 to 5 concrete endpoints with their payloads.
+ *Data model.* Write the tables or classes, with fields and the chosen key.
+ *Draw.* One picture, boxes and arrows, request path marked.
+ *Deep dive.* Pick the one or two genuinely hard parts and solve them properly.
+ *Trade-offs.* Name both sides, decide, then say what breaks at 10x.

Never skip a step. If you are short on time, *shrink* a step; do not delete it.
An interviewer scores "did the candidate estimate?" as yes or no. Thirty seconds of
arithmetic gets the yes. Zero seconds gets the no.
]

#subsection[The time budget]

45 minutes is the common length. Here is where the minutes go. Print this on the
inside of your eyelids.

#diagram(height: 3.9cm, caption: "The 45-minute budget. The two wide blocks are where the marks are.")[
  #place(dx: 0pt, dy: 2pt)[#text(size: 8pt, fill: muted)[time runs this way]]
  #darrow(92pt, 8pt, 200pt, 8pt)

  #dnode(0pt, 20pt, 50pt, 38pt, "1 Clarify")
  #dnode(53pt, 20pt, 50pt, 38pt, "2 Numbers")
  #dnode(106pt, 20pt, 50pt, 38pt, "3 API")
  #dnode(159pt, 20pt, 50pt, 38pt, "4 Data model")
  #dnode(212pt, 20pt, 85pt, 38pt, "5 Draw the picture", fill: rgb("#dde8f0"))
  #dnode(300pt, 20pt, 85pt, 38pt, "6 Deep dive", fill: rgb("#dde8f0"))
  #dnode(388pt, 20pt, 50pt, 38pt, "7 Trade-offs")

  #place(dx: 0pt,   dy: 62pt)[#text(size: 7.5pt)[0--5 min]]
  #place(dx: 53pt,  dy: 62pt)[#text(size: 7.5pt)[5--10]]
  #place(dx: 106pt, dy: 62pt)[#text(size: 7.5pt)[10--15]]
  #place(dx: 159pt, dy: 62pt)[#text(size: 7.5pt)[15--20]]
  #place(dx: 212pt, dy: 62pt)[#text(size: 7.5pt)[20--30 min]]
  #place(dx: 300pt, dy: 62pt)[#text(size: 7.5pt)[30--40 min]]
  #place(dx: 388pt, dy: 62pt)[#text(size: 7.5pt)[40--45]]

  #place(dx: 0pt, dy: 80pt)[#text(size: 8pt, fill: muted)[If you are still in step 1 at minute 12, you have already lost 20 marks.]]
]

#table(columns: (auto, auto, 1fr),
  align: (left, center, left),
  [*Step*], [*Minutes*], [*The single artefact you must leave on the board*],
  [1 Clarify], [5], [a written list: 3 in-scope features, 3 out-of-scope],
  [2 Estimate], [5], [peak QPS, storage per year, peak bandwidth],
  [3 API], [5], [3--5 endpoints with request and response fields],
  [4 Data model], [5], [2--4 tables with the partition key circled],
  [5 Draw], [10], [one diagram with the read path and write path marked],
  [6 Deep dive], [10], [the hard part, solved, with the failure case handled],
  [7 Trade-offs], [5], [two options, one decision, one 10x remark],
)

#trap[
The single most common failure: the candidate spends 20 minutes on step 1, drawing
out a perfect requirement list, and then has 10 minutes for everything technical.
Clarifying is not free marks. It is a *gate* you pass through, not a room you live in.
Five minutes. Then move.
]

#subsection[The skeleton you draw for almost every HLD]

Before you know anything about the problem, you already know 80% of the picture.
Almost every internet service has this shape. Learn to draw it in 60 seconds, then
*delete* the boxes the problem does not need.

#diagram(height: 4.9cm, caption: "The default skeleton. Draw it, then delete what you do not need.")[
  #dnode(142pt, 4pt, 62pt, 28pt, "CDN", fill: rgb("#f0ece2"))
  #dnode(306pt, 4pt, 58pt, 28pt, "Cache", fill: rgb("#f0ece2"))

  #dnode(0pt, 48pt, 52pt, 30pt, "Client")
  #dnode(70pt, 48pt, 52pt, 30pt, "LB")
  #dnode(142pt, 48pt, 62pt, 30pt, "API gateway")
  #dnode(224pt, 48pt, 62pt, 30pt, "Service")
  #dnode(306pt, 48pt, 58pt, 30pt, "DB primary")
  #dnode(306pt, 92pt, 58pt, 26pt, "DB replica", fill: rgb("#f7f7f5"))

  #dnode(224pt, 108pt, 62pt, 26pt, "Queue")
  #dnode(306pt, 138pt, 58pt, 0pt, "")

  #dnode(388pt, 48pt, 58pt, 30pt, "Blob store", fill: rgb("#f0ece2"))
  #dnode(388pt, 92pt, 58pt, 26pt, "Worker", fill: rgb("#f7f7f5"))

  #darrow(52pt, 63pt, 70pt, 63pt)
  #darrow(122pt, 63pt, 142pt, 63pt)
  #darrow(204pt, 63pt, 224pt, 63pt)
  #darrow(255pt, 48pt, 320pt, 32pt, label: "read")
  #darrow(286pt, 63pt, 306pt, 63pt, label: "miss")
  #darrow(335pt, 78pt, 335pt, 92pt)
  #darrow(250pt, 78pt, 250pt, 108pt, label: "async")
  #darrow(286pt, 118pt, 388pt, 105pt, label: "job")
  #darrow(417pt, 92pt, 417pt, 78pt, label: "put")
  #darrow(40pt, 48pt, 160pt, 32pt, dashed: true, label: "static")
]

#note[
The dashed arrow is the static path: images, CSS, video. It never touches your
service. Saying that sentence out loud is worth a mark on its own.
]

#subsection[What the interviewer is actually filling in]

At the end of the hour the interviewer types a short form. It usually has boxes
close to these five. Every minute you spend should be buying a tick in one of them.

#table(columns: (auto, 1fr, 1fr),
  align: (left, left, left),
  [*Box*], [*Tick if...*], [*Cross if...*],
  [Scope control],
    [you named what you would NOT build],
    [you tried to build everything],
  [Numbers],
    [you produced a peak QPS and a storage figure],
    [you said "it will be a lot of traffic"],
  [Concrete design],
    [endpoints, fields, keys are on the board],
    [only unlabelled boxes are on the board],
  [Depth],
    [you solved one hard thing end to end],
    [you stayed shallow everywhere],
  [Judgement],
    [you compared two options and chose one],
    [you said "it depends" and stopped],
)

#trick[
*The sentence that buys the Judgement tick, every time:*
"Option A gives me X but costs me Y. Option B is the reverse. Because this product
is read-heavy and the user tolerates a few seconds of staleness, I choose A, and I
would revisit it if writes grew past Z."
Name both. Decide. Give the condition that would flip the decision.
]

#section[Step 1 — Clarify]

The prompt you are given is deliberately under-specified. Your job is to cut it down
to something buildable in 45 minutes. There are six questions that fit almost every
problem. Ask four of them. Never ask more than six.

#formulas(title: "The six clarifying questions")[
+ *Who uses it and how many?* ("Is this 10 thousand users or 100 million?")
+ *What are the top three actions?* ("Post, read feed, follow. Anything else?")
+ *Read-heavy or write-heavy, and what ratio?* ("Roughly 100 reads per write?")
+ *How fresh must the data be?* ("Can a reader see a 10-second-old value?")
+ *What must never break?* ("Is losing one message acceptable? Is double charging?")
+ *One region or many?* ("India only, or India plus Singapore?")

And one sentence you always add yourself, without being asked:
"I will treat login, payments, and the admin console as out of scope."
]

#subsection[Why each answer changes the design]

This is the part candidates miss. Do not ask a question and then ignore the answer.
Say out loud what the answer just changed.

#table(columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  [*Question*], [*If the answer is A*], [*If the answer is B*],
  [How many users?],
    [10 K: one server, one Postgres, done],
    [100 M: sharding, cache tier, CDN],
  [Read/write ratio?],
    [100:1 read-heavy: cache + read replicas],
    [1:1: cache barely helps; size the writes],
  [Freshness?],
    [10 s stale is fine: cache aggressively, async],
    [must be exact: read the primary, pay latency],
  [What must never break?],
    [analytics: lose 0.1%, nobody dies],
    [money: idempotency keys, ledger, no deletes],
  [One region?],
    [one: single primary, simple],
    [many: conflict handling, CAP decision needed],
  [Attachments?],
    [text only: DB is enough],
    [files: blob store + CDN + signed URLs],
)

#ex(1, tier: 0, asked: "warm-up")[
Prompt: "Design a system where college clubs can post events and students can see them."
Write four clarifying questions and say what each one changes.
]
#sol[
+ *"How many students and clubs?"* --- 5,000 students means one server. 5 million means a
  feed fan-out problem. It decides whether we even need a cache.
+ *"Does a student see every club's events, or only clubs they joined?"* --- "every" means
  one shared list that can be cached once for everybody. "only joined" means a
  per-student query, which is 1000x more cache entries.
+ *"Do events have posters or video?"* --- text-only keeps everything in the database.
  Media means a blob store, a CDN, and an upload endpoint.
+ *"If an event edit takes 30 seconds to appear, is that a problem?"* --- if yes, we read
  the primary database. If no, we can serve a cached list and refresh it in the
  background, which is far cheaper.

Then the scope sentence: "I will build post-event, list-events, and join-club.
I am leaving out login, notifications, and the moderation queue."
]

#trap[
Do not ask a question whose answer you will not use. Asking "what is the tech stack?"
or "is it on AWS or GCP?" wastes a minute and earns nothing. The interviewer is
listening for whether the question *branches* your design.
]

#section[Step 2 — Estimate]

Chapter 2 is entirely about this. Here is only the part you need to run the interview:
the four numbers you must produce, and the order to produce them in.

#formulas(title: "Four numbers, always in this order")[
*1. Peak QPS.*
$ "requests/day" = "DAU" times "actions per user per day" $
$ "average QPS" = "requests/day" / 86{,}400 $
$ "peak QPS" approx 3 times "average QPS" $

*2. Storage per year.*
$ "bytes/day" = "new rows/day" times "bytes per row" $
$ "bytes/year" = "bytes/day" times 365 $

*3. Peak bandwidth.*
$ "bytes/s" = "peak QPS" times "average response size" $
(multiply by 8 for bits per second)

*4. Server count.*
$ "servers" = "peak QPS" / "QPS one server handles" times 1.5 "(headroom)" $

Round everything. 86,400 seconds in a day. Call it 100,000. You are then about 14%
low, which is fine for a 30-second estimate --- but say out loud that you rounded.
]

#ex(2, tier: 0, asked: "warm-up")[
A service has 5 million daily users. Each opens the app 8 times a day and each open
makes 3 API calls. Find requests per day, average QPS and peak QPS.
]
#sol[
*Requests per day.*
$ 5{,}000{,}000 times 8 times 3 = 120{,}000{,}000 "requests/day" $

*Average QPS.* Divide by the seconds in a day.
$ 120{,}000{,}000 / 86{,}400 = 1{,}388.9 approx 1{,}400 "QPS" $

Check with the rounded divisor: $120{,}000{,}000 / 100{,}000 = 1{,}200$. Close enough
to know the answer is "about one to one and a half thousand".

*Peak QPS.* Traffic is not flat. Use 3x.
$ 1{,}400 times 3 = 4{,}200 "QPS at peak" $
]
#ans[~1,400 QPS average, ~4,200 QPS peak]

#note[
Where does 3x come from? Real consumer traffic in one country has a busy evening.
Roughly 12--15% of a day's traffic lands in the busiest hour, versus 4.2% if it were
perfectly flat. $15 \/ 4.2 approx 3.6$. So 3x is a safe, honest, defensible multiplier.
Say that sentence and the interviewer stops questioning the number.
]

#section[Step 3 — The API surface]

Boxes and arrows are cheap. Endpoints are not. Writing three endpoints proves you
have actually decided what the system does.

#formulas(title: "How to write an endpoint in 20 seconds")[
Give four things and nothing more:
+ *method and path* --- `POST /v1/orders`
+ *request fields* --- `{ userId, items[], couponCode }`
+ *response fields* --- `{ orderId, total, status }`
+ *the one non-obvious header or rule* --- "the client sends `Idempotency-Key`; a
  repeat with the same key returns the first response instead of creating a second order."

Rules that earn marks:
- Version the path: `/v1/`. Costs two characters, shows experience.
- Every list endpoint is paginated: `?limit=20&cursor=...`. Never `?page=7`.
- Every write endpoint that touches money or sends a message is idempotent.
- Return an id, not the whole object, from a create.
]

#ex(3, tier: 0, asked: "warm-up")[
Write the API surface for the club-events service from Example 1.
]
#sol[
#code(lang: "text", caption: "Four endpoints is enough")[
```text
POST /v1/clubs/{clubId}/events
  body  { title, startsAt, venue, description }
  resp  201 { eventId }
  note  header Idempotency-Key: if the phone retries, no duplicate event

GET  /v1/feed?limit=20&cursor=<opaque>
  resp  200 { events: [ {eventId, clubId, title, startsAt, venue} ],
              nextCursor }
  note  cursor, not page number: new events keep arriving at the top,
        so page 2 would show repeats

POST /v1/clubs/{clubId}/members
  resp  204
  note  joining is idempotent by nature; joining twice is still joined

GET  /v1/events/{eventId}
  resp  200 { eventId, clubId, title, startsAt, venue, description, rsvpCount }
```
]
Notice what is *not* here: no `GET /v1/everything`, no admin endpoints, no login.
Saying "login is out of scope" in step 1 lets you skip it here without looking lazy.
]

#trap[
`?page=7` on a feed that is constantly gaining new items at the top is a real bug,
not a style choice. If three new events arrive while the student reads page 1, then
page 2 starts three items later than it should, and the student sees three events
twice and misses none --- or with deletions, misses some entirely. Cursor pagination
("give me what comes after this exact item") has no such hole.
]

#section[Step 4 — The data model]

Two to four tables. Fields. And one thing circled: *the key*.

#formulas(title: "The three key decisions")[
*Primary key* --- what identifies a row.
*Partition key* --- which shard the row lives on. This is the decision that decides
whether the system scales. Choose the field you always have when you read.
*Index* --- the extra lookup path. Every index costs write speed and disk. Add one
only when you can name the query it serves.

Write it in this shape --- it is fast on a whiteboard and unambiguous:
```
events(event_id PK, club_id, title, starts_at, venue, created_at)
   index on (club_id, starts_at)   -- "this club's upcoming events"
```
]

#ex(4, tier: 0, asked: "warm-up")[
Data model for the club-events service. Say which key you partition on and why.
]
#sol[
#code(lang: "text", caption: "Three tables")[
```text
clubs(club_id PK, name, college_id, created_at)

events(event_id PK, club_id, title, starts_at, venue, body, created_at)
    index (club_id, starts_at)      -- club page
    index (college_id, starts_at)   -- college-wide feed

memberships(student_id, club_id, joined_at)
    PK (student_id, club_id)        -- composite; also stops double-join
    index (club_id)                 -- "who is in this club"
```
]

*Partition key: `college_id`.* Reason: every read is scoped to one college. A student
at college 7 never reads college 12's events. So all of college 7's rows can live on
one shard, and every feed query touches exactly one shard. That is the property you
want --- a *single-shard read*.

*Why not partition on `event_id`?* It spreads writes beautifully, but then building
one feed needs a query to every shard and a merge. With 50 shards that is 50 network
calls for one screen. Rejected.

*Why is `memberships` keyed `(student_id, club_id)` and not a fresh id?* Because the
composite key makes "join twice" impossible at the database level, for free. A
uniqueness rule enforced by the database beats a uniqueness rule enforced by
application code that runs on 20 servers at once.
]

#section[Step 5 — Draw the picture]

#formulas(title: "Rules for a whiteboard diagram")[
+ Left to right: client, edge, service, storage. Never scatter boxes randomly.
+ Label *every* arrow with what flows on it, not just with an arrowhead.
+ Mark the *read path* and the *write path* differently (solid and dashed).
+ Put the numbers on the boxes: "3 app servers", "DB 500 GB", "cache 16 GB".
+ Draw dependencies you will not build (auth, payments) as a grey box labelled
  "existing".
+ Leave space on the right. Step 6 will add boxes there.
]

#trick[
Narrate as you draw: "a write comes in here, hits the load balancer, the service
validates it, writes to the primary, and publishes an event to the queue; the worker
picks it up and updates the search index." One sentence per arrow. The interviewer
is following your voice, not your handwriting.
]

#section[Step 6 — Deep dive]

You have 10 minutes and you cannot design everything properly. So choose. The
interviewer wants to see one thing done to the bottom.

#formulas(title: "How to pick the deep dive")[
Pick the part where a *naive answer is visibly wrong*. Usually one of these five:
+ *The hot key.* One item gets 1000x the traffic of the others (a flash sale item, a
  celebrity account). What happens to that shard?
+ *The fan-out.* One write causes a million writes (a post to a million followers).
+ *The uniqueness.* Two requests race to grab the same seat, id, or username.
+ *The retry.* The network times out. Did the payment happen or not?
+ *The big list.* A query that must scan or sort something huge to answer.

If the interviewer has already hinted ("what if one user is very popular?"), that
hint *is* the deep dive. Take it.
]

#section[Step 7 — Trade-offs, failures, and 10x]

#formulas(title: "The closing three minutes, scripted")[
*Trade-off.* "I chose X over Y. X gives me A, Y would have given me B. For this
product A matters more because (reason tied to the user). If (condition) changed, I
would switch to Y."

*Failure modes.* Walk one component at a time and say what happens when it dies:
- Cache dies -> all traffic hits the database. Is the database sized for that? If not,
  add a request coalescing layer or accept a degraded mode.
- Queue backs up -> messages are late, not lost. What is the alert threshold?
- One shard dies -> that slice of users is down. Replica promotes in N seconds.
- The whole region dies -> is there a plan, or do we accept an outage? Say which.

*10x.* "If traffic grew 10x, the first thing to break is (component), because
(measured limit). I would fix it by (change)." Pick the real bottleneck, not a generic
one.
]

#trap[
"It depends" is the most expensive phrase in the interview. It is not wrong --- it is
*empty*. The recovery is to add three words: "It depends on X. Here X is (value), so
I choose (option)." Now it is judgement instead of avoidance.
]

#section[Warm-up]
#tier-header(0)

#ex(5, tier: 0, asked: "warm-up")[
Sort these into *functional* requirements (what it does) and *non-functional*
requirements (how well it does it):
(a) a user can upload a photo, (b) the feed loads in under 400 ms,
(c) a user can follow another user, (d) no post is ever lost,
(e) it works when one data centre is down, (f) a post can be deleted.
]
#sol[
*Functional:* (a) upload a photo, (c) follow a user, (f) delete a post.
These are features. A product manager writes them.

*Non-functional:* (b) 400 ms, (d) durability, (e) availability.
These are properties. They are what actually drives the architecture.

The useful habit: list functional requirements to fix the *scope*, list
non-functional requirements to fix the *shape*. A 400 ms budget forces a cache. A
"never lost" rule forces replication and acknowledgements. Neither is visible in the
feature list.
]
#ans[Functional: a, c, f. Non-functional: b, d, e.]

#ex(6, tier: 0, asked: "warm-up")[
You are 22 minutes into a 45-minute interview and you have finished steps 1 to 4.
You have not drawn anything. How do you spend the remaining 23 minutes?
]
#sol[
You are 2 minutes behind. Do not try to win them back by rushing --- cut instead.

- Minutes 22--31 (9 min): *draw*. This is non-negotiable; it is the artefact everything
  else hangs on.
- Minutes 31--40 (9 min): *one* deep dive, not two. Say out loud: "there are two hard
  parts here, the hot key and the fan-out. I will do the hot key properly; ask me about
  fan-out if you want it."
- Minutes 40--45 (5 min): trade-offs, failure modes, 10x. Never cut this. It is where
  the Judgement tick lives and it is the last thing the interviewer hears.

The thing you cut is the *second* deep dive, because depth on one topic scores
higher than shallowness on two.
]

#ex(7, tier: 0, asked: "warm-up")[
A candidate is asked to design a photo-sharing app. In minute 3 they say:
"First let me design the login system with OAuth and refresh tokens."
What has gone wrong, and what should they say instead?
]
#sol[
*What went wrong:* they picked a sub-problem that (i) the interviewer did not ask
for, (ii) every app has, so it shows nothing specific, and (iii) will eat ten minutes.
This is *scope drift*, and it is the number one silent killer.

*What to say instead:*
"Authentication is a solved problem and every service has it, so I will assume there
is an existing identity service that gives me a verified `userId` on each request. I
will spend my time on the parts specific to photo sharing: upload, storage, and feed
generation. Tell me if you would rather I design auth."

That sentence does three things: it shows you know what auth involves, it hands the
choice back to the interviewer, and it buys back ten minutes.
]

#ex(8, tier: 0, asked: "warm-up")[
Which of these is a *hot key* problem?
#opts[a shard holding 10 TB][one product getting 40% of all reads][a slow SQL query][a full disk]
]
#sol[
(b). A hot key is when the *traffic* to one key is far above the average, so the one
shard that owns that key is overloaded while the other shards idle. Adding shards does
not help --- the key still lives on exactly one of them.

(a) is a capacity problem: rebalance or add shards, and it goes away.
(c) is a query problem: add an index or rewrite it.
(d) is an operations problem: delete, archive, or grow the volume.

The fix for a hot key is different from all three: replicate the hot key to many
nodes and read from any of them, or put it behind a cache, or split the one key into
$k$ sub-keys and sum them.
]
#ans[(b)]

#ex(9, tier: 0, asked: "warm-up")[
Turn this vague requirement into a number you can design against:
"The feed should feel fast."
]
#sol[
"Fast" is not designable. Convert it into a *percentile budget*:

"p99 latency of `GET /v1/feed` under 400 ms, measured at the load balancer,
for a cold client on 4G."

Four things make it usable:
+ *Which operation.* Feed read, not upload.
+ *Which percentile.* p99, not average. Average hides the 1% of users who wait
  4 seconds; those are the users who uninstall.
+ *The number.* 400 ms.
+ *Where measured.* At the load balancer, so it excludes the user's phone network but
  includes all of your own work.

Now it drives design: 400 ms total, minus ~80 ms of round trip, leaves ~320 ms of
server budget. A single database query that takes 250 ms no longer fits, so you know
you need a cache before you have drawn anything.
]

#practice(tier: 0, time: "12 min")[
+ Write four clarifying questions for "design a system to book badminton courts at a
  sports complex". For each, say what the answer changes.
+ A service has 800,000 daily users, each doing 12 actions per day. Find requests per
  day, average QPS, and peak QPS at 3x.
+ Write three endpoints for a service that lets a user shorten a URL and follow it.
+ Give three non-functional requirements for a school report-card portal, each with a
  number attached.
+ A candidate finishes all seven steps in 30 minutes and then stops talking. What
  should they do with the remaining 15 minutes? Give two options.
]

#key[
*1.* (i) How many courts and how far ahead can you book? --- decides whether the whole
availability grid fits in memory. (ii) Can two people book the same slot? --- decides
whether you need a database uniqueness constraint or a full locking scheme.
(iii) Is payment taken at booking? --- decides whether you need idempotency and a
refund path. (iv) Do bookings repeat weekly? --- a recurring booking is a completely
different data model (rule rows, not slot rows).

*2.* $800{,}000 times 12 = 9{,}600{,}000$ per day. $9{,}600{,}000 \/ 86{,}400 = 111.1$ QPS
average. Peak $= 111.1 times 3 = 333$ QPS. This is small: two app servers and one
database will do.

*3.* `POST /v1/links {longUrl, customAlias?} -> 201 {shortCode}`;
`GET /{shortCode} -> 301 Location: <longUrl>`;
`GET /v1/links/{shortCode}/stats -> 200 {clicks, createdAt}`.
The redirect is a bare path, not `/v1/`, because it must be short --- worth saying.

*4.* p99 page load under 1.5 s on a 3G connection; results published within 5 minutes
of the teacher pressing publish; zero marks lost --- every write is durable before the
teacher sees "saved".

*5.* Option A: offer a second deep dive --- "I have time; shall I take the fan-out
problem properly?" Option B: go back and strengthen the weakest step --- usually the
numbers. Do *not* sit in silence, and do not invent new features.
]

#section[Tier 1 — the seven steps on a low-level design]
#tier-header(1)

In an LLD round there are no servers. But the seven steps still apply --- they just
mean smaller things.

#table(columns: (auto, 1fr, 1fr),
  align: (left, left, left),
  [*Step*], [*In HLD it means*], [*In LLD it means*],
  [1 Clarify], [which features, which scale], [which use cases, which rules vary],
  [2 Estimate], [QPS, storage, bandwidth], [how many objects, which lookups must be $O(1)$],
  [3 API], [HTTP endpoints], [the public methods of the main class],
  [4 Data model], [tables and keys], [classes, fields, and the maps that index them],
  [5 Draw], [architecture boxes], [a class picture: owns, uses, implements],
  [6 Deep dive], [the hot key or fan-out], [the rule that changes most often],
  [7 Trade-offs], [CAP, cost], [inheritance vs composition; where to put the logic],
)

#ex(10, tier: 1, asked: "Infosys · pattern")[
*Design the lending desk of a college library.* A member borrows a physical book and
returns it. Late returns are fined. Run all seven steps and produce working code.
]
#sol[
*Step 1 --- Clarify (what I asked, and what the answer changed).*

#table(columns: (1fr, 1fr),
  [*Question*], [*Answer, and what it decided*],
  [Two members want "Operating Systems". Is that one thing or two?],
    [Two. A library owns several physical copies of one title. So I need *two*
     classes: `Title` (the work) and `Copy` (the barcode on the shelf). This single
     answer is the whole design.],
  [Do all members get the same loan period?],
    [No --- students 14 days, staff 30 days, and it may change next year. So the rule
     must be swappable, not an `if` inside the desk.],
  [How is the fine computed?],
    [Rupees 2 per day, capped at Rupees 100. The cap and the rate change per library, so this is
     also a swappable rule.],
  [Reservations, renewals, e-books?],
    [Out of scope --- I said so and the interviewer agreed.],
)

*Step 2 --- Estimate (the LLD version).*
A college library: about 40,000 copies, 6,000 members, roughly 300 issues a day.
Everything fits in memory easily. What matters is which lookups must be instant:
"is barcode BC-1 on loan?" happens on every return, so that must be a hash map
lookup, not a scan of all loans. That one sentence is the whole estimation step here,
and it directly creates the `openLoanByBarcode` map below.

*Step 3 --- API (public methods).*
#code(lang: "text", caption: "The only four methods the outside world needs")[
```text
addCopy(Copy c)
issue(barcode, member, today)      -> Loan       (throws if not allowed)
giveBack(barcode, today)           -> fine in paise
openLoanCount(member)              -> int        (internal helper)
```
]
Fines are in *paise* (integer), never in rupees as a `double`. Money in floating point
is a classic rejection.

*Step 4 --- Data model (classes and the maps that index them).*

#diagram(height: 4.6cm, caption: "The class picture. Solid = owns/uses, dashed = implements.")[
  #dnode(0pt, 0pt, 78pt, 26pt, "Title")
  #dnode(0pt, 44pt, 78pt, 26pt, "Copy")
  #dnode(0pt, 92pt, 78pt, 26pt, "Member")

  #dnode(150pt, 44pt, 86pt, 30pt, "LendingDesk", fill: rgb("#dde8f0"))
  #dnode(150pt, 0pt, 86pt, 26pt, "Loan")

  #dnode(280pt, 0pt, 84pt, 26pt, "LoanPolicy")
  #dnode(280pt, 40pt, 84pt, 26pt, "FineRule")

  #dnode(390pt, 0pt, 84pt, 22pt, "StudentPolicy", fill: rgb("#f7f7f5"))
  #dnode(390pt, 26pt, 84pt, 22pt, "StaffPolicy", fill: rgb("#f7f7f5"))
  #dnode(390pt, 62pt, 84pt, 22pt, "FlatPerDayFine", fill: rgb("#f7f7f5"))

  #darrow(78pt, 50pt, 150pt, 55pt)
  #darrow(78pt, 13pt, 150pt, 10pt, label: "of")
  #darrow(78pt, 98pt, 150pt, 70pt)
  #darrow(193pt, 44pt, 193pt, 26pt, label: "creates")
  #darrow(236pt, 52pt, 280pt, 20pt, label: "uses")
  #darrow(236pt, 62pt, 280pt, 56pt, label: "uses")
  #darrow(390pt, 10pt, 364pt, 10pt, dashed: true)
  #darrow(390pt, 34pt, 364pt, 14pt, dashed: true)
  #darrow(390pt, 72pt, 364pt, 58pt, dashed: true)

  #place(dx: 0pt, dy: 126pt)[#text(size: 8pt, fill: muted)[One `Title`, many `Copy`. `LendingDesk` holds the maps and owns nothing else.]]
]

*Step 5 --- The code.* This runs as written with `node`.

#code(lang: "js", caption: "Entities: the Title/Copy split is the key idea")[
```js
const CopyStatus = Object.freeze({
  ON_SHELF: "ON_SHELF", ON_LOAN: "ON_LOAN", LOST: "LOST", REPAIR: "REPAIR",
});
const Tier = Object.freeze({ STUDENT: "STUDENT", STAFF: "STAFF" });

class Title {                       // the WORK: "Operating Systems"
  constructor(isbn, name, author) {
    this.isbn = isbn; this.name = name; this.author = author;
  }
}

class Copy {                        // the PHYSICAL BOOK: one barcode each
  constructor(barcode, title) {
    this.barcode = barcode; this.title = title;
    this.status = CopyStatus.ON_SHELF;
  }
}

class Member {
  constructor(memberId, name, tier) {
    this.memberId = memberId; this.name = name; this.tier = tier;
  }
}

class Loan {
  constructor(loanId, copy, member, issuedOnDay, dueOnDay) {
    this.loanId = loanId; this.copy = copy; this.member = member;
    this.issuedOnDay = issuedOnDay; this.dueOnDay = dueOnDay;
    this.returnedOnDay = null;      // null while the loan is open
  }
  get isOpen() { return this.returnedOnDay === null; }
}
```
]

#note[
Dates here are plain day numbers (day 0, day 14) so the example stays about the design
and not about time zones. In real code use a date library, and store the due date as a
UTC instant, because a library that opens branches in two countries will otherwise
disagree with itself about when "tomorrow" is.
]

*Step 6 --- Deep dive: the rule that changes most often.*
Loan length and fine rate change every year and differ per library. Putting them in
`if` statements inside `LendingDesk` means editing the desk whenever a rule changes.
Putting each rule in its own small object means *adding* a class instead of editing a
tested one. That is the Strategy pattern, and this is the honest reason to use it.

#code(lang: "js", caption: "Two rules, four tiny classes")[
```js
class StudentPolicy { get loanDays() { return 14; } get maxOpenLoans() { return 3; } }
class StaffPolicy   { get loanDays() { return 30; } get maxOpenLoans() { return 10; } }

class FlatPerDayFine {
  constructor(perDayPaise, capPaise) {
    this.perDayPaise = perDayPaise; this.capPaise = capPaise;
  }
  fineInPaise(daysLate) {
    if (daysLate <= 0) return 0;                        // on time or early
    return Math.min(this.capPaise, this.perDayPaise * daysLate);  // cap applied last
  }
}

class LendingError extends Error {}
```
]

#note[
*A language point you will be asked about.* JavaScript has no `interface` keyword.
`LendingDesk` simply calls `policy.loanDays`, and any object with that property works
--- this is duck typing, and it gives you the same swappability with less ceremony.

But a service-company interviewer will often ask this question in Java vocabulary.
*What they expect to hear:* "`LoanPolicy` is an interface with `int loanDays()` and
`int maxOpenLoans()`; `StudentPolicy` and `StaffPolicy` implement it; `LendingDesk`
depends on the interface, not the concrete class." Say that sentence in Java terms
when asked in Java terms, then add: "in JavaScript the same design needs no interface
declaration, because the call site only requires the method to exist."
]

#code(lang: "js", caption: "The desk: every map exists to make one lookup O(1)")[
```js
class LendingDesk {
  constructor(fineRule) {
    this.fineRule = fineRule;
    this.copies = new Map();            // barcode  -> Copy
    this.openLoanByBarcode = new Map(); // barcode  -> Loan   (O(1) return)
    this.loansByMember = new Map();     // memberId -> Loan[]
    this.policies = new Map([
      [Tier.STUDENT, new StudentPolicy()],
      [Tier.STAFF,   new StaffPolicy()],
    ]);
    this.seq = 0;
  }

  addCopy(copy) { this.copies.set(copy.barcode, copy); }

  openLoanCount(member) {
    const loans = this.loansByMember.get(member.memberId) ?? [];
    return loans.filter(l => l.isOpen).length;
  }

  issue(barcode, member, todayDay) {
    const copy = this.copies.get(barcode);
    if (!copy) throw new LendingError(`no such copy: ${barcode}`);
    if (copy.status !== CopyStatus.ON_SHELF) throw new LendingError("copy not on shelf");
    const policy = this.policies.get(member.tier);
    if (this.openLoanCount(member) >= policy.maxOpenLoans)
      throw new LendingError("loan limit hit");

    const loan = new Loan(`L${++this.seq}`, copy, member,
                          todayDay, todayDay + policy.loanDays);
    copy.status = CopyStatus.ON_LOAN;
    this.openLoanByBarcode.set(barcode, loan);
    if (!this.loansByMember.has(member.memberId))
      this.loansByMember.set(member.memberId, []);
    this.loansByMember.get(member.memberId).push(loan);
    return loan;
  }

  giveBack(barcode, todayDay) {
    const loan = this.openLoanByBarcode.get(barcode);
    if (!loan) throw new LendingError("copy was not on loan");
    this.openLoanByBarcode.delete(barcode);
    loan.returnedOnDay = todayDay;
    loan.copy.status = CopyStatus.ON_SHELF;
    return this.fineRule.fineInPaise(todayDay - loan.dueOnDay);
  }
}
```
]

#code(lang: "js", caption: "The test run")[
```js
const desk = new LendingDesk(new FlatPerDayFine(200, 10000)); // Rs 2/day, cap Rs 100
const t = new Title("978-1", "Operating Systems", "Rao");
const c1 = new Copy("BC-1", t), c2 = new Copy("BC-2", t);
desk.addCopy(c1); desk.addCopy(c2);

const riya = new Member("M1", "Riya", Tier.STUDENT);
const l = desk.issue("BC-1", riya, 0);
console.log(`issued ${l.loanId}, due on day ${l.dueOnDay}`);
console.log(`copy status = ${c1.status}`);

try { desk.issue("BC-1", riya, 0); }
catch (e) { console.log(`second issue blocked: ${e.message}`); }

console.log(`fine on time       = ${desk.giveBack("BC-1", 14)}`);
desk.issue("BC-2", riya, 0);
console.log(`fine 5 days late   = ${desk.giveBack("BC-2", 19)}`);
desk.issue("BC-2", riya, 0);
console.log(`fine 200 days late = ${desk.giveBack("BC-2", 214)}`);
```
]

Run it with `node` and this is the actual output:

#code(lang: "text", caption: "Measured output")[
```text
issued L1, due on day 14
copy status = ON_LOAN
second issue blocked: copy not on shelf
fine on time       = 0
fine 5 days late   = 1000
fine 200 days late = 10000
```
]

Read the last three lines. On time: 0 paise. Five days late: $200 times 5 = 1000$ paise,
which is Rupees 10. Two hundred days late: $200 times 200 = 40{,}000$ paise, but the cap
is 10,000 paise, so Rupees 100. The cap works.

#trap[
*Why `Map` and not a plain object for `copies`?* A plain object turns every key into a
string, so a numeric barcode `1234` and the string `"1234"` become the same entry, and
keys like `constructor` or `toString` collide with things already on the object. `Map`
keeps the key's type, keeps insertion order, and has a real `.size`. In an LLD round,
say "`Map` because the keys are data, not property names." It is a one-line answer that
shows you know the difference.
]

*Step 7 --- Trade-offs, decided.*

#table(columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  [*Choice*], [*The two sides*], [*Decision*],
  [Fine logic: inside `Loan` or in a separate `FineRule`?],
    [Inside `Loan` is fewer classes and easier to read. Separate means one more
     interface but the rule can change without touching the entity.],
    [*Separate.* The rule changes yearly; the entity does not. Keep data and
     changing policy apart.],
  [Tier behaviour: subclass `Member` or give `Member` a `tier` field?],
    [A `StudentMember` subclass reads naturally. But a student who becomes staff
     would need a new object and every reference updated.],
    [*Field plus policy map.* Composition survives the change of tier;
     inheritance does not.],
  [`status` on `Copy`, or derive it from the loans map?],
    [A field can drift out of sync with the map --- two sources of truth. Deriving is
     always correct but costs a lookup.],
    [*Keep the field, but only `LendingDesk` may write it.* One writer means it
     cannot drift. If this were multi-threaded I would derive instead.],
  [Money as rupees in a float, or paise in an integer?],
    [Floats are convenient. In JavaScript every number *is* a float, and
     `0.1 + 0.2` prints `0.30000000000000004`.],
    [*Integer paise.* Never floating point for money. No exceptions.],
)

*What breaks at 10x?* Nothing --- 400,000 copies still fit in memory. What breaks is
*multi-desk*: two librarians on two machines both calling `issue("BC-1", ...)`.
Both read `ON_SHELF`, both succeed, one book leaves twice. The fix moves the design
out of memory: make `openLoanByBarcode` a database table with `barcode` as a unique
key on open loans, so the second insert fails. That is the bridge from LLD to HLD,
and it is a very good sentence to end on.
]

#trap[
The most common wrong answer to this question is a single `Book` class holding both
the title and the barcode. It seems fine until the interviewer says "the library has
five copies of that book". Then every field is wrong at once. When a question mentions
a real-world object, always ask: *is this one thing, or a type of thing and its
instances?*
]

#ex(11, tier: 1, asked: "TCS NQT · pattern")[
Run only *step 1* for: "Design a parking lot." Give five clarifying questions with
the design consequence of each.
]
#sol[
+ *"How many floors and how many spot sizes?"* --- one size means a single counter is
  enough. Three sizes (bike, car, van) means a counter per size per floor, and the
  "find a spot" method becomes a search, not a decrement.
+ *"Is the fee by hour, by slab, or flat?"* --- decides whether `FeeStrategy` needs the
  entry time only, or entry plus exit plus a slab table. It is the rule most likely to
  vary, so it becomes an interface.
+ *"Can a van occupy two car spots?"* --- if yes, allocation is no longer "find one free
  spot"; it is "find two adjacent free spots", which is a different algorithm and needs
  spots to know their neighbours.
+ *"What happens if the ticket is lost?"* --- forces a lost-ticket flat fee and a lookup
  by number plate, which means an index on plate that you would otherwise not build.
+ *"Do we need to show live free-spot counts on a display board?"* --- if yes, a counter
  per floor per size must be kept in sync with allocation, and now you have a
  concurrency question at the entry gates.

Then: "I will leave out payments, monthly passes, and reservations."
]

#ex(12, tier: 1, asked: "Capgemini · pattern")[
Here is a class. Name three things wrong with it *for an interview*, and fix each.
#code(lang: "js", caption: "Submitted by a candidate")[
```js
class Order {
  constructor(id, items, total, status) {
    this.id = id; this.items = items; this.total = total; this.status = status;
  }
  saveToDatabase() { /* SQL here */ }
  sendEmail()      { /* SMTP here */ }
  calculateTotal(customerType) {
    if (customerType === "GOLD")        return this.total * 0.8;
    else if (customerType === "SILVER") return this.total * 0.9;
    else                                return this.total;
  }
}
```
]
]
#sol[
*Problem 1 --- it does three unrelated jobs.* `Order` holds data, talks to a database,
and sends email. Three reasons to change one class. If the mail provider changes, you
edit `Order`. If the schema changes, you edit `Order`.
*Fix:* keep `Order` as data plus order rules. Move persistence to `OrderRepository`,
move mail to `NotificationService`.

*Problem 2 --- the discount is a chain of `if`s on a string.* Adding a PLATINUM tier
means editing this method, re-testing it, and re-deploying it. A typo in the string
silently gives *no* discount instead of failing loudly.
*Fix:* one small class per rule, chosen from a map.

*Problem 3 --- money in a floating-point number, in a field anyone can overwrite.*
JavaScript numbers are all doubles, so rupee amounts accumulate tiny errors; and
`order.total = -5` is legal from anywhere in the program.
*Fix:* integer paise in a `#private` field, computed once in the constructor.

#code(lang: "js", caption: "Both fixes together")[
```js
class PercentOffPolicy {
  constructor(percentOff) { this.percentOff = percentOff; }
  applyToPaise(p) { return p - Math.floor((p * this.percentOff) / 100); }
}

const DISCOUNTS = new Map([              // adding PLATINUM adds a row, not an if
  ["GOLD",   new PercentOffPolicy(20)],
  ["SILVER", new PercentOffPolicy(10)],
  ["NONE",   new PercentOffPolicy(0)],
]);

class Order {
  #totalPaise;                            // truly private, not just a naming habit
  constructor(id, itemIds, subtotalPaise, discount) {
    this.id = id; this.itemIds = itemIds;
    this.#totalPaise = discount.applyToPaise(subtotalPaise);
  }
  get totalPaise() { return this.#totalPaise; }
}

console.log("0.1 + 0.2       =", 0.1 + 0.2);
console.log("equals 0.3?     =", 0.1 + 0.2 === 0.3);
const o = new Order("o1", ["i1"], 99995, DISCOUNTS.get("GOLD"));
console.log("GOLD on 99995 p =", o.totalPaise, "paise");
console.log("visible fields  =", Object.keys(o));
```
]

#code(lang: "text", caption: "Measured output")[
```text
0.1 + 0.2       = 0.30000000000000004
equals 0.3?     = false
GOLD on 99995 p = 79996 paise
visible fields  = [ 'id', 'itemIds' ]
```
]

Look at line 2. `0.1 + 0.2 === 0.3` is *false*. That is not a JavaScript quirk to
laugh at --- it is why Rupees 999.95 becomes Rupees 999.9499999999999 after enough
arithmetic, and why a reconciliation report ends up one paisa out. Integers only.
Line 4 shows `#totalPaise` really is invisible from outside.

*Say this line:* "The test for whether a rule belongs in its own class is: does it
change on a different schedule from the rest of the class? Discounts change every
festival season. The order's fields do not."
]

#ex(13, tier: 1, asked: "Cognizant · pattern")[
Run steps 3 and 4 (API and data model) for a hostel room allocation system:
students apply, a warden allocates, a student can swap with another student if both
agree.
]
#sol[
*Step 3 --- API.*
#code(lang: "text", caption: "Five endpoints")[
```text
POST /v1/applications
  body { studentId, preferredBlock, roommatePrefStudentId? }
  resp 201 { applicationId }

POST /v1/allocations
  body { applicationId, roomId, bedNo }
  resp 201 { allocationId }
  note warden only; fails if that bed is already allocated

GET  /v1/students/{studentId}/allocation
  resp 200 { roomId, bedNo, block, allocatedAt }

POST /v1/swaps
  body { fromAllocationId, toAllocationId }
  resp 201 { swapId, status: "PENDING_OTHER" }

POST /v1/swaps/{swapId}/accept
  resp 200 { status: "DONE" }
  note both sides must accept; this is the second accept
```
]
The swap is *two* calls, not one, because it needs two people's consent. Modelling a
two-party agreement as a single endpoint is a common mistake --- there is no moment at
which both students are making the same request.

*Step 4 --- Data model.*
#code(lang: "text", caption: "Four tables; note the unique constraint")[
```text
rooms(room_id PK, block, floor, capacity)

beds(bed_id PK, room_id, bed_no)
    UNIQUE (room_id, bed_no)

allocations(allocation_id PK, student_id, bed_id, allocated_at, released_at)
    UNIQUE (bed_id) WHERE released_at IS NULL   -- one live occupant per bed
    UNIQUE (student_id) WHERE released_at IS NULL -- one live bed per student

swaps(swap_id PK, from_alloc_id, to_alloc_id, state, created_at)
    state in (PENDING_OTHER, DONE, CANCELLED, EXPIRED)
```
]

The two partial unique constraints are the whole design. They mean that even if two
wardens click "allocate" at the same instant, the database refuses the second one.
Without them you need a lock, a queue, or hope.

*Why `released_at` instead of deleting the row?* Because next year someone will ask
"who lived in 3B last year?". Soft-release keeps history at the cost of every query
carrying `WHERE released_at IS NULL`. That is a trade I would take here; for a
high-write table I would not, and would move old rows to an archive table instead.
]

#practice(tier: 1, time: "35 min")[
+ Run all seven steps for *a vending machine*. You must produce: the clarifying
  questions, the public methods, the class list, a state list, and one trade-off
  decided.
+ For a *movie ticket booking* LLD, name the one rule most likely to change and put it
  behind an interface. Write the interface and two implementations.
+ A candidate models a chess game with a single `Board` class containing a
  `move(int,int,int,int)` method holding all the rules for all six piece types. Give
  two concrete problems and the fix.
+ Write the data model for a *split-the-bill* app: a group, members, expenses, and who
  owes whom. State your primary keys.
+ A class has a method `process(String type)` with a 7-branch `if/else` on `type`.
  Give the two-sentence argument for replacing it, and the one situation where you
  would leave it alone.
]

#key[
*1.* Clarify: how many item slots; does it give change and in which coins; can an item
be reserved while paying; what happens if payment succeeds and dispensing fails.
Methods: `insertCoin`, `selectItem`, `dispense`, `refund`, `restock`. Classes:
`Machine`, `Slot`, `Item`, `CoinBox`, `MachineState`. States: `IDLE`,
`ITEM_SELECTED`, `HAS_MONEY`, `DISPENSING`, `OUT_OF_SERVICE`. Trade-off: one big
`switch` on state versus a `State` object per state --- choose the State object, because
each state then owns exactly the transitions that are legal from it, and an illegal
transition becomes impossible rather than merely untested.

*2.* Pricing. One method, `priceInPaise(show, seat)`, implemented by
`WeekdayFlatPrice` and `WeekendPremiumPrice`, chosen from a `Map` keyed by day type.
Seat class (gold / silver) is a second axis: either compose two rule objects or pass
the seat into the one rule, as shown.

*3.* (i) Adding a new piece means editing `Board`, which is also responsible for
occupancy and check detection --- so a bishop bug can break the king. (ii) `move` cannot
be unit-tested per piece. Fix: one small class per piece, each with
`canMove(board, from, to)`; `Board` only checks occupancy, turn order, and whether the
king is left in check. (In Java vocabulary the interviewer will call the shared shape
an `interface Piece`; in JavaScript it is just the method every piece class defines.)

*4.* `groups(group_id PK, name)`; `members(group_id, user_id, PK(group_id, user_id))`;
`expenses(expense_id PK, group_id, payer_id, amount_paise, description, created_at)`;
`expense_shares(expense_id, user_id, share_paise, PK(expense_id, user_id))`.
Balances are computed by summing shares, not stored --- a stored balance is a second
source of truth that drifts.

*5.* Replace it when the branches change at different times or are added by different
people; each branch becomes a class and adding an eighth type stops touching tested
code. Leave it alone when the set of types is fixed by an external standard and will
never grow (HTTP methods, days of the week) --- there, seven classes is more code for
zero flexibility you will ever use.
]

#section[Tier 2 — the seven steps on one real service]
#tier-header(2)

#ex(14, tier: 2, asked: "Shopee · pattern")[
*Design a coupon redemption service* for a South-East Asian shopping app. During
checkout the app asks "is this coupon valid for this cart?" and, if the user confirms,
"redeem it". Run all seven steps.
]
#sol[
*Step 1 --- Clarify.*

#table(columns: (1fr, 1fr),
  [*Question*], [*Answer, and what it decided*],
  [How many buyers per day, and how many use a coupon?],
    [8 million daily buyers; about 15% apply a coupon. That is 1.2 M redemptions a
     day --- small. The *validation* traffic is the real load.],
  [How many times is a coupon checked before it is redeemed?],
    [About 10 --- the app re-validates on every cart change. So validation is 12 M/day.
     This is the number that sizes the service.],
  [Can one coupon be used twice by the same user?],
    [No. Per-user limit, usually 1. This is the hard part of the whole design.],
  [Is there a global cap, like "first 10,000 users"?],
    [Yes. That is a hot counter and a flash-sale problem.],
  [Is a slightly stale "still available" answer acceptable?],
    [For *validation*, yes --- it is only a preview. For *redemption*, no: it must be
     exact. This split is the key architectural insight.],
)

*Out of scope:* creating coupons in the admin console, payments, and the cart service
itself.

*Step 2 --- Estimate. Every division shown.*

#formulas(title: "The arithmetic")[
*Redemptions per day.*
$ 8{,}000{,}000 times 0.15 = 1{,}200{,}000 "redemptions/day" $

*Average redemption QPS.*
$ 1{,}200{,}000 / 86{,}400 = 13.9 approx 14 "QPS" $

*Peak redemption QPS.* Checkout is concentrated: about 20% of a day's orders land in
the busiest hour.
$ 1{,}200{,}000 times 0.20 = 240{,}000 "in that hour" $
$ 240{,}000 / 3{,}600 = 66.7 approx 67 "QPS" $

*Validation traffic — 10 checks per redemption.*
$ 1{,}200{,}000 times 10 = 12{,}000{,}000 "validations/day" $
$ 12{,}000{,}000 / 86{,}400 = 138.9 approx 139 "QPS average" $
$ (12{,}000{,}000 times 0.20) / 3{,}600 = 2{,}400{,}000 / 3{,}600 = 666.7 approx 667 "QPS peak" $

*Storage.* A redemption row: coupon id 16 B, user id 8 B, order id 16 B, timestamp
8 B, amount 8 B, status 1 B, plus index and row overhead --- call it 120 B.
$ 1{,}200{,}000 times 120 "B" = 144{,}000{,}000 "B" = 144 "MB/day" $
$ 144 "MB" times 365 = 52{,}560 "MB" = 52.6 "GB/year" $

*Coupon definitions.* 200,000 live coupons $times$ 300 B $= 60$ MB. That is the whole
catalogue --- it fits in memory on every server, which is a very useful fact.
]

*Reading the numbers.* 667 QPS at peak is *small*. This is not a distributed systems
problem; it is a correctness problem. 52.6 GB a year fits on one database for many
years. Say this out loud --- recognising that a system is small is itself a scored
signal, because it stops you from over-engineering.

*Step 3 --- API.*
#code(lang: "text", caption: "Three endpoints; note the reservation")[
```text
POST /v1/coupons/validate
  body { userId, couponCode, cartTotalPaise, itemIds[] }
  resp 200 { valid: true, discountPaise: 5000, reason: null }
       200 { valid: false, discountPaise: 0, reason: "ALREADY_USED" }
  note  read-only, cacheable, may be a few seconds stale, no side effect

POST /v1/coupons/reserve
  body { userId, couponCode, orderId }
  header Idempotency-Key: <orderId>
  resp 201 { reservationId, expiresAt }
       409 { reason: "EXHAUSTED" | "ALREADY_USED" }
  note  exact, takes one unit from the global cap, held for 10 minutes

POST /v1/coupons/commit
  body { reservationId, paymentId }
  resp 200 { redemptionId }
  note  called after payment succeeds; converts reservation to redemption
```
]

*Why three calls and not one?* Because payment sits between "the user chose the
coupon" and "the order exists". If you decrement the global cap at validate time,
every browsing user burns a coupon. If you decrement only after payment, two users
can both pay for the last unit. A short reservation solves both: it is taken at a
moment the user has committed, and it expires by itself if payment fails.

*Step 4 --- Data model.*
#code(lang: "text", caption: "Four tables; the unique key is the whole correctness story")[
```text
coupons(coupon_code PK, kind, value_paise, min_cart_paise,
        starts_at, ends_at, global_cap, per_user_cap, status)

coupon_counters(coupon_code, shard_no, used_count,
                PK (coupon_code, shard_no))      -- see deep dive

reservations(reservation_id PK, coupon_code, user_id, order_id,
             expires_at, state)
        UNIQUE (coupon_code, user_id)  WHERE state IN ('HELD','COMMITTED')
        index (expires_at) WHERE state = 'HELD'   -- the sweeper reads this

redemptions(redemption_id PK, coupon_code, user_id, order_id,
            amount_paise, redeemed_at)
        UNIQUE (coupon_code, user_id)             -- per-user cap = 1, enforced
        UNIQUE (order_id, coupon_code)            -- retry safety
```
]

Partition key: `coupon_code`. Every single query names a coupon, so every query hits
one shard. The price of this choice is that one popular coupon puts all its load on
one shard --- which is exactly the deep dive.

*Step 5 --- Draw it.*

#diagram(height: 5.2cm, caption: "Validate is cached and cheap. Reserve and commit take the exact path.")[
  #dnode(0pt, 40pt, 54pt, 30pt, "App")
  #dnode(74pt, 40pt, 56pt, 30pt, "Gateway")
  #dnode(150pt, 40pt, 74pt, 30pt, "Coupon svc", fill: rgb("#dde8f0"))

  #dnode(244pt, 0pt, 80pt, 26pt, "Local cache\n(60 MB rules)", fill: rgb("#f0ece2"))
  #dnode(244pt, 40pt, 80pt, 30pt, "Redis\ncounters", fill: rgb("#f0ece2"))
  #dnode(244pt, 84pt, 80pt, 30pt, "Postgres\n(coupons)")

  #dnode(360pt, 84pt, 84pt, 30pt, "Sweeper job", fill: rgb("#f7f7f5"))
  #dnode(360pt, 40pt, 84pt, 30pt, "Payment svc", fill: rgb("#f7f7f5"))

  #darrow(54pt, 55pt, 74pt, 55pt)
  #darrow(130pt, 55pt, 150pt, 55pt)
  #darrow(224pt, 46pt, 244pt, 20pt, label: "validate")
  #darrow(224pt, 55pt, 244pt, 55pt, label: "reserve")
  #darrow(224pt, 64pt, 244pt, 95pt, label: "commit")
  #darrow(324pt, 55pt, 360pt, 55pt, dashed: true, label: "after pay")
  #darrow(360pt, 99pt, 324pt, 99pt, label: "expire HELD")

  #place(dx: 0pt, dy: 120pt)[#text(size: 8pt, fill: muted)[Validate never touches Postgres. Only reserve and commit do --- and they are 67 QPS, not 667.]]
]

*Step 6 --- Deep dive 1: the global cap under a flash sale.*

The cap is "first 10,000 users only". Naive version:
```
SELECT used_count FROM coupon_counters WHERE coupon_code = 'FLASH50';
if (used_count < 10000) UPDATE ... SET used_count = used_count + 1;
```
Two requests read 9,999 at the same moment. Both pass the check. Both increment.
Now 10,001 people have the coupon. This is a *lost update* and it will happen.

*Fix 1 --- make the check and the increment one atomic statement.*
```
UPDATE coupon_counters SET used_count = used_count + 1
 WHERE coupon_code = 'FLASH50' AND used_count < 10000;
-- rows affected = 1 -> you got it.  rows affected = 0 -> sold out.
```
The database evaluates the condition and the write under one row lock. No race. This
alone fixes correctness.

*Fix 2 --- the row is now a hot key.* Every request for FLASH50 queues behind one row
lock. If each update holds the lock for 1 ms, that row can serve at most 1,000
updates per second, and a flash sale can deliver far more than that. So *split the
counter*: give the coupon 10 shards, each with a cap of 1,000.

#code(lang: "text", caption: "Sharded counter — pick a shard from the user id")[
```text
shard = hash(userId) % 10
UPDATE coupon_counters SET used_count = used_count + 1
 WHERE coupon_code = 'FLASH50' AND shard_no = :shard AND used_count < 1000;
```
]
Ten independent rows, ten independent locks, roughly ten times the throughput.

*The cost, stated honestly:* the shards drain unevenly. If shard 3 fills first, a
user hashing to shard 3 is told "sold out" while units still remain on shard 7. So you
will hand out fewer than 10,000 in practice. *How many fewer?* Do not guess --- measure.

#code(lang: "js", caption: "How many units does sharding strand? Simulate it.")[
```js
const hash32 = (s) => {                 // deterministic 32-bit string hash (FNV-1a)
  let h = 0x811c9dc5;
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return h >>> 0;
};

const CAP = 10000, USERS = 10000;

const run = (shards, retries) => {
  const perShard = CAP / shards;
  const used = new Array(shards).fill(0);
  let granted = 0;
  for (let i = 0; i < USERS; i++) {
    const start = hash32(`u${i}`) % shards;
    for (let k = 0; k <= retries; k++) {          // try neighbours on a miss
      const s = (start + k) % shards;
      if (used[s] < perShard) { used[s]++; granted++; break; }
    }
  }
  return CAP - granted;                            // units nobody could claim
};

for (const shards of [1, 10, 100, 1000]) {
  const row = [0, 1, 2].map(r => `retries=${r}: ${run(shards, r)}`).join("   ");
  console.log(`shards=${String(shards).padStart(4)}  stranded units ->  ${row}`);
}
```
]

#code(lang: "text", caption: "Measured output")[
```text
shards=   1  stranded units ->  retries=0: 0   retries=1: 0   retries=2: 0
shards=  10  stranded units ->  retries=0: 44   retries=1: 29   retries=2: 19
shards= 100  stranded units ->  retries=0: 219  retries=1: 114  retries=2: 78
shards=1000  stranded units ->  retries=0: 1155 retries=1: 729  retries=2: 592
```
]

Read the table carefully, because it contradicts the fear.
- 10 shards strand *44 units out of 10,000* --- 0.44%. That is nothing.
- 1,000 shards strand 1,155 --- 11.6%. That is a real loss.
- Two retries roughly halve the loss at every shard count.

The rule this gives you: *shard just enough.* The stranding cost grows with the number
of shards, so pick the smallest count that clears your throughput need.

*Decision:* 10 shards with 2 retries --- roughly 10x the write throughput for a 0.19%
shortfall. If the cap were small (say 100 units), I would not shard at all: one row
handles 1,000 updates a second, 100 units are gone in a moment anyway, and exactness
matters more than throughput when the prize is tiny.

*Step 6 --- Deep dive 2: the reservation that never gets committed.*

A user reserves, then closes the app. The unit is held forever.
Two ways to release it:

#approach(1, "A background sweeper job", verdict: "chosen")
Every 30 seconds, run
`UPDATE reservations SET state='EXPIRED' WHERE state='HELD' AND expires_at < now()`
and decrement the matching counter shard. The `index (expires_at) WHERE state='HELD'`
makes this a cheap range scan --- the sweeper only reads rows that are actually due.

#approach(2, "Lazy expiry at read time", verdict: "rejected as the only mechanism")
When someone asks for the coupon, notice any expired holds and release them then.
Costs nothing when idle. But if nobody asks, units stay locked forever --- and the
whole point of a flash sale is that people *are* asking, so the lazy path fires
exactly when you least want extra work in the request.

*Decision: the sweeper, plus lazy expiry as a safety net.* The sweeper is the
guarantee; lazy expiry covers the 30-second window between sweeps. Running both is
safe because the state transition `HELD -> EXPIRED` is idempotent: whoever gets there
second changes zero rows.

*Step 7 --- Trade-offs, failure modes, 10x.*

#table(columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  [*Choice*], [*Both sides*], [*Decision*],
  [Counters in Redis or in Postgres?],
    [Redis: ~100 K ops/s, atomic `DECR`, but a crash can lose the last second of
     writes. Postgres: durable and transactional with the redemption row, but ~10 K
     writes/s per node.],
    [*Postgres.* Peak here is 67 reserve/s --- three orders of magnitude below the
     limit. Durability is worth more than speed we do not need. Redis is used only
     as a read cache.],
  [Validate exact or cached?],
    [Exact means every keystroke in the cart hits the database --- 667 QPS of exact
     reads for an answer that is only a preview. Cached means a user may briefly see
     "valid" for a coupon that just sold out.],
    [*Cached, 5-second TTL.* The reserve call is the source of truth and it returns a
     clean 409. Showing "sorry, just sold out" at checkout is acceptable; melting the
     database to avoid it is not.],
  [Per-user cap in code or as a unique index?],
    [Code is flexible (caps of 2, 3, n). A unique index handles only cap = 1, but it
     cannot be beaten by any race.],
    [*Unique index for cap = 1* (which is 95% of coupons), *plus* a counted check for
     caps above 1. Use the strongest tool that fits the common case.],
)

*Failure modes.*
- *Redis dies.* Validation falls through to Postgres. 667 QPS of simple indexed reads
  is well within one Postgres node. Degraded, not down. Acceptable.
- *Coupon service dies.* Checkout must not die with it. Decision: the cart treats a
  timeout as "no discount available", shows the cart without the coupon, and lets the
  user retry. Never block a purchase because a discount service is slow.
- *Payment succeeds but commit fails.* The reservation stays `HELD`, then expires ---
  the user paid full price and lost the discount. Fix: `commit` is retried from a
  durable outbox written in the same transaction as the payment record, and it is
  idempotent on `reservationId`, so retrying is always safe.
- *Sweeper dies.* Units leak slowly. Alert on `count(state='HELD' AND expires_at <
  now() - 5 min) > 100`.

*At 10x (80 M buyers/day).* Validation goes to 6,670 QPS peak and redemption to
670 QPS. The first thing to break is *not* the database --- it is the single hot coupon
row during a national sale. I would move the counter for campaign coupons only into a
sharded in-memory counter with periodic write-back, and keep everyday coupons exactly
as they are. Two paths, chosen by coupon type, because the shapes of the traffic are
genuinely different.
]

#ex(15, tier: 2, asked: "Grab · pattern")[
Run *step 2 only* for a driver-location service: 200,000 drivers are online, each
sends its position every 4 seconds. Payload is 40 bytes. Locations are kept for
24 hours for dispute resolution.
]
#sol[
*Write QPS.* Every driver sends one ping per 4 seconds, so in any one second, a
quarter of the drivers send.
$ 200{,}000 / 4 = 50{,}000 "writes per second" $

*Bandwidth in.*
$ 50{,}000 times 40 "B" = 2{,}000{,}000 "B/s" = 2 "MB/s" = 16 "Mbps" $
Tiny. The bytes are not the problem; the *operation count* is.

*Pings per day.* Seconds in a day divided by 4, times drivers:
$ 86{,}400 / 4 = 21{,}600 "pings per driver per day" $
$ 200{,}000 times 21{,}600 = 4{,}320{,}000{,}000 "pings/day" $

*Storage for 24 hours.*
$ 4{,}320{,}000{,}000 times 40 "B" = 172{,}800{,}000{,}000 "B" = 172.8 "GB/day" $

*The conclusion you must state.* 50,000 writes per second is far past a single
relational database (roughly 5--20 K writes/s). And 4.3 billion rows a day is not
something you keep in Postgres. So:
+ *Current position* goes in memory (one key per driver, overwritten each ping). That
  is 200,000 keys, about 40 MB --- trivially small, and the write rate is what
  in-memory stores are built for.
+ *The 24-hour history* is a different product with a different shape. Append it to a
  log (Kafka) and land it in a time-series or columnar store, compressed. It is never
  read in the hot path.

Splitting "the latest value" from "the history" is the move. They have the same data
and completely different access patterns, so they get different storage.
]

#ex(16, tier: 2, asked: "Agoda · pattern")[
Run *step 7 only*: you have designed a hotel search that reads from a search index
refreshed from the booking database every 60 seconds. Give the trade-off, two failure
modes, and the 10x answer.
]
#sol[
*The trade-off, named and decided.*
Reading from the search index gives fast, rich queries (filter by price, stars, map
box, free text) that a transactional database cannot serve at that speed. Reading
from the booking database directly gives perfect freshness but every search becomes a
heavy multi-table scan, and search traffic is 100x booking traffic --- it would crush
the database that the actual bookings depend on.

*Decision: search from the index.* The cost is that a room can appear available for up
to 60 seconds after it is taken. That is acceptable *because the booking step
re-checks availability against the real database*, so the worst outcome is a clear
"just taken, here are similar rooms" message rather than a double booking. I would
reduce the 60 seconds to 5 for the top 1% of properties by traffic, where a stale hit
is most likely.

*Failure modes.*
- *The refresh pipeline stalls.* Results silently get older and older. This is
  dangerous precisely because nothing errors. Fix: publish the index's newest
  timestamp as a metric and alert when `now - newest > 5 minutes`. An index that is
  merely stale looks healthy; you must measure staleness directly.
- *The index cluster dies.* Search is the front door of the product, so "no results"
  is close to "site down". Fix: a fallback that serves a cached list of popular hotels
  per city with filters disabled, plus a banner. Degraded, browsable, still bookable.

*At 10x.* The first thing to break is the *refresh*, not the queries. Reads scale by
adding index replicas, which is easy. But the refresh is one pipeline rebuilding the
same documents, and 10x the bookings means 10x the change events into one writer. I
would switch from periodic full refresh to change-data-capture with partial document
updates, so the work is proportional to what changed rather than to catalogue size.
]

#practice(tier: 2, time: "40 min")[
+ Run steps 1 and 2 for *a food-delivery order-tracking service*: 5 million orders a
  day, each order sends 6 status updates, and every customer polls the status every
  5 seconds while waiting (average wait 25 minutes). Find the polling QPS and then
  argue for or against polling.
+ Run step 3 and 4 for *a wallet top-up service*. There must be no possibility of a
  double credit when the client retries.
+ Run step 6 for *a "5 free articles a month" paywall*: the counter must be per user
  per month and must survive the user clearing cookies.
+ For a URL shortener at 50 million redirects a day, compute the peak QPS and decide
  whether the redirect should be served from a cache, a database, or both. Show the
  arithmetic.
+ Give a trade-off, decided, for: "store the user's uploaded image in the database as
  a BLOB, or in object storage with the URL in the database".
]

#key[
*1.* Status writes: $5{,}000{,}000 times 6 = 30{,}000{,}000$/day $= 30{,}000{,}000 \/
86{,}400 = 347$ QPS average; dinner peak, 25% of orders in 2 hours, gives
$(0.25 times 30{,}000{,}000) \/ 7{,}200 = 1{,}042$ QPS. Polling: each waiting customer
polls $25 times 60 \/ 5 = 300$ times, so $5{,}000{,}000 times 300 = 1.5$ billion
polls/day $= 17{,}361$ QPS average, and roughly 52,000 at peak --- *50x the write
traffic, for data that changed 6 times*. Argue against polling: use a push (websocket
or mobile push) for status changes, and keep a slow poll (every 30 s) only as a
reconnect safety net. If you must poll, serve it from a cache with a 3-second TTL and
return `304 Not Modified` with an ETag so the body is not re-sent.

*2.* `POST /v1/wallets/{walletId}/topups` with `Idempotency-Key: <clientUuid>`, body
`{ amountPaise, paymentRef }`, response `201 { topupId, newBalancePaise }`. Tables:
`wallets(wallet_id PK, balance_paise, version)`;
`ledger(entry_id PK, wallet_id, delta_paise, reason, idempotency_key, created_at)` with
`UNIQUE (wallet_id, idempotency_key)`. The unique index is the guarantee: the second
attempt fails the insert, and the handler then returns the *first* attempt's response.
Balance is updated in the same transaction as the ledger insert, never separately.

*3.* Key the counter `(userId, yyyymm)` and store it server-side, so clearing cookies
changes nothing --- that is the point of keying on the user. For logged-out readers you
have no user id; decide explicitly: count by a signed device cookie plus IP, accept
that it is beatable, and cap the loss by making the free allowance small. Reset is
implicit (a new month is a new key), so there is no monthly reset job, and no
midnight thundering herd. Write path: `INSERT ... ON CONFLICT (user_id, yyyymm) DO
UPDATE SET n = counter.n + 1 RETURNING n` --- one atomic statement, no read-then-write
race.

*4.* $50{,}000{,}000 \/ 86{,}400 = 578.7$ QPS average; $times 3 = 1{,}736$ QPS peak.
Both: the cache serves it because a redirect is the same tiny answer for everyone and
must be fast (target under 20 ms); the database is the source of truth and fills the
cache on a miss. A pure cache loses links on restart; a pure database wastes a query
on data that never changes after creation. Cache hit rate will be very high because
link popularity is extremely skewed.

*5.* BLOB in the database: one system, transactional with its row, easy backup --- but
images are 2 MB each, so the database grows 1000x faster than its rows, backups get
slow, and every read of the image occupies a database connection. Object storage:
cheap, effectively unlimited, and served by the CDN without touching your servers ---
but you now have two systems that can disagree (a row pointing at a missing object).
*Decision: object storage*, with an orphan-sweeper job and writes ordered
upload-then-insert so a failure leaves an unreferenced object (harmless, cleaned up)
rather than a broken link (visible to users).
]

#section[Tier 3 — the seven steps at scale]
#tier-header(3)

#ex(17, tier: 3, asked: "Google · pattern")[
*Design a feature-flag delivery service.* Engineers turn features on and off for a
percentage of users without deploying code. Every backend service in the company must
see a flag change quickly. Run all seven steps.
]
#sol[
*Step 1 --- Clarify.*

#table(columns: (1fr, 1fr),
  [*Question*], [*Answer, and what it decided*],
  [How many application instances read flags?],
    [About 40,000 worldwide across 2,000 services. This is the fleet size that sets
     the fan-out.],
  [How often is a flag *evaluated*?],
    [On nearly every request. 60 M users, ~25 page loads each, ~8 flags per load.
     That is 12 billion evaluations a day --- which immediately means evaluation cannot
     be a network call.],
  [How fast must a change reach every instance?],
    [Under 30 seconds is fine; under 5 seconds is nice. Not milliseconds.],
  [What is the worst failure?],
    [The flag service being down must *never* take down a product service. That
     outranks freshness and is the design's main constraint.],
  [Do flags depend on user attributes?],
    [Yes --- country, app version, and a percentage rollout by user id.],
  [How many flags?],
    [About 5,000 live. At ~400 B each the whole rule set is ~2 MB.],
)

*Step 2 --- Estimate.*

#formulas(title: "The two numbers that decide the architecture")[
*Evaluations per day.*
$ 60{,}000{,}000 "users" times 25 "loads" = 1{,}500{,}000{,}000 "page loads/day" $
$ 1{,}500{,}000{,}000 times 8 "flags" = 12{,}000{,}000{,}000 "evaluations/day" $
$ 12{,}000{,}000{,}000 / 86{,}400 = 138{,}889 "evaluations per second" $

If each evaluation were an RPC at 1 ms, that is 139,000 QPS of pure overhead and
1 ms added to every flag check. *Therefore evaluation must happen in-process.* The
service ships *rules*, not *answers*.

*Poll traffic.* 40,000 instances, each polling every 30 s:
$ 40{,}000 / 30 = 1{,}333 "polls per second" $
That is small --- and, importantly, *flat*. There is no peak hour for a poll loop.

*Bandwidth if each poll returns the full 2 MB rule set.*
$ 40{,}000 times 2 "MB" = 80{,}000 "MB" = 80 "GB per 30-second cycle" $
$ 80 "GB" / 30 "s" = 2.67 "GB/s" = 21.3 "Gbps, continuously" $

*Bandwidth with conditional requests.* The client sends the version it holds; if
nothing changed the server replies `304 Not Modified`, about 200 B.
$ 40{,}000 times 200 "B" = 8{,}000{,}000 "B" = 8 "MB per cycle" $
$ 8 "MB" / 30 "s" = 267 "KB/s" $
$ 80 "GB" / 8 "MB" = 10{,}000 times "less traffic" $
]

*That 10,000x is the whole design.* One HTTP header turns a 21 Gbps problem into a
267 KB/s problem. Say the number.

*Step 3 --- API.*
#code(lang: "text", caption: "Two read paths and one write path")[
```text
GET /v1/ruleset
  header If-None-Match: "v-8817"
  resp   200 { version: "v-8819", flags: [ ... ] }   (full set, gzipped)
         304 (empty body)                            (nothing changed)
  note   this is the poll. 40,000 callers. Cacheable at the edge.

GET /v1/stream            (Server-Sent Events, optional fast path)
  resp   event: ruleset-changed  data: { version: "v-8819" }
  note   a nudge, not the data; the client then calls GET /v1/ruleset

PUT /v1/flags/{flagKey}
  body  { enabled, rollout: { percent: 25, salt: "checkout-v2" },
          rules: [ {attr:"country", op:"in", values:["SG","TH"]} ] }
  resp  200 { version: "v-8819" }
  note  human-triggered, a few hundred calls a day. Audited.
```
]

*Step 4 --- Data model.*
#code(lang: "text", caption: "Small tables; the version number does the heavy lifting")[
```text
flags(flag_key PK, description, owner_team, created_at, archived_at)

flag_versions(flag_key, version_no, rules_json, enabled, rollout_percent,
              rollout_salt, author, created_at,
              PK (flag_key, version_no))     -- append-only: full history, free rollback

ruleset_snapshots(version PK, blob_url, byte_size, built_at)
                                             -- the whole 2 MB set, pre-built
audit(audit_id PK, flag_key, author, before_json, after_json, at)
```
]
`flag_versions` is append-only. An edit writes a new row; it never overwrites. Rollback
is then "serve version 12 again", not "hope someone remembers what it was". For a
system whose whole purpose is changing production behaviour, an immutable history is
not optional.

*Step 5 --- Draw it.*

#diagram(height: 5.4cm, caption: "Rules flow out; nothing flows in on the hot path. The SDK is the availability story.")[
  #dnode(0pt, 0pt, 70pt, 26pt, "Engineer UI")
  #dnode(0pt, 44pt, 70pt, 28pt, "Control API", fill: rgb("#dde8f0"))
  #dnode(0pt, 92pt, 70pt, 26pt, "Postgres")

  #dnode(104pt, 44pt, 76pt, 28pt, "Snapshot\nbuilder", fill: rgb("#f7f7f5"))
  #dnode(104pt, 92pt, 76pt, 26pt, "Blob store", fill: rgb("#f0ece2"))

  #dnode(214pt, 44pt, 70pt, 28pt, "CDN / edge", fill: rgb("#f0ece2"))

  #dnode(318pt, 4pt, 128pt, 30pt, "App instance + SDK\n(in-process eval)", fill: rgb("#dde8f0"))
  #dnode(318pt, 46pt, 128pt, 26pt, "App instance + SDK")
  #dnode(318pt, 82pt, 128pt, 26pt, "... 40,000 of them")
  #dnode(318pt, 116pt, 128pt, 22pt, "on-disk fallback copy", fill: rgb("#f7f7f5"))

  #darrow(35pt, 26pt, 35pt, 44pt)
  #darrow(35pt, 72pt, 35pt, 92pt, label: "write")
  #darrow(70pt, 58pt, 104pt, 58pt)
  #darrow(142pt, 72pt, 142pt, 92pt, label: "2 MB")
  #darrow(180pt, 58pt, 214pt, 58pt)
  #darrow(284pt, 52pt, 318pt, 24pt, label: "304 mostly")
  #darrow(284pt, 58pt, 318pt, 58pt)
  #darrow(284pt, 64pt, 318pt, 90pt)
  #darrow(382pt, 108pt, 382pt, 116pt, dashed: true)

  #place(dx: 0pt, dy: 126pt)[#text(size: 8pt, fill: muted)[Evaluation happens inside the app: 139,000/s, zero network calls. The wire carries only rule changes.]]
]

*Step 6 --- Deep dive 1: the SDK must never be able to break a product service.*

This is the requirement that outranks everything. Four rules, and the reason for each:

+ *Evaluate locally, always.* No network call on the hot path, so the flag service
  being slow cannot make checkout slow. This also gives 0 ms of added latency across
  139,000 evaluations per second.
+ *Persist the last good snapshot to local disk.* On process start the SDK loads the
  disk copy *first* and only then tries the network. So a cold start during a flag
  service outage still gets real rules --- possibly hours old, which is vastly better
  than no rules.
+ *Every call site supplies a default.* `flags.isOn("new-checkout", default=false)`.
  If there is no snapshot at all --- brand-new machine, empty disk, service down --- the
  code still runs and takes the safe branch. The default is in the caller's code, so
  it ships with the code that needs it.
+ *Fail open to the old value, never to an exception.* A malformed snapshot is
  rejected wholesale and the previous one is kept. Partial application of a bad
  ruleset is worse than being stale.

*What this costs:* every instance carries 2 MB of memory and there is a window, up to
30 seconds, where instances disagree. So a flag flip is not atomic across the fleet.
*Therefore the rule:* flags may never be used for anything requiring fleet-wide
agreement at an instant --- no "switch database now" flags. They gate *behaviour*, not
*coordination*. Naming that boundary is the senior part of this answer.

*Step 6 --- Deep dive 2: percentage rollout that is stable and independent.*

"Turn this on for 25% of users" has three hidden requirements:
+ *Sticky.* The same user must get the same answer on every request, forever, on every
  machine --- otherwise the UI flickers between old and new.
+ *Independent.* A user in the 25% for flag A must not be more likely to be in the 25%
  for flag B, or your experiments correlate and your measurements are worthless.
+ *Monotonic.* Going 25% -> 50% must *add* users, never swap them out.

#code(lang: "js", caption: "Three lines satisfy all three — then prove it")[
```js
const hash32 = (s) => {                      // FNV-1a: deterministic, no library
  let h = 0x811c9dc5;
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;      // imul keeps the result 32-bit
  }
  return h >>> 0;
};

const bucketOf = (salt, userId) => hash32(`${salt}:${userId}`) % 10000;  // 0..9999
const isOn = (salt, userId, percent) => bucketOf(salt, userId) < percent * 100;

const users = Array.from({ length: 100000 }, (_, i) => `user-${i}`);

// 1. sticky, and the proportion is right
const on25 = users.filter(u => isOn("checkout-v2", u, 25));
console.log("target 25%   ->", (100 * on25.length / users.length).toFixed(2) + "%");
const u0 = on25[0];
console.log(`${u0} bucket =`, bucketOf("checkout-v2", u0),
            "-> on?", isOn("checkout-v2", u0, 25), isOn("checkout-v2", u0, 25));

// 2. monotonic: 25% -> 50% must only ADD users
const on50 = new Set(users.filter(u => isOn("checkout-v2", u, 50)));
console.log("target 50%   ->", (100 * on50.size / users.length).toFixed(2) + "%");
console.log("users dropped when going 25% -> 50% =",
            on25.filter(u => !on50.has(u)).length);

// 3. independent: a different flag picks a different 25%
const onOther = new Set(users.filter(u => isOn("new-search", u, 25)));
console.log("overlap of two 25% flags =",
            (100 * on25.filter(u => onOther.has(u)).length / on25.length).toFixed(2) +
            "%  (expected ~25%)");

// 4. the trap: userId % 100 is NOT independent
const idNum = (u) => Number(u.split("-")[1]);
const modA = users.filter(u => idNum(u) % 100 < 25);
const modB = new Set(users.filter(u => idNum(u) % 100 < 25));
console.log("overlap with userId % 100 =",
            (100 * modA.filter(u => modB.has(u)).length / modA.length).toFixed(2) + "%");
```
]

#code(lang: "text", caption: "Measured output")[
```text
target 25%   -> 24.99%
user-0 bucket = 288 -> on? true true
target 50%   -> 50.08%
users dropped when going 25% -> 50% = 0
overlap of two 25% flags = 24.18%  (expected ~25%)
overlap with userId % 100 = 100.00%
```
]

Now read the output line by line --- each line proves one requirement.
- *24.99% for a 25% target.* The hash spreads users evenly; you get the share you asked
  for without keeping any list of who is in.
- *`true true` for the same user.* Sticky. No randomness, no clock, no machine
  identity, so all 40,000 instances compute the same answer for that user forever.
- *0 users dropped going 25% -> 50%.* Monotonic. Everyone below bucket 2500 is still
  below 5000. Raising a rollout can never take the feature away from someone.
- *24.18% overlap between two different flags.* Independent. That is exactly what
  chance predicts for two unrelated 25% groups, which is what you want: being in one
  experiment tells you nothing about being in another.
- *100.00% overlap with `userId % 100`.* This is the trap. Every flag using `id % 100`
  picks the *same* users. Your "25% experiment" is then always run on the same quarter
  of your customers --- and because ids are usually handed out in order, that quarter is
  your oldest, least typical users. Every measurement you take is biased, and nothing
  in the code looks wrong.

*The other trap:* calling `random()` per request. It is not sticky, so the same user
sees the new checkout on one click and the old one on the next. Users report this as
"the site is broken", and they are right.

*Step 7 --- Trade-offs, failures, 10x.*

#table(columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  [*Choice*], [*Both sides*], [*Decision*],
  [Push (streaming) or pull (polling)?],
    [Push gives ~1 s propagation but needs 40,000 live connections, reconnect storms,
     and per-connection state. Pull is stateless, cacheable at the CDN, trivially
     scalable --- but 30 s slower.],
    [*Pull as the guaranteed path; push as an optional nudge.* Correctness never
     depends on the stream. If it drops, propagation degrades from 1 s to 30 s and
     nothing else changes.],
  [Ship rules, or ship per-user answers?],
    [Answers are simpler for the client and let the server change logic centrally ---
     but require a network call per evaluation: 139,000 QPS and latency on every
     request. Rules need SDKs in every language.],
    [*Ship rules.* The evaluation count makes the other option arithmetically
     impossible, not merely expensive.],
  [Strong consistency across regions, or eventual?],
    [Strong means a global consensus write before any instance sees a change:
     hundreds of ms per write and a *global* outage if the quorum is unreachable.
     Eventual means regions can briefly disagree.],
    [*Eventual, and say why via CAP.* A partition forces a choice between consistency
     and availability. Here availability wins outright, because an unreachable flag
     service must not stop 2,000 product services from serving. The cost --- a few
     seconds of disagreement --- is invisible to users for behaviour flags.],
  [One global ruleset or one per service?],
    [One global blob is 2 MB everywhere, simple to build and cache, but ships each
     service 4,900 flags it never reads. Per-service slices are smaller but mean
     40,000 different objects, so the CDN hit rate collapses.],
    [*One global blob.* 2 MB of memory per instance is nothing, and a single cacheable
     object is what makes the CDN path work. Revisit if the blob passes ~50 MB.],
)

*Failure modes.*
- *Control API down.* Nothing changes; every instance keeps serving its snapshot.
  Engineers cannot flip flags --- an incident, not an outage. This is the correct
  failure shape.
- *A bad ruleset is published* (bad JSON, or a flag turned on for 100% by mistake).
  This is the dangerous one: it propagates everywhere in 30 seconds *by design*.
  Mitigation: schema-validate at write, require a second approver above 10% rollout,
  and keep a one-click "revert to previous version" that is itself just publishing an
  older snapshot. Recovery time must be under 60 seconds.
- *CDN down in one region.* SDKs fall back to the origin. Poll traffic at origin rises
  from near zero to ~1,333 QPS. Size the origin for full fleet load; at 1,333 QPS of
  mostly-304 responses that is a handful of machines. Cheap insurance.
- *Clock skew on an instance.* Time-based rules ("on after 09:00") misfire. Evaluate
  time rules against a timestamp stamped into the snapshot by the builder, not the
  instance's own clock.

*At 10x (400,000 instances).* Poll traffic becomes $400{,}000 \/ 30 = 13{,}333$ QPS ---
still nothing, and the CDN absorbs it. The thing that actually breaks first is the
*snapshot builder*: one process rebuilding a growing blob on every flag edit, with
edits arriving faster. I would make the blob a base snapshot plus signed deltas, so
the SDK fetches only the changes since its version and the builder's work becomes
proportional to the edit, not to the catalogue. Second concern is the blast radius of
a bad publish: at 400,000 instances I would add staged rollout of the *ruleset itself*
--- 1% of instances, then 10%, then all --- so a bad publish is caught by health metrics
before it reaches the fleet.
]

#ex(18, tier: 3, asked: "Amazon · pattern")[
Run *step 6 only*. A write-heavy service stores every row keyed by `user_id`, sharded
by `hash(user_id) % 64`. One customer is an enterprise account generating 60% of all
writes. Describe the problem precisely and give three fixes with a decision.
]
#sol[
*The problem, precisely.* Hashing distributes *keys* evenly, not *traffic*. There is
one key here with enormous traffic, and a hash puts one key on exactly one shard. So
one of the 64 shards takes 60% of all writes while the other 63 share the remaining
40% --- about 0.63% each. Adding shards does not help: 128 shards still puts that key
on one of them. The shard saturates, its replication lag grows, and reads from its
replicas go stale. This is a *hot partition*, and it is the classic failure of
hash sharding.

#approach(1, "Give the big tenant its own shard", verdict: "operationally simplest")
Route by a lookup table: enterprise customers get dedicated shards, everyone else
hashes into the shared pool. Isolates the noisy tenant completely and lets you size
its hardware separately.
*Cost:* a routing table you must keep consistent everywhere, and it only works when
you can *name* the big tenants in advance. A tenant that grows suddenly still melts a
shared shard before you notice.

#approach(2, "Add a sub-key: hash(user_id + bucket)", verdict: "best throughput")
Spread one tenant across $k$ sub-partitions: the write key becomes
`user_id : (writeSeq % 16)`, so that tenant's writes hit 16 shards instead of 1.
*Cost:* any read that wants "all rows for this user" must now query all 16 buckets and
merge. You have traded write skew for read fan-out. Acceptable only if reads are
already scoped (by time range, say) or rare.

#approach(3, "Buffer writes through a log and batch them", verdict: "best when writes are appends")
Send writes to a partitioned log keyed by user, then have a consumer batch 1,000 rows
into one database write. The database sees 1/1000th of the operations.
*Cost:* writes become visible after a delay (tens of ms to seconds), and you must
handle consumer lag and replay. Unacceptable for read-your-own-write flows.

*Decision.* Combine 1 and 3: *dedicated shards for named large tenants* (it is the
change with the least blast radius and no read-path cost), *plus batching through a
log* for the append-only event tables, which is where the volume actually is. I would
not take option 2 here, because the product's main query is "show me this user's
recent rows", and turning every such read into 16 queries would make the common case
worse in order to fix an uncommon one.

*What I would also add, regardless:* per-tenant rate limiting at the gateway, and a
per-shard write-rate alert. The real failure was not the hash --- it was that nobody
was watching a single shard's share of traffic until it was 60%.
]

#ex(19, tier: 3, asked: "Microsoft · pattern")[
Run *step 7 only*: your service runs in Singapore and Frankfurt with a single primary
database in Singapore. The network between regions is cut for 12 minutes. Walk the CAP
decision explicitly for two different features: (a) a "like" button, (b) a bank
transfer.
]
#sol[
*The setup.* During a partition, Frankfurt cannot reach the Singapore primary. You
must choose: refuse writes in Frankfurt (consistency, unavailable) or accept writes
locally and reconcile later (available, inconsistent). CAP says you may not keep both.
There is no clever third option --- but the choice can be made *per feature*, and that
is the answer the interviewer wants.

*(a) The like button --- choose AP.*
Accept likes in Frankfurt into a local store, and merge when the link returns.
- *Why it is safe:* a like count is a commutative counter. Adding 5 here and 3 there
  gives 8 either way; the merge is addition and cannot conflict. Nobody is harmed by a
  count that is 12 minutes behind.
- *The one real edge:* a user may like, see the count not move (because they are reading
  a different replica), and like again. Fix with a per-user unique key
  `(post_id, user_id)` so a like is idempotent --- then even duplicate submissions merge
  to one.
- *Decision: available. Refusing likes for 12 minutes is a worse product with no
  compensating benefit.*

*(b) The bank transfer --- choose CP.*
Refuse the write in Frankfurt. Return "temporarily unavailable, please retry".
- *Why:* two partitions both approving a withdrawal from the same balance creates money
  that does not exist. Reconciliation cannot fix it, because the money has already
  left. The damage is unbounded and irreversible; a 12-minute outage is bounded and
  reversible.
- *Do not simply error, though.* Accept the request into a durable queue, return
  `202 Accepted` with a reference number, tell the user "we will confirm within a few
  minutes", and process it when the primary is reachable. The user keeps a receipt,
  the money moves exactly once, and the *perceived* availability is much better than a
  red error. This is the senior move: you did not break CAP, you moved the wait to a
  place where waiting is acceptable.
- *Decision: consistent. Never let money diverge.*

*The sentence that ties it together.* "CAP is not a property of the system; it is a
choice you make per operation. In one product I will be AP for likes and CP for
transfers, in the same hour, in the same partition."

*And the number that matters more than CAP.* A partition lasting 12 minutes is rare;
replica lag of 200 ms happens constantly. Most real "consistency bugs" are not CAP at
all --- they are a user writing to the primary and then reading a replica that has not
caught up. Fix that with read-your-writes: pin a user to the primary for a few seconds
after their write, or route by a token carrying the write's position in the log.
]

#practice(tier: 3, time: "45 min")[
+ Run all seven steps for *a distributed rate limiter* used by an API gateway across
  40 machines: "100 requests per minute per API key". State exactly what happens when
  the shared counter store is unreachable.
+ You must choose between a single global database with 200 ms cross-region latency
  and per-region databases with eventual convergence, for *a user profile service*.
  Decide, and give the one feature that would flip your decision.
+ Run step 2 and step 6 for *a service that fans out a post to followers*: 20 million
  posts a day, average 300 followers. Then handle the account with 50 million
  followers.
+ Design the *failure-mode section only* for a payment gateway: list six components
  and, for each, what happens when it fails and what the user sees.
+ A senior engineer says "just add a cache". Give three specific questions you would
  ask before agreeing, and say what a wrong answer to each would cost.
]

#key[
*1.* Clarify: per key or per key per endpoint; is a small overshoot acceptable; hard
or soft limit. Estimate: if the gateway handles 50,000 QPS, a shared counter store
sees 50,000 increments/s --- within one Redis node (~100 K ops/s) but with no headroom,
so shard by key. API: internal `allow(key) -> {allowed, remaining, resetAt}`; return
`429` with `Retry-After` and `X-RateLimit-Remaining`. Data: one counter per
`(key, minuteBucket)` with a TTL of two minutes --- expiry is automatic, no cleanup job.
Deep dive: a fixed one-minute window lets a caller send 100 at 10:00:59 and 100 at
10:01:00 --- 200 in one second. Use a sliding window counter (weight the previous
bucket by the fraction of the window still covered) or a token bucket. Failure: if the
store is unreachable, *fail open* --- allow the request and log it. A rate limiter that
takes down the API it protects has inverted its own purpose; the cost of briefly
allowing extra traffic is far lower than the cost of a total outage. For a limiter
guarding something expensive (SMS sending, money), fail *closed* instead, and say so.

*2.* *Per-region databases.* A profile is read constantly and written rarely, and
almost every read is by the owner or by people near them, so a local read at 5 ms
beats a global read at 200 ms on every page load. Conflicts are rare (one person
editing their own profile) and last-writer-wins per field is acceptable.
*The feature that flips it:* a globally unique username or handle. Uniqueness cannot be
decided locally --- two regions can both accept "riya" --- so that one field needs a
single global authority (or a consensus store) even if everything else stays regional.
Note the shape of the answer: split the data by what it needs, rather than forcing one
answer on the whole service.

*3.* Fan-out writes: $20{,}000{,}000 times 300 = 6{,}000{,}000{,}000$ feed rows/day
$= 6{,}000{,}000{,}000 \/ 86{,}400 = 69{,}444$ writes/s sustained. That is large but
survivable with a partitioned log and batched inserts. The celebrity breaks it: one
post to 50 million followers is 50 million writes; spread over 60 seconds that is
$50{,}000{,}000 \/ 60 = 833{,}333$ writes/s from a *single* post --- twelve times the
entire normal load. Fix: hybrid. Fan out on write for normal accounts; for accounts
above a threshold (say 100,000 followers) do not fan out at all --- store the post once
and merge it into the feed at read time. A reader follows few celebrities, so the
read-time merge is a handful of extra lookups, and it is bounded. State the threshold
and say it should be tunable, because the right value is an operational fact, not a
design constant.

*4.* Card network timeout: user sees "processing", order held in `PENDING`, reconciled
by a job that queries the network by reference; never charge twice, never assume
failure. Our database primary down: writes refused, `202 Accepted` into a durable
queue, user gets a reference number. Fraud service down: decide in advance --- for
low-value transactions approve without it (fail open, cap exposure by amount); for
high-value, decline (fail closed). Queue backed up: settlement is late, not lost;
alert on queue age, not queue length. Webhook endpoint of the merchant down: retry
with exponential backoff for 24 hours, then dead-letter and alert the merchant.
Entire region down: read-only mode in the secondary showing existing transactions,
new payments queued; state the recovery point and recovery time objectives explicitly.

*5.* (i) *"What is the hit rate going to be, and how do you know?"* --- a cache in front
of a uniform-access dataset does nothing; you added a hop and a bug source for zero
benefit. (ii) *"What happens when the cache is empty or restarts?"* --- if the database
cannot survive 100% of traffic even briefly, the cache is not an optimisation, it is a
single point of failure with no fallback; you need request coalescing and staged
warm-up. (iii) *"How does an entry become wrong, and who removes it?"* --- unanswered,
you will ship stale data and never know; the cost is a bug class that is invisible in
testing and appears only under concurrency.
]

#section[Interview drill — what the interviewer pushes on]

These are the pushes that come in almost every design round, and the answer that
scores. Read the answer out loud once. The wording matters as much as the content.

#table(columns: (1fr, 1.6fr),
  align: (left, left),
  [*The push*], [*The answer that scores*],
  ["How would you scale this?"],
    ["Which part? Reads scale by adding replicas and a cache. Writes scale by
      sharding on X. Right now the binding constraint is (the one you computed), so
      that is where I would spend first."],
  ["What if the cache goes down?"],
    ["All traffic goes to the database --- that is (number) QPS. One node handles
      roughly (number), so I need N nodes, or a degraded mode. I would add request
      coalescing so 10,000 misses for the same key become one database read."],
  ["Is this consistent?"],
    ["Within one shard, yes --- it is a single-row transaction. Across shards, no, and I
      chose that: the alternative is a distributed transaction, which costs latency on
      every write to remove a rare anomaly."],
  ["Why did you choose SQL here?"],
    ["Because the access pattern is relational and I need a multi-row transaction for
      X. The data is (size), which one node handles for years. I would move to a
      key-value store if the access pattern became a single-key lookup at (scale)."],
  ["What if I told you traffic is 100x?"],
    ["Then (specific component) breaks first, because (its measured limit). I would
      change (specific thing). The next thing to break after that is (second
      component)."],
  ["How do you handle a duplicate request?"],
    ["An idempotency key from the client, stored with a unique index. A repeat returns
      the stored response instead of doing the work again. I keep keys for 24 hours."],
  ["Where is the single point of failure?"],
    ["(Name it honestly --- there is always one.) Today it is X. I would remove it by Y,
      and until then the blast radius is Z."],
  ["Your estimate looks wrong."],
    ["Let me redo it out loud. (Redo the division.) You are right, it is (new number) ---
      which changes (what it changes)." Never defend a wrong number.],
  ["Why not just use a bigger machine?"],
    ["For this size, that is genuinely the right first answer and it is cheaper than
      my time. It stops working at (number), because (the limit), and then I shard."],
  ["How do you test this?"],
    ["Unit tests on the rule logic; one integration test per failure mode I listed;
      and a load test at 3x peak to check the headroom I claimed is real."],
  ["How do you deploy a schema change?"],
    ["Expand, migrate, contract. Add the new column and write both, backfill, switch
      reads, then drop the old column in a later release. Never in one step."],
  ["We are out of time. Summarise."],
    ["Three sentences: what it does, the one number that shapes it, and the one
      trade-off I chose. Nothing else."],
)

#trick[
*The recovery move.* If you get stuck, say: "Let me go back to the numbers." Re-deriving
QPS or storage out loud takes 30 seconds, restarts your thinking, and looks like
method rather than panic. It is the single most useful habit in the whole round.
]

#trap[
Three behaviours that lose the room, in order of how often they happen:
+ *Silence.* Ten seconds of thinking is fine; thirty is not. Say what you are weighing.
+ *Arguing with the interviewer.* If they push, they are either testing you or they
  know something. Both cases mean: consider it out loud.
+ *Name-dropping.* "I would use Kafka and Cassandra and Kubernetes." Naming tools
  without naming the property you need from them reads as a memorised list. Say the
  property first: "I need an ordered, replayable log per key --- Kafka gives me that."
]

#revision[
*The seven steps.* Clarify -> Estimate -> API -> Data model -> Draw -> Deep dive ->
Trade-offs. Never skip; shrink instead.

*The budget (45 min).* 5 / 5 / 5 / 5 / 10 / 10 / 5.

*The six clarifying questions.* How many users. Top three actions. Read:write ratio.
Freshness tolerance. What must never break. One region or many.
Plus: "auth, payments and admin are out of scope."

*The four numbers, in order.*
#table(columns: (auto, 1fr),
  [requests/day], [DAU $times$ actions per user],
  [average QPS], [requests/day $\/ 86{,}400$ (round to 100,000)],
  [peak QPS], [average $times 3$],
  [storage/year], [rows/day $times$ bytes/row $times 365$],
)

*The API rules.* Version the path. Cursor pagination, never page numbers. Idempotency
key on every write that spends money or sends a message. Return an id from a create.

*The data model rules.* Name the partition key and justify it by the read pattern.
Every index must name the query it serves. Enforce uniqueness with a database
constraint, not with application code.

*Pick the deep dive from this list.* Hot key. Fan-out. Uniqueness race. Retry after
timeout. Big list scan.

*The trade-off sentence.* "A gives me X, B gives me Y. This product needs X because
(user reason), so I choose A. If (condition) changed, I would switch."

*Failure walk.* Cache dies. Queue backs up. One shard dies. One region dies. A bad
config is published. For each: what breaks, what the user sees, what alerts.

*Things that lose marks.* "It depends" with no choice. Designing auth unasked. No
numbers. Unlabelled boxes. Arguing. Tool names with no reason attached.

*Things that gain marks.* A stated out-of-scope list. A division done out loud. A
correct "this is small, one server is enough". A named single point of failure. A
decision with the condition that would reverse it.

*The recovery line.* "Let me go back to the numbers."
]

]
