#import "../../shared/lib/style.typ": *

#toc-entry("How to use this book")

#block(width: 100%, inset: (bottom: 5pt))[
  #text(size: 22pt, weight: "bold")[How to use this book]
  #v(-3pt)
  #text(size: 10pt, fill: muted, style: "italic")[Two pages. Read them once, then start Chapter 1.]
]
#line(length: 100%, stroke: 1.2pt + ink)
#v(3pt)

#section[1 · What the tiers mean in this book]

Inside every chapter the same ladder repeats. Climb it in order --- a Tier 3 answer is
reachable only because you already wrote the Tier 1 and Tier 2 ones.

#table(
  columns: (auto, 4.6cm, 1fr, auto),
  inset: (x: 5pt, y: 3.5pt),
  align: (left, left, left, center),
  [*Tier*], [*Who asks like this*], [*What the question feels like*], [*Answer*],

  text(weight: "bold", fill: warmcol)[0 Warm-up],
  [nobody --- it is you],
  [Bare mechanics, one idea, no story. Fill the table, translate the address, name the state.],
  [1--2 lines],

  text(weight: "bold", fill: t1col)[1 Service],
  [TCS NQT & Digital, Accenture, Infosys, Wipro, Capgemini, Cognizant],
  [Definitions and standard comparisons, rapid-fire. "Process vs thread." "DELETE vs TRUNCATE." Recall and speed, not insight.],
  [3--6 lines],

  text(weight: "bold", fill: t2col)[2 SE Asia],
  [Grab, Sea/Shopee, GIC, DBS, Agoda, SCB, LINE MAN, Razer],
  [The same theory in a business suit --- a slow orders query, a double-charged wallet, a laggy API. Find the concept under the story.],
  [8--15 lines],

  text(weight: "bold", fill: t3col)[3 Product],
  [Google, Amazon, Microsoft, Goldman Sachs, D. E. Shaw, Adobe, Uber],
  [One genuine insight, then follow-ups: "now at 10x traffic", "now across two data centres", "what breaks first". Naming the trade-off *is* the answer.],
  [discussion],
)

#section[2 · What is in every chapter, and what to do with it]

#table(
  columns: (3.2cm, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,

  [*Formulas box*], [Every definition and law the chapter needs, in one block. Cover it and write it out --- this is the part you must be able to recite.],
  [*Diagrams*], [Process states, memory layout, the handshake, a B+ tree. Redraw each on blank paper; interviewers ask you to *draw*, not to describe.],
  [*Worked Q → A*], [Say your answer out loud *before* reading the solution, then mark the gap. Reading first teaches nothing.],
  [*TRAP boxes*], [The classic wrong answer and why it is wrong. These are the exact lines that lose marks. Read every one twice.],
  [*Code and SQL*], [Type it and run it --- `node f.js`, `python3 f.py`, or a real SQL shell. A concept you have executed is one you can defend.],
  [*Rapid fire*], [20--30 one-line answers per chapter. Last-week material, not first-week material.],
  [*Revision card*], [One page at the chapter end. Write it from memory when you finish the chapter; the gaps are your revision list.],
)

#section[3 · The four rules of this round]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  [*1*], [*Answer in one sentence, then stop.* Give the definition and wait. Interviewers ask the follow-up themselves; rambling turns one question into a hole.],
  [*2*], [*Every comparison needs a "because".* "TRUNCATE is faster" is half an answer. "...because it deallocates pages instead of logging each row" is the whole one.],
  [*3*], [*Draw it.* Page tables, the handshake, a deadlock cycle, a B+ tree. If you can draw it, you can explain it under pressure.],
  [*4*], [*Say "I do not know" cleanly, then reason.* "I have not used it, but from first principles it would have to..." scores far above a confident guess.],
)

#trap[
Three answers sink this round more than any others. Threads do *not* share the stack ---
code, data and heap only. Deadlock needs *all four* conditions at once, not any one of
them. And an index does *not* always make things faster --- it slows every write.
]

#pagebreak(weak: true)

#section[4 · The 6-week plan]

Two chapters a week, about two hours a day, six days a week. Day 7 is the checkpoint ---
blank paper, nothing open.

#table(
  columns: (auto, auto, 1fr, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  align: (center, center, left, left),
  [*Week*], [*Chapters*], [*Daily target*], [*Checkpoint (day 7)*],

  [1], [1, 2],
  [Ch 1 on days 1--3: state diagram, then every scheduling algorithm with the Gantt arithmetic done in full. Ch 2 on days 4--6.],
  [Draw the process state diagram and the four deadlock conditions from memory.],

  [2], [3, 4],
  [Ch 3 days 1--3 --- paging, TLB, and every page-replacement algorithm worked by hand. Ch 4 days 4--6, including the disk-seek arithmetic.],
  [Translate three virtual addresses, then run one FIFO, one LRU and one Optimal trace.],

  [3], [5, 6],
  [Ch 5 with a real SQL shell open --- type every query. Ch 6 days 4--6: attribute closure until it is automatic, then 1NF to BCNF decompositions.],
  [Find all candidate keys of a fresh relation, then normalise it to BCNF.],

  [4], [7, 8],
  [Ch 7: the four isolation levels and exactly which anomaly each one stops. Ch 8: B+ tree structure, `EXPLAIN` reading, and when an index hurts.],
  [Write the isolation-versus-anomaly grid from memory, then justify three index choices.],

  [5], [9, 10],
  [Ch 9: subnetting until you no longer need the table. Ch 10: handshake, congestion control with the numbers, HTTP/1.1 vs 2 vs 3.],
  [Subnet one block four ways, then draw the handshake and the close, labelling every state.],

  [6], [11, 12],
  [Ch 11: the four pillars in Java/C++ vocabulary as well as the JS reality. Ch 12: compilation stages, memory layout, git internals.],
  [Overloading vs overriding, abstract vs interface, merge vs rebase --- out loud, under a minute each.],
)

#section[5 · The 10-day crash plan]

Use this only if the interview is inside two weeks. It cuts practice volume, not topics.
About four hours a day. Each day: read the formulas box, work the Tier 1 items, read every
TRAP box, then the rapid-fire list.

#table(
  columns: (auto, auto, 1fr, 1fr),
  inset: (x: 5pt, y: 3pt),
  align: (center, center, left, left),
  [*Day*], [*Ch*], [*Priority inside the chapter*], [*Must be able to do by tonight*],

  [1], [1], [Process vs thread, state diagram, all scheduling algorithms.], [Average waiting time under FCFS, SJF, SRTF and RR.],
  [2], [2], [Race condition, mutex vs semaphore, the four deadlock conditions.], [Banker's algorithm on a small table.],
  [3], [3], [Paging, TLB, page faults, the replacement algorithms.], [Effective access time, and an LRU trace.],
  [4], [4], [Inodes, hard vs soft link, the disk-scheduling algorithms.], [Total head movement for SCAN and C-SCAN.],
  [5], [5], [Keys, all join types, `GROUP BY` vs `HAVING`, NULL logic.], [Write a three-table join with an aggregate, first try.],
  [6], [6], [Attribute closure, candidate keys, 2NF / 3NF / BCNF.], [Normalise a given relation and say which rule broke.],
  [7], [7, 8], [ACID and the isolation grid; then B+ trees and selectivity.], [Name the anomaly each level stops, and when an index hurts.],
  [8], [9], [OSI vs TCP/IP, subnetting, ARP, DNS resolution order.], [Subnet a /24 into six usable networks.],
  [9], [10], [Handshake, TCP vs UDP, HTTP methods and status codes, TLS.], [Draw the handshake and explain why `TIME_WAIT` exists.],
  [10], [11, 12], [Four pillars, overloading vs overriding; memory layout, git.], [Read the whole Quick Reference appendix at the back of this book.],
)

#note[
*The last hour before the interview:* the Quick Reference appendix only, plus the revision
cards of your two weakest chapters. Nothing new. Nothing long.
]

#pagebreak()
