# Chapter 4 — Averages, Mixtures & Alligation

*One number for a group. Then blend two groups.*

## What you need to know

**FORMULA SHEET**

**Average.**
$ "Average" = "Sum of all values"/"Number of values" , \quad "Sum" = "Average" \times "Number" $
Turning an average back into a sum is the single most useful move in this chapter.

**Standard averages.**
- First $n$ natural numbers: $(n+1)/2$.
- First $n$ odd numbers: $n$. First $n$ even numbers: $n + 1$.
- Any set of numbers in arithmetic progression (evenly spaced): average $= ("first" + "last")/2$. When the count is **odd** this is also the middle term.

**Changing one member.** If one value $a$ is replaced by $b$ in a set of $n$ values:
$ "change in average" = (b - a)/n $

**Adding a member.** $n$ values average $A$. A new value $x$ joins:
$ "new average" = (n A + x)/(n+1) $
If the average goes **up** by $d$ when the $(n+1)$-th member joins, then $x = A + (n+1) d$.

**Weighted average.** Groups of size $n_1, n_2$ with averages $A_1, A_2$:
$ A = (n_1 A_1 + n_2 A_2)/(n_1 + n_2) $

**Alligation.** The same formula, read backwards, to get the **ratio of quantities**. Let $C$ be the cheaper value, $D$ the dearer value, $M$ the mean value ($C < M < D$):
$ "quantity of cheaper"/"quantity of dearer" = (D - M)/(M - C) $
Cross form:
#table(columns: 3, align: center,
 [$C$], [], [$D$],
 [], [$M$], [],
 [$D - M$], [], [$M - C$],
)
It works for any quantity that averages: price, percent, speed, age, interest rate, score.

**Repeated replacement.** A vessel holds $x$ units of pure liquid. Remove $y$ units and top up with water. Repeat $n$ times:
$ "pure liquid left" = x (1 - y/x)^n $
The **fraction** of pure liquid after $n$ steps is $(1 - y/x)^n$. Water left $= x - "pure left"$.

**Average speed.** Never average the speeds.
$ "Average speed" = "total distance"/"total time" $
Equal distances at $u$ and $v$: $ (2 u v)/(u + v) $
Equal distances at $u$, $v$, $w$: $ 3/(1/u + 1/v + 1/w) $

**Mean, median, mode.**
- Mean $=$ sum $\div$ count. Pulled hard by one extreme value.
- Median $=$ middle value after sorting. For an even count, the average of the two middle values. Not pulled by extremes.
- Mode $=$ the most frequent value.

## Warm-up

### Warm-up

**Example 1**

Find the average of 14, 22, 31, 45 and 63.

**Solution**

Sum $= 14 + 22 = 36$; $36 + 31 = 67$; $67 + 45 = 112$; $112 + 63 = 175$. \
Average $= 175 \div 5 = 35$.

**➜ Answer: 35**

**Example 2**

Find the average of the first 20 natural numbers.

**Solution**

Average $= (n+1)/2 = 21/2 = 10.5$.

**➜ Answer: 10.5**

**Example 3**

The average of 6 numbers is 42. Find their sum.

**Solution**

Sum $= "average" \times "count" = 42 \times 6 = 252$.

**➜ Answer: 252**

**Example 4**

The average of 8 numbers is 25. The number 18 is replaced by 42. Find the new average.

**Solution**

Change in sum $= 42 - 18 = 24$. \
Change in average $= 24 \div 8 = 3$. \
New average $= 25 + 3 = 28$.

**➜ Answer: 28**

**Example 5**

The average of 5 numbers is 30. A sixth number, 48, is added. Find the new average.

**Solution**

Old sum $= 30 \times 5 = 150$. \
New sum $= 150 + 48 = 198$. \
New average $= 198 \div 6 = 33$.

**➜ Answer: 33**

**Example 6**

4 kg of rice at Rs.~60/kg is mixed with 6 kg at Rs.~85/kg. Find the price per kg of the mixture.

**Solution**

Cost $= 4 \times 60 = 240$ and $6 \times 85 = 510$. \
Total cost $= 240 + 510 = 750$ for $4 + 6 = 10$ kg. \
Price $= 750 \div 10 = 75$.

**➜ Answer: Rs.~75 per kg**

**Example 7**

In what ratio must goods costing Rs.~40 and Rs.~70 be mixed to cost Rs.~50 on average?

**Solution**

$C = 40$, $D = 70$, $M = 50$. \
$"cheaper"/"dearer" = (D - M)/(M - C) = (70 - 50)/(50 - 40) = 20/10 = 2/1$.

**➜ Answer: $2 : 1$**

**Example 8**

Find the mean and the median of 7, 3, 11, 9, 5, 15.

**Solution**

Mean: sum $= 7 + 3 + 11 + 9 + 5 + 15 = 50$; mean $= 50 \div 6 = 8.33$ (2 d.p.). \
Median: sort them $arrow.r$ 3, 5, 7, 9, 11, 15. Count is even, so take the two middle values 7 and 9. \
Median $= (7 + 9)/2 = 8$.

**➜ Answer: Mean $\approx 8.33$, median $= 8$**

## Tier 1 — Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

The average of 11 numbers is 36. The average of the first six is 34 and the average of the last six is 39. Find the sixth number.

**Solution**

Total sum of all 11 $= 36 \times 11 = 396$. \
Sum of first six $= 34 \times 6 = 204$. \
Sum of last six $= 39 \times 6 = 234$. \
Add those two: $204 + 234 = 438$. \
The first six and the last six together cover 12 slots, but there are only 11 numbers. The sixth number sits in both groups, so it has been counted twice. \
Sixth number $= 438 - 396 = 42$.

**➜ Answer: 42**

---
💡 **SHORTCUT**

**Overlap rule.** First $k$ $+$ last $k$ $-$ total $=$ the number counted twice, whenever the two groups together cover one more slot than the list has.

**Example 10** `Infosys pattern`

The average age of 30 students is 14 years. When the teacher's age is included, the average rises by 1 year. Find the teacher's age.

**Solution**

Old sum $= 14 \times 30 = 420$. \
New count $= 31$. New average $= 14 + 1 = 15$. \
New sum $= 15 \times 31 = 465$. \
Teacher's age $= 465 - 420 = 45$ years. \
Faster: the newcomer must carry the old average **plus** enough to lift all 31 heads by 1, so age $= 14 + 31 \times 1 = 45$.

**➜ Answer: 45 years**

**Example 11** `Wipro pattern`

The average weight of 4 boxes is 62 kg. A fifth box is added and the average falls to 59 kg. Find the weight of the fifth box.

**Solution**

Sum of 4 boxes $= 62 \times 4 = 248$. \
Sum of 5 boxes $= 59 \times 5 = 295$. \
Fifth box $= 295 - 248 = 47$ kg.

**➜ Answer: 47 kg**

**Example 12** `Accenture pattern`

The average marks of a class of 40 students is 62. Later it is found that one student's mark of 78 was entered as 38. Find the correct average.

**Solution**

The sum was too small by $78 - 38 = 40$. \
Change in average $= 40 \div 40 = 1$. \
Correct average $= 62 + 1 = 63$.

**➜ Answer: 63**

---
⚠️ **TRAP**

**Decide the direction before you add.** The entered mark was **lower** than the true mark, so the recorded average is **too low** and must go up. Students who subtract get 61 and it looks just as reasonable.

**Example 13** `TCS NQT pattern`

A man drives 120 km at 40 km/h and returns over the same road at 60 km/h. Find his average speed for the whole journey.

**Solution**

Time out $= 120/40 = 3$ hours. \
Time back $= 120/60 = 2$ hours. \
Total distance $= 120 + 120 = 240$ km. Total time $= 3 + 2 = 5$ hours. \
Average speed $= 240/5 = 48$ km/h. \
Formula check: $(2 u v)/(u + v) = (2 \times 40 \times 60)/(40 + 60) = 4800/100 = 48$.

**➜ Answer: 48 km/h**

---
⚠️ **TRAP**

**Average speed is not $(40 + 60)/2 = 50$.** The slower leg eats more time, so it gets more weight. The true answer is always below the plain average of the two speeds.

**Example 14** `Capgemini pattern`

The average of five consecutive even numbers is 36. Find the largest.

**Solution**

Consecutive even numbers are evenly spaced, so the average is the middle one. \
Middle number $= 36$. \
The five numbers are $32, 34, 36, 38, 40$. \
Check: $32 + 34 + 36 + 38 + 40 = 180$, and $180 \div 5 = 36$. Correct. \
Largest $= 40$.

**➜ Answer: 40**

**Example 15** `Cognizant pattern`

In what ratio must rice at Rs.~48/kg be mixed with rice at Rs.~72/kg so that the mixture is worth Rs.~56/kg?

**Solution**

$C = 48$, $D = 72$, $M = 56$. \
$"cheap"/"dear" = (D - M)/(M - C) = (72 - 56)/(56 - 48) = 16/8 = 2/1$. \
Check with 2 kg and 1 kg: cost $= 2 \times 48 + 1 \times 72 = 96 + 72 = 168$ for 3 kg, so $168 \div 3 = 56$. Correct.

**➜ Answer: $2 : 1$**

**Example 16** `TCS NQT pattern`

A shopkeeper mixes 30 kg of tea costing Rs.~260/kg with 20 kg costing Rs.~360/kg and sells the mixture at Rs.~330/kg. Find his profit percent.

**Solution**

Cost of first lot $= 30 \times 260 = 7800$. \
Cost of second lot $= 20 \times 360 = 7200$. \
Total cost $= 7800 + 7200 = 15000$ for $30 + 20 = 50$ kg. \
Cost price per kg $= 15000 \div 50 = 300$. \
Profit per kg $= 330 - 300 = 30$. \
Profit percent $= 30/300 \times 100 = 10%$.

**➜ Answer: 10%**

**Example 17** `Infosys pattern`

A vessel holds 60 litres of pure milk. 12 litres is drawn out and replaced with water. This is done once more. How much milk is left?

**Solution**

Fraction removed each time $= 12/60 = 1/5$. \
Fraction of milk remaining each time $= 1 - 1/5 = 4/5$. \
After two rounds, milk $= 60 \times (4/5)^2$. \
$(4/5)^2 = 16/25$. \
Milk $= 60 \times 16/25 = 960/25 = 38.4$ litres. \
Water $= 60 - 38.4 = 21.6$ litres. \
Slow check: after round 1, milk $= 60 - 12 = 48$. In round 2 the 12 litres drawn is $12/60 = 1/5$ of the vessel, so it carries $48 \div 5 = 9.6$ litres of milk. Milk left $= 48 - 9.6 = 38.4$. Correct.

**➜ Answer: 38.4 litres of milk**

---
💡 **SHORTCUT**

**Use the formula $x(1 - y/x)^n$ only when the amount drawn each time is the same and the vessel is topped back to full.** If the vessel is not refilled, the concentration does not change at all — only the volume does.

**Example 18** `Accenture pattern`

A 40-litre mixture has milk and water in the ratio $3 : 1$. How much water must be added to make the ratio $3 : 2$?

**Solution**

Parts $= 3 + 1 = 4$. One part $= 40 \div 4 = 10$ L. \
Milk $= 3 \times 10 = 30$ L. Water $= 1 \times 10 = 10$ L. \
Adding water leaves the milk unchanged at 30 L. \
In the new ratio $3 : 2$, milk is 3 parts $= 30$ L, so one part $= 10$ L. \
New water $= 2 \times 10 = 20$ L. \
Water to add $= 20 - 10 = 10$ L.

**➜ Answer: 10 litres**

**Example 19** `Wipro pattern`

In a test, 20 boys average 68 marks and 30 girls average 78 marks. Find the class average.

**Solution**

Total marks of boys $= 20 \times 68 = 1360$. \
Total marks of girls $= 30 \times 78 = 2340$. \
Total marks $= 1360 + 2340 = 3700$. \
Total students $= 20 + 30 = 50$. \
Class average $= 3700 \div 50 = 74$. \
Alligation check: the mean 74 is 6 above 68 and 4 below 78, so boys : girls $= 4 : 6 = 2 : 3$, which matches 20 : 30. Correct.

**➜ Answer: 74 marks**

**Example 20** `TCS NQT pattern`

Six support agents closed these numbers of tickets in a day: 7, 9, 11, 11, 13, 69. Find the mean, the median and the mode. Which one describes a typical agent best?

**Solution**

Mean: sum $= 7 + 9 = 16$; $16 + 11 = 27$; $27 + 11 = 38$; $38 + 13 = 51$; $51 + 69 = 120$. \
Mean $= 120 \div 6 = 20$. \
Median: the list is already sorted. Count is even, so take the middle two, 11 and 11. \
Median $= (11 + 11)/2 = 11$. \
Mode: 11 appears twice, every other value once, so mode $= 11$. \
Five of the six agents closed 13 tickets or fewer, so the mean of 20 describes nobody. The single value 69 drags it up. The median of 11 is the honest summary.

**➜ Answer: Mean 20, median 11, mode 11 — the median describes a typical agent**

---
⚠️ **TRAP**

**A mean can sit outside the bulk of the data.** Whenever a question mentions one huge or tiny value, expect the mean and the median to disagree, and read carefully which one is asked for.

#### Practice — Tier 1 — Service *(target: 60 s/Q)*

+ Find the average of 8, 12, 17, 23 and 30.
+ The average of 9 numbers is 52. The average of the first five is 48 and of the last five is 56. Find the fifth number. 
**(a)** [52]  **(b)** [48]  **(c)** [56]  **(d)** [57.8]

+ The average age of 12 players is 25 years. The coach joins and the average becomes 26. Find the coach's age.
+ The average of 40 numbers is 31. One number, 49, was read as 19. Find the correct average.
+ A car covers 180 km at 45 km/h and another 180 km at 90 km/h. Find the average speed. 
**(a)** [60 km/h]  **(b)** [67.5 km/h]  **(c)** [75 km/h]  **(d)** [30 km/h]

+ Find the average of the first 15 odd numbers.
+ In what ratio must milk costing Rs.~54 per litre be mixed with water (free) to make the mixture cost Rs.~45 per litre?
+ From 80 litres of pure juice, 16 litres is removed and replaced with water. This is done twice in all. How much juice is left?
+ A 45-litre mixture has milk and water in the ratio $7 : 2$. How much water must be added to make it $7 : 3$?
+ The average salary of 15 staff is Rs.~28,000. When the manager's salary is added the average becomes Rs.~29,500. Find the manager's salary.
+ The average of 5 numbers is 27. Each number is multiplied by 3 and then 4 is subtracted from each. Find the new average.
+ The mean of 6 observations is 15. Two more observations, 21 and 27, are added. Find the new mean.
+ 12 kg of sugar at Rs.~42/kg is mixed with 8 kg at Rs.~52/kg. Find the price per kg of the mixture. 
**(a)** [Rs.~46]  **(b)** [Rs.~47]  **(c)** [Rs.~48]  **(d)** [Rs.~42]

+ Find the mean and the median of 6, 9, 12, 15, 18, 21, 87.
+ Three sections have 30, 35 and 35 students with average marks 64, 70 and 76. Find the overall average.

<details>
<summary><b>Answer key</b></summary>

**1.** 18. Sum $= 90$, and $90 \div 5 = 18$. \
**2.** (a) 52. Sum of all nine $= 468$; first five $= 240$, last five $= 280$, total $520$; overlap $= 520 - 468 = 52$. (b) 48 is the first-five average. (c) 56 is the last-five average. (d) 57.8 comes from dividing the combined 520 by 9 instead of subtracting the true total: $520 \div 9 = 57.8$. \
**3.** 38 years. Coach $= 25 + 13 \times 1 = 38$; or new sum $= 26 \times 13 = 338$ minus old sum $300$. \
**4.** 31.75. The sum was short by $49 - 19 = 30$, so the average rises by $30 \div 40 = 0.75$. \
**5.** (a) 60 km/h. $(2 \times 45 \times 90)/(45 + 90) = 8100/135 = 60$. (b) 67.5 is the plain average of the speeds — wrong, because the slow leg takes longer. (c) 75 comes from weighting each speed by itself instead of by time: $(45 \times 45 + 90 \times 90)/(45 + 90) = 10125/135 = 75$. (d) 30 comes from using only one 180 km leg as the total distance: $180 \div 6 = 30$. \
**6.** 15. The average of the first $n$ odd numbers is $n$ itself. \
**7.** $5 : 1$ (milk : water). Water costs 0, so $"water"/"milk" = (54 - 45)/(45 - 0) = 9/45 = 1/5$. \
**8.** 51.2 litres. $80 \times (1 - 16/80)^2 = 80 \times (0.8)^2 = 80 \times 0.64$. \
**9.** 5 litres. Milk $= 35$ L and water $= 10$ L; for $7 : 3$ the water must be 15 L. \
**10.** Rs.~52,000. Manager $= 28000 + 16 \times 1500 = 28000 + 24000$. \
**11.** 77. Multiplying every value by 3 multiplies the average by 3; subtracting 4 from every value subtracts 4 from the average. $27 \times 3 - 4 = 77$. \
**12.** 17.25. New sum $= 90 + 21 + 27 = 138$, new count $= 8$, and $138 \div 8 = 17.25$. \
**13.** (a) Rs.~46. Total cost $= 504 + 416 = 920$ for 20 kg. (b) 47 is the plain average of 42 and 52 — wrong, the weights differ. (c) 48 comes from swapping the weights: $(8 \times 42 + 12 \times 52)/20 = 960/20 = 48$. (d) 42 is the price of the **larger** lot; the blend price must sit strictly between 42 and 52. \
**14.** Mean 24, median 15. Sum $= 168$ and $168 \div 7 = 24$; the middle of seven sorted values is the 4th, which is 15. \
**15.** 70.3. Total $= 30 \times 64 + 35 \times 70 + 35 \times 76 = 1920 + 2450 + 2660 = 7030$ over 100 students.

## Tier 2 — Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 21** `Grab · pattern`

A driver earned an average of S$148 per day on the first 5 days of the week and S$225 per day on the last 2 days. Find his average for the whole 7-day week.

**Solution**

Earnings for the first 5 days $= 5 \times 148 = 740$. \
Earnings for the last 2 days $= 2 \times 225 = 450$. \
Total $= 740 + 450 = 1190$. \
Average $= 1190 \div 7 = 170$.

**➜ Answer: S$170 per day**

**Example 22** `Shopee · pattern`

In March a seller had 8,000 orders at an average order value of S$36. In April the order count rose 25% and the average order value fell 8%. Find the average order value across the two months together.

**Solution**

**March.** \
Orders $= 8000$. AOV $= 36$. \
Revenue $= 8000 \times 36 = 288000$. \
**April.** \
Orders $= 8000 \times 1.25 = 10000$. \
AOV $= 36 \times 0.92 = 33.12$. \
Revenue $= 10000 \times 33.12 = 331200$. \
**Combined.** \
Total revenue $= 288000 + 331200 = 619200$. \
Total orders $= 8000 + 10000 = 18000$. \
Combined AOV $= 619200 \div 18000 = 34.40$.

**➜ Answer: S$34.40**

---
⚠️ **TRAP**

**Do not average 36 and 33.12 to get 34.56.** April carried more orders, so it pulls the combined figure down past the midpoint. Always rebuild the two totals first.

**Example 23** `Agoda · pattern`

Over 30 nights a Bangkok hotel's average room rate was THB~2,800. Over the first 18 of those nights it was THB~2,500. Find the average over the remaining 12 nights.

**Solution**

Total over 30 nights $= 2800 \times 30 = 84000$. \
Total over the first 18 nights $= 2500 \times 18 = 45000$. \
Total over the last 12 nights $= 84000 - 45000 = 39000$. \
Average $= 39000 \div 12 = 3250$.

**➜ Answer: THB~3,250 per night**

**Example 24** `DBS · pattern`

A bank blends two bond funds, one yielding 3.2% and one yielding 5.6%, into a S$4.8 million portfolio with an overall yield of 4.1%. How much sits in each fund?

**Solution**

Alligation on the yields. $C = 3.2$, $D = 5.6$, $M = 4.1$. \
$D - M = 5.6 - 4.1 = 1.5$. \
$M - C = 4.1 - 3.2 = 0.9$. \
$"amount at 3.2%"/"amount at 5.6%" = 1.5/0.9 = 15/9 = 5/3$. \
Total parts $= 5 + 3 = 8$. One part $= 4.8 \div 8 = 0.6$ million. \
At 3.2%: $5 \times 0.6 = 3.0$ million. \
At 5.6%: $3 \times 0.6 = 1.8$ million. \
Check: interest $= 3.0 \times 0.032 + 1.8 \times 0.056 = 0.096 + 0.1008 = 0.1968$ million. \
$0.1968 \div 4.8 = 0.041 = 4.1%$. Correct.

**➜ Answer: S$3.0 million at 3.2% and S$1.8 million at 5.6%**

---
💡 **SHORTCUT**

**Alligation with decimals: clear them first.** Turn $1.5 : 0.9$ into $15 : 9$ and then $5 : 3$. You only ever need the ratio, so any common multiplier is free.

**Example 25** `Sea / Shopee · pattern`

A 90-litre tank is full of pure syrup. 18 litres is drawn off and replaced with water. This is repeated twice more, three rounds in all. Find the final ratio of syrup to water.

**Solution**

Fraction drawn each round $= 18/90 = 1/5 = 0.2$. \
Fraction of syrup kept each round $= 1 - 0.2 = 0.8$. \
After 3 rounds the syrup fraction $= (0.8)^3$. \
$(0.8)^2 = 0.64$. \
$(0.8)^3 = 0.64 \times 0.8 = 0.512$. \
Syrup $= 90 \times 0.512 = 46.08$ litres. \
Water $= 90 - 46.08 = 43.92$ litres. \
Ratio $= 46.08 : 43.92$. Multiply both by 1000 to clear decimals: $46080 : 43920$. \
Both are $0.512 : 0.488$, that is $512 : 488$. Divide both by 8: $64 : 61$.

**➜ Answer: Syrup : water $= 64 : 61$ (46.08 L and 43.92 L)**

---
⚠️ **TRAP**

**$(0.8)^3$ is the syrup fraction of the whole tank, not the syrup-to-water ratio.** Convert to actual litres, or use $0.512 : (1 - 0.512)$. Writing the answer as $512 : 1000$ is a very common slip.

**Example 26** `SCB · pattern`

The average age of 8 analysts in a team is 31 years. Two analysts aged 26 and 34 leave, and two new analysts join whose average age is 24. Find the new team average.

**Solution**

Sum of ages now $= 31 \times 8 = 248$. \
The two leavers total $26 + 34 = 60$. \
Sum after they leave $= 248 - 60 = 188$ for 6 people. \
The two joiners total $24 \times 2 = 48$. \
New sum $= 188 + 48 = 236$ for $6 + 2 = 8$ people. \
New average $= 236 \div 8 = 29.5$ years.

**➜ Answer: 29.5 years**

**Example 27** `LINE MAN · pattern`

A rider covers 12 km at 24 km/h, then 9 km at 18 km/h, then waits 10 minutes at a restaurant, then covers 15 km at 30 km/h. Find his average speed for the whole trip, counting the wait.

**Solution**

Leg 1 time $= 12/24 = 0.5$ h. \
Leg 2 time $= 9/18 = 0.5$ h. \
Wait $= 10$ minutes $= 10/60 = 1/6$ h. \
Leg 3 time $= 15/30 = 0.5$ h. \
Total time $= 0.5 + 0.5 + 0.5 + 1/6 = 1.5 + 0.1667 = 1.6667$ h, which is exactly $5/3$ h. \
Total distance $= 12 + 9 + 15 = 36$ km. \
Average speed $= 36 \div 5/3 = 36 \times 3/5 = 108/5 = 21.6$ km/h.

**➜ Answer: 21.6 km/h**

---
⚠️ **TRAP**

**Waiting time counts.** It adds to the denominator and adds nothing to the numerator. Drop the 10-minute wait and you get 24 km/h, which is wrong by more than 10%.

**Example 28** `GIC · pattern`

A S$8 million portfolio returned 7% for the year. It holds only equities returning 12% and bonds returning 4%. How much is in equities?

**Solution**

Alligation on returns. $C = 4$ (bonds), $D = 12$ (equities), $M = 7$. \
$D - M = 12 - 7 = 5$. \
$M - C = 7 - 4 = 3$. \
$"bonds"/"equities" = 5/3$. \
Total parts $= 5 + 3 = 8$. One part $= 8 \div 8 = 1$ million. \
Bonds $= 5$ million. Equities $= 3$ million. \
Check: $3 \times 0.12 + 5 \times 0.04 = 0.36 + 0.20 = 0.56$ million on 8 million, and $0.56 \div 8 = 0.07 = 7%$. Correct.

**➜ Answer: S$3 million in equities**

**Example 29** `Razer · pattern`

A shop buys 25 kg of premium coffee at THB~900/kg and 35 kg of regular coffee at THB~540/kg, blends them, and wants a profit of 25% on the blend. Find the selling price per kg.

**Solution**

Cost of premium $= 25 \times 900 = 22500$. \
Cost of regular $= 35 \times 540 = 18900$. \
Total cost $= 22500 + 18900 = 41400$. \
Total weight $= 25 + 35 = 60$ kg. \
Cost price per kg $= 41400 \div 60 = 690$. \
Selling price $= 690 \times 1.25$. \
$690 \times 1.25 = 690 + 690 \times 0.25 = 690 + 172.50 = 862.50$.

**➜ Answer: THB~862.50 per kg**

**Example 30** `Grab · pattern`

Nine food deliveries took these times, in minutes: 18, 21, 22, 24, 25, 27, 29, 33, 125. The operations team must publish one number as the "typical delivery time". Find the mean and the median and say which should be published.

**Solution**

Mean: add in order. \
$18 + 21 = 39$; $39 + 22 = 61$; $61 + 24 = 85$; $85 + 25 = 110$; $110 + 27 = 137$; $137 + 29 = 166$; $166 + 33 = 199$; $199 + 125 = 324$. \
Mean $= 324 \div 9 = 36$ minutes. \
Median: the list is sorted and there are 9 values, so the median is the 5th one. \
Median $= 25$ minutes. \
Eight of the nine deliveries finished in 33 minutes or less. The 125-minute outlier alone lifts the mean by about 11 minutes. \
Publish the median.

**➜ Answer: Mean 36 min, median 25 min — publish the median**

#### Practice — Tier 2 — Singapore & Thailand *(target: 100 s/Q)*

+ A driver earned S$132, S$145, S$120, S$168, S$155 and S$150 on six days. Find his average daily earning.
+ A seller's average monthly sales for January to April is S$24,500, and for February to May it is S$26,000. May's sales were S$30,200. Find January's sales.
+ In what ratio must a 4.5% bond be mixed with a 7.5% bond to give a portfolio yield of 5.5%? If the portfolio is S$9 million, how much is in the 7.5% bond?
+ From 120 litres of pure oil, 24 litres is drawn off and replaced with a cheaper oil. This is done three times in all. How much pure oil is left?
+ The average weight of 25 parcels is 8.4 kg. Two parcels weighing 12.5 kg and 13.5 kg are removed. Find the average weight of the remaining parcels.
+ A van covers 60 km at 30 km/h and the next 60 km at 60 km/h. Find the average speed.
+ A training intake has three groups: 24 trainees averaging 72, 36 averaging 78 and 40 averaging 65. Find the overall average.
+ Tea at THB~2,400/kg is mixed with tea at THB~1,600/kg. The blend sells at THB~2,310/kg at a profit of 10%. Find the mixing ratio.
+ A vessel has 54 litres of a milk-water mixture in the ratio $5 : 4$. How much of the mixture must be drawn off and replaced with pure milk to make the ratio $2 : 1$?
+ The average age of a 40-member team is 32 years. Eight members whose average age is 45 leave. Find the new average age.
+ A courier averaged 46 parcels a day over 20 working days, and 58 a day over the last 5 of those days. Find his average over the first 15 days.
+ Alloy A weighs 40 kg with copper : zinc $= 5 : 3$. Alloy B weighs 24 kg with copper : zinc $= 3 : 5$. They are melted together. Find the copper : zinc ratio of the new alloy.

<details>
<summary><b>Answer key</b></summary>

**1.** S$145. Sum $= 870$ over 6 days. \
**2.** S$24,200. Feb+Mar+Apr $= 4 \times 26000 - 30200 = 73800$; Jan $= 4 \times 24500 - 73800$. Shortcut: Jan $=$ May $- 4 \times ("difference of averages") = 30200 - 6000$. \
**3.** $2 : 1$, and S$3 million in the 7.5% bond. $(7.5 - 5.5) : (5.5 - 4.5) = 2 : 1$, so 6 million and 3 million. \
**4.** 61.44 litres. $120 times (1 - 24/120)^3 = 120 times 0.8^3 = 120 times 0.512$. \
**5.** 8 kg. Sum $= 8.4 times 25 = 210$; remove $12.5 + 13.5 = 26$; $184 div 23 = 8$. \
**6.** 40 km/h. Equal distances, so $(2 times 30 times 60)/(30 + 60) = 3600/90$. \
**7.** 71.36. Total $= 1728 + 2808 + 2600 = 7136$ over 100 trainees. \
**8.** $3 : 5$ (cheaper : dearer). Cost price of the blend $= 2310 div 1.10 = 2100$; then $(2400 - 2100) : (2100 - 1600) = 300 : 500$. \
**9.** 13.5 litres. Milk $= 30$, water $= 24$. Drawing off a fraction $f$ leaves water $= 24(1 - f)$ and milk $= 30(1 - f) + 54 f$. Setting milk $= 2 times$ water gives $30 + 24 f = 48 - 48 f$, so $72 f = 18$ and $f = 0.25$; $0.25 times 54 = 13.5$. \
**10.** 28.75 years. Sum $= 1280$; the leavers take $8 times 45 = 360$; $920 div 32 = 28.75$. \
**11.** 42 parcels a day. Total $= 920$; last five $= 290$; $630 div 15 = 42$. \
**12.** $17 : 15$. Alloy A: copper 25, zinc 15. Alloy B: copper 9, zinc 15. Totals 34 and 30.

## Tier 3 — Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 31** `Google · pattern`

Twenty **distinct** positive integers have an average of 30. What is the largest value the biggest of them can take?

**Solution**

**Insight: the sum is locked. To push one value as high as possible, squeeze every other value as low as it is allowed to go.**

Sum of all twenty $= 30 \times 20 = 600$. \
The other nineteen must be distinct positive integers, all different from each other. The smallest such set is $1, 2, 3, ..., 19$. \
Their sum $= (19 \times 20)/2 = 190$. \
Largest possible value $= 600 - 190 = 410$. \
Check the rules: 410 is a positive integer and is different from every number in $1 ... 19$, and $190 + 410 = 600$, so the average is $600 \div 20 = 30$. Correct.

**➜ Answer: 410**

**Example 32** `Amazon · pattern`

In a class of 50 the average score is 64. Every score is a whole number from 0 to 100. At most how many students could have scored above 90?

**Solution**

**Insight: turn "at most how many" into a budget question. The total score is fixed, and every high scorer spends a large slice of it.**

Total score $= 64 \times 50 = 3200$. \
"Above 90" with whole-number scores means at least 91. \
Suppose $k$ students scored 91 or more. They alone use at least $91 k$ marks. \
The other $50 - k$ students use at least 0 marks. \
So $91 k \\le 3200$. \
$3200 \div 91 = 35.16 ...$ \
Therefore $k \\le 35$. \
Now show 35 is actually reachable. Give 35 students exactly 91 marks: $35 \times 91 = 3185$. \
Marks left $= 3200 - 3185 = 15$ for the remaining $50 - 35 = 15$ students. \
Give each of them 1 mark: $15 \times 1 = 15$. \
Every score is a whole number between 0 and 100 and the total is $3185 + 15 = 3200$. Correct.

**➜ Answer: 35 students**

**Example 33** `Microsoft · pattern`

A tank holds 100 litres of pure acid. Every day 20 litres is drawn off and the tank is topped back to 100 litres with water. After how many days does the acid first fall below 50 litres?

**Solution**

**Insight: each day multiplies the acid by the same factor. So this is repeated multiplication, not repeated subtraction.**

Fraction drawn each day $= 20/100 = 0.2$. \
Fraction of acid kept each day $= 1 - 0.2 = 0.8$. \
After $n$ days, acid $= 100 \times (0.8)^n$. \
We need $100 \times (0.8)^n < 50$, that is $(0.8)^n < 0.5$. \
Day 1: $(0.8)^1 = 0.8$, acid $= 80$ L. Not below 50. \
Day 2: $(0.8)^2 = 0.64$, acid $= 64$ L. Not below 50. \
Day 3: $(0.8)^3 = 0.512$, acid $= 51.2$ L. Still not below 50. \
Day 4: $(0.8)^4 = 0.4096$, acid $= 40.96$ L. Below 50. \
Note how close day 3 is: 51.2 L. Guessing from the "20% a day" wording would give the wrong day.

**➜ Answer: On day 4, with 40.96 litres left**

**Example 34** `Goldman Sachs · pattern`

A fund gains 50% in year 1 and loses 40% in year 2. A report states that "the average annual return was $+5%$, so the fund is up". Find the true two-year change, and explain the error in one line.

**Solution**

**Insight: percentages apply to different bases, so they multiply, they do not average. Turn each percent into a growth factor and multiply.**

Start with 100 units. \
Year 1 factor $= 1 + 0.50 = 1.5$. \
Value after year 1 $= 100 \times 1.5 = 150$. \
Year 2 factor $= 1 - 0.40 = 0.6$. \
Value after year 2 $= 150 \times 0.6 = 90$. \
True change $= 90 - 100 = -10$ on a base of 100, that is $-10%$ over two years. \
The error: the $+50%$ was earned on 100 but the $-40%$ was charged on 150, so the loss is bigger in money terms even though it is smaller in percent terms. $ 1.5 \times 0.6 = 0.9 , \quad "not" \quad (1.5 + 0.6)/2 = 1.05 $

**➜ Answer: The fund is down 10% over the two years**

**Example 35** `D. E. Shaw · pattern`

Tokens numbered 1 to 50 sit in a bag. Every token whose number is a multiple of 5 is removed. Find the average of the tokens that remain.

**Solution**

**Insight: do not list 40 numbers. Work with sums — the sum of what remains is the sum of everything minus the sum of what left.**

Sum of 1 to 50 $= (50 \times 51)/2 = 1275$. \
Multiples of 5 up to 50: $5, 10, 15, ..., 50$. There are $50 \div 5 = 10$ of them. \
Their sum $= 5(1 + 2 + ... + 10) = 5 \times (10 \times 11)/2 = 5 \times 55 = 275$. \
Sum of the tokens left $= 1275 - 275 = 1000$. \
Count of tokens left $= 50 - 10 = 40$. \
Average $= 1000 \div 40 = 25$. \
Sense check: the whole set averages $1275 \div 50 = 25.5$, and the group removed averaged $275 \div 10 = 27.5$, which is above 25.5. Removing an above-average group must pull the average down, and it did, to 25. Correct.

**➜ Answer: 25**

**Example 36** `Adobe · pattern`

Rice at Rs.~40, Rs.~50 and Rs.~70 per kg is mixed to sell at Rs.~55 per kg. The Rs.~40 and Rs.~50 varieties are used in the ratio $2 : 3$. Find the ratio of all three.

**Solution**

**Insight: alligation handles only two things at a time. So first fuse the two varieties whose ratio is already fixed into one imaginary variety, then alligate that against the third.**

Step 1 — price of the fused variety. \
Take 2 kg at 40 and 3 kg at 50. \
Cost $= 2 \times 40 + 3 \times 50 = 80 + 150 = 230$ for 5 kg. \
Price $= 230 \div 5 = 46$ per kg. \
Step 2 — alligate 46 against 70 at a mean of 55. \
$D - M = 70 - 55 = 15$. \
$M - C = 55 - 46 = 9$. \
$"fused"/"70-rice" = 15/9 = 5/3$. \
Step 3 — unfold the fused part. \
The fused variety is 5 parts, and inside it the split is $2 : 3$, which also sums to 5. So the 5 parts are exactly 2 parts of Rs.~40 rice and 3 parts of Rs.~50 rice. \
Ratio $= 2 : 3 : 3$. \
Check: $(2 \times 40 + 3 \times 50 + 3 \times 70)/(2 + 3 + 3) = (80 + 150 + 210)/8 = 440/8 = 55$. Correct.

**➜ Answer: $40:50:70$ rice $= 2 : 3 : 3$**

**Example 37** `Uber · pattern`

A driver wants to average 60 km/h over a 60 km round trip, 30 km each way. He drives the first 30 km at 30 km/h. What speed must he use on the return leg?

**Solution**

**Insight: an average speed target is really a time budget. Check the budget before doing any algebra.**

Time budget for the whole trip $= "total distance"/"target speed" = 60/60 = 1$ hour. \
Time already used on the first leg $= 30/30 = 1$ hour. \
Time left for the return leg $= 1 - 1 = 0$ hours. \
He must cover 30 km in zero time. No finite speed does that. \
Algebra says the same thing. Let the return speed be $v$: \
$ 60/(1 + 30/v) = 60 arrow.r 1 + 30/v = 1 arrow.r 30/v = 0 $
which has no solution for finite $v$. \
The general rule: to double the average speed of the first half, the second half needs infinite speed, because the first half has already spent the entire time budget.

**➜ Answer: Impossible — no finite speed works**

**Example 38** `Google · pattern`

Seven **distinct** positive integers have a median of 12 and a mean of 15. What is the largest the biggest value can be?

**Solution**

**Insight: with seven sorted values the median pins the 4th value. Everything below it and the two values just above it must be pushed as low as the rules allow, and whatever is left goes to the 7th.**

Write the sorted values as $a_1 < a_2 < a_3 < a_4 < a_5 < a_6 < a_7$. \
Median is the 4th value, so $a_4 = 12$. \
Sum $= 15 \times 7 = 105$. \
Now minimise everything except $a_7$. \
$a_1, a_2, a_3$ are distinct positive integers below 12. The smallest choice is $1, 2, 3$, summing to 6. \
$a_5, a_6$ are distinct integers above 12. The smallest choice is $13, 14$, summing to 27. \
Used so far $= 6 + 12 + 27 = 45$. \
$a_7 = 105 - 45 = 60$. \
Check the list $1, 2, 3, 12, 13, 14, 60$: \
all distinct and increasing, so $a_7 = 60 > 14$. Correct. \
Sum $= 1 + 2 + 3 + 12 + 13 + 14 + 60 = 105$, so the mean is $105 \div 7 = 15$. Correct. \
The 4th value is 12, so the median is 12. Correct.

**➜ Answer: 60**

#### Practice — Tier 3 — Product *(target: 4 min/Q)*

+ Fifteen distinct positive integers have an average of 20. What is the largest the biggest of them can be?
+ In a class of 40 the average score is 70, and every score is a whole number from 0 to 100. At most how many students could have scored below 40?
+ A 200-litre tank is full of pure glycerin. Each cycle, 25 litres is drawn off and the tank is topped back up with water. After how many cycles does the glycerin first drop below 120 litres?
+ An investment rises 25% in year 1, falls 20% in year 2 and rises 25% in year 3. Find the net percent change over the three years.
+ Tokens numbered 1 to 60 are in a bag and every multiple of 4 is removed. Find the average of the tokens left.
+ Oil grades costing Rs.~80, Rs.~95 and Rs.~120 per litre are blended to sell at Rs.~100 per litre. The Rs.~80 and Rs.~95 grades are used in the ratio $1 : 2$. Find the ratio of all three.
+ A cyclist must average 24 km/h over 48 km. He covers the first 24 km at 16 km/h. What speed does he need over the rest?
+ Six distinct positive integers have a median of 20 and a mean of 25. What is the largest the biggest value can be?

<details>
<summary><b>Answer key</b></summary>

**1.** 195. The total is $20 \times 15 = 300$. The other fourteen must be distinct positive integers, so their smallest possible sum is $1 + 2 + ... + 14 = (14 \times 15)/2 = 105$. The biggest value is then $300 - 105 = 195$, which is larger than 14, so the set is valid.

**2.** 19 students. Total $= 70 \times 40 = 2800$. If $k$ students score at most 39, the largest total the class can reach is $39k + 100(40 - k) = 4000 - 61k$. This must be at least 2800, so $61k \\le 1200$ and $k \\le 19.67$, giving $k \\le 19$. Now build a class that reaches 19. Give 19 students 39 marks each: $19 \times 39 = 741$. The other $40 - 19 = 21$ students must supply $2800 - 741 = 2059$ marks. Give 20 of them 100 marks each $= 2000$, and the last one $2059 - 2000 = 59$ marks. Every score is a whole number from 0 to 100, the total is $741 + 2000 + 59 = 2800$, and exactly 19 students are below 40 (59 is not). So 19 is reached.

**3.** 4 cycles. Fraction kept each cycle $= 1 - 25/200 = 0.875$. Glycerin after $n$ cycles $= 200 \times (0.875)^n$: 175.0, then 153.1, then 134.0, then 117.2. The first value below 120 comes on cycle 4. Note that cycle 3 leaves 134 L, so stopping at 3 is the trap.

**4.** Up 25%. Multiply the growth factors: $1.25 \times 0.80 \times 1.25$. First $1.25 \times 0.80 = 1.00$, then $1.00 \times 1.25 = 1.25$. So the value is 1.25 times the start, a 25% rise. Adding the percents would wrongly give $+30%$.

**5.** 30. Sum of 1 to 60 $= (60 \times 61)/2 = 1830$. Multiples of 4 up to 60 are $4, 8, ..., 60$, that is 15 numbers summing to $4 \times (15 \times 16)/2 = 4 \times 120 = 480$. What is left: sum $= 1830 - 480 = 1350$ over $60 - 15 = 45$ tokens, so $1350 \div 45 = 30$.

**6.** $2 : 4 : 3$. Fuse the first two in $1 : 2$: cost $= (1 \times 80 + 2 \times 95)/3 = 270/3 = 90$. Alligate 90 against 120 at mean 100: $(120 - 100) : (100 - 90) = 20 : 10 = 2 : 1$. The fused part is 2 units but splits in $1 : 2$, which sums to 3, so multiply everything by 3: fused $= 6$ units splitting as 2 and 4, and the third grade $= 3$ units. Check: $(2 \times 80 + 4 \times 95 + 3 \times 120)/9 = (160 + 380 + 360)/9 = 900/9 = 100$.

**7.** 48 km/h. Time budget $= 48/24 = 2$ hours. Time already used $= 24/16 = 1.5$ hours. Time left $= 0.5$ hours for the remaining 24 km, so speed $= 24/0.5 = 48$ km/h. Unlike Example 37 the budget is not exhausted, so a finite answer exists.

**8.** 85. Sum $= 25 \times 6 = 150$. With six values the median is the average of the 3rd and 4th, so $a_3 + a_4 = 40$ with $a_3 < a_4$. To leave the most for $a_6$, make $a_4$ as small as possible: $a_3 = 19$ and $a_4 = 21$. Then $a_1 = 1$, $a_2 = 2$ and $a_5 = 22$. Used $= 1 + 2 + 19 + 21 + 22 = 65$, so $a_6 = 150 - 65 = 85$. Check $1, 2, 19, 21, 22, 85$: distinct, median $= (19 + 21)/2 = 20$, sum $= 150$.

## Mixed set — exam conditions

#### Practice — Tier 1 — Service *(target: 25 minutes for all 18)*

+ Find the average of 12, 18, 24, 30 and 36.
+ The average of 20 numbers is 45. If 5 is added to every number, find the new average.
+ The average of 6 numbers is 38. One number is removed and the average of the rest becomes 40. Find the number removed.
+ 15 litres of a 20% acid solution is mixed with 25 litres of a 44% acid solution. Find the concentration of the mixture.
+ A car covers three equal stretches at 30 km/h, 40 km/h and 60 km/h. Find the average speed for the whole run.
+ From 72 litres of pure milk, 18 litres is drawn off and replaced with water, twice in all. How much milk is left?
+ The average age of a family of 5 is 28 years. The youngest is 6 years old. Find the average age of the other four.
+ In what ratio must goods at Rs.~36/kg and Rs.~60/kg be mixed to cost Rs.~45/kg?
+ Find the average of the first 12 even numbers.
+ A batsman's average after 16 innings is 36. He scores 87 in the 17th innings. Find his new average.
+ A person's average monthly income for January to June is Rs.~42,000 and for July to December is Rs.~48,000. Find the average for the year.
+ Alloy A weighs 60 kg with tin : lead $= 3 : 2$. Alloy B weighs 40 kg with tin : lead $= 1 : 3$. They are melted together. Find the tin : lead ratio.
+ Daily sales at nine shops, in thousands of rupees, are 12, 14, 15, 15, 16, 18, 19, 21 and 95. Find the mean and the median.
+ The average of 25 numbers is 54. Two numbers, 38 and 46, were wrongly entered as 83 and 64. Find the correct average.
+ Forty distinct positive integers have an average of 50. What is the largest the biggest of them can be?
+ A 60-litre mixture has milk and water in the ratio $7 : 3$. How much water must be added to make it $3 : 2$?
+ The average age of 30 boys is 15 years. Ten new boys join and the average becomes 16 years. Find the average age of the new boys.
+ A car travels from P to Q at 50 km/h and returns at 75 km/h. Find the average speed for the round trip.

<details>
<summary><b>Answer key</b></summary>

**1.** 24. Sum $= 120$ over 5 values; the numbers are evenly spaced so the middle one is the average. \
**2.** 50. Adding the same amount to every value adds it to the average. \
**3.** 28. Old sum $= 228$; the remaining five sum to $40 \times 5 = 200$; removed $= 228 - 200$. \
**4.** 35%. Acid $= 0.20 \times 15 + 0.44 \times 25 = 3 + 11 = 14$ litres in 40 litres, and $14/40 = 0.35$. \
**5.** 40 km/h. Equal distances, so $3 \div (1/30 + 1/40 + 1/60) = 3 \div (4 + 3 + 2)/120 = 3 \times 120/9$. \
**6.** 40.5 litres. $72 \times (1 - 18/72)^2 = 72 \times (0.75)^2 = 72 \times 0.5625$. \
**7.** 33.5 years. Total $= 140$; remove 6; $134 \div 4 = 33.5$. \
**8.** $5 : 3$. $(60 - 45) : (45 - 36) = 15 : 9$. \
**9.** 13. The average of the first $n$ even numbers is $n + 1$. \
**10.** 39. Old sum $= 576$; new sum $= 663$; $663 \div 17 = 39$. Shortcut: the average rises by $(87 - 36)/17 = 3$. \
**11.** Rs.~45,000. Both halves have six months, so the plain average of 42,000 and 48,000 is correct here. \
**12.** $23 : 27$. Alloy A: tin 36, lead 24. Alloy B: tin 10, lead 30. Totals 46 and 54. \
**13.** Mean 25, median 16. Sum $= 225$ over 9 shops; the median is the 5th of the nine sorted values. \
**14.** 51.48. The entered sum was too big by $(83 - 38) + (64 - 46) = 45 + 18 = 63$; correct sum $= 1350 - 63 = 1287$, and $1287 \div 25 = 51.48$. \
**15.** 1,220. Total $= 2000$; the other 39 are at least $1 + 2 + ... + 39 = (39 \times 40)/2 = 780$; $2000 - 780 = 1220$. \
**16.** 10 litres. Milk $= 42$ L, water $= 18$ L; for $3 : 2$ the water must be $42 \times 2/3 = 28$ L. \
**17.** 19 years. Old sum $= 450$; new sum $= 40 \times 16 = 640$; the ten newcomers total 190, so their average is 19. \
**18.** 60 km/h. $(2 \times 50 \times 75)/(50 + 75) = 7500/125$.

## 📋 One-page revision card

**THE ONE MOVE THAT SOLVES MOST QUESTIONS** \
Sum $=$ average $\times$ count. Convert every average in the question into a sum, do the adding and subtracting on sums, then divide once at the end.

**AVERAGE FACTS** \
First $n$ naturals: $(n+1)/2$ · first $n$ odd: $n$ · first $n$ even: $n + 1$. \
Evenly spaced list: average $=$ (first $+$ last) $\div 2$; for an odd count this is the middle term. \
Replace $a$ by $b$ in $n$ values: average moves by $(b - a) / n$. \
New member $x$ joins $n$ values averaging $A$: new average $= (n A + x)/(n + 1)$. \
If the average rises by $d$ when the $(n+1)$-th member joins: $x = A + (n+1) d$. \
Add $c$ to every value $arrow.r$ average $+ c$. Multiply every value by $c$ $arrow.r$ average $\times c$.

**WEIGHTED AVERAGE AND ALLIGATION**
$ A = (n_1 A_1 + n_2 A_2)/(n_1 + n_2) , \quad "cheaper"/"dearer" = (D - M)/(M - C) $
Alligation works on any averaging quantity: price, percent, yield, speed, age, marks. \
Three things? Fuse the two whose ratio is already known into one price, then alligate.

**MIXTURES** \
Add water only $arrow.r$ the milk stays fixed. Rebuild the new total from the fixed part. \
Repeated replacement (draw $y$ from $x$, top up, $n$ times): pure left $= x (1 - y/x)^n$. \
Draw off and replace with the **pure** liquid instead of water: milk $= M(1-f) + x f$, water $= W(1-f)$, where $f$ is the fraction drawn.

**SPEED** \
Average speed $=$ total distance $\div$ total time. Count every stop. \
Equal distances at $u$ and $v$: $(2 u v)/(u + v)$. Three legs: $3 / (1/u + 1/v + 1/w)$. \
Percent changes across years multiply as factors; they never average.

**MEAN, MEDIAN, MODE** \
Mean follows the outliers. Median ignores them. Mode is the most frequent value. \
Even count $arrow.r$ median is the average of the two middle values.

**TOP 5 TRAPS**
+ Average speed is not the average of the speeds. Equal distances, not equal times, is the usual case.
+ Alligation returns a **ratio of quantities**, never the quantities. Multiply by the total afterwards.
+ $(1 - y/x)^n$ is the fraction of **pure liquid in the whole vessel**, not the pure-to-water ratio. Subtract to get the water.
+ When a wrong entry is corrected, decide the direction first. Entered too low $arrow.r$ the average goes up.
+ Percent returns over several years multiply. $+50%$ then $-40%$ is $-10%$, not $+5%$.
+ Bonus trap: waiting time, rest stops and idle hours all count in the total time for average speed.

</details>

</details>

</details>

</details>
