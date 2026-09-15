#import "../../shared/lib/style.typ": *

// Local helper: the Java/C++ answer the interview panel is listening for.
#let expects(body) = formulas(title: "What the interviewer expects to hear — Java / C++")[#body]

#chapter(num: 11, title: "OOP: Principles & Language Mechanics",
  tagline: "Four pillars, the words the panel uses, and the truth about JavaScript")[

This chapter is different from the rest of the book.

Your day job is JavaScript. But the OOP round at a service company is asked in *Java and C++
vocabulary*: virtual functions, abstract classes, interfaces, method overloading, the diamond
problem. The interviewer has a checklist and the words on it are Java words.

So every topic here is taught three times:

+ *The idea* — what the concept actually means, in plain language, in no particular language.
+ *The JS reality* — what JavaScript really does, with code you can run.
+ *What the interviewer expects to hear* — the Java/C++ sentence that scores the point.

A student who can only answer in JS fails this round. A student who can do all three passes it
and sounds senior. Learn all three.

#formulas(title: "The vocabulary you must be able to define in one line")[
#table(columns: (auto, 1fr),
  [*Class*], [A blueprint. Describes what state and behaviour objects of this kind have.],
  [*Object*], [One concrete thing built from a class. Has its own copy of the state.],
  [*Encapsulation*], [Keep data private; expose behaviour. The object guards its own invariants.],
  [*Abstraction*], [Show what a thing does, hide how. The caller sees a contract, not the wiring.],
  [*Inheritance*], [A child class reuses and extends a parent. Models "is-a".],
  [*Polymorphism*], [One name, many behaviours, chosen by the actual type at call time.],
  [*Overloading*], [Same method name, *different parameter list*. Chosen at *compile* time.],
  [*Overriding*], [Same method name, *same signature*, in a child class. Chosen at *run* time.],
  [*Virtual function*], [C++: a method the compiler dispatches through a table, so the child version runs.],
  [*Abstract class*], [Cannot be instantiated. May hold state and concrete methods. `extends` it.],
  [*Interface*], [A pure contract: method names, no state. `implements` it. Many allowed.],
  [*Diamond problem*], [Class D inherits from B and C which both inherit A. Which A does D get?],
  [*Composition*], [An object *has-a* part and delegates to it, instead of inheriting from it.],
  [*Coupling*], [How much one class must know about another. Lower is better.],
  [*Cohesion*], [How focused one class is on a single job. Higher is better.],
)

*Two sentences that pay for themselves*

- Overloading is *compile-time* (static) polymorphism. Overriding is *run-time* (dynamic) polymorphism.
- Inheritance is "is-a". Composition is "has-a". Prefer composition unless "is-a" is genuinely true.
]

#section[11.1 Class and object — the smallest possible start]

A class is a cookie cutter. An object is a cookie. The cutter is not edible.

#code(lang: "js", caption: "class and object in JavaScript")[```js
class Student {
  constructor(name, marks) {   // runs once, when the object is built
    this.name = name;          // state lives on the object
    this.marks = marks;
  }
  grade() {                    // behaviour lives on the class
    if (this.marks >= 80) return "A";
    if (this.marks >= 60) return "B";
    return "C";
  }
}

const a = new Student("Riya", 91);
const b = new Student("Kabir", 64);
console.log(a.name, a.grade());   // Riya A
console.log(b.name, b.grade());   // Kabir B
console.log(a.grade === b.grade); // true  -> ONE shared function, two objects
```]

Run it: `Riya A`, `Kabir B`, `true`.

That last line matters. Each object has its own `name` and `marks`. The method `grade` exists
*once*, shared. Memory holds N copies of the data and 1 copy of the code. This is true in Java,
C++ and JavaScript — the mechanism differs, the outcome is the same.

#expects[
In Java the same class is:

#code(lang: "java", caption: "Java — same class, more ceremony")[```java
class Student {
    private String name;          // private -> encapsulated
    private int marks;
    Student(String name, int marks) { this.name = name; this.marks = marks; }
    public String getName() { return name; }
    public String grade() {
        if (marks >= 80) return "A";
        if (marks >= 60) return "B";
        return "C";
    }
}
```]

Say out loud: "`name` and `marks` are private instance fields; `grade()` is a public instance
method; the constructor initialises the fields." Those five words — private, instance field,
public, instance method, constructor — are the checklist.
]

#section[11.2 Pillar 1 — Encapsulation]

*The idea.* An object hides its data and only lets you change it through methods it controls.
That way it can refuse bad changes. A bank account must never go to a negative balance because
somebody typed `acct.balance = -500`.

#code(lang: "js", caption: "Real privacy in JS: the # field")[```js
class BankAccount {
  #balance = 0;                       // '#' = truly private
  constructor(owner) { this.owner = owner; }
  deposit(amt) {
    if (amt <= 0) throw new Error("amount must be positive");
    this.#balance += amt;
    return this.#balance;
  }
  get balance() { return this.#balance; }   // read-only view
}

const a = new BankAccount("Riya");
a.deposit(500);
a.deposit(250);
console.log(a.owner, a.balance);          // Riya 750
console.log(Object.keys(a));              // [ 'owner' ]  -- #balance is invisible
console.log(JSON.stringify(a));           // {"owner":"Riya"}
try { a.deposit(-5); } catch (e) { console.log("rejected:", e.message); }
```]

Output, verified with `node`:

```
Riya 750
[ 'owner' ]
{"owner":"Riya"}
rejected: amount must be positive
```

Three things to notice.

+ `#balance` does not appear in `Object.keys` and does not appear in `JSON.stringify`. It is
  genuinely hidden, not hidden by a naming convention.
+ The only way in is `deposit`, and `deposit` checks the amount. That check is the *invariant*.
+ `get balance()` gives a read path with no write path. That is the classic "getter, no setter".

#trap[
Writing `a.#balance = 999` from outside the class is not a runtime error you can catch. It is a
*SyntaxError* — the file will not even load. Interviewers like this: JS private fields are
enforced by the language at parse time, not by convention like the old `_balance` underscore
style. The underscore convention (`this._balance`) is a *request*, not a wall. Anyone can write
`a._balance = -1`.
]

#expects[
Java has four access levels. You will be asked to list them in order.

#table(columns: (auto, auto, auto, auto, auto),
  [*Modifier*], [*Same class*], [*Same package*], [*Subclass, other package*], [*Anywhere*],
  [`private`],   [yes], [no],  [no],  [no],
  [(default)],   [yes], [yes], [no],  [no],
  [`protected`], [yes], [yes], [yes], [no],
  [`public`],    [yes], [yes], [yes], [yes],
)

C++ has three: `private`, `protected`, `public` — no package level, but it adds `friend`, which
lets a named outside class or function reach in.

The model answer: "Encapsulation means the fields are `private` and access goes through
`public` getters and setters, so the class can validate every change and keep its invariants."

JavaScript has `#private` fields and that is it. No `protected`, no `package-private`. If the
panel asks "what is `protected` in JS?" the correct answer is *"there is none; JS has only
public and `#private`, and `protected` is simulated by convention or by module scope."*
]

#section[11.3 Pillar 2 — Abstraction]

*The idea.* The caller sees *what*, never *how*. You press the brake pedal. You do not know
whether it is a disc brake or a drum brake, and your code should not break when the mechanic
swaps one for the other.

Encapsulation and abstraction sound the same and get confused in every interview. Hold this
distinction:

#table(columns: (auto, 1fr, 1fr),
  [], [*Encapsulation*], [*Abstraction*],
  [What it hides], [the *data*], [the *implementation*],
  [How],           [access modifiers, private fields], [abstract classes, interfaces, public API],
  [Question it answers], [who may touch this field?], [what does this thing promise to do?],
  [One-line], [bundling data with the methods that guard it], [exposing a contract, hiding the mechanism],
)

#code(lang: "js", caption: "Abstraction: the caller depends on a contract, not a class")[```js
const Repository = ["save", "findById", "delete"];   // the contract, as data
function implementsContract(obj, contract) {
  return contract.filter(m => typeof obj[m] !== "function");
}
class MemoryRepo {
  #rows = new Map();
  save(x) { this.#rows.set(x.id, x); return x; }
  findById(id) { return this.#rows.get(id) ?? null; }
  delete(id) { return this.#rows.delete(id); }
}
class BrokenRepo { save(x) { return x; } }

console.log(implementsContract(new MemoryRepo(), Repository));   // []  -> ok
console.log(implementsContract(new BrokenRepo(), Repository));   // missing methods

const r = new MemoryRepo();
r.save({ id: 1, name: "pen" });
console.log(r.findById(1), r.findById(2), r.delete(1), r.findById(1));
```]

Verified output:

```
[]
[ 'findById', 'delete' ]
{ id: 1, name: 'pen' } null true null
```

Swap `MemoryRepo` for a `PostgresRepo` later and the calling code never changes, because the
calling code was written against the three method names, not against the class.

#expects[
In Java you do not check the contract by hand — the compiler does it.

#code(lang: "java", caption: "Java — the contract is a language construct")[```java
interface Repository<T> {
    T save(T item);
    T findById(int id);
    boolean delete(int id);
}
class MemoryRepo implements Repository<Item> { /* compiler FORCES all three */ }
```]

Say: "Abstraction is achieved through abstract classes and interfaces. In Java an interface is
a pure contract — the compiler refuses to build a class that claims to implement it but does
not." In C++ the same thing is an abstract base class with pure virtual functions
(`virtual T f() = 0;`).

The JS honest answer: *"JavaScript has no interfaces. It uses duck typing — if the object has
the methods, it works. TypeScript adds compile-time `interface` back."*
]

#section[11.4 The JS reality — everything is a prototype]

Before inheritance, you need this. In Java, a class is a *type* known to the compiler. In
JavaScript, `class` is *syntax sugar over functions and prototype objects*, and lookups happen
at run time by walking a chain.

#code(lang: "js", caption: "A JS class is a function; methods live on .prototype")[```js
class Shape {
  constructor(name) { this.name = name; }
  area() { return 0; }
  describe() { return `${this.name} has area ${this.area()}`; }
}
class Circle extends Shape {
  constructor(r) { super("circle"); this.r = r; }
  area() { return +(Math.PI * this.r * this.r).toFixed(2); }
}

const c = new Circle(2);
console.log(typeof Shape);                                   // function
console.log(Object.getPrototypeOf(c) === Circle.prototype);  // true
console.log(Object.getPrototypeOf(Circle.prototype) === Shape.prototype); // true
console.log(c.hasOwnProperty("area"));                       // false: it is on the prototype
console.log(Circle.prototype.hasOwnProperty("area"));        // true
console.log(c.describe());                                   // dynamic dispatch
```]

Verified output:

```
function
true
true
false
true
circle has area 12.57
```

Check the maths yourself: area $= pi r^2 = 3.14159 times 4 = 12.566...$, rounded to 2 places is
`12.57`. Correct.

#diagram(height: 5.2cm, caption: "How c.describe() is found: the prototype chain is walked left to right")[
  #dnode(0cm,    0.4cm, 3.5cm, 1.3cm, [*c* (the object) \ own: `r = 2`], fill: rgb("#fdf3e7"))
  #dnode(4.4cm,  0.4cm, 3.5cm, 1.3cm, [`Circle.prototype` \ `area()`])
  #dnode(8.8cm,  0.4cm, 3.5cm, 1.3cm, [`Shape.prototype` \ `area()`, `describe()`])
  #dnode(13.2cm, 0.4cm, 3.2cm, 1.3cm, [`Object.prototype` \ `toString()`, ...])
  #darrow(3.5cm, 1.05cm, 4.4cm, 1.05cm)
  #darrow(7.9cm, 1.05cm, 8.8cm, 1.05cm)
  #darrow(12.3cm, 1.05cm, 13.2cm, 1.05cm)
  #dnode(13.2cm, 3.2cm, 3.2cm, 0.8cm, [`null` — search ends], fill: rgb("#f2f2f2"))
  #darrow(14.8cm, 1.7cm, 14.8cm, 3.2cm)
  #dnode(0cm, 3.2cm, 12.3cm, 0.8cm,
    [`describe()` is *not* on `c` and *not* on `Circle.prototype` — it is found on step 3, and it then calls `this.area()`, which restarts the walk and finds `Circle`'s version on step 2.],
    fill: rgb("#f7f7f5"))
]

That restart is the whole trick. `describe()` is written in `Shape`, but the `this.area()` inside
it resolves against the *actual* object, so it finds `Circle.area`. That is dynamic dispatch, and
it is what "polymorphism" means in practice.

#trap[
`hasOwnProperty("area")` on the instance returns *false*. Students expect `true` because
`c.area()` works. The property is reachable through the chain but it is not *owned*. This
distinction shows up in real bugs: `for...in` walks the chain, `Object.keys` does not.
]

#section[11.5 Pillar 3 — Inheritance]

*The idea.* `class B extends A` means "every B is also an A". B gets A's methods for free and may
add or replace some.

#code(lang: "js", caption: "extends and super")[```js
class Payment {
  constructor(amt) { this.amt = amt; }
  fee() { return 0; }
  total() { return this.amt + this.fee(); }
}
class Card extends Payment {
  constructor(amt) { super(amt); }          // super() MUST run before using 'this'
  fee() { return +(this.amt * 0.02).toFixed(2); }
}
const p = new Card(1000);
console.log(p.fee(), p.total());            // 20 1020
console.log(p instanceof Card, p instanceof Payment);  // true true
```]

`p instanceof Payment` is `true`. That is the "is-a" test, and it is the one-line proof of
inheritance.

#subsection[Types of inheritance — the list they want]

#table(columns: (auto, 1fr, auto),
  [*Type*], [*Shape*], [*Allowed?*],
  [Single],       [B extends A], [Java yes · C++ yes · JS yes],
  [Multilevel],   [C extends B extends A], [Java yes · C++ yes · JS yes],
  [Hierarchical], [B and C both extend A], [Java yes · C++ yes · JS yes],
  [Multiple],     [D extends B *and* C (classes)], [Java *NO* · C++ yes · JS *NO*],
  [Hybrid],       [any mix of the above], [only where multiple is allowed],
)

#expects[
"Java does not support multiple inheritance *of classes* — to avoid the diamond problem — but it
does support multiple inheritance *of type* through interfaces: a class may implement any number
of interfaces. C++ supports multiple inheritance of classes and solves the diamond with `virtual`
inheritance."

Memorise the shape of that sentence. It answers three questions at once.

In Java the child constructor implicitly calls `super()` first; in C++ base constructors run
before the derived constructor body; in JS you must write `super(...)` explicitly before touching
`this`, or you get a `ReferenceError`.
]

#subsection[Constructor order — a favourite trap]

#code(lang: "java", caption: "Java — what prints, and in what order?")[```java
class Base {
    Base() { System.out.println("Base ctor"); init(); }
    void init() { System.out.println("Base.init"); }
}
class Derived extends Base {
    int n = 42;
    Derived() { super(); System.out.println("Derived ctor, n=" + n); }
    @Override void init() { System.out.println("Derived.init, n=" + n); }
}
public class Order { public static void main(String[] a){ new Derived(); } }
```]

Compiled and run with `javac` / `java`. Actual output:

```
Base ctor
Derived.init, n=0
Derived ctor, n=42
```

Walk it step by step.

+ `new Derived()` starts. `super()` runs first, so `Base()` begins.
+ `Base()` prints `Base ctor`, then calls `init()`.
+ `init()` is *virtual* — Java methods are virtual by default — so `Derived.init` runs, not
  `Base.init`.
+ But `Derived`'s field initialisers have not run yet. `n` is still the default `0`.
+ `Base()` returns. *Now* `n = 42` runs. Then the `Derived` body prints `n=42`.

#trap[
*Never call an overridable method from a constructor.* The subclass override runs against a
half-built object. This is a real, common production bug and a classic senior-level question.
The fix: make the method `final` (Java) / non-virtual (C++), or call it after construction.
]

#section[11.6 Pillar 4 — Polymorphism]

*The idea.* Write the loop once; let each object decide what to do.

#code(lang: "js", caption: "One loop, four types, no if/else on type")[```js
class Payment { constructor(amt){ this.amt = amt; } fee(){ return 0; } }
class Card   extends Payment { fee(){ return +(this.amt * 0.02).toFixed(2); } }
class UPI    extends Payment { fee(){ return 0; } }
class Cheque extends Payment { fee(){ return 15; } }

const batch = [new Card(1000), new UPI(1000), new Cheque(1000), new Card(2500)];
let total = 0;
for (const p of batch) total += p.fee();      // no switch on type
console.log(batch.map(p => `${p.constructor.name}:${p.fee()}`).join("  "));
console.log("total fee =", +total.toFixed(2));
```]

Verified output:

```
Card:20  UPI:0  Cheque:15  Card:50
total fee = 85
```

Check the arithmetic: $1000 times 0.02 = 20$, $0$, flat $15$, $2500 times 0.02 = 50$.
$20 + 0 + 15 + 50 = 85$. Correct.

Now add `NetBanking`. The loop does not change. *That* is the payoff, and it is what you should
say when asked "why is polymorphism useful?" — not "one interface, many forms", which says
nothing.

#subsection[The two kinds — say both names]

#table(columns: (auto, 1fr, 1fr),
  [], [*Compile-time (static)*], [*Run-time (dynamic)*],
  [Also called], [early binding, static binding], [late binding, dynamic binding],
  [Mechanism],   [method *overloading*, operator overloading], [method *overriding*, virtual functions],
  [Decided by],  [the *declared* types of the arguments], [the *actual* type of the object],
  [Decided when],[compilation], [execution],
  [Cost],        [free], [one indirect jump through the vtable],
  [In Java],     [overloading], [every non-`static`, non-`final`, non-`private` method],
  [In C++],      [overloading, templates], [only methods marked `virtual`],
  [In JS],       [*does not exist*], [every method — the prototype chain is always walked],
)

#section[11.7 Overloading vs overriding — the question you will definitely be asked]

#subsection[Overloading: same name, different parameter list]

#code(lang: "java", caption: "Java — three methods, one name")[```java
class Calc {
    int add(int a, int b)          { return a + b; }
    int add(int a, int b, int c)   { return a + b + c; }
    double add(double a, double b) { return a + b; }
}
public class Overload {
    public static void main(String[] args) {
        Calc k = new Calc();
        System.out.println(k.add(1, 2));       // 3
        System.out.println(k.add(1, 2, 3));    // 6
        System.out.println(k.add(1.5, 2.5));   // 4.0
    }
}
```]

Compiled and run. Output: `3`, `6`, `4.0`. Three different methods exist in the class file. The
compiler picks one by looking at the argument types at the call site.

*Rules that make an overload legal (Java):* the parameter list must differ in *number*, *type*, or
*order* of parameters. Changing only the return type is *not* an overload — it is a compile error.

#subsection[Now the JS truth: there is no overloading]

#code(lang: "js", caption: "JS — the second definition silently wins")[```js
class Calc {
  add(a, b)      { return a + b; }
  add(a, b, c)   { return a + b + c; }   // silently replaces the one above
}
const k = new Calc();
console.log(k.add(1, 2));        // NaN  -> c is undefined
console.log(k.add(1, 2, 3));     // 6

// The honest JS way: one method, inspect the arguments.
class Calc2 {
  add(...nums) { return nums.reduce((s, n) => s + n, 0); }
}
console.log(new Calc2().add(1, 2));       // 3
console.log(new Calc2().add(1, 2, 3, 4)); // 10
```]

Verified output: `NaN`, `6`, `3`, `10`.

Why `NaN`? `k.add(1, 2)` calls the *surviving* three-parameter version. `c` is `undefined`, and
`1 + 2 + undefined` is `NaN`. No warning, no error. This bites people.

#trap[
"JavaScript supports method overloading using default parameters" — *wrong answer, say no*. A
default parameter changes what one function does when an argument is missing. Overloading means
*several distinct functions* chosen by signature. JS objects hold one property per key, so the
second `add` overwrites the first. The right phrasing: *"JavaScript does not support overloading;
it simulates it with rest parameters or by branching on `arguments.length` and `typeof`."*
]

#subsection[Overriding: same name, same signature, child class]

#table(columns: (auto, 1fr, 1fr),
  [], [*Overloading*], [*Overriding*],
  [Where], [same class (or inherited into one)], [child class only],
  [Signature], [must *differ*], [must be *identical*],
  [Return type], [may differ freely], [same, or a subtype (covariant)],
  [Access], [any], [may not be *more* restrictive than the parent's],
  [`static` methods], [can be overloaded], [*cannot* be overridden — they are *hidden*],
  [Binding], [compile time], [run time],
  [Marker], [none], [`@Override` (Java), `override` (C++11)],
)

#trap[
*Static methods are not overridden, they are hidden.* In Java, if `Base` and `Derived` both
declare `static void f()`, then `Base b = new Derived(); b.f();` calls *`Base.f`* — because
`static` dispatch uses the *declared* type. Saying "static methods can be overridden" is an
instant loss of a point. Same for `private` and `final` methods: `private` is invisible to the
child, and `final` forbids the override outright.
]

#section[11.8 Virtual functions and the vtable]

This is the C++ question. Java makes every method virtual by default, so nobody asks it there;
C++ makes you opt in, so everybody asks it there.

#code(lang: "cpp", caption: "C++ — the one experiment that explains everything")[```cpp
#include <iostream>
struct Shape {
    void draw()          { std::cout << "Shape::draw\n"; }   // NOT virtual
    virtual void print() { std::cout << "Shape::print\n"; }  // virtual
    virtual ~Shape() {}
};
struct Circle : Shape {
    void draw()           { std::cout << "Circle::draw\n"; }
    void print() override { std::cout << "Circle::print\n"; }
};
int main() {
    Shape* p = new Circle();
    p->draw();    // static binding  -> base version
    p->print();   // dynamic binding -> derived version
    delete p;
}
```]

Compiled with `g++ -std=c++17` and run. Actual output:

```
Shape::draw
Circle::print
```

*The object is a `Circle` in both lines.* The only difference is the word `virtual`. Without it,
the compiler decides from the *pointer type* (`Shape*`) and hard-codes a call to `Shape::draw`.
With it, the compiler emits a lookup through a per-class table of function pointers — the
*vtable* — and the answer depends on what the object actually is.

#diagram(height: 4.6cm, caption: "Dynamic dispatch: p->print() is two pointer hops, not a direct call")[
  #dnode(0cm, 1.1cm, 2.8cm, 1.0cm, [`Shape* p` \ (a pointer)], fill: rgb("#fdf3e7"))
  #dnode(3.9cm, 0.9cm, 3.4cm, 1.4cm, [*Circle object* (heap) \ `vptr` \ `double s`])
  #dnode(8.4cm, 0.1cm, 3.4cm, 0.7cm, [*Circle vtable*], fill: rgb("#e7eef5"))
  #dnode(8.4cm, 0.9cm, 3.4cm, 0.7cm, [slot 0 → print])
  #dnode(8.4cm, 1.7cm, 3.4cm, 0.7cm, [slot 1 → dtor])
  #dnode(12.9cm, 0.9cm, 3.4cm, 0.7cm, [code of `Circle::print`], fill: rgb("#eef5ea"))
  #darrow(2.8cm, 1.6cm, 3.9cm, 1.6cm, label: "hop 1")
  #darrow(7.3cm, 1.25cm, 8.4cm, 0.45cm, label: "hop 2")
  #darrow(11.8cm, 1.25cm, 12.9cm, 1.25cm)
  #dnode(0cm, 3.1cm, 16.3cm, 1.1cm,
    [Cost: one extra memory read per virtual call, and the target is not known at compile time, so it cannot be inlined. That is the whole price of polymorphism in C++ — and the reason `virtual` is opt-in there.],
    fill: rgb("#f7f7f5"))
]

#subsection[Proof that the vptr is real]

#code(lang: "cpp", caption: "sizeof tells you the hidden pointer exists")[```cpp
#include <iostream>
struct Plain   { int x; };
struct Virtual { int x; virtual void f(); virtual ~Virtual() = default; };
void Virtual::f() {}
struct Abstract { virtual double area() = 0; virtual ~Abstract() = default; };  // pure virtual
struct Sq : Abstract { double s; Sq(double s):s(s){} double area() override { return s*s; } };
int main() {
    std::cout << "sizeof(Plain)   = " << sizeof(Plain)   << "\n";
    std::cout << "sizeof(Virtual) = " << sizeof(Virtual) << "  (int + vptr)\n";
    Abstract* p = new Sq(3);
    std::cout << "area = " << p->area() << "\n";
    delete p;
}
```]

Verified output on a 64-bit Linux build:

```
sizeof(Plain)   = 4
sizeof(Virtual) = 16  (int + vptr)
area = 9
```

Read the numbers. `Plain` is one `int` = 4 bytes. `Virtual` is one `int` *plus one hidden 8-byte
pointer*, which the compiler then pads to a multiple of 8, giving 16. The `vptr` is not
imaginary; you can measure it.

#trap[
*Always make the destructor of a polymorphic base class `virtual`.* If `Shape::~Shape` is not
virtual and you write `delete p;` where `p` is a `Shape*` pointing at a `Circle`, only
`~Shape` runs. `Circle`'s members are never destroyed — a leak, and formally undefined behaviour.
One-line answer: *"a base class with any virtual function needs a virtual destructor."*
]

#expects[
Say these four sentences and the C++ virtual-function question is closed.

+ "A virtual function is resolved at run time using the object's actual type, not the pointer's
  static type."
+ "The compiler gives each polymorphic class a vtable of function pointers and gives each object
  a hidden `vptr` to it."
+ "A *pure virtual* function is declared `virtual T f() = 0;`. A class with one is *abstract* and
  cannot be instantiated."
+ "The base destructor must be virtual, or deleting through a base pointer is undefined
  behaviour."

And for Java: *"In Java every non-static, non-final, non-private method is virtual by default,
so there is no `virtual` keyword. `final` is how you opt out."*

JS honest answer: *"JavaScript has no vtable — every method call is a prototype-chain lookup, so
every method behaves as if it were virtual."*
]

#section[11.9 Abstract class vs interface — the highest-frequency question]

*The idea.* Both say "you must supply this method". They differ in what else they may carry and
how many you may have.

#table(columns: (auto, 1fr, 1fr),
  [], [*Abstract class*], [*Interface*],
  [Purpose], [share partial implementation among related classes], [declare a capability any class may have],
  [Relationship], ["is-a"], ["can-do"],
  [Instance fields / state], [*yes*], [*no* (only `public static final` constants in Java)],
  [Constructor], [*yes* (runs via `super()`)], [*no*],
  [Concrete methods], [yes], [Java 8+: `default` and `static` methods only],
  [How many per class], [*one*], [*many*],
  [Keyword], [`extends`], [`implements`],
  [Access of members], [any], [implicitly `public`],
  [C++ equivalent], [base with some pure virtuals], [base with *all* pure virtuals, no data],
)

#code(lang: "java", caption: "Java — both, in one file, compiled and run")[```java
abstract class Shape {
    protected String name;
    Shape(String name) { this.name = name; }     // abstract class CAN have a constructor
    abstract double area();                      // no body -> subclass must supply one
    public String describe() { return name + " area=" + area(); }  // concrete method
}
interface Drawable { void draw(); }                            // pure contract
interface Serial   { default String tag() { return "obj"; } }  // Java 8 default method

class Square extends Shape implements Drawable, Serial {
    private final double s;
    Square(double s) { super("square"); this.s = s; }
    @Override double area() { return s * s; }
    @Override public void draw() { System.out.println("[]"); }
}
public class Shapes {
    public static void main(String[] a) {
        Shape sh = new Square(3);      // upcast: reference is Shape, object is Square
        System.out.println(sh.describe());
        ((Drawable) sh).draw();
        System.out.println(((Serial) sh).tag());
        // Shape x = new Shape("x");   // ERROR: Shape is abstract
    }
}
```]

Compiled with `javac`, run with `java`. Output:

```
square area=9.0
[]
obj
```

Four facts this proves:

+ An abstract class *can* have a constructor, fields, and fully written methods
  (`describe()` here). It just cannot be instantiated.
+ `describe()` calls `area()`, which the abstract class never defines. At run time
  `Square.area()` runs. That is polymorphism reaching *down* from the abstract layer.
+ One `extends`, two `implements`, in the same declaration. That is Java's multiple inheritance
  of type.
+ A `default` method in an interface gives a body without state.

#subsection[When to choose which — the follow-up]

- Shared *state* or shared *code*? Abstract class.
- A capability that unrelated classes can each have (`Comparable`, `Serializable`, `Closeable`)?
  Interface.
- Need it in more than one family at once? Interface — you get only one parent class.
- Adding a method later to an already-shipped type? Interface with a `default` body, or the
  existing implementors all break.

#subsection[And in JavaScript?]

JS has neither keyword. You emulate an abstract class with `new.target`.

#code(lang: "js", caption: "Emulating an abstract class in JS")[```js
class Shape {
  constructor() {
    if (new.target === Shape) throw new Error("Shape is abstract");
  }
  area() { throw new Error(`${this.constructor.name} must implement area()`); }
}
class Tri  extends Shape { constructor(b,h){ super(); this.b=b; this.h=h; } area(){ return this.b*this.h/2; } }
class Blob extends Shape {}

try { new Shape(); } catch (e) { console.log("1:", e.message); }
console.log("2:", new Tri(6, 4).area());
try { new Blob().area(); } catch (e) { console.log("3:", e.message); }
```]

Verified output:

```
1: Shape is abstract
2: 12
3: Blob must implement area()
```

Check: triangle area $= (b times h)/2 = (6 times 4)/2 = 12$. Correct.

`new.target` is the constructor that `new` was actually called with. When you write
`new Tri(...)`, inside `Shape`'s constructor `new.target` is `Tri`, not `Shape`, so the guard
passes.

#trap[
The JS version fails *at run time*, and only when that exact line executes. Java fails *at
compile time* — the build does not produce a class file at all. When asked "is JS object
oriented?", the sharp answer is: *"Yes, it is object oriented, but it is dynamically typed and
prototype-based, so contract violations surface at run time instead of compile time. TypeScript
adds the compile-time check back."*
]

#section[11.10 The diamond problem]

*The setup.* `Device` has a field `id`. `Printer` and `Scanner` each inherit from `Device`.
`Copier` inherits from both. How many `Device` parts does a `Copier` contain — one or two?

#diagram(height: 5.6cm, caption: "The diamond: two inheritance paths from Copier reach Device")[
  #dnode(6.3cm, 0.1cm, 3.4cm, 0.9cm, [`Device` \ `int id`], fill: rgb("#fdf3e7"))
  #dnode(1.9cm, 1.9cm, 3.4cm, 0.9cm, [`Printer`])
  #dnode(10.7cm, 1.9cm, 3.4cm, 0.9cm, [`Scanner`])
  #dnode(6.3cm, 3.7cm, 3.4cm, 0.9cm, [`Copier`], fill: rgb("#eef5ea"))
  #darrow(3.6cm, 1.9cm, 6.6cm, 1.0cm)
  #darrow(12.4cm, 1.9cm, 9.4cm, 1.0cm)
  #darrow(7.2cm, 3.7cm, 4.2cm, 2.8cm)
  #darrow(8.8cm, 3.7cm, 11.8cm, 2.8cm)
  #dnode(0cm, 4.8cm, 16.3cm, 0.7cm,
    [Question: does `Copier` hold one `Device` or two? C++ says *two* by default. Java forbids the shape entirely.],
    fill: rgb("#f7f7f5"))
]

#subsection[C++ — it really does make two copies]

#code(lang: "cpp", caption: "Plain multiple inheritance: two Device sub-objects")[```cpp
#include <iostream>
struct Device { int id = 7; Device() { std::cout << "Device ctor\n"; } };
struct Printer : Device {};
struct Scanner : Device {};
struct Copier  : Printer, Scanner {};
int main() {
    Copier c;
    std::cout << sizeof(Copier) << " bytes\n";
    // std::cout << c.id;   // ERROR: request for member 'id' is ambiguous
    std::cout << c.Printer::id << " " << c.Scanner::id << "\n";
}
```]

Compiled and run. Actual output:

```
Device ctor
Device ctor
8 bytes
7 7
```

Read it carefully. `Device ctor` prints *twice*. `sizeof(Copier)` is *8* — two `int`s, not one.
And plain `c.id` does not compile at all; the compiler says the request is ambiguous. You must
disambiguate with `c.Printer::id`.

#subsection[The C++ fix: virtual inheritance]

#code(lang: "cpp", caption: "One shared Device")[```cpp
#include <iostream>
struct Device { int id = 7; Device() { std::cout << "Device ctor\n"; } };
struct Printer : virtual Device {};
struct Scanner : virtual Device {};
struct Copier  : Printer, Scanner {};
int main() {
    Copier c;
    std::cout << c.id << "\n";     // now unambiguous: ONE Device
}
```]

Verified output:

```
Device ctor
7
```

One constructor call. One `id`. `c.id` compiles.

#diagram(height: 4.4cm, caption: "Copier memory layout: plain multiple inheritance vs virtual inheritance")[
  #dnode(0cm, 0.1cm, 7.6cm, 0.7cm, [*Plain* `: Printer, Scanner` — 8 bytes], fill: rgb("#fdf3e7"))
  #dnode(0cm, 1.0cm, 3.7cm, 0.9cm, [Printer part \ `Device::id = 7`])
  #dnode(3.9cm, 1.0cm, 3.7cm, 0.9cm, [Scanner part \ `Device::id = 7`])
  #dnode(0cm, 2.2cm, 7.6cm, 0.7cm, [`c.id` → *ambiguous*, will not compile], fill: rgb("#fdf4f4"))

  #dnode(8.7cm, 0.1cm, 7.6cm, 0.7cm, [*Virtual* `: virtual Device` — one shared base], fill: rgb("#eef5ea"))
  #dnode(8.7cm, 1.0cm, 3.7cm, 0.9cm, [Printer part \ (pointer to base)])
  #dnode(12.6cm, 1.0cm, 3.7cm, 0.9cm, [Scanner part \ (pointer to base)])
  #dnode(8.7cm, 2.2cm, 7.6cm, 0.9cm, [one shared `Device { id = 7 }`], fill: rgb("#e7eef5"))
  #darrow(10.5cm, 1.9cm, 11.5cm, 2.2cm)
  #darrow(14.4cm, 1.9cm, 13.4cm, 2.2cm)
  #dnode(0cm, 3.4cm, 16.3cm, 0.7cm,
    [Cost of the virtual version: an extra indirection to reach the shared base, and the *most derived* class must construct it.],
    fill: rgb("#f7f7f5"))
]

#subsection[Java — the shape is banned, but a smaller diamond survives]

Java forbids `class C extends A, B`. So the state diamond cannot happen. But Java 8 added
`default` methods to interfaces, and two interfaces *can* supply the same default.

#code(lang: "java", caption: "Java's interface diamond and its fix")[```java
interface A { default String who() { return "A"; } }
interface B { default String who() { return "B"; } }
class C implements A, B {
    // Without this override javac refuses to compile.
    @Override public String who() { return A.super.who() + B.super.who(); }
}
public class Dia { public static void main(String[] x){ System.out.println(new C().who()); } }
```]

With the override, output is `AB`. Remove the override and `javac` prints, word for word:

```
error: types A and B are incompatible;
  class C inherits unrelated defaults for who() from types A and B
```

So Java's rule is: *the compiler will not guess — you must override and pick, using
`A.super.who()` to name the one you want.*

#trap[
"Java avoids the diamond problem by not allowing multiple inheritance" is only *half* the answer
and the panel is waiting for the other half. Full answer: *"Java forbids multiple inheritance of
classes, so there is no state diamond. Since Java 8, two interfaces can both supply a `default`
method, which creates a behaviour diamond — the compiler then forces the class to override and
disambiguate with `A.super.method()`."*
]

#subsection[JavaScript — mixins, the flat answer]

JS also allows only one `extends`. The idiom is a *mixin*: a function that takes a class and
returns a subclass.

#code(lang: "js", caption: "Mixins: multiple capabilities, one straight chain")[```js
const CanPrint = (Base) => class extends Base {
  print() { return `printing ${this.id}`; }
};
const CanScan = (Base) => class extends Base {
  scan() { return `scanning ${this.id}`; }
};

class Device { constructor(id) { this.id = id; } }
class Copier extends CanScan(CanPrint(Device)) {}

const c = new Copier("C-100");
console.log(c.print());
console.log(c.scan());
console.log(c instanceof Device);   // true
```]

Verified output:

```
printing C-100
scanning C-100
true
```

There is no diamond because there is no branching. The chain is a straight line:

```
Copier  ->  CanScan(...)  ->  CanPrint(...)  ->  Device
```

Whoever is applied *last* is *closest* to the object, so if two mixins defined the same method,
the outer one wins. That is a deterministic rule, which is exactly what C++ and Java lack.

#section[11.11 static, final and the modifiers]

#code(lang: "js", caption: "static belongs to the class, not to any object")[```js
class Counter {
  static made = 0;                 // one copy, on the class
  constructor() { Counter.made++; this.id = Counter.made; }
  static reset() { Counter.made = 0; }
  who() { return `instance ${this.id}`; }
}
new Counter(); new Counter(); const t = new Counter();
console.log(Counter.made, t.who());   // 3 instance 3
console.log(typeof t.reset);          // undefined - static is NOT on instances
Counter.reset();
console.log(Counter.made);            // 0
```]

Verified output: `3 instance 3`, `undefined`, `0`.

`t.reset` is `undefined`. Static members live on the class object, not on instances, and they are
*not* reachable through the instance in JavaScript (unlike Java, where `t.reset()` compiles with
a warning).

#table(columns: (auto, 1fr, 1fr),
  [*Keyword*], [*On a method*], [*On a field / class*],
  [`static` (Java/C++)], [no `this`; called on the class], [one shared copy for all objects],
  [`final` (Java)], [cannot be overridden], [field: assign once. Class: cannot be extended.],
  [`const` (C++)], [method promises not to modify the object], [value cannot change],
  [`abstract` (Java)], [no body; subclass must supply one], [class cannot be instantiated],
  [`virtual` (C++)], [dispatch through the vtable], [—],
)

#trap[
`final` on a *reference* field freezes the *reference*, not the object. In Java,
`final List<String> xs = new ArrayList<>(); xs.add("a");` is perfectly legal — you cannot
reassign `xs`, but you can mutate what it points at. Same story for `const` in JavaScript:
`const a = [1]; a.push(2);` works. `const` binds the name, not the value.
]

#section[11.12 Association, aggregation, composition]

Three words for "class A uses class B", ordered by how tightly.

#table(columns: (auto, 1fr, 1fr, 1fr),
  [], [*Association*], [*Aggregation*], [*Composition*],
  [Meaning], [uses-a], [has-a, *weak*], [has-a, *strong* / owns],
  [Lifetime], [independent], [part outlives the whole], [part dies with the whole],
  [Example], [Teacher — Student], [Department — Professor], [House — Room],
  [UML line], [plain line], [hollow diamond], [filled diamond],
  [Test question], [do they just talk?], [can the part be reused elsewhere?], [is the part meaningless alone?],
)

#code(lang: "js", caption: "Composition: the Copier owns its parts and can swap them")[```js
class PrintUnit { print(doc) { return `printed ${doc}`; } }
class ScanUnit  { scan(doc)  { return `scanned ${doc}`; } }

class Copier {
  constructor() { this.printer = new PrintUnit(); this.scanner = new ScanUnit(); }
  print(d) { return this.printer.print(d); }   // delegate
  scan(d)  { return this.scanner.scan(d); }
  copy(d)  { this.scanner.scan(d); return this.printer.print(d); }
}
const c = new Copier();
console.log(c.copy("page1"));
console.log(c.scan("page2"));
c.printer = { print: (d) => `faxed ${d}` };    // swap a part at RUN TIME
console.log(c.copy("page3"));
```]

Verified output:

```
printed page1
scanned page2
faxed page3
```

That last line is the argument for composition. You replaced a component while the program was
running. With inheritance, the parent is fixed at compile time for ever.

#section[11.13 SOLID — five principles, one worked example each]

You will be asked to expand the acronym and give one example. Keep each answer to two lines.

#subsection[S — Single Responsibility]

*A class should have one reason to change.* If `Invoice` both computes totals and writes PDFs,
a tax-rule change and a layout change both edit the same file. Split into `Invoice` (numbers) and
`InvoiceRenderer` (output).

#subsection[O — Open / Closed]

*Open for extension, closed for modification.* Adding a case should not mean editing a `switch`.

#code(lang: "js", caption: "Add a shipping rule without touching cost()")[```js
const rules = new Map();
const register = (kind, fn) => rules.set(kind, fn);

register("standard", w => 40 + 8 * w);
register("express",  w => 90 + 14 * w);

function cost(kind, weightKg) {
  const fn = rules.get(kind);
  if (!fn) throw new Error("unknown kind: " + kind);
  return fn(weightKg);
}
console.log(cost("standard", 3), cost("express", 3));

register("sameday", w => 200 + 20 * w);     // extension, no edit to cost()
console.log(cost("sameday", 3));
```]

Verified output: `64 132` then `260`.

Check each: standard $= 40 + 8 times 3 = 64$. Express $= 90 + 14 times 3 = 132$.
Same-day $= 200 + 20 times 3 = 260$. All correct.

#subsection[L — Liskov Substitution]

*Anywhere the parent works, the child must work too.* The famous counter-example is real, and it
compiles.

#code(lang: "js", caption: "Square extends Rectangle breaks the caller")[```js
class Rectangle {
  constructor(w, h) { this.w = w; this.h = h; }
  setWidth(w) { this.w = w; }
  setHeight(h) { this.h = h; }
  area() { return this.w * this.h; }
}
class Square extends Rectangle {          // "a square IS-A rectangle" -- in maths, yes
  setWidth(w)  { this.w = w; this.h = w; }
  setHeight(h) { this.w = h; this.h = h; }
}
function stretch(r) { r.setWidth(5); r.setHeight(4); return r.area(); }
console.log(stretch(new Rectangle(1, 1)));  // 20  - expected
console.log(stretch(new Square(1)));        // 16  - caller's contract broken

// Fix: stop inheriting. Model the shared CAPABILITY instead.
class Shape2 { area() { throw new Error("not implemented"); } }
class Rect2 extends Shape2 { constructor(w,h){super();this.w=w;this.h=h;} area(){return this.w*this.h;} }
class Sq2   extends Shape2 { constructor(s){super();this.s=s;}          area(){return this.s*this.s;} }
console.log([new Rect2(5,4), new Sq2(4)].map(s => s.area()));
```]

Verified output: `20`, `16`, `[ 20, 16 ]`.

Trace the failure. `stretch` sets width 5 then height 4, and expects $5 times 4 = 20$. On a
`Square`, `setHeight(4)` also resets the width to 4, so the answer is $4 times 4 = 16$. The child
is not substitutable. *"Is-a" in mathematics is not "is-a" in code* — the deciding question is
whether the child honours every promise the parent's callers rely on.

#subsection[I — Interface Segregation]

*No client should be forced to depend on methods it does not use.* One fat `Machine` interface
with `print`, `scan`, `fax` forces a plain printer to implement `fax()` with a thrown error.
Split into `Printer`, `Scanner`, `Fax` and let a class implement the ones it truly has.

#subsection[D — Dependency Inversion]

*Depend on abstractions, not concrete classes.* `OrderService` should take a `Repository` (the
contract) in its constructor, not construct a `MySQLRepository` inside itself. Then tests pass a
fake one. That is exactly the `MemoryRepo` example from section 11.3.

#trick[
Say SOLID in *five short sentences*, one per letter, then offer one example for the letter they
ask about. Reciting long definitions for all five wastes the interviewer's time and they will cut
you off. Short first, detail on demand.
]

#section[11.14 Shallow vs deep copy]

#code(lang: "js", caption: "The spread operator copies one level only")[```js
const orig = { name: "cart", items: [{ sku: "A", qty: 1 }] };
const shallow = { ...orig };
shallow.items[0].qty = 99;
console.log("orig after shallow edit:", orig.items[0].qty);   // 99 - shared!

const deep = structuredClone(orig);
deep.items[0].qty = 5;
console.log("orig after deep edit:", orig.items[0].qty);      // 99 - untouched
```]

Verified output:

```
orig after shallow edit: 99
orig after deep edit: 99
```

The first `99` is the bug: `{...orig}` copied the *reference* to `items`, so both objects point at
the same array. The second `99` is the proof that `structuredClone` worked — after the deep copy
was edited to `5`, the original still reads `99`.

#table(columns: (auto, 1fr, 1fr),
  [], [*Shallow copy*], [*Deep copy*],
  [Copies], [top-level fields only], [the whole object graph],
  [Nested objects], [*shared*], [duplicated],
  [JS], [`{...o}`, `Object.assign`, `arr.slice()`], [`structuredClone(o)`],
  [Java], [default `Object.clone()`], [hand-written, or serialise-and-read-back],
  [C++], [default copy constructor (copies the pointer)], [user-defined copy ctor that copies the target],
  [Cost], [$O(1)$ in depth], [$O(n)$ in the size of the graph],
)

#trap[
In C++ this is the *rule of three*: if a class manages a raw resource and you do not write your
own copy constructor, copy assignment and destructor, the default shallow copy gives two objects
holding the same pointer — and the second destructor calls `delete` on already-freed memory. A
double free. Modern C++ answer: use `std::unique_ptr` / `std::vector` and the rule of *zero*.
]

#section[11.15 The `this` problem — a JS-only interview topic]

#code(lang: "js", caption: "'this' is decided by the CALL, not by the class")[```js
class Timer {
  constructor() { this.ticks = 0; }
  tick() { this.ticks++; return this.ticks; }
}
const t = new Timer();
const loose = t.tick;                 // method pulled off the object
try { loose(); } catch (e) { console.log("broken:", e.constructor.name); }

const bound = t.tick.bind(t);         // fix 1: bind
console.log(bound(), bound());

class Timer2 {                        // fix 2: arrow field captures 'this' at construction
  ticks = 0;
  tick = () => { this.ticks++; return this.ticks; };
}
const g = new Timer2().tick;
console.log(g(), g());
```]

Verified output:

```
broken: TypeError
1 2
1 2
```

In Java and C++, `this` is part of the call — you cannot detach a method from its object. In JS
you can, and then `this` is `undefined` (class bodies are strict mode), so `this.ticks++` throws
a `TypeError`. This is why `onClick={this.handleClick}` in old React needed `.bind(this)` in the
constructor.

#pagebreak(weak: true)
#section[11.16 Worked examples — Warm-up]

#tier-header(0)

#ex(1, tier: 0)[
Name the four pillars of OOP and give each one a three-word description.
]
#sol[
*Encapsulation* — hide the data. \
*Abstraction* — hide the implementation. \
*Inheritance* — reuse the parent. \
*Polymorphism* — one name, many behaviours.
#ans[Encapsulation, Abstraction, Inheritance, Polymorphism.]
]

#ex(2, tier: 0)[
What is printed?

```js
class A { hi() { return "A"; } }
class B extends A { hi() { return "B"; } }
console.log(new B().hi());
```
]
#sol[
`B` overrides `hi`. Lookup starts on the object, then `B.prototype` — found there, so the walk
stops before reaching `A.prototype`.
#ans[`B`]
]

#ex(3, tier: 0)[
True or false: a class with a private constructor can still be instantiated from inside itself.
]
#sol[
True. `private` restricts access from *outside* the class. A `static` factory method inside the
class can call the private constructor. That is exactly how the singleton pattern works.
#ans[True.]
]

#ex(4, tier: 0)[
In one line: what is the difference between `extends` and `implements` in Java?
]
#sol[
`extends` takes the parent's code and state — one parent only. `implements` takes only the
method signatures — any number.
#ans[`extends` = inherit implementation (one); `implements` = accept a contract (many).]
]

#ex(5, tier: 0)[
What does this print, and why?

```js
class Box { static count = 0; }
const b = new Box();
console.log(Box.count, b.count);
```
]
#sol[
`count` lives on the class object `Box`, not on `b`. Reading `b.count` walks `b`, then
`Box.prototype`, then `Object.prototype` — `count` is on none of them.
#ans[`0 undefined`]
]

#section[11.17 Worked examples — Tier 1]

#tier-header(1)

#ex(6, tier: 1, asked: "TCS NQT · pattern")[
Explain the difference between method overloading and method overriding with one example each.
State when each is resolved.
]
#sol[
*Overloading* — same name, *different* parameter list, *same* class, resolved at *compile time*.

```java
int  add(int a, int b)          { return a + b; }
int  add(int a, int b, int c)   { return a + b + c; }
```

*Overriding* — same name, *same* signature, *child* class, resolved at *run time*.

```java
class Shape { double area() { return 0; } }
class Circle extends Shape { @Override double area() { return 3.14 * r * r; } }
```

Overloading is static (compile-time) polymorphism. Overriding is dynamic (run-time)
polymorphism.

#ans[Overloading: different signature, same class, compile time. Overriding: same signature, child class, run time.]
]

#ex(7, tier: 1, asked: "Infosys · pattern")[
Can you override a `static` method in Java? What actually happens if you declare a method with
the same signature `static` in both parent and child?
]
#sol[
No. That is *method hiding*, not overriding.

```java
class P { static String f() { return "P"; } }
class C extends P { static String f() { return "C"; } }
P ref = new C();
System.out.println(ref.f());   // prints P
```

Static dispatch uses the *declared* type of the reference (`P`), not the object's actual type.
`@Override` on such a method is a compile error, which is the compiler telling you the same
thing.

#ans[No — it is hidden, not overridden. The declared type decides which one runs.]
]

#ex(8, tier: 1, asked: "Wipro · pattern")[
List four differences between an abstract class and an interface, and say when you would choose
each.
]
#sol[
+ *Count*: one abstract parent, many interfaces.
+ *State*: an abstract class may hold instance fields; an interface may not.
+ *Constructor*: an abstract class has one; an interface does not.
+ *Relationship*: abstract class means "is-a"; interface means "can-do".

Choose an *abstract class* when subclasses share code or state — e.g. `Employee` holding `name`
and `id` with an abstract `calculateSalary()`.

Choose an *interface* when unrelated classes share a capability — e.g. `Comparable`, which a
`Student`, an `Invoice` and a `Date` may all implement without being related.

#ans[Count, state, constructor, relationship. Abstract class for shared code; interface for shared capability.]
]

#ex(9, tier: 1, asked: "Capgemini · pattern")[
What is the diamond problem? Which languages have it and how does each deal with it?
]
#sol[
*Diamond*: `D` inherits from `B` and `C`, both of which inherit from `A`. If `A` has a member,
`D` may end up with two copies of it, and a call to `d.m()` is ambiguous.

- *C++* — the problem exists. By default `D` gets *two* `A` sub-objects; a plain `d.a` is a
  compile error and you must write `d.B::a`. The fix is `class B : virtual public A`, which makes
  all paths share one `A`.
- *Java* — forbids `extends` from two classes, so the *state* diamond cannot occur. Since Java 8
  a *behaviour* diamond can, when two interfaces supply the same `default` method; the compiler
  then forces the class to override and pick with `B.super.m()`.
- *JavaScript* — one `extends` only. Multiple capabilities come from mixins, which produce a
  straight chain, so the last mixin applied wins by a clear rule.

#ans[Ambiguity from two inheritance paths. C++: virtual inheritance. Java: banned for classes, override required for default methods. JS: mixins, no branching.]
]

#ex(10, tier: 1, asked: "Cognizant · pattern")[
A junior writes this and reports "the balance went negative". Fix it and name the principle.

```js
class Account {
  constructor() { this.balance = 0; }
}
const a = new Account();
a.balance -= 900;
```
]
#sol[
The field is public, so any line anywhere can break the invariant "balance is never negative".
The principle is *encapsulation*.

```js
class Account {
  #balance = 0;
  get balance() { return this.#balance; }
  deposit(amt) {
    if (amt <= 0) throw new Error("deposit must be positive");
    this.#balance += amt;
  }
  withdraw(amt) {
    if (amt <= 0) throw new Error("withdrawal must be positive");
    if (amt > this.#balance) throw new Error("insufficient funds");
    this.#balance -= amt;
  }
}
```

Now the rule lives in *one* place. There is no path to the field that skips the check.

#ans[Make the field private and route every change through methods that validate. Principle: encapsulation.]
]

#ex(11, tier: 1, asked: "Accenture · pattern")[
What is a constructor? Can it be `private`, `static`, `final`, or inherited?
]
#sol[
A constructor is a special member that runs when an object is created and initialises its state.
It has the class's name and no return type.

#table(columns: (auto, auto, 1fr),
  [`private`], [*yes*], [used for singletons and factory methods],
  [`static`], [*no*], [it acts on the new object, so it needs an implicit `this`],
  [`final`], [*no*], [`final` blocks overriding, and constructors are never inherited anyway],
  [inherited], [*no*], [but the child's constructor *calls* the parent's via `super()`],
)

#ans[Can be private. Cannot be static or final. Never inherited — only called through `super()`.]
]

#ex(12, tier: 1, asked: "TCS Digital · pattern")[
What is printed?

```js
class A {
  constructor() { this.greet(); }
  greet() { console.log("A"); }
}
class B extends A {
  constructor() { super(); this.name = "bee"; }
  greet() { console.log("B, name =", this.name); }
}
new B();
```
]
#sol[
+ `new B()` runs `B`'s constructor. `super()` runs first.
+ `A`'s constructor calls `this.greet()`. Dispatch is dynamic, and the object is a `B`, so
  `B.greet` runs.
+ `this.name` has not been assigned yet — that line comes *after* `super()`.

Output: `B, name = undefined`.

Same lesson as the Java version in 11.5, with `undefined` instead of `0` because JS has no field
defaults.

#ans[`B, name = undefined` — never call an overridable method from a constructor.]
]

#section[11.18 Worked examples — Tier 2]

#tier-header(2)

#ex(13, tier: 2, asked: "Grab · pattern")[
A ride-hailing app prices trips. Today: `Bike`, `Car`, `Premium`. Next month, marketing wants
`Pooled` and a surge multiplier that applies to some types but not others. The current code is:

```js
function fare(type, km) {
  if (type === "bike")    return 15 + 6 * km;
  if (type === "car")     return 40 + 11 * km;
  if (type === "premium") return 90 + 18 * km;
  throw new Error("unknown");
}
```

Redesign it. Name the principles you applied.
]
#sol[
Two problems: every new type edits `fare` (violates Open/Closed), and surge has nowhere to live
without more branches.

Make each type an object that knows its own base fare, and make surge a *decorator* that wraps
any pricer. That is composition, not inheritance.

```js
class Pricer { constructor(base, perKm) { this.base = base; this.perKm = perKm; }
               quote(km) { return this.base + this.perKm * km; } }

class Surge {                                  // wraps ANY pricer
  constructor(inner, mult) { this.inner = inner; this.mult = mult; }
  quote(km) { return +(this.inner.quote(km) * this.mult).toFixed(2); }
}

const catalog = new Map([
  ["bike",    new Pricer(15, 6)],
  ["car",     new Pricer(40, 11)],
  ["premium", new Pricer(90, 18)],
  ["pooled",  new Pricer(25, 7)],              // new type: one line
]);

function fare(type, km, mult = 1) {
  const p = catalog.get(type);
  if (!p) throw new Error("unknown type: " + type);
  return mult === 1 ? p.quote(km) : new Surge(p, mult).quote(km);
}
```

Verified with `node` for a 8 km trip:

#table(columns: (auto, auto, auto, auto),
  [*type*], [*base + perKm × 8*], [*normal*], [*× 1.5 surge*],
  [bike],    [$15 + 6 times 8$],  [63],  [94.5],
  [car],     [$40 + 11 times 8$], [128], [192],
  [premium], [$90 + 18 times 8$], [234], [351],
  [pooled],  [$25 + 7 times 8$],  [81],  [121.5],
)

Check one by hand: premium $= 90 + 144 = 234$; $234 times 1.5 = 351$. Correct.

*Principles*: Open/Closed (new type = new map entry, `fare` untouched), Single Responsibility
(`Pricer` computes, `Surge` multiplies), and composition over inheritance (`Surge` wraps rather
than extends, so it works for types invented later).

#ans[Replace the type branch with a registry of pricer objects; add surge as a wrapper. Open/Closed + Single Responsibility + composition.]
]

#ex(14, tier: 2, asked: "Shopee · pattern")[
Your codebase has `class AdminUser extends User` and `class GuestUser extends User`. A product
manager now asks for a user who is an admin *and* can be temporarily downgraded to guest
permissions at run time. What is wrong with the inheritance design, and what replaces it?
]
#sol[
*What is wrong.* Inheritance is fixed when the object is constructed. A JS object's class cannot
be changed afterwards in any sane way, so "temporarily downgraded" is impossible. And "admin AND
guest" would need multiple inheritance, which JS does not have.

*What replaces it.* The varying part is not *what the user is*, it is *what the user may do*.
Model permissions as a value the user *has*, not a class the user *is*.

```js
class User {
  constructor(name, role) { this.name = name; this.role = role; }
  can(action) { return this.role.allows(action); }
}
class Role {
  constructor(name, actions) { this.name = name; this.actions = new Set(actions); }
  allows(a) { return this.actions.has(a); }
}
const ADMIN = new Role("admin", ["read", "write", "delete", "invite"]);
const GUEST = new Role("guest", ["read"]);

const u = new User("Nadia", ADMIN);
console.log(u.can("delete"));   // true
u.role = GUEST;                 // temporary downgrade, one assignment
console.log(u.can("delete"));   // false
u.role = ADMIN;
console.log(u.can("delete"));   // true
```

Verified output: `true`, `false`, `true`.

This is the *Strategy* pattern. The general rule: *if a subclass differs only in a value or a
behaviour that might change during the object's life, it should be a field, not a subclass.*

Also note the count. Three roles and two flags would need $2^2 times 3 = 12$ subclasses to cover
every combination. With composition it stays at one `User` class.

#ans[Inheritance fixes the type at construction. Replace `AdminUser`/`GuestUser` with a `role` field holding a `Role` object — the Strategy pattern.]
]

#ex(15, tier: 2, asked: "Agoda · pattern")[
Explain what this C++ code prints and why, then say what a Java developer would expect.

```cpp
struct Base { void show() { std::cout << "Base\n"; } };
struct Derived : Base { void show() { std::cout << "Derived\n"; } };
int main() {
    Base* p = new Derived();
    p->show();
    delete p;
}
```
]
#sol[
*It prints `Base`.*

`show()` is not `virtual`. Without `virtual`, C++ binds the call at compile time using the
*static* type of `p`, which is `Base*`. The object really is a `Derived`, but the compiler never
looks.

A Java developer expects `Derived`, because in Java *every* instance method is virtual by default
and dispatch always uses the object's real type. This is the single biggest mental switch between
the two languages.

*The fix* is one word:

```cpp
struct Base { virtual void show() { std::cout << "Base\n"; } virtual ~Base() = default; };
struct Derived : Base { void show() override { std::cout << "Derived\n"; } };
```

Now it prints `Derived`.

*Second bug in the original*: `~Base` is not virtual either, so `delete p` runs only `~Base`.
With real members in `Derived`, that leaks. Both bugs are fixed by the same habit — mark the base
class's overridable methods and its destructor `virtual`.

#ans[Prints `Base` — non-virtual calls bind to the static pointer type. Java would print `Derived`. Fix: `virtual`, and a `virtual` destructor.]
]

#ex(16, tier: 2, asked: "DBS · pattern")[
A payments service has this interface. A new client, "internal transfers", needs `settle` but
has no card and no refund flow. What principle is violated and how do you fix it?

```
interface PaymentMethod {
  authorize(amount)
  capture(id)
  refund(id, amount)
  tokenizeCard(pan)
  settle(batchId)
}
```
]
#sol[
*Violated*: Interface Segregation — "no client should be forced to depend on methods it does not
use." An internal-transfer class would have to implement `tokenizeCard` and `refund` with thrown
errors, and every caller then has to guess which methods are real.

It also breaks *Liskov*: a method that throws "not supported" is not a valid substitute for one
that works.

*Fix*: split by capability and let each class implement only what it truly has.

```
interface Authorizable { authorize(amount); capture(id) }
interface Refundable   { refund(id, amount) }
interface Cardable     { tokenizeCard(pan) }
interface Settleable   { settle(batchId) }

CardPayment      implements Authorizable, Refundable, Cardable, Settleable
InternalTransfer implements Authorizable, Settleable
```

Now the type system itself answers "can this method be refunded?" — there is nothing to throw
and nothing to check at run time.

#ans[Interface Segregation (and Liskov). Split the fat interface into capability interfaces; each class implements only the ones it supports.]
]

#section[11.19 Worked examples — Tier 3]

#tier-header(3)

#ex(17, tier: 3, asked: "Google · pattern")[
Design the class model for a document editor that supports plain text, images and tables, where
any element may be nested inside a table cell, and where the editor must support undo of every
edit. Name the patterns and justify each inheritance-versus-composition choice.
]
#sol[
*Step 1 — the nesting requirement decides the shape.* "Any element may be nested inside a table
cell" means a table cell holds a *list of elements*, and a table is itself an element. That is the
*Composite* pattern: leaves and containers share one interface.

```js
class Element {                      // abstract in spirit
  render() { throw new Error("must implement render()"); }
  size()   { throw new Error("must implement size()"); }
}
class TextRun extends Element {
  constructor(s) { super(); this.s = s; }
  render() { return this.s; }
  size()   { return this.s.length; }
}
class Image extends Element {
  constructor(src, w, h) { super(); Object.assign(this, { src, w, h }); }
  render() { return `[img ${this.w}x${this.h}]`; }
  size()   { return 1; }
}
class Cell extends Element {
  constructor(children = []) { super(); this.children = children; }
  render() { return this.children.map(c => c.render()).join(""); }
  size()   { return this.children.reduce((n, c) => n + c.size(), 0); }
}
class Table extends Element {
  constructor(rows) { super(); this.rows = rows; }      // rows: Cell[][]
  render() { return this.rows.map(r => r.map(c => c.render()).join(" | ")).join("\n"); }
  size()   { return this.rows.flat().reduce((n, c) => n + c.size(), 0); }
}
```

Inheritance is correct here because a `Table` genuinely *is-a* `Element` — it is used
interchangeably wherever an element is expected, and it honours the whole contract. Liskov holds.

*Step 2 — undo is a separate axis.* Do not put `undo()` on `Element`. Undo is about *edits*, not
about *content*. That is the *Command* pattern: each edit is an object that knows how to apply
itself and how to reverse itself.

```js
class InsertCmd {
  constructor(parent, index, node) { Object.assign(this, { parent, index, node }); }
  do()   { this.parent.children.splice(this.index, 0, this.node); }
  undo() { this.parent.children.splice(this.index, 1); }
}
class DeleteCmd {
  constructor(parent, index) { Object.assign(this, { parent, index }); this.removed = null; }
  do()   { this.removed = this.parent.children.splice(this.index, 1)[0]; }
  undo() { this.parent.children.splice(this.index, 0, this.removed); }
}
class Editor {
  constructor(root) { this.root = root; this.done = []; this.undone = []; }
  run(cmd) { cmd.do(); this.done.push(cmd); this.undone.length = 0; return this; }
  undo()   { const c = this.done.pop(); if (c) { c.undo(); this.undone.push(c); } return this; }
  redo()   { const c = this.undone.pop(); if (c) { c.do(); this.done.push(c); } return this; }
}
```

Verified run:

```js
const cell = new Cell([new TextRun("hello ")]);
const doc  = new Cell([cell]);
const ed   = new Editor(doc);
ed.run(new InsertCmd(cell, 1, new TextRun("world")));
console.log(doc.render(), "| size", doc.size());   // hello world | size 11
ed.undo();
console.log(doc.render(), "| size", doc.size());   // hello  | size 6
ed.redo();
console.log(doc.render(), "| size", doc.size());   // hello world | size 11
```

Count it: `"hello "` is 6 characters, `"world"` is 5, total 11. After undo, 6. Correct.

*Step 3 — the justifications the interviewer is grading.*

#table(columns: (auto, auto, 1fr),
  [*Decision*], [*Choice*], [*Why*],
  [`Table` vs `Element`], [inheritance], [true is-a; used wherever an `Element` is; Liskov holds],
  [`Cell` holds children], [composition], [a cell *has* elements; the set changes at run time],
  [undo], [composition (Command)], [undo varies per *edit*, not per *element*; putting it on `Element` would need a subclass per edit type],
  [`Editor` holds two stacks], [composition], [history is state, not identity],
)

*Step 4 — the follow-up they will ask: "what breaks at scale?"*

- `DeleteCmd` holds a reference to the removed subtree, so the undo stack pins memory. Cap the
  stack, or store a serialised patch instead of the live node.
- Deep nesting makes `size()` recursive; a 10,000-level document overflows the JS stack. Cache
  the size on each container and invalidate upwards on edit.
- Commands hold direct object references, so any edit that replaces a parent invalidates them.
  In a collaborative editor you would move to positions expressed as paths, plus operational
  transformation or CRDTs.

#ans[Composite for the element tree (inheritance — true is-a), Command for edits (composition — undo varies per edit, not per element), stacks for history. Scale risks: memory pinned by the undo stack, recursion depth, stale node references.]
]

#ex(18, tier: 3, asked: "Amazon · pattern")[
You are told: "Our `Notification` base class has 14 subclasses — `EmailNotification`,
`SmsEmailNotification`, `SmsWhatsappRetryNotification`, and so on. Adding a channel means adding
seven classes." Diagnose it and give the refactor, with the class count before and after.
]
#sol[
*Diagnosis: a combinatorial class explosion from using inheritance for two independent axes.*

The axes are:

- *channel* — email, SMS, WhatsApp, push (4 options)
- *policy* — retry, no retry (2 options)

With inheritance, one class must name a point in the product space, so you need
$4 times 2 = 8$ classes; add "digest vs immediate" and it becomes
$4 times 2 times 2 = 16$. Each new channel multiplies, it does not add.

*Refactor — one axis becomes composition.* Channels become interchangeable *senders*. Retry
becomes a *decorator* that wraps any sender.

```js
class EmailSender    { send(m) { return `email:${m}`; } }
class SmsSender      { send(m) { return `sms:${m}`; } }
class WhatsappSender { send(m) { return `wa:${m}`; } }
class PushSender     { send(m) { return `push:${m}`; } }

class Retrying {                                  // wraps ANY sender
  constructor(inner, attempts) { this.inner = inner; this.attempts = attempts; }
  send(m) {
    let last;
    for (let i = 1; i <= this.attempts; i++) {
      try { return this.inner.send(m); } catch (e) { last = e; }
    }
    throw last;
  }
}
class Fanout {                                    // wraps MANY senders
  constructor(senders) { this.senders = senders; }
  send(m) { return this.senders.map(s => s.send(m)); }
}
```

Now `SmsWhatsappRetryNotification` is not a class at all — it is an expression:

```js
const channel = new Retrying(new Fanout([new SmsSender(), new WhatsappSender()]), 3);
console.log(channel.send("otp 4821"));   // [ 'sms:otp 4821', 'wa:otp 4821' ]
```

Verified output: `[ 'sms:otp 4821', 'wa:otp 4821' ]`.

*The count.*

#table(columns: (auto, auto, auto),
  [], [*Inheritance*], [*Composition*],
  [4 channels, retry on/off], [8 classes], [4 + 1 = 5],
  [+ fanout combinations], [$2^4 times 2 = 32$], [4 + 1 + 1 = 6],
  [+ a 5th channel], [64], [7],
  [Growth], [multiplicative], [additive],
)

That table is the answer. *Inheritance composes badly because a class can only be one thing;
objects compose well because you can hold as many as you like.*

*Follow-up they will ask: "when is the 14-subclass design actually right?"* When the axes are
*not* independent — when `EmailNotification` and `SmsNotification` really do differ in behaviour
that cannot be expressed as a parameter, and when there is exactly one axis. With one axis,
inheritance is $n$ classes and composition is $n$ objects; the counts match and inheritance is
simpler to read.

#ans[Combinatorial explosion from two independent axes on one inheritance hierarchy. Make channel a `Sender` object and retry/fanout decorators. Class count goes from multiplicative ($4 times 2 = 8$, then 32, then 64) to additive (5, 6, 7).]
]

#ex(19, tier: 3, asked: "Microsoft · pattern")[
In C++, `struct A { virtual void f(); };` — explain exactly what happens in memory when you call
`p->f()` through an `A*`, what it costs, and give one concrete case where making a method
`virtual` is the *wrong* choice.
]
#sol[
*What happens, in order.*

+ The compiler gives class `A` one static, read-only table — the *vtable* — holding a pointer per
  virtual function, in a fixed slot order.
+ Every `A` object carries a hidden pointer, the *vptr*, set by the constructor to its class's
  vtable. That is why `sizeof` grows by one pointer (measured: 4 → 16 bytes for
  `struct { int x; virtual void f(); }` on 64-bit, after padding).
+ `p->f()` compiles to: load `vptr` from the object; load slot $k$ from the vtable; indirect-call
  that address. Two dependent loads, then a call whose target is unknown at compile time.

*What it costs.*

#table(columns: (auto, 1fr),
  [Memory], [8 bytes per *object* (the vptr), plus one small table per *class*],
  [Time], [two dependent loads before the call; if the target varies, a branch-target mispredict],
  [Optimisation], [*the real cost* — the callee cannot be inlined, so constant propagation, loop unrolling and vectorisation all stop at the call boundary],
)

*Where `virtual` is the wrong choice — a concrete case.*

An inner loop over a `std::vector<Shape*>` calling `s->area()` millions of times. The virtual call
prevents inlining, so a one-line `return w * h;` costs a full call. Three better options:

- *Make the set of types closed and known.* Use `std::variant<Circle, Square>` plus `std::visit`,
  or a tagged union. The compiler sees all cases and can inline each one.
- *Use CRTP* — static polymorphism: `template <class D> struct Shape { double area(){ return static_cast<D*>(this)->areaImpl(); } };`. Dispatch is resolved at compile time; zero runtime cost.
- *Restructure the data.* If you must call one function per element, sort or bucket the vector by
  concrete type and run one tight monomorphic loop per bucket. The call becomes predictable and
  the body inlines.

*The honest trade-off sentence to say out loud:* "`virtual` buys extensibility — new types with no
change to calling code. It costs a pointer per object and blocks inlining. If the type set is
closed and the call is hot, pay with `variant` or CRTP instead; if the type set is open, the
virtual call is the right price."

#ans[Two dependent loads (object → vptr → slot) then an indirect call; 8 bytes per object; the real cost is lost inlining. Wrong choice in a hot loop over a closed type set — use `std::variant` + `std::visit` or CRTP.]
]

#ex(20, tier: 3, asked: "Adobe · pattern")[
"JavaScript is not really object oriented — it has no classes." Argue both sides, then give the
answer you would actually give in an interview.
]
#sol[
*The case for "not really".*

- There are no classes at run time. `class` is sugar; `typeof Shape` is `"function"` (verified in
  section 11.4), and the methods live on a plain object called `Shape.prototype`.
- No interfaces, no abstract keyword, no access levels beyond public and `#private`, no
  overloading, no generics enforced at run time.
- No compile-time type checking at all, so "contract" violations are discovered by a customer,
  not by a build.

*The case for "yes it is".*

- OOP is defined by *encapsulation, abstraction, inheritance, polymorphism* — not by the keyword
  `class`. JS has all four: `#private` fields, duck-typed contracts, `extends` with `super`, and
  dynamic dispatch on every call.
- Prototypal inheritance is *more* general than class inheritance, not less: a class model can be
  built on prototypes (and is — that is exactly what `class` does), while the reverse is awkward.
- Objects can be extended, and their behaviour swapped, at run time. Composition and the Strategy
  pattern are cheaper in JS than in Java, not harder.

*The answer to give.*

"Yes, JavaScript is object oriented — it is *prototype-based* rather than *class-based*, and it is
dynamically typed. It has all four pillars, but three mechanisms Java developers expect are
missing: interfaces, method overloading, and compile-time enforcement. In practice teams add the
first and third back with TypeScript, and replace the second with rest parameters. So the correct
framing is not 'is it OOP', it is 'it is OOP with run-time binding instead of compile-time
binding', and that changes where your errors show up — in tests and production rather than in the
build."

That last clause is what separates a good answer from a memorised one: it names the *consequence*,
not just the difference.

#ans[Prototype-based and dynamically typed, but it has all four pillars. Missing: interfaces, overloading, compile-time checks. Consequence: contract errors surface at run time, which is why teams add TypeScript.]
]

#pagebreak(weak: true)
#section[11.20 Practice]

#practice(tier: 0, time: "6 min")[
+ Expand: OOP, SOLID.
+ One line each: encapsulation vs abstraction.
+ Can an abstract class have a constructor? Can an interface?
+ Which is compile-time polymorphism — overloading or overriding?
+ In JS, `typeof MyClass` is what?
+ Name the four Java access modifiers, least to most open.
+ True/false: `final` on a Java list field prevents `list.add(...)`.
]

#key[
1. Object Oriented Programming; Single responsibility, Open/closed, Liskov substitution,
Interface segregation, Dependency inversion.
2. Encapsulation hides *data* (private fields + accessor methods); abstraction hides
*implementation* (expose a contract).
3. Abstract class: yes. Interface: no.
4. Overloading.
5. `"function"`.
6. `private`, default (package-private), `protected`, `public`.
7. False — it prevents *reassigning* the reference, not mutating the object.
]

#practice(tier: 1, time: "14 min")[
+ Write a Java `Shape` hierarchy: abstract `Shape` with `name` and abstract `area()`; concrete
  `Rectangle` and `Circle`; a `main` that stores both in a `Shape[]` and prints each area. Say
  which line demonstrates run-time polymorphism.
+ Given `class P { void f(int x) {} }` and `class C extends P { void f(String s) {} }` — is `f`
  overloaded or overridden in `C`? What does `new C().f(3)` call?
+ List five rules that make a Java method override legal.
+ Explain why a `private` method cannot be overridden.
+ In JS, what is the difference between `Object.keys(o)` and a `for...in` loop over `o`?
+ Rewrite this to remove the type branch: `function area(s){ if(s.kind==="sq") return s.a*s.a; if(s.kind==="rect") return s.w*s.h; }`
]

#key[
1. `abstract class Shape { protected String name; Shape(String n){name=n;} abstract double area(); }`;
`Rectangle`/`Circle` with `@Override double area()`; loop
`for (Shape s : new Shape[]{ new Rectangle(3,4), new Circle(2) }) System.out.println(s.area());`.
The polymorphic line is `s.area()` — `s` is declared `Shape`, the actual type decides.
2. *Overloaded* — the signature differs, so `C` has *both* methods (`f(int)` inherited,
`f(String)` new). `new C().f(3)` calls the inherited `P.f(int)`.
3. Same name; same parameter list; return type same or covariant; access not more restrictive;
may not throw broader *checked* exceptions. (And the method must not be `static`, `final` or
`private`.)
4. A `private` method is not visible to the subclass, so the subclass's same-named method is a
brand-new method, not an override. Dispatch for it is static.
5. `Object.keys` returns *own, enumerable, string* keys. `for...in` also walks the *prototype
chain*. That is why `for...in` over an array or a class instance can surprise you.
6. Put the behaviour on the object: `const shapes = { sq: s => s.a*s.a, rect: s => s.w*s.h };
function area(s){ return shapes[s.kind](s); }` — or make them classes with an `area()` method.
]

#practice(tier: 2, time: "18 min")[
+ A `Bird` class has `fly()`. `Penguin extends Bird`. Which principle breaks, and give two
  different fixes.
+ Design classes for a food-delivery order supporting: base price, optional packaging fee,
  optional peak-hour multiplier, optional coupon. Combinations are arbitrary. How many classes
  does inheritance need for 3 optional modifiers? How many does your design need?
+ You must add a `close()` method to an interface that 40 classes already implement, without
  breaking the build. How?
+ Explain to a Java developer, in three sentences, why `this` in JavaScript can be `undefined`
  inside a method.
+ A `Cache` class has `get`, `put`, `evict`, `serialize`, `renderStats`, `sendMetrics`. Which
  principle is violated? Split it.
]

#key[
1. *Liskov* — `penguin.fly()` must either lie or throw, so a `Penguin` is not substitutable
wherever a `Bird` is used. Fix A: move `fly()` off `Bird` into a `Flying` capability
(interface/mixin) that `Penguin` does not take. Fix B: make `Bird` hold a `movement` strategy
object and give `Penguin` a `Swimming` strategy.
2. Inheritance needs $2^3 = 8$ classes to cover every on/off combination. With decorators you need
`BasePrice` + one class per modifier = 4, and any combination is built by wrapping:
`new Coupon(new Peak(new Packaging(base)))`.
3. Give it a `default` body (Java 8+): `default void close() {}` — existing implementors inherit
it and still compile; new ones can override it. This is the exact reason `default` methods were
added to the language.
4. "In Java `this` is bound by the compiler and can never be missing. In JavaScript `this` is
bound by *how the function is called*, so pulling a method off its object
(`const f = obj.method`) loses the binding. Class bodies are strict mode, so the lost `this` is
`undefined` rather than the global object — hence the `TypeError`."
5. *Single Responsibility* — it stores, it serialises, it renders, and it talks to a metrics
service; four reasons to change. Split into `Cache` (`get`/`put`/`evict`), `CacheSerializer`,
`StatsFormatter`, `MetricsReporter`, and have the cache emit events the reporter subscribes to.
]

#practice(tier: 3, time: "25 min")[
+ Explain object slicing in C++ with a three-line example, and say what the JS equivalent
  problem is (or why there is none).
+ You are designing a plugin system. Third parties ship classes you never see. Argue for
  interface-based design and name the exact cost you are paying versus a closed `switch`.
+ A team proposes `class Money extends Number`. Give three reasons to refuse.
+ Why does Java allow *covariant return types* on an override but not *contravariant parameter
  types*? Answer in terms of Liskov.
]

#key[
1. `Base b = derivedObject;` — assigning a `Derived` to a `Base` *by value* copies only the
`Base` part; the derived fields are "sliced off" and the vptr is reset to `Base`'s, so virtual
calls now run the base version. Example: `Circle c(2); Shape s = c; s.area();` calls
`Shape::area`. Fix: pass by reference or pointer (`Shape& s = c;`). *There is no JS equivalent* —
JS objects are always handled by reference and never copied on assignment, so nothing can be
sliced.
2. *For interfaces*: the plugin author compiles against a contract you published, and your
dispatch code never changes when a plugin ships — new behaviour with zero edits on your side.
*The cost*: (a) the contract is now frozen — adding a method breaks every plugin unless it has a
default; (b) you lose exhaustiveness checking, so you can never prove at compile time that all
cases are handled; (c) dispatch is indirect, so it cannot be inlined; (d) a misbehaving plugin
can violate your invariants and you must validate at the boundary. A closed `switch` gives you
exhaustiveness and inlining but requires editing your own code for every new case — right for a
closed set, wrong for third parties.
3. (a) `Number` was not designed for extension — in Java it is abstract with a fixed set of
`xxxValue()` methods, and in JS extending the built-in gives you a broken primitive wrapper whose
arithmetic silently converts to `double`. (b) *Liskov fails*: `Money` must refuse
`usd.plus(inr)`, but a `Number` freely adds to any number, so `Money` cannot honour its parent's
contract. (c) It is *not* an is-a relationship — money *has* an amount and a currency. Use
composition: `class Money { #amount; #currency; plus(o){...} }`, with the amount stored in minor
units as an integer or `BigInt` to avoid floating-point error.
4. Liskov says the child must accept *everything* the parent accepts and return *nothing broader*
than the parent returns. A *covariant return* (child returns a subtype) is safe: every caller
expecting the parent's return type still gets something valid. A *contravariant parameter* (child
accepts a supertype) would in principle also be safe — but Java resolves methods by exact
signature, so a differing parameter list creates an *overload*, not an override, and the compiler
would silently give you two methods instead of one. So the restriction is partly theory
(covariance on outputs is sound) and partly Java's dispatch rules (inputs must match exactly to
be recognised as an override at all).
]

#pagebreak(weak: true)
#section[11.21 Rapid fire — one-line answers]

Cover the right column. Say each answer out loud. Target: under five seconds each.

#table(columns: (1fr, 1.15fr),
  [*Question*], [*Answer*],

  [Four pillars?],
  [Encapsulation, abstraction, inheritance, polymorphism.],

  [Encapsulation vs abstraction in one line?],
  [Encapsulation hides *data*; abstraction hides *implementation*.],

  [Overloading — resolved when?],
  [Compile time. Static polymorphism.],

  [Overriding — resolved when?],
  [Run time. Dynamic polymorphism.],

  [Can a `static` method be overridden?],
  [No. It is *hidden*; the declared type decides.],

  [Can a `private` method be overridden?],
  [No — the child cannot see it, so it is a new method.],

  [Constructors: `static`? inherited?],
  [Neither. But one *can* be `private` — that is how a singleton works.],

  [Abstract class — constructor allowed?],
  [Yes. It just cannot be instantiated.],

  [Interface — instance fields allowed?],
  [No. Java allows only `public static final` constants.],

  [C++ pure virtual syntax?],
  [`virtual T f() = 0;` — makes the class abstract.],

  [Why must a polymorphic base destructor be virtual?],
  [Else `delete basePtr` skips the derived destructor — a leak / UB.],

  [Default virtual-ness: Java vs C++?],
  [Java: all instance methods virtual. C++: only those marked `virtual`.],

  [What is a vtable?],
  [Per-class array of function pointers; each object holds a `vptr` to it.],

  [Cost of a virtual call?],
  [8 bytes per object, two loads, and no inlining.],

  [Diamond problem in one line?],
  [Two inheritance paths to one base — which copy does the child get?],

  [C++ fix for the diamond?],
  [`virtual` inheritance — all paths share one base sub-object.],

  [Java's fix?],
  [No multiple class inheritance; `default`-method clashes must be overridden with `A.super.m()`.],

  [JavaScript's answer to multiple inheritance?],
  [Mixins — class factories that build one straight prototype chain.],

  [Does JS support method overloading?],
  [No. The later definition overwrites; use rest params instead.],

  [Does JS have interfaces?],
  [No — duck typing. TypeScript adds `interface` at compile time.],

  [Is-a vs has-a?],
  [Is-a → inheritance. Has-a → composition. Prefer has-a.],

  [Aggregation vs composition?],
  [Aggregation: part survives the whole. Composition: part dies with it.],

  [Shallow vs deep copy?],
  [Shallow shares nested objects; deep duplicates the whole graph.],

  [Deep copy in JS?],
  [`structuredClone(obj)`.],

  [C++ rule of three?],
  [Own a resource → write copy ctor, copy assignment, destructor.],

  [Expand SOLID.],
  [Single responsibility, Open/closed, Liskov, Interface segregation, Dependency inversion.],

  [One-line Liskov test?],
  [A child must work everywhere the parent works, with no surprises.],

  [Why never call an overridable method in a constructor?],
  [The override runs on a half-built object; child fields are still default.],

  [Coupling vs cohesion — which do you want high?],
  [Cohesion high, coupling low.],

  [Why is `this` `undefined` in a detached JS method?],
  [`this` is set by the call site; class bodies are strict mode.],
)

#revision[
*The three-pass rule.* Every OOP answer: the idea → the JS reality → the Java/C++ words. Give
the Java/C++ words at a service company, then add "in JavaScript this works differently" if
asked.

*The two sentences that carry the round.*
- Overloading is compile-time polymorphism (different signature, same class); overriding is
  run-time polymorphism (same signature, child class).
- Inheritance is is-a; composition is has-a; prefer composition unless is-a is genuinely true.

*Abstract class vs interface.* One parent vs many interfaces. State and a constructor vs none.
Shared *code* vs shared *capability*. `extends` vs `implements`.

*Virtual.* Java: every instance method, by default. C++: only with `virtual`, dispatched through
a vtable, and the base destructor must be virtual too.

*Diamond.* C++ gets two base copies (measured: `sizeof(Copier) = 8`, `Device ctor` printed twice)
— fixed with `virtual` inheritance. Java bans the class form and forces an override for clashing
`default` methods. JS has no diamond because mixins build one straight chain.

*What JS genuinely lacks:* interfaces, method overloading, `protected`, compile-time checking.
Say this plainly; it reads as honesty, not weakness.

*The four traps that cost marks*
+ "Static methods can be overridden." — No. Hidden.
+ "JS supports overloading with default parameters." — No. The later method wins.
+ "Java avoids the diamond by banning multiple inheritance." — Half an answer; `default` methods
  bring it back.
+ Calling an overridable method from a constructor — the child override sees default field values
  (`n=0` in the verified Java run).

*SOLID, five short sentences.* One reason to change · extend without editing · the child must
substitute · no fat interfaces · depend on contracts.

*Copying.* Shallow shares nested objects; deep duplicates them. `structuredClone` in JS; rule of
three in C++.
]

]
