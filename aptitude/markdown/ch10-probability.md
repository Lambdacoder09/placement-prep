# Chapter 10 — Probability

*Count the good cases. Divide. Then check the condition.*

## What you need to know

**WHAT YOU NEED TO KNOW**

**Classical probability.** For equally likely outcomes:
$ P(E) = ("number of favourable outcomes")/("total number of outcomes") $
Always $0 lt.eq P(E) lt.eq 1$. $P("certain") = 1$, $P("impossible") = 0$.

**Complement.** $P("not" E) = 1 - P(E)$. Use this for every "at least one" question.

**Odds.** Odds in favour $a : b arrow.r P = a/(a+b)$. Odds against $a : b arrow.r P = b/(a+b)$.

**Addition rule.**
$ P(A union B) = P(A) + P(B) - P(A inter B) $
Mutually exclusive (cannot both happen) $arrow.r P(A inter B) = 0$.

**Multiplication rule.**
$ P(A inter B) = P(A) dot P(B \mid A) $
Independent (one does not affect the other) $arrow.r P(A inter B) = P(A) dot P(B)$.

**Conditional probability.**
$ P(A \mid B) = (P(A inter B))/(P(B)), \quad P(B) \\ne 0 $
In counting language: shrink the sample space to $B$, then count inside it.

**Total probability.** If $B_1, B_2, \dots, B_n$ cover all cases and do not overlap:
$ P(E) = P(B_1) P(E \mid B_1) + P(B_2) P(E \mid B_2) + \dots.c $

**Bayes' theorem.** (Cause given effect.)
$ P(B_i \mid E) = (P(B_i) P(E \mid B_i))/(sum_j P(B_j) P(E \mid B_j)) $

**Expected value.** If $X$ takes value $x_i$ with probability $p_i$:
$ E[X] = sum x_i p_i $
**Linearity:** $E[X + Y] = E[X] + E[Y]$ — true even when $X$ and $Y$ are **not** independent.
**Indicator trick:** to count "how many of these $n$ things happen", add the $n$ separate probabilities.

**Binomial.** $n$ independent trials, success probability $p$ each, $q = 1 - p$:
$ P("exactly" r "successes") = ""^n C_r p^r q^(n-r) $
Mean $= n p$. Variance $= n p q$.

**Geometric (waiting).** Repeat until the first success, probability $p$ each try:
$ P("first success on try" k) = q^(k-1) p, \quad E["number of tries"] = 1/p $
It is **memoryless**: past failures do not change what is left to wait.

**Standard sample spaces.**
- One die: 6 outcomes. Two dice: 36 outcomes.
- Sum on two dice — number of ways:
#table(columns: 11,
[**Sum**],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11 / 12],
[**Ways**],[1],[2],[3],[4],[5],[6],[5],[4],[3],[2 / 1],
)
- $n$ coins: $2^n$ outcomes; exactly $r$ heads in $""^n C_r$ ways.
- A deck: 52 cards, 26 red, 26 black, 4 suits of 13, 4 aces, 12 face cards (J, Q, K), 6 red face cards.
- Drawing $r$ balls at once from a bag = combinations: total $= ""^n C_r$.

**Calendar.** Ordinary year $= 52$ weeks $+ 1$ odd day $arrow.r P(53 "of a given weekday") = 1/7$.
Leap year $= 52$ weeks $+ 2$ odd days $arrow.r P = 2/7$.

## Warm-up

### Warm-up

**Example 1**

A fair die is rolled. Find (a) $P("even")$, (b) $P("more than" 4)$.

**Solution**

Total outcomes $= 6$.

(a) Even faces: 2, 4, 6 $arrow.r$ 3 favourable. $P = 3/6 = 1/2$.

(b) More than 4: 5, 6 $arrow.r$ 2 favourable. $P = 2/6 = 1/3$.

**➜ Answer: (a) $1/2$   (b) $1/3$**

**Example 2**

One card is drawn from a well-shuffled deck of 52. Find (a) $P("king")$, (b) $P("spade")$.

**Solution**

(a) 4 kings. $P = 4/52 = 1/13$.

(b) 13 spades. $P = 13/52 = 1/4$.

**➜ Answer: (a) $1/13$   (b) $1/4$**

**Example 3**

Two fair coins are tossed. Find (a) $P("exactly one head")$, (b) $P("at least one head")$.

**Solution**

Outcomes: HH, HT, TH, TT $arrow.r$ 4 in all.

(a) Exactly one head: HT, TH $arrow.r 2$. $P = 2/4 = 1/2$.

(b) At least one head: all except TT $arrow.r 3$. $P = 3/4$.

**➜ Answer: (a) $1/2$   (b) $3/4$**

**Example 4**

A bag has 5 red and 3 blue balls. One ball is drawn. Find $P("blue")$.

**Solution**

Total balls $= 5 + 3 = 8$. Blue $= 3$.

$P = 3/8$.

**➜ Answer: $3/8$**

**Example 5**

Two fair dice are rolled. Find $P("sum" = 7)$.

**Solution**

Total outcomes $= 6 \times 6 = 36$.

Sum 7: $(1,6), (2,5), (3,4), (4,3), (5,2), (6,1) arrow.r 6$ ways.

$P = 6/36 = 1/6$.

**➜ Answer: $1/6$**

**Example 6**

(a) $P(A) = 0.35$. Find $P("not" A)$.
(b) The odds in favour of an event are $3 : 5$. Find its probability.

**Solution**

(a) $P("not" A) = 1 - 0.35 = 0.65$.

(b) Odds in favour $3 : 5$ means 3 favourable parts and 5 unfavourable parts.
Total parts $= 3 + 5 = 8$. $P = 3/8$.

**➜ Answer: (a) 0.65   (b) $3/8$**

**Example 7**

$A$ and $B$ are independent with $P(A) = 0.6$ and $P(B) = 0.5$.
Find (a) $P("both")$, (b) $P("neither")$.

**Solution**

(a) Independent $arrow.r$ multiply. $P(A inter B) = 0.6 \times 0.5 = 0.30$.

(b) $P("not" A) = 1 - 0.6 = 0.4$ and $P("not" B) = 1 - 0.5 = 0.5$.
$P("neither") = 0.4 \times 0.5 = 0.20$.

**➜ Answer: (a) 0.30   (b) 0.20**

**Example 8**

$P(A) = 1/2$, $P(B) = 1/3$, $P(A inter B) = 1/6$. Find $P(A union B)$.

**Solution**

$P(A union B) = P(A) + P(B) - P(A inter B) = 1/2 + 1/3 - 1/6$.

Common denominator 6: $3/6 + 2/6 - 1/6 = 4/6 = 2/3$.

**➜ Answer: $2/3$**

## Tier 1 — Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

Two fair dice are rolled. Find the probability that the sum is at least 10.

**Solution**

Total outcomes $= 36$.

Sum $= 10$: $(4,6), (5,5), (6,4) arrow.r 3$ ways.
Sum $= 11$: $(5,6), (6,5) arrow.r 2$ ways.
Sum $= 12$: $(6,6) arrow.r 1$ way.

Favourable $= 3 + 2 + 1 = 6$.

$P = 6/36 = 1/6$.

**➜ Answer: $1/6$**

**Example 10** `Accenture pattern`

One card is drawn from a deck of 52. Find the probability that it is a face card **or** a red card.

**Solution**

Face cards (J, Q, K in 4 suits) $= 12$.
Red cards $= 26$.
Cards that are both red and a face card $= 6$ (J, Q, K of hearts and of diamonds).

$P(F union R) = P(F) + P(R) - P(F inter R) = 12/52 + 26/52 - 6/52 = 32/52$.

$32/52 = 8/13$.

**➜ Answer: $8/13$**

---
⚠️ **TRAP**

Do not add $12/52 + 26/52 = 38/52$. The 6 red face cards would be counted twice. Whenever two events can happen together, the overlap must be removed exactly once.

**Example 11** `Infosys pattern`

A bag has 4 red, 5 green and 3 blue balls. Two balls are drawn together (without replacement).
Find (a) $P("both red")$, (b) $P("one red and one green")$.

**Solution**

Total balls $= 4 + 5 + 3 = 12$.

Total ways to draw 2 $= ""^12 C_2 = (12 \times 11)/2 = 66$.

(a) Both red: $""^4 C_2 = (4 \times 3)/2 = 6$.
$P = 6/66 = 1/11$.

(b) One red and one green: $""^4 C_1 \times ""^5 C_1 = 4 \times 5 = 20$.
$P = 20/66 = 10/33$.

**➜ Answer: (a) $1/11$   (b) $10/33$**

---
💡 **SHORTCUT**

**Two balls drawn together = draw them one by one.** For "both red" you may also write
$4/12 \times 3/11 = 12/132 = 1/11$ — the same answer, with no $""^n C_r$ at all.

For a **mixed** pair like "one red and one green" you must allow both orders:
$4/12 \times 5/11 + 5/12 \times 4/11 = 20/132 + 20/132 = 40/132 = 10/33$.
Same answer again. Use whichever line you can write faster, but remember: same colour $arrow.r$ one order, different colours $arrow.r$ two orders.

**Example 12** `Wipro pattern`

Three fair coins are tossed. Find (a) $P("at least one head")$, (b) $P("exactly two heads")$.

**Solution**

Total outcomes $= 2^3 = 8$.

(a) The only outcome with no head is TTT, which is 1 outcome.
$P("no head") = 1/8$, so $P("at least one head") = 1 - 1/8 = 7/8$.

(b) Exactly two heads: $""^3 C_2 = 3$ outcomes (HHT, HTH, THH).
$P = 3/8$.

**➜ Answer: (a) $7/8$   (b) $3/8$**

---
💡 **SHORTCUT**

**"At least one" $arrow.r$ turn it around.** $P("at least one") = 1 - P("none")$. "None" is a single easy product; "at least one" is a long sum of cases. This single move saves more time in this chapter than any other.

**Example 13** `Capgemini pattern`

Anjali can solve a problem with probability $1/3$ and Bhavin with probability $1/4$, independently.
Find (a) $P("the problem gets solved")$, (b) $P("exactly one of them solves it")$.

**Solution**

$P("Anjali fails") = 1 - 1/3 = 2/3$. $P("Bhavin fails") = 1 - 1/4 = 3/4$.

(a) $P("both fail") = 2/3 \times 3/4 = 6/12 = 1/2$.
$P("solved") = 1 - 1/2 = 1/2$.

(b) Anjali solves and Bhavin fails: $1/3 \times 3/4 = 3/12$.
Bhavin solves and Anjali fails: $2/3 \times 1/4 = 2/12$.

These two cases cannot happen together, so add:
$3/12 + 2/12 = 5/12$.

**➜ Answer: (a) $1/2$   (b) $5/12$**

**Example 14** `Cognizant pattern`

A number is picked at random from 1 to 50. Find the probability that it is divisible by 3 or by 5.

**Solution**

Multiples of 3 up to 50: $50 \div 3 = 16$ (remainder 2) $arrow.r 16$ numbers.
Multiples of 5 up to 50: $50 \div 5 = 10 arrow.r 10$ numbers.
Multiples of 15 (both) up to 50: $50 \div 15 = 3$ (remainder 5) $arrow.r 3$ numbers.

Favourable $= 16 + 10 - 3 = 23$.

$P = 23/50$.

**➜ Answer: $23/50$**

**Example 15** `TCS NQT pattern`

Two fair dice are rolled. Find the probability that the product of the numbers is even.

**Solution**

The product is odd only when **both** numbers are odd.

Odd faces: 1, 3, 5 $arrow.r$ 3 choices on each die.
Both odd $= 3 \times 3 = 9$ outcomes.

$P("product odd") = 9/36 = 1/4$.

$P("product even") = 1 - 1/4 = 3/4$.

**➜ Answer: $3/4$**

**Example 16** `Accenture pattern`

The letters of the word **TABLE** are arranged at random. Find the probability that the two vowels come together.

**Solution**

T, A, B, L, E $arrow.r$ 5 different letters.

Total arrangements $= 5! = 120$.

Vowels are A and E. Glue them into one block.
Units $=$ T, B, L $+$ 1 block $= 4$ units $arrow.r 4! = 24$.
Inside the block: $2! = 2$.
Favourable $= 24 \times 2 = 48$.

$P = 48/120 = 2/5$.

**➜ Answer: $2/5$**

**Example 17** `Infosys pattern`

A box holds 6 good bulbs and 4 defective bulbs. Three bulbs are drawn at random together.
Find (a) $P("all good")$, (b) $P("exactly one defective")$.

**Solution**

Total bulbs $= 10$. Total ways $= ""^10 C_3 = (10 \times 9 \times 8)/6 = 720/6 = 120$.

(a) All 3 good: $""^6 C_3 = (6 \times 5 \times 4)/6 = 120/6 = 20$.
$P = 20/120 = 1/6$.

(b) 1 defective and 2 good: $""^4 C_1 \times ""^6 C_2 = 4 \times 15 = 60$.
$P = 60/120 = 1/2$.

**➜ Answer: (a) $1/6$   (b) $1/2$**

**Example 18** `Wipro pattern`

Find the probability that (a) an ordinary year has 53 Sundays, (b) a leap year has 53 Sundays.

**Solution**

(a) An ordinary year has 365 days. $365 = 52 \times 7 + 1$.

So there are 52 full weeks (giving 52 Sundays for sure) plus 1 extra day.
That extra day is equally likely to be any of the 7 weekdays.
A 53rd Sunday happens only if the extra day is a Sunday.

$P = 1/7$.

(b) A leap year has 366 days. $366 = 52 \times 7 + 2$.

The 2 extra days are consecutive. The 7 equally likely pairs are:
(Sun, Mon), (Mon, Tue), (Tue, Wed), (Wed, Thu), (Thu, Fri), (Fri, Sat), (Sat, Sun).

Sunday appears in 2 of these 7 pairs.

$P = 2/7$.

**➜ Answer: (a) $1/7$   (b) $2/7$**

**Example 19** `TCS NQT pattern`

Two cards are drawn one after the other from a deck of 52, without replacement. Find $P("both are aces")$.

**Solution**

First card an ace: $4/52 = 1/13$.

Now 51 cards are left and only 3 aces remain.
Second card an ace, given the first was: $3/51 = 1/17$.

$P = 1/13 \times 1/17 = 1/221$.

**➜ Answer: $1/221$**

---
⚠️ **TRAP**

**With replacement or without?** If the first card is put back, the second probability is again $4/52$ and the answer becomes $1/169$. Read the sentence again before you multiply. In "drawn together" or "drawn one after the other" problems, assume **without** replacement unless the words "with replacement" appear.

**Example 20** `Capgemini pattern`

Ravi speaks the truth 75% of the time and Sita 80% of the time. They each describe the same event independently. Find the probability that they contradict each other.

**Solution**

$P(R "truth") = 0.75$, $P(R "lie") = 0.25$.
$P(S "truth") = 0.80$, $P(S "lie") = 0.20$.

They contradict when exactly one of them is lying.

Ravi truth AND Sita lie: $0.75 \times 0.20 = 0.15$.
Ravi lie AND Sita truth: $0.25 \times 0.80 = 0.20$.

These cases are separate, so add: $0.15 + 0.20 = 0.35$.

$0.35 = 35%$.

**➜ Answer: 0.35, that is 35%**

#### Practice — Tier 1 — Service *(target: 60 s/Q)*

+ A fair die is rolled. Find $P("the number is prime")$.
+ Two fair dice are rolled. Find $P("sum" = 9)$.
+ One card is drawn from a deck. Find $P("neither a king nor a queen")$.
+ A bag has 6 white and 4 black balls. One is drawn. Find $P("black")$.
+ Two fair coins are tossed. Find $P("no head")$.
+ Four fair coins are tossed. Find $P("exactly 3 heads")$.
+ $A$ and $B$ are independent, $P(A) = 0.4$, $P(B) = 0.3$. Find $P(A union B)$.
+ A number is picked from 1 to 20. Find $P("it is divisible by" 4)$.
+ A bag has 5 red and 7 blue balls. Two are drawn together. Find $P("both blue")$.
+ Two fair dice are rolled. Find $P("a doublet")$ — both dice show the same number.
+ A ticket is drawn from tickets numbered 1 to 15. Find $P("multiple of 3 or of 5")$.
+ $P(A) = 0.5$, $P(B) = 0.6$, $P(A union B) = 0.8$. Find $P(A inter B)$.
+ Three students solve a problem independently with probabilities $1/2$, $1/3$ and $1/4$. Find $P("at least one solves it")$.
+ One card is drawn from a deck. Find $P("a red face card")$.
+ The letters of the word **APPLE** are arranged at random. Find $P("the two P's are together")$.

<details>
<summary><b>Answer key</b></summary>

**1.** $1/2$ — primes on a die are 2, 3, 5 $arrow.r 3/6$. (1 is not prime; answering $2/3$ means you counted it.)   

**2.** $1/9$ — $(3,6),(4,5),(5,4),(6,3) arrow.r 4/36$.   

**3.** $11/13$ — 4 kings $+$ 4 queens $= 8$ excluded; $44/52$.   

**4.** $2/5$ — $4/10$.   

**5.** $1/4$ — only TT out of 4 outcomes.   

**6.** $1/4$ — $""^4 C_3 = 4$ out of $2^4 = 16$.   

**7.** 0.58 — $0.4 + 0.3 - (0.4 \times 0.3) = 0.7 - 0.12$. Answering 0.7 means you treated them as mutually exclusive.   

**8.** $1/4$ — 4, 8, 12, 16, 20 $arrow.r 5/20$.   

**9.** $7/22$ — $""^7 C_2 / ""^12 C_2 = 21/66$.   

**10.** $1/6$ — 6 doublets out of 36.   

**11.** $7/15$ — multiples of 3: 5; of 5: 3; of 15: 1. $5 + 3 - 1 = 7$.   

**12.** 0.3 — $P(A inter B) = 0.5 + 0.6 - 0.8$.   

**13.** $3/4$ — $P("none") = 1/2 \times 2/3 \times 3/4 = 6/24 = 1/4$; answer $= 1 - 1/4$.   

**14.** $3/26$ — 6 red face cards out of 52.   

**15.** $2/5$ — total $= 5!/2! = 60$; PP glued gives $4! = 24$ (do not multiply by $2!$, the two P's are identical); $24/60$.

## Tier 2 — Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 21** `Grab · pattern`

60% of a city's rides are inside the city centre and 40% are suburban. A city-centre ride finishes within 20 minutes with probability 0.90; a suburban ride with probability 0.70. A ride is picked at random. Find the probability that it finished within 20 minutes.

**Solution**

Two possible "causes": city centre ($C$) or suburban ($S$). They cover everything and do not overlap.

$P(C) = 0.60$, $P(S) = 0.40$.
$P(F \mid C) = 0.90$, $P(F \mid S) = 0.70$, where $F$ = finished in 20 min.

Total probability:
$ P(F) = P(C) P(F \mid C) + P(S) P(F \mid S) $

$= 0.60 \times 0.90 + 0.40 \times 0.70$

$= 0.54 + 0.28 = 0.82$.

**➜ Answer: 0.82, that is 82%**

**Example 22** `Grab · pattern`

Use the same data as Example 21. A ride is found to have finished within 20 minutes. Find the probability that it was a city-centre ride.

**Solution**

Now the direction is reversed: we know the **effect** and ask about the **cause**. That is Bayes.

$ P(C \mid F) = (P(C) P(F \mid C))/(P(F)) $

Numerator $= 0.60 \times 0.90 = 0.54$ (computed in Example 21).
Denominator $= 0.82$.

$P(C \mid F) = 0.54/0.82 = 54/82 = 27/41$.

As a decimal: $27 \div 41 = 0.6585dots \approx 0.659$.

**➜ Answer: $27/41 \approx 0.659$**

---
💡 **SHORTCUT**

Bayes is just a two-line table. Write down the product $P("cause") \times P("effect" \mid "cause")$ for each cause, add the column to get $P("effect")$, then divide the row you want by that total. You never need to recall the full formula.
#table(columns: 4,
[**Cause**],[**Prior**],[$P(F \mid dot)$],[**Product**],
[City],[0.60],[0.90],[0.54],
[Suburb],[0.40],[0.70],[0.28],
[],[],[**Total**],[**0.82**],
)

**Example 23** `Shopee · pattern`

Warehouse A ships 70% of all orders and damages 2% of what it ships. Warehouse B ships the other 30% and damages 5%. Find the probability that a randomly chosen order arrives damaged.

**Solution**

$P(A) = 0.70$, $P(D \mid A) = 0.02 arrow.r$ product $= 0.70 \times 0.02 = 0.014$.

$P(B) = 0.30$, $P(D \mid B) = 0.05 arrow.r$ product $= 0.30 \times 0.05 = 0.015$.

$P(D) = 0.014 + 0.015 = 0.029$.

$0.029 = 2.9%$.

**➜ Answer: 0.029, that is 2.9%**

**Example 24** `Shopee · pattern`

Continuing Example 23: an order arrives damaged. Find the probability that it came from warehouse B.

**Solution**

$ P(B \mid D) = (P(B) P(D \mid B))/(P(D)) = 0.015/0.029 $

Multiply top and bottom by 1000: $15/29$.

$15 \div 29 = 0.5172dots \approx 0.517$.

**➜ Answer: $15/29 \approx 0.517$**

---
⚠️ **TRAP**

Warehouse B ships less than half the orders, yet it is the more likely source of a damaged one. A small group with a high failure rate can dominate. Never answer a Bayes question with the prior (0.30) — the evidence has changed it.

**Example 25** `DBS · pattern`

A bank runs a promo spin. A customer wins S$50 with probability 0.02, wins S$10 with probability 0.10, and wins nothing otherwise. 5,000 customers spin.
(a) What is the expected payout per customer? (b) What total payout should the bank budget for?

**Solution**

(a) List value and probability:

#table(columns: 3,
[**Prize**],[S$50],[S$10],
[**Probability**],[0.02],[0.10],
)
Nothing: probability $= 1 - 0.02 - 0.10 = 0.88$, value 0.

$E = 50 \times 0.02 + 10 \times 0.10 + 0 \times 0.88$

$= 1.00 + 1.00 + 0 = 2.00$, that is S$2.00 per customer.

(b) Expected total $= 5000 times 2.00 = 10000$, that is S$10,000.

**➜ Answer: (a) S$2 per customer   (b) S$10,000**

**Example 26** `Agoda · pattern`

8 guests each hold a booking. Each guest cancels independently with probability 0.15. Find the probability that exactly 2 cancel.

**Solution**

This is binomial with $n = 8$, $p = 0.15$, $q = 0.85$, $r = 2$.

$ P = ""^8 C_2 (0.15)^2 (0.85)^6 $

**Piece 1:** $""^8 C_2 = (8 \times 7)/2 = 28$.

**Piece 2:** $(0.15)^2 = 0.0225$.

**Piece 3:** $(0.85)^6$.
$0.85^2 = 0.7225$.
$0.85^3 = 0.7225 \times 0.85 = 0.614125$.
$0.85^6 = (0.85^3)^2 = 0.614125 \times 0.614125 = 0.377150$ (to 6 places).

**Multiply:** $28 \times 0.0225 = 0.63$.
$0.63 \times 0.377150 = 0.237604$.

**➜ Answer: $\approx 0.2376$, that is about 23.8%**

**Example 27** `SCB · pattern`

A credit officer reviews 3 independent loan applications. Each is approved with probability 0.6. Find the probability that at least 2 are approved.

**Solution**

Binomial with $n = 3$, $p = 0.6$, $q = 0.4$.

"At least 2" means exactly 2 or exactly 3.

**Exactly 2:** $""^3 C_2 (0.6)^2 (0.4)^1 = 3 \times 0.36 \times 0.4$.
$3 \times 0.36 = 1.08$. $1.08 \times 0.4 = 0.432$.

**Exactly 3:** $""^3 C_3 (0.6)^3 = 1 \times 0.216 = 0.216$.
($0.6^2 = 0.36$, $0.36 \times 0.6 = 0.216$.)

$P = 0.432 + 0.216 = 0.648$.

**➜ Answer: 0.648**

**Example 28** `GIC · pattern`

A portfolio holds 12 bonds, of which 4 are rated junk. An auditor picks 3 bonds at random. Find the probability that at least one junk bond is picked.

**Solution**

Use the complement.

Total ways to pick 3 of 12: $""^12 C_3 = (12 \times 11 \times 10)/6 = 1320/6 = 220$.

No junk bond means all 3 come from the 8 good bonds:
$""^8 C_3 = (8 \times 7 \times 6)/6 = 336/6 = 56$.

$P("no junk") = 56/220 = 14/55$.

$P("at least one junk") = 1 - 14/55 = 41/55$.

$41 \div 55 = 0.7454dots \approx 0.745$.

**➜ Answer: $41/55 \approx 0.745$**

**Example 29** `LINE MAN · pattern`

A rider has 4 deliveries in a shift. Each is late independently with probability 0.2.
(a) Find the expected number of late deliveries.
(b) Find $P("at least one is late")$.

**Solution**

(a) Binomial mean $= n p = 4 \times 0.2 = 0.8$ deliveries.

(b) $P("one delivery not late") = 1 - 0.2 = 0.8$.

$P("none late") = 0.8^4$.
$0.8^2 = 0.64$. $0.8^4 = 0.64 \times 0.64 = 0.4096$.

$P("at least one late") = 1 - 0.4096 = 0.5904$.

**➜ Answer: (a) 0.8   (b) 0.5904**

**Example 30** `Razer · pattern`

Each loot box contains a rare skin with probability $1/8$, independently of the others. A player keeps opening boxes until the first rare skin appears.
(a) Find the expected number of boxes he must open.
(b) Find $P("the first rare skin is in the 3rd box")$.

**Solution**

(a) Waiting for a first success with $p = 1/8$:
$E = 1/p = 1 \div 1/8 = 8$ boxes.

(b) Box 1 fails, box 2 fails, box 3 succeeds. They are independent, so multiply:

$7/8 \times 7/8 \times 1/8 = 49/512$.

$49 \div 512 = 0.0957$.

**➜ Answer: (a) 8 boxes   (b) $49/512 \approx 0.0957$**

#### Practice — Tier 2 — Singapore & Thailand *(target: 100 s/Q)*

+ Machine A makes 60% of the parts with a 3% defect rate; machine B makes 40% with a 6% defect rate. Find $P("a random part is defective")$.
+ Using the data of Q1, a part is found defective. Find $P("it came from A")$.
+ Two cards are drawn from a deck without replacement. Given that the first was a king, find $P("the second is also a king")$.
+ A roll of 5 coupons contains exactly 2 winning coupons. Two coupons are drawn together. Find $P("both are winners")$.
+ A game costs Rs.~12 to play. You roll a fair die and are paid Rs.~60 if a 6 appears, nothing otherwise. Find the expected profit per game.
+ A fair coin is tossed 6 times. Find $P("exactly 4 heads")$.
+ $P(A) = 0.3$ and $P(B \mid A) = 0.5$. Find $P(A inter B)$.
+ A lot of 10 bulbs contains 3 defective ones. Two bulbs are drawn together. Find $P("exactly one is defective")$.
+ A rider makes 5 deliveries, each late independently with probability 0.1. Find $P("at most one is late")$.
+ Find the expected value of one roll of a fair die.
+ A test has 4 multiple-choice questions with 4 options each. A student guesses every answer. Find $P("exactly 2 correct")$.
+ Box A holds 3 red and 2 white balls; box B holds 2 red and 4 white balls. A box is chosen at random, then one ball is drawn from it. Find $P("the ball is red")$.

<details>
<summary><b>Answer key</b></summary>

**1.** 0.042 — $0.6 \times 0.03 = 0.018$ and $0.4 \times 0.06 = 0.024$; add.   

**2.** $3/7 \approx 0.4286$ — $0.018 / 0.042$. Answering 0.6 means you reported the prior instead of the posterior.   

**3.** $1/17$ — 3 kings remain among 51 cards: $3/51$.   

**4.** $1/10$ — $""^2 C_2 / ""^5 C_2 = 1/10$.   

**5.** $-$Rs.~2 — expected payout $= 60 \times 1/6 = 10$; profit $= 10 - 12 = -2$, so an expected loss of Rs.~2 per game.   

**6.** $15/64$ — $""^6 C_4 / 2^6 = 15/64$.   

**7.** 0.15 — $P(A) \times P(B \mid A) = 0.3 \times 0.5$.   

**8.** $7/15$ — $""^3 C_1 \times ""^7 C_1 / ""^10 C_2 = 21/45$.   

**9.** 0.91854 — none late $= 0.9^5 = 0.59049$; exactly one $= 5 \times 0.1 \times 0.9^4 = 5 \times 0.1 \times 0.6561 = 0.32805$; add.   

**10.** 3.5 — $(1+2+3+4+5+6)/6 = 21/6$.   

**11.** $27/128 \approx 0.211$ — $""^4 C_2 (1/4)^2 (3/4)^2 = 6 \times 1/16 \times 9/16 = 54/256$.   

**12.** $7/15$ — $1/2 \times 3/5 + 1/2 \times 2/6 = 3/10 + 1/6 = 9/30 + 5/30 = 14/30$. The boxes hold different totals, so you cannot pool the balls.

## Tier 3 — Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 31** `Goldman Sachs · pattern`

A disease affects 0.5% of a population. A screening test detects the disease in 99% of people who have it, and wrongly reports positive for 4% of people who do not. A randomly chosen person tests positive. Find the probability that the person actually has the disease.

**Solution**

**Insight: with a rare disease, the false positives come from a huge healthy group, so they can easily outnumber the true positives. The base rate decides the answer, not the 99%.**

Let $D$ = has disease, $T$ = tests positive.

$P(D) = 0.005$, so $P("no" D) = 0.995$.
$P(T \mid D) = 0.99$, $P(T \mid "no" D) = 0.04$.

**True positives:** $0.005 \times 0.99 = 0.00495$.

**False positives:** $0.995 \times 0.04 = 0.0398$.

**All positives:** $P(T) = 0.00495 + 0.0398 = 0.04475$.

$ P(D \mid T) = 0.00495/0.04475 $

Multiply top and bottom by 100000: $495/4475$. Divide both by 5: $99/895$.

$99 \div 895 = 0.11061dots \approx 0.1106$.

Sanity check with 100,000 people: 500 have the disease and 495 of them test positive; 99,500 are healthy and 3,980 of them test positive. Total positives $= 495 + 3980 = 4475$, of which 495 are true. $495/4475 = 0.1106$. Matches.

**➜ Answer: $\approx 11.1%$**

---
⚠️ **TRAP**

The "99% accurate test" instinct says 99%. The correct answer is about 11%. Whenever a condition is rare, always run the 100,000-people table — it converts the whole problem into two integers and removes all doubt.

**Example 32** `Google · pattern`

5 people are picked at random. Assume all 12 birth months are equally likely and independent. Find the probability that at least two of them share a birth month.

**Solution**

**Insight: "at least two share" has too many cases. Its opposite — "all five are different" — is a single falling product.**

Total equally likely outcomes: each person has 12 possible months.
$12^5$.
$12^2 = 144$, $12^3 = 1728$, $12^4 = 20736$, $12^5 = 248832$.

All different: person 1 has 12 free choices, person 2 must avoid 1 month (11 left), and so on.
$12 \times 11 \times 10 \times 9 \times 8$.

$12 \times 11 = 132$. $132 \times 10 = 1320$. $1320 \times 9 = 11880$. $11880 \times 8 = 95040$.

$ P("all different") = 95040/248832 = 0.381944dots $

$ P("at least two share") = 1 - 0.381944 = 0.618056 $

**➜ Answer: $\approx 0.618$, that is about 61.8%**

**Example 33** `Amazon · pattern`

5 letters are placed at random into 5 addressed envelopes, one letter per envelope. Find the expected number of letters that land in the correct envelope.

**Solution**

**Insight: do not find the whole distribution. Define one indicator per letter and add the expectations — linearity of expectation does not care that the events are tangled together.**

Let $X_i = 1$ if letter $i$ is in its own envelope, and $0$ otherwise.
The total number of correct letters is $X = X_1 + X_2 + X_3 + X_4 + X_5$.

For a single letter $i$: by symmetry it is equally likely to land in any of the 5 envelopes.
$ P(X_i = 1) = 1/5 \quad arrow.r \quad E[X_i] = 1 \times 1/5 + 0 \times 4/5 = 1/5 $

By linearity:
$ E[X] = E[X_1] + \dots.c + E[X_5] = 5 \times 1/5 = 1 $

Note how little we needed: the $X_i$ are strongly dependent (if 4 letters are correct the 5th must be too), and linearity still holds.

Check against the exact distribution. Out of $5! = 120$ arrangements, the number with exactly $k$ correct is $""^5 C_k D_(5-k)$, using $D_0=1, D_1=0, D_2=1, D_3=2, D_4=9, D_5=44$:
#table(columns: 7,
[**$k$ correct**],[0],[1],[2],[3],[4],[5],
[**Arrangements**],[44],[45],[20],[10],[0],[1],
)
$(0 \times 44 + 1 \times 45 + 2 \times 20 + 3 \times 10 + 4 \times 0 + 5 \times 1)/120 = (45 + 40 + 30 + 0 + 5)/120 = 120/120 = 1$. Matches.

**➜ Answer: 1 letter, on average**

---
💡 **SHORTCUT**

**Indicator trick.** To find "the expected number of things that happen", write the count as a sum of 0/1 variables and add the individual probabilities. Independence is never needed. This one idea answers most "expected number of ..." interview questions in two lines.

**Example 34** `D. E. Shaw · pattern`

A fair die is rolled repeatedly until a 6 appears.
(a) Find the expected number of rolls.
(b) You have already rolled 3 times with no 6. Find the expected number of **further** rolls.

**Solution**

**Insight: set up an equation in the answer itself. After one failed roll you are standing exactly where you started — the process has no memory.**

(a) Let $E$ be the expected number of rolls.

Roll once — that costs 1 roll, always.
With probability $1/6$ you get a 6 and stop.
With probability $5/6$ you do not, and you are back at the start, expecting $E$ more rolls.

$ E = 1 + 5/6 E $

$ E - 5/6 E = 1 arrow.r 1/6 E = 1 arrow.r E = 6 $

(b) The die does not remember the 3 failures. The expected number of further rolls is again 6.

(Total expected rolls for such a player is $3 + 6 = 9$, but the **remaining** wait is unchanged at 6.)

**➜ Answer: (a) 6 rolls   (b) 6 more rolls**

**Example 35** `Microsoft · pattern`

Each cereal packet contains one of 3 different toys, equally likely and independent. Find the expected number of packets needed to collect all 3 toys.

**Solution**

**Insight: split the wait into stages. In each stage you are simply waiting for a first success, and Example 34 says that wait is $1/p$.**

**Stage 1 — get any new toy.** The first packet is always new. $p = 3/3 = 1$, expected packets $= 1$.

**Stage 2 — get a toy different from the one you have.** 2 of the 3 toys are new.
$p = 2/3$, expected packets $= 1 \div 2/3 = 3/2$.

**Stage 3 — get the last missing toy.** 1 of the 3 toys is new.
$p = 1/3$, expected packets $= 1 \div 1/3 = 3$.

By linearity the total expectation is the sum of the stage expectations:
$ E = 1 + 3/2 + 3 = 2/2 + 3/2 + 6/2 = 11/2 = 5.5 $

(General form: $E = n(1 + 1/2 + \dots.c + 1/n)$. Here $3(1 + 1/2 + 1/3) = 3 \times 11/6 = 5.5$.)

**➜ Answer: 5.5 packets**

**Example 36** `Uber · pattern`

Two fair dice are rolled. You are told that at least one of them shows a 4. Find the probability that the sum is 7.

**Solution**

**Insight: conditioning is not multiplying by anything. It means throwing away every outcome that does not match the information, and recounting inside what is left.**

**New sample space — outcomes with at least one 4.**
First die is 4: $(4,1), (4,2), (4,3), (4,4), (4,5), (4,6) arrow.r 6$ outcomes.
Second die is 4: $(1,4), (2,4), (3,4), (4,4), (5,4), (6,4) arrow.r 6$ outcomes.
$(4,4)$ was counted twice.

Total $= 6 + 6 - 1 = 11$ outcomes.

**Favourable — sum 7 among these 11.**
$(4,3)$ and $(3,4)$. That is 2 outcomes.

$ P = 2/11 $

**➜ Answer: $2/11$**

---
⚠️ **TRAP**

The answer is **not** $1/6$. Knowing a 4 is present throws away every outcome with no 4 at all — that is $5 \times 5 = 25$ outcomes — leaving $36 - 25 = 11$. The space is reshaped, and 11 is not a multiple of 6. Also note the wording: "at least one shows a 4" gives 11 outcomes, while "the first die shows a 4" gives 6 outcomes and the answer $1/6$. One word changes the denominator.

**Example 37** `Adobe · pattern`

A company prints 1,000 scratch cards. One card wins Rs.~20,000, five cards win Rs.~2,000 each, and fifty cards win Rs.~100 each. The rest win nothing. Each card sells for Rs.~60.
(a) Find the expected prize per card. (b) Find the company's expected profit on the whole print run.

**Solution**

**Insight: the expected prize per card is just the total prize money spread over all cards. No probability table is needed once you see that.**

(a) Total prize money:
$1 \times 20000 = 20000$
$5 \times 2000 = 10000$
$50 \times 100 = 5000$

Total $= 20000 + 10000 + 5000 = 35000$, that is Rs.~35,000.

Expected prize per card $= 35000/1000 = 35$, that is Rs.~35.

(b) Revenue per card is Rs.~60. Expected prize cost per card is Rs.~35.

Expected profit per card $= 60 - 35 = 25$, that is Rs.~25.

Whole run: $1000 \times 25 = 25000$, that is Rs.~25,000.

(Check by totals: revenue $= 1000 \times 60 = 60000$; prizes $= 35000$; profit $= 60000 - 35000 = 25000$. Matches.)

**➜ Answer: (a) Rs.~35   (b) Rs.~25,000**

**Example 38** `Google · pattern`

Priya and Kwan toss a fair coin one after the other, Priya first. The first person to toss a head wins. Find the probability that Priya wins.

**Solution**

**Insight: after two failed tosses the game is identical to the start, but it is Priya's turn again. So write her winning probability in terms of itself.**

Let $p = P("Priya wins")$.

**Toss 1 (Priya).** Head with probability $1/2$ $arrow.r$ she wins immediately.

**Toss 2 (Kwan).** Reached only if Priya missed (probability $1/2$). If Kwan gets a head (probability $1/2$) Priya loses.

If both miss — probability $1/2 \times 1/2 = 1/4$ — the position is exactly the starting position, with Priya to toss. Her chance from there is again $p$.

$ p = 1/2 + 1/4 p $

$ p - 1/4 p = 1/2 arrow.r 3/4 p = 1/2 arrow.r p = 1/2 \times 4/3 = 2/3 $

Check by series: $p = 1/2 + (1/2)^3 + (1/2)^5 + \dots.c = (1/2)/(1 - 1/4) = (1/2)/(3/4) = 2/3$. Matches.

**➜ Answer: $2/3$**

#### Practice — Tier 3 — Product *(target: 4 min/Q)*

+ A disease affects 1% of a population. A test is positive for 95% of people who have it and for 10% of people who do not. A person tests positive. Find the probability that the person has the disease.
+ 4 people are picked at random. Assume 12 equally likely birth months. Find the probability that at least two share a birth month.
+ A fair coin is tossed 10 times. Find the expected number of positions $i$ (with $1 lt.eq i lt.eq 9$) at which toss $i$ and toss $i+1$ are both heads.
+ A fair die is rolled until a number greater than 4 appears. Find the expected number of rolls.
+ Each packet holds one of 4 equally likely toys. Find the expected number of packets needed to collect all 4.
+ Two fair dice are rolled and you are told at least one shows a 3. Find $P("the sum is" 8)$.
+ Aarav and Bao roll a fair die alternately, Aarav first. The first to roll a 6 wins. Find $P("Aarav wins")$.
+ 3 cards are drawn from a deck of 52 without replacement. Find the expected number of aces drawn.

<details>
<summary><b>Answer key</b></summary>

**1.** **$\approx 8.76%$.** True positives $= 0.01 \times 0.95 = 0.0095$. False positives $= 0.99 \times 0.10 = 0.099$. All positives $= 0.1085$. Answer $= 0.0095 / 0.1085 = 0.08756$. In 100,000 people: 950 true positives against 9,900 false ones — the healthy group is 99 times larger, so its 10% error rate swamps the test's 95% hit rate.   

**2.** **$\approx 0.4271$.** All different $= (12 \times 11 \times 10 \times 9)/12^4 = 11880/20736 = 0.572917$. Answer $= 1 - 0.572917 = 0.427083$. Note how fast this grows: 5 people already gave 0.618 in Example 32.   

**3.** **2.25.** Use indicators. There are 9 adjacent pairs. For each pair, $P("both heads") = 1/2 \times 1/2 = 1/4$. By linearity $E = 9 \times 1/4 = 9/4 = 2.25$. The pairs overlap and are dependent, which does not matter for expectation.   

**4.** **3 rolls.** "Greater than 4" means 5 or 6, so $p = 2/6 = 1/3$. Waiting for a first success gives $E = 1/p = 3$.   

**5.** **$25/3 \approx 8.33$ packets.** Stage waits are $1$, $4/3$, $4/2 = 2$ and $4/1 = 4$. Sum $= 1 + 4/3 + 2 + 4 = 7 + 4/3 = 25/3$. Equivalently $4(1 + 1/2 + 1/3 + 1/4) = 4 \times 25/12$.   

**6.** **$2/11$.** Outcomes containing at least one 3: $6 + 6 - 1 = 11$. Those summing to 8: $(3,5)$ and $(5,3)$, so 2. Answer $2/11$, not the unconditional $5/36$.   

**7.** **$6/11$.** Let $p$ be Aarav's chance. He wins at once with probability $1/6$; with probability $5/6 \times 5/6 = 25/36$ both miss and the game restarts with him to roll. So $p = 1/6 + (25/36)p arrow.r (11/36)p = 1/6 arrow.r p = 36/66 = 6/11$. Moving first is worth more than half.   

**8.** **$3/13 \approx 0.2308$.** Indicators again: let $X_i = 1$ if the $i$-th card drawn is an ace. By symmetry each drawn card is an ace with probability $4/52 = 1/13$, whatever its position. $E = 3 \times 1/13 = 3/13$. "Without replacement" changes the distribution but not this expectation.

## Mixed set — exam conditions

#### Practice — Tier 1 — Service *(target: 90 s/Q · 30 min total)*

+ A fair die is rolled. Find $P("the number is odd")$.
+ Two fair dice are rolled. Find $P("sum" = 5)$.
+ One card is drawn from a deck. Find $P("an ace or a spade")$.
+ A bag has 3 red and 5 blue balls. Two are drawn together. Find $P("both are the same colour")$.
+ Five fair coins are tossed. Find $P("at least one tail")$.
+ $A$ and $B$ are independent with $P(A) = 0.7$ and $P(B) = 0.4$. Find $P("exactly one of them happens")$.
+ Machine A makes 70% of the output with a 2% defect rate; machine B makes 30% with a 5% defect rate. A defective item is found. Find $P("it came from B")$.
+ A fair die is rolled and you are paid twice the number shown, in rupees. Find the expected payment.
+ 5 independent trials each succeed with probability 0.2. Find $P("exactly one success")$.
+ Find the probability that a leap year contains 53 Mondays.
+ The letters of **LEVEL** are arranged at random. Find $P("the arrangement starts with L")$.
+ A lot of 12 bulbs contains 4 defective ones. Three are drawn together. Find $P("none is defective")$.
+ A fair die is rolled 30 times. Find the expected number of sixes.
+ $P(A) = 0.6$ and $P(B \mid A) = 0.25$. Find $P(A inter B)$.
+ Two fair dice are rolled. Given that the sum is even, find $P("both dice show odd numbers")$.
+ A fair coin is tossed until the first head appears. Find $P("exactly 4 tosses are needed")$.
+ Three friends each choose a day of the week at random. Find $P("all three choose different days")$.
+ A bag has 4 green and 6 yellow balls. One ball is drawn, its colour noted, and it is put back; then another is drawn. Find $P("both are green")$.
+ The odds against an event are $4 : 7$. Find the probability that the event happens.
+ A game costs Rs.~20 to enter. You win Rs.~100 with probability 0.15, and nothing otherwise. Find the expected profit per game.

<details>
<summary><b>Answer key</b></summary>

**1.** $1/2$ — 1, 3, 5 out of 6.   

**2.** $1/9$ — $(1,4),(2,3),(3,2),(4,1) arrow.r 4/36$.   

**3.** $4/13$ — $4 + 13 - 1 = 16$ (the ace of spades is in both); $16/52$.   

**4.** $13/28$ — $[""^3 C_2 + ""^5 C_2] / ""^8 C_2 = (3 + 10)/28$.   

**5.** $31/32$ — $1 - (1/2)^5$.   

**6.** 0.54 — $0.7 \times 0.6 + 0.3 \times 0.4 = 0.42 + 0.12$.   

**7.** $15/29 \approx 0.517$ — products $0.7 \times 0.02 = 0.014$ and $0.3 \times 0.05 = 0.015$; total $0.029$; take $0.015 / 0.029$.   

**8.** Rs.~7 — $E[2X] = 2 E[X] = 2 \times 3.5$.   

**9.** 0.4096 — $""^5 C_1 (0.2)(0.8)^4 = 5 \times 0.2 \times 0.4096 = 1 \times 0.4096$.   

**10.** $2/7$ — 366 days give 2 odd days; Monday appears in 2 of the 7 consecutive-day pairs.   

**11.** $2/5$ — total $= 5!/(2! 2!) = 30$; starting with L leaves E, V, E, L $arrow.r 4!/2! = 12$; $12/30$.   

**12.** $14/55$ — $""^8 C_3 / ""^12 C_3 = 56/220$.   

**13.** 5 — $n p = 30 \times 1/6$.   

**14.** 0.15 — $0.6 \times 0.25$.   

**15.** $1/2$ — sum even means both odd (9 ways) or both even (9 ways), so 18 outcomes; both odd is 9 of them.   

**16.** $1/16$ — three tails then a head: $(1/2)^3 \times 1/2$.   

**17.** $30/49$ — $(7 \times 6 \times 5)/7^3 = 210/343$.   

**18.** $4/25$ — with replacement the draws are independent: $(4/10)^2 = 0.16$.   

**19.** $7/11$ — odds **against** $4:7$ means 4 parts against and 7 parts for, so $P = 7/11$. Answering $4/11$ means you read "against" as "in favour".   

**20.** $-$Rs.~5 — expected winnings $= 100 \times 0.15 = 15$; profit $= 15 - 20 = -5$, an expected loss of Rs.~5.

## 📋 One-page revision card

**THE CORE**
$ P(E) = ("favourable")/("total"), \quad P("not" E) = 1 - P(E) $
Odds in favour $a:b arrow.r a/(a+b)$. Odds against $a:b arrow.r b/(a+b)$.

**THE FOUR RULES**
#table(columns: 2,
[Addition], [$P(A union B) = P(A) + P(B) - P(A inter B)$],
[Multiplication], [$P(A inter B) = P(A) dot P(B \mid A)$],
[Independent], [$P(A inter B) = P(A) dot P(B)$],
[Conditional], [$P(A \mid B) = P(A inter B) / P(B)$],
)

**TOTAL PROBABILITY & BAYES** — build the table, never the formula:
#table(columns: 4,
[**Cause**],[**Prior**],[$P(E \mid "cause")$],[**Product**],
[$B_1$],[$P(B_1)$],[$P(E \mid B_1)$],[multiply],
[$B_2$],[$P(B_2)$],[$P(E \mid B_2)$],[multiply],
[],[],[**Total** $= P(E)$],[add the column],
)
Then $P(B_i \mid E) = ("its product")/("the column total")$.

**EXPECTATION**
- $E[X] = sum x_i p_i$; $E[a X] = a E[X]$
- **Linearity:** $E[X + Y] = E[X] + E[Y]$, dependent or not
- **Indicator trick:** expected count $=$ sum of the individual probabilities
- Waiting for a first success: $E = 1/p$; memoryless
- Collect all $n$ coupons: $E = n(1 + 1/2 + \dots.c + 1/n)$

**BINOMIAL** — $n$ independent trials, success probability $p$:
$ P(r "successes") = ""^n C_r p^r q^(n-r), \quad "mean" = n p, \quad "variance" = n p q $

**STANDARD NUMBERS**
- Two dice: 36 outcomes. Sum ways: 2 and 12 $arrow.r$ 1; 3 and 11 $arrow.r$ 2; 4 and 10 $arrow.r$ 3; 5 and 9 $arrow.r$ 4; 6 and 8 $arrow.r$ 5; 7 $arrow.r$ 6. Doublets: 6.
- Deck: 52 cards, 13 per suit, 4 aces, 12 face cards, 6 red face cards.
- $n$ coins: $2^n$ outcomes, exactly $r$ heads in $""^n C_r$ ways.
- 53 of a given weekday: ordinary year $1/7$, leap year $2/7$.

**THE FIVE SHORTCUTS**
+ "At least one" $arrow.r 1 - P("none")$.
+ Drawing several balls at once $arrow.r$ use $""^n C_r$ on top and bottom; the ordering cancels.
+ Bayes $arrow.r$ two-line product table, then divide by the column total.
+ "Expected number of ..." $arrow.r$ indicators plus linearity, in two lines.
+ Repeating games $arrow.r$ write $p$ in terms of itself and solve one equation.

**THE TOP FIVE TRAPS**
+ **Adding overlapping events.** $P(A) + P(B)$ is wrong unless $A$ and $B$ cannot both happen. Subtract $P(A inter B)$.
+ **With vs without replacement.** Without replacement the second denominator drops by one — and the numerator may drop too.
+ **Answering a Bayes question with the prior.** Evidence changes the probability; a small high-risk group can dominate the positives.
+ **Conditioning by multiplying.** $P(A \mid B)$ means shrinking the sample space to $B$ and recounting inside it. "At least one die shows a 4" gives 11 outcomes, not 6, not 12.
+ **Mixing up odds and probability.** Odds $a:b$ means $a$ parts to $b$ parts, so the probability has denominator $a+b$, not $b$.

</details>

</details>

</details>

</details>
