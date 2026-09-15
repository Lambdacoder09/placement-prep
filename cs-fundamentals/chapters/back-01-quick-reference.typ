#import "../../shared/lib/style.typ": *

#pagebreak(weak: true)
#toc-entry("Appendix · Quick Reference")

#block(width: 100%, inset: (bottom: 6pt))[
  #text(size: 9pt, fill: muted, weight: "bold", tracking: 1.5pt)[APPENDIX]
  #v(-4pt)
  #text(size: 22pt, weight: "bold")[Quick Reference]
  #v(-3pt)
  #text(size: 10pt, fill: muted, style: "italic")[
    The whole book compressed. Read this in the last week, and again in the last hour.
  ]
]
#line(length: 100%, stroke: 1.2pt + ink)
#v(5pt)

#note[
Everything below is already explained somewhere in this book. Nothing here is new. If a
line does not make sense, that is your revision list --- go back to the chapter, not to
the internet.
]

// ============================================================
#section[A · The formula sheet]
// ============================================================

#formulas(title: "Every number you may have to compute")[
#set text(size: 9.5pt)
#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  align: (left, left),

  [*Scheduling*], [Turnaround $=$ completion $-$ arrival. Waiting $=$ turnaround $-$ burst.
  Response $=$ first-run start $-$ arrival. Average $=$ sum $div$ number of processes.],

  [*Throughput*], [processes finished $div$ total time. CPU utilisation $=$ busy time $div$ total time.],

  [*Effective access (TLB)*], [$"EAT" = h times (t_"TLB" + t_"mem") + (1-h) times (t_"TLB" + 2 times t_"mem")$,
  with $h$ the hit ratio. Two memory hits on a miss because the page table is in memory too.],

  [*Effective access (paging)*], [$"EAT" = (1-p) times t_"mem" + p times t_"fault"$, where $p$ is the
  page-fault rate. $t_"fault"$ is milliseconds against nanoseconds --- that is why $p$ must be tiny.],

  [*Page/frame split*], [page size $2^n$ $=>$ offset is $n$ bits. Virtual address $m$ bits $=>$
  page number is $m - n$ bits $=>$ $2^(m-n)$ entries in a one-level page table.],

  [*Address translation*], [page number $=$ address $div$ page size; offset $=$ address mod page size.
  Physical $=$ frame $times$ page size $+$ offset.],

  [*Disk time*], [access $=$ seek $+$ rotational latency $+$ transfer.
  Average rotational latency $=$ half a rotation $=$ $(60 div "RPM")/2$.],

  [*Disk scheduling*], [score $=$ total head movement in cylinders. Add every hop, including
  the walk to the end of the disk in SCAN and the wrap in C-SCAN.],

  [*Subnetting*], [/$p$ $=>$ hosts per subnet $= 2^(32-p) - 2$; subnets from a /$q$ block $= 2^(p-q)$;
  block size in the interesting octet $= 256 - "mask octet"$.],

  [*TCP throughput*], [window $div$ RTT. Bandwidth-delay product $=$ bandwidth $times$ RTT ---
  the window must be at least this to fill the pipe.],

  [*B+ tree height*], [with order $n$, each node holds up to $n$ pointers, so height
  $approx log_n ("rows")$. Disk reads $=$ height, plus one more if the index does not cover
  the query.],

  [*Index selectivity*], [distinct values $div$ total rows. Near 1 is excellent; near 0
  (a two-value flag) means the planner will ignore the index and scan.],
)
]

#trick[
In any Gantt question, build the *chart first and completely*, then fill one table with
columns arrival / burst / completion / turnaround / waiting. Every mark is in that table.
Doing arithmetic while drawing the chart is where the slips happen.
]

// ============================================================
#section[B · Operating systems --- Chapters 1 to 4]
// ============================================================

#subsection[B1 · The comparisons they ask by name]

#table(
  columns: (auto, 1fr, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  align: (left, left, left),
  [*Pair*], [*Left*], [*Right*],

  [Process vs thread],
  [Own address space. Creation is heavy. Crash is contained. IPC needed to talk.],
  [Shares code, data and heap; *own stack, registers, PC*. Cheap switch. One crash kills all.],

  [Context switch vs mode switch],
  [Between two processes: save PCB, swap page tables, flush or tag the TLB. Expensive.],
  [User mode to kernel mode inside the *same* process, via a system call. Much cheaper.],

  [Preemptive vs non-preemptive],
  [OS can take the CPU back on a timer. Better response, needs locking.],
  [A process holds the CPU until it blocks or exits. Simple, but one long job stalls everyone.],

  [Mutex vs semaphore],
  [Ownership: the locker must unlock. Binary. A *lock*.],
  [A counter, no owner; any thread may signal. A *signalling* device.],

  [Binary semaphore vs mutex],
  [Counter capped at 1, still no ownership, no priority inheritance.],
  [Owned, and typically supports priority inheritance --- the correct choice for mutual exclusion.],

  [Deadlock vs starvation vs livelock],
  [Circular wait; nobody moves, ever.],
  [Starvation: work is possible but this one never gets picked. Livelock: all busy, none progressing.],

  [Paging vs segmentation],
  [Fixed-size pages. *Internal* fragmentation. Invisible to the programmer.],
  [Variable-size logical units. *External* fragmentation. Visible and meaningful.],

  [Internal vs external fragmentation],
  [Wasted space *inside* an allocated block (last page half empty).],
  [Free space exists but is *scattered* --- no single hole is big enough.],

  [Logical vs physical address],
  [What the CPU emits. Also called virtual. Bounded by the address width.],
  [What the memory bus sees. The MMU converts one to the other, at every access.],

  [Hard link vs soft link],
  [Another name for the *same inode*. Same filesystem only. Original can be deleted.],
  [A file holding a *path string*. Crosses filesystems. Breaks when the target moves.],

  [Thrashing vs a page fault],
  [Faulting so often that CPU utilisation collapses. Fix: fewer processes, or more frames.],
  [One normal, expected event. Demand paging *requires* page faults to work at all.],
)

#subsection[B2 · Algorithms in one line each]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3pt),
  stroke: 0.4pt + rule,
  [*FCFS*], [Queue order. Simple, fair-looking, suffers the *convoy effect* --- one long job delays every short one.],
  [*SJF*], [Shortest burst first. Provably minimal average waiting time, but burst length must be *estimated*, and long jobs starve.],
  [*SRTF*], [Preemptive SJF. Even lower averages, more context switches, worse starvation.],
  [*Round Robin*], [Quantum $q$. Great *response* time, poor *waiting* time. $q$ too big $->$ FCFS; $q$ too small $->$ all switching overhead.],
  [*Priority*], [Highest priority first. Starvation is the flaw; *aging* (raise priority while waiting) is the fix.],
  [*Multilevel feedback*], [Several queues, a job that uses its whole quantum drops a level. Approximates SJF without knowing burst lengths.],
  [*FIFO (pages)*], [Oldest page out. The only one that suffers *Belady's anomaly* --- more frames can mean more faults.],
  [*Optimal (OPT)*], [Evict the page used furthest in the future. Unimplementable; it is the *benchmark* you compare against.],
  [*LRU*], [Evict least recently used. Good, but needs a stack or timestamps. Stack algorithm, so no Belady's anomaly.],
  [*Clock / second chance*], [Circular scan of reference bits. The practical approximation of LRU, and what real kernels ship.],
  [*FCFS (disk)*], [Requests in arrival order. Fair, lots of wasted seeking.],
  [*SSTF*], [Nearest cylinder next. Good throughput, starves the far edges.],
  [*SCAN / LOOK*], [Sweep one way then reverse. LOOK turns at the last request instead of the disk edge.],
  [*C-SCAN / C-LOOK*], [Sweep one way, jump back, sweep again. More *uniform* waiting than SCAN.],
  [*Banker's*], [Grant a request only if a *safe sequence* still exists afterwards. Needs maximum demand declared up front. Avoidance, not detection.],
)

#subsection[B3 · Rapid fire --- OS]

#set enum(numbering: "1.", spacing: 3pt)
#text(size: 9.5pt)[
+ *Five process states?* New, Ready, Running, Waiting/Blocked, Terminated.
+ *Ready to Waiting --- possible?* No. Only Running can block. Waiting always returns to Ready.
+ *What is in the PCB?* PID, state, program counter, registers, scheduling info, memory maps, open-file table, accounting.
+ *Zombie?* Finished child whose exit status the parent has not reaped with `wait()`. It holds only a PCB entry.
+ *Orphan?* Parent died first; `init`/`systemd` adopts it and reaps it.
+ *What does `fork()` return?* 0 in the child, the child's PID in the parent, $-1$ on failure.
+ *Copy-on-write?* Parent and child share physical pages read-only; the first *write* triggers the copy. Makes `fork` cheap.
+ *Thread stack shared?* No --- each thread has its own stack, registers and program counter.
+ *User vs kernel threads?* User: fast switching, one blocking call blocks all. Kernel: the OS schedules them, real parallelism.
+ *Critical section requirements?* Mutual exclusion, progress, bounded waiting.
+ *Peterson's solution needs?* Two variables --- `flag[]` and `turn` --- and it assumes no instruction reordering.
+ *Why is `test-and-set` special?* It is *atomic* in hardware: read and write happen with no gap to interleave into.
+ *Spinlock --- when?* Only when the wait is shorter than a context switch, and never on a single CPU with preemption off.
+ *Busy waiting cost?* Burns CPU doing nothing. Semaphores with a wait queue block instead.
+ *Four deadlock conditions?* Mutual exclusion, hold-and-wait, no preemption, circular wait --- *all four at once*.
+ *Easiest one to break?* Circular wait: impose a global lock ordering. It is the standard real-world fix.
+ *Avoidance vs prevention vs detection?* Prevention breaks a condition structurally. Avoidance (Banker's) checks each request. Detection lets it happen, then recovers.
+ *Cycle in a wait-for graph?* With one instance per resource, a cycle *is* deadlock. With multiple instances, a cycle is only a possibility.
+ *Priority inversion?* A low-priority thread holds a lock a high-priority thread needs. Fix: priority inheritance.
+ *Why virtual memory?* Run programs larger than RAM, isolate processes, and share pages without copying.
+ *What is in a page-table entry?* Frame number plus valid, protection, reference, dirty and caching bits.
+ *Why multi-level page tables?* A flat table for a 32-bit space is megabytes *per process*. Levels let unused ranges stay unallocated.
+ *Inverted page table?* One entry per *frame*, not per page. Tiny, but lookup needs a hash.
+ *Demand paging?* Load a page only on its first touch. Start-up is fast; the cost is paid per fault.
+ *Belady's anomaly --- which algorithms?* FIFO, and not LRU or OPT, because those are stack algorithms.
+ *Working set?* The pages a process touched in the last $Delta$ references. Frames below the working set means thrashing.
+ *Inode holds?* Size, permissions, owner, timestamps, link count and block pointers --- *not* the filename.
+ *Where is the filename?* In the directory entry, which maps name to inode number.
+ *Why does `rm` on a big open file free nothing?* The link count reaches 0 but the *open count* has not; blocks are freed at the last close.
+ *Contiguous vs linked vs indexed allocation?* Contiguous: fast random access, external fragmentation. Linked: no fragmentation, no random access. Indexed (inode): both, at the cost of an index block.
+ *Journaling gives you?* Crash consistency --- write the intent to a log first, so recovery replays or discards a half-done operation.
+ *What does `fsync` cost?* It forces the page cache to durable storage and waits. Correct, and slow, which is why databases batch it.
+ *RAID 0 / 1 / 5 / 10?* 0 stripes (speed, no safety); 1 mirrors (safety, half capacity); 5 stripes with distributed parity (one disk may fail); 10 mirrors then stripes (fast and safe, half capacity).
+ *Why are SSD rules different?* No seek time, but erase happens in large blocks --- hence wear levelling, the FTL, and why TRIM matters.
]

// ============================================================
#section[C · Databases --- Chapters 5 to 8]
// ============================================================

#subsection[C1 · SQL you must produce without thinking]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  [*Logical order*], [`FROM` → `ON` → `JOIN` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `DISTINCT` → `ORDER BY` → `LIMIT`. This is why a `SELECT` alias cannot be used in `WHERE`, but can be in `ORDER BY`.],
  [*`WHERE` vs `HAVING`*], [`WHERE` filters rows *before* grouping; `HAVING` filters groups *after*. An aggregate can only appear in `HAVING`.],
  [*`JOIN` types*], [`INNER` keeps matches only. `LEFT` keeps all left rows, `NULL`-filling the right. `FULL` keeps both sides. `CROSS` is every pair.],
  [*The `LEFT JOIN` trap*], [Putting the right table's condition in `WHERE` silently turns it back into an `INNER JOIN`. Put it in the `ON` clause instead.],
  [*`NULL` logic*], [`NULL = NULL` is unknown, not true. Use `IS NULL`. `COUNT(col)` skips `NULL`s; `COUNT(*)` does not.],
  [*`NOT IN` trap*], [If the subquery returns a single `NULL`, `NOT IN` returns *no rows at all*. Use `NOT EXISTS`.],
  [*`UNION` vs `UNION ALL`*], [`UNION` removes duplicates (a sort or hash, so slower). `UNION ALL` just concatenates. Default to `ALL` when you know there are no duplicates.],
  [*`DELETE` / `TRUNCATE` / `DROP`*], [`DELETE` is DML, row-by-row, logged, `WHERE`-able, rollback-able, fires triggers. `TRUNCATE` is DDL, deallocates pages, no `WHERE`, resets identity. `DROP` removes the table itself.],
  [*Window vs `GROUP BY`*], [`GROUP BY` collapses rows into one per group. A window function keeps every row and adds the computed column beside it.],
  [*`ROW_NUMBER` / `RANK` / `DENSE_RANK`*], [On a tie: 1,2,3 --- 1,1,3 --- 1,1,2.],
  [*Correlated subquery*], [It references the outer row, so it runs *per row*. Usually rewritable as a join, usually faster that way.],
  [*CTE*], [`WITH x AS (...)` --- a named result for readability. `WITH RECURSIVE` walks hierarchies: anchor, `UNION ALL`, recursive step.],
)

#subsection[C2 · Keys, normal forms and transactions]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  [*Super key*], [Any attribute set that identifies a row uniquely. Every candidate key is a super key.],
  [*Candidate key*], [A *minimal* super key --- remove any attribute and uniqueness breaks.],
  [*Primary key*], [The candidate key you picked. Unique and `NOT NULL`. One per table.],
  [*Unique key*], [Also unique, but may allow a `NULL` (one, in most engines). Any number per table.],
  [*Foreign key*], [Points at a candidate key of another table. Enforces referential integrity; may be `NULL`.],
  [*Prime attribute*], [An attribute belonging to *some* candidate key. Everything else is non-prime.],
  [*Closure $X^+$*], [Start with $X$; keep adding right-hand sides of every FD whose left side is already inside. If $X^+$ is all attributes, $X$ is a super key.],
)

#table(
  columns: (auto, 1fr, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  align: (left, left, left),
  [*Form*], [*Rule*], [*It removes*],
  [1NF], [Every value is atomic; no repeating groups or lists in a cell.], [Lists stuffed into one column.],
  [2NF], [1NF, and no *partial* dependency --- no non-prime attribute depends on part of a composite key.], [Duplication tied to half the key.],
  [3NF], [2NF, and no *transitive* dependency --- non-prime attributes must not determine other non-prime attributes.], [Insert/update/delete anomalies.],
  [BCNF], [For every FD $X -> Y$, $X$ must be a super key.], [The last anomalies --- but may lose dependency preservation.],
  [4NF], [BCNF, and no non-trivial multivalued dependency unless the left side is a super key.], [The Cartesian blow-up of two independent lists.],
)

#note[
*3NF vs BCNF is the question that decides the round.* 3NF allows $X -> Y$ where $X$ is not a
super key *provided* $Y$ is prime. BCNF forbids it outright. A lossless, dependency-preserving
3NF decomposition always exists; a BCNF one does not always. That trade-off *is* the answer.
]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  [*ACID*], [*Atomicity* --- all or nothing (undo log). *Consistency* --- constraints hold before and after. *Isolation* --- concurrent looks serial. *Durability* --- committed survives a crash (redo log, WAL).],
  [*WAL rule*], [The log record reaches durable storage *before* the data page does. That single rule is what makes both undo and redo possible.],
  [*Dirty read*], [Reading a row another transaction wrote but has not committed.],
  [*Non-repeatable read*], [Reading the same *row* twice and getting different values.],
  [*Phantom read*], [Running the same *range query* twice and getting different row counts.],
  [*Lost update*], [Two read-modify-writes overlap; one overwrites the other's result.],
  [*2PL*], [Growing phase acquires locks, shrinking phase releases them. Guarantees serialisability. *Strict* 2PL holds every exclusive lock to commit --- that is what prevents cascading rollback.],
  [*MVCC*], [Readers see a snapshot, writers create new versions. Readers never block writers. The cost is version storage and vacuuming.],
)

#table(
  columns: (auto, auto, auto, auto),
  inset: (x: 5pt, y: 3.5pt),
  align: (left, center, center, center),
  [*Isolation level*], [*Dirty read*], [*Non-repeatable*], [*Phantom*],
  [READ UNCOMMITTED], [possible], [possible], [possible],
  [READ COMMITTED], [prevented], [possible], [possible],
  [REPEATABLE READ], [prevented], [prevented], [possible],
  [SERIALIZABLE], [prevented], [prevented], [prevented],
)

#subsection[C3 · Indexing]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  [*Why B+ and not B?*], [All data lives in the leaves and the leaves are linked, so a *range scan* is one descent plus a walk. Internal nodes hold only keys, so fan-out is higher and the tree is shorter.],
  [*Clustered index*], [Defines the physical row order. One per table. The leaf *is* the row --- no second lookup.],
  [*Non-clustered*], [A separate structure whose leaf holds a pointer. Many per table. Costs an extra fetch unless the index *covers* the query.],
  [*Covering index*], [Contains every column the query needs, so the table is never touched. This is the single biggest easy win.],
  [*Composite index order*], [Leftmost-prefix rule: an index on `(a, b, c)` serves `a`, `(a,b)` and `(a,b,c)` --- never `b` alone. Put equality columns first, the range column last.],
  [*Hash index*], [$O(1)$ equality, useless for ranges and for `ORDER BY`. B+ tree is the safe default.],
  [*When an index hurts*], [Every `INSERT`/`UPDATE`/`DELETE` must maintain it; low selectivity makes the planner scan anyway; and a wrapped column (`WHERE YEAR(d) = 2024`) disables it entirely --- rewrite as a range.],
  [*Why is my index ignored?*], [Function on the column, leading wildcard `LIKE '%x'`, type mismatch forcing a cast, stale statistics, or the query genuinely touching most of the table.],
  [*Reading `EXPLAIN`*], [Look for the *access type* (seek vs scan), the *rows examined* versus rows returned, and any sort or temporary table. A large gap between examined and returned is the bug.],
)

#subsection[C4 · Rapid fire --- DBMS]

#text(size: 9.5pt)[
+ *DDL / DML / DCL / TCL?* `CREATE`,`ALTER`,`DROP`,`TRUNCATE` / `SELECT`,`INSERT`,`UPDATE`,`DELETE` / `GRANT`,`REVOKE` / `COMMIT`,`ROLLBACK`,`SAVEPOINT`.
+ *View?* A stored query. Simplifies and restricts access. A *materialised* view stores the result and must be refreshed.
+ *Can you update a view?* Only a simple one --- no aggregate, no `DISTINCT`, no `GROUP BY`, one base table.
+ *Trigger vs stored procedure?* A trigger fires automatically on a table event; a procedure is called explicitly.
+ *ER: cardinality?* 1:1, 1:N, M:N. M:N always becomes a third *junction* table with two foreign keys.
+ *Weak entity?* No key of its own; identified by its owner's key plus a partial key. Drawn with a double rectangle.
+ *Surrogate vs natural key?* Surrogate is a meaningless generated id (stable, joins fast). Natural carries meaning (readable, but meanings change).
+ *Denormalise when?* Reads dominate, the join is proven to be the bottleneck, and you accept writing the duplicate consistently.
+ *Schedule is conflict serialisable?* Draw the precedence graph. No cycle $=>$ yes.
+ *Recoverable schedule?* A transaction commits only after every transaction it read from has committed.
+ *Cascading rollback?* One abort forces others to abort because they read its uncommitted data. Strict 2PL prevents it.
+ *Deadlock in a database?* Two transactions each hold a lock the other wants. The engine detects it and kills a victim --- your code must be ready to *retry*.
+ *Shared vs exclusive lock?* Many readers together (S), one writer alone (X). S and X conflict.
+ *Checkpoint?* A marker in the log saying "everything before this is on disk", so recovery does not replay from the beginning.
+ *OLTP vs OLAP?* Many small writes, normalised, row storage / few huge reads, denormalised star schema, column storage.
+ *SQL vs NoSQL?* Fixed schema, joins and strong transactions / flexible documents, horizontal scaling, application-side joins.
+ *CAP?* During a network *partition* you choose consistency or availability. It is not a menu for normal operation.
+ *Sharding vs partitioning?* Sharding splits across *machines*; partitioning splits within *one* database.
+ *`CHAR` vs `VARCHAR`?* Fixed width, padded, slightly faster / variable width, stores a length, saves space.
+ *`DISTINCT` cost?* It forces a sort or a hash over the whole result. If you need `DISTINCT`, suspect a join that is duplicating rows.
]

// ============================================================
#section[D · Networks --- Chapters 9 and 10]
// ============================================================

#subsection[D1 · The layers, and who does what]

#table(
  columns: (auto, auto, 1fr, auto),
  inset: (x: 5pt, y: 3.5pt),
  align: (center, left, left, left),
  [*Layer*], [*Name*], [*Job*], [*Unit · examples*],
  [7], [Application], [What the user's program speaks.], [data · HTTP, DNS, SMTP],
  [6], [Presentation], [Encoding, compression, encryption.], [data · TLS, JPEG],
  [5], [Session], [Opening, syncing and closing a dialogue.], [data · RPC],
  [4], [Transport], [Process-to-process; ports, reliability, ordering.], [segment · TCP, UDP],
  [3], [Network], [Host-to-host across networks; logical addressing.], [packet · IP, ICMP],
  [2], [Data link], [Hop-to-hop on one link; MAC, framing, error check.], [frame · Ethernet, ARP],
  [1], [Physical], [Bits as voltage, light or radio.], [bit · cable, Wi-Fi],
)

#note[
TCP/IP collapses this to four: *Application* (OSI 5--7), *Transport*, *Internet*, *Link*.
Repeater/hub = layer 1. Switch/bridge = layer 2. Router = layer 3. Firewall and load
balancer = layer 3, 4 or 7 depending on what it inspects.
]

#subsection[D2 · Addressing and subnetting]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  [*Private ranges*], [`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`. Loopback `127.0.0.0/8`. Link-local `169.254.0.0/16` --- seeing that address means DHCP failed.],
  [*Mask shorthand*], [/24 = 255.255.255.0 · /25 = .128 · /26 = .192 · /27 = .224 · /28 = .240 · /29 = .248 · /30 = .252.],
  [*Block size*], [$256 -$ the interesting mask octet. A /26 has block size 64, so networks start at .0, .64, .128, .192.],
  [*Usable hosts*], [$2^(32-p) - 2$ --- subtract the network address and the broadcast address. A /30 gives 2 usable, which is exactly one router link.],
  [*Broadcast address*], [The last address in the block --- one less than the next network address.],
  [*Public vs private*], [NAT rewrites a private source address and port to the router's public pair, and keeps a table to reverse it on the way back.],
  [*IPv6*], [128 bits, hexadecimal, `::` collapses one run of zeros. No broadcast, no NAT needed, no fragmentation by routers, and SLAAC for autoconfiguration.],
)

#subsection[D3 · TCP, UDP and HTTP]

#table(
  columns: (auto, 1fr, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  align: (left, left, left),
  [*Aspect*], [*TCP*], [*UDP*],
  [Connection], [Three-way handshake first.], [None --- just send.],
  [Guarantees], [Ordered, reliable, de-duplicated, or it reports failure.], [Best effort. May be lost, duplicated or reordered.],
  [Control], [Flow control and congestion control.], [Neither. The application must cope.],
  [Header], [20 bytes minimum.], [8 bytes.],
  [Use when], [Web, mail, file transfer, database connections.], [DNS, video and voice, gaming, QUIC's foundation.],
)

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  [*Handshake*], [SYN → SYN-ACK → ACK. It synchronises the *initial sequence numbers* in both directions --- that is the real purpose, not "saying hello".],
  [*Close*], [FIN → ACK → FIN → ACK. Four steps, because each direction closes independently (half-close).],
  [*`TIME_WAIT`*], [The active closer waits 2×MSL so late duplicates die and the final ACK can be resent. It is correct behaviour, not a leak.],
  [*Flow vs congestion control*], [Flow control protects the *receiver* (its advertised window). Congestion control protects the *network* (the congestion window). Effective window is the smaller of the two.],
  [*Slow start*], [`cwnd` doubles every RTT until `ssthresh`, then congestion avoidance adds one MSS per RTT (additive increase).],
  [*On loss*], [Triple duplicate ACK $=>$ fast retransmit and fast recovery, halving `cwnd`. Timeout $=>$ the network is badly congested: `cwnd` back to 1 and slow start again.],
  [*Nagle vs delayed ACK*], [Nagle batches small writes; delayed ACK holds acknowledgements. Together they can add avoidable latency --- the reason interactive apps disable Nagle.],
  [*HTTP is stateless*], [Every request stands alone. Cookies, tokens and sessions are what add the memory on top.],
  [*Idempotent methods*], [`GET`, `PUT`, `DELETE`, `HEAD` --- repeating them is harmless. `POST` is not. `GET` must also be *safe*: no side effects.],
  [*`PUT` vs `PATCH`*], [`PUT` replaces the whole resource; `PATCH` applies a partial change.],
  [*Status classes*], [1xx info · 2xx success · 3xx redirect · 4xx *you* made the mistake · 5xx *the server* did. Know 200, 201, 204, 301, 302, 304, 400, 401, 403, 404, 409, 429, 500, 502, 503.],
  [*401 vs 403*], [401 = not authenticated (who are you?). 403 = authenticated but not allowed.],
  [*HTTP/1.1 → 2 → 3*], [1.1 adds keep-alive and pipelining but suffers head-of-line blocking. 2 adds binary framing, multiplexing and header compression --- but TCP-level head-of-line blocking remains. 3 moves to QUIC over UDP, which removes it and gives 0-RTT resumption.],
  [*HTTPS handshake*], [Asymmetric keys authenticate the server and agree a *symmetric* session key; the rest of the traffic uses that faster symmetric key. The certificate chain is what proves identity.],
  [*Cookie flags*], [`HttpOnly` hides it from JavaScript, `Secure` means HTTPS only, `SameSite` blocks cross-site sending (the CSRF defence).],
  [*CORS*], [A *browser* rule, not a server firewall. A non-simple request is preflighted with `OPTIONS`, and the server must answer with the matching `Access-Control-Allow-*` headers.],
)

#subsection[D4 · Rapid fire --- Networks]

#text(size: 9.5pt)[
+ *What happens when you type a URL?* DNS resolve → TCP handshake → TLS handshake → HTTP request → response → parse → sub-resource requests → render.
+ *DNS resolution order?* Browser cache → OS cache → hosts file → resolver → root → TLD → authoritative.
+ *DNS record types?* A (IPv4), AAAA (IPv6), CNAME (alias), MX (mail), NS (nameserver), TXT (verification), PTR (reverse).
+ *ARP?* Maps an IP to a MAC address *on the local link*, by broadcast. Layer 2 and 3 meeting.
+ *DHCP?* DORA --- Discover, Offer, Request, Acknowledge. Leases an address, mask, gateway and DNS server.
+ *ICMP?* Control and error messages. `ping` uses echo request/reply; `traceroute` walks the TTL up from 1.
+ *MTU and fragmentation?* Ethernet's MTU is 1500 bytes. IPv4 routers may fragment; IPv6 routers never do --- the sender must discover the path MTU.
+ *TTL?* A hop counter, decremented by each router. At 0 the packet dies and ICMP reports it. It stops routing loops.
+ *Port ranges?* 0--1023 well-known, 1024--49151 registered, 49152--65535 ephemeral. Know 20/21, 22, 25, 53, 80, 443, 3306, 5432, 6379.
+ *What identifies a connection?* The 4-tuple: source IP, source port, destination IP, destination port.
+ *Switch vs router?* A switch forwards by MAC inside one network; a router forwards by IP between networks.
+ *Distance vector vs link state?* DV (RIP) tells neighbours about everyone, converges slowly, count-to-infinity. LS (OSPF) tells everyone about neighbours, then each router runs Dijkstra locally.
+ *Longest prefix match?* Of all matching routes, the most specific mask wins. A /28 route beats a /24 route.
+ *Default gateway?* The route of last resort, `0.0.0.0/0`, used when nothing more specific matches.
+ *Latency vs bandwidth vs jitter?* Delay of one packet / volume per second / the *variation* in delay, which is what breaks voice calls.
+ *Why is UDP used for video?* A late frame is worthless, so retransmission would hurt more than a dropped frame does.
+ *Sticky session?* The load balancer pins a client to one server. It works, but it makes that server's failure visible to the user --- external session storage is the better answer.
]

// ============================================================
#section[E · OOP and dev fundamentals --- Chapters 11 and 12]
// ============================================================

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  [*Encapsulation*], [Bundle the data with the methods and hide the internals. Private fields plus a controlled interface. JS: `#field`. Java/C++: `private`.],
  [*Abstraction*], [Expose *what* it does, hide *how*. An abstract class or interface names the contract; the implementation is somebody else's problem.],
  [*Inheritance*], [An "is-a" relationship that reuses a base class. Prefer *composition* ("has-a") when the relationship is not genuinely is-a.],
  [*Polymorphism*], [One interface, many implementations. Compile-time = overloading. Run-time = overriding through a base reference.],
  [*Overloading vs overriding*], [Overloading: same name, *different parameter list*, same class, resolved at *compile* time --- and JavaScript does not have it. Overriding: same signature, *subclass*, resolved at *run* time via the vtable.],
  [*Abstract class vs interface*], [Abstract class: may hold state and implemented methods, single inheritance, use for "is-a" with shared code. Interface: a pure contract, many may be implemented, use for capability. Java 8+ default methods blur the line but *state* still separates them.],
  [*Virtual function*], [A method resolved by the object's real type, not the reference type. C++ needs the `virtual` keyword; Java methods are virtual by default; JavaScript is always dynamic.],
  [*vtable*], [A per-class array of function pointers; each object stores a hidden vptr. That indirection is the entire run-time cost of polymorphism.],
  [*Why a virtual destructor?*], [Deleting a derived object through a base pointer without one skips the derived destructor and leaks. C++ only.],
  [*Diamond problem*], [Two parents inherit from one grandparent --- whose copy does the child get? C++ answers with virtual inheritance; Java forbids multiple class inheritance and uses interfaces; JavaScript uses a single linear prototype chain plus mixins.],
  [*Association / aggregation / composition*], [Just knows about / has-a with independent lifetime (a team and its players) / has-a with *shared* lifetime (a house and its rooms --- destroy one, destroy both).],
  [*SOLID*], [*S* one reason to change · *O* extend without editing · *L* a subtype must be substitutable for its base · *I* many small interfaces beat one fat one · *D* depend on abstractions, not concretions.],
  [*Shallow vs deep copy*], [Shallow copies references, so nested objects stay shared. Deep copies everything, recursively --- `structuredClone` in modern JS.],
  [*`static`*], [Belongs to the class, not the instance. One copy for all objects. It cannot see `this`.],
  [*JS `this`*], [Decided by the *call site*, not by where the function was written. Arrow functions have no `this` of their own, which is exactly why they are safe as callbacks.],
  [*Prototype chain*], [JS `class` is syntax over prototypes. Lookup walks `__proto__` upward until it finds the property or hits `null`.],
)

#subsection[E1 · From source to running program]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  [*Four stages*], [Preprocess (expand includes and macros) → Compile (to assembly) → Assemble (to an object file) → Link (resolve symbols into an executable).],
  [*Compiler vs interpreter vs JIT*], [Translate everything first, then run fast / translate and run line by line, easier to debug / interpret, then compile the hot paths at run time --- what V8 does.],
  [*Front end*], [Lexer (characters → tokens) → Parser (tokens → syntax tree) → Semantic analysis (types, scopes, the symbol table).],
  [*Back end*], [Intermediate representation → optimisation → target code generation → register allocation.],
  [*"Undefined reference"*], [A *link* error: something was declared and used but never defined, or the library was not passed to the linker. Not a compile error.],
  [*Static vs dynamic linking*], [Static copies the library in: bigger file, no runtime surprises. Dynamic shares one `.so`/`.dll`: smaller, patchable, but the right version must be present.],
  [*Memory layout*], [Low to high: *text* (code, read-only) · *data* (initialised globals) · *BSS* (uninitialised globals, zeroed) · *heap*, growing up · *stack*, growing down.],
  [*Stack vs heap*], [Stack: automatic, LIFO, fast, small, freed on return. Heap: manual or garbage-collected, large, slower, can fragment.],
  [*Stack overflow*], [Recursion without a base case, or too deep. Each call frame holds return address, saved registers, parameters and locals.],
  [*Segfault*], [Touching memory you do not own: a null or dangling pointer, or running off the end of an array.],
  [*Floating point*], [`0.1 + 0.2 != 0.3` because binary cannot represent 0.1 exactly. Compare with a tolerance; use integers or a decimal type for money.],
)

#subsection[E2 · Git]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  stroke: 0.4pt + rule,
  [*Three trees*], [Working directory → staging area (index) → repository. `add` moves left to middle, `commit` moves middle to right.],
  [*Object model*], [Four objects: *blob* (file contents), *tree* (a directory listing), *commit* (a tree plus parents plus a message), *tag*. Each is addressed by the SHA-1 of its content.],
  [*A branch is*], [A 41-byte file holding one commit hash. That is why branching is instant.],
  [*HEAD*], [A pointer to the current branch. *Detached HEAD* means it points straight at a commit instead.],
  [*Merge vs rebase*], [Merge keeps real history and adds a merge commit. Rebase replays your commits on top of the target, producing a straight line but *new hashes*. Never rebase a branch others have pulled.],
  [*`reset` vs `revert`*], [`reset` moves the branch pointer --- history is rewritten (`--soft` keeps changes staged, `--mixed` unstages, `--hard` destroys them). `revert` adds a *new* commit that undoes an old one, and is the only safe choice on a shared branch.],
  [*`fetch` vs `pull`*], [`fetch` downloads. `pull` is `fetch` plus `merge` (or `rebase` with `--rebase`).],
  [*`cherry-pick`*], [Copy one commit's change onto the current branch as a new commit with a new hash.],
  [*`stash`*], [Park uncommitted work, clean the tree, restore it later with `stash pop`.],
  [*Recovering a lost commit*], [`git reflog` --- it records every move of HEAD, so almost nothing is truly lost before garbage collection.],
  [*SemVer*], [MAJOR.MINOR.PATCH --- breaking / backward-compatible feature / backward-compatible fix. The lock file is what makes a build reproducible.],
)

// ============================================================
#pagebreak(weak: true)
#section[F · The last-hour page]
// ============================================================

#formulas(title: "If you read nothing else, read this")[
#set text(size: 9.5pt)
*The twelve traps that cost the most marks.*

#set enum(numbering: "1.", spacing: 3.5pt)
+ Threads share code, data and heap --- *not the stack*, not registers, not the program counter.
+ Deadlock needs *all four* conditions at the same time. Any one of them alone is not deadlock.
+ Belady's anomaly hits *FIFO only*. LRU and Optimal are stack algorithms and cannot suffer it.
+ Internal fragmentation belongs to *paging*; external fragmentation belongs to *segmentation* and contiguous allocation.
+ A hard link shares the *inode*; a soft link stores a *path*. Deleting the original breaks only the soft one.
+ `WHERE` filters rows, `HAVING` filters groups. An aggregate cannot appear in `WHERE`.
+ A right-table condition in the `WHERE` clause turns a `LEFT JOIN` into an `INNER JOIN`.
+ `TRUNCATE` is DDL: no `WHERE`, no per-row logging, and in most engines you cannot roll it back.
+ BCNF may cost you dependency preservation; 3NF never does. That is the whole 3NF-vs-BCNF answer.
+ An index is not free --- it slows every write, and on a low-selectivity column the planner will ignore it.
+ The handshake exists to *synchronise sequence numbers*, and `TIME_WAIT` is correct behaviour, not a bug.
+ Overloading is *compile*-time and needs a different parameter list; overriding is *run*-time and needs the same signature.

#v(4pt)
*And the four sentences that win the round.* "The trade-off here is..." · "It depends on
whether reads or writes dominate." · "I would measure before I optimise." · "I have not used
that, but from first principles it would have to work like this..."
]
