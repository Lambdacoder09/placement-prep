# Placement Prep — a five-book series

Self-study books for campus and lateral hiring, written so a student can work through them
**without a teacher**: few words, many fully worked examples, every step shown.

| # | Book | Covers | Size |
|---|---|---|---|
| 1 | [`aptitude/`](aptitude) · [PDF](pdf/1-aptitude.pdf) | Quant, logical reasoning, DI, data sufficiency, 5 mock papers | 24 ch · **456 pp** |
| 2 | [`dsa/`](dsa) · [PDF](pdf/2-dsa.pdf) | Data structures & algorithms for the coding round (JavaScript) | 20 ch · **815 pp** |
| 3 | [`system-design/`](system-design) · [PDF](pdf/3-system-design.pdf) | LLD, design patterns, 10 HLD case studies | 12 ch · **452 pp** |
| 4 | [`cs-fundamentals/`](cs-fundamentals) · [PDF](pdf/4-cs-fundamentals.pdf) | OS, DBMS, Networks, OOP — the technical round | 12 ch · **366 pp** |
| 5 | [`interview-rounds/`](interview-rounds) · [PDF](pdf/5-interview-rounds.pdf) | Resume, HR, STAR, defending projects, puzzles, GD | 8 ch · **243 pp** |

**76 chapters · 2,332 pages · ~2,100 fully solved examples · 160 diagrams · 1,342 executed code listings.**

## The three tiers

Difficulty tiers run **inside every chapter**, so you climb easy → hard on each topic rather
than reading three separate books.

| Tier | Companies | Character |
|---|---|---|
| **1** Service (India) | TCS NQT, Accenture, Infosys, Wipro, Capgemini, Cognizant | direct, template-able, speed matters |
| **2** Singapore & Thailand | Grab, Sea/Shopee, GIC, DBS, Agoda, SCB, LINE MAN | applied, business-flavoured, 2–3 step |
| **3** Product (hardest) | Google, Amazon, Microsoft, Goldman Sachs, D. E. Shaw, Adobe, Uber | needs insight, not recall; follow-ups and trade-offs |

Books 3 and 5 redefine the tiers where the plain mapping would mislead — see each book's
`meta/CONTRACT.md`.

## Language

**JavaScript primary, Python secondary.** See [`shared/LANGUAGE-POLICY.md`](shared/LANGUAGE-POLICY.md),
including where the policy deliberately bends: OOP theory is still taught in Java/C++
vocabulary because that is how interviewers ask it, OS internals stay C-flavoured, and SQL
stays SQL.

Shared, tested helpers live in [`shared/js/toolkit.js`](shared/js/toolkit.js) — `MinHeap`,
`DSU`, `Deque`, `lowerBound`, `upperBound`. JavaScript ships no heap or ordered map, so the
whole series uses one verified implementation instead of a new one per chapter.
Run its tests with `node shared/js/test-toolkit.js`.

## Read

All five finished books are in **[`pdf/`](pdf)** at the top of this repo.

## Build

Each book builds independently and writes into `pdf/`:

    cd dsa && ./build.sh          # -> pdf/2-dsa.pdf

Requires [Typst](https://typst.app):

    curl -fsSL -o typst.tar.xz https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz
    tar -xf typst.tar.xz && cp typst-*/typst ~/.local/bin/

## Layout

    shared/lib/style.typ       all styling + helpers (#ex #sol #trick #trap #code #diagram …)
    shared/js/toolkit.js       tested JS data structures used across the series
    shared/CORE-RULES.md       authoring rules common to every book
    <book>/chapters/*.typ      canonical source, one file per chapter
    <book>/meta/CONTRACT.md    that book's binding authoring contract
    <book>/book.typ            master file (include order, TOC)

`chapters/*.typ` is the source of truth. Any `markdown/` directory is a generated export.

## On the content

**Every problem, question and answer in this series is original.** Nothing is reproduced from
R. S. Aggarwal, any other published book, or any real examination or interview paper — those
are proprietary. Labels such as `[TCS NQT pattern]` or `[Amazon · pattern]` describe the
*publicly documented shape* of a company's process, and are never a claim that a question was
actually asked there.

The interview book teaches structure and worked examples, never scripts to memorise, and
never coaches fabricating experience.

## Verification

The aptitude book's arithmetic was machine-checked: 1,364 expressions independently
recomputed, zero errors. In the DSA book every code snippet is executed with `node` before
publication. Neither check covers judgement-based content — system design trade-offs and
interview advice are reasoned positions, not provable facts. Found a mistake? The chapter
files are plain text.

## Licence

MIT — see [LICENSE](LICENSE).
