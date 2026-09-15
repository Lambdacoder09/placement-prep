#import "../../shared/lib/style.typ": *

#chapter(
  num: 10,
  title: "Linked Lists",
  tagline: "No indexes, no jumping — just one pointer at a time, and a dummy node to save you",
)[

#note[
Every JavaScript snippet in this chapter was run with `node` before it was printed. Each
file uses the node class and the three helpers defined on the next page, and the one
chapter that needs a heap starts with
```js
const { MinHeap } = require('./toolkit.js');   // see the JS Toolkit appendix
```
The outputs shown under the snippets are the real outputs.
]

#section[Pattern in one page]

#formulas(title: "What a linked list is")[
A list is a chain of small boxes. Each box holds a value and a reference to the next box.
The last box points at `null`.

#align(center)[`head -> [1|·] -> [2|·] -> [3|·] -> null`]

*You get:* insert or delete anywhere in $O(1)$ *if you already hold the right pointer*,
and no reallocation ever.

*You lose:* random access. Reaching position $i$ costs $O(i)$. There is no `a[i]`.
]

#code(lang: "js", caption: "the node, and three helpers used by every test in this chapter")[
```js
class Node {
  constructor(val) { this.val = val; this.next = null; }
}

const build = (a) => {                  // helper used by every test
  const dummy = new Node(0);
  let tail = dummy;
  for (const x of a) { tail.next = new Node(x); tail = tail.next; }
  return dummy.next;
};
const show = (head) => {                // "1 -> 2 -> 3", or "(empty)"
  const parts = [];
  for (let p = head; p; p = p.next) parts.push(p.val);
  return parts.length ? parts.join(' -> ') : '(empty)';
};
const length = (head) => {
  let n = 0;
  for (let p = head; p; p = p.next) n++;
  return n;
};
```
]

#note[
There is no `delete` in JavaScript. When you unlink a node, nothing else points at it and
the garbage collector reclaims it on its own. Every C++ solution to these problems has a
`delete dead;` line — in JavaScript that line simply does not exist, and forgetting it
costs you nothing.
]

#subsection[The four moves — everything in this chapter is built from these]

#formulas(title: "The four moves")[
*Move 1 — the dummy head.* Create a fake node in front of the real head:
`const dummy = new Node(0); dummy.next = head;`. Now "delete the first node" and "delete a
middle node" are the *same* code, and you return `dummy.next` at the end. This removes
about half of all linked-list bugs.

*Move 2 — reverse by flipping arrows.* Three pointers: `prev`, `cur`, `nxt`. Save the
next, flip the arrow, step both forward.

*Move 3 — fast and slow.* Walk one pointer twice as fast as the other. When fast reaches
the end, slow is at the middle. If the list has a loop, fast catches slow from behind.

*Move 4 — the head start.* To find the node $n$ from the end, move one pointer $n$ steps
first, then move both together until the leader falls off the end.
]

#code(lang: "js", caption: "move 2 — reverse, the version to memorise")[
```js
const reverseList = (head) => {
  let prev = null;
  let cur = head;
  while (cur) {
    const nxt = cur.next;   // 1. remember where to go
    cur.next = prev;        // 2. flip the arrow
    prev = cur;             // 3. step prev forward
    cur = nxt;              // 4. step cur forward
  }
  return prev;              // prev is the new head
};
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#diagram(height: 4.6cm, caption: "One step of reverse. The arrow between prev and cur is flipped, then both slide right.")[
  #dnode(0pt, 0.2cm, 1.4cm, 0.75cm, "prev")
  #dnode(2.2cm, 0.2cm, 1.4cm, 0.75cm, "cur")
  #dnode(4.4cm, 0.2cm, 1.4cm, 0.75cm, "nxt")
  #darrow(2.2cm, 0.58cm, 1.5cm, 0.58cm, label: "flip")
  #darrow(3.7cm, 0.58cm, 4.3cm, 0.58cm)
  #place(dx: 0pt, dy: 1.4cm)[#text(size: 8.5pt)[after `cur.next = prev;` the chain behind `cur` already points backwards]]
  #dnode(0pt, 2.2cm, 1.4cm, 0.75cm, "—")
  #dnode(2.2cm, 2.2cm, 1.4cm, 0.75cm, "prev", fill: rgb("#e6f0e6"))
  #dnode(4.4cm, 2.2cm, 1.4cm, 0.75cm, "cur", fill: rgb("#e6f0e6"))
  #place(dx: 6.1cm, dy: 2.4cm)[#text(size: 8.5pt)[both stepped right;]]
  #place(dx: 6.1cm, dy: 2.8cm)[#text(size: 8.5pt)[repeat until `cur === null`]]
]

#code(lang: "js", caption: "move 3 — fast and slow, the middle of the list")[
```js
const middle = (head) => {                  // 2nd middle when the count is even
  let slow = head, fast = head;
  while (fast && fast.next) { slow = slow.next; fast = fast.next.next; }
  return slow;
};
```
]
Real output for `1 2 3 4 5` → `3`; `1 2 3 4` → `3`; `8` → `8`; empty → returns `null`.

#trick[
Start `fast` at `head` and you land on the *second* middle of an even list. Start `fast`
at `head.next` and you land on the *first* middle. Choose deliberately: splitting a list
in half needs the *first* middle, deleting the middle needs the *second*. Getting this
wrong causes infinite recursion in merge sort.
]

#trap[
Order matters in `while (fast && fast.next)`. JavaScript's `&&` evaluates left to right and
stops early, so `fast` is checked before `fast.next` is read. Swap them and you get
`TypeError: Cannot read properties of null (reading 'next')` on the last step. Tested in
Node — that is the exact message.

Optional chaining `fast?.next` also works and never throws, but `while (fast && fast.next)`
is what an interviewer expects to see, so learn that one first.
]

#subsection[The five questions to ask before you write a line]

#table(
  columns: (0.5fr, 2fr),
  [*1*], [Can the list be empty? (`head === null`)],
  [*2*], [Can it have exactly one node? (`head.next === null`)],
  [*3*], [Does the *head itself* get deleted or moved? If yes, use a dummy node.],
  [*4*], [Am I about to read `p.next.next`? Then I must have checked `p.next`.],
  [*5*], [Did I set the new last node's `next` to `null`? A forgotten `null` is a
          silent infinite loop.],
)

#section[Warm-up — build the reflex]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Write `length`, `search`, `insertAt(pos, val)` (0-based; append if `pos` is past the end)
and `deleteValue(val)` (remove the first match only).
Constraints: up to $10^5$ nodes. Edge cases: empty list, inserting at position 0,
deleting a value that is not present, deleting the only node.
]
#sol[
`insertAt` and `deleteValue` both may touch the head, so both use a dummy node.

#code(lang: "js", caption: "insert and delete with a dummy node")[
```js
const insertAt = (head, pos, val) => {     // 0-based; pos > length -> append
  const dummy = new Node(0);
  dummy.next = head;
  let prev = dummy;
  for (let i = 0; i < pos && prev.next; i++) prev = prev.next;
  const fresh = new Node(val);
  fresh.next = prev.next;
  prev.next = fresh;
  return dummy.next;
};
const deleteValue = (head, val) => {       // removes the FIRST match
  const dummy = new Node(0);
  dummy.next = head;
  for (let p = dummy; p.next; p = p.next)
    if (p.next.val === val) { p.next = p.next.next; break; }
  return dummy.next;
};
const search = (head, val) => {
  for (let p = head; p; p = p.next) if (p.val === val) return true;
  return false;
};
```
]
Real output of the test run:
```
1 -> 2 -> 3 -> 4 -> 5
5 0
9 -> 1 -> 2 -> 3 -> 4 -> 5
9 -> 1 -> 2 -> 7 -> 3 -> 4 -> 5
9 -> 1 -> 2 -> 7 -> 3 -> 4 -> 5 -> 0
1 -> 2 -> 7 -> 3 -> 4 -> 5 -> 0
1 -> 2 -> 7 -> 3 -> 4 -> 5 -> 0
1 0
```
Line 2 is `length` of the list and of `null`. Line 5 shows `insertAt(99, 0)` appending
at the end. Line 7 shows `deleteValue(1234)` leaving the list unchanged. Line 8 is
`search(7)` then `search(100)`. Inserting into an empty list gives `42`; deleting that
node gives `null` back.
]
#complexity(time: $O(n)$, space: $O(1)$)

#trap[
The loop condition in `insertAt` is `i < pos && prev.next`. Without the second half, a
`pos` larger than the list walks off the end and throws a `TypeError`. Without the first
half you always append. Both guards are needed.
]

#ex(2, tier: 0, asked: "warm-up")[
Print the middle node. For an even count, print the second of the two middles.
Trace `1 2 3 4` by hand with the fast/slow pointers.
]
#sol[
#table(
  columns: (0.6fr, 0.8fr, 0.8fr, 1.4fr),
  align: (center, center, center, left),
  [*step*], [*slow*], [*fast*], [*check `fast && fast.next`*],
  [start], [1], [1], [1 and 2 exist → continue],
  [1], [2], [3], [3 and 4 exist → continue],
  [2], [3], [`null`], [`fast` is null → stop],
)
Answer: node `3`. With `1 2 3 4 5` the trace stops with `fast` at node 5 and
`fast.next === null`, and `slow` sits at node 3.
]
#ans[3]

#ex(3, tier: 0, asked: "warm-up")[
Reverse a list, iteratively and recursively.
Constraints: up to $10^5$ nodes (think about recursion depth).
Edge cases: empty list, one node, two nodes.
]
#sol[
The iterative version is Move 2. The recursive version reverses everything *after* the
head, then makes the node behind the head point back at the head.

#code(lang: "js", caption: "recursive reverse")[
```js
const reverseRec = (head) => {
  if (!head || !head.next) return head;
  const newHead = reverseRec(head.next);
  head.next.next = head;     // the node behind me now points back at me
  head.next = null;
  return newHead;
};
```
]
Real output of `show(reverseRec(...))` on `1 2 3 4 5`, `7`, `null`, `1 2 3 4` and `-1 -2`:
```
5 -> 4 -> 3 -> 2 -> 1
7
(empty)
4 -> 3 -> 2 -> 1
-2 -> -1
```
Line 2 is a one-node list, line 3 is `reverseRec(null)`, which returns `null` and prints as
`(empty)`.
]
#complexity(time: $O(n)$, space: "iterative " + $O(1)$ + ", recursive " + $O(n)$ + " stack")

#trap[
`head.next = null;` must come *after* `head.next.next = head;`. Reverse the two lines
and you lose the reference you were about to use.
]

#trap[
*JavaScript's recursion depth is about $10^4$, far below C++ or Java.* I measured it in
Node: a plain recursive function died at depth *12546* with
`RangeError: Maximum call stack size exceeded`. I then ran `reverseRec` on a list of
$10^5$ nodes — same crash.

So `reverseRec` is a *teaching* version only. Constraints in this chapter go up to $10^5$
nodes, which means the iterative `reverseList` is the only safe answer. Say "iterative,
$O(1)$ space" first, and mention the recursion only as a follow-up, with the depth limit
named out loud. The same warning applies to every recursive walk over a long list.
]

#ex(4, tier: 0, asked: "warm-up")[
Delete a node when you are given *only* a pointer to that node — you cannot reach the
head. Edge case: the node is the last one.
]
#sol[
You cannot unlink a node without its predecessor. So do not unlink it: *become* the next
node. Copy the next node's value into this node, then delete the next node.

#code(lang: "js", caption: "delete without the head")[
```js
const deleteGivenOnlyNode = (target) => {   // works for any node except the last
  if (!target || !target.next) return false;
  const nxt = target.next;
  target.val = nxt.val;                     // copy the next node's data over mine
  target.next = nxt.next;
  return true;
};
```
]
On `1 2 3 4`, deleting the node at index 1 gives real output:
```
1 1 -> 3 -> 4
0
```
The leading `1` is the return value. The final `0` is the attempt to delete the last node,
which is impossible.
]
#note[
This is the answer the interviewer wants, *and* the honest caveat they want to hear: it is
a trick, not a real deletion. Any other variable that was aimed at the *next* node still
holds that node, now orphaned from the list but very much alive — JavaScript's collector
only frees what nothing references.
]

#ex(5, tier: 0, asked: "warm-up")[
Swap every pair of adjacent nodes: `1 2 3 4 5` becomes `2 1 4 3 5`. Swap the *nodes*, not
the values. Edge cases: odd length, one node, empty.
]
#sol[
#code(lang: "js", caption: "swap nodes in pairs")[
```js
const swapPairs = (head) => {
  const dummy = new Node(0);
  dummy.next = head;
  let prev = dummy;
  while (prev.next && prev.next.next) {
    const a = prev.next, b = a.next;
    a.next = b.next; b.next = a; prev.next = b;
    prev = a;
  }
  return dummy.next;
};
```
]
Real output:
```
2 -> 1 -> 4 -> 3 -> 5
2 -> 1
1
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#ex(6, tier: 0, asked: "warm-up")[
Is the list sorted in non-decreasing order? Edge cases: empty list, one node, duplicates.
]
#sol[
#code(lang: "js", caption: "sorted check")[
```js
const isSorted = (head) => {
  for (let p = head; p && p.next; p = p.next) if (p.val > p.next.val) return false;
  return true;
};
```
]
Real output for `1 2 2 3`, `3 1`, and `null` (printed as `1` for true, `0` for false):
```
101
```
An empty list and a one-node list are both sorted by definition.
]

#section[Tier 1 — the questions everyone is asked]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT pattern")[
*Detect a loop, find where it starts, measure it, and remove it.*
Constraints: up to $10^6$ nodes; memory is tight, so aim for $O(1)$ extra space.
Edge cases: no loop; a node pointing at itself; the whole list being one big loop.
]
#sol[

#approach(1, "Remember every node in a hash set", verdict: "O(n) time, O(n) space")
Walk the list and add each node *object* to a `Set`. A JavaScript `Set` compares objects by
identity, which is exactly what you want here — two different nodes holding the same value
are still two entries. The first repeat is the start of the loop. Simple, correct, but uses
$O(n)$ memory — and the interviewer will immediately ask for better.

#approach(2, "Fast and slow — Floyd's cycle rule", verdict: "O(n) time, O(1) space — optimal")
Slow moves one step, fast moves two. If there is a loop, fast enters it and gains one step
per move on slow, so it must eventually land on slow.

#code(lang: "js", caption: "detect a loop")[
```js
const hasCycle = (head) => {
  let slow = head, fast = head;
  while (fast && fast.next) {
    slow = slow.next;
    fast = fast.next.next;
    if (slow === fast) return true;
  }
  return false;
};
```
]

*Finding the start.* Let the straight part before the loop be $mu$ nodes long and the loop
be $lambda$ nodes long. When the two pointers meet, slow has walked $s$ steps and fast has
walked $2 s$. The extra distance fast covered is a whole number of laps:
$ 2 s - s = s = m lambda $
So $s$ is a multiple of the loop length. Now put one pointer back at the head and move both
one step at a time. The head pointer reaches the loop entrance after $mu$ steps; the other
pointer has already walked a multiple of $lambda$, so after $mu$ more steps it also sits at
the entrance. They meet exactly there.

#code(lang: "js", caption: "find the start, the length, and remove the loop")[
```js
const cycleStart = (head) => {
  let slow = head, fast = head;
  while (fast && fast.next) {
    slow = slow.next;
    fast = fast.next.next;
    if (slow === fast) {                  // they met: now walk one from the head
      let p = head;
      while (p !== slow) { p = p.next; slow = slow.next; }
      return p;
    }
  }
  return null;
};
const cycleLength = (head) => {
  let slow = head, fast = head;
  while (fast && fast.next) {
    slow = slow.next; fast = fast.next.next;
    if (slow === fast) {
      let len = 1;
      for (let p = slow.next; p !== slow; p = p.next) len++;
      return len;
    }
  }
  return 0;
};
const removeCycle = (head) => {
  const start = cycleStart(head);
  if (!start) return head;
  let p = start;
  while (p.next !== start) p = p.next;    // walk to the node pointing back
  p.next = null;
  return head;
};
```
]
Real output of the full test: a clean 5-node list; then the same list with node 5 pointing
back at node 2; then after removal; then a one-node self-loop; then `null` input; then a
2-node list that is entirely a loop.
```
0 0 0
1 2 4
1 -> 2 -> 3 -> 4 -> 5
0
1 7 1
7
0 1
1 2
```
Read the first line as `hasCycle`, "is there a start?", `cycleLength` — all zero on a clean
list. Line 2 says the loop starts at the node holding `2` and is 4 nodes long.
]
#complexity(time: $O(n)$, space: $O(1)$)

*The idea that unlocked it:* two speeds turn "is there a loop?" into "will one runner lap
the other?", and the meeting point carries enough arithmetic to recover the entrance
without any memory.

Python version — `is` is Python's identity test, the same job as JavaScript's `===` on two
objects:

#code(lang: "python", caption: "Floyd's cycle start in Python")[
```python
def cycle_start(head):
    slow = fast = head
    while fast and fast.next:
        slow, fast = slow.next, fast.next.next
        if slow is fast:
            p = head
            while p is not slow:
                p, slow = p.next, slow.next
            return p
    return None
```
]
Ran with `python3`: on a clean 5-node list it prints `None`; after pointing node 5 back at
node 2 it prints the node holding `2`.

#trap[
`removeCycle` must walk to the node whose `next` *is* the start, and set that node's `next`
to `null`. Setting `start.next = null` instead cuts the list in the wrong place and
loses everything after the entrance.
]

#trap[
Use `===` on nodes, never `==` and never a value test. `slow === fast` asks "is this the
same object?", which is the question Floyd's rule is about. `slow.val === fast.val` is a
different question and is wrong the moment two nodes share a value.
]

#ex(8, tier: 1, asked: "Infosys · pattern")[
*Merge two sorted lists into one sorted list*, reusing the existing nodes (no `new Node`).

Constraints: up to $10^5$ nodes each. Edge cases: one list empty, both empty, all values
equal, negative values.
]
#sol[
This is the single most useful linked-list routine in the book — merge sort, merge-K and
the flatten problem all call it.

#code(lang: "js", caption: "merge two sorted lists")[
```js
const mergeSorted = (x, y) => {
  const dummy = new Node(0);
  let tail = dummy;
  while (x && y) {
    if (x.val <= y.val) { tail.next = x; x = x.next; }
    else                { tail.next = y; y = y.next; }
    tail = tail.next;
  }
  tail.next = x || y;              // attach whatever is left
  return dummy.next;
};
```
]
Real output:
```
1 -> 2 -> 3 -> 4 -> 5 -> 6
1 -> 1 -> 1 -> 1 -> 1
2 -> 9
(empty)
-5 -> -3 -> -1 -> 0
```
]
#complexity(time: $O(n + m)$, space: $O(1)$)

#trick[
`tail.next = x || y;` replaces two extra while-loops. One of `x` and `y` is already `null`
when the loop ends, and `||` returns the first *truthy* operand — so this attaches whatever
is left in a single line. If both are `null`, `null || null` is `null`, which is also
right.
]

#trap[
Use `<=`, not `<`. With `<` the merge is still sorted but no longer *stable* — equal
values from the second list jump ahead of equal values from the first. Merge sort built on
an unstable merge is an unstable sort, and interviewers do ask.
]

Python version — the same shape, and `x or y` is the same trick as JavaScript's `x || y`.

#code(lang: "python", caption: "merge two sorted lists in Python")[
```python
def merge_sorted(x, y):
    dummy = Node(0)
    tail = dummy
    while x and y:
        if x.val <= y.val:
            tail.next, x = x, x.next
        else:
            tail.next, y = y, y.next
        tail = tail.next
    tail.next = x or y
    return dummy.next
```
]
Ran with `python3`: `[1, 3, 5]` merged with `[2, 4]` prints `[1, 2, 3, 4, 5]`; `None`
merged with `[9]` prints `[9]`.

#ex(9, tier: 1, asked: "Accenture · pattern")[
*Remove the n-th node from the end* in one pass.
Constraints: up to $10^5$ nodes, $n >= 1$. Edge cases: removing the head (n equals the
length), a one-node list, $n$ larger than the list.
]
#sol[

#approach(1, "Count, then walk again", verdict: "O(n), two passes")
Measure the length $L$, then delete the node at position $L - n$ from the front. Perfectly
acceptable — but the interviewer will say "one pass".

#approach(2, "Head start of n", verdict: "O(n), one pass — optimal")
Move `fast` $n$ steps ahead. Then move `fast` and `slow` together. When `fast` reaches the
last node, `slow` sits just before the node to delete. Starting both at the dummy makes
"delete the head" need no special case at all.

#code(lang: "js", caption: "remove the n-th from the end")[
```js
const removeNthFromEnd = (head, n) => {
  const dummy = new Node(0);
  dummy.next = head;
  let fast = dummy, slow = dummy;
  for (let i = 0; i < n; i++) {
    if (!fast.next) return head;   // n is bigger than the list
    fast = fast.next;
  }
  while (fast.next) { fast = fast.next; slow = slow.next; }
  slow.next = slow.next.next;      // no delete needed: nothing points at it now
  return dummy.next;
};
```
]
Real output for `1 2 3 4 5` with $n=2$; `1 2 3` with $n=3$ (deletes the head); `9` with
$n=1$; `1 2` with $n=5$ (too big):
```
1 -> 2 -> 3 -> 5
2 -> 3
(empty)
1 -> 2
```
]
#complexity(time: $O(n)$, space: $O(1)$)

*The idea that unlocked it:* a fixed gap of $n$ between two pointers converts "count from
the end" into "walk until the leader falls off", which needs no length at all.

#ex(10, tier: 1, asked: "Wipro · pattern")[
*Remove duplicates* — (a) from a *sorted* list, (b) from an *unsorted* list, keeping the
first occurrence of each value.
Constraints: up to $10^5$ nodes. Edge cases: all values equal, no duplicates, empty list,
negative values.
]
#sol[
(a) Sorted: duplicates are neighbours, so compare `p` with `p.next`.

(b) Unsorted: a `Set` of the values already kept.

#code(lang: "js", caption: "both versions")[
```js
const dedupSorted = (head) => {
  for (let p = head; p && p.next; ) {
    if (p.val === p.next.val) p.next = p.next.next;
    else p = p.next;
  }
  return head;
};
const dedupUnsorted = (head) => {
  const seen = new Set();
  const dummy = new Node(0);
  dummy.next = head;
  for (let p = dummy; p.next; ) {
    if (seen.has(p.next.val)) p.next = p.next.next;
    else { seen.add(p.next.val); p = p.next; }
  }
  return dummy.next;
};
```
]
Real output:
```
1 -> 2 -> 3 -> 4
5
(empty)
4 -> 2 -> 9
-1
```
]
#complexity(time: "(a) " + $O(n)$ + ", (b) " + $O(n)$ + " average", space: "(a) " + $O(1)$ + ", (b) " + $O(n)$)

#trap[
Do *not* advance `p` on the step where you delete. The new `p.next` has not been compared
yet. Writing the loop as a `for` with `p = p.next` in the header is exactly how people
miss `1 1 1`. Notice both loops above have an *empty* increment slot on purpose.
]

#note[
*Use a `Set`, not a plain object, for "have I seen this value?"* A plain object turns every
key into a string, so the number `1` and the string `"1"` collide, and `delete obj[k]` is
slow. A `Set` keeps the type and is built for exactly this. The same applies to `Map`
versus an object when you need key → value.
]

#ex(11, tier: 1, asked: "Capgemini · pattern")[
*Is the list a palindrome?* Target $O(1)$ extra space, and leave the list exactly as you
found it.
Constraints: up to $10^5$ nodes. Edge cases: empty, one node, two equal nodes, even and
odd lengths.
]
#sol[

#approach(1, "Copy to an array", verdict: "O(n) time, O(n) space")
Push all values into an array, then compare with two indexes. Five lines, and it is the
answer most people give first. Say it, then improve it.

#approach(2, "Push onto a stack, then re-walk", verdict: "still O(n) space")
Same cost, no gain.

#approach(3, "Reverse the back half in place", verdict: "O(n) time, O(1) space — optimal")
Find the middle with fast/slow, reverse from the middle onwards, compare the two halves,
then reverse the back half again to restore the list.

#code(lang: "js", caption: "palindrome check in O(1) space")[
```js
const isPalindrome = (head) => {
  if (!head || !head.next) return true;
  let slow = head, fast = head;                  // slow ends at the 2nd middle
  while (fast && fast.next) { slow = slow.next; fast = fast.next.next; }
  let prev = null;                               // reverse the back half
  while (slow) { const nxt = slow.next; slow.next = prev; prev = slow; slow = nxt; }
  let p = head, q = prev;
  let ok = true;
  while (q) { if (p.val !== q.val) { ok = false; break; } p = p.next; q = q.next; }
  let back = null;                               // put the list back together
  while (prev) { const nxt = prev.next; prev.next = back; back = prev; prev = nxt; }
  return ok;
};
```
]
Real output for `1 2 3 2 1`, `1 2 2 1`, `1 2 3`, `7`, `null`, `1 2`:
```
110110
```
And the restoration check on `1 2 2 1`:
```
1 1 -> 2 -> 2 -> 1
```
The list is unchanged after the call.
]
#complexity(time: $O(n)$, space: $O(1)$)

#trick[
Stop the comparison loop on `q`, not on `p`. For an odd length the front half is one node
longer, and the middle node is allowed to be anything. Looping on `q` handles odd and even
lengths with no `if`.
]

#ex(12, tier: 1, asked: "Cognizant · pattern")[
*Where do two lists merge?* Two lists may share a common tail. Return the first shared
node, or `null`.
Constraints: up to $10^5$ nodes each. Edge cases: no shared tail; the two heads are the
same node; one list empty; one list being a suffix of the other.
]
#sol[

#approach(1, "A Set holding one list's nodes", verdict: "O(n + m) time, O(n) space")
A `Set` of node *objects*, not of values — identity is the question, and JavaScript's `Set`
compares objects by identity.

#approach(2, "Line up the tails by length", verdict: "O(n + m) time, O(1) space")
Measure both lengths, advance the longer list's pointer by the difference, then walk
together. Once the remaining lengths match, the merge node (if any) is reached by both at
the same moment.

#code(lang: "js", caption: "intersection by length")[
```js
const intersectionByLength = (a, b) => {
  let la = length(a), lb = length(b);
  while (la > lb) { a = a.next; la--; }      // drop the longer list's head start
  while (lb > la) { b = b.next; lb--; }
  while (a && b && a !== b) { a = a.next; b = b.next; }
  return a === b ? a : null;
};
```
]

#approach(3, "Two pointers that swap lists", verdict: "same cost, four lines")
Each pointer walks its own list, then continues onto the *other* list. Both then cover
exactly $n + m$ nodes, so they arrive at the merge node together. If there is no merge
node, both become `null` at the same step and the loop ends.

#code(lang: "js", caption: "the swap trick")[
```js
const intersectionTwoPointer = (a, b) => {
  if (!a || !b) return null;
  let p = a, q = b;
  while (p !== q) {                          // each walks its own list then the other
    p = p ? p.next : b;
    q = q ? q.next : a;
  }
  return p;                                  // meeting point, or null
};
```
]
Real output (lists `1 2 3 -> 8 9 10` and `7 -> 8 9 10`, then disjoint lists, then `null`
input, then the same list twice, then one list being a suffix of the other). Each line
shows the two approaches side by side, and they agree every time:
```
1 -> 2 -> 3 -> 8 -> 9 -> 10
7 -> 8 -> 9 -> 10
8 8
1 1
1 1
5 5
3 3
```
Lines 4 and 5 print `1 1` meaning "both returned `null`", which is correct for disjoint
lists and for a `null` input.
]
#complexity(time: $O(n + m)$, space: $O(1)$)

#trap[
The loop in approach 3 must step to the *other list's head*, not restart on its own list.
`p = p ? p.next : b;` — note the `b`. Restarting on its own list loops forever when there
is no intersection.
]

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
*Add two numbers stored as lists.* (a) Digits are stored least-significant-first.
(b) Digits are stored most-significant-first.
Constraints: up to $10^5$ digits, so you cannot turn the list into a number.
Edge cases: different lengths; a final carry that adds a digit; both numbers zero; one
list empty.
]
#sol[
(a) Least-significant-first is the easy direction: walk both lists together, carry as you
go.

#code(lang: "js", caption: "digits stored backwards")[
```js
// digits stored LEAST significant first: 342 is 2 -> 4 -> 3
const addReversed = (a, b) => {
  const dummy = new Node(0);
  let tail = dummy;
  let carry = 0;
  while (a || b || carry) {
    let s = carry;
    if (a) { s += a.val; a = a.next; }
    if (b) { s += b.val; b = b.next; }
    carry = Math.floor(s / 10);      // NOT s / 10 — JS division gives 1.2, not 1
    tail.next = new Node(s % 10);
    tail = tail.next;
  }
  return dummy.next;
};
```
]
(b) Most-significant-first needs the digits in reverse. Either reverse both lists, or push
them onto two stacks. The stack version does not modify the inputs, and it builds the
answer by pushing at the *front*, which reverses for free.

#code(lang: "js", caption: "digits stored forwards, using stacks")[
```js
// digits stored MOST significant first: 342 is 3 -> 4 -> 2
const addForward = (a, b) => {
  const sa = [], sb = [];                  // a plain array IS the stack in JS
  for (let p = a; p; p = p.next) sa.push(p.val);
  for (let p = b; p; p = p.next) sb.push(p.val);
  let head = null;
  let carry = 0;
  while (sa.length || sb.length || carry) {
    let s = carry;
    if (sa.length) s += sa.pop();
    if (sb.length) s += sb.pop();
    carry = Math.floor(s / 10);
    const fresh = new Node(s % 10);        // build backwards: push at the FRONT
    fresh.next = head;
    head = fresh;
  }
  return head;
};
```
]
Real output — $342 + 465 = 807$, $999 + 1 = 1000$, $0 + 0$, empty + `5`, then the forward
versions $342 + 465$ and $99 + 1$, then empty + empty:
```
7 -> 0 -> 8
0 -> 0 -> 0 -> 1
0
5
8 -> 0 -> 7
1 -> 0 -> 0
(empty)
```
]
#complexity(time: $O(n + m)$, space: "(a) " + $O(1)$ + " extra, (b) " + $O(n + m)$)

#trap[
The loop condition is `while (a || b || carry)`. Drop the `|| carry` and $999 + 1$ prints
`000` — the leading 1 is lost. This is the single most common bug in this question.
]

#trap[
*`carry = s / 10` is a C++ habit and it is wrong in JavaScript.* There is no integer
division here: `19 / 10` is `1.9`, and the next digit comes out as `1.9`, not `1`. Use
`Math.floor(s / 10)`, or `(s / 10) | 0` for non-negative values. The same applies to every
"divide and keep the whole part" line in this book.
]

#trap[
*Do not try to shortcut this by converting the list to a number.* Every JavaScript number
is a double and is exact only up to `Number.MAX_SAFE_INTEGER`, which is
`9007199254740991` — 16 digits. Tested in Node: `Number("9".repeat(20))` prints
`100000000000000000000`, but the true value is twenty nines. With $10^5$ digits the
digit-by-digit walk above is the only correct answer. `BigInt` *is* exact —
`BigInt("9".repeat(20)) + 1n` gives `100000000000000000000n` — but building a
$10^5$-digit BigInt from a list is slower and misses the point of the question.
]

#ex(14, tier: 1, asked: "Infosys · pattern")[
*Rotate the list to the right by k places.* `1 2 3 4 5` with $k = 2$ becomes `4 5 1 2 3`.
Constraints: $k$ may be far larger than the list length.
Edge cases: $k = 0$; $k$ a multiple of the length; a one-node list; empty list.
]
#sol[
Close the list into a ring, then cut it in the right place.

#code(lang: "js", caption: "rotate right")[
```js
const rotateRight = (head, k) => {
  if (!head || !head.next || k <= 0) return head;
  let n = 1, tail = head;
  while (tail.next) { tail = tail.next; n++; }
  k %= n;
  if (k === 0) return head;
  tail.next = head;                      // close the ring
  let newTail = head;
  for (let i = 0; i < n - k - 1; i++) newTail = newTail.next;
  const newHead = newTail.next;
  newTail.next = null;                   // cut the ring
  return newHead;
};
```
]
Real output for $k = 2$ on `1 2 3 4 5`; $k = 3$ on `1 2 3`; $k = 7$ on `1 2 3`; $k = 5$ on
`1`; and `null`:
```
4 -> 5 -> 1 -> 2 -> 3
1 -> 2 -> 3
3 -> 1 -> 2
1
(empty)
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#trap[
`k %= n` must happen *before* anything else, and the `k === 0` early return must happen
*before* the ring is closed — otherwise you close the ring and never cut it, and the next
`show(head)` never returns.
]

#ex(15, tier: 1, asked: "Wipro · pattern")[
*Split by position.* Put the nodes at odd positions (1st, 3rd, 5th, ...) first, then the
nodes at even positions, keeping the relative order inside each group. Positions, not
values.
Constraints: $O(1)$ space. Edge cases: fewer than three nodes; even and odd lengths.
]
#sol[
Run two tails at once, hopping over each other.

#code(lang: "js", caption: "odd positions then even positions")[
```js
const oddEvenSplit = (head) => {           // positions 1,3,5,... then 2,4,6,...
  if (!head || !head.next) return head;
  let odd = head, even = head.next;
  const evenHead = even;
  while (even && even.next) {
    odd.next = even.next;  odd = odd.next;
    even.next = odd.next;  even = even.next;
  }
  odd.next = evenHead;
  return head;
};
```
]
Real output for `1 2 3 4 5`, `1 2 3 4`, `1`:
```
1 -> 3 -> 5 -> 2 -> 4
1 -> 3 -> 2 -> 4
1
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#ex(16, tier: 1, asked: "Capgemini · pattern")[
*Partition around a value x:* every node with value $< x$ must come before every node with
value $>= x$, and the original relative order must be preserved inside each group.
Edge cases: all values on one side; negative `x`; empty list.
]
#sol[
Build two chains with two dummy heads, then glue them.

#code(lang: "js", caption: "stable partition")[
```js
const partitionAround = (head, x) => {     // all < x first, order kept
  const lo = new Node(0), hi = new Node(0);
  let lt = lo, ge = hi;
  for (let p = head; p; p = p.next) {
    if (p.val < x) { lt.next = p; lt = p; }
    else           { ge.next = p; ge = p; }
  }
  ge.next = null;
  lt.next = hi.next;
  return lo.next;
};
```
]
Real output for `1 4 3 2 5 2` with $x = 3$; `5 5 5` with $x = 1$; `-3 -1 -2` with
$x = -2$:
```
1 -> 2 -> 2 -> 4 -> 3 -> 5
5 -> 5 -> 5
-3 -> -1 -> -2
```
]
#complexity(time: $O(n)$, space: $O(1)$)

#trap[
`ge.next = null;` before gluing. Without it the last node of the "big" chain still
points into the middle of the original list, and you get a loop. Call `show` on your answer
in a test — a run that never finishes is the symptom.
]

#section[Tier 2 — applied, two or three steps]
#tier-header(2)

#ex(17, tier: 2, asked: "Grab · pattern")[
*Rebuild the pick-up order.* A route is stored as a list of stops. Reorder it so that it
becomes first stop, last stop, second stop, second-last stop, and so on:
`1 2 3 4 5` becomes `1 5 2 4 3`.
Constraints: $O(1)$ space, up to $10^5$ stops. Edge cases: 0, 1 or 2 stops; even length.
]
#sol[
Three known moves in a row: find the *first* middle, reverse the back half, then weave.

#code(lang: "js", caption: "reorder: 1 n 2 (n-1) 3 ...")[
```js
const reorder = (head) => {                  // 1 2 3 4 5 -> 1 5 2 4 3
  if (!head || !head.next) return head;
  let slow = head, fast = head.next;         // slow ends at the FIRST middle
  while (fast && fast.next) { slow = slow.next; fast = fast.next.next; }
  let back = reverseList(slow.next);
  slow.next = null;
  let front = head;
  while (back) {
    const fn = front.next, bn = back.next;
    front.next = back; back.next = fn;
    front = fn; back = bn;
  }
  return head;
};
```
]
Real output for `1 2 3 4 5`, `1 2 3 4`, `1 2`, `9`, empty:
```
1 -> 5 -> 2 -> 4 -> 3
1 -> 4 -> 2 -> 3
1 -> 2
9
(empty)
```
]
#complexity(time: $O(n)$, space: $O(1)$)

*The idea that unlocked it:* a hard-looking rearrangement is three easy moves stacked.
Whenever the target order reads "front, back, front, back", think *split, reverse, weave*.

#trap[
`fast = head.next` gives the *first* middle, which puts the extra node in the *front*
half. That is what makes the weave loop terminate cleanly on `back`. Start `fast` at `head`
instead and `1 2 3 4` comes out wrong.
]

#ex(18, tier: 2, asked: "Shopee · pattern")[
*Sort a list with no extra array.* Sort a linked list of up to $10^5$ nodes in
$O(n log n)$ time and $O(log n)$ stack space.
Edge cases: already sorted; reverse sorted; duplicates; negatives; empty; one node.
]
#sol[

#approach(1, "Copy to an array, sort, copy back", verdict: "O(n log n) time, O(n) space")
Walk the list pushing values into an array, `vals.sort((a, b) => a - b)`, then walk the list
again writing them back. It works and it is fast, but it defeats the point of the question.

#trap[
*`arr.sort()` with no comparator sorts LEXICOGRAPHICALLY, as text.* Tested in Node:
`[10, 9, 1].sort()` returns `[1, 10, 9]`, because the string `"10"` is less than `"9"`.
Numbers *always* need `arr.sort((a, b) => a - b)`, which returns `[1, 9, 10]`.
This one missing comparator is the most common JavaScript bug in coding rounds — and it is
silent, because the code still runs and still returns a sorted-looking array.
]

#approach(2, "Insertion sort on the list", verdict: "O(n^2)")
Fine for tiny lists, too slow at $10^5$.

#approach(3, "Merge sort on the list", verdict: "O(n log n) time, O(log n) space — optimal")
Merge sort is the natural list sort: splitting is free (cut the middle) and merging is the
routine from Example 8. Quicksort is a bad fit here because a list has no random access
for partitioning by index.

The recursion here is safe: it splits in half every time, so the depth is $log_2 n$, about
17 for $n = 10^5$ — nowhere near JavaScript's limit of roughly $10^4$ frames.

#code(lang: "js", caption: "merge sort a linked list")[
```js
const sortList = (head) => {
  if (!head || !head.next) return head;
  let slow = head, fast = head.next;       // FIRST middle, so the split is even
  while (fast && fast.next) { slow = slow.next; fast = fast.next.next; }
  const second = slow.next;
  slow.next = null;
  return mergeSorted(sortList(head), sortList(second));
};
```
]
Real output for `4 2 1 3`; `-1 5 3 4 0`; `2 2 1`; `8`; empty:
```
1 -> 2 -> 3 -> 4
-1 -> 0 -> 3 -> 4 -> 5
1 -> 2 -> 2
8
(empty)
```
I also ran it on 5000 random values from $-1000$ to $999$ and compared the result against
`[...input].sort((a, b) => a - b)`. They matched exactly.
]
#complexity(time: $O(n log n)$, space: $O(log n)$ + " recursion")

#trap[
`fast = head.next` again. With `fast = head` a two-node list splits into "two nodes and
zero nodes", `sortList` is called on the same list forever, and Node throws
`RangeError: Maximum call stack size exceeded`. This is *the* classic
merge-sort-on-a-list bug.
]

#ex(19, tier: 2, asked: "Agoda · pattern")[
*Flatten a list of sorted columns.* Each node has a `next` pointer going right and a
`down` pointer into a sorted column. Every column is sorted. Produce one sorted list
linked only by `down`.
Constraints: total nodes up to $10^5$. Edge cases: one column; empty input; negative
values.
]
#sol[
Merge the columns from right to left. Because each column is already sorted, every merge
is the routine from Example 8 — just using `down` instead of `next`.

#code(lang: "js", caption: "flatten by repeated merging")[
```js
class FNode {
  constructor(val) { this.val = val; this.next = null; this.down = null; }
}

const mergeDown = (a, b) => {                // merge using the DOWN pointer only
  const dummy = new FNode(0);
  let tail = dummy;
  while (a && b) {
    if (a.val <= b.val) { tail.down = a; a = a.down; }
    else                { tail.down = b; b = b.down; }
    tail = tail.down;
  }
  tail.down = a || b;
  return dummy.down;
};
const flatten = (head) => {
  if (!head || !head.next) return head;
  head.next = flatten(head.next);             // flatten everything to the right first
  head = mergeDown(head, head.next);
  head.next = null;
  return head;
};
```
]
Real output for the columns `[5,7,8,30]`, `[10,20]`, `[19,22,50]`, `[28,35,40,45]`; then a
single column; then empty; then two columns of negatives:
```
5 7 8 10 19 20 22 28 30 35 40 45 50
3 4
1
-5 -3 -1 0
```
]
#complexity(time: $O(N k)$ + " worst case", space: $O(k)$ + " recursion",
  note: "N total nodes, k columns. Merging right to left touches a node once per merge it survives; a heap-based merge gives O(N log k).")

#trap[
`head.next = null;` after the merge. The flattened list must be linked only by `down`;
leaving stale `next` references means a later traversal walks into already-merged nodes.
]

#trap[
The recursion here is one frame per *column*. With $k$ columns up to $10^4$ you are close
to JavaScript's roughly $10^4$ frame limit, and past it you get
`RangeError: Maximum call stack size exceeded`. The safe rewrite is a loop: collect the
column heads into an array first, then merge them from the last one backwards.
]

#ex(20, tier: 2, asked: "SCB · pattern")[
*Reverse in groups of k.* `1 2 3 4 5 6 7` with $k = 3$ becomes `3 2 1 6 5 4 7`. A trailing
group shorter than $k$ is left as it is.
Constraints: $O(1)$ space, up to $10^5$ nodes.
Edge cases: $k = 1$; $k$ larger than the list; empty list; length an exact multiple of $k$.
]
#sol[
Walk group by group. Before touching a group, check that $k$ nodes really exist. Then
reverse it by *head insertion*: repeatedly take the node after the group's first node and
move it to the group's front.

#code(lang: "js", caption: "reverse in groups of k")[
```js
const reverseInGroups = (head, k) => {
  if (k <= 1 || !head) return head;
  const dummy = new Node(0);
  dummy.next = head;
  let groupPrev = dummy;
  for (;;) {
    let check = groupPrev;                    // is a full group of k left?
    for (let i = 0; i < k && check; i++) check = check.next;
    if (!check) break;
    const prev = groupPrev.next;              // will become the group's tail
    let cur = prev.next;
    for (let i = 1; i < k; i++) {             // standard head-insertion
      prev.next = cur.next;
      cur.next = groupPrev.next;
      groupPrev.next = cur;
      cur = prev.next;
    }
    groupPrev = prev;
  }
  return dummy.next;
};
```
]
Real output for `1..7` with $k=3$; `1..4` with $k=2$; `1 2 3` with $k=5$; `1 2 3` with
$k=1$; `null`:
```
3 -> 2 -> 1 -> 6 -> 5 -> 4 -> 7
2 -> 1 -> 4 -> 3
1 -> 2 -> 3
1 -> 2 -> 3
1
```
]
#complexity(time: $O(n)$, space: $O(1)$)

*The idea that unlocked it:* `groupPrev` is a stable anchor that never moves during the
reversal, so every node can be inserted right behind it. Without the anchor you need to
track four pointers and the code triples in size.

#note[
*Variant asked straight after:* reverse *alternate* groups — reverse one group of $k$,
skip the next, reverse the one after. Same loop with a `let doReverse = true` flag that
flips each round; in the skip branch just walk forward $k - 1$ times instead of inserting.
Real output for `1..8` with $k=2$ and `1..7` with $k=3$:
```
2 -> 1 -> 3 -> 4 -> 6 -> 5 -> 7 -> 8
3 -> 2 -> 1 -> 4 -> 5 -> 6 -> 7
```
]

#ex(21, tier: 2, asked: "LINE MAN · pattern")[
*Merge K sorted delivery queues* into one sorted list. There are $k$ lists with $N$ nodes
in total.
Constraints: $k <= 10^4$, $N <= 10^5$. Edge cases: some lists empty; all lists empty;
$k = 0$; $k = 1$.
]
#sol[

#approach(1, "Merge one at a time into an accumulator", verdict: "O(N k)")
Merging list 2 into list 1, then list 3 into that, and so on, re-walks the growing
accumulator every time. With $k = 10^4$ that is far too slow.

#approach(2, "Merge in pairs, like a tournament", verdict: "O(N log k)")
Round 1 merges $k\/2$ pairs, round 2 merges $k\/4$ pairs, and so on. Every node is touched
once per round, and there are $log k$ rounds.

#code(lang: "js", caption: "pairwise merging")[
```js
const mergeK = (lists) => {
  if (lists.length === 0) return null;
  while (lists.length > 1) {
    const nxt = [];
    for (let i = 0; i + 1 < lists.length; i += 2) nxt.push(mergeSorted(lists[i], lists[i + 1]));
    if (lists.length % 2) nxt.push(lists[lists.length - 1]);
    lists = nxt;
  }
  return lists[0];
};
```
]

#approach(3, "A min-heap of the k current heads", verdict: "O(N log k), streaming-friendly")
Same complexity, but it produces the output *in order as it goes* and needs only the $k$
heads in memory — the right answer when the lists are files or network streams.

#trap[
*JavaScript has no built-in priority queue or heap.* Python has `heapq`, Java has
`PriorityQueue`, C++ has `priority_queue` — JavaScript has nothing. Use the tested
`MinHeap` from the *JS Toolkit* appendix, and say out loud in the interview that you are
bringing your own, because the interviewer is watching for exactly this.
]

#code(lang: "js", caption: "min-heap merge")[
```js
const { MinHeap } = require('./toolkit.js');   // JS has no priority queue

const mergeKHeap = (lists) => {
  const pq = new MinHeap((a, b) => a.val - b.val);   // compare NODES by value
  for (const h of lists) if (h) pq.push(h);
  const dummy = new Node(0);
  let tail = dummy;
  while (pq.size) {
    const best = pq.pop();
    tail.next = best; tail = best;
    if (best.next) pq.push(best.next);
  }
  tail.next = null;
  return dummy.next;
};
```
]
Real output for three lists, then an empty array, then an array holding a single list —
and then the heap version on the same three lists and on an array holding two `null`
lists:
```
1 -> 1 -> 2 -> 3 -> 4 -> 4 -> 5 -> 6
(empty)
3
1 -> 1 -> 2 -> 3 -> 4 -> 4 -> 5 -> 6
(empty)
```
]
#complexity(time: $O(N log k)$, space: "pairwise " + $O(1)$ + ", heap " + $O(k)$)

#trap[
The toolkit `MinHeap` takes a comparator with the same meaning as `Array.prototype.sort`:
`(a, b) => a.val - b.val` means "a comes first when this is negative". Write
`(a, b) => b.val - a.val` and you have a *max*-heap, and the merge comes out perfectly
reverse-sorted — easy to miss on a tiny test. Check the sign on a three-element case
before you trust it.
]

#trap[
`tail.next = null;` at the end of the heap version. The last node popped still carries
its old `next`, which may point back into a list you already consumed.
]

#section[Tier 3 — you need the insight]
#tier-header(3)

#ex(22, tier: 3, asked: "Amazon · pattern")[
*Deep-copy a list where every node also has a `rand` reference* to any node in the list, or
to `null`.
Constraints: up to $10^5$ nodes. Target: $O(1)$ extra space beyond the new nodes.
Edge cases: a node whose `rand` points at itself; a `rand` pointing at the head; `null`
input; a one-node list.
]
#sol[

#approach(1, "A Map from old node to new node", verdict: "O(n) time, O(n) space")
Pass 1 creates a copy of each node and records `old -> new` in a `Map`. Pass 2 sets
`copy.get(p).next = copy.get(p.next)` and `copy.get(p).rand = copy.get(p.rand)`. This
*must* be a `Map`, not a plain object — object keys are strings, and a node is not a
string. Correct, easy, and the $O(n)$ map is exactly what the follow-up asks you to
remove.

#approach(2, "Weave the copies into the original list", verdict: "O(n) time, O(1) extra space — optimal")
Three passes and no map at all.
+ Insert each copy directly *behind* its original: `A -> A' -> B -> B' -> ...`. Now the
  copy of any node `p` is simply `p.next`.
+ Wire the random references: the copy of `p.rand` is `p.rand.next`.
+ Unweave: split the interleaved chain back into two lists.

#code(lang: "js", caption: "copy with random pointers, no map")[
```js
class RNode {
  constructor(val) { this.val = val; this.next = null; this.rand = null; }
}

const copyRandomList = (head) => {
  if (!head) return null;
  for (let p = head; p; ) {                      // 1. A -> A' -> B -> B' -> ...
    const c = new RNode(p.val);
    c.next = p.next; p.next = c; p = c.next;
  }
  for (let p = head; p; p = p.next.next)         // 2. wire the random references
    p.next.rand = p.rand ? p.rand.next : null;
  const dummy = new RNode(0);                    // 3. split the two lists apart
  let tail = dummy;
  for (let p = head; p; ) {
    const c = p.next;
    p.next = c.next;
    tail.next = c; tail = c;
    p = p.next;
  }
  return dummy.next;
};
```
]
Real output for the list `7 -> 13 -> 11` with randoms `null`, `7`, `13`:
```
7(rand=null) 13(rand=7) 11(rand=13)
1
7(rand=null) 13(rand=7) 11(rand=13)
1
4 1 1
```
Line 2 is the check "no copied node points at any original node", done with a `Set` of the
original node objects — it is a genuine deep copy. Line 3 shows the original list restored
exactly. Line 4 is `null` input. Line 5 is a one-node list whose `rand` points at itself:
the copy's `rand` points at the *copy*, and `copy !== original` is true.
]
#complexity(time: $O(n)$, space: $O(1)$ + " extra")

*The idea that unlocked it:* the map from old to new is a single reference, and a linked
list can carry a reference for free. Weaving stores the whole map inside the `next` fields,
then throws it away.

#trap[
Pass 2 and pass 3 must be separate loops. If you unweave while still wiring randoms, the
`p.rand.next` you need has already been repaired to point at the original's successor.
Attempting both in one pass is the most common failed attempt.
]

#note[
*Follow-up:* "what if the list has a loop as well?" Nothing changes. Every pass here walks
`next` a fixed number of times per node and never uses `null` as the loop end except in
pass 1 — rework pass 1 to stop when it returns to the head and the rest is identical.
]

#ex(23, tier: 3, asked: "Microsoft · pattern")[
*Design an LRU cache* with `get(key)` and `put(key, value)` both in $O(1)$. When the cache
is full, evict the least recently used key. A `get` counts as a use; a `put` on an existing
key counts as a use.
Constraints: capacity up to $10^5$, up to $10^6$ operations.
Edge cases: capacity 1; `get` on a missing key; updating an existing key must not evict.
]
#sol[
Two structures glued together.
+ A `Map` from `key` to node, for $O(1)$ lookup.
+ A *doubly* linked list in use order, most recent at the front. Doubly, because
  evicting the tail and moving a node to the front both need the node's *predecessor*,
  and a singly linked list cannot give you that in $O(1)$.

Two guard nodes (`head` and `tail`) mean no `null` checks anywhere in `unlink` and
`pushFront`.

#code(lang: "js", caption: "LRU cache: Map + doubly linked list")[
```js
class DNode {                       // doubly linked so unlink is O(1)
  constructor(key, val) { this.key = key; this.val = val; this.prev = null; this.next = null; }
}

class LRUCache {
  constructor(cap) {
    this.cap = cap;
    this.pos = new Map();           // key -> node
    this.head = new DNode(0, 0);    // head side = most recent
    this.tail = new DNode(0, 0);
    this.head.next = this.tail;     // two guard nodes, never removed
    this.tail.prev = this.head;
  }
  unlink(n) { n.prev.next = n.next; n.next.prev = n.prev; }
  pushFront(n) {
    n.next = this.head.next; n.prev = this.head;
    this.head.next.prev = n; this.head.next = n;
  }
  get(key) {
    const n = this.pos.get(key);
    if (n === undefined) return -1;
    this.unlink(n); this.pushFront(n);
    return n.val;
  }
  put(key, val) {
    const n = this.pos.get(key);
    if (n !== undefined) {
      n.val = val;
      this.unlink(n); this.pushFront(n);
      return;
    }
    if (this.pos.size === this.cap) {
      const dead = this.tail.prev;  // least recent
      this.unlink(dead); this.pos.delete(dead.key);
    }
    const fresh = new DNode(key, val);
    this.pos.set(key, fresh); this.pushFront(fresh);
  }
}
```
]

#trick[
*The JavaScript-only shortcut.* A `Map` already remembers insertion order, and
`map.keys().next().value` gives the oldest key in $O(1)$. So an LRU can be written with a
`Map` alone: on a hit, `map.delete(key)` then `map.set(key, val)` to move the entry to the
back; when full, delete the first key. It is six lines and it is genuinely $O(1)$.

Show the doubly linked list *first* — the interviewer is testing whether you know why the
list is needed — then offer the `Map` version as "and in JavaScript I would ship this".
That answer scores on both counts.
]
Real output for capacity 2: put(1,10), put(2,20), get(1), put(3,30), get(2), put(1,99),
get(42); then capacity 1:
```
2:20 1:10
10
1:10 2:20
-1  3:30 1:10
1:99 3:30
-1
-1 6 6:6
```
The `dump` shows the use order, most recent first. After `get(1)` the order flips. Putting
key 3 evicts key 2, so `get(2)` returns $-1$.
]
#complexity(time: $O(1)$ + " per operation", space: $O("capacity")$)

*The idea that unlocked it:* neither structure alone can do it. The map gives $O(1)$
*find*; the list gives $O(1)$ *reorder*. Storing the `key` inside the node is what lets the
eviction remove the map entry without searching.

#trap[
The node must store its own `key`, not just the value. On eviction you hold a `DNode` and
need to delete the matching `Map` entry — without the key you would have to scan the whole
map, and the $O(1)$ claim dies.
]

#trap[
`this.pos.get(key)` returns `undefined` for a missing key, so test `=== undefined`, not
`if (!n)`. A perfectly valid cached node is an object and is always truthy — but if you
ever store plain values instead of nodes, `0`, `""` and `null` are all falsy and a
`if (!n)` test reports "missing" for a key that is present. `Map.prototype.has` is the
explicit alternative.
]

#note[
*Follow-up 1 — "make it thread safe."* One mutex around every operation is correct but
serialises everything; sharding the cache into $S$ independent LRUs by `hash(key) % S`
keeps most operations parallel.

*Follow-up 2 — "now it is LFU (least frequently used)."* Keep one doubly linked list per
frequency count, plus a pointer to the smallest non-empty frequency. Promoting a key moves
its node from the list for count $c$ to the list for count $c+1$ — still $O(1)$.
]

#ex(24, tier: 3, asked: "Google · pattern")[
*Drop every node that is dominated on its right.* Remove each node that has a strictly
greater value somewhere after it. `12 15 10 11 5 6 2 3` becomes `15 11 6 3`.
Constraints: $O(1)$ extra space is the follow-up; up to $10^5$ nodes.
Edge cases: strictly increasing input (only the last node survives); strictly decreasing
(all survive); all equal (all survive).
]
#sol[

#approach(1, "For each node, scan the rest", verdict: "O(n^2)")

#approach(2, "Push everything onto a stack", verdict: "O(n) time, O(n) space")
This is the monotonic stack of Chapter 8, and in JavaScript the stack is just an array with
`push` and `pop`. It works, but it copies the list into an array.

#approach(3, "Reverse, sweep once, reverse back", verdict: "O(n) time, O(1) space — optimal")
Reversed, the rule becomes "keep a node only if it is at least as big as everything seen so
far" — a single running maximum. Reverse the survivors back at the end.

#code(lang: "js", caption: "keep the right-to-left maxima")[
```js
const keepRightMaxima = (head) => {
  head = reverseList(head);
  let best = -Infinity;                  // the neutral value for a maximum
  const dummy = new Node(0);
  let tail = dummy;
  for (let p = head; p; p = p.next)
    if (p.val >= best) { best = p.val; tail.next = p; tail = p; }
  tail.next = null;
  return reverseList(dummy.next);
};
```
]
Real output for `12 15 10 11 5 6 2 3`; `1 2 3`; `3 2 1`; `5 5 5`:
```
15 -> 11 -> 6 -> 3
3
3 -> 2 -> 1
5 -> 5 -> 5
```
]
#complexity(time: $O(n)$, space: $O(1)$)

*The idea that unlocked it:* "is anything to my right bigger?" is hard going forwards and
trivial going backwards. On an array you would use a stack; on a list, reversing is free
and removes the stack entirely.

#trap[
Use `>=`, not `>`. With `>` the input `5 5 5` keeps only one node, but no 5 is *strictly*
greater than another 5, so all three must survive. Equal values are the test case that
separates a correct answer from a nearly correct one.
]

#note[
`-Infinity` is the right starting value for a maximum in JavaScript — it is a real number
and it loses every comparison. Starting at `0` is a bug the moment every value is negative.
There is no `INT_MIN` here and you do not need one.
]

#note[
*Follow-up:* "now report, for each surviving node, how many nodes it swallowed." Keep a
counter that resets each time a new maximum is kept. Same pass, same complexity.
]

#ex(25, tier: 3, asked: "Goldman Sachs · pattern")[
*Prove and use the cycle arithmetic.* You already found the meeting point of the fast and
slow pointers. Answer these, as the interviewer will ask them one by one.
(a) Why must they meet at all? (b) Why does walking from the head find the entrance?
(c) How do you measure the loop length? (d) Can the slow pointer lap the fast one?
]
#sol[
*(a) Why they must meet.* Once both pointers are inside the loop, look at the distance
from fast to slow measured *forwards around the loop*. Each move, slow advances 1 and fast
advances 2, so that distance falls by exactly 1 every move. A non-negative whole number
that falls by 1 each step must reach 0. At 0 they are on the same node. It can never jump
over, because the gap changes by exactly 1, never 2.

*(b) Why the head walk works.* Let $mu$ be the number of nodes before the loop and
$lambda$ the loop length. At the meeting point slow has taken $s$ steps and fast $2s$.
Fast's extra distance is a whole number of laps, so
$ 2s - s = s = m lambda $
for some whole number $m$. Slow is $s - mu$ nodes into the loop. Walking $mu$ more steps
puts it $s = m lambda$ nodes into the loop, which is the entrance again. A pointer starting
at the head also arrives at the entrance after exactly $mu$ steps. Same node, same step.

*(c) The loop length.* Stay at the meeting point and walk forward, counting, until you
return to it. That count is $lambda$.

*(d) Can slow lap fast?* No. Slow enters the loop having taken $mu$ steps; at that moment
fast has taken $2 mu$ steps, so fast is already inside. From then on the gap only shrinks,
so they meet within $lambda$ more moves. Slow therefore walks at most $mu + lambda <= n$
steps in total — the whole algorithm is $O(n)$.

The code for (a)–(c) is in Example 7. Real output on a 5-node list with `5 -> 2`:
```
1 2 4
```
— a loop exists, it starts at the node holding 2, and its length is 4.
]

#note[
*Follow-up:* "now there are two lists and you must say whether they share a *loop*." Detect
each list's loop entrance. If either has none, the answer is no. If both do, walk one
entrance around its loop: if you meet the other entrance, they share the loop.
]

#ex(26, tier: 3, asked: "D. E. Shaw · pattern")[
*The full reversal family.* Given one list, produce: (a) the whole list reversed; (b)
reversed in groups of $k$; (c) alternate groups of $k$ reversed; (d) reversed between
positions $l$ and $r$ only. All in $O(1)$ space.
Constraints: $1 <= l <= r <= n <= 10^5$.
Edge cases: $l = 1$ (the head moves); $l = r$ (no change); $k > n$.
]
#sol[
All four are the *same* head-insertion loop with a different anchor and a different stop
rule. Once you see that, you write any of them in two minutes.

#table(
  columns: (0.8fr, 1.3fr, 1.3fr),
  [*variant*], [*anchor*], [*stop rule*],
  [whole list], [dummy], [end of list],
  [groups of k], [previous group's tail], [k nodes, only if k exist],
  [alternate groups], [same, with a flag], [reverse, then skip k],
  [positions l..r], [node at l−1], [r − l insertions],
)

For (d), walk to the node just before position $l$, then do exactly $r - l$ head
insertions. That is the group loop with `k = r - l + 1` and no outer `while`.

#code(lang: "js", caption: "(d) reverse positions l..r only")[
```js
const reverseBetween = (head, l, r) => {
  if (!head || l >= r) return head;
  const dummy = new Node(0);
  dummy.next = head;
  let anchor = dummy;
  for (let i = 1; i < l; i++) { if (!anchor.next) return head; anchor = anchor.next; }
  const prev = anchor.next;
  if (!prev) return head;
  let cur = prev.next;
  for (let i = 0; i < r - l && cur; i++) {
    prev.next = cur.next;
    cur.next = anchor.next;
    anchor.next = cur;
    cur = prev.next;
  }
  return dummy.next;
};
```
]
Real output for `1 2 3 4 5` with $l=2, r=4$; the whole list ($l=1, r=5$); a no-op
($l=r=2$); an `r` past the end; and `null`:
```
1 -> 4 -> 3 -> 2 -> 5
5 -> 4 -> 3 -> 2 -> 1
1 -> 2 -> 3
3 -> 2 -> 1
(empty)
```
Real outputs for (a) are in Example 3, and for (b) and (c) in Example 20.
]

#note[
*Follow-up the interviewer asks next:* "and if it is a doubly linked list?" Then reversing
is even shorter: walk the list and swap each node's `prev` and `next` with the destructuring
swap `[p.prev, p.next] = [p.next, p.prev]`, then return the old tail. One pass, $O(1)$
space, no three-pointer dance.
]

#section[Dry run — reverse in groups of k, line by line]

Input `1 -> 2 -> 3 -> 4 -> 5`, `k = 3`. The anchor `groupPrev` starts at the dummy node,
written `D`.

*Group 1.* The check walks `D, 1, 2, 3` — three nodes past the anchor exist, so proceed.
`prev` = node 1 (it will end up as the group's tail), `cur` = node 2.

#table(
  columns: (0.5fr, 1.1fr, 1.6fr, 1.7fr),
  align: (center, center, left, left),
  [*i*], [*cur*], [*what happens*], [*list after*],
  [1], [2], [2 jumps in front of 1], [D → 2 → 1 → 3 → 4 → 5],
  [2], [3], [3 jumps in front of 2], [D → 3 → 2 → 1 → 4 → 5],
)

The three statements inside the loop, for `i = 1`:
+ `prev.next = cur.next;` → node 1 now points to node 3. List: `D → 1 → 3 → 4 → 5`
  with node 2 held by `cur`.
+ `cur.next = groupPrev.next;` → node 2 points to node 1.
+ `groupPrev.next = cur;` → the dummy points to node 2. List: `D → 2 → 1 → 3 → 4 → 5`.
+ `cur = prev.next;` → `cur` becomes node 3, the next one to pull forward.

After the loop, `groupPrev = prev` = node 1, which is now the tail of the reversed group.

*Group 2.* The check walks from node 1: `1, 4, 5, null`. It runs out after two nodes,
so `check` is `null` and the loop breaks. Nodes 4 and 5 stay in their original order.

*Result:* `3 -> 2 -> 1 -> 4 -> 5`. The verified run with `1..7` and `k = 3` gives
`3 -> 2 -> 1 -> 6 -> 5 -> 4 -> 7`, which matches this reasoning exactly.

#table(
  columns: (0.8fr, 1fr, 1fr, 1.6fr),
  align: (center, center, center, left),
  [*group*], [*groupPrev*], [*k nodes left?*], [*list after the group*],
  [1], [D], [yes (1,2,3)], [D → 3 → 2 → 1 → 4 → 5],
  [2], [node 1], [no (only 4,5)], [unchanged, loop ends],
)

#trap[
The check loop `for (let i = 0; i < k && check; i++) check = check.next;` starts at
`groupPrev`, *not* at `groupPrev.next`. Starting one node later makes it accept a group of
$k-1$ nodes and the tail comes out reversed when it should not be.
]

#section[Practice]

#practice(tier: 0, time: "20 min")[
+ Count the nodes in a list, iteratively and recursively.
+ Delete the middle node (the second middle when the count is even). Return the new head.
  What should a one-node list return?
+ Return the $n$-th node from the end, or `null` if $n$ is larger than the list.
+ Are two lists identical in both length and values?
+ Move the last node to the front: `1 2 3 4` becomes `4 1 2 3`.
]

#practice(tier: 1, time: "45 min")[
6. Remove *every* node whose value equals `val` (not just the first).
7. Put all even values before all odd values, keeping the order inside each group.
   Careful with negative numbers.
8. Rotate the list *left* by $k$ places.
9. A number is stored most-significant-digit first. Add 1 to it and return the new list.
10. Split a list into two halves and return both heads. For an odd count the front half
    gets the extra node.
]

#practice(tier: 2, time: "50 min")[
11. Merge two sorted lists *recursively*, in $O(1)$ extra space beyond the recursion.
12. Given a sorted list, build a balanced binary search tree from it in $O(n)$ time.
    (Hint: build the left subtree first, while walking the list forward once.)
13. Remove every continuous run of nodes that sums to zero. `1 2 -3 3 1` becomes `3 1`.
]

#practice(tier: 3, time: "60 min")[
14. Sort a list that is known to have at most $k$ elements out of place, in
    $O(n log k)$ time.
15. You are given a list and a number $k$. Swap the $k$-th node from the start with the
    $k$-th node from the end — swapping the *nodes*, not the values. Handle the case where
    the two are the same node and the case where they are neighbours.
16. Given two sorted lists, return a new list holding the values that appear in *both*,
    with no duplicates, in $O(n + m)$ time and no hash map.
]

#key[
*1.* Iterative is the `length` helper on page one. Recursive:
`const count = (h) => h ? 1 + count(h.next) : 0;` — and warn out loud that $10^5$ frames
throw `RangeError: Maximum call stack size exceeded` in Node, so the iterative version is
the one you submit.

*2.* Fast and slow, with `prev` trailing `slow`.
#code(lang: "js", caption: "P2")[
```js
const deleteMiddle = (head) => {
  if (!head || !head.next) return null;
  let slow = head, fast = head, prev = null;
  while (fast && fast.next) { prev = slow; slow = slow.next; fast = fast.next.next; }
  prev.next = slow.next;
  return head;
};
```
]
Real output: `1 2 3 4 5` → `1 -> 2 -> 4 -> 5`; `1 2 3 4` → `1 -> 2 -> 4`; a one-node list
and `null` both return `null`.

*3.* Head start of $n$, then walk together.
#code(lang: "js", caption: "P3")[
```js
const nthFromEnd = (head, n) => {
  let fast = head;
  for (let i = 0; i < n; i++) { if (!fast) return null; fast = fast.next; }
  let slow = head;
  while (fast) { fast = fast.next; slow = slow.next; }
  return slow;
};
```
]
Real output on `1 2 3 4 5`: $n=2$ → `4`, $n=5$ → `1`, $n=6$ → `null`.

*4.* Walk together; both must end at `null` at the same time.
#code(lang: "js", caption: "P4")[
```js
const identical = (a, b) => {
  while (a && b) { if (a.val !== b.val) return false; a = a.next; b = b.next; }
  return a === null && b === null;
};
```
]
Real output: `1 0 0 1` for the four tests (equal, different value, different length, both
empty).

*5.* Walk to the last node while holding its predecessor.
#code(lang: "js", caption: "P5")[
```js
const lastToFront = (head) => {
  if (!head || !head.next) return head;
  let prev = null, p = head;
  while (p.next) { prev = p; p = p.next; }
  prev.next = null; p.next = head;
  return p;
};
```
]
Real output: `1 2 3 4` → `4 -> 1 -> 2 -> 3`; `9` → `9`.

*6.* Dummy node, and do not advance on a delete.
#code(lang: "js", caption: "P6")[
```js
const removeAll = (head, val) => {
  const dummy = new Node(0);
  dummy.next = head;
  for (let p = dummy; p.next; ) {
    if (p.next.val === val) p.next = p.next.next;
    else p = p.next;
  }
  return dummy.next;
};
```
]
Real output: `1 2 1 3 1` remove 1 → `2 -> 3`; `5 5 5` remove 5 → empty; `1 2` remove 9 →
unchanged.

*7.* Two chains, then glue — the same shape as `partitionAround`.
#code(lang: "js", caption: "P7")[
```js
const evenThenOdd = (head) => {
  const ev = new Node(0), od = new Node(0);
  let e = ev, o = od;
  for (let p = head; p; p = p.next) {
    if (p.val % 2 === 0) { e.next = p; e = p; } else { o.next = p; o = p; }
  }
  o.next = null; e.next = od.next;
  return ev.next;
};
```
]
Real output: `1 2 3 4 5 6` → `2 -> 4 -> 6 -> 1 -> 3 -> 5`; `1 3 5` → unchanged;
`-2 -3 0` → `-2 -> 0 -> -3`.
#trap[
In JavaScript, `-3 % 2` is `-1`, not `1` — I checked it in Node. So `p.val % 2 === 1` is
*false* for negative odd numbers and they are misfiled as even. Always test `% 2 === 0`
for even, or `% 2 !== 0` for odd. (`%` on negatives behaves the same way in C++ and Java,
and *differently* in Python, where `-3 % 2` is `1`.)
]

*8.* Same ring trick as `rotateRight`, but the new tail is $k$ nodes in from the front.
#code(lang: "js", caption: "P8")[
```js
const rotateLeft = (head, k) => {
  if (!head || !head.next || k <= 0) return head;
  let n = 1, tail = head;
  while (tail.next) { tail = tail.next; n++; }
  k %= n; if (k === 0) return head;
  let newTail = head;
  for (let i = 1; i < k; i++) newTail = newTail.next;
  const newHead = newTail.next;
  newTail.next = null;
  tail.next = head;
  return newHead;
};
```
]
Real output: `1 2 3 4 5` with $k=2$ → `3 -> 4 -> 5 -> 1 -> 2`; `1 2 3` with $k=3$ →
unchanged; with $k=7$ → `2 -> 3 -> 1`.

*9.* Reverse, add the carry, reverse back.
#code(lang: "js", caption: "P9")[
```js
const plusOne = (head) => {
  head = reverseList(head);
  let carry = 1, p = head, last = null;
  while (p && carry) {
    const s = p.val + carry;
    p.val = s % 10; carry = Math.floor(s / 10);
    last = p; p = p.next;
  }
  if (carry) last.next = new Node(carry);
  return reverseList(head);
};
```
]
Real output: `1 2 3` → `1 -> 2 -> 4`; `9 9 9` → `1 -> 0 -> 0 -> 0`; `0` → `1`.

*10.* Fast and slow with `fast = head.next` gives the first middle; cut after it.
`slow.next` is the second head, then set `slow.next = null`. Return both heads as an array
and unpack them with `const [a, b] = splitHalves(head);`.

*11.* Recursive merge — shorter to write, but the stack is the price.
#code(lang: "js", caption: "P11")[
```js
const mergeRec = (x, y) => {
  if (!x) return y;
  if (!y) return x;
  if (x.val <= y.val) { x.next = mergeRec(x.next, y); return x; }
  y.next = mergeRec(x, y.next); return y;
};
```
]
Real output: `1 3 5` with `2 4` → `1 -> 2 -> 3 -> 4 -> 5`; `null` with `7` → `7`;
both empty → empty. Time $O(n+m)$, stack $O(n+m)$ — and in JavaScript that stack is the
whole objection: $n + m$ above roughly $10^4$ throws
`RangeError: Maximum call stack size exceeded`. Give the iterative version first.

*12.* Recurse on the *count*, not on the nodes. Build the left subtree from the first
$n\/2$ items, then take the current list node as the root and advance the list pointer,
then build the right subtree. One forward walk, $O(n)$ total.

*13.* Prefix sums with a `Map` from running sum to node. If the same running sum appears
twice, everything between them sums to zero, so link the first node straight to the node
after the second. Use a dummy head so a run starting at the head is handled too.
$O(n)$ time and space.

*14.* The toolkit `MinHeap` (JavaScript has none built in), holding $k+1$ nodes: push the
first $k+1$, then repeatedly pop the smallest, append it, and push the next node. An element
that is at most $k$ places out of place is guaranteed to be inside the heap when its turn
comes. $O(n log k)$.

*15.* Walk to the two nodes *and* their predecessors, handle `k == n - k + 1` (same node,
do nothing) and the neighbour case (their predecessors are each other) separately, then
swap the four pointers. Swapping values is a one-liner but is usually rejected — the
question says swap the nodes.

*16.* Walk both lists like a merge. When the values are equal, append a *new* node with
that value and skip *both*; to avoid duplicates in the output, also skip while the next
value equals the one just appended. When they differ, advance the smaller one.
$O(n + m)$, no `Map` and no `Set`.
]

#revision[
*The node and the three reflexes.*
#code(lang: "js", caption: "memorise these")[
```js
class Node { constructor(val) { this.val = val; this.next = null; } }

// dummy head: makes "delete/insert at the head" the same code as anywhere else
const dummy = new Node(0); dummy.next = head; /* ... */ return dummy.next;

// reverse
let prev = null, cur = head;
while (cur) { const nxt = cur.next; cur.next = prev; prev = cur; cur = nxt; }
// prev is the new head

// fast and slow
let slow = head, fast = head;               // 2nd middle
while (fast && fast.next) { slow = slow.next; fast = fast.next.next; }
// use fast = head.next for the 1st middle (splitting, reorder, merge sort)
```
]

*Which move solves which problem.*
#table(
  columns: (1.4fr, 1fr, 0.8fr),
  [*problem*], [*move*], [*space*],
  [reverse, reverse in groups, reverse l..r], [three pointers / head insertion], [$O(1)$],
  [middle, delete middle, split in half], [fast + slow], [$O(1)$],
  [loop detect / start / length / remove], [fast + slow (Floyd)], [$O(1)$],
  [n-th from the end, remove n-th from the end], [head start of n], [$O(1)$],
  [palindrome], [middle + reverse half + restore], [$O(1)$],
  [merge two sorted, merge K, flatten], [dummy + tail, toolkit `MinHeap` for K], [$O(1)$ / $O(k)$],
  [sort a list], [merge sort, 1st middle], [$O(log n)$],
  [partition, odd/even split], [two chains + glue], [$O(1)$],
  [intersection of two lists], [length difference, or pointer swap], [$O(1)$],
  [copy with random pointers], [weave, wire, unweave], [$O(1)$],
  [LRU cache], [`Map` + doubly linked list], [$O("cap")$],
  [drop dominated nodes], [reverse, running max, reverse], [$O(1)$],
)

*Top traps.*
+ Forgetting the dummy node when the head can change.
+ `while (fast && fast.next)` — that order, always. The other order throws
  `TypeError: Cannot read properties of null`.
+ `fast = head` gives the 2nd middle; `fast = head.next` gives the 1st. Merge sort and
  reorder need the *1st*, or they never terminate.
+ Advancing the pointer on the same step you delete a node.
+ Forgetting `tail.next = null` after splitting or partitioning — silent infinite loop.
+ `while (a || b || carry)` in list addition. Losing `|| carry` loses the leading digit.
+ `carry = s / 10` gives `1.9`. JavaScript has no integer division: use
  `Math.floor(s / 10)`.
+ In `reverseRec`, set `head.next.next = head;` *before* `head.next = null;`.
+ `-3 % 2 === -1` in JavaScript, so test `% 2 === 0` for even, never `% 2 === 1` for odd.
+ `removeCycle` must null the node *pointing at* the entrance, not the entrance itself.
+ *Recursion depth is about $10^4$ in Node* — I measured 12546. A $10^5$-node list plus
  recursion equals `RangeError: Maximum call stack size exceeded`. Offer the iterative
  version first, every time.
+ *No built-in heap.* Merging K lists needs the toolkit `MinHeap`, and
  `(a, b) => a.val - b.val` is the min-heap comparator — flip the sign and you get a
  max-heap by accident.
+ *`arr.sort()` is lexicographic.* Any "copy to an array and sort" approach needs
  `(a, b) => a - b`.
+ Comparing nodes with `===` (identity), never by value.
+ Deleting a node given only a reference to it fails on the *last* node — say so out loud.

*Complexity you should be able to quote instantly.*
Reverse, middle, cycle, n-th from end, merge two: $O(n)$ time, $O(1)$ space.
Merge sort a list: $O(n log n)$ time, $O(log n)$ stack. Merge K lists: $O(N log k)$.
Copy with random references: $O(n)$ time, $O(1)$ extra. LRU: $O(1)$ per operation.

*From the JS Toolkit appendix, this chapter uses:* `MinHeap`, for merging K sorted lists.
Everything else here is plain objects and references.
#code(lang: "js", caption: "the one import this chapter needs")[
```js
const { MinHeap } = require('./toolkit.js');
```
]
]

]
