#import "../../shared/lib/style.typ": *

#chapter(num: 11, title: "Recursion & Backtracking",
  tagline: "Choose, explore, un-choose — and know when to stop early.")[

#section[Pattern in one page]

A recursive function solves a problem by calling *itself on a smaller version* of the
same problem. Every recursive function has exactly three parts.

#formulas(title: "The three parts of any recursion")[
1. *Base case* — the smallest input, answered with no further call. Without it the
   program runs until the stack dies.
2. *Smaller call* — call yourself on an input that is strictly closer to the base case.
3. *Combine* — turn the answer of the smaller call into the answer for this input.
]

#code(lang: "js", caption: "The shape of every recursion")[
```js
function f(state) {
  if (isBase(state)) return baseAnswer;   // 1. base case
  const small = f(shrink(state));         // 2. smaller call
  return combine(state, small);           // 3. combine
}
```
]

#subsection[The call stack — draw it once and you will never fear recursion again]

When `f(3)` calls `f(2)`, the engine *pauses* `f(3)` and remembers where it stopped.
That paused copy sits on the *call stack*. Every recursive call pushes a new frame.
Every `return` pops one.

#diagram(height: 5.4cm, caption: "fact(3) grows the stack down, then unwinds up")[
  #dnode(0pt, 0pt,   3.2cm, 0.8cm, "fact(3) waits")
  #dnode(0pt, 1.4cm, 3.2cm, 0.8cm, "fact(2) waits")
  #dnode(0pt, 2.8cm, 3.2cm, 0.8cm, "fact(1) waits")
  #dnode(0pt, 4.2cm, 3.2cm, 0.8cm, "fact(1) = 1", fill: rgb("#e6f0e6"))
  #darrow(3.4cm, 0.4cm, 3.4cm, 1.4cm, label: "calls")
  #darrow(3.4cm, 1.8cm, 3.4cm, 2.8cm, label: "calls")
  #darrow(3.4cm, 3.2cm, 3.4cm, 4.2cm, label: "calls")
  #dnode(5.0cm, 4.2cm, 3.6cm, 0.8cm, "returns 1", fill: rgb("#f7f3e6"))
  #dnode(5.0cm, 2.8cm, 3.6cm, 0.8cm, "1 x 1 = 1", fill: rgb("#f7f3e6"))
  #dnode(5.0cm, 1.4cm, 3.6cm, 0.8cm, "2 x 1 = 2", fill: rgb("#f7f3e6"))
  #dnode(5.0cm, 0pt,   3.6cm, 0.8cm, "3 x 2 = 6", fill: rgb("#f7f3e6"))
  #darrow(8.8cm, 4.2cm, 8.8cm, 3.2cm)
  #darrow(8.8cm, 2.8cm, 8.8cm, 1.8cm)
  #darrow(8.8cm, 1.4cm, 8.8cm, 0.4cm)
]

#subsection[Backtracking = recursion that undoes its own moves]

*Backtracking* is recursion over *choices*. At each step you pick one option, walk
deeper, and when you come back you *put the world back the way you found it*.

#formulas(title: "The three lines you will write a hundred times")[
```
choose     ->  cur.push(option);   used[option] = true;
explore    ->  go(nextLevel);
un-choose  ->  cur.pop();          used[option] = false;
```
*Invariant:* when `go(level)` returns, every shared structure (`cur`, `used`, the grid)
is exactly the same as when `go(level)` was entered. If that is true at every level,
your answer list is correct.
]

#code(lang: "js", caption: "The universal backtracking template")[
```js
function solve(input) {
  const out = [], cur = [];
  const go = (state) => {
    if (isComplete(state)) { out.push([...cur]); return; }   // COPY cur, never cur itself
    for (const option of optionsAt(state)) {
      if (!isLegal(state, option)) continue;   // prune: never enter a dead branch
      apply(cur, option);                      // choose
      go(next(state, option));                 // explore
      undo(cur, option);                       // un-choose  <- never forget this line
    }
  };
  go(startState);
  return out;
}
```
]

#trap[
*Two bugs, both fatal, both invisible at first.*

1. *Forgetting `undo`.* The program still runs; it just prints garbage, because level 3
   sees leftovers from level 5. If your output has too many elements, or elements that
   are too long, look for a missing `cur.pop()`.

2. *`out.push(cur)` instead of `out.push([...cur])`.* In JavaScript an array is a
   *reference*. `out.push(cur)` stores a pointer to the one live array, and every
   `cur.pop()` afterwards empties it. Your answer list ends up full of identical empty
   arrays. This is the single most common JS backtracking bug. Always copy:
   `[...cur]`, or `cur.slice()`.
]

#subsection[Which template do I reach for?]

#table(columns: (auto, 1fr, auto),
  [*You are asked for*], [*Shape*], [*Cost*],
  [one number (count, max, yes/no)], [return a value, add a memo if states repeat], [often $O(n^2)$ with a memo],
  [all subsets / subsequences], [pick or skip at each index], [$O(2^n times n)$],
  [all orderings], [swap in place, or a `used[]` array], [$O(n! times n)$],
  [all combinations summing to a target], [loop `j` from `i`, recurse with `j` or `j+1`], [depends on the target],
  [place items on a board], [one row per level + `Set`s for the blocked lines], [$O(n!)$ with pruning],
  [fill a grid], [find the first blank, try every value], [exponential, prune hard],
)

#note[
Rough budget for a 1-second coding round in Node: $2^n$ is fine up to $n approx 20$.
$n!$ is fine up to $n approx 9$. JavaScript is roughly 2 to 5 times slower than C++ on
this kind of work, so shave one or two off the exponent compared to what you may have
read elsewhere. If $n$ is 40 and the answer is a single number, recursion alone will not
pass — you need memoisation (Chapter 17) or a different idea entirely.
]

#trick[
*Count the leaves, not the nodes.* A "pick or skip" tree on $n$ items has $2^n$ leaves.
If you copy an array of length up to $n$ at each leaf — and in JS you must, see the trap
above — the true cost is $O(2^n times n)$, not $O(2^n)$. Interviewers listen for that
extra $n$.
]

#formulas(title: "The four JavaScript facts this chapter depends on")[
1. *`arr.sort()` sorts as text.* `[10, 9, 1].sort()` gives `[1, 10, 9]`. Every sort in
   this chapter must be `arr.sort((a, b) => a - b)`.
2. *Numbers are doubles.* They are exact only up to
   `Number.MAX_SAFE_INTEGER = 9007199254740991` ($2^53 - 1$). Anything bigger needs
   `BigInt`.
3. *The recursion depth limit is roughly $10^4$*, not $10^6$. A deep recursion throws
   `RangeError: Maximum call stack size exceeded`.
4. *Spread is a shallow copy.* `[...grid]` copies the outer array only; the rows are
   still shared. For a 2-D grid you need `grid.map(row => [...row])`.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Write `fact(n)` = $1 times 2 times ... times n$, with `fact(0) = 1`.
Constraints: $0 <= n <= 30$. Target: $O(n)$ time.
Edge cases: $n = 0$; $n = 23$ (where an ordinary JS number stops being exact).

#sol[
Base case is $n <= 1$, because both $0!$ and $1!$ equal 1. Then $n! = n times (n-1)!$.

#code(lang: "js", caption: "factorial with ordinary numbers")[
```js
function factNum(n) {
  if (n <= 1) return 1;            // base case
  return n * factNum(n - 1);
}
```
]

#code(lang: "js", caption: "factorial with BigInt")[
```js
function fact(n) {
  if (n <= 1n) return 1n;          // note the n suffix: these are BigInts
  return n * fact(n - 1n);
}
```
]

Ran both and compared every result against the exact BigInt value:

#table(columns: (auto, 1fr, auto),
  [*n*], [*`factNum(n)` prints*], [*exact?*],
  [20], [`2432902008176640000`], [yes],
  [21], [`51090942171709440000`], [yes],
  [22], [`1.1240007277776077e+21`], [yes],
  [23], [`2.585201673888498e+22`], [*no*],
  [25], [`1.5511210043330986e+25`], [*no*],
)

`fact(23n)` gives the true value, `25852016738884976640000`. The ordinary number is
`25852016738884980000` — close, and wrong.

#complexity(time: $O(n)$, space: $O(n)$, note: "space is the call stack: n paused frames")

#ans[`fact(20n) = 2432902008176640000n`]
]
]

#trap[
*Numbers in JavaScript are doubles.* `Number.MAX_SAFE_INTEGER` is
`9007199254740991`. Above that, the gaps between representable values grow, and
arithmetic silently rounds. I ran this:

```js
Number.MAX_SAFE_INTEGER + 1 === Number.MAX_SAFE_INTEGER + 2   // true
```

Two different sums compare equal. Notice that $20!$ and $21!$ are *far* above the safe
limit and still print exactly — factorials contain many factors of 2, so they happen to
land on representable values. $23!$ is the first that does not. *Do not rely on luck.*
The rule: if a count, a product or a sum can pass $9 times 10^15$, use `BigInt`.
]

#note[
*BigInt rules you need.* Write literals with an `n` suffix (`5n`). You may not mix
`BigInt` and `Number` in one expression — `5n + 1` throws a `TypeError`; write `5n + 1n`.
Division truncates, so `7n / 2n` is `3n`. Convert with `BigInt(x)` and `Number(x)`, and
print with `String(x)` or `x.toString()`.
]

#ex(2, tier: 0, asked: "warm-up")[
Sum the digits of a non-negative number. `4073` gives $4+0+7+3 = 14$.
Constraints: $0 <= n <= 10^15$. Target: $O(log n)$.
Edge cases: $n = 0$; a single digit.

#sol[
Peel one digit with `n % 10`, shrink with `Math.floor(n / 10)`.

#code(lang: "js", caption: "digit sum")[
```js
function digitSum(n) {
  if (n === 0) return 0;                     // base case
  return (n % 10) + digitSum(Math.floor(n / 10));
}
```
]

Trace of `digitSum(4073)`:

#table(columns: (auto, auto, auto, auto),
  [*call*], [`n`], [`n % 10`], [*next call*],
  [1], [4073], [3], [`digitSum(407)`],
  [2], [407],  [7], [`digitSum(40)`],
  [3], [40],   [0], [`digitSum(4)`],
  [4], [4],    [4], [`digitSum(0)`],
  [5], [0],    [—], [returns 0],
)

Unwinding: $0 -> 4 -> 4 -> 11 -> 14$.

Ran it: `digitSum(0) = 0`, `digitSum(9) = 9`, `digitSum(4073) = 14`.

#complexity(time: $O(log n)$, space: $O(log n)$, note: "one frame per digit")

#ans[14]
]
]

#trap[
`n / 10` in JavaScript is *not* integer division — `407 / 10` is `40.7`. You must write
`Math.floor(n / 10)`. Forget it and the recursion never reaches 0, so it runs until the
stack overflows. This bites programmers coming from C++, Java or Python's `//`.
]

#ex(3, tier: 0, asked: "Infosys pattern")[
Compute $a^b$ using as few multiplications as possible.
Constraints: $1 <= a <= 10$, $0 <= b <= 100$. The answer may be enormous, so use
`BigInt`. Target: $O(log b)$.
Edge cases: $b = 0$; $b$ odd; a result well past $2^53$.

#sol[
#approach(1, "Multiply b times", verdict: "O(b) — fine for small b, but we can do better")

#approach(2, "Halve the exponent", verdict: "O(log b) — optimal")

The key fact: $a^b = (a^(b\/2))^2$ when $b$ is even, and $a^b = (a^(b\/2))^2 times a$
when $b$ is odd. So one call solves *half* the exponent.

#code(lang: "js", caption: "fast power with BigInt")[
```js
function power(a, b) {
  if (b === 0n) return 1n;
  const half = power(a, b / 2n);     // ONE call; BigInt division truncates
  const sq = half * half;
  return (b % 2n === 1n) ? sq * a : sq;
}
```
]

Ran it:

#table(columns: (auto, 1fr),
  [`power(2n, 0n)`],  [`1`],
  [`power(2n, 10n)`], [`1024`],
  [`power(3n, 13n)`], [`1594323`],
  [`power(2n, 40n)`], [`1099511627776`],
  [`power(2n, 80n)`], [`1208925819614629174706176`],
)

#complexity(time: $O(log b)$, space: $O(log b)$)

*The idea that unlocked it:* store the half in a variable. If you write
`return power(a, b/2n) * power(a, b/2n);` you compute the same thing twice and the cost
jumps straight back to $O(b)$.

#ans[`power(2n, 80n) = 1208925819614629174706176n`]
]
]

#ex(4, tier: 0, asked: "warm-up")[
Reverse a string using recursion only — no loop, no `reverse()`.
Constraints: length up to $5000$ (see the trap about depth).
Edge cases: empty string; one character.

#sol[
Strings in JavaScript are *immutable*, so you cannot swap characters in place. Turn the
string into an array of characters first, swap there, then join it back.

#code(lang: "js", caption: "reverse by swapping the two ends")[
```js
function rev(a, i, j) {
  if (i >= j) return;                    // 0 or 1 characters left
  [a[i], a[j]] = [a[j], a[i]];           // destructuring swap
  rev(a, i + 1, j - 1);
}

function reverseString(str) {
  const a = [...str];                    // "abc" -> ["a","b","c"]
  rev(a, 0, a.length - 1);
  return a.join('');
}
```
]

Ran it: `reverseString("")` gives `""` (here `i = 0`, `j = -1`, so `i >= j` fires at
once), `reverseString("a")` gives `"a"`, and `reverseString("recursion")` gives
`"noisrucer"`.

#complexity(time: $O(n)$, space: $O(n)$, note: "n/2 stack frames plus the character array")

#ans[`noisrucer`]
]
]

#trap[
*Recursion depth in JavaScript is small.* I measured it on Node: a plain recursive
function threw `RangeError: Maximum call stack size exceeded` at about *12,500* levels,
and it varies with how many local variables each frame holds. That is roughly $10^4$ —
one hundred times less than C++.

So a recursion of depth $10^5$ *will* crash. If the depth can reach $10^4$, rewrite it as
a loop or an explicit stack. Example 36 shows exactly how.
]

#ex(5, tier: 0, asked: "TCS NQT pattern")[
A staircase has $n$ steps. You climb 1 or 2 steps at a time. How many different climbs
reach the top? Constraints: $1 <= n <= 70$. Target: $O(n)$.
Edge cases: $n = 1$ (answer 1); $n = 50$; $n = 70$ (check the safe-integer limit).

#sol[
#approach(1, "Plain recursion", verdict: "O(2^n), dies around n = 40")

From step $n$ you arrived either from $n-1$ or from $n-2$. So
`ways(n) = ways(n-1) + ways(n-2)`. Base: `ways(0) = 1` (one way to already be there) and
`ways(negative) = 0`.

#approach(3, "Remember answers you already computed", verdict: "O(n) — optimal")

`ways(n-1)` and `ways(n-2)` overlap enormously. Store each answer the first time.

#code(lang: "js", caption: "stairs with a memo")[
```js
function climb(n) {
  const memo = new Array(n + 1).fill(-1);
  const ways = (k) => {
    if (k === 0) return 1;
    if (k < 0) return 0;
    if (memo[k] !== -1) return memo[k];       // already solved
    return memo[k] = ways(k - 1) + ways(k - 2);
  };
  return ways(n);
}
```
]

Ran it: `climb(1) = 1`, `climb(2) = 2`, `climb(5) = 8`, `climb(50) = 20365011074`.
I also checked `climb(50) <= Number.MAX_SAFE_INTEGER` — true, so ordinary numbers are
still exact here.

#complexity(time: $O(n)$, space: $O(n)$)

*The idea:* the recursion tree has only $n$ *distinct* nodes. Caching turns a tree into a
line. That one trick is the whole of Chapter 17.

#ans[`climb(50) = 20365011074`]
]
]

#trap[
The answer for $n = 70$ is the 71st Fibonacci number, about $3 times 10^14$ — still under
$9 times 10^15$, so it is safe. But $n = 80$ is about $2.3 times 10^16$, which is *past*
the safe limit and silently wrong. When a count grows exponentially, work out the largest
value the constraints allow *before* you choose `Number` over `BigInt`.
]

#ex(6, tier: 0, asked: "warm-up")[
Greatest common divisor of two numbers, recursively.
Constraints: $0 <= a, b <= 10^15$. Target: $O(log min(a,b))$.
Edge cases: one of them is 0; they are coprime.

#sol[
Euclid's fact: $gcd(a, b) = gcd(b, a mod b)$, and $gcd(a, 0) = a$.

#code(lang: "js", caption: "gcd")[
```js
function gcd(a, b) {
  if (b === 0) return a;
  return gcd(b, a % b);
}
```
]

Ran it: `gcd(0, 7) = 7`, `gcd(12, 18) = 6`, `gcd(17, 5) = 1`.

Trace of `gcd(12, 18)`: $(12,18) -> (18,12) -> (12,6) -> (6,0) -> 6$. The first call
flips the pair for free, so you never need to sort the inputs.

#complexity(time: $O(log min(a,b))$, space: $O(log min(a,b))$)

#ans[6]
]
]

#note[
`%` in JavaScript is the *remainder*, not a true modulo: `-7 % 3` is `-1`, not `2`. For
`gcd` on non-negative inputs it makes no difference, but the moment negatives can appear
you want `((a % m) + m) % m`. Chapter 20 leans on this heavily.
]

#section[Tier 1 — the two trees everything is built on]
#tier-header(1)

Almost every backtracking problem in a placement round is one of two trees:

#diagram(height: 4.6cm, caption: "left: the pick-or-skip tree (subsets). right: the slot tree (permutations)")[
  #dnode(0.3cm, 0pt, 1.6cm, 0.6cm, "i = 0")
  #dnode(0pt, 1.2cm, 1.4cm, 0.6cm, "skip 1")
  #dnode(2.0cm, 1.2cm, 1.4cm, 0.6cm, "take 1")
  #darrow(1.1cm, 0.6cm, 0.7cm, 1.2cm)
  #darrow(1.1cm, 0.6cm, 2.7cm, 1.2cm)
  #dnode(0pt, 2.4cm, 1.4cm, 0.6cm, "skip 2")
  #dnode(1.5cm, 2.4cm, 1.4cm, 0.6cm, "take 2")
  #dnode(3.0cm, 2.4cm, 1.4cm, 0.6cm, "skip 2")
  #dnode(4.5cm, 2.4cm, 1.4cm, 0.6cm, "take 2")
  #darrow(0.7cm, 1.8cm, 0.7cm, 2.4cm)
  #darrow(0.7cm, 1.8cm, 2.2cm, 2.4cm)
  #darrow(2.7cm, 1.8cm, 3.7cm, 2.4cm)
  #darrow(2.7cm, 1.8cm, 5.2cm, 2.4cm)
  #dnode(0pt, 3.6cm, 5.9cm, 0.6cm, "4 leaves = 4 subsets of {1,2}", fill: rgb("#e6f0e6"))

  #dnode(8.6cm, 0pt, 2.2cm, 0.6cm, "slot 0 empty")
  #dnode(7.2cm, 1.2cm, 1.5cm, 0.6cm, "put 1")
  #dnode(9.0cm, 1.2cm, 1.5cm, 0.6cm, "put 2")
  #dnode(10.8cm, 1.2cm, 1.5cm, 0.6cm, "put 3")
  #darrow(9.7cm, 0.6cm, 7.9cm, 1.2cm)
  #darrow(9.7cm, 0.6cm, 9.7cm, 1.2cm)
  #darrow(9.7cm, 0.6cm, 11.5cm, 1.2cm)
  #dnode(7.2cm, 2.4cm, 5.1cm, 0.6cm, "each branch: 2 choices left")
  #dnode(7.2cm, 3.6cm, 5.1cm, 0.6cm, "3 x 2 x 1 = 6 leaves", fill: rgb("#e6f0e6"))
]

#ex(7, tier: 1, asked: "TCS NQT pattern")[
Return every subset of an array of $n$ distinct integers.
Constraints: $1 <= n <= 18$, values fit in an ordinary number. Target: $O(2^n times n)$.
Edge cases: empty array (the answer is one empty subset); $n = 1$.

#sol[
#approach(1, "Loop over bitmasks", verdict: "O(2^n · n), works, and is the shortest code")

Each subset is a yes/no answer for each of the $n$ items — exactly one binary number of
$n$ bits. Bit $i$ on means "item $i$ is in".

#code(lang: "js", caption: "subsets by bitmask")[
```js
function subsetsBit(a) {
  const n = a.length, out = [];
  for (let mask = 0; mask < (1 << n); mask++) {
    const cur = [];
    for (let i = 0; i < n; i++) if (mask & (1 << i)) cur.push(a[i]);
    out.push(cur);
  }
  return out;
}
```
]

Ran it on `[1,2,3]`:
`[] [1] [2] [1,2] [3] [1,3] [2,3] [1,2,3]`

#complexity(time: $O(2^n times n)$, space: $O(1)$, note: "output not counted")

#approach(2, "Pick or skip, recursively", verdict: "same cost, but this one generalises")

The bitmask trick dies the moment you add a rule ("no two adjacent", "the sum must be
10"). Recursion survives, because you can put an `if` in front of the "pick" branch.

#code(lang: "js", caption: "subsets by recursion")[
```js
function subsets(a) {
  const out = [], cur = [];
  const go = (i) => {
    if (i === a.length) { out.push([...cur]); return; }   // COPY, not the live array
    go(i + 1);                                            // not pick
    cur.push(a[i]);                                       // pick
    go(i + 1);
    cur.pop();                                            // undo
  };
  go(0);
  return out;
}
```
]

Ran it on `[1,2,3]`:
`[] [3] [2] [2,3] [1] [1,3] [1,2] [1,2,3]`
and on the empty array: `[[]]` — exactly one subset, the empty one.

#complexity(time: $O(2^n times n)$, space: $O(n)$, note: "stack depth n, plus cur")

*The idea:* the order differs from the bitmask version because the "skip" branch runs
first. Both lists contain the same 8 subsets. If the question says "any order", both pass.

#ans[8 subsets for $n = 3$; in general $2^n$]
]
]

#trap[
Write `out.push([...cur])`, never `out.push(cur)`. I cannot say this too often, because
the broken version *runs without any error*. Arrays are references. Store the reference,
and every later `cur.pop()` reaches back into the answer you already saved. You end up
with $2^n$ copies of the same empty array.

`[...cur]`, `cur.slice()` and `Array.from(cur)` all work. Pick one and use it every time.
]

#ex(8, tier: 1, asked: "Capgemini pattern")[
Same as Example 7, but the array may contain repeats. Return every *distinct* subset.
Constraints: $1 <= n <= 18$, values $1..100$. Target: $O(2^n times n)$.
Edge cases: all elements equal; a mix of one-digit and two-digit values (see the trap).

#sol[
#approach(1, "Generate all 2^n, then de-duplicate with a Set of joined strings", verdict: "O(2^n · n) but with a big constant, and it needs O(2^n · n) extra memory")

#approach(2, "Sort, then skip a repeat at the same level", verdict: "O(2^n · n) — optimal")

Sort first so equal values sit together. Now use the *loop* form of the tree: at level `i`
you choose which element starts the next block. Inside that loop, if `a[j]` equals
`a[j-1]` and `j` is not the first index of this loop, that exact choice was already made
one iteration ago — skip it.

#code(lang: "js", caption: "subsets with duplicates")[
```js
function subsetsDup(input) {
  const a = [...input].sort((x, y) => x - y);      // NUMERIC sort, see the trap
  const out = [], cur = [];
  const go = (i) => {
    out.push([...cur]);                            // every node is an answer
    for (let j = i; j < a.length; j++) {
      if (j > i && a[j] === a[j - 1]) continue;    // skip a repeat at this level
      cur.push(a[j]);
      go(j + 1);
      cur.pop();
    }
  };
  go(0);
  return out;
}
```
]

Ran it on `[2,1,2]` (sorted to `1,2,2`):
`[] [1] [1,2] [1,2,2] [2] [2,2]` — six distinct subsets, no duplicates, no Set needed.

#complexity(time: $O(2^n times n)$, space: $O(n)$)

*The idea:* `j > i` is the whole trick. It means "not the first branch of *this* loop".
Writing `j > 0` instead would wrongly kill `[2,2]`.
]
]

#trap[
*`arr.sort()` with no comparator sorts as text.* I ran it:

```js
[10, 9, 1].sort()              // [1, 10, 9]     <- text order
[10, 9, 1].sort((a, b) => a - b)   // [1, 9, 10]  <- what you meant
```

This is the most common JavaScript bug in coding rounds, and it is silent — no error, just
a wrong answer. Every `sort` in this chapter needs the comparator. Example 17 shows an
input where the missing comparator changes a correct answer into an empty list.
]

#ex(9, tier: 1, asked: "Wipro pattern")[
Return all $n!$ orderings of $n$ distinct integers.
Constraints: $1 <= n <= 8$. Target: $O(n! times n)$.
Edge cases: $n = 1$; negative values.

#sol[
#approach(1, "used[] array plus a growing list", verdict: "O(n! · n) time, O(n) extra space")

#approach(2, "Swap in place", verdict: "O(n! · n), with no used[] array at all")

Think of it as filling slot `i`. Whatever sits at position `j >= i` may be swapped into
slot `i`. Recurse for slot `i+1`. Then swap back.

#code(lang: "js", caption: "permutations by swapping")[
```js
function permute(input) {
  const a = [...input], out = [];
  const go = (i) => {
    if (i === a.length) { out.push([...a]); return; }
    for (let j = i; j < a.length; j++) {
      [a[i], a[j]] = [a[j], a[i]];
      go(i + 1);
      [a[i], a[j]] = [a[j], a[i]];              // undo
    }
  };
  go(0);
  return out;
}
```
]

Ran it on `[1,2,3]`:
`[1,2,3] [1,3,2] [2,1,3] [2,3,1] [3,2,1] [3,1,2]`
and on `[7]`: `[[7]]`.

#complexity(time: $O(n! times n)$, space: $O(n)$, note: "n frames; the array itself is reused")

#ans[6 permutations of 3 items]
]
]

#trap[
Two things at once here.

*Order.* The swap version does not produce permutations in sorted order — look at the
output: `[3,2,1]` comes before `[3,1,2]`. If the question says "in lexicographic order",
use the `used[]` version with the input sorted numerically.

*Copies.* `out.push([...a])` again — `a` is the *one* working array and it is swapped back
on the way out. Storing `a` itself gives you $n!$ references to the original order.
]

#ex(10, tier: 1, asked: "Cognizant pattern")[
All *distinct* orderings when the array has repeats.
Constraints: $1 <= n <= 8$. Target: better than $O(n! times n)$ in practice.
Edge cases: all elements equal; negatives.

#sol[
#approach(1, "Permute everything and de-duplicate with a Set of joined strings", verdict: "O(n! · n) work even when the answer is tiny")

#approach(2, "Sort, then forbid a repeat starting a new branch", verdict: "one node per real answer — optimal")

Swapping is now a trap: it moves equal values around and the "same value" test stops
working. Use `used[]`. The rule: if `a[i] === a[i-1]` and `a[i-1]` is *not* currently
used, then the twin to my left is free, which means this branch was already built starting
from that twin. Skip.

#code(lang: "js", caption: "permutations with duplicates")[
```js
function permuteDup(input) {
  const a = [...input].sort((x, y) => x - y);
  const out = [], cur = [], used = new Array(a.length).fill(false);
  const go = () => {
    if (cur.length === a.length) { out.push([...cur]); return; }
    for (let i = 0; i < a.length; i++) {
      if (used[i]) continue;
      if (i > 0 && a[i] === a[i - 1] && !used[i - 1]) continue;   // the twin rule
      used[i] = true;  cur.push(a[i]);
      go();
      cur.pop();       used[i] = false;
    }
  };
  go();
  return out;
}
```
]

Ran it on `[1,1,2]`: `[1,1,2] [1,2,1] [2,1,1]` — three, not six.
On `[-1,-1]`: `[-1,-1]` — one.

#complexity(time: $O(n! times n)$, space: $O(n)$, note: "worst case; far less when there are many repeats")

*The idea:* force the twins to be used *left to right*. Only one of the $k!$ orderings of
$k$ equal values survives, so each distinct permutation is produced exactly once.

#ans[3]
]
]

#ex(11, tier: 1, asked: "Accenture pattern")[
Return all strings of $n$ pairs of brackets that are balanced.
For $n = 2$: `(())` and `()()`. Constraints: $1 <= n <= 11$.
Target: one recursion node per partial answer.
Edge cases: $n = 0$ (one answer, the empty string); $n = 1$.

#sol[
#approach(1, "Build all 2^(2n) strings, keep the balanced ones", verdict: "O(4^n · n) — one million wasted strings at n = 10")

#approach(2, "Only ever append a legal bracket", verdict: "O(4^n / sqrt(n)) — one node per real answer path")

Carry two counters: `open` = how many `(` are still unused, `close` = how many `)` are
still unused. Two rules cover everything:
- You may write `(` whenever `open > 0`.
- You may write `)` only when `close > open`, that is, some `(` is still waiting to be
  closed.

#code(lang: "js", caption: "balanced brackets")[
```js
function genBrackets(n) {
  const out = [], cur = [];
  const go = (open, close) => {
    if (open === 0 && close === 0) { out.push(cur.join('')); return; }
    if (open > 0)     { cur.push('('); go(open - 1, close); cur.pop(); }
    if (close > open) { cur.push(')'); go(open, close - 1); cur.pop(); }
  };
  go(n, n);
  return out;
}
```
]

Ran it:
- `n = 0` gives one answer, the empty string `""`.
- `n = 1` gives `"()"`.
- `n = 3` gives `"((()))"`, `"(()())"`, `"(())()"`, `"()(())"`, `"()()()"` — 5 answers.

#complexity(time: $O(4^n \/ sqrt(n))$, space: $O(n)$, note: "the count of answers is the n-th Catalan number: 1, 1, 2, 5, 14, 42, ...")

*The idea:* pruning at the point of choice. Approach 1 builds 64 strings for $n = 3$ and
throws away 59. Approach 2 builds 5 and throws away none.

#ans[5 strings for $n = 3$]
]
]

#trick[
Build the string in an *array* and `join('')` at the end, as above. Strings in JavaScript
are immutable, so `cur = cur + '('` allocates a brand-new string every time, and undoing
means `cur = cur.slice(0, -1)` — another allocation. An array with `push`/`pop` is the
same shape as every other backtracking problem and it is faster.
]

#ex(12, tier: 1, asked: "Infosys pattern")[
On an old phone keypad, 2 maps to `abc`, 3 to `def`, ..., 7 to `pqrs`, 8 to `tuv`, 9 to
`wxyz`. Given a digit string (digits 2 to 9), return every letter string it could spell.
Constraints: length up to 8. Target: $O(4^L times L)$.
Edge cases: empty input (return nothing); a single digit; digits 7 and 9 have 4 letters.

#sol[
One level of recursion per digit. The options at that level are that digit's letters.

#code(lang: "js", caption: "keypad words")[
```js
const PAD = ['', '', 'abc', 'def', 'ghi', 'jkl', 'mno', 'pqrs', 'tuv', 'wxyz'];

function keypadWords(d) {
  const out = [];
  if (d.length === 0) return out;          // guard: no digits, no words
  const cur = [];
  const go = (i) => {
    if (i === d.length) { out.push(cur.join('')); return; }
    for (const ch of PAD[Number(d[i])]) {  // a string is iterable, one char at a time
      cur.push(ch);
      go(i + 1);
      cur.pop();
    }
  };
  go(0);
  return out;
}
```
]

Ran it on `"23"`: `ad ae af bd be bf cd ce cf` — 9 strings ($3 times 3$).
On `""`: nothing at all.

#complexity(time: $O(4^L times L)$, space: $O(L)$, note: "L = number of digits; 4 is the biggest keypad group")

#ans[9]
]
]

#trap[
The empty-input guard matters. Without it, `go(0)` hits the base case immediately and
pushes one empty string. Most graders want an *empty list* for empty input, not a list
holding `""`. Read the statement and match it.

Also note `PAD[Number(d[i])]`. `d[i]` is the one-character *string* `"2"`, and using a
string to index an array works here only because JS coerces it — but it is the kind of
implicit coercion that bites later. Convert explicitly.
]

#ex(13, tier: 1, asked: "TCS Digital pattern")[
Return all binary strings of length $n$ that never have two `1`s next to each other.
Constraints: $1 <= n <= 20$. Target: one node per partial answer.
Edge cases: $n = 1$ (both `0` and `1` are fine); $n = 2$.

#sol[
#approach(1, "Build all 2^n strings and test each", verdict: "O(2^n · n) — n = 20 means a million strings, most rejected")

#approach(2, "Refuse to write an illegal character", verdict: "O(answers · n) — optimal")

Only one rule: you may write `1` only if the previous character is `0` (or there is no
previous character).

#code(lang: "js", caption: "binary strings, no two adjacent ones")[
```js
function noAdjacentOnes(n) {
  const out = [], cur = [];
  const go = () => {
    if (cur.length === n) { out.push(cur.join('')); return; }
    cur.push('0'); go(); cur.pop();
    if (cur.length === 0 || cur[cur.length - 1] === '0') {
      cur.push('1'); go(); cur.pop();
    }
  };
  go();
  return out;
}
```
]

Ran it:
- `n = 1`: `0 1`
- `n = 4`: `0000 0001 0010 0100 0101 1000 1001 1010` — 8 strings.

The counts are $2, 3, 5, 8, 13, ...$ — Fibonacci. Not a coincidence: a legal string of
length $n$ either ends in `0` (any legal string of length $n-1$ in front) or ends in `01`
(any legal string of length $n-2$ in front).

#complexity(time: $O(F_(n+2) times n)$, space: $O(n)$, note: "F is Fibonacci; far smaller than 2^n")

#ans[8 strings for $n = 4$]
]
]

#ex(14, tier: 1, asked: "Accenture pattern")[
Given distinct positive numbers and a target, return every list of them that sums to the
target. A number may be used *any* number of times.
Constraints: $1 <= n <= 12$, $1 <= "target" <= 40$, all values $>= 2$.
Target: depth at most target divided by the smallest value.
Edge cases: target 0 (one answer, the empty list); no list works.

#sol[
Two branches at index `i`: *use `a[i]` again* (stay at `i`), or *retire `a[i]` forever*
(move to `i+1`). Staying at `i` is what allows reuse. Moving forward is what stops
`[2,3]` and `[3,2]` both appearing.

#code(lang: "js", caption: "combination sum, unlimited reuse")[
```js
function combSum(input, target) {
  const a = [...input].sort((x, y) => x - y);
  const out = [], cur = [];
  const go = (i, left) => {
    if (left === 0) { out.push([...cur]); return; }
    if (i === a.length || left < 0) return;
    if (a[i] <= left) {                    // use a[i] one more time
      cur.push(a[i]);
      go(i, left - a[i]);
      cur.pop();
    }
    go(i + 1, left);                       // retire a[i]
  };
  go(0, target);
  return out;
}
```
]

Ran it on `[2,3,5]` with target 8: `[2,2,2,2] [2,3,3] [3,5]`.
With target 0: `[[]]`. On `[5,7]` with target 3: `[]`.

#complexity(time: $O(n^("target"/"min"))$, space: $O("target"/"min")$, note: "depth is at most target / smallest value")

#ans[3 combinations]
]
]

#trap[
If the array can contain `1`, "unlimited reuse" with target 40 explodes: the depth alone
is 40 — dangerously close to nothing in C++ but perfectly fine in JS — and the answer
count is huge. Always check the statement for a lower bound on the values, and say out
loud in an interview: "this is only safe because every value is at least 2".
]

#ex(15, tier: 1, asked: "Wipro pattern")[
Return every subsequence of a string. A subsequence keeps the order but may drop letters.
Constraints: length up to 18. Target: $O(2^n times n)$.
Edge cases: empty string; all letters the same.

#sol[
Identical shape to subsets — the pick-or-skip tree, with characters instead of numbers.

#code(lang: "js", caption: "all subsequences")[
```js
function subsequences(s) {
  const out = [], cur = [];
  const go = (i) => {
    if (i === s.length) { out.push(cur.join('')); return; }
    go(i + 1);                  // skip s[i]
    cur.push(s[i]);
    go(i + 1);                  // take s[i]
    cur.pop();
  };
  go(0);
  return out;
}
```
]

Ran it on `"abc"`: `"" "c" "b" "bc" "a" "ac" "ab" "abc"` — 8.
On `""`: one answer, the empty string.

#complexity(time: $O(2^n times n)$, space: $O(n)$)

#ans[8]
]
]

#ex(16, tier: 1, asked: "Cognizant pattern")[
Three pegs A, B, C. $n$ disks of different sizes are stacked on A, biggest at the bottom.
Move all disks to C. You may move one top disk at a time, and a bigger disk may never rest
on a smaller one. Return the list of moves.
Constraints: $1 <= n <= 20$. Target: $2^n - 1$ moves, which is optimal.
Edge cases: $n = 0$ (zero moves); $n = 1$.

#sol[
The whole problem collapses into one sentence: *to move $n$ disks from A to C, first move
the top $n-1$ to B, then move disk $n$ to C, then move those $n-1$ from B to C.*

#code(lang: "js", caption: "tower of hanoi")[
```js
function hanoi(n, from = 'A', to = 'C', via = 'B') {
  const log = [];
  const go = (k, f, t, v) => {
    if (k === 0) return;
    go(k - 1, f, v, t);                      // v becomes the destination
    log.push(`disk ${k}: ${f}->${t}`);
    go(k - 1, v, t, f);                      // v becomes the source
  };
  go(n, from, to, via);
  return log;
}
```
]

Ran `hanoi(3)`. Output, in order:

#table(columns: (auto, auto, auto, auto, auto, auto, auto),
  [1], [2], [3], [4], [5], [6], [7],
  [d1 A→C], [d2 A→B], [d1 C→B], [d3 A→C], [d1 B→A], [d2 B→C], [d1 A→C],
)

Counts: $n = 0 -> 0$, $n = 3 -> 7$, $n = 4 -> 15$. The pattern is $2^n - 1$.

#complexity(time: $O(2^n)$, space: $O(n)$, note: "2^n - 1 moves; this is a lower bound, no algorithm does better")

*The idea:* notice the *rotation of roles*. In the first call, `via` becomes the new
destination; in the second, `via` becomes the new source. Getting those three letters in
the right order is the entire problem.

#ans[$2^n - 1$ moves; 7 for $n = 3$]
]
]

#section[Tier 2 — carry state, cut branches]
#tier-header(2)

Tier 2 adds two things: the state you carry is bigger than an index, and you must *prune*
— refuse to enter a branch that cannot possibly work.

#ex(17, tier: 2, asked: "Shopee · pattern")[
A warehouse has $n$ boxes with given weights. Some weights repeat. Choose a set of boxes
whose weights sum to exactly `target`. Each box may be used at most once, and two
different sets with the same multiset of weights count as one answer.
Constraints: $1 <= n <= 20$, weights $1..50$, target up to 200. Target: $O(2^n times n)$.
Edge cases: two boxes with equal weight; a weight larger than the target; a mix of
one-digit and two-digit weights.

#sol[
Sort. Use the loop form. Two cuts:
- `j > i && a[j] === a[j-1]` — the duplicate rule from Example 8.
- `a[j] > left` — since the array is sorted, every later value is also too big, so
  `break`, not `continue`.

#code(lang: "js", caption: "each item once, no duplicate answers")[
```js
function combSum2(input, target) {
  const a = [...input].sort((x, y) => x - y);      // NUMERIC sort - see below
  const out = [], cur = [];
  const go = (i, left) => {
    if (left === 0) { out.push([...cur]); return; }
    for (let j = i; j < a.length; j++) {
      if (j > i && a[j] === a[j - 1]) continue;    // same choice as last loop turn
      if (a[j] > left) break;                      // sorted: the rest are bigger too
      cur.push(a[j]);
      go(j + 1, left - a[j]);                      // j+1: this box is now used up
      cur.pop();
    }
  };
  go(0, target);
  return out;
}
```
]

Ran it on `[2,2,3,5]` with target 7: `[2,2,3] [2,5]`.
`[2,5]` appears once, even though there are two 2s that could start it.

#complexity(time: $O(2^n times n)$, space: $O(n)$, note: "the break makes it far faster in practice")

#ans[2 sets]
]
]

#trap[
*This is the problem where the missing sort comparator actually changes the answer.*
I ran the same function twice on `[2, 10, 3]` with target 5, once with `.sort()` and once
with `.sort((a,b) => a-b)`:

#table(columns: (auto, auto, auto),
  [*sort used*], [*array becomes*], [*result*],
  [`.sort()`], [`[10, 2, 3]`], [`[]` — *wrong*],
  [`.sort((a,b) => a-b)`], [`[2, 3, 10]`], [`[[2,3]]` — correct],
)

With the text sort, the first element is 10, which is bigger than the target 5, so the
`break` fires immediately and the function reports "no solution". The prune was written
assuming ascending numeric order, and the text sort quietly broke that assumption.

*Every prune is a promise about the order of your data.* Break the order and you break
the prune.
]

#ex(18, tier: 2, asked: "Grab · pattern")[
Split a string into pieces so that *every* piece is a palindrome. Return all such splits.
Constraints: length up to 16. Target: $O(2^n times n)$.
Edge cases: one character; no letter repeats (then the only split is into single
characters).

#sol[
#approach(1, "Try every cut position, check the piece, recurse", verdict: "O(2^n · n^2) — this is already the standard answer")

At index `i`, try every end `j`. If `s[i..j]` is a palindrome, take it as one piece and
solve from `j+1`.

#code(lang: "js", caption: "palindrome partitioning")[
```js
const isPal = (s, i, j) => {
  while (i < j) { if (s[i] !== s[j]) return false; i++; j--; }
  return true;
};

function partition(s) {
  const out = [], cur = [];
  const go = (i) => {
    if (i === s.length) { out.push([...cur]); return; }
    for (let j = i; j < s.length; j++) {
      if (!isPal(s, i, j)) continue;          // prune: illegal piece
      cur.push(s.slice(i, j + 1));            // slice(start, endExclusive)
      go(j + 1);
      cur.pop();
    }
  };
  go(0);
  return out;
}
```
]

Ran it on `"aab"`: `[["a","a","b"], ["aa","b"]]`. On `"a"`: `[["a"]]`.

#complexity(time: $O(2^n times n^2)$, space: $O(n)$, note: "the extra n is the palindrome check")

#approach(2, "Pre-compute a palindrome table", verdict: "O(2^n · n) — drops one factor of n")

Build `pal[i][j]` once in $O(n^2)$ with the rule
`pal[i][j] = s[i] === s[j] && (j - i < 2 || pal[i+1][j-1])`. Then the check inside the
recursion is a single array read. For $n <= 16$ it does not matter; say it anyway.

#ans[2 splits of `"aab"`]
]
]

#trap[
`s.slice(i, j + 1)` takes a start and an *exclusive* end. `s.substr(i, len)` takes a
start and a *length* and is deprecated. `s.substring(i, j)` swaps its arguments if they
are out of order, which hides bugs. Use `slice`, and remember the `+ 1`.
]

#ex(19, tier: 2, asked: "Agoda · pattern")[
Given a string and a list of allowed words, can the string be cut into a sequence of
allowed words? Words may be reused.
Constraints: length up to 300, up to 1000 words each up to 20 characters.
Target: $O(n^2 times L)$.
Edge cases: the string is exactly one word; a prefix matches but the rest fails;
`"aaaa"` with words `["a","aa"]` (many ways to reach the same place).

#sol[
#approach(1, "Try every first word, recurse on the rest", verdict: "O(2^n) — dies on strings like aaaa...a")

The killer input is `"aaaa...a"` with `["a","aa"]`: position 7 is reached from dozens of
different prefixes, and each time you redo identical work.

#approach(3, "Memoise on the start index", verdict: "O(n^2 · L) — optimal for this shape")

The only thing that matters about "the work left" is *where you are*. That is one number,
$0..n$. So one cache of size $n$ is enough.

#code(lang: "js", caption: "word break with a memo")[
```js
function canBreak(s, words) {
  const dict = new Set(words);              // Set, not a plain object
  const memo = new Array(s.length).fill(-1);
  const go = (i) => {
    if (i === s.length) return true;        // used up the string
    if (memo[i] !== -1) return memo[i] === 1;
    for (let j = i; j < s.length; j++) {
      if (dict.has(s.slice(i, j + 1)) && go(j + 1)) { memo[i] = 1; return true; }
    }
    memo[i] = 0;
    return false;
  };
  return go(0);
}
```
]

Ran it:

#table(columns: (auto, auto, auto),
  [*string*], [*words*], [*answer*],
  [`"applepie"`],  [`["apple","pie"]`], [true],
  [`"applepies"`], [`["apple","pie"]`], [false],
  [`"aaaa"`],      [`["a","aa"]`],      [true],
)

#complexity(time: $O(n^2 times L)$, space: $O(n times L)$, note: "L is the cost of hashing a substring")

*The idea:* the state is one index, so the cache is one array. Ask yourself on every
recursion: *what is the smallest description of "everything still to do"?* That
description is your memo key.

#ans[true, false, true]
]
]

#trap[
Use a `Set` for the dictionary, not a plain object.

A plain object turns every key into a string, inherits keys from `Object.prototype`, and
`dict["constructor"]` is truthy even when you never put it there — so a word like
`"constructor"` or `"toString"` in the input produces a false positive. `Set.has` has
none of those problems, keeps the value's type, and is faster for repeated lookups.
The same argument applies to `Map` versus an object for counting.
]

#ex(20, tier: 2, asked: "LINE MAN · pattern")[
A robot starts at the top-left of an $n times n$ grid and must reach the bottom-right.
`1` means the cell is open, `0` means blocked. It may move Down, Left, Right, Up, and may
not step on the same cell twice in one path. Return every path as a string of `D L R U`.
Constraints: $1 <= n <= 6$. Target: one node per reachable partial path.
Edge cases: the start is blocked; $n = 1$; no path exists.

#sol[
This is the first problem where you must mark cells *visited*, because the robot may move
in all four directions and would otherwise loop forever.

#code(lang: "js", caption: "all paths through a maze")[
```js
function mazePaths(g) {
  const n = g.length, out = [];
  if (n === 0 || g[0][0] === 0) return out;          // the start is blocked
  const vis = g.map(r => r.map(() => false));        // a real 2-D array, see the trap
  vis[0][0] = true;
  const cur = [];
  const dr = [1, 0, 0, -1], dc = [0, -1, 1, 0], name = 'DLRU';
  const go = (r, c) => {
    if (r === n - 1 && c === n - 1) { out.push(cur.join('')); return; }
    for (let k = 0; k < 4; k++) {
      const nr = r + dr[k], nc = c + dc[k];
      if (nr < 0 || nc < 0 || nr >= n || nc >= n) continue;
      if (vis[nr][nc] || g[nr][nc] === 0) continue;
      vis[nr][nc] = true;  cur.push(name[k]);
      go(nr, nc);
      cur.pop();           vis[nr][nc] = false;      // un-choose BOTH
    }
  };
  go(0, 0);
  return out;
}
```
]

Ran it on

```
1 0 0
1 1 0
0 1 1
```

Result: one path, `"DRDR"`. On a grid whose start cell is `0`: no paths.
On the $1 times 1$ grid `[[1]]`: one path, the empty string (you are already there).

#complexity(time: $O(4^(n^2))$, space: $O(n^2)$, note: "brutal in theory; the vis check makes it fine for n <= 6")

#ans[`"DRDR"`]
]
]

#trap[
*Two separate traps in one problem.*

*1. Two un-choose lines, not one:* `cur.pop()` *and* `vis[nr][nc] = false`. Forgetting
the second is the classic maze bug — you find one path, then the function reports "no more
paths" because the whole grid is still marked visited.

*2. Building the `vis` grid.* I ran this to show why:

```js
const g = [[1,0],[0,1]];
const shallow = [...g];  shallow[0][0] = 9;   // g[0][0] is now 9  <- rows are shared!
const deep = g.map(r => [...r]);              // this one is a real copy
```
And `new Array(n).fill(new Array(n).fill(false))` is worse still: all $n$ rows are the
*same* array, so marking one cell marks a whole column. Always build rows with
`Array.from({length: n}, () => new Array(n).fill(false))` or `g.map(r => r.map(...))`.
]

#ex(21, tier: 2, asked: "Sea/Shopee · pattern")[
A message was encoded with `a = 1, b = 2, ..., z = 26` and the separators were lost.
Count how many messages could produce the given digit string.
Constraints: length up to 100. Target: $O(n)$.
Edge cases: empty string (answer 0); a leading `0`; `"106"`; forty `1`s.

#sol[
#approach(1, "Plain recursion on the start index", verdict: "O(2^n) — 2^40 for forty 1s")

At index `i` you either read one digit (if it is not `'0'`) or two digits (if they form a
number from 10 to 26).

#approach(3, "Memoise on the index", verdict: "O(n) — optimal")

#code(lang: "js", caption: "count decodings")[
```js
function countDecodings(s) {
  if (s.length === 0) return 0;
  const memo = new Array(s.length).fill(-1);
  const go = (i) => {
    if (i === s.length) return 1;                  // reached the end cleanly
    if (s[i] === '0') return 0;                    // no letter is coded 0
    if (memo[i] !== -1) return memo[i];
    let total = go(i + 1);                         // take one digit
    if (i + 1 < s.length && Number(s.slice(i, i + 2)) <= 26) total += go(i + 2);
    return memo[i] = total;
  };
  return go(0);
}
```
]

Ran it:

#table(columns: (auto, auto, auto),
  [*input*], [*answer*], [*why*],
  [`""`],       [0],          [nothing to decode],
  [`"0"`],      [0],          [no letter is 0],
  [`"12"`],     [2],          [`ab` or `l`],
  [`"226"`],    [3],          [`bbf`, `bz`, `vf`],
  [`"106"`],    [1],          [only `jf`; `10` must stay together],
  [`"1010"`],   [1],          [`jj`],
  [forty `1`s], [165580141],  [the 41st Fibonacci number],
)

#complexity(time: $O(n)$, space: $O(n)$)

#ans[3 for `"226"`]
]
]

#trap[
`"106"`: a naive solution splits as `1 | 0 | 6` and counts a fake answer. The guard
`if (s[i] === '0') return 0;` at the *top* of the function handles every zero case at
once, including `"0"`, `"100"` and `"1001"`.

For a 100-digit input of all `1`s the count is about $5 times 10^20$ — *past the safe
integer limit*. If the constraint were 100 rather than 40, this function would need
`BigInt`. Work out the largest answer before you pick the number type.
]

#ex(22, tier: 2, asked: "SCB · pattern")[
Count the subsets of an array that sum to a target.
Constraints: $1 <= n <= 20$, values $0..100$, target up to 500. Target: $O(2^n)$, or
$O(n times "target")$ with a memo.
Edge cases: the array contains a `0`; target 0; no subset works.

#sol[
Count, do not collect. So the function returns a number instead of pushing to a list —
and there is nothing to undo, because nothing was changed.

#code(lang: "js", caption: "count subsets with a given sum")[
```js
function countSubsets(a, target) {
  const go = (i, left) => {
    if (i === a.length) return left === 0 ? 1 : 0;
    const skip = go(i + 1, left);
    const take = a[i] <= left ? go(i + 1, left - a[i]) : 0;
    return skip + take;
  };
  return go(0, target);
}
```
]

Ran it: `[1,2,1]` target 2 → `2` (namely `{2}` and `{1,1}`).
`[0,1]` target 1 → `2`. `[3]` target 5 → `0`.

#complexity(time: $O(2^n)$, space: $O(n)$, note: "add a memo on (i, target) to get O(n · target)")

#ans[2]
]
]

#trap[
`[0,1]` with target 1 gives *2*, not 1. The subsets `{1}` and `{0,1}` both sum to 1. A
zero in the array doubles the count of every answer it can join. If the statement says
"distinct subsets by value", you must handle zeros separately. Always ask whether zeros
are allowed.
]

#ex(23, tier: 2, asked: "GIC · pattern")[
Count the ways to walk from the top-left to the bottom-right of an
$(r+1) times (c+1)$ grid moving only Right or Down.
Constraints: $0 <= r, c <= 16$. Target: $O(r times c)$.
Edge cases: $r = 0$ (one straight line); $r = c = 16$; check the safe-integer limit.

#sol[
#approach(1, "Plain recursion", verdict: "O(2^(r+c)) — 2^32 calls at r = c = 16")

#code(lang: "js", caption: "brute force")[
```js
function pathsSlow(r, c) {
  if (r === 0 || c === 0) return 1;        // only one straight line left
  return pathsSlow(r - 1, c) + pathsSlow(r, c - 1);
}
```
]
Ran it: `pathsSlow(0,5) = 1`, `pathsSlow(2,2) = 6`, `pathsSlow(3,3) = 20`.

#approach(3, "Memoise on (r, c)", verdict: "O(r · c) — optimal")

There are only $(r+1)(c+1)$ different states, but the brute force visits some of them
millions of times.

#code(lang: "js", caption: "with a memo")[
```js
function paths(r, c) {
  const memo = Array.from({ length: r + 1 }, () => new Array(c + 1).fill(-1));
  const go = (i, j) => {
    if (i === 0 || j === 0) return 1;
    if (memo[i][j] !== -1) return memo[i][j];
    return memo[i][j] = go(i - 1, j) + go(i, j - 1);
  };
  return go(r, c);
}
```
]

Ran it: `paths(3,3) = 20` (matches the brute force — always check this) and
`paths(16,16) = 601080390`. I also checked it is under `Number.MAX_SAFE_INTEGER` — it is.

#complexity(time: $O(r times c)$, space: $O(r times c)$)

*The idea:* the state is `(r, c)` and nothing else. Two numbers, so a 2-D cache.

#ans[601080390]
]
]

#trap[
Two things.

*The memo grid.* `Array.from({length: r+1}, () => new Array(c+1).fill(-1))` builds
$r+1$ *separate* rows. `new Array(r+1).fill(new Array(c+1).fill(-1))` builds one row and
points at it $r+1$ times — writing `memo[1][2]` would also change `memo[0][2]`.

*The value size.* $601080390$ is fine. But `paths(30, 30)` is about $1.18 times 10^17$,
which is *past* $2^53 - 1$, so the count would be silently wrong. Path counts grow like
$binom(r+c, r)$, and they explode. Check the biggest case the constraints allow.
]

#ex(24, tier: 2, asked: "DBS · pattern")[
Does *any* subset of the array sum to exactly the target? Answer yes or no, as fast as
you can. Constraints: $1 <= n <= 28$, values $0..10^4$, target up to $10^5$.
Target: fast enough that $n = 28$ finishes in well under a second.
Edge cases: empty array with target 0; a target larger than the whole array's sum;
negative values (see the trap).

#sol[
#approach(1, "Plain pick-or-skip", verdict: "O(2^n) — 2.7 x 10^8 calls at n = 28, too slow in JS")

#approach(2, "Add a suffix-sum cut", verdict: "same worst case, but orders of magnitude faster in practice")

Pre-compute `suffix[i] = a[i] + a[i+1] + ... + a[n-1]`. If `suffix[i] < left`, then even
taking *every* remaining number is not enough — return `false` at once instead of walking
$2^(n-i)$ dead branches.

#code(lang: "js", caption: "subset sum with a suffix cut")[
```js
function subsetSumPruned(a, target) {
  const n = a.length, suffix = new Array(n + 1).fill(0);
  for (let i = n - 1; i >= 0; i--) suffix[i] = suffix[i + 1] + a[i];
  const go = (i, left) => {
    if (left === 0) return true;
    if (i === n) return false;
    if (left < 0) return false;
    if (suffix[i] < left) return false;          // cannot reach it any more
    return go(i + 1, left - a[i]) || go(i + 1, left);
  };
  return go(0, target);
}
```
]

Ran it: `[3,34,4,12,5,2]` target 9 → true (`4+5`); target 30 → false;
empty array target 0 → true.

#complexity(time: $O(2^n)$, space: $O(n)$, note: "worst case unchanged; the cut is what makes n = 28 pass")

#ans[true, false, true]
]
]

#trap[
*The suffix cut is only valid when every value is $>= 0$.* I ran both versions on
`[-5, 10]` with target 10:

#table(columns: (auto, auto),
  [*no pruning*], [`true` — the subset `[10]` works],
  [*with the suffix cut*], [`false` — WRONG],
)

`suffix[0]` is $-5 + 10 = 5$, which is less than 10, so the cut fires and kills the
correct branch. Every pruning rule is a *claim about the future*. Write the claim down and
check it holds for negatives and zeros before you trust it.
]

#section[Tier 3 — the classics, and the follow-up]
#tier-header(3)

#ex(25, tier: 3, asked: "Amazon · pattern")[
Place $n$ queens on an $n times n$ board so that no two attack each other (same row, same
column, or same diagonal). Return every arrangement.
Constraints: $1 <= n <= 9$ in JavaScript (10 is about 5 seconds). Target: $O(n!)$.
Edge cases: $n = 1$ (one solution); $n = 2$ and $n = 3$ (zero solutions); $n = 8$.

#sol[
First insight, and say it before you write code: *exactly one queen per row*. So the
answer is an array `pos[row] = column`, and level `row` of the recursion chooses that
column. That alone cuts the search from $binom(n^2, n)$ to $n^n$.

#approach(1, "Scan the rows above to check safety", verdict: "O(n! · n) — accepted, easy to get right")

#code(lang: "js", caption: "N-Queens, scanning check")[
```js
function queensSlow(n) {
  const out = [], pos = new Array(n).fill(-1);
  const safe = (row, col) => {
    for (let r = 0; r < row; r++) {
      if (pos[r] === col) return false;                        // same column
      if (Math.abs(pos[r] - col) === row - r) return false;     // same diagonal
    }
    return true;
  };
  const go = (row) => {
    if (row === n) { out.push([...pos]); return; }
    for (let col = 0; col < n; col++) {
      if (!safe(row, col)) continue;
      pos[row] = col;
      go(row + 1);
    }
  };
  go(0);
  return out;
}
```
]

Why is there no "undo" line for `pos`? Because `pos[row]` is *overwritten* by the next
loop turn and nothing above `row` ever reads it. Overwriting is a legal form of undo.

#complexity(time: $O(n! times n)$, space: $O(n)$, note: "the extra n is the safe() scan")

#approach(3, "Three Sets, O(1) safety check", verdict: "O(n!) — optimal")

A cell on the board sits on exactly one `/` diagonal and one `\\` diagonal:
- every cell of one `/` diagonal has the same `row + col`,
- every cell of one `\\` diagonal has the same `row - col`.

So three `Set`s answer "is this attacked?" in one step. (`Set` keeps numbers as numbers;
a plain object would turn `-2` into the string `"-2"` and still work, but a `Set` says
what you mean.)

#diagram(height: 3.9cm, caption: "row+col is constant on one diagonal; row-col on the other")[
  #dnode(0pt, 0pt, 1.1cm, 0.8cm, "0")
  #dnode(1.2cm, 0pt, 1.1cm, 0.8cm, "1")
  #dnode(2.4cm, 0pt, 1.1cm, 0.8cm, "2")
  #dnode(0pt, 0.9cm, 1.1cm, 0.8cm, "1")
  #dnode(1.2cm, 0.9cm, 1.1cm, 0.8cm, "2", fill: rgb("#e6f0e6"))
  #dnode(2.4cm, 0.9cm, 1.1cm, 0.8cm, "3")
  #dnode(0pt, 1.8cm, 1.1cm, 0.8cm, "2")
  #dnode(1.2cm, 1.8cm, 1.1cm, 0.8cm, "3")
  #dnode(2.4cm, 1.8cm, 1.1cm, 0.8cm, "4")
  #dnode(0pt, 2.8cm, 3.5cm, 0.7cm, "row + col", fill: rgb("#f7f3e6"))

  #dnode(5.5cm, 0pt, 1.1cm, 0.8cm, "0")
  #dnode(6.7cm, 0pt, 1.1cm, 0.8cm, "-1")
  #dnode(7.9cm, 0pt, 1.1cm, 0.8cm, "-2")
  #dnode(5.5cm, 0.9cm, 1.1cm, 0.8cm, "1")
  #dnode(6.7cm, 0.9cm, 1.1cm, 0.8cm, "0", fill: rgb("#e6f0e6"))
  #dnode(7.9cm, 0.9cm, 1.1cm, 0.8cm, "-1")
  #dnode(5.5cm, 1.8cm, 1.1cm, 0.8cm, "2")
  #dnode(6.7cm, 1.8cm, 1.1cm, 0.8cm, "1")
  #dnode(7.9cm, 1.8cm, 1.1cm, 0.8cm, "0")
  #dnode(5.5cm, 2.8cm, 3.5cm, 0.7cm, "row - col", fill: rgb("#f7f3e6"))
]

#code(lang: "js", caption: "N-Queens, O(1) check")[
```js
function queens(n) {
  const out = [], pos = new Array(n).fill(-1);
  const col = new Set(), d1 = new Set(), d2 = new Set();
  const go = (row) => {
    if (row === n) { out.push([...pos]); return; }
    for (let c = 0; c < n; c++) {
      if (col.has(c) || d1.has(row + c) || d2.has(row - c)) continue;
      col.add(c); d1.add(row + c); d2.add(row - c); pos[row] = c;
      go(row + 1);
      col.delete(c); d1.delete(row + c); d2.delete(row - c);     // un-choose
    }
  };
  go(0);
  return out;
}
```
]

I ran *both* versions for $n = 1..8$ and the counts agree exactly:

#table(columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
  [*n*], [1], [2], [3], [4], [5], [6], [7], [8],
  [*solutions*], [1], [0], [0], [2], [10], [4], [40], [92],
)

For $n = 4$ the two solutions are `[1,3,0,2]` and `[2,0,3,1]`:

#diagram(height: 3.4cm, caption: "the two 4-queens boards; Q marks a queen")[
  #dnode(0pt, 0pt, 0.8cm, 0.7cm, ".") #dnode(0.85cm, 0pt, 0.8cm, 0.7cm, "Q", fill: rgb("#e6f0e6")) #dnode(1.7cm, 0pt, 0.8cm, 0.7cm, ".") #dnode(2.55cm, 0pt, 0.8cm, 0.7cm, ".")
  #dnode(0pt, 0.8cm, 0.8cm, 0.7cm, ".") #dnode(0.85cm, 0.8cm, 0.8cm, 0.7cm, ".") #dnode(1.7cm, 0.8cm, 0.8cm, 0.7cm, ".") #dnode(2.55cm, 0.8cm, 0.8cm, 0.7cm, "Q", fill: rgb("#e6f0e6"))
  #dnode(0pt, 1.6cm, 0.8cm, 0.7cm, "Q", fill: rgb("#e6f0e6")) #dnode(0.85cm, 1.6cm, 0.8cm, 0.7cm, ".") #dnode(1.7cm, 1.6cm, 0.8cm, 0.7cm, ".") #dnode(2.55cm, 1.6cm, 0.8cm, 0.7cm, ".")
  #dnode(0pt, 2.4cm, 0.8cm, 0.7cm, ".") #dnode(0.85cm, 2.4cm, 0.8cm, 0.7cm, ".") #dnode(1.7cm, 2.4cm, 0.8cm, 0.7cm, "Q", fill: rgb("#e6f0e6")) #dnode(2.55cm, 2.4cm, 0.8cm, 0.7cm, ".")

  #dnode(5.5cm, 0pt, 0.8cm, 0.7cm, ".") #dnode(6.35cm, 0pt, 0.8cm, 0.7cm, ".") #dnode(7.2cm, 0pt, 0.8cm, 0.7cm, "Q", fill: rgb("#e6f0e6")) #dnode(8.05cm, 0pt, 0.8cm, 0.7cm, ".")
  #dnode(5.5cm, 0.8cm, 0.8cm, 0.7cm, "Q", fill: rgb("#e6f0e6")) #dnode(6.35cm, 0.8cm, 0.8cm, 0.7cm, ".") #dnode(7.2cm, 0.8cm, 0.8cm, 0.7cm, ".") #dnode(8.05cm, 0.8cm, 0.8cm, 0.7cm, ".")
  #dnode(5.5cm, 1.6cm, 0.8cm, 0.7cm, ".") #dnode(6.35cm, 1.6cm, 0.8cm, 0.7cm, ".") #dnode(7.2cm, 1.6cm, 0.8cm, 0.7cm, ".") #dnode(8.05cm, 1.6cm, 0.8cm, 0.7cm, "Q", fill: rgb("#e6f0e6"))
  #dnode(5.5cm, 2.4cm, 0.8cm, 0.7cm, ".") #dnode(6.35cm, 2.4cm, 0.8cm, 0.7cm, "Q", fill: rgb("#e6f0e6")) #dnode(7.2cm, 2.4cm, 0.8cm, 0.7cm, ".") #dnode(8.05cm, 2.4cm, 0.8cm, 0.7cm, ".")
]

#complexity(time: $O(n!)$, space: $O(n)$)

*The idea:* turn "is this square attacked?" from a *scan* into a *lookup* by giving every
diagonal a name. That is the same move as a hash map replacing a linear search.

#ans[92 solutions for $n = 8$]
]
]

#formulas(title: "The follow-ups an interviewer asks after N-Queens")[
*"Only count the solutions, do not store them."* Return a number; drop `pos` and the
output array entirely. Space falls to $O(n)$.

*"Use bitmasks instead of Sets."* Keep three ordinary numbers `col`, `d1`, `d2`. Free
squares in this row are `free = ~(col | d1 | d2) & ((1 << n) - 1)`. Take the lowest set
bit with `bit = free & -free`, and recurse with
`(col | bit, (d1 | bit) << 1, (d2 | bit) >> 1)`. Same $O(n!)$, but several times faster —
and note that JS bitwise operators work on *32-bit* integers, so this only holds up to
$n = 31$.

*"n is 10000."* Then you are not searching — you are *constructing*. For $n >= 4$ an
explicit formula places the queens in $O(n)$; searching is the wrong tool once you only
need *one* solution for huge $n$.
]

#ex(26, tier: 3, asked: "Microsoft · pattern")[
Fill in a partly-filled $9 times 9$ Sudoku. Blank cells are `'.'`. Every row, every column
and every $3 times 3$ box must end up holding `1..9` exactly once.
Constraints: the board is $9 times 9$ and a solution exists. Target: instant on a real
puzzle. Edge cases: an already-full board; a board with no solution.

#sol[
Two pieces: a legality check, and a recursion that finds the *first* blank and tries all
nine digits there.

The cell at `(r, c)` lives in the box whose top-left corner is
`(3*Math.floor(r/3), 3*Math.floor(c/3))`. So the $k$-th cell of that box is
`(3*Math.floor(r/3) + Math.floor(k/3), 3*Math.floor(c/3) + k%3)` for $k = 0..8$. That
lets one loop check row, column and box together.

#code(lang: "js", caption: "sudoku solver")[
```js
function solveSudoku(board) {                 // board is a 9x9 array of characters
  const ok = (r, c, v) => {
    for (let k = 0; k < 9; k++) {
      if (board[r][k] === v) return false;                     // row
      if (board[k][c] === v) return false;                     // column
      const br = 3 * Math.floor(r / 3) + Math.floor(k / 3);
      const bc = 3 * Math.floor(c / 3) + (k % 3);
      if (board[br][bc] === v) return false;                   // 3x3 box
    }
    return true;
  };
  const go = () => {
    for (let r = 0; r < 9; r++)
      for (let c = 0; c < 9; c++) {
        if (board[r][c] !== '.') continue;
        for (const v of '123456789') {
          if (!ok(r, c, v)) continue;
          board[r][c] = v;
          if (go()) return true;              // a deeper call succeeded
          board[r][c] = '.';                  // undo
        }
        return false;                         // nothing fits here
      }
    return true;                              // no blank left: done
  };
  return go();
}
```
]

Ran it on this board (36 clues, one solution). Build it with
`rows.map(r => [...r])` so each row is its own array:

#table(columns: (1fr, 1fr), align: center,
  [*puzzle*], [*solver output*],
  [```
..82...61
7..5.....
.2..1.35.
9.2.6....
8.5...136
13..5897.
5941.26..
.....521.
..7..6..4
```],
  [```
358294761
761583429
429617358
972361845
845729136
136458972
594172683
683945217
217836594
```],
)

It printed `solved = true` in *3 milliseconds*. On an already-full valid board it returns
`true` without changing anything. On a board I deliberately broke (a duplicate in row 0)
it returns `false`.

#complexity(time: $O(9^b times 81)$, space: $O(b)$, note: "b = number of blanks; the ok() pruning makes real puzzles instant")

*The idea:* the two `return`s at the bottom are opposite in meaning and both essential.
`return false` inside the cell loop means "this blank has no legal digit, so whoever
called me made a bad choice — back up." `return true` at the very end means "I scanned the
whole board and found no blank, so we are finished."
]
]

#trap[
`board` must be an array of *arrays of characters*, not an array of strings. Strings in
JavaScript are immutable, so `board[r][c] = v` on a string row does *nothing at all* —
no error, no change, and the solver loops until it gives up. Convert first with
`rows.map(r => [...r])`, and print with `board.map(r => r.join('')).join('\n')`.
]

#formulas(title: "The follow-ups after Sudoku")[
*"Make it faster."* Replace the $O(9)$ `ok()` scan with three arrays of 9-bit masks:
`rowMask`, `colMask`, `boxMask`. Then legality is one `&` and updating is one `^=`.
Typically 10 to 30 times faster.

*"Choose a smarter cell."* Instead of the first blank, pick the blank with the *fewest*
legal digits (the MRV heuristic). Fail fast, fail high in the tree.

*"Count all solutions."* Do not `return true` on success — increment a counter and keep
going. That is how you test whether a generated puzzle is unique. It is also how I checked
the puzzle above.
]

#ex(27, tier: 3, asked: "Google · pattern")[
Given a grid of letters and a word, decide whether the word can be spelled by walking
between side-by-side cells (up, down, left, right). A cell may not be used twice in one
walk. Constraints: grid up to $8 times 8$, word up to 12 letters.
Target: $O(R C 4^L)$ worst case, far less with the letter check.
Edge cases: empty word; the word's first letter is not in the grid; a word that would need
to reuse a cell.

#sol[
Start the walk from every cell. Inside, the recursion checks position, letter and
visited-ness all at the top, which keeps the body short.

The neat trick: instead of a separate `visited` grid, *overwrite the cell with a character
that cannot match* (here `'#'`), then put it back on the way out. Same effect, zero extra
memory.

#code(lang: "js", caption: "word search")[
```js
function wordExists(grid, w) {
  if (w.length === 0) return true;
  const g = grid.map(r => [...r]);             // deep copy: we scribble on it
  const R = g.length, C = g[0].length;
  const go = (r, c, k) => {
    if (k === w.length) return true;           // all letters matched
    if (r < 0 || c < 0 || r >= R || c >= C) return false;
    if (g[r][c] !== w[k]) return false;        // wrong letter, or the '#' marker
    const save = g[r][c];
    g[r][c] = '#';                             // mark visited
    const found = go(r+1, c, k+1) || go(r-1, c, k+1)
               || go(r, c+1, k+1) || go(r, c-1, k+1);
    g[r][c] = save;                            // undo
    return found;
  };
  for (let r = 0; r < R; r++)
    for (let c = 0; c < C; c++)
      if (go(r, c, 0)) return true;
  return false;
}
```
]

Ran it on

```
c a t
x r e
d o g
```

#table(columns: (auto, auto, auto),
  [*word*], [*answer*], [*why*],
  [`"cat"`],  [true],  [straight along row 0],
  [`"care"`], [true],  [c(0,0) → a(0,1) → r(1,1) → e(1,2)],
  [`"cart"`], [false], [after `car` the only `t` is at (0,2), not next to (1,1)],
  [`"catx"`], [false], [`x` is at (1,0), not next to `t` at (0,2)],
)

#complexity(time: $O(R times C times 4^L)$, space: $O(L)$, note: "R, C grid size; L word length")

*The idea:* the `||` chain short-circuits. As soon as one direction succeeds, JavaScript
stops evaluating the rest — you get early exit for free, but *only* if you restore
`g[r][c]` after the chain, not inside it.
]
]

#formulas(title: "The follow-up: many words at once")[
*"Now find all 5000 words from a dictionary in the same grid."* Running this search 5000
times is far too slow. Put every word into a *trie* (Chapter 6 territory) and walk the
grid *once*, carrying a trie node instead of an index. The search stops the moment the
prefix leaves the trie. That is the standard escalation, and naming it earns the point
even if you do not have time to code it.
]

#ex(28, tier: 3, asked: "Adobe · pattern")[
Given a string of digits and a target, insert `+`, `-` or `*` between some digits so the
expression evaluates to the target. Digits may be glued into multi-digit numbers, but a
glued number may not have a leading zero. Return every expression.
Constraints: up to 10 digits; the target fits in a safe integer.
Target: $O(4^n times n)$.
Edge cases: `"105"` target 5 (both `1*0+5` and `10-5` work); no solution; a single digit.

#sol[
Two hard parts. First, at each position you choose *where the current number ends*, so
there is an inner loop gluing digits. Second, `*` binds tighter than `+` and `-`, so a
running total is not enough.

*The trick for `*`:* carry `last` — the value of the term you most recently added. To
multiply, *undo* that term and re-add it multiplied:
`value - last + last * num`, and the new `last` becomes `last * num`.

#table(columns: (auto, auto, auto, auto),
  [*so far*], [`value`], [`last`], [*then `*4`*],
  [`2+3`],   [5],  [3],  [$5 - 3 + 3 times 4 = 14$, new `last` $= 12$],
  [`2+3*4`], [14], [12], [$14 - 12 + 12 times 5 = 62$ for `*5`],
)

#code(lang: "js", caption: "insert + - * to hit a target")[
```js
function findExpressions(d, target) {
  const out = [];
  if (d.length === 0) return out;
  const go = (i, expr, value, last) => {
    if (i === d.length) { if (value === target) out.push(expr); return; }
    for (let j = i; j < d.length; j++) {
      if (j > i && d[i] === '0') break;                // no leading zero
      const part = d.slice(i, j + 1);
      const num = Number(part);
      if (i === 0) {
        go(j + 1, part, num, num);                     // the first number
      } else {
        go(j + 1, expr + '+' + part, value + num, num);
        go(j + 1, expr + '-' + part, value - num, -num);
        go(j + 1, expr + '*' + part,
           value - last + last * num, last * num);
      }
    }
  };
  go(0, '', 0, 0);
  return out;
}
```
]

Ran it:

#table(columns: (auto, auto, auto),
  [*digits*], [*target*], [*answers*],
  [`"123"`], [6], [`"1+2+3"`, `"1*2*3"`],
  [`"105"`], [5], [`"1*0+5"`, `"10-5"`],
  [`"11"`],  [9], [none],
)

#complexity(time: $O(4^n times n)$, space: $O(n)$, note: "4 = glue, +, -, *; the extra n is string building")

#ans[`"1+2+3"` and `"1*2*3"`]
]
]

#trap[
Ten glued digits give up to $9,999,999,999$, and a running product of two such numbers is
about $10^20$ — *past the safe integer limit*. For 10 digits the intermediate values stay
safe in practice, but if the constraint were 16 digits you would need `BigInt` for
`value`, `last` and `num` throughout.

And the `break` on a leading zero must come *before* `part` is built, otherwise `"05"` is
quietly accepted as 5.
]

#ex(29, tier: 3, asked: "Goldman Sachs · pattern")[
Consider the numbers $1..n$ written in every possible order, and list those orders
alphabetically. Return the $k$-th one.
Constraints: $1 <= n <= 9$, $1 <= k <= n!$. Target: $O(n^2)$ without generating all $n!$
orders. Edge cases: $k = 1$ (the sorted order); $k = n!$ (the reversed order).

#sol[
#approach(1, "Generate all n! permutations, sort, take index k-1", verdict: "O(n! · n log n!) — 9! = 362880, slow in JS, and pure waste")

#approach(3, "Count instead of generate", verdict: "O(n^2) — optimal")

Fix the first digit. The remaining $n-1$ digits can be arranged in $(n-1)!$ ways. So the
first $(n-1)!$ orders all start with the smallest digit, the next $(n-1)!$ with the second
smallest, and so on. One division tells you which one.

Work with $k - 1$ (0-based), then repeat for each slot.

#code(lang: "js", caption: "k-th permutation directly")[
```js
function kthPermutation(n, k) {                // k is 1-based
  const f = [1];
  for (let i = 1; i <= n; i++) f[i] = f[i - 1] * i;
  const left = [];
  for (let i = 1; i <= n; i++) left.push(String(i));
  k--;                                         // make it 0-based
  const res = [];
  for (let slot = n; slot >= 1; slot--) {
    const block = f[slot - 1];                 // orders sharing one leading digit
    const idx = Math.floor(k / block);
    res.push(left[idx]);
    left.splice(idx, 1);                       // remove that digit from the pool
    k %= block;
  }
  return res.join('');
}
```
]

Worked trace for $n = 4$, $k = 9$. Start `k = 8`, `left = ["1","2","3","4"]`:

#table(columns: (auto, auto, auto, auto, auto, auto),
  [*slot*], [`block`], [`k`], [`idx = floor(k/block)`], [*picked*], [*new k*],
  [4], [3! = 6], [8], [1], [`"2"`], [8 mod 6 = 2],
  [3], [2! = 2], [2], [1], [`"3"`], [2 mod 2 = 0],
  [2], [1! = 1], [0], [0], [`"1"`], [0],
  [1], [0! = 1], [0], [0], [`"4"`], [0],
)

Ran it: `kthPermutation(3,1) = "123"`, `kthPermutation(3,4) = "231"`,
`kthPermutation(3,6) = "321"`, `kthPermutation(4,9) = "2314"` — matching the table.

#complexity(time: $O(n^2)$, space: $O(n)$, note: "the n^2 is splice() shifting the remaining elements")

*The idea:* stop enumerating, start counting. Whenever a question asks for "the $k$-th
thing in order", check whether you can *count* how many things start with each choice.

#ans[`"2314"`]
]
]

#trap[
`Math.floor(k / block)` is required. Plain `k / block` gives a fraction, and using a
fraction as an array index gives `undefined` — which `join('')` happily turns into the
text `"undefined"` with no error at all. Any time you divide in JavaScript and mean
integer division, wrap it in `Math.floor` (or use `Math.trunc` if negatives are possible).
]

#ex(30, tier: 3, asked: "D. E. Shaw · pattern")[
Split an array of positive integers into exactly $k$ groups with equal sums. Return true
or false. Constraints: $1 <= n <= 16$, $1 <= k <= n$, values up to $10^4$.
Target: fast enough for $n = 16$.
Edge cases: the total is not divisible by $k$; one value is larger than the target;
$k = 1$; $k = n$ with all values equal.

#sol[
#approach(1, "Try all k^n assignments of items to groups", verdict: "O(k^n) — 16^16, hopeless")

#approach(3, "Place items one by one, with three cuts", verdict: "fast enough for n = 16")

Three cheap tests kill almost everything before the search starts:
1. If `sum % k !== 0`, answer false.
2. If the largest value exceeds `sum / k`, answer false — it fits nowhere.
3. Sort and place the *largest* item first. Big items have the fewest homes, so they cause
   failures near the root of the tree instead of near the leaves.

And one cut inside the loop that people miss: if putting the item in an *empty* group
fails, then putting it in any other empty group also fails — the groups are
interchangeable. So `break` after an empty group fails.

#code(lang: "js", caption: "split into k equal-sum groups")[
```js
function canSplit(input, k) {
  if (k <= 0 || input.length < k) return false;
  const sum = input.reduce((x, y) => x + y, 0);
  if (sum % k !== 0) return false;                       // cut 1
  const target = sum / k;
  const a = [...input].sort((x, y) => x - y);            // NUMERIC sort
  if (a[a.length - 1] > target) return false;            // cut 2
  const bucket = new Array(k).fill(0);
  const go = (i) => {
    if (i < 0) return true;                              // every item placed
    for (let b = 0; b < k; b++) {
      if (bucket[b] + a[i] > target) continue;
      bucket[b] += a[i];
      if (go(i - 1)) return true;
      bucket[b] -= a[i];
      if (bucket[b] === 0) break;    // an empty bucket failed -> all empties fail
    }
    return false;
  };
  return go(a.length - 1);                               // largest item first
}
```
]

Ran it:

#table(columns: (auto, auto, auto, auto),
  [*array*], [*k*], [*answer*], [*why*],
  [`[2,1,3,4]`], [2], [true],  [`[1,4]` and `[2,3]`, each 5],
  [`[1,1,1]`],   [2], [false], [sum 3 is not divisible by 2],
  [`[5,5,5,5]`], [4], [true],  [one item per group],
  [`[9,1,1,1]`], [2], [false], [sum 12, target 6, but 9 > 6],
  [`[4]`],       [1], [true],  [one group holding everything],
)

#complexity(time: $O(k times 2^n)$, space: $O(n + k)$, note: "worst case; the cuts usually finish in microseconds")

*The idea:* symmetry breaking. Two empty buckets are the *same* bucket as far as the
answer is concerned. Whenever your search has interchangeable slots, one `break` removes a
factorial-sized chunk of the tree.
]
]

#formulas(title: "The follow-ups after equal-sum groups")[
*"Return the actual groups, not just true/false."* Carry a `groups` array of arrays
alongside `bucket`, push and pop in the same places. Nothing else changes.

*"n is 30."* Switch to bitmask DP over subsets: `dp[mask]` = "can the items in `mask` be
packed into full groups, and how much is in the group currently being filled". That is
$O(2^n times n)$ — Chapter 18. Note that a mask up to $2^30$ is fine as a JS number, but a
mask beyond $2^31$ breaks the *bitwise operators*, which are 32-bit. Above that you need
`BigInt` masks or a different encoding.

*"The groups may differ by at most 1."* Now it is an optimisation, not a decision. Binary
search on the allowed gap, or switch to a greedy plus local search — and say clearly that
the exact version is NP-hard, so a heuristic is expected.
]

#ex(31, tier: 3, asked: "Uber · pattern")[
Count the orderings $p_1, p_2, ..., p_n$ of $1..n$ where, for every slot $i$, either $p_i$
divides $i$ or $i$ divides $p_i$.
Constraints: $1 <= n <= 14$ in JavaScript. Target: fast enough that $n = 14$ finishes in
about a second. Edge cases: $n = 1$ (answer 1); $n = 2$ (answer 2).

#sol[
Fill the slots $1, 2, ..., n$ in order. At slot `slot`, try every unused value `v` that
satisfies the divisibility rule. The rule itself is the prune.

#code(lang: "js", caption: "count divisible arrangements")[
```js
function countArrangements(n) {
  const used = new Array(n + 1).fill(false);
  const go = (slot) => {
    if (slot > n) return 1;                           // all slots filled
    let total = 0;
    for (let v = 1; v <= n; v++) {
      if (used[v]) continue;
      if (v % slot !== 0 && slot % v !== 0) continue; // the rule
      used[v] = true;
      total += go(slot + 1);
      used[v] = false;
    }
    return total;
  };
  return go(1);
}
```
]

Ran it for $n = 1..8$:

#table(columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto),
  [*n*], [1], [2], [3], [4], [5], [6], [7], [8],
  [*count*], [1], [2], [3], [8], [10], [36], [41], [132],
)

Notice $n = 7$: only 41, barely more than $n = 6$. Slot 7 can hold only the value 7 or 1,
and 7 is prime, so the tree is very thin. Primes choke this problem.

#complexity(time: $O(n!)$, space: $O(n)$, note: "worst case; in truth far smaller, because the divisibility rule cuts most branches at depth 2")

#ans[132 for $n = 8$]
]
]

#formulas(title: "The follow-up: n = 20")[
*"Now n is 20."* $20!$ is $2.4 times 10^18$ — hopeless by pure search. But notice the
state: *which slot am I on* plus *which values are used*. The slot number is redundant —
it equals the count of set bits in the used-set plus 1. So the state is a single 20-bit
mask, and there are only $2^20 approx 10^6$ of them.

`dp[mask]` = number of ways to fill the first `popcount(mask)` slots using exactly the
values in `mask`. Cost $O(2^n times n)$, about 20 million steps. This is *bitmask DP* and
it is the single most common "now make it bigger" escalation in this chapter.

In JavaScript, keep $n <= 30$ for this: `1 << 31` is *negative*, because bitwise operators
coerce to signed 32-bit integers. Past that, index with plain numbers
(`Math.floor(mask / 2)` instead of `mask >> 1`) or use `BigInt`.
]

#section[Dry run — subsets of `[1, 2, 3]`, every single step]

This is the recursion from Example 7. I will write `go(i)` and show the output list after
every event. Read it once slowly with a pen; after that, every backtracking trace in this
book is the same picture.

#code(lang: "js", caption: "the code being traced")[
```js
const go = (i) => {
  if (i === 3) { out.push([...cur]); return; }   // a.length is 3
  go(i + 1);            // (A) not pick
  cur.push(a[i]);       // (B) pick
  go(i + 1);            // (C)
  cur.pop();            // (D) undo
};
```
]

#table(columns: (auto, auto, auto, auto, auto),
  [*step*], [*event*], [`i`], [`cur`], [`out` so far],
  [1],  [enter `go(0)`],       [0], [`[]`],      [`[]`],
  [2],  [(A) enter `go(1)`],   [1], [`[]`],      [`[]`],
  [3],  [(A) enter `go(2)`],   [2], [`[]`],      [`[]`],
  [4],  [(A) enter `go(3)`],   [3], [`[]`],      [`[]`],
  [5],  [base: push a copy of `[]`], [3], [`[]`], [`[[]]`],
  [6],  [back in `go(2)`, (B) push 3], [2], [`[3]`], [`[[]]`],
  [7],  [(C) enter `go(3)`, push],     [3], [`[3]`], [`[[], [3]]`],
  [8],  [(D) pop → `go(2)` returns],   [2], [`[]`],  [`[[], [3]]`],
  [9],  [back in `go(1)`, (B) push 2], [1], [`[2]`], [`[[], [3]]`],
  [10], [(C) enter `go(2)`],           [2], [`[2]`], [`[[], [3]]`],
  [11], [(A) `go(3)` pushes],          [3], [`[2]`], [`[[], [3], [2]]`],
  [12], [(B) push 3],                  [2], [`[2,3]`], [`[[], [3], [2]]`],
  [13], [(C) `go(3)` pushes],          [3], [`[2,3]`], [`... [2], [2,3]`],
  [14], [(D) pop → `go(2)` returns],   [2], [`[2]`],   [`... [2], [2,3]`],
  [15], [(D) pop → `go(1)` returns],   [1], [`[]`],    [`... [2], [2,3]`],
  [16], [back in `go(0)`, (B) push 1], [0], [`[1]`],   [`... [2], [2,3]`],
  [17], [(C) the whole thing repeats with a leading 1], [—], [—], [adds `[1] [1,3] [1,2] [1,2,3]`],
  [18], [(D) pop → `go(0)` returns],   [0], [`[]`],    [8 subsets],
)

Final `out`: `[] [3] [2] [2,3] [1] [1,3] [1,2] [1,2,3]` — exactly what the program
printed.

#formulas(title: "Three things this table proves")[
1. `cur` is *always* back to `[]` when `go(0)` returns. That is the invariant. If it is
   not, you have a missing `cur.pop()`.
2. The base case fires $2^3 = 8$ times — once per leaf. Every leaf is one answer.
3. Steps 6 and 16 are the *only* places anything is added to `cur`, and steps 8, 14, 15 and
   18 are the only places anything is removed. Pushes and pops always come in pairs.

And one thing the table makes obvious: at step 5, `cur` is the *same array object* as at
step 18. That is precisely why the base case pushes `[...cur]` and not `cur`.
]

#section[Recursion is too deep — rewrite it as a loop]

JavaScript gives you roughly $10^4$ stack frames. When that is not enough, turn the
recursion into an explicit stack. Every recursive call becomes an object you push; every
return becomes a pop.

#code(lang: "js", caption: "subsets with no recursion at all")[
```js
function subsetsIterative(a) {
  const out = [];
  const stack = [{ i: 0, cur: [] }];
  while (stack.length > 0) {
    const { i, cur } = stack.pop();
    if (i === a.length) { out.push(cur); continue; }
    stack.push({ i: i + 1, cur: [...cur, a[i]] });   // pick
    stack.push({ i: i + 1, cur: [...cur] });         // skip   (popped first)
  }
  return out;
}
```
]

Ran it on `[1,2,3]`: `[] [3] [2] [2,3] [1] [1,3] [1,2] [1,2,3]` — the same eight subsets,
in the same order as the recursive version. On `[]`: `[[]]`.

Then I compared the two on a 20,000-level walk:

#table(columns: (1fr, auto),
  [plain recursion, 20,000 levels], [threw `RangeError: Maximum call stack size exceeded`],
  [explicit stack, 20,000 levels],  [finished, 20,000 levels walked],
)

#note[
The price of the explicit stack is memory: each pushed frame holds its own *copy* of
`cur`, so peak memory is higher than the recursive version, which shares one `cur`. For a
backtracking search of depth $10^4$ or more, that is the trade you make. For depth under a
few thousand, prefer the recursive version — it is far easier to read and to get right.
]

#section[Python — the three signature problems]

Python is the secondary language of this book. Here it is genuinely shorter, and worth
knowing if your round lets you choose.

#code(lang: "python", caption: "subsets, permutations, N-Queens in Python")[
```python
def subsets(a):
    out, cur = [], []
    def go(i):
        if i == len(a):
            out.append(cur[:])          # copy, not the live list
            return
        go(i + 1)
        cur.append(a[i])
        go(i + 1)
        cur.pop()
    go(0)
    return out

def permute(a):
    out = []
    def go(i):
        if i == len(a):
            out.append(a[:])
            return
        for j in range(i, len(a)):
            a[i], a[j] = a[j], a[i]
            go(i + 1)
            a[i], a[j] = a[j], a[i]
    go(0)
    return out

def n_queens(n):
    out, pos = [], [-1] * n
    col, d1, d2 = set(), set(), set()
    def go(row):
        if row == n:
            out.append(pos[:])
            return
        for c in range(n):
            if c in col or (row + c) in d1 or (row - c) in d2:
                continue
            col.add(c); d1.add(row + c); d2.add(row - c); pos[row] = c
            go(row + 1)
            col.remove(c); d1.remove(row + c); d2.remove(row - c)
    go(0)
    return out
```
]

Ran all three:
- `subsets([1,2,3])` → `[[], [3], [2], [2, 3], [1], [1, 3], [1, 2], [1, 2, 3]]`
- `subsets([])` → `[[]]`
- `permute([1,2,3])` → `[[1,2,3], [1,3,2], [2,1,3], [2,3,1], [3,2,1], [3,1,2]]`
- `n_queens(4)` → `[[1, 3, 0, 2], [2, 0, 3, 1]]`
- solution counts for $n = 1..8$ → `[1, 0, 0, 2, 10, 4, 40, 92]` — identical to the JS.

#trick[
*Two things Python gives you free that JavaScript does not.*

1. Integers are arbitrary precision. `math.factorial(30)` is exact with no `BigInt`
   ceremony.
2. `sorted(a)` and `a.sort()` already compare numbers as numbers — there is no
   lexicographic surprise.

*And one thing that is worse:* the default recursion limit is *1000*, even lower than JS.
`sys.setrecursionlimit(300000)` raises it, but the real C stack may still blow up. And
`out.append(cur)` stores a reference, exactly like `out.push(cur)` in JS — use `cur[:]`.
]

#section[Practice]

#practice(tier: 0, time: "20 min")[
1. Write `sumTo(n)` = $1 + 2 + ... + n$ recursively. What is `sumTo(100)`?
2. Count the digits of a non-negative number recursively. What does your base case do for
   input 0?
3. Recursively check whether a string is a palindrome, without building a reversed copy.
4. Print the numbers $n, n-1, ..., 1$ and then $1, 2, ..., n$ using *one* recursive
   function and no loop.
]

#practice(tier: 1, time: "45 min")[
5. Return all subsets of `[1,2,3,4]` whose sum is exactly 5.
6. Return all strings of length 3 made from `['a','b']`. How many are there for length
   $n$?
7. Given `n`, return all ways to write `n` as a sum of positive integers in
   non-increasing order. For $n = 4$: `4`, `3+1`, `2+2`, `2+1+1`, `1+1+1+1`.
8. Count the paths in an $n times n$ grid from top-left to bottom-right moving only Right
   or Down, where the cell `(i, i)` is blocked for every $i$ with $0 < i < n-1$.
9. Given a list of coin values and an amount, count the ways to make the amount. Order
   does not matter and coins are unlimited.
]

#practice(tier: 2, time: "50 min")[
10. Given a string of digits, insert `.` to make four parts, each a number from 0 to 255
    with no leading zeros (except `"0"` itself). Return every valid result.
11. Given an array, return all subsets where no two chosen elements sit next to each other
    in the array.
12. A knight starts at `(0,0)` on an $n times n$ board. Count the ways it reaches
    `(n-1,n-1)` in exactly $m$ moves. Memoise on `(r, c, movesLeft)`.
13. Given $n$ tasks with durations and 2 identical workers, decide whether the tasks can be
    split so both workers finish at the same time.
]

#practice(tier: 3, time: "60 min")[
14. Place $n$ rooks on an $n times n$ board with some squares forbidden, so that no two
    rooks share a row or column. Count the placements.
15. Given a string, count the ways to split it into pieces so that no piece repeats.
16. Given an array of $n <= 16$ positive numbers, split it into two groups so the
    difference of their sums is as small as possible. Return that difference.
]

#key[
*1.* `const sumTo = n => n === 0 ? 0 : n + sumTo(n - 1);` Ran it: `sumTo(100)` is *5050*.
Depth is $n$, so this throws a `RangeError` around $n = 12000$ — use the formula
$n(n+1)/2$ there.

*2.* `const countDigits = n => n < 10 ? 1 : 1 + countDigits(Math.floor(n / 10));` The base
must be `n < 10`, not `n === 0`, otherwise input 0 returns 0 digits instead of 1. Ran it:
`0` → *1*, `4073` → *4*. And do not forget `Math.floor`.

*3.* `const pal = (s,i,j) => i >= j ? true : (s[i] !== s[j] ? false : pal(s,i+1,j-1));`
The `i >= j` base covers even and odd lengths, and the empty string (called with `i = 0`,
`j = -1`) returns true. Ran it: `"level"` → *true*, `"abca"` → *false*.

*4.* Put a `push` *before* the recursive call and a second one *after* it:
`const f = n => { if (n === 0) return; out.push(n); f(n-1); out.push(n); };` The pushes
after the call run during unwinding, so they come out in the opposite order. Ran `f(3)`:
*`3 2 1 1 2 3`*. This one idea — do work on the way down, do work on the way up — is what
makes tree traversals in Chapter 12 easy.

*5.* Take the subsets code from Example 7 and carry a running `sum`. Push only when
`i === a.length && sum === 5`. Better: prune with `if (sum > 5) return;` — legal here
because all values are positive. Ran it: *2* answers, `[2,3]` and `[1,4]`.

*6.* Two branches at each level, `'a'` and `'b'`. Ran it for length 3:
`aaa aab aba abb baa bab bba bbb` — *8*. In general $2^n$; for an alphabet of size $m$ it
is $m^n$.

*7.* Carry `maxAllowed` so the pieces never increase: `go(remaining, maxAllowed)` loops
`v` from `Math.min(maxAllowed, remaining)` down to 1. Ran it: $n = 4$ gives *5*
(`4`, `3+1`, `2+2`, `2+1+1`, `1+1+1+1`) and $n = 10$ gives *42*.

*8.* Same memo as Example 23, but return 0 when the cell is blocked:
`if (r > 0 && r < n-1 && r === c) return 0;`. Ran it: $n = 3$ leaves *2* paths, $n = 4$
leaves *4* (out of the usual 20), and $n = 5$ leaves *10*.

*9.* Exactly the shape of Example 14, but return a count instead of collecting lists:
`ways(i, amt) = ways(i, amt - coins[i]) + ways(i + 1, amt)`. Memoise on `(i, amt)` — a
`Map` keyed by `` `${i},${amt}` `` is the simplest way, because JS has no tuple keys. Ran
it for coins `[1,2,5]` and amount 5: *4* ways — `1+1+1+1+1`, `1+1+1+2`, `1+2+2`, `5`.

*10.* Four levels; at each level take 1, 2 or 3 digits. Reject a piece if it starts with
`'0'` and is longer than one character, or if its value is over 255. Ran it: `"25525"`
gives *4* answers — `2.5.5.25`, `2.5.52.5`, `2.55.2.5`, `25.5.2.5`. `"1111"` gives exactly
one, `1.1.1.1`.

*11.* Pick-or-skip, but after picking index `i` recurse to `i + 2`: `go(i+2)` for the pick
branch, `go(i+1)` for the skip branch. Ran it on `[1,2,3,4]`: *8* subsets —
`[] [4] [3] [2] [2,4] [1] [1,4] [1,3]`. The counts go 2, 3, 5, 8 — Fibonacci, exactly like
Example 13.

*12.* Eight knight moves. State is `(r, c, movesLeft)`; use a `Map` keyed by
`` `${r},${c},${k}` ``. Base: `movesLeft === 0` returns `(r === n-1 && c === n-1) ? 1 : 0`.
Ran it on a $4 times 4$ board: $m = 2$ gives *2* ways and $m = 4$ gives *12*; $m = 1$ and
$m = 3$ give *0*, because a knight changes square colour every move and $(0,0)$ and
$(3,3)$ are the same colour — parity kills all odd $m$.

*13.* This is Example 30 with $k = 2$. Total must be even, no single task may exceed half
the total, then search. Ran it: `[3,3,4,4]` → *true* (7 and 7); `[1,2,4]` → *false* (total
7 is odd).

*14.* One rook per row, like N-Queens but with *no diagonal test*: only a `col[]` array
and a forbidden-square check. Without forbidden squares the answer is exactly $n!$ — I ran
$n = 4$ and got *24*. Forbidding the single square $(0,0)$ drops it to *18*, which is
$24 - 3! = 24 - 6$: the placements that used to put a rook there.

*15.* Loop the cut point `j` from `i`, keep a `Set` of pieces already used. `add` the
piece, recurse, then `delete` it — that delete is the un-choose step and it is easy to
forget. Ran it: `"aba"` → *3* (`ab|a`, `a|ba`, `aba`; the split `a|b|a` is rejected because
`a` repeats). `"abc"` → *4*, `"aa"` → *1*.

*16.* Every subset has a sum; the other group's sum is `total - sum`. So walk the
pick-or-skip tree and track `Math.min(best, Math.abs(total - 2 * sum))`. Cost $O(2^n)$,
fine for $n <= 16$. Ran it: `[1,6,11,5]` → *1* (total 23, `[1,5,6]` = 12 against
`[11]` = 11); `[1,2,3,4]` → *0* (`[1,4]` and `[2,3]`).
]

#revision[
#subsection[The template you write every time]

```js
const go = (state) => {
  if (isComplete(state)) { out.push([...cur]); return; }  // COPY cur
  for (const o of options(state)) {
    if (!legal(state, o)) continue;   // prune
    apply(cur, o);                    // choose
    go(next(state, o));               // explore
    undo(cur, o);                     // un-choose
  }
};
```

#subsection[Pick the right tree]

#table(columns: (auto, 1fr, auto),
  [*Question says*], [*Tree*], [*Cost*],
  [subsets, subsequences], [`go(i+1)`, then push, `go(i+1)`, pop], [$O(2^n n)$],
  [permutations, orderings], [swap `a[i]`,`a[j]`, or a `used[]` array], [$O(n! n)$],
  [combinations summing to X], [loop `j >= i`, recurse at `j` (reuse) or `j+1` (once)], [target-dependent],
  [split a string], [loop the cut end `j`, recurse at `j+1`], [$O(2^n)$],
  [place on a board], [one level per row + `Set`s for column and both diagonals], [$O(n!)$],
  [fill a grid], [first blank, try all values, undo], [$O(v^b)$],
  [count only], [return a number; add a memo if states repeat], [often polynomial],
)

#subsection[The duplicate rules — memorise these two lines]

#table(columns: (auto, 1fr),
  [subsets / combinations], [`if (j > i && a[j] === a[j-1]) continue;` after a numeric sort],
  [permutations], [`if (i > 0 && a[i] === a[i-1] && !used[i-1]) continue;` after a numeric sort],
)

#subsection[Complexity cheat sheet]

#table(columns: (auto, auto, auto),
  [*Problem*], [*Time*], [*Space*],
  [all subsets], [$O(2^n times n)$], [$O(n)$],
  [all permutations], [$O(n! times n)$], [$O(n)$],
  [balanced brackets], [$O(4^n \/ sqrt(n))$], [$O(n)$],
  [palindrome split], [$O(2^n times n^2)$], [$O(n)$],
  [N-Queens], [$O(n!)$], [$O(n)$],
  [Sudoku], [$O(9^b)$], [$O(b)$],
  [word search], [$O(R C 4^L)$], [$O(L)$],
  [k-th permutation], [$O(n^2)$], [$O(n)$],
  [stairs / decodings with a memo], [$O(n)$], [$O(n)$],
  [grid paths with a memo], [$O(r c)$], [$O(r c)$],
)

#subsection[Top traps — the JavaScript ones first]

1. *`out.push(cur)` instead of `out.push([...cur])`.* Arrays are references. Your answer
   list fills with copies of one empty array.
2. *`arr.sort()` sorts as text.* `[10,9,1].sort()` is `[1,10,9]`. Always
   `arr.sort((a,b) => a-b)`, especially before a prune that assumes ascending order.
3. *Numbers are doubles*, exact only to `Number.MAX_SAFE_INTEGER` = $2^53 - 1$. Factorials,
   path counts and glued digits blow past it. Use `BigInt` (`5n`, and never mix the two
   types in one expression).
4. *Recursion depth is about $10^4$.* Depth $10^5$ throws `RangeError`. Rewrite as an
   explicit stack.
5. *`[...grid]` is a shallow copy.* Rows stay shared. Use `grid.map(r => [...r])`. And
   never `new Array(n).fill(new Array(n))` — every row is the same array.
6. *`n / 10` is not integer division.* Wrap it in `Math.floor`.
7. *A `Set`/`Map`, not a plain object*, for dictionaries and counts. Object keys stringify
   and inherit from the prototype.
8. *Strings are immutable.* `board[r][c] = v` on a string row silently does nothing.
   Convert rows to character arrays first.
9. *Missing `undo`.* Output too long, or extra elements. Check every `push` has a `pop`.
10. *Wrong duplicate guard.* `j > i` (this level), not `j > 0` (the whole array).
11. *Pruning that assumes non-negative values.* The suffix-sum cut breaks on negatives.
12. *Forgetting the second undo* in grid problems: both `cur.pop()` and
    `vis[r][c] = false`.
13. *Empty input.* Decide whether the answer is `[]` or `[""]`, and guard for it.
14. *Recomputing instead of caching.* If two branches meet at the same state, memoise.
]

]
