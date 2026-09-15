#import "../../shared/lib/style.typ": *

#chapter(num: 3, title: "OS: Memory Management", tagline: "How one small RAM pretends to be many big ones")[

#section[The one idea]

#formulas(title: "The whole chapter in one box")[
Your program says "give me byte 5000". RAM has no byte 5000 reserved for you. Something
in the middle must *translate* that request into a real RAM address, and must do it for
every running program at the same time, without letting any program read another's data.

That translator is *memory management*. Three jobs, always:

+ *Translate* — turn a logical (virtual) address into a physical address.
+ *Protect* — stop process A from touching process B's bytes.
+ *Stretch* — let the total memory all programs think they have be much larger than the
  RAM you actually bought.

Definitions you must be able to say without pausing:

- *Logical / virtual address* — the address the CPU produces while running your program.
- *Physical address* — the address that goes on the memory bus to the RAM chip.
- *MMU (Memory Management Unit)* — the hardware that converts one to the other.
- *Page* — a fixed-size block of the logical address space (typically 4 KB).
- *Frame* — a fixed-size block of physical memory, the *same size* as a page.
- *Page table* — the per-process array that says "page $i$ lives in frame $f$".
- *Page fault* — the page you asked for is not in RAM right now.

The arithmetic everything rests on. If page size is $2^d$ bytes:

$ "page number" = floor("logical address" / 2^d), quad "offset" = "logical address" mod 2^d $

$ "physical address" = "frame number" times 2^d + "offset" $

In binary this is free: the low $d$ bits *are* the offset, the rest *are* the page number.
Nothing is added or shifted for the offset — it is copied through untouched.
]

#trick[
Offset bits = $log_2("page size")$. Page-number bits = (address bits) $-$ (offset bits).
Number of entries in a flat page table = $2^("page-number bits")$. Three facts, and half
the numerical questions in this chapter fall out.
]

#section[Where a running program's bytes live]

Before translation, know what is being translated. Every process gets one flat virtual
address space, carved into regions.

#diagram(height: 7.4cm, caption: "The virtual address space of one process. Heap grows up, stack grows down; the gap in the middle is why one process can look huge and use little.")[
  #dnode(1.2cm, 0.1cm, 5.0cm, 0.8cm, "high addresses (e.g. 0xFFFF...)", fill: white)
  #dnode(1.2cm, 0.95cm, 5.0cm, 0.9cm, "kernel space\n(mapped, not readable by you)", fill: rgb("#f2dcdc"))
  #dnode(1.2cm, 1.9cm, 5.0cm, 1.0cm, "STACK\nlocals, return addresses, arguments", fill: rgb("#f7efe4"))
  #darrow(3.7cm, 3.15cm, 3.7cm, 2.95cm)
  #dnode(1.2cm, 3.3cm, 5.0cm, 0.7cm, "free gap (the big hole)", fill: white)
  #darrow(3.7cm, 4.25cm, 3.7cm, 4.45cm)
  #dnode(1.2cm, 4.6cm, 5.0cm, 0.9cm, "HEAP\nmalloc / new / JS objects", fill: rgb("#f7efe4"))
  #dnode(1.2cm, 5.6cm, 5.0cm, 0.7cm, "BSS — globals set to 0", fill: rgb("#eef3f7"))
  #dnode(1.2cm, 6.35cm, 5.0cm, 0.7cm, "DATA — globals with a value", fill: rgb("#eef3f7"))
  #dnode(1.2cm, 7.1cm, 5.0cm, 0.0cm, "", fill: white)

  #dnode(7.4cm, 0.95cm, 4.0cm, 0.9cm, "grows DOWN as\ncalls nest", fill: white)
  #dnode(7.4cm, 4.6cm, 4.0cm, 0.9cm, "grows UP as you\nallocate", fill: white)
  #dnode(7.4cm, 6.35cm, 4.0cm, 0.7cm, "fixed size, from the\nexecutable file", fill: white)

  #dnode(12.0cm, 1.9cm, 4.4cm, 1.2cm, "stack overflow =\nstack crashes into the gap\nand past it", fill: rgb("#fdf4f4"))
  #dnode(12.0cm, 4.4cm, 4.4cm, 1.2cm, "memory leak =\nheap keeps growing,\nnothing gives it back", fill: rgb("#fdf4f4"))
]

#note[
TEXT (the machine code) sits at the very bottom, below DATA, and is marked read-only and
executable. That is why writing through a bad pointer into code space gives a segmentation
fault instead of silently rewriting your program.
]

#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
A process's virtual address space is 4 GB but the machine has 8 GB of RAM and 40 processes
are running. Total virtual memory asked for is 160 GB. Why does nothing break?
]
#sol[
Because almost none of those 4 GB are *used*. The address space is a promise, not a
reservation. Only pages that are actually touched get a physical frame. The rest of the
space is the "free gap" in the picture above — no frame, no page-table entry, no cost.
#ans[Virtual space is address *range*, not allocated RAM. Frames are handed out only on first touch.]
]

#ex(2, tier: 0, asked: "warm-up")[
Which of these is produced by the CPU while executing an instruction: logical address or
physical address?
]
#sol[
The CPU produces a *logical* address. The MMU sits between the CPU and the bus and turns
it into a physical one.
#ans[Logical (virtual). Physical addresses only exist after the MMU.]
]

#section[Before paging: contiguous allocation]

The oldest scheme. Each process gets one continuous block of RAM. The hardware needs only
two registers.

#formulas(title: "Base and limit")[
- *Base register* — where this process's block starts in physical memory.
- *Limit register* — how long the block is.

On every access the hardware checks:

$ 0 <= "logical address" < "limit" $

If it passes: $"physical" = "base" + "logical"$. If it fails: trap to the OS
(segmentation fault). Two comparisons, done in hardware, on every single memory access.
]

#subsection[Choosing which hole to use]

Free memory becomes a list of *holes*. When a process of size $n$ arrives, which hole do
we cut it from?

#table(columns: (auto, auto, auto),
  [*Strategy*], [*Rule*], [*Character*],
  [*First fit*], [Scan from the start, take the first hole that is big enough.], [Fastest to run. Good enough in practice.],
  [*Best fit*], [Take the *smallest* hole that fits.], [Must scan the whole list. Leaves a litter of tiny useless slivers.],
  [*Worst fit*], [Take the *largest* hole that fits.], [Must scan the whole list. Destroys your big holes first. Usually worst overall.],
  [*Next fit*], [Like first fit, but resume scanning from where you stopped last time.], [Spreads use around; slightly better than first fit on long runs.],
)

#tier-header(1)

#ex(3, tier: 1, asked: "TCS NQT · pattern")[
Free holes, in memory order, are 120K, 60K, 300K, 180K, 90K. Requests arrive in this
order: 210K, 55K, 290K, 130K. Show what first fit, best fit and worst fit each do.
]
#sol[
Work request by request. A request that fits nowhere waits.

*First fit* — scan left to right, stop at the first hole that is big enough.

#table(columns: (auto, auto, auto),
  [*Request*], [*Goes into*], [*Holes after*],
  [210K], [hole 3 (300K) — 120 and 60 are too small], [120, 60, *90*, 180, 90],
  [55K],  [hole 1 (120K) — first one big enough],      [*65*, 60, 90, 180, 90],
  [290K], [nothing fits — must wait],                  [65, 60, 90, 180, 90],
  [130K], [hole 4 (180K)],                             [65, 60, 90, *50*, 90],
)

*Best fit* — smallest hole that fits.

#table(columns: (auto, auto, auto),
  [*Request*], [*Goes into*], [*Holes after*],
  [210K], [hole 3 (300K) — only one that fits], [120, 60, *90*, 180, 90],
  [55K],  [hole 2 (60K) — tightest fit],        [120, *5*, 90, 180, 90],
  [290K], [nothing fits — wait],                [120, 5, 90, 180, 90],
  [130K], [hole 4 (180K)],                      [120, 5, 90, *50*, 90],
)

*Worst fit* — largest hole that fits.

#table(columns: (auto, auto, auto),
  [*Request*], [*Goes into*], [*Holes after*],
  [210K], [hole 3 (300K)],           [120, 60, *90*, 180, 90],
  [55K],  [hole 4 (180K) — biggest], [120, 60, 90, *125*, 90],
  [290K], [nothing fits — wait],     [120, 60, 90, 125, 90],
  [130K], [nothing fits — wait],     [120, 60, 90, 125, 90],
)

Score: first fit and best fit each placed 3 of 4 requests. Worst fit placed only 2, because
it spent its 180K hole on a 55K request.
#ans[First fit: holes 65, 60, 90, 50, 90 · Best fit: 120, 5, 90, 50, 90 · Worst fit: 120, 60, 90, 125, 90 with two requests still waiting.]
]

#code(lang: "js", caption: "fits.js — run it and change the numbers yourself")[
```js
function allocate(holes, requests, strategy) {
  const h = [...holes];
  const log = [];
  for (const r of requests) {
    let pick = -1;
    for (let i = 0; i < h.length; i++) {
      if (h[i] < r) continue;
      if (pick === -1) { pick = i; if (strategy === 'first') break; continue; }
      if (strategy === 'best'  && h[i] < h[pick]) pick = i;
      if (strategy === 'worst' && h[i] > h[pick]) pick = i;
    }
    if (pick === -1) { log.push(`${r}K -> WAIT (no hole fits)`); continue; }
    log.push(`${r}K -> hole ${pick + 1} (was ${h[pick]}K, leftover ${h[pick] - r}K)`);
    h[pick] -= r;
  }
  return { log, holes: h };
}
const holes = [120, 60, 300, 180, 90];
const reqs  = [210, 55, 290, 130];
for (const s of ['first', 'best', 'worst']) {
  const r = allocate(holes, reqs, s);
  console.log(`--- ${s} fit ---`);
  r.log.forEach(l => console.log('  ' + l));
  console.log('  holes now', r.holes.join(','));
}
```
]

#note[
Output (verified with `node fits.js`): worst fit ends with holes `120,60,90,125,90` and
leaves both 290K and 130K waiting. First and best fit both end with 355K total free, worst
fit with 485K free — and yet worst fit served *fewer* requests. More free bytes is not the
same as more usable free bytes.
]

#subsection[The two fragmentations]

#formulas(title: "Internal vs external fragmentation")[
- *External fragmentation* — enough total free memory exists, but it is split into
  scattered holes, none big enough. Belongs to *contiguous* allocation and to
  *segmentation*.
- *Internal fragmentation* — the block you were given is bigger than what you asked for,
  and the unused tail inside it is wasted. Belongs to *paging* and to fixed-size blocks.

Average internal fragmentation with paging $approx$ half a page per process (the last page
is on average half empty).

Cure for external fragmentation: *compaction* (slide everything together) — only possible
if binding is dynamic, and it is expensive. The real cure is paging: stop requiring
contiguity at all.
]

#trap[
"Paging removes fragmentation." *Wrong.* Paging removes *external* fragmentation. It
*creates* internal fragmentation, because the last page of a process is almost never full.
Say exactly which one you mean, every time.
]

#ex(4, tier: 1, asked: "Infosys · pattern")[
Page size is 4 KB. A process needs 19,430 bytes. How many pages? How much internal
fragmentation?
]
#sol[
Step 1 — pages needed:
$ 19430 / 4096 = 4.744... arrow.r "round up" arrow.r 5 "pages" $

Step 2 — memory actually given:
$ 5 times 4096 = 20480 "bytes" $

Step 3 — waste:
$ 20480 - 19430 = 1050 "bytes" $
#ans[5 pages; 1050 bytes of internal fragmentation.]

The waste is always in the *last* page only, and is always less than one page size.
]

#section[Paging — the real scheme]

Break the logical address space into fixed-size *pages*. Break physical memory into
same-size *frames*. Any page can go into any free frame. Contiguity in virtual space no
longer means contiguity in physical space.

#diagram(height: 6.6cm, caption: "Paging. The offset is copied straight through; only the page number is looked up. The TLB is a small cache in front of the page table.")[
  #dnode(0pt, 0.2cm, 3.6cm, 0.6cm, "CPU emits logical address", fill: white)
  #dnode(0pt, 1.0cm, 2.0cm, 0.8cm, "page p", fill: rgb("#f7efe4"))
  #dnode(2.0cm, 1.0cm, 1.6cm, 0.8cm, "offset d", fill: rgb("#eef3f7"))

  #darrow(1.0cm, 1.85cm, 1.0cm, 2.55cm, label: "look up p")
  #dnode(0pt, 2.6cm, 3.6cm, 1.0cm, "TLB\n(fast, ~64-1024 entries)", fill: rgb("#dce9f2"))
  #darrow(3.65cm, 3.1cm, 5.15cm, 3.1cm, label: "MISS")
  #dnode(5.2cm, 2.6cm, 3.6cm, 1.0cm, "Page table in RAM\nentry[p] = frame f", fill: rgb("#eef3f7"))
  #darrow(7.0cm, 2.55cm, 7.0cm, 1.9cm, label: "f")
  #darrow(1.0cm, 2.55cm, 1.0cm, 1.9cm, label: "HIT: f")

  #dnode(10.2cm, 1.0cm, 2.0cm, 0.8cm, "frame f", fill: rgb("#f7efe4"))
  #dnode(12.2cm, 1.0cm, 1.6cm, 0.8cm, "offset d", fill: rgb("#eef3f7"))
  #dnode(10.2cm, 0.2cm, 3.6cm, 0.6cm, "physical address", fill: white)
  #darrow(8.9cm, 1.4cm, 10.15cm, 1.4cm)
  #darrow(3.7cm, 1.4cm, 5.0cm, 1.4cm, label: "d unchanged", dashed: true)

  #dnode(5.2cm, 4.0cm, 3.6cm, 1.0cm, "not present?\n-> PAGE FAULT", fill: rgb("#fdf4f4"))
  #darrow(7.0cm, 3.65cm, 7.0cm, 3.95cm)

  #dnode(10.2cm, 2.6cm, 5.8cm, 2.4cm, "Physical RAM\n\nframe 0 | frame 1 | frame 2 ...\nany page may sit in any frame,\nso no external fragmentation", fill: rgb("#fafbfc"))
]

#subsection[Reading a page-table entry (PTE)]

A PTE is not just a frame number. Know the bits:

#table(columns: (auto, auto),
  [*Field*], [*What it is for*],
  [Frame number], [Where the page actually is in RAM.],
  [Valid / present bit], [0 means "not in RAM" -> page fault on access.],
  [Protection bits (R/W/X)], [Write to a read-only page -> trap. This is how `const` pages and code pages are enforced.],
  [Dirty (modified) bit], [Set by hardware on a write. If 0 at eviction time, the frame can be dropped without writing to disk.],
  [Referenced (accessed) bit], [Set by hardware on any access. The OS clears it periodically; this is the raw material for LRU approximations.],
  [User/supervisor bit], [Whether user-mode code may touch this page.],
  [Caching bits], [Mark memory-mapped device pages as uncacheable.],
)

#trick[
The *dirty bit* is the cheapest optimisation in the whole chapter. Evicting a clean page
costs 0 disk writes. Evicting a dirty page costs 1. So modern replacement policies prefer
clean victims when quality is otherwise equal.
]

#ex(5, tier: 1, asked: "Wipro · pattern")[
Logical addresses are 16 bits. Page size is 1 KB. (a) How many bits of offset? (b) How many
pages can a process have? (c) Logical address 5000 with page 4 mapped to frame 9 — what is
the physical address?
]
#sol[
*(a)* $1"KB" = 1024 = 2^10$, so the offset needs *10 bits*.

*(b)* Page-number bits $= 16 - 10 = 6$, so $2^6 = 64$ *pages*.

*(c)* Split 5000:
$ "page" = floor(5000 / 1024) = 4, quad "offset" = 5000 - 4 times 1024 = 5000 - 4096 = 904 $
Page 4 is in frame 9:
$ "physical" = 9 times 1024 + 904 = 9216 + 904 = 10120 $
#ans[(a) 10 bits (b) 64 pages (c) physical address 10120.]
]

#code(lang: "js", caption: "translate.js — the MMU in nine lines")[
```js
const OFFSET_BITS = 10;
const PAGE_SIZE = 1 << OFFSET_BITS;              // 1024 bytes
// page -> frame. 16 valid pages; anything else is not mapped.
const pageTable = [5, 9, 1, 7, 9, 2, 0, 3, 11, 6, 8, 4, 13, 2, 10, 12];

function translate(logical) {
  const page   = logical >> OFFSET_BITS;         // same as Math.floor(logical/1024)
  const offset = logical & (PAGE_SIZE - 1);      // same as logical % 1024
  const frame  = pageTable[page];
  if (frame === undefined) return { page, offset, fault: true };
  return { page, offset, frame, physical: frame * PAGE_SIZE + offset };
}
console.log(translate(5000));
console.log(translate(13580));
console.log(translate(70000));
```
]

#note[
Real output from `node translate.js`:
```
{ page: 4, offset: 904, frame: 9, physical: 10120 }
{ page: 13, offset: 268, frame: 2, physical: 2316 }
{ page: 68, offset: 368, fault: true }
```
Notice the shift and the mask. `>> 10` and `& 1023` are exactly what the wires in an MMU
do — the page number and the offset are just two slices of the same bit string.
]

#ex(6, tier: 1, asked: "Capgemini · pattern")[
Virtual addresses are 32 bits, page size 4 KB, and each page-table entry is 4 bytes. How
big is one process's flat (single-level) page table?
]
#sol[
Step 1 — offset bits: $4"KB" = 2^12$, so 12 bits.

Step 2 — number of pages: $2^(32-12) = 2^20 = 1,048,576$ pages, so the table needs $2^20$
entries.

Step 3 — size: $2^20 times 4 "bytes" = 4 "MB"$.
#ans[4 MB per process — and that is *per process*, so 100 processes cost 400 MB of page tables alone.]

That number is the whole reason multi-level page tables exist.
]

#section[TLB: making translation not cost double]

Without help, every memory access becomes two: one to read the page table, one to read the
data. The TLB (Translation Lookaside Buffer) is a tiny fully-associative cache of recent
page-to-frame mappings, inside the MMU.

#formulas(title: "Effective access time with a TLB")[
Let $alpha$ = TLB hit ratio, $t$ = TLB lookup time, $m$ = one main-memory access time.

$ "EAT" = alpha (t + m) + (1 - alpha)(t + m + m) $

Read it as: *always* pay the TLB lookup. On a hit, one memory access (the data). On a
miss, two (the page table, then the data).

For an $L$-level page table the miss branch costs $L times m$ table accesses plus $m$ for
the data:

$ "EAT" = alpha (t + m) + (1 - alpha)(t + L m + m) $
]

#ex(7, tier: 1, asked: "Accenture · pattern")[
TLB lookup 20 ns, main memory access 100 ns, TLB hit ratio 80%, single-level page table.
Find the effective access time and the percentage slowdown versus raw memory.
]
#sol[
*Hit branch* (80%): 20 ns TLB $+$ 100 ns data $= 120$ ns.

*Miss branch* (20%): 20 ns TLB $+$ 100 ns page table $+$ 100 ns data $= 220$ ns.

$ "EAT" = 0.8 times 120 + 0.2 times 220 = 96 + 44 = 140 "ns" $

Raw memory with no translation at all would be 100 ns.
$ "slowdown" = (140 - 100)/100 = 40% $
#ans[EAT = 140 ns, a 40% slowdown over raw memory.]

Compare: with *no* TLB, every access costs $100 + 100 = 200$ ns, a 100% slowdown. The TLB
cut the penalty from 100% to 40%.
]

#ex(8, tier: 2, asked: "Grab · pattern")[
A 64-bit server uses a *three-level* page table. TLB lookup is 10 ns, memory access 100 ns,
TLB hit ratio 98%. Find EAT. Then explain why the hit ratio matters far more here than in
Example 7.
]
#sol[
*Hit branch* (98%): $10 + 100 = 110$ ns.

*Miss branch* (2%): $10 + 3 times 100 "(three table levels)" + 100 "(data)" = 410$ ns.

$ "EAT" = 0.98 times 110 + 0.02 times 410 = 107.8 + 8.2 = 116 "ns" $

Why the hit ratio matters more: the miss is now 410 ns against a 110 ns hit — a penalty of
300 ns per miss instead of 100 ns. Drop the hit ratio to 90% and EAT becomes
$0.9 times 110 + 0.1 times 410 = 99 + 41 = 140$ ns, a 21% jump from one 8-point drop in hit
ratio.
#ans[EAT = 116 ns. Deeper page tables make every TLB miss much more expensive, so hit ratio dominates.]

This is why real systems use *huge pages* (2 MB or 1 GB instead of 4 KB) for large
databases: one TLB entry then covers 512 times more memory, so the hit ratio climbs.
]

#trap[
"A context switch flushes the TLB." Half true, and the half matters. On old hardware, yes —
which made context switches expensive. Modern CPUs tag each TLB entry with an *address
space identifier* (ASID / PCID), so entries from different processes coexist and no flush
is needed. If you are asked, say both: "classically a flush; modern CPUs use ASIDs to
avoid it."
]

#section[Making page tables affordable]

#subsection[Multi-level (hierarchical) paging]

Split the page number itself into pieces. The outer table indexes inner tables; inner
tables hold frames. Pages of the address space that are never touched need *no inner
table at all* — and that is where the saving comes from.

#diagram(height: 5.4cm, caption: "Two-level paging on a 32-bit address with 4 KB pages: 10 outer bits, 10 inner bits, 12 offset bits.")[
  #dnode(0pt, 0.1cm, 1.9cm, 0.75cm, "p1 (10 b)", fill: rgb("#f7efe4"))
  #dnode(1.9cm, 0.1cm, 1.9cm, 0.75cm, "p2 (10 b)", fill: rgb("#f7efe4"))
  #dnode(3.8cm, 0.1cm, 2.3cm, 0.75cm, "offset (12 b)", fill: rgb("#eef3f7"))

  #darrow(0.95cm, 0.95cm, 0.95cm, 1.65cm)
  #dnode(0pt, 1.7cm, 3.0cm, 2.6cm, "OUTER TABLE\n1024 entries\n(4 KB — one page)", fill: rgb("#dce9f2"))
  #darrow(3.05cm, 2.3cm, 4.65cm, 2.3cm, label: "p1 picks")
  #dnode(4.7cm, 1.7cm, 3.0cm, 1.1cm, "inner table 0\n1024 entries", fill: rgb("#eef3f7"))
  #dnode(4.7cm, 3.0cm, 3.0cm, 1.1cm, "inner table 7\n1024 entries", fill: rgb("#eef3f7"))
  #darrow(7.75cm, 2.25cm, 9.35cm, 2.25cm, label: "p2 picks")
  #dnode(9.4cm, 1.9cm, 2.6cm, 0.75cm, "frame f", fill: rgb("#f7efe4"))
  #darrow(12.05cm, 2.25cm, 13.05cm, 2.25cm)
  #dnode(13.1cm, 1.9cm, 3.2cm, 0.75cm, "f : offset", fill: white)

  #dnode(4.7cm, 4.3cm, 7.3cm, 0.8cm, "inner tables for untouched regions are simply ABSENT — that is the saving", fill: rgb("#f3f8f4"))
  #dnode(0pt, 4.4cm, 4.4cm, 0.7cm, "cost: 2 RAM reads per miss", fill: rgb("#fdf4f4"))
]

#ex(9, tier: 2, asked: "Shopee · pattern")[
32-bit addresses, 4 KB pages, 4-byte entries, two-level paging with a 10/10/12 split. A
process actually uses only 12 MB: 8 MB of code+data at the bottom of the address space and
4 MB of stack at the top. Compare the page-table memory used by the flat scheme and the
two-level scheme.
]
#sol[
*Flat scheme* — always $2^20$ entries $times 4$ B $= 4$ MB, whether you use 12 MB or 4 GB.

*Two-level scheme* — count what is actually needed.

Step 1 — outer table: 1024 entries $times 4$ B $= 4096$ B $= 4$ KB. Always present.

Step 2 — how much does one inner table cover?
$ 1024 "entries" times 4"KB per page" = 4 "MB of address space per inner table" $

Step 3 — inner tables needed:
- 8 MB of code+data $=$ 2 inner tables.
- 4 MB of stack $=$ 1 inner table.
- Total 3 inner tables $times 4$ KB each $= 12$ KB.

Step 4 — total: $4 "KB" + 12 "KB" = 16$ KB.
#ans[Flat: 4 MB. Two-level: 16 KB — 256 times smaller. The price is one extra memory read on every TLB miss.]

This is the trade-off sentence the interviewer wants: *hierarchical paging trades time
(more levels to walk) for space (unused regions cost nothing).*
]

#subsection[Inverted page tables]

Flip the direction. Instead of one table per process indexed by page, keep *one* table for
the whole machine, with one entry per *physical frame*, holding `(pid, page number)`.

#table(columns: (auto, auto),
  [*Good*], [*Bad*],
  [Size depends on RAM, not on the number of processes or the width of the address space. One table, period.], [You cannot index it by page number — you must *search* it. Fixed with a hash table, which adds another memory access.],
  [A 64-bit address space costs nothing extra.], [Sharing memory between processes is awkward: one frame, but it needs to appear under two different `(pid, page)` keys.],
)

#section[Segmentation]

Paging splits memory into equal blocks that mean nothing to the programmer. Segmentation
splits it into blocks that *do* mean something: code, globals, heap, stack, one array.
Segments have *different sizes*.

#formulas(title: "Segmentation arithmetic")[
A logical address is a pair: $(s, d)$ = (segment number, offset within segment).

The segment table holds, for each $s$, a *base* and a *limit*.

$ "if " d < "limit"[s]: quad "physical" = "base"[s] + d $
$ "else: trap (segmentation fault)" $

Note the difference from paging: here the offset *is added*. In paging it is concatenated.
That is because segments have arbitrary sizes and arbitrary bases; pages and frames are
aligned to a power of two.
]

#ex(10, tier: 1, asked: "Cognizant · pattern")[
Segment table:

#table(columns: (auto, auto, auto),
  [*Segment*], [*Base*], [*Limit*],
  [0], [1400], [600],
  [1], [6300], [250],
  [2], [4300], [1100],
  [3], [3200], [580],
)

Translate (0, 430), (2, 88), (3, 579) and (1, 250).
]
#sol[
*(0, 430)*: is $430 < 600$? Yes. $1400 + 430 = 1830$.

*(2, 88)*: is $88 < 1100$? Yes. $4300 + 88 = 4388$.

*(3, 579)*: is $579 < 580$? Yes, by one. $3200 + 579 = 3779$.

*(1, 250)*: is $250 < 250$? *No* — the test is strictly less than. Offsets run 0 to 249.
Trap.
#ans[1830, 4388, 3779, and a trap (segmentation fault) for (1, 250).]
]

#trap[
The limit check is $d < "limit"$, never $d <= "limit"$. Offset 250 in a 250-byte segment is
the 251st byte. Exam writers love this off-by-one.
]

#subsection[Paging vs segmentation — the comparison table]

#table(columns: (auto, auto, auto),
  [], [*Paging*], [*Segmentation*],
  [Block size], [Fixed (e.g. 4 KB)], [Variable — as big as the logical unit needs],
  [Chosen by], [The OS / hardware], [The programmer or compiler],
  [Address form], [One number, split into page + offset], [A visible pair (segment, offset)],
  [Offset combined by], [Concatenation (no adder needed)], [Addition to the base],
  [External fragmentation], [None], [Yes — variable sizes leave holes],
  [Internal fragmentation], [Yes — last page half empty], [None (segment fits exactly)],
  [Protection granularity], [Per page — meaningless units], [Per segment — "this whole array is read-only" is natural],
  [Sharing], [Awkward: share page by page], [Natural: share a whole code segment],
)

#note[
*Segmented paging* (what x86 historically did, and what "segment + page table" means):
first use the segment number to find a *per-segment page table*, then page within it. You
get segmentation's meaningful units and protection, plus paging's freedom from external
fragmentation. Modern 64-bit operating systems mostly ignore segmentation and use flat
paging only.
]

#section[Virtual memory and demand paging]

Now the stretch. Do not load a page until it is touched. Keep the rest on disk in the *swap
space* (or in the executable file itself).

#diagram(height: 7.6cm, caption: "What happens on a page fault. Steps 3 and 5 are the expensive ones — disk I/O, measured in milliseconds.")[
  #dnode(0pt, 0.1cm, 3.6cm, 0.8cm, "1. CPU accesses page p", fill: white)
  #darrow(1.8cm, 0.95cm, 1.8cm, 1.45cm)
  #dnode(0pt, 1.5cm, 3.6cm, 0.9cm, "2. MMU: valid bit = 0\n-> TRAP to OS", fill: rgb("#fdf4f4"))
  #darrow(3.65cm, 1.95cm, 5.15cm, 1.95cm)
  #dnode(5.2cm, 1.5cm, 4.0cm, 0.9cm, "3. OS checks: is this a\nlegal address at all?", fill: rgb("#eef3f7"))
  #darrow(9.25cm, 1.95cm, 10.75cm, 1.95cm, label: "no")
  #dnode(10.8cm, 1.5cm, 4.4cm, 0.9cm, "kill the process\n(SIGSEGV)", fill: rgb("#f2dcdc"))
  #darrow(7.2cm, 2.45cm, 7.2cm, 3.05cm, label: "yes")
  #dnode(5.2cm, 3.1cm, 4.0cm, 0.9cm, "4. Find a free frame\n(else run replacement)", fill: rgb("#eef3f7"))
  #darrow(7.2cm, 4.05cm, 7.2cm, 4.65cm)
  #dnode(5.2cm, 4.7cm, 4.0cm, 0.9cm, "5. Read page in from disk\n~5-10 ms  <-- the cost", fill: rgb("#f7efe4"))
  #darrow(5.15cm, 5.15cm, 3.65cm, 5.15cm)
  #dnode(0pt, 4.7cm, 3.6cm, 0.9cm, "6. Update PTE:\nframe = f, valid = 1", fill: rgb("#eef3f7"))
  #darrow(1.8cm, 5.65cm, 1.8cm, 6.15cm)
  #dnode(0pt, 6.2cm, 3.6cm, 0.9cm, "7. RESTART the faulting\ninstruction", fill: rgb("#f3f8f4"))

  #dnode(10.8cm, 3.1cm, 4.4cm, 2.5cm, "while step 5 runs, this\nprocess is BLOCKED and\nthe CPU runs someone else.\n\nA page fault is not an\nerror. An invalid access is.", fill: rgb("#fafbfc"))
]

#trap[
"Page fault means the program crashed." *No.* A page fault is a normal, planned event —
every program takes thousands of them while starting up. The crash case is a *segmentation
fault*: an access to an address with no legal mapping at all. Different thing, step 3 of the
diagram.
]

#formulas(title: "Effective access time under demand paging")[
Let $p$ = page-fault rate ($0 <= p <= 1$), $m$ = memory access time, $F$ = page-fault
service time (dominated by disk I/O).

$ "EAT" = (1 - p) times m + p times F $

Because $F$ is measured in milliseconds and $m$ in nanoseconds, $F$ is roughly
*40,000 times* larger than $m$. So even a tiny $p$ dominates the sum.
]

#ex(11, tier: 2, asked: "Agoda · pattern")[
Memory access is 200 ns. A page fault takes 8 ms to service. (a) Find EAT when 1 access in
1000 faults. (b) What fault rate keeps the slowdown under 10%?
]
#sol[
First put both times in the same unit: $8 "ms" = 8,000,000$ ns.

*(a)* $p = 0.001$.
$ "EAT" = (1 - 0.001) times 200 + 0.001 times 8,000,000 $
$ = 199.8 + 8000 = 8199.8 "ns" $
Slowdown $= 8199.8 / 200 = 41.0$ times. One fault per thousand accesses makes the machine
*41 times slower*.

*(b)* "Under 10% slowdown" means $"EAT" <= 220$ ns.
$ (1-p) times 200 + p times 8,000,000 <= 220 $
$ 200 - 200p + 8,000,000 p <= 220 $
$ 7,999,800 p <= 20 $
$ p <= 20 / 7,999,800 = 2.5 times 10^(-6) $
That is about *1 fault in 400,000 accesses*.
#ans[(a) EAT = 8199.8 ns, a 41x slowdown. (b) $p < 2.5 times 10^(-6)$, i.e. fewer than 1 fault per 400,000 accesses.]

The lesson to say out loud: demand paging only works because the fault rate in real
programs is far below one in a million, thanks to locality.
]

#note[
The same arithmetic, tabulated. Memory 200 ns, fault 8 ms:

#table(columns: (auto, auto, auto),
  [*Fault rate $p$*], [*EAT*], [*Slowdown*],
  [0], [200 ns], [1.0x],
  [$10^(-6)$], [208 ns], [1.04x],
  [$10^(-5)$], [280 ns], [1.4x],
  [$10^(-4)$], [1000 ns], [5.0x],
  [$10^(-3)$], [8200 ns], [41x],
  [$10^(-2)$], [80,198 ns], [401x],
)
Each factor of 10 in $p$ costs you roughly a factor of 8 in speed once $p$ passes $10^(-5)$.
]

#section[Page replacement algorithms]

RAM is full and a page must come in. Which page leaves? This is the most-asked numerical
topic in the whole OS syllabus, so we will do it slowly and completely.

#formulas(title: "The rules for tracing")[
+ A *reference string* is the sequence of page numbers touched.
+ Every miss is a *page fault*. Count them.
+ The first $F$ distinct pages always fault (cold start) — these are *compulsory* faults.
+ *FIFO*: evict the page that arrived earliest. A hit does *not* change its position.
+ *LRU*: evict the page whose last *use* is oldest. A hit *does* refresh it.
+ *Optimal (OPT / MIN)*: evict the page whose *next use* is farthest in the future; a page
  never used again is the best victim. Needs the future, so it is only a benchmark.
+ *LFU*: evict the least frequently used. *MFU*: evict the most frequently used (argument:
  the page with the smallest count just arrived and is probably still needed).
+ *Clock / second chance*: FIFO plus a reference bit. Give a page one pardon before
  evicting it.

Always: $"faults" + "hits" = "length of the reference string"$. Use this to check yourself.
]

We will use one reference string throughout so the algorithms can be compared fairly:

$ 5, 2, 1, 3, 4, 3, 2, 5, 3, 1, 2, 1 quad "with 3 frames" $

#subsection[FIFO, step by step]

#ex(12, tier: 1, asked: "TCS Digital · pattern")[
Trace FIFO on the string above with 3 frames. Count the faults.
]
#sol[
Write the frames as a queue: the *left* end is the oldest and the next victim.

#table(columns: (auto, auto, auto, auto, auto),
  [*\#*], [*Ref*], [*Frames (old -> new)*], [*Fault?*], [*Evicted*],
  [1], [5], [5], [F], [--],
  [2], [2], [5, 2], [F], [--],
  [3], [1], [5, 2, 1], [F], [--],
  [4], [3], [2, 1, 3], [F], [5],
  [5], [4], [1, 3, 4], [F], [2],
  [6], [3], [1, 3, 4], [hit], [--],
  [7], [2], [3, 4, 2], [F], [1],
  [8], [5], [4, 2, 5], [F], [3],
  [9], [3], [2, 5, 3], [F], [4],
  [10], [1], [5, 3, 1], [F], [2],
  [11], [2], [3, 1, 2], [F], [5],
  [12], [1], [3, 1, 2], [hit], [--],
)

Count the F rows: 1, 2, 3, 4, 5, 7, 8, 9, 10, 11 — that is *10 faults* and 2 hits.
Check: $10 + 2 = 12$ = length of the string. Correct.
#ans[FIFO with 3 frames: 10 page faults, 2 hits.]

Look at row 6. Page 3 is used, but its place in the queue does not move. That is the whole
weakness of FIFO — it measures *age*, not *usefulness*.
]

#subsection[LRU, step by step]

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
Same string, 3 frames, LRU.
]
#sol[
Now the list is ordered by *last use*: left = least recently used = next victim. A hit
moves that page to the right end.

#table(columns: (auto, auto, auto, auto, auto),
  [*\#*], [*Ref*], [*Frames (LRU -> MRU)*], [*Fault?*], [*Evicted*],
  [1], [5], [5], [F], [--],
  [2], [2], [5, 2], [F], [--],
  [3], [1], [5, 2, 1], [F], [--],
  [4], [3], [2, 1, 3], [F], [5],
  [5], [4], [1, 3, 4], [F], [2],
  [6], [3], [1, 4, 3], [hit], [--],
  [7], [2], [4, 3, 2], [F], [1],
  [8], [5], [3, 2, 5], [F], [4],
  [9], [3], [2, 5, 3], [hit], [--],
  [10], [1], [5, 3, 1], [F], [2],
  [11], [2], [3, 1, 2], [F], [5],
  [12], [1], [3, 2, 1], [hit], [--],
)

Faults: rows 1, 2, 3, 4, 5, 7, 8, 10, 11 = *9 faults*, 3 hits. Check $9 + 3 = 12$.
#ans[LRU with 3 frames: 9 page faults.]

Compare row 6 with FIFO's row 6. FIFO left page 3 at the front of the queue and evicted it
at step 8. LRU moved it to the back, so at step 9 it was still resident — one extra hit.
]

#subsection[Optimal, step by step]

#ex(14, tier: 2, asked: "Sea/Shopee · pattern")[
Same string, 3 frames, Optimal. Show how you pick each victim.
]
#sol[
Index the string so you can look ahead:

#table(columns: (auto,auto,auto,auto,auto,auto,auto,auto,auto,auto,auto,auto,auto),
  [pos], [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],
  [page],[5],[2],[1],[3],[4],[3],[2],[5],[3],[1],[2],[1],
)

Steps 1-3: cold faults, frames = {5, 2, 1}.

*Step 4, need 3.* Next uses after position 4: page 5 at position 8; page 2 at position 7;
page 1 at position 10. Farthest is page *1* (position 10). Evict 1. Frames {5, 2, 3}.

*Step 5, need 4.* Next uses after position 5: page 5 -> 8; page 2 -> 7; page 3 -> 6.
Farthest is page *5* (position 8). Evict 5. Frames {4, 2, 3}.

*Step 6, page 3* — hit. *Step 7, page 2* — hit.

*Step 8, need 5.* Next uses after 8: page 4 -> never again; page 2 -> 11; page 3 -> 9.
A page never used again is the perfect victim. Evict *4*. Frames {5, 2, 3}.

*Step 9, page 3* — hit.

*Step 10, need 1.* Next uses after 10: page 5 -> never; page 2 -> 11; page 3 -> never.
Two candidates never used again; take either, say *5*. Frames {1, 2, 3}.

*Steps 11 and 12* — page 2 hit, page 1 hit.

Faults at steps 1, 2, 3, 4, 5, 8, 10 = *7 faults*.
#ans[Optimal with 3 frames: 7 page faults — the lower bound no real algorithm can beat.]
]

#subsection[All three side by side]

#table(columns: (auto, auto, auto, auto),
  [*Frames*], [*FIFO*], [*LRU*], [*Optimal*],
  [3], [10], [9], [7],
  [4], [8], [7], [6],
)

#trick[
In an exam, compute *Optimal first*. It is the floor. If your FIFO or LRU number comes out
*below* the optimal number, you have made an arithmetic mistake — go back. Optimal
$<=$ LRU and Optimal $<=$ FIFO, always.
]

#code(lang: "js", caption: "replace.js — all three, so you can check any string yourself")[
```js
function fifo(ref, frames) {
  const mem = [];                 // queue: oldest first
  let faults = 0;
  for (const p of ref) {
    if (mem.includes(p)) continue;
    if (mem.length === frames) mem.shift();
    mem.push(p);
    faults++;
  }
  return faults;
}

function lru(ref, frames) {
  const mem = new Map();          // Map keeps insertion order -> first key = least recent
  let faults = 0;
  for (const p of ref) {
    if (mem.has(p)) { mem.delete(p); mem.set(p, true); continue; }
    if (mem.size === frames) mem.delete(mem.keys().next().value);
    mem.set(p, true);
    faults++;
  }
  return faults;
}

function opt(ref, frames) {
  const mem = [];
  let faults = 0;
  for (let i = 0; i < ref.length; i++) {
    const p = ref[i];
    if (mem.includes(p)) continue;
    if (mem.length === frames) {
      let victim = 0, best = -1;
      for (let j = 0; j < mem.length; j++) {
        let next = ref.indexOf(mem[j], i + 1);
        if (next === -1) next = Infinity;      // never used again -> perfect victim
        if (next > best) { best = next; victim = j; }
      }
      mem[victim] = p;
    } else mem.push(p);
    faults++;
  }
  return faults;
}

const ref = [5, 2, 1, 3, 4, 3, 2, 5, 3, 1, 2, 1];
for (const f of [3, 4])
  console.log(`frames=${f}  FIFO=${fifo(ref, f)}  LRU=${lru(ref, f)}  OPT=${opt(ref, f)}`);
```
]

#note[
Output from `node replace.js`:
```
frames=3  FIFO=10  LRU=9  OPT=7
frames=4  FIFO=8  LRU=7  OPT=6
```
matching the hand traces above. The `lru` function is worth memorising separately: *a JS
`Map` gives you an LRU cache almost for free*, because `Map` preserves insertion order and
`mem.keys().next().value` is the oldest key. This exact trick is a common coding-round
question too.
]

#subsection[Clock (second chance)]

True LRU needs a timestamp update on every memory access — far too expensive in hardware.
Clock is the practical approximation every real OS uses.

#formulas(title: "The clock algorithm")[
Frames are arranged in a circle. A hand points at the next candidate. Each frame has a
*reference bit* R, set to 1 by hardware whenever the page is accessed.

On a fault, repeat:
- If R of the frame under the hand is *0* -> evict this page, put the new page here with
  R = 0, advance the hand, stop.
- If R is *1* -> set R to 0 (that is the "second chance"), advance the hand, look again.

A page that keeps being used keeps having R reset to 1 before the hand comes round again,
so it survives. A page nobody touches meets the hand with R = 0 and dies.

*Enhanced clock* uses the pair (R, D) where D is the dirty bit, and prefers victims in this
order: (0,0) best, then (0,1), then (1,0), then (1,1) worst.
]

#ex(15, tier: 2, asked: "DBS · pattern")[
Trace clock on $5, 2, 1, 3, 4, 3, 2, 5, 3, 1, 2, 1$ with 3 frames. Start with the hand at
frame 0 and all frames empty.
]
#sol[
Write frames as `[f0 f1 f2]`, R bits under them, and mark where the hand stops.

#table(columns: (auto, auto, auto, auto, auto, auto),
  [*\#*], [*Ref*], [*Frames*], [*R bits*], [*Hand after*], [*Result*],
  [1], [5], [5, --, --], [0, 0, 0], [1], [F — empty frame],
  [2], [2], [5, 2, --], [0, 0, 0], [2], [F — empty frame],
  [3], [1], [5, 2, 1], [0, 0, 0], [0], [F — empty frame],
  [4], [3], [3, 2, 1], [0, 0, 0], [1], [F — f0 had R=0, evict 5],
  [5], [4], [3, 4, 1], [0, 0, 0], [2], [F — f1 had R=0, evict 2],
  [6], [3], [3, 4, 1], [1, 0, 0], [2], [hit — set R of 3],
  [7], [2], [3, 4, 2], [1, 0, 0], [0], [F — f2 had R=0, evict 1],
  [8], [5], [3, 5, 2], [0, 0, 0], [2], [F — f0 R=1, pardon it, f1 R=0, evict 4],
  [9], [3], [3, 5, 2], [1, 0, 0], [2], [hit],
  [10], [1], [3, 5, 1], [1, 0, 0], [0], [F — f2 R=0, evict 2],
  [11], [2], [3, 2, 1], [0, 0, 0], [2], [F — f0 R=1, pardon, f1 R=0, evict 5],
  [12], [1], [3, 2, 1], [0, 0, 1], [2], [hit],
)

Look carefully at step 8. The hand is at frame 0, which holds page 3 with R = 1. That is
the second chance: set R to 0, move on, do *not* evict. Frame 1 holds page 4 with R = 0, so
page 4 dies.

Faults: steps 1, 2, 3, 4, 5, 7, 8, 10, 11 = *9 faults*.
#ans[Clock with 3 frames: 9 faults — exactly matching LRU here, at a fraction of LRU's hardware cost.]

That match is the point of the algorithm. Clock is not always equal to LRU, but it is
usually close, and it costs one bit per frame instead of a timestamp per frame.
]

#subsection[Belady's anomaly]

#formulas(title: "Belady's anomaly")[
*More frames can cause MORE page faults.* It happens with FIFO. It can never happen with
LRU or Optimal, because those are *stack algorithms*: the set of pages held with $n$ frames
is always a subset of the set held with $n+1$ frames, so adding a frame can only help.
]

#ex(16, tier: 3, asked: "Microsoft · pattern")[
Find the fault counts for FIFO on $2, 5, 3, 6, 2, 5, 4, 2, 5, 3, 6, 4$ with 3 frames and
with 4 frames. Then do LRU on the same string with 3 and 4 frames. Explain what you see.
]
#sol[
*FIFO, 3 frames:*

#table(columns: (auto, auto, auto, auto),
  [*\#*], [*Ref*], [*Frames (old->new)*], [*Result*],
  [1], [2], [2], [F], [2], [5], [2, 5], [F],
  [3], [3], [2, 5, 3], [F], [4], [6], [5, 3, 6], [F, out 2],
  [5], [2], [3, 6, 2], [F, out 5], [6], [5], [6, 2, 5], [F, out 3],
  [7], [4], [2, 5, 4], [F, out 6], [8], [2], [2, 5, 4], [hit],
  [9], [5], [2, 5, 4], [hit], [10], [3], [5, 4, 3], [F, out 2],
  [11], [6], [4, 3, 6], [F, out 5], [12], [4], [4, 3, 6], [hit],
)
Faults = *9*.

*FIFO, 4 frames:*

#table(columns: (auto, auto, auto, auto),
  [*\#*], [*Ref*], [*Frames (old->new)*], [*Result*],
  [1], [2], [2], [F], [2], [5], [2, 5], [F],
  [3], [3], [2, 5, 3], [F], [4], [6], [2, 5, 3, 6], [F],
  [5], [2], [2, 5, 3, 6], [hit], [6], [5], [2, 5, 3, 6], [hit],
  [7], [4], [5, 3, 6, 4], [F, out 2], [8], [2], [3, 6, 4, 2], [F, out 5],
  [9], [5], [6, 4, 2, 5], [F, out 3], [10], [3], [4, 2, 5, 3], [F, out 6],
  [11], [6], [2, 5, 3, 6], [F, out 4], [12], [4], [5, 3, 6, 4], [F, out 2],
)
Faults = *10*.

More memory, more faults. That is Belady's anomaly.

*LRU on the same string:* 3 frames gives 10 faults, 4 frames gives 8 faults — it went
*down*, as it must.
#ans[FIFO: 9 faults with 3 frames but 10 with 4 — Belady's anomaly. LRU: 10 with 3 frames, 8 with 4 — never anomalous, because LRU is a stack algorithm.]

*Why FIFO can do this.* At step 7 with 4 frames, page 2 is evicted even though it was used
at step 5 — FIFO only looks at arrival order, and with 4 frames page 2's arrival is still
the oldest. With 3 frames, page 2 had already been *re-loaded* at step 5, resetting its
arrival time, so it survived longer. Extra memory changed the arrival order in a way that
hurt.
]

#trap[
"Belady's anomaly proves FIFO is broken." It shows FIFO is not a stack algorithm. It does
*not* mean FIFO always gets worse with more frames — on average more frames still help. The
correct exam sentence: *"FIFO can suffer Belady's anomaly; LRU and Optimal cannot, because
they are stack algorithms."*
]

#subsection[LFU and MFU, briefly]

#table(columns: (auto, auto, auto),
  [*Policy*], [*Evicts*], [*Its failure mode*],
  [*LFU*], [Lowest access count], [A page used heavily at start-up keeps a huge count forever and never leaves, even when it is dead. Fixed with *ageing*: halve every count periodically.],
  [*MFU*], [Highest access count], [Rarely used. The argument is that a low count means "just arrived, probably still needed", but it throws out genuinely hot pages.],
)

#section[How many frames, and thrashing]

#subsection[Allocating frames between processes]

#table(columns: (auto, auto),
  [*Scheme*], [*Rule*],
  [*Equal allocation*], [$m$ frames, $n$ processes -> each gets $m\/n$. Unfair to big processes.],
  [*Proportional allocation*], [Process $i$ of virtual size $s_i$ gets $frac(s_i, sum s_j) times m$ frames.],
  [*Local replacement*], [A faulting process may only steal from its *own* frames. Its fault rate depends only on itself. Cannot exploit spare frames elsewhere.],
  [*Global replacement*], [A faulting process may steal *any* frame. Better throughput, but one bad process can now wreck another's performance.],
)

#ex(17, tier: 1, asked: "Infosys · pattern")[
There are 62 free frames and 3 processes of virtual sizes 20 KB, 60 KB and 120 KB.
Page size is 1 KB. Use proportional allocation.
]
#sol[
Total virtual size $= 20 + 60 + 120 = 200$ KB, so 200 pages.

$ "P1" = 20/200 times 62 = 0.10 times 62 = 6.2 arrow.r 6 "frames" $
$ "P2" = 60/200 times 62 = 0.30 times 62 = 18.6 arrow.r 18 "frames" $
$ "P3" = 120/200 times 62 = 0.60 times 62 = 37.2 arrow.r 37 "frames" $

Check: $6 + 18 + 37 = 61$. One frame is left over (we rounded down each time); give it to
the largest process or keep it in a free pool.
#ans[6, 18 and 37 frames. Always round *down* and account for the leftovers — never hand out more frames than exist.]
]

#subsection[Thrashing]

#formulas(title: "Thrashing")[
*Thrashing* = a process spends more time paging than executing. The chain of events:

+ Degree of multiprogramming rises, so each process gets fewer frames.
+ A process drops below the frames it needs for its current working set.
+ Its fault rate explodes; it blocks on disk constantly.
+ CPU utilisation *falls*.
+ The scheduler sees idle CPU and — wrongly — *admits more processes*.
+ Go to step 1. The system collapses.

The killer detail: *CPU utilisation goes down while the disk stays 100% busy*. That pair of
symptoms is the exam answer.
]

#diagram(height: 5.2cm, caption: "CPU utilisation against degree of multiprogramming. Past the peak, adding processes makes throughput collapse.")[
  #darrow(1.2cm, 4.2cm, 1.2cm, 0.3cm)
  #darrow(1.2cm, 4.2cm, 12.5cm, 4.2cm)
  #dnode(0pt, 1.6cm, 1.1cm, 0.9cm, "CPU\nuse", fill: white)
  #dnode(5.0cm, 4.3cm, 5.0cm, 0.6cm, "degree of multiprogramming", fill: white)

  #darrow(1.3cm, 4.1cm, 5.6cm, 0.9cm)
  #dnode(5.6cm, 0.55cm, 1.7cm, 0.7cm, "peak", fill: rgb("#f3f8f4"))
  #darrow(7.35cm, 1.1cm, 11.8cm, 3.6cm)
  #dnode(9.0cm, 2.3cm, 3.4cm, 0.9cm, "THRASHING\nzone", fill: rgb("#fdf4f4"))
  #dnode(2.0cm, 2.7cm, 3.2cm, 0.9cm, "more processes\n= more work done", fill: rgb("#fafbfc"))
  #dnode(11.0cm, 0.3cm, 5.0cm, 1.6cm, "Symptom pair to memorise:\nCPU utilisation FALLING\nwhile disk is 100% busy.\nCure: SUSPEND (swap out)\nsome processes.", fill: rgb("#eef3f7"))
]

#subsection[The working set model]

#formulas(title: "Working set")[
The *working set* $W(t, Delta)$ is the set of distinct pages referenced in the last
$Delta$ references ending at time $t$. $|W|$ is the *working set size* (WSS).

Rule: give each process enough frames to hold its working set. If
$sum_i "WSS"_i > "total frames"$, thrashing is guaranteed — suspend a process.

$Delta$ too small: misses parts of the real locality. $Delta$ too big: carries dead pages.
]

#ex(18, tier: 2, asked: "GIC · pattern")[
Reference string $5, 2, 1, 3, 4, 3, 2, 5, 3, 1, 2, 1$, window $Delta = 5$. Compute the
working set size at every step. What is the peak, and what does that tell you?
]
#sol[
At each position $t$, take the last 5 references (fewer at the start) and count *distinct*
pages.

#table(columns: (auto, auto, auto, auto),
  [*t*], [*Last 5 references*], [*Distinct set*], [*WSS*],
  [1], [5], [{5}], [1],
  [2], [5 2], [{5,2}], [2],
  [3], [5 2 1], [{5,2,1}], [3],
  [4], [5 2 1 3], [{5,2,1,3}], [4],
  [5], [5 2 1 3 4], [{5,2,1,3,4}], [5],
  [6], [2 1 3 4 3], [{2,1,3,4}], [4],
  [7], [1 3 4 3 2], [{1,3,4,2}], [4],
  [8], [3 4 3 2 5], [{3,4,2,5}], [4],
  [9], [4 3 2 5 3], [{4,3,2,5}], [4],
  [10], [3 2 5 3 1], [{3,2,5,1}], [4],
  [11], [2 5 3 1 2], [{2,5,3,1}], [4],
  [12], [5 3 1 2 1], [{5,3,1,2}], [4],
)
#ans[Peak WSS = 5 at t = 5; it settles at 4. Give this process 5 frames and it will barely fault after the cold start; give it 3 and it will thrash.]

Cross-check with our earlier traces: with 3 frames LRU took 9 faults, with 4 frames only 7.
The working set says 4-5 — and indeed that is where the faults stop falling steeply.
]

#code(lang: "js", caption: "ws.js — working set size over time")[
```js
function workingSet(ref, delta, t) {
  return new Set(ref.slice(Math.max(0, t - delta + 1), t + 1)).size;
}
const ref = [5, 2, 1, 3, 4, 3, 2, 5, 3, 1, 2, 1];
console.log('WSS(delta=5):', ref.map((_, t) => workingSet(ref, 5, t)).join(' '));
// prints: WSS(delta=5): 1 2 3 4 5 4 4 4 4 4 4 4
```
]

#subsection[Page-fault frequency (PFF) — the practical control]

Working sets are expensive to track exactly. PFF does the same job with a thermostat:

- Measure each process's fault rate.
- Rate above the upper bound -> the process needs more frames; give it one.
- Rate below the lower bound -> it has spare frames; take one away.
- No frames left to give -> suspend a process and free all of its frames.

#section[The clever tricks built on paging]

#subsection[Copy-on-write (COW)]

`fork()` should duplicate the parent's whole address space. Copying 2 GB to then
immediately `exec()` a new program would be absurd. So:

+ Parent and child share every page, and every shared page is marked *read-only*.
+ Reads are free — both processes read the same frames.
+ The first *write* to a shared page traps. The OS copies just that one page, gives the
  writer a private writable copy, and restarts the instruction.

So only pages actually modified are ever copied. A `fork()` followed by `exec()` copies
almost nothing.

#subsection[Memory-mapped files]

`mmap()` maps a file's bytes directly into the address space. Reading memory reads the
file; writing memory dirties the page and the OS writes it back later.

#table(columns: (auto, auto),
  [*Why it helps*], [*What it costs*],
  [No `read()` syscall per block; no copy from kernel buffer to user buffer.], [Page faults are now hidden inside ordinary loads — an innocent `arr[i]` can block for milliseconds.],
  [Two processes mapping the same file share the same physical frames — that is how shared libraries and shared memory work.], [File must fit in the address space; on 32-bit systems that was a real limit.],
)

#subsection[Demand zero and lazy allocation]

`malloc(1 GB)` usually succeeds instantly even on a small machine, because nothing is
allocated yet — the kernel just records the mapping. Frames appear on first touch, filled
with zeros. This is why a program can "successfully allocate" more memory than exists and
then be killed later when it actually writes to it (the Linux OOM killer).

#trap[
"`malloc` returning non-NULL means the memory is yours." On Linux with default overcommit
settings, *no*. The promise is only checked when you touch the page. This is why some
servers run with `vm.overcommit_memory = 2`.
]

#section[Locality: why any of this works at all]

Every trick in this chapter — TLB, demand paging, LRU, working sets — is a bet on
*locality*. If programs touched pages at random, none of it would work.

#formulas(title: "The two localities")[
- *Temporal locality* — a page touched now is likely to be touched again soon. (Loops,
  hot functions, a counter variable.) This is what LRU and clock exploit.
- *Spatial locality* — if you touch byte $x$, you will soon touch bytes near $x$.
  (Arrays, structs, sequential file reads.) This is why pages are 4 KB and not 8 bytes.

Code you write can destroy locality. The classic destroyer: walking a 2D array down the
*columns* when it is stored by *rows*.
]

#ex(19, tier: 3, asked: "Google · pattern")[
An array `int a[1024][1024]` of 4-byte integers is stored in row-major order. Page size is
4 KB, and the process has 100 frames. Compare the page faults for these two loops:

```
A:  for (i = 0..1023) for (j = 0..1023) a[i][j] = 0;
B:  for (j = 0..1023) for (i = 0..1023) a[i][j] = 0;
```
]
#sol[
Step 1 — how big is one row?
$ 1024 "elements" times 4 "bytes" = 4096 "bytes" = "exactly one page" $
So row $i$ sits entirely in page $i$. The array spans 1024 pages.

Step 2 — loop A walks along a row before moving to the next row. Each row is one page, so
each page is brought in once and all 1024 of its elements are used before you leave it.
$ "faults"_A = 1024 $

Step 3 — loop B walks *down a column*. The elements `a[0][j]`, `a[1][j]`, `a[2][j]`... are
in 1024 *different* pages. The process only has 100 frames, so by the time the loop comes
back to page 0 for column $j+1$, page 0 has long been evicted. Every single access faults.
$ "faults"_B = 1024 times 1024 = 1,048,576 $

Step 4 — ratio: $1048576 \/ 1024 = 1024$.
#ans[Loop A: 1024 faults. Loop B: 1,048,576 faults — 1024 times more, for identical output.]

Put a number on it: at 8 ms per fault, loop A takes about 8 seconds of paging and loop B
takes about 8,400 seconds — over two hours. *Same answer, same instructions, different
order.*

The follow-up an interviewer will ask: *"how many frames would loop B need to be fast?"*
Answer: 1024 — the whole array — because its working set for one pass of the outer loop is
every page. That is why the fix is to change the loop, not to buy RAM.
]

#trick[
If a question gives you an array, a page size and a loop, the first thing to compute is
*how many array elements fit in one page*. Everything else follows from that one number.
]

#section[Inside the kernel: buddy and slab allocators]

Paging hands out whole frames. But the kernel itself constantly needs *small* objects —
a 200-byte task structure, a 64-byte file handle. Two allocators sit on top of frames.

#subsection[The buddy system]

Memory is a power-of-two block. A request is rounded up to a power of two, and blocks are
split in half repeatedly until a block of the right size exists. The two halves of a split
are *buddies*; when both are free they merge back instantly.

#ex(20, tier: 2, asked: "Razer · pattern")[
A 1 MB region is managed by a buddy allocator with a 64 KB minimum block. Requests arrive:
70 KB, then 35 KB, then 80 KB. Show the splits and compute the total internal
fragmentation.
]
#sol[
*Request 1: 70 KB.* Round up to the next power of two: 128 KB.

Splits needed, starting from 1024 KB:
$ 1024 arrow.r 512 + 512 quad 512 arrow.r 256 + 256 quad 256 arrow.r 128 + 128 $
Allocate one 128 KB block. Free list now holds: 128, 256, 512.
Waste inside it: $128 - 70 = 58$ KB.

*Request 2: 35 KB.* Round up to 64 KB. Split the free 128 into $64 + 64$; allocate one.
Free list: 64, 256, 512. Waste: $64 - 35 = 29$ KB.

*Request 3: 80 KB.* Round up to 128 KB. No free 128 exists, so split the 256 into
$128 + 128$; allocate one. Free list: 64, 128, 512. Waste: $128 - 80 = 48$ KB.

Total internal fragmentation:
$ 58 + 29 + 48 = 135 "KB" $
#ans[Free blocks left: 64 KB, 128 KB, 512 KB. Internal fragmentation = 135 KB out of 272 KB allocated — about 50% wasted.]

*The trade-off sentence:* the buddy system merges free blocks in $O(1)$ by just checking
one buddy address, which makes it fast and keeps external fragmentation low — but rounding
every request to a power of two can waste up to *just under 50%* of each allocation.
]

#subsection[The slab allocator]

The buddy system's waste is unacceptable for objects the kernel allocates a million times.
The slab allocator fixes it:

+ For each *type* of kernel object, keep a cache.
+ Each cache holds *slabs* — one or more contiguous frames, pre-carved into slots of
  exactly that object's size.
+ Allocation = pop a free slot. Free = push it back. No searching, no rounding.
+ Objects are kept *pre-initialised*, so reuse skips the constructor work.

#table(columns: (auto, auto),
  [*Buddy*], [*Slab*],
  [General purpose, any size], [One cache per object type],
  [Rounds to a power of two -> big internal waste], [Slots are exactly the object size -> near-zero waste],
  [Splitting and merging on every call], [Pop and push a free list],
  [Used for page-sized and larger requests], [Used for the kernel's small fixed-size objects],
)

#section[Sharing and protection]

#subsection[How two processes share one page]

Two page tables, two different page numbers, *the same frame number*. That is all sharing
is.

#diagram(height: 5.6cm, caption: "Shared memory and shared libraries: different virtual pages in different processes, pointing at one physical frame.")[
  #dnode(0pt, 0.2cm, 3.4cm, 0.6cm, "Process A page table", fill: white)
  #dnode(0pt, 0.9cm, 3.4cm, 0.6cm, "page 3  ->  frame 17", fill: rgb("#eef3f7"))
  #dnode(0pt, 1.55cm, 3.4cm, 0.6cm, "page 4  ->  frame 21", fill: rgb("#eef3f7"))
  #dnode(0pt, 2.2cm, 3.4cm, 0.6cm, "page 9  ->  frame 42", fill: rgb("#f7efe4"))

  #dnode(0pt, 3.5cm, 3.4cm, 0.6cm, "Process B page table", fill: white)
  #dnode(0pt, 4.2cm, 3.4cm, 0.6cm, "page 2  ->  frame 42", fill: rgb("#f7efe4"))
  #dnode(0pt, 4.85cm, 3.4cm, 0.6cm, "page 5  ->  frame 8", fill: rgb("#eef3f7"))

  #darrow(3.45cm, 2.5cm, 6.55cm, 2.5cm)
  #darrow(3.45cm, 4.5cm, 6.55cm, 2.9cm)
  #dnode(6.6cm, 2.2cm, 3.2cm, 1.0cm, "FRAME 42\n(one copy in RAM)", fill: rgb("#f7efe4"))

  #dnode(10.4cm, 0.6cm, 5.9cm, 1.5cm, "Same frame, different page\nnumbers. Neither process\nknows the other's numbers.", fill: rgb("#fafbfc"))
  #dnode(10.4cm, 2.3cm, 5.9cm, 1.5cm, "Marked read-only ->\nshared library or COW.\nMarked read-write ->\nshared-memory IPC.", fill: rgb("#eef3f7"))
  #dnode(10.4cm, 4.0cm, 5.9cm, 1.1cm, "This is why 200 processes\nrunning one binary use one\ncopy of its code.", fill: rgb("#f3f8f4"))
]

#ex(21, tier: 2, asked: "SCB · pattern")[
A server runs 150 copies of the same 8 MB program. Of the 8 MB, 6 MB is read-only code and
2 MB is per-process data. Page size 4 KB. How much RAM is used with sharing, and how much
without?
]
#sol[
*Without sharing:* $150 times 8 "MB" = 1200 "MB" approx 1.17 "GB"$.

*With sharing:* code is identical and read-only, so one copy suffices.
$ 6 "MB (shared code)" + 150 times 2 "MB (private data)" = 6 + 300 = 306 "MB" $

Saving: $1200 - 306 = 894$ MB, about a 75% reduction.

In frames: $306 "MB" \/ 4 "KB" = 78,336$ frames instead of 307,200.
#ans[306 MB with sharing versus 1200 MB without — the code pages are mapped once and appear in 150 page tables.]
]

#subsection[TLB reach — the number nobody computes]

#formulas(title: "TLB reach")[
$ "TLB reach" = "number of TLB entries" times "page size" $

If your working set is bigger than the TLB reach, you will miss the TLB constantly no
matter how good your replacement policy is.
]

#ex(22, tier: 3, asked: "D. E. Shaw · pattern")[
A CPU has 64 data-TLB entries. An in-memory analytics job has a 100 MB working set.
(a) What is the TLB reach with 4 KB pages? (b) With 2 MB huge pages? (c) What does this do
to the effective access time if a TLB miss costs a 4-level walk at 80 ns per level?
]
#sol[
*(a)* $64 times 4 "KB" = 256 "KB"$. The working set is 100 MB — that is *400 times* the
reach. Essentially every access to new data misses the TLB.

*(b)* $64 times 2 "MB" = 128 "MB"$. Now the whole 100 MB working set fits inside the TLB's
reach, so once warm, almost everything hits.

*(c)* A miss costs $4 times 80 = 320$ ns of walking, plus the data access.

With 4 KB pages, take the hit ratio as roughly 0 for streaming new data:
$ "EAT" approx 320 + 80 = 400 "ns per access" $
With 2 MB pages, take the hit ratio as roughly 0.99:
$ "EAT" approx 0.99 times 80 + 0.01 times 400 = 79.2 + 4 = 83.2 "ns" $
#ans[(a) 256 KB (b) 128 MB (c) roughly 400 ns per access falling to about 83 ns — a 4.8x speed-up from changing page size alone, with no code change.]

The cost you must mention: 2 MB pages waste up to 2 MB per mapping, and the kernel must
find physically contiguous 2 MB regions, which gets hard on a long-running fragmented
machine.
]

#section[Swapping, and what "swap" really means]

#table(columns: (auto, auto),
  [*Term*], [*What it actually is*],
  [*Swapping* (classical)], [Moving an *entire process* out to disk and back. Coarse, old, still used to relieve thrashing by suspending whole processes.],
  [*Paging out*], [Moving *individual pages* to disk. This is what actually happens minute to minute.],
  [*Swap space*], [The disk area holding paged-out anonymous memory (heap, stack). Code pages do not need it — they can be re-read from the executable.],
  [*Page in*], [Bringing a page back. Cost = one disk read.],
  [*Clean vs dirty eviction*], [Clean page: just drop it, 0 writes. Dirty page: write it out first, 1 write.],
)

#trap[
"All evicted pages get written to swap." No — only *dirty* pages, and only *anonymous*
ones. A clean code page is simply discarded and re-read from the program file when needed
again. This is why read-heavy processes evict almost for free.
]

#section[Practice]

#practice(tier: 0, time: "6 min")[
+ Page size 2 KB. How many bits of offset?
+ A 14-bit logical address with 512-byte pages. How many pages?
+ Which fragmentation does paging cause?
+ Name the bit that tells the OS a page must be written back before eviction.
+ Reference string $1,2,3,1,2,3$ with 3 frames, FIFO. How many faults?
]

#key[
+ $2"KB" = 2^11$ -> *11 bits*.
+ Offset bits $= log_2 512 = 9$. Page bits $= 14 - 9 = 5$, so $2^5 = $ *32 pages*.
+ *Internal* fragmentation (last page partly empty). It removes external fragmentation.
+ The *dirty* (modified) bit.
+ 3 cold faults, then everything hits: *3 faults*.
]

#practice(tier: 1, time: "14 min")[
+ TLB access 15 ns, memory access 120 ns, hit ratio 90%, one-level page table. Find EAT.
+ 32-bit addresses, 8 KB pages, 4-byte PTEs. Size of a flat page table?
+ A process of 42,000 bytes with 8 KB pages. Pages needed and internal fragmentation?
+ Trace LRU on $3,1,4,1,5,9,2,6,5,3$ with 3 frames. Faults?
+ Segment table: seg 5 has base 2900, limit 420. Translate (5, 419) and (5, 420).
]

#key[
+ Hit: $15 + 120 = 135$. Miss: $15 + 120 + 120 = 255$. $"EAT" = 0.9(135) + 0.1(255) = 121.5 + 25.5 = 147$ ns.
+ Offset bits $= log_2 8192 = 13$. Entries $= 2^(32-13) = 2^19 = 524288$. Size $= 524288 times 4 = 2 "MB"$ *(2 MB)*.
+ $42000\/8192 = 5.13$, round up to *6 pages*. Given $6 times 8192 = 49152$ bytes. Waste $= 49152 - 42000 = 7152$, so *7152 bytes* of internal fragmentation.
+ Trace: 3(F) 1(F) 4(F) 1(hit) 5(F, out 3) 9(F, out 4) 2(F, out 1) 6(F, out 5) 5(F, out 9) 3(F, out 2) = *9 faults*, 1 hit. Check $9+1=10$.
+ $(5,419)$: $419 < 420$, so $2900 + 419 = 3319$ -> *3319*. $(5,420)$: $420 < 420$ is false -> *trap*.
]

#practice(tier: 2, time: "18 min")[
+ A 48-bit virtual address with 4 KB pages and 8-byte PTEs. How many levels of page table are needed if every table must fit in exactly one page?
+ Memory access 100 ns, page fault service 6 ms. What fault rate gives EAT = 300 ns?
+ Trace *clock* on $1,2,3,4,1,2,5,1,2,3$ with 3 frames, hand starting at frame 0.
+ Two processes each `fork()` and immediately `exec()`. Explain in three lines why COW makes this nearly free, and name the one case where COW costs *more* than a plain copy.
]

#key[
+ Offset = 12 bits, leaving $48 - 12 = 36$ page-number bits. One page holds $4096\/8 = 512 = 2^9$ entries, so each level consumes 9 bits. $36 \/ 9 = 4$, so *4 levels*.
+ 6 ms = 6,000,000 ns. $(1-p)100 + 6000000 p = 300$, so $100 + 5999900 p = 300$, giving $p = 200\/5999900 approx 3.33 times 10^(-5)$ — *about 1 fault in 30,000 accesses*.
+ 1(F) 2(F) 3(F) [frames 1,2,3 R=0,0,0, hand at 0] 4(F, f0 R=0, evict 1 -> 4,2,3) 1(F, f1 R=0, evict 2 -> 4,1,3) 2(F, f2 R=0, evict 3 -> 4,1,2) 5(F, f0 R=0, evict 4 -> 5,1,2) 1(hit, R of 1 -> 1) 2(hit, R of 2 -> 1) 3(F: f1 R=1 pardon, f2 R=1 pardon, f0 R=0 evict 5 -> 3,1,2). Total *8 faults*.
+ COW shares all pages read-only; `exec()` then throws the whole address space away, so *zero* pages were ever copied. COW costs more when the child writes to nearly every page anyway — you then pay one trap per page *plus* the copy, instead of one bulk copy.
]

#practice(tier: 3, time: "22 min")[
+ A database server shows 100% disk utilisation and 15% CPU utilisation, and adding worker processes makes both worse. Diagnose it, and give two fixes: one immediate, one structural.
+ Explain why huge pages (2 MB) help a large in-memory database but can hurt a machine running many small processes.
+ Prove that LRU cannot suffer Belady's anomaly. (Hint: show the resident set with $n$ frames is always contained in the resident set with $n+1$ frames.)
+ You must design a replacement policy for a phone, where evicting a dirty page costs a flash write and flash has limited write cycles. What do you change about clock, and what does it cost you?
]

#key[
+ *Diagnosis:* thrashing. The pair "CPU falling, disk saturated, more processes makes it worse" is decisive — the combined working sets exceed RAM. *Immediate:* reduce the degree of multiprogramming — suspend or cap worker processes (lower the connection-pool size). *Structural:* add RAM, or shrink each worker's working set (smaller buffers, smaller result sets, better indexes so fewer pages are touched per query).
+ *Helps:* one TLB entry covers 2 MB instead of 4 KB, so a 64-entry TLB reaches 128 MB instead of 256 KB — TLB misses collapse, and page-table walks get shorter. *Hurts:* internal fragmentation is now up to 2 MB per mapping, so many small processes waste enormous memory, and the OS must find *physically contiguous* 2 MB regions, which fragmenting memory makes hard.
+ Let $S_n (t)$ be the set of pages resident after $t$ references with $n$ frames under LRU. LRU keeps exactly the $n$ most recently used distinct pages. The $n$ most recently used pages are, by definition, a subset of the $n+1$ most recently used pages. So $S_n (t) subset.eq S_(n+1)(t)$ for every $t$. Therefore any reference that hits with $n$ frames also hits with $n+1$ frames, so faults with $n+1$ frames $<=$ faults with $n$ frames. No anomaly is possible. The same argument works for Optimal (the $n$ pages with nearest next use are a subset of the $n+1$ such pages).
+ Use *enhanced clock*: prefer victims in the order (R=0,D=0), (R=0,D=1), (R=1,D=0), (R=1,D=1) — i.e. always take a clean page first, and give dirty pages an extra pardon. Add background *write-back* so pages are cleaned while the device is idle, turning them into cheap victims later. *Cost:* you sometimes evict a clean page that was more useful than a dirty one, so your hit rate drops slightly; you have traded a little CPU performance for flash lifetime. Also, the scan may now go round the clock twice, so eviction takes longer.
]

#section[Rapid fire: one-line answers]

#formulas(title: "Say these in one breath")[
+ *Logical vs physical address?* Logical is what the CPU produces; physical is what reaches RAM. The MMU converts.
+ *Page vs frame?* Page is a block of virtual memory; frame is a block of physical memory. Same size.
+ *What splits a logical address?* Low $log_2("page size")$ bits are the offset; the rest is the page number.
+ *Physical address formula?* frame $times$ page size $+$ offset.
+ *What is in a page-table entry?* Frame number, valid bit, protection bits, dirty bit, referenced bit.
+ *What does the valid bit 0 cause?* A page fault.
+ *Page fault vs segmentation fault?* Page fault is normal and recoverable; segfault is an illegal address and kills the process.
+ *What is a TLB?* A small fast cache of recent page-to-frame translations, inside the MMU.
+ *EAT with a TLB?* $alpha(t+m) + (1-alpha)(t+2m)$ for one-level tables.
+ *Does a context switch flush the TLB?* Classically yes; modern CPUs avoid it with ASID/PCID tags.
+ *Internal fragmentation?* Waste *inside* an allocated block — paging's last page.
+ *External fragmentation?* Free memory exists but is split into unusable holes — contiguous allocation and segmentation.
+ *Which fit is usually fastest?* First fit. Worst fit is usually the worst overall.
+ *Why multi-level page tables?* A flat 32-bit table costs 4 MB per process; hierarchy lets untouched regions cost nothing.
+ *What is an inverted page table?* One table for the whole machine, one entry per frame, keyed by (pid, page). Small, but needs hashing to search.
+ *Paging vs segmentation in one line?* Paging = fixed blocks chosen by the OS, no external fragmentation; segmentation = variable meaningful blocks chosen by the program, natural protection and sharing.
+ *What is demand paging?* Bring a page in only when it is first referenced.
+ *EAT under demand paging?* $(1-p)m + p F$, where $F$ is the fault service time.
+ *Optimal page replacement?* Evict the page whose next use is farthest away. Unimplementable; used as a lower bound.
+ *Why does LRU beat FIFO?* FIFO measures age; LRU measures recency of use, which tracks locality.
+ *Belady's anomaly?* More frames giving more faults. FIFO can; LRU and Optimal cannot.
+ *Why can LRU never be anomalous?* It is a stack algorithm — the $n$ most recent pages are a subset of the $n+1$ most recent.
+ *What is the clock algorithm?* FIFO plus a reference bit; a page with R=1 gets one pardon, R reset to 0, hand moves on.
+ *What is enhanced clock?* Clock using (referenced, dirty) pairs; prefers clean victims to avoid a disk write.
+ *What is thrashing?* Paging more than executing. Symptom: CPU utilisation falls while the disk stays saturated.
+ *Cure for thrashing?* Lower the degree of multiprogramming — suspend processes; or add RAM.
+ *What is a working set?* The distinct pages touched in the last $Delta$ references. Give a process that many frames.
+ *What is copy-on-write?* Share pages read-only after fork; copy a page only when someone writes to it.
+ *Why do huge pages help?* Each TLB entry covers far more memory, so the TLB hit ratio rises and walks shorten.
+ *Why does `malloc` of 1 GB succeed on a small machine?* Lazy allocation — frames appear on first touch, not at allocation.
]

#revision[
*Address arithmetic.* offset bits $= log_2("page size")$; page bits $=$ address bits $-$
offset bits; entries $= 2^("page bits")$; physical $=$ frame $times$ page size $+$ offset.

*Two EATs, do not mix them up.*
- With a TLB: $alpha(t+m) + (1-alpha)(t + L m + m)$ — $L$ = page-table levels.
- With demand paging: $(1-p) m + p F$ — $F$ is the disk service time in the *same units*.

*Fragmentation.* Paging -> internal only. Segmentation and contiguous -> external.
Average internal waste with paging $approx$ half a page per process.

*Replacement, ranked on our string $5,2,1,3,4,3,2,5,3,1,2,1$ with 3 frames:*
OPT 7 $<$ LRU 9 $=$ Clock 9 $<$ FIFO 10. Compute OPT first; nothing may beat it.

*Belady's anomaly.* FIFO only. LRU and OPT are stack algorithms and are immune.

*Thrashing.* CPU utilisation down + disk 100% busy + adding processes makes it worse.
Cure = fewer processes, or more RAM. Model = working set; controller = page-fault frequency.

*Three sentences that win marks.*
+ "Paging removes external fragmentation but creates internal fragmentation."
+ "Hierarchical page tables trade time for space: unused regions cost nothing, but every
  TLB miss now costs one memory read per level."
+ "A page fault is normal; a segmentation fault is a bug."
]

]
