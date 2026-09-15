# Chapter 13 — Series

*Find the rule, then the term.*

## What you need to know

**WHAT YOU NEED TO KNOW**

**The 5-step attack (use it in this order, every time)**

+ Write the **differences** between consecutive terms. Constant? → add that number.
+ Differences not constant? Write the **second differences**. Constant? → the series is quadratic; keep extending the difference row.
+ Try **ratios** (divide each term by the one before). Constant or a neat pattern (×2, ×3, ×4 …)? 
+ Compare with $n^2$, $n^3$, $n!$, primes: is each term $n^2 plus.minus c$, $n^3 plus.minus c$, or $n(n+1)$?
+ Still stuck? The series is **alternating** (two rules used turn by turn) or **interleaved** (two separate series zipped together). Split the odd positions from the even positions.

**Standard rules you must recognise on sight**

#table(columns: 2,
[Pattern], [Example],
[Add a constant (AP)], [$3, 7, 11, 15, 19$   ($d = 4$)],
[Multiply by a constant (GP)], [$2, 6, 18, 54$   ($r = 3$)],
[Growing difference], [$7, 12, 19, 28, 39$   (diffs $5,7,9,11$)],
[$\times k plus.minus c$], [$5, 11, 23, 47$   ($\times 2 + 1$)],
[$\times k$, $k$ itself grows], [$3, 6, 18, 72$   ($\times 2, \times 3, \times 4$)],
[Perfect squares], [$1, 4, 9, 16, 25$],
[Squares $plus.minus 1$], [$2, 5, 10, 17, 26$   ($n^2+1$)],
[Perfect cubes], [$1, 8, 27, 64, 125$],
[Cubes $plus.minus c$], [$2, 9, 28, 65$   ($n^3+1$)],
[$n(n+1)$ (products)], [$2, 6, 12, 20, 30$],
[Factorials], [$1, 2, 6, 24, 120$],
[Fibonacci type], [$2, 3, 5, 8, 13, 21$],
[Alternating rules], [$5, 10, 8, 16, 14$   ($\times 2, -2, \times 2, -2$)],
[Interleaved], [$3, 20, 6, 17, 9, 14$   (two series)],
)

**Formulas**

- AP: $n$-th term $= a + (n-1)d$. Sum $= n/2 [2a + (n-1)d]$.
- GP: $n$-th term $= a r^(n-1)$. Sum of $n$ terms $= a(r^n - 1)/(r-1)$, $r \\ne 1$.
- Infinite GP, $|r| < 1$: sum $= a/(1-r)$.
- $1 + 2 + \dots.c + n = (n(n+1))/2$
- $1^2 + 2^2 + \dots.c + n^2 = (n(n+1)(2n+1))/6$
- $1^3 + 2^3 + \dots.c + n^3 = ((n(n+1))/2)^2$
- Triangular numbers $T_k = (k(k+1))/2$;   $T_1 + T_2 + \dots.c + T_n = (n(n+1)(n+2))/6$

**Numbers you should know cold**

- Squares: 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225, 256, 289, 324, 361, 400
- Cubes: 1, 8, 27, 64, 125, 216, 343, 512, 729, 1000, 1331, 1728
- Primes: 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47
- Factorials: 1, 2, 6, 24, 120, 720, 5040

**Letters**

#table(columns: 13,
[A],[B],[C],[D],[E],[F],[G],[H],[I],[J],[K],[L],[M],
[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],
[N],[O],[P],[Q],[R],[S],[T],[U],[V],[W],[X],[Y],[Z],
[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],
)

- Memory hook: **E** 5, **J** 10, **O** 15, **T** 20, **Y** 25 ("EJOTY").
- Letter series = number series in disguise. Convert to numbers, solve, convert back.
- Wrap-around: after Z, start again at A. Position 27 → A, 28 → B.

## Warm-up

### Warm-up

**Example 1**

Find the next term: 3, 7, 11, 15, ?

**Solution**

Differences: $7-3 = 4$, $11-7 = 4$, $15-11 = 4$. Constant. \
Next $= 15 + 4 = 19$.

**➜ Answer: 19**

**Example 2**

Find the next term: 2, 6, 18, 54, ?

**Solution**

Ratios: $6 \div 2 = 3$, $18 \div 6 = 3$, $54 \div 18 = 3$. Constant. \
Next $= 54 \times 3 = 162$.

**➜ Answer: 162**

**Example 3**

Find the next term: 1, 4, 9, 16, ?

**Solution**

$1 = 1^2$, $4 = 2^2$, $9 = 3^2$, $16 = 4^2$. \
Next $= 5^2 = 25$.

**➜ Answer: 25**

**Example 4**

Find the next term: 2, 5, 10, 17, 26, ?

**Solution**

Compare with squares: $1+1 = 2$, $4+1 = 5$, $9+1 = 10$, $16+1 = 17$, $25+1 = 26$. \
So the rule is $n^2 + 1$. Next: $6^2 + 1 = 36 + 1 = 37$.

**➜ Answer: 37**

**Example 5**

Find the next term: 1, 8, 27, 64, ?

**Solution**

$1 = 1^3$, $8 = 2^3$, $27 = 3^3$, $64 = 4^3$. \
Next $= 5^3 = 125$.

**➜ Answer: 125**

**Example 6**

Find the next letter: B, D, F, H, ?

**Solution**

Positions: B $= 2$, D $= 4$, F $= 6$, H $= 8$. Add 2 each time. \
Next position $= 8 + 2 = 10$. Letter number 10 is J.

**➜ Answer: J**

**Example 7**

Find the next term: 5, 11, 23, 47, ?

**Solution**

$5 \times 2 = 10$, $10 + 1 = 11$.   $11 \times 2 = 22$, $22 + 1 = 23$.   $23 \times 2 = 46$, $46 + 1 = 47$. \
Rule: $\times 2 + 1$. Next $= 47 \times 2 + 1 = 94 + 1 = 95$.

**➜ Answer: 95**

**Example 8**

Find the next term: 120, 60, 20, 5, ?

**Solution**

$120 \div 60 = 2$, so divide by 2.   $60 \div 20 = 3$, divide by 3.   $20 \div 5 = 4$, divide by 4. \
The divisor grows: 2, 3, 4, 5. Next $= 5 \div 5 = 1$.

**➜ Answer: 1**

## Tier 1 --- Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

Find the next term: 7, 12, 19, 28, 39, ?

**Solution**

Differences: $12-7 = 5$,   $19-12 = 7$,   $28-19 = 9$,   $39-28 = 11$. \
The differences are 5, 7, 9, 11 --- they grow by 2. \
Next difference $= 11 + 2 = 13$. \
Next term $= 39 + 13 = 52$.

**➜ Answer: 52**

---
💡 **SHORTCUT**

When first differences form their own AP, the series is quadratic. You never need the formula --- just keep the difference row going. It is faster and it cannot go wrong.

**Example 10** `Infosys pattern`

Find the next term: 4, 9, 20, 43, 90, ?

**Solution**

Test $\times 2$ plus something: \
$4 \times 2 = 8$, and $9 - 8 = 1$. \
$9 \times 2 = 18$, and $20 - 18 = 2$. \
$20 \times 2 = 40$, and $43 - 40 = 3$. \
$43 \times 2 = 86$, and $90 - 86 = 4$. \
The added number is 1, 2, 3, 4 --- so next we add 5. \
Next term $= 90 \times 2 + 5 = 180 + 5 = 185$.

**➜ Answer: 185**

**Example 11** `Wipro pattern`

Find the next term: 3, 6, 18, 72, ?

**Solution**

Ratios: $6 \div 3 = 2$,   $18 \div 6 = 3$,   $72 \div 18 = 4$. \
The multiplier grows: 2, 3, 4, so next is 5. \
Next term $= 72 \times 5 = 360$.

**➜ Answer: 360**

**Example 12** `Accenture pattern`

One term is wrong. Which one?   2, 5, 10, 17, 26, 38, 50

**Solution**

Check against $n^2 + 1$: \
$1^2+1 = 2$ ✓   $2^2+1 = 5$ ✓   $3^2+1 = 10$ ✓   $4^2+1 = 17$ ✓ \
$5^2+1 = 26$ ✓   $6^2+1 = 37$, but the series shows 38 ✗   $7^2+1 = 50$ ✓ \
Only 38 breaks the rule. It should be 37.

**➜ Answer: 38 (it should be 37)**

---
⚠️ **TRAP**

A "wrong term" question asks **which term is wrong**, not **what it should be**. The two answers are different numbers (here 38 and 37). Read the last line of the question before you tick an option.

**Example 13** `Capgemini pattern`

Find the missing term: 6, 13, 27, ?, 111

**Solution**

$6 \times 2 = 12$, $12 + 1 = 13$.   $13 \times 2 = 26$, $26 + 1 = 27$. \
So the rule is $\times 2 + 1$. \
Missing term $= 27 \times 2 + 1 = 54 + 1 = 55$. \
Check forward: $55 \times 2 + 1 = 110 + 1 = 111$ ✓ matches the last term.

**➜ Answer: 55**

---
💡 **SHORTCUT**

With a missing **middle** term, always check both ways: build it from the left, then test it against the term on the right. If both agree, your rule is certainly correct.

**Example 14** `TCS NQT pattern`

Find the next letter: C, F, I, L, ?

**Solution**

Positions: C $= 3$, F $= 6$, I $= 9$, L $= 12$. \
Differences: $6-3 = 3$, $9-6 = 3$, $12-9 = 3$. Add 3. \
Next position $= 12 + 3 = 15$. Letter number 15 is O.

**➜ Answer: O**

**Example 15** `Cognizant pattern`

Find the next term: A1, C4, E9, G16, ?

**Solution**

Letters: A $= 1$, C $= 3$, E $= 5$, G $= 7$. Add 2 each time. \
Next letter position $= 7 + 2 = 9$ → I. \
Numbers: 1, 4, 9, 16 are $1^2, 2^2, 3^2, 4^2$. \
Next number $= 5^2 = 25$.

**➜ Answer: I25**

**Example 16** `TCS NQT pattern`

Find the next term: 1, 2, 6, 24, 120, ?

**Solution**

Ratios: $2 \div 1 = 2$,   $6 \div 2 = 3$,   $24 \div 6 = 4$,   $120 \div 24 = 5$. \
The multiplier is 2, 3, 4, 5, so next is 6. \
Next term $= 120 \times 6 = 720$. \
(These are the factorials $1!, 2!, 3!, 4!, 5!, 6!$.)

**➜ Answer: 720**

**Example 17** `Wipro pattern`

Find the next term: 2, 3, 5, 8, 13, 21, ?

**Solution**

Test "add the two terms before": \
$2 + 3 = 5$ ✓   $3 + 5 = 8$ ✓   $5 + 8 = 13$ ✓   $8 + 13 = 21$ ✓ \
Next term $= 13 + 21 = 34$.

**➜ Answer: 34**

**Example 18** `Accenture pattern`

Find the next term: 5, 10, 8, 16, 14, 28, ?

**Solution**

The series goes up, down, up, down. Check step by step: \
$5 \times 2 = 10$   $10 - 2 = 8$   $8 \times 2 = 16$   $16 - 2 = 14$   $14 \times 2 = 28$ \
Two rules take turns: $\times 2$, then $-2$. \
The last step used was $\times 2$, so now we subtract 2. \
Next term $= 28 - 2 = 26$.

**➜ Answer: 26**

**Example 19** `Infosys pattern`

Find the next term: 3, 20, 6, 17, 9, 14, 12, ?

**Solution**

The terms swing high and low, so split them. \
Positions 1, 3, 5, 7:   3, 6, 9, 12 --- add 3 each time. \
Positions 2, 4, 6, 8:   20, 17, 14, ? --- subtract 3 each time. \
The asked term is at position 8, so it belongs to the second series. \
Next term $= 14 - 3 = 11$.

**➜ Answer: 11**

---
💡 **SHORTCUT**

Interleaved series have a give-away shape: the terms zig-zag, and the number of terms is often even. Number the positions 1, 2, 3, … and read the odd ones and even ones as two separate lists.

**Example 20** `TCS NQT pattern`

One pair of letters is wrong: AZ, CX, EV, GT, IS

**Solution**

First letters: A $= 1$, C $= 3$, E $= 5$, G $= 7$, I $= 9$. Add 2. All correct. \
Second letters: Z $= 26$, X $= 24$, V $= 22$, T $= 20$, S $= 19$. \
Differences: $26-24 = 2$, $24-22 = 2$, $22-20 = 2$, but $20-19 = 1$ ✗ \
The rule is "subtract 2", so the fifth second letter should be $20 - 2 = 18$, which is R. \
So IS is wrong; it should be IR.

**➜ Answer: IS (it should be IR)**

---
⚠️ **TRAP**

Never count letters in your head past about J. Write the position numbers down. One slip of a single position turns a 20-second question into a wrong answer, and you will never notice it.

#### Practice — Tier 1 — Service *(target: 60 s/Q)*

+ 8, 15, 22, 29, ?
+ 3, 9, 27, 81, ?
+ 4, 5, 9, 18, 34, ?
+ 1, 3, 7, 15, 31, ?
+ 100, 96, 88, 76, 60, ?
+ One term is wrong: 6, 12, 21, 33, 46, 66. Which one?
+ Z, W, T, Q, ?
+ B2, D8, F18, H32, ?
+ 7, 14, 28, 56, ?
+ 2, 9, 28, 65, ?
+ Find the missing term: 11, 13, 17, 19, ?, 29
+ 144, 121, 100, 81, ?
+ 5, 6, 9, 14, 21, ?
+ AC, EG, IK, MO, ?
+ 1, 5, 14, 30, 55, ?

<details>
<summary><b>Answer key</b></summary>

+ **36** --- constant difference $+7$;   $29 + 7 = 36$.
+ **243** --- constant ratio $\times 3$;   $81 \times 3 = 243$.
+ **59** --- differences are $1, 4, 9, 16$ (squares); next $+25$;   $34 + 25 = 59$.
+ **63** --- rule $\times 2 + 1$;   $31 \times 2 + 1 = 63$.
+ **40** --- differences $-4, -8, -12, -16$; next $-20$;   $60 - 20 = 40$.
+ **46** --- differences should be $+6, +9, +12, +15, +18$; the fifth term must be $33 + 15 = 48$, not 46.
+ **N** --- positions $26, 23, 20, 17$, subtract 3;   $17 - 3 = 14$ → N.
+ **J50** --- letters B, D, F, H, J ($+2$); numbers $2 n^2$ give $2, 8, 18, 32, 50$.
+ **112** --- constant ratio $\times 2$;   $56 \times 2 = 112$.
+ **126** --- rule $n^3 + 1$;   $5^3 + 1 = 125 + 1 = 126$.
+ **23** --- consecutive primes: 11, 13, 17, 19, 23, 29.
+ **64** --- squares going down: $12^2, 11^2, 10^2, 9^2, 8^2$;   $8^2 = 64$.
+ **30** --- differences $1, 3, 5, 7$ (odd numbers); next $+9$;   $21 + 9 = 30$.
+ **QS** --- letter positions $(1,3), (5,7), (9,11), (13,15), (17,19)$ → Q, S.
+ **91** --- running sums of squares: $1, 1{+}4, 1{+}4{+}9, \dots$;   $55 + 36 = 91$.

## Tier 2 --- Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 21** `Grab · pattern`

A ride-hailing hub logs completed rides for five days: 120, 132, 156, 192, 240. If the pattern holds, how many rides on day 6?

**Solution**

Differences: $132 - 120 = 12$,   $156 - 132 = 24$,   $192 - 156 = 36$,   $240 - 192 = 48$. \
The differences are 12, 24, 36, 48 --- they grow by 12. \
Next difference $= 48 + 12 = 60$. \
Day 6 $= 240 + 60 = 300$.

**➜ Answer: 300 rides**

**Example 22** `Shopee · pattern`

Orders taken by a new seller in the first five weeks: 5, 11, 24, 51, 106. Predict week 6.

**Solution**

Try $\times 2$ and see what is left over: \
$5 \times 2 = 10$;   $11 - 10 = 1$ \
$11 \times 2 = 22$;   $24 - 22 = 2$ \
$24 \times 2 = 48$;   $51 - 48 = 3$ \
$51 \times 2 = 102$;   $106 - 102 = 4$ \
The leftover is 1, 2, 3, 4, so next it is 5. \
Week 6 $= 106 \times 2 + 5 = 212 + 5 = 217$.

**➜ Answer: 217 orders**

**Example 23** `DBS · pattern`

Find the next term: 4, 7, 12, 14, 36, 21, ?

**Solution**

The terms do not move smoothly, so split by position. \
Odd positions (1, 3, 5, 7):   4, 12, 36, ? \
  $12 \div 4 = 3$,   $36 \div 12 = 3$ → multiply by 3. \
Even positions (2, 4, 6):   7, 14, 21 → add 7. \
The asked term sits at position 7, which is odd. \
Next term $= 36 \times 3 = 108$.

**➜ Answer: 108**

---
⚠️ **TRAP**

In an interleaved series, count the position of the **missing** term before you compute. Students who read "the last given term was 21, so add 7" get 28 --- a distractor that is always offered.

**Example 24** `Agoda · pattern`

Weekly bookings were recorded as 3, 8, 18, 38, 78, 157, 318. One figure was typed wrongly. Which one?

**Solution**

Test the rule $\times 2 + 2$: \
$3 \times 2 + 2 = 8$ ✓ \
$8 \times 2 + 2 = 18$ ✓ \
$18 \times 2 + 2 = 38$ ✓ \
$38 \times 2 + 2 = 78$ ✓ \
$78 \times 2 + 2 = 158$, but the list shows 157 ✗ \
$158 \times 2 + 2 = 318$ ✓ --- the last figure fits the **corrected** value, which confirms the rule.

**➜ Answer: 157 (it should be 158)**

---
💡 **SHORTCUT**

In a wrong-term question, check the **term after** the suspect using the corrected value. If it fits, you have found the single error. If it does not, your rule is wrong, not the data.

**Example 25** `GIC · pattern`

Find the next term: 2, 12, 36, 80, 150, ?

**Solution**

The terms grow fast, so divide each one by $n^2$ and see what is left. \
  $2 \div 1^2 = 2 \div 1 = 2$   $12 \div 2^2 = 12 \div 4 = 3$   $36 \div 3^2 = 36 \div 9 = 4$ \
  $80 \div 4^2 = 80 \div 16 = 5$   $150 \div 5^2 = 150 \div 25 = 6$ \
The leftovers are 2, 3, 4, 5, 6 --- that is $n + 1$. So the rule should be $n^2 (n+1)$. Test it: \
  $n = 1$: $1^2 \times 2 = 2$ ✓ \
  $n = 2$: $2^2 \times 3 = 4 \times 3 = 12$ ✓ \
  $n = 3$: $3^2 \times 4 = 9 \times 4 = 36$ ✓ \
  $n = 4$: $4^2 \times 5 = 16 \times 5 = 80$ ✓ \
  $n = 5$: $5^2 \times 6 = 25 \times 6 = 150$ ✓ \
Rule: $n^2 (n+1)$. \
  $n = 6$: $6^2 \times 7 = 36 \times 7 = 252$.

**➜ Answer: 252**

**Example 26** `SCB · pattern`

Find the next term: 5, 7, 12, 19, 31, 50, ?

**Solution**

Differences: $7-5 = 2$,   $12-7 = 5$,   $19-12 = 7$,   $31-19 = 12$,   $50-31 = 19$. \
From the second one on, the differences 5, 7, 12, 19 are the earlier terms themselves. That is the sign of a Fibonacci rule, so test it. \
$5 + 7 = 12$ ✓   $7 + 12 = 19$ ✓   $12 + 19 = 31$ ✓   $19 + 31 = 50$ ✓ \
Next term $= 31 + 50 = 81$.

**➜ Answer: 81**

**Example 27** `LINE MAN · pattern`

Find the next term: J3, M9, P27, S81, ?

**Solution**

Letters: J $= 10$, M $= 13$, P $= 16$, S $= 19$. Add 3 each time. \
Next position $= 19 + 3 = 22$ → V. \
Numbers: $3, 9, 27, 81$; each is $\times 3$. \
Next number $= 81 \times 3 = 243$.

**➜ Answer: V243**

**Example 28** `Razer · pattern`

Find the next term: 1, 3, 8, 19, 42, 89, ?

**Solution**

Double each term and see the leftover: \
$1 \times 2 = 2$;   $3 - 2 = 1$ \
$3 \times 2 = 6$;   $8 - 6 = 2$ \
$8 \times 2 = 16$;   $19 - 16 = 3$ \
$19 \times 2 = 38$;   $42 - 38 = 4$ \
$42 \times 2 = 84$;   $89 - 84 = 5$ \
Leftovers 1, 2, 3, 4, 5, so next add 6. \
Next term $= 89 \times 2 + 6 = 178 + 6 = 184$.

**➜ Answer: 184**

**Example 29** `Sea · pattern`

A server's error count each hour follows 6, 11, 21, 41, 81, … . In which hour does the count first go above 1000?

**Solution**

Find the rule. $6 \times 2 = 12$, $12 - 1 = 11$ ✓. Test again: $11 \times 2 - 1 = 21$ ✓,   $21 \times 2 - 1 = 41$ ✓,   $41 \times 2 - 1 = 81$ ✓. \
Rule: $\times 2 - 1$. Now list the terms with their hour numbers. \
  hour 1: 6 \
  hour 2: 11 \
  hour 3: 21 \
  hour 4: 41 \
  hour 5: 81 \
  hour 6: $81 \times 2 - 1 = 162 - 1 = 161$ \
  hour 7: $161 \times 2 - 1 = 322 - 1 = 321$ \
  hour 8: $321 \times 2 - 1 = 642 - 1 = 641$ \
  hour 9: $641 \times 2 - 1 = 1282 - 1 = 1281$ \
1281 is the first value above 1000, and it happens in hour 9.

**➜ Answer: Hour 9 (count 1281)**

**Example 30** `Agoda · pattern`

Two terms are missing: 2, 4, 10, ?, 82, ?

**Solution**

Find the rule from the terms you have. \
$2 \times 3 = 6$,   $6 - 2 = 4$ ✓ \
$4 \times 3 = 12$,   $12 - 2 = 10$ ✓ \
Rule: $\times 3 - 2$. \
Fourth term $= 10 \times 3 - 2 = 30 - 2 = 28$. \
Check: $28 \times 3 - 2 = 84 - 2 = 82$ ✓ --- matches the given fifth term. \
Sixth term $= 82 \times 3 - 2 = 246 - 2 = 244$.

**➜ Answer: 28 and 244**

#### Practice — Tier 2 — Singapore & Thailand *(target: 100 s/Q)*

+ 9, 19, 40, 83, ?
+ Daily app installs: 50, 65, 95, 140, 200, ? (next day)
+ 4, 6, 12, 30, 90, ?
+ One figure is wrong: 5, 16, 49, 148, 447, 1336. Which one?
+ 2, 3, 7, 16, 32, ?
+ C5, F10, I17, L26, ?
+ 1, 2, 5, 26, ?
+ Monthly revenue in S$ thousands: 12, 18, 27, 40.5, ?
+ 3, 12, 27, 48, 75, ?
+ 7, 2, 14, 6, 28, 18, 56, ?
+ Find the missing term: 6, 13, ?, 59, 122
+ One pair is wrong: BD, FH, JL, NQ, RT. Which one?

<details>
<summary><b>Answer key</b></summary>

+ **170** --- rule $\times 2$ then add 1, 2, 3, 4;   $83 \times 2 + 4 = 166 + 4 = 170$.
+ **275** --- differences $15, 30, 45, 60$; next $+75$;   $200 + 75 = 275$.
+ **315** --- multipliers $1.5, 2, 2.5, 3, 3.5$;   $90 \times 3.5 = 315$.
+ **447** --- rule is $\times 3 + 1$;   $148 \times 3 + 1 = 445$, not 447. (And $445 \times 3 + 1 = 1336$ ✓.)
+ **57** --- differences $1, 4, 9, 16$ (squares); next $+25$;   $32 + 25 = 57$.
+ **O37** --- letters $+3$: C, F, I, L, O; numbers $n^2 + 1$ for $n = 2,3,4,5,6$: $5, 10, 17, 26, 37$.
+ **677** --- each term is $("previous")^2 + 1$;   $26^2 + 1 = 676 + 1 = 677$.
+ **60.75** --- constant ratio $\times 1.5$;   $40.5 \times 1.5 = 60.75$.
+ **108** --- terms are $3n^2$;   $3 \times 6^2 = 3 \times 36 = 108$.
+ **54** --- interleaved: odd places $\times 2$ (7, 14, 28, 56), even places $\times 3$ (2, 6, 18, 54); position 8 is even.
+ **28** --- rule $\times 2$ then add 1, 2, 3, 4;   $13 \times 2 + 2 = 28$, and $28 \times 2 + 3 = 59$ ✓.
+ **NQ** --- inside each pair the gap is $+2$ and pairs step by $+4$: B,D; F,H; J,L; N,**P**; R,T. So NQ should be NP.

## Tier 3 --- Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 31** `Google · pattern`

Find the next term:   1, 11, 21, 1211, 111221, ?

**Solution**

**Insight: the rule is not arithmetic at all. Each term describes the previous term out loud.**

Read term 1: "one 1" → write $1 1$ → term 2 is 11 ✓ \
Read term 2 (11): "two 1s" → write $2 1$ → term 3 is 21 ✓ \
Read term 3 (21): "one 2, one 1" → write $1 2, 1 1$ → term 4 is 1211 ✓ \
Read term 4 (1211): "one 1, one 2, two 1s" → $1 1, 1 2, 2 1$ → term 5 is 111221 ✓

Now read term 5: 111221. \
Break it into equal runs: $111 | 22 | 1$.
- three 1s → 3 1
- two 2s → 2 2
- one 1 → 1 1
Write them together: $3 1 space 2 2 space 1 1$ → 312211.

**➜ Answer: 312211**

---
⚠️ **TRAP**

No difference or ratio will ever crack this series. If the term lengths jump wildly (1 digit, 2, 2, 4, 6) and the digits stay small, stop doing arithmetic and start **describing**.

**Example 32** `Amazon · pattern`

The series is 1, 2, 4, 8, 15, 26, 42, … . Find the 10th term.

**Solution**

**Insight: it looks like doubling but breaks at 15. Take differences twice; when a difference row becomes an AP, the series is fixed forever and you only need to extend rows.**

Terms:   1, 2, 4, 8, 15, 26, 42 \
First differences:   $2-1 = 1$,   $4-2 = 2$,   $8-4 = 4$,   $15-8 = 7$,   $26-15 = 11$,   $42-26 = 16$ \
So: 1, 2, 4, 7, 11, 16 \
Second differences:   $2-1 = 1$,   $4-2 = 2$,   $7-4 = 3$,   $11-7 = 4$,   $16-11 = 5$ \
So: 1, 2, 3, 4, 5 --- a clean AP. Extend it: 6, 7, 8.

Rebuild the first-difference row: \
after 16 comes $16 + 6 = 22$, then $22 + 7 = 29$, then $29 + 8 = 37$. \
First differences: 1, 2, 4, 7, 11, 16, 22, 29, 37.

Rebuild the terms: \
term 8 $= 42 + 22 = 64$ \
term 9 $= 64 + 29 = 93$ \
term 10 $= 93 + 37 = 130$

Cross-check with a formula. Constant third differences mean the terms fit a cubic. The cubic through the first four terms is $a_n = (n^3 - 3n^2 + 8n)/6$. \
Test $n = 5$: $(125 - 75 + 40)/6 = 90/6 = 15$ ✓ \
Test $n = 10$: $(1000 - 300 + 80)/6 = 780/6 = 130$ ✓

**➜ Answer: 130**

**Example 33** `Goldman Sachs · pattern`

The series 1, 3, 6, 10, 15, … continues in the same way. Find the sum of its first 20 terms.

**Solution**

**Insight: adding up 20 terms one by one is slow and error-prone. Recognise the terms as triangular numbers and use the closed sum.**

Differences: $3-1 = 2$, $6-3 = 3$, $10-6 = 4$, $15-10 = 5$. So term $k$ = $1+2+\dots.c+k$, the triangular number
$ T_k = (k(k+1))/2 $
Now sum them:
$ sum_(k=1)^n T_k = sum_(k=1)^n (k^2 + k)/2 = 1/2 sum_(k=1)^n k^2 + 1/2 sum_(k=1)^n k $
Put in the two standard sums:
$ = 1/2 dot (n(n+1)(2n+1))/6 + 1/2 dot (n(n+1))/2 = (n(n+1))/4 [ (2n+1)/3 + 1 ] $
Inside the bracket, $ (2n+1)/3 + 1 = (2n+1+3)/3 = (2n+4)/3 = (2(n+2))/3 $
So
$ (n(n+1))/4 dot (2(n+2))/3 = (2 n(n+1)(n+2))/12 = (n(n+1)(n+2))/6 $
Now put $n = 20$:
$ (20 \times 21 \times 22)/6 $
$20 \times 21 = 420$.   $420 \times 22 = 9240$.   $9240 \div 6 = 1540$.

**➜ Answer: 1540**

---
💡 **SHORTCUT**

Memorise the three-in-a-row: sum of the first $n$ whole numbers is $(n(n+1))/2$; sum of the first $n$ triangular numbers is $(n(n+1)(n+2))/6$. The pattern of factors just grows by one more bracket.

**Example 34** `Microsoft · pattern`

A series starts $a_1 = 3$ and follows $a_(n+1) = a_n^2 - 2 a_n + 2$. Find $a_5$.

**Solution**

**Insight: the rule is almost a perfect square. Shift the whole series by 1 and the mess disappears.**

Write the rule and subtract 1 from both sides:
$ a_(n+1) - 1 = a_n^2 - 2 a_n + 1 = (a_n - 1)^2 $
Let $b_n = a_n - 1$. Then $b_(n+1) = b_n^2$ --- just keep squaring.

$b_1 = a_1 - 1 = 3 - 1 = 2$ \
$b_2 = 2^2 = 4$ \
$b_3 = 4^2 = 16$ \
$b_4 = 16^2 = 256$ \
$b_5 = 256^2 = 65536$

So $a_5 = b_5 + 1 = 65536 + 1 = 65537$.

Check the first few directly: \
$a_2 = 3^2 - 2(3) + 2 = 9 - 6 + 2 = 5$, and $b_2 + 1 = 4 + 1 = 5$ ✓ \
$a_3 = 5^2 - 2(5) + 2 = 25 - 10 + 2 = 17$, and $b_3 + 1 = 16 + 1 = 17$ ✓ \
$a_4 = 17^2 - 2(17) + 2 = 289 - 34 + 2 = 257$, and $b_4 + 1 = 256 + 1 = 257$ ✓

**➜ Answer: 65537**

**Example 35** `D. E. Shaw · pattern`

A series has $a_1 = 5$, $a_2 = 7$, and $a_(n+2) = a_(n+1) - a_n$. Find $a_100$.

**Solution**

**Insight: a "subtract the earlier term" rule always repeats with period 6. Never compute 100 terms --- find the cycle, then use a remainder.**

$a_1 = 5$ \
$a_2 = 7$ \
$a_3 = 7 - 5 = 2$ \
$a_4 = 2 - 7 = -5$ \
$a_5 = -5 - 2 = -7$ \
$a_6 = -7 - (-5) = -7 + 5 = -2$ \
$a_7 = -2 - (-7) = -2 + 7 = 5$ ← same as $a_1$ \
$a_8 = 5 - (-2) = 5 + 2 = 7$ ← same as $a_2$

So the block $5, 7, 2, -5, -7, -2$ repeats every 6 terms. \
Now reduce 100 modulo 6. $6 \times 16 = 96$, and $100 - 96 = 4$. \
So $a_100 = a_4 = -5$.

**➜ Answer: $-5$**

**Example 36** `Adobe · pattern`

A letter series runs A, B, D, G, K, P, … . Find the 7th term, and decide whether the letter Z ever appears.

**Solution**

**Insight: turn letters into positions immediately. The "gap" row is the real series.**

Positions: A $= 1$, B $= 2$, D $= 4$, G $= 7$, K $= 11$, P $= 16$. \
Gaps: $2-1 = 1$,   $4-2 = 2$,   $7-4 = 3$,   $11-7 = 4$,   $16-11 = 5$. \
The gaps are 1, 2, 3, 4, 5, so the next gap is 6. \
7th position $= 16 + 6 = 22$ → V.

Now the general term. Position of the $n$-th letter is
$ p_n = 1 + (1 + 2 + \dots.c + (n-1)) = 1 + ((n-1)n)/2 $
Check: $n = 6$ gives $1 + (5 \times 6)/2 = 1 + 15 = 16$ ✓ (P).

Z sits at position 26. Set $p_n = 26$:
$ 1 + ((n-1)n)/2 = 26 arrow.r.double (n-1)n = 50 $
Consecutive whole numbers with product 50? $6 \times 7 = 42$ and $7 \times 8 = 56$. Nothing gives 50. \
So no term lands on 26. The series steps from $n = 7$ (position 22, V) straight to $n = 8$ (position $1 + (7 \times 8)/2 = 1 + 28 = 29$), which has already run past Z.

**➜ Answer: 7th term is V; Z never appears**

**Example 37** `Uber · pattern`

A driver's bonus, in dollars, for successive trips is $1, 1/2, 1/4, 1/8, …$ . (a) If this went on for ever, what is the total? (b) How many trips are needed for the running total to go above 1.99?

**Solution**

**Insight: this is a GP with $r = 1/2$. The partial sum is always "the limit minus one more halving", so part (b) becomes a powers-of-2 question.**

(a) $a = 1$, $r = 1/2$, $|r| < 1$, so
$ S_infinity = a/(1-r) = 1/(1 - 1/2) = 1/(1/2) = 2 $

(b) Sum of the first $n$ terms:
$ S_n = a(1 - r^n)/(1 - r) = (1 - (1/2)^n)/(1/2) = 2(1 - 1/2^n) = 2 - 2/2^n = 2 - 1/2^(n-1) $
We need $S_n > 1.99$:
$ 2 - 1/2^(n-1) > 1.99 arrow.r.double 1/2^(n-1) < 0.01 arrow.r.double 2^(n-1) > 100 $
Powers of 2: $2^6 = 64$ (not enough), $2^7 = 128 > 100$ ✓ \
So $n - 1 \\ge 7$, giving $n = 8$.

Verify both sides of the boundary: \
$n = 7$: $S_7 = 2 - 1/2^6 = 2 - 1/64 = 2 - 0.015625 = 1.984375$ --- below 1.99. \
$n = 8$: $S_8 = 2 - 1/2^7 = 2 - 1/128 = 2 - 0.0078125 = 1.9921875$ --- above 1.99 ✓

**➜ Answer: (a) 2   (b) 8 trips**

**Example 38** `Amazon · pattern`

A series is built by $a_1 = 4$ and $a_(n+1) = 3 a_n + 2^n$. Find $a_6$, and show that every term is even.

**Solution**

**Insight: the rule mixes a multiplier with a moving add-on. Compute term by term, and prove the "even" claim by induction, not by checking a few terms.**

$a_1 = 4$ \
$a_2 = 3(4) + 2^1 = 12 + 2 = 14$ \
$a_3 = 3(14) + 2^2 = 42 + 4 = 46$ \
$a_4 = 3(46) + 2^3 = 138 + 8 = 146$ \
$a_5 = 3(146) + 2^4 = 438 + 16 = 454$ \
$a_6 = 3(454) + 2^5 = 1362 + 32 = 1394$

**Why every term is even.** \
Base step: $a_1 = 4$, which is even. \
Inductive step: suppose $a_n$ is even, say $a_n = 2m$ for a whole number $m$. Then
$ a_(n+1) = 3(2m) + 2^n = 6m + 2^n = 2(3m + 2^(n-1)) $
For every $n \\ge 1$, $2^(n-1)$ is a whole number, so $a_(n+1)$ is 2 times a whole number --- even. \
Since $a_1$ is even and "even ⟶ next is even", **all** terms are even.

**➜ Answer: $a_6 = 1394$; all terms are even**

#### Practice — Tier 3 — Product *(target: 4 min/Q)*

+ Find the next term: 1, 11, 21, 1211, 111221, 312211, ?
+ For the series 1, 2, 4, 8, 15, 26, 42, … find the 12th term.
+ A series has $a_1 = 2$, $a_2 = 5$ and $a_(n+2) = a_(n+1) - a_n$. Find $a_2025$.
+ Find the sum of the first 15 terms of 1, 3, 6, 10, 15, … .
+ A series has $a_1 = 5$ and $a_(n+1) = a_n^2 - 4 a_n + 6$. Find $a_4$.
+ Find the next letter: A, C, F, J, O, ?
+ For the series $1, 1/3, 1/9, 1/27, \dots$, how many terms are needed before the running total first goes above 1.49?
+ Find the 10th term of 1, 4, 10, 20, 35, 56, … .

<details>
<summary><b>Answer key</b></summary>

+ **13112221** --- read 312211 in runs: $3|1|22|11$ → "one 3, one 1, two 2s, two 1s" → $1 3, 1 1, 2 2, 2 1$.
+ **232** --- extend the difference rows. First differences continue $22, 29, 37, 46, 56$; terms continue $64, 93, 130, 176, 232$. Check with $a_n = (n^3 - 3n^2 + 8n)/6$: $(1728 - 432 + 96)/6 = 1392/6 = 232$ ✓.
+ **3** --- the rule repeats with period 6: $2, 5, 3, -2, -5, -3$, then $2$ again. Since $2025 = 6 \times 337 + 3$, $a_2025 = a_3 = 3$. And $a_3 = 5 - 2 = 3$.
+ **680** --- these are triangular numbers, and $T_1 + \dots.c + T_n = (n(n+1)(n+2))/6$. With $n = 15$: $(15 \times 16 \times 17)/6 = 4080/6 = 680$.
+ **6563** --- subtract 2: $a_(n+1) - 2 = a_n^2 - 4 a_n + 4 = (a_n - 2)^2$. With $b_n = a_n - 2$: $b_1 = 3$, $b_2 = 9$, $b_3 = 81$, $b_4 = 6561$. So $a_4 = 6561 + 2 = 6563$.
+ **U** --- positions 1, 3, 6, 10, 15 with gaps 2, 3, 4, 5; next gap 6 gives $15 + 6 = 21$ → U.
+ **5 terms** --- $S_n = (3/2)(1 - 1/3^n)$. Need $1 - 1/3^n > 0.99333$, i.e. $3^n > 150$, so $n = 5$ ($3^4 = 81$, $3^5 = 243$). Check: $S_4 = 1.5 \times 80/81 = 1.4815$ (too small); $S_5 = 1.5 \times 242/243 = 1.4938 > 1.49$ ✓.
+ **220** --- differences are the triangular numbers 3, 6, 10, 15, 21, so term $n$ is $(n(n+1)(n+2))/6$. With $n = 10$: $(10 \times 11 \times 12)/6 = 1320/6 = 220$.

## Mixed set --- exam conditions

#### Practice — Tier 1 — Service *(target: 25 minutes for all 20)*

+ 12, 17, 23, 30, ?
+ 3, 4, 8, 17, 33, ?
+ D, H, L, P, ?
+ 6, 12, 24, 48, ?
+ One term is wrong: 7, 14, 28, 55, 112. Which one?
+ 1, 4, 27, 256, ?
+ A2, D6, G12, J20, ?
+ 1000, 200, 40, 8, ?
+ 5, 12, 26, 54, ?
+ Find the missing term: 4, 9, ?, 34, 54
+ 2, 6, 12, 20, 30, ?
+ A series has $a_1 = 1$, $a_2 = 1$ and $a_(n+2) = a_(n+1) - a_n$. Find $a_50$.
+ 13, 16, 22, 31, 43, ?
+ ZY, WV, TS, QP, ?
+ 3, 7, 16, 35, 74, ?
+ Find the sum of the first 12 terms of 1, 3, 6, 10, 15, … .
+ 1, 11, 21, 1211, ?
+ 2, 100, 4, 95, 8, 90, 16, ?
+ 121, 144, 169, 196, ?
+ One term is wrong: 2, 6, 12, 20, 30, 44. Which one?

<details>
<summary><b>Answer key</b></summary>

+ **38** --- differences 5, 6, 7; next $+8$; $30 + 8 = 38$.
+ **58** --- differences 1, 4, 9, 16 (squares); next $+25$; $33 + 25 = 58$.
+ **T** --- positions 4, 8, 12, 16 ($+4$); $16 + 4 = 20$ → T.
+ **96** --- constant ratio $\times 2$; $48 \times 2 = 96$.
+ **55** --- the rule is $\times 2$: 7, 14, 28, 56, 112. The fourth term should be 56.
+ **3125** --- terms are $n^n$: $1^1, 2^2, 3^3, 4^4, 5^5 = 3125$.
+ **M30** --- letters $+3$ (A, D, G, J, M); numbers $n(n+1)$: 2, 6, 12, 20, 30.
+ **1.6** --- constant ratio $\div 5$; $8 \div 5 = 1.6$.
+ **110** --- rule $\times 2 + 2$; $54 \times 2 + 2 = 110$.
+ **19** --- differences 5, 10, 15, 20; $9 + 10 = 19$, and $19 + 15 = 34$ ✓.
+ **42** --- terms are $n(n+1)$; $6 \times 7 = 42$.
+ **1** --- period 6: $1, 1, 0, -1, -1, 0$. $50 = 6 \times 8 + 2$, so $a_50 = a_2 = 1$.
+ **58** --- differences 3, 6, 9, 12; next $+15$; $43 + 15 = 58$.
+ **NM** --- pairs are $(26,25), (23,22), (20,19), (17,16)$, so next is $(14,13)$ → N, M.
+ **153** --- rule $\times 2$ then add 1, 2, 3, 4, 5; $74 \times 2 + 5 = 153$.
+ **364** --- triangular numbers; $(12 \times 13 \times 14)/6 = 2184/6 = 364$.
+ **111221** --- read 1211 aloud: "one 1, one 2, two 1s".
+ **85** --- interleaved: odd places $\times 2$ (2, 4, 8, 16); even places $-5$ (100, 95, 90, 85); position 8 is even.
+ **225** --- squares of 11, 12, 13, 14, 15; $15^2 = 225$.
+ **44** --- terms should be $n(n+1)$: 2, 6, 12, 20, 30, 42. The sixth term should be 42.

## 📋 One-page revision card

**The 5-step attack**

+ Differences constant? → AP.
+ Second differences constant? → quadratic; keep extending the difference row.
+ Ratios constant, or growing as $\times 2, \times 3, \times 4$? → GP or growing-multiplier.
+ Near $n^2$, $n^3$, $n!$, $n(n+1)$, or the primes?
+ Zig-zag shape? → alternating rules, or two interleaved series (split odd and even positions).

**Rules to recognise on sight**

#table(columns: 2,
[$+d$ / $\times r$ constant], [3, 7, 11, 15   /   2, 6, 18, 54],
[growing difference / multiplier], [7, 12, 19, 28, 39   /   3, 6, 18, 72],
[$\times 2 + c$ with $c$ growing], [4, 9, 20, 43, 90],
[$n^2$ / $n^2 plus.minus 1$], [1, 4, 9, 16 / 2, 5, 10, 17],
[$n^3$ / $n^3 plus.minus 1$], [1, 8, 27, 64 / 2, 9, 28, 65],
[$n(n+1)$], [2, 6, 12, 20, 30],
[$n^2(n+1)$], [2, 12, 36, 80, 150],
[factorial], [1, 2, 6, 24, 120, 720],
[Fibonacci type], [5, 7, 12, 19, 31, 50],
[square previous], [1, 2, 5, 26, 677],
[look-and-say], [1, 11, 21, 1211, 111221],
)

**Formulas**

- AP: $a_n = a + (n-1)d$;   $S_n = n/2[2a + (n-1)d]$
- GP: $a_n = a r^(n-1)$;   $S_n = (a(r^n - 1))/(r-1)$;   $S_infinity = a/(1-r)$ for $|r|<1$
- $sum n = (n(n+1))/2$   $sum n^2 = (n(n+1)(2n+1))/6$   $sum n^3 = ((n(n+1))/2)^2$
- Triangular: $T_k = (k(k+1))/2$;   $sum_(k=1)^n T_k = (n(n+1)(n+2))/6$
- Periodic rule $a_(n+2) = a_(n+1) - a_n$ always repeats with period **6**.

**Shortcuts**

- Extend the difference row instead of fitting a formula. Faster, safer.
- Missing middle term: build it from the left, then test it against the right.
- Wrong-term question: correct the suspect, then check that the **next** term now fits.
- Letters → numbers (EJOTY: E5, J10, O15, T20, Y25) → solve → back to letters.
- Huge term index (like the 100th or 2025th term)? Look for a repeating cycle, then divide and take the remainder.

**Top 5 traps**

+ "Which term is wrong" $\\ne$ "what should it be". Two different numbers.
+ In an interleaved series, check the **position number** of the asked term first.
+ 1, 4, 9, 16 may be the terms themselves **or** the differences. Test both.
+ Counting letters in your head. Write the positions down, always.
+ Remainder work: for period 6, a remainder of 0 means the **6th** term, not the 1st.

</details>

</details>

</details>

</details>
