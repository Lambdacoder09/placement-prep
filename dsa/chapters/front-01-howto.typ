#import "../../shared/lib/style.typ": *

#toc-entry("How to use this book")

#block(width: 100%, inset: (bottom: 8pt))[
  #text(size: 22pt, weight: "bold")[How to use this book]
  #v(-3pt)
  #text(size: 10pt, fill: muted, style: "italic")[Read these two pages once. Then start Chapter 1.]
]
#line(length: 100%, stroke: 1.2pt + ink)
#v(6pt)

#section[1 · What the three tiers mean]

Every chapter has the same four blocks. You climb them in order, *inside* the chapter.

#table(
  columns: (auto, auto, 1fr, auto),
  inset: (x: 5pt, y: 4.5pt),
  align: (left, left, left, center),
  [*Tier*], [*Companies*], [*What the questions feel like*], [*Time / Q*],

  text(weight: "bold", fill: warmcol)[0 Warm-up],
  [nobody --- it is you],
  [Bare mechanics. One idea per question, no story around it. You are building the reflex for the template, not being tested.],
  [2--5 min],

  text(weight: "bold", fill: t1col)[1 Service],
  [TCS NQT, Accenture, Infosys, Wipro, Capgemini, Cognizant],
  [The standard, well-known problems. One clean pattern per question. Correctness and speed of typing matter more than insight.],
  [10--20 min],

  text(weight: "bold", fill: t2col)[2 SE Asia],
  [Grab, Sea/Shopee, GIC, DBS, Agoda, SCB, LINE MAN, Razer],
  [The same patterns wearing a business suit --- fares, orders, deliveries, trades. Two or three steps, and you must find the pattern under the story yourself.],
  [20--30 min],

  text(weight: "bold", fill: t3col)[3 Product],
  [Google, Amazon, Microsoft, Goldman Sachs, D. E. Shaw, Adobe, Uber],
  [Needs one genuine insight, not recall. Always followed by "now do it in O(1) space", "now it is a stream", "now it is distributed". The follow-up is half the interview.],
  [30--45 min],
)

#note[
Target the tier that matches the companies you are applying to --- but always work Tier 1
first, even for a product-company interview. Each Tier 3 problem in a chapter is built
directly on the Tier 1 and Tier 2 problems that come before it. Skipping the climb is what
makes the hard problems feel impossible.
]

#section[2 · What is inside every chapter]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 4.5pt),
  stroke: 0.4pt + rule,

  [*Pattern in one page*], [When to reach for this technique, the template code you will
  type over and over, and the *invariant* --- the one sentence that is true at every step.
  Learn the invariant, not the code.],

  [*The approach ladder*], [No problem jumps straight to the optimal answer. You see
  *Approach 1 — brute force*, its complexity, why it is too slow; then *Approach 2*; then
  *Approach 3 — optimal*. After the ladder, one line names the idea that unlocked the
  optimal. That line is the transferable part.],

  [*Dry run*], [One problem per chapter is traced line by line, with a table of the state
  after every single step. Work it on paper alongside the book.],

  [*Practice + answer key*], [Timed sets per tier. The key gives full working, not just
  answers.],

  [*One-page revision card*], [Templates, a when-to-use-what table, a complexity table you
  should be able to quote from memory, and the top traps in the order they bite.],
)

#section[3 · The five rules]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 4.5pt),
  stroke: 0.4pt + rule,

  [*1*], [*Type every listing and run it.* Reading code teaches you nothing. This book's
  code was all executed before printing; yours must be too. `node solution.js` with your
  own test cases, every time.],

  [*2*], [*Attempt before you read.* Give each problem an honest try with a pen, up to the
  tier's time limit. A solution you read before trying only *feels* like learning.],

  [*3*], [*When you are stuck, write down where.* Then read the solution and find that
  exact line. That line is your real lesson, not the whole solution.],

  [*4*], [*Always say the complexity out loud* before you write code, and again after. If
  you cannot state it, you do not yet understand your own solution.],

  [*5*], [*Redo every problem you got wrong --- three days later, from a blank page.* Not
  the same day. Three days later.],
)

#trap[
The four edge cases that fail more submissions than anything else: *empty input*, *one
element*, *all elements equal*, and *the answer being at the very first or very last
index*. Test those four before you say "done". They take twenty seconds and they are on
every judge.
]

#section[4 · The language, and the appendix you will need]

JavaScript is the primary language of this book. It is accepted by every judge and every
interviewer, and it is what most students in this course already write.

It also has five gaps that C++, Java and Python do not: no heap, no ordered map, no real
queue, no binary-search helper, and numbers that stop being exact at $2^53 - 1$. The
appendix *The JS Toolkit* fills all five, with tested code you can type from memory.

#note[
Read the appendix's *"JS gotchas for interviews"* page before Chapter 1, and again the
night before any test. Four of the ten gotchas there produce a *wrong answer with no error
message*. Those are the ones that cost marks.
]

#pagebreak(weak: true)

#section[5 · The 10-week plan]

Two chapters a week. About two hours a day, six days a week. Day 7 is the checkpoint.

#table(
  columns: (auto, auto, 1fr, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  align: (center, left, left, left),
  [*Week*], [*Chapters*], [*Daily target*], [*Checkpoint (day 7)*],

  [1],  [1, 2],   [Ch 1 fully on days 1--2 (it is the shortest and it sets up everything). Then Ch 2 warm-up + Tier 1.], [Write the Ch 1 constraint-to-algorithm table from memory.],
  [2],  [3, 4],   [Warm-up + Tier 1 of each, then Tier 2. Type every template.], [Re-solve one sliding-window and one binary-search problem from a blank page.],
  [3],  [5, 6, 7],   [These three are lighter. Tier 1 and Tier 2 of each; Tier 3 only of Ch 6.], [Mixed set: 6 problems from Ch 1--7, timed.],
  [4],  [8, 9, 10], [Stacks, deques and linked lists. All tiers --- these are short chapters with high exam frequency.], [Revision cards of Ch 1--10, written out from memory.],
  [5],  [11, 12],  [Recursion and trees. Tier 1 and Tier 2 daily; Tier 3 on days 5--6.], [Re-solve two tree traversals *iteratively*, no recursion.],
  [6],  [13, 14],  [BSTs and heaps. Type the toolkit `MinHeap` from memory on day 1 and check it against the appendix.], [Top-K, merge-K and running-median from a blank page.],
  [7],  [15, 16],  [Graphs. BFS and DFS on days 1--2, then shortest paths, MST and topological sort.], [Draw the "which graph algorithm" decision table from memory.],
  [8],  [17],      [DP I, slowly. One section per day. Write every recursion first, then memoise, then loop.], [The 0/1 versus unbounded knapsack loop direction, explained out loud.],
  [9],  [18, 19],  [DP II and greedy. Tier 1 and Tier 2 daily.], [Mixed set: 6 DP problems, timed at 25 minutes each.],
  [10], [20],      [Bits, maths and number theory. Then read all 20 revision cards.], [Full mixed set across the whole book, 8 problems, strictly timed.],
)

#section[6 · The 3-week crash plan]

Use this only if your test is inside a month. It skips nothing --- it cuts the practice
volume and the Tier 3 work. About four hours a day.

#table(
  columns: (auto, auto, 1fr, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  align: (center, left, left, left),
  [*Week*], [*Chapters*], [*Daily target*], [*Checkpoint (day 7)*],

  [1], [1--7],   [Pattern page + Tier 1 of each chapter. Skip Tier 3 entirely for now. Roughly one chapter a day.], [Mixed set of Ch 1--7, timed. Read the JS Toolkit gotchas page.],
  [2], [8--16],  [Pattern page + Tier 1, plus Tier 2 of Ch 12, 14, 15 and 16 (trees, heaps and graphs carry the most marks).], [Revision cards of Ch 1--16, written from memory.],
  [3], [17--20], [DP is the priority: Ch 17 over days 1--2, Ch 18 on day 3. Ch 19 and 20 on days 4--5. Day 6 is a full mixed set.], [Re-solve every problem you got wrong in weeks 1 and 2.],
)

#trap[
The crash plan works only if you *type and run everything from day one*. Reading solutions
quickly will make you feel ready and then fail you at the keyboard, where you have to
produce working code with no reference open.
]

#section[7 · How to use the revision cards]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 4pt),
  stroke: none,
  [*While studying*], [Ignore it. Learn from the approach ladders instead.],
  [*After finishing a chapter*], [Cover the card. Write it out from memory --- templates, complexity table, traps. Compare. The gaps are your revision list.],
  [*Last week before a test*], [Read only the 20 cards. That is about an hour for the whole book. Then one timed mixed set per day.],
  [*Last hour*], [The cards of your three weakest chapters, plus the JS Toolkit gotchas page. Nothing else.],
  [*In the interview itself*], [The complexity tables are what you quote. Practise saying them out loud, because you will be speaking, not writing.],
)

#pagebreak()
