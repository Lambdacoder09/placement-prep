# CORE RULES — apply to every book in this series

## Prime directive
Fewer words, more worked examples. Prose under 15% of the chapter. Grade-8 English, short
sentences, written for a student with NO teacher and possibly not a native English speaker.
Never write "obviously", "clearly", "left as an exercise", or skip steps in a solution.

## Originality — non-negotiable
Every problem, question and answer is ORIGINAL, written by you. Never copy from any
published book, course, or real exam/interview paper. Real company interview questions are
proprietary. Label provenance as a PATTERN only: `asked: "Amazon · pattern"`. Never claim
a question was actually asked at a real company.

## The three tiers — a student climbs these INSIDE every chapter
| Tier | Companies | Character |
|---|---|---|
| 0 Warm-up | — | bare mechanics, one idea per question |
| 1 Service (India) | TCS NQT/Digital, Accenture, Infosys, Wipro, Capgemini, Cognizant | standard, well-known, template-able |
| 2 SE Asia | Grab, Sea/Shopee, GIC, DBS, Agoda, SCB, LINE MAN, Razer | applied, business-flavoured, 2-3 step |
| 3 Product (hardest) | Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe, Uber | needs insight; follow-ups; trade-off discussion |

The climb must be REAL: a Tier-3 item should feel reachable because of the Tier-2 ones.

## Typst
Import: `#import "../../shared/lib/style.typ": *`
Compile: `export PATH="$HOME/.local/bin:$PATH"; typst compile --root / <file> /tmp/c.pdf`
Helpers: #chapter #section #subsection #formulas #tier-header(0..3) #ex(n, tier:, asked:)
#sol #ans #trick #trap #note #practice(tier:, time:) #key #revision #opts
#code(lang:, caption:)[```lang ... ```]  #complexity(time:, space:, note:)
#approach(n, "name", verdict:)  #diagram(height:, caption:)[ #dnode(...) #darrow(...) ]
Math is TYPST not LaTeX: $a/b$, $sqrt(x)$, $sum_(i=1)^n$, $O(n log n)$, $<=$, $!=$, $times$.
NEVER use \frac, \begin, $$. It will not compile.
Diagrams: #dnode(x, y, w, h, "label", fill: ...) and #darrow(x1,y1,x2,y2, label: "...").
Coordinates are lengths from the block's top-left, e.g. 0pt, 3cm. Keep inside the height.

## File naming
`chapters/chNN-slug.typ`. Compile-check your own file and fix EVERY error before finishing.
