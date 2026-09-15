# Chapter 20 — Clocks, Calendars & Classic Puzzles

*One angle formula, one odd-day rule, and a clear head.*

## What you need to know

**WHAT YOU NEED TO KNOW**

**Clock — speeds**

- Minute hand: $360° \div 60 = 6°$ per minute.
- Hour hand: $360° \div 720 = 0.5°$ per minute (it moves $30°$ in one hour).
- Relative speed of minute hand over hour hand: $6 - 0.5 = 5.5°$ per minute.
- In 60 minutes the minute hand gains 55 minute-spaces on the hour hand.

**Clock — the one formula you need**

$ theta = |30 H - 5.5 M| $

$H$ = hour reading, $M$ = minutes past the hour. If $theta > 180°$, the answer is $360° - theta$.

**Clock — when is the angle exactly $theta$?** Between $H$ and $H+1$ o'clock:

$ M = 2/11 (30 H plus.minus theta) $

Keep any value with $0 \\le M < 60$. Special cases: $theta = 0$ (hands together) gives $M = (60 H)/11$; $theta = 180$ gives the opposite position.

**Clock — how often**

#table(columns: 3,
[Event], [In 12 hours], [In 24 hours],
[Hands coincide ($0°$)], [11], [22],
[Hands opposite ($180°$)], [11], [22],
[Hands in a straight line], [22], [44],
[Hands at right angles], [22], [44],
[Hands at any other fixed angle], [22], [44],
)

- Gap between two coincidences: $720/11 = 65 5/11$ minutes.
- All three hands (hour, minute, second) coincide only at 12 o'clock: **twice a day**.
- Mirror image of a clock time $= 11:60 - "time"$ (use $23:60$ when the hour reads 12).

**Faulty clocks**

- Going forward: true time known #sym.arrow add the gain, or subtract the loss.
- Going backward: the clock shows $C$ minutes while true time is $T$ minutes, and $ T/C = "true minutes per hour" / "clock minutes per hour". $ A clock gaining $g$ min per hour shows $60 + g$ clock-minutes per 60 true minutes.
- A clock that gains or loses $d$ minutes per day next shows the correct time after $720 \div d$ days (it must drift a whole 12 hours).
- Two clocks drifting apart: if one gains and the other loses, the gap grows at the **sum** of the two rates; if both gain (or both lose), it grows at the **difference**.

**Calendar — odd days**

- "Odd days" = days left over after taking out whole weeks.
- Ordinary year (365 days) = 1 odd day. Leap year (366 days) = 2 odd days.
- Leap year: divisible by 4, but a century year must be divisible by 400. So 1900 is not a leap year; 2000 is.
- 100 years = 5 odd days.   200 years = 3.   300 years = 1.   400 years = 0.
- 400 years $= 400 \times 365 + 97 = 146097$ days $= 20871$ whole weeks. The calendar repeats exactly every 400 years.
- Day code: 0 = Sunday, 1 = Monday, 2 = Tuesday, 3 = Wednesday, 4 = Thursday, 5 = Friday, 6 = Saturday.

**Calendar — days in each month (running totals, ordinary year)**

#table(columns: 6,
[Jan], [Feb], [Mar], [Apr], [May], [Jun],
[31], [59], [90], [120], [151], [181],
[Jul], [Aug], [Sep], [Oct], [Nov], [Dec],
[212], [243], [273], [304], [334], [365],
)

Add 1 to every total from Feb onward in a leap year.

**Calendar — method for "what day was DD-MM-YYYY?"**

+ Odd days from the completed centuries (use the 0 / 1 / 3 / 5 table).
+ Odd days from the completed years of the current century: $("ordinary years") \times 1 + ("leap years") \times 2$, then take mod 7.
+ Odd days from the current year: day-of-year number, mod 7.
+ Add all three, take mod 7, read off the day code.

**Calendar — repeating years**

- An ordinary year's calendar repeats after 6 or 11 years (12 if a non-leap century year such as 2100 falls in between); a leap year's repeats after 28 years (again, as long as no non-leap century year falls in between).
- A month of 31 days has 5 of the first three weekdays; a month of 30 days has 5 of the first two.
- Probability a random year has 53 Mondays: ordinary $1/7$, leap $2/7$, any year $71/400$.

**Ages**

- Fix one unknown as $x$ = the **present** age of the smaller person. Every other age is then $x plus.minus$ something.
- "$n$ years ago" means subtract $n$ from **both** ages. "In $n$ years" means add $n$ to **both**.
- The **difference** of two ages never changes. Use it to check your answer.

**Weighing and balance puzzles**

- Weights on **one pan only**: powers of 2 ($1, 2, 4, 8, 16, \dots$) reach every whole number up to $2^n - 1$.
- Weights allowed on **both pans**: powers of 3 ($1, 3, 9, 27, 81, \dots$) reach every whole number up to $(3^n - 1)/2$. Four weights reach 40; five reach 121.
- One odd coin among $N$, and you know whether it is heavy or light: split into 3 near-equal groups. Minimum weighings $= ceil(log_3 N)$. So $N \\le 3$ needs 1, $N \\le 9$ needs 2, $N \\le 27$ needs 3.
- One odd coin among 12 with **unknown** direction: 3 weighings. Counting bound: 3 weighings give $3^3 = 27$ outcome-patterns, and $N$ coins with 2 directions need $2N$ patterns, so $N \\le 13$. Twelve is the largest $N$ for which 3 weighings always name the coin **and** say heavy or light.

**Crossing and measuring puzzles**

- Farmer, wolf, goat, cabbage: 7 crossings.
- Torch on a bridge, only 2 may cross at a time, the pair moves at the slower speed. Move the two **slowest** people first. With the two slowest $a < b$ and the two fastest $f_1 < f_2$, the cost of getting $a$ and $b$ across (and leaving $f_1, f_2$ at the start) is $ min(f_1 + 2 f_2 + b,   2 f_1 + a + b). $ Then repeat on the people who are left.
- Two jugs of capacity $p$ and $q$ can measure exactly $v$ litres if and only if $v$ is a multiple of $gcd(p, q)$ and $v \\le max(p, q)$.

**Matchsticks**

- A single row of $n$ unit squares needs $3n + 1$ sticks.
- An $n \times n$ grid of unit squares needs $2n(n+1)$ sticks.

## Warm-up

### Warm-up

**Example 1**

What is the angle between the hands at 3:00?

**Solution**

$H = 3$, $M = 0$. $ theta = |30 \times 3 - 5.5 \times 0| = |90 - 0| = 90°. $

**➜ Answer: $90°$**

**Example 2**

What is the angle between the hands at 4:20?

**Solution**

$H = 4$, $M = 20$.

$30 \times 4 = 120$.   $5.5 \times 20 = 110$.

$ theta = |120 - 110| = 10°. $

**➜ Answer: $10°$**

**Example 3**

How many times in 24 hours do the two hands point in the same direction?

**Solution**

They coincide 11 times in 12 hours (not 12, because the 12 o'clock overlap is shared by the two halves).

In 24 hours: $11 \times 2 = 22$.

**➜ Answer: 22 times**

**Example 4**

Was 1900 a leap year?

**Solution**

$1900 \div 4 = 475$, so it passes the first test.

But 1900 is a century year, so it must also be divisible by 400. $1900 \div 400 = 4.75$ — not a whole number.

So 1900 was an ordinary year of 365 days. (2000 **was** a leap year: $2000 \div 400 = 5$.)

**➜ Answer: No**

**Example 5**

1 January 2026 is a Thursday. What day is 31 December 2026?

**Solution**

2026 is not divisible by 4, so it is an ordinary year: 365 days.

1 January is day 1 and 31 December is day 365. The gap between them is $365 - 1 = 364$ days.

$364 = 52 \times 7$, which is exactly 52 weeks with nothing left over.

So 31 December falls on the same weekday as 1 January.

**➜ Answer: Thursday**

**Example 6**

A clock loses 5 minutes every hour. It is set right at 6:00 a.m. What does it show at 10:00 a.m. true time?

**Solution**

True time passed $= 10 - 6 = 4$ hours.

Loss $= 4 \times 5 = 20$ minutes.

The clock is behind by 20 minutes: $10:00 - 0:20 = 9:40$.

**➜ Answer: 9:40 a.m.**

**Example 7**

A father is 3 times as old as his son. The sum of their ages is 48. How old is the son?

**Solution**

Let the son be $x$ years. Then the father is $3x$.

$ x + 3x = 48 arrow.r.double 4x = 48 arrow.r.double x = 12. $

Check: son 12, father 36, sum $= 48$. #sym.checkmark

**➜ Answer: 12 years**

**Example 8**

Nine identical-looking balls; one is heavier. Using a pan balance, what is the smallest number of weighings that always finds it?

**Solution**

Split 9 into three groups of 3.

Weighing 1: put group A against group B. Either one side sinks (the heavy ball is there), or they balance (the heavy ball is in C). Either way you are left with 3 balls.

Weighing 2: take 2 of those 3 and weigh them. If one sinks, that is it; if they balance, it is the third.

$9 \\le 3^2$, so 2 weighings are enough.

**➜ Answer: 2 weighings**

## Tier 1 — Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

Find the angle between the hands of a clock at 5:40.

**Solution**

$H = 5$, $M = 40$.

$30 H = 30 \times 5 = 150$.

$5.5 M = 5.5 \times 40 = 220$.

$ theta = |150 - 220| = 70°. $

$70 < 180$, so no adjustment is needed.

**➜ Answer: $70°$**

**Example 10** `Accenture pattern`

Find the angle between the hands at 10:10.

**Solution**

$H = 10$, $M = 10$.

$30 H = 300$.   $5.5 M = 55$.

$ theta = |300 - 55| = 245°. $

This is more than $180°$, so take the other way round: $ 360 - 245 = 115°. $

**➜ Answer: $115°$**

Answer choices in these tests almost always give the **smaller** angle. If your number is above 180, subtract it from 360 before you look at the options.

---
⚠️ **TRAP**

**$5.5 \times M$, not $6 \times M$.** The $5.5$ already allows for the hour hand creeping forward while the minutes pass. Using $6M$ gives an answer that is wrong by $0.5 M$ degrees — at 40 minutes past, that is a $20°$ error.

**Example 11** `Infosys pattern`

At what time between 4 and 5 o'clock are the two hands together?

**Solution**

Use $M = 2/11 (30H plus.minus theta)$ with $H = 4$ and $theta = 0$.

$ M = 2/11 (30 \times 4) = 2/11 \times 120 = 240/11. $

$240 \div 11 = 21$ remainder $9$, so $M = 21 9/11$ minutes.

**Check:** $theta = |30 \times 4 - 5.5 \times 240/11| = |120 - (5.5 \times 240)/11| = |120 - 1320/11| = |120 - 120| = 0$. #sym.checkmark

**➜ Answer: 4:21 and $9/11$ minutes past**

**Example 12** `Wipro pattern`

At what time between 8 and 9 o'clock are the hands exactly opposite each other?

**Solution**

Opposite means $theta = 180°$. Here $H = 8$, so $30H = 240$.

Try the minus sign first: $ M = 2/11 (240 - 180) = 2/11 \times 60 = 120/11 = 10 10/11. $

This lies between 0 and 60, so it is valid.

Try the plus sign: $M = 2/11 (240 + 180) = 840/11 = 76.36$, which is more than 60. Reject it.

**Check:** $5.5 \times 120/11 = 660/11 = 60$, and $|240 - 60| = 180$. #sym.checkmark

**➜ Answer: 8:10 and $10/11$ minutes past**

**Example 13** `Capgemini pattern`

At what times between 3 and 4 o'clock are the hands at right angles?

**Solution**

$theta = 90°$, $H = 3$, so $30H = 90$.

Minus sign: $ M = 2/11 (90 - 90) = 0. $ So the first time is exactly 3:00.

Plus sign: $ M = 2/11 (90 + 90) = 2/11 \times 180 = 360/11. $

$360 \div 11 = 32$ remainder $8$, so $M = 32 8/11$.

**Check:** $5.5 \times 360/11 = 1980/11 = 180$, and $|90 - 180| = 90$. #sym.checkmark

**➜ Answer: 3:00 and 3:32 and $8/11$ minutes past**

---
💡 **SHORTCUT**

**Two answers per hour, almost always.** For any angle strictly between $0°$ and $180°$, both signs usually give a valid minute value, so there are two such times in that hour. Compute both, then throw away any $M$ outside $0 \\le M < 60$.

**Example 14** `TCS NQT pattern`

A watch gains 10 minutes every hour. It is set right at 9:00 a.m. What is the **true** time when the watch shows 4:00 p.m.?

**Solution**

The watch shows $9$ a.m. to $4$ p.m. $= 7$ hours $= 420$ watch-minutes.

Rate: in 60 true minutes the watch shows $60 + 10 = 70$ watch-minutes.

So true minutes $=$ watch-minutes $\times 60/70$: $ 420 \times 60/70 = 420 \times 6/7 = 360 "minutes" = 6 "hours". $

True time $= 9:00 "a.m." + 6 "h" = 3:00$ p.m.

**➜ Answer: 3:00 p.m.**

---
⚠️ **TRAP**

**"Gains 10 minutes" does not mean "subtract 10 minutes".** The gain builds up with every hour that passes. Set up the ratio $60 : 70$ and scale — never subtract a flat amount unless the true elapsed time is what you were given.

**Example 15** `Cognizant pattern`

A clock loses 8 minutes every day. If it is set right now, after how many days will it show the correct time again?

**Solution**

A 12-hour clock face shows the correct time again only when it has drifted a whole $12$ hours.

$12 "hours" = 12 \times 60 = 720$ minutes.

Days needed $= 720 \div 8 = 90$.

**➜ Answer: 90 days**

**Example 16** `Accenture pattern`

What day of the week is 15 August 2026?

**Solution**

**Step 1 — completed centuries.** 2000 completed years $=$ 1600 years (0 odd days) $+$ 400 years (0 odd days) $= 0$ odd days.

**Step 2 — completed years 2001 to 2025.** That is 25 years.

Leap years: 2004, 2008, 2012, 2016, 2020, 2024 $arrow.r 6$ leap years.

Ordinary years: $25 - 6 = 19$.

Odd days $= 19 \times 1 + 6 \times 2 = 19 + 12 = 31$.

$31 \div 7 = 4$ remainder $3$, so 3 odd days.

**Step 3 — days inside 2026 up to 15 August.** 2026 is ordinary. Using the running totals, the end of July is day 212.

$212 + 15 = 227$.

$227 \div 7 = 32$ remainder $3$, so 3 odd days.

**Step 4 — add.** $0 + 3 + 3 = 6$ odd days.

Day code 6 $=$ Saturday.

**➜ Answer: Saturday**

**Example 17** `Infosys pattern`

What day of the week was 26 January 1950?

**Solution**

**Step 1 — completed centuries.** 1900 completed years $=$ 1600 (0 odd days) $+$ 300 (1 odd day) $= 1$ odd day.

**Step 2 — completed years 1901 to 1949.** That is 49 years.

Leap years: 1904, 1908, $\dots$, 1948. Count $= (1948 - 1904)/4 + 1 = 44/4 + 1 = 11 + 1 = 12$.

Ordinary years: $49 - 12 = 37$.

Odd days $= 37 \times 1 + 12 \times 2 = 37 + 24 = 61$.

$61 \div 7 = 8$ remainder $5$, so 5 odd days.

**Step 3 — days inside 1950 up to 26 January.** That is simply 26.

$26 \div 7 = 3$ remainder $5$, so 5 odd days.

**Step 4 — add.** $1 + 5 + 5 = 11$. $11 \div 7 = 1$ remainder $4$.

Day code 4 $=$ Thursday.

**➜ Answer: Thursday**

---
💡 **SHORTCUT**

**Never add up 365s.** Convert each block to odd days first (century block, whole years, days in the current year), add three small numbers, take mod 7 once at the end. The whole computation fits in four lines.

**Example 18** `Wipro pattern`

A father is 4 times as old as his son. In 12 years the father will be twice as old as the son. Find their present ages.

**Solution**

Let the son be $s$ years now. Then the father is $4s$.

In 12 years: son $= s + 12$, father $= 4s + 12$.

The condition gives $ 4s + 12 = 2(s + 12). $

$ 4s + 12 = 2s + 24 $
$ 4s - 2s = 24 - 12 $
$ 2s = 12 arrow.r.double s = 6. $

Father $= 4 \times 6 = 24$.

**Check:** in 12 years the son is 18 and the father is 36, and $36 = 2 \times 18$. #sym.checkmark

**➜ Answer: Son 6 years, father 24 years**

**Example 19** `Capgemini pattern`

The ages of Aarav and Bhavna are in the ratio $4 : 5$. Six years from now the ratio will be $5 : 6$. Find their present ages.

**Solution**

Let the ages be $4x$ and $5x$.

In 6 years: $4x + 6$ and $5x + 6$.

$ (4x + 6)/(5x + 6) = 5/6 $

Cross-multiply: $ 6(4x + 6) = 5(5x + 6) $
$ 24x + 36 = 25x + 30 $
$ 36 - 30 = 25x - 24x $
$ 6 = x. $

Aarav $= 4 \times 6 = 24$. Bhavna $= 5 \times 6 = 30$.

**Check:** in 6 years they are 30 and 36, and $30/36 = 5/6$. #sym.checkmark

**➜ Answer: 24 years and 30 years**

**Example 20** `TCS NQT pattern`

You have 8 coins that look the same. One is heavier than the other seven, which all weigh the same. Using only a pan balance, find the heavy coin in 2 weighings. Describe the plan.

**Solution**

**Weighing 1.** Split as $3 + 3 + 2$. Put the two groups of 3 on the pans.

- If one side sinks, the heavy coin is among those 3.
- If they balance, the heavy coin is among the 2 set aside.

**Weighing 2, case A (3 suspects).** Weigh coin 1 against coin 2. If one sinks it is the heavy one; if they balance it is coin 3.

**Weighing 2, case B (2 suspects).** Weigh them against each other. The side that sinks is the heavy coin.

Two weighings always finish the job because $8 \\le 3^2 = 9$.

**➜ Answer: 2 weighings, splitting $3 + 3 + 2$**

#### Practice — Tier 1 — Service *(target: 60 s/Q)*

+ Find the angle between the hands at 2:30.
+ Find the angle between the hands at 6:40.
+ At what time between 7 and 8 o'clock are the hands together?
+ How many times in 12 hours are the hands at right angles?
+ A clock gains 6 minutes a day and is set right at noon. What will it show 5 days later at noon, true time?
+ A watch loses 10 minutes every hour and is set right at 7:00 a.m. What is the true time when the watch shows 12 noon?
+ How many leap years are there from 2001 to 2100 inclusive?
+ 1 January 2025 is a Wednesday. What day is 1 January 2026?
+ What day of the week was 1 May 2005?
+ How many odd days are there in 300 years?
+ A month of 31 days begins on a Friday. How many Saturdays does it have?
+ A son's age is one third of his father's. In 12 years it will be one half. Find both present ages.
+ A mother and her daughter are 60 years old in total. Ten years ago the mother was 7 times as old as the daughter. Find their present ages.
+ What is the least number of pan-balance weighings that always finds the one heavier ball among 27?
+ The day after tomorrow is Sunday. What was the day before yesterday?

<details>
<summary><b>Answer key</b></summary>

+ **$105°$.** $|30 \times 2 - 5.5 \times 30| = |60 - 165| = 105$.
+ **$40°$.** $|30 \times 6 - 5.5 \times 40| = |180 - 220| = 40$.
+ **7:38 and $2/11$ min.** $M = 2/11 (30 \times 7) = 420/11 = 38 2/11$.
+ **22.** Two right angles in most hours, but the 3 o'clock and 9 o'clock overlaps are shared, so it is 22, not 24.
+ **12:30 p.m.** Gain $= 5 \times 6 = 30$ minutes, and the clock runs fast, so it reads half an hour ahead.
+ **1:00 p.m.** The watch shows 5 h $= 300$ watch-min; it shows only 50 watch-min per 60 true min, so true $= 300 \times 60/50 = 360$ min $= 6$ h. $7:00 + 6 = 13:00$.
+ **24.** 2004, 2008, $\dots$, 2096 is $(2096-2004)/4 + 1 = 24$ years. 2100 is a century year not divisible by 400, so it is not a leap year.
+ **Thursday.** 2025 is an ordinary year, so it carries 1 odd day.
+ **Sunday.** Centuries: 0. Years 2001–2004: 3 ordinary $+$ 1 leap $= 3 + 2 = 5$. Days in 2005 to 1 May: $120 + 1 = 121$, and $121 = 17 \times 7 + 2$, so 2. Total $5 + 2 = 7 arrow.r 0 arrow.r$ Sunday.
+ **1.** 100 years give 5, so 300 give 15, and $15 \div 7$ leaves 1.
+ **5.** $31 = 4 \times 7 + 3$, so the first three weekdays (Friday, Saturday, Sunday) each occur 5 times.
+ **Son 12, father 36.** $s = f/3$ and $s + 12 = (f + 12)/2$ give $2s + 24 = 3s + 12$, so $s = 12$. Check: $24$ and $48$. #sym.checkmark
+ **Mother 45, daughter 15.** $m + d = 60$ and $m - 10 = 7(d - 10)$ give $m = 7d - 60$, so $8d = 120$ and $d = 15$. Check: 35 and 5, and $35 = 7 \times 5$. #sym.checkmark
+ **3.** $27 = 3^3$, so three three-way splits are enough and nothing smaller works.
+ **Wednesday.** Day after tomorrow is Sunday, so today is Friday, and the day before yesterday was Wednesday.

## Tier 2 — Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 21** `Grab · pattern`

A wall clock in a Bangkok dispatch office gains 12 minutes every hour. It was set correct at 9:00 a.m. A supervisor looks at it and reads 5:00 p.m. What is the true time?

**Solution**

**What the clock shows:** 9:00 a.m. to 5:00 p.m. $= 8$ hours $= 480$ clock-minutes.

**Rate:** in 60 true minutes this clock runs through $60 + 12 = 72$ clock-minutes.

So every 72 clock-minutes correspond to 60 true minutes: $ "true minutes" = 480 \times 60/72. $

$480 \times 60 = 28800$.   $28800 \div 72 = 400$.

True elapsed $= 400$ minutes $= 6$ hours 40 minutes.

True time $= 9:00 "a.m." + 6 "h" 40 "min" = 3:40$ p.m.

**➜ Answer: 3:40 p.m.**

**Example 22** `DBS · pattern`

A clock is set right at 8:00 a.m. It gains 10 minutes in 24 hours. What is the true time when the clock shows 1:00 p.m. on the next day?

**Solution**

**What the clock shows:** 8:00 a.m. on day 1 to 1:00 p.m. on day 2.

8 a.m. to 8 a.m. is 24 hours; 8 a.m. to 1 p.m. is 5 hours more. Total $= 29$ hours.

**Rate:** in $24 \times 60 = 1440$ true minutes this clock shows $1440 + 10 = 1450$ clock-minutes.

$ "true time" = 29 \times 1440/1450 = 29 \times 144/145. $

$145 = 5 \times 29$, so $29/145 = 1/5$: $ 29 \times 144/145 = 144/5 = 28.8 "hours". $

$0.8$ hour $= 0.8 \times 60 = 48$ minutes.

True elapsed $= 28$ hours 48 minutes.

$8:00 "a.m." + 24 "h" = 8:00$ a.m. next day. Then $+ 4$ h 48 min $= 12:48$ p.m.

**➜ Answer: 12:48 p.m. on the next day**

---
💡 **SHORTCUT**

**Cancel before you divide.** In $29 \times 1440 / 1450$ notice $1450 = 5 \times 290 = 5 \times 10 \times 29$. The 29 cancels straight away and the sum becomes $144/5$. Hunting for a common factor first turns a messy division into one line.

**Example 23** `Shopee · pattern`

Two clocks in a warehouse are set to the correct time at 12 noon. One gains 1 minute per hour; the other loses 2 minutes per hour. At what time will the two clocks be exactly 1 hour apart?

**Solution**

**Insight: work with the gap between them, not with either clock alone.**

In 1 true hour, clock A moves ahead of correct time by 1 minute and clock B falls behind by 2 minutes.

So the gap between A and B grows by $1 + 2 = 3$ minutes every hour.

We need a gap of $1$ hour $= 60$ minutes: $ "hours" = 60 \div 3 = 20. $

$12$ noon $+ 20$ hours $= 8:00$ a.m. the next day.

**➜ Answer: 8:00 a.m. the next day**

**Example 24** `Agoda · pattern`

A hotel runs a maintenance cycle every 45 days. The first cycle starts on Monday, 3 March 2025. On what date and weekday does the second cycle start?

**Solution**

**The date.** 2025 is not a leap year. Day-of-year for 3 March $= 59 + 3 = 62$.

Add 45 days: $62 + 45 = 107$.

Day 107 of an ordinary year: end of March is day 90, so $107 - 90 = 17$ April.

**The weekday.** $45 \div 7 = 6$ remainder $3$.

Monday $+ 3$ days $=$ Thursday.

**Check by the odd-day method.** Completed centuries: 0. Years 2001–2024: 24 years with 6 leap years (2004–2024), so $18 + 12 = 30$, and $30 \div 7$ leaves 2. Days in 2025 to 17 April: $90 + 17 = 107$, and $107 = 15 \times 7 + 2$, so 2. Total $2 + 2 = 4 arrow.r$ Thursday. #sym.checkmark

**➜ Answer: Thursday, 17 April 2025**

**Example 25** `SCB · pattern`

Which is the first year after 2025 whose calendar is exactly the same as that of 2025?

**Solution**

**Two conditions must hold:** the new year must start on the same weekday, and it must be the same type (ordinary or leap). 2025 is ordinary, so we need an ordinary year starting on the same weekday.

Add odd days year by year and stop when the running total is a multiple of 7.

#table(columns: 4,
[Year passed], [Type], [Odd days], [Running total mod 7],
[2025], [ordinary], [1], [1],
[2026], [ordinary], [1], [2],
[2027], [ordinary], [1], [3],
[2028], [leap], [2], [5],
[2029], [ordinary], [1], [6],
[2030], [ordinary], [1], [0],
)

After 2030 has passed, the total is 0. So 1 January 2031 falls on the same weekday as 1 January 2025.

Is 2031 ordinary? $2031 \div 4 = 507.75$, so yes.

Both conditions hold.

**➜ Answer: 2031**

---
⚠️ **TRAP**

**Same starting weekday is not enough.** A leap year and an ordinary year that start on the same day still differ from 1 March onwards. Always check the leap status too.

**Example 26** `GIC · pattern`

Priya is 8 years older than Wei Ming. Five years ago Priya was 3 times as old as Wei Ming. What will the sum of their ages be 4 years from now?

**Solution**

Let Wei Ming be $w$ years now. Then Priya is $w + 8$.

Five years ago: Wei Ming $= w - 5$, Priya $= w + 8 - 5 = w + 3$.

The condition: $ w + 3 = 3(w - 5) $
$ w + 3 = 3w - 15 $
$ 3 + 15 = 3w - w $
$ 18 = 2w arrow.r.double w = 9. $

So Wei Ming is 9 and Priya is $9 + 8 = 17$.

**Check:** five years ago they were 4 and 12, and $12 = 3 \times 4$. #sym.checkmark

In 4 years: $ (9 + 4) + (17 + 4) = 13 + 21 = 34. $

**➜ Answer: 34 years**

**Example 27** `LINE MAN · pattern`

Three years ago the average age of a family of 5 was 29 years. A baby has been born since then, and the average age of the 6 members today is 27 years. How old is the baby?

**Solution**

**Three years ago.** Total age of the 5 members $= 5 \times 29 = 145$ years.

**Today, those same 5 members.** Each one is 3 years older, so the total rises by $5 \times 3 = 15$: $ 145 + 15 = 160 "years". $

**Today, all 6 members.** Total $= 6 \times 27 = 162$ years.

**The baby.** $ 162 - 160 = 2 "years". $

**Sanity check.** The baby was born in the last 3 years, so its age must lie between 0 and 3. $2$ passes. #sym.checkmark

**➜ Answer: 2 years**

The trap is to subtract $162 - 145 = 17$ and call the baby 17 years old. That forgets that the five original members also aged 3 years each — and it fails the sanity check, because a baby born in the last 3 years cannot be 17.

**Example 28** `Razer · pattern`

A shopkeeper wants a set of weights so that, using a two-pan balance, he can weigh every whole number of kilograms from 1 to 40. Weights may be placed on **either** pan. What is the smallest number of weights, and what are they?

**Solution**

**Insight: putting a weight on the other pan lets it count as $-1$ as well as $+1$, so each weight has three states: left pan, right pan, or unused. Three states point to powers of 3.**

Take the weights $1, 3, 9, 27$ kg.

With signs $+1$, $0$, $-1$ on each, the reachable totals run from $-(1+3+9+27) = -40$ to $+40$, and every whole number in between can be written exactly once.

Some checks:

- $2 = 3 - 1$ (put 3 with the goods' pan opposite, and 1 beside the goods)
- $5 = 9 - 3 - 1$
- $11 = 9 + 3 - 1$
- $20 = 27 - 9 + 3 - 1$
- $40 = 27 + 9 + 3 + 1$

Could 3 weights do it? Three weights give at most $(3^3 - 1)/2 = 26/2 = 13$ different positive totals, which is less than 40. So 3 is impossible.

**➜ Answer: 4 weights: 1 kg, 3 kg, 9 kg, 27 kg**

**Example 29** `Grab · pattern`

Four engineers must cross a narrow footbridge at night. They have one torch. At most two may cross at a time, and anyone crossing must carry the torch. They walk at 1, 2, 5 and 10 minutes for the crossing; a pair moves at the slower person's pace. What is the least total time?

**Solution**

**Insight: the two slow people should cross together, so that the big number is paid only once. Someone fast must be waiting on the far side to bring the torch back.**

The plan:

#table(columns: 3,
[Move], [Who crosses], [Time],
[1], [1 and 2 go over], [2],
[2], [1 comes back], [1],
[3], [5 and 10 go over], [10],
[4], [2 comes back], [2],
[5], [1 and 2 go over], [2],
)

Total $= 2 + 1 + 10 + 2 + 2 = 17$ minutes.

**Compare with the obvious plan** (the fastest person escorts everyone):

1 and 10 go over (10), 1 comes back (1), 1 and 5 go over (5), 1 comes back (1), 1 and 2 go over (2). Total $= 10 + 1 + 5 + 1 + 2 = 19$ minutes.

17 is better.

**The box formula agrees.** It prices only the two slowest, $a = 5$ and $b = 10$, with helpers $f_1 = 1$ and $f_2 = 2$: $ min(f_1 + 2 f_2 + b,   2 f_1 + a + b) = min(1 + 4 + 10,   2 + 5 + 10) = min(15, 17) = 15. $

That 15 covers moves 1, 2, 3 and 4 and leaves 1 and 2 back at the start. They still have to cross, which costs 2. Total $15 + 2 = 17$. #sym.checkmark

**➜ Answer: 17 minutes**

**Example 30** `Sea · pattern`

You have a 5-litre jug and a 3-litre jug, no markings, and a tap. Measure out exactly 4 litres.

**Solution**

**First check it is possible.** $gcd(5, 3) = 1$, and $4 \\le 5$. So yes.

#table(columns: 3,
[Step], [Action], [5-L jug / 3-L jug],
[start], [both empty], [0 / 0],
[1], [fill the 5-L jug], [5 / 0],
[2], [pour into the 3-L jug until it is full], [2 / 3],
[3], [empty the 3-L jug], [2 / 0],
[4], [pour the 2 L across], [0 / 2],
[5], [fill the 5-L jug], [5 / 2],
[6], [top up the 3-L jug (it takes 1 L)], [4 / 3],
)

The 5-litre jug now holds exactly 4 litres.

**➜ Answer: 4 litres in the 5-L jug after 6 moves**

---
💡 **SHORTCUT**

**Jug puzzles have only two strategies.** Either keep filling the big jug and emptying into the small one, or keep filling the small jug and pouring into the big one. Try the first; if it stalls, try the second. One of them always reaches every achievable amount.

#### Practice — Tier 2 — Singapore & Thailand *(target: 100 s/Q)*

+ Find the angle between the hands at 7:35.
+ At what times between 5 and 6 o'clock are the hands $60°$ apart?
+ A clock loses 12 minutes every hour and is set right at 8:00 a.m. What is the true time when it shows 4:00 p.m.?
+ A clock gains 5 minutes a day. After how many days will it show the correct time again?
+ Two clocks are set right at 6:00 a.m. One gains 2 minutes per hour, the other loses 3 minutes per hour. When will they be 50 minutes apart?
+ What day of the week is 15 June 2030?
+ Which is the first year after 2024 with exactly the same calendar as 2024?
+ 15 March 2024 was a Friday. What day was 20 August 2024?
+ The ages of a mother and her son are in the ratio $7 : 2$. In 10 years the ratio will be $9 : 4$. Find their present ages.
+ What is the smallest set of weights that can weigh every whole number of kilograms from 1 to 121 on a two-pan balance, weights allowed on both pans?
+ Four people must cross a bridge at night with one torch, two at a time, moving at the slower pace. Their times are 1, 3, 6 and 8 minutes. What is the least total time?
+ Using a 7-litre jug and a 4-litre jug, measure exactly 5 litres. List the moves.

<details>
<summary><b>Answer key</b></summary>

+ **$17.5°$.** $|30 \times 7 - 5.5 \times 35| = |210 - 192.5| = 17.5$.
+ **5:16 and $4/11$ min, and 5:38 and $2/11$ min.** $M = 2/11(150 - 60) = 180/11 = 16 4/11$ and $M = 2/11(150 + 60) = 420/11 = 38 2/11$.
+ **6:00 p.m.** The clock shows 8 h $= 480$ clock-min, at 48 clock-min per 60 true min. True $= 480 \times 60/48 = 600$ min $= 10$ h, so $8:00 + 10 = 18:00$.
+ **144 days.** $720 \div 5 = 144$.
+ **4:00 p.m. the same day.** The gap grows at $2 + 3 = 5$ min per hour, so $50 \div 5 = 10$ hours after 6 a.m.
+ **Saturday.** Centuries 0. Years 2001–2029: 29 years, 7 leap (2004–2028), so $22 + 14 = 36$, and $36 \div 7$ leaves 1. Days in 2030 to 15 June: $151 + 15 = 166$, and $166 = 23 \times 7 + 5$, so 5. Total $1 + 5 = 6 arrow.r$ Saturday.
+ **2052.** A leap year's calendar repeats after 28 years, and no non-leap century year lies between 2024 and 2052.
+ **Tuesday.** 2024 is a leap year. Day-of-year: 15 March $= 60 + 15 = 75$; 20 August $= 213 + 20 = 233$. Gap $= 233 - 75 = 158$ days, and $158 = 22 \times 7 + 4$, so Friday $+ 4 =$ Tuesday.
+ **Mother 35, son 10.** $(7x + 10)/(2x + 10) = 9/4$ gives $28x + 40 = 18x + 90$, so $10x = 50$ and $x = 5$. Check: $45/20 = 9/4$. #sym.checkmark
+ **Five weights: 1, 3, 9, 27, 81 kg.** They reach $(3^5 - 1)/2 = 242/2 = 121$. Four weights reach only 40.
+ **18 minutes.** 1 and 3 over (3), 1 back (1), 6 and 8 over (8), 3 back (3), 1 and 3 over (3): $3+1+8+3+3 = 18$. The escort plan costs $8+1+6+1+3 = 19$.
+ **5 L in the 7-L jug.** Fill 4 and pour into 7 (7 has 4). Fill 4 again and top up the 7-L jug, which takes 3, leaving 1 in the 4-L jug. Empty the 7-L jug, pour the 1 L in, then fill the 4-L jug and empty it into the 7-L jug: $1 + 4 = 5$.

## Tier 3 — Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 31** `Google · pattern`

How many times in 24 hours are the hour and minute hands exactly at right angles? Explain, do not just quote the number.

**Solution**

**Insight: stop thinking about two hands. Think about one imaginary hand whose position is the gap between them. That gap hand turns at a steady $5.5°$ per minute.**

In 12 hours $= 720$ minutes, the gap grows by $ 5.5 \times 720 = 3960 "degrees". $

$3960 \div 360 = 11$. So in 12 hours the gap makes exactly **11 complete turns**.

During one complete turn of the gap, the gap passes through $90°$ once and through $270°$ once — and $270°$ also looks like a right angle, measured the short way.

So each turn gives 2 right angles, and $11 \times 2 = 22$ right angles in 12 hours.

In 24 hours: $22 \times 2 = 44$.

**Why the same logic gives 22 for "hands together".** The gap equals $0°$ only once per turn, so it happens 11 times in 12 hours and 22 times a day. Same for $180°$.

**➜ Answer: 44 times**

This one argument answers the whole family of questions. Any angle strictly between $0°$ and $180°$ occurs $2 \times 11 \times 2 = 44$ times a day; the two end values $0°$ and $180°$ occur 22 times a day each.

**Example 32** `Amazon · pattern`

A clock has an hour hand, a minute hand and a second hand. How many times in 24 hours do all three point in exactly the same direction?

**Solution**

**Insight: each pair of hands has its own regular meeting timetable. Write down the hour-and-minute timetable, write down the minute-and-second timetable, and ask whether any moment appears on both lists.**

**Step 1 — when do the hour and minute hands meet?** From Example 31, 11 times in 12 hours, evenly spaced, so at $ t = k \times 720/11 "minutes after 12:00", \quad k = 0, 1, 2, \dots, 10. $

**Step 2 — when do the minute and second hands meet?** In $t$ minutes the second hand makes $t$ full turns and the minute hand makes $t slash 60$ full turns. They point the same way exactly when the second hand has gained a **whole number** of turns: $ t - t/60 = j \quad arrow.r.double \quad 59/60 t = j \quad arrow.r.double \quad t = (60 j)/59, \quad j = 0, 1, 2, \dots $

**Step 3 — can both conditions hold at once?** Set the two lists equal: $ (60 j)/59 = (720 k)/11. $

Multiply both sides by $11 \times 59 = 649$: $ 660 j = 42480 k. $

Divide both sides by 60: $ 11 j = 708 k. $

$11$ is prime. Does $11$ divide $708$? $11 \times 64 = 704$, and $708 - 704 = 4$, so no. Therefore $11$ must divide $k$.

In 12 hours $k$ runs only over $0, 1, \dots, 10$, so the only multiple of 11 available is $k = 0$.

$k = 0$ is 12 o'clock itself. At 12:00 all three hands point at the 12.

So in 12 hours it happens once, and in 24 hours: at 12 midnight and at 12 noon.

**➜ Answer: 2 times a day**

---
⚠️ **TRAP**

**"The hands meet 22 times a day, so all three must meet 22 times" is wrong.** The second hand is a much faster wheel; it only lines up with the other two at the one moment when every hand resets together. Check the arithmetic of the meeting times before you assume.

**Example 33** `Goldman Sachs · pattern`

A year is picked at random. What is the probability that it contains 53 Sundays?

**Solution**

**Insight: 52 Sundays are guaranteed. The question is only about the 1 or 2 leftover days.**

**Case A — an ordinary year.** $365 = 52 \times 7 + 1$. There are 52 of each weekday, plus 1 extra day. That extra day is equally likely to be any of the 7 weekdays, so $ P(53 "Sundays" \mid "ordinary") = 1/7. $

**Case B — a leap year.** $366 = 52 \times 7 + 2$. The 2 extra days are a consecutive pair: (Sun, Mon), (Mon, Tue), (Tue, Wed), (Wed, Thu), (Thu, Fri), (Fri, Sat) or (Sat, Sun) — 7 equally likely pairs. Two of them contain a Sunday, so $ P(53 "Sundays" \mid "leap") = 2/7. $

**How likely is a leap year?** Over one full 400-year cycle there are 97 leap years. $ P("leap") = 97/400, \quad P("ordinary") = 303/400. $

**Combine.** $ P = 303/400 \times 1/7 + 97/400 \times 2/7 = (303 + 194)/(400 \times 7) = 497/2800. $

Divide top and bottom by 7: $497 \div 7 = 71$ and $2800 \div 7 = 400$. $ P = 71/400 = 0.1775. $

**➜ Answer: $71/400 = 0.1775$**

**Example 34** `Microsoft · pattern`

A 12-hour digital clock displays the time as H:MM or HH:MM, with no leading zero on the hour (so 1:05, 10:30, 12:45). Ignoring the colon, how many times in 24 hours is the display a palindrome?

**Solution**

**Insight: split by the number of digits in the hour, because a 3-character string and a 4-character string have different palindrome conditions.**

**Case A — single-digit hours 1 to 9.** The string is $h m_1 m_2$ (3 characters). A palindrome needs the first and last to match: $ m_2 = h. $ The middle digit $m_1$ is free, but it is the tens digit of the minutes, so $m_1 in {0, 1, 2, 3, 4, 5}$ — 6 choices.

For each hour $h$ there are 6 palindromes. Example for $h = 1$: 1:01, 1:11, 1:21, 1:31, 1:41, 1:51.

Total $= 9 \times 6 = 54$.

**Case B — two-digit hours 10, 11, 12.** The string is $h_1 h_2 m_1 m_2$ (4 characters). A palindrome needs $ m_2 = h_1 \quad "and" \quad m_1 = h_2. $

Here $h_1 = 1$ always, so $m_2 = 1$.

- Hour 10: $h_2 = 0$, so $m_1 = 0$ and the time is 10:01. Minutes 01 is valid. #sym.checkmark
- Hour 11: $h_2 = 1$, so $m_1 = 1$ and the time is 11:11. Valid. #sym.checkmark
- Hour 12: $h_2 = 2$, so $m_1 = 2$ and the time is 12:21. Valid. #sym.checkmark

Total $= 3$.

**In 12 hours:** $54 + 3 = 57$.

**In 24 hours:** $57 \times 2 = 114$.

**➜ Answer: 114 times**

**Example 35** `D. E. Shaw · pattern`

You have 12 coins. Exactly one is counterfeit, and it may be heavier **or** lighter than the rest; you do not know which. With a two-pan balance and only 3 weighings, find the fake coin and say whether it is heavy or light.

**Solution**

**Insight: count the outcomes before you design anything. Each weighing has 3 results, so 3 weighings give $3^3 = 27$ outcome-patterns. There are $12 \times 2 = 24$ possible answers. $24 \\le 27$, so it is just possible — which means no weighing may be wasted; every weighing must split the possibilities into three nearly equal parts.**

Label the coins $1 \dots 12$.

**Weighing 1:** $1, 2, 3, 4$ against $5, 6, 7, 8$.

**Branch A — they balance.** The fake is among $9, 10, 11, 12$ (8 possibilities: 4 coins $\times$ 2 directions).

Weighing 2: $9, 10, 11$ against $1, 2, 3$ (three coins known to be good).

- Balance #sym.arrow the fake is 12. Weighing 3: 12 against a good coin tells you heavy or light.
- Left heavy #sym.arrow one of $9, 10, 11$ is heavy. Weighing 3: 9 against 10. Heavier side is the fake; if they balance it is 11.
- Left light #sym.arrow one of $9, 10, 11$ is light. Weighing 3: 9 against 10. Lighter side is the fake; if they balance it is 11.

**Branch B — left side heavy.** Then either one of $1, 2, 3, 4$ is heavy, or one of $5, 6, 7, 8$ is light (8 possibilities).

Weighing 2: $1, 2, 5$ against $3, 4, 6$.

- **Balance** #sym.arrow none of $1, 2, 3, 4, 5, 6$ is the fake, so it is 7 or 8, and it must be **light**. Weighing 3: 7 against 8; the lighter one is the fake.
- **Left heavy** #sym.arrow the cause is 1 heavy, 2 heavy, or 6 light. Weighing 3: 1 against 2. Heavier is the fake; if they balance, 6 is light.
- **Left light** #sym.arrow the cause is 3 heavy, 4 heavy, or 5 light. Weighing 3: 3 against 4. Heavier is the fake; if they balance, 5 is light.

**Branch C — right side heavy.** Mirror image of Branch B with the roles of the two groups swapped.

Every branch ends after weighing 3 with one coin named and its direction known.

**➜ Answer: Yes — 3 weighings are enough, using the $4$ vs $4$ opening and the mixed regrouping above**

Where the limit sits. With 13 coins, $13 \times 2 = 26$ answers still fit inside 27 outcomes, and 3 weighings can indeed **name** the fake — but in one branch they cannot also say whether it is heavy or light. Twelve is the largest number for which 3 weighings give you both facts every time.

**Example 36** `Uber · pattern`

You have two ropes. Each one burns from end to end in exactly 60 minutes, but neither burns at a steady rate — half the rope may take 50 minutes and the other half 10. You have a lighter. Measure exactly 45 minutes.

**Solution**

**Insight: you cannot trust any point along a rope, but you can trust a whole rope. Lighting both ends halves the time, whatever the unevenness.**

**Step 1.** At time 0, light rope A at **both** ends and rope B at **one** end.

Rope A now has two flames eating towards each other. Together they consume the whole 60-minutes-worth of rope at double speed, so they meet after exactly $60 \div 2 = 30$ minutes — no matter where they meet.

**Step 2.** The moment rope A is finished, 30 minutes have passed. Rope B has been burning from one end for those 30 minutes, so what is left of rope B is worth exactly $60 - 30 = 30$ minutes of one-ended burning.

**Step 3.** At that instant, light the **other** end of rope B as well.

The remaining 30-minutes-worth now burns from both ends, so it is gone in $30 \div 2 = 15$ minutes.

**Total.** $30 + 15 = 45$ minutes.

**➜ Answer: 45 minutes: both ends of A and one end of B at the start; at 30 minutes light B's second end**

The same two ropes also give 30 minutes (both ends of one rope), 60 minutes (one end of one rope) and 15 minutes (the stretch from the 30-minute mark to the 45-minute mark). The one move that does all the work is **lighting the second end**: it halves whatever burning time is left.

**Example 37** `Adobe · pattern`

Twelve matchsticks are laid out to make a $2 \times 2$ grid of four unit squares. (a) Show that 12 sticks is right. (b) Remove exactly 2 sticks so that exactly 2 squares remain. (c) How many sticks would a $5 \times 5$ grid need?

**Solution**

**(a)** A $2 \times 2$ grid has 3 horizontal lines, each 2 units long, and 3 vertical lines, each 2 units long. $ 3 \times 2 + 3 \times 2 = 6 + 6 = 12. #sym.checkmark $

The general rule: an $n \times n$ grid has $(n+1)$ lines each way, each $n$ sticks long, so $2n(n+1)$ sticks. For $n = 2$: $2 \times 2 \times 3 = 12$. #sym.checkmark

**(b)** **Insight: the figure holds 5 squares, not 4 — the big outer square counts too. Removing an outer stick destroys the big square straight away, which is wasteful. Removing an interior stick kills two small squares at once and leaves the big square alone.**

There are 4 interior sticks: the upper and lower halves of the middle vertical line, and the left and right halves of the middle horizontal line.

Remove the **upper half of the middle vertical line** — that kills the top-left and top-right unit squares.

Remove the **right half of the middle horizontal line** — that kills the top-right (already gone) and the bottom-right unit squares.

Squares destroyed: top-left, top-right, bottom-right. Squares surviving: the bottom-left unit square, and the big $2 \times 2$ square, whose 8 outer sticks are all untouched.

Exactly 2 squares remain.

**(c)** $2n(n+1)$ with $n = 5$: $ 2 \times 5 \times 6 = 60 "sticks". $

**➜ Answer: (a) $2n(n+1) = 12$; (b) remove two interior sticks, leaving 1 small square and the big square; (c) 60 sticks**

---
💡 **SHORTCUT**

**Count the big square.** In matchstick square puzzles, always list squares of every size before you start removing. A $2 \times 2$ grid has 5 squares, a $3 \times 3$ grid has 14. Most wrong answers come from counting only the unit squares.

**Example 38** `Google · pattern`

Show that the whole Gregorian calendar repeats exactly every 400 years, and use that fact to find the day of the week for 15 August 2347, given that 15 August 1947 was a Friday.

**Solution**

**Insight: the calendar repeats only if the 400-year block contains a whole number of weeks. Count the days.**

**Step 1 — leap years in 400 years.** Multiples of 4: $400 \div 4 = 100$. Remove the century years: $400 \div 100 = 4$ of them. Add back those divisible by 400: $400 \div 400 = 1$. $ 100 - 4 + 1 = 97 "leap years". $

**Step 2 — total days.** $ 400 \times 365 + 97 = 146000 + 97 = 146097. $

**Step 3 — is that a whole number of weeks?** $ 146097 \div 7 = 20871 "exactly" \quad ("since" 7 \times 20871 = 146097). $

Remainder 0. So a 400-year block contains 0 odd days.

**Step 4 — the consequence.** Every date shifts by 0 weekdays after 400 years, and the leap pattern also repeats (2000 and 2400 are both leap years, 2100 / 2200 / 2300 and 2500 / 2600 / 2700 are all non-leap). So the calendar is identical.

**Step 5 — apply it.** $2347 - 1947 = 400$.

So 15 August 2347 falls on the same weekday as 15 August 1947.

**➜ Answer: Friday**

Quick verification of the 1947 date by the odd-day method: centuries $1600 arrow.r 0$, $300 arrow.r 1$. Years 1901–1946: 46 years, 11 leap (1904 to 1944), so $35 + 22 = 57$, and $57 \div 7$ leaves 1. Days in 1947 to 15 August: $212 + 15 = 227$, and $227 \div 7$ leaves 3. Total $0 + 1 + 1 + 3 = 5 arrow.r$ Friday. #sym.checkmark

#### Practice — Tier 3 — Product *(target: 4 min/Q)*

+ How many times in 24 hours are the hour and minute hands exactly opposite each other? Justify the count.
+ At what times between 3 and 4 o'clock is the angle between the hands exactly $50°$?
+ The minute hand of a clock is 7 cm long. How far does its tip travel in 45 minutes? (Take $pi = 22/7$.)
+ A leap year is picked at random. What is the probability that it has 53 Fridays?
+ How many times in 12 hours is the angle between the hands exactly $0°$?
+ Five people must cross a bridge at night with one torch, two at a time, moving at the slower pace. Their times are 1, 2, 4, 8 and 16 minutes. What is the least total time?
+ How many matchsticks are needed for a $4 \times 4$ grid of unit squares, and how many squares of all sizes does it contain?
+ A 12-hour digital clock shows H:MM or HH:MM with no leading zero. How many times in 24 hours does the display use only one distinct digit (for example 1:11)?

<details>
<summary><b>Answer key</b></summary>

+ **22.** The gap between the hands turns at $5.5°$ per minute, so in 12 hours it makes $5.5 \times 720 \div 360 = 11$ complete turns. The gap equals $180°$ exactly once per turn, giving 11 times in 12 hours and 22 in a day. (It is 22, not 24, because the gap makes 11 turns, not 12.)
+ **3:07 and $3/11$ min, and 3:25 and $5/11$ min.** $M = 2/11(90 - 50) = 80/11 = 7 3/11$ and $M = 2/11(90 + 50) = 280/11 = 25 5/11$. Both lie in $0 \\le M < 60$, so both count.
+ **33 cm.** In 60 minutes the tip covers one full circle, $2 pi r = 2 \times 22/7 \times 7 = 44$ cm. In 45 minutes it covers $3/4$ of that: $44 \times 3/4 = 33$ cm.
+ **$2/7$.** A leap year is $52$ weeks plus 2 extra days, which form one of 7 equally likely consecutive pairs. Two of those pairs — (Thu, Fri) and (Fri, Sat) — contain a Friday.
+ **11.** The gap makes 11 complete turns in 12 hours and is $0°$ once per turn. The 12:00 overlap is counted once, at the start.
+ **28 minutes.** Handle the two slowest, 8 and 16, with helpers $f_1 = 1$, $f_2 = 2$: $min(1 + 4 + 16,   2 + 8 + 16) = min(21, 26) = 21$. That leaves 1, 2, 4 at the start; three people cost $4 + 1 + 2 = 7$ (1 and 4 over, 1 back, 1 and 2 over). Total $21 + 7 = 28$.
+ **40 sticks and 30 squares.** Sticks $= 2n(n+1) = 2 \times 4 \times 5 = 40$. Squares $= 16 + 9 + 4 + 1 = 30$.
+ **12.** Single-digit hours need $h = m_1 = m_2$ with $m_1 \\le 5$, giving 1:11, 2:22, 3:33, 4:44, 5:55 — that is 5. Two-digit hours need all four digits equal: only 11:11 works (10 and 12 have two different digits). So $5 + 1 = 6$ in 12 hours, and $6 \times 2 = 12$ in a day.

## Mixed set — exam conditions

#### Practice — Tier 1 — Service *(target: 30 min for all 18)*

+ Find the angle between the hands at 9:30.
+ At what time between 6 and 7 o'clock are the hands together?
+ A clock gains 15 minutes a day. After how many days will it show the correct time again?
+ What day of the week was 15 August 1947?
+ How many odd days are there in 100 years?
+ A watch gains 5 minutes every hour and is set right at 8:00 a.m. What is the true time when it shows 9:00 p.m.?
+ A father is 30 years older than his son. In 6 years the father will be 3 times as old as the son. Find their present ages.
+ How many times in 24 hours are the two hands in a straight line?
+ What day of the week was 1 January 2000?
+ What is the smallest set of weights that weighs every whole number of kilograms from 1 to 13 on a two-pan balance, weights allowed on both pans?
+ A farmer must ferry a wolf, a goat and a cabbage across a river. The boat holds the farmer plus one item. The wolf must not be left alone with the goat, nor the goat with the cabbage. What is the least number of crossings?
+ Find the angle between the hands at 12:25.
+ A month of 30 days begins on a Sunday. How many Mondays does it have?
+ Which is the first year after 2023 with exactly the same calendar as 2023?
+ Twenty-seven coins look alike; one is lighter. What is the least number of pan-balance weighings that always finds it?
+ If today is Tuesday, what day will it be 61 days from now?
+ You have two ropes, each burning end to end in exactly 1 hour but at an uneven rate. How do you measure 45 minutes?
+ At what time between 2 and 3 o'clock are the hands at right angles?

<details>
<summary><b>Answer key</b></summary>

+ **$105°$.** $|30 \times 9 - 5.5 \times 30| = |270 - 165| = 105$.
+ **6:32 and $8/11$ min.** $M = 2/11(30 \times 6) = 360/11 = 32 8/11$.
+ **48 days.** $720 \div 15 = 48$.
+ **Friday.** Centuries $1600 arrow.r 0$, $300 arrow.r 1$. Years 1901–1946: $35 + 22 = 57 arrow.r 1$. Days to 15 Aug: $212 + 15 = 227 arrow.r 3$. Total $0 + 1 + 1 + 3 = 5 arrow.r$ Friday.
+ **5.** 76 ordinary years and 24 leap years give $76 + 48 = 124$, and $124 \div 7$ leaves 5.
+ **8:00 p.m.** The watch shows 13 h $= 780$ watch-min at 65 watch-min per 60 true min, so true $= 780 \times 60/65 = 720$ min $= 12$ h. $8:00 "a.m." + 12 = 8:00$ p.m.
+ **Son 9, father 39.** $f = s + 30$ and $s + 36 = 3(s + 6)$ give $2s = 18$, so $s = 9$. Check: 15 and 45, and $45 = 3 \times 15$. #sym.checkmark
+ **44.** The gap makes 11 turns per 12 hours; a straight line means $0°$ or $180°$, which is twice per turn. $11 \times 2 \times 2 = 44$.
+ **Saturday.** Centuries $1600 arrow.r 0$, $300 arrow.r 1$. Years 1901–1999: 99 years, 24 leap, so $75 + 48 = 123 arrow.r 4$. 1 January is 1 day. Total $0 + 1 + 4 + 1 = 6 arrow.r$ Saturday.
+ **Three weights: 1, 3, 9 kg.** They reach $(3^3 - 1)/2 = 13$ exactly. Two weights reach only 4.
+ **7 crossings.** Goat over; return empty; wolf over; goat back; cabbage over; return empty; goat over.
+ **$137.5°$.** Treat 12 as $H = 0$: $|0 - 5.5 \times 25| = 137.5$.
+ **5.** $30 = 4 \times 7 + 2$, so the first two weekdays (Sunday and Monday) occur 5 times each.
+ **2034.** Add odd days year by year and stop at a multiple of 7. Running total after 2023 is 1; after 2024 (leap) $1 + 2 = 3$; 2025 $arrow.r 4$; 2026 $arrow.r 5$; 2027 $arrow.r 6$; 2028 (leap) $arrow.r 8 arrow.r 1$; 2029 $arrow.r 2$; 2030 $arrow.r 3$; 2031 $arrow.r 4$; 2032 (leap) $arrow.r 6$; 2033 $arrow.r 0$. So 1 January 2034 falls on the same weekday, and 2034 is ordinary like 2023.
+ **3.** $27 = 3^3$, so three three-way splits suffice, and $3^2 = 9 < 27$ rules out 2.
+ **Sunday.** $61 = 8 \times 7 + 5$, so Tuesday $+ 5 =$ Sunday.
+ **Light both ends of rope A and one end of rope B.** A is gone at 30 minutes; at that moment light B's other end, and B's remaining 30-minutes-worth burns out in 15. Total $30 + 15 = 45$.
+ **2:27 and $3/11$ min.** $M = 2/11(60 + 90) = 300/11 = 27 3/11$. The minus branch gives $2/11(60 - 90) < 0$, so it is rejected — this hour has only one right angle.

## 📋 One-page revision card

**Clock speeds.** Minute hand $6°$/min, hour hand $0.5°$/min, gap grows at $5.5°$/min. The gap makes 11 complete turns every 12 hours.

**Angle.** $theta = |30H - 5.5M|$; if over $180°$, use $360 - theta$.

**When is the angle $theta$?** $M = 2/11 (30H plus.minus theta)$, keeping $0 \\le M < 60$.

**Counts in 24 hours.** Together 22. Opposite 22. Straight line 44. Right angle 44. Any other fixed angle 44. All three hands together: 2.

**Gap between coincidences.** $720/11 = 65 5/11$ minutes.

**Mirror of a clock.** $11:60 - "time"$ (use $23:60$ if the hour reads 12).

**Faulty clocks.** A clock gaining $g$ min/hour shows $60 + g$ clock-minutes per 60 true minutes, so $ "true" = "shown" \times 60/(60 + g). $ A clock drifting $d$ min/day is next correct after $720 \div d$ days. Two clocks: use the **sum** of the rates if one gains and one loses, the **difference** if both gain.

**Odd days.** Ordinary year 1, leap year 2. $100 arrow.r 5$, $200 arrow.r 3$, $300 arrow.r 1$, $400 arrow.r 0$. Day code: 0 Sun, 1 Mon, 2 Tue, 3 Wed, 4 Thu, 5 Fri, 6 Sat.

**Leap rule.** Divisible by 4; a century year must be divisible by 400.

**Month running totals (ordinary year).** Jan 31, Feb 59, Mar 90, Apr 120, May 151, Jun 181, Jul 212, Aug 243, Sep 273, Oct 304, Nov 334, Dec 365. Add 1 from February onwards in a leap year.

**Day-of-week recipe.** century odd days $+$ year odd days ($1 \times$ ordinary $+ 2 \times$ leap) $+$ day-of-year, all mod 7.

**Calendar repeats.** Ordinary year: after 6 or 11 years (12 across a non-leap century year). Leap year: after 28 years. Everything: after 400 years ($146097$ days $= 20871$ weeks exactly). 31-day month: 5 of the first three weekdays. 30-day month: 5 of the first two.

**Probability of 53 of a given weekday.** Ordinary $1/7$, leap $2/7$, a random year $71/400$.

**Ages.** Let $x$ be the present age of the younger person. Shift **both** ages by the same amount. The difference of two ages is constant — use it to check.

**Weighing.** One pan only: $1, 2, 4, 8, \dots$ reaches $2^n - 1$. Both pans: $1, 3, 9, 27, 81$ reaches $(3^n - 1)/2$, so 4 weights reach 40 and 5 reach 121. Finding one odd item of known direction among $N$ takes $ceil(log_3 N)$ weighings; unknown direction among 12 takes 3.

**Crossings and measuring.** Wolf–goat–cabbage: 7 crossings. Torch bridge: send the two slowest together, cost $min(f_1 + 2 f_2 + b,   2 f_1 + a + b)$, then repeat. Two jugs $p$ and $q$ reach $v$ if $gcd(p,q)$ divides $v$ and $v \\le max(p,q)$. Two uneven 60-minute ropes: both ends of one plus one end of the other gives 45 minutes.

**Matchsticks.** A row of $n$ squares: $3n + 1$ sticks. An $n \times n$ grid: $2n(n+1)$ sticks, and $1^2 + \dots.c + n^2$ squares.

**The top 5 traps**

+ **Use $5.5M$, never $6M$.** The hour hand keeps moving while the minutes pass.
+ **Angle above $180°$?** Subtract from 360 before matching an option.
+ **"Gains 10 minutes" is a rate, not a one-off shift.** Scale with the ratio $60 : (60+g)$ whenever you are going from clock time back to true time.
+ **Same start weekday is not the same calendar.** The leap status must match too.
+ **In an average-age problem, everybody ages.** Add $n \times ("number of people")$ before comparing totals.

</details>

</details>

</details>

</details>
