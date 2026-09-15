#import "../../shared/lib/style.typ": *

#show: chapter.with(
  num: 4,
  title: "Binary Search",
  tagline: "Halve the search space, every single step.",
)

#section[Pattern in one page]

Most students learn binary search as "find a number in a sorted array". That is the
smallest thing it does. The real definition is wider, and it is what interviewers test:

#formulas(title: "The one idea")[
Binary search works on any range where some yes/no test flips *once* and never flips back.

Line up the test for every candidate. You must be able to say the answers look like this:

#align(center)[`F F F F F T T T T T`]

Then you can find the boundary — the first `T` — in $O(log n)$ tests. The array does not
have to be sorted. The candidates do not even have to be array positions: they can be
capacities, speeds, days, or lengths. The only thing that matters is that the test is
*monotone*.
]

#diagram(height: 2.9cm, caption: "Find the first T. Everything left of it is F, forever.")[
  #dnode(0cm,    0.3cm, 0.95cm, 0.8cm, "F")
  #dnode(1.05cm, 0.3cm, 0.95cm, 0.8cm, "F")
  #dnode(2.10cm, 0.3cm, 0.95cm, 0.8cm, "F")
  #dnode(3.15cm, 0.3cm, 0.95cm, 0.8cm, "F")
  #dnode(4.20cm, 0.3cm, 0.95cm, 0.8cm, "T", fill: rgb("#d8e8d8"))
  #dnode(5.25cm, 0.3cm, 0.95cm, 0.8cm, "T", fill: rgb("#d8e8d8"))
  #dnode(6.30cm, 0.3cm, 0.95cm, 0.8cm, "T", fill: rgb("#d8e8d8"))
  #darrow(0.47cm, 2.05cm, 0.47cm, 1.22cm, label: "lo")
  #darrow(3.62cm, 2.05cm, 3.62cm, 1.22cm, label: "mid")
  #darrow(6.77cm, 2.05cm, 6.77cm, 1.22cm, label: "hi")
]

#subsection[The three templates you must own]

#code(lang: "js", caption: "T1 — exact match, closed range [lo, hi]")[
```js
let lo = 0, hi = n - 1;
while (lo <= hi) {
  const mid = Math.floor(lo + (hi - lo) / 2);
  if (a[mid] === target) return mid;
  if (a[mid] < target) lo = mid + 1;
  else                 hi = mid - 1;
}
return -1;
```
]

#code(lang: "js", caption: "T2 — first index that satisfies a test, half-open range [lo, hi)")[
```js
let lo = 0, hi = n;              // hi is ONE PAST the last index
while (lo < hi) {
  const mid = Math.floor(lo + (hi - lo) / 2);
  if (!good(mid)) lo = mid + 1;   // mid is still F, throw it away
  else            hi = mid;       // mid might be the answer, keep it
}
return lo;                        // === n means "no index is good"
```
]

#code(lang: "js", caption: "T3 — binary search on the ANSWER")[
```js
let lo = smallestPossibleAnswer, hi = largestPossibleAnswer;
while (lo < hi) {
  const mid = Math.floor(lo + (hi - lo) / 2);
  if (feasible(mid)) hi = mid;      // mid works; try smaller
  else               lo = mid + 1;  // mid too small; go up
}
return lo;
```
]

#note[
T2 and T3 are the *same loop*. The only difference is what the candidates mean: array
indexes in T2, real-world quantities in T3. Learn one, and you have both.
]

#subsection[Three rules that stop infinite loops]

#formulas(title: "Loop hygiene")[
+ *Always shrink.* Every branch must either raise `lo` or lower `hi`. `lo = mid` with
  `while (lo < hi)` loops forever when `hi = lo + 1`.
+ *Match the guard to the range.* Closed range `[lo, hi]` pairs with `while (lo <= hi)`
  and `mid ± 1`. Half-open range `[lo, hi)` pairs with `while (lo < hi)` and `hi = mid`.
+ *`mid` must be a whole number.* In JavaScript `/` is real division, so `(lo + hi) / 2`
  can be `3.5` and `a[3.5]` is `undefined`. Write
  `const mid = Math.floor(lo + (hi - lo) / 2);` every single time.
]

#trap[
*Do not write `(lo + hi) >> 1` to floor it.* Every bitwise operator in JavaScript first
chops its operand down to a *signed 32-bit* integer, so the shift breaks the moment the
sum passes $2^31$. Tested in Node with `lo = 3000000000` and `hi = 3000000002`:

- `(lo + hi) >> 1` gives `852516353` — nonsense,
- `Math.floor(lo + (hi - lo) / 2)` gives `3000000001` — correct.

Binary search on the *answer* routinely runs past $2^31$ (capacities, times, distances),
so `>>1` is a bug waiting for a big test case. Use `Math.floor` and subtract first.
]

#subsection[How many steps?]

Each step throws away half the range. Starting from $n$ candidates you are done after
about $log_2 n$ steps.

#table(
  columns: (auto, auto, auto),
  [*n*], [*steps*], [*meaning*],
  [$10^3$], [10], [instant],
  [$10^6$], [20], [instant],
  [$10^9$], [30], [instant],
  [$10^18$], [60], [still instant],
)

#trick[
When the constraint line says $n <= 10^5$ but the *values* go up to $10^9$, that is a
loud hint: the answer is being searched, not the array. Reach for T3.
]

#subsection[When to reach for it]

#table(
  columns: (1fr, 1fr),
  [*You see this in the question*], [*Reach for*],
  [sorted array, find / count a value], [T1, or T2 twice],
  ["first index where ...", "how many are less than ..."], [T2],
  ["minimum capacity / speed / size so that ..."], [T3, feasible is monotone],
  ["maximum ... such that ..."], [T3, flipped: find the last feasible],
  [rotated sorted array], [T1 with a "which half is sorted" test],
  [two sorted arrays, k-th or median], [binary search on the *split point*],
  [answer is a real number], [fixed 100 iterations of halving],
)

#subsection[Four JavaScript facts you must know before you start]

#trap[
*`arr.sort()` sorts LEXICOGRAPHICALLY, as text.* Tested in Node:
`[10, 9, 1].sort()` returns `[1, 10, 9]`, because `"10" < "9"` when you compare them as
strings. Numbers *always* need a comparator:
`[10, 9, 1].sort((a, b) => a - b)` returns `[1, 9, 10]`.

Binary search on a sorted array is worthless if the sort was wrong, and this chapter sorts
in five different places — Examples 14, 19, 23, 25 and practice answer 12. Every one of
them passes the comparator, and so must you.
]

#trap[
*`sort` changes the array in place.* `a.sort(...)` returns `a` itself, not a new array, so
a helper that sorts its argument quietly damages the caller's data. When the caller must
keep the original order, copy first: `const sorted = [...a].sort((x, y) => x - y);`
]

#note[
*JavaScript has no `lowerBound`.* There is nothing in the standard library that finds the
first position at or after which a value belongs. You write it once (Examples 2 and 3),
and after that this chapter uses the tested copy from the *JS Toolkit* appendix:

#code(lang: "js", caption: "one line, once per file")[
```js
const { lowerBound, upperBound } = require('./toolkit.js');
```
]
]

#note[
*There is no built-in heap either, and no ordered map.* Two follow-ups in this chapter
compare binary search against a heap (Examples 25 and 28). If you code one, use the
`MinHeap` from the *JS Toolkit* appendix; JavaScript ships no priority queue and no
`TreeMap`. A `Map` keeps insertion order, never key order.
]

#pagebreak(weak: true)
#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Return any index holding `target` in a sorted array, or `-1`.
Constraints: $0 <= n <= 10^5$. Target $O(log n)$.
Edge cases: empty array; target not present; single element.
]
#sol[
#code(lang: "js", caption: "Template T1")[
```js
const binarySearch = (a, target) => {
  let lo = 0, hi = a.length - 1;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] === target) return mid;
    if (a[mid] < target) lo = mid + 1;
    else                 hi = mid - 1;
  }
  return -1;
};
```
]
Tested on `[2,5,5,5,9,14,20]`: `9` gives `4`, `5` gives `3` (any of the three is
acceptable), `3` gives `-1`. Empty array gives `-1`. `[7]` with target `7` gives `0`.
#complexity(time: $O(log n)$, space: $O(1)$)
#note[
`hi` starts at `n - 1`, so for an empty array `hi = -1` and the loop body never runs.
No special case needed.
]
]

#ex(2, tier: 0, asked: "warm-up")[
`lowerBound(a, x)`: the first index `i` with `a[i] >= x`. Return `n` if there is none.
Constraints: $0 <= n <= 10^5$, duplicates allowed. Target $O(log n)$.
Edge cases: `x` smaller than everything; `x` larger than everything.
]
#sol[
This is Template T2 with `good(mid)` meaning `a[mid] >= x`.
#code(lang: "js", caption: "lowerBound, written out")[
```js
const lowerBound = (a, x) => {
  let lo = 0, hi = a.length;          // hi is one past the end
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] < x) lo = mid + 1;
    else            hi = mid;
  }
  return lo;
};
```
]
Tested on `[2,5,5,5,9,14,20]`: `x = 5` gives `1`, `x = 6` gives `4`, `x = 1` gives `0`,
`x = 99` gives `7`. Empty array gives `0`. Cross-checked on 2000 random arrays against the
tested `lowerBound` in the *JS Toolkit* appendix.
#complexity(time: $O(log n)$, space: $O(1)$)
#note[
JavaScript has no `lowerBound` of its own — there is nothing in the standard library that
finds an insertion point. You write it once, and from Example 7 onwards this chapter uses
the tested copy from the *JS Toolkit* appendix:
`const { lowerBound, upperBound } = require('./toolkit.js');`
]]

#ex(3, tier: 0, asked: "warm-up")[
`upperBound(a, x)`: the first index with `a[i] > x`.
Same constraints. Edge cases: `x` equal to the last value.
]
#sol[
One character changes: `<` becomes `<=`.
#code(lang: "js", caption: "upperBound, written out")[
```js
const upperBound = (a, x) => {
  let lo = 0, hi = a.length;
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] <= x) lo = mid + 1;
    else             hi = mid;
  }
  return lo;
};
```
]
Tested on the same array: `x = 5` gives `4`, `x = 6` gives `4`, `x = 1` gives `0`,
`x = 20` gives `7`.
#complexity(time: $O(log n)$, space: $O(1)$)
#trick[
Memorise the pair as a picture. `lowerBound` stops *before* the first copy of `x`.
`upperBound` stops *after* the last copy. Everything in between is `x`.
]
]

#ex(4, tier: 0, asked: "warm-up")[
How many times does `x` appear in a sorted array?
Target $O(log n)$. Edge cases: `x` absent; every element equal to `x`.
]
#sol[
#code(lang: "js", caption: "Count by subtraction")[
```js
const countOf = (a, x) => upperBound(a, x) - lowerBound(a, x);
```
]
Tested on `[2,5,5,5,9,14,20]`: `5` gives `3`, `2` gives `1`, `7` gives `0`. Empty array
gives `0`.
#complexity(time: $O(log n)$, space: $O(1)$)
]

#ex(5, tier: 0, asked: "warm-up")[
`floorOf(a, x)`: the largest value that is $<= x$. `ceilOf(a, x)`: the smallest value that
is $>= x$. Report a sentinel when none exists.
Edge cases: `x` below the whole array; `x` above the whole array; `x` present exactly.
]
#sol[
#code(lang: "js", caption: "Floor and ceiling from the two bounds")[
```js
const floorOf = (a, x) => {          // largest value <= x, or null
  const i = upperBound(a, x);
  return i === 0 ? null : a[i - 1];
};
const ceilOf = (a, x) => {           // smallest value >= x, or null
  const i = lowerBound(a, x);
  return i === a.length ? null : a[i];
};
```
]
Tested on `[2,5,5,5,9,14,20]`: `floorOf(13)` gives `9`, `ceilOf(13)` gives `14`,
`floorOf(1)` reports "none", `ceilOf(21)` reports "none", and with `x = 5` both return `5`.
#complexity(time: $O(log n)$, space: $O(1)$)
#trap[
For the floor you need `upperBound`, not `lowerBound`. If `x` is present, `lowerBound`
points *at* it and `i - 1` would skip over a valid answer.
]
]

#ex(6, tier: 0, asked: "warm-up")[
Integer square root: the largest `r` with $r^2 <= n$.
Constraints: $0 <= n <= 10^18$. Target $O(log n)$.
Edge cases: `n = 0`, `n = 1`, a perfect square, and overflow.
]
#sol[
#approach(1, "Count up", verdict: "O(sqrt n), a billion steps at the top of the range")
#code(lang: "js", caption: "Linear")[
```js
const isqrtLinear = (n) => {
  let r = 0;
  while ((r + 1) * (r + 1) <= n) r++;
  return r;
};
```
]
#complexity(time: $O(sqrt(n))$, space: $O(1)$)

#approach(2, "Binary search", verdict: "O(log n) — optimal for this shape")
`mid * mid` can grow far past `Number.MAX_SAFE_INTEGER` and stop being exact. Compare with
a *division* instead — that never grows.
#code(lang: "js", caption: "Overflow-safe integer square root")[
```js
const isqrtBS = (n) => {
  let lo = 0, hi = n, ans = 0;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (mid === 0 || mid <= n / mid) { ans = mid; lo = mid + 1; }
    else                             { hi = mid - 1; }
  }
  return ans;
};
```
]
Tested: `0` gives `0`, `1` gives `1`, `24` gives `4`, `25` gives `5`, `26` gives `5`, and
`9007199254740991` gives `94906265`. Checked against the linear version for every `n` from
`0` to `3000`.
#complexity(time: $O(log n)$, space: $O(1)$)

#trap[
*Every JavaScript number is a double.* Whole numbers are exact only up to
`Number.MAX_SAFE_INTEGER`, which is `9007199254740991`, about $9 times 10^15$. The
constraint here says $n <= 10^18$, which is a hundred times past that line, so plain
numbers are the wrong tool. Tested in Node:

- `123456789 * 123456789` prints `15241578750190520`; the true answer ends in `521`,
- `9007199254740993` prints as `9007199254740992` — the literal itself is already lost.

Above $2^53 - 1$ you must switch to `BigInt`.
]

#approach(3, "The same search in BigInt", verdict: "O(log n), and exact all the way to 10^18")
`BigInt` literals end in `n`. Division on `BigInt` throws the fraction away, which is
exactly the whole-number division this algorithm wants, so `mid * mid <= n` is safe again.

#code(lang: "js", caption: "Integer square root for n past 2^53 - 1")[
```js
const isqrtBig = (n) => {            // n is a BigInt, and so is the answer
  let lo = 0n, hi = n, ans = 0n;
  while (lo <= hi) {
    const mid = lo + (hi - lo) / 2n;
    if (mid * mid <= n) { ans = mid; lo = mid + 1n; }
    else                { hi = mid - 1n; }
  }
  return ans;
};
```
]
Tested: `isqrtBig(1000000000000000000n)` gives `1000000000n`,
`isqrtBig(999999999999999999n)` gives `999999999n`, `isqrtBig(0n)` gives `0n`. Checked
against the linear version for every `n` from `0` to `3000`.
#complexity(time: $O(log n)$, space: $O(1)$, note: "Timed in Node, a 3-million-step modular loop took 13 ms with numbers and 193 ms with BigInt - about 15x slower. Reach for BigInt only where the exactness is actually needed.")
#trap[
Never mix the two. Tested in Node, `1n + 1` throws
`TypeError: Cannot mix BigInt and other types, use explicit conversions`. Convert on
purpose: `BigInt(5) + 1n` gives `6n`, and `Number(5n) + 1` gives `6`. Note that
`Number(b)` silently loses precision once `b` passes $2^53 - 1$ - convert back only when
you know the value is small.
]
]

#pagebreak(weak: true)
#section[Tier 1 — the template problems]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
Report the first and the last index of `target` in a sorted array with duplicates, or
`(-1, -1)`.
Constraints: $0 <= n <= 10^5$. Target $O(log n)$.
Edge cases: target absent; all values equal to target; single element.
]
#sol[
#approach(1, "Scan the whole array", verdict: "O(n)")
#code(lang: "js", caption: "Brute force")[
```js
const firstLastScan = (a, x) => {
  let f = -1, l = -1;
  for (let i = 0; i < a.length; i++)
    if (a[i] === x) { if (f === -1) f = i; l = i; }
  return [f, l];
};
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#approach(2, "Two bounded searches", verdict: "O(log n) — optimal")
#code(lang: "js", caption: "Reuse lowerBound and upperBound")[
```js
const { lowerBound, upperBound } = require('./toolkit.js');   // JS Toolkit appendix

const firstLast = (a, x) => {
  const lo = lowerBound(a, x);
  if (lo === a.length || a[lo] !== x) return [-1, -1];
  return [lo, upperBound(a, x) - 1];
};
```
]
Tested on `[2,5,5,5,9,14,20]`: `5` gives `(1, 3)` — the scan agrees — `7` gives
`(-1, -1)`, `20` gives `(6, 6)`. Cross-checked against the scan on 2000 random arrays and
every target from `-1` to `13`.
#complexity(time: $O(log n)$, space: $O(1)$)

*The unlocking idea:* "first index with `a[i] >= x`" and "first index with `a[i] > x`" are
both monotone tests, and every count question in a sorted array is the difference of two
such boundaries.
#trap[
You must check `a[lo] != x` before trusting `lo`. `lowerBound` returns the *insert
position* when the value is missing, and that position holds a different number.
]
]

#ex(8, tier: 1, asked: "Infosys · pattern")[
An array where no two neighbours are equal. Return the index of any *peak* — an element
larger than both of its neighbours. The two ends count as having an infinitely small
neighbour outside.
Constraints: $1 <= n <= 10^5$. Target $O(log n)$.
Edge cases: $n = 1$; a strictly rising array; a strictly falling array.
]
#sol[
#approach(1, "Check every index", verdict: "O(n)")
#code(lang: "js", caption: "Brute force")[
```js
const peakIndexLinear = (a) => {
  const n = a.length;
  for (let i = 0; i < n; i++) {
    const okL = i === 0     || a[i - 1] < a[i];
    const okR = i === n - 1 || a[i + 1] < a[i];
    if (okL && okR) return i;
  }
  return -1;
};
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#approach(2, "Walk uphill by halving", verdict: "O(log n) — optimal")
The array is not sorted, so there is nothing to compare the target against. What *is*
monotone is the direction of the slope. If `a[mid] < a[mid+1]` the ground rises to the
right, so a peak must exist somewhere to the right — keep going up.

#code(lang: "js", caption: "Binary search with no target")[
```js
const peakIndex = (a) => {
  let lo = 0, hi = a.length - 1;
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] < a[mid + 1]) lo = mid + 1;
    else                     hi = mid;
  }
  return lo;
};
```
]
Tested: `[1,4,9,7,3]` gives index `2` and so does the linear version. `[5]` gives `0`,
`[1,2,3]` gives `2`, `[3,2,1]` gives `0`. Verified on 2000 random arrays that the returned
index really is a peak.
#complexity(time: $O(log n)$, space: $O(1)$)

*The unlocking idea:* binary search does not need a sorted array. It needs a *monotone
decision*, and "which way is uphill" is one.
#note[
Why must a peak exist to the right when the ground rises? Keep walking right. Either you
keep rising until the last element — which is then a peak — or you stop rising somewhere,
and that stopping point is a peak. There is no third option.
]
]

#ex(9, tier: 1, asked: "Wipro · pattern")[
A sorted array of distinct values was rotated left an unknown number of times. Find the
index of the smallest value.
Constraints: $1 <= n <= 10^5$. Target $O(log n)$.
Edge cases: no rotation at all; $n = 1$; rotation by exactly $n - 1$.
]
#sol[
Picture the rotated array as two rising runs, the second one entirely below the first.
The smallest value is the *only* place the ground drops.

#diagram(height: 3.2cm, caption: "A rotated array: run 1 is high, run 2 is low. The minimum starts run 2.")[
  #dnode(0cm,    1.5cm, 0.9cm, 0.6cm, "17")
  #dnode(1.0cm,  1.15cm, 0.9cm, 0.6cm, "23")
  #dnode(2.0cm,  0.8cm, 0.9cm, 0.6cm, "31")
  #dnode(3.2cm,  2.3cm, 0.9cm, 0.6cm, "2", fill: rgb("#f1e0d8"))
  #dnode(4.2cm,  2.0cm, 0.9cm, 0.6cm, "5", fill: rgb("#f1e0d8"))
  #dnode(5.2cm,  1.7cm, 0.9cm, 0.6cm, "9", fill: rgb("#f1e0d8"))
  #dnode(6.2cm,  1.4cm, 0.9cm, 0.6cm, "12", fill: rgb("#f1e0d8"))
]

#approach(1, "Scan for the smallest value", verdict: "O(n)")
#code(lang: "js", caption: "Brute force")[
```js
const minIndexScan = (a) => {
  let best = 0;
  for (let i = 1; i < a.length; i++) if (a[i] < a[best]) best = i;
  return best;
};
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#approach(2, "Compare against the right end", verdict: "O(log n) — optimal")
Compare `a[mid]` with the *last* element. If `a[mid] > a[hi]`, then `mid` is still inside
the high run, so the minimum is strictly to the right.

#code(lang: "js", caption: "Index of the minimum in a rotated array")[
```js
const minIndexRotated = (a) => {
  let lo = 0, hi = a.length - 1;
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] > a[hi]) lo = mid + 1;
    else                hi = mid;
  }
  return lo;
};
```
]
Tested: `[17,23,31,2,5,9,12]` gives `3`, `[4,5,6]` (not rotated) gives `0`, `[9]` gives
`0`, `[5,1]` gives `1` — the scan agrees on all four. Verified against the true minimum on
2000 random rotations.
#complexity(time: $O(log n)$, space: $O(1)$)
#trap[
Compare with `a[hi]`, never with `a[lo]`. With `a[lo]` the un-rotated case `[4,5,6]` sends
you right and you return the wrong index.
]
]

#ex(10, tier: 1, asked: "Capgemini · pattern")[
Same rotated array of distinct values. Find `target`, or `-1`.
Constraints: $0 <= n <= 10^5$. Target $O(log n)$.
Edge cases: empty array; target in the low run; target absent.
]
#sol[
#approach(1, "Scan", verdict: "O(n)")
Works, but throws the structure away.

#approach(2, "Find the minimum, then search one side", verdict: "O(log n), two passes")
Use Example 9 to locate the split, then binary-search the half that can contain the
target. Correct, but it is two pieces of code to get right.

#approach(3, "One pass: at least one half is always sorted", verdict: "O(log n) — optimal")
Cut at `mid`. One of the two halves is a plain sorted run. Work out which, then ask a
simple range question about it.

#code(lang: "js", caption: "Search in a rotated sorted array")[
```js
const searchRotated = (a, t) => {
  let lo = 0, hi = a.length - 1;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] === t) return mid;
    if (a[lo] <= a[mid]) {                        // left half is sorted
      if (a[lo] <= t && t < a[mid]) hi = mid - 1;
      else                          lo = mid + 1;
    } else {                                      // right half is sorted
      if (a[mid] < t && t <= a[hi]) lo = mid + 1;
      else                          hi = mid - 1;
    }
  }
  return -1;
};
```
]
Tested on `[17,23,31,2,5,9,12]`: `5` gives `4`, `31` gives `2`, `100` gives `-1`.
Empty array gives `-1`, `[3]` with target `3` gives `0`. Cross-checked against a scan on
2000 random rotated arrays and every target from `0` to `39`.
#complexity(time: $O(log n)$, space: $O(1)$)

*The unlocking idea:* you cannot compare the target with `a[mid]` directly any more, but
you *can* first identify a sorted half, and inside a sorted half the usual comparison
works again.
#trap[
The left-half test must be `a[lo] <= a[mid]`, with the equals sign. When `lo == mid`
(a two-element range) the values are the same and `<` would send you down the wrong
branch.
]
]

#ex(11, tier: 1, asked: "Cognizant · pattern")[
A matrix where each row is sorted left to right, and the first value of each row is larger
than the last value of the row above. Does `target` appear?
Constraints: $1 <= "rows" times "cols" <= 10^6$. Target $O(log("rows" times "cols"))$.
Edge cases: empty matrix; a $1 times 1$ matrix; target between two rows.
]
#sol[
#approach(1, "Look at every cell", verdict: "O(rows times cols)")
#code(lang: "js", caption: "Brute force")[
```js
const searchMatrixScan = (m, t) => m.some(row => row.includes(t));
```
]
#complexity(time: $O(r c)$, space: $O(1)$)

#approach(2, "Pretend it is one long array", verdict: "O(log(r c)) — optimal")
Those two rules together mean that reading the matrix row by row gives one fully sorted
list. Index `k` of that imaginary list sits at row `k / cols`, column `k % cols`.
#code(lang: "js", caption: "Binary search on the flattened index")[
```js
const searchMatrix = (m, t) => {
  if (m.length === 0 || m[0].length === 0) return false;
  const rows = m.length, cols = m[0].length;
  let lo = 0, hi = rows * cols - 1;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    const v = m[Math.floor(mid / cols)][mid % cols];
    if (v === t) return true;
    if (v < t) lo = mid + 1;
    else       hi = mid - 1;
  }
  return false;
};
```
]
Tested on `[[1,4,7],[10,12,15],[18,21,30]]`: `12` is found by both versions, `13` is not
found by either. An empty matrix returns false. A `1 x 1` matrix holding `5` finds `5`.
#complexity(time: $O(log(r c))$, space: $O(1)$)
#trap[
`Math.floor(mid / cols)` is not optional. `mid / cols` is real division in JavaScript, so
`7 / 3` is `2.3333...` and `m[2.3333]` is `undefined`. The `%` operator does give a whole
number here, so only the row needs flooring.
]

#trap[
*`[...m]` is a SHALLOW copy of a grid.* It copies the list of rows, and every row is still
the same array. Tested in Node on `g = [[1,2],[3,4]]`: after
`const shallow = [...g]; shallow[0][0] = 99;` the original `g[0]` is `[99, 2]`.
A real copy is `const deep = g.map(r => [...r]);` — after the same edit the original stays
`[1, 2]`. This chapter never modifies a grid, but the moment a problem asks you to, this
is the bug you will ship.
]
]

#ex(12, tier: 1, asked: "Accenture · pattern")[
Builds are numbered `1..n`. Every build from some unknown build `B` onward is broken, and
every build before `B` is fine. You have a function `isBad(v)` that costs a full minute to
run. Find `B` with as few calls as possible.
Constraints: $1 <= n <= 2 times 10^9$. Target $O(log n)$ calls.
Edge cases: build 1 already broken; no build broken at all.
]
#sol[
#approach(1, "Try build 1, then 2, then 3 ...", verdict: "one call per build, up to two billion of them")
#code(lang: "js", caption: "Brute force")[
```js
const firstBadScan = (n, isBad) => {
  for (let v = 1; v <= n; v++) if (isBad(v)) return v;
  return -1;
};
```
]
#complexity(time: [$O(n)$ calls], space: $O(1)$)

#approach(2, "Binary search the boundary", verdict: "O(log n) calls — optimal")
The test is monotone by definition: `F F F T T T`. That is Template T2, with a boolean
function instead of an array.

#code(lang: "js", caption: "First failing build")[
```js
const firstBad = (n, isBad) => {
  let lo = 1, hi = n, ans = -1;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (isBad(mid)) { ans = mid; hi = mid - 1; }
    else            { lo = mid + 1; }
  }
  return ans;
};
```
]
Tested with `n = 10`: if builds from `7` onward are bad the answer is `7`; if every build
is bad the answer is `1`; if none is bad the answer is `-1`. The scan agrees on all three.
Counting the actual calls in Node: the scan used 7, 1 and 10; the binary version used
4, 3 and 4.
#complexity(time: [$O(log n)$ calls], space: $O(1)$)
#trick[
Keep a separate `ans` variable whenever the answer may not exist. It is cheaper to reason
about than trying to decode `lo` after the loop.
]
]

#ex(13, tier: 1, asked: "Adobe · pattern")[
Compute $sqrt(n)$ for a real `n`, correct to six decimal places, without using the library
`sqrt`.
Constraints: $0 <= n <= 10^12$. Edge cases: `n = 0`; `n < 1`, where the answer is *larger*
than `n`.
]
#sol[
With real numbers you cannot ask "did we land exactly". Instead run a *fixed* number of
halvings. Each one cuts the error in half, so 100 rounds take any starting range below
$10^(-25)$ — far past what a `double` can even store.

#code(lang: "js", caption: "Real-valued binary search")[
```js
const sqrtReal = (n) => {
  let lo = 0, hi = Math.max(1, n);
  for (let it = 0; it < 100; it++) {
    const mid = (lo + hi) / 2;
    if (mid * mid <= n) lo = mid;
    else                hi = mid;
  }
  return lo;
};
```
]
Tested: `sqrtReal(2)` prints `1.414214`, `sqrtReal(0)` prints `0.000000`,
`sqrtReal(0.25)` prints `0.500000`, `sqrtReal(1e12)` prints `1000000.000000`.
#complexity(time: $O(100)$, space: $O(1)$, note: "100 halvings, independent of n")
#trap[
`hi = n` alone is wrong for `n < 1`, because $sqrt(0.25) = 0.5 > 0.25$ would sit outside
the range. `max(1.0, n)` fixes it.
]
#trick[
For real binary search, never write `while (hi - lo > 1e-9)`. On adversarial inputs that
loop can spin forever. A `for` loop with a fixed count always terminates and is just as
accurate.
]
]

#ex(14, tier: 1, asked: "Cognizant · pattern")[
An unsorted price list and `q` query prices. For each query, how many items cost strictly
less than it?
Constraints: $0 <= n <= 10^5$, $1 <= q <= 10^5$. Target $O((n + q) log n)$.
Edge cases: an empty price list; a query below every price.
]
#sol[
#approach(1, "Scan the list for every query", verdict: "O(n q), ten billion steps at the limits")
#code(lang: "js", caption: "Brute force")[
```js
const countSmallerBrute = (a, q) => q.map(x => a.filter(v => v < x).length);
```
]
#complexity(time: $O(n q)$, space: $O(1)$)

#approach(2, "Sort once, then binary-search each query", verdict: "O((n + q) log n) — optimal")
After sorting, "how many are strictly less than `x`" is exactly `lowerBound(a, x)` — the
index *is* the count, because everything before it is smaller.
#code(lang: "js", caption: "Sort once, answer many")[
```js
const countSmaller = (a, q) => {
  const sorted = [...a].sort((x, y) => x - y);   // NEVER a bare .sort()
  return q.map(x => lowerBound(sorted, x));
};
```
]
Tested on prices `[8,1,5,5,3]` with queries `[0,5,6,100]`: both versions give
`0 2 4 5`. An empty price list gives `0` for any query.
#complexity(time: $O((n + q) log n)$, space: $O(1)$, note: "the sort is paid once, not per query")

*The unlocking idea:* pay $O(n log n)$ once so that every later question costs
$O(log n)$. Whenever a problem says "many queries", look for a one-time preparation step.
#trick[
`lowerBound` returns a *count* as well as a position. That double meaning is the reason it
shows up in so many solutions.
]
]

#ex(15, tier: 1, asked: "TCS Digital · pattern")[
A sorted array. Is there a value that appears *more than* $n \/ 2$ times? Return it, or
report that there is none.
Constraints: $0 <= n <= 10^5$. Target $O(log n)$.
Edge cases: empty array; exactly half (that is *not* a majority); $n = 1$.
]
#sol[
#approach(1, "Count the runs", verdict: "O(n)")
#code(lang: "js", caption: "Brute force")[
```js
const majorityScan = (a) => {
  const n = a.length;
  if (n === 0) return null;
  let best = a[0], run = 1, bestRun = 1;
  for (let i = 1; i < n; i++) {
    if (a[i] === a[i - 1]) run++;
    else run = 1;
    if (run > bestRun) { bestRun = run; best = a[i]; }
  }
  return bestRun * 2 > n ? best : null;
};
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#approach(2, "Only one candidate is possible", verdict: "O(log n) — optimal")
A block longer than half the array must cover the middle slot. So `a[n/2]` is the *only*
value that can win. Find where its block starts, then check that the block is long enough.
#code(lang: "js", caption: "One candidate, one bound check")[
```js
const majoritySorted = (a) => {
  const n = a.length;
  if (n === 0) return null;
  const half = n >> 1;
  const cand = a[half];                   // the only value that can win
  const first = lowerBound(a, cand);
  if (first + half < n && a[first + half] === cand) return cand;
  return null;
};
```
]
Tested: `[1,2,2,2,5]` gives `2` from both versions; `[1,2,3,4]` reports none from both;
`[7]` gives `7`; an empty array reports none; `[1,1,2,2]` reports none, because exactly
half is not more than half. Cross-checked against the scan on 3000 random sorted arrays.
#complexity(time: $O(log n)$, space: $O(1)$)

*The unlocking idea:* narrow the answer down to a single candidate first. Verifying one
candidate is almost always cheaper than searching for the answer.
#trap[
The length check is `first + n/2 < n && a[first + n/2] == cand`. Writing
`a[first + n/2] == cand` alone reads past the end when the block sits at the tail.
]
]

#pagebreak(weak: true)
#section[Tier 2 — binary search on the answer]
#tier-header(2)

Everything in this section shares one shape. You are asked for the smallest (or largest)
value of some quantity that makes a plan *work*. You cannot compute it directly, but you
*can* check a guess. And checking is monotone: if capacity 10 works, so does 11.

#formulas(title: "The recipe, every time")[
+ Name the answer. Call it `x`.
+ Write `feasible(x)` — a plain loop that returns true or false. This is where all the
  real thinking happens.
+ Convince yourself `feasible` is monotone: `F F F T T T`, never back to `F`.
+ Pick the smallest and largest `x` that could possibly be the answer.
+ Run Template T3.
]

#ex(16, tier: 2, asked: "Grab · pattern")[
Parcels sit on a belt in a fixed order and must be loaded in that order. Each day one
truck leaves, carrying a run of parcels whose total weight is at most the truck's
capacity. What is the smallest capacity that clears everything within `days` days?
Constraints: $0 <= n <= 10^5$, $1 <= w_i <= 500$, $1 <= "days" <= n$. Target
$O(n log(sum w))$. Edge cases: `days = 1`; `days = n`; an empty belt.
]
#sol[
*Step 1 — the check.* Greedily load the current truck until the next parcel does not fit,
then start a new day.

#code(lang: "js", caption: "feasible: does this capacity finish in time?")[
```js
const canFinishIn = (w, cap, days) => {
  let used = 1, cur = 0;
  for (const x of w) {
    if (x > cap) return false;
    if (cur + x > cap) { used++; cur = x; }
    else               { cur += x; }
  }
  return used <= days;
};
```
]

*Step 2 — the range.* The capacity is at least the heaviest single parcel (otherwise it
never ships) and at most the total weight (one day for everything).

#approach(1, "Try every capacity from low to high", verdict: "O(n times the total weight)")
#code(lang: "js", caption: "Brute force — useful as a test oracle")[
```js
const minCapacityBrute = (w, days) => {
  const hi = w.reduce((s, x) => s + x, 0);
  for (let cap = 0; cap <= hi; cap++)
    if (canFinishIn(w, cap, days)) return cap;
  return hi;
};
```
]
#complexity(time: $O(n sum w)$, space: $O(1)$)

#approach(2, "Binary search the capacity", verdict: "O(n log(sum w)) — optimal")
#code(lang: "js", caption: "Template T3")[
```js
const minCapacity = (w, days) => {
  let lo = 0, hi = 0;
  for (const x of w) { lo = Math.max(lo, x); hi += x; }
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (canFinishIn(w, mid, days)) hi = mid;
    else                           lo = mid + 1;
  }
  return lo;
};
```
]
Tested on `[5,2,8,4,1]`: `days = 3` gives `8`, `days = 1` gives `20`, `days = 5` gives `8`.
The brute force agrees on all three. An empty belt gives `0`; a single parcel of weight
`7` in one day gives `7`. Cross-checked against the brute force on 500 random belts for
every value of `days`.
#complexity(time: $O(n log(sum w))$, space: $O(1)$)

#code(lang: "python", caption: "Python version, using a reusable first-true helper")[
```python
def first_true(lo, hi, pred):
    ans = hi + 1
    while lo <= hi:
        mid = lo + (hi - lo) // 2
        if pred(mid):
            ans = mid
            hi = mid - 1
        else:
            lo = mid + 1
    return ans

def min_capacity(w, days):
    def can(cap):
        used, cur = 1, 0
        for x in w:
            if x > cap:
                return False
            if cur + x > cap:
                used += 1
                cur = x
            else:
                cur += x
        return used <= days
    if not w:
        return 0
    return first_true(max(w), sum(w), can)
```
]
Python prints `8 20 0` for the same three cases.

#trap[
`lo` must start at the *maximum* weight, not at `0` or `1`. Starting lower is not wrong
here only because `canFinishIn` rejects `x > cap` explicitly — remove that line and the
whole thing breaks silently.
]
]

#ex(17, tier: 2, asked: "Shopee · pattern")[
A courier has `n` routes; route `i` is `job[i]` kilometres long. In one hour the courier
covers `rate` kilometres, but never starts a second route inside the same hour: a route of
11 km at rate 4 costs 3 hours, not 2.75. Find the smallest whole `rate` that finishes
every route within `hours` hours.
Constraints: $1 <= n <= 10^4$, $1 <= "job"_i <= 10^9$, $n <= "hours" <= 10^9$.
Target $O(n log(max "job"))$. Edge cases: `hours = n` (one hour per route);
huge `hours`.
]
#sol[
*The check.* Hours for one route are $ceil("job"_i \/ "rate")$. JavaScript divides for
real, so `Math.ceil(x / rate)` says exactly what it means.

#code(lang: "js", caption: "feasible: is this rate fast enough?")[
```js
const rateWorks = (job, rate, hours) => {
  let t = 0;
  for (const x of job) {
    t += Math.ceil(x / rate);            // ceiling division
    if (t > hours) return false;
  }
  return true;
};
```
]

#approach(1, "Try every rate", verdict: "O(n times max job), far too slow")
#approach(2, "Binary search the rate", verdict: "O(n log(max job)) — optimal")
The slowest useful rate is `1`; the fastest useful rate is the longest route, because
beyond that nothing improves.
#code(lang: "js", caption: "Template T3 again")[
```js
const minRate = (job, hours) => {
  let lo = 1, hi = 1;
  for (const x of job) hi = Math.max(hi, x);
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (rateWorks(job, mid, hours)) hi = mid;
    else                            lo = mid + 1;
  }
  return lo;
};
```
]
Tested on `[6,11,4,9]`: `hours = 6` gives `6`, `hours = 4` gives `11`, `hours = 100` gives
`1`. A single route of `1000000000` km in `1` hour gives `1000000000`. A brute-force scan
agrees on all of these, and on 500 random inputs for every value of `hours` from `n` to
`3n`.
#complexity(time: $O(n log(max "job"))$, space: $O(1)$)
#trap[
`Math.ceil(x / rate)` is exact while `x` stays under `Number.MAX_SAFE_INTEGER`, which the
constraint $"job"_i <= 10^9$ guarantees. Past that line the division itself is already
rounded and the ceiling is off by one — switch the whole check to `BigInt` and write
`(x + rate - 1n) / rate`, because `BigInt` has no `Math.ceil`.
]
]

#ex(18, tier: 2, asked: "Sea · pattern")[
Split an array into exactly `m` non-empty contiguous blocks so that the largest block sum
is as small as possible. Return that smallest possible largest sum.
Constraints: $1 <= m <= n <= 10^4$, $0 <= a_i <= 10^6$. Target $O(n log(sum a))$.
Edge cases: `m = 1`; `m = n`.
]
#sol[
Read the check for Example 16 again. "Fit the parcels into at most `days` trucks without
any truck going over `cap`" is *word for word* the same as "cut the array into at most `m`
blocks with no block over `cap`". Same function, new name.

#code(lang: "js", caption: "The same solver, renamed")[
```js
const minLargestBlock = (a, m) => minCapacity(a, m);   // exactly the same feasibility test
```
]
Tested on `[7,2,5,10,8]`: `m = 2` gives `18` (blocks `7 2 5` and `10 8`), `m = 3` gives
`14` (blocks `7 2 5`, `10`, `8`), and `[1,1,1,1]` with `m = 4` gives `1`.
#complexity(time: $O(n log(sum a))$, space: $O(1)$)
#trick[
This is the highest-value fact in the whole chapter. "Minimum largest page count",
"minimum truck capacity", "fewest painters", "minimum time for machines in a row" are the
*same problem* with different nouns. Recognise the check, not the story.
]
#note[
"At most `m` blocks" and "exactly `m` blocks" give the same answer whenever the array has
at least `m` elements: if you used fewer blocks, split any block and the largest sum
cannot grow.
]
]

#ex(19, tier: 2, asked: "SCB · pattern")[
`n` shop positions on a straight road. Install `k` wireless routers in `k` of those
positions so that the *smallest* distance between any two routers is as large as possible.
Return that distance.
Constraints: $2 <= k <= n <= 10^5$, positions up to $10^9$ and given unsorted.
Target $O(n log n + n log("range"))$. Edge cases: all positions equal; `k > n`.
]
#sol[
This is a *maximise the minimum* problem, so the feasibility test flips: large gaps are
hard, small gaps are easy, and the pattern is `T T T F F F`. You want the *last* `T`.

#code(lang: "js", caption: "feasible: can k routers all sit at least gap apart?")[
```js
const canPlace = (pos, k, gap) => {
  let cnt = 1, last = pos[0];
  for (let i = 1; i < pos.length; i++) {
    if (pos[i] - last >= gap) { cnt++; last = pos[i]; }
  }
  return cnt >= k;
};
```
]

#approach(1, "Try every gap from 0 upwards and keep the last that works", verdict: "O(n times the range of gaps)")
#code(lang: "js", caption: "Brute force / test oracle")[
```js
const maxMinGapBrute = (pos, k) => {
  const p = [...pos].sort((a, b) => a - b);
  if (p.length < k) return -1;
  let best = 0;
  for (let g = 0; g <= p[p.length - 1] - p[0]; g++)
    if (canPlace(p, k, g)) best = g;
  return best;
};
```
]
#complexity(time: $O(n times "range")$, space: $O(1)$)

#approach(2, "Binary search the gap", verdict: "O(n log(range)) — optimal")
#code(lang: "js", caption: "Last-true search: keep the answer, push lo up")[
```js
const maxMinGap = (pos, k) => {
  const p = [...pos].sort((a, b) => a - b);   // numeric comparator, always
  if (p.length < k) return -1;
  let lo = 0, hi = p[p.length - 1] - p[0], ans = 0;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (canPlace(p, k, mid)) { ans = mid; lo = mid + 1; }
    else                     { hi = mid - 1; }
  }
  return ans;
};
```
]
Tested on `[1,2,8,4,9]`: `k = 3` gives `3` (routers at 1, 4, 8) and `k = 2` gives `8`.
`[5,5,5]` with `k = 2` gives `0`. `[1,2]` with `k = 5` returns `-1`. Cross-checked against
a linear scan of every possible gap on 500 random inputs.
#complexity(time: $O(n log n + n log("range"))$, space: $O(1)$)
#trap[
Greedy placement must always take the *first* position, and then the earliest position
that is far enough. Taking anything later only wastes road and can turn a feasible gap
into an infeasible one.
]
]

#ex(20, tier: 2, asked: "Agoda · pattern")[
`n` machines stand in a row. Machine `i` is repaired on day `day[i]` and stays working
afterwards. You need `m` separate groups of `k` *adjacent* working machines, and no
machine may belong to two groups. What is the earliest day this is possible? Return `-1`
if it never is.
Constraints: $1 <= n <= 10^5$, $1 <= "day"_i <= 10^9$. Target $O(n log n)$.
Edge cases: $m times k > n$; every machine repaired on the same day.
]
#sol[
*The check.* On a given day, walk the row and count runs of working machines, cutting off
a group every time the run reaches `k`.

#code(lang: "js", caption: "feasible: enough groups by today?")[
```js
const enoughGroups = (day, m, k, today) => {
  let run = 0, groups = 0;
  for (const d of day) {
    if (d <= today) {
      run++;
      if (run === k) { groups++; run = 0; }
    } else {
      run = 0;
    }
  }
  return groups >= m;
};
```
]
Monotone, because a machine repaired by day `t` is also repaired by day `t + 1`. The day
never needs to be a number outside the list, so search between the smallest and the
largest repair day.

#approach(1, "Walk the days upward", verdict: "O(n times the range of days), far too slow")
#code(lang: "js", caption: "Brute force / test oracle")[
```js
const earliestDayBrute = (day, m, k) => {
  if (m * k > day.length) return -1;
  const hi = Math.max(...day);
  for (let d = Math.min(...day); d <= hi; d++)
    if (enoughGroups(day, m, k, d)) return d;
  return -1;
};
```
]
#complexity(time: $O(n times "range of days")$, space: $O(1)$)

#approach(2, "Binary search the day", verdict: "O(n log n) — optimal")
#code(lang: "js", caption: "Earliest feasible day")[
```js
const earliestDay = (day, m, k) => {
  if (m * k > day.length) return -1;
  let lo = Math.min(...day), hi = Math.max(...day);
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (enoughGroups(day, m, k, mid)) hi = mid;
    else                              lo = mid + 1;
  }
  return lo;
};
```
]
Tested on `[1,5,2,8,3,9]`: `m = 2, k = 2` gives day `8`, and a linear scan agrees.
`m = 3, k = 2` gives `9`. `[4,4,4]` with `m = 1, k = 3` gives `4`. The impossible case
$m times k > n$ returns `-1`.
#complexity(time: $O(n log n)$, space: $O(1)$)
#trap[
`m * k` with both near $10^5$ gives $10^10$. In a 32-bit language that wraps and the
impossible case sails past the guard; in JavaScript it is fine, because numbers stay exact
to $9 times 10^15$ — tested: `100000 * 100000` prints `10000000000` exactly. Say this out
loud in an interview. It is one of the few places where JavaScript needs *less* care than
C++ or Java, and knowing *why* is what earns the mark.
]

#trap[
`Math.min(...day)` spreads the whole array into function arguments. Past roughly $10^5$
values that throws `RangeError: Maximum call stack size exceeded`. At this problem's limit
of $n <= 10^5$ you are on the edge — write the loop instead:
`let lo = day[0]; for (const d of day) if (d < lo) lo = d;`
]
]

#ex(21, tier: 2, asked: "GIC · pattern")[
Pick the smallest whole number `d` such that
$sum_i ceil(a_i \/ d) <= "limit"$.
Constraints: $1 <= n <= 10^4$, $1 <= a_i <= 10^6$, $n <= "limit" <= 10^6$.
Target $O(n log(max a))$. Edge cases: `limit = n` (every term must be 1);
`limit` very large.
]
#sol[
Raising `d` can only lower each ceiling, so the test is monotone.

#approach(1, "Try every divisor", verdict: "O(n times max a), ten billion steps")
#code(lang: "js", caption: "Brute force / test oracle")[
```js
const smallestDivisorBrute = (a, limit) => {
  const hi = Math.max(1, ...a);
  for (let d = 1; d <= hi; d++) if (divisorWorks(a, d, limit)) return d;
  return hi;
};
```
]
#complexity(time: $O(n max a)$, space: $O(1)$)

#approach(2, "Binary search the divisor", verdict: "O(n log(max a)) — optimal")
#code(lang: "js", caption: "feasible and the search")[
```js
const divisorWorks = (a, d, limit) => {
  let s = 0;
  for (const x of a) {
    s += Math.ceil(x / d);
    if (s > limit) return false;
  }
  return true;
};
const smallestDivisor = (a, limit) => {
  let lo = 1, hi = 1;
  for (const x of a) hi = Math.max(hi, x);
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (divisorWorks(a, mid, limit)) hi = mid;
    else                             lo = mid + 1;
  }
  return lo;
};
```
]
Tested on `[2,7,11,15]`: `limit = 9` gives `5` — the ceilings are $1 + 2 + 3 + 3 = 9$,
and `d = 4` gives $1 + 2 + 3 + 4 = 10$, one too many. `limit = 4` gives `15`.
`[5]` with `limit = 1` gives `5`. `[1,1,1]` with `limit = 3` gives `1`. The brute force
returns the same four answers.
#complexity(time: $O(n log(max a))$, space: $O(1)$)
]

#ex(22, tier: 2, asked: "Razer · pattern")[
A sorted array and a value `x`. Return the `k` values closest to `x`, in increasing order.
Ties go to the smaller value.
Constraints: $1 <= k <= n <= 10^5$. Target $O(log n + k)$ or better.
Edge cases: `x` outside the array on either side; `k = n`.
]
#sol[
#approach(1, "Find the insertion point, then walk outwards", verdict: "O(log n + k)")
#code(lang: "js", caption: "Two pointers spreading from the insert position")[
```js
const kClosestExpand = (a, k, x) => {
  const i = lowerBound(a, x);
  let lo = i - 1, hi = i, left = k;
  while (left > 0) {
    if (lo < 0)                      { hi++; }
    else if (hi >= a.length)         { lo--; }
    else if (x - a[lo] <= a[hi] - x) { lo--; }
    else                             { hi++; }
    left--;
  }
  return a.slice(lo + 1, hi);
};
```
]
#complexity(time: $O(log n + k)$, space: $O(1)$)

#approach(2, "Binary search the window's left edge", verdict: "O(log n) to decide, O(k) to copy")
The answer is always a *contiguous* block of `k` values. So search for its starting index
directly. Compare the value just outside on the left with the value just outside on the
right.
#code(lang: "js", caption: "Binary search over start positions")[
```js
const kClosestBS = (a, k, x) => {
  let lo = 0, hi = a.length - k;
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (x - a[mid] > a[mid + k] - x) lo = mid + 1;
    else                             hi = mid;
  }
  return a.slice(lo, lo + k);
};
```
]
Tested on `[1,3,6,10,11,15]`: `k = 3, x = 9` gives `6 10 11` from both versions.
`k = 6, x = 100` gives the whole array. `k = 1, x = 0` gives `1`.
#complexity(time: $O(log n + k)$, space: $O(1)$)

*The unlocking idea:* prove the answer is one contiguous block, and a "choose k items"
problem collapses into "choose one starting index".
]

#pagebreak(weak: true)
#section[Tier 3 — the ones with a follow-up]
#tier-header(3)

#ex(23, tier: 3, asked: "Google · pattern")[
Two sorted arrays of sizes `n` and `m`. Return the median of the combined list, without
building it.
Constraints: $0 <= n, m <= 10^5$, not both empty, $|a_i| <= 2 times 10^9$. Target
$O(log(min(n, m)))$. Edge cases: one array empty; all of one array below all of the other;
an even total length.
]
#sol[
#approach(1, "Merge and read the middle", verdict: "O(n + m) — good enough to be a test oracle")
#code(lang: "js", caption: "Brute force")[
```js
const medianBrute = (A, B) => {
  const all = [...A, ...B].sort((p, q) => p - q);   // numeric comparator, always
  const n = all.length;
  if (n === 0) return 0;
  if (n % 2 === 1) return all[(n - 1) / 2];
  return (all[n / 2 - 1] + all[n / 2]) / 2;
};
```
]
#complexity(time: $O((n+m) log(n+m))$, space: $O(n+m)$)

#approach(2, "Binary search the split point", verdict: "O(log(min(n, m))) — optimal")

#formulas(title: "What we are actually searching for")[
Cut `A` after `i` values and `B` after `j` values, with $i + j = ceil((n+m) \/ 2)$. The cut
is *correct* when everything on the left is $<=$ everything on the right, which needs only
two comparisons:

#align(center)[`A[i-1] <= B[j]` #h(14pt) and #h(14pt) `B[j-1] <= A[i]`]

If `A[i-1] > B[j]`, we took too much from `A`, so shrink `i`. That is monotone, so binary
search on `i` works. Because `j` is forced by `i`, there is only one thing to search.
]

Missing neighbours are replaced by $-oo$ and $+oo$ so the two comparisons never need a
special case. JavaScript spells those `-Infinity` and `Infinity`, and they compare
correctly against every real number — much cleaner than borrowing the smallest and largest
values of a fixed-width integer type.

#code(lang: "js", caption: "Median of two sorted arrays")[
```js
const medianTwo = (A, B) => {
  if (A.length > B.length) return medianTwo(B, A);
  const n = A.length, m = B.length, total = n + m;
  if (total === 0) return 0;
  const half = Math.floor((total + 1) / 2);
  let lo = 0, hi = n;
  while (lo <= hi) {
    const i = Math.floor(lo + (hi - lo) / 2);
    const j = half - i;
    const aLeft  = i > 0 ? A[i - 1] : -Infinity;
    const aRight = i < n ? A[i]     :  Infinity;
    const bLeft  = j > 0 ? B[j - 1] : -Infinity;
    const bRight = j < m ? B[j]     :  Infinity;
    if (aLeft <= bRight && bLeft <= aRight) {
      if (total % 2 === 1) return Math.max(aLeft, bLeft);
      return (Math.max(aLeft, bLeft) + Math.min(aRight, bRight)) / 2;
    }
    if (aLeft > bRight) hi = i - 1;
    else                lo = i + 1;
  }
  return 0;
};
```
]
Tested: `([1,3,8], [7,9,10,11])` gives `8.0` and the merge agrees.
`([], [2,4])` gives `3.0`. `([5], [5])` gives `5.0`.
`([-2000000000], [2000000000])` gives `0`, and `([1,2], [3,4])` gives `2.5`.
Cross-checked against the merge on 500 random pairs of arrays.
#complexity(time: $O(log(min(n, m)))$, space: $O(1)$)

#code(lang: "python", caption: "Python version")[
```python
def median_two(A, B):
    if len(A) > len(B):
        A, B = B, A
    n, m = len(A), len(B)
    total = n + m
    if total == 0:
        return 0.0
    half = (total + 1) // 2
    lo, hi = 0, n
    while lo <= hi:
        i = lo + (hi - lo) // 2
        j = half - i
        al = A[i - 1] if i > 0 else float("-inf")
        ar = A[i] if i < n else float("inf")
        bl = B[j - 1] if j > 0 else float("-inf")
        br = B[j] if j < m else float("inf")
        if al <= br and bl <= ar:
            if total % 2 == 1:
                return float(max(al, bl))
            return (max(al, bl) + min(ar, br)) / 2.0
        if al > br:
            hi = i - 1
        else:
            lo = i + 1
    return 0.0
```
]
Python prints `8.0 3.0 5.0` on the same three cases.

*Follow-up the interviewer asks next:* "now give me the k-th smallest, not the median."
Same code, with `half` replaced by `k` and the even-length branch deleted. Searching `i`
from `max(0, k - m)` to `min(k, n)` keeps `j` inside `B`.
#trap[
`hi` starts at `n`, not `n - 1`. The cut `i = n` (take all of `A`) is a legal answer, and
a range that cannot express it fails on `([1,2], [3,4])`.
]
]

#ex(24, tier: 3, asked: "Amazon · pattern")[
Search a rotated sorted array that *may contain duplicates*. Return only whether the
target is present.
Constraints: $0 <= n <= 10^5$. Target: $O(log n)$ on average.
Edge cases: every value identical; target absent; empty array.
]
#sol[
Example 10 decided which half was sorted by comparing `a[lo]` with `a[mid]`. With
duplicates that test can be blind: in `[4,4,4,1,2,4,4]` we have
`a[lo] == a[mid] == a[hi] == 4` and the sorted half is genuinely unknowable from those
three values.

The honest fix is to admit defeat for one step and shrink the range by one on each side.

#code(lang: "js", caption: "Rotated search with duplicates")[
```js
const searchRotatedDup = (a, t) => {
  let lo = 0, hi = a.length - 1;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] === t) return true;
    if (a[lo] === a[mid] && a[mid] === a[hi]) { lo++; hi--; }
    else if (a[lo] <= a[mid]) {
      if (a[lo] <= t && t < a[mid]) hi = mid - 1;
      else                          lo = mid + 1;
    } else {
      if (a[mid] < t && t <= a[hi]) lo = mid + 1;
      else                          hi = mid - 1;
    }
  }
  return false;
};
```
]
Tested on `[4,4,4,1,2,4,4]`: `2` is found, `4` is found, `3` is not. An empty array returns
false; `[2,2,2]` finds `2`.
#complexity(time: [$O(log n)$ average], space: $O(1)$, note: "O(n) in the worst case")

*Follow-up the interviewer asks next:* "what is the worst case, and can you beat it?"
Answer honestly: on an array like `[2,2,2,2,2,2,1,2]` every step hits the blind branch and
you degrade to $O(n)$. No comparison-based method can do better, because an adversary can
keep `n - 1` copies of one value and hide the odd one anywhere; distinguishing all `n`
placements needs `n` probes in the worst case. That "prove the lower bound" answer is what
separates a Tier 3 candidate from a Tier 1 one.
]

#ex(25, tier: 3, asked: "Microsoft · pattern")[
An $n times n$ grid where every *row* is sorted left to right and every *column* is sorted
top to bottom. Find the k-th smallest value overall.
Constraints: $1 <= n <= 300$, $1 <= k <= n^2$. Target $O(n log("range"))$.
Edge cases: `k = 1`; $k = n^2$; many repeated values.
]
#sol[
This grid is *not* one sorted list — row 2 can start below the end of row 1 — so the
flattening trick from Example 11 is illegal here.

#approach(1, "Copy everything out and sort", verdict: "O(n^2 log n) time and O(n^2) space")
#code(lang: "js", caption: "Brute force / test oracle")[
```js
const kthSmallestBrute = (g, k) => g.flat().sort((a, b) => a - b)[k - 1];
```
]
#complexity(time: $O(n^2 log n)$, space: $O(n^2)$)

#approach(2, "Binary search on the VALUE, not on a position", verdict: "O(n log(range)) — optimal")
Guess a value `x` and count how many grid entries are $<= x$. That count only grows as `x`
grows, so it is monotone. Counting is a staircase walk: start at the top-right, step left
while the value is too big, and step down a row.

#code(lang: "js", caption: "Count, then search the value range")[
```js
const countNotAbove = (g, x) => {
  const n = g.length;
  let col = n - 1, cnt = 0;
  for (let row = 0; row < n; row++) {
    while (col >= 0 && g[row][col] > x) col--;
    cnt += col + 1;
  }
  return cnt;
};
const kthSmallestMatrix = (g, k) => {
  const n = g.length;
  let lo = g[0][0], hi = g[n - 1][n - 1];
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (countNotAbove(g, mid) >= k) hi = mid;
    else                            lo = mid + 1;
  }
  return lo;
};
```
]
Tested on `[[1,4,9],[2,6,12],[5,8,14]]`, the answers for `k = 1..9` are
`1 2 4 5 6 8 9 12 14`, and the brute force gives the identical list.
#complexity(time: $O(n log("range"))$, space: $O(1)$)

#note[
Why is `col` never reset between rows? Because rows go down as well as across: whatever
was too big in row `r` is still too big in row `r+1` at the same column. So `col` only ever
moves left, and the whole count costs $O(n)$, not $O(n^2)$.
]

#trick[
The returned `lo` is always a value that really appears in the grid. Reason: the smallest
`x` whose count reaches `k` must itself be a grid entry — if it were not, `x - 1` would
have the same count and `x` would not be smallest.
]

*Follow-up the interviewer asks next:* "compare this with a heap solution." A min-heap
seeded with the first column and popped `k` times costs $O(k log n)$. That is better when
`k` is tiny and worse when `k` is near $n^2$. Binary search wins on memory: $O(1)$ against
$O(n)$.
]

#ex(26, tier: 3, asked: "Uber · pattern")[
A grid of distinct numbers. Find *any* peak: a cell strictly greater than its up, down,
left and right neighbours. Cells off the edge count as $-oo$.
Constraints: $1 <= "rows", "cols" <= 500$. Target $O("rows" times log "cols")$.
Edge cases: a single row; a single column.
]
#sol[
Take the middle column. Find its largest entry, at row `best`. Three cases:

+ Both horizontal neighbours are smaller. Then that cell is a peak — it already beat its
  vertical neighbours by being the column maximum.
+ The left neighbour is bigger. Then the left half must contain a peak, because the
  largest value in the left half is at least that neighbour and cannot escape leftwards
  forever.
+ Same argument on the right.

#code(lang: "js", caption: "Binary search over columns")[
```js
const peakGrid = (g) => {
  const rows = g.length, cols = g[0].length;
  let lo = 0, hi = cols - 1;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    let best = 0;
    for (let r = 0; r < rows; r++) if (g[r][mid] > g[best][mid]) best = r;
    const leftBigger  = mid - 1 >= 0   && g[best][mid - 1] > g[best][mid];
    const rightBigger = mid + 1 < cols && g[best][mid + 1] > g[best][mid];
    if (!leftBigger && !rightBigger) return [best, mid];
    if (leftBigger) hi = mid - 1;
    else            lo = mid + 1;
  }
  return [-1, -1];
};
```
]
Tested on `[[3,9,4],[7,2,6],[1,8,5]]`: returns `(0, 1)`, whose value `9` beats its left
`3`, its right `4` and the cell below, `2`.
#complexity(time: $O("rows" times log "cols")$, space: $O(1)$)

*Follow-up the interviewer asks next:* "why is that $O(r log c)$ and not $O(r c)$?"
Each round scans one column ($r$ steps) and then throws away half the columns. Number of
rounds: $log_2 c$. Total: $r log_2 c$. For a $500 times 500$ grid that is about 4500 cell
reads instead of 250000.
]

#ex(27, tier: 3, asked: "Goldman Sachs · pattern")[
A sorted array where every value appears exactly twice, except one value that appears
once. Find the lonely value.
Constraints: $n$ is odd, $1 <= n <= 10^5$. Target $O(log n)$ time, $O(1)$ space.
Edge cases: the lonely value is first; it is last; $n = 1$.
]
#sol[
Before the lonely value, every pair starts at an *even* index: `(0,1), (2,3), (4,5)`.
After it, every pair starts at an *odd* index. That flip is monotone — it happens once.

#code(lang: "js", caption: "Binary search on index parity")[
```js
const singleValue = (a) => {
  let lo = 0, hi = a.length - 1;
  while (lo < hi) {
    let mid = Math.floor(lo + (hi - lo) / 2);
    if (mid % 2 === 1) mid--;          // always look at the START of a pair
    if (a[mid] === a[mid + 1]) lo = mid + 2;
    else                       hi = mid;
  }
  return a[lo];
};
```
]
Tested: `[1,1,3,5,5,7,7]` gives `3`, `[2,3,3]` gives `2`, `[9]` gives `9`, `[1,1,2]` gives
`2`.
#complexity(time: $O(log n)$, space: $O(1)$)

#note[
The line `if (mid % 2 == 1) mid--;` is the whole trick. It snaps `mid` onto the first
member of a pair, so `a[mid] == a[mid+1]` is a clean "the pairs are still aligned" test.
Without it the comparison means nothing.
]

*Follow-up the interviewer asks next:* "what if every value appears three times except
one?" Parity becomes "index modulo 3", and the check compares `a[mid]`, `a[mid+1]` and
`a[mid+2]` after snapping `mid` down to a multiple of 3. The shape of the argument is
identical, which is the point of the question.
]

#ex(28, tier: 3, asked: "D. E. Shaw · pattern")[
Charging points sit at increasing positions along a highway. You may add `k` more points
anywhere. Minimise the largest distance between two neighbouring points. Answer to within
$10^(-6)$.
Constraints: $2 <= n <= 10^4$, $0 <= k <= 10^5$, positions up to $10^9$.
Edge cases: `k = 0`; all gaps already equal.
]
#sol[
Binary search on a *real* answer `width`. The check: with a maximum spacing of `width`, a
gap of length `g` needs $ceil(g \/ "width") - 1$ extra points inside it.

#code(lang: "js", caption: "Real-valued binary search on the answer")[
```js
const stationsNeeded = (pos, width) => {
  let need = 0;
  for (let i = 1; i < pos.length; i++) {
    const gap = pos[i] - pos[i - 1];
    need += Math.ceil(gap / width) - 1;
  }
  return need;
};
const minLargestGap = (pos, k) => {
  let lo = 0, hi = 0;
  for (let i = 1; i < pos.length; i++) hi = Math.max(hi, pos[i] - pos[i - 1]);
  for (let it = 0; it < 100; it++) {
    const mid = (lo + hi) / 2;
    if (mid <= 0) break;
    if (stationsNeeded(pos, mid) <= k) hi = mid;
    else                               lo = mid;
  }
  return hi;
};
```
]
Tested: `([0,10], 1)` gives `5.00000`, `([0,10], 4)` gives `2.00000`,
`([1,2,3,4], 0)` gives `1.00000`.
#complexity(time: $O(100 n)$, space: $O(1)$)

*Follow-up the interviewer asks next:* "the judge wants an exact answer, not a float."
Two options. Scale everything by $10^6$ and binary-search on integers, which removes all
floating-point doubt. Or use a max-heap that repeatedly splits the currently largest gap,
$k$ times — $O((n + k) log n)$, exact, and a nice contrast to draw in the interview.
#trap[
`hi` must start at the largest *gap*, not at the length of the whole highway. Starting too
high still works but wastes iterations; starting too low returns a wrong answer, which is
much worse.
]
]

#pagebreak(weak: true)
#section[Dry run — every single step]

*Problem.* `a = [31, 40, 55, 3, 8, 12, 19, 24]` — a sorted array of distinct values,
rotated. Search for `20`, which is *not* there. Watching a failed search is more useful
than watching a lucky hit, because it shows how the range actually collapses.

#code(lang: "js", caption: "The code we are tracing")[
```js
let lo = 0, hi = a.length - 1;
while (lo <= hi) {
  const mid = Math.floor(lo + (hi - lo) / 2);
  if (a[mid] === t) return mid;
  if (a[lo] <= a[mid]) {                        // left half is sorted
    if (a[lo] <= t && t < a[mid]) hi = mid - 1;
    else                          lo = mid + 1;
  } else {                                      // right half is sorted
    if (a[mid] < t && t <= a[hi]) lo = mid + 1;
    else                          hi = mid - 1;
  }
}
return -1;
```
]

Index:#h(6pt)`0:31`#h(6pt)`1:40`#h(6pt)`2:55`#h(6pt)`3:3`#h(6pt)`4:8`#h(6pt)`5:12`#h(6pt)`6:19`#h(6pt)`7:24`

#table(
  columns: (auto, auto, auto, auto, 1.5fr, auto),
  [*step*], [*lo*], [*hi*], [*mid*], [*decision*], [*new range*],
  [1], [0], [7], [3],
  [`a[3] = 3`. Is `a[lo] <= a[mid]`? `31 <= 3` is false, so the *right* half `[3..7]` is
   sorted, holding `3 .. 24`. Is `3 < 20 <= 24`? Yes — the target can only be there.],
  [`lo = 4`],
  [2], [4], [7], [5],
  [`a[5] = 12`. Is `8 <= 12`? Yes, so the *left* half `[4..5]` is sorted, holding `8 .. 12`.
   Is `8 <= 20 < 12`? No. So go right.],
  [`lo = 6`],
  [3], [6], [7], [6],
  [`a[6] = 19`. Left half `[6..6]` is sorted, holding just `19`. Is `19 <= 20 < 19`? No.
   Go right.],
  [`lo = 7`],
  [4], [7], [7], [7],
  [`a[7] = 24`. Left half `[7..7]` holds just `24`. Is `24 <= 20 < 24`? No. Go right.],
  [`lo = 8`],
  [—], [8], [7], [—], [`lo > hi`, the loop ends.], [return `-1`],
)

*Answer: `-1`.* Four probes on an array of eight, which matches $log_2 8 = 3$ plus the
final empty check.

#subsection[The same array, a target that exists]

Searching for `55`:

#table(
  columns: (auto, auto, auto, auto, 1.5fr, auto),
  [*step*], [*lo*], [*hi*], [*mid*], [*decision*], [*new range*],
  [1], [0], [7], [3], [`a[3] = 3`; right half `[3..7]` sorted, holds `3 .. 24`.
   Is `3 < 55 <= 24`? No. Go left.], [`hi = 2`],
  [2], [0], [2], [1], [`a[1] = 40`; left half `[0..1]` sorted, holds `31 .. 40`.
   Is `31 <= 55 < 40`? No. Go right.], [`lo = 2`],
  [3], [2], [2], [2], [`a[2] = 55` — hit.], [return `2`],
)

#subsection[Three things to notice]

+ Every step made the range strictly smaller. That is the only guarantee against an
  infinite loop, and it is worth checking by eye on every binary search you write.
+ The "which half is sorted" test used `a[lo]`, not `a[0]`. Using a fixed endpoint instead
  of the current one is a very common bug.
+ The failed search cost the same as the successful one. Binary search has no fast path —
  it always pays $log n$.

#trap[
If your trace ever shows the same `lo`, `hi` pair twice in a row, you have an infinite
loop. The usual cause is `lo = mid` instead of `lo = mid + 1`.
]

#pagebreak(weak: true)
#section[Practice]

#practice(tier: 1, time: "45 min for 1-5")[
+ *Count inside a range.* Sorted array with duplicates. How many values lie in the closed
  range $[L, R]$? $0 <= n <= 10^5$. Target $O(log n)$.
  Edge cases: `L > R`; the range covers everything.
+ *Integer cube root.* Largest `r` with $r^3 <= n$, for $0 <= n <= 10^18$.
  Target $O(log n)$. Edge cases: `n = 0`; a perfect cube; overflow of `r*r*r`.
+ *Fixed point.* A strictly increasing array of integers. Find the smallest index `i` with
  `a[i] == i`, or `-1`. $0 <= n <= 10^5$. Target $O(log n)$.
  Edge cases: no fixed point; several fixed points.
+ *The k-th missing number.* A strictly increasing array of positive integers. Which is
  the k-th positive integer that is *not* in it? $0 <= n <= 10^5$, $1 <= k <= 10^9$.
  Target $O(log n)$. Edge cases: empty array; nothing missing before the array starts.
+ *Mountain peak.* The array rises then falls, with a single peak. Return the peak index.
  $3 <= n <= 10^5$. Target $O(log n)$. Edge cases: peak next to an end.
]

#practice(tier: 2, time: "50 min for 6-11")[
6. *Search a mountain.* Same mountain shape. Find `target`, preferring the smaller index.
  Target $O(log n)$. Edge cases: target on both slopes; target absent.
7. *Unknown length.* A sorted stream you can only read through `get(i)`, which returns
  `Infinity` past the end. Find `target` without knowing the length.
  Target $O(log p)$ where `p` is the answer's index. Edge cases: target at index 0;
  target absent.
8. *Machines.* `speed[i]` is the number of minutes machine `i` needs per item, and all
  machines run in parallel. What is the fewest minutes to produce `n` items in total?
  $1 <= "speed"_i <= 10^6$, $1 <= n <= 10^6$. Target $O(m log(min "speed" times n))$.
  Edge cases: one machine; `n = 1`.
9. *Pairs under a limit.* Sorted array. Count the pairs $i < j$ with
  $a_i + a_j <= X$. $0 <= n <= 10^5$, values may be negative.
  Target $O(n log n)$. Edge cases: no pair qualifies; the count is large (at $n = 10^5$
  there are about $5 times 10^9$ pairs, still exact as a JavaScript number).
10. *Ceiling square root.* Smallest `k` with $k^2 >= n$, for $0 <= n <= 10^18$.
  Edge cases: `n = 0`; `n` a perfect square.
11. *Closest value.* Sorted array. Return the value closest to `x`; on a tie return the
  smaller one. Target $O(log n)$. Edge cases: `x` below or above everything.
]

#practice(tier: 3, time: "45 min for 12-15")[
12. *The k-th smallest difference.* Given an array, consider the absolute difference of
  every pair. Return the k-th smallest of those differences.
  $2 <= n <= 10^4$. Target $O(n log n + n log("range"))$.
  Edge cases: repeated values (difference 0); `k = 1`.
13. *Real square root.* $sqrt(n)$ to six decimals for $0 <= n <= 10^12$, without
  `sqrt`. State how many iterations you need and why.
14. *The generic helper.* Write one reusable `firstTrue(lo, hi, pred)` that returns the
  smallest value in $["lo", "hi"]$ where `pred` is true, or `hi + 1` if never. Then say which
  two problems from this chapter it replaces outright.
15. *Rope cutting.* `n` ropes of given whole lengths. Cut pieces of one equal whole length
  `L` (leftovers are wasted). What is the largest `L` that still yields at least `k`
  pieces? Return `0` if even `L = 1` cannot. $1 <= n <= 10^5$, lengths up to $10^9$,
  $1 <= k <= 10^9$. Edge cases: `k` larger than the total length.
]

#key[
*1.* Both bounds, subtracted.
#code(lang: "js", caption: "Count inside [L, R]")[
```js
const countInRange = (a, L, R) => {
  if (L > R) return 0;
  return upperBound(a, R) - lowerBound(a, L);
};
```
]
Tested on `[1,3,3,7,9,14,14,20]`: `[3,14]` gives `6`, `[4,6]` gives `0`, `[0,100]` gives
`8`, and a reversed range gives `0`. $O(log n)$ / $O(1)$.

*2.* Cap `hi` at $10^6$, because $(10^6)^3 = 10^18$ already covers the whole input range.
The cube itself must be `BigInt`: tested in Node, `999999 * 999999 * 999999` gives
`999997000002999900`, but the true cube is `999997000002999999`. Plain numbers are wrong
by 99 here.
#code(lang: "js", caption: "Integer cube root")[
```js
const icbrt = (n) => {                  // n is a BigInt, and so is the answer
  let lo = 0n, hi = 1000000n, ans = 0n;
  while (lo <= hi) {
    const mid = lo + (hi - lo) / 2n;
    if (mid * mid * mid <= n) { ans = mid; lo = mid + 1n; }
    else                      { hi = mid - 1n; }
  }
  return ans;
};
```
]
Tested: `icbrt(0n)` gives `0n`, `1n` gives `1n`, `26n` gives `2n`, `27n` gives `3n`,
`28n` gives `3n`, and `1000000000000000000n` gives `1000000n`. Checked against a linear
count-up for every `n` from `0` to `2000`. $O(log n)$ / $O(1)$.

*3.* Because the array is strictly increasing, `a[i] - i` never decreases. So
`a[i] >= i` is monotone and you can search for its first true.
#code(lang: "js", caption: "Smallest fixed point")[
```js
const fixedPoint = (a) => {
  let lo = 0, hi = a.length - 1, ans = -1;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] >= mid) { if (a[mid] === mid) ans = mid; hi = mid - 1; }
    else               { lo = mid + 1; }
  }
  return ans;
};
```
]
Tested: `[-5,-2,2,4,9]` gives `2` and a linear scan agrees; `[1,2,3]` gives `-1`; `[0]`
gives `0`; `[]` gives `-1`. Cross-checked against the scan on 1000 random strictly
increasing arrays. $O(log n)$ / $O(1)$.

*4.* Before index `i` the array has skipped `a[i] - (i + 1)` positive numbers. That count
never decreases, so find the first index where it reaches `k`.
#code(lang: "js", caption: "k-th missing positive")[
```js
const kthMissing = (a, k) => {
  let lo = 0, hi = a.length;
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] - (mid + 1) < k) lo = mid + 1;
    else                        hi = mid;
  }
  return k + lo;
};
```
]
Tested on `[2,3,4,7,11]`: `k = 1` gives `1`, `k = 5` gives `9`. An empty array with
`k = 3` gives `3`; `[1,2,3]` with `k = 2` gives `5`. Cross-checked against a set-based
scan on 1000 random arrays for `k` from 1 to 8. $O(log n)$ / $O(1)$.

*5.* Identical to Example 8 — walk uphill.
#code(lang: "js", caption: "Mountain peak")[
```js
const mountainPeak = (a) => {
  let lo = 0, hi = a.length - 1;
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] < a[mid + 1]) lo = mid + 1;
    else                     hi = mid;
  }
  return lo;
};
```
]
Tested: `[1,4,8,12,7,5,2]` gives `3`. $O(log n)$ / $O(1)$.

*6.* Peak first, then one ordinary search on the rising side and one *reversed* search on
the falling side.
#code(lang: "js", caption: "Search a mountain array")[
```js
const searchMountain = (a, t) => {
  const p = mountainPeak(a);
  let lo = 0, hi = p;                          // rising part
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] === t) return mid;
    if (a[mid] < t) lo = mid + 1; else hi = mid - 1;
  }
  lo = p + 1; hi = a.length - 1;               // falling part
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (a[mid] === t) return mid;
    if (a[mid] > t) lo = mid + 1; else hi = mid - 1;
  }
  return -1;
};
```
]
Tested on `[1,4,8,12,7,5,2]`: `8` gives `2`, `5` gives `5`, `12` gives `3`, `100` gives
`-1`. Note the flipped comparison in the second loop — that one character is the whole
problem. $O(log n)$ / $O(1)$.

*7.* Double the upper bound until it passes the target, then search inside. Doubling
costs $O(log p)$ steps, so the total is still $O(log p)$.
#code(lang: "js", caption: "Exponential search then binary search")[
```js
const unboundedSearch = (get, target) => {
  let hi = 1;
  while (get(hi) !== Infinity && get(hi) < target) hi *= 2;
  let lo = Math.floor(hi / 2);
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    const v = get(mid);
    if (v === target) return mid;
    if (v < target) lo = mid + 1; else hi = mid - 1;
  }
  return -1;
};
```
]
Tested on the stream `2 4 6 8 10 12 14 16 18`: `14` gives index `6`, `2` gives `0`,
`5` gives `-1`, `18` gives `8`. $O(log p)$ time, $O(1)$ space.

*8.* Guess a time `t`. Machine `i` finishes `t / speed[i]` items in that time.
#code(lang: "js", caption: "Minimum build time")[
```js
const madeEnough = (speed, t, n) => {
  let made = 0;
  for (const s of speed) {
    made += Math.floor(t / s);
    if (made >= n) return true;
  }
  return made >= n;
};
const minBuildTime = (speed, n) => {
  let lo = 1, hi = Math.min(...speed) * n;
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (madeEnough(speed, mid, n)) hi = mid;
    else                           lo = mid + 1;
  }
  return lo;
};
```
]
Tested: `([2,3], 5)` gives `6` — in 6 minutes the machines make 3 and 2 items.
`([4], 1)` gives `4`. `([1,1,1], 3)` gives `1`. `([1000000], 1000000)` gives
`1000000000000` — a trillion, comfortably inside the exact range of a JavaScript number,
so no `BigInt` is needed here.
$O(m log(min "speed" times n))$ time, $O(1)$ space.

*9.* For each `i`, binary-search the last `j` whose value fits. The early `return true`
inside `madeEnough` above is the same idea: stop as soon as the answer is settled.
#code(lang: "js", caption: "Count pairs with sum at most X")[
```js
const countPairsAtMost = (a, X) => {
  let c = 0;
  const n = a.length;
  for (let i = 0; i < n; i++) {
    const limit = X - a[i];
    let lo = i + 1, hi = n;               // first index with a[idx] > limit
    while (lo < hi) {
      const mid = Math.floor(lo + (hi - lo) / 2);
      if (a[mid] <= limit) lo = mid + 1;
      else                 hi = mid;
    }
    c += lo - (i + 1);
  }
  return c;
};
```
]
Tested on `[-4,-1,0,2,5,9]`: `X = 3` gives `7` and the brute force agrees; `X = -10` gives
`0`. Empty and single-element arrays give `0`. Cross-checked against a double loop on 1000
random arrays for `X` from `-12` to `40`. $O(n log n)$ / $O(1)$.
#note[
Chapter 3 solves this same problem in $O(n)$ with two pointers. Binary search is the
answer you can write in 60 seconds; two pointers is the answer you offer as the follow-up.
]

*10.* `hi` is $2 times 10^9$ because $(2 times 10^9)^2 = 4 times 10^18$. That square is
past $2^53 - 1$, so this one is `BigInt` too — exactly the same reason as the cube root.
#code(lang: "js", caption: "Ceiling square root")[
```js
const ceilSqrt = (n) => {               // n is a BigInt, and so is the answer
  let lo = 0n, hi = 2000000000n;
  while (lo < hi) {
    const mid = lo + (hi - lo) / 2n;
    if (mid * mid >= n) hi = mid;
    else                lo = mid + 1n;
  }
  return lo;
};
```
]
Tested: `ceilSqrt(0n)` gives `0n`, `1n` gives `1n`, `24n` gives `5n`, `25n` gives `5n`,
`26n` gives `6n`, and `1000000000000000000n` gives `1000000000n`. Verified for every `n`
from 0 to 2000 that $k^2 >= n$ and $(k-1)^2 < n$. $O(log n)$ / $O(1)$.

*11.* `lowerBound` lands on the first value that is not smaller; the answer is that value
or the one before it.
#code(lang: "js", caption: "Closest value")[
```js
const closestValue = (a, x) => {
  const i = lowerBound(a, x);
  if (i === 0) return a[0];
  if (i === a.length) return a[a.length - 1];
  const dl = x - a[i - 1], dr = a[i] - x;
  return dl <= dr ? a[i - 1] : a[i];
};
```
]
Tested on `[1,3,3,7,9,14,14,20]`: `x = 8` gives `7`, `x = 0` gives `1`, `x = 100` gives
`20`, `x = 11` gives `9`. $O(log n)$ / $O(1)$.

*12.* Binary search the *difference*. Counting pairs with difference at most `d` is a
two-pointer sweep — this problem needs both chapters at once.
#code(lang: "js", caption: "k-th smallest pair difference")[
```js
const countDiffAtMost = (a, d) => {
  let c = 0, left = 0;
  for (let right = 0; right < a.length; right++) {
    while (a[right] - a[left] > d) left++;
    c += right - left;
  }
  return c;
};
const kthDifference = (arr, k) => {
  const a = [...arr].sort((p, q) => p - q);   // numeric comparator, always
  let lo = 0, hi = a[a.length - 1] - a[0];
  while (lo < hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (countDiffAtMost(a, mid) >= k) hi = mid;
    else                              lo = mid + 1;
  }
  return lo;
};
```
]
Tested on `[1,6,3,10]`: the answers for `k = 1..6` are `2 3 4 5 7 9`, exactly matching a
brute force over all pairs. Cross-checked on 1000 random arrays for every `k`.
$O(n log n + n log("range"))$ time, $O(1)$ space.

*13.* One hundred halvings. Each one halves the error, so after 100 rounds the remaining
interval is the start width divided by $2^100$ — far below what a JavaScript number can
represent, which means it is exact to every digit the type can hold.
#code(lang: "js", caption: "Real square root")[
```js
const sqrtReal = (n) => {
  let lo = 0, hi = Math.max(1, n);
  for (let it = 0; it < 100; it++) {
    const mid = (lo + hi) / 2;
    if (mid * mid <= n) lo = mid;
    else                hi = mid;
  }
  return lo;
};
```
]
Tested: `2` prints `1.414214`, `1e12` prints `1000000.000000`, `0` prints `0.000000`.
In practice 60 rounds are already enough for a JavaScript number; 100 cost nothing and
remove all doubt.

*14.* The helper, and the two problems it replaces.
#code(lang: "js", caption: "One search to rule them all")[
```js
const firstTrue = (lo, hi, pred) => {
  let ans = hi + 1;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (pred(mid)) { ans = mid; hi = mid - 1; }
    else           { lo = mid + 1; }
  }
  return ans;
};
```
]
Tested: `firstTrue(1, 100, v -> v*v >= 50)` gives `8`; an always-false predicate on
`[1,10]` gives `11`; an always-true one gives `1`.
It replaces Example 12 (first failing build) and Example 16 (minimum truck capacity) with
one line each — pass the feasibility check as `pred`. The Python version in Example 16
does exactly that. $O(log("range"))$ calls to `pred`.

*15.* Guess a length; count the pieces.
#code(lang: "js", caption: "Largest cut length")[
```js
const piecesAt = (rope, L) => {
  let c = 0;
  for (const r of rope) c += Math.floor(r / L);
  return c;
};
const maxPieceLength = (rope, k) => {
  let lo = 1, hi = Math.max(...rope), ans = 0;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    if (piecesAt(rope, mid) >= k) { ans = mid; lo = mid + 1; }
    else                          { hi = mid - 1; }
  }
  return ans;
};
```
]
Tested: `([9,7,21], 5)` gives `7` — the ropes yield 1, 1 and 3 pieces of length 7, which is
5 in total. `([5], 5)` gives `1`. `([1,1], 5)` gives `0`. `([1000000000], 1)` gives
`1000000000`. $O(n log(max "rope"))$ time, $O(1)$ space.
#trap[
`L` starts at `1`, never at `0`. Dividing by zero would crash before the answer `0` is
ever reported, so keep the "impossible" case in `ans`, not in the range.
]
]

#revision[
#subsection[The three templates]

#code(lang: "js", caption: "T1 — exact match")[
```js
let lo = 0, hi = a.length - 1;
while (lo <= hi) {
  const mid = Math.floor(lo + (hi - lo) / 2);
  if (a[mid] === t) return mid;
  if (a[mid] < t) lo = mid + 1; else hi = mid - 1;
}
return -1;
```
]
#code(lang: "js", caption: "T2 — first index that is good")[
```js
let lo = 0, hi = n;
while (lo < hi) {
  const mid = Math.floor(lo + (hi - lo) / 2);
  if (!good(mid)) lo = mid + 1; else hi = mid;
}
return lo;                    // n means none
```
]
#code(lang: "js", caption: "T3 — smallest feasible answer")[
```js
let lo = LOW, hi = HIGH;
while (lo < hi) {
  const mid = Math.floor(lo + (hi - lo) / 2);
  if (feasible(mid)) hi = mid; else lo = mid + 1;
}
return lo;
```
]
#code(lang: "js", caption: "T3' — largest feasible answer")[
```js
let lo = LOW, hi = HIGH, ans = -1;
while (lo <= hi) {
  const mid = Math.floor(lo + (hi - lo) / 2);
  if (feasible(mid)) { ans = mid; lo = mid + 1; }
  else               { hi = mid - 1; }
}
return ans;
```
]

#subsection[When to use what]

#table(
  columns: (1.15fr, 0.85fr, auto),
  [*Question says*], [*Template*], [*Time*],
  [find a value in a sorted array], [T1], [$O(log n)$],
  [first / last occurrence, count], [T2 twice], [$O(log n)$],
  [floor, ceiling, insert position], [T2], [$O(log n)$],
  [find a peak / any local maximum], [T2 on the slope], [$O(log n)$],
  [rotated sorted array], [T1 + "which half is sorted"], [$O(log n)$],
  [rotated with duplicates], [same, plus `lo++, hi--`], [$O(n)$ worst],
  [minimum capacity / speed / size], [T3], [$O(n log R)$],
  [maximise the minimum spacing], [T3'], [$O(n log R)$],
  [k-th smallest in a sorted matrix], [T3 on the *value*], [$O(n log R)$],
  [median / k-th of two sorted arrays], [T2 on the split point], [$O(log min(n,m))$],
  [answer is a real number], [100 fixed halvings], [$O(100 n)$],
)

#subsection[Complexity you should be able to quote]

#table(
  columns: (1.5fr, auto, auto),
  [*Problem*], [*Time*], [*Space*],
  [search / lower bound / count], [$O(log n)$], [$O(1)$],
  [peak element], [$O(log n)$], [$O(1)$],
  [rotated search, distinct values], [$O(log n)$], [$O(1)$],
  [rotated search, duplicates allowed], [$O(n)$ worst], [$O(1)$],
  [flattened sorted matrix], [$O(log(r c))$], [$O(1)$],
  [minimum capacity / speed on the answer], [$O(n log R)$], [$O(1)$],
  [k-th smallest in a sorted grid], [$O(n log R)$], [$O(1)$],
  [median of two sorted arrays], [$O(log min(n,m))$], [$O(1)$],
  [peak in a 2D grid], [$O(r log c)$], [$O(1)$],
)

`R` means the width of the value range you are searching, not the array length.

#subsection[Top traps, in the order they bite]

+ *A fractional `mid`.* `(lo + hi) / 2` is real division in JavaScript. Always
  `Math.floor(lo + (hi - lo) / 2)`, and never `>>1`, which truncates to 32 bits.
+ *A branch that does not shrink the range.* `lo = mid` with `while (lo < hi)` hangs
  forever. Every branch must move `lo` up or `hi` down.
+ *Guard and range disagreeing.* `[lo, hi]` needs `lo <= hi` and `mid ± 1`. `[lo, hi)`
  needs `lo < hi` and `hi = mid`.
+ *Trusting `lowerBound` without checking the value.* It returns an insert position when
  the target is absent.
+ *`mid * mid` inside the loop.* Stops being exact past $2^53 - 1$. Use `mid <= n / mid`,
  cap `hi` so the product is provably safe, or move the whole search to `BigInt`.
+ *A feasibility check that is not monotone.* Then binary search is simply the wrong tool
  and no amount of debugging will fix it. Test the check on paper for three or four
  values first.
+ *A wrong starting range in T3.* Too high only wastes iterations; too low returns a
  confidently wrong answer.
+ *`while (hi - lo > eps)` on real numbers.* Can spin forever. Use a fixed iteration count.
+ *Comparing against `a[0]` or `a[n-1]` instead of `a[lo]` / `a[hi]`* in the rotated
  problems.

#subsection[The 30-second checklist before you code]

+ What exactly am I searching over — an index, or a real-world quantity?
+ Write the yes/no test as a sentence. Is it truly `F F F T T T`?
+ What are the smallest and largest candidates? Justify both out loud.
+ Closed or half-open range? Pick one and match the guard.
+ Does every branch shrink the range?
+ Can any intermediate value pass $2^53 - 1$ = `9007199254740991`? If yes, `BigInt`
  everywhere in that search — and never `>>1` for the midpoint.
]
