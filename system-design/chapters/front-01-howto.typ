#import "../../shared/lib/style.typ": *

#toc-entry("How to use this book")

#block(width: 100%, inset: (bottom: 6pt))[
  #text(size: 22pt, weight: "bold")[How to use this book]
  #v(-3pt)
  #text(size: 10pt, fill: muted, style: "italic")[Read these two pages once. Then start Chapter 1.]
]
#line(length: 100%, stroke: 1.2pt + ink)
#v(4pt)

#show table: set text(size: 8.6pt)

#section[1 · What the three tiers mean *in this book*]

In the other books of this series a tier is a difficulty level. Here a tier is a
*different kind of round*. A company usually runs one of them, not all three.

#table(
  columns: (auto, auto, 1fr, auto),
  inset: (x: 4pt, y: 3.5pt),
  align: (left, left, left, center),
  [*Tier*], [*Who runs this round*], [*What you must produce*], [*Length*],

  text(weight: "bold", fill: warmcol)[0 Warm-up],
  [nobody --- it is you],
  [One mechanism alone: a single class, one cache policy, one index, one queue guarantee.
  No story, no scale. You are building the reflex.],
  [5--10 min],

  text(weight: "bold", fill: t1col)[1 LLD],
  [TCS, Accenture, Infosys, Wipro, Capgemini, Cognizant],
  [Classes, fields, methods, SOLID, one or two patterns, and code that would run. No
  servers, no QPS. Marks come from clean boundaries and the awkward case.],
  [45 min],

  text(weight: "bold", fill: t2col)[2 Mid-scale HLD],
  [Grab, Sea/Shopee, GIC, DBS, Agoda, SCB, LINE MAN],
  [One service done properly: 3--5 endpoints, a schema with the key chosen, a cache with an
  invalidation rule, a few thousand RPS. Depth beats breadth.],
  [45--60 min],

  text(weight: "bold", fill: t3col)[3 Large-scale],
  [Google, Amazon, Microsoft, Uber, Adobe, Goldman Sachs],
  [Sharding key and its hotspot, replication and the consistency promise, a CAP decision
  you defend, multi-region, and what breaks first. Follow-ups are half the round.],
  [45--60 min],
)

#note[
Work Tier 1 first even for a Tier-3 company. Every Tier-3 design is built on the Tier-1 and
Tier-2 ones before it. A distributed design is a low-level design with a network in the
middle --- and the network is the part that fails.
]

#section[2 · Inside every chapter, and the six rules]

#grid(columns: (1fr, 1fr), gutter: 8pt,
  table(
    columns: (auto, 1fr),
    inset: (x: 4pt, y: 3.5pt),
    [*Idea in one page*], [The mechanism, its one formula or invariant, and the sentence you
    say out loud.],
    [*Warm-up*], [Bare mechanics. Short. Where the vocabulary becomes automatic.],
    [*Tier 1 #sym.arrow.r 2 #sym.arrow.r 3*], [The same idea as classes, then as one service,
    then as many machines.],
    [*Seven steps*], [Clarify, estimate, API, data model, diagram, deep dive, trade-offs.
    Never skipped, sometimes shrunk.],
    [*Interview drill*], [What the interviewer pushes on next, and the answer that survives
    the push.],
    [*Practice + key*], [Timed sets per tier. The key gives the full design, not a hint.],
    [*Revision card*], [Numbers, checklist, traps in the order they bite. Re-read this the
    night before.],
  ),
  table(
    columns: (auto, 1fr),
    inset: (x: 4pt, y: 3.5pt),
    [*1 Numbers*], [Thirty seconds of arithmetic ticks the "did they estimate?" box. Zero
    seconds ticks nothing. Do one division out loud.],
    [*2 Decide*], [Every trade-off names both sides *and picks one*. Say which, why, and what
    you gave up.],
    [*3 Draw early*], [Boxes and arrows by minute 20, with the read path and write path
    marked separately.],
    [*4 Code runs*], [Every listing here was run with `node` first. In the room, write code
    you could run, not pseudo-code that hides the hard part.],
    [*5 Depth*], [Two parts solved properly beat eight parts named. Short on time? Deepen,
    do not widen.],
    [*6 Failure*], [Name what breaks, how you notice, and what the user sees meanwhile. This
    separates senior from junior.],
  ),
)

#section[3 · The study plan --- eight weeks]

One hour a day on weekdays, two on Saturday. Each checkpoint is closed-book, on paper,
against a timer.

#table(
  columns: (auto, auto, auto, 1fr),
  inset: (x: 4pt, y: 3.5pt),
  align: (center, left, left, left),
  [*Week*], [*Chapters*], [*Daily target*], [*Checkpoint (closed book, timed)*],

  [1], [Ch 1, 2], [1 section + the arithmetic drills],
  [Seven steps from memory in 2 min. Storage for a 20 M-user photo app in 5 min.],

  [2], [Ch 3], [1 SOLID principle + rewrite one bad class],
  [Split a 60-line god class. Name the principle each split serves.],

  [3], [Ch 4], [1 pattern, typed from scratch],
  [Strategy, observer and factory from memory in JavaScript. 30 min, must run.],

  [4], [Ch 5], [1 classic LLD problem, full 45 min],
  [Vending machine end to end on paper in 45 min: classes, states, code.],

  [5], [Ch 6, 7], [1 section + draw the schema],
  [Schema + index plan for a booking system, then a cache and its invalidation rule.],

  [6], [Ch 8, 9], [1 section + one API written out],
  [A rate-limited, idempotent payment-submit endpoint, with the retry story.],

  [7], [Ch 10, 11], [1 case study, full 45 min],
  [A URL shortener and a news feed, each with a sharding key and a defended CAP choice.],

  [8], [Ch 12 + back matter], [1 case study + revise the cards],
  [Two 45-min mock rounds, out loud, recorded. Then watch the recording.],
)

#section[4 · The crash plan --- five days]

Use this only when the interview is this week. It buys a pass, not mastery.

#table(
  columns: (auto, 1fr, auto),
  inset: (x: 4pt, y: 3.5pt),
  align: (center, left, center),
  [*Day*], [*Do exactly this*], [*Hours*],

  [1], [Chapter 1 in full. Chapter 2's revision card --- *memorise the latency numbers and
  the five estimation lines*. Nothing else.], [3],

  [2], [Chapter 3 skim, then Chapter 4's six patterns, typing each one once. Then one
  problem from Chapter 5 end to end.], [3],

  [3], [Chapters 6 and 7: "The idea in one page" and the revision card of each. Then the
  SQL-vs-NoSQL and cache-pattern tables until you can reproduce them.], [3],

  [4], [Chapters 8, 9, 10: revision cards only, plus the trade-off table in the appendix.
  Learn the sharding-key hotspot argument cold.], [3],

  [5], [Two case studies from Chapter 11 spoken out loud against a timer, then the appendix
  quick reference twice.], [4],
)

#trap[
The crash plan skips the practice sets --- that is what makes it a crash plan. With three
weeks, run the eight-week plan at double speed instead. The practice sets are where a
design moves from "I read it" to "I can produce it".
]
