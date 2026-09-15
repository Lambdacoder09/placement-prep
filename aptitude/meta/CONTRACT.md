# AUTHORING CONTRACT — read fully before writing a single line

You are writing one chapter of **"Quant, Aptitude & Reasoning for Placements"** — a
self-study book for students preparing for company hiring tests. Think R.S. Aggarwal's
density of solved problems, but modern, tiered by company difficulty, and written so a
student with **no teacher** can learn from it alone.

## THE PRIME DIRECTIVE: fewer words, more solved examples

- Explanation prose must be **under 15% of the chapter**. If you are writing a paragraph,
  ask whether a worked example would teach it better. It usually would.
- **Never** write "as we can clearly see", "it is obvious that", "left as an exercise",
  "using the standard formula" without showing the formula.
- Every solution shows **every arithmetic step**. A student who is stuck must be able to
  find the exact line where they diverged. Do not skip from line 2 to line 5.
- Sentences short. Grade-8 English. The reader may not be a native English speaker.
- No motivational filler, no "let's dive in", no chapter pep talk.

## ORIGINALITY — non-negotiable

Write **original problems**. Do NOT copy questions from R.S. Aggarwal, any published book,
or any real exam paper. Real proprietary papers (TCS NQT, Accenture, etc.) are not public
and must not be reproduced. You write NEW problems that match the documented *pattern*,
*difficulty*, and *topic mix* of those exams. Label provenance honestly as a pattern:
`asked: "TCS NQT pattern"`, `asked: "Grab · pattern"`, `asked: "Goldman Sachs · pattern"`.
Never write "actual 2023 paper" or similar. Never claim a question was on a real test.

## THE THREE TIERS (a student climbs these INSIDE every chapter)

| Tier | Who | Character of the questions |
|---|---|---|
| 0 Warm-up | nobody — it's you | Bare mechanics. One idea per question. Builds the reflex. |
| 1 Service (India) | TCS NQT, Accenture, Infosys, Wipro, Capgemini, Cognizant | Direct formula use, light 2-step word problems. Speed matters more than depth. 45–75 s/question. Clean numbers. |
| 2 SE Asia | Grab, Sea/Shopee, GIC, DBS, Agoda, SCB, LINE MAN, Razer | 2–3 step reasoning, mixed topics in one question, data-driven and business-flavoured (fares, orders, FX, logistics). Often no options given. 90–120 s. |
| 3 Product (hardest) | Google, Amazon, Microsoft, Goldman Sachs, D. E. Shaw, Adobe, Uber | Needs insight, not recall. Counting arguments, invariants, expectation, tight bounds, estimation, proof-flavoured reasoning. 3–6 min. Often asked aloud in interview. |

**The climb is the whole point.** Tier 1 → Tier 2 → Tier 3 examples in a chapter must
visibly build on each other. A Tier-3 example should feel reachable *because* the student
just did the Tier-2 ones.

## REQUIRED CHAPTER STRUCTURE — follow exactly, in this order

```
#import "../lib/style.typ": *

#chapter(num: N, title: "Chapter Title", tagline: "one line, max 9 words")[

#section[What you need to know]
  #formulas[ ... every formula the chapter needs, in a compact list/table ... ]
  // target: fits on ONE page. No derivations here. Derivations go in examples.

#section[Warm-up]
  #tier-header(0)
  // 6-8 #ex(n, tier: 0) — bare mechanics, 1-2 line solutions

#section[Tier 1 — Service companies]
  #tier-header(1)
  // 10-12 #ex(n, tier: 1, asked: "...") fully solved
  // at least 2 #trick[] and 2 #trap[] spread through
  #practice(tier: 1, time: "60 s/Q")[ 12-15 questions ]
  #key[ answers with a 1-line reason each ]

#section[Tier 2 — Singapore & Thailand]
  #tier-header(2)
  // 8-10 #ex(n, tier: 2, asked: "...") fully solved
  #practice(tier: 2, time: "100 s/Q")[ 10-12 questions ]
  #key[ ... ]

#section[Tier 3 — Product companies]
  #tier-header(3)
  // 6-8 #ex(n, tier: 3, asked: "...") fully solved — these get LONGER solutions,
  // and each must state the *insight* in one bold line before the algebra
  #practice(tier: 3, time: "4 min/Q")[ 6-8 questions ]
  #key[ answers with a real explanation, 2-4 lines each ]

#section[Mixed set — exam conditions]
  #practice(tier: 1, time: "...")[ 15-20 questions, tiers shuffled, no tier labels ]
  #key[ ... ]

#revision[ one-page card: every formula + every shortcut + the top 5 traps ]
]
```

**Example numbering restarts at 1 in each chapter and runs continuously across all tiers.**

## TYPST SYNTAX YOU MAY USE (and nothing else)

Helpers: `#chapter`, `#section`, `#subsection`, `#formulas`, `#tier-header(0..3)`,
`#ex(n, tier: t, asked: "...")`, `#sol[...]`, `#ans[...]`, `#trick[...]`, `#trap[...]`,
`#note[...]`, `#practice(tier: t, time: "...")`, `#key[...]`, `#revision[...]`,
`#opts(a,b,c,d)`.

Math is **Typst math, not LaTeX**:
- `$x^2$`, `$x_1$`, `$sqrt(x)$`, `$root(3, x)$`
- fraction: `$a/b$` or `$frac(a,b)$` — NOT `\frac{a}{b}`
- `$sum_(i=1)^n i$`, `$product$`, `$integral$`
- `$times$` `$div$` `$<=$` `$>=$` `$!=$` `$approx$` `$therefore$`
- `$binom(n,k)$`, `$n!$`, `$P(A|B)$` → write `$P(A bar B)$`
- text inside math: `$"speed" = "distance"/"time"$`
- display math: `$ x = 5 $` (spaces inside the dollars) vs inline `$x=5$`
- **Percent sign in normal text must be escaped: `15%` is fine in Typst markup, but
  inside `#ex(...)[...]` content blocks write it plainly as `15%`. Never write `\%`.**
- Currency: write `Rs.~2,400`, `S\$1,200`, `THB~4,500`, `\$500` (escape the dollar sign
  in text as `\$`).

Tables: `#table(columns: 3, [..],[..],[..])`. Lists: `- item` or `+ item`.

**Do not** use `\frac`, `\begin{...}`, `\\`, `$$...$$`, or any LaTeX command. It will not
compile.

## QUALITY BAR — every single problem

1. **The arithmetic must be correct.** Work it twice. A book with wrong answers is worthless.
2. The answer key must match the solution shown.
3. Numbers should be realistic (a person's speed is not 400 km/h; a salary is not Rs. 12).
4. Names/contexts: use a natural mix — Indian, Singaporean, Thai, and neutral names, since
   the book spans those markets. Never stereotype.
5. If a question has options, exactly one must be right and the distractors must each
   correspond to a *specific plausible mistake* — then name that mistake in the key.

## WHAT TO NAME YOUR FILE

`chapters/chNN-slug.typ` — e.g. `chapters/ch03-ratio-proportion.typ`. Nothing else.

## BEFORE YOU FINISH

Compile-check your own file:
```
export PATH="$HOME/.local/bin:$PATH"
typst compile --root . chapters/chNN-slug.typ /tmp/t.pdf
```
Fix every error until it compiles clean. Report the page count.
