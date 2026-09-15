#import "../../shared/lib/style.typ": *

// ============================================================
//  TITLE PAGE
// ============================================================

#v(3.2cm)

#align(center)[
  #text(size: 10pt, fill: muted, weight: "bold", tracking: 3pt)[
    A SELF-STUDY BOOK FOR THE CORE-SUBJECTS ROUND
  ]

  #v(10pt)
  #line(length: 62%, stroke: 1.2pt + ink)
  #v(16pt)

  #text(size: 30pt, weight: "bold")[
    CS Fundamentals \
    #v(2pt)
    for the Technical Round
  ]

  #v(14pt)
  #line(length: 62%, stroke: 1.2pt + ink)
  #v(14pt)

  #text(size: 12pt, style: "italic")[
    Operating Systems · Databases · Networks · OOP and dev fundamentals
  ]

  #v(10pt)

  #block(width: 78%, fill: boxbg, inset: 9pt, radius: 3pt,
         stroke: (left: 2.5pt + ink, rest: 0.4pt + rule))[
    #align(left)[
      #text(size: 9pt, weight: "bold", tracking: 1pt, fill: muted)[WHAT THIS BOOK IS]
      #v(3pt)
      #set text(size: 9.5pt)
      The round where an interviewer puts the resume down and asks core-subject questions
      one after another. Every topic here is a *question, a crisp answer, and then the
      worked example or diagram that makes the answer stick*. Service companies ask these
      heavily --- often more than DSA. Product companies ask fewer, and go deeper.
    ]
  ]

  #v(12pt)

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

  #v(12pt)
  #text(size: 10pt, fill: muted)[
    12 chapters · diagrams · runnable JavaScript and real SQL · rapid-fire one-liners · one-page revision cards
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
  #text(size: 9pt, weight: "bold", tracking: 1pt, fill: muted)[AN HONEST NOTE ON WHERE THIS MATERIAL COMES FROM]
  #v(4pt)
  #set text(size: 9.5pt)
  #set par(justify: true)

  Every question, answer, example, table and diagram in this book is *original*. Each one
  was written for this book.

  Nothing here is copied, quoted or paraphrased from any published book, course, question
  bank, documentation page or website.

  No company's actual interview, test paper or question list is reproduced here. Real
  hiring questions are private property, and they are not public documents.

  When an item is labelled, for example, "TCS NQT · pattern" or "Grab · pattern", that
  label means one thing only: the item was written to match the *publicly documented shape*
  of that kind of round --- its topic mix, its usual depth, and the follow-up it tends to
  attract. The label is never a claim that this question, or anything resembling it, was
  asked at a real company.

  Company names appear only to describe that shape. This book is not affiliated with,
  endorsed by, or connected to any company named in it. All trademarks belong to their
  owners.

  Every JavaScript and Python listing was executed before it was printed, and every SQL
  query was checked by hand against the sample tables shown beside it. Where the text
  claims an output, that output came from a real run. Numbers such as seek times, page
  sizes and round-trip times are stated as *illustrative* values for the arithmetic --- your
  machine and your network will differ, and the method is the part that transfers.
]

#pagebreak()
