#import "../../shared/lib/style.typ": *

#chapter(num: 3, title: "OOP & SOLID for Interviews",
  tagline: "Classes that survive the next change")[

#section[The idea in one page]

An LLD round is 45 minutes long. The interviewer gives you a small system — a bill, a
locker, a fee engine — and asks you to write the classes. Nobody runs your code. So what
are they actually grading?

#table(columns: 2,
  align: (left, left),
  [*What they watch*], [*What a pass looks like*],
  [Did you find the right nouns?], [4 to 8 classes, each with one job you can say in one sentence],
  [Where does each rule live?], [Every rule sits in exactly one class, not copied in three],
  [What happens when I add a feature?], [You add a class or a line. You do not edit five old files],
  [Can this be tested?], [The rules class needs no database to run],
  [Did you name the trade-off?], [You named two options and *picked* one, with a reason],
)

That last row is the one most students lose. Saying "it depends" scores zero. Saying
"a map of small rule objects, because a new coupon then adds one line instead of editing a
40-branch `if`" scores full marks.

#formulas(title: "The four pillars, and the one test for each")[

*Encapsulation* — the data and the rules that guard it live inside one class, and the
outside world cannot reach past the rules.
#linebreak() *Test:* can an outsider put the object into a state your class calls illegal?
If yes, it is not encapsulated.

*Abstraction* — the caller is given a short list of things it can ask for, and is not shown
how any of them work.
#linebreak() *Test:* can you replace the whole inside of the class and leave every caller
untouched? If yes, the abstraction is good.

*Inheritance* — a child class *is a* kind of the parent, and can be used anywhere the parent
is expected.
#linebreak() *Test:* read every promise the parent makes. Does the child keep all of them?
If not, it should not inherit.

*Polymorphism* — one call site, many behaviours, chosen by the real type of the object at
run time.
#linebreak() *Test:* can you add a new behaviour without touching the call site? If yes, it
is real polymorphism, not a disguised `if`.
]

#note[
JavaScript has classes but no `interface` keyword, no `abstract` keyword, and no method
overloading. This chapter teaches the concept in JavaScript, and then states plainly what
the Java or C++ answer is — because a service-company interviewer will ask for the answer in
that vocabulary, and "JavaScript does not have that" is not an accepted reply.
]

#subsection[The shape of every LLD answer]

Draw this on the board before you write a single class. It tells the interviewer you have a
plan.

#diagram(height: 3.4cm, caption: "The five layers. Arrows point the way a call travels. The dashed arrow is the one that must NOT exist.")[
  #place(dx: 0pt,   dy: 6pt)[#text(size: 7.5pt, fill: muted)[1]]
  #place(dx: 98pt,  dy: 6pt)[#text(size: 7.5pt, fill: muted)[2]]
  #place(dx: 196pt, dy: 6pt)[#text(size: 7.5pt, fill: muted)[3]]
  #place(dx: 294pt, dy: 6pt)[#text(size: 7.5pt, fill: muted)[4]]
  #place(dx: 392pt, dy: 6pt)[#text(size: 7.5pt, fill: muted)[5]]
  #dnode(0pt,   22pt, 78pt, 44pt, [Caller #linebreak() API / CLI])
  #dnode(98pt,  22pt, 78pt, 44pt, [Service #linebreak() one use case])
  #dnode(196pt, 22pt, 78pt, 44pt, [Domain #linebreak() rules + state], fill: rgb("#e6efe6"))
  #dnode(294pt, 22pt, 78pt, 44pt, [Port #linebreak() an interface])
  #dnode(392pt, 22pt, 78pt, 44pt, [Adapter #linebreak() DB / HTTP])
  #darrow(78pt, 44pt, 98pt, 44pt)
  #darrow(176pt, 44pt, 196pt, 44pt)
  #darrow(274pt, 44pt, 294pt, 44pt)
  #darrow(372pt, 44pt, 392pt, 44pt)
  #darrow(430pt, 22pt, 235pt, 22pt, label: "never", dashed: true)
]

Layer 3 is where the marks are. It holds the rules, holds no connection object, and can be
run in a test in under a millisecond. The dashed arrow says: the database must never reach
back into your rules.

#formulas(title: "SOLID — five rules, five smells")[
#table(columns: 3,
  align: (left, left, left),
  [*Letter*], [*The rule in one line*], [*The smell that triggers it*],
  [*S* — Single responsibility],
    [A class should have one reason to change.],
    [The class name has "and" in it, or two teams edit the same file.],
  [*O* — Open/closed],
    [Open to add new behaviour, closed to editing old code.],
    [A growing `if / else if` chain or `switch` on a type string.],
  [*L* — Liskov substitution],
    [A child must be usable wherever the parent is, with no surprise.],
    [An overridden method that throws, or does nothing, or asks "am I really a X?".],
  [*I* — Interface segregation],
    [Many small contracts beat one fat one.],
    [Half the methods of an implementation throw "not supported".],
  [*D* — Dependency inversion],
    [Rules depend on shapes; details plug into the shapes.],
    [The rules file imports a database driver.],
)
]

#trick[
In an interview, never recite the five names. Point at the code and say the *smell*:
"this `switch` grows every time marketing invents a coupon — that is the open/closed smell,
so I will hold the coupons in a map of small objects." One sentence, one fix, done.
]

#section[UML-lite: the only notation you need]

You do not need full UML. You need four arrows and a box. An interviewer who sees these
knows you have drawn a class diagram before.

#table(columns: 3,
  align: (left, left, left),
  [*Relationship*], [*Say it as*], [*How to draw it fast*],
  [Inheritance], [`Car` *is a* `Vehicle`], [plain arrow, child $arrow.r$ parent],
  [Implements an interface], [`Csv` *is a kind of* `Format`], [dashed arrow, class $arrow.r$ interface],
  [Composition (owns)], [`Bill` *owns* its `LineItem`s; kill the bill, the lines die], [solid arrow with `1..*` on it],
  [Association (uses)], [`Bill` *uses* a `DiscountRule` it did not create], [thin arrow, label `uses`],
)

A class box has three floors: the name, the fields, the methods. Only write the fields and
methods that matter to the question.

#diagram(height: 6.2cm, caption: "A class diagram for the food-court bill built later in this chapter. Dashed arrows mean 'is a kind of'.")[
  #dnode(130pt, 0pt,  100pt, 34pt, [*Bill* #linebreak() #text(size: 7.5pt)[billId, items, rules]], fill: rgb("#e6efe6"))
  #dnode(320pt, 0pt,  100pt, 34pt, [*LineItem* #linebreak() #text(size: 7.5pt)[name, unit, qty, tax]])
  #dnode(320pt, 78pt, 100pt, 30pt, [*Money* #linebreak() #text(size: 7.5pt)[paise, currency]])
  #dnode(110pt, 78pt, 130pt, 30pt, [*DiscountRule* #linebreak() #text(size: 7.5pt)[offPaise(base, items)]], fill: rgb("#f3efe2"))
  #dnode(0pt,   148pt, 92pt, 26pt, [PercentOff])
  #dnode(106pt, 148pt, 92pt, 26pt, [FlatOff])
  #dnode(212pt, 148pt, 92pt, 26pt, [MemberOff])
  #darrow(230pt, 16pt, 320pt, 16pt, label: "owns 1..*")
  #darrow(180pt, 34pt, 178pt, 78pt, label: "uses")
  #darrow(370pt, 34pt, 370pt, 78pt, label: "made of")
  #darrow(46pt,  148pt, 150pt, 108pt, dashed: true)
  #darrow(152pt, 148pt, 172pt, 108pt, dashed: true)
  #darrow(258pt, 148pt, 200pt, 108pt, dashed: true)
]

Read it out loud: "A bill owns one or more line items. A line item is made of money. A bill
uses discount rules; percent-off, flat-off and member-off are each a kind of discount rule."
That sentence is the whole design.

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
A `Ticket` class is needed for a cinema. Which of these belong as *fields* of `Ticket`,
and which do not? `seatNumber`, `showTime`, `pricePaise`, `theatreAddress`, `bookedBy`,
`totalSeatsInHall`.
]
#sol[
Ask one question per candidate: *does this change when the ticket changes?*

#table(columns: 3,
  align: (left, left, left),
  [*Field*], [*Belongs?*], [*Why*],
  [`seatNumber`], [yes], [different for every ticket],
  [`showTime`], [yes], [a ticket is for one show],
  [`pricePaise`], [yes], [what this buyer paid, frozen at purchase],
  [`theatreAddress`], [no], [belongs to `Theatre`; every ticket would carry a copy],
  [`bookedBy`], [yes], [who holds it],
  [`totalSeatsInHall`], [no], [belongs to `Hall`; nothing to do with one seat],
)
#ans[`seatNumber`, `showTime`, `pricePaise`, `bookedBy`. The other two are copies of another class's data.]
]

#ex(2, tier: 0)[
For each pair say *is-a* (inheritance) or *has-a* (composition):
(a) `Car` and `Engine`; (b) `SavingsAccount` and `Account`; (c) `Order` and `Address`;
(d) `Circle` and `Shape`; (e) `Playlist` and `Song`.
]
#sol[
The test: put the words in the sentence "every \_\_\_ is a \_\_\_". If it sounds silly, it is has-a.

- (a) "every car is an engine" — silly. A car *has an* engine. #sym.arrow composition.
- (b) "every savings account is an account" — true. #sym.arrow inheritance.
- (c) "every order is an address" — silly. An order *has a* delivery address. #sym.arrow composition.
- (d) "every circle is a shape" — true. #sym.arrow inheritance.
- (e) "every playlist is a song" — silly. A playlist *has many* songs. #sym.arrow composition.
#ans[is-a: (b), (d). has-a: (a), (c), (e).]
]

#ex(3, tier: 0)[
Run this in your head, then check. What are the three lines printed?

#code(lang: "js", caption: "dispatch.js — the part that surprises people")[
```js
class Fee {
  amount(orderPaise) { throw new Error('subclass must implement amount()'); }
  label() { return `${this.constructor.name} -> ${this.amount(100000)} paise`; }
}
class FlatFee    extends Fee { amount(_)          { return 2000; } }
class PercentFee extends Fee { amount(orderPaise) { return Math.round(orderPaise * 0.04); } }
class FreeFee    extends Fee { amount(_)          { return 0; } }

for (const f of [new FlatFee(), new PercentFee(), new FreeFee()]) {
  console.log(f.label());
}
```
]
]
#sol[
`label()` is written once, in the parent. It calls `this.amount(...)`. At run time `this` is
the real object, so a different `amount` runs each time. The parent never knew the children
existed.

#code(lang: "text", caption: "measured output of node dispatch.js")[
```text
FlatFee -> 2000 paise
PercentFee -> 4000 paise
FreeFee -> 0 paise
```
]
$100000 times 0.04 = 4000$, so `PercentFee` prints 4000.
#ans[One loop, three behaviours. That is polymorphism, and `label()` is the call site that never changes.]
]

#ex(4, tier: 0)[
JavaScript trap. What does this print, and what would Java print?

#code(lang: "js", caption: "Two methods with the same name")[
```js
class Router {
  go(a)    { return 'one arg'; }
  go(a, b) { return `two args: ${a},${b}`; }
}
console.log(new Router().go('x'));
```
]
]
#sol[
In JavaScript a class body is a list of property assignments. The second `go` *replaces* the
first. Only one `go` survives, and it is the two-argument one, called with `b` missing.

#code(lang: "text", caption: "measured output")[
```text
two args: x,undefined
```
]

*What the interviewer expects to hear about Java.* Java has real overloading: the two methods
have different *signatures*, both exist, and the compiler picks one by the argument list at
compile time. That choice is made from the *declared* type, not the runtime type. Overriding
is the opposite: chosen at run time from the real object.

#trap[
Overloading is resolved at *compile* time by the declared types. Overriding is resolved at
*run* time by the real object. Say this sentence exactly. It is the most-asked one-liner in
a service-company OOP round, and JavaScript cannot show it to you, because JavaScript has no
overloading at all.
]
#ans[JavaScript prints `two args: x,undefined`. JavaScript has no overloading; Java does, and resolves it at compile time.]
]

#ex(5, tier: 0)[
Which pillar is broken in each line?
(a) `order.status = 'PAID'` written from outside the `Order` class.
(b) A `Report` class with a public method `getMySqlConnection()`.
(c) `if (shape.type === 'circle') ... else if (shape.type === 'square') ...`
(d) `class Ostrich extends Bird { fly() { throw new Error('cannot fly'); } }`
]
#sol[
- (a) *Encapsulation.* The status rule (which changes are legal) lives outside the class now. Fix: `order.markPaid()`.
- (b) *Abstraction.* The caller is shown the machinery. Fix: expose `save()`, hide the connection.
- (c) *Polymorphism.* The call site must be edited for every new shape. Fix: `shape.area()`.
- (d) *Inheritance / Liskov.* The child breaks the parent's promise. Fix: `Bird` and `FlyingBird`.
#ans[(a) encapsulation (b) abstraction (c) polymorphism (d) inheritance]
]

#ex(6, tier: 0)[
Abstract class or interface? Pick one for each, and say why in one line.
(a) Every payment method must have `charge()`, and they share nothing else.
(b) Every report has the same three-step publish flow, but step 2 differs per report.
(c) A class needs to be both `Serializable` and `Comparable`.
]
#sol[
- (a) *Interface.* Nothing to share, only a shape to promise.
- (b) *Abstract class.* The shared flow is real code that lives in the parent; only step 2 is abstract. (This is the template method pattern — Chapter 4.)
- (c) *Interfaces.* A class can implement many interfaces, and in Java can extend only one class.

*What the interviewer expects to hear.* In Java: an interface holds no state and (before
default methods) no code; a class implements many interfaces but extends one class; an
abstract class may hold fields, a constructor, and finished methods. In JavaScript neither
keyword exists — you promise a shape by throwing from the base method, or by checking
`typeof obj.charge === 'function'`.
#ans[(a) interface (b) abstract class (c) interfaces]
]

#ex(7, tier: 0)[
Here are two wallets. One of them can be pushed into an illegal state from outside.
Which one, and what exactly does the program print?

#code(lang: "js", caption: "wallet.js")[
```js
class OpenWallet {            // no encapsulation
  constructor() { this.paise = 0; }
}

class SafeWallet {            // encapsulated with real private fields (#)
  #paise = 0;
  #spentToday = 0;

  add(amount) {
    if (amount <= 0) throw new Error('add must be > 0');
    this.#paise += amount;
  }
  spend(amount) {
    if (amount <= 0) throw new Error('spend must be > 0');
    if (amount > this.#paise) throw new Error('not enough money');
    this.#paise -= amount;
    this.#spentToday += amount;      // the two fields can never drift apart
  }
  get balance()    { return this.#paise; }
  get spentToday() { return this.#spentToday; }
}

const o = new OpenWallet();
o.paise = 5000;
o.paise = -900;                      // nothing stops this
console.log('OpenWallet balance =', o.paise);

const s = new SafeWallet();
s.add(5000);
s.spend(1200);
console.log('SafeWallet balance =', s.balance, 'spentToday =', s.spentToday);
try { s.spend(99999); } catch (e) { console.log('blocked:', e.message); }
s.paise = -900;                      // this does NOT touch #paise
console.log('outsider wrote s.paise =', s.paise);
console.log('real balance still     =', s.balance);
```
]
]
#sol[
#code(lang: "text", caption: "measured output of node wallet.js")[
```text
OpenWallet balance = -900
SafeWallet balance = 3800 spentToday = 1200
blocked: not enough money
outsider wrote s.paise = -900
real balance still     = 3800
```
]

Step by step for `SafeWallet`: `add(5000)` #sym.arrow balance 5000. `spend(1200)` #sym.arrow
balance $5000 - 1200 = 3800$ and `spentToday` 1200. `spend(99999)` is rejected because
$99999 > 3800$, so *both* fields stay untouched.

The last two lines are the JavaScript detail worth knowing. Writing `s.paise = -900` from
outside does not fail and does not touch `#paise`. It silently creates a brand new, unrelated
public property. The real balance is still 3800.

#trick[
Private fields written with `#` are the only truly private members in JavaScript. A leading
underscore (`_paise`) is a polite request, not a lock. Say this if asked how JavaScript does
`private`: "`#field` is enforced by the language; `_field` is a naming convention only."
]
#ans[`OpenWallet` can be corrupted. `SafeWallet` cannot — its balance stays 3800.]
]

#ex(8, tier: 0)[
Name the SOLID letter broken by each smell.
(a) `class UserServiceAndEmailer`
(b) `calculateFee()` has 31 `else if` branches, one per city.
(c) `class ReadOnlyList extends List { add(x) { throw new Error('read only'); } }`
(d) `interface Vehicle { drive(); fly(); sail(); }`
(e) `class ReportService { constructor() { this.db = new MySqlDriver(); } }`
]
#sol[
- (a) *S*. The name says two jobs. Two teams will fight over this file.
- (b) *O*. A 32nd city means editing a function that already works.
- (c) *L*. The child weakens a promise the parent made.
- (d) *I*. A truck must implement `fly()` and lie about it.
- (e) *D*. The rules class builds its own concrete driver, so it cannot be tested without MySQL.
#ans[(a) S (b) O (c) L (d) I (e) D]
]

#section[Tier 1 — low-level design]
#tier-header(1)

#ex(9, tier: 1, asked: "TCS NQT · pattern")[
*Single responsibility, done on real code.*
This class works. Marketing, the billing team, the database team and the design team all
edit it. Split it, and say how many reasons to change each new class has.

#code(lang: "js", caption: "before — one class, four reasons to change")[
```js
class InvoiceGod {
  constructor(id, lines) { this.id = id; this.lines = lines; }
  total()  { const s = this.lines.reduce((a, b) => a + b, 0); return s + Math.round(s * 0.18); }
  render() { return `Invoice ${this.id} payable=${this.total()}`; }   // screen team
  save()   { console.log('[sql] INSERT', this.id); }                  // db team
  email()  { console.log('[smtp] sent', this.id); }                   // comms team
}
```
]
]
#sol[
*Find the reasons to change, not the methods.* Ask: "who files the ticket that edits this
line?"

#table(columns: 2,
  align: (left, left),
  [*Line*], [*Who files the ticket*],
  [`0.18`], [finance, when GST changes],
  [`render()`], [the design team, when the layout changes],
  [`save()`], [the platform team, when the database changes],
  [`email()`], [the comms team, when the template changes],
)

Four filers, four classes.

#code(lang: "js", caption: "after — one reason to change each")[
```js
class Invoice {                         // the data and its own rule only
  constructor(id, linePaise) { this.id = id; this.linePaise = linePaise; }
}
class InvoiceTotal {                    // changes when the tax rule changes
  static GST_PERCENT = 18;
  of(inv) {
    const sum = inv.linePaise.reduce((a, b) => a + b, 0);
    return sum + Math.round(sum * InvoiceTotal.GST_PERCENT / 100);
  }
}
class InvoiceText {                     // changes when the layout changes
  constructor(totals) { this.totals = totals; }
  render(inv) {
    return `Invoice ${inv.id} lines=${inv.linePaise.length} payable=${this.totals.of(inv)}`;
  }
}
class InvoiceStore {                    // changes when the database changes
  #rows = new Map();
  save(inv) { this.#rows.set(inv.id, inv); return this.#rows.size; }
}

const inv = new Invoice('INV-7', [12000, 45000, 3000]);
const totals = new InvoiceTotal();
console.log('sum   =', 12000 + 45000 + 3000);
console.log('gst   =', Math.round(60000 * 0.18));
console.log('total =', totals.of(inv));
console.log(new InvoiceText(totals).render(inv));
console.log('stored rows =', new InvoiceStore().save(inv));
```
]

#code(lang: "text", caption: "measured output of node srp.js")[
```text
sum   = 60000
gst   = 10800
total = 70800
Invoice INV-7 lines=3 payable=70800
stored rows = 1
```
]

Check the arithmetic by hand: $12000 + 45000 + 3000 = 60000$ paise.
$60000 times 18 div 100 = 10800$. $60000 + 10800 = 70800$ paise $=$ Rs 708.00. #sym.checkmark

#trap[
Splitting is not free. Four classes mean four files and four names to remember. Split when
*two different people* have a reason to edit the same file — not because a class reached
50 lines. A 200-line class with one job is healthier than six 30-line classes with tangled
jobs.
]
#ans[Four classes: `Invoice` (data), `InvoiceTotal` (money rule), `InvoiceText` (layout), `InvoiceStore` (storage). One reason to change each.]
]

#ex(10, tier: 1, asked: "Infosys · pattern")[
*Open/closed, with the cost counted.*
A coupon function grows one `if` per campaign. Marketing ships 2 new coupons a month.
Rewrite it so a new coupon never edits an old line, then count how many lines change over
a year, both ways.
]
#sol[
#code(lang: "js", caption: "before — every new coupon edits this function")[
```js
function offBefore(code, orderPaise) {
  if (code === 'STUDENT') return Math.round(orderPaise * 0.10);
  if (code === 'FESTIVE') return Math.min(Math.round(orderPaise * 0.20), 15000);
  return 0;
}
```
]

#code(lang: "js", caption: "after — a registry of tiny rules")[
```js
const rules = new Map();
const register = (code, fn) => rules.set(code, fn);

register('NONE',    () => 0);
register('STUDENT', (p) => Math.round(p * 0.10));
register('FESTIVE', (p) => Math.min(Math.round(p * 0.20), 15000));
register('FIRST3',  (p) => (p >= 20000 ? 5000 : 0));          // new: nothing above changed

function off(code, orderPaise) {
  const rule = rules.get(code) ?? rules.get('NONE');
  return Math.min(rule(orderPaise), orderPaise);              // never below zero payable
}

const order = 90000;                                           // Rs 900.00 in paise
for (const code of rules.keys()) {
  const d = off(code, order);
  console.log(code.padEnd(8), 'off=', String(d).padStart(6), 'pay=', order - d);
}
console.log('unknown code falls back:', off('WHATEVER', order));
```
]

#code(lang: "text", caption: "measured output of node ocp.js")[
```text
NONE     off=      0 pay= 90000
STUDENT  off=   9000 pay= 81000
FESTIVE  off=  15000 pay= 75000
FIRST3   off=   5000 pay= 85000
unknown code falls back: 0
```
]

Hand-check `FESTIVE` on an order of 90000 paise: $90000 times 0.20 = 18000$, but the cap is
15000, and $min(18000, 15000) = 15000$. Payable $= 90000 - 15000 = 75000$ paise = Rs 750.00. #sym.checkmark

*Now count the cost over one year.* 2 coupons a month $times$ 12 months $= 24$ new coupons.

#table(columns: 4,
  align: (left, right, right, left),
  [], [*Lines added*], [*Lines edited*], [*Risk*],
  [`if` chain], [24], [24 (the function body)], [each edit can break the 23 live coupons],
  [registry], [24], [0], [a broken new rule cannot touch the old ones],
)

The function under test is edited 24 times in one version, and 0 times in the other. That is
the whole argument for open/closed, and it is an argument about *regression risk*, not beauty.

*Trade-off, and the decision.* The `if` chain is 4 lines shorter and you can read every
coupon in one screen. The registry costs one extra concept (a map of functions) and the
rules are now spread out. *Decision: use the registry.* The tipping point is about 4
branches; below that the `if` chain wins on readability, above that the regression risk
wins. This function was already at 3 and grows 24 a year, so it is far past the line.
#ans[Registry of small rule objects. Lines edited per new coupon drops from 24 a year to 0.]
]

#ex(11, tier: 1, asked: "Capgemini · pattern")[
*Liskov substitution, caught at run time.*
`GiftCard extends PrepaidCard` looks harmless. Run the caller and see what happens.

#code(lang: "js", caption: "lsp.js — the break")[
```js
class PrepaidCard {
  #paise = 0;
  // promise 1: after load(x), balance is exactly x higher
  load(x) { this.#paise += x; }
  // promise 2: after pay(x) with x <= balance, balance is exactly x lower
  pay(x)  { if (x > this.#paise) throw new Error('insufficient'); this.#paise -= x; }
  get balance() { return this.#paise; }
}

class GiftCard extends PrepaidCard {
  load(x) { /* "gift cards cannot be topped up" */ }   // breaks promise 1
}

function topUpAndSpend(card) {         // knows only the base class
  card.load(10000);
  try {
    card.pay(4000);
    console.log(card.constructor.name, 'balance =', card.balance);
  } catch (e) {
    console.log(card.constructor.name, 'CRASHED:', e.message);
  }
}
topUpAndSpend(new PrepaidCard());
topUpAndSpend(new GiftCard());
```
]
]
#sol[
#code(lang: "text", caption: "measured output of node lsp.js (first two lines)")[
```text
PrepaidCard balance = 6000
GiftCard CRASHED: insufficient
```
]

Trace it. For `PrepaidCard`: $0 + 10000 = 10000$, then $10000 - 4000 = 6000$. #sym.checkmark
For `GiftCard`: `load` does nothing, balance stays 0, so `pay(4000)` sees $4000 > 0$ and
throws. The caller never asked for a gift card. It asked for "a prepaid card" and got a
crash.

*The fix is to stop lying about the hierarchy.* Build the base around what is always true —
a card can be spent — and let a subclass only *add*.

#code(lang: "js", caption: "the fix: a subclass may only ADD, never weaken")[
```js
class Spendable {
  constructor(paise) { this._paise = paise; }        // subclasses may use it
  pay(x) { if (x > this._paise) throw new Error('insufficient'); this._paise -= x; }
  get balance() { return this._paise; }
}
class Reloadable extends Spendable {                 // adds load(); changes nothing else
  load(x) { this._paise += x; }
}

const gift = new Spendable(10000);                   // a gift card IS only spendable
gift.pay(4000);
console.log('gift  balance =', gift.balance, '| has load()?', typeof gift.load);

const wallet = new Reloadable(0);                    // spendable AND reloadable
wallet.load(10000);
wallet.pay(4000);
console.log('wallet balance =', wallet.balance, '| has load()?', typeof wallet.load);
```
]

#code(lang: "text", caption: "measured output")[
```text
gift  balance = 6000 | has load()? undefined
wallet balance = 6000 | has load()? function
```
]

#formulas(title: "The Liskov checklist you can run in your head")[
A child class is safe if, compared with the parent, it:
+ accepts *the same or wider* inputs (never narrower — no new "this argument is not allowed"),
+ returns *the same or narrower* outputs (never a surprise type, never `null` where the parent never returned `null`),
+ throws *no new kind* of exception the caller was not warned about,
+ leaves every promise about state that the parent made still true,
+ does not need the caller to know which subclass it holds.

Break any one of the five and you must use composition instead.
]
#ans[`GiftCard` breaks promise 1, so the caller crashes. Fix: `Spendable` base, `Reloadable` adds `load()`.]
]

#ex(12, tier: 1, asked: "Wipro · pattern")[
*Interface segregation.* Every office device implements `print`, `scan`, `fax`, `staple`.
A cheap printer can only print. Show what goes wrong, then fix it.
]
#sol[
#code(lang: "js", caption: "isp.js — the fat contract and the fix")[
```js
// ---------- BEFORE: one fat contract ----------
class OfficeMachine {                 // every device must implement all four
  print(doc)   { throw new Error('not supported'); }
  scan()       { throw new Error('not supported'); }
  fax(doc)     { throw new Error('not supported'); }
  staple(doc)  { throw new Error('not supported'); }
}
class CheapPrinter extends OfficeMachine {
  print(doc) { return `printed ${doc}`; }
  // scan / fax / staple inherited -> they throw. Callers cannot tell.
}

// ---------- AFTER: small contracts, mixed in only where true ----------
const CanPrint = (Base) => class extends Base { print(doc) { return `printed ${doc}`; } };
const CanScan  = (Base) => class extends Base { scan()     { return 'scan-0001.png'; } };
const CanFax   = (Base) => class extends Base { fax(doc)   { return `faxed ${doc}`; } };

class Device {}
class HomePrinter   extends CanPrint(Device) {}
class OfficeCombo   extends CanFax(CanScan(CanPrint(Device))) {}

const supports = (d, job) => typeof d[job] === 'function';

for (const d of [new CheapPrinter(), new HomePrinter(), new OfficeCombo()]) {
  const jobs = ['print', 'scan', 'fax'].filter((j) => supports(d, j));
  console.log(d.constructor.name.padEnd(13), 'claims:', jobs.join(','));
}
console.log('HomePrinter can scan?', supports(new HomePrinter(), 'scan'));
console.log('CheapPrinter can scan?', supports(new CheapPrinter(), 'scan'), '<- a lie');
```
]

#code(lang: "text", caption: "measured output of node isp.js")[
```text
CheapPrinter  claims: print,scan,fax
HomePrinter   claims: print
OfficeCombo   claims: print,scan,fax
HomePrinter can scan? false
CheapPrinter can scan? true <- a lie
```
]

Look at line 1 against line 2. The fat design makes `CheapPrinter` *claim* three abilities
it does not have. Any code that asks "can you scan?" gets `true` and then crashes at the
call. In the split design the question is answered honestly.

*What the interviewer expects to hear.* In Java you would declare three interfaces —
`Printer`, `Scanner`, `Fax` — and `class CheapPrinter implements Printer`. The compiler then
refuses to pass a `CheapPrinter` where a `Scanner` is wanted, so the lie is caught before the
program runs. JavaScript has no interfaces, so the same idea is expressed with mixins plus a
`typeof` check, and the lie is caught at run time instead.

*Trade-off, and the decision.* One fat base class is fewer files and one place to look. Three
small contracts mean more names but no false claims. *Decision: split.* The moment any
implementation is forced to write "not supported", the fat interface has already cost you a
production incident; the extra names are cheaper.
#ans[Split into `CanPrint` / `CanScan` / `CanFax`. The fat base makes classes claim abilities they do not have.]
]

#ex(13, tier: 1, asked: "Accenture · pattern")[
*Dependency inversion, and the payoff you can measure.*
`PlaceOrder` writes to Postgres and sends an SMS. Make it testable without a database and
without an SMS bill.
]
#sol[
The rule: *the use case names the shape it needs; the details plug in from outside.*

#code(lang: "js", caption: "dip.js")[
```js
class PlaceOrder {
  constructor({ orders, notifier, clock }) {
    this.orders = orders; this.notifier = notifier; this.clock = clock;
  }
  run(userId, paise) {
    if (paise <= 0) throw new Error('amount must be > 0');
    const id = `o-${this.clock()}`;
    this.orders.save({ id, userId, paise });
    this.notifier.send(userId, `Order ${id} placed for ${paise} paise`);
    return id;
  }
}

// ---- production adapters ----
class PostgresOrders { save(o) { console.log('[pg]  INSERT', o.id, o.userId, o.paise); } }
class SmsNotifier    { send(u, t) { console.log('[sms] ->', u, ':', t); } }

// ---- test doubles: no database, no SMS bill ----
class FakeOrders   { constructor() { this.rows = []; }  save(o) { this.rows.push(o); } }
class SpyNotifier  { constructor() { this.sent = []; }  send(u, t) { this.sent.push([u, t]); } }

new PlaceOrder({ orders: new PostgresOrders(), notifier: new SmsNotifier(), clock: () => 1001 })
  .run('u-1', 45000);

const orders = new FakeOrders(), notifier = new SpyNotifier();
const id = new PlaceOrder({ orders, notifier, clock: () => 2002 }).run('u-2', 45000);
console.log('test: id =', id, '| rows =', orders.rows.length, '| messages =', notifier.sent.length);
console.log('test: message text =', notifier.sent[0][1]);
```
]

#code(lang: "text", caption: "measured output of node dip.js")[
```text
[pg]  INSERT o-1001 u-1 45000
[sms] -> u-1 : Order o-1001 placed for 45000 paise
test: id = o-2002 | rows = 1 | messages = 1
test: message text = Order o-2002 placed for 45000 paise
```
]

Notice `clock` is injected too. A real `Date.now()` makes the test unrepeatable; a function
returning 2002 makes the order id predictable, so the test can assert on it.

*The payoff, in numbers.* Suppose a test that really talks to Postgres and a real SMS sandbox
takes 400 ms, and the in-memory version takes 0.4 ms. A suite of 600 such tests:

- with real adapters: $600 times 400 "ms" = 240{,}000 "ms" = 240$ seconds = 4 minutes.
- with fakes: $600 times 0.4 "ms" = 240 "ms" = 0.24$ seconds.

$240 div 0.24 = 1000$ times faster. A 4-minute suite gets run once before lunch. A quarter-second
suite gets run on every save. That change in habit is the real return on dependency inversion.

#trap[
Injection is not "pass everything in". If `PlaceOrder` also took `taxPercent`, `currency`,
`retryCount` and `logger` through the constructor, the wiring code becomes the new god class.
Inject the things that *touch the outside world* (database, network, clock, random) and
hard-code the things that are part of the rule.
]
#ans[Inject `orders`, `notifier` and `clock`. Tests use in-memory doubles and run about 1000 times faster.]
]

#ex(14, tier: 1, asked: "Cognizant · pattern")[
*Composition over inheritance, with the explosion counted.*
A report can be CSV, JSON or TSV; stored on disk or on S3; zipped or not. Build it with
inheritance, count the classes. Then build it with composition and count again.
]
#sol[
*With inheritance* you need one subclass per combination:
$3 "formats" times 2 "stores" times 2 "zip options" = 12$ subclasses, named things like
`JsonS3GzipReport`. Add a 4th format and you need $4 times 2 times 2 = 16$ — four new classes
for one new idea.

*With composition* you need one small class per independent choice:
$3 + 2 + 2 = 7$ classes, and you *combine* them at run time. Add a 4th format and you write
*one* class; the count goes to 8 and covers all 16 combinations.

#code(lang: "js", caption: "compose.js")[
```js
class Csv  { render(rows) { return rows.join(','); } }
class Json { render(rows) { return JSON.stringify(rows); } }
class Tsv  { render(rows) { return rows.join('\t'); } }

class Disk { put(name, body) { return `disk/${name} (${body.length}B)`; } }
class S3   { put(name, body) { return `s3://reports/${name} (${body.length}B)`; } }

class NoZip  { pack(s) { return s; } }
class FakeGz { pack(s) { return s.slice(0, Math.ceil(s.length / 2)); } }   // pretend 2x

class Report {                       // HAS-A format, HAS-A zip, HAS-A store
  constructor(format, zip, store) { this.format = format; this.zip = zip; this.store = store; }
  publish(name, rows) { return this.store.put(name, this.zip.pack(this.format.render(rows))); }
}

const rows = ['seat=A12', 'seat=B07', 'seat=C03'];
let n = 0;
for (const f of [new Csv(), new Json(), new Tsv()])
  for (const z of [new NoZip(), new FakeGz()])
    for (const s of [new Disk(), new S3()]) {
      n++;
      if (n <= 4 || n === 12) console.log(String(n).padStart(2), new Report(f, z, s).publish('r', rows));
    }
console.log('combinations built =', n, 'from classes =', 3 + 2 + 2);
```
]

#code(lang: "text", caption: "measured output of node compose.js")[
```text
 1 disk/r (26B)
 2 s3://reports/r (26B)
 3 disk/r (13B)
 4 s3://reports/r (13B)
12 s3://reports/r (13B)
combinations built = 12 from classes = 7
```
]

The CSV body is `seat=A12,seat=B07,seat=C03` $= 26$ bytes. The fake zip keeps
$ceil(26 div 2) = 13$ bytes. #sym.checkmark

#table(columns: 4,
  align: (left, right, right, right),
  [*Design*], [*3 formats*], [*4 formats*], [*classes per new format*],
  [inheritance], [12], [16], [4],
  [composition], [7], [8], [1],
)

*Trade-off, and the decision.* Inheritance gives one concrete name per behaviour, which is
easy to read in a stack trace. Composition needs the caller to assemble three pieces, which
is one more line at every construction site. *Decision: composition,* and it is not close —
the multiply in $3 times 2 times 2$ is what kills inheritance here. Use inheritance only when
the axes do not multiply, that is, when there is genuinely one axis of variation.

#trick[
Count the *axes of variation* out loud. One axis #sym.arrow inheritance is fine.
Two or more axes that can be combined freely #sym.arrow composition, always. This sentence
alone will carry you through most "inheritance vs composition" follow-ups.
]
#ans[12 subclasses vs 7 small classes; adding a format costs 4 classes vs 1. Choose composition.]
]

#ex(15, tier: 1, asked: "TCS Digital · pattern")[
*Value objects and money.* Why is `pricePaise` an integer and not `price = 125.50`?
Write a `Money` class that cannot be corrupted.
]
#sol[
#code(lang: "js", caption: "money.js")[
```js
class Money {
  static of(paise, currency) { return new Money(paise, currency); }
  constructor(paise, currency) {
    if (!Number.isInteger(paise)) throw new Error('paise must be a whole number');
    this.paise = paise; this.currency = currency;
    Object.freeze(this);                       // no field can ever change again
  }
  plus(o) {
    if (o.currency !== this.currency)
      throw new Error(`cannot add ${o.currency} to ${this.currency}`);
    return new Money(this.paise + o.paise, this.currency);   // a NEW object
  }
  times(n) { return new Money(Math.round(this.paise * n), this.currency); }
  get key() { return `${this.currency}:${this.paise}`; }
  equals(o) { return o instanceof Money && o.key === this.key; }
  toString() { return `${this.currency} ${(this.paise / 100).toFixed(2)}`; }
}
```
]

#code(lang: "text", caption: "measured output of node money.js")[
```text
INR 125.50 + INR 44.50 = INR 170.00
a unchanged: INR 125.50
equal by value: true
18% GST on 60000 paise = INR 108.00
blocked: cannot add SGD to INR
0.1 + 0.2 = 0.30000000000000004 | equals 0.3? false
```
]

The last line is the answer to the question. A JavaScript number is a 64-bit float. It cannot
hold $0.1$ exactly, so $0.1 + 0.2$ lands on $0.30000000000000004$ and the equality check is
false. Money in floats drifts by fractions of a paisa, and a ledger that adds a million rows
ends up visibly wrong. Store the smallest unit as an integer — paise, cents, satang — and
divide only when printing.

Check the GST line: $60000 times 0.18 = 10800$ paise = Rs 108.00. #sym.checkmark

#formulas(title: "What makes a class a VALUE OBJECT")[
+ It has no identity of its own. Two `Money(17000, "INR")` are the same thing.
+ It is *immutable*: `Object.freeze` in the constructor, and every operation returns a new object.
+ Equality is by *value*, not by reference — give it a `key` getter and compare keys.
+ It validates itself in the constructor, so an invalid one can never exist.

Money, Date range, Coordinates, Email address, Seat number. Make these value objects and a
whole family of bugs disappears.
]
#ans[Floats cannot hold money exactly ($0.1 + 0.2 != 0.3$). Store integer paise in a frozen `Money` value object.]
]

#ex(16, tier: 1, asked: "Cognizant · pattern")[
*The identity trap that costs a booking.*
A seat is `{ row: 'A', number: 12 }`. It is used as a key in a `Map`. Predict the output.

#code(lang: "js", caption: "keybug.js")[
```js
const seatA = { row: 'A', number: 12 };

const m = new Map();
m.set(seatA, 'rishabh');
console.log('same object   ->', m.get(seatA));
console.log('equal copy    ->', m.get({ row: 'A', number: 12 }));

const obj = {};
obj[seatA] = 'rishabh';
obj[{ row: 'B', number: 7 }] = 'aisha';
console.log('object keys   ->', Object.keys(obj), '| stored count =', Object.keys(obj).length);
```
]
]
#sol[
#code(lang: "text", caption: "measured output of node keybug.js")[
```text
same object   -> rishabh
equal copy    -> undefined
object keys   -> [ '[object Object]' ] | stored count = 1
by value key  -> rishabh
frozen write  -> A
```
]

Two separate disasters here.

*Disaster 1 — `Map` matches objects by identity.* `m.get({row:'A',number:12})` builds a brand
new object. It has the same contents but it is a different object, so the `Map` says
`undefined`. Every request that rebuilds the seat from JSON gets a miss, and the seat looks
free when it is booked.

*Disaster 2 — a plain object stringifies its keys.* `obj[seatA]` becomes
`obj["[object Object]"]`. So does `obj[{row:'B',number:7}]`. Two different seats collide onto
one key and the second silently overwrites the first. One entry survives out of two.

*The fix: give the value object one string identity, and key on that.*

#code(lang: "js", caption: "the fix")[
```js
class Seat {
  constructor(row, number) { this.row = row; this.number = number; Object.freeze(this); }
  get key() { return `${this.row}#${this.number}`; }
  equals(o) { return o instanceof Seat && o.key === this.key; }
}
const booked = new Map();
booked.set(new Seat('A', 12).key, 'rishabh');
console.log('by value key  ->', booked.get(new Seat('A', 12).key));
```
]

*What the interviewer expects to hear about Java.* Java solves this with the
`equals` / `hashCode` contract. If you override `equals`, you must override `hashCode`, and
two objects that are `equals` must return the same `hashCode`. A `HashMap` first finds the
bucket by `hashCode`, then compares with `equals`. Override only `equals` and the map looks
in the wrong bucket, so it never finds the entry. And if you *mutate* a key after putting it
in the map, its hash changes, the entry stays in the old bucket, and it becomes unreachable
for ever — the map reports size 1 while every lookup returns null.

#trap[
The universal rule, in every language: *a key must be immutable.* Freeze the value object.
If you cannot freeze it, copy it before using it as a key.
]
#ans[`undefined` for the equal copy, and 1 surviving key `'[object Object]'`. Key on a derived string; freeze the value object.]
]

#ex(17, tier: 1, asked: "Infosys · pattern")[
*Replace a status `switch` with behaviour on the type.*
Orders have statuses `NEW`, `PACKED`, `SHIPPED`, `DELIVERED`, `CANCELLED`. Four different
functions each `switch` on the status. Show the design that removes all four switches.
]
#sol[
Put the behaviour *next to* the status, not in the callers.

#code(lang: "js", caption: "one table, no switches")[
```js
const STATUS = {
  NEW:       { next: ['PACKED', 'CANCELLED'], canRefund: true,  label: 'Order placed' },
  PACKED:    { next: ['SHIPPED', 'CANCELLED'], canRefund: true,  label: 'Packed' },
  SHIPPED:   { next: ['DELIVERED'],            canRefund: false, label: 'On the way' },
  DELIVERED: { next: [],                       canRefund: false, label: 'Delivered' },
  CANCELLED: { next: [],                       canRefund: false, label: 'Cancelled' },
};

class Order {
  #status = 'NEW';
  get status() { return this.#status; }
  get label()  { return STATUS[this.#status].label; }
  get canRefund() { return STATUS[this.#status].canRefund; }
  moveTo(next) {
    if (!STATUS[this.#status].next.includes(next))
      throw new Error(`illegal move ${this.#status} -> ${next}`);
    this.#status = next;
  }
}
```
]

Now `moveTo`, `label` and `canRefund` all read the same table. Adding a status `RETURNED`
means adding one row and listing it in `DELIVERED.next`. No caller changes.

*Count the saving.* Suppose the status appears in 4 switches, each with 5 branches. Adding a
status by hand means $4 times 1 = 4$ edits, in 4 files, each of which must be found first.
With the table it is 1 edit in 1 file. And a forgotten branch in a `switch` fails silently
(falls through to `default`); a missing table row throws immediately.
#ans[One `STATUS` table holding `next`, `canRefund`, `label`. Four switches become four table reads.]
]

#subsection[Tier 1 design — the food-court bill]

This is a full design, walked through all seven steps. Keep the steps in this order in a real
interview; it is the order the interviewer is taking notes in.

#ex(18, tier: 1, asked: "TCS NQT · pattern")[
*Design the classes for a food-court bill.* Items with tax, one or more discounts, and an
equal split between friends. No database.
]
#sol[
*Step 1 — Clarify.* Ask these four, and know why each changes the design.

#table(columns: 2,
  align: (left, left),
  [*Question*], [*Why it changes the design*],
  [Is tax per item or per bill?], [Per item means tax lives on `LineItem`; per bill means one number on `Bill`. Food courts tax per item (5% food, 18% packaged), so it goes on the item.],
  [Can discounts stack?], [If yes I need a *list* of rules and an order of application, not one field.],
  [Is discount applied before or after tax?], [Different totals. I will apply it after tax on the subtotal, and say so.],
  [Do splits have to be exact to the paisa?], [Yes — otherwise the total collected does not match the bill. This forces an explicit "who gets the leftover paise" rule.],
)

*Step 2 — Scale estimate.* A single food court, 40 counters, lunch rush 12:00 to 14:00.
Say 900 bills in that 2-hour window.

$900 "bills" div (2 times 3600 "s") = 900 div 7200 = 0.125$ bills per second.

Each bill has at most 20 items. So the peak work is
$0.125 times 20 = 2.5$ line-item computations per second. This is *nothing*. The design can
be as object-heavy as it likes; there is no performance question here at all. Saying this out
loud — "the scale is 0.125 writes per second, so I will optimise purely for clarity" — is
worth marks, because it shows you check before you optimise.

*Step 3 — API surface.* For an LLD problem the "API" is the public methods.

#table(columns: 3,
  align: (left, left, left),
  [*Call*], [*Arguments*], [*Returns*],
  [`bill.add(item)`], [a `LineItem`], [the bill, so calls chain],
  [`bill.apply(rule)`], [any object with `offPaise(base, items)`], [the bill],
  [`bill.subtotal`], [—], [integer paise before tax],
  [`bill.tax`], [—], [integer paise of tax],
  [`bill.discount`], [—], [integer paise, never more than the subtotal],
  [`bill.payable`], [—], [`subtotal + tax - discount`],
  [`bill.splitEqually(n)`], [`n` payers], [an array of `n` integers that sums to `payable`],
)

*Step 4 — Data model.* No database, so this is the field list.

#table(columns: 3,
  align: (left, left, left),
  [*Class*], [*Fields*], [*Key / invariant*],
  [`LineItem`], [`name`, `unitPaise`, `qty`, `taxPercent`], [frozen; `subtotal` and `tax` are derived, never stored],
  [`Bill`], [`billId`, private `#items`, private `#discounts`], [key is `billId`; `#items` is private so nobody can push a raw object in],
  [`DiscountRule`], [—], [any object with `offPaise(base, items)`],
)

*Step 5 — Diagram.* See the class diagram earlier in this chapter: `Bill` owns `1..*`
`LineItem`, uses `0..*` `DiscountRule`, and `PercentOff` / `FlatOff` / `MemberOff` are each a
kind of `DiscountRule`.

*Step 6 — Deep dive: the leftover paisa.*
This is the genuinely hard part, and interviewers do push on it. $41920 div 3 = 13973.33...$,
which is not a whole number of paise. If every share is rounded the same way the collected
total will not equal the bill.

- Round each share up: $ceil(13973.33) = 13974$, and $13974 times 3 = 41922$. You collect 2 paise too much.
- Round each share down: $floor(13973.33) = 13973$, and $13973 times 3 = 41919$. You are 1 paisa short.
- *The fix:* give everyone the floor, then hand the remainder to payer 1.
  $41920 - 13973 times 3 = 41920 - 41919 = 1$, so payer 1 pays $13973 + 1 = 13974$.
  The shares are $[13974, 13973, 13973]$ and they sum to exactly 41920. #sym.checkmark

#code(lang: "js", caption: "bill.js — the whole design, runnable")[
```js
class LineItem {
  constructor(name, unitPaise, qty, taxPercent) {
    Object.assign(this, { name, unitPaise, qty, taxPercent });
    Object.freeze(this);
  }
  get subtotal() { return this.unitPaise * this.qty; }
  get tax()      { return Math.round(this.subtotal * this.taxPercent / 100); }
}

class Bill {
  #items = [];
  #discounts = [];
  constructor(billId) { this.billId = billId; }
  add(item)   { this.#items.push(item); return this; }
  apply(rule) { this.#discounts.push(rule); return this; }

  get subtotal() { return this.#items.reduce((s, i) => s + i.subtotal, 0); }
  get tax()      { return this.#items.reduce((s, i) => s + i.tax, 0); }
  get discount() {
    const base = this.subtotal;
    return Math.min(this.#discounts.reduce((s, r) => s + r.offPaise(base, this.#items), 0), base);
  }
  get payable()  { return this.subtotal + this.tax - this.discount; }

  splitEqually(n) {
    const each = Math.floor(this.payable / n);
    const shares = new Array(n).fill(each);
    shares[0] += this.payable - each * n;          // the leftover paise go to payer 1
    return shares;
  }
  print() {
    for (const i of this.#items)
      console.log(`  ${i.name.padEnd(12)} ${i.qty} x ${i.unitPaise} = ${String(i.subtotal).padStart(6)} tax ${i.tax}`);
    console.log('  subtotal', this.subtotal, '| tax', this.tax, '| discount', this.discount,
                '| PAYABLE', this.payable);
  }
}

const FlatOff    = (p) => ({ offPaise: () => p });
const PercentOff = (pct, capPaise) => ({ offPaise: (base) => Math.min(Math.round(base * pct / 100), capPaise) });

const bill = new Bill('B-1')
  .add(new LineItem('Dosa', 12000, 2, 5))
  .add(new LineItem('Filter Cof', 4000, 3, 5))
  .add(new LineItem('Ice Cream', 9000, 1, 18))
  .apply(PercentOff(10, 5000))
  .apply(FlatOff(2000));

bill.print();
console.log('split 3 ways:', bill.splitEqually(3), 'sum =',
            bill.splitEqually(3).reduce((a, b) => a + b, 0));
```
]

#code(lang: "text", caption: "measured output of node bill.js")[
```text
  Dosa         2 x 12000 =  24000 tax 1200
  Filter Cof   3 x 4000 =  12000 tax 600
  Ice Cream    1 x 9000 =   9000 tax 1620
  subtotal 45000 | tax 3420 | discount 6500 | PAYABLE 41920
split 3 ways: [ 13974, 13973, 13973 ] sum = 41920
```
]

Every number checked by hand:
- Dosa: $12000 times 2 = 24000$; tax $= "round"(24000 times 5 div 100) = 1200$.
- Coffee: $4000 times 3 = 12000$; tax $= "round"(12000 times 5 div 100) = 600$.
- Ice cream: $9000 times 1 = 9000$; tax $= "round"(9000 times 18 div 100) = 1620$.
- Subtotal $= 24000 + 12000 + 9000 = 45000$. Tax $= 1200 + 600 + 1620 = 3420$.
- `PercentOff(10, 5000)`: $45000 times 10 div 100 = 4500$, and $min(4500, 5000) = 4500$.
- `FlatOff(2000)`: 2000. Total discount $= 4500 + 2000 = 6500$, and $6500 < 45000$ so no clamp.
- Payable $= 45000 + 3420 - 6500 = 41920$ paise = Rs 419.20. #sym.checkmark

*Step 7 — Trade-offs, failure modes, and 10x.*

#table(columns: 3,
  align: (left, left, left),
  [*Choice*], [*The other option*], [*Decision and why*],
  [Discounts as a *list* of rule objects],
    [one `discountPaise` field on the bill],
    [*List.* The clarify step said discounts stack. One field cannot hold two campaigns, and the moment it has to, the field becomes a `switch`.],
  [Derived getters (`subtotal` computed each time)],
    [store the totals as fields],
    [*Derive.* At 0.125 bills per second recomputation is free, and a stored total can go stale the instant an item is added. Store totals only after the bill is *paid* and frozen.],
  [Discount applied *after* tax],
    [before tax],
    [*After tax*, and printed on the bill. Either is defensible; what loses marks is not saying which one you chose.],
  [Leftover paise to payer 1],
    [spread them round-robin],
    [*Payer 1.* It is one line and always correct. Round-robin is fairer but needs state about who paid last — not worth it for a maximum of $n - 1$ paise.],
)

*Failure modes.*
+ A discount larger than the bill. Guarded: `Math.min(..., base)` clamps it, so `payable` can never go negative.
+ A rule that throws. Today one bad rule kills the whole bill. At 10x I would wrap each `offPaise` call in a try/catch, count it as zero, and log the rule name.
+ `qty` of 0 or a negative price. Not guarded yet — add the checks to the `LineItem` constructor so a bad item can never exist.

*At 10x (a chain of 400 food courts, central billing).* The class design does not change; the
wiring does. `Bill` becomes a domain object saved through a `BillStore` port, the discount
rules move into a registry loaded from config, and `billId` gets a prefix per outlet so two
outlets can never mint the same id.
#ans[`LineItem` (frozen, derives its own tax) + `Bill` (owns items, uses a list of rules) + rule objects. Leftover paise go to payer 1 so the shares sum exactly.]
]

#section[Tier 2 — the same OOP inside a real service]
#tier-header(2)

At Tier 2 the classes are the same. What changes is that the object now runs a few thousand
times a second, several teams touch it, and the cost of a bad boundary is measured in
incidents instead of in ugliness.

#ex(19, tier: 2, asked: "Grab · pattern")[
*Design the pricing module inside a food-delivery service.* Base fare, distance fee, surge,
packing, platform fee, and promotions, for an app with 4 million daily active users.
Walk all seven steps.
]
#sol[
*Step 1 — Clarify.*

#table(columns: 2,
  align: (left, left),
  [*Question*], [*Why it changes the design*],
  [Is the price shown on the list screen the same price that is charged?], [If yes, I must *freeze* the quote and store it; if no, I need a re-price step at checkout and a rule for what to do when it moves.],
  [How often do the fee rules change?], [Daily means the rules must be config, not code. Quarterly means code is fine.],
  [Who owns surge — this team or a pricing team?], [If another team owns it, surge must be a port with a timeout and a fallback value, not an in-process calculation.],
  [Must the same order re-price to the same number if the request is retried?], [Yes. That forces a quote id and an idempotency rule, which is step 6.],
)

*Step 2 — Scale estimate.* Show the arithmetic.

- 4,000,000 daily active users.
- Each opens the app 3 times a day: $4{,}000{,}000 times 3 = 12{,}000{,}000$ sessions/day.
- Each session shows a list of 20 restaurant cards, and every card shows a delivery fee:
  $12{,}000{,}000 times 20 = 240{,}000{,}000$ price calculations per day.
- Average: $240{,}000{,}000 div 86{,}400 = 2{,}778$ price calculations per second.
- Peak is about 3x the average (lunch and dinner): $2{,}778 times 3 = 8{,}334$ per second.

Now the important second calculation — *does the object design cost anything at that rate?*
Measured on this machine:

#code(lang: "js", caption: "bench.js — the real cost of a polymorphic call")[
```js
const N = 10_000_000;
function hardCoded(meters, seconds) {            // no polymorphism at all
  return 3000 + Math.floor(meters * 12 / 1000) * 100 + seconds * 2;
}
class BikeFare { paise(m, s) { return 3000 + Math.floor(m * 12 / 1000) * 100 + s * 2; } }
class CarFare  { paise(m, s) { return 5000 + Math.floor(m * 18 / 1000) * 100 + s * 3; } }
const pool = [new BikeFare(), new CarFare()];

let sink = 0;
let t0 = process.hrtime.bigint();
for (let i = 0; i < N; i++) sink += hardCoded(i % 9000, i % 700);
let t1 = process.hrtime.bigint();
for (let i = 0; i < N; i++) sink += pool[i & 1].paise(i % 9000, i % 700);
let t2 = process.hrtime.bigint();

const ms = (a, b) => Number(b - a) / 1e6;
console.log('direct call     :', ms(t0, t1).toFixed(0), 'ms for', N, 'calls');
console.log('method on object:', ms(t1, t2).toFixed(0), 'ms for', N, 'calls');
console.log('ns per method call =', (Number(t2 - t1) / N).toFixed(1));
```
]

#code(lang: "text", caption: "measured output of node bench.js")[
```text
direct call     : 64 ms for 10000000 calls
method on object: 69 ms for 10000000 calls
ns per method call = 6.9
(sink = 206210975000 )
```
]

A polymorphic call costs about 7 nanoseconds. Put that against the day's work:

$240{,}000{,}000 times 7 "ns" = 1{,}680{,}000{,}000 "ns" = 1.68$ seconds of CPU *for the
whole day*.

And against one database round trip of 2 ms:
$2 "ms" = 2{,}000{,}000 "ns"$, and $2{,}000{,}000 div 7 approx 285{,}714$.
*One* database call costs as much as 285,714 polymorphic calls.

#trick[
Memorise this comparison. When an interviewer asks "isn't all this indirection slow?", the
answer is: "a virtual call is about 7 ns; one database round trip is 2 ms, which is 285,000
of them. I will spend the 7 ns and save the round trip." That is a numbers answer, not an
opinion.
]

*Step 3 — API surface.*

#code(lang: "text", caption: "the two endpoints")[
```text
POST /v1/quotes
  { "userId":"u-77", "restaurantId":"r-12", "dropLat":12.97, "dropLng":77.59,
    "items":[{"sku":"s-1","qty":2}], "promoCode":"FIRST3" }
->201 { "quoteId":"q-8f3a", "basePaise":24000, "lines":[
          {"type":"DISTANCE","paise":4000}, {"type":"SURGE","paise":12000},
          {"type":"PACKING","paise":600},   {"type":"PLATFORM","paise":500},
          {"type":"PROMO","paise":-5000}],
        "totalPaise":36100, "expiresAt":"2026-09-15T12:05:00Z" }

POST /v1/orders
  { "quoteId":"q-8f3a", "idempotencyKey":"u-77:cart-3:1757937600" }
->201 { "orderId":"o-55231", "chargedPaise":36100 }
-> 409 if the quote has expired, with a fresh quote in the body
```
]

Two things to point at while drawing this. The quote returns *every line*, not just a total,
because a customer who cannot see why they are paying Rs 361 will call support. And the quote
has an `expiresAt`, which is what makes surge safe to show.

*Step 4 — Data model.*

#table(columns: 4,
  align: (left, left, left, left),
  [*Table*], [*Key*], [*Fields*], [*Why*],
  [`quotes`], [`quote_id`], [`user_id`, `restaurant_id`, `lines_json`, `total_paise`, `created_at`, `expires_at`], [written once, read once, then dead. Give it a 24-hour TTL.],
  [`fee_rules`], [`(rule_type, city_id, version)`], [`params_json`, `active_from`, `active_to`], [versioned, so an old quote can be explained months later],
  [`orders`], [`order_id`], [`quote_id`, `idempotency_key` (unique), `charged_paise`, `status`], [the unique index on `idempotency_key` is what stops a double charge],
)

Sizing the `quotes` table: only about 1 quote in 20 becomes an order, and quotes are written
at checkout, not per card. Say 2,000,000 quotes/day at 400 bytes each:
$2{,}000{,}000 times 400 = 800{,}000{,}000$ bytes $= 0.8$ GB/day. With a 24-hour TTL the table
never grows past about 0.8 GB. Without the TTL it would be
$0.8 times 365 = 292$ GB a year for data nobody reads.

*Step 5 — Architecture diagram.*

#diagram(height: 6.4cm, caption: "The pricing module. Everything inside the dashed area is pure computation with no I/O — that is what makes it fast and testable.")[
  #dnode(0pt,   54pt, 74pt, 34pt, [Mobile app])
  #dnode(96pt,  54pt, 78pt, 34pt, [Quote API])
  #dnode(206pt, 0pt,  96pt, 30pt, [FeeRegistry], fill: rgb("#f3efe2"))
  #dnode(206pt, 44pt, 96pt, 30pt, [PriceEngine], fill: rgb("#e6efe6"))
  #dnode(206pt, 88pt, 96pt, 30pt, [PromoEngine], fill: rgb("#e6efe6"))
  #dnode(206pt, 132pt, 96pt, 30pt, [Money / Quote], fill: rgb("#e6efe6"))
  #dnode(346pt, 0pt,  110pt, 30pt, [Surge service #linebreak() #text(size: 7pt)[port + timeout]])
  #dnode(346pt, 44pt, 110pt, 30pt, [Rules config #linebreak() #text(size: 7pt)[cached 60 s]])
  #dnode(346pt, 88pt, 110pt, 30pt, [Quote store #linebreak() #text(size: 7pt)[TTL 24 h]])
  #darrow(74pt, 71pt, 96pt, 71pt)
  #darrow(174pt, 66pt, 206pt, 59pt, label: "price()")
  #darrow(254pt, 74pt, 254pt, 88pt)
  #darrow(254pt, 118pt, 254pt, 132pt)
  #darrow(254pt, 30pt, 254pt, 44pt)
  #darrow(302pt, 15pt, 346pt, 15pt)
  #darrow(302pt, 59pt, 346pt, 59pt)
  #darrow(302pt, 103pt, 346pt, 103pt)
  #place(dx: 196pt, dy: 36pt)[#block(width: 116pt, height: 132pt, stroke: (paint: rgb("#2f6b3f"), thickness: 0.8pt, dash: "dashed"), radius: 3pt)[]]
  #place(dx: 198pt, dy: 172pt)[#text(size: 7.5pt, fill: rgb("#2f6b3f"))[no I/O in here]]
]

*Step 6 — Deep dive 1: strategy objects in code, or fee rules in a config table?*

This is the real design question and the interviewer will push on it.

#table(columns: 3,
  align: (left, left, left),
  [], [*Rules as code objects*], [*Rules as rows in a table*],
  [New fee type], [a deploy], [an insert, live in 60 s],
  [Change a number], [a deploy], [an update, live in 60 s],
  [Can be unit tested], [yes, fully], [only the interpreter can be tested],
  [A bad rule], [caught by tests and types], [reaches production instantly],
  [Reading the code later], [the rule is right there], [you must query the database to know what runs],
)

*Decision: both, split by what actually changes.* The *shape* of a fee (how distance fee is
computed from kilometres) is code — a small class registered in `FeeRegistry`. The *numbers*
inside it (paise per km, the cap, the city it applies to) are rows in `fee_rules`, cached for
60 seconds. This is the split that matches reality: finance changes numbers weekly and
engineering adds fee *types* about twice a year. Putting numbers in code means a deploy per
price change; putting shapes in the database means a home-made programming language inside
your own tables, which is the worst outcome of the two.

#code(lang: "js", caption: "registry.js — shapes in code, numbers injected")[
```js
class FeeRegistry {
  #byType = new Map();
  register(type, calculator) {
    if (this.#byType.has(type)) throw new Error(`duplicate fee type: ${type}`);
    for (const m of ['name', 'paise']) {
      if (typeof calculator[m] !== 'function')
        throw new Error(`${type} is missing ${m}()`);          // fail at boot, not at 2 a.m.
    }
    this.#byType.set(type, calculator);
    return this;
  }
  quote(type, order) {
    const c = this.#byType.get(type);
    if (!c) throw new Error(`no fee calculator for ${type}`);
    return { type, name: c.name(), paise: c.paise(order) };
  }
  get types() { return [...this.#byType.keys()]; }
}

const reg = new FeeRegistry()
  .register('PLATFORM', { name: () => 'Platform fee',  paise: () => 500 })
  .register('DISTANCE', { name: () => 'Distance fee',  paise: (o) => Math.ceil(o.km) * 800 })
  .register('SURGE',    { name: () => 'Surge',         paise: (o) => Math.round(o.base * (o.surge - 1)) })
  .register('PACKING',  { name: () => 'Packing',       paise: (o) => o.items * 200 });

const order = { base: 24000, km: 4.3, items: 3, surge: 1.5 };
let total = order.base;
for (const t of reg.types) {
  const q = reg.quote(t, order);
  total += q.paise;
  console.log(q.type.padEnd(9), q.name.padEnd(14), String(q.paise).padStart(6));
}
console.log('TOTAL'.padEnd(24), String(total).padStart(6), 'paise = Rs', (total / 100).toFixed(2));

try { reg.register('SURGE', { name: () => 'x', paise: () => 0 }); }
catch (e) { console.log('boot check:', e.message); }
try { reg.register('TIP', { name: () => 'Tip' }); }
catch (e) { console.log('boot check:', e.message); }
```
]

#code(lang: "text", caption: "measured output of node registry.js")[
```text
PLATFORM  Platform fee      500
DISTANCE  Distance fee     4000
SURGE     Surge           12000
PACKING   Packing           600
base                      24000
TOTAL                     41100 paise = Rs 411.00
boot check: duplicate fee type: SURGE
boot check: TIP is missing paise()
```
]

Every line checked: distance $= ceil(4.3) times 800 = 5 times 800 = 4000$.
Surge $= "round"(24000 times (1.5 - 1)) = 12000$. Packing $= 3 times 200 = 600$.
Total $= 24000 + 500 + 4000 + 12000 + 600 = 41100$ paise. #sym.checkmark

The two `boot check` lines are the part worth pointing at. The registry refuses a duplicate
type and refuses an incomplete calculator *at start-up*. That is how you get interface
safety in a language with no interfaces: check the shape once, at boot, and crash loudly
rather than at 2 a.m. under load.

*Step 6 — Deep dive 2: the same request priced twice.*

The app retries on a timeout. Surge moved between the two tries. Now the customer sees
Rs 361 and is charged Rs 395.

The fix has two halves and both are object design:
+ *Freeze the quote.* `PriceEngine` returns an immutable `Quote` with a `quoteId` and an
  `expiresAt`. Checkout charges `quote.totalPaise`, never a recomputation. Price can only
  move when the customer asks for a new quote.
+ *Make the order idempotent.* `POST /v1/orders` carries an `idempotencyKey` built by the
  client from `userId + cartId + minute`. A unique index on that column means the second
  attempt fails the insert, and the handler returns the *existing* order instead of a new
  one. The database, not the application, is what guarantees this.

What if the quote has expired? Return `409` with a fresh quote in the body, and let the app
show "the price changed, confirm again". Silently charging the new price is the design that
ends up on social media.

*Step 7 — Trade-offs, failure modes, and 10x.*

#table(columns: 3,
  align: (left, left, left),
  [*Choice*], [*The other option*], [*Decision*],
  [Fee shapes in code, numbers in config],
    [everything in a rules table],
    [*Split.* Numbers change weekly, shapes twice a year. A rules engine in the database is an unversioned language nobody can test.],
  [Quote frozen with a TTL],
    [re-price at checkout],
    [*Freeze, 5-minute TTL.* Shown price must equal charged price. 5 minutes is long enough to check out and short enough that surge is not badly stale.],
  [Surge fetched through a port with a 50 ms timeout and a fallback of $1.0$],
    [call it inline and fail the quote],
    [*Port with fallback.* A pricing page that returns an error because a secondary service is slow loses far more money than one that under-charges surge for a minute.],
  [Promotions computed in-process],
    [a separate promo service call],
    [*In-process for now.* At 8,334 quotes/s a second network hop adds 2 ms and a new failure mode. Revisit when promo rules need their own release cycle.],
)

*Failure modes.*
+ *Surge service down.* Fallback $1.0$, log it, raise an alarm on the fallback rate. Under-charging for ten minutes is survivable; a broken menu page is not.
+ *Config cache poisoned with a bad number.* Guard every fee with a sanity clamp ("no single fee above Rs 500") and a boot-time schema check.
+ *Clock skew between the app and the server.* Always compare `expiresAt` on the server, never trust the client's clock.
+ *A fee calculator throws.* Catch per fee, treat it as zero, tag the quote `degraded: true`, and alarm. A missing packing fee is better than a blank screen.

*At 10x — 40 million DAU.* Redo the arithmetic:
$40{,}000{,}000 times 3 times 20 = 2{,}400{,}000{,}000$ calculations/day
$= 2{,}400{,}000{,}000 div 86{,}400 = 27{,}778$/s average, $times 3 = 83{,}334$/s at peak.
At 7 ns each that is still only 16.8 seconds of CPU across the whole day, so the *objects*
are still not the problem. What breaks first is the config fetch and the surge call, so at
10x I would push the rules into each instance's memory at boot with a push-based invalidation
instead of a 60-second poll, and batch the surge lookup for all 20 cards into one call
instead of 20.
#ans[`PriceEngine` over a `FeeRegistry` of small fee objects; shapes in code, numbers in versioned config; a frozen `Quote` plus a unique idempotency key stops double pricing and double charging.]
]

#ex(20, tier: 2, asked: "Shopee · pattern")[
*The concurrency bug that survives in a single-threaded language.*
Node runs your JavaScript on one thread, so shared state is safe. True or false? Prove it.
]
#sol[
*False.* One thread does not mean one request at a time. Every `await` is a place where the
thread leaves your function and runs somebody else's code.

#code(lang: "js", caption: "race.js")[
```js
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

class SeatMapBuggy {
  constructor() { this.free = 1; }
  async book(who) {
    const free = this.free;              // 1. read
    await sleep(5);                      // 2. a DB call -> another request runs HERE
    if (free > 0) { this.free = free - 1; return `${who}: booked`; }
    return `${who}: sold out`;
  }
}

class SeatMapFixed {
  constructor() { this.free = 1; this.lock = Promise.resolve(); }
  book(who) {                            // queue the whole read-modify-write
    const run = this.lock.then(async () => {
      const free = this.free;
      await sleep(5);
      if (free > 0) { this.free = free - 1; return `${who}: booked`; }
      return `${who}: sold out`;
    });
    this.lock = run.then(() => {}, () => {});
    return run;
  }
}

(async () => {
  const bad = new SeatMapBuggy();
  console.log(await Promise.all([bad.book('rishabh'), bad.book('aisha')]));
  const good = new SeatMapFixed();
  console.log(await Promise.all([good.book('rishabh'), good.book('aisha')]));
})();
```
]

#code(lang: "text", caption: "measured output of node race.js")[
```text
[ 'rishabh: booked', 'aisha: booked' ] seats left = 0
[ 'rishabh: booked', 'aisha: sold out' ] seats left = 0
```
]

One seat. Two winners. Trace it:

#table(columns: 3,
  align: (left, left, left),
  [*Time*], [*rishabh*], [*aisha*],
  [t0], [reads `free` = 1], [—],
  [t0], [hits `await`, pauses], [starts, reads `free` = 1],
  [t0], [—], [hits `await`, pauses],
  [t5], [wakes, sees its own `free` = 1, books], [—],
  [t5], [—], [wakes, sees its own `free` = 1, books],
)

The read and the write are separated by an `await`. Everything between them is a window.

*The object-design lesson.* A domain object that holds *mutable* state and also does I/O in
the middle of a state change is unsafe in every language, threads or not. Two ways out:

+ *Make the object immutable* and let the database decide. `UPDATE seats SET free = free - 1 WHERE id = ? AND free > 0` returns 0 rows for the loser. One statement, no window.
+ *Serialise the whole read-modify-write*, as `SeatMapFixed` does with a promise chain.

*Trade-off, and the decision.* The promise-chain lock is 4 lines and needs no database
feature, but it only protects *one process* — start a second Node instance and both can book
the same seat. The conditional `UPDATE` is one line of SQL and is correct across every
instance, but it puts the rule in the database where your unit tests cannot see it.
*Decision: the conditional `UPDATE` is the real answer* for anything that is shared across
instances — which a seat map always is. Use the in-process lock only for state that genuinely
belongs to one process, such as a local rate-limit counter.
#ans[False. `await` opens a window between read and write. Fix with a conditional `UPDATE` in the database, not with an in-process lock.]
]

#ex(21, tier: 2, asked: "Agoda · pattern")[
*Nine teams, one enum.* A `BookingType` enum has 9 values. Somewhere in the codebase it is
`switch`-ed on in 14 places, across 9 services. A tenth booking type is coming.
Count the cost of the current design, then fix it.
]
#sol[
*Count first.* A new enum value that must behave correctly in every switch means visiting
14 switch sites. But the switches are spread across 9 services, so the real unit of work is a
deploy per service:

- switch sites to edit: 14
- services to release, test and roll out: 9
- if each of the 9 services has its own review and deploy cycle of half a day:
  $9 times 0.5 = 4.5$ engineer-days for one enum value, before any feature work.

Worse, a `switch` with no `default` that throws will *silently* fall through for the new
value. You find out in production.

*The fix has two halves.*

+ *Put the behaviour with the data.* Anything that is a pure function of the booking type —
  the label, whether it is refundable, the cancellation window — moves into a single table
  that all services read. Then there is one place to add a row, not 14.
+ *Make the remaining switches loud.* Where a service genuinely must branch, the `default`
  case throws:

#code(lang: "js", caption: "a switch that cannot fail silently")[
```js
function cancellationHours(type) {
  const table = {
    HOTEL: 24, FLIGHT: 4, BUS: 2, TRAIN: 4, CAR: 1,
    ACTIVITY: 48, CRUISE: 72, PACKAGE: 72, INSURANCE: 0,
  };
  const hours = table[type];
  if (hours === undefined) throw new Error(`unknown booking type: ${type}`);
  return hours;
}
```
]

Now a tenth type causes a loud, immediate, findable failure in every service that has not
been updated — on the first request, in staging, with the type name in the message.

*Trade-off, and the decision.* A shared table means 9 services now depend on one schema; a
bad row breaks everybody at once, and you have created a coupling point. Nine private copies
mean no shared blast radius but guaranteed drift — three services will disagree about the
cancellation window within a year. *Decision: share it,* but ship it as a *versioned* config
artefact (a package or a signed config blob with a version number) rather than a live shared
table, so a bad row can be rolled back per service instead of taking all nine down at once.

#trap[
"Just add a `default: break`" is the wrong instinct. A `default` that does nothing turns a
crash into wrong data, and wrong data is discovered by a customer, weeks later, in money.
Throw.
]
#ans[14 switch sites across 9 services $approx$ 4.5 engineer-days per enum value. Move behaviour into one versioned table; make every remaining `default` throw.]
]

#section[Tier 3 — OOP that survives a distributed system]
#tier-header(3)

At Tier 3 your objects stop living in one process. They are serialised, sent over a network,
retried, stored for seven years, and read back by a service that was deployed eight months
after yours. Every OOP rule you learned still applies, but the cost of breaking one is now
counted in shards and outages.

#ex(22, tier: 3, asked: "Amazon · pattern")[
*Design the domain model for a payments ledger* that must never lose or duplicate an entry,
at 90 million transactions a day. Walk all seven steps, and be explicit about what the
*objects* have to guarantee.
]
#sol[
*Step 1 — Clarify.*

#table(columns: 2,
  align: (left, left),
  [*Question*], [*Why it changes the design*],
  [Is a balance a stored number or a sum of entries?], [This is *the* modelling decision. Stored number is fast to read and impossible to audit; sum of entries is auditable and slow to read. It decides everything downstream.],
  [How long must entries be kept?], [7 years for financial records changes storage from "a table" to "a table plus cold archive", and changes the yearly storage arithmetic.],
  [Can two services write the same account at the same time?], [Yes. That forces an optimistic-lock version or a single-writer-per-account rule.],
  [Is a partial transfer ever acceptable?], [No. Debit and credit must land together, which forces the double-entry model below.],
)

*Step 2 — Scale estimate.*

- 90,000,000 transactions/day.
- Average: $90{,}000{,}000 div 86{,}400 = 1{,}042$ transactions per second.
- Peak 3x (salary day, sale day): $1{,}042 times 3 = 3{,}126$ per second.
- *Double entry means every transaction writes 2 rows* (one debit, one credit):
  $90{,}000{,}000 times 2 = 180{,}000{,}000$ rows/day, so $1{,}042 times 2 = 2{,}084$ row-writes/s
  average and $6{,}252$/s at peak.
- Row size about 200 bytes: $90{,}000{,}000 times 200 = 18{,}000{,}000{,}000$ bytes
  $= 18$ GB/day (counting a transaction as one logical record of 200 B).
- Per year: $18 "GB" times 365 = 6{,}570$ GB $= 6.57$ TB/year.
- With 3 replicas: $6.57 times 3 = 19.7$ TB/year of real disk.
- Over the 7-year retention: $6.57 times 7 = 46$ TB of logical data, $138$ TB with replicas.

That last number is the one that decides the design: 46 TB does not sit on one machine, so
the account id must be a shard key from day one, and shard choice must be a property of the
*domain object*, not an afterthought in the data layer.

*Step 3 — API surface.*

#code(lang: "text", caption: "the write path")[
```text
POST /v1/transfers
  Idempotency-Key: 5f2c-...-9a
  { "from":"acc-1001", "to":"acc-2938", "paise": 250000, "reference":"rent-sep" }
-> 201 { "transferId":"t-77c1", "status":"POSTED", "postedAt":"2026-09-15T09:12:03Z" }
-> 200 (same body) if this Idempotency-Key was already posted
-> 409 { "error":"INSUFFICIENT_FUNDS", "availablePaise": 180000 }

GET /v1/accounts/acc-1001/balance
-> 200 { "accountId":"acc-1001", "balancePaise": 4512000, "asOfEntryId": 918273645 }
```
]

Note `asOfEntryId` on the balance. It turns "here is a number" into "here is a number and the
exact point in the ledger it is true at", which is what makes a balance checkable.

*Step 4 — Data model.*

#table(columns: 4,
  align: (left, left, left, left),
  [*Table*], [*Key*], [*Fields*], [*Notes*],
  [`entries`], [`(account_id, entry_id)`], [`transfer_id`, `direction` (`D`/`C`), `paise`, `created_at`], [append only. Never updated, never deleted. Sharded by `account_id`.],
  [`transfers`], [`transfer_id`], [`idempotency_key` (unique), `from_account`, `to_account`, `paise`, `status`], [the unique index is the anti-duplicate guarantee],
  [`balances`], [`account_id`], [`balance_paise`, `as_of_entry_id`, `version`], [a *cache* of the sum, not the truth],
)

*Step 5 — Architecture diagram.*

#diagram(height: 6.6cm, caption: "Entries are the truth; balances are a derived cache. The account id chooses the shard, and it does so inside the domain object.")[
  #dnode(0pt,   60pt, 76pt, 32pt, [Transfer API])
  #dnode(102pt, 60pt, 92pt, 32pt, [Transfer #linebreak() use case], fill: rgb("#e6efe6"))
  #dnode(102pt, 8pt,  92pt, 30pt, [AccountId #linebreak() #text(size: 7pt)[shard(n)]], fill: rgb("#f3efe2"))
  #dnode(102pt, 120pt, 92pt, 30pt, [Money #linebreak() #text(size: 7pt)[frozen]], fill: rgb("#f3efe2"))
  #dnode(238pt, 8pt,  92pt, 30pt, [shard 0])
  #dnode(238pt, 52pt, 92pt, 30pt, [shard 1])
  #dnode(238pt, 96pt, 92pt, 30pt, [shard ...])
  #dnode(238pt, 140pt, 92pt, 30pt, [shard 7])
  #dnode(372pt, 52pt, 96pt, 30pt, [balances #linebreak() #text(size: 7pt)[derived cache]])
  #dnode(372pt, 118pt, 96pt, 34pt, [archive #linebreak() #text(size: 7pt)[7-year cold]])
  #darrow(76pt, 76pt, 102pt, 76pt)
  #darrow(148pt, 38pt, 148pt, 60pt, label: "shard?")
  #darrow(148pt, 92pt, 148pt, 120pt)
  #darrow(194pt, 70pt, 238pt, 23pt)
  #darrow(194pt, 74pt, 238pt, 67pt, label: "append")
  #darrow(194pt, 78pt, 238pt, 111pt)
  #darrow(194pt, 82pt, 238pt, 155pt)
  #darrow(330pt, 67pt, 372pt, 67pt, label: "fold")
  #darrow(330pt, 155pt, 372pt, 142pt, label: "after 90 d")
]

*Step 6 — Deep dive 1: the shard key must live in the domain object.*

If the shard is computed in the data layer, two services will compute it differently the day
someone "improves" the hash, and half the entries for an account go to the wrong shard. Make
it a method on the identifier, and make the hash one that is identical in every language and
every version.

#code(lang: "js", caption: "shard.js — a hash that never changes its mind")[
```js
function fnv1a(str) {                 // 32-bit FNV-1a: same answer in every language
  let h = 0x811c9dc5;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return h >>> 0;
}

class AccountId {
  constructor(value) { this.value = value; Object.freeze(this); }
  get shardKey() { return this.value; }          // the ONLY thing hashed. Never the object.
  shard(n) { return fnv1a(this.shardKey) % n; }
}

const counts = new Array(8).fill(0);
for (let i = 0; i < 100000; i++) counts[new AccountId('acc-' + i).shard(8)]++;
console.log('spread over 8 shards:', counts.join(' '));
console.log('ideal per shard     :', 100000 / 8);
```
]

#code(lang: "text", caption: "measured output of node shard.js")[
```text
acc-1001 hash = 1105070759 -> shard 7 of 8
acc-1002 hash = 1121848378 -> shard 2 of 8
acc-2938 hash = 1673079079 -> shard 7 of 8
acc-7777 hash = 1684264593 -> shard 1 of 8
acc-8123 hash = 1733756585 -> shard 1 of 8
spread over 8 shards: 12497 12498 12501 12497 12504 12501 12498 12504
ideal per shard     : 12500
```
]

100,000 keys over 8 shards should give $100{,}000 div 8 = 12{,}500$ each. The measured spread
is 12,497 to 12,504 — the worst shard is
$(12{,}504 - 12{,}500) div 12{,}500 = 0.00032 = 0.032%$ above ideal. That is flat enough to
ignore.

#trap[
Never shard on a language's built-in hash of an object. In Java, `Objects.hash(...)` is
computed from the fields and can differ between JVM versions and is *not* specified to be
stable forever; in Python, string hashing is randomised per process by default, so the same
key gives a different shard after a restart. Write the hash yourself, in the domain object,
from an explicit string. FNV-1a and MurmurHash3 are both fine; what matters is that it is
*your* code and it never changes.
]

*Step 6 — Deep dive 2: balance as stored number, or as a sum of entries?*

#table(columns: 3,
  align: (left, left, left),
  [], [*Stored balance (mutate a row)*], [*Sum of entries (append only)*],
  [Read a balance], [1 row read, about 1 ms], [sum of up to millions of rows — unusable without help],
  [Write], [`UPDATE` with a version check], [`INSERT` only — no locks, no contention],
  [Audit "why is it 45,120?"], [impossible; the history is gone], [replay the entries and see],
  [A bug that double-applies], [balance is permanently wrong], [duplicate entry is visible and reversible],
  [Concurrent writers], [lock contention on a hot account], [none: inserts never conflict],
)

*Decision: entries are the truth, balance is a derived cache.* Keep `entries` append-only,
and keep a `balances` row that stores the running total *plus* `as_of_entry_id`. Reads go to
`balances` (1 ms). A nightly job recomputes from the entries and alarms on any mismatch,
which turns a silent corruption into a ticket. This costs one extra table and one extra job,
and it buys the one thing a ledger cannot live without: the ability to prove a number.

Why not pure sum-on-read? Do the arithmetic. A three-year-old salary account at 30
transactions a month has $30 times 36 = 1{,}080$ entries — summing that on every read is fine.
But a merchant settlement account at 90 transactions per *second* accumulates
$90 times 86{,}400 = 7{,}776{,}000$ entries a day. Summing 7.8 million rows for one balance
read is not a design, it is an outage. The cache is not an optimisation; it is required.

*Step 6 — Deep dive 3: the object that crosses the wire.*

Your `Transfer` object is serialised, queued, retried, and read by a consumer running
last month's code. Three rules follow, and all three are Liskov in disguise — the new version
must be usable everywhere the old one was:

+ *Only add optional fields.* A new *required* field breaks every old consumer at once. Count it: 9 consuming services, each needing a coordinated release, is a 9-way deploy with an ordering constraint — the classic distributed-systems trap.
+ *Never reuse a field name with a new meaning.* `amount` meaning rupees in v1 and paise in v2 is a 100x bug that no type system will catch.
+ *Never remove a field until the metrics say nobody reads it.* Ship the removal in two releases: stop writing, wait, then delete.

*Step 7 — Trade-offs, failure modes, and 10x.*

#table(columns: 3,
  align: (left, left, left),
  [*Choice*], [*The other option*], [*Decision*],
  [Append-only entries + cached balance], [mutate a balance row], [*Append-only.* A ledger that cannot be audited is not a ledger. The extra table and the nightly reconciliation job are the price.],
  [Shard key inside `AccountId`], [shard chosen in the repository], [*Inside the domain object.* One definition, one file, testable, and impossible for two services to disagree about.],
  [Hand-written FNV-1a], [the language's built-in hash], [*Hand-written.* Built-in hashes are not promised to be stable across versions or processes, and a shard map must be stable for seven years.],
  [Idempotency enforced by a unique index], [checked in application code], [*Unique index.* Application checks have a window between read and write; a unique index has none. Let the database be the one that says no.],
  [Both legs of a transfer in one transaction when the accounts share a shard], [always use a distributed transaction], [*Same-shard transaction when possible, a saga otherwise.* Most transfers are within one shard; paying the cost of a two-phase commit for all of them to handle the minority is the wrong trade.],
)

*Failure modes.*
+ *Debit written, credit lost.* Both legs go in one database transaction when the accounts share a shard. When they do not, write a `PENDING` transfer first, then the two legs, then mark `POSTED`; a sweeper finishes or reverses anything stuck in `PENDING` for more than 30 seconds.
+ *A retried request that already succeeded.* The unique index on `idempotency_key` rejects it; the handler returns `200` with the original transfer.
+ *Balance cache drifts from the entries.* The nightly fold recomputes and alarms. Because entries are immutable, the truth is always recoverable.
+ *A hot account.* One merchant taking 90 transfers a second lands entirely on one shard. Fix by splitting the merchant into sub-accounts (`m-77/0` ... `m-77/9`) that hash apart and sum together. This is a *domain* fix, not an infrastructure one.

*At 10x — 900 million transactions a day.*
$900{,}000{,}000 div 86{,}400 = 10{,}417$/s average, $times 3 = 31{,}251$/s peak, and
$18 "GB" times 10 = 180$ GB/day $= 65.7$ TB/year of logical data. Two things change. First,
8 shards become 64 or more, so the shard count must never be baked into the id — store a
*shard map* and route through it, or the day you resize, every account moves. Second, the
balance fold moves from a nightly batch to a stream consumer, so `as_of_entry_id` is seconds
behind rather than hours.
#ans[Append-only `entries` as truth, `balances` as a derived cache with `as_of_entry_id`, `AccountId.shard()` using a hand-written FNV-1a, and a unique idempotency index. 6.57 TB/year logical, 19.7 TB with 3 replicas.]
]

#ex(23, tier: 3, asked: "Google · pattern")[
*Where does validation live?* An `Email` value object validates in its constructor, so an
invalid email cannot exist. A reviewer says: "our service reads 40 million rows a night from
a legacy table, 0.3% of them have broken emails, and now the whole batch dies." Who is right?
]
#sol[
Both are, about different things. The mistake is treating one rule as universal.

*Count the damage first.* $40{,}000{,}000 times 0.003 = 120{,}000$ bad rows. If a bad row
throws and the batch stops, the batch never finishes. If a bad row is silently accepted,
120,000 customers get no mail and nobody notices for a month.

*The resolution is a boundary rule, not a class rule.*

#table(columns: 3,
  align: (left, left, left),
  [*Where*], [*What to do with bad input*], [*Why*],
  [At the *edge* — an API request a human just made], [reject with `400` and a clear message], [the human can fix it now, and a bad value must never enter the system],
  [At an *import* from a system you do not control], [parse, do not throw: return either a valid `Email` or a reason], [you cannot fix legacy data by refusing to read it],
  [*Inside* the domain, after the edge], [assume valid; no re-checks], [if the edge did its job, re-validating everywhere is noise that hides the real rules],
)

#code(lang: "js", caption: "one class, two doors")[
```js
class Email {
  constructor(value) {                       // strict door: throws
    if (!Email.isValid(value)) throw new Error(`invalid email: ${value}`);
    this.value = value.toLowerCase();
    Object.freeze(this);
  }
  static isValid(v) { return typeof v === 'string' && /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(v); }
  static parse(v) {                          // tolerant door: never throws
    return Email.isValid(v) ? { ok: true, email: new Email(v) }
                            : { ok: false, reason: 'malformed', raw: v };
  }
}
```
]

The batch uses `Email.parse` and sends the 120,000 failures to a quarantine table with the
reason. The API uses `new Email(...)` and returns `400`. The invariant "an `Email` object is
always valid" holds in both paths, which is the whole point of the value object.

*Trade-off, and the decision.* A single strict constructor is simpler and gives the strongest
guarantee, but it makes the class unusable at any boundary where bad data is a fact of life.
Two doors is one extra method and a rule people must remember. *Decision: two doors,* with a
naming convention enforced in review — `new X(...)` throws, `X.parse(...)` returns a result.
The quarantine table is not optional: data you drop without recording is data you cannot fix.
#ans[Both. Strict constructor at the edge, a tolerant `parse()` at imports, no re-validation inside. Quarantine the 120,000 bad rows with a reason.]
]

#ex(24, tier: 3, asked: "Uber · pattern")[
*Inheritance across a network boundary.* A base class `Vehicle` has `etaSeconds()`. `Bike`,
`Car` and `Auto` override it. A new `PartnerCar` gets its ETA from a partner's HTTP API.
What breaks, and what do you do?
]
#sol[
*What breaks.* Every caller of `etaSeconds()` was written believing it is a cheap,
in-memory, always-succeeds, microsecond call. `PartnerCar` makes it a network call. Measure
the gap: an in-memory ETA is about $0.001$ ms; a partner HTTP call is about 120 ms.
$120 div 0.001 = 120{,}000$ times slower. And it can fail, time out, or return nonsense.

This is a Liskov break of the loudest kind. The method signature is identical, so the
compiler is happy, and the production behaviour is unrecognisable. Concretely, a list screen
that ranks 30 nearby vehicles used to take $30 times 0.001 = 0.03$ ms and now takes
$30 times 120 = 3{,}600$ ms if the calls are sequential. The screen times out.

*The fix, in three moves.*

+ *Make the cost visible in the type.* Rename the contract so a slow call cannot hide behind a fast one: `etaSeconds()` stays synchronous and in-memory; anything that can block becomes `async fetchEta()`. Different name, different shape, no surprise.
+ *Give the remote one an interface of its own.* `PartnerCar` implements `RemoteEtaSource`, which promises a timeout and a fallback. It is not a `Vehicle` subclass at all — it is a `Vehicle` *plus* a port.
+ *Batch and cache at the call site.* One call for 30 vehicles instead of 30 calls, with the result cached for 15 seconds. $3{,}600$ ms becomes about 120 ms.

#code(lang: "js", caption: "the shape that keeps the promise")[
```js
class Vehicle {
  etaSeconds(distanceM) { return Math.round(distanceM / this.speedMps()); }  // always fast
  speedMps() { throw new Error('subclass must implement speedMps()'); }
}
class Bike extends Vehicle { speedMps() { return 6.5; } }
class Car  extends Vehicle { speedMps() { return 9.0; } }

class PartnerEtaSource {                     // a PORT, not a subclass
  constructor(http, timeoutMs = 150, fallback = 900) {
    this.http = http; this.timeoutMs = timeoutMs; this.fallback = fallback;
  }
  async etaFor(vehicleIds) {                 // batched
    try { return await this.http.postWithTimeout('/eta', { vehicleIds }, this.timeoutMs); }
    catch { return new Map(vehicleIds.map((id) => [id, this.fallback])); }
  }
}
```
]

*Trade-off, and the decision.* Keeping `PartnerCar extends Vehicle` means one uniform list and
no caller changes — very tempting, and it is why this bug is so common. Splitting it into a
port means the ranking code must now handle two sources and merge them, which is real extra
work. *Decision: split it.* A method whose cost varies by five orders of magnitude between
subclasses is not one method. The uniformity you keep by leaving it alone is fake uniformity,
and it is paid for with a timeout on the busiest screen in the product.

#formulas(title: "The rule for inheritance across a boundary")[
A subclass may change *what* is computed. It must not change:
+ the *order of magnitude* of the cost (a microsecond method must not become a network call),
+ whether it can *fail* (an always-succeeds method must not start throwing),
+ whether it can *block* (a synchronous method must not start waiting on I/O).

Change any of those three and you need a new contract, not an override.
]
#ans[The override turns a 0.001 ms call into a 120 ms one — a 120,000x change the compiler cannot see. Make the remote source a port with a timeout, batch it, and cache it.]
]

#section[Interview drill]

These are the follow-ups that come after your first answer. Each one has a short, decided
reply. Learn the shape, not the words.

#table(columns: 2,
  align: (left, left),
  [*The interviewer pushes*], [*The answer that scores*],

  [“Isn’t all this indirection slow?”],
  [“A method call through an object is about 7 ns — I measured it. One database round trip is 2 ms, which is 285,000 of them. The indirection is free; the round trip is the cost.”],

  [“You have 6 classes for what could be one function.”],
  [“Agreed for one function. I split at the point where two different teams file tickets on the same file. Here the tax rule and the layout are owned by finance and design, so they get one class each. I would not split further.”],

  [“Why not just use inheritance here?”],
  [“There are three independent axes — format, storage, compression — and $3 times 2 times 2 = 12$ combinations. Inheritance needs 12 classes; composition needs 7 and one new class per new option. One axis, I would inherit.”],

  [“Where do you validate?”],
  [“At the edge, strictly, with a `400`. Inside the domain, not at all. At a legacy import, with a tolerant `parse()` that quarantines bad rows instead of killing the batch.”],

  [“Singleton — good or bad?”],
  [“Bad as a global that classes reach for themselves, because it hides a dependency and makes tests share state. Fine as *one instance, injected once at start-up*. The lifetime is fine; the global lookup is the problem.” (Chapter 4 works this through.)],

  [“Your value object is immutable — isn’t that wasteful?”],
  [“A `Money` object is two fields, about 40 bytes. At 8,334 quotes a second with 5 fee lines each, that is $8{,}334 times 5 times 40 approx 1.7$ MB/s of short-lived garbage, which a generational collector handles in its cheapest path. I will pay that to make a whole class of aliasing bugs impossible.”],

  [“What if two threads touch this object?”],
  [“Then it must be immutable, or the state change must be one atomic operation. In Node, remember that `await` opens the same window a thread does — I showed a seat being sold twice on one thread.”],

  [“How do you test this?”],
  [“The rules class takes no database, so a test builds it with in-memory doubles and runs in under a millisecond. 600 such tests take 0.24 s instead of 4 minutes, which is the difference between running them on every save and running them never.”],

  [“Add a new fee type. What changes?”],
  [“One new class and one `register(...)` line. No existing file is edited, and the registry rejects a duplicate type or a missing method at boot.”],

  [“Why is the shard key in the domain object?”],
  [“So there is exactly one definition. If the data layer computes it, two services will disagree the day someone changes the hash, and entries for one account land on two shards. It is a hand-written FNV-1a because built-in hashes are not promised to be stable across versions.”],

  [“What would you do differently at 10x?”],
  [“Redo the arithmetic out loud first. $40 "M" times 3 times 20 = 2.4$ billion calls a day $= 27{,}778$/s, $83{,}334$/s at peak. The objects are still 16.8 seconds of CPU across the day, so they are not the problem — the config poll and the per-card surge call are. I would push config at boot and batch surge into one call.”],

  [“You used a `switch`. Why?”],
  [“Because it has 3 branches and is read in one screen. The rule I apply is: past about 4 branches, or any branch that a different team owns, it becomes a registry. This one is neither yet.”],
)

#section[Practice]

#practice(tier: 1, time: "35 min")[
+ A `Student` class has `name`, `rollNo`, `marks[]`, `printReportCard()`, `saveToFile()`, `emailParents()`. List the reasons to change, then split it. How many classes, and what is each one's single job?

+ Write a `DateRange` value object with `start` and `end` (both day numbers). It must reject `end < start` in the constructor, be frozen, expose `days`, and have an `overlaps(other)` method. Show `overlaps` returning `true` and `false` on two examples, with the arithmetic.

+ This is claimed to be polymorphism. It is not. Say why, then fix it.
  `function area(s) { if (s.kind === 'circle') return 3.14159 * s.r * s.r; return s.w * s.h; }`

+ A parking system has `Vehicle` with `wheels()` and `feePerHour()`. `Bicycle` returns `feePerHour() = 0`, and the billing code has `if (v instanceof Bicycle) skipBilling()`. Which SOLID letter is broken, and what is the fix?

+ Count the classes: a notification can be Email, SMS or Push; in English, Hindi or Thai; urgent or normal. With inheritance, how many subclasses? With composition, how many classes? Show both multiplications.

+ Write the `STATUS` table for a support ticket with `OPEN`, `WAITING`, `RESOLVED`, `CLOSED`, `REOPENED`, giving legal next states for each. Then say what `moveTo('CLOSED')` does from `OPEN`, and why.
]

#practice(tier: 2, time: "40 min")[
+ A quiz app has 6,000,000 DAU. Each user attempts 4 quizzes a day, each quiz has 10 questions, and each question is scored server-side. Compute questions scored per day, average per second, and peak at 4x. Then, using 7 ns per polymorphic call, compute the total CPU seconds per day spent on scoring dispatch.

+ Your `Order` service exposes `order.total` as a stored field. A reviewer wants it computed from the lines every time. Give the read rate at which the stored field starts to win, assuming a line sum costs $0.2$ µs and orders average 6 lines. Then decide, and say what guards the stored field against going stale.

+ A `PaymentMethod` interface has `charge()`, `refund()`, `tokenize()`, `verifyOtp()`, `scheduleRecurring()`. UPI cannot do `scheduleRecurring()`, and a gift card cannot do `refund()`. Redesign the contracts and say exactly what a caller asks before calling.

+ You inject 4 dependencies into a use case today. Six months later it has 11. Name the smell, and give the two fixes, with the rule for choosing between them.

+ Write the promise-chain lock from this chapter as a reusable `Mutex` class with `runExclusive(fn)`. Then say in one sentence why you would still not use it for a seat map across 6 service instances.
]

#practice(tier: 3, time: "45 min")[
+ A social app stores 400,000,000 likes a day. Each like row is 64 bytes. Compute GB/day, TB/year, and TB/year with 3 replicas. Then decide: store likes as rows, or as a counter per post? Name both sides and choose, with the read rate that decides it.

+ Design `PostId` so that it carries its own shard. Requirements: stable for 10 years, computable in Node and in Python with the same answer, and even across 64 shards. Say which hash and why not the built-in one.

+ Your `OrderPlaced` event has a field `amount` in rupees. You must move to paise. Nine services consume it. Write the migration as a sequence of releases where no release breaks a consumer, and say how you know it is safe to delete the old field.

+ A base class method `price()` is overridden by a subclass to call a partner API. Give three separate things this breaks for existing callers, with an order-of-magnitude number for each.

+ A merchant account takes 90 transfers a second and all of them hash to one shard. Give a domain-level fix (not an infrastructure one), and compute the new per-shard rate if the fix splits the merchant 10 ways.
]

#key[
*Tier 1.*
+ Four reasons to change: marks rule, report layout, file format, email template. Four classes: `Student` (data + marks), `ReportCard` (layout), `StudentStore` (file), `ParentNotifier` (email).
+ `DateRange(10, 14)` has `days` $= 14 - 10 + 1 = 5$. `overlaps` is `start <= o.end && o.start <= end`. `(10,14)` vs `(12,20)`: $10 <= 20$ and $12 <= 14$, both true $arrow.r$ `true`. `(10,14)` vs `(15,20)`: $10 <= 20$ true, but $15 <= 14$ false $arrow.r$ `false`.
+ It is a `switch` wearing a costume — the call site must be edited for every new shape. Fix: `class Circle { area() { ... } }`, `class Rect { area() { ... } }`, and the caller says `s.area()`.
+ *L*, and also *O*. The `instanceof` check in the billing code proves the subclass is not usable like the others. Fix: `feePerHour()` of 0 is fine, and billing must handle a zero fee normally — delete the `instanceof` branch entirely.
+ Inheritance: $3 times 3 times 2 = 18$ subclasses. Composition: $3 + 3 + 2 = 8$ classes. A fourth channel costs 6 subclasses or 1 class.
+ `OPEN -> [WAITING, RESOLVED]`, `WAITING -> [OPEN, RESOLVED]`, `RESOLVED -> [CLOSED, REOPENED]`, `CLOSED -> []`, `REOPENED -> [WAITING, RESOLVED]`. `moveTo('CLOSED')` from `OPEN` throws, because a ticket must be resolved before it is closed — otherwise "closed" hides unresolved work.

*Tier 2.*
+ $6{,}000{,}000 times 4 times 10 = 240{,}000{,}000$ scored/day. $240{,}000{,}000 div 86{,}400 = 2{,}778$/s average; $times 4 = 11{,}112$/s peak. CPU: $240{,}000{,}000 times 7 "ns" = 1.68$ seconds per day.
+ Computing costs $6 times 0.2 = 1.2$ µs per read, so even at 100,000 reads/s it is $100{,}000 times 1.2 "µs" = 0.12$ s of CPU per second — 12% of one core. *Decision: compute it,* until the order is *paid*; then freeze the total onto the order, because at that moment it becomes a historical fact and must never change even if a price does. The guard against staleness is that nothing can edit a paid order's lines.
+ Split into `Chargeable` (`charge`), `Refundable` (`refund`), `Tokenizable` (`tokenize`), `Recurring` (`scheduleRecurring`). The caller asks `typeof m.refund === 'function'` (or checks a declared `capabilities` set) before offering a refund button — and the capability list is what the UI reads, so an unsupported button never renders.
+ The smell is a use case doing too much (SRP), with the constructor as the evidence. Fix A: split the use case into two, each with its own dependencies. Fix B: bundle related dependencies behind one port (a `Ledger` port instead of `accounts`, `entries`, `balances`). Choose A if the 11 split cleanly into two disjoint groups; choose B if 4 of them always travel together.
+ `class Mutex { #tail = Promise.resolve(); runExclusive(fn) { const r = this.#tail.then(fn); this.#tail = r.then(() => {}, () => {}); return r; } }`. It guards one process only — with 6 instances, 6 mutexes each let one booking through, so 6 people can buy the same seat.

*Tier 3.*
+ $400{,}000{,}000 times 64 = 25{,}600{,}000{,}000$ bytes $= 25.6$ GB/day. $times 365 = 9{,}344$ GB $= 9.34$ TB/year; $times 3 = 28.0$ TB/year with replicas. *Decision: store rows and keep a counter as a derived cache* — the same pattern as the ledger. Rows answer "did I like this?" and allow un-liking exactly once; the counter answers "how many?" in one read. Pure counters cannot answer the first question, and pure rows cannot answer the second at feed-render rates (a post with 2,000,000 likes cannot be counted per render).
+ `class PostId { get shardKey() { return this.value; } shard(n) { return fnv1a(this.value) % n; } }`. Use FNV-1a or MurmurHash3 written out in your own code. Not the built-in: Python randomises string hashing per process, so the shard changes after every restart, and Java's `Objects.hash` is not promised to be stable across versions. Evenness was measured at 0.032% from ideal over 100,000 keys.
+ Release 1: add `amountPaise` and write *both* fields; consumers still read `amount`. Release 2: each consumer switches to `amountPaise` at its own pace; add a metric counting reads of `amount`. Release 3: when the metric has been zero for two weeks, stop writing `amount`. Release 4: delete the field from the schema. You know it is safe when the read metric — not a code search — has been zero across a full billing cycle.
+ (i) *Latency:* 0.001 ms becomes about 120 ms, roughly 120,000x. A 30-item list page goes from 0.03 ms to 3,600 ms if called in a loop. (ii) *Failure:* a method that could never throw now throws on timeout, so every call site needs error handling it does not have. (iii) *Blocking:* a synchronous method becomes asynchronous, so either the caller changes shape or the event loop stalls. Any one of these needs a new contract.
+ Split the merchant into sub-accounts `m-77/0` ... `m-77/9`, chosen round-robin at write time and summed at read time. The hash of each sub-account id is different, so the writes spread. New rate per shard: $90 div 10 = 9$ transfers per second. Reading the merchant balance becomes 10 reads that are summed — an acceptable price, and they can run in parallel.
]

#revision[

*The five layers of an LLD answer.* Caller $arrow.r$ Service $arrow.r$ Domain $arrow.r$ Port
$arrow.r$ Adapter. The domain layer holds the rules, holds no connection, and runs in a test
in under a millisecond. The adapter must never reach back into the domain.

*The four pillars and their one test.*
#table(columns: 2,
  align: (left, left),
  [Encapsulation], [Can an outsider create an illegal state? If yes, it is broken.],
  [Abstraction], [Can you replace the whole inside and leave callers untouched?],
  [Inheritance], [Does the child keep *every* promise the parent made?],
  [Polymorphism], [Can you add a behaviour without touching the call site?],
)

*SOLID by smell — what you actually say out loud.*
#table(columns: 2,
  align: (left, left),
  [*S*], [the class name has "and" in it, or two teams edit the same file],
  [*O*], [an `if`/`switch` chain that grows with the business],
  [*L*], [an override that throws, does nothing, or forces `instanceof` at the call site],
  [*I*], [an implementation that has to write "not supported"],
  [*D*], [the rules file imports a database driver],
)

*The Liskov checklist.* Same or wider inputs · same or narrower outputs · no new exceptions ·
every state promise kept · caller never needs to know the subclass. Also, across a boundary:
no change in *order of magnitude of cost*, no new *failure*, no new *blocking*.

*Inheritance or composition?* Count the axes of variation. One axis $arrow.r$ inheritance is
fine. Two or more that combine freely $arrow.r$ composition, always, because the axes
*multiply*: $3 times 2 times 2 = 12$ subclasses versus $3 + 2 + 2 = 7$ classes.

*Numbers to memorise.*
#table(columns: 2,
  align: (left, left),
  [Polymorphic method call], [about *7 ns* (measured: 69 ms for 10,000,000 calls)],
  [One database round trip], [about *2 ms* $=$ 285,000 polymorphic calls],
  [Test with in-memory doubles], [about *0.4 ms*; with a real database about *400 ms* — 1000x],
  [A small value object], [about *40 bytes*],
  [Seconds in a day], [*86,400* — every QPS estimate starts here],
  [Peak multiplier], [*3x* the average unless the problem says otherwise],
)

*The estimation drill, every time.*
DAU $times$ actions/user $=$ actions/day $div$ 86,400 $=$ average/s $times$ 3 $=$ peak/s.
Then rows/day $times$ bytes/row $=$ bytes/day $times$ 365 $=$ bytes/year $times$ replicas.
#linebreak()
Worked once: $4 "M" times 3 times 20 = 240 "M"$/day $div 86{,}400 = 2{,}778$/s $times 3 = 8{,}334$/s peak.

*Value object rules.* No identity · frozen in the constructor · equality by value through a
`key` getter · validates itself so an invalid one cannot exist. Money is *integer paise*,
never a float — $0.1 + 0.2 = 0.30000000000000004$.

*Keys must be immutable.* A mutated key is unreachable for ever. In JavaScript a `Map` keyed
by an object matches by *identity*, and a plain object stringifies every key to
`[object Object]`. Key on a derived string. In Java: override `equals` and `hashCode`
together, and never mutate a key in a `HashMap`.

*Distributed extras.* The shard key lives in the domain object, computed by a hash *you
wrote* (FNV-1a), because built-in hashes are not stable across versions or processes. Events
may only *add optional* fields. Idempotency is enforced by a unique index, never by an
application check.

*What loses marks.* "It depends" with no choice. Reciting the five SOLID names instead of
pointing at a smell. Optimising before doing the arithmetic. Splitting a class because it got
long rather than because two teams edit it. Not saying what you would do at 10x.
]

]
