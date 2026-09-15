#import "../../shared/lib/style.typ": *

#chapter(num: 4, title: "Design Patterns That Get Asked",
  tagline: "Six patterns answer nine out of ten LLD questions. Learn those six properly.")[

#section[The idea in one page]

A design pattern is not clever code. It is a *name for a shape* that keeps appearing.
Knowing the name is worth something in an interview for one reason only: it lets you say
in four words what would otherwise take four minutes.

There is exactly one question behind every pattern in this chapter:

#formulas(title: "The only question a pattern answers")[
*"What varies here, and how do I let it vary without editing code that already works?"*

Find the thing that changes. Put it behind a small interface. Inject it from outside.
That single move is Strategy, Factory, Decorator, State and Observer wearing different
hats.

The failure it prevents has a name too: the *type-code `if`-chain*. Every time you see
```js
if (kind === "A") ... else if (kind === "B") ... else if (kind === "C") ...
```
somebody will add kind "D" next month by editing that function. That function has no
reason to know about D. A pattern moves D into its own file.
]

#subsection[Symptom to pattern — the table to memorise]

#table(columns: (1fr, auto, 1fr),
  align: (left, left, left),
  [*What you see in the problem*], [*Pattern*], [*The one-line fix*],
  [several ways to do the same calculation], [*Strategy*], [inject an object with one method],
  [behaviour changes as the object's status changes], [*State*], [one class per status; the status handles the call],
  ["create the right kind of X from a string"], [*Factory*], [a registry from key to constructor],
  [optional behaviours that combine freely], [*Decorator*], [wrappers that all share one interface],
  [one event, many uninterested-in-each-other reactions], [*Observer*], [subject publishes, listeners subscribe],
  [exactly one of something, shared], [*Singleton*], [module-level instance — and usually inject it instead],
  [a constructor with 8 arguments, half optional], [*Builder*], [chained setters, validate in `build()`],
  [a third-party API whose shape is wrong for you], [*Adapter*], [a thin class that translates both ways],
  [undo, redo, queue-the-action, retry-the-action], [*Command*], [each action is an object with `do`/`undo`],
  [a request that several handlers might claim], [*Chain of Responsibility*], [linked handlers, first match wins],
  [the same algorithm, one step different], [*Template Method*], [base class calls an abstract hook],
  [control access, add caching or laziness in front], [*Proxy*], [same interface, stands in for the real thing],
)

#trick[
*The pattern-naming move that scores.* Do not say "I will use the Strategy pattern."
Say what varies first, then the name:

"The fare rule changes per city and will keep changing, so I will put it behind a
`quote(ride)` interface and inject it --- that is the Strategy pattern. Adding Chennai
becomes adding a class, not editing `FareCalculator`."

Varies #sym.arrow.r interface #sym.arrow.r injected #sym.arrow.r *then* the name. The
name last. The name alone sounds memorised; the reasoning sounds like experience.
]

#trap[
*Pattern-itis is a real rejection reason.* A candidate who uses six patterns in a
40-minute design has built something nobody can read. Two patterns is the right number
for one LLD problem: one for the thing that varies most, one for the structure. If you
reach for a third, ask yourself whether a plain function would do. Usually it would.
]

#subsection[What the interviewer expects to hear — Java and C++ vocabulary]

Most pattern questions at service companies are *phrased* in Java or C++ vocabulary,
because the classic catalogue was written in those languages. Answer in both.

#formulas(title: "The translation table — say the Java word, show the JS reality")[
#table(columns: (auto, 1fr, 1fr),
  align: (left, left, left),
  [*Java / C++ word*], [*What it means*], [*The JavaScript reality*],
  [`interface`], [a contract with no code],
    [no such keyword; a base class whose methods `throw`, or a duck-typed object],
  [`abstract class`], [partly implemented, cannot be instantiated],
    [a class whose base methods `throw new Error("implement me")`],
  [`implements` vs `extends`], [contract vs inheritance], [only `extends`],
  [method overloading], [same name, different parameter types],
    [does not exist; one function, check the arguments],
  [`private` field], [visible only inside the class], [`#field` — real since ES2022],
)

*The sentence that satisfies a Java interviewer:*
"In Java I would write `interface FareStrategy { long quote(Ride r); }` and
`FlatFare implements FareStrategy`. JavaScript has no `interface` keyword, so the
contract is a base class whose methods throw. The design is identical; only the
compiler's help is missing."
]

#note[
Do not apologise for JavaScript and do not pretend it has interfaces. State the concept,
the Java form, and the JS form. That shows you understand the *idea* rather than one
language's syntax, which is what the question tests.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Name the pattern and say what varies.

```js
class Invoice {
  total(items, country) {
    if (country === "IN") return this.#gst(items);
    else if (country === "SG") return this.#gst9(items);
    else if (country === "TH") return this.#vat(items);
  }
}
```
]
#sol[
*What varies:* the tax rule, once per country.

*The smell:* a type-code `if`-chain. Adding Malaysia means editing `Invoice`, a class
that has nothing to do with tax law. That breaks the open/closed rule --- open to
extension, closed to modification.

*The pattern: Strategy.*

```js
class Invoice {
  constructor(taxRule) { this.taxRule = taxRule; }   // injected
  total(items) { return this.taxRule.apply(items); }
}
const inv = new Invoice(new IndiaGst());
```

Adding Malaysia is now `class MalaysiaSst { apply(items) { ... } }` --- a new file, and
`Invoice` is never opened again.
]
#ans[Strategy. The tax rule varies.]

#ex(2, tier: 0, asked: "warm-up")[
Strategy and State look identical --- both are "an object with a method, held by a
context". What is the actual difference?
]
#sol[
*Who chooses the next object.*

#table(columns: (auto, 1fr, 1fr),
  [], [*Strategy*], [*State*],
  [who picks it], [the *caller*, from outside], [the *current state*, from inside],
  [how often it changes], [rarely; usually once at construction], [constantly, as a result of calls],
  [do the objects know each other?], [no --- `FlatFare` never mentions `SlabFare`], [yes --- `Assigned` creates `Resolved`],
  [what it models], [a *choice*], [a *lifecycle*],
)

*Strategy:* "price this ride with the slab rule." You chose. The rule does not decide to
become a different rule.

*State:* "the ticket is `Assigned`; calling `resolve()` makes it `Resolved`." Nobody
outside chose that. `Assigned.resolve()` chose it.

*One sentence for the interview:* "Same structure, opposite direction of control.
Strategy is chosen from outside and stays; State changes itself from inside."
]
#ans[Strategy is picked by the caller and stays; State replaces itself from inside.]

#ex(3, tier: 0, asked: "warm-up")[
A coffee costs a base price, and a customer may add: extra shot, oat milk, syrup,
whipped cream, and a large size. Someone proposes a subclass for each combination. How
many classes is that? Give the formula and the fix.
]
#sol[
Each option is independently on or off. With 5 independent options:

$ 2^5 = 32 "subclasses" $

`CoffeeWithExtraShotAndOatMilk`, `CoffeeWithExtraShotAndSyrup`, and so on. Add a sixth
option next month and it is $2^6 = 64$.

*The general formula:* $n$ independent options $arrow.r 2^n$ subclasses.

$ n = 3 arrow.r 8 quad n = 5 arrow.r 32 quad n = 10 arrow.r "1,024" $

*The fix: Decorator.* $n$ options need $n$ wrapper classes, not $2^n$ subclasses.

$ 10 "options:" quad "1,024 subclasses" arrow.r 10 "decorators" $

```js
const drink = new Large(new Whip(new Syrup(new Coffee())));
```

Each wrapper adds exactly one behaviour and calls the one inside it.
]
#ans[32 subclasses ($2^5$). Decorator needs 5 classes instead.]

#ex(4, tier: 0, asked: "warm-up")[
Which pattern is `[3, 1, 2].sort((a, b) => a - b)` an example of? Name it and explain in
one line.
]
#sol[
*Strategy.* `sort` owns the algorithm --- comparisons, swapping, partitioning. It does
not own *what "smaller" means*. That is the part that varies, so it is passed in.

`sort` is the context. The comparator is the strategy. A different one can be passed on
every call and `sort` never changes.

*The wider point:* in JavaScript most strategies are just functions, because a
one-method interface and a function are the same thing. Use a class when the strategy
carries configuration (`new SlabFare(5000, 2, 1200)`); use a plain function when it does
not.
]
#ans[Strategy. The comparison rule varies; the sorting algorithm does not.]

#ex(5, tier: 0, asked: "warm-up")[
Why is Singleton often called an anti-pattern? Give two concrete problems, and say when
it is still correct.
]
#sol[
*Problem 1 --- it is a global variable in a costume.* Any code anywhere can call
`Config.get()`, so you cannot tell from a signature what a function touches. Change the
singleton in one test and the next test sees the change, so tests must run in order,
which they never reliably do.

*Problem 2 --- "one instance" is a lie in production.* `static #instance` means one per
*process*. Forty pods give forty instances:
$ 40 "pods" times 1 "\"singleton\" scheduler" = 40 "schedulers" $
If that singleton runs a nightly job for 2 million users:
$ 40 times "2,000,000" = "80,000,000" "emails instead of 2,000,000" $

*When it is still correct.* When a second instance would be a bug or a waste: a database
*connection pool*, a metrics registry, a read-only config object loaded once at boot.

*The interview answer:* "Yes for a connection pool, because a second pool is a resource
leak. No for anything with business logic, because it hides dependencies and it does not
mean what people think across processes --- one-per-cluster needs a lock or a leader
election, not a static field."
]
#ans[It is a global (untestable), and it means one per process, not one per cluster. Correct for pools and registries.]

#ex(6, tier: 0, asked: "warm-up")[
Factory and Builder both "create objects". When do you use each?
]
#sol[
*Factory answers "which class?"* You have a string or an enum and you need the matching
type.

```js
ChannelFactory.create("sms")   // -> SmsChannel
```

*Builder answers "how do I assemble one object with many optional parts?"* There is only
ever one class; the difficulty is the ten constructor arguments.

```js
new PizzaBuilder().size("large").add("paneer").extraCheese().build()
```

#table(columns: (auto, 1fr, 1fr),
  [], [*Factory*], [*Builder*],
  [the problem], [many possible types], [one type, many optional fields],
  [the input], [a key or a rule], [a sequence of choices],
  [returns], [a different class each time], [always the same class],
  [validation], ["is this a known kind?"], ["is this combination legal?" in `build()`],
)

*They combine happily:* a factory picks the builder, or a builder's `build()` calls a
factory for one of its parts. That is not a contradiction; they answer different
questions.
]
#ans[Factory = which class. Builder = how to assemble one class with many options.]

#ex(7, tier: 0, asked: "warm-up")[
In the Observer pattern, what is the difference between *push* and *pull*, and which do
you choose?
]
#sol[
*Push:* the subject sends the data with the notification.
```js
bus.emit("order.placed", { id: 91, userId: "u1", amountPaise: 45000 });
```

*Pull:* the subject sends only "something changed", and each listener fetches what it
needs.
```js
bus.emit("order.changed", { id: 91 });   // listener then calls orders.get(91)
```

#table(columns: (auto, 1fr, 1fr),
  [], [*Push*], [*Pull*],
  [wins], [no extra round trip; the listener works even if the row is later deleted],
           [small messages; each listener takes only what it needs],
  [loses], [big messages; every listener gets fields it does not want; the payload
            becomes a contract you cannot change],
           [$N$ listeners means $N$ reads of the same row, all at the same instant],
)

*Decision: push the identifiers plus the few fields everybody needs; pull the rest.*
Here that means pushing `{ orderId, userId, status, amountPaise, at }` --- roughly 100
bytes --- and letting the warehouse service fetch the 40-line item list itself. You avoid
a fat contract and you avoid six services hammering one row.
]
#ans[Push the ids plus the common fields; pull the heavy details.]

#ex(8, tier: 0, asked: "warm-up")[
Here is a `Report` class. Name every pattern that is *missing*, then say which single one
you would add first.

```js
class Report {
  build(type, user) {
    let rows = db.query("SELECT ...");
    if (type === "pdf") { /* 40 lines */ }
    else if (type === "csv") { /* 30 lines */ }
    else if (type === "xlsx") { /* 50 lines */ }
    log("built " + type); metrics.count("report");
    return out;
  }
}
```
]
#sol[
*Missing patterns:*
+ *Strategy or Factory* for the format --- the `if`-chain is the obvious smell.
+ *Decorator* for `log` and `metrics` --- cross-cutting concerns, repeated in every
  method of every class.
+ *Template Method* --- "fetch rows, render, finish" is the same for every format; only
  the middle step differs.
+ *Adapter* --- if the PDF and XLSX libraries have different APIs, each needs a thin
  translation class so `Report` sees one shape.

*Which one first: the format Strategy.* It is the change that is *actually happening* ---
someone will ask for JSON next week, and today that means a fourth branch in a 120-line
method. Logging and metrics are annoying but they are not growing.

*The rule:* fix the axis that changes most often, not the one with the most famous
pattern name.
]
#ans[Strategy/Factory, Decorator, Template Method, Adapter. Add the format Strategy first, because that is what keeps changing.]

#ex(9, tier: 0, asked: "warm-up")[
A vending machine ignores "select item" until money is in, and ignores "insert coin"
while it is dispensing. A candidate writes `if (this.mode === "IDLE") ...` inside every
method. What breaks, and what is the fix?
]
#sol[
*What breaks --- count it.* With $m$ methods and $s$ modes, the `if`-checks are spread
over $m times s$ places. Four methods and five modes is 20 checks in 4 functions.

+ Adding a sixth mode means finding and editing all four methods. Miss one and you have a
  bug that only appears in one transition.
+ The legal transitions are nowhere written down. You have to read all four methods and
  reconstruct the machine in your head.
+ Two methods will disagree about what `"DISPENSING"` allows, and nobody will notice for
  a year.

*The fix --- State.* One class per mode. `Idle.select()` simply refuses; `HasMoney.select()`
does the work. Nobody asks "what mode am I in?" because the current state object *is* the
answer.

The count changes from $m times s$ scattered `if`s to $s$ classes with $m$ methods each
--- the same number of behaviours, but each one has an address. And the base class
refuses everything by default, so a transition you forgot to allow fails loudly instead
of silently doing the wrong thing.
]
#ans[$m times s$ scattered checks and no written transition table. Fix: one class per state, base class refuses by default.]

#practice(tier: 0, time: "12 min")[
+ Name the pattern: "an object that looks exactly like the real service but caches
  results and can refuse the call if the caller lacks permission."
+ Name the pattern: "the same seven-step import job for CSV, XML and JSON; only step 3
  differs."
+ 7 independent optional features. How many subclasses if you use inheritance? How many
  classes with Decorator?
+ Which pattern lets you implement undo in a text editor, and what does each object
  store?
+ Give one case where Singleton is the right answer and one where it is not.
+ A method takes `(a, b, c, d, e, f)` where c, d, e, f are optional. Which pattern, and
  what does it add that a plain options object does not?
]

#key[
*1.* Proxy. Same interface, stands in front of the real object, adds access control,
caching or laziness.

*2.* Template Method. The base class owns the seven steps and calls an abstract `parse()`
that each subclass fills in.

*3.* $2^7 = 128$ subclasses, or *7* decorator classes.

*4.* Command. Each object stores what it did and enough information to reverse it --- a
`Delete` command stores the position, the length, *and the text it removed*, because you
cannot restore text you did not keep.

*5.* Right: a database connection pool (a second pool doubles the connections for no
gain). Wrong: a `PricingService` singleton --- it hides a dependency, makes tests order-
dependent, and is one-per-process anyway.

*6.* Builder. Over a plain options object it adds (i) a `build()` step where you can
*validate combinations* ("a small pizza cannot have 10 slices"), (ii) required fields
enforced before construction, and (iii) an immutable result --- the built object has no
setters, so nobody mutates it later.
]

#section[Tier 1 — the six patterns, with runnable code]
#tier-header(1)

Every snippet in this section runs as written with `node`. Type them once. Do not read
them.

#subsection[Pattern 1 --- Strategy]

#formulas(title: "Strategy in four lines")[
*Problem:* several interchangeable ways to do one job, and more will be added.

*Structure:* a *context* holds a *strategy* object. Every strategy has the same method
name. The caller injects the one it wants.

*Test that you need it:* can you finish the sentence "the \_\_\_ rule will change"? If
yes, that rule is a strategy.

*Test that you do NOT need it:* there is exactly one rule and there always will be. Then
a plain method is correct and a strategy is ceremony.
]

#diagram(height: 4.6cm, caption: "Strategy. The context on the left never changes. Every new rule is a new box on the right.")[
  #dnode(0cm, 1.5cm, 3.8cm, 1.1cm, "FareCalculator\n(context)\npriceOf(ride)", fill: rgb("#dce9f2"))
  #dnode(5.8cm, 1.5cm, 4.0cm, 1.1cm, "«interface»\nFareStrategy\nquote(ride) → paise", fill: rgb("#f7efe4"))
  #dnode(11.8cm, 0.05cm, 4.6cm, 0.66cm, "FlatFare")
  #dnode(11.8cm, 0.85cm, 4.6cm, 0.66cm, "SlabFare")
  #dnode(11.8cm, 1.65cm, 4.6cm, 0.66cm, "SurgeFare (wraps one)")
  #dnode(11.8cm, 2.45cm, 4.6cm, 0.66cm, "NightFare (added later)", fill: rgb("#eef7ee"))

  #darrow(3.8cm, 2.05cm, 5.8cm, 2.05cm, label: "has-a")
  #darrow(11.8cm, 0.38cm, 9.8cm, 1.7cm, dashed: true)
  #darrow(11.8cm, 1.18cm, 9.8cm, 1.9cm, dashed: true)
  #darrow(11.8cm, 1.98cm, 9.8cm, 2.1cm, dashed: true, label: "implements")
  #darrow(11.8cm, 2.78cm, 9.8cm, 2.3cm, dashed: true)

  #place(dx: 0cm, dy: 3.5cm)[#text(size: 8pt, fill: muted)[Adding the green box changes no existing file. That is the whole point of the pattern.]]
]

#code(lang: "js", caption: "strategy.js — three fare rules, one of which wraps another")[
```js
// ---- the plug: every strategy has the same method name and shape ----
class FlatFare {
  constructor(paisePerKm) { this.paisePerKm = paisePerKm; }
  quote(ride) { return ride.km * this.paisePerKm; }
  get name() { return "flat"; }
}

class SlabFare {
  constructor(basePaise, baseKm, perKmAfter) {
    this.basePaise = basePaise; this.baseKm = baseKm; this.perKmAfter = perKmAfter;
  }
  quote(ride) {
    if (ride.km <= this.baseKm) return this.basePaise;
    return this.basePaise + Math.ceil(ride.km - this.baseKm) * this.perKmAfter;
  }
  get name() { return "slab"; }
}

class SurgeFare {
  constructor(inner, multiplierBp) {       // bp = basis points, 15000 = 1.5x
    this.inner = inner; this.multiplierBp = multiplierBp;
  }
  quote(ride) {
    return Math.round(this.inner.quote(ride) * this.multiplierBp / 10000);
  }
  get name() { return `surge(${this.inner.name}, ${this.multiplierBp / 10000}x)`; }
}

// ---- the context: knows nothing about any rule ----
class FareCalculator {
  constructor(strategy) { this.strategy = strategy; }
  setStrategy(s) { this.strategy = s; }          // swappable at runtime
  priceOf(ride) {
    const paise = this.strategy.quote(ride);
    return { rule: this.strategy.name, paise, rupees: (paise / 100).toFixed(2) };
  }
}

const ride = { km: 12.4, minutes: 31 };
const calc = new FareCalculator(new FlatFare(1400));
console.log(calc.priceOf(ride));

calc.setStrategy(new SlabFare(5000, 2, 1200));
console.log(calc.priceOf(ride));

calc.setStrategy(new SurgeFare(new SlabFare(5000, 2, 1200), 15000));
console.log(calc.priceOf(ride));
```
]

#code(lang: "text", caption: "node strategy.js")[
```text
{ rule: 'flat', paise: 17360, rupees: '173.60' }
{ rule: 'slab', paise: 18200, rupees: '182.00' }
{ rule: 'surge(slab, 1.5x)', paise: 27300, rupees: '273.00' }
```
]

#ex(10, tier: 1, asked: "TCS NQT · pattern")[
Check the three numbers above by hand, then say what `SurgeFare` proves about the
pattern.
]
#sol[
*Flat.* 12.4 km at 1,400 paise per km:
$ 12.4 times "1,400" = "17,360" "paise" = "Rs.173.60" $

*Slab.* Base Rs.50 covers the first 2 km, then Rs.12 per started kilometre:
$ 12.4 - 2 = 10.4 "km beyond the base" $
$ ceil(10.4) = 11 "started kilometres" $
$ "5,000" + 11 times "1,200" = "5,000" + "13,200" = "18,200" "paise" = "Rs.182.00" $

*Surge.* 1.5x on the slab price:
$ "18,200" times "15,000" \/ "10,000" = "18,200" times 1.5 = "27,300" "paise" = "Rs.273.00" $

*What `SurgeFare` proves.* It takes a `FareStrategy` and *is* a `FareStrategy`. So it can
wrap any rule --- flat, slab, or a rule written next year --- without knowing which. That
is Decorator structure used inside a Strategy family, and it is the reason both patterns
are on the same interface.

Because of it, surge is defined *once*. The alternative --- `FlatSurgeFare`,
`SlabSurgeFare`, `NightSurgeFare` --- is the $2^n$ explosion again.
]
#ans[Rs.173.60, Rs.182.00, Rs.273.00. `SurgeFare` is both a strategy and a decorator, so surge is written once.]

#trap[
`ride.km * this.paisePerKm` returns a whole number here only because $12.4 times 1400$
happens to be exact in binary floating point. It will not always be. Any strategy that
computes money must end in `Math.round(...)` and return an integer number of paise. Money
in a `double` is a rejection in a payments interview, every time.
]

#subsection[Pattern 2 --- Factory]

#formulas(title: "Three things called Factory — know which one they mean")[
+ *Simple factory* --- one function or static method with a `switch`. Fine for 3 or 4
  fixed types. Still has an `if`-chain, but it is in *one* place instead of twenty.
+ *Factory method* --- a base class declares `create()` and each subclass returns its own
  product. Used when the creator itself varies.
+ *Abstract factory* --- one object that creates a whole *family* of matching products
  (`WindowsButton` + `WindowsMenu`, or `MySqlConnection` + `MySqlDialect`). Rare in
  interviews but you should be able to define it.

*The version to write in JavaScript: a registry.* A `Map` from key to a builder function.
Adding a kind is `register(...)` in the new file --- the factory class is never edited.
]

#code(lang: "js", caption: "factory.js — the registry factory, which nobody ever edits")[
```js
class Channel {
  send(msg) { throw new Error("subclass must implement send()"); }
}
class SmsChannel extends Channel {
  constructor(gateway) { super(); this.gateway = gateway; }
  send(m) { return { via: "sms", to: m.phone, gateway: this.gateway, cost: 12 }; }
}
class EmailChannel extends Channel {
  send(m) { return { via: "email", to: m.email, cost: 0 }; }
}
class PushChannel extends Channel {
  send(m) { return { via: "push", to: m.deviceToken, cost: 0 }; }
}
class WhatsAppChannel extends Channel {
  send(m) { return { via: "whatsapp", to: m.phone, cost: 35 }; }
}

// ---- registry factory: adding a channel never edits this class ----
class ChannelFactory {
  static #registry = new Map();
  static register(kind, builder) { ChannelFactory.#registry.set(kind, builder); }
  static create(kind, config = {}) {
    const build = ChannelFactory.#registry.get(kind);
    if (!build) throw new Error(`unknown channel: ${kind}`);
    return build(config);
  }
  static kinds() { return [...ChannelFactory.#registry.keys()]; }
}

ChannelFactory.register("sms",      c => new SmsChannel(c.gateway ?? "primary"));
ChannelFactory.register("email",    () => new EmailChannel());
ChannelFactory.register("push",     () => new PushChannel());
ChannelFactory.register("whatsapp", () => new WhatsAppChannel());

const user = { phone: "+91900000000", email: "s@example.com", deviceToken: "dt-77" };
for (const kind of ChannelFactory.kinds())
  console.log(kind.padEnd(9), ChannelFactory.create(kind).send(user));

try { ChannelFactory.create("pigeon"); }
catch (e) { console.log("error   ", e.message); }
```
]

#code(lang: "text", caption: "node factory.js")[
```text
sms       { via: 'sms', to: '+91900000000', gateway: 'primary', cost: 12 }
email     { via: 'email', to: 's@example.com', cost: 0 }
push      { via: 'push', to: 'dt-77', cost: 0 }
whatsapp  { via: 'whatsapp', to: '+91900000000', cost: 35 }
error    unknown channel: pigeon
```
]

#ex(11, tier: 1, asked: "Infosys · pattern")[
Your notification service must pick a channel by user preference, but fall back if the
chosen channel is unavailable, and it must never send WhatsApp to a user who has not
opted in. Where does each of those three rules live? Be specific.
]
#sol[
Three rules, three homes. Putting all three in the factory is the mistake everyone makes.

#table(columns: (auto, 1fr, 1fr),
  [*Rule*], [*Where it lives*], [*Why not the factory*],
  [which class for the key `"sms"`], [the *factory*], [this is exactly what a factory is for],
  [fallback order sms #sym.arrow.r push #sym.arrow.r email],
    [a *Strategy* object, `FallbackPolicy`],
    [the order changes per country and per message type; that is a business rule, not a
     construction rule],
  [no WhatsApp without opt-in],
    [a *guard before* the factory is called, in the dispatcher],
    [a factory that refuses to build things is lying about its job, and consent is a legal
     rule that must be checked and *logged*, not silently skipped],
)

*The flow, in order:*
```
dispatcher
  -> consent check                              (legal gate, logged)
  -> FallbackPolicy.order(user, messageType)    -> ["sms", "push", "email"]
  -> for each kind: ChannelFactory.create(kind).send(msg)   until one succeeds
```

*Why the ordering matters:* it shows you can tell a *construction* concern from a *policy*
concern. The factory answers "which class". The policy answers "in what order, and may I
at all". Mix them and the factory needs the user object, the country, the consent table
and the message type --- at which point it is not a factory, it is the whole service.
]
#ans[Factory: key to class. Strategy: fallback order. Dispatcher guard: consent, before any construction.]

#subsection[Pattern 3 --- Singleton]

#code(lang: "js", caption: "singleton.js — the classic form, what JS gives free, and why you should inject instead")[
```js
// --- 1. The classic textbook singleton, in JavaScript ---
class ConnectionPool {
  static #instance = null;
  #conns; #inUse = 0;

  constructor(size) {
    if (ConnectionPool.#instance)
      throw new Error("use ConnectionPool.get(), not new ConnectionPool()");
    this.#conns = Array.from({ length: size }, (_, i) => `conn-${i}`);
  }
  static get(size = 4) {
    if (!ConnectionPool.#instance) ConnectionPool.#instance = new ConnectionPool(size);
    return ConnectionPool.#instance;
  }
  static reset() { ConnectionPool.#instance = null; }   // ONLY for tests
  acquire() {
    if (this.#inUse >= this.#conns.length) return null;
    return this.#conns[this.#inUse++];
  }
  release() { if (this.#inUse > 0) this.#inUse--; }
  get stats() { return { size: this.#conns.length, inUse: this.#inUse }; }
}

const a = ConnectionPool.get(3);
const b = ConnectionPool.get(99);         // size ignored: it already exists
console.log("same object?", a === b);
console.log("size is 3, not 99:", a.stats);
console.log("acquire:", a.acquire(), a.acquire(), a.acquire(), a.acquire());
try { new ConnectionPool(2); } catch (e) { console.log("blocked:", e.message); }

// --- 2. What a JS module already gives you, for free ---
// in pool.js:  export const pool = new ConnectionPool(8);
// A module body runs once per process. That IS a singleton. No class tricks needed.

// --- 3. Why the pattern lies at scale ---
const pods = 40;
console.log(`\n"one" scheduler x ${pods} pods = ${pods} schedulers running the same cron`);
console.log("a process-local singleton guarantees ONE PER PROCESS, never one per cluster");

// --- 4. The testable alternative: pass it in, do not look it up ---
class ReportJob {
  constructor(pool) { this.pool = pool; }
  run() { return `report built on ${this.pool.acquire()}`; }
}
console.log(new ReportJob({ acquire: () => "fake-conn" }).run());
```
]

#code(lang: "text", caption: "node singleton.js")[
```text
same object? true
size is 3, not 99: { size: 3, inUse: 0 }
acquire: conn-0 conn-1 conn-2 null
blocked: use ConnectionPool.get(), not new ConnectionPool()

"one" scheduler x 40 pods = 40 schedulers running the same cron
a process-local singleton guarantees ONE PER PROCESS, never one per cluster
report built on fake-conn
```
]

#trap[
Look at line 2 of the output: `ConnectionPool.get(99)` silently returned a pool of size
*3*. The argument was ignored because the instance already existed. This is a real and
nasty bug class --- the caller thinks it configured something and it did not. If a
singleton takes configuration, either (i) make `get()` take no arguments and read config
from one place, or (ii) throw if `get()` is called with different arguments than the
first time. Never ignore the arguments silently.
]

#ex(12, tier: 1, asked: "Capgemini · pattern")[
An interviewer asks: "Make your Singleton thread-safe." In Java the answer is
double-checked locking with a `volatile` field. What is the answer in JavaScript, and why
is the question still worth a real reply?
]
#sol[
*The JavaScript answer.* One Node process runs your JavaScript on one thread, and nothing
yields between the `if` and the assignment, so the naive lazy initialisation above is
already safe --- *in this exact form*.

*Where it stops being safe:* the moment initialisation is `async`.
```js
static async get() {
  if (!this.#instance) this.#instance = await createPool();   // BUG
  return this.#instance;
}
```
The `await` yields. Ten concurrent callers all see `null`, all start `createPool()`, and
you build ten pools. The fix is to cache the *promise*, not the result:
```js
static get() {
  if (!this.#promise) this.#promise = createPool();   // assigned synchronously
  return this.#promise;                               // everyone awaits the same one
}
```
The assignment now happens before any `await`, so there is no window.

*And with `worker_threads`:* each worker has its own isolate and its own module
instances, so a singleton is per worker, not per process.

*What to say:* "In Java, double-checked locking with a `volatile` field, because two
threads can interleave between the null check and the assignment. In Node the synchronous
version is safe --- one JavaScript thread, no yield point in between --- but as soon as
construction becomes `async`, the `await` *is* a yield point and I get the same race. The
fix there is to memoise the promise rather than the value."
]
#ans[Cache the promise, not the value. Java needs double-checked locking; Node needs it only once `await` appears.]

#subsection[Pattern 4 --- Observer]

#formulas(title: "Observer in four lines")[
*Problem:* one thing happens; several unrelated parts of the system must react; the thing
that happened must not know about any of them.

*Structure:* a *subject* keeps a list of *listeners* and calls them all. Listeners
subscribe and unsubscribe.

*The three details that separate a good answer from a bad one:*
+ *Unsubscribe.* If `on()` returns nothing, listeners leak forever. Return a function
  that removes it.
+ *Error isolation.* One broken listener must not stop the other five. Wrap each call in
  `try/catch`.
+ *Iterate over a copy.* A listener may unsubscribe itself during the emit, which mutates
  the array you are looping over.
]

#code(lang: "js", caption: "observer.js — an event bus with unsubscribe, once, and error isolation")[
```js
class EventBus {
  #handlers = new Map();                 // event -> array of {fn, once}

  on(event, fn)   { this.#add(event, fn, false); return () => this.off(event, fn); }
  once(event, fn) { this.#add(event, fn, true);  return () => this.off(event, fn); }

  #add(event, fn, once) {
    if (!this.#handlers.has(event)) this.#handlers.set(event, []);
    this.#handlers.get(event).push({ fn, once });
  }

  off(event, fn) {
    const list = this.#handlers.get(event);
    if (!list) return false;
    const i = list.findIndex(h => h.fn === fn);
    if (i === -1) return false;
    list.splice(i, 1);
    return true;
  }

  emit(event, payload) {
    const list = this.#handlers.get(event);
    if (!list || list.length === 0) return { delivered: 0, failed: 0 };
    let delivered = 0, failed = 0;
    for (const h of [...list]) {          // copy: a handler may unsubscribe itself
      try { h.fn(payload); delivered++; }
      catch (err) { failed++; console.log("   [isolated]", event, "->", err.message); }
      finally { if (h.once) this.off(event, h.fn); }
    }
    return { delivered, failed };
  }
}

// --- the subject does not know who is listening ---
class OrderService {
  constructor(bus) { this.bus = bus; this.seq = 0; }
  place(userId, amountPaise) {
    const order = { id: ++this.seq, userId, amountPaise, status: "PLACED" };
    this.bus.emit("order.placed", order);
    return order;
  }
}

const bus = new EventBus();
bus.on("order.placed", o => console.log("   email   : receipt for order", o.id));
bus.on("order.placed", o => console.log("   warehouse: pick list for order", o.id));
bus.on("order.placed", o => { throw new Error("loyalty service is down"); });
bus.once("order.placed", o => console.log("   welcome : first-order coupon (once only)"));

const svc = new OrderService(bus);
console.log("order 1:"); console.log("  result", svc.place("u1", 45000));
console.log("order 2:"); console.log("  result", svc.place("u1", 12000));

const stop = bus.on("order.placed", o => console.log("   audit   : logged", o.id));
console.log("order 3:"); svc.place("u2", 9900);
stop();
console.log("order 4 (audit unsubscribed):"); svc.place("u2", 100);
```
]

#code(lang: "text", caption: "node observer.js")[
```text
order 1:
   email   : receipt for order 1
   warehouse: pick list for order 1
   [isolated] order.placed -> loyalty service is down
   welcome : first-order coupon (once only)
  result { id: 1, userId: 'u1', amountPaise: 45000, status: 'PLACED' }
order 2:
   email   : receipt for order 2
   warehouse: pick list for order 2
   [isolated] order.placed -> loyalty service is down
  result { id: 2, userId: 'u1', amountPaise: 12000, status: 'PLACED' }
order 3:
   email   : receipt for order 3
   warehouse: pick list for order 3
   [isolated] order.placed -> loyalty service is down
   audit   : logged 3
order 4 (audit unsubscribed):
   email   : receipt for order 4
   warehouse: pick list for order 4
   [isolated] order.placed -> loyalty service is down
```
]

#note[
Read the output carefully. The `once` welcome listener fires for order 1 and never
again. The loyalty listener throws every time and never stops the other listeners. The
audit listener appears for order 3 and disappears for order 4 because `stop()` was
called. Those three behaviours are the whole difference between a toy Observer and one
you would put in production.
]

#ex(13, tier: 1, asked: "Wipro · pattern")[
In the code above, `OrderService.place()` returns *after* all four listeners have run. Is
that right? What are the two options, and which do you choose?
]
#sol[
*What is happening now: synchronous notification.* The customer's HTTP response waits for
all four listeners. At 40 ms each:
$ 4 times 40 = 160 "ms added to every order" $
The customer is paying for the warehouse's slowness.

*Option A --- keep it synchronous.* Wins: a failed listener can still fail the whole
order, ordering is guaranteed, and debugging is one stack trace. Loses: the caller's
latency is the *sum* of all listeners, and one slow listener is everybody's problem.

*Option B --- notify asynchronously.* Wins: `place()` returns in its own time and a slow
listener cannot hurt the customer. Loses: a failed listener now fails *silently* after the
customer got a 201, so you need retries, a dead-letter queue and monitoring, or work
simply vanishes.

*Decision: split by whether the listener affects the answer.*
#table(columns: (auto, 1fr),
  [*synchronous, inside the transaction*],
    [things that must be true before you say "order placed": reserve stock, write the
     ledger row. If these fail, the order must fail.],
  [*asynchronous, after commit*],
    [email, loyalty points, analytics, search indexing. The customer does not need them to
     have happened.],
)

And the asynchronous ones must not be plain in-process listeners. They must be rows
written in the *same database transaction* as the order --- the outbox pattern --- then
picked up by a worker. Otherwise a crash between "committed the order" and "called the
listener" loses the email with no record that it was ever owed.
]
#ans[Split them. Sync for anything that can fail the order; async via an outbox row for everything else.]

#subsection[Pattern 5 --- Decorator]

#diagram(height: 4.4cm, caption: "Decorator. The request travels right through the wrappers to the core, and the response travels back out through them. Order is part of the design.")[
  #place(dx: 0cm, dy: 0.05cm)[#text(size: 8pt, fill: muted)[order A — idempotency inside the log, so retries are logged]]
  #dnode(0.2cm, 0.42cm, 3.4cm, 0.85cm, "WithLogging")
  #dnode(4.2cm, 0.42cm, 3.4cm, 0.85cm, "WithTiming")
  #dnode(8.2cm, 0.42cm, 3.8cm, 0.85cm, "WithIdempotency")
  #dnode(12.6cm, 0.42cm, 3.8cm, 0.85cm, "CreateOrder (core)", fill: rgb("#dce9f2"))
  #darrow(3.6cm, 0.72cm, 4.2cm, 0.72cm)
  #darrow(7.6cm, 0.72cm, 8.2cm, 0.72cm)
  #darrow(12.0cm, 0.72cm, 12.6cm, 0.72cm)
  #darrow(12.6cm, 1.05cm, 12.0cm, 1.05cm)
  #darrow(8.2cm, 1.05cm, 7.6cm, 1.05cm)
  #darrow(4.2cm, 1.05cm, 3.6cm, 1.05cm)

  #place(dx: 0cm, dy: 1.75cm)[#text(size: 8pt, fill: muted)[order B — idempotency outermost, so a replayed request never reaches the log or the timer]]
  #dnode(0.2cm, 2.12cm, 3.8cm, 0.85cm, "WithIdempotency", fill: rgb("#f7efe4"))
  #dnode(4.6cm, 2.12cm, 3.4cm, 0.85cm, "WithLogging")
  #dnode(8.6cm, 2.12cm, 3.4cm, 0.85cm, "WithTiming")
  #dnode(12.6cm, 2.12cm, 3.8cm, 0.85cm, "CreateOrder (core)", fill: rgb("#dce9f2"))
  #darrow(4.0cm, 2.42cm, 4.6cm, 2.42cm)
  #darrow(8.0cm, 2.42cm, 8.6cm, 2.42cm)
  #darrow(12.0cm, 2.42cm, 12.6cm, 2.42cm)

  #place(dx: 0cm, dy: 3.25cm)[#text(size: 8pt, fill: muted)[Same four classes, different order, different behaviour. Always say which order you chose and why.]]
]

#code(lang: "js", caption: "decorator.js — four wrappers and a compose() helper")[
```js
// The thing being decorated: anything with .handle(req) -> response
class CreateOrder {
  handle(req) {
    if (req.amount <= 0) throw new Error("amount must be positive");
    return { orderId: "O-" + req.id, amount: req.amount };
  }
}

// Each decorator holds the next one and adds exactly one behaviour.
class WithLogging {
  constructor(next) { this.next = next; }
  handle(req) {
    console.log("  log   > in ", JSON.stringify(req));
    const out = this.next.handle(req);
    console.log("  log   < out", JSON.stringify(out));
    return out;
  }
}
class WithTiming {
  constructor(next) { this.next = next; }
  handle(req) {
    const t0 = process.hrtime.bigint();
    const out = this.next.handle(req);
    const us = Number(process.hrtime.bigint() - t0) / 1000;
    console.log("  timing  took", us < 1000 ? "<1 ms" : us / 1000 + " ms");
    return out;
  }
}
class WithRetry {
  constructor(next, tries) { this.next = next; this.tries = tries; }
  handle(req) {
    let last;
    for (let i = 1; i <= this.tries; i++) {
      try { return this.next.handle(req); }
      catch (e) { last = e; console.log(`  retry   attempt ${i} failed: ${e.message}`); }
    }
    throw last;
  }
}
class WithIdempotency {
  constructor(next) { this.next = next; this.seen = new Map(); }
  handle(req) {
    if (this.seen.has(req.key)) {
      console.log("  idem    replayed stored response for key", req.key);
      return this.seen.get(req.key);
    }
    const out = this.next.handle(req);
    this.seen.set(req.key, out);
    return out;
  }
}

// compose(a, b, c)(core) === a(b(c(core)))  -- outermost listed first
const compose = (...wrappers) => core =>
  wrappers.reduceRight((inner, W) => new W(inner), core);

const handler = compose(WithLogging, WithTiming, WithIdempotency)(new CreateOrder());

console.log("first call:");
console.log(" ", handler.handle({ id: 1, key: "k-1", amount: 500 }));
console.log("same key again:");
console.log(" ", handler.handle({ id: 1, key: "k-1", amount: 500 }));

// A flaky core, wrapped in retry
let n = 0;
const flaky = { handle() { if (++n < 3) throw new Error("timeout"); return { ok: n }; } };
console.log("retry demo:", new WithRetry(flaky, 5).handle({}));

// Why not subclasses: 2^n classes for n options
for (const k of [3, 5, 10])
  console.log(`${k} optional behaviours -> ${2 ** k} subclasses, or ${k} decorators`);
```
]

#code(lang: "text", caption: "node decorator.js")[
```text
first call:
  log   > in  {"id":1,"key":"k-1","amount":500}
  timing  took <1 ms
  log   < out {"orderId":"O-1","amount":500}
  { orderId: 'O-1', amount: 500 }
same key again:
  log   > in  {"id":1,"key":"k-1","amount":500}
  idem    replayed stored response for key k-1
  timing  took <1 ms
  log   < out {"orderId":"O-1","amount":500}
  { orderId: 'O-1', amount: 500 }
  retry   attempt 1 failed: timeout
  retry   attempt 2 failed: timeout
retry demo: { ok: 3 }
3 optional behaviours -> 8 subclasses, or 3 decorators
5 optional behaviours -> 32 subclasses, or 5 decorators
10 optional behaviours -> 1024 subclasses, or 10 decorators
```
]

#ex(14, tier: 1, asked: "Cognizant · pattern")[
In the run above, the second call with key `k-1` was *still logged and still timed*, even
though it did no work. Is that the right order? Give both orders and choose.
]
#sol[
*Order A (what the code does):* logging #sym.arrow.r timing #sym.arrow.r idempotency
#sym.arrow.r core.
The replay is logged and timed. You can see in your logs that a duplicate arrived.

*Order B:* idempotency #sym.arrow.r logging #sym.arrow.r timing #sym.arrow.r core.
The replay returns instantly and never appears in the log or the latency metric.

#table(columns: (auto, 1fr, 1fr),
  [], [*A: idempotency inside*], [*B: idempotency outside*],
  [duplicates visible in logs], [yes], [no],
  [latency metric], [includes replays, so it looks artificially fast], [measures real work only],
  [work saved], [the core call], [the core call, the log write, the timer],
  [cost], [a log line per duplicate --- during a retry storm that is a lot of log], [a blind spot: you cannot see duplicates at all],
)

*Decision: order A, with one change --- log the replay at a lower level and count it as a
metric.* The reason is operational. Duplicate requests are a *signal*: a spike in replays
means a client is retrying, which usually means something upstream is timing out. Making
that invisible to save a log line is a bad trade. But include the replay count as its own
counter so you can alert on it, and make sure the latency metric records replays
separately so your p99 is not flattered by them.

*The wider lesson:* decorator order is not decoration. Swapping two wrappers changes what
the system can see about itself. In an interview, always say the order out loud and give
a reason for it.
]
#ans[Order A (idempotency innermost), but log replays at a lower level and count them separately.]

#subsection[Pattern 6 --- State]

#diagram(height: 5.0cm, caption: "A support-ticket lifecycle as State. Every arrow is a method on a state class; everything not drawn is refused by the base class.")[
  #dnode(0cm, 1.9cm, 2.6cm, 0.9cm, "New")
  #dnode(3.6cm, 1.9cm, 2.8cm, 0.9cm, "Assigned", fill: rgb("#dce9f2"))
  #dnode(3.3cm, 0.2cm, 3.4cm, 0.9cm, "WaitingCustomer")
  #dnode(8.0cm, 1.9cm, 2.8cm, 0.9cm, "Resolved")
  #dnode(12.0cm, 1.9cm, 2.6cm, 0.9cm, "Closed", fill: rgb("#f0dede"))
  #dnode(9.0cm, 3.6cm, 7.4cm, 0.9cm, "base class refuses every action\nnot listed on the current state", fill: rgb("#f7f7f5"))

  #darrow(2.6cm, 2.35cm, 3.6cm, 2.35cm, label: "assign")
  #darrow(4.4cm, 1.9cm, 4.4cm, 1.1cm, label: "wait")
  #darrow(5.6cm, 1.1cm, 5.6cm, 1.9cm, label: "reply(cust)")
  #darrow(6.4cm, 2.35cm, 8.0cm, 2.35cm, label: "resolve")
  #darrow(6.7cm, 0.65cm, 9.4cm, 1.9cm, label: "resolve")
  #darrow(10.8cm, 2.35cm, 12.0cm, 2.35cm, label: "close")
  #darrow(8.2cm, 3.05cm, 6.2cm, 3.05cm, dashed: true, label: "reopen ≤ 7 d")

  #place(dx: 0cm, dy: 4.0cm)[#text(size: 8pt, fill: muted)[`New.close()` (spam) also exists. `Closed` has no methods at all — it is terminal.]]
]

#code(lang: "js", caption: "state.js — the base class refuses everything; each state allows only its own moves")[
```js
class TicketState {
  get name()          { return this.constructor.name; }
  assign(t, agent)    { return this.#no("assign"); }
  waitForCustomer(t)  { return this.#no("waitForCustomer"); }
  reply(t, who)       { return this.#no("reply"); }
  resolve(t)          { return this.#no("resolve"); }
  close(t)            { return this.#no("close"); }
  reopen(t)           { return this.#no("reopen"); }
  #no(action) { return { ok: false, error: `cannot ${action} while ${this.name}` }; }
}

class New extends TicketState {
  assign(t, agent) { t.agent = agent; t.go(new Assigned()); return { ok: true }; }
  close(t)         { t.go(new Closed()); return { ok: true, note: "closed as spam" }; }
}
class Assigned extends TicketState {
  waitForCustomer(t) { t.go(new WaitingCustomer()); return { ok: true }; }
  resolve(t)         { t.resolvedAt = t.clock; t.go(new Resolved()); return { ok: true }; }
  assign(t, agent)   { t.agent = agent; return { ok: true, note: "re-assigned" }; }
}
class WaitingCustomer extends TicketState {
  reply(t, who) {
    if (who !== "customer") return { ok: false, error: "only the customer unblocks this" };
    t.go(new Assigned()); return { ok: true };
  }
  resolve(t) { t.resolvedAt = t.clock; t.go(new Resolved()); return { ok: true }; }
}
class Resolved extends TicketState {
  close(t)  { t.go(new Closed()); return { ok: true }; }
  reopen(t) {
    if (t.clock - t.resolvedAt > 7) return { ok: false, error: "reopen window expired" };
    t.go(new Assigned()); return { ok: true };
  }
}
class Closed extends TicketState {}     // terminal: every action refused by the base class

class Ticket {
  constructor(id) {
    this.id = id; this.agent = null; this.clock = 0;
    this.resolvedAt = null; this.state = new New(); this.history = ["New"];
  }
  go(next) { this.state = next; this.history.push(next.name); }
  tick(days = 1) { this.clock += days; return this; }
  do(action, ...args) {
    const before = this.state.name;
    const r = this.state[action](this, ...args);
    console.log(
      (before + " ." + action + "()").padEnd(34),
      (r.ok ? "-> " + this.state.name : "REFUSED: " + r.error));
    return r;
  }
}

const t = new Ticket(41);
t.do("resolve");                 // refused: not assigned yet
t.do("assign", "asha");
t.do("waitForCustomer");
t.do("reply", "agent");          // refused: wrong person
t.do("reply", "customer");
t.do("resolve");
t.tick(3).do("reopen");          // inside the 7-day window
t.do("resolve");
t.tick(9).do("reopen");          // window expired
t.do("close");
t.do("reopen");                  // terminal
console.log("history:", t.history.join(" -> "));
```
]

#code(lang: "text", caption: "node state.js")[
```text
New .resolve()                     REFUSED: cannot resolve while New
New .assign()                      -> Assigned
Assigned .waitForCustomer()        -> WaitingCustomer
WaitingCustomer .reply()           REFUSED: only the customer unblocks this
WaitingCustomer .reply()           -> Assigned
Assigned .resolve()                -> Resolved
Resolved .reopen()                 -> Assigned
Assigned .resolve()                -> Resolved
Resolved .reopen()                 REFUSED: reopen window expired
Resolved .close()                  -> Closed
Closed .reopen()                   REFUSED: cannot reopen while Closed
history: New -> Assigned -> WaitingCustomer -> Assigned -> Resolved -> Assigned -> Resolved -> Closed
```
]

#trick[
*The "deny by default" base class is the most important line in the whole pattern.*
Because `TicketState` refuses every action, a state you forgot to code fails loudly with
a clear message instead of silently doing something wrong. `Closed` has *no code at all*
and is completely correct. Say this out loud: "the base class denies, so the only
transitions that exist are the ones I wrote down."
]

#ex(15, tier: 1, asked: "Accenture · pattern")[
The reopen window is "7 days". Notice that the code uses `t.clock`, a number passed in,
not `Date.now()`. Why, and what would break if it used `Date.now()`?
]
#sol[
*Why time is a parameter.* Look at the run: `t.tick(3)` then `t.tick(9)` tested twelve days
of lifecycle in under a millisecond.

If `reopen()` called `Date.now()` directly:
+ *You could not test the expiry* without waiting seven real days, or patching the global
  clock, which breaks every other test running at the same time.
+ *Boundaries would be untestable.* Is exactly 7.0 days allowed? With a clock parameter
  you write `t.tick(7)` and find out.
+ *Replay would be impossible.* Re-running last month's events to debug an incident would
  use *today's* clock and give different answers.
+ *Two servers with slightly different clocks would disagree*, so the user would see
  different answers depending on which server they hit.

*The general rule, worth stating in every LLD round:* "Time, randomness and id generation
are *inputs*, not ambient facts. I pass a clock, a random source and an id generator into
the object. Same inputs, same output, always testable."

In production the HTTP layer reads the clock once at the edge and passes that one value
all the way down. Everything below it is deterministic.
]
#ans[So the rule is testable, replayable, and identical on every server. Time is an input, not an ambient fact.]

#subsection[Six more you must be able to name]

You will not be asked to implement these in a 40-minute round, but you *will* be asked to
name them. Here is enough to answer well, with working code for the three that come up
most.

#table(columns: (auto, 1fr, 1fr),
  align: (left, left, left),
  [*Pattern*], [*One line*], [*The giveaway in the question*],
  [Builder], [chained setters, validate in `build()`], ["the constructor has ten arguments"],
  [Adapter], [translate a foreign API into yours], ["we are switching payment providers"],
  [Command], [each action is an object with `do` and `undo`], ["add undo", "queue it", "retry it"],
  [Chain of Responsibility], [linked handlers; first one to claim it wins], ["run these checks in order"],
  [Template Method], [base class owns the steps, subclass fills one in], ["same job, one step differs"],
  [Proxy], [same interface, stands in front of the real object], ["add caching / access control / laziness"],
)

#code(lang: "js", caption: "builder.js — the value of Builder is the validation in build()")[
```js
class Pizza {
  constructor({ size, crust, toppings, extraCheese, cutInto }) {
    Object.assign(this, { size, crust, toppings, extraCheese, cutInto });
  }
  toString() {
    return `${this.size} ${this.crust} [${this.toppings.join(",")}]` +
           `${this.extraCheese ? " +cheese" : ""} cut into ${this.cutInto}`;
  }
}

class PizzaBuilder {
  #d = { size: "medium", crust: "thin", toppings: [], extraCheese: false, cutInto: 8 };
  size(s)      { this.#d.size = s; return this; }
  crust(c)     { this.#d.crust = c; return this; }
  add(...t)    { this.#d.toppings.push(...t); return this; }
  extraCheese(){ this.#d.extraCheese = true; return this; }
  slices(n)    { this.#d.cutInto = n; return this; }
  build() {
    if (this.#d.toppings.length > 6) throw new Error("max 6 toppings");
    if (this.#d.size === "small" && this.#d.cutInto > 6)
      throw new Error("a small pizza cannot have more than 6 slices");
    return new Pizza({ ...this.#d, toppings: [...this.#d.toppings] });
  }
}

console.log(String(new PizzaBuilder().size("large").crust("stuffed")
                     .add("paneer", "capsicum").extraCheese().slices(12).build()));
console.log(String(new PizzaBuilder().add("corn").build()));
try { new PizzaBuilder().size("small").slices(10).build(); }
catch (e) { console.log("rejected at build():", e.message); }
```
]

#code(lang: "text", caption: "node builder.js")[
```text
large stuffed [paneer,capsicum] +cheese cut into 12
medium thin [corn] cut into 8
rejected at build(): a small pizza cannot have more than 6 slices
```
]

#note[
The line `toppings: [...this.#d.toppings]` is not decoration. Without it the built `Pizza`
shares the array with the builder, so reusing the builder would silently modify a pizza
you already made. `[...a]` is a shallow copy; for a nested array you would need
`a.map(r => [...r])`. This is a JavaScript trap that has failed real candidates.
]

#code(lang: "js", caption: "adapter.js — one provider translated into your own port")[
```js
class PaymentPort { charge(orderId, paise) { throw new Error("not implemented"); } }

// SDK A: rupees as a float, callbacks, its own error shape.
const gwA = { pay(ref, rupees, cb) {
  if (rupees > 10000) return cb({ code: 42, text: "limit exceeded" });
  cb(null, { txn: "A-" + ref, amount_rupees: rupees });
} };

class AdapterA extends PaymentPort {
  charge(orderId, paise) {                       // paise in, paise out — always
    return new Promise((ok, no) => gwA.pay(orderId, paise / 100, (e, r) =>
      e ? no(new Error(`payment failed [${e.code}]: ${e.text}`))
        : ok({ txnId: r.txn, paise: Math.round(r.amount_rupees * 100) })));
  }
}
const port = new AdapterA();
port.charge("ord-7", 45000).then(r => console.log(r));
port.charge("ord-8", 5_000_000).catch(e => console.log(e.message));
```
]

#code(lang: "text", caption: "node adapter.js")[
```text
{ txnId: 'A-ord-7', paise: 45000 }
payment failed [42]: limit exceeded
```
]

A second provider with promises and minor units gets `AdapterB` with the same
`charge(orderId, paise)` signature. Nothing above the adapters changes.

#ex(16, tier: 1, asked: "TCS Digital · pattern")[
The adapter turns two different error shapes into one message. List three more things a
good adapter must normalise, and say why each matters.
]
#sol[
+ *Units.* One SDK takes rupees as a float, the other minor units as an integer. Convert
  *at the boundary* so no business code ever sees a float rupee. The round trip must be
  exact: $"45,000"$ paise $arrow.r 450.0$ rupees $arrow.r "45,000"$ paise, which is why
  the code says `Math.round(r.amount_rupees * 100)` and not a bare multiplication.
+ *Idempotency key names.* One calls it `ref`, the other `idempotencyKey`. Your code has
  one concept --- "the order id is the key" --- and the adapter maps it. Let the SDK names
  leak and half your code passes the wrong field on the day you switch providers.
+ *Retryability.* "Limit exceeded" must never be retried; "gateway timeout" must be. The
  adapter maps each provider's 40 error codes onto your own three: `PERMANENT`,
  `TRANSIENT`, `UNKNOWN`. The retry decorator above it then needs no provider knowledge.
+ *Timeouts.* The callback SDK has none. The adapter imposes *yours*, because a
  dependency with no timeout can hang your whole process.

*The sentence that ties it together:* "The adapter is the only file allowed to know the
provider's vocabulary. Everything above it speaks one language. That is what makes
swapping providers a one-file change."
]
#ans[Units, idempotency key names, error classification (permanent/transient), and timeouts.]

#code(lang: "js", caption: "command.js — undo and redo; the deleted text lives in the command")[
```js
class Insert {
  constructor(at, text) { this.at = at; this.text = text; }
  do(d)   { return d.slice(0, this.at) + this.text + d.slice(this.at); }
  undo(d) { return d.slice(0, this.at) + d.slice(this.at + this.text.length); }
}
class Delete {
  constructor(at, len) { this.at = at; this.len = len; this.removed = ""; }
  do(d)   { this.removed = d.substr(this.at, this.len);     // keep it, or you cannot undo
            return d.slice(0, this.at) + d.slice(this.at + this.len); }
  undo(d) { return d.slice(0, this.at) + this.removed + d.slice(this.at); }
}
class Editor {
  constructor(text = "") { this.text = text; this.done = []; this.undone = []; }
  run(c)  { this.text = c.do(this.text); this.done.push(c); this.undone = []; return this; }
  undo()  { const c = this.done.pop(); if (!c) return this;
            this.text = c.undo(this.text); this.undone.push(c); return this; }
  redo()  { const c = this.undone.pop(); if (!c) return this;
            this.text = c.do(this.text); this.done.push(c); return this; }
  show(t) { console.log(t.padEnd(16), JSON.stringify(this.text)); return this; }
}
new Editor("hello world").show("start")
  .run(new Insert(5, ",")).show("insert comma")
  .run(new Delete(0, 6)).show("delete")
  .undo().show("undo delete")
  .undo().show("undo insert")
  .redo().show("redo insert");
```
]

#code(lang: "text", caption: "node command.js")[
```text
start            "hello world"
insert comma     "hello, world"
delete           " world"
undo delete      "hello, world"
undo insert      "hello world"
redo insert      "hello, world"
```
]

#trap[
Two details in `Editor` that interviewers look for:
+ `Delete` stores `this.removed` during `do()`. You cannot undo a delete unless you kept
  what you deleted. Candidates forget this constantly.
+ `run()` clears `this.undone`. After you undo three times and then type something new,
  the redo stack must be thrown away --- otherwise redo would replay commands that apply
  to a document that no longer exists.
]

#code(lang: "js", caption: "chain.js — Chain of Responsibility as a validation pipeline")[
```js
class Check {
  setNext(c) { this.next = c; return c; }          // returns c, so you can chain
  handle(req) {
    const rejection = this.test(req);              // null means "not my problem"
    if (rejection) return rejection;
    return this.next ? this.next.handle(req) : { ok: true };
  }
}
class NotEmpty extends Check {
  test(r) { return r.body.trim() ? null : { ok: false, code: 400, why: "empty body" }; }
}
class LengthLimit extends Check {
  constructor(max) { super(); this.max = max; }
  test(r) { return r.body.length <= this.max ? null
          : { ok: false, code: 413, why: `over ${this.max} characters` }; }
}
class NoLinks extends Check {
  test(r) { return /https?:\/\//.test(r.body)
          ? { ok: false, code: 422, why: "links not allowed yet" } : null; }
}

const head = new NotEmpty();
head.setNext(new LengthLimit(40)).setNext(new NoLinks());
for (const body of ["  ", "x".repeat(50), "see https://spam.example", "hello there"])
  console.log(JSON.stringify(body).padEnd(22).slice(0, 22), head.handle({ body }));
```
]

#code(lang: "text", caption: "node chain.js")[
```text
"  "                   { ok: false, code: 400, why: 'empty body' }
"xxxxxxxxxxxxxxxxxxxxx { ok: false, code: 413, why: 'over 40 characters' }
"see https://spam.exam { ok: false, code: 422, why: 'links not allowed yet' }
"hello there"          { ok: true }
```
]

#ex(17, tier: 1, asked: "Cognizant · pattern")[
Look at the chain order: empty #sym.arrow.r length #sym.arrow.r links #sym.arrow.r rate
limit. Is that order right? What happens if you put `RateLimit` first?
]
#sol[
*Two competing principles.* *Cheapest first:* `body.trim()` costs nanoseconds, a rate
limit that hits Redis costs half a millisecond, so run the cheap ones first.
*Protective first:* a rate limit exists to stop an attacker, and if it is last, 50,000
junk requests a second still run three checks each.

*The numbers settle it.* With the rate limit last, an attacker's 50,000 requests/s are
rejected by local string checks and *never reach Redis*. With it first, they cost
50,000 Redis ops a second --- half of one node --- to reject traffic that three free
checks would have killed anyway.

*Decision: keep the current order inside the chain, and move the rate limit out of the
chain altogether --- to the load balancer or gateway.* A rate limit is not a validation
rule, it is a *protection* rule, and protection belongs as far from your application as
you can push it. A rate-limited request should ideally never reach your process. Inside
the chain, its correct position is last. Outside the chain is better still.
]
#ans[Cheapest-first is right inside the chain, so rate limit last. Better still: move it to the gateway.]

#practice(tier: 1, time: "30 min")[
+ Write a `FareStrategy` for "first 3 km free, then Rs.18 per started km, minimum fare
  Rs.60". Price a 1 km ride and a 9.2 km ride, in paise.
+ Add a `telegram` channel to the registry factory. How many existing files do you edit?
+ Write the `Assigned` state's `close()` so a ticket can be closed directly by a manager,
  but only if an agent is assigned. Where does the check go?
+ Write a `WithTimeout(next, ms)` decorator. Which of the four wrappers must it sit
  outside, and which inside?
+ You have `Insert` and `Delete` commands. Write `Replace(at, len, text)` using them.
  What must `undo()` do?
+ Name the pattern: "one object presents a simple `placeOrder()` that internally calls
  inventory, payments, and shipping."
]

#key[
*1.*
```js
class FreeKmFare {
  quote(r) {
    const charged = Math.max(0, Math.ceil(r.km - 3));
    return Math.max(6000, charged * 1800);
  }
}
```
1 km: $ceil(1-3) = 0$ charged km, so $0 times 1800 = 0$, and the minimum lifts it to
*6,000 paise (Rs.60)*.
9.2 km: $ceil(9.2-3) = ceil(6.2) = 7$ charged km, $7 times 1800 = "12,600"$ paise
*(Rs.126.00)*, above the minimum.

*2.* *Zero* existing files. You add `telegram.js` with the class and one
`ChannelFactory.register("telegram", ...)` line. That is the entire value of a registry
factory, and it is the sentence to say out loud.

*3.*
```js
class Assigned extends TicketState {
  close(t) {
    if (!t.agent) return { ok: false, error: "assign an agent before closing" };
    t.go(new Closed()); return { ok: true };
  }
}
```
The check goes *inside `Assigned.close()`*, not in `Ticket.do()`. A rule about what is
legal while assigned belongs to the `Assigned` class. Putting it in `Ticket` starts the
`if`-chain again.

*4.* `WithTimeout` must sit *inside* `WithRetry` (so each attempt gets its own deadline,
rather than one deadline covering all attempts) and *outside* the core. Relative to
logging and timing it does not matter much, but put it inside `WithLogging` so the
timeout is logged.

*5.* `Replace` runs `Delete(at, len)` then `Insert(at, text)` and keeps both.
`undo()` must reverse them *in the opposite order*: undo the insert first, then undo the
delete. Undoing a composite in the same order corrupts the document --- this is the
single most common bug in Command implementations.

*6.* Facade. One simple entry point in front of several subsystems. It is not on the
"six that get asked" list, but you must be able to name it, and it is the correct answer
whenever someone says "hide the complexity behind one call".
]

#section[Tier 2 — the same patterns inside one real service]
#tier-header(2)

In a Tier-2 round the pattern is not the answer --- it is one paragraph of the answer.
What is being tested is whether you know how each pattern *changes* when there is a
database, a network, and more than one process.

#formulas(title: "What happens to each pattern when it crosses a process boundary")[
#table(columns: (auto, 1fr, 1fr),
  [*Pattern*], [*In one process*], [*Across services*],
  [Strategy], [an injected object], [a config row + a registry; needs versioning and a rollout],
  [Observer], [a list of functions], [a queue topic; needs at-least-once, dedupe, DLQ, ordering],
  [State], [a field holding an object], [a column + a conditional `UPDATE`; needs optimistic locking],
  [Singleton], [`static #instance`], [a distributed lock or leader election --- a static field means nothing],
  [Decorator], [wrapper classes], [middleware, sidecars, or a service mesh],
  [Factory], [a `Map` of constructors], [service discovery: which endpoint, not which class],
)
]

#ex(18, tier: 2, asked: "Grab · pattern")[
*Strategy as configuration.* Pricing rules must change without a deploy. Product wants to
change the surge multiplier at 6 p.m. on a Friday. Design it, and name the danger.
]
#sol[
*The naive version and why it fails.* "Put the formula in the database and evaluate it."
Now your pricing engine is an interpreter for a little language, and a typo in a config
row prices every ride at zero. That is untested, unreviewed code running in production.

*The design that works: a registry of code, parameterised by config.*
```
strategies  (code, written by engineers)   "flat" -> FlatFare
                                           "slab" -> SlabFare
                                           "surge" -> SurgeFare(inner)
pricing_config row (edited by product, reviewed, versioned)
  { city: "BLR", version: 14, strategy: "surge",
    params: { inner: "slab", basePaise: 5000, baseKm: 2,
              perKmAfter: 1200, multiplierBp: 15000 },
    activeFrom: "2026-02-13T18:00:00+05:30" }
```
Product changes *numbers*; engineers change *behaviour*. Different pull requests,
different reviewers.

*Five rules that make it safe:*
#table(columns: (auto, 1fr),
  [*version every row*],
    [a quote records the config version it used, so a fare dispute six months later is
     reproducible],
  [*validate on write*],
    [when version 15 is saved, replay it against 1,000 recorded rides. If any price moves
     more than a threshold, refuse the save],
  [*bounds on every parameter*],
    [`multiplierBp` between 10,000 and 30,000, so a typed 150000 is rejected by the
     schema, not by a customer's bank statement],
  [*activeFrom, never "now"*],
    [changes are scheduled and visible in advance],
  [*cache 30 s, with a floor*],
    [if the config service is down, keep serving the last known good version. *Never*
     fail open on price],
)

*Why the cache.* At 5 million rides a day:
$ "5,000,000" \/ "86,400" = 57.9 "quotes/s average, about 174/s at 3x peak" $
Reading the row per quote is 174 reads/s of a row that changes twice a week. With a 30-second
cache on 40 servers: $40 \/ 30 = 1.33$ reads/s, a *130x* reduction.

*The danger, named plainly:* config is code that skipped code review. Everything above
exists to put the review back.
]
#ans[Registry of code + versioned, bounds-checked, replay-validated config rows, cached 30 s. Config is code without review; add the review back.]

#ex(19, tier: 2, asked: "Shopee · pattern")[
*Observer becomes a queue.* The in-process `EventBus` from Tier 1 worked because the
listeners were in the same process. Now email, warehouse and loyalty are three separate
services. What changes, and what new problems appear?
]
#sol[
*What stays the same:* the subject still does not know who listens. That is Observer,
unchanged.

*What changes --- five things, and every one is a follow-up question.*

#table(columns: (auto, 1fr),
  [*1. Delivery is at-least-once*],
    [a consumer can crash after doing the work and before acknowledging, so the same
     message arrives twice. Every consumer keys on `(consumerName, eventId)` with a
     unique index and skips what it has already done.],
  [*2. Failures are invisible*],
    [in-process, a thrown listener printed a line. Across services a failing consumer just
     stops acknowledging. You need a retry policy, a *dead-letter queue*, and an alert on
     its depth.],
  [*3. Ordering is per partition*],
    [`order.placed` and `order.cancelled` must not be processed out of sequence.
     Partition by `orderId` so one order's events land on one partition.],
  [*4. The publish and the database write can disagree*],
    [commit the order, then fail to publish, and nobody is told. Fix: write the event into
     an `outbox` table in the *same transaction*, and let a relay publish from there.],
  [*5. The payload is a public contract*],
    [three teams parse it. Adding a field is safe; renaming or removing one breaks
     somebody. Only add; version the event type when you must break it.],
)

*The numbers.* 200 million events a day, 6 consumer groups:
$ "200,000,000" \/ "86,400" = "2,315" "events/s published" quad times 6 = "13,889" "deliveries/s" $
$ "200,000,000" times 6 = "1,200,000,000" "deliveries/day" $
At a 0.1% permanent failure rate:
$ "1,200,000,000" times 0.001 = "1,200,000" "dead letters/day" = 13.9 "per second" $

Fourteen a second is not something a human inspects, so the DLQ needs its own tooling:
group by error signature, bulk replay once the bug is fixed, and alert on the *rate of
change* rather than the absolute depth.

*The summary sentence:* "The pattern survives the network; the *guarantees* do not.
In-process Observer gives me exactly-once, ordered, synchronous delivery for free. Across
a broker I buy each of those back with idempotency keys, partitioning and a DLQ."
]
#ans[Same pattern, but you must add idempotency, DLQ, per-key partitioning, an outbox, and an additive-only payload contract.]

#diagram(height: 5.4cm, caption: "Observer in one process (left) and the same pattern across services (right). The shape is identical; everything below the dashed line is what the network costs you.")[
  #place(dx: 0cm, dy: 0cm)[#text(size: 8.5pt, weight: "bold")[in one process]]
  #dnode(0cm, 0.5cm, 3.0cm, 0.9cm, "OrderService\n(subject)")
  #dnode(3.6cm, 0.5cm, 2.4cm, 0.9cm, "EventBus", fill: rgb("#f7efe4"))
  #dnode(6.4cm, 0.05cm, 1.7cm, 0.5cm, "email")
  #dnode(6.4cm, 0.7cm, 1.7cm, 0.5cm, "warehouse")
  #dnode(6.4cm, 1.35cm, 1.7cm, 0.5cm, "audit")
  #darrow(3.0cm, 0.95cm, 3.6cm, 0.95cm)
  #darrow(6.0cm, 0.85cm, 6.4cm, 0.3cm)
  #darrow(6.0cm, 0.95cm, 6.4cm, 0.95cm)
  #darrow(6.0cm, 1.05cm, 6.4cm, 1.6cm)

  #place(dx: 8.8cm, dy: 0cm)[#text(size: 8.5pt, weight: "bold")[across services]]
  #dnode(8.8cm, 0.5cm, 2.3cm, 0.9cm, "Order svc")
  #dnode(11.4cm, 0.5cm, 2.3cm, 0.9cm, "topic\norder.placed", fill: rgb("#f7efe4"))
  #dnode(14.0cm, 0.05cm, 2.4cm, 0.5cm, "email svc")
  #dnode(14.0cm, 0.7cm, 2.4cm, 0.5cm, "warehouse svc")
  #dnode(14.0cm, 1.35cm, 2.4cm, 0.5cm, "audit svc")
  #darrow(11.1cm, 0.95cm, 11.4cm, 0.95cm)
  #darrow(13.7cm, 0.85cm, 14.0cm, 0.3cm)
  #darrow(13.7cm, 0.95cm, 14.0cm, 0.95cm)
  #darrow(13.7cm, 1.05cm, 14.0cm, 1.6cm)

  #place(line(start: (8.3cm, 0cm), end: (8.3cm, 2.3cm), stroke: 0.5pt + rule))
  #place(line(start: (0cm, 2.45cm), end: (16.4cm, 2.45cm), stroke: (paint: rule, thickness: 0.5pt, dash: "dashed")))

  #dnode(0cm, 2.65cm, 7.9cm, 1.55cm, "free: exactly-once, ordered,\nsynchronous, one stack trace\n— but same machine only", fill: rgb("#eef7ee"))
  #dnode(8.8cm, 2.65cm, 7.6cm, 1.55cm, "you must now buy back:\nidempotency key · DLQ · retry policy\npartition by orderId · outbox table", fill: rgb("#f0dede"))
]

#ex(20, tier: 2, asked: "Agoda · pattern")[
*State in a database.* The ticket machine from Tier 1 kept state in memory. Now there are
20 servers and the state is a column. Two requests arrive at the same millisecond. Write
the code and show the race being caught.
]
#sol[
*The bug you must not write.*
```js
const order = await db.read(id);              // status = CREATED
if (ALLOWED.get(order.status).includes("PAID"))
  await db.update(id, { status: "PAID" });    // read-modify-write race
```
Two requests both read `CREATED`, both pass the check, both write. The second write wins
and the first caller was told "you paid" when it did not cause the payment.

*The fix: put the old state in the `WHERE` clause.*
```sql
UPDATE orders SET status = 'PAID', version = version + 1
 WHERE id = ? AND status = 'CREATED' AND version = ?
```
The database decides. If it returns 0 rows, you lost the race. That is *optimistic
locking*, and the `version` column is the whole mechanism.

#code(lang: "js", caption: "persisted.js — a state machine whose guard is a conditional UPDATE")[
```js
// A table with one row per order. version = optimistic lock column.
class FakeTable {
  #rows = new Map();
  insert(row) { this.#rows.set(row.id, { ...row }); }
  read(id)    { const r = this.#rows.get(id); return r ? { ...r } : null; }
  // UPDATE orders SET status=?, version=version+1
  //  WHERE id=? AND status=? AND version=?      <-- the whole trick is this WHERE
  compareAndSet(id, fromStatus, fromVersion, toStatus) {
    const r = this.#rows.get(id);
    if (!r || r.status !== fromStatus || r.version !== fromVersion) return 0; // 0 rows
    r.status = toStatus; r.version++;
    return 1;
  }
}

const ALLOWED = new Map(Object.entries({
  CREATED:   ["PAID", "CANCELLED"],
  PAID:      ["SHIPPED", "REFUNDED"],
  SHIPPED:   ["DELIVERED"],
  DELIVERED: [],
  CANCELLED: [],
  REFUNDED:  [],
}));

class OrderStateMachine {
  constructor(table) { this.table = table; }
  transition(id, toStatus, snapshot) {
    const allowed = ALLOWED.get(snapshot.status) ?? [];
    if (!allowed.includes(toStatus))
      return { ok: false, code: 409, why: `${snapshot.status} -> ${toStatus} is not allowed` };
    const rows = this.table.compareAndSet(id, snapshot.status, snapshot.version, toStatus);
    if (rows === 0) {
      const now = this.table.read(id);
      if (now.status === toStatus)
        return { ok: true, idempotent: true, status: now.status };   // someone else did it
      return { ok: false, code: 409, why: `lost the race; row is now ${now.status}` };
    }
    return { ok: true, status: toStatus };
  }
}

const db = new FakeTable();
db.insert({ id: "O-1", status: "CREATED", version: 1 });
const sm = new OrderStateMachine(db);

console.log("1 illegal jump  ", sm.transition("O-1", "DELIVERED", db.read("O-1")));

// Two workers read the SAME snapshot, then both try to move it. Classic race.
const snapA = db.read("O-1");
const snapB = db.read("O-1");
console.log("2 worker A pays ", sm.transition("O-1", "PAID", snapA));
console.log("3 worker B pays ", sm.transition("O-1", "PAID", snapB));
console.log("4 worker B cancels (stale snapshot)",
            sm.transition("O-1", "CANCELLED", snapB));
console.log("5 ship          ", sm.transition("O-1", "SHIPPED", db.read("O-1")));
console.log("6 deliver       ", sm.transition("O-1", "DELIVERED", db.read("O-1")));
console.log("7 refund after delivery", sm.transition("O-1", "REFUNDED", db.read("O-1")));
console.log("final row       ", db.read("O-1"));
```
]

#code(lang: "text", caption: "node persisted.js")[
```text
1 illegal jump   { ok: false, code: 409, why: 'CREATED -> DELIVERED is not allowed' }
2 worker A pays  { ok: true, status: 'PAID' }
3 worker B pays  { ok: true, idempotent: true, status: 'PAID' }
4 worker B cancels (stale snapshot) { ok: false, code: 409, why: 'lost the race; row is now PAID' }
5 ship           { ok: true, status: 'SHIPPED' }
6 deliver        { ok: true, status: 'DELIVERED' }
7 refund after delivery { ok: false, code: 409, why: 'DELIVERED -> REFUNDED is not allowed' }
final row        { id: 'O-1', status: 'DELIVERED', version: 4 }
```
]

*Read lines 2, 3 and 4 together --- they are the whole answer.*

- Line 2: worker A wins the compare-and-set. One row changed.
- Line 3: worker B has a stale snapshot, so the `WHERE` matches nothing and zero rows
  change --- but the row is *already* in the state B wanted, so B returns success marked
  `idempotent`. B asked for "make it PAID" and it is PAID.
- Line 4: B, still stale, asks to cancel. Now the answer must be a hard *409*, because the
  outcome B wanted did not happen and pretending otherwise would lose money.

*That distinction --- "zero rows, but the goal is met" versus "zero rows, and the goal is
not met" --- is what candidates miss.* Returning 409 for both makes correct retries fail.
Returning 200 for both makes cancellations silently vanish.

*What it costs.* Optimistic locking rejects writers instead of queueing them, so a very
hot row (a flash-sale item) would thrash. *Decision: optimistic locking by default,
because contention on one order row is near zero; a per-key queue only for the few rows
known to be hot.*
]
#ans[Guard the transition with `WHERE status = ? AND version = ?`. Zero rows plus the goal already met = idempotent success; zero rows otherwise = 409.]

#ex(21, tier: 2, asked: "DBS · pattern")[
*Factory plus Adapter for provider failover.* Your service sends OTP messages through
three SMS providers. Provider A is cheapest, B is more reliable, C is the emergency
option. Design the selection, and say where each pattern sits.
]
#sol[
*Four pieces, four patterns. Keeping them separate is the answer.*

#table(columns: (auto, auto, 1fr),
  [*Piece*], [*Pattern*], [*What it does, and nothing else*],
  [`ProviderRegistry`], [Factory], [key `"A"` to a live client object],
  [`ProviderAAdapter`], [Adapter], [translates A's fields, errors and timeouts into your `SmsPort`],
  [`RoutingPolicy`], [Strategy], [given country, message type and health, returns the order to try],
  [`CircuitBreaker`], [State], [per provider: CLOSED / OPEN / HALF#h(0pt)\_OPEN],
)

```
send(otp)
  -> RoutingPolicy.order(...)        -> ["A", "B", "C"]
  -> for each p:
       if breaker[p].isOpen  -> skip, no network call at all
       try  Registry.create(p).send(otp)   -> success, record it, return
       catch transient       -> record failure, try the next provider
       catch permanent       -> stop; another provider will reject it too
```

*The detail that earns the mark: transient versus permanent.* "Invalid phone number" is
permanent --- B will reject it too, so failing over turns one wasted call into three.
"Gateway timeout" is transient. The *adapter* is the only place that knows which of
provider A's 40 error codes means which.

*Why the breaker.* If A dies and each call takes its full 30-second timeout at 2,000
OTPs a second, Little's Law gives
$ L = lambda W = "2,000" times 30 = "60,000" "calls in flight" $
Your process dies long before that. With a breaker that fails in about 1 ms,
$L = "2,000" times 0.001 = 2$. Example 23 works this through in full.

*Decision: route by cost when healthy, by reliability when degraded.* Normal order is A,
B, C (cheapest first). If A's breaker is OPEN, or its success rate over the last minute
drops below 97%, the policy reorders to B, C, A. A user who cannot log in is a lost user;
the SMS costs paise.
]
#ans[Factory = which client. Adapter = translate fields/errors/timeouts. Strategy = order to try. State = circuit breaker per provider, which turns 60,000 hung calls into 2.]

#practice(tier: 2, time: "35 min")[
+ Your pricing config is cached for 30 s on 40 servers. A bad config is published. What
  is the worst-case time until every server is serving the old good version again, and
  what do you add to make it faster?
+ An `order.placed` consumer processes the same event twice. Write the exact table and
  unique index that makes this harmless.
+ Events for one order are processed out of order (`cancelled` before `placed`). Give two
  fixes and choose one.
+ 80 million events a day with 5 consumer groups. Deliveries per day and per second?
+ A conditional `UPDATE` returns 0 rows. Give the two possible reasons and the correct
  HTTP status for each.
+ Where do you put a `WithTimeout` decorator relative to a circuit breaker, and why?
]

#key[
*1.* Worst case is the full TTL, *30 seconds*, plus the time to publish the rollback. To
make it faster add (i) a push channel --- publish a "config changed" event so servers
refresh immediately instead of waiting for the poll, and (ii) an instant kill switch that
pins every server to a named known-good version. Keep the 30 s poll as the fallback for
when the push channel is broken.

*2.*
```sql
CREATE TABLE processed_events (
  consumer   VARCHAR(64) NOT NULL,
  event_id   VARCHAR(64) NOT NULL,
  handled_at TIMESTAMP   NOT NULL,
  PRIMARY KEY (consumer, event_id)
);
```
Insert the row *in the same transaction* as the work. A duplicate hits the primary key,
the transaction rolls back, the message is acknowledged anyway. The key must include the
consumer name, or the email service's row would silently suppress the warehouse service.

*3.* Fix A: partition the topic by `orderId`, so one order's events always go to one
partition and are consumed in order. Fix B: put a sequence number in each event and have
the consumer buffer or reject anything out of order. *Choose A* --- it is one
configuration line and it makes the problem impossible, whereas B is code in every
consumer, forever. Use B only when events genuinely come from several producers that
cannot share a partition key.

*4.* $"80,000,000" times 5 = "400,000,000"$ deliveries/day.
$"400,000,000" \/ "86,400" = "4,630"$ deliveries/s average; at 3x peak about
*13,900/s*.

*5.* Reason 1: the row is already in the state you asked for --- someone else did it, or
this is your own retry. Return *200* with the current state; the caller's goal is met.
Reason 2: the row moved to a *different* state. Return *409 Conflict* with the current
state in the body so the caller can decide what to do.

*6.* `WithTimeout` goes *inside* the breaker. The breaker must see the timeout as a
failure so it can count it and open. If the timeout were outside, the breaker would never
learn that the dependency is slow, and it would stay closed while every call hung.
]

#section[Tier 3 — patterns at large scale]
#tier-header(3)

At this tier the question is usually a trap: an interviewer names a pattern and waits to
see whether you apply it without thinking. The winning answer almost always contains the
words "that pattern does not mean what it means in one process".

#ex(22, tier: 3, asked: "Google · pattern")[
*The singleton that is not single.* A nightly job emails 2 million users. It is
implemented as a singleton scheduler inside the API service, which runs on 40 pods. What
happens, and what is the correct design?
]
#sol[
*What happens.*
$ 40 "pods" times 1 "scheduler each" = 40 "schedulers" $
$ 40 times "2,000,000" = "80,000,000" "emails instead of 2,000,000" $

Forty copies of every email. Your sending reputation is destroyed, your provider
rate-limits you, and the bill is 40x. A `static #instance` field guarantees one instance
*per process* and says nothing at all about a cluster.

*Three designs, compared honestly.*

#table(columns: (auto, 1fr, 1fr),
  [*Design*], [*How it works*], [*Cost and failure mode*],
  [*A. Leader election*],
    [pods compete for a lease key with a TTL; the holder runs the job and renews it],
    [needs a consistent store, and a long garbage-collection pause can let the lease expire
     while the old leader still runs --- so the job must be idempotent anyway],
  [*B. External scheduler*],
    [a managed cron makes one call or enqueues one message; pods are stateless workers],
    [simplest, and usually right. The scheduler becomes a dependency you must monitor],
  [*C. Partition the work*],
    [all 40 pods run; pod $i$ takes users where $"hash"("userId") "mod" 40 = i$],
    [no coordination at all and 40x throughput; needs stable pod identity and a rebalance
     plan],
)

*Decision: B for correctness, C for throughput, idempotency underneath both.*

B removes the problem rather than managing it --- exactly one trigger exists because
exactly one thing triggers. But one pod sending 2 million emails at 200/s takes
$ "2,000,000" \/ 200 = "10,000" "seconds" = 2.8 "hours" $
which will not fit a nightly window. So the triggered job does not send; it *fans out*
2 million messages onto a queue and all 40 pods consume:
$ "2,000,000" \/ (200 times 40) = 250 "seconds" approx 4 "minutes" $

Underneath everything: a unique index on `(campaignId, userId)`. If the trigger fires
twice, or two leases briefly overlap, the second send hits the index and does nothing.
*Never rely on "only one runner" for correctness.* Coordination reduces duplicate *work*;
the unique index prevents duplicate *effects*. You need both, and you must say which is
doing which job.
]
#ans[80 million emails. Use an external trigger, fan out to all pods for throughput, and make the effect idempotent with a unique index — coordination optimises, the index is correct.]

#ex(23, tier: 3, asked: "Amazon · pattern")[
*Circuit breaker as a State machine.* Implement it, trace the three states, and give the
numbers that prove it is worth having.
]
#sol[
*The three states, and what each one does.*

#table(columns: (auto, 1fr, 1fr),
  [*State*], [*Behaviour*], [*Leaves when*],
  [CLOSED], [every call goes through; failures are counted], [$N$ consecutive failures],
  [OPEN], [every call fails instantly, no network touched], [the cool-down timer expires],
  [HALF\_OPEN], [exactly one probe call is allowed through], [probe succeeds #sym.arrow.r CLOSED; probe fails #sym.arrow.r OPEN],
)

#diagram(height: 4.6cm, caption: "The circuit breaker is a three-state machine. HALF_OPEN exists so recovery costs one request, not a flood.")[
  #dnode(0.4cm, 1.5cm, 3.6cm, 1.0cm, "CLOSED\ncalls pass", fill: rgb("#eef7ee"))
  #dnode(6.4cm, 1.5cm, 3.6cm, 1.0cm, "OPEN\nfail instantly", fill: rgb("#f0dede"))
  #dnode(12.4cm, 1.5cm, 3.8cm, 1.0cm, "HALF_OPEN\none probe", fill: rgb("#f7efe4"))

  #darrow(4.0cm, 1.85cm, 6.4cm, 1.85cm, label: "3 failures")
  #darrow(10.0cm, 2.25cm, 12.4cm, 2.25cm, label: "after 5 s")
  #darrow(13.0cm, 1.5cm, 2.6cm, 1.0cm, label: "probe OK")
  #darrow(13.2cm, 3.0cm, 8.4cm, 3.0cm, label: "probe fails", dashed: true)

  #place(dx: 0cm, dy: 3.6cm)[#text(size: 8pt, fill: muted)[Without HALF_OPEN, the cool-down would end by sending the full 2,000 requests/s at a dependency that may still be dead.]]
]

#code(lang: "js", caption: "breaker.js — the state machine, driven by an injected clock")[
```js
class CircuitBreaker {
  constructor({ failuresToOpen = 3, openMs = 5000, halfOpenProbes = 1 } = {}) {
    this.failuresToOpen = failuresToOpen;
    this.openMs = openMs;
    this.halfOpenProbes = halfOpenProbes;
    this.state = "CLOSED";
    this.failures = 0;
    this.openedAt = 0;
    this.probesLeft = 0;
    this.phase = "CLOSED";
  }

  call(fn, now) {
    if (this.state === "OPEN") {
      if (now - this.openedAt >= this.openMs) this.#toHalfOpen();
      else return { ok: false, short: true, why: "circuit OPEN, failing fast" };
    }
    if (this.state === "HALF_OPEN" && this.probesLeft <= 0)
      return { ok: false, short: true, why: "circuit HALF_OPEN, probe in progress" };

    this.phase = this.state;              // the state the call actually ran in
    if (this.state === "HALF_OPEN") this.probesLeft--;
    try {
      const value = fn();
      this.#onSuccess();
      return { ok: true, value };
    } catch (e) {
      this.#onFailure(now);
      return { ok: false, short: false, why: e.message };
    }
  }

  #onSuccess() {
    if (this.state === "HALF_OPEN") { this.state = "CLOSED"; }
    this.failures = 0;
  }
  #onFailure(now) {
    this.failures++;
    if (this.state === "HALF_OPEN" || this.failures >= this.failuresToOpen) {
      this.state = "OPEN"; this.openedAt = now;
    }
  }
  #toHalfOpen() { this.state = "HALF_OPEN"; this.probesLeft = this.halfOpenProbes; }
}

// A dependency that is down from t=0 to t=12000, then healthy.
let clock = 0;
const dep = () => { if (clock < 12000) throw new Error("upstream 503"); return "pong"; };

const cb = new CircuitBreaker({ failuresToOpen: 3, openMs: 5000 });
const trace = [0, 100, 200, 300, 1000, 5400, 10500, 15600, 15700];
for (const t of trace) {
  clock = t;
  const before = cb.state;
  const r = cb.call(dep, t);
  console.log(String(t).padStart(6), "ms  ", before.padEnd(9), "ran as",
              (r.short ? before : cb.phase).padEnd(9), "-> now", cb.state.padEnd(9),
              r.ok ? "OK " + r.value : (r.short ? "short-circuited" : "real call failed"));
}
```
]

#code(lang: "text", caption: "node breaker.js")[
```text
     0 ms   CLOSED    ran as CLOSED    -> now CLOSED    real call failed
   100 ms   CLOSED    ran as CLOSED    -> now CLOSED    real call failed
   200 ms   CLOSED    ran as CLOSED    -> now OPEN      real call failed
   300 ms   OPEN      ran as OPEN      -> now OPEN      short-circuited
  1000 ms   OPEN      ran as OPEN      -> now OPEN      short-circuited
  5400 ms   OPEN      ran as HALF_OPEN -> now OPEN      real call failed
 10500 ms   OPEN      ran as HALF_OPEN -> now OPEN      real call failed
 15600 ms   OPEN      ran as HALF_OPEN -> now CLOSED    OK pong
 15700 ms   CLOSED    ran as CLOSED    -> now CLOSED    OK pong
```
]

*The numbers that prove it is worth having.* The dependency is dead, each call hangs for
its 30-second timeout, and traffic is 2,000 requests a second.

*Without a breaker*, by Little's Law:
$ L = "2,000" times 30 = "60,000" "calls in flight" $
Sixty thousand sockets and sixty thousand pending promises. The process runs out of file
descriptors and dies --- because *someone else's* service died.

*With the breaker*, after 3 failures every call returns in about 1 ms:
$ L = "2,000" times 0.001 = 2 quad quad "60,000" arrow.r 2 = "30,000 times fewer" $

*What HALF#h(0pt)\_OPEN buys.* Without it, the cool-down would end by releasing the full
2,000 requests a second at a dependency that may still be dead --- which re-kills it and
re-opens the breaker, a cycle that can run for hours. HALF#h(0pt)\_OPEN spends *one*
request to ask "are you back?" The trace shows it: the probes at 5,400 ms and 10,500 ms
cost one call each and fail; the probe at 15,600 ms succeeds and the circuit closes.

*The trade-off, named and decided.* A breaker fails requests that *might* have succeeded
--- during a 2-second blip it rejects traffic the dependency could have served. *Take
that price.* The alternative is that a 2-second blip in one dependency takes down every
service that calls it, which is how a small incident becomes a company-wide outage.
Bounded, fast, visible failure beats unbounded queueing.

*And say this last part:* a circuit breaker is per process. Forty pods have forty
breakers, each learning independently --- which is better than a shared one, because a
shared breaker is itself a single point of failure and a new dependency in the hot path.
]
#ans[CLOSED / OPEN / HALF_OPEN. It turns 60,000 hung calls into 2. HALF_OPEN makes recovery cost one request instead of a flood.]

#ex(24, tier: 3, asked: "Microsoft · pattern")[
*Rolling out a new Strategy safely.* You have a new pricing algorithm. Rolling it out to
everyone at once is unacceptable. Design the rollout and prove the new rule is safe before
it serves anyone.
]
#sol[
*Three mechanisms, used in this order.*

+ *Shadow mode.* Serve the old rule. Also run the new rule and throw its answer away,
  recording the difference. Nobody is affected; you get real production data.
+ *Percentage rollout.* Serve the new rule to a small, *stable* slice of users.
+ *Kill switch.* One config change returns everyone to the old rule in under a minute.

*The detail that matters: bucketing must be deterministic.* If you use `Math.random()`, a
user sees the old price on one request and the new price on the next, which is a support
nightmare and makes the experiment meaningless. Hash the user id instead --- the same user
always lands in the same bucket.

#code(lang: "js", caption: "shadow.js — deterministic buckets, a percentage rollout, shadow comparison")[
```js
const strategies = new Map([
  ["v1_flat", r => Math.round(r.km * 1400)],
  ["v2_slab", r => 5000 + Math.max(0, Math.ceil(r.km - 2)) * 1200],
]);

// deterministic bucketing: the same user always lands in the same bucket
function bucketOf(userId, buckets = 100) {
  let h = 2166136261;                            // FNV-1a, 32-bit
  for (let i = 0; i < userId.length; i++) {
    h ^= userId.charCodeAt(i);
    h = Math.imul(h, 16777619) >>> 0;
  }
  return h % buckets;
}

function price(userId, ride, cfg, log) {
  const inTest  = bucketOf(userId) < cfg.rolloutPercent;
  const chosen  = inTest ? cfg.candidate : cfg.control;
  const served  = strategies.get(chosen)(ride);
  if (cfg.shadow && !inTest) {                   // run it, throw the answer away
    const shadow = strategies.get(cfg.candidate)(ride);
    log.push({ userId, served, shadow,
               deltaBp: Math.round((shadow - served) * 10000 / served) });
  }
  return { userId, bucket: bucketOf(userId), strategy: chosen, paise: served };
}

const log = [];
const cfg = { control: "v1_flat", candidate: "v2_slab", rolloutPercent: 10, shadow: true };
for (const u of ["u-1001", "u-1002", "u-1003", "u-1004", "u-1005", "u-1006"])
  console.log(price(u, { km: 12.4 }, cfg, log));

const avg = Math.round(log.reduce((s, r) => s + r.deltaBp, 0) / log.length);
console.log(`shadow samples: ${log.length}, average difference ${avg} bp = ${(avg/100).toFixed(2)}%`);
```
]

#code(lang: "text", caption: "node shadow.js")[
```text
{ userId: 'u-1001', bucket: 1, strategy: 'v2_slab', paise: 18200 }
{ userId: 'u-1002', bucket: 44, strategy: 'v1_flat', paise: 17360 }
{ userId: 'u-1003', bucket: 63, strategy: 'v1_flat', paise: 17360 }
{ userId: 'u-1004', bucket: 58, strategy: 'v1_flat', paise: 17360 }
{ userId: 'u-1005', bucket: 77, strategy: 'v1_flat', paise: 17360 }
{ userId: 'u-1006', bucket: 20, strategy: 'v1_flat', paise: 17360 }
shadow samples: 5, average difference 484 bp = 4.84%
```
]

*Reading the output.* `u-1001` landed in bucket 1, under 10, so it gets the new rule.
The other five are controls and went through the shadow comparison. The new rule is on
average 484 basis points --- 4.84% --- dearer:
$ ("18,200" - "17,360") times "10,000" \/ "17,360" = 483.9 approx 484 "bp" $

*What you check before raising the percentage.*
#table(columns: (auto, 1fr),
  [*the mean*], [is the change what product asked for? 4.84% when they wanted 2% means the
    rule is wrong --- and nobody was charged to find that out],
  [*the tail, not the mean*], [a mean of $+4.84%$ can hide a p99.9 of $+400%$. Those are
    the cases that become screenshots],
  [*sign flips*], [any ride that got *cheaper* when it should have got dearer is a logic
    bug, not a tuning question],
  [*business metrics in the test arm*], [completed rides, cancellations, repeat rate. A
    price rise that is arithmetically perfect and loses 12% of rides is still a failure],
)

*The rollout ladder.* At 5 million rides a day:
$ 1% = "50,000" "rides" quad 10% = "500,000" quad 50% = "2,500,000" $
One day at 1%, two days at 10%, two days at 50%, then 100%. At 50,000 rides you get about
50 samples at p99.9 --- barely enough to notice a problem, which is exactly why you do not
start at 1% and stop looking.

*The trade-off, decided.* Shadow mode doubles pricing CPU for every control request. At
174 quotes a second and a sub-millisecond calculation that is free, so run it on
everything. If the candidate made a network call, you would sample instead --- shadow 5%
of requests, not all of them.
]
#ans[Shadow first (no user affected), then deterministic hash buckets 1/10/50/100%, with a kill switch. Watch the tail and the business metric, not just the mean.]

#ex(25, tier: 3, asked: "Uber · pattern")[
*A saga is a State machine with compensations.* Placing an order touches payments,
inventory and shipping --- three services, so no single transaction. Design it, and
compute how often you will have to compensate.
]
#sol[
*Why the obvious answer is wrong.* A distributed transaction (two-phase commit) holds
locks in all three services for the length of the slowest one, and a coordinator that dies
mid-commit leaves them held. At any real order rate this is unusable.

*The saga.* Break it into local transactions, each with a *compensating* action.

#table(columns: (auto, 1fr, 1fr),
  [*Step*], [*Forward action*], [*Compensation*],
  [1], [reserve stock], [release stock],
  [2], [authorise payment], [void the authorisation],
  [3], [create shipment], [cancel the shipment],
  [4], [capture payment], [refund (a *new* transaction, not an undo)],
)

*It is a State machine.* The saga's state is the column, the steps are the transitions,
and the conditional `UPDATE` from Example 20 is still the guard. Failure at step $k$ runs
compensations for steps $k-1$ down to 1, *in reverse order*.

*How often?* At 99.9% per step:
$ P("all 4 succeed") = 0.999^4 $
$0.999^2 = 0.998001$, and $0.998001^2 = 0.996006$, so
$ P("at least one fails") = 1 - 0.996006 = 0.003994 = 0.3994% $
At 1 million orders a day:
$ "1,000,000" times 0.003994 = "3,994" approx "4,000 compensating flows per day" $

Four thousand a day is far too many for humans, so compensation must be automatic,
retried and monitored --- yet small enough that the 0.1% of compensations that themselves
fail is 4 cases a day, which a person can handle.

*The degraded case.* If one service drops to 99%:
$ 0.99 times 0.999^3 = 0.98703 arrow.r 1.3% arrow.r "13,000 per day" $
A 0.9 percentage-point drop in one dependency tripled the compensation load. The saga's
own health is a dashboard, not an afterthought.

*Four rules, each with a reason:*
+ *Every step and compensation is idempotent*, keyed on `(sagaId, step)`. Retries are
  certain, so they must be harmless.
+ *Compensations run in reverse order.* Releasing stock before voiding the payment can
  leave a customer charged for an item that was resold in between.
+ *Some steps can only be offset, not undone.* A captured payment is refunded. Order the
  saga so irreversible steps come *last*, and there is much less to compensate.
+ *After $N$ failed compensation attempts, escalate to a human queue* with the full saga
  state. Silent failure in a money flow is the worst outcome available.

*Decision: saga over two-phase commit.* Two-phase commit buys atomicity and pays with
availability. The saga gives up atomicity --- there is a window where stock is reserved
and payment is not yet taken --- and buys availability, because each service commits
locally and moves on. For e-commerce that window is invisible and the availability is
worth money. *For a bank moving money between two accounts in one database I would use a
real transaction instead* --- the trade only makes sense when the services are genuinely
separate.
]
#ans[Saga = State machine + reverse-order compensations. At 99.9% per step, 0.4% of 1 M orders = about 4,000 compensations/day, so automate them and irreversible steps go last.]

#ex(26, tier: 3, asked: "Adobe · pattern")[
*When NOT to use a pattern.* An interviewer says: "make this extensible." Give three
cases where the correct answer is "no pattern", and the rule that tells you which case you
are in.
]
#sol[
*Case 1 --- there is exactly one implementation and there always will be.* A `Strategy`
interface with one class is not extensibility, it is *indirection*: a reader opens two
files to learn one thing, and the interface constrains nothing because it was designed
from a single example.
*Say:* "I would write it as a plain method. When the second rule appears, extracting it is
a ten-minute refactor --- and by then I will know what the interface should look like."

*Case 2 --- the variation is data, not behaviour.* Tax *rates* per country vary; the
*calculation* does not. That is a lookup table, not twelve strategy classes. Twelve rows
can be changed by a non-engineer, reviewed in a spreadsheet and tested in bulk; twelve
classes need a deploy each. Only a genuinely different *algorithm* --- compound tax on top
of a levy --- earns a class.

*Case 3 --- the flexibility is for a requirement nobody has asked for.* A plugin system
built because "we might support another database one day" costs an abstraction layer that
leaks anyway, and the day usually never comes. Meanwhile every feature is slower to write.

#formulas(title: "The rule of three, and the cost sentence")[
*Write it concretely the first time. Copy it the second time. Extract the pattern the
third time.* By the third case you can see what actually varies, so the interface you
extract is the right one.

Say the cost out loud too: "a pattern costs one more file, one more indirection, and one
more thing for a new joiner to learn. Worth paying when the change is *already
happening*; a loss when it is speculative."
]

*The answer that scores when an interviewer pushes "but make it extensible":*
"I can. The seam would go here --- `quote(ride)` on an injected object --- and it is a
small change whenever we need it. Today there is one rule, so I would leave it concrete
and spend the time on the genuinely hard part, which is the concurrency on the booking
row. If you would rather see the extensible version, I will write it now."

That proves you know the pattern, proves you know its cost, makes a decision, and hands
control back. It beats both "yes, here are five interfaces" and a flat "no".
]
#ans[One implementation; variation that is data not behaviour; speculative flexibility. Rule of three: concrete, copy, then extract.]

#practice(tier: 3, time: "40 min")[
+ 60 pods each run a "singleton" job that writes one summary row per customer, for
  500,000 customers. How many rows are written? Give the one-line fix that makes it
  harmless even if the coordination fails.
+ A dependency times out after 20 s. Traffic is 3,000 rps. Calls in flight without a
  breaker? With a breaker that fails in 1 ms?
+ A saga has 6 steps, each 99.5% reliable. What fraction of sagas need compensation? At
  2 million sagas a day, how many per day?
+ A shadow run shows the candidate strategy is on average 1% dearer but its p99.9 is 8x
  the control. Ship it or not, and what do you do next?
+ 3 retries at each of 3 layers, with a circuit breaker at only the middle layer. Roughly
  what amplification survives?
+ An interviewer asks you to "use the Visitor pattern". You have never needed it. What do
  you say?
]

#key[
*1.* $60 times "500,000" = "30,000,000"$ rows instead of 500,000 --- 60 copies of each.
The one-line fix: a *unique index on `(reportDate, customerId)`*, with the writer using
"insert, ignore duplicates". Then even if all 60 pods run, exactly one row per customer
survives. Coordination becomes an optimisation instead of a correctness requirement.

*2.* Without: $L = "3,000" times 20 = "60,000"$ calls in flight.
With: $L = "3,000" times 0.001 = 3$. A reduction of 20,000x.

*3.* $0.995^6$. Step by step: $0.995^2 = 0.990025$, $0.995^3 = 0.985075$, and
$0.985075^2 = 0.970373$. So $1 - 0.970373 = 0.029627 = 2.96%$ need compensation.
At 2 million a day: $"2,000,000" times 0.029627 = "59,254"$ sagas a day, about
$"59,254" \/ "86,400" = 0.69$ per second. Sixty thousand compensations a day means the
compensation path is a *main* code path and must be as well tested as the forward path.

*4.* *Do not ship.* A 1% mean with an 8x tail means a small number of users are being
charged enormously more, and those are the cases that become screenshots. Next step: pull
the worst 100 shadow samples and look for the shared input --- it is almost always one
branch of the new rule (a very short ride, a zero-distance ride, a missing field) hitting
a divide or a minimum that was never considered. Fix that branch, re-shadow, then start
the percentage rollout.

*5.* The breaker stops the amplification *below* it once it opens. Before it opens you get
the full $3 times 3 times 3 = 27$x. After it opens, the middle layer stops calling
downward, so the bottom layer sees roughly nothing and the top two layers still amplify
$3 times 3 = 9$x against the middle layer's fast failures. The real answer to say: "a
breaker limits the *duration* of the amplification, not its peak. To limit the peak I need
a retry budget --- at most 10% of traffic may be retries --- at every layer."

*6.* "I have not used Visitor in production, so let me say what I understand it to be and
you can correct me: it lets you add a new *operation* over a fixed set of node types
without editing those types --- each node has an `accept(visitor)` and the visitor has one
method per node type. It fits compilers and document trees, where the type set is stable
and the operations keep growing. It is a poor fit when new node *types* appear often,
because every visitor then needs a new method. For this problem I do not think the type
set is fixed, so I would not reach for it --- but tell me if you are seeing a case I am
missing."

Honesty plus a correct definition plus a judgement beats bluffing. Interviewers ask about
rare patterns precisely to see what you do when you do not know.
]

#section[Interview drill — what the interviewer pushes on]

#table(columns: (1fr, 1.6fr),
  align: (left, left),
  [*The push*], [*The answer that scores*],
  ["Which pattern would you use here?"],
    ["First, what varies: (the thing). I would put it behind a (method name) interface and
      inject it. That is Strategy. Adding a new case becomes a new class instead of an
      edit to (existing class)."],
  ["Strategy or State?"],
    ["Strategy if the caller chooses it and it stays. State if the object replaces its own
      behaviour as a result of calls. Here (which) because (who decides)."],
  ["Is Singleton bad?"],
    ["It is a global, so it hides dependencies and makes tests order-dependent. And it
      means one per *process*, not one per cluster --- 40 pods give 40 instances. I use it
      for a connection pool; for one-per-cluster I need a lease or an external trigger,
      plus a unique index so duplicates are harmless anyway."],
  ["How do you test this?"],
    ["Each strategy is tested alone with a table of inputs and expected paise. The context
      is tested with a fake strategy. Time and randomness are injected, so the state
      machine's 7-day rule is tested in microseconds."],
  ["What if I add a new payment provider?"],
    ["One new adapter file plus one `register()` line. No existing file changes. The
      adapter is the only place that knows that provider's field names, error codes and
      timeout behaviour."],
  ["Your Observer is synchronous. Is that okay?"],
    ["For listeners that can fail the operation, yes --- they belong inside the
      transaction. For the rest, no: I write an outbox row in the same transaction and a
      worker publishes it, so a crash between commit and notify loses nothing."],
  ["How do you change behaviour without a deploy?"],
    ["Code stays in a registry; config chooses which entry and supplies bounded
      parameters. Versioned rows, validated against recorded traffic on write, activated
      on a schedule, cached 30 s with a kill switch. Config is code that skipped review,
      so I put the review back."],
  ["Two requests hit the same state transition at once."],
    ["The old state and version go in the `WHERE` clause. Zero rows updated means I lost
      the race. If the row is already in the state I wanted, I return 200 as idempotent;
      if it moved somewhere else, 409 with the current state."],
  ["That is a lot of patterns for one problem."],
    ["Agreed --- I would ship two: (the one for the thing that varies most) and (the one
      for the structure). The others I named so you know I considered them; I would add
      each one on the day a second case actually appears."],
  ["Use pattern X." (one you do not know)],
    ["Here is what I understand it to be, here is the kind of problem it fits, and here is
      why I am not sure it fits this one. Correct me if I have it wrong."],
)

#trap[
Four ways candidates lose marks on pattern questions, in order of frequency:
+ *Naming without reasoning.* "I'll use Factory" with no sentence about what varies. It
  reads as a memorised list.
+ *Six patterns in one design.* Nobody can read it, and it signals that you cannot
  prioritise.
+ *Reciting the classic catalogue's Java structure in JavaScript* --- an `AbstractFactory`
  base class with a `createProductA()` that throws. Write the idiomatic version and
  *mention* the Java form.
+ *Refusing to decide.* "Both Strategy and State could work here" and then stopping. Pick
  one, give the reason, and name the condition that would change your mind.
]

#revision[
*The one question behind every pattern.* "What varies here, and how do I let it vary
without editing working code?" Find it, put it behind a small interface, inject it.

*The naming move.* Say what varies #sym.arrow.r the interface #sym.arrow.r injected
#sym.arrow.r *then* the pattern name. Name last.

*Symptom to pattern.*
#table(columns: (auto, 1fr),
  [several ways to do one calculation], [Strategy],
  [behaviour changes with status], [State],
  [pick a class from a key], [Factory (registry of builders)],
  [optional behaviours that combine], [Decorator ($n$ classes, not $2^n$)],
  [one event, many reactions], [Observer],
  [exactly one, shared, in one process], [Singleton — usually inject instead],
  [ten constructor arguments], [Builder (validate in `build()`)],
  [a foreign API with the wrong shape], [Adapter],
  [undo / queue / retry an action], [Command],
  [checks in order, first match wins], [Chain of Responsibility],
  [same steps, one differs], [Template Method],
  [caching, laziness, access control in front], [Proxy],
  [one simple call over several subsystems], [Facade],
)

*Strategy vs State.* Same structure, opposite control. Strategy: chosen outside, stays.
State: replaces itself from inside, and states know each other.

*Decorator maths.* $n$ independent options $arrow.r 2^n$ subclasses $arrow.r$ use $n$
decorators. $n=5$: 32 vs 5. $n=10$: 1,024 vs 10. Order matters --- always say which order
and why.

*Observer's three details.* Return an unsubscribe function. Wrap each listener in
try/catch. Iterate over a copy of the list.

*State's key line.* The base class *refuses by default*, so a transition you did not write
fails loudly. A terminal state needs no code at all.

*Java vocabulary to say out loud.* `interface` = contract with no code (JS: a base class
whose methods throw). `abstract class` = partly implemented. JS has no overloading, no
`implements`, but has real `#private` fields.

*What the network costs each pattern.*
#table(columns: (auto, 1fr),
  [Strategy], [becomes versioned, bounds-checked config + a code registry; cache 30 s, keep a kill switch],
  [Observer], [becomes a topic: at-least-once, so idempotency keys, DLQ, partition by entity id, outbox],
  [State], [becomes a column: guard with `WHERE status = ? AND version = ?`],
  [Singleton], [means nothing across processes: external trigger or lease, plus a unique index],
  [Decorator], [becomes middleware; `WithTimeout` inside `WithRetry`, both inside the breaker],
)

*Numbers to quote.*
#table(columns: (auto, 1fr),
  [40 pods, 1 "singleton" job], [40 runs — $40 times 2 "M"$ = 80 M emails],
  [breaker, 2,000 rps, 30 s timeout], [$L = "60,000"$ in flight #sym.arrow.r 2 with a breaker],
  [3 retries at 3 layers], [$3^3 = 27$x amplification],
  [saga, 4 steps at 99.9%], [$1 - 0.999^4 = 0.4%$ #sym.arrow.r 4,000 compensations per million],
  [200 M events, 6 consumers], [1.2 B deliveries/day = 13,889/s],
)

*Zero rows from a conditional UPDATE.* Already in the target state #sym.arrow.r 200,
idempotent. Moved elsewhere #sym.arrow.r 409 with the current state. Never the same answer
for both.

*The rule of three.* Concrete the first time. Copy the second. Extract the third — by then
you can see what actually varies.

*Things that gain marks.* Saying what varies before naming anything. Two patterns, not
six. Stating decorator order and why. Money as integer paise. Time as an injected
parameter. Naming what your design cannot do.

*Things that lose marks.* Pattern names with no reasoning. Pattern-itis. A Java
`AbstractFactory` transliterated into JavaScript. "Both could work" with no choice.
]

]
