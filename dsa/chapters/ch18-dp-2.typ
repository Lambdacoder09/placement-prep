#import "../../shared/lib/style.typ": *

#chapter(num: 18, title: "Dynamic Programming II — 2D, Strings, Trees & Bitmask",
  tagline: "Same recipe, bigger state")[

#section[Pattern in one page]

Chapter 17 had one moving index. This chapter has two, or three, or a whole set. Nothing
about the method changes — only the *shape of the state*.

#formulas(title: "The same three questions, every time")[
+ *State* — the changing arguments of the brute-force recursion.
+ *Transition* — how a bigger state is built from smaller ones.
+ *Base case* — the states you know for free.

Then: memo → table → shrink the memory.
]

#subsection[The five state shapes in this chapter]

#table(columns: (0.9fr, 1.1fr, 1.1fr, 1fr),
  [*Shape*], [*State*], [*Typical size*], [*Example*],
  [Grid], [`dp[i][j]` = cell], [$m n$], [count paths, min path sum],
  [Two strings], [`dp[i][j]` = prefixes], [$n m$], [LCS, edit distance],
  [One string, interval], [`dp[i][j]` = the piece `i..j`], [$n^2$, work $O(n)$], [palindrome cuts, matrix chain],
  [Tree], [`dp[u][0/1]` = subtree of `u`], [$n$], [robber on a tree],
  [Subsets], [`dp[mask]`], [$2^n$], [assignment, TSP],
)

#subsection[Template 1 — grid]

#code(lang: "js", caption: "Grid DP, one row of memory")[
```js
const row = new Array(n).fill(1);
for (let i = 1; i < m; i++)
  for (let j = 1; j < n; j++)
    row[j] += row[j-1];        // row[j] is still row i-1; row[j-1] is already row i
return row[n-1];
```
]

#note[Read the rolling-row trick carefully. When the loop reaches `row[j]`, that cell still
holds the value from *the previous row* (it has not been written yet this pass), while
`row[j-1]` was already updated *this row*. So `row[j] += row[j-1]` is exactly
`dp[i][j] = dp[i-1][j] + dp[i][j-1]`. No extra array is needed.]

#subsection[Template 2 — two strings]

#code(lang: "js", caption: "The LCS / edit-distance skeleton")[
```js
const dp = Array.from({ length: n+1 }, () => new Array(m+1).fill(0));
for (let i = 1; i <= n; i++)
  for (let j = 1; j <= m; j++)
    if (a[i-1] === b[j-1]) dp[i][j] = dp[i-1][j-1] + 1;        // characters agree
    else                   dp[i][j] = Math.max(dp[i-1][j], dp[i][j-1]);
```
]

#trap[
*Build a 2D table with `Array.from`, never with `fill`.*
`new Array(n+1).fill(new Array(m+1).fill(0))` puts the *same* row object in all $n+1$
slots, so `dp[3][2] = 5` writes row 0, row 1 and every other row at once. The code runs and
the numbers are quietly wrong. `Array.from({ length: n+1 }, () => new Array(m+1).fill(0))`
calls the factory once per row.

The same rule governs copying: `[...grid]` shares every row. A real 2D copy is
`grid.map(r => [...r])`. Every table in this chapter is built with `Array.from`.
]

#note[
Indexing a JavaScript string with `a[i-1]` gives a *one-character string*, and `===`
compares those by value — so `a[i-1] === b[j-1]` is exactly the character comparison you
want. There is no `char` type and no need for `charCodeAt` unless you are doing arithmetic
on letters.
]

#trap[Index shift. `dp[i][j]` talks about the *first `i`* characters, so the character is
`a[i-1]`, not `a[i]`. Mixing these two up is the number-one 2D DP bug. Pick the
`i` means "count of characters" convention and never change it.]

#subsection[Template 3 — interval (partition) DP]

Used when you must *split a sequence at some point `k`* and the cost of the split depends
on the whole piece.

#code(lang: "js", caption: "Interval DP skeleton — always loop by LENGTH")[
```js
for (let len = 2; len <= n; len++)
  for (let i = 0; i + len - 1 < n; i++) {
    const j = i + len - 1;
    dp[i][j] = Infinity;
    for (let k = i; k < j; k++)
      dp[i][j] = Math.min(dp[i][j], dp[i][k] + dp[k+1][j] + costOfJoining(i, k, j));
  }
```
]

#note[
`Infinity` replaces `INT_MAX` throughout this chapter. It is a real number in JavaScript:
`Math.min(Infinity, 5)` is `5`, `Infinity + 1` is `Infinity`, and no sentinel can ever
overflow into a smaller value the way `INT_MAX + 1` does in C++. Use `-Infinity` for a
"smallest so far" accumulator.
]

#trick[Why loop by length? Because `dp[i][j]` needs `dp[i][k]` and `dp[k+1][j]`, and both
are *shorter* intervals. Going by length guarantees every shorter interval is already
finished. Looping `i` then `j` in the usual order does not.]

#subsection[Template 4 — tree DP]

A tree has no cycles, so "the answer for a subtree" is well defined. Do one DFS and return
the numbers the parent needs.

#code(lang: "js", caption: "Tree DP skeleton — return a pair, one value per situation")[
```js
const dfs = (u) => {
  let withU = val[u], withoutU = 0;
  for (const v of children[u]) {
    const [t, s] = dfs(v);            // destructure the pair the child returned
    withU    += s;                    // if u is taken, children must be skipped
    withoutU += Math.max(t, s);       // if u is skipped, children are free
  }
  return [withU, withoutU];
};
```
]

#trap[
*Node's call stack is about $10^4$ frames deep — far shallower than C++ or Java.* Every
tree DP in this chapter recurses once per node, and the constraints say $n <= 10^5$. A tree
that is one long chain of 100000 nodes makes this `dfs` throw
`RangeError: Maximum call stack size exceeded`; that was run, not guessed.

The fix is an explicit stack: push `[node, childIndex]` frames, do the child work on the
way down, and combine on the way up. Say this out loud before you write the recursive
version — "recursive here for clarity; on a $10^5$ chain I would convert it to an iterative
post-order" — and you have answered the follow-up before it is asked.
]

#subsection[Template 5 — bitmask DP]

When $n <= 20$ and the state is "which items are already used", the state is a bitmask.

JavaScript has no `__builtin_popcount`, so write the two-line Kernighan loop once and
reuse it. `m &= m - 1` clears the lowest set bit, so the loop runs once per set bit.

#code(lang: "js", caption: "Bitmask skeleton — fill positions in a fixed order")[
```js
const popcount = (m) => { let c = 0; while (m) { m &= m - 1; c++; } return c; };

const dp = new Array(1 << n).fill(Infinity);
dp[0] = 0;
for (let mask = 0; mask < (1 << n); mask++) {
  if (dp[mask] === Infinity) continue;
  const i = popcount(mask);                  // the next slot to fill
  if (i === n) continue;
  for (let j = 0; j < n; j++)
    if (!(mask & (1 << j)))
      dp[mask | (1 << j)] = Math.min(dp[mask | (1 << j)], dp[mask] + cost[i][j]);
}
```
]

#trap[
*JavaScript bitwise operators work on 32-bit signed integers*, even though numbers are
doubles. `1 << 31` is negative and `1 << 32` is `1`, not $2^32$. This chapter caps masks at
$n <= 18$, so `1 << n` is at most 262144 and everything is safe — but if a problem ever
pushes past 31 bits, bit operations stop working and you need `BigInt` or a pair of masks.
Say the limit out loud; it is a favourite follow-up.
]

#formulas(title: "Bit tricks you will need")[
- `mask & (1 << j)` — is item `j` in the set?
- `mask | (1 << j)` — add item `j`
- `mask ^ (1 << j)` — flip item `j`
- `mask & -mask` — the lowest set bit, on its own
- `popcount(mask)` — how many bits are set (the Kernighan loop above; JavaScript has no built-in)
- `31 - Math.clz32(lowBit)` — index of the lowest set bit, the `__builtin_ctz` of other languages
- loop over all sub-sets of `mask`: `for (let s = mask; s; s = (s-1) & mask)`

All verified: `popcount(0b1011)` is 3, `popcount(0)` is 0, `31 - Math.clz32(0b1000)` is 3,
and the sub-set loop over `0b1011` yields exactly its 7 non-empty subsets.
]

#subsection[Choosing the shape from the question]

#table(columns: (1.3fr, 1fr, 1fr),
  [*The question says...*], [*Shape*], [*Cost*],
  [move only right/down on a grid], [grid], [$O(m n)$],
  [compare / align two sequences], [two strings], [$O(n m)$],
  [insert brackets, cut, merge, burst], [interval], [$O(n^3)$],
  [subtree, parent, child, no two adjacent nodes], [tree], [$O(n)$],
  [$n <= 20$ and "assign each to each"], [bitmask], [$O(2^n n)$ or $O(2^n n^2)$],
  [$n <= 20$ and "split into groups"], [bitmask + submask], [$O(3^n)$],
)

#note[$3^n$ comes from summing $2^(|"mask"|)$ over all masks. For $n = 15$ that is about
14 million — fine. For $n = 20$ it is 3.5 billion — too slow.]

#pagebreak(weak: true)

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
A robot starts at the top-left of an $m times n$ grid and may move only right or down. How
many paths reach the bottom-right? $1 <= m, n <= 18$.
Edge cases: a single row; a single cell; a zero-sized grid.

#sol[
To stand on cell $(i, j)$ the robot arrived from above or from the left.
$ "dp"[i][j] = "dp"[i-1][j] + "dp"[i][j-1] $
The whole first row and first column are 1 — there is only one way along an edge.

#code(lang: "js", caption: "uniquePaths — one row of memory")[
```js
const uniquePaths = (m, n) => {
  if (m <= 0 || n <= 0) return 0;
  const row = new Array(n).fill(1);
  for (let i = 1; i < m; i++)
    for (let j = 1; j < n; j++)
      row[j] += row[j-1];
  return row[n-1];
};
```
]

Outputs: `(3,7)` → 28; `(3,2)` → 3; `(1,1)` → 1; `(1,10)` → 1; `(0,5)` → 0; `(2,2)` → 2;
`(17,17)` → 601080390.

#complexity(time: $O(m n)$, space: $O(n)$)

#ans[28.]
]
]

#trap[
*Counting DP is where JavaScript numbers run out.* There is no `int` to overflow — numbers
are doubles, exact only to `Number.MAX_SAFE_INTEGER` $= 2^53 - 1 approx 9.0 times 10^15$.
Everything was measured:

#table(columns: (auto, auto, 1fr),
  [`uniquePaths(17,17)`], [`601080390`],        [exact],
  [`uniquePaths(29,29)`], [`7648690600760440`], [exact, still a safe integer],
  [`uniquePaths(32,32)`], [`465428353255261060`], [*wrong* — the true value is `465428353255261088`],
)

Past that line the answer is `BigInt`: seed with `new Array(n).fill(1n)` and the identical
loop is exact at any size. The cost is roughly a 10x slowdown and the rule that `BigInt`
and `Number` never mix in one expression — `1n + 1` throws a `TypeError`.

Most problems dodge the issue by asking for the count *modulo* $10^9+7$. That makes
*addition* safe, because two residues sum to under $2 times 10^9$. It does *not* make
multiplication safe: `(999999937 * 999999893) % (10^9+7)` gives `8023` in plain numbers and
`7980` with `BigInt` — the plain answer is simply wrong, because the product is about
$10^18$. A modular DP that multiplies needs `BigInt` for the multiply, or a modulus small
enough that the product stays under $2^53$ (the `1003` used later in this chapter is such
a modulus: `1002 * 1002 * 4` is tiny).
]

#ex(2, tier: 0, asked: "warm-up")[
Same grid, but some cells hold a wall (`1`). Walls cannot be entered. Count the paths.
Edge cases: the start cell is a wall; the finish cell is a wall; a full row of walls.

#sol[
One extra rule: a wall cell has *zero* ways.

#code(lang: "js", caption: "pathsWithObstacles")[
```js
const pathsWithObstacles = (g) => {
  const m = g.length; if (!m) return 0;
  const n = g[0].length; if (!n) return 0;
  const dp = new Array(n).fill(0);
  dp[0] = g[0][0] === 1 ? 0 : 1;
  for (let i = 0; i < m; i++)
    for (let j = 0; j < n; j++) {
      if (g[i][j] === 1) { dp[j] = 0; continue; }
      if (j > 0) dp[j] += dp[j-1];
    }
  return dp[n-1];
};
```
]

Outputs:

#table(columns: (2.2fr, 0.7fr, 2fr),
  [*grid*], [*paths*], [*note*],
  [`[[0,0,0],[0,1,0],[0,0,0]]`], [2], [wall in the middle],
  [`[[0,1],[0,0]]`], [1], [only down-then-right],
  [`[[1]]`], [0], [start is a wall],
  [`[[0]]`], [1], [start = finish],
  [`[[0,0],[1,1],[0,0]]`], [0], [a full wall row blocks every route],
  [`[]` (no rows)], [0], [],
)

#complexity(time: $O(m n)$, space: $O(n)$)

#ans[2.]
]
]

#ex(3, tier: 0, asked: "warm-up")[
Each cell of the grid holds a non-negative cost. Moving only right or down, find the
cheapest path from top-left to bottom-right.
Edge cases: single cell; single row; single column.

#sol[
$ "dp"[i][j] = g[i][j] + min("dp"[i-1][j], "dp"[i][j-1]) $

Using one rolling row, `dp[j]` is the cell above and `dp[j-1]` is the cell to the left.

#code(lang: "js", caption: "minPathSum")[
```js
const minPathSum = (g) => {
  const m = g.length; if (!m) return 0;
  const n = g[0].length; if (!n) return 0;
  const dp = new Array(n).fill(Infinity);
  dp[0] = 0;
  for (let i = 0; i < m; i++)
    for (let j = 0; j < n; j++) {
      if (j > 0) dp[j] = Math.min(dp[j], dp[j-1]);
      dp[j] += g[i][j];
    }
  return dp[n-1];
};
```
]

Outputs: `[[1,3,1],[1,5,1],[4,2,1]]` → 7; `[[5]]` → 5; `[[1,2,3]]` → 6; `[[1],[2],[3]]` → 6;
`[]` → 0.

#complexity(time: $O(m n)$, space: $O(n)$)

#ans[7 — the path $1 → 3 → 1 → 1 → 1$.]
]
]

#trap[Re-setting `dp[0] = Infinity` at the start of each row would be wrong for column 0,
where there is no "left". The code sets `dp[0] = 0` once, *before* the loop, and never
touches `dp[j-1]` when `j === 0`. Check that guard exists in your own version — and note
that `Infinity + 5` is still `Infinity`, so a missing guard shows up as an `Infinity`
answer rather than as a wrapped-around negative number. That is a mercy: the bug is
visible.]

#ex(4, tier: 0, asked: "warm-up")[
A triangle of numbers: row `i` has `i+1` entries. From entry `j` of row `i` you move to
entry `j` or `j+1` of row `i+1`. Find the smallest top-to-bottom sum.
Edge cases: one row; negative numbers; empty triangle.

#sol[
Going *bottom-up* removes all boundary checks, because the last row is the answer for
itself.

$ "dp"[j] = t[i][j] + min("dp"[j], "dp"[j+1]) $

#code(lang: "js", caption: "triangleMin")[
```js
const triangleMin = (t) => {
  const m = t.length; if (!m) return 0;
  const dp = [...t[m-1]];                  // COPY the last row, do not alias it
  for (let i = m - 2; i >= 0; i--)
    for (let j = 0; j <= i; j++)
      dp[j] = t[i][j] + Math.min(dp[j], dp[j+1]);
  return dp[0];
};
```
]

Outputs: `[[2],[3,4],[6,5,7],[4,1,8,3]]` → 11; `[[-10]]` → $-10$; `[]` → 0;
`[[1],[2,3]]` → 3; `[[-1],[2,3],[1,-1,-3]]` → $-1$.

#trap[
`const dp = t[m-1]` would not copy anything — it would make `dp` *another name for* the
caller's last row, and the loop would overwrite the caller's data. The `[...t[m-1]]` spread
is what makes this function safe to call twice. A test confirms the caller's triangle comes
back unchanged.
]

#complexity(time: $O(n^2)$, space: $O(n)$)

#ans[11 — the path $2 → 3 → 5 → 1$.]
]
]

#trick[Top-down needs "what if `j-1` does not exist" checks at both edges. Bottom-up needs
none, because `dp[j]` and `dp[j+1]` always exist in the row below. When a grid or triangle
DP feels fiddly, try reversing the direction first.]

#ex(5, tier: 0, asked: "warm-up")[
Is string `s` a subsequence of string `t`? $|s|, |t| <= 10^5$.
Edge cases: empty `s`; empty `t`; `s` longer than `t`.

#sol[
The DP table for this is $O(n m)$, but the DP collapses to a single pointer: scan `t` once
and advance a pointer into `s` on every match.

#code(lang: "js", caption: "isSubsequence")[
```js
const isSubsequence = (s, t) => {
  let i = 0;
  for (const ch of t) if (i < s.length && s[i] === ch) i++;
  return i === s.length;
};
```
]

Outputs: `("abc","ahbgdc")` → true; `("axc","ahbgdc")` → false; `("","xyz")` → true;
`("a","")` → false; `("aaa","aa")` → false; `("aa","aaa")` → true.

#complexity(time: $O(|t|)$, space: $O(1)$)

#ans[true.]
]
]

#note[The empty string is a subsequence of everything — the loop ends with
`i === 0 === s.length`. That matches `dp[0][j] = true`, the base case you would write in
the table version. The two views always agree.

`for (const ch of t)` iterates a string by *code point*, so an emoji or an accented
character arrives as one unit rather than as two surrogate halves. `t[i]` would split them.
For ASCII interview inputs the two are identical; say the difference if asked about
Unicode.]

#ex(6, tier: 0, asked: "warm-up")[
A rooted tree is given as a list of children. Find its height (edges on the longest
root-to-leaf path). Edge cases: a single node (height 0); a straight chain.

#sol[
The smallest "subproblem" of a tree is a subtree.

$ "height"(u) = cases(0 & "if " u "has no children", 1 + max_(v in "children"(u)) "height"(v) & "otherwise") $

#code(lang: "js", caption: "heightOf")[
```js
const heightOf = (u, ch) => {
  let best = 0;
  for (const v of ch[u]) best = Math.max(best, heightOf(v, ch) + 1);
  return best;
};
```
]

Tested on the tree `0 → 1, 2`; `1 → 3, 4`; `4 → 5`: height *3*.
A single node: 0. A chain `0 → 1 → 2 → 3`: 3.

#complexity(time: $O(n)$, space: $O(h)$, note: "h = recursion depth. In Node the stack gives out near 10^4, so a 10^5 chain needs an explicit stack.")

#ans[3.]
]
]

#pagebreak(weak: true)

#section[Tier 1 — the standard set]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
Count the right/down paths in an $m times n$ grid, with the *full ladder* from naive
recursion to the best version. $1 <= m, n <= 18$.

#sol[
#approach(1, "Plain recursion", verdict: "O(2^(m+n)) — dies around m = n = 15")

#code(lang: "js", caption: "Approach 1")[
```js
const pathsBrute = (i, j, m, n) => {
  if (i === m-1 && j === n-1) return 1;
  if (i >= m || j >= n) return 0;
  return pathsBrute(i+1, j, m, n) + pathsBrute(i, j+1, m, n);
};
```
]
#complexity(time: $O(2^(m+n))$, space: $O(m+n)$)

#approach(2, "Memo on (i, j)", verdict: "O(mn)")

#code(lang: "js", caption: "Approach 2")[
```js
const pathsMemo = (m, n) => {
  if (m <= 0 || n <= 0) return 0;
  const memo = Array.from({ length: m }, () => new Array(n).fill(-1));
  const go = (i, j) => {                      // closure: m, n, memo are already in scope
    if (i === m-1 && j === n-1) return 1;
    if (i >= m || j >= n) return 0;
    if (memo[i][j] !== -1) return memo[i][j];
    return memo[i][j] = go(i+1, j) + go(i, j+1);
  };
  return go(0, 0);
};
```
]

#trick[
Defining `go` *inside* `pathsMemo` is the idiomatic JavaScript memo. The inner arrow
function closes over `m`, `n` and `memo`, so the recursion carries two arguments instead of
five, and the table cannot leak between calls the way a module-level cache would. Use a
`Map` keyed by `` `${i},${j}` `` only when the state is not a small pair of integers — an
array of arrays is far faster when it is.
]
#complexity(time: $O(m n)$, space: $O(m n)$)

#approach(3, "Full 2D table", verdict: "O(mn), no recursion")

#code(lang: "js", caption: "Approach 3")[
```js
const pathsTable = (m, n) => {
  if (m <= 0 || n <= 0) return 0;
  const dp = Array.from({ length: m }, () => new Array(n).fill(0));
  for (let i = 0; i < m; i++)
    for (let j = 0; j < n; j++) {
      if (i === 0 && j === 0) { dp[i][j] = 1; continue; }
      const up   = i > 0 ? dp[i-1][j] : 0;
      const left = j > 0 ? dp[i][j-1] : 0;
      dp[i][j] = up + left;
    }
  return dp[m-1][n-1];
};
```
]
#complexity(time: $O(m n)$, space: $O(m n)$)

#approach(4, "One rolling row", verdict: "O(mn) time, O(n) space — optimal")

#code(lang: "js", caption: "Approach 4")[
```js
const pathsRow = (m, n) => {
  if (m <= 0 || n <= 0) return 0;
  const row = new Array(n).fill(1);
  for (let i = 1; i < m; i++)
    for (let j = 1; j < n; j++)
      row[j] += row[j-1];
  return row[n-1];
};
```
]
#complexity(time: $O(m n)$, space: $O(n)$)

All four agree. The $4 times 4$ block of answers (rows $m = 1..4$, columns $n = 1..4$):

```
1  1  1  1
1  2  3  4
1  3  6 10
1  4 10 20
```

and `pathsMemo(3,7) = 28`, `pathsRow(17,17) = 601080390`, `pathsRow(0,3) = 0`.
All four were also compared cell by cell for every $m, n$ from 0 to 8: zero mismatches.

#ans[*The idea that unlocked it:* only `(i, j)` changes in the recursion, so there are at
most $m n$ distinct calls. Everything past that was duplicated work.]
]
]

#note[Those numbers are Pascal's triangle — the answer also equals
$binom(m+n-2, m-1)$. Say that in an interview, then add: "but the DP version generalises to
obstacles and costs, and the formula does not." That is the real reason to know the DP.]

#ex(8, tier: 1, asked: "Infosys · pattern")[
A grid of numbers. Start anywhere in the top row, and from `(i, j)` fall to `(i+1, j-1)`,
`(i+1, j)` or `(i+1, j+1)`. Maximise the sum collected.
$1 <= m, n <= 500$. Edge cases: one row; one column; all negative.

#sol[
The state is the cell; the transition looks at three cells above.

$ "dp"[i][j] = g[i][j] + max("dp"[i-1][j-1], "dp"[i-1][j], "dp"[i-1][j+1]) $

Answer: the maximum over the last row — *not* `dp[m-1][n-1]`.

#code(lang: "js", caption: "maxFallingPath — two rows of memory")[
```js
const maxFallingPath = (g) => {
  const m = g.length; if (!m) return 0;
  const n = g[0].length; if (!n) return 0;
  let prev = [...g[0]], cur = new Array(n).fill(0);
  for (let i = 1; i < m; i++) {
    for (let j = 0; j < n; j++) {
      let best = prev[j];
      if (j > 0)     best = Math.max(best, prev[j-1]);
      if (j < n - 1) best = Math.max(best, prev[j+1]);
      cur[j] = g[i][j] + best;
    }
    [prev, cur] = [cur, prev];              // swap the two row references, no copying
  }
  return prev.reduce((a, b) => a > b ? a : b);
};
```
]

Outputs: `[[1,2,3],[4,5,6],[7,8,9]]` → 18; `[[-1,-2],[-3,-4]]` → $-4$; `[[5]]` → 5;
`[]` → 0; `[[2,1,3],[6,5,4],[7,8,9]]` → 17. The caller's grid comes back untouched.

#trick[
`[prev, cur] = [cur, prev]` is JavaScript's `swap`. It rebinds two *references* — no array
is copied — so it is $O(1)$ however wide the row is. It needs `let`, not `const`, and it
needs the rows to be separate arrays, which is why `prev` starts as `[...g[0]]` and not as
`g[0]`.
]

#trap[
`prev.reduce((a, b) => a > b ? a : b)` rather than `Math.max(...prev)`. The spread form
passes every element as a separate argument and throws
`RangeError: Maximum call stack size exceeded` somewhere past $10^5$ entries. `reduce` has
no such limit.
]

#complexity(time: $O(m n)$, space: $O(n)$)

#ans[18 — the path $3 → 6 → 9$.]
]
]

#trap[`[[-1,-2],[-3,-4]]` gives $-4$, not 0. You *must* fall all the way down; there is no
"stop early" option. If your code initialises `best = 0` you will silently allow skipping.]

#ex(9, tier: 1, asked: "Accenture · pattern")[
*Longest Common Subsequence.* Find the length of the longest subsequence present in both
strings, then print one such subsequence. $1 <= n, m <= 1000$.
Edge cases: no common character; identical strings; empty string.

#sol[
#approach(1, "Recursion from the two ends", verdict: "O(2^(n+m))")

Compare the last characters. If they match, both must be in the LCS (there is never a
reason to drop a matching pair). If not, throw away one of them and take the better result.

#code(lang: "js", caption: "Approach 1")[
```js
const lcsBrute = (a, b, i, j) => {
  if (i < 0 || j < 0) return 0;
  if (a[i] === b[j]) return 1 + lcsBrute(a, b, i-1, j-1);
  return Math.max(lcsBrute(a, b, i-1, j), lcsBrute(a, b, i, j-1));
};
```
]
#complexity(time: $O(2^(n+m))$, space: $O(n+m)$)

#approach(3, "2D table", verdict: "O(nm) — the standard answer")

#code(lang: "js", caption: "Approach 3 — dp[i][j] uses the FIRST i and FIRST j characters")[
```js
const lcsTable = (a, b) => {
  const n = a.length, m = b.length;
  const dp = Array.from({ length: n+1 }, () => new Array(m+1).fill(0));
  for (let i = 1; i <= n; i++)
    for (let j = 1; j <= m; j++)
      dp[i][j] = a[i-1] === b[j-1] ? dp[i-1][j-1] + 1
                                   : Math.max(dp[i-1][j], dp[i][j-1]);
  return dp[n][m];
};
```
]
#complexity(time: $O(n m)$, space: $O(n m)$)

#approach(4, "Two rows", verdict: "O(nm) time, O(m) space")

#code(lang: "js", caption: "Approach 4")[
```js
const lcsTwoRows = (a, b) => {
  const n = a.length, m = b.length;
  let prev = new Array(m+1).fill(0), cur = new Array(m+1).fill(0);
  for (let i = 1; i <= n; i++) {
    for (let j = 1; j <= m; j++)
      cur[j] = a[i-1] === b[j-1] ? prev[j-1] + 1 : Math.max(prev[j], cur[j-1]);
    [prev, cur] = [cur, prev];
  }
  return prev[m];
};
```
]
#complexity(time: $O(n m)$, space: $O(m)$)

To *print* the subsequence you need the full table — walk backwards from `dp[n][m]`.

#code(lang: "js", caption: "lcsString — backtracking through the table")[
```js
const lcsString = (a, b) => {
  const n = a.length, m = b.length;
  const dp = Array.from({ length: n+1 }, () => new Array(m+1).fill(0));
  for (let i = 1; i <= n; i++)
    for (let j = 1; j <= m; j++)
      dp[i][j] = a[i-1] === b[j-1] ? dp[i-1][j-1] + 1 : Math.max(dp[i-1][j], dp[i][j-1]);
  const out = [];                          // collect into an ARRAY, join at the end
  let i = n, j = m;
  while (i > 0 && j > 0) {
    if (a[i-1] === b[j-1]) { out.push(a[i-1]); i--; j--; }
    else if (dp[i-1][j] >= dp[i][j-1]) i--;
    else j--;
  }
  return out.reverse().join('');
};
```
]

#trap[
*JavaScript strings are immutable.* `out += ch` in a loop allocates a fresh string every
time, so building an $n$-character answer one character at a time is $O(n^2)$ in the worst
case. Push the characters into an array and `join('')` once. For the same reason, reversing
a string is `[...s].reverse().join('')` — there is no `s.reverse()`.
]

Outputs:

#table(columns: (1fr, 1fr, 0.5fr, 1fr),
  [*a*], [*b*], [*len*], [*one LCS*],
  [`abcde`], [`ace`], [3], [`ace`],
  [`abc`], [`abc`], [3], [`abc`],
  [`abc`], [`def`], [0], [(empty)],
  [`''`], [`abc`], [0], [(empty)],
  [`aggtab`], [`gxtxayb`], [4], [`gtab`],
  [`aaaa`], [`aa`], [2], [`aa`],
)

All three versions agree on every row above, and `lcsBrute` agrees on the small ones.

#ans[3 for `abcde` / `ace`.]
]
]

#code(lang: "python", caption: "lcs — Python, two rows")[
```python
def lcs(a, b):
    n, m = len(a), len(b)
    prev = [0] * (m + 1)
    for i in range(1, n + 1):
        cur = [0] * (m + 1)
        for j in range(1, m + 1):
            if a[i-1] == b[j-1]:
                cur[j] = prev[j-1] + 1
            else:
                cur[j] = max(prev[j], cur[j-1])
        prev = cur
    return prev[m]
```
]

Output: `3 0 0 4` for `("abcde","ace")`, `("abc","def")`, `("","abc")`,
`("aggtab","gxtxayb")`.

#trap[If the characters match, do *not* also try `Math.max(dp[i-1][j], dp[i][j-1])`. It
cannot help, and adding it makes people think the match case is optional. It is not: there
is always an optimal LCS that uses a matching pair of last characters.]

#ex(10, tier: 1, asked: "Wipro · pattern")[
*Longest Common Substring* — the pieces must now be *contiguous*.
$1 <= n, m <= 1000$. Edge cases: no common character; one string empty; repeated letters.

#sol[
The state is the same, but the meaning changes, and that changes everything.

`dp[i][j]` = length of the longest common *suffix* of `a[0..i-1]` and `b[0..j-1]`.

- characters match → `dp[i][j] = dp[i-1][j-1] + 1`
- characters differ → `dp[i][j] = 0` *(the run is broken)*

The answer is the maximum cell, not the corner cell.

#code(lang: "js", caption: "longestCommonSubstring")[
```js
const longestCommonSubstring = (a, b) => {
  const n = a.length, m = b.length;
  const dp = Array.from({ length: n+1 }, () => new Array(m+1).fill(0));
  let best = 0;
  for (let i = 1; i <= n; i++)
    for (let j = 1; j <= m; j++)
      if (a[i-1] === b[j-1]) { dp[i][j] = dp[i-1][j-1] + 1; best = Math.max(best, dp[i][j]); }
      else dp[i][j] = 0;
  return best;
};
```
]

Outputs: `('abcdxyz','xyzabcd')` → 4; `('abcde','ace')` → 1; `('','abc')` → 0;
`('a','a')` → 1; `('aaaa','aa')` → 2; `('abc','xyz')` → 0.

#complexity(time: $O(n m)$, space: $O(n m)$, note: "two rows give O(m) if you only need the length")

#ans[4 — `abcd`.]
]
]

#trick[Subsequence vs substring, in one line:
*subsequence* → on mismatch take `Math.max` of the neighbours (the run may skip);
*substring* → on mismatch write `0` (the run must restart).
The rest of the code is identical.]

#ex(11, tier: 1, asked: "Capgemini · pattern")[
*Edit distance.* The fewest single-character insert / delete / replace operations that turn
`a` into `b`. $1 <= n, m <= 1000$. Edge cases: one string empty; identical strings;
two swapped letters.

#sol[
#approach(1, "Recursion on the two prefix lengths", verdict: "O(3^n)")

#code(lang: "js", caption: "Approach 1")[
```js
const edBrute = (a, b, i, j) => {
  if (i === 0) return j;                // insert the rest of b
  if (j === 0) return i;                // delete the rest of a
  if (a[i-1] === b[j-1]) return edBrute(a, b, i-1, j-1);
  return 1 + Math.min(edBrute(a,b,i-1,j), edBrute(a,b,i,j-1), edBrute(a,b,i-1,j-1));
};
```
]

#note[
`Math.min` takes any number of arguments, so C++'s `min({x, y, z})` is simply
`Math.min(x, y, z)`. Beware only the array form: `Math.min(...arr)` spreads and hits the
argument-count limit on a long array. Three named values are always fine.
]
#complexity(time: $O(3^(n+m))$, space: $O(n+m)$)

#approach(3, "2D table", verdict: "O(nm) — the standard answer")

Read the three options as *operations on the last character*:

#table(columns: (1fr, 1.4fr, 1.6fr),
  [*term*], [*operation*], [*meaning*],
  [`dp[i-1][j] + 1`], [delete `a[i-1]`], [drop one char of `a`],
  [`dp[i][j-1] + 1`], [insert `b[j-1]`], [add one char to `a`],
  [`dp[i-1][j-1] + 1`], [replace `a[i-1]` by `b[j-1]`], [swap one char],
  [`dp[i-1][j-1]`], [nothing], [only when the characters already match],
)

#code(lang: "js", caption: "editDistance")[
```js
const editDistance = (a, b) => {
  const n = a.length, m = b.length;
  const dp = Array.from({ length: n+1 }, () => new Array(m+1).fill(0));
  for (let i = 0; i <= n; i++) dp[i][0] = i;
  for (let j = 0; j <= m; j++) dp[0][j] = j;
  for (let i = 1; i <= n; i++)
    for (let j = 1; j <= m; j++)
      dp[i][j] = a[i-1] === b[j-1] ? dp[i-1][j-1]
               : 1 + Math.min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1]);
  return dp[n][m];
};
```
]
#complexity(time: $O(n m)$, space: $O(n m)$)

#approach(4, "Two rows", verdict: "O(nm) time, O(m) space — optimal")

#code(lang: "js", caption: "editTwoRows")[
```js
const editTwoRows = (a, b) => {
  const n = a.length, m = b.length;
  let prev = Array.from({ length: m+1 }, (_, j) => j);   // base row: 0, 1, 2, ...
  let cur = new Array(m+1).fill(0);
  for (let i = 1; i <= n; i++) {
    cur[0] = i;                                         // base case for this row
    for (let j = 1; j <= m; j++)
      cur[j] = a[i-1] === b[j-1] ? prev[j-1]
             : 1 + Math.min(prev[j], cur[j-1], prev[j-1]);
    [prev, cur] = [cur, prev];
  }
  return prev[m];
};
```
]

#trick[
`Array.from({ length: m+1 }, (_, j) => j)` is the JavaScript way to write "0, 1, 2, ...".
The second argument is a map function that receives the index — the same mechanism that
makes `Array.from({ length: n }, () => [])` the correct way to build $n$ distinct rows.
]
#complexity(time: $O(n m)$, space: $O(m)$)

Outputs: `('horse','ros')` → 3 from all three versions; `('kitten','sitting')` → 3;
`('','abc')` → 3; `('abc','')` → 3; `('','')` → 0; `('same','same')` → 0;
`('ab','ba')` → 2. A randomised comparison of the three versions on 200 random string
pairs reported `200 random cross-checks passed`.

#ans[3 for `horse` → `ros`: replace `h`→`r`, delete `r`, delete `e`.]
]
]

#code(lang: "python", caption: "edit_distance — Python, two rows")[
```python
def edit_distance(a, b):
    n, m = len(a), len(b)
    prev = list(range(m + 1))
    for i in range(1, n + 1):
        cur = [i] + [0] * m
        for j in range(1, m + 1):
            if a[i-1] == b[j-1]:
                cur[j] = prev[j-1]
            else:
                cur[j] = 1 + min(prev[j], cur[j-1], prev[j-1])
        prev = cur
    return prev[m]
```
]

Output: `3 3` and `3 3 0` for the cases above.

#trap[`cur[0] = i` must be written *inside* the `i` loop, before the `j` loop. It is the
base case "turning the first `i` characters of `a` into the empty string costs `i`
deletions". Forgetting it leaves stale data from two rows ago — and because
`[prev, cur] = [cur, prev]` *reuses* the same two arrays rather than allocating fresh ones,
that stale data really is there waiting for you.]

#ex(12, tier: 1, asked: "Cognizant · pattern")[
*Longest palindromic subsequence.* $1 <= n <= 1000$.
Edge cases: empty string; all identical letters; a string with no repeats.

#sol[
The insight is one line: *a palindromic subsequence of `s` is a common subsequence of `s`
and `reverse(s)`.*

Reading a palindrome forwards and backwards gives the same letters, so every palindromic
subsequence appears in both. And the longest common subsequence of `s` and its reverse is
always palindromic.

So: reverse the string and call LCS.

#code(lang: "js", caption: "longestPalinSubseq — one line of new code")[
```js
const longestPalinSubseq = (s) => lcsTable(s, [...s].reverse().join(''));
```
]

Outputs: `'bbbab'` → 4; `'abcd'` → 1; `''` → 0; `'a'` → 1; `'aaaa'` → 4; `'agbcba'` → 5.

#trap[
There is no `String.prototype.reverse`. `[...s].reverse().join('')` is the idiom, and the
spread — not `s.split('')` — is what keeps surrogate pairs intact. `s.split('').reverse()`
would tear an emoji in half.
]

#complexity(time: $O(n^2)$, space: $O(n^2)$, note: "O(n) space with the two-row LCS if you only need the length")

#ans[4 for `"bbbab"` — the subsequence `bbbb`.]
]
]

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
What is the *fewest insertions* needed to make a string a palindrome? And the fewest
*deletions*? $1 <= n <= 1000$.

#sol[
Let $L$ be the longest palindromic subsequence. Every character *not* in that subsequence
must be dealt with, and each one costs exactly one operation.

- *Insertions:* mirror each unmatched character on the other side → $n - L$.
- *Deletions:* throw each unmatched character away → $n - L$.

They are the same number. That is a good sentence to say out loud.

#code(lang: "js", caption: "minInsertionsToPalindrome / minDeletionsToPalindrome")[
```js
const minInsertionsToPalindrome = (s) => s.length - longestPalinSubseq(s);
const minDeletionsToPalindrome  = (s) => s.length - longestPalinSubseq(s);
```
]

Outputs: `'bbbab'` → LPS 4, so 1; `'abcd'` → LPS 1, so 3; `'aaaa'` → LPS 4, so 0;
`'agbcba'` → LPS 5, so 1.

#complexity(time: $O(n^2)$, space: $O(n^2)$)

#ans[1 insertion for `"bbbab"`: make it `"babbab"` — or delete the `a` to get `"bbbb"`.]
]
]

#trick[Any question of the form "fewest edits to reach property P" where P has a
"largest sub-thing with property P" version, is usually
$"answer" = n - ("largest sub-thing")$. Spotting that saves you from designing a new DP.]

#ex(14, tier: 1, asked: "Infosys · pattern")[
A binary grid. (a) Count *all* square blocks made only of 1s. (b) Report the *area* of the
largest such square. $1 <= m, n <= 300$.
Edge cases: all zeros; all ones; a single cell.

#sol[
State: `dp[i][j]` = the side of the largest all-ones square whose *bottom-right corner* is
$(i,j)$.

$ "dp"[i][j] = 1 + min("dp"[i-1][j], "dp"[i][j-1], "dp"[i-1][j-1]) quad "if " g[i][j] = 1 $

Why the minimum of three? A square of side `k+1` at $(i,j)$ needs squares of side at least
`k` at the three neighbouring corners. The weakest of the three limits you.

And the count: a cell with `dp[i][j] = k` is the bottom-right corner of exactly `k` squares
(sides $1, 2, ..., k$). So the total is the sum of all cells.

#diagram(height: 4.2cm, caption: "dp[i][j] = 3 needs side-2 squares at the three marked corners.")[
#dnode(0.4cm, 0.2cm, 1.2cm, 1.2cm, "2", fill: rgb("#e6eef5"))
#dnode(1.8cm, 0.2cm, 1.2cm, 1.2cm, "2", fill: rgb("#e6eef5"))
#dnode(0.4cm, 1.6cm, 1.2cm, 1.2cm, "2", fill: rgb("#e6eef5"))
#dnode(1.8cm, 1.6cm, 1.2cm, 1.2cm, "3", fill: rgb("#cfe0ee"))
#dnode(4.2cm, 0.9cm, 5.6cm, 1.6cm, "min(2, 2, 2) + 1 = 3")
#darrow(3.0cm, 1.7cm, 4.2cm, 1.7cm)
]

#code(lang: "js", caption: "countSquares — every all-ones square")[
```js
const countSquares = (g) => {
  const m = g.length; if (!m) return 0;
  const n = g[0].length; if (!n) return 0;
  const dp = Array.from({ length: m }, () => new Array(n).fill(0));
  let total = 0;
  for (let i = 0; i < m; i++)
    for (let j = 0; j < n; j++) {
      if (!g[i][j]) { dp[i][j] = 0; continue; }
      dp[i][j] = (i === 0 || j === 0) ? 1
               : 1 + Math.min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1]);
      total += dp[i][j];
    }
  return total;
};
```
]

#code(lang: "js", caption: "maximalSquareArea — same table, different reading")[
```js
const maximalSquareArea = (g) => {
  const m = g.length; if (!m) return 0;
  const n = g[0].length; if (!n) return 0;
  const dp = Array.from({ length: m }, () => new Array(n).fill(0));
  let best = 0;
  for (let i = 0; i < m; i++)
    for (let j = 0; j < n; j++) {
      if (!g[i][j]) continue;
      dp[i][j] = (i === 0 || j === 0) ? 1
               : 1 + Math.min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1]);
      best = Math.max(best, dp[i][j]);
    }
  return best * best;
};
```
]

Outputs:

#table(columns: (2.3fr, 0.9fr, 0.9fr),
  [*grid*], [*count*], [*max area*],
  [`[[0,1,1,1],[1,1,1,1],[0,1,1,1]]`], [15], [9],
  [`[[1,0,1],[1,1,0],[1,1,0]]`], [7], [4],
  [`[[0]]`], [0], [0],
  [`[[1]]`], [1], [1],
  [`[]`], [0], [0],
)

#complexity(time: $O(m n)$, space: $O(m n)$, note: "two rows give O(n) space")

#ans[15 squares, largest area 9.]
]
]

#ex(15, tier: 1, asked: "Wipro · pattern")[
*Shortest common supersequence.* The shortest string that contains both `a` and `b` as
subsequences. Report its length and print one such string.
$1 <= n, m <= 1000$. Edge cases: one string empty; identical strings; no shared letters.

#sol[
Length first. Write both strings, then merge the shared part once instead of twice:
$ |"SCS"| = n + m - |"LCS"(a, b)| $

To build the string, backtrack through the LCS table. At each step:
- characters match → write it once, move diagonally
- otherwise → write the character from the side the table says to move from

#code(lang: "js", caption: "shortestCommonSupersequence")[
```js
const shortestCommonSupersequence = (a, b) => {
  const n = a.length, m = b.length;
  const dp = Array.from({ length: n+1 }, () => new Array(m+1).fill(0));
  for (let i = 1; i <= n; i++)
    for (let j = 1; j <= m; j++)
      dp[i][j] = a[i-1] === b[j-1] ? dp[i-1][j-1] + 1 : Math.max(dp[i-1][j], dp[i][j-1]);
  const out = [];
  let i = n, j = m;
  while (i > 0 && j > 0) {
    if (a[i-1] === b[j-1]) { out.push(a[i-1]); i--; j--; }
    else if (dp[i-1][j] >= dp[i][j-1]) { out.push(a[i-1]); i--; }
    else { out.push(b[j-1]); j--; }
  }
  while (i > 0) { out.push(a[i-1]); i--; }      // leftovers of a
  while (j > 0) { out.push(b[j-1]); j--; }      // leftovers of b
  return out.reverse().join('');
};
```
]

Outputs: `('abac','cab')` → `cabac`, length 5;
`('','abc')` → `abc`; `('abc','')` → `abc`; `('','')` → empty;
`('geek','eke')` → `gekek`, length 5.

Check the formula on the last one: $4 + 3 - |"LCS"("geek","eke")| = 7 - 2 = 5$. ✓

#complexity(time: $O(n m)$, space: $O(n m)$)

#ans[`cabac` — it contains `abac` (positions 2,3,4,5) and `cab` (positions 1,2,3).]
]
]

#trap[The two `while` loops *after* the main loop are not optional. When one string runs
out first, the remaining characters of the other must still be written. Leaving them out
produces a string that is too short and does not contain both inputs.]

#pagebreak(weak: true)

#section[Tier 2 — applied and two-step]
#tier-header(2)

#ex(16, tier: 2, asked: "Shopee · pattern")[
A long log string `s` and a short code `t`. How many *different subsequences* of `s` are
exactly equal to `t`? Report the count modulo $10^9+7$.
$1 <= |s| <= 1000$, $1 <= |t| <= 100$. Edge cases: `t` empty; `t` longer than `s`;
repeated letters in `s`.

#sol[
State: `dp[j]` = number of ways to build the first `j` characters of `t` using the part of
`s` processed so far.

Processing one more character `s[i-1]`: it can only help positions `j` where
`t[j-1] == s[i-1]`, and it adds the ways that already had `j-1` characters matched.

$ "dp"[j] "+=" "dp"[j-1] quad "when " s[i-1] = t[j-1] $

Base `dp[0] = 1` — there is one way to match nothing.

*The `j` loop must run backwards*, exactly as in 0/1 knapsack, so that the same `s`
character is not used twice in one pass.

#code(lang: "js", caption: "distinctSubseq")[
```js
const MOD = 1000000007;

const distinctSubseq = (s, t) => {
  const n = s.length, m = t.length;
  const dp = new Array(m + 1).fill(0);
  dp[0] = 1;
  for (let i = 1; i <= n; i++)
    for (let j = m; j >= 1; j--)                 // BACKWARDS
      if (s[i-1] === t[j-1]) dp[j] = (dp[j] + dp[j-1]) % MOD;
  return dp[m];
};
```
]

Outputs: `('rabbbit','rabbit')` → 3; `('babgbag','bag')` → 5; `('abc','')` → 1;
`('','abc')` → 0; `('aaa','aa')` → 3; `('abc','abcd')` → 0.

#note[
This DP only *adds*, so plain numbers are safe under `MOD = 1e9+7`: two residues sum to
under $2 times 10^9$, well inside $2^53 - 1$. A DP that *multiplies* residues would not be
safe — see the trap after Warm-up 1.
]

#complexity(time: $O(|s| dot |t|)$, space: $O(|t|)$)

#ans[3 for `rabbbit` → `rabbit`: the three ways choose a different one of the three `b`s to
drop.]
]
]

#trap[If the `j` loop runs forwards, one `s` character can satisfy two positions of `t` in
the same pass, and `('aaa','aa')` returns 6 instead of 3 — verified by running the broken
version. Backwards. Always backwards when one input item may be used once.]

#ex(17, tier: 2, asked: "Grab · pattern")[
*Wildcard matching.* In the pattern, `?` matches exactly one character and `*` matches any
run of characters, including none. Does the pattern match the whole string?
$0 <= |s| <= 2000$, $0 <= |p| <= 2000$. Edge cases: empty string; a pattern of only stars;
empty pattern.

#sol[
State: `dp[i][j]` = do the first `i` characters of `s` match the first `j` of `p`?

Three cases for `p[j-1]`:

#table(columns: (0.8fr, 2.6fr),
  [`*`], [`dp[i][j] = dp[i-1][j] || dp[i][j-1]` — the star eats one more character, or the star matches nothing],
  [`?` or equal], [`dp[i][j] = dp[i-1][j-1]` — consume one from each],
  [else], [`false`],
)

Base: `dp[0][0] = true`, and `dp[0][j]` is true only while the pattern is all stars.

#code(lang: "js", caption: "wildcardMatch")[
```js
const wildcardMatch = (s, p) => {
  const n = s.length, m = p.length;
  const dp = Array.from({ length: n+1 }, () => new Array(m+1).fill(false));
  dp[0][0] = true;
  for (let j = 1; j <= m; j++) dp[0][j] = dp[0][j-1] && p[j-1] === '*';
  for (let i = 1; i <= n; i++)
    for (let j = 1; j <= m; j++) {
      if (p[j-1] === '*') dp[i][j] = dp[i-1][j] || dp[i][j-1];
      else if (p[j-1] === '?' || p[j-1] === s[i-1]) dp[i][j] = dp[i-1][j-1];
      else dp[i][j] = false;
    }
  return dp[n][m];
};
```
]

#note[
A boolean table stores real `true`/`false` here, not `0`/`1`. That matters because
`dp[0][j-1] && p[j-1] === '*'` returns a *boolean*, and later `dp[i-1][j] || dp[i][j-1]`
returns one too — no coercion anywhere. If you do store `0`/`1`, remember that `0` is
falsy but the *string* `'0'` is truthy, which is the kind of mix-up that costs a round.
]

Outputs:

#table(columns: (1fr, 1fr, 0.6fr, 1fr, 1fr, 0.6fr),
  [*s*], [*p*], [*ok*], [*s*], [*p*], [*ok*],
  [`aa`], [`a`], [no], [`''`], [`''`], [yes],
  [`aa`], [`*`], [yes], [`''`], [`*`], [yes],
  [`cb`], [`?a`], [no], [`''`], [`***`], [yes],
  [`adceb`], [`*a*b`], [yes], [`''`], [`?`], [no],
  [`acdcb`], [`a*c?b`], [no], [`a`], [`''`], [no],
  [`abc`], [`a?c`], [yes], [`abc`], [`*c`], [yes],
)

#complexity(time: $O(|s| dot |p|)$, space: $O(|s| dot |p|)$, note: "two rows give O(|p|) space")

#ans[`adceb` matches `*a*b`; `acdcb` does not match `a*c?b`.]
]
]

#note[Why is `acdcb` vs `a*c?b` a *no*? After `a`, the star must cover some prefix, then a
literal `c`, then one any-character, then `b`. The string ends `...c b`, so the `?` would
have to be the `c` and the `b` the `b` — but then the literal `c` of the pattern must match
the `d`. It fails. The table finds this without you tracing it; that is the point.]

#ex(18, tier: 2, asked: "Sea/Shopee · pattern")[
*Interleaving strings.* Given `a`, `b` and `c`, can `c` be formed by taking the characters
of `a` and `b` in order, mixing them freely?
$0 <= |a|, |b| <= 500$. Edge cases: length mismatch; both empty; repeated letters.

#sol[
State: `dp[i][j]` = can the first `i` of `a` plus the first `j` of `b` build the first
$i+j$ of `c`?

The last character of `c[0..i+j-1]` came from `a` or from `b`:
$ "dp"[i][j] = ("dp"[i-1][j] "and" a_(i-1) = c_(i+j-1)) "or" ("dp"[i][j-1] "and" b_(j-1) = c_(i+j-1)) $

#code(lang: "js", caption: "isInterleave")[
```js
const isInterleave = (a, b, c) => {
  const n = a.length, m = b.length;
  if (c.length !== n + m) return false;          // length check FIRST
  const dp = Array.from({ length: n+1 }, () => new Array(m+1).fill(false));
  dp[0][0] = true;
  for (let i = 0; i <= n; i++)
    for (let j = 0; j <= m; j++) {
      if (i > 0 && dp[i-1][j] && a[i-1] === c[i+j-1]) dp[i][j] = true;
      if (j > 0 && dp[i][j-1] && b[j-1] === c[i+j-1]) dp[i][j] = true;
    }
  return dp[n][m];
};
```
]

Outputs: `('abc','def','adbecf')` → yes; `('abc','def','abcdef')` → yes;
`('abc','def','abdecf')` → yes; `('abc','def','abcdfe')` → *no*;
`('','','')` → yes; `('a','','a')` → yes; `('','a','a')` → yes; `('a','b','ab')` → yes;
`('a','b','ba')` → yes; `('aa','ab','aaba')` → yes; `('aa','ab','abaa')` → yes.

#complexity(time: $O(n m)$, space: $O(n m)$, note: "one row gives O(m)")

#ans[`abcdfe` fails — after `abcd` the only letters left are `e` then `f`, in that order.]
]
]

#trap[The length check `c.length === a.length + b.length` must come first. In C++ reading
`c[i+j-1]` past the end is undefined behaviour; in JavaScript it is worse in a quieter way
— indexing a string out of range returns `undefined`, every comparison against it is
`false`, and the function returns a *plausible-looking* `false` for the wrong reason. Bugs
that never crash are the expensive kind. Verified: `isInterleave('a','b','abc')` is
rejected by the length check, not by the table.]

#ex(19, tier: 2, asked: "Agoda · pattern")[
Two collectors start on the top row of an $m times n$ grid — collector A at column 0,
collector B at column $n-1$. Every turn *both* move down one row and may shift the column by
$-1$, $0$ or $+1$. They collect the value of the cell they land on; if both land on the
same cell it is collected once. Maximise the total.
$1 <= m <= 70$, $1 <= n <= 70$. Edge cases: a single column; a single row; a one-cell grid.

#sol[
#approach(1, "Run the best path for A, then for B", verdict: "WRONG")

Greedy fails: A taking the richest path can force B onto a poor one. The two choices are
not independent.

#approach(2, "Move both at once — state is (row, colA, colB)", verdict: "O(m n^2 · 9) — optimal")

Because both robots always sit on the *same row*, the row is a single index. The state is
$(i, j_1, j_2)$ and each step tries $3 times 3 = 9$ moves.

#code(lang: "js", caption: "twoRobots")[
```js
const twoRobots = (g) => {
  const m = g.length; if (!m) return 0;
  const n = g[0].length; if (!n) return 0;
  let dp = Array.from({ length: n }, () => new Array(n).fill(-Infinity));
  dp[0][n-1] = n === 1 ? g[0][0] : g[0][0] + g[0][n-1];
  for (let i = 1; i < m; i++) {
    const nxt = Array.from({ length: n }, () => new Array(n).fill(-Infinity));
    for (let j1 = 0; j1 < n; j1++)
      for (let j2 = 0; j2 < n; j2++) {
        if (dp[j1][j2] === -Infinity) continue;
        for (let d1 = -1; d1 <= 1; d1++)
          for (let d2 = -1; d2 <= 1; d2++) {
            const a = j1 + d1, b = j2 + d2;
            if (a < 0 || a >= n || b < 0 || b >= n) continue;
            const gain = a === b ? g[i][a] : g[i][a] + g[i][b];
            nxt[a][b] = Math.max(nxt[a][b], dp[j1][j2] + gain);
          }
      }
    dp = nxt;
  }
  let best = 0;
  for (let j1 = 0; j1 < n; j1++)
    for (let j2 = 0; j2 < n; j2++)
      best = Math.max(best, dp[j1][j2] === -Infinity ? 0 : dp[j1][j2]);
  return best;
};
```
]

#trick[
`-Infinity` replaces the `INT_MIN / 4` dodge entirely. The `/ 4` existed only so that
`INT_MIN + gain` would not wrap around to a large positive number; `-Infinity + gain` is
still `-Infinity`, so the "unreachable" marker cannot be faked by arithmetic. One fewer
thing to get wrong.
]

Outputs:

#table(columns: (2.6fr, 0.8fr),
  [*grid*], [*best*],
  [`[[3,1,1],[2,5,1],[1,5,5],[2,1,1]]`], [24],
  [`[[1,0,0,0,0,0,1],[2,0,0,0,0,3,0],[2,0,9,0,0,0,0],[0,3,0,5,4,0,0],[1,0,2,3,0,0,6]]`], [28],
  [`[[5]]`], [5],
  [`[[1,1],[1,1]]`], [4],
  [`[[2,3,4]]`], [6],
  [`[]`], [0],
)

#complexity(time: $O(m n^2)$, space: $O(n^2)$, note: "9 transitions per state, a constant")

#ans[24 for the first grid.]
]
]

#trap[The one-column case: `n === 1` means both robots start on the *same* cell, so the
starting value must be counted once. The line `dp[0][n-1] = n === 1 ? g[0][0] : ...`
handles it. Miss it and a $1$-wide grid doubles every cell.]

#ex(20, tier: 2, asked: "GIC · pattern")[
*Matrix chain multiplication.* Matrix `i` has size `d[i] × d[i+1]`. Multiplying an
$p times q$ by a $q times r$ matrix costs $p q r$ scalar multiplications. Where do you put
the brackets to make the total smallest? $2 <= |d| <= 100$.
Edge cases: one matrix (cost 0); two matrices (only one order).

#sol[
This is the first *interval DP*. The last multiplication splits the chain somewhere:

$ "dp"[i][j] = min_(i <= k < j) ("dp"[i][k] + "dp"[k+1][j] + d_i d_(k+1) d_(j+1)) $

`dp[i][k]` produces a $d_i times d_(k+1)$ matrix and `dp[k+1][j]` produces a
$d_(k+1) times d_(j+1)$ matrix — multiplying them is the last term.

*Loop by interval length*, so shorter pieces are always ready.

#code(lang: "js", caption: "matrixChain")[
```js
const matrixChain = (d) => {
  const n = d.length - 1;              // number of matrices
  if (n <= 1) return 0;
  const dp = Array.from({ length: n }, () => new Array(n).fill(0));
  for (let len = 2; len <= n; len++)
    for (let i = 0; i + len - 1 < n; i++) {
      const j = i + len - 1;
      dp[i][j] = Infinity;
      for (let k = i; k < j; k++)
        dp[i][j] = Math.min(dp[i][j], dp[i][k] + dp[k+1][j] + d[i]*d[k+1]*d[j+1]);
    }
  return dp[0][n-1];
};
```
]

Outputs: `[10,30,5,60]` → 4500; `[40,20,30,10,30]` → 26000; `[5,6]` → 0; `[2,3,4]` → 24;
`[1,2,3,4,5]` → 38.

#complexity(time: $O(n^3)$, space: $O(n^2)$)

#ans[4500 for `{10,30,5,60}`. Bracketing $(A B) C$ costs
$10 dot 30 dot 5 + 10 dot 5 dot 60 = 1500 + 3000 = 4500$; $A (B C)$ costs
$30 dot 5 dot 60 + 10 dot 30 dot 60 = 9000 + 18000 = 27000$.]
]
]

#trick[Every interval DP has the same three lines: loop `len`, loop start `i`, loop split
`k`. If you can write those three lines from memory, half of the hardest DP questions are
already framed. The only thing that changes is the cost term.]

#ex(21, tier: 2, asked: "DBS · pattern")[
*Maximum weight independent set on a tree.* Each node has a value. Pick a set of nodes with
no two picked nodes joined by an edge, maximising the total.
$1 <= n <= 10^5$. Edge cases: a single node; a chain; all values zero.

#sol[
On an array this was "no two neighbours". On a tree it is the same idea with one DFS.

For each node `u` return *two* numbers:
- `withU` — the best total in `u`'s subtree *when `u` is taken*
- `withoutU` — the best total in `u`'s subtree *when `u` is not taken*

$ "withU"(u) = "val"[u] + sum_(v in "children") "withoutU"(v) $
$ "withoutU"(u) = sum_(v in "children") max("withU"(v), "withoutU"(v)) $

#diagram(height: 4.4cm, caption: "If a node is taken, every child must be skipped; if it is skipped, each child chooses freely.")[
#dnode(3.4cm, 0.2cm, 2.4cm, 0.9cm, "u : val 10")
#dnode(0.6cm, 1.8cm, 2.4cm, 0.9cm, "child 1")
#dnode(6.2cm, 1.8cm, 2.4cm, 0.9cm, "child 2")
#dnode(0.0cm, 3.3cm, 1.6cm, 0.8cm, "g 1")
#dnode(1.8cm, 3.3cm, 1.6cm, 0.8cm, "g 2")
#dnode(5.6cm, 3.3cm, 1.6cm, 0.8cm, "g 3")
#dnode(7.4cm, 3.3cm, 1.6cm, 0.8cm, "g 4")
#darrow(4.0cm, 1.1cm, 1.8cm, 1.8cm, label: "skip")
#darrow(5.2cm, 1.1cm, 7.4cm, 1.8cm, label: "skip")
#darrow(1.4cm, 2.7cm, 0.8cm, 3.3cm)
#darrow(2.0cm, 2.7cm, 2.6cm, 3.3cm)
#darrow(7.0cm, 2.7cm, 6.4cm, 3.3cm)
#darrow(7.6cm, 2.7cm, 8.2cm, 3.3cm)
]

#code(lang: "js", caption: "robTree — returns [take u, skip u]")[
```js
const robTree = (u, ch, val) => {
  let take = val[u], skip = 0;
  for (const v of ch[u]) {
    const [t, s] = robTree(v, ch, val);
    take += s;
    skip += Math.max(t, s);
  }
  return [take, skip];
};
```
]

The answer is `Math.max(...robTree(root, ch, val))` at the root — a two-element spread, so
no stack risk there.

Outputs on the tree `0 → 1, 2`; `1 → 3, 4`:

#table(columns: (2fr, 0.7fr, 2.2fr),
  [*values*], [*best*], [*chosen*],
  [`[3,2,3,1,1]`], [5], [nodes 0, 3, 4 (or nodes 2, 3, 4)],
  [`[3,4,5,1,1]`], [9], [nodes 1 and 2],
  [single node `[7]`], [7], [that node],
  [chain `0-1-2` with `[1,100,1]`], [100], [node 1],
  [`[0,0,0,0,0]`], [0], [nothing],
)

#complexity(time: $O(n)$, space: $O(h)$)

#ans[5 for `{3,2,3,1,1}`: either take node 0 (3) plus grandchildren 3 and 4 (1+1) = 5,
or take nodes 2, 3, 4 (3+1+1) = 5. Both reach 5; node 0 and node 2 cannot both be taken
because they are joined by an edge.]
]
]

#trap[*Recursion depth — and in Node this is not hypothetical.* A tree that is one long
chain of 100000 nodes makes this exact function throw
`RangeError: Maximum call stack size exceeded`. That was run; the chapter is not guessing.
C++ and Java survive the same depth, JavaScript does not, and the constraint here says
$n <= 10^5$.

Two fixes, both worth naming:
+ *Explicit stack.* Push `[node, childIndex]` frames, advance the index on each visit, and
  fold the child's `[take, skip]` into the parent's when a frame is popped. Same algorithm,
  no recursion.
+ *Iterative post-order by reverse BFS.* Order the nodes by BFS from the root, then walk
  that order *backwards* — every node is then processed after all of its children. It is
  four lines and it is what most people write under time pressure.

`node --stack-size=...` exists but is not something you can rely on in a judge.]

#ex(22, tier: 2, asked: "SCB · pattern")[
*Best path in a weighted tree.* A path may start and end at any two nodes and bends at most
once (it goes up from one node and down to another). Node values may be negative. Find the
largest path sum. $1 <= n <= 10^5$.
Edge cases: a single node with a negative value; all values negative.

#sol[
For each node `u`, define `down(u)` = the best sum of a path that *starts at `u` and only
goes downward*. A child contributes `max(0, down(child))` — a negative branch is simply not
used.

At `u` there are two things to do:
+ *answer candidate*: the path bends at `u` and uses the two best child branches:
  `val[u] + best1 + best2`.
+ *return value*: the path continues up through `u`, so it can use only one branch:
  `val[u] + best1`.

#code(lang: "js", caption: "maxPathSum — one DFS, two jobs per node")[
```js
const maxPathSum = (root, ch, val) => {
  let bestAns = -Infinity;                       // a local, not a global
  const downFrom = (u) => {
    let b1 = 0, b2 = 0;                          // two largest child contributions
    for (const v of ch[u]) {
      const d = Math.max(0, downFrom(v));        // a negative branch is simply dropped
      if (d > b1) { b2 = b1; b1 = d; }
      else if (d > b2) b2 = d;
    }
    bestAns = Math.max(bestAns, val[u] + b1 + b2);  // path bends at u
    return val[u] + b1;                             // path continues upward
  };
  downFrom(root);
  return bestAns;
};
```
]

Outputs: root with children, values `[1,2,3]` → 6 (the whole thing);
the tree `0 → 1,2`; `2 → 3,4` with values `[-10,9,20,15,7]` → 42 (the path $15 → 20 → 7$);
single node `[-5]` → $-5$; `[-1,-2,-3]` → $-1$;
chain `0-1-2` with `[5,-100,5]` → 5.

#complexity(time: $O(n)$, space: $O(h)$)

#ans[42.]
]
]

#trap[Three separate traps in one problem.
(1) `Math.max(0, ...)` on the child, so a negative branch is dropped — but
(2) the node's *own* value is never dropped, which is why `[-5]` correctly returns $-5$ and
not 0.
(3) `bestAns` must start at `-Infinity`, not 0, or an all-negative tree returns 0.

And a fourth, specific to JavaScript: keep `bestAns` as a `let` *inside* `maxPathSum`
rather than as a module-level variable. A global accumulator survives between calls, so the
second test in your own test file silently reads the first test's answer. The closure makes
that impossible.]

#pagebreak(weak: true)

#section[Tier 3 — insight needed]
#tier-header(3)

#ex(23, tier: 3, asked: "Google · pattern")[
*Palindrome partitioning — minimum cuts.* Cut a string into pieces so that every piece is a
palindrome. What is the fewest number of cuts?
$1 <= n <= 2000$. Edge cases: already a palindrome (0 cuts); no repeats (n−1 cuts);
empty string.

#sol[
#approach(1, "Try every set of cut positions", verdict: "O(2^n)")

#approach(2, "DP with a palindrome check inside", verdict: "O(n^3) — the check costs O(n)")

#approach(3, "Precompute a palindrome table first", verdict: "O(n^2) — optimal")

Two DPs, run one after the other.

*DP 1 — is `s[i..j]` a palindrome?*
$ "pal"[i][j] = (s_i = s_j) "and" ("length" = 2 "or" "pal"[i+1][j-1]) $
Fill it by increasing length, so `pal[i+1][j-1]` is always ready.

*DP 2 — fewest cuts for the prefix ending at `i`.*
$ "dp"[i] = cases(0 & "if " s[0..i] "is a palindrome", min_(1 <= j <= i, "pal"[j][i]) ("dp"[j-1] + 1) & "otherwise") $

#code(lang: "js", caption: "minPalindromeCuts")[
```js
const minPalindromeCuts = (s) => {
  const n = s.length;
  if (n <= 1) return 0;
  const pal = Array.from({ length: n }, () => new Array(n).fill(false));
  for (let i = 0; i < n; i++) pal[i][i] = true;
  for (let len = 2; len <= n; len++)
    for (let i = 0; i + len - 1 < n; i++) {
      const j = i + len - 1;
      pal[i][j] = s[i] === s[j] && (len === 2 || pal[i+1][j-1]);
    }
  const dp = new Array(n).fill(Infinity);
  for (let i = 0; i < n; i++) {
    if (pal[0][i]) { dp[i] = 0; continue; }
    for (let j = 1; j <= i; j++)
      if (pal[j][i] && dp[j-1] !== Infinity) dp[i] = Math.min(dp[i], dp[j-1] + 1);
  }
  return dp[n-1];
};
```
]

Outputs: `'aab'` → 1; `'a'` → 0; `''` → 0; `'abcba'` → 0; `'abcd'` → 3; `'aaaa'` → 0;
`'abbab'` → 1; `'noonabbad'` → 2.

#complexity(time: $O(n^2)$, space: $O(n^2)$)

#ans[`"noonabbad"` needs 2 cuts: `noon | abba | d`.]
]

#subsection[The follow-up the interviewer asks next]

*"Now print the pieces."*

Store `from[i]` = the `j` that gave the minimum, i.e. the start index of the last piece
ending at `i`. Then walk backwards from `n-1`, slicing off `s[from[i] .. i]` each time, and
reverse the list. This is the same parent-pointer idea as Chapter 17, Example 15.

*"And can you get the memory down to $O(n)$?"*

Yes. Replace the `pal` table by the *expand-around-centre* method: for each of the $2n-1$
centres, grow outward while the characters match, and relax `dp` as you grow. That keeps
only the `dp` array — $O(n)$ space, still $O(n^2)$ time.
]

#ex(24, tier: 3, asked: "Amazon · pattern")[
*Cutting a stick.* A stick has length `L`. You must cut it at each of the given positions.
A single cut costs the *current length of the piece being cut*. The order of cuts is yours
to choose. Minimise the total cost.
Number of cut positions $<= 100$. Edge cases: no cuts at all; one cut; evenly spaced cuts.

#sol[
#approach(1, "Try every order of cuts", verdict: "O(k!) — 100! is beyond hopeless")

#approach(2, "Interval DP over cut positions", verdict: "O(k^3) — optimal")

Here is the insight. Do not think about *which cut happens first in time*. Think about
*which cut is the first one made inside a given piece*, because that single choice splits
the piece into two independent pieces.

Add the two ends `0` and `L` to the list and sort it. Then

$ "dp"[i][j] = min_(i < k < j) ("dp"[i][k] + "dp"[k][j]) + ("cuts"[j] - "cuts"[i]) $

The last term is the length of the piece `i..j`, paid once for the first cut inside it.

#code(lang: "js", caption: "minCutCost")[
```js
const minCutCost = (L, cuts) => {
  const c = [...cuts, 0, L].sort((x, y) => x - y);   // COPY, then sort NUMERICALLY
  const m = c.length;
  const dp = Array.from({ length: m }, () => new Array(m).fill(0));
  for (let len = 2; len < m; len++)
    for (let i = 0; i + len < m; i++) {
      const j = i + len;
      dp[i][j] = Infinity;
      for (let k = i + 1; k < j; k++)
        dp[i][j] = Math.min(dp[i][j], dp[i][k] + dp[k][j] + c[j] - c[i]);
    }
  return dp[0][m-1];
};
```
]

Outputs: `L=7, cuts=[1,3,4,5]` → 16; `L=9, cuts=[5,6,1,4,2]` → 22; `L=10, cuts=[]` → 0;
`L=10, cuts=[5]` → 10; `L=4, cuts=[1,2,3]` → 8. The caller's `cuts` array comes back in its
original order.

#trap[
*This is the only `sort` in the chapter, and it is the most dangerous line in it.*
`arr.sort()` with empty brackets is *lexicographic*: it stringifies every element first, so
`[10, 9, 1].sort()` gives `[1, 10, 9]`. Here that is not theoretical —
`[5,6,1,4,2,0,9].sort()` happens to come out right because every value is a single digit,
but change the stick length to 10 and `[5,6,1,4,2,0,10].sort()` gives
`[0, 1, 10, 2, 4, 5, 6]`. Both were run. Numbers *always* need
`sort((a, b) => a - b)`.

Two companions: a comparator must return a *number*, never a boolean — `(a, b) => a > b`
coerces to `1`/`0`, the sort never sees a negative, and the array stays essentially
unsorted. And `sort` mutates in place and returns the same array, which is why this code
sorts a fresh `[...cuts, 0, L]` rather than the caller's list.
]

#complexity(time: $O(k^3)$, space: $O(k^2)$)

#ans[16. One optimal order for `L=7, cuts={1,3,4,5}`: cut at 3 (cost 7), then at 5 (cost
4), then 1 (cost 3) and 4 (cost 2): $7 + 4 + 3 + 2 = 16$.]
]

#subsection[The follow-up the interviewer asks next]

*"What if the cost of a cut is a fixed fee instead of the piece length?"*

Then every order costs the same, and there is nothing to optimise. Say that. Recognising
when a problem *collapses* is as valuable as solving a hard one.

*"What if each cut has both a fee and a piece-length cost?"*

The recurrence barely changes:
`dp[i][j] = min(dp[i][k] + dp[k][j] + fee[k]) + (cuts[j] - cuts[i])`. The `fee[k]` moves
inside the `min` because it depends on which cut you choose first.
]

#trick[The whole family — matrix chain, stick cutting, merging piles, bursting balloons —
shares one move: *pick the element that is processed LAST (or FIRST) inside the interval*,
because that choice makes the two sides independent. When an interval problem feels stuck,
ask "what if I decide which one is last?"]

#ex(25, tier: 3, asked: "Microsoft · pattern")[
*Bursting balloons.* Balloons in a row each hold a number. Bursting balloon `i` earns
`left × a[i] × right`, where left and right are the nearest *surviving* neighbours (treat a
missing neighbour as 1). Burst them all. Maximise the earnings.
$1 <= n <= 300$. Edge cases: one balloon; empty list; all equal values.

#sol[
#approach(1, "Try every burst order", verdict: "O(n!)")

#approach(2, "Interval DP on 'which balloon bursts FIRST'", verdict: "WRONG — the pieces are not independent")

If you burst `k` first, the two sides still touch each other afterwards, so they are not
separate problems. This is the trap the question is built around.

#approach(3, "Interval DP on 'which balloon bursts LAST'", verdict: "O(n^3) — optimal")

Flip it. If balloon `k` is the *last* one burst in the open interval $(i, j)$, then at that
moment its neighbours are exactly `a[i]` and `a[j]` — the boundary balloons, which are
still alive. Everything strictly between `i` and `k` was burst without ever touching
anything beyond `k`, and the same on the right. Now the two sides *are* independent.

$ "dp"[i][j] = max_(i < k < j) ("dp"[i][k] + "dp"[k][j] + a_i dot a_k dot a_j) $

Pad the array with a 1 on each end so the boundaries always exist.

#code(lang: "js", caption: "burst")[
```js
const burst = (input) => {
  if (input.length === 0) return 0;
  const a = [1, ...input, 1];                  // pad both ends, without touching the caller
  const m = a.length;
  const dp = Array.from({ length: m }, () => new Array(m).fill(0));
  for (let len = 2; len < m; len++)
    for (let i = 0; i + len < m; i++) {
      const j = i + len;
      for (let k = i + 1; k < j; k++)
        dp[i][j] = Math.max(dp[i][j], dp[i][k] + dp[k][j] + a[i]*a[k]*a[j]);
    }
  return dp[0][m-1];
};
```
]

Outputs: `[3,1,5,8]` → 167; `[1,5]` → 10; `[7]` → 7; `[]` → 0; `[2,2,2]` → 14;
`[9,76,64,21]` → 116718. The caller's array is unchanged.

#trick[
`[1, ...input, 1]` does the padding, the copy and the boundary sentinels in one expression.
C++ needs an `insert` at the front — an $O(n)$ shift — plus a `push_back`; the spread form
builds the new array once and never mutates the input.
]

#complexity(time: $O(n^3)$, space: $O(n^2)$)

#ans[167. One optimal order for `{3,1,5,8}`: burst 1 (earning $3 dot 1 dot 5 = 15$), then 5
($3 dot 5 dot 8 = 120$), then 3 ($1 dot 3 dot 8 = 24$), then 8 ($1 dot 8 dot 1 = 8$):
$15+120+24+8 = 167$.]
]

#subsection[The follow-up the interviewer asks next]

*"Why does 'burst first' fail but 'burst last' work? Say it precisely."*

Because the recurrence needs the two sub-intervals to be *solvable without knowing anything
about each other*. After bursting `k` first, the left and right pieces become neighbours,
so the left piece's final earnings depend on what survives on the right. After declaring
`k` *last*, the left piece never sees past `k` and the right piece never sees before `k`.
Independence is the whole requirement of DP, and that is the sentence the interviewer is
listening for.

*"What if values can be negative?"*

Then "burst them all" may be worse than an empty burst — but the problem still forces every
balloon to pop, so the DP is unchanged. In JavaScript there is no `int` to overflow; the
question is only whether the total stays inside $2^53 - 1$. Here it does easily:
$300 times 100^3 = 3 times 10^8$.
]

#ex(26, tier: 3, asked: "Goldman Sachs · pattern")[
*Counting bracketings.* An expression like `T|T&F^T` uses `T`, `F` and the operators `&`,
`|`, `^` (XOR). In how many ways can you bracket it so the result is *True*? Report the
answer modulo 1003.
Operands $<= 50$. Edge cases: a single `T`; a single `F`; an expression that is never true.

#sol[
This is interval DP with *two* tables, because to know how many bracketings give True you
must also know how many give False.

- `T[i][j]` = bracketings of operands `i..j` that evaluate to True
- `F[i][j]` = the same, evaluating to False

Split at operator `m` (between operand `m` and `m+1`). Let
$"lt" = T[i][m]$, $"lf" = F[i][m]$, $"rt" = T[m+1][j]$, $"rf" = F[m+1][j]$, and let
$"tot" = ("lt"+"lf")("rt"+"rf")$ be the total number of bracketings of this split.

#table(columns: (0.6fr, 1.6fr, 1.6fr),
  [*op*], [*True count*], [*False count*],
  [`&`], [`lt · rt`], [`tot − lt·rt`],
  [`|`], [`tot − lf·rf`], [`lf · rf`],
  [`^`], [`lt·rf + lf·rt`], [`lt·rt + lf·rf`],
)

Using `tot − (the easy one)` saves writing three products and is less error-prone.

#code(lang: "js", caption: "countTrueWays")[
```js
const countTrueWays = (e) => {
  const MOD = 1003;
  const n = e.length;
  if (n === 0) return 0;
  const k = (n + 1) >> 1;                      // number of operands
  const T = Array.from({ length: k }, () => new Array(k).fill(0));
  const F = Array.from({ length: k }, () => new Array(k).fill(0));
  for (let i = 0; i < k; i++) {
    const c = e[2*i];
    T[i][i] = c === 'T' ? 1 : 0;
    F[i][i] = c === 'F' ? 1 : 0;
  }
  for (let len = 2; len <= k; len++)
    for (let i = 0; i + len - 1 < k; i++) {
      const j = i + len - 1;
      for (let m = i; m < j; m++) {
        const op = e[2*m + 1];
        const lt = T[i][m], lf = F[i][m], rt = T[m+1][j], rf = F[m+1][j];
        const tot = (lt + lf) * (rt + rf);
        if (op === '&')      { T[i][j] += lt * rt;  F[i][j] += tot - lt * rt; }
        else if (op === '|') { F[i][j] += lf * rf;  T[i][j] += tot - lf * rf; }
        else                 { T[i][j] += lt * rf + lf * rt;
                               F[i][j] += lt * rt + lf * rf; }
        T[i][j] %= MOD; F[i][j] %= MOD;
      }
    }
  return T[0][k-1] % MOD;
};
```
]

Outputs: `'T|T&F^T'` → 4; `'T^F|F'` → 2; `'T'` → 1; `'F'` → 0; `''` → 0;
`'T&F'` → 0; `'T|F'` → 1; `'T^T'` → 0; `'T^T^F'` → 0.

#trap[
`T[i][i] = c === 'T' ? 1 : 0`, not `T[i][i] = c === 'T'`. C++ silently converts `bool` to
`0`/`1`; JavaScript would store real booleans, and `true * true` does coerce to `1` but
`tot - lt * rt` with booleans in it reads terribly and breaks the moment a sum exceeds 1.
Store numbers in a numeric table.

Also note `(n + 1) >> 1` rather than `(n + 1) / 2`: JavaScript division produces a
*fraction*, and `dp[2.5]` is a silently different property from `dp[2]`. Any index
computed by division needs `>> 1`, `Math.floor`, or `| 0`. This is one of the most common
C++-to-JavaScript porting bugs.
]

#note[
This DP *does* multiply, but the modulus is 1003, so every product stays under
$1003^2 dot 4 approx 4 times 10^6$ — nowhere near $2^53$. Plain numbers are exact here.
Had the modulus been $10^9+7$, the same code would be wrong and would need `BigInt`.
]

#complexity(time: $O(k^3)$, space: $O(k^2)$)

#ans[4 for `"T|T&F^T"`.]
]

#subsection[The follow-up the interviewer asks next]

*"Why did you keep a False table too?"*

Because the operators mix the two. `|` produces True from *any* pair that is not
False-False, so the True count needs the False counts of both sides. A DP state must be
"closed" — you must be able to compute it from the states you kept. Whenever an answer
depends on a property you did not store, add that property to the state.

*"The modulus 1003 is not prime. Does that matter?"*

Not for this problem, because we only add and multiply — no division, no modular inverse.
If the problem asked for a ratio or used division you would need a prime modulus or a
different technique.
]

#ex(27, tier: 3, asked: "Adobe · pattern")[
*Assignment.* `n` workers, `n` jobs, `cost[w][j]` is what it costs worker `w` to do job `j`.
Each worker gets exactly one job and each job exactly one worker. Minimise the total cost.
$1 <= n <= 18$. Edge cases: $n = 1$; all costs equal; empty input.

#sol[
#approach(1, "Try every permutation", verdict: "O(n!) — 18! is about 6 × 10^15")

#approach(2, "Bitmask DP", verdict: "O(2^n · n) — 18 × 2^18 ≈ 5 × 10^6, instant")

The insight: while filling jobs one worker at a time, *the only thing that matters about
the past is which jobs are already used* — not which worker took which. So the state is a
set of used jobs, and a set of $n <= 18$ items is an 18-bit integer.

Even better: the number of workers already placed equals `popcount(mask)`, so the current
worker index is free — no second dimension needed.

#code(lang: "js", caption: "assignMinCost")[
```js
const popcount = (m) => { let c = 0; while (m) { m &= m - 1; c++; } return c; };

const assignMinCost = (cost) => {
  const n = cost.length;
  if (n === 0) return 0;
  const dp = new Array(1 << n).fill(Infinity);
  dp[0] = 0;
  for (let mask = 0; mask < (1 << n); mask++) {
    if (dp[mask] === Infinity) continue;
    const w = popcount(mask);                  // next worker to place
    if (w === n) continue;
    for (let j = 0; j < n; j++)
      if (!(mask & (1 << j)))
        dp[mask | (1 << j)] = Math.min(dp[mask | (1 << j)], dp[mask] + cost[w][j]);
  }
  return dp[(1 << n) - 1];
};
```
]

Outputs: `[[9,2,7],[6,4,3],[5,8,1]]` → 9 (matching the brute-force permutation search);
single worker `[[5]]` → 5; empty → 0; `[[1,1],[1,1]]` → 2. A randomised comparison against
the $O(n!)$ version over 200 inputs reported `200 random cross-checks passed`.

#complexity(time: $O(2^n dot n)$, space: $O(2^n)$)

#ans[9 — worker 0 takes job 1 (2), worker 1 takes job 0 (6), worker 2 takes job 2 (1).]
]

#subsection[The follow-up the interviewer asks next]

*"Now n is 2000."*

Bitmask is dead ($2^2000$ — and JavaScript bit operations gave up at 31 bits long before
that). The right answer is the *Hungarian algorithm*, which solves the
assignment problem in $O(n^3)$, or a min-cost max-flow formulation. You are not expected to
code it — you are expected to *name* it and say why bitmask stops working. The boundary is
roughly $n <= 20$ for $O(2^n n)$ and $n <= 15$ for $O(3^n)$.

*"What if a worker can take up to two jobs?"*

Keep the mask of used jobs but add a small second dimension — how many jobs the current
worker already has — or iterate over pairs of free jobs for each worker. The state grows,
the shape does not.
]

#ex(28, tier: 3, asked: "Uber · pattern")[
*Shortest tour (TSP).* `n` cities with a full distance matrix. Start at city 0, visit every
city exactly once, return to city 0. Minimise the distance.
$2 <= n <= 18$. Edge cases: $n = 1$ (tour length 0); $n = 2$; a symmetric matrix.

#sol[
#approach(1, "Try all orders", verdict: "O(n!) — 18! ≈ 6 × 10^15")

#approach(2, "Bitmask DP with a 'current city' dimension", verdict: "O(2^n · n^2) — optimal known")

Unlike the assignment problem, *where you are standing matters* — the next distance depends
on it. So the state needs two parts:

`dp[mask][u]` = cheapest way to have visited exactly the set `mask` and be standing at
city `u`.

$ "dp"["mask" | (1 << v)][v] = min("dp"["mask"][u] + d[u][v]) quad "for " v in.not "mask" $

Base: `dp[1][0] = 0` — only city 0 visited, standing at city 0.
Answer: $min_(u != 0) ("dp"["full"][u] + d[u][0])$ — close the loop.

#code(lang: "js", caption: "tsp")[
```js
const tsp = (d) => {
  const n = d.length;
  if (n <= 1) return 0;
  const dp = Array.from({ length: 1 << n }, () => new Array(n).fill(Infinity));
  dp[1][0] = 0;                                   // only city 0 visited, at city 0
  for (let mask = 1; mask < (1 << n); mask++)
    for (let u = 0; u < n; u++) {
      if (dp[mask][u] === Infinity || !(mask & (1 << u))) continue;
      for (let v = 0; v < n; v++) {
        if (mask & (1 << v)) continue;
        const nm = mask | (1 << v);
        dp[nm][v] = Math.min(dp[nm][v], dp[mask][u] + d[u][v]);
      }
    }
  const full = (1 << n) - 1;
  let best = Infinity;
  for (let u = 1; u < n; u++) best = Math.min(best, dp[full][u] + d[u][0]);
  return best;
};
```
]

Outputs: the classic four-city matrix
`[[0,10,15,20],[10,0,35,25],[15,35,0,30],[20,25,30,0]]` → 80; `[[0]]` → 0;
`[[0,5],[5,0]]` → 10. A randomised comparison against the $O(n!)$ version on 100 random
symmetric matrices reported `100 random cross-checks passed`.

#trap[
`Array.from({ length: 1 << n }, () => new Array(n).fill(Infinity))` allocates $2^n$
*separate* rows. At $n = 18$ that is 262144 ordinary arrays — about 4.7 million numbers,
and each JavaScript array carries its own header. It works, but it is heavy. If memory is
the constraint, flatten to a single `new Float64Array((1 << n) * n)` and index it as
`dp[mask * n + u]`: one allocation, no per-row overhead, and typed arrays initialise to `0`
so you `fill(Infinity)` yourself.
]

#complexity(time: $O(2^n dot n^2)$, space: $O(2^n dot n)$, note: "n = 18 gives about 8 × 10^7 steps and 4.7 M ints — tight but fine")

#ans[80 — the tour $0 → 1 → 3 → 2 → 0$ costs $10 + 25 + 30 + 15 = 80$.]
]

#code(lang: "python", caption: "tsp — Python version")[
```python
def tsp(d):
    n = len(d)
    if n <= 1:
        return 0
    INF = float('inf')
    dp = [[INF] * n for _ in range(1 << n)]
    dp[1][0] = 0
    for mask in range(1, 1 << n):
        for u in range(n):
            if dp[mask][u] == INF or not (mask >> u) & 1:
                continue
            for v in range(n):
                if (mask >> v) & 1:
                    continue
                nm = mask | (1 << v)
                if dp[mask][u] + d[u][v] < dp[nm][v]:
                    dp[nm][v] = dp[mask][u] + d[u][v]
    full = (1 << n) - 1
    return min(dp[full][u] + d[u][0] for u in range(1, n))
```
]

Output: `80`, then `10 0`.

#subsection[The follow-up the interviewer asks next]

*"Memory is 4.7 million numbers at n = 18. Can you cut it?"*

Yes — process masks in increasing order of `popcount`, keeping only two popcount layers.
Or flatten the table into one `Float64Array` (or `Int32Array`, if the distances fit in 32
bits) and index it as `dp[mask * n + u]`: that removes 262144 array headers and keeps the
values packed. Also note that any mask without bit 0 set is unreachable, so half the table
is wasted; skipping those halves the memory again.

*"n = 1000, and you only need a good tour, not the best one."*

Say: nearest-neighbour construction, then 2-opt improvement, or Christofides for metric
instances with a $1.5 times$ guarantee. TSP is NP-hard; nobody expects exactness at 1000
cities.
]

#trap[The difference between Example 27 and Example 28 is worth memorising.
*Assignment* needs only `dp[mask]` because the cost of the next pick does not depend on the
previous pick. *TSP* needs `dp[mask][u]` because the next edge starts at `u`. Ask yourself:
"does the cost of the next step depend on which item I picked last?" If yes, add that
dimension.]

#pagebreak(weak: true)

#section[Dry run — edit distance, cell by cell]

Turn `horse` into `ros`. Rows are the characters of `horse`, columns the characters of
`ros`. `dp[i][j]` = the fewest operations that turn the first `i` letters of `horse` into
the first `j` letters of `ros`.

#subsection[Step 1 — the base row and column]

`dp[i][0] = i` — to reach the empty string you delete every letter.
`dp[0][j] = j` — from the empty string you insert every letter.

```
        ''   r   o   s
   ''    0   1   2   3
    h    1   .   .   .
    o    2   .   .   .
    r    3   .   .   .
    s    4   .   .   .
    e    5   .   .   .
```

#subsection[Step 2 — row `h`]

- `dp[1][1]`: `h` vs `r`, different →
  $1 + min("dp"[0][1], "dp"[1][0], "dp"[0][0]) = 1 + min(1, 1, 0) = 1$
- `dp[1][2]`: `h` vs `o`, different → $1 + min(2, 1, 1) = 2$
- `dp[1][3]`: `h` vs `s`, different → $1 + min(3, 2, 2) = 3$

#subsection[Step 3 — row `o`]

- `dp[2][1]`: `o` vs `r`, different → $1 + min("dp"[1][1], "dp"[2][0], "dp"[1][0]) = 1 + min(1, 2, 1) = 2$
- `dp[2][2]`: `o` vs `o`, *same* → copy the diagonal: `dp[1][1] = 1`
- `dp[2][3]`: `o` vs `s`, different → $1 + min(3, 1, 2) = 2$

#subsection[Step 4 — row `r`]

- `dp[3][1]`: `r` vs `r`, *same* → diagonal `dp[2][0] = 2`
- `dp[3][2]`: `r` vs `o`, different → $1 + min("dp"[2][2], "dp"[3][1], "dp"[2][1]) = 1 + min(1, 2, 2) = 2$
- `dp[3][3]`: `r` vs `s`, different → $1 + min(2, 2, 1) = 2$

#subsection[Step 5 — rows `s` and `e`]

- `dp[4][1]`: `s` vs `r` → $1 + min(2, 3, 3) = 3$
- `dp[4][2]`: `s` vs `o` → $1 + min(2, 3, 2) = 3$
- `dp[4][3]`: `s` vs `s`, *same* → diagonal `dp[3][2] = 2`
- `dp[5][1]`: `e` vs `r` → $1 + min(3, 4, 4) = 4$
- `dp[5][2]`: `e` vs `o` → $1 + min(3, 4, 3) = 4$
- `dp[5][3]`: `e` vs `s` → $1 + min(2, 4, 3) = 3$

#subsection[The finished table (printed by the program)]

```
        ''   r   o   s
   ''    0   1   2   3
    h    1   1   2   3
    o    2   2   1   2
    r    3   2   2   2
    s    4   3   3   2
    e    5   4   4   3
```

Answer: `dp[5][3] = 3`.

#subsection[Reading the operations backwards]

Start at `dp[5][3] = 3` and move to whichever neighbour justified the value.

#table(columns: (0.9fr, 0.6fr, 1.5fr, 2.6fr),
  [*cell*], [*val*], [*came from*], [*operation*],
  [`dp[5][3]`], [3], [`dp[4][3] = 2`], [delete `e`],
  [`dp[4][3]`], [2], [`dp[3][2] = 2` (match `s`)], [keep `s`],
  [`dp[3][2]`], [2], [`dp[2][2] = 1`], [delete `r`],
  [`dp[2][2]`], [1], [`dp[1][1] = 1` (match `o`)], [keep `o`],
  [`dp[1][1]`], [1], [`dp[0][0] = 0`], [replace `h` with `r`],
)

Reading downwards: replace `h`→`r`, keep `o`, delete `r`, keep `s`, delete `e`.
Three operations. `horse` → `rorse` → `rose` → `ros`. ✓

#subsection[The same table as a two-row computation]

The two-row version keeps only the previous row and the row being built. At the moment
`cur[2]` is computed for row `r`:

#table(columns: (1fr, 0.7fr, 0.7fr, 0.7fr, 0.7fr, 2.4fr),
  [], [`''`], [`r`], [`o`], [`s`], [*meaning*],
  [`prev` (row `o`)], [2], [2], [1], [2], [finished],
  [`cur` (row `r`)], [3], [2], [?], [—], [being built],
)

The three numbers `cur[2]` needs are `prev[2] = 1` (delete), `cur[1] = 2` (insert) and
`prev[1] = 2` (replace). All three are available. That is the whole proof that two rows are
enough.

#trap[In the two-row version, `prev[j-1]` must be read *before* `cur[j-1]` overwrites
anything you still need. Because `cur` and `prev` are separate arrays, this is automatic.
If you try to squeeze it into a single array you must save the diagonal in a temporary
variable first — a very common source of wrong answers.]

#subsection[Second dry run — the LCS table]

Same idea, different rule. `abcde` against `ace`:

```
        ''   a   c   e
   ''    0   0   0   0
    a    0   1   1   1
    b    0   1   1   1
    c    0   1   2   2
    d    0   1   2   2
    e    0   1   2   3
```

Row `b`: `b` never matches `a`, `c` or `e`, so every cell copies the better of "above" and
"left" — the row is unchanged from row `a`.
Row `c`: at column `c` the characters match, so `dp[3][2] = dp[2][1] + 1 = 1 + 1 = 2`.
Row `e`: at column `e` they match, so `dp[5][3] = dp[4][2] + 1 = 2 + 1 = 3`.

Backtracking from `dp[5][3]`: match `e` → go to `dp[4][2]`; `d` vs `c` differ and
`dp[3][2] = 2 >= dp[4][1] = 1`, go up to `dp[3][2]`; match `c` → `dp[2][1]`; `b` vs `a`
differ, go up to `dp[1][1]`; match `a` → done. Collected backwards: `e`, `c`, `a` →
reversed, `ace`.

#pagebreak(weak: true)

#section[Practice]

#practice(tier: 0, time: "15 min")[
*P1.* A grid of costs. Fall from the top row to the bottom row, but you may *not* land in
the same column as the row before. Minimise the sum. $1 <= m, n <= 200$.

*P2.* Count *all* palindromic substrings of a string (single letters count).
$1 <= n <= 1000$.

*P3.* Given `a` and `b`, report the fewest deletions from `a` and insertions into `a` that
turn `a` into `b`. $1 <= |a|, |b| <= 1000$.
]

#practice(tier: 1, time: "30 min")[
*P4.* Longest common subsequence of *three* strings. $1 <= $ each length $<= 100$.

*P5.* `n` houses, `k` colours, `cost[i][c]` to paint house `i` colour `c`, no two
neighbouring houses share a colour. Minimise the cost in $O(n k)$ — not $O(n k^2)$.
$1 <= n <= 10^5$, $2 <= k <= 20$.

*P6.* Height of a rooted tree is easy. Now find its *diameter*: the largest number of edges
on any path between two nodes. $1 <= n <= 10^5$.

*P7.* Every node of a rooted tree has a (possibly negative) value. Find the largest sum of
any *subtree*. $1 <= n <= 10^5$.
]

#practice(tier: 2, time: "40 min")[
*P8.* Regular expression matching with `.` (any single character) and `*` (zero or more of
the *previous* character). Must match the whole string. $0 <= |s|, |p| <= 1000$.

*P9.* Piles of stones in a row. Repeatedly merge two *adjacent* piles; the cost of a merge
is the number of stones merged. Merge everything into one pile at minimum cost.
$1 <= n <= 300$.

*P10.* Count the right/down paths in a grid with walls, where you may *remove at most one
wall*. $1 <= m, n <= 500$.
]

#practice(tier: 3, time: "40 min")[
*P11.* Maximum weight independent set on a tree — and *print* the chosen nodes.
$1 <= n <= 10^5$.

*P12.* $2m$ people and a table saying which pairs may be partners. Count the ways to split
everybody into partner pairs. $2m <= 16$.

*P13.* $n <= 15$ items with weights. Put them into groups so that every group's total weight
is at most `C`. Use the fewest groups.

*P14.* A tree with `n` nodes and `k` colours. Count the ways to colour the nodes so that no
edge joins two nodes of the same colour, modulo $10^9+7$.
]

#key[
*P1.* The forbidden column means "take the best of the previous row *excluding one
column*". Keep the two smallest values of the previous row and their position: if the
forbidden column is where the smallest sits, use the second smallest. That is $O(m n)$, not
$O(m n^2)$.
#code(lang: "js", caption: "P1")[
```js
const minFallingNoSameCol = (g) => {
  const m = g.length; if (!m) return 0;
  const n = g[0].length; if (!n) return 0;
  if (n === 1) return m === 1 ? g[0][0] : Infinity;   // no legal move
  let prev = [...g[0]], cur = new Array(n).fill(0);
  for (let i = 1; i < m; i++) {
    let b1 = Infinity, b2 = Infinity, b1i = -1;
    for (let j = 0; j < n; j++) {
      if (prev[j] < b1) { b2 = b1; b1 = prev[j]; b1i = j; }
      else if (prev[j] < b2) b2 = prev[j];
    }
    for (let j = 0; j < n; j++) cur[j] = g[i][j] + (j === b1i ? b2 : b1);
    [prev, cur] = [cur, prev];
  }
  return prev.reduce((a, b) => a < b ? a : b);
};
```
]
Outputs: `[[1,2,3],[4,5,6],[7,8,9]]` → 13; `[[7]]` → 7; `[[1,99],[99,1]]` → 2;
`[[2,2],[2,2],[2,2]]` → 6; `[]` → 0.
*Edge case:* one column and more than one row has no legal move at all, and returns
`Infinity` — which is honest, and prints as `Infinity` rather than as a huge fake number.

*P2.* Fill a `pal[i][j]` table by increasing length and count the `true` cells.
#code(lang: "js", caption: "P2")[
```js
const countPalindromicSubstrings = (s) => {
  const n = s.length; if (!n) return 0;
  const pal = Array.from({ length: n }, () => new Array(n).fill(false));
  let total = 0;
  for (let len = 1; len <= n; len++)
    for (let i = 0; i + len - 1 < n; i++) {
      const j = i + len - 1;
      if (len === 1)      pal[i][j] = true;
      else if (len === 2) pal[i][j] = s[i] === s[j];
      else                pal[i][j] = s[i] === s[j] && pal[i+1][j-1];
      if (pal[i][j]) total++;
    }
  return total;
};
```
]
Outputs: `'abc'` → 3; `'aaa'` → 6; `''` → 0; `'a'` → 1; `'abba'` → 6; `'abcba'` → 7.
Time $O(n^2)$, space $O(n^2)$. The expand-around-centre method gets $O(1)$ space.

*P3.* Everything outside the LCS must go or be added:
deletions $= |a| - L$, insertions $= |b| - L$, where $L = |"LCS"(a,b)|$.
#code(lang: "js", caption: "P3")[
```js
const convertCost = (a, b) => {
  const l = lcsTable(a, b);
  return [a.length - l, b.length - l];               // [deletions, insertions]
};
```
]
Outputs: `('heap','pea')` → 2 deletions, 1 insertion (LCS is `ea`);
`('abc','abc')` → 0, 0; `('','abc')` → 0, 3.

*P4.* Three indices, three-way match, three-way max.
#code(lang: "js", caption: "P4")[
```js
const lcs3 = (a, b, c) => {
  const x = a.length, y = b.length, z = c.length;
  const dp = Array.from({ length: x+1 }, () =>        // three nested factories,
             Array.from({ length: y+1 }, () =>        // never a nested fill
             new Array(z+1).fill(0)));
  for (let i = 1; i <= x; i++)
    for (let j = 1; j <= y; j++)
      for (let k = 1; k <= z; k++)
        dp[i][j][k] = (a[i-1] === b[j-1] && b[j-1] === c[k-1])
                    ? dp[i-1][j-1][k-1] + 1
                    : Math.max(dp[i-1][j][k], dp[i][j-1][k], dp[i][j][k-1]);
  return dp[x][y][z];
};
```
]
Outputs: `('abcd','acbd','aacd')` → 3; `('abc','abc','abc')` → 3; `('abc','def','ghi')` → 0;
`('','abc','abc')` → 0; `('geeks','geeksfor','geeksforgeeks')` → 5.
Time $O(x y z)$, space $O(x y z)$ — at 100 each that is $10^6$ cells, fine.

*P5.* Naive is $O(n k^2)$: for every colour, scan every other colour. Instead keep the
*two smallest* values of the previous row, exactly as in P1.
#code(lang: "js", caption: "P5")[
```js
const paintKColours = (cost) => {
  const n = cost.length; if (!n) return 0;
  const k = cost[0].length; if (!k) return 0;
  let prev = [...cost[0]], cur = new Array(k).fill(0);
  for (let i = 1; i < n; i++) {
    let b1 = Infinity, b2 = Infinity, b1i = -1;
    for (let c = 0; c < k; c++) {
      if (prev[c] < b1) { b2 = b1; b1 = prev[c]; b1i = c; }
      else if (prev[c] < b2) b2 = prev[c];
    }
    for (let c = 0; c < k; c++) cur[c] = cost[i][c] + (c === b1i ? b2 : b1);
    [prev, cur] = [cur, prev];
  }
  return prev.reduce((a, b) => a < b ? a : b);
};
```
]
Outputs: `[[17,2,17],[16,16,5],[14,3,19]]` → 10; `[[1,5,3],[2,9,4]]` → 5; `[[9,4,7]]` → 4;
`[]` → 0; `[[1,1],[1,1],[1,1]]` → 3.

*P6.* One DFS. At each node keep the two deepest child depths; the diameter through that
node is their sum.
#code(lang: "js", caption: "P6")[
```js
const treeDiameter = (root, ch) => {
  let diameter = 0;                        // local, so repeated calls cannot pollute it
  const depthOf = (u) => {
    let b1 = 0, b2 = 0;
    for (const v of ch[u]) {
      const d = depthOf(v) + 1;
      if (d > b1) { b2 = b1; b1 = d; }
      else if (d > b2) b2 = d;
    }
    diameter = Math.max(diameter, b1 + b2);
    return b1;
  };
  depthOf(root);
  return diameter;
};
```
]
Outputs: the tree `0 → 1,2`; `2 → 3,4` → 3; a single node → 0; a chain of 4 → 3;
a star with 4 leaves → 2.
*Note:* the answer counts *edges*. If the question counts nodes, add 1.
*JavaScript note:* wrapping the accumulator in a closure is not decoration — a module-level
`let diameter` would carry the previous call's value into the next test.

*P7.* Post-order sum, taking the maximum as you go.
#code(lang: "js", caption: "P7")[
```js
const bestSubtreeSum = (root, ch, val) => {
  let best = -Infinity;
  const subSum = (u) => {
    let s = val[u];
    for (const v of ch[u]) s += subSum(v);
    best = Math.max(best, s);
    return s;
  };
  const total = subSum(root);
  return [total, best];
};
```
]
Outputs on `0 → 1,2`; `1 → 3,4`: values `[1,-5,4,3,3]` → total 6, best subtree 6;
values `[-1,-2,-3,-4,-5]` → total $-15$, best subtree $-3$ (the single node 2);
a single node `[7]` → 7 and 7.
*Trap:* `best` must start at `-Infinity`. Starting at 0 returns 0 for an all-negative
tree.

*P8.* `*` refers to the character *before* it, so a star always occupies two pattern slots.
#code(lang: "js", caption: "P8")[
```js
const regexMatch = (s, p) => {
  const n = s.length, m = p.length;
  const dp = Array.from({ length: n+1 }, () => new Array(m+1).fill(false));
  dp[0][0] = true;
  for (let j = 2; j <= m; j++) if (p[j-1] === '*') dp[0][j] = dp[0][j-2];
  for (let i = 1; i <= n; i++)
    for (let j = 1; j <= m; j++) {
      if (p[j-1] === '*') {
        if (j < 2) { dp[i][j] = false; continue; }
        const zero = dp[i][j-2];                                          // "x*" matches nothing
        const more = (p[j-2] === '.' || p[j-2] === s[i-1]) && dp[i-1][j];  // one more x
        dp[i][j] = zero || more;
      } else dp[i][j] = (p[j-1] === '.' || p[j-1] === s[i-1]) && dp[i-1][j-1];
    }
  return dp[n][m];
};
```
]
Outputs: `('aa','a')` → no; `('aa','a*')` → yes; `('ab','.*')` → yes; `('aab','c*a*b')` → yes;
`('mississippi','mis*is*p*.')` → no; `('','')` → yes; `('','a*')` → yes; `('','a')` → no;
`('a','')` → no; `('abc','a.c')` → yes; `('aaa','a*a')` → yes; `('aaa','ab*a*c*a')` → yes.
*JavaScript note:* do not reach for the built-in `RegExp` here. `new RegExp(p)` would match
a *substring* unless you anchor it, `'.'` and `'*'` mean different things in a real regular
expression, and the interviewer is asking you to write the DP, not to call a library.
*Difference from wildcard matching:* here `*` needs a partner character; there `*` stood
alone. Read the question twice before choosing a recurrence.

*P9.* Interval DP. A prefix-sum array gives the cost of the final merge of any interval in
$O(1)$.
#code(lang: "js", caption: "P9")[
```js
const mergeStones = (a) => {
  const n = a.length;
  if (n <= 1) return 0;
  const pre = new Array(n + 1).fill(0);
  for (let i = 0; i < n; i++) pre[i+1] = pre[i] + a[i];
  const dp = Array.from({ length: n }, () => new Array(n).fill(0));
  for (let len = 2; len <= n; len++)
    for (let i = 0; i + len - 1 < n; i++) {
      const j = i + len - 1;
      dp[i][j] = Infinity;
      for (let k = i; k < j; k++)
        dp[i][j] = Math.min(dp[i][j], dp[i][k] + dp[k+1][j]);
      dp[i][j] += pre[j+1] - pre[i];
    }
  return dp[0][n-1];
};
```
]
Outputs: `[4,3,3,4]` → 28; `[1,2,3]` → 9; `[5]` → 0; `[]` → 0; `[1,1,1,1]` → 8;
`[10,1,1,10]` → 36.
*Why `+= pre[j+1] - pre[i]` outside the `k` loop?* Because the final merge of the interval
always costs the whole interval's weight, whatever the split point is.

*P10.* Add one bit to the state: how many walls have been removed (0 or 1).
#code(lang: "js", caption: "P10")[
```js
const pathsWithOneRemoval = (g) => {
  const m = g.length; if (!m) return 0;
  const n = g[0].length; if (!n) return 0;
  // dp[i][j] = [ways with no wall removed, ways with exactly one removed]
  const dp = Array.from({ length: m }, () => Array.from({ length: n }, () => [0, 0]));
  for (let i = 0; i < m; i++)
    for (let j = 0; j < n; j++) {
      let in0 = 0, in1 = 0;
      if (i === 0 && j === 0) { in0 = 1; in1 = 0; }
      else {
        if (i > 0) { in0 += dp[i-1][j][0]; in1 += dp[i-1][j][1]; }
        if (j > 0) { in0 += dp[i][j-1][0]; in1 += dp[i][j-1][1]; }
      }
      if (g[i][j] === 1) { dp[i][j][0] = 0;   dp[i][j][1] = in0; }
      else               { dp[i][j][0] = in0; dp[i][j][1] = in1; }
    }
  return dp[m-1][n-1][0] + dp[m-1][n-1][1];
};
```
]
Outputs: `[[0,0,0],[0,1,0],[0,0,0]]` → 6 (all six paths become legal);
`[[0,1],[1,0]]` → 2; `[[0,1,0],[1,1,1],[0,1,0]]` → 0 (every route needs two removals);
`[[1]]` → 1 (remove the start wall); `[[0]]` → 1; `[[0,0],[1,1],[0,0]]` → 2.
*Note the doubly nested `Array.from`.* The inner pair `[0, 0]` must be a fresh array per
cell; `new Array(n).fill([0, 0])` would give every cell in a row the same pair.

*P11.* Run the tree DP of Example 21 storing both values per node, then walk down from the
root deciding at each node, remembering whether the parent was taken.
#code(lang: "js", caption: "P11 — the DFS")[
```js
const dfs = (u) => {
  withU[u] = val[u];
  withoutU[u] = 0;
  for (const v of ch[u]) {
    dfs(v);
    withU[u]    += withoutU[v];
    withoutU[u] += Math.max(withU[v], withoutU[v]);
  }
};
```
]
#code(lang: "js", caption: "P11 — the reconstruction")[
```js
const collect = (u, allowed, out) => {
  const takeU = allowed && withU[u] >= withoutU[u];
  if (takeU) out.push(u);
  for (const v of ch[u]) collect(v, !takeU, out);
};
```
]
Both live inside one `mwisTree(root, ch, val)` wrapper that owns `withU` and `withoutU`,
runs `dfs(root)`, then `collect(root, true, out)`, and returns
`[Math.max(withU[root], withoutU[root]), out]`.
On the tree `0 → 1,2`; `1 → 3,4`; `2 → 5,6`:
values `[10,5,5,4,4,4,4]` → total 26, nodes `0 3 4 5 6`;
values `[1,50,1,1,1,1,1]` → total 52, nodes `1 5 6`;
a single node `[9]` → 9.

*P12.* Bitmask over people. Always pair the *lowest unpaired* person — that removes the
double counting automatically.
#code(lang: "js", caption: "P12")[
```js
const countPairings = (ok) => {
  const n = ok.length;
  if (n === 0) return 1;
  if (n % 2) return 0;
  const dp = new Array(1 << n).fill(0);
  dp[0] = 1;
  for (let mask = 0; mask < (1 << n); mask++) {
    if (!dp[mask]) continue;
    let i = 0;
    while (i < n && (mask & (1 << i))) i++;      // lowest unpaired person
    if (i === n) continue;
    for (let j = i + 1; j < n; j++)
      if (!(mask & (1 << j)) && ok[i][j])
        dp[mask | (1 << i) | (1 << j)] += dp[mask];
  }
  return dp[(1 << n) - 1];
};
```
]
Outputs: 4 people, everyone compatible → 3; 6 people, everyone compatible → 15;
2 people who may *not* pair → 0; 0 people → 1; 4 people where only `0-1` and `2-3` are
allowed → 1.
*Why fix the lowest unpaired person?* Otherwise the pairing ${(0,1),(2,3)}$ is counted once
for each order in which the pairs are formed.

*P13.* Bitmask plus a submask loop. `sum[mask]` is precomputed with the lowest-bit trick.
#code(lang: "js", caption: "P13")[
```js
const minGroups = (w, C) => {
  const n = w.length;
  if (n === 0) return 0;
  const full = (1 << n) - 1;
  const sum = new Array(1 << n).fill(0);
  for (let mask = 1; mask <= full; mask++) {
    const lb = mask & -mask, i = 31 - Math.clz32(lb);   // lowest set bit, and its index
    sum[mask] = sum[mask ^ lb] + w[i];
  }
  const dp = new Array(1 << n).fill(Infinity);
  dp[0] = 0;
  for (let mask = 0; mask <= full; mask++) {
    if (dp[mask] === Infinity) continue;
    const rest = full ^ mask;
    for (let sub = rest; sub; sub = (sub - 1) & rest)   // every sub-set of `rest`
      if (sum[sub] <= C) dp[mask | sub] = Math.min(dp[mask | sub], dp[mask] + 1);
  }
  return dp[full] === Infinity ? -1 : dp[full];
};
```
]
Outputs: `[3,3,3,3]` with `C=6` → 2, `C=5` → 4, `C=12` → 1; `[10]` with `C=5` → $-1$,
`C=10` → 1; `[]` → 0; `[1,2,3,4,5]` with `C=5` → 3, `C=15` → 1.
*JavaScript note:* `31 - Math.clz32(lb)` is the `__builtin_ctz` of C++ — `Math.clz32`
counts leading zeros in a 32-bit word, and for a value with exactly one bit set that gives
the bit's index directly. Verified: `31 - Math.clz32(0b1000)` is 3.
Time $O(3^n)$ — safe to $n = 15$, too slow at $n = 20$.

*P14.* Tree DP, but the answer collapses to a formula: the root has `k` choices and every
other node has `k-1` (anything except its parent's colour).
#code(lang: "js", caption: "P14 — the tree DP (used here to verify the formula)")[
```js
const MOD = 1000000007;

const dpColour = (u, parentColour, ch, k) => {
  let total = 0;
  for (let c = 1; c <= k; c++) {
    if (c === parentColour) continue;
    let ways = 1;
    for (const v of ch[u]) ways = ways * dpColour(v, c, ch, k) % MOD;
    total = (total + ways) % MOD;
  }
  return total;
};
```
]
*The modular-multiply caveat applies here.* `ways * dpColour(...)` can reach
$(10^9)^2 = 10^18$, past $2^53 - 1$, so on a large tree this multiply loses precision. It is
exact for the small trees below, and the closed form makes it moot — but if you ever need
this DP at scale, do the multiply in `BigInt` (or with a `mulmod` helper that splits the
operands). Naming that limitation is the point of the exercise.
The closed form is $k (k-1)^(n-1)$. On the tree `0 → 1,2`; `1 → 3,4` ($n = 5$) the two
methods agree exactly (both were run): $k=1$ → 0, $k=2$ → 2, $k=3$ → 48, $k=4$ → 324.
A single node with $k=3$ → 3. A star with 4 nodes and $k=3$ → 24.
*Interview point:* notice that the answer does not depend on the *shape* of the tree at
all, only on `n`. That is because every node has exactly one parent.
]

#pagebreak(weak: true)

#revision[

*The four lines every DP in this chapter starts from.*

#code(lang: "js", caption: "Setup")[
```js
const grid2D = (r, c, v) =>
  Array.from({ length: r }, () => new Array(c).fill(v));
const popcount = (m) => {
  let c = 0; while (m) { m &= m - 1; c++; } return c;
};
const lowBitIndex = (m) => 31 - Math.clz32(m & -m);  // __builtin_ctz
const deepCopy = (g) => g.map(r => [...r]);         // [...g] is NOT enough
```
]
Unreached is `Infinity`, worst-so-far is `-Infinity`, swap two rows with
`[prev, cur] = [cur, prev]`. No toolkit import is needed in this chapter — dynamic
programming needs arrays, not a heap, a DSU or a deque. When a DP problem *does* need a
priority queue, that is the *JS Toolkit* appendix's `MinHeap`.

*Template 1 — grid. One rolling row.*

#code(lang: "js", caption: "Grid")[
```js
const row = new Array(n).fill(1);
for (let i = 1; i < m; i++)
  for (let j = 1; j < n; j++)
    row[j] += row[j-1];            // row[j] = above, row[j-1] = left
return row[n-1];
```
]

*Template 2 — two strings. `dp[i][j]` = the FIRST i and the FIRST j characters.*

#code(lang: "js", caption: "Two strings")[
```js
const dp = Array.from({ length: n+1 }, () => new Array(m+1).fill(0));
for (let i = 1; i <= n; i++)
  for (let j = 1; j <= m; j++)
    dp[i][j] = a[i-1] === b[j-1] ? dp[i-1][j-1] + 1            // LCS: match
                                 : Math.max(dp[i-1][j], dp[i][j-1]);
// substring? write 0 on mismatch and track the max cell instead
return dp[n][m];
```
]

*Template 3 — interval. Loop by LENGTH, never by `i` then `j`.*

#code(lang: "js", caption: "Interval")[
```js
for (let len = 2; len <= n; len++)
  for (let i = 0; i + len - 1 < n; i++) {
    const j = i + len - 1;
    dp[i][j] = Infinity;
    for (let k = i; k < j; k++)
      dp[i][j] = Math.min(dp[i][j], dp[i][k] + dp[k+1][j] + cost(i, k, j));
  }
```
]

*Template 4 — tree. One DFS, return a pair.*

#code(lang: "js", caption: "Tree")[
```js
const go = (u) => {
  let take = val[u], skip = 0;
  for (const v of ch[u]) {
    const [t, s] = go(v);
    take += s;                     // u taken   -> children skipped
    skip += Math.max(t, s);        // u skipped -> children free
  }
  return [take, skip];
};
return Math.max(...go(root));     // depth ~10^4: then an explicit stack
```
]

*Template 5 — bitmask. Two shapes; pick by one question.*

#code(lang: "js", caption: "Bitmask")[
```js
// Shape A — dp[mask] only. Use when the next cost does NOT
// depend on which item was picked last.
const dp = new Array(1 << n).fill(Infinity);
dp[0] = 0;
for (let mask = 0; mask < (1 << n); mask++) {
  if (dp[mask] === Infinity) continue;
  const i = popcount(mask);                  // next slot, free of charge
  if (i === n) continue;
  for (let j = 0; j < n; j++)
    if (!(mask & (1 << j)))
      dp[mask | (1<<j)] = Math.min(dp[mask | (1<<j)], dp[mask] + cost(i, j));
}

// Shape B — dp[mask][u]. Use when WHERE YOU STAND changes the next cost.
dp2[1][0] = 0;
for (let mask = 1; mask < (1 << n); mask++)
  for (let u = 0; u < n; u++) {
    if (dp2[mask][u] === Infinity || !(mask & (1 << u))) continue;
    for (let v = 0; v < n; v++)
      if (!(mask & (1 << v)))
        dp2[mask | (1<<v)][v] =
          Math.min(dp2[mask | (1<<v)][v], dp2[mask][u] + d[u][v]);
  }

// Sub-sets of a mask, for "split into groups": O(3^n) overall.
for (let sub = rest; sub; sub = (sub - 1) & rest) { /* ... */ }
```
]

*When to use which shape.*

#table(columns: (1.4fr, 1fr, 1fr),
  [*The question says...*], [*Shape*], [*State*],
  [move right / down on a grid],                  [grid],           [`dp[i][j]` = cell],
  [compare, align, transform two sequences],      [two strings],    [`dp[i][j]` = prefixes],
  [insert brackets, cut, merge, burst],           [interval],       [`dp[i][j]` = the piece `i..j`],
  [subtree, parent, child, no two adjacent],      [tree],           [`dp[u]` = a pair per node],
  [$n <= 20$, "assign each to each"],             [bitmask A],      [`dp[mask]`],
  [$n <= 20$ and the *order* matters (a tour)],   [bitmask B],      [`dp[mask][u]`],
  [$n <= 15$, "split into groups"],               [bitmask + submask], [`dp[mask]`, sub-set loop],
  ["at most one exception / one removal"],        [any of the above + 1 bit], [`dp[...][0..1]`],
)

*Complexity table.*

#table(columns: (1.5fr, auto, auto, 1fr),
  [*Problem*], [*Time*], [*Space*], [*Note*],
  [grid paths / min path sum],        [$O(m n)$],       [$O(n)$],   [one rolling row],
  [falling path, two robots],         [$O(m n)$ / $O(m n^2)$], [$O(n)$ / $O(n^2)$], [9 moves is a constant],
  [LCS, edit distance, interleaving],  [$O(n m)$],      [$O(m)$],   [two rows; full table only to *print* the answer],
  [longest common substring],         [$O(n m)$],       [$O(m)$],   [answer is the max cell, not the corner],
  [longest palindromic subsequence],  [$O(n^2)$],       [$O(n)$],   [LCS of `s` and its reverse],
  [distinct subsequences],            [$O(n m)$],       [$O(m)$],   [`j` loop BACKWARDS],
  [count / largest all-ones square],  [$O(m n)$],       [$O(n)$],   [`1 + min` of three neighbours],
  [wildcard / regex matching],        [$O(n m)$],       [$O(m)$],   [],
  [palindrome cuts],                  [$O(n^2)$],       [$O(n^2)$], [$O(n)$ space with expand-around-centre],
  [matrix chain, stick cut, merge piles], [$O(n^3)$],   [$O(n^2)$], [interval; $n <= 300$],
  [bursting balloons],                [$O(n^3)$],       [$O(n^2)$], [decide who bursts *last*],
  [bracketings to True],              [$O(k^3)$],       [$O(k^2)$], [keep a False table too],
  [tree DP (rob, diameter, best path)], [$O(n)$],       [$O(h)$],   [$h$ is the recursion depth],
  [assignment (bitmask A)],           [$O(2^n n)$],     [$O(2^n)$], [$n <= 20$],
  [TSP (bitmask B)],                  [$O(2^n n^2)$],   [$O(2^n n)$], [$n <= 18$],
  [split into groups (submask)],      [$O(3^n)$],       [$O(2^n)$], [$n <= 15$],
)

*The JavaScript facts this chapter depends on.*

#table(columns: (auto, 1fr),
  [`Array(n).fill([])`], [stores *one* array in all $n$ slots, so writing `dp[0][1]` writes every row. Always `Array.from({ length: n }, () => ...)`.],
  [`[...grid]`],        [a SHALLOW copy — the rows are shared. A real 2D copy is `grid.map(r => [...r])`.],
  [`Infinity`],         [replaces `INT_MAX`. `Infinity + w` stays `Infinity`, so a sentinel can never be relaxed by accident. Use `-Infinity` for a max accumulator.],
  [numbers are doubles],[exact only to $2^53 - 1$. `uniquePaths(29,29)` is exact; `uniquePaths(32,32)` is *wrong*. Past that, `BigInt`.],
  [modular multiply],   [`(a * b) % (10^9+7)` is WRONG in plain numbers — the product reaches $10^18$. Additive counting mod $10^9+7$ is fine. A small modulus like 1003 is fine either way.],
  [recursion depth],    [about $10^4$ frames. Every tree DP here throws `RangeError` on a 100000-node chain — use an explicit stack.],
  [bitwise ops],        [32-bit signed. `1 << 31` is negative; bitmask DP is capped near $n = 30$ regardless of time.],
  [integer division],   [`(n+1) / 2` gives a *fraction*. Index arithmetic needs `>> 1`, `Math.floor` or `| 0`.],
  [strings],            [immutable: build answers in an array and `join('')`. There is no `s.reverse()` — use `[...s].reverse().join('')`.],
  [`arr.sort()`],       [LEXICOGRAPHIC. `[10,9,1].sort()` gives `[1,10,9]`. Numbers always need `sort((a, b) => a - b)`, and a comparator must return a *number*, not a boolean.],
  [`Math.max(...arr)`], [spreads every element as an argument and throws `RangeError` past roughly $2 times 10^5$. Use `arr.reduce((a, b) => a > b ? a : b)`.],
  [no `popcount`],      [write the Kernighan loop. No `__builtin_ctz` either — `31 - Math.clz32(m & -m)`.],
)

*The top traps, in the order they bite.*

+ *Index shift.* `dp[i][j]` means the *first `i`* characters, so the character is `a[i-1]`.
  Pick that convention once and never change it. This is the number-one 2D DP bug.
+ *Interval loops.* `len` outermost. `i` then `j` reads cells that are not ready yet.
+ *Burst LAST, not first.* The two sides are only independent once you fix which element
  survives longest. Say the sentence; it is what the interviewer is listening for.
+ *Backwards `j` loop* in distinct-subsequences, exactly as in 0/1 knapsack. Forwards
  turns `('aaa','aa')` from 3 into 6.
+ *The base case written in the wrong place.* `cur[0] = i` belongs inside the `i` loop,
  before the `j` loop — the rolling arrays are reused, so stale data really is waiting.
+ *The accumulator.* Start it at `-Infinity`, not 0, or an all-negative tree returns 0 —
  and keep it in a closure, because a module-level `let` carries one test's answer into
  the next.
+ *The length check first.* `isInterleave` must reject `|c| != |a| + |b|` before indexing,
  because an out-of-range string index is `undefined`, not a crash.

*The one sentence to remember.*
Nothing about the method changed from Chapter 17 — only the *shape of the state*. Name the
state, name the transition, name the base case, and the code writes itself; everything else
on this page is JavaScript bookkeeping.
]

]
