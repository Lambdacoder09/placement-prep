#import "../../shared/lib/style.typ": *

#chapter(num: 20, title: "Bit Manipulation, Math & Number Theory", tagline: "Bits are just switches; number theory is just counting, done once and reused")[

#section[Pattern in one page]

A JavaScript number is a double, but the moment you write `&`, `|`, `^`, `<<` or `>>` the
engine converts it to a *signed 32-bit integer*, does the operation, and converts back.
So a bitwise value in JS is 32 switches in a row. A `BigInt` is as many switches as you
like. Every bit trick in this chapter is one of three things: *read* a switch, *change* a
switch, or *count* the switches that are on. Nothing more.

#formulas(title: "The bit table — learn these by heart")[

Let `k` be a bit position, counted from the right starting at 0.

#table(columns: (auto, 1fr),
  [`x >> k & 1`],        [read bit $k$ — gives 0 or 1],
  [`x | (1 << k)`],      [turn bit $k$ *on*],
  [`x & ~(1 << k)`],     [turn bit $k$ *off*],
  [`x ^ (1 << k)`],      [*flip* bit $k$],
  [`x & (x - 1)`],       [turn off the *lowest* bit that is on],
  [`x & -x`],            [keep *only* the lowest bit that is on],
  [`(x & (x - 1)) === 0`], [$x$ is 0 or a power of two],
  [`x ^ x`],             [always 0 — this is why XOR cancels pairs],
  [`x ^ 0`],             [always $x$],
  [`(a ^ b) < 0`],       [$a$ and $b$ have opposite signs (32-bit)],
  [`1 << n`],            [$2^n$ — *only while $n <= 30$*. Past that use `1n << BigInt(n)`],
)

*Why `x & (x - 1)` clears the lowest set bit.* Subtracting 1 flips the lowest 1 into a 0
and turns every 0 below it into a 1. ANDing keeps only the bits both have — the lowest 1
is gone and the bits below it were 0 in $x$ anyway.

#table(columns: (auto, auto, auto, auto),
  [*x*], [*binary*], [*x - 1*], [*x & (x-1)*],
  [12], [`1100`], [`1011`], [`1000` $= 8$],
  [8],  [`1000`], [`0111`], [`0000` $= 0$],
  [7],  [`0111`], [`0110`], [`0110` $= 6$],
)

*The three XOR laws that solve half of these problems.*
$ x xor x = 0, quad x xor 0 = x, quad a xor b = b xor a $
Together they mean: XOR every element of an array, and every value that appears an *even*
number of times vanishes.
]

#formulas(title: "The number-theory table")[

*gcd and lcm.*
$ gcd(a, 0) = a, quad gcd(a, b) = gcd(b, a mod b), quad "lcm"(a,b) = a / gcd(a,b) times b $
Divide *first*. Writing $a times b \/ gcd$ loses precision once the product passes
$2^53$.

*Primes.* To test one number, trial-divide up to $sqrt(n)$. To get *all* primes up to
$n$, use the sieve: cost $O(n log log n)$, which is nearly $O(n)$.

*Factorisation.* $N = p_1^(a_1) p_2^(a_2) dots p_k^(a_k)$. Then
$ "number of divisors" = product (a_i + 1), quad
  "sum of divisors" = product (p_i^(a_i + 1) - 1)/(p_i - 1) $

*Factorials.* The power of prime $p$ in $n!$ is
$ floor(n/p) + floor(n/p^2) + floor(n/p^3) + dots $
Trailing zeros of $n!$ is the power of 5 (there are always more 2s than 5s).

*Modular arithmetic.* With $M = 10^9 + 7$ (a prime):
$ (a + b) mod M, quad (a - b + M) mod M, quad (a times b) mod M $
Division is *not* allowed directly. Instead multiply by the modular inverse.
By Fermat's little theorem, when $M$ is prime and $a$ is not a multiple of $M$:
$ a^(M-1) equiv 1 (mod M) quad => quad a^(-1) equiv a^(M-2) (mod M) $

*Binomial.* $binom(n, r) = n! / (r! (n-r)!)$. Modulo a prime, precompute factorials and
their inverses once, then every query is $O(1)$.
]

#subsection[The two templates you will reuse all chapter]

`powMod` is the one place where a JavaScript number is simply not good enough. With
$M approx 10^9$, the product `r * base` reaches $10^18$, and doubles are exact only to
$2^53 - 1 approx 9 times 10^15$. Every multiplication under a large modulus in this
chapter therefore happens in `BigInt`.

#code(lang: "js", caption: "Template A — fast exponentiation (square and multiply)")[
```js
const powMod = (base, exp, mod) => {
  const m = BigInt(mod);
  let b = BigInt(base) % m, e = BigInt(exp), r = 1n % m;
  if (b < 0n) b += m;                        // BigInt % keeps the sign, like C
  while (e > 0n) {
    if (e & 1n) r = r * b % m;               // BigInt: never loses a digit
    b = b * b % m;
    e >>= 1n;
  }
  return Number(r);                          // the result is below mod, so it fits
};
```
]

#code(lang: "js", caption: "Template B — sieve of Eratosthenes")[
```js
const sieve = (n) => {
  const composite = new Uint8Array(n + 1);   // 1 byte per number, zero-filled
  const primes = [];
  for (let i = 2; i <= n; i++) {
    if (!composite[i]) {
      primes.push(i);
      for (let j = i * i; j <= n; j += i) composite[j] = 1;
    }
  }
  return primes;
};
```
]

Both were run. `powMod(2, 10, 1e9+7)` prints `1024`, `powMod(2, 62, 1e9+7)` prints
`145586002`, `powMod(3, 10n**18n, 1e9+7)` prints `246336683`.
`sieve(30)` prints the ten primes below 30 and `sieve(1e7).length` prints `664579`.

#trap[
*The three JavaScript number bugs that fail more submissions than any algorithm mistake.*

+ *`1 << 40` is not $2^40$ — it is `256`.* JavaScript masks the shift count to its bottom
  5 bits, so `1 << 40` computes `1 << 8`. Even worse, `1 << 32` gives `1`, not 0, and
  `1 << 31` gives $-2147483648$ because bit 31 is the sign bit. Safe shifts are
  `1 << k` for $k <= 30$ only. Beyond that use `2 ** k` (a plain number, exact to
  $k = 53$) or `1n << BigInt(k)` (a BigInt, exact forever).
+ *`a * b % mod` silently rounds.* With `a = 123456789` and `b = 987654321`,
  `a * b` gives `121932631112635260` but the true product is `121932631112635269`. The
  modulus then comes out as `259106854` instead of `259106859`. Convert to `BigInt`
  *before* multiplying.
+ *A big literal is already wrong before you use it.* Typing
  `999999998000000002` in source produces the number `999999998000000000`. If a value can
  exceed $2^53 - 1$, it must arrive and stay as a `BigInt`.
]

#trap[
*`>>` and `>>>` are different operators.* `>>` keeps the sign bit, so `-1 >> 1` is still
$-1$ and a `while (x) { x >>= 1; }` loop over a negative number never ends. `>>>` shifts
in zeros and treats the value as unsigned 32-bit: `-1 >>> 1` is `2147483647`. Whenever a
problem says "unsigned 32-bit", the loop needs `>>>`, and `x >>> 0` is the idiom that
turns a negative 32-bit result back into its unsigned reading.
]

#section[Warm-up — build the reflex]

#tier-header(0)

#ex(1, tier: 0, asked: "TCS NQT pattern")[
Write four one-line functions: read bit $k$, set bit $k$, clear bit $k$, flip bit $k$.
Test them all on $x = 22$.

*Constraints:* $0 <= k <= 30$. *Target:* $O(1)$ each.
*Edge cases:* $k = 0$; a bit that is already in the wanted state.
]
#sol[
$22$ in binary is `10110`. Positions from the right: bit 0 is 0, bit 1 is 1, bit 2 is 1,
bit 3 is 0, bit 4 is 1.

#code(lang: "js", caption: "the four one-bit operations")[
```js
const getBit   = (x, k) => (x >> k) & 1;
const setBit   = (x, k) => x | (1 << k);
const clearBit = (x, k) => x & ~(1 << k);
const flipBit  = (x, k) => x ^ (1 << k);
```
]

#table(columns: (auto, auto, auto, auto),
  [*Call*], [*Working*], [*Binary*], [*Result*],
  [`getBit(22,0)`],   [`10110 >> 0 & 1`], [`...0`],    [0],
  [`getBit(22,1)`],   [`10110 >> 1 = 1011`, and 1], [`...1`], [1],
  [`setBit(22,0)`],   [`10110 | 00001`],  [`10111`],   [23],
  [`clearBit(22,1)`], [`10110 & 11101`],  [`10100`],   [20],
  [`flipBit(22,2)`],  [`10110 ^ 00100`],  [`10010`],   [18],
)

Run output: `0 1 1 1` for the four `getBit` calls (bits 0, 1, 2, 4), then `23 20 18`.
]
#ans[0, 1, 1, 1 then 23, 20, 18]

#note[
`setBit` on a bit that is already 1 leaves it at 1 — OR is *idempotent*. The run confirms
it: `setBit(23, 0)` prints `23` and `clearBit(20, 1)` prints `20`. Only `flipBit` changes
something every single time.
]

#ex(2, tier: 0, asked: "Accenture pattern")[
Decide whether a number is a power of two, in $O(1)$, with no loop and no `log`.

*Constraints:* values up to $10^18$, so the arithmetic must be `BigInt`.
*Edge cases:* 0; negative numbers; $2^40$.
]
#sol[
A power of two has *exactly one* bit on. And `x & (x - 1)` removes the lowest bit that is
on. So if the result is 0, there was only one bit.

The `x > 0` guard is essential: `x = 0` gives `0n & -1n === 0n` (wrong answer "yes"), and
a negative `BigInt` behaves as if it had an infinite run of sign bits.

#code(lang: "js", caption: "isPowerOfTwo")[
```js
const isPowerOfTwo = (x) => {
  const b = BigInt(x);
  return b > 0n && (b & (b - 1n)) === 0n;
};
```
]

Run on $1, 2, 3, 64, 0, -8, 2^40$: output `1101001`. Exactly right — 3 is not a power of
two, 0 is not, $-8$ is not, and $2^40$ is.
]
#ans[`1101001`]

#trap[
Do *not* write this with plain `&` on a number: `1 << 40` is 256, so the number version
would call $2^40$ a non-power-of-two and $256$ a power of two. `BigInt` bitwise operators
are the only ones in JavaScript that are not capped at 32 bits.
]

#ex(3, tier: 0, asked: "Infosys pattern")[
Return the lowest set bit of a number *as a value*, and also its *index*.

*Constraints:* values up to $10^18$. *Target:* $O(1)$ value, $O(63)$ index.
*Edge cases:* 0 (no bits at all); $2^40$.
]
#sol[
`x & -x` is the whole trick. In two's complement, $-x$ is `~x + 1`, which flips every bit
above the lowest 1 and leaves the lowest 1 alone. ANDing keeps only that bit. `BigInt`
follows the same two's-complement rule, with an unlimited sign extension.

#code(lang: "js", caption: "lowest set bit, value and index")[
```js
const lowestSetBit = (x) => { const b = BigInt(x); return b & -b; };

const lowestSetIndex = (x) => {
  let b = BigInt(x);
  if (b === 0n) return -1;          // no bits at all
  b &= -b;                          // keep only the lowest one
  let i = 0;
  while (b > 1n) { b >>= 1n; i++; }
  return i;
};
```
]

#table(columns: (auto, auto, auto, auto, auto),
  [*x*], [*binary*], [*$-x$ binary (low part)*], [*x & -x*], [*index*],
  [12], [`1100`], [`...0100`], [4], [2],
  [1],  [`0001`], [`...1111`], [1], [0],
  [0],  [`0000`], [`0000`],    [0], [$-1$],
)

Run output: `4n 1n 0n` for the values and `2 -1 40` for the indices.
]
#ans[4, 1, 0 and indices 2, $-1$, 40]

#trap[
JavaScript has no `__builtin_ctz`, no `__builtin_popcount`, and no `Math.log2` you can
trust for this — `Math.log2` returns a double and rounds. The explicit shift loop above is
the honest answer, and 63 turns is free. For a *32-bit* value there is one built-in worth
knowing: `Math.clz32(x)` counts *leading* zeros, so the index of the highest set bit is
`31 - Math.clz32(x)`.
]

#ex(4, tier: 0, asked: "Wipro pattern")[
Count how many bits of an unsigned 32-bit number are 1, the plain way.

*Constraints:* the full unsigned 32-bit range. *Target:* $O(32)$.
*Edge cases:* 0; all bits on.
]
#sol[
#code(lang: "js", caption: "countBitsLoop — one turn per bit position")[
```js
const countBitsLoop = (x) => {
  let v = x >>> 0, c = 0;          // >>> 0 reads the value as unsigned 32-bit
  while (v) { c += v & 1; v >>>= 1; }
  return c;
};
```
]

Run: $0 arrow.r$ `0`; $7 arrow.r$ `3`; $255 arrow.r$ `8`; $4294967295 arrow.r$ `32`.
]
#ans[0, 3, 8, 32]

#trap[
Use `>>>=`, not `>>=`. `>>` copies the sign bit, so on a negative input `v >>= 1` settles
on $-1$ forever and the loop never ends. The run proves it: `-1 >> 1` prints `-1` while
`-1 >>> 1` prints `2147483647`.
]

#ex(5, tier: 0, asked: "Capgemini pattern")[
Swap two values without a third variable.

*Edge cases:* the two names refer to the *same* storage slot.
]
#sol[
JavaScript passes numbers by value, so there is no `int&` to swap. The question really
lives on two *slots* — two array elements — and that is where the classic bug lives too.

Three XORs. Each line uses the fact that $a xor b xor b = a$.

#code(lang: "js", caption: "swapXor — with the guard nobody remembers")[
```js
const swapXor = (a, i, j) => {
  if (i === j) return a;                  // the guard everybody forgets
  a[i] ^= a[j]; a[j] ^= a[i]; a[i] ^= a[j];
  return a;
};
```
]

#table(columns: (auto, auto, auto, 1fr),
  [*Line*], [*a[i]*], [*a[j]*], [*Reasoning*],
  [start],       [3], [9], [—],
  [`a[i]^=a[j]`],[$3 xor 9 = 10$], [9], [slot i now holds the combination],
  [`a[j]^=a[i]`],[10], [$9 xor 10 = 3$], [slot j recovers the old a[i]],
  [`a[i]^=a[j]`],[$10 xor 3 = 9$], [3], [slot i recovers the old a[j]],
)

Run: `swapXor([3, 9], 0, 1)` prints `9 3`. `swapXor([5], 0, 0)` prints `5` thanks to the
guard — without it the first line would set the slot to 0 and destroy the value.
]
#ans[9 and 3; and 5 stays 5 when swapped with itself]

#trick[
In real JavaScript you never write this. `[a, b] = [b, a]` swaps two variables in one
line, has no aliasing bug, and works on any type — the run prints `9 3` for that too. The
XOR version is an interview question about two's complement, not a technique you ship.
]

#ex(6, tier: 0, asked: "Cognizant pattern")[
Turn off the lowest set bit and report what is left. Also say how many times you can
repeat this before reaching 0.

*Edge cases:* 0; a power of two.
]
#sol[
#code(lang: "js", caption: "dropLowestBit")[
```js
const dropLowestBit = (x) => { const b = BigInt(x); return b & (b - 1n); };
```
]

Run: $12 arrow.r$ `8n`; $8 arrow.r$ `0n`; $0 arrow.r$ `0n`.

The number of repeats before reaching 0 is exactly the number of 1 bits — which is
the whole idea behind the next section's fastest popcount.
]
#ans[8, 0, 0]

#section[Tier 1 — the standard toolkit]

#tier-header(1)

#ex(7, tier: 1, asked: "TCS Digital pattern")[
Every element of an array appears *twice*, except one which appears once. Find that one.

*Constraints:* $n <= 10^6$, values can be negative. *Target:* $O(n)$ time, $O(1)$ space.
*Edge cases:* a one-element array; negative values.
]
#sol[

#approach(1, "Count occurrences of each element by scanning again", verdict: "O(n^2), too slow")

#code(lang: "js", caption: "singleBrute")[
```js
const singleBrute = (a) => {
  for (const v of a) {
    let c = 0;
    for (const x of a) if (x === v) c++;
    if (c === 1) return v;
  }
  return -1;
};
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "Hash map of counts", verdict: "O(n) time but O(n) space")

#code(lang: "js", caption: "singleMap")[
```js
const singleMap = (a) => {
  const f = new Map();                       // Map, not {} -- keys keep their type
  for (const x of a) f.set(x, (f.get(x) ?? 0) + 1);
  for (const [k, v] of f) if (v === 1) return k;
  return -1;
};
```
]
#complexity(time: $O(n)$, space: $O(n)$)

#approach(3, "XOR everything together", verdict: "O(n) time, O(1) space, optimal")

The unlock: $x xor x = 0$ and $x xor 0 = x$, and XOR does not care about order. So
XORing the whole array makes every *pair* cancel to 0, and 0 XOR the lonely value is the
lonely value.

#code(lang: "js", caption: "singleXor")[
```js
const singleXor = (a) => a.reduce((r, x) => r ^ x, 0);
```
]
#complexity(time: $O(n)$, space: $O(1)$, note: "One pass, one integer of state. Works on negatives without any change, because JS converts each operand to a signed 32-bit pattern and XOR operates on the raw bits.")

#subsection[Trace on $4, 7, 4, 9, 7$]

#table(columns: (auto, auto, auto, 1fr),
  [*x*], [*r before*], [*r after*], [*Binary*],
  [4], [0],  [4],  [`0000 ^ 0100 = 0100`],
  [7], [4],  [3],  [`0100 ^ 0111 = 0011`],
  [4], [3],  [7],  [`0011 ^ 0100 = 0111`],
  [9], [7],  [14], [`0111 ^ 1001 = 1110`],
  [7], [14], [9],  [`1110 ^ 0111 = 1001`],
)

All three versions were run on this array; all three printed `9`. The running values of
`r` printed `4 3 7 14 9`, matching the table row for row.
`singleXor([-3, 5, -3])` prints `5` and `singleXor([8])` prints `8`.
]
#ans[9]

#trap[
`singleXor` only works while every value fits in 32 signed bits. `2 ** 40 ^ 0` is `0`,
because the XOR converts $2^40$ to a 32-bit pattern first and every one of those bits is
zero. If values can exceed $2^31 - 1$, seed the reduce with `0n` and map the array through
`BigInt`.
]

#ex(8, tier: 1, asked: "Accenture pattern")[
Count the set bits of a 64-bit number, but make the loop run once per *set* bit instead of
once per bit position.

*Constraints:* values up to $2^64 - 1$, so `BigInt`. *Target:* $O("popcount")$.
*Edge cases:* 0; all 64 bits on.
]
#sol[
Each turn, `x &= x - 1` deletes exactly one 1. Count the turns.

#code(lang: "js", caption: "popcount — Kernighan's loop, BigInt so it survives past 32 bits")[
```js
const popcount = (x) => {
  let v = BigInt(x), c = 0;
  while (v) { v &= v - 1n; c++; }            // one turn per SET bit
  return c;
};
```
]

#complexity(time: [$O(s)$ where $s$ is the number of set bits], space: $O(1)$, note: "For a sparse number like 2^40 this is 1 turn instead of 41 — the run confirms popcount(2n ** 40n) is 1.")

#subsection[Trace on $x = 12$ (`1100`)]

#table(columns: (auto, auto, auto, auto),
  [*Turn*], [*x*], [*x - 1*], [*x & (x-1)*],
  [1], [`1100` = 12], [`1011`], [`1000` = 8],
  [2], [`1000` = 8],  [`0111`], [`0000` = 0],
)
Two turns, so two set bits.

Run: $0 arrow.r$ `0`; $7 arrow.r$ `3`; $1023 arrow.r$ `10`; $2^64 - 1 arrow.r$ `64`.
]
#ans[0, 3, 10, 64]

#trick[
When the value is known to fit in 32 bits, do the same loop on a plain number — it is
several times faster than `BigInt` and the code is identical apart from the literals:

#code(lang: "js", caption: "popcount32 — same loop, no BigInt")[
```js
const popcount32 = (x) => {
  let v = x >>> 0, c = 0;
  while (v) { v &= v - 1; c++; }
  return c;
};
```
]
Run: `0 3 10 32` for $0, 7, 1023, 2^32 - 1$. There is *no* built-in popcount in
JavaScript, so one of these two is what you write.
]

#code(lang: "python", caption: "Python version")[
```python
def popcount(x):
    c = 0
    while x:
        x &= x - 1
        c += 1
    return c
```
]
Run: `popcount(0)` $arrow.r$ `0`, `popcount(7)` $arrow.r$ `3`, `popcount(1023)`
$arrow.r$ `10`. Python integers are arbitrary precision, so the same three lines handle
64-bit and 640-bit values alike — and `(1023).bit_count()` is the built-in shortcut
JavaScript does not have.

#ex(9, tier: 1, asked: "Infosys pattern")[
List every subset of a set of $n$ distinct items, using bit masks.

*Constraints:* $n <= 20$ (else $2^n$ is too big).
*Target:* $O(2^n dot n)$. *Edge cases:* the empty set (one subset — itself).
]
#sol[
Number the items $0 dots n-1$. A subset is a number from $0$ to $2^n - 1$ where bit $i$
means "item $i$ is in". Counting from 0 to $2^n - 1$ therefore visits every subset
exactly once.

#code(lang: "js", caption: "allSubsets — counting is enumerating")[
```js
const allSubsets = (a) => {
  const n = a.length, out = [];
  for (let mask = 0; mask < (1 << n); mask++) {
    const cur = [];
    for (let i = 0; i < n; i++)
      if ((mask >> i) & 1) cur.push(a[i]);
    out.push(cur);
  }
  return out;
};
```
]

#complexity(time: $O(2^n dot n)$, space: $O(2^n dot n)$)

#table(columns: (auto, auto, auto),
  [*mask*], [*binary*], [*subset of ${1,2,3}$*],
  [0], [`000`], [`{}`],
  [1], [`001`], [`{1}`],
  [2], [`010`], [`{2}`],
  [3], [`011`], [`{1,2}`],
  [4], [`100`], [`{3}`],
  [5], [`101`], [`{1,3}`],
  [6], [`110`], [`{2,3}`],
  [7], [`111`], [`{1,2,3}`],
)

Run output: `{}{1}{2}{12}{3}{13}{23}{123}`. On an empty input the function returns
exactly one subset (the empty one), which the run confirmed by printing `1`.
]
#ans[8 subsets, listed above]

#trap[
`mask < (1 << n)` is a *silent* disaster at $n = 31$ and above. `1 << 31` is
$-2147483648$, so the loop never starts and you get zero subsets with no error at all.
At $n = 32$, `1 << 32` is `1` and you get one subset. In practice $n > 25$ is already too
slow, so hitting this means you have misread the constraints — but write
`mask < 2 ** n` if you want the loop to be honestly impossible rather than silently
empty.
]

#ex(10, tier: 1, asked: "Wipro pattern")[
Write `gcd` and `lcm` for two numbers up to $10^9$ without losing precision.

*Constraints:* inputs up to $10^9$; the lcm can reach $10^18$, which is past $2^53 - 1$.
*Target:* $O(log min(a,b))$. *Edge cases:* one input is 0; negative inputs.
]
#sol[
Euclid's rule: $gcd(a,b) = gcd(b, a mod b)$, stopping when $b$ is 0. Inputs up to $10^9$
are far below $2^53$, so `gcd` needs no `BigInt` — but the *lcm* does.

#code(lang: "js", caption: "gcd and lcmSafe")[
```js
const gcd = (a, b) => {
  a = Math.abs(a); b = Math.abs(b);
  while (b) { [a, b] = [b, a % b]; }         // destructuring: no temp variable
  return a;
};

const lcmSafe = (a, b) => {
  if (a === 0 || b === 0) return 0n;
  const g = BigInt(gcd(a, b));
  return BigInt(Math.abs(a)) / g * BigInt(Math.abs(b));   // divide FIRST
};
```
]

#complexity(time: $O(log min(a,b))$, space: $O(1)$, note: "Euclid halves the pair roughly every two steps, so it is logarithmic, never linear.")

#subsection[Trace of `gcd(84, 132)`]

#table(columns: (auto, auto, auto),
  [*a*], [*b*], [*a mod b*],
  [84],  [132], [84],
  [132], [84],  [48],
  [84],  [48],  [36],
  [48],  [36],  [12],
  [36],  [12],  [0],
  [12],  [0],   [stop],
)
Answer 12. Note the first step politely swaps the pair for you: $84 mod 132 = 84$.

Runs: `gcd(84,132)` $arrow.r$ `12`; `gcd(0,7)` $arrow.r$ `7`; `gcd(-12,18)` $arrow.r$ `6`.
`lcmSafe(4,6)` $arrow.r$ `12n`; `lcmSafe(0,5)` $arrow.r$ `0n`;
`lcmSafe(1000000000, 999999999)` $arrow.r$ `999999999000000000n`.
]
#ans[gcd 12; lcm of the two big numbers is 999999999000000000]

#trap[
`a * b / gcd` on plain numbers is the bug, and JavaScript hides it better than C++ does.
With $a = 999999937$ and $b = 999999893$ (both prime, so the gcd is 1), the number version
prints `999999830000006800`. The true product is `999999830000006741` — the answer is
wrong in its last *two* digits and nothing warned you. `a / gcd * b` in `BigInt` never
forms a rounded value at all.
]

#ex(11, tier: 1, asked: "Capgemini pattern")[
Is $n$ prime?

*Constraints:* $n$ up to $10^12$. *Target:* $O(sqrt(n))$.
*Edge cases:* 0 and 1 (not prime); 2 (the only even prime); a large prime.
]
#sol[

#approach(1, "Try every divisor from 2 to n-1", verdict: "O(n), hopeless past 10^9")

#code(lang: "js", caption: "isPrimeSlow")[
```js
const isPrimeSlow = (n) => {
  if (n < 2) return false;
  for (let d = 2; d < n; d++) if (n % d === 0) return false;
  return true;
};
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#approach(2, "Stop at the square root, and skip even numbers", verdict: "O(sqrt n), optimal for a single test")

The unlock: divisors come in *pairs*. If $n = d times e$ with $d <= e$, then
$d <= sqrt(n)$. So if no divisor up to $sqrt(n)$ exists, none exists at all — the partner
would have been found first.

#code(lang: "js", caption: "isPrimeFast")[
```js
const isPrimeFast = (n) => {
  if (n < 2) return false;
  if (n % 2 === 0) return n === 2;
  for (let d = 3; d * d <= n; d += 2) if (n % d === 0) return false;
  return true;
};
```
]
#complexity(time: $O(sqrt(n) \/ 2)$, space: $O(1)$, note: "d * d reaches n = 10^12 at most, and 10^12 is well under 2^53, so plain numbers stay exact here. Use d * d <= n, never d <= Math.sqrt(n).")

Runs: both versions printed the same for 97 (`1`), 1 (`0`) and 2 (`1`). The fast version
alone handled $1000000007$ and printed `1`; the slow one would need a billion turns. At
the top of the range `isPrimeFast(1000000000039)` prints `1` and
`isPrimeFast(1000000000000)` prints `0`.
]
#ans[97 prime, 1 not prime, 2 prime, 1000000007 prime]

#trap[
`Math.sqrt` returns a double. At $n$ near $10^12$ it is still exact, but the habit is what
kills you later: above $2^53$ the square root is rounded and the loop bound is off by one
in either direction. `d * d <= n` has no such failure mode while $n <= 2^53$, and past
that the whole function must move to `BigInt`.
]

#ex(12, tier: 1, asked: "Cognizant pattern")[
Print every prime up to $n$.

*Constraints:* $n <= 10^7$. *Target:* $O(n log log n)$, $O(n)$ memory.
*Edge cases:* $n = 1$ (no primes); $n = 10^6$.
]
#sol[
Trial division per number would cost $O(n sqrt(n))$. The sieve flips the work around:
instead of asking "who divides me?", each prime *marks* its own multiples.

Start the inner loop at $i times i$, not $2i$. Every smaller multiple of $i$ already has a
smaller prime factor and was marked long ago.

#code(lang: "js", caption: "sieve — Template B")[
```js
const sieve = (n) => {
  const composite = new Uint8Array(n + 1);
  const primes = [];
  for (let i = 2; i <= n; i++) {
    if (!composite[i]) {
      primes.push(i);
      for (let j = i * i; j <= n; j += i) composite[j] = 1;
    }
  }
  return primes;
};
```
]

#complexity(time: $O(n log log n)$, space: $O(n)$, note: "log log 10^7 is under 4, so in practice this is a small constant times n.")

#subsection[Trace for $n = 30$]

#table(columns: (auto, 1fr),
  [*i = 2*], [prime. Mark 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30],
  [*i = 3*], [not marked $arrow.r$ prime. Mark 9, 12, 15, 18, 21, 24, 27, 30],
  [*i = 4*], [already marked, skip],
  [*i = 5*], [prime. Mark 25, 30],
  [*i = 6*], [marked, skip],
  [*i = 7*], [prime. $7 times 7 = 49 > 30$, nothing to mark],
  [*8 to 30*], [every composite is already marked; the rest are collected as primes],
)

Run output: `2 3 5 7 11 13 17 19 23 29`, count 10.
`sieve(1)` returns nothing; `sieve(1000000)` returns `78498` primes and `sieve(10000000)`
returns `664579`.
]
#ans[10 primes below 30; 78498 primes below $10^6$]

#code(lang: "python", caption: "Python version")[
```python
def sieve(n):
    composite = [False] * (n + 1)
    primes = []
    for i in range(2, n + 1):
        if not composite[i]:
            primes.append(i)
            for j in range(i * i, n + 1, i):
                composite[j] = True
    return primes
```
]
Run: `sieve(30)` prints the same ten primes; `len(sieve(1000000))` prints `78498`.

#trap[
Use a `Uint8Array`, not `new Array(n + 1).fill(false)`. A plain JavaScript array of
$10^7$ booleans is $10^7$ tagged values — tens of megabytes and a cache miss on every
write. `Uint8Array` is one contiguous byte per entry, 10 MB for $n = 10^7$, and it starts
zero-filled so you do not even pay for the `fill`. `i * i` needs no special care here:
$10^7$ squared is $10^14$, comfortably inside the exact-integer range.
]

#ex(13, tier: 1, asked: "TCS NQT pattern")[
How many zeros does $n!$ end with?

*Constraints:* $n$ up to $10^18$. *Target:* $O(log_5 n)$.
*Edge cases:* $n = 0$ (answer 0); $n = 5$; $n = 10^9$.
]
#sol[
A trailing zero comes from a factor of 10, and $10 = 2 times 5$. In $n!$ there are far
more 2s than 5s, so the answer is *the number of 5s*.

Count them in layers: $floor(n/5)$ numbers give at least one 5, $floor(n/25)$ give a
second one, $floor(n/125)$ give a third, and so on.

$ Z(n) = floor(n/5) + floor(n/25) + floor(n/125) + dots $

$n$ can be $10^18$, past $2^53 - 1$, so both the input and the running total are `BigInt`.
`BigInt` division truncates toward zero, which is exactly the floor we want for positive
values.

#code(lang: "js", caption: "trailingZeros")[
```js
const trailingZeros = (n) => {
  const N = BigInt(n);
  let z = 0n;
  for (let p = 5n; p <= N; p *= 5n) z += N / p;    // BigInt / truncates = floor
  return z;
};
```
]

#complexity(time: $O(log_5 n)$, space: $O(1)$, note: "For n = 10^18 the loop runs 26 times.")

#table(columns: (auto, auto, auto, auto, auto),
  [*n*], [*n/5*], [*n/25*], [*n/125*], [*Total*],
  [5],   [1],  [0], [0], [1],
  [25],  [5],  [1], [0], [6],
  [100], [20], [4], [0], [24],
)

Run output: `1n 6n 24n 0n 249999998n` for $n = 5, 25, 100, 0, 10^9$, and
`trailingZeros(10n ** 18n)` prints `249999999999999995n`.
]
#ans[1, 6, 24, 0, 249999998]

#trap[
Had this been written on plain numbers, `p *= 5` would still *run* — `BigInt` is the only
thing that makes the $10^18$ case correct. The number version fails twice over: the
argument $10^18 + 3$ cannot even be written down exactly, and `z` itself reaches
$2.5 times 10^17$, which is past $2^53 - 1$. A count that can exceed $9 times 10^15$ is a
`BigInt` count.
]

#ex(14, tier: 1, asked: "Accenture pattern")[
Compute $a^b mod m$ where $b$ can be $10^18$.

*Constraints:* $a, m <= 10^9$, $b <= 10^18$.
*Target:* $O(log b)$. *Edge cases:* $b = 0$; $m = 1$; a negative base.
]
#sol[
Multiplying $b$ times is $10^18$ operations. Instead use the binary expansion of $b$.

$ a^13 = a^(8 + 4 + 1) = a^8 times a^4 times a^1 $

13 in binary is `1101`. So: square the base at every step and multiply it into the answer
whenever the current bit of $b$ is 1.

#code(lang: "js", caption: "powMod — Template A")[
```js
const powMod = (base, exp, mod) => {
  const m = BigInt(mod);
  let b = BigInt(base) % m, e = BigInt(exp), r = 1n % m;
  if (b < 0n) b += m;
  while (e > 0n) {
    if (e & 1n) r = r * b % m;
    b = b * b % m;
    e >>= 1n;
  }
  return Number(r);
};
```
]

#complexity(time: $O(log b)$, space: $O(1)$, note: "At most 60 turns for an exponent of 10^18. BigInt ops on numbers this small are a few nanoseconds each.")

#subsection[Trace of `powMod(2, 10, 1000000007)`]

10 in binary is `1010`.

#table(columns: (auto, auto, auto, auto, auto),
  [*Turn*], [*exp*], [*bit*], [*r after*], [*base after*],
  [1], [10 = `1010`], [0], [1], [$2^2 = 4$],
  [2], [5 = `101`],   [1], [$1 times 4 = 4$], [$4^2 = 16$],
  [3], [2 = `10`],    [0], [4], [$16^2 = 256$],
  [4], [1 = `1`],     [1], [$4 times 256 = 1024$], [$256^2$],
  [5], [0], [—], [stop], [—],
)

Run output: `1024 1 145586002 0` for $2^10 mod (10^9+7)$, $3^0 mod 7$,
$2^62 mod (10^9+7)$, and $5^3 mod 1$. A negative base works too:
`powMod(-2, 3, 1e9+7)` prints `999999999`, which is $-8$ folded back into range.
]
#ans[1024; 1; 145586002; 0]

#trap[
`let r = 1n % m;` — not `= 1n`. When `mod` is 1 every answer must be 0, and starting at 1
with an exponent of 0 would wrongly return 1. This is a favourite hidden test case.

The `BigInt(exp)` in the signature is doing quiet work as well: it accepts `10n ** 18n`
*and* the number `1000000000`. If you let a caller pass the *number* $10^18 + 1$, the
exponent is wrong before your function ever sees it.
]

#code(lang: "python", caption: "Python version — the whole thing is a built-in")[
```python
def pow_mod(base, exp, mod):
    return pow(base, exp, mod)          # three-argument pow IS modular exponentiation
```
]
Run: `pow_mod(2, 10, 1000000007)` prints `1024`, `pow_mod(2, 62, 1000000007)` prints
`145586002`, `pow_mod(5, 3, 1)` prints `0`, and `pow_mod(3, 10 ** 18, 1000000007)` prints
`246336683` — the same four values the JavaScript version produced. Python integers are
arbitrary precision, so there is no `BigInt` decision to make and no overflow to guard
against. This is the clearest case in the book of Python being shorter for the wrong
reason: you still have to be able to *write* square-and-multiply on a whiteboard.

#ex(15, tier: 1, asked: "Infosys pattern")[
Reverse the 32 bits of an unsigned number: bit 0 becomes bit 31, bit 1 becomes bit 30,
and so on.

*Constraints:* exactly 32 bits. *Target:* $O(32)$.
*Edge cases:* 0; 1; all bits on.
]
#sol[
Pull one bit off the right of the input and push it onto the right of the answer. After
32 turns the order is reversed.

#code(lang: "js", caption: "reverseBits")[
```js
const reverseBits = (x) => {
  let v = x >>> 0, r = 0;
  for (let i = 0; i < 32; i++) {
    r = ((r << 1) | (v & 1)) >>> 0;          // >>> 0 keeps r unsigned
    v >>>= 1;
  }
  return r >>> 0;
};
```
]

#complexity(time: $O(32)$, space: $O(1)$)

Run: $1 arrow.r$ `2147483648` (that is $2^31$ — bit 0 moved to bit 31);
$0 arrow.r$ `0`; all 32 bits on $arrow.r$ `4294967295` (unchanged, as expected).
`reverseBits(2147483648)` prints `1`, which is the round trip.
]
#ans[2147483648, 0, 4294967295]

#trap[
Two failures hide in this five-line function.

+ The loop must run a fixed *32* times, not `while (v)`. Reversing `1` with a `while` loop
  would stop after one turn and return 1 instead of $2^31$.
+ Every `>>> 0` is load-bearing. Once the answer reaches bit 31, `r << 1` produces a
  *negative* number, and without the `>>> 0` the function returns $-1$ instead of
  `4294967295`. Any time a 32-bit answer is meant to be read as unsigned, the last thing
  you do to it is `>>> 0`.
]

#ex(16, tier: 1, asked: "Wipro pattern")[
Digit sum and digit reversal of a possibly negative integer.

*Constraints:* values within the exact-integer range. *Target:* $O(d)$ where $d$ is the
digit count. *Edge cases:* 0; a negative number; a number ending in zeros.
]
#sol[
There is no integer division in JavaScript, so `n /= 10` would give a fraction and the
loop would never terminate. `Math.floor(v / 10)` is the replacement, and the loop
condition is `v > 0` rather than a truthiness test.

#code(lang: "js", caption: "digitSum and reverseDigits")[
```js
const digitSum = (n) => {
  let v = Math.abs(n), s = 0;
  while (v > 0) { s += v % 10; v = Math.floor(v / 10); }
  return s;
};

const reverseDigits = (n) => {
  const sign = n < 0 ? -1 : 1;
  let v = Math.abs(n), r = 0;
  while (v > 0) { r = r * 10 + (v % 10); v = Math.floor(v / 10); }
  return sign * r;
};
```
]

Runs: `digitSum(98765)` $arrow.r$ `35`; `digitSum(0)` $arrow.r$ `0`;
`digitSum(-407)` $arrow.r$ `11`.
`reverseDigits(1200)` $arrow.r$ `21`; `reverseDigits(-95)` $arrow.r$ `-59`;
`reverseDigits(0)` $arrow.r$ `0`.
]
#ans[35, 0, 11; then 21, $-59$, 0]

#note[
`reverseDigits(1200)` gives 21, not 0021. Leading zeros simply do not exist in a number —
this is a favourite "gotcha" question and the honest answer is that nothing special needs
to be done.
]

#trick[
For a value beyond $2^53 - 1$, stop doing arithmetic and use the string:
`[...String(n)].reduce((s, c) => s + +c, 0)` for the digit sum, and
`[...String(n)].reverse().join('')` for the reversal. Strings have no precision limit, and
this is the version to reach for when the constraint says $10^18$. Note the string
reversal keeps the leading zeros — `1200` comes back as `"0021"`, the run confirms it —
so wrap it in `BigInt(...)` if you want the number 21 back.
]

#section[Tier 2 — two ideas stitched together]

#tier-header(2)

#ex(17, tier: 2, asked: "Grab · pattern")[
In an array, *two* different values appear exactly once and every other value appears
exactly twice. Find both, in ascending order.

*Constraints:* $n <= 10^6$, values may be negative.
*Target:* $O(n)$ time, $O(1)$ space. *Edge cases:* an array of exactly two elements;
negative values.
]
#sol[

#approach(1, "Count every value in a map", verdict: "O(n log n) time and O(n) space")

#code(lang: "js", caption: "twoSinglesMap")[
```js
const twoSinglesMap = (a) => {
  const f = new Map();
  for (const x of a) f.set(x, (f.get(x) ?? 0) + 1);
  return [...f].filter(([, c]) => c === 1)
               .map(([k]) => k)
               .sort((p, q) => p - q);        // NEVER a bare .sort()
};
```
]

#complexity(time: $O(n log n)$, space: $O(n)$, note: "Run on the two tests below it printed 4 9 and 3 7 — the same as the optimal version. The problem statement's O(1) space rule is what rules it out.")

#trap[
*`arr.sort()` in JavaScript is LEXICOGRAPHIC, not numeric.* `[10, 9, 1].sort()` gives
`[1, 10, 9]`, because the default comparator turns every element into a string first. This
problem asks for the answer *in ascending order*, so the bare sort is a wrong answer, not
a style issue — the run proves it: sorting the keys `4, 9, 10` with `.sort()` prints
`10 4 9`, while `.sort((p, q) => p - q)` prints `4 9 10`.

Two rules travel with it:
- A comparator must return a *number*, never a boolean. `(p, q) => p > q` yields
  `true`/`false`, which coerce to `1`/`0`, so the sort never sees a negative and leaves
  the array essentially untouched.
- Chain tie-breaks with `||`, because `0` is falsy: `(p, q) => p[0] - q[0] || p[1] - q[1]`.
]

#approach(2, "XOR everything, then split on a differing bit", verdict: "O(n) time, O(1) space, optimal")

XOR the whole array. Every pair cancels, so you are left with $u xor v$ — the XOR of the
two lonely values. That is not enough on its own.

The unlock: *$u$ and $v$ are different, so $u xor v$ has at least one bit set, and at
that bit position $u$ and $v$ disagree.* Pick any such bit — `all & -all` gives the lowest
one. Now split the array into "bit set" and "bit clear". Each half contains exactly one
lonely value and complete pairs. XOR each half separately.

#code(lang: "js", caption: "twoSingles — XOR, then split on a differing bit")[
```js
const twoSingles = (a) => {
  let all = 0;
  for (const x of a) all ^= x;
  const bit = all & -all;                    // any bit where the two differ
  let g1 = 0, g2 = 0;
  for (const x of a) {
    if (x & bit) g1 ^= x;
    else         g2 ^= x;
  }
  return [Math.min(g1, g2), Math.max(g1, g2)];
};
```
]

#complexity(time: $O(n)$, space: $O(1)$, note: "Two passes, three integers of state, and Math.min/Math.max instead of a sort.")

#subsection[Trace on $4, 1, 2, 1, 2, 9$]

*Pass 1.* $4 xor 1 xor 2 xor 1 xor 2 xor 9 = 4 xor 9 = 13$ (`1101`).
So `bit = 13 & -13 = 1` (`0001`).

*Pass 2.* Split on bit 0 (odd or even).

#table(columns: (auto, auto, auto, auto),
  [*x*], [*x & 1*], [*Goes to*], [*Group XOR after*],
  [4], [0], [g2 (even)], [g2 = 4],
  [1], [1], [g1 (odd)],  [g1 = 1],
  [2], [0], [g2],        [g2 = 6],
  [1], [1], [g1],        [g1 = 0],
  [2], [0], [g2],        [g2 = 4],
  [9], [1], [g1],        [g1 = 9],
)

Run output: `4 9`. `twoSingles([-5, 7, -5, 3])` prints `3 7` and `twoSingles([3, 8])`
prints `3 8`.
]
#ans[4 and 9]

#diagram(height: 3.6cm, caption: "the differing bit splits the array into two clean halves")[
  #dnode(0.2cm, 0.2cm, 4.0cm, 0.8cm, "all six values XORed = 4 XOR 9 = 1101")
  #darrow(2.2cm, 1.0cm, 1.3cm, 1.7cm)
  #darrow(2.2cm, 1.0cm, 5.6cm, 1.7cm)
  #dnode(0.2cm, 1.75cm, 3.0cm, 0.8cm, "bit 0 clear: 4, 2, 2", fill: rgb("#eef3ea"))
  #dnode(4.2cm, 1.75cm, 3.0cm, 0.8cm, "bit 0 set: 1, 1, 9", fill: rgb("#f7efe4"))
  #dnode(0.2cm, 2.75cm, 3.0cm, 0.6cm, "XOR = 4")
  #dnode(4.2cm, 2.75cm, 3.0cm, 0.6cm, "XOR = 9")
]

#ex(18, tier: 2, asked: "Shopee · pattern")[
An array of length $n$ holds values from $1$ to $n$. Exactly one value is *missing* and
exactly one value appears *twice*. Find both.

*Constraints:* $n <= 10^6$. *Target:* $O(n)$ time, $O(1)$ space.
*Edge cases:* $n = 2$; the repeated value is 1 or $n$.
]
#sol[

#approach(1, "Tally the values in a counting array", verdict: "O(n) time but O(n) space")

#code(lang: "js", caption: "missRepCount")[
```js
const missRepCount = (a) => {
  const n = a.length;
  const seen = new Array(n + 2).fill(0);
  for (const x of a) seen[x]++;
  let rep = -1, mis = -1;
  for (let v = 1; v <= n; v++) {
    if (seen[v] === 2) rep = v;
    if (seen[v] === 0) mis = v;
  }
  return [rep, mis];
};
```
]

#complexity(time: $O(n)$, space: $O(n)$, note: "Printed 3 2 and 2 1 on the two tests — the same answers. Say this one out loud first in an interview, then offer the O(1)-space version.")

#approach(2, "XOR, then split on a differing bit", verdict: "O(n) time, O(1) space, optimal")

XOR the array *and* XOR $1 dots n$. Everything that appears the right number of times
cancels, leaving `repeated XOR missing`. Then split on a differing bit exactly as in
Example 17 — but this time each half must be swept over *both* the array and the range
$1 dots n$.

At the end you have the two values but not which is which. One extra count pass settles
it: if the array contains the candidate twice, that one is the repeat.

#code(lang: "js", caption: "missingAndRepeated — returns [repeated, missing]")[
```js
const missingAndRepeated = (a) => {
  const n = a.length;
  let x = 0;
  for (const v of a) x ^= v;
  for (let v = 1; v <= n; v++) x ^= v;       // x = repeated XOR missing
  const bit = x & -x;
  let p = 0, q = 0;
  for (const v of a)            { if (v & bit) p ^= v; else q ^= v; }
  for (let v = 1; v <= n; v++)  { if (v & bit) p ^= v; else q ^= v; }
  let cnt = 0;
  for (const v of a) if (v === p) cnt++;
  return cnt === 2 ? [p, q] : [q, p];
};
```
]

#complexity(time: $O(n)$, space: $O(1)$, note: "Four linear passes, no extra array.")

Runs: `missingAndRepeated([3,1,3,4,5])` prints `3 2` — 3 is repeated, 2 is missing.
`missingAndRepeated([2,2])` prints `2 1`. The two edge cases named in the statement both
hold: `[1,2,3,3]` prints `3 4` (the repeat is $n$) and `[1,1,3,4]` prints `1 2` (the
repeat is 1).
]
#ans[repeated 3, missing 2]

#trick[
A shorter but riskier alternative uses sums:
$S = sum a_i - sum_(1)^(n) i = "rep" - "miss"$ and
$Q = sum a_i^2 - sum i^2 = "rep"^2 - "miss"^2$. Solve the two equations. It works, but
$sum i^2$ for $n = 10^6$ is about $3.3 times 10^17$ — past $2^53 - 1$, so in JavaScript
the whole computation must be `BigInt` and the "shorter" version stops being shorter. The
XOR version never leaves 32-bit integers at all.
]

#ex(19, tier: 2, asked: "GIC · pattern")[
Compute $a / b mod M$ where $M = 10^9 + 7$ is prime. Then use it to compute
$binom(n, r) mod M$ for up to $10^5$ queries with $n <= 2 times 10^5$.

*Target:* $O(n)$ preprocessing, $O(1)$ per query.
*Edge cases:* $r < 0$ or $r > n$ (answer 0); $r = 0$; $n = r$.
]
#sol[
*Why you cannot just divide.* $(a / b) mod M$ is not $(a mod M) / (b mod M)$. In
JavaScript it is worse than in a language with integer division: `7 / 2` is `3.5`, and
`3.5 % 5` is `3.5`. A modulus applied to a fraction is meaningless.

*The fix.* Find the number $b^(-1)$ with $b times b^(-1) equiv 1 (mod M)$, then multiply
by it. Fermat's little theorem gives it for free when $M$ is prime:

$ b^(M-1) equiv 1 (mod M) quad => quad b^(-1) equiv b^(M-2) (mod M) $

#code(lang: "js", caption: "inverse by Fermat")[
```js
const inverse = (a, p) => powMod(a, p - 2, p);
```
]

For binomials, precompute all factorials and *all* their inverses. The clever part: do
*one* expensive inverse at the top and walk backwards, because
$("inv") (i-1)! = ("inv") i! times i$.

Every multiplication here is $10^9 times 10^9 approx 10^18$, far past $2^53 - 1$, so the
tables hold `BigInt` and only the returned value is converted back.

#code(lang: "js", caption: "makeComb — O(n) setup, O(1) queries")[
```js
const makeComb = (n, mod) => {
  const p = BigInt(mod);
  const f = new Array(n + 1).fill(1n);
  for (let i = 1; i <= n; i++) f[i] = f[i - 1] * BigInt(i) % p;

  const inv = new Array(n + 1).fill(1n);
  inv[n] = BigInt(powMod(Number(f[n]), mod - 2, mod));       // one expensive step
  for (let i = n; i >= 1; i--) inv[i - 1] = inv[i] * BigInt(i) % p;

  return (N, r) => (r < 0 || r > N)
    ? 0
    : Number(f[N] * inv[r] % p * inv[N - r] % p);
};
```
]

#complexity(time: [$O(n + log p)$ setup, $O(1)$ per query], space: $O(n)$, note: "Only one modular exponentiation in the whole setup. The closure keeps f and inv alive without a class.")

Runs: `inverse(3, MOD)` prints `333333336`, and `3n * 333333336n % MOD` prints `1n` —
which is the proof it is correct. With `const C = makeComb(200000, MOD)`:
`C(5,2)` $arrow.r$ `10`; `C(10,0)` $arrow.r$ `1`; `C(5,9)` $arrow.r$ `0`;
`C(200000, 100000)` $arrow.r$ `879467333`. That last one was checked against an exact
`BigInt` product of $binom(200000,100000)$ reduced mod $M$, which printed `879467333` too.
]
#ans[$3^(-1) = 333333336$; $binom(200000, 100000) equiv 879467333$]

#trap[
Fermat needs $M$ *prime*. For a composite modulus the inverse exists only when
$gcd(a, M) = 1$, and you must use the extended Euclid method instead — that is
Example 30.

A second, JavaScript-only trap: never verify an inverse with plain numbers.
`3 * 333333336 % 1000000007` happens to be right because the product is small, but the
same check on a pair near $10^9$ would round and print a wrong "proof". Verify in
`BigInt`.
]

#ex(20, tier: 2, asked: "Sea · pattern")[
Answer up to $10^5$ queries of the form "give me the prime factorisation of $x$", where
$x <= 10^6$.

*Target:* $O(n log log n)$ setup, then $O(log x)$ per query.
*Edge cases:* $x = 1$ (no factors); $x$ prime.
]
#sol[

#approach(1, "Trial division, once per query", verdict: "O(sqrt x) per query, 10^8 total — too slow")

#code(lang: "js", caption: "factoriseTrial")[
```js
const factoriseTrial = (x) => {
  const out = [];
  let v = x;
  for (let d = 2; d * d <= v; d++)
    if (v % d === 0) {
      let c = 0;
      while (v % d === 0) { v /= d; c++; }   // exact: d divides v, so no fraction
      out.push([d, c]);
    }
  if (v > 1) out.push([v, 1]);
  return out;
};
```
]

#complexity(time: [$O(sqrt(x))$ per query], space: $O(1)$, note: "Printed 2^3 3^2 5^1 for 360 and 999983^1 for the prime — the same as the SPF version. Use this when there is only ONE query.")

#approach(2, "Precompute the smallest prime factor of everything", verdict: "O(log x) per query, optimal for many queries")

Trial division per query is $O(sqrt(x))$, which is 1000 steps each — $10^8$ total. Too
slow. Instead precompute, for every number, its *smallest prime factor* (SPF). Then
factorising is: divide by the SPF, look up the SPF of what remains, repeat. Each division
at least halves the number, so at most $log_2 x$ steps.

#code(lang: "js", caption: "spfTable and factorise")[
```js
const spfTable = (n) => {
  const spf = new Int32Array(n + 1);
  for (let i = 0; i <= n; i++) spf[i] = i;
  for (let i = 2; i * i <= n; i++)
    if (spf[i] === i)
      for (let j = i * i; j <= n; j += i)
        if (spf[j] === j) spf[j] = i;
  return spf;
};

const factorise = (x, spf) => {
  const out = [];
  let v = x;
  while (v > 1) {
    const p = spf[v];
    let c = 0;
    while (v % p === 0) { v /= p; c++; }
    out.push([p, c]);
  }
  return out;
};
```
]

#complexity(time: [$O(n log log n)$ setup, $O(log x)$ per query], space: $O(n)$, note: "Int32Array, not a plain array: 4 MB flat instead of a tagged-value array many times that size.")

#subsection[Trace of `factorise(360)`]

#table(columns: (auto, auto, auto, auto),
  [*x*], [*spf[x]*], [*Divide out*], [*Recorded*],
  [360], [2], [$360 arrow.r 180 arrow.r 90 arrow.r 45$], [$2^3$],
  [45],  [3], [$45 arrow.r 15 arrow.r 5$], [$3^2$],
  [5],   [5], [$5 arrow.r 1$], [$5^1$],
)

Run output: `2^3 3^2 5^1`. For the prime 999983 the output is `999983^1`, and
`factorise(1, spf)` returns an empty list.

*Bonus — divisor sum from the factorisation.*

#code(lang: "js", caption: "sumOfDivisors")[
```js
const sumOfDivisors = (x, spf) => {
  let s = 1;
  for (const [p, c] of factorise(x, spf)) {
    let term = 1, pw = 1;
    for (let i = 0; i < c; i++) { pw *= p; term += pw; }
    s *= term;                               // (1 + p + ... + p^c) for each prime
  }
  return s;
};
```
]
Run: `sumOfDivisors(12, spf)` $arrow.r$ `28` (that is $1+2+3+4+6+12$);
`sumOfDivisors(1, spf)` $arrow.r$ `1`; `sumOfDivisors(97, spf)` $arrow.r$ `98`.
]
#ans[$360 = 2^3 dot 3^2 dot 5$; divisor sum of 12 is 28]

#trap[
`v /= d` is safe *only* because `d` divides `v` exactly at that moment — this is one of
the few places in JavaScript where `/` on integers is not a bug. Move that line anywhere
else in the loop and you get a fraction, `v % p` stops being 0, and the inner `while`
spins forever. When in doubt, `v = Math.floor(v / d)`.
]

#ex(21, tier: 2, asked: "Agoda · pattern")[
Count the total number of 1 bits across *every* number from 0 to $n$.

*Constraints:* $n <= 10^18$. *Target:* $O(63)$.
*Edge cases:* $n = 0$; $n = 10^9$ (the answer exceeds 32 bits).
]
#sol[

#approach(1, "Popcount every number from 0 to n", verdict: "O(n), impossible at 10^18")

#code(lang: "js", caption: "setBitsBrute")[
```js
const popcount32 = (x) => { let v = x >>> 0, c = 0; while (v) { v &= v - 1; c++; } return c; };

const setBitsBrute = (n) => {
  let t = 0;
  for (let i = 0; i <= n; i++) t += popcount32(i);
  return t;
};
```
]

#complexity(time: $O(n)$, space: $O(1)$, note: "Printed 0, 4, 12 and 17 for n = 0, 3, 7, 10 — the same as the fast version. At n = 10^18 it would run for centuries.")

#approach(2, "Count each bit column separately", verdict: "O(63), optimal")

Looping and calling popcount is $O(n)$ — impossible at $10^18$. Count *per bit position*
instead.

Look at bit $b$ across $0, 1, 2, 3, dots$ It follows a perfectly regular pattern: $2^b$
zeros, then $2^b$ ones, then $2^b$ zeros, and so on. The block length is $2^(b+1)$.

So among the first $n + 1$ numbers:
- complete blocks: $floor((n+1) \/ 2^(b+1))$, each contributing $2^b$ ones;
- a leftover of $(n+1) mod 2^(b+1)$ numbers, of which the ones beyond the first $2^b$ are
  set: $max(0, "rest" - 2^b)$.

Both $n$ and the *answer* pass $2^53$, and the shifts go up to bit 62, so this is `BigInt`
end to end.

#code(lang: "js", caption: "setBitsUpTo — count column by column")[
```js
const setBitsUpTo = (n) => {
  const N = BigInt(n) + 1n;
  let total = 0n;
  for (let b = 0n; b < 63n; b++) {
    const half = 1n << b, block = half * 2n;
    const full = N / block * half;
    const rest = N % block;
    total += full + (rest > half ? rest - half : 0n);   // BigInt has no Math.max
  }
  return total;
};
```
]

#complexity(time: $O(63)$, space: $O(1)$)

#subsection[Trace for $n = 10$, so 11 numbers $0 dots 10$]

#table(columns: (auto, auto, auto, auto, auto, auto),
  [*bit b*], [*block*], [*full blocks*], [*from full*], [*rest*], [*from rest*],
  [0], [2],  [5], [5], [1], [$max(0, 1-1) = 0$],
  [1], [4],  [2], [4], [3], [$max(0, 3-2) = 1$],
  [2], [8],  [1], [4], [3], [$max(0, 3-4) = 0$],
  [3], [16], [0], [0], [11],[$max(0, 11-8) = 3$],
)
Total $= 5 + 0 + 4 + 1 + 4 + 0 + 0 + 3 = 17$.

A brute-force loop over $0 dots 10$ was run alongside and also printed `17`, and the two
versions were compared for every $n$ from 0 to 2000 — the run printed `PASS`.
Other runs: $n = 0 arrow.r$ `0n`; $n = 3 arrow.r$ `4n`; $n = 7 arrow.r$ `12n`;
$n = 10^9 arrow.r$ `14846928141n`; $n = 10^18 arrow.r$ `29761222783429247000n`.
]
#ans[17 for $n = 10$; 14846928141 for $n = 10^9$]

#trap[
`Math.max` does not accept `BigInt` — `Math.max(0n, 1n)` throws
`TypeError: Cannot convert a BigInt value to a number`. Nor can you mix the two in
arithmetic: `1n + 1` throws as well. Inside a `BigInt` routine every literal needs its
`n`, and a maximum is written as a ternary. That is why the line above reads
`rest > half ? rest - half : 0n`.
]

#ex(22, tier: 2, asked: "DBS · pattern")[
Add up the XOR of every subset of an array (including the empty subset, whose XOR is 0).

*Constraints:* $n <= 20$ for a brute-force check, $n <= 10^5$ for the real answer.
*Target:* $O(n)$. *Edge cases:* empty array; a single element.
]
#sol[

#approach(1, "Walk all 2^n subsets", verdict: "O(2^n · n), dies past n = 25")

#code(lang: "js", caption: "subsetXorBrute")[
```js
const subsetXorBrute = (a) => {
  const n = a.length;
  let s = 0n;
  for (let m = 0; m < (1 << n); m++) {
    let x = 0;
    for (let i = 0; i < n; i++) if ((m >> i) & 1) x ^= a[i];
    s += BigInt(x);
  }
  return s;
};
```
]

#complexity(time: $O(2^n dot n)$, space: $O(1)$, note: "Printed 6n, 5n, 0n and 56n on the four tests — exactly what the formula gives. That agreement is how I checked the formula.")

#approach(2, "Count per bit position", verdict: "O(n), optimal")

Count *per bit position* again, and one fact does all the work.

Fix a bit $b$. If *no* element has bit $b$ set, no subset XOR has it either — contributes
0. If *at least one* element has it, then exactly *half* of all $2^n$ subsets have an odd
number of such elements, so exactly $2^(n-1)$ subsets have bit $b$ set in their XOR.

*Why exactly half:* pick one element $e$ that has bit $b$. Pair every subset $S$ with
$S$-with-$e$-toggled. The two partners differ in bit $b$ of their XOR, so exactly one of
each pair has it on. The pairing covers all $2^n$ subsets.

So the answer is $("OR of every element") times 2^(n-1)$.

#code(lang: "js", caption: "subsetXorSum — one line after the insight")[
```js
const subsetXorSum = (a) => {
  const n = a.length;
  if (n === 0) return 0n;
  let orAll = 0;
  for (const x of a) orAll |= x;
  return BigInt(orAll) * (1n << BigInt(n - 1));   // each bit is 1 in half the subsets
};
```
]

#complexity(time: $O(n)$, space: $O(1)$, note: "The answer is astronomically large, so it is a BigInt by necessity, not by taste.")

#subsection[Check on ${1, 3}$]

#table(columns: (auto, auto),
  [*Subset*], [*XOR*],
  [`{}`],    [0],
  [`{1}`],   [1],
  [`{3}`],   [3],
  [`{1,3}`], [2],
)
Total $= 6$. Formula: OR $= 3$, $2^(2-1) = 2$, so $3 times 2 = 6$. Match.

Runs: ${1,3} arrow.r$ `6n`; ${5} arrow.r$ `5n`; empty $arrow.r$ `0n`.
A full brute force over all 16 subsets of ${1,3,5,7}$ printed `56n`, and the formula
printed `56n` too. For the 100 values $1 dots 100$ the formula printed
`80495813114492566995040653541376n` — a 32-digit number, which is the whole reason this
function returns a `BigInt`.
]
#ans[6; and 56 for ${1,3,5,7}$]

#trap[
`1 << (n - 1)` on plain numbers is the trap this problem is built out of. At $n = 32$ it
gives 1, at $n = 33$ it gives 2, and at $n = 100$ it gives 8 — all with no error. The
moment an answer is $2^(n-1)$ for anything but a toy $n$, it is a `BigInt`.
]

#ex(23, tier: 2, asked: "SCB · pattern")[
How many bit flips turn $a$ into $b$?

*Constraints:* 32-bit unsigned. *Target:* $O("popcount")$.
*Edge cases:* $a = b$; every bit different.
]
#sol[
$a xor b$ has a 1 exactly where $a$ and $b$ disagree. Count those 1s.

#code(lang: "js", caption: "flipsNeeded")[
```js
const flipsNeeded = (a, b) => {
  let d = (a ^ b) >>> 0, c = 0;
  while (d) { d &= d - 1; c++; }
  return c;
};
```
]

$10$ is `01010`, $20$ is `10100`, so $10 xor 20$ is `11110` — four bits differ.

Run: `flipsNeeded(10,20)` $arrow.r$ `4`; `flipsNeeded(7,7)` $arrow.r$ `0`;
`flipsNeeded(0, 4294967295)` $arrow.r$ `32`.
]
#ans[4, 0, 32]

#trap[
The `>>> 0` is what makes the third test work. `0 ^ 4294967295` is $-1$ as a signed 32-bit
value, and `while (d)` on $-1$ with `d &= d - 1` still terminates — but any code that
later compares `d` against a positive bound, or prints it, sees $-1$. Convert once, at
the point of the XOR.
]

#ex(24, tier: 2, asked: "Razer · pattern")[
Produce the $n$-bit *Gray code*: a list of all $2^n$ numbers where each number differs
from the previous one in exactly one bit, starting at 0.

*Constraints:* $n <= 20$. *Target:* $O(2^n)$.
*Edge cases:* $n = 0$ (one entry, 0); $n = 1$.
]
#sol[

#approach(1, "Build it by reflecting the previous list", verdict: "O(2^n) — correct, and it explains WHY the code works")

Take the $(n-1)$-bit list, write it out, then write it again *backwards* with a 1 added in
front. Neighbours inside each half already differ by one bit, and the two middle entries
are the same number with only the new top bit different.

#code(lang: "js", caption: "grayReflect")[
```js
const grayReflect = (n) => {
  const g = [0];
  for (let b = 0; b < n; b++)
    for (let i = g.length - 1; i >= 0; i--) g.push(g[i] | (1 << b));
  return g;
};
```
]

#complexity(time: $O(2^n)$, space: $O(2^n)$, note: "Printed 0 1 3 2 6 7 5 4 for n = 3 — bit for bit the same list the one-liner produces. The two were compared for every n from 0 to 12 and the run printed PASS.")

#trap[
The inner loop reads `g.length` *once*, into `i`, and then only pushes. If you write
`for (let i = 0; i < g.length; i++) g.push(...)` the array grows while you walk it and the
loop never ends. Snapshotting the length before a loop that appends is a JavaScript reflex
worth building.
]

#approach(2, "The closed form", verdict: "O(1) per entry, optimal")

There is a closed form, and it is one line: the $i$-th Gray code is `i ^ (i >> 1)`.

*Why it works.* Going from $i$ to $i + 1$ flips a suffix of bits: a run of trailing 1s
becomes 0s and the bit above becomes 1. XORing with the shifted copy cancels that whole
run and leaves exactly one changed bit.

#code(lang: "js", caption: "grayCode")[
```js
const grayCode = (n) => Array.from({ length: 1 << n }, (_, i) => i ^ (i >> 1));
```
]

#table(columns: (auto, auto, auto, auto, auto),
  [*i*], [*i binary*], [*i >> 1*], [*XOR*], [*value*],
  [0], [`000`], [`000`], [`000`], [0],
  [1], [`001`], [`000`], [`001`], [1],
  [2], [`010`], [`001`], [`011`], [3],
  [3], [`011`], [`001`], [`010`], [2],
  [4], [`100`], [`010`], [`110`], [6],
  [5], [`101`], [`010`], [`111`], [7],
  [6], [`110`], [`011`], [`101`], [5],
  [7], [`111`], [`011`], [`100`], [4],
)

Run output: `0 1 3 2 6 7 5 4`. Check the neighbours: $0 arrow.r 1$ (bit 0),
$1 arrow.r 3$ (bit 1), $3 arrow.r 2$ (bit 0), $2 arrow.r 6$ (bit 2), and so on — always
exactly one bit. `grayCode(0)` prints `0` and `grayCode(1)` prints `0 1`.
]
#ans[`0 1 3 2 6 7 5 4`]

#ex(25, tier: 2, asked: "LINE MAN · pattern")[
Compute Euler's totient $phi(n)$: how many numbers in $1 dots n$ share no factor with $n$.

*Constraints:* $n <= 10^12$. *Target:* $O(sqrt(n))$.
*Edge cases:* $n = 1$ (answer 1); $n$ prime (answer $n - 1$).
]
#sol[

#approach(1, "Test gcd with every number up to n", verdict: "O(n log n), hopeless at 10^12")

#code(lang: "js", caption: "phiBrute")[
```js
const gcd = (a, b) => { while (b) { [a, b] = [b, a % b]; } return a; };

const phiBrute = (n) => {
  let c = 0;
  for (let i = 1; i <= n; i++) if (gcd(i, n) === 1) c++;
  return c;
};
```
]

#complexity(time: $O(n log n)$, space: $O(1)$, note: "Printed 1, 4, 96 and 96 for n = 1, 10, 97, 360 — the same as the formula. Useful only as a checker on small n, which is exactly how the formula below was verified for every n from 1 to 3000.")

#approach(2, "Use the product formula over distinct prime factors", verdict: "O(sqrt n), optimal")

$ phi(n) = n product_(p | n) (1 - 1/p) $
The product runs over *distinct* prime factors only, so once you divide a prime out
completely you never touch it again. Written as integer arithmetic, `r -= r / p` is
exactly $r times (1 - 1\/p)$ with no rounding error, because $p$ divides $r$ at that
moment — the one situation where JavaScript's `/` on integers gives an integer.

#code(lang: "js", caption: "eulerPhi")[
```js
const eulerPhi = (n) => {
  let r = n, v = n;
  for (let p = 2; p * p <= v; p++)
    if (v % p === 0) {
      while (v % p === 0) v /= p;
      r -= r / p;                            // exact: p divides r right now
    }
  if (v > 1) r -= r / v;                     // one large prime factor left over
  return r;
};
```
]

#complexity(time: $O(sqrt(n))$, space: $O(1)$, note: "The trailing if catches one large prime factor left above sqrt(n). At n = 10^12 the loop runs 10^6 times and every value stays inside the exact-integer range.")

#table(columns: (auto, auto, auto),
  [*n*], [*Factors*], [*$phi$*],
  [1],   [none],            [1],
  [10],  [$2 dot 5$],       [$10 times 1/2 times 4/5 = 4$],
  [97],  [prime],           [96],
  [360], [$2^3 dot 3^2 dot 5$], [$360 times 1/2 times 2/3 times 4/5 = 96$],
)

Run output: `1 4 96 96`. `eulerPhi(1000000000000)` prints `400000000000`, and
`Number.isInteger` on it prints `true` — no fraction ever crept in.
]
#ans[1, 4, 96, 96]

#note[
$phi$ is the exponent in Euler's theorem: $a^phi(n) equiv 1 (mod n)$ whenever
$gcd(a,n) = 1$. That is how you reduce a huge exponent modulo a *composite* number —
Fermat's $p - 1$ is just the special case where $n$ is prime.
]

#section[Tier 3 — insight, then the follow-up]

#tier-header(3)

#ex(26, tier: 3, asked: "Amazon · pattern")[
Every element of an array appears *three* times except one, which appears once. Find it.

*Constraints:* $n <= 10^6$, values fit in 32 bits. *Target:* $O(n)$ time, $O(1)$ space.
*Edge cases:* a one-element array; the lonely value is 0.

*Follow-up the interviewer asks next:* "now every other element appears $k$ times, for a
general $k$."
]
#sol[
XOR alone fails: $x xor x xor x = x$, so triples do not vanish.

#approach(1, "Count bits column by column, modulo 3", verdict: "O(32n), easy to explain, usually accepted")

Look at bit position $b$ across the whole array. Every value that appears three times
contributes 0 or 3 to that column. So the column total modulo 3 is exactly the lonely
value's bit.

#code(lang: "js", caption: "singleOfThreeCount")[
```js
const singleOfThreeCount = (a) => {
  let r = 0;
  for (let b = 0; b < 32; b++) {
    let c = 0;
    for (const x of a) c += (x >> b) & 1;
    if (c % 3) r |= (1 << b);
  }
  return r;
};
```
]
#complexity(time: $O(32 n)$, space: $O(1)$)

#approach(2, "Two variables acting as a base-3 counter", verdict: "O(n) with one pass, optimal")

Keep two masks. `ones` holds the bits that have been seen a number of times $equiv 1$
(mod 3); `twos` holds the bits seen $equiv 2$ (mod 3). A bit seen a third time must
disappear from both.

#code(lang: "js", caption: "singleOfThreeState — a 32-lane mod-3 counter")[
```js
const singleOfThreeState = (a) => {
  let ones = 0, twos = 0;
  for (const x of a) {
    ones = (ones ^ x) & ~twos;
    twos = (twos ^ x) & ~ones;               // uses the freshly updated ones
  }
  return ones;
};
```
]
#complexity(time: $O(n)$, space: $O(1)$, note: "Two integers do 32 independent mod-3 counters in parallel. The order of the two lines matters: twos uses the freshly updated ones.")

#subsection[Trace of one bit column, values $6, 1, 6, 6, 2, 1, 1$]

Follow bit 1 (value 2). The elements with bit 1 set are 6, 6, 6, and 2 — four of them.
$4 mod 3 = 1$, so the answer has bit 1 set. Follow bit 0: set in 1, 1, 1 — three of them,
$3 mod 3 = 0$, so the answer has bit 0 clear. Follow bit 2: set in 6, 6, 6 — again 0.
Answer `010` $= 2$.

Both versions were run on this array and both printed `2`.
`singleOfThreeCount([9])` and the state version both printed `9`;
`[0,0,0,13]` gave `13` from both; and `[-7,5,5,5]` gave `-7` from both.
]
#ans[2]

#subsection[Follow-up: every other element appears $k$ times]
The counting version generalises immediately — replace `% 3` with `% k`. Cost stays
$O(32 n)$ and the code is one parameter different; the run on `[4,4,4,4,4,11]` with
$k = 5$ printed `11`. The two-variable trick does *not* generalise cleanly: you would need
$ceil(log_2 k)$ masks and a hand-derived update rule per $k$. In an interview, say exactly
that: the mod-$k$ column count is the right general answer, and the two-mask version is a
$k = 3$ special case worth knowing because it is asked so often.

#trap[
`if (c % 3)` then `r |= (1 << b)` runs with `b = 31`, where `1 << 31` is
$-2147483648$ — so `r` comes back *negative*. In this problem that is exactly right: a
negative lonely value in two's complement has bit 31 set, and the run on `[-7,5,5,5]`
returns $-7$. Do not "fix" it. But remember that this is the one place in the chapter
where `1 << 31` is wanted, and everywhere else it is a bug.
]

#ex(27, tier: 3, asked: "Google · pattern")[
Given an array, find the largest value of $a_i xor a_j$ over all pairs.

*Constraints:* $n <= 10^5$, values under $2^31$. *Target:* $O(32 n)$.
*Edge cases:* a one-element array (answer 0); all values equal.

*Follow-up the interviewer asks next:* "now answer queries — for a given $x$, what is the
largest $x xor a_i$?"
]
#sol[

#approach(1, "Try every pair", verdict: "O(n^2), dies at n = 10^5")

#code(lang: "js", caption: "maxXorBrute")[
```js
const maxXorBrute = (a) => {
  let best = 0;
  for (let i = 0; i < a.length; i++)
    for (let j = i + 1; j < a.length; j++)
      best = Math.max(best, a[i] ^ a[j]);
  return best;
};
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "A binary trie: greedily take the opposite bit at every level", verdict: "O(32 n), optimal")

Here is the unlock. XOR is decided bit by bit from the *top*: a single 1 at bit 30 beats
every possible combination of the 30 bits below it. So to maximise $x xor y$, walk from
the highest bit down and, at each level, go to the child with the *opposite* bit if that
child exists. That is a plain greedy walk on a binary trie of the numbers.

The trie is stored as a flat array of `[child0, child1]` pairs rather than as linked
objects — one array, no allocation per node beyond the pair, and node ids are plain
integers.

#code(lang: "js", caption: "XorTrie — insert, and the greedy best-partner walk")[
```js
class XorTrie {
  constructor(bits = 31) { this.bits = bits; this.ch = [[-1, -1]]; }

  insert(x) {
    let cur = 0;
    for (let b = this.bits - 1; b >= 0; b--) {
      const d = (x >> b) & 1;
      if (this.ch[cur][d] === -1) {
        this.ch.push([-1, -1]);
        this.ch[cur][d] = this.ch.length - 1;
      }
      cur = this.ch[cur][d];
    }
  }

  best(x) {                        // largest x ^ (something already inserted)
    let cur = 0, res = 0;
    for (let b = this.bits - 1; b >= 0; b--) {
      const d = (x >> b) & 1;
      if (this.ch[cur][1 - d] !== -1) { res |= 1 << b; cur = this.ch[cur][1 - d]; }
      else cur = this.ch[cur][d];
    }
    return res;
  }
}

const maxXorTrie = (a, bits = 31) => {
  if (a.length < 2) return 0;
  const t = new XorTrie(bits);
  t.insert(a[0]);
  let best = 0;
  for (let i = 1; i < a.length; i++) {
    best = Math.max(best, t.best(a[i]));
    t.insert(a[i]);
  }
  return best;
};
```
]

#complexity(time: $O(32 n)$, space: $O(32 n)$, note: "Every insert and every query walks exactly 31 levels, and the walk is iterative — no recursion, so no stack depth to worry about.")

#subsection[Why the greedy walk is right]
At the top bit, any partner with the opposite bit gives $x xor y$ a 1 there, worth
$2^30$. Every partner *without* the opposite bit gives 0 there, and even if all 30 lower
bits come out as 1 the total is $2^30 - 1 < 2^30$. So the top bit dominates completely,
and the same argument repeats one level down inside the chosen subtree.

#subsection[Trace on ${3, 10, 5, 25, 2, 8}$, showing the winning pair]

The answer is $5 xor 25$. In 5 bits: $5 = 00101$, $25 = 11001$, XOR $= 11100 = 28$.
When 25 arrives, the walk from the top asks for a partner starting `0` (25 starts `1`),
finds the subtree holding 3, 10, 5, 2, keeps steering to opposite bits, and lands on 5.

Runs: brute and trie both printed `28`. A single element gave `0` from both; `[0,0]` gave
`0` from both. A randomised cross-check over 200 arrays of up to 12 random values printed
`PASS` — every trie answer equalled the brute-force answer.
]
#ans[28, from the pair $(5, 25)$]

#subsection[Follow-up: online queries]
Nothing changes. Build the trie once over the array, then every query $x$ is one
`t.best(x)` call in $O(32)$. If values may also be *removed*, store a counter at each
trie node and treat "count $= 0$" as "child does not exist"; insert increments along the
path and remove decrements.

#trap[
`bits = 31` covers values below $2^31$, and the deepest `res |= 1 << b` is `1 << 30` —
still positive. Push it to `bits = 32` and `1 << 31` makes `res` negative, so
`Math.max` compares the wrong way and the answer collapses. For values up to $10^18$ the
whole trie must move to `BigInt`: `(x >> BigInt(b)) & 1n` for the descent and
`res |= 1n << BigInt(b)` for the answer, with 63 levels instead of 31.
]

#ex(28, tier: 3, asked: "D. E. Shaw · pattern")[
Count the subarrays whose XOR equals exactly $k$.

*Constraints:* $n <= 10^5$, values under $2^20$. The count can reach $5 times 10^9$.
*Target:* $O(n)$. *Edge cases:* empty array; $k = 0$ with an array of zeros.

*Follow-up the interviewer asks next:* "now count subarrays whose XOR is *less than* $k$."
]
#sol[

#approach(1, "Every subarray, extending the XOR as you go", verdict: "O(n^2)")

#code(lang: "js", caption: "xorSubBrute")[
```js
const xorSubBrute = (a, k) => {
  let c = 0;
  for (let i = 0; i < a.length; i++) {
    let x = 0;
    for (let j = i; j < a.length; j++) { x ^= a[j]; if (x === k) c++; }
  }
  return c;
};
```
]

#complexity(time: $O(n^2)$, space: $O(1)$, note: "Printed 4, 2, 0 and 6 on the four tests — identical to the hash-map version. 10^10 operations at n = 10^5.")

#approach(2, "Prefix XOR plus a hash map", verdict: "O(n), optimal")

Define the prefix XOR $P_i = a_0 xor a_1 xor dots xor a_(i-1)$, with $P_0 = 0$. Then

$ "XOR of the subarray" a_i dots a_(j-1) = P_i xor P_j $

So "this subarray XORs to $k$" becomes $P_i xor P_j = k$, which rearranges to
$P_i = P_j xor k$. Sweep $j$ from left to right and ask a hash map how many earlier
prefixes equal $P_j xor k$.

#code(lang: "js", caption: "countXorSubarrays — prefix XOR plus a Map")[
```js
const countXorSubarrays = (a, k) => {
  const seen = new Map([[0, 1]]);            // the empty prefix, seeded
  let pref = 0, ans = 0;
  for (const x of a) {
    pref ^= x;
    ans += seen.get(pref ^ k) ?? 0;
    seen.set(pref, (seen.get(pref) ?? 0) + 1);
  }
  return ans;
};
```
]

#complexity(time: [$O(n)$ average], space: $O(n)$, note: "seen starts with [0, 1] for the empty prefix, which is what lets a subarray starting at index 0 be counted.")

#subsection[Trace on $4, 2, 2, 6, 4$ with $k = 6$]

#table(columns: (auto, auto, auto, auto, auto),
  [*x*], [*pref*], [*Looking for pref ^ k*], [*Found*], [*Running count*],
  [—], [0], [—], [seed `seen` with `[0, 1]`], [0],
  [4], [4], [$4 xor 6 = 2$], [0 times], [0],
  [2], [6], [$6 xor 6 = 0$], [1 time],  [1],
  [2], [4], [$4 xor 6 = 2$], [0 times], [1],
  [6], [2], [$2 xor 6 = 4$], [2 times], [3],
  [4], [6], [$6 xor 6 = 0$], [1 time],  [4],
)

Run output: `4`. Other runs: `[5,6,7,8,9]` with $k = 5$ gave `2`; an empty array gave `0`;
`[0,0,0]` with $k = 0$ gave `6` — which is right, since all
$3 + 2 + 1 = 6$ subarrays XOR to 0.
]
#ans[4 subarrays]

#subsection[Follow-up: XOR strictly less than $k$]
The hash map cannot answer a range question. Swap it for the binary trie of Example 27,
storing a *count* at every node. To count partners $P_i$ with $P_j xor P_i < k$, walk
down the trie comparing against $k$'s bits: whenever $k$ has a 1 at the current bit, the
entire subtree that produces a 0 there is *all* strictly smaller — add its stored count
and move into the other subtree. Cost becomes $O(32 n)$.

#trap[
Use a `Map`, not a plain object. An object stringifies every key, so `seen[4]` and
`seen["4"]` are the same slot — harmless here, but the moment a key can be negative or a
`BigInt` you get silent collisions, and `Object.keys` hands them back as strings. `Map`
keeps the number *as a number*, keeps insertion order, and is faster under heavy
insert-and-lookup traffic, which is exactly this loop.

The answer itself can reach about $n^2 \/ 2 = 5 times 10^9$. That still fits a double
exactly (it is far below $2^53 - 1$), so `ans` may stay a plain number here — but check
that bound before you assume it in another problem.
]

#ex(29, tier: 3, asked: "Microsoft · pattern")[
Given positive integers and a target $T <= 10^5$, decide whether *some subset* sums to
exactly $T$.

*Constraints:* $n <= 10^3$, $T <= 10^5$. *Target:* fast enough that $n T = 10^8$ passes.
*Edge cases:* $T = 0$ (the empty subset works); one element equal to $T$.

*Follow-up the interviewer asks next:* "now also print the subset."
]
#sol[
The classic DP is a boolean array `can[0..T]`, updated once per element:
`can[s] ||= can[s - x]`. That is $10^8$ boolean operations — borderline.

The unlock: those booleans are *bits*. C++ has a `bitset` type; JavaScript has something
better suited to it than you might expect — a `BigInt` *is* an arbitrary-width bit
vector, and `|`, `<<` and `&` on it are implemented as word-at-a-time machine loops. So
the entire inner DP collapses into one line, `can |= can << BigInt(x)`, and the engine
does 64 of the updates per machine word for you.

The `& mask` keeps the number from growing past $T$ bits; without it the `BigInt` doubles
in width on every element and the whole thing becomes quadratic.

#code(lang: "js", caption: "subsetReaches — the DP as a single shift-OR on a BigInt")[
```js
const subsetReaches = (a, target) => {
  const T = BigInt(target);
  const mask = (1n << (T + 1n)) - 1n;        // keep only sums 0..T
  let can = 1n;                              // bit 0 set: sum 0 is reachable
  for (const x of a) {
    if (x < 0 || x > target) continue;
    can = (can | (can << BigInt(x))) & mask;
  }
  return ((can >> T) & 1n) === 1n;
};
```
]

#complexity(time: $O(n T \/ 64)$, space: [$O(T \/ 8)$ bytes], note: "Measured: n = 1000, T = 10^5 finishes in about 6 ms. The mask is what keeps it there.")

#subsection[Trace on ${3, 4, 2}$ with the BigInt printed as reachable sums]

#table(columns: (auto, 1fr),
  [start],   [`{0}`],
  [after 3], [`{0, 3}`],
  [after 4], [`{0, 3, 4, 7}`],
  [after 2], [`{0, 2, 3, 4, 5, 6, 7, 9}`],
)
Each step is the old set plus a copy of the old set shifted *up* by $x$. Those four lines
are the literal run output.

Runs: `[3,34,4,12,5,2]` with target 9 $arrow.r$ `true` (that is $3+4+2$); target 30
$arrow.r$ `false`; an empty array with target 0 $arrow.r$ `true`; `[7]` with target 7
$arrow.r$ `true`. A randomised cross-check against a `Set`-based brute force over 300
small cases printed `PASS`.
]
#ans[9 reachable, 30 not reachable]

#subsection[Follow-up: print the subset]
A bit vector gives you the answer but not the path. Keep a second structure: for each
element index $i$, store the `BigInt` *after* processing element $i$. Then walk backwards
from $T$: if bit $s$ is already set in `after[i-1]` the element was not needed, so move to
$i - 1$; otherwise record element $i$ and move to $(i-1, s - a_i)$. That is $O(n T \/ 8)$
bytes of memory — acceptable at $n = 10^3$, $T = 10^5$ only if you are careful, so in an
interview offer the ordinary $O(n T)$ boolean DP over a `Uint8Array` with a parent array
as the print-the-subset version.

#trap[
`can << BigInt(x)` — the shift amount must be a `BigInt` too. `can << 3` throws
`TypeError: Cannot mix BigInt and other types`. And `1n << (T + 1n)` with $T = 10^5$ is a
100001-bit number: perfectly legal, about 12 KB, but build it *once* outside the loop.
Rebuilding the mask each iteration is the difference between 6 ms and several seconds.
]

#ex(30, tier: 3, asked: "Goldman Sachs · pattern")[
Solve $a x equiv 1 (mod m)$ for $x$, where $m$ is *not necessarily prime*. Report that no
solution exists when $gcd(a, m) != 1$.

*Constraints:* $a, m <= 10^18$. *Target:* $O(log m)$.
*Edge cases:* $gcd(a,m) > 1$; $a$ larger than $m$; $a$ negative.

*Follow-up the interviewer asks next:* "use it to solve a pair of simultaneous
congruences."
]
#sol[
Fermat is unavailable — it needs a prime modulus. Use the *extended* Euclid algorithm,
which returns not just $g = gcd(a, b)$ but also integers $x, y$ with

$ a x + b y = g $

When $g = 1$ this reads $a x + m y = 1$, so $a x equiv 1 (mod m)$, and $x$ is the
inverse. Reduce $x$ into $[0, m)$ at the end because it may come back negative.

With $m$ up to $10^18$ everything is `BigInt`. Two `BigInt` behaviours make this work
without any extra code: `/` truncates toward zero (integer division), and `%` keeps the
sign of the left operand — both exactly as C and C++ do.

#code(lang: "js", caption: "extGcd and invAny")[
```js
const extGcd = (a, b) => {
  if (b === 0n) return [a, 1n, 0n];
  const [g, x1, y1] = extGcd(b, a % b);      // destructuring instead of out-params
  return [g, y1, x1 - (a / b) * y1];
};

const invAny = (a, m) => {                   // -1n when no inverse exists
  const M = BigInt(m);
  const A = ((BigInt(a) % M) + M) % M;       // normalise a negative a
  const [g, x] = extGcd(A, M);
  if (g !== 1n) return -1n;
  return ((x % M) + M) % M;
};
```
]

#complexity(time: $O(log m)$, space: [$O(log m)$ recursion], note: "About 87 levels at m = 10^18, far under JavaScript's ~10^4 stack limit. Same step count as plain Euclid; only the bookkeeping is extra.")

#subsection[Trace of `extGcd(3n, 10n)`]

Going down: $(3,10) arrow.r (10,3) arrow.r (3,1) arrow.r (1,0)$.

#table(columns: (auto, auto, auto, 1fr),
  [*Level*], [*a, b*], [*returns (g, x, y)*], [*Check $a x + b y$*],
  [4], [1, 0],  [(1, 1, 0)],   [$1(1) + 0(0) = 1$],
  [3], [3, 1],  [(1, 0, 1)],   [$3(0) + 1(1) = 1$],
  [2], [10, 3], [(1, 1, $-3$)],[$10(1) + 3(-3) = 1$],
  [1], [3, 10], [(1, $-3$, 1)],[$3(-3) + 10(1) = 1$],
)
Those four rows are the run output, level by level.
So $x = -3$, and $-3 mod 10 = 7$.

Runs: `invAny(3,10)` $arrow.r$ `7n`, and `3n * 7n % 10n` printed `1n`.
`invAny(4,10)` $arrow.r$ `-1n` (since $gcd(4,10) = 2$). `invAny(-7,10)` $arrow.r$ `7n`,
so the normalisation handles a negative $a$. `invAny(3, 1000000007)` $arrow.r$
`333333336n`, the same value Fermat gave in Example 19. At the top of the range,
`invAny(123456789123456789n, 1000000000000000003n)` $arrow.r$ `244581051350687566n`, and
multiplying the two back together modulo $m$ printed `1n`.
]
#ans[$3^(-1) equiv 7 (mod 10)$; no inverse of 4 modulo 10]

#subsection[Follow-up: two simultaneous congruences]
To solve $x equiv r_1 (mod m_1)$ and $x equiv r_2 (mod m_2)$ with $gcd(m_1, m_2) = 1$:
write $x = r_1 + m_1 t$, substitute into the second congruence to get
$m_1 t equiv r_2 - r_1 (mod m_2)$, and multiply both sides by
`invAny(m1, m2)`. That gives $t$, hence $x$ modulo $m_1 m_2$. This is the Chinese
Remainder Theorem, and `invAny` is the only new ingredient it needs.

#trap[
`((a % m) + m) % m` is not optional. `BigInt` `%` keeps the sign of the left operand, so
`-7n % 10n` is `-3n`, not `7n` — the same rule C++ uses and the same bug it causes. Every
subtraction and every input normalisation under a modulus in this chapter carries that
`+ m`.

The other half of the trap is mixing types. `invAny(3, 10)` takes plain numbers and
converts them; `invAny(3n, 10)` also works; but writing `x % m` where one side is a number
and the other a `BigInt` throws immediately. Convert at the boundary, then stay in one
world.
]

#ex(31, tier: 3, asked: "Adobe · pattern")[
Count the integers in $[1, N]$ whose digit sum is divisible by $k$.

*Constraints:* $N <= 10^18$, $k <= 100$. *Target:* $O(d times 9d times 2 times 10)$ where
$d$ is the digit count.
*Edge cases:* $N$ with a leading digit larger than the rest; $k = 1$ (every number
qualifies).

*Follow-up the interviewer asks next:* "count them for every $k$ from 1 to 100."
]
#sol[

#approach(1, "Loop over every number and add its digits", verdict: "O(N · d), fine to N = 10^7, impossible at 10^18")

#code(lang: "js", caption: "digitSumBrute")[
```js
const digitSumBrute = (N, k) => {
  let c = 0;
  for (let i = 1; i <= N; i++) {
    let s = 0, t = i;
    while (t) { s += t % 10; t = Math.floor(t / 10); }
    if (s % k === 0) c++;
  }
  return c;
};
```
]

#complexity(time: $O(N d)$, space: $O(1)$, note: "Printed 6, 9 and 19 for (20,3), (9,1) and (100,5) — the same as the DP. It was also run against the DP for every N from 1 to 600 and every k from 1 to 12; the run printed PASS.")

#approach(2, "Digit DP", verdict: "O(d · 9d · 2 · 10), optimal")

Looping to $10^18$ is impossible. *Digit DP* builds the number one digit at a time,
carrying only what matters: the position, the digit sum so far (capped at $9d$), and
whether we are still "tight" against $N$'s prefix.

"Tight" means every digit chosen so far equalled $N$'s digit, so the next digit is capped
at $N$'s digit. Once you choose anything smaller, you are free and the cap becomes 9.

$N$ can be $10^18$, so it arrives as a `BigInt` or a string — never as a number literal.
`String(N)` handles all three, and from then on the DP works on characters, so precision
is not a question.

#code(lang: "js", caption: "countDigitSum — digit DP")[
```js
const countDigitSum = (N, k) => {
  const s = String(N), d = s.length;
  const memo = new Map();                    // fresh per call -- see the trap

  const dig = (pos, sum, tight) => {
    if (pos === d) return sum % k === 0 ? 1 : 0;
    const key = (pos * 200 + sum) * 2 + tight;
    if (memo.has(key)) return memo.get(key);
    const hi = tight ? +s[pos] : 9;
    let tot = 0;
    for (let x = 0; x <= hi; x++)
      tot += dig(pos + 1, sum + x, tight && x === hi ? 1 : 0);
    memo.set(key, tot);
    return tot;
  };

  return dig(0, 0, 1) - 1;                   // subtract the number 0
};
```
]

#complexity(time: $O(d times 9d times 2 times 10)$, space: $O(d times 9d times 2)$, note: "For d = 19 that is about 65 thousand states, each with a 10-way loop. Recursion is 19 deep, nowhere near JavaScript's limit.")

#subsection[Trace for $N = 20$, $k = 3$]

`s = "20"`. Position 0 is tight, so the first digit may be 0, 1 or 2.

#table(columns: (auto, auto, 1fr),
  [*First digit*], [*Still tight?*], [*Second digit choices and which qualify*],
  [0], [no],  [0..9; sums 0..9; divisible by 3: 0, 3, 6, 9 $arrow.r$ 4 numbers],
  [1], [no],  [0..9; sums 1..10; divisible by 3: 2, 5, 8 $arrow.r$ 3 numbers (12, 15, 18)],
  [2], [yes], [0 only (N's last digit); sum 2, not divisible $arrow.r$ 0 numbers],
)
Total 7, minus 1 for the number 0 itself, gives 6: they are 3, 6, 9, 12, 15, 18.

Run output: `6 9 19 142857049` for
$(N,k) = (20,3), (9,1), (100,5), (10^9, 7)$. A brute-force loop up to 100 with $k = 5$
was run alongside and also printed `19`.
]
#ans[6 for $N = 20, k = 3$]

#subsection[Follow-up: every $k$ from 1 to 100]
Do not rerun the DP 100 times. Run it *once* with the state `(pos, sum, tight)` and no
$k$ at all, producing `cnt[s]` = how many numbers in $[1,N]$ have digit sum exactly $s$,
for $s$ up to $9 times 19 = 171$. Then each $k$ is one $O(171)$ sum over the multiples of
$k$. One DP, 100 cheap answers.

#trap[
`const memo = new Map()` must be created *inside* `countDigitSum`, on every call, because
the cached values belong to one particular `N` and `k`. Hoisting it to module scope "for
speed" gives the previous query's answer — the sort of bug that passes the sample and
fails everything else. The run proves the version above is clean: back-to-back calls
`countDigitSum(20, 3)` and `countDigitSum(20, 7)` print `6` and `2`, not `6` and `6`.

A second, arithmetic trap: the *count* can overflow the exact-integer range. At
$N = 10^18$ with $k = 1$ every number qualifies, so the true answer is $10^18$ — well past
$2^53 - 1$, and the returned number is only approximately right. If the constraints allow
a count above $9 times 10^15$, `tot` must accumulate in `BigInt`.
]

#section[Dry run — one problem, every single step]

We trace `powMod(3, 13, 100)` completely. Every variable, after every turn.

*Why 13?* Because $13 = 8 + 4 + 1$, so
$3^13 = 3^8 times 3^4 times 3^1$. In binary $13 = 1101$ — read right to left, the bits
that are 1 are positions 0, 2 and 3, which are the powers $3^1$, $3^4$ and $3^8$.

*Setup.* `r = 1n % 100n = 1n`, `b = 3n % 100n = 3n`, `e = 13n`.

#table(columns: (auto, auto, auto, auto, 1fr, auto),
  [*Turn*], [*e*], [*e in binary*], [*e & 1n*], [*r update*], [*b update*],
  [1], [13], [`1101`], [1], [$r = 1 times 3 mod 100 = 3$],  [$b = 3^2 = 9$],
  [2], [6],  [`110`],  [0], [r stays 3],                    [$b = 9^2 = 81$],
  [3], [3],  [`11`],   [1], [$r = 3 times 81 = 243 mod 100 = 43$], [$b = 81^2 = 6561 mod 100 = 61$],
  [4], [1],  [`1`],    [1], [$r = 43 times 61 = 2623 mod 100 = 23$], [$b = 61^2 = 3721 mod 100 = 21$],
  [5], [0],  [`0`],    [—], [loop ends],                    [—],
)

Answer 23. The run prints exactly that.

*Check it by hand.* $3^13 = 1594323$. And $1594323 mod 100 = 23$. Match.

#subsection[The same numbers, read the other way]

Look at which `b` values got multiplied into `r`:

#table(columns: (auto, auto, auto, 1fr),
  [*Turn*], [*b at that moment*], [*Which power of 3?*], [*Multiplied in?*],
  [1], [3],  [$3^1$], [yes — bit 0 of 13 is 1],
  [2], [9],  [$3^2$], [no — bit 1 of 13 is 0],
  [3], [81], [$3^4$], [yes — bit 2 of 13 is 1],
  [4], [61], [$3^8 mod 100$], [yes — bit 3 of 13 is 1],
)

So the algorithm literally computes $3^1 times 3^4 times 3^8 = 3^13$, one binary digit at
a time. That is the whole idea, and it is why the loop runs $log_2 b$ times instead of
$b$ times.

#subsection[Trace of the edge cases]

#table(columns: (auto, 1fr, auto),
  [*Call*], [*What happens*], [*Result*],
  [`powMod(3, 0, 7)`],   [`e` is 0n, the loop body never runs, `r` is still `1n % 7n`], [1],
  [`powMod(5, 3, 1)`],   [`r = 1n % 1n = 0n`, and 0 times anything stays 0], [0],
  [`powMod(2, 62, 1e9+7)`], [62 turns' worth of squaring, largest intermediate about $(10^9)^2 approx 10^18$ — exact only because it is a `BigInt`], [145586002],
  [`powMod(-2, 3, 1e9+7)`], [`b` starts at `-2n`, the guard adds the modulus, so it is $(10^9 + 5)^3$], [999999999],
)

All four were run and printed exactly these values.

#note[
Watch the largest intermediate value. `b * b` with `b` just under $10^9 + 7$ is about
$10^18$. In C++ that fits a 64-bit integer with room to spare; in JavaScript a *number*
would have rounded it away eight digits earlier. This is the single reason every modular
multiplication in this chapter is `BigInt`, and it is also the reason `BigInt` costs you
nothing to reach for: the alternative is not "slower but correct", it is "faster and
wrong".
]

#section[Practice]

#practice(tier: 1, time: "12 min")[
+ Given a number, return the index of its only set bit, or $-1$ if it does not have
  exactly one. Test with 1, 1024, 12, 0 and $2^40$.
+ Compute $0 xor 1 xor 2 xor dots xor n$ in $O(1)$. Test with $n = 10$ against a loop.
+ Decide whether two integers have opposite signs, using no comparison operator on the
  values themselves.
+ Add two integers without using `+`, `-`, `*` or `/`. It must work on negatives.
+ Count the decimal digits of a possibly negative integer, including one past $2^53$.
]

#key[
*1.* Exactly one bit means `x > 0n && (x & (x - 1n)) === 0n`. The index is then found by
shifting the surviving bit down. $2^40$ is in the test set, so this cannot be a
32-bit function.
#code(lang: "js", caption: "onlyBitIndex")[
```js
const onlyBitIndex = (x) => {
  const v = BigInt(x);
  if (v <= 0n || (v & (v - 1n)) !== 0n) return -1;
  let i = 0, w = v;
  while (w > 1n) { w >>= 1n; i++; }
  return i;
};
```
]
Run: $1 arrow.r$ `0`; $1024 arrow.r$ `10`; $12 arrow.r$ `-1`; $0 arrow.r$ `-1`;
$2^40 arrow.r$ `40`. #complexity(time: $O(log x)$, space: $O(1)$)

*2.* XOR of $0 dots n$ has period 4. Pair up $(4t, 4t+1, 4t+2, 4t+3)$: their XOR is
always 0, because $4t xor (4t+1) = 1$ and $(4t+2) xor (4t+3) = 1$, and $1 xor 1 = 0$.
So only the remainder matters — and in JavaScript the four cases are just an array
lookup.
#code(lang: "js", caption: "xorUpTo")[
```js
const xorUpTo = (n) => [n, 1, n + 1, 0][n % 4];
```
]
Run: $0,1,2,3 arrow.r$ `0 1 3 0`; $10 arrow.r$ `11`, which a brute-force loop confirmed;
$10^9 arrow.r$ `1000000000`. The formula was compared against a running XOR for every
$n$ from 0 to 5000 and the run printed `PASS`.

#trick[
To XOR a *range* $[l, r]$ use `xorUpTo(r) ^ xorUpTo(l - 1)` — the same prefix trick as
prefix sums, because XOR is its own inverse. Run: `xorUpTo(9) ^ xorUpTo(3)` prints `1`,
and a loop over $4 dots 9$ prints `1` too.
]

*3.* The sign lives in the top bit. XOR makes the top bit 1 exactly when the two signs
differ, and JavaScript's bitwise operators produce a *signed* 32-bit result — so a
negative result means exactly that.
#code(lang: "js", caption: "oppositeSigns")[
```js
const oppositeSigns = (a, b) => (a ^ b) < 0;
```
]
Run: $(3,-4) arrow.r$ `true`; $(-3,-4) arrow.r$ `false`; $(0,5) arrow.r$ `false`.

*4.* `a ^ b` is the sum with every carry ignored. `(a & b) << 1` is exactly the carries.
Keep folding the carries back in until there are none left.
#code(lang: "js", caption: "addNoPlus")[
```js
const addNoPlus = (a, b) => {
  let x = a, y = b;
  while (y !== 0) {
    const carry = (x & y) << 1;
    x = x ^ y;
    y = carry;
  }
  return x;
};
```
]
Run: $(13,29) arrow.r$ `42`; $(-7,3) arrow.r$ `-4`; $(0,0) arrow.r$ `0`;
$(-5,-6) arrow.r$ `-11`. Every pair $(i, j)$ with $i, j$ from $-50$ to $50$ was checked
against `i + j`; the run printed `PASS`.
#trap[
This is one of the rare places where JavaScript is *easier* than C++. Left-shifting a
negative signed integer is undefined behaviour in C++, so the C++ answer has to launder
everything through `unsigned int`. In JavaScript `<<` is *defined* to operate on a signed
32-bit two's-complement value, so the loop above is correct as written. The price is the
ceiling: this function is exact only for inputs inside the 32-bit signed range. Feed it
$2^40$ and it answers about the low 32 bits, silently.
]

*5.* Divide by 10 until nothing is left, and handle 0 as a special case.
#code(lang: "js", caption: "digitCount")[
```js
const digitCount = (n) => {
  if (n === 0) return 1;
  let v = Math.abs(n), c = 0;
  while (v > 0) { c++; v = Math.floor(v / 10); }
  return c;
};
```
]
Run: $0 arrow.r$ `1`; $7 arrow.r$ `1`; $-1205 arrow.r$ `4`.
#trick[
For anything past $2^53 - 1$ the arithmetic version cannot even receive the input
correctly. Count the characters instead:
#code(lang: "js", caption: "digitCountBig")[
```js
const digitCountBig = (n) => {
  const v = BigInt(n);
  return (v < 0n ? -v : v).toString().length;
};
```
]
Run: `digitCountBig(9223372036854775807n)` $arrow.r$ `19`; `digitCountBig(-1205)`
$arrow.r$ `4`; `digitCountBig(0)` $arrow.r$ `1`.
]
]

#practice(tier: 2, time: "15 min")[
6. Build Pascal's triangle and read $binom(n,r)$ off it, exactly, with no modulus, for
   $n <= 30$.
7. Decide whether an integer up to $10^18$ is a perfect square, without `Math.sqrt` and
   without any floating point.
8. Count the divisors of $n$ in $O(sqrt(n))$. Test with $10^12$.
9. Compute $(1 + 2 + dots + n) mod (10^9 + 7)$ for $n$ up to $10^12$, using the modular
   inverse of 2.
10. Compute the $n$-th Fibonacci number modulo $10^9 + 7$ for $n$ up to $10^18$.
]

#key[
*6.* $binom(i,j) = binom(i-1,j-1) + binom(i-1,j)$. No multiplication means no precision
risk for moderate $n$; $binom(30,15)$ is about $1.5 times 10^8$, which fits easily.
#code(lang: "js", caption: "pascalC")[
```js
const pascalC = (n, r) => {
  if (r < 0 || r > n) return 0;
  const t = Array.from({ length: n + 1 }, () => new Array(n + 1).fill(0));
  for (let i = 0; i <= n; i++) {
    t[i][0] = 1;
    for (let j = 1; j <= i; j++) t[i][j] = t[i-1][j-1] + t[i-1][j];
  }
  return t[n][r];
};
```
]
Run: $binom(5,2) arrow.r$ `10`; $binom(30,15) arrow.r$ `155117520`;
$binom(4,7) arrow.r$ `0`; $binom(0,0) arrow.r$ `1`.
#complexity(time: $O(n^2)$, space: $O(n^2)$, note: "Exact to n around 50 in doubles. Beyond that use BigInt cells, or the modular factorial method of Example 19.")
#trap[
*Building the 2D table is where this one goes wrong.* `Array.from({length: n+1}, () => new Array(n+1).fill(0))`
calls the factory once per row, so every row is its own array. Write it as
`new Array(n+1).fill(new Array(n+1).fill(0))` and all $n+1$ "rows" are the *same* array —
`t[0][0] = 1` sets `t[1][0]` too. The run demonstrates it: aliasing two rows and writing
to one prints `1` when reading the other. The same rule covers copying: `[...grid]` is a
shallow copy, and a real 2D copy is `grid.map(row => [...row])`.
]

*7.* Binary search on the root, in `BigInt`. There is no overflow guard to write: a
`BigInt` product is exact however large it gets, so `mid * mid` can simply be compared.
#code(lang: "js", caption: "isPerfectSquare")[
```js
const isPerfectSquare = (n) => {
  const N = BigInt(n);
  if (N < 0n) return false;
  let lo = 0n, hi = 3037000499n;             // floor(sqrt(2^63 - 1))
  while (lo <= hi) {
    const mid = (lo + hi) >> 1n;
    const sq = mid * mid;
    if (sq === N) return true;
    if (sq < N) lo = mid + 1n; else hi = mid - 1n;
  }
  return false;
};
```
]
Run: $0 arrow.r$ `true`; $1 arrow.r$ `true`; $144 arrow.r$ `true`; $145 arrow.r$ `false`;
$-4 arrow.r$ `false`; `999999999999999999n` $arrow.r$ `false`;
`999999998000000001n` $arrow.r$ `true` (it is $999999999^2$). Every $k^2$ and $k^2 + 1$
for $k$ up to 3000 was checked; the run printed `PASS`.
#trap[
`Math.round(Math.sqrt(n)) ** 2 === n` is the version everybody writes, and it is wrong in
*both* directions past $2^53$. The run shows a false positive:
`1000000000000000001` is not a square, but the double round trip says it is, because
$10^18 + 1$ is not even representable — it becomes $10^18$ on the way in. Never use
floating point for an exact integer question, and never type a literal above
$9 007 199 254 740 991$ without an `n` on the end.
]

*8.* Divisors come in pairs $(d, n/d)$. Walk $d$ up to $sqrt(n)$ and add 2 each time,
except when $d = n/d$.
#code(lang: "js", caption: "divisorCount")[
```js
const divisorCount = (n) => {
  if (n <= 0) return 0;
  let c = 0;
  for (let d = 1; d * d <= n; d++)
    if (n % d === 0) c += (d === n / d) ? 1 : 2;
  return c;
};
```
]
Run: $1 arrow.r$ `1`; $36 arrow.r$ `9`; $97 arrow.r$ `2`;
$10^12 arrow.r$ `169`. Check: $10^12 = 2^12 dot 5^12$, so
$(12+1)(12+1) = 169$. Match. Note `d === n / d` is a safe comparison only because `d`
divides `n` exactly at that point; everywhere else that expression would be a float
compare.

*9.* $1 + dots + n = n(n+1)\/2$. You may not divide under a modulus, so multiply by
$2^(-1)$. Reduce $n$ and $n+1$ *before* multiplying, and keep the whole chain in
`BigInt` — the product of two reduced values is about $10^18$.
#code(lang: "js", caption: "sumUpToMod")[
```js
const MOD = 1000000007;

const sumUpToMod = (n) => {
  const M = BigInt(MOD), N = BigInt(n);
  const inv2 = BigInt(powMod(2, MOD - 2, MOD));
  return Number(N % M * ((N + 1n) % M) % M * inv2 % M);
};
```
]
Run: $n = 10 arrow.r$ `55`, which matches $10 times 11 \/ 2$.
$n = 10^12 arrow.r$ `24496500`. $n = 0 arrow.r$ `0` and $n = 1 arrow.r$ `1`.

*10.* Fast doubling. From $F(k)$ and $F(k+1)$ you get the pair at $2k$ in two
multiplications:
$ F(2k) = F(k) dot (2 F(k+1) - F(k)), quad F(2k+1) = F(k)^2 + F(k+1)^2 $
So halving $n$ each step gives $O(log n)$. Returning a *pair* is natural in JavaScript —
an array, destructured at the call site.
#code(lang: "js", caption: "fib by fast doubling")[
```js
const M = 1000000007n;

const fibPair = (n) => {                     // returns [F(n), F(n+1)]
  if (n === 0n) return [0n, 1n];
  const [a, b] = fibPair(n >> 1n);
  const c = a * ((2n * b % M - a + M) % M) % M;
  const d = (a * a % M + b * b % M) % M;
  return (n & 1n) ? [d, (c + d) % M] : [c, d];
};

const fib = (n) => Number(fibPair(BigInt(n))[0]);
```
]
Run: $F(0) arrow.r$ `0`; $F(1) arrow.r$ `1`; $F(10) arrow.r$ `55`;
$F(90) arrow.r$ `210345902`; $F(10^9) arrow.r$ `21`. Every value from $F(0)$ to $F(500)$
was cross-checked against a plain `BigInt` iteration and the run printed `PASS`; the exact
$F(90) = 2880067194370816120$ reduces to `210345902`, which the fast version also printed.
Recursion is $log_2 10^18 approx 60$ deep — nowhere near a stack problem.
#trap[
`2n * b % M - a` can go negative. The `+ M` before the final `% M` is what keeps it in
range. Subtraction under a modulus *always* needs that `+ M`, in every language.

And `(n & 1n)` is a `BigInt`: `0n` is falsy and `1n` is truthy, so the ternary works — but
`n & 1` would throw, because you cannot mix a `BigInt` with a number.
]
]

#practice(tier: 3, time: "18 min")[
11. $n$ people stand in a circle and every *second* person is removed until one remains.
   Find the survivor's position (1-based) using only bit operations. Test $n = 41$.
12. Build a table of the set-bit count of every number from 0 to $n$ in $O(n)$ total,
   with no popcount call.
13. Explain in your own words why the sieve's inner loop may start at $i times i$ rather
   than $2 i$, and what breaks if $n < i times i$.
14. You must compute $binom(n,r) mod p$ where $p$ is a *small* prime, say 13, and $n$ is
   up to $10^18$. Fermat's method needs $n < p$. What do you do?
15. Someone writes `const mask = 1 << k;` and their program works for $k = 20$ but produces
   garbage for $k = 35$. Explain exactly what happens at $k = 31$, at $k = 32$ and at
   $k = 35$.
]

#key[
*11.* Write $n = 2^m + l$ where $2^m$ is the largest power of two not above $n$. The
survivor is $2 l + 1$. Reason: once $l$ people have been removed, exactly $2^m$ remain
and the count restarts at a known person; with a power-of-two crowd the person who starts
the round always survives.
#code(lang: "js", caption: "josephusStep2")[
```js
const josephusStep2 = (n) => {
  if (n <= 0) return -1;
  let high = 1;
  while (high * 2 <= n) high *= 2;
  return 2 * (n - high) + 1;
};
```
]
Run: $n = 1 arrow.r$ `1`; $n = 5 arrow.r$ `3`; $n = 8 arrow.r$ `1`; $n = 41 arrow.r$ `19`.
Check $n = 5$: remove 2, 4, 1, 5 — the survivor is 3. Match. An explicit circle
simulation was run for every $n$ from 1 to 200 and agreed every time: the run printed
`PASS`.
#trick[
In bits: the answer is $n$ with its highest bit moved to the *bottom*. $41$ is `101001`;
drop the leading 1 to get `01001` and append a 1 to get `010011` $= 19$. Note the loop
above uses `high *= 2` rather than `high <<= 1` — at $n$ near $2^31$ the shift would go
negative and the loop would never end, while `*= 2` stays exact up to $2^53$.
]

*12.* `dp[i] = dp[i >> 1] + (i & 1)`. Dropping the last bit gives a strictly smaller
number whose answer is already known, and the last bit adds 0 or 1.
#code(lang: "js", caption: "bitsTable")[
```js
const bitsTable = (n) => {
  const dp = new Int32Array(n + 1);          // zero-filled, one word per entry
  for (let i = 1; i <= n; i++) dp[i] = dp[i >> 1] + (i & 1);
  return dp;
};
```
]
Run for $n = 10$: `0 1 1 2 1 2 2 3 1 2 2`. Check $i = 7$: `111`, three bits — the table
says 3. #complexity(time: $O(n)$, space: $O(n)$)

*13.* When $i$ is prime and $j = i times c$ with $c < i$, the number $j$ has a prime
factor $c$ or smaller, so some earlier prime already marked it. Only from $i times i$
upward is $i$ possibly the *smallest* factor. If $n < i times i$, the inner loop simply
never runs — which is exactly right, since $i$ has no multiples inside the range other
than itself. That is also why the outer loop can stop at $sqrt(n)$ for *marking*, though
it must keep going to $n$ to *collect* the remaining primes.

*14.* Use *Lucas' theorem*. Write $n$ and $r$ in base $p$:
$n = n_k dots n_1 n_0$ and $r = r_k dots r_1 r_0$. Then
$ binom(n, r) equiv product_(i=0)^(k) binom(n_i, r_i) (mod p) $
Each small binomial has $n_i, r_i < p <= 13$, so a tiny Pascal table answers it, and if
any $r_i > n_i$ the whole product is 0. The number of digits is $log_p n$, about 17 for
$p = 13$ and $n = 10^18$, so each query is essentially free. In JavaScript, extract the
base-$p$ digits with `BigInt`: `n % BigInt(p)` then `n /= BigInt(p)`, because $n$ is past
$2^53$ and a number-based loop would corrupt the digits before it started.

*15.* `1` is converted to a signed 32-bit integer holding the value 1 in bit 0, and
JavaScript then masks the shift count to its bottom five bits.
- At $k = 31$ the shift moves that 1 into the *sign* bit, so `mask` is
  $-2147483648$. Every `x & mask` test still reads the right bit, but any comparison,
  print, or `Math.max` involving `mask` behaves backwards.
- At $k = 32$ the count masks to 0, so `1 << 32` computes `1 << 0` and gives *1*, not 0.
  The program silently tests bit 0.
- At $k = 35$ the count masks to 3, so `1 << 35` gives `8`. Again, no crash, no warning,
  just a wrong answer.

This is not undefined behaviour, as it is in C++ — it is *defined* to be wrong, which
means it is perfectly reproducible on every machine and every judge, and therefore
completely invisible until the test data reaches bit 31. The fix is one of two:
`2 ** k` for a plain number (exact to $k = 53$), or `1n << BigInt(k)` for a `BigInt`
(exact forever). The run prints `1 << 40 = 256`, `1 << 32 = 1`,
`2 ** 40 = 1099511627776`.
]

#revision[

*The bit table.*

#table(columns: (auto, 1fr, auto, 1fr),
  [`x >> k & 1`], [read bit k],           [`x & (x-1)`], [clear the lowest set bit],
  [`x | (1<<k)`], [set bit k],            [`x & -x`],    [keep only the lowest set bit],
  [`x & ~(1<<k)`],[clear bit k],          [`i ^ (i>>1)`],[the i-th Gray code],
  [`x ^ (1<<k)`], [flip bit k],           [`(a^b) < 0`], [a and b have opposite signs],
  [`x^x = 0`],    [pairs cancel],         [`x >>> 0`],   [read a 32-bit result as unsigned],
  [`x^0 = x`],    [zero is the identity], [`31 - Math.clz32(x)`], [index of the highest set bit],
)

*The number-theory table.*

#table(columns: (1fr, 1fr),
  [$gcd(a,b) = gcd(b, a mod b)$], [Euclid, $O(log min(a,b))$],
  [$"lcm" = a \/ gcd times b$], [divide first — never $a times b \/ gcd$],
  [trial division to $sqrt(n)$], [one primality test, $O(sqrt n)$],
  [sieve, inner loop from $i^2$], [all primes to $n$, $O(n log log n)$],
  [smallest-prime-factor sieve], [factorise any $x <= n$ in $O(log x)$],
  [$floor(n/5) + floor(n/25) + dots$], [trailing zeros of $n!$],
  [$a^(-1) equiv a^(p-2) (mod p)$], [inverse, prime modulus only],
  [extended Euclid], [inverse for any modulus with $gcd = 1$],
  [$phi(n) = n product (1 - 1\/p)$], [Euler totient, $O(sqrt n)$],
  [$binom(n,r)$ with factorial + inverse tables], [$O(n)$ setup, $O(1)$ per query],
)

*Pattern to technique.*

#table(columns: (1fr, 1fr, auto),
  [*What the problem says*], [*Reach for*], [*Cost*],
  [one value appears once, others twice], [XOR everything],           [$O(n)$],
  [two values appear once],               [XOR, then split on `all & -all`], [$O(n)$],
  [others appear three times],            [count bits mod 3],         [$O(32 n)$],
  [largest XOR of a pair],                [binary trie, greedy walk], [$O(32 n)$],
  [count subarrays with XOR = k],         [prefix XOR + `Map`],       [$O(n)$],
  [total set bits over a range],          [count column by column],   [$O(63)$],
  [huge exponent],                        [square and multiply, `BigInt`], [$O(log b)$],
  [division under a modulus],             [multiply by the inverse],  [$O(log p)$],
  [many factorisation queries],           [smallest-prime-factor sieve],[$O(log x)$ each],
  [count numbers up to $10^18$ with a digit property], [digit DP on `String(N)`], [$O(d dot "state")$],
  [subset sum with a small target],       [`BigInt` shift-OR],        [$O(n T \/ 64)$],
)

*The JavaScript facts this chapter is built on.*

#table(columns: (auto, 1fr),
  [bitwise is 32-bit],   [`&`, `|`, `^`, `<<`, `>>` convert to a *signed* 32-bit integer first. `1 << 31` is negative, `1 << 32` is 1, `1 << 40` is 256.],
  [`>>` vs `>>>`],       [`>>` copies the sign bit, so `-1 >> 1` is $-1$ and the loop hangs. `>>>` shifts in zeros. End an unsigned computation with `>>> 0`.],
  [numbers are doubles], [exact only to $2^53 - 1 approx 9 times 10^15$. A literal past it is already the wrong value.],
  [`BigInt` or nothing],  [any product under a modulus near $10^9$, any $2^k$ with $k > 30$, any count that can pass $9 times 10^15$.],
  [no mixing],           [`1n + 1` throws; `Math.max(0n, 1n)` throws. Convert at the boundary, then stay in one world.],
  [no built-ins],        [no popcount, no `ctz`, no 128-bit type, no `bitset`. A `BigInt` *is* the bitset; the Kernighan loop *is* the popcount.],
  [`arr.sort()`],        [lexicographic. Always `arr.sort((a, b) => a - b)`, and a comparator must return a *number*.],
  [`Map` over `{}`],     [object keys stringify; `Map` keeps the key's type and insertion order and is faster under heavy churn.],
  [typed arrays],        [`Uint8Array` / `Int32Array` for sieves and DP tables — flat memory, zero-filled, no tagged values.],
  [shallow copy],        [`[...grid]` shares every row. A 2D copy is `grid.map(row => [...row])`.],
)

#note[
This is the one chapter in the book that borrows *nothing* from the *JS Toolkit* appendix.
Bits and number theory need no heap, no DSU, no deque and no `lowerBound` — they need
`BigInt` and a clear head about 32-bit wraparound. Everywhere else in this book, start
with `const { MinHeap, DSU, Deque, lowerBound, upperBound } = require('./toolkit.js')`
rather than rewriting a structure; here, there is nothing to import.
]

*The six traps that cost marks.*

+ *`1 << k` for $k >= 31$.* The shift count is masked to 5 bits, so `1 << 32` is 1, not 0,
  and nothing warns you. Use `2 ** k` or `1n << BigInt(k)`.
+ *`a * b` before the modulus.* Doubles round past $2^53 - 1$. Convert to `BigInt` first.
+ *Subtraction under a modulus.* Always `(a - b + M) % M`.
+ *`r = 1n % m`, not `r = 1n`.* The modulus can be 1.
+ *`>>` where you meant `>>>`.* A right-shift loop on a negative number never terminates.
+ *`Math.sqrt` on a big integer.* Above $2^53$ it lies in both directions. Use `d * d <= n`
  while the values are small, and `BigInt` binary search once they are not.

*Two checks before you submit any bit or math solution.*
Run your code on 0, on 1, on the maximum allowed input, and on a negative if negatives are
allowed. Then ask: what is the *largest intermediate value* my code ever forms — and is it
under $2^53 - 1$, or does this function need to be `BigInt` from end to end?
]

]
