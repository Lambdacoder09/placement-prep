#import "../../shared/lib/style.typ": *

#chapter(num: 2, title: "Arrays & Prefix Sums",
  tagline: "Pay once, answer every question in O(1)")[

#section[Pattern in one page]

An array question that says "sum of the values from $l$ to $r$" and then asks it two hundred
thousand times is not a sum question. It is a *prefix sum* question. Build a running total
once, and every answer becomes one subtraction.

#formulas(title: "The prefix sum, end to end")[

*The definition.* For an array `a` of length $n$, build `p` of length $n + 1$:
$ p[0] = 0, quad p[i+1] = p[i] + a[i] $
So $p[i]$ is the sum of the *first $i$* values, that is $a[0] + a[1] + ... + a[i-1]$.

*The one formula that matters.*
$ "sum of " a[l..r] = p[r+1] - p[l] $
Both ends included. Everything before $l$ appears in both terms and cancels.

*Why `p` has $n + 1$ slots.* $p[0] = 0$ is the sum of nothing. Without it you cannot write
the formula for a subarray that starts at index 0.

*The invariant.* After the loop has processed index $i$, the variable `run` holds
$a[0] + ... + a[i]$, which is exactly $p[i+1]$.

*The pair view — this unlocks half the chapter.* Every subarray $a[l..r]$ is a *pair of
prefixes* $(p[l], p[r+1])$. So:
- "subarray with sum $k$" $arrow.r$ "pair of prefixes that differ by $k$"
- "subarray with sum divisible by $k$" $arrow.r$ "pair of prefixes with the same remainder mod $k$"
- "subarray with XOR $k$" $arrow.r$ "pair of prefix XORs whose XOR is $k$"

Counting pairs is a job for a hash map, and it costs $O(n)$.

*The difference array — prefix sums run backwards.* To add $v$ to every index in $[l, r]$,
many times, and only read the array at the end:
$ d[l] "+"= v, quad d[r+1] "-"= v, quad "then take the prefix sum of " d $
Each update is $O(1)$ instead of $O(r - l + 1)$.

*Two dimensions.* $ p[i+1][j+1] = g[i][j] + p[i][j+1] + p[i+1][j] - p[i][j] $
$ "rectangle"(r_1, c_1, r_2, c_2) = p[r_2+1][c_2+1] - p[r_1][c_2+1] - p[r_2+1][c_1] + p[r_1][c_1] $
The middle term is subtracted twice, so it is added back once. This is inclusion--exclusion.
]

#subsection[The template you write from memory]

#code(lang: "js", caption: "Build once, query forever")[
```js
const buildPrefix = (a) => {
  const p = new Array(a.length + 1).fill(0);      // .fill(0) is required
  for (let i = 0; i < a.length; i++) p[i + 1] = p[i] + a[i];
  return p;
};

const rangeSum = (p, l, r) => p[r + 1] - p[l];   // sum of a[l..r], both ends included
```
]

Run on `a = [4, -2, 7, 1, 0, -5, 3]`:

#code(lang: "text", caption: "Measured output")[
```text
p = 0 4 2 9 10 10 5 8
sum(0,6) = 8
sum(2,4) = 8
sum(3,3) = 1
sum(0,0) = 4
empty prefix length = 1
single: -9
```
]

#trap[
`new Array(n + 1)` on its own makes a *sparse* array: every slot is a hole, reading one gives
`undefined`, and `undefined + a[i]` is `NaN`. Always write `new Array(n + 1).fill(0)`. For a
big fixed-size numeric table, `new Float64Array(n + 1)` is zero-filled already, and when
every value fits in 32 bits `new Int32Array(n + 1)` halves the memory too.
]

Check `sum(2,4)` by hand: $a[2] + a[3] + a[4] = 7 + 1 + 0 = 8$. The formula says
$p[5] - p[2] = 10 - 2 = 8$. They agree.

#diagram(height: 4.4cm, caption: "sum(l..r) = p[r+1] - p[l]. The shaded part on the left cancels.")[
  #dnode(0pt, 0pt, 2.4cm, 0.85cm, [$a[0..l-1]$], fill: rgb("#e6e6e6"))
  #dnode(2.5cm, 0pt, 4.2cm, 0.85cm, [$a[l..r]$ — the part we want])
  #dnode(6.8cm, 0pt, 2.4cm, 0.85cm, [$a[r+1..n-1]$], fill: rgb("#e6e6e6"))
  #dnode(0pt, 1.4cm, 2.4cm, 0.8cm, [$p[l]$], fill: rgb("#f7f7f5"))
  #dnode(0pt, 2.6cm, 6.7cm, 0.8cm, [$p[r+1]$], fill: rgb("#f7f7f5"))
  #darrow(1.2cm, 0.9cm, 1.2cm, 1.35cm)
  #darrow(3.4cm, 0.9cm, 3.4cm, 2.55cm)
  #dnode(7.2cm, 1.9cm, 5.2cm, 1.0cm, [$p[r+1] - p[l]$ leaves exactly $a[l..r]$])
]

#subsection[When to reach for this pattern]

#table(columns: 2,
  align: (left, left),
  [*The problem says*], [*You build*],
  ["sum of $l$ to $r$", asked $q$ times], [prefix sums, $O(1)$ per query],
  ["how many subarrays have sum $k$"], [prefix + hash map of counts],
  ["sum divisible by $k$"], [prefix remainder + a count array of size $k$],
  ["equal number of 0s and 1s"], [map 0 to $-1$, then look for sum 0],
  ["XOR of a subarray"], [prefix XOR (XOR is its own inverse)],
  ["add $v$ to all of $[l, r]$", many times], [difference array],
  ["sum of a rectangle in a grid"], [2-D prefix sums],
  ["range sum *and* the values change"], [Fenwick tree — prefix sums break],
  ["maximum in a range"], [*not* prefix sums — max cannot be undone],
)

#trap[
*The three bugs that cost marks in this chapter.*
+ Off by one. `p[r + 1] - p[l]`, not `p[r] - p[l]`. Write the formula on paper first with a
  3-element array.
+ Forgetting `seen.set(0, 1)` in the counting version. That entry stands for the empty
  prefix, and without it you lose every subarray that starts at index 0.
+ A plain object instead of a `Map` for the prefix counts. Prefix sums go negative, and an
  object turns the key $-3$ into the string `"-3"`. Use a `Map`.
]

#subsection[Four JavaScript facts this chapter depends on]

#trap[
*Numbers are doubles.* They are exact only up to `Number.MAX_SAFE_INTEGER`
$= 2^53 - 1 = 9[,]007[,]199[,]254[,]740[,]991$. Prefix sums add up fast, so check the worst
total *before* you code. $2 times 10^5$ values of $10^4$ is $2 times 10^9$ — perfectly safe
here. $3 times 10^5$ values of $10^12$ is $3 times 10^17$ — not safe, and the loop silently
drifts. See Example 5 for the measured drift and the `BigInt` fix.
]

#trap[
*`Map`, not a plain object, for prefix counts.* An object stringifies every key, so the
number `-3` and the text `"-3"` become one entry, and iteration order is not what you expect
for numeric-looking keys. A `Map` keeps the number as a number. Use `map.get(k) ?? 0` when
reading, because a missing key gives `undefined` and `undefined + 1` is `NaN`.
]

#trap[
*`%` on a negative number is negative.* Tested in Node: `-7 % 3` is `-1`, not `2`. Using
$-1$ as an array index gives `undefined`, and `undefined + 1` is `NaN`, so the whole count
becomes `NaN` with no error message. Always write `((run % k) + k) % k`. See Example 17.
]

#trap[
*`[...grid]` is a SHALLOW copy.* It copies the outer array only, so both copies still point
at the same rows. Tested in Node: after `const shallow = [...grid]; shallow[0][0] = 99;` the
original prints `[[99,2],[3,4]]`. A 2-D grid needs `grid.map(row => [...row])`, which leaves
the original as `[[1,2],[3,4]]`. This chapter builds 2-D tables in Examples 20 and 26.
]

#note[
This chapter uses `lowerBound`, `upperBound` and `Deque` from the *JS Toolkit* appendix.
JavaScript ships none of them. One line brings them in:

#code(lang: "js", caption: "The one require line")[
```js
const { Deque, lowerBound, upperBound } = require('./toolkit.js');
```
]
]

#subsection[What prefix sums cannot do]

Subtraction is what makes the trick work: to remove the left part, you *undo* it. So the
pattern works for any operation that can be undone — plus (undo with minus), XOR (undo with
XOR), count (undo with subtract), product with no zeros (undo with divide, carefully).

It does *not* work for maximum or minimum. You cannot "un-maximum" a value. Range maximum
needs a different tool (a sparse table, a segment tree, or a monotonic deque — Chapters 9
and onwards).

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[Build the prefix array of `a = [3, 1, 4, 1, 5]` by hand.
#sol[
Start with $p[0] = 0$. Then keep adding.
- $p[1] = p[0] + a[0] = 0 + 3 = 3$
- $p[2] = p[1] + a[1] = 3 + 1 = 4$
- $p[3] = p[2] + a[2] = 4 + 4 = 8$
- $p[4] = p[3] + a[3] = 8 + 1 = 9$
- $p[5] = p[4] + a[4] = 9 + 5 = 14$
]
#ans[`p = [0, 3, 4, 8, 9, 14]` — six entries for five values]
]

#ex(2, tier: 0)[Using the `p` from Example 1, find the sum of `a[1..3]`.
#sol[
The formula is $p[r+1] - p[l]$ with $l = 1$ and $r = 3$.
$p[4] - p[1] = 9 - 3 = 6$.
Check directly: $a[1] + a[2] + a[3] = 1 + 4 + 1 = 6$. Correct.
]
#ans[6]
]

#ex(3, tier: 0)[Same `p`. Find the sum of `a[0..4]` and the sum of `a[2..2]`.
#sol[
Whole array: $l = 0$, $r = 4$, so $p[5] - p[0] = 14 - 0 = 14$.
This is why $p[0] = 0$ must exist.

One single element: $l = r = 2$, so $p[3] - p[2] = 8 - 4 = 4$, which is $a[2]$. Correct.
]
#ans[14 and 4]
]

#ex(4, tier: 0)[An array of 0s and 1s: `a = [1, 0, 0, 1, 1]`. How many 1s are in `a[1..4]`?
#sol[
A count is just a sum when the values are 0 and 1.
$p = [0, 1, 1, 1, 2, 3]$.
Sum of $a[1..4] = p[5] - p[1] = 3 - 1 = 2$.
Check: $a[1], a[2], a[3], a[4] = 0, 0, 1, 1$, which has two 1s. Correct.
]
#ans[2]
#note[
Any yes/no test becomes a prefix sum: write 1 when the test passes and 0 when it fails.
"How many values above 50 in this range" is the same problem.
]
]

#ex(5, tier: 0)[An array holds 300,000 ride fares, each exactly 10,000. Is the total exact in
JavaScript? Now make each fare 987,654,321,987. Is it still exact?
#sol[
$300[,]000 times 10[,]000 = 3[,]000[,]000[,]000 = 3 times 10^9$. JavaScript numbers are exact
up to $2^53 - 1 approx 9 times 10^15$, so $3 times 10^9$ is safe with room to spare. There
is no 32-bit integer type in JavaScript, so there is nothing to overflow here.

The second total is $300[,]000 times 987[,]654[,]321[,]987 approx 3 times 10^17$. That is
*past* the safe range. This was measured, not guessed:

#code(lang: "text", caption: "Measured output")[
```text
n*f Number = 296296296596100000 safe? false
n*f BigInt = 296296296596100000
summed in a loop = 296296296595336800
summed as BigInt = 296296296596100000
```
]

The loop answer is wrong by 763,200. Notice that this is *not* a crash and *not* a negative
number. It is a plausible-looking number with the wrong digits near the end — the hardest
kind of bug to spot.

The fix is `BigInt`. Convert only the values that need it, and only at the end convert back:

#code(lang: "js", caption: "Exact totals past 2^53")[
```js
let total = 0n;
for (const fare of fares) total += BigInt(fare);
console.log(total.toString());
```
]
Run on 300,000 copies of `987654321987`, this prints `296296296596100000`, which matches the
`BigInt` product exactly.
]
#ans[$3 times 10^9$ is exact; $3 times 10^17$ is not and needs `BigInt`]
#note[
The habit to build: before writing the prefix loop, multiply $n$ by the largest value and
compare with $9 times 10^15$. Every other example in this chapter passes that check, so they
all use plain numbers.
]
]

#ex(6, tier: 0)[You know the total of the whole array and the sum of everything to the left
of index $i$. How do you get the sum of everything to the right of $i$, with no second loop?
#sol[
The three parts cover the whole array exactly once:
$ "left" + a[i] + "right" = "total" $
So
$ "right" = "total" - "left" - a[i] $
One subtraction, $O(1)$. This removes the inner loop from the next example.
]
#ans[`right = total - left - a[i]`]
]

#section[Tier 1 — Build the reflex]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
*Problem.* An array of $n$ daily sales figures. Answer $q$ questions of the form "total sales
from day $l$ to day $r$".
*Constraints.* $n, q <= 2 times 10^5$; each figure in $[-10^4, 10^4]$ (refunds are negative).
*Target.* $O(n + q)$.
*Edge cases.* $l = r$; $l = 0$ and $r = n-1$; a total near the largest possible.

#sol[
#approach(1, "Add up the range for each question", verdict: "O(n q) = 4·10^10 — too slow")

#code(lang: "js", caption: "One question, one scan")[
```js
const sumSlow = (a, l, r) => {
  let s = 0;
  for (let i = l; i <= r; i++) s += a[i];
  return s;
};
```
]
#complexity(time: "O(n) per query", space: "O(1)")

#approach(2, "Prefix sums", verdict: "O(n) build, O(1) per query — optimal")

#code(lang: "js", caption: "Build once")[
```js
const p = new Array(n + 1).fill(0);
for (let i = 0; i < n; i++) p[i + 1] = p[i] + a[i];
// answer a query:
const answer = p[r + 1] - p[l];
```
]
#complexity(time: "O(n + q)", space: "O(n)")

Measured with $n = q = 200[,]000$ wide queries, against the slow version on the first 200
of them:

#code(lang: "text", caption: "Measured output")[
```text
first 200 queries agree? yes
slow: 200 queries in 32 ms
prefix: all 200000 queries in 19 ms
```
]

Thirty-two milliseconds for 200 questions means about 32 seconds for 200,000. The prefix
version answered all of them in 19 ms.

*The idea.* The questions overlap, so the slow version adds the same numbers over and over.
Pay $O(n)$ once and every later answer is free.
]
#note[
The worst possible total here is $2 times 10^5 times 10^4 = 2 times 10^9$. Run the check from
Example 5: that is far under $9 times 10^15$, so plain numbers are exact and no `BigInt` is
needed.
]
]

#ex(8, tier: 1, asked: "Infosys · pattern")[
*Problem.* Find an index $i$ where the sum of everything to its left equals the sum of
everything to its right. Return $-1$ if none exists.
*Constraints.* $n <= 2 times 10^5$; values may be negative.
*Target.* $O(n)$.
*Edge cases.* empty array (answer $-1$); one element (index 0 always works, both sides are
empty and sum to 0); all zeros.

#sol[
#approach(1, "For each i, add both sides", verdict: "O(n^2)")

#code(lang: "js", caption: "Brute force")[
```js
const equilibriumBrute = (a) => {
  for (let i = 0; i < a.length; i++) {
    let left = 0, right = 0;
    for (let j = 0; j < i; j++) left += a[j];
    for (let j = i + 1; j < a.length; j++) right += a[j];
    if (left === right) return i;
  }
  return -1;
};
```
]

#approach(2, "Carry the left sum, derive the right sum", verdict: "O(n) — optimal")

Use Example 6: `right = total - left - a[i]`. Nothing has to be re-added.

#code(lang: "js", caption: "One pass")[
```js
const equilibriumFast = (a) => {
  let total = 0;
  for (const x of a) total += x;
  let left = 0;
  for (let i = 0; i < a.length; i++) {
    const right = total - left - a[i];
    if (left === right) return i;
    left += a[i];                // now left is the sum of a[0..i]
  }
  return -1;
};
```
]
#complexity(time: "O(n)", space: "O(1) extra")

Both were run on the same tests:

#code(lang: "text", caption: "Measured output")[
```text
[] brute=-1 fast=-1
[7] brute=0 fast=0
[1,2,3] brute=-1 fast=-1
[2,4,2] brute=1 fast=1
[1,-1,0,-1,1] brute=2 fast=2
[0,0,0] brute=0 fast=0
[5,5] brute=-1 fast=-1
```
]

Look at `[7]`: the answer is index 0, because the empty left side and the empty right side
both sum to 0. Many students return $-1$ here and lose the test case.

*The idea.* The inner loops were recomputing a sum that changes by only one element each
step. Carry it instead.
]
#trap[
`left += a[i]` must come *after* the check, not before. Put it before and you have included
`a[i]` in the left side, which is wrong.
]
]

#ex(9, tier: 1, asked: "Wipro · pattern")[
*Problem.* Given $n$ values and a threshold $t$, answer $q$ questions: "how many values in
$a[l..r]$ are greater than $t$?"
*Constraints.* $n, q <= 2 times 10^5$; $t$ is fixed for all questions.
*Target.* $O(n + q)$.
*Edge cases.* a range where no value passes; a range of length 1.

#sol[
A count is a sum of 1s and 0s. Build a prefix array of the *test result*, not of the values.

#code(lang: "js", caption: "Prefix of a yes/no test")[
```js
const c = new Array(n + 1).fill(0);
for (let i = 0; i < n; i++) c[i + 1] = c[i] + (a[i] > threshold ? 1 : 0);
// answer: number of values > threshold in a[l..r]
const answer = c[r + 1] - c[l];
```
]
#complexity(time: "O(n + q)", space: "O(n)")

Run on `a = [10, 55, 3, 80, 50, 51, 2, 99]` with `threshold = 50`:

#code(lang: "text", caption: "Measured output")[
```text
counts prefix: 0 0 1 1 2 2 3 3 4
range [0,7] fast=4 slow=4
range [1,3] fast=2 slow=2
range [2,2] fast=0 slow=0
range [0,0] fast=0 slow=0
range [6,7] fast=1 slow=1
```
]

Careful with $50$ itself: the test is *greater than* 50, so `a[4] = 50` does not count. That
is why the prefix does not rise at position 5.
]
#trick[
If the threshold changed from query to query, this trick would stop working, and the answer
would be "sort the values and binary-search with `lowerBound` from the *JS Toolkit*
appendix", or a merge sort tree. Watch for the word *fixed* in the statement.
]
]

#ex(10, tier: 1, asked: "Capgemini · pattern")[
*Problem.* Find the largest sum of any $k$ consecutive values.
*Constraints.* $n <= 10^6$, $1 <= k <= n$; values may be negative.
*Target.* $O(n)$.
*Edge cases.* $k = n$ (only one window); $k = 1$ (the largest single value); all values
negative.

#sol[
#approach(1, "Add up every window", verdict: "O(n k)")

#approach(2, "Prefix sums", verdict: "O(n) — each window is one subtraction")

#code(lang: "js", caption: "Windows from prefix sums")[
```js
const bestWindowPrefix = (a, k) => {
  const n = a.length;
  if (k > n || k <= 0) return null;          // no window exists
  const p = buildPrefix(a);
  let best = -Infinity;
  for (let l = 0; l + k <= n; l++) best = Math.max(best, p[l + k] - p[l]);
  return best;
};
```
]

#approach(3, "Slide the window", verdict: "O(n) time, O(1) extra space — optimal")

Moving the window one step right adds one value and drops one value.

#code(lang: "js", caption: "Sliding window")[
```js
const bestWindowSlide = (a, k) => {
  const n = a.length;
  if (k > n || k <= 0) return null;
  let run = 0;
  for (let i = 0; i < k; i++) run += a[i];
  let best = run;
  for (let i = k; i < n; i++) {
    run += a[i] - a[i - k];      // add the new one, drop the old one
    best = Math.max(best, run);
  }
  return best;
};
```
]
#complexity(time: "O(n)", space: "O(1)",
  note: "Same time as prefix sums, but no n+1 array. This is Chapter 3's pattern.")

Both, on `a = [3, -1, 4, 1, -5, 9, 2, -6]`:

#code(lang: "text", caption: "Measured output")[
```text
k=1 prefix=9 slide=9
k=2 prefix=11 slide=11
k=3 prefix=6 slide=6
k=4 prefix=9 slide=9
k=5 prefix=11 slide=11
k=6 prefix=11 slide=11
k=7 prefix=13 slide=13
k=8 prefix=7 slide=7
single, k=1: 7
k larger than n: null
all negative [-3,-1,-4] k=2: -4
```
]

Check $k = 2$: the windows are $2, 3, 5, -4, 4, 11, -4$. The largest is 11, from
$9 + 2$. Correct.
]
#trap[
Start `best` at `-Infinity`, not at `0`. The last measured line is the reason: with every
value negative, the true answer is $-4$, and a version that starts at `0` returns `0`, which
is not the sum of any window. JavaScript's `-Infinity` is the clean equivalent of a "smallest
possible" sentinel, and unlike a hand-picked big negative number it can never be beaten by
real data.
]
]

#ex(11, tier: 1, asked: "Cognizant · pattern")[
*Problem.* Cut the array into two non-empty parts at some position. Make the two part-sums as
close as possible, and report the smallest possible difference.
*Constraints.* $2 <= n <= 2 times 10^5$; values in $[-10^4, 10^4]$.
*Target.* $O(n)$.
*Edge cases.* $n = 2$ (only one cut); all values equal; negative values.

#sol[
#approach(1, "Try every cut and add both sides", verdict: "O(n^2)")

#approach(2, "Total minus running left", verdict: "O(n) — optimal")

#code(lang: "js", caption: "One pass")[
```js
const bestSplitFast = (a) => {
  let total = 0;
  for (const x of a) total += x;
  let left = 0, best = Infinity;
  for (let i = 0; i + 1 < a.length; i++) {   // cut AFTER index i, so i stops at n-2
    left += a[i];
    best = Math.min(best, Math.abs(left - (total - left)));
  }
  return best;
};
```
]
#complexity(time: "O(n)", space: "O(1)")

Checked against the brute force on every test, plus 500 random arrays:

#code(lang: "text", caption: "Measured output")[
```text
[1,1] brute=0 fast=0
[1,2,3,4] brute=2 fast=2
[10,-10,10] brute=10 fast=10
[5,5,5,5] brute=0 fast=0
[-3,-3] brute=0 fast=0
[1,2,3,4,5,6] brute=1 fast=1
500 random cross-checks passed
```
]

Trace `[1,2,3,4]`: total is 10. Cut after index 0: $|1 - 9| = 8$. After index 1:
$|3 - 7| = 4$. After index 2: $|6 - 4| = 2$. The best is 2.
]
#trap[
The loop must stop at $i = n - 2$. If it runs to $n - 1$, the right part is empty, which the
problem forbids.
]
]

#ex(12, tier: 1, asked: "Accenture · pattern")[
*Problem.* Prices of one item on $n$ days. Buy on one day and sell on a *later* day. What is
the largest gain? If every later price is lower, the answer is 0 (do not trade).
*Constraints.* $n <= 10^6$; prices up to $10^9$.
*Target.* $O(n)$.
*Edge cases.* empty or single day (answer 0); prices only falling (answer 0); all prices
equal (answer 0).

#sol[
#approach(1, "Every buy day against every sell day", verdict: "O(n^2)")

#approach(2, "Carry the cheapest day so far", verdict: "O(n) — optimal")

For each day, the best possible sale today uses the *smallest price seen before today*. So
keep that one number.

#code(lang: "js", caption: "One pass, one carried value")[
```js
const bestGainFast = (price) => {
  if (price.length === 0) return 0;
  let best = 0, lowestSoFar = price[0];
  for (let i = 1; i < price.length; i++) {
    best = Math.max(best, price[i] - lowestSoFar);
    lowestSoFar = Math.min(lowestSoFar, price[i]);
  }
  return best;
};
```
]
#complexity(time: "O(n)", space: "O(1)")

#code(lang: "text", caption: "Measured output")[
```text
[] brute=0 fast=0
[5] brute=0 fast=0
[1,5] brute=4 fast=4
[5,1] brute=0 fast=0
[7,2,9,4,10,1] brute=8 fast=8
[9,8,7] brute=0 fast=0
[4,4,4] brute=0 fast=0
500 random cross-checks passed
```
]

Trace `[7,2,9,4,10,1]`: lowest so far goes $7, 2, 2, 2, 2$. The gains are
$2-7$ (ignore, negative), $9-2 = 7$, $4-2 = 2$, $10-2 = 8$, $1-2$ (negative). Best is 8.

*The idea.* This is the same shape as the prefix trick: an inner loop that searches
backwards for a minimum is replaced by one carried value. The cost drops from $O(n^2)$ to
$O(n)$.
]
#trap[
The update order matters. Compare *first*, then update `lowestSoFar`. If you update first,
you allow buying and selling on the same day.
]
]

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
*Problem.* An array holds all of $1, 2, ..., n+1$ except one value, in any order. Find the
missing one.
*Constraints.* $n <= 2 times 10^6$.
*Target.* $O(n)$ time, $O(1)$ extra space.
*Edge cases.* empty array (the missing value is 1); the missing value is the largest; a very
large $n$ where the total leaves the exact range of a JavaScript number.

#sol[
#approach(1, "Sort, then scan for the gap", verdict: "O(n log n)")

#approach(2, "Expected total minus actual total", verdict: "O(n), but the total grows fast")

#code(lang: "js", caption: "Sum method")[
```js
const missingBySum = (a) => {
  const n = a.length;
  let total = (n + 1) * (n + 2) / 2;   // sum of 1..n+1
  for (const x of a) total -= x;
  return total;
};
```
]

#approach(3, "XOR everything", verdict: "O(n), and the value never grows — optimal")

XOR has two gifts: $x xor x = 0$, and $x xor 0 = x$. XOR all of $1..n+1$ together with every
value present. Every present value appears twice and cancels itself. Only the missing one
survives.

#code(lang: "js", caption: "XOR method")[
```js
const missingByXor = (a) => {
  const n = a.length;
  let x = 0;
  for (let i = 1; i <= n + 1; i++) x ^= i;
  for (const v of a) x ^= v;
  return x;
};
```
]
#complexity(time: "O(n)", space: "O(1)", note: "The running value never exceeds the largest input.")

#code(lang: "text", caption: "Measured output")[
```text
n=0 [] sum=1 xor=1
n=1 [2] sum=1 xor=1
n=1 [1] sum=2 xor=2
n=4 [1,2,4,5] sum=3 xor=3
n=4 [5,4,3,2] sum=1 xor=1
n=5 [2,3,4,5,6] sum=1 xor=1
big: sum=1234567 xor=1234567
total of 1..2000001 = 2000003000001  safe? true
total of 1..200000000 = 20000000100000000  safe? false
```
]

The last two lines are the point. At $n = 2 times 10^6$ the expected total is about
$2 times 10^12$, which a JavaScript number still holds exactly. Push $n$ to $2 times 10^8$
and the total is $2 times 10^16$, past $2^53 - 1$, and the sum method starts returning
nonsense. The XOR method never has that problem, because the XOR of numbers below $2^21$ is
itself below $2^21$.
]
#trap[
JavaScript's `^` converts both sides to a *32-bit signed integer*. That is fine here, because
$n + 1 <= 2[,]000[,]001 < 2^31$. If the values could reach $2^31$ the XOR method would break
too, and you would need `BigInt` XOR. Always check the value range before reaching for a
bitwise operator in JavaScript.
]
]

#ex(14, tier: 1, asked: "Infosys · pattern")[
*Problem.* Rotate an array right by $k$ positions. So `[1,2,3,4,5]` with $k = 2$ becomes
`[4,5,1,2,3]`.
*Constraints.* $n <= 10^6$, $0 <= k <= 10^9$.
*Target.* $O(n)$ time, $O(1)$ extra space.
*Edge cases.* empty array; $k = 0$; $k$ bigger than $n$ (take $k mod n$); $k = n$ (no
change).

#sol[
#approach(1, "Shift by one, k times", verdict: "O(n k) — 10^15 at the limits, hopeless")

#approach(2, "Copy into a second array", verdict: "O(n) time, O(n) space")

#code(lang: "js", caption: "With an extra array")[
```js
const rotateExtra = (a, k) => {
  const n = a.length;
  if (n === 0) return a;
  k %= n;
  const b = new Array(n);
  for (let i = 0; i < n; i++) b[(i + k) % n] = a[i];
  for (let i = 0; i < n; i++) a[i] = b[i];     // copy back, in place
  return a;
};
```
]

#approach(3, "Three reversals", verdict: "O(n) time, O(1) space — optimal")

Reverse the whole array, then reverse the first $k$, then reverse the rest. JavaScript's
built-in `a.reverse()` reverses the *whole* array and takes no range, so write a two-pointer
helper that reverses a slice in place.

#code(lang: "js", caption: "The reversal trick")[
```js
const reverseRange = (a, i, j) => {
  while (i < j) { [a[i], a[j]] = [a[j], a[i]]; i++; j--; }
};

const rotateReverse = (a, k) => {
  const n = a.length;
  if (n === 0) return a;
  k %= n;
  reverseRange(a, 0, n - 1);
  reverseRange(a, 0, k - 1);
  reverseRange(a, k, n - 1);
  return a;
};
```
]

Why it works, on `[1,2,3,4,5]` with $k = 2$:
- reverse all: `[5,4,3,2,1]` — the last two are now at the front, but backwards
- reverse the first 2: `[4,5,3,2,1]` — front block fixed
- reverse the rest: `[4,5,1,2,3]` — done

Both versions were run and always agreed:

#code(lang: "text", caption: "Measured output")[
```text
k=0 [1,2,3,4,5] -> [1,2,3,4,5]  same? yes
k=1 [1,2,3,4,5] -> [5,1,2,3,4]  same? yes
k=2 [1,2,3,4,5] -> [4,5,1,2,3]  same? yes
k=5 [1,2,3,4,5] -> [1,2,3,4,5]  same? yes
k=7 [1,2,3,4,5] -> [4,5,1,2,3]  same? yes
k=2 [] -> []  same? yes
k=2 [9] -> [9]  same? yes
```
]

$k = 7$ gives the same answer as $k = 2$, because $7 mod 5 = 2$.
]
#trap[
`k %= n` must come *after* the empty check. In JavaScript `5 % 0` is `NaN`, not a crash, so
every later index becomes `NaN` and the array silently fills with `undefined`. A missing
guard here does not throw; it produces garbage.
]
#trap[
`[a[i], a[j]] = [a[j], a[i]]` is the JavaScript in-place swap. Writing
`a[i] = a[j]; a[j] = a[i];` destroys the first value — the classic beginner bug. The
destructuring version builds a small temporary array and unpacks it, so both values survive.
]
#note[
`a.slice(-k).concat(a.slice(0, -k))` is a one-line answer and is perfectly readable, but it
allocates two new arrays, so it is $O(n)$ *space*. The three-reversal version is the one to
show when the interviewer asks for $O(1)$ extra space.
]
]

#ex(15, tier: 1, asked: "TCS NQT · pattern")[
*Problem.* Find the largest sum of any non-empty contiguous block.
*Constraints.* $n <= 10^6$; values in $[-10^4, 10^4]$.
*Target.* $O(n)$.
*Edge cases.* one element; every value negative (the answer is the largest single value, not
0); a block of zeros.

#sol[
#approach(1, "Every start, every end", verdict: "O(n^2) after the obvious fix, O(n^3) if you
re-add each block")

#code(lang: "js", caption: "Brute force, already improved to O(n^2)")[
```js
const maxSubarrayBrute = (a) => {
  let best = -Infinity;
  for (let i = 0; i < a.length; i++) {
    let s = 0;
    for (let j = i; j < a.length; j++) { s += a[j]; best = Math.max(best, s); }
  }
  return best;
};
```
]

#approach(2, "Prefix sums and the smallest prefix so far", verdict: "O(n) — and it explains
the next one")

The sum of $a[l..r]$ is $p[r+1] - p[l]$. For a fixed right end $r$, the best choice of $l$ is
the one with the *smallest* $p[l]$ seen so far. So carry that minimum.

#code(lang: "js", caption: "Prefix view")[
```js
const maxSubarrayPrefix = (a) => {
  let best = -Infinity, run = 0, minPrefix = 0;
  for (const x of a) {
    run += x;                                  // run is p[r+1]
    best = Math.max(best, run - minPrefix);    // best block ending here
    minPrefix = Math.min(minPrefix, run);      // ready for the next r
  }
  return best;
};
```
]

#approach(3, "Kadane", verdict: "O(n), O(1) — the same idea, written shorter")

#code(lang: "js", caption: "Kadane's rule")[
```js
const kadane = (a) => {
  let best = a[0], cur = a[0];
  for (let i = 1; i < a.length; i++) {
    cur = Math.max(a[i], cur + a[i]);          // start fresh, or extend
    best = Math.max(best, cur);
  }
  return best;
};
```
]
#complexity(time: "O(n)", space: "O(1)")

All three, on the same inputs, plus 500 random cross-checks:

#code(lang: "text", caption: "Measured output")[
```text
[5] brute=5 prefix=5 kadane=5
[-5] brute=-5 prefix=-5 kadane=-5
[1,2,3] brute=6 prefix=6 kadane=6
[-2,1,-3,4,-1,2,1,-5,4] brute=6 prefix=6 kadane=6
[-3,-1,-7] brute=-1 prefix=-1 kadane=-1
[0,0] brute=0 prefix=0 kadane=0
[2,-1,2,-1,2] brute=4 prefix=4 kadane=4
500 random cross-checks passed
```
]

`[-3,-1,-7]` gives $-1$, not 0. A version that starts `best = 0` would wrongly say 0.

*The idea that unlocked it.* "Best block ending at $r$" is
$p[r+1] - min_(l <= r) p[l]$. Kadane's `cur = max(a[i], cur + a[i])` is exactly the same
sentence with the prefix array removed.
]
]

#ex(16, tier: 1, asked: "Amazon · pattern")[
*Problem.* Count the subarrays whose sum is exactly $k$. Values may be negative and may be
zero.
*Constraints.* $n <= 2 times 10^5$; values in $[-10^9, 10^9]$, so a prefix can reach
$2 times 10^14$ — still exact in a JavaScript number.
*Target.* $O(n)$.
*Edge cases.* empty array; $k = 0$ with an array of zeros (many answers); a single element
equal to $k$.

#sol[
#approach(1, "Every start, extend to the right", verdict: "O(n^2)")

#code(lang: "js", caption: "Brute force")[
```js
const countSubarraysBrute = (a, k) => {
  let cnt = 0;
  for (let i = 0; i < a.length; i++) {
    let s = 0;
    for (let j = i; j < a.length; j++) {
      s += a[j];
      if (s === k) cnt++;
    }
  }
  return cnt;
};
```
]
#complexity(time: "O(n^2)", space: "O(1)", note: "n = 2·10^5 gives 2·10^10 steps. Dies.")

#approach(2, "Count pairs of prefixes", verdict: "O(n) average — optimal")

$a[l..r]$ has sum $k$ exactly when $p[r+1] - p[l] = k$, that is $p[l] = p[r+1] - k$.

So walk the array once. At each right end, ask *how many earlier prefixes* had the value
`run - k`. Store the counts in a hash map.

#code(lang: "js", caption: "Prefix + Map — memorise this")[
```js
const countSubarraysFast = (a, k) => {
  const seen = new Map();
  seen.set(0, 1);                            // the empty prefix, p[0] = 0
  let run = 0, cnt = 0;
  for (const x of a) {
    run += x;
    cnt += seen.get(run - k) ?? 0;           // ?? 0 because get() gives undefined
    seen.set(run, (seen.get(run) ?? 0) + 1);
  }
  return cnt;
};
```
]
#complexity(time: "O(n) expected", space: "O(n)")

The Python version is shorter and says the same thing:

#code(lang: "python", caption: "Python")[
```python
from collections import defaultdict

def count_subarrays(a, k):
    seen = defaultdict(int)
    seen[0] = 1            # the empty prefix
    run = 0
    cnt = 0
    for x in a:
        run += x
        cnt += seen[run - k]
        seen[run] += 1
    return cnt
```
]

Both were run. Same answers, and 500 random cross-checks against the brute force:

#code(lang: "text", caption: "Measured output (JavaScript and Python agree)")[
```text
k=0 [] brute=0 fast=0
k=5 [5] brute=1 fast=1
k=0 [5] brute=0 fast=0
k=3 [1,2,3] brute=2 fast=2
k=0 [1,-1,1,-1] brute=4 fast=4
k=0 [0,0,0] brute=6 fast=6
k=1 [3,-1,-1,2] brute=2 fast=2
k=0 [-2,-3,5] brute=1 fast=1
500 random cross-checks passed
```
]

And the speed, on 30,000 random values in $[-5, 5]$ with $k = 3$:

#code(lang: "text", caption: "Measured output")[
```text
n=30000 brute=887614 fast=887614
brute time = 895 ms
fast  time = 3 ms
```
]

*The idea.* A subarray is a *pair of prefixes*. Once you see that, counting subarrays becomes
counting pairs, and counting pairs is what a `Map` does in $O(1)$ expected each.
]
#trap[
+ `seen.set(0, 1)` is not optional. Drop it and `[1,2,3]` with $k = 3$ returns 1 instead of
  2, because the subarray `[1,2]` starts at index 0.
+ A plain object instead of a `Map` breaks silently. Prefix sums go negative here, and
  `obj[-3]` stores under the string key `"-3"`. It happens to still work for this exact
  problem, but it stops working the moment you also need `0` and `-0` apart, or you iterate
  the keys. Use a `Map` and stop thinking about it.
+ `seen.get(...)` returns `undefined`, not `0`. Without `?? 0` the count becomes `NaN`, and
  `NaN` never equals anything, so no test will tell you where it went wrong.
+ A sliding window does *not* work here. Windows need the sum to grow when you extend, and
  negative values break that. Sliding windows are for non-negative values (Chapter 3).
]
]

#section[Tier 2 — Business-shaped variations]
#tier-header(2)

#ex(17, tier: 2, asked: "Grab · pattern")[
*Problem.* Daily profit or loss figures for $n$ days. Count the periods (contiguous blocks of
days) whose total is divisible by $k$.
*Constraints.* $n <= 2 times 10^5$, $2 <= k <= 10^4$; values may be negative.
*Target.* $O(n + k)$.
*Edge cases.* empty array; a block summing to exactly 0 (0 is divisible by everything);
negative sums, where JavaScript's `%` returns a negative remainder.

#sol[
#approach(1, "Every block", verdict: "O(n^2)")

#approach(2, "Count prefixes by remainder", verdict: "O(n + k) — optimal")

$"sum"(l..r) = p[r+1] - p[l]$ is divisible by $k$ exactly when $p[r+1]$ and $p[l]$ leave the
*same remainder* mod $k$. So group the prefixes by remainder and count pairs inside each
group.

Since remainders are $0..k-1$, a plain array of size $k$ replaces the `Map`.

#code(lang: "js", caption: "Remainder counting")[
```js
const divisibleFast = (a, k) => {
  const cntMod = new Array(k).fill(0);
  cntMod[0] = 1;                         // the empty prefix has remainder 0
  let run = 0, ans = 0;
  for (const x of a) {
    run += x;
    const m = ((run % k) + k) % k;       // force a non-negative remainder
    ans += cntMod[m];
    cntMod[m]++;
  }
  return ans;
};
```
]
#complexity(time: "O(n + k)", space: "O(k)")

Checked against the brute force, and on 500 random arrays:

#code(lang: "text", caption: "Measured output")[
```text
k=3 [] brute=0 fast=0
k=3 [6] brute=1 fast=1
k=3 [1] brute=0 fast=0
k=2 [2,-2,2,-4] brute=10 fast=10
k=2 [-1,2,9] brute=2 fast=2
k=5 [5,0,0,5] brute=10 fast=10
k=5 [1,2,3,4,5] brute=4 fast=4
500 random cross-checks passed
-7 % 3 in JS = -1  fixed = 2
```
]
]
#trap[
Read the last measured line. In JavaScript, `-7 % 3` is $-1$, not 2 — the sign follows the
*left* operand, exactly as in C++ and Java. In JavaScript the damage is quieter than a crash:
`cntMod[-1]` is `undefined`, `ans += undefined` makes `ans` become `NaN`, and `NaN` spreads
through the rest of the run without any error. Always write `((run % k) + k) % k`. Python is
the odd one out here — `-7 % 3` is `2` there, so a Python solution ported straight to
JavaScript will fail on exactly the negative test cases.
]
]

#ex(18, tier: 2, asked: "Shopee · pattern")[
*Problem.* Find the *longest* block whose sum is exactly $k$. Report its length, or 0 if
there is none.
*Constraints.* $n <= 2 times 10^5$; values may be negative.
*Target.* $O(n)$.
*Edge cases.* no such block; the whole array works; several blocks of the same length.

#sol[
#approach(1, "Every block", verdict: "O(n^2)")

#approach(2, "Prefix + map of the EARLIEST index", verdict: "O(n) — optimal")

The counting version (Example 16) stored *how many* prefixes had each value. For the longest
block we instead store *the first index* at which each prefix value appeared — because the
earlier the left end, the longer the block.

#code(lang: "js", caption: "Keep the earliest position")[
```js
const longestFast = (a, k) => {
  const firstAt = new Map();          // prefix value -> earliest index in p
  firstAt.set(0, 0);
  let run = 0, best = 0;
  for (let i = 0; i < a.length; i++) {
    run += a[i];
    if (firstAt.has(run - k)) best = Math.max(best, i + 1 - firstAt.get(run - k));
    if (!firstAt.has(run)) firstAt.set(run, i + 1);   // only the first time
  }
  return best;
};
```
]
#complexity(time: "O(n) expected", space: "O(n)")

#code(lang: "text", caption: "Measured output")[
```text
k=0 [] brute=0 fast=0
k=4 [4] brute=1 fast=1
k=5 [4] brute=0 fast=0
k=3 [1,2,3,0,0,4] brute=3 fast=3
k=0 [-1,1,-1,1] brute=4 fast=4
k=2 [2,-2,2,-2,2] brute=5 fast=5
k=5 [1,1,1] brute=0 fast=0
500 random cross-checks passed
```
]

Check `[1,2,3,0,0,4]` with $k = 3$: the blocks summing to 3 are `[1,2]` (length 2), `[3]`
(length 1), and `[3,0,0]` (length 3). The longest is 3.
]
#trap[
*Counting* wants every occurrence; *longest* wants only the first. Drop the `if
(!firstAt.has(run))` guard and `firstAt.set` will overwrite the earliest index with a later
one, shortening your own answer. This one line is the difference between the two problems.
]
#note[
Use `.has()` here, not `.get(...) !== undefined`. A prefix value of `0` is a perfectly real
key, and `firstAt.get(0)` returns the index `0`, which is falsy. Writing
`if (firstAt.get(run - k))` would skip exactly the case the seed entry exists for.
]
]

#ex(19, tier: 2, asked: "Sea/Shopee · pattern")[
*Problem.* A log of $n$ events, each a success (1) or a failure (0). Count the blocks with
an equal number of successes and failures.
*Constraints.* $n <= 2 times 10^5$.
*Target.* $O(n)$.
*Edge cases.* all 1s (answer 0); a single event; the whole log balanced.

#sol[
The trick is a re-labelling. Treat 1 as $+1$ and 0 as $-1$. Now "equal counts" means "the
block sums to 0", and Example 16 already solves that with $k = 0$.

#code(lang: "js", caption: "Re-label, then count sum-zero blocks")[
```js
const equalZeroOne = (a) => {
  const seen = new Map();
  seen.set(0, 1);
  let run = 0, cnt = 0;
  for (const x of a) {
    run += (x === 1 ? 1 : -1);               // 1 counts +1, 0 counts -1
    cnt += seen.get(run) ?? 0;
    seen.set(run, (seen.get(run) ?? 0) + 1);
  }
  return cnt;
};
```
]
#complexity(time: "O(n)", space: "O(n)")

#code(lang: "text", caption: "Measured output")[
```text
[] brute=0 fast=0
[0] brute=0 fast=0
[0,1] brute=1 fast=1
[1,0] brute=1 fast=1
[0,0,1,1] brute=2 fast=2
[1,1,1] brute=0 fast=0
[0,1,0,1,0] brute=6 fast=6
500 random cross-checks passed
```
]

#trap[
`run` goes negative here — it is a walk up and down from zero. That makes the `Map` choice
load-bearing: with a plain object the key $-1$ becomes the string `"-1"`, and it only takes
one place elsewhere in your code that compares a key against a number for the whole thing to
quietly disagree with itself.
]

Check `[0,0,1,1]`: the balanced blocks are `[0,1]` (positions 1--2) and the whole array. That
is 2.

*The idea.* Do not invent a new algorithm. Change the data so an old algorithm fits. "Equal
counts of two things" is almost always "sum to zero after re-labelling".
]
#trick[
The same trick solves "equal numbers of vowels and consonants", "equal numbers of even and
odd", and "equal numbers of opening and closing brackets, ignoring validity". Map one kind to
$+1$ and the other to $-1$.
]
]

#ex(20, tier: 2, asked: "Agoda · pattern")[
*Problem.* A grid of $R times C$ nightly room prices (rows are hotels, columns are nights).
Answer $q$ questions: "total price over hotels $r_1..r_2$ and nights $c_1..c_2$".
*Constraints.* $R, C <= 1000$, $q <= 2 times 10^5$.
*Target.* $O(R C + q)$.
*Edge cases.* a $1 times 1$ rectangle; the whole grid; a rectangle touching row 0 or
column 0.

#sol[
#approach(1, "Add up the rectangle each time", verdict: "O(R C) per query — 2·10^11 total")

#approach(2, "2-D prefix sums", verdict: "O(R C) build, O(1) per query — optimal")

#code(lang: "js", caption: "Build and query")[
```js
const buildGrid2D = (g) => {
  const R = g.length, C = R ? g[0].length : 0;
  // Array.from with a FUNCTION: each row must be its own array
  const p = Array.from({length: R + 1}, () => new Array(C + 1).fill(0));
  for (let i = 0; i < R; i++)
    for (let j = 0; j < C; j++)
      p[i+1][j+1] = g[i][j] + p[i][j+1] + p[i+1][j] - p[i][j];
  return (r1, c1, r2, c2) =>
    p[r2+1][c2+1] - p[r1][c2+1] - p[r2+1][c1] + p[r1][c1];
};
```
]
#complexity(time: "O(R C) build, O(1) per query", space: "O(R C)")

#trap[
*Never build a 2-D array with `new Array(R + 1).fill(new Array(C + 1).fill(0))`.* `fill` puts
*the same row object* in every slot, so writing `p[1][1] = 5` also changes `p[0][1]`,
`p[2][1]` and every other row. Use `Array.from({length: R + 1}, () => new Array(C + 1).fill(0))`,
which calls the function once per row and therefore builds $R+1$ separate arrays.

The same trap bites when copying. Tested in Node: with `grid = [[1,2],[3,4]]`,
`const shallow = [...grid]; shallow[0][0] = 99;` leaves the *original* as `[[99,2],[3,4]]`.
The correct deep copy of a grid of numbers is `grid.map(row => [...row])`, after which the
original still prints `[[1,2],[3,4]]`.
]

Why four terms? $p[r_2+1][c_2+1]$ is everything above and left of the bottom-right corner.
Subtract the strip above the rectangle and the strip to its left. The top-left corner block
was inside *both* strips, so it has been removed twice — add it back once.

Run on this grid:

#code(lang: "text", caption: "The grid and its prefix table")[
```text
grid:                 prefix table p:
  1   2   3   4          0   0   0   0   0
  5   6   7   8          0   1   3   6  10
 -1   0   2   1          0   6  14  24  36
  3   3   3   3          0   5  13  25  38
                         0   8  19  34  50
```
]

#code(lang: "text", caption: "Measured output")[
```text
query(0,0,3,3) = 50  brute=50
query(1,1,2,2) = 15  brute=15
query(0,0,0,0) = 1  brute=1
query(2,0,2,3) = 2  brute=2
query(3,3,3,3) = 3  brute=3
1x1 grid: 9
after [...grid] edit, original is [[99,2],[3,4]]
after map(r=>[...r]) edit, original is [[1,2],[3,4]]
```
]

Check `query(1,1,2,2)` by hand: the values are $6, 7, 0, 2$, total 15. The formula gives
$p[3][3] - p[1][3] - p[3][1] + p[1][1] = 25 - 6 - 5 + 1 = 15$. Correct.
]
#trap[
Memory. Every JavaScript number is 8 bytes, so a $1000 times 1000$ prefix table is 8 MB,
which is fine. A $10^5 times 10^5$ grid is 80 GB and is not storable at all — check
$R times C$ against the memory limit before you build.
]
]

#ex(21, tier: 2, asked: "LINE MAN · pattern")[
*Problem.* A delivery zone has $n$ time slots, all starting at 0 riders. You receive $m$
bookings, each "add $v$ riders to every slot from $l$ to $r$". Print the final rider count of
every slot.
*Constraints.* $n, m <= 10^6$.
*Target.* $O(n + m)$.
*Edge cases.* a booking covering one slot; a booking covering everything; a negative $v$
(a cancellation).

#sol[
#approach(1, "Loop over the range for every booking", verdict: "O(n m) = 10^12 — hopeless")

#approach(2, "Difference array", verdict: "O(1) per booking, O(n) at the end — optimal")

Record only the *edges* of each booking. Adding $v$ at $l$ and $-v$ at $r+1$ means: "from
here on, $v$ more", then "from here on, $v$ less". Take the prefix sum at the end and every
slot gets its true value.

#code(lang: "js", caption: "Difference array")[
```js
const makeDiff = (n) => {
  const d = new Array(n + 1).fill(0);        // one extra slot for r+1
  return {
    add: (l, r, v) => { d[l] += v; d[r + 1] -= v; },
    finish: () => {
      const a = new Array(n);
      let run = 0;
      for (let i = 0; i < n; i++) { run += d[i]; a[i] = run; }
      return a;
    },
  };
};
```
]
#complexity(time: "O(n + m)", space: "O(n)")

Three bookings on 8 slots: `add(0,3,5)`, `add(2,5,-2)`, `add(7,7,100)`.

#code(lang: "text", caption: "Measured output")[
```text
after 3 range updates: 5 5 3 3 -2 -2 0 100
brute result        : 5 5 3 3 -2 -2 0 100
match? yes
n=1: -7
```
]

Follow slot 2: the first booking added 5, the second subtracted 2, so $5 - 2 = 3$. The
output says 3.

*The idea.* A prefix sum turns "many point marks" into "a filled range". It is the exact
reverse of the range-query trick, and the two are used together constantly.
]
#trap[
The array must have $n + 1$ slots. `d[r + 1]` with $r = n - 1$ writes to index $n$. In C++
that is an out-of-range write that corrupts memory. In JavaScript it is worse in a different
way: `d[n] += v` on an array of length $n$ *silently grows the array to length $n+1$* and
succeeds. Nothing complains, the `finish` loop stops at $n$ anyway, and the code happens to
work — until the day you write `for (let i = 0; i < d.length; i++)` and pick up a phantom
extra slot. Size it correctly on purpose, not by accident.
]
]

#ex(22, tier: 2, asked: "SCB · pattern")[
*Problem.* All values are positive. Find the *shortest* block whose sum is at least $S$.
Return 0 if none exists.
*Constraints.* $n <= 2 times 10^5$; values in $[1, 10^4]$; $S <= 10^9$.
*Target.* $O(n log n)$ or better.
*Edge cases.* no block is large enough; one element already reaches $S$; the whole array is
needed.

#sol[
#approach(1, "Every start, extend until the sum reaches S", verdict: "O(n^2) worst case")

#approach(2, "Prefix + binary search", verdict: "O(n log n)")

With all values positive, the prefix array is *strictly increasing*. That means we can binary
search it. For a left end $l$, we want the smallest index $j$ with $p[j] >= p[l] + S$.

JavaScript has no built-in binary search, so use `lowerBound` from the *JS Toolkit* appendix.
`lowerBound(p, x)` returns the index of the first value that is $>= x$, and `p.length` when
no such value exists.

#code(lang: "js", caption: "lowerBound on the prefix array")[
```js
const { lowerBound } = require('./toolkit.js');   // JS Toolkit appendix

const shortestBinary = (a, S) => {
  const n = a.length;
  const p = new Array(n + 1).fill(0);
  for (let i = 0; i < n; i++) p[i + 1] = p[i] + a[i];
  let best = Infinity;
  for (let l = 0; l < n; l++) {
    const j = lowerBound(p, p[l] + S);   // first index with p[j] >= p[l] + S
    if (j <= n) best = Math.min(best, j - l);
  }
  return best === Infinity ? 0 : best;
};
```
]
#complexity(time: "O(n log n)", space: "O(n)")

#code(lang: "text", caption: "Measured output")[
```text
S=5 [] brute=0 binary=0
S=5 [5] brute=1 binary=1
S=5 [4] brute=0 binary=0
S=7 [2,3,1,2,4,3] brute=2 binary=2
S=4 [1,1,1,1] brute=4 binary=4
S=5 [1,1,1,1] brute=0 binary=0
S=1 [10] brute=1 binary=1
500 random cross-checks passed
```
]

Check `[2,3,1,2,4,3]` with $S = 7$: the block `[4,3]` sums to 7 with length 2. Nothing of
length 1 reaches 7. So the answer is 2.
]
#note[
Searching the *whole* `p` is safe here, not just the part after `l`. Every value is positive,
so `p` is strictly increasing and `p[l] + S > p[l]`, which means the answer index is always
greater than `l`. If zeros were allowed you would have to search from `l + 1`.
]
#note[
A two-pointer window also solves this in $O(n)$ — but *only* because the values are positive.
That is Chapter 3. The binary search version is worth knowing because it still works when
you must answer for many different values of $S$.
]
]

#ex(23, tier: 2, asked: "Razer · pattern")[
*Problem.* Return an array `out` where `out[i]` is the product of every value except `a[i]`.
Division is not allowed.
*Constraints.* $n <= 10^5$; values in $[-1000, 1000]$, zeros allowed; every answer is
guaranteed to stay inside the exact range of a JavaScript number, $2^53 - 1$.
*Target.* $O(n)$ time, $O(1)$ extra space (the output array does not count).
*Edge cases.* one zero in the array; two zeros; a single element; negative values.

#sol[
#approach(1, "For each i, multiply everything else", verdict: "O(n^2)")

#approach(2, "Prefix products, then suffix products", verdict: "O(n) — optimal")

`out[i]` is (product of everything to the left) $times$ (product of everything to the right).
Do one left-to-right pass writing the left product, then one right-to-left pass multiplying
in the right product. The running product doubles as the storage, so no second array is
needed.

#code(lang: "js", caption: "Two passes, no division")[
```js
const productExceptSelf = (a) => {
  const n = a.length;
  const out = new Array(n).fill(1);
  let run = 1;
  for (let i = 0; i < n; i++) { out[i] = run; run *= a[i]; }        // left side
  run = 1;
  for (let i = n - 1; i >= 0; i--) { out[i] *= run; run *= a[i]; }  // right side
  return out;
};
```
]
#complexity(time: "O(n)", space: "O(1) beyond the output")

The Python version:

#code(lang: "python", caption: "Python")[
```python
def product_except_self(a):
    n = len(a)
    out = [1] * n
    run = 1
    for i in range(n):
        out[i] = run
        run *= a[i]
    run = 1
    for i in range(n - 1, -1, -1):
        out[i] *= run
        run *= a[i]
    return out
```
]

Both were run against the $O(n^2)$ version:

#code(lang: "text", caption: "Measured output")[
```text
[] -> []
[5] -> [1]
[1,2,3,4] -> [24,12,8,6]
[0,2,3] -> [6,0,0]
[0,0,3] -> [0,0,0]
[-1,2,-3] -> [-6,3,-2]
[100000,100000,3] -> [300000,300000,10000000000]
500 random cross-checks passed
20 copies of 1000, out[0] = 1e+57 safe? false
```
]

The zero cases come out right with no special handling at all: with one zero, only that
position gets a non-zero answer; with two zeros, everything is zero. The line
`[100000,100000,3]` reaches $10^10$, which is still exact in JavaScript.

*The idea.* "Everything except me" always splits into "everything before me" and "everything
after me". That is prefix and suffix, whatever the operation is.
]
#trap[
The tempting solution is "compute the total product, then divide by `a[i]`". It is banned
here for a reason: it breaks on a zero (division by zero gives `Infinity` in JavaScript, not
an error), and it silently gives wrong answers when two zeros exist.
]
#trap[
Read the last measured line. Twenty copies of 1000 make a product of $10^57$, and JavaScript
prints it as `1e+57` — a float, not an integer, and `Number.isSafeInteger` says `false`. The
digits past the 16th are gone. Products run out of exact range *much* faster than sums do,
so whenever a problem does not promise the answer fits, switch the running value to `BigInt`:
`let run = 1n;` and `run *= BigInt(a[i])`.
]
]

#section[Tier 3 — Insight, then the follow-up]
#tier-header(3)

#ex(24, tier: 3, asked: "Amazon · pattern")[
*Problem.* The array is *circular*: the block may wrap from the end back to the start. Find
the largest block sum. The block must be non-empty and may not use any element twice.
*Constraints.* $n <= 10^5$; values in $[-10^4, 10^4]$.
*Target.* $O(n)$.
*Edge cases.* every value negative; one element; a block that uses the whole array.

#sol[
There are exactly two shapes of answer.

+ *The block does not wrap.* That is plain Kadane (Example 15).
+ *The block wraps.* Then the elements it does *not* use form one ordinary block in the
  middle. So the wrapping answer is $"total" - ("smallest ordinary block sum")$.

Run Kadane twice, once for the maximum and once for the minimum, and take the better of the
two shapes.

#code(lang: "js", caption: "Circular maximum")[
```js
const kadaneMax = (a) => {
  let best = a[0], cur = a[0];
  for (let i = 1; i < a.length; i++) { cur = Math.max(a[i], cur + a[i]); best = Math.max(best, cur); }
  return best;
};
const kadaneMin = (a) => {
  let best = a[0], cur = a[0];
  for (let i = 1; i < a.length; i++) { cur = Math.min(a[i], cur + a[i]); best = Math.min(best, cur); }
  return best;
};

const circularMax = (a) => {
  if (a.length === 0) return 0;
  let total = 0;
  for (const x of a) total += x;
  const straight = kadaneMax(a);
  const minPart  = kadaneMin(a);
  if (minPart === total) return straight;   // every element is in the min block
  return Math.max(straight, total - minPart);
};
```
]
#complexity(time: "O(n)", space: "O(1)")

Checked against a brute force over all $n$ starts and all $n$ lengths, plus 800 random
arrays:

#code(lang: "text", caption: "Measured output")[
```text
[5] brute=5 fast=5
[-5] brute=-5 fast=-5
[1,-2,3,-2] brute=3 fast=3
[5,-3,5] brute=10 fast=10
[-3,-2,-4] brute=-2 fast=-2
[3,1,3,-9,2] brute=9 fast=9
[0,0] brute=0 fast=0
800 random cross-checks passed
```
]

Check `[5,-3,5]`: the wrapping block is $5 + 5 = 10$, taken by removing the middle $-3$.
$"total" - "minPart" = 7 - (-3) = 10$. Correct.

Check `[-3,-2,-4]`: every value is negative, so the minimum block is the whole array and
$"total" - "minPart" = 0$, which would mean an *empty* block. The guard
`if (minPart === total)` catches exactly this and returns $-2$.
]
#trap[
The wrapping index arithmetic in the brute force uses `a[(s + len - 1) % n]`. That is safe
because `s` and `len` are both non-negative. If you ever step *backwards* around a circle,
write `((i % n) + n) % n` — a bare `%` on a negative index gives a negative number and
`a[-1]` is `undefined` in JavaScript, not an error.
]

#subsection[The follow-up]

*"Return the start and end indices too."* Track the index where `cur` restarted inside
Kadane, and remember it whenever `best` improves. For the wrapping case, the answer is the
*complement* of the minimum block, so it runs from `minEnd + 1` to `minStart - 1` (mod $n$).

*"What if the block must have length at most $L$?"* Then the two-Kadane trick fails, and you
need the prefix-plus-deque method of Example 28.
]

#ex(25, tier: 3, asked: "Google · pattern")[
*Problem.* Count the subarrays whose XOR equals $k$.
*Constraints.* $n <= 2 times 10^5$; values in $[0, 2^20)$.
*Target.* $O(n)$.
*Edge cases.* $k = 0$ (blocks that XOR to zero); an array of zeros; a single element equal to
$k$.

#sol[
XOR is its own inverse: $x xor x = 0$. So a prefix XOR behaves exactly like a prefix sum,
with "minus" replaced by "XOR".

Define $P[0] = 0$ and $P[i+1] = P[i] xor a[i]$. Then
$ "XOR of " a[l..r] = P[r+1] xor P[l] $
We want that to equal $k$. XOR both sides by $P[r+1]$:
$ P[l] = P[r+1] xor k $
Same shape as Example 16, so the same code works with `-` swapped for `^`.

#code(lang: "js", caption: "Prefix XOR + Map")[
```js
const xorCountFast = (a, k) => {
  const seen = new Map();
  seen.set(0, 1);
  let run = 0, cnt = 0;
  for (const x of a) {
    run ^= x;
    cnt += seen.get(run ^ k) ?? 0;
    seen.set(run, (seen.get(run) ?? 0) + 1);
  }
  return cnt;
};
```
]
#complexity(time: "O(n) expected", space: "O(n)")

#code(lang: "text", caption: "Measured output")[
```text
k=0 [] brute=0 fast=0
k=4 [4] brute=1 fast=1
k=0 [4] brute=0 fast=0
k=5 [5,6,7,8,9] brute=2 fast=2
k=0 [0,0,0] brute=6 fast=6
k=0 [1,1,1,1] brute=4 fast=4
k=3 [3,3,3] brute=4 fast=4
500 random cross-checks passed
```
]

Check `[3,3,3]` with $k = 3$: the blocks are `[3]` three times, and `[3,3,3]` whose XOR is
$3 xor 3 xor 3 = 3$. That is 4.
]
#trap[
This works only because the constraint says values are below $2^20$. JavaScript's `^`
converts to a 32-bit signed integer first, so every prefix XOR also stays below $2^20$ and
nothing is lost. If values could reach $2^31$, `run ^= x` would start producing *negative*
numbers, and past $2^32$ the high bits would vanish entirely. Above 32 bits the only correct
option is `BigInt` XOR, which is far slower — check the constraint before you type `^`.
]

#subsection[The follow-up]

*"Now find the maximum XOR of any subarray."* Counting will not help; you need the *largest*
$P[r+1] xor P[l]$ over all pairs. Put every prefix XOR into a binary trie, one bit at a time
from the top, and for each new prefix walk the trie choosing the opposite bit whenever it
exists. That is $O(n times 20)$ for 20-bit values.

*"Why does a sliding window not work for XOR?"* Because XOR is not monotonic: extending a
window can make the value smaller *or* bigger, so there is no rule for when to shrink. Every
subarray-XOR problem is a prefix-pair problem.
]

#ex(26, tier: 3, asked: "Microsoft · pattern")[
*Problem.* A grid of $R times C$ cells starts at 0. Apply $m$ updates of the form "add $v$ to
every cell of the rectangle $(r_1, c_1)$ to $(r_2, c_2)$". Print the final grid.
*Constraints.* $R, C <= 1000$, $m <= 10^5$.
*Target.* $O(R C + m)$.
*Edge cases.* a rectangle of one cell; a rectangle touching the last row or column; a
negative $v$.

#sol[
#approach(1, "Fill each rectangle", verdict: "O(m R C) = 10^11 — dies")

#approach(2, "2-D difference array", verdict: "O(m) per update, O(R C) at the end")

In one dimension we marked two edges. In two dimensions we mark four corners, with the same
inclusion--exclusion signs as the 2-D prefix query.

#code(lang: "js", caption: "Four corner marks")[
```js
// d is (R+1) x (C+1), built with Array.from so every row is its own array
const d = Array.from({length: R + 1}, () => new Array(C + 1).fill(0));

const addRect = (d, r1, c1, r2, c2, v) => {
  d[r1][c1]         += v;
  d[r1][c2 + 1]     -= v;
  d[r2 + 1][c1]     -= v;
  d[r2 + 1][c2 + 1] += v;
};
```
]

Then sweep the whole grid once with a 2-D prefix sum to turn the marks into values:

#code(lang: "js", caption: "The final sweep")[
```js
const g = Array.from({length: R}, () => new Array(C).fill(0));
for (let i = 0; i < R; i++)
  for (let j = 0; j < C; j++) {
    const up   = i > 0 ? g[i-1][j] : 0;
    const left = j > 0 ? g[i][j-1] : 0;
    const diag = (i > 0 && j > 0) ? g[i-1][j-1] : 0;
    g[i][j] = d[i][j] + up + left - diag;
  }
```
]
#complexity(time: "O(m + R C)", space: "O(R C)")

#note[
The `i > 0 ? ... : 0` guards are needed in JavaScript for a different reason than in C++.
`g[-1]` does not crash — it is simply `undefined` — and then `undefined[j]` *does* throw
`TypeError: Cannot read properties of undefined`. So you get an exception, just one whose
message points at the wrong thing. Write the guards.
]

Three updates on a $5 times 6$ grid: `add(0,0,2,2,+1)`, `add(1,1,4,5,+10)`,
`add(4,5,4,5,-3)`.

#code(lang: "text", caption: "Measured output")[
```text
difference-array grid:
   1   1   1   0   0   0
   1  11  11  10  10  10
   1  11  11  10  10  10
   0  10  10  10  10  10
   0  10  10  10  10   7
match brute? yes
```
]

Read cell $(1,1)$: it is inside the first rectangle ($+1$) and the second ($+10$), so 11.
Cell $(4,5)$ is inside the second ($+10$) and the third ($-3$), so 7. Both match.
]

#subsection[The follow-up]

*"Now the updates and the queries are mixed — a query can come between two updates."* The
difference array only works when *all* updates come first. Mixed updates and queries need a
2-D Fenwick tree, at $O(log R log C)$ each.

*"Now it is three dimensions."* The same idea, with $2^3 = 8$ corner marks and alternating
signs. In $d$ dimensions it is $2^d$ marks, which is why nobody does this past three.
]

#ex(27, tier: 3, asked: "D. E. Shaw · pattern")[
*Problem.* Count the subarrays whose sum lies in the range $[L, R]$. Values may be negative.
*Constraints.* $n <= 10^5$; values in $[-10^9, 10^9]$.
*Target.* $O(n log n)$.
*Edge cases.* empty array; $L = R$ (Example 16 as a special case); every sum out of range.

#sol[
The sum of $a[l..r]$ is $p[r+1] - p[l]$, so we need
$ L <= p[r+1] - p[l] <= R quad arrow.l.r.double quad p[r+1] - R <= p[l] <= p[r+1] - L $

For each right end, that is a *count of earlier prefixes inside a value range*. A `Map`
cannot answer range questions, and JavaScript has no ordered map at all. A Fenwick tree
(binary indexed tree) over the compressed prefix values can, in $O(log n)$.

#code(lang: "js", caption: "Fenwick tree of counts")[
```js
class Fenwick {
  constructor(n) { this.t = new Array(n + 1).fill(0); }
  add(i)  { for (i++; i < this.t.length; i += i & -i) this.t[i]++; }
  upto(i) { let s = 0; for (i++; i > 0; i -= i & -i) s += this.t[i]; return s; }
  range(l, r) {
    if (r < l) return 0;
    return this.upto(r) - (l ? this.upto(l - 1) : 0);
  }
}
```
]

#code(lang: "js", caption: "The count itself")[
```js
const { lowerBound, upperBound } = require('./toolkit.js');   // JS Toolkit appendix

const countInRangeFast = (a, L, R) => {
  const n = a.length;
  const p = new Array(n + 1).fill(0);
  for (let i = 0; i < n; i++) p[i + 1] = p[i] + a[i];

  // coordinate compression: Set removes duplicates, sort orders them
  const sorted = [...new Set(p)].sort((x, y) => x - y);

  const bit = new Fenwick(sorted.length);
  let cnt = 0;
  bit.add(lowerBound(sorted, p[0]));
  for (let r = 1; r <= n; r++) {
    const lo = p[r] - R, hi = p[r] - L;
    cnt += bit.range(lowerBound(sorted, lo), upperBound(sorted, hi) - 1);
    bit.add(lowerBound(sorted, p[r]));
  }
  return cnt;
};
```
]
#complexity(time: "O(n log n)", space: "O(n)")

Checked against the $O(n^2)$ brute force on hand tests and 800 random arrays:

#code(lang: "text", caption: "Measured output")[
```text
[2,-1,3,-4,5] with L=1,R=4 : brute=8 fast=8
empty: 0
single in range: 1   out of range: 0
800 random cross-checks passed
```
]

*The idea.* Example 16 needed "how many earlier prefixes equal $x$" — a `Map`. This
problem needs "how many earlier prefixes lie between $x$ and $y$" — an *ordered* structure.
Recognising which of the two questions you are being asked is the whole difficulty.
]
#trap[
`[...new Set(p)].sort((x, y) => x - y)` is the JavaScript idiom for "sort and remove
duplicates". The comparator is not optional: `new Set([10, 9, 1])` spread and sorted with a
bare `.sort()` gives `[1, 10, 9]`, `lowerBound` then binary-searches a list that is not in
order, and every count comes out wrong with no error. This is the chapter's most expensive
place to forget the comparator.
]
#trap[
Fenwick trees use `i & -i` to isolate the lowest set bit. That is a 32-bit operation in
JavaScript, which is fine for array indexes but a reminder of the rule: bitwise operators
here are 32-bit. The stored *values* go through `+`, not `&`, so they stay exact to $2^53-1$.
]

#subsection[The follow-up]

*"What if all the values are positive?"* Then the prefix array is increasing, and the answer
is (number of subarrays with sum $<= R$) minus (number with sum $<= L-1$), each computed with
a two-pointer window in $O(n)$. Total $O(n)$, no Fenwick tree at all. The extra constraint
buys a whole log factor.

*"Do it without a Fenwick tree."* A merge sort that counts, while merging, how many left-half
prefixes fall in each range. Same $O(n log n)$, and it is the same counting-inversions
technique.
]

#ex(28, tier: 3, asked: "Uber · pattern")[
*Problem.* Find the largest block sum, but the block may contain at most $L$ elements.
*Constraints.* $n <= 10^5$, $1 <= L <= n$; values may be negative.
*Target.* $O(n)$.
*Edge cases.* $L = 1$ (the largest single value); $L = n$ (plain Kadane); all values
negative.

#sol[
#approach(1, "Every start, extend up to L", verdict: "O(n L) — 10^10 at the limits")

#approach(2, "Prefix + a sliding minimum", verdict: "O(n) — optimal")

The sum ending at $r$ with length at most $L$ is $p[r] - p[l]$ where
$r - L <= l <= r - 1$. So for each $r$ we need the *minimum prefix inside a sliding window of
width $L$*.

A monotonic deque keeps that minimum in $O(1)$ amortised: the deque holds indices whose
prefix values increase from front to back. The front is always the window's minimum.

*JavaScript has no deque.* An array's `push`/`pop` are $O(1)$, but `shift` moves every
remaining element, which turns this $O(n)$ algorithm into $O(n^2)$. Use the toolkit `Deque`,
which keeps a head index instead of moving anything.

#code(lang: "js", caption: "Prefix + monotonic deque")[
```js
const { Deque } = require('./toolkit.js');   // JS Toolkit appendix

const bestAtMostL = (a, L) => {
  const n = a.length;
  if (n === 0 || L <= 0) return null;
  const p = new Array(n + 1).fill(0);
  for (let i = 0; i < n; i++) p[i + 1] = p[i] + a[i];

  const dq = new Deque();                  // holds indices into p
  let best = -Infinity;
  dq.push(0);
  for (let r = 1; r <= n; r++) {
    while (dq.size && dq.front() < r - L) dq.shift();       // too far left
    best = Math.max(best, p[r] - p[dq.front()]);            // front = smallest
    while (dq.size && p[dq.back()] >= p[r]) dq.pop();       // p[r] is better
    dq.push(r);
  }
  return best;
};
```
]
#complexity(time: "O(n)", space: "O(n)",
  note: "Each index enters and leaves the deque once, so the inner whiles are O(1) amortised.")

Checked against the brute force for every $L$, plus 800 random arrays:

#code(lang: "text", caption: "Measured output on [2,-1,4,-6,3,3,-2,5]")[
```text
L=1 brute=5 deque=5
L=2 brute=6 deque=6
L=3 brute=6 deque=6
L=4 brute=9 deque=9
L=5 brute=9 deque=9
L=6 brute=9 deque=9
L=7 brute=9 deque=9
L=8 brute=9 deque=9
all negative, L=2: -2 -2
single: 6
800 random cross-checks passed
```
]

#trap[
`while (dq.size && ...)` works because `size` is `0` when the deque is empty, and `0` is
falsy. Do *not* write `while (dq.size() && ...)` — in the toolkit `size` is a getter, not a
method, and calling it throws `TypeError: dq.size is not a function`. Read the toolkit's
signatures before you use it.
]

Check $L = 2$: the best block of length at most 2 is `[3,3]`, which is 6. And $L = 4$ finds
`[3,3,-2,5]`, which is 9.
]

#subsection[The follow-up]

*"Why a deque and not a heap?"* A heap gives the minimum in $O(log n)$ but cannot cheaply
remove a value that has left the window. The deque throws away, forever, any index that a
newer index beats — because an older, larger prefix can never again be the answer while a
newer, smaller one is in the window. That is the invariant to say out loud.

*"Now the block must have length at least $L$."* Easier: keep a running minimum of
$p[0..r-L]$ as a single variable, no deque needed. One-sided windows do not need one.
]

#ex(29, tier: 3, asked: "Goldman Sachs · pattern")[
*Problem.* Range sums on an array of $n$ values, but now some queries *change* a single
value. Mixed in any order: $q$ operations, each either "add $v$ to `a[i]`" or "sum of
$a[l..r]$".
*Constraints.* $n, q <= 2 times 10^5$.
*Target.* $O((n + q) log n)$.
*Edge cases.* an update at index 0; an update at the last index; a query right after an
update.

#sol[
*Why the chapter's main tool breaks.* Changing `a[i]` changes $p[j]$ for *every* $j > i$.
Rebuilding is $O(n)$ per update, so $q$ updates cost $O(n q) = 4 times 10^10$.

#table(columns: 4,
  align: (left, left, left, left),
  [*Structure*], [*Build*], [*Query*], [*Point update*],
  [Plain array], [$O(1)$], [$O(n)$], [$O(1)$],
  [Prefix sums], [$O(n)$], [$O(1)$], [$O(n)$ — rebuild],
  [Fenwick tree], [$O(n log n)$], [$O(log n)$], [$O(log n)$],
)

A Fenwick tree keeps partial sums over power-of-two sized blocks, so one update touches only
$log_2 n$ of them.

#code(lang: "js", caption: "Fenwick tree of sums")[
```js
class FenwickSum {
  constructor(n) { this.n = n; this.t = new Array(n + 1).fill(0); }
  add(i, v) { for (i++; i <= this.n; i += i & -i) this.t[i] += v; }
  upto(i)   { let s = 0; for (i++; i > 0; i -= i & -i) s += this.t[i]; return s; }
  range(l, r) { return this.upto(r) - (l ? this.upto(l - 1) : 0); }
}
```
]
#complexity(time: "O(log n) per update and per query", space: "O(n)")

Run on the chapter's array `[4, -2, 7, 1, 0, -5, 3]`, then `a[3] += 10`:

#code(lang: "text", caption: "Measured output")[
```text
sum(0,6) = 8
sum(2,4) = 8
after a[3] += 10
sum(0,6) = 18
sum(2,4) = 18
sum(3,3) = 11
brute sum(2,4) = 18
200000 updates + 200000 queries: 23 ms, checksum positive
```
]

Twenty-three milliseconds for 400,000 mixed operations. The prefix-rebuild plan would need
about $4 times 10^10$ steps.
]
#note[
A `class` is the right shape here, and one of the few places in this book where it is. The
rule of thumb: write plain functions, and reach for a `class` only when the problem *is* a
data structure with state that many operations share — a Fenwick tree, a heap, a DSU.
]

#subsection[The follow-up]

*"Now the updates are 'add $v$ to every index in $[l, r]$' and the queries are single
points."* Flip it: keep a Fenwick tree over the *difference array*. A range update becomes two
point updates, and a point query becomes a prefix sum.

*"Now both the updates and the queries are ranges."* Two Fenwick trees, or a segment tree with
lazy propagation. Say the phrase "range update, range query — that is lazy propagation" and
the interviewer will move on.

*"Now it is a stream and you cannot store the array."* Then arbitrary $(l, r)$ is impossible.
You can keep a running total and answer "everything so far" in $O(1)$. Naming what became
impossible is part of the answer.
]

#section[Dry run — counting subarrays with sum k]

One problem, every step shown. Array `a = [3, 4, -7, 1, 3, 3, 1, -4]`, target $k = 7$.

The rule: at each step, add `a[i]` to `run`, then look up how many earlier prefixes had the
value `run - k`, then record `run` itself.

#table(columns: 7,
  align: (center, center, center, center, center, center, left),
  [*i*], [*a\[i\]*], [*run*], [*run $-$ k*], [*found*], [*cnt*], [*map after this step*],
  [0], [3], [3], [$-4$], [0], [0], [`0:1 3:1`],
  [1], [4], [7], [0], [1], [1], [`0:1 3:1 7:1`],
  [2], [$-7$], [0], [$-7$], [0], [1], [`0:2 3:1 7:1`],
  [3], [1], [1], [$-6$], [0], [1], [`0:2 1:1 3:1 7:1`],
  [4], [3], [4], [$-3$], [0], [1], [`0:2 1:1 3:1 4:1 7:1`],
  [5], [3], [7], [0], [2], [3], [`0:2 1:1 3:1 4:1 7:2`],
  [6], [1], [8], [1], [1], [4], [`0:2 1:1 3:1 4:1 7:2 8:1`],
  [7], [$-4$], [4], [$-3$], [0], [4], [`0:2 1:1 3:1 4:2 7:2 8:1`],
)

This is the real printed trace of the program, not a hand sketch.

*Step 1 in slow motion.* `run` becomes $3 + 4 = 7$. We look for `run - k` $= 7 - 7 = 0$. The
map holds `0:1` — that entry is the empty prefix we seeded. So one subarray ends here with
sum 7, namely `a[0..1] = [3,4]`. `cnt` becomes 1.

*Step 5 in slow motion.* `run` becomes 7 again. We look for 0, and the map now holds `0:2` —
the empty prefix, and the prefix that ended at index 2 (where the running total returned to
0). So *two* subarrays end at index 5 with sum 7:
- from the empty prefix: `a[0..5] = [3,4,-7,1,3,3]`, which sums to 7
- from the prefix ending at index 2: `a[3..5] = [1,3,3]`, which sums to 7

`cnt` jumps from 1 to 3. This is why the map stores *counts* and not just "seen or not".

*Step 6.* `run` is 8, and we look for 1. The map has `1:1`, from the prefix ending at index 3.
That gives `a[4..6] = [3,3,1]`, which sums to 7. `cnt` becomes 4.

*The four answers, listed.* `[3,4]`, `[3,4,-7,1,3,3]`, `[1,3,3]`, `[3,3,1]`.

#trap[
Notice that `a[2] = -7` made the running total go *down*. A sliding window would have no idea
when to shrink. This is exactly why negative values force the prefix-plus-map method.
]

#section[Practice]

#practice(tier: 1, time: "30 min")[
+ Build the prefix array of `[2, 2, 2, 2, 2]` and use it to find the sum of `a[1..3]`.
+ For `a = [5, -3, 8]`, write out `p` and then compute `sum(0,2)`, `sum(1,1)` and `sum(2,2)`.
+ An array has $n = 10^5$ values, each up to $10^5$. What is the largest possible total, and
  is a plain JavaScript number still exact there?
+ Given `a` and a fixed value $t$, describe in two sentences how to answer "how many values
  in $a[l..r]$ equal $t$" in $O(1)$ per query.
+ Find the largest sum of 3 consecutive values in `[1, -2, 5, 5, -1, 4]` by hand.
+ Find an equilibrium index of `[3, 1, 5, 2, 2]` by hand, showing the left and right sums.
+ Rotate `[10, 20, 30, 40]` right by 3 using the three-reversal method, showing each reversal.
+ Use Kadane by hand on `[4, -5, 6, -1, 2]`, writing `cur` and `best` at every step.
+ In `[1, 2, 3]` with $k = 3$, list every subarray with sum 3 and say why `seen.set(0, 1)` is
  needed to find them all.
+ An array of $1..n+1$ is missing one value and $n = 10^6$. Why is the XOR method safer than
  the sum method?
]

#practice(tier: 2, time: "35 min")[
+ Count the blocks of `[4, 2, 6, 3]` whose sum is divisible by 3, by hand, using the
  remainder-counting method. Show the remainder of each prefix.
+ For `[1, 0, 0, 1, 1, 0]`, count the blocks with equal 0s and 1s using the $+1 slash -1$
  trick. Show the running sum.
+ Bookings on 6 slots: `add(0,2,+3)`, `add(1,4,+2)`, `add(5,5,-1)`. Write the difference
  array and then the final slot values.
+ A $3 times 3$ grid holds all 1s. Write its 2-D prefix table and then use the four-term
  formula to get the sum of the rectangle from $(1,1)$ to $(2,2)$.
+ Find the longest block of `[2, -2, 2, -2, 2]` with sum 2 and explain why the map must keep
  the *earliest* index.
+ All values are positive. Find the shortest block of `[1, 4, 2, 1, 5]` with sum at least 7.
+ Compute "product of all except self" for `[2, 0, 4]` by hand, with the prefix and suffix
  passes written out.
]

#practice(tier: 3, time: "40 min")[
+ For the circular array `[4, -1, -2, 5]`, find the largest wrapping block sum and show both
  the Kadane maximum and the total-minus-minimum value.
+ Count the blocks of `[2, 3, 1]` whose XOR is 1, by listing the prefix XORs.
+ You must answer 200,000 range-sum queries on an array that never changes, and 200,000 more
  on an array that changes after every query. Give the structure and the total complexity for
  each case.
+ Explain in three sentences why prefix sums cannot answer "maximum value in $a[l..r]$".
+ A 2-D difference array is applied to a $1000 times 1000$ grid with $10^5$ rectangle
  updates. Give the total step count and compare it with the direct method.
+ Count the blocks of `[1, -1, 2]` whose sum lies in $[0, 2]$ by listing all of them, then
  say which data structure a program would need for $n = 10^5$.
]

#key[
*Tier 1.*
+ *`p = [0,2,4,6,8,10]`; sum $= p[4] - p[1] = 8 - 2 = 6$.* Check: $2 + 2 + 2 = 6$.
+ *`p = [0, 5, 2, 10]`.* $"sum"(0,2) = p[3] - p[0] = 10$. $"sum"(1,1) = p[2] - p[1] = 2 - 5
  = -3$. $"sum"(2,2) = p[3] - p[2] = 10 - 2 = 8$.
+ *The largest total is $10^5 times 10^5 = 10^10$, and yes, that is exact.* JavaScript numbers
  are exact to $2^53 - 1 approx 9 times 10^15$, so $10^10$ has almost a million times of room
  left. Run this check every time: $n$ times the largest value, compared with $9 times 10^15$.
+ *Build `c[i+1] = c[i] + (a[i] == t ? 1 : 0)`, then the answer is `c[r+1] - c[l]`.* It works
  only because $t$ is fixed for every query; a changing $t$ would need one prefix array per
  value, or a different method.
+ *9, from `[5, 5, -1]`.* The windows are $1-2+5 = 4$, $-2+5+5 = 8$, $5+5-1 = 9$,
  $5-1+4 = 8$. The largest is 9.
+ *Index 2.* Left $= 3 + 1 = 4$; right $= 2 + 2 = 4$. They match.
+ *`[20, 30, 40, 10]`.* Reverse all: `[40,30,20,10]`. Reverse the first 3:
  `[20,30,40,10]`. Reverse the rest (one element): unchanged. Done.
+ *best $= 7$.* `cur`: 4, then $max(-5, -1) = -1$, then $max(6, 5) = 6$, then
  $max(-1, 5) = 5$, then $max(2, 7) = 7$. `best`: 4, 4, 6, 6, 7.
+ *`[3]` and `[1,2]`.* `[1,2]` starts at index 0, so its left prefix is $p[0] = 0$. Only the
  seeded entry `seen.set(0, 1)` can match it. Without the seed the answer would be 1.
+ *Because the expected total is $(10^6+1)(10^6+2) slash 2 approx 5 times 10^11$, and it grows
  like $n^2$.* At $n = 10^6$ a JavaScript number still holds it exactly, but push $n$ to
  $2 times 10^8$ and the total passes $2^53 - 1$ and starts drifting, silently. XOR never
  grows: the result always fits in the same number of bits as the inputs, so the method has no
  such ceiling — as long as the values stay under $2^31$, which is where JavaScript's 32-bit
  bitwise operators stop.

*Tier 2.*
+ *6 blocks.* Prefixes: $0, 4, 6, 12, 15$. Remainders mod 3: $0, 1, 0, 0, 0$. Group them:
  remainder 0 holds 4 prefixes, remainder 1 holds 1. Pairs inside each group:
  $binom(4,2) = 6$ and $binom(1,2) = 0$. Total 6. Listing them confirms it:
  $4+2 = 6$, $6$, $6+3 = 9$, $4+2+6 = 12$, $4+2+6+3 = 15$, $3$.
+ *7 blocks.* Map 1 to $+1$ and 0 to $-1$. The running sums, starting with the seeded 0, are
  $0, 1, 0, -1, 0, 1, 0$. Count pairs of *equal* values: the value 0 appears 4 times giving
  $binom(4,2) = 6$ pairs, the value 1 appears twice giving $binom(2,2) = 1$ pair, and $-1$
  appears once giving 0. Total $6 + 1 = 7$.
+ *`d = [3, 2, 0, -3, 0, -3, 1]` and the slots are `[3, 5, 5, 2, 2, -1]`.* Step by step:
  `add(0,2,3)` sets `d[0]+=3, d[3]-=3`; `add(1,4,2)` sets `d[1]+=2, d[5]-=2`;
  `add(5,5,-1)` sets `d[5]-=1, d[6]+=1`. Prefix: $3, 5, 5, 2, 2, -1$.
+ *`p` is the table with `p[i][j] = i*j`, and the rectangle sum is
  $p[3][3] - p[1][3] - p[3][1] + p[1][1] = 9 - 3 - 3 + 1 = 4$.* Check: the rectangle holds
  four 1s.
+ *Length 5, the whole array.* Prefixes are $0, 2, 0, 2, 0, 2$. We need two prefixes differing
  by 2, as far apart as possible: $p[5] = 2$ and the earliest 0, which is $p[0]$. If the map
  had been overwritten with the later 0s, the answer would have come out as 1 or 3.
+ *Length 3.* No single value reaches 7 (the largest is 5). No pair reaches 7 either: the
  pairs are $1+4 = 5$, $4+2 = 6$, $2+1 = 3$, $1+5 = 6$. Length 3 works at once:
  $1+4+2 = 7$.
+ *`[0, 8, 0]`.* Prefix pass writes $1, 2, 0$ (products of everything to the left). Suffix
  pass multiplies by $0, 4, 1$. Results: $1 times 0 = 0$, $2 times 4 = 8$, $0 times 1 = 0$.

*Tier 3.*
+ *9.* Total $= 4 - 1 - 2 + 5 = 6$. Kadane maximum (no wrap) $= 6$, the whole array. Kadane
  minimum $= -1 - 2 = -3$. Wrapping value $= "total" - "minimum" = 6 - (-3) = 9$, which is the
  block $5$ then $4$ going around the end. The answer is $max(6, 9) = 9$.
+ *2 blocks.* Prefix XORs of `[2, 3, 1]` are $P = 0, 2, 1, 0$. We need pairs with
  $P_i xor P_j = 1$. Pair $(P_0, P_2) = (0, 1)$ gives the block `[2,3]`, whose XOR is
  $2 xor 3 = 1$. Pair $(P_2, P_3) = (1, 0)$ gives the block `[1]`. No other pair works.
+ *Static: prefix sums, $O(n + q)$. Changing: a Fenwick tree, $O((n + q) log n)$.* Measured
  earlier: 400,000 mixed Fenwick operations took 23 ms in Node.
+ *Because prefix sums work by subtracting away the unwanted left part, and maximum has no
  inverse.* Knowing $max(a[0..r])$ and $max(a[0..l-1])$ tells you nothing about
  $max(a[l..r])$: the overall maximum may sit in the discarded part. Range maximum needs a
  sparse table or a segment tree.
+ *$10^5 times 4 + 10^6 = 1.4 times 10^6$ steps, against $10^5 times 10^6 = 10^11$ for the
  direct method.* Four corner marks per update, then one sweep of the million cells. That is
  about 70,000 times less work.
+ *5 blocks.* All six subarrays and their sums: `[1]` $= 1$ ✓, `[1,-1]` $= 0$ ✓,
  `[1,-1,2]` $= 2$ ✓, `[-1]` $= -1$ ✗, `[-1,2]` $= 1$ ✓, `[2]` $= 2$ ✓. Five are inside
  $[0, 2]$. For $n = 10^5$ with negative values a program needs a Fenwick tree over the
  compressed prefix values, $O(n log n)$.
]

#revision[

*The one formula.* $p[0] = 0$, $p[i+1] = p[i] + a[i]$, and
$"sum"(l..r) = p[r+1] - p[l]$. The prefix array is built with `new Array(n + 1).fill(0)`,
always, and has $n+1$ slots.

*The pair view.* Every subarray is a pair of prefixes. So subarray questions become pair
questions, and pair questions are `Map` questions.

#table(columns: 3,
  align: (left, left, left),
  [*Question*], [*What to store*], [*Cost*],
  [count subarrays with sum $k$], [`Map`: prefix value $arrow.r$ *count*], [$O(n)$],
  [longest subarray with sum $k$], [`Map`: prefix value $arrow.r$ *earliest index*], [$O(n)$],
  [count sums divisible by $k$], [array of size $k$: remainder $arrow.r$ count], [$O(n + k)$],
  [equal 0s and 1s], [re-label to $plus.minus 1$, then sum $= 0$], [$O(n)$],
  [count subarrays with XOR $k$], [`Map` of prefix XOR values], [$O(n)$],
  [count sums inside $[L, R]$], [Fenwick over compressed prefixes], [$O(n log n)$],
  [range add, read at the end], [difference array], [$O(n + m)$],
  [rectangle sum in a grid], [2-D prefix, four terms], [$O(R C + q)$],
  [range sum with point updates], [Fenwick tree], [$O(log n)$ each],
  [max in a range], [*not* prefix sums — sparse table / `Deque`], [--],
)

*The templates.*
#code(lang: "js", caption: "Prefix sum")[
```js
const p = new Array(n + 1).fill(0);
for (let i = 0; i < n; i++) p[i + 1] = p[i] + a[i];
const s = p[r + 1] - p[l];
```
]
#code(lang: "js", caption: "Count subarrays with sum k")[
```js
const seen = new Map(); seen.set(0, 1);
let run = 0, cnt = 0;
for (const x of a) {
  run += x;
  cnt += seen.get(run - k) ?? 0;
  seen.set(run, (seen.get(run) ?? 0) + 1);
}
```
]
#code(lang: "js", caption: "Difference array")[
```js
const d = new Array(n + 1).fill(0);
d[l] += v; d[r + 1] -= v;                                  // per update
let run = 0;
for (let i = 0; i < n; i++) { run += d[i]; a[i] = run; }   // once, at the end
```
]
#code(lang: "js", caption: "Kadane")[
```js
let best = a[0], cur = a[0];
for (let i = 1; i < n; i++) { cur = Math.max(a[i], cur + a[i]); best = Math.max(best, cur); }
```
]

*The six JavaScript facts this chapter proved with a measurement.*
#table(columns: (auto, 1fr),
  [numbers are doubles],  [exact to $2^53 - 1 approx 9 times 10^15$. Multiply $n$ by the largest value and compare, *before* you code. Past it, `BigInt`. Example 5.],
  [`new Array(n)`],       [sparse — every slot is a hole, and `undefined + x` is `NaN`. Always `.fill(0)`.],
  [`.fill(row)` for a grid],[puts the *same* row in every slot. Use `Array.from({length: R}, () => new Array(C).fill(0))`. Example 20.],
  [`[...grid]` is shallow],[copies the outer array only. A grid needs `grid.map(r => [...r])`.],
  [`-7 % 3` is `-1`],     [not `2`. Write `((run % k) + k) % k`. Example 17.],
  [bitwise is 32-bit],    [`^`, `&`, `<<` all truncate to 32 bits. Fine below $2^31$; `BigInt` above. Examples 13 and 25.],
)

*Top 6 traps.*
+ `p[r + 1] - p[l]`, never `p[r] - p[l]`. Test with a 3-element array before you trust it.
+ Missing `seen.set(0, 1)`. You lose every subarray that starts at index 0.
+ `map.get(x)` returns `undefined`, not `0`. Without `?? 0` the running count becomes `NaN`
  and stays `NaN`, with no error to tell you where.
+ Counting wants the *count* of each prefix; longest wants the *earliest index*. Do not mix
  them up, and use `.has()` not truthiness, because index `0` is falsy.
+ Negative remainders: write `((run % k) + k) % k`.
+ A sliding window only works when the values are non-negative. One negative value and you
  must switch to prefix plus `Map`.
]

]
