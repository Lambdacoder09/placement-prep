#import "../../shared/lib/style.typ": *

#chapter(
  num: 6,
  title: "Strings & Pattern Matching",
  tagline: "A string is an array of characters. Every array trick still works — plus four that only strings need.",
)[

#formulas(title: "The four string engines")[
Almost every string question in a coding round is one of these four, or two of them stacked.

#table(
  columns: (auto, 1.4fr, auto),
  align: (left, left, left),
  [*Engine*], [*Use it when the question says...*], [*Cost*],
  [two pointers], [palindrome, reverse, compare from both ends], [$O(n)$],
  [frequency window], [anagram, "all characters of", "at most k distinct"], [$O(n)$],
  [prefix function (KMP)], [find a pattern, borders, periods, repeats], [$O(n + m)$],
  [rolling hash], [compare many substrings fast, count distinct], [$O(n)$ expected],
)

If none of the four fits, the answer is usually dynamic programming on two strings
(Chapter 18) --- edit distance, longest common subsequence.
]

#note[
This chapter needs nothing from the book's `toolkit.js` --- no heap, no DSU, no deque. What
it does need is the *JS Toolkit* appendix's list of JavaScript's string gaps: no `isalpha`,
no ordered map, no exact integer past $2^53 - 1$, and immutable strings. Every one of those
shows up below in a #box[trap] box at the point where it first bites.
]

#section[Pattern in one page]

#subsection[The JavaScript string toolkit]

#code(lang: "js", caption: "everything you actually use")[
```js
const s = 'placement';
s.length;                  // 9
s.slice(2, 6);             // 'acem'  -> [start, end), NOT start + length
s.indexOf('cem');          // 3
s.indexOf('zzz');          // -1     (a real -1, not a huge unsigned value)
s.startsWith('place');     // true

let t = s;
t += 's';                        // strings are IMMUTABLE: this builds a new one
[...t].reverse().join('');       // 'stnemecalp'

'apple' < 'banana';              // true : dictionary order
'Zoo'   < 'apple';               // true : 'Z' is 90, 'a' is 97

Number('  -42');           // -42   (leading spaces are skipped)
parseInt('42abc', 10);     // 42    (Number('42abc') is NaN)
String(7 * 6);             // '42'
```
]

#trap[
*`s.indexOf(x)` returns `-1` when there is no match, and `-1` is truthy.* So
`if (s.indexOf(x))` is a bug twice over: it says "found" for a missing pattern, and it says
"not found" when the pattern sits at index `0`. Tested in Node on `s = 'placement'`:
`if (s.indexOf('p'))` takes the *else* branch even though `'p'` is right there, and
`if (s.indexOf('zzz'))` takes the *then* branch even though `'zzz'` is absent.
Always compare explicitly:
```js
if (s.indexOf(x) !== -1) { ... }     // or, clearer: if (s.includes(x)) { ... }
```
]

#subsection[Strings are immutable]

#trap[
*You cannot write `s[0] = 'x'`.* A JavaScript string never changes. The assignment fails
silently in loose mode and throws `TypeError` in strict mode (which every ES module and
every `class` body already is). Any "in place" string algorithm becomes:

#align(center)[`const a = [...s];` #h(10pt) edit `a` #h(10pt) `a.join('')`]

Two problems in this chapter depend on it — Example 10 (reverse the words in place) and
Example 16 (compress a character array). Both take an *array of characters*, which is what
the interviewer means by "in place" when the language has immutable strings. Say that out
loud; it is the correct answer, not a dodge.
]

#subsection[Character arithmetic]

#code(lang: "js", caption: "letters are just small numbers")[
```js
const c = 'g';
c.charCodeAt(0) - 97;            // 6     -> the index into a 26-slot array
String.fromCharCode(97 + 3);     // 'd'
c >= 'a' && c <= 'z';            // true  -> strings compare by code unit
'7' >= '0' && '7' <= '9';        // true
c.toUpperCase();                 // 'G'
```
Output: `6 d true true G`
]

#note[
JavaScript has no `isalpha` or `isdigit`. Two honest replacements, both used in this
chapter:

- *range comparison*, the fastest: `c >= 'a' && c <= 'z'`, `c >= '0' && c <= '9'`.
  String comparison in JavaScript is by code unit, so this does exactly what you expect.
- *a regular expression*, the most readable: `/[a-z0-9]/i.test(c)`.

Both return a real `true`/`false`, so `===` against them is safe.
]

#trap[
*`s.length` counts UTF-16 code units, not characters.* Tested in Node: `'😀'.length` is
`2`, while `[...'😀'].length` is `1`, because the spread operator walks code points.
Interview inputs are almost always ASCII, where the two agree — but if the question says
"any Unicode text", index with `[...s]` and say why.
]

#subsection[Building a string]

#code(lang: "js", caption: "the slow way and the fast way")[
```js
let out = '';
for (let i = 0; i < 5; i++) out += String.fromCharCode(97 + i);   // 'abcde'

const parts = [];
for (let i = 0; i < 5; i++) parts.push(String.fromCharCode(97 + i));
const joined = parts.join('');                                    // 'abcde'
```
]

#note[
*This is one place where JavaScript is kinder than C++, and you should know why.* In C++
`s = s + c` copies the whole string every round, so $n$ appends cost $O(n^2)$. V8 does not
copy: `out += c` builds a *rope*, a tree of pieces that is flattened once, lazily, when the
string is first read. So `+=` is amortised $O(1)$ already.

Timed in Node with $n = 10^6$ single-character appends:

#table(
  columns: (auto, auto),
  align: (left, right),
  [*method*], [*time*],
  [`out += c`], [51 ms],
  [`parts.push(c)` then `parts.join('')`], [75 ms],
)

So `+=` is fine, and often the faster of the two. Reach for the array-and-join version when
you are assembling *pieces* rather than characters, or when you need the pieces separately
anyway — not because you fear quadratic behaviour.
]

#subsection[Template 1 --- two pointers]

#code(lang: "js", caption: "the palindrome shape")[
```js
const pal = (s) => {
  let i = 0, j = s.length - 1;
  while (i < j) {
    if (s[i] !== s[j]) return false;
    i++; j--;
  }
  return true;
};
// pal('racecar') is true, pal('race') is false
```
]
Loop condition `i < j`, not `i <= j`: when they meet on the middle character there is
nothing left to compare.

#subsection[Template 2 --- the frequency window]

#code(lang: "js", caption: "does t contain a window that matches p's letter counts?")[
```js
const windowEqual = (t, p) => {
  const n = t.length, m = p.length;
  if (m > n) return false;
  const need = new Array(26).fill(0), have = new Array(26).fill(0);
  for (const c of p) need[c.charCodeAt(0) - 97]++;
  const same = () => need.every((v, i) => v === have[i]);
  for (let i = 0; i < n; i++) {
    have[t.charCodeAt(i) - 97]++;                    // the char entering the window
    if (i >= m) have[t.charCodeAt(i - m) - 97]--;    // the char leaving the window
    if (i >= m - 1 && same()) return true;
  }
  return false;
};
// windowEqual('hellobca', 'abc') is true, windowEqual('hello', 'abc') is false
```
]

#formulas(title: "The invariant")[
After the two lines inside the loop, `have` always holds the counts of exactly the window
`t[i-m+1 .. i]`. The `if (i >= m-1)` guard makes sure we only compare once that window is
full.
]

#subsection[Template 3 --- the prefix function (LPS)]

#formulas(title: "What `lps[i]` means")[
`lps[i]` = the length of the longest string that is *both a proper prefix and a proper
suffix* of `p[0..i]`. "Proper" means it is not the whole thing.

For `p = "aabaa"`:

#table(
  columns: (auto,auto,auto,auto,auto,auto),
  align: (left,center,center,center,center,center),
  [*i*], [0], [1], [2], [3], [4],
  [*p\[0..i\]*], [`a`], [`aa`], [`aab`], [`aaba`], [`aabaa`],
  [*lps\[i\]*], [0], [1], [0], [1], [2],
)

`lps[4] = 2` because `"aa"` starts and ends `"aabaa"`.
]

#code(lang: "js", caption: "the prefix function: 8 lines, learn them by heart")[
```js
const buildLPS = (p) => {
  const m = p.length;
  const lps = new Array(m).fill(0);
  let len = 0;                    // length of the border we are extending
  for (let i = 1; i < m; ) {
    if (p[i] === p[len]) lps[i++] = ++len;
    else if (len > 0)    len = lps[len - 1];   // fall back; i does NOT move
    else                 lps[i++] = 0;
  }
  return lps;
};
// buildLPS('ababaca') is [0, 0, 1, 2, 3, 0, 1]
```
]

#trap[
In the middle branch, `i` must *not* advance. That branch is "try a shorter border on the
same character". Advancing `i` there is the classic KMP bug and it silently gives wrong
answers on inputs like `aaab`.
]

#subsection[Template 4 --- rolling hash]

#formulas(title: "Polynomial hashing")[
Treat the string as a number in base $B$:
$ H(s) = s_0 B^(m-1) + s_1 B^(m-2) + ... + s_(m-1) quad (mod M) $

Slide the window one step to the right:
$ H_"new" = (H_"old" - s_"left" dot B^(m-1)) dot B + s_"right" quad (mod M) $

That is $O(1)$ per step. Two substrings with different hashes are certainly different.
Two with the same hash are *probably* equal --- so verify before you trust it.
]

#code(lang: "js", caption: "prefix hashes let you hash ANY substring in O(1)")[
```js
const B = 131n, M = (1n << 61n) - 1n;      // BigInt literals end in n

const buildHash = (s) => {
  const n = s.length;
  const h = new Array(n + 1).fill(0n), pw = new Array(n + 1).fill(1n);
  for (let i = 0; i < n; i++) {
    h[i + 1] = (h[i] * B + BigInt(s.charCodeAt(i))) % M;
    pw[i + 1] = pw[i] * B % M;
  }
  // hash of s[l .. l+len-1], in O(1)
  return (l, len) => (h[l + len] - h[l] * pw[len] % M + M) % M;
};
```
]

#trap[
*A JavaScript number cannot do modular multiplication at all.* Every number is a double,
exact only to `Number.MAX_SAFE_INTEGER` $= 2^53 - 1 approx 9 times 10^15$. Two residues
below even the small modulus $10^9+7$ multiply to about $10^18$, which is a hundred times
past that line, so the product is rounded *before* the `%` ever runs. Tested in Node with
$a = 1000000006$, $b = 999999937$, $M = 10^9+7$:

- `(a * b) % m` gives `64`,
- `(BigInt(a) * BigInt(b)) % BigInt(m)` gives `70`.

The plain version is simply wrong, and it is wrong silently. So every rolling hash in this
chapter uses `BigInt`, and the modulus can then be the good one, $2^61 - 1$, with no extra
machinery — `BigInt` has no upper limit, so C++'s `__int128` dance is not needed.

*The cost is real:* `BigInt` arithmetic runs several times slower than number arithmetic.
Measured in Node, Example 27 on a random string of $n = 3000$ took *632 ms*. That is fine
for the stated limit and far too slow for $n = 10^6$ — which is exactly why Example 27's
follow-up reaches for a suffix automaton instead.
]

#diagram(height: 4.4cm, caption: "which engine to reach for")[
  #dnode(0pt, 1.6cm, 2.7cm, 1.0cm, "string question")
  #darrow(2.8cm, 1.4cm, 4.6cm, 0.45cm, label: "ends")
  #darrow(2.8cm, 1.9cm, 4.6cm, 1.55cm, label: "counts")
  #darrow(2.8cm, 2.3cm, 4.6cm, 2.65cm, label: "find pat")
  #darrow(2.8cm, 2.7cm, 4.6cm, 3.75cm, label: "compare")
  #dnode(4.7cm, 0.05cm, 3.0cm, 0.8cm, "two pointers")
  #dnode(4.7cm, 1.15cm, 3.0cm, 0.8cm, "freq window")
  #dnode(4.7cm, 2.25cm, 3.0cm, 0.8cm, "KMP / Z")
  #dnode(4.7cm, 3.35cm, 3.0cm, 0.8cm, "rolling hash")
  #dnode(8.2cm, 0.05cm, 4.6cm, 0.8cm, "palindrome, reverse", fill: rgb("#f2f2ee"))
  #dnode(8.2cm, 1.15cm, 4.6cm, 0.8cm, "anagram, k distinct", fill: rgb("#f2f2ee"))
  #dnode(8.2cm, 2.25cm, 4.6cm, 0.8cm, "search, period, border", fill: rgb("#f2f2ee"))
  #dnode(8.2cm, 3.35cm, 4.6cm, 0.8cm, "distinct / repeated subs", fill: rgb("#f2f2ee"))
  #darrow(7.8cm, 0.45cm, 8.1cm, 0.45cm)
  #darrow(7.8cm, 1.55cm, 8.1cm, 1.55cm)
  #darrow(7.8cm, 2.65cm, 8.1cm, 2.65cm)
  #darrow(7.8cm, 3.75cm, 8.1cm, 3.75cm)
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Reverse a string in place, and separately write a palindrome check.
Constraints: $n <= 10^6$. Target: $O(n)$, $O(1)$ extra space.
Edge cases: empty string, one character.
]
#sol[
#code(lang: "js", caption: "both are the same two-pointer walk")[
```js
const reverseString = (s) => [...s].reverse().join('');

const isPalindrome = (s) => {
  let i = 0, j = s.length - 1;
  while (i < j) { if (s[i] !== s[j]) return false; i++; j--; }
  return true;
};
```
]
`reverseString("placement")` gives `tnemecalp`.
`isPalindrome` on `"level"`, `"levels"`, `""`, `"z"` gives `true false true true`.
The empty string and a one-character string are palindromes: the loop never runs.
#complexity(time: $O(n)$, space: $O(1)$)
]
#ans[`tnemecalp`; `true false true true`]

#ex(2, tier: 0, asked: "warm-up")[
Count how many times each lowercase letter appears in `"banana"`.
]
#sol[
#code(lang: "js", caption: "26-slot frequency array")[
```js
const freq26 = (s) => {
  const f = new Array(26).fill(0);
  for (const c of s) f[c.charCodeAt(0) - 97]++;
  return f;
};
// banana -> a=3  b=1  n=2  z=0
```
]
`c - 'a'` maps `'a'` to 0 and `'z'` to 25. A 26-integer array is far faster than a hash map
and is the right choice whenever the alphabet is fixed.
#complexity(time: $O(n)$, space: $O(1)$, note: "26 slots is constant space, no matter how long the string is.")
]
#ans[a=3, b=1, n=2]

#ex(3, tier: 0, asked: "TCS NQT · pattern")[
Find the first position where `p` appears inside `t`, or $-1$.
Constraints: $n, m <= 10^3$ for now. Edge cases: empty pattern, pattern longer than text.
]
#sol[
#code(lang: "js", caption: "naive search: try every start")[
```js
const naiveFind = (t, p) => {
  const n = t.length, m = p.length;
  if (m === 0) return 0;                   // empty pattern matches at 0
  for (let i = 0; i + m <= n; i++) {       // i + m <= n, never i < n
    let j = 0;
    while (j < m && t[i + j] === p[j]) j++;
    if (j === m) return i;
  }
  return -1;
};
```
]
#table(
  columns: (auto, auto, auto),
  align: (left, left, center),
  [*text*], [*pattern*], [*answer*],
  [`abracadabra`], [`cad`], [4],
  [`aaaa`], [`aab`], [-1],
  [`abc`], [`""`], [0],
  [`""`], [`x`], [-1],
)
#complexity(time: $O(n m)$, space: $O(1)$, note: "Worst case: t = aaaa...a, p = aaa...ab. Every start matches m-1 characters and then fails. KMP fixes exactly this.")
]
#ans[4]

#ex(4, tier: 0, asked: "warm-up")[
Clean a string: keep only letters and digits, and force everything to lowercase.
`"A man, a Plan!! 42"`.
]
#sol[
#code(lang: "js", caption: "normalise")[
```js
const normalise = (s) => [...s.toLowerCase()].filter(c => /[a-z0-9]/.test(c)).join('');
// 'A man, a Plan!! 42' -> 'amanaplan42'
```
]
#complexity(time: $O(n)$, space: $O(n)$)
]
#ans[`amanaplan42`]

#ex(5, tier: 0, asked: "Infosys · pattern")[
Split a sentence on spaces. Extra spaces must not create empty words.
`"  the  quick brown  "`.
]
#sol[
#code(lang: "js", caption: "split, then throw away the empty pieces")[
```js
const splitWords = (s) => s.split(' ').filter(w => w.length > 0);
```
]
Result: 3 words --- `[the][quick][brown]`.
#trap[
*`.split(' ')` alone is not enough.* It keeps every empty piece between two spaces. Tested
in Node: `'  the  quick'.split(' ')` gives `['', '', 'the', '', 'quick']`. The
`.filter(w => w.length > 0)` is what turns that into `['the', 'quick']`, and it is the
whole warm-up.

`.split(/\s+/)` collapses the runs but still leaves one empty piece at the front when the
string starts with a space: `['', 'the', 'quick']`. Filter either way.
]
#complexity(time: $O(n)$, space: $O(n)$)
]
#ans[`the quick brown` (3 words)]

#ex(6, tier: 0, asked: "warm-up")[
Are two strings anagrams of each other?
Constraints: lowercase letters only, $n <= 10^5$. Target: $O(n)$.
Edge cases: different lengths, both empty.
]
#sol[
#code(lang: "js", caption: "count up, count down")[
```js
const isAnagram = (a, b) => {
  if (a.length !== b.length) return false;    // the cheapest rejection first
  const f = new Array(26).fill(0);
  for (const c of a) f[c.charCodeAt(0) - 97]++;
  for (const c of b) if (--f[c.charCodeAt(0) - 97] < 0) return false;
  return true;
};
```
]
`("listen","silent")` is `true`, `("aab","abb")` is `false`, `("","")` is `true`,
`("ab","abc")` is `false`.
Going negative means `b` has more copies of that letter than `a` --- and since the lengths
match, that is enough to reject without a second scan.
#complexity(time: $O(n)$, space: $O(1)$)
]
#ans[`true false true false`]

#section[The everyday string problems]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
Return the first character that appears exactly once. `"swiss"`.
Constraints: $n <= 10^5$, lowercase. Target: $O(n)$.
Edge cases: no such character; one-character string.
]
#sol[
#approach(1, "Check each character against all others", verdict: "O(n^2)")
#code(lang: "js", caption: "brute force")[
```js
const firstUnique_brute = (s) => {
  for (let i = 0; i < s.length; i++) {
    let seen = false;
    for (let j = 0; j < s.length; j++)
      if (i !== j && s[i] === s[j]) { seen = true; break; }
    if (!seen) return s[i];
  }
  return '#';
};
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(3, "Count once, then scan once", verdict: "O(n), optimal")
#code(lang: "js", caption: "two passes, both linear")[
```js
const firstUnique_count = (s) => {
  const f = new Array(26).fill(0);
  for (const c of s) f[c.charCodeAt(0) - 97]++;                    // pass 1: counts
  for (const c of s) if (f[c.charCodeAt(0) - 97] === 1) return c;  // pass 2: original order
  return '#';
};
```
]
#complexity(time: $O(n)$, space: $O(1)$)

`"swiss"` gives `w` from both. `"aabb"` gives the sentinel `#`. `"q"` gives `q`.

#formulas(title: "Why the second pass must walk the string, not the array")[
Scanning `f[0..25]` would give the alphabetically first unique letter, not the
*positionally* first one. On `"swiss"` that would wrongly answer `i` instead of `w`.
]
The idea that unlocked it: *separate "how many" from "where".* One pass answers the first,
one pass answers the second.
]
#ans[`w`]

#ex(8, tier: 1, asked: "Accenture · pattern")[
Are two strings anagrams? Give two solutions and compare them.
Constraints: $n <= 10^5$. Edge cases: different lengths; empty strings.
]
#sol[
#approach(1, "Sort both and compare", verdict: "O(n log n), 3 lines")
#code(lang: "js", caption: "the one-liner answer")[
```js
const anagram_sort = (a, b) => {
  if (a.length !== b.length) return false;
  return [...a].sort().join('') === [...b].sort().join('');
};
```
]
#complexity(time: $O(n log n)$, space: $O(n)$, note: "[...a] copies first, so the caller's string is untouched — strings are immutable anyway, and the array copy is what makes sorting possible at all.")

#approach(3, "Count the letters", verdict: "O(n), optimal")
#code(lang: "js", caption: "counting")[
```js
const anagram_count = (a, b) => {
  if (a.length !== b.length) return false;
  const f = new Array(26).fill(0);
  for (const c of a) f[c.charCodeAt(0) - 97]++;
  for (const c of b) if (--f[c.charCodeAt(0) - 97] < 0) return false;
  return true;
};
```
]
#complexity(time: $O(n)$, space: $O(1)$)

Both said `true` for `("listen","silent")`, `false` for `("rat","car")`, and `true` for
two empty strings. Cross-checked against each other on 2000 random pairs.

#trick[
Say the sorting answer first, then immediately offer the counting one. Interviewers like
seeing that you know both and can name the trade-off: sorting works for *any* alphabet
including Unicode; counting needs a fixed small alphabet but is linear.
]
#note[
`[...a].sort()` with no comparator is *correct* here — these are single characters and the
default sort compares them as text. That same bare `.sort()` on numbers is the most common
JavaScript bug there is. See the trap in Example 21.
]
]
#ans[both correct; counting is $O(n)$]

#ex(9, tier: 1, asked: "Wipro · pattern")[
Longest common prefix of a list of words. `{flowchart, flower, flow}`.
Constraints: up to $10^4$ words, each up to 200 characters. Edge cases: empty list; no common
prefix at all; one word.
]
#sol[
#approach(1, "Shrink a running prefix", verdict: "O(total length)")
#code(lang: "js", caption: "compare the answer against each word in turn")[
```js
const lcp_pairwise = (v) => {
  if (v.length === 0) return '';
  let best = v[0];
  for (let i = 1; i < v.length; i++) {
    let k = 0;
    while (k < best.length && k < v[i].length && best[k] === v[i][k]) k++;
    best = best.slice(0, k);
    if (best === '') break;             // cannot get shorter than nothing
  }
  return best;
};
```
]
#approach(2, "Vertical scan", verdict: "same cost, often faster in practice")
#code(lang: "js", caption: "column by column, stop at the first disagreement")[
```js
const lcp_vertical = (v) => {
  if (v.length === 0) return '';
  for (let k = 0; k < v[0].length; k++) {
    const c = v[0][k];
    for (let i = 1; i < v.length; i++)
      if (k >= v[i].length || v[i][k] !== c) return v[0].slice(0, k);
  }
  return v[0];
};
```
]
Both give `flow`. `{dog, cat}` gives the empty string. `{solo}` gives `solo`.
#complexity(time: $O(S)$, space: $O(1)$, note: "S = total characters. Vertical stops as soon as one column disagrees, so on 10^4 words sharing nothing it reads only 10^4 characters.")

#trap[
Reading past the end of a JavaScript string does *not* crash — `'abc'[9]` is `undefined`.
That sounds safer than C++, and it is worse for you: the bug survives testing instead of
dying loudly. Here `undefined !== c` is true, so the code happens to give the right answer,
but the same pattern silently returns `NaN` the moment arithmetic is involved. Keep the
`k >= v[i].length` check first and *mean* it.
]
]
#ans[`flow`]

#ex(10, tier: 1, asked: "Capgemini · pattern")[
Reverse the order of words in a sentence and squeeze extra spaces.
`"  the sky  is blue "` becomes `"blue is sky the"`.
Constraints: $n <= 10^5$. Edge cases: one word; only spaces.
]
#sol[
#approach(1, "Split into an array, then join backwards", verdict: "O(n) time, O(n) extra space")
#code(lang: "js", caption: "split, then join backwards")[
```js
const reverseWords = (s) => s.split(' ').filter(w => w.length > 0).reverse().join(' ');
```
]
`"word"` gives `word`. `"   "` gives the empty string.
#complexity(time: $O(n)$, space: $O(n)$, note: "The array of words is the extra space; on a 10^5-character sentence that is another 10^5 characters plus array overhead.")

#approach(3, "Reverse twice, in place", verdict: "O(n) time, O(1) extra space")
#formulas(title: "The double reversal")[
+ Squeeze the spaces so words are separated by exactly one space.
+ Reverse the *whole* string. Now the words are in the right order but each one is
  spelled backwards.
+ Reverse each word back.

`"the sky"` $->$ `"the sky"` $->$ `"yks eht"` $->$ `"sky the"`.
]
#code(lang: "js", caption: "one character array, a read pointer and a write pointer")[
```js
const reverseRange = (a, l, r) => {
  while (l < r) { [a[l], a[r]] = [a[r], a[l]]; l++; r--; }
};

const reverseWords_inplace = (s) => {
  const a = [...s];                        // strings are immutable: work on an array
  const n = a.length;
  let w = 0, i = 0;
  while (i < n) {                          // 1. squeeze spaces
    while (i < n && a[i] === ' ') i++;
    if (i === n) break;
    if (w) a[w++] = ' ';
    while (i < n && a[i] !== ' ') a[w++] = a[i++];
  }
  a.length = w;                            // drop the tail
  reverseRange(a, 0, a.length - 1);        // 2. reverse everything
  let st = 0;                              // 3. reverse each word back
  for (let k = 0; k <= a.length; k++)
    if (k === a.length || a[k] === ' ') {
      reverseRange(a, st, k - 1);
      st = k + 1;
    }
  return a.join('');
};
```
]
#complexity(time: $O(n)$, space: $O(1)$, note: "The string is modified in place; only the counters are extra.")

Both versions turned `"  the sky  is blue "` into `blue is sky the`, `"word"` into `word`,
and `"   "` into the empty string. A randomised check on 400 random sentences (random
letters and spaces) gave identical results every time.

#trap[
The loop in step 3 runs to `k <= a.length`, one past the end, so the *last* word (which
has no space after it) also gets reversed. Stopping at `k < a.length` leaves the last word
spelled backwards.
]
]
#ans[`blue is sky the`]

#ex(11, tier: 1, asked: "Cognizant · pattern")[
Count how many times `p` occurs in `t`. Occurrences may *overlap*.
`t = "aaaa"`, `p = "aa"`.
Constraints: $n, m <= 10^4$. Edge cases: empty pattern; pattern longer than text.
]
#sol[
#code(lang: "js", caption: "count, do not stop at the first hit")[
```js
const countOccurrences = (t, p) => {
  if (p.length === 0 || p.length > t.length) return 0;
  let c = 0;
  for (let i = 0; i + p.length <= t.length; i++) {
    let j = 0;
    while (j < p.length && t[i + j] === p[j]) j++;
    if (j === p.length) c++;
  }
  return c;
};
```
]
#table(
  columns: (auto, auto, auto, 1fr),
  align: (left, left, center, left),
  [*t*], [*p*], [*count*], [*why*],
  [`aaaa`], [`aa`], [3], [starts 0, 1, 2 --- they overlap],
  [`abcabc`], [`abc`], [2], [starts 0, 3],
  [`abc`], [`z`], [0], [--],
  [`a`], [`abc`], [0], [pattern too long],
)
#complexity(time: $O(n m)$, space: $O(1)$, note: "Example 17 does the same job in O(n + m) with KMP. Note there is no built-in overlapping count in JavaScript — String.replaceAll and a global regex both skip past each match.")

#trap[
Advancing `i` by `p.size()` after a hit gives 2 instead of 3 on `aaaa`/`aa`. Read the
question: "may overlap" means `i++`, always.
]
]
#ans[3]

#ex(12, tier: 1, asked: "TCS Digital · pattern")[
Run-length encode a string: `"aaabbbbcd"` becomes `"a3b4c1d1"`. Then make a version that
returns the original if the encoding is not shorter.
Edge cases: empty string; no repeats at all.
]
#sol[
#code(lang: "js", caption: "group equal neighbours")[
```js
const rle = (s) => {
  const out = [];
  let i = 0;
  while (i < s.length) {
    let j = i;
    while (j < s.length && s[j] === s[i]) j++;   // j lands past the run
    out.push(s[i], String(j - i));
    i = j;
  }
  return out.join('');
};

const rleSafe = (s) => {
  const e = rle(s);
  return e.length < s.length ? e : s;
};
```
]
`rle("aaabbbbcd")` gives `a3b4c1d1`. `rleSafe("abc")` returns `abc` unchanged (the encoding
`a1b1c1` is longer). `rle("")` gives the empty string.
#complexity(time: $O(n)$, space: $O(n)$, note: "The inner while never re-reads a character: i jumps straight to j.")
]
#ans[`a3b4c1d1`]

#ex(13, tier: 1, asked: "Adobe · pattern")[
Is `b` a rotation of `a`? `("abcde","cdeab")` is yes; `("abcde","abced")` is no.
Constraints: $n <= 10^5$. Edge cases: different lengths; both empty.
]
#sol[
#approach(1, "Build every rotation and compare", verdict: "O(n^2)")
#code(lang: "js", caption: "brute force")[
```js
const isRotation_brute = (a, b) => {
  const n = a.length;
  if (b.length !== n) return false;
  if (n === 0) return true;
  for (let k = 0; k < n; k++) {             // k = how far we rotated
    let ok = true;
    for (let i = 0; i < n; i++)
      if (a[(k + i) % n] !== b[i]) { ok = false; break; }
    if (ok) return true;
  }
  return false;
};
```
]
#complexity(time: $O(n^2)$, space: $O(1)$, note: "The modulo trick avoids building the rotated string, but there are still n starts times n characters.")

#approach(3, "Double the string and search once", verdict: "O(n), optimal")
#formulas(title: "The one-line insight")[
Every rotation of `a` is a substring of `a + a`.

`a = "abcde"` $=>$ `a + a = "abcdeabcde"`, which contains `bcdea`, `cdeab`, `deabc`,
`eabcd` --- exactly the rotations, and nothing else of length 5 that is not a rotation.
]
#code(lang: "js", caption: "double and search")[
```js
const isRotation = (a, b) => {
  if (a.length !== b.length) return false;  // essential, see the trap below
  if (a.length === 0) return true;
  return (a + a).includes(b);
};
```
]
Both versions gave `true` for `("abcde","cdeab")`, `false` for `("abcde","abced")` and
`true` for two empty strings. The four tests in the question give
`true false true false`, and the two versions agreed on 2000 random pairs.
#complexity(time: $O(n)$, space: $O(n)$, note: "V8's String.prototype.includes is not guaranteed linear — on an adversarial input it can degrade. Use kmpSearch when the worst case must be provable.")

#trap[
The length check is not optional. Drop it and `isRotation("abcabc","abc")` returns `true`,
because `"abcabcabcabc"` really does contain `"abc"` --- but `"abc"` is not a rotation of a
six-character string. Tested: with the check in place it correctly returns `false`.
]
]
#ans[`true false true false`]

#ex(14, tier: 1, asked: "Amazon · pattern")[
Longest palindromic substring. `"babadada"`.
Constraints: $n <= 2000$ for the $O(n^2)$ answer. Target: beat $O(n^3)$.
Edge cases: even-length palindrome; empty string; all characters different.
]
#sol[
#approach(1, "Try every substring and test it", verdict: "O(n^3)")
#code(lang: "js", caption: "brute force, used as the reference")[
```js
const lps_brute = (s) => {
  let best = '';
  for (let i = 0; i < s.length; i++)
    for (let j = i; j < s.length; j++) {
      let ok = true;
      for (let a = i, b = j; a < b; a++, b--)
        if (s[a] !== s[b]) { ok = false; break; }
      if (ok && j - i + 1 > best.length) best = s.slice(i, j + 1);
    }
  return best;
};
```
]
#complexity(time: $O(n^3)$, space: $O(1)$, note: "n = 2000 gives 8 * 10^9 character reads. Far too slow.")

#approach(3, "Expand around every centre", verdict: "O(n^2), the interview answer")
#formulas(title: "Counting the centres")[
A palindrome is decided by its centre. There are $2n - 1$ centres: $n$ single characters
(odd lengths) and $n-1$ gaps between characters (even lengths). From each centre, push
outwards while the two sides match.
]
#code(lang: "js", caption: "expand around centre")[
```js
const lps_expand = (s) => {
  if (s.length === 0) return '';
  let bestL = 0, bestLen = 1;
  const grow = (l, r) => {
    while (l >= 0 && r < s.length && s[l] === s[r]) { l--; r++; }
    const len = r - l - 1;           // l and r each stepped one too far
    if (len > bestLen) { bestLen = len; bestL = l + 1; }
  };
  for (let i = 0; i < s.length; i++) {
    grow(i, i);        // odd centre
    grow(i, i + 1);    // even centre
  }
  return s.slice(bestL, bestL + bestLen);
};
```
]
#complexity(time: $O(n^2)$, space: $O(1)$, note: "Only 2n-1 centres, each expanding at most n/2 steps.")

Both versions return `adada` for `"babadada"`. `"cbbd"` gives `bb` (an even centre).
`"x"` gives `x`. `""` gives `""`.
A randomised check against the brute force on 300 random strings matched every time.

#trap[
`int len = r - l - 1`, not `r - l + 1`. The `while` exits only *after* `l` and `r` have
both moved one step too far, so the real span is `[l+1, r-1]`, of length `r - l - 1`.
Getting this wrong is the number-one bug here.
]
Example 29 does the same job in $O(n)$ with Manacher's algorithm.
]
#ans[`adada`]

#ex(15, tier: 1, asked: "Infosys · pattern")[
Is a sentence a palindrome if you ignore case and everything that is not a letter or digit?
`"A man, a plan, a canal: Panama"`.
Edge cases: empty string; a string of only punctuation.
]
#sol[
#code(lang: "js", caption: "two pointers that skip junk")[
```js
const alnum = (c) => c !== undefined && /[a-z0-9]/i.test(c);

const cleanPalindrome = (s) => {
  let i = 0, j = s.length - 1;
  while (i < j) {
    while (i < j && !alnum(s[i])) i++;
    while (i < j && !alnum(s[j])) j--;
    if (s[i].toLowerCase() !== s[j].toLowerCase()) return false;
    i++; j--;
  }
  return true;
};
```
]
`("A man, a plan, a canal: Panama")` is `true`, `"hello"` is `false`, `""` is `true`,
`".,"` is `true`. `"0P"` is `false` --- a digit and a letter never match.
#complexity(time: $O(n)$, space: $O(1)$, note: "Beats the 'clean into a new string then check' version, which needs O(n) extra space.")

#trap[
The skip loops carry `i < j` inside them. Without it, a string of pure punctuation runs `i`
past `j`, and in JavaScript `s[i]` is then `undefined` — so `.toLowerCase()` throws
`TypeError: Cannot read properties of undefined`. The `alnum` helper guards against
`undefined` for the same reason.
]
]
#ans[`true false true true`]

#ex(16, tier: 1, asked: "Microsoft · pattern")[
Compress a character array *in place*: `xxxyzz` becomes `x3yz2` (a run of 1 keeps no
number). Return the new length.
Constraints: $n <= 10^5$. Edge cases: single character; no repeats; a run longer than 9.
]
#sol[
#approach(1, "Build the answer in a new string, then copy back", verdict: "O(n) time, O(n) extra space")
#code(lang: "js", caption: "easy to get right, but it breaks the 'in place' rule")[
```js
const compress_extra = (a) => {
  const out = [];
  let i = 0;
  while (i < a.length) {
    let j = i;
    while (j < a.length && a[j] === a[i]) j++;
    out.push(a[i]);
    if (j - i > 1) out.push(...String(j - i));
    i = j;
  }
  for (let k = 0; k < out.length; k++) a[k] = out[k];
  return out.length;
};
```
]
#complexity(time: $O(n)$, space: $O(n)$, note: "Produced byte-identical output to the in-place version on the test input.")

#approach(3, "Two pointers in the same array", verdict: "O(n) time, O(1) extra space")
#code(lang: "js", caption: "read pointer and write pointer in one array")[
```js
const compress = (a) => {
  const n = a.length;
  let w = 0, i = 0;
  while (i < n) {
    let j = i;
    while (j < n && a[j] === a[i]) j++;
    a[w++] = a[i];
    if (j - i > 1)
      for (const c of String(j - i)) a[w++] = c;   // 12 -> '1' then '2'
    i = j;
  }
  return w;
};
```
]
`{x,x,x,y,z,z}` gives length 5 and `x3yz2`. `{p}` gives length 1 and `p`.
#complexity(time: $O(n)$, space: $O(1)$, note: "w never passes i, so the write pointer can never overwrite unread data.")

#formulas(title: "Why the write pointer is always safe")[
After finishing a run of length $L$, the read pointer has passed $L$ cells and the write
pointer has used $1 + ("digits of" L)$ cells. For $L = 1$ that is $1 <= 1$; for $L >= 2$
the digit count is at most $L - 1$. So `w <= i` always holds.
]
]
#ans[length 5, `x3yz2`]

#section[Real search and real windows]
#tier-header(2)

#ex(17, tier: 2, asked: "Shopee · pattern")[
Find *every* start position of `p` inside `t`, in $O(n + m)$.
`t = "abababacaba"`, `p = "ababaca"`.
Constraints: $n <= 10^6$, $m <= 10^5$. Edge cases: overlapping matches; empty pattern;
pattern longer than the text.

*Follow-up:* "why is it linear when the inner loop can run many times?"
]
#sol[
#approach(1, "Naive: try every start", verdict: "O(n m), fails on aaaa...a")
#code(lang: "js", caption: "the baseline, also used to verify KMP")[
```js
const naiveSearch = (t, p) => {
  const hits = [];
  if (p.length === 0 || p.length > t.length) return hits;
  for (let i = 0; i + p.length <= t.length; i++) {
    let j = 0;
    while (j < p.length && t[i + j] === p[j]) j++;
    if (j === p.length) hits.push(i);
  }
  return hits;
};
```
]
#complexity(time: $O(n m)$, space: $O(1)$, note: "t = a^10^6 and p = a^10^5 b costs 10^11 character reads.")

#approach(3, "KMP", verdict: "O(n + m), optimal")
#formulas(title: "What KMP fixes")[
The naive version throws away everything it learned. After matching `ababa` and failing on
the next character, it restarts at position 1 and re-reads `baba`.

But we already know the matched part is `ababa`, and `ababa` ends with `aba`, which is also
how it *starts*. So we can jump the pattern forward and keep those 3 characters. That jump
length is exactly `lps[j-1]`. The text pointer `i` never moves backwards.
]
#code(lang: "js", caption: "KMP search, using buildLPS from the pattern page")[
```js
const kmpSearch = (t, p) => {
  const hits = [];
  if (p.length === 0 || p.length > t.length) return hits;
  const lps = buildLPS(p);
  const n = t.length, m = p.length;
  let i = 0, j = 0;
  while (i < n) {
    if (t[i] === p[j]) {
      i++; j++;
      if (j === m) { hits.push(i - m); j = lps[j - 1]; }   // keep going
    } else if (j > 0) j = lps[j - 1];    // slide the pattern, i stays put
    else i++;                            // no partial match at all
  }
  return hits;
};
```
]
#complexity(time: $O(n + m)$, space: $O(m)$, note: "buildLPS is O(m), the search is O(n).")

Results: `"abababacaba"` / `"ababaca"` gives `2`. `"aaaa"` / `"aa"` gives `0 1 2`
(overlaps kept, because after a hit `j` drops to `lps[m-1]` instead of 0).
Empty pattern and too-long pattern both give no hits.
A randomised cross-check against the naive search on 500 random cases matched every time.

*The follow-up, answered.* Look at `i + j`. Every `if` branch either increases `i` (first
and third branch) or decreases `j` (second branch), and `j` never rises faster than `i`.
So `i + j` strictly increases at every step and is bounded by $2n$. That caps the total
number of steps at $2n$, no matter how much the inner fallback fires.

#subsection[Python version]
#code(lang: "python", caption: "KMP in Python")[
```python
def build_lps(p):
    lps = [0] * len(p)
    length, i = 0, 1
    while i < len(p):
        if p[i] == p[length]:
            length += 1
            lps[i] = length
            i += 1
        elif length > 0:
            length = lps[length - 1]
        else:
            lps[i] = 0
            i += 1
    return lps

def kmp_search(t, p):
    if not p or len(p) > len(t):
        return []
    lps = build_lps(p)
    hits, i, j = [], 0, 0
    while i < len(t):
        if t[i] == p[j]:
            i += 1; j += 1
            if j == len(p):
                hits.append(i - j)
                j = lps[j - 1]
        elif j > 0:
            j = lps[j - 1]
        else:
            i += 1
    return hits

print(build_lps("aabaa"))                    # [0, 1, 0, 1, 2]
print(kmp_search("aabaabaaa", "aabaa"))      # [0, 3]
print(kmp_search("aaaa", "aa"))              # [0, 1, 2]
```
]
]
#ans[`2`]

#ex(18, tier: 2, asked: "Sea/Shopee · pattern")[
Search for a pattern with a rolling hash instead of KMP. Explain when each is the better
choice.
Constraints: $n <= 10^6$. Edge cases: hash collision; pattern equal to the whole text.
]
#sol[
#code(lang: "js", caption: "Rabin-Karp with verification")[
```js
const rabinKarp = (t, p) => {
  const hits = [];
  const n = t.length, m = p.length;
  if (m === 0 || m > n) return hits;
  const B = 131n, M = (1n << 61n) - 1n;
  let ph = 0n, th = 0n, power = 1n;
  for (let i = 0; i < m; i++) {
    ph = (ph * B + BigInt(p.charCodeAt(i))) % M;
    th = (th * B + BigInt(t.charCodeAt(i))) % M;
    if (i) power = power * B % M;                            // ends up as B^(m-1)
  }
  for (let i = 0; ; i++) {
    if (ph === th && t.startsWith(p, i)) hits.push(i);       // verify, never trust
    if (i + m >= n) break;
    th = (th - BigInt(t.charCodeAt(i)) * power % M + M) % M;  // drop the leaving char
    th = (th * B + BigInt(t.charCodeAt(i + m))) % M;          // add the entering char
  }
  return hits;
};
```
]
#complexity(time: [$O(n + m)$ expected], space: $O(1)$, note: "Worst case O(n m) if an adversary crafts collisions. The verify step keeps it CORRECT, just slower.")

Results matched KMP exactly: `2` for the main case, `0 1 2` for `aaaa`/`aa`, `0` for
`abc`/`abc`. A randomised cross-check against the naive search on 500 cases matched every
time.

#formulas(title: "Line by line, the slide")[
Window is `t[i .. i+m-1]` with hash `th`.
+ `th - t[i] * power` removes the leading character's contribution $t_i B^(m-1)$.
+ `+ M` before `% M` keeps the value non-negative --- JavaScript `%` keeps the sign of the
  left operand, so `-5n % 3n` is `-2n`, not `1n`. This is a *remainder*, not a mathematical
  modulo, and it bites in exactly this line.
+ `* B` shifts every remaining character up one power.
+ `+ t[i+m]` adds the new last character.
]

#table(
  columns: (auto, 1fr, 1fr),
  align: (left, left, left),
  [], [*KMP*], [*Rabin-Karp*],
  [worst case], [$O(n+m)$ guaranteed], [$O(n m)$ if attacked],
  [extra memory], [$O(m)$], [$O(1)$],
  [multiple patterns], [one LPS per pattern], [one hash set, all at once],
  [2-D / substring compare], [awkward], [natural],
  [interview safety], [always correct], [say "and I verify on a hash match"],
)

#trap[
Never `return` on a hash match without comparing the characters. With $M = 10^9+7$ and
$10^6$ windows, the chance of at least one collision is roughly
$10^6 slash 10^9 = 0.1%$ per pattern --- small, but judges run many tests.
]
]
#ans[same hit lists as KMP, expected $O(n+m)$]

#ex(19, tier: 2, asked: "Grab · pattern")[
Find every start index in `t` where an anagram of `p` begins.
`t = "cbaebabacd"`, `p = "abc"`.
Constraints: $n <= 10^5$, lowercase only. Target: $O(n)$.
Edge cases: `p` longer than `t`; overlapping windows.
]
#sol[
#approach(1, "Rebuild the counts for every window", verdict: "O(n m)")
#code(lang: "js", caption: "brute force: recount all m characters at each start")[
```js
const anagramStarts_brute = (t, p) => {
  const out = [];
  const n = t.length, m = p.length;
  if (m === 0 || m > n) return out;
  const need = new Array(26).fill(0);
  for (const c of p) need[c.charCodeAt(0) - 97]++;
  for (let i = 0; i + m <= n; i++) {
    const have = new Array(26).fill(0);
    for (let j = 0; j < m; j++) have[t.charCodeAt(i + j) - 97]++;   // the waste
    if (need.every((v, k) => v === have[k])) out.push(i);
  }
  return out;
};
```
]
#complexity(time: $O(n m)$, space: $O(1)$, note: "Two neighbouring windows share m-1 characters, and this version recounts all of them.")

#approach(3, "Slide the window, update two counters", verdict: "O(n), optimal")
#code(lang: "js", caption: "fixed-size frequency window")[
```js
const anagramStarts = (t, p) => {
  const out = [];
  const n = t.length, m = p.length;
  if (m === 0 || m > n) return out;
  const need = new Array(26).fill(0), have = new Array(26).fill(0);
  for (const c of p) need[c.charCodeAt(0) - 97]++;
  const same = () => need.every((v, k) => v === have[k]);
  for (let i = 0; i < n; i++) {
    have[t.charCodeAt(i) - 97]++;                    // char entering
    if (i >= m) have[t.charCodeAt(i - m) - 97]--;    // char leaving
    if (i >= m - 1 && same()) out.push(i - m + 1);
  }
  return out;
};
```
]
Trace of the window on `"cbaebabacd"` with `p = "abc"` (window length 3):

#table(
  columns: (auto, auto, auto, 1fr),
  align: (center, center, center, left),
  [*i*], [*window*], [*counts a/b/c*], [*match?*],
  [2], [`cba`], [1/1/1], [yes $->$ record start 0],
  [3], [`bae`], [1/1/0], [no],
  [4], [`aeb`], [1/1/0], [no],
  [5], [`eba`], [1/1/0], [no],
  [6], [`bab`], [1/2/0], [no],
  [7], [`aba`], [2/1/0], [no],
  [8], [`bac`], [1/1/1], [yes $->$ record start 6],
  [9], [`acd`], [1/0/1], [no],
)
Answer `0 6` from both versions. `("aaa","aa")` gives `0 1`. `("abcd","xy")` gives nothing.
#complexity(time: $O(26 n)$, space: $O(1)$, note: "The need.every(...) call is 26 comparisons, a constant. Track a 'matched letters' counter to make it a true O(n) if asked.")

#trick[
To drop the 26-per-step factor, keep an integer `matched` counting how many of the 26
letters currently have `have[c] == need[c]`. Update it only for the two letters that change
each step, and test `matched == 26`. Same idea as Example 24.
]
]
#ans[`0 6`]

#ex(20, tier: 2, asked: "Agoda · pattern")[
Longest substring with no repeated character. `"pwwkew"`.
Constraints: $n <= 10^5$, any ASCII. Target: $O(n)$.
Edge cases: empty string; all characters the same; all different.
]
#sol[
#approach(1, "Start at every index, extend while unique", verdict: "O(n^2)")
#code(lang: "js", caption: "brute force")[
```js
const longestUnique_brute = (s) => {
  const n = s.length;
  let best = 0;
  for (let i = 0; i < n; i++) {
    const seen = new Set();
    for (let j = i; j < n; j++) {
      if (seen.has(s[j])) break;
      seen.add(s[j]);
      best = Math.max(best, j - i + 1);
    }
  }
  return best;
};
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(3, "Sliding window with last-seen positions", verdict: "O(n), optimal")
#formulas(title: "The invariant")[
`s[left .. i]` always has no repeat. When `s[i]` was last seen at position `q` and
`q >= left`, the only way to stay legal is to jump `left` to `q + 1`.
`left` never moves backwards, so each index is visited once.
]
#code(lang: "js", caption: "one pass, jump the left edge")[
```js
const longestUnique_window = (s) => {
  const last = new Map();               // character -> last index it was seen at
  let best = 0, left = 0;
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (last.has(c) && last.get(c) >= left) left = last.get(c) + 1;
    last.set(c, i);
    best = Math.max(best, i - left + 1);
  }
  return best;
};
```
]
#complexity(time: $O(n)$, space: $O(|"alphabet"|)$, note: "The Map holds one entry per distinct character seen — 256 for bytes, but it grows with the alphabet rather than being fixed.")

`"pwwkew"` gives 3 from both (`wke`). `""` gives 0, `"bbbb"` gives 1, `"abcdef"` gives 6.
A randomised cross-check on 400 random strings matched every time.

#trap[
`last.get(c) >= left` --- not merely `last.has(c)`. A character seen long ago, *before*
`left`, is not inside the window and must not move the left edge. Tested: on `"abba"` the
`has`-only version answers 1 instead of the correct 2.
]

#note[
A `Map` is the right container here, not a 256-slot array. The problem says "any ASCII",
but the same code then works unchanged for Unicode, and `Map` keeps the key's real type
instead of stringifying it the way a plain object would.
]
]
#ans[3]

#ex(21, tier: 2, asked: "Razer · pattern")[
Group words that are anagrams of each other.
`{tea, eat, tan, ate, nat, bat}`.
Constraints: $10^4$ words, each up to 100 characters. Edge cases: no anagrams at all;
words of different lengths.
]
#sol[
#code(lang: "js", caption: "the sorted word is the group key")[
```js
const groupAnagrams = (v) => {
  const g = new Map();
  for (const s of v) {
    const k = [...s].sort().join('');    // 'tea', 'eat', 'ate' all become 'aet'
    if (!g.has(k)) g.set(k, []);
    g.get(k).push(s);
  }
  return [...g.keys()].sort().map(k => g.get(k));   // sort the keys: reproducible output
};
```
]
Output: `{bat} {tea eat ate} {tan nat}`.
#complexity(time: $O(N L log L)$, space: $O(N L)$, note: "N words of length L. Sorting each key costs L log L.")

#trick[
A faster key when the alphabet is small: the 26 counts joined with separators, e.g.
`"1#0#0#..."`. That builds the key in $O(L + 26)$ instead of $O(L log L)$. Worth
mentioning; only worth coding if $L$ is large.
]

#trap[
*JavaScript has no ordered map.* A `Map` iterates in *insertion* order and a plain object
iterates in a rule-based order that puts integer-like keys first. Neither is key order, so
neither is reproducible for a judge that compares output text. The fix is the last line:
`[...g.keys()].sort()` before you read the groups out.
]

#note[
Use a `Map`, not a plain object, for the groups. A plain object turns every key into a
string (so the number `1` and the text `'1'` collide), inherits keys like `constructor`
from its prototype, and is slower for heavy adds and deletes. `new Map()` has none of those
problems. `Object.create(null)` avoids the prototype issue only.
]

#trap[
`[...s].sort()` with *no* comparator is correct here, because these are single characters
and the default sort compares them as text. That same bare `.sort()` on *numbers* is the
single most common JavaScript bug there is: `[10, 9, 1].sort()` returns `[1, 10, 9]`,
because `'10' < '9'` as strings. Numbers always need `(a, b) => a - b`. Know which case you
are in every time you type `.sort()`.
]
]
#ans[`{bat} {tea eat ate} {tan nat}`]

#ex(22, tier: 2, asked: "SCB · pattern")[
Rank the words in a log by frequency. Ties go alphabetically. Case does not matter and
punctuation is a separator.
`"the cat and the dog and THE bird"`, $k = 3$.
Constraints: text up to $10^6$ characters. Edge cases: fewer than $k$ distinct words; text
ending without punctuation.
]
#sol[
#code(lang: "js", caption: "tokenize, count, sort")[
```js
const topWords = (text, k) => {
  const f = new Map();
  for (const w of text.toLowerCase().match(/[a-z]+/g) ?? [])
    f.set(w, (f.get(w) ?? 0) + 1);
  return [...f.entries()]
    .sort((a, b) => b[1] - a[1]                      // count descending
                 || (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0))   // then alphabetical
    .slice(0, k);
};
```
]
Output: `the:3 and:2 bird:1`. `THE` and `the` merge because of `.toLowerCase()`.
`bird` beats `cat` and `dog` (all count 1) because `"bird"` sorts first.
#complexity(time: $O(n + D log D)$, space: $O(D)$, note: "D distinct words. JavaScript has no partial sort and no heap, so the whole list is sorted; with k tiny, a MinHeap of size k from the JS Toolkit appendix would make it O(n + D log k).")

#trap[
`text.match(/[a-z]+/g)` returns `null`, *not* an empty array, when the text has no letters
at all. `for (const w of null)` throws `TypeError: null is not iterable`. The `?? []` is
what makes the empty input safe — tested: `topWords('', 3)` returns `[]`.

Matching with a regular expression also removes the C-style bug this problem is famous for:
there is no "flush the last word after the loop" step to forget, because there is no loop.
]
]
#ans[`the:3 and:2 bird:1`]

#ex(23, tier: 2, asked: "GIC · pattern")[
Does a letter pattern describe a sentence? `"abba"` matches `"grab bus bus grab"` because
`a` maps to `grab` and `b` maps to `bus`, and the mapping works both ways.
Edge cases: two letters mapped to the same word; word count different from pattern length.
]
#sol[
#code(lang: "js", caption: "two maps, because the mapping must be one-to-one")[
```js
const patternMatch = (pat, sentence) => {
  const w = sentence.split(' ').filter(x => x.length > 0);
  if (w.length !== pat.length) return false;

  const f = new Map();    // letter -> word
  const b = new Map();    // word   -> letter
  for (let i = 0; i < w.length; i++) {
    const c = pat[i];
    if (f.has(c) && f.get(c) !== w[i]) return false;
    if (b.has(w[i]) && b.get(w[i]) !== c) return false;
    f.set(c, w[i]);
    b.set(w[i], c);
  }
  return true;
};
```
]
#table(
  columns: (auto, 1fr, auto, 1fr),
  align: (left, left, center, left),
  [*pattern*], [*sentence*], [*answer*], [*why*],
  [`abba`], [`grab bus bus grab`], [`true`], [a$->$grab, b$->$bus, consistent],
  [`abba`], [`grab bus bus bus`], [`false`], [`a` would need to map to both grab and bus],
  [`aaaa`], [`grab bus bus grab`], [`false`], [`a` cannot map to two words],
  [`ab`], [`one two three`], [`false`], [2 letters, 3 words],
)
#complexity(time: $O(n)$, space: $O(n)$)

#trap[
With only the forward map, `"ab"` would match `"dog dog"` --- both letters mapping to
`dog`. The reverse map is what forbids that. Any "bijection" question needs both. Tested:
with both maps, `patternMatch('ab', 'dog dog')` correctly returns `false`.
]
]
#ans[`true false false false`]

#section[The hard string algorithms]
#tier-header(3)

#ex(24, tier: 3, asked: "Google · pattern")[
Compute the Z-array: `z[i]` is the length of the longest common prefix of `s` and
`s[i..]`. Then use it to search for a pattern.
`s = "aabxaayaab"`.
Constraints: $n <= 10^6$. Target: $O(n)$.
Edge cases: empty string; every character the same.

*Follow-up:* "KMP already does search. Why does Z exist?"
]
#sol[
#formulas(title: "The Z-box")[
Keep the interval `[l, r)` that is the *rightmost* prefix-match found so far, meaning
`s[l..r-1] == s[0..r-l-1]`.

For a new index `i` inside that box, the characters at `i` mirror the characters at
`i - l`. So `z[i]` starts at `min(r - i, z[i - l])` for free, and only the part past `r`
needs real comparisons. Every real comparison pushes `r` forward, and `r` only moves
right --- so the total work is $O(n)$.
]
#code(lang: "js", caption: "the Z-function")[
```js
const zFunction = (s) => {
  const n = s.length;
  const z = new Array(n).fill(0);
  if (n) z[0] = n;
  let l = 0, r = 0;
  for (let i = 1; i < n; i++) {
    if (i < r) z[i] = Math.min(r - i, z[i - l]);     // reuse the mirror
    while (i + z[i] < n && s[z[i]] === s[i + z[i]]) z[i]++;
    if (i + z[i] > r) { l = i; r = i + z[i]; }       // a new, further box
  }
  return z;
};
```
]
`zFunction("aabxaayaab")` gives:

#table(
  columns: (auto,auto,auto,auto,auto,auto,auto,auto,auto,auto,auto),
  align: (left,center,center,center,center,center,center,center,center,center,center),
  [*i*], [0], [1], [2], [3], [4], [5], [6], [7], [8], [9],
  [*s\[i\]*], [`a`], [`a`], [`b`], [`x`], [`a`], [`a`], [`y`], [`a`], [`a`], [`b`],
  [*z\[i\]*], [10], [1], [0], [0], [2], [1], [0], [3], [1], [0],
)
`z[7] = 3` because `s[7..9] = "aab"` and `s[0..2] = "aab"`.

#code(lang: "js", caption: "search with Z: glue pattern, separator, text")[
```js
const zSearch = (t, p) => {
  const hits = [];
  if (p.length === 0 || p.length > t.length) return hits;
  const j = p + '\x01' + t;            // separator appears in neither string
  const z = zFunction(j);
  for (let i = p.length + 1; i < j.length; i++)
    if (z[i] >= p.length) hits.push(i - p.length - 1);
  return hits;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n + m)$, note: "Uses more memory than KMP because it builds the joined string.")

`zSearch("abababacaba","ababaca")` gives `2`. `zSearch("aaaa","aa")` gives `0 1 2`.

*The follow-up, answered.* Z and KMP solve search equally well, and Z is easier to get
right --- there is no confusing "do not move `i`" branch. Z wins outright when the question
is about *prefixes of the string itself*: "for each position, how far does the string match
itself?" That includes counting borders, finding periods, and string-compression questions.
KMP wins when memory matters, because it never copies the text.

#trap[
The separator must be a character that cannot occur in either string. If your input can
contain any byte, prepend the *lengths* instead, or use two different sentinel handling.
Using `'#'` on input that contains `'#'` gives silent wrong answers.
]
]
#ans[`10 1 0 0 2 1 0 3 1 0`; search gives `2`]

#ex(25, tier: 3, asked: "Amazon · pattern")[
What is the smallest number of characters you must add *in front* of `s` to make it a
palindrome? `"abcd"` needs 3 (`dcbabcd`). `"aacecaaa"` needs 1.
Constraints: $n <= 10^6$. Target: $O(n)$.
Edge cases: already a palindrome; one character; empty.

*Follow-up:* "now add characters at the end instead."
]
#sol[
#approach(1, "Try prefixes from longest to shortest", verdict: "O(n^2)")
#code(lang: "js", caption: "brute force reference")[
```js
const minPrefixAdditions_brute = (s) => {
  const pal = (x) => {
    let i = 0, j = x.length - 1;
    while (i < j) { if (x[i] !== x[j]) return false; i++; j--; }
    return true;
  };
  for (let k = s.length; k >= 1; k--)
    if (pal(s.slice(0, k))) return s.length - k;
  return s.length;
};
```
]
#complexity(time: $O(n^2)$, space: $O(n)$)

#approach(3, "One prefix function on s + sep + reverse(s)", verdict: "O(n), optimal")
#formulas(title: "The chain of three ideas")[
+ You must keep the longest *palindromic prefix* of `s`. Everything after it gets mirrored
  in front. So the answer is $n - ("longest palindromic prefix")$.
+ A prefix `s[0..k-1]` is a palindrome exactly when it equals the *last* $k$ characters of
  `reverse(s)`.
+ "Longest prefix of X that is also a suffix of Y" is the last entry of the prefix function
  of `X + "separator" + Y`.

Put $X = s$ and $Y = "reverse"(s)$ and the answer falls out in one line.
]
#code(lang: "js", caption: "the whole solution")[
```js
const minPrefixAdditions = (s) => {
  if (s.length === 0) return 0;
  const r = [...s].reverse().join('');
  const j = s + '\x01' + r;
  const lps = buildLPS(j);
  return s.length - lps[lps.length - 1];   // last entry = longest palindromic prefix
};
```
]
#complexity(time: $O(n)$, space: $O(n)$)

#table(
  columns: (auto, auto, auto, 1fr),
  align: (left, center, center, left),
  [*s*], [*answer*], [*brute*], [*reason*],
  [`abcd`], [3], [3], [only `a` is a palindromic prefix, so $4-1=3$],
  [`aacecaaa`], [1], [1], [`aacecaa` is a palindrome, so $8-7=1$],
  [`aba`], [0], [--], [already a palindrome],
  [`z`], [0], [--], [--],
  [`""`], [0], [--], [--],
)
A randomised cross-check against the brute force on 400 random strings matched every time.

#trap[
Without the separator, `s = "aaa"` and `r = "aaa"` glue into `"aaaaaa"`, whose prefix
function's last value is 5 --- longer than `s` itself --- and the answer goes negative.
The separator caps `lps.back()` at $n$.
]

*The follow-up.* Adding at the *end* is the mirror question: keep the longest palindromic
*suffix* and mirror the front. Same code with the roles swapped: build the prefix function
of `reverse(s) + sep + s`.
]
#ans[3 and 1]

#ex(26, tier: 3, asked: "Microsoft · pattern")[
Smallest window of `t` that contains every character of `p`, counting repeats.
`t = "adobecodebanc"`, `p = "abc"`.
Constraints: $n <= 10^5$, any ASCII. Target: $O(n)$.
Edge cases: no such window; `p` has duplicate letters; `p` longer than `t`.

*Follow-up:* "now `t` is a stream and you only get one pass."
]
#sol[
#approach(1, "Check every substring", verdict: "O(n^3)")
#approach(3, "Grow right, shrink left", verdict: "O(n), optimal")
#formulas(title: "Two counters do the work")[
- `required` = how many *distinct* characters `p` needs.
- `formed` = how many of those characters currently have `have[c] >= need[c]`.

The window is valid exactly when `formed == required`. Grow `right` until valid, then
shrink `left` as far as it stays valid, recording the best. Each pointer moves forward at
most $n$ times, so the whole thing is $O(n)$ even though there are two loops.
]
#code(lang: "js", caption: "minimum window substring")[
```js
const minWindow = (t, p) => {
  if (p.length === 0 || t.length < p.length) return '';
  const need = new Map(), have = new Map();
  for (const c of p) need.set(c, (need.get(c) ?? 0) + 1);
  const required = need.size;

  let formed = 0, left = 0, bestLen = Infinity, bestL = 0;
  for (let right = 0; right < t.length; right++) {
    const c = t[right];
    have.set(c, (have.get(c) ?? 0) + 1);
    if (need.has(c) && have.get(c) === need.get(c)) formed++;
    while (formed === required) {                 // valid: try to shrink
      if (right - left + 1 < bestLen) {
        bestLen = right - left + 1;
        bestL = left;
      }
      const d = t[left++];
      have.set(d, have.get(d) - 1);
      if (need.has(d) && have.get(d) < need.get(d)) formed--;
    }
  }
  return bestLen === Infinity ? '' : t.slice(bestL, bestL + bestLen);
};
```
]
#complexity(time: $O(n)$, space: $O(|"alphabet"|)$, note: "left and right each travel n steps total, so the nested while is still linear overall. The two Maps hold at most one entry per distinct character.")

#table(
  columns: (1fr, auto, 1fr),
  align: (left, center, left),
  [*case*], [*answer*], [*note*],
  [`adobecodebanc` / `abc`], [`banc`], [matches the brute force],
  [`abc` / `xyz`], [`""`], [no window exists],
  [`aab` / `aab`], [`aab`], [duplicate letters counted properly],
  [`a` / `aa`], [`""`], [`p` longer than `t`],
)
A randomised cross-check against an $O(n^3)$ brute force on 300 cases matched every time.

#trap[
`have.get(c) === need.get(c)` uses `===`, not `>=`. With `>=`, every extra copy of a needed
character increments `formed` again and the window is declared valid far too early.
]

#trap[
`have.get(c) ?? 0` is not optional. A missing key gives `undefined`, and
`undefined + 1` is `NaN` — which then compares `false` against everything, so the window is
never valid and the function quietly returns the empty string. Use `??` (nullish
coalescing) rather than `||`, so that a genuine stored `0` is kept.
]

*The follow-up.* One pass is already what this does --- `right` never goes backwards and
`left` never goes backwards. The only obstacle for a true stream is the final `slice`,
which needs the characters. Store just `bestL` and `bestLen` and emit the window from a
ring buffer of the last `bestLen` characters, or report the indices and let the caller
fetch them.

#subsection[Python version]
`collections.Counter` removes the two `?? 0` guards, which is the one place Python is
genuinely shorter here.

#code(lang: "python", caption: "minimum window substring in Python")[
```python
def min_window(t, p):
    if not p or len(t) < len(p):
        return ""
    from collections import Counter
    need = Counter(p)
    have = Counter()
    required = len(need)
    formed = 0
    left = 0
    best = (float("inf"), 0)
    for right, c in enumerate(t):
        have[c] += 1
        if c in need and have[c] == need[c]:
            formed += 1
        while formed == required:
            if right - left + 1 < best[0]:
                best = (right - left + 1, left)
            d = t[left]
            left += 1
            have[d] -= 1
            if d in need and have[d] < need[d]:
                formed -= 1
    if best[0] == float("inf"):
        return ""
    return t[best[1]:best[1] + best[0]]
```
]
Run on the four cases above, Python prints `'banc'`, `''`, `'aab'`, `''` --- the same
answers as the JavaScript. Cross-checked against an $O(n^3)$ brute force on 300 random
cases.
]
#ans[`banc`]

#ex(27, tier: 3, asked: "D. E. Shaw · pattern")[
Count the distinct substrings of a string. `"abab"` has 7.
Constraints: $n <= 3000$ for the hashing answer. Edge cases: all characters equal; empty
string.

*Follow-up:* "now $n = 10^6$."
]
#sol[
#approach(1, "Put every substring in a set", verdict: "O(n^3) time and O(n^3) memory")
#code(lang: "js", caption: "the obvious version, used as the reference")[
```js
const distinctSubstrings_set = (s) => {
  const seen = new Set();
  for (let i = 0; i < s.length; i++)
    for (let len = 1; i + len <= s.length; len++)
      seen.add(s.slice(i, i + len));
  return seen.size;
};
```
]
#complexity(time: $O(n^3)$, space: $O(n^3)$, note: "Every slice copies characters, and the Set stores them all. n = 3000 would need gigabytes.")

#approach(3, "Group by length, hash each window", verdict: "O(n^2) time, O(n) memory")
#code(lang: "js", caption: "prefix hashes, one set per length")[
```js
const distinctSubstrings_hash = (s) => {
  const n = s.length;
  const sub = buildHash(s);             // the prefix-hash helper from the pattern page
  let total = 0;
  for (let len = 1; len <= n; len++) {
    const seen = new Set();
    for (let i = 0; i + len <= n; i++) seen.add(sub(i, len));
    total += seen.size;
  }
  return total;
};
```
]
#complexity(time: $O(n^2)$, space: $O(n)$, note: "n^2 hash inserts, each O(1). The set is cleared every length, so memory stays O(n).")

`"abab"` gives 7 from both: `a`, `b`, `ab`, `ba`, `aba`, `bab`, `abab`.
`"aaa"` gives 3 (`a`, `aa`, `aaa`). The empty string gives 0. `"q"` gives 1.
A randomised cross-check on 200 random strings matched every time.

*The follow-up.* At $n = 10^6$ even $O(n^2)$ is dead. The real answer is a suffix automaton
or a suffix array with LCP:
$ "distinct" = (n(n+1))/2 - sum_i "lcp"[i] $
The suffix array counts every substring once by subtracting the overlaps that consecutive
suffixes share. That is $O(n log n)$ and is the expected answer at this size --- worth
*naming* even if you do not code it in 40 minutes.
]
#ans[7]

#ex(28, tier: 3, asked: "Goldman Sachs · pattern")[
Longest substring that appears at least twice (the copies may overlap).
`"banana"` gives `ana`.
Constraints: $n <= 10^5$. Target: $O(n log n)$.
Edge cases: no repeat at all; single character.

*Follow-up:* "what if the hash collides?"
]
#sol[
#formulas(title: "Why binary search works here")[
Let $f(L)$ = "does some substring of length $L$ appear twice?".

If a substring of length $L$ appears twice, then its first $L-1$ characters also appear
twice. So $f$ is *monotone*: true for all small $L$, false for all large $L$. Anything
monotone can be binary-searched.

For a fixed $L$, testing $f(L)$ is one pass: hash every window of length $L$ and look for
a repeat.
]
#code(lang: "js", caption: "binary search on the length, hashing inside")[
```js
const longestRepeated = (s) => {
  const n = s.length;
  if (n < 2) return '';
  const sub = buildHash(s);
  const findLen = (len) => {                      // a start index, or -1
    const seen = new Map();
    for (let i = 0; i + len <= n; i++) {
      const key = sub(i, len);
      if (seen.has(key)) {
        const at = seen.get(key);
        if (s.slice(at, at + len) === s.slice(i, i + len)) return at;  // verified
      } else seen.set(key, i);
    }
    return -1;
  };
  let lo = 1, hi = n - 1, bestPos = -1, bestLen = 0;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    const pos = findLen(mid);
    if (pos >= 0) { bestLen = mid; bestPos = pos; lo = mid + 1; }
    else hi = mid - 1;
  }
  return bestLen ? s.slice(bestPos, bestPos + bestLen) : '';
};
```
]
#complexity(time: [$O(n log n)$ expected], space: $O(n)$, note: "log n rounds, each O(n) hash lookups.")

`"banana"` gives `ana`, matching the $O(n^3)$ brute force. `"abcd"` gives the empty string.
`"a"` gives the empty string. A randomised cross-check on 300 random strings matched the
brute force length every time.

*The follow-up, answered.* Three defences, in order of how much an interviewer likes them:
+ *Verify.* The code above compares the actual characters after a hash hit
  (`s.slice(at, at + len) === s.slice(i, i + len)`). A collision then costs time, never
  correctness.
+ *Big modulus.* $2^61 - 1$ is prime; with $10^5$ windows the birthday-collision chance is
  about $(10^5)^2 slash 2^62 approx 2 times 10^(-9)$.
+ *Random base.* Pick `B` at random at run time so nobody can pre-compute a colliding test
  case. Fixed bases like 31 and 131 are exactly what anti-hash tests target.
]
#ans[`ana`]

#ex(29, tier: 3, asked: "Adobe · pattern")[
Longest palindromic substring in $O(n)$.
`"babadada"`.
Constraints: $n <= 10^6$. Edge cases: even-length answer; empty string.

*Follow-up:* "what does the algorithm actually compute, beyond the single longest one?"
]
#sol[
#approach(1, "Expand around every centre", verdict: "O(n^2) — the answer from Example 14")
#note[
Correct and short, and it is what you should write first. At $n = 10^6$ a worst case like
`"aaaa...a"` makes every centre expand $n/2$ steps, giving $5 times 10^11$ character
comparisons. That is the only reason to go further.
]

#approach(3, "Manacher", verdict: "O(n), optimal")
#formulas(title: "Two tricks make Manacher work")[
*Trick 1 --- kill the odd/even split.* Insert `#` between every pair of characters and at
both ends. `"cbbd"` becomes `"#c#b#b#d#"`. Now *every* palindrome has odd length and a
single character centre. Add guards `^` and `$` at the two ends so the expansion loop never
needs a bounds check.

*Trick 2 --- reuse the mirror.* Keep the palindrome with the furthest right edge, centre
`c` and right edge `r`. For a new index `i` inside it, the mirror index is `2c - i`, and
`p[i]` starts at `min(r - i, p[2c - i])` for free. Only the part past `r` is really
compared, and `r` only moves right --- so the total work is $O(n)$.
]
#code(lang: "js", caption: "Manacher's algorithm")[
```js
const manacher = (s) => {
  if (s.length === 0) return '';
  let t = '^';
  for (const c of s) t += '#' + c;
  t += '#$';                                  // guards: no bounds checks needed
  const n = t.length;
  const p = new Array(n).fill(0);
  let c = 0, r = 0;
  for (let i = 1; i < n - 1; i++) {
    if (i < r) p[i] = Math.min(r - i, p[2 * c - i]);
    while (t[i + p[i] + 1] === t[i - p[i] - 1]) p[i]++;
    if (i + p[i] > r) { c = i; r = i + p[i]; }
  }
  let bestLen = 0, bestC = 0;
  for (let i = 1; i < n - 1; i++)
    if (p[i] > bestLen) { bestLen = p[i]; bestC = i; }
  const start = (bestC - bestLen) / 2;        // map back to the original s
  return s.slice(start, start + bestLen);
};
```
]
#complexity(time: $O(n)$, space: $O(n)$, note: "The transformed string is 2n+3 characters; the p array is the same size.")

`"babadada"` gives `adada`, same as the $O(n^2)$ expand version. `"cbbd"` gives `bb`,
`"x"` gives `x`, `""` gives `""`. A randomised cross-check against the expand version on
400 random strings matched the length every time.

#formulas(title: "Reading the p array")[
In the transformed string, `p[i]` is *exactly the length of the palindrome centred at `i`
in the original string*. That is why the mapping back is
`start = (bestC - bestLen) / 2` and the length is `bestLen` with no adjustment.
]

*The follow-up.* `p` holds the radius at *every* centre, so with one $O(n)$ run you can
also answer:
- how many palindromic substrings are there? $sum_i ceil(p[i] slash 2)$, though it is
  easier to count directly on the transformed array,
- is `s[l..r]` a palindrome? check `p[l + r + 2] >= r - l + 1` on the transformed indices,
- the longest palindrome *starting* or *ending* at each position.

In an interview: code the $O(n^2)$ expand version first, get it correct, then say
"Manacher makes this $O(n)$ by reusing mirror information, same idea as the Z-function."
Most interviewers stop you there.
]
#ans[`adada`]

#section[Dry run: KMP on `aabaabaaa` / `aabaa`]

#subsection[Step 1 --- build the LPS table]

Pattern `p = "aabaa"`. Trace exactly as the instrumented program printed it:

#code(lang: "text", caption: "buildLPS trace")[
```text
i  len  p[i] p[len]  action                   lps
1  0    a    a       match: lps[1]=1          [01000]
2  1    b    a       mismatch: len=lps[0]=0   [01000]
2  0    b    a       mismatch, len=0: lps[2]=0[01000]
3  0    a    a       match: lps[3]=1          [01010]
4  1    a    a       match: lps[4]=2          [01012]

lps = 0 1 0 1 2
```
]

#note[
Look at the two rows with `i = 2`. The first one does not advance `i` --- it only shrinks
`len` from 1 to 0. That is the fall-back branch. The second row, now with `len = 0`, writes
`lps[2] = 0` and finally moves on.
]

#subsection[Step 2 --- check the table by hand]

#table(
  columns: (auto, auto, auto, 1fr),
  align: (center, center, center, left),
  [*i*], [*p\[0..i\]*], [*lps\[i\]*], [*the border*],
  [0], [`a`], [0], [a single character has no proper border],
  [1], [`aa`], [1], [`a` is both the prefix and the suffix],
  [2], [`aab`], [0], [starts with `a`, ends with `b`],
  [3], [`aaba`], [1], [`a`],
  [4], [`aabaa`], [2], [`aa`],
)

#subsection[Step 3 --- the search, every single step]

Text `t = "aabaabaaa"`, $n = 9$, $m = 5$.

#table(
  columns: (auto, auto, auto, auto, 1fr),
  align: (center, center, center, center, left),
  [*i*], [*j*], [*t\[i\]*], [*p\[j\]*], [*action*],
  [0], [0], [`a`], [`a`], [equal: advance both],
  [1], [1], [`a`], [`a`], [equal: advance both],
  [2], [2], [`b`], [`b`], [equal: advance both],
  [3], [3], [`a`], [`a`], [equal: advance both],
  [4], [4], [`a`], [`a`], [equal $->$ `j` hits 5 = m. *Match at 0.* `j = lps[4] = 2`],
  [5], [2], [`b`], [`b`], [equal: advance both],
  [6], [3], [`a`], [`a`], [equal: advance both],
  [7], [4], [`a`], [`a`], [equal $->$ *Match at 3.* `j = lps[4] = 2`],
  [8], [2], [`a`], [`b`], [not equal, `j > 0`: `j = lps[1] = 1`, `i` does *not* move],
  [8], [1], [`a`], [`a`], [equal: advance both. `i` reaches 9, loop ends],
)

*Answer: matches start at 0 and 3.*

#subsection[Step 4 --- the three things to notice]

#formulas(title: "What the trace proves")[
+ *`i` never goes backwards.* Look at the `i` column: 0,1,2,3,4,5,6,7,8,8. It only repeats
  once (the fall-back row) and never decreases. The naive search would have gone back to
  `i = 1` after the first match.
+ *Matches can overlap.* After the hit at 0, `j` drops to `lps[4] = 2` instead of 0,
  meaning "we already have `aa` matched". That is why the hit at 3 is found --- positions
  3 and 0 overlap by 2 characters.
+ *The fall-back is cheap.* Row `i = 8` fires it once. Over the whole run, the number of
  fall-backs is bounded by how much `j` grew, which is bounded by $n$.
]

#subsection[Step 5 --- edge cases, checked]

#table(
  columns: (1fr, 1fr, auto, 1fr),
  align: (left, left, center, left),
  [*text*], [*pattern*], [*hits*], [*note*],
  [`aaaa`], [`aa`], [`0 1 2`], [overlaps kept],
  [`abc`], [`xyz`], [none], [--],
  [`abc`], [`""`], [none], [the guard rejects an empty pattern],
  [`ab`], [`abc`], [none], [pattern longer than text],
)

#section[Practice]

#practice(tier: 0, time: "20 min for P1--P3")[
*P1.* Count vowels and consonants in `"Hello World 42"`. Digits and spaces count as
neither.

*P2.* Two strings of equal length: do they differ in *exactly one* position?
Test `("cat","cot")`, `("cat","cat")`, `("cat","dog")`, `("cat","cats")`.

*P3.* Capitalise the first letter of every word and lowercase the rest.
Test `"the QUICK brown fOx"` and the empty string.
]

#practice(tier: 1, time: "45 min for P4--P7")[
*P4.* Remove duplicate characters, keeping the first occurrence of each.
Test `"programming"`.

*P5.* Is `a` a subsequence of `b` (same order, gaps allowed)?
Test `("ace","abcde")`, `("aec","abcde")`, `("","abc")`, `("abc","")`.

*P6.* Count all palindromic substrings (different positions count separately).
Test `"aaa"` and `"abc"`. Target $O(n^2)$.

*P7.* In a sentence, find the longest word whose letters are all different.
Test `"code the quick brown fox"`.
]

#practice(tier: 2, time: "55 min for P8--P11")[
*P8.* Implement `strStr` with KMP: return the first index of `p` in `t`, or $-1$.
Test `("aabaabaaa","aabaa")`, `("abc","d")`, `("abc","")`, `("a","aa")`.

*P9.* Does `t` contain any permutation of `p` as a contiguous block?
Test `("eidbaooo","ab")` and `("eidboaoo","ab")`.

*P10.* Longest substring with at most $k$ distinct characters.
Test `("eceba", 2)`. Also handle $k = 0$ and $k >$ alphabet size.

*P11.* Decode a run-length encoded string: `"a3b4c1d1"` becomes `"aaabbbbcd"`.
Handle counts with more than one digit, e.g. `"a12"`.
]

#practice(tier: 3, time: "70 min for P12--P15")[
*P12.* Is `s` made by repeating one shorter substring? Test `"abab"` (yes), `"aba"` (no),
`"aaaa"` (yes), `"a"` (no). Target $O(n)$.

*P13.* Longest common substring of two strings, in $O((n+m) log)$.
Test `("abcdefg","xxcdefyy")`.

*P14.* Count substrings with *exactly* $k$ distinct characters.
Test `("pqpqs", 2)`. Target $O(n)$.

*P15.* Lexicographically smallest rotation of a string. Test `"bcabd"`.
]

#key[
*P1 --- 3 vowels, 7 consonants.*
```js
const vowelsConsonants = (s) => {
  let a = 0, b = 0;
  for (const c of s.toLowerCase()) {
    if (!/[a-z]/.test(c)) continue;        // skip digits and spaces
    if ('aeiou'.includes(c)) a++; else b++;
  }
  return [a, b];
};
```
`"Hello World 42"`: vowels `e, o, o`; consonants `H, l, l, W, r, l, d`.
#complexity(time: $O(n)$, space: $O(1)$)

*P2 --- `true false false false`.*
```js
const differByOne = (a, b) => {
  if (a.length !== b.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) d++;
  return d === 1;
};
```
Identical strings give $d = 0$, so they are *not* "differ by one". `("cat","cats")` is
rejected by the length check.
*Speed-up:* `if (d > 1) return false;` inside the loop lets long strings exit early.

*P3 --- `The Quick Brown Fox`.*
```js
const titleCase = (s) => {
  const out = [...s];                    // strings are immutable: edit an array
  let start = true;
  for (let i = 0; i < out.length; i++) {
    if (out[i] === ' ') { start = true; continue; }
    out[i] = start ? out[i].toUpperCase() : out[i].toLowerCase();
    start = false;
  }
  return out.join('');
};
```
The `start` flag is the whole solution: set it at every space, clear it after writing a
letter. The empty string returns the empty string.

*P4 --- `progamin`.*
```js
const dedup = (s) => {
  const seen = new Set();
  const out = [];
  for (const c of s) if (!seen.has(c)) { seen.add(c); out.push(c); }
  return out.join('');
};
```
`"programming"` loses the second `r`, the second `m`, and the second `g`.
A `Set` handles any character, not just lowercase letters, and it costs only as much as
the number of distinct characters actually seen.
#complexity(time: $O(n)$, space: $O(1)$)

*P5 --- `true false true false`.*
```js
const isSubsequence = (a, b) => {
  let i = 0;
  for (let j = 0; j < b.length && i < a.length; j++)
    if (a[i] === b[j]) i++;
  return i === a.length;
};
```
Greedy matching is safe: taking the *earliest* possible match for each character of `a`
never blocks a later one. `("","abc")` is true --- the empty string is a subsequence of
everything. `("abc","")` is false.
#complexity(time: $O(n + m)$, space: $O(1)$)

*P6 --- `aaa` gives 6, `abc` gives 3.*
```js
const countPalSubstrings = (s) => {
  const n = s.length;
  let c = 0;
  const grow = (l, r) => {
    while (l >= 0 && r < n && s[l] === s[r]) { c++; l--; r++; }
  };
  for (let i = 0; i < n; i++) { grow(i, i); grow(i, i + 1); }
  return c;
};
```
The counter sits *inside* the while loop: every successful expansion is one more
palindrome. `"aaa"` has `a`, `a`, `a`, `aa`, `aa`, `aaa` = 6.
A randomised cross-check against an $O(n^3)$ brute force on 300 strings matched every time.
#complexity(time: $O(n^2)$, space: $O(1)$)

*P7 --- `quick`.*
```js
const longestDistinctWord = (sentence) => {
  let best = '';
  for (const w of sentence.split(' ').filter(x => x.length > 0)) {
    if (new Set(w).size !== w.length) continue;   // a repeated letter: skip the word
    if (w.length > best.length) best = w;         // > not >=, so a tie keeps the first
  }
  return best;
};
```
`code`(4), `the`(3), `quick`(5), `brown`(5), `fox`(3) all have distinct letters.
`quick` and `brown` tie at 5, and `>` (not `>=`) keeps the first one.

*P8 --- `0`, `-1`, `0`, `-1`.*
```js
const strStrKMP = (t, p) => {
  if (p.length === 0) return 0;
  if (p.length > t.length) return -1;
  const lps = buildLPS(p);
  let i = 0, j = 0;
  while (i < t.length) {
    if (t[i] === p[j]) { i++; j++; if (j === p.length) return i - j; }
    else if (j > 0) j = lps[j - 1];
    else i++;
  }
  return -1;
};
```
Same as Example 17 but returning on the first hit instead of collecting all of them.
#complexity(time: $O(n + m)$, space: $O(m)$)

*P9 --- `true` then `false`.*
```js
const containsPermutation = (t, p) => {
  const n = t.length, m = p.length;
  if (m === 0) return true;
  if (m > n) return false;
  const need = new Array(26).fill(0), have = new Array(26).fill(0);
  for (const c of p) need[c.charCodeAt(0) - 97]++;
  const same = () => need.every((v, k) => v === have[k]);
  for (let i = 0; i < n; i++) {
    have[t.charCodeAt(i) - 97]++;
    if (i >= m) have[t.charCodeAt(i - m) - 97]--;
    if (i >= m - 1 && same()) return true;
  }
  return false;
};
```
`"eidbaooo"` contains `ba` at index 3. `"eidboaoo"` has `b` and `a` separated by `o`, so no
window of length 2 holds both.
#complexity(time: $O(26 n)$, space: $O(1)$, note: "need.every(...) is 26 comparisons per step, a constant factor.")

*P10 --- 3.*
```js
const atMostKDistinct = (s, k) => {
  if (k <= 0) return 0;
  const cnt = new Map();
  let left = 0, best = 0;
  for (let right = 0; right < s.length; right++) {
    const c = s[right];
    cnt.set(c, (cnt.get(c) ?? 0) + 1);
    while (cnt.size > k) {
      const d = s[left];
      cnt.set(d, cnt.get(d) - 1);
      if (cnt.get(d) === 0) cnt.delete(d);    // delete, or size never drops
      left++;
    }
    best = Math.max(best, right - left + 1);
  }
  return best;
};
```
`"eceba"` with $k=2$: the window `ece` has 2 distinct letters and length 3.
$k = 0$ gives 0; $k$ larger than the alphabet gives the whole string.
*The `delete` is the whole trick.* `cnt.size` is the number of distinct characters in the
window, so a count that reaches zero must be removed from the `Map` or the size never
drops and the window never shrinks. Setting the value to `0` is not enough.
#complexity(time: $O(n)$, space: $O(1)$)

*P11 --- `aaabbbbcd`.*
```js
const rleDecode = (s) => {
  const out = [];
  let i = 0;
  while (i < s.length) {
    const c = s[i++];
    let n = 0;
    while (i < s.length && s[i] >= '0' && s[i] <= '9')
      n = n * 10 + (s.charCodeAt(i++) - 48);     // multi-digit counts
    if (n === 0) n = 1;                          // a bare letter means one copy
    out.push(c.repeat(n));
  }
  return out.join('');
};
```
`"a3b4c1d1"` gives `aaabbbbcd`. `"x"` gives `x`. `"a12"` gives twelve `a`s --- the inner
loop reads *both* digits, which a single `s.charCodeAt(i) - 48` would get wrong.
`String.prototype.repeat` does the expanding, so no inner append loop is needed.
#complexity(time: $O("output length")$, space: $O("output length")$)

*P12 --- `abab` yes, `aba` no, `aaaa` yes, `a` no.*
```js
const isRepeated = (s) => {
  const n = s.length;
  if (n < 2) return false;
  const lps = buildLPS(s);
  const b = lps[n - 1];                    // longest proper border
  return b > 0 && n % (n - b) === 0;
};
```
*Why this works.* If the longest border has length $b$, the string has period $n - b$.
The string is a whole number of copies of that period exactly when $n$ divides evenly by
$n - b$.
`"abab"`: `lps = 0 0 1 2`, so $b = 2$, period $= 2$, and $4 % 2 = 0$ $=>$ yes.
`"aba"`: $b = 1$, period $= 2$, and $3 % 2 = 1$ $=>$ no.
A randomised cross-check against an $O(n^2)$ brute force on 400 strings matched every time.
#complexity(time: $O(n)$, space: $O(n)$)

*P13 --- `cdef`.* Binary-search the length; for each length, hash all windows of `b` into a
set and look up every window of `a`.
```js
const longestCommonSubstring = (a, b) => {
  const ha = buildHash(a), hb = buildHash(b);
  const tryLen = (len) => {                    // a start index in a, or -1
    if (len === 0) return 0;
    const s = new Set();
    for (let i = 0; i + len <= b.length; i++) s.add(hb(i, len));
    for (let i = 0; i + len <= a.length; i++)
      if (s.has(ha(i, len))) return i;
    return -1;
  };
  let lo = 1, hi = Math.min(a.length, b.length), bestPos = -1, bestLen = 0;
  while (lo <= hi) {
    const mid = Math.floor(lo + (hi - lo) / 2);
    const pos = tryLen(mid);
    if (pos >= 0) { bestLen = mid; bestPos = pos; lo = mid + 1; }
    else hi = mid - 1;
  }
  return bestLen ? a.slice(bestPos, bestPos + bestLen) : '';
};
```
`ha` and `hb` are the prefix-hash structures from the pattern page.
Monotone because any common substring of length $L$ contains a common substring of length
$L-1$. A randomised cross-check on 300 random pairs matched the brute-force length every
time.
#complexity(time: $O((n+m) log min(n,m))$, space: $O(n+m)$)

*P14 --- 7.* The trick: *exactly k* = *at most k* $-$ *at most k-1*.
```js
const atMost = (s, k) => {
  if (k <= 0) return 0;
  const cnt = new Map();
  let left = 0, total = 0;
  for (let right = 0; right < s.length; right++) {
    const c = s[right];
    cnt.set(c, (cnt.get(c) ?? 0) + 1);
    while (cnt.size > k) {
      const d = s[left];
      cnt.set(d, cnt.get(d) - 1);
      if (cnt.get(d) === 0) cnt.delete(d);
      left++;
    }
    total += right - left + 1;      // all windows ending at right are valid
  }
  return total;
};

const exactlyK = (s, k) => atMost(s, k) - atMost(s, k - 1);
```
*Why `total += right - left + 1`:* once the window `[left, right]` is valid, every
sub-window ending at `right` is also valid, and there are `right - left + 1` of them.
`"pqpqs"` with $k = 2$ gives 7; a brute force agreed, and a randomised check on 300 cases
matched every time. `"aaa"` with $k=1$ gives 6. $k$ bigger than the alphabet gives 0.
#complexity(time: $O(n)$, space: $O(1)$)

*P15 --- `abdbc`.*
```js
const smallestRotation = (s) => {
  if (s.length === 0) return s;
  const d = s + s;
  const n = s.length;
  let best = 0;
  for (let i = 1; i < n; i++)
    if (d.slice(i, i + n) < d.slice(best, best + n)) best = i;
  return d.slice(best, best + n);
};
```
Rotations of `bcabd`: `bcabd, cabdb, abdbc, bdbca, dbcab`. The smallest is `abdbc`.
`"aaa"` gives `aaa`, `""` gives `""`, `"z"` gives `z`.
#complexity(time: $O(n^2)$, space: $O(n)$, note: "Booth's algorithm does it in O(n). Name it; code this one.")
]

#revision[
#subsection[The four engines, as code]
#code(lang: "js", caption: "memorise these shapes")[
```js
// 1. two pointers
let i = 0, j = s.length - 1;
while (i < j) { if (s[i] !== s[j]) return false; i++; j--; }

// 2. fixed frequency window of length m
for (let i = 0; i < n; i++) {
  have[t.charCodeAt(i) - 97]++;
  if (i >= m) have[t.charCodeAt(i - m) - 97]--;
  if (i >= m - 1 && need.every((v, k) => v === have[k])) { /* hit at i-m+1 */ }
}

// 3. prefix function
for (let i = 1; i < m; ) {
  if (p[i] === p[len]) lps[i++] = ++len;
  else if (len > 0)    len = lps[len - 1];
  else                 lps[i++] = 0;
}

// 4. rolling hash prefix, on BigInt
h[i + 1] = (h[i] * B + BigInt(s.charCodeAt(i))) % M;
const sub = (l, len) => (h[l + len] - h[l] * pw[len] % M + M) % M;
```
]

#subsection[Which algorithm for which question]
#table(
  columns: (1.3fr, 1fr, auto, auto),
  align: (left, left, center, center),
  [*Question says*], [*Use*], [*Time*], [*Space*],
  [palindrome check], [two pointers], [$O(n)$], [$O(1)$],
  [longest palindrome], [expand centres], [$O(n^2)$], [$O(1)$],
  [longest palindrome, huge n], [Manacher], [$O(n)$], [$O(n)$],
  [find a pattern], [KMP], [$O(n+m)$], [$O(m)$],
  [find many patterns], [Rabin-Karp / Aho-Corasick], [$O(n+m)$], [$O(1)$],
  [prefix-of-self questions], [Z-function], [$O(n)$], [$O(n)$],
  [shortest palindrome by prefix], [LPS of `s + sep + rev(s)`], [$O(n)$], [$O(n)$],
  [is it a repeated block], [LPS border + period], [$O(n)$], [$O(n)$],
  [anagram windows], [fixed frequency window], [$O(n)$], [$O(1)$],
  [at most / exactly k distinct], [variable window], [$O(n)$], [$O(1)$],
  [smallest window containing], [grow right, shrink left], [$O(n)$], [$O(1)$],
  [distinct substrings], [hash per length / suffix array], [$O(n^2)$], [$O(n)$],
  [longest repeated / common], [binary search + hash], [$O(n log n)$], [$O(n)$],
  [two strings, edit-like], [DP (Chapter 18)], [$O(n m)$], [$O(n m)$],
)

#subsection[The key formulas]
#formulas(title: "Worth writing on the board")[
- Prefix function: `lps[i]` = longest proper border of `p[0..i]`.
- *Period* of a string: $n - "lps"[n-1]$. It tiles the string exactly when
  $n mod (n - "lps"[n-1]) = 0$.
- *Longest palindromic prefix* of `s` = `lps.back()` of `s + sep + reverse(s)`.
- *Polynomial hash*: $H = sum_k s_k B^(m-1-k) mod M$; slide with
  $H' = (H - s_"left" B^(m-1)) B + s_"right"$.
- *Exactly k distinct* = *at most k* $-$ *at most k-1*.
- Number of palindrome centres in a string of length $n$: $2n - 1$.
]

#subsection[Top traps]
+ `if (s.indexOf(x))` is wrong at both ends: `-1` is truthy, and index `0` is falsy.
  Write `s.indexOf(x) !== -1`, or `s.includes(x)`.
+ Strings are immutable. `s[0] = 'x'` throws in strict mode and does nothing otherwise.
  Work on `[...s]` and `join('')` at the end.
+ `.split(' ')` keeps the empty pieces. Always `.filter(w => w.length > 0)`.
+ `str.match(/re/g)` returns `null`, not `[]`, when nothing matches. Guard with `?? []`.
+ In `buildLPS`, advancing `i` in the fall-back branch. It must not move.
+ Expand-around-centre: the length is `r - l - 1`, not `r - l + 1`.
+ Forgetting the last token after a split loop (no trailing separator).
+ Rabin-Karp without character verification after a hash match.
+ A separator character in `s + sep + t` that can actually appear in the input.
+ `formed++` guarded with `>=` instead of `==` in the minimum-window pattern.
+ `Map` iterates in insertion order and a plain object puts integer-like keys first.
  Neither is key order — sort the keys yourself when the output must be reproducible.
+ `map.get(k) + 1` on a missing key is `NaN`. Write `(map.get(k) ?? 0) + 1`.
+ Two-pointer skip loops without the `i < j` guard read past the ends.
+ A bare `.sort()` is lexicographic. Correct for single characters, catastrophic for
  numbers: `[10, 9, 1].sort()` gives `[1, 10, 9]`.
+ Modular multiplication in plain numbers is wrong above $2^53 - 1$, which two residues
  mod $10^9+7$ reach immediately. Every rolling hash must be `BigInt`.
+ Counting substrings: there are $n(n+1)/2$ of them, which stays exact as a JavaScript
  number until $n approx 1.3 times 10^8$ — comfortably beyond any input, so no `BigInt`
  is needed for the *count* itself.

#subsection[Complexity facts to quote]
- A string of length $n$ has $n(n+1)/2$ substrings but at most $n(n+1)/2$ *distinct* ones,
  and a suffix automaton stores them all in $O(n)$ states.
- KMP, Z and Manacher are all the same idea: *never re-compare what a previous match
  already proved*. Each keeps one "rightmost known region" and reuses it.
- Rabin-Karp is the only one of the four that generalises to 2-D patterns and to searching
  many patterns at once.
]
]
