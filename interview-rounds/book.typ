// ============================================================
//  THE INTERVIEW ROUNDS — HR, BEHAVIOURAL, PROJECTS & PUZZLES
//  Master file. Compile with:  typst compile --root / book.typ
//  or just run ./build.sh
// ============================================================

#import "../shared/lib/style.typ": *

#show: book.with(
  title: "The Interview Rounds — HR, Behavioural, Projects & Puzzles",
  subtitle: "Tier 1 standard HR screens · Tier 2 cross-border rounds · Tier 3 structured behavioural interviews",
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

// ---------- chapters ----------

#include "chapters/ch01-how-hiring-works.typ"
#include "chapters/ch02-resume-profile.typ"
#include "chapters/ch03-core-hr-questions.typ"
#include "chapters/ch04-star-behavioural.typ"
#include "chapters/ch05-defending-your-project.typ"
#include "chapters/ch06-hard-questions.typ"
#include "chapters/ch07-puzzles-guesstimates.typ"
#include "chapters/ch08-gd-communication.typ"

// ---------- back matter ----------

#include "chapters/back-01-quick-reference.typ"
