#import "../../shared/lib/style.typ": *

#chapter(num: 6, title: "Databases & Data Modelling",
  tagline: "The schema is the design. Everything else is plumbing around it.")[

#section[The idea in one page]

You can draw ten boxes and still fail the round. You cannot write a correct schema and
fail the round. The schema is where the interviewer finds out whether you actually
understand the problem: which things exist, which things are the same thing, what must
never be lost, and which query has to be fast.

This chapter teaches four things, in this order:
+ how a database *finds* a row (indexes, pages, B-trees, LSM trees),
+ how to *shape* the rows (keys, normalisation, and when to stop normalising),
+ how the database keeps two users from corrupting each other (transactions, isolation),
+ how all of that changes when the table has ten billion rows.

#formulas(title: "What a database question is really testing")[
#table(columns: (auto, 1fr),
  [*1. Keys*], [Did you pick a primary key that is stable, unique, and not guessable?],
  [*2. Access path*], [For every query you wrote, can you name the index that serves it?],
  [*3. Correctness*], [Two users, same row, same millisecond --- what happens?],
  [*4. Shape*], [SQL or NoSQL, and can you defend it with the query pattern, not with taste?],
  [*5. Growth*], [At 100x rows, which query dies first, and what do you do about it?],
)

The single sentence that earns the most marks in this round:

#align(center)[*"Here is the query, and here is the index that makes it fast."*]

Say it for every endpoint you wrote in Step 3. A candidate who lists five endpoints and
five matching indexes has already out-scored a candidate who drew a beautiful diagram.
]

#subsection[The numbers you must know by heart]

#table(columns: (1fr, auto, 1fr, auto),
  [read one row by primary key, in RAM], [0.1 -- 0.5 ms],
    [read one row by index, from SSD], [1 -- 5 ms],
  [indexed query returning 100 rows], [5 -- 15 ms],
    [full scan of 1 million rows], [0.2 -- 1 s],
  [random 4 KB SSD read], [\~0.1 ms], [sequential SSD read], [0.5 -- 2 GB/s],
  [one SQL node, simple reads], [3,000 -- 8,000 QPS],
    [one SQL node, durable writes], [200 -- 2,000 TPS],
  [B-tree page size], [8 KB], [B-tree fanout], [\~500 keys/page],
  [row overhead per row], [24 -- 40 bytes], [one DB connection], [5 -- 10 MB RAM],
)

#trick[
*The B-tree height trick.* A page is 8 KB. One key plus one child pointer is roughly
16 bytes. So one page holds about $8192 \/ 16 = 512$ entries; round it to 500.

$ "rows covered by a tree of height " h = 500^h $

$500^1 = 500$. $500^2 = "250,000"$. $500^3 = "125,000,000"$. $500^4 = 62.5$ billion.

So *any table you will ever meet in an interview is 3 or 4 page reads deep*, and the top
two levels are always in RAM. That is why "the index makes it fast" is not hand-waving: it
is the difference between 3 reads and 12,500 reads on a 100-million-row table.
]

#subsection[How the database actually finds your row]

#diagram(height: 6.0cm, caption: "An index lookup: 3 reads down the tree, then 1 read into the heap. A full scan would read every heap page instead.")[
  #dnode(5.4cm, 0.1cm, 5.8cm, 0.85cm, "B-tree root page\nkeys < 400 | 400-799 | 800+", fill: rgb("#dce9f2"))

  #dnode(0.2cm, 1.9cm, 4.8cm, 0.95cm, "leaf page: 101 -- 399\nkey -> (page, slot)")
  #dnode(5.4cm, 1.9cm, 5.8cm, 0.95cm, "leaf page: 400 -- 799\nid 512 -> (page 7, slot 3)", fill: rgb("#dce9f2"))
  #dnode(11.6cm, 1.9cm, 4.8cm, 0.95cm, "leaf page: 800 -- 1200\nkey -> (page, slot)")

  #darrow(6.6cm, 0.95cm, 2.6cm, 1.9cm)
  #darrow(8.3cm, 0.95cm, 8.3cm, 1.9cm, label: "read 2")
  #darrow(10.0cm, 0.95cm, 14.0cm, 1.9cm)

  #dnode(0.2cm, 4.1cm, 3.7cm, 1.0cm, "heap page 5\n(60 rows)")
  #dnode(4.3cm, 4.1cm, 3.7cm, 1.0cm, "heap page 6\n(60 rows)")
  #dnode(8.4cm, 4.1cm, 3.7cm, 1.0cm, "heap page 7\nslot 3 = your row", fill: rgb("#dce9f2"))
  #dnode(12.5cm, 4.1cm, 3.9cm, 1.0cm, "heap page 8\n(60 rows)")

  #darrow(8.3cm, 2.85cm, 10.0cm, 4.1cm, label: "read 4")
  #place(dx: 0.2cm, dy: 3.35cm)[#text(size: 7.5pt, fill: muted)[the heap: rows in insert order, no order at all]]
]

Read that picture as four disk reads: root, one internal level (not drawn), one leaf, then
one heap page. The leaf does not hold the row. It holds a *pointer* to the row. That extra
hop has a name --- the *heap fetch* --- and killing it is what a covering index does.

#subsection[Two ways to store a table: B-tree and LSM]

Every database you will be asked about is one of these two. Know which, and why.

#diagram(height: 6.4cm, caption: "B-tree: write in place, one seek per write. LSM: append to RAM, flush sorted runs, merge later.")[
  #place(dx: 0pt, dy: 0pt)[#text(size: 9pt, weight: "bold")[B-tree (Postgres, MySQL/InnoDB, Oracle)]]
  #dnode(0.2cm, 0.7cm, 2.5cm, 0.8cm, "write")
  #darrow(2.75cm, 1.1cm, 3.55cm, 1.1cm)
  #dnode(3.6cm, 0.7cm, 2.6cm, 0.8cm, "WAL append")
  #darrow(6.25cm, 1.1cm, 7.05cm, 1.1cm)
  #dnode(7.1cm, 0.7cm, 3.0cm, 0.8cm, "find the page")
  #darrow(10.15cm, 1.1cm, 10.95cm, 1.1cm)
  #dnode(11.0cm, 0.7cm, 5.2cm, 0.8cm, "rewrite that 8 KB page in place", fill: rgb("#f2dcdc"))
  #place(dx: 0.2cm, dy: 1.7cm)[#text(size: 7.5pt, fill: muted)[reads: 3--4 page reads, always. writes: random, one page per write, so write amplification is small but seeks are not.]]

  #place(dx: 0pt, dy: 2.5cm)[#text(size: 9pt, weight: "bold")[LSM tree (Cassandra, RocksDB, HBase, ScyllaDB)]]
  #dnode(0.2cm, 3.2cm, 2.5cm, 0.8cm, "write")
  #darrow(2.75cm, 3.6cm, 3.55cm, 3.6cm)
  #dnode(3.6cm, 3.2cm, 2.6cm, 0.8cm, "commit log")
  #darrow(6.25cm, 3.6cm, 7.05cm, 3.6cm)
  #dnode(7.1cm, 3.2cm, 3.0cm, 0.8cm, "memtable (RAM)", fill: rgb("#dce9f2"))
  #darrow(10.15cm, 3.6cm, 10.95cm, 3.6cm, label: "full")
  #dnode(11.0cm, 3.2cm, 2.4cm, 0.8cm, "sorted run 0")
  #dnode(11.0cm, 4.3cm, 2.3cm, 0.7cm, "run 1")
  #dnode(14.1cm, 4.3cm, 2.3cm, 0.7cm, "run 2 (big)")
  #darrow(12.15cm, 4.0cm, 12.15cm, 4.3cm)
  #darrow(13.35cm, 4.65cm, 14.05cm, 4.65cm)
  #place(dx: 13.3cm, dy: 3.85cm)[#text(size: 7pt, fill: dc)[compact]]
  #place(dx: 0.2cm, dy: 5.3cm)[#text(size: 7.5pt, fill: muted)[writes: sequential, never a seek. reads: may touch several runs, so a Bloom filter per run. compaction rewrites data many times.]]
]

#table(columns: (auto, 1fr, 1fr),
  [], [*B-tree*], [*LSM tree*],
  [write path], [find page, rewrite page (random I/O)], [append to RAM, flush sorted (sequential I/O)],
  [write speed], [limited by random I/O], [very high; 10--50x more write throughput],
  [read one row], [3--4 reads, predictable], [check memtable + N runs; Bloom filters help],
  [range scan], [excellent, the leaves are a linked list], [good, but merges N runs on the fly],
  [space], [pages are \~70% full, so \~30% slack], [compaction reclaims space in bursts],
  [write amplification], [low (1--3x)], [high (10--30x) --- measured below],
  [the cost you pay], [random writes], [background compaction CPU and disk],
  [pick it when], [you need joins, transactions, secondary indexes], [you need huge write rates and simple key access],
)

#note[
*Write amplification* means: the user wrote 1 row, the disk wrote $k$ rows. The LSM demo
later in this chapter measures 10.01x on a real run. That is not a bug; it is the price of
turning random writes into sequential ones. Say the number out loud in an interview and
you sound like somebody who has operated one.
]

#subsection[SQL or NoSQL --- decide with the query pattern]

#formulas(title: "The decision table. Do not say 'it depends'.")[
#table(columns: (1fr, auto),
  [*If this is true about your data...*], [*then*],
  [you need a multi-row transaction (money, inventory, bookings)], [SQL],
  [the same entity is read by many different filters (status, owner, date, tag)], [SQL],
  [you have real joins across 3+ entities on the read path], [SQL],
  [under \~10 TB and under \~10,000 write TPS], [SQL --- it will cope, do not over-engineer],
  [one access pattern only, always by a known key], [key--value / wide-column],
  [writes are enormous and each row is independent (events, metrics, logs)], [LSM wide-column],
  [the document is always read whole and never joined], [document store],
  [the query is "find text like..." or "rank by relevance"], [search index, alongside SQL],
  [the query is "friends of friends of friends"], [graph store, alongside SQL],
)

*The default answer is SQL.* Start there, and move a specific table out only when you can
say which query SQL cannot serve at your scale. "We used Mongo because it is web-scale" is
the worst answer in this chapter.
]

#trap[
NoSQL is not "schemaless". The schema still exists --- it has just moved out of the
database and into every piece of code that reads the data. In SQL, one `ALTER TABLE` fixes
a bad field. In a document store, you now have four years of documents in six different
shapes, and every reader must handle all six. Always say this sentence; it shows you have
maintained something, not just started something.
]

#subsection[ACID, in one line each, with the failure it prevents]

#table(columns: (auto, 1fr, 1fr),
  [*Letter*], [*Promise*], [*What breaks without it*],
  [*A* --- atomic], [all the statements land, or none do],
    [money leaves account A, the crash happens, it never arrives at B],
  [*C* --- consistent], [the database's own rules always hold after a commit],
    [an order row points at a customer id that does not exist],
  [*I* --- isolated], [concurrent transactions do not see each other's half-done work],
    [two buyers both read "1 left" and both buy it],
  [*D* --- durable], [once you got "committed", a power cut cannot take it back],
    [the write was in RAM only; the server reboots; the order is gone],
)

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
A helpdesk app says: "A customer of a company raises a ticket. Agents reply with messages.
A ticket has a status and one assigned agent." Turn it into tables and pick each key.
#sol[
Underline the nouns: *customer, company, ticket, agent, message, status*.

Now ask of each noun: *does it have a life of its own?*

- *company* --- yes, it exists before any ticket. Table. Key: `company_id`.
- *customer* --- yes. Table. Key: `customer_id`. It belongs to a company, so it carries
  `company_id`.
- *agent* --- yes. Table. Key: `agent_id`, carries `company_id`.
- *ticket* --- yes. Table. Key: `ticket_id`, carries `company_id`, `customer_id`,
  `assignee_agent_id`.
- *message* --- yes, many per ticket. Table. Key: `message_id`, carries `ticket_id`.
- *status* --- no. It is one of a fixed small set of labels with no life of its own.
  It is a *column* on `ticket`, not a table.

The test for "table or column": if the thing can exist when nothing points at it, it is a
table. "Open" cannot exist on its own. Company can.
]
#ans[5 tables (company, customer, agent, ticket, message); status is a column]
]

#ex(2, tier: 0)[
This table breaks first normal form. Say how, and fix it.

```
tickets(ticket_id, subject, tags)
  1001, "card declined", "billing,urgent,vip"
```
#sol[
*The break.* The `tags` column holds a *list* squeezed into one string. First normal form
says every cell holds one single value.

*Why it hurts, concretely.* "Find all urgent tickets" becomes
`WHERE tags LIKE '%urgent%'`. That cannot use a normal index, so it is a full scan. It
also matches the tag `not-urgent`. And deleting the tag `vip` from 40,000 tickets means
string surgery on every row.

*The fix:* a second table, one row per (ticket, tag) pair.

```
tickets(ticket_id, subject)
ticket_tags(ticket_id, tag)        PRIMARY KEY (ticket_id, tag)
  1001, "billing"
  1001, "urgent"
  1001, "vip"
```

Now "all urgent tickets" is an index seek on `ticket_tags(tag)`, and removing a tag is one
`DELETE`.
]
#ans[A list in one cell. Split into a child table with key (ticket\_id, tag).]
]

#ex(3, tier: 0)[
Take this table to third normal form, showing each step.

```
order_lines(order_id, line_no, product_id, product_name,
            product_category, qty, unit_paise, customer_city)
PRIMARY KEY (order_id, line_no)
```
#sol[
*Step 1 --- is it in 1NF?* Yes. Every cell holds one value.

*Step 2 --- 2NF: no non-key column may depend on only PART of the key.*
The key is `(order_id, line_no)`.
- `customer_city` depends on `order_id` alone. It does not care which line. *Violation.*
- `product_name`, `product_category` depend on `product_id`, which is not part of the key
  at all. Hold that thought for step 3.
- `qty`, `unit_paise` depend on the whole key. Fine.

Move `customer_city` up to the order:

```
orders(order_id, customer_id, customer_city, placed_at)
order_lines(order_id, line_no, product_id, product_name,
            product_category, qty, unit_paise)
```

*Step 3 --- 3NF: no non-key column may depend on another non-key column.*
In `order_lines`, `product_category` depends on `product_name`, which depends on
`product_id`. That is a chain through non-key columns. *Violation.*
And in `orders`, `customer_city` depends on `customer_id`. *Violation.*

```
products(product_id, product_name, product_category)
customers(customer_id, customer_city)
orders(order_id, customer_id, placed_at)
order_lines(order_id, line_no, product_id, qty, unit_paise)
```

*Now the interview follow-up you must pre-empt.* "Wait --- if the customer moves city, the
old order now shows the new city. Is that right?"

No. For an order, the shipping city is *historical fact*, not a lookup. So you deliberately
de-normalise it back:

```
orders(order_id, customer_id, ship_city, ship_pincode, placed_at)
```

and the same for the price: `order_lines.unit_paise` stays a copy, because the price on
the day of the order must never change when the catalog price changes.

*The rule:* normalise by default; copy a value only when it is a *snapshot of a fact at a
moment*, and say that out loud.
]
#ans[Split to products/customers/orders/order\_lines, then copy back ship\_city and unit\_paise as historical snapshots.]
]

#ex(4, tier: 0)[
A table has 100,000 rows. Column `status` has 3 possible values, roughly equal. Column
`tenant_id` has 500 possible values, roughly equal. Which column deserves an index?
Show the arithmetic.
#sol[
*Selectivity* = the fraction of the table one value picks out. Lower is better.

$ "selectivity"("status") = 1/3 = 0.333 = 33.3% arrow.r "33,300" "rows" $
$ "selectivity"("tenant_id") = 1/500 = 0.002 = 0.2% arrow.r 200 "rows" $

Now the cost. An index lookup that matches 33,300 rows must do 33,300 heap fetches, each
possibly a separate page. A full scan of 100,000 rows reads maybe 1,700 pages
(60 rows per 8 KB page). *The index is slower than the scan.* The planner knows this and
will ignore your index.

200 rows is 200 heap fetches. That is far cheaper than 1,700 page reads. The index wins.

*Rule of thumb:* an index pays off below roughly 5--10% selectivity. Above that, the
planner scans.
]
#ans[`tenant_id` (0.2%). An index on `status` alone (33%) will not be used.]
]

#ex(5, tier: 0)[
You have one index: `(tenant_id, status)`, in that order. Which of these four queries can
use it?

```
A  WHERE tenant_id = 7
B  WHERE tenant_id = 7 AND status = 'open'
C  WHERE status = 'open'
D  WHERE status = 'open' AND tenant_id = 7
```
#sol[
An index is a *sorted list of concatenated keys*. Sorted by `tenant_id` first, then by
`status` inside each `tenant_id`. Think of a phone book sorted by surname, then first name.

- *A* --- yes. `tenant_id` is the first column. This is "all the Sharmas".
- *B* --- yes. Both columns, in order. "Sharma, Anil". One seek.
- *C* --- *no*. You know the first name but not the surname. Every Anil is scattered across
  the whole book. Full scan.
- *D* --- *yes*. The order you type the conditions in does not matter at all. The planner
  reorders them. `D` is the same query as `B`.

The rule has a name: the *left-prefix rule*. An index on $(a, b, c)$ serves $a$, $(a,b)$,
and $(a,b,c)$ --- never $b$ alone, never $c$ alone.
]
#ans[A, B and D use it. C cannot. Query order does not matter; index column order does.]
]

#ex(6, tier: 0)[
The query is `SELECT status, subject FROM tickets WHERE tenant_id = 7`, matching 200 rows.
The index is `(tenant_id)`. How many reads? Now change the index to
`(tenant_id) INCLUDE (status, subject)`. How many reads now?
#sol[
*With the plain index.*
- walk down the tree: 3 page reads,
- read the matching index leaves: say 2 pages (200 small entries fit easily),
- then *one heap fetch per row* to get `status` and `subject`: up to 200 page reads.

$ 3 + 2 + 200 = 205 "page reads" $

*With the covering index.* The index leaf now carries `status` and `subject` itself. The
query never needs the table.

$ 3 + 2 + 0 = 5 "page reads" $

$ 205 / 5 = 41 times "fewer reads" $

This is called an *index-only scan*. The cost: the index is fatter, so writes are slower
and the index takes more RAM.
]
#ans[205 reads becomes 5 reads --- 41x fewer. That is what "covering index" buys.]
]

#ex(7, tier: 0)[
A table has 80 million rows. Pages are 8 KB and hold about 500 index entries. How many
page reads does a primary-key lookup need? How many does a full scan need if a heap page
holds 50 rows?
#sol[
*Index height.* Find the smallest $h$ with $500^h >= "80,000,000"$.

$ 500^1 = 500 $
$ 500^2 = "250,000" $
$ 500^3 = "125,000,000" >= "80,000,000" checkmark $

So $h = 3$: three index pages, plus one heap page for the row.

$ "index lookup" = 3 + 1 = 4 "page reads" $

*Full scan.*
$ "80,000,000" / 50 = "1,600,000" "heap pages" $

$ "1,600,000" / 4 = "400,000" times "more work" $

At 0.1 ms per random read that scan is $"1,600,000" times 0.0001 = 160$ seconds; even at
1 GB/s sequential it is $"1,600,000" times 8192 \/ 10^9 = 13.1$ seconds. The index does it
in under a millisecond.
]
#ans[4 page reads by index; 1,600,000 pages for a scan --- 400,000x more.]
]

#ex(8, tier: 0)[
Name the anomaly in each trace.

```
Trace 1: T1 writes qty=5 (not committed). T2 reads qty=5. T1 rolls back.
Trace 2: T1 reads qty=5. T2 writes qty=3 and commits. T1 reads qty=3.
Trace 3: T1 counts rows WHERE status='open' -> 40. T2 inserts a new open
         ticket and commits. T1 counts again -> 41.
Trace 4: T1 reads bal=100. T2 reads bal=100. T1 writes 90. T2 writes 80.
```
#sol[
- *Trace 1 --- dirty read.* T2 saw a value that never existed. Only `READ UNCOMMITTED`
  allows this. Nobody runs that level on purpose.
- *Trace 2 --- non-repeatable read.* The same row, read twice in one transaction, gave two
  answers. Stopped by `REPEATABLE READ` (a snapshot).
- *Trace 3 --- phantom read.* Not a changed row --- a *new* row appearing inside a range
  T1 already looked at. Stopped by `SERIALIZABLE` (and, for locking reads, by MySQL's gap
  locks).
- *Trace 4 --- lost update.* T1's write of 90 is simply gone. This is the one that costs
  real money, and the most important thing to know is that *`REPEATABLE READ` does not
  always save you* --- you need an atomic update, a `SELECT ... FOR UPDATE`, or a version
  check.
]
#ans[dirty read; non-repeatable read; phantom; lost update]
]

#ex(9, tier: 0)[
Give the column type for: a price, a "created at" timestamp, a user id, a country code,
a "is deleted" flag. Say what goes wrong with the tempting wrong choice.
#sol[
#table(columns: (auto, auto, 1fr),
  [*Field*], [*Use*], [*Wrong choice and what it costs*],
  [price], [`BIGINT` in paise/cents], [`FLOAT`: $0.1 + 0.2 = 0.30000000000000004$. Money silently drifts. `DECIMAL(12,2)` is acceptable and exact; never `FLOAT`.],
  [created at], [`TIMESTAMPTZ`, stored UTC], [`TIMESTAMP` without zone: the same row means two different moments in Mumbai and Singapore. Bugs appear only in October.],
  [user id], [`BIGINT` or `UUID`/`ULID`], [`INT`: dies at 2,147,483,647 rows. That is not a hypothetical; it is a famous class of outage.],
  [country code], [`CHAR(2)`], [free text: "IN", "in", "India", "Bharat" all appear. Constrain it.],
  [is deleted], [`TIMESTAMPTZ deleted_at NULL`], [`BOOLEAN`: you lose *when*, and you cannot expire old soft-deletes.],
)
]
#ans[BIGINT paise, TIMESTAMPTZ, BIGINT/ULID, CHAR(2), nullable deleted\_at]
]

#ex(10, tier: 0)[
Your primary key is a random UUID (version 4). A colleague says "switch to auto-increment,
it is faster". Explain the mechanism, then decide.
#sol[
*Mechanism.* In a clustered index (MySQL/InnoDB) or any B-tree, rows are stored *in key
order*.

- With an *increasing* key, every new row goes at the right-hand end of the tree. The
  right-most page stays in RAM. One page is dirtied per insert.
- With a *random* key, each new row lands in a random page out of (say) 2 million pages.
  That page is probably not in RAM, so the insert costs a read *and* a write, and the page
  may have to *split* because it is already full.

Order-of-magnitude: a 100 GB table on a machine with 16 GB of RAM has about 16% of pages
cached. Random inserts miss the cache 84% of the time. Sequential inserts miss \~0%.

*But auto-increment has two real costs:*
+ ids are guessable --- `/orders/1002` tells a stranger you have about a thousand orders,
  and lets them try `/orders/1001`,
+ you cannot generate an id on the client or in a second data centre without coordination.

*Decision:* use a *time-sorted* id --- ULID, UUIDv7, or Snowflake. The first 48 bits are a
millisecond timestamp, so inserts stay at the right-hand end like auto-increment, and the
random tail keeps them unguessable and generatable anywhere. If you must choose only
between the two the colleague offered: keep auto-increment as the internal key and expose
a random public id in the API.
]
#ans[Random UUID causes page splits and cache misses. Use ULID/UUIDv7 --- sorted like an integer, unguessable like a UUID.]
]

#ex(11, tier: 0)[
`tickets` has 3 million rows. 120,000 are `status='open'`. The only hot query is
`WHERE tenant_id = ? AND status = 'open' ORDER BY created_at DESC LIMIT 20`.
Design one index for it and say why each column is where it is.
#sol[
Build the index in three parts, in this order:

+ *Equality columns first, most selective first.* `tenant_id` (0.2% selective) and
  `status`. Both are equality tests, so both can sit at the front.
+ *Then the `ORDER BY` column.* `created_at DESC`. If it is in the index in the right
  direction, the database reads 20 entries and stops --- no sort at all.
+ *Then, optionally, the columns the query returns*, to make it covering.

```sql
CREATE INDEX ix_tickets_hot
  ON tickets (tenant_id, status, created_at DESC)
  INCLUDE (subject, assignee_agent_id);
```

Better still, since only 4% of rows are open, make it a *partial index*:

```sql
CREATE INDEX ix_tickets_open
  ON tickets (tenant_id, created_at DESC)
  INCLUDE (subject, assignee_agent_id)
  WHERE status = 'open';
```

Size: $"120,000"$ entries instead of $"3,000,000"$ --- 25x smaller, so it stays in RAM,
and every non-open write does not touch it at all.
]
#ans[`(tenant_id, status, created_at DESC)`; better, a partial index `WHERE status='open'`, 25x smaller.]
]

#section[Tier 1 · LLD: model it, then index it]
#tier-header(1)

This is the low-level design version of a database question. You are given a paragraph of
English, a whiteboard, and 25 minutes. Six moves, same as any LLD.

#formulas(title: "The six moves for a schema question")[
+ *Nouns to tables.* A noun is a table if it can exist alone.
+ *Pick each key.* Stable, unique, never re-used, never guessable in public.
+ *Draw the relationships* with their cardinality (1:1, 1:N, N:M). Every N:M is a table.
+ *Write the DDL* --- types, `NOT NULL`, foreign keys, unique constraints.
+ *Write the five queries the product needs*, and one index for each.
+ *Say the concurrency story*: which two writes can collide, and how you stop them.
]

#subsection[The worked model: a small library]

The English: "Members borrow copies of books. A book has many physical copies. A member
may hold at most 4 copies at once. A copy is on loan to at most one member. Late returns
are fined by the day."

*Move 1 and 2 --- nouns and keys.*

#table(columns: (auto, auto, 1fr),
  [*Noun*], [*Table?*], [*Key and why*],
  [book], [yes], [`book_id`. Not the ISBN --- old books have none, and ISBNs get re-used across editions.],
  [copy], [yes], [`copy_id`. A copy is a physical object with its own damage and location.],
  [member], [yes], [`member_id`. Not the phone number --- people change phones and share them.],
  [loan], [yes], [`loan_id`. A loan is an *event*, not a link: it has a start, an end and a fine.],
  [fine], [no], [computed from the loan's dates and a rate. Store the *amount charged* on the loan, not a separate table.],
  [librarian], [no], [out of scope; say so out loud.],
)

#trick[
*The "event vs link" test.* If a join table has only two foreign keys, it is a *link* and
can stay a join table. The moment it grows a date, a state, or a price, it is an *event*
and deserves its own id. `loan` has `issued_at`, `due_at`, `returned_at`, `fine_paise` ---
it is an event. Name it with a noun, never `member_copy`.
]

*Move 3 --- the picture.*

#diagram(height: 5.6cm, caption: "Library schema. The arrow head is the 'many' end. The loan table is an event, not a link.")[
  #dnode(0.2cm, 0.2cm, 4.4cm, 1.5cm, "books\nbook_id (PK)\ntitle, author, published_year")
  #dnode(6.0cm, 0.2cm, 4.4cm, 1.5cm, "copies\ncopy_id (PK)\nbook_id (FK), barcode UNIQUE,\ncondition")
  #dnode(11.8cm, 1.5cm, 4.6cm, 1.9cm, "loans\nloan_id (PK)\ncopy_id (FK), member_id (FK)\nissued_at, due_at,\nreturned_at NULL, fine_paise", fill: rgb("#dce9f2"))
  #dnode(0.2cm, 3.3cm, 4.4cm, 1.5cm, "members\nmember_id (PK)\nname, email UNIQUE, joined_at")

  #darrow(4.65cm, 0.95cm, 5.95cm, 0.95cm, label: "1 : N")
  #darrow(10.45cm, 0.95cm, 11.75cm, 1.9cm, label: "1 : N")
  #darrow(4.65cm, 3.9cm, 11.75cm, 3.1cm, label: "1 : N")

  #place(dx: 5.4cm, dy: 4.3cm)[#text(size: 7.5pt, fill: muted)[partial unique index on `loans(copy_id) WHERE returned_at IS NULL`\ = at most one open loan per copy, enforced by the database]]
]

*Move 4 --- the DDL.* This is what you write on the board. Types and constraints, no prose.

#code(lang: "sql", caption: "library.sql — the constraints do half the work")[
```sql
CREATE TABLE books (
  book_id        BIGINT PRIMARY KEY,
  title          TEXT        NOT NULL,
  author         TEXT        NOT NULL,
  published_year SMALLINT
);

CREATE TABLE copies (
  copy_id   BIGINT PRIMARY KEY,
  book_id   BIGINT NOT NULL REFERENCES books(book_id),
  barcode   TEXT   NOT NULL UNIQUE,
  condition TEXT   NOT NULL DEFAULT 'good'
);

CREATE TABLE members (
  member_id BIGINT PRIMARY KEY,
  name      TEXT        NOT NULL,
  email     TEXT        NOT NULL UNIQUE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE loans (
  loan_id     BIGINT PRIMARY KEY,
  copy_id     BIGINT      NOT NULL REFERENCES copies(copy_id),
  member_id   BIGINT      NOT NULL REFERENCES members(member_id),
  issued_at   TIMESTAMPTZ NOT NULL,
  due_at      TIMESTAMPTZ NOT NULL,
  returned_at TIMESTAMPTZ,                       -- NULL means "still out"
  fine_paise  BIGINT      NOT NULL DEFAULT 0,
  CHECK (due_at > issued_at),
  CHECK (returned_at IS NULL OR returned_at >= issued_at)
);

-- THE rule of the whole system, enforced by the database, not by code:
-- a copy can have at most one loan that has not been returned.
CREATE UNIQUE INDEX ux_one_open_loan_per_copy
  ON loans (copy_id) WHERE returned_at IS NULL;
```
]

#trick[
That last index is the single highest-scoring line in a library LLD. It makes
double-lending *impossible at the storage layer*. No amount of racing application code can
get past it: the second `INSERT` fails with a unique-violation and the API returns 409.

The general move: *turn your most important business rule into a constraint.* If you can
only remember one thing from this chapter, remember that sentence.
]

*Move 5 --- the queries and their indexes.*

#table(columns: (1fr, 1fr),
  [*The query the product needs*], [*The index that serves it*],
  [what does member 42 currently hold?], [`(member_id) WHERE returned_at IS NULL`],
  [is copy 991 available?], [`ux_one_open_loan_per_copy` --- already there],
  [which loans are overdue today?], [`(due_at) WHERE returned_at IS NULL`],
  [loan history of a member, newest first], [`(member_id, issued_at DESC)`],
  [how many copies of book 7 are free?], [`copies(book_id)` + the open-loan index],
)

#note[
The "4 books at a time" rule is *not* a constraint you can write in standard SQL on this
shape. Options: (a) check inside the same transaction with
`SELECT count(*) ... FOR UPDATE` on the member row, (b) keep a `held_count` column on
`members` and add a `CHECK (held_count <= 4)` updated in the same transaction. Option (b)
is better: it is $O(1)$, and the database enforces the limit even if a new code path
forgets to check. Decide out loud, and say which you chose.
]

#subsection[Move 6 --- prove the index actually does something]

Here is a runnable model of a table with one composite index. It counts *comparisons*, so
you can see the gap rather than believe it.

#code(lang: "js", caption: "mini-index.js — a table, a composite index, and a comparison counter")[
```js
class Table {
  constructor(name, rows = []) { this.name = name; this.rows = rows;
                                 this.indexes = new Map(); }
  insert(row) {
    const rid = this.rows.length; this.rows.push(row);
    for (const ix of this.indexes.values()) ix.add(row, rid);
    return rid;
  }
  scan(pred) {                       // full table scan: look at every row
    let cmp = 0; const out = [];
    for (const r of this.rows) { cmp++; if (pred(r)) out.push(r); }
    return { out, cmp };
  }
}

// a sorted composite index: [key..., rid] kept sorted, binary-searched
class SortedIndex {
  constructor(cols) { this.cols = cols; this.entries = []; }
  key(row) { return this.cols.map(c => row[c]); }
  static cmp(a, b) {
    for (let i = 0; i < Math.min(a.length, b.length); i++) {
      if (a[i] < b[i]) return -1;
      if (a[i] > b[i]) return 1;
    }
    return 0;                        // a shorter key that matches is a PREFIX
  }
  add(row, rid) {
    const e = { k: this.key(row), rid };
    let lo = 0, hi = this.entries.length;
    while (lo < hi) { const m = (lo + hi) >> 1;
      if (SortedIndex.cmp(this.entries[m].k, e.k) < 0) lo = m + 1; else hi = m; }
    this.entries.splice(lo, 0, e);
  }
  lookup(prefix) {  // every entry whose leading columns equal prefix
    let cmp = 0;
    const cmpTo = (e) => SortedIndex.cmp(e.k, prefix);
    let lo = 0, hi = this.entries.length;
    while (lo < hi) {
      const m = (lo + hi) >> 1; cmp++;
      if (cmpTo(this.entries[m]) < 0) lo = m + 1; else hi = m;
    }
    const rids = [];
    const n = this.entries.length;
    for (let i = lo; i < n && cmpTo(this.entries[i]) === 0; i++) {
      cmp++; rids.push(this.entries[i].rid);
    }
    return { rids, cmp };
  }
}
```
]

#code(lang: "js", caption: "mini-index.js — 100,000 rows, then the same query two ways")[
```js
const t = new Table("tickets");
const ix = new SortedIndex(["tenantId", "status"]);
t.indexes.set("ix_tenant_status", ix);

const STATUS = ["open", "pending", "solved"];
let seed = 42;  // a fixed seed: same output every run
const rnd = () => (seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648;

for (let i = 0; i < 100000; i++) {
  t.insert({ id: i, tenantId: 1 + Math.floor(rnd() * 500),
             status: STATUS[Math.floor(rnd() * 3)], subject: "t" + i });
}

const a = t.scan(r => r.tenantId === 7 && r.status === "open");
const b = ix.lookup([7, "open"]);
console.log("rows in table          :", t.rows.length);
console.log("scan  -> matched", a.out.length, "rows,", a.cmp, "comparisons");
console.log("index -> matched", b.rids.length, "rows,", b.cmp, "comparisons");
console.log("speed-up  :", (a.cmp / b.cmp).toFixed(1) + "x fewer comparisons");

const canServe = (ix, cols) =>
  cols.length <= ix.cols.length && cols.every((c, i) => c === ix.cols[i]);
console.log("\nWhich queries can ix(tenantId, status) serve?");
const QUERIES = [["tenantId"], ["tenantId", "status"],
                 ["status"], ["status", "tenantId"]];
for (const cols of QUERIES) {
  const ok = canServe(ix, cols);
  console.log("WHERE " + cols.join(" AND ").padEnd(22),
    ok ? "-> INDEX" : "-> FULL SCAN, the index cannot help");
}

const pct = (f) => (t.rows.filter(f).length / t.rows.length * 100);
console.log("\nselectivity of status='open' :",
            pct(r => r.status === "open").toFixed(1) + "%  (bad index on its own)");
console.log("selectivity of tenantId=7    :",
            pct(r => r.tenantId === 7).toFixed(2) + "%  (good)");
```
]

#code(lang: "text", caption: "$ node mini-index.js  — real output")[
```text
rows in table          : 100000
scan  -> matched 80 rows, 100000 comparisons
index -> matched 80 rows, 97 comparisons
speed-up  : 1030.9x fewer comparisons

Which queries can ix(tenantId, status) serve?
WHERE tenantId               -> INDEX
WHERE tenantId AND status    -> INDEX
WHERE status                 -> FULL SCAN, the index cannot help
WHERE status AND tenantId    -> FULL SCAN, the index cannot help

selectivity of status='open' : 34.0%  (bad index on its own)
selectivity of tenantId=7    : 0.25%  (good)
```
]

#complexity(time: "scan $O(n)$; index lookup $O(log n + k)$ for $k$ matches",
  space: "index $O(n)$ entries, roughly 10--20% of the table size per index",
  note: "97 comparisons for 100,000 rows is $log_2(100000) approx 17$ for the seek plus 80 for the matches.")

#trap[
*The JavaScript trap hiding in this code.* `SortedIndex.cmp` compares with `<` and `>`.
If one key is a number and the other is a string, JavaScript gives you *neither* less nor
greater --- `1 < "open"` is `false` and `1 > "open"` is also `false` --- so the comparator
silently reports "equal" and your index returns garbage. A real database has typed columns
and refuses the mismatch. In JS you must check the types yourself, or keep every index
column the same type. The same family of bug: `[10, 9, 1].sort()` gives `[1, 10, 9]`
because the default sort is *lexicographic*.
]

#ex(12, tier: 1, asked: "TCS NQT · pattern")[
The library adds a rule: "A member may not borrow two copies of the *same book* at once."
Add it to the schema. Do not add application code.
#sol[
The rule is about `(member_id, book_id)`, but `loans` does not have `book_id` --- it has
`copy_id`. Two ways:

*Option A --- join at check time.* Inside the borrow transaction, run
`SELECT 1 FROM loans l JOIN copies c USING (copy_id) WHERE l.member_id=? AND c.book_id=? AND l.returned_at IS NULL`.
Cost: a join on every borrow, and a race window between the `SELECT` and the `INSERT`
unless you also lock.

*Option B --- copy `book_id` onto `loans` and constrain it.*

```sql
ALTER TABLE loans ADD COLUMN book_id BIGINT NOT NULL REFERENCES books(book_id);
CREATE UNIQUE INDEX ux_one_copy_per_book_per_member
  ON loans (member_id, book_id) WHERE returned_at IS NULL;
```

*Decision: B.* The cost is one de-normalised column, and the risk is that `loans.book_id`
could disagree with `copies.book_id`. Both are cheap to control: `book_id` is written once
at insert and never updated, and a nightly check can assert agreement. The benefit is that
the rule is now impossible to break --- no race, no forgotten code path, one index entry
instead of a join.

This is the same pattern as `ux_one_open_loan_per_copy`. *De-normalise the column you need
in order to write the constraint.*
]
#ans[Copy `book_id` onto `loans`, then a partial unique index on `(member_id, book_id) WHERE returned_at IS NULL`.]
]

#ex(13, tier: 1, asked: "Infosys · pattern")[
The librarian wants "the 10 most borrowed books this month". Write the query, then say
what you would do when it becomes slow.
#sol[
*The query.*

```sql
SELECT c.book_id, count(*) AS borrows
FROM loans l
JOIN copies c ON c.copy_id = l.copy_id
WHERE l.issued_at >= date_trunc('month', now())
GROUP BY c.book_id
ORDER BY borrows DESC
LIMIT 10;
```

*Why it gets slow.* `count(*)` with `GROUP BY` must touch *every* loan in the month. There
is no index that can skip rows: the answer depends on all of them. At 200 loans a day and
one branch, that is 6,000 rows --- fine. At 50,000 loans a day across 300 branches it is
1.5 million rows per month, and the query does a sort on top.

*Three fixes, cheapest first.*
+ *Index the filter:* `CREATE INDEX ON loans (issued_at) INCLUDE (copy_id)` turns the scan
  into a range read of only this month's rows. Do this first; it may be enough forever.
+ *Roll up on write:* a table `book_month_counts(book_id, month, borrows)` incremented by
  one `UPDATE` inside the borrow transaction. The report becomes an index read of 10 rows.
  Cost: one extra write per borrow, and a hot row per popular book.
+ *Materialised view refreshed nightly.* The report is a *yesterday* report anyway.

*Decision:* start with (1). Move to (3) when the report takes over a second, because a
nightly refresh costs nothing on the write path. Only go to (2) if the product genuinely
needs live counts, and then expect the hot-row contention from Example 15.
]
#ans[Index `(issued_at) INCLUDE (copy_id)` first; then a nightly materialised view. Live counters only if the product truly needs live.]
]

#section[Tier 1 · LLD: transactions and the lost update]
#tier-header(1)

Every LLD round ends with the same question in some costume: *"two users do this at the
same moment --- what happens?"* Here is the whole answer, once, so you can reuse it for
seats, stock, wallets and likes.

#subsection[The four isolation levels, and what each one still allows]

#table(columns: (auto, auto, auto, auto, auto),
  [*Level*], [*Dirty read*], [*Non-repeatable*], [*Phantom*], [*Lost update*],
  [READ UNCOMMITTED], [possible], [possible], [possible], [possible],
  [READ COMMITTED], [no], [possible], [possible], [possible],
  [REPEATABLE READ], [no], [no], [no (snapshot)], [*still possible*],
  [SERIALIZABLE], [no], [no], [no], [no],
)

#note[
Two facts that make you sound experienced.
*One:* the default in PostgreSQL and in Oracle is `READ COMMITTED`; in MySQL/InnoDB it is
`REPEATABLE READ`. So the level your code runs at is probably not the one you assumed.
*Two:* `REPEATABLE READ` in PostgreSQL is *snapshot isolation*. It stops phantoms in your
reads, but it still allows *write skew*: two transactions each read the same snapshot,
each check a rule, each write a different row, and together they break the rule that
neither broke alone. Only `SERIALIZABLE` stops that.
]

#subsection[The lost update, measured three ways]

#code(lang: "js", caption: "lost-update.js — a store with three different write methods")[
```js
class Row {
  constructor(id, qty) { this.id = id; this.qty = qty; this.version = 1; }
}

class Store {
  constructor() { this.rows = new Map(); this.conflicts = 0; }
  put(r) { this.rows.set(r.id, r); }
  read(id) { return { ...this.rows.get(id) }; }   // a COPY = a snapshot

  writeBlind(id, qty) { this.rows.get(id).qty = qty; }         // the bug

  // UPDATE t SET qty=?, version=version+1 WHERE id=? AND version=?
  writeIfVersion(id, qty, version) {
    const r = this.rows.get(id);
    if (r.version !== version) { this.conflicts++; return false; }
    r.qty = qty; r.version++; return true;
  }

  // UPDATE t SET qty = qty-1 WHERE id=? AND qty>0   <- one atomic statement
  decrementIfPositive(id) {
    const r = this.rows.get(id);
    if (r.qty <= 0) return false;
    r.qty--; r.version++; return true;
  }
}
```
]

#code(lang: "js", caption: "lost-update.js — the same 200 buyers, three times")[
```js
// 1. read-modify-write. Worst case: everybody reads, then everybody writes.
function lostUpdate(n) {
  const s = new Store(); s.put(new Row("sku1", 200));
  const snapshots = [];
  for (let i = 0; i < n; i++) snapshots.push(s.read("sku1"));
  for (const snap of snapshots) s.writeBlind("sku1", snap.qty - 1);
  return s.rows.get("sku1").qty;
}

// 2. optimistic concurrency control: version check, retry on conflict
function optimistic(n) {
  const s = new Store(); s.put(new Row("sku1", 200));
  let pending = n, rounds = 0, retries = 0;
  while (pending > 0) {  // one round = all pending read, then all write
    rounds++;
    const snaps = [];
    for (let i = 0; i < pending; i++) snaps.push(s.read("sku1"));
    let won = 0;
    for (const snap of snaps) {
      if (snap.qty <= 0) { pending--; continue; }
      if (s.writeIfVersion("sku1", snap.qty - 1, snap.version)) won++;
      else retries++;                    // stale version -> read again and retry
    }
    pending -= won;
  }
  return { qty: s.rows.get("sku1").qty, rounds, retries };
}

// 3. one atomic UPDATE. No read at all, so nothing to lose.
function atomicUpdate(n) {
  const s = new Store(); s.put(new Row("sku1", 200));
  let sold = 0;
  for (let i = 0; i < n; i++) if (s.decrementIfPositive("sku1")) sold++;
  return { qty: s.rows.get("sku1").qty, sold };
}

console.log("start qty = 200, 200 buyers each buying 1");
console.log("1. read-modify-write :", "qty =", lostUpdate(200));
console.log("2. optimistic + retry:", optimistic(200));
console.log("3. atomic UPDATE     :", atomicUpdate(200));
console.log("4. oversell test, 250 buyers on 200 stock:", atomicUpdate(250));
```
]

#code(lang: "text", caption: "$ node lost-update.js  — real output")[
```text
start qty = 200, 200 buyers each buying 1
1. read-modify-write : qty = 199
2. optimistic + retry: { qty: 0, rounds: 200, retries: 19900 }
3. atomic UPDATE     : { qty: 0, sold: 200 }
4. oversell test, 250 buyers on 200 stock: { qty: 0, sold: 200 }
```
]

Read the four lines carefully; each one is a whole answer.

+ *Line 1 is the disaster.* 200 units were sold and the counter went from 200 to 199. One
  unit was deducted. You have sold 199 units of stock you do not have.
+ *Line 2 is correct but expensive.* 19,900 retries. That is
  $199 + 198 + dots + 1 + 0 = (199 times 200) \/ 2 = "19,900"$ --- every buyer that loses a
  round has to read and try again. Optimistic locking is *correct under contention and
  terrible under contention*.
+ *Line 3 is correct and cheap.* Zero retries, because there is no read to invalidate.
+ *Line 4 proves the guard works.* 250 buyers, 200 stock, exactly 200 sold, never $-50$.

#formulas(title: "The four fixes, and when to use each")[
#table(columns: (auto, 1fr, 1fr),
  [*Fix*], [*SQL*], [*Use when*],
  [atomic update], [`UPDATE stock SET qty=qty-1 WHERE sku=? AND qty>0`],
    [the new value is a *function of the old one*. Always your first choice.],
  [pessimistic lock], [`SELECT ... FOR UPDATE` then update],
    [you must read several rows, think, then write. Holds a lock: keep the transaction short.],
  [optimistic (version)], [`UPDATE ... WHERE id=? AND version=?` + retry],
    [conflicts are *rare*. Great for user profiles, awful for one hot inventory row.],
  [unique constraint], [`CREATE UNIQUE INDEX ... WHERE active`],
    [the rule is "at most one of these may exist". The best fix of all, when it fits.],
)
]

#trap[
`UPDATE stock SET qty = qty - 1 WHERE sku = ?` *without* `AND qty > 0` looks atomic and is
atomic --- and still sells you into negative stock. Atomicity is not the same as
correctness. The guard is the `AND`.
]

#ex(14, tier: 1, asked: "Accenture · pattern")[
Two transactions transfer money between the same two accounts at the same time:
T1 moves Rs.100 from A to B, T2 moves Rs.50 from B to A. Both lock rows with
`SELECT ... FOR UPDATE`. What can go wrong, and what is the fix?
#sol[
*Trace it.*

#table(columns: (auto, 1fr, 1fr),
  [*t*], [*T1 (A #sym.arrow.r B)*], [*T2 (B #sym.arrow.r A)*],
  [1], [locks row A], [---],
  [2], [---], [locks row B],
  [3], [asks for row B --- *waits for T2*], [---],
  [4], [---], [asks for row A --- *waits for T1*],
)

Both wait forever. This is a *deadlock*. The database detects it (Postgres in about one
second) and kills one transaction with a deadlock error. So nothing is corrupted --- but
one user sees a failure, and under load a large share of transfers fail.

*The fix is one line:* always lock rows in a fixed global order.

```sql
SELECT * FROM accounts
 WHERE account_id IN (:from, :to)
 ORDER BY account_id          -- <= the whole fix
   FOR UPDATE;
```

Now both transactions ask for the lower id first. T2 waits at step 1 instead of
half-way through, and then completes. No deadlock is possible, because a cycle in the wait
graph needs two transactions holding locks in opposite order.

*Say this out loud:* "I sort the ids before locking, so the lock order is total and cycles
cannot form." It is a one-sentence answer that very few candidates give.
]
#ans[Deadlock. Fix: lock rows in a fixed order --- `ORDER BY account_id FOR UPDATE`.]
]

#ex(15, tier: 1, asked: "Cognizant · pattern")[
A flash sale has one SKU with 10,000 units. 5,000 buyers per second hit
`UPDATE stock SET qty=qty-1 WHERE sku='X' AND qty>0`. The row updates take 2 ms each while
holding a row lock. What throughput do you actually get, and what do you do?
#sol[
*The arithmetic.* One row, one lock. The updates on that row are *serial*.

$ "max throughput on one row" = 1 / 0.002 "s" = 500 "updates per second" $

Offered load is 5,000/s. So 4,500 requests a second queue up behind the lock. The queue
grows without bound and the whole database's connections are consumed waiting.

*The fix: split the hot row into buckets.* Keep 20 rows for the same SKU:

```sql
CREATE TABLE stock_bucket (
  sku VARCHAR(32), bucket SMALLINT, qty INT,
  PRIMARY KEY (sku, bucket)
);
-- 10,000 units spread as 500 per bucket, 20 buckets
```

Each buyer picks a bucket at random and decrements it:

```sql
UPDATE stock_bucket SET qty = qty - 1
 WHERE sku = 'X' AND bucket = :b AND qty > 0;
```

$ 20 "buckets" times 500 "updates/s" = "10,000" "updates per second" $

Now 5,000/s fits with 2x headroom.

*The cost you must name.* A buyer can be told "sold out" while another bucket still has
stock. Fix it by retrying 2 or 3 other buckets before giving up:
$ P("all 3 tried buckets empty while stock remains") $
is tiny until the sale is genuinely almost over. Also, "how much is left?" is now
`SELECT sum(qty)` across 20 rows instead of one read --- cheap.

*Decision:* bucket it. 20x throughput for the price of a 3-try retry loop and a `sum()`.
]
#ans[500/s on one row. Split into 20 buckets $arrow.r$ 10,000/s, with a 3-bucket retry on "empty".]
]

#ex(16, tier: 1, asked: "Wipro · pattern")[
Explain write skew with a concrete example, and say which fix works.
#sol[
*The rule:* "at least one doctor must be on call at all times."

Right now Asha and Bikram are both on call. Both feel unwell and both click "go off call"
at the same instant, at `REPEATABLE READ` (snapshot isolation).

#table(columns: (auto, 1fr, 1fr),
  [*t*], [*T1 (Asha)*], [*T2 (Bikram)*],
  [1], [counts on-call doctors #sym.arrow.r 2. OK to leave.], [---],
  [2], [---], [counts on-call doctors #sym.arrow.r 2. OK to leave.],
  [3], [sets Asha.on\_call = false], [---],
  [4], [---], [sets Bikram.on\_call = false],
  [5], [commit], [commit],
)

Nobody is on call. Neither transaction broke the rule *on the rows it wrote*, so no lock
and no version check catches it. They wrote *different rows*. That is write skew.

*Which fixes work?*
- Optimistic version check on the row you write: *no*. Each row's version was untouched.
- `SELECT ... FOR UPDATE` on the rows you *read*: *yes*, if you lock the whole on-call set
  (`SELECT ... WHERE on_call FOR UPDATE`). T2 then waits and re-reads 1, not 2.
- `SERIALIZABLE`: *yes*. Postgres SSI detects the read--write dependency cycle and aborts
  one transaction; you retry it.
- A constraint: *yes, and best.* Keep a counter row `oncall_count` with
  `CHECK (n >= 1)` and `UPDATE oncall_count SET n = n - 1`. Now the rule lives in one row,
  and one row cannot have write skew with itself.

*Decision:* materialise the invariant into a single row and constrain it. Fall back to
`SERIALIZABLE` + retry when the invariant is too complex to materialise.
]
#ans[Two transactions, different rows, one broken rule. Fix: lock the read set, or `SERIALIZABLE`, or best, materialise the invariant into one constrained row.]
]

#section[Tier 2 · Mid-scale: the database for a helpdesk SaaS]
#tier-header(2)

#ex(17, tier: 2, asked: "Agoda · pattern")[
Design the data layer for a multi-tenant helpdesk product. Companies sign up; their
customers raise tickets; their agents reply. Walk all seven steps.
]

#sol[
#subsection[Step 1 --- Clarify]

#table(columns: (1fr, 1fr),
  [*Question I ask*], [*Why the answer changes the design*],
  [How many tenants, and how skewed are they?],
    [500 equal tenants is one schema. 20,000 tenants where the top one is 30% of all data means I need per-tenant limits and possibly a separate shard for the whales.],
  [Must one tenant's data be physically separate?],
    [If a contract says "separate database", the answer is a database per tenant and I lose cross-tenant reporting. If not, one schema with `tenant_id` everywhere is far cheaper.],
  [How long must tickets be kept?],
    [Forever means 10 TB a year and partitioning from day one. 18 months means the old partitions are simply dropped.],
  [Is full-text search on message bodies required?],
    [Yes means a search index next to the database, and a new consistency problem. No means the schema stays simple.],
  [Are attachments in scope?],
    [Yes means a blob store and signed URLs; the database only stores metadata. Never put a 300 KB file in a row.],
)

*My assumptions:* 20,000 tenants, one shared schema with `tenant_id` on every table;
tickets kept 24 months then archived; full-text search required; attachments go to object
storage.

#subsection[Step 2 --- Scale estimate]

*Writes: new tickets.* 20,000 tenants, average 150 new tickets per tenant per day.

$ "20,000" times 150 = "3,000,000" "tickets/day" $
$ "3,000,000" / "86,400" = 34.7 "ticket inserts per second" $
$ "peak" = 34.7 times 3 = 104 "per second" $

*Writes: messages.* Each ticket collects about 4 messages over its life.

$ "3,000,000" times 4 = "12,000,000" "messages/day" $
$ "12,000,000" / "86,400" = 138.9 "per second", "peak" 138.9 times 3 = 417 $

*Reads.* 200,000 agents are active daily and each loads about 250 pages.

$ "200,000" times 250 = "50,000,000" "page views/day" $
$ "50,000,000" / "86,400" = 578.7 "page views per second" $
$ "peak" = 578.7 times 3 = "1,736" "page views per second" $

Each page view costs about 3 database queries (the list, the ticket, the messages):

$ "1,736" times 3 = "5,208" "queries per second at peak" $

#note[
5,208 QPS is *right at the ceiling* of a single good SQL node (3,000--8,000 simple reads).
That single number decides the whole architecture: I need read replicas and a cache, and I
need them at launch, not later. This is exactly what Step 2 exists to tell you.
]

*Storage.* A ticket row with all its columns is about 800 bytes. A message row, body
included, averages 2,000 bytes.

$ "tickets" = "3,000,000" times 800 = "2,400,000,000" "bytes" = 2.4 "GB/day" $
$ "messages" = "12,000,000" times "2,000" = "24,000,000,000" "bytes" = 24 "GB/day" $
$ "total" = 2.4 + 24 = 26.4 "GB/day" $
$ "per year" = 26.4 times 365 = "9,636" "GB" = 9.64 "TB" $
$ "with indexes, " + 40%: 9.64 times 1.4 = 13.5 "TB/year" $

Two years retained is about 27 TB. That is too big for one comfortable node, so tickets
and messages get *time partitions* and old partitions get archived.

*Attachments.* 10% of tickets carry one 300 KB file.

$ "3,000,000" times 0.10 = "300,000" "files/day" $
$ "300,000" times "300,000" "bytes" = "90,000,000,000" = 90 "GB/day" $
$ 90 times 365 = "32,850" "GB" = 32.85 "TB/year" arrow.r "object storage, not the database" $

#subsection[Step 3 --- API surface]

#code(lang: "text", caption: "The five calls that generate 95% of the load")[
```text
GET  /v1/tickets?status=open&assignee=me&limit=25&cursor=<opaque>
  200 { tickets:[{id,subject,status,priority,requester,updatedAt}], nextCursor }
  note  tenant comes from the auth token, NEVER from a query parameter

GET  /v1/tickets/{id}
  200 { id, subject, status, priority, requester, assignee, tags[], createdAt }

GET  /v1/tickets/{id}/messages?limit=50&cursor=<opaque>
  200 { messages:[{id, authorId, authorKind, bodyHtml, createdAt, attachments[]}],
        nextCursor }

POST /v1/tickets
  body   { subject, bodyHtml, requesterEmail, priority }
  header Idempotency-Key: <uuid>      -- an email retry must not make two tickets
  201    { id }

PATCH /v1/tickets/{id}
  body   { status?, assigneeId?, priority?, expectedVersion }
  200    { id, version }      409 if expectedVersion is stale
```
]

#note[
Two details worth saying out loud. *One:* `tenant_id` never appears in a URL or a body. It
comes from the signed token. A tenant id the client can type is a data leak waiting for
somebody to type a different number. *Two:* `PATCH` carries `expectedVersion`. Two agents
editing one ticket is the most common collision in a helpdesk, and this turns a silent
overwrite into a visible 409.
]

#subsection[Step 4 --- Data model]

#code(lang: "sql", caption: "The core tables. Note tenant_id leading every primary key.")[
```sql
CREATE TABLE tickets (
  tenant_id   BIGINT      NOT NULL,
  ticket_id   BIGINT      NOT NULL,
  subject     TEXT        NOT NULL,
  status      SMALLINT    NOT NULL,  -- 0 new 1 open 2 pending 3 solved 4 closed
  priority    SMALLINT    NOT NULL,
  requester_id BIGINT     NOT NULL,
  assignee_id  BIGINT,                  -- NULL = unassigned
  version      INT        NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ NOT NULL,
  updated_at  TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (tenant_id, ticket_id)
) PARTITION BY RANGE (created_at);

CREATE TABLE messages (
  tenant_id   BIGINT      NOT NULL,
  ticket_id   BIGINT      NOT NULL,
  message_id  BIGINT      NOT NULL,
  author_id   BIGINT      NOT NULL,
  author_kind SMALLINT    NOT NULL,     -- 0 customer 1 agent 2 system
  body_html   TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (tenant_id, ticket_id, message_id)
) PARTITION BY RANGE (created_at);

CREATE TABLE attachments (
  tenant_id  BIGINT NOT NULL,
  message_id BIGINT NOT NULL,
  blob_key   TEXT   NOT NULL,           -- s3://bucket/t/9/2026/09/ab12...
  bytes      BIGINT NOT NULL,
  mime       TEXT   NOT NULL,
  PRIMARY KEY (tenant_id, message_id, blob_key)
);
```
]

*Three decisions to defend.*

*(a) `tenant_id` is the first column of every primary key.* It is not decoration. It means
(i) one tenant's rows are physically next to each other, so a tenant's queries touch few
pages; (ii) every index is automatically tenant-scoped; (iii) when you finally shard, the
shard key is already chosen and no code changes. *Decision: always lead with the tenant.*

*(b) Partition by `created_at`, monthly.* 26.4 GB a day is 800 GB a month. A 24-month
retention is 24 partitions. Dropping the oldest month is `DROP TABLE` --- instant --- versus
a `DELETE` of 800 GB that would run for hours and bloat the table. *Decision: range
partition on time, drop don't delete.*

*(c) `body_html` lives in the row, attachments do not.* A 2 KB text body in the row is
fine. A 300 KB file in the row would make every `SELECT *` drag megabytes through the
buffer pool and would multiply backup size by 4. *Decision: bytes to object storage, a
key in the row.*

*The indexes, one per hot query:*

#table(columns: (1fr, 1fr),
  [*Query*], [*Index*],
  [my open tickets, newest first],
    [`(tenant_id, assignee_id, updated_at DESC) WHERE status IN (0,1,2)`],
  [the tenant's queue, newest first],
    [`(tenant_id, updated_at DESC) WHERE status IN (0,1,2)`],
  [one ticket's messages in order],
    [primary key `(tenant_id, ticket_id, message_id)` --- already sorted],
  [a customer's tickets], [`(tenant_id, requester_id, created_at DESC)`],
  [search the body text], [not an index --- a separate search service, see the deep dive],
)

#trick[
Notice all three list indexes are *partial*: `WHERE status IN (0,1,2)`. Solved and closed
tickets are 90% of the table after a year and are almost never listed. Excluding them
makes the index roughly 10x smaller, so it stays in RAM. A partial index is the cheapest
big win in this whole chapter.
]

#subsection[Step 5 --- Architecture]

#diagram(height: 6.8cm, caption: "Helpdesk data layer. Solid = the request path. Dashed = what happens after the commit.")[
  #dnode(0.2cm, 0.1cm, 9.2cm, 0.9cm, "peak 5,208 queries/s · 13.5 TB/yr with indexes", fill: rgb("#fbf6ee"))

  #dnode(4.2cm, 1.1cm, 3.0cm, 0.9cm, "Redis: hot tickets", fill: rgb("#dce9f2"))

  #dnode(0.2cm, 2.3cm, 2.2cm, 1.0cm, "agent\nbrowser")
  #darrow(2.45cm, 2.8cm, 2.95cm, 2.8cm)
  #dnode(3.0cm, 2.3cm, 2.4cm, 1.0cm, "API service")
  #darrow(5.45cm, 2.8cm, 5.95cm, 2.8cm)
  #dnode(6.0cm, 2.3cm, 3.0cm, 1.0cm, "pgbouncer\n5,000 client conns\n-> 200 server conns", fill: rgb("#fbf6ee"))
  #darrow(4.6cm, 2.3cm, 5.0cm, 2.05cm, label: "hit")

  #dnode(10.0cm, 1.2cm, 5.4cm, 0.9cm, "replica 1 (reads)", fill: rgb("#dce9f2"))
  #dnode(10.0cm, 2.4cm, 5.4cm, 0.9cm, "replica 2 (reads)", fill: rgb("#dce9f2"))
  #dnode(10.0cm, 3.6cm, 5.4cm, 0.9cm, "PRIMARY (all writes)", fill: rgb("#f2dcdc"))
  #darrow(9.05cm, 2.6cm, 9.95cm, 1.65cm)
  #darrow(9.05cm, 2.8cm, 9.95cm, 2.85cm)
  #darrow(9.05cm, 3.0cm, 9.95cm, 4.05cm)
  #place(dx: 9.1cm, dy: 3.95cm)[#text(size: 7pt, fill: dc)[writes]]

  #darrow(15.9cm, 4.0cm, 15.9cm, 1.6cm, dashed: true)
  #darrow(15.9cm, 1.65cm, 15.45cm, 1.65cm, dashed: true)
  #darrow(15.9cm, 2.85cm, 15.45cm, 2.85cm, dashed: true)
  #place(dx: 10.6cm, dy: 4.72cm)[#text(size: 7.5pt, fill: muted)[dashed = replication, 20--200 ms behind]]

  #dnode(0.2cm, 5.4cm, 5.2cm, 1.0cm, "search index\nfed by CDC, 1--5 s behind", fill: rgb("#f0ece2"))
  #dnode(6.0cm, 5.4cm, 3.4cm, 1.0cm, "object store\n(attachments)", fill: rgb("#f0ece2"))
  #dnode(10.0cm, 5.4cm, 6.4cm, 1.0cm, "24 monthly partitions; DROP the oldest,\narchive it as Parquet", fill: rgb("#f0ece2"))
  #darrow(10.4cm, 4.5cm, 3.4cm, 5.35cm, dashed: true, label: "CDC")
  #darrow(12.9cm, 4.5cm, 12.9cm, 5.4cm)
  #darrow(3.7cm, 3.3cm, 6.9cm, 5.4cm, dashed: true, label: "upload")
]

#subsection[Step 6 --- Deep dive 1: tenant isolation without 20,000 databases]

Three ways to keep 20,000 companies apart. You will be asked to compare them.

#table(columns: (auto, 1fr, 1fr, 1fr),
  [], [*database per tenant*], [*schema per tenant*], [*shared tables + `tenant_id`*],
  [isolation], [strongest], [strong], [logical only],
  [connections], [20,000 pools --- impossible], [1 pool, 20,000 search paths], [1 pool],
  [migrations], [20,000 runs, days], [20,000 runs], [1 run],
  [cross-tenant report], [impossible], [painful], [one query],
  [noisy neighbour], [contained], [partly], [needs rate limits],
  [cost at 20,000], [absurd], [high], [low],
)

*Decision: shared tables with `tenant_id` leading every key.* At 20,000 tenants the other
two are not engineering choices, they are operations disasters --- 20,000 schema migrations
per release. The isolation you give up must then be bought back deliberately:

+ *`tenant_id` comes only from the signed token*, never from user input.
+ *Row-level security in the database as a second lock.* If application code forgets a
  `WHERE tenant_id = ?`, the database adds it.

```sql
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON tickets
  USING (tenant_id = current_setting('app.tenant_id')::BIGINT);
```

+ *Per-tenant rate limits* so one tenant's runaway integration cannot eat the pool.
+ *The escape hatch:* the top 10 tenants by volume can be moved to their own database
  later, because `tenant_id` is already the leading key. Say this --- it shows you planned
  the exit.

#subsection[Step 6 --- Deep dive 2: the list query that dies at page 500]

The obvious list query:

```sql
SELECT ticket_id, subject, status, updated_at
FROM tickets
WHERE tenant_id = 9 AND status IN (0,1,2)
ORDER BY updated_at DESC
LIMIT 25 OFFSET 12475;          -- page 500
```

*Why `OFFSET` dies.* The database cannot jump to row 12,475. It must produce rows
1 to 12,475, throw them away, and return the next 25.

$ "rows touched at page" p = 25 times p $

#table(columns: (auto, auto, auto),
  [*Page*], [*Rows the database touches*], [*Rough time*],
  [1], [25], [1 ms],
  [100], [2,500], [12 ms],
  [500], [12,500], [60 ms],
  [4,000], [100,000], [480 ms],
)

And it is *wrong*, not only slow: a ticket updated between page 1 and page 2 shifts
everything down, so page 2 repeats a row that page 1 already showed.

*The fix: keyset (cursor) pagination.* Order by something *totally ordered* and carry the
last value forward.

```sql
SELECT ticket_id, subject, status, updated_at
FROM tickets
WHERE tenant_id = 9 AND status IN (0,1,2)
  AND (updated_at, ticket_id) < (:last_updated_at, :last_ticket_id)
ORDER BY updated_at DESC, ticket_id DESC
LIMIT 25;
```

Every page is now an index seek plus 25 entries --- *constant cost, page 1 or page 4,000*.

#table(columns: (auto, auto, auto),
  [], [*OFFSET*], [*keyset*],
  [rows touched, page 500], [12,500], [25],
  [cost as pages grow], [linear], [flat],
  [duplicates when data changes], [yes], [no],
  [can jump to "page 500"], [yes], [*no*],
)

*The cost, stated honestly:* you lose "jump to page 500" and you lose a total page count.
*Decision:* take keyset. A support agent has never once wanted page 500; they want
"next" and a filter. Where the product truly needs numbered pages (an export screen), cap
the offset at 10,000 rows and tell the user to filter.

#trap[
Keyset pagination is *only correct if the sort key is unique*. `ORDER BY updated_at DESC`
alone will skip or repeat rows whenever two tickets share a millisecond --- and at 104
inserts a second, they will. Always append the primary key as the tie-breaker, and compare
as a tuple: `(updated_at, ticket_id) < (:a, :b)`.
]

#subsection[Step 6 --- Deep dive 3: search, and the consistency you must admit]

"Find every ticket mentioning `refund failed`" is not an index problem. `LIKE '%refund%'`
cannot use a B-tree, so it is a full scan of 24 TB.

*Two options.*

*Option A --- the database's own full-text index.* Postgres `tsvector` with a GIN index.
One system, transactional: the search result can never disagree with the row, because they
commit together.
Cost: the GIN index on message bodies is roughly 30--50% of the text size --- call it 4 TB
--- and every insert now pays the GIN update. It also gives you no ranking to speak of, no
typo tolerance, and no faceting.

*Option B --- a separate search service*, fed by change-data-capture from the write-ahead
log. Cost: a second system to run, and the index is *eventually* consistent --- typically
1--5 seconds behind.

*Decision: B, a separate search index*, because (i) it keeps 4 TB of GIN index off the
transactional database that is already at 5,208 QPS, and (ii) helpdesk search genuinely
needs ranking and typo tolerance, which the database does not give.

*And then handle the lag honestly*, which is the part candidates forget:
- after an agent creates a ticket, show it from the *database* on their next screen, not
  from search;
- label the search screen "results may be a few seconds behind";
- for the one screen that must be exact (legal export), query the database with an
  explicit filter, not search.

#subsection[Step 7 --- Trade-offs, failure modes, and 10x]

#table(columns: (auto, 1fr, 1fr, 1fr),
  [*Decision*], [*Chosen*], [*Rejected*], [*Why, in one line*],
  [tenancy], [shared tables + `tenant_id`], [database per tenant],
    [20,000 migrations per release is not a release],
  [pagination], [keyset cursor], [`OFFSET`],
    [flat cost and no duplicates beat "jump to page 500"],
  [search], [external index via CDC], [in-database GIN],
    [keeps 4 TB and its write cost off the hot node],
  [old data], [monthly partitions, drop + archive], [`DELETE` by date],
    [`DROP TABLE` is instant; `DELETE` of 800 GB is an outage],
  [ticket edits], [version column, 409 on conflict], [last write wins],
    [two agents editing one ticket must not silently overwrite],
  [attachments], [object storage + key], [bytes in the row],
    [keeps rows small, backups small, buffer pool useful],
)

*Failure modes, and what actually happens.*

#table(columns: (auto, 1fr, 1fr),
  [*Failure*], [*Symptom*], [*What I do*],
  [primary dies], [all writes fail; reads from replicas still work],
    [promote a replica (30--60 s), point the writer DNS at it; the app already serves reads],
  [replication lag spikes to 10 s], [an agent replies, refreshes, and their reply is missing],
    [route "read your own write" to the primary for 5 s after a write, keyed by user id],
  [one tenant imports 5 million tickets], [the pool fills, every tenant is slow],
    [per-tenant rate limit + a separate low-priority pool for bulk imports],
  [a partition is not created for next month], [inserts fail on the 1st at midnight],
    [a job that creates partitions 3 months ahead, plus an alert if fewer than 2 exist],
  [search index falls behind by an hour], [agents cannot find new tickets],
    [the list view still works from the database; page on CDC lag, not on index size],
)

*At 10x (200,000 tenants, 52,000 queries/s, 135 TB/year).*
+ `tenant_id` is already the leading key, so *shard by `hash(tenant_id)` into 16 shards*.
  No schema change, only a router. This is why decision (a) mattered.
+ Move messages --- 91% of the bytes --- out of the SQL primary into a wide-column store
  keyed by `(tenant_id, ticket_id)`, since messages are only ever read by that key. Tickets
  stay in SQL because they are filtered six different ways.
+ The list query is served from a read model kept in Redis per agent, rebuilt from CDC.
+ Archive to Parquet in object storage after 6 months instead of 24.
]

#ex(18, tier: 2, asked: "Grab · pattern")[
A product manager asks for a `ticket_count` on every tenant's dashboard, live. At peak,
104 tickets a second are created across 20,000 tenants. What do you build?
#sol[
*The naive answer:* `SELECT count(*) FROM tickets WHERE tenant_id = ?`.
For the largest tenant that is a count over 600,000 rows on every dashboard load. With a
partial index it is an index-only scan of 600,000 entries --- about 100 ms, every load.
Unacceptable on a dashboard that polls.

*Option A --- a counter row per tenant,* incremented in the same transaction.

$ "writes per second on the counter table" = 104 $

But they are spread over 20,000 tenants, so the *hottest single row* takes only the biggest
tenant's share. If the biggest tenant is 5% of all tickets:
$ 104 times 0.05 = 5.2 "updates per second on one row" $
At 2 ms per update that row can do 500/s. 5.2 is nothing. *No hot-row problem.*

*Option B --- recompute every 60 seconds* into a summary table.
Cost: one query per tenant per minute $= "20,000" \/ 60 = 333$ counts per second. That is
worse than the writes it replaces.

*Option C --- approximate count* from table statistics. Free, but wrong by a few percent
and useless per tenant.

*Decision: Option A*, a `tenant_stats(tenant_id, open_count, total_count)` row updated in
the same transaction as the ticket insert and the status change. It is exact, it is
$O(1)$ to read, and the arithmetic above proves the write contention is a non-issue at
this scale.

*What I say next, unprompted:* "If one tenant ever grew to 50% of traffic, the row would
take $104 times 0.5 = 52$ updates a second --- still under 500, so it holds. I would revisit
at roughly 10x total volume, and then bucket the counter the way I would a flash-sale
stock row."
]
#ans[A per-tenant counter row updated in the same transaction. Peak contention is 5.2 updates/s on the hottest row --- 100x below the limit.]
]

#ex(19, tier: 2, asked: "DBS · pattern")[
The team wants to add "tags" to tickets: each ticket has 0 to 10 tags, and agents filter
by "has tag X". Compare three designs and pick one. 3 million tickets a day.
#sol[
*Design A --- a text column `tags` holding a comma list.* Rejected immediately: not 1NF,
`LIKE '%vip%'` is a full scan and matches `not-vip`. See Warm-up 2.

*Design B --- a child table.*

```sql
CREATE TABLE ticket_tags (
  tenant_id BIGINT NOT NULL, ticket_id BIGINT NOT NULL, tag TEXT NOT NULL,
  PRIMARY KEY (tenant_id, tag, ticket_id)      -- note the order!
);
```
Key order is `(tenant_id, tag, ticket_id)` because the query is "tickets with tag X",
so `tag` must come before `ticket_id`.

Rows added per day: $"3,000,000" times 3 "tags average" = "9,000,000"$ rows/day.
At \~60 bytes: $"9,000,000" times 60 = 540$ MB/day $= 197$ GB/year. Acceptable.
Filtering by two tags is a join or an intersect --- still index seeks.

*Design C --- an array column with a GIN index.*

```sql
ALTER TABLE tickets ADD COLUMN tags TEXT[];
CREATE INDEX ix_tags ON tickets USING GIN (tags);
-- WHERE tags @> ARRAY['vip']
```
No extra table, no join, and "has all of these tags" is one operator. Cost: a GIN index
update on every ticket write, GIN's pending-list behaviour makes write latency spiky, and
you cannot put a foreign key on a tag inside an array, so typos create new tags forever.

*Decision: B, the child table.* Two reasons I can defend: (i) a `tags(tenant_id, tag)`
lookup table plus a foreign key stops typo-tags, which is the actual product problem after
six months; (ii) writes stay predictable at 104 tickets/s peak, where GIN's spiky updates
would sit directly on the ticket-creation path.

*When I would switch to C:* if the product needed "tickets having ALL of tags A, B and C"
as its main filter, because the array containment operator does that in one index probe
where the child table needs an N-way intersect.
]
#ans[Child table keyed `(tenant_id, tag, ticket_id)`. Array + GIN only if "has all of these tags" becomes the main query.]
]

#section[Tier 3 · Large-scale: a telemetry store for 20 million devices]
#tier-header(3)

#ex(20, tier: 3, asked: "Amazon · pattern")[
20 million field devices (meters, sensors, scooters) each send one reading a minute, and
each reading carries 8 metrics. Engineers query "device D over the last hour" constantly
and "fleet average over the last month" occasionally. Design the storage. All seven steps.
]

#sol[
#subsection[Step 1 --- Clarify]

#table(columns: (1fr, 1fr),
  [*Question*], [*What it changes*],
  [Is a lost reading acceptable?],
    [Yes (one missing point in 1,440 a day) means I can choose availability over consistency and use a quorum of 2 of 3. No would force synchronous replication and halve throughput.],
  [How long is data kept at full resolution?],
    [7 days at full resolution and 2 years rolled up is a 40x storage difference versus keeping everything raw.],
  [Do readings arrive in order and on time?],
    [No --- devices go offline in tunnels and dump an hour of backlog at once. That means I must handle out-of-order writes and late arrivals, which rules out some append-only designs.],
  [Is any query "give me all devices where temperature > 80 right now"?],
    [If yes, I need a secondary index or a separate "latest value" store. If no, everything can be keyed by device.],
  [Does a reading ever need to be corrected?],
    [Overwrite by `(device, timestamp, metric)` is enough; no transactions, no multi-row atomicity.],
)

*Assumptions:* losing a rare point is fine; 7 days raw, 2 years of 5-minute rollups;
out-of-order arrivals up to 6 hours late; "current value of all devices" is a real query.

#subsection[Step 2 --- Scale estimate]

*Ingest rate.*
$ "messages/s" = "20,000,000" "devices" / 60 "s" = "333,333" "messages/s" $
$ "points/s" = "333,333" times 8 "metrics" = "2,666,667" "points/s" $

*Per day.*
$ "messages/day" = "20,000,000" times "1,440" = "28,800,000,000" = 28.8 "billion" $
$ "points/day" = 28.8 "billion" times 8 = "230,400,000,000" = 230.4 "billion" $

*Raw storage, if stored naively at 16 bytes per point:*
$ 230.4 times 10^9 times 16 = 3.686 times 10^12 "bytes" = 3.69 "TB/day" $

*Compressed.* Time-series values compress hard: delta-of-delta on the timestamp and
XOR-of-float on the value give roughly 2 bytes per point in practice.
$ 230.4 times 10^9 times 2 = 460.8 times 10^9 = 460.8 "GB/day" $
$ "per year" = 460.8 times 365 = "168,192" "GB" = 168.2 "TB/year" $
$ "with 3 replicas" = 168.2 times 3 = 504.6 "TB/year" $

Compression is not a detail here --- it is the difference between 168 TB and 1,346 TB a
year. Say the ratio out loud: $16 \/ 2 = 8 times$.

*Ingest bandwidth.* A message with 8 metrics plus headers is about 120 bytes.
$ "333,333" times 120 = "40,000,000" "bytes/s" = 40 "MB/s" = 320 "Mbit/s" $
Tiny. The bytes are not the problem --- the *write rate* is.

*How many storage nodes?* One LSM node sustains about 300,000 point-writes per second
while also compacting.
$ "with replication factor 3: " "2,666,667" times 3 = "8,000,000" "point-writes/s" $
$ "8,000,000" / "300,000" = 26.7 arrow.r 27 "nodes" $
$ "with 1.5x headroom for compaction and node loss" = 27 times 1.5 = 40 "nodes" $

#note[
Do the replication multiplication *out loud*. Half of candidates size the cluster for
2.67 million writes a second and forget that replication factor 3 means the cluster
actually performs 8 million. It is a 3x sizing error, and interviewers listen for it.
]

#subsection[Step 3 --- API surface]

#code(lang: "text", caption: "Three writes, three reads")[
```text
POST /v1/ingest                      <- devices, batched, protobuf
  body { deviceId, points:[ {ts, metric, value} x N ] }
  202 Accepted             <- accepted, not stored: it goes to a log first.
  note  the device retries on any non-2xx; writes are idempotent by
        (deviceId, ts, metric) so a retry overwrites with the same value

GET /v1/devices/{id}/series?metric=temp_c&from=...&to=...&step=60s
  200 { deviceId, metric, step, points:[[ts, value], ...] }
  note  `step` is mandatory. Without it a 2-year query returns 1M points
        and nobody's browser survives it.

GET /v1/devices/{id}/latest
  200 { deviceId, ts, metrics:{ temp_c: 31.4, volts: 12.1, ... } }
  note  served from a separate tiny store, not from the time series

POST /v1/query/aggregate
  body { filter:{ fleet:"scooters-bkk" }, metric:"battery_pct",
         from, to, step:"5m", agg:"avg" }
  202 { jobId }        <- a month-wide fleet query is a JOB, not a request
GET  /v1/query/jobs/{jobId}   -> 200 { state, resultUrl }
```
]

#trick[
Making the fleet-wide aggregate an *asynchronous job* rather than a synchronous `GET` is
one of the highest-value design moves in this whole chapter. A month of 5-minute rollups
across 20 million devices is
$ "20,000,000" times (30 times 24 times 12) = "20,000,000" times "8,640" = 172.8 "billion values" $
That cannot be a request with a 30-second timeout. Making it a job means a slow query can
never take down the read path that the dashboards depend on.
]

#subsection[Step 4 --- Data model]

This is a wide-column (LSM) model. There are no joins and no ad-hoc filters --- *you design
the key for the query you will run, and you cannot run any other query*.

#code(lang: "text", caption: "The physical layout. The partition key is the whole design.")[
```text
TABLE readings
  PARTITION KEY  (device_id, day_bucket)      -- day_bucket = floor(ts / 86400)
  CLUSTERING KEY (metric, ts)                 -- sorted inside the partition
  VALUE          value DOUBLE
  TTL            7 days

  -> one partition = one device, one day = 1,440 x 8 = 11,520 points
  -> "device D, metric temp_c, last hour" = ONE partition, ONE contiguous slice

TABLE rollup_5m
  PARTITION KEY  (device_id, month_bucket)
  CLUSTERING KEY (metric, ts_5m)
  VALUE          min, max, sum, count   -- avg is sum/count, and it composes
  TTL            730 days

TABLE latest
  PARTITION KEY  (device_id)
  VALUE          ts, metrics map<text,double>   -- rewritten every minute

TABLE fleet_index
  PARTITION KEY  (fleet_id, day_bucket)
  CLUSTERING KEY (device_id)
  -> the ONLY way to answer "which devices are in fleet F"
```
]

*Why `(device_id, day_bucket)` and not just `device_id`?*

#table(columns: (auto, auto, 1fr),
  [*Key*], [*Partition size after 7 days*], [*Verdict*],
  [`device_id`], [$"11,520" times 7 = "80,640"$ points], [works today; breaks the day someone raises retention or adds metrics --- unbounded partitions are the classic wide-column mistake],
  [`(device_id, day_bucket)`], [11,520 points, \~23 KB compressed], [*chosen* --- bounded by construction, whatever the retention],
  [`(device_id, hour_bucket)`], [480 points], [too small: a 24-hour query now reads 24 partitions instead of 1],
)

*The rule for a partition key, in one line:* it must make the hot query read *one*
partition, and it must be *bounded in size no matter how long the system runs*.

#subsection[Prove it: what a bad partition key costs]

Do not argue about partition keys. Simulate them.

#code(lang: "python", caption: "partition.py — the same data, four different keys")[
```python
import hashlib
from collections import Counter

DEVICES, PARTITIONS, HOUR = 2_000, 64, 3600
STEP = 900                                     # one reading every 15 minutes

def h(s):
    return int(hashlib.md5(s.encode()).hexdigest(), 16)

def load(label, keyfn):
    c = Counter()
    for d in range(DEVICES):
        for t in range(0, 24 * HOUR, STEP):
            c[h(keyfn(d, t)) % PARTITIONS] += 1
    avg = sum(c.values()) / PARTITIONS
    hot = max(c.values())
    print(f"{label:<22} used={len(c):>3}  hottest={hot:>8,}"
          f"  avg={avg:>5,.0f}  hot/avg={hot/avg:>5.2f}x")

load("hour",                   lambda d, t: f"{t // HOUR}")
load("device_id",              lambda d, t: f"dev{d}")
load("(device_id, day)",       lambda d, t: f"dev{d}#{t // (24 * HOUR)}")
load("(device_id, 6h bucket)", lambda d, t: f"dev{d}#{t // (6 * HOUR)}")
```
]

#code(lang: "text", caption: "$ python3 partition.py  — real output")[
```text
hour                   used= 19  hottest=  24,000  avg=3,000  hot/avg= 8.00x
device_id              used= 64  hottest=   4,320  avg=3,000  hot/avg= 1.44x
(device_id, day)       used= 64  hottest=   4,224  avg=3,000  hot/avg= 1.41x
(device_id, 6h bucket) used= 64  hottest=   3,888  avg=3,000  hot/avg= 1.30x
```
]

Read the first line and feel the pain. Keying by *time* uses only 19 of 64 partitions, and
the busiest is *8x* the average. In a real cluster that means one node takes 8x the write
load of its neighbours while 45 nodes sit idle. Every device writing "now" writes to the
same partition --- that is the definition of a hot partition.

Every device-keyed variant spreads flat (1.3--1.4x, which is just normal hashing variance).
Adding a *time bucket to a device key* costs nothing in balance and buys bounded partitions.

#subsection[Step 5 --- Architecture]

#diagram(height: 6.8cm, caption: "Ingest goes through a log, so storage can stall without losing data. The router picks raw or rollup by time range.")[
  #dnode(0.2cm, 0.1cm, 8.6cm, 0.9cm, "2.67M points/s x RF3 = 8M writes/s · 460.8 GB/day", fill: rgb("#fbf6ee"))

  #dnode(0.2cm, 1.2cm, 2.3cm, 1.1cm, "20M\ndevices")
  #darrow(2.55cm, 1.75cm, 3.05cm, 1.75cm, label: "333k/s")
  #dnode(3.1cm, 1.2cm, 2.5cm, 1.1cm, "ingest API\n(stateless)")
  #darrow(5.65cm, 1.75cm, 6.15cm, 1.75cm)
  #dnode(6.2cm, 1.2cm, 2.7cm, 1.1cm, "log, partitioned\nby device_id", fill: rgb("#fbf6ee"))

  #dnode(10.0cm, 0.1cm, 5.4cm, 0.9cm, "raw store · 40 nodes\nTTL 7 days", fill: rgb("#dce9f2"))
  #dnode(10.0cm, 1.3cm, 5.4cm, 0.9cm, "rollup 5m (90 d)\nrollup 1h (2 years)", fill: rgb("#dce9f2"))
  #dnode(10.0cm, 2.5cm, 5.4cm, 0.9cm, "latest KV\n20M rows, 4 GB", fill: rgb("#dce9f2"))
  #darrow(8.95cm, 1.55cm, 9.95cm, 0.55cm)
  #place(dx: 9.0cm, dy: 0.98cm)[#text(size: 7pt, fill: dc)[writers]]
  #darrow(8.95cm, 1.75cm, 9.95cm, 1.75cm)
  #darrow(8.95cm, 1.95cm, 9.95cm, 2.95cm)

  #dnode(0.2cm, 3.9cm, 2.3cm, 1.0cm, "dashboard")
  #darrow(2.55cm, 4.4cm, 3.05cm, 4.4cm)
  #dnode(3.1cm, 3.8cm, 4.0cm, 1.2cm, "query router\n< 7 days -> raw store\nelse -> rollup store")
  #darrow(7.15cm, 4.4cm, 15.85cm, 4.4cm, label: "reads")
  #darrow(15.9cm, 4.3cm, 15.9cm, 0.5cm)
  #darrow(15.9cm, 0.55cm, 15.45cm, 0.55cm)
  #darrow(15.9cm, 1.75cm, 15.45cm, 1.75cm)
  #darrow(15.9cm, 2.95cm, 15.45cm, 2.95cm)

  #dnode(3.1cm, 5.4cm, 4.0cm, 0.9cm, "job runner\n(fleet queries)")
  #darrow(5.1cm, 5.0cm, 5.1cm, 5.4cm)
  #dnode(8.0cm, 5.4cm, 7.4cm, 0.9cm, "cold: Parquet in object storage\n(2 years, cheap parallel scans)", fill: rgb("#f0ece2"))
  #darrow(7.15cm, 5.85cm, 7.95cm, 5.85cm)
]

#subsection[Step 6 --- Deep dive 1: why LSM, measured]

The claim "LSM is better for write-heavy workloads" is worth nothing unless you can say
what it costs. Here is a tiny LSM you can run.

#code(lang: "js", caption: "lsm.js — memtable, levels, compaction, and a write-amplification counter")[
```js
class LSM {
  constructor({ memLimit = 1000, fanout = 10 } = {}) {
    this.mem = new Map();          // memtable: newest writes, in RAM
    this.levels = [];              // levels[0] newest ... levels[n] oldest
    this.memLimit = memLimit; this.fanout = fanout;
    this.userWrites = 0; this.diskWrites = 0;
  }
  put(k, v) {
    this.userWrites++;
    this.mem.set(k, v);
    if (this.mem.size >= this.memLimit) this.flush();
  }
  flush() {
    const run = [...this.mem.entries()]
      .sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0));
    this.mem.clear();
    this.mergeInto(0, run);
    this.compact();
  }
  mergeInto(level, run) {
    const merged = LSM.merge(run, this.levels[level] ?? []);  // run is newer
    this.diskWrites += merged.length;               // merges rewrite bytes
    this.levels[level] = merged;
  }
  compact() {
    for (let i = 0; i < this.levels.length; i++) {
      const cap = this.memLimit * Math.pow(this.fanout, i + 1);
      if (this.levels[i].length <= cap) continue;
      const run = this.levels[i];
      this.levels[i] = [];
      this.mergeInto(i + 1, run);
    }
  }
  static merge(newer, older) {              // 2-way merge; the newer key wins
    const out = []; let i = 0, j = 0;
    while (i < newer.length || j < older.length) {
      if (j >= older.length) out.push(newer[i++]);
      else if (i >= newer.length) out.push(older[j++]);
      else if (newer[i][0] < older[j][0]) out.push(newer[i++]);
      else if (newer[i][0] > older[j][0]) out.push(older[j++]);
      else { out.push(newer[i++]); j++; }  // duplicate: the older copy is dropped
    }
    return out;
  }
  get(k) {
    let runsRead = 0;
    if (this.mem.has(k)) return { v: this.mem.get(k), runsRead };
    for (const run of this.levels) {
      if (run.length === 0) continue;
      runsRead++;
      let lo = 0, hi = run.length;
      while (lo < hi) { const m = (lo + hi) >> 1;
        if (run[m][0] < k) lo = m + 1; else hi = m; }
      if (lo < run.length && run[lo][0] === k) return { v: run[lo][1], runsRead };
    }
    return { v: undefined, runsRead };
  }
}

const t = new LSM({ memLimit: 1000, fanout: 10 });
const key = (i) => "k" + String(i % 50000).padStart(6, "0");
for (let i = 0; i < 200000; i++) t.put(key(i), i);
console.log("keys the user wrote   :", t.userWrites);
console.log("rows rewritten to disk:", t.diskWrites);
console.log("write amplification   :",
            (t.diskWrites / t.userWrites).toFixed(2) + "x");
console.log("levels (rows each)    :", t.levels.map(r => r.length));
const hit = t.get("k000042"), miss = t.get("k999999");
console.log("read an existing key  :", hit.v,  "| runs touched =", hit.runsRead);
console.log("read a missing key    :", miss.v, "| runs touched =", miss.runsRead);
```
]

#code(lang: "text", caption: "$ node lsm.js  — real output")[
```text
keys the user wrote   : 200000
rows rewritten to disk: 2001000
write amplification   : 10.01x
levels (rows each)    : [ 2000, 50000 ]
read an existing key  : 150042 | runs touched = 2
read a missing key    : undefined | runs touched = 2
```
]

*What those five lines tell you, in interview language:*

+ *Write amplification is 10.01x.* The user wrote 200,000 rows; the disk wrote 2,001,000.
  This is the real cost of LSM. Budget for it: at 8 million point-writes a second,
  the disks are actually doing $"8,000,000" times 10 = 80$ million row-writes a second
  across 40 nodes, or 2 million per node. That is why the node estimate needed 1.5x
  headroom for compaction.
+ *A read touched 2 runs.* A B-tree would touch exactly 1 path. LSM reads are slower and
  *less predictable* than B-tree reads. That is the trade.
+ *A missing key touched 2 runs too.* A read for a key that is not there does the maximum
  work. That is precisely what a *Bloom filter per run* removes: it answers "definitely
  not here" in RAM, so a missing key costs zero disk reads.
+ *Duplicates are collapsed during merge.* The same key written 4 times occupies 4 slots
  until compaction, then 1. So disk usage rises and falls in a sawtooth, and you must
  provision for the peak of the sawtooth, not the average.

*The decision, stated plainly:* the workload is 2.67 million writes a second, 8 metrics per
device, always read back by device. LSM wins the write side by an order of magnitude, and
the read penalty (2 runs instead of 1 path, fixed by Bloom filters) does not matter because
reads are 1,000x rarer than writes here. If the read/write ratio were reversed, this
decision would flip to a B-tree store.

#subsection[Step 6 --- Deep dive 2: the query "temperature > 80 across the fleet"]

This query has no device id. In a partition-keyed store it is a full cluster scan: 40 nodes
each scanning everything. Three options.

*Option A --- a global secondary index on `value`.* The index must be partitioned by value,
so every write to any device sends an extra write to a *different* node. Write cost
doubles (8 million $arrow.r$ 16 million writes/s, meaning 40 $arrow.r$ 80 nodes), and the
index for a popular value range becomes its own hot partition. Rejected.

*Option B --- a local secondary index* (one index per partition). Writes stay local and
cheap. But a query with no device id must still ask all 40 nodes and merge --- a
scatter-gather across the entire cluster on every dashboard refresh. Rejected for the hot
path; useful for the rare job.

*Option C --- a separate `latest` store plus alert evaluation on the write path.*
- The `latest` table already holds one small row per device, 20 million rows total ---
  roughly $"20,000,000" times 200 "bytes" = 4$ GB. That fits in memory on a handful of
  nodes.
- "Which devices are over 80 right now" becomes a scan of a 4 GB in-memory table, not
  168 TB of history.
- Alerts are evaluated as the point arrives, in the writer, and *breaches* are written to a
  small `alerts` table that is tiny and fully indexable.

*Decision: C.* The insight to say out loud: *the fleet-wide question is about the present,
not about history.* Do not build an index over 168 TB to answer a question about 4 GB.
Keep a small, current, differently-shaped copy of the data and query that.

#subsection[Step 6 --- Deep dive 3: rollups, TTL and the sawtooth]

*Why rollups.* A 30-day chart of one device at full resolution is
$30 times "1,440" = "43,200"$ points per metric. Nobody's screen has 43,200 pixels. Rolling
up to 5-minute buckets gives
$ (30 times 24 times 60) / 5 = "8,640" "points" $
and to 1-hour buckets gives $30 times 24 = 720$ points. Storage falls the same way:

$ "5-minute rollup is " 5 times "fewer rows than 1-minute raw" $
$ 460.8 "GB/day" / 5 = 92.2 "GB/day, storing min/max/sum/count" $

Since a rollup row holds 4 numbers instead of 1, the real saving is
$5 \/ 4 = 1.25 times$ on that table --- which sounds disappointing until you remember the
*raw* table is deleted after 7 days while the rollup lives 2 years.

$ "raw kept: " 460.8 times 7 = "3,226" "GB" approx 3.2 "TB" $
$ "rollup kept: " 92.2 times 4 times 730 = "269,224" "GB" approx 269 "TB" $

Hold on --- that is *worse* than keeping raw for 2 years? Check:
$ "raw for 2 years" = 460.8 times 730 = "336,384" "GB" = 336 "TB" $
$ 269 / 336 = 0.80 $

So the rollup saves only 20%. *That arithmetic changes the design*, and this is exactly the
kind of moment an interviewer is waiting for. Fix it by rolling up *twice*:

$ "5-min rollup, kept 90 days" = 92.2 times 4 times 90 = "33,192" "GB" = 33 "TB" $
$ "1-hour rollup, kept 730 days" = (460.8/60) times 4 times 730 = "22,426" "GB" = 22 "TB" $
$ "total" = 3.2 + 33 + 22 = 58.2 "TB" "versus" 336 "TB raw" = 5.8 times "smaller" $

*Decision: three tiers --- raw 7 days, 5-minute 90 days, 1-hour 2 years.* And say the
number: 5.8x, not "much smaller".

#trap[
*Aggregates must compose.* Store `min, max, sum, count` --- never `avg`. You cannot average
a set of averages when the buckets have different counts: the average of `avg=10 (n=1)`
and `avg=20 (n=999)` is not 15, it is
$(10 times 1 + 20 times 999) \/ 1000 = 19.99$.
Store `sum` and `count`, divide at read time. The same rule kills `median` and `p99`:
they do not compose at all, so you must store a sketch (t-digest, HLL for distinct counts),
not a number.
]

#subsection[Step 7 --- Trade-offs, failure modes, and 10x]

#table(columns: (auto, 1fr, 1fr, 1fr),
  [*Decision*], [*Chosen*], [*Rejected*], [*Why*],
  [engine], [LSM wide-column], [B-tree SQL],
    [2.67M writes/s; B-tree random I/O cannot do it at any sane cost],
  [partition key], [`(device_id, day_bucket)`], [`device_id` alone or time],
    [time keys give 8x hot partitions (measured); device alone grows unbounded],
  [consistency], [quorum W=2, R=2 of RF=3 (AP-leaning)], [W=3 strict],
    [one lost point in 1,440 is invisible; an unavailable ingest endpoint is not],
  [fleet queries], [async jobs + a small `latest` table], [global secondary index],
    [a global index doubles the write cost and creates its own hot partitions],
  [retention], [3 tiers: raw 7d, 5m 90d, 1h 730d], [raw for 2 years],
    [5.8x less storage, and dashboards never want 43,200 points anyway],
  [ingest], [log first, storage second], [write straight to storage],
    [a compaction stall must slow the writers, never reject the devices],
)

*The CAP sentence you should say.* "During a network partition I choose *availability*:
the ingest path keeps accepting writes with W=2 on whichever replicas it can reach, and
readers may briefly see a point missing. I make that choice because a device that cannot
write drops the reading permanently, while a reader seeing 1,439 of 1,440 points sees a
chart that looks identical. If this were a billing meter, I would flip to consistency and
accept ingest failures, because a missing unit of electricity is money."

*Failure modes.*

#table(columns: (auto, 1fr, 1fr),
  [*Failure*], [*Symptom*], [*What happens*],
  [one storage node dies], [its partitions lose one replica],
    [quorum of 2 still satisfied; hinted writes replay when it returns; no user impact],
  [compaction storm on a node], [p99 write latency on that node goes 10x],
    [the log absorbs it: writers lag, devices never see an error; alert on log lag, not on latency],
  [10,000 devices come out of a tunnel at once], [a 6-hour backlog arrives in 60 seconds],
    [the log flattens the burst; out-of-order points are fine because the key is `(metric, ts)` and writes are idempotent],
  [a whole region is partitioned], [half the devices cannot reach their nearest cluster],
    [devices fail over to the next region's endpoint; data lands in the wrong region and is reconciled by device id later],
  [a bad deploy writes a broken metric name], [a new, unbounded set of metric names],
    [cardinality limit per device (say 64 metrics), enforced at ingest; reject and count, do not store],
)

*The failure that has no clean fix, and you should say so:* *cardinality explosion*. If a
device starts emitting a metric name containing a timestamp or a request id, the number of
distinct series grows without limit and every index and rollup grows with it. There is no
storage trick that survives it. The only defence is a hard limit at the ingest boundary and
an alert on new-series-per-minute. Naming this unprompted is what separates a Tier-3 answer
from a Tier-2 one.

*At 10x (200 million devices, 26.7 million points/s).*
+ Node count scales linearly: $26.7 "M" times 3 \/ "300,000" times 1.5 = 400$ nodes. Linear
  scaling is the *point* of a partition key with no cross-partition queries.
+ Push the first rollup *to the device*: a device that sends one 1-minute average instead
  of 60 one-second readings cuts ingest 60x. At this scale the cheapest byte is the one
  never sent.
+ Move raw retention from 7 days to 24 hours and lean harder on rollups.
+ Split the `latest` table out to its own cluster; at 200 million rows it is 40 GB and
  deserves its own memory budget.
]

#ex(21, tier: 3, asked: "Google · pattern")[
Your telemetry cluster has 40 nodes. One customer's 200,000 scooters all report at exactly
`hh:mm:00` because their firmware uses a shared cron. What breaks, and how do you fix it
without a firmware update?
#sol[
*What breaks.* The partition key is `(device_id, day_bucket)`, so the *partitions* are
spread evenly --- that part is fine. What is not spread is *time*: all 200,000 writes land
in the same few hundred milliseconds of every minute.

$ "200,000" "writes" / 0.5 "s" = "400,000" "writes/s in the spike" $

against a steady-state budget of
$ "200,000" / 60 = "3,333" "writes/s" $

That is a *120x* burst. The ingest API autoscaler cannot react in 500 ms, connection pools
fill, and the writers time out --- once a minute, forever.

*Fix 1 --- absorb it in the log.* The log is append-only and sequential; 400,000 small
appends a second is well within one partition set's capacity. The writers then drain at
their own pace. The burst becomes *lag*, and lag is harmless here. This alone probably
solves it.

*Fix 2 --- smear at the edge.* The ingest API, on receiving a batch, does not need to write
immediately. Hold each device's batch for
$ "delay" = "hash"("device_id") mod 30 "seconds" $
The spike flattens across 30 seconds:
$ "200,000" / 30 = "6,667" "writes/s" $
That is a 60x reduction, with a deterministic delay per device so ordering per device is
preserved. Note this is a *server-side* change --- no firmware update, which was the
constraint.

*Fix 3 --- fix the numbers, not the system.* Tell the customer to add
`sleep $((RANDOM % 55))` to the cron on the next firmware cycle. Correct, free, and slow to
arrive. Do it anyway, but do not wait for it.

*Decision: 1 and 2 now, 3 scheduled.* The interviewer is testing whether you noticed that
an evenly-spread *key* does not imply evenly-spread *time*. Say that sentence.
]
#ans[A 120x per-minute write burst. Absorb it in the log, then smear by `hash(device_id) mod 30 s` at the ingest API.]
]

#ex(22, tier: 3, asked: "Microsoft · pattern")[
Compute how much RAM the Bloom filters need for the raw table, and decide whether they are
worth it.
#sol[
*How many keys?* One Bloom filter entry per key per sorted run. The raw table holds 7 days:

$ "partitions" = "20,000,000" "devices" times 7 "days" = "140,000,000" "partitions" $

A Bloom filter is built per *run* over the *partition keys* it contains (not over every
point --- that is the common mistake). Assume a steady state of about 8 runs per node.

*Bits per key.* The standard result: for a false-positive rate $p$, you need
$ "bits per key" = -1.44 times log_2(p) $

$ p = 1% arrow.r -1.44 times log_2(0.01) = -1.44 times (-6.64) = 9.6 "bits" approx 10 "bits" $
$ p = 0.1% arrow.r -1.44 times log_2(0.001) = -1.44 times (-9.97) = 14.4 "bits" $

*Memory at 1%:*
$ "140,000,000" "keys" times 10 "bits" = "1,400,000,000" "bits" $
$ "1,400,000,000" / 8 = "175,000,000" "bytes" = 175 "MB" "across the cluster" $
$ 175 "MB" / 40 "nodes" = 4.4 "MB per node" $

*What it buys.* Without filters, a read for a key not on this node touches all runs. The
LSM demo measured 2 runs on a small tree; a production node with 8 runs would do 8 disk
probes for every miss. With a 1% filter:

$ "disk probes per miss" = 8 times 0.01 = 0.08 $

$ 8 / 0.08 = 100 times "fewer disk reads on misses" $

*Decision: obviously yes, at 1%.* 4.4 MB per node --- less than a rounding error on a
64 GB machine --- removes 99% of wasted disk reads. Going to 0.1% costs 1.44x the memory
(6.3 MB/node) for another 10x fewer probes; take that too, because the memory is free at
this size. The only reason not to raise it further is diminishing returns: at 0.01% you are
spending 19 bits per key to avoid probes that already almost never happen.
]
#ans[\~10 bits/key at 1% $arrow.r$ 175 MB cluster-wide, 4.4 MB per node, removing 99% of wasted probes. Clearly worth it.]
]

#section[Interview drill]

These are the pushes that come after your first answer. Each answer is what a strong
candidate says in about 30 seconds.

#subsection[Push 1: "Why not just add an index on every column?"]

#note[
*Answer.* Because every index is a second copy of that column that must be written on
every insert, update and delete, and kept in RAM to be useful.

Concretely, on the helpdesk: 104 ticket inserts a second. With 4 indexes that is
$104 times (1 + 4) = 520$ writes a second instead of 104 --- *5x the write cost*. Index
storage is roughly 10--20% of table size each, so 8 indexes roughly doubles the database.

And most of them would never be used: the planner ignores any index above about 10%
selectivity (Warm-up 4). So the extra indexes cost writes, RAM and backup size, and buy
nothing.

My rule: *one index per hot query, and delete any index with zero scans after 30 days.*
Both numbers are visible in `pg_stat_user_indexes`.
]

#subsection[Push 2: "Your query is slow. Walk me through what you do, in order."]

#note[
*Answer.* Five steps, in this order, and I do not skip to step 5.

+ `EXPLAIN (ANALYZE, BUFFERS)`. I am reading three things: is it a Seq Scan or an Index
  Scan; is the estimated row count close to the actual; and how many buffers were read.
+ *Estimate far off actual* means the statistics are stale --- `ANALYZE` the table. A
  planner that thinks 20 rows match when 200,000 do will pick a terrible plan.
+ *Seq Scan where I expected an index* means either no index matches the left-prefix rule,
  or the predicate is not sargable --- `WHERE lower(email) = ?` cannot use an index on
  `email`; it needs an index on `lower(email)`.
+ *Index used but still slow* means too many heap fetches. Make the index covering.
+ Only then do I consider changing the query, de-normalising or caching.

The thing I do *not* do first is add a cache. A cache in front of a query that should have
been 2 ms hides a bug and doubles the code paths.
]

#subsection[Push 3: "SQL or NoSQL for this? Choose now."]

#note[
*Answer.* I choose by counting access patterns, not by preference.

*One access pattern, always by a known key, enormous write rate* --- that is the telemetry
store. Wide-column LSM.

*Six access patterns over the same entity, plus a transaction* --- that is the helpdesk.
SQL, and I will not move it until a specific query proves SQL cannot serve it at my scale.

The trap in this question is the word "or". The real answer for almost every product is
*both*: SQL for the entities people filter and transact on, and a second store for the one
table that is 90% of the bytes. In the helpdesk that split is tickets (SQL) and messages
(key-value by `(tenant_id, ticket_id)`) --- and I showed the arithmetic: messages are
$24 \/ 26.4 = 91%$ of the daily bytes.
]

#subsection[Push 4: "Two users edit the same ticket. What does the user see?"]

#note[
*Answer.* Not "last write wins" --- that silently destroys one agent's work.

The `PATCH` carries `expectedVersion`. The update is
`UPDATE tickets SET ..., version = version + 1 WHERE tenant_id=? AND ticket_id=? AND version=?`.
If it touches 0 rows, somebody else got there first and I return *409 Conflict* with the
current row in the body.

The UI then shows "Priya changed the status to Pending while you were typing" and offers
merge or overwrite. That is an optimistic-locking design, and it is right here because two
agents editing the same ticket is *rare* --- Example 15 showed optimistic locking is
exactly wrong when conflicts are common, as with flash-sale stock.
]

#subsection[Push 5: "Why is your primary key `(tenant_id, ticket_id)` and not just `ticket_id`?"]

#note[
*Answer.* Four reasons, and the fourth is the one that matters in two years.

+ *Locality.* One tenant's rows sit in the same pages. A tenant's list query touches a
  handful of pages instead of pages scattered across the whole table.
+ *Safety.* Every index is automatically tenant-scoped, so a missing `WHERE tenant_id = ?`
  cannot accidentally return another company's ticket through an index-only scan.
+ *Smaller indexes.* Every secondary index starts with `tenant_id`, so each one is really
  20,000 small trees rather than one huge one.
+ *The exit.* When the database outgrows one node, the shard key is already the leading
  column. Sharding becomes a routing change with *no schema migration*. Retrofitting a
  tenant column into a live 27 TB table is a multi-month project.
]

#subsection[Push 6: "Your replica is 3 seconds behind. A user posts a reply and does not see it. Fix it."]

#note[
*Answer.* This is read-your-own-writes, and there are three fixes with different costs.

+ *Sticky-to-primary window.* After a write by user U, route U's reads to the primary for
  the next 5 seconds. Cost: a small, bounded increase in primary reads. In our numbers,
  writes are 417/s at peak and each buys 5 seconds of stickiness, so at most
  $417 times 5 = "2,085"$ concurrent sticky users out of 200,000 --- about 1%. Cheap.
+ *Write-through the client.* The `POST` response already contains the created message, so
  the UI renders it locally without re-reading. Free, and it handles the common case.
+ *LSN token.* The write returns the log position; the read sends it back; the replica
  waits until it has caught up to that position. Exact, but adds latency and complexity.

*Decision: 2 first (free), 1 as the safety net (1% extra primary reads).* 3 only for a
screen where correctness is legally required.
]

#subsection[Push 7: "How do you change a column type on a 27 TB table with no downtime?"]

#note[
*Answer.* Never with `ALTER TABLE ALTER COLUMN TYPE` --- that rewrites the whole table
under an exclusive lock. Six steps, the expand--contract pattern:

+ Add the new column, nullable, with no default. Instant --- it is a catalogue change only.
+ Deploy code that *writes both* columns and *reads the old* one.
+ Backfill the new column in batches of 10,000 rows with a pause between batches, so
  replication never falls behind.
+ Verify: a query that counts rows where the two disagree must return 0.
+ Deploy code that *reads the new* column.
+ Drop the old column, a week later, after a rollback window has passed.

The whole point is that every step is independently reversible. Adding `NOT NULL` or a
default in step 1 is the classic mistake --- on older engines that rewrites the table.
]

#subsection[Push 8: "When would you de-normalise?"]

#note[
*Answer.* Three cases, and only three.

+ *It is a historical snapshot, not a lookup.* `orders.ship_city` and
  `order_lines.unit_paise` must not change when the customer moves or the price changes.
  This is not de-normalisation at all; it is correct modelling.
+ *To make a constraint writable.* `loans.book_id` was copied purely so that a unique index
  could enforce "one copy of a book per member". A rule the database enforces beats a rule
  the code enforces.
+ *A join is measurably on the hot path.* Measured, not imagined: `EXPLAIN` shows the join,
  the query is in the top 3 by total time, and no index fixes it.

And I state the cost every time: two copies can disagree, so I need one writer, a
reconciliation check, and a documented source of truth. If I cannot name who fixes the
drift, I do not de-normalise.
]

#practice(tier: 0, time: "15 min")[
+ A table has 4,000,000 rows. Pages hold 500 index entries. How many page reads for an
  index lookup? How many pages for a full scan at 40 rows per page?
+ Column `city` has 900 distinct values spread evenly over 2,000,000 rows. Compute the
  selectivity and say whether an index will be used.
+ You have `INDEX (a, b, c)`. Which of these can use it?
  `WHERE a=1` · `WHERE b=2` · `WHERE a=1 AND c=3` · `WHERE c=3 AND b=2 AND a=1`
+ 1,000 buyers do read-modify-write on a stock row starting at 1,000, all reading before
  any writes. What is the final quantity, and how many units were oversold?
+ A query returns 500 rows through a non-covering index. Count the page reads with and
  without an `INCLUDE` of the 2 returned columns (tree height 3, index leaves 4 pages).
+ 12,000,000 rows a day at 1,500 bytes each. Give GB/day, TB/year, and TB/year with
  indexes at +35%.
+ At a Bloom filter false-positive rate of 2%, how many bits per key?
  ($"bits" = -1.44 log_2 p$)
]

#key[
*1.* $500^2 = "250,000" < "4,000,000" <= 500^3 = "125,000,000"$, so height 3.
Index lookup $= 3 + 1 = *4$ page reads*. Full scan $= "4,000,000" \/ 40 = *"100,000"$
pages*. Ratio $"100,000" \/ 4 = "25,000" times$.

*2.* $1 \/ 900 = 0.00111 = 0.111%$, about $"2,222"$ rows. Far below 5%, so *yes, the index
is used*.

*3.* `a=1` *yes* (left prefix). `b=2` *no*. `a=1 AND c=3` *partly* --- it seeks on `a` and
then filters on `c`; `c` is not usable as a seek because `b` is missing.
`c=3 AND b=2 AND a=1` *yes, fully* --- written order is irrelevant.

*4.* Every buyer read 1,000, so every buyer writes 999. Final quantity *999*. Units
actually sold: 1,000. Units the counter admits: 1. *Oversold by 999.*

*5.* Without `INCLUDE`: $3 + 4 + 500 = *507$ page reads*.
With `INCLUDE`: $3 + 4 + 0 = *7$ page reads*. $507 \/ 7 = 72.4 times$ fewer.

*6.* $"12,000,000" times "1,500" = "18,000,000,000" = *18$ GB/day*.
$18 times 365 = "6,570"$ GB $= *6.57$ TB/year*.
With indexes: $6.57 times 1.35 = 8.87$ *TB/year*.

*7.* $-1.44 times log_2(0.02) = -1.44 times (-5.644) = 8.13$, so *9 bits per key*.
]

#practice(tier: 2, time: "40 min")[
+ Design the schema for a college course-registration system: students, courses, sections
  (a course taught at a time by a teacher), enrolments, and a seat cap per section.
  Give the DDL, the key of each table, the four indexes, and the *one constraint* that
  makes over-enrolment impossible. Then compute: 30,000 students, each registering for
  5 sections in a 2-hour window on results day --- what is the peak write rate, and what
  is the peak write rate on the single hottest section row if the most popular section
  has 400 applicants?
+ The helpdesk adds "merge two tickets into one". Write the transaction, name every table
  it touches, and say what happens if it crashes half way. Then say which isolation level
  you run it at and why.
+ A reporting query joins `tickets` to `messages` to count messages per ticket for one
  tenant over one month. Using the chapter's numbers (3M tickets/day, 4 messages each,
  20,000 tenants), estimate the rows touched for an average tenant and decide between
  running it live, running it on a replica, and pre-aggregating.
]

#key[
*1.* Tables: `students(student_id PK)`, `courses(course_id PK)`,
`sections(section_id PK, course_id FK, teacher_id, term, seat_cap, seats_taken)`,
`enrolments(student_id, section_id, enrolled_at, PRIMARY KEY (section_id, student_id))`.

The primary key `(section_id, student_id)` *is* the "no double enrolment" constraint --- a
second insert fails. The seat cap is
`CHECK (seats_taken <= seat_cap)` on `sections`, with
`UPDATE sections SET seats_taken = seats_taken + 1 WHERE section_id = ? AND seats_taken < seat_cap`
in the same transaction as the enrolment insert. If it touches 0 rows, the section is full
and you roll back.

Indexes: `(student_id, term)` for "my timetable"; `(course_id, term)` for "sections of this
course"; `(teacher_id, term)`; the primary keys serve the rest.

Peak rate: $"30,000" times 5 = "150,000"$ enrolments over
$2 times "3,600" = "7,200"$ s $= 20.8$ per second average. Registration is not flat --- use
5x for the first ten minutes: $20.8 times 5 = 104$ *enrolments per second*.

Hottest row: 400 applicants for one section, arriving in the same first minute:
$400 \/ 60 = 6.7$ *updates per second on one row*. At 2 ms per locked update the row supports 500/s,
so it holds comfortably. *No bucketing needed* --- and that is the answer to give, with the
arithmetic, rather than reflexively bucketing.

*2.* `merge(source, target)`: update `messages SET ticket_id = target WHERE ticket_id = source`;
insert a system message into the target; update `ticket_tags` (ignore duplicates); set
`tickets.status = closed, merged_into = target` on the source; bump both `version` columns;
update `tenant_stats`. Five tables.

A crash half way: nothing is visible, because it is one transaction --- atomicity means the
partial state never existed. The dangerous version is doing it in five separate
transactions, which can leave messages pointing at a closed ticket.

Isolation: `READ COMMITTED` is *not* enough, because an agent could add a message to the
source ticket between the move and the close, orphaning it. Run it at
`SERIALIZABLE`, or at `READ COMMITTED` with `SELECT ... FOR UPDATE` on *both* ticket rows
first, in `ticket_id` order (Example 14) so two simultaneous merges cannot deadlock.

*3.* Per tenant per day: $"3,000,000" \/ "20,000" = 150$ tickets and
$150 times 4 = 600$ messages. Over 30 days: $150 times 30 = "4,500"$ tickets and
$600 times 30 = "18,000"$ *messages*.

18,000 rows is nothing --- roughly 20 ms with the right index. *Run it live*, on a replica
so a badly-filtered variant cannot hurt the primary. Pre-aggregation would be premature:
it adds a write-path cost of 417 writes/s to save 20 ms on a report.

The answer changes for the largest tenant. If one tenant is 5% of all volume, that is
$"3,000,000" times 0.05 times 30 = 4.5$ million tickets and *18 million messages* a month
--- there, pre-aggregate. *So: live on a replica, with a row-count guard that switches the
top 1% of tenants to a pre-aggregated table.*
]

#practice(tier: 3, time: "50 min")[
+ Redesign the telemetry store for 5 million devices reporting every 10 seconds with
  20 metrics each. Give: points/s, points/day, compressed GB/day at 2 bytes/point, node
  count at 300,000 point-writes/s with RF=3 and 1.5x headroom, and the partition key with
  its resulting partition size. Then say which of your numbers is most likely to be wrong
  and why.
+ The product adds "alert me when any device in fleet F has battery below 10% for
  15 minutes". Design the data path. Say exactly which store answers it, what you write on
  the ingest path, and what the failure mode is when the alert engine restarts.
+ Compare keeping 2 years of raw data in the LSM store against archiving to columnar files
  in object storage after 7 days. Use the chapter's numbers. Give the storage figures for
  both, name one query each option makes easy and one it makes hard, and decide.
]

#key[
*1.* $"5,000,000" \/ 10 = "500,000"$ messages/s.
$"500,000" times 20 = *"10,000,000"$ points/s*.
Per day: $"10,000,000" times "86,400" = "864,000,000,000" = *864$ billion points/day*.
Compressed: $864 times 10^9 times 2 = "1,728" times 10^9$ bytes $= *"1,728"$ GB/day
$= 1.73$ TB/day*; $times 365 = 631$ TB/year, $times 3$ replicas $= "1,893"$ TB/year.
Nodes: $"10,000,000" times 3 = "30,000,000"$ point-writes/s;
$"30,000,000" \/ "300,000" = 100$; $times 1.5 = *150$ nodes*.

Partition key `(device_id, hour_bucket)`: one partition is
$("3,600" \/ 10) times 20 = "7,200"$ *points*, about 14 KB compressed. A *day* bucket would
be $"8,640" times 20 = "172,800"$ points --- too big for one partition, which is why the
bucket must shrink as the rate rises.

*Most likely wrong number: 2 bytes per point.* It assumes slowly-changing float values.
Counters that jump, or values with genuine noise in the low bits, compress at 4--6 bytes,
which would triple the storage bill. I would measure it on a day of real data before
buying disks.

*2.* Ingest path: for each point, the writer updates the `latest` row *and* maintains a
small per-device state `below_10_since` (set when the value first drops under 10, cleared
when it rises). The alert fires when
$"now" - "below_10_since" >= 900$ s. That is a comparison of two numbers on a row we are
already writing --- no scan, no index.

Which store answers the fleet question: `fleet_index` gives the device list; the alert
state lives with `latest`. The 168 TB history is never touched.

Restart failure mode: the in-memory part of the alert engine loses `below_10_since`, so
every device's timer restarts and alerts are *late by up to 15 minutes*, not lost. Fix by
persisting `below_10_since` in the `latest` row itself, which makes the engine stateless
and restart-safe. Say that: *put the state in the store, not in the process.*

*3.* Raw for 2 years in the LSM store: $460.8 "GB/day" times 730 = "336,384"$ GB
$= *336$ TB* $times 3$ replicas $= *"1,009"$ TB* of SSD.
Archive after 7 days: $460.8 times 7 times 3 = *9.7$ TB* of SSD, plus
$460.8 times 723 = "333,158"$ GB $= *333$ TB* of object storage at roughly one tenth the
price per GB and no replication to pay for separately.

LSM makes easy: "device D, any minute in the last 2 years", in milliseconds.
LSM makes hard: "average across 20 million devices for last March" --- a full cluster scan.
Columnar archive makes easy: exactly that fleet-wide scan, cheaply and in parallel.
Columnar archive makes hard: a point lookup of one device-minute, which now means opening
a large file.

*Decision: archive after 7 days.* The cost difference is roughly 100x on the expensive
tier, and the query the archive makes hard (a single old point lookup) is rare, while the
query it makes easy (fleet-wide history) is the one the LSM store could never serve. Keep
the last 7 days hot because that is where every interactive query lives.
]

#revision[
*The five questions for any schema*
+ What is the key --- stable, unique, unguessable, and sorted if it can be?
+ For every query, which index serves it? (If you cannot name one, the query is a scan.)
+ Which two writes can collide, and what stops them?
+ What is the biggest table in two years, and what do you do with the old rows?
+ Which business rule can become a database constraint?

*Numbers to memorise*
#table(columns: (auto, auto, auto, auto),
  [PK read, cached], [0.1--0.5 ms], [PK read, SSD], [1--5 ms],
  [scan 1M rows], [0.2--1 s], [8 KB page holds], [\~500 index entries],
  [B-tree height for 125M rows], [3], [index lookup], [height + 1 reads],
  [one SQL node, reads], [3--8k QPS], [one SQL node, writes], [200--2,000 TPS],
  [index is used below], [\~10% selectivity], [one locked row], [\~500 updates/s],
  [LSM write amplification], [10--30x], [Bloom bits at 1%], [\~10 per key],
)

*The formulas*
- $"selectivity" = "rows matched" \/ "rows total"$; index pays below \~10%
- $"B-tree height": 500^h >= "rows"$
- $"index lookup reads" = h + 1$; $"covering index reads" = h + "leaves"$
- $"OFFSET cost" = 25 times "page number"$; $"keyset cost" = "constant"$
- $"writes per insert" = 1 + "number of indexes"$
- $"cluster write rate" = "user writes" times "replication factor"$
- $"Bloom bits per key" = -1.44 log_2 p$
- $"max updates/s on one row" = 1 \/ "lock hold time"$

*Worked numbers from this chapter*
- 100,000 rows: scan 100,000 comparisons vs index 97 --- 1,031x
- 205 page reads become 5 with a covering index --- 41x
- helpdesk: 3M tickets/day $arrow.r$ 34.7/s, 50M page views $arrow.r$ 5,208 queries/s peak
- helpdesk storage: 26.4 GB/day $arrow.r$ 9.64 TB/yr $arrow.r$ 13.5 TB/yr with indexes
- 200 buyers, read-modify-write: qty goes 200 $arrow.r$ 199. Optimistic: 19,900 retries.
- telemetry: 20M devices/60 s $=$ 333,333 msg/s $times$ 8 $=$ 2.67M points/s
- telemetry: 230.4 B points/day, 460.8 GB/day compressed, 168.2 TB/yr, 504.6 TB with RF3
- nodes: $2.67"M" times 3 \/ 300"k" times 1.5 = 40$
- time-based partition key measured 8.00x hot; device-based 1.44x
- LSM measured write amplification 10.01x on 200,000 writes
- Bloom filters: 175 MB cluster-wide, 4.4 MB/node, 100x fewer probes on a miss

*Order of decisions --- never get this wrong*
normalise first $arrow.r$ de-normalise only for a snapshot, a constraint, or a *measured*
hot join. Write the source of truth in one transaction; everything else is derived.

*The four concurrency fixes*
+ atomic `UPDATE ... WHERE guard` --- first choice, always
+ `SELECT ... FOR UPDATE` in sorted key order --- when you must read, think, then write
+ version column + retry --- when conflicts are rare
+ unique constraint --- when the rule is "at most one may exist". Best of all.

*Sentences that score points*
- "Here is the query, and here is the index that serves it."
- "`tenant_id` leads every primary key, so sharding later is a routing change, not a migration."
- "That is a partial index --- 25x smaller, so it stays in RAM."
- "Keyset pagination, not OFFSET: constant cost and no duplicates, at the price of page jumping."
- "Replication factor 3 means the cluster really performs 8 million writes a second, not 2.67."
- "Store min, max, sum, count --- never avg. Averages do not compose."
- "I turn the business rule into a constraint, so racing code cannot break it."
]

]
