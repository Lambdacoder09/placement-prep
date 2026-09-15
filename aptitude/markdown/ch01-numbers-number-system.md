# Chapter 1 — Numbers & Number System

*Divisibility, HCF–LCM, remainders, digits, factorials*

## What you need to know

**WHAT YOU NEED TO KNOW**

**Divisibility tests.**
#table(columns: 4,
  [**By**], [**Test**], [**By**], [**Test**],
  [2], [last digit even], [9], [digit sum divisible by 9],
  [3], [digit sum divisible by 3], [10], [last digit 0],
  [4], [last 2 digits divisible by 4], [11], [(sum of odd-place digits) $-$ (sum of even-place digits) divisible by 11],
  [5], [last digit 0 or 5], [12], [divisible by 3 **and** by 4],
  [6], [divisible by 2 **and** by 3], [25], [last 2 digits divisible by 25],
  [7], [drop last digit, subtract twice it, repeat], [8], [last 3 digits divisible by 8],
)

**Factors.** If $N = p^a dot q^b dot r^c$ (distinct primes $p, q, r$):
- Number of factors $= (a+1)(b+1)(c+1)$
- Sum of factors $= ((p^(a+1)-1)/(p-1)) dot ((q^(b+1)-1)/(q-1)) dot ((r^(c+1)-1)/(r-1))$
- Product of all factors $= N^(d/2)$, where $d$ = number of factors
- Odd factors: count with the power of 2 removed. Even factors = total $-$ odd.
- Factors that are perfect squares: count only even exponents $0, 2, 4, \dots$

**HCF and LCM.**
- For two numbers: $"HCF" \times "LCM" = "product of the two numbers"$
- $"HCF of fractions" = ("HCF of numerators")/("LCM of denominators")$
- $"LCM of fractions" = ("LCM of numerators")/("HCF of denominators")$
- Largest number dividing $a, b, c$ leaving the **same** remainder $= "HCF"(b-a, c-b, c-a)$
- Largest number dividing $a, b$ leaving remainders $r_1, r_2 = "HCF"(a-r_1, b-r_2)$
- Smallest number leaving remainder $r$ with each of $a, b, c$ $= "LCM"(a,b,c) + r$

**Remainders.**
- $(a \times b) mod n = ((a mod n) \times (b mod n)) mod n$
- Use negatives: if $a equiv -1 (mod n)$ then $a^"even" equiv 1$ and $a^"odd" equiv -1 equiv n-1$
- Fermat: if $p$ is prime and $p$ does not divide $a$, then $a^(p-1) equiv 1 (mod p)$
- Euler: $a^phi(n) equiv 1 (mod n)$ when HCF$(a,n)=1$; $phi(n) = n product (1 - 1/p)$

**Unit digit (cyclicity).**
#table(columns: 6,
  [**Last digit**], [0, 1, 5, 6], [4, 9], [2], [3, 7], [8],
  [**Cycle length**], [1], [2], [4], [4], [4],
)
Rule: divide the power by 4. If remainder is $1,2,3$ take that term of the cycle. If remainder is **0**, take the **4th** term.

**Last two digits.**
- Ends in 1: tens digit of answer $=$ (tens digit of base $\times$ unit digit of power) mod 10; unit digit is 1.
- $2^20 equiv 76$, $76^k equiv 76 (mod 100)$ for every $k \\ge 1$.
- $7^4 = 2401 arrow.r$ last two digits of $7^n$ repeat with period 4.

**Factorials.**
- Highest power of a prime $p$ in $n! = floor(n/p) + floor(n/p^2) + floor(n/p^3) + \dots$
- Trailing zeros of $n! = floor(n/5) + floor(n/25) + floor(n/125) + \dots$
- For a composite $m = p^alpha q^beta$, find each prime power, divide by its exponent, take the minimum.

**Base systems.** $(d_k \dots d_1 d_0)_b = d_k b^k + \dots + d_1 b + d_0$. To convert a decimal number to base $b$, divide repeatedly by $b$ and read remainders bottom-up.

**Useful counts.** Numbers from 1 to $N$ divisible by $d$ is $floor(N/d)$. Divisible by $a$ or $b$ is $floor(N/a) + floor(N/b) - floor(N/"LCM"(a,b))$.

## Warm-up

### Warm-up

**Example 1**

Is $453,672$ divisible by 8?

**Solution**

Test for 8: look at the last three digits only.
Last three digits $= 672$.
$672 \div 8 = 84$, exact.
So yes.

**➜ Answer: Yes**

**Example 2**

Find the unit digit of $7^35$.

**Solution**

Cycle of 7: $7, 9, 3, 1$ then repeat. Cycle length 4.
$35 \div 4 = 8$ remainder $3$.
Remainder 3 $arrow.r$ take the 3rd term of the cycle $= 3$.

**➜ Answer: 3**

**Example 3**

Find the HCF and the LCM of 24 and 36.

**Solution**

$24 = 2^3 \times 3$
$36 = 2^2 \times 3^2$
HCF = lowest power of each common prime $= 2^2 \times 3 = 12$.
LCM = highest power of each prime $= 2^3 \times 3^2 = 8 \times 9 = 72$.
Check: $12 \times 72 = 864$ and $24 \times 36 = 864$. Matches.

**➜ Answer: HCF $= 12$, LCM $= 72$**

**Example 4**

How many factors does 360 have?

**Solution**

$360 = 36 \times 10 = (2^2 \times 3^2) \times (2 \times 5) = 2^3 \times 3^2 \times 5^1$.
Number of factors $= (3+1)(2+1)(1+1) = 4 \times 3 \times 2 = 24$.

**➜ Answer: 24**

**Example 5**

How many zeros are at the end of $30!$?

**Solution**

Count the 5s.
$floor(30/5) = 6$
$floor(30/25) = 1$
$floor(30/125) = 0$, stop.
Total $= 6 + 1 = 7$.

**➜ Answer: 7**

**Example 6**

Find the remainder when $2^10$ is divided by 7.

**Solution**

$2^3 = 8 = 7 + 1$, so $2^3 equiv 1 (mod 7)$.
$2^10 = 2^9 \times 2 = (2^3)^3 \times 2$.
$(2^3)^3 equiv 1^3 = 1$.
So $2^10 equiv 1 \times 2 = 2 (mod 7)$.

**➜ Answer: 2**

**Example 7**

Write the decimal number 45 in base 2.

**Solution**

$45 \div 2 = 22$ remainder $1$
$22 \div 2 = 11$ remainder $0$
$11 \div 2 = 5$ remainder $1$
$5 \div 2 = 2$ remainder $1$
$2 \div 2 = 1$ remainder $0$
$1 \div 2 = 0$ remainder $1$
Read remainders bottom-up: $101101$.
Check: $32 + 0 + 8 + 4 + 0 + 1 = 45$. Correct.

**➜ Answer: $(101101)_2$**

**Example 8**

Is $100,001$ divisible by 11?

**Solution**

Digits, from the right: $1, 0, 0, 0, 0, 1$.
Odd places (1st, 3rd, 5th from right): $1 + 0 + 0 = 1$.
Even places (2nd, 4th, 6th): $0 + 0 + 1 = 1$.
Difference $= 1 - 1 = 0$, and 0 is divisible by 11.
So yes. Check: $11 \times 9091 = 100,001$.

**➜ Answer: Yes**

## Tier 1 — Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

What is the smallest number that must be added to $5,432$ to make it divisible by 9?

**(a)** [2]  **(b)** [4]  **(c)** [5]  **(d)** [7]

**Solution**

Digit sum of $5432 = 5 + 4 + 3 + 2 = 14$.
The next multiple of 9 after 14 is 18.
$18 - 14 = 4$.
So add 4. New number $= 5436$, digit sum $= 5+4+3+6 = 18$, divisible by 9.

**➜ Answer: (b) 4**

**Example 10** `Infosys pattern`

Three bells ring at intervals of 12, 18 and 30 minutes. They ring together at 9:00 am. At what time do they next ring together?

**Solution**

They meet again after LCM(12, 18, 30) minutes.
$12 = 2^2 \times 3$
$18 = 2 \times 3^2$
$30 = 2 \times 3 \times 5$
LCM $= 2^2 \times 3^2 \times 5 = 4 \times 9 \times 5 = 180$ minutes.
$180$ minutes $= 3$ hours.
$9:00$ am $+ 3$ h $= 12:00$ noon.

**➜ Answer: 12:00 noon**

**Example 11** `Accenture pattern`

Find the largest number that divides 400 and 556 leaving remainders 4 and 6 respectively.

**Solution**

If the number divides 400 leaving remainder 4, it divides $400 - 4 = 396$ exactly.
If it divides 556 leaving remainder 6, it divides $556 - 6 = 550$ exactly.
So we want HCF(396, 550).
$396 = 2^2 \times 3^2 \times 11$
$550 = 2 \times 5^2 \times 11$
Common primes: $2^1$ and $11^1$.
HCF $= 2 \times 11 = 22$.
Check: $400 = 22 \times 18 + 4$. And $556 = 22 \times 25 + 6$. Both correct.

**➜ Answer: 22**

---
💡 **SHORTCUT**

"Leaves remainder $r$" $arrow.r$ subtract $r$ first, then take the HCF.
"Leaves the **same** unknown remainder" $arrow.r$ take the HCF of the **differences** of the numbers. You never need to know the remainder.

**Example 12** `Wipro pattern`

How many factors of 1080 are odd? How many are even?

**Solution**

$1080 = 8 \times 135 = 2^3 \times (27 \times 5) = 2^3 \times 3^3 \times 5^1$.
Total factors $= (3+1)(3+1)(1+1) = 4 \times 4 \times 2 = 32$.
Odd factors have no 2 in them. Remove the 2s: odd part is $3^3 \times 5$.
Odd factors $= (3+1)(1+1) = 4 \times 2 = 8$.
Even factors $= 32 - 8 = 24$.

**➜ Answer: 8 odd, 24 even**

**Example 13** `TCS NQT pattern`

Find the unit digit of $137^59 \times 242^43$.

**Solution**

Only the last digits matter: $7^59 \times 2^43$.
Step 1: $7^59$. Cycle of 7 is $7, 9, 3, 1$ (length 4).
$59 \div 4 = 14$ remainder $3$ $arrow.r$ 3rd term $= 3$.
Step 2: $2^43$. Cycle of 2 is $2, 4, 8, 6$ (length 4).
$43 \div 4 = 10$ remainder $3$ $arrow.r$ 3rd term $= 8$.
Step 3: multiply the unit digits: $3 \times 8 = 24$, unit digit $4$.

**➜ Answer: 4**

---
⚠️ **TRAP**

Cyclicity remainder $0$ does **not** mean "take the 0th term". It means the power lands exactly at the **end** of a cycle, so take the **4th** term. For $2^40$: $40 \div 4$ gives remainder 0, so the unit digit is 6, not 2.

**Example 14** `Capgemini pattern`

Find the remainder when $2^89$ is divided by 7.

**Solution**

$2^3 = 8$, and $8 = 7 \times 1 + 1$, so $2^3 equiv 1 (mod 7)$.
Write 89 in terms of 3: $89 = 3 \times 29 + 2$.
$2^89 = (2^3)^29 \times 2^2$.
$(2^3)^29 equiv 1^29 = 1$.
So $2^89 equiv 1 \times 4 = 4 (mod 7)$.

**➜ Answer: 4**

**Example 15** `Cognizant pattern`

How many zeros does $125!$ end with?

**Solution**

Count the number of 5s in $125!$.
$floor(125/5) = 25$
$floor(125/25) = 5$
$floor(125/125) = 1$
$floor(125/625) = 0$, stop.
Total $= 25 + 5 + 1 = 31$.
There are far more 2s than 5s, so 5s decide the answer.

**➜ Answer: 31**

---
⚠️ **TRAP**

A common slip is to answer $floor(125/5) = 25$ and stop. Every multiple of 25 gives an **extra** 5, and 125 gives one more. Keep dividing until the quotient is 0.

**Example 16** `Infosys pattern`

Find the HCF and the LCM of $3/4$, $9/10$ and $6/7$.

**Solution**

HCF of fractions $=$ HCF of numerators $\div$ LCM of denominators.
HCF$(3, 9, 6) = 3$.
LCM$(4, 10, 7)$: $4 = 2^2$, $10 = 2 \times 5$, $7 = 7$. LCM $= 2^2 \times 5 \times 7 = 140$.
So HCF $= 3/140$.
LCM of fractions $=$ LCM of numerators $\div$ HCF of denominators.
LCM$(3, 9, 6) = 18$.
HCF$(4, 10, 7) = 1$.
So LCM $= 18/1 = 18$.

**➜ Answer: HCF $= 3/140$, LCM $= 18$**

---
⚠️ **TRAP**

Do not swap the two rules. HCF of fractions has HCF **on top**. LCM of fractions has LCM **on top**. The answer must satisfy: HCF is the smallest of the three or smaller, LCM is the largest or larger. Use that as your check.

**Example 17** `TCS NQT pattern`

Find the smallest number which, when divided by 12, 15 and 18, leaves remainder 7 in each case.

**Solution**

First find the smallest number divisible by all three.
$12 = 2^2 \times 3$, $15 = 3 \times 5$, $18 = 2 \times 3^2$.
LCM $= 2^2 \times 3^2 \times 5 = 180$.
Now add the common remainder: $180 + 7 = 187$.
Check: $187 = 12 \times 15 + 7$. $187 = 15 \times 12 + 7$. $187 = 18 \times 10 + 7$. All correct.

**➜ Answer: 187**

**Example 18** `Accenture pattern`

Convert $(1101101)_2$ to decimal, then write that decimal number in base 8.

**Solution**

Step 1 — binary to decimal. Place values from the right: $1, 2, 4, 8, 16, 32, 64$.
Digits from the right: $1, 0, 1, 1, 0, 1, 1$.
$= 1 \times 1 + 0 \times 2 + 1 \times 4 + 1 \times 8 + 0 \times 16 + 1 \times 32 + 1 \times 64$
$= 1 + 0 + 4 + 8 + 0 + 32 + 64 = 109$.
Step 2 — decimal to base 8.
$109 \div 8 = 13$ remainder $5$
$13 \div 8 = 1$ remainder $5$
$1 \div 8 = 0$ remainder $1$
Read bottom-up: $155$.
Check: $1 \times 64 + 5 \times 8 + 5 = 64 + 40 + 5 = 109$. Correct.

**➜ Answer: $109$ in decimal; $(155)_8$**

---
💡 **SHORTCUT**

Binary to octal in one move: group the binary digits in 3s from the right.
$1101101 arrow.r 1 | 101 | 101 arrow.r 1, 5, 5 arrow.r (155)_8$. No decimal step needed.

**Example 19** `Wipro pattern`

Find the unit digit of $1! + 2! + 3! + \dots + 100!$.

**Solution**

$5! = 120$ ends in 0. Every factorial after that contains both a 2 and a 5, so all of $5!, 6!, \dots, 100!$ end in 0.
They add nothing to the unit digit.
So only the first four matter:
$1! = 1$
$2! = 2$
$3! = 6$
$4! = 24$
$1 + 2 + 6 + 24 = 33$.
Unit digit $= 3$.

**➜ Answer: 3**

**Example 20** `Capgemini pattern`

The four-digit number $523x$ is divisible by 6. Find all possible digits $x$.

**Solution**

Divisible by 6 means divisible by 2 **and** by 3.
By 2: $x$ must be even, so $x in {0, 2, 4, 6, 8}$.
By 3: digit sum $= 5 + 2 + 3 + x = 10 + x$ must be a multiple of 3.
$10 + x in {12, 15, 18} arrow.r x in {2, 5, 8}$.
Both conditions: $x in {2, 8}$.
Check: $5232 \div 6 = 872$. $5238 \div 6 = 873$. Both exact.

**➜ Answer: $x = 2$ or $x = 8$**

#### Practice — Tier 1 — Service *(target: 60 s/Q)*

+ Find the unit digit of $43^17$.
+ Find the HCF of 96 and 144.
+ Find the LCM of 16, 24 and 40.
+ How many factors does 540 have?
+ How many zeros does $60!$ end with?
+ What is the smallest number that must be subtracted from $3,105$ to make it divisible by 11?
+ Find the remainder when $5^40$ is divided by 6.
+ Two numbers are in the ratio $3 : 4$ and their LCM is 84. Find the two numbers and their HCF.
+ Find the sum of all factors of 200.
+ Convert $(237)_8$ to decimal.
+ Find the least number which when divided by 8, 12 and 16 leaves remainder 3 in each case.
+ For which digits $x$ is the four-digit number $234x$ divisible by 6?
+ Find the unit digit of $24^15 \times 33^12$.
  
**(a)** [2]  **(b)** [4]  **(c)** [6]  **(d)** [8]

+ Find the largest four-digit number divisible by 36.
+ Find the HCF of $2/3$, $8/9$ and $16/81$.

<details>
<summary><b>Answer key</b></summary>

+ **3.** Cycle of 3 is $3, 9, 7, 1$; $17 \div 4$ leaves remainder 1, so take the 1st term.
+ **48.** $96 = 2^5 \times 3$, $144 = 2^4 \times 3^2$; HCF $= 2^4 \times 3 = 48$.
+ **240.** $16 = 2^4$, $24 = 2^3 \times 3$, $40 = 2^3 \times 5$; LCM $= 2^4 \times 3 \times 5 = 240$.
+ **24.** $540 = 2^2 \times 3^3 \times 5$, so $(2+1)(3+1)(1+1) = 3 \times 4 \times 2 = 24$.
+ **14.** $floor(60/5) = 12$, $floor(60/25) = 2$; $12 + 2 = 14$.
+ **3.** Alternating sum from the right $= 5 - 0 + 1 - 3 = 3$, so the remainder is 3. $3105 - 3 = 3102 = 11 \times 282$.
+ **1.** $5 equiv -1 (mod 6)$, and the power 40 is even, so $(-1)^40 = 1$.
+ **21 and 28; HCF $= 7$.** Let the numbers be $3k$ and $4k$; then HCF $= k$ and LCM $= 12k = 84$, so $k = 7$.
+ **465.** $200 = 2^3 \times 5^2$; sum $= (1+2+4+8)(1+5+25) = 15 \times 31 = 465$.
+ **159.** $2 \times 64 + 3 \times 8 + 7 = 128 + 24 + 7 = 159$.
+ **51.** LCM$(8,12,16) = 48$; $48 + 3 = 51$.
+ **$x = 0$ or $x = 6$.** Digit sum $9 + x$ must be a multiple of 3, giving $x in {0,3,6,9}$; $x$ must also be even.
+ **(b) 4.** $4^15$: cycle $4, 6$, odd power gives 4. $3^12$: $12 \div 4$ leaves remainder 0, so take the 4th term, 1. Then $4 \times 1 = 4$. Choosing (c) 6 means you used the even-power value of 4; choosing (a) 2 means you multiplied the bases' unit digits $4 \times 3 = 12$ and stopped; choosing (d) 8 means you used the cycle of 2 ($2, 4, 8, 6$) instead of the cycle of 4.
+ **9972.** $9999 \div 36 = 277$ remainder 27, so $277 \times 36 = 9972$.
+ **$2/81$.** HCF of numerators $= 2$; LCM of denominators $=$ LCM$(3, 9, 81) = 81$.

## Tier 2 — Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 21** `Grab · pattern`

A fleet hub services three vehicle groups on fixed cycles: every 36 days, every 48 days and every 60 days. All three were serviced together on day 0. In the next 730 days, how many more times are all three serviced on the same day?

**Solution**

All three coincide after LCM(36, 48, 60) days.
$36 = 2^2 \times 3^2$
$48 = 2^4 \times 3$
$60 = 2^2 \times 3 \times 5$
Take the highest power of each prime: $2^4 \times 3^2 \times 5$.
$= 16 \times 9 \times 5 = 16 \times 45 = 720$.
So they coincide on day 720, day 1440, day 2160, and so on.
Inside 730 days only day 720 qualifies.

**➜ Answer: Once, on day 720**

**Example 22** `Shopee · pattern`

Order IDs run from 1 to 2000. How many IDs are divisible by 3 or by 5, but **not** by 15?

**Solution**

Step 1 — divisible by 3: $floor(2000/3) = 666$.
Step 2 — divisible by 5: $floor(2000/5) = 400$.
Step 3 — divisible by both, i.e. by 15: $floor(2000/15) = 133$.
Step 4 — divisible by 3 or 5 $= 666 + 400 - 133 = 933$.
Step 5 — remove the ones divisible by 15: $933 - 133 = 800$.

**➜ Answer: 800**

---
💡 **SHORTCUT**

"By 3 or 5 but not by 15" $=$ (count by 3) $+$ (count by 5) $- 2 \times$ (count by 15). Here $666 + 400 - 266 = 800$. The multiples of 15 are subtracted twice: once to fix the double count, once to throw them out.

**Example 23** `DBS · pattern`

Find the remainder when $1234 \times 5678 \times 9101$ is divided by 7.

**Solution**

Reduce each factor first. That keeps the numbers small.
$1234 \div 7$: $7 \times 176 = 1232$, remainder $2$.
$5678 \div 7$: $7 \times 811 = 5677$, remainder $1$.
$9101 \div 7$: $7 \times 1300 = 9100$, remainder $1$.
So the product $equiv 2 \times 1 \times 1 = 2 (mod 7)$.

**➜ Answer: 2**

**Example 24** `GIC · pattern`

Find the highest power of 12 that divides $100!$.

**Solution**

$12 = 2^2 \times 3$. We need both pieces.
Power of 2 in $100!$:
$floor(100/2) = 50$
$floor(100/4) = 25$
$floor(100/8) = 12$
$floor(100/16) = 6$
$floor(100/32) = 3$
$floor(100/64) = 1$
Total $= 50 + 25 + 12 + 6 + 3 + 1 = 97$.
Power of 3 in $100!$:
$floor(100/3) = 33$
$floor(100/9) = 11$
$floor(100/27) = 3$
$floor(100/81) = 1$
Total $= 33 + 11 + 3 + 1 = 48$.
Each 12 needs **two** 2s: from 97 twos we get $floor(97/2) = 48$ copies.
Each 12 needs **one** 3: from 48 threes we get 48 copies.
Answer is the smaller: $min(48, 48) = 48$.

**➜ Answer: $12^48$**

---
⚠️ **TRAP**

Do not stop at "power of 2 is 97, power of 3 is 48, so answer 48" by luck. Divide each prime count by its exponent in the composite **first**. For the highest power of 8 in $100!$ the answer is $floor(97/3) = 32$, not 97.

**Example 25** `Agoda · pattern`

Find the last two digits of $7^2024$.

**Solution**

Work modulo 100.
$7^1 = 7$
$7^2 = 49$
$7^3 = 343 arrow.r 43$
$7^4 = 43 \times 7 = 301 arrow.r 01$
So the pattern $07, 49, 43, 01$ repeats with period 4.
$2024 \div 4 = 506$ remainder $0$.
Remainder 0 means we land on the 4th term of the cycle, which is $01$.

**➜ Answer: 01**

**Example 26** `SCB · pattern`

How many factors of $21,600$ are perfect squares?

**Solution**

Factorise. $21600 = 216 \times 100$.
$216 = 6^3 = 2^3 \times 3^3$.
$100 = 2^2 \times 5^2$.
So $21600 = 2^(3+2) \times 3^3 \times 5^2 = 2^5 \times 3^3 \times 5^2$.
A factor is a perfect square only if **every** exponent in it is even.
For $2$: choose from $0, 2, 4$ $arrow.r$ 3 ways.
For $3$: choose from $0, 2$ $arrow.r$ 2 ways.
For $5$: choose from $0, 2$ $arrow.r$ 2 ways.
Total $= 3 \times 2 \times 2 = 12$.

**➜ Answer: 12**

**Example 27** `LINE MAN · pattern`

A Bangkok warehouse holds 1,344 packets of rice, 2,016 packets of oil and 1,680 packets of sauce. They must go into identical crates, each crate holding one product only, with no packet left over and no crate part-filled. What is the largest crate size, and how many crates are needed?

**Solution**

Crate size must divide all three counts, so take the HCF.
$1344 = 2^6 \times 3 \times 7$   (since $1344 = 64 \times 21$)
$2016 = 2^5 \times 3^2 \times 7$   (since $2016 = 32 \times 63$)
$1680 = 2^4 \times 3 \times 5 \times 7$   (since $1680 = 16 \times 105$)
Lowest power of each common prime: $2^4$, $3^1$, $7^1$. (5 is missing from two of them.)
HCF $= 16 \times 3 \times 7 = 336$.
Crates needed:
rice $= 1344 \div 336 = 4$
oil $= 2016 \div 336 = 6$
sauce $= 1680 \div 336 = 5$
Total $= 4 + 6 + 5 = 15$.

**➜ Answer: 336 packets per crate; 15 crates**

**Example 28** `Sea · pattern`

A legacy pricing system stores numbers in an unknown base $b$. In that system a price is written $144$, and its decimal value is 49. Find $b$, then write 49 in base 6.

**Solution**

Step 1 — set up the place values.
$(144)_b = 1 \times b^2 + 4 \times b + 4$.
So $b^2 + 4b + 4 = 49$.
The left side is a perfect square: $b^2 + 4b + 4 = (b+2)^2$.
$(b+2)^2 = 49 arrow.r b + 2 = 7 arrow.r b = 5$.
Check the digits are legal: the digits used are 1 and 4, both less than 5. Good.
Check the value: $(144)_5 = 25 + 20 + 4 = 49$. Correct.
Step 2 — write 49 in base 6.
$49 \div 6 = 8$ remainder $1$
$8 \div 6 = 1$ remainder $2$
$1 \div 6 = 0$ remainder $1$
Read bottom-up: $121$.
Check: $1 \times 36 + 2 \times 6 + 1 = 36 + 12 + 1 = 49$. Correct.

**➜ Answer: $b = 5$; $49 = (121)_6$**

---
⚠️ **TRAP**

In base $b$, every digit must be **less than** $b$. If an answer gives $b = 3$ but the number contains the digit 4, the answer is wrong. Always run this check.

**Example 29** `Razer · pattern`

Find the remainder when $3^100$ is divided by 13.

**Solution**

13 is prime and does not divide 3, so Fermat applies:
$3^12 equiv 1 (mod 13)$.
Write $100 = 12 \times 8 + 4$.
$3^100 = (3^12)^8 \times 3^4 equiv 1^8 \times 3^4 = 3^4$.
$3^4 = 81$.
$81 \div 13$: $13 \times 6 = 78$, remainder $3$.

**➜ Answer: 3**

#### Practice — Tier 2 — Singapore & Thailand *(target: 100 s/Q)*

+ How many integers from 1 to 500 are divisible by 4 or by 6?
+ Find the highest power of 7 that divides $200!$.
+ Find the last two digits of $3^2026$.
+ How many factors of $14,400$ are perfect squares?
+ Find the remainder when $2^31$ is divided by 5.
+ In base $b$, the number $121$ equals 144 in decimal. Find $b$.
+ Find the largest number that divides 1,305, 4,665 and 6,905 leaving the same remainder in each case. State that remainder.
+ Find the remainder when $1! + 2! + 3! + \dots + 50!$ is divided by 15.
+ A shop must pack 1,020 chocolates and 1,632 candies into identical boxes, one product per box, nothing left over. Find the largest box size and the total number of boxes.
+ How many zeros are at the end of $1^1 \times 2^2 \times 3^3 \times \dots \times 10^10$?
+ Find the remainder when $7^77$ is divided by 100.

<details>
<summary><b>Answer key</b></summary>

+ **167.** $floor(500/4) = 125$, $floor(500/6) = 83$, $floor(500/12) = 41$; $125 + 83 - 41 = 167$.
+ **$7^32$.** $floor(200/7) = 28$, $floor(200/49) = 4$, $floor(200/343) = 0$; $28 + 4 = 32$.
+ **29.** Powers of 3 mod 100 repeat with period 20 (since $3^20 equiv 01$). $2026 \div 20$ leaves remainder 6, and $3^6 = 729 arrow.r 29$.
+ **16.** $14400 = 2^6 \times 3^2 \times 5^2$. Even exponents: $2$ gives $0,2,4,6$ (4 ways), $3$ gives $0,2$ (2 ways), $5$ gives $0,2$ (2 ways); $4 \times 2 \times 2 = 16$.
+ **3.** Cycle of 2 mod 5 has length 4; $31 \div 4$ leaves remainder 3, and $2^3 = 8 equiv 3$.
+ **11.** $b^2 + 2b + 1 = 144 arrow.r (b+1)^2 = 144 arrow.r b = 11$. Digits 1 and 2 are both below 11, so it is valid.
+ **1,120; remainder 185.** Differences: $4665 - 1305 = 3360$, $6905 - 4665 = 2240$, $6905 - 1305 = 5600$. HCF$(3360, 2240, 5600) = 1120$. Then $1305 = 1120 \times 1 + 185$.
+ **3.** From $5!$ onward every term is a multiple of 15, so only $1 + 2 + 6 + 24 = 33$ matters, and $33 \div 15$ leaves remainder 3.
+ **204 per box; 13 boxes.** $1020 = 2^2 \times 3 \times 5 \times 17$, $1632 = 2^5 \times 3 \times 17$, HCF $= 2^2 \times 3 \times 17 = 204$. Boxes $= 5 + 8 = 13$.
+ **15.** Power of 5 comes from $5^5$ and $10^10$: $5 + 10 = 15$. Power of 2 comes from $2^2, 4^4, 6^6, 8^8, 10^10$: $2 + 8 + 6 + 24 + 10 = 50$. The smaller count wins.
+ **7.** The last two digits of $7^n$ cycle as $07, 49, 43, 01$; $77 \div 4$ leaves remainder 1, so the last two digits are 07, i.e. remainder 7.

## Tier 3 — Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 30** `Google · pattern`

Show that no factorial ends in exactly 5 zeros. Then find the next number of zeros that is also impossible.

**Solution**

**Insight: the zero-count function $Z(n)$ climbs in steps of 1 most of the time, but it jumps by 2 at every multiple of 25, skipping a value.**

Let $Z(n) = floor(n/5) + floor(n/25) + floor(n/125) + \dots$

Compute around 25:
$Z(24) = floor(24/5) + floor(24/25) = 4 + 0 = 4$.
$Z(25) = floor(25/5) + floor(25/25) = 5 + 1 = 6$.
$Z(n)$ never decreases, and it changes only when $n$ crosses a multiple of 5. Between $n = 24$ and $n = 25$ it went straight from 4 to 6.
So no $n$ gives $Z(n) = 5$. A factorial ending in exactly 5 zeros does not exist.

Now the next skip. The next multiple of 25 is 50.
$Z(49) = floor(49/5) + floor(49/25) = 9 + 1 = 10$.
$Z(50) = floor(50/5) + floor(50/25) = 10 + 2 = 12$.
So 11 is skipped too.

The pattern: a value is skipped at every multiple of 25. The skipped values are $5, 11, 17, 23, 29, \dots$, rising by 6 each time, until 125 is reached (where the jump is 3 and two values are skipped at once).

**➜ Answer: 5 is impossible; the next impossible value is 11**

**Example 31** `Amazon · pattern`

How many integers from 1 to 1000 share no common factor with 1000 other than 1? What is their sum?

**Solution**

**Insight: the count comes from Euler's $phi$; the sum comes from pairing $k$ with $1000 - k$, because one is coprime to 1000 exactly when the other is.**

Step 1 — the count.
$1000 = 2^3 \times 5^3$, so the only primes to avoid are 2 and 5.
$phi(1000) = 1000 \times (1 - 1/2) \times (1 - 1/5) = 1000 \times 1/2 \times 4/5$.
$1000 \times 1/2 = 500$. $500 \times 4/5 = 400$.
So 400 integers qualify. (1000 itself is not one of them, since HCF(1000, 1000) = 1000.)

Step 2 — the sum.
If HCF$(k, 1000) = 1$, then any common factor of $1000 - k$ and 1000 would also divide $k$. So HCF$(1000 - k, 1000) = 1$ as well.
This pairs the 400 numbers into $400 \div 2 = 200$ pairs, each pair adding to 1000.
No number is paired with itself, because $k = 500$ is not coprime to 1000.
Sum $= 200 \times 1000 = 200,000$.

**➜ Answer: 400 numbers; sum $= 200,000$**

**Example 32** `Goldman Sachs · pattern`

Find the last two digits of $2^2024$.

**Solution**

**Insight: 100 splits as $4 \times 25$. Solve mod 4 and mod 25 separately, then glue the two answers together.**

Mod 4: $2^2024$ has far more than two factors of 2, so $2^2024 equiv 0 (mod 4)$.

Mod 25: HCF$(2, 25) = 1$, and $phi(25) = 25 \times (1 - 1/5) = 20$.
So $2^20 equiv 1 (mod 25)$.
$2024 \div 20 = 101$ remainder $4$.
$2^2024 = (2^20)^101 \times 2^4 equiv 1 \times 16 = 16 (mod 25)$.

Glue: we need a number below 100 that is $equiv 16 (mod 25)$ and $equiv 0 (mod 4)$.
Numbers $equiv 16 (mod 25)$: $16, 41, 66, 91$.
Which are multiples of 4? $16 \div 4 = 4$ exactly. $41, 66, 91$ are not.
So the last two digits are 16.

Cross-check with the 76-trick: $2^20 equiv 76 (mod 100)$ and $76 \times 76 equiv 76$.
$2^2024 = (2^20)^101 \times 2^4 equiv 76 \times 16 = 1216 arrow.r 16$. Same answer.

**➜ Answer: 16**

**Example 33** `D. E. Shaw · pattern`

How many positive integers less than 1000 have exactly 3 factors?

**Solution**

**Insight: the factor count $(a+1)(b+1)\dots$ equals 3 only if it is the single term $3$, so the number must be $p^2$ for a prime $p$.**

3 is prime, so the product $(a+1)(b+1)\dots = 3$ forces exactly one prime in the factorisation with $a + 1 = 3$, i.e. $a = 2$.
So the number is $p^2$.
Condition: $p^2 < 1000$.
$31^2 = 961 < 1000$. $32^2 = 1024 > 1000$. So $p \\le 31$.
Primes up to 31: $2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31$.
Count them: $2, 3, 5, 7$ (4), $11, 13, 17, 19$ (4 more, total 8), $23, 29, 31$ (3 more, total 11).

**➜ Answer: 11**

**Example 34** `Microsoft · pattern`

Find the smallest positive integer $n$ such that $n!$ is divisible by $2^30$.

**Solution**

**Insight: the power of 2 in $n!$ is $n$ minus the number of 1s in the binary form of $n$. So the count grows almost like $n$, and the answer sits just above 30.**

Power of 2 in $n! = floor(n/2) + floor(n/4) + floor(n/8) + \dots$

Try $n = 31$:
$floor(31/2) = 15$
$floor(31/4) = 7$
$floor(31/8) = 3$
$floor(31/16) = 1$
$floor(31/32) = 0$
Total $= 15 + 7 + 3 + 1 = 26$. That is less than 30, so $31!$ fails.

Try $n = 32$:
$floor(32/2) = 16$
$floor(32/4) = 8$
$floor(32/8) = 4$
$floor(32/16) = 2$
$floor(32/32) = 1$
Total $= 16 + 8 + 4 + 2 + 1 = 31$. That is at least 30, so $32!$ works.

Since the power of 2 never decreases as $n$ grows, 32 is the smallest.
Sanity check with the binary shortcut: $31 = (11111)_2$ has five 1s, giving $31 - 5 = 26$. And $32 = (100000)_2$ has one 1, giving $32 - 1 = 31$. Both match.

**➜ Answer: $n = 32$**

**Example 35** `Uber · pattern`

Find the smallest positive integer that leaves remainder 2 when divided by 3, remainder 3 when divided by 5, and remainder 4 when divided by 7. Then describe all such integers.

**Solution**

**Insight: build the answer one modulus at a time. Satisfy the largest modulus condition last, so you test the fewest candidates.**

Step 1 — satisfy "remainder 3 when divided by 5".
Candidates: $3, 8, 13, 18, 23, 28, \dots$ (step 5).

Step 2 — among those, keep the ones with remainder 2 when divided by 3.
$3 \div 3$ leaves 0. No.
$8 \div 3$ leaves 2. Yes.
So the first is 8, and the family now steps by LCM$(3,5) = 15$:
$8, 23, 38, 53, 68, \dots$

Step 3 — among those, keep the ones with remainder 4 when divided by 7.
$8 \div 7$ leaves 1. No.
$23 \div 7$: $7 \times 3 = 21$, leaves 2. No.
$38 \div 7$: $7 \times 5 = 35$, leaves 3. No.
$53 \div 7$: $7 \times 7 = 49$, leaves 4. Yes.

So the smallest is 53.
Full check: $53 = 3 \times 17 + 2$. $53 = 5 \times 10 + 3$. $53 = 7 \times 7 + 4$. All three hold.

All solutions: once one works, adding LCM$(3,5,7) = 105$ keeps all three remainders. So the numbers are
$53, 158, 263, 368, \dots$, that is $53 + 105k$ for $k = 0, 1, 2, \dots$

**➜ Answer: 53; in general $53 + 105k$**

**Example 36** `Adobe · pattern`

Find the smallest positive integer with exactly 15 factors. Then find the smallest **odd** integer with exactly 15 factors.

**Solution**

**Insight: 15 factors means the exponents plus one must multiply to 15. List every way to write 15 as a product, then attach the biggest exponent to the smallest prime.**

Ways to write $15$ as a product of integers each at least 2:
$15 = 15$   $arrow.r$ one prime, exponent $15 - 1 = 14$, shape $p^14$
$15 = 5 \times 3$   $arrow.r$ two primes, exponents 4 and 2, shape $p^4 q^2$
$15 = 3 \times 5$ is the same shape with the exponents swapped.

Now minimise using the smallest primes.
Shape $p^14$: smallest is $2^14 = 16384$.
Shape $p^4 q^2$ with the bigger exponent on the smaller prime: $2^4 \times 3^2 = 16 \times 9 = 144$.
Shape $p^2 q^4$ (bigger exponent on the bigger prime): $2^2 \times 3^4 = 4 \times 81 = 324$. Larger.
Smallest overall $= 144$.
Check: $144 = 2^4 \times 3^2$, so it has $(4+1)(2+1) = 5 \times 3 = 15$ factors. Correct.

Odd case — drop the prime 2, so the smallest primes available are 3 and 5.
Shape $p^14$: $3^14$, enormous.
Shape $p^4 q^2$: $3^4 \times 5^2 = 81 \times 25 = 2025$.
Shape $p^2 q^4$: $3^2 \times 5^4 = 9 \times 625 = 5625$. Larger.
Smallest odd $= 2025$.
Check: $2025 = 3^4 \times 5^2$, factor count $= 5 \times 3 = 15$. Correct.

**➜ Answer: 144; smallest odd is 2025**

#### Practice — Tier 3 — Product *(target: 4 min/Q)*

+ Find the smallest $n$ for which $n!$ ends in exactly 20 zeros.
+ Find the last two digits of $13^2025$.
+ Find the smallest positive integer with exactly 18 factors.
+ Find the remainder when $2^2024 + 3^2024$ is divided by 5.
+ How many zeros are at the end of the product $100 \times 200 \times 300 \times \dots \times 1000$?
+ Find the sum of all positive integers below 60 that share no factor with 60 except 1.
+ Find the smallest positive integer that leaves remainder 1 when divided by each of 2, 3, 4, 5 and 6, and is exactly divisible by 7.

<details>
<summary><b>Answer key</b></summary>

+ **85.** $Z(84) = 16 + 3 = 19$ and $Z(85) = 17 + 3 = 20$, so 85 is the first. Note $Z(86) = Z(87) = Z(88) = Z(89) = 20$ as well, but 85 is the smallest. The value 20 is reachable, unlike 5 or 11.
+ **93.** Work mod 100: $13^2 equiv 69$, $13^4 equiv 69^2 = 4761 equiv 61$, $13^5 equiv 61 \times 13 = 793 equiv 93$, $13^10 equiv 93^2 = 8649 equiv 49$, $13^20 equiv 49^2 = 2401 equiv 01$. Period 20, and $2025 \div 20$ leaves remainder 5, so the answer equals $13^5 equiv 93$.
+ **180.** $18 = 2 \times 3 \times 3$ gives exponents $(2,2,1)$, so $2^2 \times 3^2 \times 5 = 180$. Other shapes: $18 = 3 \times 6$ gives $2^5 \times 3^2 = 288$; $18 = 2 \times 9$ gives $2^8 \times 3 = 768$; $18 = 18$ gives $2^17$. 180 is smallest, and it does have $3 \times 3 \times 2 = 18$ factors.
+ **2.** Unit-digit cycles have length 4 for both. $2024 \div 4$ leaves remainder 0, so take the 4th terms: $2^4 = 16 equiv 1 (mod 5)$ and $3^4 = 81 equiv 1 (mod 5)$. Sum $equiv 1 + 1 = 2$.
+ **22.** The product is $(100 \times 1)(100 \times 2) \dots (100 \times 10) = 100^10 \times 10!$. Now $100^10 = 10^20$ gives 20 zeros, and $10! = 3,628,800$ ends in 2 zeros. Total $= 20 + 2 = 22$.
+ **480.** $60 = 2^2 \times 3 \times 5$, so $phi(60) = 60 \times 1/2 \times 2/3 \times 4/5 = 16$. Those 16 numbers pair as $(k, 60-k)$, giving 8 pairs each summing to 60, so the sum is $8 \times 60 = 480$.
+ **301.** Remainder 1 with all of 2, 3, 4, 5, 6 means the number is LCM$(2,3,4,5,6) + 1 = 60k + 1$. Now need $7$ to divide $60k + 1$. Since $60 equiv 4 (mod 7)$, we need $4k + 1 equiv 0 (mod 7)$, i.e. $4k equiv 6 (mod 7)$. Multiply both sides by 2 (because $4 \times 2 = 8 equiv 1$): $k equiv 12 equiv 5 (mod 7)$. Smallest $k = 5$ gives $n = 301 = 7 \times 43$.

## Mixed set — exam conditions

#### Practice — Tier 1 — Service *(target: 90 s/Q · 18 questions in 27 minutes)*

+ Find the unit digit of $1234^567$.
+ Find the HCF of 72, 120 and 192.
+ How many zeros does $200!$ end with?
+ Find the remainder when $3^1000$ is divided by 7.
+ How many factors of 720 are even?
+ Write the decimal number 300 in base 7.
+ Find the smallest four-digit number divisible by 15, 20 and 24.
+ Find the last two digits of $2^100$.
+ How many integers from 1 to 300 are divisible by neither 2 nor 3?
+ What is the smallest positive integer $n$ for which $7^n$ ends in the digit 3?
+ Find the product of all the factors of 36.
+ Find the remainder when $96^96 + 1$ is divided by 97.
+ Find the smallest positive integer that leaves remainder 1 when divided by 3 and remainder 2 when divided by 5.
+ For which digits $x$ is the four-digit number $5 1 x 3$ divisible by 9?
+ Find the highest power of 5 that divides $1000!$.
+ How many factors of 1,800 are multiples of 10?
+ Find the remainder when $2^2024$ is divided by 9.
+ A number $N$ leaves remainder 63 when divided by 899. What remainder does $N$ leave when divided by 29?

<details>
<summary><b>Answer key</b></summary>

+ **4.** Only the last digit 4 matters. Cycle of 4 is $4, 6$; the power 567 is odd, so the answer is 4.
+ **24.** $72 = 2^3 \times 3^2$, $120 = 2^3 \times 3 \times 5$, $192 = 2^6 \times 3$; HCF $= 2^3 \times 3 = 24$.
+ **49.** $floor(200/5) = 40$, $floor(200/25) = 8$, $floor(200/125) = 1$; total $40 + 8 + 1 = 49$.
+ **4.** 7 is prime, so $3^6 equiv 1 (mod 7)$. $1000 \div 6$ leaves remainder 4, and $3^4 = 81 = 7 \times 11 + 4$.
+ **24.** $720 = 2^4 \times 3^2 \times 5$; total factors $= 5 \times 3 \times 2 = 30$; odd factors $= 3 \times 2 = 6$; even $= 30 - 6 = 24$.
+ **$(606)_7$.** $300 \div 7 = 42$ r 6; $42 \div 7 = 6$ r 0; $6 \div 7 = 0$ r 6. Check: $6 \times 49 + 0 + 6 = 300$.
+ **1080.** LCM$(15, 20, 24) = 120$. $1000 \div 120 = 8$ r 40, so the next multiple is $9 \times 120 = 1080$.
+ **76.** Mod 25: $2^20 equiv 1$ and $100 \div 20$ leaves remainder 0, so $2^100 equiv 1 (mod 25)$. Candidates below 100: $1, 26, 51, 76$. The answer must also be a multiple of 4, and only 76 is.
+ **100.** Divisible by 2: 150. By 3: 100. By 6: 50. By 2 or 3: $150 + 100 - 50 = 200$. Neither: $300 - 200 = 100$.
+ **3.** Cycle of 7 is $7, 9, 3, 1$, and 3 is the 3rd term.
+ **$10,077,696$.** $36 = 2^2 \times 3^2$ has $3 \times 3 = 9$ factors, so the product is $36^(9/2) = 6^9 = 10,077,696$.
+ **2.** $96 equiv -1 (mod 97)$, and 96 is an even power, so $96^96 equiv 1$. Then $1 + 1 = 2$.
+ **7.** Numbers with remainder 2 mod 5: $2, 7, 12, \dots$ The first with remainder 1 mod 3 is 7, since $7 = 3 \times 2 + 1$.
+ **$x = 0$ or $x = 9$.** Digit sum $= 5 + 1 + x + 3 = 9 + x$, which must be a multiple of 9.
+ **$5^249$.** $floor(1000/5) = 200$, $floor(1000/25) = 40$, $floor(1000/125) = 8$, $floor(1000/625) = 1$; total $= 249$.
+ **18.** A factor that is a multiple of 10 has the form $10 \times m$ where $m$ divides $1800 \div 10 = 180 = 2^2 \times 3^2 \times 5$. Count of such $m$ is $3 \times 3 \times 2 = 18$.
+ **4.** $phi(9) = 6$, so $2^6 equiv 1 (mod 9)$. $2024 \div 6 = 337$ r 2, so $2^2024 equiv 2^2 = 4$.
+ **5.** $899 = 29 \times 31$, so $N = 899k + 63$ gives $N equiv 63 (mod 29)$ because $899k$ is a multiple of 29. Then $63 = 29 \times 2 + 5$.

## 📋 One-page revision card

**Divisibility, fast.**
2: last digit even · 3: digit sum · 4: last 2 digits · 5: ends 0 or 5 · 6: 2 and 3 · 8: last 3 digits · 9: digit sum · 11: alternating digit sum · 12: 3 and 4 · 25: last 2 digits.

**Factors.** For $N = p^a q^b r^c$: count $= (a+1)(b+1)(c+1)$; sum $= product ((p^(a+1)-1)/(p-1))$; product $= N^(d/2)$.
Odd factors: ignore the 2s. Even factors: total $-$ odd. Square factors: even exponents only.
Exactly 3 factors $arrow.r$ the number is $p^2$. Exactly 4 factors $arrow.r$ it is $p^3$ or $p q$.

**HCF / LCM.** HCF $\times$ LCM $=$ product (two numbers only).
Fractions: HCF $=$ HCF(num)/LCM(den); LCM $=$ LCM(num)/HCF(den).
Same unknown remainder $arrow.r$ HCF of differences. Given remainders $arrow.r$ subtract them first.
Smallest number with common remainder $r$ $arrow.r$ LCM $+ r$.

**Remainders.** Reduce every factor before multiplying. Use $-1$ whenever possible.
Fermat: $a^(p-1) equiv 1 (mod p)$. Euler: $a^phi(n) equiv 1 (mod n)$.
Split a composite modulus, e.g. $100 = 4 \times 25$, solve both, then glue.

**Unit digits.** Cycle length 4 for $2, 3, 7, 8$; length 2 for $4, 9$; length 1 for $0, 1, 5, 6$.
Divide the power by 4; remainder 0 means take the 4th term.

**Last two digits.** $7^4 equiv 01$ · $2^20 equiv 76$ and $76 \times 76 equiv 76$ · $3^20 equiv 01$ · $13^20 equiv 01$.

**Factorials.** Power of prime $p$ in $n! = floor(n/p) + floor(n/p^2) + \dots$
Trailing zeros $=$ the 5-count. For $p^k$ divide the prime count by $k$. For a composite, take the minimum across its primes.

**Bases.** $(d_k \dots d_0)_b = sum d_i b^i$. Decimal to base $b$: divide repeatedly, read remainders bottom-up. Binary to octal: group in 3s; binary to hex: group in 4s. Every digit must be less than the base.

**Top 5 traps.**
+ Cyclicity remainder 0 means the **4th** term, not the 1st and not zero.
+ Trailing zeros: keep dividing past $n/5$ — 25, 125, 625 each add more.
+ HCF/LCM of fractions: do not swap the two formulas. Check that HCF $\\le$ LCM.
+ Highest power of a **composite**: divide each prime's count by its exponent **before** taking the minimum.
+ A remainder is never negative. If your work gives $-1 (mod 7)$, the remainder is 6.

</details>

</details>

</details>

</details>
