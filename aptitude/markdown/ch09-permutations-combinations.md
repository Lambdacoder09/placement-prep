# Chapter 9 — Permutations & Combinations

*Count without listing. Order first, then choose.*

## What you need to know

**WHAT YOU NEED TO KNOW**

**Notation.** $""^n P_r$ = number of **arrangements** of $r$ things out of $n$ (order matters).
$""^n C_r = binom(n,r)$ = number of **selections** of $r$ things out of $n$ (order does not matter).

**The one question to ask first:** does changing the order make a new answer?
Yes $arrow.r$ permutation. No $arrow.r$ combination.

**Counting principle.**
- AND $arrow.r$ multiply. (Do this, then that.)
- OR $arrow.r$ add. (Do this, or instead that. Cases must not overlap.)

**Factorials.** $n! = n (n-1) (n-2) \dots.c 2 dot 1$, and $0! = 1$.
$1! = 1$, $2! = 2$, $3! = 6$, $4! = 24$, $5! = 120$, $6! = 720$, $7! = 5040$, $8! = 40320$, $9! = 362880$, $10! = 3628800$.

**Core formulas.**
$ ""^n P_r = n!/(n-r)! = underbrace(n (n-1) \dots.c, r "factors") \quad \quad ""^n C_r = n!/(r! (n-r)!) = (""^n P_r)/r! $

- $""^n C_r = ""^n C_(n-r)$   $""^n C_0 = ""^n C_n = 1$   $""^n C_1 = n$
- $""^n C_2 = (n(n-1))/2$   $""^n C_3 = (n(n-1)(n-2))/6$
- $""^n C_r + ""^n C_(r-1) = ""^(n+1) C_r$ (Pascal)
- $""^n C_0 + ""^n C_1 + \dots.c + ""^n C_n = 2^n$   so: subsets of an $n$-set $= 2^n$; at least one item $= 2^n - 1$

**Repetition allowed.** $r$ slots, $n$ choices each $arrow.r n^r$ (codes, PINs, passwords).

**Alike objects in a row.** $n$ objects with $p$ alike of one kind, $q$ alike of another:
$ "arrangements" = n!/(p! q! r! \dots.c) $

**Circular.**
- $n$ people round a table: $(n-1)!$
- Necklace / garland (flip allowed, clockwise $=$ anticlockwise): $(n-1)!/2$

**Two standard moves.**
- **Together** $arrow.r$ glue the group into one unit, then multiply by the internal arrangements.
- **No two together** $arrow.r$ arrange the others first, then drop the special ones into the **gaps**.
- $r$ chosen from $n$ in a row with no two adjacent: $""^(n-r+1) C_r$.

**Identical objects into distinct groups** ($x_1 + x_2 + \dots.c + x_r = n$):
- each group $gt.eq 1$: $""^(n-1) C_(r-1)$
- each group $gt.eq 0$: $""^(n+r-1) C_(r-1)$

**Distinct objects into distinct boxes.**
- any number per box: $r^n$
- into exactly 3 boxes, none empty: $3^n - 3 dot 2^n + 3$

**Dividing into groups.** $m n$ distinct objects into $m$ groups of $n$ each:
labelled groups $arrow.r (m n)!/(n!)^m$; unlabelled groups $arrow.r (m n)!/((n!)^m dot m!)$.

**Derangements** (nothing in its own place):
$ D_n = n! (1 - 1/1! + 1/2! - 1/3! + \dots.c plus.minus 1/n!) $
$D_1=0$, $D_2=1$, $D_3=2$, $D_4=9$, $D_5=44$, $D_6=265$, $D_7=1854$.
Exactly $k$ items in the right place out of $n$: $""^n C_k dot D_(n-k)$.

**Geometry counts.** From $n$ points, no 3 collinear: lines $= ""^n C_2$, triangles $= ""^n C_3$.
Diagonals of an $n$-gon $= (n(n-3))/2$.
Rectangles in a grid of $a \times b$ cells $= ""^(a+1) C_2 \times ""^(b+1) C_2$.

**Grid paths.** $m$ steps east and $n$ steps north: $(m+n)!/(m! n!)$.

**Sum of all numbers** formed by $n$ distinct non-zero digits, all $n$ used:
$ "Sum" = (n-1)! \times ("sum of digits") \times underbrace(1 1 1 \dots.c 1, n "ones") $

## Warm-up

### Warm-up

**Example 1**

Find $6!$, $0!$ and $5!/3!$.

**Solution**

$6! = 6 \times 5 \times 4 \times 3 \times 2 \times 1 = 720$.

$0! = 1$ (by definition).

$5!/3! = (5 \times 4 \times 3!)/(3!) = 5 \times 4 = 20$.

**➜ Answer: 720, 1, 20**

**Example 2**

Find $""^8 P_3$.

**Solution**

$""^8 P_3$ means 3 factors starting from 8.

$= 8 \times 7 \times 6 = 56 \times 6 = 336$.

**➜ Answer: 336**

**Example 3**

Find $""^10 C_3$.

**Solution**

$""^10 C_3 = (10 \times 9 \times 8)/(3 \times 2 \times 1) = 720/6 = 120$.

**➜ Answer: 120**

**Example 4**

Find $""^12 C_10$.

**Solution**

Use $""^n C_r = ""^n C_(n-r)$. So $""^12 C_10 = ""^12 C_2$.

$""^12 C_2 = (12 \times 11)/2 = 132/2 = 66$.

**➜ Answer: 66**

---
💡 **SHORTCUT**

Never compute $""^n C_r$ with $r$ bigger than $n/2$. Flip it first: $""^20 C_17 = ""^20 C_3 = (20 \times 19 \times 18)/6 = 1140$. Three multiplications instead of seventeen.

**Example 5**

From 5 different letters, how many 3-letter codes are possible
(a) with no letter repeated, (b) with repetition allowed?

**Solution**

(a) Slot 1: 5 ways. Slot 2: 4 ways left. Slot 3: 3 ways left.
$5 \times 4 \times 3 = 60$.

(b) Every slot has all 5 letters available. $5 \times 5 \times 5 = 125$.

**➜ Answer: (a) 60   (b) 125**

**Example 6**

How many arrangements of the letters of **LEVEL**?

**Solution**

Letters: L, E, V, E, L $arrow.r$ 5 letters. L appears 2 times, E appears 2 times.

$"Arrangements" = 5!/(2! dot 2!) = 120/(2 \times 2) = 120/4 = 30$.

**➜ Answer: 30**

**Example 7**

In how many ways can 7 friends sit around a circular table?

**Solution**

Circular: fix one person, arrange the rest.

$(7-1)! = 6! = 720$.

**➜ Answer: 720**

**Example 8**

A set has 5 different elements. How many subsets does it have? How many are non-empty?

**Solution**

Each element is either in or out: 2 choices each.

Total subsets $= 2^5 = 32$.

Remove the empty subset: $32 - 1 = 31$.

**➜ Answer: 32 subsets; 31 non-empty**

## Tier 1 — Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

How many 4-digit numbers can be formed using the digits 1, 2, 3, 4, 5, 6, 7 if no digit repeats?

**Solution**

Order matters (1234 and 4321 are different numbers). No zero to worry about.

$""^7 P_4 = 7 \times 6 \times 5 \times 4$.

$7 \times 6 = 42$. $42 \times 5 = 210$. $210 \times 4 = 840$.

**➜ Answer: 840**

**Example 10** `Infosys pattern`

How many 4-digit numbers can be formed using 0, 1, 2, 3, 4, 5 with no digit repeated?

**Solution**

The thousands place cannot be 0.

Thousands place: 5 choices (1, 2, 3, 4, 5).

Now 5 digits are left (including 0) for the other 3 places:
$5 \times 4 \times 3 = 60$.

Total $= 5 \times 60 = 300$.

**➜ Answer: 300**

---
⚠️ **TRAP**

The most common loss of marks in this chapter: forgetting that a number cannot start with 0. Here the careless answer is $""^6 P_4 = 360$. The 60 extra "numbers" all start with 0, so they are only 3-digit numbers.

**Example 11** `Accenture pattern`

A committee of 3 men and 2 women must be formed from 5 men and 4 women. In how many ways?

**Solution**

Choosing a committee: order does not matter $arrow.r$ combinations.

Men: $""^5 C_3 = ""^5 C_2 = (5 \times 4)/2 = 10$.

Women: $""^4 C_2 = (4 \times 3)/2 = 6$.

Men AND women $arrow.r$ multiply: $10 \times 6 = 60$.

**➜ Answer: 60**

**Example 12** `Wipro pattern`

From 6 men and 5 women, a committee of 4 is formed with **at least 3 women**. In how many ways?

**Solution**

"At least 3 women" out of 4 members means 3 women or 4 women. These cases do not overlap, so add.

**Case A — 3 women, 1 man:**
$""^5 C_3 \times ""^6 C_1 = 10 \times 6 = 60$.
($""^5 C_3 = ""^5 C_2 = (5 \times 4)/2 = 10$.)

**Case B — 4 women, 0 men:**
$""^5 C_4 \times ""^6 C_0 = 5 \times 1 = 5$.

Total $= 60 + 5 = 65$.

**➜ Answer: 65**

---
⚠️ **TRAP**

"At least 3" is **not** $""^5 C_3 \times ""^8 C_1$. That kind of shortcut counts the same committee more than once. Always split "at least" into clean, separate cases and add.

**Example 13** `TCS NQT pattern`

How many arrangements are there of the letters of the word **PLACEMENT**?

**Solution**

Write the letters out: P, L, A, C, E, M, E, N, T $arrow.r$ 9 letters.

Repeats: E appears 2 times. All others once.

$"Arrangements" = 9!/(2!) = 362880/2 = 181440$.

**➜ Answer: 181440**

**Example 14** `Capgemini pattern`

For the word **BANANA**: (a) how many arrangements? (b) how many start with B?

**Solution**

(a) Letters: B, A, N, A, N, A $arrow.r$ 6 letters. A appears 3 times, N appears 2 times.

$6!/(3! dot 2!) = 720/(6 \times 2) = 720/12 = 60$.

(b) Fix B in the first place. The remaining 5 letters are A, N, A, N, A: A three times, N twice.

$5!/(3! dot 2!) = 120/12 = 10$.

**➜ Answer: (a) 60   (b) 10**

**Example 15** `Cognizant pattern`

In how many arrangements of **COMPUTER** do all the vowels stay together?

**Solution**

C, O, M, P, U, T, E, R $arrow.r$ 8 distinct letters.

Vowels: O, U, E (3 of them). Consonants: C, M, P, T, R (5 of them).

Glue the 3 vowels into one block. Now count units: 5 consonants $+$ 1 block $= 6$ units.

Arrange the 6 units: $6! = 720$.

Arrange the vowels inside the block: $3! = 6$.

Total $= 720 \times 6 = 4320$.

**➜ Answer: 4320**

---
💡 **SHORTCUT**

**Together = glue.** Tie the group with a rubber band, count the units, then untie it and multiply by the arrangements inside. Two multiplications, always.

**Example 16** `TCS NQT pattern`

In how many arrangements of **LEADING** do no two vowels sit next to each other?

**Solution**

L, E, A, D, I, N, G $arrow.r$ 7 distinct letters.

Consonants: L, D, N, G (4). Vowels: E, A, I (3).

**Step 1 — seat the consonants first.** $4! = 24$ ways.

**Step 2 — find the gaps.** With 4 consonants in a row there are 5 gaps:
  $\*   C   \*   C   \*   C   \*   C   \_$

**Step 3 — put the 3 vowels into 3 different gaps.** Order matters, so
$""^5 P_3 = 5 \times 4 \times 3 = 60$.

Total $= 24 \times 60 = 1440$.

**➜ Answer: 1440**

---
💡 **SHORTCUT**

**No two together = gap method.** Seat the "ordinary" items first, count the gaps (always one more than the number of ordinary items), then place the "special" items into separate gaps. This is faster and safer than "total minus together" whenever there are 3 or more special items.

**Example 17** `Accenture pattern`

At a meeting 12 people are present.
(a) Each shakes hands with every other exactly once. How many handshakes?
(b) Instead, each person gives a business card to every other person. How many cards are given?

**Solution**

(a) A handshake between P and Q is the same as between Q and P $arrow.r$ order does not matter.

$""^12 C_2 = (12 \times 11)/2 = 132/2 = 66$.

(b) A card from P to Q is **not** the same as a card from Q to P $arrow.r$ order matters.

$""^12 P_2 = 12 \times 11 = 132$.

**➜ Answer: (a) 66   (b) 132**

---
⚠️ **TRAP**

Handshakes, matches between teams, lines through points $arrow.r$ combinations.
Gifts, letters, one-way flights between cities, ordered pairs $arrow.r$ permutations.
Read the verb carefully. The two answers always differ by a factor of $2$ in the pair case.

**Example 18** `Infosys pattern`

How many diagonals does a 12-sided polygon have?

**Solution**

Join any 2 of the 12 vertices: $""^12 C_2 = (12 \times 11)/2 = 66$ line segments.

Of these, 12 are the sides of the polygon, not diagonals.

Diagonals $= 66 - 12 = 54$.

(Formula check: $(n(n-3))/2 = (12 \times 9)/2 = 108/2 = 54$. Matches.)

**➜ Answer: 54**

**Example 19** `Wipro pattern`

5 boys and 3 girls stand in a row. In how many ways can they stand if all 3 girls stay together?

**Solution**

Glue the 3 girls into one block.

Units $=$ 5 boys $+$ 1 block $= 6$ units.

Arrange units: $6! = 720$.

Arrange the girls inside the block: $3! = 6$.

Total $= 720 \times 6 = 4320$.

**➜ Answer: 4320**

**Example 20** `TCS NQT pattern`

There are 10 points in a plane. Exactly 4 of them lie on one straight line; no other 3 points are collinear.
(a) How many triangles can be formed? (b) How many straight lines?

**Solution**

(a) Any 3 points give a triangle, **unless** all 3 are on the same line.

All choices: $""^10 C_3 = (10 \times 9 \times 8)/6 = 720/6 = 120$.

Bad choices (all 3 from the 4 collinear points): $""^4 C_3 = 4$.

Triangles $= 120 - 4 = 116$.

(b) Any 2 points give a line.

All choices: $""^10 C_2 = (10 \times 9)/2 = 45$.

The 4 collinear points give $""^4 C_2 = 6$ pairs, but all 6 pairs give the **same** single line.

Lines $= 45 - 6 + 1 = 40$.

**➜ Answer: (a) 116   (b) 40**

#### Practice — Tier 1 — Service *(target: 60 s/Q)*

+ Find $""^7 P_3$.
+ Find $""^15 C_13$.
+ How many 3-digit numbers with no repeated digit can be made from the digits 1 to 9?
+ How many 4-character codes can be made from the 26 English capital letters if repetition is allowed?
+ How many arrangements are there of the letters of **SUCCESS**?
+ How many arrangements are there of the letters of **MISSISSIPPI**?
+ In how many ways can 4 books be chosen from 9 different books?
+ A committee of 5 is chosen from 7 men and 4 women, with exactly 2 women. In how many ways?
+ In how many ways can 6 people be seated around a circular table?
+ At a party every person shook hands with every other person exactly once. There were 45 handshakes. How many people were there?
+ How many diagonals does a regular octagon have?
+ How many arrangements of the letters of **ORANGE** begin with a vowel?
+ 4 different Maths books and 3 different Physics books are placed on a shelf so that all the Physics books are together. In how many ways?
+ How many non-empty subsets does a set of 6 elements have?
+ With 5 different flags, how many signals can be made by hoisting one or more flags one above the other?

<details>
<summary><b>Answer key</b></summary>

**1.** 210 — $7 \times 6 \times 5$.   

**2.** 105 — flip: $""^15 C_13 = ""^15 C_2 = (15 \times 14)/2$.   

**3.** 504 — $9 \times 8 \times 7$; no zero is available so no first-digit problem.   

**4.** 456976 — repetition allowed: $26^4$.   

**5.** 420 — 7 letters, S three times, C twice: $5040/(6 \times 2)$.   

**6.** 34650 — 11 letters: I four times, S four times, P twice: $39916800/(24 \times 24 \times 2) = 39916800/1152$.   

**7.** 126 — $""^9 C_4 = (9 \times 8 \times 7 \times 6)/24 = 3024/24$.   

**8.** 210 — $""^4 C_2 \times ""^7 C_3 = 6 \times 35$. "Exactly 2 women" fixes the men count at 3.   

**9.** 120 — $(6-1)! = 5! = 120$. Answer 720 means you forgot it is circular.   

**10.** 10 — $(n(n-1))/2 = 45 arrow.r n(n-1) = 90 arrow.r n = 10$.   

**11.** 20 — $(8 \times 5)/2$.   

**12.** 360 — vowels O, A, E: 3 choices for the first letter, then $5! = 120$ for the rest.   

**13.** 720 — glue: 5 units $arrow.r 5! = 120$, times $3! = 6$ inside.   

**14.** 63 — $2^6 - 1 = 64 - 1$.   

**15.** 325 — $""^5 P_1 + ""^5 P_2 + ""^5 P_3 + ""^5 P_4 + ""^5 P_5 = 5+20+60+120+120$. Order up the pole matters.

## Tier 2 — Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 21** `Grab · pattern`

A rider app lists 7 open pickup points. A rider will visit exactly 4 of them, one after the other.
(a) In how many different routes can he do this?
(b) In how many of these is a particular point (the central kitchen) visited first?

**Solution**

(a) The order of visits matters, so this is an arrangement.

$""^7 P_4 = 7 \times 6 \times 5 \times 4 = 840$.

(b) Fix the central kitchen in position 1. Now 3 more stops must be chosen and ordered from the remaining 6 points.

$""^6 P_3 = 6 \times 5 \times 4 = 120$.

**➜ Answer: (a) 840   (b) 120**

**Example 22** `Shopee · pattern`

A seller has 10 listed products. She builds a "bundle" of any 4 of them. But the phone case and the screen guard must never be in the same bundle (they clash in the promo rules). How many bundles are possible?

**Solution**

**Step 1 — all bundles, ignoring the rule.**
$""^10 C_4 = (10 \times 9 \times 8 \times 7)/(4 \times 3 \times 2 \times 1) = 5040/24 = 210$.

**Step 2 — bad bundles that contain both clashing items.**
Both are already in. Choose 2 more from the remaining 8 products.
$""^8 C_2 = (8 \times 7)/2 = 28$.

**Step 3 — subtract.**
$210 - 28 = 182$.

**➜ Answer: 182**

---
💡 **SHORTCUT**

When a rule says "these two must NOT both appear", it is almost always faster to count **all** cases and subtract the cases where both **do** appear. Forcing both in is a single, easy count.

**Example 23** `DBS · pattern`

8 managers sit at a round table. Two of them, Arun and Bala, must not sit next to each other. In how many ways can they be seated?

**Solution**

**Step 1 — all circular seatings.**
$(8-1)! = 7! = 5040$.

**Step 2 — seatings where Arun and Bala ARE together.**
Glue them into one unit. Units $= 6$ other managers $+ 1$ block $= 7$ units around a circle.

Circular arrangements of 7 units $= (7-1)! = 6! = 720$.

Inside the block Arun–Bala or Bala–Arun: $2! = 2$.

Together $= 720 \times 2 = 1440$.

**Step 3 — subtract.**
$5040 - 1440 = 3600$.

**➜ Answer: 3600**

---
⚠️ **TRAP**

In a circular "together" problem you glue first and **then** apply $(k-1)!$ to the new number of units. Writing $(8-1)!$ and then gluing gives $7! \times 2 = 10080$, which is larger than the total. If a sub-count comes out bigger than the total, you glued in the wrong order.

**Example 24** `SCB · pattern`

12 identical laptops are sent to 4 branch offices. Every office must get at least one. In how many ways can they be split?

**Solution**

The laptops are identical, so only the **numbers** matter. We need
$x_1 + x_2 + x_3 + x_4 = 12$, each $x_i gt.eq 1$.

Picture 12 laptops in a row with 11 gaps between them:
  $L   |   L   |   L \dots.c L$

Put 3 dividers into 3 of the 11 gaps. That cuts the row into 4 non-empty parts.

$""^11 C_3 = (11 \times 10 \times 9)/(3 \times 2 \times 1) = 990/6 = 165$.

**➜ Answer: 165**

**Example 25** `LINE MAN · pattern`

10 identical THB~100 vouchers are given to 4 riders.
(a) Any rider may get none. In how many ways?
(b) Every rider must get at least 2. In how many ways?

**Solution**

(a) $x_1+x_2+x_3+x_4 = 10$, each $x_i gt.eq 0$. Use $""^(n+r-1) C_(r-1)$ with $n=10$, $r=4$.

$""^13 C_3 = (13 \times 12 \times 11)/6 = 1716/6 = 286$.

(b) First hand out the compulsory 2 vouchers to each rider: $4 \times 2 = 8$ used.

Vouchers left $= 10 - 8 = 2$, now free to give to anyone.

$y_1+y_2+y_3+y_4 = 2$ with each $y_i gt.eq 0$:
$""^(2+4-1) C_3 = ""^5 C_3 = ""^5 C_2 = (5 \times 4)/2 = 10$.

**➜ Answer: (a) 286   (b) 10**

---
💡 **SHORTCUT**

"Each must get at least $k$" $arrow.r$ pay the minimum first, then the problem becomes the plain "at least 0" case. Only the leftover count changes.

**Example 26** `GIC · pattern`

12 different analysts are split into 3 groups of 4.
(a) The groups are named Equity, Credit and Macro. In how many ways?
(b) The groups have no names — only the split matters. In how many ways?

**Solution**

(a) Pick Equity's 4 from 12, then Credit's 4 from the remaining 8, then Macro gets the last 4.

$""^12 C_4 = (12 \times 11 \times 10 \times 9)/24 = 11880/24 = 495$.

$""^8 C_4 = (8 \times 7 \times 6 \times 5)/24 = 1680/24 = 70$.

$""^4 C_4 = 1$.

Total $= 495 \times 70 \times 1 = 34650$.

(b) Without names, the same 3 sets can be labelled in $3! = 6$ orders, and all 6 were counted separately above.

$34650/6 = 5775$.

**➜ Answer: (a) 34650   (b) 5775**

---
⚠️ **TRAP**

Divide by $m!$ **only** when the groups are of equal size **and** unlabelled. If the groups have different sizes (say 5, 4, 3), do not divide — the sizes themselves already tell the groups apart.

**Example 27** `Agoda · pattern`

A traveller walks on a city grid. Her hotel is 5 blocks east and 3 blocks north of the station. She only walks east or north.
(a) How many shortest routes are there?
(b) How many of them pass through a coffee shop that is 2 blocks east and 1 block north of the station?

**Solution**

(a) Every shortest route is a word of 5 E's and 3 N's, in some order. Total letters $= 8$.

$8!/(5! dot 3!) = 40320/(120 \times 6) = 40320/720 = 56$.

(b) Split the journey at the coffee shop.

Station $arrow.r$ coffee shop: 2 E and 1 N $arrow.r 3!/(2! dot 1!) = 6/2 = 3$ ways.

Coffee shop $arrow.r$ hotel: still needs $5-2 = 3$ E and $3-1 = 2$ N $arrow.r 5!/(3! dot 2!) = 120/12 = 10$ ways.

Multiply: $3 \times 10 = 30$.

**➜ Answer: (a) 56   (b) 30**

**Example 28** `Razer · pattern`

A 6-digit account PIN must not start with 0 and must have no repeated digit. How many such PINs exist?

**Solution**

Digits available: 0 to 9, that is 10 digits.

**Position 1:** cannot be 0 $arrow.r$ 9 choices.

**Positions 2 to 6:** 9 digits remain (0 is now allowed), and no repeats:
$9 \times 8 \times 7 \times 6 \times 5$.

$9 \times 8 = 72$. $72 \times 7 = 504$. $504 \times 6 = 3024$. $3024 \times 5 = 15120$.

Total $= 9 \times 15120 = 136080$.

**➜ Answer: 136080**

**Example 29** `Sea/Shopee · pattern`

A project team of 5 is chosen from 6 staff in Singapore and 5 staff in Thailand. The team must contain at least 2 from each country. In how many ways?

**Solution**

Team size is 5. "At least 2 from each" allows only these splits:
(2 SG, 3 TH) and (3 SG, 2 TH). A (4,1) split fails the Thailand condition, (1,4) fails Singapore.

**Case A — 2 SG, 3 TH:**
$""^6 C_2 = (6 \times 5)/2 = 15$. $""^5 C_3 = ""^5 C_2 = (5 \times 4)/2 = 10$.
$15 \times 10 = 150$.

**Case B — 3 SG, 2 TH:**
$""^6 C_3 = (6 \times 5 \times 4)/6 = 120/6 = 20$. $""^5 C_2 = 10$.
$20 \times 10 = 200$.

Total $= 150 + 200 = 350$.

**➜ Answer: 350**

**Example 30** `Grab · pattern`

A waiting bench has 9 seats in a row. 4 riders must sit so that no two of them are next to each other. In how many ways?

**Solution**

**Step 1 — the empty seats first.** $9 - 4 = 5$ seats stay empty.

Lay out the 5 empty seats. They create $5 + 1 = 6$ gaps (including the two ends):
  $\*   e   \*   e   \*   e   \*   e   \*   e   \*$

**Step 2 — choose 4 of the 6 gaps** (one rider per gap keeps them apart):
$""^6 C_4 = ""^6 C_2 = (6 \times 5)/2 = 15$.

**Step 3 — the riders are different people, so order them:** $4! = 24$.

Total $= 15 \times 24 = 360$.

(Formula check: $""^(n-r+1) C_r \times r! = ""^6 C_4 \times 4! = 360$. Matches.)

**➜ Answer: 360**

#### Practice — Tier 2 — Singapore & Thailand *(target: 100 s/Q)*

+ 8 people sit around a round table. 3 particular people must sit together. In how many ways?
+ 15 identical cartons are sent to 5 stores, each store getting at least one. In how many ways?
+ 7 identical discount coupons are given to 3 users; a user may get none. In how many ways?
+ A courier must go 4 blocks east and 4 blocks north. How many shortest routes?
+ From 8 drivers, 3 are chosen for the morning shift and 3 different ones for the evening shift. In how many ways?
+ A bundle of 5 items is made from 12 items, and 2 particular items must both be included. How many bundles?
+ A playlist plays 4 songs in order, chosen from 10 different songs. How many playlists?
+ 10 different interns are split into 2 unnamed groups of 5. In how many ways?
+ How many strings of length 5 can be made from the letters A, B, C with repetition allowed?
+ 3 people sit on a row of 7 seats so that no two are adjacent. In how many ways?
+ 5 people sit at a round table; 2 particular people must sit together. In how many ways?
+ How many 4-digit even numbers with no repeated digit can be made from the digits 1, 2, 3, 4, 5?

<details>
<summary><b>Answer key</b></summary>

**1.** 720 — glue the 3: units $= 5 + 1 = 6$, circular $arrow.r 5! = 120$, times $3! = 6$.   

**2.** 1001 — $""^14 C_4 = (14 \times 13 \times 12 \times 11)/24 = 24024/24$.   

**3.** 36 — zero allowed: $""^(7+3-1) C_2 = ""^9 C_2 = 36$.   

**4.** 70 — $8!/(4! 4!) = 40320/576$.   

**5.** 560 — $""^8 C_3 \times ""^5 C_3 = 56 \times 10$. The two shifts are different, so do not divide by $2!$.   

**6.** 120 — the 2 are fixed, pick 3 more from 10: $""^10 C_3$.   

**7.** 5040 — order matters: $""^10 P_4 = 10 \times 9 \times 8 \times 7$.   

**8.** 126 — $""^10 C_5 = 252$, then divide by $2!$ because the groups are unnamed.   

**9.** 243 — $3^5$.   

**10.** 60 — 4 empty seats give 5 gaps: $""^5 C_3 \times 3! = 10 \times 6$.   

**11.** 12 — glue: 4 units circular $arrow.r 3! = 6$, times $2! = 2$.   

**12.** 48 — last digit must be 2 or 4 (2 ways), then $4 \times 3 \times 2 = 24$ for the first three places: $2 \times 24$.

## Tier 3 — Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 31** `Goldman Sachs · pattern`

5 signed letters and their 5 addressed envelopes are mixed up. A clerk puts one letter into each envelope at random. In how many ways can **no** letter end up in its own envelope?

**Solution**

**Insight: count all arrangements, then throw out every arrangement in which at least one letter is correct — by inclusion–exclusion, alternating signs.**

Let $A_i$ = the set of arrangements where letter $i$ IS in its own envelope.

Number with a chosen set of $k$ letters fixed correctly $= (5-k)!$, and there are $""^5 C_k$ such sets.

$ D_5 = 5! - ""^5 C_1 4! + ""^5 C_2 3! - ""^5 C_3 2! + ""^5 C_4 1! - ""^5 C_5 0! $

Term by term:
- $5! = 120$
- $""^5 C_1 \times 4! = 5 \times 24 = 120$
- $""^5 C_2 \times 3! = 10 \times 6 = 60$
- $""^5 C_3 \times 2! = 10 \times 2 = 20$
- $""^5 C_4 \times 1! = 5 \times 1 = 5$
- $""^5 C_5 \times 0! = 1 \times 1 = 1$

$D_5 = 120 - 120 + 60 - 20 + 5 - 1 = 44$.

**➜ Answer: 44**

**Example 32** `D. E. Shaw · pattern`

7 letters are put into 7 addressed envelopes at random. In how many ways do **exactly 3** letters land in the correct envelope?

**Solution**

**Insight: "exactly 3 correct" splits cleanly into two independent jobs — choose which 3 are correct, then force the remaining 4 to be all wrong. The second job is a derangement, not a free arrangement.**

**Step 1 — choose the 3 correct letters:**
$""^7 C_3 = (7 \times 6 \times 5)/(3 \times 2 \times 1) = 210/6 = 35$.

**Step 2 — the other 4 letters must all be wrong.** That is $D_4$.

$D_4 = 4!(1 - 1/1! + 1/2! - 1/3! + 1/4!)$.

Inside the bracket, take 24 as the common denominator:
$1 - 1 + 1/2 - 1/6 + 1/24 = (24 - 24 + 12 - 4 + 1)/24 = 9/24$.

So $D_4 = 24 \times 9/24 = 9$.

**Step 3 — multiply:** $35 \times 9 = 315$.

**➜ Answer: 315**

---
⚠️ **TRAP**

If Step 2 were "$4!$" you would be allowing some of those 4 to also be correct, and the count would include cases with 4, 5, 6 or 7 correct letters. "Exactly $k$" always forces a derangement on the rest: $""^n C_k \times D_(n-k)$.

**Example 33** `Amazon · pattern`

5 different packages are put into 3 different lockers. Every locker must get at least one package. In how many ways?

**Solution**

**Insight: the packages are different and the lockers are different, so start from the free count $3^5$, then remove the arrangements that leave a locker empty — again with inclusion–exclusion.**

**All ways (lockers may be empty):** each package picks one of 3 lockers.
$3^5 = 243$.

**Remove the ways that miss at least one locker.**

Ways that use at most 2 chosen lockers: pick which locker is banned ($""^3 C_1 = 3$ ways), then each package has 2 choices: $2^5 = 32$.
Subtract $3 \times 32 = 96$.

But an arrangement using only 1 locker was subtracted twice (it misses two lockers), so add it back.
Pick which single locker is used: $""^3 C_2 = 3$ ways of banning two lockers, then $1^5 = 1$.
Add $3 \times 1 = 3$.

$243 - 96 + 3 = 150$.

**➜ Answer: 150**

**Example 34** `Google · pattern`

All possible 4-digit numbers are formed using the digits 2, 3, 5, 7, each digit used exactly once. Find the sum of all these numbers.

**Solution**

**Insight: do not add 24 numbers. Count how many times each digit sits in each place — by symmetry, every digit visits every place equally often.**

Total numbers $= 4! = 24$.

Fix digit 2 in the units place. The other 3 digits fill the other 3 places in $3! = 6$ ways.
So each digit appears in the units place exactly 6 times. The same is true for tens, hundreds and thousands.

Sum of the digits $= 2 + 3 + 5 + 7 = 17$.

Sum contributed by the units place $= 6 \times 17 = 102$.
Tens place $= 102 \times 10$. Hundreds $= 102 \times 100$. Thousands $= 102 \times 1000$.

$ "Total" = 102 \times (1 + 10 + 100 + 1000) = 102 \times 1111 $

$102 \times 1111 = 102 \times 1000 + 102 \times 100 + 102 \times 10 + 102 = 102000 + 10200 + 1020 + 102 = 113322$.

Check: average number $= 113322 / 24 = 4721.75$, and the average digit is $17/4 = 4.25$, giving $4721.75$. Matches.

**➜ Answer: 113322**

---
💡 **SHORTCUT**

General rule: with $n$ distinct non-zero digits all used, each digit appears $(n-1)!$ times in each place, so
Sum $= (n-1)! \times ("sum of digits") \times (underbrace(1 1 \dots.c 1, n))$.
For 4 digits the repunit is $1111$; for 3 digits it is $111$.

**Example 35** `Microsoft · pattern`

An $8 \times 8$ chessboard is drawn.
(a) How many rectangles are there in the figure?
(b) How many of them are squares?

**Solution**

**Insight: a rectangle is not a shape you hunt for — it is fixed the moment you choose two vertical lines and two horizontal lines.**

(a) An $8 \times 8$ board of cells is made of 9 vertical lines and 9 horizontal lines.

Choose 2 vertical lines: $""^9 C_2 = (9 \times 8)/2 = 36$.
Choose 2 horizontal lines: $""^9 C_2 = 36$.

Rectangles $= 36 \times 36 = 1296$.

(b) A $k \times k$ square needs its top-left corner in a $(9-k) \times (9-k)$ block of positions, so there are $(9-k)^2$ squares of side $k$.

$k=1: 8^2 = 64$, $k=2: 7^2=49$, $k=3: 36$, $k=4: 25$, $k=5: 16$, $k=6: 9$, $k=7: 4$, $k=8: 1$.

$64+49 = 113$. $113+36 = 149$. $149+25 = 174$. $174+16 = 190$. $190+9 = 199$. $199+4 = 203$. $203+1 = 204$.

**➜ Answer: (a) 1296 rectangles   (b) 204 squares**

**Example 36** `Uber · pattern`

In how many ways can 3 numbers be chosen from $1, 2, 3, \dots, 20$ so that no two chosen numbers are consecutive?

**Solution**

**Insight: shrink the problem. Subtract a growing amount from each chosen number so that "no two consecutive" turns into "all different" — a plain combination.**

Let the chosen numbers be $a < b < c$ with $b gt.eq a+2$ and $c gt.eq b+2$.

Define $a' = a$, $b' = b - 1$, $c' = c - 2$.

Then $b' - a' = b - a - 1 gt.eq 1$ and $c' - b' = c - b - 1 gt.eq 1$, so $a' < b' < c'$ with no gap condition at all.

Range: $a' gt.eq 1$ and $c' = c - 2 lt.eq 20 - 2 = 18$.

So $a', b', c'$ are any 3 different numbers from $1$ to $18$. And the map is reversible, so the counts are equal.

$""^18 C_3 = (18 \times 17 \times 16)/(3 \times 2 \times 1) = 4896/6 = 816$.

(Formula check: $""^(n-r+1) C_r = ""^(20-3+1) C_3 = ""^18 C_3$. Matches.)

**➜ Answer: 816**

**Example 37** `Adobe · pattern`

How many solutions in non-negative integers does $x + y + z = 20$ have, if $x lt.eq 8$?

**Solution**

**Insight: an upper bound is handled the same way as a "must not happen" rule — count everything, then subtract the cases that break the bound. And the broken cases are themselves a clean stars-and-bars count after a substitution.**

**Step 1 — all non-negative solutions.**
$""^(20+3-1) C_(3-1) = ""^22 C_2 = (22 \times 21)/2 = 462/2 = 231$.

**Step 2 — the bad ones, where $x gt.eq 9$.**
Put $x = 9 + x'$ with $x' gt.eq 0$. Then
$9 + x' + y + z = 20 arrow.r x' + y + z = 11$.

$""^(11+3-1) C_2 = ""^13 C_2 = (13 \times 12)/2 = 156/2 = 78$.

**Step 3 — subtract.**
$231 - 78 = 153$.

**➜ Answer: 153**

**Example 38** `Google · pattern`

In how many ways can 10 be written as an **ordered** sum of positive integers?
(For example $10$, $7+3$, $3+7$, $1+1+8$ all count as different.)

**Solution**

**Insight: an ordered sum is just a way of cutting a row of ten 1's into blocks. Every cut position is an independent yes/no choice.**

Write 10 as ten 1's in a row:
  $1   1   1   1   1   1   1   1   1   1$

There are $10 - 1 = 9$ gaps between neighbouring 1's.

In each gap, either place a "$+$" (start a new part) or join the two 1's into the same part. Two choices, independently, in each of the 9 gaps.

$2^9 = 512$.

Cross-check with the parts count: the number of ordered sums with exactly $k$ parts is $""^9 C_(k-1)$, and
$""^9 C_0 + ""^9 C_1 + \dots.c + ""^9 C_9 = 2^9 = 512$. Matches.

**➜ Answer: 512**

#### Practice — Tier 3 — Product *(target: 4 min/Q)*

+ 6 letters are placed at random into 6 addressed envelopes. In how many ways does no letter reach its correct envelope?
+ 5 letters are placed at random into 5 addressed envelopes. In how many ways do exactly 2 reach the correct envelope?
+ 6 different balls are put into 3 different boxes so that no box is empty. In how many ways?
+ All possible 3-digit numbers are formed from the digits 1, 3, 5, 7 using each digit at most once. Find the sum of all of them.
+ In how many ways can 4 numbers be chosen from 1 to 15 so that no two are consecutive?
+ How many solutions in non-negative integers does $a + b + c + d = 12$ have if every variable is at most 6?
+ How many squares are there in a $6 \times 6$ grid of cells?
+ How many 5-digit numbers have their digits in strictly increasing order?

<details>
<summary><b>Answer key</b></summary>

**1.** **265.** This is $D_6$. Using $D_n = (n-1)(D_(n-1) + D_(n-2))$ with $D_4 = 9$ and $D_5 = 44$: $D_6 = 5(44 + 9) = 5 \times 53 = 265$. The recurrence is far faster than the full inclusion–exclusion sum, and worth memorising up to $D_6$.   

**2.** **20.** Choose which 2 are correct: $""^5 C_2 = 10$. The remaining 3 must all be wrong: $D_3 = 2$. So $10 \times 2 = 20$. Using $3!$ instead of $D_3$ gives 60, which wrongly includes cases with more than 2 correct.   

**3.** **540.** Free count $3^6 = 729$. Subtract the ones missing a box: $""^3 C_1 \times 2^6 = 3 \times 64 = 192$. Add back the ones using a single box: $""^3 C_2 \times 1^6 = 3$. $729 - 192 + 3 = 540$.   

**4.** **10656.** Total numbers $= ""^4 P_3 = 24$. Each of the 4 digits appears $24/4 = 6$ times in each of the 3 places. Sum of digits $= 1+3+5+7 = 16$, so each place contributes $6 \times 16 = 96$. Total $= 96 \times 111 = 10656$.   

**5.** **495.** Shrink: subtract 0, 1, 2, 3 from the four chosen numbers in order, giving 4 distinct values in the range 1 to $15 - 3 = 12$. So $""^12 C_4 = (12 \times 11 \times 10 \times 9)/24 = 11880/24 = 495$.   

**6.** **231.** All solutions: $""^15 C_3 = 455$. Bad ones with a chosen variable $gt.eq 7$: substitute and get a total of 5, giving $""^8 C_3 = 56$ each, and there are 4 variables: $4 \times 56 = 224$. Two variables cannot both be $gt.eq 7$ since $14 > 12$, so nothing is added back. $455 - 224 = 231$.   

**7.** **91.** Squares of side $k$ number $(7-k)^2$: $36 + 25 + 16 + 9 + 4 + 1 = 91$. (Rectangles would be $""^7 C_2 \times ""^7 C_2 = 441$.)   

**8.** **126.** Once you choose 5 different digits, exactly one increasing order exists — so this is a pure selection. The digit 0 can never be used, because in an increasing number it would have to come first. So choose 5 from $1..9$: $""^9 C_5 = ""^9 C_4 = (9 \times 8 \times 7 \times 6)/24 = 3024/24 = 126$.

## Mixed set — exam conditions

#### Practice — Tier 1 — Service *(target: 90 s/Q · 30 min total)*

+ Find $""^9 P_2$.
+ How many arrangements are there of the letters of **ACCOUNT**?
+ From 5 red and 4 blue pens, 2 red and 1 blue are chosen. In how many ways?
+ In how many ways can 4 friends sit around a circular table?
+ How many 3-digit numbers with no repeated digit can be formed from the digits 0 to 9?
+ 20 identical pens are given to 4 students, each getting at least one. In how many ways?
+ How many diagonals does a 15-sided polygon have?
+ A team of 4 is chosen from 5 men and 4 women with at least 1 woman. In how many ways?
+ 7 letters go into 7 addressed envelopes at random. In how many ways does exactly 1 reach the right envelope?
+ A delivery route goes 6 blocks east and 4 blocks north. How many shortest routes?
+ A 4-character password uses the 26 capital letters and the 10 digits, with repetition allowed. How many passwords?
+ How many arrangements are there of the letters of **ENGINEERING**?
+ In how many ways can 3 numbers be chosen from 1 to 30 so that no two are consecutive?
+ 5 different prizes are given to 3 students; a student may get any number of prizes. In how many ways?
+ From 4 different fruits, at least one must be chosen. In how many ways?
+ 6 people sit at a round table; 2 particular people must not sit together. In how many ways?
+ Find the sum of all 3-digit numbers formed from the digits 2, 4, 6 with no digit repeated.
+ 12 distinct books are split into 2 unnamed groups of 6. In how many ways?
+ How many 4-letter arrangements can be made from the letters of **DELTA** with no letter repeated?
+ In how many ways can 3 identical red balls and 2 identical blue balls be placed in a row?

<details>
<summary><b>Answer key</b></summary>

**1.** 72 — $9 \times 8$.   

**2.** 2520 — 7 letters, C twice: $5040/2$.   

**3.** 40 — $""^5 C_2 \times ""^4 C_1 = 10 \times 4$.   

**4.** 6 — $(4-1)! = 3!$.   

**5.** 648 — first digit 9 ways (not 0), then $9 \times 8$: $9 \times 9 \times 8$.   

**6.** 969 — $""^19 C_3 = (19 \times 18 \times 17)/6 = 5814/6$.   

**7.** 90 — $(15 \times 12)/2$.   

**8.** 121 — all $""^9 C_4 = 126$, minus all-men $""^5 C_4 = 5$.   

**9.** 1855 — $""^7 C_1 \times D_6 = 7 \times 265$.   

**10.** 210 — $10!/(6! 4!) = ""^10 C_4$.   

**11.** 1679616 — 36 symbols, 4 slots: $36^4$.   

**12.** 277200 — 11 letters: E three times, N three times, G twice, I twice. $39916800/(6 \times 6 \times 2 \times 2) = 39916800/144$.   

**13.** 3276 — $""^(30-3+1) C_3 = ""^28 C_3 = (28 \times 27 \times 26)/6 = 19656/6$.   

**14.** 243 — each of the 5 distinct prizes picks a student: $3^5$.   

**15.** 15 — $2^4 - 1$.   

**16.** 72 — total $5! = 120$; together $= 4! \times 2 = 48$; $120 - 48$.   

**17.** 2664 — 6 numbers; each digit appears $6/3 = 2$ times per place; digit sum $= 12$; $2 \times 12 = 24$ per place; $24 \times 111$.   

**18.** 462 — $""^12 C_6 = 924$, divided by $2!$ for unnamed groups.   

**19.** 120 — $""^5 P_4 = 5 \times 4 \times 3 \times 2$.   

**20.** 10 — $5!/(3! 2!) = 120/12$.

## 📋 One-page revision card

**THE FIRST QUESTION, ALWAYS:** does order matter?
Order matters $arrow.r ""^n P_r$. Order does not matter $arrow.r ""^n C_r$.

**CORE**
- $""^n P_r = n!/(n-r)! = r$ factors counting down from $n$
- $""^n C_r = (""^n P_r)/r! = n!/(r!(n-r)!)$, and $""^n C_r = ""^n C_(n-r)$
- $""^n C_2 = (n(n-1))/2$, $""^n C_3 = (n(n-1)(n-2))/6$, $sum_r ""^n C_r = 2^n$
- $0! = 1$; $5! = 120$, $6! = 720$, $7! = 5040$, $8! = 40320$, $9! = 362880$, $10! = 3628800$

**THE PATTERNS**
#table(columns: 2,
[Repetition allowed, $r$ slots], [$n^r$],
[Letters with repeats], [$n!/(p! q! \dots.c)$],
[Round table, $n$ people], [$(n-1)!$],
[Necklace], [$(n-1)!/2$],
[Group together], [glue $arrow.r (k)! \times ("units arrangement")$],
[No two together ($r$ of $n$ in a row)], [$""^(n-r+1) C_r$, then $\times r!$ if distinct],
[Identical into $r$ groups, each $gt.eq 1$], [$""^(n-1) C_(r-1)$],
[Identical into $r$ groups, each $gt.eq 0$], [$""^(n+r-1) C_(r-1)$],
[$m n$ distinct into $m$ labelled groups of $n$], [$(m n)!/(n!)^m$],
[…into $m$ unlabelled groups], [$(m n)!/((n!)^m m!)$],
[$n$ distinct into 3 distinct boxes, none empty], [$3^n - 3 dot 2^n + 3$],
[Grid, $m$ east and $n$ north], [$(m+n)!/(m! n!)$],
[Diagonals of $n$-gon], [$(n(n-3))/2$],
[Rectangles in $a \times b$ cells], [$""^(a+1) C_2 \times ""^(b+1) C_2$],
[Derangement], [$D_n = (n-1)(D_(n-1)+D_(n-2))$],
[Exactly $k$ correct out of $n$], [$""^n C_k \times D_(n-k)$],
[Sum of all numbers, $n$ distinct digits], [$(n-1)! \times ("digit sum") \times 1 1 \dots 1$],
)

$D_1=0$, $D_2=1$, $D_3=2$, $D_4=9$, $D_5=44$, $D_6=265$, $D_7=1854$.

**THE FIVE SHORTCUTS**
+ Flip $""^n C_r$ to $""^n C_(n-r)$ whenever $r > n/2$.
+ "Must not both appear" $arrow.r$ total minus (both forced in).
+ "Each gets at least $k$" $arrow.r$ pay the minimum first, then count the leftover freely.
+ "Together" $arrow.r$ glue and multiply by the inside arrangements.
+ "No two together" $arrow.r$ seat the others, then use the gaps ($1$ more gap than items).

**THE TOP FIVE TRAPS**
+ **Leading zero.** A number cannot begin with 0. Handle the first place separately.
+ **"At least" done in one shot.** Split into disjoint cases and add. A single clever product double-counts.
+ **Circular gluing order.** Glue first, count the new units, only then apply $(k-1)!$.
+ **Dividing by $m!$ when you should not.** Divide only for equal-sized **unlabelled** groups. Named groups (Team A, Team B) are already distinct.
+ **Using $(n-k)!$ instead of $D_(n-k)$ for "exactly $k$ correct".** The rest must be forced wrong, not left free.

</details>

</details>

</details>

</details>
