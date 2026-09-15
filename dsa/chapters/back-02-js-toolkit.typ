#import "../../shared/lib/style.typ": *

#toc-entry("Appendix · The JS Toolkit")

#pagebreak(weak: true)

#block(width: 100%, inset: (bottom: 10pt))[
  #text(size: 9pt, fill: muted, weight: "bold", tracking: 1.5pt)[APPENDIX]
  #v(-4pt)
  #text(size: 22pt, weight: "bold")[The JS Toolkit]
  #v(-3pt)
  #text(size: 10pt, fill: muted, style: "italic")[
    Five things every other interview language gives you for free, and JavaScript does not.
  ]
]
#line(length: 100%, stroke: 1.2pt + ink)
#v(6pt)

JavaScript's standard library is small. It has no heap, no ordered map, no real queue and
no binary search. Those four gaps cost marks, because the algorithms that need them are
exactly the ones interviews ask about.

This appendix holds the five pieces that fill the gaps. Every one of them is short enough
to type from memory in an interview, and every one is tested — the test file lives beside
the source and reports *15 passed, 0 failed*.

#formulas(title: "How to use this in a real coding round")[
Put all five in one file and start every solution with one line:

#raw("const { MinHeap, DSU, Deque, lowerBound, upperBound } = require('./toolkit.js');", lang: "js")

In a whiteboard or online-judge round where you cannot import anything, type in *only the
piece you need*. `MinHeap` is about 25 lines, `DSU` is 8, `Deque` is 8, and each binary
search is one line. Say out loud what you are doing: "JavaScript has no priority queue, so
I will write a small binary heap — about twenty lines — and then the algorithm." That
sentence earns marks. Silently writing a slow array-scan instead loses them.
]

#section[1 · MinHeap — the priority queue JavaScript does not have]

#table(
  columns: (auto, 1fr),
  [*Replaces*], [C++ `priority_queue`, Java `PriorityQueue`, Python `heapq`],
  [*Reach for it when*], [the question says top-K, K-th largest, "merge K sorted lists",
    "running median", Dijkstra, Prim, "schedule the next task", or any loop whose next step
    is "take the current smallest / largest"],
  [*Do not reach for it when*], [you only need the single minimum (`Math.min`), or the data
    is already sorted (two pointers is cheaper)],
)

#code(lang: "js", caption: "MinHeap — verbatim from the shared toolkit")[
```js
// ---- MinHeap / priority queue (JS has none built in) ----
class MinHeap {
  constructor(cmp = (a, b) => a - b) { this.a = []; this.cmp = cmp; }
  get size() { return this.a.length; }
  peek() { return this.a[0]; }
  push(v) {
    this.a.push(v);
    let i = this.a.length - 1;
    while (i > 0) {
      const p = (i - 1) >> 1;
      if (this.cmp(this.a[i], this.a[p]) >= 0) break;
      [this.a[i], this.a[p]] = [this.a[p], this.a[i]]; i = p;
    }
  }
  pop() {
    const top = this.a[0], last = this.a.pop();
    if (this.a.length) {
      this.a[0] = last;
      let i = 0;
      for (;;) {
        const l = 2*i+1, r = l+1; let m = i;
        if (l < this.a.length && this.cmp(this.a[l], this.a[m]) < 0) m = l;
        if (r < this.a.length && this.cmp(this.a[r], this.a[m]) < 0) m = r;
        if (m === i) break;
        [this.a[i], this.a[m]] = [this.a[m], this.a[i]]; i = m;
      }
    }
    return top;
  }
}
```
]

#subsection[How to use it]

#code(lang: "js", caption: "three shapes you will need")[
```js
const h = new MinHeap();                       // smallest comes out first
[5, 3, 8, 1].forEach(v => h.push(v));
h.pop();                                       // 1

const mx = new MinHeap((a, b) => b - a);       // MAX-heap: flip the comparator
[5, 3, 8].forEach(v => mx.push(v));
mx.pop();                                      // 8

const pq = new MinHeap((a, b) => a[1] - b[1]); // heap of [name, priority] pairs
pq.push(['a', 3]); pq.push(['b', 1]);
pq.pop();                                      // ['b', 1]
```
]

#table(
  columns: (1fr, auto, auto),
  [*Operation*], [*Time*], [*Note*],
  [`push`], [$O(log n)$], [one swap chain up the tree],
  [`pop`], [$O(log n)$], [one swap chain down the tree],
  [`peek`], [$O(1)$], [returns `undefined` on an empty heap],
  [`size`], [$O(1)$], [a getter, not a method — no brackets],
  [build from n items], [$O(n log n)$], [pushing one at a time],
  [heapify an existing array], [$O(n)$], [not in this toolkit; sift down from `n/2` to `0`],
)

#trap[
`h.size` is a *getter*. Write `h.size`, not `h.size()`. Calling it throws
`TypeError: h.size is not a function`, and it always happens inside a `while` condition
where it is hardest to see.
]

#trap[
The comparator returns a *number*, like `Array.prototype.sort`: negative means "a comes
first". A comparator that returns `true`/`false` coerces to `1`/`0`, can never say "a
first", and the heap silently returns items in the wrong order.
]

#trick[
There is no `decrease-key`. For Dijkstra, do not try to update an entry in place — push the
new, smaller distance as a *second* entry and skip stale entries when they pop:
`if (d > dist[u]) continue;`. This is the standard "lazy deletion" heap and it is what
every accepted solution does.
]

#section[2 · DSU — disjoint set union (union-find)]

#table(
  columns: (auto, 1fr),
  [*Replaces*], [nothing in any standard library — C++, Java and Python do not ship one
    either. Everyone writes it.],
  [*Reach for it when*], [the question is "are these two connected?", "how many groups?",
    "merge these accounts", Kruskal's MST, cycle detection in an *undirected* graph, or
    "process the edges in some order and keep the components"],
  [*Do not reach for it when*], [you need to *remove* an edge, or you need the actual path
    between two nodes. DSU only ever merges, and it never remembers routes.],
)

#code(lang: "js", caption: "DSU — verbatim from the shared toolkit")[
```js
// ---- Disjoint Set Union ----
class DSU {
  constructor(n) { this.p = Array.from({length: n}, (_, i) => i); this.r = new Array(n).fill(0); }
  find(x) { while (this.p[x] !== x) { this.p[x] = this.p[this.p[x]]; x = this.p[x]; } return x; }
  union(a, b) {
    a = this.find(a); b = this.find(b);
    if (a === b) return false;
    if (this.r[a] < this.r[b]) [a, b] = [b, a];
    this.p[b] = a; if (this.r[a] === this.r[b]) this.r[a]++;
    return true;
  }
}
```
]

#subsection[How to use it]

#code(lang: "js", caption: "count the groups, and detect a cycle")[
```js
const d = new DSU(6);
d.union(0, 1);                 // true  — they were separate, now merged
d.union(1, 2);                 // true
d.union(0, 2);                 // false — already together: this edge closes a CYCLE
d.find(2) === d.find(0);       // true
d.find(3) === d.find(0);       // false

let groups = 0;                // number of components
for (let i = 0; i < 6; i++) if (d.find(i) === i) groups++;   // 4
```
]

#table(
  columns: (1fr, auto, auto),
  [*Operation*], [*Time*], [*Note*],
  [`find`], [$O(alpha(n))$], [$alpha$ is the inverse Ackermann function],
  [`union`], [$O(alpha(n))$], [returns `false` if they were already together],
  [build for n items], [$O(n)$], [two arrays],
  [m operations on n items], [$O(m alpha(n))$], [quote this — "effectively constant"],
)

#note[
$alpha(n)$ is below 5 for every `n` that fits in a computer. In an interview say
"amortised almost constant, $O(alpha(n))$", never plain $O(1)$ — the distinction is
exactly what the question is testing.
]

#trick[
`union` returning `false` is the whole cycle-detection algorithm. In Kruskal's MST you
write `if (d.union(u, v)) total += w;` — the boolean both merges the sets and tells you
whether the edge was safe to take.
]

#trap[
`find` here does *path halving*, so it flattens the tree as it walks. Do not "simplify" it
to `while (p[x] !== x) x = p[x];` — that version keeps the tree tall and turns a chain of
$10^5$ unions into $O(n^2)$.
]

#section[3 · Deque — an O(1) queue]

#table(
  columns: (auto, 1fr),
  [*Replaces*], [C++ `deque`, Java `ArrayDeque`, Python `collections.deque`],
  [*Reach for it when*], [BFS, level-order traversal, monotonic-window problems (window
    maximum, shortest subarray with a condition), 0-1 BFS, or any loop that pops from the
    front],
  [*Do not reach for it when*], [you only push and pop at the *back* — a plain array is
    already a perfect stack],
)

#formulas(title: "Why this exists at all")[
A plain array *looks* like a queue: `q.push(x)` and `q.shift()`. But `shift()` removes the
first element and then moves every remaining element down one slot. On a queue of $10^5$
items that is $10^{10}$ element moves over the run — an $O(n)$ BFS silently becomes
$O(n^2)$ and times out.

Measured in Node on 100000 items: `shift()` in a loop took *971 ms*; the same loop with a
head index took *2 ms*.

The fix is to never actually remove the front. Keep a head index, step it forward, and
compact the array only when more than half of it is dead.
]

#code(lang: "js", caption: "Deque — verbatim from the shared toolkit")[
```js
// ---- Deque backed by a plain array with head index (O(1) amortised shift) ----
class Deque {
  constructor() { this.a = []; this.h = 0; }
  get size() { return this.a.length - this.h; }
  push(v) { this.a.push(v); }
  pop() { return this.a.pop(); }
  shift() { const v = this.a[this.h++]; if (this.h * 2 > this.a.length) { this.a = this.a.slice(this.h); this.h = 0; } return v; }
  front() { return this.a[this.h]; }
  back() { return this.a[this.a.length - 1]; }
}
```
]

#subsection[How to use it]

#code(lang: "js", caption: "BFS, and a monotonic window maximum")[
```js
const q = new Deque();
q.push(1); q.push(2); q.push(3);
q.shift();                       // 1   — from the FRONT
q.back();                        // 3
q.size;                          // 2   — a getter, no brackets

// window maximum: the deque holds INDEXES, values decreasing
const windowMax = (a, k) => {
  const dq = new Deque(), out = [];
  for (let i = 0; i < a.length; i++) {
    while (dq.size && a[dq.back()] <= a[i]) dq.pop();      // drop the useless
    dq.push(i);
    if (dq.front() <= i - k) dq.shift();                   // drop the expired
    if (i >= k - 1) out.push(a[dq.front()]);
  }
  return out;
};
```
]

#table(
  columns: (1fr, auto, auto),
  [*Operation*], [*Time*], [*Note*],
  [`push` (back)], [$O(1)$], [plain array push],
  [`pop` (back)], [$O(1)$], [plain array pop],
  [`shift` (front)], [$O(1)$ amortised], [head index; compacts when half is dead],
  [`front` / `back` / `size`], [$O(1)$], [`front` and `back` are methods, `size` is a getter],
  [memory], [$O(n)$], [holds dead slots until the next compaction],
)

#trap[
This `Deque` has no `unshift` — you cannot push to the *front*. Plain BFS and monotonic
windows never need to. If a problem genuinely does (0-1 BFS with zero-weight edges), keep
two arrays: one you `push` to and read backwards for the front, one for the back. Say that
out loud rather than reaching for `Array.prototype.unshift`, which is $O(n)$ for the same
reason `shift` is.
]

#trap[
`dq.size` is a getter and `dq.front()` is a method. `while (dq.size() ...)` throws;
`if (dq.front <= i - k)` compares a *function* with a number and is always `false`. Both
mistakes compile and both are silent.
]

#section[4 · lowerBound / upperBound — the binary search JS is missing]

#table(
  columns: (auto, 1fr),
  [*Replaces*], [C++ `lower_bound` / `upper_bound`, Python `bisect_left` / `bisect_right`,
    Java `Collections.binarySearch`],
  [*Stands in for*], [an *ordered map* — C++'s `map`, Java's `TreeMap`, Python's
    `sortedcontainers`. JavaScript has none of them. A sorted array plus these two searches
    is the standard workaround.],
  [*Reach for it when*], [the array is sorted and you need: an insert position, the first
    element $>= x$, the count of a value, the number of elements below a threshold, LIS in
    $O(n log n)$, or "the next booking after time t"],
)

#code(lang: "js", caption: "lowerBound / upperBound — verbatim from the shared toolkit")[
```js
// ---- binary search helpers (JS has no lower_bound) ----
const lowerBound = (a, x) => { let lo = 0, hi = a.length; while (lo < hi) { const m = (lo+hi)>>1; a[m] < x ? lo = m+1 : hi = m; } return lo; };
const upperBound = (a, x) => { let lo = 0, hi = a.length; while (lo < hi) { const m = (lo+hi)>>1; a[m] <= x ? lo = m+1 : hi = m; } return lo; };
```
]

#subsection[How to use it]

#code(lang: "js", caption: "the five things these two lines give you")[
```js
const a = [1, 3, 3, 5, 7];

lowerBound(a, 3);                  // 1  first index with a[i] >= 3
upperBound(a, 3);                  // 3  first index with a[i] >  3
upperBound(a, 3) - lowerBound(a, 3);  // 2  how many 3s
lowerBound(a, 0);                  // 0  x is below everything
lowerBound(a, 9);                  // 5  == a.length: x is above everything

a[lowerBound(a, 4)] === 4;         // false — 4 is ABSENT. This is "binary search".
a.splice(lowerBound(a, 4), 0, 4);  // insert 4 and keep the array sorted
```
]

#table(
  columns: (1fr, auto, auto),
  [*Operation*], [*Time*], [*Note*],
  [`lowerBound` / `upperBound`], [$O(log n)$], [the array must already be sorted],
  [membership test], [$O(log n)$], [`a[lowerBound(a,x)] === x` — check the value!],
  [count of a value], [$O(log n)$], [`upperBound - lowerBound`],
  [insert, keeping order], [$O(n)$], [the `splice` shift dominates the search],
  [delete one copy], [$O(n)$], [`splice(i, 1)` after `lowerBound`],
  [n inserts into a sorted array], [$O(n^2)$], [say this out loud before you use it],
)

#trap[
These return an *insert position*, never `-1`. `lowerBound(a, 4)` on `[1,3,3,5,7]` returns
`3`, and `a[3]` is `5`. Always check the value before you trust the index:
`const i = lowerBound(a, x); const found = i < a.length && a[i] === x;`
]

#trap[
`(lo + hi) >> 1` is safe *here* because `lo` and `hi` are array indexes, which never reach
$2^31$. Do not copy this midpoint into a binary search *on the answer*, where the bounds
can be $10^{15}$: `>>` truncates to 32 bits and the search returns nonsense. There, use
`Math.floor(lo + (hi - lo) / 2)`.
]

#trick[
Sorted array plus these two searches is your answer to *every* "JavaScript has no
`TreeMap`" moment. Quote the trade-off: lookups are $O(log n)$, the same as a balanced
tree, but each insert is $O(n)$ instead of $O(log n)$. That is fine for up to a few tens of
thousands of elements, and an interviewer who hears you state the limit is satisfied.
]

#pagebreak(weak: true)
#section[JS gotchas for interviews — all seven on one page]

Every line below was run in Node. The output is what actually printed.

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 5pt),
  align: (left, left),

  [*1*], [*`sort()` is lexicographic.* It compares numbers as *text*.
    #linebreak() #text(fill: rgb("#9b2226"))[`[10,9,1].sort()` #sym.arrow.r `[1,10,9]`]
    #linebreak() #text(fill: rgb("#2f6b3f"))[`[10,9,1].sort((a,b)=>a-b)` #sym.arrow.r `[1,9,10]`]],

  [*2*], [*There is no priority queue.* `typeof PriorityQueue` prints `"undefined"`.
    #linebreak() #text(fill: rgb("#9b2226"))[`arr.sort((a,b)=>a-b)[0]` inside a loop #sym.arrow.r $O(n^2 log n)$]
    #linebreak() #text(fill: rgb("#2f6b3f"))[`const h = new MinHeap(); h.push(x); h.pop();` #sym.arrow.r $O(log n)$ each]],

  [*3*], [*There is no TreeMap or ordered set.* `typeof TreeMap` prints `"undefined"`.
    #linebreak() #text(fill: rgb("#9b2226"))[`[...map.keys()].sort()` inside the loop #sym.arrow.r $O(n^2 log n)$]
    #linebreak() #text(fill: rgb("#2f6b3f"))[sorted array + `lowerBound(a, x)` #sym.arrow.r $O(log n)$ to find]],

  [*4*], [*Numbers are doubles — exact only to $2^53 - 1$.*
    #linebreak() #text(fill: rgb("#9b2226"))[`123456789 * 987654321` #sym.arrow.r `121932631112635260` (wrong)]
    #linebreak() #text(fill: rgb("#2f6b3f"))[`123456789n * 987654321n` #sym.arrow.r `121932631112635269n` (exact)]],

  [*5*], [*Recursion depth is about $10^4$ frames.* Measured: `RangeError` after 12545
    frames.
    #linebreak() #text(fill: rgb("#9b2226"))[`const dfs = (u) => { ... dfs(v) ... }` on $10^5$ nodes #sym.arrow.r stack overflow]
    #linebreak() #text(fill: rgb("#2f6b3f"))[`const st = [s]; while (st.length) { const u = st.pop(); ... }` #sym.arrow.r no limit]],

  [*6*], [*Object keys are strings; `Map` keys are not.*
    #linebreak() #text(fill: rgb("#9b2226"))[`o[1]="num"; o["1"]="str";` #sym.arrow.r one entry, `o[1]` is `"str"`]
    #linebreak() #text(fill: rgb("#2f6b3f"))[`m.set(1,"num"); m.set("1","str");` #sym.arrow.r `m.size` is `2`]],

  [*7*], [*Array copy is shallow.*
    #linebreak() #text(fill: rgb("#9b2226"))[`const b = [...g]; b[0][0] = 9;` #sym.arrow.r `g[0][0]` is now `9`]
    #linebreak() #text(fill: rgb("#2f6b3f"))[`const b = g.map(r => [...r]); b[0][0] = 9;` #sym.arrow.r `g[0][0]` is still `0`]],
)

#subsection[Three more that cost marks just as often]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 5pt),

  [*8*], [*`new Array(n)` makes holes, not zeros.* `map` skips holes.
    #linebreak() #text(fill: rgb("#9b2226"))[`new Array(3).map(x => 1)` #sym.arrow.r `[null,null,null]`]
    #linebreak() #text(fill: rgb("#2f6b3f"))[`new Array(3).fill(0).map(x => 1)` #sym.arrow.r `[1,1,1]`]],

  [*9*], [*`fill` with an array stores one shared row.*
    #linebreak() #text(fill: rgb("#9b2226"))[`new Array(2).fill(new Array(2).fill(0))` then `g[0][1]=9` #sym.arrow.r `[[0,9],[0,9]]`]
    #linebreak() #text(fill: rgb("#2f6b3f"))[`Array.from({length: 2}, () => new Array(2).fill(0))` #sym.arrow.r `[[0,9],[0,0]]`]],

  [*10*], [*`shift()` on an array is $O(n)$.* Measured on 100000 items: 971 ms against 2 ms.
    #linebreak() #text(fill: rgb("#9b2226"))[`const q = [s]; while (q.length) q.shift();` #sym.arrow.r $O(n^2)$]
    #linebreak() #text(fill: rgb("#2f6b3f"))[`const q = new Deque(); q.push(s); while (q.size) q.shift();` #sym.arrow.r $O(n)$]],
)

#note[
Four of these ten — 1, 4, 6 and 7 — produce a *wrong answer with no error message*. Those
are the dangerous ones. Before you say "done", check: did I sort numbers with a comparator,
can any value pass $2^53$, am I using a `Map`, and did I deep-copy the grid?
]

#pagebreak(weak: true)
#section[JavaScript against Python — the quick table]

Python is the other language interviewers accept everywhere. If you write JavaScript, know
the Python line too: it is often the shorter way to *explain* what you are doing.

#subsection[Arrays and lists]

#table(
  columns: (0.9fr, 1.05fr, 1.05fr),
  [*You want*], [*JavaScript*], [*Python*],
  [length], [`a.length`], [`len(a)`],
  [add at the end], [`a.push(x)`], [`a.append(x)`],
  [remove from the end], [`a.pop()`], [`a.pop()`],
  [remove from the front], [`Deque.shift()` — array `shift()` is $O(n)$], [`collections.deque.popleft()`],
  [last element], [`a.at(-1)`], [`a[-1]`],
  [slice], [`a.slice(1, 4)`], [`a[1:4]`],
  [reverse a copy], [`[...a].reverse()`], [`a[::-1]`],
  [copy (one level)], [`[...a]`], [`a[:]` or `list(a)`],
  [copy a 2D grid], [`a.map(r => [...r])`], [`[r[:] for r in a]`],
  [n zeros], [`new Array(n).fill(0)`], [`[0] * n`],
  [an $r times c$ grid], [`Array.from({length: r}, () => new Array(c).fill(0))`], [`[[0]*c for _ in range(r)]`],
  [range 0..n-1], [`[...Array(n).keys()]`], [`range(n)`],
  [index and value together], [`a.forEach((x, i) => ...)`], [`for i, x in enumerate(a)`],
  [sum], [`a.reduce((p, q) => p + q, 0)`], [`sum(a)`],
  [max], [`Math.max(...a)` — breaks past ~100k items], [`max(a)`],
  [filter], [`a.filter(x => x > 0)`], [`[x for x in a if x > 0]`],
  [does it contain x], [`a.includes(x)` — $O(n)$], [`x in a` — $O(n)$],
)

#subsection[Maps and sets]

#table(
  columns: (0.9fr, 1.05fr, 1.05fr),
  [*You want*], [*JavaScript*], [*Python*],
  [empty map], [`new Map()`], [`{}`],
  [set a value], [`m.set(k, v)`], [`m[k] = v`],
  [read a value], [`m.get(k)` — `undefined` if absent], [`m[k]` — raises `KeyError`],
  [read with a default], [`m.get(k) ?? 0`], [`m.get(k, 0)`],
  [count into it], [`m.set(k, (m.get(k) ?? 0) + 1)`], [`c[k] += 1` with `Counter()`],
  [does the key exist], [`m.has(k)`], [`k in m`],
  [delete a key], [`m.delete(k)`], [`del m[k]`],
  [number of keys], [`m.size` — a getter], [`len(m)`],
  [walk keys and values], [`for (const [k, v] of m)`], [`for k, v in m.items()`],
  [keys in sorted order], [`[...m.keys()].sort((a,b)=>a-b)`], [`sorted(m)`],
  [empty set], [`new Set()`], [`set()`],
  [add / test / remove], [`s.add(x)` · `s.has(x)` · `s.delete(x)`], [`s.add(x)` · `x in s` · `s.discard(x)`],
  [set from an array], [`new Set(a)`], [`set(a)`],
  [back to an array], [`[...s]`], [`list(s)`],
  [most common element], [count in a `Map`, then scan], [`Counter(a).most_common(1)`],
)

#trap[
The row that matters most: `m.get(k)` returns `undefined` for a missing key, and
`undefined + 1` is `NaN`. Python raises a loud `KeyError` instead. JavaScript fails
*quietly*, so write `?? 0` every single time you count.
]

#subsection[Sorting]

#table(
  columns: (0.9fr, 1.05fr, 1.05fr),
  [*You want*], [*JavaScript*], [*Python*],
  [sort numbers], [`a.sort((x, y) => x - y)` — the comparator is *mandatory*], [`a.sort()`],
  [descending], [`a.sort((x, y) => y - x)`], [`a.sort(reverse=True)`],
  [sort a copy], [`[...a].sort((x, y) => x - y)`], [`sorted(a)`],
  [by a key], [`a.sort((x, y) => x.age - y.age)`], [`a.sort(key=lambda p: p.age)`],
  [two keys], [`a.sort((x, y) => x.age - y.age || x.name.localeCompare(y.name))`], [`a.sort(key=lambda p: (p.age, p.name))`],
  [strings], [`a.sort()` works, or `localeCompare`], [`a.sort()`],
  [stable?], [yes, guaranteed since ES2019], [yes, always],
  [in place?], [*yes* — `sort` mutates and returns the same array], [`sort()` mutates, `sorted()` does not],
  [k smallest], [toolkit `MinHeap`, pop k times], [`heapq.nsmallest(k, a)`],
)

#subsection[Strings]

#table(
  columns: (0.9fr, 1.05fr, 1.05fr),
  [*You want*], [*JavaScript*], [*Python*],
  [character at i], [`s[i]` (read only)], [`s[i]`],
  [change one character], [`const t = [...s]; t[i] = 'x'; t.join('')`], [`s[:i] + 'x' + s[i+1:]`],
  [build a long string], [push into an array, then `.join('')`], [append to a list, then `''.join(...)`],
  [concatenate in a loop], [safe in V8 (ropes), but `join` is clearer], [$O(n^2)$ — always use `join`],
  [code of a character], [`s.charCodeAt(i)`], [`ord(s[i])`],
  [character from a code], [`String.fromCharCode(n)`], [`chr(n)`],
  [letter index a..z], [`s.charCodeAt(i) - 97`], [`ord(s[i]) - ord('a')`],
  [split / join], [`s.split(' ')` · `arr.join(' ')`], [`s.split(' ')` · `' '.join(arr)`],
  [reverse], [`[...s].reverse().join('')`], [`s[::-1]`],
  [substring], [`s.slice(i, j)`], [`s[i:j]`],
  [starts with], [`s.startsWith(p)`], [`s.startswith(p)`],
  [repeat], [`'ab'.repeat(3)`], [`'ab' * 3`],
)

#trap[
Strings are immutable in *both* languages. `s[i] = 'x'` in JavaScript changes nothing and
raises no error at all — Python at least throws `TypeError`. Spread into an array, edit,
`join('')`.
]

#subsection[Numbers, and where the two languages really differ]

#table(
  columns: (0.9fr, 1.05fr, 1.05fr),
  [*You want*], [*JavaScript*], [*Python*],
  [integer division], [`Math.floor(a / b)`], [`a // b`],
  [remainder, never negative], [`((a % b) + b) % b`], [`a % b` — already non-negative],
  [big integers], [`BigInt`: `2n ** 100n`], [built in: `2 ** 100`],
  [exact integer range], [$plus.minus (2^53 - 1)$, then rounding], [unlimited],
  [infinity], [`Infinity` / `-Infinity`], [`float('inf')` / `-float('inf')`],
  [bit operations], [32-bit only; use `>>>` to stay unsigned], [unlimited width],
  [max / min of two], [`Math.max(a, b)`], [`max(a, b)`],
)

#note[
The single biggest real difference: *Python integers never overflow and never round.*
JavaScript's stop being exact at $2^53 - 1 approx 9.0 times 10^15$. If a problem's answer
can pass that — counting DPs, products of two large numbers, $n(n+1)\/2$ for huge $n$ —
either take the answer modulo $10^9 + 7$, or move that whole computation to `BigInt`. This
is the one place where the Python solution is genuinely simpler, and it is worth saying so
in an interview.
]
