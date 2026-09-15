#import "../../shared/lib/style.typ": *

// ============================================================
//  TITLE PAGE
// ============================================================

#v(3.2cm)

#align(center)[
  #text(size: 10pt, fill: muted, weight: "bold", tracking: 3pt)[
    A SELF-STUDY BOOK FOR THE ROUNDS AFTER THE CODING TEST
  ]

  #v(10pt)
  #line(length: 62%, stroke: 1.2pt + ink)
  #v(16pt)

  #text(size: 30pt, weight: "bold")[
    The Interview Rounds \
  ]
  #v(6pt)
  #text(size: 17pt, weight: "bold", fill: muted)[
    HR · Behavioural · Projects · Puzzles
  ]

  #v(16pt)
  #line(length: 62%, stroke: 1.2pt + ink)
  #v(16pt)

  #text(size: 12pt, style: "italic")[
    Structures you fill with your own true stories --- never scripts you memorise
  ]

  #v(10pt)

  #block(width: 76%, fill: boxbg, inset: 9pt, radius: 3pt,
         stroke: (left: 2.5pt + ink, rest: 0.4pt + rule))[
    #align(left)[
      #text(size: 9pt, weight: "bold", tracking: 1pt, fill: muted)[THE ONE RULE OF THIS BOOK]
      #v(3pt)
      #set text(size: 9.5pt)
      Every answer in this book is shown as a *structure* plus a *filled example*. The filled
      example is there so you can see the shape. It is not your answer. You substitute your own
      real project, your own real team, your own real numbers --- every time. Nobody in this
      book is coached to lie, and no weak answer is fixed by inventing a better one.
    ]
  ]

  #v(14pt)

  #block(width: 88%)[
    #table(
      columns: (auto, 1fr),
      stroke: none,
      inset: (x: 6pt, y: 5pt),
      align: (right, left),

      text(size: 10pt, weight: "bold", fill: t1col)[TIER 1],
      text(size: 10pt)[Standard HR screen --- TCS, Accenture, Infosys, Wipro, Capgemini, Cognizant],

      text(size: 10pt, weight: "bold", fill: t2col)[TIER 2],
      text(size: 10pt)[Cross-border and regional --- Grab, Sea/Shopee, GIC, DBS, Agoda, SCB],

      text(size: 10pt, weight: "bold", fill: t3col)[TIER 3],
      text(size: 10pt)[Structured behavioural, deep probing --- Google, Amazon, Microsoft, Goldman Sachs],
    )
  ]

  #v(14pt)
  #text(size: 10pt, fill: muted)[
    8 chapters · weak answer vs strong answer, side by side · labelled STAR · 24 puzzles ·
    7 guesstimates · one-page revision cards
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

  Every question, answer, story, puzzle and example in this book is *original*. Each one was
  written for this book.

  Nothing here is copied, quoted or paraphrased from any published book, course, question
  bank, coaching handout or website.

  *No company's real interview is reproduced here.* No transcript, no question paper, no
  candidate's recollection. Real hiring questions and real interview conversations are
  private; they are not public documents, and none were used.

  When something is labelled, for example, "TCS · pattern" or "Amazon · pattern", that label
  means one thing only: it was written to match the *publicly documented shape* of that kind
  of round --- its usual topics, its usual depth of follow-up, and its usual time pressure,
  as described in openly published careers pages, job posts and the companies' own public
  descriptions of how they interview. The label is never a claim that this question, or
  anything like it, was actually asked at that company.

  Company names appear only to describe that shape. This book is not affiliated with,
  endorsed by, or connected to any company named in it. All trademarks belong to their
  owners.

  Every filled answer, project and story in this book is *invented for teaching*. The people
  in them do not exist. They show you the structure, the length and the level of detail.
  Your own answer must come from your own life --- at Tier 3 the follow-up to the follow-up
  finds an invented story, and a background check finds the rest.
]

#pagebreak()
