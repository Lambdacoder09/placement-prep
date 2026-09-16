# BOOK 4 — CS FUNDAMENTALS (OS, DBMS, Networks, OOP)
Read ../shared/CORE-RULES.md first. It is binding.

## What this book is for
The technical round where an interviewer asks core-subject questions rapid-fire. Service
companies ask these HEAVILY - often more than DSA. Product companies ask fewer but deeper.

## Format: this book is Q&A-dense
Most content is question -> crisp answer -> a worked example or diagram. Use #ex for the
question and #sol for the answer. A Tier-1 answer is 3-6 lines. A Tier-3 answer goes deeper
and names the trade-off.


## Language
Read ../shared/LANGUAGE-POLICY.md — it is binding.
**JavaScript primary, Python secondary.** Not C++, not Java (except where the policy's
"where this policy bends" section explicitly allows it to illustrate OOP/OS concepts).
Every snippet must be run with `node` or `python3` before you publish it.

## Required per chapter
- #formulas[] box holding the definitions/laws the chapter needs
- at least 2 #diagram[] figures (process states, memory layout, TCP handshake, B+ tree, ...)
- real SQL / JavaScript / shell where relevant, and it must be CORRECT. Run every JS
  snippet with `node` before publishing; check SQL logic by hand. SQL stays SQL.
- For the OOP chapter specifically: teach the concept, show the JS reality, AND state what
  the Java/C++ answer is — service-company interviewers ask OOP in Java/C++ vocabulary and
  a JS-only answer fails that round. See the LANGUAGE-POLICY "where this policy bends".
- a "one-liner answers" rapid-fire section: 20-30 Q->A pairs for last-minute revision
- #trap[] boxes for the classic wrong answers (e.g. "deadlock needs all 4 conditions",
  "DELETE vs TRUNCATE vs DROP", "process vs thread memory")
