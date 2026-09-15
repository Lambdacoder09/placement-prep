#import "../../shared/lib/style.typ": *

#chapter(
  num: 14,
  title: "Heaps & Priority Queues",
  tagline: "A heap answers one question fast — what is the smallest thing left? — and that single question solves top-K, merge-K, medians and half of all greedy problems.",
)[

#section[Pattern in one page]

#formulas(title: "The one rule")[
A *min-heap* is a binary tree where every parent is `<=` both of its children. (A
*max-heap* flips the sign.) That is the *only* rule. Note what it does *not* say:

- It says nothing about left versus right. A heap is *not* sorted.
- It only promises one thing: *the smallest item is at the root*.

Two more facts make it fast and tiny:

+ The tree is *complete* — every level is full except possibly the last, which fills from
  the left. So it can live in a plain array with no pointers at all.
+ With the array layout, a node at index `i` has parent `(i-1)/2`, children `2i+1` and
  `2i+2`. Height is always $floor(log_2 n)$.
]

#diagram(height: 5.4cm, caption: "The same min-heap twice: as a tree, and as the array it really is. Node a[1]=3 has children a[3]=5 and a[4]=7.")[
  #dnode(6.4cm, 0cm, 1.1cm, 0.6cm, "1")
  #dnode(3.4cm, 1.2cm, 1.1cm, 0.6cm, "3")
  #dnode(9.4cm, 1.2cm, 1.1cm, 0.6cm, "9")
  #dnode(2.0cm, 2.4cm, 1.1cm, 0.6cm, "5")
  #dnode(4.8cm, 2.4cm, 1.1cm, 0.6cm, "7")
  #darrow(6.95cm, 0.6cm, 3.95cm, 1.2cm)
  #darrow(6.95cm, 0.6cm, 9.95cm, 1.2cm)
  #darrow(3.95cm, 1.8cm, 2.55cm, 2.4cm)
  #darrow(3.95cm, 1.8cm, 5.35cm, 2.4cm)
  #dnode(0.0cm, 3.8cm, 1.7cm, 0.7cm, "a[0]=1", fill: rgb("#f7f0e8"))
  #dnode(1.8cm, 3.8cm, 1.7cm, 0.7cm, "a[1]=3", fill: rgb("#f7f0e8"))
  #dnode(3.6cm, 3.8cm, 1.7cm, 0.7cm, "a[2]=9", fill: rgb("#f7f0e8"))
  #dnode(5.4cm, 3.8cm, 1.7cm, 0.7cm, "a[3]=5", fill: rgb("#f7f0e8"))
  #dnode(7.2cm, 3.8cm, 1.7cm, 0.7cm, "a[4]=7", fill: rgb("#f7f0e8"))
]

#subsection[The two moves: sift up and sift down]

Every heap operation is one of two repairs.

- *Sift up* — a value is too small for its place. Swap it with its parent, again and
  again, until the parent is smaller. Used after `push`.
- *Sift down* — a value is too big for its place. Swap it with its *smaller* child, again
  and again, until both children are bigger. Used after `pop`.

Each repair walks one root-to-leaf path, so each costs $O(log n)$.

#trap[
*JavaScript has no heap and no priority queue.* Not in the language, not in the standard
library. Python has `heapq`, Java has `PriorityQueue`, C++ has `priority_queue` — JS has
nothing. You either write the twenty lines below or you carry them in. That is why this
book ships a tested `MinHeap` in the *JS Toolkit* appendix and every later chapter just
does `const { MinHeap } = require('./toolkit.js')`.

This chapter is the one place where we write it out in full, because this chapter is
about *how it works*.
]

#code(lang: "js", caption: "A complete min-heap, written by hand")[
```js
class MinHeap {
  // cmp(a, b) < 0 means "a belongs closer to the root"
  constructor(cmp = (a, b) => a - b) { this.a = []; this.cmp = cmp; }
  get size() { return this.a.length; }
  peek() { return this.a[0]; }                 // a[0] is always the smallest

  siftUp(i) {
    while (i > 0) {
      const p = (i - 1) >> 1;
      if (this.cmp(this.a[p], this.a[i]) <= 0) break;   // parent smaller: done
      [this.a[p], this.a[i]] = [this.a[i], this.a[p]];
      i = p;
    }
  }

  siftDown(i) {
    const n = this.a.length;
    for (;;) {
      const l = 2 * i + 1, r = 2 * i + 2;
      let small = i;
      if (l < n && this.cmp(this.a[l], this.a[small]) < 0) small = l;
      if (r < n && this.cmp(this.a[r], this.a[small]) < 0) small = r;
      if (small === i) break;                  // both children bigger: done
      [this.a[i], this.a[small]] = [this.a[small], this.a[i]];
      i = small;
    }
  }

  push(v) { this.a.push(v); this.siftUp(this.a.length - 1); }

  pop() {
    const top = this.a[0], last = this.a.pop();
    if (this.a.length) { this.a[0] = last; this.siftDown(0); }
    return top;
  }

  build(vals) {                                // O(n), not O(n log n)
    this.a = [...vals];
    for (let i = (this.a.length >> 1) - 1; i >= 0; i--) this.siftDown(i);
    return this;
  }
}
```
]

#code(lang: "text", caption: "Real output")[
```text
push 5,3,9,1,7 -> array [1 3 9 5 7]   valid heap = yes
pop order: 1 3 5 7 9
build from [9,4,7,1,-3,8,0] -> [-3 1 0 9 4 8 7]  valid = yes  top = -3
empty build -> size 0, valid = yes
one element -> top 42
duplicates [2,2,2] -> [2 2 2], valid = yes
```
]

#note[
`[this.a[p], this.a[i]] = [this.a[i], this.a[p]]` is JavaScript's swap: build a pair on
the right, destructure it back on the left. There is no `swap` function in the language.

`(i - 1) >> 1` is the parent index. `>> 1` is an integer halving that also truncates, so
it replaces C-style integer division. Use it everywhere a heap index is computed —
`Math.floor((i - 1) / 2)` is the same thing and three times as long.
]

#trap[
`pop()` must move the *last* element to the root and shrink, then sift down. A common
bug is to move the *smaller child* up recursively — that leaves a hole in the middle and
breaks the "complete tree" property, which breaks the index arithmetic.
]

#subsection[Why `build` is O(n) and not O(n log n)]

You call `siftDown` on `n/2` nodes, and each call is "up to $log n$". So the lazy bound is
$O(n log n)$. But almost every node is near the *bottom*, where `siftDown` has almost
nothing to do.

#table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, center),
  [*Level from the bottom*], [*Nodes on it*], [*Max sift distance*], [*Work*],
  [0 (leaves)], [$n/2$], [0], [0],
  [1], [$n/4$], [1], [$n/4$],
  [2], [$n/8$], [2], [$2n/8$],
  [3], [$n/16$], [3], [$3n/16$],
  [k], [$n/2^(k+1)$], [k], [$k n/2^(k+1)$],
)

Total work $= n sum_(k=1)^(log n) k/2^(k+1)$, and $sum_(k>=1) k/2^(k+1)$ converges to 1.
So the total is below $n$. *Build is linear.*

#trick[
Inserting `n` items one by one is $O(n log n)$. Calling `build` on the whole array is
$O(n)$. If you already have all the data, always build — never push in a loop.
]

#subsection[The comparator — one rule, three heaps]

One class covers every heap you need. The comparator decides what "smallest" means, and
the root is always whatever the comparator calls smallest.

#code(lang: "js", caption: "min-heap, max-heap and a custom order")[
```js
const minh = new MinHeap();                    // smallest on top (the default)
const maxh = new MinHeap((a, b) => b - a);     // biggest on top — just flip it

// a custom order: min-heap on .cnt, ties broken by the smaller .id
const pq = new MinHeap((x, y) => x.cnt - y.cnt || x.id - y.id);
```
]

#trap[
A heap comparator obeys exactly the same rules as a `sort` comparator, and breaks in
exactly the same ways.

- It must return a *number*, never a boolean. `(a, b) => a.cnt > b.cnt` returns
  `true`/`false`, which coerce to `1`/`0`; the heap never sees a negative and silently
  stops ordering anything. Write `(a, b) => a.cnt - b.cnt`.
- Chain tie-breaks with `||`, because `0` is falsy:
  `(x, y) => x.cnt - y.cnt || x.id - y.id`.
- There is no separate "max-heap" class to remember. `(a, b) => b - a` *is* the max-heap.

And the rule to say out loud once: *the element the comparator calls smallest ends up at
the root, and the root is what `pop()` hands back.*
]

#subsection[When to reach for a heap]

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*You need*], [*Heap?*], [*Why*],
  [the k largest of n, k much smaller than n], [yes], [$O(n log k)$ beats $O(n log n)$],
  [the whole list sorted], [no], [`a.sort((x, y) => x - y)`],
  [the smallest item, repeatedly, while inserting], [yes], [this is the definition],
  [the k-th largest, once, offline], [no], [quickselect is $O(n)$ on average],
  [merge k sorted lists], [yes], [$O(N log k)$],
  [a running median], [yes], [two heaps facing each other],
  [max in a sliding window], [maybe], [a monotonic deque is $O(n)$; a heap is $O(n log n)$],
  [greedy "always take the best available"], [yes], [the heap *is* the greedy step],
)

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Which of these arrays is a valid min-heap?

(A) `[1, 3, 9, 5, 7]` (B) `[1, 5, 2, 9, 3]` (C) `[2, 2, 2]` (D) `[5]`
]
#sol[
Check each parent against its children using `children of i are 2i+1 and 2i+2`.

- (A) a[0]=1 vs a[1]=3, a[2]=9 — ok. a[1]=3 vs a[3]=5, a[4]=7 — ok. *Valid.*
- (B) a[1]=5 vs its children a[3]=9 and a[4]=3. But 5 > 3. *Not valid.*
- (C) 2 <= 2 everywhere. *Valid* — the rule is `<=`, not `<`.
- (D) One node has no children, so nothing can be broken. *Valid.*
]
#ans[A, C and D]

#code(lang: "js", caption: "The check, in five lines")[
```js
const isMinHeap = (a) => {
  for (let i = 0; i < a.length; i++) {
    const l = 2 * i + 1, r = 2 * i + 2;
    if (l < a.length && a[l] < a[i]) return false;
    if (r < a.length && a[r] < a[i]) return false;
  }
  return true;
};
```
]

Tested: `[1,3,9,5,7]` $arrow.r$ `true`, `[1,5,2,9,3]` $arrow.r$ `false`, `[2,2,2]`
$arrow.r$ `true`, `[5]` $arrow.r$ `true`, `[]` $arrow.r$ `true`.

#ex(2, tier: 0, asked: "warm-up")[
A heap holds 100 items. Which index holds the parent of index 37? Which indices are its
children? How tall is the heap?
]
#sol[
- Parent of 37 is $(37 - 1)/2 = 18$ (integer division).
- Children of 37 are $2 times 37 + 1 = 75$ and $2 times 37 + 2 = 76$. Both are below
  100, so both exist.
- Height is $floor(log_2 100) = 6$, because $2^6 = 64 <= 100 < 128 = 2^7$.
]
#ans[parent 18, children 75 and 76, height 6]

#ex(3, tier: 0, asked: "warm-up")[
Push 2 into the min-heap `[4, 6, 5, 9, 8]`. Show every swap.
]
#sol[
Append 2 at index 5. Parent of 5 is $(5-1)/2 = 2$.

+ `[4, 6, 5, 9, 8, 2]`. a[2]=5 > a[5]=2, so swap → `[4, 6, 2, 9, 8, 5]`. Now i = 2.
+ Parent of 2 is $(2-1)/2 = 0$. a[0]=4 > a[2]=2, so swap → `[2, 6, 4, 9, 8, 5]`. Now i = 0.
+ i = 0 is the root. Stop.
]
#ans[`[2, 6, 4, 9, 8, 5]` — two swaps]

#ex(4, tier: 0, asked: "warm-up")[
Pop from the min-heap `[1, 3, 9, 5, 7]`. Show every step.
]
#sol[
+ The answer is a[0] = 1.
+ Move the *last* element (7) to the root and shrink: `[7, 3, 9, 5]`.
+ Sift down from index 0. Children are a[1]=3 and a[2]=9. The smaller is 3, and 3 < 7,
  so swap → `[3, 7, 9, 5]`. Now i = 1.
+ Children of 1 are index 3 (=5) and index 4 (does not exist). 5 < 7, so swap →
  `[3, 5, 9, 7]`. Now i = 3, a leaf. Stop.
]
#ans[returns 1; the heap becomes `[3, 5, 9, 7]`]

#ex(5, tier: 0, asked: "warm-up")[
You need the 3 largest of 1000000 numbers. Compare sorting everything against a heap of
size 3. Roughly how many operations does each take?
]
#sol[
- *Sort everything*: about $n log_2 n = 10^6 times 20 = 2 times 10^7$ operations, plus
  $O(n)$ memory for the copy.
- *Min-heap of size 3*: one push and at most one pop per element, each $log_2 3 approx 1.6$
  operations, so about $2 times 10^6$. Memory is 3 integers.

The heap is about ten times faster and uses essentially no memory.
]
#ans[sort $approx 2 times 10^7$; heap $approx 2 times 10^6$ with $O(k)$ memory]

#trick[
The size-k trick: *to keep the k LARGEST, use a MIN-heap of size k.* The root is then the
weakest survivor, so it is the one to throw away when a better item arrives. Beginners
reach for a max-heap and get stuck. Flip it.
]

#ex(6, tier: 0, asked: "warm-up")[
Build a min-heap, push 5, 1, 4, and print the pop order. Then say what one character you
would change to make it a max-heap.
]
#sol[
The default comparator `(a, b) => a - b` already gives a min-heap. Flipping it to
`(a, b) => b - a` gives a max-heap — that is the whole difference.
]
#code(lang: "js", caption: "The exact spelling")[
```js
const pq = new MinHeap();                    // default cmp = (a, b) => a - b
for (const x of [5, 1, 4]) pq.push(x);
const out = [];
while (pq.size) out.push(pq.pop());
console.log(out.join(' '));                  // 1 4 5
```
]
#ans[1 4 5; swap the comparator to `(a, b) => b - a` for a max-heap]

#section[Tier 1 — the core heap toolkit]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
*K-th largest element.* Given an array, return the k-th largest value. Duplicates count
as separate elements, so in `[3, 3, 1]` the 2nd largest is 3.

*Limits* $n <= 10^5$, $1 <= k <= n$, values fit in a 32-bit range · *Target* better than
$O(n log n)$ · *Edge cases* k = 1; k = n; all values equal; negative values.
]

#approach(1, "Sort descending, take a[k-1]", verdict: "O(n log n) — correct, always accepted, never impressive")

#code(lang: "js", caption: "The baseline")[
```js
const kthLargestSort = (a, k) => {
  const s = [...a].sort((x, y) => y - x);   // NUMERIC comparator, descending
  return s[k - 1];
};
```
]

#trap[
*`arr.sort()` in JavaScript is LEXICOGRAPHIC.* `[10, 9, 1].sort()` gives `[1, 10, 9]`,
because the default comparator turns every element into a *string* first. On this problem
that means `kthLargestSort([10, 9, 1], 1)` would answer `9` instead of `10`.

Numbers always need an explicit comparator: `.sort((a, b) => a - b)` ascending,
`.sort((a, b) => b - a)` descending. If you typed `.sort()` with empty brackets, you have
a bug.

Note the `[...a]` too: `sort` works *in place* and returns the same array, so without the
copy this function silently reorders the caller's data.
]
#complexity(time: $O(n log n)$, space: $O(1)$, note: "Sorting does far more work than the question asks for: it orders all n, when only k matter.")

#approach(2, "Keep a min-heap of the k best so far", verdict: "O(n log k) — the standard answer")

#sol[
Walk the array. Push every value. If the heap grows past `k`, pop the smallest — it can
never be in the top k. At the end the heap holds exactly the k largest, and its *root* is
the smallest of those, which is the k-th largest.
]

#code(lang: "js", caption: "Min-heap of size k")[
```js
const kthLargestHeap = (a, k) => {
  const pq = new MinHeap();            // min-heap of the k best so far
  for (const x of a) {
    pq.push(x);
    if (pq.size > k) pq.pop();         // drop the weakest survivor
  }
  return pq.peek();
};
```
]
#complexity(time: $O(n log k)$, space: $O(k)$, note: "This is the version that also works on a STREAM, where n is not known in advance.")

#approach(3, "Quickselect — partition, then recurse into one side only", verdict: "O(n) average, O(n^2) worst; O(1) extra memory")

#code(lang: "js", caption: "Quickselect with a random pivot")[
```js
const kthLargestQuickselect = (arr, k) => {
  const a = [...arr];
  const target = a.length - k;                // index in ascending order
  let lo = 0, hi = a.length - 1;
  while (lo < hi) {
    const p = lo + Math.floor(Math.random() * (hi - lo + 1));  // random pivot
    [a[p], a[hi]] = [a[hi], a[p]];
    const pivot = a[hi];
    let store = lo;
    for (let i = lo; i < hi; i++)
      if (a[i] < pivot) { [a[i], a[store]] = [a[store], a[i]]; store++; }
    [a[store], a[hi]] = [a[hi], a[store]];
    if (store === target) return a[store];
    if (store < target) lo = store + 1; else hi = store - 1;
  }
  return a[lo];
};
```
]
#complexity(time: [$O(n)$ average], space: [$O(n)$ for the copy], note: "JavaScript has no nth_element / partial-sort helper. If you need O(n), you write this. A random pivot is what keeps sorted input from turning it into O(n^2).")

#code(lang: "text", caption: "All three agree — a = [3,2,3,1,2,4,5,5,6]")[
```text
k=1: 6 6 6      k=4: 4 4 4      k=9: 1 1 1
single element [8], k=1 -> 8
negatives [-1,-5,-3], k=2 -> -3 from all three
```
]

*The idea that unlocked it:* you were asked for *one* rank, not for the order. Sorting
answers a bigger question than the one asked. The heap keeps exactly `k` items and throws
the rest away immediately.

#ex(8, tier: 1, asked: "Infosys · pattern")[
*Heap sort.* Sort an array ascending using a heap, with $O(1)$ extra memory.

*Limits* $n <= 10^6$ · *Target* $O(n log n)$ time, $O(1)$ extra space ·
*Edge cases* empty array; all equal values; negative values.
]
#approach(1, "Selection sort: scan for the biggest, swap it to the end, repeat", verdict: "O(n^2) — the scan is the waste")
#approach(2, "Let a heap find the biggest for you in O(log n)", verdict: "O(n log n) time, still O(1) extra memory")

#sol[
Use a *max*-heap in the same array.

+ `build` it in $O(n)$.
+ Swap `a[0]` (the biggest) with the last slot. That slot is now final.
+ Shrink the heap by one and sift down the new root.
+ Repeat. Each round places one more value, from the back forward.
]

#code(lang: "js", caption: "Heap sort — in place, no extra array")[
```js
const maxSiftDown = (a, i, n) => {
  for (;;) {
    const l = 2 * i + 1, r = 2 * i + 2;
    let big = i;
    if (l < n && a[l] > a[big]) big = l;
    if (r < n && a[r] > a[big]) big = r;
    if (big === i) return;
    [a[i], a[big]] = [a[big], a[i]];
    i = big;
  }
};

const heapSort = (a) => {
  const n = a.length;
  for (let i = (n >> 1) - 1; i >= 0; i--) maxSiftDown(a, i, n);   // build, O(n)
  for (let end = n - 1; end > 0; end--) {
    [a[0], a[end]] = [a[end], a[0]];    // biggest goes to its final slot
    maxSiftDown(a, 0, end);             // heap is now one shorter
  }
  return a;
};
```
]
#complexity(time: $O(n log n)$, space: $O(1)$, note: "Worst case too — unlike quicksort. But it is not stable, and it is cache-unfriendly, so the engine's own .sort is usually faster in practice.")

#code(lang: "text", caption: "Output")[
```text
[5 1 4 2 8] -> [1 2 4 5 8]
[]          -> []
[7]         -> [7]
[3 3 3]     -> [3 3 3]
[-9 2 -4 0] -> [-9 -4 0 2]
2000 random values match .sort((a,b)=>a-b): yes
```
]

#trap[
`heapSort` sorts *in place* and returns the same array — exactly like `Array.prototype.sort`.
Callers who still want their original order must pass a copy: `heapSort([...v])`.

Note `(n >> 1) - 1`. On an empty array that is `-1` and the loop never runs, which is
correct. `>>` also truncates towards zero for these values, so it doubles as the integer
division C++ gets for free.
]

#ex(9, tier: 1, asked: "Wipro · pattern")[
*Top k frequent values.* Return the k values that appear most often. Break ties by
returning the smaller value first.

*Limits* $n <= 10^5$, $1 <= k <= $ number of distinct values ·
*Target* better than $O(n log n)$ · *Edge cases* every value distinct; one value repeated
n times; negative values.
]

#approach(1, "Count, then sort the counts", verdict: "O(d log d), d = number of distinct values")
#approach(2, "Count, then keep a min-heap of size k", verdict: "O(d log k) time, O(d) memory")

#code(lang: "js", caption: "Min-heap of size k, with an explicit tie rule")[
```js
const topKFrequentHeap = (a, k) => {
  const cnt = new Map();
  for (const x of a) cnt.set(x, (cnt.get(x) ?? 0) + 1);
  // the root is the entry to DROP: smallest count, and on a tie the bigger value
  const pq = new MinHeap((x, y) => x[1] - y[1] || y[0] - x[0]);
  for (const e of cnt) {              // iterating a Map yields [key, value] pairs
    pq.push(e);
    if (pq.size > k) pq.pop();
  }
  const out = [];
  while (pq.size) out.push(pq.pop()[0]);
  return out.reverse();               // heap gives worst first, so flip
};
```
]
#complexity(time: $O(n + d log k)$, space: $O(d)$)

#trap[
Use a `Map`, not a plain object, for counting. An object turns every key into a *string*,
so `-1` and `"-1"` collide, the keys come back as strings, and your comparator then does
string subtraction. `Map` keeps the key's type, keeps insertion order, and is faster for
heavy add/delete traffic. `cnt.get(x) ?? 0` handles the first sighting of a key.
]

#approach(3, "Bucket by frequency", verdict: "O(n) — a count can never exceed n, so it is an index")

#sol[
A frequency is a whole number between 1 and n. So make `n+1` buckets and drop each value
into the bucket named by its count. Then read the buckets from the highest down.
]

#code(lang: "js", caption: "No heap, no sort of the counts")[
```js
const topKFrequentBucket = (a, k) => {
  const cnt = new Map();
  for (const x of a) cnt.set(x, (cnt.get(x) ?? 0) + 1);
  const bucket = Array.from({ length: a.length + 1 }, () => []);
  for (const [v, c] of cnt) bucket[c].push(v);
  const out = [];
  for (let f = a.length; f >= 1 && out.length < k; f--) {
    bucket[f].sort((x, y) => y - x);          // numeric, descending
    for (const v of bucket[f]) {
      if (out.length === k) break;
      out.push(v);
    }
  }
  return out;
};
```
]
#complexity(time: $O(n)$, space: $O(n)$, note: "The inner sorts together cost O(d log d) in the worst case, but only inside single buckets.")

#trap[
`Array.from({length: n}, () => [])` — *not* `new Array(n).fill([])`. `fill` stores the
*same* array object in every slot, so pushing into `bucket[3]` also pushes into
`bucket[7]`. This is the same shallow-copy trap that bites 2D grids, where `[...grid]`
shares every row and only `grid.map(r => [...r])` is a real copy.
]

#code(lang: "text", caption: "Output — a = [4,1,-1,2,-1,2,3,2]")[
```text
heap   k=2 -> [2 -1]
bucket k=2 -> [2 -1]
[9] k=1 -> [9] from both;  [5,5,5] k=1 -> [5] from both
```
]

*The idea that unlocked it:* a frequency is bounded by `n`, so it can be an *array index*
instead of a sort key. Whenever a key is a small whole number, bucket it.

#ex(10, tier: 1, asked: "Capgemini · pattern")[
*Connect the ropes.* You have ropes of given lengths. Joining two ropes costs the sum of
their lengths and gives one rope. Join all of them for the least total cost.

*Limits* $n <= 10^5$, each length up to $10^9$ · *Target* $O(n log n)$ ·
*Edge cases* zero or one rope (cost 0); a total big enough to leave the 32-bit range.
]
#approach(1, "Try every order of joining", verdict: "factorial — 10 ropes already give 3628800 orders")
#approach(2, "Always join the two shortest ropes left", verdict: "O(n log n) with a min-heap")

#sol[
Every join adds the two lengths to the bill, and the result gets joined again later. So a
rope that is joined *early* is paid for *many* times. To keep the bill small, always join
the *two shortest* ropes available. A min-heap hands them to you.
]

#code(lang: "js", caption: "Greedy with a min-heap — build, do not push in a loop")[
```js
const connectRopes = (len) => {
  if (len.length <= 1) return 0;
  const pq = new MinHeap().build(len);     // O(n) build, not n pushes
  let total = 0;
  while (pq.size > 1) {
    const a = pq.pop(), b = pq.pop();
    total += a + b;
    pq.push(a + b);
  }
  return total;
};
```
]
#complexity(time: $O(n log n)$, space: $O(n)$)

#code(lang: "text", caption: "Output")[
```text
[4,3,2,6] -> 29        (2+3=5, 5+4=9, 9+6=15; bill 5+9+15 = 29)
[5] -> 0     [] -> 0     [1,1,1,1] -> 8
four ropes of 1000000000 -> 8000000000   safe integer? true
```
]

#trap[
*JavaScript numbers are doubles.* There is no `int`, no 64-bit integer type, and no silent 32-bit
wrap — so `8000000000` is simply correct here. The limit is different: integers are exact
only up to `Number.MAX_SAFE_INTEGER` $= 2^53 - 1 = 9007199254740991$, about
$9 times 10^15$.

Past that, arithmetic quietly *rounds* instead of wrapping, which is harder to spot than
an overflow. Guard the moment a running total or a product can exceed it:

```js
console.log(Number.isSafeInteger(8000000000));   // true  — the rope bill is exact
console.log(Number.isSafeInteger(1e20));         // false — rounded, and silently so
```

and switch to `BigInt` when it cannot: `let total = 0n; total += BigInt(a) + BigInt(b);`.
This chapter needs `BigInt` exactly once — the product of the k largest, in the practice
set — because sums of $10^5$ values up to $10^9$ stay comfortably inside $2^53$.
]

#ex(11, tier: 1, asked: "Cognizant · pattern")[
*Sort a nearly sorted array.* Every element is at most `k` positions away from where it
belongs. Sort it.

*Limits* $n <= 10^5$, $0 <= k <= n$ · *Target* $O(n log k)$ ·
*Edge cases* k = 0 (already sorted); k = n (a normal sort); empty array.
]

#approach(1, "Just call sort", verdict: "O(n log n) — correct but ignores the k")
#approach(2, "Slide a min-heap of size k+1 along the array", verdict: "O(n log k)")

#sol[
If the true smallest remaining element is at most `k` places away, then after reading
`k+1` elements it *must* already be inside the heap. So: read `k+1` elements, then for
each new element, pop one — that pop is the next value of the answer.
]

#code(lang: "js", caption: "A window of size k+1")[
```js
const sortKSorted = (a, k) => {
  const pq = new MinHeap();
  const out = [];
  for (const x of a) {
    pq.push(x);
    if (pq.size > k + 1) out.push(pq.pop());
  }
  while (pq.size) out.push(pq.pop());
  return out;
};
```
]
#complexity(time: $O(n log k)$, space: $O(k)$)

#code(lang: "text", caption: "Output")[
```text
[6,5,3,2,8,10,9] with k=3 -> [2 3 5 6 8 9 10]
[] k=2 -> []     [4] k=0 -> [4]     [2,1,2,1] k=1 -> [1 1 2 2]
```
]

#ex(12, tier: 1, asked: "Accenture · pattern")[
*Merge k sorted arrays.* Combine `k` sorted arrays into one sorted array of `N` values.

*Limits* $k <= 10^4$, total $N <= 10^6$ · *Target* $O(N log k)$ ·
*Edge cases* some arrays empty; all arrays empty; k = 0.
]

#approach(1, "Concatenate everything and sort", verdict: "O(N log N) — throws away the sortedness")
#approach(2, "Merge two at a time, left to right", verdict: "O(N k) — the first array is copied k times")
#approach(3, "One min-heap holding the current head of each array", verdict: "O(N log k)")

#code(lang: "js", caption: "The heap holds at most k items — one per array")[
```js
const mergeKArrays = (lists) => {
  // each heap entry is {val, li, idx} = value, which list, where in it
  const pq = new MinHeap((x, y) => x.val - y.val);
  lists.forEach((l, i) => { if (l.length) pq.push({ val: l[0], li: i, idx: 0 }); });
  const out = [];
  while (pq.size) {
    const { val, li, idx } = pq.pop();          // destructure the entry
    out.push(val);
    if (idx + 1 < lists[li].length)
      pq.push({ val: lists[li][idx + 1], li, idx: idx + 1 });
  }
  return out;
};
```
]
#complexity(time: $O(N log k)$, space: [$O(k)$ plus the output])

#code(lang: "text", caption: "Output")[
```text
[[1,5,9],[2,6],[3,4,10]] -> [1 2 3 4 5 6 9 10]
[[],[],[]] -> []      [] -> []      [[-5,-1],[-3,0]] -> [-5 -3 -1 0]
```
]

#trap[
Pushing the *whole* first array into the heap instead of just its head makes the heap
$O(N)$ and defeats the point. The heap must never hold more than one item per list.
]

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
*K closest points.* Given points on a plane, return the `k` closest to the origin.

*Limits* $n <= 10^5$, coordinates up to $10^5$ in absolute value ·
*Target* $O(n log k)$ · *Edge cases* k = n; coordinates big enough that
$x^2 + y^2$ leaves the 32-bit range.
]
#approach(1, "Compute every distance, sort, take the first k", verdict: "O(n log n) time and O(n) memory")
#approach(2, "Max-heap of size k, keyed on the squared distance", verdict: "O(n log k) time, O(k) memory")

#sol[
Distance from the origin is $sqrt(x^2 + y^2)$, but the square root is a waste — comparing
$x^2 + y^2$ gives the same order. To keep the `k` *closest*, use a *max*-heap of size k,
so the root is the worst survivor.
]

#code(lang: "js", caption: "Max-heap of size k, keyed on the squared distance")[
```js
const kClosestPoints = (pts, k) => {
  const d2 = ([x, y]) => x * x + y * y;            // destructure in the parameter
  const pq = new MinHeap((p, q) => d2(q) - d2(p)); // MAX-heap on distance
  for (const p of pts) {
    pq.push(p);
    if (pq.size > k) pq.pop();                     // throw out the farthest
  }
  const out = [];
  while (pq.size) out.push(pq.pop());
  return out.reverse();
};
```
]
#complexity(time: $O(n log k)$, space: $O(k)$)

#code(lang: "text", caption: "Output")[
```text
[(1,3),(-2,2),(5,8),(0,1)] k=2 -> (0,1) (-2,2)
[(40000,40000),(1,1)] k=1 -> (1,1)
40000^2 + 40000^2 = 3200000000   exact? true
```
]

#note[
In C++ this example is the classic 32-bit overflow trap: $40000^2 + 40000^2 =
3.2 times 10^9$ wraps negative without a 64-bit cast, and the far point wins.
In JavaScript it is simply right — doubles hold every integer up to $2^53 - 1$ exactly,
so no cast exists and none is needed.

The JS version of the same danger is *larger*: at coordinates around $10^8$ the squared
distance passes $2^53$ and starts rounding, with no error and no warning. Guard with
`Number.isSafeInteger(d2(p))` when the statement allows coordinates that big.
]

#ex(14, tier: 1, asked: "TCS NQT · pattern")[
*Colliding stones.* Repeatedly take the two heaviest stones. If they are equal, both are
destroyed; otherwise the lighter one is destroyed and the heavier loses that weight.
Return the weight left at the end (0 if nothing is left).

*Limits* $n <= 10^4$, weights up to $10^3$ · *Target* $O(n log n)$ ·
*Edge cases* no stones; one stone; two equal stones.
]
#approach(1, "Sort the whole list again after every collision", verdict: "O(n^2 log n) — the list is re-sorted n times")
#approach(2, "A max-heap, so each round costs O(log n)", verdict: "O(n log n)")

#code(lang: "js", caption: "Max-heap simulation")[
```js
const lastStone = (st) => {
  const pq = new MinHeap((a, b) => b - a).build(st);   // max-heap, built in O(n)
  while (pq.size > 1) {
    const a = pq.pop(), b = pq.pop();
    if (a !== b) pq.push(a - b);
  }
  return pq.size ? pq.peek() : 0;
};
```
]
#complexity(time: $O(n log n)$, space: $O(n)$)
#code(lang: "text", caption: "Output")[
```text
[2,7,4,1,8,1] -> 1     [3,3] -> 0     [6] -> 6     [] -> 0
```
]

#note[
`.build(st)` runs the linear build, not `n` pushes, and it returns the heap so it chains
straight onto the constructor. Free speed for six characters.
]

#ex(15, tier: 1, asked: "Infosys · pattern")[
*Convert a min-heap into a max-heap.* You are given an array that satisfies the min-heap
rule. Rearrange it so it satisfies the max-heap rule.

*Limits* $n <= 10^6$ · *Target* $O(n)$ · *Edge cases* empty; one element.
]
#approach(1, "Sort the array descending", verdict: "O(n log n) — correct, but more than the question needs")
#approach(2, "Run the linear build with the comparison flipped", verdict: "O(n) — optimal")

#sol[
There is no clever shortcut — a min-heap gives almost no information about the max order.
So just run the linear `build` with the comparison flipped. $O(n)$ is already optimal.
]
#code(lang: "js", caption: "Build, with the sign flipped")[
```js
const minHeapToMaxHeap = (a) => {
  for (let i = (a.length >> 1) - 1; i >= 0; i--) maxSiftDown(a, i, a.length);
  return a;                             // reuses maxSiftDown from heap sort
};
```
]
#complexity(time: $O(n)$, space: $O(1)$)
#code(lang: "text", caption: "Output")[
```text
isMaxHeap checks: [9 7 8 1 3]=yes  [1 7 8]=no  []=yes  [5]=yes
[1 3 5 7 9 11] -> [11 9 5 7 3 1]   isMaxHeap = yes
```
]

#section[Tier 2 — applied problems]
#tier-header(2)

#ex(16, tier: 2, asked: "Grab · pattern")[
*Fewest drivers.* A ride app has a list of trips, each with a start and an end minute.
One driver can take a new trip only when the previous one has ended. How many drivers are
needed?

*Limits* $n <= 10^5$ trips · *Target* $O(n log n)$ · *Edge cases* no trips; one trip ends
exactly when the next begins (the same driver can take it).
]

#approach(1, "For every minute, count the trips covering it", verdict: "O(n * T) — hopeless when times go up to 10^9")
#approach(2, "Sort by start; a min-heap holds the end times in use", verdict: "O(n log n)")

#sol[
Sort the trips by start time. Keep a min-heap of the *end* times of the busy drivers. For
each new trip: if the earliest-finishing driver is already free (`heap.peek() <= start`),
reuse them — pop. Then push this trip's end. The heap size at any moment is the number of
drivers in use, and the final size is the answer.
]

#code(lang: "js", caption: "Sort by start, heap on end")[
```js
const minRooms = (mt) => {
  if (!mt.length) return 0;
  const v = [...mt].sort((a, b) => a[0] - b[0] || a[1] - b[1]);   // by start
  const endTimes = new MinHeap();
  for (const [start, end] of v) {
    if (endTimes.size && endTimes.peek() <= start) endTimes.pop();
    endTimes.push(end);
  }
  return endTimes.size;
};
```
]
#complexity(time: $O(n log n)$, space: $O(n)$)

#code(lang: "text", caption: "Output")[
```text
[(0,30),(5,10),(15,20)] -> 2
[(7,10),(2,4)]          -> 1
[]                      -> 0
[(1,5),(5,9),(9,12)]    -> 1   (touching ends reuse the same driver)
```
]

#trap[
Two separate bugs live on the sort line.

+ `mt.sort()` with no comparator compares the *string* forms of the pairs, so `[10, 20]`
  sorts before `[9, 30]`. Always `(a, b) => a[0] - b[0]`.
+ C++ sorts a `pair` by first *then* second for free. JavaScript does not: a bare
  `a[0] - b[0]` leaves equal starts in arbitrary order. Chain the tie-break with `||`.
]

#trap[
`endTimes.peek() <= start` versus `<`. If the problem says a trip ending at minute 5 and
one starting at minute 5 *can* share a driver, use `<=`. If they cannot, use `<`. The two
answers differ on the last test line above. Ask.
]

#ex(17, tier: 2, asked: "Shopee · pattern")[
*Merge k sorted linked lists.* Merge `k` sorted singly linked lists into one sorted list.
Reuse the nodes.

*Limits* total $N <= 10^6$ nodes, $k <= 10^4$ · *Target* $O(N log k)$ ·
*Edge cases* some lists are null; all are null.
]
#approach(1, "Collect every value, sort, then rebuild a fresh list", verdict: "O(N log N) time and O(N) memory; it does not reuse the nodes")
#approach(2, "Merge two lists at a time", verdict: "O(N k) — the first list is walked k times")
#approach(3, "A min-heap holding the current head of each list", verdict: "O(N log k) time, O(k) memory")

#code(lang: "js", caption: "The heap stores nodes, not values")[
```js
const node = (val, next = null) => ({ val, next });

const mergeKLists = (heads) => {
  const pq = new MinHeap((a, b) => a.val - b.val);   // compares NODES by .val
  for (const h of heads) if (h) pq.push(h);
  const dummy = node(0);
  let tail = dummy;
  while (pq.size) {
    const cur = pq.pop();
    tail.next = cur; tail = cur;
    if (cur.next) pq.push(cur.next);
  }
  tail.next = null;            // cut the old tail loose
  return dummy.next;
};
```
]
#complexity(time: $O(N log k)$, space: $O(k)$)

#code(lang: "text", caption: "Output")[
```text
[1,4,7] [2,5] [3,6,8] -> [1 2 3 4 5 6 7 8]
[null, [2], null]     -> [2]
all null              -> []
```
]

#trap[
Forgetting `tail.next = null` at the end leaves the last node still pointing into the
middle of another list. The list then has a cycle and printing it never stops.

Note also `for (const h of heads) if (h) pq.push(h)` — the guard is `if (h)`, which is
false for both `null` and `undefined`. A missing list arriving as `undefined` is the JS
version of a null pointer, and this one test covers both.
]

#ex(18, tier: 2, asked: "Agoda · pattern")[
*K-th largest in a stream.* Design a class that starts with some values and supports
`add(x)`, returning the k-th largest value seen so far.

*Limits* up to $10^5$ calls · *Target* $O(log k)$ per call, $O(k)$ memory ·
*Edge cases* fewer than k values so far; equal values.
]
#approach(1, "Store everything and sort on every add", verdict: "O(n log n) per call — unusable on a stream")
#approach(2, "Keep one min-heap of size k alive between calls", verdict: "O(log k) per call, O(k) memory")

#sol[
The size-k min-heap from Example 7, kept alive between calls. It never grows past k, so
memory does not grow with the stream.
]
#code(lang: "js", caption: "A class around one min-heap")[
```js
class KthLargestStream {
  constructor(k, start = []) {
    this.k = k;
    this.pq = new MinHeap();
    for (const x of start) this.add(x);
  }
  add(x) {
    this.pq.push(x);
    if (this.pq.size > this.k) this.pq.pop();
    // null means fewer than k values have arrived so far
    return this.pq.size === this.k ? this.pq.peek() : null;
  }
}
```
]
#complexity(time: [$O(log k)$ per call], space: $O(k)$)
#code(lang: "text", caption: "Output — k = 3, start = [4,5,8,2]")[
```text
add(3) -> 4     add(5) -> 5     add(10) -> 5     add(9) -> 8
k=2 with no start values: add(1) -> not enough yet, add(7) -> 1
```
]

#note[
C++ returns `INT_MIN` for "not enough values yet". JavaScript has no such sentinel, and
picking one is a bug waiting to happen — a stream of real values could contain it. Return
`null` and let the caller test `=== null`. Do *not* return `undefined`: that is what a
function returns when it forgot to return anything, so it hides mistakes instead of
naming a case.
]

#ex(19, tier: 2, asked: "Sea/Shopee · pattern")[
*K cheapest bundles.* Two sorted price lists `a` and `b`. A bundle takes one price from
each. Return the `k` bundles with the smallest total, cheapest first.

*Limits* $n, m <= 10^5$, $k <= 10^4$ · *Target* $O(k log k)$ ·
*Edge cases* either list empty; `k` bigger than $n times m$; prices up to $10^9$.
]

#approach(1, "Build all n*m sums and sort", verdict: "O(n m log(n m)) — 10^10 pairs, impossible")
#approach(2, "Seed the heap with (a[i], b[0]) and expand one step at a time", verdict: "O(k log k)")

#sol[
Think of a grid where cell `(i, j)` is `a[i] + b[j]`. Rows increase to the right and
columns increase downward. The cheapest unseen cell is always next to one already taken.
So: push the whole first *column* (at most `k` of it), and each time you pop `(i, j)`,
push `(i, j+1)`.
]

#code(lang: "js", caption: "Only k pops, so only k+n pushes ever happen")[
```js
const kSmallestPairs = (a, b, k) => {
  const out = [];
  if (!a.length || !b.length || k <= 0) return out;
  const pq = new MinHeap((x, y) => x.sum - y.sum);
  for (let i = 0; i < a.length && i < k; i++) pq.push({ sum: a[i] + b[0], i, j: 0 });
  while (pq.size && out.length < k) {
    const { i, j } = pq.pop();
    out.push([a[i], b[j]]);
    if (j + 1 < b.length) pq.push({ sum: a[i] + b[j + 1], i, j: j + 1 });
  }
  return out;
};
```
]
#complexity(time: $O(k log k)$, space: $O(k)$)

#code(lang: "text", caption: "Output")[
```text
a=[1,7,11], b=[2,4,6], k=3 -> (1,2) (1,4) (1,6)
a empty -> 0 pairs
a=[1,2], b=[3], k=10 -> only 2 pairs exist, so 2 are returned
```
]

#note[
`{ sum: a[i] + b[0], i, j: 0 }` uses the shorthand: `i` alone means `i: i`. It reads
better than the long form and is what an interviewer expects to see in 2020s JavaScript.
]

#ex(20, tier: 2, asked: "LINE MAN · pattern")[
*No two the same in a row.* Rearrange a string so that no two neighbouring characters are
equal. Return an empty string if it cannot be done.

*Limits* length $<= 10^5$, lowercase letters · *Target* $O(n log 26)$ ·
*Edge cases* one character; a character that appears more than half the time.
]
#approach(1, "Try every arrangement of the letters", verdict: "factorial — impossible past about 10 letters")
#approach(2, "Place the two most common letters first, every round", verdict: "O(n log 26) with a max-heap")

#sol[
Always place the *two* most common remaining characters next to each other, then put them
back with their counts reduced. This spreads the crowded characters out as far as
possible. If at the end a single character is left with a count above 1, it is impossible.
]

#code(lang: "js", caption: "Pop two, place two, push back")[
```js
const reorganize = (s) => {
  const cnt = new Map();
  for (const c of s) cnt.set(c, (cnt.get(c) ?? 0) + 1);
  // max-heap on count; on a tie the alphabetically later letter goes first
  const pq = new MinHeap((x, y) =>
    y[0] - x[0] || (x[1] < y[1] ? 1 : x[1] > y[1] ? -1 : 0));
  for (const [c, n] of cnt) pq.push([n, c]);
  let out = '';
  while (pq.size >= 2) {
    const x = pq.pop(), y = pq.pop();
    out += x[1] + y[1];
    if (--x[0] > 0) pq.push(x);
    if (--y[0] > 0) pq.push(y);
  }
  if (pq.size) {
    if (pq.peek()[0] > 1) return '';      // one letter, 2+ copies: stuck
    out += pq.peek()[1];
  }
  return out;
};
```
]
#complexity(time: $O(n log 26)$, space: $O(n)$)

#trap[
`x[1] - y[1]` would be `NaN` here, because the elements are *characters*. Subtraction only
works on numbers; strings need an explicit three-way comparison, either the ternary above
or `x[1].localeCompare(y[1])`. A comparator that returns `NaN` leaves the heap in
arbitrary order and never errors.
]

#code(lang: "text", caption: "Output")[
```text
"aaabbc" -> "abacba"   (no two neighbours match)
"aaab"   -> ""         ('a' appears 3 times out of 4 — impossible)
"a"      -> "a"
""       -> ""
```
]

#trick[
The impossibility test has a closed form too: it is impossible exactly when the most
common character appears more than $ceil(n/2)$ times. Checking that first lets you return
early without running the heap at all.
]

#ex(21, tier: 2, asked: "SCB · pattern")[
*Job sequencing with deadlines.* Each job takes one unit of time, has a deadline and a
profit. Only one job runs at a time. Choose the set of jobs with the biggest total profit
such that every chosen job finishes by its deadline.

*Limits* $n <= 10^5$, deadlines up to $n$, profits up to $10^9$ ·
*Target* $O(n log n)$ · *Edge cases* no jobs; all deadlines equal to 1; a total profit
well past the 32-bit range.
]
#approach(1, "Try every subset of jobs and check each one fits", verdict: "2^n — impossible past about 20 jobs")
#approach(2, "Sort by profit, then scan for a free slot before the deadline", verdict: "O(n^2) with a plain array of slots, or O(n alpha(n)) with a DSU")
#approach(3, "Sort by deadline, take everything, and drop the least profitable when a deadline is broken", verdict: "O(n log n) with a min-heap")

#sol[
Sort the jobs by deadline. Walk through them, taking every job greedily. Keep the taken
profits in a *min*-heap. After adding a job with deadline `d`, if you now hold more than
`d` jobs you cannot run them all — so drop the least profitable one. That is exactly the
job you would regret least.
]

#code(lang: "js", caption: "Take everything, then regret the cheapest")[
```js
const jobProfit = (jobs) => {                 // jobs[i] = [deadline, profit]
  const v = [...jobs].sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const taken = new MinHeap();
  let total = 0;
  for (const [deadline, profit] of v) {
    taken.push(profit); total += profit;
    if (taken.size > deadline) total -= taken.pop();   // one job too many
  }
  return total;
};
```
]
#complexity(time: $O(n log n)$, space: $O(n)$)

#code(lang: "text", caption: "Output")[
```text
[(2,100),(1,19),(2,27),(1,25),(3,15)] -> 142   (100 + 27 + 15)
[(1,5),(1,6),(1,7)]                   -> 7     (only one slot exists)
[]                                    -> 0
three jobs, deadline 3, profit 1e9 each -> 3000000000
```
]

#note[
$3 times 10^9$ is the classic C++ `int` overflow here, and in JavaScript it is simply a
number. The JS question is always the same one: can the total pass
`Number.MAX_SAFE_INTEGER`? With $n <= 10^5$ jobs at $10^9$ each the worst total is
$10^14$, still inside $2^53 - 1$. So plain numbers are correct — but say *why* they are
correct, because that is the answer the interviewer is listening for.
]

#ex(22, tier: 2, asked: "Razer · pattern")[
*Seat manager.* Seats are numbered 1..n and all start free. Support `reserve()` — take
the smallest free seat number — and `release(s)` — free seat `s` again.

*Limits* $n <= 10^5$, up to $10^5$ calls · *Target* $O(log n)$ per call ·
*Edge cases* reserving when nothing is free; releasing a seat that was never taken.
]
#approach(1, "Keep a boolean array and scan it for the first free seat", verdict: "O(n) per reserve")
#approach(2, "A min-heap of free seat numbers", verdict: "O(log n) per call")

#code(lang: "js", caption: "A min-heap of free seat numbers")[
```js
class SeatManager {
  constructor(n) {
    this.freeSeats = new MinHeap();
    for (let i = 1; i <= n; i++) this.freeSeats.push(i);
  }
  reserve() { return this.freeSeats.pop(); }
  release(s) { this.freeSeats.push(s); }
}
```
]
#complexity(time: [$O(log n)$ per call], space: $O(n)$)
#code(lang: "text", caption: "Output — SeatManager(5)")[
```text
reserve -> 1   reserve -> 2   release(1)   reserve -> 1   reserve -> 3
```
]
#note[
A cleaner version starts the heap *empty* and keeps a counter `next = 1`. `reserve()`
returns `next++` when the heap is empty, so the constructor is $O(1)$ instead of
$O(n log n)$. Mention this — it is the follow-up the interviewer is waiting for.
]

#section[Tier 3 — product interviews]
#tier-header(3)

#ex(23, tier: 3, asked: "Google · pattern")[
*Median of a stream.* Numbers arrive one at a time. After each one, report the median of
everything seen so far.

*Limits* up to $10^5$ numbers, values up to $10^9$ · *Target* $O(log n)$ per insert,
$O(1)$ per query · *Edge cases* the first number; an even count; all numbers equal;
negative numbers.
]

#approach(1, "Keep a sorted array, insert each new value in place", verdict: "O(n) per insert because of the shifting; O(n^2) overall")
#approach(2, "Two heaps facing each other", verdict: "O(log n) per insert, O(1) per query")

#formulas(title: "The two-heap invariant")[
Split the numbers into a *smaller half* and a *bigger half*.

- `lo` is a *max*-heap holding the smaller half. Its root is the biggest of the small side.
- `hi` is a *min*-heap holding the bigger half. Its root is the smallest of the big side.
- Keep the sizes balanced: `lo.size` equals `hi.size` or is exactly one bigger.

Then the median is `lo.peek()` when the total count is odd, and the average of
`lo.peek()` and `hi.peek()` when it is even. Both are $O(1)$ reads.
]

#code(lang: "js", caption: "Insert, then rebalance — always in that order")[
```js
class MedianStream {
  constructor() {
    this.lo = new MinHeap((a, b) => b - a);   // max-heap, small half
    this.hi = new MinHeap();                  // min-heap, big half
  }

  add(x) {
    if (!this.lo.size || x <= this.lo.peek()) this.lo.push(x);
    else this.hi.push(x);
    // rebalance so that lo.size is hi.size or hi.size + 1
    if (this.lo.size > this.hi.size + 1) this.hi.push(this.lo.pop());
    else if (this.hi.size > this.lo.size) this.lo.push(this.hi.pop());
  }

  median() {
    if (!this.lo.size) return 0;
    if (this.lo.size > this.hi.size) return this.lo.peek();
    return (this.lo.peek() + this.hi.peek()) / 2;
  }
}
```
]
#complexity(time: [$O(log n)$ insert, $O(1)$ query], space: $O(n)$)

#code(lang: "text", caption: "Output")[
```text
adding 5, 15, 1, 3, 8, -4 -> medians [5 10 5 4 5 4]
one value [7] -> 7      all equal [2,2,2,2] -> 2      nothing added -> 0
```
]

#note[
C++ needs a `(double)` cast here or the two `int` tops overflow before the division.
JavaScript has one number type, so `(a + b) / 2` is already the true average — `5 / 2` is
`2.5`, not `2`. The flip side is that a median of `4` prints as `4`, not `4.0`; if the
statement wants a fixed number of decimals, format it at the *edge* with
`.toFixed(1)` and never inside the algorithm.

`this.hi.push(this.lo.pop())` is the whole rebalance: `pop` returns the value it removed,
so the transfer is one expression.
]

*The idea that unlocked it:* you do not need the data sorted; you need only the *two
values in the middle*. Two heaps hold exactly those two at their tops, and nothing else
has to move.

#subsection[The follow-up]
*"Now it is a sliding window of size k, and old values must leave."* \
Heaps cannot remove an arbitrary value. Two honest answers:

+ *A sorted array plus binary search.* Keep the whole window sorted. Binary search finds
  where the arrival goes and where the departure sits; `splice` does both edits. Each
  slide is $O(log k)$ to *find* and $O(k)$ to *shift*.
+ *Two heaps with lazy deletion.* Mark a value as deleted in a side `Map` and skip it when
  it surfaces at a root. That restores $O(log k)$ per slide, but it is much fiddlier to
  get exactly right under interview pressure.

#trap[
*JavaScript has no `TreeMap`, no `multiset`, no ordered set.* C++ answers this question
with `multiset` and a parked iterator; Java with `TreeMap`. There is no equivalent, and
`Set`/`Map` are *unordered* for this purpose — they keep insertion order, not sorted
order.

The two workarounds worth memorising:
- a *sorted array* plus binary search (`lowerBound` / `upperBound` from the toolkit), when
  the window is small or the data is mostly read;
- a *`Map` plus a separately maintained sorted key list*, when you need both random access
  by key and ordered traversal.

Say this out loud in the interview. "JavaScript has no ordered map, so I will keep a
sorted array and binary search it" is a *correct* answer. Pretending `Object.keys()` comes
back sorted is not — it does not, except for integer-like keys, which is a rule you should
never lean on.
]

#code(lang: "js", caption: "Sliding window median — sorted window, binary search")[
```js
const { lowerBound } = require('./toolkit.js');   // JS Toolkit appendix

const slidingMedian = (a, k) => {
  const out = [];
  if (k <= 0 || a.length < k) return out;
  const w = a.slice(0, k).sort((x, y) => x - y);    // the window, kept sorted
  const mid = (arr) => k % 2 ? arr[(k - 1) >> 1]
                             : (arr[k / 2 - 1] + arr[k / 2]) / 2;
  out.push(mid(w));
  for (let i = k; i < a.length; i++) {
    w.splice(lowerBound(w, a[i]), 0, a[i]);         // insert the arrival
    w.splice(lowerBound(w, a[i - k]), 1);           // remove ONE copy of the leaver
    out.push(mid(w));
  }
  return out;
};
```
]
#complexity(time: [$O(n log k)$ to locate, $O(n k)$ to shift], space: $O(k)$, note: "The splices dominate. At k <= a few thousand the shifts are a memmove and this is fast in practice; past that, use two heaps with lazy deletion.")
#code(lang: "text", caption: "Output")[
```text
[1,3,-1,-3,5,3,6,7] k=3 -> [1 -1 -1 3 5 6]
[1,4,2,3] k=4 -> [2.5]      [5] k=1 -> [5]      k bigger than n -> []
[2,2,2,2] k=2 -> [2 2 2]
```
]
#trap[
`w.splice(lowerBound(w, x), 1)` removes *one* copy — the first one at or after that index.
Do not reach for `filter(v => v !== x)`: with duplicates in the window that deletes *every*
copy, and `[2,2,2,2]` silently empties out. The same warning applies to the C++ habit of
`multiset::erase(value)`, which also erases all copies.
]

#ex(24, tier: 3, asked: "Amazon · pattern")[
*K-th smallest in a sorted matrix.* An $n times n$ matrix has every row and every column
sorted ascending. Find the k-th smallest value overall.

*Limits* $n <= 300$ (so up to 90000 values), $1 <= k <= n^2$ ·
*Target* better than $O(n^2 log n)$ · *Edge cases* k = 1; $k = n^2$; a 1x1 matrix;
repeated values.
]

#approach(1, "Flatten and sort", verdict: "O(n^2 log n) time and O(n^2) memory — fine here, but it ignores the structure")

#code(lang: "js", caption: "Baseline")[
```js
const kthMatrixSort = (m, k) => {
  const all = m.flat().sort((x, y) => x - y);   // numeric comparator, always
  return all[k - 1];
};
```
]
#complexity(time: [$O(n^2 log n)$], space: $O(n^2)$, note: "C++ would call nth_element here and get O(n^2). JavaScript has no partial sort, so either you sort everything or you paste in the quickselect from Example 7 — which does give O(n^2) on average.")

#approach(2, "Merge the rows with a heap and stop after k pops", verdict: "O(k log n) time, O(n) memory")

#code(lang: "js", caption: "Exactly the merge-k-arrays heap, stopped early")[
```js
const kthMatrixHeap = (m, k) => {
  const n = m.length;
  const pq = new MinHeap((x, y) => x.val - y.val);
  for (let r = 0; r < n && r < k; r++) pq.push({ val: m[r][0], r, c: 0 });
  let out = 0;
  for (let step = 0; step < k; step++) {
    const cur = pq.pop();
    out = cur.val;
    if (cur.c + 1 < m[cur.r].length)
      pq.push({ val: m[cur.r][cur.c + 1], r: cur.r, c: cur.c + 1 });
  }
  return out;
};
```
]
#complexity(time: $O(k log n)$, space: $O(n)$, note: "When k is near n^2 this is worse than the baseline.")

#approach(3, "Binary search on the ANSWER, not on an index", verdict: "O(n log(max - min)) time, O(1) memory")

#sol[
Guess a value `x`. Count how many matrix entries are `<= x`. Because rows and columns are
sorted, that count can be done in $O(n)$ with a staircase walk: start at the top-right,
move left while the value is too big, move down otherwise. If the count is at least `k`,
the answer is `<= x`; otherwise it is bigger. Binary search on `x` over the value range.
]

#code(lang: "js", caption: "Binary search on the value range")[
```js
const kthMatrixBinary = (m, k) => {
  const n = m.length;
  let lo = m[0][0], hi = m[n - 1][n - 1];
  const countLE = (x) => {                    // how many entries are <= x
    let cnt = 0, c = n - 1;
    for (let r = 0; r < n; r++) {
      while (c >= 0 && m[r][c] > x) c--;      // c never moves back right
      cnt += c + 1;
    }
    return cnt;
  };
  while (lo < hi) {
    const mid = lo + ((hi - lo) >> 1);
    if (countLE(mid) >= k) hi = mid; else lo = mid + 1;
  }
  return lo;
};
```
]
#complexity(time: [$O(n log(max - min))$], space: $O(1)$)

#trap[
`(lo + hi) >> 1` is *not* a safe midpoint in JavaScript. `>>` converts to a signed 32-bit
integer first, so any sum above $2^31 - 1$ wraps to a negative number and the search
walks off the bottom of the range. `lo + ((hi - lo) >> 1)` keeps the shifted value small
and is safe here; when the range itself can exceed $2^31$, use
`Math.floor((hi - lo) / 2)` instead, which has no 32-bit step at all.
]

#code(lang: "text", caption: "All three agree on [[1,5,9],[10,11,13],[12,13,15]]")[
```text
k=1 -> 1 1 1      k=4 -> 10 10 10
k=8 -> 13 13 13   k=9 -> 15 15 15
1x1 matrix [[-5]], k=1 -> -5
```
]

*The idea that unlocked it:* the answer is a *number*, and "how many are `<= x`" only
grows as `x` grows. Anything monotone can be binary searched. This is the bridge between
Chapter 4 and this one — and it is why the binary-search version needs no memory at all.

#subsection[The follow-up]
*"Why does `lo` end up being an actual matrix entry, and not some value in between?"* \
Because the loop only ever sets `hi = mid` when `countLE(mid) >= k`, and it never sets
`lo` past a value with a big enough count. The smallest `x` whose count reaches `k` must
be a value that is *present* — if it were absent, `x - 1` would have the same count, and
the search would have moved further left. Be ready to say this; it is the real question.

#ex(25, tier: 3, asked: "Microsoft · pattern")[
*Smallest range covering every list.* You are given `k` sorted lists. Find the shortest
range `[x, y]` that contains at least one number from every list.

*Limits* $k <= 3500$, total $N <= 10^5$ · *Target* $O(N log k)$ ·
*Edge cases* one list; all lists identical; a list that is empty.
]
#approach(1, "Try every pair of values as the range and test all k lists", verdict: "O(N^2 k) — far too slow")
#approach(2, "One pointer per list; move the pointer sitting on the minimum", verdict: "O(N log k) with a min-heap")

#sol[
Hold one *pointer per list* — exactly the merge-k-arrays heap again. At any moment the
`k` values under the pointers touch every list, so they form a valid range: from the heap
*minimum* to a separately tracked *maximum*. To shrink it, you must move the minimum
forward, because moving anything else cannot help. Pop the minimum, advance its list,
update the maximum, repeat. Stop when a list runs out.
]

#code(lang: "js", caption: "Heap holds the minimum; a plain variable holds the maximum")[
```js
const smallestRange = (lists) => {
  const pq = new MinHeap((a, b) => a.val - b.val);
  let curMax = -Infinity;
  for (let i = 0; i < lists.length; i++) {
    if (!lists[i].length) return [0, 0];       // a list with nothing in it
    pq.push({ val: lists[i][0], li: i, idx: 0 });
    curMax = Math.max(curMax, lists[i][0]);
  }
  let bestLo = pq.peek().val, bestHi = curMax;
  for (;;) {
    const cur = pq.pop();
    if (curMax - cur.val < bestHi - bestLo) { bestLo = cur.val; bestHi = curMax; }
    if (cur.idx + 1 >= lists[cur.li].length) break;   // this list is used up
    const nx = lists[cur.li][cur.idx + 1];
    curMax = Math.max(curMax, nx);
    pq.push({ val: nx, li: cur.li, idx: cur.idx + 1 });
  }
  return [bestLo, bestHi];
};
```
]
#complexity(time: $O(N log k)$, space: $O(k)$)

#note[
`-Infinity` is the JS stand-in for `INT_MIN`, and it is a better one: it is smaller than
every number rather than merely very small, so no real input can accidentally equal it.
Use `Infinity` / `-Infinity` for "no answer yet" seeds throughout this book.
]

#code(lang: "text", caption: "Output")[
```text
[[4,10,15,24],[0,9,12,20],[5,18,22,30]] -> [20,24]
[[1,2,3],[1,2,3],[1,2,3]]               -> [1,1]
```
]

#subsection[The follow-up]
*"Why is it safe to stop the moment one list runs out?"* Because every later range would
still have to contain a number from that list, and the only numbers left there are ones
already passed. Any range covering all lists from this point on is at least as wide as
one already examined. Say that sentence; it is the proof.

#ex(26, tier: 3, asked: "Goldman Sachs · pattern")[
*Pick projects to grow capital.* You start with `C` rupees and may run at most `k`
projects, one after another. Project `i` needs `capital[i]` on hand to start and returns
`profit[i]` on top of what you already had. Maximise your final capital.

*Limits* $n <= 10^5$, $k <= 10^5$, values up to $10^9$ · *Target* $O(n log n)$ ·
*Edge cases* nothing affordable at the start; k bigger than n; a final capital far past
the 32-bit range.
]
#approach(1, "Try every choice of k projects", verdict: "combinatorial — impossible past about 20 projects")
#approach(2, "Sort by capital needed, max-heap on profit, take k times", verdict: "O(n log n)")

#sol[
Two structures working together:

- Sort the projects by *capital needed*, so you can unlock them in order as money grows.
- A *max*-heap of the *profits* of everything you can currently afford.

Each round: unlock everything newly affordable, then take the single most profitable one.
This is safe because profits are never negative, so money only grows, so anything
affordable now stays affordable.
]

#code(lang: "js", caption: "Sort by cost, heap by profit")[
```js
const maximizeCapital = (k, start, proj) => {   // proj[i] = [capital needed, profit]
  const v = [...proj].sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const affordable = new MinHeap((a, b) => b - a);   // MAX-heap on profit
  let money = start, i = 0;
  for (let step = 0; step < k; step++) {
    while (i < v.length && v[i][0] <= money) affordable.push(v[i++][1]);
    if (!affordable.size) break;              // nothing we can start
    money += affordable.pop();
  }
  return money;
};
```
]
#complexity(time: $O(n log n)$, space: $O(n)$)

#code(lang: "text", caption: "Output")[
```text
k=2, start 0, [(0,1),(1,2),(2,3)] -> 3
k=3, start 0, [(0,1),(1,2),(2,3)] -> 6
k=5, start 100, [(200,50)]        -> 100   (never affordable, so nothing happens)
```
]

#subsection[The follow-up]
*"What if a project can LOSE money?"* The greedy breaks immediately: a loss might unlock
nothing, and money no longer only grows, so "affordable now" is no longer permanent. The
problem stops being greedy and becomes a search or a DP. Recognising that the greedy
*proof* depends on non-negative profits is the point of the follow-up.

#ex(27, tier: 3, asked: "Uber · pattern")[
*Fewest refuelling stops.* A van starts with `startFuel` litres and burns one litre per
kilometre. Stations sit at given positions with given litres. Reach `target` with as few
stops as possible, or report that it is impossible.

*Limits* $n <= 500$ stations, positions and litres up to $10^9$ ·
*Target* $O(n log n)$ · *Edge cases* you can already reach the target; the first station
is out of reach.
]
#approach(1, "Dynamic programming on (station, stops used)", verdict: "O(n^2) — correct, and the usual first answer")
#approach(2, "Drive as far as possible, then take fuel from the best station already passed", verdict: "O(n log n) with a max-heap")

#sol[
This is greedy *with hindsight*. Drive as far as the fuel allows. Every station you pass
is a litre-can you *could* have taken. When you run dry, retroactively take the biggest
can you passed. A max-heap of passed station sizes gives it to you.
]

#code(lang: "js", caption: "Take fuel from the past, when you need it")[
```js
const minRefuel = (target, startFuel, st) => {   // st[i] = [position, litres]
  const v = [...st].sort((a, b) => a[0] - b[0]);
  const pq = new MinHeap((a, b) => b - a);       // MAX-heap of litres passed
  let fuel = startFuel, stops = 0, i = 0;
  while (fuel < target) {
    while (i < v.length && v[i][0] <= fuel) pq.push(v[i++][1]);
    if (!pq.size) return -1;                     // stranded
    fuel += pq.pop();
    stops++;
  }
  return stops;
};
```
]
#complexity(time: $O(n log n)$, space: $O(n)$)

#code(lang: "text", caption: "Output")[
```text
target 100, fuel 10, stations [(10,60),(20,30),(30,30),(60,40)] -> 2
target 100, fuel 100, no stations -> 0
target 100, fuel 1, station at 10 -> -1  (cannot even reach the first station)
```
]

#note[
In C++ `fuel` has to be declared as a 64-bit integer or it wraps after a few stops. In JavaScript
`fuel` is just a number and the sum of 500 stations at $10^9$ litres is $5 times 10^11$ —
comfortably exact. The only thing worth checking is the *statement's* bound: if litres
could reach $10^15$, start asking about `BigInt`.
]

#subsection[The follow-up]
*"Prove the greedy is correct."* Suppose an optimal plan makes `m` stops. Our method has
always driven at least as far with the same number of stops, because at every point it
took the biggest available can. By induction, after `m` of our stops we are at least as
far as the optimal plan, so we never need more than `m`. That exchange argument is the
same one behind Chapter 19's greedy proofs.

#ex(28, tier: 3, asked: "D. E. Shaw · pattern")[
*A heap you can update.* Dijkstra's algorithm needs "lower the key of an item already in
the heap". A plain binary heap cannot do that — it can only find its *root*. Build a heap
that can, and describe the cheaper alternative.

*Limits* $n <= 10^5$ ids, $m <= 5 times 10^5$ updates · *Target* $O(log n)$ per operation ·
*Edge cases* decreasing the key of something not in the heap; decreasing to a value that
is not actually smaller.
]

#subsection[Option A — an indexed heap]
#sol[
Keep three arrays: `key[id]`, `heap` (holding ids), and `pos[id]` (where each id sits in
`heap`, or `-1` if absent). Every swap updates `pos`, so you can find any id in $O(1)$ and
sift it from there.
]

#code(lang: "js", caption: "Indexed min-heap with decrease-key")[
```js
class IndexedHeap {
  constructor(n) {
    this.key = new Array(n).fill(Infinity);   // key[id]
    this.heap = [];                           // holds ids
    this.pos = new Array(n).fill(-1);         // pos[id] = its slot, -1 if absent
  }

  less(i, j) { return this.key[this.heap[i]] < this.key[this.heap[j]]; }

  swap(i, j) {
    [this.heap[i], this.heap[j]] = [this.heap[j], this.heap[i]];
    this.pos[this.heap[i]] = i; this.pos[this.heap[j]] = j;   // keep pos in step
  }

  up(i) {
    while (i > 0 && this.less(i, (i - 1) >> 1)) {
      this.swap(i, (i - 1) >> 1); i = (i - 1) >> 1;
    }
  }

  down(i) {
    const n = this.heap.length;
    for (;;) {
      const l = 2 * i + 1, r = 2 * i + 2;
      let b = i;
      if (l < n && this.less(l, b)) b = l;
      if (r < n && this.less(r, b)) b = r;
      if (b === i) break;
      this.swap(i, b); i = b;
    }
  }

  push(id, k) {
    this.key[id] = k;
    this.heap.push(id);
    this.pos[id] = this.heap.length - 1;
    this.up(this.pos[id]);
  }

  decrease(id, k) {
    if (this.pos[id] === -1) { this.push(id, k); return; }
    if (k >= this.key[id]) return;            // not actually an improvement
    this.key[id] = k; this.up(this.pos[id]);  // a smaller key only ever moves up
  }

  popMin() {
    const id = this.heap[0];
    this.swap(0, this.heap.length - 1);
    this.heap.pop(); this.pos[id] = -1;
    if (this.heap.length) this.down(0);
    return id;
  }

  get size() { return this.heap.length; }
}
```
]
#complexity(time: [$O(log n)$ per operation], space: $O(n)$)

#code(lang: "text", caption: "Output — push (0,40) (1,10) (2,70) (3,25), then decrease id 2 to 5")[
```text
pop ids in order: 2 1 3 0
```
]

#subsection[Option B — lazy deletion, which is what people actually write]
#sol[
Do not update anything. Push the *new* pair and leave the stale one behind. When a value
surfaces at the top, check whether it is still current; if not, pop it and carry on. The
heap grows to $O(m)$ instead of $O(n)$, but every line is simple and there is no `pos`
array to keep in step.
]

#code(lang: "js", caption: "Two heaps: live values, and values marked for removal")[
```js
class LazyHeap {
  constructor() { this.live = new MinHeap(); this.dead = new MinHeap(); }
  push(x) { this.live.push(x); }
  erase(x) { this.dead.push(x); }            // promise to remove it later
  clean() {
    while (this.dead.size && this.live.size &&
           this.live.peek() === this.dead.peek()) {
      this.live.pop(); this.dead.pop();
    }
  }
  top() { this.clean(); return this.live.peek(); }
  get empty() { this.clean(); return this.live.size === 0; }
  get size() { return this.live.size - this.dead.size; }
}
```
]
#complexity(time: [$O(log n)$ amortised], space: [$O(m)$, m = total pushes])

#code(lang: "text", caption: "Output")[
```text
push 5,1,9,3 then erase 1 -> top 3, size 3
erase 3 and 5             -> top 9, empty = false
```
]

#subsection[The follow-up]
*"Which one goes into your Dijkstra?"* Lazy deletion, almost always. The extra memory is
$O(m)$ where `m` is the number of edges, which you are already storing. Every Dijkstra you
will write looks like `pq.push([newDist, v])` with an
`if (d > dist[u]) continue;` guard at the top of the loop — that guard *is* the lazy
deletion. Reserve the indexed heap for when memory is genuinely tight.

#section[Dry run — the running median, step by step]

Trace `MedianStream` on the input 5, 15, 1, 3, 8, -4. Remember: `lo` is a max-heap
(biggest on top), `hi` is a min-heap (smallest on top), and `lo` may hold one extra item.

#table(
  columns: (auto, auto, auto, auto, auto),
  align: (center, left, left, left, center),
  [*x*], [*where it goes*], [*lo (max-heap)*], [*hi (min-heap)*], [*median*],
  [5], [`lo` is empty, so `lo`], [`[5]`], [`[]`], [5],
  [15], [15 > 5, so `hi`], [`[5]`], [`[15]`], [(5+15)/2 = 10],
  [1], [1 <= 5, so `lo`], [`[5, 1]`], [`[15]`], [5],
  [3], [3 <= 5, so `lo`; now lo has 3 and hi has 1, so move 5 across], [`[3, 1]`], [`[5, 15]`], [(3+5)/2 = 4],
  [8], [8 > 3, so `hi`; hi now has 3 and lo has 2, so move 5 back], [`[5, 3, 1]`], [`[8, 15]`], [5],
  [-4], [-4 <= 5, so `lo`; lo has 4 and hi has 2, so move 5 across], [`[3, 1, -4]`], [`[5, 8, 15]`], [(3+5)/2 = 4],
)

#code(lang: "text", caption: "The program prints exactly the last column")[
```text
[5 10 5 4 5 4]
```
]

#note[
The medians print as `5 10 5 4` and not `5.0 10.0 5.0 4.0`, because JavaScript has one
number type and drops a trailing `.0`. Only `2.5`-style answers show a decimal point. If a
judge wants one decimal place, apply `.toFixed(1)` when printing, never inside `median()`
— `toFixed` returns a *string*, and a string leaking back into the heap ruins every later
comparison.
]

#subsection[Reading the table]

Three things to notice, because they are what the interviewer probes.

+ *The rebalance runs after every insert, never before.* Insert first, then fix the
  sizes. Doing it the other way round leaves the new value on the wrong side.
+ *Only one item ever moves.* One insert can unbalance the sizes by at most one, so one
  transfer is always enough. No loop is needed.
+ *`lo` is allowed to be bigger, `hi` is not.* That asymmetry is what makes the odd case
  a single read of `lo.peek()`. If you allow it the other way you must test both sizes
  every time.

#subsection[A second trace: why build is not n pushes]

Build the heap `[9, 4, 7, 1, -3, 8, 0]`. `n = 7`, so start at index `(7 >> 1) - 1 = 2`
and walk down to 0.

#table(
  columns: (auto, auto, auto, auto),
  align: (center, left, left, left),
  [*i*], [*node and its children*], [*action*], [*array after*],
  [2], [7 with children 8 (idx 5) and 0 (idx 6)], [0 is smallest, swap], [`[9 4 0 1 -3 8 7]`],
  [1], [4 with children 1 (idx 3) and -3 (idx 4)], [-3 is smallest, swap], [`[9 -3 0 1 4 8 7]`],
  [0], [9 with children -3 (idx 1) and 0 (idx 2)], [-3 is smallest, swap; then 9 at idx 1 has children 1 and 4, so swap with 1], [`[-3 1 0 9 4 8 7]`],
)

The whole build did 4 swaps for 7 elements. Seven separate `push` calls would have done
more work and would have produced a different (also valid) heap.

#section[Python — the signature problems]

JavaScript is the language of this book, and a JS answer is always a complete answer.
Python is worth knowing for exactly one reason here: `heapq` is in the standard library,
so the three signature problems of this chapter — the running median, top-k frequent, and
merge-k — collapse to a few lines each.

#code(lang: "python", caption: "heapq is a MIN-heap; negate to get a max-heap")[
```python
import heapq
from collections import Counter

class MedianStream:
    def __init__(self):
        self.lo = []      # max-heap, stored as negatives
        self.hi = []      # min-heap

    def add(self, x):
        if not self.lo or x <= -self.lo[0]:
            heapq.heappush(self.lo, -x)
        else:
            heapq.heappush(self.hi, x)
        if len(self.lo) > len(self.hi) + 1:
            heapq.heappush(self.hi, -heapq.heappop(self.lo))
        elif len(self.hi) > len(self.lo):
            heapq.heappush(self.lo, -heapq.heappop(self.hi))

    def median(self):
        if not self.lo:
            return 0.0
        if len(self.lo) > len(self.hi):
            return float(-self.lo[0])
        return (-self.lo[0] + self.hi[0]) / 2.0

def top_k_frequent(nums, k):
    cnt = Counter(nums)
    return [v for v, _ in heapq.nsmallest(k, cnt.items(),
                                          key=lambda e: (-e[1], e[0]))]

def merge_k(lists):
    heap = [(lst[0], i, 0) for i, lst in enumerate(lists) if lst]
    heapq.heapify(heap)                      # O(n), not n pushes
    out = []
    while heap:
        val, li, idx = heapq.heappop(heap)
        out.append(val)
        if idx + 1 < len(lists[li]):
            heapq.heappush(heap, (lists[li][idx + 1], li, idx + 1))
    return out
```
]

#code(lang: "text", caption: "Output")[
```text
medians : [5.0, 10.0, 5.0, 4.0, 5.0, 4.0]
one     : 7.0
empty   : 0.0
all same: 2.0
top2    : [2, -1]
single  : [9]
all same: [5]
tie     : [3, 7]
merge   : [1, 2, 3, 4, 5, 6, 9, 10]
empties : [] []
negative: [-5, -3, -1, 0]
```
]

#trap[
`heapq` has *no* max-heap. Push `-x` and negate on the way out. If the items are tuples,
negate only the sort key: `(-count, value)`, not the whole tuple — otherwise the
tie-break flips as well, which is rarely what you want.
]

#section[Practice]

#practice(tier: 0, time: "25 min")[
+ Is `[2, 5, 4, 9, 6, 8]` a valid min-heap? Show the check for every parent.
+ In a heap of 50 items, list the indices on the path from index 41 up to the root.
+ Push 0 into the min-heap `[1, 3, 9, 5, 7]`. Show every swap.
+ Pop twice from the max-heap `[9, 7, 8, 1, 3]`. Show the array after each pop.
+ You must sort 10 million integers with almost no extra memory. Heap sort or merge sort?
  Give one reason each way.
]

#practice(tier: 1, time: "60 min")[
6. *Product of the k largest.* Return the product of the k biggest values.
   $n <= 10^5$, values up to $10^5$. Edge cases: k = 1; negative values; a product past
   `Number.MAX_SAFE_INTEGER`.
7. *Fewest platforms.* Given arrival and departure times of trains, find the smallest
   number of platforms so no train waits. Edge cases: one train; a departure equal to the
   next arrival.
8. *When does the last job finish?* `k` workers take jobs from a queue in the given order;
   each worker picks up the next job the moment they are free. Return the finish time of
   the last job. Edge cases: more workers than jobs; no jobs.
9. *Sort characters by frequency.* Rearrange a string so the most frequent characters come
   first. Edge cases: empty string; every character once.
10. *A d-ary heap.* Write a min-heap where every node has `d` children instead of 2. Show
    that it still pops in sorted order. Edge cases: d = 2; one element.
]

#practice(tier: 2, time: "70 min")[
11. *Top k words.* Return the k most frequent words, most frequent first, alphabetical on
    a tie. Edge cases: every word once; an exact tie across all words.
12. *Sliding window maximum.* Return the maximum of every window of size k, using a heap.
    Edge cases: k = 1; k = n; all values equal.
13. *Schedule with a cooldown.* Tasks have counts; two runs of the *same* task must be at
    least `cool` slots apart. Return the total time including idle slots. Edge cases:
    `cool` = 0; one task type only.
14. *K-th number from given primes.* Return the k-th smallest positive number whose only
    prime factors come from a given set. Edge cases: one prime; a candidate that leaves
    the exact-integer range.
]

#practice(tier: 3, time: "80 min")[
15. *Cheapest k workers.* Each worker has a quality and a minimum wage. If you hire a
    group, every member is paid in proportion to their quality, and nobody is paid below
    their minimum wage. Hire exactly k for the least total. Edge cases: k = 1;
    k = n; workers with the same ratio.
16. *K-th largest subarray sum.* Over every contiguous subarray, return the k-th largest
    sum. Edge cases: all negatives; k = 1; k = the total number of subarrays.
17. *Fewest halvings.* You may halve any one value. Repeat until the total has dropped by
    at least half. Return the number of halvings. Edge cases: one value; all values equal.
]

#key[
*1.* Parent 0 (=2) vs children 5 and 4 — ok. Parent 1 (=5) vs children 9 and 6 — ok.
Parent 2 (=4) vs child 8 — ok. *Valid.* \
*2.* 41 → 20 → 9 → 4 → 1 → 0, using `(i-1)/2` each time. \
*3.* Append 0 at index 5. Parent 2 holds 9 > 0 → swap: `[1,3,0,5,7,9]`, i = 2. Parent 0
holds 1 > 0 → swap: `[0,3,1,5,7,9]`, i = 0. Stop. Two swaps. \
*4.* First pop returns 9: move 3 to the root → `[3,7,8,1]`, sift down (8 is the bigger
child) → `[8,7,3,1]`. Second pop returns 8: move 1 to the root → `[1,7,3]`, sift down →
`[7,1,3]`. \
*5.* Heap sort: $O(1)$ extra memory, guaranteed $O(n log n)$ even in the worst case.
Merge sort: stable and far more cache-friendly, but needs $O(n)$ extra memory. With
"almost no extra memory" as the constraint, heap sort wins.

*6 (product of the k largest).* Min-heap of size k, then multiply.

#code(lang: "js", caption: "Size-k heap, plus the BigInt version")[
```js
const productOfKLargest = (a, k) => {
  const pq = new MinHeap();
  for (const x of a) { pq.push(x); if (pq.size > k) pq.pop(); }
  let p = 1;
  while (pq.size) p *= pq.pop();
  return p;                              // exact while |p| <= 2^53 - 1
};

const productOfKLargestBig = (a, k) => {
  const pq = new MinHeap();
  for (const x of a) { pq.push(x); if (pq.size > k) pq.pop(); }
  let p = 1n;                            // BigInt literals end in n
  while (pq.size) p *= BigInt(pq.pop());
  return p;                              // exact, however big
};
```
]
Output: `[3,9,2,7]` k=2 → 63; `[100000,90000,3]` k=2 → 9000000000;
`[-4,-9,2]` k=2 → -8 (the two largest are 2 and -4); `[5]` k=1 → 5.

#trap[
*This is the chapter's `BigInt` case.* Four values of $10^5$ give $10^20$, which is past
$2^53 - 1$. Both versions *print* `100000000000000000000`, and only the `BigInt` one is
telling the truth — the plain-number answer has silently rounded, and
`Number.isSafeInteger` on it returns `false`.

That is the whole danger: a double does not wrap or throw, it *rounds*, and the wrong
answer looks completely ordinary. Any time the statement allows a product, or a sum of
more than about $10^15$, either switch to `BigInt` or say out loud why you do not have to.
Mixing the two throws — `1n + 1` is a `TypeError` — so convert at the boundary with
`BigInt(x)` and `Number(b)`.
]

*7 (platforms).* Sort by arrival, min-heap of departures.

#code(lang: "js", caption: "Platforms")[
```js
const minPlatforms = (arr, dep) => {
  const t = arr.map((a, i) => [a, dep[i]])
               .sort((x, y) => x[0] - y[0] || x[1] - y[1]);
  const busy = new MinHeap();
  let best = 0;
  for (const [a, d] of t) {
    while (busy.size && busy.peek() < a) busy.pop();
    busy.push(d);
    best = Math.max(best, busy.size);
  }
  return best;
};
```
]
Output: arrivals `[900,940,950,1100,1500,1800]` with departures
`[910,1200,1120,1130,1900,2000]` → 3. One train → 1. `[10,20]` / `[20,30]` → 2, because
`busy.peek() < a` is strict: a train departing at 20 does *not* free the platform
for a train arriving at 20.

`arr.map((a, i) => [a, dep[i]])` is the JS way to zip two parallel arrays — there is no
`zip` in the language.

*8 (when does the last job finish).* Min-heap of "time each worker becomes free".

#code(lang: "js", caption: "k workers, jobs in the given order")[
```js
const finishTime = (jobs, k) => {
  const freeAt = new MinHeap();
  for (let i = 0; i < k; i++) freeAt.push(0);
  let last = 0;
  for (const j of jobs) {
    const t = freeAt.pop() + j;
    last = Math.max(last, t);
    freeAt.push(t);
  }
  return last;
};
```
]
Output: jobs `[5,2,3,7,1]` with 2 workers → 12; one job of 4 with 3 workers → 4; no jobs
→ 0; `[3,3,3]` with 3 workers → 3.

*9 (frequency sort).* Count, then pop from a max-heap keyed on count.

#code(lang: "js", caption: "Frequency sort")[
```js
const frequencySort = (s) => {
  const cnt = new Map();
  for (const c of s) cnt.set(c, (cnt.get(c) ?? 0) + 1);
  // max-heap on count, ties broken by the later character
  const pq = new MinHeap((x, y) =>
    y[1] - x[1] || (x[0] < y[0] ? 1 : x[0] > y[0] ? -1 : 0));
  for (const e of cnt) pq.push(e);
  let out = '';
  while (pq.size) { const [c, n] = pq.pop(); out += c.repeat(n); }
  return out;
};
```
]
Output: `"treeeb"` → `"eeetrb"`; `""` → `""`; `"aA"` → `"aA"` (both appear once, and
`'a'` = 97 outranks `'A'` = 65).
`c.repeat(n)` is the JS way to write "n copies of this character"; there is no
string-append-with-count.

*10 (d-ary heap).* Children of `i` are `d*i+1 ... d*i+d`; the parent is `(i-1)/d`.

#code(lang: "js", caption: "A d-ary min-heap")[
```js
class DaryHeap {
  constructor(d) { this.d = d; this.a = []; }
  get size() { return this.a.length; }
  up(i) {
    while (i > 0) {
      const p = Math.floor((i - 1) / this.d);   // no >> shortcut once d != 2
      if (this.a[p] <= this.a[i]) break;
      [this.a[p], this.a[i]] = [this.a[i], this.a[p]]; i = p;
    }
  }
  down(i) {
    const n = this.a.length;
    for (;;) {
      let best = i;
      for (let c = this.d * i + 1; c <= this.d * i + this.d && c < n; c++)
        if (this.a[c] < this.a[best]) best = c;
      if (best === i) break;
      [this.a[i], this.a[best]] = [this.a[best], this.a[i]]; i = best;
    }
  }
  push(x) { this.a.push(x); this.up(this.a.length - 1); }
  peek() { return this.a[0]; }
  pop() {
    const t = this.a[0], last = this.a.pop();
    if (this.a.length) { this.a[0] = last; this.down(0); }
    return t;
  }
}
```
]
Output: with `d = 4`, pushing 9, 2, 7, 1, 8, 3 pops in the order 1 2 3 7 8 9. A bigger `d`
makes the tree shorter (push gets faster) but each `down` compares `d` children (pop gets
slower). `d = 4` is a common compromise.

*11 (top k words).* A `Map` counts, and the comparator's tie rule drops the alphabetically
*later* word first, so no sorted container is needed at all.

#code(lang: "js", caption: "Count in a Map, filter with a size-k heap")[
```js
const topKWords = (w, k) => {
  const cnt = new Map();
  for (const s of w) cnt.set(s, (cnt.get(s) ?? 0) + 1);
  // root = the entry to drop: smallest count, tie -> the alphabetically later word
  const pq = new MinHeap((a, b) =>
    a[1] - b[1] || (a[0] < b[0] ? 1 : a[0] > b[0] ? -1 : 0));
  for (const e of cnt) { pq.push(e); if (pq.size > k) pq.pop(); }
  const out = [];
  while (pq.size) out.push(pq.pop()[0]);
  return out.reverse();
};
```
]
Output: `[grab, bus, grab, mrt, bus, grab, taxi]` k=2 → `grab bus`;
`[b, a, b, a, c]` k=2 → `a b` (both appear twice, so alphabetical order decides).

C++ reaches for `map<string,int>` here because it keeps keys sorted. JavaScript has no
sorted map, but it does not need one: the comparator already encodes the tie rule, so an
unordered `Map` plus the heap is enough.

*12 (sliding window maximum with a heap).* Push `(value, index)`. Before reading the top,
throw away anything whose index has left the window.

#code(lang: "js", caption: "Lazy deletion by index")[
```js
const windowMax = (a, k) => {
  // MAX-heap on [value, index]
  const pq = new MinHeap((x, y) => y[0] - x[0] || y[1] - x[1]);
  const out = [];
  for (let i = 0; i < a.length; i++) {
    pq.push([a[i], i]);
    if (i >= k - 1) {
      while (pq.peek()[1] <= i - k) pq.pop();     // stale, drop it
      out.push(pq.peek()[0]);
    }
  }
  return out;
};
```
]
Output: `[1,3,-1,-3,5,3,6,7]` k=3 → `[3 3 5 5 6 7]`; `[4]` k=1 → `[4]`; `[2,2,2]` k=2 →
`[2 2]`; `[-5,-2,-8]` k=3 → `[-2]`.
This is $O(n log n)$. A *monotonic deque* — the toolkit's `Deque`, used in Chapter 9 —
does the same job in $O(n)$. Say so, then write whichever the interviewer asks for.

*13 (schedule with a cooldown).* Each round, take up to `cool + 1` different tasks, always
the ones with the highest remaining count.

#code(lang: "js", caption: "Fill one cooldown block at a time")[
```js
const scheduleTime = (counts, cool) => {
  const pq = new MinHeap((a, b) => b - a);        // max-heap
  let time = 0;
  for (const c of counts) if (c > 0) pq.push(c);
  while (pq.size) {
    const hold = [];
    let slot = 0;
    while (slot <= cool && pq.size) {
      hold.push(pq.pop() - 1);
      slot++; time++;
    }
    for (const h of hold) if (h > 0) pq.push(h);
    if (pq.size) time += cool + 1 - slot;         // pad with idle slots
  }
  return time;
};
```
]
Output: counts `[3,3,3]` with cool = 2 → 9 (A B C A B C A B C, no idling);
`[3,1,1]` with cool = 2 → 7 (A B C A idle idle A); `[1,1,1]` with cool = 0 → 3;
no tasks → 0.

*14 (k-th number from given primes).* A min-heap plus a `Set` so each value is produced
once.

#code(lang: "js", caption: "Grow the set of reachable numbers, smallest first")[
```js
const kthMultiple = (primes, k) => {
  const pq = new MinHeap();
  const seen = new Set([1]);
  pq.push(1);
  let cur = 1;
  for (let step = 0; step < k; step++) {
    cur = pq.pop();
    for (const p of primes) {
      const nx = cur * p;
      if (Number.isSafeInteger(nx) && !seen.has(nx)) {   // stays exact
        seen.add(nx); pq.push(nx);
      }
    }
  }
  return cur;
};
```
]
Output: primes `[2,3,5]` → k=1 gives 1, k=5 gives 5, k=10 gives 12, k=40 gives 144.
Primes `[7]` → k=5 gives 2401. k=1500 with `[2,3,5]` gives 859963392.

#trap[
`Number.isSafeInteger(nx)` is the JS version of C++'s `nx / p == cur` overflow guard, and
it guards against something subtler. C++ *wraps* and pushes a negative number, which is
obvious the moment you print it. JavaScript *rounds*: `cur * p` stays positive, stays
plausible, and is simply wrong — and two rounded values can even collide, so the `Set`
stops de-duplicating correctly too. Check the guard, or work in `BigInt`.

Note also `new Set([1])` and `seen.has(nx)`. A `Set` of numbers is the right structure
here: an object used as a set would stringify every key, and `Set` gives $O(1)$ membership
with the type preserved.
]

*15 (cheapest k workers).* Everyone in the group is paid `ratio * quality`, where `ratio`
is the *largest* wage-to-quality ratio in the group. So sort by ratio, and for each worker
treat their ratio as the group's ratio while a max-heap keeps the `k` *smallest* qualities
seen so far.

#code(lang: "js", caption: "Sort by ratio, max-heap on quality")[
```js
const minCostHire = (quality, wage, k) => {
  const w = quality.map((q, i) => [wage[i] / q, q])          // [ratio, quality]
                   .sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const pq = new MinHeap((a, b) => b - a);                   // biggest quality on top
  let sumQ = 0, best = Infinity;
  for (const [ratio, q] of w) {
    pq.push(q); sumQ += q;
    if (pq.size > k) sumQ -= pq.pop();
    if (pq.size === k) best = Math.min(best, ratio * sumQ);
  }
  return best;
};
```
]
Checked against a brute force over every subset of size k:
quality `[10,20,5]`, wage `[70,50,30]`, k=2 → 105.0000 from both.
quality `[3,1,10,10,1]`, wage `[4,8,2,2,7]`, k=3 → 30.6667 from both.
One worker, k=1 → 11.0000 from both.

Note `wage[i] / q` with no cast. JavaScript `/` is always floating-point division, so
`7 / 2` is `3.5` — the opposite of the C++ habit, where the cast is what you must not
forget. When you actually want the *integer* quotient, that is `Math.floor(a / b)`, or
`(a / b) | 0` for values that fit in 32 bits.

*16 (k-th largest subarray sum).* Prefix sums turn every subarray into a difference; then
a size-k min-heap keeps the best sums.

#code(lang: "js", caption: "Prefix sums plus a size-k heap")[
```js
const kthLargestSubarraySum = (a, k) => {
  const n = a.length;
  const pre = new Array(n + 1).fill(0);
  for (let i = 0; i < n; i++) pre[i + 1] = pre[i] + a[i];
  const pq = new MinHeap();
  for (let i = 0; i < n; i++)
    for (let j = i + 1; j <= n; j++) {
      pq.push(pre[j] - pre[i]);
      if (pq.size > k) pq.pop();
    }
  return pq.peek();
};
```
]
Output: `[2,-1,3]` → k=1 gives 4, k=3 gives 2, k=6 gives -1; `[-4]` k=1 gives -4.
This is $O(n^2 log k)$, which is fine to $n approx 3000$. For bigger `n` you binary search
on the answer and count subarrays with a sum above the guess.

*17 (fewest halvings).* Always halve the current largest — a max-heap.

#code(lang: "js", caption: "Halve the biggest, repeat")[
```js
const halveSum = (a) => {
  const pq = new MinHeap((x, y) => y - x);     // max-heap
  let total = 0;
  for (const x of a) { pq.push(x); total += x; }
  let removed = 0, ops = 0;
  while (removed < total / 2) {
    const big = pq.pop();
    removed += big / 2;
    pq.push(big / 2);
    ops++;
  }
  return ops;
};
```
]
Output: `[5,19,8,1]` → 3; `[3,8,20]` → 3; `[1]` → 1; `[4,4,4,4]` → 4.
The halves are fractions, and JS numbers already *are* doubles, so nothing needs to be
declared `double` and nothing needs `/ 2.0` — `/ 2` is the same operation.
Why greedy is safe: halving the biggest value removes more than halving anything else, and
the choice made now does not restrict any later choice.
]

#revision[
#subsection[The invariant]
Min-heap: every parent `<=` both children. The array is complete, so parent of `i` is
`(i - 1) >> 1` and children are `2i+1`, `2i+2`. The heap knows *one* thing — the extreme
item — and knows it in $O(1)$.

#subsection[Template]
#code(lang: "js", caption: "The four shapes that cover this whole chapter")[
```js
const { MinHeap } = require('./toolkit.js');   // JS Toolkit appendix

// 1. keep the k LARGEST -> MIN-heap of size k (and vice versa)
const pq = new MinHeap();
for (const x of a) { pq.push(x); if (pq.size > k) pq.pop(); }
// pq.peek() is now the k-th largest

// 2. merge k sources -> one entry per source, refill on pop
const pq2 = new MinHeap((x, y) => x.val - y.val);
lists.forEach((l, i) => { if (l.length) pq2.push({ val: l[0], li: i, idx: 0 }); });

// 3. running median -> max-heap lo, min-heap hi, lo.size in {hi.size, hi.size + 1}
const lo = new MinHeap((p, q) => q - p), hi = new MinHeap();
if (!lo.size || x <= lo.peek()) lo.push(x); else hi.push(x);
if (lo.size > hi.size + 1) hi.push(lo.pop());
else if (hi.size > lo.size) lo.push(hi.pop());

// 4. greedy "always take the best available" -> sort by the gate, heap on the prize
items.sort((p, q) => p.gate - q.gate);         // NEVER a bare .sort()
while (i < items.length && items[i].gate <= budget) pq.push(items[i++].prize);
budget += pq.pop();
```
]

#subsection[Complexity table]
#table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, left),
  [*Operation*], [*Time*], [*Space*], [*Note*],
  [`push` / `pop`], [$O(log n)$], [$O(1)$], [one root-to-leaf path],
  [`top`], [$O(1)$], [$O(1)$], [it is just `a[0]`],
  [build from an array], [$O(n)$], [$O(1)$], [never push in a loop],
  [heap sort], [$O(n log n)$], [$O(1)$], [worst case too; not stable],
  [k largest of n], [$O(n log k)$], [$O(k)$], [min-heap of size k],
  [k-th largest, offline], [$O(n)$ average], [$O(n)$], [quickselect; JS has no partial sort],
  [top-k frequent], [$O(n)$], [$O(n)$], [bucket by count beats the heap],
  [merge k lists, N items], [$O(N log k)$], [$O(k)$], [one entry per list],
  [running median], [$O(log n)$], [$O(n)$], [two heaps],
  [sliding window median], [$O(n k)$ worst], [$O(k)$], [sorted array + binary search],
  [sliding window maximum], [$O(n log n)$], [$O(n)$], [the toolkit `Deque` does it in $O(n)$],
  [decrease-key (indexed heap)], [$O(log n)$], [$O(n)$], [or lazy deletion, $O(m)$ memory],
)

#subsection[Top traps]
+ *`arr.sort()` is lexicographic.* `[10, 9, 1].sort()` is `[1, 10, 9]`. Every sort in this
  chapter needs `(a, b) => a - b`, and every tie-break chains with `||`.
+ *A comparator must return a number.* `(a, b) => a.cnt > b.cnt` returns a boolean, which
  coerces to `1`/`0`; the heap silently stops ordering.
+ *JavaScript has no heap.* Write it or `require` it. Saying "I'd use a priority queue"
  and then not having one is the failure mode.
+ *k largest needs a MIN-heap.* Reach for the opposite of what feels natural. A max-heap
  is just `new MinHeap((a, b) => b - a)`.
+ *Numbers are doubles.* Exact only to $2^53 - 1$. Past that they *round* silently rather
  than wrap — guard with `Number.isSafeInteger`, or use `BigInt`.
+ *JavaScript has no `TreeMap` / ordered set.* Sorted array plus binary search, or a `Map`
  plus a maintained key list.
+ *`Map`, not a plain object, for counting.* Object keys stringify, so `-1` and `"-1"`
  collide and the values come back as strings.
+ *`new Array(n).fill([])` shares one array.* Use `Array.from({length: n}, () => [])`; the
  same rule makes `[...grid]` a shallow copy and `grid.map(r => [...r])` a real one.
+ *The heap must hold one item per list, not one list.* Otherwise merge-k is $O(N log N)$.
+ *`pop` moves the LAST element to the root.* Not the smaller child.
+ *Building beats pushing.* `new MinHeap().build(v)` is $O(n)$; pushing in a loop is
  $O(n log n)$.
+ *Heaps cannot delete a middle item.* Use lazy deletion, an indexed heap, or a sorted
  array.
+ *`filter(v => v !== x)` removes every copy.* To delete one, `splice(lowerBound(w, x), 1)`.
+ *`heapq` in Python has no max-heap.* Negate the key, and only the key.
+ *A heap is not sorted.* `[1, 3, 9, 5, 7]` is a perfectly good heap and a terrible sorted
  array. Never print the array and call it the answer.

#subsection[When to reach for what]
#table(
  columns: (auto, auto),
  align: (left, left),
  [*You need*], [*Use*],
  [the extreme item, repeatedly, with inserts], [the toolkit `MinHeap`],
  [the k best of a stream], [min-heap of size k (max-heap for k smallest)],
  [the k-th best of a fixed array, once], [quickselect — $O(n)$ average],
  [the whole thing sorted], [`a.sort((x, y) => x - y)`],
  [the max of a sliding window], [monotonic deque — $O(n)$],
  [the median of a sliding window], [sorted array + `lowerBound`],
  [delete an arbitrary item], [lazy deletion, or a sorted array],
  [lower a key that is already inside], [indexed heap, or push a duplicate and skip stale ones],
  [counts bounded by n], [bucket array — $O(n)$, no heap at all],
  [exact arithmetic past $2^53 - 1$], [`BigInt`],
)
]

]
