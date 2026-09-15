#import "../../shared/lib/style.typ": *

#chapter(num: 17, title: "Dynamic Programming I — 1D & Knapsack",
  tagline: "Recursion that refuses to repeat itself")[

#section[Pattern in one page]

Dynamic programming (DP) is one idea: *solve a big problem by re-using answers to smaller
versions of the same problem.* Nothing more.

You already use it. To find the 10th Fibonacci number you do not re-count from zero every
time. You keep the last two answers and add. That is DP.

#formulas(title: "The three questions")[
Before you write one line of code, answer these.

+ *State* — what is the smallest set of numbers that describes "where I am"?
  Write it as `dp[...]` and say in words what it means.
+ *Transition* — how do I build `dp[i]` from smaller states?
+ *Base case* — which states do I know without computing?

If you cannot say the state in one English sentence, you do not have a DP yet.
]

#subsection[The five-step recipe]

#formulas(title: "Recipe — use it every single time")[
+ Write the *brute-force recursion*. Do not optimise. Just: "at each step I choose X or Y".
+ Find the *changing arguments* of that recursion. They are your state.
+ Add a *memo* array indexed by those arguments. Now it is top-down DP.
+ Turn the memo into a *loop* (bottom-up table). The loop order must go from base cases
  outward.
+ Look at which rows the loop reads. If it only reads the previous row, *drop the rest of
  the table* and keep O(1) or O(W) space.
]

#note[Steps 1→2→3 are mechanical. You never need cleverness there. Cleverness only
appears in step 1 (choosing the recursion) and step 5 (shrinking memory).]

#subsection[Two DP problems are two different animals]

#table(columns: (auto, 1fr, 1fr),
  [], [*Optimisation DP*], [*Counting DP*],
  [Asks], [max / min / "is it possible"], [how many ways],
  [Combiner], [`Math.max`, `Math.min`, `||`], [`+`],
  [Base], [`dp[0] = 0` or `false`], [`dp[0] = 1` (the empty way)],
  [Precision], [rare problem], [common — watch $2^53$],
  [Order of loops], [usually does not matter], [*often changes the answer*],
)

#trap[The most common counting bug in placement tests: `dp[0] = 0` instead of `dp[0] = 1`.
There is exactly *one* way to make the amount 0 — take nothing. If you set it to 0 every
answer becomes 0.]

#subsection[Overlapping subproblems — the picture]

Plain recursion for "ways to climb $n$ stairs with steps of 1 or 2" re-computes the same
call many times.

#diagram(height: 4.4cm, caption: "f(3) is computed twice, f(2) three times. A memo computes each node once.")[
#dnode(4.2cm, 0cm, 1.6cm, 0.7cm, "f(5)")
#dnode(1.8cm, 1.2cm, 1.6cm, 0.7cm, "f(4)")
#dnode(6.6cm, 1.2cm, 1.6cm, 0.7cm, "f(3)")
#dnode(0.2cm, 2.4cm, 1.6cm, 0.7cm, "f(3)")
#dnode(3.0cm, 2.4cm, 1.6cm, 0.7cm, "f(2)")
#dnode(5.6cm, 2.4cm, 1.6cm, 0.7cm, "f(2)")
#dnode(8.2cm, 2.4cm, 1.6cm, 0.7cm, "f(1)")
#dnode(1.2cm, 3.6cm, 1.6cm, 0.7cm, "f(2)")
#dnode(3.6cm, 3.6cm, 1.6cm, 0.7cm, "f(1)")
#darrow(4.6cm, 0.7cm, 2.9cm, 1.2cm)
#darrow(5.4cm, 0.7cm, 7.2cm, 1.2cm)
#darrow(2.2cm, 1.9cm, 1.1cm, 2.4cm)
#darrow(2.9cm, 1.9cm, 3.6cm, 2.4cm)
#darrow(7.0cm, 1.9cm, 6.3cm, 2.4cm)
#darrow(7.5cm, 1.9cm, 8.8cm, 2.4cm)
#darrow(0.7cm, 3.1cm, 1.7cm, 3.6cm)
#darrow(1.3cm, 3.1cm, 4.1cm, 3.6cm)
]

Number of distinct nodes: about $n$. Number of calls without a memo: about $2^n$.
That single gap is the whole chapter.

#subsection[Template 1 — top-down (memo)]

#code(lang: "javascript", caption: "Top-down skeleton — write this first when you are stuck")[
```javascript
function solve(n) {
  const memo = new Array(n + 1).fill(-1);
  const go = (i) => {
    if (i < 0)  return 0;          // base: impossible
    if (i === 0) return 1;         // base: known answer
    if (memo[i] !== -1) return memo[i];
    return memo[i] = go(i - 1) + go(i - 2);
  };
  return go(n);
}
```
]

#trap[*JavaScript recursion depth is roughly $10^4$ frames*, far below C++ or Java. A
top-down DP over $n = 10^5$ will throw `RangeError: Maximum call stack size exceeded`.
Two fixes: (a) convert to a bottom-up loop — always possible for a 1D DP; (b) run the
recursion with an explicit stack. Prefer (a). Write top-down to *find* the recurrence,
then ship the loop.]

#subsection[Template 2 — bottom-up (table)]

#code(lang: "javascript", caption: "Bottom-up skeleton — same recurrence, written as a loop")[
```javascript
function solve(n) {
  const dp = new Array(n + 1).fill(0);
  dp[0] = 1;
  for (let i = 1; i <= n; i++) {
    dp[i] = dp[i - 1];
    if (i >= 2) dp[i] += dp[i - 2];
  }
  return dp[n];
}
```
]

#trap[`new Array(n)` makes an array of *holes*, not zeros. `new Array(3).map(x => 1)`
returns `[null, null, null]` — `map` skips holes. Always write
`new Array(n).fill(0)`. And for a 2D table, `new Array(3).fill(new Array(4).fill(0))`
stores *the same row three times*: setting `bad[0][1] = 9` gives
`[[0,9,0,0],[0,9,0,0],[0,9,0,0]]`. The correct form is
`Array.from({ length: 3 }, () => new Array(4).fill(0))`, which gives
`[[0,9,0,0],[0,0,0,0],[0,0,0,0]]`.]

#subsection[Template 3 — 0/1 knapsack in one row]

This is the single most tested DP shape in placement papers. Memorise the two-line core.

#code(lang: "javascript", caption: "0/1 knapsack, one row, capacity loop BACKWARDS")[
```javascript
const dp = new Array(cap + 1).fill(0);
for (let i = 0; i < w.length; i++)
  for (let c = cap; c >= w[i]; c--)
    dp[c] = Math.max(dp[c], v[i] + dp[c - w[i]]);
return dp[cap];
```
]

#trick[*Backwards = each item used at most once (0/1).*
*Forwards = each item used any number of times (unbounded).*
That one word — the direction of the inner loop — is the whole difference. Write it on
your rough sheet before you start.]

#subsection[Use `Infinity`, not a big number]

C++ programmers write `INT_MAX / 2` as a sentinel because `INT_MAX + 1` overflows.
JavaScript has a real infinity and it behaves correctly under addition.

#code(lang: "javascript", caption: "Sentinels in JS")[
```javascript
const dp = new Array(n + 1).fill(Infinity);
dp[0] = 0;
// Infinity + 1 === Infinity   -> no overflow, no wrap-around
// Infinity > 5                -> true
return dp[n] === Infinity ? -1 : dp[n];
```
]

Verified in Node: `Infinity + 1` prints `Infinity`, and `Infinity > 5` prints `true`.
Use `-Infinity` for maximisation problems.

#subsection[When to reach for 1D DP]

#table(columns: (1fr, 1.3fr),
  [*The question says...*], [*Reach for*],
  [count the ways to reach step $n$], [`dp[i] = dp[i-1] + dp[i-2] + ...`],
  [minimum cost to reach the end], [`dp[i] = min over previous j`],
  [pick items, no two neighbours], [take / skip pair of variables],
  [fill a bag of capacity $W$ exactly once each], [0/1 knapsack, loop backwards],
  [unlimited copies of each item], [unbounded knapsack, loop forwards],
  [split the array into two equal halves], [subset sum on `total/2`],
  [longest increasing / chain], [LIS, $O(n^2)$ then $O(n log n)$],
)

#subsection[The complexity rule for DP]

#formulas(title: "Cost of a DP")[
$ "time" = ("number of states") times ("work per state") $
$ "space" = ("number of states you must keep alive") $
]

For 0/1 knapsack: states $= n times W$, work per state $= O(1)$, so time $= O(n W)$.
With $n <= 100$ and $W <= 10^4$ that is $10^6$ operations — fast. With $W <= 10^9$ it is
hopeless, and that is your hint to index the table by *value* instead (Example 27).

#subsection[The number trap you must know before you start]

#trap[*JavaScript numbers are doubles. Integers are exact only up to*
`Number.MAX_SAFE_INTEGER` $= 2^53 - 1 = 9007199254740991$.

Counting DPs cross that line fast. For the staircase count of Example 1:

`climbWays(45) = 1836311903` — exact.
`climbWays(77) = 8944394323791464` — exact, just under the limit.
`climbWays(79) = 23416728348467684` — *wrong*. The true value is `23416728348467685`.

Products bite even harder: `123456789 * 987654321` prints `121932631112635260`, but the
true product is `121932631112635269`.

Two fixes: take the answer *modulo* $10^9+7$ (what the question usually asks for), or
switch to `BigInt` — `123456789n * 987654321n` gives the exact `121932631112635269n`.]

#pagebreak(weak: true)

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
A staircase has $n$ steps. You climb 1 or 2 steps at a time. How many different ways can
you reach the top? Constraints: $0 <= n <= 77$ for an exact answer. Target: $O(n)$ time,
$O(1)$ space. Edge cases: $n = 0$ (one way — stand still), $n = 79$ (the answer is no
longer exact in a JS number).

#sol[
State: `ways[i]` = number of ways to stand on step `i`.

To stand on step `i` your last move came from `i-1` or from `i-2`. So
$ "ways"[i] = "ways"[i-1] + "ways"[i-2] $

Base: `ways[0] = 1` (do nothing), `ways[1] = 1` (one single step).

Only two old values are ever needed, so keep two variables.

#code(lang: "javascript", caption: "climbWays — O(1) space")[
```javascript
function climbWays(n) {
  if (n <= 1) return 1;
  let twoBack = 1, oneBack = 1;      // ways(0), ways(1)
  for (let i = 2; i <= n; i++) {
    const cur = oneBack + twoBack;
    twoBack = oneBack;
    oneBack = cur;
  }
  return oneBack;
}
```
]

Run for $n = 0 .. 10$:

```
1 1 2 3 5 8 13 21 34 55 89
```

and `climbWays(45) = 1836311903`, `climbWays(77) = 8944394323791464`.

#complexity(time: $O(n)$, space: $O(1)$, note: "exact up to n = 77; beyond that use BigInt or a modulus")

#ans[The Fibonacci numbers, shifted by one.]
]
]

#ex(2, tier: 0, asked: "warm-up")[
`cost[i]` is the fee to *step on* stair `i`. You start on the ground, may begin at stair 0
or stair 1, and from stair `i` you move to `i+1` or `i+2`. Find the cheapest way to get
past the top. Constraints: $0 <= n <= 10^5$, $0 <= "cost"[i] <= 1000$.
Edge cases: empty array, single stair.

#sol[
State: `dp[i]` = cheapest total fee to *arrive at and pay for* stair `i`.

$ "dp"[i] = "cost"[i] + min("dp"[i-1], "dp"[i-2]) $

Base: `dp[0] = cost[0]`, `dp[1] = cost[1]` (you may start at either).

The top is one step past the last stair, so the answer is `min(dp[n-1], dp[n-2])`.

#code(lang: "javascript", caption: "minCostStairs")[
```javascript
function minCostStairs(cost) {
  const n = cost.length;
  if (n === 0) return 0;
  if (n === 1) return cost[0];
  let prev2 = cost[0], prev1 = cost[1];
  for (let i = 2; i < n; i++) {
    const cur = cost[i] + Math.min(prev1, prev2);
    prev2 = prev1;
    prev1 = cur;
  }
  return Math.min(prev1, prev2);
}
```
]

Tested outputs:

#table(columns: (1.9fr, 0.6fr),
  [*input*], [*output*],
  [`[10, 15, 20]`], [15],
  [`[1,100,1,1,1,100,1,1,100,1]`], [6],
  [`[]` (empty)], [0],
  [`[7]`], [7],
  [`[5, 3]`], [3],
)

#complexity(time: $O(n)$, space: $O(1)$)

#ans[`[10,15,20]` → 15 (start at stair 1, pay 15, then jump over the top).]
]
]

#ex(3, tier: 0, asked: "warm-up")[
Pick numbers from an array so that no two picked numbers sit next to each other. Maximise
the sum. Constraints: $0 <= n <= 10^5$, values may be negative.
Edge cases: empty array, all negative.

#sol[
Two running answers are enough.

- `take` = best sum where the *last element was taken*
- `skip` = best sum where the *last element was skipped*

Moving to the next element `x`:
$ "take"' = "skip" + x, quad "skip"' = max("skip", "take") $

#code(lang: "javascript", caption: "maxNonAdjacent")[
```javascript
function maxNonAdjacent(a) {
  let take = 0, skip = 0;            // best if a[i-1] was taken / skipped
  for (const x of a) {
    const newTake = skip + x;
    const newSkip = Math.max(skip, take);
    take = newTake;
    skip = newSkip;
  }
  return Math.max(take, skip);
}
```
]

Outputs: `[3,2,7,10]` → 13 (3 + 10); `[5]` → 5; `[]` → 0;
`[-4,-1,-9]` → 0; `[2000000000, 1, 2000000000]` → 4000000000.

#complexity(time: $O(n)$, space: $O(1)$)

#ans[13 for `[3,2,7,10]`.]
]
]

#trap[`[-4,-1,-9]` gives *0*, not $-1$, because "pick nothing" is a legal empty choice.
If the question says *at least one element must be picked*, start with
`take = a[0], skip = -Infinity` instead. Always ask the interviewer which one they want.]

#ex(4, tier: 0, asked: "warm-up")[
Same staircase, but steps of 1, 2 or 3. Count the ways. $0 <= n <= 60$.
Edge cases: $n = 0$; $n = 2$ (only 2 ways, not 4).

#sol[
$ "dp"[i] = "dp"[i-1] + "dp"[i-2] + "dp"[i-3] $
Base: `dp[0] = 1, dp[1] = 1, dp[2] = 2`.

#code(lang: "javascript", caption: "waysSteps123")[
```javascript
function waysSteps123(n) {
  const dp = new Array(Math.max(n + 1, 3)).fill(0);
  dp[0] = 1; dp[1] = 1; dp[2] = 2;
  for (let i = 3; i <= n; i++) dp[i] = dp[i-1] + dp[i-2] + dp[i-3];
  return dp[n];
}
```
]

Output for $n = 0 .. 8$:

```
1 1 2 4 7 13 24 44 81
```

and `waysSteps123(30) = 53798080`.

#complexity(time: $O(n)$, space: $O(n)$, note: "shrink to 3 variables for O(1) space")

#ans[These are the Tribonacci numbers.]
]
]

#note[Why `Math.max(n + 1, 3)` in the array size? If a tester calls with $n = 0$, an array
of length 1 would leave `dp[2] = 2` writing past the end and silently growing the array.
Sizing it to at least 3 removes that whole class of bug.]

#ex(5, tier: 0, asked: "warm-up")[
A frog is on stone 0 of `n` stones with heights `h[]`. From stone `i` it hops to `i+1` or
`i+2`. A hop from `i` to `j` costs $|h[i] - h[j]|$. Find the minimum total cost to reach
the last stone. $1 <= n <= 10^5$. Edge cases: $n = 1$ (cost 0), all heights equal.

#sol[
State: `dp[i]` = cheapest cost to *stand on* stone `i`.

$ "dp"[i] = min("dp"[i-1] + |h[i] - h[i-1]|, quad "dp"[i-2] + |h[i] - h[i-2]|) $

#code(lang: "javascript", caption: "frogMinCost")[
```javascript
function frogMinCost(h) {
  const n = h.length;
  if (n <= 1) return 0;
  let prev2 = 0, prev1 = Math.abs(h[1] - h[0]);
  for (let i = 2; i < n; i++) {
    const one = prev1 + Math.abs(h[i] - h[i-1]);
    const two = prev2 + Math.abs(h[i] - h[i-2]);
    prev2 = prev1;
    prev1 = Math.min(one, two);
  }
  return prev1;
}
```
]

Outputs: `[10,30,40,20]` → 30; `[30,10,60,10,60,50]` → 40; `[7]` → 0; `[]` → 0;
`[1,1,1,1]` → 0.

#complexity(time: $O(n)$, space: $O(1)$)

#ans[30. Path $10 → 30 → 20$ costs $20 + 10 = 30$; the greedy path $10 → 30 → 40 → 20$
costs $20 + 10 + 20 = 50$.]
]
]

#trap[Greedy fails here. "Always hop to the closer height" picks $10 → 30$ then $30 → 40$
and loses. DP wins because it keeps *both* possibilities alive until the end.]

#ex(6, tier: 0, asked: "warm-up")[
Given non-negative numbers, can any subset add up exactly to `target`?
$1 <= n <= 100$, $0 <= "target" <= 10^4$. Edge cases: empty array with target 0;
array containing zeros.

#sol[
State: `dp[s]` = true if some subset of the items seen so far sums to `s`.

Start with `dp[0] = true`. For each new item `x`, any sum `s` becomes reachable if
`s - x` was already reachable.

#code(lang: "javascript", caption: "subsetSumExists — the 0/1 pattern")[
```javascript
function subsetSumExists(a, target) {
  const dp = new Array(target + 1).fill(false);
  dp[0] = true;
  for (const x of a)
    for (let s = target; s >= x; s--)
      if (dp[s - x]) dp[s] = true;
  return dp[target];
}
```
]

Outputs: `[3,34,4,12,5,2]` target 9 → true, target 30 → false;
`[]` target 0 → true, target 5 → false; `[0,0,7]` target 7 → true, target 1 → false;
`[2,2,2]` target 4 → true, target 5 → false.

#complexity(time: $O(n dot "target")$, space: $O("target")$)

#ans[true for 9 ($4 + 5$), false for 30.]
]
]

#trap[If the inner loop went *forwards* (`for (let s = x; s <= target; s++)`) the same item
would be reused many times and `[2]` would reach target 6. Backwards is what makes it 0/1.]

#pagebreak(weak: true)

#section[Tier 1 — the standard set]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
Count the ways to climb $n$ stairs with steps of 1 or 2 — but this time show the *full
ladder* from the naive solution to the best one. $n <= 77$.

#sol[
#approach(1, "Plain recursion", verdict: "O(2^n) — dies around n = 40")

#code(lang: "javascript", caption: "Approach 1 — no memory at all")[
```javascript
function waysBrute(n) {
  if (n === 0) return 1;
  if (n < 0)  return 0;
  return waysBrute(n - 1) + waysBrute(n - 2);
}
```
]
#complexity(time: $O(2^n)$, space: $O(n)$, note: "call stack depth n")

#approach(2, "Recursion + memo", verdict: "O(n) — just add an array")

#code(lang: "javascript", caption: "Approach 2 — top-down")[
```javascript
function waysMemo(n) {
  const memo = new Array(n + 1).fill(-1);
  const go = (k) => {
    if (k === 0) return 1;
    if (k < 0)  return 0;
    if (memo[k] !== -1) return memo[k];
    return memo[k] = go(k - 1) + go(k - 2);
  };
  return go(n);
}
```
]
#complexity(time: $O(n)$, space: $O(n)$, note: "memo array + recursion stack — the stack is the risky part in JS")

#approach(3, "Bottom-up table", verdict: "O(n), no stack")

#code(lang: "javascript", caption: "Approach 3 — loop, not recursion")[
```javascript
function waysTab(n) {
  const dp = new Array(n + 1).fill(0);
  dp[0] = 1;
  for (let i = 1; i <= n; i++) {
    dp[i] = dp[i - 1];
    if (i >= 2) dp[i] += dp[i - 2];
  }
  return dp[n];
}
```
]
#complexity(time: $O(n)$, space: $O(n)$)

#approach(4, "Two variables", verdict: "O(n) time, O(1) space — optimal")

#code(lang: "javascript", caption: "Approach 4 — the table only ever reads 2 cells back")[
```javascript
function waysO1(n) {
  if (n === 0) return 1;
  let twoBack = 1, oneBack = 1;
  for (let i = 2; i <= n; i++) {
    const cur = oneBack + twoBack;
    twoBack = oneBack;
    oneBack = cur;
  }
  return oneBack;
}
```
]
#complexity(time: $O(n)$, space: $O(1)$)

All four agree on $n = 0 .. 12$:

```
1 1 2 3 5 8 13 21 34 55 89 144 233
```
and all three fast ones give `waysMemo(50) = waysTab(50) = waysO1(50) = 20365011074`.

#ans[*The idea that unlocked it:* the recursion's only changing argument is `n`, so there
are only $n+1$ distinct calls. Everything else was repeated work.]
]
]

#note[Notice that Approach 4 is not a new idea — it is Approach 3 with the useless part of
the array deleted. In an interview, say out loud: "the recurrence only looks two cells
back, so I can keep two variables." That sentence is what they want to hear.]

#trap[Approach 2 is the one that fails in production JavaScript. `waysMemo(200000)` throws
`RangeError: Maximum call stack size exceeded` long before it runs out of time, because
Node's stack holds only about $10^4$ frames. Approaches 3 and 4 have no stack at all. Use
top-down to *discover* the recurrence, then ship bottom-up.]

#ex(8, tier: 1, asked: "Infosys · pattern")[
Frog on stones again, but now it may hop up to `k` stones forward. Same cost
$|h[i]-h[j]|$. Minimise the cost to reach the last stone.
$1 <= n <= 10^5$, $1 <= k <= 100$. Target: $O(n k)$.
Edge cases: $k = 1$ (forced path), $n = 1$.

#sol[
State is the same, only the transition widens.

$ "dp"[i] = min_(1 <= j <= k, i - j >= 0) ("dp"[i-j] + |h[i] - h[i-j]|) $

#code(lang: "javascript", caption: "frogK")[
```javascript
function frogK(h, k) {
  const n = h.length;
  if (n <= 1) return 0;
  const dp = new Array(n).fill(Infinity);
  dp[0] = 0;
  for (let i = 1; i < n; i++)
    for (let j = 1; j <= k && j <= i; j++)
      dp[i] = Math.min(dp[i], dp[i - j] + Math.abs(h[i] - h[i - j]));
  return dp[n - 1];
}
```
]

Outputs: `[10,30,40,50,20]` with $k=3$ → 30; the same array with $k=1$ → 70;
`[40,10,20,70,80,10]` with $k=4$ → 30; `[5]` → 0; `[]` → 0.

#complexity(time: $O(n k)$, space: $O(n)$)

#ans[30 with $k=3$ (hop 10 → 50 → 20 is $40 + 30 = 70$; hop 10 → 30 → 20 is
$20 + 10 = 30$).]
]
]

#trick[In C++ this loop needs a hand-picked sentinel like `INT_MAX / 2`, because
`INT_MAX + cost` overflows to a negative number and the `min` picks garbage. JavaScript's
`Infinity` is a genuine infinity: `Infinity + 40` is still `Infinity`. One less bug class
for free.]

#ex(9, tier: 1, asked: "Wipro · pattern")[
Shops stand in a *circle*. You may not pick two neighbouring shops, and shop 0 and shop
$n-1$ are neighbours. Maximise the sum.
$1 <= n <= 10^5$, $0 <= a[i] <= 10^9$. Edge cases: $n = 1$, $n = 2$.

#sol[
#approach(1, "Try every subset", verdict: "O(2^n) — impossible past n = 25")

#approach(2, "Two straight-line runs", verdict: "O(n) — optimal")

The circular rule says one thing only: *you cannot take both index 0 and index $n-1$.*
So the best answer is either an answer that never touches the last shop, or one that never
touches the first shop.

- Run the straight-line solver on `a[0 .. n-2]`
- Run it again on `a[1 .. n-1]`
- Take the larger

#code(lang: "javascript", caption: "robCircle")[
```javascript
function bestLine(a, lo, hi) {            // inclusive range
  let take = 0, skip = 0;
  for (let i = lo; i <= hi; i++) {
    const nt = skip + a[i];
    const ns = Math.max(skip, take);
    take = nt; skip = ns;
  }
  return Math.max(take, skip);
}

function robCircle(a) {
  const n = a.length;
  if (n === 0) return 0;
  if (n === 1) return a[0];
  return Math.max(bestLine(a, 0, n - 2), bestLine(a, 1, n - 1));
}
```
]

Outputs: `[2,3,2]` → 3; `[1,2,3,1]` → 4; `[9]` → 9; `[4,4]` → 4; `[]` → 0;
`[10^9, 1, 10^9, 1, 10^9]` → 2000000000.

#complexity(time: $O(n)$, space: $O(1)$)

#ans[3 for `[2,3,2]` — you cannot take both 2s because they are neighbours in a circle.]
]
]

#trap[The $n = 1$ case must be handled *before* the two runs. With $n = 1$ the range
`0 .. n-2` is `0 .. -1`, which is empty, and you would return 0 instead of `a[0]`.]

#ex(10, tier: 1, asked: "Capgemini · pattern")[
Coins of given values, unlimited supply. What is the *smallest number of coins* that makes
exactly `amount`? Return $-1$ if impossible.
$1 <= "amount" <= 10^4$, at most 12 coin types. Edge cases: amount 0; coin set that cannot
make the amount.

#sol[
#approach(1, "Recursion — try every coin at every step", verdict: "exponential")

#code(lang: "javascript", caption: "Approach 1")[
```javascript
function bruteCoins(coins, amt) {
  if (amt === 0) return 0;
  let best = Infinity;
  for (const c of coins)
    if (c <= amt) best = Math.min(best, 1 + bruteCoins(coins, amt - c));
  return best;
}
```
]
#complexity(time: $O(k^"amt")$, space: $O("amt")$, note: "k = number of coin types")

#approach(2, "Greedy — always take the biggest coin", verdict: "WRONG")

With coins `[1, 3, 4]` and amount 6, greedy takes $4 + 1 + 1 = 3$ coins. The real answer is
$3 + 3 = 2$ coins. Greedy only works for special coin systems, never in general.

#approach(3, "Bottom-up table", verdict: "O(amount × k) — optimal")

$ "dp"[s] = 1 + min_(c in "coins", c <= s) "dp"[s - c] $

#code(lang: "javascript", caption: "minCoins")[
```javascript
function minCoins(coins, amt) {
  const dp = new Array(amt + 1).fill(Infinity);
  dp[0] = 0;
  for (let s = 1; s <= amt; s++)
    for (const c of coins)
      if (c <= s) dp[s] = Math.min(dp[s], dp[s - c] + 1);
  return dp[amt] === Infinity ? -1 : dp[amt];
}
```
]

With coins `[1,3,4]`, amounts $0 .. 12$:

```
0 1 2 1 1 2 2 2 2 3 3 3 3
```

With coins `[5,7]`: amount 11 → $-1$, amount 12 → 2, amount 3 → $-1$.
With coins `[]`: amount 0 → 0, amount 5 → $-1$.
The brute force gives the same numbers for $0 .. 12$.

#complexity(time: $O("amount" times k)$, space: $O("amount")$)

#ans[2 coins for amount 6 with `[1,3,4]`.]
]
]

Python, same recurrence — a little shorter because of the list comprehension:

#code(lang: "python", caption: "min_coins — the Python version")[
```python
def min_coins(coins, amount):
    INF = float('inf')
    dp = [INF] * (amount + 1)
    dp[0] = 0
    for s in range(1, amount + 1):
        for c in coins:
            if c <= s and dp[s - c] + 1 < dp[s]:
                dp[s] = dp[s - c] + 1
    return -1 if dp[amount] == INF else dp[amount]
```
]

Output: `[0, 1, 2, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3]` for coins `[1,3,4]`, then
`2`, `-1`, `0`, `-1` for the edge cases above.

#ex(11, tier: 1, asked: "Cognizant · pattern")[
Same coins, unlimited supply — now *count the number of ways* to make `amount`, where
`[1, 3]` and `[3, 1]` are the *same* way. Then also count them as *different*.
$1 <= "amount" <= 5000$. Edge cases: amount 0; a coin larger than the amount.

#sol[
This is the one problem where *loop order is the answer*.

*Combinations* (order does not matter) — coin loop outside:

#code(lang: "javascript", caption: "countCombinations — coin loop OUTSIDE")[
```javascript
function countCombinations(coins, amt) {
  const dp = new Array(amt + 1).fill(0);
  dp[0] = 1;
  for (const c of coins)
    for (let s = c; s <= amt; s++)
      dp[s] += dp[s - c];
  return dp[amt];
}
```
]

*Permutations* (order matters) — amount loop outside:

#code(lang: "javascript", caption: "countPermutations — amount loop OUTSIDE")[
```javascript
function countPermutations(coins, amt) {
  const dp = new Array(amt + 1).fill(0);
  dp[0] = 1;
  for (let s = 1; s <= amt; s++)
    for (const c of coins)
      if (c <= s) dp[s] += dp[s - c];
  return dp[amt];
}
```
]

Measured outputs:

#table(columns: (1fr, 0.6fr, 0.9fr, 1.1fr),
  [*coins*], [*amt*], [*combinations*], [*permutations*],
  [`[1,2,5]`], [5], [4], [9],
  [`[1,3]`],   [4], [2], [3],
  [`[2]`],     [3], [0], [—],
  [`[2]`],     [4], [1], [—],
  [`[]`],      [0], [1], [—],
  [`[]`],      [7], [0], [—],
  [`[1,2]`],   [60], [31], [2504730781961],
)

#ans[4 combinations of `[1,2,5]` for 5: $5$; $2+2+1$; $2+1+1+1$; $1 times 5$.]
]
]

#trick[Say it to yourself in words.
*Coin outside* = "I finish deciding how many 1-rupee coins, then move on to 2-rupee coins."
Each coin is considered once, so order cannot repeat.
*Amount outside* = "for this amount, the last coin I placed was any of them." The last coin
can differ, so orders are counted separately.]

#trap[`countPermutations([1,2], 60)` is 2504730781961 — safe. But the same count for
amount 200 blows past $2^53$ and stops being exact. Any counting DP that is not asked
modulo something should be checked against `Number.MAX_SAFE_INTEGER` before you trust it.]

#ex(12, tier: 1, asked: "TCS Digital · pattern")[
*0/1 knapsack.* $n$ items, item `i` has weight `w[i]` and value `v[i]`. A bag holds at most
`cap`. Each item may be taken at most once. Maximise value.
$1 <= n <= 100$, $1 <= "cap" <= 10^4$. Edge cases: no items; item heavier than the bag;
cap 0.

#sol[
#approach(1, "Try both choices for every item", verdict: "O(2^n)")

#code(lang: "javascript", caption: "Approach 1 — pure recursion")[
```javascript
function knapBrute(w, v, i, cap) {
  if (i < 0 || cap === 0) return 0;
  const skip = knapBrute(w, v, i - 1, cap);
  let take = 0;
  if (w[i] <= cap) take = v[i] + knapBrute(w, v, i - 1, cap - w[i]);
  return Math.max(skip, take);
}
```
]
#complexity(time: $O(2^n)$, space: $O(n)$)

#approach(2, "Memo on (i, cap)", verdict: "O(n × cap)")

The recursion has exactly two changing arguments: `i` and `cap`. So memo on a 2D array.

#code(lang: "javascript", caption: "Approach 2 — top-down")[
```javascript
function knapMemo(w, v, cap) {
  const n = w.length;
  if (n === 0) return 0;
  const memo = Array.from({ length: n }, () => new Array(cap + 1).fill(-1));
  const go = (i, c) => {
    if (i < 0 || c === 0) return 0;
    if (memo[i][c] !== -1) return memo[i][c];
    const skip = go(i - 1, c);
    const take = w[i] <= c ? v[i] + go(i - 1, c - w[i]) : 0;
    return memo[i][c] = Math.max(skip, take);
  };
  return go(n - 1, cap);
}
```
]
#complexity(time: $O(n dot "cap")$, space: $O(n dot "cap")$)

#approach(3, "2D table", verdict: "O(n × cap), no recursion")

#code(lang: "javascript", caption: "Approach 3 — bottom-up, rows = items")[
```javascript
function knapTable(w, v, cap) {
  const n = w.length;
  const dp = Array.from({ length: n + 1 }, () => new Array(cap + 1).fill(0));
  for (let i = 1; i <= n; i++)
    for (let c = 0; c <= cap; c++) {
      dp[i][c] = dp[i-1][c];
      if (w[i-1] <= c) dp[i][c] = Math.max(dp[i][c], v[i-1] + dp[i-1][c - w[i-1]]);
    }
  return dp[n][cap];
}
```
]
#complexity(time: $O(n dot "cap")$, space: $O(n dot "cap")$)

#approach(4, "One row", verdict: "O(n × cap) time, O(cap) space — optimal")

Row `i` reads only row `i-1`. Keep one row and walk the capacity *backwards* so that
`dp[c - w[i]]` still holds the old row's value.

#code(lang: "javascript", caption: "Approach 4 — the version to memorise")[
```javascript
function knap1D(w, v, cap) {
  const dp = new Array(cap + 1).fill(0);
  for (let i = 0; i < w.length; i++)
    for (let c = cap; c >= w[i]; c--)
      dp[c] = Math.max(dp[c], v[i] + dp[c - w[i]]);
  return dp[cap];
}
```
]
#complexity(time: $O(n dot "cap")$, space: $O("cap")$)

Verification with `w = [1,3,4,5]`, `v = [1,4,5,7]`, `cap = 7`: all four approaches
return *9*. Edge cases: no items → 0; single item of weight 10 with cap 5 → 0, with cap 10
→ 60; `w=[2,2,2], v=[3,3,3], cap=4` → 6, with cap 0 → 0. A randomised test comparing
Approach 1 against Approach 4 on 200 random inputs printed
`200 random cross-checks passed`.

#ans[9 — take items of weight 3 and 4, value $4 + 5 = 9$, total weight 7.]
]
]

#code(lang: "python", caption: "knapsack — Python, the same one row")[
```python
def knapsack(weights, values, cap):
    dp = [0] * (cap + 1)
    for w, v in zip(weights, values):
        for c in range(cap, w - 1, -1):
            dp[c] = max(dp[c], v + dp[c - w])
    return dp[cap]
```
]

Output: `9` for the example above; `0` for empty input; `0` and `60` for the single heavy
item with cap 5 and 10.

#trap[Writing the capacity loop *forwards* in Approach 4 silently turns 0/1 knapsack into
unbounded knapsack. It still runs and gives a bigger (wrong) answer. Graders love this
test.]

#trap[`Array.from({ length: n }, () => new Array(cap + 1).fill(-1))` in Approach 2 is not
decoration. `new Array(n).fill(new Array(cap + 1).fill(-1))` would store the *same row*
`n` times — every memo write would be visible from every item index, and the answer would
be wrong in a way that is very hard to see.]

#ex(13, tier: 1, asked: "Accenture · pattern")[
Split an array of non-negative numbers into two groups with the *same sum*. Is it
possible? $1 <= n <= 200$, $0 <= a[i] <= 100$.
Edge cases: odd total (instantly false); a single element; all zeros.

#sol[
#approach(1, "Generate every subset", verdict: "O(2^n) — hopeless at n = 200")

#approach(2, "Subset sum on half the total", verdict: "O(n × total) — optimal here")

If the two groups have equal sums, each group sums to $"total" / 2$. So:

+ If `total` is odd → impossible, stop.
+ Otherwise ask: can a subset reach exactly `total / 2`? That is Example 6.

#code(lang: "javascript", caption: "canPartition")[
```javascript
function canPartition(a) {
  const total = a.reduce((s, x) => s + x, 0);
  if (total % 2 !== 0) return false;
  const half = total / 2;
  const dp = new Array(half + 1).fill(false);
  dp[0] = true;
  for (const x of a)
    for (let s = half; s >= x; s--)
      if (dp[s - x]) dp[s] = true;
  return dp[half];
}
```
]

Tested outputs:

#table(columns: (1.8fr, 0.8fr, 2fr),
  [*input*], [*output*], [*why*],
  [`[1, 5, 11, 5]`], [true], [$11 = 1+5+5$],
  [`[1, 2, 3, 5]`], [false], [total 11 is odd],
  [`[]`], [true], [two empty groups, both sum 0],
  [`[4]`], [false], [one group would be empty, sums 4 and 0],
  [`[2, 2]`], [true], [],
  [`[0, 0]`], [true], [],
  [`[100,100,100,100,99,1]`], [false], [total 500, but no subset hits 250],
)

#complexity(time: $O(n dot "total")$, space: $O("total")$, note: "total <= 200 × 100 = 20000, so about 4 million steps")

#ans[true for `[1,5,11,5]`.]
]
]

#note[Why is `[100,100,100,100,99,1]` false? The total is 500 and half is 250. Every subset
sum is built from 100s plus possibly 99 and 1. To reach 250 you need $100a + 99b + c = 250$
with $b, c in {0,1}$. $a=2$ gives 200, 299, 201 or 300 — none is 250. So no split exists,
even though the total is even. This is exactly why you cannot answer with a parity check
alone.]

#ex(14, tier: 1, asked: "TCS NQT · pattern")[
*Unbounded knapsack.* Same bag, but each item type has unlimited copies. Maximise value.
Then use it to solve *rod cutting*: a rod of length $n$, `price[L-1]` is the money for a
piece of length `L`; cut it to maximise income.
$1 <= "cap", n <= 10^4$. Edge cases: cap 0; every item heavier than the bag.

#sol[
The only change from 0/1 knapsack is the *direction of the inner loop*. Going forwards
means `dp[c - w[i]]` may already include item `i`, so item `i` can be used again.

#code(lang: "javascript", caption: "unboundedKnap — capacity loop FORWARDS")[
```javascript
function unboundedKnap(w, v, cap) {
  const dp = new Array(cap + 1).fill(0);
  for (let c = 1; c <= cap; c++)
    for (let i = 0; i < w.length; i++)
      if (w[i] <= c) dp[c] = Math.max(dp[c], v[i] + dp[c - w[i]]);
  return dp[cap];
}
```
]

Rod cutting is the same code with $w[i] = i+1$:

#code(lang: "javascript", caption: "rodCut")[
```javascript
function rodCut(price) {
  const n = price.length;
  const dp = new Array(n + 1).fill(0);
  for (let len = 1; len <= n; len++)
    for (let cut = 1; cut <= len; cut++)
      dp[len] = Math.max(dp[len], price[cut - 1] + dp[len - cut]);
  return dp[n];
}
```
]

Outputs: `w=[2,3,4], v=[5,9,11], cap=8` → 23; same with cap 0 → 0;
`w=[5], v=[7]`, cap 4 → 0, cap 17 → 21;
`price = [1,5,8,9,10,17,17,20]` (rod length 8) → 22; `price=[3]` → 3; `price=[]` → 0.

#complexity(time: $O(n dot "cap")$, space: $O("cap")$)

#ans[23 for the bag: take the weight-3 item twice (18) plus the weight-2 item once (5),
total weight 8. For the rod of length 8: cut into $2 + 6$ giving $5 + 17 = 22$.]
]
]

#trick[Two identical loops, one word apart:

`for (let c = cap; c >= w[i]; c--)` → each item once (0/1)

`for (let c = w[i]; c <= cap; c++)` → each item unlimited

Write both on your rough sheet at the start of the exam and never think about it again.]

#ex(15, tier: 1, asked: "Infosys · pattern")[
*Longest Increasing Subsequence (LIS).* Find the length of the longest strictly increasing
subsequence, and also print one such subsequence.
$1 <= n <= 2500$ for this $O(n^2)$ version. Edge cases: empty array; all equal; all
negative.

#sol[
#approach(1, "Check every subsequence", verdict: "O(2^n)")

#approach(2, "DP on 'LIS ending exactly at i'", verdict: "O(n^2) — good up to n = 2500")

State: `dp[i]` = length of the longest increasing subsequence that *ends at index i*.

$ "dp"[i] = 1 + max_(j < i, space a[j] < a[i]) "dp"[j] quad ("or " 1 "if no such " j) $

The answer is the maximum over all `i` — *not* `dp[n-1]`.

#code(lang: "javascript", caption: "lisLength")[
```javascript
function lisLength(a) {
  const n = a.length;
  if (n === 0) return 0;
  const dp = new Array(n).fill(1);
  let best = 1;
  for (let i = 1; i < n; i++) {
    for (let j = 0; j < i; j++)
      if (a[j] < a[i]) dp[i] = Math.max(dp[i], dp[j] + 1);
    best = Math.max(best, dp[i]);
  }
  return best;
}
```
]

To *print* the subsequence, remember which `j` gave you the best value.

#code(lang: "javascript", caption: "lisSequence — with parent pointers")[
```javascript
function lisSequence(a) {
  const n = a.length;
  if (n === 0) return [];
  const dp = new Array(n).fill(1), parent = new Array(n).fill(-1);
  let best = 1, bestEnd = 0;
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < i; j++)
      if (a[j] < a[i] && dp[j] + 1 > dp[i]) { dp[i] = dp[j] + 1; parent[i] = j; }
    if (dp[i] > best) { best = dp[i]; bestEnd = i; }
  }
  const out = [];
  for (let i = bestEnd; i !== -1; i = parent[i]) out.push(a[i]);
  return out.reverse();
}
```
]

Outputs:

#table(columns: (1.8fr, 0.5fr, 1.2fr),
  [*input*], [*len*], [*one LIS*],
  [`[10,9,2,5,3,7,101,18]`], [4], [`2 5 7 101`],
  [`[7,7,7]`], [1], [`7`],
  [`[]`], [0], [(nothing)],
  [`[5]`], [1], [`5`],
  [`[-5,-3,-4,-1]`], [3], [`-5 -3 -1`],
)

#complexity(time: $O(n^2)$, space: $O(n)$)

#ans[4, one witness being $2, 5, 7, 101$.]
]
]

#trap[`[7,7,7]` has LIS 1 because *strictly* increasing means `a[j] < a[i]`, not `<=`.
If the problem says "non-decreasing", change the test to `a[j] <= a[i]` — and the answer
becomes 3.]

#ex(16, tier: 1, asked: "Wipro · pattern")[
A message is a string of digits. `1` decodes to `A`, ..., `26` decodes to `Z`. There is no
letter for `0`. How many ways can the string be decoded?
$1 <= |s| <= 100$. Edge cases: leading `0`; `"100"`; empty string.

#sol[
State: `dp[i]` = number of ways to decode the first `i` characters.

Two moves land on position `i`:
- take one digit `s[i-1]`, legal unless it is `'0'`
- take two digits `s[i-2..i-1]`, legal only if the number is between 10 and 26

$ "dp"[i] = [s_(i-1) != 0] dot "dp"[i-1] + [10 <= overline(s_(i-2) s_(i-1)) <= 26] dot "dp"[i-2] $

Base: `dp[0] = 1` — the empty prefix has one (empty) decoding.

#code(lang: "javascript", caption: "decodeWays")[
```javascript
function decodeWays(s) {
  const n = s.length;
  if (n === 0) return 0;
  const dp = new Array(n + 1).fill(0);
  dp[0] = 1;
  for (let i = 1; i <= n; i++) {
    if (s[i-1] !== '0') dp[i] += dp[i-1];
    if (i >= 2) {
      const two = Number(s.slice(i-2, i));
      if (two >= 10 && two <= 26) dp[i] += dp[i-2];
    }
  }
  return dp[n];
}
```
]

Outputs:

#table(columns: (1fr, 0.8fr, 1fr, 0.8fr),
  [*input*], [*ways*], [*input*], [*ways*],
  [`"12"`], [2], [`"0"`], [0],
  [`"226"`], [3], [`"10"`], [1],
  [`"06"`], [0], [`"100"`], [0],
  [`""`], [0], [`"27"`], [1],
  [`"1111"`], [5], [`"2101"`], [1],
  [30 ones], [1346269], [], [],
)

#complexity(time: $O(|s|)$, space: $O(|s|)$, note: "two variables give O(1) space")

#ans[`"226"` → 3: `BZ` (2,26), `VF` (22,6), `BBF` (2,2,6).]
]
]

#trap[Three separate zero traps: `"06"` is 0 because a two-digit code may not start with 0;
`"10"` is 1 because the `0` must pair with the `1`; `"100"` is 0 because the second `0`
has no legal partner (`"00"` is not in 10..26). Test all three.

A fourth trap is pure JavaScript: `s[i-2] * 10 + s[i-1]` does *string* arithmetic and gives
nonsense, because `s[i]` is a one-character string. `Number(s.slice(i-2, i))` is the safe
form, and `"06"` converts to the number `6`, which correctly fails the `>= 10` test.]

#pagebreak(weak: true)

#section[Tier 2 — applied and two-step]
#tier-header(2)

#ex(17, tier: 2, asked: "Shopee · pattern")[
A warehouse has `n` parcels with integer weights. Count *how many different subsets* weigh
exactly `target` kilograms. Answers can be huge, so report the count modulo $10^9+7$.
$1 <= n <= 200$, $0 <= "target" <= 10^4$, weights may be *zero* (empty boxes).
Edge cases: zero-weight parcels; target 0; empty warehouse.

#sol[
Counting DP, so the combiner is `+` and the base is `dp[0] = 1`.

$ "dp"[s] "after adding item " x = "dp"[s] + "dp"[s - x] $

#code(lang: "javascript", caption: "countSubsetsWithSum")[
```javascript
const MOD = 1000000007;

function countSubsetsWithSum(a, target) {
  if (target < 0) return 0;
  const dp = new Array(target + 1).fill(0);
  dp[0] = 1;                                   // the empty subset
  for (const x of a)
    for (let s = target; s >= x; s--)          // x may be 0: the loop still runs, that is wanted
      dp[s] = (dp[s] + dp[s - x]) % MOD;
  return dp[target];
}
```
]

With `a = [1,2,3]` and targets $0 .. 6$:

```
1 1 1 2 1 1 1
```

Other outputs: `[0,0,1]` target 1 → *4*, target 0 → *4*;
`[]` target 0 → 1, target 3 → 0; `[2,2,2]` target 4 → 3.

#complexity(time: $O(n dot "target")$, space: $O("target")$)

#ans[For `[1,2,3]` target 3 the answer is 2: ${3}$ and ${1,2}$.]
]
]

#trap[Zero-weight parcels double the count. With `[0,0,1]` and target 1 there are four
subsets: ${1}$, ${0_a,1}$, ${0_b,1}$, ${0_a,0_b,1}$. If your code skips items with
`x === 0` you will report 1 and fail. The loop `for (let s = target; s >= x; s--)` with
`x = 0` runs over every `s` and correctly doubles each count — leave it alone.]

#note[Why is the modulus safe here? Both `dp[s]` and `dp[s-x]` stay below $10^9+7$, so
their sum stays below $2 times 10^9$ — far under $2^53$. If the modulus were near $2^53$
instead, the *addition* would still be fine but any *multiplication* would lose precision,
and you would need `BigInt`.]

#ex(18, tier: 2, asked: "Grab · pattern")[
Split all `n` parcels into two trucks, group $S_1$ and group $S_2$, so that
$"sum"(S_1) - "sum"(S_2) = D$ exactly. Count the number of such splits, modulo $10^9+7$.
$1 <= n <= 100$, $0 <= a[i] <= 1000$, $0 <= D <= "total"$.
Edge cases: `D` larger than the total; total and `D` of different parity; zero weights.

#sol[
Turn it into Example 17 with algebra. Let $T$ be the total.
$ "sum"(S_1) + "sum"(S_2) = T, quad "sum"(S_1) - "sum"(S_2) = D $
Subtracting: $2 dot "sum"(S_2) = T - D$, so
$ "sum"(S_2) = (T - D) / 2 $

Two guards fall out immediately:
- if $T - D < 0$ → answer 0
- if $T - D$ is odd → answer 0 (a sum of integers cannot be a half-integer)

Otherwise just count subsets with that sum.

#code(lang: "javascript", caption: "countWithDifference")[
```javascript
function countWithDifference(a, D) {
  const total = a.reduce((s, x) => s + x, 0);
  const t2 = total - D;                  // 2 * sum(S2)
  if (t2 < 0 || t2 % 2 !== 0) return 0;
  return countSubsetsWithSum(a, t2 / 2);
}
```
]

Outputs: `[1,1,2,3]` with $D=1$ → 3; `[1,2,3,1]` with $D=3$ → 2;
`[1]` with $D=1$ → 1 and with $D=2$ → 0; `[0,0,1]` with $D=1$ → 4;
`[]` with $D=0$ → 1.

#complexity(time: $O(n dot T)$, space: $O(T)$)

#ans[3 for `[1,1,2,3]`, $D = 1$: the small truck can carry ${3}$, ${1_a,2}$ or ${1_b,2}$.]
]
]

#trick[Any "difference equals D" question is a "sum equals $(T-D)/2$" question. Do the
algebra on paper *before* touching the keyboard — it converts a scary problem into one you
already solved.]

#ex(19, tier: 2, asked: "Agoda · pattern")[
Split the parcels into two trucks so that the *difference of their weights is as small as
possible*. Return that smallest difference.
$1 <= n <= 100$, $0 <= a[i] <= 200$. Edge cases: empty array; one item; all zeros.

#sol[
Let $T$ be the total. If one truck carries $s$, the other carries $T - s$, and the
difference is $|T - 2s|$. To make it small, push $s$ as close to $T/2$ as you can *from
below*.

+ Mark every reachable subset sum with a boolean DP (Example 6).
+ Scan $s = 0 .. T/2$ and take the best $T - 2s$ among reachable sums.

#code(lang: "javascript", caption: "minSubsetDiff")[
```javascript
function minSubsetDiff(a) {
  const total = a.reduce((s, x) => s + x, 0);
  const dp = new Array(total + 1).fill(false);
  dp[0] = true;
  for (const x of a)
    for (let s = total; s >= x; s--)
      if (dp[s - x]) dp[s] = true;
  let best = Infinity;
  for (let s = 0; s <= Math.floor(total / 2); s++)
    if (dp[s]) best = Math.min(best, total - 2 * s);
  return best;
}
```
]

Outputs: `[1,6,11,5]` → 1; `[1,2,7]` → 4; `[8]` → 8; `[]` → 0; `[3,3]` → 0;
`[0,0,0]` → 0.

#complexity(time: $O(n dot T)$, space: $O(T)$, note: "T <= 100 × 200 = 20000")

#ans[1 for `[1,6,11,5]`: split into ${1,5,6} = 12$ and ${11} = 11$.]
]
]

#note[`dp[0]` is always true, so the loop always finds at least $s = 0$ and `best` is never
left at `Infinity`. That is why no extra guard is needed for the empty array.]

#ex(20, tier: 2, asked: "SCB · pattern")[
A house painter must paint `n` houses in a row using 3 colours. `cost[i][c]` is the price
of painting house `i` in colour `c`. Neighbouring houses must differ in colour. Find the
cheapest total.
$1 <= n <= 10^5$, $0 <= "cost" <= 10^4$. Edge cases: $n = 0$; $n = 1$; all costs equal.

#sol[
The state must remember *the last colour used*, so it is a triple, not a single number.

- `a` = cheapest cost for houses $0..i$ where house `i` is colour 0
- `b` = same, colour 1
- `c` = same, colour 2

$ a' = "cost"[i][0] + min(b, c) $ and similarly for the other two.

#code(lang: "javascript", caption: "minPaint")[
```javascript
function minPaint(cost) {
  if (cost.length === 0) return 0;
  let [a, b, c] = cost[0];
  for (let i = 1; i < cost.length; i++) {
    const na = cost[i][0] + Math.min(b, c);
    const nb = cost[i][1] + Math.min(a, c);
    const nc = cost[i][2] + Math.min(a, b);
    a = na; b = nb; c = nc;
  }
  return Math.min(a, b, c);
}
```
]

Outputs: `[[17,2,17],[16,16,5],[14,3,19]]` → 10; `[[7,6,2]]` → 2; `[]` → 0;
`[[1,1,1],[1,1,1]]` → 2.

#complexity(time: $O(n)$, space: $O(1)$)

#ans[10 — colours 1, 2, 1 with costs $2 + 5 + 3$.]
]
]

#trap[`na`, `nb`, `nc` must all be computed *before* any of `a`, `b`, `c` is overwritten.
Writing `a = cost[i][0] + Math.min(b,c); b = cost[i][1] + Math.min(a,c);` uses the *new*
`a` in the second line and gives a wrong (and very hard to spot) answer. The destructuring
line `let [a, b, c] = cost[0];` is safe because the right-hand side is fully evaluated
first.]

#ex(21, tier: 2, asked: "Sea/Shopee · pattern")[
Daily percentage changes are stored as integers. Find the *largest product* of any
contiguous block. $1 <= n <= 10^5$, $|a[i]| <= 10$ — and then the same question with much
larger values, where the product stops being exact.
Edge cases: zeros; all negative; a single element.

#sol[
Sum problems (Kadane) only need the best-so-far. Products need *two* running values,
because a very negative product times a negative number becomes very positive.

- `hi` = largest product of a block ending here
- `lo` = smallest (most negative) product of a block ending here

$ "hi"' = max(x, "hi" dot x, "lo" dot x), quad "lo"' = min(x, "hi" dot x, "lo" dot x) $

#code(lang: "javascript", caption: "maxProductSubarray")[
```javascript
function maxProductSubarray(a) {
  if (a.length === 0) return 0;
  let best = a[0], hi = a[0], lo = a[0];
  for (let i = 1; i < a.length; i++) {
    const x = a[i];
    const nhi = Math.max(x, hi * x, lo * x);
    const nlo = Math.min(x, hi * x, lo * x);
    hi = nhi; lo = nlo;
    best = Math.max(best, hi);
  }
  return best;
}
```
]

Outputs: `[2,3,-2,4]` → 6; `[-2,0,-1]` → 0; `[]` → 0; `[-3]` → $-3$;
`[-2,-3,-4]` → 12; `[100000,100000,100000]` → 1000000000000000; `[0,0,0]` → 0.

#complexity(time: $O(n)$, space: $O(1)$)

#ans[6 for `[2,3,-2,4]` (the block `2,3`). Note 4 alone is only 4 and
$2 dot 3 dot (-2) dot 4 = -48$.]
]
]

#trap[`[100000,100000,100000]` gives $10^15$, which is still exact — it is under
$2^53 approx 9.007 times 10^15$. But `maxProductSubarray([123456789, 987654321])` returns
*121932631112635260* while the true product is *121932631112635269*. Nine wrong at the end,
no warning, no exception.

The fix when products can be that large: switch the whole DP to `BigInt`
(`123456789n * 987654321n` gives the exact value), or ask the interviewer whether the
answer is wanted modulo something. Always ask "how big can this product get?" before you
write `*`.]

#ex(22, tier: 2, asked: "LINE MAN · pattern")[
A menu has words. Given a string with no spaces, can it be split into a sequence of menu
words? Then print one valid split.
$1 <= |s| <= 300$, dictionary up to 1000 words. Edge cases: empty string; a word that is a
prefix of another; impossible strings.

#sol[
#approach(1, "Try every cut position recursively", verdict: "O(2^n)")

#approach(2, "DP over prefixes", verdict: "O(n^2 × L) — optimal enough")

State: `dp[i]` = true if the first `i` characters can be split.

$ "dp"[i] = "OR"_(0 <= j < i) ("dp"[j] "AND" s[j..i-1] in "dict") $

Base: `dp[0] = true` — the empty prefix always splits (into zero words).

#code(lang: "javascript", caption: "wordBreak — a Set, not a plain object")[
```javascript
function wordBreak(s, dict) {
  const words = new Set(dict);
  const n = s.length;
  const dp = new Array(n + 1).fill(false);
  dp[0] = true;                                  // the empty prefix always breaks
  for (let i = 1; i <= n; i++)
    for (let j = 0; j < i; j++)
      if (dp[j] && words.has(s.slice(j, i))) { dp[i] = true; break; }
  return dp[n];
}
```
]

To print a split, store *where the last word started*.

#code(lang: "javascript", caption: "oneSentence — rebuild the split from cut[]")[
```javascript
function oneSentence(s, dict) {
  const words = new Set(dict);
  const n = s.length;
  const dp = new Array(n + 1).fill(false), cut = new Array(n + 1).fill(-1);
  dp[0] = true;
  for (let i = 1; i <= n; i++)
    for (let j = 0; j < i; j++)
      if (dp[j] && words.has(s.slice(j, i))) { dp[i] = true; cut[i] = j; break; }
  if (!dp[n]) return '(impossible)';
  const parts = [];
  for (let i = n; i > 0; i = cut[i]) parts.push(s.slice(cut[i], i));
  return parts.reverse().join(' ');
}
```
]

Outputs:

#table(columns: (1.3fr, 1.5fr, 0.5fr, 1.2fr),
  [*string*], [*dictionary*], [*ok*], [*split printed*],
  [`carton`], [`['cart','on','car','ton']`], [true], [`car ton`],
  [`abcd`], [`['ab','abc']`], [false], [`(impossible)`],
  [`""`], [`['a']`], [true], [(empty line)],
  [`aaaaa`], [`['aa','aaa']`], [true], [`aa aaa`],
  [`x`], [`[]`], [false], [],
)

#complexity(time: $O(n^2 L)$, space: $O(n + "dict")$, note: "L = average word length, from hashing each substring")

#ans[`carton` splits as `car ton` (and also as `cart on`; either is accepted).]
]
]

#trap[*Use a `Set`, not a plain object, for the dictionary.* A plain object inherits keys
from `Object.prototype`, so `dict['constructor']` is truthy even when the word
`"constructor"` is not in your list — `'constructor' in {}` is `true`. A `Set` has no
inherited members, keeps the type of what you put in, and `has()` is the honest test. The
same argument applies to frequency counting: prefer `Map` over `{}`.]

#note[`dp[0] = true` is not a special case you bolt on — it is the honest answer to "can an
empty string be written as zero words?" Yes, it can. Every counting and feasibility DP
starts from that same idea.]

#ex(23, tier: 2, asked: "Razer · pattern")[
*Bounded knapsack.* Item `i` has weight `w[i]`, value `v[i]` and *exactly `cnt[i]` copies*
in stock. Fill a bag of capacity `cap` for maximum value.
$1 <= n <= 100$, $0 <= "cnt"[i] <= 10^4$, $"cap" <= 10^4$.
Edge cases: `cnt[i] = 0`; no items; cap 0.

#sol[
#approach(1, "Expand every copy into its own item", verdict: "O(cap × Σcnt) — 10^8, too slow")

If `cnt[i]` is 10000 for 100 items, you create a million 0/1 items. Too slow.

#approach(2, "Binary splitting", verdict: "O(cap × Σ log cnt) — optimal")

Here is the trick. Any count `k` can be written using pieces of size
$1, 2, 4, 8, ..., "remainder"$. With $k = 11$ the pieces are $1, 2, 4, 4$. Every number from
0 to 11 is the sum of some of those pieces, and no number above 11 is. So replace item `i`
by about $log_2 "cnt"[i]$ *fused* items and run plain 0/1 knapsack.

#code(lang: "javascript", caption: "boundedKnap")[
```javascript
function boundedKnap(w, v, cnt, cap) {
  const W = [], V = [];
  for (let i = 0; i < w.length; i++) {
    let k = cnt[i], piece = 1;
    while (k > 0) {
      const use = Math.min(piece, k);
      W.push(w[i] * use);
      V.push(v[i] * use);
      k -= use;
      piece *= 2;
    }
  }
  const dp = new Array(cap + 1).fill(0);
  for (let i = 0; i < W.length; i++)
    for (let c = cap; c >= W[i]; c--)
      dp[c] = Math.max(dp[c], V[i] + dp[c - W[i]]);
  return dp[cap];
}
```
]

Checked against the slow "expand every copy" version: `w=[2,3], v=[4,5], cnt=[3,2], cap=10`
gives *18* from both. `cnt = [0]` gives 0 from both. Empty input gives 0. A randomised
comparison over 300 inputs printed `300 random cross-checks passed`.

#complexity(time: $O("cap" dot sum log "cnt"[i])$, space: $O("cap")$)

#ans[18 — three weight-2 items (12) plus two weight-3 items (10) is weight 12, too heavy;
the best legal pack is two weight-2 (8) plus two weight-3 (10), weight 10, value 18.]
]
]

#trick[Why $1, 2, 4, ..., r$? Because binary. Every integer $0 <= m <= k$ has a binary
form, and the leftover piece $r$ covers the top of the range. You get *exactly* the numbers
$0..k$ and nothing more — which is precisely the "at most `cnt[i]` copies" rule.]

#pagebreak(weak: true)

#section[Tier 3 — insight needed]
#tier-header(3)

#ex(24, tier: 3, asked: "Google · pattern")[
LIS again, but $n$ is up to $2 times 10^5$. The $O(n^2)$ solution will time out. Find the
length in $O(n log n)$.
Edge cases: empty array; all equal; strictly decreasing.

#sol[
#approach(1, "DP ending at i", verdict: "O(n^2) — 4 × 10^10 steps, far too slow")

#approach(2, "Keep the best tail for every length", verdict: "O(n log n) — optimal")

Here is the insight. For each possible length `L`, we only care about *the smallest value
that can end an increasing subsequence of length `L`*. Call it `tails[L-1]`.

Why smallest? Because a smaller ending value is never worse — anything that can extend a
big ending can also extend a small one.

Two facts make this work:

+ `tails` is always sorted increasing. (A length-5 chain contains a length-4 chain ending
  at a smaller value.)
+ For a new value `x`, find the first tail that is $>= x$ and *overwrite it* with `x`.
  If no tail is $>= x$, then `x` extends the longest chain, so append it.

Step 2 is exactly a lower-bound search. JavaScript has no `lower_bound` in the standard
library, so we use `lowerBound` from the JS Toolkit appendix.

#code(lang: "javascript", caption: "lisFast — strictly increasing")[
```javascript
const { lowerBound } = require('./toolkit.js');

function lisFast(a) {
  const tails = [];                       // tails[k] = smallest tail of a length k+1 chain
  for (const x of a) {
    const i = lowerBound(tails, x);
    if (i === tails.length) tails.push(x);
    else tails[i] = x;
  }
  return tails.length;
}
```
]

Trace on `[10, 9, 2, 5, 3, 7, 101, 18]`:

#table(columns: (0.5fr, 0.5fr, 2fr, 2.4fr),
  [*step*], [*x*], [*tails after*], [*what happened*],
  [1], [10], [`10`], [append (first value)],
  [2], [9],  [`9`], [9 replaces 10 — cheaper length-1 ending],
  [3], [2],  [`2`], [2 replaces 9],
  [4], [5],  [`2 5`], [5 > 2, append: a length-2 chain exists],
  [5], [3],  [`2 3`], [3 replaces 5 — cheaper length-2 ending],
  [6], [7],  [`2 3 7`], [append: length 3],
  [7], [101],[`2 3 7 101`], [append: length 4],
  [8], [18], [`2 3 7 18`], [18 replaces 101],
)

Final size 4 — matching the $O(n^2)$ answer from Example 15.

Outputs: `[10,9,2,5,3,7,101,18]` → 4; `[7,7,7]` → 1; `[]` → 0; `[4,3,2,1]` → 1.
A randomised comparison of `lisFast` against the $O(n^2)$ version on 300 arrays printed
`300 random cross-checks passed`.

#complexity(time: $O(n log n)$, space: $O(n)$)

#ans[4.]
]

#subsection[The follow-up the interviewer asks next]

*"Now make it non-decreasing (ties allowed)."*

Change `lowerBound` (first element $>= x$) to `upperBound` (first element $> x$). That
single word lets an equal value sit next to an equal value.

#code(lang: "javascript", caption: "lndsFast — non-decreasing, one word changed")[
```javascript
const { upperBound } = require('./toolkit.js');

function lndsFast(a) {
  const tails = [];
  for (const x of a) {
    const i = upperBound(tails, x);
    if (i === tails.length) tails.push(x);
    else tails[i] = x;
  }
  return tails.length;
}
```
]

Outputs: `[10,9,2,5,3,7,101,18]` → 4 (unchanged); `[7,7,7]` → *3* (was 1).
]

#trap[Two JavaScript-specific points on this problem.

*(1) There is no ordered set.* C++ has an ordered `set` with `lower_bound`; Java has `TreeMap`.
JavaScript has neither. The working pattern is exactly what this solution does: keep a
*sorted plain array* and binary-search it with the toolkit's `lowerBound` / `upperBound`.

*(2) `tails` is not an LIS.* After the trace above it holds `2 3 7 18`. Only its *length*
is meaningful; the contents are a mixture of different chains. To print an actual LIS you
must store parent pointers as in Example 15.]

#ex(25, tier: 3, asked: "Adobe · pattern")[
Count *how many* longest increasing subsequences an array has.
$1 <= n <= 2000$. Edge cases: all equal (answer is $n$, not 1); empty array; single element.

#sol[
Run the $O(n^2)$ LIS, but carry a second array.

- `len[i]` = length of the longest increasing subsequence ending at `i`
- `cnt[i]` = how many such subsequences there are

When we look at a smaller index `j` with `a[j] < a[i]`:

- if `len[j] + 1 > len[i]` → we found a *longer* chain. Reset: `len[i] = len[j]+1`,
  `cnt[i] = cnt[j]`.
- if `len[j] + 1 === len[i]` → we found *another* way to reach the same length. Add:
  `cnt[i] += cnt[j]`.

Finally sum `cnt[i]` over every `i` whose `len[i]` equals the overall best.

#code(lang: "javascript", caption: "countLIS")[
```javascript
function countLIS(a) {
  const n = a.length;
  if (n === 0) return 0;
  const len = new Array(n).fill(1), cnt = new Array(n).fill(1);
  let best = 1;
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < i; j++) {
      if (a[j] < a[i]) {
        if (len[j] + 1 > len[i]) { len[i] = len[j] + 1; cnt[i] = cnt[j]; }
        else if (len[j] + 1 === len[i]) cnt[i] += cnt[j];
      }
    }
    best = Math.max(best, len[i]);
  }
  let total = 0;
  for (let i = 0; i < n; i++) if (len[i] === best) total += cnt[i];
  return total;
}
```
]

Outputs: `[1,3,5,4,7]` → 2; `[2,2,2,2]` → 4; `[]` → 0; `[5]` → 1;
`[1,2,4,3,5,4,7,2]` → 3.

#complexity(time: $O(n^2)$, space: $O(n)$)

#ans[2 for `[1,3,5,4,7]`: $1,3,5,7$ and $1,3,4,7$.]
]

#subsection[The follow-up the interviewer asks next]

*"n is now $10^5$ — can you still do it?"*

Yes, but you must replace the inner `j` loop with a data structure. Keep a Fenwick tree (or
segment tree) indexed by *compressed value*, where each node stores the pair
`[best length, number of ways]` for all values below it. Merging two such pairs uses the
same "longer resets, equal adds" rule. That gives $O(n log n)$.

Say this out loud even if you do not code it — recognising that the transition is a
*prefix maximum with counts* is the point of the question.
]

#trap[`[2,2,2,2]` answers 4, not 1. The LIS length is 1, and there are four different
single-element subsequences. Many candidates return 1 here. Test equal values first.]

#ex(26, tier: 3, asked: "Amazon · pattern")[
You have `n` rectangular boxes given as `[width, depth]` pairs. Box $B$ may sit on box $A$
only if *both* $w_B < w_A$ and $d_B < d_A$ (strictly). What is the tallest stack (most
boxes)?
$1 <= n <= 5000$. Edge cases: identical boxes; boxes where one dimension ties; one box.

#sol[
#approach(1, "Try all orders", verdict: "O(n!) — never")

#approach(2, "Sort by width, then LIS on depth", verdict: "O(n^2), optimal for n = 5000")

Two conditions are hard to handle at once. So *remove one of them by sorting*. After
sorting by width ascending, a box later in the array can only sit under a box earlier in
the array. Now the problem reads: *find the longest chain where depth also increases* —
which is LIS with a custom comparison.

We still check width strictly inside the loop, because sorting does not stop two boxes from
sharing a width.

#code(lang: "javascript", caption: "longestChain")[
```javascript
function longestChain(box) {
  const n = box.length;
  if (n === 0) return 0;
  const b = box.map(p => [...p]);                   // deep enough copy of the pairs
  b.sort((p, q) => p[0] - q[0] || p[1] - q[1]);     // NEVER b.sort()
  const dp = new Array(n).fill(1);
  let best = 1;
  for (let i = 0; i < n; i++) {
    for (let j = 0; j < i; j++)
      if (b[j][0] < b[i][0] && b[j][1] < b[i][1])
        dp[i] = Math.max(dp[i], dp[j] + 1);
    best = Math.max(best, dp[i]);
  }
  return best;
}
```
]

Outputs:

#table(columns: (2.2fr, 0.6fr, 2fr),
  [*boxes*], [*stack*], [*why*],
  [`[[5,4],[6,4],[6,7],[2,3]]`], [3], [$(2,3) < (5,4) < (6,7)$],
  [`[[1,1],[1,1],[1,1]]`], [1], [ties are not allowed],
  [`[]`], [0], [],
  [`[[9,9]]`], [1], [],
  [`[[1,5],[2,4],[3,3],[4,2],[5,1]]`], [1], [width up means depth down],
  [`[[1,2],[2,3],[3,4],[4,5]]`], [4], [everything nests],
)

#complexity(time: $O(n^2)$, space: $O(n)$)

#ans[3.]
]

#subsection[The follow-up the interviewer asks next]

*"Now boxes may be rotated 90°, and $n$ is $10^5$."*

Two separate changes.

+ *Rotation*: for each box push both `[w,d]` and `[d,w]` into the list, then solve the same
  problem on $2n$ boxes. Normalising each box so that $w <= d$ first removes exact
  duplicates.
+ *Speed*: sort by width ascending, and for equal widths sort by depth *descending*. Now
  two boxes with the same width can never both be picked — because their depths are in
  decreasing order, they can never form an increasing depth pair. That makes the width
  check unnecessary, and the problem becomes plain LIS on depth, solvable in $O(n log n)$
  with the `tails` method of Example 24. The comparator becomes
  `(p, q) => p[0] - q[0] || q[1] - p[1]`.

That tie-breaking trick — *sort the second key downwards so ties self-destruct* — is worth
memorising. It appears in many "2D chain" questions.
]

#trap[*This is the single most common JavaScript interview bug.* `Array.prototype.sort()`
with no comparator converts every element to a *string* and sorts lexicographically.

`[10, 9, 1].sort()` returns `[1, 10, 9]`.

It is worse for pairs. `[[6,4],[5,4],[10,1],[2,3]].sort()` returns
`[[10,1],[2,3],[5,4],[6,4]]` — because `"10,1" < "2,3"` as strings. Your box DP would then
run on garbage order and quietly return a wrong number.

Always pass a comparator: `(a, b) => a - b` for numbers, and
`(p, q) => p[0] - q[0] || p[1] - q[1]` for pairs. The `||` trick works because a `0`
first-key difference is falsy, so the second key decides.]

#ex(27, tier: 3, asked: "D. E. Shaw · pattern")[
0/1 knapsack, but the weights are huge: $n <= 100$, $w[i] <= 10^9$, $"cap" <= 10^9$, and
$v[i] <= 100$. The classic `dp[cap]` table would need $10^9$ cells.
Edge cases: no items; capacity 0; a single item that does not fit.

#sol[
#approach(1, "dp indexed by capacity", verdict: "O(n × cap) = 10^11 time and 10^9 cells — impossible")

#approach(2, "Flip the table: index by VALUE", verdict: "O(n × Σv) = 10^6 — optimal")

The insight is a swap of question. Instead of

> "with capacity `c`, what is the best value?"

ask

> "to reach value `val`, what is the *least weight* I need?"

Total value is at most $100 times 100 = 10^4$, so the table is tiny. Then walk down from the
largest value and return the first one whose least weight fits in the bag.

$ "dp"["val"] = min("dp"["val"], "dp"["val" - v_i] + w_i) $

#code(lang: "javascript", caption: "knapsackByValue")[
```javascript
function knapsackByValue(w, v, cap) {
  const V = v.reduce((s, x) => s + x, 0);
  const dp = new Array(V + 1).fill(Infinity);   // dp[val] = least weight that reaches val
  dp[0] = 0;
  for (let i = 0; i < w.length; i++)
    for (let val = V; val >= v[i]; val--)
      if (dp[val - v[i]] < Infinity)
        dp[val] = Math.min(dp[val], dp[val - v[i]] + w[i]);
  for (let val = V; val >= 0; val--)
    if (dp[val] <= cap) return val;
  return 0;
}
```
]

Outputs with `w = [1000000000, 999999999, 3]` and `v = [3, 4, 2]`:

#table(columns: (1.4fr, 0.6fr, 2fr),
  [*capacity*], [*best value*], [*chosen items*],
  [1000000002], [6], [weights 999999999 + 3],
  [1999999999], [7], [weights 1000000000 + 999999999],
  [2], [0], [nothing fits],
)

Also: empty input with cap 10 → 0; `w=[4,5,6], v=[1,2,3]` with cap 11 → 5.

#complexity(time: $O(n dot sum v_i)$, space: $O(sum v_i)$)

#ans[6 at capacity 1000000002.]
]

#subsection[The follow-up the interviewer asks next]

*"What if both the weights and the values are up to $10^9$?"*

Then neither table fits and no polynomial-in-the-input algorithm is known — knapsack is
NP-hard in general. The honest answers are:

- *meet in the middle*: split the $n$ items into two halves, list all $2^(n/2)$ subset
  `[weight, value]` pairs of each half, sort one half and binary search. Works up to about
  $n = 40$: $2 times 2^20 approx 2 times 10^6$ pairs.
- *approximation*: scale all values down by a factor and run the value-indexed DP. You lose
  a controllable small percentage of the optimum.

Naming "NP-hard, so here are the two standard escapes" is the expected answer. Do not
pretend a polynomial algorithm exists.
]

#trick[Whenever a DP dimension is too big, look at the *other* quantity in the problem. If
the answer range is small, index the table by the answer and store the resource. This
"invert the DP" move shows up again in scheduling and in shortest-path problems with small
edge weights.]

#trap[Weights here reach $10^9$ and sums reach $2 times 10^9$. In C++ that overflows a
32-bit `int`; in JavaScript it does not, because a Number is exact to $2^53$. This is one
of the rare places where JS is *safer* than C++. But do not relax: a *sum of 100 such
weights* is $10^11$, still exact, while a *product* of two of them is $10^18$ and is not.
Addition is safe far longer than multiplication.]

#ex(28, tier: 3, asked: "Goldman Sachs · pattern")[
Daily prices of one stock. You may buy and sell any number of times, but you hold at most
one share, and *after selling you must rest one full day* before buying again. Maximise
profit.
$1 <= n <= 10^5$. Edge cases: empty; one day; prices only falling.

#sol[
#approach(1, "Recursion over (day, holding?, resting?)", verdict: "O(2^n) without a memo")

#approach(2, "Three-state machine, O(1) space", verdict: "optimal")

The state is not a number — it is *which situation you are in today*. There are three:

#diagram(height: 3.6cm, caption: "The three states and the moves between them. Buying is only allowed from REST.")[
#dnode(0.2cm, 0.4cm, 2.6cm, 1cm, "HOLD — own a share")
#dnode(5.0cm, 0.4cm, 2.6cm, 1cm, "SOLD — sold today")
#dnode(2.6cm, 2.4cm, 2.6cm, 1cm, "REST — free to buy")
#darrow(2.8cm, 0.9cm, 5.0cm, 0.9cm, label: "sell +p")
#darrow(6.0cm, 1.4cm, 4.6cm, 2.4cm, label: "wait")
#darrow(3.4cm, 2.4cm, 1.4cm, 1.4cm, label: "buy -p")
]

- `hold` = best profit while owning a share
- `sold` = best profit on a day you just sold (tomorrow you must rest)
- `rest` = best profit while free and not in cooldown

Transitions for day `i` with price `p`:
$ "hold"' = max("hold", "rest" - p), quad "sold"' = "hold" + p, quad "rest"' = max("rest", "sold") $

#code(lang: "javascript", caption: "maxProfitCooldown")[
```javascript
function maxProfitCooldown(p) {
  const n = p.length;
  if (n === 0) return 0;
  let hold = -p[0];          // holding a share
  let sold = -Infinity;      // sold today, so tomorrow is a rest day
  let rest = 0;              // free, not in cooldown
  for (let i = 1; i < n; i++) {
    const nHold = Math.max(hold, rest - p[i]);
    const nSold = hold + p[i];
    const nRest = Math.max(rest, sold);
    hold = nHold; sold = nSold; rest = nRest;
  }
  return Math.max(rest, sold);
}
```
]

Outputs (second number is the profit with *no* cooldown, for comparison):

#table(columns: (1.6fr, 0.9fr, 0.9fr),
  [*prices*], [*cooldown*], [*no rule*],
  [`[1,2,3,0,2]`], [3], [4],
  [`[5,4,3,2,1]`], [0], [0],
  [`[]`], [0], [—],
  [`[7]`], [0], [—],
  [`[1,5]`], [4], [—],
  [`[2,1,4,5,2,9,7]`], [10], [11],
)

#complexity(time: $O(n)$, space: $O(1)$)

#ans[3 for `[1,2,3,0,2]` — buy at 1, sell at 3, rest, buy at 0, sell at 2.]
]

#subsection[The follow-up the interviewer asks next]

*"Drop the cooldown, but now allow at most `k` transactions."*

The state becomes "how many sales are done so far", so keep two arrays of size $k+1$.

#code(lang: "javascript", caption: "maxProfitK — at most k buy/sell pairs")[
```javascript
function maxProfitK(p, k) {
  const n = p.length;
  if (n === 0 || k === 0) return 0;
  const hold = new Array(k + 1).fill(-Infinity);
  const sold = new Array(k + 1).fill(0);        // sold[j] = free, j sales done
  for (const price of p)
    for (let j = 1; j <= k; j++) {
      hold[j] = Math.max(hold[j], sold[j-1] - price);
      sold[j] = Math.max(sold[j], hold[j] + price);
    }
  return sold[k];
}
```
]

Outputs: `[2,4,1]` with $k=2$ → 2; `[3,2,6,5,0,3]` with $k=2$ → 7, with $k=1$ → 4,
with $k=9$ → 7 (same as unlimited); `[]` → 0; `[5]` → 0; `[5,4,3,2]` → 0;
`[1,2,3,4,5]` with $k=1$ → 4 and with $k=2$ → 4.

#complexity(time: $O(n k)$, space: $O(k)$)
]

#trap[Inside the `j` loop, `hold[j]` is updated *before* `sold[j]` uses it. That is not a
bug — it means "buy and sell on the same day", which earns 0 and never hurts. But if you
reversed the two lines you would be using yesterday's `hold`, and the answer would drop.
Know which order you wrote and why.

Also note `-Infinity` as the "impossible" marker. `-Infinity - price` stays `-Infinity`,
so an impossible state can never accidentally win a `Math.max`.]

#ex(29, tier: 3, asked: "Uber · pattern")[
An array of scores. You start at index 0 and must reach index $n-1$. From index `i` you may
jump to any index in $[i+1, i+k]$. Landing on `i` adds `a[i]` to your score (including the
first and last). Maximise the total score.
$1 <= n <= 10^5$, $1 <= k <= n$, $-10^4 <= a[i] <= 10^4$.
Edge cases: $n=1$; all negatives; $k = n-1$.

#sol[
#approach(1, "DP over all previous k positions", verdict: "O(n k) — 10^10 when k is large")

$ "dp"[i] = a[i] + max_(i-k <= j < i) "dp"[j] $

#code(lang: "javascript", caption: "Approach 1 — correct but slow (used here as the reference)")[
```javascript
function slow(a, k) {
  const n = a.length; if (n === 0) return 0;
  const dp = new Array(n).fill(-Infinity); dp[0] = a[0];
  for (let i = 1; i < n; i++)
    for (let j = Math.max(0, i - k); j < i; j++)
      dp[i] = Math.max(dp[i], dp[j] + a[i]);
  return dp[n-1];
}
```
]
#complexity(time: $O(n k)$, space: $O(n)$)

#approach(2, "Sliding-window maximum with a deque", verdict: "O(n) — optimal")

The inner loop is *a maximum over a window of the last `k` values of `dp`*. That is exactly
the monotonic deque from Chapter 9. The deque stores indices whose `dp` values are
decreasing from front to back, so the front is always the window maximum.

Two rules per step:
+ drop the front while it is older than $i-k$ (out of the window);
+ before pushing `i`, drop from the back every index whose `dp` is $<=$ `dp[i]` — it can
  never be the maximum again.

#code(lang: "javascript", caption: "maxScoreJumpK")[
```javascript
const { Deque } = require('./toolkit.js');

function maxScoreJumpK(a, k) {
  const n = a.length;
  if (n === 0) return 0;
  const dp = new Array(n).fill(-Infinity);
  const dq = new Deque();
  dp[0] = a[0]; dq.push(0);
  for (let i = 1; i < n; i++) {
    while (dq.size && dq.front() < i - k) dq.shift();
    dp[i] = dp[dq.front()] + a[i];
    while (dq.size && dp[dq.back()] <= dp[i]) dq.pop();
    dq.push(i);
  }
  return dp[n-1];
}
```
]

Each index enters and leaves the deque once, so the total deque work is $O(n)$.

Outputs (both methods agree): `[1,-1,-2,4,-7,3]` with $k=2$ → 7;
`[10,-5,-2,4,0,3]` with $k=3$ → 17; `[5]` → 5; `[]` → 0. A randomised comparison of the
two versions over 300 inputs printed `300 random cross-checks passed`.

#complexity(time: $O(n)$, space: $O(n)$, note: "O(k) extra for the deque")

#ans[7 for `[1,-1,-2,4,-7,3]`, $k=2$: indices 0 → 1 → 3 → 5 giving $1-1+4+3 = 7$.]
]

#subsection[The follow-up the interviewer asks next]

*"The array arrives as a stream — you see `a[i]` only at step `i`."*

Nothing changes. The deque solution already reads each element once, in order, and keeps
only the last `k` useful entries. Memory is $O(k)$, not $O(n)$, if you also store `dp` in a
circular buffer of size $k+1$. Streaming-friendliness is a direct consequence of the
window being *bounded*; say that, and you have answered the question.
]

#trap[*Do not use a plain array with `shift()` as a deque.* `Array.prototype.shift()` is
$O(n)$ in the worst case because every remaining element moves down one slot, which turns
this $O(n)$ algorithm back into $O(n^2)$. The toolkit `Deque` keeps a head index and only
compacts occasionally, giving $O(1)$ amortised `shift`. JavaScript also has no built-in
priority queue; when a problem needs one, use the toolkit `MinHeap`.]

#trick[Whenever a DP transition is "max or min over a contiguous window of previous
states", the fix is always the same: monotonic deque for a fixed window, or a heap /
prefix-max array if the window grows. Recognising the shape is worth more than memorising
the code.]

#revision[
#subsection[The recipe]

#formulas(title: "Five steps, every time")[
+ Write the brute-force recursion: "at this index I take it or I skip it".
+ The *changing arguments* of that recursion are the state.
+ Memoise on those arguments $arrow.r$ top-down DP.
+ Rewrite as a loop from the base cases outward $arrow.r$ bottom-up table.
+ If the loop only reads the previous row, throw the rest of the table away.
]

#subsection[The templates]

#code(lang: "js", caption: "T1 — top-down memo (use it to FIND the recurrence)")[
```js
const climbMemo = (n) => {
  const memo = new Array(n + 1).fill(-1);
  const go = (i) => {
    if (i < 0) return 0;                       // impossible
    if (i === 0) return 1;                     // the one empty way
    if (memo[i] !== -1) return memo[i];
    return memo[i] = go(i - 1) + go(i - 2);
  };
  return go(n);
};
```
]

#code(lang: "js", caption: "T2 — bottom-up table (SHIP this one)")[
```js
const climb = (n) => {
  const dp = new Array(n + 1).fill(0);         // never new Array(n) alone
  dp[0] = 1;                                   // counting base is 1, not 0
  for (let i = 1; i <= n; i++) {
    dp[i] = dp[i - 1];
    if (i >= 2) dp[i] += dp[i - 2];
  }
  return dp[n];
};
```
]

#code(lang: "js", caption: "T3 — 0/1 knapsack, one row, capacity loop BACKWARDS")[
```js
const knap01 = (w, v, cap) => {
  const dp = new Array(cap + 1).fill(0);
  for (let i = 0; i < w.length; i++)
    for (let c = cap; c >= w[i]; c--)          // BACKWARDS = each item once
      dp[c] = Math.max(dp[c], v[i] + dp[c - w[i]]);
  return dp[cap];
};
```
]

#code(lang: "js", caption: "T3' — unbounded knapsack: the same loop, FORWARDS")[
```js
const knapU = (w, v, cap) => {
  const dp = new Array(cap + 1).fill(0);
  for (let i = 0; i < w.length; i++)
    for (let c = w[i]; c <= cap; c++)          // FORWARDS = unlimited copies
      dp[c] = Math.max(dp[c], v[i] + dp[c - w[i]]);
  return dp[cap];
};
```
]

#trick[
One word is the whole difference. Run both on `w = [3,4]`, `v = [4,5]`, `cap = 8`:
backwards gives *9* (one of each), forwards gives *10* (two copies of item 1). Verified in
Node. Write the direction on your rough sheet before you write the loop.
]

#code(lang: "js", caption: "T4 — min-cost with an Infinity sentinel")[
```js
const coinMin = (coins, amt) => {
  const dp = new Array(amt + 1).fill(Infinity);
  dp[0] = 0;
  for (const c of coins)
    for (let x = c; x <= amt; x++) dp[x] = Math.min(dp[x], dp[x - c] + 1);
  return dp[amt] === Infinity ? -1 : dp[amt];
};
```
]

#code(lang: "js", caption: "T5 — take / skip in two variables, O(1) space")[
```js
const rob = (a) => {                           // no two neighbours
  let take = 0, skip = 0;
  for (const x of a) {
    const t = skip + x;
    skip = Math.max(skip, take);
    take = t;
  }
  return Math.max(take, skip);
};
```
]

#code(lang: "js", caption: "T6 — LIS in O(n log n) with the toolkit lowerBound")[
```js
const { lowerBound } = require('./toolkit.js');   // JS Toolkit appendix

const lis = (a) => {
  const tails = [];                            // tails[k] = smallest tail of
  for (const x of a) {                         // an increasing run of length k+1
    const i = lowerBound(tails, x);
    if (i === tails.length) tails.push(x); else tails[i] = x;
  }
  return tails.length;                         // LENGTH only — not the subsequence
};
```
]

#note[
All six were run in Node. `climb(5)` = `8`; `knap01([1,3,4,5],[1,4,5,7],7)` = `9`;
`coinMin([1,3,4],6)` = `2` and `coinMin([2],3)` = `-1`; `rob([2,7,9,3,1])` = `12`;
`lis([10,9,2,5,3,7,101,18])` = `4`. Empty input returns `0` in every one of them.
]

#subsection[When to reach for which]

#table(
  columns: (1.2fr, 0.9fr, auto),
  [*The question says*], [*Template*], [*Time*],
  [count the ways to reach step n], [T2, `+` combiner, `dp[0] = 1`], [$O(n)$],
  [minimum cost to reach the end], [T4, `Infinity` sentinel], [$O(n)$ or $O(n k)$],
  [pick items, no two neighbours], [T5], [$O(n)$],
  [same, but in a circle], [T5 twice: drop first, drop last], [$O(n)$],
  [fill a bag, each item once], [T3 — backwards], [$O(n W)$],
  [unlimited copies of each item], [T3' — forwards], [$O(n W)$],
  [exactly `cnt[i]` copies], [binary-split into powers of two, then T3], [$O(n W log "cnt")$],
  [split the array into two equal halves], [subset sum on `total/2` (T3, boolean)], [$O(n S)$],
  [smallest difference between two groups], [subset sum, then scan from the middle], [$O(n S)$],
  [count subsets with a given weight], [T3 with `+` instead of `max`], [$O(n S)$],
  [can this string be cut into dictionary words], [T2 over prefixes + a `Set`], [$O(n^2)$],
  [longest increasing subsequence], [T6 (or $O(n^2)$ T2 if n is small)], [$O(n log n)$],
  [weights up to $10^9$, values small], [index the table by *value*, not weight], [$O(n sum v)$],
  [max / min over a sliding window of states], [T2 + monotonic `Deque`], [$O(n)$],
)

#subsection[Complexity you should be able to quote]

#formulas(title: "The only DP cost formula")[
$ "time" = ("number of states") times ("work per state") $
$ "space" = ("number of states you must keep alive") $
]

#table(
  columns: (1.5fr, auto, auto),
  [*Problem*], [*Time*], [*Space*],
  [staircase / Fibonacci-shaped], [$O(n)$], [$O(1)$],
  [house robber, straight or circular], [$O(n)$], [$O(1)$],
  [frog with k jumps], [$O(n k)$], [$O(n)$],
  [coin change, min coins or count of ways], [$O(n A)$], [$O(A)$],
  [0/1 knapsack], [$O(n W)$], [$O(W)$],
  [unbounded knapsack], [$O(n W)$], [$O(W)$],
  [bounded knapsack (binary splitting)], [$O(n W log "cnt")$], [$O(W)$],
  [subset sum / equal partition], [$O(n S)$], [$O(S)$],
  [decode-ways / word-break], [$O(n)$ / $O(n^2)$], [$O(n)$],
  [LIS, table version], [$O(n^2)$], [$O(n)$],
  [LIS, tails + binary search], [$O(n log n)$], [$O(n)$],
  [knapsack indexed by value], [$O(n sum v)$], [$O(sum v)$],
)

`A` is the amount, `W` the capacity, `S` the target sum. None of these are polynomial in
the *input size* — they are polynomial in the *value* of a number in the input. That is
what "pseudo-polynomial" means, and interviewers ask for the word.

#subsection[Top traps, in the order they bite]

+ *`dp[0] = 0` in a counting DP.* There is exactly *one* way to make 0 — take nothing. Set
  `dp[0] = 1` or every answer collapses to 0.
+ *Knapsack loop direction.* Backwards for 0/1, forwards for unbounded. Forwards on a 0/1
  problem silently reuses an item and the answer comes out too large.
+ *`new Array(n)` without `.fill(0)`.* That is an array of *holes*. `map` skips holes, and
  `dp[i] += x` on a hole gives `NaN`.
+ *`new Array(3).fill(new Array(4).fill(0))`* stores *the same row three times*. Setting
  `grid[0][1] = 9` changes all three. Use
  `Array.from({ length: 3 }, () => new Array(4).fill(0))`.
+ *Recursion depth.* JavaScript gives you roughly $10^4$ frames. A top-down DP over
  $n = 10^5$ throws `RangeError: Maximum call stack size exceeded`. Write top-down to find
  the recurrence, then ship the loop.
+ *Counting past $2^53 - 1$.* Measured: `climb(77)` = `8944394323791464` is exact;
  `climb(79)` = `23416728348467684` is *wrong* by one. Take the answer modulo $10^9+7$, or
  switch the whole table to `BigInt`.
+ *A finite sentinel instead of `Infinity`.* A large finite number can be beaten by a real
  answer, or be relaxed by accident. `Infinity + cost` is still `Infinity`; it cannot be
  picked by a `Math.min` unless nothing else exists.
+ *Loop order in a counting DP.* Coins outside, amount inside counts *combinations*
  (`{1,2}` once). Amount outside, coins inside counts *permutations* (`1,2` and `2,1`
  separately). The question tells you which — read it twice.
+ *`tails` in the LIS template is not the LIS.* Only its length is meaningful. To recover
  the actual subsequence you must store predecessor indices as well.
+ *Forgetting the "no solution" check.* `dp[amt] === Infinity ? -1 : dp[amt]`. Without it
  you print `Infinity` and lose the mark.
+ *A plain array with `shift()` as a deque* in a windowed DP. `shift()` is $O(n)$ worst
  case and turns an $O(n)$ DP back into $O(n^2)$. Use the toolkit `Deque`.

#subsection[The 30-second checklist before you code]

+ What is the state? Name it in one sentence: "`dp[i]` is the best answer using the first
  `i` items."
+ What is the base case, and is it `0` or `1`?
+ Optimisation or counting? That fixes the combiner: `Math.max`/`Math.min` or `+`.
+ Which earlier states does `dp[i]` read? That fixes the loop order.
+ Number of states times work per state — is that under $10^8$?
+ Can the answer pass $2^53 - 1$? If yes, modulo or `BigInt` from the start.
+ Does the table only read the previous row? Then collapse it to one row.
]

]
