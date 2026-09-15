// ============================================================
//  DATA STRUCTURES & ALGORITHMS FOR THE CODING ROUND
//  Master file. Compile with:  typst compile --root / book.typ
//  or just run ./build.sh
// ============================================================

#import "../shared/lib/style.typ": *

#show: book.with(
  title: "Data Structures & Algorithms for the Coding Round",
  subtitle: "JavaScript first · Tier 1 Indian service companies · Tier 2 Singapore & Thailand · Tier 3 global product companies",
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

// ---------- Part I · Arrays, searching and sorting ----------

#include "chapters/ch01-complexity-analysis.typ"
#include "chapters/ch02-arrays-prefix-sums.typ"
#include "chapters/ch03-two-pointers-sliding-window.typ"
#include "chapters/ch04-binary-search.typ"
#include "chapters/ch05-sorting-comparators.typ"
#include "chapters/ch06-strings.typ"
#include "chapters/ch07-hashing.typ"

// ---------- Part II · Linear structures ----------

#include "chapters/ch08-stacks-monotonic.typ"
#include "chapters/ch09-queues-deques.typ"
#include "chapters/ch10-linked-lists.typ"

// ---------- Part III · Recursion, trees and heaps ----------

#include "chapters/ch11-recursion-backtracking.typ"
#include "chapters/ch12-trees.typ"
#include "chapters/ch13-bst.typ"
#include "chapters/ch14-heaps.typ"

// ---------- Part IV · Graphs ----------

#include "chapters/ch15-graphs-1.typ"
#include "chapters/ch16-graphs-2.typ"

// ---------- Part V · Dynamic programming, greedy and maths ----------

#include "chapters/ch17-dp-1.typ"
#include "chapters/ch18-dp-2.typ"
#include "chapters/ch19-greedy-intervals.typ"
#include "chapters/ch20-bits-math.typ"

// ---------- back matter ----------

#include "chapters/back-02-js-toolkit.typ"
