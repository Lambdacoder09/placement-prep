#import "../../shared/lib/style.typ": *

// ============================================================
//  TITLE PAGE
// ============================================================

#v(3.6cm)

#align(center)[
  #text(size: 10pt, fill: muted, weight: "bold", tracking: 3pt)[
    A SELF-STUDY BOOK FOR DESIGN ROUNDS
  ]

  #v(10pt)
  #line(length: 62%, stroke: 1.2pt + ink)
  #v(16pt)

  #text(size: 30pt, weight: "bold")[
    System Design \
    #v(2pt)
    for Interviews
  ]

  #v(8pt)
  #text(size: 16pt, weight: "bold", fill: muted)[LLD and HLD]

  #v(16pt)
  #line(length: 62%, stroke: 1.2pt + ink)
  #v(18pt)

  #text(size: 12pt, style: "italic")[
    One procedure. Seven steps. Twelve chapters that climb three tiers.
  ]

  #v(14pt)

  #block(width: 88%)[
    #table(
      columns: (auto, 1fr),
      stroke: none,
      inset: (x: 6pt, y: 5pt),
      align: (right, left),

      text(size: 10pt, weight: "bold", fill: t1col)[TIER 1],
      text(size: 10pt)[Low-level design --- classes, SOLID, patterns, one small design that
      runs. TCS, Accenture, Infosys, Wipro, Capgemini, Cognizant],

      text(size: 10pt, weight: "bold", fill: t2col)[TIER 2],
      text(size: 10pt)[Mid-scale HLD --- one service done properly: API, schema, cache,
      a few thousand requests per second. Grab, Sea/Shopee, GIC, DBS, Agoda, SCB],

      text(size: 10pt, weight: "bold", fill: t3col)[TIER 3],
      text(size: 10pt)[Large-scale distributed --- sharding, quorums, CAP trade-offs,
      multi-region, failure modes. Google, Amazon, Microsoft, Uber, Adobe],
    )
  ]

  #v(16pt)
  #text(size: 10pt, fill: muted)[
    12 chapters · estimation · OOP & SOLID · design patterns · classic LLD ·
    databases · caching · load balancing & API · queues · sharding · 10 HLD case studies
  ]

  #v(10pt)
  #text(size: 9.5pt, fill: muted)[
    Code is JavaScript first (ES2022), Python where it reads more clearly.
  ]
]

#v(1fr)

#block(
  width: 100%,
  fill: boxbg,
  inset: 11pt,
  radius: 3pt,
  stroke: (left: 2.5pt + ink, rest: 0.4pt + rule),
)[
  #text(size: 9pt, weight: "bold", tracking: 1pt, fill: muted)[A NOTE ON WHERE THIS MATERIAL COMES FROM]
  #v(4pt)
  #set text(size: 9.5pt)
  #set par(justify: true)

  Every design, problem, code listing, diagram and answer in this book is *original*.
  Each one was written for this book.

  Nothing here is copied from any published book, course, blog or question bank.

  No company's real interview question is reproduced, quoted or paraphrased. Real
  interview questions are private property and are not public documents. No engineer's
  account of a real interview was used.

  When a design is labelled, for example, "Grab · pattern" or "Amazon · pattern", that
  label means one thing only: the problem was written to match the *publicly documented
  shape* of that company's design round --- the kind of system it tends to ask about, the
  depth it tends to push to, and the time it gives you. The label is never a claim that
  this question, or anything like it, was ever asked at that company.

  Company names are used only to describe that shape. This book is not affiliated with,
  endorsed by, or connected to any company named in it. All trademarks belong to their
  owners.

  Architecture descriptions of well-known systems are *teaching sketches*, not accounts
  of how any real company builds anything. Treat them as a model to reason with, not as
  inside knowledge.

  Every number was worked twice and every code listing was run before it was printed.
  If you still find a mistake, trust your own working and re-check it --- that habit is
  worth more than any answer key.
]

#pagebreak()
