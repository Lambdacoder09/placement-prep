#import "../../shared/lib/style.typ": *

#chapter(
  num: 5,
  title: "Sorting & Custom Comparators",
  tagline: "Order is not the answer. Order is the shortcut that makes the answer easy.",
)[

#formulas(title: "The one idea of this chapter")[
You almost never sort because the question says "sort this".
You sort because *after sorting, a hard question becomes an easy scan.*

#table(
  columns: (1fr, 1.6fr),
  align: (left, left),
  [*Hard on unsorted data*], [*Easy after sorting*],
  [closest pair of values], [neighbours only: check $a[i] - a[i-1]$],
  [count pairs with a given sum], [two pointers from both ends],
  [k-th smallest], [index $k-1$],
  [how many duplicates], [equal values sit together],
  [best greedy pick order], [scan left to right once],
)

Cost of the shortcut: $O(n log n)$ time. You pay it once, then everything after is $O(n)$.
]

#section[Pattern in one page]

#subsection[The four shapes of `sort`]

#code(lang: "js", caption: "The only four ways you will ever call sort")[
```js
const v = [4, 1, 3];
v.sort();                          // 1. default: LEXICOGRAPHIC, almost never right
v.sort((a, b) => a - b);           // 2. numbers ascending
v.sort((a, b) => b - a);           // 3. numbers descending

const p = [{ key: 4, tag: "d" }, { key: 1, tag: "a" }, { key: 3, tag: "c" }];
p.sort((a, b) => a.key - b.key);   // 4. objects by a numeric key
const q = [...p].sort((a, b) => (a.tag < b.tag ? 1 : a.tag > b.tag ? -1 : 0));

console.log(v.join(" "), "|",
            p.map(e => e.key + e.tag).join(" "), "|",
            q.map(e => e.key + e.tag).join(" "));
```
]

Output:

#code(lang: "text", caption: "program output")[
```text
4 3 1 | 1a 3c 4d | 4d 3c 1a
```
]

#note[
`v` prints `4 3 1` because the descending call ran last. Each `sort` call overwrites the
previous order.

Two JavaScript facts hidden in that block:
- `sort` works *in place* and returns *the same array*. It does not give you a new one.
- That is why `q` starts with `[...p]`: a copy, so sorting `q` does not disturb `p`.
]

#subsection[The comparator contract — memorise this]

#formulas(title: "What a comparator must return")[
`cmp(a, b)` must return a *number*:

#table(
  columns: (auto, 1fr),
  align: (center, left),
  [*return*], [*meaning*],
  [negative], [`a` comes before `b`],
  [`0`], [tie --- leave their order alone],
  [positive], [`b` comes before `a`],
)

Three rules the engine assumes. Break one and you get a wrong order, silently.

+ *Reflexive zero*: `cmp(a, a)` is always `0`.
+ *Antisymmetric*: if `cmp(a, b)` is negative then `cmp(b, a)` must be positive.
+ *Transitive*: if `cmp(a, b) < 0` and `cmp(b, c) < 0` then `cmp(a, c) < 0`.

The name for these three together is a *strict weak ordering*.
]

#trap[
*The single most common JavaScript bug in any coding round.* `arr.sort()` with no argument
turns every element into a string and sorts those strings:

```js
[10, 9, 1].sort();                  // [1, 10, 9]   "10" sorts before "9"
[10, 9, 1].sort((a, b) => a > b);   // [10, 9, 1]   a boolean is never negative
[10, 9, 1].sort((a, b) => a - b);   // [1, 9, 10]   correct
```

Line 2 is the second trap: `a > b` gives `true` or `false`, which become `1` and `0`.
The comparator can never return a negative number, so the engine is told "these are equal
or swapped" and never "this one comes first" --- and the array comes back unsorted.

*Numbers always need `(a, b) => a - b`.* Never a `>`, never a `<=`.
]

#subsection[The multi-key template]

This shape covers 80% of comparator questions. Copy it exactly.

#code(lang: "js", caption: "multi-key comparator: marks desc, then age asc, then name A-Z")[
```js
students.sort((a, b) =>
  b.marks - a.marks ||                                  // key 1: bigger first
  a.age   - b.age   ||                                  // key 2: smaller first
  (a.name < b.name ? -1 : a.name > b.name ? 1 : 0));    // key 3: the tie-breaker
```
]

#formulas(title: "How to read the template")[
- One line per key, in priority order, joined with `||`.
- `b.marks - a.marks` is `0` when the two marks are equal. `0` is *falsy*, so `||` moves
  on to the next key. Any non-zero value stops the chain and decides the order.
- The last line has no `||` after it. It is the final tie-breaker.
- `b.x - a.x` means "bigger first". `a.x - b.x` means "smaller first". Nothing else changes.
- Strings have no `-`, so the tie-breaker spells the three cases out:
  `(a.name < b.name ? -1 : a.name > b.name ? 1 : 0)`.
]

#trap[
In C++ the `||` in a comparator is a bug. In JavaScript it is the *correct* idiom --- but
only because each piece returns a *number* and a tie returns exactly `0`. Write
`b.marks > a.marks || a.age < b.age` with booleans and the chain breaks: `false || false`
is `false`, which is `0`, which means "tie", and your second key never fires.
]

#subsection[Ties keep their order]

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, left),
  [*Language*], [*What happens to equal items*], [*Cost*],
  [JavaScript `sort`], [original order is kept --- *stable*, guaranteed since ES2019],
    [$O(n log n)$],
  [C++ `sort`], [order is scrambled, no promise (that is why it has `stable_sort`)],
    [$O(n log n)$],
)

JavaScript gives you stability for free. A question that says "keep the earlier entry first
on a tie" needs no extra work at all --- just do not add a tie-breaking key.

#code(lang: "js", caption: "sort is stable: ties keep the input order")[
```js
const v = [{ name: "amit", score: 70 }, { name: "bina", score: 90 },
           { name: "chen", score: 70 }, { name: "dev",  score: 90 },
           { name: "esha", score: 70 }];
v.sort((a, b) => a.score - b.score);     // sort is STABLE: ties keep input order
// amit/70 chen/70 esha/70 bina/90 dev/90
```
]

`amit`, `chen`, `esha` all scored 70 and they come out in exactly that input order.
With a sort that is *not* stable you would get *some* order of those three, and it may
differ between engines.

#trick[
`Array.prototype.sort` has been required to be stable since ES2019, and Node has been
stable since V8 7.0. So in modern JavaScript you get ties-keep-input-order for free.
Two cautions: an old judge may run an old engine, and `TypedArray.prototype.sort` is a
different function. When the marks depend on it, add the original index as the last key —
`|| i - j` — and the order is yours no matter what the engine does.
]

#subsection[The friends of `sort` you should know]

#code(lang: "js", caption: "cheaper than a full sort when you do not need one")[
```js
const { lowerBound, upperBound } = require('./toolkit.js');   // JS Toolkit appendix

const a = [2, 4, 4, 4, 9];
lowerBound(a, 4);                          // 1  first index with value >= 4
upperBound(a, 4);                          // 4  first index with value >  4
upperBound(a, 4) - lowerBound(a, 4);       // 3  how many 4s
a[lowerBound(a, 7)] === 7;                 // false  -- this is "binary search"

const uniq = [...new Set(a)];              // duplicates gone, no sort needed
```
]

On `a = [2, 4, 4, 4, 9]`:

#code(lang: "text", caption: "output")[
```text
lowerBound(4)=1  upperBound(4)=4  count of 4 = 4-1 = 3  found 7? false
```
]

#subsection[When NOT to use `sort`]

#table(
  columns: (1fr, 1fr, auto),
  align: (left, left, left),
  [*Situation*], [*Use instead*], [*Cost*],
  [values are small ints, $0..K$, and $K$ is near $n$], [counting sort], [$O(n + K)$],
  [only 3 distinct values (0/1/2)], [Dutch-flag one pass], [$O(n)$, $O(1)$ space],
  [you need only the top $k$], [toolkit `MinHeap` of size $k$], [$O(n log k)$],
  [you need only the $k$-th], [quickselect (write it yourself)], [$O(n)$ average],
  [data arrives as a stream], [heap of size $k$], [$O(n log k)$],
  [data is bigger than RAM], [external merge sort], [$O(n log n)$ I/O],
)

#diagram(height: 4.0cm, caption: "sorting is a pre-step: pay once, scan many times")[
  #dnode(0pt, 0.7cm, 3.1cm, 1.1cm, "raw input\n(no order)")
  #darrow(3.2cm, 1.25cm, 4.5cm, 1.25cm, label: "sort")
  #dnode(4.6cm, 0.7cm, 3.1cm, 1.1cm, "sorted array", fill: rgb("#e6efe6"))
  #darrow(7.8cm, 1.25cm, 9.1cm, 0.6cm, label: "scan")
  #darrow(7.8cm, 1.25cm, 9.1cm, 1.25cm, label: "2 ptr")
  #darrow(7.8cm, 1.25cm, 9.1cm, 1.9cm, label: "greedy")
  #dnode(9.2cm, 0.1cm, 3.4cm, 0.85cm, "neighbour answers")
  #dnode(9.2cm, 1.05cm, 3.4cm, 0.85cm, "pair answers")
  #dnode(9.2cm, 2.0cm, 3.4cm, 0.85cm, "schedule answers")
  #place(dx: 0pt, dy: 3.2cm)[#text(size: 8.5pt)[cost paid once: $O(n log n)$ #h(20pt) every arrow after it: $O(n)$]]
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Sort `a = {5, -2, 9, 0, 9, -7}` ascending, print it, then sort it descending and print again.
Constraints: $n <= 10^5$, values fit in `int`. Target: $O(n log n)$.
Edge cases: negative numbers, repeated 9.
]
#sol[
#code(lang: "js", caption: "ascending then descending")[
```js
const a = [5, -2, 9, 0, 9, -7];
a.sort((x, y) => x - y);
console.log(a.join(" "));          // -7 -2 0 5 9 9
a.sort((x, y) => y - x);
console.log(a.join(" "));          // 9 9 5 0 -2 -7
```
]
Negatives need nothing special: `<` already knows that $-7 < -2$.
]
#ans[`-7 -2 0 5 9 9` then `9 9 5 0 -2 -7`]

#ex(2, tier: 0, asked: "warm-up")[
Sort pairs by the *second* value. If two seconds are equal, the smaller first value wins.
Input `{(3,7), (1,7), (9,2), (4,2)}`.
]
#sol[
#code(lang: "js", caption: "two-key pair sort")[
```js
const p = [[3, 7], [1, 7], [9, 2], [4, 2]];
p.sort((x, y) => x[1] - y[1] || x[0] - y[0]);
// [4,2] [9,2] [1,7] [3,7]
```
]
Trace of the two-key rule:

#table(
  columns: (auto, auto, auto, 1fr),
  align: (left, left, left, left),
  [*a*], [*b*], [*seconds differ?*], [*result*],
  [(3,7)], [(9,2)], [yes, $7 != 2$], [`7 < 2` is false, so (9,2) comes first],
  [(9,2)], [(4,2)], [no, both 2], [fall to key 2: `9 < 4` is false, (4,2) first],
)
]
#ans[`(4,2) (9,2) (1,7) (3,7)`]

#ex(3, tier: 0, asked: "TCS NQT · pattern")[
Sort words by length. Same length means alphabetical order.
Input: `pen ox apple kite ax fig`.
]
#sol[
#code(lang: "js", caption: "length then alphabet")[
```js
const v = ["pen", "ox", "apple", "kite", "ax", "fig"];
v.sort((a, b) => a.length - b.length ||
                 (a < b ? -1 : a > b ? 1 : 0));   // `<` on strings is A-Z order
// ax ox fig pen kite apple
```
]
]
#ans[`ax ox fig pen kite apple`]

#ex(4, tier: 0, asked: "warm-up")[
Five students, some share a score. Sort by score ascending but keep students with the same
score in their original order.
]
#sol[
#code(lang: "js", caption: "stable_sort")[
```js
const v = [{ name: "amit", score: 70 }, { name: "bina", score: 90 },
           { name: "chen", score: 70 }, { name: "dev",  score: 90 },
           { name: "esha", score: 70 }];
v.sort((a, b) => a.score - b.score);        // nothing extra to do: sort is stable
```
]
]
#ans[`amit/70 chen/70 esha/70 bina/90 dev/90`]

#ex(5, tier: 0, asked: "Infosys · pattern")[
A shop list has name, price, quantity. Show the costliest items first. If two items cost the
same, show the smaller quantity first.
Input: rice(60,4), dal(95,2), oil(95,9), salt(20,1).
]
#sol[
#code(lang: "js", caption: "price desc, quantity asc")[
```js
const v = [{ name: "rice", price: 60, qty: 4 }, { name: "dal",  price: 95, qty: 2 },
           { name: "oil",  price: 95, qty: 9 }, { name: "salt", price: 20, qty: 1 }];
v.sort((a, b) => b.price - a.price || a.qty - b.qty);
// dal(95,2) oil(95,9) rice(60,4) salt(20,1)
```
]
]
#ans[`dal(95,2) oil(95,9) rice(60,4) salt(20,1)`]

#ex(6, tier: 0, asked: "warm-up")[
Every value is between 0 and $K$ and $K$ is small. Sort without calling `sort`.
Constraints: $n <= 10^6$, $0 <= a[i] <= K <= 10^5$. Target: $O(n + K)$.
Edge cases: empty array, one element.
]
#sol[
#code(lang: "js", caption: "counting sort")[
```js
const countingSort = (a, K) => {
  const cnt = new Array(K + 1).fill(0);
  for (const x of a) cnt[x]++;            // how many of each value
  const out = [];
  for (let v = 0; v <= K; v++)            // walk the values in order
    for (let c = 0; c < cnt[v]; c++) out.push(v);
  return out;
};
```
]
On `{4,1,4,0,2,1,4}` with `K = 4`:

#table(
  columns: (auto, auto, auto, auto, auto, auto),
  align: (left,center,center,center,center,center),
  [*value*], [0], [1], [2], [3], [4],
  [*count*], [1], [2], [1], [0], [3],
)

Output `0 1 1 2 4 4 4`. Empty input gives an empty result. A single element `{3}` gives `3`.
#complexity(time: $O(n + K)$, space: $O(K)$, note: "Beats O(n log n) only when K is not much larger than n. K = 10^9 would need 4 GB.")
]
#ans[`0 1 1 2 4 4 4`]

#section[Sorting as the pre-step]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
Find the second largest *distinct* value.
Constraints: $1 <= n <= 10^5$, $-10^9 <= a[i] <= 10^9$. Target: $O(n)$.
Edge cases: every value equal (no answer), all negatives.
]
#sol[
#approach(1, "Sort and scan", verdict: "O(n log n), fine but not the best")
#code(lang: "js", caption: "sort descending, skip copies of the maximum")[
```js
const secondLargestSort = (a) => {
  if (a.length < 2) return null;
  const b = [...a].sort((x, y) => y - x);          // copy: sort changes the array
  for (let i = 1; i < b.length; i++) if (b[i] !== b[0]) return b[i];
  return null;                                     // every value was the same
};
```
]
#complexity(time: $O(n log n)$, space: $O(1)$, note: "Correct, but we sorted the whole array to look at two numbers.")

#approach(2, "One pass with two variables", verdict: "O(n), optimal")
#code(lang: "js", caption: "carry the best two as you walk")[
```js
const secondLargestScan = (a) => {
  let best = -Infinity, second = -Infinity;
  for (const x of a) {
    if (x > best)                       { second = best; best = x; }
    else if (x < best && x > second)      second = x;
  }
  return second === -Infinity ? null : second;
};
```
]
#complexity(time: $O(n)$, space: $O(1)$, note: "-Infinity sentinels, so a[i] = -10^9 is still a real candidate.")

Trace on `{4, 9, 9, 2, 7}`:

#table(
  columns: (auto, auto, auto, 1fr),
  align: (center, center, center, left),
  [*x*], [*best*], [*second*], [*why*],
  [4], [4], [--], [first value becomes best],
  [9], [9], [4], [9 beats best, old best drops to second],
  [9], [9], [4], [`x < best` is false, so nothing happens --- this is the distinct rule],
  [2], [9], [4], [2 is not bigger than second],
  [7], [9], [7], [7 is below best and above second],
)

Checks that were run: `[4,9,9,2,7]` gives 7; `[5,5,5]` gives `null` (no second distinct
value); `[-3,-1,-7]` gives $-3$. Returning `null` — not a magic number — is the JavaScript
habit: any sentinel you pick could be a real answer, `null` never can.

#trap[
`else if (x > second)` without the `x < best` guard would let a second copy of the maximum
become the "second largest". On `{9, 9}` that wrongly answers 9.
]
The idea that unlocked it: *you do not need order, you need the top two.* Sorting gives you
far more than the question asked for.
]
#ans[7]

#ex(8, tier: 1, asked: "Capgemini · pattern")[
Given $n$ integers, find the smallest absolute difference between any two of them.
Constraints: $2 <= n <= 2 dot 10^5$, values up to $10^9$ in size. Target: $O(n log n)$.
Edge cases: duplicates (answer 0), all negatives.
]
#sol[
#approach(1, "Check every pair", verdict: "O(n^2), dies at n = 200000")
#code(lang: "js", caption: "brute force")[
```js
const minDiffBrute = (a) => {
  let best = Infinity;
  for (let i = 0; i < a.length; i++)
    for (let j = i + 1; j < a.length; j++)
      best = Math.min(best, Math.abs(a[i] - a[j]));
  return best;
};
```
]
#complexity(time: $O(n^2)$, space: $O(1)$, note: "n = 2*10^5 means 2*10^10 pairs. Far past the 10^8 budget.")

#approach(3, "Sort, then look at neighbours only", verdict: "O(n log n), optimal")
#formulas(title: "Why neighbours are enough")[
After sorting, take any pair $a[i] < a[j]$ with $j > i+1$. Then
$a[j] - a[i] = (a[j] - a[j-1]) + (a[j-1] - a[i]) >= a[j] - a[j-1]$,
because every term is $>= 0$. So a far-apart pair can never beat the neighbour pair inside
it. Checking $n-1$ neighbours is enough.
]
#code(lang: "js", caption: "sort + neighbour scan")[
```js
const minDiffSort = (a) => {
  if (a.length < 2) return -1;
  const b = [...a].sort((x, y) => x - y);
  let best = Infinity;
  for (let i = 1; i < b.length; i++) best = Math.min(best, b[i] - b[i - 1]);
  return best;
};
```
]
#complexity(time: $O(n log n)$, space: $O(1)$, note: "After sorting, a[i] - a[i-1] is never negative, so abs() is not needed.")

On `{17, 3, 40, 8, 20, 6}`: sorted is `3 6 8 17 20 40`, gaps are `3 2 9 3 20`, answer *2*.
Both versions printed 2. `{5,5,9}` gives 0. `{-10,-3,2}` gives 5.

The idea that unlocked it: *sorting turns "all pairs" into "adjacent pairs".* That single
sentence removes an entire loop.
]
#ans[2]

#ex(9, tier: 1, asked: "Wipro · pattern")[
Rank students. Higher marks first. Same marks: younger first. Same marks and age:
alphabetical.
Input: riya(88,19), arun(92,21), kabir(88,18), asha(92,21).
Constraints: $n <= 10^5$. Edge cases: a full three-way tie, students with the same name.
]
#sol[
#code(lang: "js", caption: "three-key comparator")[
```js
v.sort((a, b) =>
  b.marks - a.marks ||
  a.age   - b.age   ||
  (a.name < b.name ? -1 : a.name > b.name ? 1 : 0));
```
]
Result: `arun/92/21  asha/92/21  kabir/88/18  riya/88/19`.

Why `arun` beats `asha`: marks equal (92), age equal (21), so key 3 decides and
`"arun" < "asha"`.
Why `kabir` beats `riya`: marks equal (88), and kabir is 18 against riya's 19.
#complexity(time: $O(n log n)$, space: $O(1)$, note: "String compares are O(length); with long names think O(n log n * L).")
]
#ans[`arun asha kabir riya`]

#ex(10, tier: 1, asked: "Accenture · pattern")[
Count the pairs $(i, j)$ with $i < j$ and $a[i] + a[j] = t$.
Constraints: $n <= 2 dot 10^5$, $|a[i]| <= 10^9$, $|t| <= 2 dot 10^9$. Target: $O(n log n)$.
Edge cases: every element equal, no pair at all.
]
#sol[
#approach(1, "All pairs", verdict: "O(n^2)")
#code(lang: "js", caption: "brute force, used later as the reference answer")[
```js
const countPairsBrute = (a, t) => {
  let c = 0;
  for (let i = 0; i < a.length; i++)
    for (let j = i + 1; j < a.length; j++)
      if (a[i] + a[j] === t) c++;
  return c;
};
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(3, "Sort, then two pointers", verdict: "O(n log n), optimal")
#code(lang: "js", caption: "two pointers, counting equal blocks together")[
```js
const countPairsSorted = (a, t) => {
  const b = [...a].sort((x, y) => x - y);
  let c = 0, i = 0, j = b.length - 1;
  while (i < j) {
    const s = b[i] + b[j];
    if (s === t) {
      if (b[i] === b[j]) {                   // one block of equal values
        const m = j - i + 1;
        c += m * (m - 1) / 2;                // choose 2 out of m
        break;
      }
      let ci = 0, cj = 0;
      const vi = b[i], vj = b[j];
      while (i < j && b[i] === vi) { i++; ci++; }
      while (j >= i && b[j] === vj) { j--; cj++; }
      c += ci * cj;                          // every left with every right
    } else if (s < t) i++;                   // need a bigger sum
    else j--;                                // need a smaller sum
  }
  return c;
};
```
]
#complexity(time: $O(n log n)$, space: $O(1)$, note: "The sort dominates; the two-pointer walk is O(n).")

Tests that were run:

#table(
  columns: (1fr, auto, auto, auto),
  align: (left, center, center, left),
  [*input*], [*t*], [*answer*], [*why*],
  [`{2,4,3,5,1,3,5}`], [6], [4], [(1,5),(1,5),(3,3),(2,4)],
  [`{3,3,3,3}`], [6], [6], [all four are equal: $4 dot 3 slash 2 = 6$],
  [`{1,2}`], [99], [0], [no pair],
)

#trap[
In C++ `int s = a[i] + a[j]` overflows when both are near $10^9$. JavaScript adds as a
double, so $2 times 10^9$ is exact and nothing special is needed here. The JavaScript
version of this trap lives further out: the sum stops being exact only past
$2^53 - 1 approx 9.0 times 10^15$, and then you need `BigInt`.
]
]
#ans[4]

#ex(11, tier: 1, asked: "Cognizant · pattern")[
Merge two already-sorted arrays into one sorted array.
Constraints: $n, m <= 10^5$. Target: $O(n+m)$.
Edge cases: one array empty, duplicate values across both arrays.
]
#sol[
#approach(1, "Glue them together and re-sort", verdict: "O((n+m) log(n+m)), throws away what you were given")
#code(lang: "js", caption: "the lazy version")[
```js
const mergeSortedResort = (a, b) => a.concat(b).sort((x, y) => x - y);
```
]
#complexity(time: $O((n+m) log(n+m))$, space: $O(n+m)$, note: "Correct, and it gives the same answer as the merge below — but it pays for order it already had.")

#approach(3, "Merge in one walk", verdict: "O(n+m), optimal")
#code(lang: "js", caption: "the merge step, the heart of merge sort")[
```js
const mergeSorted = (a, b) => {
  const out = [];
  let i = 0, j = 0;
  while (i < a.length && j < b.length)
    out.push(a[i] <= b[j] ? a[i++] : b[j++]);      // <= keeps a's item first
  while (i < a.length) out.push(a[i++]);           // drain the leftovers
  while (j < b.length) out.push(b[j++]);
  return out;
};
```
]
`{1,4,9}` and `{2,4,4,10}` gives `1 2 4 4 4 9 10`.
Empty first array plus `{3,7}` gives `3 7`.
#complexity(time: $O(n+m)$, space: $O(n+m)$, note: "Sorting the joined array instead would cost O((n+m) log(n+m)) and waste the order you were given.")

#trick[
Never re-sort data that is already sorted. Merging is the cheaper move and interviewers
watch for it.
]
]
#ans[`1 2 4 4 4 9 10`]

#ex(12, tier: 1, asked: "TCS Digital · pattern")[
An array holds only 0, 1 and 2. Sort it.
Constraints: $n <= 10^6$. Target: $O(n)$ time and $O(1)$ extra space, one pass.
Edge cases: single element, all the same value.
]
#sol[
#approach(1, "Count and rewrite", verdict: "O(n) but two passes")
#code(lang: "js", caption: "count the three values, then overwrite")[
```js
const sort012Count = (a) => {
  const c = [0, 0, 0];
  for (const x of a) c[x]++;
  let k = 0;
  for (let v = 0; v < 3; v++)
    for (let t = 0; t < c[v]; t++) a[k++] = v;
};
```
]
#complexity(time: $O(n)$, space: $O(1)$, note: "Perfectly good. Fails only the extra rule 'read each element once'.")

#approach(3, "Dutch national flag, one pass", verdict: "O(n), optimal")
#formulas(title: "The invariant — this is the whole trick")[
Three walls split the array at all times:
- `a[0 .. low-1]` is all 0
- `a[low .. mid-1]` is all 1
- `a[mid .. high]` is *not yet looked at*
- `a[high+1 .. n-1]` is all 2

Stop when `mid > high`, because then nothing is unknown.
]
#code(lang: "js", caption: "one pass, three pointers")[
```js
const sort012OnePass = (a) => {
  let low = 0, mid = 0, high = a.length - 1;
  while (mid <= high) {
    if (a[mid] === 0)      { [a[low], a[mid]] = [a[mid], a[low]]; low++; mid++; }
    else if (a[mid] === 1) mid++;
    else                   { [a[mid], a[high]] = [a[high], a[mid]]; high--; }
  }                                          // do NOT move mid in the last branch
};
```
]
#complexity(time: $O(n)$, space: $O(1)$, note: "Each step either grows low/mid or shrinks high, so at most n steps.")

#trap[
In the `== 2` branch, `mid` must *not* advance. The value swapped in from `high` has never
been seen, so it must be examined next round.
]
Both versions turned `{2,0,1,2,1,0,0}` into `0001122`. A one-element array `{2}` stays `2`.
]
#ans[`0001122`]

#ex(13, tier: 1, asked: "Amazon · pattern")[
Join all the numbers into one string so the resulting number is as large as possible.
Input `{3, 30, 34, 5, 9}`.
Constraints: $n <= 10^4$, each value $<= 10^9$. Target: $O(n log n dot L)$.
Edge cases: all zeros (answer is `"0"`, not `"00"`), a single number.
]
#sol[
#formulas(title: "The comparator that makes this work")[
For two strings `x` and `y`, `x` should come first when the joined string `x+y` is bigger
than `y+x`.

`"3"` vs `"30"`: `"330"` against `"303"`. `"330"` wins, so `3` goes first.

This is not the same as `x > y`. Sorting the plain strings would put `"34"` before `"3"`
and lose.
]
#code(lang: "js", caption: "concatenation comparator")[
```js
const largestNumber = (a) => {
  const s = a.map(String);
  s.sort((x, y) => (x + y > y + x ? -1 : x + y < y + x ? 1 : 0));
  if (s[0] === "0") return "0";                  // all zeros
  return s.join("") || "0";
};
```
]
Sorted pieces: `9, 5, 34, 3, 30` giving `9534330`. `{0,0}` gives `"0"`. `{12}` gives `"12"`.
#complexity(time: $O(n log n dot L)$, space: $O(n L)$, note: "L is the digit count; each compare builds two strings of length ~2L.")

#subsection[Python version]
#code(lang: "python", caption: "same comparator, via cmp_to_key")[
```python
from functools import cmp_to_key

def largest_number(a):
    s = [str(x) for x in a]
    s.sort(key=cmp_to_key(lambda x, y: (x + y < y + x) - (x + y > y + x)))
    out = "".join(s)
    return "0" if out[0] == "0" else out

print(largest_number([3, 30, 34, 5, 9]))   # 9534330
```
]
#note[
Python's `cmp_to_key` wants $-1$ / $0$ / $+1$, not a boolean. The expression
`(less) - (greater)` produces exactly that.
]
]
#ans[`9534330`]

#ex(14, tier: 1, asked: "Infosys · pattern")[
Find the $k$-th smallest element.
Constraints: $n <= 10^6$, $1 <= k <= n$. Target: better than $O(n log n)$.
Edge cases: $k = 1$, $k = n$.
]
#sol[
#approach(1, "Sort, read index k-1", verdict: "O(n log n)")
#code(lang: "js", caption: "simple and always correct")[
```js
const kthSmallestSort = (a, k) => [...a].sort((x, y) => x - y)[k - 1];
```
]
#complexity(time: $O(n log n)$, space: $O(1)$)

#approach(3, "nth_element", verdict: "O(n) average, optimal")
#code(lang: "js", caption: "quickselect, built into the library")[
```js
const quickSelect = (a, k) => {                  // k is 1-based; a is rearranged
  let lo = 0, hi = a.length - 1;
  while (lo < hi) {
    const pivot = a[(lo + hi) >> 1];
    let i = lo, j = hi;
    while (i <= j) {                             // Hoare partition
      while (a[i] < pivot) i++;
      while (a[j] > pivot) j--;
      if (i <= j) { [a[i], a[j]] = [a[j], a[i]]; i++; j--; }
    }
    if (k - 1 <= j) hi = j;                      // the k-th is in the left part
    else if (k - 1 >= i) lo = i;                 // ...or in the right part
    else break;                                  // it is already in place
  }
  return a[k - 1];
};
```
]
#complexity(time: [$O(n)$ average], space: $O(1)$, note: "After the call, everything left of k-1 is <= it and everything right is >= it. The two sides are NOT sorted.")

On `{7, 10, 4, 3, 20, 15}` with $k = 3$ both give *7*. $k=1$ gives 3, $k=6$ gives 20.

The idea that unlocked it: *you asked for one position, not for a full order.*
Quickselect throws away half the array at each step instead of sorting it.
]
#ans[7]

#ex(15, tier: 1, asked: "Adobe · pattern")[
Sort the array so more frequent values come first. Equal frequency: smaller value first.
Input `{4,6,2,6,4,4,6,8}`.
Constraints: $n <= 10^5$. Edge cases: every value unique, every value the same.
]
#sol[
#approach(1, "Count each element by rescanning", verdict: "O(n^2)")
#code(lang: "js", caption: "brute force: one full scan per element")[
```js
const byFrequencyBrute = (a) => {
  const cnt = a.map(x => a.filter(y => y === x).length);   // one full scan each
  return a.map((v, i) => [cnt[i], v])
          .sort((x, y) => y[0] - x[0] || x[1] - y[1])
          .map(([, v]) => v);
};
```
]
#complexity(time: $O(n^2)$, space: $O(n)$, note: "Gave the same output as the fast version on the test input — it is correct, only slow.")

#approach(3, "One counting pass, then sort", verdict: "O(n log n), optimal")
#code(lang: "js", caption: "count first, then sort using the counts")[
```js
const byFrequency = (a) => {
  const f = new Map();
  for (const x of a) f.set(x, (f.get(x) ?? 0) + 1);   // pass 1: the counts
  return [...a].sort((x, y) => f.get(y) - f.get(x) || x - y);
};
```
]
Counts: `4 -> 3`, `6 -> 3`, `2 -> 1`, `8 -> 1`. Output `4 4 4 6 6 6 2 8`.
#complexity(time: $O(n log n)$, space: $O(n)$, note: "The map lookup inside the comparator is O(1) average, so the sort stays O(n log n).")

#trap[
`f[x]` on a `const` map does not compile, and on a non-const map it *inserts* a zero when
the key is missing. Here every key already exists, so it is safe --- but capture by
reference (`[&]`), never by value, or you copy the whole map for every compare.
]
]
#ans[`4 4 4 6 6 6 2 8`]

#ex(16, tier: 1, asked: "Google · pattern")[
Sort `a` so that values appear in the order given by a second array `order`. Values missing
from `order` go last, sorted ascending.
`a = {2,3,1,3,2,4,6,7,9,2,19}`, `order = {2,1,4,3,9,6}`.
Constraints: $n <= 10^5$, `order` has distinct values. Edge cases: `order` empty; no value of
`a` appears in `order`.
]
#sol[
#code(lang: "js", caption: "rank lookup inside the comparator")[
```js
const relativeSort = (a, order) => {
  const pos = new Map(order.map((v, i) => [v, i]));       // value -> rank
  const last = order.length;                              // rank for "missing"
  return [...a].sort((x, y) =>
    (pos.get(x) ?? last) - (pos.get(y) ?? last) || x - y);
};
```
]
Output: `2 2 2 1 4 3 3 9 6 7 19`.
The `7` and `19` are not in `order`, so both get rank 6 and fall to the `x < y` rule.
#complexity(time: $O(n log n + m)$, space: $O(m)$, note: "m = order.size(). Giving every missing value the same sentinel rank is what keeps the comparator transitive.")
]
#ans[`2 2 2 1 4 3 3 9 6 7 19`]

#section[Business rules become comparators]
#tier-header(2)

#ex(17, tier: 2, asked: "Grab · pattern")[
A dispatch service must pick the best $k$ free drivers. Rules, in order: highest rating,
then shortest distance, then smallest id. Busy drivers are not considered.
Constraints: $n <= 2 dot 10^5$, $k <= n$. Edge cases: fewer than $k$ free drivers; every
driver busy.
]
#sol[
#code(lang: "js", caption: "filter, then a three-key sort")[
```js
const pickDrivers = (drivers, k) =>
  drivers
    .filter(d => d.free)                                   // filter first
    .sort((a, b) => b.rating - a.rating ||
                    a.distance - b.distance ||
                    a.id - b.id)
    .slice(0, k)
    .map(d => d.id);
```
]
Input: 11(4.8, 900, free), 12(4.9, 2200, free), 13(4.9, 700, busy), 14(4.9, 700, free),
15(4.8, 900, free). With $k=3$ the answer is `14 12 11`.

- 13 is dropped: busy.
- 14 first: rating 4.9 and the shortest distance among the 4.9 drivers.
- 12 next: rating 4.9 but 2200 m away.
- 11 before 15: both 4.8 and 900 m, so the smaller id wins.

#complexity(time: $O(n log n)$, space: $O(n)$, note: "Filtering before sorting matters when most drivers are busy.")

#trap[
`double` equality (`a.rating != b.rating`) is risky if ratings come from division. Store
ratings as integers of hundredths (`490` for 4.90) in real systems.
]
]
#ans[`14 12 11`]

#ex(18, tier: 2, asked: "LINE MAN · pattern")[
A rider has $T$ minutes left. Order $i$ takes $t[i]$ minutes. Orders can be done in any
order and any subset. Maximise the *count* of completed orders.
`t = {30, 12, 45, 12, 60, 9}`, $T = 70$.
Constraints: $n <= 10^5$, $t[i] <= 10^9$, $T <= 10^14$. Edge cases: $T = 0$; $T$ big enough
for everything.
]
#sol[
#approach(1, "Try every subset", verdict: "O(2^n · n), only usable as a checker")
#code(lang: "js", caption: "bitmask brute force")[
```js
const maxOrdersBrute = (t, T) => {
  const n = t.length;
  let best = 0;
  for (let mask = 0; mask < (1 << n); mask++) {
    let s = 0, c = 0;
    for (let i = 0; i < n; i++) if (mask >> i & 1) { s += t[i]; c++; }
    if (s <= T) best = Math.max(best, c);
  }
  return best;
};
```
]
#complexity(time: $O(2^n n)$, space: $O(1)$, note: "n = 20 is already a million subsets. Use it only to check the greedy on small inputs.")

#approach(3, "Sort ascending and take greedily", verdict: "O(n log n), optimal")
#formulas(title: "Exchange argument — why greedy is safe")[
Suppose the best answer takes $c$ orders but not the $c$ shortest ones. Then it contains
some order $x$ while a shorter order $y$ is left out. Swap $x$ for $y$: the count stays $c$
and the total time does not grow. Repeat until the answer *is* the $c$ shortest orders.
So taking shortest-first never loses.
]
#code(lang: "js", caption: "sort + running sum")[
```js
const maxOrdersGreedy = (t, T) => {
  const b = [...t].sort((x, y) => x - y);
  let s = 0, c = 0;
  for (const x of b) {
    if (s + x > T) break;
    s += x; c++;
  }
  return c;
};
```
]
#complexity(time: $O(n log n)$, space: $O(1)$)

Sorted `t` is `9 12 12 30 45 60`. Running sums: 9, 21, 33, 63, then $63+45=108 > 70$ so stop.
Answer *4*. The brute force on the same input also said 4. $T=0$ gives 0; $T=1000$ gives 6.

#trap[
This maximises the *count*, not the earned money. If each order paid a different amount the
greedy is wrong and you need a knapsack (Chapter 17).
]
]
#ans[4]

#ex(19, tier: 2, asked: "Agoda · pattern")[
A hotel desk has bookings with a check-in and a check-out time. A desk can serve one guest
at a time. What is the smallest number of desks needed?
Starts `{1,2,4,9}`, ends `{5,3,7,11}`.
Constraints: $n <= 10^5$. A guest leaving at time $t$ frees the desk for a guest arriving at
$t$. Edge cases: one booking; two bookings that touch exactly.
]
#sol[
#formulas(title: "Break the pairs apart")[
You do not care *which* guest is in a desk, only *how many* guests are inside at once.
So sort the starts and the ends as two independent lists, then sweep a clock forward.
Every start adds one, every end removes one. The peak is the answer.
]
#code(lang: "js", caption: "two sorted event lists, one sweep")[
```js
const minCounters = (start, end) => {
  const s = [...start].sort((a, b) => a - b);
  const e = [...end].sort((a, b) => a - b);
  let i = 0, j = 0, cur = 0, best = 0;
  while (i < s.length) {
    if (s[i] < e[j]) { cur++; best = Math.max(best, cur); i++; }   // arrival
    else             { cur--; j++; }                               // departure
  }
  return best;
};
```
]
Sorted starts `1 2 4 9`, sorted ends `3 5 7 11`. Sweep:

#table(
  columns: (auto, auto, auto, auto, auto),
  align: (center, center, center, center, left),
  [*start[i]*], [*end[j]*], [*action*], [*cur*], [*best*],
  [1], [3], [$1 < 3$: arrive], [1], [1],
  [2], [3], [$2 < 3$: arrive], [2], [2],
  [4], [3], [$4 >= 3$: depart], [1], [2],
  [4], [5], [$4 < 5$: arrive], [2], [2],
  [9], [5], [$9 >= 5$: depart], [1], [2],
  [9], [7], [$9 >= 7$: depart], [0], [2],
  [9], [11], [$9 < 11$: arrive], [1], [2],
)
Answer *2*. A single booking gives 1. Bookings `[1,5)` and `[5,9)` give 1, because
`5 < 5` is false, so the departure is processed first.
#complexity(time: $O(n log n)$, space: $O(n)$, note: "Only starts drive the loop; ends can never run out first.")

#trap[
Use `<` and not `<=` in `start[i] < end_[j]` when leaving at $t$ frees the desk at $t$.
If the rule is "cleaning takes a minute", flip it to `<=` and the answer changes.
Ask the interviewer which rule applies.
]
]
#ans[2]

#ex(20, tier: 2, asked: "Shopee · pattern")[
A catalogue has $10^7$ products. Every price is a whole number of cents from 0 to
$10^5$. Return all prices in ascending order as fast as possible.
Edge cases: empty catalogue; every product the same price.
]
#sol[
#approach(1, "Plain a.sort((x, y) => x - y)", verdict: "O(n log n) ~ 2.3 * 10^8 compares, often too slow")
#approach(3, "Counting sort on the price range", verdict: "O(n + K), optimal here")
#code(lang: "js", caption: "counting sort with a bulk insert")[
```js
const sortPrices = (p, maxP) => {
  const cnt = new Int32Array(maxP + 1);
  for (const x of p) cnt[x]++;
  const out = new Array(p.length);
  let k = 0;
  for (let v = 0; v <= maxP; v++)
    for (let c = 0; c < cnt[v]; c++) out[k++] = v;   // never out.push(...big)
  return out;
};
```
]
`{7,2,7,0,5,2,7}` with `maxP = 7` gives `0 2 2 5 7 7 7`.
#complexity(time: $O(n + K)$, space: $O(K)$, note: "n = 10^7, K = 10^5. That is ~10^7 work, about 20x fewer operations than a comparison sort here.")

#formulas(title: "The decision rule")[
Counting sort wins when $K = O(n)$. It loses badly when $K$ is huge: prices up to $10^9$
would need a 4 GB counter array.

Rough rule for interviews: *if the value range fits in memory and is not much bigger than
$n$, count. Otherwise compare.*
]
]
#ans[`0 2 2 5 7 7 7`]

#ex(21, tier: 2, asked: "Sea/Shopee · pattern")[
A log line is `id rest`. If `rest` starts with a digit it is a *metric* log; otherwise it is
a *text* log. Sort so all text logs come first (by `rest`, ties by `id`), and every metric
log stays in its original relative order, after the text logs.
Edge cases: no metric logs at all; two text logs with identical `rest`.
]
#sol[
#code(lang: "js", caption: "stable_sort plus a comparator that only orders text logs")[
```js
const sortLogs = (logs) => {
  const cut = (s) => { const i = s.indexOf(" "); return [s.slice(0, i), s.slice(i + 1)]; };
  const isMetric = (s) => /^[0-9]/.test(cut(s)[1]);      // rest starts with a digit
  return [...logs].sort((a, b) => {
    const ma = isMetric(a), mb = isMetric(b);
    if (ma || mb) return (ma ? 1 : 0) - (mb ? 1 : 0);   // text first; metric ties
    const [ida, ra] = cut(a), [idb, rb] = cut(b);
    return (ra < rb ? -1 : ra > rb ? 1 : 0) ||
           (ida < idb ? -1 : ida > idb ? 1 : 0);
  });
};
```
]
Input and output:

#table(
  columns: (1fr, 1fr),
  align: (left, left),
  [*input order*], [*output order*],
  [`a1 9 4 2`], [`g2 act car`],
  [`g2 act car`], [`zo4 act car`],
  [`zo4 act car`], [`a8 act zoo`],
  [`ab1 off key dog`], [`ab1 off key dog`],
  [`a8 act zoo`], [`a1 9 4 2`],
  [`b3 5 1`], [`b3 5 1`],
)

`g2 act car` beats `zo4 act car` because the `rest` fields are equal and `"g2" < "zo4"`.
The two metric logs keep their input order because the comparator returns `false` both ways
for them and `stable_sort` then preserves the original positions.

#formulas(title: "Reading the tricky line")[
`if (ma || mb) return !ma && mb;`

- both metric: `!ma` is false, so returns `false` --- they are "equal", stability decides
- `a` text, `b` metric: `!ma && mb` is `true` --- text first
- `a` metric, `b` text: `!ma` is `false` --- correct, and asymmetry holds
]
#complexity(time: $O(n log n dot L)$, space: $O(n)$, note: "stable_sort allocates a buffer; L is the line length because of substr and string compare.")
]
#ans[text logs sorted by content, then the metric logs untouched]

#ex(22, tier: 2, asked: "DBS · pattern")[
$n$ warehouses hold $a[i]$ units. Moving one unit in or out of a warehouse costs 1. Make
every warehouse hold the same amount at the lowest total cost.
`a = {4, 1, 9, 7, 2}`.
Constraints: $n <= 10^5$, $a[i] <= 10^9$. Edge cases: even $n$; all values already equal.
]
#sol[
#approach(1, "Try every target between min and max", verdict: "O(n · range), unusable")
#code(lang: "js", caption: "brute force over targets")[
```js
const equalCostBrute = (a) => {
  let best = Infinity;
  const lo = Math.min(...a), hi = Math.max(...a);
  for (let t = lo; t <= hi; t++) {
    let c = 0;
    for (const x of a) c += Math.abs(x - t);
    best = Math.min(best, c);
  }
  return best;
};
```
]
#complexity(time: $O(n dot (max - min))$, space: $O(1)$, note: "With values up to 10^9 this never finishes.")

#approach(3, "Sort and move everything to the median", verdict: "O(n log n), optimal")
#formulas(title: "Why the median wins")[
Let $f(t) = sum_i |a_i - t|$. Move the target from $t$ to $t+1$:
every warehouse with $a_i <= t$ costs 1 more, every one with $a_i > t$ costs 1 less.
So $f(t+1) - f(t) = ("count" <= t) - ("count" > t)$.

That difference is negative while fewer than half the values are below $t$, and positive
after. The turning point is exactly the median. For even $n$ every point between the two
middle values gives the same cost.
]
#code(lang: "js", caption: "sort, pick the middle, sum the distances")[
```js
const equalCostMedian = (a) => {
  const b = [...a].sort((x, y) => x - y);
  const med = b[b.length >> 1];
  let c = 0;
  for (const x of b) c += Math.abs(x - med);
  return c;
};
```
]
#complexity(time: $O(n log n)$, space: $O(1)$)

Sorted: `1 2 4 7 9`. Median 4. Cost $3+2+0+3+5 = 13$. Brute force also printed 13.
`{1,2,3,4}` gives 4 both ways. `{6,6,6}` gives 0.

#trap[
Use the *median*, not the *mean*. The mean minimises squared distance; the median minimises
absolute distance. On `{1,1,1,100}` the mean is 25.75 (cost 148) and the median is 1
(cost 99).
]
]
#ans[13]

#ex(23, tier: 2, asked: "GIC · pattern")[
Return the top $k$ sellers by revenue; ties broken alphabetically. $n$ is a million and
$k$ is 10.
Edge cases: $k > n$; two sellers with equal revenue.
]
#sol[
#approach(1, "Sort everything, keep k", verdict: "O(n log n), 10^6 items sorted to print 10")
#code(lang: "js", caption: "the obvious version")[
```js
const topKFullSort = (sellers, k) =>
  [...sellers].sort((a, b) => b.revenue - a.revenue ||
                              (a.name < b.name ? -1 : a.name > b.name ? 1 : 0))
              .slice(0, k);
```
]
#complexity(time: $O(n log n)$, space: $O(1)$, note: "About 2*10^7 compares for n = 10^6.")

#approach(3, "partial_sort", verdict: "O(n log k), optimal")
#code(lang: "js", caption: "partial_sort: order only the part you print")[
```js
const topK = (sellers, k) => {
  const better = (a, b) => b.revenue - a.revenue ||
                           (a.name < b.name ? -1 : a.name > b.name ? 1 : 0);
  const heap = new MinHeap((a, b) => better(b, a));     // the WORST of the k on top
  for (const s of sellers) {
    heap.push(s);
    if (heap.size > k) heap.pop();                      // drop the worst
  }
  const out = [];
  while (heap.size) out.push(heap.pop());               // worst first...
  return out.reverse();                                 // ...so reverse
};
```
]
On `ria/900, om/1500, zed/1500, kai/200` with $k = 2$: `om/1500 zed/1500`
(equal revenue, and `"om" < "zed"`).
#complexity(time: $O(n log k)$, space: $O(1)$, note: "n = 10^6, k = 10: about 10^6 * 3.3 compares instead of 10^6 * 20 for a full sort.")

#trick[
Three tools, three questions:
- "give me the $k$-th" $->$ `nth_element`, $O(n)$
- "give me the top $k$, in order" $->$ `partial_sort`, $O(n log k)$
- "give me everything in order" $->$ `sort`, $O(n log n)$
]
]
#ans[`om/1500 zed/1500`]

#section[Sorting hidden inside another problem]
#tier-header(3)

#ex(24, tier: 3, asked: "Google · pattern")[
Find the largest gap between two consecutive values of the array *after* it would be sorted.
`a = {3, 6, 9, 1}`.
Constraints: $n <= 10^6$, $0 <= a[i] <= 10^9$. Target: $O(n)$ time.
Edge cases: $n = 1$ (answer 0); every value equal (answer 0).

*Follow-up the interviewer asks:* "your sort is $O(n log n)$ --- can you do it in linear
time?"
]
#sol[
#approach(1, "Sort and scan", verdict: "O(n log n), the honest first answer")
#code(lang: "js", caption: "baseline")[
```js
const maxGapSort = (a) => {
  if (a.length < 2) return 0;
  const b = [...a].sort((x, y) => x - y);
  let best = 0;
  for (let i = 1; i < b.length; i++) best = Math.max(best, b[i] - b[i - 1]);
  return best;
};
```
]
#complexity(time: $O(n log n)$, space: $O(1)$)

#approach(3, "Pigeonhole buckets", verdict: "O(n), optimal")
#formulas(title: "The counting insight")[
The $n$ values span the range $"hi" - "lo"$. Split that range into $n-1$ buckets, each of
width $w = ceil((("hi" - "lo")) / (n-1))$.

There are $n$ values and $n-1$ buckets, so at least one bucket is empty (pigeonhole).
That empty bucket forces the winning gap to *cross* a bucket boundary. Therefore the answer
is never a within-bucket distance, and each bucket only needs its *min* and *max*.
]
#code(lang: "js", caption: "bucket min/max, then scan the buckets")[
```js
const maxGapBucket = (a) => {
  const n = a.length;
  if (n < 2) return 0;
  const lo = Math.min(...a), hi = Math.max(...a);
  if (lo === hi) return 0;

  const width = Math.ceil((hi - lo) / (n - 1));
  const nb = Math.floor((hi - lo) / width) + 1;
  const bmin = new Array(nb).fill(Infinity), bmax = new Array(nb).fill(-Infinity);
  for (const x of a) {
    const b = Math.floor((x - lo) / width);
    bmin[b] = Math.min(bmin[b], x);
    bmax[b] = Math.max(bmax[b], x);
  }
  let best = 0, prev = null;
  for (let b = 0; b < nb; b++) {
    if (bmin[b] === Infinity) continue;                 // empty bucket, skip
    if (prev !== null) best = Math.max(best, bmin[b] - prev);
    prev = bmax[b];
  }
  return best;
};
```
]
#complexity(time: $O(n)$, space: $O(n)$, note: "Two passes over the data plus one pass over n-1 buckets.")

On `{3,6,9,1}`: $"lo"=1$, $"hi"=9$, $w = ceil(8/3) = 3$, buckets `[1,4) [4,7) [7,10)`.

#table(
  columns: (auto, auto, auto, auto),
  align: (center, center, center, center),
  [*bucket*], [*values*], [*min*], [*max*],
  [0], [1, 3], [1], [3],
  [1], [6], [6], [6],
  [2], [9], [9], [9],
)
Cross-bucket gaps: $6-3=3$, $9-6=3$. Answer *3*, matching the sort version.

Verification run: on 400 random arrays of length 1 to 9 the bucket version matched the sort
version every single time.

#trap[
In C++ `(hi - lo)` with `int` overflows when $"lo" = -2 dot 10^9$. JavaScript subtracts as
a double and gets $4 times 10^9$ exactly. What *does* bite in JavaScript is the division:
`(hi - lo) / (n - 1)` is a *float*, not an integer. Bucket indices must be floored —
`Math.floor((x - lo) / gap)` — or a fractional index silently becomes a string key.
]

*The follow-up after the follow-up:* "now the data arrives as a stream and you cannot store
it." Answer: you cannot. The maximum gap depends on every value at once; with $O(1)$ memory
it is impossible. You can only stream if you are allowed an approximate answer (keep bucket
min/max only, which is exactly what the above does in one pass if $"lo"$ and $"hi"$ are known
in advance).
]
#ans[3]

#ex(25, tier: 3, asked: "D. E. Shaw · pattern")[
Count *inversions*: pairs $(i, j)$ with $i < j$ and $a[i] > a[j]$. This measures how far the
array is from sorted.
`a = {5, 1, 4, 2, 8, 3}`.
Constraints: $n <= 2 dot 10^5$. Target: $O(n log n)$.
Edge cases: already sorted (0); reversed (n(n-1)/2); all duplicates (0).

*Follow-up:* "now the array is a stream of $10^9$ items across 50 machines."
]
#sol[
#approach(1, "Check all pairs", verdict: "O(n^2)")
#code(lang: "js", caption: "the reference implementation")[
```js
const invBrute = (a) => {
  let c = 0;
  for (let i = 0; i < a.length; i++)
    for (let j = i + 1; j < a.length; j++)
      if (a[i] > a[j]) c++;
  return c;
};
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(3, "Count during a merge sort", verdict: "O(n log n), optimal")
#formulas(title: "The one line that does the counting")[
During a merge, the left half and the right half are each already sorted.
If we are about to take `a[j]` from the *right* half while positions `i .. m-1` of the left
half are still waiting, then *every one of those `m - i` left values is greater than
`a[j]`*. That is `m - i` inversions, found in a single addition.
]
#code(lang: "js", caption: "merge sort that returns the inversion count")[
```js
const mergeCount = (a, buf, l, r) => {
  if (r - l <= 1) return 0;
  const m = (l + r) >> 1;
  let c = mergeCount(a, buf, l, m) + mergeCount(a, buf, m, r);
  let i = l, j = m, k = l;
  while (i < m && j < r) {
    if (a[i] <= a[j]) buf[k++] = a[i++];         // <= : equal is no inversion
    else { c += m - i; buf[k++] = a[j++]; }      // the whole counting trick
  }
  while (i < m) buf[k++] = a[i++];
  while (j < r) buf[k++] = a[j++];
  for (let t = l; t < r; t++) a[t] = buf[t];
  return c;
};

const invMergeSort = (a) => {
  const b = [...a];
  return mergeCount(b, new Array(b.length), 0, b.length);
};
```
]
#complexity(time: $O(n log n)$, space: $O(n)$, note: "One shared buffer, allocated once. Allocating inside the recursion would add a huge constant.")

Results: `{5,1,4,2,8,3}` gives *7* from both versions. Sorted `{1,2,3}` gives 0. Reversed
`{4,3,2,1}` gives 6. All-duplicate `{2,2,2}` gives 0 --- that is what the `<=` guarantees.
A randomised cross-check on 400 arrays agreed with the brute force every time.

#approach(4, "Fenwick tree from the right", verdict: "also O(n log n), the streaming-friendly one")
#code(lang: "js", caption: "compress values, then count smaller items already seen")[
```js
class BIT {
  constructor(n) { this.t = new Int32Array(n + 1); }
  add(i) { for (; i < this.t.length; i += i & -i) this.t[i]++; }
  sum(i) { let s = 0; for (; i > 0; i -= i & -i) s += this.t[i]; return s; }
}

const invBIT = (a) => {
  const sorted = [...new Set(a)].sort((x, y) => x - y);      // compress values
  const rank = new Map(sorted.map((v, i) => [v, i + 1]));    // 1-based ranks
  const bit = new BIT(sorted.length);
  let c = 0;
  for (let i = a.length - 1; i >= 0; i--) {                  // walk right to left
    const r = rank.get(a[i]);
    c += bit.sum(r - 1);          // smaller values already seen on the right
    bit.add(r);
  }
  return c;
};
```
]
#complexity(time: $O(n log n)$, space: $O(n)$, note: "Walking right to left means everything already in the tree sits to the right of the current index.")

*Answering the follow-up.* Inversions split cleanly:
$ "inv"(A + B) = "inv"(A) + "inv"(B) + #[pairs with one item in A and one in B] $
The cross term is exactly what the merge step counts. So: each machine sorts its own chunk
and reports its local inversion count, then the chunks are merged pairwise up a tree, each
merge adding its cross count. This is the standard external / distributed merge sort, and it
is why the merge-sort solution is the one to present in an interview even though the
Fenwick version is shorter.
]
#ans[7]

#ex(26, tier: 3, asked: "Microsoft · pattern")[
A candidate writes `(a, b) => a.score >= b.score` as a comparator. The program does not
crash — it just returns the wrong order, on every size of input. Explain, then write a test
that catches this class of bug before submission.

*Follow-up:* "how would you prove a comparator is correct?"
]
#sol[
*What goes wrong.* A JavaScript comparator must return a *number*: negative for "a first",
positive for "b first", zero for "tie". `a.score >= b.score` returns a *boolean*. The engine
coerces it, so `true` becomes `1` and `false` becomes `0` — and there is no way to produce a
negative value at all. The sort is told "b first" or "tie", never "a first", so nothing ever
moves left and the array comes back in something close to its input order.

C++ makes this mistake fatal: `>=` there breaks the strict-weak-order contract and
its sort's partitioning runs off the end of the buffer. JavaScript makes it *silent*,
which is worse for an exam. Nothing warns you.

#code(lang: "js", caption: "the boolean comparator, measured")[
```js
const mk = (n) => Array.from({length: n}, (_, i) => ({ name: "p" + i, score: (i * 37) % 10 }));

const boolCmp = (a, b) => a.score >= b.score;          // WRONG: returns true/false
const numCmp  = (a, b) => b.score - a.score;           // RIGHT: returns a number

const isSorted = (v, cmp) => v.every((x, i) => i === 0 || cmp(v[i-1], x) <= 0);

for (const n of [5, 11, 30, 1000])
  console.log("n =", n,
    "| boolean sorted?", isSorted(mk(n).sort(boolCmp), numCmp),
    "| number sorted?",  isSorted(mk(n).sort(numCmp),  numCmp));
```
]

#code(lang: "text", caption: "measured output")[
```text
n = 5 | boolean sorted? false | number sorted? true
n = 11 | boolean sorted? false | number sorted? true
n = 30 | boolean sorted? false | number sorted? true
n = 1000 | boolean sorted? false | number sorted? true
```
]

On the 11-element case the boolean comparator returns `0 7 4 1 8 5 2 9 6 3 0` — the input
order — while the number comparator returns `9 8 7 6 5 4 3 2 1 0 0`.

*The fix* is always the multi-key template: subtract to get a number, and chain the keys
with `||` only because `0` is falsy — `b.score - a.score || a.name.localeCompare(b.name)`
reads the second key exactly when the first ties.

#code(lang: "js", caption: "a checker you can paste into any solution while testing")[
```js
const sign = (x) => (x < 0 ? -1 : x > 0 ? 1 : 0);

const checkComparator = (v, cmp) => {
  for (const a of v)
    if (sign(cmp(a, a)) !== 0) return "not reflexive: cmp(a, a) must be 0";
  for (const a of v) for (const b of v)
    if (sign(cmp(a, b)) !== -sign(cmp(b, a))) return "not antisymmetric";
  for (const a of v) for (const b of v) for (const c of v)
    if (sign(cmp(a, b)) < 0 && sign(cmp(b, c)) < 0 && sign(cmp(a, c)) >= 0)
      return "not transitive";
  return "ok";
};
```
]
Run on `v = [1,2,3,4]` — measured output:

#table(
  columns: (1fr, auto),
  align: (left, left),
  [*comparator*], [*`checkComparator` says*],
  [`(a, b) => a - b`], [`ok`],
  [`(a, b) => a <= b`], [`not reflexive: cmp(a, a) must be 0`],
  [`(a, b) => a >= b`], [`not reflexive: cmp(a, a) must be 0`],
)

Both boolean comparators fail on the very first check, because `cmp(a, a)` is `true`, which
coerces to `1`, not `0`. That one line of testing would have caught the bug.
#complexity(time: [$O(m^3)$ for a sample of size $m$], space: $O(1)$, note: "Never ship this. Run it on a 20-element sample during testing only.")

#trap[
A comparator can also break transitivity without any `<=`. Example:
`return a.score > b.score || a.name < b.name;`
Here `||` lets the second key fire even when the first key already decided, and the result
is not transitive. Keys must be chained with `if`, never with `||`.
]

*The follow-up.* A comparator built from the multi-key template is correct by construction:
it is a lexicographic order on a tuple of keys, and a lexicographic order on totally-ordered
keys is always a strict weak ordering. If you cannot express your rule that way --- for
example "a beats b if they played and a won" --- then your rule is probably not an ordering
at all and sorting is the wrong tool; you want a topological sort (Chapter 16).
]
#ans[`>=` returns a boolean, which coerces to 1 or 0 — the comparator can never say "a first", so nothing is sorted]

#ex(27, tier: 3, asked: "Amazon · pattern")[
An array is *k-sorted*: every element is at most $k$ positions away from where it belongs.
Sort it faster than $O(n log n)$.
`a = {3, 1, 2, 6, 4, 8, 7}`, $k = 2$.
Constraints: $n <= 10^6$, $k <= 100$. Edge cases: $k = 0$ (already sorted); $k >= n$.

*Follow-up:* "the array is a stream that does not fit in memory."
]
#sol[
#approach(1, "Ignore the promise and just sort", verdict: "O(n log n)")
#code(lang: "js", caption: "correct, but wastes the k-sorted property")[
```js
const sortKSortedFull = (a, k) => a.sort((x, y) => x - y);   // k is never used
```
]
#complexity(time: $O(n log n)$, space: $O(log n)$, note: "Gives the same array as the optimal version. The interviewer's point is that k <= 100 is free information.")

#approach(3, "Min-heap of size k+1", verdict: "O(n log k), optimal")
#formulas(title: "Why a window of size k+1 is enough")[
The true smallest element is at most $k$ places from index 0, so it lives somewhere in
`a[0 .. k]`. Take the minimum of that window and it is the global minimum. Slide the window
one step and repeat. A min-heap of $k+1$ items is exactly that sliding window.
]
#code(lang: "js", caption: "min-heap of size k+1")[
```js
const sortKSorted = (a, k) => {
  const heap = new MinHeap((x, y) => x - y);     // toolkit: JS has no heap
  let w = 0;                                    // write position
  for (const x of a) {
    heap.push(x);
    if (heap.size > k + 1) a[w++] = heap.pop();
  }
  while (heap.size) a[w++] = heap.pop();        // drain the tail
  return a;
};
```
]
#complexity(time: $O(n log k)$, space: $O(k)$, note: "With k = 100, log k is about 7 against log n = 20 for n = 10^6: roughly 3x fewer compares.")

`{3,1,2,6,4,8,7}` with $k = 2$ becomes `1 2 3 4 6 7 8`. `{9,4}` with $k=1$ becomes `4 9`.

#trap[
`if (pq.size() > k + 1)` compares a `size_t` with an `int`. If `k` were $-1$ the `int` would
convert to a giant unsigned value and the branch never fires. Cast: `(int)pq.size()`.
]

*The follow-up.* The heap version already handles a stream: it holds only $k+1$ items at a
time and emits output as it goes. That is its real selling point --- not the $log k$, but
the $O(k)$ memory. Push every arriving item, pop whenever the heap exceeds $k+1$, and the
popped sequence is the sorted stream.
]
#ans[`1 2 3 4 6 7 8`]

#ex(28, tier: 3, asked: "Goldman Sachs · pattern")[
Sort by the number of 1-bits in the binary form. Same bit count: smaller value first.
`{7, 1, 8, 3, 2, 15, 4}`.
Constraints: $n <= 10^5$, $0 <= a[i] < 2^31$. Edge cases: value 0; two values with the same
popcount.

*Follow-up:* "sort in $O(n)$ using this key."
]
#sol[
#approach(1, "Count the bits with a loop inside the comparator", verdict: "O(n log n · 32)")
#code(lang: "js", caption: "correct, but the bit loop runs on every comparison")[
```js
const popcountLoop = (x) => {
  let c = 0;
  while (x) { c += x & 1; x >>>= 1; }      // >>> not >>: x can reach 2^31
  return c;
};

const byPopcountLoop = (a) =>
  [...a].sort((x, y) => popcountLoop(x) - popcountLoop(y) || x - y);
```
]
`popcountLoop(15)` is 4 and `popcountLoop(0)` is 0.
#complexity(time: $O(32 n log n)$, space: $O(1)$, note: "Same output as the version below, roughly 30x more work inside the comparator.")

#approach(2, "Compute each key once, then sort pairs", verdict: "O(n log n), the portable fix")
#note[
Build an array of `[popcount, value]` pairs first and sort that — or, as the code below
does, a `Map` from value to key. The bit loop then runs $n$ times instead of $2 n log n$
times. This is the trick to remember whenever the sort key is expensive:
*precompute the key*.
]

#approach(3, "One CPU instruction", verdict: "O(n log n), optimal constant")
#code(lang: "js", caption: "popcount as the primary key")[
```js
const popcount = (x) => {                  // JS has no __builtin_popcount
  x = x - ((x >>> 1) & 0x55555555);
  x = (x & 0x33333333) + ((x >>> 2) & 0x33333333);
  x = (x + (x >>> 4)) & 0x0f0f0f0f;
  return (x * 0x01010101) >>> 24;
};

const byPopcount = (a) => {
  const key = new Map(a.map(x => [x, popcount(x)]));   // compute each key ONCE
  return [...a].sort((x, y) => key.get(x) - key.get(y) || x - y);
};
```
]
#table(
  columns: (auto, auto, auto),
  align: (center, center, center),
  [*value*], [*binary*], [*bits*],
  [1], [`0001`], [1],
  [2], [`0010`], [1],
  [4], [`0100`], [1],
  [8], [`1000`], [1],
  [3], [`0011`], [2],
  [7], [`0111`], [3],
  [15], [`1111`], [4],
)
Output: `1 2 4 8 3 7 15`.
#complexity(time: $O(n log n)$, space: $O(n)$, note: "The bit-twiddle popcount is ~5 operations against ~32 for the loop. Verified equal to the loop on every x from 0 to 99999.")

*The follow-up, answered.* The key has only 32 possible values (0 to 31 bits set), so
counting sort applies: bucket by popcount in $O(n)$, then sort each bucket. But the
within-bucket rule is "smaller value first", which still needs a comparison sort *inside*
each bucket, so the honest total is $O(n log n)$ again. The $O(n)$ answer is only real if
the tie rule is "keep input order" --- then bucket by popcount with a stable pass and you
are done in $O(n + 32)$.

#trick[
Every bit operator in JavaScript first truncates to *32 bits*, so this `popcount` is only
correct for $0 <= x < 2^32$. Use `>>>` (not `>>`) throughout, or the sign bit of a value
above $2^31$ makes the shift drag in ones. Above $2^32$ there is no 64-bit type to switch
to: count the bits of a `BigInt` instead —
`let c = 0n; while (n) { c += n & 1n; n >>= 1n; }`. Tested: that loop gives `40` for
`2n**40n - 1n`.
]
]
#ans[`1 2 4 8 3 7 15`]

#ex(29, tier: 3, asked: "Uber · pattern")[
A 100 GB file of integers must be sorted on a machine with 8 GB of RAM.
Describe the algorithm and write the in-memory part.

*Follow-up:* "now there are 50 machines."
]
#sol[
*The shape of external merge sort:*

+ Read the file in chunks that fit in RAM (say 4 GB each, giving 25 chunks).
+ Sort each chunk in memory and write it back to disk as a sorted run.
+ Merge all 25 runs at once with a min-heap, reading a small buffer from each run and
  writing the output as one long stream.

Step 3 is the only interesting code. It is the K-way merge.

#code(lang: "js", caption: "K-way merge with a min-heap")[
```js
const mergeK = (chunks) => {
  const heap = new MinHeap((a, b) => a.val - b.val);
  chunks.forEach((chunk, c) => {
    if (chunk.length) heap.push({ val: chunk[0], c, i: 0 });   // skip empties
  });
  const out = [];
  while (heap.size) {
    const { val, c, i } = heap.pop();
    out.push(val);
    if (i + 1 < chunks[c].length)
      heap.push({ val: chunks[c][i + 1], c, i: i + 1 });       // refill same chunk
  }
  return out;
};
```
]
On `{{1,9,12}, {}, {2,3,30}, {0,11}}` the output is `0 1 2 3 9 11 12 30`.
All-empty input gives an empty result.
#complexity(time: $O(N log K)$, space: $O(K)$, note: "N total items, K runs. Memory holds only one item per run plus the I/O buffers.")

#trap[
`if (!chunks[c].empty())` is not decoration. Pushing `chunks[c][0]` from an empty vector is
undefined behaviour and is the single most common bug in K-way merge code.
]

*The follow-up.* With 50 machines the same three steps run in parallel: every machine sorts
its own slice locally (step 1--2), then a merge tree combines them, each level halving the
number of runs. The total I/O is what matters, not the compare count --- the algorithm is
chosen to read and write each byte a small fixed number of times, which is why merge sort
and not quicksort is the external algorithm of choice. Quicksort's access pattern is random;
merge sort's is sequential, and sequential disk reads are an order of magnitude faster.
]
#ans[external merge sort: chunk, sort in RAM, K-way merge with a heap]

#section[Dry run: counting inversions, line by line]

Input `a = {6, 2, 5, 1}`. Expected answer: the pairs $(6,2), (6,5), (6,1), (2,1), (5,1)$,
so *5*.

#subsection[Step 1 --- the recursion splits the array]

#diagram(height: 4.2cm, caption: "the call tree; counting happens on the way back up")[
  #dnode(3.6cm, 0pt, 3.6cm, 0.75cm, "[6,2,5,1]  l=0 r=4")
  #darrow(4.6cm, 0.8cm, 2.6cm, 1.5cm)
  #darrow(6.2cm, 0.8cm, 8.2cm, 1.5cm)
  #dnode(1.1cm, 1.55cm, 3.0cm, 0.75cm, "[6,2]  l=0 r=2")
  #dnode(6.7cm, 1.55cm, 3.0cm, 0.75cm, "[5,1]  l=2 r=4")
  #darrow(1.8cm, 2.35cm, 0.9cm, 3.0cm)
  #darrow(3.4cm, 2.35cm, 4.2cm, 3.0cm)
  #darrow(7.4cm, 2.35cm, 6.5cm, 3.0cm)
  #darrow(9.0cm, 2.35cm, 9.8cm, 3.0cm)
  #dnode(0.2cm, 3.05cm, 1.5cm, 0.7cm, "[6]", fill: rgb("#f2f2ee"))
  #dnode(3.5cm, 3.05cm, 1.5cm, 0.7cm, "[2]", fill: rgb("#f2f2ee"))
  #dnode(5.8cm, 3.05cm, 1.5cm, 0.7cm, "[5]", fill: rgb("#f2f2ee"))
  #dnode(9.1cm, 3.05cm, 1.5cm, 0.7cm, "[1]", fill: rgb("#f2f2ee"))
]

#subsection[Step 2 --- every merge, exactly as the program printed it]

#code(lang: "text", caption: "instrumented run of mergeCount on {6,2,5,1}")[
```text
  merge l=0 m=1 r=2  left=[6] right=[2]  before=0
    take right 2 add 1
    drain left 6 add 0
  -> [2,6] total=1

  merge l=2 m=3 r=4  left=[5] right=[1]  before=0
    take right 1 add 1
    drain left 5 add 0
  -> [1,5] total=1

merge l=0 m=2 r=4  left=[2,6] right=[1,5]  before=2
  take right 1 add 2
  take left 2 add 0
  take right 5 add 1
  drain left 6 add 0
-> [1,2,5,6] total=5

answer = 5
```
]

#subsection[Step 3 --- the top merge as a state table]

Entering the top merge: left half `[2,6]` at positions 0..1, right half `[1,5]` at
positions 2..3, `m = 2`, count carried up from below `= 1 + 1 = 2`.

#table(
  columns: (auto, auto, auto, auto, auto, 1fr),
  align: (center, center, center, center, center, left),
  [*i*], [*j*], [*a[i]*], [*a[j]*], [*c*], [*decision*],
  [0], [2], [2], [1], [2], [$2 <= 1$? no. Take right. Left still has $m-i = 2-0 = 2$ items, *add 2* $->$ c = 4],
  [0], [3], [2], [5], [4], [$2 <= 5$? yes. Take left, add 0. $i -> 1$],
  [1], [3], [6], [5], [4], [$6 <= 5$? no. Take right. Left has $2-1 = 1$ item, *add 1* $->$ c = 5],
  [1], [--], [6], [--], [5], [right half empty. Drain the left, add 0],
)

Buffer fills as `1`, then `1 2`, then `1 2 5`, then `1 2 5 6`. Final count *5*.

#formulas(title: "What to say out loud in the interview")[
"When I take a value from the right half, every left value still waiting is larger than it.
That is `m - i` inversions in one addition. The merge sort was going to walk the array
anyway, so counting is free."
]

#subsection[Step 4 --- check the edge cases]

#table(
  columns: (1fr, auto, 1fr),
  align: (left, center, left),
  [*input*], [*count*], [*reason*],
  [`{1,2,3}`], [0], [already sorted, the `<=` branch always wins],
  [`{4,3,2,1}`], [6], [every pair is an inversion: $4 dot 3 slash 2 = 6$],
  [`{2,2,2}`], [0], [equal is not an inversion, thanks to `a[i] <= a[j]`],
  [`{}`], [0], [`r - l <= 1` returns immediately],
)

#subsection[Python version of the same algorithm]

#code(lang: "python", caption: "merge sort inversion count in Python")[
```python
def count_inversions(a):
    def go(v):
        if len(v) <= 1:
            return v, 0
        m = len(v) // 2
        L, cl = go(v[:m])
        R, cr = go(v[m:])
        out, c, i, j = [], cl + cr, 0, 0
        while i < len(L) and j < len(R):
            if L[i] <= R[j]:
                out.append(L[i]); i += 1
            else:
                c += len(L) - i
                out.append(R[j]); j += 1
        out += L[i:] + R[j:]
        return out, c
    return go(a)[1]

print(count_inversions([6, 2, 5, 1]))   # 5
print(count_inversions([]))             # 0
print(count_inversions([4, 3, 2, 1]))   # 6
```
]

#section[Practice]

#practice(tier: 0, time: "20 min for P1--P3")[
*P1.* Print the third *smallest distinct* value of `{9,4,4,1,7,9}`. Say what your code does
when there are fewer than three distinct values.

*P2.* Sort `{go, tree, ant, bee, apple}` by length descending; same length means *reverse*
alphabetical.

*P3.* Write `isSorted(a)` returning whether `a` is non-decreasing. Test it on `{1,2,2,5}`,
`{3,1}` and the empty array.
]

#practice(tier: 1, time: "45 min for P4--P7")[
*P4.* Two arrays `a` and `b` of the same length $n <= 10^5$, values up to $10^5$. Pair each
`a[i]` with one `b[j]`, each used once, to make $sum a_i b_j$ as *small* as possible.
Watch for overflow.

*P5.* Count distinct values in an array of size $10^5$ using sorting only (no hash map).

*P6.* Rearrange so even numbers come first in increasing order and odd numbers follow in
decreasing order. Test `{5,2,9,4,7,8}`.

*P7.* Given stick lengths and a tolerance $d$, pair up sticks whose lengths differ by at
most $d$. Each stick is in at most one pair. Maximise the number of pairs.
Test `{1,3,4,9,10,20}` with $d = 2$.
]

#practice(tier: 2, time: "50 min for P8--P11")[
*P8.* Each boat carries at most 2 people and at most `limit` kilograms. Find the smallest
number of boats. Test `{1,2,3,5}` with `limit = 5`.

*P9.* Child $i$ is satisfied by a cookie of size $>=$ `need[i]`. One cookie per child.
Maximise satisfied children. Test `need = {1,3,5}`, `size = {1,2,4,6}`.

*P10.* Orders have `(id, priority, timestamp)`. Return the ids of the top 3 by priority
descending, then oldest timestamp first, then smallest id.
Test `{(1,2,50),(2,5,90),(3,5,30),(4,1,10)}`.

*P11.* Given arrival and departure times of drivers going online and offline, find the
largest number that were online at the same moment. Test in `{1,2,6}`, out `{4,5,8}`.
]

#practice(tier: 3, time: "60 min for P12--P15")[
*P12.* Count pairs $i < j$ with $a[i] > 2 dot a[j]$ in $O(n log n)$.
Test `{8,3,1,20,2}`. Beware: $2 dot a[j]$ can overflow `int`.

*P13.* h-index: the largest $h$ such that at least $h$ papers have $>= h$ citations.
Test `{6,1,4,0,3}`.

*P14.* Minimum number of swaps (of any two positions) to sort an array of distinct values.
Test `{4,3,2,1}`.

*P15.* Given intervals, choose the largest set with no two overlapping.
Test `{(1,3),(2,5),(4,7),(6,8),(8,9)}`.
]

#key[
*P1 --- answer 7.* Sort, then `unique` collapses runs of equal values. Return a sentinel if
fewer than 3 remain.
```js
const thirdSmallest = (a) => {
  const u = [...new Set(a)].sort((x, y) => x - y);
  return u.length >= 3 ? u[2] : null;
};
```
`[1,1]` returns `null` — fewer than three distinct values. #complexity(time: $O(n log n)$, space: $O(n)$)

*P2 --- `apple tree bee ant go`.*
```js
const byLengthDesc = (v) =>
  [...v].sort((a, b) => b.length - a.length ||
                        (a > b ? -1 : a < b ? 1 : 0));   // reverse alphabetical
```
`bee` beats `ant` because both have length 3 and `"bee" > "ant"`.

*P3 --- `1`, `0`, `1`.* An empty array and a one-element array are sorted by definition.
```js
const isSorted = (a) => {
  for (let i = 1; i < a.length; i++) if (a[i] < a[i - 1]) return false;
  return true;
};
```
The loop starts at `i = 1`, so size 0 and size 1 never enter it.

*P4 --- answer 30 for `a={1,5,3}`, `b={4,2,8}`.* Pair the smallest of one with the largest
of the other. Sorted `a = 1,3,5`; `b` descending `= 8,4,2`; products $8 + 12 + 10 = 30$.
```js
const minPairSum = (a, b) => {
  const x = [...a].sort((p, q) => p - q);       // one ascending
  const y = [...b].sort((p, q) => q - p);       // the other descending
  let s = 0n;                                   // BigInt: the total passes 2^53-1
  for (let i = 0; i < x.length; i++) s += BigInt(x[i]) * BigInt(y[i]);
  return s;
};
```
*Why it works (exchange argument):* take any two pairs $(x_1, y_1)$ and $(x_2, y_2)$ with
$x_1 < x_2$ and $y_1 < y_2$. Then
$x_1 y_2 + x_2 y_1 - (x_1 y_1 + x_2 y_2) = -(x_2 - x_1)(y_2 - y_1) < 0$,
so crossing them is always better. Repeat and you reach "ascending against descending".
*Big-number test:* `a = b = [100000, 100000]` gives 20000000000. That is past the 32-bit
limit — a C++ `int` would wrap — but a JavaScript number holds it exactly, and stays exact
all the way to $2^53 - 1$.
#complexity(time: $O(n log n)$, space: $O(1)$)

*P5 --- answer 3 for `{4,4,4,2,9,2}`.*
```js
const distinctCount = (a) => {
  const b = [...a].sort((x, y) => x - y);
  let c = 0;
  for (let i = 0; i < b.length; i++) if (i === 0 || b[i] !== b[i - 1]) c++;
  return c;
};
```
`unique` only removes *adjacent* duplicates, which is exactly why the sort must come first.
Empty input gives 0. #complexity(time: $O(n log n)$, space: $O(1)$)

*P6 --- `2 4 8 9 7 5`.*
```js
const evensThenOdds = (a) =>
  [...a].sort((x, y) => {
    const ex = x % 2 === 0, ey = y % 2 === 0;
    if (ex !== ey) return ex ? -1 : 1;      // an even value comes first
    return ex ? x - y : y - x;              // evens ascending, odds descending
  });
```
`return ex` is the whole "evens first" rule: if exactly one of them is even, `ex` is `true`
precisely when it is `x`.
*Careful with negatives:* in C++, `-3 % 2` is `-1`, not `1`. Use `x % 2 == 0` (as above)
rather than `x % 2 == 1`, which is false for every negative odd number.

*P7 --- answer 2.* Sort, then walk left to right pairing each element with its neighbour
when they fit.
```js
const maxPairs = (a, d) => {
  const b = [...a].sort((x, y) => x - y);
  let c = 0;
  for (let i = 1; i < b.length; ) {
    if (b[i] - b[i - 1] <= d) { c++; i += 2; }    // pair them, skip both
    else i++;
  }
  return c;
};
```
Sorted `1 3 4 9 10 20`: (3,4) pairs, (9,10) pairs, 1 and 20 are left over. Answer 2.
`{2,2,2}` with $d=0$ gives 1: one pair and a leftover.
#complexity(time: $O(n log n)$, space: $O(1)$)

*P8 --- answer 3.* Sort, then two pointers: the heaviest person always boards; the lightest
joins only if they fit together.
```js
const minBoats = (w, limit) => {
  const b = [...w].sort((x, y) => x - y);
  let i = 0, j = b.length - 1, boats = 0;
  while (i <= j) {
    if (b[i] + b[j] <= limit) i++;      // the lightest rides along
    j--; boats++;                       // the heaviest always rides
  }
  return boats;
};
```
`{1,2,3,5}, limit 5`: (5) alone, (1,3) together, (2) alone $=> 3$ boats.
#complexity(time: $O(n log n)$, space: $O(1)$)

*P9 --- answer 3.* Sort both. Give the smallest cookie that works to the least demanding
child.
```js
const assignCookies = (need, size) => {
  const n = [...need].sort((a, b) => a - b);
  const s = [...size].sort((a, b) => a - b);
  let i = 0, j = 0, c = 0;
  while (i < n.length && j < s.length) {
    if (s[j] >= n[i]) { c++; i++; }     // this cookie satisfies this child
    j++;                                // the cookie is used up either way
  }
  return c;
};
```
`need = 1,3,5`; `size = 1,2,4,6`: cookie 1 to child 1; cookie 2 wasted; cookie 4 to child 3;
cookie 6 to child 5. Answer 3. `need={9}, size={1}` gives 0.

*P10 --- `3 2 1`.*
```js
const topOrders = (o, k) =>
  [...o].sort((a, b) => b.priority - a.priority || a.ts - b.ts || a.id - b.id)
        .slice(0, k)
        .map(x => x.id);
```
Orders 2 and 3 both have priority 5; order 3's timestamp 30 beats order 2's 90, so 3 is
first. Then order 1 (priority 2), then order 4.

*P11 --- answer 2.* Same sweep as Example 19: sort the two lists, then walk.
```js
const busiest = (inTimes, outTimes) => {
  const a = [...inTimes].sort((x, y) => x - y);
  const b = [...outTimes].sort((x, y) => x - y);
  let i = 0, j = 0, cur = 0, best = 0;
  while (i < a.length) {
    if (a[i] < b[j]) { cur++; best = Math.max(best, cur); i++; }
    else { cur--; j++; }
  }
  return best;
};
```
Sessions $[1,4)$, $[2,5)$, $[6,8)$: the first two overlap, the third is alone. Answer 2.

*P12 --- answer 5.* Merge sort again, but *count before you merge*, with a separate pointer.
```js
const cntBig = (a, buf, l, r) => {
  if (r - l <= 1) return 0;
  const m = (l + r) >> 1;
  let c = cntBig(a, buf, l, m) + cntBig(a, buf, m, r);
  let j = m;
  for (let i = l; i < m; i++) {                  // both halves are sorted here
    while (j < r && a[i] > 2 * a[j]) j++;
    c += j - m;                                  // a[m..j) all qualify
  }
  let i = l; j = m; let k = l;                   // now the ordinary merge
  while (i < m && j < r) buf[k++] = a[i] <= a[j] ? a[i++] : a[j++];
  while (i < m) buf[k++] = a[i++];
  while (j < r) buf[k++] = a[j++];
  for (let t = l; t < r; t++) a[t] = buf[t];
  return c;
};

const countBigPairs = (a) => {
  const b = [...a];
  return cntBig(b, new Array(b.length), 0, b.length);
};
```
`{8,3,1,20,2}`: the qualifying pairs are $(8,3), (8,1), (8,2), (3,1), (20,2)$ $=> 5$.
A randomised cross-check against the $O(n^2)$ version agreed on 300 random arrays.
*Two traps:* the counting loop must run *before* the merge destroys the two sorted halves;
and `2 * a[j]` overflows `int` when $a[j] > 10^9$, so write `2LL * a[j]`.
#complexity(time: $O(n log n)$, space: $O(n)$)

*P13 --- answer 3.* Sort descending and walk while the citation count can still support the
position.
```js
const hIndex = (c) => {
  const b = [...c].sort((x, y) => y - x);       // descending
  let h = 0;
  while (h < b.length && b[h] >= h + 1) h++;
  return h;
};
```
Sorted `6 4 3 1 0`: $6 >= 1$ ok, $4 >= 2$ ok, $3 >= 3$ ok, $1 >= 4$ no. Answer 3.
`{0,0}` gives 0. #complexity(time: $O(n log n)$, space: $O(1)$)

*P14 --- answer 2.* Sorting by cycles: every cycle of length $L$ needs $L-1$ swaps.
```js
const minSwaps = (a) => {
  const p = a.map((v, i) => [v, i]).sort((x, y) => x[0] - y[0]);
  const seen = new Array(a.length).fill(false);
  let swaps = 0;
  for (let i = 0; i < a.length; i++) {
    if (seen[i] || p[i][1] === i) continue;
    let len = 0, j = i;
    while (!seen[j]) { seen[j] = true; j = p[j][1]; len++; }
    swaps += len - 1;
  }
  return swaps;
};
```
`{4,3,2,1}` has two cycles of length 2 ($0<->3$ and $1<->2$), so $1 + 1 = 2$ swaps.
Already-sorted input gives 0. #complexity(time: $O(n log n)$, space: $O(n)$)

*P15 --- answer 3.* Sort by *end* time, then take greedily.
```js
const maxNonOverlap = (v) => {
  const b = [...v].sort((a, c) => a[1] - c[1]);      // earliest finish first
  let c = 0, last = -Infinity;
  for (const [s, e] of b) if (s >= last) { c++; last = e; }
  return c;
};
```
Picks $(1,3)$, then $(4,7)$, then $(8,9)$. Answer 3.
*Why end time and not start time:* finishing early leaves the most room for everything that
follows. Sorting by start would pick $(1,3)$ and then be blocked by a very long interval.
#complexity(time: $O(n log n)$, space: $O(1)$)
]

#revision[
#subsection[The comparator template --- write this from memory]
#code(lang: "js", caption: "multi-key, safe, always correct")[
```js
v.sort((a, b) =>
  b.k1 - a.k1 ||                                   // key 1, bigger first
  a.k2 - b.k2 ||                                   // key 2, smaller first
  (a.k3 < b.k3 ? -1 : a.k3 > b.k3 ? 1 : 0));       // final tie-breaker
```
]

#subsection[Which tool for which question]
#table(
  columns: (1.3fr, 1fr, auto, auto),
  align: (left, left, center, center),
  [*Question says*], [*Use*], [*Time*], [*Space*],
  [sort everything], [`sort`], [$O(n log n)$], [$O(log n)$],
  [keep ties in input order], [`stable_sort`], [$O(n log n)$], [$O(n)$],
  [top $k$, in order], [`partial_sort`], [$O(n log k)$], [$O(1)$],
  [just the $k$-th], [`nth_element`], [$O(n)$ avg], [$O(1)$],
  [values are $0..K$, $K approx n$], [counting sort], [$O(n+K)$], [$O(K)$],
  [only 3 distinct values], [Dutch flag], [$O(n)$], [$O(1)$],
  [each item $<= k$ from home], [min-heap size $k+1$], [$O(n log k)$], [$O(k)$],
  [count inversions], [merge sort or BIT], [$O(n log n)$], [$O(n)$],
  [maximum gap after sorting], [pigeonhole buckets], [$O(n)$], [$O(n)$],
  [bigger than RAM], [external merge sort], [$O(n log n)$ I/O], [$O(K)$],
)

#subsection[Sort-then-scan playbook]
#table(
  columns: (1fr, 1.2fr),
  align: (left, left),
  [*After sorting, this becomes...*], [*...this scan*],
  [closest pair], [`a[i] - a[i-1]` over all i],
  [pair with a target sum], [two pointers from both ends],
  [duplicates], [`a[i] == a[i-1]`],
  [$k$-th smallest], [`a[k-1]`],
  [pair small with large], [`a[i]` against `b[n-1-i]`],
  [most concurrent intervals], [merge two sorted event lists],
  [max non-overlapping intervals], [greedy by earliest end],
  [minimum total move cost], [move everything to the median],
)

#subsection[Top traps]
+ Bare `a.sort()` on numbers $->$ *lexicographic* order. `[10,9,1].sort()` gives
  `[1,10,9]`. Numbers always need `a.sort((x, y) => x - y)`. This is the single most
  common JavaScript bug in a coding round.
+ A comparator that returns a *boolean* $->$ coerced to 1 or 0, so it can never say
  "a first" and nothing sorts. Always return a number.
+ `a.sort(...)` sorts *in place* and returns the same array. When the caller still needs
  the original, sort a copy: `[...a].sort(...)`.
+ Two keys joined with `||` where the first key can legitimately return `0`
  $->$ the second key fires on a non-tie. Subtracting numbers is safe; a hand-rolled
  first key that returns `0` for "a first" is not.
+ Counting sort when the value range is $10^9$ $->$ out of memory.
+ Sorting an array of objects and expecting the *original* array to stay untouched.
+ In Dutch flag, advancing `mid` after a swap with `high`.
+ Pushing from an empty chunk in a K-way merge.
+ Sorting data that already arrived sorted --- merge instead.
+ Using the mean where the problem needs the median.

#subsection[Complexity facts to quote]
- Comparison sorting cannot beat $O(n log n)$: there are $n!$ orders and each compare gives
  one bit, so at least $log_2(n!) approx n log_2 n - 1.44 n$ compares are needed.
- V8's `Array.prototype.sort` is TimSort: a stable merge sort that finds and extends
  already-ordered runs. Worst case is $O(n log n)$; an already-sorted array costs $O(n)$.
  Stability has been guaranteed by the language since ES2019.
- Counting and radix sorts beat the bound only because they never compare two values.
]
]
