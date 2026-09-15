#import "../../shared/lib/style.typ": *

#chapter(num: 7, title: "Hashing & Frequency Maps", tagline: "Trade memory for time: turn a search into a lookup")[

#section[Pattern in one page]

#formulas(title: "The one idea")[
A hash table answers *"have I seen this before?"* in about one step.

Everything in this chapter is the same move: you are about to write a loop inside a
loop, so you stop, ask *what is the inner loop searching for?*, and store that thing in
a hash table instead. The $O(n^2)$ becomes $O(n)$.

*The three containers JavaScript gives you*
#table(columns: 4,
  [*Container*], [*Holds*], [*Lookup*], [*Order of keys*],
  [`Set`], [keys only], [$O(1)$ average], [insertion order],
  [`Map`], [key $arrow.r$ value], [$O(1)$ average], [insertion order],
  [plain object `{}`], [string key $arrow.r$ value], [$O(1)$ average], [insertion order, integer-like keys first],
)

Use `Map` and `Set` by default. A plain object turns every key into a string, so `1` and
`"1"` become the same entry and an object key becomes `"[object Object]"`. `Map` keeps the
type of the key.

*There is no sorted map.* JavaScript has nothing like an ordered dictionary, so when the
question wants keys in increasing order you collect the keys and sort them at the end:
`[...freq.keys()].sort((a, b) => a - b)`. That costs one extra $O(d log d)$ pass over the
$d$ distinct keys and is usually far cheaper than it sounds.

*The four templates*
]

#code(lang: "js", caption: "The four things you will write over and over")[
```js
// 1. HAVE I SEEN IT?
const seen = new Set();
for (const x of a) {
  if (seen.has(x)) { /* duplicate */ }
  seen.add(x);
}

// 2. HOW MANY TIMES?
const freq = new Map();
for (const x of a) freq.set(x, (freq.get(x) ?? 0) + 1);   // missing key -> 0, then +1

// 3. WHERE DID I SEE IT?
const pos = new Map();
a.forEach((x, i) => pos.set(x, i));      // keeps the LAST index
                                         // use if (!pos.has(x)) for the FIRST

// 4. PREFIX SUM + MAP  (the big one: subarray questions)
const seenPrefix = new Map([[0, 1]]);    // the empty prefix, before index 0
let pre = 0;
for (const x of a) {
  pre += x;
  // pre - target was a prefix ending somewhere earlier,
  // so the piece between them sums to target
  seenPrefix.set(pre, (seenPrefix.get(pre) ?? 0) + 1);
}
```
]

#subsection[The invariant]

#note[
At the moment the loop is about to look at index `i`, the table already describes
*everything strictly before* `i` — and nothing after it. Write that sentence down for
your problem before you write code. Every bug in this chapter is a broken version of it.
]

#subsection[What a hash table actually is]

#diagram(height: 4.2cm, caption: "A key is turned into a bucket number, then the bucket is searched.")[
  #dnode(0pt, 1.1cm, 1.9cm, 0.7cm, "key 27")
  #darrow(1.95cm, 1.45cm, 2.9cm, 1.45cm)
  #dnode(2.95cm, 1.1cm, 2.6cm, 0.7cm, "h(k) = k mod 5", fill: rgb("#f7efe4"))
  #darrow(5.6cm, 1.45cm, 6.5cm, 1.45cm)
  #dnode(6.55cm, 0.0cm, 1.5cm, 0.5cm, "bucket 0")
  #dnode(6.55cm, 0.55cm, 1.5cm, 0.5cm, "bucket 1")
  #dnode(6.55cm, 1.1cm, 1.5cm, 0.5cm, "bucket 2", fill: rgb("#dce9f2"))
  #dnode(6.55cm, 1.65cm, 1.5cm, 0.5cm, "bucket 3")
  #dnode(6.55cm, 2.2cm, 1.5cm, 0.5cm, "bucket 4")
  #darrow(8.1cm, 1.35cm, 9.0cm, 1.35cm)
  #dnode(9.05cm, 1.1cm, 1.3cm, 0.5cm, "27")
  #darrow(10.4cm, 1.35cm, 11.1cm, 1.35cm)
  #dnode(11.15cm, 1.1cm, 1.3cm, 0.5cm, "12")
]

The bucket number is computed, not searched for. That is why lookup costs one step
*on average*. If many keys land in the same bucket, that bucket becomes a list and
lookup costs $O(n)$. Tier 3 shows an attack that does exactly this, and the fix.

#trap[
`Map` lookup is $O(1)$ *on average*, not always. In a written round, say
"$O(n)$ expected, $O(n^2)$ worst case for a hash map". Interviewers listen for this.
]

#trick[
A missing key in a `Map` reads back as `undefined`, not `0`. So `freq.get(x) + 1` on a
first sighting gives `NaN`. Always write `freq.set(x, (freq.get(x) ?? 0) + 1)`. The `??`
is the whole fix, and forgetting it is the most common counting bug in JavaScript.
]

#trick[
Reading a `Map` never creates an entry, so `if (freq.get(x) === 3)` is safe on a missing
key — unlike C++'s `operator[]`, which silently inserts a zero. This is one place where
JavaScript is the friendlier language.
]

#subsection[When to reach for it]

#table(columns: 2,
  [*The question sounds like*], [*Reach for*],
  [duplicate / seen before / distinct], [`new Set()`],
  [count, frequency, most common, anagram], [`new Map()` or a 26-slot array],
  [pair with sum / difference], [`Set` of values seen so far],
  [subarray with sum $k$, count of subarrays], [prefix sum + `Map` of counts],
  [longest subarray with property P], [prefix value + `Map` of the *first* index],
  [group things that are "the same shape"], [build a canonical string key, then `Map<key, array>`],
  [$O(1)$ insert / delete / random], [an array plus a `Map` of positions],
)

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
Print how many times each value appears, with the values in increasing order.
Array length up to $10^5$; values fit in `int`. Target $O(n log n)$.
Edge cases: empty array, all values equal.

#sol[
JavaScript has no sorted map, so the "increasing order" part is handled at the end:
count into a `Map`, then sort the keys once. The counting stays $O(n)$; the sort of the
$d$ distinct keys is the $O(d log d)$ part, and $d <= n$.
]
]

#code(lang: "js", caption: "Frequency in sorted key order")[
```js
const printFrequencies = (a) => {
  const freq = new Map();
  for (const x of a) freq.set(x, (freq.get(x) ?? 0) + 1);
  // JS has no ordered map, so pull the keys out and sort them yourself
  const keys = [...freq.keys()].sort((p, q) => p - q);   // never a bare .sort()
  for (const k of keys) console.log(`${k} -> ${freq.get(k)}`);
};
```
]

Running it on `{4, 1, 4, 7, 1, 4}` prints:

#code(lang: "text", caption: "output")[
```text
1 -> 2
4 -> 3
7 -> 1
```
]

On an empty array it prints nothing. On `{-2, -2, 0, 5}` it prints `-2 -> 2`, `0 -> 1`,
`5 -> 1`. Negative keys are no problem.

#complexity(time: "O(n log n)", space: "O(d), d = number of distinct values",
  note: "Drop the final sort and it becomes O(n), but the keys come out in insertion order.")

#ex(2, tier: 0)[
Does the array contain any value twice? Length up to $10^5$. Target $O(n)$.
Edge cases: empty array, one element.

#sol[
Walk once. Before inserting, ask whether the value is already there.
]
]

#code(lang: "js", caption: "Duplicate check")[
```js
const hasDuplicate = (a) => {
  const seen = new Set();
  for (const x of a) {
    if (seen.has(x)) return true;     // x arrived a second time
    seen.add(x);
  }
  return false;
};
```
]

Tested: `{3,9,2,9}` gives `1`, `{3,9,2,8}` gives `0`, `{}` gives `0`, `{5}` gives `0`,
`{-1,-1}` gives `1`.

#complexity(time: "O(n) expected", space: "O(n)")

#ex(3, tier: 0)[
Return the value whose *second* occurrence comes earliest. Return $-1$ if no value
repeats. Edge cases: empty array, no repeats.

#sol[
This is the same loop as Example 2. The first time the `count` test fires, that value
is the answer — because we are walking left to right, no other value can have finished
its pair sooner.
]
]

#code(lang: "js", caption: "First value to repeat")[
```js
const firstRepeating = (a) => {
  const seen = new Set();
  for (const x of a) {
    if (seen.has(x)) return x;
    seen.add(x);
  }
  return -1;
};
```
]

Tested: `{5,2,7,2,5}` gives `2` (not 5 — the *second 2* arrives at index 3, the second 5
only at index 4). `{1,2,3}` gives `-1`. `{}` gives `-1`. `{8,8}` gives `8`.

#trap[
"First repeating" has two meanings. (a) The value whose second copy comes first — this
code. (b) The value whose *first* copy comes earliest among all repeated values — for
`{5,2,7,2,5}` that answer is `5`. Ask the interviewer which one. For (b) you count
first, then re-walk the array and return the first value with count $>= 2$.
]

#ex(4, tier: 0)[
Are two arrays rearrangements of each other? Lengths up to $10^5$.
Edge cases: different lengths, both empty.

#sol[
Count the first array. Then spend the counts on the second. If a value runs out, or
was never there, the answer is no.
]
]

#code(lang: "js", caption: "Same multiset of values")[
```js
const samePermutation = (a, b) => {
  if (a.length !== b.length) return false;
  const cnt = new Map();
  for (const x of a) cnt.set(x, (cnt.get(x) ?? 0) + 1);
  for (const x of b) {
    const c = cnt.get(x);
    if (c === undefined || c === 0) return false;
    cnt.set(x, c - 1);
  }
  return true;
};
```
]

Tested: `({1,2,2,3},{3,2,1,2})` gives `1`; `({1,2,2,3},{3,2,1,1})` gives `0`;
`({},{})` gives `1`; `({1},{1,1})` gives `0`; `({-4,-4},{-4,-4})` gives `1`.

#complexity(time: "O(n) expected", space: "O(n)")

#ex(5, tier: 0)[
Count distinct values. Edge cases: empty array, all equal.

#sol[
A set drops repeats for you. Build it from the range and read its size.
]
]

#code(lang: "js", caption: "Distinct count in one line")[
```js
const countDistinct = (a) => new Set(a).size;
```
]

Tested: `{6,6,6}` gives `1`; `{1,2,3,2}` gives `3`; `{}` gives `0`; `{-7}` gives `1`.

#ex(6, tier: 0)[
Return the most frequent value. If two values tie, return the smaller one.
Edge case: single element, negative values. Assume the array is not empty.

#sol[
Count everything, then sweep the map once keeping the best pair `(count, value)`.
The tie rule is one extra condition.
]
]

#code(lang: "js", caption: "Mode, smallest value on a tie")[
```js
const modeSmallestTie = (a) => {
  const cnt = new Map();
  for (const x of a) cnt.set(x, (cnt.get(x) ?? 0) + 1);
  let best = 0, bestCount = -1;
  for (const [value, c] of cnt) {
    if (c > bestCount || (c === bestCount && value < best)) {
      best = value;
      bestCount = c;
    }
  }
  return best;                       // caller must not pass an empty array
};
```
]

Tested: `{4,9,4,9,2}` gives `4` (both 4 and 9 appear twice, 4 is smaller);
`{7,7,7,1}` gives `7`; `{3}` gives `3`; `{-5,-9,-9}` gives `-9`.

#trap[
`bestCount` starts at $-1$, not $0$. If it started at 0 and every count were 0 (it
cannot be, but in similar problems it can), nothing would ever be selected and `best`
would stay at its junk value.
]

#section[Tier 1 — the placement standards]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
Given an array and a number `target`, is there a pair of *different positions* whose
values add to `target`? $n <= 10^5$, values up to $10^9$ in size. Target $O(n)$.
Edge cases: empty array, one element, two equal values that add to the target, values
big enough that `target - x` leaves `int` range.
]

#sol[
#approach(1, "Check every pair", verdict: "O(n^2) — dies above n = 10000")
]

#code(lang: "js", caption: "Approach 1 — brute force")[
```js
const pairSumBrute = (a, target) => {
  for (let i = 0; i < a.length; i++)
    for (let j = i + 1; j < a.length; j++)
      if (a[i] + a[j] === target) return true;
  return false;
};
```
]

#complexity(time: "O(n^2)", space: "O(1)")

#approach(2, "Sort, then two pointers", verdict: "O(n log n), and it destroys the order")

#code(lang: "js", caption: "Approach 2 — sort + two pointers")[
```js
const pairSumTwoPointer = (a, target) => {
  const s = [...a].sort((x, y) => x - y);   // sort a COPY, and pass a comparator
  let i = 0, j = s.length - 1;
  while (i < j) {
    const sum = s[i] + s[j];
    if (sum === target) return true;
    if (sum < target) i++;                  // need more, move the small end up
    else j--;                               // too much, move the big end down
  }
  return false;
};
```
]

#complexity(time: "O(n log n)", space: "O(n) for the copy",
  note: "Good when you also need the values sorted. Useless when you must return original indices.")

#approach(3, "One pass with a set of values already seen", verdict: "O(n) — optimal")

For the current value `x`, the partner must be `target - x`. Ask the set whether that
partner walked past already.

#code(lang: "js", caption: "Approach 3 — hash set")[
```js
const pairSumHash = (a, target) => {
  const seen = new Set();
  for (const x of a) {
    if (seen.has(target - x)) return true;
    seen.add(x);
  }
  return false;
};
```
]

#complexity(time: "O(n) expected", space: "O(n)")

If the indices are wanted, store `value -> index` instead of just the value.

#code(lang: "js", caption: "Approach 3b — return the two indices")[
```js
const pairSumIndices = (a, target) => {
  const pos = new Map();                    // value -> index seen earlier
  for (let i = 0; i < a.length; i++) {
    const need = target - a[i];
    if (pos.has(need)) return [pos.get(need), i];
    pos.set(a[i], i);                       // insert AFTER the lookup
  }
  return [-1, -1];
};
```
]

Tested on `({2,11,7,4}, 9)` all three return `1`, and `pairSumIndices` returns
`0,2` (values 2 and 7). On `({}, 5)`, `({5}, 5)` all return `0`. On `({3,3}, 6)` all
return `1` — two different positions holding the same value is a legal pair. On
`([1000000000, 1000000000], 2000000000)` all return `1`. In C++ that sum needs a
64-bit cast; in JavaScript every number is already a double, exact up to
$2^53 - 1 approx 9.0 times 10^15$, so $2 times 10^9$ is nowhere near the edge.

#trap[
Insert `a[i]` *after* the lookup, never before. If you insert first, a lone `4` with
`target = 8` matches itself and you report a fake pair.
]

#note[
*The idea that unlocked it:* the inner loop was searching for one exact number,
`target - x`. Anything searching for one exact number is a hash lookup.
]

#ex(8, tier: 1, asked: "Infosys · pattern")[
Return the first character in a string that appears exactly once. Return `#sym.hash` if
there is none. String length up to $10^5$, any bytes. Target $O(n)$.
Edge cases: empty string, all characters repeated.
]

#sol[
Two passes. Pass 1 counts. Pass 2 walks the string again *in order* and returns the
first character with count 1. The second pass must walk the string, not the table — a
table has no order.
]

#code(lang: "js", caption: "First unique character")[
```js
const firstUniqueChar = (s) => {
  const cnt = new Map();
  for (const c of s) cnt.set(c, (cnt.get(c) ?? 0) + 1);
  for (const c of s) if (cnt.get(c) === 1) return c;   // walk the STRING, not the map
  return '#';
};
```
]

Tested: `"swiss"` gives `w`; `"aabb"` gives `#sym.hash`; `""` gives `#sym.hash`;
`"z"` gives `z`; `"aabbc"` gives `c`.

#trick[
When keys are characters, `new Array(256).fill(0)` *is* the hash table, with a perfect
hash and zero collisions. It is several times faster than a `Map`, because there is no
hashing and no boxing. For lowercase letters only, use 26 slots and index with
`c.charCodeAt(0) - 97`.
]

#complexity(time: "O(n)", space: "O(1) — 256 fixed slots")

#ex(9, tier: 1, asked: "Wipro · pattern")[
Return the distinct values that appear in both arrays, in the order they first appear
in the first array. Lengths up to $10^5$.
Edge cases: one array empty, repeats inside each array.
]

#sol[
Put the second array in a set. Then walk the first array in order. A second set stops
you from printing the same value twice.
]

#code(lang: "js", caption: "Intersection, order kept")[
```js
const intersectDistinct = (a, b) => {
  const inB = new Set(b);
  const used = new Set();
  const out = [];
  for (const x of a)
    if (inB.has(x) && !used.has(x)) { out.push(x); used.add(x); }
  return out;
};
```
]

Tested: `({4,1,4,9},{9,4,4})` gives `[4,9]`; `({1,2},{3})` gives `[]`;
`({},{1})` gives `[]`; `({-3,-3},{-3})` gives `[-3]`.

#complexity(time: "O(n + m) expected", space: "O(m + answer)")

#ex(10, tier: 1, asked: "Capgemini · pattern")[
The array holds $n-1$ *distinct* numbers taken from $1..n$. Find the missing one.
$n$ up to $2 times 10^6$. Edge cases: empty array (then $n = 1$, answer 1), the
missing number is 1 or is $n$, and the overflow risk in the sum method.
]

#sol[
#approach(1, "Hash set", verdict: "O(n) time, O(n) memory")
]

#code(lang: "js", caption: "Approach 1 — set")[
```js
const missingHash = (a) => {
  const n = a.length + 1;
  const s = new Set(a);
  for (let v = 1; v <= n; v++) if (!s.has(v)) return v;
  return -1;
};
```
]

#approach(2, "Sum formula", verdict: "O(n) time, O(1) memory — but watch the overflow")

$1 + 2 + dots + n = n(n+1)\/2$. Subtract everything present; what is left is the hole.

#code(lang: "js", caption: "Approach 2 — sum")[
```js
const missingSum = (a) => {
  const n = a.length + 1;
  let total = n * (n + 1) / 2;      // n = 2e6 gives 2e12 — exact, the ceiling is 9.0e15
  for (const x of a) total -= x;
  return total;
};
```
]

#approach(3, "XOR", verdict: "O(n) time, O(1) memory, no overflow at all — optimal")

XOR every number from 1 to $n$, then XOR every number present. Every value that appears
twice cancels ($x xor x = 0$). Only the hole survives.

#code(lang: "js", caption: "Approach 3 — XOR")[
```js
const missingXor = (a) => {
  const n = a.length + 1;
  let x = 0;
  for (let v = 1; v <= n; v++) x ^= v;   // ^ is a 32-bit operator, fine up to 2^31 - 1
  for (const v of a) x ^= v;
  return x;
};
```
]

Tested. On `{1,2,4,5}` all three give `3`. On `{}` all give `1`. On `{2}` all give `1`.
On `{1}` all give `2`. On a two-million case with the hole at 777777, the sum version
and the XOR version both print `777777` — the running total reaches about
$2 times 10^12$, which a JavaScript number still holds exactly.

#trap[
Write `missingSum` with plain `int` and $n = 2 times 10^6$: the total is about
$2 times 10^12$, which does not fit in a 32-bit `int`. You get a wrong answer with no
warning. This is the single most common silent bug in a placement test.
]

#note[
*The idea that unlocked it:* the set stored *presence*. A sum stores presence too, just
compressed into one number. XOR stores it and cannot overflow.
]

#ex(11, tier: 1, asked: "Accenture · pattern")[
Count how many *value pairs* $(x, x+k)$ exist, where both values occur in the array.
$k >= 0$. Count each value pair once, no matter how many copies exist. $n <= 10^5$.
Edge cases: $k = 0$, empty array, one element, negative values.
]

#sol[
#approach(1, "All ordered index pairs, then de-duplicate", verdict: "O(n^2 log n)")
]

#code(lang: "js", caption: "Approach 1 — brute force")[
```js
const countPairsBrute = (a, k) => {
  const found = new Set();
  for (let i = 0; i < a.length; i++)
    for (let j = 0; j < a.length; j++)
      if (i !== j && a[j] - a[i] === k) found.add(`${a[i]},${a[j]}`);   // string key
  return found.size;
};
```
]

#approach(2, "Count table, then ask for each key", verdict: "O(n) — optimal")

For every distinct value `x`, ask whether `x + k` also exists. That is one lookup.
The case $k = 0$ is different: `x` must pair with *another copy of itself*, so it needs
count $>= 2$.

#code(lang: "js", caption: "Approach 2 — hash map of counts")[
```js
const countPairsHash = (a, k) => {
  const cnt = new Map();
  for (const x of a) cnt.set(x, (cnt.get(x) ?? 0) + 1);
  let total = 0;
  if (k === 0) {
    for (const c of cnt.values()) if (c >= 2) total++;   // x pairs with another copy of x
    return total;
  }
  for (const x of cnt.keys()) if (cnt.has(x + k)) total++;
  return total;
};
```
]

Both versions agree on every test: `({1,5,3,4,2}, 2)` gives `3` (the pairs
$(1,3), (2,4), (3,5)$); `({3,3,3}, 0)` gives `1`; `({}, 1)` gives `0`;
`({7}, 1)` gives `0`; `({-4,-2,0}, 2)` gives `2`.

#trap[
Forgetting $k = 0$ is the classic failure. Without the special case every distinct
value pairs with itself and you return the number of distinct values.
]

#complexity(time: "O(n) expected", space: "O(n)")

#ex(12, tier: 1, asked: "Cognizant · pattern")[
Are two strings anagrams? Length up to $10^5$.
Edge cases: different lengths, both empty, same letters but different counts.
]

#sol[
#approach(1, "Sort both, compare", verdict: "O(n log n)")
]

#code(lang: "js", caption: "Approach 1 — sort")[
```js
const anagramSort = (a, b) => {
  if (a.length !== b.length) return false;
  const norm = (s) => [...s].sort().join('');   // characters: the default sort is correct
  return norm(a) === norm(b);
};
```
]

#approach(2, "One count table: add for a, subtract for b", verdict: "O(n) — optimal")

#code(lang: "js", caption: "Approach 2 — counting")[
```js
const anagramCount = (a, b) => {
  if (a.length !== b.length) return false;
  const cnt = new Map();
  for (const c of a) cnt.set(c, (cnt.get(c) ?? 0) + 1);
  for (const c of b) {
    const left = (cnt.get(c) ?? 0) - 1;
    if (left < 0) return false;                 // b used a letter a does not have
    cnt.set(c, left);
  }
  return true;
};
```
]

Both agree: `("listen","silent")` $arrow.r$ `1`; `("abc","abd")` $arrow.r$ `0`;
`("","")` $arrow.r$ `1`; `("a","aa")` $arrow.r$ `0`; `("aab","abb")` $arrow.r$ `0`.

#trick[
The length check is not just an optimisation, it is *required*. Without it, `"a"` and
`"aa"` would give a wrong answer for some count schemes. With equal lengths, "no letter
went negative" already proves the counts match exactly.
]

#complexity(time: "O(n)", space: "O(1)")

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
Remove later copies of every value, keep the first copy, keep the original order.
$n <= 10^5$. Edge cases: empty, all same, negatives.
]

#sol[
`insert` on an `unordered_set` returns a pair; its second field is `true` only when the
value was new. That is exactly the test you need, and it costs one lookup instead of two.
]

#code(lang: "js", caption: "De-duplicate, order kept")[
```js
const dedupKeepFirst = (a) => {
  const seen = new Set();
  return a.filter((x) => (seen.has(x) ? false : (seen.add(x), true)));
};

// when you do not need the "was it new?" test at all, one line does it:
const dedup = (a) => [...new Set(a)];
```
]

Tested: `{5,1,5,2,1}` gives `[5,1,2]`; `{}` gives `[]`; `{9,9,9}` gives `[9]`;
`{-1,0,-1}` gives `[-1,0]`.

#ex(14, tier: 1, asked: "Infosys · pattern")[
One value appears *more than* $n\/2$ times. Find it, or report that no value does.
$n <= 10^5$. Edge cases: empty array, no majority, negative values.
]

#sol[
#approach(1, "Count every value by scanning", verdict: "O(n^2)")
]

#code(lang: "js", caption: "Approach 1 — brute force")[
```js
const majorityBrute = (a) => {
  for (let i = 0; i < a.length; i++) {
    let c = 0;
    for (let j = 0; j < a.length; j++) if (a[j] === a[i]) c++;
    if (c > a.length / 2) return a[i];
  }
  return -1;
};
```
]

#approach(2, "Hash map of counts", verdict: "O(n) time, O(n) memory")

#code(lang: "js", caption: "Approach 2 — counting")[
```js
const majorityHash = (a) => {
  const cnt = new Map();
  for (const x of a) {
    const c = (cnt.get(x) ?? 0) + 1;
    cnt.set(x, c);
    if (c > a.length / 2) return x;        // stop the moment it crosses
  }
  return -1;
};
```
]

#approach(3, "Voting", verdict: "O(n) time, O(1) memory — optimal")

Keep a candidate and a vote count. A matching value adds a vote, any other value removes
one. When votes hit zero, the next value becomes the new candidate. Think of it as
cancelling one majority ballot against one non-majority ballot: since the majority has
more than half, it always survives. The vote alone can lie when *no* majority exists,
so verify with one more pass.

#code(lang: "js", caption: "Approach 3 — vote and verify")[
```js
const majorityVote = (a) => {
  let cand = 0, votes = 0;
  for (const x of a) {
    if (votes === 0) { cand = x; votes = 1; }
    else if (x === cand) votes++;
    else votes--;
  }
  let c = 0;
  for (const x of a) if (x === cand) c++;   // verify: the vote alone can lie
  return c > a.length / 2 ? cand : -1;
};
```
]

All three agree: `{4,4,2,4,3}` gives `4`; `{1,2}` gives `-1`; `{}` gives `-1`;
`{6}` gives `6`; `{-3,-3,-3,1}` gives `-3`.

#trap[
Skipping the verification pass is the number one mistake here. On `{1,2}` the voting
loop leaves `cand = 2`, and without the check you would return 2.
]

#note[
*The idea that unlocked it:* the hash map stored the count of every value, but we only
ever needed *one* count. Voting keeps that single count and throws the rest away.
]

#ex(15, tier: 1, asked: "Capgemini · pattern")[
Given two arrays, how many values appear in the first but not in the second? Count
distinct values. Lengths up to $10^5$.
]

#sol[
One set for the second array, one set to avoid double counting. The same skeleton as
Example 9 with the condition flipped.
]

#code(lang: "js", caption: "Values only in the first array")[
```js
const onlyInFirst = (a, b) => {
  const inB = new Set(b), done = new Set();
  const out = [];
  for (const x of a)
    if (!inB.has(x) && !done.has(x)) { out.push(x); done.add(x); }
  return out;
};
```
]

Tested: `({1,2,2,3},{2,4})` gives `[1,3]`; `({},{1})` gives `[]`; `({5},{})` gives `[5]`;
`({-1,-1},{-1})` gives `[]`.

#section[Tier 2 — applied, two or three steps]
#tier-header(2)

#ex(16, tier: 2, asked: "Grab · pattern")[
A ride-fare log holds daily profit or loss as integers, positive and negative.
Find the length of the *longest* stretch of consecutive days whose total is exactly `k`.
$n <= 10^5$, each value up to $10^9$ in size, so the running total can reach $10^14$.
Target $O(n)$. Edge cases: empty log, no such stretch, all zeros with $k = 0$, totals
that overflow 32 bits.
]

#sol[
#approach(1, "Every start, every end", verdict: "O(n^2) — 10^10 steps at n = 10^5")
]

#code(lang: "js", caption: "Approach 1 — brute force")[
```js
const longestSumBrute = (a, k) => {
  let best = 0;
  for (let i = 0; i < a.length; i++) {
    let s = 0;
    for (let j = i; j < a.length; j++) {
      s += a[j];
      if (s === k) best = Math.max(best, j - i + 1);
    }
  }
  return best;
};
```
]

#approach(2, "Prefix sums + map of the FIRST index", verdict: "O(n) — optimal")

Let $P_i$ be the sum of the first $i+1$ values. The sum of the stretch from $l$ to $r$
is $P_r - P_(l-1)$. So a stretch ending at $r$ has sum $k$ exactly when some earlier
prefix equals $P_r - k$.

To make the stretch *long*, you want that earlier prefix to be as *early* as possible.
So store only the first index at which each prefix value appeared.

#code(lang: "js", caption: "Approach 2 — prefix + first-index map")[
```js
const longestSumHash = (a, k) => {
  const firstIdx = new Map([[0, -1]]);   // prefix value -> earliest index;
  let pre = 0, best = 0;                 // 0 is the empty prefix, ending before index 0
  for (let i = 0; i < a.length; i++) {
    pre += a[i];
    if (firstIdx.has(pre - k)) best = Math.max(best, i - firstIdx.get(pre - k));
    if (!firstIdx.has(pre)) firstIdx.set(pre, i);   // keep the EARLIEST only
  }
  return best;
};
```
]

Both versions agree on every test:

#table(columns: 3,
  [*array*], [*k*], [*answer*],
  [`{1,-1,5,-2,3}`], [3], [4],
  [`{-2,-1,2,1}`], [1], [2],
  [`{}`], [0], [0],
  [`{0,0,0}`], [0], [3],
  [`{5}`], [5], [1],
  [`{5}`], [4], [0],
  [`{2000000000, 2000000000, -1}`], [4000000000], [2],
)

#trap[
Two traps live in four lines here.
+ `firstIdx[0] = -1` must be there. Without it a stretch that starts at index 0 is
  never found. Test `{5}` with $k = 5$ catches this.
+ `if (!firstIdx.has(pre))` must be there. Overwriting with a later index gives you a
  shorter answer, and the bug only shows on inputs with repeated prefix values.
]

#note[
With $10^5$ values of size $10^9$ the prefix reaches $10^14$. In C++ this is the line
where you would reach for a 64-bit integer; a JavaScript number is a double and holds every
integer up to $2^53 - 1 approx 9.0 times 10^15$ exactly, so nothing special is needed.
Past that limit — and only past it — you would switch to `BigInt`.
]

#complexity(time: "O(n) expected", space: "O(n)")

#note[
*The idea that unlocked it:* the inner loop was recomputing sums you already had. A
prefix sum turns "sum of a stretch" into "difference of two numbers", and a difference
is exactly what a hash lookup finds.
]

#ex(17, tier: 2, asked: "Shopee · pattern")[
Same log. Now count *how many* stretches total exactly `k` (not the longest — all of
them). $n <= 10^5$. The count itself can exceed 32 bits.
Edge cases: empty log, all zeros with $k = 0$, negatives.
]

#sol[
Same prefix trick, one change: you no longer want the earliest index, you want *how
many* earlier prefixes had the needed value. So store counts, not indices.
]

#code(lang: "js", caption: "Approach 1 — brute force (for checking)")[
```js
const countSumBrute = (a, k) => {
  let total = 0;
  for (let i = 0; i < a.length; i++) {
    let s = 0;
    for (let j = i; j < a.length; j++) { s += a[j]; if (s === k) total++; }
  }
  return total;
};
```
]

#code(lang: "js", caption: "Approach 2 — prefix + count map")[
```js
const countSumHash = (a, k) => {
  const seen = new Map([[0, 1]]);        // the empty prefix counts as one
  let pre = 0, total = 0;
  for (const x of a) {
    pre += x;
    total += seen.get(pre - k) ?? 0;                 // look up BEFORE inserting
    seen.set(pre, (seen.get(pre) ?? 0) + 1);
  }
  return total;
};
```
]

Both agree:

#table(columns: 3,
  [*array*], [*k*], [*answer*],
  [`{1,2,3}`], [3], [2],
  [`{0,0,0}`], [0], [6],
  [`{}`], [0], [0],
  [`{-1,1,-1,1}`], [0], [4],
  [`{4}`], [4], [1],
  [`{4}`], [0], [0],
)

With 100000 zeros and $k = 0$, the optimal version returns `5000050000`. That is
$n(n+1)\/2$. It is far past $2^31$, which would overflow a 32-bit `int` in C++, but it is
a thousand times below $2^53$, so a plain JavaScript number is exact.

#trap[
`seen[0] = 1` — not `seen[0] = 0`, and not missing. Test `{4}` with $k = 4$: without it
the answer is 0 instead of 1.
]

#trap[
Look up `pre - k` *before* you do `seen[pre]++`. If `k = 0` and you increment first, the
current prefix matches itself and every element reports one fake stretch.
]

#complexity(time: "O(n) expected", space: "O(n)")

#ex(18, tier: 2, asked: "Agoda · pattern")[
Group hotel-code strings so that all rearrangements of the same letters end up in one
group. Words are lowercase, total characters up to $10^6$.
Edge cases: no words, one word, two identical words.
]

#sol[
Two words belong together when their letter counts match. So build a *canonical key*
from the letter counts and use it as a map key. Sorting the word also works and is
shorter; the count key is faster for long words.
]

#code(lang: "js", caption: "Group by a canonical count key")[
```js
const groupAnagrams = (words) => {
  const table = new Map();
  for (const w of words) {
    const cnt = new Array(26).fill(0);
    for (let i = 0; i < w.length; i++) cnt[w.charCodeAt(i) - 97]++;
    const key = cnt.join('#');            // '#' separators: (1,11) must not read as (11,1)
    if (!table.has(key)) table.set(key, []);
    table.get(key).push(w);
  }
  return [...table.values()];             // a Map hands the groups back in first-seen order
};
```
]

On `{"tea","eat","tan","ate","nat","bat"}` the groups printed are:

#code(lang: "text", caption: "output")[
```text
bat
tan nat
tea eat ate
```
]

Empty input gives 0 groups, `{"zz"}` gives 1 group, `{"ab","ab"}` gives 1 group of two.

#trap[
The separator `'#'` in the key matters. Without it, counts `(1, 11)` and `(11, 1)` both
become the string `"111"` and two different words collide into one group.
]

#complexity(time: "O(total characters)", space: "O(total characters)")

#ex(19, tier: 2, asked: "Sea / Shopee · pattern")[
Order IDs arrive unsorted with repeats. Find the length of the longest run of
*consecutive integers* present. $n <= 10^5$, IDs may be negative.
Edge cases: empty, one ID, all equal, a run that touches `INT_MAX`.
]

#sol[
#approach(1, "Sort, then walk", verdict: "O(n log n), easy and usually fast enough")
]

#code(lang: "js", caption: "Approach 1 — sort")[
```js
const longestRunSort = (a) => {
  if (a.length === 0) return 0;
  const s = [...a].sort((x, y) => x - y);      // NUMERIC comparator, always
  let best = 1, run = 1;
  for (let i = 1; i < s.length; i++) {
    if (s[i] === s[i - 1]) continue;           // skip duplicates
    if (s[i] === s[i - 1] + 1) run++;
    else run = 1;
    best = Math.max(best, run);
  }
  return best;
};
```
]

#approach(2, "Hash set, count only from a run's start", verdict: "O(n) — optimal")

Put everything in a set. For a value `x`, only bother counting upward if `x - 1` is
*not* in the set — that means `x` begins its run. Every run is therefore walked exactly
once, so the total work over all runs is $O(n)$, not $O(n^2)$.

#code(lang: "js", caption: "Approach 2 — hash set")[
```js
const longestRunHash = (a) => {
  const s = new Set(a);
  let best = 0;
  for (const x of s) {
    if (s.has(x - 1)) continue;                // x is not the start of its run
    let y = x, len = 1;
    while (s.has(y + 1)) { y++; len++; }
    best = Math.max(best, len);
  }
  return best;
};
```
]

Both agree: `{100,4,2,1,3,2}` gives `4`; `{}` gives `0`; `{8}` gives `1`;
`{5,5,5}` gives `1`; `{-3,-2,-1,4}` gives `3`.

#trap[
Drop the `if (s.count(x - 1)) continue;` guard and the code still gives the right answer
but becomes $O(n^2)$ on a single long run: every member re-walks the whole run.
]

#complexity(time: "O(n) expected", space: "O(n)")

#ex(20, tier: 2, asked: "DBS · pattern")[
A log of transactions marks each as a credit (1) or a debit (0). Find the longest
stretch with an equal number of credits and debits. $n <= 10^5$.
Edge cases: empty, all credits, one entry.
]

#sol[
Replace every 0 by $-1$. Now "equal counts" means "the stretch sums to zero", and you
are back in Example 16 with $k = 0$.
]

#code(lang: "js", caption: "0 becomes -1, then longest zero-sum stretch")[
```js
const longestBalanced = (bits) => {
  const firstIdx = new Map([[0, -1]]);
  let pre = 0, best = 0;
  for (let i = 0; i < bits.length; i++) {
    pre += bits[i] === 1 ? 1 : -1;
    if (firstIdx.has(pre)) best = Math.max(best, i - firstIdx.get(pre));
    else firstIdx.set(pre, i);
  }
  return best;
};
```
]

Tested: `{0,1,0,0,1,1,0}` gives `6` (indices 0..5 hold three of each); `{1,1,1}` gives
`0`; `{}` gives `0`; `{0}` gives `0`; `{0,1}` gives `2`.

#note[
*The idea that unlocked it:* a re-labelling. Nothing about the algorithm changed; only
the meaning of the numbers did. Watch for this move — it also turns "equal vowels and
consonants" and "equal A's and B's" into the same three lines.
]

#ex(21, tier: 2, asked: "LINE MAN · pattern")[
Find the `k` most ordered dishes. On a tie, the smaller dish id comes first.
$n <= 10^5$, ids fit in `int`. Target better than $O(n log n)$ if possible.
Edge cases: `k` larger than the number of distinct dishes, empty input.
]

#sol[
#approach(1, "Count, then sort the distinct values", verdict: "O(d log d), d = distinct count")
]

#code(lang: "js", caption: "Approach 1 — sort the counts")[
```js
const topKSort = (a, k) => {
  const cnt = new Map();
  for (const x of a) cnt.set(x, (cnt.get(x) ?? 0) + 1);
  return [...cnt.entries()]
    .sort(([v1, c1], [v2, c2]) => c2 - c1 || v1 - v2)   // count down, then value up
    .slice(0, k)
    .map(([v]) => v);
};
```
]

#approach(2, "Bucket by count", verdict: "O(n) — optimal")

A count can never be bigger than `n`. So make `n + 1` buckets, drop each value into the
bucket named by its count, and read the buckets from the top down.

#code(lang: "js", caption: "Approach 2 — bucket sort on counts")[
```js
const topKBucket = (a, k) => {
  const cnt = new Map();
  for (const x of a) cnt.set(x, (cnt.get(x) ?? 0) + 1);
  const bucket = Array.from({ length: a.length + 1 }, () => []);
  for (const [v, c] of cnt) bucket[c].push(v);
  const out = [];
  for (let c = a.length; c >= 1 && out.length < k; c--) {
    bucket[c].sort((p, q) => p - q);          // smaller value first on a tie
    for (const v of bucket[c]) {
      if (out.length === k) break;
      out.push(v);
    }
  }
  return out;
};
```
]

Both agree: `({1,1,1,2,2,3}, 2)` gives `[1,2]`; `({}, 3)` gives `[]`;
`({7}, 1)` gives `[7]`; `({4,4,5,5}, 1)` gives `[4]`; `({-2,-2,9}, 2)` gives `[-2,9]`.

#note[
Without the tie rule the bucket version is a clean $O(n)$. The tie rule forces a small
sort inside each bucket, but the buckets are tiny, so it stays close to $O(n)$ in
practice. Say this out loud in an interview instead of pretending the sort is free.
]

#ex(22, tier: 2, asked: "SCB · pattern")[
Count *distinct unordered value pairs* $\{x, y\}$ with $x != y$ and $x + y = $ target.
$n <= 10^5$, values up to $2 times 10^9$ in size.
Edge cases: repeats, $x = y$ cases must be excluded, values near the `int` edges.
]

#sol[
Walk once. Keep a set of values seen. When the partner is present and different from
`x`, remember the pair with its smaller value first so both orders collapse to one entry.
]

#code(lang: "js", caption: "Distinct value pairs")[
```js
const countUniquePairs = (a, target) => {
  const seen = new Set();
  const used = new Set();                     // keys are strings "lo,hi"
  for (const x of a) {
    const need = target - x;
    if (need !== x && seen.has(need))
      used.add(`${Math.min(x, need)},${Math.max(x, need)}`);
    seen.add(x);
  }
  return used.size;
};
```
]

Tested: `({1,5,3,3,7,-1,9}, 8)` gives `3` — the pairs $\{1,7\}$, $\{5,3\}$, $\{-1,9\}$,
and the second `3` adds nothing. `({4,4,4}, 8)` gives `0` because $x = y$ is excluded.
`({}, 0)` gives `0`. `({2}, 2)` gives `0`. `({2000000000, 2000000000, -2000000000}, 0)`
gives `1`.

#complexity(time: "O(n log n) — the answer set is ordered", space: "O(n)")

#section[Tier 3 — needs an insight]
#tier-header(3)

#ex(23, tier: 3, asked: "Google · pattern")[
Length of the longest stretch of a string in which no character repeats.
Length up to $10^5$, any bytes. Target $O(n)$.
Edge cases: empty, all same, a repeat that is far behind the window.

*The follow-up the interviewer asks next:* "now the characters arrive one at a time and
you cannot store the whole string."
]

#sol[
#approach(1, "Every start, grow until a repeat", verdict: "O(n^2)")
]

#code(lang: "js", caption: "Approach 1 — brute force")[
```js
const longestDistinctBrute = (s) => {
  let best = 0;
  for (let i = 0; i < s.length; i++) {
    const used = new Set();
    for (let j = i; j < s.length; j++) {
      if (used.has(s[j])) break;
      used.add(s[j]);
      best = Math.max(best, j - i + 1);
    }
  }
  return best;
};
```
]

#approach(2, "Sliding window + last-seen table", verdict: "O(n) — optimal")

Keep a window `[left, right]`. Store, for each character, the last index it was seen at.
When the new character was last seen *inside* the window, jump `left` to just past that
old copy. `left` never moves backwards, so each index is touched a constant number of
times.

#code(lang: "js", caption: "Approach 2 — window with a jump")[
```js
const longestDistinctWindow = (s) => {
  const last = new Map();          // character -> last index it was seen at
  let left = 0, best = 0;
  for (let right = 0; right < s.length; right++) {
    const c = s[right];
    if (last.has(c) && last.get(c) >= left) left = last.get(c) + 1;  // jump past the copy
    last.set(c, right);
    best = Math.max(best, right - left + 1);
  }
  return best;
};
```
]

Both agree: `"abcabcbb"` gives `3`; `"bbbbb"` gives `1`; `""` gives `0`; `"a"` gives `1`;
`"pwwkew"` gives `3`; `"abba"` gives `2`.

#trap[
`if (last[c] >= left)` — the `>= left` part is essential. On `"abba"` the second `a` was
last seen at index 0, but `left` has already moved to 2. Without the guard `left` would
jump *backwards* to 1 and the answer would be 3, which is wrong.
]

#subsection[The follow-up: a stream]

You cannot keep the string, but you never needed it. The window code already stores only
256 integers and two cursors. Feed characters in one at a time, keep `left`, `right` and
`last[]` as member variables, and report `right - left + 1` after each arrival. Memory
stays $O(1)$ for bytes, or $O(|Sigma|)$ for a general alphabet.

#ex(24, tier: 3, asked: "Amazon · pattern")[
Count the stretches of an array whose sum is divisible by `k`. Values may be negative.
$n <= 10^5$, $1 <= k <= 10^4$. Target $O(n + k)$.
Edge cases: empty, negative sums, all values already divisible by `k`.

*The follow-up:* "why did your first version fail on negative numbers?"
]

#sol[
Two prefix sums leave the same remainder when divided by `k` exactly when the piece
between them is divisible by `k`. So count remainders, not prefix values. There are only
`k` different remainders, so a plain array beats a hash map here.
]

#code(lang: "js", caption: "Approach 1 — brute force (for checking)")[
```js
const divKBrute = (a, k) => {
  let total = 0;
  for (let i = 0; i < a.length; i++) {
    let s = 0;
    for (let j = i; j < a.length; j++) { s += a[j]; if (s % k === 0) total++; }
  }
  return total;
};
```
]

#code(lang: "js", caption: "Approach 2 — remainder counts")[
```js
const divKHash = (a, k) => {
  const cnt = new Array(k).fill(0);
  cnt[0] = 1;                       // the empty prefix has remainder 0
  let pre = 0, total = 0;
  for (const x of a) {
    pre += x;
    let r = pre % k;
    if (r < 0) r += k;              // -7 % 5 is -2 in JS; we want 3
    total += cnt[r];
    cnt[r]++;
  }
  return total;
};
```
]

Both agree:

#table(columns: 3,
  [*array*], [*k*], [*answer*],
  [`{4,5,0,-2,-3,1}`], [5], [7],
  [`{}`], [3], [0],
  [`{7}`], [7], [1],
  [`{-1,-1,-1}`], [3], [1],
  [`{5,5,5}`], [5], [6],
  [`{1,2}`], [1], [3],
)

#subsection[The follow-up answered]

In C++, `%` keeps the sign of the left operand: `-7 % 5` is `-2`, not `3`. Without the
`if (r < 0) r += k;` line, the prefix with sum $-7$ and the prefix with sum $3$ get
different slots even though both are "remainder 3", and you undercount. It also indexes
`cnt[-2]`, which is out of bounds — undefined behaviour, and often a crash. Test
`{-1,-1,-1}` with $k = 3$ catches it.

#complexity(time: "O(n + k)", space: "O(k)")

#ex(25, tier: 3, asked: "Microsoft · pattern")[
Design a container with `insert(v)`, `erase(v)` and `getRandom()`, *all* $O(1)$ average.
`getRandom` must pick uniformly among the current values.
Edge cases: erase a value that is not there, erase the last remaining value, insert a
duplicate.

*The follow-up:* "now allow duplicates."
]

#sol[
A `vector` gives $O(1)$ random access but $O(n)$ erase-from-the-middle. A hash map gives
$O(1)$ erase but no random pick. Use both: the vector holds the values with no holes,
the map says where each value sits in the vector.

To erase from the middle in $O(1)$, move the *last* item into the hole and shrink.
Order inside the vector does not matter, so nothing is lost.
]

#code(lang: "js", caption: "Vector + map, with the swap-with-last trick")[
```js
class RandomSet {
  constructor() {
    this.items = [];               // dense list of the current values
    this.where = new Map();        // value -> its index inside items
  }
  insert(v) {
    if (this.where.has(v)) return false;
    this.where.set(v, this.items.length);
    this.items.push(v);
    return true;
  }
  erase(v) {
    if (!this.where.has(v)) return false;
    const idx = this.where.get(v);
    const lastVal = this.items[this.items.length - 1];
    this.items[idx] = lastVal;     // move the last item into the hole
    this.where.set(lastVal, idx);
    this.items.pop();
    this.where.delete(v);          // delete AFTER the move, or v === lastVal breaks
    return true;
  }
  getRandom() {
    return this.items[Math.floor(Math.random() * this.items.length)];
  }
  get size() { return this.items.length; }
}
```
]

Tested. `insert(4) insert(4) insert(9) erase(7) erase(4)` prints `1 0 1 0 1`, and the
one remaining value is `9`. Erasing the only element works and leaves size 0. With
values `{10, 20, 30}` and 30000 draws the tally was `10:10086  20:9929  30:9985` —
close to a third each, as it must be.

#trap[
Order matters inside `erase`. If you erase the map entry for `v` first and `v` happens
to *be* the last item, the line `where[lastVal] = idx` then re-creates a dead entry for
a value you just deleted. Always move first, erase second.
]

#subsection[The follow-up: allow duplicates]

Change the map to `Map<number, Set<number>>`: value $arrow.r$ *the set of
indices* holding it. `insert` appends and adds the new index. `erase` takes any one index
out of that set, does the same swap-with-last, and fixes the moved value's index set
(remove the old index, add the new one). All still $O(1)$ average; memory grows to
$O(n)$ set nodes.

#ex(26, tier: 3, asked: "Adobe · pattern")[
Build a fixed-size cache with $O(1)$ `get` and `put`. When it is full, throw out the
key that was used least recently.
Edge cases: capacity 1, updating a key that is already present, getting a missing key.

*The follow-up:* "now every entry also expires after T seconds."
]

#sol[
You need two things at once: find a key fast, and know the order of use. A hash map does
the first; a doubly linked list does the second. Store an *iterator into the list*
inside the map, and `list::splice` moves a node to the front in $O(1)$ without copying.
]

#code(lang: "js", caption: "Hash map + doubly linked list")[
```js
class LRUCache {
  constructor(capacity) {
    this.cap = capacity;
    this.m = new Map();            // iteration order: oldest key first, newest last
  }
  get(key) {
    if (!this.m.has(key)) return -1;
    const v = this.m.get(key);
    this.m.delete(key);
    this.m.set(key, v);            // delete + set = move to the newest end
    return v;
  }
  put(key, value) {
    if (this.m.has(key)) this.m.delete(key);
    else if (this.m.size === this.cap) this.m.delete(this.m.keys().next().value);
    this.m.set(key, value);        // keys().next().value is the oldest key
  }
}
```
]

Traced run with capacity 2:

#table(columns: 3,
  [*call*], [*returns*], [*cache after, newest first*],
  [`put(1,10)`], [—], [(1,10)],
  [`put(2,20)`], [—], [(2,20) (1,10)],
  [`get(1)`], [10], [(1,10) (2,20)],
  [`put(3,30)`], [—], [(3,30) (1,10)  — key 2 evicted],
  [`get(2)`], [-1], [(3,30) (1,10)],
  [`get(3)`], [30], [(3,30) (1,10)],
  [`put(1,11)`], [—], [(1,11) (3,30)],
  [`get(1)`], [11], [(1,11) (3,30)],
)

With capacity 1: `put(5,50)` then `put(6,60)` gives `get(5) = -1` and `get(6) = 60`.

#trap[
`splice` keeps the node alive, so the iterator stored in the map stays valid. If you
instead `erase` the node and `push_front` a copy, the old iterator becomes dangling and
you must remember to re-store the new one. Every LRU bug in interviews is a stale
iterator.
]

#subsection[The follow-up: entries expire after T seconds]

Store the insertion time inside each node. On `get`, if `now - stored > T`, delete the
node and return "miss". Stale nodes that are never touched still waste memory, so add a
*second* structure ordered by expiry time — a `min-heap` of (expiry, key) — and pop
expired keys lazily on each operation. Amortised cost stays $O(1)$ for the map part plus
$O(log n)$ for each real expiry, and each key expires at most once.

#ex(27, tier: 3, asked: "Uber · pattern")[
Longest stretch of an array that holds at most `k` different values.
$n <= 10^5$. Target $O(n)$.
Edge cases: $k = 0$, $k >= n$, empty array.

*The follow-up:* "now count the stretches with *exactly* `k` different values."
]

#sol[
Grow the window on the right. While it holds too many kinds, shrink from the left. Erase
a key from the map the moment its count hits zero — otherwise `cnt.size()` lies.
]

#code(lang: "js", caption: "Window with a count map")[
```js
const longestAtMostK = (a, k) => {
  if (k <= 0) return 0;
  const cnt = new Map();
  let left = 0, best = 0;
  for (let right = 0; right < a.length; right++) {
    cnt.set(a[right], (cnt.get(a[right]) ?? 0) + 1);
    while (cnt.size > k) {                    // too many kinds: shrink
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

On `{1,2,1,3,4,3,3}`: $k = 2$ gives `4` (the tail `3,4,3,3`), $k = 1$ gives `2`,
$k = 7$ gives `7`. On `{}` with $k = 3$ it gives `0`, on `{5}` with $k = 1$ it gives `1`,
on `{5,5}` with $k = 0$ it gives `0`.

#trap[
`cnt.erase(...)` when the count reaches 0 is not optional. Leave the zero entry in and
`cnt.size()` keeps counting values that already left the window, so the window never
grows again.
]

#subsection[The follow-up: exactly k]

"Exactly `k`" has no direct window, because shrinking on "too many" and growing on "too
few" fight each other. The standard move is a subtraction:

$ "exactly"(k) = "atMost"(k) - "atMost"(k-1) $

This works for *counting stretches*, not for *lengths*. So write the counting version.

#code(lang: "js", caption: "Count version, then subtract")[
```js
const countAtMostK = (a, k) => {
  if (k <= 0) return 0;
  const cnt = new Map();
  let left = 0, total = 0;
  for (let right = 0; right < a.length; right++) {
    cnt.set(a[right], (cnt.get(a[right]) ?? 0) + 1);
    while (cnt.size > k) {
      const c = cnt.get(a[left]) - 1;
      if (c === 0) cnt.delete(a[left]); else cnt.set(a[left], c);
      left++;
    }
    total += right - left + 1;      // every window ending at `right` is valid
  }
  return total;
};

const countExactlyK = (a, k) => countAtMostK(a, k) - countAtMostK(a, k - 1);
```
]

Tested: `({1,2,1,2,3}, 2)` gives `7`; `({1,1,1}, 1)` gives `6`; `({}, 1)` gives `0`.

#note[
`total += right - left + 1` is the line to understand. Once the window `[left, right]`
is legal, *every* window that ends at `right` and starts at or after `left` is also
legal, and there are `right - left + 1` of them.
]

#ex(28, tier: 3, asked: "D. E. Shaw · pattern")[
Your $O(n)$ hash solution passes locally and times out on the judge with $n = 10^5$.
Explain what happened and fix it.

*The follow-up:* "how would you use a pair of ints as a key?"
]

#sol[
In JavaScript this is almost never a hash collision. `Map` and `Set` are real hash tables
and they behave. What times out is a *container that only looks like* a hash table:

+ an array with `.includes(x)` inside the loop — that is a linear scan per element, so
  the loop is secretly $O(n^2)$;
+ an array used as a queue with `.shift()` — each `shift` moves every remaining element
  down one slot, again $O(n^2)$;
+ a plain object used with keys that are added and `delete`d in a mixed pattern, which
  pushes the object out of its fast shape.

The fix is to name the real container: `Set` for membership, a head index (or the
toolkit `Deque`) for a queue, `Map` for counts. Measure it and the difference is not
subtle.
]

#code(lang: "js", caption: "The same two loops, right and wrong")[
```js
const n = 100000;
const data = Array.from({ length: n }, (_, i) => i * 7);

// (1) an array pretending to be a set — the loop is secretly O(n^2)
let t = Date.now();
const seenArr = [];
for (const x of data) if (!seenArr.includes(x)) seenArr.push(x);
const t1 = Date.now() - t;

// (2) the same loop with a Set
t = Date.now();
const seenSet = new Set();
for (const x of data) seenSet.add(x);
const t2 = Date.now() - t;

// (3) an array used as a queue: every shift() moves the whole array down
t = Date.now();
const q = [...data];
while (q.length) q.shift();
const t3 = Date.now() - t;

// (4) the same queue with a head index — this is what the toolkit Deque does
t = Date.now();
const q2 = [...data];
let head = 0;
while (head < q2.length) head++;
const t4 = Date.now() - t;

console.log("includes  ms", t1, " Set ms", t2);
console.log("shift     ms", t3, " head index ms", t4);
console.log("sizes", seenArr.length, seenSet.size);
```
]

The blow-up, measured on 100000 values:

#code(lang: "text", caption: "measured output — node, one run")[
```text
includes  ms 6456  Set ms 26
shift     ms 971  head index ms 2
sizes 100000 100000
```
]

`includes` took *six and a half seconds*; the `Set` took 26 milliseconds. Same data, same
machine, same number of keys. That is the $O(n^2)$ blow-up in the flesh — and neither
line looks slow when you read it.

#trap[
Exact times move with the machine and the Node version. What does not move is the
*shape*: two of these grow like $n^2$ and two like $n$. Quote the shape in an interview,
not the milliseconds.
]

#subsection[The follow-up: a pair as a key]

A `Map` keyed on an *array* does not work: `m.set([1,2], 9)` and `m.get([1,2])` are two
different array objects, so the lookup misses. `Map` compares keys by identity, not by
contents. Three clean fixes:

+ Join the two numbers into a string key with a separator.
+ Pack both into one number, while the result stays inside $2^53 - 1$.
+ Pack both into one `BigInt`, which has no ceiling at all.

#code(lang: "js", caption: "Packing two ints into one key")[
```js
const packPair = (a, b) => `${a},${b}`;              // always correct

const packNum = (a, b) => a * 4294967296 + (b >>> 0);  // faster, but only while
                                                       // the result stays under 2^53 - 1
const packBig = (a, b) => (BigInt(a) << 32n) | BigInt(b >>> 0);   // no ceiling at all
```
]

Tested: storing under `packPair(3, -7)` and `packPair(-7, 3)` creates *two* entries with
values 1 and 5, so the order of the pair is preserved, and `packNum` keeps them apart too.
`packBig(3, -7)` prints `17179869177` and `packBig(-7, 3)` prints `-30064771069`.

#trap[
The `>>> 0` matters. It forces `b` into an unsigned 32-bit value before it is added in;
without it a negative `b` carries its sign and collides with a different pair. Write
`(b >>> 0)`, not `b`, every time you pack.
]

#trick[
When you are unsure, use the string key. `` `${a},${b}` `` is a few times slower than the
number version and always correct, including for negatives, floats and values past
$2^53$. Correct and fast enough beats clever and wrong.
]

#ex(29, tier: 3, asked: "Goldman Sachs · pattern")[
Characters arrive one at a time. After each arrival, report the first character so far
that has appeared exactly once, or `#sym.hash` if none.
Target: $O(1)$ amortised per character.

*The follow-up:* "now it must also handle removals."
]

#sol[
Keep a count table and a queue of candidates in arrival order. On each arrival, push the
character and then throw away any characters at the *front* of the queue whose count has
grown past 1. Each character is pushed once and popped at most once, so the work per
arrival is $O(1)$ amortised.
]

#code(lang: "js", caption: "Count table + candidate queue")[
```js
const { Deque } = require('./toolkit.js');   // see the JS Toolkit appendix

class FirstUniqueStream {
  constructor() {
    this.cnt = new Map();
    this.q = new Deque();                    // candidates, oldest first
  }
  add(c) {
    this.cnt.set(c, (this.cnt.get(c) ?? 0) + 1);
    this.q.push(c);
    while (this.q.size > 0 && this.cnt.get(this.q.front()) > 1) this.q.shift();  // stale head
    return this.q.size === 0 ? '#' : this.q.front();
  }
}
```
]

Feeding `"aabcbd"` prints `a#bbcc`. Step by step: `a` is unique; the second `a` makes it
repeat so nothing is unique; `b` arrives and is unique; `c` arrives but `b` is still
older and unique; the second `b` pushes the answer to `c`; `d` arrives but `c` is older.
Feeding `"zzz"` prints `z##`. A single `q` prints `q`.

#trap[
Do not pop from the *middle* of the queue when a count grows. A queue cannot do that.
Instead leave the stale entries in and skip them at the front — that is the whole trick,
and it is why the cost is *amortised* $O(1)$, not worst-case $O(1)$.
]

#subsection[The follow-up: removals too]

A queue can no longer work, because removing a character can make an *old* character
unique again and the queue has already thrown it away. Switch to a doubly linked list of
unique characters plus a map `character -> node`. Adding a second copy unlinks the node
in $O(1)$; a removal that brings a count back to 1 re-links the node. Order is then kept
by the list, not by arrival into a queue. The structure is the same map-plus-list pairing
used in the LRU cache.

#section[Dry run — count the stretches summing to k]

Take `a = {3, 1, -2, 4, -2, 2}` and `k = 3`. We run `countSumHash` from Example 17 and
write down every variable after each step.

The map starts as `{0: 1}` — the empty prefix.

#table(columns: 7,
  [*i*], [*a[i]*], [*pre*], [*pre - k*], [*found*], [*total*], [*map after*],
  [0], [3],  [3], [0],  [1], [1], [`{0:1, 3:1}`],
  [1], [1],  [4], [1],  [0], [1], [`{0:1, 3:1, 4:1}`],
  [2], [-2], [2], [-1], [0], [1], [`{0:1, 3:1, 4:1, 2:1}`],
  [3], [4],  [6], [3],  [1], [2], [`{0:1, 3:1, 4:1, 2:1, 6:1}`],
  [4], [-2], [4], [1],  [0], [2], [`{0:1, 3:1, 4:2, 2:1, 6:1}`],
  [5], [2],  [6], [3],  [1], [3], [`{0:1, 3:1, 4:2, 2:1, 6:2}`],
)

Answer: *3*.

Reading the table:

- *Row i = 0.* `pre` becomes 3. We need an earlier prefix of $3 - 3 = 0$. The map has
  `0` once — that is the empty prefix, which sits just before index 0. So the stretch
  from index 0 to index 0 works: `{3}`. Total 1.
- *Row i = 1.* `pre` is 4, we need 1. No prefix equals 1. Nothing found.
- *Row i = 2.* `pre` is 2, we need $-1$. Not present.
- *Row i = 3.* `pre` is 6, we need 3. Prefix 3 was recorded at the end of index 0. The
  stretch after it is indices 1..3: `{1, -2, 4}`, which sums to 3. Total 2.
- *Row i = 4.* `pre` is 4 again, we need 1. Not present. But note the map entry for `4`
  goes from 1 to 2 — that second copy will matter later if some prefix needs 4.
- *Row i = 5.* `pre` is 6, we need 3. Prefix 3 is still there once. The stretch is
  indices 1..5: `{1, -2, 4, -2, 2}`, which sums to 3. Total 3.

Checking by hand: the stretches summing to 3 are `{3}` at index 0, `{1,-2,4}` at
indices 1..3, and `{1,-2,4,-2,2}` at indices 1..5. Three of them. The brute-force
version also prints 3.

#note[
Notice that *nothing in the table ever looks forward*. The map only ever holds prefixes
that finished before the current index. That is the invariant from page one, in action.
]

#section[Python, for the three signature problems]

Python is meaningfully shorter for these three. Everything else in this chapter is
almost line-for-line the same, so C++ is enough.

#code(lang: "python", caption: "The same three algorithms")[
```python
from collections import defaultdict

def count_sum_k(a, k):
    seen = defaultdict(int)
    seen[0] = 1
    pre = total = 0
    for x in a:
        pre += x
        total += seen[pre - k]      # defaultdict gives 0 for a missing key
        seen[pre] += 1
    return total

def longest_run(a):
    s = set(a)
    best = 0
    for x in s:
        if x - 1 in s:
            continue
        y, ln = x, 1
        while y + 1 in s:
            y += 1
            ln += 1
        best = max(best, ln)
    return best

def group_anagrams(words):
    table = defaultdict(list)
    for w in words:
        table[tuple(sorted(w))].append(w)    # a tuple is hashable, a list is not
    return sorted(table.values())
```
]

Run output:

#code(lang: "text", caption: "output")[
```text
2 0 6 4
4 0 1 3
[['bat'], ['tan', 'nat'], ['tea', 'eat', 'ate']]
[]
```
]

#trap[
In Python, `seen[pre - k]` on a plain `dict` raises `KeyError`. Either use
`defaultdict(int)` as above, or write `seen.get(pre - k, 0)`. Also note that
`table[list] ` fails — a list cannot be a dict key because it can change. Use a tuple.
]

#section[Practice]

#practice(tier: 1, time: "12 min")[
+ Count how many values appear *exactly once* in an array.
+ Can the array be split into pairs of equal values? (Every value must appear an even
  number of times.)
+ Given a list of words, return the first word that appears twice, or the empty string.
+ Find the smallest positive integer that is *not* in the array. Values may be negative.
+ Count the stretches of an array that contain exactly `k` odd numbers.
+ Return the distinct values that appear in the first array but not in the second.
+ Can the string `note` be built from the letters of `pool`, each letter used at most as
  many times as it appears in `pool`?
]

#practice(tier: 2, time: "18 min")[
8. Length of the longest stretch whose sum is exactly 0.
9. Count index pairs $i < j$ with `a[i] == a[j]`.
10. Does a string have all-distinct characters?
11. Group values by their remainder mod `m` and report the size of the biggest group.
    `m >= 1`, values may be negative.
12. Return every value that appears *more than* $n\/3$ times. Use $O(1)$ extra space.
13. Are two strings *isomorphic* — is there a one-to-one letter mapping turning the
    first into the second?
14. For every window of length `w`, report how many distinct values it holds.
]

#key[
*1.* Count with a map, then count the entries whose value is 1.

#code(lang: "js", caption: "1 — values appearing exactly once")[
```js
const countSingles = (a) => {
  const c = new Map();
  for (const x of a) c.set(x, (c.get(x) ?? 0) + 1);
  return [...c.values()].filter((v) => v === 1).length;
};
```
]
Tested: `{3,1,3,5,-2}` $arrow.r$ `3`; `{}` $arrow.r$ `0`; `{8,8}` $arrow.r$ `0`;
`{0}` $arrow.r$ `1`.

*2.* Odd length fails immediately. Then every count must be even.

#code(lang: "js", caption: "2 — split into equal pairs")[
```js
const pairsUp = (a) => {
  if (a.length % 2) return false;
  const c = new Map();
  for (const x of a) c.set(x, (c.get(x) ?? 0) + 1);
  return [...c.values()].every((v) => v % 2 === 0);
};
```
]
Tested: `{2,5,5,2}` $arrow.r$ `1`; `{2,5,5}` $arrow.r$ `0`; `{}` $arrow.r$ `1`;
`{7,7,7,7}` $arrow.r$ `1`; `{1,2}` $arrow.r$ `0`.

*3.* `insert(...).second` is `false` when the word was already there.

#code(lang: "js", caption: "3 — first repeated word")[
```js
const firstRepeatWord = (w) => {
  const seen = new Set();
  for (const s of w) {
    if (seen.has(s)) return s;
    seen.add(s);
  }
  return '';
};
```
]
Tested: `{"red","blue","red","blue"}` $arrow.r$ `red`; `{"a","b"}` $arrow.r$ empty;
`{}` $arrow.r$ empty; `{"x","x"}` $arrow.r$ `x`.

*4.* Ignore everything that is not positive. Then try 1, 2, 3, ... The loop runs at most
$n+1$ times, because after $n$ successful hits the array is exhausted.

#code(lang: "js", caption: "4 — smallest missing positive")[
```js
const smallestMissingPositive = (a) => {
  const s = new Set(a.filter((x) => x > 0));
  let v = 1;
  while (s.has(v)) v++;
  return v;
};
```
]
Tested: `{3,4,-1,1}` $arrow.r$ `2`; `{1,2,3}` $arrow.r$ `4`; `{}` $arrow.r$ `1`;
`{-5,-1}` $arrow.r$ `1`; `{2,2,2}` $arrow.r$ `1`.

*5.* Replace each value by 1 if odd and 0 if even. Now it is "count stretches with sum
k" from Example 17. Note `x % 2 != 0` works for negatives; `x % 2 == 1` does not, because
`-3 % 2` is `-1` in C++.

#code(lang: "js", caption: "5 — stretches with exactly k odd numbers")[
```js
const subarraysWithKOdds = (a, k) => {
  const seen = new Map([[0, 1]]);
  let pre = 0, total = 0;
  for (const x of a) {
    pre += x % 2 !== 0 ? 1 : 0;       // correct for negatives too
    total += seen.get(pre - k) ?? 0;
    seen.set(pre, (seen.get(pre) ?? 0) + 1);
  }
  return total;
};
```
]
Checked against brute force: `({1,1,2,1,1}, 3)` $arrow.r$ `2`; `({2,4,6}, 0)`
$arrow.r$ `6`; `({}, 0)` $arrow.r$ `0`; `({-3}, 1)` $arrow.r$ `1`; `({5}, 2)`
$arrow.r$ `0`.

*6.* Same skeleton as Example 9, condition flipped. See Example 15 for the code; tested
`({1,2,2,3},{2,4})` $arrow.r$ `[1,3]`.

*7.* Count the pool, then spend it.

#code(lang: "js", caption: "7 — can the note be built")[
```js
const canBuild = (note, pool) => {
  const c = new Map();
  for (const ch of pool) c.set(ch, (c.get(ch) ?? 0) + 1);
  for (const ch of note) {
    const left = (c.get(ch) ?? 0) - 1;
    if (left < 0) return false;
    c.set(ch, left);
  }
  return true;
};
```
]
Tested: `("aab","aabbc")` $arrow.r$ `1`; `("aaa","aab")` $arrow.r$ `0`;
`("","x")` $arrow.r$ `1`; `("x","")` $arrow.r$ `0`; `("ab","ba")` $arrow.r$ `1`.

*8.* Example 16 with `k = 0`.

#code(lang: "js", caption: "8 — longest zero-sum stretch")[
```js
const longestZeroSum = (a) => {
  const first = new Map([[0, -1]]);
  let pre = 0, best = 0;
  for (let i = 0; i < a.length; i++) {
    pre += a[i];                      // 1e5 values of 1e9 reach 1e14 — still exact
    if (first.has(pre)) best = Math.max(best, i - first.get(pre));
    else first.set(pre, i);
  }
  return best;
};
```
]
Tested: `{4,-1,-3,2,1,-2}` $arrow.r$ `3`; `{1,2,3}` $arrow.r$ `0`; `{}` $arrow.r$ `0`;
`{0}` $arrow.r$ `1`; `{2000000000, 2000000000, -2000000000, -2000000000}` $arrow.r$ `4`.

*9.* A value with `c` copies gives $c(c-1)\/2$ pairs. At $n = 2 times 10^5$ all equal,
the answer is about $2 times 10^10$ — an `int` in C++ would wrap here, a JavaScript
number does not.

#code(lang: "js", caption: "9 — equal-value index pairs")[
```js
const goodPairs = (a) => {
  const c = new Map();
  for (const x of a) c.set(x, (c.get(x) ?? 0) + 1);
  let t = 0;
  for (const v of c.values()) t += v * (v - 1) / 2;
  return t;
};
```
]
Tested: `{1,2,1,1}` $arrow.r$ `3`; `{}` $arrow.r$ `0`; `{9}` $arrow.r$ `0`;
`{4,4}` $arrow.r$ `1`; 200000 copies of 7 $arrow.r$ `19999900000`.

*10.* A 256-slot boolean array is the table.

#code(lang: "js", caption: "10 — all characters distinct")[
```js
const allUnique = (s) => new Set(s).size === s.length;
```
]
Tested: `"abcd"` $arrow.r$ `1`; `"abca"` $arrow.r$ `0`; `""` $arrow.r$ `1`;
`"q"` $arrow.r$ `1`.

*11.* Normalise the remainder for negatives, exactly as in Example 24.

#code(lang: "js", caption: "11 — biggest remainder group")[
```js
const biggestRemainderGroup = (a, m) => {
  const c = new Map();
  for (const x of a) {
    let r = x % m;
    if (r < 0) r += m;
    c.set(r, (c.get(r) ?? 0) + 1);
  }
  return c.size === 0 ? 0 : Math.max(...c.values());
};
```
]
Tested: `({3,6,7,10,13}, 3)` $arrow.r$ `3`; `({-3,-6,3}, 3)` $arrow.r$ `3`;
`({}, 5)` $arrow.r$ `0`; `({4}, 1)` $arrow.r$ `1`.

*12.* At most two values can beat $n\/3$. Run *two* vote counters side by side, then
verify both.

#code(lang: "js", caption: "12 — values over n/3")[
```js
const overOneThird = (a) => {
  let c1 = 0, c2 = 0, v1 = 0, v2 = 1;        // v1 !== v2 to start
  for (const x of a) {
    if (x === v1) c1++;
    else if (x === v2) c2++;
    else if (c1 === 0) { v1 = x; c1 = 1; }
    else if (c2 === 0) { v2 = x; c2 = 1; }
    else { c1--; c2--; }
  }
  let n1 = 0, n2 = 0;
  for (const x of a) { if (x === v1) n1++; else if (x === v2) n2++; }
  const out = [];
  if (n1 > a.length / 3) out.push(v1);
  if (n2 > a.length / 3) out.push(v2);
  return out.sort((p, q) => p - q);          // numeric comparator
};
```
]
Tested: `{2,2,1,1,1,2,2}` $arrow.r$ `[1,2]`; `{1,2,3}` $arrow.r$ `[]`;
`{}` $arrow.r$ `[]`; `{5,5}` $arrow.r$ `[5]`; `{0,0,0,1,1,1,2}` $arrow.r$ `[0,1]`.

The order of the `else if` chain matters: matching an existing candidate must be checked
*before* filling an empty slot, or the same value can occupy both slots.

*13.* One map is not enough — it would call `("ab","aa")` isomorphic. You need the
mapping to work in *both* directions.

#code(lang: "js", caption: "13 — isomorphic strings")[
```js
const isomorphic = (s, t) => {
  if (s.length !== t.length) return false;
  const fwd = new Map(), bwd = new Map();
  for (let i = 0; i < s.length; i++) {
    const a = s[i], b = t[i];
    if (!fwd.has(a) && !bwd.has(b)) { fwd.set(a, b); bwd.set(b, a); }
    else if (fwd.get(a) !== b || bwd.get(b) !== a) return false;
  }
  return true;
};
```
]
Tested: `("paper","title")` $arrow.r$ `1`; `("foo","bar")` $arrow.r$ `0`;
`("","")` $arrow.r$ `1`; `("ab","aa")` $arrow.r$ `0`; `("aa","ab")` $arrow.r$ `0`;
`("a","z")` $arrow.r$ `1`.

*14.* A sliding window with a count map. Erase a key when its count reaches 0, or
`c.size()` over-reports.

#code(lang: "js", caption: "14 — distinct values per window")[
```js
const distinctPerWindow = (a, w) => {
  const out = [];
  const n = a.length;
  if (w <= 0 || w > n) return out;
  const c = new Map();
  for (let i = 0; i < n; i++) {
    c.set(a[i], (c.get(a[i]) ?? 0) + 1);
    if (i >= w) {
      const left = c.get(a[i - w]) - 1;
      if (left === 0) c.delete(a[i - w]); else c.set(a[i - w], left);
    }
    if (i >= w - 1) out.push(c.size);
  }
  return out;
};
```
]
Tested: `({1,2,1,3,4,3}, 3)` $arrow.r$ `[2,3,3,2]`; `({5,5,5}, 2)` $arrow.r$ `[1,1]`;
`({}, 1)` $arrow.r$ `[]`; `({1,2}, 5)` $arrow.r$ `[]`; `({7}, 1)` $arrow.r$ `[1]`.
]

#revision[
*The reflex.* About to write a loop inside a loop? Ask what the inner loop searches for.
Store that in a hash table and the inner loop disappears.

*Template 1 — counting*
#code(lang: "js", caption: "")[
```js
const freq = new Map();
for (const x of a) freq.set(x, (freq.get(x) ?? 0) + 1);
```
]

*Template 2 — prefix sum + map (the highest-value pattern in this chapter)*
#code(lang: "js", caption: "")[
```js
const seen = new Map([[0, 1]]);    // counts      -> "how many subarrays"
let pre = 0, total = 0;            // first index  -> "longest subarray"
for (const x of a) {
  pre += x;
  total += seen.get(pre - k) ?? 0;
  seen.set(pre, (seen.get(pre) ?? 0) + 1);   // AFTER the lookup, always
}
```
]

*Template 3 — window with a count map*
#code(lang: "js", caption: "")[
```js
const cnt = new Map();
let left = 0;
for (let right = 0; right < n; right++) {
  cnt.set(a[right], (cnt.get(a[right]) ?? 0) + 1);
  while (/* window is illegal */) {
    const c = cnt.get(a[left]) - 1;
    if (c === 0) cnt.delete(a[left]); else cnt.set(a[left], c);
    left++;
  }
  // record the answer for this right
}
```
]

*When to use what*
#table(columns: 3,
  [*Goal*], [*Store*], [*Read*],
  [seen before?], [`Set`], [`seen.has(x)`],
  [how many times?], [`Map`], [`freq.get(x) ?? 0`],
  [longest subarray, property P], [first index of each prefix value], [`i - firstIdx.get(need)`],
  [count of subarrays, property P], [count of each prefix value], [`total += seen.get(need) ?? 0`],
  [divisible by k], [count of each *remainder*], [`((x % k) + k) % k` first],
  [group by shape], [canonical string key], [`(m.get(key) ?? []).push(x)`],
  [O(1) insert/delete/random], [array + `Map` of positions], [swap with last],
  [LRU], [`Map` alone — it keeps insertion order], [delete then re-set to refresh],
)

*Complexity*
#table(columns: 4,
  [*Operation*], [*`Map` / `Set`*], [*sorted array + binary search*], [*array of 256*],
  [insert / get / delete], [$O(1)$ expected], [$O(n)$ insert, $O(log n)$ find], [$O(1)$ always],
  [worst case], [$O(n)$ per op], [$O(n)$], [$O(1)$],
  [keys in sorted order], [no — sort at the end], [yes, always], [yes, by index],
  [memory per entry], [high], [low], [lowest],
)

*Top traps*
+ `seen.set(0, 1)` (or `firstIdx.set(0, -1)`) missing $arrow.r$ subarrays starting at
  index 0 are lost.
+ Inserting *before* the lookup $arrow.r$ an element pairs with itself.
+ Overwriting `firstIdx` for a repeated prefix $arrow.r$ the "longest" answer is too short.
+ `freq.get(x) + 1` without `?? 0` $arrow.r$ `NaN` on the first sighting.
+ `pre % k` is negative in JavaScript for negative `pre` $arrow.r$ use `((pre % k) + k) % k`.
+ Not deleting a zero count $arrow.r$ `cnt.size` lies inside a sliding window.
+ A plain object instead of a `Map` $arrow.r$ `1` and `"1"` collapse into one key.
+ An array or object used as a `Map` key $arrow.r$ compared by identity, so the lookup
  always misses. Join it into a string first.
+ Forgetting the verify pass after Boyer-Moore voting.
+ `arr.includes(x)` inside a loop instead of a `Set` $arrow.r$ silently $O(n^2)$.
+ Building a group key without separators $arrow.r$ `(1,11)` and `(11,1)` collide.
]

]
