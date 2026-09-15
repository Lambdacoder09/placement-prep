#import "../../shared/lib/style.typ": *

#show: chapter.with(
  num: 3,
  title: "Two Pointers & Sliding Window",
  tagline: "Turn a double loop into a single walk.",
)

#section[Pattern in one page]

An array question with two nested loops is almost always $O(n^2)$. For $n = 10^5$ that is
ten billion steps. Too slow. The fix, very often, is to keep *two indexes* and move each of
them forward only. Each index moves at most $n$ times, so the whole scan is $O(n)$.

There are three shapes. Learn to tell them apart in ten seconds.

#formulas(title: "The three shapes")[
*Shape A — opposite ends.* Start `i = 0`, `j = a.length - 1`. Move them towards each other.
Use when the array is *sorted*, or when the answer depends on a pair taken from the two
ends (pair sum, palindrome, water between two walls, reverse).

*Shape B — fixed window of size k.* Add the new element on the right, drop the element
that fell off the left. The window size never changes.

*Shape C — variable window (the real sliding window).* `right` always moves forward.
`left` moves forward only while the window is *bad*. The window is a valid answer the
moment the inner `while` stops.

The whole family shares one invariant: *no index ever moves backwards.* If you ever write
`left--` or `right--`, you have left the pattern.
]

#subsection[Template A — two ends]

#code(lang: "js", caption: "Opposite ends, sorted array")[
```js
let i = 0, j = a.length - 1;
while (i < j) {
  // decide using a[i] and a[j]
  if (needBigger) i++;
  else if (needSmaller) j--;
  else { /* found it */ }
}
```
]

#subsection[Template B — fixed window of size k]

#code(lang: "js", caption: "Fixed window: build once, then slide")[
```js
let sum = 0;
for (let i = 0; i < k; i++) sum += a[i];   // first window
let best = sum;
for (let i = k; i < n; i++) {
  sum += a[i] - a[i - k];                  // gain right, lose left
  best = Math.max(best, sum);
}
```
]

#subsection[Template C — variable window]

#code(lang: "js", caption: "Grow right, shrink left while the window is bad")[
```js
let left = 0;
for (let right = 0; right < n; right++) {
  add(a[right]);                  // window is now [left .. right]
  while (windowIsBad()) {
    remove(a[left]);
    left++;
  }
  best = Math.max(best, right - left + 1);   // longest-valid problems
}
```
]

#note[
For *longest valid* problems the answer is read *after* the `while`.
For *shortest valid* problems the `while` condition flips to "window is *good*", and the
answer is read *inside* the `while`, just before you shrink. Get this backwards and every
test case fails.
]

#diagram(height: 2.9cm, caption: "Shape C: right marches on, left only chases. The shaded cells are the window.")[
  #dnode(0cm,    0.3cm, 1.0cm, 0.8cm, "4")
  #dnode(1.15cm, 0.3cm, 1.0cm, 0.8cm, "2", fill: rgb("#dbe8f0"))
  #dnode(2.30cm, 0.3cm, 1.0cm, 0.8cm, "7", fill: rgb("#dbe8f0"))
  #dnode(3.45cm, 0.3cm, 1.0cm, 0.8cm, "1", fill: rgb("#dbe8f0"))
  #dnode(4.60cm, 0.3cm, 1.0cm, 0.8cm, "3")
  #dnode(5.75cm, 0.3cm, 1.0cm, 0.8cm, "6")
  #dnode(6.90cm, 0.3cm, 1.0cm, 0.8cm, "2")
  #darrow(1.65cm, 2.05cm, 1.65cm, 1.22cm, label: "left")
  #darrow(3.95cm, 2.05cm, 3.95cm, 1.22cm, label: "right")
]

#subsection[When to reach for it]

#table(
  columns: (1fr, 1.1fr),
  [*You see this in the question*], [*Reach for*],
  [sorted array, find a pair / triple], [Shape A, after sorting],
  ["every window of length k"], [Shape B],
  [longest / shortest subarray with some rule], [Shape C],
  ["at most K distinct", "at most k changes"], [Shape C with a `Map` of counts],
  [answer needs window max and min], [Shape C with two monotonic deques],
  [array has negative numbers and you need an exact sum], [*not* a window — use prefix sums plus a `Map`],
)

#trap[
Sliding window for *sum* problems only works when every value is positive (or zero). With
negatives, growing the window can make the sum smaller, so shrinking is no longer safe.
You will see a worked counter-example in Example 19.
]

#subsection[Three JavaScript facts you must know before you start]

#trap[
*`arr.sort()` sorts LEXICOGRAPHICALLY, as text.* Tested in Node:
`[10, 9, 1].sort()` returns `[1, 10, 9]`, because `"10" < "9"` as strings.
Numbers *always* need a comparator: `[10, 9, 1].sort((a, b) => a - b)` returns
`[1, 9, 10]`. This chapter sorts in four different problems. Every one of them uses the
comparator, and so must you.
]

#trap[
*Every JavaScript number is a double.* Whole numbers are exact only up to
`Number.MAX_SAFE_INTEGER`, which is `9007199254740991`, about $9 times 10^15$. Tested in
Node: `123456789 * 123456789` prints `15241578750190520`, but the true answer ends in
`521`. It is silently wrong by one.
The fix is `BigInt`: `BigInt(123456789) * BigInt(123456789)` gives
`15241578750190521n`, exactly. Use it whenever a product or a sum can pass
$9 times 10^15$.
]

#note[
*Use `Map`, not a plain object, for counting.* A plain object turns every key into a
string, so the number `1` and the text `"1"` collide. A `Map` keeps the type, keeps
insertion order, and is faster when you add and delete a lot — which is exactly what a
sliding window does.
]

#pagebreak(weak: true)
#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Reverse an array in place. You may not use a second array.
Constraints: $0 <= n <= 10^5$. Target $O(n)$ time, $O(1)$ extra space.
Edge cases: empty array, single element.
]
#sol[
Swap the two ends, then step inwards. JavaScript gives you a one-line swap through array
destructuring.

#code(lang: "js", caption: "Reverse with two pointers")[
```js
function reverseArr(a) {
  let i = 0, j = a.length - 1;
  while (i < j) {
    [a[i], a[j]] = [a[j], a[i]];
    i++;
    j--;
  }
}
```
]
Tested: `[3,8,1,9,4]` becomes `[4,9,1,8,3]`. `[7]` stays `[7]`. `[]` stays `[]`.
`[1,2,3,4]` becomes `[4,3,2,1]`.
#complexity(time: $O(n)$, space: $O(1)$, note: "n/2 swaps, so the loop runs n/2 times.")
#note[
`[a[i], a[j]] = [a[j], a[i]]` builds a tiny temporary array, then unpacks it. It is
clear and it is what interviewers expect in JavaScript, so use it.
]
]
#ans[the loop stops when `i >= j`, which also handles `n = 0` and `n = 1`]

#ex(2, tier: 0, asked: "warm-up")[
Check whether a string reads the same forwards and backwards.
Constraints: $0 <= |s| <= 10^5$. Target $O(n)$ / $O(1)$.
Edge cases: empty string (say yes), one character (say yes).
]
#sol[
#code(lang: "js", caption: "Palindrome check")[
```js
function isPalindrome(s) {
  let i = 0, j = s.length - 1;
  while (i < j) {
    if (s[i] !== s[j]) return false;
    i++;
    j--;
  }
  return true;
}
```
]
Tested: `"racecar"` gives `true`, `"abca"` gives `false`, `""` gives `true`, `"z"` gives
`true`, `"abba"` gives `true`.
#complexity(time: $O(n)$, space: $O(1)$)
#trick[
`s[i]` works on a JavaScript string and costs $O(1)$. Do *not* write
`s.split("").reverse().join("") === s` — it is $O(n)$ *space* and the interviewer will ask
you to do better.
]
]

#ex(3, tier: 0, asked: "warm-up")[
Move every zero to the end of the array. The order of the non-zero values must not change.
Constraints: $0 <= n <= 10^5$, values may be negative. Target $O(n)$ / $O(1)$.
Edge cases: all zeros, no zeros.
]
#sol[
This is the *slow / fast* pair. `read` looks at every slot. `write` marks where the next
non-zero belongs.

#code(lang: "js", caption: "Move zeros, keep order")[
```js
function moveZeros(a) {
  let write = 0;
  for (let read = 0; read < a.length; read++) {
    if (a[read] !== 0) {
      [a[write], a[read]] = [a[read], a[write]];
      write++;
    }
  }
}
```
]
Tested: `[0,5,0,3,12,0,7]` becomes `[5,3,12,7,0,0,0]`. `[0,0,0]` stays `[0,0,0]`.
`[4,-1,2]` stays `[4,-1,2]`.
#complexity(time: $O(n)$, space: $O(1)$)
#trick[
`write` is never ahead of `read`. So the swap either swaps a value with itself
(no zeros seen yet) or moves a non-zero forward into the first zero slot. Order is safe.
]
]

#ex(4, tier: 0, asked: "warm-up")[
Return the sum of every window of length $k$.
Constraints: $1 <= k <= n <= 10^5$. Target $O(n)$.
Edge cases: $k = n$, $k > n$ (return nothing), negative values.
]
#sol[
#approach(1, "Recompute each window", verdict: "O(n k)")
For each start, add $k$ values. With $n = 10^5$ and $k = 5 times 10^4$ that is five billion
additions.

#approach(2, "Slide", verdict: "O(n) — optimal")
Two neighbouring windows differ by exactly two values.

#code(lang: "js", caption: "Sums of all windows of length k")[
```js
function windowSums(a, k) {
  const out = [];
  const n = a.length;
  if (k <= 0 || k > n) return out;
  let sum = 0;
  for (let i = 0; i < k; i++) sum += a[i];
  out.push(sum);
  for (let i = k; i < n; i++) {
    sum += a[i];
    sum -= a[i - k];
    out.push(sum);
  }
  return out;
}
```
]
Tested: `windowSums([2,1,5,1,3,2], 3)` returns `[8,7,9,6]`. `windowSums([2,1], 5)` returns
`[]`. `windowSums([-3,4,-1], 1)` returns `[-3,4,-1]`.
#complexity(time: $O(n)$, space: $O(n)$, note: "O(1) extra if you only need the best window.")
#trap[
Check `k > n` *before* the first loop. Without that guard the first loop reads past the end,
`a[i]` gives `undefined`, and `sum` becomes `NaN` — which then compares `false` against
everything and hides the bug.
]
]

#ex(5, tier: 0, asked: "warm-up")[
Merge two sorted arrays into one sorted array.
Constraints: $0 <= n, m <= 10^5$. Target $O(n + m)$.
Edge cases: one array empty, both arrays full of the same value.
]
#sol[
#code(lang: "js", caption: "Classic merge")[
```js
function mergeSorted(a, b) {
  const out = [];
  let i = 0, j = 0;
  while (i < a.length && j < b.length) {
    if (a[i] <= b[j]) out.push(a[i++]);
    else out.push(b[j++]);
  }
  while (i < a.length) out.push(a[i++]);
  while (j < b.length) out.push(b[j++]);
  return out;
}
```
]
Tested: `[1,4,7]` and `[2,3,9,11]` give `[1,2,3,4,7,9,11]`. `[]` and `[2,3]` give `[2,3]`.
`[5,5]` and `[5]` give `[5,5,5]`.
#complexity(time: $O(n + m)$, space: $O(n + m)$)
#note[
`<=` (not `<`) keeps equal values in their original order. That property is called
*stability*, and it matters once you sort records by one field.
]
]

#ex(6, tier: 0, asked: "warm-up")[
A sorted array may hold repeats. Keep one copy of each value, at the front, and return the
new length. The tail of the array may hold anything.
Constraints: $0 <= n <= 10^5$. Target $O(n)$ / $O(1)$.
Edge cases: empty, all values equal.
]
#sol[
#code(lang: "js", caption: "Remove duplicates in place")[
```js
function removeDupSorted(a) {
  if (a.length === 0) return 0;
  let write = 1;
  for (let read = 1; read < a.length; read++) {
    if (a[read] !== a[write - 1]) {
      a[write] = a[read];
      write++;
    }
  }
  return write;
}
```
]
Tested: `[1,1,2,2,2,5,9,9]` returns `4` and the front becomes `[1,2,5,9]`.
`[]` returns `0`. `[4,4,4]` returns `1`.
#complexity(time: $O(n)$, space: $O(1)$)
]

#pagebreak(weak: true)
#section[Tier 1 — the template problems]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
A *sorted* array of prices and a budget `target`. Is there a pair of prices that adds up
to exactly `target`?
Constraints: $0 <= n <= 10^5$. Target $O(n)$ time, $O(1)$ space.
Edge cases: fewer than 2 elements; negative prices (a refund line).
]
#sol[
#approach(1, "Check every pair", verdict: "O(n^2), far too slow when n is 100000")
#code(lang: "js", caption: "Brute force")[
```js
function pairSumBrute(a, target) {
  for (let i = 0; i < a.length; i++)
    for (let j = i + 1; j < a.length; j++)
      if (a[i] + a[j] === target) return true;
  return false;
}
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "A Set of what you have seen", verdict: "O(n) time but O(n) space, and ignores the sorting")
#code(lang: "js", caption: "Remember what you have seen")[
```js
function pairSumSet(a, target) {
  const seen = new Set();
  for (const x of a) {
    if (seen.has(target - x)) return true;
    seen.add(x);
  }
  return false;
}
```
]
#complexity(time: $O(n)$, space: $O(n)$)

#approach(3, "Two pointers from the ends", verdict: "O(n) time, O(1) space — optimal")
Sum too small? The only way to grow it is to raise the small end, so `i++`.
Sum too big? The only way to shrink it is to lower the big end, so `j--`.
Nothing is ever skipped, because the value you throw away could not pair with *anything*
that is still in range.

#code(lang: "js", caption: "Two pointers on a sorted array")[
```js
function pairSumTwoPtr(a, target) {
  let i = 0, j = a.length - 1;
  while (i < j) {
    const s = a[i] + a[j];
    if (s === target) return true;
    if (s < target) i++;
    else j--;
  }
  return false;
}
```
]
Tested on `[1,3,4,7,11,15]`: target `15` gives `true` from all three versions, target `6`
gives `false` from all three. On `[-8,-3,0,2,5]`: target `-3` gives `true`, target `100`
gives `false`.
#complexity(time: $O(n)$, space: $O(1)$)

*The unlocking idea:* sorting turns "search everywhere" into "one direction is always
wrong", and that kills the inner loop.
#trick[
`Set.has` is the JavaScript answer to "have I seen this value". Do not reach for
`array.includes` — that is a full scan, and it turns approach 2 back into $O(n^2)$.
]
]

#ex(8, tier: 1, asked: "Infosys · pattern")[
Find the largest sum of any $k$ consecutive elements.
Constraints: $1 <= k <= n <= 10^5$, values may be negative.
Target $O(n)$. Edge cases: all values negative, $k = n$.
]
#sol[
#approach(1, "Add up each window", verdict: "O(n k)")
#code(lang: "js", caption: "Brute force")[
```js
function maxWindowBrute(a, k) {
  let best = -Infinity;
  for (let i = 0; i + k <= a.length; i++) {
    let s = 0;
    for (let j = i; j < i + k; j++) s += a[j];
    best = Math.max(best, s);
  }
  return best;
}
```
]
#complexity(time: $O(n k)$, space: $O(1)$)

#approach(2, "Slide the window", verdict: "O(n) — optimal")
#code(lang: "js", caption: "Fixed window, one pass")[
```js
function maxWindowSlide(a, k) {
  const n = a.length;
  if (k <= 0 || k > n) return -Infinity;
  let sum = 0;
  for (let i = 0; i < k; i++) sum += a[i];
  let best = sum;
  for (let i = k; i < n; i++) {
    sum += a[i] - a[i - k];
    best = Math.max(best, sum);
  }
  return best;
}
```
]
Tested: `[2,1,5,1,3,2]` with $k = 3$ gives `9` from both versions.
All-negative `[-4,-2,-7,-1]` with $k = 2$ gives `-6` from both.
`[5]` with $k = 1$ gives `5`.
#complexity(time: $O(n)$, space: $O(1)$)
#trap[
Starting with `best = 0` is the classic wrong answer here. If every value is negative the
true answer is negative, and `0` is not a real window. Start from the first window, or from
`-Infinity` — JavaScript has no `INT_MIN`, and `-Infinity` is the right idiom.
]
]

#ex(9, tier: 1, asked: "Accenture · pattern")[
Length of the longest stretch of a string with no repeated character.
Constraints: $0 <= |s| <= 10^5$. Target $O(n)$.
Edge cases: empty string, all characters the same.
]
#sol[
#approach(1, "Test every substring", verdict: "O(n^3)")
#code(lang: "js", caption: "Brute force")[
```js
function allUnique(s, i, j) {
  const seen = new Set();
  for (let t = i; t <= j; t++) {
    if (seen.has(s[t])) return false;
    seen.add(s[t]);
  }
  return true;
}
function lenNoRepeatBrute(s) {
  let best = 0;
  for (let i = 0; i < s.length; i++)
    for (let j = i; j < s.length; j++)
      if (allUnique(s, i, j)) best = Math.max(best, j - i + 1);
  return best;
}
```
]
#complexity(time: $O(n^3)$, space: $O(n)$)

#approach(2, "Window with a count Map", verdict: "O(n) — good")
The window is *bad* exactly when the character we just added appears twice. Shrink from
the left until it appears once again.
#code(lang: "js", caption: "Grow, then shrink")[
```js
function lenNoRepeatShrink(s) {
  const cnt = new Map();
  let left = 0, best = 0;
  for (let right = 0; right < s.length; right++) {
    const c = s[right];
    cnt.set(c, (cnt.get(c) || 0) + 1);
    while (cnt.get(c) > 1) {
      cnt.set(s[left], cnt.get(s[left]) - 1);
      left++;
    }
    best = Math.max(best, right - left + 1);
  }
  return best;
}
```
]
#complexity(time: $O(n)$, space: $O(min(n, "alphabet"))$)

#approach(3, "Jump left straight past the twin", verdict: "O(n) with no inner loop — optimal")
Instead of stepping `left` one at a time, remember where each character was last seen and
jump.
#code(lang: "js", caption: "Last-seen jump")[
```js
function lenNoRepeatJump(s) {
  const last = new Map();
  let left = 0, best = 0;
  for (let right = 0; right < s.length; right++) {
    const c = s[right];
    if (last.has(c) && last.get(c) >= left) left = last.get(c) + 1;
    last.set(c, right);
    best = Math.max(best, right - left + 1);
  }
  return best;
}
```
]
Tested (all three agree): `"abcabcbb"` gives `3`, `"bbbb"` gives `1`, `""` gives `0`,
`"pwwkew"` gives `3`, `"abcdef"` gives `6`, `"abba"` gives `2`.
#complexity(time: $O(n)$, space: $O(min(n, "alphabet"))$)
#trap[
`"abba"` is the test that kills a careless jump version. When `right` reaches the final
`a`, `last.get("a")` is `0` but `left` is already `2`. Without the guard
`last.get(c) >= left`, `left` would jump *backwards* to `1` and the answer becomes `3`.
Wrong: the true answer is `2`.
]
*The unlocking idea:* a repeated character can only be fixed by moving `left` past its
previous position, and that position is already known.

This is one of the chapter's signature problems, so here it is in Python too.

#code(lang: "python", caption: "Python version of the optimal")[
```python
def len_no_repeat(s):
    last = {}
    left = 0
    best = 0
    for right, c in enumerate(s):
        if c in last and last[c] >= left:
            left = last[c] + 1
        last[c] = right
        best = max(best, right - left + 1)
    return best
```
]
Run on the same inputs, Python prints `3 0 1 2` for
`"abcabcbb"`, `""`, `"bbbb"`, `"abba"` — the same answers as the JavaScript.
]

#ex(10, tier: 1, asked: "Wipro · pattern")[
Count the pairs $(i, j)$ with $i < j$ whose sum is strictly less than `target`.
Constraints: $0 <= n <= 10^5$, values may be negative, the array is *not* sorted.
Target $O(n log n)$. Edge cases: $n < 2$; all pairs qualify.
]
#sol[
#approach(1, "Every pair", verdict: "O(n^2)")
#code(lang: "js", caption: "Brute force")[
```js
function countPairsLessBrute(a, target) {
  let c = 0;
  for (let i = 0; i < a.length; i++)
    for (let j = i + 1; j < a.length; j++)
      if (a[i] + a[j] < target) c++;
  return c;
}
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "Sort, then count in blocks", verdict: "O(n log n) — optimal")
After sorting, if `a[i] + a[j] < target`, then *every* element between `i` and `j` also
pairs with `a[i]` under the target, because they are all no larger than `a[j]`. That is
`j - i` pairs in one step.

#code(lang: "js", caption: "Count a whole block at a time")[
```js
function countPairsLessTwoPtr(input, target) {
  const a = [...input].sort((x, y) => x - y);   // NEVER a plain .sort()
  let c = 0;
  let i = 0, j = a.length - 1;
  while (i < j) {
    if (a[i] + a[j] < target) {
      c += j - i;
      i++;
    } else {
      j--;
    }
  }
  return c;
}
```
]
Tested: `[1,6,2,5,3]` with target `7` gives `4` from both versions.
`[-2,0,1,3]` with target `2` gives `4` from both. `[5]` gives `0`, `[]` gives `0`.
#complexity(time: $O(n log n)$, space: $O(n)$, note: "the sort dominates; the copy is the O(n) space")

#trap[
Two JavaScript mistakes hide in this function, and both were run to prove the point.
*One:* `.sort()` with no comparator is lexicographic — in Node, `[10, 9, 1].sort()` returns
`[1, 10, 9]`. Always pass `(x, y) => x - y`.
*Two:* `.sort()` rearranges the caller's array *in place*. Copying with `[...input]`
first keeps the caller's data intact. Interviewers notice when you quietly destroy an
input.
]
#trick[
With $n = 10^5$ the answer can reach $n(n-1)/2 approx 5 times 10^9$. That is fine in
JavaScript — it stays far below `Number.MAX_SAFE_INTEGER` — but say the number out loud,
because in C++ or Java it would overflow a 32-bit counter.
]
]

#ex(11, tier: 1, asked: "Capgemini · pattern")[
All values are *positive*. Find the length of the *shortest* subarray whose sum is at
least `S`. Return `0` if no subarray reaches `S`.
Constraints: $0 <= n <= 10^5$, $1 <= a_i <= 10^4$. Target $O(n)$.
Edge cases: empty array; a single element already $>= S$; total sum below `S`.
]
#sol[
#approach(1, "Start at every index", verdict: "O(n^2)")
#code(lang: "js", caption: "Brute force with an early break")[
```js
function minLenBrute(a, S) {
  let best = Infinity;
  for (let i = 0; i < a.length; i++) {
    let s = 0;
    for (let j = i; j < a.length; j++) {
      s += a[j];
      if (s >= S) { best = Math.min(best, j - i + 1); break; }
    }
  }
  return best === Infinity ? 0 : best;
}
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "Prefix sums plus binary search", verdict: "O(n log n)")
With positive values the prefix array `p` is strictly increasing, so a binary search can
find the first end point that reaches `p[i] + S`. JavaScript has no `lower_bound`, so write
the four-line version — the book's toolkit ships one, and Chapter 4 explains it in full.
#code(lang: "js", caption: "Binary search on the prefix array")[
```js
function minLenPrefixBS(a, S) {
  const n = a.length;
  const p = new Array(n + 1).fill(0);
  for (let i = 0; i < n; i++) p[i + 1] = p[i] + a[i];
  let best = Infinity;
  for (let i = 0; i < n; i++) {
    const need = p[i] + S;
    let lo = i + 1, hi = n + 1;               // first index with p[idx] >= need
    while (lo < hi) {
      const mid = lo + Math.floor((hi - lo) / 2);
      if (p[mid] < need) lo = mid + 1;
      else hi = mid;
    }
    if (lo <= n) best = Math.min(best, lo - i);
  }
  return best === Infinity ? 0 : best;
}
```
]
#complexity(time: $O(n log n)$, space: $O(n)$)

#approach(3, "Sliding window", verdict: "O(n) time, O(1) space — optimal")
This is a *shortest* problem, so the answer is recorded *inside* the shrink loop.
#code(lang: "js", caption: "Shrink while the window is still good")[
```js
function minLenWindow(a, S) {
  let left = 0, best = Infinity, sum = 0;
  for (let right = 0; right < a.length; right++) {
    sum += a[right];
    while (sum >= S) {
      best = Math.min(best, right - left + 1);
      sum -= a[left];
      left++;
    }
  }
  return best === Infinity ? 0 : best;
}
```
]
Tested on `[2,1,6,5,4]`: `S = 9` gives `2` from all three, `S = 100` gives `0` from all
three, `S = 6` gives `1` from all three. `[]` with `S = 3` gives `0`. `[7]` with `S = 7`
gives `1`.
#complexity(time: $O(n)$, space: $O(1)$)

*The unlocking idea:* because the values are positive, adding an element can only push the
sum up and removing one can only push it down. That one-way behaviour is exactly what
lets `left` move forward and never come back.
#trap[
`Math.floor((hi - lo) / 2)` — not `(hi - lo) / 2`. JavaScript division always produces a
double, so without `Math.floor` your index becomes `3.5` and `p[3.5]` is `undefined`.
Chapter 4 makes this its number-one rule.
]
]

#ex(12, tier: 1, asked: "Cognizant · pattern")[
A sorted array may contain negatives. Return the squares of all values, sorted.
Constraints: $0 <= n <= 10^5$, $|a_i| <= 3 times 10^7$. Target $O(n)$.
Edge cases: all negative; a single element; squares that pass the safe-integer limit.
]
#sol[
#approach(1, "Square then sort", verdict: "O(n log n)")
#code(lang: "js", caption: "The obvious way")[
```js
function sortedSquaresSort(a) {
  return a.map(x => x * x).sort((x, y) => x - y);
}
```
]
#complexity(time: $O(n log n)$, space: $O(n)$)

#approach(2, "Fill from the back", verdict: "O(n) — optimal")
The *largest* square must sit at one of the two ends. Compare the ends, take the bigger,
and write it into the last free slot.
#code(lang: "js", caption: "Two pointers, writing backwards")[
```js
function sortedSquaresTwoPtr(a) {
  const n = a.length;
  const r = new Array(n);
  let i = 0, j = n - 1;
  for (let pos = n - 1; pos >= 0; pos--) {
    const li = a[i] * a[i], rj = a[j] * a[j];
    if (li > rj) { r[pos] = li; i++; }
    else { r[pos] = rj; j--; }
  }
  return r;
}
```
]
Tested: `[-7,-3,0,2,5]` gives `[0,4,9,25,49]` from both versions. `[-2,-1]` gives `[1,4]`.
`[3]` gives `[9]`.
#complexity(time: $O(n)$, space: $O(n)$, note: "output array only")

#trap[
The constraint says $|a_i| <= 3 times 10^7$ for a reason: $(3 times 10^7)^2 = 9 times
10^14$, still under `Number.MAX_SAFE_INTEGER`. Push past that and JavaScript silently
rounds. Tested in Node: `123456789 * 123456789` gives `15241578750190520`, while the true
value ends in `521`.
]

If the interviewer widens the range, switch to `BigInt`. Only two lines change.

#code(lang: "js", caption: "The BigInt version, for very large values")[
```js
function sortedSquaresBig(a) {
  const n = a.length;
  const r = new Array(n);
  let i = 0, j = n - 1;
  for (let pos = n - 1; pos >= 0; pos--) {
    const li = BigInt(a[i]) * BigInt(a[i]), rj = BigInt(a[j]) * BigInt(a[j]);
    if (li > rj) { r[pos] = li; i++; }
    else { r[pos] = rj; j--; }
  }
  return r;
}
```
]
Tested: `sortedSquaresBig([-2000000000, 1000000000])` returns
`1000000000000000000n` and `4000000000000000000n`, both exact.
#note[
`BigInt` values print with a trailing `n` and cannot be mixed with ordinary numbers in
arithmetic. Convert once at the boundary, as above, and keep the whole computation in one
world.
]
]

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
Longest substring that uses at most $K$ different characters.
Constraints: $0 <= |s| <= 10^5$, $0 <= K <= 26$. Target $O(n)$.
Edge cases: $K = 0$; $K$ larger than the number of distinct characters.
]
#sol[
"At most K distinct" is the signature of Shape C with a count `Map`. The window is *bad*
when the map holds more than $K$ keys.

#code(lang: "js", caption: "At most K distinct characters")[
```js
function longestKDistinct(s, K) {
  if (K <= 0) return 0;
  const cnt = new Map();
  let left = 0, best = 0;
  for (let right = 0; right < s.length; right++) {
    const c = s[right];
    cnt.set(c, (cnt.get(c) || 0) + 1);
    while (cnt.size > K) {
      const d = s[left];
      cnt.set(d, cnt.get(d) - 1);
      if (cnt.get(d) === 0) cnt.delete(d);
      left++;
    }
    best = Math.max(best, right - left + 1);
  }
  return best;
}
```
]
Tested: `("aabbcc", 2)` gives `4`, `("abcadcacacaca", 3)` gives `11`, `("aaaa", 1)` gives
`4`, `("abc", 0)` gives `0`, `("", 2)` gives `0`.
#complexity(time: $O(n)$, space: $O(K)$)
#trap[
You must `delete` the key when its count hits zero. If you only decrement, `cnt.size`
keeps counting dead characters and the window never grows.
]
#trick[
`(cnt.get(c) || 0) + 1` is the standard JavaScript "increment or start at one", because
`cnt.get` on a missing key returns `undefined`, and `undefined + 1` is `NaN`.
]
]

#ex(14, tier: 1, asked: "Adobe · pattern")[
`h[i]` is the height of the $i$-th vertical board on a line, one unit apart. Pick two
boards. The water they hold is $min(h_i, h_j) times (j - i)$. Maximise it.
Constraints: $1 <= n <= 10^5$, $0 <= h_i <= 10^5$. Target $O(n)$.
Edge cases: $n = 1$ (answer `0`); all boards the same height.
]
#sol[
#approach(1, "Try every pair", verdict: "O(n^2)")
#code(lang: "js", caption: "Brute force")[
```js
function maxWaterBrute(h) {
  let best = 0;
  for (let i = 0; i < h.length; i++)
    for (let j = i + 1; j < h.length; j++)
      best = Math.max(best, Math.min(h[i], h[j]) * (j - i));
  return best;
}
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "Squeeze from both ends", verdict: "O(n) — optimal")
Start as wide as possible. Width can now only shrink, so the only hope of a better answer
is a taller *shorter* side. Moving the taller side in can never help, so move the shorter
one.
#code(lang: "js", caption: "Move the shorter board")[
```js
function maxWaterTwoPtr(h) {
  let i = 0, j = h.length - 1, best = 0;
  while (i < j) {
    best = Math.max(best, Math.min(h[i], h[j]) * (j - i));
    if (h[i] < h[j]) i++;
    else j--;
  }
  return best;
}
```
]
Tested: `[1,6,3,2,8,4]` gives `18` from both versions (boards at index 1 and 4:
$min(6,8) times 3 = 18$). `[4,4]` gives `4` from both. `[9]` gives `0`.
A stress case of 100000 boards of height 100000 gives `9999900000` — ten billion, which
JavaScript holds exactly because it is far under $9 times 10^15$.
#complexity(time: $O(n)$, space: $O(1)$)

*The unlocking idea:* prove that one of the two candidates can be thrown away without
checking it. That proof is what converts $O(n^2)$ into $O(n)$.
]

#ex(15, tier: 1, asked: "Amazon · pattern")[
List every *distinct* triple of values that adds up to zero.
Constraints: $0 <= n <= 3000$. Target $O(n^2)$.
Edge cases: many duplicates such as `[0,0,0,0]`; no triple exists.
]
#sol[
#approach(1, "Three loops and a Set of keys", verdict: "O(n^3)")
JavaScript arrays cannot be compared by value, and a `Set` of arrays would store each one
separately. Join the sorted triple into a string and use that as the key.
#code(lang: "js", caption: "Brute force with de-duplication")[
```js
function tripletsBrute(a) {
  const n = a.length;
  const seen = new Set();
  const out = [];
  for (let i = 0; i < n; i++)
    for (let j = i + 1; j < n; j++)
      for (let k = j + 1; k < n; k++)
        if (a[i] + a[j] + a[k] === 0) {
          const t = [a[i], a[j], a[k]].sort((x, y) => x - y);
          const key = t.join(',');
          if (!seen.has(key)) { seen.add(key); out.push(t); }
        }
  out.sort((p, q) => p[0] - q[0] || p[1] - q[1]);
  return out;
}
```
]
#complexity(time: $O(n^3)$, space: $O(n^3)$)

#approach(2, "Fix one, two-pointer the rest", verdict: "O(n^2) — optimal")
Sort. Fix `a[i]`. Now you need two values that sum to `-a[i]` inside a sorted range — that
is Example 7 again.
#code(lang: "js", caption: "Sort plus two pointers")[
```js
function tripletsZero(input) {
  const a = [...input].sort((x, y) => x - y);
  const n = a.length;
  const out = [];
  for (let i = 0; i < n - 2; i++) {
    if (i > 0 && a[i] === a[i - 1]) continue;
    let j = i + 1, k = n - 1;
    while (j < k) {
      const s = a[i] + a[j] + a[k];
      if (s === 0) {
        out.push([a[i], a[j], a[k]]);
        j++;
        k--;
        while (j < k && a[j] === a[j - 1]) j++;
        while (j < k && a[k] === a[k + 1]) k--;
      } else if (s < 0) {
        j++;
      } else {
        k--;
      }
    }
  }
  return out;
}
```
]
Tested on `[-4,-1,-1,0,1,2,5]`: both versions return
`[[-4,-1,5],[-1,-1,2],[-1,0,1]]`. `[0,0,0,0]` gives exactly one triple `[[0,0,0]]`.
`[1,2,3]` gives `[]`.
#complexity(time: $O(n^2)$, space: $O(1)$, note: "output not counted")
#trap[
Three separate duplicate guards are needed: one for `i`, one for `j`, one for `k`. Drop
any of them and `[0,0,0,0]` returns the same triple several times.
]
#trap[
`p[0] - q[0] || p[1] - q[1]` is the JavaScript idiom for "sort by the first field, break
ties on the second". It works because `0` is falsy, so a tie falls through to the next
comparison.
]
]

#ex(16, tier: 1, asked: "Infosys · pattern")[
Rearrange an array so that every even number comes before every odd number. The order
inside each group does not matter.
Constraints: $0 <= n <= 10^5$. Target $O(n)$ / $O(1)$.
Edge cases: all odd; all even; negative values.
]
#sol[
#code(lang: "js", caption: "Partition with two ends")[
```js
function evenBeforeOdd(a) {
  let i = 0, j = a.length - 1;
  while (i < j) {
    if (a[i] % 2 === 0) i++;
    else if (a[j] % 2 !== 0) j--;
    else [a[i], a[j]] = [a[j], a[i]];
  }
}
```
]
Tested: `[3,8,5,2,9,4,7]` becomes `[4,8,2,5,9,3,7]` — every even value is left of every odd
value. `[1,3,5]` is unchanged. `[2,4]` is unchanged.
#complexity(time: $O(n)$, space: $O(1)$)
#note[
`a[i] % 2` is negative for negative odd numbers in JavaScript (`-3 % 2` is `-1`), exactly
as in C and Java. That is why the test is `!== 0` and not `=== 1`.
]
]

#pagebreak(weak: true)
#section[Tier 2 — the same pattern, wearing a business suit]
#tier-header(2)

#ex(17, tier: 2, asked: "Grab · pattern")[
A driver's shift is recorded minute by minute: `1` means a ride was running, `0` means the
car was idle. The company may pay for at most $k$ idle minutes to be counted as "on duty".
What is the longest stretch of minutes that can be reported as fully on duty?
Constraints: $0 <= n <= 10^5$, $0 <= k <= n$. Target $O(n)$.
Edge cases: $k = 0$ and the shift is all idle; $k$ larger than the number of idle minutes.
]
#sol[
"At most $k$ zeros inside the window" is the rule. That is Shape C.

#code(lang: "js", caption: "Longest run of 1s with at most k flips")[
```js
function longestRunWithKFlips(bit, k) {
  let left = 0, zeros = 0, best = 0;
  for (let right = 0; right < bit.length; right++) {
    if (bit[right] === 0) zeros++;
    while (zeros > k) {
      if (bit[left] === 0) zeros--;
      left++;
    }
    best = Math.max(best, right - left + 1);
  }
  return best;
}
```
]
Tested: `([1,1,0,1,0,1,1,1,0], 2)` gives `8`, `([0,0,0], 0)` gives `0`, `([1,1,1], 5)`
gives `3`, `([], 1)` gives `0`, `([0], 1)` gives `1`.
#complexity(time: $O(n)$, space: $O(1)$)
#trick[
You do not need to know *which* zeros were flipped. Counting them is enough. Most window
problems are like this: track a number, not a set.
]
]

#ex(18, tier: 2, asked: "Shopee · pattern")[
A row of stalls, each selling one product type `stall[i]`. A shopper walks left to right
and may carry at most *two* different product types. What is the largest number of
consecutive stalls the shopper can cover?
Constraints: $0 <= n <= 10^5$, types are arbitrary integers. Target $O(n)$.
Edge cases: fewer than two distinct types; every stall different.
]
#sol[
This is Example 13 with $K = 2$, but the keys are numbers instead of characters — which is
exactly why it must be a `Map` and not a plain object.

#code(lang: "js", caption: "At most two distinct values")[
```js
function longestTwoKinds(stall) {
  const cnt = new Map();
  let left = 0, best = 0;
  for (let right = 0; right < stall.length; right++) {
    const v = stall[right];
    cnt.set(v, (cnt.get(v) || 0) + 1);
    while (cnt.size > 2) {
      const d = stall[left];
      cnt.set(d, cnt.get(d) - 1);
      if (cnt.get(d) === 0) cnt.delete(d);
      left++;
    }
    best = Math.max(best, right - left + 1);
  }
  return best;
}
```
]
Tested: `[3,3,7,7,3,5,5,5]` gives `5` (the stretch `3 3 7 7 3`), `[1,2,3,4]` gives `2`,
`[9,9,9]` gives `3`, `[]` gives `0`.
#complexity(time: $O(n)$, space: $O(1)$, note: "the Map never holds more than 3 keys")
#trap[
With a plain object, `obj[1]` and `obj["1"]` are the *same* slot, because object keys are
always strings. If the stall types ever mix numbers and text, a plain object merges them
and the count silently goes wrong. `Map` keeps the type.
]
]

#ex(19, tier: 2, asked: "Sea · pattern")[
Daily order counts for a shop. How many *contiguous* day-ranges have a total of exactly
`K` orders?
Part (a): every day has at least 1 order.
Part (b): refunds are allowed, so a day can be negative.
Constraints: $0 <= n <= 10^5$, $|a_i| <= 10^4$. Target $O(n)$.
Edge cases: `K = 0`; an empty array.
]
#sol[
#approach(1, "All ranges", verdict: "O(n^2) — works for both parts")
#code(lang: "js", caption: "Brute force")[
```js
function countSumKBrute(a, K) {
  let c = 0;
  for (let i = 0; i < a.length; i++) {
    let s = 0;
    for (let j = i; j < a.length; j++) {
      s += a[j];
      if (s === K) c++;
    }
  }
  return c;
}
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "Sliding window — part (a) only", verdict: "O(n)")
#code(lang: "js", caption: "Only valid when every value is positive")[
```js
function countSumKWindow(a, K) {          // needs every a[i] > 0
  let sum = 0, c = 0, left = 0;
  for (let right = 0; right < a.length; right++) {
    sum += a[right];
    while (sum > K && left <= right) {
      sum -= a[left];
      left++;
    }
    if (sum === K) c++;
  }
  return c;
}
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#approach(3, "Prefix sums in a Map — part (b)", verdict: "O(n), handles negatives")
If `run` is the sum of everything up to `right`, a range ending at `right` with sum `K`
exists once for every earlier prefix equal to `run - K`.
#code(lang: "js", caption: "Prefix sum plus a Map")[
```js
function countSumKPrefix(a, K) {          // works with negatives
  const seen = new Map([[0, 1]]);
  let run = 0, c = 0;
  for (const x of a) {
    run += x;
    c += seen.get(run - K) || 0;
    seen.set(run, (seen.get(run) || 0) + 1);
  }
  return c;
}
```
]
#complexity(time: $O(n)$, space: $O(n)$)

*Tested, and this is the important part.* On `[2,1,3,1,1,2]` with `K = 4` all three give
`3`. On `[1,1,1,1]` with `K = 2` all three give `3`. But on `[3,-1,1,2]` with `K = 3` the
brute force and the prefix `Map` both give `3`, while the *window version returns 2*.
#trap[
The window misses `[3,-1,1]`. Once `-1` arrives the running sum drops, so a window that was
shrunk earlier can never be grown back. That is why a sliding window needs
non-negative values for sum problems. Say this out loud in the interview before you write
any code.
]
#trick[
`new Map([[0, 1]])` seeds the map with "one empty prefix of sum 0". Without that seed you
miss every range that starts at index 0.
]
]

#ex(20, tier: 2, asked: "Agoda · pattern")[
Choose exactly three parcels whose total weight is as close as possible to a truck's
target. Return that total.
Constraints: $3 <= n <= 3000$, weights may be negative (a credit note).
Target $O(n^2)$. Edge cases: an exact hit; all weights equal.
]
#sol[
#approach(1, "All triples", verdict: "O(n^3)")
#code(lang: "js", caption: "Brute force")[
```js
function threeClosestBrute(w, target) {
  let best = null;
  for (let i = 0; i < w.length; i++)
    for (let j = i + 1; j < w.length; j++)
      for (let k = j + 1; k < w.length; k++) {
        const s = w[i] + w[j] + w[k];
        if (best === null || Math.abs(s - target) < Math.abs(best - target)) best = s;
      }
  return best;
}
```
]
#complexity(time: $O(n^3)$, space: $O(1)$)

#approach(2, "Sort, fix one, two-pointer the rest", verdict: "O(n^2) — optimal")
#code(lang: "js", caption: "Closest triple")[
```js
function threeClosest(input, target) {
  const w = [...input].sort((x, y) => x - y);
  const n = w.length;
  let best = w[0] + w[1] + w[2];
  for (let i = 0; i < n - 2; i++) {
    let j = i + 1, k = n - 1;
    while (j < k) {
      const s = w[i] + w[j] + w[k];
      if (Math.abs(s - target) < Math.abs(best - target)) best = s;
      if (s === target) return s;
      if (s < target) j++;
      else k--;
    }
  }
  return best;
}
```
]
Tested: `([4,9,1,7,12], 20)` gives `20` from both. `([-5,-2,0,3], 1)` gives `1` from both.
`([1,1,1], 100)` gives `3`.
#complexity(time: $O(n^2)$, space: $O(n)$, note: "the O(n) space is the defensive copy")
#trap[
Seed `best` with a *real* triple, or with `null` as the brute force does. Seeding with
`Infinity` and then computing `Math.abs(Infinity - target)` gives `Infinity`, which
compares `false` against itself and the first candidate is never recorded.
]
]

#ex(21, tier: 2, asked: "LINE MAN · pattern")[
A row of $n$ vouchers. You must take exactly $k$ of them, and each pick must come from the
front or the back of the row. Maximise the total value.
Constraints: $1 <= k <= n <= 10^5$, values may be negative. Target $O(n)$.
Edge cases: $k = n$; all values negative.
]
#sol[
#approach(1, "Try every split", verdict: "O(k^2)")
Take `front` from the left and `k - front` from the right, for every `front` from `0`
to `k`.
#code(lang: "js", caption: "Brute force over the split point")[
```js
function bestFromEndsBrute(v, k) {
  const n = v.length;
  let best = -Infinity;
  for (let front = 0; front <= k; front++) {
    const back = k - front;
    let s = 0;
    for (let i = 0; i < front; i++) s += v[i];
    for (let i = 0; i < back; i++) s += v[n - 1 - i];
    best = Math.max(best, s);
  }
  return best;
}
```
]
#complexity(time: $O(k^2)$, space: $O(1)$)

#approach(2, "Look at what you leave behind", verdict: "O(n) — optimal")
Whatever you take from the ends, what stays behind is one *contiguous block* of length
$n - k$ in the middle. Maximising what you take is the same as minimising what you leave.
And "smallest sum over all windows of a fixed length" is Template B.
#code(lang: "js", caption: "Minimise the middle window")[
```js
function bestFromEnds(v, k) {
  const n = v.length;
  const total = v.reduce((s, x) => s + x, 0);
  const win = n - k;
  if (win === 0) return total;
  let sum = 0;
  for (let i = 0; i < win; i++) sum += v[i];
  let minSum = sum;
  for (let i = win; i < n; i++) {
    sum += v[i] - v[i - win];
    minSum = Math.min(minSum, sum);
  }
  return total - minSum;
}
```
]
Tested: `([8,2,9,1,7,3], 3)` gives `19` from both versions. `([8,2,9,1,7,3], 6)` gives `30`
from both. `([-4,-1,-9], 1)` gives `-4` from both.
#complexity(time: $O(n)$, space: $O(1)$)

*The unlocking idea:* flip the question. "Pick from the two ends" is a disguise for
"leave one window in the middle".
#trick[
`v.reduce((s, x) => s + x, 0)` is the JavaScript way to total an array. The `0` seed
matters: `reduce` with no seed throws on an empty array.
]
]

#ex(22, tier: 2, asked: "DBS · pattern")[
A queue of customers, `1` means premium and `0` means standard. One *swap* exchanges any
two customers. What is the smallest number of swaps that puts all premium customers next
to each other?
Constraints: $0 <= n <= 10^5$. Target $O(n)$.
Edge cases: zero or one premium customer (answer `0`); everyone premium.
]
#sol[
If there are `ones` premium customers, the final block has length exactly `ones`. So slide
a window of that fixed length and find the one that *already* holds the most premium
customers. Every remaining slot in that window costs one swap.

#code(lang: "js", caption: "Fixed window of length ones")[
```js
function minSwapsToGroup(bit) {
  const ones = bit.reduce((s, b) => s + b, 0);
  if (ones <= 1) return 0;
  let have = 0;
  for (let i = 0; i < ones; i++) have += bit[i];
  let best = have;
  for (let i = ones; i < bit.length; i++) {
    have += bit[i] - bit[i - ones];
    best = Math.max(best, have);
  }
  return ones - best;
}
```
]
Tested: `[1,0,1,1,0,1,0,1]` gives `2`, `[1,1,1]` gives `0`, `[0,0]` gives `0`, `[1]` gives
`0`, `[1,0,0,0,1]` gives `1`.
#complexity(time: $O(n)$, space: $O(1)$)
#trick[
Whenever a problem says "group them together", first compute the *size* of the final
group. It is usually fixed, and a fixed size means Template B.
]
]

#pagebreak(weak: true)
#section[Tier 3 — the ones with a follow-up]
#tier-header(3)

#ex(23, tier: 3, asked: "Google · pattern")[
`h[i]` is the height of a wall block. Rain falls. How much water is held between the
blocks?
Constraints: $0 <= n <= 2 times 10^5$, $0 <= h_i <= 10^5$. Target $O(n)$ time, $O(1)$
space. Edge cases: empty array; a strictly falling profile (holds nothing).
]
#sol[
The key fact, and you must say it before writing code: the water above column $i$ is
$min("tallest to the left", "tallest to the right") - h_i$.

#approach(1, "Scan left and right for every column", verdict: "O(n^2)")
#code(lang: "js", caption: "Brute force")[
```js
function rainBrute(h) {
  const n = h.length;
  let total = 0;
  for (let i = 0; i < n; i++) {
    let L = 0, R = 0;
    for (let j = 0; j <= i; j++) L = Math.max(L, h[j]);
    for (let j = i; j < n; j++) R = Math.max(R, h[j]);
    total += Math.min(L, R) - h[i];
  }
  return total;
}
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "Pre-compute the two max arrays", verdict: "O(n) time, O(n) space")
#code(lang: "js", caption: "Prefix and suffix maxima")[
```js
function rainPrefix(h) {
  const n = h.length;
  if (n === 0) return 0;
  const L = new Array(n), R = new Array(n);
  L[0] = h[0];
  for (let i = 1; i < n; i++) L[i] = Math.max(L[i - 1], h[i]);
  R[n - 1] = h[n - 1];
  for (let i = n - 2; i >= 0; i--) R[i] = Math.max(R[i + 1], h[i]);
  let total = 0;
  for (let i = 0; i < n; i++) total += Math.min(L[i], R[i]) - h[i];
  return total;
}
```
]
#complexity(time: $O(n)$, space: $O(n)$)

#approach(3, "Two pointers", verdict: "O(n) time, O(1) space — optimal")
Here is the whole trick. If `h[i] <= h[j]`, then the right side already has *something* at
least as tall as `h[i]`. So the true limit for column `i` is decided by the left side
alone, and `leftMax` is all you need. Symmetrically on the other side.

#code(lang: "js", caption: "The O(1)-space solution")[
```js
function rainTwoPtr(h) {
  let i = 0, j = h.length - 1;
  let leftMax = 0, rightMax = 0, total = 0;
  while (i < j) {
    if (h[i] <= h[j]) {
      leftMax = Math.max(leftMax, h[i]);
      total += leftMax - h[i];
      i++;
    } else {
      rightMax = Math.max(rightMax, h[j]);
      total += rightMax - h[j];
      j--;
    }
  }
  return total;
}
```
]
Tested (all three agree): `[3,0,2,0,4]` gives `7`, `[5,4,3,2]` gives `0`, `[]` gives `0`,
`[2,1,2]` gives `1`. A stress case of 200000 columns, tall only at the two ends, gives
`19999800000`, and `Number.isSafeInteger` on that answer returns `true`, so no `BigInt` is
needed here. All three were also cross-checked against each other on 400 random arrays.
#complexity(time: $O(n)$, space: $O(1)$)

This is a signature problem, so here it is in Python as well.

#code(lang: "python", caption: "Python version")[
```python
def trapped(h):
    i, j = 0, len(h) - 1
    lmax = rmax = total = 0
    while i < j:
        if h[i] <= h[j]:
            lmax = max(lmax, h[i]); total += lmax - h[i]; i += 1
        else:
            rmax = max(rmax, h[j]); total += rmax - h[j]; j -= 1
    return total
```
]
Python prints `7 0 0 1` on the same four inputs.

*Follow-up the interviewer asks next:* "the heights arrive as a stream, you cannot store
them — now what?" Answer: you cannot. Water above a column depends on a block that may
appear far in the future, so no single-pass, no-memory answer exists. You can, however,
keep a *monotonic decreasing stack* of candidate left walls and settle water in layers as
each new block arrives; that is $O(n)$ time and $O(n)$ worst-case memory. That stack
version is built in Chapter 8.
]

#ex(24, tier: 3, asked: "Amazon · pattern")[
Given a long string `s` and a short string `need`, find the *shortest* substring of `s`
that contains every character of `need`, counting repeats. Return `""` if none exists.
Constraints: $0 <= |s| <= 10^5$, $0 <= |"need"| <= 100$. Target $O(|s|)$.
Edge cases: `need` longer than `s`; `need` with repeated letters such as `"aa"`; empty
inputs.
]
#sol[
#approach(1, "Every start, extend until covered", verdict: "O(n^3) with a Map rebuild each time")
#code(lang: "js", caption: "Brute force (correct, slow, good for testing)")[
```js
function minCoverBrute(s, need) {
  let best = '';
  for (let i = 0; i < s.length; i++) {
    for (let j = i; j < s.length; j++) {
      const have = new Map();
      for (let t = i; t <= j; t++) have.set(s[t], (have.get(s[t]) || 0) + 1);
      const want = new Map();
      for (const c of need) want.set(c, (want.get(c) || 0) + 1);
      let ok = true;
      for (const [c, k] of want) if ((have.get(c) || 0) < k) { ok = false; break; }
      if (ok) {
        if (best === '' || j - i + 1 < best.length) best = s.slice(i, j + 1);
        break;
      }
    }
  }
  return best;
}
```
]
#complexity(time: $O(n^3)$, space: $O(|"need"|)$)

#approach(2, "One window and a single counter", verdict: "O(n) — optimal")
The clever part is the `want` map. It starts as the required count of each character.
Adding a character *decrements* it. A value that is still above zero before the decrement
means that character was genuinely needed, so `missing` goes down. A value below zero
simply means "we have spare copies". One integer, `missing`, replaces the whole comparison
of two maps.

#code(lang: "js", caption: "Minimum covering window")[
```js
function minCover(s, need) {
  if (s.length === 0 || need.length === 0) return '';
  const want = new Map();
  for (const c of need) want.set(c, (want.get(c) || 0) + 1);
  let missing = need.length;
  let left = 0, bestLen = Infinity, bestStart = 0;
  for (let right = 0; right < s.length; right++) {
    const c = s[right];
    const wc = want.get(c) || 0;
    if (wc > 0) missing--;
    want.set(c, wc - 1);
    while (missing === 0) {
      if (right - left + 1 < bestLen) {
        bestLen = right - left + 1;
        bestStart = left;
      }
      const d = s[left];
      want.set(d, want.get(d) + 1);
      if (want.get(d) > 0) missing++;
      left++;
    }
  }
  return bestLen === Infinity ? '' : s.slice(bestStart, bestStart + bestLen);
}
```
]
Tested (brute force and window agree): `("PQRSTAQBSRC", "ABC")` gives `"AQBSRC"`,
`("bbaacx", "abc")` gives `"baac"`, `("xaybzabcq", "abc")` gives `"abc"`,
`("aabbcc", "abc")` gives `"abbc"`, `("aaab", "ab")` gives `"ab"`, `("aa", "aa")` gives
`"aa"`, `("a", "aa")` gives `""`, `("", "a")` gives `""`, `("xyz", "")` gives `""`.
They were also cross-checked on 300 random strings.
#complexity(time: $O(n)$, space: $O(|"need"|)$)

Python, for the same reason as above.

#code(lang: "python", caption: "Python version")[
```python
def min_cover(s, need):
    from collections import Counter
    if not s or not need:
        return ""
    want = Counter(need)
    missing = len(need)
    left = 0
    best = (float("inf"), 0)
    for right, c in enumerate(s):
        if want[c] > 0:
            missing -= 1
        want[c] -= 1
        while missing == 0:
            if right - left + 1 < best[0]:
                best = (right - left + 1, left)
            want[s[left]] += 1
            if want[s[left]] > 0:
                missing += 1
            left += 1
    if best[0] == float("inf"):
        return ""
    return s[best[1]: best[1] + best[0]]
```
]
Python gives `'AQBSRC'`, `''`, `'baac'` on the matching inputs.

*Follow-up the interviewer asks next:* "the alphabet is Unicode, not 26 letters."
Nothing changes. A JavaScript `Map` already accepts any key, which is why the `Map`
version is better here than a 26-slot array. Time stays $O(n)$; space becomes
$O(|"need"|)$. When the invariant is right, the data structure swap is free.
#trap[
`missing` must be compared with `0`, never with `want.size`. Repeated characters in
`need` (like `"aa"`) need *two* copies, and only the counter version knows that.
]
]

#ex(25, tier: 3, asked: "Microsoft · pattern")[
Longest subarray in which the largest and the smallest value differ by at most `limit`.
Constraints: $0 <= n <= 10^5$. Target $O(n)$.
Edge cases: `limit = 0`; empty array; all values equal.
]
#sol[
#approach(1, "Every start, track running min and max", verdict: "O(n^2)")
#code(lang: "js", caption: "Brute force")[
```js
function longestBoundedBrute(a, limit) {
  let best = 0;
  for (let i = 0; i < a.length; i++) {
    let lo = a[i], hi = a[i];
    for (let j = i; j < a.length; j++) {
      lo = Math.min(lo, a[j]);
      hi = Math.max(hi, a[j]);
      if (hi - lo <= limit) best = Math.max(best, j - i + 1);
      else break;
    }
  }
  return best;
}
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "Window plus two monotonic deques", verdict: "O(n) — optimal")
The window rule needs `max - min`. A plain counter cannot give that. Keep two deques of
*indexes*: `maxq` decreasing by value (its front is the window max) and `minq` increasing
by value (its front is the window min). When `left` moves past an index, drop it from the
front if it is there.

#trap[
JavaScript has no deque, and `array.shift()` has to move every remaining element down one
slot. Measured in Node: pushing 200000 values and shifting them all off a plain array took
*3156 ms*; the book's `Deque` did the same work in *15 ms*. Using a plain array here turns
an $O(n)$ algorithm into $O(n^2)$. The `Deque` (JS Toolkit appendix) keeps a head index
instead, so `shift` is $O(1)$ amortised.
]

#code(lang: "js", caption: "Two deques hold the window max and min")[
```js
const { Deque } = require('./toolkit.js');

function longestBounded(a, limit) {
  const maxq = new Deque(), minq = new Deque();   // both hold indexes
  let left = 0, best = 0;
  for (let right = 0; right < a.length; right++) {
    while (maxq.size && a[maxq.back()] <= a[right]) maxq.pop();
    maxq.push(right);
    while (minq.size && a[minq.back()] >= a[right]) minq.pop();
    minq.push(right);
    while (a[maxq.front()] - a[minq.front()] > limit) {
      if (maxq.front() === left) maxq.shift();
      if (minq.front() === left) minq.shift();
      left++;
    }
    best = Math.max(best, right - left + 1);
  }
  return best;
}
```
]
Tested (both agree): `([8,2,4,7], 4)` gives `2`, `([10,1,2,4,7,2], 5)` gives `4`,
`([4,4,4], 0)` gives `3`, `([], 3)` gives `0`, `([5], 0)` gives `1`.
Cross-checked on 400 random arrays against the brute force.
#complexity(time: $O(n)$, space: $O(n)$, note: "each index enters and leaves each deque once")

*The unlocking idea:* when the window rule needs an *extremum* instead of a *count*,
upgrade the counter to a monotonic deque. Everything else in Template C stays the same.

*Follow-up the interviewer asks next:* "give me the answer for every `limit` from 0 to L."
The maximum valid length is non-decreasing in `limit`, which is exactly the monotone shape
Chapter 4 lives on — binary search the answer instead of recomputing.
]

#ex(26, tier: 3, asked: "Uber · pattern")[
Count the subarrays that contain *exactly* `K` distinct values.
Constraints: $0 <= n <= 10^5$, $1 <= K <= n$. Target $O(n)$.
Edge cases: `K` bigger than the number of distinct values (answer `0`); all values equal.
]
#sol[
"Exactly K" is not a sliding-window rule: when you add an element the distinct count can
jump over K and shrinking is not forced. So *change the question*.

#formulas(title: "The exactly-K trick")[
$"exactly"(K) = "atMost"(K) - "atMost"(K - 1)$

"At most K" *is* a window rule, because adding an element can only break it and shrinking
always fixes it.
]

Counting every subarray that ends at `right` is the second half of the trick: once the
window `[left..right]` is valid, so is every window that starts at `left+1, left+2, ...,
right`. That is `right - left + 1` subarrays, added in one step.

#code(lang: "js", caption: "At most K distinct, then subtract")[
```js
function atMostKDistinct(a, K) {
  if (K < 0) return 0;
  const cnt = new Map();
  let total = 0, left = 0;
  for (let right = 0; right < a.length; right++) {
    const v = a[right];
    cnt.set(v, (cnt.get(v) || 0) + 1);
    while (cnt.size > K) {
      const d = a[left];
      cnt.set(d, cnt.get(d) - 1);
      if (cnt.get(d) === 0) cnt.delete(d);
      left++;
    }
    total += right - left + 1;
  }
  return total;
}
const exactlyKDistinct = (a, K) => atMostKDistinct(a, K) - atMostKDistinct(a, K - 1);
```
]
Tested against a brute force: `([1,2,1,3,4], 2)` gives `5`, `([1,2,1,3,4], 3)` gives `3`,
`([5,5,5], 1)` gives `6`, `([], 1)` gives `0`, `([1,2,1,3,4], 9)` gives `0`.
Cross-checked on 400 random arrays for every `K` from 1 to 4.
#complexity(time: $O(n)$, space: $O(n)$, note: "two passes, each O(n)")

*Follow-up the interviewer asks next:* "count subarrays with sum exactly K" — same trick
shape, different engine: `atMost` on a sum needs positive values (Example 19), so with
negatives you must fall back to prefix sums plus a `Map`.
]

#ex(27, tier: 3, asked: "Goldman Sachs · pattern")[
Find the shortest subarray such that sorting *only that subarray* leaves the whole array
sorted. Return its length, or `0` if the array is already sorted.
Constraints: $0 <= n <= 10^5$. Target $O(n)$ time, $O(1)$ space.
Edge cases: already sorted; strictly decreasing; all values equal.
]
#sol[
#approach(1, "Sort a copy and compare", verdict: "O(n log n) time, O(n) space")
#code(lang: "js", caption: "Compare with the sorted copy")[
```js
function shortestUnsortedBrute(a) {
  const b = [...a].sort((x, y) => x - y);
  const n = a.length;
  let i = 0, j = n - 1;
  while (i < n && a[i] === b[i]) i++;
  if (i === n) return 0;
  while (j > i && a[j] === b[j]) j--;
  return j - i + 1;
}
```
]
#complexity(time: $O(n log n)$, space: $O(n)$)

#approach(2, "Two sweeps, no sorting", verdict: "O(n) time, O(1) space — optimal")
Sweep left to right keeping the running maximum. Any element *smaller* than that maximum is
out of place, and the last such element is the right edge of the window. Sweep the other
way with the running minimum to find the left edge.

#code(lang: "js", caption: "Two sweeps")[
```js
function shortestUnsorted(a) {
  const n = a.length;
  if (n < 2) return 0;
  let runMax = a[0], right = -1;
  for (let i = 1; i < n; i++) {
    if (a[i] < runMax) right = i;
    else runMax = a[i];
  }
  let runMin = a[n - 1], left = -1;
  for (let i = n - 2; i >= 0; i--) {
    if (a[i] > runMin) left = i;
    else runMin = a[i];
  }
  if (right === -1) return 0;
  return right - left + 1;
}
```
]
Tested (both agree): `[1,3,5,4,2,6,7]` gives `4` (the block `3 5 4 2`), `[1,2,3]` gives
`0`, `[3,2,1]` gives `3`, `[2,2,2]` gives `0`, `[]` gives `0`, `[9]` gives `0`.
Cross-checked on 400 random arrays.
#complexity(time: $O(n)$, space: $O(1)$)

*Follow-up the interviewer asks next:* "do it in one pass." You can: run both sweeps in the
same `for` loop, one using index `i` and the other using index `n - 1 - i`. The code gets
denser but the complexity class does not change, so say that out loud and only write it if
they insist.
]

#ex(28, tier: 3, asked: "D. E. Shaw · pattern")[
You may change at most `k` characters of a lowercase string. What is the longest block of
*one repeated letter* you can end up with?
Constraints: $0 <= |s| <= 10^5$, $0 <= k <= |s|$. Target $O(n)$.
Edge cases: `k = 0`; all letters already equal; empty string.
]
#sol[
A window is valid when `(window length) - (count of the most common letter in it) <= k`,
because every other letter has to be changed.

#approach(1, "Every start", verdict: "O(n^2)")
#code(lang: "js", caption: "Brute force")[
```js
function longestAfterKChangesBrute(s, k) {
  let best = 0;
  for (let i = 0; i < s.length; i++) {
    const cnt = new Array(26).fill(0);
    let mx = 0;
    for (let j = i; j < s.length; j++) {
      cnt[s.charCodeAt(j) - 97]++;
      mx = Math.max(mx, cnt[s.charCodeAt(j) - 97]);
      if (j - i + 1 - mx <= k) best = Math.max(best, j - i + 1);
    }
  }
  return best;
}
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "Window that never shrinks", verdict: "O(n) — optimal")
Notice the `if` instead of a `while`, and that `bestCount` is never lowered. Both look like
bugs. They are not, and explaining why is the whole interview.

#code(lang: "js", caption: "The non-shrinking window")[
```js
function longestAfterKChanges(s, k) {
  const cnt = new Array(26).fill(0);
  let left = 0, bestCount = 0, best = 0;
  for (let right = 0; right < s.length; right++) {
    const idx = s.charCodeAt(right) - 97;
    cnt[idx]++;
    bestCount = Math.max(bestCount, cnt[idx]);
    if (right - left + 1 - bestCount > k) {
      cnt[s.charCodeAt(left) - 97]--;
      left++;
    }
    best = Math.max(best, right - left + 1);
  }
  return best;
}
```
]

#formulas(title: "Why the stale bestCount is safe")[
We only ever want a *longer* answer. A window can beat the current best only if its most
common letter has a *higher* count than `bestCount`. In that case `bestCount` is updated on
the very step that count appears, so it is fresh exactly when it matters.
If `bestCount` is stale it is too small, which makes the window look *worse* than it is,
so the window slides. We never report a length we did not earn. The window size therefore
never decreases — it only slides forward — and the final `best` is correct.
]

Tested (both agree): `("aabbba", 2)` gives `5`, `("abcd", 0)` gives `1`, `("aaaa", 3)`
gives `4`, `("", 2)` gives `0`. Cross-checked on 300 random strings over the alphabet
`a b c`.
#complexity(time: $O(n)$, space: $O(1)$, note: "26 counters")
#note[
Here a 26-slot array beats a `Map`, because the alphabet is fixed and tiny and
`charCodeAt(i) - 97` is a direct index. Choose the array when the key space is small and
dense; choose the `Map` when it is not.
]

*Follow-up the interviewer asks next:* "return the actual substring, not just the length."
Store `bestStart = left` whenever you improve `best`, then `s.slice(bestStart, bestStart +
best)`. Cost stays $O(n)$.
]

#pagebreak(weak: true)
#section[Dry run — every single step]

*Problem.* `a = [4, 2, 7, 1, 3, 6, 2]`, `S = 11`. Find the length of the shortest subarray
with sum at least `11`. All values are positive, so Template C applies and the answer is
read *inside* the shrink loop.

#code(lang: "js", caption: "The code we are tracing")[
```js
let left = 0, best = Infinity, sum = 0;
for (let right = 0; right < a.length; right++) {
  sum += a[right];
  while (sum >= S) {
    best = Math.min(best, right - left + 1);
    sum -= a[left];
    left++;
  }
}
```
]

Read the table one row at a time. "inf" means `best` is still `Infinity`.

#table(
  columns: (auto, auto, auto, 1fr, auto, auto),
  [*right*], [*a\[right\]*], [*sum after add*], [*what happens*], [*left after*], [*best*],
  [0], [4], [4],  [`4 < 11`, no shrink], [0], [inf],
  [1], [2], [6],  [`6 < 11`, no shrink], [0], [inf],
  [2], [7], [13], [`13 >= 11`: window `[0..2]` has length 3, `best = 3`; drop `a[0] = 4`, sum becomes 9; `9 < 11`, stop], [1], [3],
  [3], [1], [10], [`10 < 11`, no shrink], [1], [3],
  [4], [3], [13], [`13 >= 11`: window `[1..4]` length 4, `best` stays 3; drop `a[1] = 2`, sum becomes 11], [2], [3],
  [], [], [11], [still `>= 11`: window `[2..4]` length 3, `best` stays 3; drop `a[2] = 7`, sum becomes 4; stop], [3], [3],
  [5], [6], [10], [`10 < 11`, no shrink], [3], [3],
  [6], [2], [12], [`12 >= 11`: window `[3..6]` length 4, `best` stays 3; drop `a[3] = 1`, sum becomes 11], [4], [3],
  [], [], [11], [still `>= 11`: window `[4..6]` length 3, `best` stays 3; drop `a[4] = 3`, sum becomes 8; stop], [5], [3],
)

*Answer: 3.* Two different windows achieve it — `[4,2,7]` with sum 13 and `[3,6,2]` with
sum 11. This trace was produced by running the code in Node with a `console.log` on every
step, so the table is the program's real output, not a guess.

#subsection[Three things to notice]

+ `right` advanced 7 times. `left` advanced 5 times. Total pointer moves: 12, which is less
  than $2n$. That is the whole reason the algorithm is $O(n)$ even though there is a loop
  inside a loop.
+ `sum` was never recomputed from scratch. Each step was one addition or one subtraction.
+ `best` was written *before* the shrink, never after. Rows 5 and 8 are exactly where a
  "record after the loop" version would report the wrong length.

#trap[
Trace your own code like this on paper before you run it. Half of all sliding-window bugs
are a `best` update on the wrong side of the `while`, and a five-row table finds them
faster than a debugger.
]

#pagebreak(weak: true)
#section[Practice]

Solve these on paper first, then type them. Full code is in the answer key.

#practice(tier: 1, time: "45 min for 1-6")[
+ *Pairs at a fixed distance.* A sorted array of *distinct* values and an integer
  $D >= 1$. Count the pairs whose difference is exactly $D$.
  $0 <= n <= 10^5$. Target $O(n)$. Edge cases: empty array; no pair matches.
+ *Longest exact-sum run.* All values are positive. Find the length of the longest
  subarray whose sum is exactly `K`. $0 <= n <= 10^5$, $1 <= a_i <= 10^4$. Target $O(n)$.
  Edge cases: no such subarray (return `0`); a single element equal to `K`.
+ *Anagram window.* Does `big` contain any rearrangement of `small` as a substring?
  Lowercase only, $0 <= |"small"| <= |"big"| <= 10^5$. Target $O(n)$.
  Edge cases: `small` longer than `big`; `small` empty.
+ *Best window sum.* Return the largest sum over all windows of length `k`.
  $1 <= k <= n <= 10^5$, values may be negative. Target $O(n)$.
  Edge cases: all negative; $k = n$.
+ *Take from the ends.* All values positive. Each move takes the first or the last element.
  What is the fewest moves to collect a total of at least `target`? Return `-1` if the
  whole array is not enough. $0 <= n <= 10^5$. Target $O(n)$.
  Edge cases: `target = 0`; target above the total.
+ *Delete one.* A `0/1` array. You must delete exactly one element. What is the longest run
  of `1`s in what remains? $1 <= n <= 10^5$. Target $O(n)$.
  Edge cases: all ones; all zeros.
]

#practice(tier: 2, time: "50 min for 7-11")[
7. *Cheap baskets.* All values positive. Count the subarrays whose *product* is strictly
  less than `target`. $0 <= n <= 10^5$, $1 <= a_i <= 10^5$. Target $O(n)$.
  Edge cases: `target = 1` (answer `0`); a product that passes the safe-integer limit.
8. *Full catalogue window.* Find the length of the shortest subarray that contains every
  distinct value present in the whole array. $0 <= n <= 10^5$. Target $O(n)$.
  Edge cases: every value the same; all values distinct.
9. *Two-sum indexes.* Sorted array, return the two *1-based* indexes whose values add to
  `target`, or an empty array. $0 <= n <= 10^5$. Target $O(n)$.
  Edge cases: no pair; negative values.
10. *Three-colour sort.* Values are only `0`, `1`, `2`. Sort in one pass with $O(1)$ extra
  space. $0 <= n <= 10^5$. Edge cases: already sorted; all one colour.
11. *Closest across two lists.* Two sorted arrays. Find the smallest possible
  $|a_i - b_j|$. $1 <= n, m <= 10^5$. Target $O(n + m)$.
  Edge cases: single-element arrays; values far apart.
]

#practice(tier: 3, time: "45 min for 12-15")[
12. *All three letters.* The string uses only `a`, `b`, `c`. Count the substrings that
  contain at least one of each. $0 <= n <= 10^5$. Target $O(n)$.
  Edge cases: a letter missing entirely (answer `0`); a large count.
13. *At most twice.* Longest subarray in which no value appears more than twice.
  $0 <= n <= 10^5$. Target $O(n)$. Edge cases: empty; all values equal.
14. *Reverse the vowels.* Reverse only the vowels of a string, leaving every other
  character where it is. Both cases count as vowels. $0 <= n <= 10^5$. Target $O(n)$.
  Edge cases: no vowels; all vowels.
15. *Merge backwards.* `a` holds `m` sorted values then `n` spare slots; `b` holds `n`
  sorted values. Merge `b` into `a` in place, with no extra array.
  Target $O(m + n)$. Edge cases: `m = 0`; every value of `b` smaller than every value of
  `a`.
]

#key[
*1.* Walk `j` forward; pull `i` up whenever the gap is too big.
#code(lang: "js", caption: "Pairs with difference exactly D")[
```js
function countDiffPairs(a, D) {
  let c = 0, i = 0, j = 1;
  while (j < a.length) {
    const d = a[j] - a[i];
    if (i === j || d < D) j++;
    else if (d > D) i++;
    else { c++; i++; j++; }
  }
  return c;
}
```
]
Tested: `([1,3,5,8,10], 2)` gives `3`, `([1,2,3,4], 1)` gives `3`, `([1,9], 3)` gives `0`,
`([], 1)` gives `0`, `([4], 1)` gives `0`. Cross-checked against a brute force on 500
random distinct arrays. $O(n)$ time, $O(1)$ space.

*2.* Shrink while the sum is too big, then check for equality.
#code(lang: "js", caption: "Longest subarray with sum exactly K")[
```js
function longestSumK(a, K) {
  let sum = 0, left = 0, best = 0;
  for (let right = 0; right < a.length; right++) {
    sum += a[right];
    while (sum > K && left <= right) { sum -= a[left]; left++; }
    if (sum === K) best = Math.max(best, right - left + 1);
  }
  return best;
}
```
]
Tested: `([1,2,3,1,1,1,1], 4)` gives `4`, `([5], 5)` gives `1`, `([5], 3)` gives `0`,
`([], 0)` gives `0`. $O(n)$ / $O(1)$.

*3.* A fixed window of length `small.length`, compared as two 26-slot count arrays.
JavaScript will not compare arrays with `===`, so compare element by element with
`every`.
#code(lang: "js", caption: "Permutation inside a string")[
```js
function hasPermutation(big, small) {
  const m = small.length, n = big.length;
  if (m === 0 || m > n) return false;
  const need = new Array(26).fill(0), have = new Array(26).fill(0);
  for (const c of small) need[c.charCodeAt(0) - 97]++;
  const same = () => need.every((v, i) => v === have[i]);
  for (let i = 0; i < n; i++) {
    have[big.charCodeAt(i) - 97]++;
    if (i >= m) have[big.charCodeAt(i - m) - 97]--;
    if (i >= m - 1 && same()) return true;
  }
  return false;
}
```
]
Tested: `("oidbcaf","abc")` gives `true`, `("odicf","abc")` gives `false`,
`("aa","aaa")` gives `false`, `("ab","ba")` gives `true`. $O(26 n)$ time, $O(1)$ space.
#trap[
`[1,2] === [1,2]` is `false` in JavaScript — it compares object identity, not contents.
That single fact breaks a lot of first attempts at this problem.
]

*4.* Template B, seeded with the first real window.
#code(lang: "js", caption: "Best window sum of length k")[
```js
function bestWindowSum(a, k) {
  let sum = 0;
  for (let i = 0; i < k; i++) sum += a[i];
  let best = sum;
  for (let i = k; i < a.length; i++) {
    sum += a[i] - a[i - k];
    best = Math.max(best, sum);
  }
  return best;
}
```
]
Tested: `([4,1,9,2,8], 2)` gives `11`, `([-3,-1,-7], 2)` gives `-4`, `([6], 1)` gives `6`.
$O(n)$ / $O(1)$.

*5.* Flip it: taking from the ends leaves one middle window. You want the *longest* middle
window whose sum is at most `total - target`.
#code(lang: "js", caption: "Fewest picks from the two ends")[
```js
function fewestFromEnds(v, target) {
  const total = v.reduce((s, x) => s + x, 0);
  if (total < target) return -1;
  const keep = total - target;          // biggest middle window with sum <= keep
  let sum = 0, left = 0, bestWin = 0;
  for (let right = 0; right < v.length; right++) {
    sum += v[right];
    while (sum > keep) { sum -= v[left]; left++; }
    bestWin = Math.max(bestWin, right - left + 1);
  }
  return v.length - bestWin;
}
```
]
Tested: `([3,1,4,1,5], 9)` gives `3`, `([2,2], 100)` gives `-1`, `([7], 7)` gives `1`,
`([1,1,1], 0)` gives `0`. $O(n)$ / $O(1)$.

*6.* Allow one zero in the window, then subtract the deleted slot: the answer is
`right - left`, not `right - left + 1`.
#code(lang: "js", caption: "Longest run of 1s after deleting one element")[
```js
function longestOnesDeleteOne(bit) {
  let left = 0, zeros = 0, best = 0;
  for (let right = 0; right < bit.length; right++) {
    if (bit[right] === 0) zeros++;
    while (zeros > 1) { if (bit[left] === 0) zeros--; left++; }
    best = Math.max(best, right - left);      // -1 for the deleted slot
  }
  return best;
}
```
]
Tested: `[1,1,0,1,1,1]` gives `5`, `[1,1,1]` gives `2`, `[0,0]` gives `0`, `[1]` gives `0`.
$O(n)$ / $O(1)$.

*7.* Same shape as "at most K distinct": once a window is valid, it contributes
`right - left + 1` subarrays.
#code(lang: "js", caption: "Subarrays with product below target")[
```js
function countProductLess(a, target) {
  if (target <= 1) return 0;
  let prod = 1, c = 0, left = 0;
  for (let right = 0; right < a.length; right++) {
    prod *= a[right];
    while (prod >= target) { prod /= a[left]; left++; }
    c += right - left + 1;
  }
  return c;
}
```
]
Tested: `([10,2,3,4], 30)` gives `8` and a brute force agrees; `([1,1,1], 2)` gives `6`;
`([5,5], 1)` gives `0`; `([100000,100000,100000], 4000000000)` gives `3`. Cross-checked on
500 random arrays.
#trap[
`prod` peaks at roughly `target × max(a)`. Keep that product under
`Number.MAX_SAFE_INTEGER` or the division that follows starts returning fractions and the
count drifts. If the interviewer raises the limits, switch to `BigInt` — this version was
also run and gives the same answers:
]
#code(lang: "js", caption: "The BigInt variant")[
```js
function countProductLessBig(a, target) {
  const T = BigInt(target);
  let prod = 1n, c = 0, left = 0;
  for (let right = 0; right < a.length; right++) {
    prod *= BigInt(a[right]);
    while (prod >= T) { prod /= BigInt(a[left]); left++; }
    c += right - left + 1;
  }
  return c;
}
```
]
Tested: on `[100000,100000,100000,100000]` with target `1e15`, both versions return `7`.
$O(n)$ / $O(1)$.

*8.* Count the distinct values first, then shrink as hard as possible while the window
still holds all of them.
#code(lang: "js", caption: "Shortest window with every distinct value")[
```js
function shortestAllDistinct(a) {
  const need = new Set(a).size;
  if (need === 0) return 0;
  const cnt = new Map();
  let left = 0, best = Infinity;
  for (let right = 0; right < a.length; right++) {
    cnt.set(a[right], (cnt.get(a[right]) || 0) + 1);
    while (cnt.size === need) {
      best = Math.min(best, right - left + 1);
      const v = a[left];
      cnt.set(v, cnt.get(v) - 1);
      if (cnt.get(v) === 0) cnt.delete(v);
      left++;
    }
  }
  return best;
}
```
]
Tested: `[2,1,3,2,1,3,3]` gives `3`, `[7,7,7]` gives `1`, `[4,5]` gives `2`.
$O(n)$ time, $O(n)$ space.
#trick[
`new Set(a).size` counts distinct values in one line. It is the JavaScript replacement for
sorting and counting runs.
]

*9.* Shape A, unchanged.
#code(lang: "js", caption: "Two-sum on a sorted array, 1-based")[
```js
function twoSumSorted(a, target) {
  let i = 0, j = a.length - 1;
  while (i < j) {
    const s = a[i] + a[j];
    if (s === target) return [i + 1, j + 1];
    if (s < target) i++;
    else j--;
  }
  return [];
}
```
]
Tested: `([2,4,7,11], 15)` gives `[2,4]`; `([2,4], 99)` gives `[]`. $O(n)$ / $O(1)$.

*10.* Three pointers. Everything before `low` is `0`, everything after `high` is `2`, and
`mid` is the scanner. Do *not* advance `mid` after a swap with `high`, because the value
that arrived from the back has not been looked at yet.
#code(lang: "js", caption: "One-pass three-colour sort")[
```js
function sortThreeValues(a) {
  let low = 0, mid = 0, high = a.length - 1;
  while (mid <= high) {
    if (a[mid] === 0) { [a[low], a[mid]] = [a[mid], a[low]]; low++; mid++; }
    else if (a[mid] === 1) { mid++; }
    else { [a[mid], a[high]] = [a[high], a[mid]]; high--; }
  }
}
```
]
Tested: `[2,0,1,2,1,0]` becomes `[0,0,1,1,2,2]`; `[1,1]` stays `[1,1]`. $O(n)$ / $O(1)$.

*11.* Walk both arrays forward; always advance the pointer sitting on the smaller value,
because only that move can close the gap.
#code(lang: "js", caption: "Closest pair across two sorted arrays")[
```js
function closestPair(a, b) {
  let i = 0, j = 0, best = Infinity;
  while (i < a.length && j < b.length) {
    best = Math.min(best, Math.abs(a[i] - b[j]));
    if (a[i] < b[j]) i++;
    else j++;
  }
  return best;
}
```
]
Tested: `([1,9,20], [4,12])` gives `3`, `([5],[5])` gives `0`,
`([-2000000000], [2000000000])` gives `4000000000`. $O(n + m)$ / $O(1)$.

*12.* For each right end, the substrings that work are exactly those starting at or before
the *most recent* position of the rarest of the three letters.
#code(lang: "js", caption: "Substrings containing a, b and c")[
```js
function countAbcSubstrings(s) {
  const last = [-1, -1, -1];
  let c = 0;
  for (let i = 0; i < s.length; i++) {
    last[s.charCodeAt(i) - 97] = i;
    const lo = Math.min(last[0], last[1], last[2]);
    if (lo >= 0) c += lo + 1;
  }
  return c;
}
```
]
Tested against a brute force: `"abcabc"` gives `10`, `"aaa"` gives `0`, `"cba"` gives `1`.
Cross-checked on 500 random strings. $O(n)$ / $O(1)$.

*13.* Template C with the rule "this value now appears three times".
#code(lang: "js", caption: "No value more than twice")[
```js
function longestAtMostTwice(a) {
  const cnt = new Map();
  let left = 0, best = 0;
  for (let right = 0; right < a.length; right++) {
    const v = a[right];
    cnt.set(v, (cnt.get(v) || 0) + 1);
    while (cnt.get(v) > 2) {
      cnt.set(a[left], cnt.get(a[left]) - 1);
      left++;
    }
    best = Math.max(best, right - left + 1);
  }
  return best;
}
```
]
Tested: `[1,2,1,2,1]` gives `4`, `[4,4,4]` gives `2`, `[]` gives `0`, `[3,3]` gives `2`.
$O(n)$ time, $O(n)$ space.

*14.* Shape A with two skip rules. JavaScript strings cannot be changed in place, so
convert to an array of characters first.
#code(lang: "js", caption: "Reverse only the vowels")[
```js
function reverseVowels(str) {
  const s = [...str];
  const isVowel = c => 'aeiouAEIOU'.includes(c);
  let i = 0, j = s.length - 1;
  while (i < j) {
    if (!isVowel(s[i])) i++;
    else if (!isVowel(s[j])) j--;
    else { [s[i], s[j]] = [s[j], s[i]]; i++; j--; }
  }
  return s.join('');
}
```
]
Tested: `"placement"` becomes `"plecemant"`, `"xyz"` is unchanged, `""` is unchanged,
`"aeiou"` becomes `"uoiea"`. $O(n)$ / $O(1)$ beyond the character array.
#trap[
`s[i] = 'x'` on a JavaScript string does nothing at all — no error, no change. Strings are
immutable. Spread into an array, edit, then `join('')`.
]

*15.* Write from the *back*. The tail of `a` is spare space, so nothing is ever overwritten
before it is read.
#code(lang: "js", caption: "In-place merge, filling backwards")[
```js
function mergeInPlace(a, m, b, n) {
  let i = m - 1, j = n - 1, w = m + n - 1;
  while (j >= 0) {
    if (i >= 0 && a[i] > b[j]) a[w--] = a[i--];
    else a[w--] = b[j--];
  }
}
```
]
Tested: `a = [1,5,9,0,0]` with `m = 3` and `b = [3,7]` becomes `[1,3,5,7,9]`;
`a = [0,0]` with `m = 0` and `b = [2,4]` becomes `[2,4]`. $O(m + n)$ / $O(1)$.
]

#revision[
#subsection[The three templates]

#code(lang: "js", caption: "A — opposite ends (array must be sorted)")[
```js
const pairSum = (a, t) => {          // a is sorted ascending
  let i = 0, j = a.length - 1;
  while (i < j) {
    const s = a[i] + a[j];
    if (s === t) return [i, j];
    if (s < t) i++; else j--;        // too small: raise the low end
  }                                  // too big:  lower the high end
  return null;
};
```
]

#code(lang: "js", caption: "B — fixed window of size k")[
```js
const maxWindowSum = (a, k) => {
  if (a.length < k || k <= 0) return 0;
  let sum = 0;
  for (let i = 0; i < k; i++) sum += a[i];      // first window
  let best = sum;
  for (let i = k; i < a.length; i++) {
    sum += a[i] - a[i - k];                     // gain right, lose left
    best = Math.max(best, sum);
  }
  return best;
};
```
]

#code(lang: "js", caption: "C-long — variable window, LONGEST valid")[
```js
const longestAtMostK = (a, K) => {
  const cnt = new Map();
  let left = 0, best = 0;
  for (let right = 0; right < a.length; right++) {
    cnt.set(a[right], (cnt.get(a[right]) ?? 0) + 1);
    while (cnt.size > K) {                      // shrink while BAD
      const c = cnt.get(a[left]) - 1;
      if (c === 0) cnt.delete(a[left]); else cnt.set(a[left], c);
      left++;
    }
    best = Math.max(best, right - left + 1);    // read AFTER the while
  }
  return best;
};
```
]

#code(lang: "js", caption: "C-short — variable window, SHORTEST valid (positives only)")[
```js
const shortestAtLeastS = (a, S) => {
  let left = 0, sum = 0, best = Infinity;
  for (let right = 0; right < a.length; right++) {
    sum += a[right];
    while (sum >= S) {                          // shrink while GOOD
      best = Math.min(best, right - left + 1);  // read INSIDE the while
      sum -= a[left]; left++;
    }
  }
  return best === Infinity ? 0 : best;
};
```
]

#note[
All four were run in Node. `pairSum([1,3,4,7,11], 11)` gives `[2,3]`;
`maxWindowSum([2,1,5,1,3,2], 3)` gives `9`; `longestAtMostK([1,2,1,3,4], 2)` gives `3`;
`shortestAtLeastS([2,3,1,2,4,3], 7)` gives `2`. Every one of them returns `0` or `null` on
the empty array — no crash, no special case.
]

#subsection[When to use which]

#table(
  columns: (1.25fr, 0.75fr, auto),
  [*The question says*], [*Shape*], [*Time*],
  [sorted array, find a pair with a given sum], [A], [$O(n)$],
  [is it a palindrome / reverse it in place], [A], [$O(n)$],
  [container of water, two walls], [A], [$O(n)$],
  [triple with a given sum], [sort, then A inside a loop], [$O(n^2)$],
  [squares of a sorted array, sorted], [A, filling from the back], [$O(n)$],
  ["every window of length k"], [B], [$O(n)$],
  [longest subarray with rule P], [C-long], [$O(n)$],
  [shortest subarray with sum $>=$ S], [C-short], [$O(n)$],
  ["at most K distinct" / "at most k changes"], [C-long + `Map` of counts], [$O(n)$],
  ["exactly K distinct"], [atMost(K) $-$ atMost(K$-$1)], [$O(n)$],
  [window max *and* min at the same time], [C + two monotonic deques], [$O(n)$],
  [exact subarray sum, values may be negative], [*not a window* — prefix sums + `Map`], [$O(n)$],
)

#subsection[Complexity you should be able to quote]

#table(
  columns: (1.5fr, auto, auto),
  [*Problem*], [*Time*], [*Space*],
  [pair sum in a sorted array], [$O(n)$], [$O(1)$],
  [pair sum, unsorted, sorting allowed], [$O(n log n)$], [$O(1)$],
  [three-sum], [$O(n^2)$], [$O(1)$ beyond the sort],
  [fixed window of size k], [$O(n)$], [$O(1)$],
  [longest / shortest variable window], [$O(n)$], [$O(1)$],
  [window with a count `Map`], [$O(n)$], [$O(k)$ distinct keys],
  [window max and min (two deques)], [$O(n)$], [$O(k)$],
  [trapping rain water, two pointers], [$O(n)$], [$O(1)$],
  [minimum window covering a set], [$O(n)$], [$O(sigma)$ alphabet],
)

#note[
Why every window is $O(n)$ and not $O(n^2)$: `left` and `right` each move forward at most
$n$ times in the whole run. The inner `while` is not a nested loop — it is the *same*
`left` continuing its one journey across the array. Say that sentence in the interview.
]

#subsection[Top traps, in the order they bite]

+ *Reading the answer on the wrong side of the `while`.* Longest problems read
  *after* the shrink loop; shortest problems read *inside* it. Get this backwards and
  every single test fails.
+ *A window for a sum problem with negative values.* Growing the window can lower the sum,
  so shrinking is no longer safe. Use prefix sums plus a `Map` instead.
+ *Moving an index backwards.* `left--` or `right--` means you have left the pattern and
  the $O(n)$ argument is gone.
+ *`a.sort()` with no comparator.* It sorts as *text*: `[10, 9, 1].sort()` returns
  `[1, 10, 9]`. Shape A needs `a.sort((x, y) => x - y)` first, every time.
+ *Not deleting a zero count.* `cnt.size` is the number of distinct values in the window
  only if you `cnt.delete(key)` when its count hits 0. Leaving a `0` behind makes
  `cnt.size` lie.
+ *Duplicate answers in three-sum.* After sorting, skip equal values at each of the three
  positions, or the same triple comes out many times.
+ *`sum += a[i] - a[i - k]` before the first full window exists.* Build the first window
  with its own loop, then start sliding at `i = k`.
+ *An array used as a queue.* `shift()` is $O(n)$ in the worst case, which turns an $O(n)$
  window into $O(n^2)$. Use the toolkit `Deque`, or a head index.
+ *`s[i] = 'x'` on a string.* JavaScript strings are immutable — the line does nothing and
  raises no error. Spread into an array, edit, then `join('')`.
+ *Off-by-one in the window length.* It is `right - left + 1`, never `right - left`.

#subsection[The 20-second checklist before you code]

+ Is the array sorted, or may I sort it? If yes, Shape A is on the table.
+ Is the window length fixed by the question? Then Shape B — no `while` at all.
+ Otherwise: write the *bad condition* as one sentence. That sentence becomes the `while`.
+ Longest or shortest? That decides where the answer is read.
+ Are there negative numbers in a *sum* problem? If yes, stop — use prefix sums.
+ What do `add` and `remove` cost? If either is more than $O(1)$, the total is not $O(n)$.
]
