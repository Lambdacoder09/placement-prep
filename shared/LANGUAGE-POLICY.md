# LANGUAGE POLICY — applies to every book in this series

**JavaScript (Node) is the primary language. Python is the secondary language.**
C++ and Java are NOT used as primary languages anywhere in this series.

- Show JS first, always. Add a Python version where it is meaningfully shorter or clearer.
- Use modern readable JS: const/let, arrow functions, Map/Set, destructuring.
- Shared tested helpers live in `/home/zayed/books/shared/js/toolkit.js`
  (MinHeap, DSU, Deque, lowerBound, upperBound). USE them; do not redefine per chapter.

## The JS traps to teach wherever they apply (#trap[] box)
1. `arr.sort()` is LEXICOGRAPHIC. `[10,9,1].sort()` -> `[1,10,9]`. Numbers need `(a,b)=>a-b`.
2. No built-in heap/priority queue -> use the toolkit `MinHeap`.
3. No TreeMap/ordered set -> sorted array + binary search, or Map + maintained key list.
4. Numbers are doubles; exact only to 2^53-1. Beyond that use `BigInt`.
5. Recursion depth ~10^4 — deep DFS needs an explicit stack.
6. `Map` vs object: object keys stringify; Map keeps type and insertion order.
7. `[...a]` is a SHALLOW copy. A 2D grid needs `a.map(r => [...r])`.

## Every snippet must be EXECUTED before publishing
  node /tmp/x.js        # include your own test cases and expected output
  python3 /tmp/x.py
Never publish code you have not run. Report an honest count of snippets executed.

## Where this policy bends — and why
Some interview topics are defined in other languages. Do not force JS where it misleads:

- **OOP theory (virtual functions, abstract classes, interfaces, method overloading,
  the diamond problem, access modifiers).** Interviewers at service companies ask these in
  **Java/C++ vocabulary**. Teach the CONCEPT language-neutrally, show the JS reality
  (prototypes, classes, no overloading, no interfaces, mixins), AND state plainly what the
  Java/C++ answer is, because that is what will be asked. A student who can only answer in
  JS will fail this round. Show short Java or C++ ONLY to illustrate such a concept, clearly
  labelled as "what the interviewer expects to hear".
- **OS internals** (fork, exec, pthreads, signals): illustrate with C-style pseudocode or
  real C where that is what the concept IS, and give the Node equivalent
  (child_process, worker_threads) where one genuinely exists.
- **SQL stays SQL.** **Networking stays protocol-level.** Neither becomes JS.

The rule: JS everywhere it is honest, other languages only where JS would leave the student
unable to answer the question they will actually be asked — and say so explicitly.
