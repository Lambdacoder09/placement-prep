#import "../../shared/lib/style.typ": *

#chapter(num: 16, title: "Graphs II — Shortest Paths, MST & Topological Sort",
  tagline: "Now the edges carry numbers. Pick the right algorithm and the code is short.")[

#section[Pattern in one page]

Chapter 15 had roads with no length. Every step cost 1, so BFS answered everything.
Now each edge carries a *weight*: a price, a distance, a delay. BFS is no longer enough.

#formulas(title: "The one operation behind every shortest-path algorithm")[
*Relaxation.* You hold a best-known distance `d[v]` for every node. For an edge
$u -> v$ of weight $w$:
```js
if (d[u] + w < d[v]) d[v] = d[u] + w;
```
"I found a cheaper way to reach $v$: go to $u$ first, then take this edge."

Every algorithm below is just a different *order* of doing relaxations.
]

#subsection[Storing a weighted graph]

An edge is a two-element array `[to, weight]`, so the loop body destructures straight
into named variables. The whole graph is an array of such arrays.

#code(lang: "js", caption: "Weighted adjacency list")[
```js
const buildW = (n, E, directed) => {
  const g = Array.from({ length: n }, () => []);
  for (const [u, v, w] of E) {          // e = [from, to, weight]
    g[u].push([v, w]);
    if (!directed) g[v].push([u, w]);
  }
  return g;
};
```
]

#trap[
*Do not write `new Array(n).fill([])`.* `fill` stores the *same* array object in every
slot, so pushing an edge into `g[0]` pushes it into all $n$ lists at once. Use
`Array.from({ length: n }, () => [])`, which calls the factory once per slot.

The same shallow-copy rule bites a grid: `[...grid]` copies the outer array but shares
every row. A real copy is `grid.map(r => [...r])`.
]

#trap[
*JavaScript numbers are doubles, exact only to `Number.MAX_SAFE_INTEGER` $= 2^53 - 1
approx 9.0 times 10^15$.* Nothing in this chapter passes that line — $10^5$ edges of
weight $10^9$ cap a path at $10^14$ — so plain numbers are correct throughout. Verified:
`3e9 + 3e9` prints `6000000000` exactly, and a 3-node MST of two `3e9` cables returns
`6000000000`.

Past $2^53$ you need `BigInt`: `2n ** 60n` is exact, while `2 ** 60` is not. Say this out
loud when an interviewer asks about "overflow" in JavaScript — the answer is *precision
loss*, not wraparound. There is no `int` and no 64-bit integer type; the only two number types
are `Number` and `BigInt`.
]

#subsection[Choose the algorithm from the constraints]

This table is the most useful thing in the chapter. Learn it.

#table(columns: (1fr, auto, auto, 1fr),
  [*You are asked*], [*Weights*], [*Algorithm*], [*Time*],
  [one source → all nodes], [all $>= 0$], [Dijkstra with a heap], [$O((n+m) log n)$],
  [one source → all nodes], [some negative], [Bellman-Ford], [$O(n m)$],
  [one source → all nodes], [all equal to 1], [BFS], [$O(n+m)$],
  [one source → all nodes], [only 0 and 1], [0-1 BFS with a deque], [$O(n+m)$],
  [one source → all nodes], [graph is a DAG], [relax in topological order], [$O(n+m)$],
  [*every* pair], [any, $n <= 400$], [Floyd-Warshall], [$O(n^3)$],
  [is there a negative loop?], [any], [Bellman-Ford, one extra pass], [$O(n m)$],
  [cheapest way to link everything], [any], [Kruskal or Prim], [$O(m log m)$],
  [a valid order of dependent jobs], [—], [topological sort], [$O(n+m)$],
)

#subsection[Dijkstra — the template]

#trap[
*JavaScript has no built-in priority queue.* Every shortest-path algorithm in this chapter
needs one, so import the tested `MinHeap` from the *JS Toolkit* appendix. Write that
`require` line once at the top of your solution file and never re-implement a heap under
interview pressure.

The heap stores `[distance, node]` pairs and takes a comparator, so a *max*-heap is the
same class with the comparator flipped: `new MinHeap((a, b) => b[0] - a[0])`. You will
need that for the widest-path problem later.
]

#code(lang: "js", caption: "Dijkstra with a min-heap. Memorise this.")[
```js
const { MinHeap, DSU, Deque } = require('./toolkit.js');   // JS Toolkit appendix

const dijkstra = (n, g, src) => {
  const d = new Array(n).fill(Infinity);
  const pq = new MinHeap((a, b) => a[0] - b[0]);   // [dist, node]
  d[src] = 0;
  pq.push([0, src]);
  while (pq.size) {
    const [du, u] = pq.pop();
    if (du > d[u]) continue;                       // stale copy, skip it
    for (const [v, w] of g[u]) {
      if (du + w < d[v]) {
        d[v] = du + w;
        pq.push([d[v], v]);
      }
    }
  }
  return d;
};
```
]

#trick[
Use `Infinity`, not a big finite sentinel, for "unreached". `Infinity + w` is still
`Infinity`, and `Infinity < Infinity` is false, so an unreachable node can never be
relaxed by accident. In C++ this is the classic `INF + w` overflow bug; JavaScript hands
you the fix for free. Verified: seeding a Bellman-Ford with
`Number.MAX_SAFE_INTEGER` instead lets the edge `2 -> 3` of weight $-5$ invent a finite
distance for an unreachable node, while the `Infinity` version leaves it untouched.
]

#formulas(title: "The Dijkstra invariant — and why negatives break it")[
When a node is popped with `du == d[u]`, that distance is *final*. The reason: every
remaining edge has weight $>= 0$, so no route through a node that is still in the heap
(and therefore already costs at least `du`) can arrive cheaper.

A single negative edge destroys that reason, and the algorithm gives wrong answers.
]

Here is the failure, actually run. Graph: `0->1 (2)`, `0->2 (5)`, `2->1 (-4)`, `1->3 (1)`.
Most people write Dijkstra with a `done[]` array — settle a node once, never look at it
again — so that is the version shown failing.

#code(lang: "text", caption: "Real output — the settled version is wrong on nodes 1 and 3")[
```text
settled Dijkstra : 0 2 5 3
truth (Bellman)  : 0 1 5 2
```
]
It locked node 1 at distance 2 and immediately set `d[3] = 3`. Later the edge
`2->1` offered `5 - 4 = 1`, but node 1 was already marked done, so neither it nor node 3
was ever revisited.

#note[
*Be precise about this in an interview.* The *lazy* template above — no `done[]` array,
only `if (du > d[u]) continue;` — happens to recover the right answer on this particular
graph, because a node whose distance drops is simply pushed again. That is not a
defence: with negative edges that re-pushing can blow up to exponentially many pops, and
the algorithm is no longer Dijkstra, it is a slow Bellman-Ford. The rule stands: *one
negative edge means Bellman-Ford.*
]

#trap[
*A JavaScript comparator must return a number, not a boolean.* `(a, b) => a[0] > b[0]`
yields `true`/`false`, which coerce to `1`/`0` — the heap never sees a negative value and
its ordering collapses. Write `(a, b) => a[0] - b[0]`. The same rule governs
`arr.sort`, which you will meet in Kruskal in a moment.
]

#trap[
Do *not* write `if (done[u]) continue; done[u] = true;` *and* also forget the
`du > d[u]` check — pick one. The lazy `du > d[u]` test is the safer habit, because it
never needs an extra array.
]

#subsection[Topological order — the template]

A *DAG* is a directed graph with no cycle. A *topological order* lists its nodes so that
every arrow points forward in the list.

#code(lang: "js", caption: "Kahn's algorithm (BFS style)")[
```js
const topoKahn = (n, g) => {
  const indeg = new Array(n).fill(0);
  for (let u = 0; u < n; u++) for (const v of g[u]) indeg[v]++;
  const pq = new MinHeap();                        // default comparator: smallest id first
  for (let i = 0; i < n; i++) if (indeg[i] === 0) pq.push(i);
  const order = [];
  while (pq.size) {
    const u = pq.pop();
    order.push(u);
    for (const v of g[u]) if (--indeg[v] === 0) pq.push(v);
  }
  return order.length === n ? order : [];          // short -> some node never hit 0 -> cycle
};
```
]

#trick[
Kahn gives cycle detection for free. If the output is shorter than $n$, the leftover
nodes all sit on or after a cycle. Swap the `MinHeap` for the toolkit `Deque` used as a
plain queue when you do not care about ties — it is faster and the answer is still valid.
]

#trap[
Kahn never recurses, so it is the *safe* topological sort at $n = 10^5$. The DFS version
later in this chapter recurses once per node, and Node's stack gives out at roughly
$10^4$ frames: a 100000-node chain throws `RangeError: Maximum call stack size exceeded`.
That was verified, not guessed. When the constraint says $n <= 10^5$, reach for Kahn.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
Relax the edge $u -> v$ with weight 7, given `d[u] = 4` and `d[v] = 13`.
What is `d[v]` afterwards?
]
#sol[
$d[u] + w = 4 + 7 = 11$. Is $11 < 13$? Yes. So `d[v]` becomes 11.
#ans[11]
]

#ex(2, tier: 0)[
Same edge, but now `d[v] = 9`.
]
#sol[
$4 + 7 = 11$, and $11 < 9$ is false. Nothing changes.
#ans[9, unchanged]
]

#ex(3, tier: 0)[
A directed graph has `0->1 (4)`, `0->2 (1)`, `2->1 (2)`, `1->3 (1)`, `2->3 (5)`, and a
lone node 4. Compute the shortest distances from node 0 by hand.
]
#sol[
+ `d[0] = 0`.
+ Direct edges: `d[1] = 4`, `d[2] = 1`.
+ Through 2: $1 + 2 = 3 < 4$, so `d[1] = 3`.
+ To 3: through 1 costs $3 + 1 = 4$; through 2 costs $1 + 5 = 6$. Keep 4.
+ Node 4 is unreachable.

Verified by running both Dijkstra versions: `0 3 1 4 INF`.
#ans[`0 3 1 4 INF`]
]

#ex(4, tier: 0)[
Compute the in-degree of every node for the DAG
`5->0, 5->2, 4->0, 4->1, 2->3, 3->1`, with $n = 6$.
]
#sol[
Walk the arrow list and add 1 to the *head* of each arrow.

#table(columns: 7,
  [node], [0], [1], [2], [3], [4], [5],
  [in-degree], [2], [2], [1], [1], [0], [0],
)
#ans[`2 2 1 1 0 0`]
]

#ex(5, tier: 0)[
Using the in-degrees above, list a valid topological order. Always take the smallest
ready node.
]
#sol[
Ready at the start: `{4, 5}` (in-degree 0).
#table(columns: (auto, auto, 1fr, auto),
  [*step*], [*take*], [*in-degrees that drop*], [*ready set after*],
  [1], [4], [0 → 1, 1 → 1], [`{5}`],
  [2], [5], [0 → 0, 2 → 0], [`{0, 2}`],
  [3], [0], [none], [`{2}`],
  [4], [2], [3 → 0], [`{3}`],
  [5], [3], [1 → 0], [`{1}`],
  [6], [1], [none], [`{}`],
)
Verified real output: `4 5 0 2 3 1`.
#ans[`4 5 0 2 3 1`]
]

#ex(6, tier: 0)[
Why can Dijkstra not be trusted when one edge has weight $-4$? Answer with the graph
`0->1 (2)`, `0->2 (5)`, `2->1 (-4)`, `1->3 (1)`.
]
#sol[
Dijkstra pops the *cheapest* node and declares it finished. Node 1 looks like distance 2,
so it is finished, and `d[3]` is written as 3.

Only later does the route `0 -> 2 -> 1` (cost $5 - 4 = 1$) appear. Node 1 gets a better
value, but node 3 was already processed and is never revisited.

Real output from the settled version: `0 2 5 3`; the truth is `0 1 5 2`.
#ans[because "cheapest so far" stops being "cheapest ever" when edges can subtract]
]

#section[Tier 1 — the standard weighted questions]
#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
*Shortest distance from one city to all others.*
$n$ cities, $m$ two-way roads with positive lengths. Print the distance from city 0 to
every city, or $-1$ where there is no route.

Constraints: $n <= 10^5$, $m <= 2 times 10^5$, weight $<= 10^9$.
Edge cases: an unreachable city; $n = 1$.
]
#sol[
#approach(1, "Scan for the closest unfinished node", verdict: "O(n^2) — fine only to n = 5000")

#code(lang: "js", caption: "Dijkstra without a heap")[
```js
const dijkstraSimple = (n, g, src) => {
  const d = new Array(n).fill(Infinity);
  const done = new Array(n).fill(false);
  d[src] = 0;
  for (let it = 0; it < n; it++) {
    let u = -1;
    for (let i = 0; i < n; i++)
      if (!done[i] && (u === -1 || d[i] < d[u])) u = i;
    if (u === -1 || d[u] === Infinity) break;
    done[u] = true;
    for (const [v, w] of g[u])
      if (d[u] + w < d[v]) d[v] = d[u] + w;
  }
  return d;
};
```
]
#complexity(time: $O(n^2 + m)$, space: $O(n)$,
  note: "Actually the better choice when the graph is dense, m near n^2.")

#approach(2, "Min-heap Dijkstra", verdict: "O((n+m) log n) — optimal for sparse graphs")
Use the template from page one. Both versions were run on the graph of Warm-up 3 and both
printed `0 3 1 4 INF`.

#complexity(time: $O((n+m) log n)$, space: $O(n + m)$)

*The idea that unlocked it:* the $O(n^2)$ version spends all its time *searching* for the
minimum. A heap does that search in $log n$ instead of $n$.

#trap[
Print $-1$, not `Infinity`, for unreachable nodes. Forgetting the conversion is the single
most common submission failure on this problem — and in JavaScript it bites twice, because
`JSON.stringify(Infinity)` silently becomes `null`. Map the array before you print:
`d.map(x => x === Infinity ? -1 : x)`.
]
#ans[`0 3 1 4 -1`]
]

#ex(8, tier: 1, asked: "Infosys · pattern")[
*Print the route, not just its length.*
Same input. Print the actual list of cities on one shortest route from `src` to `dst`.
Edge cases: no route (print nothing); `src == dst` (print just that city).
]
#sol[
Every time a relaxation succeeds, remember *who* caused it. Then walk the parents
backwards from the destination and reverse.

#code(lang: "js", caption: "Dijkstra plus a parent array")[
```js
const shortestPathNodes = (n, g, src, dst) => {
  const d = new Array(n).fill(Infinity);
  const par = new Array(n).fill(-1);
  const pq = new MinHeap((a, b) => a[0] - b[0]);
  d[src] = 0; pq.push([0, src]);
  while (pq.size) {
    const [du, u] = pq.pop();
    if (du > d[u]) continue;
    for (const [v, w] of g[u])
      if (du + w < d[v]) {
        d[v] = du + w;
        par[v] = u;                          // remember the winner
        pq.push([d[v], v]);
      }
  }
  if (d[dst] === Infinity) return [];        // no route at all
  const path = [];
  for (let v = dst; v !== -1; v = par[v]) path.push(v);
  return path.reverse();
};
```
]
#complexity(time: $O((n+m) log n)$, space: $O(n)$)
Verified on the graph of Warm-up 3: the route from 0 to 3 prints `0 2 1 3`, cost
$1 + 2 + 1 = 4$. The route from 0 to the lone node 4 prints nothing.
#ans[`0 2 1 3`]
]

#ex(9, tier: 1, asked: "Accenture · pattern")[
*Shortest paths when some weights are negative.*
Directed graph, weights may be negative, but you are told there is no negative loop.

Constraints: $n <= 2000$, $m <= 10^4$. Target $O(n m)$.
Edge cases: a node unreachable from the source (must stay `INF`, never
`INF + w`); a graph with no edges.
]
#sol[
*Bellman-Ford.* Relax *every* edge, $n - 1$ times.

#formulas(title: "Why n - 1 rounds is enough")[
A shortest path with no repeated node uses at most $n - 1$ edges. After round $k$, every
shortest path that uses at most $k$ edges has been found. So after $n-1$ rounds you are
done.

If round $n$ still improves something, a path is getting cheaper without limit — that is
a *negative cycle*.
]

#code(lang: "js", caption: "Bellman-Ford with early exit and cycle detection")[
```js
const bellmanFord = (n, E, src) => {
  const d = new Array(n).fill(Infinity);
  d[src] = 0;
  for (let i = 0; i < n - 1; i++) {
    let changed = false;
    for (const [u, v, w] of E)
      if (d[u] + w < d[v]) { d[v] = d[u] + w; changed = true; }
    if (!changed) break;                           // nothing moved: stop early
  }
  for (const [u, v, w] of E)                       // one extra pass
    if (d[u] + w < d[v]) return { ok: false, d };  // still improving -> negative cycle
  return { ok: true, d };
};
```
]
#complexity(time: $O(n m)$, space: $O(n)$)

Verified on `0->1 (4)`, `0->2 (5)`, `2->1 (-3)`, `1->3 (3)`:
returns `ok: true`, distances `0 2 5 5`. On `0->1 (1)`, `1->2 (-1)`, `2->1 (-1)`,
`0->3 (2)`: returns `ok: false`. An empty edge list gives `0 Infinity Infinity`,
and $n = 1$ gives `0`.

#trap[
Most write-ups of Bellman-Ford guard the relaxation with `if (d[u] !== INF && ...)`,
because with a large *finite* sentinel `INF + (-5)` is smaller than `INF` and unreachable
nodes start growing fake distances. In JavaScript that guard is unnecessary *provided you
seed with `Infinity`*: `Infinity + (-5)` is still `Infinity`, and `Infinity < Infinity` is
false. Verified both ways — seeding with `Number.MAX_SAFE_INTEGER` reproduces the bug
exactly (node 3 gets a finite distance from an unreachable node 2); seeding with
`Infinity` leaves it at `Infinity`.

So: seed with `Infinity` and drop the guard, or keep a finite sentinel and keep the
guard. Mixing the two is what fails.
]

#trick[
The `changed` flag usually ends the loop long before $n-1$ rounds, which makes
Bellman-Ford fast in practice even though its worst case is $O(n m)$.
]
#ans[true, `0 2 5 5`]
]

#ex(10, tier: 1, asked: "Wipro · pattern")[
*All pairs at once.*
$n <= 400$. Print the shortest distance between *every* pair of nodes.
Edge cases: parallel edges of different weights (keep the smallest); `d[i][i] = 0`.
]
#sol[
*Floyd-Warshall.* Three nested loops, and the outer loop must be $k$.

#formulas(title: "What the k loop means")[
After the outer loop has finished value $k$, `d[i][j]` is the best route from $i$ to $j$
that is allowed to pass through intermediate nodes taken only from
#box[$\{0, 1, ..., k\}$].

So you add one permitted "stopover" at a time. That is why $k$ must be outermost — if $i$
or $j$ is outermost, the recurrence reads values that have not been prepared yet.
]

#code(lang: "js", caption: "Floyd-Warshall")[
```js
const floyd = (n, E, directed) => {
  const d = Array.from({ length: n }, () => new Array(n).fill(Infinity));
  for (let i = 0; i < n; i++) d[i][i] = 0;
  for (const [u, v, w] of E) {
    d[u][v] = Math.min(d[u][v], w);                // min: parallel edges
    if (!directed) d[v][u] = Math.min(d[v][u], w);
  }
  for (let k = 0; k < n; k++)
    for (let i = 0; i < n; i++) {
      if (d[i][k] === Infinity) continue;          // small test, big speed win
      for (let j = 0; j < n; j++)
        if (d[i][k] + d[k][j] < d[i][j]) d[i][j] = d[i][k] + d[k][j];
    }
  return d;
};
```
]
#complexity(time: $O(n^3)$, space: $O(n^2)$,
  note: "n = 400 gives 6.4 x 10^7 — fast. n = 1000 gives 10^9 — too slow.")

#trap[
Build the matrix with `Array.from({ length: n }, () => new Array(n).fill(Infinity))`.
`new Array(n).fill(new Array(n).fill(Infinity))` looks identical and is catastrophically
wrong: all $n$ rows are the *same* array, so writing `d[0][1]` writes every row's
column 1. `[...row]` has the same flaw one level down.
]

Verified on the directed graph of Warm-up 3 (first 4 nodes):
#code(lang: "text", caption: "Real output")[
```text
F[0]: 0   3   1   4
F[1]: INF 0   INF 1
F[2]: INF 2   0   3
F[3]: INF INF INF 0
```
]

#trick[
After Floyd, `d[i][i] < 0` for some $i$ means a negative cycle passes through $i$.
]
#ans[the table above]
]

#ex(11, tier: 1, asked: "Capgemini · pattern")[
*Cheapest way to wire every office.*
$n$ offices, a list of possible cables each with a price. Choose cables so that all
offices are linked and the total price is smallest. Return the total, or $-1$ if it cannot
be done.

Constraints: $n <= 10^5$, $m <= 2 times 10^5$. Target $O(m log m)$.
Edge cases: the graph is not connected ($-1$); $n = 1$ (answer 0, zero cables).
]
#sol[
This is a *minimum spanning tree* (MST).

#approach(1, "Kruskal — sort the edges, take what fits", verdict: "O(m log m) — optimal")

Sort every cable by price. Walk the sorted list. Take a cable only if its two ends are
still in different groups; DSU answers that in near-constant time.

Use the tested `DSU` from the *JS Toolkit* appendix — its `union(a, b)` returns `false`
when the two ends were already together, which is exactly the test Kruskal needs.

#code(lang: "js", caption: "Kruskal")[
```js
const kruskal = (n, E) => {
  const e = [...E].sort((a, b) => a[2] - b[2]);    // numeric comparator, never a bare sort()
  const d = new DSU(n);
  let total = 0, used = 0;
  for (const [u, v, w] of e)
    if (d.union(u, v)) { total += w; used++; }
  return used === n - 1 ? total : -1;              // fewer edges -> not connected
};
```
]

#trap[
*`arr.sort()` with empty brackets is LEXICOGRAPHIC.* It converts every element to a string
first, so `[10, 9, 1].sort()` gives `[1, 10, 9]`. On an edge list it is worse, because
each edge stringifies whole: sorting
`[[0,1,1],[1,2,2],[0,2,4],[2,3,3],[3,0,10]]` with a bare `.sort()` produces the weight
order `1, 4, 2, 3, 10` — verified — and Kruskal then returns a wrong total. Always
`sort((a, b) => a[2] - b[2])`.

Two companions to that rule: `sort` works *in place* and returns the same array, so copy
with `[...E]` before sorting a caller's list (this code does, and a test confirms the
caller's array comes back untouched); and chain tie-breaks with `||`, as in
`(a, b) => a[2] - b[2] || a[0] - b[0]`, because `0` is falsy.
]
#complexity(time: $O(m log m)$, space: $O(n)$,
  note: "The sort dominates; DSU is almost free.")

#approach(2, "Prim — grow one blob", verdict: "O(m log n), better on dense graphs")

Start at node 0. Repeatedly add the cheapest cable leaving the blob.

#code(lang: "js", caption: "Prim with a min-heap")[
```js
const prim = (n, g) => {
  if (n === 0) return 0;
  const inMst = new Array(n).fill(false);
  const pq = new MinHeap((a, b) => a[0] - b[0]);   // [weight, node]
  pq.push([0, 0]);
  let total = 0, cnt = 0;
  while (pq.size) {
    const [w, u] = pq.pop();
    if (inMst[u]) continue;
    inMst[u] = true; total += w; cnt++;
    for (const [v, ew] of g[u]) if (!inMst[v]) pq.push([ew, v]);
  }
  return cnt === n ? total : -1;
};
```
]
#complexity(time: $O(m log n)$, space: $O(n + m)$)

Verified on `0-1:1, 1-2:2, 0-2:4, 2-3:3, 3-0:10`:
Kruskal and Prim both give *6*, using edges `(0-1,1) (1-2,2) (2-3,3)`.
Disconnected input gives $-1$ from both. A single node gives 0 from both.
Two cables of weight $3 times 10^9$ gave `6000000000` exactly from both — comfortably
inside $2^53 - 1$, so no `BigInt` is needed here.

#formulas(title: "Why greedy is safe here (the cut property)")[
Split the nodes into any two groups. The *cheapest* edge crossing that split is in some
MST.

Kruskal picks exactly such edges: when it takes an edge, the two ends are in different
DSU groups, so that edge is the cheapest one crossing the split "this group versus
everything else".
]

#trap[
Note the `used == n - 1` test at the end. Without it, a disconnected graph quietly returns
the total of several separate trees.
]
#ans[6]
]

#ex(12, tier: 1, asked: "Cognizant · pattern")[
*A valid build order.*
$n$ modules, and pairs `(a, b)` meaning "a must be built before b". Print any valid order,
or say it is impossible.
Edge cases: no dependencies at all (any order works); a two-module loop (impossible).
]
#sol[
Topological sort. Two standard ways; know both.

#approach(1, "Kahn — peel off the ready nodes", verdict: "O(n+m), detects cycles for free")
See the template on page one. Verified: on `5->0, 5->2, 4->0, 4->1, 2->3, 3->1` it prints
`4 5 0 2 3 1`. On a two-node loop it returns an empty list.

#approach(2, "DFS finish order", verdict: "O(n+m), fewer lines")
Run the 3-colour DFS from Chapter 15. Push each node onto a list *when it finishes*, then
reverse the list.

#code(lang: "js", caption: "Topological sort by DFS")[
```js
const topoDFS = (n, g) => {
  const col = new Array(n).fill(0);                // 0 white, 1 grey, 2 black
  const out = [];
  const visit = (u) => {
    col[u] = 1;
    for (const v of g[u]) {
      if (col[v] === 1) return false;              // grey -> cycle
      if (col[v] === 0 && !visit(v)) return false;
    }
    col[u] = 2;
    out.push(u);                                   // push on FINISH
    return true;
  };
  for (let i = 0; i < n; i++)
    if (col[i] === 0 && !visit(i)) return [];
  return out.reverse();
};
```
]

#trap[
*This version recurses, and Node's call stack is only about $10^4$ frames deep.* A
100000-node chain makes it throw `RangeError: Maximum call stack size exceeded` — verified,
not guessed. C++ and Java survive that depth; JavaScript does not. At $n = 10^5$ either
use Kahn (no recursion at all) or rewrite `visit` with an explicit stack of
`[node, edgeIndex]` frames. Say this in the interview before you write the recursive
version — it is exactly the kind of language detail that separates a pass from a fail.
]
#complexity(time: $O(n + m)$, space: $O(n)$)
Verified on the same graph: prints `5 4 2 3 1 0`. Different from Kahn's answer and equally
valid — check each arrow: 5 before 0 and 2, 4 before 0 and 1, 2 before 3, 3 before 1. All
forward.

#note[
When a problem says "print the *lexicographically smallest* valid order", you must use
Kahn with a *priority queue*, as in the template. DFS cannot give you that.
]
#ans[`4 5 0 2 3 1` (or `5 4 2 3 1 0`)]
]

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
*Shortest path in a DAG — in linear time.*
Weights may even be negative, as long as the graph has no cycle.
Edge cases: unreachable nodes stay `INF`.
]
#sol[
No heap needed. Sort the nodes topologically, then relax the edges *in that order*. When
you reach node $u$, every route into $u$ has already been considered, so `d[u]` is final.

#code(lang: "js", caption: "DAG shortest path, O(n + m)")[
```js
const dagShortest = (n, g, src) => {
  const plain = g.map(row => row.map(([v]) => v));   // drop the weights for the sort
  const order = topoDFS(n, plain);
  const d = new Array(n).fill(Infinity);
  d[src] = 0;
  for (const u of order) {
    if (d[u] === Infinity) continue;
    for (const [v, w] of g[u]) d[v] = Math.min(d[v], d[u] + w);
  }
  return d;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n + m)$)
Verified on `0->1 (2)`, `0->4 (1)`, `1->2 (3)`, `4->2 (2)`, `2->3 (6)`, `4->5 (4)`,
`5->3 (1)`: result `0 2 3 6 1 5`.
Check node 3 by hand: through 2 costs $3 + 6 = 9$; through 5 costs $5 + 1 = 6$. The code
says 6. Correct. A negative edge is fine too: `0->1 (-5)` with an unreachable node 2 gives
`0 -5 Infinity`.
#ans[`0 2 3 6 1 5`]
]

#ex(14, tier: 1, asked: "Infosys · pattern")[
*Longest path in a DAG.*
Same DAG. What is the largest total weight of any path?
Edge cases: no edges (answer 0).
]
#sol[
Longest paths are *hard* in a general graph but *easy* in a DAG: relax with `max` instead
of `min`, still in topological order.

#code(lang: "js", caption: "Longest path (critical path)")[
```js
const dagLongest = (n, g) => {
  const plain = g.map(row => row.map(([v]) => v));
  const order = topoDFS(n, plain);
  const best = new Array(n).fill(0);
  let ans = 0;
  for (const u of order)
    for (const [v, w] of g[u]) {
      best[v] = Math.max(best[v], best[u] + w);
      ans = Math.max(ans, best[v]);
    }
  return ans;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)
Verified on the same DAG: *11*, the route $0 -> 1 -> 2 -> 3$ with $2 + 3 + 6 = 11$.
#ans[11]
]

#ex(15, tier: 1, asked: "Wipro · pattern")[
*Detect a money loop.*
Directed graph of conversion costs, some negative. Is there a cycle whose total weight is
negative?
Edge cases: the cycle may sit in a part of the graph the source cannot reach.
]
#sol[
Bellman-Ford's extra pass answers it — but only for cycles reachable from the source. To
cover the *whole* graph, start with `d[i] = 0` for every $i$ instead of `INF`. That is the
same as adding an invisible node with a free edge to everyone.

#code(lang: "js", caption: "Whole-graph negative cycle test")[
```js
const anyNegativeCycle = (n, E) => {
  const d = new Array(n).fill(0);                  // start everyone at 0
  for (let i = 0; i < n - 1; i++)
    for (const [u, v, w] of E)
      if (d[u] + w < d[v]) d[v] = d[u] + w;
  for (const [u, v, w] of E)
    if (d[u] + w < d[v]) return true;
  return false;
};
```
]
#complexity(time: $O(n m)$, space: $O(n)$)
Verified: `0->1 (1)`, `1->2 (-1)`, `2->1 (-1)`, `0->3 (2)` gives `true`; the acyclic
`0->1 (4)`, `0->2 (5)`, `2->1 (-3)`, `1->3 (3)` gives `false`; an empty edge list gives
`false`; and a negative loop `2 -> 3 -> 2` that node 0 cannot reach still gives `true`,
which is the whole point of seeding everyone at 0.
#ans[true when the extra pass still improves something]
]

#ex(16, tier: 1, asked: "Accenture · pattern")[
*The MST edges, not just the total.*
Return which cables Kruskal picked.
]
#sol[
#code(lang: "js", caption: "Kruskal that reports its choices")[
```js
const kruskalEdges = (n, E) => {
  const e = [...E].sort((a, b) => a[2] - b[2]);
  const d = new DSU(n);
  let total = 0;
  const take = [];
  for (const edge of e)
    if (d.union(edge[0], edge[1])) { total += edge[2]; take.push(edge); }
  return take.length === n - 1 ? [total, take] : [-1, []];
};
```
]
#complexity(time: $O(m log m)$, space: $O(n + m)$)
Verified on `0-1:1, 1-2:2, 0-2:4, 2-3:3, 3-0:10`:
weight 6 with edges `(0-1,1) (1-2,2) (2-3,3)`. The edge `0-2` of weight 4 is skipped
because 0 and 2 are already together by then, and `3-0` of weight 10 is skipped for the
same reason.

#diagram(height: 4.4cm, caption: "Kruskal takes 1, 2, 3 and rejects 4 and 10.")[
  #dnode(20pt, 8pt, 26pt, 20pt, "0")
  #dnode(150pt, 8pt, 26pt, 20pt, "1")
  #dnode(150pt, 85pt, 26pt, 20pt, "2")
  #dnode(20pt, 85pt, 26pt, 20pt, "3")
  #darrow(46pt, 18pt, 150pt, 18pt, label: "1 take")
  #darrow(163pt, 28pt, 163pt, 85pt, label: "2 take")
  #darrow(150pt, 95pt, 46pt, 95pt, label: "3 take")
  #darrow(48pt, 30pt, 150pt, 86pt, label: "4 skip", dashed: true)
  #darrow(31pt, 85pt, 31pt, 28pt, label: "10 skip", dashed: true)
  #place(dx: 215pt, dy: 14pt)[#text(size: 8.5pt)[total = 1 + 2 + 3 = 6]]
  #place(dx: 215pt, dy: 34pt)[#text(size: 8.5pt)[edges used = 3 = n − 1]]
  #place(dx: 215pt, dy: 54pt)[#text(size: 8.5pt)[so the graph is connected]]
]
#ans[weight 6, edges `0-1, 1-2, 2-3`]
]

#section[Tier 2 — weighted graphs with a business story]
#tier-header(2)

#ex(17, tier: 2, asked: "Agoda · pattern")[
*Cheapest flight with at most K stops.*
Directed flights with prices. Find the cheapest trip from `src` to `dst` that uses at most
`K` intermediate stops, or $-1$.

Constraints: $n <= 100$, flights $<= 10^4$, $K <= n$.
Edge cases: `K = 0` (direct flights only); `src == dst` (answer 0).
]
#sol[
#approach(1, "Try every route with DFS", verdict: "exponential")

#approach(2, "Dijkstra by price", verdict: "WRONG — a trap")
Plain Dijkstra finds the cheapest route ignoring the stop limit. It may settle a node at a
cheap price that used too many hops, and then a more expensive but legal route through
that node is never explored. Say this out loud in an interview: it shows you understand
*why* the constraint changes the algorithm.

#approach(3, "Bellman-Ford with exactly K+1 rounds", verdict: "O(K m) — optimal")

"At most K stops" means "at most $K+1$ flights". Bellman-Ford round $i$ finds the best
route using at most $i$ edges. So run exactly $K+1$ rounds and stop.

The one subtle part: each round must read the *previous* round's array, not the array it
is writing. Otherwise one round can chain two flights together.

#code(lang: "js", caption: "Layered Bellman-Ford")[
```js
const cheapestWithStops = (n, flights, src, dst, K) => {
  let d = new Array(n).fill(Infinity);
  d[src] = 0;
  for (let round = 0; round <= K; round++) {
    const nd = [...d];                             // copy: this round adds ONE hop
    for (const [u, v, w] of flights)
      if (d[u] + w < nd[v]) nd[v] = d[u] + w;
    d = nd;
  }
  return d[dst] === Infinity ? -1 : d[dst];
};
```
]
#complexity(time: $O(K m)$, space: $O(n)$)

Verified on `0->1 (100)`, `1->2 (100)`, `0->2 (500)`:
#code(lang: "text", caption: "Real output")[
```text
K = 0  ->  500     (only the direct flight is legal)
K = 1  ->  200     (0 -> 1 -> 2 uses one stop)
K = 5  ->  200     (more stops allowed, but nothing cheaper exists)
unreachable -> -1
src == dst  ->  0
```
]

#trap[
Drop the `const nd = [...d];` copy and `K = 0` returns 200 instead of 500 — verified by
running the broken version — because the same round relaxes `0->1` and then immediately
uses the new `d[1]` for `1->2`. The copy is the entire point of the algorithm.

`[...d]` is the right copy *here* because `d` holds numbers. If each entry were itself an
array, `[...d]` would share every row and the trick would silently stop working; that case
needs `d.map(row => [...row])`.
]

*The idea that unlocked it:* Bellman-Ford already counts edges. Turning a limit on stops
into a limit on rounds costs one line.
#ans[200 when K = 1]
]

#ex(18, tier: 2, asked: "Grab · pattern")[
*Signal delay.*
A message starts at one server and travels along one-way links with known delays. When
does the last server receive it? Return $-1$ if some server never does.
Edge cases: $n = 1$ (answer 0); an isolated server ($-1$).
]
#sol[
Dijkstra from the source, then take the maximum of the distance array. If any entry is
still `INF`, return $-1$.

#code(lang: "js", caption: "Dijkstra, then take the max")[
```js
const networkDelay = (n, g, src) => {
  const d = new Array(n).fill(Infinity);
  const pq = new MinHeap((a, b) => a[0] - b[0]);
  d[src] = 0; pq.push([0, src]);
  while (pq.size) {
    const [du, u] = pq.pop();
    if (du > d[u]) continue;
    for (const [v, w] of g[u])
      if (du + w < d[v]) { d[v] = du + w; pq.push([d[v], v]); }
  }
  const mx = Math.max(...d);
  return mx === Infinity ? -1 : mx;             // one Infinity poisons the max: exactly right
};
```
]
#complexity(time: $O((n+m) log n)$, space: $O(n + m)$)
Verified on `0->1 (1)`, `0->2 (4)`, `1->2 (2)`, `2->3 (1)`: answer *4*
(distances `0 1 3 4`). One unreachable node gives $-1$. $n = 1$ gives 0.

#trap[
`Math.max(...d)` spreads the whole array onto the call stack as arguments. Verified on this Node build:
$10^5$ entries are fine, $2 times 10^5$ throws `RangeError: Maximum call stack size
exceeded`. For a big array write
`d.reduce((a, b) => a > b ? a : b, 0)` instead — same answer, no stack.
]

#trick[
"When does *everyone* get it" is always `max` over the Dijkstra array. "When does the
*first* one get it" is `min`. The graph work is identical.
]
#ans[4]
]

#ex(19, tier: 2, asked: "Sea / Shopee · pattern")[
*Doors and free corridors.*
A grid where stepping into a `0` cell is free and stepping into a `1` cell costs 1 (you
open a door). Find the cheapest route.

Constraints: grid up to $1000 times 1000$, so $10^6$ nodes. Dijkstra's $log$ factor is
avoidable.
Edge cases: every cell free (answer 0).
]
#sol[
When the only weights are 0 and 1, you do not need a heap. Use a *deque*: push a 0-weight
neighbour to the *front*, a 1-weight neighbour to the *back*. The deque then holds at most
two distinct distance values at any time, in order — exactly what a heap would give you,
in $O(1)$ per push.

#note[
The toolkit `Deque` is a head-index *queue*: `push` at the back, `shift` from the front,
`pop` from the back. It has no push-*front*, and 0-1 BFS is the one algorithm in this book
that needs one. The eight-line two-stack deque below supplies it in amortised $O(1)$ —
`unshift` on a plain array would be $O(n)$ per call and would turn this $O(n+m)$
algorithm into $O(n m)$.
]

#code(lang: "js", caption: "0-1 BFS")[
```js
class Deque01 {
  constructor() { this.f = []; this.b = []; }    // f is reversed: f[last] is the front
  get size() { return this.f.length + this.b.length; }
  pushFront(v) { this.f.push(v); }
  pushBack(v) { this.b.push(v); }
  popFront() {
    if (!this.f.length) while (this.b.length) this.f.push(this.b.pop());
    return this.f.pop();
  }
}

const zeroOneBFS = (n, g, src) => {
  const d = new Array(n).fill(Infinity);
  d[src] = 0;
  const dq = new Deque01();
  dq.pushBack(src);
  while (dq.size) {
    const u = dq.popFront();
    for (const [v, w] of g[u])
      if (d[u] + w < d[v]) {
        d[v] = d[u] + w;
        if (w === 0) dq.pushFront(v);            // free step -> jump the queue
        else         dq.pushBack(v);
      }
  }
  return d;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n + m)$,
  note: "No log factor. At 10^6 cells that matters.")

Verified on `0->1 (0)`, `0->3 (1)`, `1->2 (1)`, `3->2 (0)`, `2->4 (1)`:
result `0 0 1 1 2`. An all-zero chain gives `0 0 0`, an unreachable node stays `Infinity`,
and $n = 1$ gives `0`. Cross-checked against the heap Dijkstra on 300 random 0/1 graphs:
zero mismatches.

*The idea that unlocked it:* the heap in Dijkstra exists only to keep the frontier sorted.
With two possible weights the frontier is sorted by *which end you push to*.
#ans[`0 0 1 1 2`]
]

#ex(20, tier: 2, asked: "GIC · pattern")[
*Widest pipe.*
Links have capacities. The capacity of a route is its *smallest* link. Find the route from
`src` to `dst` with the largest capacity.
Edge cases: no route ($-1$); a single link.
]
#sol[
This is Dijkstra with two swaps:
- `min` over a path becomes `min(current, edge)` instead of `+`.
- "smallest distance wins" becomes "largest capacity wins", so use a *max*-heap.

#code(lang: "js", caption: "Widest (max-bottleneck) path")[
```js
const widestPath = (n, g, src, dst) => {
  const cap = new Array(n).fill(-1);
  cap[src] = Infinity;
  const pq = new MinHeap((a, b) => b[0] - a[0]);   // MAX-heap: flip the comparator
  pq.push([cap[src], src]);
  while (pq.size) {
    const [c, u] = pq.pop();
    if (c < cap[u]) continue;
    if (u === dst) return c;
    for (const [v, w] of g[u]) {
      const nc = Math.min(c, w);                   // bottleneck, not sum
      if (nc > cap[v]) { cap[v] = nc; pq.push([nc, v]); }
    }
  }
  return -1;
};
```
]
#complexity(time: $O((n+m) log n)$, space: $O(n + m)$)
Verified on `0-1:3, 1-3:4, 0-2:7, 2-3:2`: answer *3*.
Route `0-1-3` bottlenecks at 3; route `0-2-3` bottlenecks at 2. Unreachable gives $-1$;
a single link `0-1:9` gives 9.

#trick[
*There is no max-heap in JavaScript either — but you do not need one.* The toolkit
`MinHeap` takes a comparator, so `new MinHeap((a, b) => b[0] - a[0])` *is* a max-heap.
This is the standard answer when an interviewer asks "JavaScript has no priority queue,
what do you do?"
]

#trick[
Dijkstra works for any "combine" rule that never *improves* as the path grows. Sum with
non-negative weights qualifies. So does `min`. So does multiplying probabilities in
$[0,1]$ (with a max-heap). Recognise the shape and you get three problems for free.
]
#ans[3]
]

#ex(21, tier: 2, asked: "DBS · pattern")[
*How many terms to finish the degree?*
Courses with prerequisites. You may take *any* number of courses in one term, as long as
every prerequisite is already done. Fewest terms? Return $-1$ if impossible.
Edge cases: no prerequisites (1 term); a circular prerequisite ($-1$).
]
#sol[
Kahn's algorithm, but peel a *whole level* at a time — exactly the ring trick from
multi-source BFS.

#code(lang: "js", caption: "Level-by-level Kahn")[
```js
const semesters = (n, g) => {
  const indeg = new Array(n).fill(0);
  for (let u = 0; u < n; u++) for (const v of g[u]) indeg[v]++;
  const q = new Deque();                           // JS Toolkit appendix
  for (let i = 0; i < n; i++) if (indeg[i] === 0) q.push(i);
  let done = 0, terms = 0;
  while (q.size) {
    let sz = q.size;                               // one whole term
    terms++;
    while (sz-- > 0) {
      const u = q.shift();
      done++;
      for (const v of g[u]) if (--indeg[v] === 0) q.push(v);
    }
  }
  return done === n ? terms : -1;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)
Verified on `0->2, 1->2, 2->3, 3->4`: *4* terms — take `{0,1}`, then `{2}`, then `{3}`,
then `{4}`. A 2-cycle gives $-1$. Five courses with no prerequisites give 1, and one
course gives 1.

#trap[
Use the toolkit `Deque`, not a plain array with `shift()`. `Array.prototype.shift` moves
every remaining element down one slot, so it is $O(n)$ — a queue of $10^5$ nodes turns
this $O(n+m)$ algorithm into $O(n^2)$. The toolkit `Deque` keeps a head index instead.
]

#note[
The answer equals the number of nodes on the *longest chain* of prerequisites. That is why
this is also called the longest path in a DAG measured in nodes.
]
#ans[4]
]

#ex(22, tier: 2, asked: "SCB · pattern")[
*Count the cheapest itineraries.*
Weighted graph. How many *different* shortest routes from the source reach each node?
Edge cases: an unreachable node (count 0); counts that grow past $2^53 - 1$ — plain
numbers stop being exact there, so use `BigInt` or the modulus the problem asks for.
]
#sol[
Dijkstra plus a `ways` array, exactly like the unweighted version in Chapter 15, but the
comparison is on *distance*, not on "first seen".

#code(lang: "js", caption: "Dijkstra that counts")[
```js
const countShortest = (n, g, src) => {
  const d = new Array(n).fill(Infinity), ways = new Array(n).fill(0);
  const pq = new MinHeap((a, b) => a[0] - b[0]);
  d[src] = 0; ways[src] = 1; pq.push([0, src]);
  while (pq.size) {
    const [du, u] = pq.pop();
    if (du > d[u]) continue;
    for (const [v, w] of g[u]) {
      if (du + w < d[v]) {                         // strictly better
        d[v] = du + w;
        ways[v] = ways[u];
        pq.push([d[v], v]);
      } else if (du + w === d[v]) {                // equally good
        ways[v] += ways[u];
      }
    }
  }
  return [d, ways];
};
```
]
#complexity(time: $O((n+m) log n)$, space: $O(n)$)
Verified on `0->1 (1)`, `0->2 (1)`, `1->3 (1)`, `2->3 (1)`, `3->4 (1)`:
distances `0 1 1 2 3`, counts `1 1 1 2 2`.

#trap[
The `if (du > d[u]) continue;` line must stay. Without it a stale heap entry re-adds its
`ways` value and the counts double.
]

#trap[
`du + w === d[v]` uses `===`, which does *not* coerce. That is what you want. But watch
the arithmetic: if the weights were fractions, `0.1 + 0.2 === 0.3` is `false` in
JavaScript, and the "equally good" branch would never fire. Weighted-graph problems in
interviews use integers; if yours does not, compare with a tolerance.
]
#ans[`ways = 1 1 1 2 2`]
]

#ex(23, tier: 2, asked: "Razer · pattern")[
*Lay cable when some links already exist.*
Some offices are already connected (those links are free). Other links have a price.
Cheapest total to connect everything.
Edge cases: already fully connected (answer 0); impossible ($-1$).
]
#sol[
Feed the free links into DSU *first*, then run Kruskal on the priced ones. A free link
costs nothing and can never be a bad choice.

#code(lang: "js", caption: "MST with pre-merged groups")[
```js
const connectWithExisting = (n, built, opt) => {
  const d = new DSU(n);
  let comps = n;
  for (const [a, b] of built) if (d.union(a, b)) comps--;
  const sorted = [...opt].sort((x, y) => x[2] - y[2]);
  let total = 0;
  for (const [u, v, w] of sorted)
    if (d.union(u, v)) { total += w; comps--; }
  return comps === 1 ? total : -1;
};
```
]
#complexity(time: $O(m log m)$, space: $O(n)$)
Verified: $n = 4$, built `{0,1}`, options `{1,2,5}, {0,2,7}, {2,3,2}` → *7*
(take `2-3` for 2, then `1-2` for 5; `0-2` is rejected). With only `{0,1,5}` as an
option → $-1$. Already fully connected gives 0, and $n = 1$ gives 0.
#ans[7]
]

#section[Tier 3 — the hard ones]
#tier-header(3)

#ex(24, tier: 3, asked: "Google · pattern")[
*The gentlest climb.*
A grid of heights. Moving between neighbouring cells costs the *height difference*. The
cost of a route is its *largest* single step. Find the smallest possible largest step from
the top-left to the bottom-right.

Constraints: grid up to $500 times 500$.
Edge cases: a $1 times 1$ grid (answer 0); a flat grid (answer 0).
]
#sol[
#approach(1, "Try every route", verdict: "exponential")

#approach(2, "Binary search on the answer plus BFS", verdict: "O(R C log H) — good")
Guess a limit $L$. Delete every step bigger than $L$ and ask BFS whether the corner is
still reachable. If yes, try a smaller $L$; if no, a bigger one. Since the feasibility is
*monotone* in $L$, binary search works.

#approach(3, "Dijkstra where 'distance' means 'worst step so far'",
  verdict: "O(R C log(R C)) — optimal and shorter")

This is the same swap as the widest-path problem: replace `+` with `max`.

#code(lang: "js", caption: "Minimax-path Dijkstra on a grid")[
```js
const minEffort = (h) => {
  const R = h.length, C = h[0].length;
  const best = Array.from({ length: R }, () => new Array(C).fill(Infinity));
  const pq = new MinHeap((a, b) => a[0] - b[0]);   // [worst step so far, row, col]
  best[0][0] = 0;
  pq.push([0, 0, 0]);
  const DR = [1, -1, 0, 0], DC = [0, 0, 1, -1];
  while (pq.size) {
    const [e, r, c] = pq.pop();
    if (e > best[r][c]) continue;
    if (r === R - 1 && c === C - 1) return e;
    for (let k = 0; k < 4; k++) {
      const nr = r + DR[k], nc = c + DC[k];
      if (nr < 0 || nr >= R || nc < 0 || nc >= C) continue;
      const ne = Math.max(e, Math.abs(h[nr][nc] - h[r][c]));   // max, not +
      if (ne < best[nr][nc]) { best[nr][nc] = ne; pq.push([ne, nr, nc]); }
    }
  }
  return -1;
};
```
]
#complexity(time: $O(R C log(R C))$, space: $O(R C)$)

Verified:
#code(lang: "text", caption: "Real runs")[
```text
1 3 5
2 8 3   ->  1   (route 1,2,3,4,5 down the left then across the bottom)
3 4 5

1 10 1
1 10 1  ->  0   (go straight down the left column, then across)
1  1 1

[[7]]   ->  0

1 2 3   ->  1   (single row)
```
]

*Follow-up: "the same, but minimise the sum of steps instead of the maximum."*
Change `max(e, ...)` back to `e + ...`. It is plain Dijkstra again. Point out that the
*only* difference between the two problems is one operator.

*Follow-up: "what if the grid is $10^5 times 10^5$ but mostly flat?"*
Then the graph does not fit in memory. Say so, and describe compressing runs of equal
height into single nodes before running the same algorithm.
#ans[1]
]

#ex(25, tier: 3, asked: "Amazon · pattern")[
*One free ride.*
Directed graph with prices. You hold one coupon that makes *one* edge free. Cheapest trip
from `src` to `dst`?

Constraints: $n <= 10^5$. Target $O((n+m) log n)$.
Edge cases: the coupon is worth nothing (the cheapest route is already free);
`src == dst` (answer 0).
]
#sol[
#approach(1, "Try the coupon on each edge, re-run Dijkstra", verdict: "O(m (n+m) log n) — too slow")

#approach(2, "Double the graph: state = (node, coupon used?)",
  verdict: "O((n+m) log n) — optimal")

#formulas(title: "State expansion — the key trick for hard Dijkstra")[
When a rule limits what you may do, add the rule to the node. Here the node becomes a
*pair*:
#box[(city, have I spent the coupon yet)].

That doubles the graph to $2n$ states. From state $(u, 0)$ an edge $u -> v$ of weight $w$
gives two moves:
- pay it: go to $(v, 0)$ at cost $w$;
- burn the coupon: go to $(v, 1)$ at cost 0.

From $(u, 1)$ you can only pay. The answer is $min(d[(d s t, 0)], d[(d s t, 1)])$.
]

#code(lang: "js", caption: "Dijkstra over doubled states")[
```js
const withOneFreeEdge = (n, g, src, dst) => {
  // d[u] = [best with the coupon still in hand, best with it already spent]
  const d = Array.from({ length: n }, () => [Infinity, Infinity]);
  const pq = new MinHeap((a, b) => a[0] - b[0]);   // [dist, node, used]
  d[src][0] = 0;
  pq.push([0, src, 0]);
  while (pq.size) {
    const [du, u, used] = pq.pop();
    if (du > d[u][used]) continue;
    for (const [v, w] of g[u]) {
      if (du + w < d[v][used]) {                   // pay normally
        d[v][used] = du + w;
        pq.push([du + w, v, used]);
      }
      if (used === 0 && du < d[v][1]) {            // spend the coupon
        d[v][1] = du;
        pq.push([du, v, 1]);
      }
    }
  }
  const b = Math.min(d[dst][0], d[dst][1]);
  return b === Infinity ? -1 : b;
};
```
]

#trap[
`Array.from({ length: n }, () => [Infinity, Infinity])` builds $n$ *separate* pairs.
`new Array(n).fill([Infinity, Infinity])` builds one pair shared by all $n$ nodes, and the
first relaxation corrupts every node at once. This is the shallow-copy trap in its most
expensive form: the code runs, produces plausible numbers, and is wrong.
]
#complexity(time: $O((n+m) log n)$, space: $O(n)$,
  note: "The graph doubled, so every cost doubled. Same big-O.")

Verified on `0->1 (5)`, `1->2 (5)`, `0->2 (12)`, `2->3 (1)`, `3->4 (20)`:
plain Dijkstra gives `d[4] = 31`; with one coupon the answer is *11* — pay
$5 + 5 + 1 = 11$ to reach node 3, then ride `3->4` free.
`src == dst` gives 0, an unreachable target gives $-1$, and a graph whose cheapest route
already costs 0 gives 0. Cross-checked against an exhaustive brute force — try the coupon
on every edge in turn, Bellman-Ford each time — on 400 random graphs: zero mismatches.

*Follow-up: "now you have K coupons."*
Make the state `(node, coupons used)` with $K+1$ layers. Time becomes
$O(K (n+m) log(K n))$, memory $O(K n)$. Same code, one array dimension bigger.

*Follow-up: "the coupon halves an edge instead of zeroing it."*
Identical structure. Replace the "cost 0" transition with "cost `e.w / 2`". Watch out for
odd weights and rounding — ask the interviewer which way it rounds.
#ans[11]
]

#ex(26, tier: 3, asked: "Microsoft · pattern")[
*Which cables can never be replaced?*
Given a weighted undirected graph, split the edges into:
- *critical* — in every minimum spanning tree;
- *pseudo-critical* — in at least one MST, but not all.

Constraints: $n <= 100$, $m <= 200$.
Edge cases: all weights distinct (then the MST is unique and every MST edge is critical);
several equal weights.
]
#sol[
#formulas(title: "Two tests, one helper")[
Let `base` = the weight of the minimum spanning tree.

- Edge $e$ is *critical* if banning $e$ makes the MST heavier (or breaks connectivity).
- Otherwise, edge $e$ is *pseudo-critical* if forcing $e$ in first still reaches `base`.
- If neither, the edge is in no MST at all.
]

#code(lang: "js", caption: "MST with one edge banned or forced")[
```js
// E is sorted by weight; each entry is [u, v, w, original index].
// `ban` is an ORIGINAL index; `force` is a SORTED slot.
const mstWeight = (n, E, ban, force) => {
  const d = new DSU(n);
  let tot = 0, used = 0;
  if (force !== -1) {
    d.union(E[force][0], E[force][1]);
    tot += E[force][2];
    used++;
  }
  for (const [u, v, w, id] of E) {
    if (id === ban || id === force) continue;
    if (d.union(u, v)) { tot += w; used++; }
  }
  return used === n - 1 ? tot : Infinity;      // Infinity means "cannot connect"
};
```
]

#code(lang: "js", caption: "The two classifications")[
```js
const criticalEdges = (n, raw) => {
  const E = raw.map(([u, v, w], i) => [u, v, w, i])
               .sort((a, b) => a[2] - b[2]);
  const posOf = new Map(E.map((e, i) => [e[3], i]));   // original index -> sorted slot
  const base = mstWeight(n, E, -1, -1);
  const crit = [], pseudo = [];
  for (let i = 0; i < raw.length; i++) {
    if (mstWeight(n, E, i, -1) > base) crit.push(i);
    else if (mstWeight(n, E, -1, posOf.get(i)) === base) pseudo.push(i);
  }
  return [crit, pseudo];
};
```
]
#complexity(time: $O(m^2 alpha(n))$, space: $O(m)$,
  note: "m = 200 gives 40000 DSU runs. Instant.")

#trap[
The array is *sorted*, but the answer must be reported in *original* indices. That is why
every entry carries its original index in slot 3 and why `posOf` — a `Map` from original
index to sorted slot — exists at all. `ban` is compared against slot 3, so it takes an
original index; `force` indexes `E` directly, so it takes a sorted slot. Mixing the two is
the classic bug here, and it only shows up when the input happens to arrive unsorted.

Use a `Map` rather than a plain object for `posOf`. Object keys are coerced to strings, so
`obj[0]` and `obj["0"]` are the same slot — harmless for small integers, a real bug the
moment your keys are anything else. `Map` keeps the key's type.
]

Verified on the square `0-1:1, 1-2:1, 2-3:1, 3-0:1, 0-2:2`:
critical = none, pseudo-critical = edges `0, 1, 2, 3`. Any three of the four weight-1
edges form an MST of weight 3, so no single one is required; the weight-2 diagonal is in
no MST at all.
On the chain `0-1:1, 1-2:2`: both edges are critical (removing either disconnects the
graph). Two parallel edges of equal weight between the same pair: neither is critical,
both are pseudo-critical. $n = 1$ with no edges gives two empty lists.

*Follow-up: "is the MST unique?"*
Yes exactly when every MST edge is critical, that is when the pseudo-critical list is
empty.
#ans[critical: none. pseudo-critical: 0, 1, 2, 3]
]

#ex(27, tier: 3, asked: "Goldman Sachs · pattern")[
*The quietest branch.*
Cities joined by two-way roads of known length, plus a distance `limit`. For each city,
count how many *other* cities lie within `limit` (using shortest road distance). Return
the city with the smallest count; on a tie, return the largest city number.

Constraints: $n <= 100$. Edge cases: `limit = 0` (every count is 0, so return $n-1$);
a huge limit (every count is $n-1$).
]
#sol[
$n <= 100$, and you need *all* pairs. Floyd-Warshall is the right shape: $100^3 = 10^6$.

#code(lang: "js", caption: "Floyd, then count and tie-break")[
```js
const bestCity = (n, E, limit) => {
  const d = Array.from({ length: n }, () => new Array(n).fill(Infinity));
  for (let i = 0; i < n; i++) d[i][i] = 0;
  for (const [u, v, w] of E) {
    d[u][v] = Math.min(d[u][v], w);
    d[v][u] = d[u][v];
  }
  for (let k = 0; k < n; k++)
    for (let i = 0; i < n; i++) {
      if (d[i][k] === Infinity) continue;
      for (let j = 0; j < n; j++)
        d[i][j] = Math.min(d[i][j], d[i][k] + d[k][j]);
    }
  let best = -1, bestCount = Infinity;
  for (let i = 0; i < n; i++) {
    let c = 0;
    for (let j = 0; j < n; j++) if (i !== j && d[i][j] <= limit) c++;
    if (c < bestCount || (c === bestCount && i > best)) { bestCount = c; best = i; }
  }
  return best;
};
```
]
#complexity(time: $O(n^3)$, space: $O(n^2)$)

Verified on roads `0-1:2, 0-3:1, 1-3:3, 1-2:4, 2-3:1` with `limit = 3`:
answer *2*. City 1 reaches `{0 at 2, 3 at 3}` = 2 cities; city 2 reaches
`{3 at 1, 0 at 2}` = 2 cities; cities 0 and 3 each reach 3. Tie between 1 and 2, so the
larger number 2 wins. With `limit = 100` the answer is 3 (everyone ties at $n-1$), and
with `limit = 0` the answer is 3 as well (every count is 0, so the largest index wins).
$n = 1$ gives 0.

#trap[
Read the tie-break rule carefully. "Largest index on a tie" is written as
`c == bestCount && i > best`. If you loop upward and use plain `<`, you silently keep the
*smallest* index and fail half the tests.
]

*Follow-up: "n is 10^5 now."*
Floyd is dead ($10^{15}$). Run Dijkstra from each node instead:
$O(n(n+m) log n)$ — still far too slow at $10^5$. The honest answer is that the problem
must change: either only a few query cities matter, or the graph has special structure
(a tree, a planar road map) you can exploit.
#ans[2]
]

#ex(28, tier: 3, asked: "D. E. Shaw · pattern")[
*The second-best route.*
Undirected weighted graph. Find the length of the second shortest route from `src` to
`dst`. It must be *strictly* longer than the shortest. It may repeat nodes.

Constraints: $n <= 10^5$. Edge cases: no second route ($-1$).
]
#sol[
Keep *two* best values per node instead of one: `d1[v]` (best) and `d2[v]` (best that is
strictly worse than `d1[v]`). Run Dijkstra, but do not stop at the first time a node is
settled — let a node be popped up to twice.

#code(lang: "js", caption: "Two-label Dijkstra")[
```js
const secondShortest = (n, g, s, t) => {
  const d1 = new Array(n).fill(Infinity), d2 = new Array(n).fill(Infinity);
  const pq = new MinHeap((a, b) => a[0] - b[0]);
  d1[s] = 0; pq.push([0, s]);
  while (pq.size) {
    const [du, u] = pq.pop();
    if (du > d2[u]) continue;                      // worse than both labels
    for (const [v, w] of g[u]) {
      const nd = du + w;
      if (nd < d1[v]) {                            // new best: old best slides down
        d2[v] = d1[v];
        d1[v] = nd;
        pq.push([nd, v]);
      } else if (nd > d1[v] && nd < d2[v]) {
        d2[v] = nd;
        pq.push([nd, v]);
      }
    }
  }
  return d2[t] === Infinity ? -1 : d2[t];
};
```
]
#complexity(time: $O((n+m) log n)$, space: $O(n)$,
  note: "Each node enters the heap at most twice, so the bound holds.")

Verified on `0-1:1, 1-2:1, 0-2:3, 2-3:1, 3-4:1, 2-4:5`:
- `0 -> 4`: shortest is $0,1,2,3,4 = 4$; second is $0,2,3,4 = 5$. Code gives *5*.
- `0 -> 2`: shortest 2, second 3. Code gives 3.
- unreachable gives $-1$.
- the single edge `0-1:4`: the answer is *12*, walking $0 -> 1 -> 0 -> 1$. Routes may
  repeat nodes, so "no second route" is rarer than it looks.

#trap[
The test must be `nd > d1[v]`, not `nd !== d1[v]`. With `>=` or `!==` you can let an
equal-length route sneak in as "second", which the problem forbids.
]

*Follow-up: "now the K-th shortest."*
Same idea with $K$ labels per node, or the standard trick: keep a counter per node and
allow each node to be popped $K$ times. Time $O(K (n+m) log n)$, and you should mention
the memory cost of $K n$ before writing a line.
#ans[5]
]

#ex(29, tier: 3, asked: "Uber · pattern")[
*Round trip.*
Directed roads (one-way streets). Find the cheapest trip that goes from the depot to a
customer *and back*.
Edge cases: one direction impossible ($-1$).
]
#sol[
The naive move is to run Dijkstra from the customer as well — but there can be many
customers, and that is one Dijkstra each.

Better: run Dijkstra *twice from the depot*. Once on the graph, once on the graph with
every edge reversed. In the reversed graph, the distance from the depot to node $t$ is
exactly the distance from $t$ back to the depot in the real graph.

#code(lang: "js", caption: "Forward plus reverse Dijkstra")[
```js
const roundTrip = (n, g, s, t) => {
  const run = (gg, st) => {
    const d = new Array(n).fill(Infinity);
    const pq = new MinHeap((a, b) => a[0] - b[0]);
    d[st] = 0; pq.push([0, st]);
    while (pq.size) {
      const [du, u] = pq.pop();
      if (du > d[u]) continue;
      for (const [v, w] of gg[u])
        if (du + w < d[v]) { d[v] = du + w; pq.push([d[v], v]); }
    }
    return d;
  };
  const rg = Array.from({ length: n }, () => []);
  for (let u = 0; u < n; u++)
    for (const [v, w] of g[u]) rg[v].push([u, w]);   // reverse every edge
  const out = run(g, s), back = run(rg, s);
  if (out[t] === Infinity || back[t] === Infinity) return -1;
  return out[t] + back[t];
};
```
]
#complexity(time: $O((n+m) log n)$, space: $O(n + m)$,
  note: "Two Dijkstras total, no matter how many customers you ask about.")

Verified on `0->1 (3)`, `1->2 (4)`, `2->0 (2)`, `0->2 (10)`:
round trip `0 <-> 2` costs *9* (out $0,1,2 = 7$; back $2 -> 0 = 2$; the direct `0->2`
at 10 is worse). Adding a one-way `0->3 (1)` to a dead end gives $-1$, because `back[3]`
stays `Infinity`. `s === t` gives 0.

*Follow-up: "the answer for every customer at once."*
You already have it: `out[t] + back[t]` for every $t$, from the same two runs. Say this —
it is the whole point of reversing instead of re-running.

*Follow-up: "the driver must pick up a parcel at one of a set S of depots on the way."*
Add a virtual source joined to every depot in S with weight 0 and run one Dijkstra from it.
#ans[9]
]

#ex(30, tier: 3, asked: "Adobe · pattern")[
*Project deadline.*
$n$ tasks, each with a duration, plus "A must end before B starts" arrows. Tasks with no
unfinished prerequisite may run in parallel. When does the whole project finish?
Return $-1$ if the arrows contain a loop.
Edge cases: no arrows (answer = the longest single duration).
]
#sol[
This is the *critical path*. Relax with `max` in topological order, carrying finish times.

#code(lang: "js", caption: "Earliest finish time of the whole project")[
```js
const earliestFinish = (n, g, dur) => {
  const indeg = new Array(n).fill(0);
  for (let u = 0; u < n; u++) for (const v of g[u]) indeg[v]++;
  const q = new Deque();
  const fin = new Array(n).fill(0);
  let done = 0, ans = 0;
  for (let i = 0; i < n; i++)
    if (indeg[i] === 0) { q.push(i); fin[i] = dur[i]; }
  while (q.size) {
    const u = q.shift();
    done++;
    ans = Math.max(ans, fin[u]);
    for (const v of g[u]) {
      fin[v] = Math.max(fin[v], fin[u] + dur[v]);  // wait for the slowest input
      if (--indeg[v] === 0) q.push(v);
    }
  }
  return done === n ? ans : -1;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)

Verified on durations `{3, 2, 4, 1}` and arrows `0->1, 0->2, 1->3, 2->3`:
answer *8*. Task 0 ends at 3; task 1 at 5; task 2 at 7; task 3 must wait for both, so it
starts at 7 and ends at 8. A 2-cycle gives $-1$.

Durations `{5, 2, 9}` with no arrows give 9 — the longest single task. One task gives its
own duration.

#trap[
`fin[v] = Math.max(fin[v], fin[u] + dur[v])` must run for *every* incoming arrow, not only
the one that pushes the in-degree to zero. Task 3 above would finish at 6 instead of 8 if
you only used the last arrow.
]

*Follow-up: "which tasks can be delayed without moving the deadline?"*
Compute the latest allowed finish time by running the same relaxation backwards from the
deadline on the reversed graph. Any task whose earliest and latest times differ has
*slack*; tasks with zero slack form the critical path.
#ans[8]
]

#section[Dry run — Dijkstra, pop by pop]

Undirected weighted graph, 6 nodes:

#table(columns: 10,
  [edge], [0–1], [0–2], [2–1], [1–3], [2–3], [3–4], [2–4], [4–5], [3–5],
  [weight], [4], [1], [2], [5], [8], [3], [10], [2], [6],
)

Source is node 0. We print every pop, every relaxation, and the whole `dist` array.

#code(lang: "text", caption: "Actual printed trace")[
```text
step 1: pop (0,0) settle node 0
   relax 0->1 w=4 : inf -> 4  push
   relax 0->2 w=1 : inf -> 1  push
   dist = [0,4,1,inf,inf,inf]
step 2: pop (1,2) settle node 2
   edge 2->0 w=1 gives 2 , not better than 0
   relax 2->1 w=2 : 4 -> 3  push
   relax 2->3 w=8 : inf -> 9  push
   relax 2->4 w=10 : inf -> 11  push
   dist = [0,3,1,9,11,inf]
step 3: pop (3,1) settle node 1
   edge 1->0 w=4 gives 7 , not better than 0
   edge 1->2 w=2 gives 5 , not better than 1
   relax 1->3 w=5 : 9 -> 8  push
   dist = [0,3,1,8,11,inf]
step 4: pop (4,1) STALE, skip
step 5: pop (8,3) settle node 3
   edge 3->1 w=5 gives 13 , not better than 3
   edge 3->2 w=8 gives 16 , not better than 1
   edge 3->4 w=3 gives 11 , not better than 11
   relax 3->5 w=6 : inf -> 14  push
   dist = [0,3,1,8,11,14]
step 6: pop (9,3) STALE, skip
step 7: pop (11,4) settle node 4
   edge 4->3 w=3 gives 14 , not better than 8
   edge 4->2 w=10 gives 21 , not better than 1
   relax 4->5 w=2 : 14 -> 13  push
   dist = [0,3,1,8,11,13]
step 8: pop (13,5) settle node 5
   edge 5->4 w=2 gives 15 , not better than 11
   edge 5->3 w=6 gives 19 , not better than 8
   dist = [0,3,1,8,11,13]
step 9: pop (14,5) STALE, skip
final: 0 3 1 8 11 13
```
]

The same thing as a table. "Heap after" lists the pairs `(distance, node)` still waiting.

#table(columns: (auto, auto, 1fr, 1fr),
  [*step*], [*pop*], [*dist array after*], [*heap after*],
  [1], [(0,0)], [`0 4 1 - - -`], [(1,2) (4,1)],
  [2], [(1,2)], [`0 3 1 9 11 -`], [(3,1) (4,1) (9,3) (11,4)],
  [3], [(3,1)], [`0 3 1 8 11 -`], [(4,1) (8,3) (9,3) (11,4)],
  [4], [(4,1)], [stale — `4 > dist[1] = 3`, skip], [(8,3) (9,3) (11,4)],
  [5], [(8,3)], [`0 3 1 8 11 14`], [(9,3) (11,4) (14,5)],
  [6], [(9,3)], [stale — `9 > dist[3] = 8`, skip], [(11,4) (14,5)],
  [7], [(11,4)], [`0 3 1 8 11 13`], [(13,5) (14,5)],
  [8], [(13,5)], [no change], [(14,5)],
  [9], [(14,5)], [stale, skip], [empty],
)

#formulas(title: "Three things this trace teaches")[
+ *Stale entries are normal.* Node 1 went into the heap twice (at 4 and at 3) and node 3
  twice (at 9 and 8) and node 5 twice (at 14 and 13). The one-line guard
  `if (du > d[u]) continue;` throws the old copies away. You never need a `decrease-key`
  operation.
+ *A node's value can drop before it is popped, never after.* `dist[1]` fell from 4 to 3
  at step 2 — before node 1 was settled at step 3. After that it never moved.
+ *The heap can hold more than $n$ items.* Up to $m$ of them. That is why the bound is
  $O((n+m) log n)$ and not $O(n log n)$.
]

#note[
Check the final answer by hand for node 5: $0 -> 2 (1) -> 1 (2) -> 3 (5) -> 4 (3) -> 5
(2)$ gives $1+2+5+3+2 = 13$. Any other route is longer. The trace is right.
]

#section[Python, for the two signature problems]

JavaScript is the primary language of this book; Python appears here only for the two
problems every weighted-graph round comes back to. Both versions below were run.

#code(lang: "python", caption: "Dijkstra and Kahn in Python")[
```python
import heapq
from collections import deque

def dijkstra(n, g, src):                 # g[u] = list of (v, w)
    INF = float('inf')
    dist = [INF] * n
    dist[src] = 0
    pq = [(0, src)]
    while pq:
        du, u = heapq.heappop(pq)
        if du > dist[u]:
            continue
        for v, w in g[u]:
            if du + w < dist[v]:
                dist[v] = du + w
                heapq.heappush(pq, (dist[v], v))
    return dist

def topo_kahn(n, g):
    indeg = [0] * n
    for u in range(n):
        for v in g[u]:
            indeg[v] += 1
    q = deque(i for i in range(n) if indeg[i] == 0)
    order = []
    while q:
        u = q.popleft()
        order.append(u)
        for v in g[u]:
            indeg[v] -= 1
            if indeg[v] == 0:
                q.append(v)
    return order if len(order) == n else []
```
]
Real output: `dijkstra` on the Warm-up 3 graph gives `[0, 3, 1, 4, inf]`;
`dijkstra(1, [[]], 0)` gives `[0]`;
`topo_kahn` on `0->2, 1->2, 2->3` with $n=5$ gives `[0, 1, 4, 2, 3]`;
on a 2-cycle it gives `[]`.

#trick[
Python's `heapq` is a min-heap and has no `decrease-key` — and it is the one thing Python
gives you that JavaScript does not give you at all. The lazy
`if du > dist[u]: continue` pattern is the standard way in both languages; in JavaScript
the same loop runs on the toolkit `MinHeap`.

Note that `heapq` orders *tuples* element by element for free, so Python can push
`(dist, node)` with no comparator. The JavaScript `MinHeap` compares arrays only if you
tell it how: `new MinHeap((a, b) => a[0] - b[0])`.
]

#section[Practice]

#practice(tier: 0, time: "20 min")[
+ `d[u] = 10`, edge weight 3, `d[v] = 12`. What is `d[v]` after relaxing $u -> v$?
+ A graph has 5 nodes. How many Bellman-Ford rounds are enough (with no negative loop)?
+ Which algorithm: one source, all weights equal to 7?
+ Which algorithm: every pair of nodes, $n = 300$, weights may be negative but no negative
  loop?
]

#practice(tier: 1, time: "60 min")[
5. Given $n$ and a weighted undirected edge list, return the total weight of the minimum
  spanning tree, or $-1$ if the graph is not connected.
6. Given a list of points on a plane, return the cheapest total cost to link them all,
  where the cost of a link is the Manhattan distance
  $|x_1 - x_2| + |y_1 - y_2|$. Points up to 1000.
7. Given a DAG and a list you were handed, decide whether that list is a valid
  topological order.
8. Grid of positive cell costs. You pay the cost of every cell you *enter*, plus the
  starting cell. Cheapest route from the top-left to the bottom-right, 4 directions.
]

#practice(tier: 2, time: "70 min")[
9. Weighted graph, a source, a target, and a node `x` you *must* pass through. Cheapest
  route.
10. Given a source and a limit `T`, count the nodes whose shortest distance is at most `T`.
11. Tasks with durations and dependencies. Report the earliest finish time of the whole
   project.
12. Is the shortest route from `s` to `t` unique?
]

#practice(tier: 3, time: "60 min")[
13. Directed graph with possibly negative weights. List the nodes whose shortest distance
   is undefined because a negative cycle can reach them.
14. Undirected graph. For a given `s` and `t`, find the smallest possible *largest* edge on
   any route between them (the minimax edge).
15. Given an MST and one extra edge, decide in $O(n)$ whether the MST changes.
]

#key[
*1.* $10 + 3 = 13$, and $13 < 12$ is false. `d[v]` stays *12*.

*2.* $n - 1 = 4$ rounds.

*3.* All weights equal means the cheapest route is the one with the fewest edges: plain
*BFS*, then multiply the hop count by 7.

*4.* *Floyd-Warshall*. $300^3 = 2.7 times 10^7$, and it handles negative weights.

*5.* Kruskal, exactly as in Example 11. Verified: `0-1:1, 1-2:2, 0-2:4, 2-3:3, 3-0:10`
gives *6*; a disconnected graph gives $-1$; $n = 1$ gives 0.

*6.* Every pair of points is a possible link, so $m = n^2 / 2$ — the graph is *dense* and
the $O(n^2)$ Prim beats Kruskal (which would need to sort half a million edges).
#code(lang: "js", caption: "Q6 — dense Prim, no heap")[
```js
const connectPoints = (p) => {
  const n = p.length;
  if (n <= 1) return 0;
  const best = new Array(n).fill(Infinity);
  const inMst = new Array(n).fill(false);
  best[0] = 0;
  let total = 0;
  for (let it = 0; it < n; it++) {
    let u = -1;
    for (let i = 0; i < n; i++)
      if (!inMst[i] && (u === -1 || best[i] < best[u])) u = i;
    inMst[u] = true;
    total += best[u];
    for (let v = 0; v < n; v++)
      if (!inMst[v]) {
        const d = Math.abs(p[u][0] - p[v][0]) + Math.abs(p[u][1] - p[v][1]);
        best[v] = Math.min(best[v], d);
      }
  }
  return total;
};
```
]
Verified on `(0,0) (2,2) (3,10) (5,2) (7,0)`: *20*
(links $0-1$ costs 4, $1-3$ costs 3, $3-4$ costs 4, $1-2$ costs 9). One point gives 0;
zero points gives 0; two identical points give 0; negative coordinates work
(`(-5,-5) (-5,-1)` gives 4).
#complexity(time: $O(n^2)$, space: $O(n)$)

*7.* Record each node's position in the given list, then check that every arrow points
forward. Also reject a list with wrong length or repeats.
#code(lang: "js", caption: "Q7")[
```js
const validTopo = (n, g, order) => {
  if (order.length !== n) return false;
  const pos = new Array(n).fill(-1);
  for (let i = 0; i < n; i++) {
    const u = order[i];
    if (u < 0 || u >= n || pos[u] !== -1) return false;
    pos[u] = i;
  }
  for (let u = 0; u < n; u++)
    for (const v of g[u]) if (pos[u] > pos[v]) return false;
  return true;
};
```
]
Verified on `0->1, 0->2, 1->3, 2->3`: `0 1 2 3` → true; `0 3 1 2` → false; a short list
`0 1 2` → false; a list with a repeat `0 1 1 3` → false; $n = 0$ with an empty list → true.
#complexity(time: $O(n + m)$, space: $O(n)$)

*8.* Dijkstra on the grid, where entering a cell costs that cell's number.
#code(lang: "js", caption: "Q8")[
```js
const gridCost = (c) => {
  const R = c.length, C = c[0].length;
  const d = Array.from({ length: R }, () => new Array(C).fill(Infinity));
  const pq = new MinHeap((a, b) => a[0] - b[0]);   // [cost, row, col]
  d[0][0] = c[0][0];
  pq.push([d[0][0], 0, 0]);
  const DR = [1, -1, 0, 0], DC = [0, 0, 1, -1];
  while (pq.size) {
    const [du, r, cc] = pq.pop();
    if (du > d[r][cc]) continue;
    if (r === R - 1 && cc === C - 1) return du;
    for (let k = 0; k < 4; k++) {
      const nr = r + DR[k], nc = cc + DC[k];
      if (nr < 0 || nr >= R || nc < 0 || nc >= C) continue;
      if (du + c[nr][nc] < d[nr][nc]) {
        d[nr][nc] = du + c[nr][nc];
        pq.push([d[nr][nc], nr, nc]);
      }
    }
  }
  return -1;
};
```
]
Verified on `[[1,9,9],[1,1,9],[9,1,1]]`: *5* (down the left, across the bottom).
`[[7]]` gives 7 — the starting cell still costs. A single row `[[1,2,3]]` gives 6.
#complexity(time: $O(R C log(R C))$, space: $O(R C)$)

*9.* Any route through `x` splits at `x`. So the answer is
$"dist"(s, x) + "dist"(x, t)$. Run Dijkstra from `s` on the graph, and Dijkstra from `x`
on the graph (undirected) or on the *reversed* graph (directed). Two runs, then one
addition. Report $-1$ if either half is `INF`.

*10.* One Dijkstra from the source, then count entries `<= T`. $O((n+m) log n)$.
`d.filter(x => x <= T).length` reads well; just remember that unreachable entries are
`Infinity` and are correctly excluded by `<=`.

*11.* Exactly Example 30. Verified: durations `{3,2,4,1}` with `0->1, 0->2, 1->3, 2->3`
gives *8*; a cycle gives $-1$.

*12.* Count shortest routes as in Example 22 and ask whether `ways[t] == 1`.
#code(lang: "js", caption: "Q12")[
```js
const uniqueShortest = (n, g, s, t) => {
  const d = new Array(n).fill(Infinity), ways = new Array(n).fill(0);
  const pq = new MinHeap((a, b) => a[0] - b[0]);
  d[s] = 0; ways[s] = 1; pq.push([0, s]);
  while (pq.size) {
    const [du, u] = pq.pop();
    if (du > d[u]) continue;
    for (const [v, w] of g[u]) {
      if (du + w < d[v]) {
        d[v] = du + w; ways[v] = ways[u];
        pq.push([d[v], v]);
      } else if (du + w === d[v]) ways[v] += ways[u];
    }
  }
  return d[t] !== Infinity && ways[t] === 1;
};
```
]
Verified: `0->1 (1), 0->2 (1), 1->3 (1), 2->3 (1)` gives false (two routes);
the chain `0->1->2` gives true; an unreachable target gives false.

*13.* Run $n-1$ Bellman-Ford rounds. Then run $n$ more sweeps that mark a node bad if it
still improves, *or* if any of its predecessors is already bad. The extra sweeps let
"badness" spread along every arrow.
#code(lang: "js", caption: "Q13")[
```js
const hitByNegCycle = (n, E, src) => {
  const d = new Array(n).fill(Infinity);
  d[src] = 0;
  for (let i = 0; i < n - 1; i++)
    for (const [u, v, w] of E)
      if (d[u] + w < d[v]) d[v] = d[u] + w;
  const bad = new Array(n).fill(false);
  for (let i = 0; i < n; i++)                      // n sweeps let "badness" spread
    for (const [u, v, w] of E)
      if (d[u] !== Infinity && (bad[u] || d[u] + w < d[v])) bad[v] = true;
  return { bad, d };
};
```
]
Verified on `0->1 (1), 1->2 (-1), 2->1 (-1), 2->3 (1), 0->4 (4)`:
`bad = 0 1 1 1 0` and `d[4] = 4`. Node 4 is off the loop and keeps a real distance; node 0
is the source and nothing returns to it. A graph with no negative cycle marks nothing.

Here the `d[u] !== Infinity` guard *is* needed, because it also gates the `bad[u]`
propagation — an unreachable node must not spread badness.
#complexity(time: $O(n m)$, space: $O(n)$)

*14.* This is the widest-path idea with `max` instead of `min`: use Dijkstra where the
"distance" of a route is its largest edge, and keep the smallest such value. Change the
minimax Dijkstra of Example 24 from a grid to an adjacency list. A second correct answer:
run Kruskal, and the minimax edge between `s` and `t` is the *largest edge on the MST path*
between them — worth saying out loud, because it shows you know the MST has that property.

*15.* Adding edge $(u, v, w)$ to a spanning tree creates exactly one cycle. The MST
changes if and only if $w$ is *smaller* than the largest edge on the existing tree path
from $u$ to $v$. Walk that path with one DFS from $u$ to $v$ on the tree, tracking the
maximum edge: $O(n)$. If $w$ is smaller, swap it for that maximum edge.
]

#revision[
*One import covers the whole chapter.*
#code(lang: "js", caption: "Toolkit")[
```js
const { MinHeap, DSU, Deque } = require('./toolkit.js');  // JS Toolkit appendix
```
]
JavaScript ships no heap, no ordered map and no deque. `MinHeap` with a flipped
comparator is your max-heap; `DSU.union` returns `false` when the ends were already
joined; `Deque` is the $O(1)$ queue that `Array.prototype.shift` is not.
Graph: `g[u]` is a list of `[to, weight]` pairs. Unreached: `Infinity`.

*Dijkstra — non-negative weights*
#code(lang: "js", caption: "Dijkstra")[
```js
const d = new Array(n).fill(Infinity);
const pq = new MinHeap((a, b) => a[0] - b[0]);   // [dist, node]
d[src] = 0; pq.push([0, src]);
while (pq.size) {
  const [du, u] = pq.pop();
  if (du > d[u]) continue;
  for (const [v, w] of g[u])
    if (du + w < d[v]) { d[v] = du + w; pq.push([d[v], v]); }
}
```
]

*Bellman-Ford — negatives allowed*
#code(lang: "js", caption: "Bellman-Ford")[
```js
const d = new Array(n).fill(Infinity);
d[src] = 0;
for (let i = 0; i < n - 1; i++)
  for (const [u, v, w] of E)                       // e = [from, to, weight]
    if (d[u] + w < d[v]) d[v] = d[u] + w;
for (const [u, v, w] of E)                         // one more pass that still
  if (d[u] + w < d[v]) return null;              // improves => negative cycle
return d;
```
]

*Floyd-Warshall — every pair, k outermost*
#code(lang: "js", caption: "Floyd")[
```js
for (let k = 0; k < n; k++)
  for (let i = 0; i < n; i++)
    for (let j = 0; j < n; j++)
      if (d[i][k] + d[k][j] < d[i][j]) d[i][j] = d[i][k] + d[k][j];
```
]

*Kruskal — MST*
#code(lang: "js", caption: "Kruskal")[
```js
const e = [...E].sort((a, b) => a[2] - b[2]);    // numeric, never a bare sort()
const d = new DSU(n);
let tot = 0, used = 0;
for (const [u, v, w] of e)
  if (d.union(u, v)) { tot += w; used++; }
return used === n - 1 ? tot : -1;
```
]

*Kahn — topological order + cycle test*
#code(lang: "js", caption: "Kahn")[
```js
const indeg = new Array(n).fill(0), order = [];
const q = new Deque();
for (let u = 0; u < n; u++) for (const v of g[u]) indeg[v]++;
for (let i = 0; i < n; i++) if (indeg[i] === 0) q.push(i);
while (q.size) {
  const u = q.shift(); order.push(u);
  for (const v of g[u]) if (--indeg[v] === 0) q.push(v);
}
return order.length === n ? order : [];            // short -> a cycle
```
]

*Pick the algorithm*
#table(columns: (1fr, 1fr),
  [weights all 1], [BFS, $O(n+m)$],
  [weights 0 or 1], [0-1 BFS with a deque, $O(n+m)$],
  [weights $>= 0$], [Dijkstra, $O((n+m) log n)$],
  [some negative], [Bellman-Ford, $O(n m)$],
  [graph is a DAG], [relax in topological order, $O(n+m)$],
  [every pair, $n <= 400$], [Floyd-Warshall, $O(n^3)$],
  [cheapest way to link all], [Kruskal / Prim, $O(m log m)$],
  [order of dependent jobs], [Kahn or DFS topo, $O(n+m)$],
  [route cost = worst edge], [Dijkstra with `max` instead of `+`],
  [a limited resource (K stops, K coupons)], [add it to the state],
)

*Complexity table*
#table(columns: (1fr, auto, auto),
  [*algorithm*], [*time*], [*space*],
  [BFS / 0-1 BFS], [$O(n + m)$], [$O(n + m)$],
  [Dijkstra with heap], [$O((n+m) log n)$], [$O(n + m)$],
  [Dijkstra, dense, no heap], [$O(n^2 + m)$], [$O(n)$],
  [Bellman-Ford], [$O(n m)$], [$O(n)$],
  [Floyd-Warshall], [$O(n^3)$], [$O(n^2)$],
  [Kruskal], [$O(m log m)$], [$O(n)$],
  [Prim with heap], [$O(m log n)$], [$O(n + m)$],
  [Topological sort], [$O(n + m)$], [$O(n)$],
  [DAG shortest / longest path], [$O(n + m)$], [$O(n)$],
)

*The JavaScript facts this chapter depends on*
#table(columns: (auto, 1fr),
  [`arr.sort()`], [lexicographic on *stringified* elements. A bare `.sort()` on the edge list `[[0,1,1],[1,2,2],[0,2,4],[2,3,3],[3,0,10]]` yields weight order `1, 4, 2, 3, 10`. Always `sort((a, b) => a[2] - b[2])`, and copy with `[...E]` first because `sort` mutates.],
  [no heap], [`MinHeap` from the *JS Toolkit* appendix. Max-heap = flipped comparator.],
  [no `TreeMap`], [not needed here; when it is, a sorted array plus the toolkit `lowerBound`.],
  [comparators], [must return a *number*. `(a, b) => a[0] > b[0]` returns a boolean, coerces to `1`/`0`, and the ordering collapses.],
  [numbers are doubles], [exact to $2^53 - 1 approx 9 times 10^15$. A path of $10^5$ edges of weight $10^9$ caps at $10^14$, so this chapter is safe. Past it, `BigInt`.],
  [recursion depth], [about $10^4$ frames. The DFS topological sort throws `RangeError` on a 100000-node chain — use Kahn.],
  [`Array(n).fill([])`], [stores *one* array in all $n$ slots. Use `Array.from({ length: n }, () => [])`; a grid copy is `g.map(r => [...r])`.],
  [`arr.shift()`], [$O(n)$. Use the toolkit `Deque` for a queue.],
  [`Math.max(...arr)`], [throws `RangeError` past roughly $2 times 10^5$ entries. Use `reduce`.],
)

*Top traps*
#table(columns: (auto, 1fr),
  [1], [A bare `.sort()` in Kruskal. Lexicographic, so the MST is wrong.],
  [2], [Forgetting the comparator on `MinHeap` when pushing `[dist, node]` pairs — the default `(a, b) => a - b` on arrays gives `NaN`.],
  [3], [Dropping `if (du > d[u]) continue;`. Stale entries then corrupt path counts.],
  [4], [Running Dijkstra on a graph with a negative edge. Use Bellman-Ford.],
  [5], [Mixing a finite sentinel with a missing `d[u] !== INF` guard. Seed with `Infinity` and the guard becomes unnecessary.],
  [6], [Floyd with `k` not in the outer loop. The answer is silently wrong.],
  [7], [Kruskal without the `used === n - 1` check. A disconnected graph returns a fake total.],
  [8], [The "at most K stops" round without `const nd = [...d]` first.],
  [9], [Returning `Infinity` instead of $-1$ for unreachable nodes — and note `JSON.stringify(Infinity)` is `null`.],
  [10], [Mixing the sorted position of an edge with its original index.],
  [11], [Recursive DFS on $10^5$ nodes. Kahn, or an explicit stack.],
)

*The one sentence to remember*
Pick the algorithm from the *weights*, not from the story: all-ones means BFS,
non-negative means Dijkstra, negative means Bellman-Ford, no-cycles means topological
order, and "link everything cheaply" means MST.
]

]
