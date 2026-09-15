// ============================================================
//  QUANT, APTITUDE & REASONING FOR PLACEMENTS
//  Master file. Compile with:  typst compile --root . book.typ
// ============================================================

#import "lib/style.typ": *

#show: book.with(
  title: "Quant, Aptitude & Reasoning for Placements",
  subtitle: "Tier 1 Indian service companies · Tier 2 Singapore & Thailand · Tier 3 global product companies",
)

// ---------- front matter ----------

#set page(numbering: none)
#include "chapters/front-00-title.typ"
#set page(numbering: "1")

// ---------- table of contents ----------

#block(width: 100%, inset: (bottom: 8pt))[
  #text(size: 22pt, weight: "bold")[Contents]
]
#line(length: 100%, stroke: 1.2pt + ink)
#v(8pt)

#show outline.entry: it => {
  v(1.5pt, weak: true)
  it
}

#outline(title: none, depth: 1, indent: 0pt)

#pagebreak(weak: true)

#include "chapters/front-01-howto.typ"

// ---------- Part I · Quantitative Aptitude ----------

#include "chapters/ch01-numbers-number-system.typ"
#include "chapters/ch02-percentages.typ"
#include "chapters/ch03-ratio-proportion.typ"
#include "chapters/ch04-averages-mixtures.typ"
#include "chapters/ch05-profit-loss.typ"
#include "chapters/ch06-interest.typ"
#include "chapters/ch07-time-speed-distance.typ"
#include "chapters/ch08-time-work.typ"
#include "chapters/ch09-permutations-combinations.typ"
#include "chapters/ch10-probability.typ"
#include "chapters/ch11-algebra.typ"
#include "chapters/ch12-geometry-mensuration.typ"

// ---------- Part II · Logical Reasoning ----------

#include "chapters/ch13-series.typ"
#include "chapters/ch14-coding-decoding.typ"
#include "chapters/ch15-blood-relations-directions.typ"
#include "chapters/ch16-seating-arrangement.typ"
#include "chapters/ch17-syllogisms.typ"
#include "chapters/ch18-critical-reasoning.typ"
#include "chapters/ch19-analogy-nonverbal.typ"
#include "chapters/ch20-clocks-calendars-puzzles.typ"

// ---------- Part III · Data Interpretation & Test Craft ----------

#include "chapters/ch21-di-charts.typ"
#include "chapters/ch22-di-caselets.typ"
#include "chapters/ch23-data-sufficiency.typ"
#include "chapters/ch24-mock-papers.typ"

// ---------- back matter ----------

#include "chapters/back-01-speed-arithmetic.typ"
#include "chapters/back-02-formula-index.typ"
