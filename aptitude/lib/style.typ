// ============================================================
//  QUANT & REASONING FOR PLACEMENTS — shared style library
//  Do not edit inside chapter files. Import and use only.
// ============================================================

#let ink      = rgb("#1a1a1a")
#let muted    = rgb("#6b6b6b")
#let rule     = rgb("#d9d9d9")
#let t1col    = rgb("#0b7285")   // Tier 1 - service
#let t2col    = rgb("#a6620a")   // Tier 2 - SE Asia
#let t3col    = rgb("#8c2f39")   // Tier 3 - product
#let warmcol  = rgb("#4a5568")   // Level 0 warm-up
#let boxbg    = rgb("#f7f7f5")
#let trapbg   = rgb("#fdf4f4")
#let trickbg  = rgb("#f3f8f4")

// ---------- book-level page setup ----------
#let book(title: "", subtitle: "", body) = {
  set document(title: title)
  set page(
    paper: "a4",
    margin: (top: 2.2cm, bottom: 2.2cm, inside: 2.4cm, outside: 1.8cm),
    numbering: "1",
    number-align: center,
  )
  set text(font: ("Liberation Serif", "DejaVu Serif"), size: 10.5pt, fill: ink, lang: "en")
  set par(justify: true, leading: 0.62em, spacing: 0.95em)
  set heading(numbering: none)
  show math.equation: set text(font: "New Computer Modern Math", size: 10.5pt)
  show raw: set text(font: ("DejaVu Sans Mono"), size: 9pt)
  set table(stroke: 0.4pt + rule, inset: 6pt)
  show table: set text(size: 9.5pt)
  body
}

// ---------- invisible outline marker (feeds the table of contents) ----------
// Renders nothing. It only registers a level-1 heading so outline() can find it.
#let toc-entry(title) = place(hide(heading(level: 1, title)))

// ---------- chapter opener ----------
#let chapter(num: 0, title: "", tagline: "", body) = {
  pagebreak(weak: true)
  toc-entry[Chapter #num · #title]
  block(width: 100%, inset: (bottom: 10pt))[
    #text(size: 9pt, fill: muted, weight: "bold", tracking: 1.5pt)[CHAPTER #num]
    #v(-4pt)
    #text(size: 22pt, weight: "bold")[#title]
    #if tagline != "" [ #v(-3pt) #text(size: 10pt, fill: muted, style: "italic")[#tagline] ]
  ]
  line(length: 100%, stroke: 1.2pt + ink)
  v(6pt)
  body
}

#let section(title) = {
  v(8pt)
  block(breakable: false)[
    #text(size: 13pt, weight: "bold")[#title]
    #v(-5pt)
    #line(length: 100%, stroke: 0.6pt + rule)
  ]
  v(2pt)
}

#let subsection(title) = {
  v(5pt)
  text(size: 11pt, weight: "bold")[#title]
  v(2pt)
}

// ---------- the formula / concept box ----------
#let formulas(title: "What you need to know", body) = {
  block(
    width: 100%, fill: boxbg, inset: 10pt, radius: 3pt,
    stroke: (left: 2.5pt + ink, rest: 0.4pt + rule),
    breakable: true,
  )[
    #text(size: 9pt, weight: "bold", tracking: 1pt, fill: muted)[#upper(title)]
    #v(1pt)
    #body
  ]
  v(4pt)
}

// ---------- tier badge ----------
#let tier-meta = (
  (warmcol, "WARM-UP", "build the reflex"),
  (t1col,   "TIER 1",  "TCS NQT · Accenture · Infosys · Wipro · Capgemini"),
  (t2col,   "TIER 2",  "Singapore & Thailand · Grab · Shopee · GIC · DBS · Agoda · SCB"),
  (t3col,   "TIER 3",  "Google · Amazon · Microsoft · Goldman Sachs · D. E. Shaw · Adobe"),
)

#let tier-header(t) = {
  let (c, label, who) = tier-meta.at(t)
  v(9pt)
  block(width: 100%, breakable: false)[
    #block(fill: c, inset: (x: 7pt, y: 3pt), radius: 2pt)[
      #text(size: 8.5pt, weight: "bold", fill: white, tracking: 1pt)[#label]
    ]
    #h(6pt)
    #text(size: 8.5pt, fill: muted)[#who]
    #v(-4pt)
    #line(length: 100%, stroke: 0.8pt + c)
  ]
  v(3pt)
}

// ---------- worked example ----------
// asked: short provenance string, e.g. "TCS NQT pattern" or "Google · pattern"
#let ex(n, tier: 1, asked: "", body) = {
  let c = tier-meta.at(tier).at(0)
  v(5pt)
  block(width: 100%, breakable: true)[
    #text(weight: "bold", fill: c)[Example #n]
    #if asked != "" [ #h(5pt) #text(size: 8pt, fill: muted)[\[#asked\]] ]
    #v(2pt)
    #body
  ]
}

#let sol(body) = {
  block(width: 100%, inset: (left: 9pt), stroke: (left: 1.2pt + rule))[
    #text(size: 9pt, weight: "bold", fill: muted, tracking: 0.8pt)[SOLUTION]
    #v(1pt)
    #body
  ]
}

#let ans(body) = {
  v(2pt)
  box(fill: rgb("#eef2ee"), inset: (x: 6pt, y: 3pt), radius: 2pt)[
    #text(weight: "bold", size: 10pt)[Answer: #body]
  ]
}

// ---------- pedagogy boxes ----------
#let trick(body) = {
  v(4pt)
  block(width: 100%, fill: trickbg, inset: 8pt, radius: 3pt,
        stroke: (left: 2pt + rgb("#2f6b3f"), rest: none), breakable: true)[
    #text(size: 8.5pt, weight: "bold", fill: rgb("#2f6b3f"), tracking: 1pt)[SHORTCUT]
    #v(1pt) #body
  ]
}

#let trap(body) = {
  v(4pt)
  block(width: 100%, fill: trapbg, inset: 8pt, radius: 3pt,
        stroke: (left: 2pt + rgb("#9b2226"), rest: none), breakable: true)[
    #text(size: 8.5pt, weight: "bold", fill: rgb("#9b2226"), tracking: 1pt)[TRAP]
    #v(1pt) #body
  ]
}

#let note(body) = {
  v(3pt)
  block(width: 100%, inset: (left: 8pt), stroke: (left: 1.5pt + muted))[
    #text(size: 9.5pt, fill: muted)[#body]
  ]
  v(3pt)
}

// ---------- practice set + answer key ----------
#let practice(tier: 1, time: "", body) = {
  let (c, label, _) = tier-meta.at(tier)
  v(7pt)
  block(width: 100%, breakable: true, inset: 9pt, radius: 3pt,
        stroke: 0.7pt + c, fill: white)[
    #text(size: 9pt, weight: "bold", fill: c, tracking: 1pt)[PRACTICE · #label]
    #if time != "" [ #h(6pt) #text(size: 8.5pt, fill: muted)[target: #time] ]
    #v(3pt)
    #body
  ]
}

#let key(body) = {
  v(5pt)
  block(width: 100%, fill: boxbg, inset: 8pt, radius: 3pt, breakable: true)[
    #text(size: 8.5pt, weight: "bold", fill: muted, tracking: 1pt)[ANSWER KEY]
    #v(1pt) #text(size: 9pt)[#body]
  ]
}

// ---------- end-of-chapter revision card ----------
#let revision(body) = {
  pagebreak(weak: true)
  block(width: 100%, inset: 11pt, radius: 4pt, stroke: 1.2pt + ink, fill: boxbg)[
    #text(size: 11pt, weight: "bold", tracking: 1pt)[ONE-PAGE REVISION CARD]
    #v(-3pt) #line(length: 100%, stroke: 0.5pt + rule) #v(3pt)
    #body
  ]
}

// ---------- small helpers ----------
#let opts(a, b, c, d) = {
  v(2pt)
  grid(columns: (1fr, 1fr, 1fr, 1fr), gutter: 5pt,
    [(a) #a], [(b) #b], [(c) #c], [(d) #d])
  v(2pt)
}
