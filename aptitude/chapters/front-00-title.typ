#import "../lib/style.typ": *

// ============================================================
//  TITLE PAGE
// ============================================================

#v(4.2cm)

#align(center)[
  #text(size: 10pt, fill: muted, weight: "bold", tracking: 3pt)[
    A SELF-STUDY BOOK FOR HIRING TESTS
  ]

  #v(10pt)
  #line(length: 62%, stroke: 1.2pt + ink)
  #v(16pt)

  #text(size: 30pt, weight: "bold")[
    Quant, Aptitude \
    #v(2pt)
    & Reasoning \
    #v(2pt)
    for Placements
  ]

  #v(16pt)
  #line(length: 62%, stroke: 1.2pt + ink)
  #v(18pt)

  #text(size: 12pt, style: "italic")[
    Every chapter climbs three tiers of difficulty
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

  #v(18pt)
  #text(size: 10pt, fill: muted)[
    24 chapters · quantitative aptitude · logical reasoning · data interpretation · 5 full mock papers
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

  Nothing here is copied from any published book, question bank, or exam paper.

  No company's actual test paper is reproduced, quoted, or paraphrased. Real hiring tests
  are private property and are not public documents.

  When a problem is labelled, for example, "TCS NQT pattern" or "Grab · pattern", that label
  means one thing only: the problem was written to match the *publicly documented shape* of
  that company's test --- its topic mix, its usual difficulty, and its time pressure. The
  label is never a claim that this question, or anything like it, appeared on a real test.

  Company names are used only to describe that pattern. This book is not affiliated with,
  endorsed by, or connected to any company named in it. All trademarks belong to their
  owners.

  Every answer has been worked twice. If you still find a mistake, trust your own working
  and re-check it --- that habit is worth more than any answer key.
]

#pagebreak()
