#import "../../shared/lib/style.typ": *

#chapter(num: 15, title: "Graphs I — Traversal & Components",
  tagline: "Store the graph once. Then BFS and DFS answer almost everything.")[

#section[Pattern in one page]

A graph is just *dots and lines*. The dots are called *nodes* (or vertices). The lines
are called *edges*. That is all.

#formulas(title: "The four words you must know")[
- *n* — how many nodes. Nodes are numbered #box[$0, 1, ..., n-1$].
- *m* — how many edges.
- *Undirected* edge: a two-way road. If $u$ and $v$ are joined, you can walk both ways.
- *Directed* edge: a one-way road. $u -> v$ only.
- *Weighted* edge: the road has a number on it (cost, time, distance).
  This chapter uses *unweighted* graphs only. Weights come in Chapter 16.
]

#subsection[How to store a graph]

There are two ways. You will use the first one in almost every interview.

#table(columns: (auto, 1fr, 1fr),
  [], [*Adjacency list*], [*Adjacency matrix*],
  [Shape], [`Array.from({length: n}, () => [])`], [`Array.from({length: n}, () => new Array(n).fill(0))`],
  [Memory], [$O(n + m)$], [$O(n^2)$],
  [List all neighbours of $u$], [$O(deg(u))$ — perfect], [$O(n)$ — wasteful],
  [Ask "is $u$–$v$ an edge?"], [$O(deg(u))$], [$O(1)$ — perfect],
  [Use when], [normal graphs (this is the default)], [$n <= 500$ and you ask about single pairs a lot],
)

#trick[
Rule of thumb: *always start with an adjacency list*. Switch to a matrix only when the
problem literally hands you an $n times n$ table, or $n$ is tiny (under 500) and you must
test single pairs quickly.
]

#code(lang: "js", caption: "Build an adjacency list from an edge list")[
```js
const buildAdj = (n, edges) => {
  const g = Array.from({ length: n }, () => []);
  for (const [u, v] of edges) {
    g[u].push(v);
    g[v].push(u);          // delete this line for a DIRECTED graph
  }
  return g;
};
```
]

#trap[
`Array.from({length: n}, () => [])` — never `new Array(n).fill([])`. `fill` puts *the same
array object* in all `n` slots, so `g[0].push(1)` also appears in `g[5]` and every other
row. The graph silently becomes one giant row.

The same rule governs grids: `[...grid]` copies the outer array but *shares* every row, so
writing to `copy[0][0]` writes to `grid[0][0]` too. A real 2D copy is
`grid.map(r => [...r])`, and this chapter's flood fills depend on it.
]

For edges `[0,1], [0,2], [1,3], [4,5]` with `n = 7` this prints:

#code(lang: "text", caption: "Real output of the code above")[
```text
0 -> 1 2
1 -> 0 3
2 -> 0
3 -> 1
4 -> 5
5 -> 4
6 ->
```
]

Node 6 has an empty row. It exists, but it touches nothing.

#subsection[BFS — breadth first search]

BFS walks outward in *rings*. First the source. Then everything one edge away. Then
everything two edges away. It uses a *queue* (first in, first out).

#code(lang: "js", caption: "BFS template — memorise this")[
```js
const bfsDist = (g, src) => {
  const dist = new Array(g.length).fill(-1);   // -1 means "not reached yet"
  const q = [src];
  dist[src] = 0;
  for (let head = 0; head < q.length; head++) {
    const u = q[head];                         // read, do not remove
    for (const v of g[u])
      if (dist[v] === -1) {                    // first time we see v
        dist[v] = dist[u] + 1;
        q.push(v);
      }
  }
  return dist;
};
```
]

#trap[
*JavaScript has no queue.* An array is a stack (`push` / `pop` are $O(1)$), but
`q.shift()` — the obvious "remove from the front" — is $O(n)$, because every remaining
element slides down one slot. A BFS written with `shift()` is $O(n^2)$ and will time out
on $10^5$ nodes while looking completely correct.

Two fixes, and you should know both:
- *A head index*, as above. The array only grows, `head` only moves forward, and
  `q.length - head` is the live size. Simplest, and what this chapter uses.
- *The toolkit `Deque`* (`const { Deque } = require('./toolkit.js')`), when you also need
  to push to the *front* — 0-1 BFS in Chapter 16, or a monotonic deque.
]

#formulas(title: "The BFS invariant — why it works")[
Nodes leave the queue in order of increasing distance from the source.
So the *first* time BFS touches a node, it has already found the *shortest* route to it.
That is why you mark a node the moment you push it, never when you pop it.
]

#trap[
Mark `dist[v]` (or `visited[v]`) *when you push*, not when you pop. If you mark on pop,
the same node can be pushed many times before it is popped once, and the queue explodes.
]

#subsection[DFS — depth first search]

DFS dives as deep as it can, then backs up. It uses the *call stack* (or your own stack).

#code(lang: "js", caption: "DFS template, recursive")[
```js
const dfs = (u, g, vis, order) => {
  vis[u] = 1;
  order.push(u);
  for (const v of g[u])
    if (!vis[v]) dfs(v, g, vis, order);
};
```
]

#code(lang: "js", caption: "DFS template, iterative (safe for very deep graphs)")[
```js
const dfsIter = (g, src) => {
  const vis = new Array(g.length).fill(0), order = [];
  const st = [src];
  while (st.length) {
    const u = st.pop();
    if (vis[u]) continue;           // it may have been pushed twice
    vis[u] = 1;
    order.push(u);
    for (let i = g[u].length - 1; i >= 0; i--)
      if (!vis[g[u][i]]) st.push(g[u][i]);
  }
  return order;
};
```
]

On the graph above, both DFS versions print `0 1 3 2` and BFS prints `0 1 2 3`.
BFS distance from node 0 is `0 1 1 2 -1 -1 -1`.

#trap[
*Recursion depth in Node is roughly $10^4$ frames, far below C++ or Java.* This is not a
warning about a rare edge case — it is the single most common way a correct JS graph
solution fails.

Measured, on a chain of $10^5$ nodes:

```text
recursive DFS  -> RangeError: Maximum call stack size exceeded
iterative DFS  -> visits all 100000 nodes
```

So: if the constraint says $n <= 10^5$ *and* the graph can be a long chain, a recursive
DFS is not an option. Use BFS, or the explicit-stack `dfsIter` above. Recursive DFS in
this chapter is shown because it is the clearest way to *explain* an algorithm — say
"recursive for clarity, and I would rewrite it with an explicit stack for $10^5$ nodes",
and the interviewer will nod.

The rewrite has a pattern worth memorising. For a plain visit-order DFS, a stack of nodes
is enough. For anything that does work *after* the children return — low-link, finish
times, subtree sizes — push `[node, childIndex]` pairs and advance the index, doing the
"after child" work when the index runs out. The Kosaraju code later in this chapter is
written exactly that way.
]

#subsection[When to reach for which]

#table(columns: (1fr, 1fr),
  [*Question*], [*Tool*],
  [Fewest edges from A to B], [BFS],
  [Distance rings, "how many minutes"], [BFS (often multi-source)],
  [Is there any path at all], [either — BFS is safer],
  [Count connected pieces], [DFS or BFS or DSU],
  [Cycle in an undirected graph], [DFS/BFS with parent, or DSU],
  [Cycle in a directed graph], [DFS with 3 colours],
  [Bridges, articulation points], [DFS with entry time and low-link],
  [Many "are A and B joined" queries while edges arrive], [DSU],
)

#formulas(title: "Complexity of every traversal in this chapter")[
Time $O(n + m)$. Space $O(n + m)$ for the list, plus $O(n)$ for `visited` and the
queue or stack. That is it. If your answer is worse than $O(n + m)$ for a plain
traversal, something is wrong.
]

#diagram(height: 4.2cm, caption: "BFS grows in rings; DFS follows one thread to the end.")[
  #dnode(0pt, 25pt, 24pt, 20pt, "0")
  #dnode(45pt, 5pt, 24pt, 20pt, "1")
  #dnode(45pt, 50pt, 24pt, 20pt, "2")
  #dnode(95pt, 5pt, 24pt, 20pt, "3")
  #dnode(95pt, 50pt, 24pt, 20pt, "5")
  #dnode(145pt, 27pt, 24pt, 20pt, "4")
  #darrow(24pt, 33pt, 45pt, 17pt)
  #darrow(24pt, 37pt, 45pt, 58pt)
  #darrow(69pt, 15pt, 95pt, 15pt)
  #darrow(69pt, 60pt, 95pt, 60pt)
  #darrow(119pt, 17pt, 145pt, 33pt)
  #place(dx: 200pt, dy: 4pt)[#text(size: 8.5pt)[ring 0: \{0\}]]
  #place(dx: 200pt, dy: 20pt)[#text(size: 8.5pt)[ring 1: \{1, 2\}]]
  #place(dx: 200pt, dy: 36pt)[#text(size: 8.5pt)[ring 2: \{3, 5\}]]
  #place(dx: 200pt, dy: 52pt)[#text(size: 8.5pt)[ring 3: \{4\}]]
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
The edges of an undirected graph with `n = 7` are
`[0,1], [0,2], [1,3], [4,5]`.
Write the degree of every node. (Degree = number of edges touching the node.)
]
#sol[
Walk the edge list and add 1 to *both* ends of each edge.

#table(columns: 8,
  [node], [0], [1], [2], [3], [4], [5], [6],
  [degree], [2], [2], [1], [1], [1], [1], [0],
)

#code(lang: "js", caption: "Degrees from an adjacency list")[
```js
const degrees = (g) => g.map(row => row.length);
```
]
#ans[`2 2 1 1 1 1 0`]
]

#ex(2, tier: 0)[
Same graph. How many edges does it have, if all you are given is the adjacency list?
]
#sol[
Every undirected edge is stored *twice*, once in each end's row. So add up all row
lengths and halve.

$ 2 + 2 + 1 + 1 + 1 + 1 + 0 = 8, quad 8 / 2 = 4 $

#code(lang: "js", caption: "Count edges")[
```js
const countEdges = (g) => g.reduce((s, row) => s + row.length, 0) / 2;
```
]
#ans[4]

#note[
C++ needs a 64-bit integer here because the degree sum of a big graph passes the 32-bit limit.
JavaScript numbers are doubles and hold every integer up to $2^53 - 1$ exactly, so a sum
of $2 m <= 4 times 10^5$ is not remotely a concern. The JS thing to notice instead is that
`/ 2` is *floating-point* division — it returns `3.5` on an odd total rather than
truncating — which is a useful accident here: a fractional answer means your adjacency
list is malformed.
]

#trap[
A *self loop* (edge from node 2 back to node 2) is pushed twice into row 2, so it adds
2 to the degree of one node. The formula still works, but many people forget self loops
exist. Verified: on edges `[0,1], [0,1], [2,2]` the degrees are `2 2 2`.
]
]

#ex(3, tier: 0)[
Run BFS from node 0 on `[0,1], [0,2], [1,3], [4,5]` with `n = 7`.
Give the order nodes leave the queue, and the distance array.
]
#sol[
#table(columns: (auto, auto, 1fr),
  [*pop*], [*pushed now*], [*distance array*],
  [0], [1, 2], [`0 1 1 - - - -`],
  [1], [3], [`0 1 1 2 - - -`],
  [2], [none], [`0 1 1 2 - - -`],
  [3], [none], [`0 1 1 2 - - -`],
)
Nodes 4, 5 and 6 are never reached from 0, so they keep $-1$.
#ans[order `0 1 2 3`, distance `0 1 1 2 -1 -1 -1`]
]

#ex(4, tier: 0)[
Same graph, but run DFS from node 0. Neighbours are visited in the order they appear in
the adjacency row.
]
#sol[
Row 0 is `1 2`. Row 1 is `0 3`.

0 → 1 (first neighbour) → 0 is used → 3 → 3 has only 1, used → back up to 1, back up to
0 → 2.
#ans[`0 1 3 2`]

#note[
Compare with BFS: `0 1 2 3`. Both visit the same four nodes. Only the *order* differs.
If a question asks about *shortest* anything, the order matters and you need BFS.
]
]

#ex(5, tier: 0)[
A graph has 5 nodes and these *directed* edges: `0->1, 1->2, 2->0, 2->3`.
Write the adjacency list.
]
#sol[
Push only into the row of the *source*.
#code(lang: "text", caption: "Directed adjacency list")[
```text
0 -> 1
1 -> 2
2 -> 0 3
3 ->
4 ->
```
]
#ans[as shown above]
]

#ex(6, tier: 0)[
You must answer $10^5$ queries of the form "is there an edge between $u$ and $v$?"
on a graph with $n = 400$ nodes. Which storage do you choose, and why?
]
#sol[
A matrix. $400 times 400 = 160000$ cells, about 160 KB as `char` — tiny.
Each query is then $O(1)$.

With an adjacency list each query costs $O(deg(u))$, which can be 400. Total
$10^5 times 400 = 4 times 10^7$ — it would pass, but the matrix is simpler and faster.
#ans[adjacency matrix]
]

#section[Tier 1 — the standard traversal questions]
#tier-header(1)

#ex(7, tier: 1, asked: "Infosys · pattern")[
*Count connected components.*
Given `n` nodes and a list of undirected edges, count how many separate pieces the graph
breaks into. An isolated node counts as one piece.

Constraints: $n <= 10^5$, $m <= 2 times 10^5$. Target $O(n + m)$.
Edge cases: no edges at all (answer $n$); one node (answer 1).
]
#sol[
#approach(1, "Reachability table", verdict: "O(n(n+m)) — too slow")
For every node run a BFS and record the whole set it can reach. Then sweep and count
how many distinct sets appear.

#code(lang: "js", caption: "Brute force — correct but heavy")[
```js
const componentsBrute = (n, g) => {
  const reach = Array.from({ length: n }, () => new Array(n).fill(false));
  for (let s = 0; s < n; s++) {
    const q = [s]; reach[s][s] = true;
    for (let head = 0; head < q.length; head++) {
      const u = q[head];
      for (const v of g[u]) if (!reach[s][v]) { reach[s][v] = true; q.push(v); }
    }
  }
  const done = new Array(n).fill(false);
  let c = 0;
  for (let i = 0; i < n; i++) {
    if (done[i]) continue;
    c++;
    for (let j = 0; j < n; j++) if (reach[i][j]) done[j] = true;
  }
  return c;
};
```
]
#complexity(time: $O(n(n+m))$, space: $O(n^2)$,
  note: "The n x n table alone is 10^10 bytes at n = 10^5. Impossible.")

#approach(2, "Disjoint set union (DSU)", verdict: "O(m alpha(n)) — good")
Start with $n$ islands. Every edge that joins two different islands reduces the count
by one.

#code(lang: "js", caption: "DSU from the toolkit — do not rewrite it per problem")[
```js
const { DSU } = require('./toolkit.js');   // JS Toolkit appendix

const countComponentsDSU = (n, edges) => {
  const d = new DSU(n);
  let c = n;
  for (const [u, v] of edges) if (d.union(u, v)) c--;   // true = they merged
  return c;
};
```
]

#note[
The toolkit `DSU` is the tested one this book uses everywhere: `find` with path halving,
`union` by rank, and `union` returning `true` only when two different sets actually
merged. That return value is the whole trick behind counting components, counting
redundant edges, and Kruskal's algorithm in Chapter 16 — it is the question "did this edge
join two pieces, or close a loop?" answered in $O(alpha(n))$.

Every DSU-flavoured problem in this chapter is one `require` line plus five lines of
logic. Writing the structure out again is a waste of interview minutes; say "I'd use a
DSU with path compression and union by rank" and use it.
]
#complexity(time: $O(m alpha(n))$, space: $O(n)$,
  note: "alpha(n) is under 5 for any n you will ever see. Treat it as O(m).")

#approach(3, "One DFS per unvisited node", verdict: "O(n+m) — optimal, simplest")
Loop over all nodes. When you find one that is still unvisited, that is a brand new
component: count it, then flood the whole component so you never count it again.

#code(lang: "js", caption: "The version to write in an interview")[
```js
const dfsC = (u, g, vis) => {
  vis[u] = 1;
  for (const v of g[u]) if (!vis[v]) dfsC(v, g, vis);
};

const countComponents = (n, g) => {
  const vis = new Array(n).fill(0);
  let c = 0;
  for (let i = 0; i < n; i++)
    if (!vis[i]) { c++; dfsC(i, g, vis); }
  return c;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n + m)$)

#trap[
This is the recursive one, and at $n = 10^5$ it throws `RangeError: Maximum call stack
size exceeded` the moment the graph contains a long chain. Swap `dfsC` for a BFS flood —
`const q = [i]` with a head index, exactly as in the `bfsDist` template — and the shape of
the solution does not change at all. Every later flood in this chapter is written that
way for precisely this reason.
]

All three were run on `n = 7`, edges `[0,1],[0,2],[1,3],[4,5]`, and all three printed *3*
(the piece `{0,1,2,3}`, the piece `{4,5}`, and the lone node 6). A random cross-check over
500 graphs found zero disagreements.

*The idea that unlocked it:* you never need pairwise information. One outer loop plus one
flood is enough, because a flood consumes the whole piece in one go.
#ans[3]
]

#ex(8, tier: 1, asked: "TCS NQT · pattern")[
*Count the islands.*
A grid of `'1'` (land) and `'0'` (water). Land cells that touch side by side (up, down,
left, right — not diagonally) form one island. Count the islands.

Constraints: grid up to $1000 times 1000$. Target $O(R C)$.
Edge cases: empty grid; grid that is all water; a single `'1'`.
]
#sol[
A grid *is* a graph. Cell `(r,c)` is a node; its neighbours are the four cells next to it.
So this is Example 7 wearing a costume.

#approach(1, "Recursive DFS flood", verdict: "O(R C) but risky")
It works, but a $1000 times 1000$ grid of all land makes one million nested calls. Many
judges crash.

#approach(2, "BFS flood", verdict: "O(R C), no recursion — optimal")

#code(lang: "js", caption: "Count islands with a BFS flood")[
```js
const numIslands = (grid) => {
  if (!grid.length) return 0;
  const g = grid.map(r => [...r]);          // REAL 2D copy — we sink land as we go
  const R = g.length, C = g[0].length;
  const dr = [1, -1, 0, 0], dc = [0, 0, 1, -1];
  let cnt = 0;
  for (let i = 0; i < R; i++)
    for (let j = 0; j < C; j++) {
      if (g[i][j] !== '1') continue;
      cnt++;
      const q = [[i, j]];
      g[i][j] = '0';                        // sink it: this is our "visited"
      for (let head = 0; head < q.length; head++) {
        const [r, c] = q[head];
        for (let k = 0; k < 4; k++) {
          const nr = r + dr[k], nc = c + dc[k];
          if (nr < 0 || nr >= R || nc < 0 || nc >= C || g[nr][nc] !== '1') continue;
          g[nr][nc] = '0';
          q.push([nr, nc]);
        }
      }
    }
  return cnt;
};
```
]
#complexity(time: $O(R C)$, space: $O(R C)$,
  note: "Sinking the land means no separate visited array; the copy is what costs the space.")

Tested grid:
#code(lang: "text", caption: "Input and real output")[
```text
1 1 0 0
1 0 0 1
0 0 1 1
0 0 0 0      ->  islands = 2
empty grid   ->  0
[[0,0],[0,0]] -> 0
[[1]]        ->  1
caller's grid afterwards: unchanged
```
]

#trap[
`grid.map(r => [...r])` is the copy, and it matters twice over.

+ Without a copy at all, the function *destroys* the caller's grid. An interviewer who
  calls your function twice and gets `2` then `0` has found a real bug.
+ With `[...grid]` instead — the obvious-looking "copy" — the outer array is new but every
  row is still the *same* array object, so sinking land still writes through to the
  original. Run it and see: `const c = [...grid]; c[0][0] = 'X';` leaves `grid[0][0]`
  equal to `'X'`.

For a grid of numbers there is also `structuredClone(grid)`, which deep-copies anything.
It is slower, and `map(r => [...r])` is what you should write on a whiteboard.
]

*The idea that unlocked it:* the four direction arrays `dr` / `dc` turn "grid" into
"graph" with three lines of code.
#ans[2]
]

#ex(9, tier: 1, asked: "Wipro · pattern")[
*Cycle in an undirected graph.*
Return true if the graph contains any cycle. The graph may be disconnected.

Constraints: $n <= 10^5$. Target $O(n + m)$.
Edge cases: a single node with no edges (no cycle); two nodes joined by *two* parallel
edges (that IS a cycle).
]
#sol[
#approach(1, "Count edges inside each component", verdict: "O(n+m), easy to explain")
A connected piece with $k$ nodes and no cycle is a *tree*, and a tree has exactly
$k - 1$ edges. So a piece is cycle-free exactly when
#box[edges $= $ nodes $- 1$]. If any piece has edges $>=$ nodes, there is a cycle.

#code(lang: "js", caption: "Cycle test by counting")[
```js
const cycleByCounting = (n, E, g) => {
  const comp = new Array(n).fill(-1);
  let c = 0;
  for (let s = 0; s < n; s++) {
    if (comp[s] !== -1) continue;
    const q = [s]; comp[s] = c;
    for (let head = 0; head < q.length; head++) {
      const u = q[head];
      for (const v of g[u]) if (comp[v] === -1) { comp[v] = c; q.push(v); }
    }
    c++;
  }
  const nodes = new Array(c).fill(0), edges = new Array(c).fill(0);
  for (let i = 0; i < n; i++) nodes[comp[i]]++;
  for (const [u] of E) edges[comp[u]]++;    // destructure just the first endpoint
  for (let i = 0; i < c; i++) if (edges[i] >= nodes[i]) return true;
  return false;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)

#approach(2, "BFS with a parent array", verdict: "O(n+m) — optimal, one pass")
Walk the graph. If you meet a node that is already seen, and it is *not* the node you
came from, you have closed a loop.

#code(lang: "js", caption: "One-pass cycle test")[
```js
const hasCycleUndirected = (n, g) => {
  const par = new Array(n).fill(-2);        // -2 = not seen yet
  for (let s = 0; s < n; s++) {
    if (par[s] !== -2) continue;
    par[s] = -1;                            // root: it has no parent
    const q = [s];
    for (let head = 0; head < q.length; head++) {
      const u = q[head];
      for (const v of g[u]) {
        if (par[v] === -2) { par[v] = u; q.push(v); }
        else if (v !== par[u]) return true;
      }
    }
  }
  return false;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)

Verified outputs: tree plus isolated node → `false`. Add edge `[2,3]` to close a square →
`true`. Triangle → `true`. Two parallel edges between 0 and 1 → `true`. A random
cross-check over 500 graphs found both methods always agreeing.

#note[
`par` is seeded with `-2` for "not seen" and `-1` for "root", so the test must be
`par[v] === -2` with a strict `===`. `-2` and `"-2"` are different values but `==` says
they are equal, and graph inputs parsed from text arrive as strings surprisingly often.
Use `===` everywhere in this book.
]

#trap[
`v != par[u]` compares against the parent of *u*, not of *v*. Writing `v != par[v]` is a
very common bug and always returns false.
]

#trap[
This "skip the parent" trick only works for *undirected* graphs. For directed graphs it
is wrong — use Example 10.
]
#ans[true when any piece has edges $>=$ nodes]
]

#ex(10, tier: 1, asked: "Capgemini · pattern")[
*Cycle in a directed graph.*
Edges are one-way. Return true if some node can reach itself by following arrows.

Constraints: $n <= 10^5$. Target $O(n + m)$.
Edge cases: a self loop `0->0` (that is a cycle); a "diamond" `0->1, 0->2, 1->2`
(that is NOT a cycle even though node 2 is reached twice).
]
#sol[
The parent trick fails here. In the diamond, node 2 is reached from both 0 and 1, but
nothing loops back. What matters is not "seen before" but *"seen on the path I am
standing on right now"*.

Give every node one of three colours.

#formulas(title: "The 3-colour rule")[
- *0 = white* — never touched.
- *1 = grey* — the DFS entered it and has not left yet. It is on the current path.
- *2 = black* — the DFS entered it and already left. Fully finished.

Meeting a *grey* node means you walked back onto your own path. That is a cycle.
Meeting a *black* node means nothing at all.
]

#code(lang: "js", caption: "3-colour DFS")[
```js
const dfsDir = (u, g, col) => {
  col[u] = 1;                            // grey: on the current path
  for (const v of g[u]) {
    if (col[v] === 1) return true;       // back edge -> cycle
    if (col[v] === 0 && dfsDir(v, g, col)) return true;
  }
  col[u] = 2;                            // black: done
  return false;
};

const hasCycleDirected = (n, g) => {
  const col = new Array(n).fill(0);
  for (let i = 0; i < n; i++)
    if (col[i] === 0 && dfsDir(i, g, col)) return true;
  return false;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)

Verified: chain `0->1->2->3` gives `false`. Loop `0->1->2->0` gives `true`. Diamond
`0->1, 0->2, 1->2` gives `false`. Self loop `0->0` gives `true`.

#trap[
Recursive again, so $n = 10^5$ in a chain blows the stack. The iterative rewrite is a
stack of `[node, childIndex]` pairs: colour grey on the way in, advance the index for each
child, and colour black when the index runs out. That is exactly the structure Kahn's
topological sort automates — and "no valid topological order" *is* "the graph has a
cycle", which is the answer worth knowing for Chapter 16.
]

#diagram(height: 3.2cm, caption: "Grey means danger. Black is harmless.")[
  #dnode(0pt, 26pt, 26pt, 20pt, "0", fill: rgb("#d6d6d6"))
  #dnode(60pt, 26pt, 26pt, 20pt, "1", fill: rgb("#d6d6d6"))
  #dnode(120pt, 26pt, 26pt, 20pt, "2", fill: rgb("#d6d6d6"))
  #darrow(26pt, 36pt, 60pt, 36pt)
  #darrow(86pt, 36pt, 120pt, 36pt)
  #darrow(133pt, 20pt, 76pt, 25pt, label: "grey!")
  #place(dx: 175pt, dy: 10pt)[#text(size: 8.5pt)[2 points back to 1,]]
  #place(dx: 175pt, dy: 27pt)[#text(size: 8.5pt)[which is still grey]]
  #place(dx: 175pt, dy: 44pt)[#text(size: 8.5pt)[so the cycle is 1, 2, 1]]
]
#ans[true]
]

#ex(11, tier: 1, asked: "Cognizant · pattern")[
*Bipartite check.*
Can you paint every node red or blue so that no edge joins two nodes of the same colour?

Constraints: $n <= 10^5$. Target $O(n + m)$.
Edge cases: no edges (always yes); a triangle (no); a square (yes).
]
#sol[
#approach(1, "Try every colouring", verdict: "O(2^n m) — only for n <= 20")
Each node is red or blue, so a bitmask of $n$ bits is one attempt. Check every edge.

#code(lang: "js", caption: "Brute force over all 2^n paintings")[
```js
const bipartiteBrute = (n, E) => {
  for (let mask = 0; mask < (1 << n); mask++) {
    let ok = true;
    for (const [u, v] of E) {
      if (((mask >> u) & 1) === ((mask >> v) & 1)) { ok = false; break; }
    }
    if (ok) return true;
  }
  return false;
};
```
]

#trap[
`1 << n` is a *32-bit* operation in JavaScript, however big numbers are elsewhere. At
`n = 31` it goes negative and the loop never runs; at `n = 32` it wraps to `1`. This
brute force is only ever used as a checker for $n <= 20$, so it is safe here — but the
moment you write `1 << k` for a bitmask with more than 30 bits, switch to `2 ** k` (a
double, exact to $2^53$) or to `BigInt`.
]
#complexity(time: $O(2^n m)$, space: $O(1)$, note: "At n = 30 this is already hopeless.")

#approach(2, "BFS and force the colours", verdict: "O(n+m) — optimal")
You never have a choice. Paint the start red. Then every neighbour *must* be blue, every
neighbour of those *must* be red, and so on. If a forced colour clashes with a colour
already written, the answer is no.

#code(lang: "js", caption: "2-colouring by BFS")[
```js
const isBipartite = (n, g) => {
  const c = new Array(n).fill(-1);       // -1 unpainted, 0 red, 1 blue
  for (let s = 0; s < n; s++) {
    if (c[s] !== -1) continue;           // handles disconnected graphs
    c[s] = 0;
    const q = [s];
    for (let head = 0; head < q.length; head++) {
      const u = q[head];
      for (const v of g[u]) {
        if (c[v] === -1) { c[v] = 1 - c[u]; q.push(v); }
        else if (c[v] === c[u]) return false;
      }
    }
  }
  return true;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)

Verified against the brute force on 500 random graphs: zero mismatches.
Triangle → `false`. Square `0-1-2-3-0` → `true`.

#trick[
A graph is bipartite exactly when it has *no odd-length cycle*. A triangle (length 3) kills
it. A square (length 4) does not.
]

#trap[
The outer `for (let s = 0; ...)` loop is not decoration. Without it you only test the
component containing node 0 and silently pass graphs that fail elsewhere.
]
#ans[yes for the square, no for the triangle]
]

#ex(12, tier: 1, asked: "Accenture · pattern")[
*Shortest number of moves in a grid with walls.*
`0` is open, `1` is a wall. You may step up, down, left, right. Return the fewest steps
from `(sr,sc)` to `(tr,tc)`, or $-1$.

Constraints: grid up to $1000 times 1000$.
Edge cases: start equals target (answer 0); target is a wall (answer $-1$).
]
#sol[
#approach(1, "Try every path with DFS", verdict: "exponential — dies at 5 x 5")
#code(lang: "js", caption: "Brute force: every simple path")[
```js
const DR = [1, -1, 0, 0], DC = [0, 0, 1, -1];

const gridBrute = (g, r, c, tr, tc, used) => {
  const R = g.length, C = g[0].length;
  if (r < 0 || r >= R || c < 0 || c >= C || g[r][c] === 1 || used[r][c])
    return Infinity;
  if (r === tr && c === tc) return 0;
  used[r][c] = true;
  let best = Infinity;
  for (let k = 0; k < 4; k++) {
    const sub = gridBrute(g, r + DR[k], c + DC[k], tr, tc, used);
    if (sub !== Infinity) best = Math.min(best, sub + 1);
  }
  used[r][c] = false;
  return best;
};
```
]

#note[
`Infinity` replaces `INT_MAX` and is strictly better for this job: `Infinity + 1` is still
`Infinity`, so an accidental `sub + 1` on an unreachable branch cannot wrap around to a
tiny number the way `INT_MAX + 1` does in C++.
]
#complexity(time: "exponential", space: $O(R C)$,
  note: "Useful only as a checker on tiny grids.")

#approach(2, "BFS", verdict: "O(R C) — optimal")
#code(lang: "js", caption: "Grid BFS")[
```js
const shortestGrid = (g, sr, sc, tr, tc) => {
  const R = g.length, C = g[0].length;
  if (g[sr][sc] === 1 || g[tr][tc] === 1) return -1;
  const d = Array.from({ length: R }, () => new Array(C).fill(-1));
  const q = [[sr, sc]];
  d[sr][sc] = 0;
  for (let head = 0; head < q.length; head++) {
    const [r, c] = q[head];
    if (r === tr && c === tc) return d[r][c];
    for (let k = 0; k < 4; k++) {
      const nr = r + DR[k], nc = c + DC[k];
      if (nr < 0 || nr >= R || nc < 0 || nc >= C ||
          g[nr][nc] === 1 || d[nr][nc] !== -1) continue;
      d[nr][nc] = d[r][c] + 1;
      q.push([nr, nc]);
    }
  }
  return -1;
};
```
]
#complexity(time: $O(R C)$, space: $O(R C)$)

Test grid (0 = open):
#code(lang: "text", caption: "Real runs")[
```text
0 0 0 1
1 1 0 1        (0,0) -> (3,3)  answer 6
0 0 0 0        (0,0) -> (0,0)  answer 0
0 1 1 0        [[0,1],[1,0]] (0,0)->(1,1)  answer -1
```
]
The two were cross-checked on 200 random grids: zero mismatches.

*The idea that unlocked it:* every step costs exactly 1, so "fewest steps" is exactly
what BFS computes for free.
#ans[6]
]

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
*Flood fill.*
Given a grid of colour numbers, a start cell, and a new colour, repaint the whole
connected block of the start cell's colour.

Edge cases: the new colour equals the old colour (do nothing, or you loop forever).
]
#sol[
#code(lang: "js", caption: "Flood fill by BFS")[
```js
const floodFill = (a, sr, sc, newColor) => {
  const R = a.length, C = a[0].length, old = a[sr][sc];
  if (old === newColor) return a;          // THE edge case
  const q = [[sr, sc]];
  a[sr][sc] = newColor;
  for (let head = 0; head < q.length; head++) {
    const [r, c] = q[head];
    for (let k = 0; k < 4; k++) {
      const nr = r + DR[k], nc = c + DC[k];
      if (nr < 0 || nr >= R || nc < 0 || nc >= C || a[nr][nc] !== old) continue;
      a[nr][nc] = newColor;
      q.push([nr, nc]);
    }
  }
  return a;
};
```
]

#note[
This one deliberately paints the caller's grid — that is what "flood fill" means — and
returns it so the call can be chained. JavaScript objects and arrays are passed by
reference, so there is no `&` to write and no copy made: every function in this chapter
that takes a grid either mutates it on purpose or copies it with `map(r => [...r])` on
purpose. Decide which, and say so in the function's first line.
]
#complexity(time: $O(R C)$, space: $O(R C)$)

Real run on
`[[1,1,2],[1,0,1],[2,1,1]]`, start `(0,0)`, new colour 9:
result `[[9,9,2],[9,0,1],[2,1,1]]`. The `0` at `(1,1)` blocks the path, so the two 1s on
the right are a different block and stay.

#trap[
Skip the `old == newColor` guard and the cell is repainted to a colour that still matches
`old`, so it is pushed again, forever.
]
#ans[`[[9,9,2],[9,0,1],[2,1,1]]`]
]

#ex(14, tier: 1, asked: "Infosys · pattern")[
*Largest component.*
Return the number of nodes in the biggest connected piece.
Edge cases: $n = 0$ (answer 0); no edges (answer 1).
]
#sol[
Same skeleton as counting components, but count the nodes you flood.

#code(lang: "js", caption: "Biggest piece")[
```js
const largestComponent = (n, g) => {
  const vis = new Array(n).fill(0);
  let best = 0;
  for (let i = 0; i < n; i++) {
    if (vis[i]) continue;
    let cnt = 0;
    const q = [i]; vis[i] = 1;
    for (let head = 0; head < q.length; head++) {
      const u = q[head]; cnt++;
      for (const v of g[u]) if (!vis[v]) { vis[v] = 1; q.push(v); }
    }
    best = Math.max(best, cnt);
  }
  return best;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)
Verified: on `n = 7` with edges `[0,1],[0,2],[1,3],[4,5]` the answer is *4*.
#ans[4]
]

#ex(15, tier: 1, asked: "TCS NQT · pattern")[
*Provinces from a matrix.*
You are given an $n times n$ table where `m[i][j] = 1` means city $i$ and city $j$ are
directly linked. Count the groups of linked cities.

Constraints: $n <= 500$ (so $n^2$ is fine).
Edge cases: $n = 1$ (answer 1); the identity matrix (answer $n$).
]
#sol[
The input is a matrix, so reading it already costs $O(n^2)$. Only the upper triangle
matters, because the table is symmetric.

#code(lang: "js", caption: "Provinces with DSU")[
```js
const provinces = (m) => {
  const n = m.length;
  const d = new DSU(n);
  let c = n;
  for (let i = 0; i < n; i++)
    for (let j = i + 1; j < n; j++)
      if (m[i][j] === 1 && d.union(i, j)) c--;
  return c;
};
```
]
#complexity(time: $O(n^2 alpha(n))$, space: $O(n)$)
Verified: `[[1,1,0],[1,1,0],[0,0,1]]` → *2*. `[[1]]` → 1. `[[1,0],[0,1]]` → 2.
#ans[2]
]

#ex(16, tier: 1, asked: "Capgemini · pattern")[
*Is there a path?*
Undirected graph, a source and a destination. Return true if a route exists.
Edge cases: source equals destination (true, even with no edges).
]
#sol[
#approach(1, "Repeated relaxation over the edge list", verdict: "O(n m)")
Keep a `reachable` flag per node. Sweep the whole edge list again and again until nothing
changes.

#code(lang: "js", caption: "Brute force")[
```js
const pathExistsBrute = (n, E, s, t) => {
  const r = new Array(n).fill(false);
  r[s] = true;
  for (let pass = 0; pass < n; pass++) {
    let changed = false;
    for (const [u, v] of E) {
      if (r[u] && !r[v]) { r[v] = true; changed = true; }
      if (r[v] && !r[u]) { r[u] = true; changed = true; }
    }
    if (!changed) break;
  }
  return r[t];
};
```
]
#complexity(time: $O(n m)$, space: $O(n)$)

#approach(2, "BFS", verdict: "O(n+m) — optimal")
#code(lang: "js", caption: "The obvious answer")[
```js
const pathExistsBFS = (n, g, s, t) => {
  if (s === t) return true;
  const vis = new Array(n).fill(false);
  const q = [s]; vis[s] = true;
  for (let head = 0; head < q.length; head++) {
    const u = q[head];
    for (const v of g[u]) {
      if (v === t) return true;
      if (!vis[v]) { vis[v] = true; q.push(v); }
    }
  }
  return false;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)
Cross-checked on 300 random graphs: zero mismatches.
#ans[true / false]
]

#ex(17, tier: 1, asked: "Wipro · pattern")[
*Which nodes are exactly $k$ edges away from the source?*
Constraints: $n <= 10^5$. Edge cases: $k = 0$ (only the source); $k$ larger than the
graph's reach (empty list).
]
#sol[
BFS gives you distance for free. The only trick is to *stop expanding* once a node sits
at distance $k$ — going deeper cannot help.

#code(lang: "js", caption: "Nodes at distance exactly k")[
```js
const atDistanceK = (n, g, src, k) => {
  const dist = new Array(n).fill(-1), res = [];
  const q = [src]; dist[src] = 0;
  for (let head = 0; head < q.length; head++) {
    const u = q[head];
    if (dist[u] === k) { res.push(u); continue; }    // do not go deeper
    for (const v of g[u])
      if (dist[v] === -1) { dist[v] = dist[u] + 1; q.push(v); }
  }
  return res;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)
Real run on the tree `0-1, 0-2, 1-3, 2-4, 4-5, 5-6`:
$k = 2$ → `3 4`; $k = 0$ → `0`; $k = 9$ → empty.
#ans[`3 4`]
]

#section[Tier 2 — traversal with a business story]
#tier-header(2)

#ex(18, tier: 2, asked: "Grab · pattern")[
*Spoilage in a warehouse.*
A warehouse shelf is a grid. `0` is an empty slot, `1` is a fresh box, `2` is a spoiled
box. Every minute, a spoiled box spoils every fresh box directly beside it (4
directions). Return the minute at which nothing fresh is left, or $-1$ if some box can
never spoil.

Constraints: grid up to $500 times 500$.
Edge cases: no fresh boxes at all (answer 0); a fresh box walled off by empty slots
(answer $-1$).
]
#sol[
#approach(1, "Simulate minute by minute", verdict: "O(R C x minutes)")
Each minute, scan the whole grid, list the fresh boxes touching a spoiled one, then
spoil them all together.

#code(lang: "js", caption: "Brute force simulation")[
```js
const spreadBrute = (grid) => {
  const g = grid.map(r => [...r]);
  const R = g.length, C = g[0].length;
  let t = 0;
  for (;;) {
    const todo = [];
    for (let i = 0; i < R; i++)
      for (let j = 0; j < C; j++) {
        if (g[i][j] !== 1) continue;
        for (let k = 0; k < 4; k++) {
          const nr = i + DR[k], nc = j + DC[k];
          if (nr < 0 || nr >= R || nc < 0 || nc >= C) continue;
          if (g[nr][nc] === 2) { todo.push([i, j]); break; }
        }
      }
    if (!todo.length) break;
    for (const [r, c] of todo) g[r][c] = 2;
    t++;
  }
  for (let i = 0; i < R; i++)
    for (let j = 0; j < C; j++) if (g[i][j] === 1) return -1;
  return t;
};
```
]
#complexity(time: $O(R C times T)$, space: $O(R C)$,
  note: "T can be R x C, so the worst case is 6 x 10^10 cell visits at 500 x 500.")

#approach(2, "Multi-source BFS", verdict: "O(R C) — optimal")
Put *every* spoiled box in the queue before the loop starts. Then one BFS ring equals one
minute. No re-scanning.

#code(lang: "js", caption: "Multi-source BFS, level by level")[
```js
const spreadTime = (grid) => {
  const g = grid.map(r => [...r]);           // we mutate, so copy every ROW
  const R = g.length, C = g[0].length;
  let fresh = 0, t = 0;
  const q = [];
  for (let i = 0; i < R; i++)
    for (let j = 0; j < C; j++) {
      if (g[i][j] === 2) q.push([i, j]);     // ALL sources go in first
      else if (g[i][j] === 1) fresh++;
    }
  if (fresh === 0) return 0;
  let head = 0;
  while (head < q.length) {
    const sz = q.length - head;              // one whole ring = one minute
    let changed = false;
    for (let s = 0; s < sz; s++) {
      const [r, c] = q[head++];
      for (let k = 0; k < 4; k++) {
        const nr = r + DR[k], nc = c + DC[k];
        if (nr < 0 || nr >= R || nc < 0 || nc >= C || g[nr][nc] !== 1) continue;
        g[nr][nc] = 2; fresh--; changed = true;
        q.push([nr, nc]);
      }
    }
    if (changed) t++;
  }
  return fresh === 0 ? t : -1;
};
```
]
#complexity(time: $O(R C)$, space: $O(R C)$)

#trap[
`const sz = q.length - head` must be read *before* the inner loop starts, because the loop
pushes onto `q` as it goes. Capture the ring size first, then consume exactly that many.
This is the head-index version of the classic `int sz = q.size()` line, and getting it
wrong merges two minutes into one.
]

Real runs:
#code(lang: "text", caption: "Verified output")[
```text
2 1 1
1 1 0   -> 4
0 1 1

2 1 1
0 1 1   -> -1   (the 1 at the bottom-left is cut off)
1 0 1

0 2     -> 0    (nothing fresh)
```
]
Both versions were cross-checked on 200 random grids: zero mismatches.

*The idea that unlocked it:* seeding the queue with all sources at once makes BFS measure
distance to the *nearest* source instead of to one chosen source. That single change
removes the outer time loop.

#trap[
`if (changed) t++` matters. Without the guard, the last ring (which spoils nothing) still
bumps the counter and you answer one minute too many.
]

#note[
Verified against the brute-force simulation on 200 random grids: zero mismatches. Writing
the slow version as a *checker* costs three minutes and is the single most effective way
to catch off-by-one bugs like the one above.
]
#ans[4]
]

#ex(19, tier: 2, asked: "Sea / Shopee · pattern")[
*Fewest knight hops.*
A knight sits on an $N times N$ board. It moves in the usual L shape. Return the fewest
moves to reach a target square, or $-1$.

Constraints: $N <= 300$. Edge cases: start equals target (0); a $3 times 3$ board where
the centre is unreachable.
]
#sol[
There is no adjacency list to build — the neighbours of a square are computed on the fly
from 8 offsets. This is called an *implicit graph*.

#code(lang: "js", caption: "BFS on the knight's implicit graph")[
```js
const knightMoves = (N, sr, sc, tr, tc) => {
  const d = Array.from({ length: N }, () => new Array(N).fill(-1));
  const dr = [1, 1, -1, -1, 2, 2, -2, -2];
  const dc = [2, -2, 2, -2, 1, -1, 1, -1];
  const q = [[sr, sc]]; d[sr][sc] = 0;
  for (let head = 0; head < q.length; head++) {
    const [r, c] = q[head];
    if (r === tr && c === tc) return d[r][c];
    for (let k = 0; k < 8; k++) {
      const nr = r + dr[k], nc = c + dc[k];
      if (nr < 0 || nr >= N || nc < 0 || nc >= N || d[nr][nc] !== -1) continue;
      d[nr][nc] = d[r][c] + 1;
      q.push([nr, nc]);
    }
  }
  return -1;
};
```
]
#complexity(time: $O(N^2)$, space: $O(N^2)$)
Verified: $8 times 8$, $(0,0) -> (7,7)$ → *6*. $(0,0) -> (1,2)$ → 1.
$3 times 3$, $(0,0) -> (1,1)$ → $-1$ (a knight can never reach the centre of a
$3 times 3$ board).
#ans[6]
]

#ex(20, tier: 2, asked: "Agoda · pattern")[
*Fewest button presses.*
A counter shows the number `start`. Three buttons: add 1, subtract 1, double. The counter
can never go below 0. Reach `target` in the fewest presses.

Constraints: `start`, `target` up to $10^5$.
Edge cases: `start == target` (0); target smaller than start (only subtract helps).
]
#sol[
Nodes are *numbers*, edges are *button presses*. Every press costs 1, so BFS again.

The only real design decision is the upper bound. Doubling past $2 times "target"$ is
never useful: from there you can only come down one step at a time, and walking down from
`target + k` costs $k$ presses, which you could have saved. A safe bound is
$max("start", 2 times "target") + 2$.

#code(lang: "js", caption: "Implicit BFS over numbers")[
```js
const fewestPresses = (start, target) => {
  if (start === target) return 0;
  const LIM = Math.max(start, 2 * target) + 2;   // must cover the START too
  const dist = new Array(LIM + 1).fill(-1);
  const q = [start]; dist[start] = 0;
  for (let head = 0; head < q.length; head++) {
    const u = q[head];
    for (const v of [u + 1, u - 1, u * 2]) {
      if (v < 0 || v > LIM || dist[v] !== -1) continue;
      dist[v] = dist[u] + 1;
      if (v === target) return dist[v];
      q.push(v);
    }
  }
  return -1;
};
```
]
#complexity(time: $O("LIM")$, space: $O("LIM")$)
Verified: `3 -> 10` gives 3 (`3, 4, 5, 10`). `2 -> 9` gives 3 (`2, 4, 8, 9`).
`10 -> 1` gives 9. `0 -> 7` gives 5. `1 -> 1024` gives 10. `5 -> 5` gives 0.

#trap[
Writing `const LIM = 2 * target + 2;` looks right and breaks when `start > LIM`, and in
JavaScript it breaks *silently*. C++ reads past the end of the vector and usually crashes;
JS returns `undefined` for `dist[start]`, the test `dist[v] !== -1` is then `true` for
every out-of-range index, and the BFS simply reports `-1` with no error at all. The test
`10 -> 1` catches it. Always ask: is the start itself inside my array?
]
#ans[3]
]

#ex(21, tier: 2, asked: "DBS · pattern")[
*Enclosed desks.*
An office floor is a grid of `'X'` (wall) and `'O'` (desk). Any group of desks that can
reach the outer border stays. Every other group is enclosed and must be turned into
`'X'`.

Edge cases: a desk on the border (its whole group survives); no desks at all.
]
#sol[
Do not hunt for enclosed groups. Hunt for the *safe* ones — they are exactly the groups
that touch the border.

Three steps:
+ Start a BFS from every `'O'` on the four borders. Mark everything it reaches `'S'`.
+ Every `'S'` becomes `'O'` again.
+ Everything else becomes `'X'`.

#code(lang: "js", caption: "Mark the survivors, flip the rest")[
```js
const captureRegions = (b) => {
  if (!b.length) return b;
  const R = b.length, C = b[0].length;
  const q = [];
  const seed = (r, c) => {                  // a closure over q and b
    if (b[r][c] === 'O') { b[r][c] = 'S'; q.push([r, c]); }
  };
  for (let i = 0; i < R; i++) { seed(i, 0); seed(i, C - 1); }
  for (let j = 0; j < C; j++) { seed(0, j); seed(R - 1, j); }
  for (let head = 0; head < q.length; head++) {
    const [r, c] = q[head];
    for (let k = 0; k < 4; k++) {
      const nr = r + DR[k], nc = c + DC[k];
      if (nr < 0 || nr >= R || nc < 0 || nc >= C) continue;
      seed(nr, nc);
    }
  }
  for (let i = 0; i < R; i++)
    for (let j = 0; j < C; j++)
      b[i][j] = b[i][j] === 'S' ? 'O' : 'X';
  return b;
};
```
]

#note[
The helper is named `seed`, not `push`, on purpose — `push` is already the array method
and shadowing the word in your own head causes real confusion at the whiteboard. An arrow
function declared inside the outer function closes over `q` and `b` automatically; this is
JavaScript's version of C++'s `[&]` capture, and it needs no capture list.
]
#complexity(time: $O(R C)$, space: $O(R C)$)

Real run:
#code(lang: "text", caption: "Before and after")[
```text
X X X X        X X X X
X O O X   ->   X X X X
X X O X        X X X X
X O X X        X O X X
```
]
The `'O'` at the bottom-left is on the border, so it survives. The three in the middle are
enclosed and become `'X'`.

*The idea that unlocked it:* flip the question. "Find enclosed" is hard; "find what
touches the border" is one multi-source BFS.
#ans[as shown]
]

#ex(22, tier: 2, asked: "LINE MAN · pattern")[
*Delivery zones with diagonals.*
Same island counting, but two land cells are in the same zone if they touch on a side
*or a corner* (8 directions). Count the zones.
Edge cases: a checkerboard (all one zone with 8 directions, many zones with 4).
]
#sol[
Change 4 offsets to 8. Everything else is identical. Writing the two loops
`for dr in -1..1, for dc in -1..1` with a skip on `(0,0)` is shorter than listing 8 pairs.

#code(lang: "js", caption: "8-direction flood")[
```js
const numIslands8 = (grid) => {
  if (!grid.length) return 0;
  const g = grid.map(r => [...r]);
  const R = g.length, C = g[0].length;
  let cnt = 0;
  for (let i = 0; i < R; i++)
    for (let j = 0; j < C; j++) {
      if (g[i][j] !== 1) continue;
      cnt++;
      const q = [[i, j]]; g[i][j] = 0;
      for (let head = 0; head < q.length; head++) {
        const [r, c] = q[head];
        for (let dr = -1; dr <= 1; dr++)
          for (let dc = -1; dc <= 1; dc++) {
            if (dr === 0 && dc === 0) continue;
            const nr = r + dr, nc = c + dc;
            if (nr < 0 || nr >= R || nc < 0 || nc >= C || g[nr][nc] !== 1) continue;
            g[nr][nc] = 0; q.push([nr, nc]);
          }
      }
    }
  return cnt;
};
```
]
#complexity(time: $O(R C)$, space: $O(R C)$)
Verified: `[[1,0,1],[0,1,0],[1,0,1]]` → *1* with 8 directions (it would be 5 with 4
directions). `[[1,0],[0,1]]` → 1.
#ans[1]
]

#ex(23, tier: 2, asked: "GIC · pattern")[
*How many shortest routes?*
Unweighted graph. For every node, report both the shortest distance from the source and
*how many* different shortest routes reach it.

Constraints: $n <= 10^5$; counts grow like a product and can pass $2^53 - 1$.
Edge cases: unreachable node (distance $-1$, count 0); the source itself (distance 0,
count 1).
]
#sol[
Extend BFS with a `ways` array. When you *first* reach `v` from `u`, it inherits `u`'s
count. When you reach it again at the *same* distance, add.

#code(lang: "js", caption: "BFS that also counts routes")[
```js
const countShortestPaths = (n, g, src) => {
  const dist = new Array(n).fill(-1);
  const ways = new Array(n).fill(0);
  dist[src] = 0; ways[src] = 1;
  const q = [src];
  for (let head = 0; head < q.length; head++) {
    const u = q[head];
    for (const v of g[u]) {
      if (dist[v] === -1) {                     // first time: new distance
        dist[v] = dist[u] + 1;
        ways[v] = ways[u];
        q.push(v);
      } else if (dist[v] === dist[u] + 1) {     // another equally short route
        ways[v] += ways[u];
      }
    }
  }
  return { dist, ways };      // one object, destructured by the caller
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)

#note[
Returning `{ dist, ways }` and calling it as
`const { dist, ways } = countShortestPaths(n, g, 0);` is the JS answer to C++'s
`pair<...>`: the fields have *names*, so the caller cannot silently swap them the way
`.first` and `.second` invite. Use an object for every multi-value return in this book.
]

Real run on `0-1, 0-2, 1-3, 2-3, 3-4, 4-5`:
#code(lang: "text", caption: "Verified output")[
```text
dist: 0 1 1 2 3 4
ways: 1 1 1 2 2 2
```
]
Node 3 has two shortest routes (`0-1-3` and `0-2-3`), and nodes 4 and 5 inherit that 2.

#trap[
Counts grow like a product and explode fast. Plain JS numbers stay exact only to
$2^53 - 1$, and past that they *round* — the count keeps looking like a plausible integer
while being wrong. Two correct answers, and you should name the one the statement asks
for:

- If the statement says "modulo $10^9 + 7$", take the modulus at *every* `+=`:
  `ways[v] = (ways[v] + ways[u]) % MOD`. Each intermediate stays under $2 times 10^9$,
  far inside the exact range, so plain numbers are fine.
- If the statement wants the true count, use `BigInt`: `ways` is filled with `0n`,
  `ways[src] = 1n`, and `+=` needs no other change. Just never mix — `1n + 1` throws a
  `TypeError`.

Beware the modular *multiply*, though: `(a * b) % MOD` with `a`, `b` near $10^9$ needs
$10^18$ of headroom and silently rounds. Measured, with `MOD = 1000000007`,
`a = 999999937` and `b = 999999893`:

```text
(a * b) % MOD                                 -> 8023     WRONG
Number((BigInt(a) * BigInt(b)) % BigInt(MOD)) -> 7980     correct
```

Plain addition, as used here, is safe; a modular multiply is not.
]

#trap[
The `else if` must test `dist[v] == dist[u] + 1`. If you test only `dist[v] != -1` you
will add routes that are longer, and the count becomes garbage.
]
#ans[`ways = 1 1 1 2 2 2`]
]

#ex(24, tier: 2, asked: "SCB · pattern")[
*Name one broken dependency loop.*
A build system has services and one-way "needs" arrows. If the arrows contain a loop, the
build never finishes. Print one loop, in order. Print nothing if there is no loop.

Edge cases: no loop at all; a self loop.
]
#sol[
Reuse the 3-colour DFS, but remember the parent of each node. The moment you step onto a
*grey* node `v` from node `u`, the loop is: `v`, then the chain of parents from `u` back
up to `v`.

#code(lang: "js", caption: "Find and print one directed cycle")[
```js
class CycleFinder {
  constructor(n) {
    this.n = n;
    this.g = Array.from({ length: n }, () => []);
    this.col = new Array(n).fill(0);
    this.par = new Array(n).fill(-1);
    this.st = -1; this.en = -1;
  }
  addEdge(u, v) { this.g[u].push(v); }
  dfs(u) {
    this.col[u] = 1;
    for (const v of this.g[u]) {
      if (this.col[v] === 0) { this.par[v] = u; if (this.dfs(v)) return true; }
      else if (this.col[v] === 1) { this.st = v; this.en = u; return true; }
    }
    this.col[u] = 2;
    return false;
  }
  run() {
    for (let i = 0; i < this.n; i++) if (this.col[i] === 0 && this.dfs(i)) break;
    if (this.st === -1) return [];
    const c = [];
    for (let v = this.en; v !== this.st; v = this.par[v]) c.push(v);
    c.push(this.st);
    return c.reverse();
  }
}
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)
Verified on `0->1, 1->2, 2->3, 3->1, 0->4`: prints `1 2 3`, meaning
$1 -> 2 -> 3 -> 1$. On `0->1, 1->2` it prints nothing.
#ans[`1 2 3`]
]

#section[Tier 3 — the hard ones]
#tier-header(3)

#ex(25, tier: 3, asked: "Amazon · pattern")[
*Critical links.*
A network of servers is joined by two-way cables. A cable is *critical* if removing it
splits some group of servers apart. List every critical cable.

Constraints: $n <= 10^5$, $m <= 2 times 10^5$. Target $O(n + m)$.
Edge cases: two servers joined by *two* parallel cables (neither is critical); a chain
(every cable is critical).
]
#sol[
#approach(1, "Remove one cable, test connectivity", verdict: "O(m(n+m)) — too slow")
For each of the $m$ cables, delete it and count components. If the count went up, it was
critical. At $m = 2 times 10^5$ this is about $10^{10}$ operations.

#approach(2, "One DFS with entry times and low-link", verdict: "O(n+m) — optimal")

#formulas(title: "The low-link idea")[
Run one DFS. Give each node the time it was entered, `tin[u]` (0, 1, 2, ...).

Define `low[u]` = the *smallest* `tin` value reachable from the subtree of `u`, using
tree edges downwards plus *at most one* back edge upwards.

Then the edge $u -> v$ (a tree edge, $v$ a child) is a bridge exactly when
$ "low"[v] > "tin"[u] $
In words: nothing in $v$'s subtree can climb back to $u$ or above it without using that
very edge. So the edge is the only link.
]

#code(lang: "js", caption: "Bridges by Tarjan low-link")[
```js
class BridgeFinder {
  constructor(n) {
    this.n = n; this.timer = 0;
    this.g = Array.from({ length: n }, () => []);   // entries are [neighbour, edge id]
    this.tin = new Array(n).fill(-1);
    this.low = new Array(n).fill(-1);
    this.bridges = [];
  }
  addEdge(id, u, v) { this.g[u].push([v, id]); this.g[v].push([u, id]); }
  dfs(u, pid) {
    this.tin[u] = this.low[u] = this.timer++;
    for (const [v, id] of this.g[u]) {
      if (id === pid) continue;           // do not walk back on the SAME edge
      if (this.tin[v] !== -1) this.low[u] = Math.min(this.low[u], this.tin[v]);
      else {
        this.dfs(v, id);
        this.low[u] = Math.min(this.low[u], this.low[v]);
        if (this.low[v] > this.tin[u])
          this.bridges.push([Math.min(u, v), Math.max(u, v)]);
      }
    }
  }
  run() {
    for (let i = 0; i < this.n; i++) if (this.tin[i] === -1) this.dfs(i, -1);
    return this.bridges;
  }
}
```
]
#complexity(time: $O(n + m)$, space: $O(n + m)$)

Verified on the triangle `0-1-2-0` plus the tail `2-3`, `3-4`: the bridges are `(3,4)` and
`(2,3)`, reported in that order — the deepest one finishes first. The triangle's own edges
are not bridges. On two parallel edges `0-1` and `0-1`: *no* bridges. On a chain `0-1-2`:
both edges, `(1,2)` then `(0,1)`.

#trap[
This is recursive, so it inherits the $10^4$-frame ceiling. At $n = 10^5$ — exactly this
problem's stated limit — a long chain blows the stack. The rewrite is the `[node,
childIndex]` stack from the DFS section: the "after child" work (`low[u] = min(low[u],
low[v])` and the bridge test) happens when you pop a child's frame. Know that this is what
you would do, and say so before the interviewer asks.
]

#trap[
Skip by *edge id*, not by parent node. If you write `if (v === p) continue;` then two
parallel edges between `u` and `v` are both skipped, and the code wrongly reports a
bridge. Using the id skips exactly one of the two.
]

*Follow-up the interviewer asks next: "now give me the articulation points."*
An articulation *point* is a node whose removal splits the graph. Same DFS, one changed
test, plus a special rule for the DFS root.

#code(lang: "js", caption: "Articulation points")[
```js
class APFinder {
  constructor(n) {
    this.n = n; this.timer = 0;
    this.g = Array.from({ length: n }, () => []);
    this.tin = new Array(n).fill(-1);
    this.low = new Array(n).fill(-1);
    this.isAP = new Array(n).fill(false);
  }
  addEdge(u, v) { this.g[u].push(v); this.g[v].push(u); }
  dfs(u, p) {
    this.tin[u] = this.low[u] = this.timer++;
    let children = 0;
    for (const v of this.g[u]) {
      if (v === p) continue;
      if (this.tin[v] !== -1) this.low[u] = Math.min(this.low[u], this.tin[v]);
      else {
        this.dfs(v, u);
        this.low[u] = Math.min(this.low[u], this.low[v]);
        if (this.low[v] >= this.tin[u] && p !== -1) this.isAP[u] = true;  // note >=
        children++;
      }
    }
    if (p === -1 && children > 1) this.isAP[u] = true;                    // root rule
  }
  run() {
    for (let i = 0; i < this.n; i++) if (this.tin[i] === -1) this.dfs(i, -1);
    return this.isAP.map((b, i) => b ? i : -1).filter(i => i !== -1);
  }
}
```
]
Verified on the same graph (triangle 0-1-2 plus tail 2-3-4): articulation points are
`2` and `3`. On a chain `0-1-2`: only `1`. On a triangle: none.

The last line turns a boolean array into a list of indices. `isAP.filter(Boolean)` would
be wrong — it returns the `true` *values*, not where they were — so map to the index
first, then drop the `-1`s.

#formulas(title: "Bridge vs articulation point — the one-character difference")[
- Bridge: #box[`low[v] > tin[u]`] — strictly greater.
- Articulation point: #box[`low[v] >= tin[u]`] — greater *or equal*, plus the root needs
  two or more DFS children.

Why? A child that can climb back exactly to $u$ (equality) still cannot get *past* $u$.
Deleting the edge is fine; deleting the node $u$ is not.
]
#ans[`(2,3)` and `(3,4)`]
]

#ex(26, tier: 3, asked: "Google · pattern")[
*Groups that can all reach each other (SCC).*
A directed graph. Two nodes are in the same group if each can reach the other. Count the
groups and label every node.

Constraints: $n <= 10^5$. Target $O(n + m)$.
Edge cases: a chain (every node is its own group); one node (1 group).
]
#sol[
#approach(1, "Reachability from everybody", verdict: "O(n(n+m)) — too slow")
Run a DFS from each node in the graph, and a DFS from each node in the reversed graph.
Group $u$ and $v$ together when each appears in the other's list.

#approach(2, "Kosaraju — two passes", verdict: "O(n+m) — optimal")

#formulas(title: "Kosaraju in three lines")[
+ DFS the graph, and push each node onto a list *when it finishes*. The list ends with
  the node that finished last.
+ Reverse every edge.
+ Walk the list *backwards*. Each fresh DFS in the reversed graph collects exactly one
  group.

Why it works: reversing keeps the groups the same (if $u$ reaches $v$ and back, the
reversed graph says the same). Taking the latest-finishing node first guarantees you
start in a group that no *other* unvisited group points into, so the reversed DFS cannot
leak out of it.
]

#code(lang: "js", caption: "Kosaraju — both passes iterative, so 10^5 nodes are safe")[
```js
class Kosaraju {
  constructor(n) {
    this.n = n;
    this.g = Array.from({ length: n }, () => []);
    this.rg = Array.from({ length: n }, () => []);
    this.vis = new Array(n).fill(0);
    this.comp = new Array(n).fill(-1);
    this.order = [];
  }
  addEdge(u, v) { this.g[u].push(v); this.rg[v].push(u); }

  dfs1(u) {                          // stack of [node, childIndex]
    const st = [[u, 0]];
    this.vis[u] = 1;
    while (st.length) {
      const top = st[st.length - 1];
      if (top[1] < this.g[top[0]].length) {
        const v = this.g[top[0]][top[1]++];        // take the next child
        if (!this.vis[v]) { this.vis[v] = 1; st.push([v, 0]); }
      } else {
        this.order.push(top[0]);                   // push on FINISH
        st.pop();
      }
    }
  }

  dfs2(u, c) {                       // plain flood: no post-order work needed
    const st = [u];
    this.comp[u] = c;
    while (st.length) {
      const x = st.pop();
      for (const v of this.rg[x])
        if (this.comp[v] === -1) { this.comp[v] = c; st.push(v); }
    }
  }

  run() {
    for (let i = 0; i < this.n; i++) if (!this.vis[i]) this.dfs1(i);
    let c = 0;
    for (let i = this.n - 1; i >= 0; i--) {        // latest finisher first
      const u = this.order[i];
      if (this.comp[u] === -1) this.dfs2(u, c++);
    }
    return c;
  }
}
```
]
#complexity(time: $O(n + m)$, space: $O(n + m)$)

Verified on `0->1, 1->2, 2->0, 2->3, 3->4, 4->5, 5->3`:
count = *2*, labels `0 0 0 1 1 1`. Chain `0->1->2` gives 3 groups. One node gives 1.
A chain of *200000* nodes gives 200000 groups and does not overflow the stack — the
recursive version dies there, which is why `dfs1` is written with an explicit stack.

#note[
Compare `dfs1` and `dfs2`. The first pass must record each node *when it finishes*, so it
needs the `[node, childIndex]` stack that remembers how far through the children it got.
The second pass only paints labels, with nothing to do on the way back up, so a plain
stack of nodes is enough. Recognising which of the two shapes a DFS needs is the whole
skill of converting recursion to iteration.
]

*Follow-up: "shrink each group to a single node — what do you get?"*
You get the *condensation*, and it is always a DAG (a directed graph with no cycles). If
it had a cycle, the groups on that cycle could all reach each other, so they would have
been one group. The condensation is the first step in almost every hard directed-graph
problem.

*Follow-up: "how many extra edges make the whole graph one group?"*
Build the condensation. Let $a$ = number of groups with no incoming edge, $b$ = number
with no outgoing edge. If the condensation has only one node the answer is 0, otherwise
it is $max(a, b)$.
#ans[2 groups; labels `0 0 0 1 1 1`]
]

#ex(27, tier: 3, asked: "Microsoft · pattern")[
*Best single reclamation.*
An $n times n$ grid of 0 (water) and 1 (land). You may turn *at most one* 0 into a 1.
Return the largest island you can end up with.

Constraints: $n <= 500$. Target $O(n^2)$.
Edge cases: the grid is already all land (answer $n^2$, you flip nothing); all water
(answer 1).
]
#sol[
#approach(1, "Flip each 0 and recount", verdict: "O(n^4) — too slow")
There are up to $n^2$ zeros and each recount costs $O(n^2)$. At $n = 500$ that is
$6 times 10^{10}$.

#approach(2, "Label the islands once, then look at each 0's four neighbours",
  verdict: "O(n^2) — optimal")

Two passes:
+ Flood every island once. Give each island a *label* (2, 3, 4, ...) and record its size.
  Labels start at 2 so they can never be confused with 0 or 1.
+ For each water cell, look at its (at most 4) neighbours, collect the *distinct* labels,
  and add up their sizes plus 1 for the flipped cell.

The "distinct" part is essential: two neighbours can belong to the same island, and you
must not count it twice.

#code(lang: "js", caption: "Label, then merge")[
```js
const largestIslandAfterFlip = (grid) => {
  const g = grid.map(r => [...r]);
  const n = g.length;
  const id = Array.from({ length: n }, () => new Array(n).fill(0));
  const area = new Map();                    // label -> size
  let label = 2;
  for (let i = 0; i < n; i++)
    for (let j = 0; j < n; j++) {
      if (g[i][j] !== 1 || id[i][j]) continue;
      let cnt = 0;
      const q = [[i, j]]; id[i][j] = label;
      for (let head = 0; head < q.length; head++) {
        const [r, c] = q[head]; cnt++;
        for (let k = 0; k < 4; k++) {
          const nr = r + DR[k], nc = c + DC[k];
          if (nr < 0 || nr >= n || nc < 0 || nc >= n ||
              g[nr][nc] !== 1 || id[nr][nc]) continue;
          id[nr][nc] = label; q.push([nr, nc]);
        }
      }
      area.set(label++, cnt);
    }
  let best = 0;
  for (const size of area.values()) best = Math.max(best, size);   // flip nothing
  for (let i = 0; i < n; i++)
    for (let j = 0; j < n; j++) {
      if (g[i][j] !== 0) continue;
      const seen = new Set();
      let tot = 1;
      for (let k = 0; k < 4; k++) {
        const nr = i + DR[k], nc = j + DC[k];
        if (nr < 0 || nr >= n || nc < 0 || nc >= n || id[nr][nc] === 0) continue;
        if (!seen.has(id[nr][nc])) {
          seen.add(id[nr][nc]);
          tot += area.get(id[nr][nc]);
        }
      }
      best = Math.max(best, tot);
    }
  return best;
};
```
]
#complexity(time: $O(n^2)$, space: $O(n^2)$, note: "The Set holds at most 4 labels.")

Verified: `[[1,0],[0,1]]` → *3*. `[[1,1],[1,1]]` → 4 (no flip needed, and no 0 exists).
`[[0,0],[0,0]]` → 1. `[[1,1,0],[1,0,0],[0,0,1]]` → 4.

#note[
C++ writes `if (seen.insert(x).second)` because `insert` reports whether the value was new.
JavaScript's `Set.add` returns the set itself, so the test has to be written out:
`if (!seen.has(x)) { seen.add(x); ... }`. Two lines instead of one, and the same $O(1)$.
]

#trap[
`best` must be seeded with the biggest existing island. If the grid has no 0 at all, the
second loop never runs and you would return 0.
]

*Follow-up: "now you may flip up to K zeros, K small."*
Labelling still helps, but the merge is no longer local. For $K = 1$ the four-neighbour
trick is exact. For general $K$ this becomes a search problem, and the honest interview
answer is: state that it is much harder, and give a BFS over "water cells used so far" for
small K.
#ans[3]
]

#ex(28, tier: 3, asked: "D. E. Shaw · pattern")[
*Shortest loop.*
Return the length of the shortest cycle in an undirected graph, or $-1$ if there is none.

Constraints: $n <= 1000$, $m <= 5000$. Target $O(n(n+m))$.
Edge cases: a tree (answer $-1$); a triangle (answer 3).
]
#sol[
#approach(1, "Try every set of nodes", verdict: "hopeless")

#approach(2, "BFS from every node", verdict: "O(n(n+m)) — the standard answer")

Run BFS from each node $s$. During that BFS, if you meet an edge $u - v$ where $v$ is
*already* at a known distance and $v$ is not the parent of $u$, then
$"dist"[u] + "dist"[v] + 1$ is the length of a cycle through $s$. Take the minimum over
every start and every such edge.

#code(lang: "js", caption: "Shortest cycle (girth)")[
```js
const shortestCycle = (n, g) => {
  let best = Infinity;
  for (let s = 0; s < n; s++) {
    const dist = new Array(n).fill(-1), par = new Array(n).fill(-1);
    const q = [s]; dist[s] = 0;
    for (let head = 0; head < q.length; head++) {
      const u = q[head];
      for (const v of g[u]) {
        if (dist[v] === -1) { dist[v] = dist[u] + 1; par[v] = u; q.push(v); }
        else if (v !== par[u]) best = Math.min(best, dist[u] + dist[v] + 1);
      }
    }
  }
  return best === Infinity ? -1 : best;
};
```
]
#complexity(time: $O(n(n+m))$, space: $O(n)$,
  note: "At n = 1000 and m = 5000 this is about 6 x 10^6 steps. Fine.")

Verified: triangle plus a tail → *3*. Square `0-1-2-3-0` → 4. Path `0-1-2` → $-1$.

#note[
This finds the true shortest cycle for *unweighted* graphs. The formula can overshoot the
true answer for a single fixed start $s$, but taking the minimum over all starts fixes it,
because the shortest cycle is measured correctly from at least one of its own nodes.
]

*Follow-up: "now the graph is directed."*
BFS with a parent no longer applies. The standard answer is: for each edge $u -> v$,
delete it, run a BFS from $v$ to $u$, and add 1. That is $O(m(n+m))$ — say this out loud
and note it is much worse, which is why the directed version is rarely asked.
#ans[3]
]

#ex(29, tier: 3, asked: "Goldman Sachs · pattern")[
*Cables to lay.*
There are $n$ machines and a list of existing cables. You may unplug any cable and plug
it in somewhere else. What is the smallest number of moves that connects everything, or
$-1$ if it is impossible?

Edge cases: fewer than $n - 1$ cables (impossible); $n = 1$ (0 moves).
]
#sol[
Two facts settle it.

+ Connecting $n$ machines needs at least $n - 1$ cables. If you have fewer, answer $-1$.
+ If you have enough cables, you have enough *spare* cables. Every cable that closes a
  loop is spare, and the number of spares is always at least
  (number of components $- 1$). So the answer is simply
  #box[components $- 1$].

#code(lang: "js", caption: "Count components, subtract one")[
```js
const minExtraCables = (n, cables) => {
  if (cables.length < n - 1) return -1;
  const d = new DSU(n);
  let comps = n;
  for (const [u, v] of cables) if (d.union(u, v)) comps--;
  return comps - 1;
};
```
]
#complexity(time: $O(m alpha(n))$, space: $O(n)$)

Verified: $n = 5$ with cables `[0,1],[0,2],[1,2],[3,4]` → *1*
(components `{0,1,2}` and `{3,4}`; the cable `{1,2}` is the spare that moves).
$n = 4$ with one cable → $-1$. $n = 1$ with no cables → 0.

*Follow-up: "prove you always have enough spares."*
A component with $k$ nodes needs only $k - 1$ cables inside it. With $c$ components and
$m >= n - 1$ cables, the cables used inside components total $n - c$, so spares
$= m - (n - c) >= (n-1) - (n-c) = c - 1$. Exactly enough.
#ans[1]
]

#ex(30, tier: 3, asked: "Adobe · pattern")[
*Jobs that can never get stuck.*
A directed graph of tasks. A task is *safe* if every route that starts at it eventually
reaches a dead end (a node with no outgoing edges). List the safe tasks in increasing
order.

Edge cases: a node with no outgoing edges (safe); a node inside a cycle (not safe).
]
#sol[
"Unsafe" means: from this node you can reach a cycle. So reuse the 3-colour DFS, but
*remember* the verdict instead of stopping at the first cycle.

Colours here: 0 new, 1 on the current path, 2 proved safe, 3 proved unsafe.

#code(lang: "js", caption: "Safe nodes by memoised colouring")[
```js
const safeNodes = (n, g) => {
  const col = new Array(n).fill(0);   // 0 new, 1 on path, 2 safe, 3 unsafe
  const unsafe = (u) => {
    if (col[u] === 1 || col[u] === 3) return true;
    if (col[u] === 2) return false;
    col[u] = 1;
    for (const v of g[u])
      if (unsafe(v)) { col[u] = 3; return true; }
    col[u] = 2;
    return false;
  };
  const res = [];
  for (let i = 0; i < n; i++) if (!unsafe(i)) res.push(i);
  return res;
};
```
]
#complexity(time: $O(n + m)$, space: $O(n)$)

Verified on `0->1, 0->2, 1->2, 1->3, 2->5, 3->0, 4->5, 5` (dead end):
safe nodes are `2 4 5`. Nodes 0, 1 and 3 sit on the loop $0 -> 1 -> 3 -> 0$.
A single node with no edges is safe.

#note[
C++ needs `function<bool(int)> unsafe = [&](int u) -> bool { ... }` so the lambda can call
itself. A JavaScript arrow function assigned to a `const` can already refer to its own
name — the binding exists by the time the function *runs* — so `const unsafe = (u) => {
... unsafe(v) ... }` just works. Watch the order, though: calling `unsafe` on the line
*above* its declaration throws a `ReferenceError`, because `const` is not hoisted the way
`function` declarations are.
]

#trap[
The memo is what makes this linear. Without storing colour 2 and colour 3, the same
subtree is explored again for every caller and the running time becomes exponential.
]

*Follow-up: "now do it without recursion."*
Reverse every edge, start from all nodes whose *out-degree* is 0, and run a Kahn-style
peel: a node becomes safe once all of its out-neighbours are safe. That is the same idea
in iterative clothing, and it is $O(n + m)$ with no stack risk — which, at $n = 10^5$ in
Node, is not an optimisation but a requirement.

#code(lang: "js", caption: "The same answer, peeled instead of recursed")[
```js
const safeNodesKahn = (n, g) => {
  const rg = Array.from({ length: n }, () => []);
  const outdeg = new Array(n).fill(0);
  for (let u = 0; u < n; u++)
    for (const v of g[u]) { rg[v].push(u); outdeg[u]++; }
  const q = [];
  for (let i = 0; i < n; i++) if (outdeg[i] === 0) q.push(i);   // dead ends
  const safe = new Array(n).fill(false);
  for (let head = 0; head < q.length; head++) {
    const u = q[head];
    safe[u] = true;
    for (const p of rg[u]) if (--outdeg[p] === 0) q.push(p);
  }
  return safe.map((b, i) => b ? i : -1).filter(i => i !== -1);
};
```
]
Both versions return `2 4 5` on the graph above.
#ans[`2 4 5`]
]

#section[Dry run — bridges, line by line]

Graph (undirected, 6 nodes), edges given with their ids:

#table(columns: 8,
  [id], [0], [1], [2], [3], [4], [5], [6],
  [edge], [0–1], [1–2], [2–0], [2–3], [3–4], [3–5], [4–5],
)

So there are two triangles, `0-1-2` and `3-4-5`, joined by the single edge `2-3`.
By eye, the only bridge should be `2-3`. Let us watch the algorithm find it.

We run `dfs(0, -1)`. Recall: `tin[u]` is the entry time, `low[u]` starts equal to `tin[u]`
and only ever goes *down*.

#code(lang: "text", caption: "Actual printed trace of the DFS")[
```text
enter 0  tin=0 low=0
  enter 1  tin=1 low=1
    enter 2  tin=2 low=2
      back edge 2->0  low[2]=0
      enter 3  tin=3 low=3
        enter 4  tin=4 low=4
          enter 5  tin=5 low=5
            back edge 5->3  low[5]=3
          after child 5: low[4]=3   low[5]=3 vs tin[4]=4  -> not a bridge
        after child 4: low[3]=3   low[4]=3 vs tin[3]=3  -> not a bridge
        back edge 3->5  low[3]=3
      after child 3: low[2]=0   low[3]=3 vs tin[2]=2  -> BRIDGE
    after child 2: low[1]=0   low[2]=0 vs tin[1]=1  -> not a bridge
  after child 1: low[0]=0   low[1]=0 vs tin[0]=0  -> not a bridge
  back edge 0->2  low[0]=0
tin: 0 1 2 3 4 5
low: 0 0 0 3 3 3
```
]

Now the same thing as a table, one row per event.

#table(columns: (auto, auto, auto, 1fr),
  [*event*], [*node*], [*tin / low after*], [*what it means*],
  [enter], [0], [0 / 0], [root of the DFS],
  [enter], [1], [1 / 1], [],
  [enter], [2], [2 / 2], [],
  [back edge 2→0], [2], [2 / *0*], [0 is already open, so 2 can climb to time 0],
  [enter], [3], [3 / 3], [we crossed the edge `2-3`],
  [enter], [4], [4 / 4], [],
  [enter], [5], [5 / 5], [],
  [back edge 5→3], [5], [5 / *3*], [5 can climb only as high as time 3],
  [return 5→4], [4], [4 / *3*], [`low[5]=3` is not `> tin[4]=4` → edge 4–5 is safe],
  [return 4→3], [3], [3 / 3], [`low[4]=3` is not `> tin[3]=3` → edge 3–4 is safe],
  [back edge 3→5], [3], [3 / 3], [5 was entered at 5, no improvement],
  [return 3→2], [2], [2 / 0], [`low[3]=3 > tin[2]=2` → *edge 2–3 IS a bridge*],
  [return 2→1], [1], [1 / *0*], [`low[2]=0` is not `> tin[1]=1` → safe],
  [return 1→0], [0], [0 / 0], [`low[1]=0` is not `> tin[0]=0` → safe],
  [back edge 0→2], [0], [0 / 0], [no change],
)

#formulas(title: "Read the final table")[
```text
node:  0  1  2  3  4  5
tin :  0  1  2  3  4  5
low :  0  0  0  3  3  3
```
The whole first triangle collapses to `low = 0`. The whole second triangle collapses to
`low = 3`. Those two blocks are exactly the two *2-edge-connected components*, and the
single edge joining blocks with different low values is the bridge.
]

#note[
Read the trace twice. The first time, follow only the `enter` lines — that is plain DFS.
The second time, follow only the `after child` lines — that is where every decision is
made, on the way *back up*.
]

#section[Python, for the two signature problems]

JavaScript is the language of this book and a JS answer is always a complete answer. These
two are worth seeing in Python for one reason: `collections.deque` is a real queue in the
standard library, so the BFS loop reads exactly the way the algorithm is described.

#code(lang: "python", caption: "BFS distances and island counting")[
```python
from collections import deque

def bfs_dist(g, src):
    n = len(g)
    dist = [-1] * n
    dist[src] = 0
    q = deque([src])
    while q:
        u = q.popleft()
        for v in g[u]:
            if dist[v] == -1:
                dist[v] = dist[u] + 1
                q.append(v)
    return dist

def num_islands(grid):
    if not grid:
        return 0
    R, C = len(grid), len(grid[0])
    seen = [[False] * C for _ in range(R)]
    count = 0
    for i in range(R):
        for j in range(C):
            if grid[i][j] != 1 or seen[i][j]:
                continue
            count += 1
            q = deque([(i, j)])
            seen[i][j] = True
            while q:
                r, c = q.popleft()
                for nr, nc in ((r+1,c), (r-1,c), (r,c+1), (r,c-1)):
                    if 0 <= nr < R and 0 <= nc < C \
                       and grid[nr][nc] == 1 and not seen[nr][nc]:
                        seen[nr][nc] = True
                        q.append((nr, nc))
    return count
```
]
Real output: `bfs_dist` on the graph of Example 3 gives `[0, 1, 1, 2, -1, -1, -1]`;
`num_islands` on the grid of Example 8 gives `2`, on `[]` gives 0, on `[[1]]` gives 1.

#trap[
Use `deque.popleft()`, never `list.pop(0)`. Popping from the front of a Python list is
$O(n)$, which silently turns your $O(n+m)$ BFS into $O(n^2)$.

This is the *same bug* as `q.shift()` in JavaScript, in a different costume. Every
language punishes "remove from the front of a plain array"; each one gives you a different
escape hatch — `deque` in Python, the toolkit `Deque` or a head index in JS.
]

#section[Practice]

#practice(tier: 0, time: "20 min")[
+ A graph has degrees `3 1 1 1 0`. How many edges does it have?
+ Undirected edges `[0,1],[1,2],[2,0]`, `n = 3`. Write the adjacency list.
+ Same graph. BFS from 0 visits nodes in what order?
+ `n = 4`, edges `[0,1],[2,3]`. How many components?
]

#practice(tier: 1, time: "60 min")[
5. Given `n` and an undirected edge list, return the number of nodes that touch no edge
  at all.
6. Decide whether an undirected graph is a *tree*: connected and with no cycle.
7. Given a grid of 0s and 1s, for every cell report the distance to the nearest 1.
8. Return the number of nodes in the component that contains a given node `x`.
9. Decide whether the whole graph is one single simple cycle and nothing else.
10. Return how many edges you must delete so that no cycle remains.
]

#practice(tier: 2, time: "70 min")[
11. Directed graph. Find a node from which every other node is reachable, or say there is
   none.
12. Find the node farthest (in edges) from a given source, and that distance.
13. Count the land islands that do *not* touch the border of the grid.
14. Directed graph. List every node that has no incoming edge.
]

#practice(tier: 3, time: "60 min")[
15. Count the unordered pairs of nodes $(u, v)$ that are *not* connected to each other.
   $n$ up to $10^5$, so say whether the answer still fits in an exact JS number.
16. A *star* graph has one centre joined to all $n-1$ others and no other edges. Given
   an edge list you believe is a star, find the centre (or say it is not a star).
]

#key[
*1.* Sum of degrees is $3+1+1+1+0 = 6$, so $6/2 = 3$ edges.

*2.* `0 -> 1 2`, `1 -> 0 2`, `2 -> 1 0`.

*3.* `0 1 2`.

*4.* Two: `[0,1]` and `[2,3]`.

*5.* Count rows of the adjacency list that are empty.
#code(lang: "js", caption: "Q5")[
```js
const isolatedCount = (n, g) => g.filter(row => row.length === 0).length;
```
]
On `n = 7`, edges `[0,1],[0,2],[1,3],[4,5]` the answer is *1* (node 6).

*6.* A tree on $n$ nodes has exactly $n-1$ edges *and* no cycle. Check the edge count
first, then use DSU: if any `unite` returns false, an edge closed a loop.
#code(lang: "js", caption: "Q6")[
```js
const isTree = (n, E) => {
  if (E.length !== n - 1) return false;
  const d = new DSU(n);
  for (const [u, v] of E) if (!d.union(u, v)) return false;
  return true;
};
```
]
Verified: 4 nodes with `[0,1],[1,2],[1,3]` → true. Triangle → false. Single node, no
edges → true.

*7.* Multi-source BFS: push every cell holding a 1 with distance 0, then expand.
#code(lang: "js", caption: "Q7")[
```js
const nearestOne = (a) => {
  const R = a.length, C = a[0].length;
  const d = Array.from({ length: R }, () => new Array(C).fill(-1));
  const q = [];
  for (let i = 0; i < R; i++)
    for (let j = 0; j < C; j++)
      if (a[i][j] === 1) { d[i][j] = 0; q.push([i, j]); }
  for (let head = 0; head < q.length; head++) {
    const [r, c] = q[head];
    for (let k = 0; k < 4; k++) {
      const nr = r + DR[k], nc = c + DC[k];
      if (nr < 0 || nr >= R || nc < 0 || nc >= C || d[nr][nc] !== -1) continue;
      d[nr][nc] = d[r][c] + 1;
      q.push([nr, nc]);
    }
  }
  return d;
};
```
]
On `[[0,0,1],[0,0,0],[1,0,0]]` the real output is
`[[2,1,0],[1,2,1],[0,1,2]]`.

*8.* One BFS, count what you visit.
#code(lang: "js", caption: "Q8")[
```js
const componentSize = (n, g, x) => {
  const vis = new Array(n).fill(false);
  const q = [x]; vis[x] = true;
  let c = 0;
  for (let head = 0; head < q.length; head++) {
    const u = q[head]; c++;
    for (const v of g[u]) if (!vis[v]) { vis[v] = true; q.push(v); }
  }
  return c;
};
```
]
Verified: on the usual 7-node graph, `componentSize(0) = 4`, `componentSize(6) = 1`.

*9.* A single simple cycle needs $n >= 3$, every degree exactly 2, and all nodes in one
component. Two separate triangles pass the degree test but fail the connectivity test.
#code(lang: "js", caption: "Q9")[
```js
const isSingleCycle = (n, g) => {
  if (n < 3) return false;
  for (let i = 0; i < n; i++) if (g[i].length !== 2) return false;
  return componentSize(n, g, 0) === n;
};
```
]
Verified: square → true; two triangles (`n = 6`) → false.

*10.* Every edge that DSU rejects is an edge that closed a loop, and deleting exactly
those leaves a forest.
#code(lang: "js", caption: "Q10")[
```js
const edgesToRemove = (n, E) => {
  const d = new DSU(n);
  let kept = 0;
  for (const [u, v] of E) if (d.union(u, v)) kept++;
  return E.length - kept;
};
```
]
Verified: `n = 5`, edges `[0,1],[1,2],[2,0],[3,4]` → *1*.

*11.* DFS from every unvisited node; remember the node that started the *last* DFS. Only
that node can possibly reach everyone, so run one more DFS from it and check.
#code(lang: "js", caption: "Q11 — iterative, so 10^5 nodes are safe")[
```js
const motherVertex = (n, g) => {
  const flood = (s, vis) => {
    const st = [s]; vis[s] = true;
    while (st.length) {
      const u = st.pop();
      for (const v of g[u]) if (!vis[v]) { vis[v] = true; st.push(v); }
    }
  };
  const vis = new Array(n).fill(false);
  let last = 0;
  for (let i = 0; i < n; i++) if (!vis[i]) { flood(i, vis); last = i; }
  const v2 = new Array(n).fill(false);
  flood(last, v2);
  return v2.every(Boolean) ? last : -1;
};
```
]
Verified: `0->1, 0->2, 1->2, 2->3` gives *0*. `0->1` with node 2 loose gives $-1$.

*12.* BFS and keep the largest distance seen.
#code(lang: "js", caption: "Q12")[
```js
const farthest = (n, g, src) => {
  const dist = new Array(n).fill(-1);
  const q = [src]; dist[src] = 0;
  let bi = src, bd = 0;
  for (let head = 0; head < q.length; head++) {
    const u = q[head];
    if (dist[u] > bd) { bd = dist[u]; bi = u; }
    for (const v of g[u]) if (dist[v] === -1) { dist[v] = dist[u] + 1; q.push(v); }
  }
  return [bi, bd];
};
```
]
Verified on the chain `0-1-2-3-4-5`: from 0 → node 5 at distance 5; from 2 → node 5 at
distance 3.

*13.* Flood each island; while flooding, watch whether any of its cells sits on row 0,
row $R-1$, column 0 or column $C-1$.
#code(lang: "js", caption: "Q13")[
```js
const closedIslands = (grid) => {
  const g = grid.map(r => [...r]);
  const R = g.length, C = g[0].length;
  let cnt = 0;
  for (let i = 0; i < R; i++)
    for (let j = 0; j < C; j++) {
      if (g[i][j] !== 1) continue;
      let closed = true;
      const q = [[i, j]]; g[i][j] = 0;
      for (let head = 0; head < q.length; head++) {
        const [r, c] = q[head];
        if (r === 0 || c === 0 || r === R - 1 || c === C - 1) closed = false;
        for (let k = 0; k < 4; k++) {
          const nr = r + DR[k], nc = c + DC[k];
          if (nr < 0 || nr >= R || nc < 0 || nc >= C || g[nr][nc] !== 1) continue;
          g[nr][nc] = 0; q.push([nr, nc]);
        }
      }
      if (closed) cnt++;
    }
  return cnt;
};
```
]
Verified: `[[0,0,0],[0,1,0],[0,0,0]]` → *1*. `[[1,1],[1,1]]` → 0.

*14.* Count incoming edges, then list the zeros.
#code(lang: "js", caption: "Q14")[
```js
const noIncoming = (n, g) => {
  const indeg = new Array(n).fill(0);
  for (let u = 0; u < n; u++) for (const v of g[u]) indeg[v]++;
  return indeg.map((d, i) => d === 0 ? i : -1).filter(i => i !== -1);
};
```
]
Verified on `0->1, 0->2, 1->2, 2->3`: the answer is `0`.

*15.* Total pairs minus the pairs inside components. If component sizes are
$c_1, c_2, ...$ then
$ "answer" = n(n-1)/2 - sum_i c_i (c_i - 1) / 2 $
#code(lang: "js", caption: "Q15")[
```js
const disconnectedPairs = (n, g) => {
  const vis = new Array(n).fill(false);
  const total = n * (n - 1) / 2;
  let same = 0;
  for (let i = 0; i < n; i++) {
    if (vis[i]) continue;
    let c = 0;
    const q = [i]; vis[i] = true;
    for (let head = 0; head < q.length; head++) {
      const u = q[head]; c++;
      for (const v of g[u]) if (!vis[v]) { vis[v] = true; q.push(v); }
    }
    same += c * (c - 1) / 2;
  }
  return total - same;
};
```
]
Verified: `n = 7` with components of size 4, 2, 1 gives $21 - (6+1+0) = 14$.
A triangle gives 0.

This is the question C++ answers with a 64-bit integer: at $n = 10^5$ the total is
$4999950000$, past the 32-bit limit of about $2.1 times 10^9$. JavaScript needs no
annotation — `Number.isSafeInteger(4999950000)` is `true`, and the exact range reaches
$2^53 - 1 approx 9 times 10^15$. Be able to say that out loud; "JS numbers are doubles so
it just works" is only half an answer, and the other half is the bound.

*16.* In a star with $n$ nodes the centre has degree $n-1$ and there are exactly $n-1$
edges.
#code(lang: "js", caption: "Q16")[
```js
const starCentre = (n, E) => {
  if (n < 2 || E.length !== n - 1) return -1;
  const deg = new Array(n).fill(0);
  for (const [u, v] of E) { deg[u]++; deg[v]++; }
  for (let i = 0; i < n; i++) if (deg[i] === n - 1) return i;
  return -1;
};
```
]
Verified: `[0,1],[0,2],[0,3]` → *0*. The chain `[0,1],[1,2],[2,3]` → $-1$.
]

#revision[
*Build the graph — always start here*
#code(lang: "js", caption: "Adjacency list")[
```js
const { DSU, Deque } = require('./toolkit.js');   // JS Toolkit appendix

const g = Array.from({ length: n }, () => []);    // NOT new Array(n).fill([])
for (const [u, v] of edges) {
  g[u].push(v);
  g[v].push(u);                                   // drop for directed
}
```
]

*BFS — shortest edge count*
#code(lang: "js", caption: "BFS")[
```js
const dist = new Array(n).fill(-1);
const q = [src];                     // array + head index, never q.shift()
dist[src] = 0;
for (let head = 0; head < q.length; head++) {
  const u = q[head];
  for (const v of g[u]) if (dist[v] === -1) {
    dist[v] = dist[u] + 1; q.push(v);
  }
}
```
]

*DFS — reach everything in one component*
#code(lang: "js", caption: "DFS, recursive and iterative")[
```js
// clear, but dies past ~10^4 depth
const dfs = (u) => { vis[u] = 1; for (const v of g[u]) if (!vis[v]) dfs(v); };

// what you actually ship at n = 10^5
const st = [src];
while (st.length) {
  const u = st.pop();
  if (vis[u]) continue;
  vis[u] = 1;
  for (const v of g[u]) if (!vis[v]) st.push(v);
}
```
]

*Which tool?*
#table(columns: (1fr, 1fr),
  [fewest edges / minutes], [BFS],
  [spread from many starts at once], [multi-source BFS],
  [count pieces, flood a region], [DFS or BFS or DSU],
  [cycle, undirected], [BFS with parent, or edges $>=$ nodes],
  [cycle, directed], [3-colour DFS],
  [bridges / articulation points], [DFS with `tin` and `low`],
  [groups in a directed graph], [Kosaraju (two DFS passes)],
  [many connectivity queries as edges arrive], [DSU],
)

*Complexity*
#table(columns: (1fr, auto, auto),
  [*algorithm*], [*time*], [*space*],
  [BFS / DFS], [$O(n + m)$], [$O(n + m)$],
  [grid BFS], [$O(R C)$], [$O(R C)$],
  [DSU over $m$ edges], [$O(m alpha(n))$], [$O(n)$],
  [bridges / articulation points], [$O(n + m)$], [$O(n + m)$],
  [Kosaraju SCC], [$O(n + m)$], [$O(n + m)$],
  [shortest cycle (girth)], [$O(n(n+m))$], [$O(n)$],
)

*Top traps*
#table(columns: (auto, 1fr),
  [1], [`q.shift()` is $O(n)$ in JavaScript. A BFS written with it is $O(n^2)$. Use an array with a head index, or the toolkit `Deque`.],
  [2], [Recursion depth in Node is roughly $10^4$. A recursive DFS on a $10^5$-node chain throws `RangeError`. Use BFS or an explicit stack.],
  [3], [`new Array(n).fill([])` puts *one* array in every slot. Use `Array.from({length: n}, () => [])`.],
  [4], [`[...grid]` shares every row. A real 2D copy is `grid.map(r => [...r])`.],
  [5], [Marking visited on *pop* instead of on *push*. The queue explodes.],
  [6], [Forgetting the outer loop over all nodes. Disconnected graphs are silently half-checked.],
  [7], [Using the parent trick for cycles in a *directed* graph. Use 3 colours instead.],
  [8], [`v !== par[u]` written as `v !== par[v]`.],
  [9], [Skipping the parent *node* instead of the parent *edge id* when finding bridges. Parallel edges break it.],
  [10], [Route counts past $2^53 - 1$ *round* rather than overflow. Take a modulus at every `+=`, or switch to `BigInt`.],
  [11], [In flood fill, forgetting the "new colour equals old colour" guard. Infinite loop.],
  [12], [Bumping the minute counter on the final empty ring of a multi-source BFS.],
  [13], [Sizing an array from the target only, when the *start* can sit outside it. An out-of-range read gives `undefined`, not a crash.],
  [14], [`==` where you meant `===`. Graph input parsed from text arrives as strings, and `"2" == 2` is `true` while `"2" === 2` is not.],
)

*The one sentence to remember*
Every unweighted "shortest / fewest / minimum steps" question is BFS. Every
"how many pieces / can I reach / is there a loop" question is DFS or DSU.
]

]
