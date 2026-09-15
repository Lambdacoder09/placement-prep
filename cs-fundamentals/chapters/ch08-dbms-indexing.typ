#import "../../shared/lib/style.typ": *

#chapter(num: 8, title: "DBMS: Indexing & Query Performance", tagline: "Why the same query takes 3 milliseconds or 30 seconds")[

#section[The chapter in one page]

An index is a *sorted copy of one or more columns*, plus a pointer back to the row. That is
all. Every question in this chapter comes from three consequences of that sentence:

+ Sorted means you can *binary search* it, so a lookup costs $O(log n)$ page reads instead of
  reading the whole table.
+ A *copy* means every `INSERT`, `UPDATE` and `DELETE` has to maintain it. Indexes make reads
  fast and writes slow.
+ Sorted *in a particular order* means an index helps only the queries that match that order.
  A composite index on `(city, age)` cannot help `WHERE age = 30`.

The interviewer's real question is almost always the same: *given this query and this table,
would the planner use the index, and should it?*

#formulas(title: "What you need to know")[

*The unit of I/O is the page*, not the row. Typical page size 8 KB (PostgreSQL) or 16 KB
(InnoDB). The database never reads one row from disk; it reads the page the row sits on.

$ "rows per page" = floor("page size" / "row size") quad quad
  "table pages" = ceil("rows" / "rows per page") $

*B+ tree* — the index structure in every relational database.
- All keys live in the *leaf* level. Internal nodes hold only separator keys, so the fanout is
  huge.
- Every leaf is at the same depth, so every lookup costs the same.
- Leaves are joined in a *linked list*, so a range scan descends once and then walks sideways.

$ "fanout" f = floor(("page size" times "fill factor") / "entry size") quad quad
  "height" h = ceil(log_f ("number of keys")) $

*Cost of a lookup* $= h$ page reads to reach the leaf, $+ 1$ more to fetch the row if the index
does not already contain everything the query needs.

*Clustered vs secondary*
#table(columns: (auto, 1fr),
  [*Clustered index*], [The table *is* the index. The leaf holds the whole row. One per table.
    InnoDB always clusters on the primary key.],
  [*Secondary index*], [The leaf holds the key plus a pointer to the row. Many per table.
    In InnoDB that pointer is the primary key, so a secondary lookup is *two* descents.],
  [*Heap table*], [No clustering. Rows sit wherever there was room. The pointer is a physical
    address (`ctid` in PostgreSQL). This is PostgreSQL's model.],
)

*Selectivity* — the fraction of the table a predicate keeps.
$ "selectivity" = "matching rows" / "total rows" $
Low selectivity value (say 0.001) = highly selective = *good for an index*.
Selectivity near 1 = the index is useless, a sequential scan is cheaper.

*Cost model in one line* — a random page read costs several sequential page reads.
$ "cost"_"index" = ("height" + "matched rows") times r quad quad
  "cost"_"scan" = "table pages" $
where $r$ is the random-to-sequential cost ratio (about 4 on an SSD, 20+ on a spinning disk).

*The leftmost prefix rule.* An index on $(c_1, c_2, c_3)$ can serve a predicate only on a
*prefix* of that list: $c_1$; or $c_1$ and $c_2$; or all three. It cannot serve $c_2$ alone.
Inside the prefix, everything up to the *first range predicate* is used for seeking; after
that, the index gives order but not a seek.

*Column order rule:* equality columns first, then the range column, then the `ORDER BY`
columns. Remember it as *E-R-O*.

*Sargable* ("Search ARGument able") — a predicate the index can seek on. `col = value` is
sargable. `f(col) = value` is not, because the index stores `col`, not `f(col)`.

*Covering index / index-only scan* — the index contains every column the query touches, so the
table is never read at all.

*Join algorithms*
#table(columns: (auto, auto, 1fr),
  [*Algorithm*], [*Cost shape*], [*Wins when*],
  [Nested loop], [$|R| times "lookup"$], [the outer side is tiny and the inner side has an index],
  [Hash join], [$|R| + |S|$], [both sides are big and the join is on equality],
  [Sort-merge join], [$|R| log |R| + |S| log |S|$], [both sides are already sorted on the join key,
    or the join is on a range],
)

*What kills an index* — a function on the column, a leading wildcard, an implicit type cast,
`OR` across different columns, `!=`, low cardinality, or a predicate that matches most of the
table.
]

#subsection[The structure]

#diagram(height: 5.2cm, caption: "A B+ tree. All data is in the leaves; the leaves are a linked list, which is what makes a range scan cheap.")[
  #dnode(5.8cm, 0pt, 3.2cm, 0.8cm, "[ 70 ]", fill: rgb("#f7efe4"))
  #dnode(1.6cm, 1.6cm, 3.2cm, 0.8cm, "[ 20 | 50 ]")
  #dnode(10.0cm, 1.6cm, 3.2cm, 0.8cm, "[ 90 ]")
  #dnode(0.2cm, 3.4cm, 3.0cm, 0.9cm, "10 · 15 · 18\n→ rows")
  #dnode(3.7cm, 3.4cm, 3.0cm, 0.9cm, "20 · 30 · 34\n→ rows")
  #dnode(8.0cm, 3.4cm, 3.0cm, 0.9cm, "50 · 60 · 65\n→ rows")
  #dnode(11.5cm, 3.4cm, 3.0cm, 0.9cm, "70 · 90 · 95\n→ rows")
  #darrow(6.6cm, 0.85cm, 3.2cm, 1.55cm)
  #darrow(8.2cm, 0.85cm, 11.6cm, 1.55cm)
  #darrow(2.4cm, 2.45cm, 1.7cm, 3.35cm)
  #darrow(3.8cm, 2.45cm, 5.2cm, 3.35cm)
  #darrow(10.8cm, 2.45cm, 9.5cm, 3.35cm)
  #darrow(12.2cm, 2.45cm, 13.0cm, 3.35cm)
  #darrow(3.25cm, 3.85cm, 3.65cm, 3.85cm)
  #darrow(6.75cm, 3.85cm, 7.95cm, 3.85cm)
  #darrow(11.05cm, 3.85cm, 11.45cm, 3.85cm)
]

#diagram(height: 4.6cm, caption: "Two ways to answer WHERE email = 'x'. The index path reads 4 pages; the scan path reads every page in the table.")[
  #dnode(0pt, 0.1cm, 2.6cm, 0.9cm, "WHERE\nemail = 'x'")
  #dnode(3.2cm, 0.1cm, 2.2cm, 0.9cm, "root", fill: rgb("#f7efe4"))
  #dnode(5.9cm, 0.1cm, 2.4cm, 0.9cm, "internal", fill: rgb("#f7efe4"))
  #dnode(8.8cm, 0.1cm, 2.6cm, 0.9cm, "leaf\nemail → ptr", fill: rgb("#f7efe4"))
  #dnode(11.9cm, 0.1cm, 2.8cm, 0.9cm, "heap page\n(the row)", fill: rgb("#e3efe3"))
  #darrow(2.65cm, 0.55cm, 3.15cm, 0.55cm)
  #darrow(5.45cm, 0.55cm, 5.85cm, 0.55cm)
  #darrow(8.35cm, 0.55cm, 8.75cm, 0.55cm)
  #darrow(11.45cm, 0.55cm, 11.85cm, 0.55cm)
  #dnode(0pt, 1.5cm, 14.7cm, 0.55cm, "index path: 3 page reads to descend + 1 to fetch the row  =  4", fill: rgb("#f3f8f4"))
  #dnode(0pt, 2.7cm, 2.6cm, 0.9cm, "same WHERE")
  #dnode(3.2cm, 2.7cm, 11.5cm, 0.9cm, "read page 1, page 2, page 3, … page 156250 — check every row", fill: rgb("#f7e8e8"))
  #darrow(2.65cm, 3.15cm, 3.15cm, 3.15cm)
]

#section[Warm-up — the mechanics]
#tier-header(0)

#ex(1, tier: 0)[
A table has 10,000,000 rows. Each row is 128 bytes and the page size is 8192 bytes.
How many pages does the table occupy, and how big is it in megabytes?

#sol[
Step 1 — rows per page.
$ floor(8192 / 128) = 64 "rows per page" $
Step 2 — pages.
$ ceil(10^7 / 64) = 156250 "pages" $
Step 3 — size.
$ 156250 times 8192 = 1.28 times 10^9 "bytes" = 1220.7 "MB" $

#ans[156,250 pages, about 1.22 GB]
]
#note[
Remember these three numbers — 64 rows per page, 156,250 pages, 1.2 GB. Every example in this
chapter reuses them, so the arithmetic stays out of your way.
]
]

#ex(2, tier: 0)[
Build a B+ tree index on a 4-byte integer key over those 10 million rows. Each index entry is
16 bytes (key + pointer + overhead). How many levels does the tree have?

#sol[
Step 1 — fanout.
$ f = floor(8192 / 16) = 512 $
Step 2 — leaf level. Each leaf holds 512 entries.
$ ceil(10^7 / 512) = 19532 "leaves" $
Step 3 — the level above.
$ ceil(19532 / 512) = 39 "nodes" $
Step 4 — the level above that.
$ ceil(39 / 512) = 1 "node — the root" $

#code(lang: "js", caption: "height calculator, run with node")[
```js
function bptHeight(rows, pageBytes, entryBytes, fill = 1.0) {
  const fanout = Math.floor((pageBytes * fill) / entryBytes);
  let nodes = Math.ceil(rows / fanout), levels = 1;      // the leaf level
  while (nodes > 1) { nodes = Math.ceil(nodes / fanout); levels++; }
  return { fanout, levels };
}
console.log(bptHeight(10_000_000, 8192, 16));         // { fanout: 512, levels: 3 }
console.log(bptHeight(10_000_000, 8192, 16, 0.7));    // { fanout: 358, levels: 3 }
console.log(bptHeight(10_000_000, 8192, 64));         // { fanout: 128, levels: 4 }
```
]

#ans[3 levels — root, one internal level, leaves. So *3 page reads* to reach a leaf.]

Notice the third line. A 56-byte text key drops the fanout from 512 to 128 and adds a level.
*Fat keys make tall trees.* That is the whole argument for indexing an integer surrogate key
rather than a long `VARCHAR`.
]
]

#ex(3, tier: 0)[
Real B+ trees are not packed 100% full. At a 70% fill factor, does the tree from Example 2 get
taller?

#sol[
$ f = floor(8192 times 0.7 / 16) = 358 $
$ ceil(10^7 / 358) = 27933 "leaves" quad ceil(27933/358) = 79 quad ceil(79/358) = 1 $

Still 3 levels. The tree grew 43% in size but not in height, because height grows like
$log_f n$ — you have to change the fanout enormously to add a level.

#ans[no, still 3 levels; the tree is wider, not taller]
]
#trick[
Height barely moves. With a fanout around 400, a 3-level tree already holds
$400^3 = 64$ million keys and a 4-level tree holds 25 *billion*. So the honest answer to
"how many I/Os does an index lookup take?" is almost always *"three or four, plus one for the
row"* — and the root and the level below it are practically always in the buffer pool, so in
practice you pay 1 to 2 real disk reads.
]
]

#ex(4, tier: 0)[
Which of these predicates can use an index on `orders(order_date)`? Say yes or no and why.

#code(lang: "sql", caption: "")[
```sql
1.  WHERE order_date = DATE '2026-01-15'
2.  WHERE order_date >= DATE '2026-01-01' AND order_date < DATE '2026-02-01'
3.  WHERE YEAR(order_date) = 2026
4.  WHERE order_date + INTERVAL '1 day' > now()
5.  WHERE order_date IS NULL
```
]

#sol[
#table(columns: (auto, auto, 1fr),
  [*No.*], [*Index?*], [*Why*],
  [1], [yes], [equality on the indexed column — a single descent.],
  [2], [yes], [a range on the indexed column — descend once, walk the leaves.],
  [3], [*no*], [the index stores `order_date`, not `YEAR(order_date)`. Not sargable.],
  [4], [*no*], [same problem: the column is wrapped in an expression.],
  [5], [yes], [`NULL`s are stored in the index in PostgreSQL and InnoDB, so this seeks fine.],
)

Fix number 3 by rewriting the predicate so the *column stands alone*:
#code(lang: "sql", caption: "the rewrite that makes it sargable")[
```sql
WHERE order_date >= DATE '2026-01-01'
  AND order_date <  DATE '2027-01-01'
```
]
And number 4 by moving the arithmetic to the other side:
#code(lang: "sql", caption: "")[
```sql
WHERE order_date > now() - INTERVAL '1 day'
```
]
#ans[1, 2 and 5 yes; 3 and 4 no — a function on the column kills the seek]
]
#trap[
This is the single most common indexing bug in real code and a favourite interview question.
The rule to say out loud: *keep the indexed column bare on the left-hand side.* If you truly
need the function, build an *expression index*:
`CREATE INDEX idx_o_year ON orders ((EXTRACT(YEAR FROM order_date)));`
]
]

#ex(5, tier: 0)[
Explain the difference between a clustered index and a secondary index in one sentence each,
and say how many of each a table can have.

#sol[
- *Clustered* — the leaf level *is* the table; the rows are physically stored in index order.
  At most *one* per table, because a row can only be in one place.
- *Secondary* — the leaf holds the key and a pointer to the row. *Many* per table.

#diagram(height: 4.4cm, caption: "InnoDB: a secondary index points at the primary key, so a secondary lookup is two descents.")[
  #dnode(0pt, 0.1cm, 4.4cm, 1.1cm, "SECONDARY INDEX on email\nleaf: ('a@x.com' → user_id 77)")
  #dnode(5.4cm, 0.1cm, 4.4cm, 1.1cm, "CLUSTERED INDEX on user_id\nleaf: (77 → the whole row)", fill: rgb("#e3efe3"))
  #darrow(4.45cm, 0.65cm, 5.35cm, 0.65cm, label: "2nd descent")
  #dnode(0pt, 2.2cm, 4.4cm, 1.1cm, "POSTGRES INDEX on email\nleaf: ('a@x.com' → ctid (12, 4))")
  #dnode(5.4cm, 2.2cm, 4.4cm, 1.1cm, "HEAP FILE\npage 12, slot 4 = the row", fill: rgb("#e3efe3"))
  #darrow(4.45cm, 2.75cm, 5.35cm, 2.75cm, label: "1 page read")
  #dnode(10.4cm, 0.1cm, 4.3cm, 3.2cm, "Consequence:\nin InnoDB a long primary key is copied into EVERY secondary index.\n\nUse a short PK.", fill: rgb("#f7efe4"))
]

#ans[one clustered index, many secondary indexes]
]
]

#ex(6, tier: 0)[
`CREATE INDEX idx ON emp (dept_id, salary);` Which of these can seek on the index?

#code(lang: "sql", caption: "")[
```sql
a.  WHERE dept_id = 4
b.  WHERE dept_id = 4 AND salary > 50000
c.  WHERE salary > 50000
d.  WHERE salary = 50000 AND dept_id = 4
```
]

#sol[
The index is sorted by `dept_id` first, and only *within one `dept_id`* by `salary`.

#table(columns: (auto, auto, 1fr),
  [*No.*], [*Seek?*], [*Why*],
  [a], [yes], [`dept_id` is the leftmost column.],
  [b], [yes], [seek to `dept_id = 4`, then walk forward from `salary > 50000` — both columns used.],
  [c], [*no*], [`salary` is not a prefix. Rows with salary 50001 are scattered through every
    department. At best the engine does an *index-only scan* of the whole index, which is
    cheaper than a table scan but is not a seek.],
  [d], [yes], [the *written* order of the `AND` conditions does not matter. The planner
    reorders them. Only the *index* column order matters.],
)
#ans[a, b and d seek; c cannot]
]
#trap[
"I wrote `salary` first in my `WHERE`, so I need an index with `salary` first." No. `AND` is
commutative and the planner knows it. What matters is the *index* definition order, never the
order you typed the conditions.
]
]

#ex(7, tier: 0)[
What does `EXPLAIN` show, and what does `EXPLAIN ANALYZE` show that `EXPLAIN` does not?

#sol[
- `EXPLAIN` prints the *plan the planner chose* and its *estimates*. It does not run the query.
- `EXPLAIN ANALYZE` actually runs the query and prints *real* row counts and *real* timings
  next to the estimates.

#code(lang: "sql", caption: "reading a PostgreSQL plan")[
```sql
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 4412;

-- Index Scan using idx_orders_cust on orders
--   (cost=0.43..38.12 rows=11 width=128)
--   (actual time=0.031..0.079 rows=9 loops=1)
--   Index Cond: (customer_id = 4412)
-- Planning Time: 0.121 ms
-- Execution Time: 0.098 ms
```
]
#table(columns: (auto, 1fr),
  [`cost=0.43..38.12`], [startup cost .. total cost, in arbitrary units where 1.0 is one
    sequential page read. *Not milliseconds.*],
  [`rows=11`], [the *estimate*.],
  [`actual ... rows=9`], [the *truth*. Compare it with the estimate — this is the whole point.],
  [`loops=1`], [how many times this node ran. Multiply `actual time` by `loops` for the real cost.],
)

#ans[`EXPLAIN` = the plan and estimates; `EXPLAIN ANALYZE` = the plan plus what actually happened]
]
#trick[
When you read a plan, look at *one number first*: estimated `rows` versus actual `rows`. If
they differ by 100× or more, the planner is working from bad statistics, and every decision
above that node in the tree is built on sand. Fix the statistics before you touch the query.
]
]

#practice(tier: 0, time: "10 minutes")[
+ A page is 8 KB and a row is 256 bytes. Rows per page?
+ Fanout 200, 8 million keys. How many leaf nodes?
+ Can an index on `(a, b, c)` serve `WHERE a = 1 AND c = 3`? Fully or partly?
+ Which is sargable: `WHERE UPPER(name) = 'RAVI'` or `WHERE name = 'Ravi'`?
+ How many clustered indexes can one table have?
+ In `EXPLAIN`, is `cost` measured in milliseconds?
+ Does `WHERE id != 5` use an index on `id` well?
]

#key[
1. $floor(8192\/256) = 32$. #h(8pt)
2. $ceil(8000000\/200) = 40000$. #h(8pt)
3. Partly: it seeks on `a = 1`, then *filters* on `c` while scanning that range. `b` is missing,
so `c` cannot be used for seeking. #h(8pt)
4. `WHERE name = 'Ravi'`. #h(8pt)
5. One. #h(8pt)
6. No — arbitrary units, where 1.0 is roughly one sequential page read. #h(8pt)
7. No. `!=` matches almost everything, so a sequential scan is cheaper.
]

#section[Tier 1 — the questions a service company asks]
#tier-header(1)

#ex(8, tier: 1, asked: "TCS NQT · pattern")[
"Indexes make queries faster, so index every column." Give four reasons this is wrong, with
numbers.

#sol[
*Reason 1 — every write pays for every index.* An `INSERT` into a table with $k$ secondary
indexes performs $1 + k$ B+ tree insertions.

#table(columns: (auto, auto, auto),
  [*Secondary indexes*], [*Tree insertions per row*], [*Relative insert cost*],
  [0], [1], [1×],
  [1], [2], [2×],
  [3], [4], [4×],
  [6], [7], [7×],
)
Each of those is a descent plus a possible *page split*, which is a random write.

*Reason 2 — space.* Our 10 million row index at 16 bytes per entry and a 70% fill factor is
$10^7 times 16 \/ 0.7 = 218$ MB. Six such indexes are 1.3 GB — bigger than the 1.22 GB table.
They compete with the table for buffer-pool memory, so *adding indexes can make unrelated
queries slower* by pushing hot pages out of cache.

*Reason 3 — unused indexes are pure loss.* An index on a column no query filters on costs
writes and memory and returns nothing. Find them:
#code(lang: "sql", caption: "PostgreSQL: indexes that have never been read")[
```sql
SELECT relname AS table_name, indexrelname AS index_name, idx_scan
  FROM pg_stat_user_indexes
 WHERE idx_scan = 0
 ORDER BY pg_relation_size(indexrelid) DESC;
```
]

*Reason 4 — a bad index can be chosen over a good plan.* More indexes means more plans to
consider, and with skewed data the planner sometimes picks an index scan that is far worse
than a sequential scan (Example 11).

#ans[writes multiply, space can exceed the table, unused indexes are pure cost, and extra
choices can mislead the planner]
]
]

#ex(9, tier: 1, asked: "Infosys · pattern")[
What is a covering index? Show the difference on a real query.

#sol[
A covering index contains *every column the query mentions*, so the engine answers the query
from the index alone and never touches the table. PostgreSQL calls this an *index-only scan*.

#code(lang: "sql", caption: "before: index seek + heap fetch for every row")[
```sql
CREATE INDEX idx_o_cust ON orders (customer_id);

SELECT customer_id, amount
  FROM orders
 WHERE customer_id = 4412;
-- Index Scan: descend 3 pages, then ONE HEAP READ PER MATCHING ROW to get `amount`
```
]

#code(lang: "sql", caption: "after: everything the query needs is in the index")[
```sql
CREATE INDEX idx_o_cust_amt ON orders (customer_id, amount);
-- or, PostgreSQL 11+, keep `amount` as a payload only:
CREATE INDEX idx_o_cust_inc ON orders (customer_id) INCLUDE (amount);

SELECT customer_id, amount
  FROM orders
 WHERE customer_id = 4412;
-- Index Only Scan: descend 3 pages, read the leaf entries, done. Zero heap reads.
```
]

*The numbers.* Say 200 orders match. Before: $3 + 200 = 203$ page reads, of which 200 are
*random*. After: $3 + 1 = 4$ page reads, all clustered together in the leaf. Roughly 50×
fewer I/Os.

*`INCLUDE` versus adding the column to the key*
#table(columns: (auto, 1fr),
  [key column], [is sorted, can be searched and can satisfy an `ORDER BY`; makes the entry
    bigger at *every* level of the tree],
  [`INCLUDE` column], [payload only — stored in the leaves, not in internal nodes. Cannot be
    searched, but keeps the tree's fanout high],
)
Put a column in the key if you filter or sort on it. Put it in `INCLUDE` if you only `SELECT` it.

#ans[an index that holds all the columns the query needs, so the table is never read —
"index-only scan"]
]
#trap[
In PostgreSQL an index-only scan is *not always* index-only. Because of MVCC, the index entry
does not know whether its row version is visible to you. The engine consults the *visibility
map*; if the page is not marked all-visible, it must fetch the heap row anyway. A table that
has not been vacuumed recently will show `Heap Fetches: 198` in `EXPLAIN ANALYZE` and get none
of the benefit. `VACUUM` the table and the number drops to 0.
]
]

#ex(10, tier: 1, asked: "Wipro · pattern")[
Order the columns for an index that must serve this query well:

#code(lang: "sql", caption: "")[
```sql
SELECT order_id, amount
  FROM orders
 WHERE status = 'SHIPPED'
   AND shipped_at >= DATE '2026-01-01'
 ORDER BY amount DESC
 LIMIT 20;
```
]

#sol[
Apply *E-R-O*: *Equality* first, then the *Range*, then the *Order by*.

- Equality: `status`
- Range: `shipped_at`
- Order by: `amount DESC`

So the key order is `(status, shipped_at, amount)`.

#code(lang: "sql", caption: "")[
```sql
CREATE INDEX idx_o_ship ON orders (status, shipped_at, amount DESC);
```
]

*But look carefully at what this actually buys.* Everything *after* the first range predicate
is no longer in usable sort order — the index is sorted by `amount` only *within one exact
`shipped_at` value*. So the engine can seek on `status` and `shipped_at`, but it must still
collect all matching rows and sort them by `amount` before the `LIMIT 20`. The `ORDER BY` is
not free.

*The alternative, when the range is broad:*
#code(lang: "sql", caption: "put the sort column second, pay a filter instead")[
```sql
CREATE INDEX idx_o_ship_amt ON orders (status, amount DESC);
-- walk the index in amount DESC order inside status='SHIPPED',
-- filter each entry on shipped_at, stop after 20 survivors -> no sort at all
```
]
This wins when most shipped orders are recent, so the first 20 big amounts are found quickly.
It loses badly when the date filter is very selective, because the engine may walk a long way
down the amount order before finding 20 rows that pass the date filter.

#ans[`(status, shipped_at, amount)` by the E-R-O rule; but if the date range is broad,
`(status, amount)` avoids the sort and usually wins]
]
#note[
This is a trade-off, not a rule, and saying so is what separates a Tier-1 answer from a Tier-3
one. Two indexes, two plans; the right answer depends on the data. Run both with
`EXPLAIN ANALYZE` and compare *actual* time.
]
]

#ex(11, tier: 1, asked: "Accenture · pattern")[
An index exists on `orders(status)` but the planner chooses a sequential scan for
`WHERE status = 'DELIVERED'`. Is the planner wrong? Compute.

#sol[
Use our standard table: 10 million rows, 64 per page, 156,250 pages. Suppose 88% of orders are
`DELIVERED`, so 8.8 million rows match.

*Index path.* Descend 3 pages, then one heap read per matching row, scattered randomly:
$ 3 + 8800000 approx 8.8 "million random page reads" $
*Scan path.* Read every page once, sequentially:
$ 156250 "sequential page reads" $

The index path does *56 times more I/O*, and each of those I/Os is a *random* read, which costs
several times a sequential one. The planner is right by a factor of about 200.

*Where is the crossover?* Let $r = 4$ (a random read costs 4 sequential ones) and let $m$ be
the number of matching rows.
$ 4 (3 + m) < 156250 quad arrow.r.double quad m < 39059.5 $

#code(lang: "js", caption: "crossover calculator, run with node")[
```js
const PAGE = 8192, ROW = 128, N = 10_000_000, RANDOM_COST = 4;
const tablePages = Math.ceil(N / Math.floor(PAGE / ROW));     // 156250

const cost = (matched) => {
  const idx = (3 + matched) * RANDOM_COST;
  return { matched, pct: +(matched / N * 100).toFixed(3), index: idx,
           scan: tablePages, winner: idx < tablePages ? "index" : "seq scan" };
};
[100, 1000, 39000, 40000, 100000].forEach(m => console.log(cost(m)));
```
]
Output:
#table(columns: (auto, auto, auto, auto, auto),
  [*rows matched*], [*% of table*], [*index cost*], [*scan cost*], [*winner*],
  [100], [0.001], [412], [156250], [index],
  [1000], [0.01], [4012], [156250], [index],
  [39000], [0.39], [156012], [156250], [index],
  [40000], [0.4], [160012], [156250], [*seq scan*],
  [100000], [1.0], [400012], [156250], [*seq scan*],
)

#ans[the planner is right; past roughly 0.4% of the table a sequential scan is cheaper]
]
#trap[
The often-quoted "5% rule" is a rough memory aid, not a law. The real crossover depends on the
random-to-sequential cost ratio and on the *clustering factor* — how well the table's physical
order matches the index order. If the matching rows happen to sit together (a clustered index,
or a naturally time-ordered table), 8.8 million rows occupy only $ceil(8800000\/64) = 137500$
pages read almost sequentially, and the index wins again. Mention the clustering factor and you
have said something most candidates do not.
]
]

#ex(12, tier: 1, asked: "Capgemini · pattern")[
Name six ways a developer accidentally stops the planner from using an index, and give the fix
for each.

#sol[
#table(columns: (auto, auto, 1fr),
  [*Killer*], [*Broken*], [*Fix*],
  [Function on the column], [`WHERE YEAR(d) = 2026`], [`WHERE d >= '2026-01-01' AND d < '2027-01-01'` — or an expression index],
  [Leading wildcard], [`WHERE name LIKE '%ravi'`], [`LIKE 'ravi%'` seeks; for the other direction index a *reversed* copy of the column, or use a trigram index],
  [Implicit type cast], [`WHERE phone = 9876543210` on a `VARCHAR` column], [quote it: `WHERE phone = '9876543210'`],
  [`OR` across columns], [`WHERE a = 1 OR b = 2`], [`SELECT ... WHERE a = 1 UNION SELECT ... WHERE b = 2` — each branch can use its own index],
  [Negation], [`WHERE status != 'DONE'`], [list the values: `WHERE status IN ('NEW','RUNNING')`],
  [Low cardinality], [`WHERE active = true` when 95% are true], [a *partial* index: `CREATE INDEX ... WHERE active = false`],
)

*The implicit-cast trap is worth its own line.* If `phone` is `VARCHAR` and you compare it to a
number, the database must cast *every row's* `phone` to a number to compare. That is a function
on the column, so the index is dead — and the query still returns the right answer, just 1000×
slower. It is invisible in code review.

#code(lang: "sql", caption: "the partial index, the most under-used tool here")[
```sql
-- 20 million rows, only ~4000 are unprocessed at any moment
CREATE INDEX idx_jobs_pending ON jobs (created_at) WHERE state = 'PENDING';

-- this query uses it; the index is a few pages, not gigabytes
SELECT * FROM jobs WHERE state = 'PENDING' ORDER BY created_at LIMIT 100;
```
]
#ans[functions, leading wildcards, implicit casts, `OR`, negation, low cardinality]
]
]

#ex(13, tier: 1, asked: "Cognizant · pattern")[
Compare a B+ tree index with a hash index. When would you ever choose the hash index?

#sol[
#table(columns: (auto, auto, auto),
  [], [*B+ tree*], [*Hash*],
  [`col = value`], [$O(log_f n)$, about 3 reads], [$O(1)$, about 1 read],
  [`col > value` / `BETWEEN`], [*yes* — descend once, walk leaves], [*no* — hashing destroys order],
  [`ORDER BY col`], [free, the index is sorted], [no help at all],
  [`LIKE 'abc%'`], [yes — it is a range], [no],
  [`MIN` / `MAX`], [free — first or last leaf], [full scan],
  [Multi-column prefix], [yes], [only on the whole key],
  [Size], [larger], [smaller],
  [Worst case], [guaranteed $O(log n)$], [$O(n)$ if the hash function is poor],
)

*When to choose hash:* only when *every* query on the column is an exact-equality lookup, the
column is long (so the fixed-size hash saves real space), and you will never sort or range-scan
on it. A common real case is a big text or URL column used only as a lookup key.

*Why B+ trees dominate anyway:* one structure answers equality, range, prefix, sort, `MIN`,
`MAX` and top-N. A hash index answers exactly one question. The B+ tree's extra 2 page reads
are usually served from the buffer pool and cost nothing.

#ans[B+ tree unless every single query is exact equality and you never need order]
]
#note[
Other index types worth naming in one line each, because an interviewer may ask "what else is
there?":
*Bitmap* — one bit vector per distinct value; superb for low-cardinality columns in a data
warehouse, terrible under concurrent writes (a single update locks a whole bit vector).
*GiST / GIN* — inverted indexes for full-text search, arrays and JSON: they index the *elements
inside* a value.
*R-tree* — bounding boxes for geographic queries ("which shops are inside this rectangle").
*LSM tree* — used by RocksDB and Cassandra: writes go to a memory table and are merged into
sorted files later. Great write throughput, reads may have to check several files.
]
]

#ex(14, tier: 1, asked: "TCS Digital · pattern")[
Explain a *composite* index by showing the physical order of the entries. Use
`(city, age, salary)`.

#sol[
The index is one sorted list. Sorting is by `city`; ties broken by `age`; ties broken by
`salary`. Exactly like sorting names in a phone book by surname, then first name.

#code(lang: "js", caption: "the actual index order, run with node")[
```
index order (city, age, salary):
  Kochi  22 34
  Kochi  24 42
  Kochi  44 50
  Pune   20 20
  Pune   24 20
  Pune   24 30
  Pune   26 50
  Pune   38 70
  Pune   40 96
  Surat  24 42
  Surat  46 40
  Surat  46 52

city='Pune' AND age>=30 -> contiguous run of 2 entries
age=24 alone             -> positions 1,4,5,9  (not contiguous -> index useless)
```
]

Read the two results carefully.
- `city = 'Pune' AND age >= 30` is a *contiguous run*. The engine seeks to the first entry and
  reads forward until the run ends. That is what a seek *is*.
- `age = 24` alone appears at positions 1, 4, 5 and 9 — scattered through the whole index. To
  find them the engine would have to read *every* entry. There is nothing to seek to.

#diagram(height: 4.4cm, caption: "The leftmost prefix rule, drawn. A seek needs the matching entries to be next to each other.")[
  #dnode(0pt, 0pt, 6.4cm, 0.7cm, "WHERE city='Pune' AND age>=30", fill: rgb("#f3f8f4"))
  #dnode(0pt, 0.9cm, 2.0cm, 0.5cm, "Kochi 22")
  #dnode(0pt, 1.5cm, 2.0cm, 0.5cm, "Kochi 44")
  #dnode(0pt, 2.1cm, 2.0cm, 0.5cm, "Pune 20")
  #dnode(0pt, 2.7cm, 2.0cm, 0.5cm, "Pune 38", fill: rgb("#dce9f2"))
  #dnode(0pt, 3.3cm, 2.0cm, 0.5cm, "Pune 40", fill: rgb("#dce9f2"))
  #dnode(2.4cm, 2.7cm, 4.0cm, 1.1cm, "one contiguous run\n→ SEEK", fill: rgb("#e3efe3"))
  #dnode(8.0cm, 0pt, 6.4cm, 0.7cm, "WHERE age=24", fill: rgb("#f7e8e8"))
  #dnode(8.0cm, 0.9cm, 2.0cm, 0.5cm, "Kochi 22")
  #dnode(8.0cm, 1.5cm, 2.0cm, 0.5cm, "Kochi 24", fill: rgb("#dce9f2"))
  #dnode(8.0cm, 2.1cm, 2.0cm, 0.5cm, "Pune 20")
  #dnode(8.0cm, 2.7cm, 2.0cm, 0.5cm, "Pune 24", fill: rgb("#dce9f2"))
  #dnode(8.0cm, 3.3cm, 2.0cm, 0.5cm, "Surat 24", fill: rgb("#dce9f2"))
  #dnode(10.4cm, 1.8cm, 4.3cm, 1.3cm, "scattered\n→ NO SEEK possible", fill: rgb("#f7e8e8"))
]

#ans[sorted by the first column, ties by the second, ties by the third — so only a leftmost
prefix produces a contiguous run]
]
#trick[
One index on `(a, b, c)` already covers `(a)` and `(a, b)`. So never create all three; create
the widest one. Conversely, an index on `(a, b)` does *not* cover `(b)` — that needs its own
index if `WHERE b = ?` is a real query.
]
]

#ex(15, tier: 1, asked: "Infosys · pattern")[
Page 5000 of a result set loads in 4 seconds; page 1 loads in 8 milliseconds. The query is
`ORDER BY created_at DESC LIMIT 20 OFFSET 99980`. Explain and fix.

#sol[
*Why.* `OFFSET n` does not skip cheaply. The engine must *produce* the first $n$ rows in order
and throw them away. `OFFSET 99980` builds 100,000 rows to return 20. The cost is linear in the
page number, so the last pages of a listing are always the slowest.

#table(columns: (auto, auto),
  [*OFFSET*], [*Rows produced and discarded*],
  [0], [0],
  [1,000], [1,000],
  [100,000], [100,000],
  [1,000,000], [1,000,000],
)

*Fix — keyset pagination* (also called seek pagination or cursor pagination). Instead of "skip
99,980 rows", say "start just after the last row I showed you".

#code(lang: "sql", caption: "before — cost grows with the page number")[
```sql
SELECT post_id, created_at, title
  FROM posts
 ORDER BY created_at DESC, post_id DESC
 LIMIT 20 OFFSET 99980;
```
]
#code(lang: "sql", caption: "after — constant cost, every page")[
```sql
-- the client sends back the (created_at, post_id) of the last row it received
SELECT post_id, created_at, title
  FROM posts
 WHERE (created_at, post_id) < (TIMESTAMP '2026-03-04 11:20:00', 88213)
 ORDER BY created_at DESC, post_id DESC
 LIMIT 20;
```
]
With an index on `(created_at DESC, post_id DESC)` this is a 3-page descent plus one leaf read,
*for every page*. Page 5000 costs the same as page 1.

Two details that make it correct:
+ The *row-value comparison* `(a, b) < (x, y)` is the whole trick. Writing
  `created_at <= x AND post_id < y` is wrong — it drops rows with an earlier timestamp and a
  larger id.
+ The sort key must be *unique*, which is why `post_id` is appended. With ties on `created_at`
  alone, rows would be skipped or repeated across pages.

#table(columns: (auto, 1fr, 1fr),
  [], [*`OFFSET`*], [*Keyset*],
  [Cost of page $k$], [grows with $k$], [constant],
  [Jump to page 500], [yes], [*no* — only next/previous],
  [Stable when rows are inserted], [no — rows shift between pages], [yes],
)
#ans[`OFFSET` materialises and discards every skipped row; use keyset pagination with a
row-value comparison on a unique sort key]
]
]

#ex(16, tier: 1, asked: "Wipro · pattern")[
Explain the three join algorithms and which one the planner picks for each of these:
(a) one customer joined to their orders, (b) all 200,000 customers joined to all 2,000,000
orders.

#sol[
Table sizes with our page model: `orders` = $ceil(2000000\/64) = 31250$ pages,
`customers` = $ceil(200000\/64) = 3125$ pages.

*Nested loop join.* For each row of the outer side, look up the inner side.
$ "cost" = "outer pages" + |"outer rows"| times "inner lookup cost" $

*Hash join.* Build a hash table on the smaller side in memory, then stream the bigger side
through it.
$ "cost" = "pages"_R + "pages"_S = 31250 + 3125 = 34375 $

*Sort-merge join.* Sort both sides on the join key, then walk them in step.
$ "cost" approx 2 times "pages"_R + 2 times "pages"_S + ("pages"_R + "pages"_S) approx 103125 $

*Case (a) — one customer, about 10 orders.*
Outer side is a *single row*. Nested loop with an index on `orders(customer_id)`:
$ 1 + 1 times (3 + 10) = 14 "page reads" $
A hash join would read all 31,250 order pages to build the table. Nested loop wins by 2000×.

*Case (b) — everything joined to everything.*
Nested loop: $3125 + 200000 times (3 + 10) = 2603125$ page reads, nearly all random.
Hash join: 34,375 sequential page reads.
Hash join wins by about 76×.

#table(columns: (auto, 1fr),
  [*Nested loop*], [tiny outer side, indexed inner side. Also the only choice for non-equality
    joins like `ON a.x BETWEEN b.lo AND b.hi`.],
  [*Hash join*], [both sides large, equality join, and the smaller side fits in the work memory.
    If it does not fit, it spills to disk in partitions and costs roughly double.],
  [*Sort-merge*], [both sides already sorted on the join key (for example, both come from index
    scans in that order), or the join is a range, or the output must be sorted anyway.],
)
#ans[(a) nested loop with an index — 14 reads; (b) hash join — 34,375 reads versus 2.6 million]
]
#trap[
"Nested loop is $O(n m)$ so it is always bad." It is the *fastest* join in an OLTP system,
because the outer side is usually one row from a primary-key lookup. What makes nested loop
catastrophic is a *wrong row estimate*: the planner thinks the outer side has 3 rows, picks a
nested loop, and the outer side actually has 300,000. This is the single most common cause of a
query that was fast for a year and is suddenly slow.
]
]

#practice(tier: 1, time: "25 minutes")[
+ A table gains 4 secondary indexes. By roughly what factor does an `INSERT` get more expensive?
+ Rewrite `WHERE LOWER(email) = 'a@x.com'` so it can use an index (two possible answers).
+ Index on `(a, b, c)`. Which columns does `WHERE a = 1 AND b > 5 AND c = 9` seek on?
+ Why is `LIKE '%son'` unindexable but `LIKE 'son%'` indexable?
+ A query returns 40% of the table. Index scan or sequential scan?
+ Name the join algorithm for: `WHERE o.order_id = 991` joined to `order_items`.
+ What does `Heap Fetches: 0` in an `EXPLAIN ANALYZE` tell you?
+ Give the index that makes `SELECT max(amount) FROM orders WHERE status='NEW'` instant.
]

#key[
1. About 5× — one clustered insertion plus four secondary ones. #h(8pt)
2. Either `CREATE INDEX ... ON users (LOWER(email))`, or store the email lower-cased at write
time and query `WHERE email = 'a@x.com'`. #h(8pt)
3. `a` and `b`. `c` is only a filter, because `b` is a range and order below a range is lost.
#h(8pt)
4. The index is sorted left to right, so a known prefix is a contiguous run; a known *suffix*
is scattered everywhere. #h(8pt)
5. Sequential scan — far past the crossover. #h(8pt)
6. Nested loop with an index on `order_items(order_id)`. #h(8pt)
7. It was a true index-only scan; the table never had to be read, so the visibility map said
every page was all-visible. #h(8pt)
8. `CREATE INDEX ON orders (status, amount DESC);` — the answer is the first entry in the
`status='NEW'` run.
]

#section[Tier 2 — applied, business-flavoured]
#tier-header(2)

#ex(17, tier: 2, asked: "Shopee · pattern")[
A product search page runs this and takes 2.4 seconds. Redesign the indexes.

#code(lang: "sql", caption: "")[
```sql
SELECT p.product_id, p.title, p.price
  FROM products p
 WHERE p.category_id = 77
   AND p.is_active   = true
   AND p.price BETWEEN 500 AND 2000
 ORDER BY p.sold_count DESC
 LIMIT 40;
```
]
Facts: 40 million products; 96% are active; category 77 has 120,000 products; about 18,000 of
those are in the price band.

#sol[
*Step 1 — rank the predicates by selectivity.*
#table(columns: (auto, auto, auto),
  [*Predicate*], [*Rows kept*], [*Selectivity*],
  [`category_id = 77`], [120,000], [0.003 — very selective],
  [`price BETWEEN 500 AND 2000`], [18,000 of those], [0.15 within the category],
  [`is_active = true`], [96%], [0.96 — nearly useless],
)

*Step 2 — apply E-R-O, but think about the `LIMIT`.*
Equality: `category_id`. Range: `price`. Order: `sold_count DESC`.

Candidate A — `(category_id, price, sold_count DESC)`. The engine seeks
`category_id = 77 AND price BETWEEN 500 AND 2000`, reads all ~18,000 matching entries,
*sorts them* by `sold_count`, and keeps 40. The sort of 18,000 rows is the cost.

Candidate B — `(category_id, sold_count DESC)`. The engine walks category 77 in `sold_count`
order and filters each entry on `price`, stopping as soon as 40 survive. If roughly 15% of the
category is in the price band, it expects to read about $40 \/ 0.15 approx 267$ entries.
*No sort at all.*

Candidate B reads 267 entries instead of sorting 18,000. It wins.

*Step 3 — make it covering and partial.*
#code(lang: "sql", caption: "the index to build")[
```sql
CREATE INDEX idx_p_cat_sold
    ON products (category_id, sold_count DESC)
       INCLUDE (price, title)
     WHERE is_active = true;
```
]
- `is_active` moves into a `WHERE` clause on the index: a *partial index*. It stops being a
  column (which would waste space at 96% one value) and becomes a filter on which rows are
  indexed at all.
- `price` and `title` are `INCLUDE`d, so the filter and the output both come from the index.
  Zero heap reads.

*Step 4 — state the failure mode honestly.* Candidate B is a gamble on the price filter not
being too selective. If a user searches a price band containing 0.1% of the category, the
engine may walk 40,000 entries before finding 40 survivors — slower than candidate A. If your
traffic has both shapes, keep both indexes and let the planner choose using the histogram on
`price`.

#ans[`(category_id, sold_count DESC) INCLUDE (price, title) WHERE is_active` — avoid the sort,
make it covering, and move the low-cardinality flag into a partial-index predicate]
]
]

#ex(18, tier: 2, asked: "Grab · pattern")[
A query was fast for eight months and became slow overnight. Nothing was deployed. Give five
causes and how you would confirm each.

#sol[
#table(columns: (auto, 1fr, 1fr),
  [*Cause*], [*Why it happens*], [*How to confirm*],
  [Stale statistics], [the table grew or its distribution shifted; the planner's row estimates
    are now wrong and it flipped to a bad plan], [`EXPLAIN ANALYZE`: estimated `rows` versus
    actual `rows` off by 100×. Fix: `ANALYZE tablename;`],
  [Crossed the cost threshold], [the table grew past the point where the index stopped paying
    (Example 11) and the planner correctly switched to a sequential scan], [the plan changed
    from `Index Scan` to `Seq Scan` and the row count really did grow],
  [Data skew appeared], [a single customer now owns 40% of the rows; the average-based estimate
    is meaningless for *that* customer's parameter], [run the query with the hot parameter and
    with a normal one and compare `EXPLAIN ANALYZE`],
  [Index bloat], [many updates left dead entries; the index is now three times its useful size
    and no longer fits in the buffer pool], [`pg_relation_size` on the index versus its expected
    size; fix with `REINDEX CONCURRENTLY`],
  [Cache eviction], [a new nightly job reads a huge table and evicts the hot index pages, so
    reads that used to be memory hits are now disk reads], [the buffer-cache hit ratio dropped
    at exactly that hour; the plan is unchanged but timings tripled],
)

*The first thing to run, always:*
#code(lang: "sql", caption: "estimate versus reality")[
```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT ... ;
-- look for:  rows=12 ... actual rows=418203      <- statistics are wrong
--            Buffers: shared read=91223          <- it went to disk
--            Rows Removed by Filter: 3900000     <- read far more than returned
```
]
#ans[stale statistics, a real crossover, new skew, index bloat, or cache eviction — and
`EXPLAIN (ANALYZE, BUFFERS)` distinguishes them in one command]
]
#trick[
`Rows Removed by Filter` is the most under-read number in a plan. A node that returns 40 rows
after removing 3.9 million did almost all of its work for nothing — that is exactly where a
better index belongs.
]
]

#ex(19, tier: 2, asked: "Agoda · pattern")[
The planner estimates 1 row and the query actually returns 400,000. Explain how the estimate
was computed and why it was wrong.

#sol[
*How the planner estimates.* It keeps per-column statistics: the number of distinct values, the
most common values with their frequencies, and a histogram of the rest. Then:
+ For an equality predicate with a histogram entry, use that entry's frequency.
+ For one without, assume the remaining values are *uniform*:
  $"selectivity" = 1\/"distinct values"$.
+ For `AND` of two predicates, assume *independence* and multiply.

#code(lang: "js", caption: "the estimator, run with node")[
```js
const stats = { rows: 2_000_000, distinctCity: 400, distinctStatus: 3,
                statusHist: { PENDING: 0.002, SHIPPED: 0.118, DELIVERED: 0.880 } };

const flat = (col) => 1 / stats["distinct" + col];    // no histogram: assume uniform

console.log("uniform guess for status =", flat("Status").toFixed(4),
            "-> rows", Math.round(stats.rows * flat("Status")));   // 0.3333, 666667
for (const [v, s] of Object.entries(stats.statusHist))
  console.log(" histogram status =", v, s, "-> est rows", stats.rows * s);
                        // PENDING 4000 | SHIPPED 236000 | DELIVERED 1760000

const combined = flat("City") * stats.statusHist.PENDING;       // independence
console.log("city AND status='PENDING' -> rows", (stats.rows * combined).toFixed(2));
                        // 5e-6 * 2,000,000 = 10.00
```
]

Look at the first two lines. Without a histogram the planner guesses 666,667 rows for
*every* status value. With a histogram it says 4,000 for `PENDING` and 1,760,000 for
`DELIVERED` — a 440× difference the uniform model cannot see. This is why `ANALYZE` matters.

*Why the 1-row estimate happened.* The independence assumption. Suppose the predicate is
`WHERE city = 'Pune' AND pincode = '411001'`. The planner computes
$ 1/400 times 1/20000 = 1.25 times 10^(-7) quad arrow.r.double quad 2000000 times 1.25 times 10^(-7) = 0.25 arrow.r "rounded to " 1 $
But `city` and `pincode` are not independent — a pincode *determines* the city. The true
selectivity is just the pincode's, $1\/20000$, giving 100 rows; and if that pincode is a busy
one, 400,000.

*The consequences and the fixes.*
The 1-row estimate makes the planner choose a nested loop, expecting one lookup. It performs
400,000 random lookups instead. The plan is not slightly wrong; it is thousands of times wrong.

+ `ANALYZE` the table — the cheapest fix, and often enough.
+ Raise the histogram resolution on the skewed column:
  `ALTER TABLE t ALTER COLUMN status SET STATISTICS 1000;` then `ANALYZE t;`
+ Tell the planner about the correlation:
  `CREATE STATISTICS s_city_pin (dependencies, ndistinct) ON city, pincode FROM addresses;`
+ Restructure so the correlated columns are one column, or one composite index.

#ans[uniform-within-distinct plus independence between predicates; correlated columns break
the multiplication and produce estimates that are orders of magnitude too small]
]
]

#ex(20, tier: 2, asked: "DBS · pattern")[
A 900-million-row `transactions` table is queried almost always by date range and account.
Queries older than 90 days are rare. Design the physical layout.

#sol[
*The problem with one giant table.* The index on `(account_id, txn_date)` is
$9 times 10^8 times 16 \/ 0.7 approx 20$ GB. It will not stay in cache, every lookup is a real
disk read, and the nightly delete of old rows is a multi-hour `DELETE` that bloats the table.

*The answer is partitioning.* Split the table by month. Each partition is a separate physical
table with its own indexes, and the planner *prunes* the ones that cannot match.

#code(lang: "sql", caption: "range partitioning by month (PostgreSQL)")[
```sql
CREATE TABLE transactions (
  txn_id     bigint,
  account_id bigint      NOT NULL,
  txn_date   date        NOT NULL,
  amount     numeric(14,2),
  PRIMARY KEY (txn_id, txn_date)       -- partition key must be in every unique key
) PARTITION BY RANGE (txn_date);

CREATE TABLE transactions_2026_01 PARTITION OF transactions
  FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE transactions_2026_02 PARTITION OF transactions
  FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

CREATE INDEX ON transactions_2026_01 (account_id, txn_date);
CREATE INDEX ON transactions_2026_02 (account_id, txn_date);
```
]

*What this buys.*
#table(columns: (auto, 1fr),
  [Partition pruning], [a query with `txn_date >= '2026-02-01'` touches one partition, so the
    index it searches is 1/36th the size and stays in memory],
  [Instant archiving], [`ALTER TABLE transactions DETACH PARTITION transactions_2023_01;` is
    metadata only. Compare that with `DELETE` on 25 million rows.],
  [Cheaper maintenance], [`VACUUM`, `ANALYZE` and `REINDEX` run per partition, so each finishes
    in minutes],
  [Better locality], [rows for one month sit together on disk, so a date-range scan is nearly
    sequential],
)

*The rules you must state, because they are where people get caught:*
+ *The partition key must appear in the `WHERE` clause* or the planner cannot prune, and the
  query touches all 36 partitions. Every query in the application must filter on `txn_date`.
+ *Every unique constraint must include the partition key.* You cannot have a globally unique
  `txn_id` alone; it becomes `(txn_id, txn_date)`.
+ *Do not over-partition.* Planning time grows with the partition count. Monthly for a few
  years is fine; hourly for ten years is not.

*The secondary idea — a covering index for the hot path.* Roughly 95% of the traffic is "last
90 days for one account", so also keep
`CREATE INDEX ON transactions_2026_02 (account_id, txn_date DESC) INCLUDE (amount);`
so the statement page is answered index-only.

#ans[range-partition by month, index each partition on `(account_id, txn_date)`, always filter
on `txn_date` so pruning works, and drop old data by detaching partitions]
]
]

#ex(21, tier: 2, asked: "LINE MAN · pattern")[
Read this plan and say what is wrong.

#code(lang: "sql", caption: "EXPLAIN ANALYZE output")[
```
Nested Loop  (cost=0.86..4821.10 rows=12 width=96)
             (actual time=0.11..9184.22 rows=214883 loops=1)
  ->  Index Scan using idx_riders_zone on riders r
        (cost=0.43..18.20 rows=3 width=48)
        (actual time=0.03..14.77 rows=53721 loops=1)
        Index Cond: (zone_id = 9)
  ->  Index Scan using idx_trips_rider on trips t
        (cost=0.43..1600.90 rows=4 width=48)
        (actual time=0.10..0.16 rows=4 loops=53721)
        Index Cond: (rider_id = r.rider_id)
Execution Time: 9201.44 ms
```
]

#sol[
*Read it bottom-up and compare the two row numbers on every line.*

#table(columns: (auto, auto, auto, auto),
  [*Node*], [*Estimated*], [*Actual*], [*Error*],
  [Index Scan on `riders`], [3], [53,721], [17,907× too low],
  [Index Scan on `trips`], [4 per loop], [4 per loop], [correct],
  [Nested Loop], [12], [214,883], [17,907× too low],
)

*The diagnosis.* The inner side is perfect. The *outer* estimate is catastrophically wrong: the
planner believed zone 9 had 3 riders, so a nested loop looked cheap — 3 lookups. Zone 9 has
53,721 riders, so the loop ran 53,721 times. `loops=53721` is the smoking gun: `actual time`
on an inner node is *per loop*, so the true cost of the inner node is
$53721 times 0.16 "ms" approx 8600 "ms"$ — essentially the entire query.

#diagram(height: 4.4cm, caption: "The plan tree. The node that lied is the one at the bottom left.")[
  #dnode(4.6cm, 0pt, 5.6cm, 1.0cm, "Nested Loop\nest 12  /  actual 214,883", fill: rgb("#f7e8e8"))
  #dnode(0pt, 2.2cm, 6.2cm, 1.2cm, "Index Scan  riders\nzone_id = 9\nest 3  /  actual 53,721", fill: rgb("#f7e8e8"))
  #dnode(8.0cm, 2.2cm, 6.2cm, 1.2cm, "Index Scan  trips\nrider_id = r.rider_id\nest 4  /  actual 4  /  loops 53,721")
  #darrow(3.1cm, 2.15cm, 6.0cm, 1.05cm, label: "outer")
  #darrow(11.1cm, 2.15cm, 8.8cm, 1.05cm, label: "inner")
]

*The fixes, in order.*
+ `ANALYZE riders;`. If `zone_id` is skewed, also
  `ALTER TABLE riders ALTER COLUMN zone_id SET STATISTICS 500;`
  With a correct estimate of 53,721 the planner will choose a *hash join* instead, costing one
  scan of each side rather than 53,721 index descents.
+ Ask whether the query should return 214,883 rows at all. A join producing a fifth of a million
  rows for a dashboard usually wants an aggregate or a `LIMIT` pushed down.
+ If the estimate cannot be fixed, a covering index on `trips (rider_id) INCLUDE (...)` at least
  makes each of the 53,721 loops cheaper.

#ans[the outer row estimate is 17,907× too low, so a nested loop was chosen and ran 53,721
times; fix the statistics so the planner picks a hash join]
]
#trap[
`actual time=0.10..0.16` on the inner node looks harmless — a sixth of a millisecond. It is
*per loop*. Always multiply by `loops` before you decide a node is cheap. This one line is
where most people misread a plan.
]
]

#ex(22, tier: 2, asked: "Razer · pattern")[
An `UPDATE`-heavy table has become slow even though no index definition changed. `pg_class`
says the index is 11 GB but its data should be 2 GB. Explain and fix without downtime.

#sol[
*Why an index bloats.* Under MVCC an `UPDATE` writes a *new row version*. If any indexed column
changed, a new index entry must be written too, and the old entry stays until vacuum removes it.
Vacuum frees the *space inside* a page for reuse, but it does not give pages back to the
operating system and it cannot merge half-empty index pages. After millions of updates the tree
is a sparse skeleton: 11 GB of pages holding 2 GB of live entries.

The damage is not the disk — it is the *buffer pool*. A 2 GB index fits in RAM; an 11 GB one
does not, so lookups that were memory hits become disk reads.

*How to confirm.*
#code(lang: "sql", caption: "measure before you rebuild")[
```sql
SELECT indexrelname,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size,
       idx_scan
  FROM pg_stat_user_indexes
 WHERE relname = 'sessions'
 ORDER BY pg_relation_size(indexrelid) DESC;
```
]

*Fix without downtime.*
#code(lang: "sql", caption: "rebuild online")[
```sql
REINDEX INDEX CONCURRENTLY idx_sessions_user;   -- PostgreSQL 12+, no long write lock
```
]
`CONCURRENTLY` builds a second copy while writes continue, then swaps. It is slower and needs
room for both copies, but it never blocks the application. Plain `REINDEX` takes an exclusive
lock and will stop your service.

*Stop it coming back.*
+ Make autovacuum more aggressive on that table:
  `ALTER TABLE sessions SET (autovacuum_vacuum_scale_factor = 0.02);`
+ Avoid updating indexed columns. In PostgreSQL, if *no indexed column changes* and the page has
  free space, the engine can do a *HOT update* — a new row version on the same page with *no*
  index entry at all. Leaving `last_seen_at` unindexed can remove almost all the index churn on
  a session table.
+ Give pages room to work with a lower fill factor:
  `ALTER TABLE sessions SET (fillfactor = 80);`
+ Hunt for long-running transactions. A transaction open for hours pins the oldest snapshot, so
  vacuum can remove nothing and bloat grows without limit.

#ans[dead index entries from `UPDATE`s that vacuum cannot compact; `REINDEX CONCURRENTLY`, then
prevent it with aggressive autovacuum, HOT updates and a lower fill factor]
]
]

#practice(tier: 2, time: "30 minutes")[
+ 40 million rows, one category holds 120,000. Is `category_id` selective enough to lead an
  index? Give the number.
+ An `EXPLAIN ANALYZE` node shows `actual time=0.20..0.30 loops=80000`. What is its real cost?
+ Give two reasons a partial index beats a full index on a boolean column.
+ Why must the partition key appear in every unique constraint of a partitioned table?
+ A plan shows `Rows Removed by Filter: 2900000` above an index scan that returned 50 rows.
  What index would you build?
+ Name the PostgreSQL feature that avoids writing index entries on an `UPDATE`, and its
  precondition.
+ Two predicates each keep 1% of the table. The planner estimates 0.01% together. When is that
  wrong?
]

#key[
1. $120000\/40000000 = 0.003$, that is 0.3% — well inside the crossover, so yes. #h(8pt)
2. Up to $80000 times 0.30 "ms" = 24$ seconds. #h(8pt)
3. It indexes only the rare value, so it is tiny and stays cached; and it is not maintained for
rows that do not match the predicate, so writes to the common case are cheaper. #h(8pt)
4. Uniqueness is enforced per partition by a local index; without the partition key in the
constraint the engine cannot prove global uniqueness. #h(8pt)
5. One that includes the filtered column, so the filter becomes part of the index condition —
for example `(status, created_at)` instead of `(status)`. #h(8pt)
6. HOT update; it needs *no indexed column to change* and free space on the same heap page.
#h(8pt)
7. Whenever the two columns are correlated — if one determines the other, the true selectivity
is 1%, not 0.01%, and the estimate is 100× too low.
]

#section[Tier 3 — the hard version]
#tier-header(3)

#ex(23, tier: 3, asked: "Google · pattern")[
Derive the cost of an index range scan from first principles, including the clustering factor,
and use it to explain why the same index is excellent on one table and useless on another
holding identical data.

#sol[
*Setup.* $N$ rows, $B$ rows per page, so $P = ceil(N\/B)$ table pages. A predicate matches $m$
rows. The index has height $h$ and fanout $f$, so the $m$ matching entries occupy about
$ceil(m\/f)$ leaf pages.

*Part 1 — reading the index.*
$ C_"index" = h + ceil(m/f) - 1 $
Descend once, then walk the leaf chain. With $f = 512$ and $m = 20000$ that is
$3 + 40 - 1 = 42$ page reads. The index part is almost never the problem.

*Part 2 — fetching the rows.* This is where it is decided. Define the *clustering factor* $c$:
the number of *distinct table pages* the $m$ matching rows live on.

Two extremes:
- *Perfectly clustered* — the table is physically stored in index order. The $m$ rows sit
  together: $c = ceil(m\/B)$, and the reads are nearly sequential.
- *Perfectly scattered* — every matching row is on a different page: $c = min(m, P)$, and every
  read is random.

$ C_"total" = underbrace(h + ceil(m/f) - 1, "index") + underbrace(c times r, "table") $
where $r$ is the random-to-sequential cost ratio ($r approx 1$ when the reads are sequential).

*Part 3 — put numbers in.* Our table: $N = 10^7$, $B = 64$, $P = 156250$, $h = 3$, $f = 512$,
$r = 4$. Let $m = 100000$ (1% of the table).

#table(columns: (auto, auto, auto, auto),
  [*Table*], [*Clustering factor $c$*], [*Total cost*], [*Versus scan (156,250)*],
  [clustered on this key], [$ceil(100000\/64) = 1563$], [$3 + 195 + 1563 times 1 = 1761$], [*89× better*],
  [scattered], [$min(100000, 156250) = 100000$], [$3 + 195 + 100000 times 4 = 400198$], [*2.6× worse*],
)

*The same index, the same data, the same query — and the answer flips from "89 times faster"
to "2.6 times slower" purely because of physical row order.*

*Part 4 — what this means in practice.*
+ This is why `EXPLAIN` on your laptop, where you loaded the data in sorted order, does not
  predict production, where rows arrived interleaved.
+ It is why a time-series table is nearly free to query by time (rows arrive in time order, so
  it is naturally clustered) and expensive to query by `user_id` (one user's rows are spread
  across the whole file).
+ The fixes: `CLUSTER t USING idx` in PostgreSQL (a one-off physical reorder, not maintained);
  choosing the clustered primary key in InnoDB to match the dominant access pattern; making the
  index *covering* so the clustering factor becomes irrelevant — you never touch the table at
  all.

*Part 5 — the InnoDB twist.* In InnoDB a secondary index leaf holds the *primary key*, not a
physical address. So the fetch is a second B+ tree descent, not a single page read:
$ C_"total" = h_"sec" + ceil(m/f) - 1 + m times h_"pk" $
Each fetch costs $h_"pk" approx 3$ logical reads rather than 1 — usually cached, but it is why
InnoDB benefits even more from covering indexes, and why a wide primary key hurts twice (once
in every secondary index's size, once in every secondary lookup).

#ans[$C = h + ceil(m\/f) - 1 + c r$; the clustering factor $c$ ranges from $ceil(m\/B)$ to $m$,
a factor of $B$, and it alone decides whether the index is a 90× win or a loss]
]
]

#ex(24, tier: 3, asked: "Amazon · pattern")[
Design the indexes for an order-history API that must serve p99 under 20 ms on a 4-billion-row
table, given these three access patterns. Justify every index and state what it costs.

#code(lang: "sql", caption: "the three queries")[
```sql
-- Q1: the customer's recent orders  (92% of traffic)
SELECT order_id, placed_at, status, total
  FROM orders WHERE customer_id = ? ORDER BY placed_at DESC LIMIT 20;

-- Q2: one order by its public reference  (7%)
SELECT * FROM orders WHERE order_ref = ?;

-- Q3: operations dashboard — stuck orders  (1%, but must never be slow)
SELECT order_id, customer_id, placed_at
  FROM orders
 WHERE status = 'PAYMENT_PENDING' AND placed_at < now() - INTERVAL '1 hour';
```
]

#sol[
*First — the physical layout, before any index.* 4 billion rows will not sit in one table that
anyone can vacuum or reindex. Partition by `placed_at`, monthly. That also means every query
must carry a date bound or it fans out across all partitions — which Q1 does not, so we must
handle that.

*Q1 — 92% of traffic, and it defines the design.*
#code(lang: "sql", caption: "the index for Q1")[
```sql
CREATE INDEX idx_o_cust_time ON orders (customer_id, placed_at DESC)
       INCLUDE (order_id, status, total);
```
]
- `customer_id` leads: it is the equality predicate, and it is extremely selective
  (4 billion rows / 80 million customers = 50 orders per customer).
- `placed_at DESC` second: the index is now *already in the required order* inside one
  customer, so `LIMIT 20` reads exactly 20 entries. No sort node at all.
- `INCLUDE` the other three columns: an index-only scan, so zero heap reads.

*Cost:* 3 to 4 page reads, all likely cached. Well under 1 ms. The `INCLUDE` columns make the
index perhaps 60 bytes per entry — around 340 GB across all partitions. That is the price, and
for 92% of traffic it is worth it.

*The partition-pruning problem with Q1.* Q1 has no date predicate, so it would search every
monthly partition. Two answers:
+ Change the API contract to a rolling window: "recent orders" means the last 24 months, so the
  query carries `AND placed_at > now() - INTERVAL '24 months'` and prunes to 24 partitions.
+ Better: partition by `HASH(customer_id)` instead of by date. Then Q1 prunes to exactly one
  partition. Archiving gets harder, which is the trade-off. For a customer-facing API where Q1
  is 92% of traffic, hash-partitioning on `customer_id` is the right call.

*Q2 — a unique lookup.*
#code(lang: "sql", caption: "the index for Q2")[
```sql
CREATE UNIQUE INDEX idx_o_ref ON orders (order_ref);
```
]
Two things to say:
+ It must be `UNIQUE` so it also *enforces* the invariant, not merely accelerates it. An index
  that is really a constraint should be declared as one.
+ Under hash partitioning on `customer_id`, a *global* unique index across partitions is not
  available in PostgreSQL. So either put `order_ref` in the partition key, or accept a
  per-partition unique index plus an application-level generator (a UUIDv7 or a Snowflake id)
  that is unique by construction.

*Q3 — 1% of traffic, but it must not degrade.*
#code(lang: "sql", caption: "the index for Q3")[
```sql
CREATE INDEX idx_o_stuck ON orders (placed_at)
       WHERE status = 'PAYMENT_PENDING';
```
]
A *partial* index. At any instant maybe 3,000 orders are payment-pending out of 4 billion, so
this index is a few hundred kilobytes — permanently cached, and almost free to maintain because
99.99% of rows never satisfy the predicate. A full index on `(status, placed_at)` would have
been 200 GB to answer a query about 3,000 rows.

There is a subtlety: rows leave the predicate when payment completes, which is a *delete* from
the partial index. That is exactly what you want — the index shrinks back on its own.

*What all of this costs on the write path.*
#table(columns: (auto, auto),
  [Clustered insert (the table itself)], [1 tree insertion],
  [`idx_o_cust_time`], [1 tree insertion, 60-byte entry],
  [`idx_o_ref`], [1 tree insertion, plus a uniqueness check],
  [`idx_o_stuck`], [1 insertion only for payment-pending rows, and a later delete],
)
About 3.2 tree insertions per order. At 5,000 orders per second that is 16,000 index writes per
second — fine on an SSD, and the reason we did *not* add a fourth index "just in case".

*What was deliberately not built.*
- No index on `status` alone: three distinct values, no selectivity, and Q3 is already covered
  by the partial index.
- No index on `total` or on `(customer_id, status)`: no query in the list needs them, and every
  unused index is pure write cost (Example 8).

#ans[a covering `(customer_id, placed_at DESC)` index with hash partitioning on `customer_id`
for Q1; a unique index on `order_ref` for Q2; a tiny partial index for Q3 — three indexes,
about 3.2 tree writes per insert]
]
]

#ex(25, tier: 3, asked: "Microsoft · pattern")[
Compare a B+ tree with an LSM tree as the storage structure for an index. Give the read, write
and space amplification of each and say which database chooses which.

#sol[
*The three amplifications.* Every storage engine trades these against each other.
#table(columns: (auto, 1fr),
  [*Write amplification*], [bytes written to the device / bytes the application logically wrote],
  [*Read amplification*], [device reads performed / logical reads requested],
  [*Space amplification*], [bytes stored on the device / bytes of live data],
)

*B+ tree.* An update finds the leaf and rewrites it in place.
- *Write:* to change 100 bytes the engine must write a whole 8 KB page, plus the WAL record.
  Amplification around 80× for small random updates — and worse when a page splits.
- *Read:* $h$ page reads, typically 1 real read after caching. Amplification near 1. *This is
  the B+ tree's strength.*
- *Space:* $1 / "fill factor"$, so about 1.4×, plus bloat between vacuums.

*LSM tree.* Writes land in an in-memory table; when it fills, it is flushed as an immutable
sorted file (an SSTable). Background *compaction* merges files into bigger levels.
- *Write:* the initial flush is one sequential write — very cheap. But each byte is rewritten
  once per level it is compacted through: with 7 levels and a size ratio of 10, amplification
  is roughly 10 to 30×. *Lower than a B+ tree for random writes, because every write is
  sequential*, and sequential bandwidth is 100× random IOPS on a spinning disk and still several
  times higher on an SSD.
- *Read:* a key may be in the memtable or in any level. Without help, that is one lookup per
  level. Bloom filters cut it to roughly 1 real read for a point lookup that exists, but a
  *range scan* must merge across all levels, so amplification stays higher than a B+ tree's.
- *Space:* obsolete versions live until compaction removes them — typically 1.1× to 2×, with
  spikes during compaction.

#table(columns: (auto, auto, auto),
  [], [*B+ tree*], [*LSM tree*],
  [Random write], [slow — read-modify-write a page], [fast — append only],
  [Point read], [~1 I/O], [~1 I/O with bloom filters],
  [Range scan], [excellent — linked leaves], [merge across levels],
  [Write amplification], [high for small updates], [lower, and sequential],
  [Space amplification], [~1.4× + bloat], [1.1–2×, spiky],
  [Latency shape], [steady], [spiky — compaction stalls],
  [Used by], [PostgreSQL, InnoDB, Oracle, SQL Server], [RocksDB, LevelDB, Cassandra, HBase, ScyllaDB],
)

*How to choose.*
- Write-heavy, key-value or wide-column, tolerant of p99 spikes $arrow.r$ LSM.
- Read-heavy or range-scan-heavy, needs predictable latency and full SQL $arrow.r$ B+ tree.
- MySQL offers both: InnoDB (B+ tree) and MyRocks (LSM). Facebook moved parts of its MySQL fleet
  to MyRocks for roughly half the space and much lower write amplification on flash.

*The honest caveat.* The classic "LSM writes are cheap" claim compares the *user-visible* write.
Compaction does the work later, in the background, and it competes for the same device
bandwidth. LSM does not remove write cost; it *defers and batches* it, converting random writes
into sequential ones. That is the real win, and saying it that way shows you understand the
mechanism rather than the slogan.

#ans[B+ tree: read amplification ~1, high write amplification, steady latency. LSM: sequential
writes and lower write amplification, higher read and range amplification, spiky latency from
compaction.]
]
]

#ex(26, tier: 3, asked: "Goldman Sachs · pattern")[
A report joins four tables and takes 90 seconds. The planner's join order is clearly wrong.
Explain how a cost-based optimiser chooses a join order, why it goes wrong here, and what you
can do.

#sol[
*How the optimiser works.*
+ *Enumerate.* For $n$ tables there are $ (2(n-1))! / (n-1)!$ join orders — 12 for 3 tables,
  120 for 4, and 17,297,280 for 8. A System-R style optimiser uses dynamic programming over
  *subsets*: it computes the best plan for every subset of tables, building up from pairs. That
  is $O(3^n)$ instead of factorial — feasible to about 10 to 12 tables.
+ *Cost.* For each candidate it estimates the output cardinality of the join and the cost of
  each physical algorithm (nested loop, hash, merge).
+ *Prune.* Keep only the cheapest plan per subset — plus the cheapest plan per *interesting
  sort order*, because a plan that is already sorted on the next join key may win later even
  though it is more expensive now.
+ Beyond roughly 12 tables, the optimiser gives up on exhaustive search and uses a greedy or
  genetic algorithm (`geqo` in PostgreSQL).

*Why it goes wrong.* Join order is chosen entirely from *estimated cardinalities*, and
estimation error *compounds multiplicatively* up the tree. If each of three joins is estimated
10× too low, the top of the tree is 1000× off. The optimiser is not choosing badly — it is
choosing correctly from wrong numbers.

The three usual sources:
+ Correlated predicates (Example 19) — independence assumption multiplies when it should not.
+ Join cardinality on non-key columns — estimated as
  $ |R| times |S| / max("distinct"_R, "distinct"_S) $
  which is badly wrong when the join column's distribution is skewed.
+ A subquery, function or `LIKE` the planner cannot see through, for which it substitutes a
  fixed default guess.

*What to do, in the order you should try it.*
#table(columns: (auto, 1fr),
  [1. Fix the inputs], [`ANALYZE` every table. Raise `SET STATISTICS` on the skewed join and
    filter columns. Create extended statistics for correlated pairs.],
  [2. Give the planner room], [raise `join_collapse_limit` and `from_collapse_limit` so it
    actually searches, and `work_mem` so a hash join is allowed to stay in memory.],
  [3. Reduce the problem], [materialise a selective part into a CTE or temporary table, `ANALYZE`
    it, and join against that. Now the planner has *measured* cardinalities, not estimates.],
  [4. Force the order], [last resort. `SET join_collapse_limit = 1` makes PostgreSQL join in
    written order; MySQL has `STRAIGHT_JOIN`; SQL Server and Oracle have hints. This freezes the
    plan against future data changes — you are taking on maintenance forever.],
)

#code(lang: "sql", caption: "step 3 in practice — the usual real fix")[
```sql
-- 90 s version: four-way join, planner guesses at every step
-- fixed version: reduce first, then join against a small measured set
CREATE TEMP TABLE hot_accounts AS
SELECT account_id
  FROM transactions
 WHERE txn_date >= DATE '2026-03-01'
 GROUP BY account_id
HAVING sum(amount) > 1000000;          -- a few thousand rows

ANALYZE hot_accounts;                  -- now the planner KNOWS the size

SELECT ...
  FROM hot_accounts h
  JOIN accounts a ON a.account_id = h.account_id
  JOIN customers c ON c.customer_id = a.customer_id
  JOIN regions   r ON r.region_id   = c.region_id;
```
]

#ans[dynamic programming over subsets, costed from estimated cardinalities that compound
multiplicatively; fix the statistics first, materialise a measured intermediate second, and
force the order only as a last resort]
]
]

#ex(27, tier: 3, asked: "Adobe · pattern")[
You must add an index to a 600 GB table in production. Writes must not stop. Describe exactly
what happens, what can go wrong, and how you would verify the result.

#sol[
*The naive command is a trap.*
`CREATE INDEX idx ON big_table (col);` takes an `ACCESS EXCLUSIVE`-equivalent lock in
PostgreSQL — it blocks every `INSERT`, `UPDATE` and `DELETE` on the table for the entire build.
On 600 GB that is hours. Your application is down.

*The right command.*
#code(lang: "sql", caption: "")[
```sql
CREATE INDEX CONCURRENTLY idx_big_col ON big_table (col);
```
]

*What it actually does — two table scans and a wait.*
+ *Pass 1.* Take a snapshot, scan the whole table, build the index from the rows visible in that
  snapshot. Writes continue throughout.
+ *Wait.* Wait for every transaction that started before pass 1 to finish, so that no writer is
  still unaware of the new index.
+ *Pass 2.* Take a second snapshot and scan again, adding the rows that were inserted or updated
  during pass 1.
+ *Wait again*, then mark the index valid and usable by the planner.

*What can go wrong — say all of these, because this is the real content of the question.*
#table(columns: (auto, 1fr),
  [It can fail and leave a mess], [If it fails, the index remains in the catalogue marked
    `indisvalid = false`. It is *not used by queries* but *is maintained on every write* — the
    worst of both worlds. Find it with
    `SELECT indexrelid::regclass FROM pg_index WHERE NOT indisvalid;` and `DROP INDEX` it.],
  [It is blocked by long transactions], [Both waits block behind the oldest running transaction.
    One analyst's session left open makes the build hang for hours while still holding
    resources.],
  [It needs a lot of space], [the new index plus temporary sort space. Check free disk first; a
    600 GB table's index may be 40 GB and the sort may need as much again.],
  [It is slow and I/O heavy], [two full scans plus a sort. It will compete with production
    traffic for cache and bandwidth. Run it in a low-traffic window and consider lowering the
    build's I/O priority.],
  [Not allowed inside a transaction], [`CREATE INDEX CONCURRENTLY` cannot run in a transaction
    block, so most migration frameworks need it marked as non-transactional.],
  [Unique indexes can fail late], [`CREATE UNIQUE INDEX CONCURRENTLY` fails at the end if a
    duplicate exists — after hours of work. Check for duplicates first.],
)

*The procedure I would actually follow.*
+ Check for duplicates and for long-running transactions; kill or wait out anything older than a
  few minutes.
+ Confirm free disk space is at least 3× the expected index size.
+ Run `CREATE INDEX CONCURRENTLY` in a maintenance window, monitoring
  `pg_stat_progress_create_index`.
+ Verify validity: `SELECT indisvalid FROM pg_index WHERE indexrelid = 'idx_big_col'::regclass;`
+ `ANALYZE big_table;` — the planner will not use a new index well until statistics are fresh.
+ Verify usefulness, not just existence: run the target query with `EXPLAIN (ANALYZE, BUFFERS)`
  and confirm the plan changed and `shared read` fell.
+ Check `idx_scan` in `pg_stat_user_indexes` a day later. If it is still 0, the index is pure
  cost and should be dropped.

*MySQL note.* InnoDB's online DDL does the equivalent with
`ALTER TABLE ... ADD INDEX ..., ALGORITHM=INPLACE, LOCK=NONE;` — it buffers concurrent changes
in an online log and applies them at the end. The failure mode is that the log fills
(`innodb_online_alter_log_max_size`) and the whole `ALTER` fails after hours.

#ans[`CREATE INDEX CONCURRENTLY`: two scans and two waits, no write lock; watch for invalid
leftovers, long transactions, disk space and late unique violations; verify with
`indisvalid`, a fresh `ANALYZE`, a re-run `EXPLAIN ANALYZE`, and `idx_scan` the next day]
]
]

#ex(28, tier: 3, asked: "Uber · pattern")[
`SELECT count(*) FROM events;` takes 40 seconds on a 900-million-row table. Explain why, and
give three designs with their exact trade-offs.

#sol[
*Why it is slow.* In PostgreSQL, MVCC means *no single place records how many rows are
visible to you*. Different transactions see different counts, so `count(*)` must examine every
row and test its visibility. That is a full scan of all 900 million rows — about
$ceil(9 times 10^8 \/ 64) = 14062500$ pages, roughly 115 GB of I/O.

An index does not help by itself, but an *index-only scan* over the smallest index does reduce
the bytes read — it still visits every entry, but the entries are far smaller than the rows.
That is why `count(*)` sometimes uses an index and is still slow.

*Design 1 — an approximate count.*
#code(lang: "sql", caption: "milliseconds, accurate to a few percent")[
```sql
SELECT reltuples::bigint AS approx_rows
  FROM pg_class
 WHERE oid = 'events'::regclass;
```
]
#table(columns: (auto, 1fr),
  [Cost], [one catalogue row read — under a millisecond],
  [Accuracy], [as of the last `ANALYZE` or autovacuum; typically within 1–5%],
  [Use when], [a dashboard shows "about 900 million events". Nobody reads the last six digits.],
)

*Design 2 — a maintained counter.*
A trigger or an application-level increment keeps a running total.
#code(lang: "sql", caption: "exact, but it creates a hot row")[
```sql
CREATE TABLE event_counts (bucket int PRIMARY KEY, n bigint NOT NULL DEFAULT 0);
INSERT INTO event_counts (bucket) SELECT generate_series(0, 99);   -- 100 buckets

-- INSERT path: pick a random bucket so the counter is not one hot row
-- floor(), not a cast: (random() * 100)::int rounds, so it can produce 100
UPDATE event_counts SET n = n + 1 WHERE bucket = floor(random() * 100)::int;

-- read path:
SELECT sum(n) FROM event_counts;
```
]
#table(columns: (auto, 1fr),
  [Cost], [one extra row update per insert; the read is 100 rows],
  [Accuracy], [exact],
  [Danger], [without bucketing, every insert contends on one row and the insert rate collapses
    (see the hot-row analysis in Chapter 7). With bucketing you pay a small write cost on every
    insert forever.],
  [Also], [a `DELETE` path must decrement, or the count drifts. Deletes are the usual source of
    bugs here.],
)

*Design 3 — count only what is asked for.*
Almost no real product needs the count of the whole table. It needs "events for this user this
month" or "is there more than one page of results".
#code(lang: "sql", caption: "a bounded count, and a pre-aggregated rollup")[
```sql
-- "are there more than 500?" — stops early, never scans the table
SELECT count(*) FROM (SELECT 1 FROM events WHERE user_id = 42 LIMIT 501) s;

-- a rollup table maintained by a nightly or streaming job
CREATE TABLE event_daily (day date, user_id bigint, n bigint,
                          PRIMARY KEY (day, user_id));
SELECT sum(n) FROM event_daily WHERE user_id = 42 AND day >= DATE '2026-03-01';
```
]
#table(columns: (auto, 1fr),
  [Cost], [an index seek, or a few rollup rows],
  [Accuracy], [exact for the bounded count; as fresh as the job for the rollup],
  [Trade-off], [you must define the granularity in advance; a new question needs a new rollup],
)

*How to choose, said as a rule:* ask what the number is *for*. If it is displayed, approximate
it. If it drives a decision, bound it (`LIMIT 501`). If it is a business metric, pre-aggregate
it. An exact live `count(*)` of a 900-million-row table is almost always a requirement nobody
actually had.

*The InnoDB footnote.* MySQL's `count(*)` on InnoDB is also a scan, for the same MVCC reason.
MyISAM kept an exact row count in its header and answered instantly — but it had no
transactions, which is exactly the trade being made.

#ans[MVCC means visibility is per-transaction, so an exact count must scan every row; use
`reltuples` for display, a bucketed counter for exactness, or a bounded/rolled-up count for the
question actually being asked]
]
]

#practice(tier: 3, time: "40 minutes")[
+ Write the full cost formula for an index range scan and name every symbol.
+ A clustering factor equals the number of matching rows. What does that tell you about the
  table?
+ Explain why InnoDB benefits more from covering indexes than PostgreSQL does.
+ Give the write, read and space amplification of a B+ tree and of an LSM tree, in one line each.
+ Why does cardinality estimation error compound multiplicatively up a join tree?
+ `CREATE INDEX CONCURRENTLY` failed overnight. What is now true of your database, and what
  must you do?
+ A query needs an exact count of a 900-million-row table every 5 seconds. Push back on the
  requirement — what would you ask?
+ You have `(a, b)` and `(a, b, c)` and `(a)`. Which would you drop and why?
]

#key[
1. $C = h + ceil(m\/f) - 1 + c r$: $h$ height, $m$ matched rows, $f$ entries per leaf, $c$
clustering factor (distinct table pages touched), $r$ random-to-sequential cost ratio. #h(8pt)
2. The matching rows are perfectly scattered — one per page — so the table's physical order has
no relationship to this index. #h(8pt)
3. In InnoDB the row fetch is a second full B+ tree descent through the clustered index, not a
single page read, so avoiding it saves more. #h(8pt)
4. B+ tree: write high (a whole page per small change), read ~1, space ~1.4× plus bloat. LSM:
write lower and sequential but repeated per compaction level, read higher (several levels, cut
by bloom filters), space 1.1–2× and spiky. #h(8pt)
5. The output cardinality of one join is the input to the next, so each level multiplies its own
error by the error already carried in. #h(8pt)
6. There is an invalid index that queries ignore but every write still maintains. Find it with
`pg_index WHERE NOT indisvalid`, drop it, then retry the build. #h(8pt)
7. "What decision does the number drive, and what error is acceptable?" — then offer `reltuples`
for display, a bucketed counter for exactness, or a rollup. #h(8pt)
8. Drop `(a)` and `(a, b)`. `(a, b, c)` already serves every leftmost prefix, so both are pure
write cost — unless `(a, b)` is far smaller and is used for an index-only scan on a hot path.
]

#section[Rapid-fire — one-line answers]

Cover the right column. These thirty cover most of what a technical round asks on indexing.

#table(columns: (1fr, 1.25fr),
  [*Question*], [*Answer*],
  [What is an index, in one sentence?], [A sorted copy of some columns plus a pointer to the row.],
  [Why B+ tree and not binary search tree?], [Huge fanout means 3–4 levels instead of 30, and the unit of I/O is a page, not a node.],
  [Where does a B+ tree store the data?], [Only in the leaves; internal nodes hold separator keys.],
  [Why are B+ tree leaves linked?], [So a range scan descends once and then walks sideways.],
  [Typical height for 10 million rows?], [3 levels, so 3 page reads to a leaf.],
  [How many clustered indexes per table?], [One — the rows can be in only one physical order.],
  [What does an InnoDB secondary index leaf hold?], [The indexed key plus the *primary key*, so a lookup is two descents.],
  [Define selectivity.], [Matching rows divided by total rows. Smaller is better for an index.],
  [When is a sequential scan cheaper?], [Past roughly 0.4–5% of the table, depending on the random cost ratio and the clustering factor.],
  [What is the clustering factor?], [How many distinct table pages the matching rows sit on.],
  [State the leftmost prefix rule.], [An index on `(a,b,c)` serves `a`, `(a,b)` or `(a,b,c)` — never `b` alone.],
  [Index column order rule?], [Equality, then Range, then Order-by. E-R-O.],
  [What happens after the first range column?], [Later columns can be filtered but not seeked, and their sort order is lost.],
  [What is a covering index?], [It holds every column the query needs, so the table is never read.],
  [What is a partial index?], [An index with a `WHERE` clause — only matching rows are indexed.],
  [Define sargable.], [The indexed column appears bare on one side of the comparison.],
  [Name four index killers.], [Function on the column, leading wildcard, implicit cast, `OR` across columns.],
  [Why is `LIKE '%abc'` unindexable?], [The index is sorted left to right; a known suffix is scattered everywhere.],
  [`EXPLAIN` versus `EXPLAIN ANALYZE`?], [Estimates versus actually running it and reporting the truth.],
  [First thing to check in a plan?], [Estimated `rows` against actual `rows`.],
  [What does `loops=N` mean?], [The node ran N times; multiply its `actual time` by N.],
  [What does `Rows Removed by Filter` tell you?], [Work done for nothing — usually a missing index column.],
  [Three join algorithms?], [Nested loop, hash join, sort-merge join.],
  [When does nested loop win?], [Tiny outer side with an indexed inner side — the OLTP case.],
  [When does hash join win?], [Both sides large, equality join, smaller side fits in `work_mem`.],
  [Why did a fast query suddenly get slow?], [Stale statistics, a crossed cost threshold, new skew, index bloat, or cache eviction.],
  [Replacement for `OFFSET` pagination?], [Keyset pagination with a row-value comparison on a unique sort key.],
  [Cost of each extra index on writes?], [One more B+ tree insertion per row, plus possible page splits.],
  [How do you add an index without downtime?], [`CREATE INDEX CONCURRENTLY` — two scans, no write lock, cannot run in a transaction.],
  [Hash index versus B+ tree?], [Hash is $O(1)$ for equality only; B+ tree also does ranges, prefixes, sorts, `MIN` and `MAX`.],
)

#revision[
*The one sentence.* An index is a sorted copy of some columns plus a pointer to the row.
Sorted $arrow.r$ fast search. Copy $arrow.r$ slow writes. Sorted *this* way $arrow.r$ helps only
*these* queries.

*The numbers to carry into the room*
#table(columns: (auto, auto),
  [Page], [8 KB (PostgreSQL), 16 KB (InnoDB)],
  [Rows per page (128-byte row)], [64],
  [10 million rows], [156,250 pages, 1.2 GB],
  [Fanout (16-byte entry)], [512],
  [Tree height for 10 million keys], [3],
  [Lookup cost], [3 reads to the leaf, +1 for the row],
  [Sequential-scan crossover], [about 0.4% of the table at $r = 4$],
)

*Formulas*
$ f = floor(("page" times "fill") / "entry") quad h = ceil(log_f n) quad
  C = h + ceil(m/f) - 1 + c dot r $
$ "selectivity" = m/N quad quad "cost"_"scan" = ceil(N/B) $

*Design rules*
+ E-R-O: Equality columns, then the Range column, then the `ORDER BY` columns.
+ One index on `(a, b, c)` already covers `(a)` and `(a, b)`. Build the widest, not all three.
+ `INCLUDE` the columns you only `SELECT`; put in the key the ones you filter or sort on.
+ Low-cardinality flag $arrow.r$ partial index, not a key column.
+ Keep the indexed column bare on the left. No function, no cast, no leading `%`.
+ A `LIMIT` with an `ORDER BY` can often beat a selective filter: walk the sort order and stop
  early instead of matching then sorting.

*Reading a plan, in order*
+ Estimated `rows` versus actual `rows`. Off by 100×? Fix statistics first.
+ `loops` — multiply before judging an inner node cheap.
+ `Rows Removed by Filter` — work done for nothing.
+ `Buffers: shared read` — how much really came from disk.

*The five traps*
+ `YEAR(col) = 2026` kills the index. Rewrite as a range.
+ A number compared to a `VARCHAR` column is an invisible cast that kills the index.
+ `actual time` on an inner node is *per loop*.
+ The "5% rule" is a memory aid; the clustering factor can move the crossover by 60×.
+ Every unused index costs writes, memory and space, and returns nothing. Measure `idx_scan`.
]

]
