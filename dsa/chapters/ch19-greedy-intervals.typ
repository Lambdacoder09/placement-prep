#import "../../shared/lib/style.typ": *

#chapter(num: 19, title: "Greedy & Intervals", tagline: "Sort by the right key, take the best local move, prove it with an exchange argument")[

#section[Pattern in one page]

A *greedy* algorithm builds the answer one step at a time. At every step it takes the
move that looks best *right now* and never takes it back. That is all. The whole skill
is deciding *what "best right now" means*, and proving that the local choice cannot
hurt the final answer.

#formulas(title: "The greedy checklist")[

*Step 1 — find the sort key.* Almost every greedy problem in a coding round starts with
a sort. The interview is really asking: sort by *what*?

#table(columns: (auto, 1fr),
  [*Goal*], [*Sort key that works*],
  [Pick the most non-overlapping intervals], [earliest *finish* time],
  [Merge / union of intervals], [earliest *start* time],
  [Minimum rooms, maximum overlap], [starts and ends *separately* (sweep)],
  [Fractional knapsack], [value / weight, descending],
  [Job with deadline + profit], [profit descending, then fill the latest free day],
  [Pair two lists to satisfy the most], [both lists ascending, two pointers],
  [Minimum groups of size $<= 2$ under a cap], [ascending, then lightest with heaviest],
  [Join pieces to make the biggest number], [custom: $a + b > b + a$ as strings],
)

*Step 2 — state the invariant.* One sentence that stays true after every step.
Example, activity selection: "after processing $k$ intervals, `freeAt` is the earliest
possible finishing time among all ways to pick this many non-overlapping intervals."

*Step 3 — the exchange argument (this is the proof).*
Assume some optimal answer $O$ differs from the greedy answer $G$. Look at the *first*
place they differ. Swap the optimal's choice for the greedy's choice. Show the answer
is still valid and *no worse*. Repeat. After enough swaps $O$ has turned into $G$, so
$G$ is optimal too.

*Step 4 — sanity-check with a counterexample hunt.* Before you code, spend 30 seconds
trying to break your own rule with a tiny 3-element input. If you cannot break it in
30 seconds, code it.
]

#subsection[The two template loops you will reuse all chapter]

#code(lang: "js", caption: "Template A — merge / union (sort by START)")[
```js
v.sort((a, b) => a[0] - b[0] || a[1] - b[1]);          // by start, then by end
const out = [v[0]];
for (let i = 1; i < v.length; i++) {
  const last = out[out.length - 1];
  if (v[i][0] <= last[1])                              // touches the open block
    last[1] = Math.max(last[1], v[i][1]);
  else
    out.push(v[i]);                                    // clean gap -> new block
}
```
]

#code(lang: "js", caption: "Template B — pick the most (sort by END)")[
```js
v.sort((a, b) => a[1] - b[1]);                         // by END, numerically
let cnt = 0, freeAt = -Infinity;
for (const [s, e] of v)
  if (s >= freeAt) { cnt++; freeAt = e; }              // fits -> take it, never undo
```
]

#trap[
*`arr.sort()` in JavaScript is LEXICOGRAPHIC, not numeric.* `[10, 9, 1].sort()` gives
`[1, 10, 9]`, because the default comparator turns every element into a string first.
Numbers *always* need an explicit comparator: `arr.sort((a, b) => a - b)`. This chapter
sorts in almost every solution, so the rule is: if you typed `.sort()` with empty
brackets, you have a bug.

Two more comparator rules that go with it:
- A comparator must return a *number*, not a boolean. `(a, b) => a[1] > b[1]` returns
  `true`/`false`, which coerce to `1`/`0` — the sort never sees a negative and leaves the
  array essentially untouched. Write `(a, b) => a[1] - b[1]`.
- Chain tie-breaks with `||`, because `0` is falsy:
  `(a, b) => a[0] - b[0] || a[1] - b[1]`.
- `arr.sort()` sorts *in place* and returns the same array. Every solution in this chapter
  starts with `[...v]` or `v.map(iv => [...iv])` so the caller's array is not silently
  reordered.
]

#trick[
Almost every interval question is Template A or Template B with a different word
problem wrapped around it. Learn to see which one it is in the first 20 seconds:
- The answer is a *list of intervals* $arrow.r$ Template A (sort by start).
- The answer is a *count* $arrow.r$ Template B (sort by end).
- The answer is *how many at once* $arrow.r$ sweep line (starts and ends separately).
]

#subsection[Open or closed? Decide before you code]

An interval $[s, e]$ can mean two different things and the code changes by one character.

#table(columns: (auto, auto, 1fr),
  [*Meaning*], [*Overlap test*], [*Typical wording*],
  [Closed $[s,e]$ — both ends count], [`max(s1,s2) <= min(e1,e2)`], [a balloon spans x = 2 to x = 5],
  [Half-open $[s,e)$ — end does not count], [`max(s1,s2) < min(e1,e2)`], [a meeting from 2 pm to 5 pm],
)

#trap[
The single most common wrong answer in an interval question is treating "meeting ends
at 5, next starts at 5" as a clash. A meeting that *ends* at 5 frees the room at 5.
Write the rule on your rough sheet before you write the first line of code.
]

#subsection[When greedy is WRONG]

Greedy fails the moment a local best move can block a bigger future gain. Two examples
you must be able to produce on demand in an interview:

+ *Coin change with a strange coin set.* Coins ${25, 10, 1}$, amount 30. Greedy takes
  25 and then five 1s $=$ 6 coins. The best answer is $10 + 10 + 10 = 3$ coins.
+ *Intervals with weights.* Meetings $(1,4)$ worth 30, $(2,6)$ worth 90, $(5,8)$ worth 20.
  "Earliest finish" greedy takes $(1,4)$ and $(5,8)$ for 50. The best is the single
  meeting $(2,6)$ for 90.

Both need dynamic programming. We solve both later in this chapter.

#section[Warm-up — build the reflex]

#tier-header(0)

#ex(1, tier: 0, asked: "TCS NQT pattern")[
You have notes of value 1, 2, 5, 10, 20, 50, 100, 200, 500.
Pay an amount with the *fewest* notes. Print that count, or $-1$ if the amount cannot
be paid exactly.

*Constraints:* amount up to $10^9$. *Target:* $O(k log k)$ where $k$ is the number of
distinct notes. *Edge cases:* amount $= 0$; a coin set where exact payment is impossible.
]
#sol[
Sort the notes biggest first. Take as many of each as fit. This *particular* note set is
"canonical", which means greedy is provably correct on it.

#code(lang: "js", caption: "minCoins — greedy on a canonical note set")[
```js
const minCoins = (amount, coins) => {
  const sorted = [...coins].sort((a, b) => b - a);   // biggest first
  let used = 0;
  for (const c of sorted) {
    used += Math.floor(amount / c);                  // take as many as fit
    amount %= c;                                     // keep the leftover
  }
  return amount === 0 ? used : -1;                   // -1 = cannot pay exactly
};
```
]

Trace for amount $= 287$:

#table(columns: (auto, auto, auto, auto),
  [*Note*], [*How many fit*], [*Used so far*], [*Left*],
  [500], [0], [0], [287],
  [200], [1], [1], [87],
  [100], [0], [1], [87],
  [50],  [1], [2], [37],
  [20],  [1], [3], [17],
  [10],  [1], [4], [7],
  [5],   [1], [5], [2],
  [2],   [1], [6], [0],
  [1],   [0], [6], [0],
)

Tested: `minCoins(287, indian)` prints `6`, `minCoins(0, indian)` prints `0`,
`minCoins(3, [2, 4])` prints `-1`, and `minCoins(1e9, indian)` prints `2000000`.
]
#ans[6 notes: $200 + 50 + 20 + 10 + 5 + 2$]

#ex(2, tier: 0, asked: "Infosys pattern")[
Two closed intervals $[a_1, a_2]$ and $[b_1, b_2]$. Do they share at least one point?

*Constraints:* values fit in a 32-bit range. *Target:* $O(1)$.
*Edge cases:* they touch at exactly one point; one sits fully inside the other.
]
#sol[
Do *not* write four `if` cases. There is a one-line rule.

Two intervals overlap when the later of the two starts is not after the earlier of the
two ends.

#code(lang: "js", caption: "overlap — the one-line rule")[
```js
const overlap = (a1, a2, b1, b2) => Math.max(a1, b1) <= Math.min(a2, b2);
```
]

#diagram(height: 3.6cm, caption: "max of the starts vs min of the ends")[
  #dnode(0.4cm, 0.5cm, 4.2cm, 0.7cm, "A: 2 ... 5")
  #dnode(3.2cm, 1.6cm, 4.2cm, 0.7cm, "B: 4 ... 9", fill: rgb("#f7efe4"))
  #darrow(3.3cm, 2.9cm, 3.3cm, 2.35cm, label: "max start = 4")
  #darrow(4.6cm, 2.9cm, 4.6cm, 1.25cm, label: "min end = 5")
  #dnode(0.4cm, 2.95cm, 7.0cm, 0.55cm, "4 <= 5 -> they overlap on [4,5]", fill: rgb("#eef3ea"))
]

Tested: `overlap(2,5,4,9)` $arrow.r$ `true`, `overlap(2,5,5,9)` $arrow.r$ `true` (they
touch at 5), `overlap(2,5,6,9)` $arrow.r$ `false`.
]
#ans[`max(a1,b1) <= min(a2,b2)`]

#ex(3, tier: 0, asked: "Capgemini pattern")[
Prices of $n$ items and a budget $B$. Buy the *most items* possible. You may buy each
item at most once.

*Constraints:* $n <= 10^5$, prices up to $10^9$, $B$ up to $10^14$.
*Target:* $O(n log n)$. *Edge cases:* empty price list; $B = 0$.
]
#sol[
Wanting the *count* and not the *value* is the key. Cheap items are strictly better than
dear ones because every item adds exactly 1 to the count. So sort ascending and buy
until the money runs out.

*Exchange argument.* Suppose an optimal basket skips the cheapest item $c$ but includes
some item $d$ with $d >= c$. Swap $d$ for $c$. The count stays the same and the money
spent does not go up. So there is always an optimal basket that contains the cheapest
item. Repeat on the rest.

#code(lang: "js", caption: "maxItems — cheapest first")[
```js
const maxItems = (price, budget) => {
  const p = [...price].sort((a, b) => a - b);   // cheapest first
  let cnt = 0;
  for (const x of p) {
    if (budget < x) break;
    budget -= x;
    cnt++;
  }
  return cnt;
};
```
]

Tested with prices ${40, 10, 25, 5, 90}$ and $B = 60$: sorted is $5, 10, 25, 40, 90$.
Buy 5 (left 55), 10 (left 45), 25 (left 20), stop at 40. Output `3`.
`maxItems([40, 10], 0)` prints `0`; `maxItems([], 100)` prints `0`.
]
#ans[3 items]

#trap[
*JavaScript numbers are doubles — exact only up to `Number.MAX_SAFE_INTEGER`
$= 2^53 - 1 approx 9.007 times 10^15$.* Here you are safe: $10^5$ items at $10^9$ each is
$10^14$, comfortably inside that. Run `Number.isSafeInteger(total)` if you are unsure. The
moment a running total can pass $9 times 10^15$ — a product of two values near $10^9$, for
example — the answer silently loses its low digits and you must switch to `BigInt`:
`items.reduce((s, x) => s + BigInt(x), 0n)`.
]

#ex(4, tier: 0, asked: "Wipro pattern")[
Given a string of digits, rearrange them to make the largest possible number.

*Constraints:* length up to $10^5$. *Target:* $O(n log n)$, or $O(n)$ with counting sort.
*Edge cases:* all digits equal; a single digit.
]
#sol[
Largest number $=$ biggest digit first. Sort descending.

#code(lang: "js", caption: "biggestNumber")[
```js
const biggestNumber = (digits) => [...digits].sort().reverse().join('');
```
]

Tested: `biggestNumber("40921")` prints `94210`; `biggestNumber("7")` prints `7`;
`biggestNumber("222")` prints `222`.

This is the one place a bare `.sort()` is *safe*, and only because every element is a
single character: for one-digit strings the lexicographic order and the numeric order
agree. The moment a piece has two digits that stops being true — see Example 25.
]
#ans[`94210`]

#note[
Careful — this works only because all pieces are *single digits*. Joining multi-digit
pieces needs a different comparator. That is Tier 2, Example 25.
]

#ex(5, tier: 0, asked: "Cognizant pattern")[
Sort a list of intervals by finishing time, breaking ties by starting time.

*Constraints:* $n <= 10^5$. *Target:* $O(n log n)$. *Edge cases:* two intervals with the
same end; an empty list.
]
#sol[
This is the exact comparator Template B needs, so write it once and keep it.

#code(lang: "js", caption: "byEnd — the comparator you will reuse all chapter")[
```js
const byEnd = (v) => [...v].sort((a, b) => a[1] - b[1] || a[0] - b[0]);
```
]

Tested with $(1,9), (2,4), (6,7), (3,4)$: output is
`(2,4)(3,4)(6,7)(1,9)`.
]
#ans[`(2,4) (3,4) (6,7) (1,9)`]

#trap[
A JS comparator must return a *number*: negative if `a` comes first, positive if `b` does,
`0` for a tie. Writing `(a, b) => a[1] > b[1]` returns a boolean, which coerces to `1` or
`0` — the engine never sees a negative number, so it concludes nothing is ever out of
order. Run it on $(1,9), (2,4), (6,7), (3,4)$ and it prints the input back unchanged:
`(1,9) (2,4) (6,7) (3,4)`. No crash, no warning, just a wrong answer.
]

#ex(6, tier: 0, asked: "Accenture pattern")[
An array of integers and a number $k$. You must flip the sign of *exactly* $k$ numbers
(you may flip the same position more than once). Make the total as large as possible.

*Constraints:* $n <= 10^5$, $k <= 10^4$, values in $[-100, 100]$.
*Target:* $O(n log n)$. *Edge cases:* no negatives at all; $k$ larger than the count of
negatives; a single element.
]
#sol[
Two greedy moves, in this order:

+ Flipping a negative always increases the total. Do that first, smallest (most negative)
  first, while flips remain.
+ If flips are still left, they must be spent. Flipping a number twice is a no-op, so an
  *even* leftover costs nothing. An *odd* leftover forces one real flip — waste it on the
  smallest remaining value.

#code(lang: "js", caption: "maxSumAfterFlips")[
```js
const maxSumAfterFlips = (a, k) => {
  const v = [...a].sort((x, y) => x - y);
  for (let i = 0; i < v.length && k > 0 && v[i] < 0; i++) {
    v[i] = -v[i];                        // flipping a negative always helps
    k--;
  }
  let sum = 0, small = Infinity;
  for (const x of v) { sum += x; small = Math.min(small, x); }
  return k % 2 === 1 ? sum - 2 * small : sum;   // one flip left: waste it on the smallest
};
```
]

#table(columns: (auto, auto, auto, auto),
  [*Input*], [*k*], [*After flipping negatives*], [*Output*],
  [$-4, -2, 3$], [2], [$4, 2, 3$, k left 0], [9],
  [$-4, -2, 3$], [3], [$4, 2, 3$, k left 1, smallest is 2], [$9 - 4 = 5$],
  [$5$], [1], [nothing to flip, k left 1, smallest is 5], [$5 - 10 = -5$],
)

All three lines were run and matched.
]
#ans[9, 5 and $-5$ for the three cases]

#trap[
After the flipping loop you must recompute the smallest value. The smallest value of the
*new* array may not be `a[0]` any more — flipping $-9$ into $9$ moves it to the far end.
The code above scans for `small` after the flips, which is why it is correct.
]

#section[Tier 1 — the standard interval toolkit]

#tier-header(1)

#ex(7, tier: 1, asked: "TCS Digital pattern")[
You are given $n$ intervals. Some overlap. Merge every group that overlaps (or touches)
into a single interval and return the merged list, sorted.

*Constraints:* $n <= 10^5$, endpoints up to $10^9$.
*Target:* $O(n log n)$ time, $O(n)$ extra space.
*Edge cases:* an empty list; one interval; several copies of the same interval;
an interval fully inside another.
]
#sol[

#approach(1, "Fuse any two that touch, then start over", verdict: "O(n^3) worst case, too slow")

The first idea most students have: scan every pair, and whenever two touch, replace them
with their union and restart the scan.

#code(lang: "js", caption: "mergeBrute — correct but slow")[
```js
const mergeBrute = (input) => {
  const v = input.map(iv => [...iv]);                  // per-row copy, see the trap below
  let changed = true;
  while (changed) {
    changed = false;
    for (let i = 0; i < v.length && !changed; i++)
      for (let j = i + 1; j < v.length && !changed; j++)
        if (Math.max(v[i][0], v[j][0]) <= Math.min(v[i][1], v[j][1])) {
          v[i] = [Math.min(v[i][0], v[j][0]), Math.max(v[i][1], v[j][1])];
          v.splice(j, 1);
          changed = true;
        }
  }
  return v.sort((a, b) => a[0] - b[0]);
};
```
]

#complexity(time: $O(n^3)$, space: [$O(1)$ extra], note: "Each fuse costs a full O(n^2) rescan, and there can be n fuses. It is a fine reference implementation to test against, never a submission.")

#approach(2, "Sort by start, then sweep once", verdict: "O(n log n), optimal")

Here is the unlock. *After sorting by start time, any interval can only ever merge with
the block that is currently open.* It can never reach backwards, because every earlier
interval started earlier and has already been folded in.

So keep one open block. For each new interval: if it begins at or before the open
block's end, stretch the block's end; otherwise the open block is finished, push it and
open a new one.

#code(lang: "js", caption: "mergeSorted — Template A")[
```js
const mergeSorted = (input) => {
  if (input.length === 0) return [];
  const v = input.map(iv => [...iv]);                  // copy every row, not just the outer array
  v.sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const out = [v[0]];
  for (let i = 1; i < v.length; i++) {
    const last = out[out.length - 1];
    if (v[i][0] <= last[1])                            // touches the last block
      last[1] = Math.max(last[1], v[i][1]);
    else
      out.push(v[i]);                                  // clean gap, start new block
  }
  return out;
};
```
]

#complexity(time: $O(n log n)$, space: $O(n)$, note: "The sort dominates. The sweep itself is O(n).")

#subsection[Trace]

Input $(7,9), (1,4), (2,5), (9,11), (15,18)$. After sorting by start:
$(1,4), (2,5), (7,9), (9,11), (15,18)$.

#table(columns: (auto, auto, auto, 1fr),
  [*i*], [*Interval*], [*Open block*], [*What happens*],
  [0], [(1,4)],   [(1,4)],   [first block],
  [1], [(2,5)],   [(1,5)],   [$2 <= 4$ so stretch the end to $max(4,5) = 5$],
  [2], [(7,9)],   [(7,9)],   [$7 > 5$, gap. Push (1,5), open (7,9)],
  [3], [(9,11)],  [(7,11)],  [$9 <= 9$, they touch. Stretch to 11],
  [4], [(15,18)], [(15,18)], [$15 > 11$, gap. Push (7,11), open (15,18)],
)

Both versions were run on this input. Both printed
`[[1,5],[7,11],[15,18]]`. Extra runs: `mergeSorted([])` prints `[]`,
`mergeSorted([[3,3]])` prints `[[3,3]]`, and three copies of $(1,2)$ collapse to
`[[1,2]]`. A fourth run confirmed the *caller's* array comes back in its original order.
]
#ans[`[1,5] [7,11] [15,18]`]

#code(lang: "python", caption: "Python version — same idea, 8 lines")[
```python
def merge_intervals(v):
    if not v:
        return []
    v.sort()
    out = [list(v[0])]
    for s, e in v[1:]:
        if s <= out[-1][1]:
            out[-1][1] = max(out[-1][1], e)
        else:
            out.append([s, e])
    return out
```
]

Run: `merge_intervals([(7,9),(1,4),(2,5),(9,11),(15,18)])` prints
`[[1, 5], [7, 11], [15, 18]]`.

#trap[
`last[1] = v[i][1];` is wrong. Use `Math.max`. Input $(1,10), (2,3)$ would otherwise
shrink the block from $[1,10]$ to $[1,3]$ and silently lose half the range.
]

#trap[
*`[...v]` is a SHALLOW copy.* It makes a new outer array whose slots still point at the
*same* inner `[s, e]` arrays. Since this solution mutates `last[1]` in place, a shallow
copy would rewrite the caller's data. Copy every row:
`const v = input.map(iv => [...iv]);`. The same applies to any 2D grid —
`grid.map(r => [...r])`, never `[...grid]`.
]

#ex(8, tier: 1, asked: "Infosys pattern")[
A single room. You have $n$ meeting requests, each $[s, e)$ — the room is free again at
time $e$. Book the *largest number* of meetings.

*Constraints:* $n <= 10^5$. *Target:* $O(n log n)$.
*Edge cases:* an empty list; a zero-length meeting $(4,4)$; every meeting identical.
]
#sol[

#approach(1, "Try every subset", verdict: "O(2^n · n log n), dies past n = 20")

#code(lang: "js", caption: "maxMeetBrute — the reference answer")[
```js
const maxMeetBrute = (v) => {
  const n = v.length;
  let best = 0;
  for (let mask = 0; mask < (1 << n); mask++) {
    const pick = v.filter((_, i) => mask >> i & 1).sort((a, b) => a[0] - b[0]);
    let ok = true;
    for (let i = 1; i < pick.length; i++)
      if (pick[i][0] < pick[i - 1][1]) ok = false;
    if (ok) best = Math.max(best, pick.length);
  }
  return best;
};
```
]

#complexity(time: $O(2^n dot n log n)$, space: $O(n)$, note: "Useful only to check the greedy on random small inputs — which is exactly what I did.")

#approach(2, "Sort by earliest finish, take whatever fits", verdict: "O(n log n), optimal")

Why *finish* and not *start* or *shortest*? Because finishing early is the only thing
that helps the future. A meeting that ends at 4 leaves the room free from 4 onward; a
meeting that ends at 9 blocks everything until 9. Nothing else about a meeting matters
once it is chosen.

#code(lang: "js", caption: "maxMeetGreedy — Template B")[
```js
const maxMeetGreedy = (v) => {
  const a = [...v].sort((x, y) => x[1] - y[1]);   // earliest FINISH first
  let cnt = 0, freeAt = -Infinity;
  for (const [s, e] of a)
    if (s >= freeAt) { cnt++; freeAt = e; }
  return cnt;
};
```
]

#complexity(time: $O(n log n)$, space: [$O(1)$ extra], note: "One sort, one pass.")

#subsection[The exchange argument, written out in full]

Let the greedy picks in order be $g_1, g_2, dots, g_k$ and let some optimal solution,
sorted by finish time, be $o_1, o_2, dots, o_m$ with $m >= k$. We prove by induction
that $"finish"(g_i) <= "finish"(o_i)$ for every $i$.

- $i = 1$: greedy picked the globally earliest finishing interval, so
  $"finish"(g_1) <= "finish"(o_1)$.
- Suppose $"finish"(g_(i-1)) <= "finish"(o_(i-1))$. The optimal's next interval $o_i$
  starts at or after $"finish"(o_(i-1))$, which is at or after $"finish"(g_(i-1))$. So
  $o_i$ was still available to greedy at step $i$. Greedy takes the earliest finishing
  available interval, so $"finish"(g_i) <= "finish"(o_i)$.

Now suppose $m > k$. Then $o_(k+1)$ exists and starts at or after $"finish"(o_k)$, which
is at or after $"finish"(g_k)$. So $o_(k+1)$ was still available when greedy stopped —
but greedy only stops when nothing fits. Contradiction. Therefore $m = k$ and greedy is
optimal.

#subsection[Trace]

Meetings $(1,4), (3,5), (0,6), (5,7), (3,9), (5,9), (6,10), (8,11)$.
Sorted by end: $(1,4), (3,5), (0,6), (5,7), (3,9), (5,9), (6,10), (8,11)$.

#table(columns: (auto, auto, auto, auto),
  [*Meeting*], [*Start $>=$ freeAt?*], [*Take?*], [*freeAt*],
  [(1,4)], [$1 >= -infinity$ yes], [yes], [4],
  [(3,5)], [$3 >= 4$ no],  [skip], [4],
  [(0,6)], [$0 >= 4$ no],  [skip], [4],
  [(5,7)], [$5 >= 4$ yes], [yes], [7],
  [(3,9)], [$3 >= 7$ no],  [skip], [7],
  [(5,9)], [$5 >= 7$ no],  [skip], [7],
  [(6,10)],[$6 >= 7$ no],  [skip], [7],
  [(8,11)],[$8 >= 7$ yes], [yes], [11],
)

Both versions were run on this input: brute force printed `3`, greedy printed `3`.
`maxMeetGreedy([])` prints `0`; `maxMeetGreedy([[4,4]])` prints `1`.
]
#ans[3 meetings: $(1,4), (5,7), (8,11)$]

#code(lang: "python", caption: "Python version")[
```python
def max_meetings(v):
    v.sort(key=lambda p: p[1])
    cnt, free_at = 0, float("-inf")
    for s, e in v:
        if s >= free_at:
            cnt += 1
            free_at = e
    return cnt
```
]

Run: on the eight meetings above it prints `3`; on `[]` it prints `0`.

#trap[
"Pick the shortest meeting first" *feels* right and is wrong. Meetings $(1,10)$,
$(9,11)$, $(10,20)$: shortest-first takes $(9,11)$ and then nothing else fits, giving 1.
Earliest-finish takes $(1,10)$ and $(10,20)$, giving 2.
]

#ex(9, tier: 1, asked: "Wipro pattern")[
A railway station. Train $i$ arrives at $a_i$ and departs at $d_i$. A train occupies a
platform for $[a_i, d_i)$. What is the *minimum number of platforms* so no train waits?

*Constraints:* $n <= 10^5$, times given as 24-hour numbers like 900 and 1145.
*Target:* $O(n log n)$. *Edge cases:* one train departs exactly when the next arrives;
all trains identical.
]
#sol[

#approach(1, "For each train, count how many are live at its arrival", verdict: "O(n^2)")

#code(lang: "js", caption: "roomsBrute")[
```js
const roomsBrute = (v) => {
  let best = 0;
  for (const [s] of v) {
    let live = 0;
    for (const [a, d] of v) if (a <= s && s < d) live++;
    best = Math.max(best, live);
  }
  return best;
};
```
]

#complexity(time: $O(n^2)$, space: $O(1)$, note: "Correct, because the busiest moment is always some train's arrival time. n = 10^5 means 10^10 operations. Too slow.")

#approach(2, "Sweep line: split into arrival events and departure events", verdict: "O(n log n), optimal")

The unlock: *a platform count only changes at an arrival (+1) or a departure ($-1$),
and which train an event belongs to does not matter.* So throw away the pairing. Sort
all arrivals into one array and all departures into another. Walk both with two pointers
and watch the running count.

#code(lang: "js", caption: "roomsSweep — two sorted event lists")[
```js
const roomsSweep = (v) => {
  const n = v.length;
  const st = v.map(([s]) => s).sort((a, b) => a - b);
  const en = v.map(([, e]) => e).sort((a, b) => a - b);
  let i = 0, j = 0, live = 0, best = 0;
  while (i < n) {
    if (st[i] < en[j]) { live++; i++; best = Math.max(best, live); }
    else               { live--; j++; }
  }
  return best;
};
```
]

#complexity(time: $O(n log n)$, space: $O(n)$, note: "Two sorts, one linear merge walk.")

#subsection[Trace]

Trains $(900,1010), (940,1200), (950,1120), (1100,1130), (1500,1900), (1800,2000)$.

Arrivals: `900 940 950 1100 1500 1800`. Departures: `1010 1120 1130 1200 1900 2000`.

#table(columns: (auto, auto, auto, auto, auto),
  [*st[i]*], [*en[j]*], [*st $<$ en?*], [*live*], [*best*],
  [900],  [1010], [yes], [1], [1],
  [940],  [1010], [yes], [2], [2],
  [950],  [1010], [yes], [3], [3],
  [1100], [1010], [no (a train left)], [2], [3],
  [1100], [1120], [yes], [3], [3],
  [1500], [1120], [no], [2], [3],
  [1500], [1130], [no], [1], [3],
  [1500], [1200], [no], [0], [3],
  [1500], [1900], [yes], [1], [3],
  [1800], [1900], [yes], [2], [3],
)

Both versions were run: both printed `3`. For $(1,5), (5,9), (9,12)$ — a perfect relay —
both printed `1`, which confirms the strict `<` handles the touching case correctly.
]
#ans[3 platforms]

#trap[
Use `st[i] < en[j]`, not `<=`. With `<=`, a train departing at 1010 and another arriving
at 1010 would be counted as needing two platforms. Flip this to `<=` only if the problem
says a platform needs cleaning time.
]

#ex(10, tier: 1, asked: "Accenture pattern")[
You already have a sorted list of *non-overlapping* intervals. Insert one new interval
and re-merge, keeping the list sorted and non-overlapping.

*Constraints:* $n <= 10^5$. *Target:* $O(n)$ — no re-sorting allowed.
*Edge cases:* the list is empty; the new interval lands after everything; the new
interval swallows the whole list.
]
#sol[

#approach(1, "Throw it on the pile and re-merge everything", verdict: "O(n log n) — correct, but it re-sorts data that was already sorted")

#code(lang: "js", caption: "insertBrute")[
```js
const insertBrute = (v, nw) => {
  const a = [...v.map(iv => [...iv]), [...nw]];
  a.sort((x, y) => x[0] - y[0] || x[1] - y[1]);
  const out = [a[0]];
  for (let i = 1; i < a.length; i++) {
    const last = out[out.length - 1];
    if (a[i][0] <= last[1]) last[1] = Math.max(last[1], a[i][1]);
    else out.push(a[i]);
  }
  return out;
};
```
]

#complexity(time: $O(n log n)$, space: $O(n)$, note: "It works — the run printed [1,5][6,9], [2,5] and [0,20] on the three test lists, matching the fast version. But sorting already-sorted data is wasted work.")

#approach(2, "Three zones, one linear pass", verdict: "O(n), optimal")

Because the list is already sorted and clean, you can split it into three zones in one
pass: intervals entirely to the *left* of the new one, intervals that *touch* it, and
intervals entirely to the *right*.

#code(lang: "js", caption: "insertInterval — three zones, one pass")[
```js
const insertInterval = (v, nw) => {
  const out = [];
  let [lo, hi] = nw, i = 0;
  while (i < v.length && v[i][1] < lo) out.push(v[i++]);     // fully left
  while (i < v.length && v[i][0] <= hi) {                    // overlapping
    lo = Math.min(lo, v[i][0]);
    hi = Math.max(hi, v[i][1]);
    i++;
  }
  out.push([lo, hi]);
  while (i < v.length) out.push(v[i++]);                     // fully right
  return out;
};
```
]

#complexity(time: $O(n)$, space: $O(n)$, note: "Every interval is looked at exactly once by exactly one of the three loops.")

Runs, all checked:

#table(columns: (auto, auto, auto),
  [*List*], [*Insert*], [*Output*],
  [`[1,3] [6,9]`], [`[2,5]`],  [`[1,5] [6,9]`],
  [`(empty)`],     [`[2,5]`],  [`[2,5]`],
  [`[1,3] [6,9]`], [`[10,12]`],[`[1,3] [6,9] [10,12]`],
  [`[1,3] [6,9]`], [`[0,20]`], [`[0,20]`],
)
]
#ans[`[1,5] [6,9]` for the first case]

#ex(11, tier: 1, asked: "TCS NQT pattern")[
Fractional knapsack. Items have weight $w_i$ and value $v_i$. The bag holds $W$ total
weight. You *may cut an item* and take part of it, getting that fraction of its value.
Maximise the value carried.

*Constraints:* $n <= 10^5$, $W <= 10^9$. *Target:* $O(n log n)$.
*Edge cases:* $W = 0$; total weight of all items less than $W$.
]
#sol[
Every unit of bag space should carry as much value as possible. So rank items by
*value per unit weight* and fill from the top. The last item may be cut.

*Exchange argument.* Take any optimal packing. If a lower-ratio item is in the bag while
some of a higher-ratio item is left outside, remove one kilogram of the lower one and put
in one kilogram of the higher one. Weight is unchanged and value went up or stayed equal.
Repeat until the packing is the greedy one.

#code(lang: "js", caption: "fracKnap — sort by value/weight")[
```js
const fracKnap = (item, cap) => {                    // item = [weight, value]
  const a = [...item].sort((x, y) => y[1] / y[0] - x[1] / x[0]);   // ratio, descending
  let got = 0;
  for (const [w, val] of a) {
    if (cap === 0) break;
    const take = Math.min(w, cap);
    got += val * take / w;
    cap -= take;
  }
  return got;
};
```
]

#complexity(time: $O(n log n)$, space: [$O(1)$ extra], note: "The sort dominates.")

#subsection[Trace]

Items $(10, 60), (20, 100), (30, 120)$, bag $= 50$.

#table(columns: (auto, auto, auto, auto, auto),
  [*Item (w, v)*], [*Ratio*], [*Take*], [*Value added*], [*Cap left*],
  [(10, 60)],  [6.0], [all 10], [60],  [40],
  [(20, 100)], [5.0], [all 20], [100], [20],
  [(30, 120)], [4.0], [20 of 30], [$120 times 20 \/ 30 = 80$], [0],
)

Run output: `240.00`. `fracKnap([[10,60]], 0)` prints `0.00`, and `fracKnap([], 50)` prints `0.00`.
]
#ans[240]

#trap[
This greedy is *only* valid because you may cut items. If items are all-or-nothing
(0/1 knapsack) the same greedy is wrong. Items $(10, 60)$ and $(20, 100)$ with a bag of
20: the ratios are 6.0 and 5.0, so greedy grabs the 10-weight item for 60 and the other
no longer fits — total 60. Taking the 20-weight item alone gives 100. This was checked
against an exhaustive search over all subsets, which printed 100 while the ratio greedy
printed 60. 0/1 knapsack needs DP.
]

#ex(12, tier: 1, asked: "Capgemini pattern")[
An array `a` where `a[i]` is the maximum number of steps you may jump forward from
index $i$. Starting at index 0, can you reach the last index?

*Constraints:* $n <= 10^5$, $0 <= a[i] <= 10^5$. *Target:* $O(n)$.
*Edge cases:* a single element (already at the end); a zero that blocks the path.
]
#sol[

#approach(1, "Backward DP — mark each index reachable or not", verdict: "O(n · maxJump), too slow")

#code(lang: "js", caption: "canJumpDP")[
```js
const canJumpDP = (a) => {
  const n = a.length;
  if (n === 0) return false;
  const ok = new Array(n).fill(false);
  ok[n - 1] = true;
  for (let i = n - 2; i >= 0; i--)
    for (let s = 1; s <= a[i] && i + s < n; s++)
      if (ok[i + s]) { ok[i] = true; break; }
  return ok[0];
};
```
]

#complexity(time: [$O(n^2)$ worst case], space: $O(n)$, note: "With every a[i] = n the inner loop is length n.")

#approach(2, "Carry one number: the farthest index reached so far", verdict: "O(n), O(1) space, optimal")

The unlock: you never need to know *which* index you jumped from. You only need the
farthest index any jump so far could land on. Walk left to right. If you ever stand at an
index beyond that farthest reach, there is a hole you cannot cross.

#code(lang: "js", caption: "canJumpGreedy")[
```js
const canJumpGreedy = (a) => {
  let reach = 0;
  for (let i = 0; i < a.length; i++) {
    if (i > reach) return false;            // a hole we can never cross
    reach = Math.max(reach, i + a[i]);
  }
  return true;
};
```
]

#complexity(time: $O(n)$, space: $O(1)$, note: "One pass, one integer of state.")

#subsection[Trace on $2, 3, 1, 1, 4$]

#table(columns: (auto, auto, auto, auto),
  [*i*], [*a[i]*], [*i $>$ reach?*], [*reach after*],
  [0], [2], [no], [$max(0, 0+2) = 2$],
  [1], [3], [no], [$max(2, 1+3) = 4$],
  [2], [1], [no], [$max(4, 3) = 4$],
  [3], [1], [no], [4],
  [4], [4], [no], [8],
)
Reached the end. Output `true`.

#subsection[Trace on $3, 2, 1, 0, 4$]

reach goes $3, 3, 3, 3$; at $i = 4$ we have $4 > 3$, so `false`. Output `false`.

Both versions were run on both inputs and on the single-element input `[0]`; all three
pairs agreed (`true true`, `false false`, `true true`).
]
#ans[`true` for $2,3,1,1,4$; `false` for $3,2,1,0,4$]

#ex(13, tier: 1, asked: "Cognizant pattern")[
Given $n$ intervals, delete the *fewest* of them so that no two of the survivors overlap.
Return how many you deleted.

*Constraints:* $n <= 10^5$. *Target:* $O(n log n)$.
*Edge cases:* empty list; no overlaps at all.
]
#sol[
This is Example 8 wearing a disguise. "Delete the fewest" $=$ "keep the most", and
"keep the most non-overlapping" is exactly Template B.

$ "deleted" = n - "kept" $

#code(lang: "js", caption: "minRemovals — keep the most, subtract")[
```js
const minRemovals = (v) => {
  if (v.length === 0) return 0;
  const a = [...v].sort((x, y) => x[1] - y[1]);
  let kept = 0, freeAt = -Infinity;
  for (const [s, e] of a)
    if (s >= freeAt) { kept++; freeAt = e; }
  return v.length - kept;
};
```
]

#complexity(time: $O(n log n)$, space: [$O(1)$ extra])

Run on $(1,4), (2,5), (3,6), (7,8)$: sorted by end it is the same order. Keep $(1,4)$,
skip $(2,5)$, skip $(3,6)$, keep $(7,8)$. Kept 2 out of 4, so the output is `2`.
`minRemovals([])` prints `0`.
]
#ans[2 deletions]

#trick[
The *same* function also answers "how many arrows to pop all the balloons" and "how many
machines to run all the jobs on one shift" — with one twist: for arrows, intervals that
merely *touch* can share an arrow, so the test becomes `s > freeAt` and you count the
kept groups instead of subtracting.
]

#ex(14, tier: 1, asked: "Infosys pattern")[
$m$ children, child $i$ needs a biscuit of size at least `need[i]`. You have $k$
biscuits with sizes `size[j]`. Each child gets at most one biscuit. Make the most
children happy.

*Constraints:* $m, k <= 10^5$. *Target:* $O(m log m + k log k)$.
*Edge cases:* no children; every biscuit too small.
]
#sol[

#approach(1, "For each child, search the whole biscuit list", verdict: "O(m · k), too slow")

#code(lang: "js", caption: "childrenBrute")[
```js
const childrenBrute = (need, size) => {
  const used = new Array(size.length).fill(false);
  let happy = 0;
  for (const nd of need) {
    let pick = -1;
    for (let j = 0; j < size.length; j++)
      if (!used[j] && size[j] >= nd && (pick === -1 || size[j] < size[pick])) pick = j;
    if (pick !== -1) { used[pick] = true; happy++; }
  }
  return happy;
};
```
]

#complexity(time: $O(m k)$, space: $O(k)$, note: "Run on the same three tests as the fast version, it printed 2, 0 and 0 — identical answers, 10^10 operations at the stated limits.")

#approach(2, "Sort both, then two pointers", verdict: "O(m log m + k log k), optimal")

Sort both lists ascending and walk them with two pointers. Always feed the *least
demanding unfed child* with the *smallest biscuit that is big enough*.

*Why it is safe:* if a bigger biscuit satisfies the fussiest child, a smaller one that
also fits satisfies them too — so spending the small one first never loses an option.

#code(lang: "js", caption: "contentChildren — two sorted lists, two pointers")[
```js
const contentChildren = (need, size) => {
  const nd = [...need].sort((a, b) => a - b);
  const sz = [...size].sort((a, b) => a - b);
  let i = 0, j = 0, happy = 0;
  while (i < nd.length && j < sz.length) {
    if (sz[j] >= nd[i]) { happy++; i++; }
    j++;
  }
  return happy;
};
```
]

#complexity(time: $O(m log m + k log k)$, space: [$O(1)$ extra])

Runs: `contentChildren([1,2,7], [1,1,3,5])` prints `2` (biscuit 1 feeds child 1,
biscuit 3 feeds child 2, biscuit 5 is too small for child 7).
`contentChildren([9], [1])` prints `0`. `contentChildren([], [1,2])` prints `0`.
`contentChildren([1,1,1], [1,1,1])` prints `3`.
]
#ans[2 happy children]

#note[
Notice that `j` advances on *every* loop turn but `i` advances only on a match. That is
the whole algorithm: a biscuit that cannot feed the current least-demanding child cannot
feed anybody, so throw it away.
]

#ex(15, tier: 1, asked: "TCS NQT pattern")[
Greedy coin change is not always right. Show that with coins ${25, 10, 1}$ and amount 30
the greedy answer is worse than the true best, and give the algorithm that is always
right.

*Constraints:* amount up to $10^4$, up to 20 coin types.
*Target:* $O("amount" times "coins")$. *Edge cases:* amount 0; a set with no way to pay.
]
#sol[
Greedy: $25 arrow.r 5$ left $arrow.r$ five 1s. That is $1 + 5 = 6$ coins.
True best: $10 + 10 + 10 = 3$ coins. Greedy is off by a factor of two.

The safe algorithm is a small DP. `dp[a]` is the fewest coins that make exactly `a`.

#code(lang: "js", caption: "coinsDP — always correct")[
```js
const coinsDP = (amount, coins) => {
  const dp = new Array(amount + 1).fill(Infinity);
  dp[0] = 0;
  for (let a = 1; a <= amount; a++)
    for (const c of coins)
      if (c <= a && dp[a - c] + 1 < dp[a]) dp[a] = dp[a - c] + 1;
  return dp[amount] === Infinity ? -1 : dp[amount];
};
```
]

#complexity(time: $O("amount" times "coins")$, space: $O("amount")$)

Verified side by side: `minCoins(30, [25,10,1])` from Example 1 prints `6` while
`coinsDP(30, [25,10,1])` prints `3`. On a set where greedy happens to be right,
`minCoins(7, [5,2])` and `coinsDP(7, [5,2])` both print `2`. `coinsDP(0, [2])` prints `0`
and `coinsDP(3, [2,4])` prints `-1`.
]
#ans[Greedy 6 coins, true best 3 coins. Use DP.]

#trap[
In an interview, never say "greedy" for coin change without adding "if the coin system is
canonical". Indian and most world currencies are canonical, so greedy happens to work —
but the interviewer is testing whether you know *why*, and the ${25,10,1}$ example is the
fastest way to show you do.
]

#section[Tier 2 — greedy with a business wrapper]

#tier-header(2)

#ex(16, tier: 2, asked: "Grab · pattern")[
A delivery hub runs $n$ one-hour jobs. Job $i$ earns `profit[i]` but must be *finished by
the end of hour* `deadline[i]`. Only one job can run in any hour, and hours are
$1, 2, 3, dots$. Schedule jobs to earn the most money. Report how many jobs you ran and
the total earned.

*Constraints:* $n <= 10^5$, deadlines up to $n$, profit up to $10^5$.
*Target:* $O(n log n)$.
*Edge cases:* one job; every job with deadline 1 (only one can run).
]
#sol[

#approach(1, "Take the richest job first, park it as late as it may legally run", verdict: "O(n · maxDeadline), passes most tests")

Why "as late as possible"? Because an early hour is more useful than a late hour: an
early hour can host a job with a tight deadline, a late hour cannot. So spend the *latest
legal hour* and keep the early hours free for jobs you have not seen yet.

#code(lang: "js", caption: "jobSeqSlots — greedy by profit, linear slot search")[
```js
// a job is { id, deadline, profit }
const jobSeqSlots = (job) => {
  const a = [...job].sort((x, y) => y.profit - x.profit);
  const last = a.reduce((m, j) => Math.max(m, j.deadline), 0);
  const slot = new Array(last + 1).fill(-1);        // slot[t] = job sitting in hour t
  let cnt = 0, money = 0;
  for (const j of a)
    for (let t = Math.min(j.deadline, last); t >= 1; t--)
      if (slot[t] === -1) { slot[t] = j.id; cnt++; money += j.profit; break; }
  return [cnt, money];
};
```
]

#complexity(time: $O(n dot D)$, space: $O(D)$, note: "D is the largest deadline. If deadlines are up to n this is O(n^2) in the worst case — all jobs with deadline n.")

#approach(2, "Same order, but a DSU jumps straight to the free hour", verdict: "O(n log n) effectively, optimal")

The inner loop wastes time walking over hours that are already full. A disjoint-set
union fixes that: `find(t)` returns the *latest free hour at or before t*. When you fill
hour $t$, point $t$ at $t - 1$, so the next `find` skips it instantly.

Use the tested `DSU` from the *JS Toolkit* appendix rather than writing one here. Note we
call `d.find` and then set `d.p[t]` by hand instead of calling `d.union` — union-by-rank
would attach the trees whichever way is shallower, and this trick needs the parent to
point *specifically* at $t - 1$.

#code(lang: "js", caption: "jobSeqDSU — the same greedy, with a skip pointer")[
```js
const { DSU } = require('./toolkit.js');       // JS Toolkit appendix

const jobSeqDSU = (job) => {
  const a = [...job].sort((x, y) => y.profit - x.profit);
  const last = a.reduce((m, j) => Math.max(m, j.deadline), 0);
  const d = new DSU(last + 1);                 // d.find(t) = latest free hour at or before t
  let cnt = 0, money = 0;
  for (const j of a) {
    const t = d.find(Math.min(j.deadline, last));
    if (t > 0) {
      d.p[t] = t - 1;                          // skip pointer, NOT union-by-rank
      cnt++; money += j.profit;
    }
  }
  return [cnt, money];
};
```
]

#complexity(time: $O(n log n)$, space: $O(D)$, note: "Sorting dominates; every find is near-constant after path compression.")

#subsection[Trace]

Jobs (id, deadline, profit):
$(1, 4, 20), (2, 1, 10), (3, 1, 40), (4, 1, 30), (5, 2, 60)$.
Sorted by profit: 60, 40, 30, 20, 10.

#table(columns: (auto, auto, auto, auto, auto),
  [*Profit*], [*Deadline*], [*Latest free hour*], [*Placed?*], [*Money*],
  [60], [2], [2], [yes, hour 2], [60],
  [40], [1], [1], [yes, hour 1], [100],
  [30], [1], [none (hour 1 full)], [no], [100],
  [20], [4], [4], [yes, hour 4], [120],
  [10], [1], [none], [no], [120],
)

Both versions were run on this input. Both printed `3 120`. A one-job input
$(1, 2, 100)$ printed `1 100`.
]
#ans[3 jobs, 120 profit]

#trap[
$10^5$ jobs at $10^5$ profit is $10^10$. In C++ or Java that overflows a 32-bit `int` and
you would reach for a 64-bit integer; in JavaScript a plain number holds it exactly, because
$10^10$ is far below $2^53 - 1$. The run confirmed `100000 10000000000` with
`Number.isSafeInteger` returning `true`. Only start worrying past about
$9 times 10^15$ — then switch the accumulator to `BigInt`.
]

#ex(17, tier: 2, asked: "Shopee · pattern")[
Now do more than count rooms. Given $n$ meetings, actually *assign a room number*
to each meeting, using as few rooms as possible. Return the room number for each meeting
*in the original input order*.

*Constraints:* $n <= 10^5$. *Target:* $O(n log n)$.
*Edge cases:* meetings that touch end-to-start must share a room; all meetings at once.
]
#sol[
*JavaScript has no built-in priority queue.* Use the `MinHeap` from the *JS Toolkit*
appendix — it takes an optional comparator, so one class covers min-heaps, max-heaps and
heaps of tuples.

Counting used a sweep. Assigning needs to remember *which* room freed up. Two heaps:

- `busy`: min-heap of (free-at time, room number) — rooms in use.
- `spare`: min-heap of room numbers that are free right now.

Process meetings in start order. Move every room whose meeting has ended into `spare`.
Reuse the lowest-numbered spare room if any, else open a brand new room.

#code(lang: "js", caption: "assignRooms — two heaps")[
```js
const { MinHeap } = require('./toolkit.js');   // JS has no priority queue

const assignRooms = (v) => {
  const room = new Array(v.length).fill(-1);
  const order = [...v.keys()].sort((a, b) => v[a][0] - v[b][0] || v[a][1] - v[b][1]);
  const busy  = new MinHeap((a, b) => a[0] - b[0]);   // [freeAt, room]
  const spare = new MinHeap();                       // free room numbers
  let made = 0;
  for (const i of order) {
    while (busy.size && busy.peek()[0] <= v[i][0]) spare.push(busy.pop()[1]);
    const r = spare.size ? spare.pop() : made++;
    room[i] = r;
    busy.push([v[i][1], r]);
  }
  return room;
};
```
]

#complexity(time: $O(n log n)$, space: $O(n)$, note: "Each meeting enters and leaves each heap at most once.")

#subsection[Trace]

Meetings $(0,30), (5,10), (15,20), (35,40)$ — already in start order.

#table(columns: (auto, 1fr, auto),
  [*Meeting*], [*What frees up first*], [*Room given*],
  [(0,30)],  [nothing busy, no spares], [new room 0],
  [(5,10)],  [room 0 busy until 30], [new room 1],
  [(15,20)], [room 1 freed at 10, goes to spare], [reuse room 1],
  [(35,40)], [rooms 0 and 1 both freed by 30], [reuse room 0 (lowest spare)],
)

Run output: `0 1 1 0`. The maximum room number used is 1, so 2 rooms — which matches
what the sweep-line count of Example 9 would say. `assignRooms([])` prints nothing,
$(1,5), (5,9), (9,12)$ gives `0 0 0` (one room, reused twice) and three copies of
$(1,9)$ give `0 1 2`.
]
#ans[Rooms `0 1 1 0` — two rooms are enough]

#ex(18, tier: 2, asked: "Agoda · pattern")[
A ring road has $n$ fuel pumps. Pump $i$ gives `gas[i]` litres, and driving from pump $i$
to pump $i+1$ burns `cost[i]` litres. The tank starts empty and has no limit. Find a pump
you can start from and complete the whole loop, or report $-1$. The answer is unique if
it exists.

*Constraints:* $n <= 10^5$, values up to $10^4$ (a running total reaches $10^9$ — well inside a JS number).
*Target:* $O(n)$. *Edge cases:* one pump; total gas less than total cost.
]
#sol[

#approach(1, "Start at every pump and drive the loop", verdict: "O(n^2)")

#code(lang: "js", caption: "startBrute")[
```js
const startBrute = (gas, cost) => {
  const n = gas.length;
  for (let s = 0; s < n; s++) {
    let tank = 0, ok = true;
    for (let k = 0; k < n; k++) {
      const i = (s + k) % n;
      tank += gas[i] - cost[i];
      if (tank < 0) { ok = false; break; }
    }
    if (ok) return s;
  }
  return -1;
};
```
]

#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "One pass, restart the moment the tank goes negative", verdict: "O(n), optimal")

Two facts unlock it.

+ *If the total of all $("gas"[i] - "cost"[i])$ is negative, no start works.* You cannot
  create fuel. If it is zero or positive, some start works.
+ *If you start at $s$ and die somewhere between $s$ and $j$, then none of
  $s, s+1, dots, j$ works either.* Reason: starting at $s$ you arrived at every pump in
  between with a tank that was zero or better. Starting *later* means you arrive with
  less, so you die no later. So skip straight past $j$ and try $j + 1$.

#code(lang: "js", caption: "startGreedy — single pass")[
```js
const startGreedy = (gas, cost) => {
  let total = 0, tank = 0, start = 0;
  for (let i = 0; i < gas.length; i++) {
    const d = gas[i] - cost[i];
    total += d; tank += d;
    if (tank < 0) { start = i + 1; tank = 0; }
  }
  return total < 0 ? -1 : start;
};
```
]

#complexity(time: $O(n)$, space: $O(1)$, note: "One pass. Two running sums, nothing else.")

#subsection[Trace]

`gas = 1 2 3 4 5`, `cost = 3 4 5 1 2`, so `d = -2 -2 -2 3 3`.

#table(columns: (auto, auto, auto, auto, auto),
  [*i*], [*d*], [*tank after*], [*tank $<$ 0?*], [*start*],
  [0], [$-2$], [$-2$], [yes, reset], [1],
  [1], [$-2$], [$-2$], [yes, reset], [2],
  [2], [$-2$], [$-2$], [yes, reset], [3],
  [3], [3],    [3],    [no],         [3],
  [4], [3],    [6],    [no],         [3],
)
`total` $= -2-2-2+3+3 = 0 >= 0$, so the answer is pump 3.

Both versions were run: both printed `3`. With `gas = 2 3 4`, `cost = 3 4 3` the total is
$-1$ and both printed `-1`. With one pump `gas = 5`, `cost = 4` both printed `0`.
]
#ans[Start at pump index 3]

#code(lang: "python", caption: "Python version")[
```python
def fuel_start(gas, cost):
    total = tank = 0
    start = 0
    for i, (g, c) in enumerate(zip(gas, cost)):
        total += g - c
        tank += g - c
        if tank < 0:
            start, tank = i + 1, 0
    return start if total >= 0 else -1
```
]

Run: prints `3` and `-1` for the two cases above.

#trap[
Do not return `start` without the `total` check. On `gas = 2 3 4`, `cost = 3 4 3` the
loop would leave `start = 1` even though no start works at all.
]

#ex(19, tier: 2, asked: "Sea · pattern")[
A small lift carries at most *two* people and at most `limit` kilograms per trip. Given
everybody's weight (each $<=$ `limit`), find the fewest trips.

*Constraints:* $n <= 10^5$. *Target:* $O(n log n)$.
*Edge cases:* one person; everybody so heavy that nobody can share.
]
#sol[
Sort ascending. Point `i` at the lightest and `j` at the heaviest. The heaviest person
*must* travel now in some trip — so send them. If the lightest can ride along without
breaking the limit, send them too; otherwise the heaviest rides alone.

*Why pairing the lightest with the heaviest is safe:* if the lightest person cannot ride
with the heaviest, nobody can, so the heaviest is alone in every possible solution. If the
lightest *can* ride with the heaviest, then swapping whoever the optimal put with the
heaviest for the lightest keeps the trip legal and frees a heavier person for later.

#code(lang: "js", caption: "minBoats — two pointers from both ends")[
```js
const minBoats = (w, limit) => {
  const a = [...w].sort((x, y) => x - y);
  let i = 0, j = a.length - 1, boats = 0;
  while (i <= j) {
    if (a[i] + a[j] <= limit) i++;   // lightest rides with heaviest
    j--; boats++;                    // heaviest always leaves now
  }
  return boats;
};
```
]

#complexity(time: $O(n log n)$, space: [$O(1)$ extra])

#subsection[Trace]

Weights $3, 5, 3, 4$ with `limit = 5`. Sorted: $3, 3, 4, 5$.

#table(columns: (auto, auto, auto, 1fr, auto),
  [*i*], [*j*], [*w[i] + w[j]*], [*Decision*], [*Trips*],
  [0], [3], [$3 + 5 = 8 > 5$], [5 rides alone], [1],
  [0], [2], [$3 + 4 = 7 > 5$], [4 rides alone], [2],
  [0], [1], [$3 + 3 = 6 > 5$], [one 3 rides alone], [3],
  [0], [0], [$3 + 3 = 6 > 5$], [last 3 rides alone], [4],
)

Run output: `4`. `minBoats([1,2], 3)` prints `1`; `minBoats([9], 9)` prints `1`; `minBoats([], 5)` prints `0`.
]
#ans[4 trips]

#trap[
`while (i <= j)` — not `i < j`. When one person is left, `i == j` and that person still
needs a trip. Using `<` silently loses them.
]

#ex(20, tier: 2, asked: "LINE MAN · pattern")[
A lowercase string. Cut it into as many pieces as possible so that *every letter appears
in only one piece*. Return the piece lengths in order.

*Constraints:* length up to $10^5$. *Target:* $O(n)$ time, $O(1)$ extra space (26 slots).
*Edge cases:* one repeated letter; all letters distinct.
]
#sol[
Record the *last position* of every letter. Then walk the string carrying `reach`, the
furthest index any letter seen so far must still reach. The moment `i == reach`, every
letter inside the current piece has finished — so cut there.

#code(lang: "js", caption: "partitionSizes — last-position + reach")[
```js
const partitionSizes = (s) => {
  const lastAt = new Map();                                 // Map, not a 26-slot array
  for (let i = 0; i < s.length; i++) lastAt.set(s[i], i);
  const out = [];
  let start = 0, reach = 0;
  for (let i = 0; i < s.length; i++) {
    reach = Math.max(reach, lastAt.get(s[i]));
    if (i === reach) { out.push(i - start + 1); start = i + 1; }
  }
  return out;
};
```
]

#complexity(time: $O(n)$, space: $O(1)$, note: "Two passes, a fixed 26-slot table.")

#subsection[Trace on `abacdefegh`]

Last positions: a $arrow.r$ 2, b $arrow.r$ 1, c $arrow.r$ 3, d $arrow.r$ 4, e $arrow.r$ 7,
f $arrow.r$ 6, g $arrow.r$ 8, h $arrow.r$ 9.

#table(columns: (auto, auto, auto, auto, 1fr),
  [*i*], [*char*], [*lastAt*], [*reach*], [*cut?*],
  [0], [a], [2], [2], [no],
  [1], [b], [1], [2], [no],
  [2], [a], [2], [2], [yes $arrow.r$ piece `aba`, length 3],
  [3], [c], [3], [3], [yes $arrow.r$ piece `c`, length 1],
  [4], [d], [4], [4], [yes $arrow.r$ piece `d`, length 1],
  [5], [e], [7], [7], [no],
  [6], [f], [6], [7], [no],
  [7], [e], [7], [7], [yes $arrow.r$ piece `efe`, length 3],
  [8], [g], [8], [8], [yes $arrow.r$ piece `g`, length 1],
  [9], [h], [9], [9], [yes $arrow.r$ piece `h`, length 1],
)

Run output: `3 1 1 3 1 1`. For `zzzz` it prints `4`.
]
#ans[`3 1 1 3 1 1` — pieces `aba | c | d | efe | g | h`]

#ex(21, tier: 2, asked: "Razer · pattern")[
You have $n$ ropes. Joining two ropes of length $a$ and $b$ costs $a + b$ and produces one
rope of length $a + b$. Join all of them into one rope at the least total cost.

*Constraints:* $n <= 10^5$, each length up to $10^5$. The total cost reaches $10^10$.
*Target:* $O(n log n)$. *Edge cases:* zero ropes; one rope.
]
#sol[

#approach(1, "Scan the list for the two shortest, every single time", verdict: "O(n^2)")

#code(lang: "js", caption: "joinRopesBrute")[
```js
const joinRopesBrute = (len) => {
  const v = [...len];
  let cost = 0;
  while (v.length > 1) {
    let i = 0;
    for (let t = 1; t < v.length; t++) if (v[t] < v[i]) i = t;
    const a = v.splice(i, 1)[0];
    let j = 0;
    for (let t = 1; t < v.length; t++) if (v[t] < v[j]) j = t;
    const b = v.splice(j, 1)[0];
    cost += a + b;
    v.push(a + b);
  }
  return cost;
};
```
]

#complexity(time: $O(n^2)$, space: $O(n)$, note: "n-1 joins, each with two linear scans and two erases. It printed 29, 0 and 0 on the tests below — the same answers, just slowly.")

#approach(2, "Let a min-heap hand you the two shortest", verdict: "O(n log n), optimal")

Every time a rope takes part in a join, its whole length is paid again. So a rope joined
early gets charged many times. Therefore: *always join the two shortest ropes.* A
min-heap gives them to you in $O(log n)$ — and since JavaScript ships no heap, that is the
toolkit `MinHeap` again.

#code(lang: "js", caption: "joinRopes — min-heap greedy")[
```js
const { MinHeap } = require('./toolkit.js');

const joinRopes = (len) => {
  if (len.length <= 1) return 0;
  const pq = new MinHeap();
  for (const x of len) pq.push(x);
  let cost = 0;
  while (pq.size > 1) {
    const a = pq.pop(), b = pq.pop();
    cost += a + b;
    pq.push(a + b);
  }
  return cost;
};
```
]

#complexity(time: $O(n log n)$, space: $O(n)$, note: "n-1 joins, each two pops and one push.")

#subsection[Trace]

Ropes $4, 3, 2, 6$.

#table(columns: (auto, auto, auto, auto),
  [*Heap*], [*Two smallest*], [*Cost added*], [*Total*],
  [2 3 4 6], [2 and 3], [5],  [5],
  [4 5 6],   [4 and 5], [9],  [14],
  [6 9],     [6 and 9], [15], [29],
  [15],      [done],    [—],  [29],
)

Run output: `29`. `joinRopes([7])` prints `0`, `joinRopes([])` prints `0`.

*Size check.* With $10^5$ ropes of length 20000 the answer is `33378560000`. The run
printed exactly that, and `Number.isSafeInteger` on it returned `true` — $3.3 times 10^10$
is nowhere near $2^53 - 1$.
]
#ans[29]

#trap[
Even with small individual lengths, the *total* explodes because every join re-pays the
whole combined length. In JavaScript that is fine up to $2^53 - 1$; raise the constraints
to $10^6$ ropes of length $10^9$ and the answer passes $10^16$, at which point plain
numbers start rounding and you need `BigInt` — including inside the heap, with
`new MinHeap((a, b) => (a < b ? -1 : a > b ? 1 : 0))`, because `a - b` on BigInts returns
a BigInt and the heap wants a plain number.
]

#ex(22, tier: 2, asked: "DBS · pattern")[
Several employees each have a sorted list of busy intervals. Find every *free window
common to everybody* that is at least `minLen` long.

*Constraints:* total intervals up to $10^5$. *Target:* $O(n log n)$.
*Edge cases:* one employee only; no common gap at all.
]
#sol[
The insight: a window is free for everybody exactly when it lies in *no* busy interval.
So dump every interval from every person into one list, merge it (Template A), and read
off the gaps between merged blocks.

#code(lang: "js", caption: "commonFree — merge everything, report the holes")[
```js
const commonFree = (people, minLen) => {
  const all = people.flat().sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const gaps = [];
  if (all.length === 0) return gaps;
  let reach = all[0][1];
  for (let i = 1; i < all.length; i++) {
    if (all[i][0] > reach) {
      if (all[i][0] - reach >= minLen) gaps.push([reach, all[i][0]]);
      reach = all[i][1];
    } else reach = Math.max(reach, all[i][1]);
  }
  return gaps;
};
```
]

#complexity(time: $O(n log n)$, space: $O(n)$)

#subsection[Trace]

Person A busy $(1,3), (6,7)$; person B busy $(2,4)$; person C busy $(2,5), (9,12)$,
with `minLen = 1`.

Pooled and sorted: $(1,3), (2,4), (2,5), (6,7), (9,12)$.

#table(columns: (auto, auto, 1fr),
  [*Interval*], [*reach*], [*Gap found*],
  [(1,3)], [3], [—],
  [(2,4)], [4], [$2 <= 3$, overlaps, extend],
  [(2,5)], [5], [$2 <= 4$, overlaps, extend],
  [(6,7)], [7], [$6 > 5$ $arrow.r$ gap `[5,6]`],
  [(9,12)],[12],[$9 > 7$ $arrow.r$ gap `[7,9]`],
)

Run output: `[5,6][7,9]`.
]
#ans[`[5,6]` and `[7,9]`]

#ex(23, tier: 2, asked: "GIC · pattern")[
Given non-negative integers, join them end to end to make the *largest possible number*.
Return it as a string.

*Constraints:* $n <= 10^4$, values up to $10^9$.
*Target:* $O(n log n dot L)$ where $L$ is the digit length.
*Edge cases:* every number is 0 (answer is `"0"`, not `"000"`); a single number.
]
#sol[

#approach(1, "Try every ordering", verdict: "O(n! · L), only useful as a checker")

#code(lang: "js", caption: "joinBiggestBrute")[
```js
const permutations = (a) => a.length <= 1 ? [a] :
  a.flatMap((x, i) =>
    permutations([...a.slice(0, i), ...a.slice(i + 1)]).map(p => [x, ...p]));

const joinBiggestBrute = (a) => {
  if (a.length === 0) return '0';
  let best = '';
  for (const p of permutations(a.map(String))) {
    const cur = p.join('');
    if (best === '' || cur.length > best.length ||
        (cur.length === best.length && cur > best)) best = cur;
  }
  return best[0] === '0' ? '0' : best;
};
```
]

#complexity(time: $O(n! dot L)$, space: $O(n L)$, note: "Run on the three test inputs it printed 9534330, 0 and 12 — exactly what the comparator version gives. That agreement is the evidence the comparator is right.")

#approach(2, "One sort with the right comparator", verdict: "O(n log n · L), optimal")

Sorting by value fails: $3$ vs $30$ — is 3 bigger? As numbers yes, but `330 > 303`, so
3 must come first. Sorting by first digit fails too: $34$ vs $3$ — `343 > 334`, so 34
comes first even though the first digits tie.

The correct rule compares the two *possible joins*:

$ a "comes before" b "when" (a + b) > (b + a) "as strings" $

#code(lang: "js", caption: "joinBiggest — the a+b vs b+a comparator")[
```js
const joinBiggest = (a) => {
  const s = a.map(String)
    .sort((x, y) => (x + y > y + x ? -1 : x + y < y + x ? 1 : 0));
  if (s.length === 0 || s[0] === '0') return '0';
  return s.join('');
};
```
]

#complexity(time: $O(n log n dot L)$, space: $O(n L)$, note: "Every comparison builds two strings of length at most 2L.")

#subsection[Why this comparator is a valid ordering]

It is *transitive* — that is the part people doubt. Sketch: writing $a$ followed by $b$
as a number is $a dot 10^(|b|) + b$. The test $a + b > b + a$ becomes
$a dot 10^(|b|) + b > b dot 10^(|a|) + a$, i.e.
$a (10^(|b|) - 1) > b (10^(|a|) - 1)$, i.e.
$ a / (10^(|a|) - 1) > b / (10^(|b|) - 1) $
That is a comparison of two plain numbers, and plain number comparison is transitive.

Run: `joinBiggest([3, 30, 34, 5, 9])` prints `9534330`;
`joinBiggest([0, 0])` prints `0`; `joinBiggest([12])` prints `12`;
`joinBiggest([])` prints `0`; `joinBiggest([10, 2])` prints `210`.

Note the comparator shape. `(x, y) => x + y > y + x` would be a boolean and would not
sort at all; the three-way `? -1 : ... ? 1 : 0` is what a JS comparator has to return.
The plain `>` on strings is safe here because `x + y` and `y + x` always have the *same
length*, so a character-by-character comparison is exactly a numeric one.
]
#ans[`9534330`]

#trap[
Miss the all-zero guard and you print `00`. Checking only `s[0] === '0'` is enough: if the
biggest piece after sorting is `'0'`, every piece is `'0'`. Note `a.map(String)`, not
`a.map(x => x.toString())` inside a callback that also receives an index — `map(Number)`
and `map(String)` are safe, `map(parseInt)` famously is not.
]

#section[Tier 3 — insight, then the follow-up]

#tier-header(3)

#ex(24, tier: 3, asked: "Google · pattern")[
A road runs from position 0 to position $n$. At every integer position $i$ there is a
sprinkler with radius `r[i]`; it wets the closed range $[i - r[i], i + r[i]]$. A radius
of 0 means the sprinkler is broken. Use the *fewest* sprinklers to wet the whole road, or
report $-1$.

*Constraints:* $n <= 10^4$. *Target:* $O(n)$ after an $O(n)$ preparation pass.
*Edge cases:* $n = 0$ (already wet, answer 0); every sprinkler broken.

*Follow-up the interviewer asks next:* "the sprinklers are now at arbitrary real
positions, not integers — what changes?"
]
#sol[

#approach(1, "DP over positions", verdict: "O(n^2), fine for n = 10^4 but not the answer they want")

`dp[x]` = fewest sprinklers to wet everything from 0 up to $x$.

#code(lang: "js", caption: "coverDP — the reference answer")[
```js
const coverDP = (n, r) => {
  const dp = new Array(n + 1).fill(Infinity);
  dp[0] = 0;
  for (let i = 0; i <= n; i++) {
    if (r[i] === 0) continue;
    const lo = Math.max(0, i - r[i]), hi = Math.min(n, i + r[i]);
    let best = Infinity;
    for (let j = lo; j <= hi; j++) best = Math.min(best, dp[j]);
    if (best === Infinity) continue;
    for (let j = lo; j <= hi; j++) dp[j] = Math.min(dp[j], best + 1);
  }
  return dp[n] === Infinity ? -1 : dp[n];
};
```
]

#complexity(time: $O(n^2)$, space: $O(n)$)

#approach(2, "Convert to intervals, then jump greedily", verdict: "O(n), optimal")

Two steps, and the first one is the whole trick.

*Step 1 — forget the sprinklers, keep the reach.* A sprinkler at $i$ with radius $r$
says: "if the wet part already reaches position $i - r$, I can push it to $i + r$."
So build `far[L]` $=$ the furthest right any single sprinkler can push you, given you have
already covered up to $L$. Several sprinklers may share the same $L$; keep the best.

*Step 2 — jump.* Stand at `reach`. Look at every start from 0 to `reach` that you have
not looked at yet, and remember the best `far` among them. Jump there. One sprinkler
used. Repeat. If the best jump does not move you, there is a dry gap and the answer is
$-1$.

#code(lang: "js", caption: "coverGreedy — interval cover in one pass")[
```js
const coverGreedy = (n, r) => {
  const far = new Array(n + 1).fill(0);
  for (let i = 0; i <= n; i++) {
    if (r[i] === 0) continue;
    const lo = Math.max(0, i - r[i]);
    far[lo] = Math.max(far[lo], Math.min(n, i + r[i]));
  }
  let used = 0, reach = 0, nxt = 0, i = 0;
  while (reach < n) {
    while (i <= reach) { nxt = Math.max(nxt, far[i]); i++; }
    if (nxt <= reach) return -1;        // stuck, a dry gap
    reach = nxt; used++;
  }
  return used;
};
```
]

#complexity(time: $O(n)$, space: $O(n)$, note: "The pointer i never moves backwards, so the inner while loop runs n times in total across the whole algorithm.")

#subsection[Trace]

$n = 7$, radii $1, 2, 1, 0, 2, 1, 0, 1$ at positions $0 dots 7$.

Reaches: position 0 $arrow.r$ $[0,1]$, 1 $arrow.r$ $[0,3]$, 2 $arrow.r$ $[1,3]$,
4 $arrow.r$ $[2,6]$, 5 $arrow.r$ $[4,6]$, 7 $arrow.r$ $[6,7]$.

So `far[0] = 3` (from position 1), `far[1] = 3`, `far[2] = 6`, `far[4] = 6`, `far[6] = 7`.

#table(columns: (auto, auto, auto, auto),
  [*reach*], [*Starts scanned*], [*Best far*], [*Used*],
  [0], [far[0] = 3], [3], [1],
  [3], [far[1], far[2], far[3] $arrow.r$ 3, 6, 0], [6], [2],
  [6], [far[4], far[5], far[6] $arrow.r$ 6, 0, 7], [7], [3],
  [7], [done], [—], [3],
)

Both versions were run on four inputs and agreed every time:
$n=5$ with radii $3,4,1,1,0,0$ $arrow.r$ `1`; $n=3$ all broken $arrow.r$ `-1`;
$n=7$ above $arrow.r$ `3`; $n=0$ $arrow.r$ `0`.
]
#ans[3 sprinklers]

#subsection[Follow-up: arbitrary real positions]
Sprinklers are now pairs $(L_i, R_i)$ in any order with real endpoints. The `far[]`
array no longer works because the index is not an integer. Fix: sort the pairs by $L$,
then sweep with a pointer that admits every interval whose $L <=$ `reach` and tracks the
largest $R$ among them. Same loop, same proof; the cost becomes $O(m log m)$ for the
sort instead of $O(n)$.

#ex(25, tier: 3, asked: "Amazon · pattern")[
A worker has a list of tasks, each labelled `A`..`Z`. Two tasks with the *same* label must
be separated by at least `cool` idle-or-different slots. Each task takes one slot. Find
the shortest total number of slots.

*Constraints:* up to $10^5$ tasks, `cool` up to 100. *Target:* $O(n + 26)$.
*Edge cases:* `cool = 0`; a single task; two labels tied for most frequent.

*Follow-up the interviewer asks next:* "now print an actual valid schedule, not just its
length."
]
#sol[
Think about the *most frequent* label. Say it appears $m$ times. Those $m$ copies force
$m - 1$ gaps, and each gap is at least `cool` slots wide, so those copies alone stretch
the timeline to

$ (m - 1) times ("cool" + 1) + 1 "slots" $

If several labels tie at frequency $m$, each tie adds one more slot at the very end.
With `ties` labels at the maximum:

$ "frame" = (m - 1) times ("cool" + 1) + "ties" $

Every other task is *poured into the idle holes* of that frame. If there are enough
holes, the frame is the answer. If there are more tasks than holes, the holes all fill up
and the schedule has no idle time at all, so the answer is just $n$. Hence:

$ "answer" = max("frame", n) $

#code(lang: "js", caption: "scheduleLength — the frame formula")[
```js
const scheduleLength = (task, cool) => {
  const cnt = new Map();
  for (const c of task) cnt.set(c, (cnt.get(c) ?? 0) + 1);
  const mx = Math.max(0, ...cnt.values());                    // at most 26 values
  const ties = [...cnt.values()].filter(v => v === mx).length;
  const frame = (mx - 1) * (cool + 1) + ties;
  return Math.max(frame, task.length);
};
```
]

#complexity(time: $O(n)$, space: $O(1)$, note: "One counting pass plus a fixed 26-slot scan.")

#diagram(height: 3.4cm, caption: "A A A with cool = 2: three copies, two gaps of width 2, frame = 8")[
  #dnode(0.2cm, 0.4cm, 1.1cm, 0.7cm, "A", fill: rgb("#e6eef5"))
  #dnode(1.4cm, 0.4cm, 1.1cm, 0.7cm, "B")
  #dnode(2.6cm, 0.4cm, 1.1cm, 0.7cm, "idle", fill: rgb("#f3f3f3"))
  #dnode(3.8cm, 0.4cm, 1.1cm, 0.7cm, "A", fill: rgb("#e6eef5"))
  #dnode(5.0cm, 0.4cm, 1.1cm, 0.7cm, "B")
  #dnode(6.2cm, 0.4cm, 1.1cm, 0.7cm, "idle", fill: rgb("#f3f3f3"))
  #dnode(7.4cm, 0.4cm, 1.1cm, 0.7cm, "A", fill: rgb("#e6eef5"))
  #dnode(8.6cm, 0.4cm, 1.1cm, 0.7cm, "B")
  #darrow(0.75cm, 1.5cm, 3.8cm, 1.5cm, label: "gap = cool + 1")
  #dnode(0.2cm, 2.1cm, 9.5cm, 0.7cm, "frame = (3-1)(2+1) + 2 ties = 8, and n = 6, so answer = 8", fill: rgb("#eef3ea"))
]

#table(columns: (auto, auto, auto, auto, auto, auto),
  [*Tasks*], [*cool*], [*m*], [*ties*], [*frame*], [*Answer*],
  [A A A B B B], [2], [3], [2], [$2 times 3 + 2 = 8$], [8],
  [A A A B B B], [0], [3], [2], [$2 times 1 + 2 = 4$], [$max(4, 6) = 6$],
  [A B C D E A B C], [2], [2], [3], [$1 times 3 + 3 = 6$], [$max(6, 8) = 8$],
  [A], [5], [1], [1], [$0 + 1 = 1$], [1],
)

All four rows were run and printed `8 6 8 1`.
]
#ans[8, 6, 8, 1 for the four rows]

#subsection[Follow-up: print a real schedule]
Use a max-heap of (remaining count, label). Repeat: pop up to `cool + 1` distinct labels,
write them out (writing `idle` if the heap runs dry but tasks remain), decrement each
count, and push back the ones still above zero. That is $O(n log 26)$ and produces a
schedule whose length matches the formula.

#trap[
With $m = 10^5$ and `cool` $= 100$ the frame is about $10^7$ — fine anywhere. Interviewers
often raise `cool` to $10^9$ to see whether you noticed: $(m-1)("cool"+1)$ is then about
$10^14$, which overflows a 32-bit `int` in C++ but is still *exact* in a JavaScript
number. The run printed `99999000100000` with `Number.isSafeInteger` true. Push `cool` to
$10^12$ and you are past $2^53 - 1$ — that is when `BigInt` becomes the answer, not before.

Second, smaller trap in the same function: `Math.max(0, ...cnt.values())` spreads the
values as arguments, and spreading a *large* array blows the call stack around $10^5$
elements. It is safe here only because there are at most 26 labels. For a general array
write `arr.reduce((m, x) => Math.max(m, x), -Infinity)`.
]

#ex(26, tier: 3, asked: "Microsoft · pattern")[
Children stand in a line, each with a rating. Give every child at least one sweet, and any
child whose rating is *strictly higher* than a neighbour must get strictly more sweets
than that neighbour. Use the fewest sweets.

*Constraints:* $n <= 10^5$, ratings up to $10^9$. The total fits a JS number easily.
*Target:* $O(n)$ time. *Edge cases:* empty line; all ratings equal; a strictly increasing
run of length $n$.

*Follow-up the interviewer asks next:* "now do it in $O(1)$ extra space."
]
#sol[

#approach(1, "Keep fixing broken neighbours until nothing changes", verdict: "O(n^2) worst case")

#code(lang: "js", caption: "sweetsBrute")[
```js
const sweetsBrute = (rank) => {
  const n = rank.length;
  if (n === 0) return 0;
  const c = new Array(n).fill(1);
  let changed = true;
  while (changed) {
    changed = false;
    for (let i = 0; i < n; i++) {
      if (i > 0 && rank[i] > rank[i-1] && c[i] <= c[i-1]) { c[i] = c[i-1] + 1; changed = true; }
      if (i + 1 < n && rank[i] > rank[i+1] && c[i] <= c[i+1]) { c[i] = c[i+1] + 1; changed = true; }
    }
  }
  return c.reduce((s, x) => s + x, 0);
};
```
]

#complexity(time: $O(n^2)$, space: $O(n)$, note: "A strictly rising line of n children needs n sweeps. It printed 5, 4, 0, 4 and 15 on the five tests — the same as the two-pass version.")

#approach(2, "One pass each way", verdict: "O(n), optimal")

The constraint has *two directions* and one pass can only satisfy one of them. So do two
passes and take the maximum.

+ Left to right: if `rank[i] > rank[i-1]` then `c[i] = c[i-1] + 1`.
+ Right to left: if `rank[i] > rank[i+1]` then `c[i] = max(c[i], c[i+1] + 1)`.

The `max` in pass 2 is essential — it protects the work pass 1 already did.

#code(lang: "js", caption: "sweets — two passes")[
```js
const sweets = (rank) => {
  const n = rank.length;
  if (n === 0) return 0;
  const c = new Array(n).fill(1);
  for (let i = 1; i < n; i++)
    if (rank[i] > rank[i-1]) c[i] = c[i-1] + 1;
  for (let i = n - 2; i >= 0; i--)
    if (rank[i] > rank[i+1]) c[i] = Math.max(c[i], c[i+1] + 1);
  return c.reduce((s, x) => s + x, 0);
};
```
]

#complexity(time: $O(n)$, space: $O(n)$)

#subsection[Trace on ratings $1, 0, 2$]

#table(columns: (auto, auto, auto, 1fr),
  [*Pass*], [*i*], [*c after*], [*Why*],
  [start], [—],  [1, 1, 1], [everyone gets at least one],
  [L to R], [1], [1, 1, 1], [$0 > 1$? no],
  [L to R], [2], [1, 1, 2], [$2 > 0$? yes, so $c[1] + 1 = 2$],
  [R to L], [1], [1, 1, 2], [$0 > 2$? no],
  [R to L], [0], [2, 1, 2], [$1 > 0$? yes, so $max(1, c[1]+1) = 2$],
)
Total $= 2 + 1 + 2 = 5$.

Runs: $(1,0,2) arrow.r 5$; $(1,2,2) arrow.r 4$; empty $arrow.r 0$;
$(5,5,5,5) arrow.r 4$; $(1,2,3,4,5) arrow.r 15$. All five matched.
]
#ans[5 sweets]

#subsection[Follow-up: $O(1)$ extra space]
Walk once and measure *runs*. Track `up` = the length of the current rising run and
`down` = the length of the current falling run. Each rising run of length $k$ contributes
$1 + 2 + dots + k$; each falling run likewise; the peak between them is counted once, in
whichever run is longer. Keep a running total and reset `up` or `down` at each turn. No
array, one pass, $O(1)$ memory. The two-pass version is easier to get right under
pressure — offer the $O(1)$ version as the follow-up answer, not the first answer.

#trap[
`max` in the second pass, never plain assignment. Ratings $1, 3, 2$: pass 1 gives
$1, 2, 1$. A plain assignment in pass 2 would set $c[1] = c[2] + 1 = 2$, which is right
here — but ratings $1, 5, 4, 3$ give pass 1 $= 1, 2, 1, 1$ and pass 2 must lift $c[1]$ to
3, not drop it. Use `max` and you are safe in both.
]

#ex(27, tier: 3, asked: "Adobe · pattern")[
Event $i$ is open on every day from `start[i]` to `end[i]` inclusive. You may attend at
most one event per day, and attending an event takes exactly one day. Attend the most
events.

*Constraints:* $n <= 10^5$, days up to $10^5$. *Target:* $O(n log n)$.
*Edge cases:* several one-day events on the same day; an empty list.

*Follow-up the interviewer asks next:* "now each event has a value — maximise total value
instead of count."
]
#sol[
Greedy rule: *on each day, attend the open event that expires soonest.* An event with a
late deadline can wait; one expiring today cannot.

A min-heap keyed on `end` gives the soonest-expiring open event in $O(log n)$.

#code(lang: "js", caption: "maxEvents — day sweep plus a min-heap of deadlines")[
```js
const { MinHeap } = require('./toolkit.js');

const maxEvents = (ev) => {
  const a = [...ev].sort((x, y) => x[0] - y[0] || x[1] - y[1]);
  const live = new MinHeap();                  // end days of open events
  const n = a.length;
  let i = 0, got = 0, day = n ? a[0][0] : 0;
  while (i < n || live.size) {
    if (live.size === 0 && i < n) day = Math.max(day, a[i][0]);
    while (i < n && a[i][0] <= day) live.push(a[i++][1]);
    while (live.size && live.peek() < day) live.pop();   // already expired
    if (live.size) { live.pop(); got++; }
    day++;
  }
  return got;
};
```
]

#complexity(time: $O(n log n)$, space: $O(n)$, note: "The jump `day = max(day, ev[i].first)` when the heap is empty keeps the loop from crawling through empty days one at a time.")

#subsection[Trace]

Events $(1,2), (2,3), (3,4), (1,2)$.

#table(columns: (auto, 1fr, auto, auto),
  [*day*], [*Heap (end days)*], [*Attend*], [*Total*],
  [1], [push 2, push 2 $arrow.r$ {2, 2}], [an event ending 2], [1],
  [2], [push 3 $arrow.r$ {2, 3}],          [the other ending 2], [2],
  [3], [push 4 $arrow.r$ {3, 4}],          [the one ending 3],   [3],
  [4], [{4}],                              [the one ending 4],   [4],
)

Runs: $(1,2)(2,3)(3,4) arrow.r$ `3`; the four events above $arrow.r$ `4`;
three copies of $(1,1) arrow.r$ `1`; empty list $arrow.r$ `0`.
]
#ans[4 events]

#subsection[Follow-up: events have values]
The count version is greedy because every event is worth 1. Add values and the greedy
breaks — a cheap event expiring today may be worth skipping for an expensive one
tomorrow. The fix is the *job sequencing with a heap* pattern: process events in order of
deadline, push each value into a *min*-heap, and whenever the heap holds more events than
the days available, pop the smallest value. That is $O(n log n)$ and is the same trick as
Example 16 run in the opposite direction.

#ex(28, tier: 3, asked: "Goldman Sachs · pattern")[
Now every interval carries a *weight*. Pick non-overlapping intervals with the maximum
total weight. First show that "earliest finish time" greedy is wrong, then give the
correct algorithm.

*Constraints:* $n <= 10^5$, weights up to $10^9$; the total reaches $10^14$, still exact in a JS number.
*Target:* $O(n log n)$. *Edge cases:* one interval; all intervals identical.

*Follow-up the interviewer asks next:* "also print which intervals you chose."
]
#sol[

#approach(1, "Earliest-finish greedy", verdict: "WRONG — and knowing why is the point")

#code(lang: "js", caption: "weightedGreedyByEnd — the tempting wrong answer")[
```js
// an interval is { s, e, w }
const weightedGreedyByEnd = (v) => {
  const a = [...v].sort((x, y) => x.e - y.e);
  let got = 0, freeAt = -Infinity;
  for (const j of a) if (j.s >= freeAt) { got += j.w; freeAt = j.e; }
  return got;
};
```
]

Counterexample: $(1,4)$ worth 30, $(2,6)$ worth 90, $(5,8)$ worth 20.
Greedy takes $(1,4)$ then $(5,8)$ for $50$. Taking $(2,6)$ alone gives $90$.
The exchange argument collapses because swapping an interval now changes the *weight*,
not just the finishing time — so "no worse" is no longer guaranteed.

#approach(2, "DP over sorted ends, with binary search for the previous compatible job", verdict: "O(n log n), correct")

Sort by end. Let `dp[i]` be the best total using only the first $i$ intervals. For
interval $i$ you either skip it (`dp[i]`) or take it, in which case you may add the best
answer that finishes at or before `a[i].s`. Binary search finds that index — JavaScript
has no `lower_bound`/`upper_bound`, so use the toolkit's `upperBound` from the *JS
Toolkit* appendix.

#code(lang: "js", caption: "weightedDP — the correct answer")[
```js
const { upperBound } = require('./toolkit.js');

const weightedDP = (v) => {
  const a = [...v].sort((x, y) => x.e - y.e);
  const n = a.length;
  const ends = a.map(j => j.e);
  const dp = new Array(n + 1).fill(0);
  for (let i = 0; i < n; i++) {
    const p = Math.min(upperBound(ends, a[i].s), i);   // jobs finishing at or before s
    dp[i + 1] = Math.max(dp[i], dp[p] + a[i].w);
  }
  return dp[n];
};
```
]

#complexity(time: $O(n log n)$, space: $O(n)$, note: "One sort plus one binary search per interval.")

#subsection[Trace]

Sorted by end: $(1,4,30), (2,6,90), (5,8,20)$. `ends = 4, 6, 8`.

#table(columns: (auto, auto, auto, auto, auto),
  [*i*], [*Interval*], [*p (first end $>$ s)*], [*Take = dp[p] + w*], [*dp[i+1]*],
  [0], [(1,4,30)], [`upperBound(ends, 1)` = 0], [$0 + 30 = 30$], [$max(0,30) = 30$],
  [1], [(2,6,90)], [`upperBound(ends, 2)` = 0], [$0 + 90 = 90$], [$max(30,90) = 90$],
  [2], [(5,8,20)], [`upperBound(ends, 5)` = 1], [$30 + 20 = 50$], [$max(90,50) = 90$],
)

Runs: greedy printed `50`, DP printed `90`. On a case where greedy happens to be right —
$(1,3,5), (3,5,5), (5,7,5)$ — both printed `15`. A randomised cross-check over 400 arrays
of up to 8 intervals against an exhaustive $2^n$ search printed `random check PASS`.
]
#ans[Greedy 50, correct answer 90]

#subsection[Follow-up: print the chosen intervals]
Keep a `from[i+1]` array recording which branch won. Walk backwards from $n$: if
`dp[i+1] == dp[i]` the interval was skipped, so move to $i$; otherwise record interval
$i$ and jump to $p$. Reverse the list at the end. Costs $O(n)$ extra memory and $O(n)$
time, and changes nothing about the forward pass.

#trap[
The toolkit `upperBound` searches the *whole* `ends` array, so the `Math.min(..., i)` is
not decoration — it clamps the result to the already-computed prefix of `dp`. Drop it and
a degenerate zero-length interval can return an index past `i` and read a `dp` entry that
is still `0`, silently giving a wrong answer on some inputs. Slicing the array instead
(`upperBound(ends.slice(0, i), s)`) is also wrong for a different reason: it copies
$O(n)$ elements per step and quietly turns the $O(n log n)$ solution into $O(n^2)$.
]

#ex(29, tier: 3, asked: "D. E. Shaw · pattern")[
Numbers arrive one at a time in an endless stream. After each arrival, be able to report
the current set as a list of merged, disjoint ranges.

*Constraints:* up to $10^6$ arrivals, values up to $10^9$, duplicates allowed.
*Target:* $O(log k)$ per arrival where $k$ is the number of ranges.
*Edge cases:* a number already inside a range; a number that glues two ranges into one.

*Follow-up the interviewer asks next:* "and if the stream is split across ten machines?"
]
#sol[
In C++ or Java you would reach for an ordered map (C++'s `map`, Java's `TreeMap`) keyed on the
range's *start*, and get $O(log k)$ per insert. *JavaScript has neither.* `Map` keeps
insertion order, not sorted order, and has no "give me the next key after $x$" operation.

The standard workaround is a *sorted array plus binary search*, and that is what we do
here: two parallel arrays, `starts` and `ends`, kept sorted, with `upperBound` from the
toolkit locating the insertion point. A new value $x$ then needs only two lookups: the
range starting just after $x$, and the range just before it.

Four cases:

+ $x$ already sits inside the previous range $arrow.r$ do nothing.
+ The previous range ends at $x - 1$ $arrow.r$ extend it left-side, absorb it.
+ The next range starts at $x + 1$ $arrow.r$ absorb it too.
+ Neither $arrow.r$ insert the singleton $[x, x]$.

Cases 2 and 3 can both fire at once, which is exactly how two ranges get glued.

#code(lang: "js", caption: "RangeStream — an ordered map of start -> end")[
```js
const { upperBound } = require('./toolkit.js');

class RangeStream {
  constructor() { this.starts = []; this.ends = []; }   // two parallel sorted arrays
  add(x) {
    const i  = upperBound(this.starts, x);              // first range starting AFTER x
    const lo = i - 1;                                   // the only range that could hold x
    if (lo >= 0 && this.ends[lo] >= x) return;          // already inside
    let s = x, e = x, from = i, drop = 0;
    if (lo >= 0 && this.ends[lo] === x - 1) { s = this.starts[lo]; from = lo; drop = 1; }
    if (i < this.starts.length && this.starts[i] === x + 1) { e = this.ends[i]; drop++; }
    this.starts.splice(from, drop, s);
    this.ends.splice(from, drop, e);
  }
  ranges() { return this.starts.map((s, i) => [s, this.ends[i]]); }
}
```
]

#complexity(time: [$O(log k)$ to locate, $O(k)$ to splice], space: $O(k)$, note: "k is the number of disjoint ranges, never more than the number of distinct values seen. Say the honest cost out loud: the search is logarithmic, the array shift is linear but is a single memmove the engine does very fast.")

#trap[
*JavaScript has no `TreeMap`, no ordered set, and no `map.upperBound`.* Say this before
you write code, then name the two workarounds: (1) a sorted array plus binary search —
$O(log k)$ search, $O(k)$ insert, which is what almost every interview accepts; (2) a
hand-written balanced BST or skip list if the interviewer insists on a true $O(log k)$
insert. Pretending `Map` is ordered is the answer that loses the round.
]

#subsection[Trace]

Adding $1, 3, 7, 2, 6$:

#table(columns: (auto, 1fr, auto),
  [*Add*], [*Case*], [*Ranges after*],
  [1], [nothing near it], [`[1,1]`],
  [3], [nothing near it], [`[1,1] [3,3]`],
  [7], [nothing near it], [`[1,1] [3,3] [7,7]`],
  [2], [previous ends at 1 *and* next starts at 3 — glue both], [`[1,3] [7,7]`],
  [6], [next starts at 7], [`[1,3] [6,7]`],
)

Run output after those five: `[[1,3],[6,7]]`. Then adding 3 (already inside) and 5:
`[[1,3],[5,7]]`. An empty stream reports `[]`, and adding 10, 10, $-1$ gives
`[[-1,-1],[10,10]]`. A cross-check drove $10^5$ random adds through both this class and a
plain `Set`, then expanded the ranges back out: `oracle match: true`.
]
#ans[`[1,3] [6,7]`, and `[1,3] [5,7]` after the two extra adds]

#subsection[Follow-up: ten machines]
Range sets *merge*. Each machine keeps its own map. To combine, pour all ranges into one
list, sort by start and run Template A — the merge of two disjoint range sets is a normal
interval merge. Because merging is associative and order-independent, the machines can
combine in a tree rather than one by one, which is what makes this pattern fit a
map-reduce job. Each machine's local map is a *partial* answer, never a wrong one.

#section[Dry run — one problem, every single step]

We trace `minBoats` (Example 19) completely: every variable, after every line, with the
weights $7, 2, 3, 6, 4, 1$ and `limit = 8`.

*Step 0 — sort.* `w` becomes $1, 2, 3, 4, 6, 7$. Indices $0 dots 5$.

*Step 1 — set up.* `i = 0`, `j = 5`, `boats = 0`.

Now the loop. Read each row as "state *before* the turn, then what the turn does".

#table(columns: (auto, auto, auto, auto, auto, auto, 1fr),
  [*Turn*], [*i*], [*j*], [*w[i]*], [*w[j]*], [*Sum vs 8*], [*Action, then new state*],
  [1], [0], [5], [1], [7], [$8 <= 8$ fits],   [both ride. `i` $arrow.r$ 1, `j` $arrow.r$ 4, `boats` $arrow.r$ 1],
  [2], [1], [4], [2], [6], [$8 <= 8$ fits],   [both ride. `i` $arrow.r$ 2, `j` $arrow.r$ 3, `boats` $arrow.r$ 2],
  [3], [2], [3], [3], [4], [$7 <= 8$ fits],   [both ride. `i` $arrow.r$ 3, `j` $arrow.r$ 2, `boats` $arrow.r$ 3],
  [4], [3], [2], [—], [—], [—],               [`i > j`, loop ends],
)

Answer: 3 trips. Passengers are $(1,7)$, $(2,6)$, $(3,4)$.

#subsection[The same trace when the pairing fails]

Weights $3, 5, 3, 4$, `limit = 5`. Sorted: $3, 3, 4, 5$. `i = 0`, `j = 3`, `boats = 0`.

#table(columns: (auto, auto, auto, auto, auto, auto, 1fr),
  [*Turn*], [*i*], [*j*], [*w[i]*], [*w[j]*], [*Sum vs 5*], [*Action, then new state*],
  [1], [0], [3], [3], [5], [$8 > 5$ no], [5 rides alone. `i` stays 0, `j` $arrow.r$ 2, `boats` $arrow.r$ 1],
  [2], [0], [2], [3], [4], [$7 > 5$ no], [4 rides alone. `i` stays 0, `j` $arrow.r$ 1, `boats` $arrow.r$ 2],
  [3], [0], [1], [3], [3], [$6 > 5$ no], [one 3 rides alone. `i` stays 0, `j` $arrow.r$ 0, `boats` $arrow.r$ 3],
  [4], [0], [0], [3], [3], [$6 > 5$ no], [`i == j`, the last person rides alone. `j` $arrow.r$ $-1$, `boats` $arrow.r$ 4],
  [5], [0], [$-1$], [—], [—], [—], [`i > j`, loop ends],
)

Answer: 4 trips. Both traces matched what `node` printed, exactly.

#note[
Look carefully at turn 4 of the second trace. `i` and `j` point at the *same person*.
The condition `i <= j` lets the turn happen, the pair sum test fails (a person cannot
ride with themselves anyway), `j` drops below `i`, and the trip is counted. That single
`=` is the whole reason the answer is 4 and not 3.
]

#section[Practice]

#practice(tier: 1, time: "12 min")[
+ Given $2n$ numbers, split them into $n$ pairs so the *largest* pair sum is as small as
  possible. Return that largest pair sum. Test with ${3,5,2,3}$.
+ Can one person attend every meeting in a list? Return true or false.
+ A van has `slots` box positions. Each box type has a count and a "units per box" value.
  Load the most units. Test with types $(1, 3), (2, 2), (3, 1)$ and `slots = 4`.
+ Two *already sorted, already disjoint* interval lists. Return their intersection.
+ Notes of 5, 10 and 20 arrive at a counter selling a 5-rupee item. Each customer pays
  with one note and you must give correct change from notes you already have. Can you
  serve everybody?
]

#key[
*1.* Sort, then pair the smallest with the largest, second smallest with second
largest, and so on. Any other pairing puts two large numbers together, which can only
raise the maximum.

#code(lang: "js", caption: "minMaxPairSum")[
```js
const minMaxPairSum = (a) => {
  const v = [...a].sort((x, y) => x - y);
  let i = 0, j = v.length - 1, best = -Infinity;
  while (i < j) { best = Math.max(best, v[i] + v[j]); i++; j--; }
  return v.length === 0 ? 0 : best;
};
```
]
Run: `[3,5,2,3]` sorts to $2,3,3,5$; pairs $(2,5) = 7$ and $(3,3) = 6$; output `7`.
`[1,1]` gives `2`, `[]` gives `0`, and `[-5,-1,0,4]` gives `-1` — which is why `best`
starts at `-Infinity` and not at `0`. #complexity(time: $O(n log n)$, space: [$O(1)$ extra])

*2.* Sort by start and look for one clash.
#code(lang: "js", caption: "noClash")[
```js
const noClash = (v) => {
  const a = [...v].sort((x, y) => x[0] - y[0] || x[1] - y[1]);
  for (let i = 1; i < a.length; i++)
    if (a[i][0] < a[i-1][1]) return false;
  return true;
};
```
]
Run: $(0,30),(5,10) arrow.r$ `false`; $(7,10),(2,4) arrow.r$ `true`; empty $arrow.r$ `true`; $(1,5),(5,9) arrow.r$ `true`.

*3.* Sort box types by units-per-box, descending, and fill.
#code(lang: "js", caption: "maxUnits")[
```js
const maxUnits = (box, slots) => {                 // box = [count, unitsPerBox]
  const a = [...box].sort((x, y) => y[1] - x[1]);
  let got = 0;
  for (const [cnt, u] of a) {
    const take = Math.min(cnt, slots);
    got += take * u; slots -= take;
    if (slots === 0) break;
  }
  return got;
};
```
]
Run: 1 box of 3 units, then 2 boxes of 2 units, then 1 box of 1 unit
$= 3 + 4 + 1 = 8$. Output `8`. With `slots = 0` the output is `0`.

*4.* Two pointers. Intersect the two fronts; then *drop whichever ends first*, because
it can never reach any later interval of the other list.
#code(lang: "js", caption: "intersect")[
```js
const intersect = (A, B) => {
  const out = [];
  let i = 0, j = 0;
  while (i < A.length && j < B.length) {
    const lo = Math.max(A[i][0], B[j][0]), hi = Math.min(A[i][1], B[j][1]);
    if (lo <= hi) out.push([lo, hi]);
    if (A[i][1] < B[j][1]) i++; else j++;
  }
  return out;
};
```
]
Run on `[0,2] [5,10] [13,23]` and `[1,5] [8,12] [15,24]`: output
`[1,2][5,5][8,10][15,23]`. With an empty first list: nothing.

*5.* Hoard the small notes. A 20 should be changed with $10 + 5$ when possible, because
three 5s are more flexible than one 10 plus one 5.
#code(lang: "js", caption: "canServe")[
```js
const canServe = (pay) => {
  let five = 0, ten = 0;
  for (const p of pay) {
    if (p === 5) five++;
    else if (p === 10) { if (!five) return false; five--; ten++; }
    else {
      if (ten && five) { ten--; five--; }
      else if (five >= 3) five -= 3;
      else return false;
    }
  }
  return true;
};
```
]
Run: $5,5,5,10,20 arrow.r$ `true`; $5,5,10,10,20 arrow.r$ `false`; a lone $10 arrow.r$ `false`; empty $arrow.r$ `true`.
]

#practice(tier: 2, time: "15 min")[
6. Delete exactly $k$ digits from a digit string so the remaining number is the smallest
   possible. Keep the digit order. Strip leading zeros. Test `"1432219"` with $k = 3$.
7. Share prices day by day. You may buy and sell as many times as you like, but you may
   hold at most one share. Find the maximum total profit.
8. $2n$ candidates, each with a cost to fly to city A and a cost to fly to city B. Send
   exactly $n$ to each city at the least total cost.
9. Rearrange a lowercase string so no two identical letters sit next to each other, or
   report that it is impossible.
10. Given an array, make it *strictly increasing* using the fewest total $+1$ increments.
   Return the number of increments.
]

#key[
*6.* Walk left to right keeping a stack. A digit that is *smaller* than the top of the
stack makes the number smaller if we drop that top — so pop while we still have deletions
left. This is a monotonic-stack greedy.
#code(lang: "js", caption: "dropK")[
```js
const dropK = (s, k) => {
  const st = [];
  for (const c of s) {
    while (st.length && k > 0 && st[st.length - 1] > c) { st.pop(); k--; }
    st.push(c);
  }
  while (k-- > 0 && st.length) st.pop();
  let p = 0;
  while (p + 1 < st.length && st[p] === '0') p++;
  const out = st.slice(p).join('');
  return out === '' ? '0' : out;
};
```
]
Run: `dropK("1432219",3)` $arrow.r$ `1219`; `dropK("10200",1)` $arrow.r$ `200`;
`dropK("10",2)` $arrow.r$ `0`. The trailing `while` matters for an already-increasing
string like `"12345"`, where nothing is ever popped inside the loop.
#complexity(time: $O(n)$, space: $O(n)$)

*7.* Collect every rise. If tomorrow is dearer than today, buy today and sell tomorrow;
chains of rises add up to the same profit as one long hold, so this is never worse.
#code(lang: "js", caption: "stockProfit")[
```js
const stockProfit = (p) => {
  let got = 0;
  for (let i = 1; i < p.length; i++)
    if (p[i] > p[i-1]) got += p[i] - p[i-1];
  return got;
};
```
]
Run: $7,1,5,3,6,4 arrow.r$ `7`; a falling series $9,8,7 arrow.r$ `0`; one day $arrow.r$ `0`.

*8.* Sort by (cost to A $-$ cost to B). The most negative differences are the people who
are relatively cheapest in A, so send the first half to A and the rest to B.
#code(lang: "js", caption: "twoCity")[
```js
const twoCity = (c) => {
  const a = [...c].sort((x, y) => (x[0] - x[1]) - (y[0] - y[1]));
  const n = a.length / 2;
  return a.reduce((tot, [ca, cb], i) => tot + (i < n ? ca : cb), 0);
};
```
]
Run with $(10,20), (30,200), (400,50), (30,20)$: differences are $-10, -170, 350, 10$.
Sorted order is $(30,200), (10,20), (30,20), (400,50)$. First two fly to A for $30+10=40$,
last two fly to B for $20+50=70$. Output `110`.

*9.* Always place the letter with the most copies left, but never the one you just
placed. Hold the last-used letter aside for one turn, then push it back. JavaScript has no
max-heap either — the toolkit `MinHeap` with a flipped comparator *is* one.
#code(lang: "js", caption: "spreadOut")[
```js
const { MinHeap } = require('./toolkit.js');

const spreadOut = (s) => {
  const cnt = new Map();
  for (const ch of s) cnt.set(ch, (cnt.get(ch) ?? 0) + 1);
  // no max-heap either: a MinHeap with a flipped comparator IS the max-heap
  const pq = new MinHeap((a, b) => b[0] - a[0] || (a[1] < b[1] ? -1 : 1));
  for (const [ch, c] of cnt) pq.push([c, ch]);
  const out = [];
  let hold = null;
  while (pq.size) {
    const [c, ch] = pq.pop();
    out.push(ch);
    if (hold && hold[0] > 0) pq.push(hold);
    hold = [c - 1, ch];
  }
  return out.length === s.length ? out.join('') : '';
};
```
]
Run: `"aab"` $arrow.r$ `aba`; `"aaab"` $arrow.r$ the empty string (impossible, because one
letter has more than half the copies); `"a"` $arrow.r$ `a`; `"aaabbbccc"` $arrow.r$
`abcabcabc`, and a neighbour check on that output confirmed no two equal letters touch.

*10.* One pass. If an element is not already larger than its left neighbour, raise it to
exactly `left + 1` — never higher, because a higher value only makes the next element
more expensive.
#code(lang: "js", caption: "makeIncreasing")[
```js
const makeIncreasing = (a) => {
  const v = [...a];
  let cost = 0;
  for (let i = 1; i < v.length; i++)
    if (v[i] <= v[i-1]) { cost += v[i-1] + 1 - v[i]; v[i] = v[i-1] + 1; }
  return cost;
};
```
]
Run: $1,1,1 arrow.r$ `3` (raise to $1,2,3$); $3,2,1 arrow.r$ `6` (raise to $3,4,5$);
$1,5,9 arrow.r$ `0`.
]

#practice(tier: 3, time: "18 min")[
11. Split items into the fewest groups such that no group contains the same item twice.
   Prove your answer is a lower bound as well as achievable.
12. You are given $n$ intervals. Answer $q$ queries of the form "how many intervals cover
   point $x$?" Preprocess once, then answer each query fast.
13. Explain, with a 3-interval counterexample, why sorting by *start* time breaks
   "pick the most non-overlapping intervals".
14. Given intervals and an integer $k$, find the smallest number of points such that every
   interval contains at least $k$ of the chosen points. Solve it for $k = 1$ and describe
   the change for general $k$.
15. You run `mergeSorted` on a list that is *already sorted by end time* instead of start
   time. Give an input where the output is wrong, and say exactly which line breaks.
]

#key[
*11.* The answer is the largest frequency. *Lower bound:* if some item appears $f$ times,
those $f$ copies must sit in $f$ different groups, so at least $f$ groups are needed.
*Achievable:* number the copies of each item $0, 1, 2, dots$ and put copy number $t$ into
group $t$. No group ever receives two copies of the same item.
#code(lang: "js", caption: "fewestGroups")[
```js
const fewestGroups = (a) => {
  const f = new Map();                 // Map, not {} -- keys keep their number type
  let best = 0;
  for (const x of a) {
    f.set(x, (f.get(x) ?? 0) + 1);
    best = Math.max(best, f.get(x));
  }
  return best;
};
```
]
Run: `[4,4,4,2,2,7]` $arrow.r$ `3`; `[1,2,3]` $arrow.r$ `1`; `[]` $arrow.r$ `0`; `[-1,-1]` $arrow.r$ `2` — a `Map` keeps $-1$ as the *number* $-1$, where a plain object would stringify it to `"-1"`.
#complexity(time: $O(n)$, space: $O(n)$)

*12.* Difference array plus prefix sums. For every interval $[s,e]$ do `d[s] += 1` and
`d[e+1] -= 1`. The prefix sum of `d` at position $x$ is the number of intervals covering
$x$. Preprocessing is $O(n + M)$ where $M$ is the coordinate range; each query is $O(1)$.
If coordinates are up to $10^9$, first compress them: collect all endpoints, sort, remove
duplicates, and index into that list — then $M$ becomes $2n$ and a query is a binary
search, $O(log n)$.

*13.* Intervals $(0, 100), (1, 2), (3, 4)$. Sorted by start, greedy takes $(0,100)$ and
then nothing fits: answer 1. Sorted by end, greedy takes $(1,2)$ and $(3,4)$: answer 2.
Starting early tells you nothing about when the room frees up; only the finish time does.

*14.* For $k = 1$: sort by end and sweep. Keep `last = -infinity`. For each interval, if
its start is greater than `last`, place a point at its *end* and set `last` to that end.
Placing the point at the end is the greedy move — it is the position that can also serve
the largest number of future intervals. For general $k$: sort by end, and for each
interval count how many already-placed points lie inside it; if that count is $c < k$,
add the $k - c$ largest unused positions inside the interval, starting from its right
end and walking left. The "place as far right as legally possible" rule is unchanged;
only the number of points per step changes.

*15.* Input $(1, 10), (2, 3), (4, 5)$ is sorted by end as $(2,3), (4,5), (1,10)$.
`mergeSorted` walks it and produces `[2,3] [4,5] [1,10]` — not merged and not even
sorted. The line that breaks is
`if (v[i][0] <= last[1])`. Its correctness rests on the guarantee that every
later interval starts at or after the current one, which only start-order provides. With
end-order, $(1,10)$ arrives last and reaches backwards over both earlier blocks, and
the single open block cannot represent that.
]

#revision[

*The four JavaScript facts this chapter depends on.*

#table(columns: (auto, 1fr),
  [`arr.sort()`],      [lexicographic. Always `arr.sort((a, b) => a - b)`, and the comparator returns a *number*.],
  [no heap],           [`MinHeap` from the *JS Toolkit* appendix; flip the comparator for a max-heap.],
  [no `TreeMap`],      [sorted array + `upperBound`, or a hand-rolled balanced tree. `Map` is insertion-ordered, not sorted.],
  [numbers are doubles],[exact to $2^53 - 1 approx 9 times 10^15$. Everything in this chapter fits; past it, `BigInt`.],
)

*Two templates, memorised.*

#table(columns: (auto, 1fr),
  [*Sort by START*], [merge / union / insert / free-gaps. Keep one open block; stretch its end with `max`, or push it and open a new one.],
  [*Sort by END*],   [count the most non-overlapping / minimum deletions / minimum arrows. Keep `freeAt`; take an interval only when `s >= freeAt`.],
  [*Sweep (split events)*], [minimum rooms / maximum overlap. Sort starts and ends separately, walk with two pointers, `+1` on a start, `-1` on an end.],
  [*Heap*], [when you must know *which* resource freed up (room assignment), or repeatedly need the current smallest/largest (ropes, events, reorganise string).],
)

*Sort key cheat sheet.*

#table(columns: (1fr, auto, auto),
  [*Problem shape*], [*Sort key*], [*Cost*],
  [merge / union of intervals],        [start ascending],          [$O(n log n)$],
  [most non-overlapping],              [end ascending],            [$O(n log n)$],
  [minimum rooms],                     [starts and ends separately],[$O(n log n)$],
  [fractional knapsack],               [value/weight descending],  [$O(n log n)$],
  [job + deadline + profit],           [profit descending + DSU],  [$O(n log n)$],
  [pair two lists],                    [both ascending],           [$O(n log n)$],
  [lift / boat with 2 seats],          [ascending, two pointers],  [$O(n log n)$],
  [biggest joined number],             [`a+b > b+a` on strings],   [$O(n L log n)$],
  [cheapest rope joins],               [min-heap],                 [$O(n log n)$],
  [reach the end (jump)],              [none — carry `reach`],     [$O(n)$],
  [circular fuel],                     [none — carry `tank`],      [$O(n)$],
  [cut string by last letter position],[none — carry `reach`],     [$O(n)$],
)

*When greedy is NOT allowed.*

#table(columns: (1fr, 1fr),
  [*Looks greedy but is not*], [*Use instead*],
  [coin change, non-canonical coins],   [DP over amount, $O(A dot C)$],
  [intervals with weights],             [DP sorted by end + binary search, $O(n log n)$],
  [0/1 knapsack (no cutting)],          [DP over capacity, $O(n W)$],
  [maximise the *value* of events attended], [deadline order + min-heap of values],
)

*The five traps that cost marks.*

+ *Touch is not overlap.* Decide `<` versus `<=` before writing code, and write it down.
+ *`Math.max` when stretching a block.* `last[1] = Math.max(last[1], e)`, never plain
  assignment.
+ *Never a bare `.sort()`.* It is lexicographic. Numbers need `(a, b) => a - b`, and a
  comparator must return a *number*, never a boolean.
+ *`[...v]` is shallow.* Intervals are arrays; copy each row with `v.map(iv => [...iv])`
  before mutating.
+ *`i <= j` in two-pointer pairing.* The last lone element still needs its own group.

*The exchange argument in one sentence.*
Take any optimal answer, find the first place it differs from greedy, swap in greedy's
choice, show the answer stays valid and no worse — repeat until optimal *is* greedy.

*Thirty-second pre-flight check before you code any greedy.*
Try to break your rule with a 3-element input. If you cannot break it in 30 seconds,
write the code. If you can, you just found the reason the problem is really DP.
]

]
