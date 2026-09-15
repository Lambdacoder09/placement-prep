# Chapter 11 — Algebra Essentials

*Equations, progressions, powers, logs, inequalities*

## What you need to know

**WHAT YOU NEED TO KNOW**

**Identities**
- $(a+b)^2 = a^2 + 2a b + b^2$   $(a-b)^2 = a^2 - 2a b + b^2$
- $a^2 - b^2 = (a-b)(a+b)$
- $(a+b)^3 = a^3 + b^3 + 3a b(a+b)$   $(a-b)^3 = a^3 - b^3 - 3a b(a-b)$
- $a^3 + b^3 = (a+b)(a^2 - a b + b^2)$   $a^3 - b^3 = (a-b)(a^2 + a b + b^2)$
- $a^3 + b^3 + c^3 - 3a b c = (a+b+c)(a^2+b^2+c^2-a b-b c-c a)$
- If $x + 1/x = k$: $x^2 + 1/x^2 = k^2 - 2$,   $x^3 + 1/x^3 = k^3 - 3k$
- If $x - 1/x = k$: $x^2 + 1/x^2 = k^2 + 2$,   $x^3 - 1/x^3 = k^3 + 3k$

**Linear equations**
- $a_1 x + b_1 y = c_1$, $a_2 x + b_2 y = c_2$.
- Unique solution if $a_1/a_2 \\ne b_1/b_2$. No solution if $a_1/a_2 = b_1/b_2 \\ne c_1/c_2$. Infinite if all three equal.

**Quadratic** $a x^2 + b x + c = 0$, $a \\ne 0$
- $x = (-b plus.minus sqrt(b^2 - 4a c))/(2a)$,   discriminant $D = b^2 - 4a c$
- $D > 0$: two real distinct. $D = 0$: two equal. $D < 0$: no real root.
- Sum of roots $alpha + beta = -b/a$. Product $alpha beta = c/a$.
- Equation from roots: $x^2 - ("sum")x + ("product") = 0$
- $alpha^2 + beta^2 = (alpha+beta)^2 - 2 alpha beta$;   $abs(alpha - beta) = sqrt(D)/abs(a)$
- Minimum / maximum of $a x^2 + b x + c$ is at $x = -b/(2a)$; value $= c - b^2/(4a)$.

**Progressions**
- AP: $t_n = a + (n-1)d$;   $S_n = n/2 [2a + (n-1)d] = n/2 (a + l)$
- GP: $t_n = a r^(n-1)$;   $S_n = a(r^n - 1)/(r-1)$ for $r \\ne 1$
- Infinite GP ($|r| < 1$): $S_infinity = a/(1-r)$
- HP: reciprocals form an AP. $n$-th term of HP $= 1/(a + (n-1)d)$.
- $1+2+\dots+n = n(n+1)/2$;   $1^2+\dots+n^2 = n(n+1)(2n+1)/6$;   $1^3+\dots+n^3 = [n(n+1)/2]^2$
- For two positives: $"AM" = (a+b)/2$, $"GM" = sqrt(a b)$, $"HM" = (2a b)/(a+b)$;   $"GM"^2 = "AM" \times "HM"$;   $"AM" \\ge "GM" \\ge "HM"$

**Indices**
- $a^m \times a^n = a^(m+n)$;   $a^m \div a^n = a^(m-n)$;   $(a^m)^n = a^(m n)$
- $a^0 = 1$;   $a^(-n) = 1/a^n$;   $a^(m/n) = root(n, a^m)$

**Surds**
- $1/(sqrt(a) - sqrt(b)) = (sqrt(a) + sqrt(b))/(a - b)$ (multiply by the conjugate)
- $sqrt(a) \times sqrt(b) = sqrt(a b)$

**Logarithms** (base $b > 0$, $b \\ne 1$)
- $log_b x = y arrow.l.r b^y = x$
- $log(m n) = log m + log n$;   $log(m/n) = log m - log n$;   $log(m^p) = p log m$
- $log_b b = 1$;   $log_b 1 = 0$;   change of base: $log_b a = (log_c a)/(log_c b) = 1/(log_a b)$
- Digits in $N$ (base 10) $= floor(log_10 N) + 1$
- Useful: $log_10 2 = 0.3010$, $log_10 3 = 0.4771$, $log_10 7 = 0.8451$

**Inequalities**
- Multiplying or dividing by a negative number flips the sign.
- $|x| < a arrow.l.r -a < x < a$;   $|x| > a arrow.l.r x < -a "or" x > a$
- For $x > 0$: $x + k/x \\ge 2 sqrt(k)$, equality at $x = sqrt(k)$.

**Functions**
- $(f compose g)(x) = f(g(x))$ — inner function first.
- Inverse: swap $x$ and $y$ in $y = f(x)$, then solve for $y$.
- Domain rule: denominator $\\ne 0$, and the inside of a square root $\\ge 0$.
- Remainder when $f(x)$ is divided by $(x - a)$ is $f(a)$.

## Warm-up

### Warm-up

**Example 1**

Solve $5x - 7 = 3x + 9$.

**Solution**

Bring $3x$ to the left: $5x - 3x - 7 = 9$, so $2x - 7 = 9$. \
Add 7: $2x = 16$. \
Divide by 2: $x = 8$.

**➜ Answer: $x = 8$**

**Example 2**

Simplify $81^(3/4) \div 27^(2/3)$.

**Solution**

$81 = 3^4$, so $81^(3/4) = 3^(4 \times 3/4) = 3^3 = 27$. \
$27 = 3^3$, so $27^(2/3) = 3^(3 \times 2/3) = 3^2 = 9$. \
$27 \div 9 = 3$.

**➜ Answer: $3$**

**Example 3**

Rationalise $1/(sqrt(5) - 2)$.

**Solution**

Multiply top and bottom by the conjugate $sqrt(5) + 2$. \
Bottom: $(sqrt(5) - 2)(sqrt(5) + 2) = 5 - 4 = 1$. \
Top: $sqrt(5) + 2$. \
So the value is $(sqrt(5) + 2)/1 = sqrt(5) + 2$.

**➜ Answer: $sqrt(5) + 2$**

**Example 4**

Find the 12th term of the AP $5, 9, 13, \dots$

**Solution**

$a = 5$, $d = 9 - 5 = 4$. \
$t_12 = a + 11 d = 5 + 11 \times 4 = 5 + 44 = 49$.

**➜ Answer: $49$**

**Example 5**

Find the sum of the first 20 terms of $3, 7, 11, \dots$

**Solution**

$a = 3$, $d = 4$, $n = 20$. \
$S_20 = 20/2 [2 \times 3 + 19 \times 4] = 10 [6 + 76] = 10 \times 82 = 820$.

**➜ Answer: $820$**

**Example 6**

Find the 6th term of the GP $2, 6, 18, \dots$, and the sum of $8 + 4 + 2 + \dots$ to infinity.

**Solution**

GP: $a = 2$, $r = 6 \div 2 = 3$. $t_6 = a r^5 = 2 \times 3^5 = 2 \times 243 = 486$. \
Infinite GP: $a = 8$, $r = 4 \div 8 = 1/2$. \
$S_infinity = 8/(1 - 1/2) = 8/(1/2) = 16$.

**➜ Answer: $t_6 = 486$; sum $= 16$**

**Example 7**

Evaluate $log_2 64 - log_3 27$.

**Solution**

$2^6 = 64$, so $log_2 64 = 6$. \
$3^3 = 27$, so $log_3 27 = 3$. \
$6 - 3 = 3$.

**➜ Answer: $3$**

**Example 8**

Solve $|x - 3| = 7$.

**Solution**

Two cases. \
Case 1: $x - 3 = 7 arrow.r x = 10$. \
Case 2: $x - 3 = -7 arrow.r x = -4$.

**➜ Answer: $x = 10$ or $x = -4$**

## Tier 1 — Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

Three pens and four notebooks cost Rs.~250. Five pens and two notebooks cost Rs.~230. Find the price of one pen and one notebook.

**Solution**

Let one pen cost $p$ and one notebook cost $n$. \
$3p + 4n = 250$ ... (i) \
$5p + 2n = 230$ ... (ii) \
Multiply (ii) by 2 so the $n$ terms match: $10 p + 4n = 460$ ... (iii) \
Subtract (i) from (iii): $(10p - 3p) + (4n - 4n) = 460 - 250$ \
$7p = 210$, so $p = 30$. \
Put $p = 30$ in (i): $3 \times 30 + 4n = 250 arrow.r 90 + 4n = 250 arrow.r 4n = 160 arrow.r n = 40$. \
Check in (ii): $5 \times 30 + 2 \times 40 = 150 + 80 = 230$. Correct.

**➜ Answer: Pen Rs.~30, notebook Rs.~40**

---
💡 **SHORTCUT**

To kill one variable, make its coefficients equal, not "nice". Here $4n$ and $2n$: doubling the second equation is one step. Do not cross-multiply the whole system — that creates big numbers you will misadd.

**Example 10** `Infosys pattern`

One root of $x^2 - 7x + k = 0$ is 3. Find $k$ and the other root.

**Solution**

A root satisfies the equation. Put $x = 3$: \
$3^2 - 7 \times 3 + k = 0$ \
$9 - 21 + k = 0$ \
$-12 + k = 0$, so $k = 12$. \
Now the equation is $x^2 - 7x + 12 = 0$. \
Sum of roots $= 7$, so the other root $= 7 - 3 = 4$. \
Check: $4^2 - 7 \times 4 + 12 = 16 - 28 + 12 = 0$. Correct.

**➜ Answer: $k = 12$, other root $= 4$**

**Example 11** `Capgemini pattern`

If $alpha$ and $beta$ are the roots of $x^2 - 5x + 3 = 0$, find (a) $alpha^2 + beta^2$ and (b) $1/alpha + 1/beta$.

**Solution**

Here $a = 1$, $b = -5$, $c = 3$. \
Sum $alpha + beta = -b/a = 5$. Product $alpha beta = c/a = 3$. \
(a) $alpha^2 + beta^2 = (alpha + beta)^2 - 2 alpha beta = 5^2 - 2 \times 3 = 25 - 6 = 19$. \
(b) $1/alpha + 1/beta = (beta + alpha)/(alpha beta) = 5/3$.

**➜ Answer: (a) $19$   (b) $5/3$**

---
⚠️ **TRAP**

Sum of roots is $-b/a$, not $b/a$. In $x^2 - 5x + 3$ the value of $b$ is $-5$, so the sum is $-(-5)/1 = +5$. Writing $-5$ here is the single most common slip in this topic.

**Example 12** `Wipro pattern`

For which values of $k$ does $4x^2 + k x + 9 = 0$ have equal roots?

**Solution**

Equal roots means $D = 0$, where $D = b^2 - 4a c$. \
$a = 4$, $b = k$, $c = 9$. \
$D = k^2 - 4 \times 4 \times 9 = k^2 - 144$. \
Set $D = 0$: $k^2 = 144$, so $k = 12$ or $k = -12$.

**➜ Answer: $k = plus.minus 12$**

**Example 13** `TCS NQT pattern`

Meera joins at a monthly salary of Rs.~24,000. Her monthly salary rises by Rs.~1,500 at the start of every year. What is her monthly salary in the 8th year, and how much does she earn in total over 8 years?

**Solution**

Monthly salaries form an AP: $a = 24000$, $d = 1500$. \
Year 8 monthly salary: $t_8 = 24000 + 7 \times 1500 = 24000 + 10500 = 34500$. \
Sum of the 8 monthly figures: $S_8 = 8/2 (a + t_8) = 4 (24000 + 34500) = 4 \times 58500 = 234000$. \
That is the total of the 8 monthly rates. Each rate is paid for 12 months, so over 8 full years she earns $12 \times 234000 = 2808000$, that is Rs.~28,08,000.

**➜ Answer: Year-8 salary Rs.~34,500; 8-year total Rs.~28,08,000**

**Example 14** `Accenture pattern`

Which term of the AP $7, 11, 15, \dots$ is 143?

**Solution**

$a = 7$, $d = 4$. \
$t_n = a + (n-1)d = 143$ \
$7 + (n-1) \times 4 = 143$ \
$(n-1) \times 4 = 136$ \
$n - 1 = 34$ \
$n = 35$.

**➜ Answer: 35th term**

**Example 15** `Cognizant pattern`

A machine bought for Rs.~80,000 loses 25% of its value every year. What is its value after 4 years?

**Solution**

Each year the value becomes $100% - 25% = 75%$ of the year before. \
So the values form a GP with $a = 80000$ and $r = 0.75$. \
Value after 4 years $= 80000 \times (0.75)^4$. \
$(0.75)^2 = 0.5625$. \
$(0.75)^4 = 0.5625 \times 0.5625 = 0.31640625$. \
$80000 \times 0.31640625 = 25312.5$.

**➜ Answer: Rs.~25,312.50**

---
💡 **SHORTCUT**

For "falls by 25% a year", never subtract 25% four separate times. Multiply by $0.75$ four times — one power, no chain of subtractions. Same for growth: $+12%$ for $n$ years is $\times (1.12)^n$.

**Example 16** `Infosys pattern`

Find the sum of the first 10 terms of $3, 6, 12, 24, \dots$

**Solution**

$a = 3$, $r = 6 \div 3 = 2$, $n = 10$. \
$S_n = a(r^n - 1)/(r - 1) = 3(2^10 - 1)/(2 - 1)$. \
$2^10 = 1024$, so $2^10 - 1 = 1023$. \
$S_10 = 3 \times 1023 \div 1 = 3069$.

**➜ Answer: $3069$**

**Example 17** `TCS NQT pattern`

Solve $9^(x+1) = 27^(x-1)$.

**Solution**

Write both sides with base 3. $9 = 3^2$ and $27 = 3^3$. \
Left: $(3^2)^(x+1) = 3^(2x + 2)$. \
Right: $(3^3)^(x-1) = 3^(3x - 3)$. \
Equal bases means equal powers: $2x + 2 = 3x - 3$. \
$2 + 3 = 3x - 2x$ \
$x = 5$. \
Check: $9^6 = 3^12$ and $27^4 = 3^12$. Correct.

**➜ Answer: $x = 5$**

**Example 18** `Capgemini pattern`

Solve $log_2 x + log_2 (x - 2) = 3$.

**Solution**

Add the logs: $log_2 [x(x-2)] = 3$. \
Rewrite in power form: $x(x - 2) = 2^3 = 8$. \
$x^2 - 2x - 8 = 0$ \
$(x - 4)(x + 2) = 0$, so $x = 4$ or $x = -2$. \
A log needs a positive input. $x = -2$ makes $log_2 x$ undefined, so reject it. \
Check $x = 4$: $log_2 4 + log_2 2 = 2 + 1 = 3$. Correct.

**➜ Answer: $x = 4$**

---
⚠️ **TRAP**

Every log equation must end with a check. Solving the algebra gives candidates, not answers. Any candidate that makes some $log$ take a zero or negative input is thrown away.

**Example 19** `Accenture pattern`

Solve $3x - 7 \\le 5x + 3$ and state the least integer value of $x$.

**Solution**

$3x - 7 \\le 5x + 3$ \
Take $5x$ to the left and $-7$ to the right: $3x - 5x \\le 3 + 7$ \
$-2x \\le 10$ \
Divide by $-2$ and flip the sign: $x \\ge -5$. \
The least integer that is $\\ge -5$ is $-5$.

**➜ Answer: $x \\ge -5$; least integer $= -5$**

**Example 20** `Wipro pattern`

Given $f(x) = 3x - 4$ and $g(x) = x^2 + 1$, find $f(g(2))$ and $g(f(2))$.

**Solution**

Inner function first. \
$g(2) = 2^2 + 1 = 4 + 1 = 5$. Then $f(5) = 3 \times 5 - 4 = 15 - 4 = 11$. \
$f(2) = 3 \times 2 - 4 = 6 - 4 = 2$. Then $g(2) = 2^2 + 1 = 5$. \
So $f(g(2)) = 11$ and $g(f(2)) = 5$.

**➜ Answer: $f(g(2)) = 11$, $g(f(2)) = 5$**

---
⚠️ **TRAP**

$f(g(x))$ and $g(f(x))$ are different animals. The answers above (11 and 5) are not equal. Read the brackets from the inside out, every time.

#### Practice — Tier 1 — Service *(target: 60 s/Q)*

+ Solve $7x + 5 = 4x + 26$.
+ Solve the pair $2x + 3y = 31$, $5x - y = 18$.
+ Find the roots of $x^2 - 11x + 30 = 0$. 
**(a)** $5  **(b)** 6$  **(c)** $-5  **(d)** -6$  **(e)** $3  **(f)** 10$  **(g)** $2  **(h)** 15$

+ If the roots of $x^2 + p x + 12 = 0$ are 3 and 4, find $p$.
+ If $alpha, beta$ are the roots of $2x^2 - 9x + 4 = 0$, find $alpha + beta$ and $alpha beta$.
+ For what value of $m$ does $x^2 + 6x + m = 0$ have equal roots? 
**(a)** $9$  **(b)** $6$  **(c)** $36$  **(d)** $3$

+ Find the 25th term of the AP $8, 15, 22, \dots$
+ How many terms are there in the AP $12, 18, 24, \dots, 150$?
+ Find the sum of all multiples of 7 between 1 and 200.
+ The 4th term of a GP is 54 and the first term is 2. Find the common ratio.
+ Find the sum to infinity of $27 + 9 + 3 + \dots$
+ Simplify $(32)^(2/5) \times (125)^(1/3)$.
+ If $log_10 2 = 0.3010$, find $log_10 32$.
+ Solve $2 log_5 x = log_5 36$, with $x > 0$.
+ Solve the inequality $4 - 3x > 13$.

<details>
<summary><b>Answer key</b></summary>

**1.** $x = 7$. $7x - 4x = 26 - 5 arrow.r 3x = 21$. \
**2.** $x = 5, y = 7$. Multiply the second by 3: $15x - 3y = 54$; add to the first: $17x = 85 arrow.r x = 5$, then $y = 5(5) - 18 = 7$. \
**3.** (a) $5, 6$ — they add to 11 and multiply to 30. (b) is the sign-flip error, (c) and (d) multiply to 30 but do not add to 11. \
**4.** $p = -7$. Sum of roots $= 7 = -p$. \
**5.** $alpha + beta = 9/2$, $alpha beta = 4/2 = 2$. \
**6.** (a) $9$. $D = 36 - 4m = 0 arrow.r m = 9$. (b) is $b$ itself, (c) is $b^2$, (d) is $b/2$. \
**7.** $176$. $a = 8, d = 7$; $8 + 24 \times 7 = 8 + 168$. \
**8.** $24$. $12 + (n-1)6 = 150 arrow.r n - 1 = 23$. \
**9.** $2842$. Terms $7$ to $196$: $n = 28$; $S = 28/2 (7 + 196) = 14 \times 203$. \
**10.** $r = 3$. $2 r^3 = 54 arrow.r r^3 = 27$. \
**11.** $40.5$. $a = 27$, $r = 1/3$; $27 \div (2/3) = 81/2$. \
**12.** $20$. $32^(2/5) = 2^2 = 4$ and $125^(1/3) = 5$; $4 \times 5 = 20$. \
**13.** $1.5050$. $log 32 = 5 log 2 = 5 \times 0.3010$. \
**14.** $x = 6$. $log_5 x^2 = log_5 36 arrow.r x^2 = 36$; reject $-6$. \
**15.** $x < -3$. $-3x > 9$, divide by $-3$ and flip.

## Tier 2 — Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 21** `LINE MAN · pattern`

A rider in Bangkok earns THB~420 on his first day on a new incentive plan. Every following day his earning rises by THB~35. On which day does his cumulative earning first reach THB~10,000?

**Solution**

Daily earnings form an AP: $a = 420$, $d = 35$. \
Cumulative earning after $n$ days: \
$S_n = n/2 [2 \times 420 + (n-1) \times 35] = n/2 [840 + 35n - 35] = n/2 [805 + 35 n]$. \
Try $n = 15$: $S_15 = 15/2 [805 + 525] = 15/2 \times 1330 = 15 \times 665 = 9975$. \
That is below 10,000. \
Try $n = 16$: $S_16 = 16/2 [805 + 560] = 8 \times 1365 = 10920$. \
So the total crosses 10,000 on day 16.

**➜ Answer: Day 16**

---
💡 **SHORTCUT**

For "when does the running total first cross $T$", do not solve the quadratic. Estimate $n \approx T \div "average daily amount"$, then test that $n$ and $n plus.minus 1$. Two multiplications beat the quadratic formula every time.

**Example 22** `Shopee · pattern`

A seller records 2,500 orders on day 1 of a campaign. Orders grow by 20% each day. Find the orders on day 5 and the total orders over the 5 days.

**Solution**

GP with $a = 2500$ and $r = 1.2$. \
Day 5 is the 5th term: $t_5 = 2500 \times (1.2)^4$. \
$(1.2)^2 = 1.44$. \
$(1.2)^4 = 1.44 \times 1.44 = 2.0736$. \
$t_5 = 2500 \times 2.0736 = 5184$. \
Total of 5 days: $S_5 = a(r^5 - 1)/(r - 1)$. \
$(1.2)^5 = 2.0736 \times 1.2 = 2.48832$. \
$S_5 = 2500 \times (2.48832 - 1)/(0.2) = 2500 \times 1.48832/0.2 = 2500 \times 7.4416 = 18604$.

**➜ Answer: Day 5: 5,184 orders. Five-day total: 18,604 orders**

**Example 23** `Grab · pattern`

A subscription team models its daily profit in Singapore dollars as $P(x) = -2x^2 + 240x - 4000$, where $x$ is the number of premium sign-ups in a day. Find (a) the sign-ups that maximise profit and the maximum profit, and (b) the two break-even values of $x$.

**Solution**

(a) For $a x^2 + b x + c$ with $a < 0$, the maximum is at $x = -b/(2a)$. \
$a = -2$, $b = 240$. \
$x = -240/(2 \times (-2)) = -240/(-4) = 60$. \
$P(60) = -2 \times 60^2 + 240 \times 60 - 4000$ \
$= -2 \times 3600 + 14400 - 4000$ \
$= -7200 + 14400 - 4000 = 3200$. \
(b) Break-even means $P(x) = 0$: \
$-2x^2 + 240x - 4000 = 0$. Divide by $-2$: \
$x^2 - 120x + 2000 = 0$ \
$D = 120^2 - 4 \times 1 \times 2000 = 14400 - 8000 = 6400$; $sqrt(D) = 80$. \
$x = (120 plus.minus 80)/2 arrow.r x = 200/2 = 100$ or $x = 40/2 = 20$.

**➜ Answer: (a) 60 sign-ups, profit S$3,200   (b) break-even at $x = 20$ and $x = 100$**

Notice the shape: profit is zero at 20 and at 100, and the peak sits exactly midway at 60. The vertex of a parabola is always the midpoint of its two roots. That is a free check.

**Example 24** `DBS · pattern`

A fund grows 8% a year. How many **full** years must an investment stay in before it is worth at least double its starting value? Use $log_10 2 = 0.3010$ and $log_10 1.08 = 0.0334$.

**Solution**

Let the start value be $A$. After $n$ years it is $A(1.08)^n$. \
Doubling: $A (1.08)^n = 2A arrow.r (1.08)^n = 2$. \
Take $log_10$ of both sides: $n log_10 1.08 = log_10 2$. \
$n = 0.3010 \div 0.0334 = 9.01$ years. \
Exact doubling happens at $n = 9.01$, which is **more** than 9. \
So after 9 full years the fund is still a hair short of double. \
The next full year carries it past double. \
So 10 full years are needed.

**➜ Answer: 10 full years (exact doubling time $\approx 9.01$ years)**

**Example 25** `GIC · pattern`

Three numbers are in AP. Their sum is 27 and their product is 585. Find the numbers.

**Solution**

Take the three terms as $a - d$, $a$, $a + d$. This makes the sum easy. \
Sum: $(a-d) + a + (a+d) = 3a = 27 arrow.r a = 9$. \
Product: $(a - d) \times a \times (a + d) = a(a^2 - d^2) = 585$. \
$9(81 - d^2) = 585$ \
$81 - d^2 = 585/9 = 65$ \
$d^2 = 81 - 65 = 16$, so $d = 4$ or $d = -4$. \
With $d = 4$: the numbers are $5, 9, 13$. \
Check: $5 + 9 + 13 = 27$ and $5 \times 9 \times 13 = 585$. Correct.

**➜ Answer: $5, 9, 13$**

---
💡 **SHORTCUT**

Three terms in AP: use $a-d, a, a+d$. Four terms: use $a-3d, a-d, a+d, a+3d$ (common difference $2d$). Three terms in GP: use $a/r, a, a r$. The middle-symmetry makes the sum or product collapse in one line.

**Example 26** `Agoda · pattern`

A shuttle covers the same stretch three times: at 30 km/h, then 40 km/h, then 60 km/h. Find its average speed for the whole trip.

**Solution**

Equal distances, different speeds $arrow.r$ use the harmonic mean, not the plain average. \
Let each stretch be $d$ km. Total distance $= 3d$. \
Time $= d/30 + d/40 + d/60$. \
LCM of 30, 40, 60 is 120. \
$d/30 = 4d/120$,   $d/40 = 3d/120$,   $d/60 = 2d/120$. \
Total time $= (4d + 3d + 2d)/120 = 9d/120$. \
Average speed $= (3d) / (9d/120) = 3d \times 120/(9d) = 360/9 = 40$ km/h.

**➜ Answer: 40 km/h**

---
⚠️ **TRAP**

The plain average of 30, 40 and 60 is $130/3 = 43.33$ km/h. That is wrong. Equal distances need the harmonic mean; equal times need the plain mean. Ask which one is equal before you average.

**Example 27** `Sea · pattern`

Given $5^x = 3^y = 15^z$ with $x, y, z$ all non-zero, show that $1/z = 1/x + 1/y$. Then find $z$ when $x = 10$ and $y = 15$.

**Solution**

Let the common value be $k$, so $5^x = k$, $3^y = k$ and $15^z = k$. \
Raise each to the reciprocal power to free the base: \
$5 = k^(1/x)$,   $3 = k^(1/y)$,   $15 = k^(1/z)$. \
But $15 = 5 \times 3$, so \
$k^(1/z) = k^(1/x) \times k^(1/y) = k^(1/x + 1/y)$. \
Same base, so the powers match: \
$ 1/z = 1/x + 1/y $
Now put $x = 10$ and $y = 15$: \
$1/z = 1/10 + 1/15$. \
LCM of 10 and 15 is 30: $1/10 = 3/30$ and $1/15 = 2/30$. \
$1/z = (3 + 2)/30 = 5/30 = 1/6$, so $z = 6$.

**➜ Answer: $1/z = 1/x + 1/y$;   $z = 6$**

**Example 28** `SCB · pattern`

A Bangkok food stall makes THB~38 profit per plate and pays THB~4,560 rent a day. The kitchen can serve at most 260 plates a day. For what numbers of plates is the daily net profit at least THB~1,900? What is the best possible daily net profit?

**Solution**

Let $n$ be the plates sold in a day. \
Net profit $= 38 n - 4560$. \
Condition: $38 n - 4560 \\ge 1900$ \
$38 n \\ge 1900 + 4560 = 6460$ \
$n \\ge 6460/38 = 170$. \
Capacity gives $n \\le 260$. \
So $170 \\le n \\le 260$. \
Best case $n = 260$: net profit $= 38 \times 260 - 4560 = 9880 - 4560 = 5320$.

**➜ Answer: $170 \\le n \\le 260$ plates; maximum net profit THB~5,320**

**Example 29** `Razer · pattern`

For $f(x) = (2x + 3)/(x - 1)$, find $f^(-1)(x)$ and verify it using $x = 4$.

**Solution**

Write $y = (2x+3)/(x-1)$. \
Cross-multiply: $y(x - 1) = 2x + 3$ \
$y x - y = 2x + 3$ \
Collect $x$ terms on one side: $y x - 2x = y + 3$ \
$x(y - 2) = y + 3$ \
$x = (y + 3)/(y - 2)$. \
Swap the letters: $f^(-1)(x) = (x + 3)/(x - 2)$. \
Verify: $f(4) = (2 \times 4 + 3)/(4 - 1) = 11/3$. \
$f^(-1)(11/3) = (11/3 + 3)/(11/3 - 2) = (11/3 + 9/3)/(11/3 - 6/3) = (20/3)/(5/3) = 20/5 = 4$. \
It returns 4, so the inverse is right.

**➜ Answer: $f^(-1)(x) = (x+3)/(x-2)$**

**Example 30** `Grab · pattern`

Three **positive** numbers are in AP with sum 15. If 1, 4 and 19 are added to them in order, the results are in GP. Find the original numbers.

**Solution**

Let the AP be $a - d$, $a$, $a + d$. \
Sum: $3a = 15 arrow.r a = 5$. So the numbers are $5 - d$, $5$, $5 + d$. \
After adding: $(5 - d + 1)$, $(5 + 4)$, $(5 + d + 19)$, i.e. $6 - d$, $9$, $24 + d$. \
GP condition: the middle term squared equals the product of the outer two. \
$9^2 = (6 - d)(24 + d)$ \
$81 = 144 + 6d - 24 d - d^2$ \
$81 = 144 - 18 d - d^2$ \
$d^2 + 18 d - 63 = 0$ \
$D = 18^2 + 4 \times 63 = 324 + 252 = 576$; $sqrt(D) = 24$. \
$d = (-18 plus.minus 24)/2 arrow.r d = 3$ or $d = -21$. \
Test $d = -21$: the numbers would be $5 - (-21) = 26$, $5$, $5 + (-21) = -16$. \
The third one is negative, and the question says all three are positive. Reject $d = -21$. \
(It does pass the GP test — adding gives $27, 9, 3$, ratio $1/3$ — which is exactly why the word **positive** is in the question.) \
Take $d = 3$: the numbers are $2, 5, 8$. \
Check: adding gives $3, 9, 27$, which is a GP with ratio 3, and all three originals are positive. Correct.

**➜ Answer: $2, 5, 8$**

#### Practice — Tier 2 — Singapore & Thailand *(target: 100 s/Q)*

+ A courier hub handles 180 parcels on Monday and 24 more each following day. On which day does the running total first pass 1,500 parcels?
+ A start-up's monthly users grow by 25% a month. If January has 4,096 users, find the users in May and the total across January to May.
+ A vendor's daily profit is $P(x) = -5x^2 + 300x - 2500$ for $x$ combo meals. Find the profit-maximising $x$, the maximum profit, and both break-even points.
+ Three numbers in GP have product 216 and sum 26. Find them.
+ A boat covers 60 km downstream at 20 km/h and returns at 12 km/h. Find the average speed for the round trip.
+ A deposit of S$5,000 grows at 6% a year. Using $log_10 1.06 = 0.0253$ and $log_10 1.5 = 0.1761$, find how many full years until it first exceeds S$7,500.
+ If $f(x) = (3x - 1)/(x + 2)$, find $f^(-1)(5)$.
+ A river-cruise operator charges THB~1,200 per seat when 40 seats are booked. For every extra seat booked above 40, the price **every** passenger pays drops by THB~10. If $n$ extra seats are booked, revenue is $(40 + n)(1200 - 10n)$. Find the $n$ that maximises revenue, and that maximum revenue.
+ The sum of the first $n$ terms of an AP is $3n^2 + 5n$. Find the 10th term.
+ An office lamp loses 15% of its brightness every 1,000 hours. After how many full 1,000-hour blocks does brightness fall below half? Use $log_10 0.85 = -0.0706$ and $log_10 0.5 = -0.3010$.
+ Solve for $x$: $2^(x+2) + 2^(x) = 80$.
+ A warehouse has 4 more shelves than aisles. Total storage slots equal 96, where slots $=$ aisles $\times$ shelves. Find the number of aisles.

<details>
<summary><b>Answer key</b></summary>

**1.** Day 7. $S_n = n/2[360 + 24(n-1)] = n(168 + 12n)$; $S_6 = 6(240) = 1440 < 1500$ and $S_7 = 7(252) = 1764 \\ge 1500$. \
**2.** May $= 4096(1.25)^4 = 4096 \times 2.44140625 = 10000$ users. Total $= 4096(1.25^5 - 1)/0.25 = 4096 \times 8.20703125 = 33616$ users. \
**3.** $x = 30$; max $= -5(900) + 9000 - 2500 = 2000$. Break-even: $x^2 - 60x + 500 = 0 arrow.r x = 10$ or $50$. \
**4.** $2, 6, 18$. Take $a/r, a, a r$: product $a^3 = 216 arrow.r a = 6$; $6/r + 6 + 6r = 26 arrow.r 3r^2 - 10r + 3 = 0 arrow.r r = 3$. \
**5.** $15$ km/h. Equal distances: $"HM" = (2 \times 20 \times 12)/(20+12) = 480/32$. \
**6.** 7 years. Need $(1.06)^n > 1.5 arrow.r n > 0.1761/0.0253 = 6.96$. \
**7.** $f^(-1)(5) = -11/2$. Solve $(3x-1)/(x+2) = 5$: $3x - 1 = 5x + 10 arrow.r -11 = 2x arrow.r x = -11/2$. Check: $f(-11/2) = (-33/2 - 1)/(-11/2 + 2) = (-35/2)/(-7/2) = 5$. \
**8.** $n = 40$. Revenue $= 48000 + 800n - 10n^2$; peak at $n = 800/20 = 40$. Then 80 seats at THB~800 each: $80 \times 800 = 64000$, i.e. THB~64,000. \
**9.** $62$. $t_10 = S_10 - S_9 = (300 + 50) - (243 + 45) = 350 - 288$. \
**10.** 5 blocks. Need $n \times (-0.0706) < -0.3010 arrow.r n > 4.26$. \
**11.** $x = 4$. $2^x (4 + 1) = 80 arrow.r 2^x = 16$. \
**12.** 8 aisles. $a(a+4) = 96 arrow.r a^2 + 4a - 96 = 0 arrow.r (a+12)(a-8) = 0$.

## Tier 3 — Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 31** `Goldman Sachs · pattern`

Given $x + 1/x = 5$, find $x^5 + 1/x^5$ without finding $x$.

**Solution**

**Insight: power sums obey a recursion. $(x^a + x^(-a))(x^b + x^(-b)) = (x^(a+b) + x^(-(a+b))) + (x^(a-b) + x^(-(a-b)))$.**

Write $p_n = x^n + 1/x^n$. We are given $p_1 = 5$. \
Step 1. Square $p_1$: \
$(x + 1/x)^2 = x^2 + 2 + 1/x^2 = 25$, so $p_2 = 25 - 2 = 23$. \
Step 2. Cube $p_1$: \
$(x + 1/x)^3 = x^3 + 1/x^3 + 3(x + 1/x)$, so $125 = p_3 + 3 \times 5$. \
$p_3 = 125 - 15 = 110$. \
Step 3. Multiply $p_2$ and $p_3$: \
$p_2 \times p_3 = (x^2 + 1/x^2)(x^3 + 1/x^3) = x^5 + 1/x + x + 1/x^5 = p_5 + p_1$. \
$23 \times 110 = 2530$. \
$p_5 = 2530 - p_1 = 2530 - 5 = 2525$.

**➜ Answer: $x^5 + 1/x^5 = 2525$**

The same trick chains upward for free: $p_4 = p_2^2 - 2 = 529 - 2 = 527$, and $p_6 = p_3^2 - 2 = 12100 - 2 = 12098$. You never need the value of $x$ (which here is irrational).

**Example 32** `Google · pattern`

Find $1/(1 \times 2) + 1/(2 \times 3) + 1/(3 \times 4) + \dots + 1/(99 \times 100)$.

**Solution**

**Insight: split each term into a difference so that neighbours cancel.**

$1/(n(n+1)) = 1/n - 1/(n+1)$. \
Check on one term: $1/2 - 1/3 = (3-2)/6 = 1/6 = 1/(2 \times 3)$. Correct. \
So the sum becomes \
$(1/1 - 1/2) + (1/2 - 1/3) + (1/3 - 1/4) + \dots + (1/99 - 1/100)$. \
Every middle piece appears once with a $+$ and once with a $-$. They all cancel. \
What survives is the very first and the very last: \
$1 - 1/100 = 99/100 = 0.99$.

**➜ Answer: $99/100$**

**Example 33** `Amazon · pattern`

A fulfilment centre's daily cost in thousands of rupees is $C(x) = 3x + 300/x$, where $x > 0$ is the number of loading bays kept open. Find the $x$ that minimises cost and the minimum cost.

**Solution**

**Insight: a sum of the form "term + constant/term" is smallest when the two terms are equal. That is AM–GM.**

For positive $u, v$: $(u + v)/2 \\ge sqrt(u v)$, so $u + v \\ge 2 sqrt(u v)$, with equality only when $u = v$. \
Take $u = 3x$ and $v = 300/x$. \
$u v = 3x \times 300/x = 900$, a constant — this is what makes the trick work. \
So $C(x) \\ge 2 sqrt(900) = 2 \times 30 = 60$. \
Equality when $3x = 300/x arrow.r 3x^2 = 300 arrow.r x^2 = 100 arrow.r x = 10$ (take the positive root). \
Check: $C(10) = 3 \times 10 + 300/10 = 30 + 30 = 60$. \
Check a neighbour: $C(9) = 27 + 33.33 = 60.33$ and $C(11) = 33 + 27.27 = 60.27$. Both above 60.

**➜ Answer: $x = 10$ bays; minimum cost Rs.~60,000**

---
💡 **SHORTCUT**

AM–GM works only when the product of the parts is a constant. If it is not, force it: split a term into equal pieces. To minimise $2x + 50/x^2$, write it as $x + x + 50/x^2$ — now the product $x \times x \times 50/x^2 = 50$ is constant, and the bound is $3 root(3, 50)$.

**Example 34** `D. E. Shaw · pattern`

If $alpha$ and $beta$ are the roots of $x^2 - 6x + 7 = 0$, find $alpha^4 + beta^4$ without solving the equation.

**Solution**

**Insight: build the answer from the sum and product alone, one power at a time.**

$alpha + beta = 6$,   $alpha beta = 7$. \
Step 1. $alpha^2 + beta^2 = (alpha + beta)^2 - 2 alpha beta = 36 - 14 = 22$. \
Step 2. Square that result: \
$(alpha^2 + beta^2)^2 = alpha^4 + 2 alpha^2 beta^2 + beta^4$ \
$22^2 = alpha^4 + beta^4 + 2 (alpha beta)^2$ \
$484 = alpha^4 + beta^4 + 2 \times 49$ \
$484 = alpha^4 + beta^4 + 98$ \
$alpha^4 + beta^4 = 386$. \
Sanity check: the roots are $3 plus.minus sqrt(2)$, so $alpha \approx 4.414$ and $beta \approx 1.586$. \
$4.414^4 \approx 379.6$ and $1.586^4 \approx 6.3$; the total is about 386. Correct.

**➜ Answer: $386$**

**Example 35** `Microsoft · pattern`

Find the value of $x = sqrt(20 + sqrt(20 + sqrt(20 + \dots)))$, continuing for ever.

**Solution**

**Insight: the tail of the expression is a copy of the whole expression. Name it and the infinity disappears.**

Inside the first square root sits $20 +$ (the same infinite expression), which is $20 + x$. \
So $x = sqrt(20 + x)$. \
Square both sides: $x^2 = 20 + x$ \
$x^2 - x - 20 = 0$ \
$(x - 5)(x + 4) = 0$, so $x = 5$ or $x = -4$. \
A square root is never negative, so reject $-4$. \
$x = 5$. \
Feel the convergence: $sqrt(20) = 4.472$, then $sqrt(24.472) = 4.947$, then $sqrt(24.947) = 4.995$. It is climbing to 5.

**➜ Answer: $x = 5$**

**Example 36** `Adobe · pattern`

Evaluate $log_2 3 \times log_3 4 \times log_4 5 \times \dots \times log_63 64$.

**Solution**

**Insight: change every log to one common base and the product telescopes.**

Change of base: $log_b a = (log a)/(log b)$, using any fixed base (say base 10). \
The product becomes \
$ (log 3)/(log 2) \times (log 4)/(log 3) \times (log 5)/(log 4) \times \dots \times (log 64)/(log 63) $
Each numerator cancels the next denominator: $log 3$ cancels, $log 4$ cancels, and so on up to $log 63$. \
What is left is $(log 64)/(log 2) = log_2 64$. \
$2^6 = 64$, so the value is 6.

**➜ Answer: $6$**

**Example 37** `Uber · pattern`

Two positive numbers $a$ and $b$ add to 18. What is the largest possible value of $a^2 b$?

**Solution**

**Insight: to use AM–GM on $a^2 b$, split $a$ into two equal halves so that all three parts can be made equal.**

Write $a + b = a/2 + a/2 + b = 18$. \
AM–GM on the three positive parts: \
$ (a/2 + a/2 + b)/3 \\ge root(3, a/2 \times a/2 \times b) $
$ 18/3 \\ge root(3, (a^2 b)/4) $
$ 6 \\ge root(3, (a^2 b)/4) $
Cube both sides: $216 \\ge (a^2 b)/4$, so $a^2 b \\le 864$. \
Equality needs all three parts equal: $a/2 = b$. \
With $a + b = 18$ and $a = 2b$: $2b + b = 18 arrow.r b = 6$, $a = 12$. \
Check: $a^2 b = 144 \times 6 = 864$. \
Check a neighbour: $a = 13, b = 5$ gives $169 \times 5 = 845 < 864$. And $a = 11, b = 7$ gives $121 \times 7 = 847 < 864$.

**➜ Answer: $864$, at $a = 12$ and $b = 6$**

**Example 38** `Goldman Sachs · pattern`

Find $S = 1/2 + 2/4 + 3/8 + 4/16 + \dots$ continuing for ever.

**Solution**

**Insight: this is an AP ($1, 2, 3, \dots$) times a GP ($1/2, 1/4, 1/8, \dots$). Subtract a shifted copy of the sum and it collapses into a plain GP.**

$ S = 1/2 + 2/4 + 3/8 + 4/16 + \dots $
Multiply by $1/2$: \
$ S/2 = 1/4 + 2/8 + 3/16 + \dots $
Subtract the second line from the first, matching denominators: \
$ S - S/2 = 1/2 + (2/4 - 1/4) + (3/8 - 2/8) + (4/16 - 3/16) + \dots $
$ S/2 = 1/2 + 1/4 + 1/8 + 1/16 + \dots $
The right side is an infinite GP with $a = 1/2$ and $r = 1/2$: \
$ S/2 = (1/2)/(1 - 1/2) = (1/2)/(1/2) = 1 $
So $S = 2$. \
Partial check: $0.5 + 0.5 + 0.375 + 0.25 + 0.15625 = 1.78125$, and later terms keep adding smaller amounts towards 2.

**➜ Answer: $S = 2$**

#### Practice — Tier 3 — Product *(target: 4 min/Q)*

+ If $x - 1/x = 3$, find $x^3 - 1/x^3$ and $x^4 + 1/x^4$.
+ Find $1/(1 \times 3) + 1/(3 \times 5) + 1/(5 \times 7) + \dots + 1/(99 \times 101)$.
+ For $x > 0$, find the least value of $4x + 9/x$, and the $x$ where it occurs.
+ If $alpha, beta$ are the roots of $x^2 - 4x + 1 = 0$, find $alpha^3 + beta^3$ and $1/alpha^2 + 1/beta^2$.
+ Find the value of $x = root(3, 6 + root(3, 6 + root(3, 6 + \dots)))$ — hint: set up the cubic and look for an integer root.
+ Evaluate $log_3 5 \times log_5 7 \times log_7 9 \times log_9 81$.
+ Two positive numbers have sum 30. Maximise $a b^2$.
+ Find $sum_(n=1)^infinity n/3^n$.

<details>
<summary><b>Answer key</b></summary>

**1.** $x^3 - 1/x^3 = 36$ and $x^4 + 1/x^4 = 119$. From $x - 1/x = 3$: cube it, $x^3 - 1/x^3 - 3(x - 1/x) = 27$, so $x^3 - 1/x^3 = 27 + 9 = 36$. Also $x^2 + 1/x^2 = 3^2 + 2 = 11$, so $x^4 + 1/x^4 = 11^2 - 2 = 119$. \
**2.** $50/101$. Here $1/((2k-1)(2k+1)) = 1/2 [1/(2k-1) - 1/(2k+1)]$. The sum telescopes to $1/2 (1 - 1/101) = 1/2 \times 100/101$. Note the extra factor of $1/2$ — it is the gap between the two factors. \
**3.** Least value 12, at $x = 3/2$. AM–GM: $4x + 9/x \\ge 2 sqrt(4x \times 9/x) = 2 sqrt(36) = 12$; equality when $4x = 9/x arrow.r x^2 = 9/4$. \
**4.** $alpha^3 + beta^3 = 52$ and $1/alpha^2 + 1/beta^2 = 14$. Sum $= 4$, product $= 1$. $alpha^3 + beta^3 = (alpha+beta)^3 - 3 alpha beta (alpha + beta) = 64 - 12 = 52$. And $1/alpha^2 + 1/beta^2 = (alpha^2 + beta^2)/(alpha beta)^2 = (16 - 2)/1 = 14$. \
**5.** $x = 2$. The tail repeats, so $x = root(3, 6 + x) arrow.r x^3 = x + 6 arrow.r x^3 - x - 6 = 0$. Test $x = 2$: $8 - 2 - 6 = 0$. Factor: $(x-2)(x^2 + 2x + 3) = 0$; the quadratic has $D = 4 - 12 < 0$, so 2 is the only real root. \
**6.** $4$. Chain to base 3: the product telescopes to $log_3 81 = 4$, since $3^4 = 81$. Each log's argument becomes the next log's base, so all middle logs cancel. \
**7.** $4000$, at $a = 10$, $b = 20$. Split $b$: $a + b/2 + b/2 = 30$, so $10 \\ge root(3, a b^2 / 4)$, giving $a b^2 \\le 4000$; equality at $a = b/2$. \
**8.** $3/4$. Let $S = sum n/3^n$. Then $S/3 = sum n/3^(n+1)$; subtracting gives $ (2S)/3 = 1/3 + 1/9 + 1/27 + \dots = (1/3)/(1 - 1/3) = 1/2$, so $S = 3/4$.

## Mixed set — exam conditions

#### Practice — Tier 1 — Service *(target: 90 s/Q · 18 questions · 27 min)*

+ Solve $6x - 11 = 2x + 21$.
+ If $alpha, beta$ are the roots of $3x^2 - 12x + 5 = 0$, find $alpha + beta$.
+ Find the 18th term of the AP $4, 11, 18, \dots$
+ Simplify $(64)^(2/3) \div (16)^(1/2)$.
+ Solve $log_3 (x + 6) = 2$.
+ A car's resale value drops 20% a year from Rs.~9,00,000. Find its value after 3 years.
+ Find the sum $2 + 4 + 6 + \dots + 100$.
+ Solve $5 - 2x \\ge 11$.
+ If $f(x) = x^2 - 3x$, find $f(f(2))$.
+ The sum to infinity of a GP is 45 and its first term is 30. Find the common ratio.
+ Find $k$ so that $x^2 - k x + 25 = 0$ has equal roots.
+ If $x + 1/x = 4$, find $x^3 + 1/x^3$.
+ A phone plan costs THB~350 a month plus THB~2 per GB. For how many GB is the bill at most THB~500?
+ Find the remainder when $f(x) = x^4 - 5x^2 + 6x - 9$ is divided by $(x - 2)$.
+ Three numbers in AP have sum 45 and the largest is twice the smallest. Find them.
+ Find $1/(2 \times 3) + 1/(3 \times 4) + \dots + 1/(20 \times 21)$.
+ For $x > 0$, find the minimum of $x + 49/x$.
+ Solve $3^(2x) - 10 \times 3^x + 9 = 0$.

<details>
<summary><b>Answer key</b></summary>

**1.** $x = 8$. $4x = 32$. \
**2.** $4$. Sum $= -(-12)/3 = 4$. \
**3.** $123$. $4 + 17 \times 7 = 4 + 119$. \
**4.** $4$. $64^(2/3) = 4^2 = 16$; $16^(1/2) = 4$; $16 \div 4 = 4$. \
**5.** $x = 3$. $x + 6 = 3^2 = 9$. \
**6.** Rs.~4,60,800. $900000 \times (0.8)^3 = 900000 \times 0.512$. \
**7.** $2550$. 50 terms; $50/2 (2 + 100) = 25 \times 102$. \
**8.** $x \\le -3$. $-2x \\ge 6$, divide by $-2$ and flip. \
**9.** $10$. $f(2) = 4 - 6 = -2$; then $f(-2) = (-2)^2 - 3(-2) = 4 + 6 = 10$. \
**10.** $r = 1/3$. $30/(1-r) = 45 arrow.r 1 - r = 2/3$. \
**11.** $k = plus.minus 10$. $k^2 = 100$. \
**12.** $52$. $4^3 - 3 \times 4 = 64 - 12$. \
**13.** At most 75 GB. $350 + 2g \\le 500 arrow.r 2g \\le 150$. \
**14.** $-1$. Remainder $= f(2) = 16 - 20 + 12 - 9 = -1$. \
**15.** $10, 15, 20$. Take $a-d, a, a+d$: $3a = 45 arrow.r a = 15$. Largest is twice smallest: $15 + d = 2(15 - d) arrow.r 3d = 15 arrow.r d = 5$. \
**16.** $19/42$. Telescoping: $1/2 - 1/21 = (21 - 2)/42$. \
**17.** $14$, at $x = 7$. AM–GM: $2 sqrt(49) = 14$. \
**18.** $x = 0$ or $x = 2$. Let $t = 3^x$: $t^2 - 10t + 9 = 0 arrow.r t = 1$ or $9$, so $3^x = 3^0$ or $3^2$.

## 📋 One-page revision card

**Quadratics** — $x = (-b plus.minus sqrt(b^2-4a c))/(2a)$. Sum $= -b/a$, product $= c/a$. $D>0$ distinct, $D=0$ equal, $D<0$ none. Vertex at $x = -b/(2a)$ — always the midpoint of the two roots.

**AP** — $t_n = a + (n-1)d$; $S_n = n/2[2a + (n-1)d] = n/2(a + l)$. Three terms: $a-d, a, a+d$.

**GP** — $t_n = a r^(n-1)$; $S_n = a(r^n-1)/(r-1)$; $S_infinity = a/(1-r)$ for $|r|<1$. Three terms: $a/r, a, a r$.

**Means** — $"AM" = (a+b)/2$, $"GM" = sqrt(a b)$, $"HM" = (2a b)/(a+b)$, and $"GM"^2 = "AM" \times "HM"$, with $"AM" \\ge "GM" \\ge "HM"$.

**Power sums** — $x + 1/x = k arrow.r x^2 + 1/x^2 = k^2 - 2$, $x^3 + 1/x^3 = k^3 - 3k$, and $p_(m+n) = p_m p_n - p_(m-n)$.

**Logs** — $log(m n) = log m + log n$; $log(m^p) = p log m$; $log_b a = 1/(log_a b)$; digits of $N$ $= floor(log_10 N) + 1$.

**Indices** — $a^(m/n) = root(n, a^m)$; $a^(-n) = 1/a^n$; equal bases $arrow.r$ equal powers.

**Inequalities** — flip on multiply/divide by a negative. For $x>0$: $x + k/x \\ge 2 sqrt(k)$ at $x = sqrt(k)$.

**Shortcuts worth memorising**
- Growth/decay of $p%$ for $n$ periods: multiply by $(1 plus.minus p/100)^n$. Never repeat-subtract.
- "Running total first crosses $T$": estimate $n$, then test $n$ and $n plus.minus 1$. Skip the quadratic.
- $1/(n(n+1)) = 1/n - 1/(n+1)$ — telescopes. With a gap of 2, an extra $1/2$ appears in front.
- AM–GM only works when the product of the parts is constant. Split a term into equal pieces to force it.
- Nested radical or continued fraction: name the whole thing $x$, spot the copy inside, solve.

**Top 5 traps**
+ Sum of roots is $-b/a$. In $x^2 - 5x + 3$ it is $+5$, not $-5$.
+ Dividing an inequality by a negative flips the sign. $-2x \\le 10$ gives $x \\ge -5$.
+ Log solutions must be re-checked: any root making a log's input zero or negative is rejected.
+ $f(g(x)) \\ne g(f(x))$ in general. Work from the innermost bracket outward.
+ Equal distances at different speeds need the harmonic mean, not the plain average.

</details>

</details>

</details>

</details>
