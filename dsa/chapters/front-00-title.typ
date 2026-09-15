#import "../../shared/lib/style.typ": *

// ============================================================
//  TITLE PAGE
// ============================================================

#v(3.6cm)

#align(center)[
  #text(size: 10pt, fill: muted, weight: "bold", tracking: 3pt)[
    A SELF-STUDY BOOK FOR THE CODING ROUND
  ]

  #v(10pt)
  #line(length: 62%, stroke: 1.2pt + ink)
  #v(16pt)

  #text(size: 30pt, weight: "bold")[
    Data Structures \
    #v(2pt)
    & Algorithms \
    #v(2pt)
    for the Coding Round
  ]

  #v(16pt)
  #line(length: 62%, stroke: 1.2pt + ink)
  #v(16pt)

  #text(size: 12pt, style: "italic")[
    Every problem climbs from brute force to optimal, and every line of code was run
  ]

  #v(8pt)

  #block(width: 74%, fill: boxbg, inset: 9pt, radius: 3pt,
         stroke: (left: 2.5pt + ink, rest: 0.4pt + rule))[
    #align(left)[
      #text(size: 9pt, weight: "bold", tracking: 1pt, fill: muted)[THE LANGUAGE OF THIS BOOK]
      #v(3pt)
      #set text(size: 9.5pt)
      *JavaScript (Node) is the primary language.* Python appears as a second opinion where
      it is genuinely shorter. There is no C++ and no Java in this book — the appendix
      supplies the five data structures JavaScript is missing, all of them tested.
    ]
  ]

  #v(14pt)

  #block(width: 86%)[
    #table(
      columns: (auto, 1fr),
      stroke: none,
      inset: (x: 6pt, y: 5pt),
      align: (right, left),

      text(size: 10pt, weight: "bold", fill: t1col)[TIER 1],
      text(size: 10pt)[Indian service companies --- TCS NQT, Accenture, Infosys, Wipro, Capgemini, Cognizant],

      text(size: 10pt, weight: "bold", fill: t2col)[TIER 2],
      text(size: 10pt)[Singapore & Thailand --- Grab, Sea/Shopee, GIC, DBS, Agoda, SCB, LINE MAN, Razer],

      text(size: 10pt, weight: "bold", fill: t3col)[TIER 3],
      text(size: 10pt)[Global product companies --- Google, Amazon, Microsoft, Goldman Sachs, D. E. Shaw, Adobe, Uber],
    )
  ]

  #v(14pt)
  #text(size: 10pt, fill: muted)[
    20 chapters · arrays to dynamic programming · approach ladders · dry runs · one-page revision cards
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
  #text(size: 9pt, weight: "bold", tracking: 1pt, fill: muted)[A NOTE ON WHERE THESE PROBLEMS COME FROM]
  #v(4pt)
  #set text(size: 9.5pt)
  #set par(justify: true)

  Every problem in this book is *original*. Each one was written for this book.

  Nothing here is copied from any published book, course, question bank, or online judge.

  No company's actual interview or test paper is reproduced, quoted, or paraphrased. Real
  hiring questions are private property and are not public documents.

  When a problem is labelled, for example, "TCS NQT · pattern" or "Grab · pattern", that
  label means one thing only: the problem was written to match the *publicly documented
  shape* of that company's round --- its topic mix, its usual difficulty, and its time
  pressure. The label is never a claim that this question, or anything like it, was asked
  at a real company.

  Company names are used only to describe that pattern. This book is not affiliated with,
  endorsed by, or connected to any company named in it. All trademarks belong to their
  owners.

  Every code listing in this book was executed before it was printed. Where the text claims
  an output, that output was copied from a real run. Timings were measured on one ordinary
  machine and will differ on yours --- the *shape* of the growth is the part that transfers.
]

#pagebreak()
