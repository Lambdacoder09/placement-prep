#import "../../shared/lib/style.typ": *

#chapter(num: 8, title: "Stacks & Monotonic Stack", tagline: "Last in, first out — and the one trick that makes it O(n)")[

#note[
Every JavaScript snippet in this chapter was executed with `node` before it was printed,
and the outputs shown under the snippets are the real outputs.

This chapter needs *no* import. A plain JavaScript array already is a stack: `push` and
`pop` both work on the end and both cost $O(1)$. The shared `MinHeap`, `DSU` and `Deque`
of the *JS Toolkit* appendix are not needed until the next chapter, where `shift` from
the front starts to matter.
]

#section[Pattern in one page]

#formulas(title: "The one idea")[
A stack answers *"what is the most recent thing still waiting?"*

Half of this chapter is plain stacks: brackets, expressions, undo. The other half is the
*monotonic stack*, and it is one of the highest-value patterns in a coding round.

*The monotonic stack rule.* Keep the stack sorted (all increasing, or all decreasing).
Before pushing a new item, *pop everything that can never be the answer again*. Each item
is pushed once and popped at most once, so the whole loop is $O(n)$ even though it has
an inner `while`.

*The four questions it answers instantly*
#table(columns: 3,
  [*Question*], [*Direction*], [*Pop while the top is*],
  [next greater to the right], [right $arrow.l$ left], [$<=$ current],
  [next smaller to the right], [right $arrow.l$ left], [$>=$ current],
  [previous greater to the left], [left $arrow.r$ right], [$<=$ current],
  [previous smaller to the left], [left $arrow.r$ right], [$>=$ current],
)

Say it in words: *"pop while the top is useless."* Useless means the new element is
better than it *and* stands in front of it, so no future query can ever pick the old one.
]

#code(lang: "js", caption: "The template you will write ten times")[
```js
// NEXT GREATER ELEMENT to the right. -1 when there is none.
const nextGreater = (a) => {
  const n = a.length;
  const out = new Array(n).fill(-1);
  const st = [];                              // a plain array IS a stack
  for (let i = n - 1; i >= 0; i--) {          // walk backwards
    while (st.length && st[st.length - 1] <= a[i]) st.pop();   // useless
    if (st.length) out[i] = st[st.length - 1];                 // survivor is the answer
    st.push(a[i]);
  }
  return out;
};
```
]

#subsection[Values or indices?]

Push *indices* whenever you need a distance (a width, a span, a number of days) and
*values* when you only need the number itself. Indices are never wrong, so when in doubt,
push indices and read `a[st[st.length - 1]]`.

#note[
JavaScript has no stack type, and it does not need one. A plain array already *is* a
stack: `push` and `pop` are both $O(1)$ and both act on the end. The top is
`st[st.length - 1]`, and `st.length` is the size. The one habit to build: test
`while (st.length && ...)` before you ever read the top, because reading past the end of
a JavaScript array gives you `undefined` rather than an error.
]

#subsection[The invariant]

#note[
At the moment the loop is about to look at index `i`, the stack holds exactly those
earlier elements that are still *candidates* — nothing more, nothing less. Everything
popped was beaten by something closer to `i`, so it can never win again.
]

#subsection[Watching it run]

`a = {4, 1, 2, 6, 3}`, walking right to left, next greater to the right:

#table(columns: 5,
  [*i*], [*a[i]*], [*popped*], [*stack after push (top first)*], [*out[i]*],
  [4], [3], [—], [3], [-1],
  [3], [6], [3], [6], [-1],
  [2], [2], [—], [2, 6], [6],
  [1], [1], [—], [1, 2, 6], [2],
  [0], [4], [1, 2], [4, 6], [6],
)

Result `[6, 2, 6, -1, -1]`. Notice row `i = 0`: the values 1 and 2 are thrown away
because 4 is bigger *and* closer to everything on the left. Five elements, five pushes,
three pops. Total work $O(n)$.

#diagram(height: 4.6cm, caption: "Pushing 4 pops every smaller value first. The stack stays decreasing.")[
  #dnode(0pt, 0.2cm, 2.2cm, 0.6cm, "before: 1, 2, 6")
  #dnode(0.35cm, 1.1cm, 1.5cm, 0.5cm, "1  (top)", fill: rgb("#f7e4e4"))
  #dnode(0.35cm, 1.65cm, 1.5cm, 0.5cm, "2", fill: rgb("#f7e4e4"))
  #dnode(0.35cm, 2.2cm, 1.5cm, 0.5cm, "6")
  #darrow(2.2cm, 1.8cm, 4.0cm, 1.8cm, label: "push 4")
  #dnode(4.3cm, 0.2cm, 2.6cm, 0.6cm, "pop 1, pop 2")
  #dnode(4.6cm, 1.65cm, 1.5cm, 0.5cm, "4  (top)", fill: rgb("#e4f0e6"))
  #dnode(4.6cm, 2.2cm, 1.5cm, 0.5cm, "6")
  #dnode(7.4cm, 1.1cm, 6.5cm, 1.5cm, "1 and 2 are gone forever: anything to their left now meets 4 first, and 4 is bigger than both.", fill: rgb("#fbfbf8"))
]

#trap[
`<=` versus `<` in the pop test decides what happens with *equal* values. `pop while top
<= a[i]` means "strictly greater" is wanted. `pop while top < a[i]` means "greater or
equal" is acceptable. Get this wrong and duplicates are counted twice in the
contribution problems of Tier 2.
]

#subsection[When to reach for it]

#table(columns: 2,
  [*The question sounds like*], [*Reach for*],
  [brackets, nesting, undo, backtrack], [plain stack],
  [postfix / prefix expression], [plain stack of operands],
  [next / previous greater or smaller], [monotonic stack],
  [span, days until, how far back], [monotonic stack of *indices*],
  [largest rectangle, biggest area], [monotonic stack of indices],
  [water trapped, container], [monotonic stack or two pointers],
  [sum over all subarrays of min / max], [monotonic stack + contribution counting],
  [smallest / largest result after k deletions], [monotonic stack, greedy],
)

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
Build a stack on a plain array with `push`, `pop`, `peek`, `empty` and `size`.
It must not crash when full or empty. Capacity up to $10^5$.

#sol[
Keep one index `top` = position of the newest item. Empty is `top == -1`. Full is
`top + 1 == capacity`. Both operations return `false` instead of crashing.
]
]

#code(lang: "js", caption: "Array-backed stack")[
```js
class ArrayStack {
  constructor(cap) { this.buf = new Array(cap); this.cap = cap; this.top = -1; }

  push(v) {
    if (this.top + 1 === this.cap) return false;   // full
    this.buf[++this.top] = v;
    return true;
  }
  pop() {
    if (this.top < 0) return undefined;            // empty
    return this.buf[this.top--];
  }
  peek() { return this.top < 0 ? undefined : this.buf[this.top]; }
  get empty() { return this.top < 0; }
  get size()  { return this.top + 1; }
}
```
]

Tested with capacity 3: pushing 7, 8, 9, 10 prints `true true true false` — the fourth
push is refused. `peek` then gives `9`, size `3`. Popping everything prints `9 8 7`, and
one more `pop` returns `undefined` with `empty` true.

#trick[
In a real round just write `const st = []` and use `st.push(v)`, `st.pop()` and
`st[st.length - 1]`. Write the fixed-capacity class above only when the interviewer asks
you to implement a stack, or when the question genuinely has a capacity limit. A plain
array grows on its own and is the faster of the two.
]

#trap[
`empty` and `size` above are *getters*, so you write `s.empty` and `s.size`, with no
brackets. Writing `s.empty()` throws `TypeError: s.empty is not a function`. Pick one
style per class and stay with it.
]

#ex(2, tier: 0)[
Reverse a string using a stack. Edge cases: empty string, one character.

#sol[
Push every character, then pop them all. Last in, first out *is* reversal.
]
]

#code(lang: "js", caption: "Reverse with a stack")[
```js
const reverseWithStack = (s) => {
  const st = [];
  for (const c of s) st.push(c);
  let out = '';
  while (st.length) out += st.pop();
  return out;
};
```
]

Tested: `"stack"` gives `kcats`; `""` gives the empty string; `"a"` gives `a`;
`"aa bb"` gives `bb aa`.

#complexity(time: "O(n)", space: "O(n)")

#ex(3, tier: 0)[
Only round brackets. Is the string balanced? Edge cases: empty, `")("`, unclosed.

#sol[
With *one* kind of bracket you do not need a stack at all. A counter is enough — but it
must never go below zero, otherwise a `)` arrived with nothing to close.
]
]

#code(lang: "js", caption: "One bracket kind: a counter")[
```js
const balancedRound = (s) => {
  let open = 0;
  for (const c of s) {
    if (c === '(') open++;
    else if (c === ')') { open--; if (open < 0) return false; }
  }
  return open === 0;
};
```
]

Tested: `"(()())"` $arrow.r$ `true`; `"(()"` $arrow.r$ `false`;
`")("` $arrow.r$ `false`; `""` $arrow.r$ `true`; `"("` $arrow.r$ `false`.

#note[
The `if (open < 0) return false;` line is the whole difficulty. Without it, `")("`
ends at `open == 0` and you wrongly report balanced.
]

#ex(4, tier: 0)[
For every index, find the nearest value to its *left* that is strictly greater.
Write the obvious $O(n^2)$ version first — Tier 1 makes it $O(n)$.
Edge cases: empty, all equal, decreasing.

#sol[
From each index walk left until something bigger shows up.
]
]

#code(lang: "js", caption: "Previous greater — brute force")[
```js
const prevGreaterBrute = (a) => {
  const n = a.length;
  const out = new Array(n).fill(-1);
  for (let i = 0; i < n; i++)
    for (let j = i - 1; j >= 0; j--)
      if (a[j] > a[i]) { out[i] = a[j]; break; }
  return out;
};
```
]

Tested: `[2,5,3,8,1]` gives `[-1,-1,5,-1,8]`; `[]` gives `[]`; `[4]` gives `[-1]`;
`[3,3,3]` gives `[-1,-1,-1]` (strictly greater, so equals do not count);
`[-1,-5]` gives `[-1,-1]`.

#complexity(time: "O(n^2)", space: "O(1) extra")

#ex(5, tier: 0)[
Repeatedly delete any two *neighbouring* equal characters, until none are left.
Edge cases: empty, one character, everything cancels.

#sol[
Use an array of characters as a stack. If the new character equals the top, they cancel:
pop instead of push. Join the survivors at the end.
]
]

#code(lang: "js", caption: "Cancel adjacent equal pairs")[
```js
const crushAdjacent = (s) => {
  const st = [];                     // an array of characters, used as a stack
  for (const c of s) {
    if (st.length && st[st.length - 1] === c) st.pop();
    else st.push(c);
  }
  return st.join('');
};
```
]

Tested: `"abbaca"` gives `ca`; `"aabb"` gives the empty string; `""` gives empty;
`"x"` gives `x`; `"abccba"` gives empty.

#trap[
Do *not* try to use a JavaScript string as the stack. Strings are immutable: there is no
`pop`, and `s[i] = 'x'` silently does nothing. Push characters into an array and
`join('')` at the end. Building the answer with `out += c` in a loop is fine for short
strings, but for $10^5$ characters the array-then-join version is the one to write.
]

#note[
Trace `"abbaca"`: push `a`, push `b`, `b` matches so pop $arrow.r$ `a`, `a` matches so
pop $arrow.r$ empty, push `c`, push `a` $arrow.r$ `ca`. The cancellation *cascades*, and
the stack handles that for free.
]

#ex(6, tier: 0)[
A stack that also reports its minimum in $O(1)$. Edge cases: duplicates of the minimum,
popping the minimum, negative values.

#sol[
Keep a second array the same height as the first. Slot `i` of it holds the minimum of
the first `i + 1` items. Then `getMin` is just the last slot of `mins`.
]
]

#code(lang: "js", caption: "Min stack with a parallel stack")[
```js
class MinStack {
  constructor() { this.main = []; this.mins = []; }

  push(v) {
    this.main.push(v);
    const top = this.mins[this.mins.length - 1];
    this.mins.push(this.mins.length === 0 || v <= top ? v : top);   // <= keeps duplicates safe
  }
  pop() {
    if (this.main.length === 0) return undefined;
    this.mins.pop();
    return this.main.pop();
  }
  top()    { return this.main[this.main.length - 1]; }
  getMin() { return this.mins[this.mins.length - 1]; }
  get empty() { return this.main.length === 0; }
}
```
]

Pushing 5, 2, 2, 9 reports minimum `5 2 2 2`. Popping back reports `2 2 5`. Popping an
empty stack returns `undefined` instead of crashing. With `-4` then `-9`, `getMin` is
`-9` and `top` is `-9`.

#complexity(time: "O(1) per operation", space: "O(n) extra")

#section[Tier 1 — the placement standards]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
For every element, find the next strictly greater element to its right. $-1$ if none.
$n <= 10^5$. Target $O(n)$.
Edge cases: empty, one element, all equal, strictly decreasing, negatives.
]

#sol[
#approach(1, "Look right from every index", verdict: "O(n^2) — 10^10 steps at n = 10^5")
]

#code(lang: "js", caption: "Approach 1 — brute force")[
```js
const ngeBrute = (a) => {
  const n = a.length;
  const out = new Array(n).fill(-1);
  for (let i = 0; i < n; i++)
    for (let j = i + 1; j < n; j++)
      if (a[j] > a[i]) { out[i] = a[j]; break; }
  return out;
};
```
]

#approach(2, "Monotonic stack, walking right to left", verdict: "O(n) — optimal")

Walk backwards. The stack holds the values to the right that could still be somebody's
answer. Before pushing `a[i]`, pop everything $<=$ `a[i]`: those values are both smaller
*and* further away, so nothing on the left will ever choose them over `a[i]`.

#code(lang: "js", caption: "Approach 2 — monotonic stack")[
```js
const ngeStack = (a) => {
  const n = a.length;
  const out = new Array(n).fill(-1);
  const st = [];                              // values, decreasing bottom -> top
  for (let i = n - 1; i >= 0; i--) {
    while (st.length && st[st.length - 1] <= a[i]) st.pop();  // too small, never useful again
    if (st.length) out[i] = st[st.length - 1];
    st.push(a[i]);
  }
  return out;
};
```
]

Both agree on every test:

#table(columns: 2,
  [*input*], [*output*],
  [`[4,1,2,6,3]`], [`[6,2,6,-1,-1]`],
  [`[]`], [`[]`],
  [`[5]`], [`[-1]`],
  [`[3,3,3]`], [`[-1,-1,-1]`],
  [`[9,8,7]`], [`[-1,-1,-1]`],
  [`[-5,-2,-9]`], [`[-2,-1,-1]`],
)

#complexity(time: "O(n) — each element is pushed once and popped at most once", space: "O(n)")

#note[
*The idea that unlocked it:* the inner loop kept re-reading the same elements. The stack
*remembers* them, already filtered down to the ones that can still win.
]

#ex(8, tier: 1, asked: "Infosys · pattern")[
Nearest strictly smaller element to the *left*, for every index. $-1$ if none.
$n <= 10^5$. Edge cases: empty, all equal, increasing, negatives.
]

#sol[
Mirror image of Example 7: walk *forwards*, and pop while the top is $>=$ the current
value. Now the stack is increasing from bottom to top.
]

#code(lang: "js", caption: "Previous smaller element")[
```js
const prevSmaller = (a) => {
  const n = a.length;
  const out = new Array(n).fill(-1);
  const st = [];                    // values, increasing bottom -> top
  for (let i = 0; i < n; i++) {
    while (st.length && st[st.length - 1] >= a[i]) st.pop();
    if (st.length) out[i] = st[st.length - 1];
    st.push(a[i]);
  }
  return out;
};
```
]

Tested: `[4,5,2,10,8]` gives `[-1,4,-1,2,2]`; `[]` gives `[]`; `[7]` gives `[-1]`;
`[2,2,2]` gives `[-1,-1,-1]`; `[-1,-3,0]` gives `[-1,-1,-3]`.

#trick[
Memorise the four-way table from page one and stop re-deriving it:
*direction of the walk* is opposite to the side you are asked about; *the pop test* uses
the opposite comparison of the word in the question.
]

#ex(9, tier: 1, asked: "Wipro · pattern")[
Three bracket kinds: `()`, `[]`, `[]`. Other characters may appear and are ignored.
Is the string balanced? $n <= 10^5$.
Edge cases: empty, `"{[(])}"`, an unmatched closer at the very start.
]

#sol[
With more than one kind, a counter no longer works, because the *order* of closing
matters. Push every opener. On a closer, the top must be the matching opener.
]

#code(lang: "js", caption: "Three bracket kinds")[
```js
const balanced = (s) => {
  const st = [];
  const match = { ')': '(', ']': '[', '}': '{' };   // closer -> its opener
  for (const c of s) {
    if (c === '(' || c === '[' || c === '{') st.push(c);
    else if (c in match) {
      if (st.length === 0) return false;            // closer with nothing open
      if (st.pop() !== match[c]) return false;      // wrong kind
    }
    // any other character is ignored
  }
  return st.length === 0;                           // nothing may be left open
};
```
]

Tested: `"{[()]}"` $arrow.r$ `true`; `"{[(])}"` $arrow.r$ `false`;
`""` $arrow.r$ `true`; `"("` $arrow.r$ `false`; `")"` $arrow.r$ `false`;
`"a(b[c]d)e"` $arrow.r$ `true`.

#trap[
Three separate failures, all needed:
+ a closer when the stack is empty,
+ a closer whose top is the *wrong* opener,
+ a non-empty stack at the end.
Most wrong submissions check only the third.
]

#complexity(time: "O(n)", space: "O(n)")

#ex(10, tier: 1, asked: "Capgemini · pattern")[
Evaluate a postfix (reverse Polish) expression. Tokens are separated by single spaces.
Operators are `+ - * /`. Numbers may be negative. Results can exceed $2^31$.
Edge cases: a single number, a product of two large numbers.
]

#sol[
Push numbers. On an operator, pop *two* values — the second pop is the *left* operand —
apply, push the result back. At the end one value is left.
]

#code(lang: "js", caption: "Postfix evaluation")[
```js
const evalPostfix = (expr) => {
  const st = [];
  for (const tok of expr.split(/\s+/).filter(t => t.length)) {
    if (tok.length === 1 && '+-*/'.includes(tok)) {
      const b = st.pop();                   // RIGHT operand pops first
      const a = st.pop();                   // LEFT operand
      if (tok === '+') st.push(a + b);
      else if (tok === '-') st.push(a - b);
      else if (tok === '*') st.push(a * b);
      else st.push(Math.trunc(a / b));      // integer division: JS / gives 4.5
    } else {
      st.push(Number(tok));
    }
  }
  return st.pop();
};
```
]

Tested:

#table(columns: 3,
  [*expression*], [*meaning*], [*result*],
  [`3 4 +`], [$3 + 4$], [7],
  [`5 1 2 + 4 * + 3 -`], [$5 + (1+2) times 4 - 3$], [14],
  [`7`], [just a number], [7],
  [`-4 5 *`], [$-4 times 5$], [-20],
  [`9 2 /`], [integer division], [4],
  [`100000 100000 *`], [$10^10$], [10000000000],
)

#trap[
Order of the two pops. For `-` and `/` it changes the answer. The *first* pop is the
right-hand operand. Test with `9 2 /`: if you get 0 you swapped them.
]

#trap[
*JavaScript division is not integer division.* `9 / 2` is `4.5`, not `4`. Wrap it in
`Math.trunc` for the toward-zero answer that C-style languages give: `Math.trunc(-9 / 2)`
is `-4`, while `Math.floor(-9 / 2)` is `-5`. Tested: with `Math.trunc`, `9 2 /` gives
`4` and `-9 2 /` gives `-4`.
]

#note[
There is no separate wide integer type in JavaScript, but there is still a limit. Every
JavaScript number is a double, exact only up to `Number.MAX_SAFE_INTEGER` $= 9007199254740991$, about
$9 times 10^15$. Tested: `100000 100000 *` gives `10000000000` exactly, because $10^10$
is far below that line. A product that can pass $9 times 10^15$ needs `BigInt` — you will
see exactly that in Example 18.
]

#ex(11, tier: 1, asked: "Accenture · pattern")[
A stack with $O(1)$ `getMin`, but use as little extra memory as you can.
Edge cases: duplicate minimums, popping the minimum, single element.
]

#sol[
#approach(1, "Parallel stack of running minimums", verdict: "O(n) extra, always n slots")
]

#code(lang: "js", caption: "Approach 1 — one helper slot per item")[
```js
class MinStackPair {
  constructor() { this.a = []; this.m = []; }
  push(v) { this.a.push(v); this.m.push(this.m.length ? Math.min(this.m[this.m.length - 1], v) : v); }
  pop()   { this.m.pop(); return this.a.pop(); }
  top()    { return this.a[this.a.length - 1]; }
  getMin() { return this.m[this.m.length - 1]; }
}
```
]

#approach(2, "Push a helper entry only when a NEW minimum arrives", verdict: "O(n) worst case but usually far less")

#code(lang: "js", caption: "Approach 2 — lazy helper stack")[
```js
class MinStackLazy {
  constructor() { this.a = []; this.m = []; }
  push(v) { this.a.push(v); if (!this.m.length || v <= this.m[this.m.length - 1]) this.m.push(v); }
  pop()   { const v = this.a.pop(); if (v === this.m[this.m.length - 1]) this.m.pop(); return v; }
  top()    { return this.a[this.a.length - 1]; }
  getMin() { return this.m[this.m.length - 1]; }
}
```
]

Both were run side by side on the same calls and reported the same minimum every
time. Pushing `6, 3, 3, 8, 1, 9`:

#table(columns: 3,
  [*pushed*], [*minimum (approach 1)*], [*minimum (approach 2)*],
  [6], [6], [6],
  [3], [3], [3],
  [3], [3], [3],
  [8], [3], [3],
  [1], [1], [1],
  [9], [1], [1],
)

Then popping all the way back down:

#table(columns: 3,
  [*top before the pop*], [*minimum (approach 1)*], [*minimum (approach 2)*],
  [9], [1], [1],
  [1], [1], [1],
  [8], [3], [3],
  [3], [3], [3],
  [3], [3], [3],
  [6], [6], [6],
)

#trap[
The comparison must be `v <= top`, not `v < top`. Push 2, then 2, then pop once: with
the strict `<` the helper array holds only one `2`, the pop removes it, and `getMin` then
reads a stale older minimum — or `undefined` if the helper is now empty, which turns every
later comparison into `false` with no error. Tested: `push(2) push(2) pop()` reports
minimum `2`, as it must.
]

Tier 3 shows a version with *no* second stack at all.

#ex(12, tier: 1, asked: "Cognizant · pattern")[
Items $1, 2, dots, n$ are pushed in that order, with pops allowed at any moment. Given a
claimed output order, is it producible? $n <= 10^5$.
Edge cases: empty, already-sorted output, fully reversed output, `[3,1,2]`.
]

#sol[
Simulate. Whenever the stack top is the next wanted item, pop it. Otherwise push the
next unused item. If neither is possible, the order is impossible.
]

#code(lang: "js", caption: "Stack permutation check")[
```js
const canProduce = (want) => {
  const n = want.length;
  const st = [];
  let next = 1, k = 0;
  while (k < n) {
    if (st.length && st[st.length - 1] === want[k]) { st.pop(); k++; }
    else if (next <= n) st.push(next++);
    else return false;               // nothing left to push and the top is wrong
  }
  return true;
};
```
]

Tested: `[2,1,3]` $arrow.r$ `true`; `[3,1,2]` $arrow.r$ `false`;
`[]` $arrow.r$ `true`; `[1]` $arrow.r$ `true`; `[4,3,2,1]` $arrow.r$ `true`;
`[1,2,3,4]` $arrow.r$ `true`.

#note[
Why is `[3,1,2]` impossible? To pop 3 first, 1 and 2 must already be on the stack with
2 above 1. So after 3 comes out, the top is 2 — you cannot reach 1 first.
]

#complexity(time: "O(n) — each item is pushed once and popped once", space: "O(n)")

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
Decode a nested repeat string. `3[ab2[c]]` means `ab` followed by `c` twice, all of that
three times. Counts can be multi-digit. Nesting depth up to 30.
Edge cases: no brackets at all, a zero repeat count, a two-digit count, empty input.
]

#sol[
Two stacks: one of repeat counts, one of the text built *before* each `[`.
On `[`, save the count and the text so far, then start fresh.
On `]`, pop the count and the saved text, and append the current text that many times.
]

#code(lang: "js", caption: "Decode nested repeats")[
```js
const decode = (s) => {
  const textStack = [], numStack = [];
  let cur = '', num = 0;
  for (const c of s) {
    if (c >= '0' && c <= '9') {
      num = num * 10 + Number(c);        // counts can be multi-digit
    } else if (c === '[') {
      numStack.push(num); num = 0;       // reset num right after pushing it
      textStack.push(cur); cur = '';
    } else if (c === ']') {
      const k = numStack.pop();
      cur = textStack.pop() + cur.repeat(k);
    } else {
      cur += c;
    }
  }
  return cur;
};
```
]

Tested:

#table(columns: 2,
  [*input*], [*output*],
  [`3[ab2[c]]`], [`abccabccabcc`],
  [`2[xy]`], [`xyxy`],
  [`plain`], [`plain`],
  [(empty)], [(empty)],
  [`0[gone]tail`], [`tail`],
  [`12[a]`], [`aaaaaaaaaaaa`],
)

#trap[
`num = num * 10 + (c - '0')` and resetting `num = 0` right after pushing it. Forget the
reset and `2[a]3[b]` reads the second count as 23.
]

#ex(14, tier: 1, asked: "Wipro · pattern")[
Delete every run of exactly `k` equal neighbours, repeatedly, until no such run exists.
$n <= 10^5$, $2 <= k <= 10^4$.
Edge cases: empty, one character, a run that becomes `k` only after an inner run vanishes.
]

#sol[
Store *pairs* on the stack: the character and how many of it are stacked in a row. When
a count reaches `k`, drop the whole entry. Cascading is automatic — after dropping, the
new top may merge with the next incoming character.
]

#code(lang: "js", caption: "Stack of (character, run length)")[
```js
const crushRuns = (s, k) => {
  const st = [];                           // [character, how many in a row]
  for (const c of s) {
    if (st.length && st[st.length - 1][0] === c) {
      if (++st[st.length - 1][1] === k) st.pop();
    } else {
      st.push([c, 1]);
    }
  }
  return st.map(([ch, n]) => ch.repeat(n)).join('');
};
```
]

Tested: `("deeedbbcccbdaa", 3)` gives `aa`; `("pbbcggttciiippooaais", 2)` gives `ps`;
`("", 2)` gives empty; `("a", 2)` gives `a`; `("aaaa", 2)` gives empty.

#note[
Trace `"deeedbbcccbdaa"` with $k = 3$: `eee` goes, leaving `d d bb ccc b d aa`; `ccc`
goes, so the two `b`s meet and become `bbb`, which goes; then `ddd` forms and goes; only
`aa` is left. One pass of the stack does all of that.
]

#complexity(time: "O(n)", space: "O(n)")

#ex(15, tier: 1, asked: "Infosys · pattern")[
The *span* of day `i` is how many days back, counting today, the price was less than or
equal to today's price. $n <= 10^5$. Target $O(n)$.
Edge cases: empty, one day, all equal, strictly increasing.
]

#sol[
#approach(1, "Walk backwards from each day", verdict: "O(n^2)")
]

#code(lang: "js", caption: "Approach 1 — brute force")[
```js
const spanBrute = (p) => {
  const n = p.length;
  const s = new Array(n).fill(1);
  for (let i = 0; i < n; i++) {
    let j = i - 1;
    while (j >= 0 && p[j] <= p[i]) { s[i]++; j--; }
  }
  return s;
};
```
]

#approach(2, "Monotonic stack of INDICES", verdict: "O(n) — optimal")

The span ends at the nearest day on the left with a *strictly greater* price. So find
that day's index with a stack and subtract.

#code(lang: "js", caption: "Approach 2 — stack of indices")[
```js
const spanStack = (p) => {
  const n = p.length;
  const s = new Array(n).fill(0);
  const st = [];                              // indices, prices decreasing
  for (let i = 0; i < n; i++) {
    while (st.length && p[st[st.length - 1]] <= p[i]) st.pop();
    s[i] = st.length === 0 ? i + 1 : i - st[st.length - 1];
    st.push(i);
  }
  return s;
};
```
]

Both agree: `[100,80,60,70,60,75,85]` gives `[1,1,1,2,1,4,6]`; `[]` gives `[]`;
`[5]` gives `[1]`; `[4,4,4]` gives `[1,2,3]`; `[1,2,3]` gives `[1,2,3]`.

#trap[
`st.length === 0 ? i + 1 : i - st[st.length - 1]`. When nothing on the left is bigger,
the span reaches back to day 0, which is `i + 1` days *including today*, not `i`. Test
`[1,2,3]`: the answer must be `[1,2,3]`.
]

#note[
*The idea that unlocked it:* this is "previous greater element", but you keep the
*index* instead of the value, because the question asks for a distance.
]

#section[Tier 2 — applied, two or three steps]
#tier-header(2)

#ex(16, tier: 2, asked: "Grab · pattern")[
Bars of width 1 stand side by side, bar `i` has height `h[i]`. Find the largest
rectangle that fits entirely inside them. $n <= 10^5$, heights up to $10^5$.
The answer can exceed $2^31$.
Edge cases: empty, one bar, all equal, strictly increasing, all zeros.
]

#sol[
#approach(1, "Fix the left edge, walk right, track the minimum height", verdict: "O(n^2)")
]

#code(lang: "js", caption: "Approach 1 — brute force")[
```js
const histBrute = (h) => {
  let best = 0;
  const n = h.length;
  for (let i = 0; i < n; i++) {
    let lo = Infinity;
    for (let j = i; j < n; j++) {
      lo = Math.min(lo, h[j]);                        // the shortest bar so far
      best = Math.max(best, lo * (j - i + 1));
    }
  }
  return best;
};
```
]

#approach(2, "Monotonic stack of indices", verdict: "O(n) — optimal")

Ask a different question: *for each bar, how wide can a rectangle of exactly that height
be?* It stretches left until a shorter bar, and right until a shorter bar. A monotonic
stack finds both boundaries in one pass.

Keep indices with *increasing* heights. When a shorter bar arrives at index `i`, every
taller bar on the stack is finished: its rectangle ends just before `i`, and starts just
after whatever is below it on the stack.

#code(lang: "js", caption: "Approach 2 — one pass")[
```js
const histStack = (h) => {
  const n = h.length;
  let best = 0;
  const st = [];                       // indices, heights increasing bottom -> top
  for (let i = 0; i <= n; i++) {
    const cur = i === n ? 0 : h[i];    // a virtual height-0 bar flushes the stack
    while (st.length && h[st[st.length - 1]] >= cur) {
      const height = h[st.pop()];
      const left = st.length ? st[st.length - 1] : -1;
      best = Math.max(best, height * (i - left - 1));
    }
    st.push(i);
  }
  return best;
};
```
]

Both agree:

#table(columns: 2,
  [*heights*], [*largest area*],
  [`[2,1,5,6,2,3]`], [10],
  [`[]`], [0],
  [`[7]`], [7],
  [`[3,3,3]`], [9],
  [`[5,4,3,2,1]`], [9],
  [`[1,2,3,4,5]`], [9],
  [`[0,0]`], [0],
)

With 100000 bars all of height 100000 the answer is `10000000000` — $10^10$. That is
still exact in JavaScript, because $10^10$ is far below `Number.MAX_SAFE_INTEGER`
$= 9007199254740991$. Tested in Node: the value comes back as `10000000000`, and
`10000000000 <= Number.MAX_SAFE_INTEGER` is `true`.

#trap[
Three details decide whether this works.
+ The virtual bar `cur = 0` at `i == n`. Without it, bars still on the stack at the end
  are never measured. Test `[1,2,3,4,5]`.
+ `width = i - left - 1`, where `left` is the index *below* the popped one. It is not
  `i - popped`. The rectangle spreads left past every bar that was popped before it.
+ The multiply. `height * width` at $10^5 times 10^5$ is $10^10$, which JavaScript
  still holds exactly. Check the limit every time: if the product could pass
  $9 times 10^15$ you must switch to `BigInt`, as Example 18 does.
]

The full dry run of this algorithm is at the end of the chapter.

#complexity(time: "O(n)", space: "O(n)")

#ex(17, tier: 2, asked: "Shopee · pattern")[
Rain falls on the same bars. How much water is trapped? $n <= 10^5$.
Edge cases: empty, one bar, strictly decreasing (no water), a flat pair.
]

#sol[
#approach(1, "For each column, scan both ways for the tallest wall", verdict: "O(n^2)")
]

Water above column `i` is $min("tallest on the left", "tallest on the right") - h[i]$.

#code(lang: "js", caption: "Approach 1 — brute force")[
```js
const rainBrute = (h) => {
  const n = h.length;
  let total = 0;
  for (let i = 0; i < n; i++) {
    let L = 0, R = 0;
    for (let j = 0; j <= i; j++) L = Math.max(L, h[j]);
    for (let j = i; j < n; j++) R = Math.max(R, h[j]);
    total += Math.min(L, R) - h[i];
  }
  return total;
};
```
]

#approach(2, "Precompute both wall arrays", verdict: "O(n) time, O(n) memory")

#code(lang: "js", caption: "Approach 2 — two prefix passes")[
```js
const rainPrefix = (h) => {
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
};
```
]

#approach(3, "Monotonic stack: fill one flat basin per pop", verdict: "O(n), single pass")

Keep indices with *decreasing* heights. When a taller bar arrives, the bar on top of the
stack is the floor of a basin: the left wall is the next item down, the right wall is the
new bar.

#code(lang: "js", caption: "Approach 3 — stack, layer by layer")[
```js
const rainStack = (h) => {
  const st = [];                       // indices, heights decreasing
  let total = 0;
  for (let i = 0; i < h.length; i++) {
    while (st.length && h[st[st.length - 1]] < h[i]) {
      const floorIdx = st.pop();
      if (st.length === 0) break;                     // no left wall, no basin
      const leftIdx = st[st.length - 1];
      const width = i - leftIdx - 1;
      const depth = Math.min(h[leftIdx], h[i]) - h[floorIdx];
      total += width * depth;
    }
    st.push(i);
  }
  return total;
};
```
]

All three agree:

#table(columns: 2,
  [*heights*], [*water*],
  [`[0,2,0,3,1,0,1,3]`], [9],
  [`[]`], [0],
  [`[4]`], [0],
  [`[3,3]`], [0],
  [`[5,4,3,2,1]`], [0],
  [`[2,0,2]`], [2],
)

#note[
The stack version fills water in *horizontal layers*, not columns. For `[0,2,0,3,1,0,1,3]`
it first fills the small dip at index 2, then the wide dip from index 4 to 6, layer by
layer as each wall is discovered.
]

#trap[
`if (st.length === 0) break;` after the pop. If nothing is below the popped bar, there
is no left wall, so there is no basin — water would run off the edge. Miss this and
`st[st.length - 1]` quietly evaluates to `undefined`; JavaScript does not crash, it just
produces `NaN` and every later total is `NaN`. A silent wrong answer is worse than a
crash, so write the guard.
]

#ex(18, tier: 2, asked: "GIC · pattern")[
Sum `min(subarray)` over *every* contiguous subarray. Give the answer modulo $10^9 + 7$.
$n <= 3 times 10^4$, values positive.
Edge cases: empty, one element, all equal (the duplicate trap), sorted both ways.
]

#sol[
#approach(1, "Every subarray", verdict: "O(n^2) — fine for n = 3*10^4? no, 9*10^8 steps")
]

#code(lang: "js", caption: "Approach 1 — brute force (used only to check)")[
```js
const MOD = 1000000007;

const sumMinBrute = (a) => {
  let total = 0;
  const n = a.length;
  for (let i = 0; i < n; i++) {
    let lo = Infinity;
    for (let j = i; j < n; j++) { lo = Math.min(lo, a[j]); total = (total + lo) % MOD; }
  }
  return total;
};
```
]

#approach(2, "Contribution counting with two monotonic stacks", verdict: "O(n) — optimal")

Flip the question. Instead of *"what is the minimum of this subarray?"*, ask
*"how many subarrays have `a[i]` as their minimum?"* Then

$ "answer" = sum_i a[i] times ("count of subarrays where " a[i] " is the minimum") $

Let `left[i]` be how many choices of start keep `a[i]` the minimum, and `right[i]` how
many choices of end. The count is `left[i] * right[i]`.

#trap[
With equal values, "the minimum" is ambiguous and you double-count. Fix it by breaking
ties in *one direction only*: use strictly-smaller on the left (`>` in the pop test) and
smaller-or-equal on the right (`>=` in the pop test). Then for a block of equal values,
each subarray is credited to exactly one of them.
]

#code(lang: "js", caption: "Approach 2 — count each element's reign")[
```js
const sumMinStack = (a) => {
  const n = a.length;
  const left = new Array(n), right = new Array(n);
  let st = [];
  for (let i = 0; i < n; i++) {                 // previous STRICTLY smaller
    while (st.length && a[st[st.length - 1]] > a[i]) st.pop();
    left[i] = st.length ? i - st[st.length - 1] : i + 1;
    st.push(i);
  }
  st = [];
  for (let i = n - 1; i >= 0; i--) {            // next smaller OR EQUAL
    while (st.length && a[st[st.length - 1]] >= a[i]) st.pop();
    right[i] = st.length ? st[st.length - 1] - i : n - i;
    st.push(i);
  }
  let total = 0n;                               // BigInt: the products pass 2^53
  const M = BigInt(MOD);
  for (let i = 0; i < n; i++)
    total = (total + BigInt(a[i]) * BigInt(left[i]) * BigInt(right[i])) % M;
  return Number(total);
};
```
]

Both agree:

#table(columns: 2,
  [*array*], [*sum of minima*],
  [`[3,1,2,4]`], [17],
  [`[]`], [0],
  [`[5]`], [5],
  [`[2,2,2]`], [12],
  [`[1,2,3,4,5]`], [35],
  [`[4,3,2,1]`], [20],
)

They were also checked against each other on 300 random arrays of length up to 8 with
values 1..5, and every single one agreed.

#trap[
*This is the chapter's `BigInt` problem.* `left[i] * right[i]` can be as large as $n^2$,
and with $n = 3 times 10^4$ that is $9 times 10^8$. Multiply by a value of $10^9$ and one
term reaches $9 times 10^17$ — far past `Number.MAX_SAFE_INTEGER`
$= 9007199254740991 approx 9 times 10^15$. Tested in Node:
`1e9 * 30000 * 30000 <= Number.MAX_SAFE_INTEGER` is `false`, so plain numbers would
silently round and the modulo would be wrong with no warning.

`BigInt` fixes it exactly: write the literal `0n`, convert with `BigInt(x)`, and take
`Number(total)` at the very end. You may never mix the two — `1n + 1` throws
`TypeError: Cannot mix BigInt and other types`. Tested on 30000 copies of $10^9$:
the answer is `849895028`.
]

Hand check for `[3,1,2,4]`: the ten subarrays have minima
$3, 1, 1, 1, 1, 1, 1, 2, 2, 4$, total 17. The formula gives
$3 times 1 times 1 + 1 times 2 times 3 + 2 times 1 times 2 + 4 times 1 times 1 = 3 + 6 + 4 + 4 = 17$.

#note[
*The idea that unlocked it:* stop iterating over subarrays and start iterating over
*elements*, asking how many subarrays each one owns. This "contribution" move reappears
in Tier 3 and in the DP chapters.
]

#ex(19, tier: 2, asked: "Agoda · pattern")[
Delete exactly `k` digits from a digit string so that the remaining number is the
smallest possible. Keep the digits in their original order. Length up to $10^5$.
Edge cases: the result starts with zeros, `k` equals the length, an already-increasing
string.
]

#sol[
Greedy with a stack. Scan left to right. If the new digit is smaller than the digit on
top and you still have deletions left, the top digit is wasting a high place value —
remove it. Each removal makes the number strictly smaller, so removing as early as
possible is always right.
]

#code(lang: "js", caption: "Remove k digits, keep it smallest")[
```js
const removeKDigits = (num, k) => {
  const st = [];
  for (const c of num) {
    while (k > 0 && st.length && st[st.length - 1] > c) { st.pop(); k--; }
    st.push(c);
  }
  while (k > 0 && st.length) { st.pop(); k--; }      // still digits to drop
  let i = 0;
  while (i + 1 < st.length && st[i] === '0') i++;    // strip leading zeros
  const out = st.slice(i).join('');
  return out === '' ? '0' : out;
};
```
]

Tested:

#table(columns: 3,
  [*input*], [*k*], [*result*],
  [`1432219`], [3], [`1219`],
  [`10200`], [1], [`200`],
  [`10`], [2], [`0`],
  [`112`], [1], [`11`],
  [`9`], [0], [`9`],
  [`54321`], [2], [`321`],
)

#trap[
Three endings, all needed.
+ The string is already increasing (`112`, `12345`): no pop ever fires, so the leftover
  `k` must be removed *from the end*.
+ Leading zeros: `10200` with $k = 1$ leaves `0200`, which must print as `200`.
+ Everything removed: return `"0"`, not the empty string.
]

#ex(20, tier: 2, asked: "Razer · pattern")[
Trolleys move on one straight track. A positive value means it moves right, negative
means left; the size is its mass. When a right-mover meets a left-mover, the lighter one
is destroyed; equal masses destroy each other. Return the surviving trolleys in order.
$n <= 10^4$.
Edge cases: empty, no collisions possible, a chain reaction, an exact tie.
]

#sol[
Only a right-mover on the stack followed by a left-mover arriving can collide. That is
exactly `st.back() > 0 && cur < 0`. Loop, because destroying one survivor may expose
another one behind it.
]

#code(lang: "js", caption: "Collision simulation")[
```js
const collide = (t) => {
  const st = [];
  for (const cur of t) {
    let alive = true;
    while (alive && st.length && st[st.length - 1] > 0 && cur < 0) {
      const top = st[st.length - 1];
      if (Math.abs(top) < Math.abs(cur)) st.pop();                // left wins, keep going
      else if (Math.abs(top) === Math.abs(cur)) { st.pop(); alive = false; }
      else alive = false;                                         // right wins
    }
    if (alive) st.push(cur);
  }
  return st;
};
```
]

Tested:

#table(columns: 2,
  [*input*], [*survivors*],
  [`[5,10,-5]`], [`[5,10]`],
  [`[8,-8]`], [`[]`],
  [`[10,2,-5]`], [`[10]`],
  [`[]`], [`[]`],
  [`[-2,-1,1,2]`], [`[-2,-1,1,2]`],
  [`[1,-1,1,-1]`], [`[]`],
)

#note[
`[-2,-1,1,2]` has no collisions at all: the left-movers are already to the left of the
right-movers, so they move apart forever. The stack condition `st.back() > 0 && cur < 0`
catches this for free.
]

#trap[
The `alive` flag. When the arriving trolley is destroyed you must *stop the loop and not
push it*. A `break` alone is not enough; you also need to skip the push.
]

#ex(21, tier: 2, asked: "Sea / Shopee · pattern")[
Next greater element, but the array is *circular*: after the last element comes the
first again. $n <= 10^5$.
Edge cases: empty, one element, all equal, strictly decreasing.
]

#sol[
Walk right to left *twice* over the same array. The first lap only fills the stack with
the wrap-around candidates; the second lap records answers. No copy of the array is
needed — just index with `% n`.
]

#code(lang: "js", caption: "Circular next greater")[
```js
const ngeCircular = (a) => {
  const n = a.length;
  const out = new Array(n).fill(-1);
  const st = [];                            // indices
  for (let pass = 0; pass < 2 * n; pass++) {
    const i = (2 * n - 1 - pass) % n;
    while (st.length && a[st[st.length - 1]] <= a[i]) st.pop();
    if (pass >= n && st.length) out[i] = a[st[st.length - 1]];
    st.push(i);
  }
  return out;
};
```
]

Checked against a brute force that tries every offset. They agree:

#table(columns: 2,
  [*input*], [*output*],
  [`[3,8,4,1,2]`], [`[8,-1,8,2,3]`],
  [`[]`], [`[]`],
  [`[6]`], [`[-1]`],
  [`[2,2,2]`], [`[-1,-1,-1]`],
  [`[5,4,3,2,1]`], [`[-1,5,5,5,5]`],
  [`[-3,-1,-7]`], [`[-1,-1,-3]`],
)

#note[
Read `[5,4,3,2,1]`: index 0 holds the largest value, so it has no greater element
anywhere and stays $-1$. Every other index wraps around and finds the 5.
]

#trap[
`if (pass >= n ...)`. Record answers only on the second lap. Record on the first and
indices near the end of the array get answers computed from an unfinished stack.
]

#section[Tier 3 — needs an insight]
#tier-header(3)

#ex(22, tier: 3, asked: "Google · pattern")[
A grid of 0s and 1s. Find the area of the largest all-1 rectangle.
Rows and columns up to 200 each. Target $O(R times C)$.
Edge cases: empty grid, all zeros, all ones, a single cell.

*The follow-up:* "now the grid is a stream — rows arrive one at a time and you cannot
store them all."
]

#sol[
Read the grid row by row. For each row, build a histogram: column `c` holds *how many
consecutive 1s end at this row* in that column. A 0 resets the column to 0. Then the
answer for that row is "largest rectangle in a histogram" — Example 16, unchanged.
]

#code(lang: "js", caption: "Row by row, histogram by histogram")[
```js
const largestRectangle = (h) => {                       // exactly Example 16
  const n = h.length;
  let best = 0;
  const st = [];
  for (let i = 0; i <= n; i++) {
    const cur = i === n ? 0 : h[i];
    while (st.length && h[st[st.length - 1]] >= cur) {
      const height = h[st.pop()];
      const left = st.length ? st[st.length - 1] : -1;
      best = Math.max(best, height * (i - left - 1));
    }
    st.push(i);
  }
  return best;
};

const maximalRectangle = (g) => {
  if (g.length === 0 || g[0].length === 0) return 0;
  const cols = g[0].length;
  const h = new Array(cols).fill(0);
  let best = 0;
  for (const row of g) {
    for (let c = 0; c < cols; c++) h[c] = row[c] === 1 ? h[c] + 1 : 0;
    best = Math.max(best, largestRectangle(h));
  }
  return best;
};
```
]

Tested:

#table(columns: 2,
  [*grid*], [*largest area*],
  [`[[1,0,1,0,0],[1,0,1,1,1],[1,1,1,1,1],[1,0,0,1,0]]`], [6],
  [`[]`], [0],
  [`[[0]]`], [0],
  [`[[1]]`], [1],
  [`[[0,0],[0,0]]`], [0],
  [`[[1,1],[1,1]]`], [4],
)

The 6 comes from rows 1 and 2, columns 2 to 4: a $2 times 3$ block of ones.

#trap[
This version only *reads* the grid, so it is safe. The moment a grid problem asks you to
*change* the grid, remember that `[...grid]` is a *shallow* copy: the new outer array
holds the very same row arrays, so writing into a row of the copy also writes into the
original. Tested in Node: after `const shallow = [...g]; shallow[0][0] = 0;` the original
`g[0][0]` is `0` too. The correct deep copy of a 2-D grid is `g.map(r => [...r])` —
tested, and it leaves the original alone.
]

#complexity(time: "O(R * C)", space: "O(C)")

#subsection[The follow-up: a stream of rows]

Nothing changes. The algorithm already keeps only the current histogram `h` — one integer
per column — and the running best. Rows are consumed and discarded. Memory is $O(C)$
whatever the number of rows, so a million-row stream is fine.

#note[
*The idea that unlocked it:* a 2-D problem turned into $R$ copies of a 1-D problem you
already solved. Look for this whenever a grid question smells like a solved array
question.
]

#ex(23, tier: 3, asked: "Amazon · pattern")[
Sum over every subarray of $("max") - ("min")$. $n <= 10^5$, values may be negative.
Edge cases: empty, one element, all equal, alternating signs.

*The follow-up:* "why can you not do it with one stack pass?"
]

#sol[
$sum ("max" - "min") = sum "max" - sum "min"$. Each half is Example 18's contribution
counting, with the comparisons flipped for the max version.
]

#code(lang: "js", caption: "Approach 1 — brute force (for checking)")[
```js
const rangesBrute = (a) => {
  let total = 0;
  const n = a.length;
  for (let i = 0; i < n; i++) {
    let lo = a[i], hi = a[i];
    for (let j = i; j < n; j++) { lo = Math.min(lo, a[j]); hi = Math.max(hi, a[j]); total += hi - lo; }
  }
  return total;
};
```
]

#code(lang: "js", caption: "Approach 2 — two contribution passes")[
```js
const sumOf = (a, wantMax) => {
  const n = a.length;
  const left = new Array(n), right = new Array(n);
  let st = [];
  for (let i = 0; i < n; i++) {                       // strict on the left
    while (st.length && (wantMax ? a[st[st.length - 1]] < a[i] : a[st[st.length - 1]] > a[i])) st.pop();
    left[i] = st.length ? i - st[st.length - 1] : i + 1;
    st.push(i);
  }
  st = [];
  for (let i = n - 1; i >= 0; i--) {                  // non-strict on the right
    while (st.length && (wantMax ? a[st[st.length - 1]] <= a[i] : a[st[st.length - 1]] >= a[i])) st.pop();
    right[i] = st.length ? st[st.length - 1] - i : n - i;
    st.push(i);
  }
  let total = 0n;                                     // BigInt: value * left * right
  for (let i = 0; i < n; i++) total += BigInt(a[i]) * BigInt(left[i]) * BigInt(right[i]);
  return total;
};

const rangesStack = (a) => Number(sumOf(a, true) - sumOf(a, false));
```
]

Both agree: `[1,2,3]` gives `4`; `[]` gives `0`; `[5]` gives `0`; `[4,-2,-3,4,1]` gives
`59`; `[2,2,2]` gives `0`. They also agreed on 400 random arrays of length up to 8 with
values from $-4$ to $4$.

#subsection[The follow-up answered]

One pass cannot do it, because the max-stack and the min-stack pop at *different* moments
— a new element may finish several maxima while finishing no minimum at all. You can run
both stacks inside one `for` loop to save a traversal, but they are still two independent
stacks. Two passes is the honest answer, and the complexity is the same.

#complexity(time: "O(n)", space: "O(n)")

#ex(24, tier: 3, asked: "Microsoft · pattern")[
Longest balanced substring of a string of `(` and `)`. $n <= 10^5$.
Edge cases: empty, no valid pair, `"(()"`, `")()())"`.

*The follow-up:* "now do it in O(1) extra space."
]

#sol[
#approach(1, "Stack of indices with a sentinel", verdict: "O(n) time, O(n) space")
]

Push `-1` first. It marks *the last position that broke the balance*. On `(`, push the
index. On `)`, pop. If the stack is now empty, this `)` is itself a new breaking point,
so push its index. Otherwise the valid run reaches from just after the new top to `i`,
giving length `i - st[st.length - 1]`.

#code(lang: "js", caption: "Approach 1 — stack with a sentinel")[
```js
const longestValidStack = (s) => {
  const st = [-1];                // sentinel: the last bad position
  let best = 0;
  for (let i = 0; i < s.length; i++) {
    if (s[i] === '(') st.push(i);
    else {
      st.pop();
      if (st.length === 0) st.push(i);            // this ')' is the new breaking point
      else best = Math.max(best, i - st[st.length - 1]);
    }
  }
  return best;
};
```
]

#approach(2, "Two counter sweeps", verdict: "O(n) time, O(1) space — optimal")

Sweep left to right counting openers and closers. When they are equal, you have a valid
run of length `2 * close`. When closers overtake openers, the run is dead — reset both to
zero. That sweep alone misses runs like `"((()"`, where openers *never* get overtaken, so
sweep again from the right with the roles swapped.

#code(lang: "js", caption: "Approach 2 — two counter sweeps")[
```js
const longestValidCounters = (s) => {
  let best = 0, open = 0, close = 0;
  for (const c of s) {                          // left to right
    if (c === '(') open++; else close++;
    if (open === close) best = Math.max(best, 2 * close);
    else if (close > open) { open = 0; close = 0; }
  }
  open = 0; close = 0;
  for (let i = s.length - 1; i >= 0; i--) {     // right to left
    if (s[i] === '(') open++; else close++;
    if (open === close) best = Math.max(best, 2 * open);
    else if (open > close) { open = 0; close = 0; }
  }
  return best;
};
```
]

Both agree:

#table(columns: 2,
  [*input*], [*longest valid*],
  [`")()())"`], [4],
  [`"(()"`], [2],
  [`""`], [0],
  [`"()"`], [2],
  [`"(((("`], [0],
  [`"()(()"`], [2],
)

They were also checked against each other on 500 random bracket strings of length up to
12, with no disagreement.

#trap[
The second sweep is not optional, and it is easy to convince yourself otherwise. The
left-to-right sweep can only score a run when the closers *catch up* with the openers.
Any string with extra openers on the left never lets them catch up, so that sweep scores
nothing at all. Measured, with only the left sweep running:

#table(columns: 3,
  [*input*], [*left sweep alone*], [*both sweeps (correct)*],
  [`"(()"`], [0], [2],
  [`"(((()"`], [0], [2],
  [`"(()("`], [0], [2],
)

The right-to-left sweep is the mirror image and catches exactly these cases.
]

#ex(25, tier: 3, asked: "Goldman Sachs · pattern")[
A min-stack using *no* second stack — $O(1)$ extra space beyond the data itself.
Edge cases: duplicate minimums, popping the minimum, a very large range of values.

*The follow-up:* "what breaks if the values are near the limits of the type?"
]

#sol[
Store an *encoded* value when a new minimum arrives. If the new minimum is `v` and the
old minimum was `mn`, push `2*v - mn` instead of `v`. Because `v < mn`, that encoded
number is *smaller than `v`*, so it is smaller than the current minimum too — which makes
it recognisable later. On pop, if the popped number is below the current minimum, it is a
marker: restore `mn = 2*mn - popped`.
]

#code(lang: "js", caption: "Min stack with one extra variable")[
```js
class MinStackTiny {
  constructor() { this.st = []; this.mn = 0n; }   // BigInt: 2*v - mn can be huge

  push(v) {
    const x = BigInt(v);
    if (this.st.length === 0) { this.st.push(x); this.mn = x; return; }
    if (x < this.mn) { this.st.push(2n * x - this.mn); this.mn = x; }   // encoded marker
    else this.st.push(x);
  }
  pop() {
    if (this.st.length === 0) return;
    const t = this.st.pop();
    if (t < this.mn) this.mn = 2n * this.mn - t;   // restore the previous minimum
  }
  top() {
    const t = this.st[this.st.length - 1];
    return t < this.mn ? this.mn : t;              // a marker hides the real value
  }
  getMin() { return this.mn; }
  get empty() { return this.st.length === 0; }
}
```
]

Pushing `5, 3, 7, 2, 2, 9, -4` and reading `top/getMin` after each push gives

#code(lang: "text", caption: "measured output")[
```text
5/5  3/3  7/3  2/2  2/2  9/2  -4/-4
```
]

and popping all the way back down reads the same values in reverse:
`-4/-4  9/2  2/2  2/2  7/3  3/3  5/5`. Pushing $-10^9$ then $10^9$ gives minimum
`-1000000000n` and top `1000000000n` — the trailing `n` is how Node prints a `BigInt`.

#note[
Why does `2*v - mn` work? Write it as $v - ("mn" - v)$. Since $v < "mn"$, the term
$"mn" - v$ is positive, so the stored number is strictly below `v`. And recovering is
just algebra: if the stored number is $t = 2v - "mn"$ and `mn` currently equals `v`, then
$2 times "mn" - t = 2v - (2v - "mn"_("old")) = "mn"_("old")$.
]

#subsection[The follow-up answered]

`2*v - mn` roughly *doubles* the magnitude of the number you store. With plain
JavaScript numbers, once `2n * v - mn` passes `Number.MAX_SAFE_INTEGER`
$= 9007199254740991$ the encoding is destroyed *silently* — no error, just a wrong
minimum later. That is why the code above stores `BigInt` values: `BigInt` is exact at
any size. Tested: pushing $-2^53$ and then $-2^53 - 4$ still reports the minimum
`-9007199254740996n` correctly.

The two honest answers for the interviewer: (a) use `BigInt`, paying roughly a
$3 times$ to $10 times$ slowdown on arithmetic; (b) give up the trick and go back to a
second stack, which is $O(n)$ memory but plain fast numbers. Say the trade-off out loud —
the follow-up is asked precisely to hear it.

#ex(26, tier: 3, asked: "Adobe · pattern")[
Given a lowercase string, keep exactly one copy of every distinct letter so that the
result is the lexicographically *smallest* possible, while keeping the original relative
order. $n <= 10^5$.
Edge cases: empty, one letter, all identical, already decreasing.

*The follow-up:* "now keep exactly `k` copies of every letter."
]

#sol[
Greedy with a stack, plus one extra fact: the *last* index of each letter. Scan left to
right. Skip a letter already in the stack. Otherwise pop the top while it is bigger than
the current letter *and* it appears again later — because if it appears again later, you
can safely drop it now and pick it up again.
]

#code(lang: "js", caption: "Smallest subsequence with every letter once")[
```js
const smallestUniqueSubsequence = (s) => {
  const last = new Map();
  for (let i = 0; i < s.length; i++) last.set(s[i], i);   // last index of each letter
  const inStack = new Set();
  const st = [];
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (inStack.has(c)) continue;                         // already placed
    while (st.length && st[st.length - 1] > c && last.get(st[st.length - 1]) > i) {
      inStack.delete(st.pop());                           // it will come back later
    }
    st.push(c);
    inStack.add(c);
  }
  return st.join('');
};
```
]

Tested:

#table(columns: 2,
  [*input*], [*result*],
  [`cbacdcbc`], [`acdb`],
  [`bcabc`], [`abc`],
  [(empty)], [(empty)],
  [`a`], [`a`],
  [`aaaa`], [`a`],
  [`edcba`], [`edcba`],
)

#note[
Read `edcba`: nothing can be popped, because every letter appears exactly once, so
`last[top] > i` is always false. The greedy is forced to keep the original order. That is
the guard doing its job.
]

#trap[
Two conditions in the `while`, both required.
+ `st.back() > c` — only pop something that makes the result *bigger*.
+ `last[st.back()] > i` — only pop something you can still get back. Drop this and
  `bcabc` loses its `b` forever.
Plus the `inStack` flag, or the same letter appears twice.
]

#subsection[The follow-up: keep k copies]

Replace `inStack[c]` by a count `inStackCount[c] < k`, and replace `last[c] > i` by
"there are still at least `k - inStackCount[c]` copies of `c` after index `i`". You get
that from a suffix-count array built in one backward pass. Same stack, same greedy, two
arrays instead of two flags.

#ex(27, tier: 3, asked: "D. E. Shaw · pattern")[
Prices arrive one at a time and never stop. After each price, report its span (the number
of consecutive days back, including today, with price $<=$ today's). You may not store
all the prices.

*The follow-up:* "now report the maximum over a sliding window of the last `w` days."
]

#sol[
The monotonic stack already throws away prices it can never need. Store *pairs*
`(price, span already absorbed)` so that when a block is swallowed you keep its width and
throw away its contents.
]

#code(lang: "js", caption: "Streaming span in O(1) amortised")[
```js
class SpanStream {
  constructor() { this.st = []; }          // [price, span of that block]

  next(price) {
    let span = 1;
    while (this.st.length && this.st[this.st.length - 1][0] <= price) {
      span += this.st.pop()[1];            // swallow the whole block
    }
    this.st.push([price, span]);
    return span;
  }
  get memoryUsed() { return this.st.length; }
}
```
]

Tested:

#table(columns: 3,
  [*prices fed*], [*spans reported*], [*slots kept at the end*],
  [`100 80 60 70 60 75 85`], [`1 1 1 2 1 4 6`], [2],
  [`5 5 5`], [`1 2 3`], [1],
  [`9`], [`1`], [1],
  [`9 8 7 6`], [`1 1 1 1`], [4],
)

#note[
Look at the last two rows. A rising stream collapses to almost nothing — after
`100 80 60 70 60 75 85` only *two* slots remain. A strictly falling stream keeps
everything, because no old price is ever beaten. So memory is $O(n)$ worst case but often
tiny, and the *time* is $O(1)$ amortised either way.
]

#subsection[The follow-up: maximum over the last w days]

A stack cannot do it, because the element leaving the window is at the *bottom*, and a
stack only removes from the top. You need removal at *both* ends — a
*monotonic deque*. That is the next chapter. Recognising that a stack is the wrong shape
here is exactly what the interviewer is testing.

#section[Dry run — largest rectangle in a histogram]

Heights `h = {2, 1, 5, 6, 2, 3}`. We run `histStack` from Example 16. The loop runs for
`i` from 0 to 6; at `i = 6` the virtual height is 0, which flushes everything.

The stack holds *indices*. Width for a popped index is `i - left - 1`, where `left` is
the index left on the stack below it (or $-1$ if the stack is empty).

#table(columns: 5,
  [*i*], [*cur*], [*pops (index, height, width, area)*], [*stack after*], [*best*],
  [0], [2], [none], [`[0]`], [0],
  [1], [1], [idx 0, h=2, w=1, area=2], [`[1]`], [2],
  [2], [5], [none], [`[1,2]`], [2],
  [3], [6], [none], [`[1,2,3]`], [2],
  [4], [2], [idx 3, h=6, w=1, area=6; then idx 2, h=5, w=2, area=10], [`[1,4]`], [10],
  [5], [3], [none], [`[1,4,5]`], [10],
  [6], [0], [idx 5, h=3, w=1, area=3; idx 4, h=2, w=4, area=8; idx 1, h=1, w=6, area=6], [`[6]`], [10],
)

Answer: *10*.

Reading the interesting rows:

- *Row i = 1.* Height 1 arrives and is shorter than the 2 on the stack. So bar 0 is
  finished: it can spread right only as far as index 0. After popping, the stack is
  empty, so `left = -1` and `width = 1 - (-1) - 1 = 1`. Area $2 times 1 = 2$.
- *Row i = 4.* Height 2 arrives. Bar 3 (height 6) is finished: below it is index 2, so
  `width = 4 - 2 - 1 = 1`, area 6. Then bar 2 (height 5) is finished: below it is index
  1, so `width = 4 - 1 - 1 = 2`, area 10. This is the winner — a rectangle of height 5
  over columns 2 and 3. Then the top is index 1 with height 1, which is *not* $>= 2$, so
  popping stops.
- *Row i = 6.* The virtual 0 bar. Bar 5 (height 3) pops with width 1. Bar 4 (height 2)
  pops: below it is index 1, so `width = 6 - 1 - 1 = 4` — the rectangle of height 2
  spreads over columns 2, 3, 4, 5, area 8. Finally bar 1 (height 1) pops with an empty
  stack below, so `width = 6 - (-1) - 1 = 6`: the full-width rectangle of height 1,
  area 6.

The winner is $5 times 2 = 10$.

#note[
Every index is pushed exactly once (six pushes plus the virtual one) and popped at most
once (six pops). Two nested loops, still $O(n)$. Say "amortised" when you explain this.
]

#section[Python, for the three signature problems]

#code(lang: "python", caption: "The same three algorithms")[
```python
def next_greater(a):
    n = len(a)
    out = [-1] * n
    st = []
    for i in range(n - 1, -1, -1):
        while st and st[-1] <= a[i]:
            st.pop()
        if st:
            out[i] = st[-1]
        st.append(a[i])
    return out

def largest_rectangle(h):
    best = 0
    st = []
    n = len(h)
    for i in range(n + 1):
        cur = 0 if i == n else h[i]
        while st and h[st[-1]] >= cur:
            height = h[st.pop()]
            left = st[-1] if st else -1
            best = max(best, height * (i - left - 1))
        st.append(i)
    return best

def balanced(s):
    pairs = {')': '(', ']': '[', '}': '{'}
    st = []
    for c in s:
        if c in "([{":
            st.append(c)
        elif c in pairs:
            if not st or st.pop() != pairs[c]:
                return False
    return not st
```
]

Run output:

#code(lang: "text", caption: "output")[
```text
[6, 2, 6, -1, -1] [] [-1, -1, -1]
10 0 7 9
True False True False
```
]

#trap[
`largest_rectangle` indexes `h[st[-1]]` *before* popping, then pops. Writing
`h[st.pop()]` inside the `while` condition would pop on every test, including the one
that fails. Keep the test and the pop separate.
]

#note[
Python integers are exact at any size, so the `BigInt` question of Example 18 never
comes up: `height * width` and `a[i] * left * right` are simply correct. The trade is
speed. A Python `list` used as a stack is several times slower than a JavaScript array,
so at $n = 10^5$ you are fine and at $n = 10^7$ you are not. Write JavaScript first and
offer the Python only if the interviewer asks.
]

#section[Practice]

#practice(tier: 1, time: "14 min")[
+ Fewest brackets you must *add* to make a `()` string balanced.
+ Next strictly smaller element to the right, for every index.
+ Sort a stack (largest on top) using only one helper stack.
+ Does an expression contain a bracket pair that wraps nothing useful — like `(a)` or
  `((a+b))`?
+ Standing at index `i` and looking right, how many buildings can you see? You see a
  building when it is taller than every building strictly between you and it.
+ Evaluate a *prefix* expression.
+ Simplify a folder path: `/a/./b/../../c/` becomes `/c`.
]

#practice(tier: 2, time: "22 min")[
8. Remove the outer bracket of every top-level group: `(()())(())` becomes `()()()`.
9. For each day, how many days until a strictly warmer day? 0 if it never comes.
10. Delete exactly `k` digits so the remaining number is the *largest* possible.
11. For each index, how many subarrays have `a[i]` as their maximum?
12. For every window size `w` from 1 to `n`, report the largest of all window minimums.
13. Given the exact push order and a claimed pop order, is the pop order possible?
14. Score a balanced bracket string: `()` scores 1, `(X)` scores `2*X`, `XY` scores
    `X + Y`.
]

#key[
*1.* One counter for unmatched openers, one for unmatched closers.

#code(lang: "js", caption: "1 — brackets to add")[
```js
const bracketsToAdd = (s) => {
  let open = 0, need = 0;
  for (const c of s) {
    if (c === '(') open++;
    else { if (open > 0) open--; else need++; }   // a ')' with nothing to close
  }
  return need + open;
};
```
]
Tested: `"())"` $arrow.r$ `1`; `"((("` $arrow.r$ `3`; `""` $arrow.r$ `0`;
`"()"` $arrow.r$ `0`; `")("` $arrow.r$ `2`. These are counts, not flags.

*2.* Example 7 with the pop test flipped.

#code(lang: "js", caption: "2 — next smaller to the right")[
```js
const nextSmaller = (a) => {
  const n = a.length, out = new Array(n).fill(-1), st = [];
  for (let i = n - 1; i >= 0; i--) {
    while (st.length && st[st.length - 1] >= a[i]) st.pop();
    if (st.length) out[i] = st[st.length - 1];
    st.push(a[i]);
  }
  return out;
};
```
]
Tested: `[4,8,5,2,25]` $arrow.r$ `[2,5,2,-1,-1]`; `[]` $arrow.r$ `[]`;
`[3]` $arrow.r$ `[-1]`; `[2,2,2]` $arrow.r$ `[-1,-1,-1]`; `[-1,-4,0]` $arrow.r$ `[-4,-1,-1]`.

*3.* Pull one value off the input. Push back anything on the output that is bigger, then
place the value. It is insertion sort with stacks.

#code(lang: "js", caption: "3 — sort a stack")[
```js
const sortStack = (input) => {
  const inSt = [...input], out = [];
  while (inSt.length) {
    const v = inSt.pop();
    while (out.length && out[out.length - 1] > v) inSt.push(out.pop());
    out.push(v);
  }
  return out;   // the last slot is the largest
};
```
]
Tested: pushing `3, 1, 4, 1, 5` then sorting and popping prints `5 4 3 1 1`. An empty
stack stays empty. A single `-7` comes back as `-7`.
Cost is $O(n^2)$ in the worst case — that is expected for this puzzle.

*4.* A bracket pair is redundant when nothing between it and its opener was an operator.

#code(lang: "js", caption: "4 — redundant brackets")[
```js
const hasRedundantBrackets = (s) => {
  const st = [];
  for (const c of s) {
    if (c === ')') {
      let sawOperator = false;
      while (st.length && st[st.length - 1] !== '(') {
        const t = st.pop();
        if (t === '+' || t === '-' || t === '*' || t === '/') sawOperator = true;
      }
      if (st.length) st.pop();            // drop the '('
      if (!sawOperator) return true;
    } else st.push(c);
  }
  return false;
};
```
]
Tested: `"(a+b)"` $arrow.r$ `false`; `"((a+b))"` $arrow.r$ `true`;
`"(a)"` $arrow.r$ `true`; `"(a+(b*c))"` $arrow.r$ `false`; `"a+b"` $arrow.r$ `false`;
`""` $arrow.r$ `false`.

*5.* Walk right to left. Keep the "record holders" of the suffix, nearest on top. Its
*size* is exactly the answer for the index just to the left.

#code(lang: "js", caption: "5 — buildings visible to the right")[
```js
const visibleToRight = (h) => {
  const n = h.length, out = new Array(n).fill(0), st = [];
  for (let i = n - 1; i >= 0; i--) {
    out[i] = st.length;                                        // records of h[i+1..]
    while (st.length && st[st.length - 1] <= h[i]) st.pop();   // h[i] hides them
    st.push(h[i]);
  }
  return out;
};
```
]
Tested against brute force: `[3,1,4,2,5]` $arrow.r$ `[3,2,2,1,0]`; `[]` $arrow.r$ `[]`;
`[6]` $arrow.r$ `[0]`; `[2,2,2]` $arrow.r$ `[1,1,0]`; `[5,4,3]` $arrow.r$ `[1,1,0]`;
`[1,2,3]` $arrow.r$ `[2,1,0]`. Also agreed on 400 random arrays.

*6.* Prefix is postfix read backwards, with the operand order swapped.

#code(lang: "js", caption: "6 — evaluate a prefix expression")[
```js
const evalPrefix = (expr) => {
  const tok = expr.split(/\s+/).filter(t => t.length);
  const st = [];
  for (let i = tok.length - 1; i >= 0; i--) {
    const x = tok[i];
    if (x.length === 1 && '+-*/'.includes(x)) {
      const a = st.pop();                   // LEFT operand pops first here
      const b = st.pop();
      if (x === '+') st.push(a + b);
      else if (x === '-') st.push(a - b);
      else if (x === '*') st.push(a * b);
      else st.push(Math.trunc(a / b));
    } else st.push(Number(x));
  }
  return st.pop();
};
```
]
Tested: `"+ 3 4"` $arrow.r$ `7`; `"- * 5 6 2"` $arrow.r$ `28`; `"8"` $arrow.r$ `8`;
`"* -3 7"` $arrow.r$ `-21`; `"* 100000 100000"` $arrow.r$ `10000000000`.
Note the pop order is the *opposite* of postfix: scanning backwards puts the left operand
on top.

*7.* Split on `/`. Ignore empty pieces and `.`. On `..` pop.

#code(lang: "js", caption: "7 — simplify a path")[
```js
const simplifyPath = (p) => {
  const st = [];
  for (const part of p.split('/')) {
    if (part === '' || part === '.') continue;
    if (part === '..') st.pop();          // pop() on an empty array is a harmless no-op
    else st.push(part);
  }
  return st.length ? '/' + st.join('/') : '/';
};
```
]
Tested: `"/a/./b/../../c/"` $arrow.r$ `/c`; `"/"` $arrow.r$ `/`; `"/../"` $arrow.r$ `/`;
`"/home//docs///"` $arrow.r$ `/home/docs`; `"/a/b/c"` $arrow.r$ `/a/b/c`.

*8.* You do not need a stack — a depth counter is enough. Emit a bracket only when the
depth is above 1.

#code(lang: "js", caption: "8 — remove outer brackets")[
```js
const removeOuter = (s) => {
  let out = '', depth = 0;
  for (const c of s) {
    if (c === '(') { if (depth > 0) out += c; depth++; }
    else { depth--; if (depth > 0) out += c; }
  }
  return out;
};
```
]
Tested: `"(()())(())"` $arrow.r$ `()()()`; `"()()"` $arrow.r$ empty; `""` $arrow.r$ empty;
`"((()))"` $arrow.r$ `(())`.

*9.* Monotonic stack of *indices*. When a warmer day arrives, every colder day still
waiting gets its answer at once.

#code(lang: "js", caption: "9 — days until warmer")[
```js
const daysUntilWarmer = (t) => {
  const n = t.length, out = new Array(n).fill(0), st = [];   // indices
  for (let i = 0; i < n; i++) {
    while (st.length && t[st[st.length - 1]] < t[i]) { const j = st.pop(); out[j] = i - j; }
    st.push(i);
  }
  return out;
};
```
]
Tested: `[30,32,28,29,35]` $arrow.r$ `[1,3,1,1,0]`; `[]` $arrow.r$ `[]`;
`[40]` $arrow.r$ `[0]`; `[20,20,20]` $arrow.r$ `[0,0,0]`; `[50,40,30]` $arrow.r$ `[0,0,0]`.
Indices left on the stack at the end keep their 0 — those days never warm up.

*10.* Example 19 with `<` instead of `>`, and no leading-zero problem (the largest number
never starts with 0 unless everything is 0).

#code(lang: "js", caption: "10 — keep the largest")[
```js
const keepLargest = (num, k) => {
  const st = [];
  for (const c of num) {
    while (k > 0 && st.length && st[st.length - 1] < c) { st.pop(); k--; }
    st.push(c);
  }
  while (k > 0 && st.length) { st.pop(); k--; }
  return st.length ? st.join('') : '0';
};
```
]
Tested: `("1432219", 3)` $arrow.r$ `4329`; `("10200", 1)` $arrow.r$ `1200`;
`("10", 2)` $arrow.r$ `0`; `("9", 0)` $arrow.r$ `9`; `("12345", 2)` $arrow.r$ `345`.

*11.* Contribution counting. Strict on one side, non-strict on the other, so ties are
credited once.

#code(lang: "js", caption: "11 — subarrays where a[i] is the maximum")[
```js
const countAsMax = (a) => {
  const n = a.length;
  const L = new Array(n), R = new Array(n);
  let st = [];
  for (let i = 0; i < n; i++) {
    while (st.length && a[st[st.length - 1]] < a[i]) st.pop();    // previous >=
    L[i] = st.length ? i - st[st.length - 1] : i + 1;
    st.push(i);
  }
  st = [];
  for (let i = n - 1; i >= 0; i--) {
    while (st.length && a[st[st.length - 1]] <= a[i]) st.pop();   // next strictly >
    R[i] = st.length ? st[st.length - 1] - i : n - i;
    st.push(i);
  }
  return L.map((l, i) => l * R[i]);
};
```
]
Tested, with the built-in check that the counts must add up to $n(n+1)\/2$:
`[3,1,2]` $arrow.r$ `[3,1,2]`, sum 6, expected 6.
`[]` $arrow.r$ `[]`, sum 0. `[7]` $arrow.r$ `[1]`, sum 1. `[2,2]` $arrow.r$ `[2,1]`,
sum 3. `[1,2,3]` $arrow.r$ `[1,2,3]`, sum 6.

That sum check is the best test you can write for any contribution problem: every
subarray has exactly one owner, so the counts must total $n(n+1)\/2$.

*12.* For each `a[i]`, find the widest window in which it is the minimum; call that
length `len`. Then `a[i]` is a candidate answer for size `len`. Fill sizes downwards at
the end, because a value that is the best minimum for size `len` also beats anything for
smaller sizes.

#code(lang: "js", caption: "12 — max of window minimums, for every window size")[
```js
const maxOfMins = (a) => {
  const n = a.length;
  if (n === 0) return [];
  const L = new Array(n), R = new Array(n);
  let st = [];
  for (let i = 0; i < n; i++) {
    while (st.length && a[st[st.length - 1]] >= a[i]) st.pop();
    L[i] = st.length ? st[st.length - 1] : -1;
    st.push(i);
  }
  st = [];
  for (let i = n - 1; i >= 0; i--) {
    while (st.length && a[st[st.length - 1]] >= a[i]) st.pop();
    R[i] = st.length ? st[st.length - 1] : n;
    st.push(i);
  }
  const best = new Array(n + 1).fill(-Infinity);
  for (let i = 0; i < n; i++) {
    const len = R[i] - L[i] - 1;              // biggest window where a[i] is the min
    best[len] = Math.max(best[len], a[i]);
  }
  for (let w = n - 1; w >= 1; w--) best[w] = Math.max(best[w], best[w + 1]);
  return best.slice(1);
};
```
]
Tested against brute force: `[10,20,30,50,10,70,30]` $arrow.r$ `[70,30,20,10,10,10,10]`;
`[]` $arrow.r$ `[]`; `[4]` $arrow.r$ `[4]`; `[3,3,3]` $arrow.r$ `[3,3,3]`;
`[5,4,3,2,1]` $arrow.r$ `[5,4,3,2,1]`. Also agreed on 300 random arrays.

*13.* Push in order, and pop greedily whenever the top matches the next wanted value.

#code(lang: "js", caption: "13 — validate push/pop sequences")[
```js
const validSequences = (pushed, popped) => {
  if (pushed.length !== popped.length) return false;
  const st = [];
  let k = 0;
  for (const v of pushed) {
    st.push(v);
    while (st.length && k < popped.length && st[st.length - 1] === popped[k]) { st.pop(); k++; }
  }
  return st.length === 0;
};
```
]
Tested: `([1,2,3,4,5], [4,5,3,2,1])` $arrow.r$ `true`;
`([1,2,3,4,5], [4,3,5,1,2])` $arrow.r$ `false`; `([], [])` $arrow.r$ `true`;
`([1], [1])` $arrow.r$ `true`; `([1,2], [2,1])` $arrow.r$ `true`;
`([1,2], [1,2])` $arrow.r$ `true`.

*14.* Keep a stack of *partial scores*, one per open bracket depth. An empty inner score
means the pair was `()`, worth 1; otherwise double it.

#code(lang: "js", caption: "14 — bracket score")[
```js
const bracketScore = (s) => {
  const st = [0];                    // score of the current level
  for (const c of s) {
    if (c === '(') st.push(0);
    else {
      const inner = st.pop();
      st[st.length - 1] += inner === 0 ? 1 : 2 * inner;
    }
  }
  return st[st.length - 1];
};
```
]
Tested: `"()"` $arrow.r$ `1`; `"(())"` $arrow.r$ `2`; `"()()"` $arrow.r$ `2`;
`"(()(()))"` $arrow.r$ `6`; `""` $arrow.r$ `0`.
Check the last real one by hand: `(()(()))` is `( A )` with `A = () + (())` $= 1 + 2 = 3$,
so the whole thing is $2 times 3 = 6$.
]

#revision[
*The reflex.* "Nearest something, on one side" or "how far until" or "largest area" —
that is a monotonic stack. Write the four-line skeleton before thinking about the problem.

*Template — monotonic stack*
#code(lang: "js", caption: "")[
```js
// `isUseless(topValue, currentValue)` is the only line that changes per problem.
const st = [];                       // push INDICES when you need a distance
for (let i = 0; i < n; i++) {        // or i = n-1 down to 0
  while (st.length && isUseless(a[st[st.length - 1]], a[i])) st.pop();
  out[i] = st.length ? a[st[st.length - 1]] : NONE;
  st.push(i);
}
```
]

*The four-way table*
#table(columns: 3,
  [*Want*], [*Walk*], [*Pop while top is*],
  [next greater (right)], [backwards], [$<=$ a[i]],
  [next smaller (right)], [backwards], [$>=$ a[i]],
  [previous greater (left)], [forwards], [$<=$ a[i]],
  [previous smaller (left)], [forwards], [$>=$ a[i]],
)

*Contribution counting (sum over all subarrays of min or max)*
#code(lang: "js", caption: "")[
```js
// left[i]  = i - (index of previous STRICTLY smaller)   // strict on ONE side only
// right[i] = (index of next smaller OR EQUAL) - i        // non-strict on the other
// total += BigInt(a[i]) * BigInt(left[i]) * BigInt(right[i]);   // BigInt: passes 2^53

// Run this self-check on every contribution problem. Every subarray has exactly
// one owner, so the counts must total n(n+1)/2. It catches a wrong `<` vs `<=`
// instantly, on inputs far too small to spot by hand.
const contributionSelfCheck = (left, right) => {
  const n = left.length;
  const owned = left.reduce((sum, l, i) => sum + l * right[i], 0);
  return owned === n * (n + 1) / 2;
};
```
]

*Complexity of everything in this chapter*
#table(columns: 4,
  [*Problem*], [*Brute*], [*Optimal*], [*Space*],
  [next greater / smaller], [$O(n^2)$], [$O(n)$], [$O(n)$],
  [stock span], [$O(n^2)$], [$O(n)$], [$O(n)$],
  [largest rectangle], [$O(n^2)$], [$O(n)$], [$O(n)$],
  [trapping rain water], [$O(n^2)$], [$O(n)$], [$O(n)$ or $O(1)$],
  [sum of subarray minima], [$O(n^2)$], [$O(n)$], [$O(n)$],
  [maximal rectangle in a grid], [$O(R^2 C^2)$], [$O(R C)$], [$O(C)$],
  [longest valid brackets], [$O(n^2)$], [$O(n)$], [$O(1)$ with counters],
  [min stack], [—], [$O(1)$ per op], [$O(1)$ encoded],
)

*Top traps*
+ Wrong strictness (`<` vs `<=`) in the pop test $arrow.r$ duplicates counted twice.
+ Pushing values when you needed indices $arrow.r$ you cannot compute a width.
+ Forgetting the virtual bar of height 0 at the end $arrow.r$ leftovers never measured.
+ `width = i - popped` instead of `i - below - 1` $arrow.r$ rectangles too narrow.
+ Letting a product pass $9 times 10^15$ $arrow.r$ silently wrong; switch to `BigInt`.
+ Reading `st[st.length - 1]` without checking `st.length` first $arrow.r$ `undefined`,
  then `NaN`, and no error message anywhere.
+ Postfix: popping the two operands in the wrong order for `-` and `/`.
+ Brackets: checking only that the stack is empty at the end.
+ `remove k digits`: forgetting leftover `k`, leading zeros, and the empty result.
+ Trying to solve a *sliding window maximum* with a stack — it needs a deque.
]

]
