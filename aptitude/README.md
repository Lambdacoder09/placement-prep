# Quant, Aptitude & Reasoning for Placements

A 456-page self-study book — 24 chapters, 888 fully solved examples, ~2,370 practice
questions (3,258 problems total). Built for a student working **without a teacher**.

## Read it

    build/quant-reasoning-book.pdf     <- the book (456 pp)

## The three tiers

The difficulty tiers live *inside every chapter*, so you climb easy -> hard on each topic
rather than reading three separate books.

| Tier | Companies | Character | Pace |
|---|---|---|---|
| Warm-up | — | bare mechanics, one idea per question | — |
| **Tier 1** — Service (India) | TCS NQT, Accenture, Infosys, Wipro, Capgemini, Cognizant | direct formula, light 2-step word problems | 45–75 s/Q |
| **Tier 2** — Singapore & Thailand | Grab, Sea/Shopee, GIC, DBS, Agoda, SCB, LINE MAN | 2–3 step, business-flavoured, often no options | 90–120 s/Q |
| **Tier 3** — Product (hardest) | Google, Amazon, Microsoft, Goldman Sachs, D. E. Shaw, Adobe, Uber | needs insight, not recall; counting, invariants, expectation, bounds | 3–6 min/Q |

## Structure

- **Part I — Quantitative Aptitude** (ch. 1–12)
- **Part II — Logical Reasoning** (ch. 13–20)
- **Part III — DI, Data Sufficiency & 5 full mock papers** (ch. 21–24)
- Appendix A — speed arithmetic (tables, squares, cubes, fraction/% conversions)
- Appendix B — master formula index (~420 formulas, revise the whole book from it)

Every chapter: one-page formula box -> warm-up -> Tier 1 -> Tier 2 -> Tier 3, each tier
with solved examples then a timed practice set with a worked answer key, plus SHORTCUT and
TRAP boxes, a mixed exam-conditions set, and a one-page revision card.

## Build it

    ./build.sh                         # -> build/quant-reasoning-book.pdf

Requires Typst (`~/.local/bin/typst`). Install:

    curl -fsSL -o typst.tar.xz https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz
    tar -xf typst.tar.xz && cp typst-*/typst ~/.local/bin/

## Layout

    book.typ                 master file (include order, TOC)
    lib/style.typ            all styling + the #ex/#sol/#trick/#trap/#practice helpers
    chapters/*.typ           canonical source, one file per chapter
    markdown/*.md            portable Markdown export (+ BOOK.md, everything in one file)
    meta/CONTRACT.md         the authoring rules every chapter obeys
    meta/BLUEPRINT.md        chapter-by-chapter topic coverage
    build/typ2md.py          regenerates markdown/ from chapters/

`chapters/*.typ` is the source of truth. `markdown/` is a generated export — regenerate it
with `python3 build/typ2md.py` after editing a chapter. Math in the Markdown export stays in
Typst notation (`$a/b$`, `$sum_(i=1)^n$`) with common operators mapped to LaTeX.

## Editing

To change how the whole book looks, edit `lib/style.typ` — never restyle inside a chapter.
To add a chapter: write `chapters/chNN-slug.typ` following `meta/CONTRACT.md`, then add an
`#include` line to `book.typ`.

## On the problems

**Every problem in this book is original.** Nothing is copied from R. S. Aggarwal, from any
other published book, or from any real examination paper. Real company test papers (TCS NQT,
Accenture, Grab and the rest) are proprietary and are not reproduced here.

Labels such as `[TCS NQT pattern]` or `[Goldman Sachs · pattern]` describe the *publicly
documented shape* of that company's test — its topic mix, difficulty and time pressure — and
are never a claim that the question appeared on a real test.

## Verification done

- All 24 chapters carry all 4 tiers, a revision card, and a key for every practice set.
- Every chapter compiles clean; the full book builds with zero Typst errors or warnings.
- 1,364 machine-checkable arithmetic expressions were independently recomputed: 0 errors.
- Worked-solution logic and answer keys were reviewed by a second agent per chapter.

Machine checking covers arithmetic, not problem *setup* or the reasoning chapters' logic.
If you hit a questionable answer, the chapter file is plain text — fix it and rebuild.
