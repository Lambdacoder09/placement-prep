#import "../../shared/lib/style.typ": *

#chapter(num: 1, title: "Complexity Analysis & Thinking About Limits",
  tagline: "Count the steps before you write the code")[

#section[Pattern in one page]

In a coding round you get a problem, a time limit, and a line that says
$1 <= n <= 10^5$. That line is not decoration. It tells you which algorithm is allowed.
This chapter teaches you to read it.

#formulas(title: "The counting rules")[

*What we count.* Not seconds. We count how many basic steps the code does when the input
has size $n$. A basic step is one comparison, one addition, one array read, one array write.

*Rule 1 — a loop that runs $k$ times costs $k$ steps.*

*Rule 2 — loops side by side ADD.* $n + n = 2n$.

*Rule 3 — loops inside loops MULTIPLY.* $n times n = n^2$.

*Rule 4 — drop the constants.* $3n + 7$ becomes $O(n)$. A doubling of speed does not change
the shape of the curve.

*Rule 5 — keep only the fastest-growing term.* $n^2 + 100 n + 5000$ becomes $O(n^2)$.

*Rule 6 — a loop that halves (or doubles) costs $log_2 n$ steps.* Because $n$ can be halved
only about $log_2 n$ times before it reaches 1.

*Rule 7 — "how many steps in the WORST case".* Big-O is a promise about the worst input,
unless the problem says otherwise.

*The ladder of growth, slowest-growing first.*
$O(1) < O(log n) < O(sqrt(n)) < O(n) < O(n log n) < O(n^2) < O(n^3) < O(2^n) < O(n!)$
]

#subsection[How big each shape really gets]

This table is not theory. It is the output of a program that counted the steps.

#table(columns: 5,
  align: (left, right, right, right, right),
  [*$n$*], [*$O(n)$*], [*$O(n log_2 n)$*], [*$O(n^2)$*], [*$O(2^n)$*],
  [10], [10], [33], [100], [1,024],
  [20], [20], [86], [400], [1,048,576],
  [1,000], [1,000], [9,965], [1,000,000], [too big to print],
  [100,000], [100,000], [1,660,964], [10,000,000,000], [too big to print],
)

Look at the last row. For $n = 100{,}000$ the $O(n log n)$ column is about 1.6 million, and
the $O(n^2)$ column is 10 billion. They are not "both a bit slow". One finishes instantly.
The other never finishes.

#subsection[The machine budget]

A judge machine does roughly $10^8$ (a hundred million) simple operations per second.
Measured with Node on the machine this book was written on:

#code(lang: "js", caption: "How long 10^8 simple steps really takes")[
```js
for (const n of [1e6, 1e7, 1e8]) {
  const t0 = Date.now();
  let s = 0;
  for (let i = 0; i < n; i++) s += i % 7;
  const ms = Date.now() - t0;
  console.log(`n=${n}  sum=${s}  time=${ms} ms`);
}
```
]

Output:

#code(lang: "text", caption: "Measured output")[
```text
n=1000000  sum=2999997  time=4 ms
n=10000000  sum=29999994  time=22 ms
n=100000000  sum=299999995  time=146 ms
```
]

So $10^8$ of the simplest possible steps took about 0.15 second in Node. Real steps (`Map`
lookups, string work, array pushes) are 5 to 50 times heavier. That is why the safe working
number is:

#trick[
*Budget: about $10^8$ operations per second. Aim to stay under $10^8$ total.*
If your step count is above $10^9$, the solution will not pass. If it is below $10^7$, you
have room to spare and can pick the simpler code.
]

#subsection[The table you should memorise]

Read $n$ from the constraints. Look it up here. That row tells you what to build.

#table(columns: 3,
  align: (left, left, left),
  [*$n$ up to*], [*Target complexity*], [*What that usually means*],
  [$10 - 12$], [$O(n!)$], [try every ordering (permutations)],
  [$20 - 25$], [$O(2^n)$ or $O(2^(n slash 2))$], [try every subset; meet in the middle],
  [$100$], [$O(n^3)$], [three nested loops; Floyd--Warshall],
  [$1{,}000 - 5{,}000$], [$O(n^2)$], [two nested loops; simple DP over pairs],
  [$10^5$], [$O(n log n)$], [sort, binary search, heap, set/map],
  [$10^6$], [$O(n)$ or $O(n log n)$], [one pass, prefix sums, hashing, two pointers],
  [$10^9$], [$O(log n)$ or $O(sqrt(n))$], [maths, binary search on the answer],
  [$10^18$], [$O(1)$ or $O(log n)$], [a formula, fast power, digit DP],
)

#trap[
The most common wrong move in a coding round is to write the first idea that comes to mind,
run it on the 3 sample cases, see "Accepted" on the samples, submit, and get *Time Limit
Exceeded*. The samples are tiny. The hidden tests are at the limit. Do the arithmetic
*before* you type.
]

#subsection[Space costs too]

Memory limits are usually 256 MB. Every number in a plain JS array is a double, 8 bytes.
A typed array (`Int32Array`) stores 4 bytes per value and is worth knowing for the biggest
inputs.

#table(columns: 4,
  align: (left, right, right, right),
  [*$n$*], [*`new Int32Array(n)`*], [*plain array of $n$ numbers*], [*$n times n$ numbers*],
  [100,000], [0.4 MB], [0.8 MB], [76,294 MB],
  [1,000,000], [3.8 MB], [7.6 MB], [7,629,395 MB],
  [10,000,000], [38.1 MB], [76.3 MB], [huge],
)

A 1-D array of ten million numbers is fine. A 2-D array of $n times n$ for $n = 10^5$ is
impossible. When the problem says $n <= 10^5$ and you reach for a 2-D table, stop.

#subsection[The four-step routine, every single time]

#table(columns: 2,
  align: (left, left),
  [*Step*], [*What you do*],
  [1. Read the limit], [Find $n$, $q$ (number of queries), and the value range.],
  [2. Pick the target], [Use the table above. "$n = 10^5$, so I need $O(n log n)$."],
  [3. Then design], [Only now think about the algorithm. The target rules out most ideas for you.],
  [4. Check the numbers], [Can any sum or product pass $2^53 approx 9 times 10^15$? If yes, `BigInt`.],
)

#diagram(height: 3.4cm, caption: "Read the limit first. It chooses the family of algorithms for you.")[
  #dnode(0pt, 10pt, 3.2cm, 1.1cm, [Constraint line #linebreak() $n <= 10^5$])
  #darrow(3.3cm, 0.65cm, 4.5cm, 0.65cm)
  #dnode(4.6cm, 10pt, 3.2cm, 1.1cm, [Budget #linebreak() $10^8$ steps])
  #darrow(7.9cm, 0.65cm, 9.1cm, 0.65cm)
  #dnode(9.2cm, 10pt, 3.4cm, 1.1cm, [Target #linebreak() $O(n log n)$])
  #dnode(2.2cm, 2.1cm, 8.6cm, 0.9cm, [Allowed tools: sort · binary search · heap · hash map · prefix sums], fill: rgb("#f7f7f5"))
]

#subsection[The overflow check you must never skip]

JavaScript has one number type, and it is a double. Whole numbers are exact only up to
`Number.MAX_SAFE_INTEGER` $= 2^53 - 1 = 9{,}007{,}199{,}254{,}740{,}991$. Past that, the
arithmetic silently rounds. Anything that can go past it needs `BigInt`.

#code(lang: "js", caption: "Where the doubles start lying")[
```js
const sumFormula = (n) => (n * (n + 1)) / 2;

console.log('MAX_SAFE_INTEGER =', Number.MAX_SAFE_INTEGER);
console.log('n=100000 sum =', sumFormula(100000));

const a = 1234567891, b = 987654321, mod = 1000000007;
console.log('a*b as a Number  =', a * b);
console.log('a*b as a BigInt  =', (BigInt(a) * BigInt(b)).toString());
console.log('(a*b) % mod Number =', (a * b) % mod);
console.log('(a*b) % mod BigInt =', Number((BigInt(a) * BigInt(b)) % BigInt(mod)));
console.log('2**53 === 2**53 + 1 ?', 2 ** 53 === 2 ** 53 + 1);
```
]

Output:

#code(lang: "text", caption: "Measured output")[
```text
MAX_SAFE_INTEGER = 9007199254740991
n=100000 sum = 5000050000
a*b as a Number  = 1219326312114007000
a*b as a BigInt  = 1219326312114007011
(a*b) % mod Number = 578722919
(a*b) % mod BigInt = 578722890
2**53 === 2**53 + 1 ? true
```
]

The Number answer is not "a bit off". The last three digits of the product are gone, so the
remainder $578{,}722{,}919$ is simply the wrong answer. Sums of $10^5$ values of $10^4$
(that is $10^9$) are safe. A product of two values near $10^9$ is not.

#trap[
*Numbers are doubles.* They are exact only to $2^53 - 1$. The moment a *product* of two
values above about $9.4 times 10^7$ appears, or a sum passes $9 times 10^15$, switch to
`BigInt`: `(BigInt(a) * BigInt(b)) % BigInt(m)`. `BigInt` is about 10 times slower, so use it
only on the values that need it, and convert back with `Number(...)` at the end.
]

#subsection[The other JavaScript facts this chapter needs]

#trap[
*`arr.sort()` sorts LEXICOGRAPHICALLY, as text.* Tested in Node: `[10, 9, 1].sort()` returns
`[1, 10, 9]`, because the string `"10"` comes before the string `"9"`. Numbers *always* need
a comparator: `[10, 9, 1].sort((a, b) => a - b)` returns `[1, 9, 10]`. This chapter sorts in
five different examples. Every one of them passes a comparator, and so must you. A bare
`.sort()` is the single most common JavaScript bug in a coding round.
]

#trap[
*Bitwise operators are 32-bit.* JavaScript converts both sides of `&`, `|`, `^`, `<<`, `>>`
and `>>>` to a 32-bit signed integer first. Tested in Node: `2**40 | 0` prints `0`, and
`(2**40) >>> 1` also prints `0`. Above $2^31$ the bits are simply thrown away. For bit work
on values past 32 bits, use `BigInt` (`1n`, `&`, `>>` all work on `BigInt`). See Example 14.
]

#trap[
*JavaScript has no built-in heap and no ordered map.* There is no `PriorityQueue` and no
sorted-key dictionary. Use the tested `MinHeap`, `lowerBound` and `upperBound` from the
*JS Toolkit* appendix. Every chapter that needs them starts with one line:

#code(lang: "js", caption: "The one require line")[
```js
const { MinHeap, lowerBound, upperBound } = require('./toolkit.js');
```
]
`Map` keeps *insertion* order, not sorted order, so it is not a substitute. When you need
"the smallest key greater than x", keep a sorted array and binary-search it.
]

#note[
*Use `Map`, not a plain object, for counting.* A plain object turns every key into a string,
so the number `1` and the text `"1"` become the same key. Tested in Node: after
`o[1] = 'num'; o['1'] = 'str'`, `o[1]` is `'str'` and `Object.keys(o)` is `["1"]`. A `Map`
keeps both, and `mm.size` is `2`. A `Map` is also faster when you add and delete a lot —
measured in Example 16.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[What is the complexity of this loop, and how many times does the body run
for $n = 5$?

#code(lang: "js", caption: "One plain loop")[
```js
const oneLoop = (n) => { let c = 0; for (let i = 0; i < n; i++) c++; return c; };
```
]
#sol[
The loop starts at $i = 0$ and stops when $i = n$. So it runs for
$i = 0, 1, 2, ..., n-1$, which is $n$ values.
For $n = 5$: $i = 0, 1, 2, 3, 4$, so the body runs 5 times.
Rule 1: a loop that runs $n$ times is $O(n)$.
]
#ans[$O(n)$; the body runs 5 times]
]

#ex(2, tier: 0)[Two loops, one after the other. Complexity?

#code(lang: "js", caption: "Loops side by side")[
```js
const twoLoops = (n) => {
  let c = 0;
  for (let i = 0; i < n; i++) c++;
  for (let j = 0; j < n; j++) c++;
  return c;
};
```
]
#sol[
First loop: $n$ steps. Second loop: $n$ steps. They are side by side, so we *add*.
Total $= n + n = 2n$.
Rule 4 says drop the constant 2.
Measured for $n = 1024$: the counter ended at 2048, which is $2n$. And $2n$ is $O(n)$.
]
#ans[$O(n)$]
]

#ex(3, tier: 0)[Nested loops, both full length. Complexity?

#code(lang: "js", caption: "Loops inside loops")[
```js
const nested = (n) => {
  let c = 0;
  for (let i = 0; i < n; i++)
    for (let j = 0; j < n; j++) c++;
  return c;
};
```
]
#sol[
For *each* of the $n$ values of $i$, the inner loop runs $n$ times.
Rule 3 says nested loops multiply: $n times n = n^2$.
Measured counts: $n = 2$ gave 4, $n = 16$ gave 256, $n = 1024$ gave 1,048,576. Each one is
exactly $n^2$.
]
#ans[$O(n^2)$]
]

#ex(4, tier: 0)[The inner loop starts at $i + 1$, not at 0. Is it still $O(n^2)$?

#code(lang: "js", caption: "The triangle loop")[
```js
const countInner = (n) => {
  let steps = 0;
  for (let i = 0; i < n; i++)
    for (let j = i + 1; j < n; j++) steps++;
  return steps;
};
```
]
#sol[
Count the inner runs one row at a time.
- $i = 0$: $j$ goes from 1 to $n-1$, that is $n - 1$ steps.
- $i = 1$: $n - 2$ steps.
- $i = 2$: $n - 3$ steps.
- ... down to $i = n-1$: 0 steps.

Total $= (n-1) + (n-2) + ... + 1 + 0 = (n(n-1))/2$.

Measured output of the program above:

#code(lang: "text", caption: "Measured output")[
```text
n=0  steps=0  n(n-1)/2=0
n=1  steps=0  n(n-1)/2=0
n=2  steps=1  n(n-1)/2=1
n=4  steps=6  n(n-1)/2=6
n=8  steps=28  n(n-1)/2=28
n=100  steps=4950  n(n-1)/2=4950
n=1000  steps=499500  n(n-1)/2=499500
```
]

$(n(n-1))/2 = (n^2 - n)/2$. Drop the constant $1/2$ and the smaller term $n$. What is left
is $n^2$.
]
#ans[Yes, $O(n^2)$ — it does about half the work of the full square, and half of $n^2$ is
still $O(n^2)$]
]

#ex(5, tier: 0)[How many times does this loop run?

#code(lang: "js", caption: "Halving")[
```js
const halvings = (n) => {
  let steps = 0;
  while (n > 1) { n = Math.floor(n / 2); steps++; }   // JS division gives 7 / 2 = 3.5
  return steps;
};
```
]
#sol[
Each turn cuts $n$ in half. Starting at $n$, the values are
$n, n/2, n/4, n/8, ...$ until it reaches 1.
The number of halvings is $log_2 n$ rounded down.

Measured output:

#code(lang: "text", caption: "Measured output")[
```text
n=1  halvings=0
n=8  halvings=3
n=1000  halvings=9
n=100000  halvings=16
n=1000000000  halvings=29
```
]

Check one: $n = 8$ gives $8 arrow.r 4 arrow.r 2 arrow.r 1$, which is 3 halvings, and
$log_2 8 = 3$. Correct.
]
#ans[$O(log n)$ — only 29 steps even for a billion]
]

#trick[
Memorise these three: $log_2 10^3 approx 10$, $log_2 10^6 approx 20$, $log_2 10^9 approx 30$.
So "$log n$" is never more than about 30 in a coding round. Treat it as a small constant
when you estimate.
]

#ex(6, tier: 0)[An outer loop of $n$ and an inner loop that doubles. Complexity?

#code(lang: "js", caption: "n times log n")[
```js
const f4 = (n) => {
  let c = 0;
  for (let i = 0; i < n; i++)
    for (let j = 1; j < n; j *= 2) c++;
  return c;
};
```
]
#sol[
The inner loop multiplies $j$ by 2 each turn, so it runs $log_2 n$ times (Example 5, read
backwards).
The outer loop runs $n$ times.
Nested, so multiply: $n times log_2 n$.
Measured: $n = 16$ gave $c = 64 = 16 times 4$, and $log_2 16 = 4$. Correct.
$n = 1024$ gave $c = 10240 = 1024 times 10$, and $log_2 1024 = 10$. Correct.
]
#ans[$O(n log n)$]
]

#ex(7, tier: 0)[Which is faster for $n = 10^5$: a loop that adds $1$ to $n$, or the formula?

#code(lang: "js", caption: "O(n) versus O(1)")[
```js
const sumLoop = (n) => { let s = 0; for (let i = 1; i <= n; i++) s += i; return s; };

const sumFormula = (n) => (n * (n + 1)) / 2;
```
]
#sol[
`sumLoop` does $n$ additions, so $O(n)$.
`sumFormula` does one multiply, one add, one divide, no matter how big $n$ is, so $O(1)$.

Both were run and both printed the same answers:

#code(lang: "text", caption: "Measured output")[
```text
n=0 loop=0 formula=0
n=1 loop=1 formula=1
n=5 loop=15 formula=15
n=100000 loop=5000050000 formula=5000050000
```
]

Note $n = 0$ works in both: the loop body never runs, and the formula gives $0 times 1 / 2 = 0$.
]
#ans[The formula, $O(1)$ against $O(n)$]
]

#note[
Edge cases to always test on a counting problem: $n = 0$ (loop body never runs) and
$n = 1$ (loop body runs once, or zero times if the inner loop starts at $i+1$).
]

#section[Tier 1 — Read the code, name its cost]
#tier-header(1)

#ex(8, tier: 1, asked: "TCS NQT · pattern")[
*Problem.* Given an array of $n$ integers, report whether any value appears twice.
*Constraints.* $n <= 2 times 10^5$, every value fits in a safe JavaScript integer.
*Target.* $O(n log n)$ or better.
*Edge cases.* empty array; one element; two equal negatives.

#sol[
#approach(1, "Compare every pair", verdict: "O(n^2), too slow at 2·10^5")

#code(lang: "js", caption: "Brute force")[
```js
const hasDuplicateBrute = (a) => {
  for (let i = 0; i < a.length; i++)
    for (let j = i + 1; j < a.length; j++)
      if (a[i] === a[j]) return true;
  return false;
};
```
]
#complexity(time: "O(n^2)", space: "O(1)",
  note: "For n = 2·10^5 that is 2·10^10 pair checks. At 10^8 per second: over 3 minutes.")

#approach(2, "Sort, then look at neighbours", verdict: "O(n log n), passes")

If two equal values exist, sorting puts them next to each other. So we only need to compare
each element with the one before it.

#code(lang: "js", caption: "Sort first")[
```js
const hasDuplicateSort = (a) => {
  const b = [...a].sort((x, y) => x - y);   // the comparator is NOT optional
  for (let i = 1; i < b.length; i++)
    if (b[i] === b[i - 1]) return true;
  return false;
};
```
]
#complexity(time: "O(n log n)", space: "O(n) for the copy, or O(1) if you may sort in place",
  note: "2·10^5 · 18 ≈ 3.6·10^6 steps. Instant.")

#approach(3, "Remember what you have seen", verdict: "O(n) expected — optimal")

#code(lang: "js", caption: "Set")[
```js
const hasDuplicateSet = (a) => {
  const seen = new Set();
  for (const x of a) {
    if (seen.has(x)) return true;
    seen.add(x);
  }
  return false;
};
```
]
#complexity(time: "O(n) expected", space: "O(n)",
  note: "A Set lookup is O(1) expected, not guaranteed — say 'expected' out loud.")

All three were run in Node on the same tests:

#code(lang: "text", caption: "Measured output")[
```text
[] brute=false sort=false set=false
[7] brute=false sort=false set=false
[1,2,3,4] brute=false sort=false set=false
[1,2,3,2] brute=true sort=true set=true
[-5,-5] brute=true sort=true set=true
[-3,0,3,-3] brute=true sort=true set=true
[0,0] brute=true sort=true set=true
bare sort of [10,9,1]  = [1,10,9]
with comparator        = [1,9,10]
```
]

Look at the last two lines. They come from the same program. Without `(x, y) => x - y` the
array is sorted as *text*, so `10` lands before `9` and "equal values end up next to each
other" is no longer true.

Python does the same job with a `set`, and this is one of the chapter's signature problems,
so here it is:

#code(lang: "python", caption: "Python version of the optimal")[
```python
def has_duplicate(a):
    seen = set()
    for x in a:
        if x in seen:
            return True
        seen.add(x)
    return False
```
]
Run on the same inputs, Python prints `False False False True True True` for
`[]`, `[7]`, `[1,2,3,4]`, `[1,2,3,2]`, `[-5,-5]`, `[0,0]` — the same answers as the
JavaScript.

*The idea that unlocked it.* The brute force asks "is `a[i]` equal to anything else?" and
searches the whole array for the answer. Both faster versions replace that search: sorting
makes the answer a neighbour, hashing makes the answer a lookup. Whenever an inner loop is
only *searching*, you can usually delete it.
]
]

#ex(9, tier: 1, asked: "Infosys · pattern")[
*Problem.* Find the value that appears most often in an array. If there is a tie, any of the
winners is fine.
*Constraints.* $1 <= n <= 10^6$; values may be negative.
*Target.* $O(n)$ or $O(n log n)$.
*Edge cases.* one element; all elements equal; negative values.

#sol[
#approach(1, "Sort and count runs", verdict: "O(n log n), passes")

#code(lang: "js", caption: "Sort, then count each run")[
```js
const mostFrequentSort = (a) => {
  if (a.length === 0) return undefined;
  const b = [...a].sort((x, y) => x - y);
  let best = b[0], bestCount = 1, cur = b[0], count = 1;
  for (let i = 1; i < b.length; i++) {
    if (b[i] === cur) count++;
    else { cur = b[i]; count = 1; }
    if (count > bestCount) { bestCount = count; best = cur; }
  }
  return best;
};
```
]
#complexity(time: "O(n log n)", space: "O(n) for the copy")

#approach(2, "Count in one pass with a Map", verdict: "O(n) expected — optimal")

#code(lang: "js", caption: "Frequency Map")[
```js
const mostFrequentMap = (a) => {
  if (a.length === 0) return undefined;
  const freq = new Map();
  let best = a[0], bestCount = 0;
  for (const x of a) {
    const c = (freq.get(x) ?? 0) + 1;   // get() returns undefined, not 0
    freq.set(x, c);
    if (c > bestCount) { bestCount = c; best = x; }
  }
  return best;
};
```
]
#complexity(time: "O(n) expected", space: "O(k) where k is the number of distinct values")

Measured, both versions on the same inputs:

#code(lang: "text", caption: "Measured output")[
```text
[] sort=undefined map=undefined
[4] sort=4 map=4
[1,1,2] sort=1 map=1
[-2,-2,-2,5,5] sort=-2 map=-2
[0,0,1,1] sort=0 map=0
```
]

The last line is the tie case: both counts are 2, and both versions returned 0, because 0
reached count 2 first. A tie rule must be stated in the problem, or you must ask.

#trap[
`freq.get(x)` returns `undefined` for a key that is not there, and `undefined + 1` is `NaN`.
Always write `(freq.get(x) ?? 0) + 1`. Use a `Map` and not a plain object here, because the
values can be negative: an object would turn the number $-2$ into the string `"-2"`.
]

*The idea.* Sorting costs $O(n log n)$ only to bring equal values together. A `Map` brings
them together for free.
]
]

#ex(10, tier: 1, asked: "Wipro · pattern")[
*Problem.* Remove every odd number from an array, keeping the order of the even ones.
*Constraints.* $n <= 2 times 10^5$.
*Target.* $O(n)$.
*Edge cases.* empty array; array with only odd numbers (answer is empty).

#sol[
#approach(1, "splice() out each odd value", verdict: "O(n^2) — the hidden cost")

#code(lang: "js", caption: "Looks O(n). Is not.")[
```js
const removeOddSlow = (a) => {
  const v = [...a];
  for (let i = 0; i < v.length; ) {
    if (v[i] % 2 !== 0) v.splice(i, 1);
    else i++;
  }
  return v;
};
```
]

There is only *one* loop, so it looks like $O(n)$. But `splice` in the middle of an array has
to shift every element after that position one slot to the left. That shift is a hidden
inner loop of up to $n$ steps.

#approach(2, "Two pointers: read and write", verdict: "O(n) — optimal")

#code(lang: "js", caption: "Read pointer r, write pointer w")[
```js
const removeOddFast = (a) => {
  const v = [...a];
  let w = 0;
  for (let r = 0; r < v.length; r++)
    if (v[r] % 2 === 0) v[w++] = v[r];
  v.length = w;          // truncate in place; no new array
  return v;
};
```
]
#complexity(time: "O(n)", space: "O(1) extra")

Both versions were run on the numbers 1 to 20,000, with a counter on the element moves:

#code(lang: "text", caption: "Measured output")[
```text
same result? yes size 10000
splice version shifted  100000000 elements
two-pointer version wrote 10000 elements
empty -> 0
single odd -> 0
negatives [-4,-3,0] -> [-4,0]
splice time 41 ms   two-pointer time 1 ms
```
]

One hundred million moves against ten thousand. That is a factor of 10,000 on an input of
only 20,000 items, and it shows up as 41 ms against 1 ms.

#note[
`v.length = w` is the JavaScript way to shorten an array in place. `a.filter(x => x % 2 === 0)`
is also $O(n)$ and is the shortest correct answer — but write the two-pointer version at
least once, because the same read/write pair is the core of Chapter 3.
]

#trap[
`x % 2 !== 0` is the safe odd test. `x % 2 === 1` is *wrong* for negatives: in JavaScript
`-3 % 2` is `-1`, not `1`. Tested above on `[-4,-3,0]`, which correctly keeps `[-4, 0]`.
]

*The idea.* Any library call inside a loop may hide its own loop. `splice`, `unshift`,
`indexOf`, `includes`, and `slice` are the usual suspects. Ask "what does this call have to
touch?" before you count it as one step.
]
]

#trap[
`splice` inside a loop, `unshift` inside a loop, and `includes` / `indexOf` inside a loop
are the three most common accidental $O(n^2)$ bugs in placement tests. Each one *looks*
like a single line.
]

#ex(11, tier: 1, asked: "Capgemini · pattern")[
*Problem.* Build the list $n, n-1, ..., 2, 1$ in that order, by walking $i$ upwards from 1.
*Constraints.* $n <= 10^5$.
*Target.* $O(n)$.
*Edge cases.* $n = 0$ (empty list); $n = 1$.

#sol[
#approach(1, "out.unshift(i)", verdict: "O(n^2) — every existing item shifts right")

#code(lang: "js", caption: "One line, one loop, quadratic")[
```js
const buildUnshift = (n) => {
  const out = [];
  for (let i = 1; i <= n; i++) out.unshift(i);   // pushes everything right by one
  return out;
};
```
]

#approach(2, "push, walking downwards", verdict: "O(n) — optimal")

#code(lang: "js", caption: "push only ever touches the end")[
```js
const buildPush = (n) => {
  const out = [];
  for (let i = n; i >= 1; i--) out.push(i);
  return out;
};
```
]
#complexity(time: "O(n)", space: "O(n) for the output")

If the walk direction is fixed by the problem, `push` then `out.reverse()` is still $O(n)$:
one reverse costs $n/2$ swaps, not $n^2/2$ shifts.

Measured:

#code(lang: "text", caption: "Measured output")[
```text
n=0 unshift=[] push=[]
n=1 unshift=[1] push=[1]
n=5 unshift=[5,4,3,2,1] push=[5,4,3,2,1]
n=20000 same? true  unshift=23 ms  push=4 ms
n=100000 same? true  unshift=630 ms  push=2 ms
```
]

Five times the input, but 27 times the time. That ratio is the signature of $O(n^2)$:
$5^2 = 25$.
]
#ans[Use `push` (plus `reverse` if you must), never `unshift` inside a loop]
#note[
*JavaScript strings are the exception.* In C++ and Java, `s = s + 'a'` inside a loop is
$O(n^2)$ because it copies the whole string every turn. V8 does not: it builds a *rope*, a
small tree of pieces, and flattens it only when the string is actually read. Tested in Node:
`s += 'a'` one hundred thousand times finished in 5 ms. So `+=` on strings is safe in
JavaScript — but `unshift` on arrays is not, and that is the trap that survives the language
change.
]
]

#ex(12, tier: 1, asked: "Accenture · pattern")[
*Problem.* Search a sorted array of $n$ values. How many comparisons in the worst case?
*Constraints.* $n <= 10^6$.
*Target.* $O(log n)$.
*Edge cases.* empty array; value not present; array of length 1.

#sol[
#code(lang: "js", caption: "Binary search with a step counter")[
```js
const binarySearch = (a, target) => {
  let lo = 0, hi = a.length - 1;
  while (lo <= hi) {
    const mid = Math.floor((lo + hi) / 2);   // plain / gives 4.5, not 4
    if (a[mid] === target) return mid;
    if (a[mid] < target) lo = mid + 1;
    else hi = mid - 1;
  }
  return -1;
};
```
]

Run on an array of one million even numbers, counting loop turns:

#code(lang: "text", caption: "Measured output")[
```text
find 0 -> index 0 steps 19
find 1999998 -> index 999999 steps 20
find 7 (absent) -> index -1 steps 20
empty array -> index -1 steps 0
one element, found -> index 0 steps 1
```
]

Twenty steps for one million elements. A linear scan would need up to one million.
$log_2 10^6 approx 20$, which matches exactly.
]
#complexity(time: "O(log n)", space: "O(1)")
#trap[
*JavaScript division does not round.* `(0 + 9) / 2` is `4.5`, and `a[4.5]` is `undefined`,
so the search silently fails. You must round: `Math.floor((lo + hi) / 2)`.

`(lo + hi) >> 1` also rounds down and is faster to type — but `>>` is a *32-bit* operator.
Tested in Node: with `lo = 3000000000` and `hi = 3000000001`, `(lo + hi) >> 1` printed
`852516352`, while `Math.floor((lo + hi) / 2)` printed `3000000000`. Array indexes never get
that large, so `>> 1` is safe for searching an array; it is *not* safe when you binary-search
over a range of *answers* that can pass $2^31$. Use `Math.floor` there.
]
]

#ex(13, tier: 1, asked: "Cognizant · pattern")[
*Problem.* Name the complexity of each of these four functions.
*Constraints.* $n <= 10^6$.

#code(lang: "js", caption: "Four loop shapes")[
```js
const f1 = (n) => { let c=0; for (let i=0;i<n;i++) c++;
                             for (let j=0;j<n;j++) c++; return c; };
const f2 = (n) => { let c=0; for (let i=0;i<n;i++)
                               for (let j=0;j<n;j++) c++; return c; };
const f3 = (n) => { let c=0; for (let i=1;i<n;i*=2) c++; return c; };
const f4 = (n) => { let c=0; for (let i=0;i<n;i++)
                               for (let j=1;j<n;j*=2) c++; return c; };
```
]

#sol[
Measured counter values:

#code(lang: "text", caption: "Measured output")[
```text
n=1	f1=2	f2=1	f3=0	f4=0
n=2	f1=4	f2=4	f3=1	f4=2
n=16	f1=32	f2=256	f3=4	f4=64
n=1024	f1=2048	f2=1048576	f3=10	f4=10240
```
]

- `f1`: the count is always $2n$. Side-by-side loops add. $O(n)$.
- `f2`: the count is $n^2$ ($1024^2 = 1{,}048{,}576$). Nested loops multiply. $O(n^2)$.
- `f3`: the count is $log_2 n$ ($1024 arrow.r 10$). $O(log n)$.
- `f4`: the count is $n log_2 n$ ($1024 times 10 = 10{,}240$). $O(n log n)$.
]
#ans[`f1` $O(n)$, `f2` $O(n^2)$, `f3` $O(log n)$, `f4` $O(n log n)$]
]

#ex(14, tier: 1, asked: "TCS Digital · pattern")[
*Problem.* Count the 1-bits in a number.
*Constraints.* $0 <= x < 2^63$.
*Target.* $O(log x)$ or better.
*Edge cases.* $x = 0$; $x$ a power of two; $x$ larger than $2^32$.

#sol[
First, the JavaScript problem. The constraint says $2^63$, and JavaScript's bitwise operators
only work on 32 bits. Tested in Node:

#code(lang: "text", caption: "Measured output — the 32-bit cliff")[
```text
2**40 | 0          = 0
(2**40) >>> 1      = 0   (should be 2**39 = 549755813888 )
(2**31) | 0        = -2147483648
```
]

Everything above bit 31 is thrown away, and bit 31 itself comes back negative. So for this
constraint the values must be `BigInt`. `BigInt` supports `&`, `|`, `^`, `<<` and `>>` at any
width, and its literals end in `n`: `1n`, `0n`.

#approach(1, "Shift one bit at a time", verdict: "O(number of bit positions) = O(log x)")

#code(lang: "js", caption: "One step per bit position")[
```js
const countBitsSlow = (n) => {           // n is a BigInt
  let c = 0;
  while (n > 0n) { c += Number(n & 1n); n >>= 1n; }
  return c;
};
```
]

#approach(2, "Clear the lowest set bit", verdict: "O(number of SET bits) — optimal")

`n & (n - 1)` clears exactly the lowest 1-bit and leaves the rest alone. So the loop runs
once per 1-bit, not once per bit position.

#code(lang: "js", caption: "One step per set bit")[
```js
const countBitsFast = (n) => {           // n is a BigInt
  let c = 0;
  while (n > 0n) { n &= n - 1n; c++; }
  return c;
};
```
]

Measured, both agree:

#code(lang: "text", caption: "Measured output")[
```text
0 -> slow 0 fast 0
1 -> slow 1 fast 1
7 -> slow 3 fast 3
8 -> slow 1 fast 1
1023 -> slow 10 fast 10
1024 -> slow 1 fast 1
1099511627776 -> slow 1 fast 1
1099511627777 -> slow 2 fast 2
turns for 1099511627776: slow=41 fast=1
```
]

Look at $2^40 = 1{,}099{,}511{,}627{,}776$. The slow version needs 41 loop turns to find its
single 1-bit; the fast version needs 1.

If the problem had said $0 <= x < 2^31$ instead, plain numbers are fine and the code is the
same without the `n` suffixes:

#code(lang: "js", caption: "The 32-bit version — only when the constraint allows it")[
```js
const countBits32 = (n) => {
  let c = 0;
  while (n !== 0) { n &= n - 1; c++; }
  return c;
};
```
]
Tested: `0` gives `0`, `7` gives `3`, `1024` gives `1`, `2147483647` gives `31`.
]
#complexity(time: "O(popcount) vs O(log x)", space: "O(1)",
  note: "Both are 'fast'. The second is faster on sparse numbers.")
#trap[
Never mix a `BigInt` and a `Number` in one expression. `1n + 1` throws
`TypeError: Cannot mix BigInt and other types`. Convert on purpose with `Number(x)` or
`BigInt(x)`, and remember that `Number(x)` on a huge `BigInt` loses precision above
$2^53 - 1$.
]
]

#ex(15, tier: 1, asked: "Infosys · pattern")[
*Problem.* Compute the $n$-th Fibonacci number. Why is the plain recursion unusable?
*Constraints.* $n <= 90$.
*Target.* $O(n)$.
*Edge cases.* $n = 0$; $n = 1$; $n = 90$ (past the exact range of a JavaScript number).

#sol[
#approach(1, "Plain recursion", verdict: "O(2^n) — unusable past n ≈ 40")

#code(lang: "js", caption: "Recomputes the same values again and again")[
```js
const fibSlow = (n) => {
  if (n <= 1) return n;
  return fibSlow(n - 1) + fibSlow(n - 2);
};
```
]

#approach(2, "Remember each answer (memo)", verdict: "O(n) — optimal")

#code(lang: "js", caption: "Each n is computed once")[
```js
const fibMemo = (n, memo = new Map()) => {
  if (n <= 1) return n;
  if (memo.has(n)) return memo.get(n);
  const v = fibMemo(n - 1, memo) + fibMemo(n - 2, memo);
  memo.set(n, v);
  return v;
};
```
]

Both were run with a call counter:

#code(lang: "text", caption: "Measured output")[
```text
n=10 fib=55 same=true slowCalls=177 memoCalls=19
n=20 fib=6765 same=true slowCalls=21891 memoCalls=39
n=30 fib=832040 same=true slowCalls=2692537 memoCalls=59
```
]

The slow version's call count roughly *triples* every 5 steps of $n$. The memo version's
call count is $2n - 1$: a straight line. At $n = 50$ the slow version needs about 40 billion
calls; the memo version needs 99.

#approach(3, "A loop, with BigInt for the big end", verdict: "O(n), no stack at all")

#code(lang: "js", caption: "Exact for every n up to 90")[
```js
const fibBig = (n) => {
  let a = 0n, b = 1n;
  for (let i = 0; i < n; i++) [a, b] = [b, a + b];
  return a;                                   // a BigInt
};
```
]

#code(lang: "text", caption: "Measured output — where the doubles start lying")[
```text
n=0 Number=0  BigInt=0  exact? true
n=1 Number=1  BigInt=1  exact? true
n=78 Number=8944394323791464  BigInt=8944394323791464  exact? true
n=79 Number=14472334024676220  BigInt=14472334024676221  exact? false
n=90 Number=2880067194370816000  BigInt=2880067194370816120  exact? false
```
]
]
#complexity(time: "O(2^n) vs O(n)", space: "O(n) for the memo and the call stack")
#trap[
$"fib"(90) = 2{,}880{,}067{,}194{,}370{,}816{,}120$ is larger than
`Number.MAX_SAFE_INTEGER`. A plain JavaScript number gives
`2880067194370816000` — the last three digits are gone. The first $n$ that is already wrong
is $n = 79$. Any Fibonacci past $n = 78$ needs `BigInt`.
]
#trap[
`fibSlow(n)` recurses $n$ deep, which is fine at $n = 90$. But Node's call stack holds only
about $10^4$ frames. A recursion that goes $10^5$ deep — a DFS on a long path graph, for
example — throws `RangeError: Maximum call stack size exceeded`. When the depth can reach
$10^5$, rewrite the recursion with an explicit stack array.
]
]

#ex(16, tier: 1, asked: "TCS NQT · pattern")[
*Problem.* You will do $n = 200{,}000$ insertions and $n$ lookups by key. JavaScript gives
you three choices: a plain object, a `Map`, or a sorted array searched with `lowerBound`.
Pick one and justify it with a number.
*Constraints.* keys are integers, no ordering needed in the output.
*Target.* $O(n)$ expected.
*Edge cases.* keys all equal; keys inserted in increasing order.

#sol[
A *plain object* is a hash table too, but every key is first converted to a string, and V8
moves an object into a slower "dictionary" layout once the keys stop being small dense
integers. A *`Map`* hashes the value itself and keeps insertion order. A *sorted array* plus
binary search is $O(log n)$ per lookup, and it is the only one of the three that can also
answer "the smallest key greater than $x$" — JavaScript has no ordered map.

#code(lang: "js", caption: "The same work, three containers")[
```js
const { lowerBound } = require('./toolkit.js');   // JS Toolkit appendix

const obj = Object.create(null);                  // plain object
for (const k of keys) obj[k] = k;
for (const k of keys) s1 += obj[k];

const m = new Map();                              // Map
for (const k of keys) m.set(k, k);
for (const k of keys) s2 += m.get(k);

const sorted = [...keys].sort((a, b) => a - b);   // sorted array
for (const k of keys) s3 += sorted[lowerBound(sorted, k)];
```
]

Measured with $n = 200{,}000$, third run (the first run pays for the JIT warming up):

#code(lang: "text", caption: "Measured output")[
```text
run 1: equal=true object=140ms Map=53ms sorted+binary=61ms
run 2: equal=true object=147ms Map=31ms sorted+binary=49ms
run 3: equal=true object=144ms Map=29ms sorted+binary=53ms
```
]

The `Map` wins, and the plain object is about 5 times slower. The sorted array costs a little
more than the `Map` and buys you ordered queries:

#code(lang: "text", caption: "What only the sorted array can answer")[
```text
smallest key > 500000 = 500001
```
]
]
#ans[`Map`, unless you need the keys in sorted order — then a sorted array plus
`lowerBound` / `upperBound`]
#trap[
A plain object stringifies keys. Tested in Node: after `o[1] = 'num'` and `o['1'] = 'str'`,
`o[1]` is `'str'` and `Object.keys(o)` is `["1"]` — the two keys collided. The same code with
a `Map` keeps both and reports `size` 2. Use a `Map` whenever keys are numbers, and always
when they can be negative or fractional.
]
]

#ex(17, tier: 1, asked: "Wipro · pattern")[
*Problem.* An interviewer writes $T(n) = 3n^2 + 500 n + 20000$ and asks for the Big-O. Then
asks: at which $n$ does the $n^2$ term actually become the biggest one?

#sol[
Big-O keeps only the fastest-growing term and drops constants, so $T(n) = O(n^2)$.

Now the second half. We want $3n^2 > 500n$, that is $3n > 500$, that is
$n > 166.7$, so from $n = 167$ upward the square term beats the linear term.
And $3n^2 > 20000$ needs $n^2 > 6666.7$, so $n >= 82$.

So for $n$ below about 80, the constant 20,000 dominates and the function looks flat. For
$n$ above about 170, it is a parabola. Big-O describes the *large* $n$ behaviour, which is
the only behaviour the hidden tests care about.
]
#ans[$O(n^2)$; the $n^2$ term takes over from about $n = 167$]
#note[
This is why Big-O ignores constants: for the input sizes a judge uses ($10^5$ and up), the
shape always wins over the constant.
]
]

#section[Tier 2 — Let the limits choose the algorithm]
#tier-header(2)

#ex(18, tier: 2, asked: "Grab · pattern")[
*Problem.* A fare log stores the fare of each ride of the day, in order. The dashboard asks
$q$ questions of the form "total fare of rides $l$ through $r$".
*Constraints.* $n <= 2 times 10^5$ rides, $q <= 2 times 10^5$ questions, each fare up to
$10^4$ and possibly negative (refunds).
*Target.* $O(n + q)$.
*Edge cases.* $l = r$ (one ride); $l = 0$ and $r = n-1$ (the whole day).

#sol[
#approach(1, "Add up the range for every question", verdict: "O(n·q) = 4·10^10, far too slow")

#code(lang: "js", caption: "One question, one scan")[
```js
const sumSlow = (a, l, r) => {
  let s = 0;
  for (let i = l; i <= r; i++) s += a[i];
  return s;
};
```
]
#complexity(time: "O(n) per question, O(n q) in total", space: "O(1)")

#approach(2, "Precompute running totals once", verdict: "O(n) build + O(1) per question — optimal")

Let $p[i]$ be the total of the first $i$ fares, with $p[0] = 0$. Then the total of
$l..r$ is $p[r+1] - p[l]$, because the part before $l$ cancels.

#code(lang: "js", caption: "Prefix sums")[
```js
const buildPrefix = (a) => {
  const p = new Array(a.length + 1).fill(0);
  for (let i = 0; i < a.length; i++) p[i + 1] = p[i] + a[i];
  return (l, r) => p[r + 1] - p[l];     // a closure over p, no class needed
};
```
]
#complexity(time: "O(n) build, O(1) per query", space: "O(n)")

Measured with $n = q = 200{,}000$ and wide ranges:

#code(lang: "text", caption: "Measured output")[
```text
first 200 queries agree? yes
slow: 200 queries in 32 ms
prefix: all 200000 queries in 21 ms
one ride l=r=0 -> -10000  whole day -> -97975
single [5]: query(0,0) = 5
negatives [-3,-4]: query(0,1) = -7
worst total 2e5 * 1e4 = 2000000000  safe in a JS number? true
```
]

The slow version needed 32 ms for *200* questions. Scale that to 200,000 questions and it is
about 32 seconds. The prefix version answered all 200,000 in 21 ms.

This is one of the chapter's signature problems, so here it is in Python too:

#code(lang: "python", caption: "Python version of the optimal")[
```python
from itertools import accumulate

def build_prefix(a):
    p = [0] + list(accumulate(a))
    return lambda l, r: p[r + 1] - p[l]
```
]
Run on `[5]` and `[-3,-4]`, Python prints `5` and `-7` — the same answers as the JavaScript.

*The idea that unlocked it.* The questions overlap. The slow version re-adds the same
numbers for every question. Pay $O(n)$ once, then each answer is one subtraction. Chapter 2
is built entirely on this idea.
]
#note[
In C++ or Java this is where you would have to remember to declare `p` as a 64-bit type,
because $2 times 10^5$ fares of $10^4$ each reaches $2 times 10^9$ and a 32-bit integer
stops at about $2.1 times 10^9$. JavaScript has no 32-bit integer type, so this particular
trap is gone — the measured line above confirms $2 times 10^9$ is safe. The JavaScript limit
is $2^53 - 1 approx 9 times 10^15$, which is five million times higher. Check *that* number
instead.
]
]

#ex(19, tier: 2, asked: "Shopee · pattern")[
*Problem.* From two million order values, report the 10 largest.
*Constraints.* $n <= 2 times 10^6$, $k <= 100$.
*Target.* better than a full sort.
*Edge cases.* $k = 1$; $k = n$; duplicate values among the top $k$.

#sol[
#approach(1, "Sort everything, take the first k", verdict: "O(n log n) — works, but does too much")

#code(lang: "js", caption: "Full sort")[
```js
const kthLargestSort = (a, k) => [...a].sort((x, y) => y - x)[k - 1];
```
]

#approach(2, "Keep a min-heap of size k", verdict: "O(n log k) — optimal for small k")

Hold the best $k$ seen so far in a *min*-heap. The smallest of the $k$ sits on top. Each new
value is pushed; if the heap grows past $k$, pop the smallest. Only $k$ items are ever
stored.

*JavaScript has no built-in priority queue.* Use the tested `MinHeap` from the *JS Toolkit*
appendix — do not write your own here.

#code(lang: "js", caption: "Min-heap of size k")[
```js
const { MinHeap } = require('./toolkit.js');   // JS has no priority queue

const kthLargestHeap = (a, k) => {
  const h = new MinHeap();                     // default comparator (a, b) => a - b
  for (const x of a) {
    h.push(x);
    if (h.size > k) h.pop();                   // drop the smallest of the k+1
  }
  return h.peek();
};
```
]
#complexity(time: "O(n log k)", space: "O(k)",
  note: "log2(10) ≈ 3.3 against log2(2·10^6) ≈ 21. About 6 times less work per element.")

Measured:

#code(lang: "text", caption: "Measured output")[
```text
k=1 sort=9 heap=9
k=2 sort=9 heap=9
k=3 sort=5 heap=5
k=4 sort=3 heap=3
k=5 sort=1 heap=1
single: -7 -7
all equal [4,4,4] k=3: 4 4
big: sort=999995999 heap=999995999 sortTime=1617 ms heapTime=289 ms
bare .sort() on [5,1,9,3,9] gives [1,3,5,9,9]  and on [10,9,1] [1,10,9]
```
]

The first five lines use the array `[5, 1, 9, 3, 9]`. Notice $k = 1$ and $k = 2$ both give 9:
duplicates each take their own place in the ranking, which is the usual rule. State it before
you code.

#trap[
Read the last measured line again. A bare `.sort()` on `[5,1,9,3,9]` *looks* correct, because
every value is a single digit and text order matches number order there. On `[10,9,1]` the
same call gives `[1,10,9]`. This is exactly how the bug survives your own small tests and
then fails the hidden ones. `sort((x, y) => y - x)` for descending, `sort((x, y) => x - y)`
for ascending, always.
]

*The idea.* A full sort orders all $n$ items when the question only asks about $k$ of them.
Sorting is the default, not the answer. Ask what the question actually needs.
]
]

#ex(20, tier: 2, asked: "Agoda · pattern")[
*Problem.* Sort two million review scores. Every score is an integer from 0 to 100.
*Constraints.* $n <= 2 times 10^6$, values in $[0, 100]$.
*Target.* beat $O(n log n)$.
*Edge cases.* empty array; all values equal.

#sol[
#approach(1, "a.sort((x, y) => x - y)", verdict: "O(n log n) — fine, but ignores a gift in the constraints")

#approach(2, "Counting sort", verdict: "O(n + k) where k = 101 — optimal")

The value range is tiny. Count how many of each value there are, then write them out in
order. No comparisons at all.

#code(lang: "js", caption: "Counting sort")[
```js
const countingSort = (a, maxVal) => {
  const cnt = new Array(maxVal + 1).fill(0);
  for (const x of a) cnt[x]++;
  const out = [];
  for (let v = 0; v <= maxVal; v++)
    for (let c = 0; c < cnt[v]; c++) out.push(v);
  return out;
};
```
]
#complexity(time: "O(n + k)", space: "O(n + k)",
  note: "k is the value range, not the array length.")

Measured on two million scores:

#code(lang: "text", caption: "Measured output")[
```text
same answer? yes
sort((a,b)=>a-b) : 585 ms
counting sort    : 154 ms
empty: 0
all equal [2,2,2]: [2,2,2]
bare .sort() on 3 values [100,9,20] -> [100,20,9]
```
]

Almost four times faster, and the results are identical.

*The idea.* "$O(n log n)$ is the best possible for sorting" is only true for sorts that
*compare* elements. Counting sort never compares; it uses the value as an array index. When
the value range is small, use it.
]
#trap[
Counting sort needs an array of size `maxVal + 1`. If the scores went up to $10^9$, this
approach would ask for 8 GB. Check the *value range*, not just $n$.
]
#trap[
The last measured line is the reason this chapter repeats itself about `.sort()`. Scores are
two- and three-digit numbers, and `[100, 9, 20].sort()` returns `[100, 20, 9]` — the exact
reverse of the right answer, with no error message.
]
#note[
`new Array(k).fill(0)` is required. `new Array(k)` alone makes a *sparse* array whose slots
are all `undefined`, and `undefined++` gives `NaN`. For a large fixed-size counter,
`new Int32Array(k)` is both zero-filled and half the memory.
]
]

#ex(21, tier: 2, asked: "Sea/Shopee · pattern")[
*Problem.* Given $n$ driver ratings, count the pairs $(i, j)$ with $i < j$ whose ratings add
up to exactly `target`.
*Constraints.* $n <= 2 times 10^5$; ratings can be negative; the count can exceed $2 times 10^10$.
*Target.* $O(n)$ expected.
*Edge cases.* empty array; all values equal (so every pair counts); a value of $10^9$ twice.

#sol[
#approach(1, "Every pair", verdict: "O(n^2) — 2·10^10 steps, too slow")

#code(lang: "js", caption: "Brute force")[
```js
const countPairsBrute = (a, target) => {
  let cnt = 0;
  for (let i = 0; i < a.length; i++)
    for (let j = i + 1; j < a.length; j++)
      if (a[i] + a[j] === target) cnt++;
  return cnt;
};
```
]

#approach(2, "Sort, then two pointers", verdict: "O(n log n) — passes, but the duplicate
handling is fiddly")

#approach(3, "One pass with a frequency Map", verdict: "O(n) expected — optimal")

Walk left to right. Before adding `x` to the `Map`, ask how many earlier values equal
`target - x`. Each of those earlier values pairs with this `x` exactly once, and the
condition $i < j$ is satisfied automatically because we only look *backwards*.

#code(lang: "js", caption: "Count as you go")[
```js
const countPairsMap = (a, target) => {
  const freq = new Map();
  let cnt = 0;
  for (const x of a) {
    cnt += freq.get(target - x) ?? 0;          // earlier partners
    freq.set(x, (freq.get(x) ?? 0) + 1);       // now x is available as a partner
  }
  return cnt;
};
```
]
#complexity(time: "O(n) expected", space: "O(n)")

Both versions were run on the same tests:

#code(lang: "text", caption: "Measured output")[
```text
[] target=5 brute=0 map=0
[5] target=5 brute=0 map=0
[1,4,2,3] target=5 brute=2 map=2
[2,2,2,2] target=4 brute=6 map=6
[-3,3,0,0] target=0 brute=2 map=2
[1,1,2,2,3] target=4 brute=3 map=3
[1000000000,1000000000] target=2000000000 brute=1 map=1
worst count C(2e5,2) = 19999900000  safe? true
plain object key 1 is really ["1"]
```
]

Check `[2,2,2,2]` by hand: the pairs are $(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)$, which
is $binom(4,2) = 6$. The program agrees.

This is one of the chapter's signature problems, so here it is in Python too:

#code(lang: "python", caption: "Python version of the optimal")[
```python
from collections import Counter

def count_pairs(a, target):
    freq = Counter()
    cnt = 0
    for x in a:
        cnt += freq[target - x]     # Counter gives 0 for a missing key
        freq[x] += 1
    return cnt
```
]
Run on the same inputs, Python prints `0 0 2 6 2 1` for `[]`, `[5]`, `[1,4,2,3]`,
`[2,2,2,2]`, `[-3,3,0,0]` and `[10^9, 10^9]` — the same answers as the JavaScript.

*The idea.* "For each element, does a partner exist?" is a *search*. Replace the search with
a lookup and the inner loop disappears. Counting backwards also solves the $i < j$ problem
without any extra work.
]
#note[
The two numeric traps that would bite in C++ are both gone here. The count reaches
$binom(2 times 10^5, 2) = 19{,}999{,}900{,}000$, and `Number.isSafeInteger` confirms that
is exact in JavaScript. `a[i] + a[j]` with two values near $10^9$ gives $2 times 10^9$,
which is also exact. JavaScript only starts lying above $9 times 10^15$.
]
#trap[
Use a `Map`, not a plain object. Ratings can be negative, and the measured line
`plain object key 1 is really ["1"]` shows what an object does to a numeric key. With an
object, the number `-3` and the string `"-3"` become the same entry; a `Map` keeps them apart.
]
]

#ex(22, tier: 2, asked: "DBS · pattern")[
*Problem.* Why is Euclid's algorithm for GCD fast? Give the step count for the worst input
you can construct with two numbers below $10^9$.
*Constraints.* $1 <= a, b <= 10^9$.
*Edge cases.* $b = 0$; $a = b$; two consecutive Fibonacci numbers.

#sol[
#code(lang: "js", caption: "Euclid with a step counter")[
```js
let gcdSteps = 0;
const gcd = (a, b) => {
  gcdSteps = 0;
  while (b !== 0) { const r = a % b; a = b; b = r; gcdSteps++; }
  return a;
};
```
]

Measured:

#code(lang: "text", caption: "Measured output")[
```text
gcd(12,18)=6 steps=3
gcd(100,75)=25 steps=2
gcd(1000000007,998244353)=1 steps=9
gcd(13,8)=1 steps=5
gcd(5,0)=5 steps=0
gcd(701408733,433494437)=1 steps=42
```
]

Two nine-digit numbers took only 9 steps.

*Why.* After two steps the larger number is at most half of what it was. Proof sketch: if
$a >= b$, then $a mod b < b$, and also $a mod b < a/2$ (if $b <= a/2$ this is clear; if
$b > a/2$ then $a mod b = a - b < a/2$). So the pair shrinks by at least half every two
steps, giving $O(log min(a,b))$ steps.

The *worst* inputs are consecutive Fibonacci numbers: `gcd(13, 8)` needed 5 steps while the
much larger `gcd(10^9+7, 998244353)` needed only 9. The largest Fibonacci pair under $10^9$
is $(701408733, 433494437)$, and the last measured line shows it takes 42 steps. Still tiny.
]
#note[
`a % b` in JavaScript is exact for any values below $2^53$, so no cast is needed. It does
*not* behave like C++ on negative inputs in the way beginners expect, though: `-7 % 3` is
`-1` in JavaScript. For a GCD, call it on absolute values.
]
#ans[$O(log min(a,b))$ — never more than about 45 steps for 32-bit inputs]
]

#ex(23, tier: 2, asked: "GIC · pattern")[
*Problem.* `arr.push` sometimes has to copy the whole array into a bigger block of memory. So
is filling an array with $n$ values $O(n)$ or $O(n^2)$?
*Constraints.* $n <= 10^6$.
*Target.* name the *amortised* cost of one `push`.

#sol[
JavaScript does not let you read an array's capacity, so simulate the two growth policies and
count the copies:

#code(lang: "js", caption: "Doubling against growing by one")[
```js
const doublingCopies = (n) => {
  let cap = 0, copies = 0;
  for (let i = 1; i <= n; i++)
    if (i > cap) { copies += cap; cap = cap === 0 ? 1 : cap * 2; }
  return copies;
};

const growByOneCopies = (n) => {
  let copies = 0;
  for (let i = 1; i <= n; i++) copies += i - 1;   // copy everything, every push
  return copies;
};
```
]

#code(lang: "text", caption: "Measured copy counts")[
```text
n=1	doubling copies=0	grow-by-one copies=0
n=10	doubling copies=15	grow-by-one copies=45
n=1000	doubling copies=1023	grow-by-one copies=499500
n=100000	doubling copies=131071	grow-by-one copies=4999950000
```
]

The capacity *doubles*, so a copy happens at push 1, 2, 3, 5, 9, 17, 33, ..., and the copies
cost $1 + 2 + 4 + 8 + ... + n$, which is less than $2n$ in total. Doubling: 131,071 copies
for 100,000 pushes — about 1.3 per push. Growing by one: 5 billion copies. This is what
*amortised $O(1)$* means: one single call may be slow, but any run of $n$ calls costs $O(n)$
altogether.

V8 grows a JavaScript array the doubling way, and the timings show it:

#code(lang: "text", caption: "Measured output")[
```text
push  1000000 times : 48 ms  (length 1000000)
unshift 100000 times: 617 ms  (length 100000)
```
]

One million `push` calls in 48 ms. One *tenth* as many `unshift` calls took thirteen times
longer, because `unshift` has no doubling trick available: every existing element really does
move, every single time.
]
#ans[Amortised $O(1)$ per `push`, $O(n)$ for all $n$ pushes. `unshift` is $O(n)$ per call and
$O(n^2)$ for $n$ calls.]
#note[
Amortised is not the same as average-case. Average-case talks about lucky and unlucky
*inputs*. Amortised talks about a *sequence* of operations and is a worst-case promise about
the whole sequence.
]
#trap[
`arr.pop()` is $O(1)$ but `arr.shift()` is $O(n)$ — it is `unshift` in reverse. A queue built
from `push` and `shift` is $O(n^2)$ on $n$ items. Use the toolkit `Deque`, which keeps a head
index instead of moving anything. See the *JS Toolkit* appendix and Chapter 9.
]
]

#ex(24, tier: 2, asked: "SCB · pattern")[
*Problem.* How many steps does this run? It looks like two nested loops over $n$.

#code(lang: "js", caption: "The inner loop steps by i")[
```js
const harmonicSteps = (n) => {
  let steps = 0;
  for (let i = 1; i <= n; i++)
    for (let j = i; j <= n; j += i)
      steps++;
  return steps;
};
```
]
*Constraints.* $n <= 10^6$.

#sol[
For a fixed $i$, the inner loop hits $i, 2i, 3i, ...$ up to $n$, so it runs $n/i$ times
(rounded down).

Total $= n/1 + n/2 + n/3 + ... + n/n = n (1 + 1/2 + 1/3 + ... + 1/n)$.

The bracket is the *harmonic sum*, and it is close to $ln n$. So the total is about
$n ln n$.

Measured:

#code(lang: "text", caption: "Measured output")[
```text
n=10	steps=27	n ln n = 23
n=100	steps=482	n ln n = 461
n=1000	steps=7069	n ln n = 6908
n=100000	steps=1166750	n ln n = 1151293
```
]

At $n = 100{,}000$ the true count is 1.17 million. A real $O(n^2)$ loop would be 10 billion —
nearly ten thousand times more.
]
#ans[$O(n log n)$, not $O(n^2)$]
#note[
This exact shape appears in the Sieve of Eratosthenes. That is why the sieve is fast.
]
]

#section[Tier 3 — Insight, then the follow-up]
#tier-header(3)

#ex(25, tier: 3, asked: "Amazon · pattern")[
*Problem.* Given $n$ integers and a value `target`, count the triples $i < j < k$ whose sum
is strictly less than `target`.
*Constraints.* $n <= 3000$; values in $[-10^9, 10^9]$.
*Target.* $O(n^2)$.
*Edge cases.* $n < 3$ (answer 0); all values equal; negative values.

#sol[
#approach(1, "Three nested loops", verdict: "O(n^3) = 2.7·10^10, too slow")

#code(lang: "js", caption: "Brute force")[
```js
const tripletsBrute = (a, target) => {
  let cnt = 0;
  for (let i = 0; i < a.length; i++)
    for (let j = i + 1; j < a.length; j++)
      for (let k = j + 1; k < a.length; k++)
        if (a[i] + a[j] + a[k] < target) cnt++;
  return cnt;
};
```
]

#approach(2, "Sort, fix one, two pointers for the rest", verdict: "O(n^2) — optimal here")

Sort the array. Fix the smallest member `a[i]`. Now we need pairs $(l, r)$ with
$l < r$ and $a[l] + a[r] < "target" - a[i]$.

Put `l` just after `i` and `r` at the end.
- If `a[i] + a[l] + a[r] < target`, then *every* index between `l` and `r` also works as the
  partner of `l`, because the array is sorted and those values are $<= a[r]$. That is
  $r - l$ triples at once. Then move `l` right.
- Otherwise the sum is too big, so move `r` left.

#code(lang: "js", caption: "Sort + two pointers")[
```js
const tripletsTwoPointer = (a, target) => {
  const v = [...a].sort((x, y) => x - y);   // never a bare .sort()
  let cnt = 0;
  for (let i = 0; i < v.length - 2; i++) {
    let l = i + 1, r = v.length - 1;
    while (l < r) {
      if (v[i] + v[l] + v[r] < target) {
        cnt += r - l;      // every k in (l, r] works too
        l++;
      } else r--;
    }
  }
  return cnt;
};
```
]
#complexity(time: "O(n^2)", space: "O(n) for the sorted copy",
  note: "n = 3000 gives 9·10^6 steps. Instant.")

Both versions were run together and always matched:

#code(lang: "text", caption: "Measured output")[
```text
target=5	[]	brute=0 twoPtr=0
target=10	[1,2]	brute=0 twoPtr=0
target=7	[1,2,3]	brute=1 twoPtr=1
target=6	[1,2,3]	brute=0 twoPtr=0
target=2	[-1,0,1,2]	brute=2 twoPtr=2
target=1	[0,0,0,0]	brute=4 twoPtr=4
target=100	[5,5,5]	brute=1 twoPtr=1
random n=400: brute=5534457 twoPtr=5534457
```
]

Note `[1,2,3]` with target 6: the only triple sums to 6, and 6 is not *less than* 6, so the
answer is 0. Strict versus non-strict is a real trap.

*The idea.* Sorting turns "count the partners" into "count a range of indices". The
`cnt += r - l` line is where an entire loop disappears.
]
#trap[
`[...a].sort(...)` makes a copy so the caller's array is not reordered. Remember that the
spread is a *shallow* copy: it is right here, where the elements are numbers, but if the
elements were themselves arrays (intervals, points, pairs) you would need
`a.map(row => [...row])` to copy them safely.
]
#trap[
Values here reach $10^9$, so a triple sum reaches $3 times 10^9$. In C++ that overflows a
32-bit `int` and needs a cast. In JavaScript it does not: numbers stay exact to
$9 times 10^15$. Do not carry the C++ habit of casting; do carry the habit of *checking the
number*, because the JavaScript limit is real too, just much higher.
]

#subsection[The follow-up the interviewer asks next]

*"Now count triples with sum exactly equal to target."* The same $O(n^2)$ shape works, but
when you hit an exact match you must count how many copies of `a[l]` and `a[r]` there are
and multiply — and handle `a[l] == a[r]` separately with $m(m-1)/2$. That is the same
duplicate trap as the pair version in Example 21.

*"Now $n <= 10^5$."* $O(n^2)$ is $10^10$ and dies. There is no known $O(n log n)$ for the
general triple-sum count, so the interviewer is testing whether you will say so. The honest
answer: "with those limits, the problem must have extra structure — small value range, or
only counting, or offline queries. Which is it?"
]

#ex(26, tier: 3, asked: "Google · pattern")[
*Problem.* You are given $n$ item weights and a truck capacity `limit`. Find the largest
total weight that fits.
*Constraints.* $n <= 36$; weights up to $10^6$; `limit` up to $10^12$.
*Target.* around $2^(n slash 2)$.
*Edge cases.* $n = 0$ (answer 0); all items heavier than the limit (answer 0); negative
weights are not allowed here, but the code below still handles them.

#sol[
The limit $n <= 36$ is the whole message. $n$ is far too small for a polynomial bound to
matter and far too big for $2^n$.

#approach(1, "Try every subset", verdict: "O(2^n · n) — 2^36 ≈ 7·10^10, too slow")

#code(lang: "js", caption: "Enumerate all subsets with a bitmask")[
```js
const bestSubsetSum = (a, limit) => {
  let best = 0;
  for (let mask = 0; mask < (1 << a.length); mask++) {
    let s = 0;
    for (let i = 0; i < a.length; i++) if (mask & (1 << i)) s += a[i];
    if (s <= limit) best = Math.max(best, s);
  }
  return best;
};
```
]

Measured: $n = 20$ (that is 1,048,576 masks) took 56 ms. So $n = 36$, which is 65,536 times
more masks, would take about an hour.

#trap[
`1 << n` is a *32-bit* shift. At $n = 31$ it goes negative and at $n = 32$ it wraps to `1`,
so this brute force silently returns nonsense for $n >= 31$ — another reason it cannot be the
answer here. If you ever do need masks past 31 bits, the loop counter must be a `BigInt`, or
you split the problem, which is exactly what comes next.
]

#approach(2, "Meet in the middle", verdict: "O(2^(n/2) · n/2 · log) — optimal")

Split the items into two halves of 18. Build *all* subset sums of each half: $2^18 =
262{,}144$ sums per half, which is nothing. Sort the right half's sums. For every left sum
`x`, binary-search the largest right sum that is $<= "limit" - x$.

JavaScript has no built-in binary-search helper, so use the tested `upperBound` from the
*JS Toolkit* appendix. `upperBound(rs, x)` returns the index of the first value *greater
than* `x`, so `upperBound(rs, x) - 1` is the largest value that still fits.

#code(lang: "js", caption: "Meet in the middle")[
```js
const { upperBound } = require('./toolkit.js');   // JS Toolkit appendix

const allSums = (a) => {
  const out = [];
  for (let mask = 0; mask < (1 << a.length); mask++) {
    let t = 0;
    for (let i = 0; i < a.length; i++) if (mask & (1 << i)) t += a[i];
    out.push(t);
  }
  return out;
};

const bestSubsetMeet = (a, limit) => {
  const half = a.length >> 1;
  const ls = allSums(a.slice(0, half));
  const rs = allSums(a.slice(half)).sort((x, y) => x - y);
  let best = -Infinity;
  for (const x of ls) {
    const idx = upperBound(rs, limit - x) - 1;    // largest right sum that still fits
    if (idx >= 0) best = Math.max(best, x + rs[idx]);
  }
  return best;
};
```
]
#complexity(time: "O(2^(n/2) · (n/2 + log(2^(n/2))))", space: "O(2^(n/2))",
  note: "For n = 36: about 5·10^5 sums instead of 7·10^10 subsets.")

Measured against the brute force on small inputs, and then on a real $n = 36$ with weights
$250{,}000, 251{,}000, ..., 285{,}000$ and a limit of $9{,}000{,}000$:

#code(lang: "text", caption: "Measured output")[
```text
limit=10 []	brute=0 meet=0
limit=10 [7]	brute=7 meet=7
limit=10 [3,5,8]	brute=8 meet=8
limit=10 [-4,6,6]	brute=8 meet=8
limit=10 [1,2,3,4,5,6,7,8]	brute=10 meet=10
n=36 meet-in-the-middle answer=8877000 time=98 ms
   (524288 subsets built, not 68719476736)
n=20 brute force took 56 ms
```
]

Ninety-eight milliseconds instead of an hour.

#trap[
Each half is 18 items, so `1 << 18` is safe. Splitting is what keeps the mask under 31 bits.
Also note the `.sort((x, y) => x - y)` on `rs`: `upperBound` does a binary search and gives
wrong answers on a lexicographically sorted array. A bare `.sort()` here would break the
whole algorithm silently.
]

*The idea.* $2^36 = 2^18 times 2^18$. Doing $2^18$ work *twice* is nothing; doing $2^18$
work $2^18$ *times* is impossible. Splitting the exponent in half is the whole trick.
]

#subsection[The follow-up]

*"What if $n <= 100$ but every weight is at most 1000?"* Then the total weight is at most
$10^5$ and you should switch to a knapsack DP: $O(n times "sum")= 10^7$. Notice how the
*second* constraint changed the answer completely. Always read every constraint line.
]

#ex(27, tier: 3, asked: "Microsoft · pattern")[
*Problem.* Your "$O(n)$, I use a lookup" solution passed all your own tests, then failed the
hidden tests with Time Limit Exceeded. Here is the line you wrote. Find the cost.
*Constraints.* $n = 2 times 10^5$ values, checking each one against the ones already seen.

#code(lang: "js", caption: "The line that looks like a lookup")[
```js
const seen = [];
for (const x of values) {
  if (seen.includes(x)) duplicates++;   // <-- this is a full scan
  seen.push(x);
}
```
]

#sol[
`seen.includes(x)` is not a hash lookup. It is a linear scan of the array, $O(n)$ every time.
Inside a loop over $n$ values that makes the whole thing $O(n^2)$. `indexOf`, `lastIndexOf`,
`find` and `filter` all have the same shape. A `Set` really is a hash lookup, $O(1)$ expected.

#code(lang: "js", caption: "The fix is one word")[
```js
const seen = new Set();
for (const x of values) {
  if (seen.has(x)) duplicates++;        // O(1) expected
  seen.add(x);
}
```
]

Both were measured at three sizes so you can watch the shape, not just one number:

#code(lang: "text", caption: "Measured output")[
```text
n = 50000
  Set.has          : 5 ms
  array.includes   : 1020 ms
  array.indexOf    : 1011 ms
n = 100000
  Set.has          : 8 ms
  array.includes   : 4056 ms
  array.indexOf    : 4069 ms
n = 200000
  Set.has          : 19 ms
  array.includes   : 16492 ms
  array.indexOf    : 16710 ms
```
]

Nineteen milliseconds against sixteen and a half *seconds*: a factor of 870 at the real
constraint. And look at the doubling. Each time $n$ doubles, `Set` roughly doubles
($5 arrow.r 8 arrow.r 19$) but `includes` roughly *quadruples*
($1020 arrow.r 4056 arrow.r 16492$). Quadrupling on a doubled input is the fingerprint of
$O(n^2)$, and you can read it off two timings without any theory at all.

This is why your own tests passed. At $n = 1000$ the slow version needs about 0.4 ms. You
will never notice.

*Fixes, in the order you should reach for them.*
+ `Set` for membership, `Map` for key $arrow.r$ value. This is almost always the answer.
+ If the values must stay ordered, sort once and use two pointers or `lowerBound` from the
  *JS Toolkit* appendix: $O(n log n)$ total, and no hashing at all.
+ If you truly need an array, keep a parallel `Set` beside it for the membership test.
]

#subsection[The follow-up]

*"Give me the worst case of a `Set` lookup, the average case, and which one Big-O usually
reports."* Worst $O(n)$ per operation, expected $O(1)$. Big-O is usually quoted as the worst
case, but for hash tables everyone quotes the expected cost — so say which one you mean. In
an interview, the sentence that scores is: "$O(1)$ *expected*, $O(n)$ worst case if the hash
degrades."

*"Is a JavaScript `Set` attackable the way a C++ `unordered_set` is?"* Much less easily. A
A C++ hash map with the default integer hash puts key $k$ in bucket $k mod B$, so a test
setter who knows $B$ can send keys that all collide. V8 mixes the bits of a number key and
seeds string hashing randomly per process, so a fixed key set cannot be built in advance.
That makes the failure mode above — a linear scan wearing the costume of a lookup — far more
likely than a hash attack. Still say "expected". You are not promising $O(1)$ worst case.
]

#ex(28, tier: 3, asked: "Goldman Sachs · pattern")[
*Problem.* You must answer $q$ range-sum questions on an array of $n$ numbers. A colleague
suggests precomputing the answer to *every* possible $(l, r)$ pair so each query is a single
array read. For $n = 10^5$, is that a good idea?
*Constraints.* $n <= 10^5$, $q <= 10^5$, memory limit 256 MB.

#sol[
Count the memory first, before writing any code.

The number of pairs with $l <= r$ is $(n(n+1))/2$. For $n = 10^5$:
$(10^5 times (10^5+1))/2 approx 5 times 10^9$ entries.

Each entry is a JavaScript number, which is a double, 8 bytes. That is $4 times 10^10$ bytes
$= 40{,}000$ MB $= 40$ GB. The limit is 256 MB. It is off by a factor of 156. It is also past
the hard ceiling: a JavaScript array cannot hold more than $2^32 - 1 approx 4.3 times 10^9$
elements at all, and $5 times 10^9$ is over that.

And the *build* would take $5 times 10^9$ steps, which is about 50 seconds by itself.

The prefix-sum table from Example 18 stores $n + 1$ numbers, that is 0.8 MB, builds in
$10^5$ steps, and answers each query with one subtraction.

#table(columns: 4,
  align: (left, right, right, right),
  [*Plan*], [*Build time*], [*Query time*], [*Memory*],
  [Precompute all pairs], [$5 times 10^9$], [$O(1)$], [40 GB],
  [Prefix sums], [$10^5$], [$O(1)$], [0.8 MB],
  [Nothing precomputed], [0], [$O(n)$], [0],
)
]
#ans[No. It uses 40 GB and takes 50 seconds to build, to buy nothing over prefix sums.]

#subsection[The follow-up]

*"Now the array can change: some queries update a single value."* Prefix sums break, because
one update ruins every prefix after it ($O(n)$ per update). The answer is a Fenwick tree or
a segment tree: $O(log n)$ per update *and* per query. Say the phrase "the array is no longer
static, so I need a structure that supports updates".

*"Now it is a stream — the numbers arrive one at a time and you cannot store them all."*
Then you cannot answer arbitrary $(l, r)$ at all. You can keep a running total, and answer
"sum of everything so far" in $O(1)$ and $O(1)$ memory. Being clear about what becomes
*impossible* is part of the answer.
]

#ex(29, tier: 3, asked: "D. E. Shaw · pattern")[
*Problem.* Here is a function. Give its time complexity in terms of $n$, and justify it.

#code(lang: "js", caption: "What is the cost?")[
```js
const mystery = (n) => {
  let c = 0;
  for (let i = 1; i <= n; i++)
    for (let j = i; j <= n; j += i)
      c++;
  for (let k = 1; k < n; k *= 2)
    for (let m = 0; m < n; m++)
      c++;
  return c;
};
```
]

#sol[
Two blocks, side by side, so we *add* their costs.

*Block 1.* This is Example 24. The inner loop runs $n/i$ times for each $i$, giving
$n(1 + 1/2 + ... + 1/n) approx n ln n$. Measured at $n = 10^5$: 1,166,750 steps.

*Block 2.* The outer loop doubles $k$, so it runs $log_2 n$ times. The inner loop runs $n$
times. Multiply: $n log_2 n$. Measured at $n = 1024$: 10,240 steps.

Total $approx n ln n + n log_2 n$. Both terms are $O(n log n)$, and adding two $O(n log n)$
terms is still $O(n log n)$. Measured totals: $n = 1$ gives 1, $n = 16$ gives 114
($50 + 64$), $n = 1024$ gives 17,502 ($7262 + 10240$).
]
#ans[$O(n log n)$]

#subsection[The follow-up]

*"Your two blocks use $ln$ and $log_2$. Does the base matter in Big-O?"* No.
$log_2 n = ln n / ln 2 approx 1.44 ln n$, so the bases differ only by a constant factor, and
Big-O drops constant factors. That is why nobody writes the base. But when you are estimating
*actual* step counts for a time limit, use $log_2$ — it is the bigger of the two and keeps
your estimate safe.
]

#ex(30, tier: 3, asked: "Adobe · pattern")[
*Problem.* You have 1 second. For each of these, say whether the plan passes, and give the
step count.
+ $n = 10^5$, plan is $O(n^2)$.
+ $n = 10^5$, plan is $O(n sqrt(n))$.
+ $n = 10^6$, plan is $O(n log n)$.
+ $n = 10^9$, plan is $O(sqrt(n))$.
+ $n = 25$, plan is $O(2^n)$.
+ $n = 10$, plan is $O(n!)$.

#sol[
Use the budget $10^8$ steps per second.

+ $ (10^5)^2 = 10^10$. That is 100 times the budget. *Fails* — about 100 seconds.
+ $10^5 times sqrt(10^5) approx 10^5 times 316 = 3.2 times 10^7$. *Passes* comfortably.
+ $10^6 times log_2 10^6 approx 10^6 times 20 = 2 times 10^7$. *Passes.*
+ $sqrt(10^9) approx 31{,}623$. *Passes* with enormous room.
+ $2^25 = 33{,}554{,}432 approx 3.4 times 10^7$. *Passes*, but only just — if each subset
  costs another $O(n)$ to evaluate, it becomes $8 times 10^8$ and fails.
+ $10! = 3{,}628{,}800$. *Passes.* But $12! = 4.8 times 10^8$ fails, and $13!$ is hopeless.
  This is why permutation problems always have $n <= 11$ or so.
]

#subsection[The follow-up]

*"Item 5 passed on the count but you said it might fail. Explain."* Big-O hides the work done
*inside* one step. $O(2^n)$ usually means "$2^n$ subsets", and if building or checking each
subset costs $O(n)$, the truth is $O(2^n n)$. Always ask what one "step" contains. In the
truck problem (Example 26) the inner `for (int i = 0; i < n; i++)` is exactly that hidden
factor.

*"Now it is distributed over 100 machines."* Dividing by 100 turns $10^10$ into $10^8$ — but
only if the work splits cleanly with no shared state. A sum splits cleanly. Sorting does not
(you still have to merge). Saying *which* part does not split is the real answer.
]

#section[Dry run — binary search, one line at a time]

We trace `binarySearch` on this array. It is sorted, which is the only thing the algorithm
needs.

#code(lang: "text", caption: "The array, with indices")[
```text
index :  0   1   2    3    4    5    6    7    8    9
value :  2   5   8   12   16   23   38   56   72   91
```
]

*Search for 23.* Start with `lo = 0`, `hi = 9`.

#table(columns: 6,
  align: (center, center, center, center, center, left),
  [*step*], [*lo*], [*hi*], [*mid*], [*a\[mid\]*], [*decision*],
  [1], [0], [9], [4], [16], [$16 < 23$, so go right: `lo = mid + 1 = 5`],
  [2], [5], [9], [7], [56], [$56 > 23$, so go left: `hi = mid - 1 = 6`],
  [3], [5], [6], [5], [23], [equal — return index 5, stop],
)

Work through step 1 slowly. `(lo + hi) / 2 = (0 + 9) / 2 = 4.5`, and `Math.floor(4.5) = 4`.
Without that `Math.floor` you would read `a[4.5]`, which is `undefined`, and every comparison
against `undefined` is `false`. `a[4] = 16`. We want 23, which is bigger, so everything at
index 4 and below is useless. That is why `lo` jumps to 5 — half the array is gone in one
step.

*Search for 40, which is not there.*

#table(columns: 6,
  align: (center, center, center, center, center, left),
  [*step*], [*lo*], [*hi*], [*mid*], [*a\[mid\]*], [*decision*],
  [1], [0], [9], [4], [16], [$16 < 40$: `lo = 5`],
  [2], [5], [9], [7], [56], [$56 > 40$: `hi = 6`],
  [3], [5], [6], [5], [23], [$23 < 40$: `lo = 6`],
  [4], [6], [6], [6], [38], [$38 < 40$: `lo = 7`],
  [--], [7], [6], [--], [--], [`lo > hi`, loop ends, return $-1$],
)

This is the real measured trace; the program printed
`ended with lo=7 hi=6 -> not found after 4 steps`.

#trick[
When the search fails, `lo` stops at the first index whose value is *greater* than the
target, and `hi` stops just left of it. That is the whole idea behind the toolkit's
`lowerBound` and `upperBound`, and it is why a failed search is still useful information.
JavaScript ships neither, so the *JS Toolkit* appendix carries both.
]

*Counting the cost.* The window is $"hi" - "lo" + 1$. It starts at $n$ and at least halves
each step: $10 arrow.r 5 arrow.r 2 arrow.r 1 arrow.r 0$. Four steps for ten elements.
$log_2 10 approx 3.3$, and we round up to 4. For $n = 10^6$ it was measured at 20 steps.

#section[Practice]

#practice(tier: 1, time: "25 min")[
+ How many times does the body run? `for (let i = 0; i < n; i += 3) ...`
+ Give the complexity: `for (let i = n; i > 0; i = Math.floor(i / 2)) ...`
+ Give the complexity of a loop nested inside a halving loop:
  `for (let i = n; i > 0; i = Math.floor(i/2)) for (let j = 0; j < n; j++) ...`
+ Simplify to Big-O: $T(n) = 7n^3 + 900 n^2 + 10^6 n + 10^9$.
+ Which is bigger for $n = 10^6$: $n log_2 n$ or $n sqrt(n)$? Show the numbers.
+ An algorithm takes 2 seconds for $n = 1000$ and is $O(n^2)$. Estimate its time for
  $n = 4000$.
+ You need $10^6$ operations on an *ordered* collection: insert, delete, and
  "smallest item bigger than x". JavaScript has no ordered set. What do you build, and what
  is the cost per operation?
+ $n = 10^5$ and you have written three nested loops. What is the step count and how far
  over the 1-second budget are you?
+ Why is `s.slice(i, i + k)` inside a loop dangerous?
+ An array holds $10^7$ numbers. How much memory, in MB? How much with `Int32Array`?
]

#practice(tier: 2, time: "30 min")[
+ You must answer $10^5$ questions "how many values in $[l, r]$ are greater than 50?" on a
  fixed array of $10^5$ numbers. Name a plan that is $O(n + q)$.
+ A solution is $O(n log^2 n)$. For $n = 2 times 10^5$, give the step count and say whether it
  passes in 1 second.
+ Sorting $10^7$ numbers, each between 0 and 999. What is the fastest approach, and why does
  it beat $O(n log n)$?
+ Explain, with the doubling numbers, why `arr.push(x)` is amortised $O(1)$ but
  `arr.unshift(x)` is $O(n)$ every time.
+ You have $n = 2 times 10^5$ items and want the 5 largest. Compare full sort against a heap
  of size 5, in steps.
+ A function calls itself twice on inputs of size $n/2$ and does $O(n)$ work to combine.
  What is the total? Name an algorithm shaped like this.
]

#practice(tier: 3, time: "35 min")[
+ $n <= 22$ and you must try every subset, doing $O(n)$ work per subset. Step count? Passes?
+ Prove that any comparison-based sort needs at least about $n log_2 n$ comparisons.
  (Hint: count the possible orderings.)
+ You have a $O(n^2)$ solution for $n <= 5000$ and the interviewer changes the limit to
  $n <= 10^6$. What do you say in the next 30 seconds?
+ A colleague's "hash lookup" solution is timing out. Their line is `if (seen.includes(x))`.
  Give the real complexity, two fixes, and the new complexity of each.
+ An algorithm does $n$ operations that are each $O(log n)$, plus one operation that is
  $O(n^2)$ but runs only when $n$ is a perfect square. Give the worst-case complexity.
]

#key[
*Tier 1.*
+ *$ceil(n\/3)$ times.* Each turn adds 3, so the values are $0, 3, 6, ...$ below $n$. Still
  $O(n)$ — the constant $1/3$ is dropped.
+ *$O(log n)$.* $n$ is halved each turn, so about $log_2 n$ turns.
+ *$O(n log n)$.* Outer runs $log_2 n$ times, inner runs $n$ times, and nested loops multiply.
+ *$O(n^3)$.* Keep the fastest-growing term only. The $10^9$ constant is huge but it never
  grows.
+ *$n sqrt(n)$ is bigger.* $n log_2 n = 10^6 times 20 = 2 times 10^7$.
  $n sqrt(n) = 10^6 times 1000 = 10^9$. Fifty times bigger.
+ *About 32 seconds.* $n$ went up 4 times, and $O(n^2)$ means the time goes up $4^2 = 16$
  times. $2 times 16 = 32$.
+ *A sorted array plus binary search, $O(log n)$ to find and $O(n)$ to insert — so if the
  inserts are spread through the run, use a balanced tree you write yourself, or batch the
  work.* "Smallest item bigger than x" is `upperBound` from the *JS Toolkit* appendix. A
  `Set` or `Map` cannot answer it at all, because neither keeps sorted order — `Map` keeps
  *insertion* order, which is not the same thing. This is the "no `TreeMap`" gap, and naming
  it out loud is most of the mark.
+ *$10^15$ steps, ten million times over budget.* $(10^5)^3 = 10^15$, and the budget is
  $10^8$. Three nested loops need $n <= 500$ or so.
+ *It copies $k$ characters every time, so the loop is $O(n k)$, not $O(n)$.* Use two indices
  into the original string instead of making copies. `slice`, `substring` and `split` all
  copy.
+ *76.3 MB as a plain array, 38.1 MB as an `Int32Array`.* Every JavaScript number is a
  double: $10^7 times 8 "bytes" = 8 times 10^7$ bytes, and
  $8 times 10^7 \/ (1024 times 1024) approx 76.3$. An `Int32Array` stores 4 bytes per value,
  so it halves that — worth knowing for the biggest inputs.

*Tier 2.*
+ *Prefix counts.* Build `c[i+1] = c[i] + (a[i] > 50 ? 1 : 0)` in $O(n)$. Every question is
  `c[r+1] - c[l]` in $O(1)$. Total $O(n + q)$.
+ *About $2 times 10^5 times 18 times 18 approx 6.5 times 10^7$ — passes.* $log_2(2 times 10^5)
  approx 17.6$, and $log^2$ means you square it.
+ *Counting sort, $O(n + k)$ with $k = 1000$.* It never compares two values; it uses the value
  as an index. The $n log n$ lower bound applies only to comparison sorts. Measured earlier:
  154 ms against 585 ms on 2 million values.
+ *Doubling means the copies total $1 + 2 + 4 + ... + n < 2n$ over all $n$ pushes, so under 2
  moves per push.* `unshift` has no such trick: every existing element must shift
  right, every single time, giving $O(n)$ per call and $O(n^2)$ for $n$ calls. Measured
  earlier: one million `push` calls in 48 ms, one hundred thousand `unshift` calls in 617 ms.
+ *Sort: $2 times 10^5 times 17.6 approx 3.5 times 10^6$. Heap of size 5:
  $2 times 10^5 times log_2 5 approx 2 times 10^5 times 2.3 = 4.6 times 10^5$.* The heap does
  about 7 times less work and uses $O(5)$ memory instead of $O(n)$.
+ *$O(n log n)$ — this is merge sort.* Each level of the recursion does $O(n)$ combine work,
  and there are $log_2 n$ levels. Measured in Node: merge sort on $n = 100{,}000$ used
  1,508,260 comparisons, and $n log_2 n = 1{,}660{,}964$.

*Tier 3.*
+ *$2^22 times 22 approx 9.2 times 10^7$ — passes, but with almost nothing to spare.* If each
  subset needed $O(n log n)$ work it would fail. Try to make the per-subset work $O(1)$ by
  building sums as you extend the mask.
+ *There are $n!$ possible orderings, and each comparison has 2 outcomes, so a decision tree
  of depth $d$ can tell apart at most $2^d$ orderings. You need $2^d >= n!$, so
  $d >= log_2(n!)$, and $log_2(n!) approx n log_2 n - 1.44 n$.* That is the $n log n$ lower
  bound.
+ *"$O(n^2)$ is $10^12$ at that limit, about 3 hours, so it is out. I need $O(n)$ or
  $O(n log n)$. The $n^2$ came from the inner loop that searches for a partner — I can replace
  it with a hash map, a sorted array with two pointers, or a prefix sum, depending on what the
  inner loop is doing."* Name the inner loop's job. That is what scores.
+ *`includes` is a linear scan, so the loop is $O(n^2)$ — measured at 16.5 seconds for
  $n = 2 times 10^5$.* (a) Replace the array with a `Set` and `includes` with `has`: $O(n)$
  expected, measured at 19 ms. (b) Sort once and use two pointers or `lowerBound` from the
  *JS Toolkit* appendix: $O(n log n)$ total, no hashing at all. Say "expected" for the first
  one — a `Set` promises $O(1)$ on average, not in the worst case.
+ *$O(n^2)$.* Worst case means worst *input*. The problem setter will choose $n = 10^6$, which
  is $1000^2$, a perfect square. "It rarely happens" is an average-case argument, and
  worst-case Big-O does not accept it.
]

#revision[

*The counting rules.* Side by side $arrow.r$ add. Nested $arrow.r$ multiply. Drop constants.
Keep only the fastest-growing term. Halving or doubling $arrow.r log_2 n$.

*The growth ladder.*
$O(1) < O(log n) < O(sqrt(n)) < O(n) < O(n log n) < O(n^2) < O(n^3) < O(2^n) < O(n!)$

*The budget.* About $10^8$ simple operations per second. Measured in Node: $10^8$ additions
took 146 ms; add a factor of 5--50 for real work.

*Constraint $arrow.r$ target, the table to memorise.*
#table(columns: 4,
  align: (left, left, left, left),
  [$n <= 12$ $arrow.r$ $O(n!)$], [$n <= 25$ $arrow.r$ $O(2^n)$],
  [$n <= 100$ $arrow.r$ $O(n^3)$], [$n <= 5000$ $arrow.r$ $O(n^2)$],
  [$n <= 10^5$ $arrow.r$ $O(n log n)$], [$n <= 10^6$ $arrow.r$ $O(n)$],
  [$n <= 10^9$ $arrow.r$ $O(sqrt n)$ or $O(log n)$], [$n <= 10^18$ $arrow.r$ $O(log n)$ or a formula],
)

*Memory.* Every JavaScript number is a double, 8 bytes. `Int32Array` is 4. $10^7$ numbers =
76 MB (fine), $10^7$ in an `Int32Array` = 38 MB. An $n times n$ table for $n = 10^5$ = 76 TB
(impossible, and past the $2^32 - 1$ array-length ceiling anyway). Limit is usually 256 MB.

*Logs to know by heart.* $log_2 10^3 approx 10$, $log_2 10^6 approx 20$,
$log_2 10^9 approx 30$. So $log n <= 30$ always. Treat it as a small constant.

*Hidden costs inside one line.*
#table(columns: 2,
  align: (left, left),
  [*Looks like $O(1)$*], [*Really costs*],
  [`a.splice(i, 1)`], [$O(n)$ — shifts everything after `i`],
  [`a.unshift(x)` / `a.shift()`], [$O(n)$ — shifts everything],
  [`a.includes(x)` / `a.indexOf(x)`], [$O(n)$ — a full scan wearing a lookup's costume],
  [`s.slice(i, i + k)`], [$O(k)$ — it copies],
  [`Set.has` / `Map.get`], [$O(1)$ expected, $O(n)$ worst case],
  [`a.push(x)`], [amortised $O(1)$, sometimes $O(n)$],
  [`arr.sort()`], [$O(n log n)$ — and *lexicographic*, so also wrong],
)

*The seven JavaScript facts this chapter proved with a measurement.*
#table(columns: (auto, 1fr),
  [`arr.sort()`],        [lexicographic. `[10,9,1].sort()` gives `[1,10,9]`. Always `(a, b) => a - b`.],
  [no heap],             [`MinHeap` from the *JS Toolkit* appendix. Example 19.],
  [no `TreeMap`],        [sorted array + `lowerBound`/`upperBound`. `Map` keeps *insertion* order, not sorted order.],
  [numbers are doubles], [exact to $2^53 - 1 approx 9 times 10^15$. Past it, `BigInt`. Example 15.],
  [bitwise is 32-bit],   [`2**40 | 0` is `0`; `1 << 32` is `1`. Use `BigInt` above 31 bits. Examples 14 and 26.],
  [recursion depth],     [about $10^4$ frames, then `RangeError`. Deep DFS needs an explicit stack.],
  [`[...a]` is shallow], [fine for numbers; a 2-D grid needs `a.map(r => [...r])`.],
)

*The ladder you climb on every problem.*
+ Brute force. Write it, state its cost, say why it fails.
+ Find the inner loop's *job*: searching, or re-adding, or re-sorting.
+ Replace that job: sort $arrow.r$ neighbours, hash $arrow.r$ lookup, prefix $arrow.r$
  subtraction, heap $arrow.r$ top-$k$.
+ State the new cost and check it against the budget.

*Top 5 traps.*
+ Passing the samples proves nothing. The hidden tests are at the constraint limit. Do the
  arithmetic first.
+ A bare `.sort()`. It sorts as text, and small single-digit test data hides it.
+ A single loop can still be $O(n^2)$ if a call inside it hides a loop — `includes`,
  `splice`, `unshift`.
+ $O(1)$ expected is not $O(1)$ worst case. Say "expected" out loud for `Map` and `Set`.
+ Big-O hides the work inside one step. $2^n$ subsets with $O(n)$ work each is $O(2^n n)$.
]

]
