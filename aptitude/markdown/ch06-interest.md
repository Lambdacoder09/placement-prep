# Chapter 6 — Simple & Compound Interest

*Simple interest adds. Compound interest multiplies.*

## What you need to know

**WHAT YOU NEED TO KNOW**

**Symbols.** $P$ = principal, $R$ = rate per cent per year, $T$ or $n$ = time in years, $A$ = amount (principal + interest).

**Simple interest — interest only on the original principal**

$ "SI" = (P R T)/100   A = P + "SI" = P (1 + (R T)/100) $

$ P = (100 "SI")/(R T)   R = (100 "SI")/(P T)   T = (100 "SI")/(P R) $

**Compound interest — interest on interest**

$ A = P (1 + R/100)^n   "CI" = A - P = P [ (1 + R/100)^n - 1 ] $

**Compounding more than once a year** (nominal rate $R$% per year) — divide the rate, multiply the periods:

#table(columns: 4,
[**Compounded**], [yearly], [half-yearly], [quarterly],
[**Rate, periods in $n$ yr**], [$R$%, $n$], [$R/2$%, $2n$], [$R/4$%, $4n$],
[**Amount**], [$P(1 + R/100)^n$], [$P(1 + R/200)^(2n)$], [$P(1 + R/400)^(4n)$],
)

Monthly: rate $R/12$%, periods $12n$, amount $P(1 + R/1200)^(12n)$.

**Effective annual rate** with $k$ compoundings a year: $"EAR" = [(1 + R/(100k))^k - 1] \times 100$ %.

**Difference between CI and SI** (same $P$ and $R$), and the 2-year ratio:

$ "2 yr:" D = P (R/100)^2   "3 yr:" D = P (R^2 (300 + R))/10^6   "CI"/"SI" = 1 + R/200 $

**Doubling and multiplying**

- SI: doubles when $R T = 100$. Doubles in $T$ $arrow.r$ triples in $2T$ $arrow.r$ $m$ times in $(m-1)T$.
- CI: $m$ times in $T$ $arrow.r$ $m^2$ times in $2T$ $arrow.r$ $m^3$ times in $3T$.
- **Rule of 72:** at CI, doubling time $\approx 72 / R$ years.

**Growth, decay, depreciation (compound interest in disguise).** Value after $n$ years $= P (1 plus.minus R/100)^n$ — use $+$ for growth (population, revenue, prices) and $-$ for decay.

**Equal annual instalments of $x$ on a loan $P$.** At CI, discount every payment back to today, writing $v = 1 + R/100$: $P = x/v + x/v^2 + \dots.c + x/v^n$. At SI, instead compare values at the end of year $n$ — each instalment earns simple interest for the years still left.

**EMI (reducing balance)**, with $i = R/1200$ per month and $n$ months: $"EMI" = P i (1+i)^n / ((1+i)^n - 1)$.

**Flat-rate loan.** Total interest $= (P R T)/100$ and $"EMI" = (P + "total interest")/("number of months")$. The true reducing-balance rate is roughly **twice** the quoted flat rate.

**Real return.** Nominal $R$%, inflation $f$%: real factor per year $= (1 + R/100)/(1 + f/100)$. Divide, never subtract.

## Warm-up

### Warm-up

**Example 1**

Find the simple interest on Rs.~8,000 at 9% per year for 3 years.

**Solution**

$"SI" = (8000 \times 9 \times 3)/100$.

$8000 \times 9 = 72000$. Then $72000 \times 3 = 216000$.

$216000/100 = 2160$.

**➜ Answer: Rs.~2,160**

**Example 2**

The simple interest on Rs.~6,000 for 4 years is Rs.~1,440. Find the rate.

**Solution**

$R = (100 \times "SI")/(P T) = (100 \times 1440)/(6000 \times 4)$.

$100 \times 1440 = 144000$. And $6000 \times 4 = 24000$.

$144000/24000 = 6$.

**➜ Answer: 6% per year**

**Example 3**

Find the amount on Rs.~12,500 at 8% simple interest for 5 years.

**Solution**

$"SI" = (12500 \times 8 \times 5)/100$.

$12500 \times 8 = 100000$. Then $100000 \times 5 = 500000$.

$500000/100 = 5000$.

$A = 12500 + 5000 = 17500$.

**➜ Answer: Rs.~17,500**

**Example 4**

Find the compound interest on Rs.~10,000 at 10% per year for 2 years, compounded yearly.

**Solution**

Year 1: $10000 \times 1.10 = 11000$.

Year 2: $11000 \times 1.10 = 12100$.

$"CI" = 12100 - 10000 = 2100$.

**➜ Answer: Rs.~2,100**

**Example 5**

Find the compound interest on Rs.~5,000 at 20% per year for 2 years.

**Solution**

Year 1: $5000 \times 1.20 = 6000$.

Year 2: $6000 \times 1.20 = 7200$.

$"CI" = 7200 - 5000 = 2200$.

**➜ Answer: Rs.~2,200**

**Example 6**

Find the difference between CI and SI on Rs.~20,000 at 5% per year for 2 years.

**Solution**

$D = P (R/100)^2 = 20000 \times (5/100)^2 = 20000 \times (0.05)^2$.

$(0.05)^2 = 0.0025$.

$20000 \times 0.0025 = 50$.

**➜ Answer: Rs.~50**

**Example 7**

Find the compound interest on Rs.~16,000 at 10% per year for 1 year, compounded half-yearly.

**Solution**

Half-yearly rate $= 10/2 = 5$%. Number of periods $= 2$.

Period 1: $16000 \times 1.05 = 16800$.

Period 2: $16800 \times 1.05 = 17640$.

$"CI" = 17640 - 16000 = 1640$.

**➜ Answer: Rs.~1,640**

**Example 8**

In how many years will Rs.~4,000 double itself at 12.5% simple interest?

**Solution**

To double, the interest earned must equal the principal: $"SI" = 4000$.

$T = (100 \times "SI")/(P R) = (100 \times 4000)/(4000 \times 12.5) = 100/12.5 = 8$.

**➜ Answer: 8 years**

## Tier 1 — Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

Find the simple interest on Rs.~24,000 at 7.5% per year for 2 years and 8 months.

**Solution**

First turn the time into years.

8 months $= 8/12 = 2/3$ of a year.

$T = 2 + 2/3 = 8/3$ years.

Interest for **one** year $= (24000 \times 7.5)/100$.

$24000 \times 7.5 = 180000$. Then $180000/100 = 1800$.

Interest for $8/3$ years $= 1800 \times 8/3$.

$1800/3 = 600$. Then $600 \times 8 = 4800$.

**➜ Answer: Rs.~4,800**

---
⚠️ **TRAP**

Never plug "2 years 8 months" in as $T = 2.8$. Months must be divided by 12, not by 10. $2.8$ would give Rs.~5,040 — wrong by Rs.~240.

**Example 10** `Accenture pattern`

A sum of money at simple interest amounts to Rs.~9,560 in 3 years and to Rs.~10,600 in 5 years. Find the sum and the rate.

**Solution**

**Key idea: with SI, every year adds exactly the same amount.**

Growth over 2 years (from year 3 to year 5) $= 10600 - 9560 = 1040$.

Interest for 1 year $= 1040/2 = 520$.

Interest for 3 years $= 520 \times 3 = 1560$.

$P = 9560 - 1560 = 8000$.

$R = (100 \times 520)/(8000 \times 1) = 52000/8000 = 6.5$.

**➜ Answer: Sum Rs.~8,000, rate 6.5% per year**

**Example 11** `Infosys pattern`

Find the compound interest on Rs.~12,000 at 10% per year for 3 years.

**Solution**

Year 1: $12000 \times 1.10 = 13200$.

Year 2: $13200 \times 1.10 = 14520$.

Year 3: $14520 \times 1.10 = 15972$.

$"CI" = 15972 - 12000 = 3972$.

**➜ Answer: Rs.~3,972**

---
💡 **SHORTCUT**

Learn the 10% powers by heart — they appear constantly:
$ 1.1^2 = 1.21   1.1^3 = 1.331   1.1^4 = 1.4641   1.1^5 = 1.61051 $
Also $1.05^2 = 1.1025$, $1.05^3 = 1.157625$, $1.2^2 = 1.44$, $1.2^3 = 1.728$, $1.25^3 = 1.953125$.

**Example 12** `Wipro pattern`

The difference between the compound interest and the simple interest on a sum for 2 years at 10% per year is Rs.~360. Find the sum.

**Solution**

$D = P (R/100)^2$.

$(10/100)^2 = (0.1)^2 = 0.01$.

So $0.01 P = 360$.

$P = 360/0.01 = 36000$.

**Check.** SI $= (36000 \times 10 \times 2)/100 = 7200$.
CI: $36000 \times 1.21 = 43560$, so CI $= 7560$.
Difference $= 7560 - 7200 = 360$. Correct.

**➜ Answer: Rs.~36,000**

---
💡 **SHORTCUT**

**Why the 2-year difference is $P(R/100)^2$.** SI ignores the interest earned in year 1. CI pays interest on it. So the gap is simply "$R$% of the first year's interest":
$ R/100 \times (P R)/100 = (P R^2)/10000 = P(R/100)^2 $

**Example 13** `Capgemini pattern`

Find the compound interest on Rs.~50,000 at 8% per year for 6 months, compounded quarterly.

**Solution**

Quarterly rate $= 8/4 = 2$%.

6 months = 2 quarters, so 2 periods.

Period 1: $50000 \times 1.02 = 51000$.

Period 2: $51000 \times 1.02 = 52020$.

$"CI" = 52020 - 50000 = 2020$.

**➜ Answer: Rs.~2,020**

---
⚠️ **TRAP**

"Compounded quarterly" changes **two** things at once: the rate is divided by 4 **and** the number of periods is multiplied by 4. Students who divide the rate but forget to multiply the periods (or the reverse) lose the mark every time.

**Example 14** `Cognizant pattern`

A sum of money doubles itself in 8 years at simple interest. In how many years will it triple?

**Solution**

**Doubling** means interest earned $=P$.

$P = (P \times R \times 8)/100$, so $R \times 8 = 100$ and $R = 12.5$%.

**Tripling** means interest earned $= 2P$.

$2P = (P \times 12.5 \times T)/100$

$2 = (12.5 T)/100$

$12.5 T = 200$

$T = 200/12.5 = 16$.

**➜ Answer: 16 years**

---
💡 **SHORTCUT**

At **simple** interest the interest earned is a straight line, so the shortcut is just counting:

doubling in $T$ $arrow.r$ tripling in $2T$ $arrow.r$ $m$ times in $(m-1)T$ years.

At **compound** interest it is completely different — see Example 16.

**Example 15** `TCS NQT pattern`

A sum amounts to Rs.~8,820 in 2 years at 5% per year compound interest. Find the sum.

**Solution**

$A = P (1.05)^2$.

$(1.05)^2 = 1.1025$.

$P = 8820/1.1025$.

Multiply top and bottom by 10000: $P = 88200000/11025$.

$11025 \times 8000 = 88200000$, so $P = 8000$.

**Check.** $8000 \times 1.05 = 8400$; $8400 \times 1.05 = 8820$. Correct.

**➜ Answer: Rs.~8,000**

**Example 16** `Accenture pattern`

A sum of money at compound interest becomes 3 times itself in 5 years. In how many years will it become 27 times itself?

**Solution**

**Key idea: at CI the multiplier, not the interest, is what repeats.**

In 5 years the money is multiplied by 3.

In another 5 years it is multiplied by 3 again: $3 \times 3 = 9$ times, at 10 years.

In another 5 years: $9 \times 3 = 27$ times, at 15 years.

Since $27 = 3^3$, we need $3 \times 5 = 15$ years.

**➜ Answer: 15 years**

---
⚠️ **TRAP**

Do not answer $27/3 \times 5 = 45$ years. That is the **simple interest** style of thinking. At CI you ask "how many times do I multiply by 3?" — the answer is 3 times, so 15 years.

**Example 17** `Infosys pattern`

A machine bought for Rs.~64,000 loses 25% of its value every year. Find its value after 3 years. After how many full years does its value first drop below Rs.~20,000?

**Solution**

Each year the machine keeps $100 - 25 = 75$% of its value, so multiply by 0.75.

Year 1: $64000 \times 0.75 = 48000$.

Year 2: $48000 \times 0.75 = 36000$.

Year 3: $36000 \times 0.75 = 27000$.

Year 4: $27000 \times 0.75 = 20250$. Still above 20,000.

Year 5: $20250 \times 0.75 = 15187.50$. Now below 20,000.

**➜ Answer: Rs.~27,000 after 3 years; it first drops below Rs.~20,000 after 5 years**

**Example 18** `Wipro pattern`

The population of a town is 1,25,000 and grows at 6% per year. Find the population after 2 years and the increase over those 2 years.

**Solution**

Year 1: $125000 \times 1.06$.

$125000 \times 0.06 = 7500$, so the population is $125000 + 7500 = 132500$.

Year 2: $132500 \times 1.06$.

$132500 \times 0.06 = 7950$, so the population is $132500 + 7950 = 140450$.

Increase $= 140450 - 125000 = 15450$.

**➜ Answer: 1,40,450; an increase of 15,450**

**Example 19** `Capgemini pattern`

A man borrows Rs.~21,000 at 10% simple interest and repays it in 2 equal annual instalments. Find each instalment.

**Solution**

**Compare everything at the same date — the end of year 2.**

What he owes at the end of year 2:

$"SI" = (21000 \times 10 \times 2)/100 = 4200$.

Amount owed $= 21000 + 4200 = 25200$.

What he pays. Let each instalment be $x$.

The first instalment is paid at the end of year 1, so it sits with the lender for 1 more year and earns 10% simple interest:

value at end of year 2 $= x + (x \times 10 \times 1)/100 = 1.1 x$.

The second instalment is paid at the end of year 2, so its value is just $x$.

Total paid (valued at end of year 2) $= 1.1x + x = 2.1 x$.

Set the two equal:

$2.1 x = 25200$

$x = 25200/2.1 = 252000/21 = 12000$.

**➜ Answer: Rs.~12,000 per instalment**

**Example 20** `Cognizant pattern`

A loan of Rs.~10,500 at 10% per year compound interest is cleared in 2 equal annual instalments. Find each instalment.

**Solution**

Let each instalment be $x$.

At CI we discount each payment back to today:

$ 10500 = x/1.1 + x/1.1^2 = x/1.1 + x/1.21 $

Multiply every term by 1.21 to clear the fractions:

$ 10500 \times 1.21 = 1.1 x + x $

$10500 \times 1.21 = 10500 + 10500 \times 0.21 = 10500 + 2205 = 12705$.

$ 12705 = 2.1 x $

$ x = 12705/2.1 = 127050/21 = 6050 $

**Check.** $6050/1.1 = 5500$ and $6050/1.21 = 5000$. Sum $= 10500$. Correct.

**➜ Answer: Rs.~6,050 per instalment**

#### Practice — Tier 1 — Service *(target: 60 s/Q)*

+ Find the simple interest on Rs.~15,000 at 8% per year for 4 years.
+ Rs.~9,000 gives a simple interest of Rs.~2,700 in 3 years. Find the rate.
+ In how many years does Rs.~7,200 at 6% simple interest give Rs.~1,296 of interest?
+ Find the compound interest on Rs.~16,000 at 15% per year for 2 years.
+ Find the difference between CI and SI on Rs.~45,000 at 4% per year for 2 years.
+ Find the amount on Rs.~20,000 at 10% per year for 1.5 years, compounded half-yearly.
+ A sum doubles itself in 10 years at simple interest. Find the rate.
+ A sum doubles itself in 4 years at compound interest. In how many years will it become 16 times?
+ A sum amounts to Rs.~13,310 in 3 years at 10% compound interest. Find the sum.
+ A machine worth Rs.~50,000 depreciates 20% a year. Find its value after 3 years.
+ A sum at simple interest amounts to Rs.~12,400 in 4 years and Rs.~14,200 in 7 years. Find the sum and the rate.
+ A loan of Rs.~8,400 at 10% simple interest is repaid in 2 equal annual instalments. Find each instalment.
+ Rs.~6,000 is invested for 2 years, once at 10% compound interest and once at 12% simple interest. Which gives more interest, and by how much?
+ A town's population of 80,000 grows 5% a year. Find the population after 2 years.
+ Find the effective annual rate for a nominal 12% per year compounded quarterly.

<details>
<summary><b>Answer key</b></summary>

**1.** Rs.~4,800. $(15000 \times 8 \times 4)/100$.

**2.** 10%. $R = (100 \times 2700)/(9000 \times 3) = 270000/27000$.

**3.** 3 years. $T = (100 \times 1296)/(7200 \times 6) = 129600/43200$.

**4.** Rs.~5,160. $16000 \times 1.15 = 18400$; $18400 \times 1.15 = 21160$; $21160 - 16000$.

**5.** Rs.~72. $45000 \times (0.04)^2 = 45000 \times 0.0016$.

**6.** Rs.~23,152.50. Rate 5%, 3 periods: $21000$, $22050$, $23152.50$.

**7.** 10%. Doubling needs $R T = 100$ with $T = 10$.

**8.** 16 years. $16 = 2^4$, so 4 doubling periods of 4 years each.

**9.** Rs.~10,000. $13310/1.331 = 10000$.

**10.** Rs.~25,600. $50000 \times 0.8 = 40000$; $\times 0.8 = 32000$; $\times 0.8 = 25600$.

**11.** Sum Rs.~10,000, rate 6%. Growth over 3 years $= 1800$, so 1 year $= 600$; 4-year interest $= 2400$; $P = 12400 - 2400$; $R = 600/10000 \times 100$.

**12.** Rs.~4,800. Owed at end of year 2 $= 8400 + 1680 = 10080$; $2.1x = 10080$.

**13.** Simple interest gives more, by Rs.~180. CI $= 6000 \times 1.21 - 6000 = 1260$; SI $= (6000 \times 12 \times 2)/100 = 1440$. At short times a higher simple rate can beat a lower compound rate.

**14.** 88,200. $80000 \times 1.05 = 84000$; $84000 \times 1.05 = 88200$.

**15.** About 12.55%. $(1.03)^4 = 1.12550881$.

## Tier 2 — Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 21** `DBS · pattern`

A fixed deposit of S$40,000 pays 6% per year compounded half-yearly. Find the amount after 2 years and the effective annual rate.

**Solution**

Half-yearly rate $= 6/2 = 3$%. Periods $= 2 \times 2 = 4$.

Period 1: $40000 \times 1.03 = 41200$.

Period 2: $41200 \times 1.03 = 42436$.
(Working: $41200 \times 0.03 = 1236$; $41200 + 1236 = 42436$.)

Period 3: $42436 \times 1.03 = 43709.08$.
(Working: $42436 \times 0.03 = 1273.08$; $42436 + 1273.08 = 43709.08$.)

Period 4: $43709.08 \times 1.03 = 45020.35$.
(Working: $43709.08 \times 0.03 = 1311.27$; $43709.08 + 1311.27 = 45020.35$.)

**Effective annual rate.** One year is two 3% periods:

$(1.03)^2 = 1.0609$, so the EAR is 6.09%.

**➜ Answer: S$45,020.35; effective annual rate 6.09%**

---
💡 **SHORTCUT**

Once you have the EAR you can jump straight to any whole number of years:
$40000 \times (1.0609)^2 = 40000 \times 1.12550881 = 45020.35$. Same answer, two multiplications instead of four.

**Example 22** `Grab · pattern`

A merchant needs THB~2,00,000 for 3 years. Lender A charges 12% per year simple interest. Lender B charges 10% per year compounded annually. Which loan is cheaper, and by how much?

**Solution**

**Lender A (simple).**

$"SI" = (200000 \times 12 \times 3)/100$.

$200000 \times 12 = 2400000$. Then $2400000 \times 3 = 7200000$.

$7200000/100 = 72000$.

**Lender B (compound).**

Year 1: $200000 \times 1.1 = 220000$.

Year 2: $220000 \times 1.1 = 242000$.

Year 3: $242000 \times 1.1 = 266200$.

Interest $= 266200 - 200000 = 66200$.

**Compare.** $72000 - 66200 = 5800$.

**➜ Answer: Lender B is cheaper by THB~5,800**

A lower compound rate can still beat a higher simple rate over a short period. Over a long enough period compounding always wins — but "long enough" here would be well past 3 years.

**Example 23** `Shopee · pattern`

The difference between the compound interest and the simple interest on a sum for 3 years at 10% per year is Rs.~3,100. Find the sum.

**Solution**

$ D = P (R^2 (300+R))/10^6 $

Put $R = 10$:

$R^2 = 100$ and $300 + R = 310$.

$ D = P (100 \times 310)/1000000 = P \times 31000/1000000 = 0.031 P $

$0.031 P = 3100$

$P = 3100/0.031 = 100000$.

**Check.** SI $= (100000 \times 10 \times 3)/100 = 30000$.
CI: $100000 \times 1.331 = 133100$, so CI $= 33100$.
Difference $= 33100 - 30000 = 3100$. Correct.

**➜ Answer: Rs.~1,00,000**

**Example 24** `GIC · pattern`

S$25,000 is invested at 8% per year compounded annually. After 2 years the rate falls to 6% for one more year. Find the amount at the end of year 3.

**Solution**

Year 1: $25000 \times 1.08 = 27000$.

Year 2: $27000 \times 1.08 = 29160$.
(Working: $27000 \times 0.08 = 2160$.)

Year 3 at the new rate: $29160 \times 1.06$.

$29160 \times 0.06 = 1749.60$.

$29160 + 1749.60 = 30909.60$.

**➜ Answer: S$30,909.60**

---
⚠️ **TRAP**

Do not average the rates. $(8 + 8 + 6)/3 = 7.33$% would give $25000 \times (1.0733)^3 = 30910.31$, which is Rs.~0.71 too high. It looks close only because the rates here are close. Rates that change must be applied in order, one factor at a time.

**Example 25** `SCB · pattern`

A loan of Rs.~33,100 at 10% per year compound interest is cleared in 3 equal annual instalments. Find each instalment.

**Solution**

Let each instalment be $x$. Discount all three back to today:

$ 33100 = x/1.1 + x/1.21 + x/1.331 $

Multiply every term by 1.331:

$ 33100 \times 1.331 = 1.21 x + 1.1 x + x $

Left side: $33100 \times 1.331 = 33100 + 33100 \times 0.331$.

$33100 \times 0.331 = 10956.1$.

So the left side $= 33100 + 10956.1 = 44056.1$.

Right side $= 3.31 x$.

$ x = 44056.1/3.31 = 13310 $

**Check.** $13310/1.1 = 12100$; $13310/1.21 = 11000$; $13310/1.331 = 10000$.
Sum $= 12100 + 11000 + 10000 = 33100$. Correct.

**➜ Answer: Rs.~13,310 per instalment**

---
💡 **SHORTCUT**

For $n$ instalments at 10%, multiply the loan by $1.1^n$ and divide by $(1.1^(n-1) + \dots.c + 1.1 + 1)$.

$n = 2$: divide by 2.1. $n = 3$: divide by 3.31. $n = 4$: divide by 4.641.

Those divisors are just $1.1^n$ figures with the decimal shifted — easy to recall.

**Example 26** `Agoda · pattern`

A person takes a "flat rate" loan of Rs.~1,20,000 for 2 years at 12% per year. Under this scheme the total interest is worked out as simple interest on the whole amount, and principal plus interest is split into 24 equal monthly payments. Find the EMI, and estimate the true annual rate the borrower is really paying.

**Solution**

**Step 1 — total interest (flat).**

$"SI" = (120000 \times 12 \times 2)/100$.

$120000 \times 12 = 1440000$. Then $1440000 \times 2 = 2880000$.

$2880000/100 = 28800$.

**Step 2 — EMI.**

Total to repay $= 120000 + 28800 = 148800$.

$"EMI" = 148800/24 = 6200$.

**Step 3 — the true rate.**

The borrower does not owe Rs.~1,20,000 for the whole 2 years. The balance falls in 24 steps to zero, so the average amount outstanding is

$ 120000 \times 25/48 = 62500 $

(The factor is $(n+1)/(2n)$ with $n = 24$ payments, because the balance is still the full 1,20,000 at the start of month 1.)

He pays Rs.~28,800 of interest over 2 years on an average balance of Rs.~62,500:

$ "true rate" \approx 28800/(62500 \times 2) \times 100 = 28800/125000 \times 100 = 23.04 %$

This shortcut always runs a little high; the exact reducing-balance rate here is about 21.6% per year. Either way the message is the same — the loan costs far more than 12%.

**➜ Answer: EMI Rs.~6,200; true rate roughly 23% per year by the quick estimate (about 21.6% exactly) — near enough double the quoted 12%**

---
⚠️ **TRAP**

A "12% flat" loan is **not** a 12% loan. Flat rate charges you interest on the full principal even in the last month, when you owe almost nothing. Always double the flat rate for a rough comparison with a bank's reducing-balance rate.

**Example 27** `LINE MAN · pattern`

An investment grows from THB~50,000 to THB~72,000 in 2 years at compound interest. Find the annual rate. At the same rate, how long from the start until it reaches THB~1,24,416?

**Solution**

**Rate.**

$50000 (1 + R/100)^2 = 72000$

$(1+R/100)^2 = 72000/50000 = 1.44$

$1 + R/100 = sqrt(1.44) = 1.2$

$R = 20$%.

**Time to reach 1,24,416.** Keep multiplying by 1.2.

End of year 1: $50000 \times 1.2 = 60000$.

End of year 2: $60000 \times 1.2 = 72000$.

End of year 3: $72000 \times 1.2 = 86400$.

End of year 4: $86400 \times 1.2 = 103680$.

End of year 5: $103680 \times 1.2 = 124416$.

**➜ Answer: 20% per year; 5 years from the start**

**Example 28** `Razer · pattern`

Rs.~60,000 is split into two parts. One part is lent at 8% simple interest and the other at 10% simple interest, both for 3 years. The total interest is Rs.~15,600. Find the two parts.

**Solution**

Let the part at 8% be $x$. The other part is $60000 - x$.

Interest over 3 years at 8% $= (x \times 8 \times 3)/100 = 0.24 x$.

Interest over 3 years at 10% $= ((60000 - x) \times 10 \times 3)/100 = 0.30(60000 - x)$.

$0.30 \times 60000 = 18000$, so this is $18000 - 0.30 x$.

Total:

$ 0.24 x + 18000 - 0.30 x = 15600 $
$ 18000 - 0.06 x = 15600 $
$ 0.06 x = 2400 $
$ x = 2400/0.06 = 40000 $

Other part $= 60000 - 40000 = 20000$.

**Check.** $40000 \times 0.24 = 9600$ and $20000 \times 0.30 = 6000$. Sum $= 15600$. Correct.

**➜ Answer: Rs.~40,000 at 8% and Rs.~20,000 at 10%**

**Example 29** `Sea · pattern`

A seller's monthly revenue is S$40,000. It rises 25% in month 1, rises another 20% in month 2, then falls 20% in month 3. Find the revenue after month 3 and the overall percentage change.

**Solution**

Treat every change as a multiplying factor.

Month 1: $40000 \times 1.25 = 50000$.

Month 2: $50000 \times 1.20 = 60000$.

Month 3: $60000 \times 0.80 = 48000$.

Overall change $= 48000 - 40000 = 8000$.

Percentage change $= 8000/40000 \times 100 = 0.2 \times 100 = 20$ %.

**➜ Answer: S$48,000; an overall rise of 20%**

---
⚠️ **TRAP**

$+25$, $+20$, $-20$ does **not** add up to $+25$%. The 20% fall is taken on a much bigger base than the 20% rise was, so it wipes out more. Always multiply: $1.25 \times 1.20 \times 0.80 = 1.20$.

**Example 30** `DBS · pattern`

Rs.~1,00,000 is to be invested for 1 year. Scheme A pays 10% compounded annually. Scheme B pays 9.6% compounded quarterly. Which pays more, and by how much?

**Solution**

**Scheme A.**

$100000 \times 1.10 = 110000$.

**Scheme B.**

Quarterly rate $= 9.6/4 = 2.4$%, so the factor is 1.024 and there are 4 periods.

$(1.024)^2 = 1.048576$.
(Working: $1.024 \times 1.024 = 1.024 + 1.024 \times 0.024 = 1.024 + 0.024576$.)

$(1.024)^4 = (1.048576)^2 = 1.09951163$.
(Working: $1.048576 + 1.048576 \times 0.048576 = 1.048576 + 0.050936 = 1.099512$.)

Amount $= 100000 \times 1.09951163 = 109951.16$.

**Compare.** $110000 - 109951.16 = 48.84$.

**➜ Answer: Scheme A pays more, by about Rs.~48.84**

Quarterly compounding lifts 9.6% to an effective 9.951%, still just short of a plain 10%. Frequent compounding helps, but it cannot rescue a rate that is 0.4 points too low.

#### Practice — Tier 2 — Singapore & Thailand *(target: 100 s/Q)*

+ Find the amount on S$60,000 at 8% per year for 1.5 years, compounded half-yearly.
+ Find the difference between CI and SI on Rs.~80,000 at 5% per year for 3 years.
+ A sum amounts to Rs.~17,640 in 2 years at 5% compound interest. Find the sum.
+ A loan of Rs.~21,000 at 10% per year compound interest is cleared in 2 equal annual instalments. Find each instalment.
+ A flat-rate loan of Rs.~90,000 is taken for 3 years at 10% flat, repaid in 36 EMIs. Find the EMI.
+ An investment grows from S$32,000 to S$50,000 in 2 years at compound interest. Find the annual rate.
+ Rs.~50,000 is invested for 2 years. Option 1: 12% simple interest. Option 2: 11% compound interest. Which gives more interest, and by how much?
+ Rs.~90,000 is split, one part at 6% simple interest and the rest at 11% simple interest, both for 2 years. The total interest is Rs.~15,000. Find the two parts.
+ A sum becomes 8 \times itself in 12 years at compound interest. In how many years does it double?
+ A shop's revenue of THB~2,50,000 rises 20%, rises 20% again, then falls 25%. Find the final revenue and the overall percentage change.
+ Find the effective annual rate for a nominal 16% per year compounded quarterly.
+ A machine costing S$80,000 depreciates 15% a year. Find its value after 2 years and the total depreciation.

<details>
<summary><b>Answer key</b></summary>

**1.** S$67,491.84. Rate 4%, 3 periods: $62400$, $64896$, $67491.84$.

**2.** Rs.~610. $D = 80000 times (25 times 305)/10^6 = 80000 times 0.007625$. (Check: SI $=12000$, CI $= 80000 times 1.157625 - 80000 = 12610$.)

**3.** Rs.~16,000. $17640/1.1025 = 16000$.

**4.** Rs.~12,100. $21000 times 1.21 = 25410 = 2.1x$. (Check: $12100/1.1 = 11000$, $12100/1.21 = 10000$, sum 21,000.)

**5.** Rs.~3,250. Interest $= (90000 times 10 times 3)/100 = 27000$; total $= 117000$; $117000/36$.

**6.** 25%. $50000/32000 = 1.5625$ and $sqrt(1.5625) = 1.25$.

**7.** Simple interest gives more, by Rs.~395. SI $= 12000$; CI $= 50000 times 1.2321 - 50000 = 11605$.

**8.** Rs.~48,000 at 6% and Rs.~42,000 at 11%. $0.12x + 0.22(90000-x) = 15000$ gives $19800 - 0.10x = 15000$.

**9.** 4 years. $8 = 2^3$, so 12 years holds three doubling periods.

**10.** THB~2,70,000, a rise of 8%. $1.2 times 1.2 times 0.75 = 1.08$. (Not $20+20-25 = 15$%.)

**11.** About 16.99%. $(1.04)^4 = 1.16985856$.

**12.** S$57,800; depreciation S$22,200. $80000 times 0.85 = 68000$; $68000 times 0.85 = 57800$.

## Tier 3 — Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 31** `Goldman Sachs · pattern`

Prove that for the same principal, rate and a period of 2 years, the difference between compound and simple interest is exactly $P(R/100)^2$. Then use it: the difference is Rs.~96 at 8% for 2 years. Find the principal.

**Solution**

**Insight: the whole gap is one thing — the interest that CI pays on year 1's interest, and SI does not.**

Write $r = R/100$.

**Simple interest over 2 years:**
$ "SI" = 2 P r $

**Compound interest over 2 years:**
$ "CI" = P(1+r)^2 - P = P(1 + 2r + r^2) - P = 2 P r + P r^2 $

**Difference:**
$ D = ("CI") - ("SI") = (2 P r + P r^2) - 2 P r = P r^2 = P (R/100)^2 $

**Read the meaning.** Year 1's interest is $P r$. Under CI that amount itself earns interest for year 2, giving $r \times P r = P r^2$. Under SI it earns nothing. So the gap is exactly $P r^2$ — nothing else differs.

**Now the number.** $R = 8$, so $r = 0.08$ and $r^2 = 0.0064$.

$ 0.0064 P = 96 $
$ P = 96/0.0064 $

Multiply top and bottom by 10000: $P = 960000/64 = 15000$.

**Check.** SI $= (15000 \times 8 \times 2)/100 = 2400$.
CI: $15000 \times (1.08)^2 = 15000 \times 1.1664 = 17496$, so CI $= 2496$.
$2496 - 2400 = 96$. Correct.

**➜ Answer: $D = P(R/100)^2$; the principal is Rs.~15,000**

**Example 32** `D. E. Shaw · pattern`

At 9% per year compound interest, how long does money take to double? Compare your exact answer with the "Rule of 72".

**Solution**

**Insight: at compound interest the doubling time depends only on the rate, not on how much money you start with — because the principal cancels.**

We need the smallest $n$ with $(1.09)^n \\ge 2$.

Build the powers by repeated squaring — far faster than multiplying nine times.

$(1.09)^2 = 1.09 \times 1.09 = 1.09 + 1.09 \times 0.09 = 1.09 + 0.0981 = 1.1881$.

$(1.09)^4 = (1.1881)^2 = 1.1881 + 1.1881 \times 0.1881$.

$1.1881 \times 0.1881 = 0.22348$.

So $(1.09)^4 = 1.41158$.

$(1.09)^8 = (1.41158)^2 = 1.41158 + 1.41158 \times 0.41158$.

$1.41158 \times 0.41158 = 0.58098$.

So $(1.09)^8 = 1.99256$. That is just **under** 2 — eight years is not quite enough.

$(1.09)^9 = 1.99256 \times 1.09 = 1.99256 + 1.99256 \times 0.09 = 1.99256 + 0.17933 = 2.17189$.

So money doubles a little after 8 years; the first **whole** year by which it has doubled is 9.

**Rule of 72:** doubling time $\approx 72/R = 72/9 = 8$ years. The rule gives 8, and the true figure is about 8.04 years — an error of roughly 16 days.

**➜ Answer: Just over 8 years (8 full years leaves you at 1.9926 times; 9 full years gives 2.1719 times). The Rule of 72 estimate of 8 years is accurate here.**

---
💡 **SHORTCUT**

**Rule of 72:** doubling time $\approx 72/R$ years at compound interest. It is very good for rates between about 5% and 12%, and drifts at extreme rates. At 1%: the rule says 72, the truth is 69.7. At 30%: the rule says 2.4, the truth is 2.64.

**Example 33** `Amazon · pattern`

A laptop can be bought two ways. Plan A: pay Rs.~60,000 today. Plan B: pay Rs.~22,000 today, Rs.~22,000 at the end of year 1, and Rs.~22,000 at the end of year 2. Money earns 10% per year compound interest. Which plan costs less, and by how much in today's rupees?

**Solution**

**Insight: Rs.~22,000 paid a year from now costs you less than Rs.~22,000 today, because you could have kept that money earning 10%. Pull every payment back to today before adding.**

**Plan A.** Cost today $= 60000$.

**Plan B.** Discount each payment.

Payment today: $22000$.

Payment after 1 year: $22000/1.1$.

$22000/1.1 = 220000/11 = 20000$.

Payment after 2 years: $22000/1.21$.

$22000/1.21 = 2200000/121 = 18181.82$.
(Working: $121 \times 18181 = 2199901$; the remainder 99 gives $0.818$.)

Total today $= 22000 + 20000 + 18181.82 = 60181.82$.

**Compare.** $60181.82 - 60000 = 181.82$.

Plan A is cheaper by Rs.~181.82 in today's money.

**➜ Answer: Plan A, by about Rs.~181.82 in present-day value**

Note how close it is. At a rate of about 10.36% the two plans would cost the same. The instalment plan looks free, but it is only "free" if the interest rate is high enough — spreading payments is a hidden loan running the other way.

**Example 34** `Google · pattern`

Rs.~1,00,000 is invested for 1 year at a nominal 12% per year. Find the amount when it is compounded yearly, half-yearly, quarterly and monthly. What happens as the compounding gets ever more frequent?

**Solution**

**Insight: more frequent compounding always helps, but each extra split helps less than the one before. The amount converges to a ceiling, it does not grow without limit.**

**Yearly.** $100000 \times 1.12 = 112000$.

**Half-yearly.** Rate 6%, 2 periods.

$(1.06)^2 = 1.06 + 1.06 \times 0.06 = 1.06 + 0.0636 = 1.1236$.

Amount $= 112360$.

**Quarterly.** Rate 3%, 4 periods.

$(1.03)^2 = 1.0609$.

$(1.03)^4 = (1.0609)^2 = 1.0609 + 1.0609 \times 0.0609 = 1.0609 + 0.06461 = 1.12551$.

Amount $= 112550.88$.

**Monthly.** Rate 1%, 12 periods.

$(1.01)^2 = 1.0201$.

$(1.01)^4 = (1.0201)^2 = 1.0201 + 1.0201 \times 0.0201 = 1.0201 + 0.020504 = 1.040604$.

$(1.01)^8 = (1.040604)^2 = 1.040604 + 1.040604 \times 0.040604 = 1.040604 + 0.042253 = 1.082857$.

$(1.01)^12 = (1.01)^8 \times (1.01)^4 = 1.082857 \times 1.040604 = 1.082857 + 1.082857 \times 0.040604 = 1.082857 + 0.043968 = 1.126825$.

Amount $= 112682.50$.

**The pattern.**

#table(columns: 3,
[**Compounding**], [**Amount (Rs.)**], [**Gain over the line above**],
[yearly], [1,12,000.00], [--],
[half-yearly], [1,12,360.00], [360.00],
[quarterly], [1,12,550.88], [190.88],
[monthly], [1,12,682.50], [131.62],
)

Each step gains less than the last: 360, then 191, then 132. The gains are shrinking towards zero.

**The ceiling.** As the number of splits $k$ grows without bound,
$ (1 + 0.12/k)^k arrow.r e^(0.12) = 1.127497 $
so the amount can never exceed about Rs.~1,12,749.69 — daily or even by-the-second compounding at 12% buys you less than Rs.~70 more than monthly.

**➜ Answer: Rs.~1,12,000 / Rs.~1,12,360 / Rs.~1,12,550.88 / Rs.~1,12,682.50; the amount rises with frequency but is capped at about Rs.~1,12,749.69**

**Example 35** `Microsoft · pattern`

Derive the EMI. A loan of Rs.~1,00,000 is taken at 12% per year, charged at 1% per month on the outstanding balance, and repaid in 3 equal monthly instalments. Find the EMI and show the month-by-month balance.

**Solution**

**Insight: an EMI is simply the payment whose present value, discounted at the loan's own rate, equals the loan. Set that equation and solve.**

Let the EMI be $x$ and the monthly factor be $1.01$.

$ 100000 = x/1.01 + x/(1.01)^2 + x/(1.01)^3 $

$(1.01)^2 = 1.0201$ and $(1.01)^3 = 1.0201 \times 1.01 = 1.030301$.

Multiply every term by 1.030301:

$ 100000 \times 1.030301 = x (1.0201 + 1.01 + 1) $

Left side $= 103030.10$.

Right side bracket $= 3.0301$.

$ x = 103030.10/3.0301 $

$3.0301 \times 34000 = 103023.40$.

Remainder $= 103030.10 - 103023.40 = 6.70$.

$6.70/3.0301 = 2.21$.

$ x = 34002.21 $

**Same answer from the standard formula** with $i = 0.01$ and $n = 3$:
$ "EMI" = (P i (1+i)^n)/((1+i)^n - 1) = (100000 \times 0.01 \times 1.030301)/(0.030301) = 1030.301/0.030301 = 34002.21 $

**Month-by-month check.**

#table(columns: 5,
[**Month**], [**Opening**], [**Interest 1%**], [**Principal repaid**], [**Closing**],
[1], [1,00,000.00], [1,000.00], [33,002.21], [66,997.79],
[2], [66,997.79], [669.98], [33,332.23], [33,665.56],
[3], [33,665.56], [336.66], [33,665.55], [0.01],
)

The balance lands on zero (the 1 paisa is rounding). The EMI is correct.

Notice the shape: in month 1 only 97% of the payment goes to principal; by month 3 it is 99%. On a long loan the early EMIs are almost all interest.

**➜ Answer: EMI Rs.~34,002.21**

**Example 36** `Adobe · pattern`

For a certain sum at a certain rate, the compound interest over 2 years is Rs.~2,652 and the simple interest over the same 2 years is Rs.~2,600. Find the rate and the sum.

**Solution**

**Insight: divide the two, not subtract them. The ratio kills the principal and leaves the rate alone.**

Write $r = R/100$.

$ "SI" = 2 P r   "CI" = 2 P r + P r^2 $

$ "CI"/"SI" = (2 P r + P r^2)/(2 P r) = (P r(2 + r))/(2 P r) = (2+r)/2 = 1 + r/2 $

Since $r = R/100$, this is $1 + R/200$.

**Use the numbers.**

$ 2652/2600 = 1 + R/200 $

$2652/2600 = 1.02$.

$ 1.02 = 1 + R/200 $
$ R/200 = 0.02 $
$ R = 4 %$

**Now the sum.** Use SI.

$ 2600 = (P \times 4 \times 2)/100 = (8 P)/100 = 0.08 P $
$ P = 2600/0.08 = 32500 $

**Check.** $32500 \times 1.04 = 33800$; $33800 \times 1.04 = 35152$.
CI $= 35152 - 32500 = 2652$. Correct.
SI $= 32500 \times 0.08 = 2600$. Correct.

**➜ Answer: Rate 4% per year; sum Rs.~32,500**

---
💡 **SHORTCUT**

Memorise the one-liner for 2 years: $ "CI"/"SI" = 1 + R/200 $
So at 10%, CI is exactly 1.05 times SI. At 8%, exactly 1.04 times. It turns a two-unknown problem into a single division.

**Example 37** `Uber · pattern`

A driver takes a flat-rate loan of Rs.~60,000 for 1 year at 10% flat, repaid in 12 EMIs. Find the EMI. Then show that the true monthly rate he is paying is close to 1.5%, and state the true annual rate.

**Solution**

**Insight: a flat loan charges interest on the full Rs.~60,000 for all 12 months, but the borrower's average balance over the year is only about half of that. Halving the balance roughly doubles the effective rate.**

**Step 1 — EMI.**

Flat interest $= (60000 \times 10 \times 1)/100 = 6000$.

Total repaid $= 60000 + 6000 = 66000$.

$"EMI" = 66000/12 = 5500$.

**Step 2 — a quick estimate of the true rate.**

The balance falls roughly in a straight line from 60,000 to 0, so the average outstanding balance is about
$ 60000 \times 13/24 = 32500 $
(The factor $13/24$, not $1/2$, because there are 12 payments and the balance is still 60,000 at the start of month 1.)

$ "true annual rate" \approx 6000/32500 \times 100 = 18.46 %$

**Step 3 — check it properly.** The true monthly rate $i$ satisfies
$ 60000 = 5500 \times (1 - (1+i)^(-12))/i $

Try $i = 0.015$ (1.5% per month).

$(1.015)^2 = 1.030225$.

$(1.015)^4 = (1.030225)^2 = 1.030225 + 1.030225 \times 0.030225 = 1.030225 + 0.031139 = 1.061364$.

$(1.015)^8 = (1.061364)^2 = 1.061364 + 1.061364 \times 0.061364 = 1.061364 + 0.065130 = 1.126494$.

$(1.015)^12 = 1.126494 \times 1.061364 = 1.126494 + 1.126494 \times 0.061364 = 1.126494 + 0.069125 = 1.195619$.

$1/1.195619 = 0.836388$.

$1 - 0.836388 = 0.163612$.

$0.163612/0.015 = 10.9075$.

$5500 \times 10.9075 = 59991$.

That is Rs.~9 short of Rs.~60,000, so the true rate is a hair **below** 1.5% per month — about 1.4977%.

**Annual figures.**

Nominal annual rate $= 12 \times 1.4977 \approx 17.97$ %, call it 18%.

Effective annual rate $= (1.015)^12 - 1 \approx 0.1956$, i.e. about 19.6%.

**➜ Answer: EMI Rs.~5,500; true rate about 1.5% per month, i.e. about 18% per year nominal — roughly 1.8 times the quoted 10% flat**

---
⚠️ **TRAP**

Flat rate, "add-on" rate and "reducing balance" rate are three different things. Comparing a 10% flat loan with a 14% bank loan and picking the flat one is a classic and expensive error: the flat loan really costs about 18%.

**Example 38** `Goldman Sachs · pattern`

An investment returns 12% a year for 3 years. Inflation runs at 5% a year over the same period. Find the real growth of the money over the 3 years, and the real rate per year.

**Solution**

**Insight: a nominal return and inflation are both multipliers acting on the same money. The real result is their ratio, never their difference.**

**Nominal factor over 3 years.**

$(1.12)^2 = 1.12 + 1.12 \times 0.12 = 1.12 + 0.1344 = 1.2544$.

$(1.12)^3 = 1.2544 \times 1.12 = 1.2544 + 1.2544 \times 0.12 = 1.2544 + 0.150528 = 1.404928$.

**Inflation factor over 3 years.**

$(1.05)^2 = 1.1025$.

$(1.05)^3 = 1.1025 \times 1.05 = 1.1025 + 0.055125 = 1.157625$.

**Real factor.**

$ "real factor" = 1.404928/1.157625 $

$1.157625 \times 1.21 = 1.157625 + 1.157625 \times 0.21 = 1.157625 + 0.243101 = 1.400726$.

Remainder $= 1.404928 - 1.400726 = 0.004202$.

$0.004202/1.157625 = 0.00363$.

$ "real factor" = 1.21363 $

So the real growth over 3 years is about **21.36%**.

**Real rate per year.**

$ (1.12)/(1.05) = 1.0666667 $

so the real rate is $6.6667$%, i.e. $6 2/3$% per year.

**Check:** $(1.0666667)^2 = 1.137778$ and $1.137778 \times 1.0666667 = 1.213630$. Matches.

**The wrong method, for contrast.** Subtracting gives $12 - 5 = 7$% a year, and $(1.07)^3 = 1.225043$, i.e. 22.5% — an overstatement of more than a full percentage point over 3 years.

**➜ Answer: Real growth about 21.36% over 3 years; real rate $6 2/3$% per year**

#### Practice — Tier 3 — Product *(target: 4 min/Q)*

+ The difference between CI and SI on a sum for 2 years at 6% per year is Rs.~180. Find the sum.
+ Use the Rule of 72 to estimate the doubling time at 6% compound interest, then check whether 12 years is actually enough by computing $(1.06)^12$.
+ Plan A: pay Rs.~45,000 today. Plan B: pay Rs.~16,000 today and Rs.~16,000 at the end of each of the next 2 years. Money earns 10% per year. Which plan is cheaper in today's money, and by how much?
+ Rs.~2,00,000 is invested for 1 year at a nominal 8% per year. Find the amount when compounded yearly, half-yearly and quarterly.
+ A loan of Rs.~50,000 at 1% per month on the reducing balance is repaid in 3 equal monthly instalments. Find the EMI.
+ For a certain sum and rate, the CI for 2 years is Rs.~1,640 and the SI for 2 years is Rs.~1,600. Find the rate and the sum.
+ A flat-rate loan of Rs.~1,20,000 is taken for 2 years at 9% flat, repaid in 24 EMIs. Find the EMI and estimate the true annual rate.
+ An investment returns 15% a year for 2 years while inflation runs at 6% a year. Find the real growth over the 2 years and the real rate per year.

<details>
<summary><b>Answer key</b></summary>

**1.** Rs.~50,000. $D = P(0.06)^2 = 0.0036P = 180$. The gap is just the interest earned on year 1's interest, so it is tiny compared with the interest itself (SI here is Rs.~6,000).

**2.** The rule says $72/6 = 12$ years, and 12 years is indeed enough. Squaring up: $(1.06)^2 = 1.1236$; $(1.06)^4 = 1.26247696$; $(1.06)^8 = 1.593848$; $(1.06)^12 = 1.593848 \times 1.26247696 = 2.012196$. Since that exceeds 2, the money has just passed double at 12 years.

**3.** Plan B is cheaper by about Rs.~1,231. $"PV"("B") = 16000 + 16000/1.1 + 16000/1.21 = 16000 + 14545.45 + 13223.14 = 43768.59$, against Plan A's 45,000. Unlike Example 33 the down payment here is a much smaller share of the total, so more of the cost is pushed into the future and discounting bites harder.

**4.** Yearly Rs.~2,16,000; half-yearly Rs.~2,16,320 (rate 4%, $(1.04)^2 = 1.0816$); quarterly Rs.~2,16,486.43 (rate 2%, $(1.02)^4 = 1.08243216$). The steps shrink: +320, then +166.43.

**5.** Rs.~17,001.11. $50000 \times 1.030301 = 51515.05$, and dividing by $(1.0201 + 1.01 + 1) = 3.0301$ gives 17,001.11 — exactly half the answer in Example 35, because the EMI is proportional to the loan.

**6.** Rate 5%, sum Rs.~16,000. $"CI"/"SI" = 1640/1600 = 1.025 = 1 + R/200$, so $R = 5$. Then SI $= 0.10 P = 1600$. (Check: $16000 \times 1.1025 = 17640$, so CI $= 1640$.)

**7.** EMI Rs.~5,900; true rate about 17.3% per year. Flat interest $= (120000 \times 9 \times 2)/100 = 21600$; total $= 141600$; $141600/24 = 5900$. Average balance $\approx 120000 \times 25/48 = 62500$, so the true rate $\approx 21600/(62500 \times 2) \times 100 = 17.28$% — close to double the quoted 9%.

**8.** Real growth about 17.70% over 2 years; real rate about 8.49% per year. Nominal $(1.15)^2 = 1.3225$; inflation $(1.06)^2 = 1.1236$; ratio $= 1.3225/1.1236 = 1.17702$. Per year $1.15/1.06 = 1.084906$. Subtracting would have given 9% a year, which overstates it.

## Mixed set — exam conditions

#### Practice — Tier 1 — Service *(target: 30 minutes for all 20)*

+ Find the simple interest on Rs.~18,000 at 7% per year for 5 years.
+ Find the compound interest on Rs.~8,000 at 25% per year for 2 years.
+ A sum doubles in 6 years at simple interest. In how many years will it triple?
+ Find the difference between CI and SI on Rs.~25,000 at 8% per year for 2 years.
+ Find the compound interest on Rs.~30,000 at 20% per year for 1 year, compounded half-yearly.
+ A sum amounts to Rs.~9,261 in 3 years at 5% compound interest. Find the sum.
+ A loan of Rs.~16,800 at 10% compound interest is cleared in 2 equal annual instalments. Find each instalment.
+ A machine worth Rs.~1,00,000 depreciates 10% a year. Find its value after 3 years.
+ A sum at simple interest amounts to Rs.~11,500 in 3 years and Rs.~12,500 in 5 years. Find the sum and the rate.
+ A flat-rate loan of Rs.~72,000 for 2 years at 11% flat is repaid in 24 EMIs. Find the EMI.
+ A sum becomes 4 times itself in 6 years at compound interest. In how many years will it become 64 times?
+ A town's population of 40,000 falls 5% a year. Find the population after 2 years.
+ Rs.~50,000 is split, one part at 9% simple interest and the rest at 12% simple interest, both for 2 years. The total interest is Rs.~10,200. Find the two parts.
+ Find the effective annual rate for a nominal 10% per year compounded half-yearly.
+ Find the difference between CI and SI on Rs.~10,000 at 20% per year for 3 years.
+ Which costs less today: paying Rs.~33,000 now, or paying Rs.~12,000 now and Rs.~12,000 at the end of each of the next 2 years, when money earns 10% per year?
+ An investment returns 10% in a year while inflation is 4%. Find the real rate of return for that year.
+ Find the compound interest on Rs.~64,000 at 12.5% per year for 3 years.
+ For how long must Rs.~15,000 be lent at 8% simple interest to earn Rs.~4,800?
+ Rs.~1,00,000 is invested for 2 years, once at 10% compound interest and once at 10.5% simple interest. Compare the interest earned.

<details>
<summary><b>Answer key</b></summary>

**1.** Rs.~6,300. $(18000 \times 7 \times 5)/100$.

**2.** Rs.~4,500. $8000 \times 1.25 = 10000$; $\times 1.25 = 12500$; minus 8,000.

**3.** 12 years. At SI, doubling in $T$ means tripling in $2T$. (Rate $= 100/6 = 16 2/3$%.)

**4.** Rs.~160. $25000 \times (0.08)^2 = 25000 \times 0.0064$.

**5.** Rs.~6,300. Half-yearly rate 10%, 2 periods: $33000$, then $36300$; $36300 - 30000$.

**6.** Rs.~8,000. $9261/1.157625 = 8000$. (Check: $8000 arrow.r 8400 arrow.r 8820 arrow.r 9261$.)

**7.** Rs.~9,680. $16800 \times 1.21 = 20328$ and $20328/2.1 = 9680$. (Check: $9680/1.1 = 8800$, $9680/1.21 = 8000$, sum 16,800.)

**8.** Rs.~72,900. $100000 \times 0.9 = 90000$; $\times 0.9 = 81000$; $\times 0.9 = 72900$.

**9.** Sum Rs.~10,000, rate 5%. Two years of growth $= 1000$, so 1 year $= 500$; 3-year interest $= 1500$; $P = 11500 - 1500$.

**10.** Rs.~3,660. Interest $= (72000 \times 11 \times 2)/100 = 15840$; total $= 87840$; $87840/24$.

**11.** 18 years. $64 = 4^3$, so three blocks of 6 years. (Answering $64/4 \times 6 = 96$ is the SI-style trap.)

**12.** 36,100. $40000 \times 0.95 = 38000$; $38000 \times 0.95 = 36100$.

**13.** Rs.~30,000 at 9% and Rs.~20,000 at 12%. $0.18x + 0.24(50000-x) = 10200$ gives $12000 - 0.06x = 10200$.

**14.** 10.25%. $(1.05)^2 = 1.1025$.

**15.** Rs.~1,280. $D = P (R^2(300+R))/10^6 = 10000 \times (400 \times 320)/10^6 = 10000 \times 0.128$. (Check: SI $= 6000$; CI $= 10000 \times 1.728 - 10000 = 7280$.)

**16.** The instalment plan is cheaper, by about Rs.~173.55. $"PV" = 12000 + 12000/1.1 + 12000/1.21 = 12000 + 10909.09 + 9917.36 = 32826.45$.

**17.** About 5.77%. $1.10/1.04 = 1.057692$. Subtracting would give 6%, which is too high.

**18.** Rs.~27,125. Factor 1.125: $64000 arrow.r 72000 arrow.r 81000 arrow.r 91125$; $91125 - 64000$.

**19.** 4 years. $T = (100 \times 4800)/(15000 \times 8) = 480000/120000$.

**20.** They are exactly equal — Rs.~21,000 each. CI $= 100000 \times 1.21 - 100000 = 21000$; SI $= (100000 \times 10.5 \times 2)/100 = 21000$. This is the rule $"CI"/"SI" = 1 + R/200$ in action: at 10% over 2 years, CI equals SI at 10.5%.

## 📋 One-page revision card

**The two engines**

- **Simple interest adds the same slab every year.** Interest never earns interest.
- **Compound interest multiplies by the same factor every year.** Interest earns interest.

**Core formulas**

$ "SI" = (P R T)/100   A = P(1 + (R T)/100) $

$ A = P(1 + R/100)^n   "CI" = P[(1+R/100)^n - 1] $

**Compounding frequency**

half-yearly: rate $R/2$, periods $2n$   quarterly: rate $R/4$, periods $4n$   monthly: rate $R/12$, periods $12n$

$k$ compoundings a year: $"EAR" = [(1 + R/(100k))^k - 1] \times 100$ per cent.

**Shortcuts worth memorising**

$ "2 yr gap:" D = P (R/100)^2   "3 yr gap:" D = P (R^2 (300+R))/10^6   "2 yr ratio:" "CI"/"SI" = 1 + R/200 $
- SI doubling: $R T = 100$. Double in $T$ $arrow.r$ triple in $2T$ $arrow.r$ $m$ times in $(m-1)T$.
- CI multiplying: $m$ times in $T$ $arrow.r$ $m^2$ times in $2T$ $arrow.r$ $m^3$ times in $3T$.
- Rule of 72: doubling time $\approx 72/R$ years.
- $n$ instalments at 10%: multiply the loan by $1.1^n$, then divide by 2.1, 3.31 or 4.641 for $n = 2, 3, 4$.
- EMI $= (P i (1+i)^n)/((1+i)^n - 1)$, with $i = R/1200$.
- Flat rate $arrow.r$ true reducing-balance rate is roughly **double**.
- Real return: divide $(1+R/100)$ by $(1+f/100)$; never subtract.

**Powers to know cold**

#table(columns: 5,
[$1.05^2 = 1.1025$], [$1.05^3 = 1.157625$], [$1.1^2 = 1.21$], [$1.1^3 = 1.331$], [$1.1^4 = 1.4641$],
[$1.2^2 = 1.44$], [$1.2^3 = 1.728$], [$1.25^2 = 1.5625$], [$1.25^3 = 1.953125$], [$1.15^2 = 1.3225$],
)

**The top 5 traps**

+ **Months divided by 10.** "2 years 8 months" is $8/3$ years, not 2.8 years.
+ **Half-yearly done halfway.** Halve the rate **and** double the periods. Doing only one of the two is the single most common slip in this chapter.
+ **SI thinking applied to CI multiples.** At CI, "3 times in 5 years" gives 27 times in 15 years — not 45. Count the multiplications, do not scale the time.
+ **Flat rate read as a real rate.** A 10% flat loan really costs about 18%. Always double it before comparing.
+ **Subtracting inflation.** A 12% return with 5% inflation is $1.12/1.05 = 6 2/3$% real, not 7%. Ratios, not differences.

</details>

</details>

</details>

</details>
