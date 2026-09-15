# BOOK 3 — SYSTEM DESIGN (LLD + HLD)
Read /home/zayed/books/shared/CORE-RULES.md first. It is binding.

## Tier meaning is DIFFERENT in this book — use this mapping
| Tier | What it means here | Who asks it |
|---|---|---|
| 1 | OOP & Low-Level Design: classes, SOLID, design patterns, a small working design | TCS, Accenture, Infosys, Capgemini, Cognizant |
| 2 | Mid-scale HLD: one service done properly - API, schema, caching, a few thousand RPS | Grab, Shopee, GIC, DBS, Agoda |
| 3 | Large-scale distributed: sharding, consensus, CAP trade-offs, multi-region, failure modes | Google, Amazon, Microsoft, Uber |

## Every design walks the SAME 7 steps — never skip one
1. Clarify (the questions to ask back, and why each one changes the design)
2. Scale estimate (actual numbers: DAU -> QPS -> storage/yr -> bandwidth; show the arithmetic)
3. API surface (concrete endpoints with payloads)
4. Data model (tables/collections with fields and the chosen key)
5. Architecture diagram (use #diagram with #dnode/#darrow — REQUIRED, at least one per design)
6. Deep dive on the 1-2 genuinely hard parts
7. Trade-offs, failure modes, and what you would do differently at 10x


## Language
Read /home/zayed/books/shared/LANGUAGE-POLICY.md — it is binding.
**JavaScript primary, Python secondary.** Not C++, not Java (except where the policy's
"where this policy bends" section explicitly allows it to illustrate OOP/OS concepts).
Every snippet must be run with `node` or `python3` before you publish it.

## Rules
- Numbers must be arithmetically real. Show the calculation: "50M DAU x 20 req = 1B/day
  = 1B/86400 ~ 11,600 QPS average, 3x peak ~ 35,000 QPS".
- Every trade-off names BOTH sides and a decision. Never "it depends" with no choice made.
- LLD chapters include real runnable **JavaScript** class skeletons (ES2022 classes).
  Run every snippet with `node` before publishing. Python second where it is clearer.
- At least 2 diagrams per HLD chapter.

## Chapter structure
#section[The idea in one page] -> #section[Warm-up] -> Tier 1 (LLD) -> Tier 2 (mid-scale)
-> Tier 3 (large-scale) -> #section[Interview drill] (what the interviewer pushes on, and
the answer) -> #practice + #key -> #revision[] (checklist + numbers to memorise)
