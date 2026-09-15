#import "../../shared/lib/style.typ": *

#chapter(
  num: 13,
  title: "Binary Search Trees & Balanced Trees",
  tagline: "One rule — smaller on the left, bigger on the right — turns a tree into a sorted list you can walk, search and edit in O(h) time.",
)[

#section[Pattern in one page]

#formulas(title: "The one rule")[
A binary tree is a *binary search tree* (BST) when, for *every* node `x`:

- every key in the *left* subtree of `x` is *smaller* than `x.val`, and
- every key in the *right* subtree of `x` is *bigger* than `x.val`.

The rule is about the whole subtree, not just the two children. That single sentence
gives you three gifts:

+ *Search is a decision.* At each node you go left or right. You never look at both sides.
+ *Inorder walk is sorted.* Left, node, right gives the keys in increasing order.
+ *Edits keep the order.* Insert and delete cost the same as a search.

Everything in this chapter is one of those three gifts, reused.
]

#diagram(height: 4.2cm, caption: "A BST. Read the leaves left to right: 20 30 40 50 60 70 80 — already sorted.")[
  #dnode(6.5cm, 0cm, 1.3cm, 0.7cm, "50")
  #dnode(3.0cm, 1.4cm, 1.3cm, 0.7cm, "30")
  #dnode(10.0cm, 1.4cm, 1.3cm, 0.7cm, "70")
  #dnode(1.0cm, 2.8cm, 1.3cm, 0.7cm, "20")
  #dnode(4.6cm, 2.8cm, 1.3cm, 0.7cm, "40")
  #dnode(8.4cm, 2.8cm, 1.3cm, 0.7cm, "60")
  #dnode(12.0cm, 2.8cm, 1.3cm, 0.7cm, "80")
  #darrow(7.15cm, 0.7cm, 3.65cm, 1.4cm)
  #darrow(7.15cm, 0.7cm, 10.65cm, 1.4cm)
  #darrow(3.65cm, 2.1cm, 1.65cm, 2.8cm)
  #darrow(3.65cm, 2.1cm, 5.25cm, 2.8cm)
  #darrow(10.65cm, 2.1cm, 9.05cm, 2.8cm)
  #darrow(10.65cm, 2.1cm, 12.65cm, 2.8cm)
]

#subsection[The template you will write again and again]

#code(lang: "js", caption: "The whole BST toolkit — node, search, insert, delete")[
```js
class Node {
  constructor(val) { this.val = val; this.left = null; this.right = null; }
}

// search — no recursion needed, it is just a walk
const bstSearch = (root, key) => {
  while (root !== null) {
    if (key === root.val) return root;
    root = key < root.val ? root.left : root.right;
  }
  return null;
};

// insert — falls off the bottom, then hangs a new node there
const bstInsert = (root, key) => {
  if (root === null) return new Node(key);
  if (key < root.val) root.left = bstInsert(root.left, key);
  else if (key > root.val) root.right = bstInsert(root.right, key);
  return root;                     // equal key: ignore, keep the tree a set
};

const minNode = (t) => { while (t.left !== null) t = t.left; return t; };

// delete — three shapes: leaf, one child, two children
const bstErase = (root, key) => {
  if (root === null) return null;
  if (key < root.val) root.left = bstErase(root.left, key);
  else if (key > root.val) root.right = bstErase(root.right, key);
  else {
    if (root.left === null) return root.right;     // leaf or right child only
    if (root.right === null) return root.left;     // left child only
    const s = minNode(root.right);                 // smallest key on the right
    root.val = s.val;                              // copy it up
    root.right = bstErase(root.right, s.val);      // then delete the copy
  }
  return root;
};

const inorder = (r, out = []) => {
  if (r === null) return out;
  inorder(r.left, out); out.push(r.val); inorder(r.right, out);
  return out;
};
```
]

Running it on the tree above:

#code(lang: "text", caption: "Output — this is the real program output, not a guess")[
```text
inorder = [20 30 40 50 60 70 80]
search 40 -> found
search 45 -> null
search in empty -> null
duplicates {5,5,5} -> [5]
erase leaf 20    -> [30 40 50 60 70 80]
erase 1-child 30 -> [40 50 60 70 80]
erase 2-child 50 -> [40 60 70 80]
erase missing    -> [40 60 70 80]
erase only node  -> empty
```
]

#trap[
*Node's recursion depth is about 12500 frames.* Measured, not guessed: a plain recursive
function in Node crashes with `RangeError: Maximum call stack size exceeded` at roughly
12500 nested calls. `bstInsert` recurses once per level, so inserting the keys
1, 2, 3, ..., 100000 in sorted order — which builds a chain — *crashes*. It does not run
slowly; it dies. Two fixes, both in this chapter: keep the tree short (Example 28), or
rewrite the walk with an explicit stack (Example 21, approach 3). Any recursion that can
go $10^4$ deep needs one of the two.
]

#subsection[Why every cost is written with h, not n]

`h` is the *height* of the tree — the longest root-to-leaf path.

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*Shape*], [*Height h*], [*Search cost*],
  [balanced (each level full)], [$approx log_2 n$], [$O(log n)$],
  [random insert order], [$approx 1.39 log_2 n$], [$O(log n)$],
  [sorted insert order (1,2,3,...)], [$n$], [$O(n)$ — a linked list],
)

#trap[
A plain BST is *not* fast. It is fast *only if it stays short*. Insert
1, 2, 3, ..., 1000 in that order and you get a chain of 1000 nodes. Every search then
scans all 1000. This is why balanced trees exist. And JavaScript gives you *no* balanced
tree in the standard library, so in JS you must either keep an array sorted or balance the
tree yourself — Example 28 shows both ways.
]

#subsection[BST vs the other two containers]

#table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, center),
  [*Operation*], [*sorted array*], [*`Map` / `Set`*], [*balanced BST (hand-written)*],
  [find a key], [$O(log n)$], [$O(1)$ average], [$O(log n)$],
  [insert / delete], [$O(n)$], [$O(1)$ average], [$O(log n)$],
  [smallest / biggest], [$O(1)$], [$O(n)$], [$O(log n)$],
  [next key after x], [$O(log n)$], [$O(n)$], [$O(log n)$],
  [list keys in order], [$O(n)$], [$O(n log n)$], [$O(n)$],
)

#trick[
Reach for a BST when you need *order* and *change* at the same time. If the data never
changes, sort it once. If you never need order, use a `Map` or a `Set`. The BST is for the
middle case: "keep me sorted while I keep inserting and deleting."
]

#subsection[The JavaScript shortcut — and the one that does not exist]

Other languages hand you a balanced BST: C++ has an ordered `set`, Java has `TreeMap`,
Python has `sortedcontainers`. *JavaScript has nothing like it.* A JS `Set` is a hash set: it has
no order, no "smallest key", no "next key after x".

So the JS stand-in is a *sorted array plus binary search*. The book's toolkit has the two
search helpers (see the JS Toolkit appendix); you write the require line once per file:

#code(lang: "js", caption: "The toolkit import used through this chapter")[
```js
const { lowerBound, upperBound } = require('./toolkit.js');
```
]

#code(lang: "js", caption: "A sorted array gives floor, ceil and successor — reads are cheap, writes are not")[
```js
const sortedSetDemo = () => {
  const s = [40, 10, 70, 25, 90].sort((a, b) => a - b);  // (a,b)=>a-b ALWAYS
  let i = lowerBound(s, 30);                 // first index with s[i] >= 30
  console.log('ceil(30) =', s[i]);
  i = upperBound(s, 70);                     // first index with s[i] > 70
  console.log('successor(70) =', s[i]);
  const p = lowerBound(s, 26);               // floor(26): step one back
  console.log('floor(26) =', p > 0 ? s[p - 1] : 'none');
  s.splice(s.indexOf(25), 1);                // erase 25 — O(n), the array's price
  console.log('after erase 25:', s.join(' '));
};
```
]

#code(lang: "text", caption: "Output")[
```text
ceil(30) = 40
successor(70) = 90
floor(26) = 25
after erase 25: 10 40 70 90
```
]

#trap[
*`arr.sort()` is lexicographic.* It turns every element into a string first, so
`[10, 9, 1].sort()` gives `[1, 10, 9]` — 9 last, because `"9" > "10"` as text. Numbers
*always* need `arr.sort((a, b) => a - b)`. This one line costs more interview marks than
any other JS mistake, and a sorted-array BST stand-in is built on it.
]

#trap[
`lowerBound(s, x)` can return `0`, meaning "every key is `>= x`", so there is *no* floor.
`s[p - 1]` is then `s[-1]`, which in JS is `undefined` rather than a crash — the bug
travels silently into your answer. Always test `p > 0` first. The same goes the other way:
`lowerBound` can return `s.length`, and `s[s.length]` is `undefined` too.
]

#trap[
The sorted array is $O(n)$ to *edit*. `splice` shifts every later element. For $10^5$ keys
with $10^5$ inserts that is $10^10$ moves. Reads are $O(log n)$, writes are $O(n)$ — if
the problem inserts and deletes as often as it searches, write the balanced tree from
Example 28 instead.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Which of these is a valid BST?

(A) root 10, left child 5, right child 15 \
(B) root 10, left child 15, right child 5 \
(C) root 10, left child 5, right child 15, and 15 has left child 6
]
#sol[
- (A) 5 < 10 < 15. Valid.
- (B) 15 is on the left of 10 but 15 > 10. Invalid.
- (C) Look at 6. It sits in the *right subtree* of 10, so it must be bigger than 10.
  It is not. Invalid — even though 6 < 15 is fine for its parent.
]
#ans[Only (A)]

#trap[
Case (C) is the trap that kills most "validate BST" attempts. Checking only
`left < node < right` for each parent and child is *not enough*. The rule covers the
whole subtree.
]

#ex(2, tier: 0, asked: "warm-up")[
Walk this BST in inorder and write the output.
Tree: root 8; 8.left = 3; 8.right = 10; 3.left = 1; 3.right = 6.

*Limits* $n <= 10^5$ · *Target* $O(n)$ · *Edge cases* empty tree; a tree with one node.
]
#sol[
Inorder = left, node, right. Start at 8.

+ Go left to 3. Go left to 1. 1 has no left, so print *1*. 1 has no right.
+ Back at 3: print *3*. Go right to 6. Print *6*.
+ Back at 8: print *8*. Go right to 10. Print *10*.
]
#ans[1 3 6 8 10 — sorted, as promised]

#ex(3, tier: 0, asked: "warm-up")[
Insert 4, 2, 6, 1, 3 into an empty BST in that order. Draw the shape. Then insert 2 again.
]
#sol[
+ 4 becomes the root.
+ 2 < 4, go left, empty, place 2.
+ 6 > 4, go right, empty, place 6.
+ 1 < 4 go left; 1 < 2 go left, empty, place 1.
+ 3 < 4 go left; 3 > 2 go right, empty, place 3.
+ Insert 2 again: 2 < 4 go left; we find 2. It is already there. The template does nothing.
]
#ans[Root 4; left 2 (children 1 and 3); right 6. The second 2 changes nothing.]

#ex(4, tier: 0, asked: "warm-up")[
In the tree from Example 3, what is the smallest key? The biggest?
]
#sol[
The smallest key has nothing smaller than it, so it has no left child. Walk left until
you cannot: 4 → 2 → 1. The biggest: walk right until you cannot: 4 → 6.
]
#ans[smallest 1, biggest 6]

#code(lang: "js", caption: "Two one-line walks")[
```js
const minNode = (t) => { while (t.left  !== null) t = t.left;  return t; };
const maxNode = (t) => { while (t.right !== null) t = t.right; return t; };
```
]

#ex(5, tier: 0, asked: "warm-up")[
A BST holds 20, 30, 40, 50, 60, 70, 80. How many nodes does `bstSearch` visit when
looking for 60, if the tree is the balanced one from page 1? What if the same keys were
inserted in sorted order instead?
]
#sol[
*Balanced tree.* 50 → 70 → 60. That is 3 nodes.

*Sorted insert order.* The tree becomes 20 → 30 → 40 → 50 → 60, a chain. Searching 60
visits 20, 30, 40, 50, 60 = 5 nodes. For 80 it would visit all 7.
]
#ans[3 visits when balanced, 5 when it is a chain]

#ex(6, tier: 0, asked: "warm-up")[
Delete 30 from: root 50; 50.left = 30; 50.right = 70; 30.left = 20; 30.right = 40.

*Limits* $n <= 10^5$ · *Target* $O(h)$ · *Edge cases* deleting the root; deleting a key
that is not present.
]
#sol[
Node 30 has two children, so we cannot just unhook it. The template does this:

+ Find the *smallest key in the right subtree* of 30. The right subtree is just 40, so
  that key is 40. (This is 30's inorder successor.)
+ Copy 40 into the node: the node now holds 40.
+ Delete 40 from the right subtree. 40 is a leaf there, so it is unhooked.

Result: root 50; 50.left = 40; 40.left = 20; 50.right = 70.
]
#ans[Inorder afterwards: 20 40 50 70]

#note[
Why the *smallest of the right* (or, equally, the biggest of the left)? Because that key
is the only one that can sit between "everything on the left" and "everything else on the
right" without breaking the rule.
]

#section[Tier 1 — the standard BST toolkit]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
*Validate a BST.* Given the root of a binary tree, return true if it is a BST.

*Limits* $n <= 10^5$, keys up to `Number.MAX_SAFE_INTEGER` $= 2^53 - 1$ ·
*Target* $O(n)$ time · *Edge cases* empty tree (true); a node whose key equals its
parent's key (false); keys at the very edge of the safe-integer range.
]

#approach(1, "Collect the inorder walk, then check it is sorted", verdict: "O(n) time, O(n) extra memory")

#code(lang: "js", caption: "Brute force — write the keys out and look at them")[
```js
const inorderCollect = (r, out = []) => {
  if (r === null) return out;
  inorderCollect(r.left, out);
  out.push(r.val);
  inorderCollect(r.right, out);
  return out;
};

const isBstBrute = (root) => {
  const a = inorderCollect(root);
  for (let i = 1; i < a.length; i++)
    if (a[i] <= a[i - 1]) return false;   // <= rejects duplicate keys too
  return true;
};
```
]
#complexity(time: $O(n)$, space: $O(n)$, note: "Correct, and a fine first answer. The interviewer will now ask you to drop the array.")

#approach(2, "Same walk, but remember only the previous key", verdict: "O(n) time, O(h) memory")

#code(lang: "js", caption: "You never need the whole array — only the last key printed")[
```js
const isBstPrev = (root) => {
  let prev = -Infinity;                  // -Infinity is below every number
  const walk = (r) => {
    if (r === null) return true;
    if (!walk(r.left)) return false;
    if (r.val <= prev) return false;
    prev = r.val;
    return walk(r.right);
  };
  return walk(root);
};
```
]
#complexity(time: $O(n)$, space: $O(h)$, note: "O(h) is the recursion stack. For a balanced tree that is O(log n).")

#approach(3, "Push a legal window down the tree", verdict: "O(n) time, O(h) memory — the answer to give")

#code(lang: "js", caption: "Every node inherits a window (lo, hi) it must fit inside")[
```js
const boundCheck = (r, lo, hi) => {
  if (r === null) return true;
  if (r.val <= lo || r.val >= hi) return false;
  return boundCheck(r.left, lo, r.val)       // left side: hi shrinks to r.val
      && boundCheck(r.right, r.val, hi);     // right side: lo grows to r.val
};

const isBstBounds = (root) => boundCheck(root, -Infinity, Infinity);
```
]
#complexity(time: $O(n)$, space: $O(h)$, note: "Stops early on the first bad node, which the inorder version cannot always do.")

#code(lang: "text", caption: "Output of all three on the same inputs")[
```text
good tree : true true true
bad tree  : false false false   (root 10, right 15, and 15.left = 6)
huge keys (9007199254740991 root, -9007199254740991 left): true true
empty tree: true
equal keys (5 under 5): false false false
```
]

*The idea that unlocked it:* the BST rule is not local, it is a *range*. Carrying the
range down turns "check the whole subtree" into "check one number".

#trap[
Start the window at `-Infinity` and `Infinity`, never at
`Number.MIN_SAFE_INTEGER` / `Number.MAX_SAFE_INTEGER`. A key sitting exactly on the safe
limit would then fail its own test. `-Infinity` is below every number and `Infinity` is
above every number, so the window can never be too tight. This is one place where JS is
*easier* than a fixed-width language — there is no "one below the minimum" problem.
]

#trap[
Keys past $2^53 - 1$ are not safe. JS numbers are doubles, so `9007199254740993` is
stored as `9007199254740992` — two different keys become equal and the BST silently loses
one. If the problem allows 64-bit keys, store `BigInt` values and compare them with the
same `<` and `>` (they work), but never mix a `BigInt` and a `Number` in arithmetic.
]

#ex(8, tier: 1, asked: "Infosys · pattern")[
*Floor and ceil.* For a query `x`, find the biggest key `<= x` (floor) and the smallest
key `>= x` (ceil).

*Limits* $n <= 10^5$, up to $10^5$ queries · *Target* $O(h)$ per query ·
*Edge cases* `x` smaller than every key (no floor); `x` bigger than every key (no ceil).
]

#approach(1, "Inorder into an array, then binary search", verdict: "O(n) once, then O(log n) per query — good if the tree never changes")
#approach(2, "Walk down and keep the best candidate", verdict: "O(h), no extra memory — the answer")

#sol[
Walking down, every time you move *right* you have just passed a key that is `<= x`.
That key is the best floor found so far. Symmetrically, every time you move *left* you
pass a key that is `>= x`, the best ceil so far.
]

#code(lang: "js", caption: "Floor and ceil in one downward walk")[
```js
const bstFloor = (r, x) => {            // biggest value <= x, or null if none
  let best = null;
  while (r !== null) {
    if (r.val === x) return x;
    if (r.val < x) { best = r.val; r = r.right; }   // r.val is a candidate
    else           { r = r.left; }
  }
  return best;
};

const bstCeil = (r, x) => {             // smallest value >= x, or null if none
  let best = null;
  while (r !== null) {
    if (r.val === x) return x;
    if (r.val > x) { best = r.val; r = r.left; }    // r.val is a candidate
    else           { r = r.right; }
  }
  return best;
};
```
]
#complexity(time: $O(h)$, space: $O(1)$)

#code(lang: "text", caption: "Output on the tree {20, 8, 22, 4, 12, 10, 14}")[
```text
x=5   floor=4    ceil=8
x=8   floor=8    ceil=8
x=21  floor=20   ceil=22
x=3   floor=none ceil=4
x=100 floor=22   ceil=none
```
]

#ex(9, tier: 1, asked: "Wipro · pattern")[
*Kth smallest key.* Return the k-th smallest key (k is 1-based).

*Limits* $n <= 10^5$, $1 <= k <= n$ · *Target* $O(h + k)$ ·
*Edge cases* k = 1; k bigger than the number of nodes.
]

#approach(1, "Full inorder into an array, take a[k-1]", verdict: "O(n) time and O(n) memory")
#approach(2, "Inorder that stops the moment it has counted k", verdict: "O(h + k) time, O(h) memory")

#code(lang: "js", caption: "Counting walk — quits as soon as it has seen k keys")[
```js
const kthSmallest = (root, k) => {
  let seen = 0, out = null;               // null means "k was too big"
  const walk = (r) => {
    if (r === null || seen >= k) return;
    walk(r.left);
    if (seen >= k) return;
    seen++;
    if (seen === k) { out = r.val; return; }
    walk(r.right);
  };
  walk(root);
  return out;
};
```
]
#complexity(time: $O(h + k)$, space: $O(h)$)

#approach(3, "Store a subtree size in every node", verdict: "O(h) per query — pay once at insert time")

#code(lang: "js", caption: "Each node knows how many nodes are under it")[
```js
class SNode {
  constructor(val) { this.val = val; this.sz = 1; this.left = null; this.right = null; }
}

const sizeOf = (t) => (t === null ? 0 : t.sz);

const sInsert = (r, v) => {
  if (r === null) return new SNode(v);
  if (v < r.val) r.left = sInsert(r.left, v);
  else if (v > r.val) r.right = sInsert(r.right, v);
  else return r;
  r.sz = 1 + sizeOf(r.left) + sizeOf(r.right);
  return r;
};

const sKth = (r, k) => {                   // O(h), no walking of k nodes
  while (r !== null) {
    const leftCount = sizeOf(r.left);
    if (k === leftCount + 1) return r.val;        // this node is the k-th
    if (k <= leftCount) r = r.left;               // answer is on the left
    else { k -= leftCount + 1; r = r.right; }     // skip left side plus this node
  }
  return null;
};
```
]
#complexity(time: [$O(h)$ per query], space: $O(n)$, note: "One extra number per node. Insert still O(h).")

#code(lang: "text", caption: "Output on {50,30,70,20,40,60,80}")[
```text
counting walk : k=1 -> 20,  k=4 -> 50,  k=7 -> 80
augmented tree: k=1 -> 20,  k=4 -> 50,  k=7 -> 80,  k=8 -> none
```
]

*The idea that unlocked it:* "how many keys are smaller than me" is a number you can
*store*, not a walk you must repeat. That single extra field turns $O(k)$ into $O(h)$ and
is the seed of every order-statistics tree.

#ex(10, tier: 1, asked: "Capgemini · pattern")[
*Lowest common ancestor in a BST.* Given two keys `a` and `b` that both exist in the
tree, find their lowest common ancestor.

*Limits* $n <= 10^5$ · *Target* $O(h)$, no extra memory ·
*Edge cases* a = b (answer is that node); one key is an ancestor of the other.
]
#approach(1, "Find the root-to-key path for both keys, then compare them", verdict: "O(h) time, but O(h) memory for the two stored paths")
#approach(2, "Let the keys themselves decide the direction", verdict: "O(h) time, O(1) memory — the answer")

#sol[
In a general binary tree LCA needs a full search. In a BST you can *read the answer off
the keys*. Start at the root:

- If both `a` and `b` are smaller than the current node, the answer is on the left.
- If both are bigger, the answer is on the right.
- Otherwise the paths to `a` and `b` split right here. This node is the LCA.
]

#code(lang: "js", caption: "LCA — the first node that sits between a and b")[
```js
const lcaBST = (r, a, b) => {
  if (a > b) [a, b] = [b, a];             // destructuring swap; now a <= b
  while (r !== null) {
    if (b < r.val) r = r.left;            // both smaller
    else if (a > r.val) r = r.right;      // both bigger
    else return r;                        // a <= r.val <= b : split point
  }
  return null;
};
```
]
#complexity(time: $O(h)$, space: $O(1)$)

#code(lang: "text", caption: "Output on {50,30,70,20,40,60,80}")[
```text
lca(20,40)=30   lca(20,80)=50   lca(60,80)=70   lca(30,30)=30
```
]

#ex(11, tier: 1, asked: "Accenture · pattern")[
*Inorder successor and predecessor.* For a key `x` (which may or may not be in the tree),
find the smallest key strictly bigger than `x`, and the biggest key strictly smaller.

*Limits* $n <= 10^5$ · *Target* $O(h)$ · *Edge cases* `x` is the biggest key
(no successor); `x` is not in the tree at all.
]
#approach(1, "Inorder into an array, then scan it for x", verdict: "O(n) time and O(n) memory, and you pay it on every query")
#approach(2, "One walk down, keeping the best candidate", verdict: "O(h) time, O(1) memory")

#sol[
This is floor and ceil with the equality removed. Compare with `>` instead of `>=`.
]

#code(lang: "js", caption: "Successor and predecessor")[
```js
const successorOf = (r, x) => {          // smallest key > x, null if none
  let best = null;
  while (r !== null) {
    if (r.val > x) { best = r.val; r = r.left; }
    else           { r = r.right; }
  }
  return best;
};

const predecessorOf = (r, x) => {        // biggest key < x, null if none
  let best = null;
  while (r !== null) {
    if (r.val < x) { best = r.val; r = r.right; }
    else           { r = r.left; }
  }
  return best;
};
```
]
#complexity(time: $O(h)$, space: $O(1)$)

#code(lang: "text", caption: "Output")[
```text
succ(40)=50   succ(80)=none   pred(50)=40   pred(20)=none
```
]

#trick[
Notice the pattern: *floor, ceil, successor, predecessor, LCA and search are the same
five-line walk* with one comparison changed. Learn the walk, not four functions.
]

#ex(12, tier: 1, asked: "Cognizant · pattern")[
*Range sum.* Add up every key in `[lo, hi]`.

*Limits* $n <= 10^5$, keys up to $10^9$ · *Target* better than $O(n)$ when the range is
small · *Edge cases* the range holds no key (answer 0); the range holds every key —
check the total against $2^53 - 1$.
]

#approach(1, "Visit every node, add it if it is in range", verdict: "O(n) — correct but wasteful")
#approach(2, "Prune: never enter a subtree that cannot hold a key in range", verdict: "O(h + m) where m is the number of keys inside")

#code(lang: "js", caption: "Pruned range sum")[
```js
const rangeSum = (r, lo, hi) => {
  if (r === null) return 0;
  if (r.val < lo) return rangeSum(r.right, lo, hi);   // left side all too small
  if (r.val > hi) return rangeSum(r.left, lo, hi);    // right side all too big
  return r.val + rangeSum(r.left, lo, hi) + rangeSum(r.right, lo, hi);
};
```
]
#complexity(time: $O(h + m)$, space: $O(h)$, note: "m = how many keys land inside [lo, hi].")

#code(lang: "text", caption: "Output — note the overflow test")[
```text
sum[30,60]  = 180
sum[0,100]  = 350
sum[81,99]  = 0
keys 300000000 ... 1800000000, sum over everything = 6300000000
```
]

#trap[
`6300000000` is far past the 32-bit limit of about $2.1 times 10^9$ — in C++ or Java this
is where you would reach for a 64-bit integer. *JS needs no cast here*: a number is a double and
stays exact up to $2^53 - 1 approx 9 times 10^15$, so a sum of $10^5$ keys of size $10^9$
($10^14$) is still exact.

The JS limit is higher, not absent. Past $2^53 - 1$ the additions start rounding and the
answer is quietly wrong — `9007199254740992 + 1` gives `9007199254740992`. When a sum can
reach that far, add with `BigInt`: `0n + BigInt(r.val)`, and print with `.toString()`.
]

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
*Sorted array to a height-balanced BST.* Given a sorted array with no duplicates, build a
BST whose left and right heights differ by at most 1 at every node.

*Limits* $n <= 10^5$ · *Target* $O(n)$ · *Edge cases* empty array; one element.
]
#approach(1, "Insert the keys left to right", verdict: "O(n^2), and it builds a chain — the worst possible shape")
#approach(2, "Put the middle element at the root, then repeat on each half", verdict: "O(n), and the height is as small as it can be")

#sol[
If you want both halves to be the same height, put the *middle* element at the root. Then
do the same to each half. That is the whole algorithm.
]

#code(lang: "js", caption: "Middle element becomes the root, recursively")[
```js
const buildBalanced = (a, lo, hi) => {
  if (lo > hi) return null;
  const mid = lo + Math.floor((hi - lo) / 2);   // safe midpoint, see the trap
  const root = new Node(a[mid]);
  root.left  = buildBalanced(a, lo, mid - 1);
  root.right = buildBalanced(a, mid + 1, hi);
  return root;
};

const sortedToBST = (a) => buildBalanced(a, 0, a.length - 1);
```
]
#complexity(time: $O(n)$, space: $O(log n)$, note: "Each element is used exactly once; the space is the recursion stack.")

#code(lang: "text", caption: "Output")[
```text
input [1 2 3 4 5 6 7] -> inorder [1 2 3 4 5 6 7], root 4, height 3
empty input -> null
one element [9] -> root 9, height 1
```
]

#trap[
Do not write `const mid = (lo + hi) >> 1`. It looks clever and it is the standard trick in
C++, but *JS bitwise operators truncate to 32 bits*. With `lo = 2000000000` and
`hi = 2100000000`, `(lo + hi) >> 1` returns `-97483648` — a negative index. The safe form
is `lo + Math.floor((hi - lo) / 2)`, which never leaves the double range. Build the habit
now; every binary search in this book uses it.
]

#ex(14, tier: 1, asked: "Infosys · pattern")[
*Balance an unbalanced BST.* You are handed a BST that has degenerated into a chain.
Rebuild it so its height is minimal, keeping the same keys.

*Limits* $n <= 10^5$ · *Target* $O(n)$ · *Edge cases* already balanced; one node.
]
#approach(1, "Rotate repeatedly until it looks balanced", verdict: "hard to write, harder to prove correct — do not start here")
#approach(2, "Flatten to a sorted array, then rebuild from the middle", verdict: "O(n) time, O(n) memory — the answer")

#sol[
You already have both pieces. Inorder gives you the sorted array; Example 13 turns a
sorted array into a balanced tree. Glue them.
]

#code(lang: "js", caption: "Two functions you already wrote")[
```js
const balanceBST = (root) => sortedToBST(inorderCollect(root));   // sorted, because it is a BST
```
]
#complexity(time: $O(n)$, space: $O(n)$)

#code(lang: "text", caption: "Output — insert 1..7 in order, then rebuild")[
```text
skewed height 7 -> balanced height 3
```
]

#ex(15, tier: 1, asked: "TCS NQT · pattern")[
*Trim a BST to a range.* Delete every key outside `[lo, hi]`, keeping the remaining keys
a valid BST.

*Limits* $n <= 10^5$ · *Target* $O(n)$ · *Edge cases* every key is outside the range
(result is empty); every key is inside (tree unchanged).
]
#approach(1, "Collect every out-of-range key, then call bstErase on each one", verdict: "O(n h), and each delete reshuffles the tree again")
#approach(2, "One recursive pass that returns the replacement for each node", verdict: "O(n), every node touched once")

#sol[
If `r.val < lo`, then `r` *and its whole left subtree* are too small. The answer is
whatever trimming the right subtree gives. Mirror it for the other side.
]

#code(lang: "js", caption: "Trim — return the replacement for this node")[
```js
const trimBST = (r, lo, hi) => {
  if (r === null) return null;
  if (r.val < lo) return trimBST(r.right, lo, hi);
  if (r.val > hi) return trimBST(r.left, lo, hi);
  r.left  = trimBST(r.left, lo, hi);
  r.right = trimBST(r.right, lo, hi);
  return r;
};
```
]
#complexity(time: $O(n)$, space: $O(h)$)

#code(lang: "text", caption: "Output")[
```text
{50,30,70,20,40,60,80} trimmed to [35,65] -> [40 50 60]
{5,3,8} trimmed to [100,200] -> null
```
]

#ex(16, tier: 1, asked: "Capgemini · pattern")[
*Count how many keys lie in `[lo, hi]`.*

*Limits* $n <= 10^5$, $10^5$ queries · *Target* $O(h + m)$ per query ·
*Edge cases* empty range; `lo > hi` (answer 0).
]
#approach(1, "Walk the whole tree and test every key", verdict: "O(n) per query")
#approach(2, "Prune any subtree that cannot hold a key in range", verdict: "O(h + m)")

#code(lang: "js", caption: "Same pruning shape as the range sum")[
```js
const countInRange = (r, lo, hi) => {
  if (r === null) return 0;
  if (r.val < lo) return countInRange(r.right, lo, hi);
  if (r.val > hi) return countInRange(r.left, lo, hi);
  return 1 + countInRange(r.left, lo, hi) + countInRange(r.right, lo, hi);
};
```
]
#complexity(time: $O(h + m)$, space: $O(h)$)
#code(lang: "text", caption: "Output on {50,30,70,20,40,60,80}")[
```text
count[30,70] = 5    count[0,100] = 7    count[41,49] = 0
```
]

#note[
If the queries keep coming and the tree never changes, do the inorder walk once into an
array and answer each query with two toolkit `lowerBound` calls in $O(log n)$. Choose by
how many queries you expect.
]

#section[Tier 2 — applied problems]
#tier-header(2)

#ex(17, tier: 2, asked: "Grab · pattern")[
*Closest fare.* A ride app stores every historical fare in a BST. Given a target fare,
return the stored fare closest to it. If two are equally close, return the smaller one.

*Limits* $n <= 2 times 10^5$ fares, values up to $10^6$ · *Target* $O(h)$ ·
*Edge cases* target smaller than every fare; an exact match.
]
#approach(1, "Walk the whole tree, keeping the smallest difference seen", verdict: "O(n) — it ignores the ordering completely")
#approach(2, "One walk down; only one side can ever hold something closer", verdict: "O(h) time, O(1) memory")

#sol[
Walk down. At every node, the current key is a candidate; then the BST rule tells you
which side can hold anything closer. Only one side can.
]

#code(lang: "js", caption: "Closest value — track the best while you descend")[
```js
const closestValue = (r, target) => {
  let best = r.val;
  while (r !== null) {
    if (Math.abs(r.val - target) < Math.abs(best - target)) best = r.val;
    if (target < r.val) r = r.left;
    else if (target > r.val) r = r.right;
    else return r.val;
  }
  return best;
};
```
]
#complexity(time: $O(h)$, space: $O(1)$)

#code(lang: "text", caption: "Output on {50,30,70,20,40,60,80}")[
```text
closest to 55   -> 50    (50 and 60 are both 5 away; strict < keeps the first, 50)
closest to 1    -> 20
closest to 1000 -> 80
closest to 40   -> 40
```
]

#trap[
The tie rule is decided by `<` versus `<=`. With strict `<`, the first candidate wins.
On the path 50 → 70 → 60 the first candidate is 50, so 50 wins. If the question wanted
the *bigger* fare on a tie, you would need `<=` *and* to visit 60 after 50 — read the
statement carefully, then pick the comparison to match.
]

#ex(18, tier: 2, asked: "Shopee · pattern")[
*Two prices that add to a budget.* Given a BST of prices and a budget `T`, is there a
pair of distinct nodes whose prices add to exactly `T`?

*Limits* $n <= 2 times 10^5$, prices up to $10^9$ · *Target* $O(n)$ time and better than
$O(n)$ memory · *Edge cases* one node only; negative values (refunds).
]

#approach(1, "Flatten to an array and use a hash set", verdict: "O(n) time, O(n) memory")

#code(lang: "js", caption: "The obvious one")[
```js
const twoSumSet = (root, target) => {
  const seen = new Set();                 // a Set, not an object: keys keep their type
  for (const x of inorderCollect(root)) {
    if (seen.has(target - x)) return true;
    seen.add(x);
  }
  return false;
};
```
]
#complexity(time: $O(n)$, space: $O(n)$)

#approach(2, "Two iterators — one from the smallest, one from the biggest", verdict: "O(n) time, O(h) memory")

#sol[
On a *sorted array* you would use two pointers. The inorder walk is a sorted array; you
just cannot index into it. So build two lazy iterators: one that yields keys in increasing
order and one in decreasing order, each using a stack of size `h`.
]

#code(lang: "js", caption: "Forward and backward iterators, then classic two pointers")[
```js
class BSTIterator {                       // yields keys smallest first
  constructor(root) { this.st = []; this.pushLeft(root); }
  pushLeft(r) { while (r !== null) { this.st.push(r); r = r.left; } }
  hasNext() { return this.st.length > 0; }
  next() { const cur = this.st.pop(); this.pushLeft(cur.right); return cur.val; }
}

class RevIterator {                       // yields keys biggest first
  constructor(root) { this.st = []; this.pushRight(root); }
  pushRight(r) { while (r !== null) { this.st.push(r); r = r.right; } }
  hasNext() { return this.st.length > 0; }
  next() { const cur = this.st.pop(); this.pushRight(cur.left); return cur.val; }
}

const twoSumTwoPointer = (root, target) => {
  const lo = new BSTIterator(root), hi = new RevIterator(root);
  if (!lo.hasNext() || !hi.hasNext()) return false;
  let a = lo.next(), b = hi.next();
  while (a < b) {                         // a < b keeps the two nodes distinct
    const s = a + b;
    if (s === target) return true;
    if (s < target) { if (!lo.hasNext()) break; a = lo.next(); }
    else            { if (!hi.hasNext()) break; b = hi.next(); }
  }
  return false;
};
```
]
#complexity(time: $O(n)$, space: $O(h)$)

#code(lang: "text", caption: "Output")[
```text
hash set    : target 90 -> yes, target 200 -> no
two pointers: target 90 -> yes, target 200 -> no, target 100 -> yes
single node {5}, target 10 -> no    (a node cannot pair with itself)
negatives {-5,-2,0,3}, target -7 -> yes
```
]

*The idea that unlocked it:* an iterator is a pointer you can move but not index. Every
two-pointer trick that only ever moves *forward* or *backward* works on a BST unchanged.

#ex(19, tier: 2, asked: "Agoda · pattern")[
*Design an iterator.* Build a class over a BST with `hasNext()` and `next()` that returns
keys in increasing order, using $O(h)$ memory and $O(1)$ *average* time per call.

*Limits* $n <= 10^5$, up to $n$ calls · *Target* $O(h)$ memory ·
*Edge cases* empty tree; calling `next()` exactly n times.
]
#approach(1, "Run a full inorder in the constructor and store the array", verdict: "O(n) memory, and the constructor costs O(n) even if the caller stops after one next()")
#approach(2, "Keep only the left spine on a stack", verdict: "O(h) memory, O(1) amortised per call")

#sol[
The `BSTIterator` above is the answer. Why is `next()` $O(1)$ on average? Over the whole
walk each node is pushed once and popped once, so `n` calls do `2n` stack operations in
total. Single calls can cost $O(h)$; the *average* is $O(1)$. That is amortised analysis
(Chapter 1).
]
#complexity(time: [$O(1)$ amortised per call], space: $O(h)$)
#code(lang: "text", caption: "Output")[
```text
walk: 20 30 40 50 60 70 80
empty tree -> hasNext() = false
```
]

#ex(20, tier: 2, asked: "DBS · pattern")[
*Merge two account ledgers.* Two BSTs hold account numbers. Produce one sorted list of
all account numbers, keeping duplicates that appear in both.

*Limits* both trees up to $10^5$ nodes · *Target* $O(n + m)$ time, $O(h_1 + h_2)$ extra ·
*Edge cases* one tree empty; both empty.
]

#approach(1, "Flatten both, concatenate, sort", verdict: "O((n+m) log(n+m)) — throws away the fact that both are already sorted")
#approach(2, "Flatten both, merge like merge sort", verdict: "O(n+m) time but O(n+m) memory")
#approach(3, "Two iterators, merge on the fly", verdict: "O(n+m) time, O(h1+h2) memory")

#code(lang: "js", caption: "Merge with two lazy iterators")[
```js
const mergeBSTs = (a, b) => {
  const ia = new BSTIterator(a), ib = new BSTIterator(b);
  const out = [];
  let x = ia.hasNext() ? ia.next() : null;
  let y = ib.hasNext() ? ib.next() : null;
  while (x !== null && y !== null) {
    if (x <= y) { out.push(x); x = ia.hasNext() ? ia.next() : null; }
    else        { out.push(y); y = ib.hasNext() ? ib.next() : null; }
  }
  while (x !== null) { out.push(x); x = ia.hasNext() ? ia.next() : null; }
  while (y !== null) { out.push(y); y = ib.hasNext() ? ib.next() : null; }
  return out;
};
```
]
#complexity(time: $O(n + m)$, space: [$O(h_1 + h_2)$ plus the output])

#code(lang: "text", caption: "Output")[
```text
{5,2,9} + {6,1,8} -> [1 2 5 6 8 9]
one empty         -> [2 5 9]
both empty        -> []
```
]

#note[
Follow-up the interviewer will ask: "now give me a *balanced BST* of the union, not a
list." Answer: feed the merged array into `sortedToBST`. Total $O(n + m)$.
]

#ex(21, tier: 2, asked: "SCB · pattern")[
*Build a BST from a preorder list.* A backup file stores the tree as its preorder walk.
Rebuild the tree.

*Limits* $n <= 10^5$, keys distinct · *Target* $O(n)$ ·
*Edge cases* empty list; strictly increasing list (a right chain).
]

#approach(1, "Insert the keys one by one", verdict: "O(n h) — O(n^2) on a sorted list")

#code(lang: "js", caption: "Brute force")[
```js
const preToBstInsert = (pre) => pre.reduce((root, x) => bstInsert(root, x), null);
```
]
#complexity(time: $O(n h)$, space: $O(h)$, note: "With pre = 1,2,3,...,n this is 5 x 10^9 steps for n = 10^5. Too slow.")

#approach(2, "Carry a legal window, exactly like validating a BST", verdict: "O(n) — the answer")

#sol[
Preorder visits the root first. So `pre[0]` is the root. Everything after it that is
smaller belongs to the left subtree, and the rest to the right. Instead of *searching* for
where the split is, give each recursive call a window `(lo, hi)` and stop as soon as the
next key falls outside it. Every key is read once.
]

#code(lang: "js", caption: "One pass, one shared index")[
```js
const preToBstBounds = (pre) => {
  let i = 0;                                  // one shared cursor, closed over
  const build = (lo, hi) => {
    if (i >= pre.length) return null;
    if (pre[i] < lo || pre[i] > hi) return null;   // not mine — give it back
    const r = new Node(pre[i++]);
    r.left  = build(lo, r.val);
    r.right = build(r.val, hi);
    return r;
  };
  return build(-Infinity, Infinity);
};
```
]
#complexity(time: $O(n)$, space: $O(h)$)

#approach(3, "A stack instead of recursion", verdict: "O(n) time, O(h) memory, no recursion at all")

#code(lang: "js", caption: "Stack version — useful when the tree may be 100000 deep")[
```js
const preToBstStack = (pre) => {
  if (pre.length === 0) return null;
  const root = new Node(pre[0]);
  const st = [root];
  for (let i = 1; i < pre.length; i++) {
    const cur = new Node(pre[i]);
    if (pre[i] < st[st.length - 1].val) {
      st[st.length - 1].left = cur;
    } else {
      let parent = null;
      while (st.length && st[st.length - 1].val < pre[i]) parent = st.pop();
      parent.right = cur;
    }
    st.push(cur);
  }
  return root;
};
```
]
#complexity(time: $O(n)$, space: $O(h)$, note: "Each node is pushed once and popped at most once.")

#code(lang: "text", caption: "All three agree — pre = {8, 5, 1, 7, 10, 12}")[
```text
insert one by one : inorder [1 5 7 8 10 12], root 8
bounds            : inorder [1 5 7 8 10 12], root 8
stack             : inorder [1 5 7 8 10 12], root 8
empty preorder    : null
```
]

*The idea that unlocked it:* the window `(lo, hi)` is the same idea as validating a BST.
Once you can *check* a tree with a window, you can *build* one with it.

#ex(22, tier: 2, asked: "Sea/Shopee · pattern")[
*Is this list a valid preorder of some BST?* No tree is given — only the list.

*Limits* $n <= 10^5$ · *Target* $O(n)$ time, $O(n)$ memory ·
*Edge cases* empty list (true); one key (true).
]
#approach(1, "Build a BST from the list, then check its preorder matches", verdict: "O(n h), and it needs the whole tree in memory")
#approach(2, "One stack plus a running floor value — never build the tree", verdict: "O(n) time, O(n) memory")

#sol[
Walk the list keeping a stack of "ancestors I am still inside" and a value `floorVal`:
the key of the last ancestor I moved *right* of. Once I have gone right of some node `p`,
every later key must be bigger than `p`. If any key is smaller, the list is impossible.
]

#code(lang: "js", caption: "One stack, one floor value")[
```js
const validPreorder = (pre) => {
  const st = [];
  let floorVal = -Infinity;
  for (const x of pre) {
    if (x < floorVal) return false;
    while (st.length && st[st.length - 1] < x) floorVal = st.pop();
    st.push(x);
  }
  return true;
};
```
]
#complexity(time: $O(n)$, space: $O(n)$)

#code(lang: "text", caption: "Output")[
```text
{8,5,1,7,10,12} -> valid
{8,10,5}        -> not valid   (after going right of 8 to 10, 5 cannot appear)
{}              -> valid
{4}             -> valid
```
]

#ex(23, tier: 2, asked: "GIC · pattern")[
*Serialise and rebuild.* Write a BST to a string, and read it back. The string must be as
short as you can make it.

*Limits* $n <= 10^5$ · *Target* $O(n)$ both ways · *Edge cases* empty tree; one node.
]
#approach(1, "Write the preorder WITH null markers, as for a general binary tree", verdict: "correct, but the string is about twice as long")
#approach(2, "Write the keys only, and rebuild with the window rule", verdict: "the shortest string a BST can have")

#sol[
For a *general* binary tree you must write null markers. For a *BST* you do not: the
preorder list alone fixes the shape, because the window rule tells you where each subtree
ends. So the string is just the preorder keys with spaces.
]

#code(lang: "js", caption: "Serialise = preorder; deserialise = the window build")[
```js
const serializeBST = (root) => {
  const out = [];
  const walk = (r) => { if (r === null) return; out.push(r.val); walk(r.left); walk(r.right); };
  walk(root);
  return out.join(' ');
};

const deserializeBST = (s) => {
  const pre = s.split(' ').filter(t => t.length).map(Number);
  let i = 0;
  const build = (lo, hi) => {
    if (i >= pre.length || pre[i] < lo || pre[i] > hi) return null;
    const r = new Node(pre[i++]);
    r.left  = build(lo, r.val);
    r.right = build(r.val, hi);
    return r;
  };
  return build(-Infinity, Infinity);
};
```
]
#complexity(time: $O(n)$, space: $O(n)$)

#code(lang: "text", caption: "Output")[
```text
serialise {50,30,70,20,40,60,80} -> "50 30 20 40 70 60 80 "
rebuild -> inorder [20 30 40 50 60 70 80], root 50
empty round trip: "" -> null
```
]

#section[Tier 3 — product interviews]
#tier-header(3)

#ex(24, tier: 3, asked: "Microsoft · pattern")[
*Repair a BST.* Exactly two nodes of a BST had their keys swapped by mistake. Put them
back without building a new tree.

*Limits* $n <= 10^5$ · *Target* $O(n)$ time, $O(h)$ memory ·
*Edge cases* the two swapped nodes are neighbours in the inorder walk; the swapped pair
includes the root.
]
#approach(1, "Copy the inorder, sort the copy, compare position by position, swap what differs", verdict: "O(n log n) time and O(n) memory")
#approach(2, "Spot the drops during a single inorder walk", verdict: "O(n) time, O(h) memory — the answer")

#sol[
Do the inorder walk and look for places where the sequence goes *down* instead of up.

- If the two wrong keys are far apart, you see *two* drops. The first wrong key is the
  *earlier* node of the first drop; the second is the *later* node of the second drop.
- If they are neighbours, you see only *one* drop, and the two nodes of that drop are the
  pair.

The code below handles both because `first` is set only once, while `second` keeps being
overwritten.
]

#code(lang: "js", caption: "Find the two drops, then swap the keys")[
```js
const recoverBST = (root) => {
  let first = null, second = null, prev = null;
  const walk = (r) => {
    if (r === null) return;
    walk(r.left);
    if (prev !== null && prev.val > r.val) {
      if (first === null) first = prev;    // only the first drop sets first
      second = r;                          // every drop updates second
    }
    prev = r;
    walk(r.right);
  };
  walk(root);
  if (first !== null && second !== null)
    [first.val, second.val] = [second.val, first.val];   // swap the two keys
};
```
]
#complexity(time: $O(n)$, space: $O(h)$)

#code(lang: "text", caption: "Output — both cases")[
```text
far apart : broken [5 30 15 20 10] -> fixed [5 10 15 20 30], valid = true
neighbours: broken [1 3 2 4]       -> fixed [1 2 3 4],       valid = true
```
]

#subsection[The follow-up]
*"Now do it in O(1) extra space."* \
Answer: replace the recursion with a *Morris inorder traversal*. Morris threads each
node's rightmost left-descendant back to the node, walks without a stack, then unthreads.
The drop-detection logic above does not change at all — only the traversal does. Say this
out loud; you do not need to write Morris from memory to get the credit.

#ex(25, tier: 3, asked: "Amazon · pattern")[
*Largest BST inside a binary tree.* You are given a binary tree that is *not* a BST. Find
the number of nodes in its biggest subtree that *is* a BST.

*Limits* $n <= 10^5$ · *Target* $O(n)$ · *Edge cases* the whole tree is already a BST;
an empty tree.
]

#approach(1, "For every node, test whether its subtree is a BST", verdict: "O(n^2) — each test is O(size)")
#approach(2, "One bottom-up pass; each node returns a tiny summary", verdict: "O(n) — the answer")

#sol[
A node's subtree is a BST exactly when: the left subtree is a BST, the right subtree is a
BST, `max(left) < node < min(right)`. So each call needs to return four things: is it a
BST, its size, its minimum and its maximum. Compute them from the children — never walk
down twice.
]

#code(lang: "js", caption: "Return a 4-field summary from every node")[
```js
const largestBSTSubtree = (root) => {
  let best = 0;
  // every call returns { ok, sz, mn, mx } about its own subtree
  const walk = (r) => {
    if (r === null) return { ok: true, sz: 0, mn: Infinity, mx: -Infinity };
    const L = walk(r.left), R = walk(r.right);
    if (L.ok && R.ok && L.mx < r.val && r.val < R.mn) {
      const cur = { ok: true, sz: L.sz + R.sz + 1,
                    mn: Math.min(L.mn, r.val), mx: Math.max(R.mx, r.val) };
      best = Math.max(best, cur.sz);
      return cur;
    }
    return { ok: false, sz: 0, mn: 0, mx: 0 };
  };
  walk(root);
  return best;
};
```
]
#complexity(time: $O(n)$, space: $O(h)$)

#code(lang: "text", caption: "Output")[
```text
tree 10(5(1,8), 15(-,7))  -> largest BST has 3 nodes  (the subtree 5(1,8))
tree that is fully a BST  -> 7
empty tree                -> 0
```
]

#trap[
The empty case returns `mn = Infinity, mx = -Infinity`. That looks backwards, and that is
the point: an empty subtree must never fail the test `L.mx < r.val`. Setting
`mx = -Infinity` makes the comparison always pass, whatever the key is. C++ would use
`INT_MIN` here and break on a key equal to `INT_MIN`; `-Infinity` has no such hole.
]

#subsection[The follow-up]
*"Now return the largest sum instead of the largest count, and allow negative keys."* \
Same walk, one field changes: carry a running `sum` instead of the subtree size `sz`.
No numeric type to widen — a JavaScript number already holds $10^5$ keys of size $10^9$.

#code(lang: "js", caption: "Maximum-sum BST subtree")[
```js
const maxSumBST = (root) => {
  let best = 0;
  const walk = (r) => {
    if (r === null) return { ok: true, sum: 0, mn: Infinity, mx: -Infinity };
    const L = walk(r.left), R = walk(r.right);
    if (L.ok && R.ok && L.mx < r.val && r.val < R.mn) {
      const cur = { ok: true, sum: L.sum + R.sum + r.val,
                    mn: Math.min(L.mn, r.val), mx: Math.max(R.mx, r.val) };
      best = Math.max(best, cur.sum);
      return cur;
    }
    return { ok: false, sum: 0, mn: 0, mx: 0 };
  };
  walk(root);
  return best;
};
```
]
#code(lang: "text", caption: "Output")[
```text
tree 1(40(20,60), 3)      -> 120   (the subtree 40(20,60))
a full BST {50,...,80}    -> 350
empty tree                -> 0
all-negative BST {-5,-8,-2} -> 0   (the empty subtree, sum 0, wins)
```
]
#trap[
That last line is a *specification* question, not a bug. `best` starts at 0, so an empty
subtree is always allowed. If the question says the subtree must be non-empty, start
`best` at `LLONG_MIN` and update it only for non-empty subtrees. Ask the interviewer
which one they want.
]

#ex(26, tier: 3, asked: "Google · pattern")[
*Split a BST.* Given a BST and a value `t`, split it into two BSTs: one with every key
`<= t`, one with every key `> t`. Reuse the existing nodes.

*Limits* $n <= 10^5$ · *Target* $O(h)$ · *Edge cases* every key `<= t`; empty tree.
]
#approach(1, "Walk every node and insert its key into one of two fresh trees", verdict: "O(n h), and it throws away every existing node")
#approach(2, "Follow the search path and re-hang only what it crosses", verdict: "O(h) — the answer")

#sol[
Follow the search path for `t`. At a node with `val <= t`, the node and its *whole left
subtree* belong to the low tree; only its right subtree needs splitting, and the low part
of that split becomes the node's new right child.
]

#code(lang: "js", caption: "Split — O(h), only the search path is touched")[
```js
const splitBST = (r, target) => {         // returns [keys <= target, keys > target]
  if (r === null) return [null, null];
  if (r.val <= target) {
    const [lowPart, highPart] = splitBST(r.right, target);
    r.right = lowPart;
    return [r, highPart];
  }
  const [lowPart, highPart] = splitBST(r.left, target);
  r.left = highPart;
  return [lowPart, r];
};
```
]
#complexity(time: $O(h)$, space: $O(h)$)

#code(lang: "text", caption: "Output")[
```text
{50,30,70,20,40,60,80} split at 45 -> low [20 30 40]  high [50 60 70 80]
{5,3,8} split at 100               -> low [3 5 8]     high = null
```
]

#subsection[The follow-up]
*"Now join them back."* If every key of tree A is smaller than every key of tree B, you
can join in $O(h)$: take the biggest node of A, make it the new root, hang A-without-it
on the left and B on the right. This pair of operations — split and join — is the engine
inside a treap and inside a rope.

#ex(27, tier: 3, asked: "Goldman Sachs · pattern")[
*Count smaller trades to the right.* Given an array of trade sizes, for each position `i`
report how many *later* positions hold a strictly smaller size.

*Limits* $n <= 10^5$, values may repeat and may be negative · *Target* $O(n log n)$
average · *Edge cases* all values equal (all zeros); a strictly decreasing array.
]

#approach(1, "Two loops", verdict: "O(n^2) — 10^10 steps at n = 10^5, far too slow")

#code(lang: "js", caption: "Brute force, kept only as a checker")[
```js
const countSmallerRightBrute = (a) => {
  const n = a.length, out = new Array(n).fill(0);
  for (let i = 0; i < n; i++)
    for (let j = i + 1; j < n; j++)
      if (a[j] < a[i]) out[i]++;
  return out;
};
```
]
#complexity(time: $O(n^2)$, space: $O(1)$)

#approach(2, "Insert from the right into a size-augmented BST", verdict: "O(n h) — O(n log n) on random data")

#sol[
Process the array *right to left*. Before inserting `a[i]`, everything already in the
tree is exactly "the elements to the right of i". While `a[i]` walks down to its place,
count what it passes:

- moving *left*: the current node and its right subtree are all bigger — count nothing,
  but bump that node's `leftSize` because a new smaller key joined its left side;
- moving *right*: every key in the current node's left subtree, plus the copies of the
  current node itself, are smaller — add them to a running `carry`.
]

#code(lang: "js", caption: "Each node stores leftSize and a duplicate count")[
```js
class CNode {
  constructor(val) {
    this.val = val;
    this.cnt = 1;        // copies of this key
    this.leftSize = 0;   // how many smaller keys sit on the left
    this.left = null; this.right = null;
  }
}

const countSmallerRight = (a) => {
  let root = null;
  const out = new Array(a.length).fill(0);
  // insert v, returning [newSubtree, howManySmallerItPassed]
  const insert = (r, v, carry) => {
    if (r === null) return [new CNode(v), carry];
    if (v === r.val) { r.cnt++; return [r, carry + r.leftSize]; }
    if (v < r.val) {
      r.leftSize++;
      const [child, res] = insert(r.left, v, carry);
      r.left = child;
      return [r, res];
    }
    const [child, res] = insert(r.right, v, carry + r.leftSize + r.cnt);
    r.right = child;
    return [r, res];
  };
  for (let i = a.length - 1; i >= 0; i--) {
    const [newRoot, res] = insert(root, a[i], 0);
    root = newRoot;
    out[i] = res;
  }
  return out;
};
```
]
#complexity(time: $O(n h)$, space: $O(n)$, note: "h is log n on random input, n in the worst case (already sorted input).")

#code(lang: "text", caption: "Output — checked against the brute force on every case")[
```text
[5 2 6 1]     -> [2 1 1 0]  (matches brute)
[]            -> []         (matches brute)
[7]           -> [0]        (matches brute)
[2 2 2]       -> [0 0 0]    (matches brute)
[-1 -5 0 -5]  -> [2 0 1 0]  (matches brute)
```
]

#subsection[The follow-up]
*"The input is already sorted descending — your tree becomes a chain."* True: the plain
BST degrades to $O(n^2)$. Three honest answers, in increasing order of effort:

+ Replace the plain BST with a *balanced* one (an AVL or a treap — see Example 28).
+ Use a Fenwick tree over the *compressed* values. Sort the distinct values, map each to
  an index, then "count smaller" is a prefix sum. Guaranteed $O(n log n)$.
+ Use a merge sort that counts inversions as it merges. Also $O(n log n)$, no extra
  structure.

#ex(28, tier: 3, asked: "Adobe · pattern")[
*Keep the tree short.* Explain and implement one way to stop a BST degenerating. Show
that inserting 1, 2, 3, ..., 1000 does not produce a chain.

*Limits* $n <= 10^5$ inserts · *Target* $O(log n)$ per insert ·
*Edge cases* sorted input; duplicate keys.
]

#subsection[Option A — AVL: measure the height, rotate when it slips]

#formulas(title: "The AVL rule")[
Store a *height* in every node. Define `balance(x) = height(x.left) - height(x.right)`.
After every insert, walk back up the path and fix any node with `|balance| > 1` using a
rotation. Four cases:

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*Case*], [*What it looks like*], [*Fix*],
  [LL], [balance > 1 and the new key went left of the left child], [rotate right],
  [RR], [balance < -1 and the new key went right of the right child], [rotate left],
  [LR], [balance > 1 and the new key went right of the left child], [rotate left on the left child, then rotate right],
  [RL], [balance < -1 and the new key went left of the right child], [rotate right on the right child, then rotate left],
)
]

#diagram(height: 4.6cm, caption: "The LL case. Insert 30, 20, 10. The chain leans left, so rotate right at 30: node 20 becomes the root.")[
  #dnode(0.6cm, 0cm, 1.2cm, 0.7cm, "30")
  #dnode(0.0cm, 1.3cm, 1.2cm, 0.7cm, "20")
  #dnode(0.0cm, 2.6cm, 1.2cm, 0.7cm, "10")
  #darrow(1.2cm, 0.7cm, 0.6cm, 1.3cm)
  #darrow(0.6cm, 2.0cm, 0.6cm, 2.6cm)
  #dnode(3.2cm, 1.3cm, 2.6cm, 0.7cm, "rotate right")
  #darrow(5.8cm, 1.65cm, 7.4cm, 1.65cm)
  #dnode(9.6cm, 0.6cm, 1.2cm, 0.7cm, "20")
  #dnode(8.2cm, 2.0cm, 1.2cm, 0.7cm, "10")
  #dnode(11.0cm, 2.0cm, 1.2cm, 0.7cm, "30")
  #darrow(10.2cm, 1.3cm, 8.8cm, 2.0cm)
  #darrow(10.2cm, 1.3cm, 11.6cm, 2.0cm)
]

#code(lang: "js", caption: "A complete AVL insert")[
```js
class ANode {
  constructor(val) { this.val = val; this.h = 1; this.left = null; this.right = null; }
}

const ht = (t) => (t === null ? 0 : t.h);
const fix = (t) => { t.h = 1 + Math.max(ht(t.left), ht(t.right)); };
const balanceOf = (t) => (t === null ? 0 : ht(t.left) - ht(t.right));

const rotateRight = (y) => {
  const x = y.left, T = x.right;
  x.right = y; y.left = T;
  fix(y); fix(x);            // fix the lower node first
  return x;                  // x is the new subtree root
};

const rotateLeft = (x) => {
  const y = x.right, T = y.left;
  y.left = x; x.right = T;
  fix(x); fix(y);
  return y;
};

const avlInsert = (r, v) => {
  if (r === null) return new ANode(v);
  if (v < r.val) r.left = avlInsert(r.left, v);
  else if (v > r.val) r.right = avlInsert(r.right, v);
  else return r;                                   // duplicate: nothing to do
  fix(r);
  const b = balanceOf(r);
  if (b >  1 && v < r.left.val)  return rotateRight(r);                  // LL
  if (b < -1 && v > r.right.val) return rotateLeft(r);                   // RR
  if (b >  1 && v > r.left.val) {                                        // LR
    r.left = rotateLeft(r.left); return rotateRight(r);
  }
  if (b < -1 && v < r.right.val) {                                       // RL
    r.right = rotateRight(r.right); return rotateLeft(r);
  }
  return r;
};
```
]
#complexity(time: [$O(log n)$ per insert], space: $O(log n)$, note: "An AVL tree of n nodes has height below 1.44 log2(n).")

#code(lang: "text", caption: "Output — the proof that it works")[
```text
insert 1..7 in order  -> inorder [1 2 3 4 5 6 7], root 4, height 3
{30,20,10} (LL case)  -> root 20, height 2
{30,10,20} (LR case)  -> root 20, height 2
insert 1..1000 in order -> AVL height 10   (a plain BST would be 1000)
```
]

#subsection[Option B — a treap: let randomness do the balancing]

#sol[
Give every node a *random priority* as well as its key. Keep the keys in BST order *and*
the priorities in heap order (a parent's priority is smaller than both children's). After
inserting normally, rotate the new node upward while its priority beats its parent's.

Because the priorities are random, the shape is the shape of a BST built from a *random*
insertion order — expected height about $1.39 log_2 n$ — no matter what order the keys
arrive in. It is twenty lines instead of AVL's sixty.
]

#code(lang: "js", caption: "A treap: BST on the key, min-heap on the priority")[
```js
class TNode {
  constructor(val) { this.val = val; this.pri = Math.random(); this.l = null; this.r = null; }
}

const tRotR = (y) => { const x = y.l; y.l = x.r; x.r = y; return x; };
const tRotL = (x) => { const y = x.r; x.r = y.l; y.l = x; return y; };

const tInsert = (r, v) => {
  if (r === null) return new TNode(v);
  if (v < r.val) {
    r.l = tInsert(r.l, v);
    if (r.l.pri < r.pri) r = tRotR(r);      // child outranks parent
  } else if (v > r.val) {
    r.r = tInsert(r.r, v);
    if (r.r.pri < r.pri) r = tRotL(r);
  }
  return r;
};
```
]
#complexity(time: [$O(log n)$ expected], space: $O(n)$)

#code(lang: "text", caption: "Output — 1000 keys inserted in sorted order")[
```text
n=1000  inorder is sorted: yes   height = 23   (a plain BST would be 1000)
```
]

#note[
23 is bigger than the AVL's 10, because a treap only promises a good height *on average*.
Both are $O(log n)$. Pick AVL when you need a guarantee, a treap when you need to write
it quickly and correctly under time pressure.
]

#subsection[The follow-up]
*"Which one does a real library use?"* A red-black tree: a different balance rule
(colour-based instead of height-based) with the same $O(log n)$ guarantee, and fewer
rotations per insert. C++'s ordered `set` and `map` and Java's `TreeMap` are all red-black
trees. In an interview you are not expected to code one. You are expected to know that
they are ordered, $O(log n)$, and safe on sorted input — and that JavaScript ships none of
them, so you reach for a sorted array or hand-write the tree.

#ex(29, tier: 3, asked: "D. E. Shaw · pattern")[
*BST to a sorted doubly linked list, in place.* Convert a BST into a sorted doubly linked
list using the existing nodes. Use `left` as `prev` and `right` as `next`.

*Limits* $n <= 10^5$ · *Target* $O(n)$ time, $O(h)$ memory, no new nodes ·
*Edge cases* empty tree; one node (its `left` and `right` must both end up null).
]
#approach(1, "Inorder into a vector, then relink the nodes in a second pass", verdict: "O(n) time but O(n) extra memory")
#approach(2, "Link each node as the inorder walk leaves it", verdict: "O(n) time, O(h) memory, no array at all")

#sol[
Do the inorder walk, and as you *leave* each node, link it to the previously finished
node. The single trap: `r.right` is the next thing you must visit, but you are about to
overwrite it. Save it first.
]

#code(lang: "js", caption: "Save the right pointer before you destroy it")[
```js
const bstToDLL = (root) => {
  let head = null, tail = null;
  const walk = (r) => {
    if (r === null) return;
    walk(r.left);
    const nxt = r.right;               // SAVE — we are about to overwrite it
    if (tail === null) { head = r; r.left = null; }
    else { tail.right = r; r.left = tail; }
    tail = r;
    r.right = null;
    walk(nxt);
  };
  walk(root);
  return head;
};
```
]
#complexity(time: $O(n)$, space: $O(h)$)

#code(lang: "text", caption: "Output on {4,2,6,1,3,5,7}")[
```text
forward : 1 2 3 4 5 6 7
backward: 7 6 5 4 3 2 1
```
]

#subsection[The follow-up]
*"Now go the other way: sorted doubly linked list back to a balanced BST, in O(n)."* \
Count the nodes, then build *bottom-up*: recursively build the left half, take the next
node from the list as the root, then build the right half. Each list node is consumed
once, in order, so it is $O(n)$ and never walks the list twice.

#ex(30, tier: 3, asked: "Uber · pattern")[
*How many different BSTs?* With the keys 1..n, how many *structurally different* BSTs
exist?

*Limits* $n <= 30$ (the answer for n = 30 is about $3.8 times 10^15$) ·
*Target* $O(n^2)$ · *Edge cases* n = 0 (one tree: the empty one); the answer overflowing
32-bit `int` from n = 20 onward.
]
#approach(1, "Generate every shape and count them", verdict: "exponential — there are 4861946401452 of them at n = 25")
#approach(2, "Choose the root, then multiply the counts of the two sides", verdict: "O(n^2) dynamic programming")

#sol[
Pick the root. If the root is key `k`, then keys `1..k-1` form the left subtree and
`k+1..n` the right subtree, and the two choices are independent. So with `dp[m]` = number
of BST shapes on `m` keys:

$ "dp"[m] = sum_(k=1)^m "dp"[k-1] times "dp"[m-k], quad "dp"[0] = 1 $

These are the Catalan numbers.
]

#code(lang: "js", caption: "Catalan by dynamic programming — exact only up to n = 30")[
```js
const countBSTShapes = (n) => {
  const dp = new Array(n + 1).fill(0);
  dp[0] = 1;
  for (let k = 1; k <= n; k++)
    for (let left = 0; left < k; left++)
      dp[k] += dp[left] * dp[k - 1 - left];
  return dp[n];
};

// From n = 31 the count passes 2^53 - 1, so the plain version starts lying.
// Same three lines, BigInt literals (0n, 1n) everywhere:
const countBSTShapesBig = (n) => {
  const dp = new Array(n + 1).fill(0n);
  dp[0] = 1n;
  for (let k = 1; k <= n; k++)
    for (let left = 0; left < k; left++)
      dp[k] += dp[left] * dp[k - 1 - left];
  return dp[n];
};
```
]
#complexity(time: $O(n^2)$, space: $O(n)$)

#code(lang: "text", caption: "Output")[
```text
n=0  -> 1
n=1  -> 1
n=2  -> 2
n=3  -> 5
n=4  -> 14
n=5  -> 42
n=10 -> 16796
n=25 -> 4861946401452
```
]

#trap[
`dp[left] * dp[k-1-left]` is a *product of two large numbers*, and this is where
JavaScript quietly lies. Numbers are doubles: every integer up to $2^53 - 1$ is exact,
and past that the answer is rounded. Measured with node: `n = 30` gives
`3814986502092304`, which is correct; `n = 31` gives `14544636039226908`, and the true
value is `14544636039226909`. Off by one, no error, no warning.

Past n = 30, switch the whole table to `BigInt`: start with `dp = new Array(n+1).fill(0n)`,
`dp[0] = 1n`, and print with `.toString()`. In C++ this is the line where you would widen
to a 64-bit integer; in JavaScript the corresponding move is `BigInt`, and it has no
ceiling at all.
]

#subsection[The follow-up]
*"Now list them all, not just count them."* Recursion again: for each root `k`, build
every left shape from `1..k-1` and every right shape from `k+1..n` and pair them up. The
count is Catalan, so the output size is exponential — this is only sane for n up to about
10. Say that out loud before you start coding.

#section[Dry run — deleting a node with two children]

Trace `bstErase(root, 30)` on this tree, node by node.

#diagram(height: 3.6cm, caption: "Starting tree. We delete 30, which has two children.")[
  #dnode(5.4cm, 0cm, 1.2cm, 0.7cm, "50")
  #dnode(2.4cm, 1.3cm, 1.2cm, 0.7cm, "30")
  #dnode(8.4cm, 1.3cm, 1.2cm, 0.7cm, "70")
  #dnode(0.8cm, 2.6cm, 1.2cm, 0.7cm, "20")
  #dnode(4.0cm, 2.6cm, 1.2cm, 0.7cm, "40")
  #darrow(6.0cm, 0.7cm, 3.0cm, 1.3cm)
  #darrow(6.0cm, 0.7cm, 9.0cm, 1.3cm)
  #darrow(3.0cm, 2.0cm, 1.4cm, 2.6cm)
  #darrow(3.0cm, 2.0cm, 4.6cm, 2.6cm)
]

#table(
  columns: (auto, auto, auto, auto),
  align: (left, left, left, left),
  [*Step*], [*Call*], [*What the code checks*], [*What happens*],
  [1], [`bstErase(50, 30)`], [`30 < 50`], [recurse into the left child],
  [2], [`bstErase(30, 30)`], [equal — this is the node], [it has both children, so we cannot unhook],
  [3], [`minNode(40)`], [walk left from 40; 40 has no left child], [successor `s` = 40],
  [4], [copy], [`root.val = 40`], [the node now holds 40; the tree has two 40s for a moment],
  [5], [`bstErase(40, 40)`], [equal — this is the duplicate], [`left === null`, so return `right` = null; the node is dropped],
  [6], [unwind], [step 2 sets `root.right = null`], [node 40 (old 30) now has only child 20],
  [7], [unwind], [step 1 sets `50->left = ` that node], [done],
)

Final tree: root 50; `50.left` = 40 with left child 20; `50.right` = 70.

#code(lang: "text", caption: "Inorder before and after")[
```text
before: 20 30 40 50 70
after : 20 40 50 70
```
]

#note[
Step 4 is the trick worth remembering: *we never move a node, we move a key*. The node
object stays where it is; only its `val` changes. That is why the deletion does not have
to repair any parent pointers.
]

#subsection[The same trace, but the successor is deeper]

If 30's right subtree had been 45 with a left child 42, then `minNode` would walk
45 → 42 and return 42. The copy step writes 42 into the node, and step 5 deletes 42 from
the right subtree — where 42 is a *leaf*, so it is unhooked directly. The successor of a
two-child node always has *no left child*, which is exactly why the recursive delete never
loops forever.

#section[Python — the two signature problems]

Python is shorter for the two problems you are most likely to be asked to "just write
quickly".

#code(lang: "python", caption: "Validate a BST, and the k-th smallest without recursion")[
```python
class Node:
    def __init__(self, val):
        self.val = val
        self.left = None
        self.right = None

def is_bst(root):
    prev = [float('-inf')]              # a list, so walk() can change it
    def walk(n):
        if n is None:
            return True
        if not walk(n.left):
            return False
        if n.val <= prev[0]:
            return False
        prev[0] = n.val
        return walk(n.right)
    return walk(root)

def kth_smallest(root, k):
    st, cur = [], root
    while st or cur:
        while cur:                          # run down the left spine
            st.append(cur)
            cur = cur.left
        cur = st.pop()
        k -= 1
        if k == 0:
            return cur.val
        cur = cur.right
    return None                             # k was bigger than the tree

def sorted_to_bst(a, lo=0, hi=None):
    if hi is None:
        hi = len(a) - 1
    if lo > hi:
        return None
    mid = (lo + hi) // 2
    n = Node(a[mid])
    n.left = sorted_to_bst(a, lo, mid - 1)
    n.right = sorted_to_bst(a, mid + 1, hi)
    return n
```
]

#code(lang: "text", caption: "Output")[
```text
is_bst good     : True
is_bst bad      : False
is_bst empty    : True
is_bst dup keys : False
kth 1,4,7       : 20 50 80
kth 8 (too big) : None
kth on empty    : None
balanced inorder: [1, 2, 3, 4, 5, 6, 7] root 4 height 3
empty build     : None
one build       : 9 1
negatives       : [-9, -4, -1, 0] is_bst True
```
]

#trap[
In Python, `sys.setrecursionlimit(300000)` is often needed for deep trees — the default
limit is about 1000. The iterative `kth_smallest` above has no such problem, which is one
more reason to prefer the stack version.
]

#section[Practice]

#practice(tier: 0, time: "25 min")[
+ Insert 15, 10, 20, 8, 12, 17, 25 into an empty BST. Write the inorder walk and the
  height.
+ In that tree, what does `bstSearch` visit while looking for 12? For 13?
+ Delete 10 from that tree using the template. Write the tree after.
+ Write the smallest and biggest key of that tree, and say which pointer walk finds each.
+ True or false: every inorder walk that comes out sorted proves the tree is a BST.
]

#practice(tier: 1, time: "60 min")[
5. *Second largest key.* Return the second biggest key in a BST in $O(h)$.
   Edge cases: one node; two nodes.
6. *Minimum absolute difference.* Return the smallest $|a - b|$ over all pairs of keys.
   $n <= 10^5$. Edge cases: two nodes; negative keys.
7. *k-th largest key.* Same as k-th smallest but from the other end.
8. *Median of a BST.* Return the median key. Even counts average the middle two.
   Edge cases: empty tree; even node count.
9. *Distance between two keys.* Both keys exist. Return the number of edges between them.
   Edge cases: the same key twice; one key is the ancestor of the other.
10. *Greater-sum tree.* Replace every key by (itself + the sum of all bigger keys).
    Edge cases: one node; all-negative keys.
]

#practice(tier: 2, time: "70 min")[
11. *Same key set.* Two BSTs with possibly different shapes — do they hold exactly the
    same keys? $O(n)$ time, $O(h)$ memory. Edge cases: both empty; one is a prefix of the
    other.
12. *Pairs across two trees.* Given two BSTs and a target `x`, count pairs (one key from
    each tree) that add to `x`. Edge cases: no pair; every key equal.
13. *Modes.* A BST that *allows duplicates* (equal keys go right). Return every key that
    appears most often. Edge cases: all keys distinct; empty tree.
14. *Successor with parent pointers.* Every node has a `parent`. Find the inorder
    successor of a given *node* in $O(h)$ and $O(1)$ memory. Edge cases: the biggest node;
    a node with a right child.
]

#practice(tier: 3, time: "75 min")[
15. *k closest keys.* Return the `k` keys closest to a target, in increasing order.
    $n <= 10^5$. Target $O(n)$, then improve. Edge cases: `k >= n`; the target below
    every key.
16. *Valid postorder.* Decide whether an array is the postorder walk of some BST, in
    $O(n)$. Edge cases: empty; one element.
17. *Ranked leaderboard.* Support `add(score)`, `remove(score)`, `topKSum(k)` and
    `rankOf(score)` on a stream of scores, allowing duplicates.
]

#key[
*1.* Inorder 8 10 12 15 17 20 25; height 3 (15 → 10 → 8). \
*2.* For 12: 15, 10, 12 — three nodes. For 13: 15, 10, 12, then `12->right` is null, so
it visits three nodes and returns null. \
*3.* 10 has two children. Successor = smallest of its right subtree = 12. Copy 12 up,
delete the leaf 12. Result: root 15; 15.left = 12 with left child 8; 15.right = 20 with
children 17 and 25. Inorder 8 12 15 17 20 25. \
*4.* Smallest 8 (walk left only), biggest 25 (walk right only). \
*5.* True. A sorted inorder walk is exactly the BST rule — this is why `isBST_prev` is
correct. The one catch is duplicates: you must reject `a[i] == a[i-1]` if your BST is
meant to hold distinct keys.

*5 (second largest).* Reverse inorder — right, node, left — and stop at the second key.

#code(lang: "js", caption: "k-th largest, reverse inorder")[
```js
const kthLargest = (root, k) => {
  let seen = 0, out = null;
  const walk = (r) => {                 // reverse inorder: right, node, left
    if (r === null || seen >= k) return;
    walk(r.right);
    if (seen >= k) return;
    if (++seen === k) { out = r.val; return; }
    walk(r.left);
  };
  walk(root);
  return out;
};

const secondLargest = (root) => kthLargest(root, 2);
```
]
Output: on {50,30,70,20,40,60,80}: 1st = 80, 3rd = 60, 7th = 20, 9th = none, second = 70.
On a one-node tree {42}: 1st = 42, 2nd = none. This also answers *7*.

*6 (minimum absolute difference).* In sorted order, the closest pair is always two
*neighbours*. So compare each inorder key with the previous one.

#code(lang: "js", caption: "Neighbours in the inorder walk")[
```js
const minAbsDiff = (root) => {
  let prev = null, best = Infinity;
  const walk = (r) => {
    if (r === null) return;
    walk(r.left);
    if (prev !== null) best = Math.min(best, r.val - prev);   // inorder: never negative
    prev = r.val;
    walk(r.right);
  };
  walk(root);
  return best;
};
```
]
Output: {10,4,15,2,12} → 2; {1,100} → 99; {-5,-3,7} → 2. Note `r.val - prev` is never
negative, because inorder is increasing — no `abs` needed. `prev` starts at `-Infinity`,
so the very first node gives a difference of `Infinity` and can never be the minimum.
C++ starts `prev` at `INT_MIN` and must widen the subtraction to avoid overflow; the
JavaScript version has nothing to widen.

*8 (median).* Count the nodes, then fetch position `(n+1)/2` (and `n/2 + 1` as well when
`n` is even).

#code(lang: "js", caption: "Median")[
```js
const countNodes = (r) => (r === null ? 0 : 1 + countNodes(r.left) + countNodes(r.right));

const nthKey = (root, target) => {          // the target-th smallest, 1-based
  let seen = 0, out = null;
  const walk = (r) => {
    if (r === null || seen >= target) return;
    walk(r.left);
    if (seen >= target) return;
    if (++seen === target) { out = r.val; return; }
    walk(r.right);
  };
  walk(root);
  return out;
};

const medianBST = (root) => {
  const n = countNodes(root);
  if (n === 0) return 0;
  const a = nthKey(root, Math.floor((n + 1) / 2));
  if (n % 2 === 1) return a;
  return (a + nthKey(root, n / 2 + 1)) / 2;
};
```
]
Output: {50,30,70,20,40,60,80} → 50; {4,2,6,1} → 3 (that is (2+4)/2); {9} → 9; empty → 0.

*9 (distance).* Find the LCA, then count the edges from the LCA down to each key.

#code(lang: "js", caption: "Distance = depth(a) + depth(b), measured from the LCA")[
```js
const depthFrom = (r, key) => {
  let d = 0;
  while (r !== null && r.val !== key) { r = key < r.val ? r.left : r.right; d++; }
  return r ? d : -1;
};

const distanceBST = (root, a, b) => {
  const l = lcaBST(root, a, b);
  if (l === null) return -1;
  const da = depthFrom(l, a), db = depthFrom(l, b);
  if (da < 0 || db < 0) return -1;
  return da + db;
};
```
]
Output: distance(20,40) = 2; distance(20,80) = 4; distance(50,50) = 0; a missing key → -1.

*10 (greater-sum tree).* Walk in *reverse* inorder (right, node, left) with a running
total. Each node is replaced by the running total *after* adding itself.

#code(lang: "js", caption: "Reverse inorder with a running sum")[
```js
const toGreaterSumTree = (root) => {
  let run = 0;
  const walk = (r) => {                 // reverse inorder: right, node, left
    if (r === null) return;
    walk(r.right);
    run += r.val;
    r.val = run;
    walk(r.left);
  };
  walk(root);
};
```
]
Output: {4,1,6,0,2,5,7} → inorder becomes [25 25 24 22 18 13 7]; {5} → 5;
{-2,-5,1} → [-6 -1 1]. With $10^5$ keys of size $10^9$ the running total reaches
$10^14$ — a 64-bit integer in C++, and a plain JavaScript number here, since $10^14$ is
well inside $2^53 - 1$.

*11 (same key set).* Run two iterators in step.

#code(lang: "js", caption: "Compare two trees key by key")[
```js
const sameKeys = (a, b) => {
  const x = new BSTIterator(a), y = new BSTIterator(b);
  while (x.hasNext() && y.hasNext()) if (x.next() !== y.next()) return false;
  return !x.hasNext() && !y.hasNext();
};
```
]
Output: {5,3,8} vs {8,5,3} → true (different shapes, same keys); {5,3,8} vs {5,3} → false;
two empty trees → true.

*12 (pairs across two trees).* Forward iterator on the first tree, reverse on the second,
then the two-pointer rule.

#code(lang: "js", caption: "Two trees, two pointers")[
```js
const countPairs = (a, b, x) => {
  const ia = new BSTIterator(a), ib = new RevIterator(b);
  if (!ia.hasNext() || !ib.hasNext()) return 0;
  let p = ia.next(), q = ib.next(), cnt = 0;
  for (;;) {
    const s = p + q;
    if (s === x) {
      cnt++;
      if (!ia.hasNext() || !ib.hasNext()) break;
      p = ia.next(); q = ib.next();
    } else if (s < x) {
      if (!ia.hasNext()) break;
      p = ia.next();
    } else {
      if (!ib.hasNext()) break;
      q = ib.next();
    }
  }
  return cnt;
};
```
]
Output: {5,3,7} and {4,2,6} with x = 9 → 3 pairs ((3,6), (5,4), (7,2)); with x = 100 → 0.

*13 (modes).* Inorder groups equal keys together, so count run lengths.

#code(lang: "js", caption: "Runs of equal keys in the inorder walk")[
```js
const dupInsert = (r, v) => {            // equal keys go right
  if (r === null) return new Node(v);
  if (v < r.val) r.left = dupInsert(r.left, v);
  else r.right = dupInsert(r.right, v);
  return r;
};

const modesOfBST = (root) => {
  let prev = null, run = 0, best = 0, out = [];
  const walk = (r) => {
    if (r === null) return;
    walk(r.left);
    run = (prev !== null && r.val === prev) ? run + 1 : 1;
    if (run > best) { best = run; out = [r.val]; }
    else if (run === best) out.push(r.val);
    prev = r.val;
    walk(r.right);
  };
  walk(root);
  return out;
};
```
]
Output: inserting 5,3,5,7,5,3 → modes [5] (it appears three times); all-distinct
{1,2,3} → [1 2 3] (every key ties at one); empty tree → [].

*14 (successor with parent pointers).* Two cases. If the node has a right child, the
answer is the leftmost node of that right subtree. Otherwise climb until you step up from
a *left* child — that parent is the successor.

#code(lang: "js", caption: "Climb when there is nothing on the right")[
```js
class PNode {
  constructor(val) { this.val = val; this.left = null; this.right = null; this.parent = null; }
}

const successorWithParent = (x) => {
  if (x === null) return null;
  if (x.right !== null) {
    let c = x.right;
    while (c.left !== null) c = c.left;
    return c;
  }
  let p = x.parent;
  while (p !== null && p.right === x) { x = p; p = p.parent; }
  return p;
};
```
]
Output on {50,30,70,20,40,60,80}: succ(40)=50, succ(30)=40, succ(80)=none, succ(20)=30.

*15 (k closest keys).* Brute force: flatten, sort by distance, take k, sort again.
Better: flatten (already sorted), then binary search for the best *window* of length k.

#code(lang: "js", caption: "Two ways — the second is O(n + log n)")[
```js
const kClosestBrute = (root, target, k) => {
  const a = inorderCollect(root);
  // sort() on numbers ALWAYS needs a comparator; this one sorts by distance
  a.sort((p, q) => Math.abs(p - target) - Math.abs(q - target));
  return a.slice(0, k).sort((p, q) => p - q);
};

const kClosestWindow = (root, target, k) => {
  const a = inorderCollect(root);          // already sorted
  const n = a.length;
  if (k >= n) return a;
  let lo = 0, hi = n - k;                  // lo = start of the window
  while (lo < hi) {
    const mid = lo + Math.floor((hi - lo) / 2);
    if (target - a[mid] > a[mid + k] - target) lo = mid + 1;
    else hi = mid;
  }
  return a.slice(lo, lo + k);
};
```
]
Output: tree {50,30,70,20,40,60,80}, target 55, k = 3 → [40 50 60] from both. Target 5,
k = 2 → [20 30] from both. k = 100 → the whole tree.

*16 (valid postorder).* Postorder ends with the root, so scan *right to left* and mirror
Example 22: keep a *ceiling* instead of a floor.

#code(lang: "js", caption: "Postorder read backwards is root, right, left")[
```js
const validPostorder = (post) => {
  const st = [];
  let ceilVal = Infinity;
  for (let i = post.length - 1; i >= 0; i--) {
    const x = post[i];
    if (x > ceilVal) return false;
    while (st.length && st[st.length - 1] > x) ceilVal = st.pop();
    st.push(x);
  }
  return true;
};
```
]
Output: {1,7,5,12,10,8} → valid; {7,12,5,1,10,8} → not valid; {} → valid; {3} → valid.

*17 (leaderboard).* C++ would use a `multiset` — a balanced BST that keeps duplicates.
JavaScript has none, so the stand-in is a sorted array plus `lowerBound` from the toolkit.
Inserts cost $O(n)$ for the shift instead of $O(log n)$, which is fine up to a few tens of
thousands of scores; say that out loud rather than pretending it is free.

#code(lang: "js", caption: "Sorted array standing in for a multiset")[
```js
class Leaderboard {
  constructor() { this.scores = []; }          // kept sorted ascending

  add(s) {
    const i = lowerBound(this.scores, s);
    this.scores.splice(i, 0, s);               // O(n) shift, O(log n) search
  }
  remove(s) {
    const i = lowerBound(this.scores, s);
    if (this.scores[i] === s) this.scores.splice(i, 1);   // ONE copy only
  }
  topKSum(k) {
    return this.scores.slice(Math.max(0, this.scores.length - k))
                      .reduce((a, b) => a + b, 0);
  }
  rankOf(s) {                                  // how many scores are >= s
    return this.scores.length - lowerBound(this.scores, s);
  }
}
```
]
Output: add 70, 95, 95, 40, 88 → top-3 sum 278, rank of 88 is 3. After removing one 95:
top-3 sum 253, top-10 sum 293 (only five scores exist, so it returns the total).

#trap[
Delete *one* copy, not all of them. `this.scores.splice(i, 1)` removes exactly one element
at index `i`, which is what you want. The lazy version — `scores.filter(x => x !== s)` —
removes every 95 at once and silently changes the answer. (C++ has the same trap with
`multiset::erase(value)`, which also erases every copy.) Guard the splice with
`if (this.scores[i] === s)`, or a `remove` of a score that is not there will delete its
neighbour.
]
]

#revision[
#subsection[The invariant]
For every node: all keys left < node key < all keys right — across the *whole* subtree,
not just the children. Inorder walk = sorted order. That is the entire chapter.

#subsection[Template]
#code(lang: "js", caption: "Memorise this shape; change one comparison per problem")[
```js
// 1. walk down — search, floor, ceil, successor, predecessor and LCA share it
const walkDown = (r, key) => {
  while (r !== null) {
    if (key === r.val) return r;
    r = key < r.val ? r.left : r.right;
  }
  return null;
};

// 2. walk in order — validate, k-th, median, modes, min-gap, greater-sum share it
const walkInOrder = (r, visit) => {
  if (r === null) return;
  walkInOrder(r.left, visit);
  visit(r);                          // <- put the problem's work here
  walkInOrder(r.right, visit);
};

// 3. window down — validate, build-from-preorder and deserialise share it
const walkWindow = (r, lo, hi) => {
  if (r === null) return true;
  if (r.val <= lo || r.val >= hi) return false;
  return walkWindow(r.left, lo, r.val) && walkWindow(r.right, r.val, hi);
};
```
]

#subsection[Complexity table]
#table(
  columns: (auto, auto, auto, auto),
  align: (left, center, center, left),
  [*Operation*], [*Time*], [*Space*], [*Note*],
  [search / insert / delete], [$O(h)$], [$O(1)$ iterative], [h = log n only if balanced],
  [floor / ceil / successor / LCA], [$O(h)$], [$O(1)$], [one downward walk],
  [k-th smallest (plain)], [$O(h + k)$], [$O(h)$], [counting inorder],
  [k-th smallest (size field)], [$O(h)$], [$O(n)$], [pay at insert time],
  [validate], [$O(n)$], [$O(h)$], [window or inorder-prev],
  [range sum / count], [$O(h + m)$], [$O(h)$], [m = keys inside the range],
  [sorted array to balanced BST], [$O(n)$], [$O(log n)$], [middle element is the root],
  [iterator `next()`], [$O(1)$ amortised], [$O(h)$], [each node pushed and popped once],
  [AVL insert], [$O(log n)$], [$O(log n)$], [height stays below $1.44 log_2 n$],
  [treap insert], [$O(log n)$ expected], [$O(n)$], [random priority, no worst-case promise],
  [count BST shapes], [$O(n^2)$], [$O(n)$], [Catalan; exact only to n = 30, then `BigInt`],
)

#subsection[Top traps]
+ *Local check is not enough.* `left < node < right` on parents and children does not
  prove a BST. Use a window or the inorder-previous value.
+ *Finite sentinels break on extreme keys.* Use `-Infinity` and `Infinity` for `lo` and
  `hi`, never a large finite number — a key equal to that number then fails the test.
+ *Sorted input kills a plain BST.* Height becomes n. Use an AVL, a treap, or a sorted
  array plus `lowerBound`.
+ *Products overflow silently.* Catalan numbers are exact only to n = 30; past that a
  JavaScript number rounds and prints a wrong answer with no error. Switch to `BigInt`.
+ *Stepping back past the start.* Check `i > 0` before reading `a[i-1]` in a sorted-array
  predecessor query.
+ *Deleting every copy instead of one.* `filter(x => x !== s)` removes all duplicates;
  `splice(i, 1)` removes one.
+ *Delete forgets the successor rule.* For a two-child node, copy the smallest key of the
  right subtree up, then delete *that* key from the right subtree.
+ *`bstToDLL` overwrites `right` before using it.* Save `r.right` first.
+ *Empty-subtree sentinels look backwards on purpose.* `{mn: Infinity, mx: -Infinity}` is
  what makes an empty child pass every comparison.
+ *"Largest BST" with all-negative keys.* Decide with the interviewer whether the empty
  subtree (sum 0) is allowed to win.

#subsection[When to reach for what]
#table(
  columns: (auto, auto),
  align: (left, left),
  [*You need*], [*Use*],
  [order + inserts + deletes], [hand-written AVL or treap (JS ships no balanced BST)],
  [order + duplicates], [sorted array + `lowerBound`, `splice` to insert],
  [only lookups, data fixed], [sorted array + `lowerBound` / `upperBound`],
  [no order needed], [`Map` or `Set`],
  [k-th smallest, many queries], [BST with a subtree-size field],
  [guaranteed height, hand-written], [AVL],
  [short code, good height on average], [treap],
)
]

]
