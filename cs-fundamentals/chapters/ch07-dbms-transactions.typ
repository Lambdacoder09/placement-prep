#import "../../shared/lib/style.typ": *

#chapter(num: 7, title: "DBMS: Transactions, Concurrency & Recovery", tagline: "What the database promises when two people press the button at the same moment")[

#section[The chapter in one page]

A transaction is a group of statements that must happen *all* or *none*. That is the whole
idea. Everything else in this chapter is the database keeping that promise while hundreds of
other transactions run at the same time, and while the power may cut at any instant.

Three questions get asked again and again in the technical round:

+ *What is ACID?* — say the four words, then give one line of what each one buys you.
+ *What are the isolation levels and which anomaly does each stop?* — the four-by-three table.
+ *How does the database survive a crash?* — write-ahead log, redo the winners, undo the losers.

If you can draw the isolation table from memory and explain write-ahead logging in five
sentences, you have cleared most of what a service company asks on this topic.

#formulas(title: "What you need to know")[

*ACID*
#table(columns: (auto, 1fr),
  [*A* — Atomicity], [All statements commit, or none do. Delivered by the *undo* log.],
  [*C* — Consistency], [The database moves from one legal state to another legal state.
    Constraints, keys and triggers are not violated at commit time.],
  [*I* — Isolation], [Concurrent transactions do not see each other's half-finished work.
    Delivered by *locks* or *MVCC*.],
  [*D* — Durability], [Once `COMMIT` returns, the change survives a power cut.
    Delivered by *forcing the log to disk*, not the data file.],
)

*Transaction states:* Active $arrow.r$ Partially Committed $arrow.r$ Committed. A failure at
any point sends it to Failed $arrow.r$ Aborted (rolled back).

*A schedule* is an interleaving of the operations of several transactions.
Two operations *conflict* when they are from different transactions, touch the same data
item, and at least one of them is a write. So: R-R never conflicts. R-W, W-R, W-W do.

*Serial schedule* — transactions run one after another, no overlap. Always correct, always slow.

*Conflict serialisable* — the schedule can be turned into some serial schedule by swapping
non-conflicting neighbouring operations. Test: build the *precedence graph*
(a node per transaction; an edge $T_i arrow.r T_j$ when an operation of $T_i$ conflicts with
a *later* operation of $T_j$). The schedule is conflict serialisable exactly when the graph
has *no cycle*.

*The four read anomalies*
#table(columns: (auto, 1fr),
  [*Dirty read*], [$T_1$ reads a row that $T_2$ wrote but has not committed. $T_2$ then aborts,
    so $T_1$ read a value that never existed.],
  [*Non-repeatable read*], [$T_1$ reads a row twice and gets two different values, because
    $T_2$ committed an `UPDATE` in between.],
  [*Phantom read*], [$T_1$ runs the same `WHERE` twice and the second run returns *extra rows*,
    because $T_2$ committed an `INSERT` that matches.],
  [*Lost update*], [$T_1$ and $T_2$ both read a value, both compute from it, both write.
    One of the two updates silently disappears.],
)

*Isolation levels* (the SQL standard)
#table(columns: (auto, auto, auto, auto),
  [*Level*], [*Dirty read*], [*Non-repeatable read*], [*Phantom*],
  [READ UNCOMMITTED], [possible], [possible], [possible],
  [READ COMMITTED],   [no], [possible], [possible],
  [REPEATABLE READ],  [no], [no], [possible],
  [SERIALIZABLE],     [no], [no], [no],
)

*Two-phase locking (2PL)* — every transaction has a *growing* phase (take locks, release
none) then a *shrinking* phase (release locks, take none). 2PL guarantees conflict
serialisability. It does *not* prevent deadlock.

*Strict 2PL* — all locks are held until `COMMIT` or `ROLLBACK`. This is what real databases
do. It also prevents cascading rollback.

*Lock compatibility*
#table(columns: 3,
  [], [*S held*], [*X held*],
  [*S wanted*], [yes], [no],
  [*X wanted*], [no], [no],
)

*Write-ahead logging (WAL), the two rules*
+ *Undo rule:* the log record for a change must reach disk *before* the changed data page does.
+ *Redo rule:* all log records of a transaction must reach disk *before* its `COMMIT` returns.

*Recovery in three passes*
+ *Analysis* — read the log from the last checkpoint, decide who committed (*winners*) and who
  did not (*losers*).
+ *Redo* — replay every logged change forward, winners and losers alike. This brings the disk
  back to the exact state at the moment of the crash.
+ *Undo* — walk backwards and reverse every change made by a loser.

*Deadlock in a DBMS* — a cycle in the *wait-for graph*. The database detects the cycle, picks
a *victim*, and rolls it back. The application must retry.
]

#subsection[The picture of a transaction's life]

#diagram(height: 3.8cm, caption: "Transaction states. There is no arrow out of Committed — that is what durability means.")[
  #dnode(0pt, 2.0cm, 2.4cm, 0.9cm, "Active")
  #dnode(3.6cm, 2.0cm, 3.4cm, 0.9cm, "Partially\ncommitted")
  #dnode(8.2cm, 2.0cm, 2.6cm, 0.9cm, "Committed", fill: rgb("#e3efe3"))
  #dnode(3.6cm, 0.1cm, 3.4cm, 0.9cm, "Failed", fill: rgb("#f7e8e8"))
  #dnode(8.2cm, 0.1cm, 2.6cm, 0.9cm, "Aborted", fill: rgb("#f7e8e8"))
  #darrow(2.45cm, 2.45cm, 3.55cm, 2.45cm, label: "last stmt")
  #darrow(7.05cm, 2.45cm, 8.15cm, 2.45cm, label: "log forced")
  #darrow(1.2cm, 2.95cm, 3.55cm, 0.75cm, label: "error")
  #darrow(5.3cm, 1.95cm, 5.3cm, 1.05cm, label: "crash")
  #darrow(7.05cm, 0.55cm, 8.15cm, 0.55cm, label: "undo done")
]

#trap[
"Partially committed" means the last statement has run but the log has *not* been forced to
disk yet. A crash here still loses the transaction. `COMMIT` returns only after the log write
returns. That single `fsync` is the whole of durability.
]

#section[Warm-up — the mechanics]
#tier-header(0)

#ex(1, tier: 0)[
A bank transfer moves #sym.dollar 5000 from `A100` to `B200`. Write it as a transaction and
say which ACID letter each part relies on.

#sol[
#code(lang: "sql", caption: "The canonical transaction")[
```sql
BEGIN;
  UPDATE accounts SET balance = balance - 5000 WHERE acc_no = 'A100';
  UPDATE accounts SET balance = balance + 5000 WHERE acc_no = 'B200';
COMMIT;
```
]
+ *Atomicity* — if the second `UPDATE` fails, the first is undone. Money never vanishes.
+ *Consistency* — the sum of all balances is the same before and after. A `CHECK (balance >= 0)`
  constraint is enforced at commit.
+ *Isolation* — a report running at the same time does not see the money in neither account
  or in both accounts.
+ *Durability* — after `COMMIT` returns, a power cut cannot undo the transfer.

#ans[atomicity for the pair, durability for the `COMMIT`]
]
]

#ex(2, tier: 0)[
Two ATM sessions read the same balance of 1000, then one withdraws 100 and the other
withdraws 200. What is the final balance if nothing stops them, and what is the name of
this bug?

#sol[
#code(lang: "js", caption: "lost-update, run with node")[
```js
let balance = 1000;
const readBalance  = ()  => balance;
const writeBalance = (v) => { balance = v; };

const t1 = readBalance();      // T1 reads 1000
const t2 = readBalance();      // T2 reads 1000
writeBalance(t1 - 100);        // T1 writes 900
writeBalance(t2 - 200);        // T2 writes 800

console.log("final =", balance, " expected = 700");
// output:  final = 800  expected = 700
```
]
$T_1$'s withdrawal of 100 is gone. The bank lost 100 rupees.

#ans[final balance 800; the bug is a *lost update*]

The fix is one line, and it is the answer the interviewer wants:
#code(lang: "sql", caption: "let the database do the arithmetic")[
```sql
UPDATE accounts SET balance = balance - 100 WHERE acc_no = 'A100';
```
]
This takes an exclusive lock on the row and reads-and-writes inside the lock, so the two
withdrawals queue up instead of overwriting each other.
]
]

#ex(3, tier: 0)[
List the four anomalies in order of how badly they break things, and give the smallest
isolation level that stops each one.

#sol[
#table(columns: (auto, 1fr, auto),
  [*Anomaly*], [*One-line meaning*], [*Stopped from*],
  [Dirty read], [you read data that was never committed], [READ COMMITTED],
  [Lost update], [two blind read-modify-writes, one disappears], [REPEATABLE READ],
  [Non-repeatable read], [same row, same transaction, two different values], [REPEATABLE READ],
  [Phantom read], [same `WHERE`, second run has extra rows], [SERIALIZABLE],
)
#ans[dirty $arrow.r$ lost update $arrow.r$ non-repeatable $arrow.r$ phantom]
]
]

#ex(4, tier: 0)[
Which pairs of operations conflict? `R1(A) R2(A)`, `R1(A) W2(A)`, `W1(A) W2(A)`, `W1(A) R1(A)`,
`W1(A) W2(B)`.

#sol[
The rule has three parts: *different transactions*, *same item*, *at least one write*.

#table(columns: (auto, auto, auto, auto, auto),
  [*Pair*], [*Different txn?*], [*Same item?*], [*A write?*], [*Conflict*],
  [`R1(A) R2(A)`], [yes], [yes], [no], [no],
  [`R1(A) W2(A)`], [yes], [yes], [yes], [*yes*],
  [`W1(A) W2(A)`], [yes], [yes], [yes], [*yes*],
  [`W1(A) R1(A)`], [no], [yes], [yes], [no],
  [`W1(A) W2(B)`], [yes], [no], [yes], [no],
)
#ans[only `R1(A) W2(A)` and `W1(A) W2(A)`]
]
]

#ex(5, tier: 0)[
Say in one sentence each: what is a shared lock, an exclusive lock, and why is
`S` compatible with `S` but not with `X`?

#sol[
- *Shared (S)* — "I am reading this; others may read it too, nobody may change it."
- *Exclusive (X)* — "I am changing this; nobody else may read it or change it."
- Two readers cannot upset each other, because neither changes anything. A writer must be
  alone, because a reader who saw the row half-changed would read garbage.

#ans[S-S compatible; every other combination blocks]
]
]

#ex(6, tier: 0)[
`ROLLBACK` is issued after a `COMMIT`. What happens?

#sol[
Nothing. The `COMMIT` ended the transaction. The `ROLLBACK` starts a new, empty transaction
and ends it. There is no way back.

#ans[no effect — a committed transaction cannot be rolled back]
]
#trap[
Students often say "ROLLBACK undoes the last statement". It undoes *everything since the last
`BEGIN` or `COMMIT`* — which may be a hundred statements — and nothing before that.
]
]

#ex(7, tier: 0)[
What does a `SAVEPOINT` give you that `ROLLBACK` does not?

#sol[
A partial undo. You can throw away part of a transaction and keep the rest.

#code(lang: "sql", caption: "keep the order, drop the bad line item")[
```sql
BEGIN;
  INSERT INTO orders (order_id, cust_id, amount) VALUES (9001, 42, 1200);
  SAVEPOINT after_order;
  INSERT INTO order_items (order_id, sku, qty) VALUES (9001, 'SKU-7', -3);
  ROLLBACK TO SAVEPOINT after_order;   -- the bad item is gone
  INSERT INTO order_items (order_id, sku, qty) VALUES (9001, 'SKU-7', 3);
COMMIT;                                -- order + good item are saved together
```
]
#ans[a named point inside the transaction you can rewind to, without losing the whole transaction]
]
]

#practice(tier: 0, time: "8 minutes")[
+ Name the ACID letter that the *undo* log delivers.
+ Name the ACID letter that the `fsync` of the log delivers.
+ Does `R2(B) R1(B)` conflict?
+ A transaction is in the Failed state. Which state comes next?
+ Which isolation level allows a dirty read?
+ True or false: `SERIALIZABLE` means the transactions actually run one at a time.
+ Two transactions both hold an S lock on row 7. $T_1$ now asks for X on row 7. What happens?
]

#key[
1. Atomicity. #h(10pt) 2. Durability. #h(10pt) 3. No — both are reads.
#h(10pt) 4. Aborted. #h(10pt) 5. READ UNCOMMITTED only.
#h(10pt) 6. False — it means the *result* is the same as some serial order; they still overlap.
#h(10pt) 7. $T_1$ waits for $T_2$ to release its S lock. If $T_2$ also asks for X, that is a
deadlock (this exact pattern is called *lock upgrade deadlock*).
]

#section[Tier 1 — the questions a service company asks]
#tier-header(1)

#ex(8, tier: 1, asked: "TCS NQT · pattern")[
Explain the difference between a *dirty read* and a *non-repeatable read* with a two-session
example.

#sol[
*Dirty read* — you read something that was never committed.

#code(lang: "sql", caption: "dirty read (needs READ UNCOMMITTED)")[
```sql
-- session 2                              -- session 1
BEGIN;
UPDATE accounts SET balance = 9999
  WHERE acc_no = 'A100';
                                 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
                                          BEGIN;
                                          SELECT balance FROM accounts
                                            WHERE acc_no = 'A100';   -- reads 9999
ROLLBACK;   -- the 9999 never existed
                                          -- session 1 acted on a fake number
```
]

*Non-repeatable read* — you read something twice; both values were committed, but they differ.

#code(lang: "sql", caption: "non-repeatable read (happens at READ COMMITTED)")[
```sql
-- session 1                              -- session 2
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
SELECT balance FROM accounts
  WHERE acc_no = 'A100';   -- 5000
                                          BEGIN;
                                          UPDATE accounts SET balance = 3000
                                            WHERE acc_no = 'A100';
                                          COMMIT;
SELECT balance FROM accounts
  WHERE acc_no = 'A100';   -- 3000   <-- different!
COMMIT;
```
]

#ans[dirty read = uncommitted data; non-repeatable read = committed data that changed under you]
]
#trap[
A very common wrong answer: "dirty read means reading old data". No. Old committed data is
perfectly clean — that is exactly what a snapshot gives you. Dirty means *uncommitted*.
]
]

#ex(9, tier: 1, asked: "Infosys · pattern")[
Is this schedule conflict serialisable? Draw the precedence graph.

`R1(A) W1(A) R2(A) W2(A) R2(B) W2(B) R1(B) W1(B)`

#sol[
Step 1 — find conflicting pairs where the *earlier* one belongs to a different transaction.

#table(columns: (auto, auto, auto),
  [*Earlier op*], [*Later op*], [*Edge*],
  [`W1(A)`], [`R2(A)`], [$T_1 arrow.r T_2$],
  [`W1(A)`], [`W2(A)`], [$T_1 arrow.r T_2$],
  [`R1(A)`], [`W2(A)`], [$T_1 arrow.r T_2$],
  [`W2(B)`], [`R1(B)`], [$T_2 arrow.r T_1$],
  [`R2(B)`], [`W1(B)`], [$T_2 arrow.r T_1$],
)

Step 2 — the graph has $T_1 arrow.r T_2$ and $T_2 arrow.r T_1$. That is a cycle of length 2.

#code(lang: "js", caption: "checker, run with node")[
```js
function precedenceGraph(schedule) {
  const edges = new Set();
  for (let i = 0; i < schedule.length; i++) {
    for (let j = i + 1; j < schedule.length; j++) {
      const a = schedule[i], b = schedule[j];
      if (a.txn === b.txn) continue;          // same transaction: not a conflict
      if (a.item !== b.item) continue;        // different item: not a conflict
      if (a.op === "R" && b.op === "R") continue;   // read-read: not a conflict
      edges.add(a.txn + "->" + b.txn);
    }
  }
  return [...edges];
}

function hasCycle(edges) {
  const g = new Map();
  for (const e of edges) {
    const [u, v] = e.split("->");
    if (!g.has(u)) g.set(u, []);
    g.get(u).push(v);
  }
  const state = new Map();                    // 1 = on stack, 2 = done
  const dfs = (u) => {
    state.set(u, 1);
    for (const v of g.get(u) ?? []) {
      if (state.get(v) === 1) return true;    // back edge -> cycle
      if (!state.has(v) && dfs(v)) return true;
    }
    state.set(u, 2);
    return false;
  };
  for (const u of g.keys()) if (!state.has(u) && dfs(u)) return true;
  return false;
}
```
]
Running it on this schedule prints
`S1 edges: T1->T2 , T2->T1 | cycle? true | NOT conflict serialisable`,
and on the serial order `R1(A) W1(A) R1(B) W1(B) R2(A) W2(A) R2(B) W2(B)` it prints
`S2 edges: T1->T2 | cycle? false | conflict serialisable`.

#ans[not conflict serialisable — the precedence graph has the cycle $T_1 arrow.r T_2 arrow.r T_1$]
]
#trick[
You never need to list every edge. Stop the moment you have both $T_i arrow.r T_j$ and
$T_j arrow.r T_i$. In a two-transaction schedule that is the only cycle possible, so the test
is: *does $T_1$ beat $T_2$ on one item and lose to it on another?* If yes, not serialisable.
]
]

#ex(10, tier: 1, asked: "Wipro · pattern")[
State the two-phase locking protocol and show why it forces serialisability. Then show a 2PL
schedule that still deadlocks.

#sol[
*The protocol.* Split every transaction's lifetime at one instant called the *lock point*.
Before it, the transaction may only *acquire* locks. After it, it may only *release* them.

#diagram(height: 4.6cm, caption: "Two-phase locking. The lock point is the moment the transaction holds the most locks.")[
  #dnode(0pt, 0pt, 15cm, 0.75cm, "Strict 2PL: the whole shrinking phase happens at once, at COMMIT or ROLLBACK.", fill: rgb("#f3f8f4"))
  #dnode(0pt, 1.3cm, 6cm, 1.4cm, "PHASE 1 — GROWING\nacquire locks, release none")
  #dnode(6.4cm, 1.3cm, 2.3cm, 1.4cm, "LOCK\nPOINT", fill: rgb("#f7efe4"))
  #dnode(9.1cm, 1.3cm, 5.9cm, 1.4cm, "PHASE 2 — SHRINKING\nrelease locks, acquire none")
  #darrow(6.05cm, 2.0cm, 6.35cm, 2.0cm)
  #darrow(8.75cm, 2.0cm, 9.05cm, 2.0cm)
  #darrow(0pt, 3.3cm, 15cm, 3.3cm, label: "time")
]

*Why it works.* Order the transactions by their lock points. If $T_i$'s lock point comes
before $T_j$'s, then every conflict between them must run $T_i$ first: to conflict, $T_j$ needs
a lock that $T_i$ holds, and $T_i$ only lets go after its own lock point. So the lock-point
order *is* an equivalent serial order, and the precedence graph cannot have a cycle.

*But it deadlocks.*
#code(lang: "sql", caption: "two sessions, opposite order, guaranteed deadlock")[
```sql
-- session 1                                -- session 2
BEGIN;                                      BEGIN;
UPDATE seats SET held = 1 WHERE id = 1;     UPDATE seats SET held = 1 WHERE id = 2;
-- now holds X on row 1                     -- now holds X on row 2
UPDATE seats SET held = 1 WHERE id = 2;     UPDATE seats SET held = 1 WHERE id = 1;
-- waits for session 2                      -- waits for session 1   => DEADLOCK
```
]
Both obeyed 2PL perfectly. 2PL is about *correctness*, not about *liveness*.

#ans[growing then shrinking; it guarantees conflict serialisability but not freedom from deadlock]
]
#trap[
The single most common wrong answer on this topic is "2PL prevents deadlock." It *causes*
deadlocks. What prevents deadlock is a lock *ordering* rule in your application: always touch
rows in increasing primary-key order. Rewriting the example above as
`WHERE id IN (1,2) ORDER BY id` makes the deadlock impossible.
]
]

#ex(11, tier: 1, asked: "Capgemini · pattern")[
What is *strict* 2PL and what extra problem does it solve?

#sol[
Strict 2PL holds all *exclusive* locks until the transaction commits or aborts. Rigorous 2PL
holds *all* locks (shared too) until then.

The extra problem it solves is *cascading rollback*.

Without strictness: $T_1$ writes row A, releases the X lock, keeps running. $T_2$ reads A.
$T_3$ reads what $T_2$ wrote. Now $T_1$ aborts — so $T_2$ read dirty data and must abort, so
$T_3$ must abort. One failure knocks over a chain.

With strict 2PL, nobody can read $T_1$'s row until $T_1$ has committed, so there is nothing to
cascade.

#ans[locks held until commit; it makes the schedule *recoverable* and *cascadeless*]
]
#note[
Three words you may be asked to order, easiest to strictest:
*recoverable* (a transaction commits only after every transaction it read from has committed)
$arrow.r$ *cascadeless* (you may only read committed data) $arrow.r$ *strict* (you may neither
read nor overwrite uncommitted data). Strict implies cascadeless implies recoverable.
]
]

#ex(12, tier: 1, asked: "Accenture · pattern")[
Explain write-ahead logging. Why does `COMMIT` not write the data pages?

#sol[
#diagram(height: 4.8cm, caption: "WAL: the log goes to disk at COMMIT; the data page goes whenever the buffer manager feels like it.")[
  #dnode(0pt, 1.5cm, 2.8cm, 1.1cm, "T1 changes\nrow on page P1")
  #dnode(4.4cm, 0.1cm, 3.8cm, 1.1cm, "Log buffer\nLSN 20: P1 50→40")
  #dnode(4.4cm, 2.8cm, 3.8cm, 1.1cm, "Buffer pool\nP1 dirty, = 40")
  #dnode(10.6cm, 0.1cm, 4.2cm, 1.1cm, "LOG FILE on disk", fill: rgb("#e3efe3"))
  #dnode(10.6cm, 2.8cm, 4.2cm, 1.1cm, "DATA FILE on disk")
  #darrow(2.85cm, 1.9cm, 4.35cm, 1.1cm)
  #darrow(2.85cm, 2.2cm, 4.35cm, 3.0cm)
  #darrow(8.25cm, 0.65cm, 10.55cm, 0.65cm, label: "fsync at COMMIT")
  #darrow(8.25cm, 3.35cm, 10.55cm, 3.35cm, label: "later, lazily")
]

The log is a single file written *sequentially*. The data pages are scattered all over the
disk. Forcing one sequential 200-byte append is cheap; forcing twenty random 8 KB pages is not.
So the database makes durability cheap by writing the *promise* (the log) and letting the
*payment* (the data page) happen whenever it is convenient.

The two rules that make this safe:
+ Never write a data page to disk before its log record is on disk. (Otherwise a crash leaves
  a change on disk with no way to undo it.)
+ Never return from `COMMIT` before all of that transaction's log records are on disk.
  (Otherwise a crash leaves a promise you cannot keep.)

#ans[log first, sequentially, and force it at commit; data pages follow lazily]
]
#trap[
"Durability means the row is in the table file on disk." It is not. Right after `COMMIT`
returns, the data file may still hold the *old* value. The new value exists only in the log
and in RAM. Recovery replays the log to put it in the data file. Say *log*, not *data file*.
]
]

#ex(13, tier: 1, asked: "Cognizant · pattern")[
The system crashes. The log since the last checkpoint is below. Which transactions are redone,
which are undone, and what is on page `P1` afterwards?

#table(columns: (auto, auto, auto, auto, auto, auto),
  [*LSN*], [*Type*], [*Txn*], [*Page*], [*Before*], [*After*],
  [10], [BEGIN],  [T1], [], [], [],
  [20], [UPDATE], [T1], [P1], [50], [40],
  [30], [BEGIN],  [T2], [], [], [],
  [40], [UPDATE], [T2], [P2], [70], [90],
  [50], [COMMIT], [T1], [], [], [],
  [60], [BEGIN],  [T3], [], [], [],
  [70], [UPDATE], [T3], [P1], [40], [15],
)
At the moment of the crash the disk happened to hold `P1 = 15` and `P2 = 90`.

#sol[
*Analysis.* Walk forward. A transaction with a `COMMIT` is a *winner*; anything still open at
the end is a *loser*.
- T1 has `COMMIT` at LSN 50 $arrow.r$ winner.
- T2 and T3 have no `COMMIT` $arrow.r$ losers.

*Redo.* Replay *every* update forward, winners and losers alike. This is called *repeating
history*. After redo: `P1 = 15`, `P2 = 90` — the exact state at the crash.

Why redo a loser? Because redo must not have to think. It sets the disk to a known state so
that undo's "before" values are guaranteed to be correct.

*Undo.* Walk the log *backwards*, reversing only the losers.
- LSN 70, T3 (loser): `P1` $arrow.l$ 40.
- LSN 40, T2 (loser): `P2` $arrow.l$ 70.
- LSN 20, T1 (winner): leave it. `P1` stays 40.

#code(lang: "js", caption: "the whole recovery in 15 lines, run with node")[
```js
const winners = new Set(), losers = new Set();
for (const r of log) {
  if (r.type === "BEGIN") losers.add(r.txn);
  if (r.type === "COMMIT" || r.type === "ABORT") {
    losers.delete(r.txn); winners.add(r.txn);
  }
}
const page = { P1: 15, P2: 90 };                                  // disk at restart

for (const r of log)
  if (r.type === "UPDATE") page[r.page] = r.after;                // REDO everything

for (const r of [...log].reverse())
  if (r.type === "UPDATE" && losers.has(r.txn)) page[r.page] = r.before;  // UNDO
```
]
It prints
`winners: T1 | losers: T2,T3`, then
`after REDO {"P1":15,"P2":90}`, then
`after UNDO {"P1":40,"P2":70}`.

#ans[redo all of T1, T2, T3; undo T2 and T3; final `P1 = 40`, `P2 = 70`]
]
]

#ex(14, tier: 1, asked: "TCS Digital · pattern")[
What is a checkpoint and why does recovery get faster with one?

#sol[
A checkpoint is a log record that says: *at this instant, here is the list of transactions
still running, and here is the list of dirty pages in the buffer pool.* Usually the database
also flushes some dirty pages at the same time.

Without a checkpoint, recovery has to read the log from the very beginning of time. With one,
it starts at the last checkpoint record.

#table(columns: (auto, 1fr),
  [*Sharp checkpoint*], [Stop accepting new work, finish or roll back everything running, flush
    every dirty page, then write the record. Simple, but the database freezes for seconds.],
  [*Fuzzy checkpoint*], [Write the record and keep going; flush dirty pages in the background.
    No freeze. Recovery must start a little earlier in the log — at the oldest LSN that is
    still dirty. This is what real systems use.],
)
#ans[a restart point in the log; recovery reads from the last checkpoint instead of from the start]
]
]

#ex(15, tier: 1, asked: "Infosys · pattern")[
Compare `DELETE`, `TRUNCATE` and `DROP` on transactions, logging and speed.

#sol[
#table(columns: (auto, auto, auto, auto),
  [], [*`DELETE FROM t`*], [*`TRUNCATE TABLE t`*], [*`DROP TABLE t`*],
  [Kind], [DML], [DDL], [DDL],
  [What goes], [rows], [all rows], [rows + the table itself],
  [`WHERE`], [yes], [no], [no],
  [Logging], [one log record per row], [deallocates pages; almost no row logging], [same],
  [Speed on 10M rows], [slow], [fast], [fast],
  [Triggers fire], [yes (`ON DELETE`)], [no], [no],
  [Identity counter], [keeps counting], [usually reset to 1], [gone with the table],
  [Rollback], [always], [*depends on the engine*], [*depends on the engine*],
)

#ans[`DELETE` is row-by-row DML; `TRUNCATE` and `DROP` are DDL that drop storage wholesale]
]
#trap[
The rollback row is where most students lose the mark, because the honest answer is
"it depends", and you should say so:
- *PostgreSQL* — `TRUNCATE` and even `DROP TABLE` are transactional. `BEGIN; TRUNCATE t; ROLLBACK;`
  brings the rows back.
- *MySQL (InnoDB)* and *Oracle* — DDL causes an *implicit commit*. The rows are gone. There is
  nothing to roll back to.
Saying "TRUNCATE can never be rolled back" is a half-truth. Say which engine you mean.
]
]

#ex(16, tier: 1, asked: "Wipro · pattern")[
Your Node service does a read, some arithmetic, and a write. Show the wrong way and two right
ways to make it safe under concurrency.

#sol[
*The wrong way* — read, compute in the application, write back.
#code(lang: "sql", caption: "broken: a lost update waiting to happen")[
```sql
SELECT stock FROM inventory WHERE sku = 'SKU-7';   -- app reads 5
-- ... app computes 5 - 1 = 4 ...
UPDATE inventory SET stock = 4 WHERE sku = 'SKU-7';
```
]

*Right way 1 — pessimistic.* Take the lock while reading.
#code(lang: "sql", caption: "SELECT ... FOR UPDATE")[
```sql
BEGIN;
  SELECT stock FROM inventory WHERE sku = 'SKU-7' FOR UPDATE;  -- X lock; others wait
  UPDATE inventory SET stock = stock - 1 WHERE sku = 'SKU-7' AND stock >= 1;
COMMIT;
```
]

*Right way 2 — optimistic.* No lock. Carry a version number and check it on the way out.
#code(lang: "sql", caption: "compare-and-set on a version column")[
```sql
SELECT stock, version FROM inventory WHERE sku = 'SKU-7';    -- stock 5, version 12

UPDATE inventory
   SET stock = 4, version = 13
 WHERE sku = 'SKU-7' AND version = 12;    -- 0 rows updated => retry
```
]

#code(lang: "js", caption: "optimistic control, run with node")[
```js
const row = { id: 7, seats: 2, version: 1 };
const read  = () => ({ ...row });                       // SELECT ...
const write = (snap, newSeats) => {                 // UPDATE ... WHERE version = ?
  if (row.version !== snap.version) return 0;       // 0 rows updated: somebody won
  row.seats = newSeats; row.version++; return 1;
};

const t1 = read();                 // T1 reads {seats: 2, version: 1}
const t2 = read();                 // T2 reads  {seats: 2, version: 1}
console.log("T2 rows =", write(t2, t2.seats - 1));   // 1  -> version becomes 2
console.log("T1 rows =", write(t1, t1.seats - 1));   // 0  -> stale, rejected
const t1b = read();                                  // re-read
console.log("T1 retry rows =", write(t1b, t1b.seats - 1));   // 1
```
]
Output: `T2 rows = 1`, `T1 rows = 0`, `T1 retry rows = 1`, and the row ends at
`{"id":7,"seats":0,"version":3}`. No update was lost.

#table(columns: (auto, 1fr, 1fr),
  [], [*Pessimistic (`FOR UPDATE`)*], [*Optimistic (version column)*],
  [Cost when there is no clash], [a lock, still paid for], [nothing],
  [Cost when there is a clash], [waiting], [a full retry],
  [Best for], [hot rows, short transactions], [rare clashes, long think time],
  [Danger], [deadlock, lock convoys], [livelock if everyone retries at once],
)
#ans[never compute the new value in the application without either a lock or a version check]
]
]

#practice(tier: 1, time: "20 minutes")[
+ Name the isolation level that permits phantoms but not non-repeatable reads.
+ Is `R1(X) W2(X) W1(X)` conflict serialisable? Show the graph.
+ Give one reason a database prefers a sequential log write to a random data-page write.
+ A transaction reads a row written by another transaction that has not committed. Which
  property of the schedule has been broken?
+ Write the SQL that increments a counter safely, in one statement.
+ Which of `DELETE`, `TRUNCATE`, `DROP` fires an `ON DELETE` trigger?
+ In strict 2PL, when exactly does the shrinking phase happen?
+ A checkpoint record lists 3 active transactions. Two of them appear with `COMMIT` later in
  the log. During recovery, how many are losers?
]

#key[
1. REPEATABLE READ. #h(8pt)
2. Edges: `R1(X)` before `W2(X)` gives $T_1 arrow.r T_2$; `W2(X)` before `W1(X)` gives
$T_2 arrow.r T_1$. Cycle $arrow.r$ *not* conflict serialisable. #h(8pt)
3. One `fsync` on an append-only file, no seeking; a dirty-page flush may touch dozens of
scattered 8 KB pages. #h(8pt)
4. It is not *cascadeless* (and possibly not recoverable). #h(8pt)
5. `UPDATE counters SET n = n + 1 WHERE name = 'hits';` #h(8pt)
6. `DELETE` only. #h(8pt)
7. All at once, at `COMMIT` or `ROLLBACK`. #h(8pt)
8. One — plus any transaction that started after the checkpoint and never committed.
]

#section[Tier 2 — applied, business-flavoured]
#tier-header(2)

#ex(17, tier: 2, asked: "Grab · pattern")[
A ride-booking service assigns drivers. Two dispatchers run the same code at `REPEATABLE READ`:

#code(lang: "sql", caption: "both sessions, same code, same second")[
```sql
BEGIN;
SELECT count(*) AS free FROM drivers WHERE zone = 'BKK-3' AND state = 'FREE';  -- 2
-- application: "free >= 1, so I may take one"
UPDATE drivers SET state = 'BUSY' WHERE driver_id = ?  AND state = 'FREE';
COMMIT;
```
]
Dispatcher A takes driver 11, dispatcher B takes driver 12. The business rule is "never drop
below one free driver in a zone". It is now broken. Why did `REPEATABLE READ` not stop this,
and what are the three fixes?

#sol[
*Why it happened.* This is *write skew*. Both transactions read the same set of rows, both
made a decision from that read, and then each wrote a *different* row. There is no
read-write conflict on the same row, so snapshot-based `REPEATABLE READ` sees nothing wrong.
Each transaction on its own is fine; the pair is not.

#table(columns: (auto, 1fr),
  [Lost update], [two transactions write *the same* row],
  [*Write skew*], [two transactions write *different* rows after reading the same set],
)

*Fix 1 — raise the level to `SERIALIZABLE`.* On PostgreSQL this is Serialisable Snapshot
Isolation: the engine watches the read-write dependencies and aborts one transaction with a
serialisation failure. Your code must catch that error and retry.

*Fix 2 — materialise the conflict.* Give the *zone* a row and lock it, so the two
transactions collide on something real.
#code(lang: "sql", caption: "lock the zone, not the driver")[
```sql
BEGIN;
  SELECT zone_id FROM zones WHERE zone_id = 'BKK-3' FOR UPDATE;  -- serialises them
  SELECT count(*) FROM drivers WHERE zone = 'BKK-3' AND state = 'FREE';
  UPDATE drivers SET state = 'BUSY' WHERE driver_id = 11 AND state = 'FREE';
COMMIT;
```
]

*Fix 3 — make the rule a single atomic statement,* so there is no gap between the check and
the write.
#code(lang: "sql", caption: "check and write in one statement")[
```sql
UPDATE drivers
   SET state = 'BUSY'
 WHERE driver_id = 11
   AND state = 'FREE'
   AND (SELECT count(*) FROM drivers WHERE zone = 'BKK-3' AND state = 'FREE') > 1;
-- 0 rows updated => the rule would have been broken; the app sees it and stops
```
]

#ans[write skew; fix with `SERIALIZABLE` + retry, a lock on a shared row, or one atomic statement]
]
#trap[
"`REPEATABLE READ` gives me a consistent snapshot, so my check is safe." A snapshot makes your
*read* consistent. It says nothing about whether the world still agrees with your read at the
moment you *write*. Every check-then-act pattern needs a lock, a unique constraint, or a
serialisable retry.
]
]

#ex(18, tier: 2, asked: "Shopee · pattern")[
A flash sale has 100 units. 5000 requests arrive in two seconds. The naive code uses
`SELECT ... FOR UPDATE` on the single stock row. Latency explodes. Explain why, and give two
designs that survive.

#sol[
*Why it explodes.* Every request needs the X lock on *one* row. That row becomes a queue. If
each transaction holds the lock for 4 ms (network round trip + commit `fsync`), the row can
serve at most 250 requests per second, no matter how many CPUs you have. 5000 requests take
20 seconds. Everything behind the queue times out, and the timeouts trigger retries, which
lengthen the queue. This is a *hot row*.

$ "max throughput" = 1 / "lock hold time" = 1/(4 "ms") = 250 "per second" $

*Design 1 — split the row into buckets.* Turn one hot row into $k$ warm rows.
#code(lang: "sql", caption: "sharded counter, k = 20 buckets of 5 units each")[
```sql
-- each request picks a random bucket, so the lock traffic spreads over 20 rows
UPDATE stock_bucket
   SET remaining = remaining - 1
 WHERE sku = 'FLASH-1' AND bucket = ? AND remaining >= 1;
-- 0 rows updated => that bucket is empty; try another bucket, then give up
```
]
Throughput becomes $20 times 250 = 5000$ per second. The cost: a bucket can be empty while
others are not, so you must sweep a few buckets before declaring "sold out".

*Design 2 — do not use the database for the counter at all.* Decrement an atomic counter in
Redis (`DECR` returns the new value in one round trip, no transaction, no `fsync`). Only the
requests that get a value $>= 0$ go on to write a durable order row. The database now sees
100 inserts instead of 5000 lock waits.

#table(columns: (auto, 1fr, 1fr),
  [], [*Bucket split*], [*External counter*],
  [Durability of the count], [full ACID], [weaker; needs reconciliation],
  [Extra system], [none], [Redis],
  [Failure mode], [uneven buckets], [counter and orders drift apart],
)

#ans[one row is a serial queue capped at $1\/t_"hold"$; shard the row, or move the counter out]
]
]

#ex(19, tier: 2, asked: "DBS · pattern")[
A nightly settlement job runs for 40 minutes at `SERIALIZABLE` and reads three large tables.
It aborts almost every night with a serialisation failure. The report it produces does not
need to be up to the second. What do you change?

#sol[
A long read-only transaction at `SERIALIZABLE` has a huge read set. The chance that *someone*
creates a conflicting dependency over 40 minutes is close to 1.

Three changes, cheapest first:

+ *Declare it read-only.* `BEGIN TRANSACTION READ ONLY;` — the engine knows the transaction
  will never write, so it can skip a large part of the conflict tracking. On PostgreSQL,
  `READ ONLY DEFERRABLE` at `SERIALIZABLE` waits for a safe snapshot and is then *guaranteed*
  never to abort.
+ *Drop to `REPEATABLE READ`.* A read-only transaction at `REPEATABLE READ` gets a single
  consistent snapshot of all three tables. Write skew cannot happen because it never writes.
  For a report this is exactly right.
+ *Run it against a read replica* so it competes with nothing. Accept the replication lag —
  the report already tolerates it.

#code(lang: "sql", caption: "the fix")[
```sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ READ ONLY;
  SELECT ... FROM ledger  ...;
  SELECT ... FROM fees    ...;
  SELECT ... FROM fx_rate ...;   -- all three see the same instant in time
COMMIT;
```
]
#ans[read-only + `REPEATABLE READ` snapshot (or a replica); `SERIALIZABLE` buys nothing for a
transaction that never writes]
]
#note[
Keep this sentence ready: *the cost of an isolation level is paid in aborts and waiting, and
you should buy only the level your invariant actually needs.* A read-only report needs a
consistent snapshot. It does not need serialisability.
]
]

#ex(20, tier: 2, asked: "Agoda · pattern")[
A booking API writes to the `bookings` table and then calls a payment provider over HTTP.
The developer puts the HTTP call inside the transaction so that "if payment fails, the booking
rolls back". Criticise this and give the standard alternative.

#sol[
*What is wrong.*
+ The transaction now holds locks for the whole duration of a network call — 200 ms on a good
  day, 30 s on a bad one. Lock hold time is throughput's denominator (Example 18).
+ The connection pool drains. Each in-flight payment occupies one database connection doing
  nothing.
+ It does not even work. If the payment succeeds and the `COMMIT` then fails, you have charged
  a customer with no booking. Two systems cannot be made atomic by wrapping one inside the
  other's transaction.

*The standard alternative — the outbox pattern.*
#code(lang: "sql", caption: "transaction 1: local, short, atomic")[
```sql
BEGIN;
  INSERT INTO bookings (booking_id, user_id, room_id, state)
       VALUES ('B-77', 42, 'R-9', 'PENDING_PAYMENT');
  INSERT INTO outbox (id, topic, payload, sent)
       VALUES ('B-77', 'charge', '{"booking":"B-77","amount":4200}', false);
COMMIT;          -- both rows or neither: one database, real atomicity
```
]
A separate worker reads unsent outbox rows, calls the payment provider, and then:
#code(lang: "sql", caption: "transaction 2: also local and short")[
```sql
BEGIN;
  UPDATE bookings SET state = 'CONFIRMED' WHERE booking_id = 'B-77';
  UPDATE outbox   SET sent  = true        WHERE id = 'B-77';
COMMIT;
```
]
The worker may crash after charging and before this update, so it will retry — which means the
payment call must be *idempotent*. Send `booking_id` as the provider's idempotency key and the
second charge is a no-op.

#ans[never hold a transaction across a network call; write an outbox row atomically and let an
idempotent worker do the remote call]
]
#trap[
Someone will suggest two-phase commit (2PC) here. Name it, then say why it is rarely used:
2PC blocks. If the coordinator dies between "prepare" and "commit", every participant sits
holding locks until a human intervenes. Most teams choose an outbox plus idempotency and
accept *eventual* consistency instead.
]
]

#ex(21, tier: 2, asked: "GIC · pattern")[
Explain MVCC. Given the version list below and a transaction whose snapshot is "all
transactions with id $<= 103$ that have committed", which rows does it see?

#table(columns: 4,
  [*row id*], [*value*], [*xmin (created by)*], [*xmax (deleted by)*],
  [1], [A], [100], [105],
  [1], [B], [105], [—],
  [2], [C], [102], [—],
)

#sol[
*MVCC in one paragraph.* An `UPDATE` does not overwrite. It writes a *new version* of the row
and marks the old version as dead from that transaction onwards. Every row version carries
`xmin` (the transaction that created it) and `xmax` (the transaction that killed it). A reader
takes a *snapshot* — a rule for which transaction ids count as "already committed for me" —
and then sees exactly the versions that were alive under that rule. Readers therefore never
block writers, and writers never block readers.

*Visibility test for a version:*
+ `xmin` must be committed, and must be inside my snapshot. Otherwise I cannot see it.
+ If `xmax` is empty, or `xmax` is not committed, or `xmax` is outside my snapshot, the version
  is still alive for me.
+ Otherwise the version is dead for me.

#code(lang: "js", caption: "visibility rule, run with node")[
```js
function visible(v, snapshotXid, running, committed) {
  if (!committed.has(v.xmin)) return false;              // creator never committed
  if (v.xmin > snapshotXid || running.has(v.xmin))
    return false;                                 // created after my snapshot
  if (v.xmax === null) return true;                            // never deleted
  if (!committed.has(v.xmax)) return true;               // deleter did not commit
  if (v.xmax > snapshotXid || running.has(v.xmax))
    return true;                                  // deleted after my snapshot
  return false;
}
```
]
Running it prints:
`snapshot xid <= 103 -> 1:A 2:C` and `snapshot xid <= 110 -> 1:B 2:C`.

*Walking it by hand for snapshot 103:*
- `(1, A)`: xmin 100 $<= 103$, committed $arrow.r$ visible so far. xmax 105 $> 103$ $arrow.r$
  the delete has not happened for me. *Visible.*
- `(1, B)`: xmin 105 $> 103$ $arrow.r$ created after my snapshot. *Not visible.*
- `(2, C)`: xmin 102 $<= 103$, xmax empty. *Visible.*

#ans[snapshot 103 sees `1:A` and `2:C`; the update to `B` is invisible to it]
]
#note[
The price of MVCC is *garbage*. Dead versions pile up and must be cleaned (`VACUUM` in
PostgreSQL, the purge thread in InnoDB). A transaction left open for hours pins the oldest
snapshot, so nothing can be cleaned, and the table *bloats*. "Long idle transaction" is the
number-one cause of a PostgreSQL table growing ten times bigger than its data.
]
]

#ex(22, tier: 2, asked: "SCB · pattern")[
Your application logs show `deadlock detected, process 4411 was chosen as the victim` a few
hundred times a day. Walk through how you would diagnose and fix it.

#sol[
*Step 1 — draw the wait-for graph* from the deadlock report. A node per transaction, an edge
$T_i arrow.r T_j$ meaning "$T_i$ is waiting for a lock that $T_j$ holds". A deadlock is a
cycle.

#diagram(height: 4.0cm, caption: "Wait-for graph. T1→T2→T3→T1 is a cycle, so those three are deadlocked. T4 is only a victim of the traffic jam.")[
  #dnode(0.6cm, 0.2cm, 1.8cm, 0.9cm, "T1", fill: rgb("#f7e8e8"))
  #dnode(5.4cm, 0.2cm, 1.8cm, 0.9cm, "T2", fill: rgb("#f7e8e8"))
  #dnode(5.4cm, 2.4cm, 1.8cm, 0.9cm, "T3", fill: rgb("#f7e8e8"))
  #dnode(10.2cm, 0.2cm, 1.8cm, 0.9cm, "T4")
  #darrow(2.45cm, 0.65cm, 5.35cm, 0.65cm, label: "waits for")
  #darrow(6.3cm, 1.15cm, 6.3cm, 2.35cm, label: "waits for")
  #darrow(5.35cm, 2.85cm, 2.5cm, 1.15cm, label: "waits for")
  #darrow(10.15cm, 0.65cm, 7.25cm, 0.65cm, label: "waits for")
]

#code(lang: "js", caption: "cycle finder + victim choice, run with node")[
```js
const waitsFor = { T1: ["T2"], T2: ["T3"], T3: ["T1"], T4: ["T2"] };

function findCycle(g) {
  const state = new Map(), stack = [];
  const dfs = (u) => {
    state.set(u, 1); stack.push(u);
    for (const v of g[u] ?? []) {
      if (state.get(v) === 1) return stack.slice(stack.indexOf(v));  // the cycle
      if (!state.has(v)) { const c = dfs(v); if (c) return c; }
    }
    state.set(u, 2); stack.pop(); return null;
  };
  for (const u of Object.keys(g))
    if (!state.has(u)) { const c = dfs(u); if (c) return c; }
  return null;
}
const cycle = findCycle(waitsFor);          // [ 'T1', 'T2', 'T3' ]
const work = { T1: 900, T2: 120, T3: 4000 };        // log records written so far
const victim = cycle.reduce((a, b) => (work[a] <= work[b] ? a : b));   // T2
```
]
Output: `cycle: T1 -> T2 -> T3 -> T1` and
`victim = cheapest to roll back = T2 ( 120 log records )`.

*Step 2 — find the common shape.* Almost always one of these three:
#table(columns: (auto, 1fr),
  [Opposite lock order], [Two code paths touch rows A and B in different orders.],
  [Lock upgrade], [Both take an S lock (a plain `SELECT` under some engines), then both ask to
    upgrade to X. Neither can, because the other holds S.],
  [Range/gap locks], [Two inserts into the same gap of an index under `REPEATABLE READ` in
    InnoDB.],
)

*Step 3 — fix.*
+ Impose a *global lock order*. Sort the keys in the application before touching them:
  `ORDER BY id` on the `SELECT ... FOR UPDATE`, or sort the array in Node before the loop.
+ Replace "read then upgrade" with `SELECT ... FOR UPDATE` on the first read, so the X lock is
  taken once and never upgraded.
+ Shorten the transaction. A transaction that holds locks for 2 ms rarely meets another one.
+ Keep a *retry wrapper* anyway. A deadlock is not a bug you can eliminate; it is an error code
  you must handle.

#code(lang: "js", caption: "retry on serialisation / deadlock errors, run with node")[
```js
async function withRetry(run, tries = 4) {
  for (let i = 0; i < tries; i++) {
    try { return await run(); }
    catch (e) {
      // 40001 = serialisation failure, 40P01 = deadlock
      const retryable = e.code === "40001" || e.code === "40P01";
      if (!retryable || i === tries - 1) throw e;
      await new Promise(r => setTimeout(r, 20 * 2 ** i + Math.random() * 20));
    }
  }
}
```
]
#ans[cycle in the wait-for graph; enforce one lock order, shorten transactions, and always retry]
]
]

#practice(tier: 2, time: "25 minutes")[
+ Two transactions read the same 10 rows and each updates a different one. Name the anomaly
  and the level that stops it.
+ A row is locked for an average of 8 ms. What is the maximum number of transactions per
  second that row can serve?
+ Give one reason an outbox row and the business row must be inserted in the *same*
  transaction.
+ Under MVCC, does a `SELECT` ever block an `UPDATE` on the same row? Does an `UPDATE` ever
  block another `UPDATE` on the same row?
+ Why does an idle-in-transaction connection make a PostgreSQL table grow?
+ A deadlock report names 3 transactions. How many must be rolled back to break it?
+ You must not sell the same seat twice. Give the *simplest* mechanism, using no explicit locks.
]

#key[
1. Write skew; `SERIALIZABLE`. #h(8pt)
2. $1\/0.008 = 125$ per second. #h(8pt)
3. Otherwise a crash between the two writes leaves either a booking nobody will charge for, or
a charge for a booking that does not exist. #h(8pt)
4. No, and yes — readers and writers do not block each other, but two writers on the same row
do. #h(8pt)
5. Its snapshot is the oldest one alive, so no dead row version newer than it may be reclaimed;
`VACUUM` can do nothing and the table bloats. #h(8pt)
6. One — removing any single node breaks a cycle. #h(8pt)
7. A `UNIQUE` constraint on `(show_id, seat_no)` in the bookings table. The second insert fails
with a constraint violation. The database does the locking for you.
]

#section[Tier 3 — the hard version]
#tier-header(3)

#ex(23, tier: 3, asked: "Google · pattern")[
"`SERIALIZABLE` means the transactions run one at a time." Take that apart. Then explain the
difference between *conflict* serialisability, *view* serialisability, and what PostgreSQL's
SSI actually guarantees.

#sol[
*The claim is wrong in an important way.* `SERIALIZABLE` guarantees the *result* is equal to
*some* serial order. It does not say which order, and it does not say the transactions ran one
at a time. They overlap freely; the engine only has to prove afterwards that some serial order
would have produced the same outcome.

*Conflict serialisable.* Reachable from a serial schedule by swapping adjacent
non-conflicting operations. Test: acyclic precedence graph. Cheap to check — this is what
engines implement.

*View serialisable.* A weaker, larger class. Schedule $S$ is view equivalent to serial $S'$ when
+ every transaction reads the same *initial* values in both,
+ every read in $S$ reads from the same writer as in $S'$,
+ the *final* write of each item is by the same transaction in both.

Every conflict serialisable schedule is view serialisable. The reverse is false. The gap is
made of *blind writes* — a write with no read before it.

$ S = W_1(A) space W_2(A) space W_3(A) $
The precedence graph has $T_1 arrow.r T_2$, $T_2 arrow.r T_3$, $T_1 arrow.r T_3$ — acyclic, so
this one *is* conflict serialisable. Now consider

$ S = R_1(A) space W_2(A) space W_1(A) space W_3(A) $
Edges: $T_1 arrow.r T_2$ (read then write), $T_2 arrow.r T_1$ (write then write),
$T_1 arrow.r T_3$, $T_2 arrow.r T_3$. The cycle $T_1 arrow.r T_2 arrow.r T_1$ makes it *not*
conflict serialisable. But it is view equivalent to $T_2, T_1, T_3$: $T_1$ reads the initial
$A$ in both, and $T_3$ writes last in both. So it is view serialisable and not conflict
serialisable.

*Why nobody implements view serialisability:* deciding it is NP-complete. Conflict
serialisability is a cycle check on a graph with one node per active transaction —
microseconds.

*What SSI guarantees.* PostgreSQL's Serialisable Snapshot Isolation runs everything on MVCC
snapshots, so readers never block. It watches for the one structure that snapshot isolation
cannot handle: a transaction with both an incoming and an outgoing read-write dependency — a
*dangerous structure*. When it spots one it aborts a transaction with SQLSTATE `40001`. So the
guarantee is true serialisability, bought with *aborts* rather than with *waiting*, and it can
abort transactions that would in fact have been fine (false positives).

#ans[serialisable = equivalent to some serial order, not actually serial; conflict $subset$ view;
engines use conflict because view is NP-complete; SSI achieves it by aborting, not by locking]
]
]

#ex(24, tier: 3, asked: "Amazon · pattern")[
Design the locking for a "transfer money between two accounts" API that must run at 5000
transfers per second across 10 million accounts, and prove your design cannot deadlock.

#sol[
*Step 1 — the shape of the work.* Each transfer touches exactly two rows. With 10 million
accounts, two random accounts collide rarely. The danger is not volume; it is *ordering*.

*Step 2 — the deadlock proof.* A deadlock needs a cycle in the wait-for graph. Suppose every
transaction acquires its locks in strictly increasing order of `acc_no`. Let $T_i$ wait for
$T_j$. Then $T_i$ is blocked on some account $a$, and it already holds every account it locked
before $a$ — all of which are $< a$. $T_j$ holds $a$. So the *highest lock held* by $T_i$ is
less than the highest lock held by $T_j$. Follow the cycle
$T_1 arrow.r T_2 arrow.r dots.h arrow.r T_1$ and this quantity strictly increases all the way
round, ending below itself. Contradiction. *No cycle can exist.*

#code(lang: "sql", caption: "ordered locking — the whole trick is ORDER BY")[
```sql
BEGIN;
  -- lock BOTH rows in one statement, in ascending account order
  SELECT acc_no, balance
    FROM accounts
   WHERE acc_no IN ('A100', 'B200')
   ORDER BY acc_no
     FOR UPDATE;

  UPDATE accounts SET balance = balance - 5000
   WHERE acc_no = 'A100' AND balance >= 5000;
  -- the application checks that 1 row was updated; if 0, the balance was too low
  UPDATE accounts SET balance = balance + 5000 WHERE acc_no = 'B200';

  INSERT INTO ledger (from_acc, to_acc, amount, at)
       VALUES ('A100', 'B200', 5000, now());
COMMIT;
```
]

#trap[
`ORDER BY` inside `SELECT ... FOR UPDATE` is *not* guaranteed to fix the lock acquisition order
on every engine — the planner may choose to lock as it scans. The portable version is to sort
in the application and lock one row at a time:
#code(lang: "js", caption: "portable ordered locking, run with node")[
```js
const ids = ['B200', 'A100'].sort();        // ALWAYS sort -> ['A100','B200']
for (const id of ids)
  await tx.query('SELECT 1 FROM accounts WHERE acc_no = $1 FOR UPDATE', [id]);
```
]
]

*Step 3 — the throughput budget.* Lock hold time is everything.
$ "hold" = "2 index lookups" + "3 writes" + "commit fsync" approx 1 "ms" $
One account row can then serve about 1000 transfers per second. 5000 transfers per second over
10 million accounts averages $5000 times 2 \/ 10^7 = 0.001$ locks per account per second — no
contention at all. The design fails only on *celebrity accounts*: a merchant settlement
account receiving 3000 transfers per second exceeds one row's budget. For those, bucket the
credit side (Example 18) and sum the buckets when reading the balance.

*Step 4 — what else is needed.*
+ Group commit, so 200 transactions share one log `fsync` instead of paying for 200.
+ An idempotency key on the API, because the client will retry a request whose response was
  lost, and a retried transfer must not move the money twice:
  `INSERT INTO transfers (idem_key, ...) VALUES (...)` with `UNIQUE(idem_key)`.
+ A retry wrapper anyway, for `40001` from the occasional serialisation failure.

#ans[strict 2PL with locks taken in ascending key order; the highest-lock-held argument proves
no cycle; shard hot accounts and use group commit for throughput]
]
]

#ex(25, tier: 3, asked: "Goldman Sachs · pattern")[
Compare *timestamp ordering*, *optimistic concurrency control* and *2PL* on the same workload,
and say when each wins. Then run the timestamp-ordering rules on a small schedule.

#sol[
*Timestamp ordering (T/O).* Every transaction gets a timestamp `TS` when it starts. Every item
$X$ carries `RTS(X)` (largest timestamp that read it) and `WTS(X)` (largest that wrote it).
No locks at all — instead, an operation that would violate timestamp order is *rejected*, and
the transaction is restarted with a new timestamp.

#table(columns: (auto, 1fr),
  [`read(X)` by $T$], [if `TS(T) < WTS(X)` $arrow.r$ abort $T$ (it wants a value that has
    already been overwritten by a younger transaction). Else read, and set
    `RTS(X) = max(RTS(X), TS(T))`.],
  [`write(X)` by $T$], [if `TS(T) < RTS(X)` $arrow.r$ abort $T$ (somebody younger already read
    the old value). If `TS(T) < WTS(X)` $arrow.r$ *Thomas's write rule*: this write is obsolete,
    so silently ignore it and continue. Else write and set `WTS(X) = TS(T)`.],
)

*Worked run.* `TS(T1) = 10`, `TS(T2) = 20`. Start with `RTS(A) = WTS(A) = 0`.

#table(columns: (auto, auto, auto, auto, auto),
  [*Step*], [*Operation*], [*Rule check*], [*RTS(A)*], [*WTS(A)*],
  [1], [`R2(A)`], [`20 < WTS=0`? no $arrow.r$ allow], [20], [0],
  [2], [`W2(A)`], [`20 < RTS=20`? no. `20 < WTS=0`? no $arrow.r$ write], [20], [20],
  [3], [`W1(A)`], [`10 < RTS=20`? *yes*], [—], [—],
)
Step 3 aborts $T_1$ under the plain rule. Under Thomas's write rule we first ask whether the
write is merely obsolete: `10 < WTS=20` is true, so $T_1$'s write would be overwritten by
$T_2$'s anyway — but $T_1$'s timestamp is also below `RTS`, and the read-check fires first, so
$T_1$ still aborts. Change step 1 to `R1(A)` (`RTS = 10`) and step 3 becomes: `10 < RTS=10`?
no. `10 < WTS=20`? yes $arrow.r$ *ignore the write, do not abort*. That is exactly what
Thomas's rule buys.

*The three protocols side by side.*
#table(columns: (auto, auto, auto, auto),
  [], [*2PL*], [*Timestamp ordering*], [*OCC*],
  [When it checks], [before every access], [before every access], [only at commit],
  [Cost when no conflict], [lock/unlock on every row], [two comparisons per access], [almost zero],
  [Cost on conflict], [wait], [restart], [restart, after all the work is done],
  [Deadlock], [possible], [impossible], [impossible],
  [Starvation], [rare], [a long transaction can be restarted forever], [same],
  [Wins when], [contention is real and transactions are short], [conflicts are moderate and
    waiting is worse than restarting], [conflicts are rare],
  [Loses when], [hot rows, long transactions], [long read-write transactions], [contention is
    high — work is repeated again and again],
)

*Reading the workload.* Let $p$ be the probability a transaction conflicts and $W$ the work it
does. OCC's expected cost is roughly $W \/ (1 - p)$ — fine while $p$ is small, and it blows up
as $p arrow.r 1$. 2PL's cost is $W + p times "wait"$, which grows gently. So: low contention
$arrow.r$ OCC; high contention $arrow.r$ 2PL. Almost every real system is 2PL (SQL Server,
InnoDB on writes) or MVCC + 2PL on writers (PostgreSQL, Oracle), with OCC available as a
version column for the application to use where it knows conflicts are rare.

#ans[2PL waits, T/O and OCC restart; use OCC when conflicts are rare, 2PL when they are not]
]
]

#ex(26, tier: 3, asked: "Microsoft · pattern")[
Explain exactly how a `COMMIT` becomes durable on a modern server, including group commit and
the operating system page cache. Then explain why `fsync` failing is such a dangerous bug.

#sol[
*The path of a commit.*
+ The transaction appends log records to the *log buffer* in RAM. Cheap: a `memcpy`.
+ `COMMIT` is issued. The log buffer up to this transaction's last LSN must reach *stable
  storage*.
+ The database calls `write()`. The bytes go into the *operating system page cache* — still
  RAM, still lost on a power cut.
+ The database calls `fsync()` (or opens the log with `O_DSYNC`). The OS pushes the pages to the
  device and waits.
+ The device may still hold them in its own *volatile write cache*. A device with a battery or
  capacitor is safe; a cheap consumer SSD may not be. The database asks for a
  `FLUSH CACHE` / FUA write to be sure.
+ `fsync` returns. Only now does `COMMIT` return to the client.

*Group commit.* Step 4 costs about the same whether it flushes 200 bytes or 200 KB — the cost
is the round trip and the flush, not the bytes. So the log writer waits a tiny amount (or
simply takes whatever arrived while the previous flush was in flight) and flushes many
transactions' records together. 200 transactions then share one `fsync`.

$ "throughput" approx ("transactions per flush") / ("flush latency") $

With a 1 ms flush and no grouping: 1000 commits per second, full stop. With 200 per group:
200000 per second. This is why `innodb_flush_log_at_trx_commit` and
`synchronous_commit` exist — turning them off buys throughput by giving up the D in ACID for
the last few milliseconds of work.

*Why a failing `fsync` is dangerous.* On Linux, when a writeback error occurs the kernel may
mark the page clean and report the error to *the next* `fsync` on that file descriptor — once.
A subsequent `fsync` then returns success even though the data was never written. If the
database treated the first failure as "retry later", it would retry, see success, and report
a durable commit for data that is gone. The correct behaviour, which PostgreSQL adopted after
this was understood, is brutal and right: *`fsync` failed $arrow.r$ panic the server and
recover from the log*, because the in-memory state can no longer be trusted to match the disk.

#ans[log buffer $arrow.r$ page cache $arrow.r$ device $arrow.r$ `fsync` returns $arrow.r$
`COMMIT` returns; group commit amortises the flush; a failed `fsync` may not be retried, so the
only safe response is to crash and replay the log]
]
#trap[
If you are asked "what makes commits slow", the wrong answer is "writing the rows to the
table". The right answer is "one `fsync` of the log per commit group, about 0.5–2 ms on a
datacentre SSD" — and that is why batching a thousand inserts into one transaction is
thousands of times faster than a thousand auto-commit inserts.
]
]

#ex(27, tier: 3, asked: "D. E. Shaw · pattern")[
An `INSERT` under InnoDB's `REPEATABLE READ` deadlocks against another `INSERT` on a different
primary key. Explain how that is possible.

#sol[
The answer is *gap locks* and *insert intention locks*.

InnoDB's `REPEATABLE READ` stops phantoms, which the SQL standard does not require. To do it,
a locking read does not only lock the rows it found — it locks the *gaps between* index
entries, so nobody can insert a new row into the range you looked at. A row lock plus the gap
before it is a *next-key lock*.

Now take an index on `order_no` holding the values 10 and 30, and two sessions:

#code(lang: "sql", caption: "two inserts into the same gap")[
```sql
-- session 1                                    -- session 2
BEGIN;                                          BEGIN;
SELECT * FROM t WHERE order_no BETWEEN 10 AND 30
  FOR UPDATE;    -- next-key locks the gap (10,30)
                                      SELECT * FROM t
                                        WHERE order_no BETWEEN 10 AND 30
                                        FOR UPDATE;  -- gap locks are SHARED!
INSERT INTO t (order_no) VALUES (20);
  -- needs an insert intention lock in (10,30);
  -- blocked by session 2's gap lock
                                                INSERT INTO t (order_no) VALUES (25);
                                                  -- blocked by session 1's gap lock
                                                --            => DEADLOCK
```
]

The key facts that make this surprising:
+ Gap locks are *compatible with each other*. Two sessions can both hold a gap lock on
  $(10, 30)$. Nothing blocks at the `SELECT`.
+ An `INSERT` needs an *insert intention* lock in that gap, and that *is* blocked by another
  session's gap lock.
+ So both sessions pass the `SELECT` and both block on the `INSERT`. Cycle. Deadlock.

The same shape appears with `INSERT ... ON DUPLICATE KEY UPDATE` and with two inserts of the
*same* unique value: the loser takes a shared lock on the existing row while waiting, then
tries to upgrade.

*Fixes.*
+ Drop to `READ COMMITTED`, where InnoDB mostly stops using gap locks. You give up
  phantom protection — usually acceptable, and it is MySQL's most common production setting.
+ Do not take the range lock at all: `INSERT` first and handle the duplicate-key error, rather
  than "check whether it exists, then insert".
+ Make the ranges disjoint, so two sessions never sit in the same gap.

#ans[gap locks are shared but insert intention locks conflict with them, so two sessions can
both hold the gap and then both block trying to insert into it]
]
#note[
This is also the reason `SELECT ... FOR UPDATE` on a column with *no index* is dangerous under
InnoDB: with no index to lock gaps in, it locks *every* row it scans — effectively the whole
table. Index your locking predicates.
]
]

#ex(28, tier: 3, asked: "Adobe · pattern")[
Your team wants "exactly once" processing of a queue of jobs stored in a table. Many workers,
at-least-once delivery, no job run twice. Design it and state precisely what you can and cannot
guarantee.

#sol[
*What is impossible.* A worker can crash after finishing its side effect and before recording
that it finished. No protocol removes that window, so *exactly once execution* of an arbitrary
side effect is not achievable. What you can achieve is *exactly once effect*: at-least-once
delivery plus idempotent work.

*The claim step.* One statement, atomic, no explicit lock.
#code(lang: "sql", caption: "claim a batch of jobs (PostgreSQL)")[
```sql
UPDATE jobs
   SET state      = 'RUNNING',
       worker_id  = 'w-17',
       claimed_at = now(),
       attempts   = attempts + 1
 WHERE job_id IN (
         SELECT job_id
           FROM jobs
          WHERE state = 'READY'
            AND run_after <= now()
          ORDER BY run_after
          LIMIT 10
          FOR UPDATE SKIP LOCKED      -- the important line
       )
RETURNING job_id, payload;
```
]
`FOR UPDATE SKIP LOCKED` means: if another worker already holds the lock on that row, do not
wait for it — *skip it and take the next one*. Without `SKIP LOCKED`, every worker queues on
the same head-of-queue rows and the system serialises to one worker's speed.

*The idempotency step.* The side effect carries a key derived from the job, so a repeat is a
no-op.
#code(lang: "sql", caption: "record the effect and complete the job together")[
```sql
BEGIN;
  INSERT INTO effects (idem_key, job_id, result)
       VALUES ('job-4412-v1', 4412, '{"charged":true}')
  ON CONFLICT (idem_key) DO NOTHING;      -- second run inserts nothing

  UPDATE jobs SET state = 'DONE', finished_at = now() WHERE job_id = 4412;
COMMIT;
```
]

*The stuck-worker step.* A worker that dies leaves a row in `RUNNING` forever. A reaper
returns it:
#code(lang: "sql", caption: "lease expiry")[
```sql
UPDATE jobs
   SET state = 'READY', worker_id = NULL
 WHERE state = 'RUNNING'
   AND claimed_at < now() - interval '5 minutes'
   AND attempts < 5;
```
]
The lease is what makes this safe *and* the reason the job may run twice: a worker that was
merely slow, not dead, may still be running when the lease expires. That is exactly why the
side effect must be idempotent.

*What you can state precisely:*
#table(columns: (auto, 1fr),
  [Guaranteed], [every ready job is eventually attempted; no two workers ever *claim* the same
    job at the same instant; the effect row and the job's `DONE` state flip together, atomically],
  [Not guaranteed], [that the side effect runs exactly once — only that repeats are harmless,
    because of the idempotency key],
  [Cost], [`SKIP LOCKED` gives up FIFO order; a slow job can be overtaken],
)

#ans[claim with `FOR UPDATE SKIP LOCKED`, make the effect idempotent with a unique key, expire
leases; the guarantee is at-least-once delivery with exactly-once *effect*]
]
]

#practice(tier: 3, time: "35 minutes")[
+ Give a schedule that is view serialisable but not conflict serialisable, and say which
  feature of it creates the gap.
+ Prove that acquiring locks in a fixed global order makes deadlock impossible.
+ A workload has a 30% conflict rate. Argue for 2PL over OCC using the expected-cost model.
+ Under Thomas's write rule, when is a write simply discarded rather than causing an abort?
+ Explain why redo replays the changes of transactions that will immediately be undone.
+ `synchronous_commit = off` — which ACID letter did you sell, and exactly how much of it?
+ Why can `SELECT ... FOR UPDATE` on an unindexed column lock an entire table in InnoDB?
+ A job queue without `SKIP LOCKED` has 40 workers but the throughput of one. Explain.
]

#key[
1. $R_1(A) W_2(A) W_1(A) W_3(A)$ — the *blind write* $W_3(A)$ (and the blind $W_2(A)$) create the
gap; view equivalence only cares who wrote *last*. #h(8pt)
2. See Example 24: the highest lock held strictly increases along every wait edge, so a cycle
would require a value to be less than itself. #h(8pt)
3. OCC's expected cost $approx W\/(1-p) = W\/0.7 = 1.43 W$, and every restart repeats *all* the
work; 2PL pays $W$ plus a wait that is usually shorter than a full restart. #h(8pt)
4. When `TS(T) >= RTS(X)` (no younger reader) but `TS(T) < WTS(X)` (a younger writer already
won) — the write is invisible to everyone, so dropping it is safe. #h(8pt)
5. So that undo's "before" values are known to be correct; redo restores the exact crash state,
which is the only state the undo log describes. #h(8pt)
6. Durability, for the window between `COMMIT` returning and the next log flush — typically a
few hundred milliseconds of committed transactions. Atomicity and consistency are unaffected:
you lose whole transactions, never half of one. #h(8pt)
7. With no index there are no index entries to place next-key locks on, so InnoDB locks every
row it examines — which is all of them. #h(8pt)
8. All 40 workers `SELECT ... FOR UPDATE` the same head rows; 39 wait on the first, so the queue
drains at one worker's rate.
]

#section[Rapid-fire — one-line answers]

Cover the right column. Say the answer out loud. These thirty cover most of what a technical
round asks on transactions.

#table(columns: (1fr, 1.25fr),
  [*Question*], [*Answer*],
  [Expand ACID.], [Atomicity, Consistency, Isolation, Durability.],
  [Which one does the `fsync` of the log deliver?], [Durability.],
  [What is a transaction?], [A unit of work that happens all or not at all.],
  [When do two operations conflict?], [Different transactions, same item, at least one is a write.],
  [Test for conflict serialisability?], [Precedence graph has no cycle.],
  [What is a dirty read?], [Reading a row another transaction wrote but has not committed.],
  [What is a phantom?], [The same `WHERE` returns extra rows the second time.],
  [Lowest level that stops dirty reads?], [READ COMMITTED.],
  [Lowest level that stops phantoms?], [SERIALIZABLE.],
  [Default level in PostgreSQL? In MySQL InnoDB?], [READ COMMITTED; REPEATABLE READ.],
  [What is write skew?], [Two transactions read the same set, then each writes a *different* row, breaking a rule about the set.],
  [Which level stops write skew?], [SERIALIZABLE only.],
  [State two-phase locking.], [Growing phase takes locks, shrinking phase releases them, never mixed.],
  [Does 2PL prevent deadlock?], [No. It guarantees serialisability and causes deadlocks.],
  [What does strict 2PL add?], [Locks held until commit — no cascading rollback.],
  [S with S? S with X?], [Compatible; not compatible.],
  [How is a DBMS deadlock detected?], [A cycle in the wait-for graph.],
  [How is it resolved?], [Roll back a victim, usually the cheapest to undo.],
  [The one-line deadlock prevention rule?], [Always take locks in the same global order.],
  [State the write-ahead rule.], [The log record reaches disk before the data page, and before `COMMIT` returns.],
  [The three recovery passes?], [Analysis, redo, undo.],
  [Who is redone? Who is undone?], [Redo everybody; undo only the losers.],
  [What is a checkpoint for?], [So recovery starts there instead of at the start of the log.],
  [What is MVCC?], [Writes create new row versions; each reader sees the versions alive in its snapshot.],
  [Under MVCC, do readers block writers?], [No. Writers block writers on the same row.],
  [What does `SELECT ... FOR UPDATE` do?], [Takes an exclusive row lock at read time.],
  [Optimistic concurrency in one line?], [Read a version, write with `WHERE version = ?`, retry if 0 rows changed.],
  [What is group commit?], [Many transactions share one log `fsync`.],
  [Can `TRUNCATE` be rolled back?], [In PostgreSQL yes; in MySQL and Oracle DDL commits implicitly, so no.],
  [What SQLSTATE means "serialisation failure"?], [`40001` — and the right response is to retry.],
)

#revision[
*The four words.* Atomicity — undo log. Consistency — constraints. Isolation — locks or MVCC.
Durability — log `fsync`.

*The table to draw from memory*
#table(columns: (auto, auto, auto, auto, auto),
  [*Level*], [*Dirty*], [*Non-repeatable*], [*Phantom*], [*Write skew*],
  [READ UNCOMMITTED], [yes], [yes], [yes], [yes],
  [READ COMMITTED], [no], [yes], [yes], [yes],
  [REPEATABLE READ], [no], [no], [yes\*], [yes],
  [SERIALIZABLE], [no], [no], [no], [no],
)
\*InnoDB's `REPEATABLE READ` also blocks phantoms, using gap locks. The standard does not
require it.

*Conflict rule.* Different transactions + same item + at least one write.
*Serialisability test.* Precedence graph, look for a cycle.

*Locking.* 2PL = grow then shrink $arrow.r$ serialisable, but deadlocks.
Strict 2PL = hold until commit $arrow.r$ no cascading rollback. This is what engines do.
Deadlock = cycle in the wait-for graph $arrow.r$ kill a victim $arrow.r$ *the application must
retry*. Prevent it by locking in a fixed global order.

*Recovery.* Log first, sequentially. `COMMIT` returns after `fsync`. On restart:
analysis (winners / losers) $arrow.r$ redo *everything* $arrow.r$ undo *losers*, backwards.
Checkpoint = where recovery starts reading.

*MVCC.* New version per write, `xmin` / `xmax`, snapshot decides visibility. Readers never
block. Cost = vacuum, and bloat from long-open transactions.

*The five answers that win marks*
+ "Durability means the *log* is on disk, not the data file."
+ "2PL prevents non-serialisable schedules; it *causes* deadlock."
+ "`SERIALIZABLE` means equivalent to *some* serial order, not actually one at a time."
+ "`TRUNCATE` rollback depends on the engine."
+ "A check-then-act in the application is never safe without a lock, a unique constraint, or a
  serialisable retry."

*The seven traps*
+ Dirty read means *uncommitted*, not *old*.
+ `ROLLBACK` after `COMMIT` does nothing.
+ `REPEATABLE READ` does not stop write skew.
+ MVCC does not remove write-write locking.
+ Never hold a transaction across a network call.
+ A long idle transaction bloats the whole table.
+ `SELECT ... FOR UPDATE` without an index can lock the entire table.
]

]
