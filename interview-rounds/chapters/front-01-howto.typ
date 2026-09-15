#import "../../shared/lib/style.typ": *

#toc-entry("How to use this book")

#block(width: 100%, inset: (bottom: 6pt))[
  #text(size: 22pt, weight: "bold")[How to use this book]
  #v(-3pt)
  #text(size: 10pt, fill: muted, style: "italic")[Two pages. Read them once, then start Chapter 1.]
]
#line(length: 100%, stroke: 1.2pt + ink)
#v(4pt)

#section[1 · What the three tiers mean in *this* book]

In the coding books a tier means how hard the problem is. Here it means *how deep the
interviewer digs into the same answer.* One honest story, told at three depths.

#table(
  columns: (auto, auto, 1fr, auto),
  inset: (x: 5pt, y: 3pt),
  align: (left, left, left, center),
  [*Tier*], [*Who runs the round*], [*What it feels like*], [*Follow-ups*],

  text(weight: "bold", fill: warmcol)[0 Warm-up],
  [you, with a timer],
  [One slot of a structure at a time: write the NOW sentence, or say the ACKNOWLEDGE line and hold three seconds of silence. Mechanics only.],
  [0],

  text(weight: "bold", fill: t1col)[1 Standard HR],
  [TCS, Accenture, Infosys, Wipro, Capgemini, Cognizant],
  [The famous ten --- yourself, strengths, weakness, why us, five years, relocation, bond, notice period. Asked once, taken at face value.],
  [0--1],

  text(weight: "bold", fill: t2col)[2 Cross-border],
  [Grab, Sea/Shopee, GIC, DBS, Agoda, SCB],
  [The same questions plus the regional layer: work pass and relocation reality, why South East Asia, communication style, CTC vs in-hand in two currencies.],
  [1--2],

  text(weight: "bold", fill: t3col)[3 Structured behavioural],
  [Google, Amazon, Microsoft, Goldman Sachs],
  [Principle-driven. One story, then "why that choice?", "what would you do differently?", "what did the other person say?". The follow-ups *are* the interview.],
  [3--5],
)

Work Tier 1 first even for a Tier 3 company. A Tier 3 answer is not a different answer --- it
is the same Tier 1 answer that survived five layers of "why".

#section[2 · How to use the book]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3pt),
  [*Weak vs strong, side by side*], [Each big question shows a WEAK and a STRONG answer to
  the *same* question, then a table naming what changed. The change table is the lesson ---
  not the sample answer.],

  [*Structure, then filled example*], [The structure (STAR, NOW--PATH--PROOF--POINT,
  A--F--E--F, PAUSE, SPEH) is yours to keep. Every filled example is invented for teaching.
  Never carry one into a real room.],

  [*Out loud, on a timer*], [An answer that reads well at your desk and runs three minutes
  out loud has already failed. Record yourself weekly and play it back. And build the story
  bank (Chapter 4) *before* you write any answer --- the other order produces invented stories.],
)

#pagebreak(weak: true)

#trap[
The four failures that cost the most offers: *no number in the answer*; *"we" where it should
be "I"*; *a weakness that is secretly a boast*; *a project you cannot trace one request through*.
]

#section[3 · The six-week plan]

About 90 minutes a day, six days a week. Day 7 is the checkpoint --- spoken, on a timer, from
memory.

#table(
  columns: (auto, auto, 1fr, 1fr),
  inset: (x: 5pt, y: 3pt),
  align: (center, left, left, left),
  [*Week*], [*Chapters*], [*Daily target*], [*Checkpoint (day 7)*],

  [1], [1, 2],
  [Ch 1 on days 1--2: the funnel, and what each round scores. Ch 2 on days 3--6: rewrite five
  resume bullets a day as VERB + WHAT + HOW + NUMBER.],
  [A one-page resume where every bullet holds a number you can defend.],

  [2], [3],
  [One HR question a day, out loud, on a timer: warm-up slot, then Tier 1, then the Tier 2/3
  version of the same question.],
  [Questions 1--6 back to back, recorded, none over 90 seconds.],

  [3], [4],
  [Days 1--2: build the story bank of 12 real events. Days 3--6: two stories a day in
  labelled STAR, each with a measured result.],
  [Someone picks three of your stories and probes each three levels deep.],

  [4], [5],
  [One Project Defence Sheet per project, then a day each on: what did YOU do, the 60-second
  architecture, the code you must explain, the extension question.],
  [Trace one request end to end on a blank page, then defend two trade-offs.],

  [5], [6, 7],
  [Days 1--3: salary, bond, notice period, backlogs and gaps in A--F--E--F, 45 seconds each.
  Days 4--6: four puzzles a day using PAUSE, then two guesstimates.],
  [Five awkward questions cold, then one puzzle and one guesstimate, thinking aloud.],

  [6], [8, revision],
  [Days 1--4: GD entries with SPEH, the follow-up email, questions to ask, CTC vs in-hand.
  Days 5--6: all eight revision cards and the quick reference.],
  [Full mock: 10 HR questions, 2 STAR probes, 1 project defence, 1 puzzle.],
)

#section[4 · The 10-day crash plan]

Only if your interview is inside two weeks. It cuts practice volume and Tier 3 depth --- not
the structures.

#table(
  columns: (auto, auto, 1fr),
  inset: (x: 5pt, y: 3pt),
  align: (center, left, left),
  [*Day*], [*Chapters*], [*Finish that day*],

  [1], [1, 2], [The funnel and the score sheets. Fix your top five resume bullets: every one gets a number.],
  [2--3], [3], ["Tell me about yourself" in NOW--PATH--PROOF--POINT, strengths, weakness; then why us (20 minutes of real research), five years, and your two questions to ask.],
  [4--5], [4], [Story bank of 12 real events, then all 12 written in labelled STAR. Practise a 30-second and a 2-minute version of each.],
  [6], [5], [One Project Defence Sheet per resume project. Trace one request end to end, out loud.],
  [7--8], [5, 6], [The "I don't know" protocol. Then salary, bond, notice period, backlogs, gaps and CGPA --- 45 seconds each, flat voice, then silence.],
  [9], [7], [PAUSE on eight puzzles, then three guesstimates. Memorise only the anchor numbers table.],
  [10], [8, appendix], [GD with SPEH, the follow-up email, CTC vs in-hand. Then the quick reference at the back.],
)

#trap[
The crash plan fails in exactly one way: reading it silently. Every line says *out loud* or
*recorded* for a reason --- the room tests speech, not recognition.
]

#pagebreak()
