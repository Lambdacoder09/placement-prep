#import "../../shared/lib/style.typ": *

#chapter(num: 12, title: "Compilers, Git & Dev Fundamentals",
  tagline: "What happens between your source file and a running process — and how Git really stores it")[

Every number, every file size and every command output in this chapter was produced by actually
running the command on a Linux machine. Nothing here is from memory. Where you see an output
block, it is a real transcript, and you can reproduce it.

#formulas(title: "What you need to know")[
#table(columns: (auto, 1fr),
  [*Compiler*], [Translates a whole program to another language (usually machine code) *before* it runs.],
  [*Interpreter*], [Reads and executes the program statement by statement, *while* it runs.],
  [*JIT*], [Starts interpreting, then compiles the hot parts to machine code at run time. V8 does this.],
  [*Preprocessor*], [Text stage. Expands includes and macros. Output is still source code.],
  [*Assembler*], [Assembly text → machine code in an *object file*. Addresses still unresolved.],
  [*Linker*], [Joins object files and libraries, resolves every symbol, produces an executable.],
  [*Loader*], [Copies the executable into memory, sets up segments, jumps to the entry point.],
  [*Token*], [The smallest meaningful piece of source: a number, a name, an operator.],
  [*AST*], [Abstract syntax tree — the parsed shape of the program, with precedence baked in.],
  [*Symbol table*], [Name → (type, scope, address). Built during semantic analysis.],
  [*Static linking*], [Library code is copied into the executable. Big file, no runtime dependency.],
  [*Dynamic linking*], [Library is loaded at run time from a `.so` / `.dll`. Small file, shared in RAM.],
  [*Segment*], [A region of a process's address space: text, rodata, data, bss, heap, stack.],
  [*Stack frame*], [One function call's locals, arguments and return address. Pushed on call, popped on return.],
  [*Blob / tree / commit*], [Git's three object types: file bytes / directory listing / snapshot + parent + message.],
  [*HEAD*], [A file holding which branch you are on. In detached state it holds a raw commit SHA.],
  [*Index*], [Also called the staging area. The list of what the *next* commit will contain.],
)

*Four sentences that carry most of this chapter*

- A compiler produces a *file*; an interpreter produces an *answer*.
- The four stages are *preprocess → compile → assemble → link*, and they produce
  `.i → .s → .o → executable`.
- The stack grows *down* toward low addresses; the heap grows *up*. They meet in the middle.
- A Git commit is a *snapshot*, not a diff. It stores a tree hash, a parent hash, and a message.
]

#section[12.1 From source file to executable — the four stages]

Here is the program. Six lines.

#code(lang: "c", caption: "hello.c")[```c
#include <stdio.h>
#define TIMES 3
int main(void) {
    for (int i = 0; i < TIMES; i++) printf("hi %d\n", i);
    return 0;
}
```]

Now run each stage by hand instead of letting `gcc` do all four silently.

#code(lang: "bash", caption: "The four stages, one command each")[```bash
gcc -E hello.c -o hello.i     # 1. preprocess  -> still C source
gcc -S hello.i -o hello.s     # 2. compile     -> assembly text
gcc -c hello.s -o hello.o     # 3. assemble    -> object file (machine code)
gcc    hello.o -o hello       # 4. link        -> executable
```]

Real measured results:

#table(columns: (auto, auto, auto, 1fr),
  [*File*], [*Lines*], [*Bytes*], [*What it is*],
  [`hello.c`], [6],   [—],     [what you wrote],
  [`hello.i`], [819], [21339], [C source with `stdio.h` pasted in and `TIMES` replaced by `3`],
  [`hello.s`], [56],  [814],   [x86-64 assembly, human readable text],
  [`hello.o`], [—],   [1528],  [machine code, but `printf`'s address is still a hole],
  [`hello`],   [—],   [15960], [executable: holes filled, entry point set],
)

Six lines became 819. That is `stdio.h` and everything it includes. This is why C compiles
slowly: the compiler really does re-read those 800 lines for every `.c` file.

#diagram(height: 4.4cm, caption: "The four stages. All sizes measured on a real build.")[
  #dnode(0cm,    0.4cm, 3.6cm, 2.4cm,
    [`hello.c` → `hello.i` \ \ *1. preprocess* \ `gcc -E` \ \ expands `#include` \ and `#define`; \ 6 → 819 lines], fill: rgb("#fdf3e7"))
  #dnode(4.1cm,  0.4cm, 3.6cm, 2.4cm,
    [`hello.i` → `hello.s` \ \ *2. compile* \ `gcc -S` \ \ the real compiler; \ output is assembly \ *text*, 56 lines])
  #dnode(8.2cm,  0.4cm, 3.6cm, 2.4cm,
    [`hello.s` → `hello.o` \ \ *3. assemble* \ `gcc -c` \ \ machine code, but \ `printf` is still \ an unresolved hole])
  #dnode(12.3cm, 0.4cm, 3.6cm, 2.4cm,
    [`hello.o` → `hello` \ \ *4. link* \ `gcc` \ \ joins objects + \ libc, fills holes, \ sets entry point], fill: rgb("#eef5ea"))
  #darrow(3.6cm, 1.6cm, 4.1cm, 1.6cm)
  #darrow(7.7cm, 1.6cm, 8.2cm, 1.6cm)
  #darrow(11.8cm, 1.6cm, 12.3cm, 1.6cm)
  #dnode(0cm, 3.2cm, 15.9cm, 0.7cm,
    [Only stage 2 is "the compiler". People say "compiling" for all four — in an interview, name all four.],
    fill: rgb("#f7f7f5"))
]

#subsection[Proof that the preprocessor is just text substitution]

The last lines of `hello.i`, straight from the file:

```
# 3 "hello.c"
int main(void) {
    for (int i = 0; i < 3; i++) printf("hi %d\n", i);
    return 0;
}
```

`TIMES` is gone. The literal `3` is in its place. The preprocessor does not know C — it does not
know that `3` is a number or that `i` is a variable. It matches text and pastes text.

#trap[
Because macros are pure text, `#define SQ(x) x*x` then `SQ(2+3)` expands to `2+3*2+3` = *11*, not
25. The fix is parentheses everywhere: `#define SQ(x) ((x)*(x))`. This is the classic macro
question, and the reason C++ says "use `inline` functions and `constexpr` instead of macros".
]

#section[12.2 Compiler vs interpreter vs JIT]

#table(columns: (auto, 1fr, 1fr, 1fr),
  [], [*Compiler*], [*Interpreter*], [*JIT*],
  [Translates], [whole program, once, ahead of time], [one statement at a time, every time], [hot functions, at run time],
  [Output],     [a machine-code file], [an answer — nothing is saved], [machine code in memory],
  [Errors found], [at build time, all at once], [when that line runs], [build-free; run time],
  [Speed of run], [fastest], [slowest], [close to compiled, after warm-up],
  [Startup], [slow to build, instant to start], [instant], [instant, then gets faster],
  [Portability], [one binary per platform], [runs anywhere the interpreter runs], [same as interpreter],
  [Examples], [C, C++, Rust, Go], [classic Python, shell], [Java HotSpot, V8, .NET, PyPy],
)

#subsection[Measure the difference yourself]

Both strategies, same work: evaluate `x * 3 + 7` three million times.

#code(lang: "js", caption: "Interpreting an AST vs 'compiling' it to a closure")[```js
const ast = { n: "bin", op: "+",
              l: { n: "bin", op: "*", l: {n:"var",v:"x"}, r: {n:"num",v:3} },
              r: {n:"num",v:7} };

function interpret(node, env) {                 // walks the tree on EVERY call
  switch (node.n) {
    case "num": return node.v;
    case "var": return env[node.v];
    case "bin": { const a = interpret(node.l, env), b = interpret(node.r, env);
                  return node.op === "+" ? a + b : a * b; }
  }
}
function compile(node) {                        // walks the tree ONCE, returns a function
  switch (node.n) {
    case "num": { const v = node.v; return () => v; }
    case "var": { const k = node.v; return env => env[k]; }
    case "bin": { const L = compile(node.l), R = compile(node.r);
                  return node.op === "+" ? env => L(env) + R(env) : env => L(env) * R(env); }
  }
}
const N = 3_000_000, env = { x: 5 };
let t = process.hrtime.bigint(); let s = 0;
for (let i = 0; i < N; i++) s += interpret(ast, env);
const ti = Number(process.hrtime.bigint() - t) / 1e6;

const fn = compile(ast);                        // one-time cost
t = process.hrtime.bigint(); let s2 = 0;
for (let i = 0; i < N; i++) s2 += fn(env);
const tc = Number(process.hrtime.bigint() - t) / 1e6;

console.log("same answer:", s === s2, "value per call =", interpret(ast, env));
console.log(`interpret : ${ti.toFixed(0)} ms`);
console.log(`compiled  : ${tc.toFixed(0)} ms`);
```]

Real output from `node` (two runs, to show it is stable):

```
same answer: true value per call = 22
interpret : 114 ms
compiled  :   7 ms
```

Check the value: $5 times 3 + 7 = 22$. Correct.

The compiled version is about *16 times* faster and it is the *same algorithm*. The only change
is *when* the decisions are made. The interpreter re-asks "what node type is this?" three million
times. The compiled version asked once and baked the answer into a closure.

That is the entire idea behind a JIT, in miniature.

#trick[
When asked "why is C faster than Python?", do not say "because it is compiled". Say: *"the work
of deciding what each operation means is done once at build time instead of on every execution,
and the compiler can then see the whole function and optimise across statements."* That answer
survives the follow-up "but Python has a JIT now".
]

#section[12.3 Inside the front end: lexer, parser, semantic analysis]

The compiler reads your file in three passes before it emits a single machine instruction.

#subsection[Pass 1 — the lexer: characters become tokens]

#code(lang: "js", caption: "A working lexer in 14 lines")[```js
function lex(src) {
  const toks = [], re = /\s*(\d+|[A-Za-z_]\w*|[-+*/()=;])/g;
  let m, pos = 0;
  while ((m = re.exec(src)) !== null) {
    if (m.index !== pos) throw new Error("bad char at " + pos);
    pos = re.lastIndex;
    const s = m[1];
    if (/^\d/.test(s))             toks.push({ type: "NUM", value: +s });
    else if (/^[A-Za-z_]/.test(s)) toks.push({ type: "ID",  value: s });
    else                           toks.push({ type: "OP",  value: s });
  }
  return toks;
}
console.log(lex("total = price * 3 + 12;").map(t => `${t.type}(${t.value})`).join(" "));
```]

Real output:

```
ID(total) OP(=) ID(price) OP(*) NUM(3) OP(+) NUM(12) OP(;)
```

Notice what the lexer does *not* do. It does not know that `total` is a variable, that `=` is an
assignment, or that `*` binds tighter than `+`. It only chops the character stream into labelled
pieces and throws away whitespace. Errors it can catch: an illegal character, an unterminated
string. That is all.

#subsection[Pass 2 — the parser: tokens become a tree]

This is where precedence lives. `2 + 3 * 4` must become $2 + (3 times 4)$, and the grammar's
*shape* is what makes that happen.

```
expr   := term   (('+' | '-') term)*
term   := factor (('*' | '/') factor)*
factor := NUM | '(' expr ')'
```

`expr` calls `term` first, so multiplication is grabbed *before* addition gets a chance. Nothing
else is needed — no precedence table.

#code(lang: "js", caption: "A recursive-descent parser and an evaluator")[```js
function parse(toks) {
  let i = 0;
  const peek = () => toks[i];
  const eat  = v => { if (toks[i]?.value !== v) throw new Error("expected " + v); i++; };
  function factor() {
    const t = peek();
    if (t.type === "NUM") { i++; return { n: "num", v: t.value }; }
    eat("("); const e = expr(); eat(")"); return e;
  }
  function term() {
    let l = factor();
    while (peek() && (peek().value === "*" || peek().value === "/")) {
      const op = toks[i++].value; l = { n: "bin", op, l, r: factor() };
    }
    return l;
  }
  function expr() {
    let l = term();
    while (peek() && (peek().value === "+" || peek().value === "-")) {
      const op = toks[i++].value; l = { n: "bin", op, l, r: term() };
    }
    return l;
  }
  return expr();
}
const lex = s => [...s.matchAll(/\d+|[-+*/()]/g)].map(m =>
  /\d/.test(m[0]) ? { type: "NUM", value: +m[0] } : { type: "OP", value: m[0] });

const show = a => a.n === "num" ? String(a.v) : `(${show(a.l)} ${a.op} ${show(a.r)})`;
const evalAst = a => a.n === "num" ? a.v :
  ({ "+": (x,y)=>x+y, "-": (x,y)=>x-y, "*": (x,y)=>x*y, "/": (x,y)=>x/y })[a.op](evalAst(a.l), evalAst(a.r));

for (const s of ["2 + 3 * 4", "(2 + 3) * 4", "20 - 6 - 4"]) {
  const ast = parse(lex(s));
  console.log(s.padEnd(12), "->", show(ast).padEnd(20), "=", evalAst(ast));
}
```]

Real output:

```
2 + 3 * 4    -> (2 + (3 * 4))        = 14
(2 + 3) * 4  -> ((2 + 3) * 4)        = 20
20 - 6 - 4   -> ((20 - 6) - 4)       = 10
```

Read the middle column. The parentheses in the printed tree were *never in the source* of the
first line — the parser put them there. And `20 - 6 - 4` grouped *left*, giving 10 and not
$20 - (6-4) = 18$, because the `while` loop in `expr()` keeps folding to the left. That loop
*is* left-associativity.

#subsection[Pass 3 — semantic analysis: does it make sense?]

The parser only checks *shape*. `x = "hello" * true;` parses fine. Semantic analysis walks the
tree with a *symbol table* and asks: is `x` declared? what type is it? is `*` defined for those
types?

JavaScript does a small version of this before running each script, and you can see it:

#code(lang: "js", caption: "Scope resolution happens before line 1 executes")[```js
console.log(typeof hoistedFn);   // "function"  -> whole function lifted
console.log(typeof varX);        // "undefined" -> name lifted, value not
try { console.log(letY); }       // name is known, but in the "temporal dead zone"
catch (e) { console.log(e.constructor.name + ":", e.message); }

function hoistedFn() {}
var varX = 1;
let letY = 2;
```]

Real output:

```
function
undefined
ReferenceError: Cannot access 'letY' before initialization
```

Three different behaviours for three declaration forms, and all three are decided *before the
first line runs*. The engine built a scope record for the whole script first. That is a symbol
table.

#table(columns: (auto, 1fr, 1fr),
  [*Stage*], [*Catches*], [*Example error*],
  [Lexical], [illegal characters, unterminated literals], [`let x = "abc;`],
  [Syntactic], [wrong shape], [`if (x { }` — missing `)`],
  [Semantic], [undeclared names, type mismatch, wrong argument count], [`int n = "hello";`],
  [Link], [a name that no file defines], [`undefined reference to 'helper'`],
  [Run], [everything the compiler could not know], [divide by zero, null dereference],
)

#section[12.4 The back end: intermediate code, optimisation, code generation]

After the front end, the compiler builds an *intermediate representation* — a simple,
machine-independent form. Then it optimises the IR, then it turns it into instructions for the
target CPU.

You can watch optimisation happen.

#code(lang: "c", caption: "opt2.c — two obvious wastes")[```c
int compute(void) {
    int a = 6 * 7;      /* constant folding      */
    int unused = 999;   /* dead code elimination */
    return a + 8;
}
```]

Compile twice and look at the assembly `gcc` produced.

#code(lang: "bash", caption: "gcc -O0 -S opt2.c   vs   gcc -O2 -S opt2.c")[```bash
# ---- gcc -O0 (no optimisation) ----
compute:
        endbr64
        pushq   %rbp
        movq    %rsp, %rbp
        movl    $42, -8(%rbp)       # a = 42        (6*7 already folded)
        movl    $999, -4(%rbp)      # unused = 999  (still stored!)
        movl    -8(%rbp), %eax
        addl    $8, %eax
        popq    %rbp
        ret

# ---- gcc -O2 ----
compute:
        endbr64
        movl    $50, %eax           # the WHOLE function is one constant
        ret
```]

That is a real transcript. Eight instructions became two.

Follow the two optimisations:

+ *Constant folding* — `6 * 7` is computed at build time. This happened even at `-O0`
  (`movl $42`), because it is done in the front end.
+ *Dead code elimination* — `unused` is written at `-O0` and *absent* at `-O2`. Nothing reads it,
  so the store is removed, and with it the local variable.
+ *Constant propagation* — knowing `a` is 42, `a + 8` becomes 50 at build time. The function no
  longer computes anything.

#table(columns: (auto, 1fr),
  [*Optimisation*], [*What it does*],
  [Constant folding], [Evaluate expressions with known values at build time: `6*7` → `42`.],
  [Constant propagation], [Replace a variable by its known value, then fold again.],
  [Dead code elimination], [Delete computations whose result nothing reads.],
  [Common subexpression elimination], [Compute `a*b` once when it appears twice.],
  [Loop-invariant code motion], [Move a computation that does not change out of the loop.],
  [Strength reduction], [Replace an expensive op with a cheap one: `x*8` → `x << 3`.],
  [Inlining], [Paste a small function's body into the caller, then optimise across the join.],
  [Register allocation], [Keep hot variables in CPU registers instead of memory.],
)

#trap[
"Optimisation makes my code faster, so `-O2` is always safe" is not quite true, and the follow-up
is about *undefined behaviour*. If your C program has UB — signed overflow, reading uninitialised
memory, a data race — the optimiser is allowed to assume it never happens and may delete the code
that handles it. Programs that "work at `-O0` and break at `-O2`" almost always have UB. The fix
is to remove the UB, not to lower the optimisation level.
]

#section[12.5 Linking: where "undefined reference" comes from]

#code(lang: "c", caption: "u.c — a function that is declared but never defined")[```c
int helper(int);          /* declared, never defined */
int main(void) { return helper(1); }
```]

Real transcript:

```
$ gcc -c u.c -o u.o
u.o built                      <- compiling ALONE succeeds

$ gcc u.o -o u
/usr/bin/ld: u.o: in function `main':
u.c:(.text+0xe): undefined reference to `helper'
collect2: error: ld returned 1 exit status
```

Read what this tells you. The *compiler* was happy: it saw a declaration, so it knew the name,
the return type and the argument types — enough to emit a `call` instruction with a *hole* where
the address goes. Only the *linker* has to find a real definition, and there is none.

This is the single most useful diagnostic skill in C and C++:

#table(columns: (auto, 1fr),
  [*Message*], [*It means*],
  [`error: 'helper' was not declared`], [*Compiler* error. You forgot the header / the declaration.],
  [`undefined reference to 'helper'`], [*Linker* error. Declaration found, definition missing. You forgot to compile or link that `.c` file, or forgot `-lm` / `-lpthread`.],
  [`multiple definition of 'helper'`], [*Linker* error. Two files define it. Usually a function body put in a header.],
  [`ld: cannot find -lfoo`], [The library file `libfoo.so` / `libfoo.a` is not on the search path.],
)

#subsection[Static vs dynamic linking — measured]

```
$ gcc         hello.c -o dyn
$ gcc -static hello.c -o sta
$ ls -l dyn sta
dyn      15960
sta     785328

$ ldd dyn
    linux-vdso.so.1
    libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6
    /lib64/ld-linux-x86-64.so.2

$ ldd sta
    not a dynamic executable
```

The static build is *49 times larger* ($785328 / 15960 = 49.2$) because the parts of libc it uses
are copied inside it.

#table(columns: (auto, 1fr, 1fr),
  [], [*Static (`.a`)*], [*Dynamic (`.so` / `.dll`)*],
  [When joined], [at link time], [at load time (and later, with `dlopen`)],
  [Executable size], [large — measured 785 KB vs 16 KB], [small],
  [RAM with 50 copies running], [50 copies of the library], [*one* shared copy],
  [Security patch in libc], [rebuild and reship every program], [replace the `.so`; everything is fixed],
  [Startup], [faster — nothing to resolve], [slower — the dynamic loader must resolve symbols],
  [Deployment], [one file, no dependencies], [needs the right library version present],
  [Failure mode], [none at run time], [`error while loading shared libraries` / version hell],
)

#section[12.6 The memory layout of a running program]

This is asked constantly, and most students recite the diagram without ever having checked it.
Let us check it.

#code(lang: "c", caption: "layout.c — print the address of one thing in every segment")[```c
#include <stdio.h>
#include <stdlib.h>
int  g_init   = 5;      /* .data  - initialised global   */
int  g_zero;            /* .bss   - uninitialised global */
const char *msg = "hi"; /* pointer in .data, "hi" in .rodata */
void fn(void) {}        /* .text  */
int main(void) {
    int local = 1;                     /* stack */
    int *heap = malloc(sizeof(int));   /* heap  */
    printf("text  (fn)      %p\n", (void*)fn);
    printf("rodata(\"hi\")    %p\n", (void*)msg);
    printf("data  (g_init)  %p\n", (void*)&g_init);
    printf("bss   (g_zero)  %p\n", (void*)&g_zero);
    printf("heap  (malloc)  %p\n", (void*)heap);
    printf("stack (local)   %p\n", (void*)&local);
    free(heap);
    return 0;
}
```]

Built with `gcc -no-pie layout.c -o layout` (the `-no-pie` just keeps the addresses fixed so they
are easy to read). Real output:

```
text  (fn)      0x401196
rodata("hi")    0x402004
data  (g_init)  0x404030
bss   (g_zero)  0x404044
heap  (malloc)  0x17dca2a0
stack (local)   0x7fffe2b52bcc
```

Every address is larger than the one above it. The textbook picture is correct, and now you have
seen it.

#diagram(height: 7.6cm, caption: "Process address space, low address at the bottom. Addresses are a real run of layout.c")[
  #dnode(0cm, 0.1cm, 11.5cm, 0.9cm,
    [*stack* — locals, arguments, return addresses, saved registers. Grows *DOWN* ↓], fill: rgb("#fdf3e7"))
  #dnode(11.9cm, 0.1cm, 4.4cm, 0.9cm, [`0x7fffe2b52bcc`])

  #dnode(0cm, 1.2cm, 11.5cm, 0.7cm,
    [free gap — the two ends grow toward each other], fill: rgb("#f2f2f2"))

  #dnode(0cm, 2.1cm, 11.5cm, 0.9cm,
    [*heap* — `malloc` / `new`. Grows *UP* ↑. Freed by you, never automatically (in C).], fill: rgb("#eef5ea"))
  #dnode(11.9cm, 2.1cm, 4.4cm, 0.9cm, [`0x17dca2a0`])

  #dnode(0cm, 3.2cm, 11.5cm, 0.8cm,
    [*.bss* — globals/statics with *no* initialiser. Takes *zero* bytes in the file; zero-filled at load.])
  #dnode(11.9cm, 3.2cm, 4.4cm, 0.8cm, [`0x404044`])

  #dnode(0cm, 4.2cm, 11.5cm, 0.8cm,
    [*.data* — globals/statics *with* an initialiser. The values are stored in the file.])
  #dnode(11.9cm, 4.2cm, 4.4cm, 0.8cm, [`0x404030`])

  #dnode(0cm, 5.2cm, 11.5cm, 0.8cm,
    [*.rodata* — string literals and `const` data. Read-only; writing here segfaults.])
  #dnode(11.9cm, 5.2cm, 4.4cm, 0.8cm, [`0x402004`])

  #dnode(0cm, 6.2cm, 11.5cm, 0.8cm,
    [*.text* — the machine code itself. Read-only and shareable between processes.], fill: rgb("#e7eef5"))
  #dnode(11.9cm, 6.2cm, 4.4cm, 0.8cm, [`0x401196`])
]

#table(columns: (auto, 1fr, 1fr, 1fr),
  [*Segment*], [*Holds*], [*Lifetime*], [*Freed by*],
  [.text], [code], [whole program], [the OS, at exit],
  [.rodata], [literals, `const`], [whole program], [the OS, at exit],
  [.data], [initialised globals/statics], [whole program], [the OS, at exit],
  [.bss], [zero-initialised globals/statics], [whole program], [the OS, at exit],
  [heap], [`malloc` / `new`], [until you free it], [*you*],
  [stack], [locals, parameters, return address], [until the function returns], [automatically],
)

#trap[
*`.bss` takes no space in the executable file.* `int big[1000000];` as a global adds 4 MB to the
*process* but roughly *nothing* to the file on disk, because the file only records "reserve 4 MB
and zero it". Change it to `int big[1000000] = {1};` and it moves to `.data`, and now 4 MB of
mostly-zeros really is written into the file. This is a favourite follow-up: "why is my binary
suddenly 4 MB?"
]

#section[12.7 The stack frame and why recursion has a limit]

Each function call pushes a *frame*: the return address, saved registers, the parameters and the
locals. Return pops it.

#code(lang: "c", caption: "frame.c — print the address of a local at each depth")[```c
#include <stdio.h>
void level(int n) {
    int local = n;                  /* one per frame */
    printf("depth %d  frame at %p\n", n, (void*)&local);
    if (n < 4) level(n + 1);
}
int main(void) { level(1); return 0; }
```]

Real output:

```
depth 1  frame at 0x7ffec82cd284
depth 2  frame at 0x7ffec82cd254
depth 3  frame at 0x7ffec82cd224
depth 4  frame at 0x7ffec82cd1f4
```

Subtract: `0x284 - 0x254 = 0x30` = *48 bytes*, and the gap is the same every time. So on this
build each frame is 48 bytes and the addresses go *down*. Both facts are now measured, not
assumed.

#diagram(height: 5.4cm, caption: "Stack frames from the real run. Each call moves the stack pointer DOWN by 48 bytes.")[
  #dnode(0cm, 0.1cm, 10.8cm, 0.8cm, [frame for `main` — higher address, pushed first], fill: rgb("#f2f2f2"))
  #dnode(11.2cm, 0.1cm, 5.1cm, 0.8cm, [(above `0x...284`)])

  #dnode(0cm, 1.1cm, 10.8cm, 0.8cm, [frame for `level(1)` — `local = 1`, return addr → `main`], fill: rgb("#fdf3e7"))
  #dnode(11.2cm, 1.1cm, 5.1cm, 0.8cm, [`0x7ffec82cd284`])

  #dnode(0cm, 2.1cm, 10.8cm, 0.8cm, [frame for `level(2)` — `local = 2`, return addr → `level(1)`], fill: rgb("#fdf3e7"))
  #dnode(11.2cm, 2.1cm, 5.1cm, 0.8cm, [`0x7ffec82cd254`   (−48)])

  #dnode(0cm, 3.1cm, 10.8cm, 0.8cm, [frame for `level(3)` — `local = 3`, return addr → `level(2)`], fill: rgb("#fdf3e7"))
  #dnode(11.2cm, 3.1cm, 5.1cm, 0.8cm, [`0x7ffec82cd224`   (−48)])

  #dnode(0cm, 4.1cm, 10.8cm, 0.8cm, [frame for `level(4)` — top of stack, lowest address], fill: rgb("#eef5ea"))
  #dnode(11.2cm, 4.1cm, 5.1cm, 0.8cm, [`0x7ffec82cd1f4`   (−48)])

  #darrow(10.9cm, 0.9cm, 10.9cm, 4.1cm, label: "grows ↓")
]

#subsection[The same limit, in JavaScript]

#code(lang: "js", caption: "How deep can you go, and what to do instead")[```js
let depth = 0;
function dive() { depth++; dive(); }
try { dive(); } catch (e) { console.log(e.constructor.name, "at depth ~", depth); }

// Same job, heap-allocated explicit stack -> no limit problem.
function sumTo(n) {
  let total = 0n;
  const stack = [n];
  while (stack.length) { const k = stack.pop(); if (k > 0) { total += BigInt(k); stack.push(k - 1); } }
  return total;
}
console.log("sumTo(200000) =", sumTo(200000).toString());
console.log("check n(n+1)/2 =", (200000n * 200001n / 2n).toString());
```]

Real output:

```
RangeError at depth ~ 12546
sumTo(200000) = 20000100000
check n(n+1)/2 = 20000100000
```

Two lessons here.

*First*, the JS call stack died at about *12,500* frames. So any recursion that could go deeper
than roughly $10^4$ needs an explicit stack held on the heap, exactly as the loop version does.
The loop handled 200,000 levels without complaint.

*Second*, the arithmetic checks out. $n(n+1)/2 = (200000 times 200001)/2 = 20{,}000{,}100{,}000$,
and that is what the program printed. `BigInt` was used so the check stays exact for any `n`; for
this particular `n` a plain `Number` would also have been fine, since
$2 times 10^10$ is far below the safe-integer limit $2^53 - 1 approx 9.007 times 10^15$.

#trap[
*Stack overflow and heap exhaustion are different failures.* Deep recursion overflows the
*stack* (fixed size, typically 1–8 MB, set at thread creation). Allocating too many objects
exhausts the *heap* (grows until the OS refuses). In Node the first is `RangeError: Maximum call
stack size exceeded`; the second is `JavaScript heap out of memory`. Naming the right one is the
whole point of the question.
]

#pagebreak(weak: true)
#section[12.8 Git — the three trees]

Everything in Git is easier once you hold this picture. There are three places a file can be,
and every command moves files between them.

#diagram(height: 5.4cm, caption: "The three trees. Every everyday Git command is an arrow on this picture.")[
  #dnode(0cm,    0.9cm, 4.3cm, 1.5cm, [*working directory* \ the files you can edit \ and your editor can see], fill: rgb("#fdf3e7"))
  #dnode(6.0cm,  0.9cm, 4.3cm, 1.5cm, [*index* (staging area) \ `.git/index` \ what the *next* commit will hold])
  #dnode(12.0cm, 0.9cm, 4.3cm, 1.5cm, [*repository* \ `.git/objects` \ committed history — permanent], fill: rgb("#eef5ea"))
  #darrow(4.3cm, 1.3cm, 6.0cm, 1.3cm, label: "git add")
  #darrow(10.3cm, 1.3cm, 12.0cm, 1.3cm, label: "git commit")
  #darrow(12.0cm, 2.1cm, 10.3cm, 2.1cm, label: "reset")
  #darrow(6.0cm, 2.1cm, 4.3cm, 2.1cm, label: "restore")
  #dnode(0cm, 3.1cm, 16.3cm, 0.8cm,
    [`git status` shows two diffs at once: *working ↔ index* (\"not staged\") and *index ↔ HEAD* (\"to be committed\").], fill: rgb("#f7f7f5"))
  #dnode(0cm, 4.1cm, 16.3cm, 0.8cm,
    [`git diff` = working vs index.  `git diff --cached` = index vs HEAD.  `git diff HEAD` = working vs HEAD.], fill: rgb("#f7f7f5"))
]

Here is the index, printed. It is a real list of file paths and content hashes:

```
$ git ls-files -s
100644 ce013625030ba8dba906f756967f9e9ca394464a 0  a.txt
100644 ce013625030ba8dba906f756967f9e9ca394464a 0  b.txt
```

Note that `a.txt` and `b.txt` have the *same hash*. They have the same content, so Git stores the
bytes *once*. That is not a special feature; it falls out of how the objects are named.

#section[12.9 Git's object model — and the hash, computed by hand]

Git stores four object types. Three matter for interviews.

#table(columns: (auto, 1fr, 1fr),
  [*Object*], [*Contains*], [*Named by*],
  [blob], [the *bytes of one file* — no name, no path, no permissions], [SHA-1 of its content],
  [tree], [a directory listing: mode, type, hash, name — one row per entry], [SHA-1 of that listing],
  [commit], [tree hash, parent hash(es), author, committer, message], [SHA-1 of all of that],
  [tag], [an annotated tag: object hash, tagger, message], [SHA-1 of that],
)

Make a repo with one file and look inside.

#code(lang: "bash", caption: "One commit, three objects")[```bash
$ git init -q -b main && printf 'hello\n' > a.txt && git add a.txt && git commit -q -m "first"

$ find .git/objects -type f
ce/013625030ba8dba906f756967f9e9ca394464a
8e/b30367d95cd1f9d226d1eeacb0e3439d20c794
2e/81171448eb9f2ee3821e3d447aa6b2fe3ddba1

$ git cat-file -t ce01362 ; git cat-file -t 2e81171 ; git cat-file -t 8eb3036
blob
tree
commit
```]

One six-byte file produced *three* objects: the blob (the bytes), the tree (the directory listing
saying "a.txt is that blob"), and the commit (a pointer to the tree plus the message).

Print the tree and the commit:

```
$ git cat-file -p HEAD^{tree}
100644 blob ce013625030ba8dba906f756967f9e9ca394464a  a.txt

$ git cat-file -p HEAD
tree 2e81171448eb9f2ee3821e3d447aa6b2fe3ddba1
author Student <s@example.com> 1789490157 +0530
committer Student <s@example.com> 1789490157 +0530

first
```

#subsection[Compute the blob hash yourself]

Git's rule for a blob is exactly this: take the literal string
`blob`, a space, the content length in decimal, a *zero byte*, then the content — and SHA-1 the
whole thing.

#code(lang: "python", caption: "Reproducing Git's hash in six lines of Python")[```python
import hashlib
content = b'hello\n'
store = b'blob ' + str(len(content)).encode() + b'\x00' + content
print('header+body =', store)
print('sha1        =', hashlib.sha1(store).hexdigest())
```]

Real output:

```
header+body = b'blob 6\x00hello\n'
sha1        = ce013625030ba8dba906f756967f9e9ca394464a
```

That is *character for character* the hash Git reported above. You have just reimplemented
`git hash-object`.

The tree works the same way, with a body of `<mode> <name>\0<20 raw bytes of the hash>`:

```python
blob = bytes.fromhex('ce013625030ba8dba906f756967f9e9ca394464a')
body = b'100644 a.txt\x00' + blob
store = b'tree ' + str(len(body)).encode() + b'\x00' + body
print(hashlib.sha1(store).hexdigest())
# 2e81171448eb9f2ee3821e3d447aa6b2fe3ddba1   <- matches the tree above
```

#diagram(height: 4.8cm, caption: "Two commits. The blob is stored once and shared, because its hash is its name.")[
  #dnode(0cm,   0.2cm, 3.6cm, 1.3cm, [*commit* `728ea0f` \ "second"], fill: rgb("#eef5ea"))
  #dnode(0cm,   2.6cm, 3.6cm, 1.3cm, [*commit* `8eb3036` \ "first"], fill: rgb("#eef5ea"))
  #dnode(5.6cm, 0.2cm, 4.2cm, 1.3cm, [*tree* `b5b0ccc` \ `a.txt` → ce01362 \ `b.txt` → ce01362])
  #dnode(5.6cm, 2.6cm, 4.2cm, 1.3cm, [*tree* `2e81171` \ `a.txt` → ce01362])
  #dnode(11.8cm, 1.4cm, 4.5cm, 1.3cm, [*blob* `ce01362` \ the bytes `hello\n` \ stored ONCE], fill: rgb("#fdf3e7"))
  #darrow(3.6cm, 0.85cm, 5.6cm, 0.85cm, label: "tree")
  #darrow(3.6cm, 3.25cm, 5.6cm, 3.25cm, label: "tree")
  #darrow(1.8cm, 1.5cm, 1.8cm, 2.6cm, label: "parent")
  #darrow(9.8cm, 0.85cm, 11.8cm, 1.7cm)
  #darrow(9.8cm, 3.25cm, 11.8cm, 2.4cm)
]

#trap[
*A Git commit is a full snapshot, not a diff.* Subversion stored diffs; Git stores a complete
tree per commit and relies on content addressing so that unchanged files cost nothing extra.
Deltas do exist — but only later, inside *pack files*, as a storage optimisation. Measured: after
committing a 50,000-byte random file and then changing *one character*, the two loose blobs
occupy 74,573 bytes in `.git/objects`; after `git gc` packs them with deltas, the whole directory
is 39,387 bytes. Snapshots first, deltas as a compression step.
]

#section[12.10 Branches, HEAD and the reflog are just files]

This is the demo that makes Git stop being magic.

```
$ cat .git/HEAD
ref: refs/heads/main

$ cat .git/refs/heads/main
7be546fae23440745fc098dd8c1aff50ee304a4d
```

A *branch* is a 41-byte text file containing one commit hash. `HEAD` is a one-line file saying
which branch you are on. That is all. Creating a branch writes 41 bytes — which is why it is
instant, and why Git encourages branching where older tools did not.

Now check out an old commit directly:

```
$ git checkout HEAD~1
$ cat .git/HEAD
8eb30367d95cd1f9d226d1eeacb0e3439d20c794

$ git status --short --branch
## HEAD (no branch)
```

*That* is "detached HEAD": `HEAD` now holds a raw SHA instead of `ref: refs/heads/...`. Commits
you make here belong to no branch, so nothing points at them and they are eventually garbage
collected. The fix is to give them a name before you leave: `git switch -c rescue`.

And the safety net:

```
$ git reflog
7be546f HEAD@{0}: commit: C3
5636034 HEAD@{1}: commit: C2 (bad)
3a6b71b HEAD@{2}: commit (initial): C1
```

The reflog records *every* position `HEAD` has held on this machine, including ones no branch
points to any more. After a bad `git reset --hard`, `git reset --hard HEAD@{1}` gets you back.
Say this in an interview and it reads as experience.

#section[12.11 Merge vs rebase]

Build the classic situation: `main` and `feature` both moved after they split.

```
$ git log --oneline --graph --all
* e4dd9cb D          <- feature
* 0939c0b C
| * b9e3e0e E        <- main
|/
* 1a4b9c1 B
* 9de8a76 A
```

#subsection[git merge]

```
$ git merge --no-ff feature
*   a01ac63 merge feature
|\
| * e4dd9cb D
| * 0939c0b C
* | b9e3e0e E
|/
* 1a4b9c1 B
* 9de8a76 A
```

A *new commit with two parents* is created. `C` and `D` keep their original hashes — `0939c0b`
and `e4dd9cb`, exactly as before. Nothing was rewritten.

#subsection[git rebase]

Same starting point, different command:

```
$ git rebase main
* 3db7a77 D          <- NEW hash
* 9eb9636 C          <- NEW hash
* b9e3e0e E
* 1a4b9c1 B
* 9de8a76 A
```

The graph is a straight line. But look carefully: `C` went from `0939c0b` to `9eb9636` and `D`
from `e4dd9cb` to `3db7a77`. *Those are not the same commits.* Rebase replayed the changes on top
of `E`, which means it built brand-new commits with a different parent — and a commit's hash
covers its parent, so the hash had to change.

#diagram(height: 5.2cm, caption: "Same starting graph, two results. Rebase gives C and D new hashes.")[
  #dnode(0cm, 3.4cm, 7.5cm, 0.7cm, [*MERGE* — history preserved, one extra commit], fill: rgb("#f7f7f5"))
  #dnode(0cm,   1.9cm, 1.3cm, 0.7cm, [A])
  #dnode(1.6cm, 1.9cm, 1.3cm, 0.7cm, [B])
  #dnode(3.2cm, 0.5cm, 1.3cm, 0.7cm, [C])
  #dnode(4.8cm, 0.5cm, 1.3cm, 0.7cm, [D])
  #dnode(3.2cm, 2.6cm, 1.3cm, 0.7cm, [E])
  #dnode(6.4cm, 1.9cm, 1.3cm, 0.7cm, [M], fill: rgb("#eef5ea"))
  #darrow(1.3cm, 2.25cm, 1.6cm, 2.25cm)
  #darrow(2.9cm, 2.1cm, 3.2cm, 0.9cm)
  #darrow(2.9cm, 2.4cm, 3.2cm, 2.9cm)
  #darrow(4.5cm, 0.85cm, 4.8cm, 0.85cm)
  #darrow(6.1cm, 0.9cm, 6.6cm, 1.9cm)
  #darrow(4.5cm, 2.9cm, 6.4cm, 2.55cm)

  #dnode(8.8cm, 3.4cm, 7.5cm, 0.7cm, [*REBASE* — straight line, C and D rebuilt], fill: rgb("#f7f7f5"))
  #dnode(8.8cm,  1.9cm, 1.3cm, 0.7cm, [A])
  #dnode(10.4cm, 1.9cm, 1.3cm, 0.7cm, [B])
  #dnode(12.0cm, 1.9cm, 1.3cm, 0.7cm, [E])
  #dnode(13.6cm, 1.9cm, 1.3cm, 0.7cm, [C'], fill: rgb("#fdf3e7"))
  #dnode(15.2cm, 1.9cm, 1.1cm, 0.7cm, [D'], fill: rgb("#fdf3e7"))
  #darrow(10.1cm, 2.25cm, 10.4cm, 2.25cm)
  #darrow(11.7cm, 2.25cm, 12.0cm, 2.25cm)
  #darrow(13.3cm, 2.25cm, 13.6cm, 2.25cm)
  #darrow(14.9cm, 2.25cm, 15.2cm, 2.25cm)
  #dnode(8.8cm, 0.5cm, 7.5cm, 1.1cm,
    [C' and D' are *new objects*: `0939c0b → 9eb9636`, `e4dd9cb → 3db7a77`. Anyone who already pulled C or D now has a conflicting history.], fill: rgb("#fdf4f4"))
]

#table(columns: (auto, 1fr, 1fr),
  [], [*merge*], [*rebase*],
  [History], [true — shows that a branch existed], [linear — looks like it was written in order],
  [Commit hashes], [unchanged], [*rewritten* for every replayed commit],
  [Extra commit], [yes, a merge commit with 2 parents], [none],
  [Conflicts], [resolved *once*], [possibly once *per replayed commit*],
  [Safe on a shared branch], [*yes*], [*no* — never rebase commits others have pulled],
  [Good for], [integrating a finished feature into `main`], [tidying *your own* branch before a PR],
)

#trap[
*The golden rule of rebase: never rebase a branch that other people have already pulled.* Their
clone still points at `0939c0b`; yours now says `9eb9636`. Their next `git pull` sees two
histories containing the same change and either creates a duplicate or forces a painful merge.
Rebase your private branch; merge everything else. "It rewrites history" is the phrase the panel
listens for.
]

#subsection[Fast-forward: the merge that is not a merge]

If `main` did *not* move while you worked, there is nothing to combine — Git just slides the
branch pointer forward.

```
$ git merge feat
Updating d3fdaba..5d8e775
Fast-forward
 b.txt | 1 +

$ git log --oneline --graph
* 5d8e775 B
* d3fdaba A          <- no merge commit at all
```

With `--no-ff` you force a merge commit anyway, which keeps a visible record that a feature
branch existed:

```
$ git merge --no-ff feat -m "merge feat"
*   e28c951 merge feat
|\
| * 5d8e775 B
|/
* d3fdaba A
```

Many teams require `--no-ff` on `main` for exactly that reason: the merge commit is the audit
trail of the pull request.

#section[12.12 reset vs revert vs checkout/restore]

The three commands students confuse. Here is the difference, measured.

Setup: two commits, `C1` writing `v1` to `f.txt` and `C2` writing `v2`. Then run each reset mode
on a fresh copy.

#table(columns: (auto, auto, auto, auto, auto),
  [*Command*], [*HEAD*], [*Index*], [*Working file*], [*`git status` shows*],
  [`reset --soft HEAD~1`],  [C1], [*still v2*], [v2], [`f.txt` staged, ready to re-commit],
  [`reset --mixed HEAD~1`], [C1], [reset to C1], [v2], [`f.txt` modified, *not* staged],
  [`reset --hard HEAD~1`],  [C1], [reset to C1], [*v1*], [nothing — your edit is *gone*],
)

That table is a real transcript, not a recollection. `--mixed` is the default when you type
`git reset HEAD~1` with no flag.

#table(columns: (auto, 1fr, 1fr),
  [], [*`git reset`*], [*`git revert`*],
  [What it does], [moves the branch pointer *backwards*], [creates a *new* commit that undoes an old one],
  [History], [*rewritten* — commits disappear from the branch], [*preserved* — the bad commit is still there],
  [Safe on a shared branch], [*no*], [*yes*],
  [Use when], [the commits are still local and private], [the commit is already pushed],
)

Real `git revert` transcript. Three commits; `C2` added `bad.txt`.

```
$ ls
a.txt  bad.txt  c.txt

$ git revert --no-edit HEAD~1
$ ls
a.txt  c.txt

$ git log --oneline
523ec46 Revert "C2 add bad.txt"
6f49bfc C3
12968d2 C2 add bad.txt        <- still in history
f9ba0fa C1
```

The file is gone from the working tree; the commit that added it is *still in the log*, and a new
commit records the undo. That is what "does not rewrite history" means in practice.

#note[
If the reverted commit and later commits touched the *same lines*, `git revert` will stop with a
merge conflict and ask you to resolve it, exactly like a merge. That is normal; fix the file,
`git add`, then `git revert --continue`.
]

#table(columns: (auto, 1fr),
  [*Command*], [*Effect*],
  [`git restore f.txt`], [throw away *working-directory* changes to `f.txt` (take the index version)],
  [`git restore --staged f.txt`], [unstage `f.txt`, keep the edit in the working directory],
  [`git checkout <commit>`], [move `HEAD` to that commit — *detached HEAD*],
  [`git switch <branch>`], [move to a branch (the modern, unambiguous spelling)],
  [`git reset --hard <commit>`], [move the branch *and* wipe index and working tree to match],
)

#trick[
`git checkout` did two unrelated jobs — switch branches *and* discard file changes — which is why
it confused everybody. Git 2.23 split it: `git switch` for branches, `git restore` for files. Use
those two names in an interview; it signals you have used Git recently.
]

#section[12.13 cherry-pick, stash, and .gitignore]

#subsection[cherry-pick — copy one commit onto another branch]

```
$ git log fix --oneline
5936873 wip
806a058 hotfix          <- we want only this one
d446f83 base

$ git switch main
$ git cherry-pick 806a058
$ git log --oneline
f888b61 hotfix          <- SAME change, DIFFERENT hash
d4e9ef2 main moves on
d446f83 base
```

The hash changed from `806a058` to `f888b61` for the same reason rebase changes hashes: the parent
is different, and the parent is part of what gets hashed. So cherry-pick *copies a change*; it
does not move a commit.

#subsection[stash — park uncommitted work]

```
$ git status --short
 M f.txt
?? new.txt

$ git stash push -m "wip"
$ git status --short
?? new.txt              <- untracked file was NOT stashed
$ cat f.txt
v1                      <- tracked edit is gone from the working tree

$ git stash list
stash@{0}: On main: wip

$ git stash pop
$ git status --short
 M f.txt                <- edit is back
?? new.txt
```

Two things that catch people out, both visible above: `git stash` by default takes only *tracked*
modifications — untracked files stay behind (use `-u` to include them) — and `pop` applies *and
deletes* the stash while `apply` keeps it.

#subsection[.gitignore does not untrack anything]

```
$ git add .env && git commit -m "oops committed .env"
$ echo ".env" > .gitignore && git commit -am "add gitignore"
$ echo changed > .env
$ git status --short
 M .env                 <- STILL TRACKED. .gitignore did nothing.

$ git rm --cached .env
$ git commit -m "untrack .env"
$ git status --short
                        <- clean, and .env is still on disk

$ git log --oneline --all -- .env
7903c18 untrack .env
e624687 oops committed .env    <- the secret is STILL in history
```

#trap[
*`.gitignore` only affects files Git is not already tracking.* Adding a path to it does nothing
for a file already in the index — you must `git rm --cached <file>`. And even then, *the old
content stays in every historical commit*. If it was a credential, it is compromised: rotate the
key. Removing it from history needs `git filter-repo` (or BFG) *and* a force-push *and* every
collaborator re-cloning. Say all three parts; the "rotate the key" part is what a security-aware
answer sounds like.
]

#section[12.14 Branching workflows]

#table(columns: (auto, 1fr, 1fr),
  [*Workflow*], [*Shape*], [*Fits*],
  [*Feature branch*], [branch off `main`, PR, review, merge back], [almost everyone; the default],
  [*Git flow*], [long-lived `develop`, `release/*`, `hotfix/*`, `main` is releases only], [versioned products with scheduled releases],
  [*Trunk-based*], [everyone commits to `main` many times a day behind feature flags], [continuous deployment, strong test suite],
  [*Forking*], [contributors fork, PR from their fork], [open source, untrusted contributors],
)

*A pull request that gets approved quickly:*

+ One branch, one purpose. `fix/login-redirect`, not `misc-changes`.
+ Small. Under ~400 changed lines is reviewable; 2,000 gets rubber-stamped, which is worse than
  not being reviewed.
+ Commit messages in the imperative: "Add retry to payment webhook", not "added stuff".
+ Rebase *your own* branch on `main` before opening it, so the diff is only your work.
+ Never commit generated files, `node_modules`, `.env`, or a lockfile you did not mean to change.

#section[12.15 Versioning and dependencies]

*Semantic versioning*: `MAJOR.MINOR.PATCH`.

- *MAJOR* — you broke the public API. Callers must change.
- *MINOR* — you added something, backwards compatible.
- *PATCH* — you fixed a bug, nothing else changed.

The npm range operators follow from that.

#code(lang: "js", caption: "What ^ and ~ actually allow")[```js
function satisfies(range, v) {
  const [M, m, p] = v.split(".").map(Number);
  const op = range[0] === "^" || range[0] === "~" ? range[0] : "=";
  const [RM, Rm, Rp] = range.replace(/^[\^~]/, "").split(".").map(Number);
  if (op === "=") return M === RM && m === Rm && p === Rp;
  if (op === "^") return M === RM && (m > Rm || (m === Rm && p >= Rp));  // MAJOR locked
  return M === RM && m === Rm && p >= Rp;                               // ~ locks MINOR too
}
const tests = [["^2.3.1","2.4.0"],["^2.3.1","3.0.0"],["^2.3.1","2.3.0"],
               ["~2.3.1","2.3.9"],["~2.3.1","2.4.0"],["2.3.1","2.3.1"]];
for (const [r, v] of tests) console.log(`${r.padEnd(7)} allows ${v.padEnd(7)} -> ${satisfies(r, v)}`);
```]

Real output:

```
^2.3.1  allows 2.4.0   -> true
^2.3.1  allows 3.0.0   -> false
^2.3.1  allows 2.3.0   -> false
~2.3.1  allows 2.3.9   -> true
~2.3.1  allows 2.4.0   -> false
2.3.1   allows 2.3.1   -> true
```

Read the pattern: `^` lets MINOR and PATCH move but freezes MAJOR. `~` lets only PATCH move. A
bare version pins exactly.

#table(columns: (auto, 1fr),
  [`package.json`], [What you *asked for*: ranges like `^2.3.1`. Human-edited.],
  [`package-lock.json`], [What you *got*: the exact version and integrity hash of every package in the whole tree. Machine-generated.],
  [`npm install`], [May update the lockfile to satisfy `package.json`.],
  [`npm ci`], [Installs *exactly* the lockfile, deletes `node_modules` first, fails if the two disagree. Use this in CI.],
)

#trap[
*Commit the lockfile for an application; do not rely on it for a library.* Without it, two
developers running `npm install` a week apart can get different transitive versions and one of
them sees a bug the other cannot reproduce. In CI always use `npm ci`, not `npm install` — `ci` is
reproducible and fails loudly when `package.json` and the lockfile have drifted apart.
]

#section[12.16 Static vs dynamic typing — and floating point]

One more front-end topic that gets asked as a "dev fundamentals" question.

#code(lang: "js", caption: "No compiler stopped any of these")[```js
function add(a, b) { return a + b; }
console.log(add(2, 3));        // 5
console.log(add("2", 3));      // "23"
console.log(add([], {}));      // "[object Object]"
console.log(add(0.1, 0.2));    // 0.30000000000000004
console.log(0.1 + 0.2 === 0.3);
console.log((0.1 + 0.2).toFixed(20));
```]

Real output:

```
5
23
[object Object]
0.30000000000000004
false
0.30000000000000004441
```

The last two lines are *not* a JavaScript bug. `0.1` and `0.2` are not representable in binary
floating point (IEEE-754 double), just as $1/3$ is not representable in finite decimal. The stored
value for `0.1 + 0.2` is genuinely a hair above `0.3`, and `.toFixed(20)` shows it: `...04441`.

Every language using doubles does this — C, Java, Python. The rules:

- Never compare floats with `===`. Compare `Math.abs(a - b) < 1e-9`.
- Never store money in a float. Store *minor units* as an integer: 1099 paise, not 10.99.
- For exact integers beyond $2^53 - 1 = 9007199254740991$, use `BigInt`.

#table(columns: (auto, 1fr, 1fr),
  [], [*Static typing*], [*Dynamic typing*],
  [Types checked], [at compile time], [at run time],
  [Errors found], [before shipping], [when that line executes],
  [Speed], [faster — the compiler knows the layout], [slower — types checked on every operation],
  [Flexibility], [less], [more],
  [Languages], [C, C++, Java, Go, Rust, TypeScript], [JavaScript, Python, Ruby],
  [Note], [*strong/weak* is a different axis], [JS is dynamic *and* weak; Python is dynamic and strong],
)

#trap[
*Static vs dynamic and strong vs weak are two different axes, and interviewers test whether you
know that.* Static/dynamic = *when* types are checked. Strong/weak = whether the language
*implicitly converts* between unrelated types. JavaScript is dynamic and weak (`"2" + 3` is
`"23"`). Python is dynamic and strong (`"2" + 3` raises `TypeError`). Java is static and
relatively strong. Saying "JS is weakly typed" alone is an incomplete answer.
]

#pagebreak(weak: true)
#section[12.17 Worked examples — Warm-up]

#tier-header(0)

#ex(1, tier: 0)[
Name the four stages of building a C program and the file each one produces.
]
#sol[
#table(columns: (auto, auto, auto),
  [1. Preprocess], [`gcc -E`], [`.i` — still C source],
  [2. Compile],    [`gcc -S`], [`.s` — assembly text],
  [3. Assemble],   [`gcc -c`], [`.o` — object file],
  [4. Link],       [`gcc`],    [executable],
)
#ans[Preprocess → compile → assemble → link, giving `.i`, `.s`, `.o`, executable.]
]

#ex(2, tier: 0)[
Which direction does the stack grow, and which way does the heap grow?
]
#sol[
The stack grows *down*, toward lower addresses — measured: each call moved the local from
`0x...284` to `0x...254`, a drop of 48 bytes. The heap grows *up*. They approach each other
across the free gap.
#ans[Stack down, heap up.]
]

#ex(3, tier: 0)[
What are the three Git object types you must be able to name, and what does each hold?
]
#sol[
*blob* — the bytes of one file, with no name attached. \
*tree* — a directory listing: mode, type, hash, filename per row. \
*commit* — one tree hash, the parent hash(es), author, committer, message.
#ans[blob (file bytes), tree (directory listing), commit (snapshot + parent + message).]
]

#ex(4, tier: 0)[
In one line each: `git diff`, `git diff --cached`, `git diff HEAD`.
]
#sol[
`git diff` — working directory vs *index*. \
`git diff --cached` — index vs *HEAD*. \
`git diff HEAD` — working directory vs *HEAD* (both of the above together).
#ans[Working↔index, index↔HEAD, working↔HEAD.]
]

#ex(5, tier: 0)[
`int big[1000000];` as a global. Roughly how much does this add to the *file* on disk, and to the
*process* in memory?
]
#sol[
It has no initialiser, so it lives in `.bss`. `.bss` records only "reserve this much and zero
it", so the *file* grows by almost nothing. The *process* grows by 4 MB
($1000000 times 4$ bytes).

Change it to `int big[1000000] = {1};` and it moves to `.data`, and now 4 MB of mostly zeros is
really written into the file.
#ans[File: ~0 bytes. Process: 4 MB. It is in `.bss`.]
]

#ex(6, tier: 0)[
What does `git stash` do with your *untracked* files by default?
]
#sol[
Nothing — it leaves them in the working directory. Verified: after `git stash push`,
`git status --short` still showed `?? new.txt`. Use `git stash -u` to include untracked files.
#ans[Leaves them alone. Use `-u` to include them.]
]

#section[12.18 Worked examples — Tier 1]

#tier-header(1)

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
Difference between a compiler and an interpreter. Give two examples of each and say which finds
errors earlier.
]
#sol[
A *compiler* translates the whole program to machine code *before* it runs and writes the result
to a file. An *interpreter* reads and executes the program one statement at a time, every time it
runs, and produces no file.

#table(columns: (auto, auto, auto),
  [], [*Compiler*], [*Interpreter*],
  [Translates], [whole program, once], [one statement, every run],
  [Output], [an executable file], [just the result],
  [Errors], [*all* syntax and type errors at build time], [only when that line is reached],
  [Speed], [faster to run, slower to start building], [slower to run, instant to start],
  [Examples], [C, C++, Go, Rust], [classic Python, Bash],
)

The compiler finds errors earlier — before a single user runs the program. A modern extra: a
*JIT* (Java HotSpot, V8) starts by interpreting and then compiles the hot functions to machine
code at run time, getting most of the speed with none of the build step.

#ans[Compiler: whole program ahead of time, produces a file, errors at build time. Interpreter: statement by statement at run time, errors when reached. JIT is the hybrid.]
]

#ex(8, tier: 1, asked: "Infosys · pattern")[
You get `undefined reference to 'compute'` when building a C project. Is this a compiler error or
a linker error? Give three causes.
]
#sol[
*Linker error.* The compiler was satisfied — it found a *declaration* (a prototype), which is all
it needs to emit a `call` instruction with a placeholder address. The linker then has to find the
*definition*, and there is none.

Verified transcript: `gcc -c u.c -o u.o` *succeeds*; `gcc u.o -o u` fails with
`undefined reference to 'helper'`.

Three causes:

+ You wrote the prototype in a header but never wrote the function body anywhere.
+ The body exists in `compute.c` but you did not compile or link it: you need
  `gcc main.c compute.c -o app`.
+ The function is in a library you did not link: e.g. using `sqrt` without `-lm`, or `pthread_create`
  without `-lpthread`.

A fourth, C++-only cause worth naming: *name mangling*. Calling a C function from C++ without
wrapping its declaration in `extern "C" { ... }` makes the C++ compiler look for a mangled name
the C object file does not contain.

#ans[Linker error. Missing definition, unlinked `.c` file, or missing `-l<library>` (plus `extern "C"` in C++).]
]

#ex(9, tier: 1, asked: "Wipro · pattern")[
Draw the memory layout of a running C program and say what lives in each part.
]
#sol[
Low address at the bottom:

#table(columns: (auto, 1fr, auto),
  [*stack*], [locals, parameters, return addresses; grows *down*], [`0x7fffe2b52bcc`],
  [*(gap)*], [free space the two ends grow into], [],
  [*heap*], [`malloc`/`new`; grows *up*; freed by you], [`0x17dca2a0`],
  [*.bss*], [globals/statics with *no* initialiser, zero-filled at load], [`0x404044`],
  [*.data*], [globals/statics *with* an initialiser], [`0x404030`],
  [*.rodata*], [string literals and `const` data, read-only], [`0x402004`],
  [*.text*], [the machine code, read-only], [`0x401196`],
)

The addresses on the right are from a real run of a program that printed the address of one
object in each segment, so the ordering is measured rather than assumed.

Two facts to add, because they are the usual follow-ups: `.bss` costs nothing in the *file*, only
in the *process*; and `.text` is read-only and can be *shared* between several processes running
the same binary.

#ans[Bottom to top: .text, .rodata, .data, .bss, heap (grows up), gap, stack (grows down).]
]

#ex(10, tier: 1, asked: "Capgemini · pattern")[
Difference between `git merge` and `git rebase`. When would you use each?
]
#sol[
*Merge* creates one new commit with *two parents*. Existing commits keep their hashes.

*Rebase* replays your commits one by one on top of the target branch. Each replayed commit gets a
*new hash*, because a commit's hash covers its parent.

Verified: after `git rebase main`, commit `C` went from `0939c0b` to `9eb9636` and `D` from
`e4dd9cb` to `3db7a77`.

#table(columns: (auto, auto, auto),
  [], [*merge*], [*rebase*],
  [Result graph], [branched, with a merge commit], [one straight line],
  [Hashes], [unchanged], [rewritten],
  [Conflicts], [once], [possibly once per commit],
  [Shared branch], [safe], [*unsafe*],
)

*Use merge* to bring a finished feature into `main`, and whenever the branch is shared.
*Use rebase* to tidy up *your own, unpushed* branch before opening a pull request, so reviewers
see only your changes and not a merge commit from `main`.

The golden rule: never rebase commits that other people have already pulled.

#ans[Merge joins with a two-parent commit and preserves hashes; rebase replays and rewrites hashes. Merge to integrate, rebase to tidy your own private branch.]
]

#ex(11, tier: 1, asked: "Accenture · pattern")[
`git reset` vs `git revert`. Which is safe on a branch you have already pushed, and why?
]
#sol[
*`git reset`* moves the branch pointer backwards. The commits after it vanish from the branch —
history is *rewritten*.

*`git revert`* creates a *new* commit whose content is the inverse of an old one. Nothing is
removed; history is *preserved*.

Verified: after `git revert --no-edit HEAD~1`, the file `bad.txt` was gone from the working tree,
but `git log` still showed `C2 add bad.txt`, with a new `Revert "C2 add bad.txt"` on top.

*`revert` is the safe one on a pushed branch*, because everyone else's clone already contains the
old commits. Reset would give you a history that contradicts theirs and require a force-push,
which destroys any commit they pushed in the meantime.

Bonus — the three reset modes, all measured on a repo where `C2` changed `f.txt` from `v1` to
`v2`:

#table(columns: (auto, auto, auto, auto),
  [*Mode*], [*HEAD*], [*Index*], [*Working file*],
  [`--soft`],  [C1], [still v2 (staged)], [v2],
  [`--mixed`], [C1], [reset to C1], [v2 (unstaged edit)],
  [`--hard`],  [C1], [reset to C1], [*v1 — edit destroyed*],
)

#ans[Reset rewrites history (unsafe once pushed); revert adds an inverse commit (safe). `--soft` keeps the change staged, `--mixed` unstages it, `--hard` destroys it.]
]

#ex(12, tier: 1, asked: "Cognizant · pattern")[
What is `#define SQ(x) x*x` going to compute for `SQ(2+3)`, and why? Fix it.
]
#sol[
The preprocessor does *text* substitution. It does not know that `2+3` is one value.

`SQ(2+3)` becomes the text `2+3*2+3`. C then applies normal precedence:
$2 + (3 times 2) + 3 = 2 + 6 + 3 = 11$.

Expected 25, got 11.

*Fix — parenthesise every parameter and the whole body:*

```c
#define SQ(x) ((x)*(x))
```

Now `SQ(2+3)` becomes `((2+3)*(2+3))` = $5 times 5 = 25$.

There is still a second bug even with the fix: `SQ(i++)` expands to `((i++)*(i++))`, which
increments `i` twice and is undefined behaviour. The real fix in C++ is
`inline int sq(int x) { return x*x; }` or `constexpr`, which evaluates the argument once and type-checks it.

#ans[11, because the macro pastes text: `2+3*2+3`. Fix with `((x)*(x))`; better, use an inline function.]
]

#section[12.19 Worked examples — Tier 2]

#tier-header(2)

#ex(13, tier: 2, asked: "Grab · pattern")[
A teammate says: "Our repo is 4 GB. Git must be storing every version of every file in full. We
should switch to a system that stores diffs." Is the diagnosis right? What would you actually
check and do?
]
#sol[
*The premise is half right and the conclusion is wrong.*

Git *does* store a full snapshot per commit at the object level — a commit points at a tree, the
tree points at blobs, and each blob is a complete file. But Git then packs loose objects into
*pack files* and delta-compresses them, so on disk you do not pay full size per version.

Measured proof. Commit a 50,000-byte random file, change *one character*, commit again:

#table(columns: (auto, auto),
  [Two loose blobs in `.git/objects`], [74,573 bytes],
  [After `git gc` (packed with deltas)], [39,387 bytes],
)

So the storage model is "snapshots logically, deltas physically". Switching version control
systems would gain nothing here.

*What to actually check.*

+ `git count-objects -vH` — how much is loose vs packed. If loose is large, `git gc` has not run.
+ Find the big objects: list the pack index sorted by size and map hashes to paths. Nine times
  out of ten the answer is a handful of binaries — a 300 MB video, a committed `node_modules`,
  a vendored SDK, or build output.
+ `git log --all --diff-filter=A -- <path>` to see when each big file was added.

*What to do.*

- Add the offending paths to `.gitignore` *and* `git rm --cached` them, so they stop growing.
- Move large binaries to *Git LFS*, which stores a pointer in the repo and the bytes elsewhere.
- Only if history size is genuinely blocking people: rewrite history with `git filter-repo` to
  drop those blobs. This changes every commit hash after the rewrite, needs a force-push, and
  every collaborator must re-clone. It is a last resort, agreed with the whole team.
- For everyday relief without rewriting: `git clone --filter=blob:none` (partial clone) or
  `--depth=1` (shallow clone) for CI machines that do not need history.

#ans[Diagnosis is wrong: Git stores snapshots logically but delta-compresses in pack files (measured 74,573 → 39,387 bytes). The real cause is almost always large binaries. Fix with `.gitignore` + `git rm --cached`, Git LFS, shallow/partial clones, and `filter-repo` only as a last resort.]
]

#ex(14, tier: 2, asked: "Shopee · pattern")[
A build works on your laptop and fails in CI with a "cannot find module" error from a package
nobody changed. Walk through the likely causes and how you would make the build reproducible.
]
#sol[
*Read the symptom precisely:* the code did not change, the *dependency tree* did. Something in
the install step is not pinned.

*Cause 1 — `npm install` instead of `npm ci` in CI.* `npm install` is allowed to resolve ranges
freshly and update the lockfile. A `^2.3.1` range accepts `2.4.0`, and that release may have
dropped an export.

Verified range behaviour:

#table(columns: (auto, auto, auto),
  [*Range*], [*2.4.0*], [*3.0.0*],
  [`^2.3.1`], [allowed], [blocked],
  [`~2.3.1`], [blocked], [blocked],
)

So `^` will happily take a new MINOR, and a MINOR is where an accidental breaking change usually
hides.

*Cause 2 — the lockfile is not committed, or is in `.gitignore`.* Then CI has nothing to install
*from* and resolves ranges from scratch.

*Cause 3 — a transitive dependency.* Your direct deps are pinned but a dependency of a dependency
is not, and only the lockfile records those.

*Cause 4 — different Node versions.* A native module compiled for Node 18 on your laptop, Node 22
in CI.

*Cause 5 — case sensitivity.* `require("./Utils")` works on macOS/Windows (case-insensitive
filesystems) and fails on Linux CI. Very common and very confusing.

*How to make it reproducible.*

+ Commit `package-lock.json`. It records the exact version *and integrity hash* of every package
  in the whole tree.
+ In CI use `npm ci` — it deletes `node_modules`, installs exactly the lockfile, and *fails* if
  the lockfile and `package.json` disagree. `npm install` does none of that.
+ Pin the runtime: an `.nvmrc` / `engines` field, and the same version in the CI config.
+ Cache by *lockfile hash*, not by branch, so a changed lockfile always means a fresh install.
+ Build once, promote the same artefact through environments; do not rebuild per environment.

#ans[Unpinned transitive dependency resolved differently in CI. Commit the lockfile, use `npm ci` not `npm install`, pin the Node version, key the cache on the lockfile hash, and check for case-sensitivity differences on Linux.]
]

#ex(15, tier: 2, asked: "Agoda · pattern")[
You are on a feature branch with 9 messy commits ("wip", "fix typo", "wip again"). `main` has
moved ahead by 12 commits. Describe exactly how you prepare this for review, and what you must
check before you push.
]
#sol[
*Goal:* the reviewer should see a small number of meaningful commits, and a diff that contains
only your work — no noise from `main`.

*Step 1 — make sure nothing is uncommitted.*

```
git status
git stash -u        # if anything is in progress
```

*Step 2 — get the real `main`.*

```
git fetch origin
```

Fetch, not pull. `fetch` updates `origin/main` without touching your branch.

*Step 3 — rebase onto it.*

```
git rebase origin/main
```

Your 9 commits are replayed on top of the 12 new ones. Every one of them gets a new hash. If a
conflict stops the rebase, fix the files, `git add`, then `git rebase --continue`. To bail out at
any point: `git rebase --abort`.

*Step 4 — squash the noise.*

```
git rebase -i origin/main
```

In the editor, keep `pick` on the commits that are real units of work, change the rest to
`squash` (or `fixup` to also throw away their messages). Nine commits become, say, two:
"Add retry to payment webhook" and "Add tests for webhook retry".

*Step 5 — check before pushing.*

+ `git log --oneline origin/main..HEAD` — is the list exactly your commits, in a sensible order?
+ `git diff origin/main...HEAD` — does the diff contain *only* your change? Anything from `main`
  appearing here means the rebase went wrong.
+ Run the tests. Rebasing replays each commit but does not compile them; a silent semantic
  conflict is possible even with zero textual conflicts.
+ Confirm *nobody else is working on this branch*. Rebasing rewrites hashes, so if a colleague
  has pulled it, you will break their clone.

*Step 6 — push.*

```
git push --force-with-lease
```

*`--force-with-lease`, never plain `--force`.* Plain force overwrites the remote branch
unconditionally, including a commit somebody pushed while you were rebasing.
`--force-with-lease` refuses unless the remote is still where you last saw it.

#ans[fetch → `git rebase origin/main` → `git rebase -i` to squash → verify with `git log origin/main..HEAD` and `git diff origin/main...HEAD` → run tests → `git push --force-with-lease`. Only safe because the branch is yours alone.]
]

#ex(16, tier: 2, asked: "DBS · pattern")[
A C service crashes only in production, only under load, and only in a build compiled with
`-O2`. The same build at `-O0` never crashes. What is your hypothesis and how do you test it?
]
#sol[
*Hypothesis: the program has undefined behaviour, and the optimiser is exposing it.*

The optimiser is allowed to assume UB never occurs. If your code relies on signed overflow
wrapping, on reading uninitialised memory, on a strict-aliasing violation, or on unsynchronised
access from two threads, then `-O2` may reorder, cache in a register, or delete the code around
it — and only then does the bug appear. "Works at `-O0`" is *evidence of UB*, not evidence that
`-O2` is broken.

Load makes it worse because a data race needs two threads to interleave badly, and higher load
means more interleavings per second.

*How to test it, in order of cost.*

+ *Turn on the warnings you are not using.* `-Wall -Wextra -Wuninitialized -Wstrict-aliasing=2`.
  Free, and often enough.
+ *UndefinedBehaviorSanitizer*: rebuild with `-fsanitize=undefined -fno-omit-frame-pointer` and
  run the load test. It prints file and line when UB happens.
+ *ThreadSanitizer*: `-fsanitize=thread`. This is the one for "only under load" — it detects data
  races even when the race did not actually corrupt anything on that run.
+ *AddressSanitizer*: `-fsanitize=address` for use-after-free and buffer overruns. (Run it
  separately from TSan; they do not combine.)
+ *Bisect the optimisation.* If a sanitiser finds nothing, try `-O2 -fno-strict-aliasing`. If that
  fixes it, you have an aliasing bug — code reading the same memory through two incompatible
  pointer types.
+ *Bisect the code.* `git bisect run ./loadtest.sh` to find the commit that introduced it.

*What is NOT the fix:* shipping at `-O0`, or adding `volatile` until the symptom goes away. Both
hide the bug for the current compiler version and it returns after the next upgrade. Fix the UB.

#ans[Undefined behaviour exposed by the optimiser — most likely a data race or strict-aliasing violation. Test with `-fsanitize=thread`, then `undefined`, then `address`; try `-fno-strict-aliasing` as a diagnostic; `git bisect` to find the commit. Do not ship at `-O0`.]
]

#section[12.20 Worked examples — Tier 3]

#tier-header(3)

#ex(17, tier: 3, asked: "Google · pattern")[
Explain precisely why a Git commit hash changes when you rebase, what security property the hash
chain gives you, and what breaks if SHA-1 collisions become cheap.
]
#sol[
*Why the hash changes.*

A commit object's serialised body is, literally:

```
tree <tree-sha>
parent <parent-sha>
author <name> <email> <timestamp> <tz>
committer <name> <email> <timestamp> <tz>

<message>
```

and its name is `SHA-1("commit " + len + "\0" + body)`. The *parent hash is inside the body*. A
rebase replays your change onto a different base, so the parent field is different, so the body is
different, so the hash is different. There is no way to keep the hash and change the parent —
that is the whole design.

Measured: rebasing `C` onto `E` changed it from `0939c0b` to `9eb9636`; `D` followed, from
`e4dd9cb` to `3db7a77`. `D`'s hash had to change *even though its content did not*, because its
parent `C` changed. That cascade is the point.

Note also that `committer` includes a *timestamp*, so cherry-picking the same change at a
different moment also yields a different hash — verified: `806a058` on the branch became `f888b61`
on `main`.

*The security property: a Merkle tree (hash chain).*

Each commit names its tree; each tree names its blobs and sub-trees; each commit names its
parent. So one commit hash transitively covers *every byte of every file in every ancestor
commit*.

Consequences:

- If anyone alters a file in a commit from 2019, that blob's hash changes, so its tree's hash
  changes, so that commit's hash changes, so every descendant's hash changes. `git fsck` sees it
  immediately.
- Saying "my HEAD is `9eb9636`" to a colleague is a complete, verifiable statement about the
  entire history. This is why signing *one* tag with GPG effectively vouches for everything
  beneath it.
- It also means history is *append-only in practice*: any edit to the past is visible as a change
  of identity, not a silent modification.

*What breaks if SHA-1 collisions get cheap.*

A *collision* (two inputs, same hash, attacker chooses both) has been demonstrated — SHAttered,
2017. What Git actually needs to fear is a *second-preimage* attack (given a commit that already
exists, find different content with the same hash), which is much harder and has not been
demonstrated.

If collisions became cheap enough to be useful, the attack shape is: get a benign blob accepted
into the repo, then serve a malicious blob with the same hash. Everyone verifying by hash accepts
it. Signed tags would not help, because the signature covers the hash and the hash still matches.

Git's actual mitigations:

+ *Collision detection on every hash.* Git ships `sha1dc`, which detects the specific bit patterns
  used by known collision attacks and aborts rather than accepting the object.
+ *SHA-256 repositories.* Supported since Git 2.29 (`git init --object-format=sha256`). Adoption
  is slow because interoperability with SHA-1 remotes is the hard part.
+ *Practical friction:* the attacker must get the benign half committed, and Git objects are
  length-prefixed and typed, which constrains what a colliding pair can look like.

#ans[The parent hash is part of the commit body, so changing the parent changes the hash, and the change cascades to every descendant. That makes Git a Merkle tree: one hash covers all history, so tampering is detectable. Cheap collisions would let a malicious blob impersonate a benign one; Git mitigates with sha1dc collision detection and optional SHA-256 repositories.]
]

#ex(18, tier: 3, asked: "Amazon · pattern")[
A service written in a JIT-compiled language has fast median latency but a terrible 99th
percentile, and the worst latencies cluster in the first minutes after deployment. Explain the
mechanism and give four mitigations with their costs.
]
#sol[
*The mechanism, in order.*

+ *Cold start.* A JIT begins by *interpreting*. Interpretation is roughly an order of magnitude
  slower — measured in section 12.2, the interpreted tree walk took 114 ms against 7 ms for the
  same work compiled to closures, a factor of about 16. Every request in the first seconds pays
  that.
+ *Profiling overhead.* While interpreting, the runtime counts call sites and loop iterations to
  decide what is hot. That counting is not free either.
+ *Compilation pauses.* When a function becomes hot, a compiler thread optimises it. On a busy
  machine that thread competes for CPU with request handling.
+ *Deoptimisation.* This is the one that produces *late* spikes, not just early ones. The
  optimiser speculates — "this call site always receives the same object shape", "this value is
  always a small integer" — and compiles code that assumes it. The first request that breaks the
  assumption triggers a *deopt*: throw away the optimised code, fall back to the interpreter,
  re-profile, recompile. A rare input path can therefore cost hundreds of times the median.
+ *Garbage collection.* Warm-up allocates heavily (profiling data, compiled code, caches). Early
  GC pauses land on top of everything above.

Deploy all instances at once and every one of them is cold simultaneously, so the p99 for the
whole fleet degrades together.

*Four mitigations, with honest costs.*

#table(columns: (auto, 1fr, 1fr),
  [*Mitigation*], [*What it does*], [*Cost*],
  [Warm-up before serving], [Send synthetic traffic through the real code paths, and only then mark the instance healthy in the load balancer.], [Slower deploys; the synthetic traffic must exercise the *real* paths or you warm the wrong code.],
  [Rolling deploy with surge], [Replace a few instances at a time, keeping warm ones serving.], [Longer deploys; two versions live at once, so the code must be backwards compatible.],
  [Ahead-of-time compilation], [Compile before shipping (GraalVM native image, CRaC/AppCDS for Java, V8 code cache/snapshots).], [Loses peak throughput — AOT cannot use run-time profiles; longer builds; some dynamic features stop working.],
  [Make the code less speculative], [Keep object shapes stable (same fields, same order, same types), avoid megamorphic call sites, avoid mixing types in hot arrays.], [Constrains how you write code; needs profiling tools to find the megamorphic sites.],
)

*How to prove which one it is before changing anything.*

- Plot latency *against instance age*. If the spike is confined to the first N seconds, it is
  warm-up. If it recurs later, suspect deopt or GC.
- Read the runtime's own logs: `--trace-deopt` / `--trace-opt` in V8, JIT compilation logs in the
  JVM. A deopt storm is unmistakable.
- Separate GC time from CPU time in the metrics. If p99 tracks GC pause duration, warm-up is not
  your problem.
- Check whether p99 improves when you *slow the deploy down*. If it does, it is a fleet-wide cold
  start and rolling deploys are the cheapest fix.

*The trade-off sentence:* a JIT buys peak throughput by deciding late; the price is paid as
variance early and as deoptimisation whenever a late assumption is broken. AOT buys predictability
and gives up the peak.

#ans[Cold start: the JIT interprets first (measured ~16× slower), profiles, then compiles, and later deoptimises when a speculation is violated; GC pauses stack on top. Mitigate with pre-serving warm-up, rolling deploys, AOT compilation, and less speculative code — each trading peak throughput or deploy speed for predictability.]
]

#ex(19, tier: 3, asked: "Microsoft · pattern")[
Design the Git strategy for a repository with 200 engineers, releases every two weeks, and a
requirement that any release can be patched within one hour. Justify each choice and name what
you are giving up.
]
#sol[
*Step 1 — pin down what the constraints actually force.*

- *200 engineers* means long-lived branches are lethal: the more branches live for days, the more
  merge conflicts grow superlinearly with the number of concurrent editors.
- *Two-week releases* means there must be *something stable to ship*, so a pure "`main` is always
  the release" model is not enough on its own.
- *Patch within one hour* means you must be able to build a fix on the exact code that is in
  production, without dragging in anything merged since.

That third constraint is the decisive one: it forces a *release branch*, because you need a place
to apply a fix that is not `main`.

*Step 2 — the model.*

#table(columns: (auto, 1fr),
  [`main`], [Always green, always deployable. Every merge is gated by CI. Nobody commits directly.],
  [`feature/*`], [Short-lived — target *under two days*. Branch from `main`, rebase on `main`, PR, squash-merge back, delete.],
  [`release/1.14`], [Cut from `main` at the start of the release window. Tagged `v1.14.0` when shipped. Kept alive for the support period.],
  [`hotfix/*`], [Branched *from the release branch*, not from `main`. Fix, test, merge into the release branch, tag `v1.14.1`, deploy. Then *cherry-pick into `main`*.],
)

*Step 3 — the one-hour patch path, concretely.*

```
git switch release/1.14
git switch -c hotfix/order-total-rounding
# ...fix, test...
git switch release/1.14 && git merge --no-ff hotfix/order-total-rounding
git tag -s v1.14.1 && git push origin release/1.14 --tags
git switch main && git cherry-pick <the fix commit>
```

The cherry-pick is the step teams forget, and the failure it causes is the classic *regression on
the next release*: 1.14.1 fixed the bug, 1.15 shipped without the fix, the bug came back. Automate
it — a bot that opens the cherry-pick PR the moment a hotfix lands on a release branch.

*Step 4 — the rules that make it survive 200 people.*

+ *Squash-merge PRs into `main`.* One feature, one commit. It makes `git bisect` meaningful and
  makes cherry-picking a hotfix a single-commit operation.
+ *Merge with `--no-ff` from release branches* so the release history shows discrete units.
+ *Feature flags for anything that spans more than two days.* Merge incomplete work behind a flag
  rather than keeping a branch open. This is what actually keeps branches short.
+ *Protected branches*: no force-push to `main` or `release/*`, required reviews, required CI.
  Force-push only ever with `--force-with-lease`, and only on personal branches.
+ *Signed, annotated tags* for releases. The hash chain then means one signature vouches for the
  whole tree.
+ *Merge queue.* At 200 engineers, "CI passed on my branch" is not "CI passes on `main`" —
  something else merged in between. A merge queue re-tests each PR against the current `main`
  before landing it.
+ *CODEOWNERS* so reviews route automatically instead of by asking in chat.

*Step 5 — what you are giving up. Name this; it is the part that distinguishes a senior answer.*

- *Not trunk-based.* Release branches add ceremony and a permanent risk of divergence between
  `main` and `release/*`. You accept that cost to buy the one-hour patch guarantee.
- *Squash-merging destroys intermediate commits.* You lose fine-grained history and per-commit
  authorship inside a feature. You accept that to get a bisectable `main`.
- *Feature flags are technical debt.* Every flag is a branch in the code and a combination to
  test. You need an owner and an expiry date per flag, and a quarterly sweep, or they accumulate.
- *A merge queue adds latency.* Time from approval to landing grows, and the queue itself needs
  capacity and monitoring.
- *Supporting multiple release branches multiplies backport work.* Cap it — support the last two
  releases, not five.

#ans[Trunk-ish `main` plus short-lived feature branches, cut a `release/*` branch per release, hotfix *from* the release branch then cherry-pick back to `main`. Squash-merge, protected branches, merge queue, feature flags, signed tags. Giving up: pure trunk-based simplicity, fine-grained history, flag debt, merge-queue latency, and backport cost.]
]

#pagebreak(weak: true)
#section[12.21 Practice]

#practice(tier: 0, time: "6 min")[
+ Which stage turns `.s` into `.o`?
+ Which segment holds a string literal `"hello"`?
+ Which segment holds an uninitialised global?
+ What is inside `.git/refs/heads/main`?
+ `git diff --cached` compares what to what?
+ Does a commit store a diff or a snapshot?
+ Which command is safe on an already-pushed branch — `reset` or `revert`?
]

#key[
1. The assembler (`gcc -c`). 2. `.rodata` — read-only. 3. `.bss`. 4. A single 40-character commit
SHA. 5. The index versus HEAD. 6. A snapshot (a tree hash); deltas happen later in pack files.
7. `revert`.
]

#practice(tier: 1, time: "14 min")[
+ Write the four `gcc` commands for the four stages and name each output file.
+ Explain in three lines why `gcc -c` succeeds but `gcc` fails with "undefined reference".
+ Give three differences between static and dynamic linking, with a number for at least one.
+ What does `git cat-file -p HEAD` print? Name every field.
+ Explain the three `git reset` modes in terms of HEAD, index and working directory.
+ A colleague force-pushed and your commits vanished. How do you recover them?
+ What does `.bss` cost in the file, and what does it cost in memory?
]

#key[
1. `gcc -E f.c -o f.i`; `gcc -S f.i -o f.s`; `gcc -c f.s -o f.o`; `gcc f.o -o f`.
2. `-c` stops after assembling. The compiler only needs a *declaration* to emit a `call` with a
placeholder address. The linker needs a *definition* and cannot find one.
3. Size (measured: 785,328 bytes static vs 15,960 dynamic — about 49×); RAM sharing (one copy of a
`.so` serves every process); patching (replace the `.so` once vs rebuild every program). Plus:
static starts faster, dynamic can fail at load time.
4. `tree <sha>`, `parent <sha>` (absent on the first commit, twice on a merge), `author
name/email/timestamp/tz`, `committer` (same fields), blank line, then the message.
5. `--soft`: moves HEAD only — the change stays *staged*. `--mixed` (default): moves HEAD and
resets the index — the change stays in the *working directory*, unstaged. `--hard`: moves all
three — *the change is destroyed*.
6. `git reflog` on *your* machine still lists every position HEAD held. Find the hash, then
`git switch -c rescue <hash>` (or `git reset --hard <hash>`). The reflog is local, so this works
only on a machine that had the commits.
7. Nearly zero bytes in the file (it records only "reserve this much, zero-filled"). Full size in
memory once the process starts.
]

#practice(tier: 2, time: "18 min")[
+ Your branch has 6 commits; `main` moved by 20. Give the exact command sequence to prepare a
  clean PR, and the one flag that makes the final push safe.
+ Explain why `0.1 + 0.2 !=` `0.3` and give the correct way to store a price.
+ CI passes, production fails, same commit. Give five hypotheses.
+ Why is `npm ci` preferred over `npm install` in CI? What exactly does it do differently?
+ A file was committed with a password in it three months ago. It is no longer in the working
  tree. Is the secret safe? What do you do?
]

#key[
1. `git fetch origin` → `git rebase origin/main` → `git rebase -i origin/main` (squash the noise)
→ verify with `git log --oneline origin/main..HEAD` and `git diff origin/main...HEAD` → run tests
→ `git push --force-with-lease`. The safe flag is `--force-with-lease`, which refuses if the
remote moved since you last fetched.
2. Neither `0.1` nor `0.2` is exactly representable in binary IEEE-754, so the sum is a hair high
— `(0.1+0.2).toFixed(20)` really prints `0.30000000000000004441`. Store money as an *integer in
minor units* (1099 paise) or use a decimal library; compare floats with a tolerance, never `===`.
3. (a) Different environment variables or config. (b) Different data — production has rows CI's
fixtures do not. (c) Different dependency versions (unpinned lockfile). (d) Concurrency and load —
races only appear with real traffic. (e) Different OS or filesystem (case sensitivity, path
separators, locale). Also: CI runs a fresh process; production has long-lived state and caches.
4. `npm ci` deletes `node_modules`, installs *exactly* what `package-lock.json` says, never
updates the lockfile, and *fails* if `package.json` and the lockfile disagree. `npm install`
resolves ranges and may silently change the lockfile, so two CI runs on the same commit can
install different trees.
5. *It is not safe.* Removing a file from the working tree does not remove it from history —
`git log --all -- <path>` still finds the blob, and anyone with a clone has it. Order of
operations: (a) *rotate the credential immediately* — this is the only step that actually fixes
the exposure; (b) remove it from the current tree and add it to `.gitignore`; (c) if the repo is
private and the team agrees, rewrite history with `git filter-repo`, force-push, and have everyone
re-clone; (d) add a secret-scanning pre-commit hook so it cannot happen again.
]

#practice(tier: 3, time: "22 min")[
+ Explain why `git rebase` can produce a build that fails even though every individual commit
  merged with zero textual conflicts.
+ You have a 40-minute CI pipeline and 200 engineers merging. Describe how "CI green on my branch"
  can still break `main`, and what fixes it.
+ Why can `-O2` break a correct-looking multithreaded C program that works at `-O0`? Name the two
  language-level tools that make it correct.
+ Given only a commit hash, explain exactly what you can and cannot prove about the repository.
]

#key[
1. Git merges *text*, not *meaning*. A *semantic conflict*: your branch adds a call to
`helper(a, b)`; `main` independently changed `helper` to take three parameters. Neither change
touches the other's lines, so there is no textual conflict, and the rebase is silent — but the
build is broken. Only running the build and tests after the rebase catches it. This is why
"rebased cleanly" is never the same as "it works".
2. Your branch was tested against `main` as it was when you branched. By the time you merge, 40
minutes of other merges have landed. Two PRs can each pass alone and conflict semantically
together. Fixes: a *merge queue* that re-tests each PR against the current `main` immediately
before landing; required "branch up to date before merge"; splitting the pipeline so a fast subset
gates the merge and the slow suite runs post-merge with automatic revert on failure; and reducing
batch size so fewer changes are in flight at once.
3. Without synchronisation, the compiler may keep a shared variable in a register across a loop,
reorder stores, or delete a read it believes is redundant — all legal, because a data race is
*undefined behaviour* and the optimiser may assume there is none. At `-O0` the compiler reloads
from memory every time, which accidentally hides the bug. The two correct tools: a *mutex*
(`pthread_mutex_t` / `std::mutex`) for anything non-trivial, and *atomics* with a defined memory
order (`_Atomic` / `std::atomic`) for single variables. `volatile` is *not* one of them — it
prevents compiler caching but gives no ordering or atomicity guarantees against other threads.
4. *Can prove*: that the entire history reachable from that commit — every file, every tree, every
ancestor commit, every author line and timestamp — is exactly what it was, because each object's
hash covers its contents and each commit's hash covers its parent and tree. Anyone presenting
different bytes under that hash is detectable. *Cannot prove*: who wrote it (the author field is
free text; only a GPG/SSH signature binds an identity), that it is the *latest* commit on any
branch (a hash names a point, not a tip), that any branch still points at it (refs move; the
commit may be unreachable and pending garbage collection), or anything about commits that are not
its ancestors.
]

#pagebreak(weak: true)
#section[12.22 Rapid fire — one-line answers]

Cover the right column. Say each answer out loud.

#table(columns: (1fr, 1.15fr),
  [*Question*], [*Answer*],

  [Four stages of building a C program?],
  [Preprocess → compile → assemble → link.],

  [What does the preprocessor actually do?],
  [Text substitution: expand `#include` and `#define`, strip comments.],

  [Compiler vs interpreter in one line?],
  [Compiler makes a file ahead of time; interpreter produces an answer as it goes.],

  [What is a JIT?],
  [Interprets first, compiles the hot code at run time. V8, HotSpot.],

  [`undefined reference` vs "was not declared"?],
  [Linker vs compiler. One found the declaration but no definition; the other found neither.],

  [Which segment: `"hi"` · `int g;` · `int g = 5;`?],
  [`.rodata` · `.bss` (free on disk) · `.data`.],

  [Stack direction? Heap direction?],
  [Stack grows down, heap grows up.],

  [What is in a stack frame?],
  [Return address, saved registers, parameters, locals.],

  [Stack overflow vs heap exhaustion?],
  [Deep recursion vs too many allocations. Different limits, different errors.],

  [JS recursion depth limit, roughly?],
  [Measured ~12,500 frames — so use an explicit stack past ~10^4.],

  [Three optimisations by name?],
  [Constant folding, dead code elimination, loop-invariant code motion.],

  [Why can `-O2` break working code?],
  [The program has undefined behaviour; the optimiser assumes it cannot happen.],

  [Git's three object types?],
  [blob (file bytes), tree (directory listing), commit (snapshot + parent + message).],

  [How is a blob named?],
  [`SHA-1("blob " + length + "\\0" + content)` — verified by hand.],

  [Is a commit a diff or a snapshot?],
  [A snapshot. Deltas exist only inside pack files.],

  [What is a branch, physically?],
  [A file holding one 40-character commit SHA.],

  [What is `HEAD`? What is *detached* HEAD?],
  [A one-line file naming your branch. Detached = it holds a raw SHA, so new commits belong to no branch.],

  [`git diff` vs `--cached` vs `HEAD`?],
  [Working↔index, index↔HEAD, working↔HEAD.],

  [merge vs rebase, and why do hashes change?],
  [Merge adds a two-parent commit. Rebase replays onto a new parent — and the parent SHA is inside the hashed body, so every hash is rewritten.],

  [The golden rule of rebase?],
  [Never rebase commits that others have already pulled.],

  [reset `--soft` / `--mixed` / `--hard`?],
  [Staged / unstaged / destroyed.],

  [reset vs revert?],
  [Reset rewrites history; revert adds an inverse commit. Revert is safe once pushed.],

  [Does `git stash` take untracked files?],
  [No, not by default. Use `-u`.],

  [Does `.gitignore` untrack a tracked file?],
  [No. You need `git rm --cached`, and history still has it.],

  [How do you recover from a bad `reset --hard`?],
  [`git reflog`, find the hash, `git reset --hard HEAD@{1}`.],

  [`--force` vs `--force-with-lease`?],
  [Lease refuses if the remote moved since your last fetch. Always use lease.],

  [`npm install` vs `npm ci`?],
  [`ci` installs the lockfile exactly, wipes `node_modules`, and fails on drift.],

  [What do `^2.3.1` and `~2.3.1` allow?],
  [`^`: any 2.x ≥ 2.3.1. `~`: any 2.3.x ≥ 2.3.1.],

  [Why is `0.1 + 0.2 !=` `0.3`, and how do you store money?],
  [Neither is exactly representable in binary IEEE-754. Store money as an integer in minor units.],

  [Static/dynamic vs strong/weak typing?],
  [*When* types are checked vs whether implicit conversion happens. Two axes.],
)

#revision[
*Build pipeline.* Preprocess (`-E`, text) → compile (`-S`, assembly) → assemble (`-c`, object) →
link (executable). Measured: 6 lines → 819 → 56 asm lines → 1528 B → 15960 B.

*Error, at which stage?* "not declared" = compiler. "undefined reference" = linker. "multiple
definition" = linker. Works at `-O0`, breaks at `-O2` = undefined behaviour in your code.

*Linking.* Static: one big file (785 KB vs 16 KB measured), no runtime dependency, rebuild to
patch. Dynamic: small, one shared copy in RAM, patch the `.so` once.

*Memory layout*, low to high: `.text` `0x401196` → `.rodata` `0x402004` → `.data` `0x404030` →
`.bss` `0x404044` → heap `0x17dca2a0` (grows ↑) → gap → stack `0x7fffe2b52bcc` (grows ↓).
`.bss` is free on disk, not free in RAM.

*Stack frames.* Measured 48 bytes each, addresses decreasing. JS dies at ~12,500 frames — past
$10^4$, use an explicit stack.

*Compiler front end.* Lexer → tokens. Parser → AST (precedence is the grammar's shape).
Semantic analysis → symbol table, type checks.

*Git objects.* blob = file bytes; tree = directory listing; commit = tree + parent + author +
message. Blob name = `SHA-1("blob " + len + "\\0" + content)` — verified by hand against
`git hash-object`. Commits are *snapshots*; deltas live in pack files.

*Git is files.* A branch is 41 bytes holding a SHA. `HEAD` is one line. Detached HEAD = a raw SHA
in `HEAD`. `git reflog` remembers every position and is the undo button.

*The four commands people confuse.*
+ `reset --soft` keeps the change *staged*; `--mixed` *unstaged*; `--hard` *destroys* it.
+ `revert` adds an inverse commit — the only safe undo on a pushed branch.
+ `rebase` rewrites hashes (verified `0939c0b → 9eb9636`). Never on a shared branch.
+ `cherry-pick` copies a change and gives it a new hash.

*Dependencies.* `package.json` = what you asked for; the lockfile = what you got. `npm ci` in CI,
always. `^` frees MINOR+PATCH, `~` frees PATCH only.

*Floating point.* `0.1 + 0.2` is `0.30000000000000004`. Money goes in integer minor units.
Compare floats with a tolerance. Past $2^53 - 1$, use `BigInt`.
]

]
