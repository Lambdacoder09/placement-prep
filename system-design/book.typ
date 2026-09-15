// ============================================================
//  SYSTEM DESIGN FOR INTERVIEWS — LLD AND HLD
//  Master file. Compile with:  typst compile --root / book.typ
//  or just run ./build.sh
// ============================================================

#import "../shared/lib/style.typ": *

#show: book.with(
  title: "System Design for Interviews — LLD and HLD",
  subtitle: "Tier 1 low-level design · Tier 2 mid-scale HLD · Tier 3 large-scale distributed systems",
)

// ---------- front matter ----------

#set page(numbering: none)
#include "chapters/front-00-title.typ"
#set page(numbering: "1")
#counter(page).update(1)

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

// ---------- Part I · The procedure and the arithmetic ----------

#include "chapters/ch01-how-to-run-the-interview.typ"
#include "chapters/ch02-estimation.typ"

// ---------- Part II · Low-level design ----------

#include "chapters/ch03-oop-solid.typ"
#include "chapters/ch04-design-patterns.typ"
#include "chapters/ch05-classic-lld.typ"

// ---------- Part III · The building blocks ----------

#include "chapters/ch06-databases.typ"
#include "chapters/ch07-caching.typ"
#include "chapters/ch08-load-balancing-api.typ"
#include "chapters/ch09-queues-streams.typ"
#include "chapters/ch10-replication-sharding.typ"

// ---------- Part IV · High-level design case studies ----------

#include "chapters/ch11-hld-case-studies-1.typ"
#include "chapters/ch12-hld-case-studies-2.typ"

// ---------- back matter ----------

#include "chapters/back-01-quick-reference.typ"
