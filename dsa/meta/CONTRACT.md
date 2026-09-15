# BOOK 2 — DSA & CODING ROUND
Read /home/zayed/books/shared/CORE-RULES.md first. It is binding.

## What makes this book different
Code is the content. Every problem is solved with an APPROACH LADDER, never one jump to
the optimal answer:
  #approach(1, "Brute force", verdict: "O(n^2), too slow")  -> code -> #complexity(...)
  #approach(2, "Better", ...)                               -> code -> #complexity(...)
  #approach(3, "Optimal", ...)                              -> code -> #complexity(...)
Then one line naming the IDEA that unlocked the optimal ("sort first, then two pointers
collapse the inner loop"). A student must see WHY the optimal was reachable.

## Language — JavaScript primary, Python secondary
Also read /home/zayed/books/shared/LANGUAGE-POLICY.md — it is binding.
**JavaScript (Node) is the primary language of this book.** Every solution shows JS first.
**Python is the secondary language**, shown for each chapter's 2-3 signature problems where
it is meaningfully shorter or clearer. C++ is NOT used in this book.

Use modern, readable JS: `const`/`let`, arrow functions, `Map`/`Set`, destructuring.
Write plain functions, not classes, unless the problem is about a data structure.

### The JS traps you MUST teach (these cost real marks in interviews)
Every chapter that touches these must call them out in a #trap[] box:
1. **`arr.sort()` is LEXICOGRAPHIC by default.** `[10,9,1].sort()` gives `[1,10,9]`.
   Numbers always need `arr.sort((a, b) => a - b)`. This is the single most common JS bug.
2. **No built-in priority queue / heap.** Use the book's `MinHeap` (see the JS Toolkit
   appendix). Say so explicitly the first time a heap is needed in a chapter.
3. **No TreeMap / ordered set.** Teach the workaround: sorted array + binary search, or a
   Map plus a separately maintained sorted key list.
4. **Integers are doubles.** Exact only to `Number.MAX_SAFE_INTEGER` = 2^53 - 1. Anything
   that can exceed it needs `BigInt`. Show `(a * b) % m` overflowing and the BigInt fix.
5. **Recursion depth** is roughly 10^4, far below C++/Java. Deep DFS on 10^5 nodes will
   blow the stack — teach the explicit-stack iterative rewrite.
6. **`Map` vs plain object** for hashing: object keys are strings, `Map` keeps type and
   insertion order and is faster for frequent adds/deletes.
7. **Array copy is shallow**; `[...a]` does not deep-copy a 2D grid. Show the correct
   `a.map(r => [...r])`.

### Shared toolkit — do NOT redefine these per chapter
`/home/zayed/books/shared/js/toolkit.js` holds tested `MinHeap`, `DSU`, `Deque`,
`lowerBound`, `upperBound`. Chapters USE them and reference the JS Toolkit appendix.
Only re-show an implementation when the chapter is specifically teaching that structure.

## CODE MUST ACTUALLY RUN — this is the hard requirement
For every JS snippet you publish:
  1. write it to /tmp/<name>.js with your own test cases and `console.log` assertions
  2. run `node /tmp/<name>.js`
  3. confirm the OUTPUT matches what the book claims
Do the same for Python with `python3`. Do NOT publish code you have not executed.
Include edge cases in your tests: empty input, single element, duplicates, negatives,
overflow (use BigInt where a value can exceed 2^53 - 1).

## Chapter structure
#section[Pattern in one page]  - when to reach for it, the template code, the invariant
#section[Warm-up] tier 0       - 5-6 small problems
#section[Tier 1 ...] tier 1    - 8-10 problems, full approach ladder on at least 5
#section[Tier 2 ...] tier 2    - 6-8 problems
#section[Tier 3 ...] tier 3    - 5-6 problems + the follow-up the interviewer asks next
  ("now do it in O(1) space", "now it's a stream", "now it's distributed")
#section[Dry run]              - ONE problem traced line by line with a state table
#section[Practice]             - 12-15 problems with full solutions in the #key
#revision[]                    - template code + when-to-use + complexity table + top traps

## Every problem must state
constraints (n up to what), the complexity target, and at least 2 edge cases.
