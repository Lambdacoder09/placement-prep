#import "../../shared/lib/style.typ": *

#chapter(num: 5, title: "Classic LLD Problems", tagline: "Parking lot, vending machine, Splitwise, seat booking, elevators, chess — the same six moves every time")[

#section[The idea in one page]

#formulas(title: "What a low-level design round actually tests")[

The interviewer is not checking whether you know a parking lot. They are checking six
things, in this order:

#table(columns: (auto, 1fr),
  [*1. Scope*], [Can you cut the problem down to something buildable in 40 minutes?],
  [*2. Nouns*], [Can you turn the story into classes with clean responsibilities?],
  [*3. The one hard part*], [Every classic problem has exactly one. Did you find it?],
  [*4. Code*], [Can you write the core method fully, not in hand-waves?],
  [*5. Change*], [When they add a rule, does your design bend or break?],
  [*6. Concurrency*], [What happens when two users do the same thing in the same millisecond?],
)

*The one hard part, per problem.* Memorise this column. It is what earns the offer.

#table(columns: (auto, auto, 1fr),
  [*Problem*], [*The one hard part*], [*The pattern that solves it*],
  [Parking lot], [pricing and allocation keep changing], [Strategy],
  [Vending machine], [behaviour depends on state], [State],
  [Splitwise], [money must never leak; many split rules], [Strategy + integer money],
  [Seat booking], [two people, one seat, same moment], [atomic compare-and-set + TTL hold],
  [Elevator bank], [which car, out of many?], [a cost function you can tune],
  [Chess], ["is this move legal?" is not local], [make-move / test / unmake (memento)],
)

*The six moves.* Do them in this order, out loud, every single time.

#table(columns: (auto, 1fr),
  [*Move 1*], [*Cut scope.* Say what you are NOT building. "No payments gateway, no login, single building." The interviewer will stop you if they disagree — that is the point.],
  [*Move 2*], [*Nouns to classes, verbs to methods.* Read the problem sentence by sentence and underline them.],
  [*Move 3*], [*Draw the boxes.* Who owns whom. Who knows about whom. Ten boxes maximum.],
  [*Move 4*], [*Name the one hard part* and say which pattern you are spending on it. One or two patterns, not six.],
  [*Move 5*], [*Write the core method in full.* The `allocate`, the `settle`, the `dispatch`. Not the getters.],
  [*Move 6*], [*Say the concurrency story and one extension.* "Two cars at the gate" and "now add electric charging bays."],
)
]

#trap[
The most common way to fail this round is to spend 25 minutes writing `getName()` and
`setName()` for eight classes, then have four minutes left for the part that actually
matters. Write the *hard* method first. Say out loud: "getters and setters assumed."
]

#trick[
*Responsibility test in one sentence.* For every class, finish this line: "This class is
the only place that knows how to \_\_\_." If you cannot finish it, the class is
decoration. If you can finish it two different ways, split the class in two.
]

#subsection[Money, time and identity — three rules that are never negotiable]

#formulas(title: "Get these wrong and the design is wrong, however pretty the classes are")[
+ *Money is an integer of the smallest unit.* Rupees become paise. `0.1 + 0.2` in
  JavaScript is `0.30000000000000004`. Never store money in a float.
+ *Time is a single monotonic number* you pass in, never `Date.now()` read inside a
  method. If time is a parameter, you can unit-test 24-hour parking without waiting a day.
+ *Every entity has an id you generate, not a field you hope is unique.* Number plates
  repeat across states. Seat "A5" repeats in every screen in the country.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[A parking lot problem says: "A vehicle arrives at a gate, an attendant
gives it a ticket, the vehicle occupies a spot, and on exit the driver pays a fee."
List the nouns and the verbs.
#sol[
Read it word by word and underline.

Nouns: vehicle, gate, attendant, ticket, spot, driver, fee.

Verbs: arrives, gives, occupies, exits, pays.

Now cut. "Attendant" and "driver" are humans who do not hold state that our program needs
— fold them into `Gate`. "Fee" is not a thing that lives; it is a number computed from a
ticket. So it becomes a method, or better, a strategy object.

Classes that survive: `Vehicle`, `Gate`, `Ticket`, `Spot`, `FeeStrategy`, and a
`ParkingLot` that owns the spots.
]
#ans[6 classes: Vehicle, Gate, Ticket, Spot, FeeStrategy, ParkingLot]
]

#ex(2, tier: 0)[Should `SpotSize` be a class or an enum? Should `FeeStrategy` be an enum
or a class?
#sol[
Ask one question: *does it carry behaviour that differs per value?*

`SpotSize` has three values (SMALL, MEDIUM, LARGE) and the only thing you ever do with
them is compare them. No behaviour. So: enum (in JavaScript, a frozen object of constants).

`FeeStrategy` has values whose *behaviour* differs — flat rate computes differently from a
slab rate. So: a class per strategy, with the same method name.

The rule: same data, different behaviour $arrow.r$ class. Same behaviour, different label
$arrow.r$ enum.
]
#ans[`SpotSize` = enum, `FeeStrategy` = one class per rule]
]

#ex(3, tier: 0)[Here is a bad design. Name the smell and fix it in one line.

```
class ParkingLot {
  fee(ticket) {
    if (this.city === "BLR") return ...
    else if (this.city === "DEL") return ...
    else if (this.city === "BOM") return ...
  }
}
```
#sol[
Smell: an `if`-chain over a *type code*. Every new city edits a class that has nothing to
do with cities. That breaks the open/closed rule: open to extension, closed to
modification.

Fix: `ParkingLot` holds a `pricing` object. Adding Chennai means adding a class, not
editing `ParkingLot`.

```
const lot = new ParkingLot(spots, allocator, new SlabRate(40, 25, 300));
```
]
#ans[Type-code `if`-chain $arrow.r$ inject a strategy object]
]

#ex(4, tier: 0)[A vending machine ignores the "select item" button until money is in.
Where does that rule live?
#sol[
Two wrong places and one right one.

Wrong 1: in the button handler (`if (machine.credit === 0) return;`). Then every new rule
adds another `if` to the same handler.

Wrong 2: a `mode` string checked everywhere. Same problem, spread wider.

Right: the machine holds a *state object*, and `select()` is a method on that object. The
`Idle` state's `select()` simply refuses. Nobody asks "what mode am I in?" — the current
state already knows.
]
#ans[In the `Idle` state class's own `select()` method]
]

#ex(5, tier: 0)[Three friends split a bill of Rs.10.00 equally. Show why
`total / 3` is a bug and give the fix.
#sol[
Work in paise. Total $= 1000$ paise.

$1000 div 3 = 333.33dots$ — not a whole number of paise.

If each person owes 333, the sum is $333 times 3 = 999$. One paisa has vanished. Over a
million splits that is Rs.100 that the ledger cannot explain.

Fix: integer division plus a remainder spread.

$"base" = floor(1000\/3) = 333$, $"remainder" = 1000 - 333 times 3 = 1$.

Give the first 1 person an extra paisa: shares are $334, 333, 333$. Sum $= 1000$. Exact.
]
#ans[Floor-divide, then hand the leftover paise out one each. Sum must equal the total.]
]

#ex(6, tier: 0)[Two people click "book seat C7" at the same instant. Your code is
`if (seat.isFree) seat.book(user)`. What goes wrong?
#sol[
Trace the interleaving, line by line, with a clock ticking between lines.

#table(columns: (auto, 1fr, 1fr),
  [*t*], [*Request 1*], [*Request 2*],
  [1], [reads `seat.isFree` #sym.arrow.r true], [—],
  [2], [—], [reads `seat.isFree` #sym.arrow.r true],
  [3], [writes holder = u1], [—],
  [4], [—], [writes holder = u2],
  [5], [returns "you got C7"], [returns "you got C7"],
)

Both were told yes. Only u2 holds the seat. This is a *read-modify-write race*, and it is
the number-one bug in booking systems.

Fix: one atomic operation that reads and writes together — a conditional `UPDATE`, a
Redis `SET NX`, or a unique index that rejects the second insert.
]
#ans[Both succeed; the seat is double-sold. Needs one atomic compare-and-set.]
]

#ex(7, tier: 0)[In chess, why can you not decide "is this knight move legal?" by only
looking at the knight?
#sol[
Because of the *pin*. A knight may be standing between your own king and an enemy rook.
The knight's own movement rule says the jump is fine. But making the jump exposes the
king, so the move is illegal.

Legality is a property of the whole board after the move, not of the piece before it.

That is why the code is always: make the move, ask "is my king attacked?", unmake the
move. Three steps, never one.
]
#ans[Legality depends on the whole board after the move — make, test, unmake]
]

// ============================================================
#tier-header(1)
#section[Tier 1 · Design a parking lot]

#subsection[Move 1 — cut the scope]

Say this out loud in the first 60 seconds:

#note[
"I will build one building with several floors. Three spot sizes. A vehicle takes the
smallest free spot that fits, on the lowest floor. Pricing is hourly with a daily cap.
I am *not* building: payment gateways, number-plate cameras, reservations, or multiple
buildings. If you want any of those, tell me and I will make room."
]

The questions to ask back, and why each one changes the design:

#table(columns: (auto, 1fr),
  [*"Can a big vehicle take several small spots?"*], [If yes, a `Ticket` holds a *list* of spots, not one. That changes `Ticket`, `Spot.free`, and the allocator. Huge difference — ask first.],
  [*"Is pricing per started hour or per minute?"*], [Decides whether `fee()` uses `Math.ceil` or plain division. Also decides whether the daily cap is even reachable.],
  [*"Do I need to find a specific car later?"*], [If yes I need a plate #sym.arrow.r ticket index. If no, I skip it and save a map.],
  [*"How many spots?"*], [200 spots means a linear scan is fine. 200,000 spots means I need free-lists per (floor, size).],
)

#subsection[Move 2 and 3 — the boxes]

#diagram(height: 5.6cm, caption: "Who owns whom. Solid arrows point from owner to owned, or from caller to callee.")[
  #dnode(6.3cm, 0.15cm, 3.8cm, 0.7cm, "ParkingLot", fill: rgb("#dce9f2"))
  #dnode(6.3cm, 1.55cm, 3.8cm, 0.7cm, "Level (floor)")
  #dnode(6.3cm, 2.95cm, 3.8cm, 0.7cm, "Spot")
  #dnode(6.3cm, 4.35cm, 3.8cm, 0.7cm, "Vehicle")
  #dnode(0.5cm, 1.55cm, 3.6cm, 0.7cm, "EntryGate")
  #dnode(0.5cm, 2.95cm, 3.6cm, 0.7cm, "Ticket")
  #dnode(0.5cm, 4.35cm, 3.6cm, 0.7cm, "FeeStrategy", fill: rgb("#f7efe4"))
  #dnode(12.5cm, 1.55cm, 3.8cm, 0.7cm, "SpotAllocator", fill: rgb("#f7efe4"))
  #dnode(12.5cm, 2.95cm, 3.8cm, 0.7cm, "ExitGate")
  #dnode(12.5cm, 4.35cm, 3.8cm, 0.7cm, "Payment")
  #darrow(8.2cm, 0.85cm, 8.2cm, 1.55cm, label: "1..N")
  #darrow(8.2cm, 2.25cm, 8.2cm, 2.95cm, label: "1..N")
  #darrow(8.2cm, 3.65cm, 8.2cm, 4.35cm, label: "0..1")
  #darrow(4.1cm, 1.9cm, 6.3cm, 0.6cm, label: "park()")
  #darrow(2.3cm, 2.25cm, 2.3cm, 2.95cm, label: "issues")
  #darrow(2.3cm, 3.65cm, 2.3cm, 4.35cm, label: "uses")
  #darrow(4.1cm, 3.3cm, 6.3cm, 3.3cm, label: "holds")
  #darrow(10.1cm, 0.5cm, 12.5cm, 1.9cm, label: "asks")
  #darrow(10.1cm, 3.3cm, 12.5cm, 3.3cm, label: "frees")
  #darrow(14.4cm, 3.65cm, 14.4cm, 4.35cm, label: "charges")
]

The two shaded boxes on the sides are the *plug points*. Everything the interviewer will
ask you to change lives in one of them.

#subsection[Move 4 and 5 — the code]

#code(lang: "js", caption: "Sizes, entities, and the two plug points")[
```js
const SpotSize = { SMALL: 0, MEDIUM: 1, LARGE: 2 };

class Vehicle {
  constructor(plate, size) { this.plate = plate; this.size = size; }
}

class Spot {
  constructor(id, floor, size) {
    this.id = id; this.floor = floor; this.size = size;
    this.vehicle = null;
  }
  get free() { return this.vehicle === null; }
  fits(v) { return this.free && this.size >= v.size; }   // a car may use a large spot
}

class Ticket {
  constructor(id, vehicle, spot, inAt) {
    this.id = id; this.vehicle = vehicle; this.spot = spot;
    this.inAt = inAt; this.outAt = null;
  }
}

// ---- plug point 1: pricing ----
class FlatRate {
  constructor(rate) { this.rate = rate; }
  fee(minutes) { return Math.ceil(minutes / 60) * this.rate; }
}
class SlabRate {
  constructor(firstHour, perExtraHour, dayCap) {
    this.firstHour = firstHour; this.perExtraHour = perExtraHour; this.dayCap = dayCap;
  }
  fee(minutes) {
    if (minutes <= 60) return this.firstHour;
    const extra = Math.ceil((minutes - 60) / 60);
    return Math.min(this.firstHour + extra * this.perExtraHour, this.dayCap);
  }
}

// ---- plug point 2: which spot ----
class NearestFreeFirst {
  pick(spots, vehicle) {
    let best = null;
    for (const s of spots) {
      if (!s.fits(vehicle)) continue;
      if (best === null) { best = s; continue; }
      if (s.floor < best.floor) { best = s; continue; }
      if (s.floor === best.floor && s.size < best.size) best = s;  // smallest that fits
    }
    return best;
  }
}
```
]

#code(lang: "js", caption: "The lot itself — park() and unpark() written in full")[
```js
class ParkingLot {
  constructor(spots, allocator, pricing) {
    this.spots = spots; this.allocator = allocator; this.pricing = pricing;
    this.open = new Map();          // ticketId -> Ticket
    this.nextTicket = 1;
    this.freeBySize = new Map();    // so isFull() is O(1), not a scan
    for (const s of spots)
      this.freeBySize.set(s.size, (this.freeBySize.get(s.size) || 0) + 1);
  }

  park(vehicle, atMinute) {
    const spot = this.allocator.pick(this.spots, vehicle);
    if (spot === null) return { ok: false, reason: "LOT_FULL" };
    spot.vehicle = vehicle;
    this.freeBySize.set(spot.size, this.freeBySize.get(spot.size) - 1);
    const t = new Ticket(this.nextTicket++, vehicle, spot, atMinute);
    this.open.set(t.id, t);
    return { ok: true, ticket: t };
  }

  unpark(ticketId, atMinute) {
    const t = this.open.get(ticketId);
    if (!t) return { ok: false, reason: "NO_SUCH_TICKET" };
    t.outAt = atMinute;
    const minutes = t.outAt - t.inAt;
    const amount = this.pricing.fee(minutes);
    t.spot.vehicle = null;
    this.freeBySize.set(t.spot.size, this.freeBySize.get(t.spot.size) + 1);
    this.open.delete(ticketId);
    return { ok: true, minutes, amount, spot: t.spot.id };
  }
}
```
]

#ex(8, tier: 1, asked: "TCS NQT · pattern")[Run the lot. Four spots: `F0-S1` (floor 0,
small), `F0-M1` (floor 0, medium), `F1-M1` (floor 1, medium), `F1-L1` (floor 1, large).
Pricing: Rs.40 for the first hour, Rs.25 per started hour after that,
daily cap Rs.300. A bike parks at 09:47 and leaves at 14:12. What does it pay?
#sol[
*Step 1 — allocation.* A bike is SMALL. `NearestFreeFirst` scans:
- `F0-S1`: fits (size 0 $>=$ 0), floor 0 — best so far.
- `F0-M1`: fits, floor 0, but size 1 is *not* smaller than 0 — keep `F0-S1`.
- `F1-M1`, `F1-L1`: floor 1 is worse. Keep `F0-S1`.

So the bike gets `F0-S1`.

*Step 2 — duration.* Convert clock times to minutes past midnight.

09:47 becomes $9 times 60 + 47 = 540 + 47 = 587$

14:12 becomes $14 times 60 + 12 = 840 + 12 = 852$

$"minutes" = 852 - 587 = 265$

*Step 3 — fee.* $265 > 60$, so use the slab branch.

$"extra minutes" = 265 - 60 = 205$

$"extra hours" = ceil(205 \/ 60) = ceil(3.4166dots) = 4$

$"fee" = 40 + 4 times 25 = 40 + 100 = 140$

Cap check: $min(140, 300) = 140$.
]
#ans[Spot `F0-S1`, 265 minutes, Rs.140]
]

#code(lang: "js", caption: "node parking.js — actual output")[
```
bike spot: F0-S1 SMALL
car  spot: F0-M1 MEDIUM
van  spot: F1-L1 LARGE
bike stayed 265 min, pay 140
24h stay pay: 300
```
]

#ex(9, tier: 1, asked: "Infosys · pattern")[A vehicle stays exactly 24 hours (1440
minutes). Show that the cap binds, and find the exact stay length at which the cap first
binds.
#sol[
*24-hour stay.*

$"extra minutes" = 1440 - 60 = 1380$

$"extra hours" = ceil(1380 \/ 60) = ceil(23) = 23$

$"uncapped fee" = 40 + 23 times 25 = 40 + 575 = 615$

$"fee" = min(615, 300) = 300$. The cap binds.

*Where does it first bind?* We need $40 + 25h >= 300$, where $h$ is extra hours.

$25h >= 260$

$h >= 10.4$, so the first whole $h$ is $11$.

$h = 11$ means $ceil("extra minutes" \/ 60) = 11$, which first happens at
$"extra minutes" = 601$.

$"total minutes" = 60 + 601 = 661$ minutes $= 11$ hours $1$ minute.

Check $h = 10$: $40 + 250 = 290 < 300$. Check $h = 11$: $40 + 275 = 315$, capped to 300.
Correct.
]
#ans[24 h costs 300 (capped). The cap first binds at 11 h 1 min of stay.]
]

#subsection[Move 6 — the follow-ups they will actually ask]

#table(columns: (auto, 1fr),
  [*"Add electric charging bays."*], [`Spot` gets a `features: Set` and `fits()` also checks the vehicle's required features. The allocator does not change. One field, zero edits to `ParkingLot`.],
  [*"Weekend pricing is different."*], [New class `WeekendRate` implementing `fee(minutes)`. Zero edits anywhere else. This is why pricing was a plug point.],
  [*"200,000 spots — the scan is too slow."*], [Replace `NearestFreeFirst` with `FreeListAllocator` that keeps one array of free spots per `(floor, size)` pair. `pick` becomes `pop` from the lowest non-empty list: $O(1)$ instead of $O(n)$. Zero edits to `ParkingLot` — same interface.],
  [*"Two cars at the gate at once."*], [`park()` does a read-modify-write on `spot.vehicle`. With real threads, wrap the pick-and-claim in one lock per floor, or make the free-list a concurrent queue so `pop` is atomic. Do NOT lock the whole lot — that serialises 200,000 spots behind one mutex.],
)

#complexity(time: "park() = O(n) scanning, O(1) with free lists; unpark() = O(1)",
  space: "O(n) spots + O(open tickets)",
  note: "n = number of spots. Free lists trade about 8 bytes a spot for a 200,000x faster pick.")

// ============================================================
#section[Tier 1 · Design a vending machine]

The one hard part here is *state*. The same button does different things depending on what
happened before. That is the definition of a state machine, and the State pattern is the
only clean way to code one.

#subsection[The machine drawn as states]

#diagram(height: 5.6cm, caption: "Each box is a class. Each arrow is a method on that class that changes this.state.")[
  #dnode(0.5cm, 2.2cm, 3.4cm, 0.9cm, [Idle \ credit = 0], fill: rgb("#dce9f2"))
  #dnode(5.2cm, 2.2cm, 3.6cm, 0.9cm, [HasMoney \ credit > 0])
  #dnode(10.2cm, 2.2cm, 3.6cm, 0.9cm, "Dispensing")
  #dnode(10.2cm, 0.3cm, 3.6cm, 0.9cm, "SoldOut", fill: rgb("#f7efe4"))
  #dnode(5.2cm, 4.4cm, 3.6cm, 0.9cm, "Refunding", fill: rgb("#f7efe4"))
  #darrow(3.95cm, 2.65cm, 5.15cm, 2.65cm, label: "insert")
  #darrow(8.85cm, 2.65cm, 10.15cm, 2.65cm, label: "select ok")
  #darrow(7.0cm, 2.2cm, 11.0cm, 1.25cm, label: "select, empty")
  #darrow(10.4cm, 1.25cm, 8.8cm, 4.4cm, label: "refund")
  #darrow(6.2cm, 3.1cm, 6.2cm, 4.4cm, label: "cancel")
  #darrow(5.2cm, 4.85cm, 2.4cm, 3.15cm, label: "coins out")
  #darrow(10.2cm, 3.45cm, 3.6cm, 3.2cm, label: "item dropped")
]

#formulas(title: "The State pattern, in four lines")[
+ The machine holds the *data* (credit, stock, coin bank) and a pointer `this.state`.
+ Each state is a small class with the same method names: `insert`, `select`, `cancel`, `tick`.
+ A base `State` class makes every method say "you cannot do that now". A concrete state
  overrides only the methods that are legal in it.
+ A transition is one line: `m.state = m.DISPENSING`. Nothing else in the program branches
  on the state.
]

#code(lang: "js", caption: "Base state: the default answer is 'no'")[
```js
class State {
  constructor(name) { this.name = name; }
  insert(m, coin) { return `${this.name}: cannot take coins now`; }
  select(m, code) { return `${this.name}: cannot select now`; }
  cancel(m)       { return `${this.name}: nothing to cancel`; }
  tick(m)         { return `${this.name}: idle tick`; }
}

class Idle extends State {
  constructor() { super("Idle"); }
  insert(m, coin) { m.credit += coin; m.state = m.HAS_MONEY; return `credit = ${m.credit}`; }
}

class Dispensing extends State {
  constructor() { super("Dispensing"); }
  tick(m) { m.state = m.IDLE; return "item dropped -> Idle"; }
}

class Refunding extends State {
  constructor() { super("Refunding"); }
  tick(m) { const r = m.credit; m.credit = 0; m.state = m.IDLE; return `refunded ${r} -> Idle`; }
}
```
]

#code(lang: "js", caption: "The interesting state: every rejection path is explicit")[
```js
class HasMoney extends State {
  constructor() { super("HasMoney"); }
  insert(m, coin) { m.credit += coin; return `credit = ${m.credit}`; }
  cancel(m) { m.state = m.REFUNDING; return m.state.tick(m); }
  select(m, code) {
    const slot = m.slots.get(code);
    if (!slot)          { m.state = m.REFUNDING; return `no such code ${code}; refunding`; }
    if (slot.qty === 0) { m.state = m.REFUNDING; return `${code} sold out; refunding`; }
    if (m.credit < slot.price) return `need ${slot.price - m.credit} more`;

    const change = m.makeChange(m.credit - slot.price);
    if (change === null) { m.state = m.REFUNDING; return `no change available; refunding`; }

    slot.qty -= 1;
    for (const c of change) m.bank.set(c, m.bank.get(c) - 1);
    m.credit = 0;
    m.state = m.DISPENSING;
    return `dispensing ${code}, change ${JSON.stringify(change)}`;
  }
}
```
]

#code(lang: "js", caption: "The machine: data + a change-maker that respects the real coin bank")[
```js
class VendingMachine {
  constructor(slots, bank) {
    this.IDLE = new Idle();           this.HAS_MONEY  = new HasMoney();
    this.DISPENSING = new Dispensing(); this.REFUNDING = new Refunding();
    this.state = this.IDLE;
    this.credit = 0;
    this.slots = new Map(Object.entries(slots));   // code -> {price, qty}
    this.bank  = new Map(Object.entries(bank).map(([k, v]) => [Number(k), v]));
  }
  // greedy over the coins we ACTUALLY HAVE, largest first
  makeChange(amount) {
    if (amount === 0) return [];
    const coins = [...this.bank.keys()].sort((a, b) => b - a);   // numeric sort!
    const used = [];
    const left = new Map(this.bank);
    for (const c of coins) {
      while (amount >= c && left.get(c) > 0) {
        amount -= c; left.set(c, left.get(c) - 1); used.push(c);
      }
    }
    return amount === 0 ? used : null;    // null = "I cannot pay this exactly"
  }
}
```
]

#trap[
`[...this.bank.keys()].sort()` with no comparator sorts *as text*. `[1, 5, 10]` becomes
`[1, 10, 5]`, so the machine would try the 1-coin before the 10-coin and hand out a fistful
of change. Numbers always need `(a, b) => a - b` (or `b - a` for descending). This is the
single most common JavaScript bug in an interview.
]

#ex(10, tier: 1, asked: "Capgemini · pattern")[The machine holds coins
$\{1 times 5, 5 times 4, 10 times 3\}$. Slot `A1` costs 25, `A2` costs 40 but has
`qty = 0`. Trace this button sequence: `select A1`, `insert 10`, `insert 10`, `select A1`,
`insert 10`, `select A1`, `tick`, `insert 50`, `select A2`, `tick`.
#sol[
#table(columns: (auto, auto, auto, 1fr),
  [*Step*], [*State before*], [*State after*], [*Why*],
  [`select A1`], [Idle], [Idle], [base `State.select` refuses — no money],
  [`insert 10`], [Idle], [HasMoney], [credit 0 #sym.arrow.r 10],
  [`insert 10`], [HasMoney], [HasMoney], [credit 20],
  [`select A1`], [HasMoney], [HasMoney], [$20 < 25$, asks for 5 more, no transition],
  [`insert 10`], [HasMoney], [HasMoney], [credit 30],
  [`select A1`], [HasMoney], [Dispensing], [$30 >= 25$, change $= 5$],
  [`tick`], [Dispensing], [Idle], [item fell, reset],
  [`insert 50`], [Idle], [HasMoney], [credit 50],
  [`select A2`], [HasMoney], [Refunding], [`qty === 0`],
  [`tick`], [Refunding], [Idle], [50 returned],
)

*The change step, in full.* Credit 30, price 25, so change owed $= 30 - 25 = 5$.

Coins sorted descending: $[10, 5, 1]$.
- Try 10: $5 >= 10$? No. Skip.
- Try 5: $5 >= 5$ and bank has 4 fives. Take one. Now $5 - 5 = 0$ left, bank fives $= 3$.
- Try 1: $0 >= 1$? No. Skip.

Amount left is 0, so return `[5]`. Success.
]
#ans[Ends back in Idle. Change handed out is a single 5-coin.]
]

#code(lang: "js", caption: "node vending.js — actual output")[
```
Idle       --select(A1)--> Idle       | Idle: cannot select now
Idle       --insert(10)--> HasMoney   | credit = 10
HasMoney   --insert(10)--> HasMoney   | credit = 20
HasMoney   --select(A1)--> HasMoney   | need 5 more
HasMoney   --insert(10)--> HasMoney   | credit = 30
HasMoney   --select(A1)--> Dispensing | dispensing A1, change [5]
Dispensing --tick()--> Idle       | item dropped -> Idle
Idle       --insert(50)--> HasMoney   | credit = 50
HasMoney   --select(A2)--> Refunding  | A2 sold out; refunding
Refunding  --tick()--> Idle       | refunded 50 -> Idle
```
]

#ex(11, tier: 1, asked: "Wipro · pattern")[The greedy change-maker can fail even when
exact change is possible. Give a coin bank where it fails, and decide what to ship.
#sol[
Take a bank of $\{25 times 1, 10 times 3, 1 times 0\}$ and change owed $= 30$.

Greedy, largest first:
- Try 25: $30 >= 25$, take it. Left $= 5$. Bank: 25-coin gone.
- Try 10: $5 >= 10$? No.
- Left is 5, not 0 $arrow.r$ greedy returns `null`, "no change".

But $10 + 10 + 10 = 30$ works. Greedy was wrong.

*The exact answer* is a bounded-coin dynamic program: `dp[a] = fewest coins to make a`,
filled for $a = 0 dots "amount"$, decrementing each coin's count. Cost is
$O("amount" times "coin types")$.

*Decision.* Ship greedy, and here is why, stated as a trade-off with both sides named:

#table(columns: (auto, 1fr),
  [*Greedy*], [Wins: 5 lines, $O(k log k)$, obviously correct to a reviewer. Loses: can refuse change it could actually make.],
  [*Bounded DP*], [Wins: never refuses when a solution exists. Loses: 25 lines, an array of size `amount`, and a bug surface in a machine that must never hang.],
)

Real machines use *denominations that are canonical* (1, 2, 5, 10, 20, 50). For a canonical
set, greedy is provably optimal, so the failure case never arises. I would ship greedy plus
one unit test asserting the coin set is canonical, and put the DP behind a feature flag for
markets with odd coins. That keeps the hot path five lines long.
]
#ans[Greedy fails on non-canonical coin sets. Ship greedy + a canonical-coin assertion.]
]

// ============================================================
#tier-header(2)
#section[Tier 2 · Design an expense-sharing app]

Four friends share costs on a trip. Anyone can add an expense, say who paid, and say how
to split it. The app must show, at any moment, who owes whom — and the app must never lose
a paisa.

#subsection[Move 1 — clarify]

#table(columns: (auto, 1fr),
  [*"How many split rules?"*], [Equal, exact amounts, percentages, shares. If the answer is "more later", split rules must be a plug point, not an `if`-chain.],
  [*"Do I show pairwise debts or net balances?"*], [Pairwise (A owes B 300, B owes C 300) is what people remember. Net (A is +500) is what settles fastest. I will store *net* and derive settlements, because pairwise storage grows as $n^2$ and gets tangled after every expense.],
  [*"Can an expense be edited or deleted?"*], [If yes, I cannot store only running totals — I must keep every expense and be able to recompute. That is the difference between a `Map` of balances and an append-only event list.],
  [*"Multi-currency?"*], [If yes, an expense stores its own currency plus the rate at the time. Converting at read time gives different answers every day. I will say "single currency" and move on.],
)

#subsection[Move 2 — the money rules]

#formulas(title: "Three invariants. Write them on the whiteboard before any code.")[
+ *Shares sum to the total.* For every expense, $sum "share"_i = "total"$ exactly, in paise.
+ *Net balances sum to zero.* $sum_i "net"_i = 0$ across all users, always. If it ever
  drifts, an expense was recorded wrongly.
+ *A settlement transfer is itself an expense* with payer = the debtor and a single share
  on the creditor. That way there is one code path, not two.
]

#code(lang: "js", caption: "Split rules as three small pure functions — the plug point")[
```js
// Money is in PAISE (integers). Never floats.
const Equal = (total, users) => {
  const base = Math.floor(total / users.length);
  const rem  = total - base * users.length;               // leftover paise
  return users.map((u, i) => [u, base + (i < rem ? 1 : 0)]);   // spread it, one each
};

const Exact = (total, users, amounts) => {
  const sum = amounts.reduce((a, b) => a + b, 0);
  if (sum !== total) throw new Error(`exact split ${sum} != total ${total}`);
  return users.map((u, i) => [u, amounts[i]]);
};

const Percent = (total, users, pct) => {
  const sum = pct.reduce((a, b) => a + b, 0);
  if (sum !== 100) throw new Error(`percents sum to ${sum}, not 100`);
  const shares = pct.map(p => Math.floor(total * p / 100));
  let rem = total - shares.reduce((a, b) => a + b, 0);
  for (let i = 0; rem > 0; i = (i + 1) % users.length) { shares[i]++; rem--; }
  return users.map((u, i) => [u, shares[i]]);
};
```
]

#code(lang: "js", caption: "The ledger: net balances, and the greedy settlement")[
```js
class Ledger {
  constructor() { this.net = new Map(); }       // user -> (paid minus owed), in paise
  bump(u, d) { this.net.set(u, (this.net.get(u) || 0) + d); }

  addExpense(payer, total, shares) {
    const sum = shares.reduce((a, [, v]) => a + v, 0);
    if (sum !== total) throw new Error(`shares ${sum} != total ${total}`);  // invariant 1
    this.bump(payer, total);
    for (const [u, v] of shares) this.bump(u, -v);
  }

  // greedy: biggest creditor meets biggest debtor
  settle() {
    const cred = [], debt = [];
    for (const [u, v] of this.net) {
      if (v > 0) cred.push([u, v]);
      else if (v < 0) debt.push([u, -v]);
    }
    cred.sort((a, b) => b[1] - a[1]);
    debt.sort((a, b) => b[1] - a[1]);
    const out = [];
    let i = 0, j = 0;
    while (i < cred.length && j < debt.length) {
      const pay = Math.min(cred[i][1], debt[j][1]);
      out.push([debt[j][0], cred[i][0], pay]);
      cred[i][1] -= pay; debt[j][1] -= pay;
      if (cred[i][1] === 0) i++;
      if (debt[j][1] === 0) j++;
    }
    return out;
  }
}
```
]

#ex(12, tier: 2, asked: "Grab · pattern")[Four friends A, B, C, D.

+ A pays 1200 for dinner, split equally among all four.
+ B pays 900 for a cab, split equally among A, B, C only.
+ C pays 600 for a movie, split exactly: A 100, C 200, D 300.

Compute every net balance, check the zero invariant, and produce the settlement.
#sol[
*Step 1 — turn each expense into shares (in rupees here; the code uses paise).*

Expense 1: equal among 4. $1200 div 4 = 300$ each, no remainder.
Shares: A 300, B 300, C 300, D 300. Sum $= 1200$. #sym.checkmark

Expense 2: equal among 3. $900 div 3 = 300$ each.
Shares: A 300, B 300, C 300. Sum $= 900$. #sym.checkmark

Expense 3: exact. A 100, C 200, D 300. Sum $= 100 + 200 + 300 = 600$. #sym.checkmark

*Step 2 — net = what you paid minus what you owed.*

#table(columns: (auto, auto, auto, auto),
  [*User*], [*Paid*], [*Owed*], [*Net*],
  [A], [1200], [$300 + 300 + 100 = 700$], [$1200 - 700 = +500$],
  [B], [900],  [$300 + 300 + 0 = 600$],   [$900 - 600 = +300$],
  [C], [600],  [$300 + 300 + 200 = 800$], [$600 - 800 = -200$],
  [D], [0],    [$300 + 0 + 300 = 600$],   [$0 - 600 = -600$],
)

*Step 3 — the zero check.*

$500 + 300 + (-200) + (-600) = 800 - 800 = 0$. #sym.checkmark The ledger is consistent.

*Step 4 — settle, biggest meets biggest.*

Creditors sorted: A 500, B 300. Debtors sorted: D 600, C 200.

- Round 1: D (600) meets A (500). Transfer $min(600, 500) = 500$.
  D owes 100 more; A is settled. Move to creditor B.
- Round 2: D (100) meets B (300). Transfer $min(100, 300) = 100$.
  D is settled; B still expects 200. Move to debtor C.
- Round 3: C (200) meets B (200). Transfer $min(200, 200) = 200$. Both settled.

Three transfers:
D #sym.arrow.r A 500, #h(6pt) D #sym.arrow.r B 100, #h(6pt) C #sym.arrow.r B 200.

*Step 5 — check.* Money out of D $= 500 + 100 = 600 = $ D's debt. #sym.checkmark
Money into B $= 100 + 200 = 300 = $ B's credit. #sym.checkmark
]
#ans[Nets: A $+500$, B $+300$, C $-200$, D $-600$. Settlement is 3 transfers.]
]

#diagram(height: 4.6cm, caption: "Left: the tangled pairwise view. Right: net balances, then three transfers.")[
  #dnode(0.2cm, 0.3cm, 1.7cm, 0.7cm, "A")
  #dnode(4.6cm, 0.3cm, 1.7cm, 0.7cm, "B")
  #dnode(0.2cm, 2.8cm, 1.7cm, 0.7cm, "C")
  #dnode(4.6cm, 2.8cm, 1.7cm, 0.7cm, "D")
  #darrow(1.95cm, 0.65cm, 4.55cm, 0.65cm, label: "300")
  #darrow(1.05cm, 1.05cm, 1.05cm, 2.75cm, label: "500")
  #darrow(4.55cm, 3.15cm, 1.95cm, 3.15cm, label: "300")
  #darrow(4.6cm, 2.8cm, 1.95cm, 1.05cm, label: "300")
  #darrow(5.45cm, 2.75cm, 5.45cm, 1.05cm, label: "300")
  #dnode(9.2cm, 0.3cm, 2.6cm, 0.7cm, "A  +500", fill: rgb("#dce9f2"))
  #dnode(9.2cm, 1.3cm, 2.6cm, 0.7cm, "B  +300", fill: rgb("#dce9f2"))
  #dnode(9.2cm, 2.3cm, 2.6cm, 0.7cm, "C  -200", fill: rgb("#f7efe4"))
  #dnode(9.2cm, 3.3cm, 2.6cm, 0.7cm, "D  -600", fill: rgb("#f7efe4"))
  #dnode(13.6cm, 0.3cm, 2.8cm, 0.7cm, "D pays A 500")
  #dnode(13.6cm, 1.5cm, 2.8cm, 0.7cm, "D pays B 100")
  #dnode(13.6cm, 2.7cm, 2.8cm, 0.7cm, "C pays B 200")
  #darrow(11.9cm, 1.8cm, 13.55cm, 1.2cm, label: "settle")
]

#code(lang: "js", caption: "node split.js — actual output")[
```
net (rupees):
  A 500.00
  B 300.00
  C -200.00
  D -600.00
sum of net = 0
settlement:
  D pays A 500.00
  D pays B 100.00
  C pays B 200.00
percent split of 1000 paise 33/33/34: [ [ 'X', 330 ], [ 'Y', 330 ], [ 'Z', 340 ] ]
equal split of 1000 paise among 3: [ [ 'X', 334 ], [ 'Y', 333 ], [ 'Z', 333 ] ]
```
]

#ex(13, tier: 2, asked: "Shopee · pattern")[Is the greedy settlement the *minimum* number
of transfers? Prove or disprove for the example above, and decide what to ship.
#sol[
*Upper bound first.* With $n$ people who have non-zero balances, you never need more than
$n - 1$ transfers: line everyone up and push the running imbalance along the line. Here
$n = 4$, so at most 3. Greedy gave exactly 3.

*Is 3 the minimum?* A settlement needs fewer than $n-1$ transfers only if the group splits
into two or more *sub-groups whose balances each sum to zero*. Check every subset:

#table(columns: (auto, auto, auto),
  [*Subset*], [*Sum*], [*Zero?*],
  [\{A, C\}], [$500 - 200 = 300$], [no],
  [\{A, D\}], [$500 - 600 = -100$], [no],
  [\{B, C\}], [$300 - 200 = 100$], [no],
  [\{B, D\}], [$300 - 600 = -300$], [no],
  [\{A, B, C\}], [$500 + 300 - 200 = 600$], [no],
  [\{A, B, D\}], [$500 + 300 - 600 = 200$], [no],
  [\{A, C, D\}], [$500 - 200 - 600 = -300$], [no],
  [\{B, C, D\}], [$300 - 200 - 600 = -500$], [no],
)

No proper subset sums to zero, so the group cannot be split. Minimum $= n - 1 = 3$.
Greedy is optimal *here*.

*In general it is not.* Finding the true minimum means finding the largest number of
zero-sum subsets, which is the partition problem — NP-hard. A backtracking search is
exponential.

#code(lang: "python", caption: "settle.py — the exact minimum, exponential, for checking only")[
```python
def min_transfers(net):
    debts = [v for v in net.values() if v != 0]

    def go(i, arr):
        while i < len(arr) and arr[i] == 0:
            i += 1
        if i == len(arr):
            return 0
        best = 10**9
        for j in range(i + 1, len(arr)):
            if arr[i] * arr[j] < 0:              # opposite signs can cancel
                arr[j] += arr[i]
                best = min(best, 1 + go(i + 1, arr))
                arr[j] -= arr[i]
        return best
    return go(0, debts)

case1 = {"A": 500, "B": 300, "C": -200, "D": -600}
print(case1, "-> minimum transfers =", min_transfers(case1))   # 3
```
]

*The trade-off, both sides named, then a decision.*

#table(columns: (auto, 1fr),
  [*Greedy*], [Wins: $O(n log n)$, ten lines, always correct (it always settles everyone), never more than $n-1$ transfers. Loses: occasionally one transfer more than the theoretical best.],
  [*Exact search*], [Wins: provably minimal. Loses: exponential — a 20-person trip can take minutes, and the app must respond in 100 ms.],
)

*Decision: ship greedy.* Real groups are 3 to 10 people, greedy is within one transfer of
optimal almost always, and "one extra UPI payment" costs the user nothing while a 3-second
spinner costs them the app. I would add the exact solver as a test-only oracle that asserts
greedy is within 1 of optimal on random inputs.
]
#ans[Here greedy is optimal (3 = $n-1$). In general it is not, but ship it anyway.]
]

#trap[
`Equal(1000, [X, Y, Z])` returns `[334, 333, 333]` — *not* three equal numbers. If your UI
shows "333.33 each", your ledger and your screen disagree by one paisa and a user will
screenshot it. Show the actual per-person integer, and always give the leftover to a
*deterministic* person (sorted user id), not a random one, or the number changes each time
the page reloads.
]

// ============================================================
#section[Tier 2 · Design seat booking for a cinema]

Now the one hard part is not classes. It is *two users, one seat, one millisecond*.

#subsection[Move 1 — clarify, then Move 2 — the numbers]

#table(columns: (auto, 1fr),
  [*"Can a user hold seats before paying?"*], [Yes — this is the whole design. A hold with a time-to-live is what makes payment possible without locking a seat forever.],
  [*"How long is the hold?"*], [5 minutes. Short enough that abandoned carts free up; long enough for a UPI payment.],
  [*"Can a booking be partly successful?"*], [No. Four seats or zero. That is an all-or-nothing rule and it decides whether I lock seats one by one or in one atomic step.],
  [*"Is the seat map per show or per screen?"*], [Per show. The same physical seat is free at 6 pm and sold at 9 pm.],
)

#formulas(title: "Scale estimate — show every division")[
*Assumptions I state out loud:* 12M daily active users; 3% of them book on a given day;
each user views 8 pages; a booking row is about 400 bytes; 6,000 cinemas, 5 screens each,
5 shows a day, 200 seats a screen.

*Browse traffic.*

$12,000,000 times 8 = 96,000,000$ page views a day

$96,000,000 div 86,400 = 1,111$ requests per second (average)

Peak is roughly 5x the average for an entertainment app (evening spike):
$1,111 times 5 = 5,555$ RPS peak.

*Booking traffic.*

$12,000,000 times 0.03 = 360,000$ bookings a day

$360,000 div 86,400 = 4.2$ bookings per second (average) — tiny.

But bookings are not spread out. Say 60% land in a 3-hour evening window
($3 times 3600 = 10,800$ seconds):

$360,000 times 0.6 = 216,000$ bookings in that window

$216,000 div 10,800 = 20$ bookings per second.

*The number that actually matters.* A blockbuster opens. 40,000 people hit *one show* in
the first minute:

$40,000 div 60 = 667$ lock attempts per second — all on the *same* handful of rows.

Average RPS is 4.2. The hot row sees 667. *Design for 667, not for 4.2.*

*Storage.*

Bookings: $360,000 times 365 = 131,400,000$ rows a year.

$131,400,000 times 400 "bytes" = 52,560,000,000 "bytes" = 52.6$ GB a year. One machine.

Seat inventory: $6,000 times 5 times 5 = 150,000$ shows a day.

$150,000 times 200 = 30,000,000$ seat rows a day.

At 50 bytes a row: $30,000,000 times 50 = 1,500,000,000 "bytes" = 1.5$ GB a day.

Keep 30 days hot: $1.5 times 30 = 45$ GB. Also one machine — but a *hot* one.
]

#subsection[Move 3 — the API surface]

#code(lang: "js", caption: "Three endpoints. The hold is a first-class resource.")[
```
POST /v1/shows/{showId}/holds
  body   { seats: ["C7","C8"], userId: "u_991", idemKey: "5f1c-..." }
  200    { holdId: "h_88x", expiresAt: 1730000300, seats: ["C7","C8"] }
  409    { error: "SEAT_TAKEN", seats: ["C7"] }          <- name WHICH seat

POST /v1/holds/{holdId}/confirm
  body   { paymentRef: "pay_7712", idemKey: "5f1c-..." }
  200    { bookingId: "b_4410", seats: ["C7","C8"], total: 76000 }
  410    { error: "HOLD_EXPIRED" }

DELETE /v1/holds/{holdId}          -> 204, seats free immediately
```
]

#note[
`idemKey` is not decoration. A phone on a bad network retries the POST. Without an
idempotency key the user gets two holds, or worse, two bookings and two charges. The server
stores `idemKey -> response` for 24 hours and replays the stored response on a repeat.
]

#subsection[Move 4 — the data model]

#code(lang: "sql", caption: "Seat state lives in ONE row per (show, seat). That row is the lock.")[
```sql
CREATE TABLE show_seat (
  show_id     BIGINT      NOT NULL,
  seat_label  VARCHAR(8)  NOT NULL,
  status      SMALLINT    NOT NULL,   -- 0 FREE, 1 HELD, 2 SOLD
  holder_id   BIGINT      NULL,
  hold_until  TIMESTAMP   NULL,
  price_paise INT         NOT NULL,
  version     INT         NOT NULL DEFAULT 0,
  PRIMARY KEY (show_id, seat_label)
);
CREATE INDEX ix_seat_expiry ON show_seat (hold_until) WHERE status = 1;

CREATE TABLE booking (
  booking_id  BIGINT PRIMARY KEY,
  show_id     BIGINT NOT NULL,
  user_id     BIGINT NOT NULL,
  seats       TEXT   NOT NULL,        -- "C7,C8"
  total_paise INT    NOT NULL,
  idem_key    VARCHAR(64) NOT NULL,
  created_at  TIMESTAMP NOT NULL,
  UNIQUE (idem_key)                   -- the retry guard, enforced by the database
);
```
]

The primary key `(show_id, seat_label)` is the whole trick. Because it is the primary key,
the database gives you a row lock on it for free, and a conditional `UPDATE` on it is
atomic without any application-level lock.

#subsection[Move 5 — the flow]

#diagram(height: 5.4cm, caption: "Hold, pay, confirm. The hold is taken BEFORE payment and expires on its own.")[
  #dnode(0.3cm, 0.1cm, 2.8cm, 0.7cm, "Client")
  #dnode(3.8cm, 0.1cm, 3.2cm, 0.7cm, "Booking service")
  #dnode(7.7cm, 0.1cm, 3.0cm, 0.7cm, "show_seat rows", fill: rgb("#dce9f2"))
  #dnode(11.4cm, 0.1cm, 2.6cm, 0.7cm, "Payments")
  #dnode(14.7cm, 0.1cm, 1.9cm, 0.7cm, "booking")
  #darrow(1.7cm, 0.8cm, 1.7cm, 5.0cm, dashed: true)
  #darrow(5.4cm, 0.8cm, 5.4cm, 5.0cm, dashed: true)
  #darrow(9.2cm, 0.8cm, 9.2cm, 5.0cm, dashed: true)
  #darrow(12.7cm, 0.8cm, 12.7cm, 5.0cm, dashed: true)
  #darrow(15.65cm, 0.8cm, 15.65cm, 5.0cm, dashed: true)
  #darrow(1.7cm, 1.3cm, 5.4cm, 1.3cm, label: "1 hold C7,C8")
  #darrow(5.4cm, 1.75cm, 9.2cm, 1.75cm, label: "2 conditional UPDATE")
  #darrow(9.2cm, 2.2cm, 5.4cm, 2.2cm, label: "3 2 rows changed")
  #darrow(5.4cm, 2.65cm, 1.7cm, 2.65cm, label: "4 holdId, 5 min")
  #darrow(1.7cm, 3.1cm, 12.7cm, 3.1cm, label: "5 pay")
  #darrow(12.7cm, 3.55cm, 5.4cm, 3.55cm, label: "6 paid webhook")
  #darrow(5.4cm, 4.0cm, 15.65cm, 4.0cm, label: "7 insert booking")
  #darrow(5.4cm, 4.45cm, 9.2cm, 4.45cm, label: "8 status = SOLD")
]

#subsection[Move 6 — the deep dive: making the hold atomic]

#code(lang: "sql", caption: "One statement. Read and write happen together, so no race exists.")[
```sql
UPDATE show_seat
   SET status = 1, holder_id = :user, hold_until = now() + interval '5 minutes',
       version = version + 1
 WHERE show_id = :show
   AND seat_label IN ('C7','C8')
   AND (status = 0 OR (status = 1 AND hold_until <= now()));
-- then check: did this statement change exactly 2 rows?
-- if not, ROLLBACK. All-or-nothing, enforced by row count.
```
]

#code(lang: "js", caption: "The same idea in code, so you can see the race and the fix")[
```js
class SeatStore {
  constructor(seats) {
    this.state = new Map(seats.map(s => [s, { status: "FREE", holder: null, until: 0 }]));
  }
  // WRONG: read, decide, write. Two callers can both pass the read.
  naiveHold(seat, user, now) {
    const s = this.state.get(seat);
    if (s.status !== "FREE") return false;
    // <-- another request can run right here
    s.status = "HELD"; s.holder = user; s.until = now + HOLD_MS;
    return true;
  }
  // RIGHT: one atomic compare-and-set. The store decides, not the caller.
  casHold(seat, user, now) {
    const s = this.state.get(seat);
    const expired = s.status === "HELD" && s.until <= now;
    if (!(s.status === "FREE" || expired)) return false;
    s.status = "HELD"; s.holder = user; s.until = now + HOLD_MS;
    return true;
  }
  confirm(seat, user, now) {
    const s = this.state.get(seat);
    if (s.status !== "HELD" || s.holder !== user || s.until <= now) return false;
    s.status = "SOLD"; s.until = 0;
    return true;
  }
}
```
]

#code(lang: "js", caption: "node seathold.js — actual output")[
```
naive, two racing holds -> [ true, true, 'u2' ] (both told YES, only u2 really has it)
cas u1 -> true
cas u2 -> false (correctly refused)
u2 confirm -> false
u1 confirm -> true
after 6 min, u2 cas -> true
u1 confirm late -> false
```
]

#ex(14, tier: 2, asked: "Agoda · pattern")[Why does the hold carry an expiry *timestamp*
rather than a background job that "unlocks abandoned seats"? What breaks if you use the
background job alone?
#sol[
*The timestamp approach.* The row says `hold_until = 12:05:00`. Any reader can decide for
itself whether the hold is alive, by comparing with the current time. No job needs to have
run.

*The job-only approach.* The job runs every 30 seconds and sets expired holds back to FREE.

What breaks:

+ *The job dies.* Nobody notices for 20 minutes. Every abandoned seat stays locked. The
  show looks sold out and you lose real money.
+ *The job is slow.* 30,000,000 seat rows a day. Scanning them all takes minutes, so the
  effective hold length is "5 minutes plus however long the job took", which is not a
  number you can tell a user.
+ *The job races the user.* At 12:05:00 exactly, the job frees the seat while the user's
  confirm is in flight. The user pays and gets nothing.

*The fix is both, with the timestamp as the source of truth.*
- The `WHERE` clause `(status = 0 OR (status = 1 AND hold_until <= now()))` means *any*
  incoming request can steal an expired hold. Correctness never depends on the job.
- The job still exists, but only as *housekeeping*: it rewrites expired rows to FREE so the
  "seats available" count on the browse page is honest. If it dies, bookings still work —
  only a counter goes stale.

That is the general rule: *make correctness depend on data, and make background jobs
depend on correctness — never the other way round.*
]
#ans[Timestamp = source of truth, job = cosmetic cleanup. Correctness must not need a cron.]
]

#ex(15, tier: 2, asked: "DBS · pattern")[667 lock attempts a second land on one show's
seat rows. The database starts timing out. Name two fixes, compare, and choose.
#sol[
*Why it hurts.* 667 requests all want the same 200 rows. Most pick popular seats, so maybe
80% target the same 20 middle rows. Each one takes a row lock, holds it for the length of
the transaction, and the rest queue. Queueing 500 connections behind 20 rows exhausts the
connection pool, and then *unrelated* queries fail too.

*Fix A — a virtual waiting room.* Before the seat map loads, put the user in a queue. Admit
$N$ users a second into the booking flow; everyone else sees a position number.

$"admit rate" = 50 "users/sec" arrow.r 667$ drops to 50, a 13x reduction.

- Wins: protects everything downstream, and the user sees an honest "you are number 4,120"
  instead of a spinner then a failure.
- Loses: a whole extra service, and a bad user experience for the 4,119 people behind.

*Fix B — hold seats in Redis first, database second.* `SET seat:{show}:{C7} u991 NX PX 300000`
is a single-threaded atomic operation, roughly 100,000 ops/sec on one node. The database
only sees writes for holds that *succeeded*, and only at confirm time.

$667 "attempts" arrow.r$ maybe $200$ succeed $arrow.r$ maybe 60 actually pay $arrow.r$
60 database writes. That is a 11x reduction in database writes.

- Wins: cheap, fast, one dependency you already have.
- Loses: Redis is now in the correctness path. If Redis loses data, two people can hold one
  seat, and you find out at the door.

*Decision: ship B, then add A only for known blockbusters.*

Reasoning: B removes the load at its source with one moving part, and the Redis failure
mode is containable — make the *database* the final authority at confirm time. The confirm
still runs the conditional `UPDATE`, so even if Redis hands out two holds for C7, exactly
one confirm will change a row and the other gets a clean 409 before any money moves. Redis
is an optimisation, not the truth. A is a big build and only pays off on maybe ten days a
year, so it waits until a launch actually hurts.
]
#ans[Redis `SET NX` hold in front, database conditional UPDATE as final authority. Waiting room only for launch days.]
]

#trap[
If Redis is your *only* lock, a Redis restart sells the same seat twice and you cannot
un-sell it. Always leave one authoritative check at the last moment before money moves —
a unique constraint or a conditional UPDATE in the database. Fast locks are for shedding
load; the slow lock is for being right.
]

#revision[
*The six moves, in order.* Cut scope $arrow.r$ nouns to classes $arrow.r$ draw the boxes
$arrow.r$ name the one hard part and the pattern you spend on it $arrow.r$ write the core
method in full $arrow.r$ say the concurrency story and one extension.

*The one hard part, per problem — memorise this table.*
#table(columns: (auto, auto, 1fr),
  [*Problem*], [*The one hard part*], [*What you reach for*],
  [Parking lot], [pricing and allocation keep changing], [Strategy objects, injected],
  [Vending machine], [behaviour depends on state], [State pattern, explicit transitions],
  [Splitwise], [money must never leak], [integer paise + a remainder rule],
  [Seat booking], [two people, one seat, one millisecond], [atomic compare-and-set + TTL hold],
  [Elevator bank], [which car, out of many], [a cost function you can tune],
  [Chess], ["is this move legal" is not local], [make-move / test / unmake],
)

*The three non-negotiables.*
+ *Money is an integer of the smallest unit.* Paise, not rupees. Never a float. Split
  remainders by an explicit rule (first payer takes the extra paise), and assert that the
  parts sum back to the whole.
+ *Time is a parameter, never `Date.now()` inside a method.* That is what makes a 24-hour
  parking fee testable in one millisecond.
+ *Ids are generated, not borrowed.* Number plates repeat across states; seat "A5" repeats
  in every screen in the country.

*Concurrency — the one-line answers.*
#table(columns: (auto, 1fr),
  [two cars, one spot], [allocate inside one atomic step; the loser is told "full", not
  given the same spot],
  [two clicks, one seat], [`SET NX` with a TTL in front for speed, and a *conditional
  `UPDATE`* in the database as the final authority],
  [fast lock fails], [the database check still holds. A fast lock sheds load; the slow lock
  is what makes you right],
  [held seat, user vanishes], [the hold carries an *expiry timestamp*, so it releases
  itself with no cleanup job needed],
  [667 attempts/s on one row], [that is contention, not throughput — queue behind one
  writer per show, or split the lock per seat],
)

*Numbers from this chapter.*
- a food-court bill: 900 bills over 2 hours $=$ 0.125 bills/s $times$ 20 items $=$ 2.5
  computations/s. Optimise for clarity, and *say* that you checked.
- Rs.10.00 split three ways $=$ 333 + 333 + 334 paise. The remainder is a decision, not a
  rounding accident.
- greedy settlement gives *at most* $n - 1$ transfers for $n$ people, and it is not always
  the true minimum. Say both halves.

*Sentences that score points.*
- "Getters and setters assumed — let me write `allocate` first."
- "This class is the only place that knows how to price a stay."
- "The scale here is 0.125 writes per second, so there is no performance question; I will
  optimise the design purely for change."
- "Redis is an optimisation, not the truth. The database has the last word before money
  moves."

*Traps, in the order they bite.*
+ 25 minutes of boilerplate, 4 minutes for the hard method.
+ Six patterns where two would do. Abstraction you cannot name a second user for.
+ Floating-point money.
+ `Date.now()` buried inside a fee calculation.
+ An enum that needs a new `switch` arm in four files every time a rule changes.
+ Forgetting that two users exist.
]
]
