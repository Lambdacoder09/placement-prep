# Chapter 24 — Full-Length Mock Papers

*Five timed papers. Five different enemies.*

## What you need to know

**WHAT YOU NEED TO KNOW**

**The five papers in this chapter.**

#table(columns: (auto, 1fr, auto, auto),
  [**Paper**], [**Profile**], [**Questions**], [**Time**],
  [1], [Service company, speed-first (TCS NQT pattern)],   [15], [18 min],
  [2], [Service company, reasoning-heavy (Accenture pattern)], [15], [20 min],
  [3], [SE-Asia business analytics (Grab / Shopee / DBS pattern)], [12], [25 min],
  [4], [Product company, insight-first (Google / Amazon pattern)], [8],  [35 min],
  [5], [Mixed final, all tiers shuffled], [20], [30 min],
)

**Exam arithmetic you must be able to do in your head.**
- Seconds per question $=$ (minutes $\times$ 60) $\div$ questions.
- Accuracy $=$ correct $\div$ attempted. Score rate $=$ correct $\div$ total.
- With $+1$ for a correct answer and $-m$ for a wrong one, a guess is worth
  $ p \times 1 - (1 - p) \times m . $
  It pays when $p > m/(1+m)$. So $m = 0.25$ needs $p > 0.2$, and $m = 1/3$ needs
  $p > 0.25$.
- Blind guess on 4 options: $p = 0.25$. On 5 options: $p = 0.20$.
- Marks still needed $=$ target $-$ marks banked. Divide by the marks per question left.

**The three-pass rule.** Pass 1: take every question you can finish in under the average
time. Pass 2: return to the ones you flagged. Pass 3: guess the rest if there is no
negative marking, or only where you eliminated two options if there is.

**High-yield formula recall — the things these papers test again and again.**
#table(columns: (auto, 1fr),
  [Percent change], [net factor $=$ $(1 plus.minus a/100)(1 plus.minus b/100)$],
  [Profit], [$"profit"% = ("SP" - "CP")/"CP" \times 100$; $"SP" = "MP"(1 - d/100)$],
  [SI / CI], [$"SI" = (P r t)/100$; $A = P(1 + r/100)^t$; 2-year gap $= P (r/100)^2$],
  [Speed], [km/h $\times 5/18 =$ m/s; average speed $= "total distance"/"total time"$],
  [Trains], [crossing a pole: own length; a platform: length $+$ platform],
  [Boats], [still $= ("down" + "up")/2$; stream $= ("down" - "up")/2$],
  [Work], [rate $= 1/"days"$; add rates; $M_1 D_1 = M_2 D_2$ for the same job],
  [Averages], [weighted mean $= (n_1 a_1 + n_2 a_2)/(n_1 + n_2)$],
  [Alligation], [cheap : dear $= (d - m) : (m - c)$],
  [Counting], [$n P r = n!/(n-r)!$; $n C r = n!/(r!(n-r)!)$; circle: $(n-1)!$],
  [Probability], [$P = "favourable"/"total"$; $P(A "or" B) = P(A) + P(B) - P(A "and" B)$],
  [Numbers], [unit digit cycles in 4; zeros in $n!$ $=$ $floor(n/5) + floor(n/25) + ...$],
  [Clocks], [angle $= |30 H - 5.5 M|$ degrees; hands meet every $720/11$ minutes],
  [Mensuration], [circle $pi r^2$; cylinder $pi r^2 h$; cone $(pi r^2 h)/3$;
                  sphere $(4 pi r^3)/3$],
)

## Warm-up

### Warm-up

**Example 1**

A paper has 30 questions and 40 minutes. How many seconds per question?

**Solution**

$40$ minutes $= 40 \times 60 = 2400$ seconds.
$2400 \div 30 = 80$ seconds.

**➜ Answer: 80 seconds per question.**

**Example 2**

Marking is $+1$ for correct and $-0.25$ for wrong. You attempt 40 and get 32 right.
What is your score?

**Solution**

Wrong $= 40 - 32 = 8$.
Penalty $= 8 \times 0.25 = 2$.
Score $= 32 - 2 = 30$.

**➜ Answer: 30 marks.**

**Example 3**

With $+1$ and $-0.25$, what accuracy makes guessing worth it?

**Solution**

Expected value of a guess $= p(1) - (1-p)(0.25)$.
Set it above zero: $p - 0.25 + 0.25p > 0 \\Rightarrow 1.25 p > 0.25 \\Rightarrow p > 0.2$.
So you need better than 1 in 5. A blind guess among 4 options gives $p = 0.25$, which
is above 0.2.

**➜ Answer: Guess whenever your chance beats 20%; blind 4-option guessing already does.**

**Example 4**

A section has 25 questions and no negative marking. The cut-off is 60%. How many must be
correct?

**Solution**

$60%$ of $25 = 25 \times 0.6 = 15$.

**➜ Answer: 15 questions.**

**Example 5**

You spent 14 minutes on 10 questions. At that pace, can you finish 35 questions in
45 minutes?

**Solution**

Current pace $= 14 \div 10 = 1.4$ minutes per question.
In seconds that is $1.4 \times 60 = 84$ seconds per question.
At that pace, 35 questions need $35 \times 1.4 = 49$ minutes.
$49 > 45$, so no.
Required pace $= 45 \div 35 = 1.286$ minutes $= 1.286 \times 60 \approx 77$ seconds.

**➜ Answer: No. You must speed up from 84 s to about 77 s per question.**

**Example 6**

Three sections have 20, 15 and 25 questions, with 60 minutes in total. Split the time
so every question gets the same number of seconds.

**Solution**

Total questions $= 20 + 15 + 25 = 60$.
Time per question $= 60 \div 60 = 1$ minute.
So the sections get 20, 15 and 25 minutes.

**➜ Answer: 20 min, 15 min, 25 min.**

**Example 7**

You attempted 45 questions and 36 were correct. What is your accuracy?

**Solution**

Accuracy $= 36/45$. Divide top and bottom by 9: $4/5 = 0.8 = 80%$.

**➜ Answer: 80%.**

**Example 8**

A test is out of 100 marks. You have banked 46 marks from sections A and B. Your target is
70. Section C has 30 one-mark questions. What accuracy do you need in section C?

**Solution**

Marks still needed $= 70 - 46 = 24$.
Accuracy needed $= 24 \div 30 = 0.8 = 80%$.

**➜ Answer: 80% of section C.**

---
💡 **SHORTCUT**

**Do the time arithmetic before question 1, not during question 7.** Write the clock time
at which you must be one-third and two-thirds done in the corner of your sheet. Checking
against a fixed target costs 2 seconds; recomputing your pace mid-paper costs 30.

## Tier 1 — Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

Find the unit digit of $7^103$.

**Solution**

Powers of 7 end in a repeating block of four:
$7^1 = 7$, $7^2 = 49$, $7^3 = 343$, $7^4 = 2401$. So the cycle is 7, 9, 3, 1.
Divide the exponent by 4: $103 = 4 \times 25 + 3$, so the remainder is 3.
Remainder 3 means the third entry of the cycle, which is 3.

**➜ Answer: 3**

Remainder 0 means the **fourth** entry, not the first.

**Example 10** `Accenture pattern`

A price rises by 25% and then falls by 20%. What is the net change?

**Solution**

Take the price as 100.
After the rise: $100 \times 1.25 = 125$.
After the fall: $125 \times 0.80 = 100$.
Net change $= 100 - 100 = 0$.

**➜ Answer: No change (0%).**

---
💡 **SHORTCUT**

**Chain the factors, never add the percents.** A rise of $a%$ then a fall of $b%$ gives the
factor $(1 + a/100)(1 - b/100)$. Memorise the pairs that cancel exactly:
$+25%$ with $-20%$, $+20%$ with $-16 2/3 %$, $+50%$ with $-33 1/3 %$, $+100%$ with $-50%$.

**Example 11** `Infosys pattern`

The ages of Arun and Bala are in the ratio $4 : 5$. After 6 years the ratio becomes
$6 : 7$. Find their present ages.

**Solution**

Let the ages be $4x$ and $5x$.
After 6 years: $(4x + 6)/(5x + 6) = 6/7$.
Cross-multiply: $7(4x + 6) = 6(5x + 6)$.
$28x + 42 = 30x + 36$.
$42 - 36 = 30x - 28x \\Rightarrow 6 = 2x \\Rightarrow x = 3$.
Ages $= 4(3) = 12$ and $5(3) = 15$.
Check: $(12+6) : (15+6) = 18 : 21 = 6 : 7$. Correct.

**➜ Answer: 12 years and 15 years.**

**Example 12** `TCS NQT pattern`

A train 240 m long crosses a 360 m bridge in 30 seconds. Find its speed in km/h.

**Solution**

Distance covered $=$ train length $+$ bridge length $= 240 + 360 = 600$ m.
Speed $= 600 \div 30 = 20$ m/s.
Convert: $20 \times 18/5 = 360/5 = 72$ km/h.

**➜ Answer: 72 km/h**

**Example 13** `Wipro pattern`

A does a job in 15 days and B does it in 10 days. How long do they take together?

**Solution**

Use LCM units. Take the job as $"LCM"(15, 10) = 30$ units.
A's rate $= 30 \div 15 = 2$ units per day.
B's rate $= 30 \div 10 = 3$ units per day.
Together $= 2 + 3 = 5$ units per day.
Time $= 30 \div 5 = 6$ days.

**➜ Answer: 6 days**

---
💡 **SHORTCUT**

**Never use $1/a + 1/b$ under time pressure.** Set the job equal to the LCM of the days,
read off whole-number rates, add, divide. No fractions appear anywhere.

**Example 14** `Capgemini pattern`

Find the difference between the compound interest and the simple interest on Rs.~12,000
at 10% per annum for 2 years.

**Solution**

For exactly 2 years the gap is $P (r/100)^2$.
$= 12000 \times (10/100)^2 = 12000 \times 0.01 = 120$.
Long check: SI $= (12000 \times 10 \times 2)/100 = 2400$.
CI $= 12000(1.1)^2 - 12000 = 12000 \times 1.21 - 12000 = 14520 - 12000 = 2520$.
Difference $= 2520 - 2400 = 120$. Same.

**➜ Answer: Rs.~120**

**Example 15** `Cognizant pattern`

How many distinct arrangements are there of the letters of the word BANANA?

**Solution**

BANANA has 6 letters: A appears 3 times, N appears 2 times, B appears once.
Arrangements $= 6!/(3! \times 2! \times 1!)$.
$6! = 720$. $3! = 6$, $2! = 2$, so the denominator is $6 \times 2 = 12$.
$720 \div 12 = 60$.

**➜ Answer: 60**

**Example 16** `TCS NQT pattern`

Two fair dice are rolled. What is the probability that the sum is 9?

**Solution**

Total outcomes $= 6 \times 6 = 36$.
Sum 9 comes from $(3,6), (4,5), (5,4), (6,3)$ — that is 4 outcomes.
$P = 4/36 = 1/9$.

**➜ Answer: $1/9$**

---
⚠️ **TRAP**

**Dice outcomes are ordered.** $(3,6)$ and $(6,3)$ are two different outcomes, not one.
Students who list only the unordered pairs $\{3,6\}$ and $\{4,5\}$ get $2/36 = 1/18$ and
lose the mark. Count out of 36 always, and write both orders unless the two dice show the
same number.

**Example 17** `Accenture pattern`

Find the next term: 2, 5, 11, 23, 47, ?

**Solution**

Test "double and add 1":
$2 \times 2 + 1 = 5$.   $5 \times 2 + 1 = 11$.   $11 \times 2 + 1 = 23$.
  $23 \times 2 + 1 = 47$.
The rule holds every time, so the next term is $47 \times 2 + 1 = 95$.

**➜ Answer: 95**

**Example 18** `Infosys pattern`

If MANGO is coded as NBOHP, how is APPLE coded?

**Solution**

Compare letter by letter: M$arrow$N, A$arrow$B, N$arrow$O, G$arrow$H, O$arrow$P.
Every letter moves forward by one place.
APPLE: A$arrow$B, P$arrow$Q, P$arrow$Q, L$arrow$M, E$arrow$F.

**➜ Answer: BQQMF**

**Example 19** `TCS NQT pattern`

Pointing at a photograph, Rahul said, "She is the daughter of the only son of my
grandmother." How is she related to Rahul?

**Solution**

Work outwards from the far end.
The only son of Rahul's grandmother is Rahul's father.
The daughter of Rahul's father is Rahul's sister.

**➜ Answer: His sister.**

---
⚠️ **TRAP**

Read relation puzzles **from the inside out**, and do not add people the sentence never
named. "The only son of my grandmother" is the father — but only because Rahul himself is
that son's child. If the speaker were female, the answer would be the same; if the phrase
said "a son", an uncle would also be possible.

**Example 20** `Accenture pattern`

A shop's sales were Rs.~480 lakh in 2022 and Rs.~600 lakh in 2023. Its costs were
Rs.~400 lakh and Rs.~480 lakh. (i) By what percent did sales grow? (ii) Did the profit
margin on sales rise or fall?

**Solution**

(i) Increase $= 600 - 480 = 120$.
Growth $= 120/480 \times 100$. Since $120/480 = 1/4$, growth $= 25%$.

(ii) 2022 profit $= 480 - 400 = 80$; margin $= 80/480 = 1/6 = 16.67%$.
2023 profit $= 600 - 480 = 120$; margin $= 120/600 = 1/5 = 20%$.
$20% > 16.67%$, so the margin rose.

**➜ Answer: (i) 25% growth. (ii) The margin rose, from 16.67% to 20%.**

#### Practice — Tier 1 — Service *(target: PAPER 1 · TCS NQT pattern · 15 questions in 18 minutes)*

Marking: $+1$ correct, $-0.25$ wrong. Sit this in one unbroken block. No calculator.

+ What is the unit digit of $13^47$?
+ If 35% of a number is 168, what is the number?
+ A sum grows to Rs.~8,400 in 4 years at 5% simple interest. Find the principal.
+ The average of five consecutive even numbers is 36. What is the largest of them?
+ A shopkeeper buys an article for Rs.~250, marks it 40% above cost and sells it at a
  10% discount. Find his profit percent.
+ Two pipes fill a tank in 12 minutes and 18 minutes. How long do they take together?
+ A boat covers 24 km downstream in 2 hours and returns in 3 hours. Find its speed in
  still water.
+ In how many ways can 3 boys and 2 girls sit in a row so that the two girls are always
  together?
+ Find the HCF of 84 and 126.
+ Find the next term: 5, 11, 23, 47, ?
+ If $A : B = 2 : 3$ and $B : C = 4 : 5$, find $A : C$.
+ A can finish a job in 20 days and B in 30 days. They work together for 6 days. What
  fraction of the job is left?
+ In a code, TIGER is written as UJHFS. How is LION written?
+ A man walks 5 km north, turns right and walks 12 km. How far is he from his starting
  point?
+ A town's population rises 10% in one year and falls 10% the next. It is now 99,000.
  What was it at the start?

<details>
<summary><b>Answer key</b></summary>

+ **7.** Only the unit digit 3 matters. Cycle of 3: 3, 9, 7, 1. $47 = 4 \times 11 + 3$, so
  take the 3rd entry $= 7$.
+ **480.** $0.35 N = 168 \\Rightarrow N = 168 \div 0.35 = 16800 \div 35 = 480$.
+ **Rs.~7,000.** In 4 years SI adds $4 \times 5 = 20%$, so $1.2P = 8400$ and
  $P = 8400 \div 1.2 = 7,000$.
+ **40.** Five consecutive terms have their average in the middle, so the middle number is
  36 and the list is 32, 34, 36, 38, 40.
+ **26%.** MP $= 250 \times 1.4 = 350$. SP $= 350 \times 0.9 = 315$. Profit $= 315 - 250 = 65$.
  $65/250 = 0.26 = 26%$.
+ **7.2 minutes.** Take the tank as $"LCM"(12,18) = 36$ units: rates 3 and 2, total 5 per
  minute, so $36 \div 5 = 7.2$ min.
+ **10 km/h.** Downstream $= 24 \div 2 = 12$; upstream $= 24 \div 3 = 8$;
  still water $= (12 + 8)/2 = 10$.
+ **48.** Tie the girls into one block: 4 items arrange in $4! = 24$ ways, and the girls
  swap inside in $2! = 2$ ways. $24 \times 2 = 48$.
+ **42.** $84 = 2^2 \times 3 \times 7$ and $126 = 2 \times 3^2 \times 7$. Common part
  $= 2 \times 3 \times 7 = 42$.
+ **95.** The rule is "double and add 1": $5 arrow 11 arrow 23 arrow 47 arrow 95$.
+ **8 : 15.** Make B common: $A : B = 8 : 12$ and $B : C = 12 : 15$, so
  $A : B : C = 8 : 12 : 15$ and $A : C = 8 : 15$.
+ **$1/2$.** Combined rate $= 1/20 + 1/30 = 3/60 + 2/60 = 5/60 = 1/12$ per day. In 6 days
  they finish $6/12 = 1/2$, so half is left.
+ **MJPO.** Every letter shifts forward one place: T$arrow$U, I$arrow$J, G$arrow$H,
  E$arrow$F, R$arrow$S. So L$arrow$M, I$arrow$J, O$arrow$P, N$arrow$O.
+ **13 km.** North then right is east, so the two legs are perpendicular:
  $sqrt(5^2 + 12^2) = sqrt(25 + 144) = sqrt(169) = 13$.
+ **1,00,000.** Net factor $= 1.1 \times 0.9 = 0.99$, so $0.99 P = 99000$ and
  $P = 99000 \div 0.99 = 100,000$.

**Paper 1 scoring.** 13–15 correct: strong, you will clear any service-company cut-off.
10–12: safe, but your speed is the thing to train. 7–9: you know the topics and lose
marks to arithmetic slips — redo every wrong one without looking at the key. Below 7:
go back to the chapter of each topic you missed before sitting Paper 2.

#### Practice — Tier 1 — Service *(target: PAPER 2 · Accenture pattern · 15 questions in 20 minutes)*

Marking: $+1$ correct, no negative marking. Reasoning-heavy.

+ Statements: All pens are tools. Some tools are sharp.   Conclusions:
  I. Some pens are sharp.   II. Some tools are pens.   Which follows?
+ Find the odd one out: 121, 144, 169, 180, 196.
+ Complete the letter series: B, D, G, K, P, ?
+ A is B's father. B is C's sister. C is D's mother. How is A related to D?
+ One term is wrong: 4, 9, 19, 39, 79, 160, 319. Which one?
+ A student scoring 30% fails by 40 marks. Another scoring 45% gets 35 marks more than the
  pass mark. Find the maximum marks.
+ A and B together earn Rs.~6,000 for a job. A alone could do it in 10 days and B alone in
  15 days. What is A's share?
+ What is the angle between the hands of a clock at 4:20?
+ 1 January 2024 was a Monday. What day was 1 March 2024?
+ 40 litres of a mixture has milk and water in the ratio $3 : 1$. How much water must be
  added to make the ratio $3 : 2$?
+ A bag has 4 red, 5 green and 3 blue balls. One ball is drawn. Find the probability that
  it is not green.
+ Find the value of 15% of 240 $+$ 25% of 160.
+ A cube painted on all faces is cut into 64 identical small cubes. How many small cubes
  have exactly two painted faces?
+ P, Q, R, S, T sit in a row facing you. Q is immediately to the right of P. R is at the
  extreme left end. S sits between T and Q. Who is at the extreme right end?
+ The incomes of A and B are in the ratio $5 : 4$ and their expenditures in the ratio
  $3 : 2$. If each saves Rs.~6,000, find A's income.

<details>
<summary><b>Answer key</b></summary>

+ **Only II.** "All pens are tools" flips to "Some tools are pens", so II follows. The sharp
  part of "tools" may lie entirely outside the pens, so I does not follow.
+ **180.** The others are perfect squares: $11^2, 12^2, 13^2, 14^2$. 180 is not a square.
+ **V.** Positions: B(2), D(4), G(7), K(11), P(16) — the gaps are $+2, +3, +4, +5$. The next
  gap is $+6$: $16 + 6 = 22 = $ V.
+ **Grandfather.** B is C's sister, so C is also A's child. C is D's mother, so D is A's
  grandchild and A is D's grandfather.
+ **160.** The rule is "double and add 1": $4, 9, 19, 39, 79$, then $79 \times 2 + 1 = 159$,
  not 160. (And $159 \times 2 + 1 = 319$ confirms it.)
+ **500.** Let the total be $T$. Pass mark $= 0.30T + 40$ and also $= 0.45T - 35$.
  So $0.15T = 75$ and $T = 500$. (Pass mark $= 190$.)
+ **Rs.~3,600.** Wages split as the rates: $1/10 : 1/15 = 3 : 2$. A gets
  $6000 \times 3/5 = 3,600$.
+ **10 degrees.** Angle $= |30 H - 5.5 M| = |30(4) - 5.5(20)| = |120 - 110| = 10$.
+ **Friday.** Days from 1 Jan to 1 Mar $= 31 + 29 = 60$ (2024 is a leap year).
  $60 = 7 \times 8 + 4$, so move 4 days on from Monday: Friday.
+ **10 litres.** Milk $= 40 \times 3/4 = 30$, water $= 10$. Milk does not change, so for
  $3 : 2$ the water must be $30 \times 2/3 = 20$. Add $20 - 10 = 10$ litres.
+ **$7/12$.** Total $= 4 + 5 + 3 = 12$; not green $= 4 + 3 = 7$.
+ **76.** $0.15 \times 240 = 36$ and $0.25 \times 160 = 40$; $36 + 40 = 76$.
+ **24.** $64 = 4^3$, so the cube is $4 \times 4 \times 4$. Exactly two faces are painted on
  the edge cubes that are not corners: 12 edges $\times (4 - 2) = 12 \times 2 = 24$.
+ **T.** "S between T and Q" means the block is T, S, Q or Q, S, T. The order T, S, Q is
  impossible: it puts S immediately left of Q, but that seat belongs to P. So the block is
  Q, S, T, and with P immediately left of Q it grows to P, Q, S, T. R takes the extreme
  left seat, so the row is R, P, Q, S, T and T is on the extreme right.
+ **Rs.~15,000.** Incomes $5x, 4x$; expenditures $3y, 2y$. Then $5x - 3y = 6000$ and
  $4x - 2y = 6000$. The second gives $2x - y = 3000$, so $y = 2x - 3000$. Substituting:
  $5x - 6x + 9000 = 6000 \\Rightarrow x = 3000$. A's income $= 5(3000) = 15,000$.

**Paper 2 scoring.** There is no negative marking, so an unattempted question is a
pure loss — mark something on all 15. 12–15: interview-ready on reasoning. 9–11: solid;
drill clocks, calendars and seating. 6–8: your quant is carrying you and your reasoning
is not — chapters 13 to 20. Below 6: rebuild from chapter 17 (syllogisms) upward.

## Tier 2 — Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 21** `Grab · pattern`

A ride costs a base fare of S$3.20 plus S$0.85 per km. During surge, the whole fare is
multiplied by 1.4. What does a 12 km surge ride cost?

**Solution**

Distance charge $= 12 \times 0.85$.
$12 \times 0.85 = 12 \times 85 \div 100 = 1020 \div 100 = 10.20$.
Normal fare $= 3.20 + 10.20 = 13.40$.
Surge fare $= 13.40 \times 1.4 = 13.40 + 13.40 \times 0.4 = 13.40 + 5.36 = 18.76$.

**➜ Answer: S$18.76**

**Example 22** `Shopee · pattern`

A seller lists an item at S$45. The platform takes a 6% commission and a 2% payment fee,
both on the selling price. The seller also pays S$3 of shipping. The item cost the seller
S$28. What is the profit, and what is the margin on cost?

**Solution**

Total percentage fees $= 6% + 2% = 8%$ of 45.
$8%$ of $45 = 45 \times 0.08 = 3.60$.
Net receipt $= 45 - 3.60 - 3.00 = 38.40$.
Profit $= 38.40 - 28 = 10.40$.
Margin on cost $= 10.40/28 \times 100$.
$10.40 \div 28 = 0.3714...$, so about $37.14%$.

**➜ Answer: Profit S$10.40; margin on cost about 37.1%.**

---
⚠️ **TRAP**

**Percentage fees sit on the selling price; the margin sits on the cost.** Mixing the two
bases is the single most common error in marketplace questions. Write the base next to
every percent before you multiply.

**Example 23** `DBS · pattern`

A deposit of S$20,000 earns 3% per annum, compounded annually, for 3 years. What is the
final amount?

**Solution**

$A = 20000 \times (1.03)^3$.
$(1.03)^2 = 1.03 \times 1.03 = 1.0609$.
$(1.03)^3 = 1.0609 \times 1.03 = 1.0609 + 0.031827 = 1.092727$.
$A = 20000 \times 1.092727 = 21,854.54$.

**➜ Answer: About S$21,854.54**

**Example 24** `Agoda · pattern`

A hotel has 120 rooms. On the five weeknights it runs 85% occupancy at S$180 a room; on
the two weekend nights it runs 100% at S$240 a room. Find the weekly room revenue.

**Solution**

Weeknight rooms sold $= 120 \times 0.85 = 102$.
Weeknight revenue for one night $= 102 \times 180$.
$102 \times 180 = 100 \times 180 + 2 \times 180 = 18000 + 360 = 18,360$.
Five nights $= 18360 \times 5 = 91,800$.
Weekend revenue for one night $= 120 \times 240 = 28,800$.
Two nights $= 28800 \times 2 = 57,600$.
Total $= 91800 + 57600 = 149,400$.

**➜ Answer: S$149,400**

**Example 25** `SCB · pattern`

A trader converts S$10,000 into baht at 26.4, invests it in Thailand for 6 months at 2.5%
per annum simple interest, then converts back at 26.9. What is the gain or loss in
Singapore dollars?

**Solution**

Baht received $= 10000 \times 26.4 = 264,000$.
Interest for 6 months $= 264000 \times 2.5/100 \times 1/2$.
$264000 \times 0.025 = 6,600$ for a full year, so half a year gives $6600 \div 2 = 3,300$.
Total baht $= 264000 + 3300 = 267,300$.
Convert back: $267300 \div 26.9$.
$26.9 \times 9,900 = 266,310$. Remainder $= 267300 - 266310 = 990$.
$990 \div 26.9 = 36.8$.
So he gets back $9900 + 36.8 = $ S$9,936.80.
Change $= 9936.80 - 10000 = -63.20$.

**➜ Answer: A loss of about S$63.20.**

He earned 1.25% of interest but paid about 1.86% in exchange rate movement
($26.9$ baht per dollar buys back less than $26.4$ did). Interest gains can be erased by
the rate.

**Example 26** `Sea/Shopee · pattern`

Each order earns a gross margin of S$4.50. Acquiring a customer costs S$18.
(i) How many orders must one customer place before the company breaks even on them?
(ii) If only 35% of customers ever place a second order (and nobody places a third),
what is the average gross margin per acquired customer?

**Solution**

(i) Break-even orders $= 18 \div 4.50 = 4$.

(ii) Take 100 acquired customers. All 100 place a first order, and $35%$ of them,
that is 35 customers, place a second. Nobody places a third.
Total orders $= 100 + 35 = 135$ from 100 customers.
Average orders per customer $= 135 \div 100 = 1.35$.
Average gross margin $= 1.35 \times 4.50$.
$1.35 \times 4.5 = 1.35 \times 4 + 1.35 \times 0.5 = 5.40 + 0.675 = 6.075$.
Against a cost of 18, the company loses $18 - 6.075 = 11.925$ per customer.

**➜ Answer: (i) 4 orders. (ii) S$6.075 per customer — a loss of about S$11.93 each.**

**Example 27** `LINE MAN · pattern`

A rider averages 18 minutes per delivery. He works a 7-hour shift with a 30-minute break.
How many deliveries does he complete?

**Solution**

Working time $= 7$ hours $- 30$ minutes $= 6.5$ hours $= 6.5 \times 60 = 390$ minutes.
Deliveries $= 390 \div 18 = 21.67$.
He cannot finish a part delivery, so take the whole number below.

**➜ Answer: 21 deliveries.**

---
⚠️ **TRAP**

**Round the way the situation rounds, not the way arithmetic rounds.** Deliveries, buses,
workers and packets round **down**; boxes needed, trips needed and staff required round
**up**. $21.67$ deliveries done is 21; $21.67$ boxes needed is 22.

**Example 28** `GIC · pattern`

A portfolio holds 60% equities, 30% bonds and 10% cash. Over the year equities returned
9%, bonds 4% and cash 1%. What was the portfolio return?

**Solution**

Weighted return $= 0.60(9) + 0.30(4) + 0.10(1)$.
$0.60 \times 9 = 5.4$.
$0.30 \times 4 = 1.2$.
$0.10 \times 1 = 0.1$.
Total $= 5.4 + 1.2 + 0.1 = 6.7$.

**➜ Answer: 6.7%**

**Example 29** `Razer · pattern`

A product sells for S$60 and costs S$34 per unit to make. Fixed costs are S$180,000.
How many units must be sold to break even?

**Solution**

Contribution per unit $= 60 - 34 = 26$.
Units $= 180000 \div 26$.
$26 \times 6,000 = 156,000$. Remainder $= 180000 - 156000 = 24,000$.
$26 \times 900 = 23,400$. Remainder $= 24000 - 23400 = 600$.
$26 \times 23 = 598$. Remainder 2.
So $180000 \div 26 = 6,923.08$ approximately.
You cannot sell part of a unit and you must **cover** the fixed cost, so round up.

**➜ Answer: 6,924 units.**

#### Practice — Tier 2 — Singapore & Thailand *(target: PAPER 3 · SE-Asia pattern · 12 questions in 25 minutes)*

No options. Write the number. Marking: $+2$ correct, no negative marking.

+ A ride costs THB~40 base $+$ THB~6.50 per km $+$ THB~2 per minute. A 9 km trip takes
  22 minutes. What is the fare?
+ A shop's annual revenue rose from S$84,000 to S$113,400. What was the growth percent?
+ An invoice is USD~4,800. The bank quotes 1 USD $=$ 1.35 SGD and adds a 0.8% margin
  against the customer. How many Singapore dollars are payable?
+ A warehouse holds 4,500 items. 8% are damaged. Of the rest, 25% are customer returns
  that cannot be resold. How many items are sellable?
+ Courier A handles 15 parcels per hour and courier B handles 12. Working together, how
  long do they take to clear 216 parcels?
+ A hotel room lists at THB~3,200 a night. A member discount of 15% applies, then a promo
  code takes 10% off, and 7% VAT is added at the end. What is the final price?
+ Six workers finish a task in 5 days. How long would 10 workers take?
+ At a sorting hub each parcel independently goes to lane 1 with probability 0.5, lane 2
  with 0.3 and lane 3 with 0.2. Two parcels arrive. What is the probability they go to the
  same lane?
+ A fleet of 40 cars averages 11 km per litre. Ten new cars average 16 km per litre. What
  is the average of all 50 cars?
+ A subscription costs S$12 monthly or S$120 for a year paid upfront. What percent does
  the annual plan save?
+ A food stall pays THB~30,000 rent a month, spends THB~45 of ingredients per dish and
  sells each dish at THB~120. How many dishes a month does it need to break even?
+ An account grows 2% every quarter. What is the effective annual growth, to two decimal
  places?

<details>
<summary><b>Answer key</b></summary>

+ **THB~142.50.** Distance $= 9 \times 6.5 = 58.50$. Time $= 22 \times 2 = 44$.
  Fare $= 40 + 58.50 + 44 = 142.50$.
+ **35%.** Increase $= 113400 - 84000 = 29,400$.
  $29400/84000 = 0.35$, so 35%.
+ **S$6,531.84.** $4800 times 1.35 = 6,480$. Margin against the customer means he pays
  0.8% more: $6480 times 1.008 = 6480 + 51.84 = 6,531.84$.
+ **3,105.** Damaged $= 4500 times 0.08 = 360$, leaving $4500 - 360 = 4,140$. Returns
  $= 4140 times 0.25 = 1,035$. Sellable $= 4140 - 1035 = 3,105$.
+ **8 hours.** Combined rate $= 15 + 12 = 27$ parcels per hour; $216 div 27 = 8$.
+ **THB~2,619.36.** $3200 times 0.85 = 2,720$. $2720 times 0.90 = 2,448$.
  $2448 times 1.07 = 2448 + 171.36 = 2,619.36$.
+ **3 days.** The job is $6 times 5 = 30$ worker-days; $30 div 10 = 3$.
+ **0.38.** Same lane $= 0.5^2 + 0.3^2 + 0.2^2 = 0.25 + 0.09 + 0.04 = 0.38$.
+ **12 km per litre.** This is a weighted average of the **rates as given**:
  $(40 times 11 + 10 times 16)/50 = (440 + 160)/50 = 600/50 = 12$.
+ **16.67%.** Monthly for a year $= 12 times 12 = 144$. Saving $= 144 - 120 = 24$.
  $24/144 = 1/6 = 16.67%$.
+ **400 dishes.** Contribution $= 120 - 45 = 75$ per dish; $30000 div 75 = 400$.
+ **8.24%.** $(1.02)^2 = 1.0404$; $(1.0404)^2 = 1.08243216$. So the growth is
  $8.243...% approx 8.24%$.

**Paper 3 scoring, out of 24.** 20–24: you are ready for a Grab or Shopee analytics
screen. 14–19: the method is there and the decimals are not — redo every question writing
each multiplication on its own line. Below 14: you are losing marks on multi-step chains,
not on topics. Practise chaining factors (chapter 2) and weighted averages (chapter 4).

## Tier 3 — Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 30** `Google · pattern`

How many four-digit numbers have all four digits different?

**Solution**

*Insight: fill the most restricted position first. The leading digit is the restricted one,
because 0 is banned there.*

First digit: 1 to 9, so 9 choices.
Second digit: any of the 10 digits except the one already used — 9 choices (0 is allowed
here).
Third digit: 8 choices remain.
Fourth digit: 7 choices remain.
Total $= 9 \times 9 \times 8 \times 7$.
$9 \times 9 = 81$. $81 \times 8 = 648$. $648 \times 7 = 4,536$.

**➜ Answer: 4,536**

**Example 31** `Amazon · pattern`

You roll a fair die. You may keep the number shown, or reroll once and must keep the
second roll. Playing best, what is your expected score?

**Solution**

*Insight: reroll exactly when the number in front of you is below the value of a fresh
roll. A fresh roll is worth $3.5$, so keep 4, 5, 6 and reroll 1, 2, 3.*

A fresh roll has expectation $(1+2+3+4+5+6)/6 = 21/6 = 3.5$.
Case A — the first roll is 4, 5 or 6 (probability $3/6 = 1/2$). You keep it, and its
average value is $(4+5+6)/3 = 15/3 = 5$.
Case B — the first roll is 1, 2 or 3 (probability $1/2$). You reroll, and the reroll is
worth 3.5.
Expected score $= 1/2 \times 5 + 1/2 \times 3.5 = 2.5 + 1.75 = 4.25$.

**➜ Answer: 4.25**

Check the rule itself: keeping a 3 would give 3, rerolling gives 3.5, so rerolling
a 3 is right. Keeping a 4 gives 4, better than 3.5, so keeping is right. The cut is
exactly where the insight said.

**Example 32** `Goldman Sachs · pattern`

At a meetup of 25 people, can every person shake hands with exactly 3 others?

**Solution**

*Insight: every handshake adds 1 to two people's counts, so the total of all counts is
always even — it is twice the number of handshakes.*

If each of the 25 people shakes exactly 3 hands, the total of the counts is
$25 \times 3 = 75$.
But that total must equal $2 \times ("number of handshakes")$, which is even.
$75$ is odd, so no such arrangement exists.

**➜ Answer: No. 75 is odd, and the sum of handshake counts must be even.**

---
💡 **SHORTCUT**

**The handshake parity rule.** In any group, the number of people who shake an odd number
of hands is itself even. Whenever a puzzle asks "can every one of $n$ people do exactly
$k$...", check whether $n k$ is even first. It settles many questions in five seconds.

**Example 33** `Microsoft · pattern`

What is the highest power of 12 that divides $100!$?

**Solution**

*Insight: $12 = 2^2 \times 3$, so count the 2s and the 3s in $100!$ separately, then see how
many complete bundles of (two 2s and one 3) you can build.*

Count the 2s with repeated division:
$floor(100/2) = 50$, $floor(100/4) = 25$, $floor(100/8) = 12$, $floor(100/16) = 6$,
$floor(100/32) = 3$, $floor(100/64) = 1$, and $128 > 100$ stops it.
Total 2s $= 50 + 25 + 12 + 6 + 3 + 1 = 97$.

Count the 3s:
$floor(100/3) = 33$, $floor(100/9) = 11$, $floor(100/27) = 3$, $floor(100/81) = 1$,
and $243 > 100$ stops it.
Total 3s $= 33 + 11 + 3 + 1 = 48$.

Each 12 needs two 2s, so the 2s allow $floor(97/2) = 48$ of them.
Each 12 needs one 3, so the 3s allow $48$ of them.
The smaller limit wins: $min(48, 48) = 48$.

**➜ Answer: $12^48$**

**Example 34** `D. E. Shaw · pattern`

Five people are in a room. Assuming birth months are equally likely and independent, what
is the probability that at least two share a birth month?

**Solution**

*Insight: "at least two share" is hard to count directly. Count the opposite — all
different — and subtract from 1.*

Total possibilities $= 12^5$.
$12^2 = 144$, $12^3 = 1728$, $12^4 = 20736$, $12^5 = 248,832$.

All different: the first person has 12 choices, the second 11, then 10, 9, 8.
$12 \times 11 = 132$. $132 \times 10 = 1320$. $1320 \times 9 = 11,880$.
$11880 \times 8 = 95,040$.

$P("all different") = 95040/248832$.
Divide both by 48: $95040 \div 48 = 1980$ and $248832 \div 48 = 5184$, so $1980/5184$.
Divide both by 12: $165/432$. Divide both by 3: $55/144 = 0.3819$.

$P("at least two share") = 1 - 0.3819 = 0.6181$.

**➜ Answer: $89/144$, about 61.8%.**

Check the fraction: $1 - 55/144 = 89/144 = 0.6181$. Correct.

**Example 35** `Uber · pattern`

A driver is paid S$28 for every hour of his shift. Across the shift, 70% of his time is
spent carrying passengers at an average 25 km/h and 30% is spent driving empty at
20 km/h. Running the car costs S$0.35 per km. What is his net pay per hour?

**Solution**

*Insight: pay is per hour but cost is per km, so convert the hour into kilometres before
comparing anything.*

Take one hour of the shift.
Carrying: $0.7$ hours at 25 km/h $= 0.7 \times 25 = 17.5$ km.
Empty: $0.3$ hours at 20 km/h $= 0.3 \times 20 = 6$ km.
Total distance per hour $= 17.5 + 6 = 23.5$ km.
Running cost $= 23.5 \times 0.35$.
$23.5 \times 0.35 = 23.5 \times 35 \div 100 = 822.5 \div 100 = 8.225$.
Net $= 28 - 8.225 = 19.775$.

**➜ Answer: About S$19.78 per hour.**

Notice how much the 30% empty time costs him: it adds 6 km, that is S$2.10 an hour,
with no fare attached. Cutting empty time is worth more than raising the fare.

**Example 36** `Adobe · pattern`

A drawer holds socks of 4 colours, plenty of each. How many socks must you pull out in the
dark to be **sure** of getting 3 of one colour?

**Solution**

*Insight: "be sure" means beat the worst possible luck. Build the unluckiest draw that
still fails, then add one.*

The unluckiest run that still has no colour appearing 3 times is 2 socks of each colour:
$2 \times 4 = 8$ socks.
At 8 socks it is still possible to have failed.
The next sock must match one of the four colours, making a third of that colour.
So $8 + 1 = 9$.

**➜ Answer: 9 socks.**

The general rule: to guarantee $k$ of one kind from $c$ kinds, take
$c(k-1) + 1$. Here $4(3-1) + 1 = 9$.

#### Practice — Tier 3 — Product *(target: PAPER 4 · product-company pattern · 8 questions in 35 minutes)*

Show your reasoning. Marking: $+3$ correct, $+1$ for a correct method with an arithmetic
slip, no negative marking.

+ How many integers from 1 to 1000 inclusive are divisible by neither 3 nor 5?
+ A fair coin is tossed until two heads appear in a row. What is the expected number of
  tosses?
+ Eight people sit at random around a round table. What is the probability that two
  particular people sit next to each other?
+ The numbers 1 to 50 are written on a board. Repeatedly, two numbers are erased and their
  positive difference is written back. This continues until one number is left. Can that
  last number be 0?
+ Thirty items in a shop have an average price of Rs.~400, and no item costs less than
  Rs.~250. What is the highest price the costliest item can possibly have?
+ In how many ways can 10 identical chocolates be given to 4 children so that each child
  gets at least one?
+ A city has 6 million people. Suppose 20% of them ever use taxis, and those who do average
  0.3 taxi rides a day. If one taxi completes 20 rides a day, estimate the fleet size the
  city needs.
+ A screening test flags 98% of people who have a condition and wrongly flags 5% of people
  who do not. 1% of the population has the condition. A random person tests positive. What
  is the chance they actually have it?

<details>
<summary><b>Answer key</b></summary>

+ **533.** Divisible by 3: $floor(1000/3) = 333$. By 5: $floor(1000/5) = 200$. By both,
  i.e. by 15: $floor(1000/15) = 66$. By 3 or 5 $= 333 + 200 - 66 = 467$.
  Neither $= 1000 - 467 = 533$.
+ **6 tosses.** Let $E_0$ be the expectation from a fresh start and $E_1$ the expectation
  when the last toss was a head. $E_1 = 1 + 1/2 (0) + 1/2 E_0$ and
  $E_0 = 1 + 1/2 E_1 + 1/2 E_0$. From the second, $1/2 E_0 = 1 + 1/2 E_1$, so
  $E_0 = 2 + E_1$. Substituting into the first: $E_1 = 1 + 1/2 (2 + E_1)$, so
  $E_1 = 2 + 1/2 E_1$, giving $E_1 = 4$ and $E_0 = 6$.
+ **$2/7$.** Seat the first of the pair anywhere. The second person is equally likely to
  take any of the remaining 7 seats, and 2 of those 7 are next to the first. So $2/7$.
+ **No.** Replacing $a$ and $b$ by $|a - b|$ changes the total by $a + b - |a-b|$, which is
  $2 \times min(a,b)$ — always even. So the parity of the total never changes. The starting
  total is $1 + 2 + ... + 50 = (50)(51)/2 = 1275$, which is odd. The final single number
  therefore must be odd, and 0 is even.
+ **Rs.~4,750.** Total $= 30 \times 400 = 12,000$. To push one item as high as possible, hold
  the other 29 at the floor of 250: $29 \times 250 = 7,250$.
  Maximum $= 12000 - 7250 = 4,750$.
+ **84.** Give each child one chocolate first; 6 remain to be split freely among 4 children.
  That is $binom(6 + 4 - 1, 4 - 1) = binom(9,3) = (9 \times 8 \times 7)/(3 \times 2 \times 1)
  = 504/6 = 84$.
+ **About 18,000 taxis.** Taxi users $= 6,000,000 \times 0.20 = 1,200,000$. Rides per day
  $= 1200000 \times 0.3 = 360,000$. Taxis $= 360000 \div 20 = 18,000$. State the assumptions
  out loud — an estimation answer is judged on the chain, not the digits.
+ **About 16.5%.** Out of 10,000 people: 100 have it, and 98 of those test positive. 9,900
  do not have it, and $9900 \times 0.05 = 495$ of those test positive. Total positives
  $= 98 + 495 = 593$. True positives $= 98/593 = 0.1653$, about 16.5%.

---
⚠️ **TRAP**

**A very accurate test on a rare condition still gives mostly false alarms.** The 5% error
rate acts on the huge healthy group, so it produces 495 false positives against only 98
true ones. Always convert the percentages into counts out of 10,000 before judging.

**Paper 4 scoring, out of 24.** 18–24: you can hold your own in a product-company
round. 12–17: your reasoning is sound and your first move is slow — for each question you
missed, write down what the single insight was, in one line. Below 12: do not add speed
yet. Redo Tier 3 of chapters 9, 10 and 20 and come back.

## Mixed set — exam conditions

#### Practice — Tier 1 — Service *(target: PAPER 5 · mixed final · 20 questions in 30 minutes)*

All tiers, shuffled, no labels. Marking: $+1$ correct, $-0.25$ wrong. Sit it once,
without stopping, and mark it strictly.

+ Find 12.5% of 480.
+ A train 180 m long passes a 270 m platform in 25 seconds. Find its speed in km/h.
+ Two numbers have HCF 12 and LCM 180. One of them is 60. Find the other.
+ Find the simple interest on Rs.~15,000 at 8% per annum for 2.5 years.
+ A sells an article to B at a 20% profit, and B sells it to C at a 25% profit. C pays
  Rs.~900. What did A pay for it?
+ Find the next term: 7, 14, 28, 56, ?
+ Find the odd one out: 3, 5, 11, 14, 17, 23.
+ In a code, FLOWER is written as REWOLF. How is GARDEN written?
+ Statements: All doctors are graduates. No graduate is illiterate.   Does
  "No doctor is illiterate" follow?
+ At what time between 3 and 4 o'clock do the hands of a clock coincide?
+ Two cards are drawn from a standard 52-card pack without replacement. What is the
  probability that both are aces?
+ The average of 11 results is 50. The average of the first six is 49 and of the last six
  is 52. Find the sixth result.
+ In what ratio must rice at Rs.~45 per kg be mixed with rice at Rs.~60 per kg to get a
  mixture worth Rs.~50 per kg?
+ Find the area of the largest circle that fits inside a square of side 14 cm.
    (Take $pi = 22/7$.)
+ How many 3-digit numbers can be formed from the digits 1 to 7 if no digit repeats?
+ **Data sufficiency.** Is the integer $n$ divisible by 4?   I: $n$ is divisible by 8.
    II: $n$ is even.   Options: (a) I alone   (b) II alone
    (c) both together   (d) each alone   (e) neither
+ A man walks 10 m south, turns left and walks 10 m, then turns left and walks 10 m. Where
  is he now, and which way is he facing?
+ Twelve men can finish a job in 18 days. After 6 days of work, 6 more men join them. How
  many more days does the job take?
+ A's salary is 25% more than B's. By what percent is B's salary less than A's?
+ Find the remainder when $2^50$ is divided by 7.

<details>
<summary><b>Answer key</b></summary>

+ **60.** $12.5% = 1/8$, and $480 \div 8 = 60$.
+ **64.8 km/h.** Distance $= 180 + 270 = 450$ m in 25 s, so $450 \div 25 = 18$ m/s.
  $18 \times 18/5 = 324/5 = 64.8$ km/h.
+ **36.** For two numbers, HCF $\times$ LCM $=$ their product:
  $12 \times 180 = 2,160$. Other number $= 2160 \div 60 = 36$.
  (Check: HCF(60,36) $= 12$ and LCM $= 180$.)
+ **Rs.~3,000.** $"SI" = (15000 \times 8 \times 2.5)/100 = (15000 \times 20)/100 = 3,000$.
+ **Rs.~600.** The chain factor is $1.20 \times 1.25 = 1.5$, so A's cost
  $= 900 \div 1.5 = 600$. (Check: $600 arrow 720 arrow 900$.)
+ **112.** Each term doubles: $7, 14, 28, 56, 112$.
+ **14.** Every other number is an odd prime; 14 is even and composite.
+ **NEDRAG.** The code simply reverses the word: GARDEN reversed is NEDRAG.
+ **Yes, it follows.** Doctors sit inside graduates, and graduates are entirely outside
  illiterates, so doctors are entirely outside illiterates.
+ **$3 : 16 4/11$.** At 3:00 the minute hand is 90 degrees behind the hour hand. The minute
  hand gains $5.5$ degrees a minute, so it needs $90 \div 5.5 = 180/11 = 16 4/11$ minutes.
+ **$1/221$.** $P = 4/52 \times 3/51 = (1/13) \times (1/17) = 1/221$.
+ **56.** First six total $= 6 \times 49 = 294$. Last six total $= 6 \times 52 = 312$. All
  eleven total $= 11 \times 50 = 550$. The sixth result is counted in both groups, so it is
  $294 + 312 - 550 = 56$.
+ **$2 : 1$.** By alligation, cheap : dear $= (60 - 50) : (50 - 45) = 10 : 5 = 2 : 1$.
+ **154 cm#super[2].** The largest circle has diameter 14, so $r = 7$.
  Area $= 22/7 \times 7 \times 7 = 22 \times 7 = 154$.
+ **210.** $7 \times 6 \times 5 = 210$.
+ **(a).** $n = 8k = 4(2k)$, always a multiple of 4 — a definite yes. Statement II fails,
  because $n = 6$ is even and not a multiple of 4.
+ **10 m east of the start, facing north.** Walking south then turning left faces him east;
  10 m east; turning left again faces him north; 10 m north cancels the 10 m south. Net
  displacement is 10 m east.
+ **8 days.** The job is $12 \times 18 = 216$ man-days. In 6 days, $12 \times 6 = 72$
  man-days are done, leaving $216 - 72 = 144$. With $12 + 6 = 18$ men,
  $144 \div 18 = 8$ days.
+ **20%.** Let B $= 100$, so A $= 125$. B is short of A by 25, and that is measured against
  A: $25/125 = 1/5 = 20%$.
+ **4.** $2^3 = 8$ leaves remainder 1 on division by 7. Write $50 = 3 \times 16 + 2$, so
  $2^50 = (2^3)^16 \times 2^2$, which leaves $1^16 \times 4 = 4$.

**Paper 5 scoring, out of 20 with $-0.25$ per wrong answer.**
#table(columns: (auto, 1fr),
  [**16 and above**], [Placement-ready across all three tiers. Keep sitting timed papers weekly.],
  [**12 to 15.75**], [A good service-company score. Your gap is the last five questions, which are Tier 2 and Tier 3 — work those chapters' Tier 3 sections.],
  [**8 to 11.75**], [You know more than this score shows. Count your wrong answers: if more than 4, you are guessing too loosely for $-0.25$ marking.],
  [**Below 8**], [Stop timing yourself for two weeks. Work untimed until your accuracy is above 85%, then bring the clock back.],
)
Also compute two numbers every time: **accuracy** (correct $\div$ attempted) and **coverage**
(attempted $\div$ 20). Low coverage with high accuracy is a speed problem. High coverage
with low accuracy is a discipline problem. They are fixed in opposite ways.

## 📋 One-page revision card

**THE FIVE PAPERS** — Paper 1 speed (15 Q / 18 min), Paper 2 reasoning (15 Q / 20 min),
Paper 3 business analytics (12 Q / 25 min), Paper 4 insight (8 Q / 35 min),
Paper 5 mixed (20 Q / 30 min).

**EXAM ARITHMETIC**
- Seconds per question $=$ (minutes $\times 60$) $\div$ questions.
- A guess pays when your chance beats $m/(1+m)$: with $-0.25$ that is 20%, with $-1/3$
  it is 25%. With no negative marking, never leave a blank.
- Marks needed $=$ target $-$ banked, then divide by marks per remaining question.
- Accuracy $=$ correct $\div$ attempted. Coverage $=$ attempted $\div$ total. Diagnose with
  both.

**THE THREE-PASS RULE** — Pass 1 take the quick ones, pass 2 the flagged ones, pass 3 guess
what is left under the rule above. Never let one question eat more than triple the average
time.

**FORMULAS THESE PAPERS KEEP ASKING FOR**
#table(columns: (auto, 1fr),
  [Percent chain], [factor $= (1 plus.minus a/100)(1 plus.minus b/100)$; $+25%$ cancels $-20%$],
  [Profit], [$"SP" = "MP"(1-d/100)$; profit% on CP, discount% on MP, fees% on SP],
  [SI / CI], [$"SI" = (P r t)/100$; 2-year CI$-$SI gap $= P(r/100)^2$],
  [Speed], [km/h $\times 5/18 =$ m/s; platform $=$ train length $+$ platform length],
  [Boats], [still $= ("down"+"up")/2$; stream $= ("down"-"up")/2$],
  [Work], [job $=$ LCM of days; add the whole-number rates],
  [Alligation], [cheap : dear $= (d-m):(m-c)$],
  [Counting], [$n C r$; identical items to $k$ people, each $\\ge 1$: $binom(n-1, k-1)$],
  [Probability], [count the complement when the question says "at least"],
  [Clock], [angle $= |30H - 5.5M|$; the hands gain $5.5$ degrees a minute],
  [Numbers], [unit digit cycles in 4; HCF $\times$ LCM $=$ product of the two numbers],
)

**SHORTCUTS**
+ Chain percentage factors; never add percents.
+ Set a job equal to the LCM of the given days so every rate is a whole number.
+ Fill the most restricted slot first in any counting problem.
+ In "at least two share", compute the complement and subtract from 1.
+ Handshake parity: the sum of all counts is even, so $n k$ odd is impossible.
+ Pigeonhole: to guarantee $k$ of one kind out of $c$ kinds, take $c(k-1)+1$.
+ Turn per-hour pay and per-km cost into the same unit before comparing them.

**TOP 5 TRAPS**
+ **Adding percents.** $+25%$ then $-20%$ is not $+5%$; it is zero.
+ **Mixing the base.** Profit is on cost, discount is on marked price, platform fees are on
  selling price. Write the base before you multiply.
+ **Rounding the wrong way.** Deliveries completed round down; units needed to cover a cost
  round up.
+ **Guessing loosely under negative marking.** With $-0.25$, a blind guess is barely
  positive and a guess you feel bad about is negative. Eliminate one option first.
+ **Spending 4 minutes on one Tier 3 question inside a Tier 1 paper.** The marks are equal.
  Flag it and move.

</details>

</details>

</details>

</details>

</details>
