#import "../../shared/lib/style.typ": *

#chapter(num: 12, title: "Trees & Binary Trees",
  tagline: "Solve the left side, solve the right side, combine. That is the whole chapter.")[

#section[Pattern in one page]

A *binary tree* is made of nodes. Each node holds a value and two references, `left` and
`right`, either of which may be `null`. One node is the *root*. A node with no children
is a *leaf*.

#code(lang: "js", caption: "the node, and nothing more")[
```js
class Node {
  constructor(val) { this.val = val; this.left = null; this.right = null; }
}
```
]

This chapter needs one thing JavaScript does not ship: a queue you can take from the front
cheaply. Use the tested `Deque` from the *JS Toolkit* appendix.

#code(lang: "js", caption: "the one import this chapter needs")[
```js
const { Deque } = require('./toolkit.js');   // see the JS Toolkit appendix
```
]

#trap[
*`array.shift()` is $O(n)$, not $O(1)$.* It moves every remaining element down one slot. A
breadth-first search that calls `q.shift()` once per node is therefore $O(n^2)$, and on
$10^5$ nodes it will time out even though your algorithm is correct.

I measured it in Node on a queue of 200000 numbers: draining it with `array.shift()` took
*2726 ms*; the toolkit `Deque`, which keeps a head index instead of moving anything, took
*10 ms*. Same answer, 270 times faster.

Every BFS in this chapter uses `Deque`. If you are writing on a whiteboard, `q.shift()` is
fine — but say out loud that you would swap it for an index-based queue in real code.
]

#formulas(title: "The one sentence that solves 90% of tree problems")[
*Ask the left child for its answer. Ask the right child for its answer. Combine the two
with this node's value.*

```js
const solve = (r) => {
  if (r === null) return emptyAnswer;   // the base case is ALWAYS null
  const L = solve(r.left);
  const R = solve(r.right);
  return combine(L, R, r.val);
};
```
Everything in this chapter is that shape, plus one of two twists:
- the answer you *return* upward is different from the answer you *record*, or
- you need level-by-level order, which means a queue, not recursion.
]

#subsection[The tree used all through this chapter]

#diagram(height: 5.2cm, caption: "call this tree T. 8 nodes, height 4, 4 leaves.")[
  #dnode(4.6cm, 0pt,    1.0cm, 0.7cm, "1")
  #dnode(2.4cm, 1.3cm,  1.0cm, 0.7cm, "2")
  #dnode(6.8cm, 1.3cm,  1.0cm, 0.7cm, "3")
  #dnode(1.0cm, 2.6cm,  1.0cm, 0.7cm, "4")
  #dnode(3.8cm, 2.6cm,  1.0cm, 0.7cm, "5")
  #dnode(8.2cm, 2.6cm,  1.0cm, 0.7cm, "6")
  #dnode(3.0cm, 3.9cm,  1.0cm, 0.7cm, "7")
  #dnode(4.6cm, 3.9cm,  1.0cm, 0.7cm, "8")
  #darrow(4.9cm, 0.7cm, 3.1cm, 1.3cm)
  #darrow(5.3cm, 0.7cm, 7.2cm, 1.3cm)
  #darrow(2.7cm, 2.0cm, 1.6cm, 2.6cm)
  #darrow(3.1cm, 2.0cm, 4.2cm, 2.6cm)
  #darrow(7.5cm, 2.0cm, 8.5cm, 2.6cm)
  #darrow(4.1cm, 3.3cm, 3.4cm, 3.9cm)
  #darrow(4.4cm, 3.3cm, 5.0cm, 3.9cm)
]

Node `3` has *no left child*. That single missing pointer is what makes the views, the
boundary and the top view interesting later — it is not an accident.

#subsection[The three depth-first traversals]

They differ in *one line*: where you print.

#code(lang: "js", caption: "preorder, inorder, postorder")[
```js
const preorder = (r, out = []) => {
  if (r === null) return out;
  out.push(r.val);              // root  -> left -> right
  preorder(r.left, out);
  preorder(r.right, out);
  return out;
};

const inorder = (r, out = []) => {
  if (r === null) return out;
  inorder(r.left, out);
  out.push(r.val);              // left  -> root -> right
  inorder(r.right, out);
  return out;
};

const postorder = (r, out = []) => {
  if (r === null) return out;
  postorder(r.left, out);
  postorder(r.right, out);
  out.push(r.val);              // left  -> right -> root
  return out;
};
```
]

Ran all three on tree T:

#table(columns: (auto, 1fr, 1fr),
  [*order*], [*output*], [*use it for*],
  [preorder],  [`1 2 4 5 7 8 3 6`], [copying a tree, serialising, "top-down" work],
  [inorder],   [`4 2 7 5 8 1 3 6`], [BSTs (Chapter 13) — it comes out sorted there],
  [postorder], [`4 7 8 5 2 6 3 1`], [deleting a tree, "bottom-up" work like height or diameter],
)

#trick[
*How to read the names.* "Pre / in / post" says where the *root* goes: before the
children, between them, or after them. `left` always comes before `right` in all three.
]

#subsection[Breadth-first: the level-order template]

Recursion cannot easily do "all of level 2, then all of level 3". A queue can. Memorise
this exact loop — you will type it in eight problems in this chapter.

#code(lang: "js", caption: "level order — the template")[
```js
const levelOrder = (root) => {
  const out = [];
  if (root === null) return out;
  const q = new Deque(); q.push(root);
  while (q.size) {
    const sz = q.size;                   // freeze the size: this is one level
    const level = [];
    for (let i = 0; i < sz; i++) {
      const cur = q.shift();
      level.push(cur.val);
      if (cur.left)  q.push(cur.left);
      if (cur.right) q.push(cur.right);
    }
    out.push(level);
  }
  return out;
};
```
]

Ran it on T: `[[1],[2,3],[4,5,6],[7,8]]`. On `null`: `[]`.

#trap[
`const sz = q.size;` must be read *before* the inner loop starts. If you write
`for (let i = 0; i < q.size; i++)`, the size grows as you push children, and the level
boundary disappears. This is the single most common level-order bug, and it is worse in
JavaScript than in C++ because `q.size` on the toolkit `Deque` is a *getter* — it looks
like a plain field, so nobody notices it is being re-read every turn.
]

#subsection[The two shapes of a tree recursion]

#table(columns: (auto, 1fr, auto),
  [*Shape*], [*What it looks like*], [*Examples*],
  [*Pure return*], [the value you return is the answer for this subtree], [height, count, sum, same-tree, path sum],
  [*Return one thing, record another*], [return the best *straight arm* upward, record the best *bent path* in a variable the inner function closes over], [diameter, max path sum, longest consecutive],
)

That second shape is the hardest idea in the chapter, and it appears in every Tier-3
problem. It looks like this:

#code(lang: "js", caption: "the return-one-record-another skeleton")[
```js
const solveTwoWays = (root) => {
  let best = 0;                            // lives in the OUTER function
  const go = (r) => {
    if (r === null) return 0;
    const L = go(r.left);
    const R = go(r.right);
    best = Math.max(best, L + R + something);   // RECORD: the path that bends at r
    return 1 + Math.max(L, R);                  // RETURN: the arm the parent can use
  };
  go(root);
  return best;
};
```
]

The parent cannot use a bent path — a path through the parent must enter `r` from above
and leave through *one* side. So the bent value goes into `best`, and only the straight
arm is returned.

#note[
*JavaScript has no reference parameters.* C++ writes `int &best` and Java passes an
`int[1]`. In JavaScript you put the inner function *inside* the outer one, and `best` is
simply a variable the inner function can see and assign. This is called a *closure*, and it
is the cleanest of the three. Python does the same job with `nonlocal best`.

The trap is writing `const go = (r, best) => ...` instead. A number passed as an argument
is a *copy*, so `best = ...` inside `go` changes nothing outside it, and the function
silently returns the starting value.
]

#note[
*Complexity rule of thumb for this chapter.* Any traversal that touches each node a
constant number of times is $O(n)$ time. The space is the *stack depth*, which is the
height $h$: $O(h)$. For a balanced tree $h = O(log n)$; for a chain of nodes $h = n$.
A queue-based level order is $O(n)$ time and $O(w)$ space, where $w$ is the widest level.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Return the *height* of a tree — the number of nodes on the longest root-to-leaf path.
Constraints: up to $10^5$ nodes. Edge cases: empty tree; one node; a chain.

#sol[
Height of an empty tree is 0. Otherwise it is 1 plus the taller child.

#code(lang: "js", caption: "height")[
```js
const height = (r) => {
  if (r === null) return 0;
  return 1 + Math.max(height(r.left), height(r.right));
};
```
]

Ran it: `height(T)=4`, `height(null)=0`, `height(single node)=1`.

#complexity(time: $O(n)$, space: $O(h)$, note: "h is the height; a chain gives O(n) stack")

#ans[4]
]
]

#trap[
Some books define height in *edges*, so a single node has height 0 and an empty tree has
height $-1$. Both are correct — they are different definitions. In an interview, say
which one you are using *before* you write code. Every formula in this chapter counts
*nodes*, except the diameter, which counts *edges*. I will say so each time.
]

#ex(2, tier: 0, asked: "warm-up")[
Count all nodes, count only the leaves, and add up every value.
Constraints: values up to $10^9$, $n$ up to $10^5$. Edge cases: empty tree;
a total large enough to worry about.

#sol[
Three functions, all the same shape.

#code(lang: "js", caption: "count, count leaves, sum")[
```js
const countNodes = (r) => {
  if (r === null) return 0;
  return 1 + countNodes(r.left) + countNodes(r.right);
};

const countLeaves = (r) => {
  if (r === null) return 0;
  if (r.left === null && r.right === null) return 1;   // a leaf
  return countLeaves(r.left) + countLeaves(r.right);
};

const sumTree = (r) => {
  if (r === null) return 0;
  return r.val + sumTree(r.left) + sumTree(r.right);
};
```
]

Ran it on T: `count=8`, `leaves=4`, `sum=36`. On `null`: `0`, `0`, `0`.
On a single node `9`: `1`, `1`, `9`.

#complexity(time: $O(n)$, space: $O(h)$)

#ans[8 nodes, 4 leaves, sum 36]
]
]

#trap[
`countLeaves` needs *two* base cases: `null` returns 0, and a leaf returns 1. If you
only write the `null` case and return 1 there, a node with one child is counted as a
leaf — wrong. Test with a tree that has a one-child node. Tree T has exactly one such
node (node `3`), which is why I use it everywhere.
]

#note[
*There is no 64-bit integer type in JavaScript, and here you do not need one.* Every number is a
double, exact up to `Number.MAX_SAFE_INTEGER` = `9007199254740991`. The worst case in this
problem is $10^5$ nodes holding $10^9$ each, which is $10^14$ — I checked in Node that
$10^14$ is still a safe integer, so a plain `+` is exact.

Past $9 times 10^15$ it is not. If the constraints ever allow that, switch to `BigInt`:
`BigInt(r.val) + sumTree(r.left)`, and remember that BigInt will not mix with plain numbers
in the same expression.
]

#ex(3, tier: 0, asked: "TCS NQT pattern")[
Does the tree contain a given value?
Constraints: $n$ up to $10^5$. Edge cases: empty tree; the value at the root; missing.

#sol[
#code(lang: "js", caption: "search")[
```js
const contains = (r, x) => {
  if (r === null) return false;
  if (r.val === x) return true;
  return contains(r.left, x) || contains(r.right, x);
};
```
]

Ran it on T: `contains(7)=true`, `contains(99)=false`, `contains(null, 1)=false`.

#complexity(time: $O(n)$, space: $O(h)$, note: "in a plain binary tree you must look everywhere; a BST does it in O(h) — Chapter 13")

#ans[true, false]
]
]

#trick[
The `||` short-circuits: if the left subtree finds it, the right subtree is never
searched. Writing `const L = contains(...); const R = contains(...); return L || R;` throws
that away and always searches the whole tree. Keep the `||` on one line.
]

#ex(4, tier: 0, asked: "warm-up")[
Return the *minimum* depth — nodes on the shortest path from the root down to a *leaf*.
Constraints: $n$ up to $10^5$. Edge cases: empty tree; a chain (min depth equals height);
a root with only one child.

#sol[
This looks like `height` with `min` instead of `max`. It is not, and that is the point.

#code(lang: "js", caption: "minimum depth")[
```js
const minDepth = (r) => {
  if (r === null) return 0;
  if (r.left === null)  return 1 + minDepth(r.right);   // must go right
  if (r.right === null) return 1 + minDepth(r.left);    // must go left
  return 1 + Math.min(minDepth(r.left), minDepth(r.right));
};
```
]

Ran it: `minDepth(T)=3` (the path `1 → 2 → 4`, and also `1 → 3 → 6`).
On the chain `1 → 2 → 3 → 4`: `minDepth = 4`, same as the height.

#complexity(time: $O(n)$, space: $O(h)$)

#ans[3]
]
]

#trap[
The naive `1 + Math.min(minDepth(r.left), minDepth(r.right))` is *wrong*. On the chain
`1 → 2 → 3 → 4`, node `1` has a `null` left child which returns 0, so the naive
version reports depth 1 — but there is no leaf at depth 1. A path must *end at a leaf*.
That is why the two `null` checks exist.
]

#ex(5, tier: 0, asked: "warm-up")[
Find the largest value in the tree, and the sum of only the leaf values.
Constraints: $n$ up to $10^5$, values from $-10^9$ to $10^9$. Target: $O(n)$.
Edge cases: all values negative; a single node; an empty tree.

#sol[
#code(lang: "js", caption: "max value and leaf sum")[
```js
const maxVal = (r) => {
  if (r === null) return -Infinity;          // neutral element for max
  return Math.max(r.val, maxVal(r.left), maxVal(r.right));
};

const leafSum = (r) => {
  if (r === null) return 0;
  if (r.left === null && r.right === null) return r.val;
  return leafSum(r.left) + leafSum(r.right);
};
```
]

Ran it on T: `maxVal=8`, `leafSum=25` (leaves are 4, 7, 8, 6).
On the all-negative tree `{-3, -2, -9}`: `maxVal = -2`. On a single node `9`:
`leafSum = 9`.

#complexity(time: $O(n)$, space: $O(h)$)

#ans[8 and 25]
]
]

#trap[
`-Infinity` is the right neutral value for `max`, and `0` would be a bug: on an
all-negative tree, `0` would win and the answer would be 0, a value that is not in the
tree. Pick your neutral element to match the operation: `0` for a sum, `-Infinity` for a
maximum, `Infinity` for a minimum. JavaScript has no `INT_MIN`, and it does not need one —
`-Infinity` is a real number that loses every comparison.

`Math.max` also takes any number of arguments, so
`Math.max(r.val, maxVal(r.left), maxVal(r.right))` needs no nesting. And
`Math.max()` with *no* arguments returns `-Infinity`, which is why spreading an empty array
into it, `Math.max(...[])`, quietly gives `-Infinity` instead of throwing.
]

#section[Tier 1 — walk the tree, level by level]
#tier-header(1)

#ex(6, tier: 1, asked: "Infosys pattern")[
Print the tree level by level, one list per level.
Constraints: $n$ up to $10^5$. Edge cases: empty tree; a chain (every level has 1 node).

#sol[
#approach(1, "DFS carrying the depth", verdict: "O(n) — correct, and shorter than you expect")

You do not strictly *need* a queue. Walk the tree any way you like, but carry the depth,
and append each value into `out[depth]`. The first time you reach a new depth, create the
row.

#code(lang: "js", caption: "level order by DFS")[
```js
const loGo = (r, d, out) => {
  if (r === null) return;
  if (d === out.length) out.push([]);       // first node at this depth
  out[d].push(r.val);
  loGo(r.left,  d + 1, out);
  loGo(r.right, d + 1, out);
};

const levelOrderDfs = (r) => { const out = []; loGo(r, 0, out); return out; };
```
]
Ran it on T: `[[1],[2,3],[4,5,6],[7,8]]` — the same answer. On `null`: `[]`.

#approach(2, "BFS with a queue", verdict: "O(n) — same cost, but this one extends to every level question")

The DFS version cannot easily answer "the last node on each level" or "reverse this
level", because it never has a whole level in hand at once. The BFS version does, and
that is why it is the template.

Ran it on T: `[[1],[2,3],[4,5,6],[7,8]]`. On `null`: `[]`.

#diagram(height: 3.8cm, caption: "the queue during level order on T")[
  #dnode(0pt,   0pt,   2.4cm, 0.65cm, "start: [1]")
  #dnode(0pt,   0.9cm, 5.0cm, 0.65cm, "pop 1, push 2,3  ->  [2,3]")
  #dnode(0pt,   1.8cm, 7.4cm, 0.65cm, "pop 2 push 4,5; pop 3 push 6  ->  [4,5,6]")
  #dnode(0pt,   2.7cm, 7.4cm, 0.65cm, "pop 4; pop 5 push 7,8; pop 6  ->  [7,8]")
  #darrow(8.0cm, 0.3cm, 9.0cm, 0.3cm, label: "sz=1")
  #darrow(8.0cm, 1.2cm, 9.0cm, 1.2cm, label: "sz=2")
  #darrow(8.0cm, 2.1cm, 9.0cm, 2.1cm, label: "sz=3")
  #darrow(8.0cm, 3.0cm, 9.0cm, 3.0cm, label: "sz=2")
]

#complexity(time: $O(n)$, space: $O(w)$, note: "w is the widest level; for a perfect tree w is about n/2")

#ans[`[[1],[2,3],[4,5,6],[7,8]]`]
]
]

#ex(7, tier: 1, asked: "Wipro pattern")[
Do the inorder traversal *without recursion*.
Constraints: $n$ up to $10^5$ — deep enough that recursion may blow the stack.
Edge cases: empty tree; a left chain; a right chain.

#sol[
#approach(1, "Plain recursion", verdict: "O(n) time, O(h) stack — and in Node that stack runs out at roughly 10^4 frames")

The recursive version is on the pattern page. On a chain of $10^5$ nodes it *will* crash.

#trap[
*JavaScript's call stack is about $10^4$ frames deep — far shallower than C++ or Java.*
I measured it in Node: a plain recursive function died at depth *12546* with
`RangeError: Maximum call stack size exceeded`.

A balanced tree of $10^5$ nodes is only 17 deep, so recursion is safe there. But nothing in
the problem statement promises balance, and a tree that is one long chain of $10^5$ nodes
is a legal input. *Whenever the constraint is $10^5$ nodes and the shape is not guaranteed,
write the iterative version with your own stack array.* That is exactly what this example
is for.
]

#approach(2, "Your own stack", verdict: "O(n) time, O(h) heap space — no crash, and you can pause mid-traversal")

An array *is* the stack: `push` to add, `pop` to remove. Push every node you pass on the
way left. When you cannot go left any more, pop, visit, and turn right.

#code(lang: "js", caption: "iterative inorder")[
```js
const inorderIter = (root) => {
  const out = [];
  const st = [];                                        // a plain array IS the stack
  let cur = root;
  while (cur !== null || st.length) {
    while (cur !== null) { st.push(cur); cur = cur.left; }   // go all the way left
    cur = st.pop();
    out.push(cur.val);                                      // visit
    cur = cur.right;                                        // then turn right
  }
  return out;
};
```
]

Ran it on T: `[4,2,7,5,8,1,3,6]` — identical to the recursive version. Good.

#complexity(time: $O(n)$, space: $O(h)$, note: "the stack replaces the call stack, same size")

#ans[`4 2 7 5 8 1 3 6`]
]
]

#ex(8, tier: 1, asked: "Capgemini pattern")[
Do preorder and postorder without recursion too.
Constraints: $n$ up to $10^5$; the recursion depth could be $10^5$, so a stack is safer.
Target: $O(n)$ time. Edge cases: empty tree; single node; a left-only chain.

#sol[
Preorder is easy with a stack: pop, print, push *right then left* so that left pops first.

#code(lang: "js", caption: "iterative preorder")[
```js
const preorderIter = (root) => {
  const out = [];
  if (root === null) return out;
  const st = [root];
  while (st.length) {
    const cur = st.pop();
    out.push(cur.val);
    if (cur.right) st.push(cur.right);   // right first: it pops last
    if (cur.left)  st.push(cur.left);
  }
  return out;
};
```
]

Postorder needs a trick, and there are two ways to do it.

#approach(1, "Two stacks", verdict: "O(n) time, O(n) space — easy to remember")

Push into stack `a`, pop from `a` into stack `b`, pushing children left-then-right.
Stack `b` then pops in postorder.

#code(lang: "js", caption: "postorder, two stacks")[
```js
const postorderTwoStacks = (root) => {
  const out = [];
  if (root === null) return out;
  const a = [root], b = [];
  while (a.length) {
    const c = a.pop();
    b.push(c);
    if (c.left)  a.push(c.left);
    if (c.right) a.push(c.right);
  }
  while (b.length) out.push(b.pop().val);
  return out;
};
```
]
Ran it on T: `[4,7,8,5,2,6,3,1]`.

#approach(2, "One stack, then reverse", verdict: "O(n) time, O(n) space — the same idea with the second stack replaced by a reverse")

Run the *same* loop as preorder but push `left` first, giving root → right → left. Then
*reverse* the list. Reversed, that is left → right → root — exactly postorder.

#code(lang: "js", caption: "iterative postorder, one stack")[
```js
const postorderIter = (root) => {
  const out = [];
  if (root === null) return out;
  const st = [root];
  while (st.length) {
    const c = st.pop();
    out.push(c.val);                   // builds root-right-left
    if (c.left)  st.push(c.left);
    if (c.right) st.push(c.right);
  }
  out.reverse();                       // reverse -> left-right-root
  return out;
};
```
]

Ran both on T: preorder `[1,2,4,5,7,8,3,6]`, postorder `[4,7,8,5,2,6,3,1]`. I compared
each against the recursive version with `JSON.stringify` — identical.

#trap[
`out.reverse()` reverses the array *in place* and returns the same array. It does not give
you a copy. If you still need the original order afterwards, reverse a copy:
`[...out].reverse()`. The same is true of `sort`, `splice` and `fill` — the JavaScript
array methods that end in a verb usually mutate.
]

#complexity(time: $O(n)$, space: $O(n)$, note: "postorder needs the whole output list before reversing")

#ans[preorder `1 2 4 5 7 8 3 6`, postorder `4 7 8 5 2 6 3 1`]
]
]

#ex(9, tier: 1, asked: "TCS Digital pattern")[
Turn the tree into its mirror image: swap every node's two children.
Constraints: $n$ up to $10^5$. Target: $O(n)$ time, $O(h)$ space.
Edge cases: empty tree; a single node; a chain.

#sol[
Mirror the left subtree, mirror the right subtree, then swap the pointers.

#code(lang: "js", caption: "invert a tree")[
```js
const invert = (r) => {
  if (r === null) return null;
  const l  = invert(r.left);
  const rt = invert(r.right);
  r.left = rt; r.right = l;
  return r;
};
```
]

Ran it on a copy of T:

#table(columns: (auto, auto, auto),
  [], [*before*], [*after invert*],
  [preorder], [`1 2 4 5 7 8 3 6`], [`1 3 6 2 5 8 7 4`],
  [inorder],  [`4 2 7 5 8 1 3 6`], [`6 3 1 8 5 7 2 4`],
)

The inorder of the mirror is the *reverse* of the original inorder. That is a useful
self-check: if it is not reversed, your swap is wrong.

#complexity(time: $O(n)$, space: $O(h)$)
]
]

#trap[
`r.left = invert(r.right); r.right = invert(r.left);` is *broken*. By the time the
second line runs, `r.left` has already been overwritten, so you invert the new left
subtree again. Compute both children into local variables *first*, then assign.

JavaScript gives you a second way out: the destructuring swap
`[r.left, r.right] = [invert(r.right), invert(r.left)];`. The right-hand side is fully
evaluated into a temporary array before anything is assigned, so it is correct. Use
whichever you find clearer, but know why each one works.
]

#ex(10, tier: 1, asked: "Accenture pattern")[
Two problems that look the same and are not:
(a) are two trees *identical*? (b) is one tree *symmetric* about its own centre?
Constraints: up to $10^5$ nodes each. Target: $O(n)$.
Edge cases: both empty; one empty; same values but different shape.

#sol[
Identical: compare left with left and right with right.

#code(lang: "js", caption: "same tree")[
```js
const same = (a, b) => {
  if (a === null && b === null) return true;
  if (a === null || b === null) return false;     // one ran out first
  return a.val === b.val && same(a.left, b.left) && same(a.right, b.right);
};
```
]

Symmetric: compare left with *right* and right with *left*.

#code(lang: "js", caption: "symmetric tree")[
```js
const mirror = (a, b) => {
  if (a === null && b === null) return true;
  if (a === null || b === null) return false;
  return a.val === b.val && mirror(a.left, b.right) && mirror(a.right, b.left);
};

const symmetric = (r) => r === null || mirror(r.left, r.right);
```
]

Ran them:

#table(columns: (1fr, auto, auto),
  [*test*], [*result*], [*why*],
  [`same(T, a fresh copy of T)`], [true], [same values, same shape],
  [`same(T, tree {1,2,3})`], [false], [shape differs],
  [`same(null, null)`], [true], [both empty],
  [`symmetric(T)`], [false], [node 3 has no left child, node 2 has both],
  [`symmetric({1,2,2,3,4,4,3})`], [true], [a perfect mirror],
  [`symmetric({1,2,2,·,3,·,3})`], [false], [values mirror, shape does not],
  [`symmetric(null)`], [true], [nothing to break],
)

#complexity(time: $O(n)$, space: $O(h)$)

*The idea:* the *only* difference between the two functions is `b.right` versus
`b.left` in the two recursive calls. Say that out loud in an interview and you have
answered both questions at once.
]
]

#trap[
Use `===`, not `==`. `null == undefined` is `true` in JavaScript, so a tree built with
`undefined` children instead of `null` would still pass a `== null` test but fail every
`=== null` test. Pick `null` for "no child", build every node the same way, and compare
with `===`.

The third test in the table is the one that catches people (a `·` in the level-order list
means "no node", so both 2s have a *right* child holding 3 and no left child). Both children of the
root hold 2; both 2s have exactly one child holding 3. But the left 2's child is on its
*right*, and the right 2's child is on its *right* too — so they are not mirrored.
A symmetric check must compare *shape*, not just the multiset of values.
]

#ex(11, tier: 1, asked: "Cognizant pattern")[
Is there a root-to-leaf path whose values add up to a given target?
Constraints: values may be negative; $n$ up to $10^5$.
Edge cases: empty tree; the target hits a non-leaf node.

#sol[
#approach(1, "Collect every root-to-leaf path, then add each one up", verdict: "O(n · h) time and O(n · h) space — correct but wasteful")

#code(lang: "js", caption: "the wasteful version")[
```js
const hasPathSumSlow = (r, target) => {
  const all = [];
  pathsGo(r, [], all);                        // the path collector from Example 12
  for (const p of all) {
    const s = p.reduce((acc, x) => acc + x, 0);
    if (s === target) return true;
  }
  return false;
};
```
]
I ran this against the fast version below for every target from $-5$ to $30$ on tree T.
They agree on all 36 targets. So it is correct — it just builds and stores every path
first, and it cannot stop early.

#approach(2, "Subtract as you go", verdict: "O(n) time, O(h) space, and it stops the moment it finds a path — optimal")

Subtract as you descend. At a *leaf*, the remaining target must equal the leaf's value.

#code(lang: "js", caption: "root-to-leaf path sum")[
```js
const hasPathSum = (r, target) => {
  if (r === null) return false;
  if (r.left === null && r.right === null) return target === r.val;
  return hasPathSum(r.left, target - r.val) || hasPathSum(r.right, target - r.val);
};
```
]

Ran it on T:

#table(columns: (auto, auto, auto),
  [*target*], [*answer*], [*path*],
  [7],  [true],  [`1 + 2 + 4`],
  [15], [true],  [`1 + 2 + 5 + 7`],
  [3],  [false], [`1 + 2` reaches 3 but node `2` is *not* a leaf],
  [0 on an empty tree], [false], [there is no path at all],
)

#complexity(time: $O(n)$, space: $O(h)$)

#ans[true, true, false]
]
]

#trap[
Target 3 on tree T is the trap. `1 + 2 = 3`, but node `2` has children, so it is not a
leaf and the path is not allowed to stop there. The leaf test must come *before* you use
the target. And an empty tree must return `false` even for target 0 — there is no path,
so no path sums to anything.
]

#note[
`p.reduce((acc, x) => acc + x, 0)` is how you add up an array in JavaScript. The `0` at the
end is the starting value and it is *not* optional here: `[].reduce((a, b) => a + b)` with
no starting value throws `TypeError: Reduce of empty array with no initial value`.
]

#ex(12, tier: 1, asked: "Infosys pattern")[
Print every root-to-leaf path. Then, treating each path as a decimal number
(root digit first), add all the numbers up.
Constraints: values are single digits $0..9$ for part two. Edge cases: single node;
a chain.

#sol[
Part one is plain backtracking on a tree — push, recurse, pop (Chapter 11's rule).

#code(lang: "js", caption: "all root-to-leaf paths")[
```js
const pathsGo = (r, cur, out) => {
  if (r === null) return;
  cur.push(r.val);
  if (r.left === null && r.right === null) out.push([...cur]);   // COPY, not the live array
  else { pathsGo(r.left, cur, out); pathsGo(r.right, cur, out); }
  cur.pop();                            // un-choose
};

const allPaths = (r) => { const out = []; pathsGo(r, [], out); return out; };
```
]

#trap[
`out.push(cur)` without the spread is a silent disaster. C++ copies the vector on
`push_back`; JavaScript pushes a *reference* to the one live array, and `cur.pop()` on the
way back out empties it. You end up with a list of identical empty arrays.

`out.push([...cur])` makes a real copy. Remember that `[...cur]` is only one level deep —
if the elements were themselves arrays you would need `cur.map(x => [...x])`.
]

#code(lang: "js", caption: "what the spread actually fixes")[
```js
const out = [];
const live = [1, 2, 3];
out.push(live);          // a reference
out.push([...live]);     // a copy
live.pop();
// out is now [[1, 2], [1, 2, 3]] — the first row changed under you
```
]

Part two has a ladder of its own.

#approach(1, "Collect the paths, then turn each into a number", verdict: "O(n · h) time and space")

```js
const sumNumbersSlow = (r) => {
  let total = 0;
  for (const p of allPaths(r)) total += p.reduce((v, d) => v * 10 + d, 0);
  return total;
};
```
Ran it on T: `2775`. On `{1,2,3}`: `25`.

#approach(2, "Build the number on the way down", verdict: "O(n) time, O(h) space — optimal")

Part two does not need the list at all — carry the number being built.

#code(lang: "js", caption: "sum of root-to-leaf numbers")[
```js
const numsGo = (r, cur) => {
  if (r === null) return 0;
  cur = cur * 10 + r.val;
  if (r.left === null && r.right === null) return cur;
  return numsGo(r.left, cur) + numsGo(r.right, cur);
};

const sumNumbers = (r) => numsGo(r, 0);
```
]

Ran it on T. Paths: `[1,2,4] [1,2,5,7] [1,2,5,8] [1,3,6]`.
Numbers: $124 + 1257 + 1258 + 136 = 2775$. The program printed `2775`.
On `{1,2,3}`: $12 + 13 = 25$.

#complexity(time: $O(n times h)$, space: $O(h)$, note: "the n·h is copying each path; part two is pure O(n)")

#ans[2775]
]
]

#note[
*A path of 17 digits breaks this.* `cur * 10 + r.val` is exact only while `cur` stays under
`Number.MAX_SAFE_INTEGER` = `9007199254740991`. The stated constraint is single digits and
a tree of $10^4$ nodes, so a root-to-leaf path could in principle be far longer than 16
digits. If the statement allows that, build the number as a *string* and compare, or switch
to `BigInt`: `cur * 10n + BigInt(r.val)`. Say this out loud — noticing it is worth a mark.
]

#ex(13, tier: 1, asked: "TCS NQT pattern")[
For each level, report the maximum value, the sum, and the average.
Constraints: $n$ up to $10^5$, values from $-10^9$ to $10^9$ (so a level sum can reach
$10^14$). Target: $O(n)$. Edge cases: empty tree; negative values; a one-node level.

#sol[
#approach(1, "DFS carrying the depth", verdict: "O(n) time, O(h) space — best when the tree is wide")

```js
const mplGo = (r, d, out) => {
  if (r === null) return;
  if (d === out.length) out.push(-Infinity);   // new depth, neutral element
  out[d] = Math.max(out[d], r.val);
  mplGo(r.left,  d + 1, out);
  mplGo(r.right, d + 1, out);
};
```
Ran it on T: `[1,3,6,8]`.

#approach(2, "BFS level by level", verdict: "O(n) time, O(w) space — best when the tree is deep, and the only option for averages")

The average needs the *count* of nodes on the level, which the BFS gives you for free as
`sz`. Three variations on the level-order template; only the line inside the inner loop
changes.

#code(lang: "js", caption: "max value on each level")[
```js
const maxPerLevel = (root) => {
  const out = [];
  if (root === null) return out;
  const q = new Deque(); q.push(root);
  while (q.size) {
    const sz = q.size;
    let best = -Infinity;                     // neutral element
    for (let i = 0; i < sz; i++) {
      const c = q.shift();
      best = Math.max(best, c.val);
      if (c.left)  q.push(c.left);
      if (c.right) q.push(c.right);
    }
    out.push(best);
  }
  return out;
};
```
]

For the sum, replace `best` with `let s = 0` and `s += c.val`. For the average, divide that
same `s` by `sz` at the end of the level.

#code(lang: "js", caption: "average on each level — the only two changed lines")[
```js
    let s = 0;
    for (let i = 0; i < sz; i++) { const c = q.shift(); s += c.val; /* push children */ }
    out.push(s / sz);                         // plain / — JS has no integer division
```
]

Ran all three on T:

#table(columns: (auto, auto, auto, auto, auto),
  [*level*], [*nodes*], [*max*], [*sum*], [*average*],
  [1], [`1`],       [1], [1],  [1],
  [2], [`2 3`],     [3], [5],  [2.5],
  [3], [`4 5 6`],   [6], [15], [5],
  [4], [`7 8`],     [8], [15], [7.5],
)

#complexity(time: $O(n)$, space: $O(w)$)

#ans[max `[1,3,6,8]`, sum `[1,5,15,15]`, average `[1, 2.5, 5, 7.5]`]
]
]

#trap[
This is the one place where JavaScript is *easier* than C++. In C++, `sum / sz` with two
`int`s silently truncates and you must write `(double)sum / sz`. In JavaScript `/` is
always real division — `5 / 2` is `2.5`, which I checked in Node — so the average comes out
right by default.

The mirror-image trap is the one that bites JavaScript programmers: when you *want* the
whole part, `/` will not give it to you. `Math.floor(a / b)` is the fix, and it is needed
in binary search, in carry arithmetic, and in heap index maths.

There is no overflow worry here: a level of $10^5$ nodes holding $10^9$ each sums to
$10^14$, and I confirmed in Node that $10^14$ is still a safe integer.
]

#section[Tier 2 — views, shapes and one-pass checks]
#tier-header(2)

A *view* is what you see when you stand somewhere and look at the tree. Four views come
up again and again, and each is a one-line change to a traversal you already know.

#ex(14, tier: 2, asked: "Grab · pattern")[
*Right view:* standing on the right of the tree, list the nodes you can see, top to
bottom. Constraints: $n$ up to $10^5$. Target: $O(n)$.
Edge cases: empty tree; a left-only chain (you still see every node); a single node.

#sol[
#approach(1, "Level order, keep the last node of each level", verdict: "O(n) time, O(w) space")

#code(lang: "js", caption: "right view, BFS")[
```js
const rightView = (root) => {
  const out = [];
  if (root === null) return out;
  const q = new Deque(); q.push(root);
  while (q.size) {
    const sz = q.size;
    for (let i = 0; i < sz; i++) {
      const c = q.shift();
      if (i === sz - 1) out.push(c.val);   // last on this level
      if (c.left)  q.push(c.left);
      if (c.right) q.push(c.right);
    }
  }
  return out;
};
```
]

#approach(2, "DFS, right child first, record the first node seen at each depth", verdict: "O(n) time, O(h) space — better when the tree is wide")

If you always go right before left, the *first* node you reach at depth $d$ is the
rightmost node at that depth. "First time I reach depth $d$" is exactly
`depth === out.length`.

#code(lang: "js", caption: "right view, DFS")[
```js
const rvGo = (r, depth, out) => {
  if (r === null) return;
  if (depth === out.length) out.push(r.val);   // first node at this depth
  rvGo(r.right, depth + 1, out);               // RIGHT first
  rvGo(r.left,  depth + 1, out);
};

const rightViewDfs = (r) => { const out = []; rvGo(r, 0, out); return out; };
```
]

*Left view* is the same function with the two calls swapped.

#code(lang: "js", caption: "left view")[
```js
const lvGo = (r, depth, out) => {
  if (r === null) return;
  if (depth === out.length) out.push(r.val);
  lvGo(r.left,  depth + 1, out);               // LEFT first
  lvGo(r.right, depth + 1, out);
};

const leftView = (r) => { const out = []; lvGo(r, 0, out); return out; };
```
]

Ran all three on T: right view `[1,3,6,8]` (both approaches agree), left view
`[1,2,4,7]`.

#complexity(time: $O(n)$, space: $O(h)$, note: "the BFS version uses O(w) instead")

*The idea:* `depth === out.length` is a "have I been this deep before?" test that costs
nothing. Remember it; it replaces a `visitedDepth` array in many problems.

#ans[right `[1,3,6,8]`, left `[1,2,4,7]`]
]
]

#ex(15, tier: 2, asked: "Sea/Shopee · pattern")[
*Top view* and *bottom view:* give every node a column number — the root is column 0, a
left child is one less, a right child is one more. Looking straight down, list the
*first* node in each column (top view), left column to right column. Bottom view lists
the *last* one. Constraints: $n$ up to $10^5$; columns range from $-n$ to $n$.
Target: $O(n log n)$. Edge cases: empty tree; two nodes landing in the same column;
columns that cross under other nodes.

#sol[
#approach(1, "BFS carrying the column, stored in a Map", verdict: "O(n log n) — the standard answer, and the one to write first")

Do a BFS carrying the column, and remember one value per column.

#trap[
*JavaScript has no `TreeMap`, no ordered `map`, no ordered dictionary of any kind.* C++ gets
its columns back in sorted order for free; JavaScript does not. A `Map` keeps *insertion*
order, which for a BFS is the order the columns were first reached — `0, -1, 1, -2, ...`,
not left to right.

The workaround is one line: take the keys out and sort them yourself,
`[...firstAt.keys()].sort((a, b) => a - b)`. That is the $log n$ in the complexity.
]

#trap[
*That sort needs the comparator, and columns are exactly where forgetting it shows.*
`arr.sort()` compares *as text*. Tested in Node: `[-2, -1, 0, 1, 2].sort()` returns
`[-1, -2, 0, 1, 2]` — the two negative columns come out in the wrong order, because the
string `"-1"` is less than `"-2"`. With the comparator,
`[-2, -1, 0, 1, 2].sort((a, b) => a - b)` returns `[-2, -1, 0, 1, 2]`.

This is the single most common JavaScript bug in coding rounds. Any time you sort numbers,
write the comparator.
]

#code(lang: "js", caption: "top view")[
```js
const topView = (root) => {
  if (root === null) return [];
  const firstAt = new Map();                   // column -> value
  const q = new Deque(); q.push([root, 0]);
  while (q.size) {
    const [c, col] = q.shift();                // destructure the pair
    if (!firstAt.has(col)) firstAt.set(col, c.val);   // BFS: first seen is topmost
    if (c.left)  q.push([c.left,  col - 1]);
    if (c.right) q.push([c.right, col + 1]);
  }
  const cols = [...firstAt.keys()].sort((a, b) => a - b);   // NUMERIC sort
  return cols.map(k => firstAt.get(k));
};
```
]

Bottom view is the same code with one line changed: `lastAt.set(col, c.val);` with no
`has` guard — keep overwriting, so the deepest node in that column wins.

#note[
Use a `Map`, not a plain object, for the columns. An object turns the key `-1` into the
string `"-1"`, so you would have to convert it back with `Number(k)` before sorting — and
if you forget, the sort is lexicographic again and column $-10$ lands next to column $-1$.
A `Map` keeps the number a number.
]

#approach(2, "A plain array plus an offset", verdict: "O(n) — drops the log n")

A column can never be further than $n$ steps from the root, so an array of size
$2n + 1$ indexed by `col + n` replaces the `Map` *and* the sort. Track the smallest and
largest index used so you know where to start and stop reading.

#code(lang: "js", caption: "top view in O(n)")[
```js
const topViewFast = (root, n) => {             // n = number of nodes
  const out = [];
  if (root === null) return out;
  const val = new Array(2 * n + 1).fill(null); // column c lives at index c + n
  let lo = 2 * n, hi = 0;
  const q = new Deque(); q.push([root, 0]);
  while (q.size) {
    const [c, col] = q.shift();
    const idx = col + n;
    if (val[idx] === null) { val[idx] = c.val; lo = Math.min(lo, idx); hi = Math.max(hi, idx); }
    if (c.left)  q.push([c.left,  col - 1]);
    if (c.right) q.push([c.right, col + 1]);
  }
  for (let i = lo; i <= hi; i++) if (val[i] !== null) out.push(val[i]);
  return out;
};
```
]

#trap[
`new Array(k)` alone gives you $k$ *holes*, not $k$ values — `map` and `forEach` skip them
and `val[idx] === null` is false for every slot. Always finish it: `new Array(k).fill(null)`
or `Array.from({ length: k }, () => 0)`. Here `null` is the "empty column" marker, which
also frees you from needing an `INT_MIN` sentinel at all.
]
Ran it on T: `[4,2,1,3,6]` — identical to the map version.

Columns of tree T:

#table(columns: (auto, auto, auto, auto, auto),
  [*column*], [-2], [-1], [0], [+1],
  [*nodes, top to bottom*], [`4`], [`2`, `7`], [`1`, `5`], [`3`, `8`],
)
plus column +2 holding `6`.

Ran it: top view `[4,2,1,3,6]`, bottom view `[4,7,5,8,6]`.

#complexity(time: $O(n log n)$, space: $O(n)$, note: "the log n is sorting the Map keys; use an array plus an offset for O(n)")

#ans[top `[4,2,1,3,6]`, bottom `[4,7,5,8,6]`]
]
]

#trap[
*You must use BFS, not DFS, for the top view.* With DFS you might walk deep down the left
side and record a node at column 0 that sits at depth 5, before ever visiting the node at
column 0 and depth 2. BFS visits strictly by depth, so "first seen in a column" really
does mean "highest in that column".

Second trap: node `7` is at column $-1$ and node `8` is at column $+1$. They sit *under*
nodes `2` and `3`, crossing sideways. If you assume columns never cross, your code is
wrong on tree T.
]

#ex(16, tier: 2, asked: "Agoda · pattern")[
*Zigzag level order:* level 1 left to right, level 2 right to left, level 3 left to
right, and so on. Constraints: $n$ up to $10^5$. Target: $O(n)$.
Edge cases: one level; empty tree; a level holding a single node.

#sol[
Do not reverse the queue. Instead, pre-size the level array and *write into the right
slot*.

#code(lang: "js", caption: "zigzag level order")[
```js
const zigzag = (root) => {
  const out = [];
  if (root === null) return out;
  const q = new Deque(); q.push(root);
  let leftToRight = true;
  while (q.size) {
    const sz = q.size;
    const level = new Array(sz);
    for (let i = 0; i < sz; i++) {
      const c = q.shift();
      const pos = leftToRight ? i : sz - 1 - i;    // write forwards or backwards
      level[pos] = c.val;
      if (c.left)  q.push(c.left);
      if (c.right) q.push(c.right);
    }
    out.push(level);
    leftToRight = !leftToRight;
  }
  return out;
};
```
]

Ran it on T: `[[1],[3,2],[4,5,6],[8,7]]`.

#complexity(time: $O(n)$, space: $O(w)$)

*The idea:* the children are *always* pushed left-then-right. Only the *writing* flips.
Flipping the push order instead corrupts the next level.

Here `new Array(sz)` with no `fill` is safe, because every slot is written before the array
is read.

#ans[`[[1],[3,2],[4,5,6],[8,7]]`]
]
]

#ex(17, tier: 2, asked: "GIC · pattern")[
*Vertical order:* group every node by its column, columns from left to right, and inside
one column list the nodes top to bottom. Constraints: $n$ up to $10^5$.
Target: $O(n log n)$. Edge cases: empty tree; two nodes in the same column at the same
depth; a column holding three or more nodes.

#sol[
#approach(1, "Collect (column, depth, value) triples, then sort", verdict: "O(n log n) — and it handles every tie-break rule you might be asked for")

#code(lang: "js", caption: "vertical order by sorting triples")[
```js
const vtGo = (r, col, depth, all) => {
  if (r === null) return;
  all.push([col, depth, r.val]);
  vtGo(r.left,  col - 1, depth + 1, all);
  vtGo(r.right, col + 1, depth + 1, all);
};

const verticalSorted = (r) => {
  const all = [];
  vtGo(r, 0, 0, all);
  // column, then depth, then value — || picks the next key when the previous ties
  all.sort((a, b) => a[0] - b[0] || a[1] - b[1] || a[2] - b[2]);
  const out = [];
  for (let i = 0; i < all.length; ) {
    const col = all[i][0];
    const group = [];
    while (i < all.length && all[i][0] === col) { group.push(all[i][2]); i++; }
    out.push(group);
  }
  return out;
};
```
]

#trap[
C++ sorts an `array<int,3>` by comparing field after field for you. JavaScript sorts arrays
*as text* and would compare `"−1,1,2"` with `"0,0,1"` character by character — nonsense.

The multi-key comparator is
`(a, b) => a[0] - b[0] || a[1] - b[1] || a[2] - b[2]`. It works because `0` is falsy: if
the first difference is `0` (a tie), `||` moves on to the next key. Memorise this line; it
is how every "sort by X, then by Y" is written in JavaScript.
]

Ran it on T: `[[4],[2,7],[1,5],[3,8],[6]]`, and on tree U below: `[[2],[1,4,5],[3,6]]`.

#approach(2, "BFS with a Map", verdict: "O(n log n) — shorter, and the depth ordering comes free")

Same BFS with columns, but collect a *list* per column instead of one value.

#code(lang: "js", caption: "vertical order")[
```js
const verticalOrder = (root) => {
  const out = [];
  if (root === null) return out;
  const cols = new Map();
  const q = new Deque(); q.push([root, 0]);
  while (q.size) {
    const [c, col] = q.shift();
    if (!cols.has(col)) cols.set(col, []);     // no default-construct in JS
    cols.get(col).push(c.val);
    if (c.left)  q.push([c.left,  col - 1]);
    if (c.right) q.push([c.right, col + 1]);
  }
  for (const k of [...cols.keys()].sort((a, b) => a - b)) out.push(cols.get(k));
  return out;
};
```
]

#trap[
C++'s `cols[col].push_back(...)` creates an empty vector the first time a column is seen.
A JavaScript `Map` does not: `cols.get(col)` returns `undefined` and `.push` on it throws
`TypeError: Cannot read properties of undefined`. The two-line guard
`if (!cols.has(col)) cols.set(col, []);` is not optional.
]

Ran it on T: `[[4],[2,7],[1,5],[3,8],[6]]`.

I also ran it on a second tree U, where a column really fills up:

#diagram(height: 4.3cm, caption: "tree U: nodes 1, 4 and 5 all sit in column 0")[
  #dnode(3.4cm, 0pt,   1.0cm, 0.65cm, "1")
  #dnode(1.8cm, 1.1cm, 1.0cm, 0.65cm, "2")
  #dnode(5.0cm, 1.1cm, 1.0cm, 0.65cm, "3")
  #dnode(3.4cm, 2.2cm, 1.0cm, 0.65cm, "4")
  #dnode(4.9cm, 2.2cm, 1.0cm, 0.65cm, "5")
  #dnode(5.0cm, 3.3cm, 1.0cm, 0.65cm, "6")
  #darrow(3.7cm, 0.65cm, 2.5cm, 1.1cm)
  #darrow(4.1cm, 0.65cm, 5.4cm, 1.1cm)
  #darrow(2.6cm, 1.75cm, 3.6cm, 2.2cm)
  #darrow(5.2cm, 1.75cm, 5.1cm, 2.2cm)
  #darrow(5.3cm, 2.85cm, 5.4cm, 3.3cm)
]

Result for U: vertical `[[2],[1,4,5],[3,6]]`, top view `[2,1,3]`,
bottom view `[2,5,6]`.

#complexity(time: $O(n log n)$, space: $O(n)$)

#ans[`[[4],[2,7],[1,5],[3,8],[6]]`]
]
]

#note[
Some versions of this question add a tie-break: *inside one column, if two nodes are at
the same depth, list the smaller value first.* The BFS above lists them in left-to-right
order instead. If the statement asks for the tie-break, store triples
`[column, depth, value]`, collect them all, then sort with
`(a, b) => a[0] - b[0] || a[1] - b[1] || a[2] - b[2]`. Ask the interviewer which rule they
want.
]

#ex(18, tier: 2, asked: "SCB · pattern")[
*Boundary traversal:* print the root, then the left edge going down (not counting
leaves), then every leaf left to right, then the right edge coming up (not counting
leaves). Each node appears exactly once.
Constraints: $n$ up to $10^5$. Target: $O(n)$.
Edge cases: single node (the root is itself a leaf); a tree with no right child at all;
an empty tree.

#sol[
Three helpers, and one rule that prevents double printing: *the edges skip leaves,
because the leaf pass will print them.*

#code(lang: "js", caption: "boundary traversal")[
```js
const isLeaf = (n) => n.left === null && n.right === null;

const addLeftEdge = (r, out) => {
  let c = r.left;
  while (c !== null) {
    if (!isLeaf(c)) out.push(c.val);
    c = c.left !== null ? c.left : c.right;   // prefer left, else right
  }
};

const addLeaves = (r, out) => {
  if (r === null) return;
  if (isLeaf(r)) { out.push(r.val); return; }
  addLeaves(r.left, out);
  addLeaves(r.right, out);
};

const addRightEdge = (r, out) => {
  const tmp = [];
  let c = r.right;
  while (c !== null) {
    if (!isLeaf(c)) tmp.push(c.val);
    c = c.right !== null ? c.right : c.left;
  }
  for (let i = tmp.length - 1; i >= 0; i--) out.push(tmp[i]);   // reversed
};

const boundary = (root) => {
  const out = [];
  if (root === null) return out;
  if (!isLeaf(root)) out.push(root.val);
  addLeftEdge(root, out);
  addLeaves(root, out);
  addRightEdge(root, out);
  return out;
};
```
]

Ran it on T: `[1,2,4,7,8,6,3]`.
Read it: root `1`; left edge `2` (node `4` is a leaf, skipped); leaves `4 7 8 6`; right
edge `3`, reversed (just one node).
On a single node `9`: `[9]`. On `null`: `[]`.

#complexity(time: $O(n)$, space: $O(h)$)

*The idea:* the right edge is collected *downward* and printed *upward*, so it needs a
temporary list. Everything else is printed as it is found.
]
]

#trap[
Three separate double-print traps, all fixed by one habit — *the edges skip leaves*:
1. The root, if it is a leaf (single-node tree), must not be printed twice.
2. A leaf on the left edge is printed by `addLeaves`, not by `addLeftEdge`.
3. Same for the right edge.
Check your answer's length: it must equal the number of *distinct* boundary nodes.
]

#ex(19, tier: 2, asked: "Razer · pattern")[
Is the tree *height-balanced*? That means: for every node, the heights of its two
subtrees differ by at most 1.
Constraints: $n$ up to $10^5$. Edge cases: empty tree (balanced); a chain (not, for
$n >= 3$); a perfect tree.

#sol[
#approach(1, "For each node, call height() on both children", verdict: "O(n^2) — height is recomputed from scratch at every node")

#code(lang: "js", caption: "the slow version")[
```js
const balancedSlow = (r) => {
  if (r === null) return true;
  if (Math.abs(height(r.left) - height(r.right)) > 1) return false;
  return balancedSlow(r.left) && balancedSlow(r.right);
};
```
]
On a chain of $10^5$ nodes this does about $10^10$ steps. Far too slow.

#approach(3, "Compute the height and the verdict in the same pass", verdict: "O(n) — optimal")

Let the height function return a *sentinel* $-1$ meaning "something below me is already
unbalanced". A real height is never negative, so there is no clash.

#code(lang: "js", caption: "balanced in one pass")[
```js
const balHeight = (r) => {               // -1 means "not balanced"
  if (r === null) return 0;
  const lh = balHeight(r.left);
  if (lh === -1) return -1;              // bail out early
  const rh = balHeight(r.right);
  if (rh === -1) return -1;
  if (Math.abs(lh - rh) > 1) return -1;
  return 1 + Math.max(lh, rh);
};

const balanced = (r) => balHeight(r) !== -1;
```
]

Ran it:

#table(columns: (1fr, auto),
  [*tree*], [*balanced?*],
  [T], [true],
  [chain `1 → 2 → 3 → 4`], [false],
  [perfect tree of 7 nodes], [true],
  [empty tree], [true],
)

#complexity(time: $O(n)$, space: $O(h)$)

*The idea:* a function that returns *either* a measurement *or* a failure flag. This
"sentinel return" trick turns many $O(n^2)$ tree checks into $O(n)$ — you will use it
again for "is this a BST" in Chapter 13.

#ans[T is balanced; a chain of 4 is not]
]
]

#ex(20, tier: 2, asked: "DBS · pattern")[
*Maximum width:* the widest level, counting the empty gaps between the leftmost and
rightmost real node on that level.
Constraints: depth up to 60, so the index can be huge. Edge cases: empty tree;
single node; a very deep tree (index overflow).

#sol[
#approach(1, "Level order, pushing null for missing children", verdict: "O(2^h) — it works on small trees and dies on deep ones")

If you push a `null` placeholder for every missing child, each level is a full row and
the width is just "trim the nulls off both ends". Ran it on T: it gives the right answer,
*4*. Then I ran it on a chain of 40 nodes with a budget of ten million pushes: it ran out
of room and returned my "gave up" marker. A chain of depth 40 needs $2^40$ placeholders.

#approach(2, "Number the nodes like an array heap", verdict: "O(n) — optimal")

Give the root index 0. Then a node with index $i$ has children $2i$ and $2i+1$ — the
same numbering as an array heap. The width of a level is
`lastIndex - firstIndex + 1`.

#code(lang: "js", caption: "maximum width")[
```js
const maxWidth = (root) => {
  if (root === null) return 0;
  let best = 0;
  const q = new Deque(); q.push([root, 0]);
  while (q.size) {
    const sz = q.size;
    const first = q.front()[1];                   // leftmost index on this level
    let last = 0;
    for (let i = 0; i < sz; i++) {
      const [c, raw] = q.shift();
      const idx = raw - first;                    // re-base: keeps every index small
      last = idx;
      if (c.left)  q.push([c.left,  2 * idx]);
      if (c.right) q.push([c.right, 2 * idx + 1]);
    }
    best = Math.max(best, last + 1);
  }
  return best;
};
```
]

Ran it: `maxWidth(T)=4` (level 3 holds `4`, `5`, `6` at indices 0, 1, 3 — so the width
counts the gap). `maxWidth(null)=0`, single node `1`, and the tree
`{1,2,3,4,-,-,7}` also gives `4`.

#complexity(time: $O(n)$, space: $O(w)$)

#ans[4]
]
]

#trap[
*Indices double every level, and a JavaScript number stops being exact at $2^53 - 1$.*
There is no unsigned 64-bit integer type to reach for. I printed the raw index down a right-leaning
chain in Node: at depth 50 it is `1125899906842623` and `Number.isSafeInteger` is still
`true`; at depth 60 it is `1152921504606847000` and `Number.isSafeInteger` is *false* —
the trailing digits are already made up.

I then built a right chain of depth $D$ with two children at the bottom, so the true answer
is always *2*, and ran both versions:

#table(columns: (auto, auto, auto),
  [*depth*], [*without `raw - first`*], [*with it*],
  [20], [2], [2],
  [50], [2], [2],
  [54], [*3*], [2],
  [58], [*1*], [2],
)

Two different wrong answers, silently. The one-line fix is `const idx = raw - first;` —
re-base every level so the leftmost node is index 0, and the numbers never grow past the
width of the tree. This is the whole point of the problem.

If you ever genuinely need indices past $2^53$, `BigInt` is exact: `2n * idx + 1n`. It is
slower and you cannot mix it with plain numbers, so re-basing is the better answer here.
]

#ex(21, tier: 2, asked: "LINE MAN · pattern")[
*Children-sum property:* for every non-leaf node, the value equals the sum of its
children's values (a missing child counts as 0). Check it.
Constraints: $n$ up to $10^5$, values from 0 to $10^9$. Target: $O(n)$.
Edge cases: single node (true by definition); a node with only one child; an empty tree.

#sol[
#code(lang: "js", caption: "children sum check")[
```js
const childrenSum = (r) => {
  if (r === null) return true;
  if (r.left === null && r.right === null) return true;    // leaves pass
  let s = 0;
  if (r.left)  s += r.left.val;
  if (r.right) s += r.right.val;
  return s === r.val && childrenSum(r.left) && childrenSum(r.right);
};
```
]

Ran it: tree T → `false` (node 1 has children 2 and 3, and $2 + 3 != 1$).
`{10, 4, 6}` → `true`. `{10, 4, 5}` → `false`. `null` → `true`.

#complexity(time: $O(n)$, space: $O(h)$)

#ans[false for T, true for `{10,4,6}`]
]
]

#section[Tier 3 — two answers at once]
#tier-header(3)

#ex(22, tier: 3, asked: "Amazon · pattern")[
*Diameter:* the number of edges on the longest path between any two nodes. The path does
not have to pass through the root.
Constraints: $n$ up to $10^5$, so $O(n^2)$ will time out.
Edge cases: empty tree (0); single node (0); a chain of $k$ nodes ($k-1$).

#sol[
#approach(1, "For every node, height(left) + height(right)", verdict: "O(n^2) — recomputes the same heights over and over")

#code(lang: "js", caption: "brute force diameter")[
```js
const diameterSlow = (r) => {
  if (r === null) return 0;
  const through = height(r.left) + height(r.right);    // edges through r
  return Math.max(through, diameterSlow(r.left), diameterSlow(r.right));
};
```
]
Correct, but on a chain of $10^5$ nodes it is $10^10$ steps.

#approach(3, "One postorder pass: return the height, record the best diameter", verdict: "O(n) — optimal")

This is the *return-one-record-another* shape from the pattern page. Each node needs two
numbers, and only one of them can be a return value — so the other one lives in a variable
the inner function closes over.

#code(lang: "js", caption: "diameter in one pass")[
```js
const diameter = (root) => {
  let best = 0;                             // the closure replaces C++'s int &best
  const go = (r) => {
    if (r === null) return 0;
    const lh = go(r.left);
    const rh = go(r.right);
    best = Math.max(best, lh + rh);         // RECORD: path bending at r, in edges
    return 1 + Math.max(lh, rh);            // RETURN: height, for my parent
  };
  go(root);
  return best;
};
```
]

Ran both versions. On T: `5` from each. Edge cases from the fast one:
`diameter(null) = 0`, single node `0`, chain of 4 nodes `3`.

I also generated *200 random trees* of up to 12 nodes and checked that the slow and fast
versions agree on every single one. They do. That is the test you should write whenever
you replace a brute force with a clever version.

#complexity(time: $O(n)$, space: $O(h)$)

*The idea:* the path with the most edges either bends at this node (then it is
`lh + rh`), or it lies entirely inside one child (then a deeper call already recorded
it). Those two cases are exhaustive, so one pass is enough.

#ans[5]
]
]

#formulas(title: "Diameter follow-ups")[
*"Return the actual path, not just its length."* Store, at each node, the child that gave
the taller arm. After the pass, walk down from the recorded bend node in both directions.

*"Values are weights on the edges."* Replace `1 + Math.max(lh, rh)` with
`weight + Math.max(lh, rh)` and `lh + rh` stays as it is. The shape does not change at
all.

*"It is a general tree, not binary."* Loop over the children, keep the *two* largest
arms, record their sum. Same $O(n)$.
]

#ex(23, tier: 3, asked: "Google · pattern")[
*Lowest common ancestor:* given two values that are both present, find the deepest node
that has both of them somewhere below it (a node counts as its own ancestor).
Constraints: $n$ up to $10^5$, values distinct.
Edge cases: one value is an ancestor of the other; both in the same subtree.

#sol[
#approach(1, "Build the root-to-node path for each value, then compare", verdict: "O(n) time, O(h) space — correct, safe with missing values, and longer to write")

#code(lang: "js", caption: "LCA via paths")[
```js
const pathTo = (r, x, p) => {
  if (r === null) return false;
  p.push(r.val);
  if (r.val === x) return true;
  if (pathTo(r.left, x, p) || pathTo(r.right, x, p)) return true;
  p.pop();                                      // un-choose
  return false;
};

const lcaSlow = (r, a, b) => {
  const pa = [], pb = [];
  if (!pathTo(r, a, pa) || !pathTo(r, b, pb)) return null;   // a value is missing
  let i = 0, ans = null;
  while (i < pa.length && i < pb.length && pa[i] === pb[i]) { ans = pa[i]; i++; }
  return ans;                                   // last shared node on the two paths
};
```
]
Ran it on T: (4, 8) → 2, (4, 6) → 1, (7, 8) → 5, (2, 7) → 2, and (4, 99) → `null`.
Note the last one — this version *detects* a missing value, which the short version below
does not. `null` is the right "absent" marker here: there is no `INT_MIN` in JavaScript,
and `-Infinity` would be a strange thing to return where a node value is expected.

#approach(2, "One pass, report upward", verdict: "O(n) time, O(h) space — shorter, and the version interviewers want")

Three lines of logic, and they are worth memorising word for word.

#code(lang: "js", caption: "lowest common ancestor")[
```js
const lca = (r, p, q) => {
  if (r === null) return null;
  if (r.val === p || r.val === q) return r;     // found one: report myself upward
  const L = lca(r.left,  p, q);
  const R = lca(r.right, p, q);
  if (L && R) return r;                         // they split here: this is the LCA
  return L || R;                                // both on one side, pass it up
};
```
]

Ran it on T:

#table(columns: (auto, auto, auto),
  [*pair*], [*LCA*], [*why*],
  [4 and 8], [2], [4 is under 2's left, 8 is under 2's right],
  [4 and 6], [1], [different sides of the root],
  [7 and 8], [5], [both are children of 5],
  [2 and 7], [2], [7 is *under* 2, so 2 is its own ancestor],
)

#complexity(time: $O(n)$, space: $O(h)$)

*The idea:* a node returns "the useful thing I found below me". If both sides return
something, the two values split here and *this* node is the answer. If only one side
returns something, that answer is already correct — just pass it up unchanged.
]
]

#trap[
The last row is the subtle one. When `p` is an ancestor of `q`, the function stops at `p`
and never even looks for `q`. That is fine *only because the problem promises both values
exist*. If a value might be missing, this code returns a wrong answer — I ran
`lca(T, 4, 999)` and it returned the node holding *4*. To be safe, first `contains()` both
values in $O(n)$, or carry two boolean flags up alongside the node.
]

#trap[
`return L || R;` is shorter than the ternary and means the same thing *here*, because a
node object is always truthy and the only other value is `null`. Do not carry that habit
into a function that returns numbers: `0 || R` skips the perfectly valid `0`. When the
value can be falsy, use `L ?? R` (nullish coalescing) or a real `=== null` test.
]

#ex(24, tier: 3, asked: "Microsoft · pattern")[
*Maximum path sum:* find the largest sum over all paths. A path is any sequence of nodes
connected parent-to-child, going up and then down at most once. It need not touch the
root or a leaf.
Constraints: values from $-10^4$ to $10^4$, $n$ up to $10^5$.
Edge cases: every value negative; a single node; a mix.

#sol[
Same shape as the diameter, with two extra ideas:
1. A branch whose best sum is negative should be *dropped* — use `max(0, ...)`.
2. The recorded best must include *this node alone*, in case both branches are dropped.

#code(lang: "js", caption: "maximum path sum")[
```js
const maxPathSum = (root) => {
  let best = -Infinity;                     // NOT 0: every value may be negative
  const go = (r) => {
    if (r === null) return 0;
    const L = Math.max(0, go(r.left));      // drop a negative branch
    const R = Math.max(0, go(r.right));
    best = Math.max(best, L + R + r.val);   // RECORD: path bending at r
    return r.val + Math.max(L, R);          // RETURN: best straight arm
  };
  go(root);
  return best;
};
```
]

Ran it:

#table(columns: (1fr, auto, auto),
  [*tree*], [*answer*], [*best path*],
  [T], [25], [`8 → 5 → 2 → 1 → 3 → 6`],
  [`{-3, -2, -9}`], [-2], [the single node `-2`],
  [`{-5}`], [-5], [the only node],
  [`{2, -1, 3}`], [5], [`2 + 3`; the `-1` branch is dropped],
)

Let me show the T arithmetic in full, because it is the whole lesson:

#table(columns: (auto, auto, auto, auto),
  [*node*], [`L`], [`R`], [*record* `L + R + val`],
  [4], [0], [0], [4],
  [7], [0], [0], [7],
  [8], [0], [0], [8],
  [5], [7], [8], [*20*],
  [2], [4], [`5 + 8 = 13`], [19],
  [6], [0], [0], [6],
  [3], [0], [6], [9],
  [1], [`2 + 13 = 15`], [9], [*25*],
)

Read the last row: the arm coming up from `2` is `2 + max(4, 13) = 15`, which is the
chain `8 → 5 → 2`. The arm coming up from `3` is `3 + 6 = 9`. Bending at the root gives
$15 + 9 + 1 = 25$, so the winning path is `8 → 5 → 2 → 1 → 3 → 6`.

#complexity(time: $O(n)$, space: $O(h)$)

#ans[25]
]
]

#trap[
Initialise `best` to `-Infinity`, not 0. On the all-negative tree `{-3,-2,-9}` the true
answer is $-2$; starting at 0 would return 0, a sum no path can produce. I ran exactly that
case and it returns $-2$.

`Math.max(0, go(r.left))` needs no type suffix — this is the one spot where JavaScript is
kinder than C++, which forces you to write `max(0LL, ...)` or fail to compile. The cost of
that kindness is that JavaScript will not warn you about anything at all, so *you* have to
remember that `best` must start at `-Infinity`. Test the all-negative tree every time.
]

#ex(25, tier: 3, asked: "Goldman Sachs · pattern")[
Rebuild the tree from its preorder list and its inorder list. All values are distinct.
Constraints: $n$ up to $10^5$. Target: $O(n)$.
Edge cases: empty lists; a single node; a left-only chain.

#sol[
Two facts do all the work:
1. The *first* value in preorder is the root.
2. In the inorder list, everything *before* the root belongs to the left subtree and
   everything *after* belongs to the right subtree.

So one scan of preorder, left to right, hands out roots in exactly the order the
recursion needs them. Use a *shared* index `pi` that only ever moves forward.

#approach(1, "Find the root in the inorder list with a linear scan", verdict: "O(n^2) — fine for n = 1000, too slow at 10^5")

```js
let m = lo;
while (ino[m] !== v) m++;        // O(n) work, at every one of the n nodes
```
I ran this version on T's own traversals and it rebuilt the tree correctly — it is not
wrong, only slow. On a left-only chain of $10^5$ nodes it does about $5 times 10^9$ steps.

#approach(2, "Look the root up in a hash map", verdict: "O(n) — optimal")

#diagram(height: 3.2cm, caption: "preorder gives the root; inorder splits the rest")[
  #dnode(0pt, 0pt, 10.5cm, 0.7cm, "preorder:  [ 1 | 2 4 5 7 8 | 3 6 ]")
  #dnode(0pt, 1.1cm, 10.5cm, 0.7cm, "inorder:   [ 4 2 7 5 8 | 1 | 3 6 ]")
  #darrow(0.7cm, 0.7cm, 5.2cm, 1.1cm, label: "root")
  #dnode(0pt, 2.3cm, 10.5cm, 0.7cm, "left subtree = 5 values, right subtree = 2 values", fill: rgb("#e6f0e6"))
]

#code(lang: "js", caption: "build from preorder + inorder")[
```js
const buildFrom = (pre, ino) => {
  const pos = new Map();                     // value -> index, O(1) lookups
  ino.forEach((v, i) => pos.set(v, i));
  let pi = 0;                                // ONE shared cursor, closed over
  const go = (lo, hi) => {
    if (lo > hi) return null;
    const v = pre[pi++];                     // next root, in preorder
    const r = new Node(v);
    const m = pos.get(v);                    // where it sits in inorder
    r.left  = go(lo, m - 1);
    r.right = go(m + 1, hi);
    return r;
  };
  return go(0, ino.length - 1);
};
```
]

Ran it: I took T's own lists, `pre = [1,2,4,5,7,8,3,6]` and `ino = [4,2,7,5,8,1,3,6]`,
rebuilt the tree, and compared the new tree's preorder and inorder against the originals
with `JSON.stringify`. Both matched exactly. Empty lists give `null`; `[9]` and `[9]` give
a single node.

#complexity(time: $O(n)$, space: $O(n)$, note: "the Map is what makes it O(n) instead of O(n^2)")

*The idea:* there is exactly *one* `pi`, and the inner `go` sees it because it is defined
inside `buildFrom`. The left subtree's recursion consumes exactly as many preorder values
as it has nodes, so when it returns, `pi` is already pointing at the right subtree's root.

#trap[
Writing `const go = (lo, hi, pi) => ...` and passing `pi` down as an argument breaks
everything silently. A number argument is a *copy*: each call gets its own `pi`, the
increments never travel back up, and the tree comes out wrong with no error. This is the
JavaScript version of C++'s "you forgot the `&`". Keep `pi` in the enclosing scope.
]

#note[
Use a `Map` for `pos`, not a plain object. Object keys are strings, so a value of `-3`
becomes `"-3"` and `pos[-3]` happens to still work — until you iterate the keys and find
strings where you expected numbers. `Map` keeps the number a number and is faster for
$10^5$ inserts.
]
]
]

#note[
*Which pairs of traversals are enough?* Preorder + inorder works. Postorder + inorder
works. Preorder + postorder does *not* — it cannot tell a single left child from a single
right child. This is a favourite follow-up question, and the one-line answer above is
what the interviewer wants.
]

#ex(26, tier: 3, asked: "Amazon · pattern")[
*Serialise and deserialise:* turn any binary tree into a string, and turn that string
back into the identical tree.
Constraints: $n$ up to $10^4$, values from $-1000$ to $1000$. Target: $O(n)$ each way.
Edge cases: empty tree; a node whose value is negative; a one-sided tree.

#sol[
Level order with an explicit marker for a missing child. I use `#` for "no node" and a
comma after every token.

#code(lang: "js", caption: "serialize")[
```js
const serialize = (root) => {
  let s = '';
  const q = new Deque(); q.push(root);
  while (q.size) {
    const c = q.shift();
    if (c === null) { s += '#,'; continue; }
    s += c.val + ',';                        // number + string -> string, no to_string
    q.push(c.left); q.push(c.right);         // push nulls too
  }
  return s;
};
```
]

#code(lang: "js", caption: "deserialize")[
```js
const deserialize = (s) => {
  const tok = s.split(',');
  tok.pop();                                 // the trailing comma leaves an empty token
  if (tok.length === 0 || tok[0] === '#') return null;
  const root = new Node(Number(tok[0]));
  const q = new Deque(); q.push(root);
  let i = 1;
  while (q.size && i < tok.length) {
    const c = q.shift();
    if (i < tok.length && tok[i] !== '#') { c.left  = new Node(Number(tok[i])); q.push(c.left); }
    i++;
    if (i < tok.length && tok[i] !== '#') { c.right = new Node(Number(tok[i])); q.push(c.right); }
    i++;
  }
  return root;
};
```
]

Ran it on T. The string was

`1,2,3,4,5,#,6,#,#,7,8,#,#,#,#,#,#,`

I fed that straight back into `deserialize` and printed the preorder of the result:
`[1,2,4,5,7,8,3,6]` — identical to T. `serialize(null)` gives `"#,"` and
`deserialize("#,")` gives `null`. I also round-tripped the tree `{-7, -8, 9}` and got
`[-7,-8,9]` back.

#complexity(time: $O(n)$, space: $O(n)$)

*The idea:* `Number("-8")` handles the leading minus sign, so negative values survive the
round trip. If values could contain a comma you would need a different separator — say so.

#trap[
Three JavaScript-only details in these twenty lines.

1. `'1,2,3,'.split(',')` returns `['1','2','3','']` — a trailing separator leaves an *empty
   last token*. The `tok.pop()` removes it. Without it, `Number('')` is `0` and you grow a
   phantom node holding zero.
2. Use `Number(tok[i])`, not `parseInt(tok[i])`. `parseInt('12abc')` happily returns `12`,
   so corrupt input passes silently; `Number('12abc')` gives `NaN`, which you can check.
3. `s += c.val + ','` works because a number plus a string is a string. That is convenient
   here and a menace elsewhere: `'5' + 3` is `'53'`, while `'5' - 3` is `2`.
]
]
]

#trap[
The `#` markers are not optional. `1,2,3` alone does not say whether `3` is the right
child of `1` or the left child of `2`. Every missing child needs a marker, which is why
the serialised string is longer than the node count. A preorder serialisation with
markers works equally well — pick one and be consistent.
]

#ex(27, tier: 3, asked: "Uber · pattern")[
Given a target *node* (by value) and a number $k$, list every node exactly $k$ edges away
— above, below, or sideways through the parent.
Constraints: $n$ up to $10^5$. Edge cases: $k = 0$; $k$ larger than the tree;
the target is missing.

#sol[
A tree only has *downward* pointers, but this problem needs to walk *upward*. There are
two ways to get that.

#approach(1, "Build a parent map, then BFS", verdict: "O(n) time, O(n) space — longer in memory, much easier to get right")

Build a parent map once, and then the tree is just an undirected graph — so do a plain
BFS from the target and stop at distance $k$.

#code(lang: "js", caption: "nodes at distance k")[
```js
const mapParents = (r, par) => {
  const q = new Deque(); q.push(r); par.set(r, null);
  while (q.size) {
    const c = q.shift();
    if (c.left)  { par.set(c.left,  c); q.push(c.left); }
    if (c.right) { par.set(c.right, c); q.push(c.right); }
  }
};

const distanceK = (root, targetVal, k) => {
  const out = [];
  if (root === null) return out;
  const target = findNode(root, targetVal);
  if (target === null) return out;
  const par = new Map();                     // Map, not an object: the KEYS are nodes
  mapParents(root, par);

  const seen = new Set([target]);
  const q = new Deque(); q.push(target);
  let dist = 0;
  while (q.size) {
    if (dist === k) {                        // everything in the queue is at distance k
      while (q.size) out.push(q.shift().val);
      break;
    }
    const sz = q.size;
    for (let i = 0; i < sz; i++) {
      const c = q.shift();
      for (const nb of [c.left, c.right, par.get(c)])       // three neighbours
        if (nb && !seen.has(nb)) { seen.add(nb); q.push(nb); }
    }
    dist++;
  }
  out.sort((a, b) => a - b);                 // NUMERIC sort, never a bare sort()
  return out;
};
```
]

#trap[
*This is the problem where a plain object would destroy you.* `par` maps a *node object* to
its parent node. A plain object converts every key with `String(key)`, and every node
object becomes the same string `"[object Object]"` — so all $10^5$ entries collide into
one. `Map` and `Set` compare objects by identity, which is the whole point.

Use `Map` when the key is an object, a number you want to stay a number, or anything you
will iterate in insertion order. Use a plain object only for fixed string keys you typed
yourself.
]

#trap[
`out.sort()` with no comparator would return `[1, 4]` correctly by luck and
`[10, 4]` as `[10, 4]` wrongly. Values here go to $10^5$. Write
`out.sort((a, b) => a - b)`.
]

#code(lang: "js", caption: "the findNode helper this uses")[
```js
const findNode = (r, x) => {
  if (r === null) return null;
  if (r.val === x) return r;
  return findNode(r.left, x) || findNode(r.right, x);
};
```
]

Ran it on T:

#table(columns: (auto, auto, auto, 1fr),
  [*target*], [`k`], [*answer*], [*why*],
  [5], [2], [`[1, 4]`], [up to 2 then to 1, and up to 2 then down to 4],
  [5], [0], [`[5]`], [distance 0 is the node itself],
  [1], [1], [`[2, 3]`], [the root's two children],
  [5], [9], [`[]`], [nothing is that far],
  [99], [1], [`[]`], [target not in the tree],
)

#complexity(time: $O(n)$, space: $O(n)$, note: "the parent map is the O(n) space")

*The idea:* the `seen` set is what stops the BFS from bouncing back down the branch it
just came up. Without it, the search runs forever.

#approach(2, "No parent map: let the recursion carry the distance back up", verdict: "O(n) time, O(h) space — shorter, and far easier to get wrong")

A node asks its left subtree "how far below you is the target?". If the answer is `dl`,
then this node is at distance `dl + 1`. Two things can happen from here: this node itself
is at distance `k`, or the answer lies in the *other* subtree, `k - dl - 2` levels down
(one step up to this node, one step down into the other side).

#code(lang: "js", caption: "distance k without a parent map")[
```js
const downK = (r, k, out) => {                    // nodes exactly k below r
  if (r === null || k < 0) return;
  if (k === 0) { out.push(r.val); return; }
  downK(r.left,  k - 1, out);
  downK(r.right, k - 1, out);
};

// returns the distance from r down to the target, or -1 if it is not below r
const kGo = (r, target, k, out) => {
  if (r === null) return -1;
  if (r.val === target) { downK(r, k, out); return 0; }

  const dl = kGo(r.left, target, k, out);
  if (dl !== -1) {
    if (dl + 1 === k) out.push(r.val);
    else downK(r.right, k - dl - 2, out);         // cross over through r
    return dl + 1;
  }
  const dr = kGo(r.right, target, k, out);
  if (dr !== -1) {
    if (dr + 1 === k) out.push(r.val);
    else downK(r.left, k - dr - 2, out);
    return dr + 1;
  }
  return -1;
};
```
]

I ran *both* versions on every pair (target, $k$) with the target one of T's 8 values and
$k$ from 0 to 6 — 56 cases, compared with `JSON.stringify`. They agree on all 56. Spot
check from node `4`:

#table(columns: (auto, auto, auto, auto, auto),
  [`k`], [0], [1], [2], [3],
  [*answer*], [`[4]`], [`[2]`], [`[1,5]`], [`[3,7,8]`],
)

*The idea:* `k - dl - 2` is the whole problem in one expression. Get it wrong by one and
you will pass the easy tests and fail the crossing ones. Write out a small case by hand
before you trust it.
]
]

#formulas(title: "Follow-ups on distance-k")[
*"Now the tree is burning — it starts at that node and spreads one edge per second.
How long until the whole tree burns?"* Identical code, but instead of stopping at
distance $k$, run the BFS to the end and return the number of levels minus one.
I ran it on T: from node `5` it takes *4* seconds, from the root `1` it takes *3*, and
from leaf `4` it takes *4*. A single-node tree takes *0*. The code is the same BFS with the
`dist === k` early exit removed and `dist` returned at the end.

*"The tree has a million nodes and you get thousands of queries."* Pre-compute the
parent map *once*, not per query. Better still, root the tree, store an Euler tour, and
answer each query with binary lifting in $O(log n)$ — that is the standard escalation and
it belongs to the graph chapters.
]

#ex(28, tier: 3, asked: "Adobe · pattern")[
Do the inorder traversal in $O(1)$ extra space — no recursion, no stack.
Constraints: $n$ up to $10^6$, and the tree must be unchanged when you finish.

#sol[
This is *Morris traversal*. The idea: before going down-left, find the node that would
be visited just before this one (the rightmost node of the left subtree, the
*predecessor*) and make its empty `right` reference point *back* at this node. That
temporary link is called a *thread*. When you come back up through the thread, you
remove it, restoring the tree.

This is also the only traversal in the chapter that is safe on a $10^6$-node chain in
JavaScript: no recursion, and no stack array either.

#diagram(height: 3.2cm, caption: "the thread: 4's empty right pointer temporarily points back to 2")[
  #dnode(3.6cm, 0pt,   1.1cm, 0.7cm, "2")
  #dnode(1.6cm, 1.4cm, 1.1cm, 0.7cm, "4")
  #dnode(5.6cm, 1.4cm, 1.1cm, 0.7cm, "5")
  #darrow(3.8cm, 0.7cm, 2.3cm, 1.4cm, label: "left")
  #darrow(4.5cm, 0.7cm, 5.9cm, 1.4cm, label: "right")
  #darrow(2.7cm, 1.6cm, 4.0cm, 0.75cm, label: "thread", dashed: true)
  #dnode(0pt, 2.5cm, 10.5cm, 0.65cm, "walk down-left, leaving a way back; on the way back, cut the thread", fill: rgb("#f7f3e6"))
]

#code(lang: "js", caption: "Morris inorder, O(1) space")[
```js
const morrisInorder = (root) => {
  const out = [];
  let cur = root;
  while (cur !== null) {
    if (cur.left === null) {
      out.push(cur.val);               // nothing on the left: visit and go right
      cur = cur.right;
    } else {
      let pred = cur.left;
      while (pred.right !== null && pred.right !== cur) pred = pred.right;
      if (pred.right === null) {
        pred.right = cur;              // PUT the thread
        cur = cur.left;
      } else {
        pred.right = null;             // REMOVE the thread: left side is done
        out.push(cur.val);
        cur = cur.right;
      }
    }
  }
  return out;
};
```
]

Ran it on T: `[4,2,7,5,8,1,3,6]` — identical to the recursive inorder. Then I ran the
*recursive* inorder again on the same tree afterwards and got the same list, proving the
threads were all removed and T was left intact. `morrisInorder(null)` gives `[]`;
a single node gives `[9]`.

#complexity(time: $O(n)$, space: $O(1)$, note: "each edge is walked at most 3 times, so it is still linear")

*The idea:* the inner `while` stops on `pred.right !== cur` as well as on `null`. That
second test is how you tell "I am going down for the first time" from "I have come back
up through my own thread". Note it compares *node identity* with `!==`, not values. Drop
it and the loop never ends.
]
]

#ex(29, tier: 3, asked: "D. E. Shaw · pattern")[
*Flatten* the tree into a right-leaning chain, in preorder, using $O(1)$ extra space.
Every node's `left` must end up `null`.
Constraints: $n$ up to $10^5$; extra space must be $O(1)$, so no recursion and no stack.
Edge cases: empty tree; a tree with no left children at all; a single node.

#sol[
Same threading idea as Morris, but this time the rewiring is permanent.

For each node that has a left subtree: find the *rightmost* node of that left subtree,
hang the current right subtree off it, then move the whole left subtree to the right and
clear `left`. Then step right and repeat.

#code(lang: "js", caption: "flatten to a preorder chain")[
```js
const flatten = (root) => {
  let cur = root;
  while (cur !== null) {
    if (cur.left !== null) {
      let pred = cur.left;
      while (pred.right !== null) pred = pred.right;   // rightmost of left
      pred.right = cur.right;                          // hang the right side there
      cur.right = cur.left;                            // left becomes right
      cur.left = null;
    }
    cur = cur.right;
  }
};
```
]

Ran it on a copy of T, then walked the chain following only `right` references:
`[1,2,4,5,7,8,3,6]`. That is exactly T's preorder, and I checked that every `left`
along the chain is `null`.

Note that `flatten` returns nothing — it rewires the tree in place. That works because
objects are passed by reference in JavaScript: `cur.left = null` changes the caller's tree.
Reassigning the parameter itself (`root = something`) would *not* be visible outside.

#complexity(time: $O(n)$, space: $O(1)$, note: "each node's left subtree is scanned once along its right spine")

*The idea:* the preorder of a node is "me, then all of my left subtree, then all of my
right subtree". Sticking the right subtree onto the *end* of the left subtree's right
spine puts the three pieces in exactly that order.
]
]

#ex(30, tier: 3, asked: "Microsoft · pattern")[
Count the *good* nodes: a node is good if no node on the path from the root down to it
holds a strictly larger value.
Constraints: values may be negative, $n$ up to $10^5$.
Edge cases: empty tree; all values equal; strictly decreasing values.

#sol[
Carry the largest value seen so far *down* the tree. This is the mirror image of the
diameter pattern: information flows down, not up.

#code(lang: "js", caption: "count good nodes")[
```js
const goodGo = (r, best) => {
  if (r === null) return 0;
  const c = r.val >= best ? 1 : 0;
  const nb = Math.max(best, r.val);              // pass the new maximum down
  return c + goodGo(r.left, nb) + goodGo(r.right, nb);
};

const goodNodes = (r) => goodGo(r, -Infinity);
```
]

Ran it: on T, `8` — every node is good, because the values grow as you go down every
path. On `{5, 3, 8, 1, 4}`, `2` — only the root `5` and the node `8`. On `null`, `0`.

#complexity(time: $O(n)$, space: $O(h)$)

*The idea:* `best` is a *parameter*, not a closed-over variable. Each recursive call gets
its own copy, so a value picked up on the left branch cannot leak into the right branch.
That is the whole reason no "undo" line is needed here — compare it with Example 12, where
the shared `cur` array forced a `cur.pop()`.

This is the one place where JavaScript's copy-on-pass for numbers is exactly what you want.
It is the same behaviour that ruins `diameter` if you try to pass `best` as an argument —
the mechanism is identical, and only the intent differs. Know which one you need.

#ans[8 and 2]
]
]

#section[Dry run — diameter of T, node by node]

This traces the inner `go` from Example 22. It returns the *height in edges*
(`0` for `null`) and records `lh + rh` into `best`, the variable in the enclosing function.
Postorder: children finish first.

#code(lang: "js", caption: "the code being traced")[
```js
const diameter = (root) => {
  let best = 0;
  const go = (r) => {
    if (r === null) return 0;
    const lh = go(r.left);
    const rh = go(r.right);
    best = Math.max(best, lh + rh);
    return 1 + Math.max(lh, rh);
  };
  go(root);
  return best;
};
```
]

#table(columns: (auto, auto, auto, auto, auto, auto),
  [*step*], [*node*], [`lh`], [`rh`], [`lh+rh`], [`best` after / *returns*],
  [1],  [`4`], [0], [0], [0], [0 / returns 1],
  [2],  [`7`], [0], [0], [0], [0 / returns 1],
  [3],  [`8`], [0], [0], [0], [0 / returns 1],
  [4],  [`5`], [1], [1], [2], [*2* / returns 2],
  [5],  [`2`], [1], [2], [3], [*3* / returns 3],
  [6],  [`6`], [0], [0], [0], [3 / returns 1],
  [7],  [`3`], [0], [1], [1], [3 / returns 2],
  [8],  [`1`], [3], [2], [5], [*5* / returns 4],
)

`best` ends at *5*. The path with 5 edges is `7 → 5 → 2 → 1 → 3 → 6` — six nodes, five
edges. It does not touch the root's left-left branch at all, which is why you cannot just
add the two heights at the root and stop.

#formulas(title: "What the table teaches")[
1. *Leaves return 1, not 0.* The return value is `1 + Math.max(0, 0)`. The `0` for `null`
   is the height in *nodes* of an empty tree; the recorded `lh + rh` is in *edges*.
   Two different units in one function — this is exactly where people lose marks.
2. `best` only ever grows. It is updated at steps 4, 5 and 8. Every other step leaves it
   alone.
3. The winning value 5 is recorded at the root, but the *path* does not include the
   root's left child `4`. `best` at a node is about the *shape* below it, not about which
   nodes lie on the path.
]

#trap[
If you report the diameter in *nodes* instead of edges, T's answer is 6, not 5. Both are
defensible; the question decides. Say "I am counting edges" before you write code. If the
statement says "number of nodes on the longest path", return `best + 1` — but be careful:
for an empty tree that formula gives 1, which is wrong, so special-case `root === null`.
]

#section[Python versions — inorder, level order, diameter]

#code(lang: "python", caption: "the three signature traversals in Python")[
```python
from collections import deque

class Node:
    def __init__(self, val):
        self.val = val
        self.left = None
        self.right = None

def inorder(root):
    out = []
    def go(n):
        if n is None:
            return
        go(n.left)
        out.append(n.val)
        go(n.right)
    go(root)
    return out

def level_order(root):
    if root is None:
        return []
    out, q = [], deque([root])
    while q:
        level = []
        for _ in range(len(q)):         # freeze the size
            cur = q.popleft()
            level.append(cur.val)
            if cur.left:  q.append(cur.left)
            if cur.right: q.append(cur.right)
        out.append(level)
    return out

def diameter(root):
    best = 0
    def go(n):
        nonlocal best
        if n is None:
            return 0
        lh = go(n.left)
        rh = go(n.right)
        best = max(best, lh + rh)       # path bending here, in edges
        return 1 + max(lh, rh)
    go(root)
    return best
```
]

Ran all three on tree T:
`inorder` → `[4, 2, 7, 5, 8, 1, 3, 6]`,
`level_order` → `[[1], [2, 3], [4, 5, 6], [7, 8]]`,
`diameter` → `5`.
Empty tree: `[]`, `[]`, `0`. Single node: diameter `0`.

#trap[
`nonlocal best` is required. Without it, `best = max(...)` creates a brand-new *local*
variable inside `go` and the outer `best` never changes — the function silently returns
0.

JavaScript does *not* need a keyword here: `best = Math.max(...)` inside a nested arrow
function assigns to the outer `best` automatically, because `let best` is already in scope.
That is the one thing JavaScript makes easier than Python in this chapter. The JavaScript
mistake is the opposite one — declaring `let best` again *inside* `go`, which shadows the
outer variable and loses every update.

Also, `for _ in range(len(q))` reads the length *once*, before the loop body runs. That
is the Python equivalent of `const sz = q.size;`.
]

#section[Practice]

#practice(tier: 0, time: "25 min")[
1. Count the nodes that have exactly one child.
2. Given a value, return its level (root is level 1), or $-1$ if the value is absent.
3. Count the nodes at a given depth $d$ (root is depth 0).
4. Return the *sum of the leaf values* and the *maximum value*, in one traversal that
   visits each node once.
]

#practice(tier: 1, time: "45 min")[
5. Compute (sum of values at odd levels) minus (sum at even levels), root at level 1.
6. Given two trees, decide whether one is the mirror of the other.
7. Report the average value of each level.
8. Which level has the biggest sum? Return the level number (1-based), and the sum.
9. Print all the ancestors of a given value, nearest first.
]

#practice(tier: 2, time: "55 min")[
10. *Diagonal traversal:* group nodes by "diagonal", where moving to a right child stays
    on the same diagonal and moving to a left child starts the next one.
11. Sum the values of the leaves that sit at the *deepest* level.
12. Two nodes are *cousins* if they are at the same depth but have different parents.
    Given two values, decide whether they are cousins.
13. Replace every node's value by the sum of all values in its subtree, *not* counting
    itself. (A leaf becomes 0.)
]

#practice(tier: 3, time: "60 min")[
14. Count the subtrees whose total value equals a given target.
15. Find the length of the longest downward path whose values increase by exactly 1 at
    each step.
16. Compute the sum of the values in each *column* (the top-view column numbering), left
    to right.
]

#key[
*1.* `((r.left === null) !== (r.right === null)) ? 1 : 0` plus the two recursive calls.
The `!==` on two booleans is a clean "exactly one of them". Ran it on T: *1* (only
node `3`). Empty tree and single node both give *0*.

*2.* `const levelOf = (r, x, d) => ...`: return `d` if `r.val === x`; search left, and
if that returns $-1$ search right. Call it with `d = 1`. Ran it: value 7 → *4*,
value 1 → *1*, value 99 → *-1*.

*3.* `if (d === 0) return 1;` then `atDepth(r.left, d - 1) + atDepth(r.right, d - 1)`.
Ran it on T: depth 2 → *3*, depth 3 → *2*, depth 9 → *0*.

*4.* Return a two-element array `[leafSum, max]` and unpack it with destructuring:
`const [ls, lm] = go(r.left); const [rs, rm] = go(r.right);` then
`return [ls + rs, Math.max(r.val, lm, rm)];`, with `[0, -Infinity]` for `null` and
`[r.val, r.val]` at a leaf. Ran it: T → *25* and *8*; the all-negative tree `{-3,-2,-9}`
→ *-11* and *-2*; a single node `9` → *9* and *9*.
Neutral elements matter: `0` for the sum, `-Infinity` for the maximum. Returning an array
and destructuring it is JavaScript's answer to a `pair`, and it reads better.

*5.* Carry the level down and flip the sign: `(d % 2 === 1 ? r.val : -r.val)` plus the
two calls with `d + 1`. Ran it on T: $1 - 5 + 15 - 15 =$ *-4*.

*6.* Exactly `mirror(a, b)` from Example 10, but called on the two *roots*:
`mirror(rootA, rootB)`. Ran it: `{1,2,3}` against `{1,3,2}` → *true*;
`{1,2,3}` against `{1,2,3}` → *false*.

*7.* The level-order template with `let s = 0` and `out.push(s / sz);` — no cast needed,
because `/` in JavaScript is always real division. Ran it on T: *`[1, 2.5, 5, 7.5]`*.

*8.* Same template, keep a running level counter and the best sum seen. Ran it on T:
level *3*, sum *15*. Levels 3 and 4 tie at 15; `if (s > bs)` keeps the *first*, which is
level 3. If the question wants the last, use `>=`. Ask.

*9.* `const ancGo = (r, x, out) => ...`: return `true` at the match; if either child
returns `true`, push `r.val` and return `true`. Because the push happens while *unwinding*,
the list comes out nearest-first. Ran it: ancestors of 8 → *`[5, 2, 1]`*;
of the root 1 → *`[]`*; of a missing value → *`[]`*.

*10.* BFS carrying a diagonal id `k`: a right child keeps `k`, a left child gets `k + 1`.
Collect into a `Map` from `k` to an array, then read the keys back in sorted order with
`[...m.keys()].sort((a, b) => a - b)`. Ran it on T: *`[[1,3,6],[2,5,8],[4,7]]`*.

*11.* Track the deepest leaf depth seen and the running sum. When a deeper leaf appears,
*reset* the sum to that leaf's value; when an equally deep leaf appears, add to it.
Ran it on T: the deepest level is 4, holding leaves 7 and 8, so *15*.

*12.* Find each value's depth and parent pointer with one traversal each, then check
`depthA == depthB && parentA != parentB`. Ran it on T: (4, 6) → *true* (both at depth 2,
parents 2 and 3); (4, 5) → *false* (same parent); (7, 8) → *false* (same parent);
(1, 2) → *false* (different depths).

*13.* Postorder. Save the old value, recurse both sides to get `L` and `R`, set
`r.val = L + R`, and return `old + L + R` so the parent sees the *original* subtree
total. Ran it on T: the preorder of the result is
*`[35, 24, 0, 15, 0, 0, 6, 0]`* — the root becomes $2+3+4+5+6+7+8 = 35$ and every leaf
becomes 0.

*14.* Postorder again: return the subtree sum from the inner function, and increment a
`count` in the enclosing scope whenever that sum equals the target. Ran it on T: target 9
→ *1* (the subtree rooted at node 3, which is $3 + 6$); target 36 → *1* (the whole tree);
target 15 → *0*.

*15.* Return the longest increasing-by-one chain that *starts at this node*, and record
the best anywhere. `let len = 1`, and if `r.left && r.left.val === r.val + 1` then
`len = Math.max(len, 1 + L)`, same for the right. Ran it: on the chain `1 → 2 → 3 → 4` the
answer is *4*; on T it is *2* (just `1 → 2`); a single node gives *1*; an empty tree
gives *0*.

*16.* The vertical-order BFS, but add into a `Map` from column to a running total instead
of pushing, and sort the keys numerically at the end.
Ran it on T: *`[4, 9, 6, 11, 6]`* — column $-2$ holds `4`; column $-1$ holds `2` and `7`,
summing to 9; column 0 holds `1` and `5`, summing to 6; column $+1$ holds `3` and `8`,
summing to 11; column $+2$ holds `6`.
]

#revision[
#subsection[The two templates]

```js
const { Deque } = require('./toolkit.js');   // JS Toolkit appendix

// 1. depth first - solve left, solve right, combine
const solve = (r) => {
  if (r === null) return neutral;
  const L = solve(r.left);
  const R = solve(r.right);
  return combine(L, R, r.val);
};

// 2. breadth first - one level per outer turn
const q = new Deque(); q.push(root);
while (q.size) {
  const sz = q.size;                    // FREEZE the size
  for (let i = 0; i < sz; i++) {
    const c = q.shift();
    /* use c, and i === 0 / i === sz - 1 for first / last on the level */
    if (c.left)  q.push(c.left);
    if (c.right) q.push(c.right);
  }
}

// 3. return one thing, record another - the closure replaces C++'s int &best
const solveTwoWays = (root) => {
  let best = 0;                           // declared OUT here, assigned in there
  const go = (r) => {
    if (r === null) return 0;
    const L = go(r.left), R = go(r.right);
    best = Math.max(best, L + R);         // RECORD the bend
    return 1 + Math.max(L, R);            // RETURN the arm
  };
  go(root);
  return best;
};
```

#subsection[When to use which]

#table(columns: (auto, 1fr),
  [*Question mentions*], [*Reach for*],
  [height, depth, sum, count, path to a leaf], [plain DFS recursion],
  [level, "by level", zigzag, views, width], [BFS with a frozen level size],
  [column, vertical, top / bottom view], [BFS carrying a column number + a `Map`, then sort the keys],
  [diameter, max path sum, longest chain], [return an arm, record the bend in a closed-over variable],
  [distance from a node, burning, "upward"], [parent map + BFS from the target],
  [$O(1)$ space traversal, flatten], [Morris threading],
  [rebuild from traversals], [preorder gives roots, inorder splits — keep one shared cursor in the enclosing scope],
)

#subsection[Complexity table]

#table(columns: (auto, auto, auto),
  [*Task*], [*Time*], [*Space*],
  [any single traversal], [$O(n)$], [$O(h)$],
  [level order / any view], [$O(n)$], [$O(w)$],
  [top / bottom / vertical with a `Map` + sort], [$O(n log n)$], [$O(n)$],
  [balanced check, naive], [$O(n^2)$], [$O(h)$],
  [balanced check, one pass], [$O(n)$], [$O(h)$],
  [diameter, naive], [$O(n^2)$], [$O(h)$],
  [diameter, one pass], [$O(n)$], [$O(h)$],
  [LCA], [$O(n)$], [$O(h)$],
  [build from preorder + inorder], [$O(n)$], [$O(n)$],
  [serialize / deserialize], [$O(n)$], [$O(n)$],
  [distance-k / burning], [$O(n)$], [$O(n)$],
  [Morris inorder, flatten], [$O(n)$], [$O(1)$],
)

#subsection[Values to remember for tree T]

#table(columns: (auto, auto, auto, auto),
  [preorder], [`1 2 4 5 7 8 3 6`], [right view], [`1 3 6 8`],
  [inorder], [`4 2 7 5 8 1 3 6`], [left view], [`1 2 4 7`],
  [postorder], [`4 7 8 5 2 6 3 1`], [top view], [`4 2 1 3 6`],
  [height], [4], [bottom view], [`4 7 5 8 6`],
  [diameter (edges)], [5], [boundary], [`1 2 4 7 8 6 3`],
  [max path sum], [25], [max width], [4],
)

#subsection[Top traps]

1. *Not freezing `q.size`* before the inner level loop. On the toolkit `Deque` it is a
   getter, so it silently re-reads.
2. *`array.shift()` in a BFS.* It is $O(n)$ — measured 2726 ms against the `Deque`'s 10 ms
   on 200000 items. Use the toolkit `Deque`.
3. *`arr.sort()` with no comparator.* It sorts as text:
   `[-2, -1, 0, 1, 2].sort()` gives `[-1, -2, 0, 1, 2]`. Always `(a, b) => a - b`, and
   `(a, b) => a[0] - b[0] || a[1] - b[1]` for two keys.
4. *No `TreeMap`.* Columns come out of a `Map` in insertion order; sort the keys yourself.
5. *A plain object where the key is a node.* Every object key stringifies to
   `"[object Object]"` and they all collide. Use `Map` and `Set`.
6. *Height in nodes versus edges.* Say which one you mean, every time.
7. *`minDepth` without the one-child guard* — a `null` child is not a leaf.
8. *Neutral element wrong:* `0` for a max on a negative tree, `0` for `best` in max path
   sum. Use `-Infinity`.
9. *Inverting in place with overwritten references.* Compute both children first, or use
   the destructuring swap.
10. *Recursion depth.* Node dies at roughly 12500 frames with
    `RangeError: Maximum call stack size exceeded`. A $10^5$-node chain needs the
    explicit-stack version.
11. *`new Array(k)` without `.fill(...)`* leaves holes, and `a[0] === null` is `false`.
12. *Pushing the live path array* instead of `[...cur]` in the backtracking collector.
13. *Index precision in max width.* Past $2^53$ a raw index is no longer exact — re-base
    each level with `raw - first`.
14. *Passing the preorder cursor as an argument* when rebuilding a tree. It must live in
    the enclosing scope.
15. *DFS for the top view.* It must be BFS. *Boundary double-printing leaves* — the edges
    skip leaves.
16. *LCA when a value is missing* returns the other value's node, not `null`.
17. *Python: forgetting `nonlocal`*, so the recorded best never updates. JavaScript needs
    no keyword — but re-declaring `let best` inside the inner function shadows it, with
    exactly the same symptom.
]

]
