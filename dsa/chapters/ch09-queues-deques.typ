#import "../../shared/lib/style.typ": *

#chapter(
  num: 9,
  title: "Queues, Deques & Monotonic Deque",
  tagline: "A line you can only join at the back — until you learn to throw people out of it",
)[

#note[
Every JavaScript snippet in this chapter was executed with `node` before it was printed.
Most of them start with this one line:
```js
const { MinHeap, Deque } = require('./toolkit.js');   // see the JS Toolkit appendix
```
`Deque` is a plain array plus a head index, so removing from the front is $O(1)$
amortised; `MinHeap` is there because JavaScript ships no priority queue at all. The
outputs shown under the snippets are the real outputs.
]

#section[Pattern in one page]

#formulas(title: "The three tools of this chapter")[
*1. Queue — FIFO (first in, first out).* You may only add at the back and remove from
the front. This is a ticket line. Use it when order of arrival must be respected:
breadth-first search, level-by-level processing, task pipelines, stream buffers.

*2. Deque — double-ended queue.* You may add and remove at *both* ends. JavaScript has
nothing like it built in: `arr.push`/`arr.pop` are $O(1)$ but `arr.shift`/`arr.unshift`
are not. The toolkit `Deque` gives you push, pop, shift, `front()` and `back()` in $O(1)$
amortised.

*3. Monotonic deque — the money-maker.* A deque of *indexes* whose values are kept
sorted (always decreasing, or always increasing). It answers
"what is the maximum (or minimum) of the current window?" in $O(1)$, and the whole
sweep costs $O(n)$.
]

#subsection[The JavaScript operations you need]

#code(lang: "js", caption: "queue and deque — the full menu")[
```js
const { Deque } = require('./toolkit.js');

const q = new Deque();
q.push(5); q.push(9);      // add at the back
q.front();                 // 5   read the front, do NOT remove
q.back();                  // 9   read the back
q.shift();                 // 5   remove the front AND return it
q.size;                    // 1   a getter, not a method
q.size === 0;              // "is it empty?"

const d = new Deque();
d.push(5); d.push(6);      // grow at the back
d.pop();                   // 6   remove from the back and return it
d.front(); d.back();

const st = [];             // a plain array is already a perfectly good STACK
st.push(1); st.pop();      // both O(1)
```
]

#trap[
Never build a queue out of `arr.shift()`. Removing the first element of a plain array has
to slide every other element down, so it is $O(n)$ in the general case, and a BFS written
that way quietly becomes $O(n^2)$. The toolkit `Deque` is an array plus a head index:
`shift()` only moves the index, and the array is compacted once half of it is dead. That
is the $O(1)$ amortised every complexity claim in this chapter assumes.
]

#trap[
`q.size` is a *getter*, not a method. Writing `q.size()` throws
`TypeError: q.size is not a function`. `front()`, `back()`, `push()`, `pop()` and
`shift()` all *are* methods. Mixing the two up is the first error you will hit.
]

#subsection[The monotonic deque template — learn this by heart]

The window slides from left to right. The deque stores *indexes*, never values.
Two rules keep it clean, and a third reads the answer.

#code(lang: "js", caption: "sliding window MAXIMUM — the template")[
```js
const { Deque } = require('./toolkit.js');

const maxWindow = (a, k) => {
  const n = a.length, res = [];
  if (k <= 0 || k > n) return res;
  const dq = new Deque();                                // holds INDEXES, values decreasing
  for (let i = 0; i < n; i++) {
    while (dq.size && dq.front() <= i - k) dq.shift();   // rule 1: drop expired
    while (dq.size && a[dq.back()] <= a[i]) dq.pop();    // rule 2: drop weaker
    dq.push(i);
    if (i >= k - 1) res.push(a[dq.front()]);             // rule 3: front is the answer
  }
  return res;
};
```
]
Real output for `[1,3,-1,-3,5,3,6,7], k=3`; `[4], k=1`; `[2,2,2,2], k=2`;
`[-5,-2,-9,-1], k=2`; then the empty array and $k > n$:
```
3 3 5 5 6 7
4
2 2 2
-2 -2 -1
[] []
```

#complexity(time: $O(n)$, space: $O(k)$,
  note: "Each index is pushed once and popped once. Two pushes never happen for one index, so the total work is linear even though there is a while-loop inside a for-loop.")

#subsection[The invariant — say it out loud]

#formulas(title: "Invariant of the decreasing deque")[
At the end of every loop step:
+ Every index in the deque is inside the current window.
+ The values at those indexes go *strictly down* from front to back.
+ `a[dq.front()]` is the maximum of the current window.
]

*Why rule 2 is safe.* Suppose `a[j] <= a[i]` and `j < i`. Then from now on, every window
that contains `j` also contains `i` (because `i` is to the right of `j` and windows move
right). A window can never prefer `j` over `i`: `i` is at least as big *and* lives longer.
So `j` is useless forever. Throw it away.

#trick[
Flip one comparison and you get the minimum instead:
`a[dq.back()] >= a[i]` keeps values *increasing*, and `a[dq.front()]` is the window
*minimum*. Nothing else changes. Keep both versions in your head as one template with a
switch.
]

#diagram(height: 4.2cm, caption: "One step of the decreasing deque. 9 arrives and eats every smaller value behind it.")[
  #dnode(0pt, 0.2cm, 1.5cm, 0.8cm, "idx 2 \n val 7")
  #dnode(1.7cm, 0.2cm, 1.5cm, 0.8cm, "idx 3 \n val 5")
  #dnode(3.4cm, 0.2cm, 1.5cm, 0.8cm, "idx 4 \n val 1")
  #dnode(6.6cm, 0.2cm, 1.5cm, 0.8cm, "new: 9", fill: rgb("#fdf0e3"))
  #darrow(6.5cm, 0.6cm, 5.1cm, 0.6cm, label: "push")
  #dnode(0pt, 2.4cm, 1.5cm, 0.8cm, "idx 2 \n val 7")
  #dnode(1.7cm, 2.4cm, 1.5cm, 0.8cm, "idx 5 \n val 9", fill: rgb("#e6f0e6"))
  #place(dx: 3.6cm, dy: 2.55cm)[#text(size: 8.5pt)[5 and 1 are gone: 9 is bigger *and* newer,]]
  #place(dx: 3.6cm, dy: 3.0cm)[#text(size: 8.5pt)[so they can never win a future window.]]
]

#subsection[When to reach for each tool]

#table(
  columns: (1.1fr, 2fr),
  [*Signal in the question*], [*Tool*],
  [“shortest number of moves”, “level by level”, “spread step by step”], [plain `Deque` + BFS],
  [“max / min of every window of size k”], [monotonic deque],
  [“longest window such that max − min ≤ L”], [two deques (one max, one min)],
  [“shortest window with sum ≥ S”, values may be negative], [prefix sums + increasing deque],
  [“dp\[i\] depends on the best of dp\[i−k..i−1\]”], [deque over the dp array],
  [“edges cost 0 or 1”], [deque BFS (0-1 BFS)],
  [“keep only the last k seconds of events”], [deque of timestamps],
)

#section[Warm-up — build the reflex]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Build a queue on top of a fixed-size array. Support `push`, `pop`, `front`, `empty`,
`full`. Capacity is 3. Constraints: capacity up to $10^5$; every operation must be $O(1)$.
Edge cases: pop from an empty queue, push into a full queue.
]
#sol[
A plain array queue that only moves `head` forward wastes space. Use a *circular* buffer:
after the last cell, wrap back to cell 0. Store `head` and `count`; the tail is then
`(head + count) % cap`.

#code(lang: "js", caption: "circular array queue")[
```js
class CircQueue {
  constructor(cap) { this.a = new Array(cap); this.head = 0; this.count = 0; this.cap = cap; }
  get empty() { return this.count === 0; }
  get full()  { return this.count === this.cap; }
  push(x) {                                   // add at the back
    if (this.full) return false;
    this.a[(this.head + this.count) % this.cap] = x;
    this.count++;
    return true;
  }
  pop() {                                     // remove from the front
    if (this.empty) return false;
    this.head = (this.head + 1) % this.cap;
    this.count--;
    return true;
  }
  front() { return this.a[this.head]; }       // caller must check .empty first
}
```
]

Test and real output:

#code(lang: "js", caption: "test")[
```js
const q = new CircQueue(3);
console.log(q.push(10), q.push(20), q.push(30), q.push(40));   // the 4th push fails
console.log(q.front());
q.pop(); q.push(40);
console.log(q.front(), q.count);
const drained = [];
while (!q.empty) { drained.push(q.front()); q.pop(); }
console.log(drained.join(' '));
console.log(q.pop(), q.empty);                                 // pop on empty fails
```
]
```
true true true false
10
20 3
20 30 40
false true
```
The fourth `push` returned `false` because the queue was full. The last `pop` returned
`false` because the queue was empty.
]
#complexity(time: $O(1)$ + " per operation", space: $O(c)$)

#trap[
Do not test "full" with `head == tail`. When the buffer is full, `head == tail` as well —
the same condition means both empty and full. Storing `count` removes the ambiguity.
]

#ex(2, tier: 0, asked: "warm-up")[
Build a queue using only two stacks. Constraints: up to $10^5$ operations.
Edge cases: `empty()` on a brand-new object, interleaving pushes and pops.
]
#sol[
Stack is LIFO, queue is FIFO. Pouring a stack into another stack reverses it, which turns
LIFO into FIFO. The trick is to pour *only when the output stack runs dry*.

#code(lang: "js", caption: "queue from two stacks (plain arrays)")[
```js
class QueueFromStacks {
  constructor() { this.in = []; this.out = []; }
  push(x) { this.in.push(x); }
  #shift() {                                   // move only when out is empty
    if (this.out.length === 0)
      while (this.in.length) this.out.push(this.in.pop());
  }
  front() { this.#shift(); return this.out[this.out.length - 1]; }
  pop()   { this.#shift(); return this.out.pop(); }
  get empty() { return this.in.length === 0 && this.out.length === 0; }
  get size()  { return this.in.length + this.out.length; }
}
```
]
Test: push 1, 2, 3; pop once; push 4; drain.
```
1 2 3 4
true 0
7 1
```
Line 1 is the drained order — perfect FIFO. Line 2 is `.empty` and `.size` of a fresh
object. Line 3 pushes 7 into the drained queue and reads front and size.
]
#complexity(time: "amortised " + $O(1)$, space: $O(n)$,
  note: "Each element is moved from in to out at most once in its whole life, so n operations cost O(n) total.")

#trap[
If you pour on *every* `pop`, the cost becomes $O(n)$ per operation. The `if (out.length === 0)`
guard is the entire trick. Interviewers ask "what is the amortised cost?" right after this
question — the answer is $O(1)$, and the reason is "each element crosses once".
]

#ex(3, tier: 0, asked: "warm-up")[
Print the first $n$ binary strings: 1, 10, 11, 100, 101, ... using a queue.
Constraints: $n <= 10^5$. Edge cases: $n = 0$, $n = 1$.
]
#sol[
Start with `"1"` in the queue. Pop a string, print it, then push that string with `"0"`
appended and with `"1"` appended. The queue keeps the numbers in increasing order for free.

#code(lang: "js", caption: "binary strings with a queue")[
```js
const firstBinary = (n) => {
  const out = [];
  const q = new Deque();
  q.push('1');
  for (let i = 0; i < n; i++) {
    const s = q.shift();
    out.push(s);
    q.push(s + '0');
    q.push(s + '1');
  }
  return out;
};
```
]
`firstBinary(7)` prints:
```
1 10 11 100 101 110 111
```
`firstBinary(0)` has length `0`. `firstBinary(1)` gives `1`. The strings are built with
`s + '0'`, which is exactly why this stays readable — no digit arithmetic anywhere.
]
#note[
This is breadth-first search on a binary tree where the left child appends `0` and the
right child appends `1`. Level $d$ holds every binary string of length $d+1$ that starts
with `1`. You will meet this exact shape again in the trees chapter.
]

#ex(4, tier: 0, asked: "TCS NQT pattern")[
(a) Reverse a whole queue. (b) Reverse only the first $k$ elements of a queue, leaving
the rest in order. Constraints: size up to $10^5$, $1 <= k <= "size"$.
Edge cases: empty queue, $k$ equal to the size, $k = 1$.
]
#sol[
(a) A stack reverses. Pour the queue into a stack, pour it back.

(b) Pour the first $k$ into a stack and push them back — they are now reversed, but they
sit at the *back*. Then rotate the remaining $n - k$ elements from front to back, which
slides the reversed block to the front.

#code(lang: "js", caption: "reverse a queue, and reverse its first k")[
```js
const reverseQueue = (q) => {
  const st = [];                              // a plain array, used as a stack
  while (q.size) st.push(q.shift());
  while (st.length) q.push(st.pop());
};

const reverseFirstK = (q, k) => {
  if (k <= 0 || k > q.size) return;
  const st = [];
  for (let i = 0; i < k; i++) st.push(q.shift());
  while (st.length) q.push(st.pop());
  const rotate = q.size - k;                  // size is n again: rotate exactly n - k
  for (let i = 0; i < rotate; i++) q.push(q.shift());
};
```
]
Real output for the tests `[1..5]` reversed, `[1..5]` with $k=3$, with $k=5$, `[9]` with
$k=1$, and an empty queue:
```
5 4 3 2 1
3 2 1 4 5
5 4 3 2 1
9
0
```
]
#trap[
In `reverseFirstK`, `q.size` changes while you are pushing. Read `q.size - k` into a
`const` *after* the block has been pushed back — at that moment the size is $n$ again and
the rotation count is exactly $n - k$. Putting `q.size - k` straight into the loop
condition re-reads it every iteration, and the loop never ends. This is the most common
bug in this question.
]

#ex(5, tier: 0, asked: "warm-up")[
Interleave the two halves of a queue. `1 2 3 4 5 6` must become `1 4 2 5 3 6`.
Constraints: size up to $10^5$. Edge cases: odd size (reject), empty queue.
]
#sol[
Move the front half into a second queue. Then alternate: one from the helper, one from
the main queue's front (pushing it to the back).

#code(lang: "js", caption: "interleave the halves")[
```js
const interleave = (q) => {
  const n = q.size;
  if (n % 2 !== 0) return false;              // needs an even count
  const first = new Deque();                  // holds the front half
  for (let i = 0; i < n / 2; i++) first.push(q.shift());
  while (first.size) {
    q.push(first.shift());                    // one from the front half
    q.push(q.shift());                        // one from the back half
  }
  return true;
};
```
]
Real output (return value, then the queue):
```
true 1 4 2 5 3 6
true 11 13 12 14
false 1 2 3
true 0
```
The third line shows an odd-sized queue: the function returns `false` and leaves the queue
untouched. The fourth line is the empty queue — `0` elements, treated as valid.
]
#complexity(time: $O(n)$, space: $O(n\/2)$)

#ex(6, tier: 0, asked: "warm-up")[
Warm up the monotonic idea by hand. Array `a = [4, 2, 7, 1, 9]`, window size `k = 3`.
List every window and its maximum, then say which indexes would ever be useful.
]
#sol[
#table(
  columns: (0.6fr, 1.2fr, 0.7fr),
  [*window*], [*values*], [*max*],
  [0..2], [4, 2, 7], [7],
  [1..3], [2, 7, 1], [7],
  [2..4], [7, 1, 9], [9],
)
Index 1 (value 2) is *never* the answer: index 2 (value 7) is bigger and always outlives
it. Index 0 (value 4) is also never the answer for the same reason. That is exactly rule 2
of the template.
]
#ans[maxima are 7, 7, 9; only indexes 2 and 4 are ever useful]

#section[Tier 1 — the standard window questions]
#tier-header(1)

#ex(7, tier: 1, asked: "Infosys · pattern")[
*Sliding window maximum.* Given an array `a` of $n$ integers and a window size $k$,
output the maximum of every window of size $k$.
Constraints: $n <= 10^5$, values are whole numbers and may be negative, $1 <= k <= n$.
Target: $O(n)$.
Edge cases: $k = 1$ (answer is the array itself), $k = n$ (one number), all values equal,
all values negative.
]
#sol[

#approach(1, "Check every window from scratch", verdict: "O(n k) — too slow")
For each starting position, scan $k$ cells and keep the largest.

#code(lang: "js", caption: "brute force")[
```js
const maxWindowBrute = (a, k) => {
  const n = a.length, res = [];
  if (k <= 0 || k > n) return res;
  for (let i = 0; i + k <= n; i++) {
    let best = a[i];
    for (let j = i; j < i + k; j++) best = Math.max(best, a[j]);
    res.push(best);
  }
  return res;
};
```
]
Real output for `[1,3,-1,-3,5,3,6,7], k=3`; `[4], k=1`; `[2,2,2,2], k=2`;
`[-5,-2,-9,-1], k=2`; the empty array; and $k > n$:
```
3 3 5 5 6 7
4
2 2 2
-2 -2 -1
[]
[]
```
The last two are empty arrays on purpose — no window exists.
#complexity(time: $O(n k)$, space: $O(1)$ + " output",
  note: "With n = 10^5 and k = 10^5 this is 10^10 steps. It will time out.")

#approach(2, "A max-heap with lazy deletion", verdict: "O(n log n) — passes, but not the intended answer")
This is the first place in the chapter where JavaScript leaves you empty-handed: there is
no priority queue in the language, and no ordered multiset either. Use the toolkit
`MinHeap` with the comparator flipped, which makes it a max-heap of `[value, index]`
pairs. You cannot pull an arbitrary element out of a heap, so you do not try — you discard
the top only when it turns out to have left the window. That is *lazy deletion*.

#code(lang: "js", caption: "max-heap window with lazy deletion")[
```js
const { MinHeap } = require('./toolkit.js');   // JS has no heap of its own

const maxWindowHeap = (a, k) => {
  const n = a.length, res = [];
  if (k <= 0 || k > n) return res;
  const h = new MinHeap((x, y) => y[0] - x[0]);      // flip the comparator -> max-heap
  for (let i = 0; i < n; i++) {
    h.push([a[i], i]);
    while (h.peek()[1] <= i - k) h.pop();            // the top has left the window
    if (i >= k - 1) res.push(h.peek()[0]);
  }
  return res;
};
```
]
Real output for `[1,3,-1,-3,5,3,6,7], k=3`; `[7,7,7,1], k=3`; `[-5,-2,-9,-1], k=2`;
`[5], k=1`; the empty array:
```
3 3 5 5 6 7
7 7
-2 -2 -1
5
[]
```
#complexity(time: $O(n log n)$, space: $O(n)$,
  note: "The heap can hold every element that has ever arrived, because expired entries are only thrown away when they float to the top.")

#trap[
JavaScript has no `TreeMap`, no ordered set and no multiset. When a problem wants "the
sorted contents of the window", your three options are: a heap with lazy deletion (this
approach), a *sorted array* kept in order with `lowerBound` and `splice` (used for the
median in Example 26), or — when you only need an extreme — a monotonic deque. Say which
one you are choosing and why; "I would use a multiset" is not an answer in JavaScript.
]

#trap[
`new MinHeap()` with no argument is a *min*-heap on numbers. For a max-heap you must pass
`(x, y) => y - x`, and for pairs `(x, y) => y[0] - x[0]`. Getting the sign backwards gives
a perfectly plausible, perfectly wrong answer — the window *minimum* — which tiny test
cases often fail to reveal.
]

#approach(3, "Monotonic deque", verdict: "O(n) — optimal")
Same template as page one.

#code(lang: "js", caption: "optimal: decreasing deque of indexes")[
```js
const { Deque } = require('./toolkit.js');

const maxWindow = (a, k) => {
  const n = a.length, res = [];
  if (k <= 0 || k > n) return res;
  const dq = new Deque();                                // holds INDEXES, values decreasing
  for (let i = 0; i < n; i++) {
    while (dq.size && dq.front() <= i - k) dq.shift();   // drop the expired index
    while (dq.size && a[dq.back()] <= a[i]) dq.pop();    // drop weaker candidates
    dq.push(i);
    if (i >= k - 1) res.push(a[dq.front()]);
  }
  return res;
};
```
]
Real output over seven tests (including a 2000-case random stress test against the brute
force):
```
3 3 5 5 6 7
9 8 7
2 3 4
2 2
-2 -2 -1
4
[] []
stress ok
```
#complexity(time: $O(n)$, space: $O(k)$,
  note: "Each index enters the deque once and leaves once: at most 2n deque operations in total.")

*The idea that unlocked it:* a value that is smaller than a newer value can never win a
future window, so it can be deleted permanently. Once deletions are permanent, the total
number of deletions is bounded by $n$, and the inner while-loop stops being a second loop.

The same code in Python:

#code(lang: "python", caption: "sliding window maximum in Python")[
```python
from collections import deque

def max_window(a, k):
    if k <= 0 or k > len(a):
        return []
    dq, res = deque(), []          # dq holds indexes, values decreasing
    for i, v in enumerate(a):
        while dq and dq[0] <= i - k:
            dq.popleft()
        while dq and a[dq[-1]] <= v:
            dq.pop()
        dq.append(i)
        if i >= k - 1:
            res.append(a[dq[0]])
    return res
```
]
Real output for `([1,3,-1,-3,5,3,6,7], 3)`, then `([2,2], 2)`, the empty list,
and `([1], 5)`:
```
[3, 3, 5, 5, 6, 7]
[2] [] []
```
Python has `collections.deque` built in, with $O(1)$ `append`, `pop`, `appendleft` and
`popleft`. That is the one place Python is genuinely shorter than JavaScript here — but
the toolkit `Deque` gives you the same $O(1)$ behaviour, so the algorithm is identical.
]

#trap[
Store *indexes*, not values. If you store values you cannot tell whether the front has
expired. Beginners store values, then bolt on a separate counter, then get it wrong when
duplicates appear. Indexes make expiry a one-line comparison.
]

#ex(8, tier: 1, asked: "Wipro · pattern")[
*Sliding window minimum.* Same input, but report the minimum of each window.
Constraints and edge cases as above.
]
#sol[
Flip two comparison signs. Nothing else.

#code(lang: "js", caption: "increasing deque")[
```js
const minWindow = (a, k) => {
  const n = a.length, res = [];
  if (k <= 0 || k > n) return res;
  const dq = new Deque();                                // values INCREASING
  for (let i = 0; i < n; i++) {
    while (dq.size && dq.front() <= i - k) dq.shift();
    while (dq.size && a[dq.back()] >= a[i]) dq.pop();
    dq.push(i);
    if (i >= k - 1) res.push(a[dq.front()]);
  }
  return res;
};
```
]
Real output for `[1,3,-1,-3,5,3,6,7], k=3`; `[5,5,5], k=2`; `[-1,-2,-3], k=1`; empty:
```
-1 -3 -3 -3 3 3
5 5
-1 -2 -3
[]
```
]
#complexity(time: $O(n)$, space: $O(k)$)

#ex(9, tier: 1, asked: "Capgemini · pattern")[
*First negative number in every window of size k.* If a window has no negative number,
report 0.
Constraints: $n <= 10^5$. Edge cases: no negatives at all, all negatives, $k = 1$.
]
#sol[

#approach(1, "Scan each window", verdict: "O(n k)")
For each window, walk left to right and stop at the first negative. Correct, too slow
for $n = 10^5$ with a large $k$.

#approach(2, "A queue of negative indexes only", verdict: "O(n) — optimal")
The answer is the *oldest* negative still inside the window. That is a plain FIFO queue of
indexes — no monotonic rule is needed, because "oldest" is exactly what FIFO gives.

#code(lang: "js", caption: "first negative in each window")[
```js
const firstNegative = (a, k) => {
  const n = a.length, res = [];
  if (k <= 0 || k > n) return res;
  const dq = new Deque();                                // indexes of negative numbers only
  for (let i = 0; i < n; i++) {
    if (a[i] < 0) dq.push(i);
    while (dq.size && dq.front() <= i - k) dq.shift();
    if (i >= k - 1) res.push(dq.size ? a[dq.front()] : 0);
  }
  return res;
};
```
]
Real output for `[12,-1,-7,8,-15,30,16,28], k=3`; `[1,2,3,4], k=2`; `[-1,-2,-3], k=3`;
`[5], k=1`; empty:
```
-1 -1 -7 -15 -15 0
0 0 0
-1
0
[]
```
]
#complexity(time: $O(n)$, space: $O(k)$)

*The idea that unlocked it:* the answer is a *position* question, not a *value* question.
When the answer is "the oldest thing that still qualifies", a plain queue is enough — you
do not need the monotonic rule at all.

#ex(10, tier: 1, asked: "TCS Digital · pattern")[
*Sum of window maximum plus window minimum, over all windows of size k.*
Constraints: $n <= 10^5$, $|a_i| <= 10^9$.
Target: $O(n)$. Edge cases: the total can exceed 32 bits; $k = n$; empty array.
]
#sol[
Run *two* deques at the same time over the same loop: one decreasing (max) and one
increasing (min).

#code(lang: "js", caption: "two deques, one pass")[
```js
const sumMinPlusMax = (a, k) => {
  const n = a.length;
  if (k <= 0 || k > n) return 0;
  const mx = new Deque(), mn = new Deque();        // both hold INDEXES
  let total = 0;
  for (let i = 0; i < n; i++) {
    while (mx.size && mx.front() <= i - k) mx.shift();
    while (mn.size && mn.front() <= i - k) mn.shift();
    while (mx.size && a[mx.back()] <= a[i]) mx.pop();
    while (mn.size && a[mn.back()] >= a[i]) mn.pop();
    mx.push(i); mn.push(i);
    if (i >= k - 1) total += a[mx.front()] + a[mn.front()];
  }
  return total;
};
```
]
Real output for `([2,5,-1,7,-3,-1,-2], 4)`; `([1,1,1], 3)`;
`([2000000000, 2000000000], 2)`; the empty array; `([4], 1)`:
```
18
2
4000000000
0
8
```
]
#complexity(time: $O(n)$, space: $O(k)$)

#note[
The third test is the "would this have overflowed?" test. In a 32-bit language
$2 times 10^9 + 2 times 10^9$ overflows and you need a wider type. JavaScript has no
32-bit integers to overflow: every number is a double, exact up to
`Number.MAX_SAFE_INTEGER` $= 9007199254740991$. Tested: the answer comes back as
`4000000000`, and `4000000000 <= Number.MAX_SAFE_INTEGER` is `true`.

Check the worst case anyway, every time. Here the running `total` is at most
$10^5$ windows $times 2 times 10^9 = 2 times 10^14$ — still under
$9 times 10^15$, so plain numbers are safe. Tested:
`1e5 * 2e9 <= Number.MAX_SAFE_INTEGER` is `true`. Push $k$ or the values one order of
magnitude higher and the answer would change to `BigInt`.
]

#ex(11, tier: 1, asked: "Accenture · pattern")[
*Count of distinct values in every window of size k.*
Constraints: $n <= 10^5$, values up to $10^9$. Edge cases: all values the same,
negative values, $k = 1$.
]
#sol[

#approach(1, "Build a set per window", verdict: "O(n k)")
Build a `new Set(a.slice(i, i + k))` for every window and read its `.size`.

#approach(2, "One hash map that slides", verdict: "O(n) average — optimal")
Keep a `Map` of counts for the current window. When a count drops to zero, *delete the
key*, so that `cnt.size` is the answer directly.

#code(lang: "js", caption: "distinct per window")[
```js
const distinctInWindow = (a, k) => {
  const n = a.length, res = [];
  if (k <= 0 || k > n) return res;
  const cnt = new Map();
  for (let i = 0; i < n; i++) {
    cnt.set(a[i], (cnt.get(a[i]) || 0) + 1);            // new element joins
    if (i >= k) {
      const old = a[i - k];
      const c = cnt.get(old) - 1;
      if (c === 0) cnt.delete(old);                     // delete, so .size is the answer
      else cnt.set(old, c);
    }
    if (i >= k - 1) res.push(cnt.size);
  }
  return res;
};
```
]
Real output for `([1,2,1,3,4,2,3], 4)`; `([5,5,5,5], 2)`; `([-1,-1,0], 3)`; `([9], 1)`;
the empty array:
```
[3,4,4,3]
[1,1,1]
[2]
[1]
[]
```
]
#complexity(time: $O(n)$ + " average", space: $O(k)$)

#trap[
If you do not delete the zero-count key, `cnt.size` counts values that left the window
long ago. The bug is silent: small tests still pass because keys rarely leave.

And note `cnt.size` is a *property* on a `Map`, not a method: `cnt.size()` throws. On a
plain object there is no `.size` at all — you would need `Object.keys(o).length`, which
is $O(k)$ every time and turns this $O(n)$ sweep into $O(n k)$. Another reason `Map` wins.
]

#ex(12, tier: 1, asked: "Cognizant · pattern")[
*Build a deque from scratch* on a fixed-capacity array. Support `pushFront`, `pushBack`,
`popFront`, `popBack`, `front`, `back`, all in $O(1)$.
Constraints: capacity up to $10^5$. Edge cases: push into a full deque, pop from an empty
one, wrap-around at both ends.
]
#sol[
Same circular buffer as Example 1, plus one new move: `pushFront` steps `head`
*backwards* with wrap-around, `head = (head - 1 + cap) % cap`. The `+ cap` is needed
because JavaScript `%` keeps the sign of the left operand: tested in Node, `(0 - 1) % 4`
is `-1`, not `3`.

#code(lang: "js", caption: "fixed-capacity deque")[
```js
class MyDeque {                  // fixed capacity, circular buffer
  constructor(cap) { this.a = new Array(cap); this.cap = cap; this.head = 0; this.count = 0; }
  get empty() { return this.count === 0; }
  get full()  { return this.count === this.cap; }

  pushBack(x) {
    if (this.full) return false;
    this.a[(this.head + this.count) % this.cap] = x;
    this.count++;
    return true;
  }
  pushFront(x) {
    if (this.full) return false;
    this.head = (this.head - 1 + this.cap) % this.cap;      // step back, wrapping
    this.a[this.head] = x;
    this.count++;
    return true;
  }
  popFront() { if (this.empty) return false; this.head = (this.head + 1) % this.cap; this.count--; return true; }
  popBack()  { if (this.empty) return false; this.count--; return true; }
  front() { return this.a[this.head]; }
  back()  { return this.a[(this.head + this.count - 1) % this.cap]; }
}
```
]
Real output, with capacity 4, doing `pushBack(2) pushBack(3) pushFront(1)`, then
`pushFront(-1) pushFront(-2)`, then draining:
```
true true true
1 3 3
true false
-1 3
false false true
```
Line 3 shows `pushFront(-1)` succeeding and `pushFront(-2)` failing — capacity 4 is full.
Line 5 shows both pops failing on an empty deque, and `empty` returning `true`.
]

#trap[
`(head - 1) % cap` is wrong when `head` is 0. Tested in Node: `(0 - 1) % 4` is `-1`, so
`this.a[-1]` reads and writes a *string-keyed property* on the array — no error, no
crash, and `count` says the item is there while `front()` returns `undefined` forever.
Always write `(head - 1 + cap) % cap`, which gives `3`.
]

#trap[
`empty` and `full` above are getters, so they are `d.empty` and `d.full` with no
brackets, while `front()` and `back()` are methods. Mixing the two up throws
`TypeError: d.empty is not a function`, or — worse — `if (d.full)` on a *method* is
always truthy, so a full deque silently accepts nothing.
]

#ex(13, tier: 1, asked: "TCS NQT pattern")[
*Circular fuel route.* There are $n$ stops in a circle. Stop $i$ gives `fuel[i]` litres,
and driving from stop $i$ to stop $i+1$ burns `cost[i]` litres. Start with an empty tank.
Return a stop you can start from and finish the whole circle, or $-1$.
Constraints: $n <= 10^5$, values up to $10^9$. Target: $O(n)$.
Edge cases: exactly one stop; total fuel equals total cost; no valid start.
]
#sol[

#approach(1, "Try every start", verdict: "O(n^2)")
For each start, simulate the whole circle with a queue of stops. Correct but quadratic.

#approach(2, "One pass with a running tank", verdict: "O(n) — optimal")
Two facts do all the work.
+ If total fuel $<$ total cost, no start can work. Answer $-1$.
+ If the tank goes negative somewhere between start $s$ and stop $i$, then *no* stop
  between $s$ and $i$ can be a valid start either. Every such stop begins with an even
  emptier tank. So jump the start to $i+1$.

#code(lang: "js", caption: "circular route in one pass")[
```js
// pumps[i] = [fuel at pump i, cost to reach pump i+1].  Returns a start index, or -1.
const startPump = (pumps) => {
  const n = pumps.length;
  let total = 0, tank = 0, start = 0;
  for (let i = 0; i < n; i++) {
    const gain = pumps[i][0] - pumps[i][1];
    total += gain;
    tank  += gain;
    if (tank < 0) { start = i + 1; tank = 0; }   // nothing before i+1 can work
  }
  return total >= 0 ? start % Math.max(n, 1) : -1;
};
```
]
Real output for `[[4,6],[6,5],[7,3],[4,5]]`; `[[1,5],[2,3]]`; `[[3,3]]`; `[[2,1],[1,2]]`;
empty:
```
1
-1
0
0
0
```
]
#complexity(time: $O(n)$, space: $O(1)$)

*The idea that unlocked it:* a failed prefix rules out *every* start inside it, not just
the one you tried. That turns $n$ independent simulations into one sweep.

#ex(14, tier: 1, asked: "Infosys · pattern")[
*Moving average of a stream.* Numbers arrive one at a time. After each arrival report the
average of the last $k$ numbers (or of all of them if fewer than $k$ have arrived).
Constraints: up to $10^6$ arrivals, $|x| <= 10^9$. Edge cases: $k = 1$; negative numbers.
]
#sol[
Keep a deque of the window and a running sum. Never re-add the whole window.

#code(lang: "js", caption: "moving average")[
```js
class MovingAverage {
  constructor(k) { this.win = new Deque(); this.sum = 0; this.k = k; }

  next(x) {
    this.win.push(x);
    this.sum += x;
    if (this.win.size > this.k) this.sum -= this.win.shift();
    return this.sum / this.win.size;               // divide by size, not by k
  }
}
```
]
Real output with $k = 3$ feeding 10, 20, 30, 40, −90, then with $k = 1$ feeding 5, −5:
```
10.0000 15.0000 20.0000 30.0000 -6.6667
5.0000 -5.0000
```
]
#complexity(time: $O(1)$ + " per arrival", space: $O(k)$)

#trap[
Divide by `win.size`, not by `k` — during the first $k-1$ arrivals the window is not full
yet, and dividing by `k` gives an average that is far too small.

`win.size` is a *getter* on the toolkit `Deque`, so there are no brackets. `win.size()`
throws `TypeError: win.size is not a function`.
]

#note[
The running `sum` here is safe. Even $10^6$ arrivals of $10^9$ each reach $10^15$, and
`Number.MAX_SAFE_INTEGER` is $9007199254740991 approx 9 times 10^15$. Tested:
`1e6 * 1e9 <= Number.MAX_SAFE_INTEGER` is `true`. One more order of magnitude on either
factor and you would have to switch `sum` to `BigInt` — and then the division would need
`Number(sum) / size`, because `BigInt` division truncates.
]

#ex(15, tier: 1, asked: "Wipro · pattern")[
*First non-repeating character in a stream.* Letters `a`..`z` arrive one at a time. After
every arrival print the first character seen so far that has appeared exactly once, or
`#` if there is none.
Constraints: stream length up to $10^6$. Edge cases: empty stream, one character,
all characters the same.
]
#sol[
A `Map` of counts plus a queue of candidates in arrival order. Before reading the front,
throw away any front whose count has risen above 1. Use a `Map` rather than a plain
object: a plain object turns every key into a string, so the number `1` and the text
`"1"` would collide. Tested in Node — a `Map` given the key `1` and then the key `"1"`
holds *two* entries; a plain object holds one.

#code(lang: "js", caption: "first unique in a stream")[
```js
const firstUniqueStream = (s) => {
  const out = [];
  const cnt = new Map();
  const q = new Deque();                                 // candidates in arrival order
  for (const ch of s) {
    cnt.set(ch, (cnt.get(ch) || 0) + 1);
    q.push(ch);
    while (q.size && cnt.get(q.front()) > 1) q.shift();   // stale front
    out.push(q.size ? q.front() : '#');
  }
  return out.join('');
};
```
]
Real output for `"aabc"`, `"zzz"`, `"abcabc"`, `""` and `"q"`:
```
a#bb
z##
aaabc#
(empty string)
q
```
]
#complexity(time: $O(n)$, space: $O(n)$,
  note: "Each character is pushed once and popped at most once.")

#note[
This is *lazy deletion*: instead of hunting through the queue for the character that just
became repeated, you leave it in place and skip it when it reaches the front. Lazy
deletion shows up again with heaps in Chapter 14.
]

#ex(16, tier: 1, asked: "Capgemini · pattern")[
*A queue that can report its maximum in $O(1)$.* Support `push`, `pop` (FIFO) and
`getMax`.
Constraints: up to $10^6$ operations. Edge cases: duplicates of the maximum; negative
values; `getMax` right after the maximum is popped.
]
#sol[
Keep the normal queue plus a *decreasing deque of values*. On `push`, delete every smaller
value from the back. On `pop`, if the value leaving equals the deque front, remove the
front too.

#code(lang: "js", caption: "MaxQueue")[
```js
class MaxQueue {
  constructor() { this.q = new Deque(); this.mx = new Deque(); }   // mx: VALUES, decreasing

  push(x) {
    this.q.push(x);
    while (this.mx.size && this.mx.back() < x) this.mx.pop();
    this.mx.push(x);
  }
  pop() {
    const v = this.q.shift();
    if (this.mx.size && this.mx.front() === v) this.mx.shift();
    return v;
  }
  getMax() { return this.mx.front(); }
  get empty() { return this.q.size === 0; }
  get size()  { return this.q.size; }
}
```
]
Real output. Pushing 5, then 3, then 1, then a second 5, printing the value just pushed
and `getMax` each time; then two pops with `getMax` after each; then a fresh queue that
gets `-4` and `2` and one pop:
```
5
3 5
1 5
5 5
5 5
3 5
-4 2
```
Line 5 is the important one: popping the *first* 5 must leave `getMax` at 5, because the
second 5 is still in the queue.
]
#complexity(time: "amortised " + $O(1)$, space: $O(n)$)

#trap[
The pop comparison uses `<`, not `<=`. If you write `mx.back() <= x` you delete *equal*
copies, and then popping one 5 removes the only record of the other 5 — `getMax` returns
2 while a 5 is still in the queue. The test above pushes two 5s exactly to catch this.
]

#section[Tier 2 — applied, two or three steps]
#tier-header(2)

#ex(17, tier: 2, asked: "Grab · pattern")[
*Surge pricing window.* A ride app records the number of open ride requests each minute
for $n$ minutes. Marketing wants, for every rolling window of $k$ minutes, both the peak
and the floor, and then the largest peak-minus-floor across all windows.
Constraints: $n <= 2 times 10^5$, counts up to $10^6$. Target: $O(n)$.
Edge cases: $k = n$; counts all equal (answer 0); $k = 1$ (answer 0).
]
#sol[
Two deques again, but this time you only track the widest gap.

#code(lang: "js", caption: "widest peak-to-floor gap over all windows")[
```js
const widestGap = (a, k) => {
  const n = a.length;
  if (k <= 0 || k > n) return 0;
  const mx = new Deque(), mn = new Deque();
  let best = 0;
  for (let i = 0; i < n; i++) {
    while (mx.size && mx.front() <= i - k) mx.shift();
    while (mn.size && mn.front() <= i - k) mn.shift();
    while (mx.size && a[mx.back()] <= a[i]) mx.pop();
    while (mn.size && a[mn.back()] >= a[i]) mn.pop();
    mx.push(i); mn.push(i);
    if (i >= k - 1) best = Math.max(best, a[mx.front()] - a[mn.front()]);
  }
  return best;
};
```
]
Real output for `([3,9,2,8,8,1], 3)`; `([5,5,5], 2)`; `([4,7,2], 1)`; the empty array:
```
7
0
0
0
```
The first answer is 7: the window `[9, 2, 8]` has peak 9 and floor 2.
]
#complexity(time: $O(n)$, space: $O(k)$)

#ex(18, tier: 2, asked: "Shopee · pattern")[
*Stable price run.* A seller logs a price every hour. Find the longest run of consecutive
hours in which the highest price minus the lowest price is at most `limit`.
Constraints: $n <= 10^5$, prices up to $10^9$, `limit` $>= 0$.
Target: $O(n)$. Edge cases: `limit = 0` (longest run of equal values); one element;
empty array; negative values.
]
#sol[

#approach(1, "Try every pair of endpoints", verdict: "O(n^2) or O(n^3)")
For every start and end, compute max and min. Even with a running max and min this is
$O(n^2)$.

#approach(2, "Window + a sorted array", verdict: "O(n log n), and O(n) hidden in splice")
JavaScript has no ordered multiset, so you would hold the window in an array kept sorted,
find positions with the toolkit `lowerBound`, and insert and remove with `splice`. Then
`last - first > limit` says when to shrink. It works, but `splice` itself moves elements,
so the real cost is worse than the $O(n log n)$ the idea promises. Avoidable — skip to
approach 3.

#approach(3, "Window + two monotonic deques", verdict: "O(n) — optimal")
The window is no longer a fixed size, so expiry is not "index $<= i-k$" any more. Instead,
when you move `left` forward, check whether either deque's front *was* that index and pop
it.

#code(lang: "js", caption: "longest run with max - min <= limit")[
```js
const longestStableRun = (a, limit) => {
  const mx = new Deque(), mn = new Deque();          // both hold indexes
  let best = 0, left = 0;
  for (let right = 0; right < a.length; right++) {
    while (mx.size && a[mx.back()] <= a[right]) mx.pop();
    while (mn.size && a[mn.back()] >= a[right]) mn.pop();
    mx.push(right); mn.push(right);
    while (a[mx.front()] - a[mn.front()] > limit) {   // shrink from the left
      if (mx.front() === left) mx.shift();
      if (mn.front() === left) mn.shift();
      left++;
    }
    best = Math.max(best, right - left + 1);
  }
  return best;
};
```
]
Real output for `([8,2,4,7], 4)`; `([10,1,2,4,7,2], 5)`; `([4,2,2,2,4,4,2,2], 0)`;
`([5], 0)`; the empty array; `([-5,-1,-3], 4)`:
```
2
4
3
1
0
3
```
]
#complexity(time: $O(n)$, space: $O(n)$)

*The idea that unlocked it:* the window still only moves right, so the deques still only
ever discard from the front. A variable-size window does not break the monotonic
structure — it only changes *when* you pop the front.

#trap[
Inside the shrink loop, both `if`s must be checked, and neither may be an `else if`. When
the window holds a single element, that index is the front of *both* deques and both must
go.
]

#ex(19, tier: 2, asked: "Agoda · pattern")[
*Warehouse spoilage.* A shelf grid holds `0` = empty slot, `1` = fresh crate,
`2` = spoiled crate. Every minute a spoiled crate spoils the fresh crates directly above,
below, left and right of it. Return the number of minutes until nothing fresh is left,
or $-1$ if some crate can never be reached.
Constraints: grid up to $500 times 500$. Edge cases: no fresh crates at the start
(answer 0); a fresh crate walled off (answer −1); an empty grid.
]
#sol[
This is breadth-first search with *many* starting points at once. Push every spoiled crate
into the queue first, then process the queue one whole *level* at a time; each level is
one minute.

#code(lang: "js", caption: "multi-source BFS")[
```js
const minutesToSpoil = (grid) => {
  const g = grid.map(row => [...row]);          // deep copy: we overwrite cells
  const r = g.length; if (r === 0) return 0;
  const c = g[0].length; if (c === 0) return 0;
  const q = new Deque();
  let fresh = 0;
  for (let i = 0; i < r; i++)
    for (let j = 0; j < c; j++) {
      if (g[i][j] === 2) q.push([i, j]);
      else if (g[i][j] === 1) fresh++;
    }
  if (fresh === 0) return 0;
  let minutes = 0;
  const dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
  while (q.size && fresh > 0) {
    const sz = q.size;                          // one whole minute = one whole level
    for (let s = 0; s < sz; s++) {
      const [x, y] = q.shift();
      for (const [dx, dy] of dirs) {
        const nx = x + dx, ny = y + dy;
        if (nx < 0 || ny < 0 || nx >= r || ny >= c || g[nx][ny] !== 1) continue;
        g[nx][ny] = 2; fresh--; q.push([nx, ny]);
      }
    }
    minutes++;
  }
  return fresh === 0 ? minutes : -1;
};
```
]
Real output for the six test grids
`[[2,1,1],[1,1,0],[0,1,1]]`, `[[2,1,1],[0,1,1],[1,0,1]]`, `[[0,2]]`, `[[1]]`, `[]`
and `[[]]`:
```
4 -1 0 -1 0 0
```
The caller's grid is printed afterwards and is unchanged.
]

#trap[
*`[...grid]` is only a SHALLOW copy.* The new outer array holds the very same row arrays,
so `copy[0][0] = 2` also changes `grid[0][0]`. Tested in Node: after
`const shallow = [...g]; shallow[0][0] = 0;` the original `g[0][0]` is `0` too — the
caller's data is destroyed and there is no error to tell you.

The correct deep copy of a 2-D grid is `grid.map(row => [...row])`, which is what the
code above uses. Tested: the caller's grid comes back untouched. If you *want* to spoil
the caller's grid in place, say so out loud; silently doing it is a bug.
]
#complexity(time: $O(r c)$, space: $O(r c)$)

#trap[
`const sz = q.size;` must be taken *before* the inner loop. If you write
`for (let s = 0; s < q.size; s++)` the bound is re-read every iteration, so the loop keeps
growing while you push, and every crate is processed in "minute 1". The whole
level-by-level idea collapses and the answer comes out as `1` for almost every grid.
]

#ex(20, tier: 2, asked: "SCB · pattern")[
*Fewest moves on a floor plan.* A warehouse floor is a grid of `.` (walkable) and `#`
(blocked). Return the fewest single-step moves (up, down, left, right) from a start cell
to a target cell, or $-1$.
Constraints: grid up to $1000 times 1000$. Edge cases: start equals target (0);
start or target blocked; target unreachable.
]
#sol[
Plain BFS. The first time BFS reaches a cell, it reaches it by the shortest path — this
is true only because every move costs the same.

#code(lang: "js", caption: "grid BFS")[
```js
const shortestSteps = (g, sr, sc, tr, tc) => {
  const r = g.length; if (r === 0) return -1;
  const c = g[0].length;
  if (g[sr][sc] === '#' || g[tr][tc] === '#') return -1;
  const dist = Array.from({ length: r }, () => new Array(c).fill(-1));
  const q = new Deque();
  q.push([sr, sc]); dist[sr][sc] = 0;
  const dirs = [[1, 0], [-1, 0], [0, 1], [0, -1]];
  while (q.size) {
    const [x, y] = q.shift();
    if (x === tr && y === tc) return dist[x][y];
    for (const [dx, dy] of dirs) {
      const nx = x + dx, ny = y + dy;
      if (nx < 0 || ny < 0 || nx >= r || ny >= c) continue;
      if (g[nx][ny] === '#' || dist[nx][ny] !== -1) continue;
      dist[nx][ny] = dist[x][y] + 1;          // mark on PUSH, not on pop
      q.push([nx, ny]);
    }
  }
  return -1;
};
```
]
On the floor plan
```
. . . .
# # . #
. # . .
. . . .
```
the real output for (0,0)→(3,0); (0,0)→(0,3); a blocked 2×2 case; a single cell:
```
7
3
-1
0
```
]
#complexity(time: $O(r c)$, space: $O(r c)$)

#trap[
Mark a cell as visited *when you push it*, not when you pop it. If you mark on pop, the
same cell can be pushed many times before it is popped once, and the queue explodes.
]

#ex(21, tier: 2, asked: "DBS · pattern")[
*API rate limiter.* Allow at most `limit` calls from one client in any window of
`windowSec` seconds. Timestamps arrive in non-decreasing order.
Constraints: up to $10^6$ calls. Edge cases: `limit = 0`; a long gap with no calls;
two calls at the same timestamp.
]
#sol[
Keep the accepted timestamps in a deque. Drop everything older than the window, then
compare the size against the limit.

#code(lang: "js", caption: "sliding-window rate limiter")[
```js
class RateLimiter {
  constructor(limit, windowSec) { this.t = new Deque(); this.limit = limit; this.windowSec = windowSec; }

  allow(now) {
    while (this.t.size && this.t.front() <= now - this.windowSec) this.t.shift();
    if (this.t.size >= this.limit) return false;
    this.t.push(now);
    return true;
  }
  countInWindow(now) {
    while (this.t.size && this.t.front() <= now - this.windowSec) this.t.shift();
    return this.t.size;
  }
}
```
]
Real output with `limit = 3`, `windowSec = 10`, calls at t = 1, 2, 3, 4, then 11, then
`countInWindow` at t = 100, and finally a limiter with `limit = 0`:
```
true true true false
3
true
3
0
false
```
The call at t = 4 is rejected. The call at t = 11 is accepted because the call at t = 1
has now expired. With `limit = 0` nothing is ever allowed.
]
#complexity(time: "amortised " + $O(1)$ + " per call", space: $O("limit")$)

#note[
*Follow-up the interviewer asks:* "a million clients, and memory is tight." Then you drop
the exact deque and use a *counter per fixed bucket* — an approximate limiter that stores
two integers per client instead of `limit` timestamps. Trading exactness for memory is a
normal, expected answer here.
]

#ex(22, tier: 2, asked: "Sea/Shopee · pattern")[
*Job cooldown scheduler.* You have a list of jobs, each labelled by a type. Two jobs of
the same type may not run within `cool` ticks of each other. One job runs per tick, and a
tick may be idle. Return the number of ticks the whole list takes.
Constraints: up to $10^5$ jobs. Edge cases: `cool = 0`; every job the same type;
empty list.
]
#sol[
Greedy: at every tick run the *most frequent* job that is not cooling down. A max-heap
holds the ready jobs, and a queue holds the cooling ones with the tick at which they
become ready again. The queue is naturally sorted by wake-up time because ticks only move
forward.

#code(lang: "js", caption: "cooldown scheduler")[
```js
const { MinHeap, Deque } = require('./toolkit.js');   // JS has no priority queue

const ticksNeeded = (jobs, cool) => {
  const cnt = new Map();
  for (const j of jobs) cnt.set(j, (cnt.get(j) || 0) + 1);
  const ready = new MinHeap((x, y) => y[0] - x[0]);   // flipped comparator -> MAX-heap
  for (const [id, c] of cnt) ready.push([c, id]);     // [remaining count, job id]
  const cooling = new Deque();                        // [free at tick, [count, id]]
  let tick = 0;
  while (ready.size || cooling.size) {
    tick++;                                           // an idle tick still counts
    if (ready.size) {
      const [c, id] = ready.pop();
      if (c - 1 > 0) cooling.push([tick + cool, [c - 1, id]]);
    }
    if (cooling.size && cooling.front()[0] <= tick) ready.push(cooling.shift()[1]);
  }
  return tick;
};
```
]
Real output for `([1,1,2,2,3,3], 2)`; `([1,1,1], 2)`; `([1,2,3,4], 0)`;
`([5], 9)`; the empty list; `([1,1,1,1,2,2,3], 2)`:
```
6
7
4
1
0
10
```
]
#complexity(time: $O(n log n)$, space: $O(n)$)

#trap[
`tick++` happens *before* the work, so the loop counts idle ticks automatically: if
`ready` is empty but `cooling` is not, the tick is burned doing nothing. Many people
forget the idle case and get `([1,1,1], 2)` wrong (7 is right, 3 is the common wrong
answer).
]

#ex(23, tier: 2, asked: "GIC · pattern")[
*Shortest burst that reaches a target.* Given daily profit or loss numbers (they may be
negative) and a target $S$, find the *shortest* run of consecutive days whose total is at
least $S$. Return $-1$ if none exists.
Constraints: $n <= 10^5$, $|a_i| <= 10^4$, $|S| <= 10^9$.
Edge cases: all values negative; $S$ negative; empty array; one element equal to $S$.
]
#sol[

#approach(1, "All pairs", verdict: "O(n^2)")
Fix a start, walk right, keep the running total. Correct. With $n = 10^5$ that is
$5 times 10^9$ steps.

#approach(2, "Sliding window", verdict: "wrong when values may be negative")
The classic two-pointer window works *only* if every value is positive, because then the
running sum grows when you extend and shrinks when you cut. With a negative value in the
middle, extending the window can *lower* the sum, so shrinking is no longer safe.

#code(lang: "js", caption: "sliding window — valid only for all-positive input")[
```js
const shortestAtLeastPositive = (a, S) => {
  let sum = 0, left = 0, best = Infinity;
  for (let right = 0; right < a.length; right++) {
    sum += a[right];
    while (sum >= S) { best = Math.min(best, right - left + 1); sum -= a[left++]; }
  }
  return best === Infinity ? -1 : best;
};
```
]
Real output for `([2,3,1,2,4,3], 7)` and `([1,1,1], 9)`:
```
2 -1
```
And the proof that it is wrong with negatives: on `([84,-37,32,40,95], 167)` it reports
`5`, while the true answer is `3` (the run `32, 40, 95`). Once `left` has moved past a
negative value, it can never come back for it.

#approach(3, "Prefix sums + increasing deque", verdict: "O(n) — optimal, handles negatives")
Let `p[i]` be the sum of the first $i$ values. A run `a[j..i-1]` totals `p[i] - p[j]`. So
for each right end $i$ you want the *largest* $j < i$ with `p[i] - p[j] >= S`.

Keep a deque of candidate start indexes whose `p` values *increase*. Two deletions:
+ From the front: if `p[i] - p[front] >= S`, record the length and pop — a later $i$ would
  only give a longer run with the same start, so this start is finished forever.
+ From the back: if `p[back] >= p[i]`, pop. Index $i$ is newer *and* has a smaller prefix,
  so it is a strictly better start for everything after it.

#code(lang: "js", caption: "optimal: monotonic deque over prefix sums")[
```js
const shortestAtLeast = (a, S) => {
  const n = a.length;
  const p = new Array(n + 1).fill(0);
  for (let i = 0; i < n; i++) p[i + 1] = p[i] + a[i];
  const dq = new Deque();                                 // indexes into p, p increasing
  let best = Infinity;
  for (let i = 0; i <= n; i++) {                          // note: i <= n
    while (dq.size && p[i] - p[dq.front()] >= S) {        // front is the oldest usable start
      best = Math.min(best, i - dq.front());
      dq.shift();
    }
    while (dq.size && p[dq.back()] >= p[i]) dq.pop();     // a bigger prefix is useless
    dq.push(i);
  }
  return best === Infinity ? -1 : best;
};
```
]
Real output over six hand tests — `([84,-37,32,40,95], 167)`, `([1,1,1], 9)`,
`([2,-1,2], 3)`, `([5], 5)`, `([], 1)`, `([-1,-2], -1)` — plus a 3000-case random stress
test against the brute force, with negative values and negative $S$:
```
3 -1 3 1 -1 1
stress ok
```
]
#complexity(time: $O(n)$, space: $O(n)$)

*The idea that unlocked it:* rewrite "sum of a run" as "difference of two prefix sums".
The question then becomes "find the best earlier prefix", and *best earlier* is exactly
what a monotonic deque stores.

This is the chapter's second signature problem, so here it is in Python too.

#code(lang: "python", caption: "shortest run with sum at least S, negatives allowed")[
```python
from collections import deque

def shortest_at_least(a, S):
    n = len(a)
    p = [0] * (n + 1)
    for i, v in enumerate(a):
        p[i + 1] = p[i] + v
    dq = deque()                   # indexes into p, p values increasing
    best = None
    for i in range(n + 1):         # note: n + 1 prefix sums
        while dq and p[i] - p[dq[0]] >= S:
            length = i - dq.popleft()
            if best is None or length < best:
                best = length
        while dq and p[dq[-1]] >= p[i]:
            dq.pop()
        dq.append(i)
    return -1 if best is None else best
```
]
Run on the same six inputs, Python prints `3 -1 3 1 -1 1` — the same answers as the
JavaScript. Python integers are exact at any size, so there is no
`Number.MAX_SAFE_INTEGER` check to do on the prefix sums.

#trap[
The loop runs to `i <= n`, not `i < n`, because there are $n+1$ prefix sums. Miss this and
you never consider runs that end at the last element.
]

#section[Tier 3 — you need the insight]
#tier-header(3)

#ex(24, tier: 3, asked: "Amazon · pattern")[
*Best spaced pick.* Choose a non-empty subsequence of `a` such that any two chosen
positions are at most $k$ apart. Maximise the sum of the chosen values.
Constraints: $n <= 10^5$, $|a_i| <= 10^4$, $1 <= k <= n$. Target: $O(n)$.
Edge cases: all values negative (you must still pick one); a total large enough to be
worth checking against `Number.MAX_SAFE_INTEGER`; $k = 1$ (you must take a contiguous
run).
]
#sol[

#approach(1, "Try every subsequence", verdict: "O(2^n) — hopeless")
Useful only as a checker on tiny inputs (this is exactly what the stress test below does).

#approach(2, "Plain dp", verdict: "O(n k)")
Let `dp[i]` be the best total of a valid pick that *ends at* position $i$. Then
$ "dp"[i] = a[i] + max(0, max_(j = i-k)^(i-1) "dp"[j]) $
The `max(0, ...)` says "or start fresh at $i$". Scanning $k$ earlier cells for each $i$
gives $O(n k)$ — up to $10^{10}$ steps.

#approach(3, "dp + monotonic deque", verdict: "O(n) — optimal")
The inner `max` is the maximum of a sliding window over the `dp` array. Exactly the
template.

#code(lang: "js", caption: "dp with a sliding-window maximum")[
```js
const bestSpacedSum = (a, k) => {
  const n = a.length;
  if (n === 0) return 0;
  const dp = new Array(n);
  const dq = new Deque();                  // indexes, dp values decreasing
  let best = -Infinity;
  for (let i = 0; i < n; i++) {
    while (dq.size && dq.front() < i - k) dq.shift();
    const take = dq.size ? Math.max(0, dp[dq.front()]) : 0;
    dp[i] = a[i] + take;
    best = Math.max(best, dp[i]);
    while (dq.size && dp[dq.back()] <= dp[i]) dq.pop();
    dq.push(i);
  }
  return best;
};
```
]
Real output for `([10,2,-10,5,20], 2)`, `([-1,-2,-3], 1)`, `([3,-1,4,-1,5,-9,2,6], 3)`,
`([7], 1)`, `([], 2)` and `([2000000000,2000000000], 1)`, including a 400-case stress test
against the exponential brute force:
```
37 -1 20 7 0 4000000000
stress ok
```
`[-1,-2,-3]` with $k=1$ gives $-1$: you must pick something, so you pick the least bad.
The last test is the one a 32-bit language would fail — $4 times 10^9$ overflows a signed
32-bit integer. JavaScript holds it exactly, because it is far below
`Number.MAX_SAFE_INTEGER` $= 9007199254740991$. That is the check to run out loud, not
a type to declare.
]
#complexity(time: $O(n)$, space: $O(n)$)

*The idea that unlocked it:* whenever a dp recurrence says "the best of the last $k$
states", the deque replaces that inner loop. Recognising a sliding-window maximum *inside
a dp* is the single most valuable use of this chapter.

#trick[
Notice the expiry test here is `dq.front() < i - k`, not `<= i - k`. The window is
`[i-k, i-1]`, which has $k$ cells, and `i` itself is pushed only *after* `dp[i]` is read.
Draw the window on paper before you choose the comparison sign.
]

#note[
*Follow-up:* "now the array is a stream and you must answer after every arrival." Nothing
changes — the code already works online. It reads only `a[i]` and the deque, never a
future value. Say that out loud; it is the answer the interviewer wants.
]

#ex(25, tier: 3, asked: "Google · pattern")[
*Tile hopping.* You stand on tile 0 of a row of $n$ tiles and must reach tile $n-1$. From
tile $i$ you may jump to any tile $i+1 .. i+k$. Your score is the sum of every tile you
land on, including tile 0 and tile $n-1$. Maximise the score.
Constraints: $n <= 10^5$, $|a_i| <= 10^4$, $1 <= k <= n$.
Edge cases: $n = 1$; all tiles negative; $k >= n$ (jump straight to the end).
]
#sol[

#approach(1, "dp over all predecessors", verdict: "O(n k)")
`dp[i] = a[i] + max(dp[i-k..i-1])`. Straightforward, too slow.

#approach(2, "Same dp, deque for the inner max", verdict: "O(n) — optimal")
Unlike the previous problem there is no `max(0, ...)`: you *must* land somewhere, so
starting fresh is not allowed.

#code(lang: "js", caption: "tile hopping")[
```js
const bestJumpScore = (a, k) => {
  const n = a.length;
  if (n === 0) return 0;
  const dp = new Array(n).fill(-Infinity);
  dp[0] = a[0];
  const dq = new Deque();
  dq.push(0);
  for (let i = 1; i < n; i++) {
    while (dq.size && dq.front() < i - k) dq.shift();
    dp[i] = dp[dq.front()] + a[i];                       // you MUST land somewhere
    while (dq.size && dp[dq.back()] <= dp[i]) dq.pop();
    dq.push(i);
  }
  return dp[n - 1];
};
```
]
Real output for `([1,-1,-2,4,-7,3], 2)`, `([10,-5,-2,4,0,9], 3)`, `([0], 5)`,
`([-3,2,-1,6], 4)` and `([], 2)`, plus a 2000-case stress test against the $O(n k)$ dp:
```
7 23 0 5 0
stress ok
```
]
#complexity(time: $O(n)$, space: $O(n)$)

#trap[
`dq` can never become empty here, because index `i-1` was pushed on the previous step and
`i-1 >= i-k` for any $k >= 1$. That is why `dp[dq.front()]` is safe without a guard. If you
allowed $k = 0$ the guarantee breaks — and in JavaScript it breaks *quietly*:
`dq.front()` returns `undefined`, `dp[undefined]` is `undefined`, and every later `dp`
value becomes `NaN` with no error. Reject $k = 0$ at the top.
]

#note[
*Follow-up:* "what if some tiles are holes you may not land on?" Simply never push a hole
index into the deque, and set `dp[hole] = -Infinity`. `-Infinity` is the right sentinel
in JavaScript: it compares correctly with every real number and `-Infinity + x` is still
`-Infinity`, so an unreachable tile can never win. If the deque is empty when you reach
tile $i$, tile $i$ is unreachable.
]

#ex(26, tier: 3, asked: "D. E. Shaw · pattern")[
*Median of every window.* Report the median of every window of size $k$. For even $k$ the
median is the average of the two middle values.
Constraints: $n <= 10^5$. Target: $O(n log k)$.
Edge cases: $k = 1$; duplicates; $k = n$; negative values.
]
#sol[
A monotonic deque cannot help here: the median is not an extreme, so "smaller and older
means useless" is false. Every value in the window matters.

#approach(1, "Sort each window", verdict: "O(n k log k)")

#approach(2, "One sorted array, kept sorted", verdict: "O(n log k) searching, O(k) moving — fast enough")
JavaScript has no ordered multiset, so keep the window in a plain array that you *never*
let go out of order. Finding where a value belongs is a binary search — the toolkit
`lowerBound` from the *JS Toolkit* appendix. Inserting and removing is `splice`.

The median is then just a fixed slot: index $(k-1)/2$ for odd $k$, and the average of
slots $(k-1)/2$ and $(k-1)/2 + 1$ for even $k$. No iterator to walk, because an array
index does not move when the array shifts around it — it always points at the middle.

#code(lang: "js", caption: "median of every window")[
```js
const { lowerBound } = require('./toolkit.js');   // JS has no lower_bound of its own

const windowMedian = (a, k) => {
  const res = [];
  const n = a.length;
  if (k <= 0 || k > n) return res;
  const win = a.slice(0, k).sort((x, y) => x - y);   // NUMERIC comparator, never bare sort()
  const mid = (k - 1) >> 1;                          // lower of the two middles
  for (let i = k; ; i++) {
    res.push(k % 2 ? win[mid] : (win[mid] + win[mid + 1]) / 2);
    if (i === n) break;
    win.splice(lowerBound(win, a[i]), 0, a[i]);      // insert, keeping win sorted
    win.splice(lowerBound(win, a[i - k]), 1);        // remove ONE copy of the old value
  }
  return res;
};
```
]
Real output for `([1,3,-1,-3,5,3,6,7], 3)`, `([1,2,3,4], 2)`, `([5], 1)`,
`([4,4,4], 2)` and `([0,0], 1)`, ending with a 3000-case stress test against
sort-every-window:
```
1 -1 -1 3 5 6
1.5 2.5 3.5
5
4 4
0 0
stress ok
```
]
#complexity(time: $O(n log k)$, space: $O(k)$)

#trap[
*`win.sort()` with no comparator is lexicographic.* Tested in Node: `[10, 9, 1].sort()`
returns `[1, 10, 9]`, because it compares the *strings* `"10"`, `"9"`, `"1"`. Every
numeric sort in this book must be `sort((x, y) => x - y)`, which on the same array
returns `[1, 9, 10]`. Get this wrong here and the first window's median is nonsense while
every later window looks fine — the hardest kind of bug to find.
]

#trap[
`win.splice(lowerBound(win, v), 1)` removes *exactly one* copy of `v`. Do not reach for
`win.filter(x => x !== v)`, which removes every copy, nor `indexOf`, which is $O(k)$ and
defeats the binary search. And insert the new value *before* removing the old one, or the
two `lowerBound` calls can disagree about the array they are searching.
]

#note[
Honest cost: each `splice` moves up to $k$ elements, so this is $O(n k)$ element moves in
the worst case, with only the *searching* being $O(n log k)$. For $k$ up to a few
thousand it is comfortably fast, because `splice` moves memory in one block. If $k$ is
huge, use the two-heap version in the follow-up instead. Say this out loud — pretending
JavaScript has a `TreeMap` is the mistake the interviewer is listening for.
]

#note[
*Follow-up:* "do it with heaps." Keep a max-heap of the lower half and a min-heap of the
upper half, rebalance after every move, and use lazy deletion for values that have left
the window. Same $O(n log k)$, more code, and it is the version that generalises to a
pure stream with no window. You will build it in Chapter 14.
]

#ex(27, tier: 3, asked: "Microsoft · pattern")[
*Best floor for every span length.* For every window size $w$ from 1 to $n$, report the
largest value of "the minimum of a window of size $w$". Return all $n$ answers.
Constraints: $n <= 10^5$. Target: $O(n)$.
Edge cases: all values equal; strictly decreasing input; empty array; negatives.
]
#sol[
Running the sliding-window minimum once per $w$ costs $O(n^2)$. Turn the question around.

*Turn it around:* instead of asking "for this window, what is the minimum?", ask "for this
element, over how wide a span is it the minimum?" Element `a[i]` is the minimum of the
span that stretches from just after the nearest strictly smaller element on its left to
just before the nearest strictly smaller element on its right. Call that width `len`.
Then `a[i]` is a candidate answer for window size `len` — and for every size below `len`
too, which one backward sweep fixes up.

Nearest smaller on each side is the monotonic *stack* from Chapter 8.

#code(lang: "js", caption: "max of window minimums, for every window size")[
```js
const maxOfMins = (a) => {
  const n = a.length;
  if (n === 0) return [];
  const left = new Array(n), right = new Array(n);   // strictly smaller neighbour each side
  let st = [];                                       // a plain array: Chapter 8's stack
  for (let i = 0; i < n; i++) {
    while (st.length && a[st[st.length - 1]] >= a[i]) st.pop();
    left[i] = st.length ? st[st.length - 1] : -1;
    st.push(i);
  }
  st = [];
  for (let i = n - 1; i >= 0; i--) {
    while (st.length && a[st[st.length - 1]] >= a[i]) st.pop();
    right[i] = st.length ? st[st.length - 1] : n;
    st.push(i);
  }
  const best = new Array(n + 2).fill(-Infinity);
  for (let i = 0; i < n; i++) {
    const len = right[i] - left[i] - 1;   // a[i] is the min of this many-wide span
    best[len] = Math.max(best[len], a[i]);
  }
  for (let w = n - 1; w >= 1; w--) best[w] = Math.max(best[w], best[w + 1]);
  return best.slice(1, n + 1);
};
```
]
Real output, with a 1500-case stress test:
```
70 30 20 10 10 10 10
5 5 5
-1 -2 -3
0
stress ok
```
]
#complexity(time: $O(n)$, space: $O(n)$)

*The idea that unlocked it:* swap the roles of the loop variable and the answer. "For each
window, find the element" became "for each element, find its windows". This *contribution*
view is the standard escape hatch when a per-window sweep is too slow.

#note[
*Follow-up:* "why the backward sweep at the end?" Because an element that is the minimum
of a span of width 5 is also the minimum of some span of width 4, 3, 2 and 1 inside it.
The sweep `best[w] = max(best[w], best[w+1])` pushes every answer down to the smaller
sizes in one pass.
]

#ex(28, tier: 3, asked: "Goldman Sachs · pattern")[
*Shortest route when some moves are free.* A network of $n$ nodes has directed links. A
link costs either 0 (an internal transfer) or 1 (an external hop). Find the cheapest cost
from a source node to every node.
Constraints: $n, m <= 10^5$. Target: $O(n + m)$ — faster than Dijkstra's $O(m log n)$.
Edge cases: unreachable nodes; a node with no outgoing links; source equals target.
]
#sol[
With only two possible edge costs you do not need a heap. The classic phrasing uses one
*deque*: a free move goes to the *front* (handle it now, same cost level) and a paid move
goes to the *back* (next cost level). The deque then holds at most *two* distinct distance
values at any time, and it stays sorted by itself.

That "at most two" is the whole insight, and it gives a JavaScript-friendly way to write
the same algorithm: keep those two levels as two plain queues, `cur` (cost $d$) and `next`
(cost $d+1$). A free move pushes onto `cur`, a paid move onto `next`, and when `cur` runs
dry you swap them. Identical order of processing, identical complexity — and it needs only
`push` and `shift`, which is exactly what the toolkit `Deque` gives you in $O(1)$.

#code(lang: "js", caption: "0-1 BFS")[
```js
const zeroOneBFS = (n, adj, src) => {
  const dist = new Array(n).fill(Infinity);
  let cur = new Deque(), next = new Deque();   // cur: cost d;  next: cost d + 1
  dist[src] = 0;
  cur.push(src);
  while (cur.size || next.size) {
    if (cur.size === 0) { [cur, next] = [next, cur]; continue; }   // step to the next level
    const u = cur.shift();
    for (const [v, w] of adj[u]) {
      if (dist[u] + w < dist[v]) {
        dist[v] = dist[u] + w;
        if (w === 0) cur.push(v);     // free move: same cost level, handle it now
        else         next.push(v);    // paid move: one level later
      }
    }
  }
  return dist;
};
```
]
Real output on the 5-node chain with edges
$0 arrow.r 1$ (cost 0), $1 arrow.r 2$ (cost 1), $2 arrow.r 3$ (cost 0), $3 arrow.r 4$
(cost 1), then a check that an unreachable node stays at `Infinity`, then a one-node
graph, then a 500-case stress test against a plain Dijkstra:
```
0 0 1 1 2
true
0
stress ok
```
]
#complexity(time: $O(n + m)$, space: $O(n + m)$,
  note: "A node can be pushed more than once, but its distance only ever falls, and it can fall at most twice — so the total work stays linear.")

*The idea that unlocked it:* a priority queue is only needed when many different distances
are in flight. With costs in $\{0, 1\}$ there are only ever two, and "this level or the
next" is enough priority.

#trap[
Whatever you do, do *not* write the front insert as `arr.unshift(v)` on a plain array.
`unshift` has to slide every existing element up one slot, so it is $O(n)$, and the whole
$O(n + m)$ claim collapses to $O(n^2)$. Measured in Node: unshifting 200000 values onto a
plain array took *2695 ms*; pushing and shifting the same 200000 through the toolkit
`Deque` took *15 ms*. The toolkit `Deque` deliberately has no `unshift` — the two-queue
form above is how you get the same algorithm at the right speed.
]

#note[
*Follow-up:* "now costs are 0, 1 or 2." Split every cost-2 edge into two cost-1 edges with
a fake node in the middle, then run the same 0-1 BFS. For general small costs up to $C$,
use $C+1$ buckets (dial's algorithm). For arbitrary costs, use Dijkstra — Chapter 16.
]

#ex(29, tier: 3, asked: "Adobe · pattern")[
*Design: a queue with `getMin` in $O(1)$, and then the follow-ups.*
Constraints: up to $10^6$ operations. Edge cases: duplicates of the minimum; `getMin`
after the minimum is popped; an empty structure.
]
#sol[
Mirror of the MaxQueue: store the values in a deque kept *increasing*.

#code(lang: "js", caption: "MinQueue")[
```js
class MinQueue {
  constructor() { this.q = new Deque(); this.mn = new Deque(); }   // mn: values, INCREASING
  push(x) { this.q.push(x); while (this.mn.size && this.mn.back() > x) this.mn.pop(); this.mn.push(x); }
  pop()   { const v = this.q.shift(); if (this.mn.front() === v) this.mn.shift(); return v; }
  getMin() { return this.mn.front(); }
  get empty() { return this.q.size === 0; }
}
```
]
Real output pushing 4, 2, 6 then draining:
```
2 4 2 2 6 6 1
```
Read it as: min is 2; pop gives 4, min still 2; pop gives 2, min becomes 6; pop gives 6,
now empty (1).
]
#complexity(time: "amortised " + $O(1)$, space: $O(n)$)

*Follow-up 1 — "now support `pop` from both ends."* Then a single deque of candidates is
no longer enough, because a pop from the back can remove the newest minimum and there is
no record of what was behind it. Switch to two *min-stacks* (Chapter 8, Example 6) glued
back to back, which keeps $O(1)$ amortised; or accept $O(log k)$ with a sorted array plus
`lowerBound` and `splice`, since JavaScript has no ordered multiset to fall back on.

*Follow-up 2 — "now it is distributed across many machines."* Each machine keeps its own
MinQueue and reports its local minimum; a coordinator keeps a small heap of the $m$ local
minimums. A pop tells the coordinator which machine changed, and it fixes that one entry
in $O(log m)$.

*Follow-up 3 — "prove the amortised bound."* Every value is pushed into `mn` exactly once
and popped from `mn` at most once. So $n$ operations cause at most $2n$ deque moves. The
worst *single* operation is $O(n)$; the *average* over any sequence is $O(1)$.

#section[Dry run — sliding window maximum, line by line]

Input `a = [4, 2, 7, 1, 9, 3, 3, 8]`, window size `k = 3`.

The deque column shows `index(value)` from front to back. "Expired" is the index dropped
by rule 1; "Popped from back" lists the indexes dropped by rule 2.

#table(
  columns: (0.4fr, 0.4fr, 0.6fr, 0.9fr, 1.9fr, 0.6fr),
  align: (center, center, center, center, left, center),
  [*i*], [*a\[i\]*], [*expired*], [*popped back*], [*deque after*], [*output*],
  [0], [4], [—], [—], [0(4)], [—],
  [1], [2], [—], [—], [0(4) 1(2)], [—],
  [2], [7], [—], [1, 0], [2(7)], [*7*],
  [3], [1], [—], [—], [2(7) 3(1)], [*7*],
  [4], [9], [—], [3, 2], [4(9)], [*9*],
  [5], [3], [—], [—], [4(9) 5(3)], [*9*],
  [6], [3], [—], [5], [4(9) 6(3)], [*9*],
  [7], [8], [4], [6], [7(8)], [*8*],
)

Final answer: `7 7 9 9 9 8`.

*Step-by-step reading.*

+ *i = 0.* Deque empty, push 0. Window is not full ($i < k-1$), no output.
+ *i = 1.* `a[0] = 4 > a[1] = 2`, so rule 2 does not fire. Push 1. Deque `0(4) 1(2)`.
+ *i = 2.* `a[1] = 2 <= 7` → pop index 1. `a[0] = 4 <= 7` → pop index 0. Push 2.
  Window `[4,2,7]`, front is `2(7)` → output *7*.
+ *i = 3.* Front index 2 is not expired ($2 > 3-3 = 0$). `a[2] = 7 > 1`, so 1 just joins.
  Window `[2,7,1]` → output *7*.
+ *i = 4.* `a[3] = 1 <= 9` pop, `a[2] = 7 <= 9` pop. Deque `4(9)`. Output *9*.
+ *i = 5.* `9 > 3`, push. Deque `4(9) 5(3)`. Output *9*.
+ *i = 6.* `a[5] = 3 <= 3` → pop index 5 *even though the values are equal*. Push 6.
  Deque `4(9) 6(3)`. Output *9*.
+ *i = 7.* Rule 1: front is 4 and $4 <= 7-3 = 4$ → expire it. The 9 has left the window.
  Rule 2: `a[6] = 3 <= 8` → pop. Push 7. Deque `7(8)`. Window `[3,3,8]` → output *8*.

#note[
Why pop an equal value at $i = 6$? Because index 6 is newer. Both hold 3, so keeping the
older one buys nothing and it will expire sooner. Using `<=` instead of `<` keeps the
deque shorter and is still correct. Using `<` is *also* correct here — it just wastes
space. But in the `MaxQueue` of Example 16, which stores *values* and not indexes, `<=`
would be a real bug. Know which structure you are in.
]

#section[Practice]

#practice(tier: 0, time: "20 min")[
+ Rotate a queue left by $k$ places using only queue operations. Example: `1 2 3 4 5`
  with $k = 2$ becomes `3 4 5 1 2`. Handle $k$ larger than the size and an empty queue.
+ Given an array and $k$, return `true` if *every* window of size $k$ contains at least
  one zero.
+ Using a queue of strings, print the first $n$ numbers whose decimal digits are only 1
  and 2 (1, 2, 11, 12, 21, 22, 111, ...).
+ Write `minWindow` from memory, then write `maxWindow` by changing exactly two
  characters. State which two.
]

#practice(tier: 1, time: "45 min")[
5. Given prices for $n$ days and a window $k$, return the index of the day with the
   highest price in each window (if tied, the earliest such day).
6. Count how many windows of size $k$ satisfy "max − min ≤ L".
7. Longest run containing at most $K$ distinct values.
8. A queue holds server IDs. Remove every ID that appears more than once anywhere in the
   queue, keeping the original order of the survivors.
9. Given an array, return the sum of the *minimums* of all windows of size $k$. Watch for
   overflow.
]

#practice(tier: 2, time: "50 min")[
10. Shortest run of consecutive days whose total is at least $S$, where daily values may
    be negative.
11. A delivery grid has `.`, `#` and `T` (toll booth, costs 1 extra move to enter, normal
    cells cost 1). Find the cheapest path. (Hint: costs are 1 and 2 — see the 0-1 BFS
    follow-up.)
12. Design a structure that stores events with timestamps and answers "how many events in
    the last $W$ seconds?" in amortised $O(1)$.
]

#practice(tier: 3, time: "60 min")[
13. Maximise the sum of a subsequence in which consecutive chosen positions are at most
    $k$ apart, and at most $m$ items may be chosen in total. State the complexity.
14. Given an array, find the maximum over all subarrays of (subarray minimum × subarray
    sum), assuming all values are non-negative.
15. You are given a stream and a window $k$. After each arrival, report the *second*
    largest value in the current window. Aim for $O(log k)$ per arrival.
]

#key[
*1.* `k %= q.size()` first (guard the empty queue), then repeat `q.push(q.front()); q.pop();`
$k$ times.
#code(lang: "js", caption: "P1")[
```js
const rotateLeft = (q, k) => {
  if (q.size === 0) return;
  k %= q.size;                                   // read the size ONCE, before the loop
  for (let i = 0; i < k; i++) q.push(q.shift());
};
```
]
Real output: `1 2 3 4 5` with $k=2$ → `3 4 5 1 2`; empty queue → size `0`; `7 8` with
$k=4$ → `7 8`.

*2.* Keep a queue of zero indexes; expire the front as usual; if the queue is empty once
the window is full, the answer is false.
#code(lang: "js", caption: "P2")[
```js
const everyWindowHasZero = (a, k) => {
  const n = a.length;
  if (k <= 0 || k > n) return false;
  const zeros = new Deque();                   // indexes of zeros
  for (let i = 0; i < n; i++) {
    if (a[i] === 0) zeros.push(i);
    while (zeros.size && zeros.front() <= i - k) zeros.shift();
    if (i >= k - 1 && zeros.size === 0) return false;
  }
  return true;
};
```
]
Real output: `([1,0,2,3,0,4], 3)` → `true`; `([1,0,2,3,4,0], 3)` → `false`;
`([0], 1)` → `true`; $k > n$ → `false`.

*3.* Exactly Example 3 with `"1"` and `"2"` seeded into the queue, appending `"1"` and
`"2"` instead of `"0"` and `"1"`.

*4.* The two characters are the comparison in rule 2: `<=` becomes `>=`. Everything else
is identical.

*5.* Same template, but push `a[dq.front()]`'s *index* into the result instead of the
value. For ties, use strict `<` in rule 2 so the older index survives.

*6.* Two deques, count when the window is full.
#code(lang: "js", caption: "P6")[
```js
const countStableWindows = (a, k, L) => {
  const n = a.length;
  if (k <= 0 || k > n) return 0;
  const mx = new Deque(), mn = new Deque();
  let cnt = 0;
  for (let i = 0; i < n; i++) {
    while (mx.size && mx.front() <= i - k) mx.shift();
    while (mn.size && mn.front() <= i - k) mn.shift();
    while (mx.size && a[mx.back()] <= a[i]) mx.pop();
    while (mn.size && a[mn.back()] >= a[i]) mn.pop();
    mx.push(i); mn.push(i);
    if (i >= k - 1 && a[mx.front()] - a[mn.front()] <= L) cnt++;
  }
  return cnt;
};
```
]
Real output: `([1,3,2,6,4,4], 3, 2)` → `2`; `([5,5,5], 2, 0)` → `2`; empty → `0`.

*7.* Variable window plus a count map; shrink while the map has more than $K$ keys.
#code(lang: "js", caption: "P7")[
```js
const longestAtMostKDistinct = (a, K) => {
  if (K <= 0) return 0;
  const cnt = new Map();
  let left = 0, best = 0;
  for (let right = 0; right < a.length; right++) {
    cnt.set(a[right], (cnt.get(a[right]) || 0) + 1);
    while (cnt.size > K) {
      const c = cnt.get(a[left]) - 1;
      if (c === 0) cnt.delete(a[left]); else cnt.set(a[left], c);
      left++;
    }
    best = Math.max(best, right - left + 1);
  }
  return best;
};
```
]
Real output: `([1,2,1,3,4], 2)` → `3`; `([1,1,1], 1)` → `3`; `K=0` → `0`;
empty → `0`.

*8.* First pass: count every ID in a hash map. Second pass: pop each ID and push it back
only if its count is 1. Two passes, $O(n)$.

*9.* Identical to Example 10 but accumulate only `a[mn.front()]`. Check the total before
you trust it: $10^5$ windows times $10^9$ is $10^14$, which is still under
`Number.MAX_SAFE_INTEGER` $approx 9 times 10^15$, so a plain number is fine. One more
order of magnitude and you would need `BigInt`.

*10.* Example 23, approach 3. Answer for `([84,-37,32,40,95], 167)` is `3`.

*11.* Entering a `T` costs 2, entering a normal cell costs 1. Subtract 1 from every cost
so they become 0 and 1, run 0-1 BFS, then add back the number of steps — or split each
cost-2 edge with a fake middle node and run plain 0-1 BFS. Both are $O(r c)$.

*12.* A toolkit `Deque` of timestamps. On every query, `shift` from the front while
`front() <= now - W`, then return `.size`. Amortised $O(1)$ because each timestamp is
shifted off once. This is `countInWindow` from Example 21.

*13.* Add the count to the state: `dp[i][t]` = best total ending at $i$ having chosen $t$
items. For each fixed $t$ the recurrence is again "max of `dp[i-k..i-1][t-1]`", so run one
deque per $t$. Time $O(n m)$, space $O(n)$ if you keep only two rows.

*14.* Use the contribution view of Example 27. For each $i$, find the span where `a[i]` is
the minimum using a monotonic stack, then take the maximum-sum subarray inside that span
that contains $i$ — with all values non-negative that is the *whole* span, so the value is
`a[i] * (prefix[right] - prefix[left])`. One pass with a stack and prefix sums, $O(n)$.

*15.* JavaScript has no ordered multiset, so keep the window as a *sorted array*, exactly
as in Example 26: `win.splice(lowerBound(win, a[i]), 0, a[i])` to insert, then
`win.splice(lowerBound(win, a[i - k]), 1)` to remove one copy of the value leaving. The
second largest is then just `win[win.length - 2]`. The binary search is $O(log k)$; the
`splice` moves up to $k$ slots, which is the honest cost to quote. A monotonic deque
cannot do this at all — it deliberately throws away the second largest.
]

#revision[
*The one template.* Indexes in the deque. Three rules, in this order: expire the front,
pop weaker from the back, push, then read the front.

#code(lang: "js", caption: "memorise this")[
```js
const dq = new Deque();
for (let i = 0; i < n; i++) {
  while (dq.size && dq.front() <= i - k) dq.shift();   // 1 expire
  while (dq.size && a[dq.back()] <= a[i])  dq.pop();   // 2 dominate
  dq.push(i);                                          // 3 join
  if (i >= k - 1) res.push(a[dq.front()]);             // 4 read
}
```
]

*Switches.*
#table(
  columns: (1.2fr, 1.8fr),
  [*want*], [*change*],
  [window maximum], [rule 2 uses `<=` (deque decreasing)],
  [window minimum], [rule 2 uses `>=` (deque increasing)],
  [variable-size window], [replace rule 1 with "if front == left, pop front" inside the shrink loop],
  [dp over the last k states], [store dp values instead of array values; expiry becomes `< i - k`],
  [prefix-sum problems], [deque over `p[0..n]`, loop to `i <= n`],
)

*When to use what.*
#table(
  columns: (1.3fr, 0.8fr, 0.8fr),
  [*problem shape*], [*tool*], [*time*],
  [max/min of every fixed window], [monotonic deque], [$O(n)$],
  [median of every window], [sorted array + `lowerBound`], [$O(n log k)$ search],
  [second largest of every window], [sorted array + `lowerBound`], [$O(n log k)$ search],
  [longest window with max−min ≤ L], [two deques], [$O(n)$],
  [shortest window with sum ≥ S, negatives], [prefix + deque], [$O(n)$],
  [fewest moves, all costs equal], [queue BFS], [$O(V+E)$],
  [costs are 0 or 1], [0-1 BFS: two queues], [$O(V+E)$],
  [level-by-level spread], [queue, fix `sz` per level], [$O(V+E)$],
  [queue with O(1) max/min], [queue + monotonic deque], [amortised $O(1)$],
)

*Top JavaScript traps.*
+ Never build a queue on `arr.shift()` or `arr.unshift()` — both are $O(n)$. Measured:
  200000 `unshift` calls took *2695 ms*; the toolkit `Deque` did the same work in *15 ms*.
+ `dq.size` is a *getter*: no brackets. `dq.size()` throws
  `TypeError: dq.size is not a function`.
+ `arr.sort()` is *lexicographic*. `[10, 9, 1].sort()` gives `[1, 10, 9]`. Numbers always
  need `sort((a, b) => a - b)`.
+ No heap and no priority queue in the language: use the toolkit `MinHeap`, and flip the
  comparator to `(x, y) => y - x` for a max-heap.
+ No `TreeMap`, no ordered set, no multiset: use a sorted array with the toolkit
  `lowerBound` plus `splice`, and say the `splice` cost out loud.
+ `[...grid]` is a *shallow* copy. A 2-D grid needs `grid.map(row => [...row])`.
+ Reading past the end of a deque or array gives `undefined`, not an error — it turns into
  `NaN` several lines later. Guard with `dq.size` before every `front()` or `back()`.
+ `(head - 1) % cap` is $-1$ when `head` is 0, because `%` keeps the sign of the left
  operand. Write `(head - 1 + cap) % cap`.

*Top algorithm traps.*
+ Store indexes, not values, or you cannot detect expiry.
+ In BFS, take `const sz = q.size` *before* the level loop.
+ In BFS, mark visited on *push*, not on pop.
+ Check every running total against `Number.MAX_SAFE_INTEGER` $approx 9 times 10^15$;
  past it, switch to `BigInt`.
+ For the two-stack queue, pour only when the output stack is empty — otherwise you lose
  the amortised $O(1)$.
+ In a dp deque, the window is `[i-k, i-1]`, so expiry is `< i - k`, not `<= i - k`.
+ `MaxQueue` stores values, so its back-pop must use strict `<` to protect duplicates.

*Complexity you should be able to quote instantly.*
Sliding window max/min: $O(n)$ time, $O(k)$ space. Sorted-array window: $O(n log k)$
searching plus the `splice` moves. BFS on a grid: $O(r c)$. 0-1 BFS: $O(V + E)$.
Two-stack queue: amortised $O(1)$.
]

]
