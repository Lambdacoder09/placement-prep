// ============================================================
//  CS FUNDAMENTALS FOR THE TECHNICAL ROUND
//  Master file. Compile with:  typst compile --root / book.typ
//  or just run ./build.sh
// ============================================================

#import "../shared/lib/style.typ": *

#show: book.with(
  title: "CS Fundamentals for the Technical Round",
  subtitle: "Operating systems · Databases · Networks · OOP and dev fundamentals",
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

// ---------- Part I · Operating systems ----------

#include "chapters/ch01-os-processes.typ"
#include "chapters/ch02-os-sync-deadlock.typ"
#include "chapters/ch03-os-memory.typ"
#include "chapters/ch04-os-filesystems.typ"

// ---------- Part II · Databases ----------

#include "chapters/ch05-dbms-sql.typ"
#include "chapters/ch06-dbms-normalisation.typ"
#include "chapters/ch07-dbms-transactions.typ"
#include "chapters/ch08-dbms-indexing.typ"

// ---------- Part III · Networks ----------

#include "chapters/ch09-net-ip-routing.typ"
#include "chapters/ch10-net-tcp-http.typ"

// ---------- Part IV · OOP and dev fundamentals ----------

#include "chapters/ch11-oop.typ"
#include "chapters/ch12-dev-fundamentals.typ"

// ---------- back matter ----------

#include "chapters/back-01-quick-reference.typ"
