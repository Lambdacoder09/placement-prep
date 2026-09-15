# Chapter 23 — Data Sufficiency

*Decide if you can solve it. Do not solve it.*

## What you need to know

**WHAT YOU NEED TO KNOW**

**The question is never "what is the answer".** The question is "do I have enough to get
**one** answer?" Stop the moment you know that.

**The standard five options (2-statement format).** This book uses them everywhere.

#table(columns: (auto, 1fr),
  [**(a)**], [Statement I alone is sufficient, but statement II alone is not.],
  [**(b)**], [Statement II alone is sufficient, but statement I alone is not.],
  [**(c)**], [Both statements together are sufficient, but neither alone is.],
  [**(d)**], [Each statement alone is sufficient.],
  [**(e)**], [Both together are still not sufficient.],
)

**The 3-statement format (I, II, III).** The question becomes "which combinations are
sufficient?" Typical options: "I and II only", "II and III only", "any two of the three",
"all three are needed", "even all three are not enough". Method is the same: test each
combination separately.

**The AD / BCE grid — the only procedure you need.**
+ Read the question. Write down what a complete answer would look like (a number? a yes
  or a no?).
+ Test statement I **alone**. Cover statement II with your finger.
+ If I works $\\Rightarrow$ the answer is **(a) or (d)**. Now test II alone. II works too $\\Rightarrow$ (d).
  II fails $\\Rightarrow$ (a).
+ If I fails $\\Rightarrow$ the answer is **(b), (c) or (e)**. Test II alone. II works $\\Rightarrow$ (b).
  II fails $\\Rightarrow$ now, and only now, combine them. Works $\\Rightarrow$ (c). Fails $\\Rightarrow$ (e).

**Sufficient means exactly one answer.**
- A value question is settled when the unknown is pinned to **one** number.
- A yes/no question is settled when the answer is **always yes** or **always no**.
  A definite **no** is just as sufficient as a definite yes.
- Two possible values $\\Rightarrow$ not sufficient. $x^2 = 49$ gives $x = 7$ or $x = -7$.

**Counting equations (linear only).**
- $k$ unknowns need $k$ **independent** linear equations for a unique solution.
- $2x + 3y = 12$ and $4x + 6y = 24$ are the **same** equation. That is one equation, not two.
- Non-linear equations break the count: $x y = 12$ and $x + y = 7$ give two answer pairs.

**Things you often do NOT need.**
- For a percentage, ratio or fraction answer, absolute values are usually unnecessary.
- For "is $n$ divisible by $d$", the value of $n$ is unnecessary.
- For a yes/no about an average, the individual items are unnecessary.

**Standing assumptions of the format.**
+ Both statements are **true**. They can never contradict each other. If they seem to,
  you made an arithmetic error.
+ The statements do not have to be independent of each other in meaning, but each one
  must be tested **on its own** first.
+ Unless stated, a "number" may be negative, zero or a fraction.

## Warm-up

### Warm-up

**Example 1**

Find $x$.   I: $x + 3 = 10$.   II: $2x = 14$.

**Solution**

I alone: $x = 10 - 3 = 7$. One value. Sufficient.
II alone: $x = 14 \div 2 = 7$. One value. Sufficient.

**➜ Answer: (d) Each alone is sufficient.**

**Example 2**

Find $x$.   I: $x^2 = 49$.   II: $x > 0$.

**Solution**

I alone: $x = 7$ or $x = -7$. Two values. Not sufficient.
II alone: any positive number. Not sufficient.
Together: $x = 7$ or $-7$, and $x > 0$, so $x = 7$. One value.

**➜ Answer: (c) Both together.**

**Example 3**

Is the integer $n$ even?   I: $n$ is a multiple of 6.   II: $n$ is a multiple of 3.

**Solution**

I alone: $n = 6k = 2(3k)$, always even. Definite **yes**. Sufficient.
II alone: $n = 3$ is odd, $n = 6$ is even. Two different answers. Not sufficient.

**➜ Answer: (a) I alone.**

**Example 4**

Find the area of a rectangle.   I: Its length is 12 cm.   II: Its perimeter is 34 cm.

**Solution**

I alone: breadth unknown. Not sufficient.
II alone: length and breadth both unknown. Not sufficient.
Together: $2(12 + b) = 34 \\Rightarrow 12 + b = 17 \\Rightarrow b = 5$. Area $= 12 \times 5 = 60$ cm#super[2].

**➜ Answer: (c) Both together.**

**Example 5**

Find $x - y$.   I: $x + y = 10$.   II: $3x - 3y = 12$.

**Solution**

I alone: gives the sum, not the difference. $x=6, y=4$ gives 2; $x=9, y=1$ gives 8.
Not sufficient.
II alone: divide by 3. $x - y = 12 \div 3 = 4$. One value. Sufficient.

**➜ Answer: (b) II alone.**

You never found $x$ or $y$. You did not need to.

**Example 6**

Is $x > 5$?   I: $x > 3$.   II: $x$ is an integer.

**Solution**

I alone: $x = 4$ gives no, $x = 9$ gives yes. Not sufficient.
II alone: any integer. Not sufficient.
Together: $x = 4$ (integer, $> 3$) gives no; $x = 9$ gives yes. Still both answers.

**➜ Answer: (e) Not sufficient even together.**

**Example 7**

How old is Ravi?   I: Ravi is 5 years older than Meera.   II: Meera is 18 years old.

**Solution**

I alone: Meera's age unknown. Not sufficient.
II alone: says nothing about Ravi. Not sufficient.
Together: $18 + 5 = 23$ years.

**➜ Answer: (c) Both together.**

**Example 8**

What is the speed of a car?   I: It covers 180 km.   II: It takes 3 hours.

**Solution**

I alone: no time. Not sufficient.
II alone: no distance. Not sufficient.
Together: speed $= 180 \div 3 = 60$ km/h.

**➜ Answer: (c) Both together.**

## Tier 1 — Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

What is the two-digit number $N$?   I: The sum of its digits is 11.
  II: The difference of its digits is 3.

**Solution**

I alone: 29, 38, 47, 56, 65, 74, 83, 92. Eight numbers. Not sufficient.
II alone: 14, 25, 41, 52, 63, ... many. Not sufficient.
Together: digits add to 11 and differ by 3. Let the digits be $a$ and $b$.
$a + b = 11$ and $a - b = 3$ give $2a = 14$, $a = 7$, $b = 4$.
So the digits are 7 and 4. The number is **74 or 47**. Two numbers.

**➜ Answer: (e) Not sufficient even together.**

---
⚠️ **TRAP**

Solving for the **digits** is not the same as solving for the **number**. The order of the
digits is a second unknown. Always ask: have I pinned the exact thing the question named?

**Example 10** `Infosys pattern`

What is the cost of one pen?   I: 5 pens and 3 notebooks cost Rs.~145.
  II: 10 pens and 6 notebooks cost Rs.~290.

**Solution**

Let a pen cost $p$ and a notebook cost $n$.
I: $5p + 3n = 145$. One equation, two unknowns. Not sufficient.
II: $10p + 6n = 290$. Divide both sides by 2: $5p + 3n = 145$. Not sufficient.
Together: statement II **is** statement I. You still have one equation and two unknowns.
Check: $p = 20, n = 15$ gives $100 + 45 = 145$. Also $p = 26, n = 5$ gives
$130 + 15 = 145$. Two different pen prices fit both statements.

**➜ Answer: (e) Not sufficient even together.**

---
⚠️ **TRAP**

**The repeated equation.** When statement II is statement I multiplied by a constant, the
answer is (e), never (c). Test it fast: divide statement II by the factor that makes the
first coefficient match, then compare.

**Example 11** `Accenture pattern`

What simple interest does a sum earn in 2 years?   I: The principal is Rs.~24,000.
  II: The rate is 7.5% per annum.

**Solution**

I alone: no rate. Not sufficient.
II alone: no principal. Not sufficient.
Together: $"SI" = (24000 \times 7.5 \times 2) / 100$.
$24000 \times 7.5 = 180000$. $180000 \times 2 = 360000$. $360000 \div 100 = 3600$.
SI $=$ Rs.~3,600. One value.

**➜ Answer: (c) Both together.**

**Example 12** `TCS NQT pattern`

Is the positive integer $x$ divisible by 12?   I: $x$ is divisible by 4 and by 6.
  II: $x$ is divisible by 24.

**Solution**

I alone: divisible by 4 and by 6 means divisible by their LCM.
$4 = 2^2$, $6 = 2 \times 3$, so LCM $= 2^2 \times 3 = 12$. Definite **yes**. Sufficient.
II alone: $x = 24k = 12(2k)$, always a multiple of 12. Definite **yes**. Sufficient.

**➜ Answer: (d) Each alone is sufficient.**

---
⚠️ **TRAP**

"Divisible by 4 and by 6" gives 12, not 24. Multiply the **LCM**, not the two numbers.
$x = 12$ is divisible by 4 and 6 but not by 24.

**Example 13** `Wipro pattern`

What is Priya's monthly salary?   I: She saves 20% of her salary.
  II: Her total monthly expenses are Rs.~32,000.

**Solution**

I alone: a percentage with no rupee figure. Not sufficient.
II alone: expenses alone say nothing about the salary. Not sufficient.
Together: she saves 20%, so she spends $100 - 20 = 80%$ of her salary.
$80%$ of salary $= 32000$.
Salary $= 32000 \times 100 / 80 = 3200000 / 80 = 40000$. Rs.~40,000.

**➜ Answer: (c) Both together.**

**Example 14** `Capgemini pattern`

What is the area of a square?   I: Its perimeter is 48 cm.
  II: Its diagonal is $12 sqrt(2)$ cm.

**Solution**

I alone: side $= 48 \div 4 = 12$ cm. Area $= 12 \times 12 = 144$ cm#super[2]. Sufficient.
II alone: for a square, diagonal $= "side" \times sqrt(2)$.
So side $= 12 sqrt(2) \div sqrt(2) = 12$ cm. Area $= 144$ cm#super[2]. Sufficient.

**➜ Answer: (d) Each alone is sufficient.**

For a square, **any one** measurement fixes every other one. Side, perimeter,
diagonal, area, inradius — one gives all.

**Example 15** `Cognizant pattern`

What is the length of a train?   I: It crosses a pole in 12 seconds.
  II: Its speed is 54 km/h.

**Solution**

I alone: no speed. Not sufficient.
II alone: no time. Not sufficient.
Together: $54$ km/h $= 54 \times 5/18 = 270/18 = 15$ m/s.
Crossing a pole means covering exactly the train's own length.
Length $= 15 \times 12 = 180$ m.

**➜ Answer: (c) Both together.**

---
💡 **SHORTCUT**

**km/h to m/s: multiply by $5/18$.** m/s to km/h: multiply by $18/5$.
Memorise the ladder: 18 km/h $=$ 5 m/s, 36 $=$ 10, 54 $=$ 15, 72 $=$ 20, 90 $=$ 25.

**Example 16** `TCS NQT pattern`

**Three-statement format.** What is the father's present age?
  I: The father is 4 times as old as his son now.
  II: Five years ago the father was 7 times as old as his son.
  III: The sum of their present ages is 50 years.

**Solution**

Let the son be $s$ and the father be $f$ today.
I: $f = 4s$. II: $f - 5 = 7(s - 5)$. III: $f + s = 50$.

**I and II:** $4s - 5 = 7s - 35 \\Rightarrow 35 - 5 = 7s - 4s \\Rightarrow 30 = 3s \\Rightarrow s = 10$, $f = 40$. Works.

**I and III:** $4s + s = 50 \\Rightarrow 5s = 50 \\Rightarrow s = 10$, $f = 40$. Works.

**II and III:** $f = 50 - s$, so $50 - s - 5 = 7s - 35 \\Rightarrow 45 - s = 7s - 35$
$\\Rightarrow 45 + 35 = 8s \\Rightarrow 80 = 8s \\Rightarrow s = 10$, $f = 40$. Works.

Every pair gives the same answer, 40 years. No single statement works alone: I alone has
two unknowns, II alone has two unknowns, III alone has two unknowns.

**➜ Answer: Any two of the three statements are sufficient.**

**Example 17** `Accenture pattern`

Is the positive integer $p$ a prime number?   I: $p$ lies between 30 and 40.
  II: $p$ is odd and is divisible by neither 3 nor 5.

**Solution**

I alone: 31 is prime, 32 is not. Two answers. Not sufficient.
II alone: 7 is prime, 49 is not (it is $7 \times 7$). Not sufficient.
Together: list 31 to 39 and strike out what II forbids.
- Even: 32, 34, 36, 38 — out.
- Divisible by 3: 33, 39 — out.
- Divisible by 5: 35 — out.
Left: 31 and 37. Both are prime. So the answer is **yes** either way.

**➜ Answer: (c) Both together.**

You never learned which number $p$ is. For a yes/no question you do not have to.

---
💡 **SHORTCUT**

**A yes/no question can be settled without finding the unknown.** Shrink the list of
possibilities until every survivor gives the same yes or the same no. Stop there.

**Example 18** `Infosys pattern`

What is the ratio of boys to girls in a class?   I: There are 18 more boys than girls.
  II: There are 90 students in total.

**Solution**

I alone: 28 boys and 10 girls give $28:10 = 14:5$. 54 boys and 36 girls give $3:2$.
Different ratios. Not sufficient.
II alone: no split given. Not sufficient.
Together: $b + g = 90$ and $b - g = 18$.
Add: $2b = 108 \\Rightarrow b = 54$. Then $g = 90 - 54 = 36$.
Ratio $= 54 : 36 = 3 : 2$ (divide both by 18).

**➜ Answer: (c) Both together.**

**Example 19** `TCS NQT pattern`

What is the shopkeeper's profit percent?   I: He marks his goods 40% above cost and
gives a 25% discount on the marked price.   II: The cost price is Rs.~800.

**Solution**

I alone: take cost $= 100$ (you may, because the answer is a percent).
Marked price $= 140$. Discount $= 25%$ of $140 = 35$.
Selling price $= 140 - 35 = 105$.
Profit $= 105 - 100 = 5$ on a cost of 100, so profit $= 5%$. Sufficient.
II alone: no selling price. Not sufficient.

**➜ Answer: (a) I alone.**

---
💡 **SHORTCUT**

**Percent answers are scale-free.** When the question asks for a percentage or a ratio,
set the base to 100 and work. If statement I fixes every **rate** in the chain, it is
sufficient, and the rupee value in statement II is a decoy.

**Example 20** `Wipro pattern`

What is the remainder when the positive integer $N$ is divided by 5?
  I: $N$ leaves remainder 3 when divided by 15.
  II: $N$ leaves remainder 8 when divided by 10.

**Solution**

I alone: $N = 15k + 3$. Now $15k$ is a multiple of 5, so $N = 5(3k) + 3$ and the
remainder is **3**. Sufficient.
II alone: $N = 10k + 8 = 10k + 5 + 3 = 5(2k + 1) + 3$, so the remainder is again **3**.
Sufficient.
Quick check with a number that fits both: $N = 18$. $18 = 15 + 3$ and $18 = 10 + 8$,
and $18 = 5 \times 3 + 3$. Remainder 3.

**➜ Answer: (d) Each alone is sufficient.**

You never found $N$. Remainder questions rarely need the number itself — only the
part of it that survives the division.

#### Practice — Tier 1 — Service *(target: 60 s/Q)*

Use the five standard options (a)–(e) from the formula box.

+ What is the value of $x$?   I: $3x - 7 = 14$.   II: $x^2 = 49$.
+ What is the perimeter of a rectangle?   I: Its area is 72 cm#super[2].
    II: Its length is twice its breadth and its area is 72 cm#super[2].
+ Is the number $n$ divisible by 9?   I: $n$ is divisible by 3.
    II: The sum of the digits of $n$ is 18.
+ What is the average of five numbers?   I: Their total is 80.
    II: The sum of the first three is 45.
+ What is the speed of a boat in still water?   I: Its downstream speed is 18 km/h.
    II: Its upstream speed is 12 km/h.
+ What is the value of $a$?   I: $a + b = 10$.   II: $2a + 2b = 20$.
+ What is the cost price of an article?   I: Selling it at Rs.~720 gives a 20% profit.
    II: Selling it at Rs.~540 gives a 10% loss.
+ In how many days can A and B finish a job together?   I: A alone takes 12 days.
    II: B alone takes 24 days.
+ Is a four-digit number divisible by 4?   I: Its last two digits form the number 36.
    II: The sum of its digits is 12.
+ What will the population of a town be after 2 years?   I: It is 20,000 today.
    II: It grows at 10% per annum.
+ What is the 10th term of an arithmetic progression?   I: The 4th term is 17 and the
  7th term is 29.   II: The sum of the first three terms is 27.
+ What is the value of the integer $x$?   I: $x$ is a prime number between 10 and 20.
    II: $x$ is odd.
+ Is $x > y$?   I: $x^2 > y^2$.   II: Both $x$ and $y$ are positive.
+ How long does a train take to cross a 200 m platform?   I: The train is 150 m long.
    II: The train travels at 25 m/s.
+ What is the discount percent on an article?   I: Its marked price is Rs.~1,200 and
  it sells for Rs.~960.   II: The discount is Rs.~240.

<details>
<summary><b>Answer key</b></summary>

+ **(a).** I gives $3x = 21$, $x = 7$. II gives $x = 7$ or $-7$ — two values, so it fails.
+ **(b).** II: $2b^2 = 72 \\Rightarrow b^2 = 36 \\Rightarrow b = 6$, $l = 12$, perimeter $= 2(12+6) = 36$ cm.
  I fixes only the product $l b = 72$, and $12 \times 6$ (perimeter 36) and
  $9 \times 8$ (perimeter 34) both fit.
+ **(b).** Digit sum 18 is a multiple of 9, so $n$ is. I only gives a multiple of 3, and
  $n = 12$ is not a multiple of 9.
+ **(a).** $80 \div 5 = 16$. II leaves the last two numbers unknown.
+ **(c).** Still water speed $= ("down" + "up")/2 = (18 + 12)/2 = 15$ km/h. Each alone
  gives only one of the two.
+ **(e).** II is I doubled. One equation, two unknowns: $a = 4$ or $a = 6$ both fit.
+ **(d).** I: $720 \div 1.2 = 600$. II: $540 \div 0.9 = 600$. Both pin Rs.~600.
+ **(c).** Together $1/12 + 1/24 = 3/24 = 1/8$, so 8 days. One rate alone is not enough.
+ **(a).** A number is divisible by 4 when its last two digits are; $36 \div 4 = 9$, so yes.
  Digit sum tests 3 and 9, not 4.
+ **(c).** $20000 \times 1.1 \times 1.1 = 24,200$. Rate without base, or base without rate,
  fails.
+ **(a).** $3d = 29 - 17 = 12 \\Rightarrow d = 4$, $a = 17 - 3(4) = 5$, $t_10 = 5 + 9(4) = 41$.
  II only gives $a + d = 9$.
+ **(e).** Primes 11, 13, 17, 19 are all odd, so II adds nothing and four values survive.
+ **(c).** With both positive, $x^2 > y^2$ forces $x > y$. Alone, I allows $x = -5, y = 2$.
+ **(c).** Length $+$ platform $= 350$ m; $350 \div 25 = 14$ s. Each alone misses a piece.
+ **(a).** $ (1200 - 960)/1200 = 240/1200 = 20% $. A rupee discount with no marked price
  gives no percent.

## Tier 2 — Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 21** `Grab · pattern`

What was a driver's total fare income on Tuesday?
  I: He completed 24 trips at an average fare of S$11.50.
  II: His Tuesday income was 15% more than his Monday income.

**Solution**

I alone: total $=$ number of trips $\times$ average fare $= 24 \times 11.50$.
$24 \times 11 = 264$ and $24 \times 0.5 = 12$, so total $= 264 + 12 = $ S$276. Sufficient.
II alone: Monday's income is unknown, so 15% more than an unknown is unknown.
Not sufficient.

**➜ Answer: (a) I alone.**

**Example 22** `Shopee · pattern`

What is the cost price of an item a seller shipped?
  I: The platform charges a 12% fee on the selling price, and the item sold for
S$250.   II: After the fee, the seller's profit was S$40.

**Solution**

I alone: it tells you what the seller **receives**, not what the item **cost**.
Receipt $= 250 \times (100 - 12)/100 = 250 \times 0.88 = 220$. Cost still unknown.
Not sufficient.
II alone: profit without any price figure. Not sufficient.
Together: cost $=$ receipt $-$ profit $= 220 - 40 = $ S$180.

**➜ Answer: (c) Both together.**

**Example 23** `DBS · pattern`

A customer qualifies for the premium tier if her average monthly balance over three
months is at least S$5,000. Does she qualify?
  I: Her three monthly balances were S$4,200, S$5,100 and S$6,000.
  II: Her third-month balance was S$6,000.

**Solution**

I alone: sum $= 4200 + 5100 = 9300$; $9300 + 6000 = 15300$.
Average $= 15300 \div 3 = 5100$. Since $5100 \\ge 5000$, the answer is a definite **yes**.
Sufficient.
II alone: one month out of three. The other two could be zero (average 2,000, no) or
6,000 each (average 6,000, yes). Not sufficient.

**➜ Answer: (a) I alone.**

---
⚠️ **TRAP**

One month below the target does not disqualify anybody. The rule is about the **average**.
Read what is being averaged before you judge any single number.

**Example 24** `Agoda · pattern`

What was a hotel's occupancy rate last Friday?   I: 84 rooms were occupied.
  II: 21 rooms were empty.

**Solution**

I alone: occupancy rate needs the total room count. Not sufficient.
II alone: same problem from the other side. Not sufficient.
Together: total rooms $= 84 + 21 = 105$.
Rate $= 84/105$. Divide top and bottom by 21: $84 \div 21 = 4$, $105 \div 21 = 5$,
so $4/5 = 80%$.

**➜ Answer: (c) Both together.**

**Example 25** `SCB · pattern`

Nat changes S$400 into Thai baht at a bank. How many baht does she receive?
  I: The bank's rate is S$1 $=$ THB~26.5.
  II: The bank deducts a 1.5% commission from the converted amount.

**Solution**

I alone: gross $= 400 \times 26.5 = 10,600$ baht, but the question asks what she
**receives**, and a fee may apply. Not sufficient on its own.
II alone: a fee percent with no rate. Not sufficient.
Together: gross $= 400 \times 26.5$.
$400 \times 26 = 10400$ and $400 \times 0.5 = 200$, so gross $= 10,600$ baht.
Commission $= 1.5%$ of $10600 = 10600 \times 0.015 = 159$.
Received $= 10600 - 159 = $ THB~10,441.

**➜ Answer: (c) Both together.**

**Example 26** `Sea/Shopee · pattern`

**Three-statement format.** How many March orders were delivered on time?
  I: There were 12,500 orders in March.   II: The on-time rate was 92%.
  III: 1,000 orders were late.

**Solution**

**I and II:** $12500 \times 92/100 = 125 \times 92 = 11,500$. Works.

**I and III:** on time $= 12500 - 1000 = 11,500$. Works.

**II and III:** late rate $= 100 - 92 = 8%$. So $8%$ of total $= 1000$,
total $= 1000 \times 100 / 8 = 12,500$. On time $= 12500 - 1000 = 11,500$. Works.

No single statement works alone: I gives no split, II gives no count, III gives no total.

**➜ Answer: Any two of the three statements are sufficient.**

**Example 27** `GIC · pattern`

Over two years, did a fund beat its benchmark?
  I: The fund returned 8% in year 1 and 5% in year 2; the benchmark returned 6% in
year 1 and 7% in year 2.   II: The benchmark's two-year total return was 13.42%.

**Solution**

I alone: chain the growth factors, do not add the percents.
Fund: $1.08 \times 1.05$. $1.08 \times 1.05 = 1.08 + 0.054 = 1.134$, a 13.4% gain.
Benchmark: $1.06 \times 1.07 = 1.06 + 0.0742 = 1.1342$, a 13.42% gain.
$13.40% < 13.42%$, so the fund did **not** beat the benchmark. A definite **no**.
Sufficient.
II alone: it gives the benchmark only, nothing about the fund. Not sufficient.

**➜ Answer: (a) I alone.**

---
⚠️ **TRAP**

$8 + 5 = 13$ and $6 + 7 = 13$ tempts you into "equal, so cannot decide". Compounding
breaks the tie: the pair that is **less spread out** compounds higher. Always multiply
the factors.

**Example 28** `LINE MAN · pattern`

A delivery app charges a fixed base fee plus a fixed rate per km. What is the rate per km?
  I: A 4 km delivery costs THB~62.   II: A 7 km delivery costs THB~89.

**Solution**

Let the base be $B$ and the per-km rate be $r$.
I alone: $B + 4r = 62$. One equation, two unknowns. Not sufficient.
II alone: $B + 7r = 89$. Same problem. Not sufficient.
Together: subtract the first from the second.
$(B + 7r) - (B + 4r) = 89 - 62 \\Rightarrow 3r = 27 \\Rightarrow r = 9$.
Check: $B = 62 - 4(9) = 62 - 36 = 26$; then $26 + 7(9) = 26 + 63 = 89$. Correct.

**➜ Answer: (c) Both together.**

---
💡 **SHORTCUT**

**Two points on a straight-line price list give both the slope and the base.** Subtract to
kill the base, then back-substitute. If the question asks only for the per-km rate, you
can stop right after the subtraction.

**Example 29** `Razer · pattern`

Is the average product rating above 4.0?
  I: 60 reviews average 4.2 and the other 40 average 3.7.
  II: More than half the reviews give 5 stars.

**Solution**

I alone: weighted average $= (60 \times 4.2 + 40 \times 3.7) / 100$.
$60 \times 4.2 = 252$. $40 \times 3.7 = 148$. $252 + 148 = 400$.
$400 \div 100 = 4.0$ exactly. "Above 4.0" is therefore **no**. A definite answer.
Sufficient.
II alone: 51 fives and 49 ones give an average near 3.0; 51 fives and 49 fours give 4.5.
Both answers possible. Not sufficient.

**➜ Answer: (a) I alone.**

The answer is "no" and that still counts as sufficient. Students lose this mark
by thinking a boundary result means "cannot say".

#### Practice — Tier 2 — Singapore & Thailand *(target: 100 s/Q)*

Options (a)–(e) as before, except where a question names its own options.

+ What is the price of 1 kg of rice at a stall?   I: 3 kg of rice and 2 kg of dal
  cost THB~410.   II: 6 kg of rice and 4 kg of dal cost THB~820.
+ What were a driver's net earnings for the day?   I: His gross fares were S$320.
    II: The platform keeps a 20% commission.
+ Did more than 500 customers visit a store on Sunday?   I: 600 customers visited
  across Saturday and Sunday together.   II: Sunday's count was 50% higher than
  Saturday's.
+ What is a company's profit margin on revenue?   I: Revenue was S$4.5 million and
  total cost was S$3.6 million.   II: Profit was S$0.9 million.
+ What did Ploy pay for a phone including 7% VAT?   I: The price before VAT was
  THB~18,000.   II: The VAT charged was THB~1,260.
+ What is the value of an order in Singapore dollars?   I: The order is THB~21,200.
    II: S$1 $=$ THB~26.5.
+ **Three statements.** What is the monthly rent of a shop?   I: Rent is 18% of
  monthly revenue.   II: Monthly revenue is S$25,000.   III: Rent plus
  utilities is S$5,000, and utilities alone are S$500.
    Options: (a) I and II together, but III alone does not work  
  (b) III alone, but I and II together do not work  
  (c) III alone works, and I and II together also work  
  (d) all three statements are needed
+ Is the discount on a laptop more than 15%?   I: The marked price is S$2,400 and
  it sells for S$2,040.   II: The discount is S$360.
+ How long does an airport shuttle take to reach the hotel?   I: The distance is
  27 km.   II: The shuttle averages 45 km/h.
+ How many people work at the Bangkok office?   I: More than 120.
    II: Fewer than 150.
+ A fund grew exactly 25% during 2024. What was its value at the start of the year?
    I: It ended the year at S$1.5 million.   II: The gain was S$300,000.
+ Is the average order value above THB~500?   I: Total order value was THB~58,000.
    II: There were 120 orders.

<details>
<summary><b>Answer key</b></summary>

+ **(e).** II is I doubled, so it is the same equation. Rice at 90 with dal at 70, or rice
  at 100 with dal at 55, both fit.
+ **(c).** Net $= 320 \times 0.80 = $ S$256. A gross figure with no rate, or a rate with no
  gross, fails.
+ **(c).** Let Saturday $= S$. Then $S + 1.5S = 600 => 2.5S = 600 => S = 240$, Sunday
  $= 360$. That is not more than 500 — a definite **no**.
+ **(a).** Profit $= 4.5 - 3.6 = 0.9$; margin $= 0.9/4.5 = 20%$. II has no revenue to
  divide by.
+ **(d).** I: $18000 times 1.07 = 19,260$. II: $1260 div 0.07 = 18,000$ before VAT, so
  $18000 + 1260 = 19,260$.
+ **(c).** $21200 div 26.5 = 800$. Either an amount with no rate, or a rate with no amount.
+ **(c).** III alone: $5000 - 500 = $ S$4,500. I and II together:
  $0.18 \times 25000 = $ S$4,500. Same answer by two routes.
+ **(a).** $(2400 - 2040)/2400 = 360/2400 = 15%$, which is **not** more than 15% — a definite
  no. A rupee-style amount alone gives no percent.
+ **(c).** $27 div 45 = 0.6$ h $= 36$ minutes. Distance without speed, or speed without
  distance, fails.
+ **(e).** Together the count is any number from 121 to 149 — many values.
+ **(d).** I: $1.5 div 1.25 = $ S$1.2 million. II: $300000 \div 0.25 = $ S$1.2 million.
+ **(c).** $58000 div 120 = 483.33$, which is not above 500 — a definite no. Neither the
  total nor the count works alone.

## Tier 3 — Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 30** `Google · pattern`

Is the positive integer $n$ a perfect square?
  I: $n$ has exactly 3 positive divisors.   II: $n$ is odd.

**Solution**

*Insight: divisors pair up as $d$ and $n/d$, so the count of divisors is odd only when one
divisor pairs with itself — that is, only for a perfect square.*

I alone: exactly 3 divisors is an odd count, so $n$ must be a perfect square.
Concretely, if $n = p^2$ for a prime $p$, its divisors are $1, p, p^2$ — exactly 3.
Any other shape gives a different count: $p$ gives 2, $p q$ gives 4, $p^3$ gives 4.
So $n = p^2$, a perfect square. Definite **yes**. Sufficient.
II alone: $n = 9$ is an odd perfect square; $n = 15$ is odd and not a perfect square.
Not sufficient.

**➜ Answer: (a) I alone.**

**Example 31** `Goldman Sachs · pattern`

$x$ and $y$ are positive integers. Is the product $x y$ even?
  I: $x + y$ is odd.   II: $x^2 + y^2$ is odd.

**Solution**

*Insight: a product is even the moment one factor is even. So the whole question is
"is at least one of them even?" — a parity question, not an arithmetic one.*

I alone: a sum is odd only when one number is odd and the other is even
(odd $+$ odd $=$ even, even $+$ even $=$ even). So one of them is even, and the product
is even. Definite **yes**. Sufficient.
II alone: squaring does not change parity. An even number squared is even
($4^2 = 16$); an odd number squared is odd ($3^2 = 9$).
So $x^2 + y^2$ odd forces one of $x^2, y^2$ even and the other odd, hence one of
$x, y$ even and the other odd. The product is even. Definite **yes**. Sufficient.

**➜ Answer: (d) Each alone is sufficient.**

**Example 32** `Amazon · pattern`

A bag holds only red and blue balls. Two balls are drawn together (without replacement).
Is the probability that both are red greater than $1/2$?
  I: There are 10 balls, of which 8 are red.
  II: More than 75% of the balls are red.

**Solution**

*Insight: drawing without replacement makes the second draw slightly worse than the first,
so the probability is a little below $p^2$. If $p^2$ clears $1/2$ with room to spare, the
small penalty cannot drag it below.*

I alone: $P = 8/10 \times 7/9 = 56/90 = 28/45$.
$28/45 = 0.622...$, and $0.622 > 0.5$. Definite **yes**. Sufficient.

II alone: let there be $n$ balls with $r$ red, $r > 0.75 n$. Then
$ P = r/n \times (r-1)/(n-1) . $
Test the tightest cases, where $r$ is the smallest integer above $0.75n$:
- $n = 4, r = 4$: $P = 1$. Yes.
- $n = 5, r = 4$: $P = 4/5 \times 3/4 = 3/5 = 0.6$. Yes.
- $n = 8, r = 7$: $P = 7/8 \times 6/7 = 6/8 = 0.75$. Yes.
- $n = 9, r = 7$: $P = 7/9 \times 6/8 = 42/72 = 0.583$. Yes.
- $n = 100, r = 76$: $P = 0.76 \times 75/99 = 0.76 \times 0.7576 = 0.576$. Yes.
- Very large $n$: $P$ approaches $0.75^2 = 0.5625$. Still above $0.5$.
Now prove it instead of sampling. With $r > 0.75n$,
$ r(r-1) > 0.75n (0.75n - 1) = 0.5625 n^2 - 0.75 n . $
We need $P > 1/2$, i.e. $r(r-1) > n(n-1)/2 = 0.5 n^2 - 0.5 n$.
It is enough that $0.5625 n^2 - 0.75 n \\ge 0.5 n^2 - 0.5 n$, i.e.
$0.0625 n^2 \\ge 0.25 n$, i.e. $n \\ge 4$. And $n$ must be at least 4 anyway, because
$r > 0.75n$ with $r \\le n$ needs at least 4 balls to leave room for a non-red one — and
$n = 2, 3$ force $r = n$, giving $P = 1$. So the answer is always **yes**. Sufficient.

**➜ Answer: (d) Each alone is sufficient.**

Sampling six cases is how you **believe** it. The inequality is how you **know** it.
In an interview, do the sampling out loud, then produce the inequality.

**Example 33** `Microsoft · pattern`

A jar holds black and white stones. Repeatedly, two stones are removed: if they match,
one **black** stone is put back; if they differ, one **white** stone is put back. This runs
until one stone is left. Is the last stone white?
  I: The jar starts with 12 white stones.
  II: The jar starts with 15 black stones.

**Solution**

*Insight: track the parity of the white count. Every move changes it by 0 or 2, never
by 1 — so odd stays odd and even stays even for the whole game.*

Check the three moves:
- Two black removed, one black added: white unchanged.
- Two white removed, one black added: white drops by 2.
- One of each removed, one white added: white loses 1 and gains 1, so white unchanged.
In every case the number of white stones keeps its parity.

I alone: white starts at 12, an even number, so it is even forever. At the end one stone
remains. If it were white, the white count would be 1, which is odd — impossible.
So the last stone is black: a definite **no**. Sufficient.
II alone: the black count tells you nothing, because black is the colour whose parity is
**not** protected. Start 15 black with 1 white: the pair (black, white) gives white back,
and white parity is odd, so the last stone is white. Start 15 black with 2 white: white
parity is even, so the last stone is black. Two different answers. Not sufficient.

**➜ Answer: (a) I alone.**

---
💡 **SHORTCUT**

**Find the invariant, and one statement usually collapses to "irrelevant".** In any
repeat-until-one puzzle, ask what each move does to a count's parity, a total, or a sum
modulo something. The quantity that never changes is the whole answer.

**Example 34** `D. E. Shaw · pattern`

A biased coin shows heads with probability $p$. It is tossed until the first head appears.
Is the expected number of tosses less than 4?
  I: $p = 0.3$.   II: The probability of getting no head in the first two
tosses is less than 0.5.

**Solution**

*Insight: for "toss until the first success", the expected number of tosses is $1/p$.
So the question "is $E < 4$?" is exactly the question "is $p > 1/4$?"*

Why $E = 1/p$: let $E$ be the expected number. The first toss always happens. With
probability $p$ you stop; with probability $1-p$ you are back where you started.
$ E = 1 + (1-p) E \\Rightarrow E - (1-p)E = 1 \\Rightarrow p E = 1 \\Rightarrow E = 1/p . $
And $1/p < 4 <\\Rightarrow p > 1/4 = 0.25$.

I alone: $p = 0.3 > 0.25$, so $E = 1/0.3 = 3.33$, which is less than 4.
Definite **yes**. Sufficient.
II alone: "no head in two tosses" has probability $(1-p)^2$.
$ (1-p)^2 < 0.5 \\Rightarrow 1 - p < sqrt(0.5) = 0.7071 \\Rightarrow p > 0.2929 . $
Since $0.2929 > 0.25$, we get $E = 1/p < 1/0.2929 = 3.41 < 4$.
Definite **yes**. Sufficient.

**➜ Answer: (d) Each alone is sufficient.**

Statement II never pins $p$ down. It only pushes $p$ past the threshold, and a
threshold is all a yes/no question needs.

**Example 35** `Adobe · pattern`

A set $S$ has 8 distinct positive integers. Is the median of $S$ greater than 20?
  I: The four smallest members are 3, 7, 11 and 19.
  II: The four largest members are 24, 30, 41 and 50.

**Solution**

*Insight: with 8 numbers the median is the average of the 4th and 5th. Statement I fixes
the 4th, statement II fixes the 5th. Neither half is a median by itself.*

I alone: the 4th smallest is 19. The 5th is some integer above 19, so at least 20.
- If the 5th is 20, median $= (19 + 20)/2 = 19.5$, which is **not** above 20.
- If the 5th is 25, median $= (19 + 25)/2 = 22$, which **is** above 20.
Two answers. Not sufficient.

II alone: the four largest are 24, 30, 41, 50, so the 5th smallest is 24 and the 4th is
some value below 24.
- If the 4th is 10, median $= (10 + 24)/2 = 17$. Not above 20.
- If the 4th is 23, median $= (23 + 24)/2 = 23.5$. Above 20.
Two answers. Not sufficient.

Together: the list is $3, 7, 11, 19$ then $24, 30, 41, 50$ — all eight members.
Median $= (19 + 24)/2 = 43/2 = 21.5$, which is greater than 20. Definite **yes**.

**➜ Answer: (c) Both together.**

**Example 36** `Amazon · pattern`

A shop sold exactly 100 items today. Is the total revenue more than Rs.~50,000?
  I: The cheapest item sold for Rs.~460.
  II: The median selling price was Rs.~560.

**Solution**

*Insight: a minimum gives a floor for every item; a median gives a floor for the top
half only. Add the two floors — if their sum already clears the target, the answer is
yes no matter what the actual prices are.*

I alone: every item is at least 460, so revenue $\\ge 100 \times 460 = 46,000$.
That is below 50,000, so "more than 50,000" could be false (all items at 460) or true
(all at 1,000). Not sufficient.

II alone: with 100 sorted prices, median $= (x_50 + x_51)/2 = 560$. Since
$x_50 \\le x_51$, we get $x_51 \\ge 560$, so the top 50 items give at least
$50 \times 560 = 28,000$. But the bottom 50 have no floor at all; they could be Rs.~1 each,
giving a total near 28,050 — below 50,000. Or they could be huge. Not sufficient.

Together:
- Bottom 50 items: each at least 460, so at least $50 \times 460 = 23,000$.
- Top 50 items: each at least 560 (shown above), so at least $50 \times 560 = 28,000$.
- Minimum possible revenue $= 23,000 + 28,000 = 51,000$.
Since $51,000 > 50,000$, the revenue is above 50,000 in every case. Definite **yes**.

**➜ Answer: (c) Both together.**

The pattern to remember: **worst-case sum**. Build the cheapest world the statements
allow. If even that world beats the target, you are done.

#### Practice — Tier 3 — Product *(target: 4 min/Q)*

Options (a)–(e) as before.

+ Is the positive integer $n$ divisible by 6?   I: $n^2$ is divisible by 36.
    II: $n^3$ is divisible by 8.
+ $x, y, z$ are positive integers. Is the product $x y z$ even?   I: $x + y + z$ is
  even.   II: $x z$ is odd.
+ A box holds red and green counters. Repeatedly two are removed: if they match, a **green**
  counter is put back; if they differ, a **red** counter is put back. This runs until one
  counter is left. Is the last counter red?   I: The box starts with 7 green
  counters.   II: The box starts with 10 red counters.
+ A set has 7 distinct positive integers. Is the mean greater than the median?
    I: The largest member is 100.
    II: The seven numbers form an arithmetic progression.
+ Fifty students sat a test. Is the total of all their marks more than 1,900?
    I: The lowest mark was 35.   II: The median mark was 45.
+ A bag holds only red and blue balls. Two are drawn without replacement. Is the
  probability that both are the same colour greater than $1/2$?   I: The bag holds
  10 balls.   II: There are equally many red and blue balls.
+ A game costs Rs.~20 per play and pays Rs.~100 when a biased die shows a six. Is the
  expected profit per play positive?   I: The probability of **not** getting a six is
  0.78.   II: The expected payout per play is Rs.~22.
+ $n$ distinct points lie on a circle. Is the number of chords joining them more than 50?
    I: $n > 10$.   II: The number of triangles with vertices at these points
  is 165.

<details>
<summary><b>Answer key</b></summary>

+ **(a).** $36 = 2^2 3^2$. If $n^2$ carries $2^2 3^2$, then $n$ carries $2 \times 3 = 6$
  (each prime's power in $n^2$ is double its power in $n$, so $n$ has at least one 2 and
  one 3). Definite yes. II only forces $n$ to be even: $n = 2$ has $n^3 = 8$ but is not
  a multiple of 6.
+ **(a).** Three odd numbers add to an odd total, so an even sum means all three are even, or
  exactly two are odd and one is even. Either way at least one factor is even, so the
  product is even — a definite yes. II says $x$ and $z$ are both odd but leaves $y$ free:
  $y$ even gives an even product, $y$ odd gives an odd one.
+ **(b).** Check what each move does to the **red** count. Two reds out, one green in: red
  drops by 2. Two greens out, one green in: red unchanged. One of each out, one red in:
  red unchanged. So red parity never changes. Starting at 10 (even) it stays even, so the
  last counter cannot be a single red — a definite no. The green count in I is the
  unprotected one and decides nothing.
+ **(b).** In an arithmetic progression the terms are symmetric about the middle one, so the
  mean equals the median exactly — "greater" is a definite no. I fails: $1,2,3,4,5,6,100$
  has mean $121/7 = 17.3$ against median 4 (yes), while $94,95,96,97,98,99,100$ has mean
  $=$ median $= 97$ (no).
+ **(c).** The bottom 25 marks are each at least 35, giving at least 875. The median 45 means
  the 26th mark is at least 45, so the top 25 give at least $25 \times 45 = 1,125$. Minimum
  total $= 875 + 1125 = 2,000 > 1,900$. Definite yes. Alone, I gives only 1,750 and II
  leaves the bottom half unbounded below.
+ **(b).** II alone settles it. Equal numbers means $n$ red and $n$ blue, so $2n$ balls.
  Favourable pairs $= binom(n,2) + binom(n,2) = n(n-1)$. Total pairs
  $= binom(2n,2) = (2n)(2n-1)/2 = n(2n-1)$.
  So $P = (n(n-1))/(n(2n-1)) = (n-1)/(2n-1)$, and this is always below $1/2$ because
  $2(n-1) = 2n - 2$ is less than $2n - 1$. So the answer is **no** for every $n$ — definite.
  Check with $n = 5$: $P = 4/9 = 0.444$. I alone fails: 10 balls all red gives $P = 1$
  (yes), 5 red and 5 blue gives $0.444$ (no).
+ **(d).** Profit is positive when $100p > 20$, i.e. $p > 0.2$. I: $p = 1 - 0.78 = 0.22 >
  0.2$, so expected profit $= 22 - 20 = $ Rs.~2, positive. II: payout $100p = 22$ gives
  $p = 0.22$, the same conclusion.
+ **(d).** Chords $= binom(n,2) = n(n-1)/2$, so chords $> 50$ needs $n(n-1) > 100$: true
  from $n = 11$ ($11 \times 10 = 110$) and false at $n = 10$ ($10 \times 9 = 90$).
  I: $n > 10$ means $n \\ge 11$, so chords $\\ge 55$ — definite yes.
  II: $binom(n,3) = 165$. Try $n = 11$: $(11 \times 10 \times 9)/6 = 990/6 = 165$. Fits,
  and $binom(n,3)$ grows with $n$, so $n = 11$ is the only value. Chords
  $= binom(11,2) = (11 \times 10)/2 = 55 > 50$ — definite yes.

---
⚠️ **TRAP**

**Both statements are always true at once.** They can never contradict each other. If you
derive $x = 5$ from I and $x = 9$ from II, stop — you have made an arithmetic slip, not
found a trick question. Re-check before you answer.

## Mixed set — exam conditions

#### Practice — Tier 1 — Service *(target: 30 min for 18 questions)*

No tier labels. Options (a)–(e) as before, except where a question names its own options.

+ What is the value of $y$?   I: $4y - 9 = 11$.   II: $y^2 - 25 = 0$.
+ What do 8 identical chairs cost?   I: 3 chairs cost Rs.~4,200.
    II: 5 chairs cost Rs.~7,000.
+ Is the integer $n$ a multiple of 15?   I: $n$ is a multiple of 10.
    II: $n$ is a multiple of 6.
+ How much simple interest does a sum earn in 3 years?   I: The sum doubles itself
  in 12 years at that rate.   II: The sum is Rs.~20,000.
+ Is $x > 0$?   I: $x^3 > 0$.   II: $x^2 > 0$.
+ What is the perimeter of a right-angled triangle?   I: The two legs are 6 cm and
  8 cm.   II: The hypotenuse is 10 cm and the area is 24 cm#super[2].
+ What does a shirt sell for after two successive discounts?   I: Its marked price is
  Rs.~2,000 and the discounts are 20% and then 10%.   II: The total discount is
  Rs.~560.
+ How many students are in a class?   I: The number is divisible by 7 and lies
  between 40 and 50.   II: The number is a multiple of 14 and lies between 40 and 50.
+ What is the speed of the current?   I: A boat covers 30 km downstream in 2 hours.
    II: The boat's downstream speed is 15 km/h.
+ Is a given quadrilateral a square?   I: All four sides are equal.
    II: The diagonals are equal.
+ How many litres of milk are in a mixture?   I: The mixture is 40 litres with
  milk : water $= 3 : 2$.   II: The mixture has 16 litres of water, and the milk is
  50% more than the water.
+ What is the compound interest for 2 years?   I: The principal is Rs.~10,000 and
  the rate is 10% per annum.   II: The rate is 10% per annum and the simple
  interest for 2 years is Rs.~2,000.
+ Is the average weight of a team above 60 kg?   I: The 11 players weigh 660 kg in
  total.   II: The heaviest player weighs 78 kg.
+ **Three statements.** What is a son's present age?   I: His father is 30 years older
  than he is.   II: In 6 years the father will be 3 times as old as the son.
    III: Four years ago the father was 7 times as old as the son.
    Options: (a) I and II only   (b) I and III only  
  (c) any two of the three   (d) all three are needed
+ Is $2^n - 1$ a prime number, where $n$ is a positive integer?   I: $n = 11$.
    II: $n$ is prime.
+ A jar holds 20 coins, each either a one-rupee or a two-rupee coin. How many are
  two-rupee coins?   I: The coins are worth Rs.~32 in all.   II: There are 8
  one-rupee coins.
+ Is the product of the roots of $x^2 + b x + c = 0$ positive?   I: $b = -5$.
    II: The two roots are equal.
+ A list has 100 numbers. Is their total at least 4,000?   I: The smallest number is
  30.   II: The median is 50.

<details>
<summary><b>Answer key</b></summary>

+ **(a).** $4y = 20$, $y = 5$. II gives $y = 5$ or $y = -5$.
+ **(d).** I: $4200 \div 3 = 1400$ each, so $8 \times 1400 = $ Rs.~11,200.
  II: $7000 \div 5 = 1400$ each, same total.
+ **(c).** Together $n$ is a multiple of $"LCM"(10, 6) = 30$, and 30 is a multiple of 15.
  Alone, $n = 10$ and $n = 6$ both fail.
+ **(c).** Doubling in 12 years at simple interest means the interest equals the principal
  in 12 years, so the rate is $100/12 %$ per year and 3 years give $25%$ of the principal.
  With $P = 20,000$: SI $= 20000 \times 0.25 = $ Rs.~5,000. Rate without principal, or
  principal without rate, fails.
+ **(a).** A cube keeps the sign, so $x^3 > 0$ forces $x > 0$. $x^2 > 0$ only says
  $x \\ne 0$; $x = -3$ works too.
+ **(d).** I: hypotenuse $= sqrt(36 + 64) = sqrt(100) = 10$, perimeter $= 6 + 8 + 10 = 24$ cm.
  II: legs $a, b$ with $a b = 48$ (from area $= a b / 2 = 24$) and $a^2 + b^2 = 100$, so
  $(a+b)^2 = 100 + 2(48) = 196$, $a + b = 14$, perimeter $= 14 + 10 = 24$ cm.
+ **(a).** $2000 \times 0.8 \times 0.9 = 1,440$. II gives a rupee discount with no marked
  price — the same Rs.~560 off Rs.~5,000 would leave a different price.
+ **(b).** Multiples of 7 between 40 and 50: 42 and 49 — two values. Multiples of 14 between
  40 and 50: only 42.
+ **(e).** Statement II just restates statement I ($30 \div 2 = 15$ km/h). Neither says
  anything about the upstream speed, so the current stays unknown.
+ **(c).** Equal sides alone give a rhombus; equal diagonals alone give a rectangle or an
  isosceles trapezium. Both together force a square.
+ **(d).** I: milk $= 40 \times 3/5 = 24$ litres. II: milk $= 16 \times 1.5 = 24$ litres.
+ **(d).** I: $10000(1.1)^2 - 10000 = 12100 - 10000 = $ Rs.~2,100. II: SI Rs.~2,000 over
  2 years at 10% means $P \times 0.2 = 2000$, so $P = 10,000$, and the CI is again
  Rs.~2,100.
+ **(a).** $660 \div 11 = 60$ exactly, which is **not** above 60 — a definite no. One player's
  weight settles nothing.
+ **(c).** Let the son be $s$ and the father $f$. I and II: $f = s + 30$ and
  $s + 36 = 3(s+6) = 3s + 18$, so $2s = 18$, $s = 9$. I and III: $s + 26 = 7(s - 4)
  = 7s - 28$, so $6s = 54$, $s = 9$. II and III: $f = 3s + 12$ and $f = 7s - 24$, so
  $4s = 36$, $s = 9$. Every pair gives 9 years.
+ **(a).** $2^11 - 1 = 2047 = 23 \times 89$, so it is **not** prime — a definite no. II fails
  because $n = 3$ gives the prime 7 while $n = 11$ gives the composite 2047.
+ **(d).** Let there be $t$ two-rupee coins and $o$ one-rupee coins, $o + t = 20$.
  I: $o + 2t = 32$, so $t = 12$. II: $o = 8$, so $t = 20 - 8 = 12$.
+ **(c).** For $x^2 + b x + c$, the product of the roots is $c$. I gives $b$, not $c$. II
  alone allows a double root of 0 (product 0, not positive). Together, equal roots need
  $b^2 - 4c = 0$, so $25 - 4c = 0$, $c = 6.25 > 0$ — a definite yes.
+ **(c).** Bottom 50 numbers are each at least 30, giving 1,500. The median 50 forces the
  51st number to be at least 50, so the top 50 give at least 2,500. Minimum total
  $= 1500 + 2500 = 4,000$, so "at least 4,000" is a definite yes. Alone, I gives only
  3,000 and II leaves the bottom half unbounded.

## 📋 One-page revision card

**THE FIVE OPTIONS**
#table(columns: (auto, 1fr),
  [(a)], [I alone works, II alone does not],
  [(b)], [II alone works, I alone does not],
  [(c)], [Neither alone; both together work],
  [(d)], [Each one alone works],
  [(e)], [Even both together fail],
)

**THE AD / BCE GRID** — Test I alone. Works $\\Rightarrow$ answer is (a) or (d); now test II.
Fails $\\Rightarrow$ answer is (b), (c) or (e); now test II, and combine only if II also fails.

**WHAT "SUFFICIENT" MEANS**
- Value question: exactly **one** number survives.
- Yes/no question: the answer is **always yes** or **always no**. A definite no is sufficient.
- Two survivors $\\Rightarrow$ insufficient. Always hunt for a second case before you commit.

**COUNTING EQUATIONS** — $k$ unknowns need $k$ **independent** linear equations.
$4x + 6y = 24$ is not new information after $2x + 3y = 12$. Non-linear pairs
($x + y = 7$, $x y = 12$) often give two solutions, so they are not automatically enough.

**SHORTCUTS**
+ Set the base to 100 whenever the answer is a percent or a ratio. Rupee values are then
  decoys.
+ For a yes/no, shrink the candidate list until every survivor gives the same verdict.
  You never have to identify the unknown.
+ Two points on a linear price rule (base fee $+$ rate) give the rate by subtraction.
+ For "is the total above $T$?", build the **cheapest legal world** from the floors the
  statements give. If even that beats $T$, the answer is yes.
+ In repeat-until-one puzzles, find the parity or sum that every move leaves unchanged.
  The statement that does not touch it is the useless one.
+ km/h $arrow$ m/s: $\times 5/18$. Divisible by $a$ and $b$ $\\Rightarrow$ divisible by
  $"LCM"(a,b)$, not by $a b$.

**TOP 5 TRAPS**
+ **Solving instead of deciding.** You get no marks for the number. Stop at "one answer
  exists".
+ **The repeated equation.** If II is I times a constant, the answer is (e), never (c).
+ **Leaking statement I into statement II.** Cover I with your finger while you test II.
+ **Forgetting the second root or the negative case.** $x^2 = 49$, $|x| = 3$,
  even roots, and "digits found" versus "number found" all hide a second answer.
+ **Calling a boundary result "cannot say".** An average of exactly 4.0 answers
  "is it above 4.0?" with a firm no — that is sufficient.

</details>

</details>

</details>

</details>
