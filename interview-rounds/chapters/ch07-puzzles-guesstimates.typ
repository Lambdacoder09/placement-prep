#import "../../shared/lib/style.typ": *

#chapter(num: 7, title: "Interview Puzzles & Guesstimates",
  tagline: "They are not testing your answer. They are testing how you think out loud.")[

#formulas(title: "What this chapter gives you")[
- A 5-step protocol (PAUSE) you say out loud for *every* puzzle.
- 24 worked puzzles, warm-up to Tier 3, with every step shown.
- 7 worked guesstimates using one repeatable funnel.
- A short list of anchor numbers to memorise. Nothing else is memorised.
- The exact words for "I am stuck" and "I do not know" that keep you in the game.
- Weak answer vs strong answer, side by side, with the change named.
]

#section("Why this round exists")

A puzzle round is cheap for the company and hard to fake. In 10 minutes the interviewer
learns four things that a coding test does not show.

#table(columns: (auto, 1fr, 1fr),
  [*What is scored*], [*What a weak candidate does*], [*What a strong candidate does*],
  [Structure], [Jumps straight to guessing numbers], [Names the method before computing],
  [Assumptions], [Hides them, or invents them silently], [States each one out loud, with a reason],
  [Arithmetic under pressure], [Freezes, or produces 7 digits], [Rounds to easy numbers, keeps going],
  [Coachability], [Defends a wrong answer], [Takes the hint, folds it in, restarts cleanly],
)

#note[
The score sheet in most companies has a line called *communication* that is worth as much as
*correctness*. A candidate who reaches the wrong number while thinking clearly out loud often
scores above a silent candidate who reaches the right one.
]

#trap[
*The single biggest mistake.* Silence. You think for 90 seconds, then say "42". The interviewer
has no data. From their side, a long silence and a lucky guess look identical. Say every step.
]

#section("The PAUSE protocol — say these five things every time")

#formulas(title: "PAUSE")[
*P — Play it back.* Repeat the question in your own words. "So we have 12 chips, exactly one is
fake, and I do not know if the fake is heavy or light. Correct?"

*A — Ask, then assume.* Ask at most two questions. If the interviewer says "you decide",
*state* the assumption: "I will assume the balance is exact and gives three outcomes."

*U — Use a smaller case.* Solve it for 3 chips or 2 people first. Always. This is the step
that separates a pass from a fail.

*S — Solve and state.* Do the general case. Say the numbers as you write them.

*E — Examine.* Sanity-check. "Is this in the right range? Does the extreme case still work?"
]

#diagram(height: 4.2cm, caption: "The same five steps, every puzzle, every time.")[
  #dnode(0pt, 10pt, 2.6cm, 1.1cm, "P\nPlay it back")
  #dnode(3.0cm, 10pt, 2.6cm, 1.1cm, "A\nAsk, then assume")
  #dnode(6.0cm, 10pt, 2.6cm, 1.1cm, "U\nUse a small case")
  #dnode(9.0cm, 10pt, 2.6cm, 1.1cm, "S\nSolve and state")
  #dnode(12.0cm, 10pt, 2.6cm, 1.1cm, "E\nExamine")
  #darrow(2.6cm, 24pt, 3.0cm, 24pt)
  #darrow(5.6cm, 24pt, 6.0cm, 24pt)
  #darrow(8.6cm, 24pt, 9.0cm, 24pt)
  #darrow(11.6cm, 24pt, 12.0cm, 24pt)
  #darrow(13.3cm, 46pt, 13.3cm, 70pt)
  #dnode(0pt, 70pt, 14.6cm, 0.9cm, "If E fails, go back to A and change one assumption out loud. That is a strength, not a failure.")
]

#subsection("Weak answer vs strong answer, same puzzle")

The puzzle: *a water tank has a leak that doubles in size every day. The tank is empty on day 30.
On which day was it half empty?*

#trap[
*WEAK.* "Day 15."

(pause)

"Because 30 divided by 2 is 15."
]

#sol[
*STRONG.* "Let me play it back: the leak doubles daily and the tank is fully empty on day 30. I
want the day it was half empty.

I will assume 'doubles' means the water lost per day doubles, so the amount remaining halves as I
step backwards one day.

Small case first. Suppose the tank emptied on day 3 instead. Day 3 is empty, so day 2 is half. So
the answer is always one day before the end, not half the days.

General case: day 30 is empty, so day 29 is half empty.

Examine: does 15 make sense? On day 15 the leak is $2^15$ times smaller than on day 30, so almost
nothing had drained yet. So 15 is clearly wrong and 29 is right."
]

#formulas(title: "What exactly changed")[
1. The strong answer *restated the problem* — this buys you 5 seconds of thinking time for free.
2. It *named the assumption* about what "doubles" means.
3. It *ran a 3-day version first*. That is where the insight came from.
4. It *checked the tempting wrong answer* (15) and explained why it fails.
5. Same length. Roughly 40 seconds either way. The difference is structure, not speed.
]

#note[
Read that strong answer again. It is not a script. It is the PAUSE skeleton with *this* puzzle's
words poured into it. When you practise, do not memorise the sentences — memorise the five slots
and fill them with whatever puzzle you are given.
]

#section("The six puzzle families")

Almost every interview puzzle is one of six shapes. Recognising the shape in the first 20 seconds
is most of the work.

#table(columns: (auto, 1fr, auto),
  [*Family*], [*Tell-tale sign*], [*Opening move*],
  [Information / weighing], [Balance, tests, questions, "minimum number of"], [Count the outcomes vs the answers],
  [Scheduling / crossing], [Limited resource, must return, timings], [Send the two slowest together],
  [Invariant / parity], [Toggling, flipping, colouring, "can you ever"], [Find something that never changes],
  [Counting / pigeonhole], ["At least", "guarantee", drawers, socks], [Assume the worst case, then add one],
  [Probability / expectation], [Random, chance, expected number of], [Enumerate the sample space first],
  [Game / backward induction], [Two players, optimal play, voting], [Solve the last move first],
)

#trick[
When you cannot tell the family, ask: *"what would happen with 2 instead of 100?"* Two is small
enough to draw on paper and large enough to show the pattern.
]

// =====================================================================
#tier-header(0)
// =====================================================================

These are reflex builders. Aim for under 60 seconds each, spoken out loud.

#ex(1, tier: 0, asked: "warm-up · rates")[
Five packing machines fill five cartons in five minutes. How long do 100 machines take to fill
100 cartons?
]
#sol[
*U — small case.* Five machines, five cartons, five minutes. So *one* machine fills *one* carton
in five minutes. The five machines are working in parallel, not sharing one carton.

*S — general.* One machine takes 5 minutes per carton. Give 100 machines one carton each. They all
work at the same time. Total time is still 5 minutes.

*E — examine.* Machines per carton is 1 in both cases, so nothing changed. Good.
]
#ans[5 minutes]
#trap[
The trap answer is 100 minutes. It comes from reading "5, 5, 5" as a ratio to scale up. Always ask
*how many machines per carton*, not how many machines in total.
]

#ex(2, tier: 0, asked: "warm-up · algebra in disguise")[
An ID badge and its lanyard cost Rs 110 together. The badge costs Rs 100 more than the lanyard.
What does the lanyard cost?
]
#sol[
*P.* Two items, total 110, difference 100.

*S.* Let the lanyard be $x$. Then the badge is $x + 100$.
$ x + (x + 100) = 110 $
$ 2x = 10 $
$ x = 5 $

So the lanyard is Rs 5 and the badge is Rs 105.

*E.* Check both conditions. Sum: $5 + 105 = 110$. Difference: $105 - 5 = 100$. Both hold.
]
#ans[Rs 5]
#trap[
Almost everyone says Rs 10 first. Then the badge is Rs 110 and the total is Rs 120, not Rs 110.
The check step catches it in three seconds. Never skip the check.
]

#ex(3, tier: 0, asked: "warm-up · counting")[
Nine interns are in a room. Every intern shakes hands with every other intern exactly once. How
many handshakes happen?
]
#sol[
*U — small case.* With 2 people: 1 handshake. With 3 people: 3. With 4 people: 6.

*S.* Each of the 9 people shakes 8 hands, giving $9 times 8 = 72$. But that counts each handshake
from both sides, so divide by 2.
$ (9 times 8) / 2 = 36 $

*E.* Test the formula on the small case: $ (4 times 3) / 2 = 6 $. Matches.
]
#ans[36 handshakes]

#ex(4, tier: 0, asked: "warm-up · relative speed")[
Two delivery riders start 60 km apart and ride towards each other, one at 25 km/h and one at
35 km/h. A drone flies back and forth between them at 50 km/h until they meet. How far does the
drone fly?
]
#sol[
*A — assume.* The drone turns instantly and never stops.

*The insight.* Do not track the zig-zag. Track *time*.

*S — step 1: when do the riders meet?* They close the gap at $25 + 35 = 60$ km/h.
$ "time" = 60/60 = 1 "hour" $

*Step 2: how far does the drone fly in that hour?* It never stops, so
$ 50 "km/h" times 1 "h" = 50 "km" $

*E.* The drone is slower than the two riders combined, so it should cover less than 60 km. 50 < 60.
Good.
]
#ans[50 km]
#trick[
Any "back and forth until they meet" puzzle is solved by finding the *meeting time* and
multiplying. Never sum the individual legs.
]

#ex(5, tier: 0, asked: "warm-up · pigeonhole")[
A drawer holds 12 black socks, 12 blue socks and 12 grey socks, all mixed, in the dark. How many
socks must you take out to be *sure* of a matching pair?
]
#sol[
*A — assume.* "Sure" means in the worst case, not on average.

*S.* Worst case: you pull one of each colour — black, blue, grey. Three socks, no pair. The fourth
sock must repeat one of those three colours.
$ "colours" + 1 = 3 + 1 = 4 $

*E.* Could 3 ever be enough? Yes, by luck, but not *guaranteed*. The question says "sure", so 4.
]
#ans[4 socks]

#ex(6, tier: 0, asked: "warm-up · clocks")[
In 12 hours, how many times do the hour hand and the minute hand overlap?
]
#sol[
*S.* The minute hand does 12 laps in 12 hours; the hour hand does 1. The minute hand gains
$12 - 1 = 11$ laps on the hour hand. Each full lap gained is exactly one overlap.

So there are 11 overlaps in 12 hours, spaced $12/11 approx 1.09$ hours apart.

*E.* Naively you might say 12, once per hour. But between 11:00 and 12:00 there is no separate
overlap — the 11th overlap *is* 12:00. That is why the count is 11, not 12.
]
#ans[11 times]

// =====================================================================
#tier-header(1)
// =====================================================================

Tier 1 puzzles are the standard set. They are template-able: learn the move, and the whole
family falls.

#ex(7, tier: 1, asked: "Infosys · pattern")[
Four lab partners must cross a narrow catwalk at night. They have one working headlamp. At most
two may cross at a time, and the headlamp must be carried each way. Alone they take 1, 2, 7 and
10 minutes. A pair moves at the *slower* person's speed. What is the fastest everyone is across?
]
#sol[
Call them A(1), B(2), C(7), D(10).

*U — small case, 2 people.* A and B cross together: 2 minutes. Done. No return needed.

*The greedy idea that people try first.* Always send the fastest person as the escort:
#table(columns: (auto, auto, auto),
  [*Move*], [*Who*], [*Cost*],
  [cross], [A + D], [10],
  [return], [A], [1],
  [cross], [A + C], [7],
  [return], [A], [1],
  [cross], [A + B], [2],
  [*Total*], [], [*21*],
)

*The better idea.* The two slow people, C and D, each cost a full crossing. Pair them so that
*one* crossing pays for both:
#table(columns: (auto, auto, auto),
  [*Move*], [*Who*], [*Cost*],
  [cross], [A + B], [2],
  [return], [A], [1],
  [cross], [C + D], [10],
  [return], [B], [2],
  [cross], [A + B], [2],
  [*Total*], [], [*17*],
)

*E — why is 17 the floor?* D must cross, costing at least 10. C must cross, and if C crosses alone
or with a fast person that is 7 more, giving 17 at best; pairing C with D makes C free but then you
need two fast people already on the far side to ferry the lamp, which is the 2 + 1 + 2 + 2 above.
Either way you land on 17.
]
#ans[17 minutes]

Here is a small search that proves it, by trying every legal sequence.

#code(lang: "js", caption: "catwalk.js — brute force over all crossing plans")[
```js
const T = { A: 1, B: 2, C: 7, D: 10 };
const names = Object.keys(T);
let best = Infinity, bestPlan = null;

function subsets(arr, k) {
  return k === 0 ? [[]]
    : arr.flatMap((v, i) => subsets(arr.slice(i + 1), k - 1).map(r => [v, ...r]));
}

function go(left, right, time, lampLeft, plan) {
  if (time >= best) return;                  // prune
  if (left.length === 0) { best = time; bestPlan = plan; return; }
  if (lampLeft) {
    for (const pair of [...subsets(left, 2), ...subsets(left, 1)]) {
      const cost = Math.max(...pair.map(p => T[p]));
      go(left.filter(x => !pair.includes(x)), [...right, ...pair],
         time + cost, false, [...plan, `-> ${pair.join('+')} (${cost})`]);
    }
  } else {
    for (const p of right) {
      go([...left, p], right.filter(x => x !== p),
         time + T[p], true, [...plan, `<- ${p} (${T[p]})`]);
    }
  }
}

go(names, [], 0, true, []);
console.log('minimum crossing time =', best, 'minutes');
console.log('plan:', bestPlan.join('  '));
```
]
#code(lang: "text", caption: "output")[
```text
minimum crossing time = 17 minutes
plan: -> A+B (2)  <- A (1)  -> C+D (10)  <- B (2)  -> A+B (2)
```
]
#trick[
The rule for the whole family: *ship the two slowest together, and pre-position a fast pair to
ferry the lamp back.* It generalises to 5, 6 or 20 people.
]

#ex(8, tier: 1, asked: "TCS NQT · pattern")[
You have a 5-litre can and a 3-litre can, no markings, and a tap. Measure exactly 4 litres.
]
#sol[
*A — assume.* You may fill, empty, and pour from one can into the other until it is full.

*S — the steps.*
#table(columns: (auto, 1fr, auto),
  [*Step*], [*Action*], [*(5L, 3L)*],
  [1], [Fill the 5 L can], [(5, 0)],
  [2], [Pour 5 L into 3 L until full], [(2, 3)],
  [3], [Empty the 3 L can], [(2, 0)],
  [4], [Pour the 2 L across], [(0, 2)],
  [5], [Fill the 5 L can], [(5, 2)],
  [6], [Pour into the 3 L can — it takes only 1 more litre], [(4, 3)],
)

Four litres are now in the 5 L can.

*E.* Every step conserves water or uses the tap. Step 6 works because the 3 L can already held 2,
so it accepted exactly 1.
]
#ans[Six steps; 4 L sits in the 5-litre can]

#code(lang: "js", caption: "jugs.js — BFS finds the shortest sequence")[
```js
function jugs(cap1, cap2, target) {
  const seen = new Set(['0,0']);
  let frontier = [[[0, 0], []]];
  while (frontier.length) {
    const next = [];
    for (const [[a, b], path] of frontier) {
      if (a === target || b === target) return [...path, `(${a},${b})`];
      const moves = [
        [[cap1, b], `fill ${cap1}L`],  [[a, cap2], `fill ${cap2}L`],
        [[0, b],    `empty ${cap1}L`], [[a, 0],    `empty ${cap2}L`],
        [[a - Math.min(a, cap2 - b), b + Math.min(a, cap2 - b)], `pour ${cap1}L -> ${cap2}L`],
        [[a + Math.min(b, cap1 - a), b - Math.min(b, cap1 - a)], `pour ${cap2}L -> ${cap1}L`],
      ];
      for (const [st, label] of moves) {
        const k = st.join(',');
        if (!seen.has(k)) { seen.add(k); next.push([st, [...path, `${label} -> (${st})`]]); }
      }
    }
    frontier = next;
  }
  return null;
}
for (const step of jugs(5, 3, 4)) console.log('  ' + step);
```
]
#code(lang: "text", caption: "output")[
```text
  fill 5L -> (5,0)
  pour 5L -> 3L -> (2,3)
  empty 3L -> (2,0)
  pour 5L -> 3L -> (0,2)
  fill 5L -> (5,2)
  pour 5L -> 3L -> (4,3)
  (4,3)
```
]
#note[
The general rule: with cans of size $a$ and $b$ you can measure any multiple of $gcd(a, b)$ up to
$max(a, b)$. Here $gcd(5, 3) = 1$, so every whole number from 1 to 5 is reachable. Say this line
in the interview — it shows you saw the family, not just the instance.
]

#ex(9, tier: 1, asked: "Wipro · pattern")[
Nine identical-looking power banks. Exactly one is heavier than the rest. You have a balance
scale. Find the heavy one in two weighings.
]
#sol[
*The counting bound first.* Each weighing has 3 outcomes: left down, balanced, right down. Two
weighings give $3 times 3 = 9$ outcomes. There are 9 possible answers. So 2 weighings is exactly
enough — and this tells you to split into *three* groups, not two.

*S — weighing 1.* Split into groups of 3: X = {1,2,3}, Y = {4,5,6}, Z = {7,8,9}. Weigh X vs Y.
- X goes down $=>$ the heavy one is in X.
- Balanced $=>$ it is in Z.
- Y goes down $=>$ it is in Y.

Either way you are left with 3 candidates.

*S — weighing 2.* Take those 3 candidates, weigh one against another.
- One side down $=>$ that is the heavy one.
- Balanced $=>$ it is the third one, the one you left out.

*E.* Two weighings, always. Never three.
]
#ans[2 weighings]
#trick[
A balance gives $log_3$ information, not $log_2$. For $n$ items with one known-heavy fake you
need $ceil(log_3 n)$ weighings. For $n = 27$ that is 3. Always split into thirds.
]

#ex(10, tier: 1, asked: "Capgemini · pattern")[
You have two lengths of fuse cord. Each burns away completely in exactly 60 minutes, but the cord
is uneven, so half the cord does *not* mean 30 minutes. Using only these two cords and a lighter,
measure exactly 45 minutes.
]
#sol[
*The insight.* You cannot trust length, but you *can* trust that lighting *both ends* halves the
time, whatever the unevenness — the two flames together consume the whole cord, and the whole cord
is 60 minutes of burn.

*S — the steps.*
1. At time 0, light cord A at *both* ends and cord B at *one* end.
2. Cord A is gone after 30 minutes. At that moment, cord B has 30 minutes of burn left in it.
3. Immediately light cord B's *other* end. Now B is burning from both ends, so its remaining
   30 minutes of burn takes 15 minutes.
4. $30 + 15 = 45$ minutes when cord B is gone.

*E.* Does unevenness break anything? No. Step 2 relies only on "total burn time", not on position.
]
#ans[45 minutes]
#trap[
The wrong move is to try to fold a cord in half. Uneven burning means the midpoint of the *length*
is not the midpoint of the *time*. Say this out loud — interviewers wait for it.
]

#ex(11, tier: 1, asked: "Accenture · pattern")[
Three switches outside a sealed server room control three bulbs inside. You may flip switches as
much as you like, but you may open the door and enter *once*. Match each switch to its bulb.
]
#sol[
*A — ask first.* "Are these filament bulbs that get warm?" If the interviewer says yes, the heat
channel is open. If they say LED, you must ask for a different extra channel (a dimmer, a helper,
or a second entry). *Asking this is the point of the puzzle.*

*S — with warm bulbs.*
1. Turn switch 1 ON. Wait 10 minutes.
2. Turn switch 1 OFF. Turn switch 2 ON. Enter immediately.
3. Inside:
  - the bulb that is *lit* $->$ switch 2
  - the bulb that is *off but warm* $->$ switch 1
  - the bulb that is *off and cold* $->$ switch 3

*E — why does this work?* One visit gives you only one bit per bulb if you look at light alone,
and you need to tell three states apart. Heat adds a second channel, so each bulb carries
2 bits worth of state: (lit or not) times (warm or not).
]
#ans[Use light AND heat as two separate signals]
#note[
The strong candidate says the sentence "I need more than one bit per bulb, so I need a second
physical channel." That sentence is what gets scored, not the switch order.
]

#ex(12, tier: 1, asked: "Cognizant · pattern")[
A corridor has 100 lockers, all closed. Student 1 opens every locker. Student 2 changes every 2nd
locker (2, 4, 6, ...). Student 3 changes every 3rd locker. This continues to student 100. Which
lockers are open at the end?
]
#sol[
*U — small case, 10 lockers.* Track locker 6. It is touched by students 1, 2, 3 and 6 — that is
4 touches, an even number, so it ends *closed*. Track locker 9: students 1, 3 and 9 — 3 touches,
odd, so it ends *open*.

*The pattern.* Locker $n$ is touched once per *divisor* of $n$. A locker ends open exactly when
$n$ has an odd number of divisors.

*Why would divisors be odd?* Divisors normally come in pairs: $1 times 12$, $2 times 6$,
$3 times 4$ — an even count. The pairing only breaks when a number is its own partner, that is
when $n = k times k$.

*S.* So the open lockers are the perfect squares:
$ 1, 4, 9, 16, 25, 36, 49, 64, 81, 100 $

That is 10 lockers.

*E.* $sqrt(100) = 10$, so exactly 10 squares are at or below 100. Consistent.
]
#ans[The 10 perfect squares: 1, 4, 9, 16, 25, 36, 49, 64, 81, 100]

#ex(13, tier: 1, asked: "TCS Digital · pattern")[
A digital clock shows hours and minutes in 24-hour form, from 00:00 to 23:59. On how many minutes
of the day do all four digits read the same forwards and backwards (a palindrome), like 12:21?
]
#sol[
*A — assume.* Format is HH:MM with leading zeros, so 01:10 counts.

*S.* A palindrome means digit 1 = digit 4 and digit 2 = digit 3. Write the time as $H_1 H_2 : M_1 M_2$.
So $M_2 = H_1$ and $M_1 = H_2$. The minutes are fully decided by the hour. So *count valid hours*.

Go hour by hour and check that the forced minutes are legal (minutes must be 00 to 59, so
$M_1 <= 5$, which means $H_2 <= 5$).

- Hours 00 to 09: $H_1 = 0$, $H_2$ runs 0 to 9, but we need $H_2 <= 5$. That is
  00, 01, 02, 03, 04, 05 $->$ *6 hours*.
- Hours 10 to 19: $H_1 = 1$, need $H_2 <= 5$: 10, 11, 12, 13, 14, 15 $->$ *6 hours*.
- Hours 20 to 23: $H_1 = 2$, $H_2$ runs 0 to 3, all are $<= 5$ $->$ *4 hours*.

$ 6 + 6 + 4 = 16 $

*E — spot check.* Hour 15 forces minutes $M_1 M_2 = 5 1$, so 15:51. Reversed that is 15:51. Correct.
Hour 16 would force 16:61, which is not a real minute — and indeed we excluded it.
]
#ans[16 minutes per day]

// =====================================================================
#tier-header(2)
// =====================================================================

Tier 2 puzzles wear business clothes. The maths is still small, but the setup is a product or
operations story and there are usually two steps.

#ex(14, tier: 2, asked: "Grab · pattern")[
A warehouse has three sealed racks. Exactly one holds a working GPU; the other two are empty. You
point at rack 1. The technician, who knows what is inside every rack, opens rack 3 and shows it is
empty. He offers to let you switch to rack 2. Should you switch?
]
#sol[
*P.* Three racks, one prize, you pick, a knowing host reveals an empty one that is not yours, then
offers a swap.

*A — the assumption that decides everything.* The technician *knows* the contents and will
*always* open an empty rack that you did not pick. State this out loud. If he opened a rack at
random and it happened to be empty, the answer changes.

*U — enumerate all three cases.* Suppose the GPU is equally likely in each rack and you always
pick rack 1.

#table(columns: (auto, 1fr, auto, auto),
  [*GPU is in*], [*Technician must open*], [*Stay wins?*], [*Switch wins?*],
  [Rack 1], [rack 2 or 3], [yes], [no],
  [Rack 2], [rack 3 (forced)], [no], [yes],
  [Rack 3], [rack 2 (forced)], [no], [yes],
)

*S.* Staying wins in 1 of 3 equally likely worlds. Switching wins in 2 of 3.
$ P("stay") = 1/3, quad P("switch") = 2/3 $

*E — why it feels wrong.* Your first pick was made with no information and stays a $1/3$ shot. The
technician's action moves *all* the remaining probability onto the one rack he did not open.
Switching doubles your odds.
]
#ans[Switch. It wins 2/3 of the time.]

#code(lang: "js", caption: "racks.js — 200,000 simulated trials confirm the split")[
```js
function trial(switchDoor, rnd) {
  const prize = Math.floor(rnd() * 3);
  const pick  = Math.floor(rnd() * 3);
  const open  = [0, 1, 2].filter(r => r !== pick && r !== prize)[0];
  if (!switchDoor) return pick === prize;
  const final = [0, 1, 2].filter(r => r !== pick && r !== open)[0];
  return final === prize;
}

function mc(switchDoor, n = 200000) {
  let seed = 12345;
  const rnd = () => (seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648;
  let win = 0;
  for (let i = 0; i < n; i++) if (trial(switchDoor, rnd)) win++;
  return win / n;
}

console.log('stay   wins about', mc(false).toFixed(3), '(exact 1/3 =', (1/3).toFixed(3) + ')');
console.log('switch wins about', mc(true).toFixed(3),  '(exact 2/3 =', (2/3).toFixed(3) + ')');
```
]
#code(lang: "text", caption: "output")[
```text
stay   wins about 0.328 (exact 1/3 = 0.333)
switch wins about 0.672 (exact 2/3 = 0.667)
```
]
#trick[
If the interviewer will not accept $2/3$, scale the puzzle up out loud: *"imagine 100 racks. You
pick one. The technician opens 98 empty ones. Would you still keep your first pick?"* Almost
nobody says yes. That is the same argument.
]

#ex(15, tier: 2, asked: "Shopee · pattern")[
A QA batch has 1000 sachets. Exactly one is contaminated. A test strip shows a result after
24 hours, and you have only 24 hours before shipping. What is the smallest number of test strips
that guarantees you find the bad sachet?
]
#sol[
*P.* One round of tests, all in parallel, 1000 candidates.

*A — assume.* A strip can be dipped in a *mixture* of many sachets, and it turns positive if any
drop of the contaminated sachet is present.

*The information count.* Each strip returns 1 bit: positive or negative. With $k$ strips you can
tell apart $2^k$ situations.
$ 2^9 = 512 < 1000, quad 2^10 = 1024 >= 1000 $
So $k = 10$ strips.

*S — the construction.* Number the sachets $0$ to $999$ and write each number in 10-bit binary.
Strip $i$ receives a drop from every sachet whose bit $i$ is a 1.

After 24 hours, read the strips: positive = 1, negative = 0. Those 10 bits, read as a binary
number, *are* the sachet number.

*Worked case.* Suppose sachet 37 is bad. In binary, $37 = 0000100101$. So strips 0, 2 and 5 turn
positive and the rest stay negative. Reading the pattern back gives 37.

*E.* Could 9 strips ever work? 9 bits name only 512 sachets, and 1000 > 512, so two different
sachets would have to share a pattern. Then you could not tell them apart. So 10 is the minimum.
]
#ans[10 test strips]
#note[
Say the words "each test gives me one bit, so $k$ tests give me $2^k$ distinguishable outcomes".
That sentence is the whole puzzle. The binary labelling is just bookkeeping after it.
]

#ex(16, tier: 2, asked: "Agoda · pattern")[
A training batch has 30 people. What is the chance that at least two of them share a birthday?
Estimate it, then say whether you would bet on it.
]
#sol[
*A — assume.* 365 days, all equally likely, no twins, ignore leap years. Say all four aloud.

*The move.* "At least two share" is messy. Its opposite, "all 30 are different", is a clean
product. Compute the opposite and subtract.

*S.* Line the 30 people up. The first may have any birthday. The second must dodge 1 day, the
third must dodge 2, and so on.
$ P("all different") = 365/365 times 364/365 times 363/365 times dots times 336/365 $

That is 30 factors. Each is slightly under 1, and they multiply down fast.

*Fast mental estimate.* The number of *pairs* is $ (30 times 29)/2 = 435 $. Each pair collides with
chance $1/365$. So the expected number of collisions is about $435/365 approx 1.19$. When the
expected count of a rare event is above 1, the chance of "at least one" is already well past a half.

*S — the actual number.* The exact product gives about *0.706*, roughly 71%.

*E.* Yes, I would bet on it. And note the crossover: 23 people is where it passes 50%.
]
#ans[About 71%]

#code(lang: "js", caption: "birthday.js — exact chance for several batch sizes")[
```js
function sharedBirthday(n) {
  let allDifferent = 1;
  for (let i = 0; i < n; i++) allDifferent *= (365 - i) / 365;
  return 1 - allDifferent;
}
for (const n of [10, 23, 30, 50, 60]) {
  console.log('n =', String(n).padStart(2), '->', (sharedBirthday(n) * 100).toFixed(1) + '%');
}
```
]
#code(lang: "text", caption: "output")[
```text
n = 10 -> 11.7%
n = 23 -> 50.7%
n = 30 -> 70.6%
n = 50 -> 97.0%
n = 60 -> 99.4%
```
]
#trick[
Memorise one number: *23 people, 50%*. From there, 30 is "about 70", 50 is "about 97". That is
enough to answer any version of this question without computing.
]

#ex(17, tier: 2, asked: "Sea / Shopee · pattern")[
You must drop-test a new phone from a 100-floor test tower to find the highest floor it survives.
You have exactly *two* test units. A broken unit cannot be reused. Minimise the number of drops in
the *worst case*.
]
#sol[
*P.* Find the highest safe floor $f$ (0 to 100) using at most 2 phones, minimising worst-case drops.

*U — with one phone only.* You cannot skip: if it breaks you learn nothing about the floors below.
So you climb 1, 2, 3, ... and the worst case is 100 drops.

*The naive two-phone plan.* Drop phone 1 every 10 floors. Worst case: it survives 10, 20, ..., 90
and breaks at 100 (10 drops), then phone 2 climbs 91 to 99 (9 drops). Worst case = 19.

*The fix — balance the work.* The problem with fixed steps of 10 is that a late break costs the
most. Make the steps *shrink*. If the first jump is $k$ floors, then after one drop you have
$k - 1$ drops of budget left for phone 2, so the next jump should be $k - 1$, then $k - 2$, and so on.

*S.* Total floors covered must reach 100:
$ k + (k-1) + (k-2) + dots + 1 = (k(k+1))/2 >= 100 $
Try $k = 13$: $ (13 times 14)/2 = 91 $. Not enough.
Try $k = 14$: $ (14 times 15)/2 = 105 >= 100 $. Enough.

So the first drop is from floor 14, then 27, 39, 50, 60, 69, 77, 84, 90, 95, 99, 100.

*E — check the worst case.* If it breaks at floor 14, phone 2 tests 1 to 13, which is 13 more
drops: $1 + 13 = 14$. If it survives everything to 99 and breaks at 100, the count of drops is
also 14. The plan is balanced, which is the sign of an optimum.
]
#ans[14 drops in the worst case, starting at floor 14]
#trap[
Do not answer "binary search, so 7". Binary search needs a phone you can keep breaking. With only
two units the *first* break must leave a range you can walk linearly.
]

#ex(18, tier: 2, asked: "LINE MAN · pattern")[
A snack pack contains one of 5 different stickers, equally likely. On average, how many packs must
a customer buy to collect all 5?
]
#sol[
*The move.* Split the journey into 5 stages: the wait for the 1st new sticker, then the 2nd, and so
on. Expectations add, even when the stages are not independent.

*S — stage by stage.* When you already hold $i$ stickers, the chance a fresh pack is new is
$(5 - i)/5$. The average number of packs to get one success at probability $p$ is $1/p$.

#table(columns: (auto, auto, auto),
  [*Stickers held*], [*Chance next pack is new*], [*Average packs to wait*],
  [0], [$5/5$], [$1.00$],
  [1], [$4/5$], [$1.25$],
  [2], [$3/5$], [$1.67$],
  [3], [$2/5$], [$2.50$],
  [4], [$1/5$], [$5.00$],
)

$ E = 5/5 + 5/4 + 5/3 + 5/2 + 5/1 = 5 (1 + 1/2 + 1/3 + 1/4 + 1/5) approx 11.42 $

*E.* It must be more than 5 (you cannot do better than perfect luck) and the last sticker alone
costs 5 packs on average. 11.4 sits sensibly between.
]
#ans[About 11.4 packs]

#code(lang: "js", caption: "stickers.js — formula against 100,000 simulated customers")[
```js
function expectedPackets(k) {
  let e = 0;
  for (let i = 1; i <= k; i++) e += k / i;
  return e;
}
console.log('exact expectation for 5 stickers =', expectedPackets(5).toFixed(3));

let seed = 99;
const rnd = () => (seed = (seed * 1103515245 + 12345) % 2147483648) / 2147483648;
let total = 0;
const runs = 100000;
for (let r = 0; r < runs; r++) {
  const seen = new Set();
  let c = 0;
  while (seen.size < 5) { seen.add(Math.floor(rnd() * 5)); c++; }
  total += c;
}
console.log('simulation average          =', (total / runs).toFixed(3));
```
]
#code(lang: "text", caption: "output")[
```text
exact expectation for 5 stickers = 11.417
simulation average          = 11.439
```
]

#ex(19, tier: 2, asked: "DBS · pattern")[
You need to pick one of two team members fairly, but the only randomiser you have is a bent coin
that lands heads with some unknown probability $p$, where $0 < p < 1$. How do you get a fair 50-50
decision?
]
#sol[
*The insight.* One toss is biased. But a *pair* of tosses has two outcomes that are equally likely
no matter what $p$ is.

*S.* Toss the coin twice.
$ P("HT") = p (1 - p), quad P("TH") = (1 - p) p $
These are exactly equal for every $p$. The other two outcomes, HH and TT, are useless.

*The procedure.*
1. Toss twice.
2. If you see HT, pick member A. If you see TH, pick member B.
3. If you see HH or TT, throw the pair away and start again.

*E — does it always end?* The chance of a useful pair is $2 p (1-p) > 0$, so the chance of never
finishing shrinks to zero. If $p = 0.9$, a pair is useful with chance $2 (0.9)(0.1) = 0.18$, so you
need about $1/0.18 approx 5.6$ pairs, that is roughly 11 tosses. Slow, but exactly fair.
]
#ans[Toss in pairs; HT means A, TH means B, repeat on HH or TT]

// =====================================================================
#tier-header(3)
// =====================================================================

Tier 3 puzzles need one non-obvious idea. You will not find it by grinding. You find it by asking
"what stays the same?" or "what does the last move look like?"

#ex(20, tier: 3, asked: "Goldman Sachs · pattern")[
Twelve identical chips. Exactly one is a fake. The fake may be *heavier or lighter* than a genuine
chip, and you do not know which. Using a balance scale three times, identify the fake *and* say
whether it is heavy or light.
]
#sol[
*The counting bound first — always say this.* There are $12 times 2 = 24$ possible truths
(each chip, heavy or light). Three weighings give $3^3 = 27$ outcomes. $27 >= 24$, so three is
*just* enough. That tells you the weighings must be near-perfectly balanced: each of the three
outcomes should split the remaining candidates into nearly equal thirds.

*A — assume.* The balance is exact, and each weighing has exactly three outcomes.

*S — weighing 1.* Weigh ${1,2,3,4}$ against ${5,6,7,8}$.

*Case A: balanced.* The fake is one of 9, 10, 11, 12, and chips 1 to 8 are known genuine.
That is 8 truths left, and $3^2 = 9 >= 8$, so two weighings suffice.
- *Weighing 2:* ${9,10,11}$ vs ${1,2,3}$ (known genuine).
  - *Balanced* $=>$ the fake is 12. *Weighing 3:* 12 vs 1 tells you heavy or light.
  - *Left down* $=>$ one of 9, 10, 11 is heavy. *Weighing 3:* 9 vs 10. Down side is the fake;
    balanced means 11.
  - *Right down* $=>$ one of 9, 10, 11 is light. *Weighing 3:* 9 vs 10. The *up* side is the fake;
    balanced means 11.

*Case B: the left group went down.* Now one of ${1,2,3,4}$ is heavy, or one of ${5,6,7,8}$ is
light. Call the down-group $A = {1,2,3,4}$ and the up-group $B = {5,6,7,8}$. Chips 9 to 12 are
known genuine. That is 8 truths and 2 weighings left, so again it fits — but only if the second
weighing splits 8 into roughly 3, 2, 3.

- *Weighing 2:* ${A_1, A_2, B_1}$ vs ${A_3, B_2, 9}$.
  - *Balanced* $=>$ none of those is the fake, so the fake is $A_4$ heavy, $B_3$ light, or
    $B_4$ light. *Weighing 3:* $B_3$ vs $B_4$. If balanced, the fake is $A_4$ and it is heavy.
    Otherwise the pan that *rose* holds the light fake.
  - *Left down* $=>$ either $A_1$ or $A_2$ is heavy, or $B_2$ is light. *Weighing 3:* $A_1$ vs
    $A_2$. Down side is a heavy fake; balanced means $B_2$ is light.
  - *Right down* $=>$ either $A_3$ is heavy or $B_1$ is light. *Weighing 3:* $B_1$ vs a genuine
    chip. Balanced means $A_3$ is heavy; otherwise $B_1$ is light.

*Case C: the right group went down.* Swap the names of the two groups and reuse Case B exactly.

*E.* Every branch ends with exactly one chip and a direction. 24 truths, all covered.
]
#ans[3 weighings, using the split 4-vs-4, then a mixed 3-vs-3, then 1-vs-1]

#diagram(height: 5.6cm, caption: "Weighing 1 splits 24 truths into 8 + 8 + 8. Every later split must stay near-equal.")[
  #dnode(4.6cm, 0pt, 5.4cm, 0.9cm, "24 truths: 12 chips x (heavy or light)")
  #dnode(0pt, 1.9cm, 4.2cm, 0.9cm, "left down: A heavy or B light (8)")
  #dnode(5.2cm, 1.9cm, 4.2cm, 0.9cm, "balanced: fake in 9..12 (8)")
  #dnode(10.4cm, 1.9cm, 4.2cm, 0.9cm, "right down: mirror of case A (8)")
  #darrow(6.4cm, 0.9cm, 2.1cm, 1.9cm)
  #darrow(7.3cm, 0.9cm, 7.3cm, 1.9cm)
  #darrow(8.2cm, 0.9cm, 12.5cm, 1.9cm)
  #dnode(0pt, 3.8cm, 4.2cm, 0.9cm, "3 / 3 / 2 after weighing 2")
  #dnode(5.2cm, 3.8cm, 4.2cm, 0.9cm, "3 / 1 / 3 after weighing 2")
  #dnode(10.4cm, 3.8cm, 4.2cm, 0.9cm, "3 / 3 / 2 after weighing 2")
  #darrow(2.1cm, 2.8cm, 2.1cm, 3.8cm)
  #darrow(7.3cm, 2.8cm, 7.3cm, 3.8cm)
  #darrow(12.5cm, 2.8cm, 12.5cm, 3.8cm)
]

#code(lang: "js", caption: "weigh.js — the strategy above, tested against all 24 truths")[
```js
function weigh(left, right, fake, heavy) {
  let d = 0;                       // + means the LEFT pan goes down
  if (left.includes(fake))  d += heavy ? 1 : -1;
  if (right.includes(fake)) d -= heavy ? 1 : -1;
  return d > 0 ? 'L' : d < 0 ? 'R' : '=';
}

function strategy(fake, heavy) {
  const W = (l, r) => weigh(l, r, fake, heavy);
  const r1 = W([1, 2, 3, 4], [5, 6, 7, 8]);

  if (r1 === '=') {                        // fake is in {9,10,11,12}
    const r2 = W([9, 10, 11], [1, 2, 3]);
    if (r2 === '=') return [12, W([12], [1]) === 'L'];
    const hi = (r2 === 'L');
    const r3 = W([9], [10]);
    if (r3 === '=') return [11, hi];
    if (hi) return [r3 === 'L' ? 9 : 10, true];
    return [r3 === 'L' ? 10 : 9, false];
  }

  const [A, B] = r1 === 'L' ? [[1,2,3,4], [5,6,7,8]] : [[5,6,7,8], [1,2,3,4]];
  const g = 9;                             // known genuine
  const r2 = W([A[0], A[1], B[0]], [A[2], B[1], g]);

  if (r2 === '=') {
    const r3 = W([B[2]], [B[3]]);
    if (r3 === '=') return [A[3], true];
    return [r3 === 'L' ? B[3] : B[2], false];
  }
  if (r2 === 'L') {
    const r3 = W([A[0]], [A[1]]);
    if (r3 === '=') return [B[1], false];
    return [r3 === 'L' ? A[0] : A[1], true];
  }
  const r3 = W([B[0]], [g]);
  if (r3 === '=') return [A[2], true];
  return [B[0], false];
}

let ok = 0;
const bad = [];
for (let fake = 1; fake <= 12; fake++) {
  for (const heavy of [true, false]) {
    const [id, h] = strategy(fake, heavy);
    if (id === fake && h === heavy) ok++; else bad.push([fake, heavy, id, h]);
  }
}
console.log('counting bound: 3^3 =', 3 ** 3, 'outcomes for 24 answers');
console.log('cases solved correctly:', ok, 'of 24');
console.log('failures:', bad.length === 0 ? 'none' : bad);
```
]
#code(lang: "text", caption: "output")[
```text
counting bound: 3^3 = 27 outcomes for 24 answers
cases solved correctly: 24 of 24
failures: none
```
]

#ex(21, tier: 3, asked: "Amazon · pattern")[
A hundred ants are placed at random points on a 1-metre pole, each facing left or right at random.
They all walk at 1 metre per minute. When two ants meet head-on, both instantly reverse. An ant
that reaches an end of the pole falls off. What is the longest possible time before the pole is
empty?
]
#sol[
*The insight — the one idea in this puzzle.* The ants are identical. When two ants collide and both
reverse, the *picture* is exactly the same as if they had walked *through* each other and swapped
identities. Nothing observable changes.

*S.* So ignore collisions completely. Each ant now walks in a straight line at 1 m/min until it
falls off. The longest any single ant can walk is the full length of the pole, 1 metre, which takes
1 minute.

Therefore the pole is empty after at most *1 minute*, no matter how the 100 ants are arranged.

*E — sanity check with 2 ants.* Two ants at the very ends, walking towards each other. They meet in
the middle at 0.5 min, reverse, and each walks 0.5 m back to its own end, arriving at 1 min.
Matches.

*E — why "at most" and not "exactly"?* If every ant happens to be facing the nearer end, they all
leave sooner. The worst case is one ant starting at one end facing the far end.
]
#ans[1 minute]
#trick[
The "pass through instead of bouncing" swap works whenever the objects are *indistinguishable* and
the collision rule is symmetric. Look for it in any bouncing-particle or swapping-token puzzle.
]

#ex(22, tier: 3, asked: "D. E. Shaw · pattern")[
Five engineers, ranked 1 (most senior) to 5, must split a bonus of 100 indivisible units. The most
senior *surviving* engineer proposes a split. Everyone still in the room votes. If at least half
vote yes, the split stands. If not, the proposer is removed from the process and the next most
senior proposes. Every engineer wants, in order: to stay in the process, then to get the most
units, then to see a senior removed. What should engineer 1 propose?
]
#sol[
*The method.* Never start at 5 engineers. Start at the *end state* and walk backwards. This is
backward induction.

*Case: only 5 is left.* Engineer 5 proposes "100 to me" and votes yes. 1 of 1 is at least half.
So 5 gets 100. *This means engineer 4 must never let it reach this stage.*

*Case: 4 and 5 are left.* Engineer 4 proposes. With 2 voters, "at least half" is 1 vote — and 4's
own yes is enough. So 4 proposes "100 to me" and it passes.
Result: $(4: 100, space 5: 0)$. So *engineer 5 gets nothing* if it reaches the pair stage, and would
accept even 1 unit to avoid it.

*Case: 3, 4, 5 are left.* Engineer 3 needs 2 of 3 votes: his own plus one. Who is cheapest? Engineer
5 gets 0 in the next stage, so 1 unit buys his yes. Engineer 4 gets 100 next stage, so he is
unbuyable.
Result: $(3: 99, space 4: 0, space 5: 1)$.

*Case: 2, 3, 4, 5 are left.* Engineer 2 needs 2 of 4 votes: his own plus one. In the next stage,
4 gets 0. So 1 unit buys engineer 4.
Result: $(2: 99, space 3: 0, space 4: 1, space 5: 0)$.

*Case: all five.* Engineer 1 needs 3 of 5 votes: his own plus two. In the next stage (the 2-3-4-5
case) engineers 3 and 5 both get 0. So 1 unit each buys them both.

$ ("E1": 98, space "E2": 0, space "E3": 1, space "E4": 0, space "E5": 1) $

*E — verify engineer 3's choice.* If he votes no, engineer 1 is removed and 3 lands in the
2-3-4-5 case where he gets 0. Voting yes gets him 1. He votes yes. Same logic for 5. So the
proposal passes 3 votes to 2.
]
#ans[98 / 0 / 1 / 0 / 1]
#note[
The scoring point here is not the numbers. It is that you *said out loud* "I will solve the last
stage first." Interviewers stop listening to the arithmetic once they hear that sentence.
]

#ex(23, tier: 3, asked: "Microsoft · pattern")[
You toss a fair coin repeatedly. On average, how many tosses until you first see the pattern
*HH*? And until you first see *HT*? Are they the same?
]
#sol[
*Guess first, then check.* Most people say both are 4, since each 2-letter pattern has probability
$1/4$. That is wrong for HH, and explaining *why* is the whole answer.

*S — HT first.* Wait for the first head; that takes 2 tosses on average. After a head, keep tossing
until a tail; that also takes 2 on average. Nothing can "undo" the head you already have — a second
head simply replaces it as the newest head.
$ E["HT"] = 2 + 2 = 4 $

*S — HH.* Set up states by how much of the pattern you already hold.
- $E_0$ = expected tosses from "nothing yet"
- $E_1$ = expected tosses from "one head so far"

From state 0, one toss lands you in state 1 (heads) or back in state 0 (tails):
$ E_0 = 1 + 1/2 E_1 + 1/2 E_0 $
From state 1, one toss finishes (heads) or *resets you all the way to state 0* (tails):
$ E_1 = 1 + 1/2 (0) + 1/2 E_0 $

Solve. From the first equation, $ 1/2 E_0 = 1 + 1/2 E_1 $, so $ E_0 = 2 + E_1 $.
Substitute into the second: $ E_1 = 1 + 1/2 (2 + E_1) = 2 + 1/2 E_1 $, giving $ E_1 = 4 $ and
$ E_0 = 6 $.

*E — why the difference?* After a head, a tail *completes* HT but *destroys* HH. That asymmetry
costs HH two extra tosses on average. The patterns have the same probability per window but
different *overlap* structure.
]
#ans[HT takes 4 tosses on average; HH takes 6]

#ex(24, tier: 3, asked: "Google · pattern")[
A hundred new joiners stand in a line, each wearing a red or blue lanyard chosen at random. Each
person can see every lanyard in front of them but not their own and not those behind. Starting from
the back, each must say one word — "red" or "blue" — loud enough for all to hear, and it must be a
guess at their own lanyard. They may agree on a strategy beforehand but not communicate afterwards.
How many can be guaranteed correct?
]
#sol[
*P.* 100 people, each hears all earlier guesses and sees all lanyards ahead. One word each, back to
front.

*U — small case, 2 people.* Person 2 (at the back) sees person 1. If person 2 simply says what he
sees, person 1 repeats it and is certain to be right. Person 2 is a coin flip. So 1 guaranteed out
of 2.

*The generalisation.* The back person is the sacrifice. He must broadcast *one bit* that helps all
99 people ahead of him. One bit cannot name 99 colours — but it can name a *parity*.

*S — the strategy.*
1. Agree beforehand: "red" means *the number of red lanyards I can see is even*; "blue" means it is
   odd.
2. Person 100 (at the back) counts the reds in front of him and says the matching word. He is right
   only by luck.
3. Person 99 counts the reds *he* can see. If his count has the same parity as announced, his own
   lanyard is blue. If the parity differs by one, his own is red. He says it, and he is certain.
4. Person 98 heard both the original parity *and* person 99's true colour. He updates the running
   parity and repeats the same reasoning. And so on down the line.

*Worked micro-example with 4 people.* Lanyards front-to-back are R, B, R, ? . Person 4 sees R, B, R
— that is 2 reds, even — so he says "red". Person 3 sees R, B: 1 red, odd. Announced parity was
even, so person 3's own must be red. He says "red", correctly. Person 2 now knows the total parity
was even and that person 3 is red, so the parity among persons 1 and 2 must be odd. He sees R in
front, which is 1 red, already odd, so his own must be blue. Correct.

*E.* Everyone from 99 down to 1 is certain. Person 100 is a 50-50 shot.
]
#ans[99 guaranteed correct; the 100th is a coin flip]
#trick[
Whenever one person must help many with a single message, the answer is almost always *parity*.
It is the only thing that compresses a whole line into one bit.
]

// =====================================================================
#section("Part 2 — Guesstimates")
// =====================================================================

A guesstimate asks for a number nobody knows: cups of tea sold in a city, routers replaced per
year, the weight of all the luggage on a flight. There is no correct answer. There is a correct
*method*.

#formulas(title: "The rule that decides your score")[
You are judged on the *chain*, not the number. An answer within a factor of 3 of the
interviewer's own estimate is a pass. An answer with no visible chain is a fail even if it is
exactly right.
]

#subsection("The funnel — five slots, always the same")

#formulas(title: "The guesstimate funnel")[
*1. Define.* Say exactly what you are counting, in what unit, over what time. "Cups sold per day
by roadside stalls, in one city, on a normal weekday."

*2. Anchor.* Start from one number you actually know — usually a population.

*3. Filter.* Narrow with 3 to 5 multiplications, each one a stated assumption.

*4. Compute.* Round hard. Say the running total after every step.

*5. Sanity-check.* Cross-check with a second, different route, or a per-person feel test.
]

#diagram(height: 5.4cm, caption: "Each step is one stated assumption. Say the running total out loud after each one.")[
  #dnode(1.0cm, 0pt, 12cm, 0.8cm, "Anchor: city population 80 lakh")
  #dnode(2.0cm, 1.2cm, 10cm, 0.8cm, "x 0.65 adults aged 15-65  ->  52 lakh")
  #dnode(3.0cm, 2.4cm, 8cm, 0.8cm, "x 0.40 buy tea outside  ->  20.8 lakh")
  #dnode(4.0cm, 3.6cm, 6cm, 0.8cm, "x 1.8 cups per day  ->  37 lakh cups")
  #darrow(7.0cm, 0.8cm, 7.0cm, 1.2cm)
  #darrow(7.0cm, 2.0cm, 7.0cm, 2.4cm)
  #darrow(7.0cm, 3.2cm, 7.0cm, 3.6cm)
]

#subsection("Anchor numbers — the only things you memorise")

Round these. Precision is worthless here; a wrong order of magnitude is fatal.

#table(columns: (1fr, auto),
  [*Anchor*], [*Use*],
  [India population], [1.4 billion = 140 crore],
  [Indian metro city], [80 lakh to 2 crore],
  [Indian tier-2 city], [10 to 30 lakh],
  [Average Indian household size], [about 4 people],
  [Share of India aged 15-65], [about 65%],
  [Singapore population], [about 6 million],
  [Thailand population], [about 70 million; Bangkok about 10 million],
  [Indonesia population], [about 280 million; Jakarta metro about 30 million],
  [Days in a year], [365, but use 300 working days / 50 weeks],
  [Smartphone life], [about 3 years],
  [Laptop / router life], [about 5 years],
  [Car life], [about 12 years],
)

#trick[
Never divide by 365 in your head. Use 400 and say "I am rounding 365 up to 400 to keep the
arithmetic clean; that makes my answer about 10% low." Interviewers *like* this sentence.
]

#subsection("Weak answer vs strong answer, same guesstimate")

The question: *how many cups of tea are sold by roadside stalls in one Indian metro city in a day?*

#trap[
*WEAK.* "Hmm. India has a lot of tea drinkers. I'd say... maybe 10 lakh cups? Actually maybe more.
50 lakh. Let's say 50 lakh."
]

#sol[
*STRONG.*

"*Define:* cups sold by roadside stalls in one metro, on a normal weekday. Not packaged tea, not
home tea, not cafes.

*Anchor:* take a metro of 80 lakh people.

*Filter 1:* roughly 65% are aged 15 to 65 — that is the band that drinks tea outside. That gives
52 lakh.

*Filter 2:* of those, maybe 40% actually buy tea from a stall rather than making it at home or
drinking office tea. I am using 40% because tea is cheap and commuting is common, but in a
wealthier city I would drop it to 25%. That gives about 21 lakh buyers.

*Filter 3:* a regular buyer has about 2 cups a day — one on the way to work, one in the afternoon.
I will use 1.8 to allow for the light drinkers. That gives about 37 lakh cups.

*Answer:* roughly 35 to 40 lakh cups a day.

*Sanity-check, second route:* a busy stall sells maybe 300 cups a day. 37 lakh divided by 300 gives
about 12,000 stalls in a city of 80 lakh, or one stall per 650 people. Walking through any Indian
metro, that feels about right — maybe slightly low. So I am comfortable with 35 to 50 lakh.

If you want, I can tell you which assumption my answer is most sensitive to."
]

#formulas(title: "What exactly changed")[
1. The strong answer *defined the unit* before touching any number. The weak one never said whether
   it meant a city, a state, or the country.
2. Every multiplier came with a *reason*, and one came with a *range* ("40%, but 25% in a wealthier
   city").
3. It *restated the running total* after each step, so the interviewer could interrupt with a
   correction — which is exactly what they want to do.
4. It gave a *band*, not a single digit.
5. It *cross-checked from a completely different direction* (stalls, not people).
6. It ended by *offering the next step*. That converts a monologue into a conversation.
]

#note[
Do not memorise those sentences. Memorise the five slots — Define, Anchor, Filter, Compute,
Sanity-check — and fill them with the numbers *you* believe. If you recite the tea answer for a
question about helmets, the interviewer will hear it.
]

#tier-header(0)

#ex(25, tier: 0, asked: "warm-up · guesstimate")[
How many chairs are in your engineering college?
]
#sol[
*Define.* All seating in one campus: classrooms, labs, library, canteen, offices, auditorium.

*Anchor.* 4 years times 3 branches times 60 students = 720 students. Round to 800.

*Filter by place.*
#table(columns: (1fr, auto, auto),
  [*Place*], [*Reasoning*], [*Chairs*],
  [Classrooms], [One seat per student, plus 30% spare rooms], [1000],
  [Labs], [Half the students seated at a time, 2 shifts of rooms], [500],
  [Library], [About 10% of students at once], [80],
  [Canteen], [About 15% of students at once], [120],
  [Staff offices], [1 teacher per 20 students = 40 staff, 2 chairs each], [80],
  [Auditorium], [Seats the whole college at once], [800],
  [*Total*], [], [*about 2,600*],
)

*Sanity-check.* That is about 3.2 chairs per student. For a campus where every student has a
classroom seat *and* a lab seat *and* a share of the auditorium, 3 sounds right. If I had got 0.5
or 30, I would go back.
]
#ans[About 2,500 to 3,000 chairs]

#tier-header(1)

#ex(26, tier: 1, asked: "Infosys · pattern")[
How many Wi-Fi routers are sold each year in one Indian metro city of 80 lakh people?
]
#sol[
*Define.* Home broadband routers, retail plus those supplied by internet providers, in one city,
per year.

*Anchor.* 80 lakh people.

*Filter.*
1. Households: $80 "lakh" div 4 = 20$ lakh households.
2. Households with home broadband: I will say 35%. Mobile data is dominant in India, so this is
   well under 100%. That gives 7 lakh connected households.
3. Routers per connected household: 1.1, allowing for a few homes with a second unit. That gives
   7.7 lakh routers *in use*.
4. Replacement rate: a router lasts about 5 years, so $1/5$ of the installed base is replaced each
   year. That gives 1.54 lakh.
5. Growth: new connections are still being added, maybe 10% on top. Call it 1.7 lakh.

*Answer:* roughly 1.5 to 2 lakh routers a year.

*Sanity-check.* That is about 1 router per 45 people per year. A router lasting 5 years, in a city
where roughly 1 person in 11 lives in a connected household, works out to about 1 per 50 per year.
Close enough.
]
#ans[About 1.5 to 2 lakh routers per year]

#code(lang: "js", caption: "funnel.js — the same chain, printed step by step")[
```js
function funnel(name, steps) {
  let v = 1;
  console.log('\n' + name);
  for (const [label, factor] of steps) {
    v *= factor;
    console.log('  x ' + String(factor).padEnd(12) + label.padEnd(38) + '=> ' + fmt(v));
  }
  return v;
}

function fmt(n) {
  if (n >= 1e7) return (n / 1e7).toFixed(2) + ' crore';
  if (n >= 1e5) return (n / 1e5).toFixed(2) + ' lakh';
  if (n >= 1e3) return (n / 1e3).toFixed(2) + ' thousand';
  return n.toFixed(2);
}

const routers = funnel('Routers replaced per year, city of 80 lakh', [
  ['city population', 8_000_000],
  ['people per household', 1 / 4],
  ['households with home broadband', 0.35],
  ['routers per connected household', 1.1],
  ['fraction replaced each year (5-year life)', 1 / 5],
]);
console.log('  ANSWER ~', fmt(routers), 'routers/year');
```
]
#code(lang: "text", caption: "output")[
```text
Routers replaced per year, city of 80 lakh
  x 8000000     city population                       => 80.00 lakh
  x 0.25        people per household                  => 20.00 lakh
  x 0.35        households with home broadband        => 7.00 lakh
  x 1.1         routers per connected household       => 7.70 lakh
  x 0.2         fraction replaced each year (5-year life)=> 1.54 lakh
  ANSWER ~ 1.54 lakh routers/year
```
]

#ex(27, tier: 1, asked: "TCS NQT · pattern")[
How many windows are there on a 20-storey office tower?
]
#sol[
*Define.* Outward-facing glass panes on one rectangular tower.

*Anchor — geometry, not population.* A typical floor plate is about 40 m by 25 m. The perimeter is
$2 (40 + 25) = 130$ m.

*Filter.*
1. A window module is about 1.5 m wide, so one floor has $130 div 1.5 approx 87$ panes. Round to 85.
2. Twenty floors gives $85 times 20 = 1700$.
3. The ground floor is mostly entrance and service, so subtract roughly 40. Call it 1,660.

*Answer:* about 1,600 to 1,800 windows.

*Sanity-check.* 85 windows per floor for a floor of about 1,000 square metres is one window per
12 square metres of floor. In an open-plan office with continuous glazing, that is reasonable.
]
#ans[About 1,700 windows]
#trick[
Not every guesstimate anchors on population. The three anchors are *people*, *geometry* and
*money*. Pick the one closest to the thing being counted.
]

#tier-header(2)

#ex(28, tier: 2, asked: "Grab · pattern")[
Estimate the number of food-delivery orders placed in Singapore on a normal weekday.
]
#sol[
*Define.* Completed restaurant-to-home orders through delivery apps, in Singapore, on a weekday.

*Anchor.* Singapore population about 6 million (including residents and pass holders).

*Filter.*
1. Delivery-app users: Singapore has very high smartphone use and small homes, so I will say 55% of
   the population uses a delivery app at least sometimes. That gives 3.3 million users.
2. Order frequency: a typical user orders maybe twice a week, so on any given weekday about
   $2/7 approx 0.29$ of users order. Round to 0.3. That gives about 1.0 million orders.
3. But an order often feeds more than one person. Divide by about 1.5 people per order, giving
   roughly *650,000 to 700,000 orders a day*.

*Answer:* roughly 0.6 to 0.8 million orders on a weekday.

*Sanity-check from the supply side.* Suppose there are about 12,000 active riders, each completing
about 20 deliveries in a shift. That is 240,000 deliveries — which is a *lot* lower than my demand
number. That gap is useful: either there are more riders than I assumed, or my order frequency is
too high. I would revise down towards 300,000 to 500,000 and say so.

*What the revision shows.* Noticing and *naming* the gap between the two routes scores higher than
either number alone.
]
#ans[Roughly 0.3 to 0.7 million orders per weekday, with the supply check pulling the estimate down]

#note[
This example deliberately ends with a disagreement between two routes. That is realistic. Do not
hide it. Say: "My two routes disagree by a factor of two. Here is which one I trust more and why."
]

#ex(29, tier: 2, asked: "Agoda · pattern")[
A hotel booking site wants to size its market. Estimate the number of hotel room-nights booked in
Bangkok in a year.
]
#sol[
*Define.* Paid room-nights in hotels and serviced apartments in Bangkok, per year, both tourist
and domestic business travel.

*Two routes, both from the supply side and the demand side.*

*Route A — supply side.*
1. Bangkok has roughly 2,000 to 3,000 registered hotels. Use 2,500.
2. Average size about 120 rooms. That gives 300,000 rooms.
3. Rooms available per year: 300,000 $times$ 365 $approx$ 110 million room-nights of *capacity*.
4. Average occupancy about 65%. That gives about *71 million room-nights sold*.

*Route B — demand side.*
1. Bangkok receives roughly 20 million international visitors a year.
2. Average stay about 4 nights, and about 1.7 guests share a room. So room-nights from
   international visitors $= (20 "million" times 4) / 1.7 approx 47$ million.
3. Domestic and business travel adds maybe 40% more: about 66 million.

*Compare.* 71 million and 66 million. The two routes agree within 10%, which is unusually good.

*Answer:* about 65 to 75 million room-nights a year.

*Sanity-check.* 70 million room-nights divided by 365 is about 190,000 rooms occupied on an average
night, out of 300,000 rooms. That is 63% occupancy, which matches the assumption I started from.
Consistent.
]
#ans[Roughly 65 to 75 million room-nights per year]

#tier-header(3)

#ex(30, tier: 3, asked: "Amazon · pattern")[
A photo-sharing app has 5 million monthly active users. Estimate its yearly cloud storage bill, and
then say what you would change to cut it in half.
]
#sol[
*Define.* Cost of storing user photos for one year. Ignore bandwidth and compute; say so.

*Step 1 — how many photos arrive per year?*
- 5 million monthly actives; suppose 40% upload in a given month, so 2 million uploaders.
- Each uploader posts about 8 photos a month.
- $2 "million" times 8 times 12 = 192$ million photos a year. Round to *200 million*.

*Step 2 — how big is a photo?*
- An original phone photo is about 3 MB.
- But a real app stores several sizes: original, a display copy, a thumbnail. Say $3 + 0.4 + 0.05
  approx 3.5$ MB per photo.
- $200 "million" times 3.5 "MB" = 700$ million MB $= 700$ TB per year of *new* data.

*Step 3 — replication.*
- Object storage keeps about 3 copies for durability, but that is usually already inside the
  quoted price. I will assume the price already includes it and say so.

*Step 4 — cost.*
- Object storage runs roughly USD 0.02 per GB per month. 700 TB is 700,000 GB.
- 700,000 $times$ 0.02 $=$ USD 14,000 per month for one year's worth of photos.
- But storage *accumulates*. In year 1 the average stored volume is only half the final amount, so
  year 1 costs about 14,000 $times$ 12 $times$ 0.5 $approx$ *USD 84,000*.
- By year 3, with 3 years of photos on disk, the bill is roughly
  14,000 $times$ 12 $times$ 2.5 $approx$ *USD 420,000* a year.

*Answer:* about USD 80,000 in year one, rising to roughly USD 400,000 a year by year three.

*Step 5 — how to halve it.* Rank by leverage, because in a pure product every factor counts equally,
so attack the ones you can actually control:
1. *Tiered storage.* Photos older than 90 days are almost never viewed. Moving them to cold storage
   at about one-fifth the price cuts the bill by roughly 60% on its own. This is the single biggest
   lever.
2. *Stop storing the original.* Re-encode to a modern format at about 1 MB. That is a 3x cut on new
   data, but it is irreversible, so it needs a product decision.
3. *De-duplicate.* Identical re-uploads (memes, forwards) can be 5 to 15% of volume.
4. *Delete on account closure.* Often forgotten, and often several percent.

*E.* Levers 1 and 2 together are more than 2x, so halving the bill is clearly achievable.
]
#ans[About USD 80k in year 1, rising to roughly USD 400k by year 3; cold tiering is the main lever]

#note[
Tier 3 guesstimates almost always end with *"and what would you do about it?"*. Practise the
second half. A number with no recommendation is only half an answer.
]

#subsection("Which assumption should you argue about?")

In a pure chain of multiplications, every factor moves the answer by the same percentage. So do not
spend your time polishing the factor you know best. Spend it on the one you are *least sure of*.

#code(lang: "js", caption: "doubt.js — rank your assumptions by your own uncertainty")[
```js
const doubt = [
  { factor: 'city population',    spreadPct: 10 },
  { factor: 'share aged 15-65',   spreadPct: 8 },
  { factor: 'share who buy out',  spreadPct: 60 },
  { factor: 'cups per buyer/day', spreadPct: 100 },
];

console.log('WRONG - default sort compares text:');
console.log([100, 60, 10, 8].sort());

console.log('\nRIGHT - numbers need a comparator:');
console.log([100, 60, 10, 8].sort((a, b) => b - a));

console.log('\nattack this assumption first:');
for (const d of [...doubt].sort((a, b) => b.spreadPct - a.spreadPct)) {
  console.log('  +/-' + String(d.spreadPct).padStart(4) + '%  ' + d.factor);
}
```
]
#code(lang: "text", caption: "output")[
```text
WRONG - default sort compares text:
[ 10, 100, 60, 8 ]

RIGHT - numbers need a comparator:
[ 100, 60, 10, 8 ]

attack this assumption first:
  +/- 100%  cups per buyer/day
  +/-  60%  share who buy out
  +/-  10%  city population
  +/-   8%  share aged 15-65
```
]

#trap[
*JS trap you must know.* `[100, 60, 10, 8].sort()` returns `[10, 100, 60, 8]`. The default `sort`
converts every element to a string and compares text, so `"10"` comes before `"100"` which comes
before `"60"`. Numbers always need `(a, b) => a - b` for ascending or `(a, b) => b - a` for
descending. This exact bug has cost people offers in coding rounds.
]

#subsection("How close is close enough?")

#code(lang: "python", caption: "band.py — judging a guesstimate by order of magnitude")[
```python
import math

def magnitude_gap(mine, theirs):
    return abs(math.log10(mine / theirs))

truth = 3_700_000
for guess in [400_000, 1_200_000, 3_000_000, 9_000_000, 40_000_000]:
    gap = magnitude_gap(guess, truth)
    verdict = "same ballpark" if gap < 0.5 else ("one zero off" if gap < 1.5 else "way off")
    print(f"guess {guess:>12,}  log10 gap {gap:.2f}  -> {verdict}")

base = {"people": 8_000_000, "adult_share": 0.65, "buyer_share": 0.40, "cups": 1.8}

def answer(d):
    return d["people"] * d["adult_share"] * d["buyer_share"] * d["cups"]

print(f"\nbase answer = {answer(base):,.0f}")
for k in base:
    hi = dict(base); hi[k] = base[k] * 1.5
    print(f"  raising {k:<12} by 50% changes the answer by {(answer(hi)/answer(base)-1)*100:.0f}%")
```
]
#code(lang: "text", caption: "output")[
```text
guess      400,000  log10 gap 0.97  -> one zero off
guess    1,200,000  log10 gap 0.49  -> same ballpark
guess    3,000,000  log10 gap 0.09  -> same ballpark
guess    9,000,000  log10 gap 0.39  -> same ballpark
guess   40,000,000  log10 gap 1.03  -> one zero off

base answer = 3,744,000
  raising people       by 50% changes the answer by 50%
  raising adult_share  by 50% changes the answer by 50%
  raising buyer_share  by 50% changes the answer by 50%
  raising cups         by 50% changes the answer by 50%
```
]

#note[
Look at the bottom block. Every factor moves the answer by exactly 50%. That is the mathematical
proof of the rule above: in a product model there is no "unimportant" assumption, only assumptions
you are more or less sure about.
]

// =====================================================================
#section("When you are stuck — what to actually say")
// =====================================================================

You *will* get stuck. Everyone does. The score depends entirely on what comes out of your mouth in
the next 15 seconds.

#formulas(title: "The recovery structure — four moves, in order")[
*1. Name where you are.* "I have the setup but I cannot see the move yet."

*2. Say what you have ruled out, and why.* "Brute force is out because the search space is $2^100$."

*3. Shrink the problem out loud.* "Let me drop to 3 people and see what happens."

*4. Ask for a nudge, specifically.* "Am I right that the fake could be lighter, not just heavier?
That is the branch I am stuck on."
]

#trap[
*WEAK when stuck.* Long silence. Then: "Sorry... I've seen this one but I don't remember the
answer."

Two separate failures. The silence gave no data, and admitting you were trying to *recall* rather
than *derive* tells the interviewer the round is worthless.
]

#sol[
*STRONG when stuck.* "Let me say where I am. I know three weighings give 27 outcomes and I have 24
truths to separate, so it is tight but possible. My problem is the second weighing in the
unbalanced branch — a plain 2-vs-2 leaves 4 candidates, and one weighing cannot split 4 into
1. So I need to *mix* a suspect-heavy chip with a suspect-light one on the same pan. Let me try
that."
]

#formulas(title: "What exactly changed")[
1. It *named the exact sub-step* that failed, not a general "I'm stuck".
2. It *showed the counting argument still standing*, proving the earlier work was real.
3. It *diagnosed why* the obvious move fails ("4 cannot split into 1").
4. It *proposed the next experiment*. The interviewer can now nudge with one word.
5. It never said "I have seen this before". Derive, do not recall.
]

#subsection("Saying \"I do not know\" without losing the round")

Sometimes you genuinely have nothing. There is still a right way.

#trap[
*WEAK.* "I don't know." (silence)
]

#sol[
*STRONG.* "I do not have a method for this one. Let me tell you how I would attack it if I had
ten more minutes: I would first check whether some quantity stays fixed as the tokens move,
because the question asks whether a state is *reachable*, and those are usually invariant problems.
If you would rather move on, I am happy to, but I would like to come back to it at the end."
]

#formulas(title: "What exactly changed")[
The strong version admits ignorance *once*, in one short sentence, then spends the rest of the
answer showing method. It also offers the interviewer control. You cannot fake an answer, but you
can always show a plan of attack.
]

#trap[
*Never bluff.* If you half-remember a puzzle and state the answer with confidence but cannot
reconstruct it, the very next question will be "why?" and you will have nothing. A derived wrong
answer scores above a recalled right one you cannot defend.
]

// =====================================================================
#section("Linking puzzles to the behavioural round")
// =====================================================================

Interviewers often follow a puzzle with: *"tell me about a time you had to make a decision with
incomplete information."* The puzzle round and the behavioural round are testing the same muscle.

Use STAR. The four parts are labelled below so you can see the shape.

#trap[
*WEAK.* "In my final year project we didn't have all the data but I managed it and it worked out
fine. I'm good under pressure."
]

#sol[
*STRONG — with the four STAR parts labelled.*

*S — Situation.* "In my sixth-semester project my team of four was building a bus-tracking app for
our campus. Two weeks before the demo the college would not give us the real GPS feed from the
bus contractor, and we had no idea if we would ever get it."

*T — Task.* "I was responsible for the tracking module. I had to decide whether to keep waiting for
the real feed or to build without it, knowing a wrong choice would cost us the demo."

*A — Action.* "I listed what I actually knew: the feed, if it came, would be latitude, longitude
and a timestamp every 30 seconds, because that is what the contractor's public documentation said.
I could not confirm anything else. So I wrote the app against that one assumption and put a small
adapter layer in front of it. Then I built a replay service that pushed recorded GPS points from my
own phone into the same adapter, so the app could run fully without the real feed. I told my guide
in writing what assumption I had made, so that if it was wrong, it was a known risk and not a
surprise."

*R — Result.* "The real feed never arrived. We demoed on the replay service and scored the highest
in our section. Two months later the feed was released, and swapping it in took one afternoon
because only the adapter changed. My guide asked us to document the adapter pattern for the next
batch."
]

#formulas(title: "What exactly changed")[
1. The weak version has no *S*, no *T*, no measurable *R*. "Worked out fine" is not a result.
2. The strong version names *one decision* under uncertainty and shows the *reasoning*, which is
   exactly what the puzzle round scores.
3. It states the assumption *in writing to the guide* — the interview equivalent of saying your
   assumption out loud.
4. It gives a *result you can verify*: highest in section, one afternoon to swap, reused by the
   next batch.
]

#note[
*This is not your story.* Do not use it. It is here so you can see the shape. Take one real project
of your own, find the moment you had to decide without full information, and pour it into the same
four slots. If you cannot find such a moment in your own work, you have not looked hard enough —
every project has one.
]

// =====================================================================
#section("Practice")
// =====================================================================

#practice(tier: 0, time: "10 minutes for all six")[
1. A tank of algae doubles every hour and is full at 12:00. At what time was it one quarter full?
2. Three printers print three pages in three seconds. How many pages do nine printers print in
   nine seconds?
3. A rope ladder hangs from a boat; its rungs are 30 cm apart and 4 rungs are above the water. The
   tide rises 1 metre. How many rungs are above the water now?
4. Twelve people at a reunion each hug every other person exactly once. How many hugs?
5. A box has 6 red, 6 green and 6 blue pens. How many must you draw blind to be sure of 3 of the
   same colour?
6. A book's pages are numbered from 1. The printer used 1,392 digits in total. How many pages?
]

#key[
*1.* Step backwards one hour at a time, halving each step. Full at 12:00, so half full at 11:00,
so one quarter full at *10:00*.
*2.* One printer does one page in three seconds, so in nine seconds each does 3 pages. Nine printers
give *27 pages*.
*3.* *4 rungs.* The boat floats, so the ladder rises with the tide. This is a "does the situation
actually change?" puzzle.
*4.* $(12 times 11)/2 = $ *66 hugs*.
*5.* Worst case is 2 of each colour, that is 6 pens, so the 7th must make a triple. *7 pens.*
*6.* Pages 1-9 use 9 digits; 10-99 use $90 times 2 = 180$; running total 189. Remaining
$1392 - 189 = 1203$ digits at 3 each gives 401 pages, starting at 100. So the last page is
$99 + 401 = $ *500 pages*.
]

#practice(tier: 1, time: "20 minutes")[
1. You have a 7-minute timer and an 11-minute timer, both sand glasses. Measure exactly 15 minutes.
2. Eight batteries look identical; one is flat and slightly lighter. Find it with a balance in two
   weighings.
3. A snail climbs a 10-metre well, rising 3 m each day and slipping 2 m each night. On which day
   does it get out?
4. There are 25 horses and a track that races 5 at a time, with no timer — only finish order. How
   many races to find the fastest 3?
5. A ferry takes exactly 1 minute to cross a river. Two ferries start from opposite banks at the
   same time. Where do they meet, and does the answer change if one is twice as fast?
6. Two candles burn for 6 hours and 4 hours respectively at constant rates. After how long is one
   exactly twice the height of the other, if they start at the same height and are lit together?
]

#key[
*1.* Start both. At 7 min the 7-glass ends; flip it. At 11 min the 11-glass ends; the 7-glass has
4 min of sand in its bottom bulb. Flip the 7-glass so those 4 min run back. At 15 min it ends.
*15 minutes.* (Do not restart — the running count from 11 plus 4 is the trick.)
*2.* Weigh 3 vs 3. If one side rises, the flat one is in that group of 3; if balanced, it is in the
remaining 2. Second weighing: 1 vs 1 from the suspect group. In the group-of-3 case, the pan that
rises holds it, or if balanced it is the third. In the group-of-2 case, the lighter pan holds it.
*3.* Net gain is 1 m per full day, but on the day it reaches the top it does not slip back. After
day 7 it is at 7 m; on day 8 it climbs 3 m to 10 m and is out. *Day 8.*
*4.* *7 races.* Race the 5 groups (5 races). Race the 5 winners (race 6) — this ranks the groups.
Only 6 horses can still be in the top 3: the 2nd and 3rd of the winning group, the 1st and 2nd of
the second group, and the 1st of the third group — that is 5 horses. Race those 5 (race 7); the
overall winner is already known, and this race gives places 2 and 3.
*5.* They meet when their combined distance equals one crossing, so at $t = 1/2$ minute if equal
speed, at the midpoint. If one is twice as fast, they still meet at $t$ where combined distance is
one width, and the fast one has covered $2/3$ of the river. *Meeting time is always the width
divided by the sum of speeds; only the position moves.*
*6.* Let the starting height be 1. Heights are $1 - t/6$ and $1 - t/4$. Set
$1 - t/6 = 2(1 - t/4)$, giving $1 - t/6 = 2 - t/2$, so $t/2 - t/6 = 1$, so $t/3 = 1$,
so $t = 3$ hours.
]

#practice(tier: 2, time: "30 minutes")[
1. A logistics hub has 5 loading bays. Trucks arrive at random and each uses one bay for 1 hour. On
   average 3 trucks arrive per hour. Estimate how often a truck has to wait, and state your
   assumptions.
2. Three boxes are labelled "cables", "chargers" and "mixed". Every label is wrong. You may pull one
   item out of one box, without looking inside. Can you relabel all three correctly?
3. Estimate the number of lifts (elevators) installed each year in Singapore.
4. You are given a coin that may or may not be fair. You toss it 10 times and see 8 heads. How
   suspicious should you be? Give a number, not a feeling.
5. A subscription app has 200,000 users and loses 4% of them each month. If it adds 12,000 new
   users a month, what does the user count settle at?
6. Estimate how many cups of coffee a 500-person office building consumes in a working year.
]

#key[
*1.* State the assumption: arrivals are independent and spread out. With 3 arriving per hour and
each holding a bay for 1 hour, the average number in service is 3, against 5 bays. A wait happens
only when 5 or more overlap. Using the Poisson shape with mean 3, $P(5 "or more") approx 18%$.
So roughly *1 truck in 5 waits*. Saying "I am assuming independent arrivals" is worth more than
the exact percentage.
*2.* *Yes.* Pull one item from the box labelled "mixed". Since all labels are wrong, that box is
*not* mixed, so whatever you pull names it correctly. Say you pull a cable — that box is "cables".
Now the box labelled "cables" cannot be cables (its label is wrong) and cannot be the one you just
named, so it is "mixed". The last box is "chargers".
*3.* Anchor: 6 million people, roughly 1.4 million households, mostly in high-rise blocks. Say one
lift per 60 households in service, giving about 23,000 lifts, plus offices and malls, call it
35,000 total. A lift lasts about 25 years, so replacement is 35,000 $div$ 25 $approx$ 1,400 per
year, plus new construction, maybe 2,000 to 2,500. *Roughly 2,000 lifts a year.*
*4.* A fair coin gives 8 or more heads in 10 tosses with probability
$(C(10,8) + C(10,9) + C(10,10)) div 2^10 = (45 + 10 + 1)/1024 approx 5.5%$. So it is unusual but
not damning. *Mildly suspicious, about 1 in 18.* You would want more tosses.
*5.* Losses equal gains at the steady state: $0.04 N =$ 12,000, so $N =$ 300,000.
*6.* 500 people, about 80% drink coffee = 400 drinkers, about 2 cups each per working day,
220 working days: $400 times 2 times 220 = $ *about 176,000 cups a year*.
]

#practice(tier: 3, time: "45 minutes")[
1. Twenty-five engineers stand in a circle. Starting at engineer 1, every second engineer leaves
   the circle, going round and round, until one remains. Which position survives? Find the rule,
   not just the answer.
2. A jar holds 50 white and 50 black beads plus one spare white bead in your hand. You repeatedly
   draw two beads. If they are the same colour, you discard both and put a white bead in. If they
   differ, you put the black one back and discard the white. What colour is the last bead? Prove it.
3. Two numbers between 2 and 50 are chosen. One person is told their sum, another their product.
   Sketch how you would reason about who can deduce what, and say what type of puzzle this is.
4. A data centre's monthly bill is USD 200,000. Break it into a chain of assumptions and identify
   the two levers that would cut it by 30%.
5. You must find the single defective chip among 100, but each test costs Rs 500 and can test any
   subset at once. What is the cheapest guaranteed plan, and what changes if a test can give a
   false negative 10% of the time?
6. Estimate the total weight of checked luggage on a full wide-body flight from Delhi to Singapore,
   and say which assumption you are least sure about.
]

#key[
*1.* Write $25 = 16 + 9$, so $25 = 2^4 + 9$. The survivor in this "every second person leaves,
starting the elimination at position 2" version is $2 times 9 + 1 = $ *position 19*. The general
rule: write $n = 2^m + l$ with $0 <= l < 2^m$; the survivor is $2l + 1$. Verify on $n = 5$:
$5 = 4 + 1$, survivor $= 3$. Walk it by hand to confirm.
*2.* Track the *parity of black beads*. Two blacks discarded: black count drops by 2, parity
unchanged. Two whites: black count unchanged. One of each: the black goes back, the white is
discarded, so black count unchanged. Black parity *never* changes. It starts at 50, which is even,
so it ends even — and the only even count with one bead left is 0. *The last bead is white.*
*3.* This is a *common knowledge* puzzle. Each statement of the form "I cannot deduce it" removes a
whole class of candidate pairs from both players' worlds. You solve it by listing the pairs
consistent with each announcement in turn and intersecting. Say the words "each 'I don't know' is
itself information" — that is the scored insight.
*4.* Chain: bill = servers x cost per server + storage + network + staff. Typical split is roughly
60% compute, 20% storage, 15% network, 5% other. The two levers: *(a)* right-size over-provisioned
instances and use committed-use pricing — 30 to 40% off compute alone, which is about 20% of the
total; *(b)* tier cold storage and cut egress by caching at the edge. Together these comfortably
reach 30%.
*5.* With perfect tests, group testing needs $ceil(log_2 100) = 7$ tests, costing Rs 3,500, using
binary labelling. With a 10% false-negative rate you must *repeat* each test until the chance of a
missed positive is acceptable: 3 repeats drop it to $0.1^3 = 0.1%$. So about 21 tests, Rs 10,500.
The scored point is that *reliability multiplies the cost, it does not add to it*.
*6.* About 300 passengers, roughly 1.3 checked bags each, about 18 kg per bag:
$300 times 1.3 times 18 approx $ *7,000 kg*. Least certain assumption: *bags per passenger*, because
it swings from 0.8 on a business-heavy route to 2.0 on a migrant-worker route. Say that.
]

#revision[
*The five spoken steps — PAUSE.* Play it back. Ask, then assume. Use a small case. Solve and state.
Examine.

*The six families.* Information/weighing · Scheduling/crossing · Invariant/parity ·
Counting/pigeonhole · Probability/expectation · Game/backward induction.

*Openings that score.*
- "Let me count the outcomes against the number of possible answers."
- "Let me try this with 3 instead of 100."
- "I am assuming X — tell me if that is wrong."
- "What stays the same as the state changes?"
- "Let me solve the last move first."

*Numbers worth memorising.* $3^3 = 27$ · balance gives $log_3$ · 23 people = 50% birthday match ·
$n(n-1)/2$ handshakes · $(k(k+1))/2 >= n$ for two-egg drops · coupon collector $= n(1 + 1/2 + dots + 1/n)$.

*Guesstimate funnel.* Define $->$ Anchor $->$ Filter $->$ Compute $->$ Sanity-check from a second
direction.

*Anchors.* India 140 crore · metro 80 lakh to 2 crore · household 4 people · 65% aged 15-65 ·
Singapore 6 m · Bangkok 10 m · 300 working days · phone 3 yr, router 5 yr, car 12 yr.

*The three anchor types.* People · Geometry · Money. Pick the closest one.

*In a product model every factor moves the answer equally.* So argue about the factor you trust
least, not the one you know best.

*When stuck, in this order.* Name where you are $->$ say what you ruled out and why $->$ shrink
the problem $->$ ask one specific question.

*When you truly do not know.* Say it once, in one sentence. Then spend the rest of the answer on
the method you *would* use. Never bluff. A derived wrong answer beats a recalled right one.

*The three fatal habits.* Silence · a bare number with no chain · defending a wrong answer after a
hint.

*And for the behavioural follow-up.* S, T, A, R — all four, every time, with a result you can
measure. Use *your own* project, never a sample one.
]

]
