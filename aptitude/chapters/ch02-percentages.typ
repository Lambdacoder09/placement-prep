#import "../lib/style.typ": *

#chapter(num: 2, title: "Percentages", tagline: "Multipliers, successive change, growth, error, savings")[

#section[What you need to know]

#formulas[

*The basics.*
- $x% = x/100$. "Percent" means "out of 100".
- $x%$ of $N = (x/100) times N$
- $A$ as a percent of $B = (A/B) times 100 %$
- Percentage change $= ("new" - "old")/"old" times 100 %$. The *old* value is always the base.

*The multiplier method — use this for everything.*
- Increase by $x% arrow.r$ multiply by $(1 + x/100)$
- Decrease by $x% arrow.r$ multiply by $(1 - x/100)$
- Two changes in a row $arrow.r$ multiply the two multipliers. Order does not matter.
- Net percent of $+a%$ then $+b%$ $= a + b + (a b)/100$ (use a negative sign for a fall)

*Must-know conversions.*
#table(columns: 8,
  [$1/2$], [$1/3$], [$1/4$], [$1/5$], [$1/6$], [$1/7$], [$1/8$], [$1/9$],
  [50%], [$33 1/3 %$], [25%], [20%], [$16 2/3 %$], [$14 2/7 %$], [12.5%], [$11 1/9 %$],
)
#table(columns: 8,
  [$1/10$], [$1/11$], [$1/12$], [$1/15$], [$1/16$], [$1/20$], [$1/25$], [$1/40$],
  [10%], [$9 1/11 %$], [$8 1/3 %$], [$6 2/3 %$], [6.25%], [5%], [4%], [2.5%],
)
Also: $2/3 = 66 2/3 %$, $3/4 = 75%$, $3/8 = 37.5%$, $5/8 = 62.5%$, $7/8 = 87.5%$, $3/5 = 60%$.

*The two "reverse" rules.* (Both come from a change of base.)
- If $A$ is $x%$ *more* than $B$, then $B$ is $(100 x)/(100 + x) %$ *less* than $A$.
- If $A$ is $x%$ *less* than $B$, then $B$ is $(100 x)/(100 - x) %$ *more* than $A$.

*Product constancy.* If price $times$ quantity must stay fixed and price rises $x%$, quantity must fall by $(100 x)/(100 + x) %$. If price falls $x%$, quantity may rise by $(100 x)/(100 - x) %$.

*Growth and depreciation.*
- After $n$ years at $r%$ growth per year: $P (1 + r/100)^n$
- After $n$ years at $r%$ depreciation per year: $P (1 - r/100)^n$
- Different rates each year: multiply the separate multipliers.

*Percentage error.*
$"% error" = (|"wrong value" - "correct value"|)/("correct value") times 100 %$
- If a measured length is $x%$ too large, the area is $((1+x/100)^2 - 1) times 100 %$ too large, and the volume is $((1+x/100)^3 - 1) times 100 %$ too large.

*Income, expenditure, savings.*
- Savings $=$ Income $-$ Expenditure
- If expenditure is $e%$ of income, savings are $(100 - e)%$ of income.
- Work with income $= 100$. It removes all the fractions.

*Mixing two groups (weighted percent).* If a fraction $w$ of a total changes by $a%$ and the rest $(1-w)$ changes by $b%$, the whole changes by $w a + (1-w) b$ percent.

*Two-set percentages.* $n(A "or" B) = n(A) + n(B) - n(A "and" B)$, and (neither) $= 100% - n(A "or" B)$.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[Find 35% of 640.
#sol[
$35% = 35/100$.
$640 times 35/100 = (640 times 35)/100$.
$640 times 35 = 640 times 30 + 640 times 5 = 19200 + 3200 = 22400$.
$22400 div 100 = 224$.
]
#ans[224]
]

#ex(2, tier: 0)[45 is what percent of 180?
#sol[
$(45/180) times 100$.
$45/180 = 1/4$.
$1/4 times 100 = 25$.
]
#ans[25%]
]

#ex(3, tier: 0)[Write $5/8$ as a percent.
#sol[
$5/8 times 100 = 500/8 = 62.5$.
]
#ans[62.5%]
]

#ex(4, tier: 0)[Increase 250 by 12%.
#sol[
Multiplier $= 1 + 12/100 = 1.12$.
$250 times 1.12 = 250 + 250 times 0.12 = 250 + 30 = 280$.
]
#ans[280]
]

#ex(5, tier: 0)[Decrease 480 by 15%.
#sol[
15% of $480 = 480 times 15/100 = (480 times 15)/100 = 7200/100 = 72$.
$480 - 72 = 408$.
]
#ans[408]
]

#ex(6, tier: 0)[60 is what percent more than 48?
#sol[
Rise $= 60 - 48 = 12$.
Base is the *old* number, 48.
$(12/48) times 100 = (1/4) times 100 = 25$.
]
#ans[25%]
]

#ex(7, tier: 0)[If 20% of a number is 70, find the number.
#sol[
Let the number be $N$.
$0.20 N = 70$
$N = 70/0.20 = 700/2 = 350$.
Check: 20% of $350 = 70$. Correct.
]
#ans[350]
]

#ex(8, tier: 0)[A quantity of 100 is increased by 10%, then the result is increased by 20%. Find the final value.
#sol[
After the first rise: $100 times 1.10 = 110$.
After the second rise: $110 times 1.20 = 132$.
]
#ans[132]
]

#section[Tier 1 — Service companies]
#tier-header(1)

#ex(9, tier: 1, asked: "TCS NQT pattern")[In an exam a student scores 36% of the total marks and fails by 24 marks. The pass mark is 40% of the total. Find the total marks.
#sol[
The gap between the pass mark and the score is 24 marks.
In percent, that gap is $40% - 36% = 4%$ of the total.
So 4% of total $= 24$.
$1%$ of total $= 24/4 = 6$.
$100%$ of total $= 6 times 100 = 600$.
Check: 36% of $600 = 216$; 40% of $600 = 240$; $240 - 216 = 24$. Correct.
]
#ans[600 marks]
]

#trap[
"Fails by 24 marks" means score $+ 24 =$ pass mark. It does *not* mean the student scored 24 marks, and it does not mean 24% of the paper. Always turn the sentence into an equation before touching numbers.
]

#ex(10, tier: 1, asked: "Infosys pattern")[A salary is increased by 20% and then decreased by 20%. What is the net percent change?
#sol[
Use multipliers. Start with 100.
Rise: $times 1.20 arrow.r 100 times 1.20 = 120$.
Fall: $times 0.80 arrow.r 120 times 0.80 = 96$.
Change $= 96 - 100 = -4$.
Percent change $= (-4)/100 times 100 = -4%$.
]
#ans[4% decrease]
]

#trick[
Up $x%$ then down $x%$ is *always* a fall of $x^2/100$ percent. Here $20^2/100 = 4%$. For 10% it is 1%; for 30% it is 9%; for 50% it is 25%. It never returns to the start.
]

#ex(11, tier: 1, asked: "Accenture pattern")[The price of rice rises by 25%. By what percent must a family cut its consumption so that the money spent on rice stays the same?
#sol[
Spending $=$ price $times$ consumption, and spending must not change.
Take price $= 100$ and consumption $= 100$, so spending $= 10000$.
New price $= 125$.
New consumption $= 10000 div 125 = 80$.
Drop $= 100 - 80 = 20$.
Percent drop $= (20/100) times 100 = 20%$.
Formula check: $(100 times 25)/(100+25) = 2500/125 = 20$. Same.
]
#ans[20%]
]

#ex(12, tier: 1, asked: "Wipro pattern")[A's income is 25% more than B's income. B's income is what percent less than A's?
#sol[
Let B $= 100$.
A $= 100 + 25 = 125$.
B is less than A by $125 - 100 = 25$.
Now the base is *A*, not B.
$(25/125) times 100 = 2500/125 = 20$.
]
#ans[20%]
]

#trap[
The base changes when you flip the comparison. "A is 25% more than B" and "B is 25% less than A" are *not* the same statement. The first uses B as base, the second uses A.
]

#ex(13, tier: 1, asked: "Capgemini pattern")[The population of a town is 50,000 and grows by 10% every year. Find the population after 3 years.
#sol[
Multiplier per year $= 1.10$.
Year 1: $50000 times 1.10 = 55000$.
Year 2: $55000 times 1.10 = 60500$.
Year 3: $60500 times 1.10 = 66550$.
One-shot check: $50000 times (1.1)^3 = 50000 times 1.331 = 66550$.
]
#ans[66,550]
]

#ex(14, tier: 1, asked: "Cognizant pattern")[A machine costs Rs.~80,000 and loses 15% of its value each year. Find its value after 2 years.
#sol[
Multiplier per year $= 1 - 0.15 = 0.85$.
Year 1: $80000 times 0.85$.
$80000 times 0.85 = 80000 - 80000 times 0.15 = 80000 - 12000 = 68000$.
Year 2: $68000 times 0.85 = 68000 - 68000 times 0.15 = 68000 - 10200 = 57800$.
]
#ans[Rs.~57,800]
]

#ex(15, tier: 1, asked: "TCS NQT pattern")[In a town, 60% of the people are men. 40% of the men and 25% of the women can read. What percent of the whole town can read?
#sol[
Take the town as 100 people.
Men $= 60$. Women $= 100 - 60 = 40$.
Men who can read $= 40%$ of $60 = 0.40 times 60 = 24$.
Women who can read $= 25%$ of $40 = 0.25 times 40 = 10$.
Total who can read $= 24 + 10 = 34$.
Out of 100 people, so $34%$.
]
#ans[34%]
]

#trick[
For "percent of a percent" questions, set the total to 100. Every answer then falls out as a plain count, and the final count *is* the percent. No fractions, no decimals.
]

#ex(16, tier: 1, asked: "Infosys pattern")[A man spends 75% of his income. Next year his income rises by 20% and his spending rises by 10%. By what percent do his savings rise?
#sol[
Take income $= 100$.
Expenditure $= 75$. Savings $= 100 - 75 = 25$.
New income $= 100 times 1.20 = 120$.
New expenditure $= 75 times 1.10 = 82.5$.
New savings $= 120 - 82.5 = 37.5$.
Rise in savings $= 37.5 - 25 = 12.5$.
Percent rise $= (12.5/25) times 100 = 50$.
]
#ans[50%]
]

#ex(17, tier: 1, asked: "Wipro pattern")[In an election between two candidates, the winner got 55% of the valid votes and won by 1,200 votes. Find the number of valid votes.
#sol[
Winner $= 55%$. Only two candidates, so loser $= 100% - 55% = 45%$.
Margin in percent $= 55% - 45% = 10%$.
So 10% of valid votes $= 1200$.
$1%$ of valid votes $= 1200/10 = 120$.
$100%$ of valid votes $= 120 times 100 = 12000$.
Check: winner $= 6600$, loser $= 5400$, margin $= 1200$. Correct.
]
#ans[12,000 valid votes]
]

#ex(18, tier: 1, asked: "Accenture pattern")[A student had to multiply a number by $5/3$, but multiplied it by $3/5$ instead. Find the percentage error.
#sol[
Pick a convenient number. Take 15 (it divides by both 3 and 5).
Correct answer $= 15 times 5/3 = 25$.
Wrong answer $= 15 times 3/5 = 9$.
Error $= 25 - 9 = 16$.
Percentage error $= (16/25) times 100 = 1600/25 = 64$.
]
#ans[64%]
]

#trap[
Percentage error is always divided by the *correct* value, not the wrong one. Dividing by 9 here gives about 178%, which is a different (and wrong) quantity.
]

#ex(19, tier: 1, asked: "TCS NQT pattern")[The price of a product is cut by 20%. By what percent must the new price be raised to bring it back to the original?
#sol[
Take the original price $= 100$.
New price $= 100 - 20 = 80$.
To get back to 100 we must add $100 - 80 = 20$.
Base is now the *new* price, 80.
$(20/80) times 100 = 2000/80 = 25$.
]
#ans[25%]
]

#ex(20, tier: 1, asked: "Capgemini pattern")[In a class of 400 students, 45% are girls. 20% of the girls and 10% of the boys wear glasses. How many students wear glasses?
#sol[
Girls $= 45%$ of $400 = 0.45 times 400 = 180$.
Boys $= 400 - 180 = 220$.
Girls with glasses $= 20%$ of $180 = 0.20 times 180 = 36$.
Boys with glasses $= 10%$ of $220 = 0.10 times 220 = 22$.
Total $= 36 + 22 = 58$.
]
#ans[58 students]
]

#practice(tier: 1, time: "60 s/Q")[
+ Find 18% of 2,500.
+ If 15% of a number is 54, find the number.
+ 84 is what percent of 350?
+ A number increased by 25% becomes 375. Find the original number.
+ A quantity rises by 20% and then by 25%. Find the net percent rise.
+ A salary is cut by 10% and then raised by 10%. Find the net percent change.
+ If A is 40% less than B, then B is what percent more than A?
+ A town's population is 25,000 and falls by 4% each year. Find the population after 2 years.
+ A student scores 30% and fails by 45 marks. The pass mark is 45%. Find the total marks.
+ A man spends 80% of his income. His income rises 25% and his spending rises 20%. Find the percent rise in savings.
+ Write $7/16$ as a percent.
+ In an election with two candidates, the loser got 42% of the votes and lost by 4,800 votes. Find the total number of votes.
+ The price of sugar rises by 20%. By what percent must consumption fall so that spending is unchanged?
  #opts([$16 2/3 %$], [20%], [25%], [$83 1/3 %$])
+ If 30% of A equals 45% of B, find $A : B$.
+ The price of a phone falls from Rs.~24,000 to Rs.~19,200. Find the percent fall.
]

#key[
+ *450.* $2500 times 18/100 = 25 times 18 = 450$.
+ *360.* $0.15 N = 54 arrow.r N = 54/0.15 = 360$.
+ *24%.* $(84/350) times 100 = 0.24 times 100 = 24$.
+ *300.* $1.25 N = 375 arrow.r N = 375/1.25 = 300$.
+ *50%.* $1.20 times 1.25 = 1.50$. Or $20 + 25 + (20 times 25)/100 = 45 + 5 = 50$.
+ *1% decrease.* $0.90 times 1.10 = 0.99$. Same as the $x^2/100$ rule with $x = 10$.
+ *$66 2/3 %$.* A $= 60$ when B $= 100$; B exceeds A by 40, and $(40/60) times 100 = 66 2/3$.
+ *23,040.* $25000 times 0.96 = 24000$; $24000 times 0.96 = 23040$.
+ *300.* Gap $= 45% - 30% = 15%$, so $15%$ of total $= 45$ and total $= 45 times 100/15 = 300$.
+ *45%.* Income 100, spend 80, save 20. New: income 125, spend 96, save 29. Rise $= 9/20 = 45%$.
+ *43.75%.* $7/16 times 100 = 700/16 = 43.75$.
+ *30,000.* Winner $= 58%$, margin $= 58 - 42 = 16%$, so $16%$ of total $= 4800$ and total $= 30000$.
+ *(a) $16 2/3 %$.* $(100 times 20)/(100 + 20) = 2000/120 = 16 2/3$. Choosing (b) 20% means you used the same 20% for the cut, forgetting the base changed. Choosing (c) 25% means you divided by $100 - 20$ instead of $100 + 20$. Choosing (d) $83 1/3 %$ gives the consumption that is *left*, not the size of the cut.
+ *$3 : 2$.* $0.30 A = 0.45 B arrow.r A/B = 0.45/0.30 = 3/2$.
+ *20%.* Fall $= 24000 - 19200 = 4800$, and $(4800/24000) times 100 = 20$. The base is the *old* price.
]

#section[Tier 2 — Singapore & Thailand]
#tier-header(2)

#ex(21, tier: 2, asked: "Grab · pattern")[A ride has a base fare of S\$12.00. A surge raises the fare by 35%. A promo code then takes 20% off the surged fare. Find the amount paid and the net percent change from the base fare.
#sol[
Surged fare $= 12 times 1.35$.
$12 times 1.35 = 12 + 12 times 0.35 = 12 + 4.20 = 16.20$.
After the promo $= 16.20 times 0.80$.
$16.20 times 0.80 = 16.20 - 16.20 times 0.20 = 16.20 - 3.24 = 12.96$.
Net multiplier $= 1.35 times 0.80 = 1.08$.
Net change $= 1.08 - 1 = 0.08 arrow.r +8%$.
Check: $12 times 1.08 = 12.96$. Matches.
]
#ans[S\$12.96, a rise of 8%]
]

#trick[
Never carry the middle number. Multiply the multipliers first: $1.35 times 0.80 = 1.08$. One multiplication instead of two, and no rounding builds up.
]

#ex(22, tier: 2, asked: "Shopee · pattern")[A seller lists an item at THB~2,500. Before a festival she raises the price by 12%, then during the festival she cuts the new price by 12%. Find the final price and the net percent change.
#sol[
Net multiplier $= 1.12 times 0.88$.
$1.12 times 0.88 = 1.12 - 1.12 times 0.12 = 1.12 - 0.1344 = 0.9856$.
Final price $= 2500 times 0.9856$.
$2500 times 0.9856 = 2500 - 2500 times 0.0144 = 2500 - 36 = 2464$.
Net change $= 0.9856 - 1 = -0.0144 arrow.r -1.44%$.
Shortcut check: $x^2/100 = 12^2/100 = 144/100 = 1.44%$ fall. Matches.
]
#ans[THB~2,464; a fall of 1.44%]
]

#ex(23, tier: 2, asked: "DBS · pattern")[A bank's loan book grew 8% in year 1, shrank 5% in year 2, and grew 12% in year 3. Find the net percent change over the three years.
#sol[
Multiply the three multipliers.
$1.08 times 0.95$:
$1.08 times 0.95 = 1.08 - 1.08 times 0.05 = 1.08 - 0.054 = 1.026$.
Now $1.026 times 1.12$:
$1.026 times 1.12 = 1.026 + 1.026 times 0.12 = 1.026 + 0.12312 = 1.14912$.
Net change $= 1.14912 - 1 = 0.14912$.
As a percent: $14.912%$, about $14.91%$ growth.
]
#ans[About 14.91% growth]
]

#trap[
Do not add $8 - 5 + 12 = 15%$. Adding percent changes only works when they all sit on the same base, and successive changes never do. Here the true answer is 14.912%, not 15%.
]

#ex(24, tier: 2, asked: "GIC · pattern")[A fund holds 60% of its money in equity and 40% in bonds. Over a year equity returns $+15%$ and bonds return $-5%$. Find the fund's overall percent return.
#sol[
Take the fund as 100 units.
Equity $= 60$, bonds $= 40$.
Equity becomes $60 times 1.15 = 60 + 9 = 69$.
Bonds become $40 times 0.95 = 40 - 2 = 38$.
Total $= 69 + 38 = 107$.
Change $= 107 - 100 = 7$ out of 100, so $+7%$.
Weighted-average check: $0.6 times 15 + 0.4 times (-5) = 9 - 2 = 7$. Matches.
]
#ans[$+7%$]
]

#ex(25, tier: 2, asked: "Agoda · pattern")[A hotel ran at 80% occupancy with an average rate of S\$180 per night. The next year occupancy fell to 72% but the average rate rose to S\$207. Find the percent change in revenue per available room.
#sol[
Revenue per available room $=$ occupancy $times$ rate.
Old $= 0.80 times 180 = 144$.
New $= 0.72 times 207$.
$0.72 times 207 = 0.72 times 200 + 0.72 times 7 = 144 + 5.04 = 149.04$.
Change $= 149.04 - 144 = 5.04$.
Percent change $= (5.04/144) times 100$.
$5.04/144 = 0.035$.
$0.035 times 100 = 3.5$.
]
#ans[$+3.5%$]
]

#ex(26, tier: 2, asked: "SCB · pattern")[A Thai exporter's revenue in baht rose by 20% this year. Over the same period the value of one baht in US dollars fell by 10%. Find the percent change in the exporter's revenue measured in US dollars.
#sol[
Revenue in USD $=$ (revenue in THB) $times$ (USD per THB).
THB multiplier $= 1.20$.
Rate multiplier $= 0.90$.
Combined $= 1.20 times 0.90 = 1.08$.
Change $= 1.08 - 1 = 0.08 arrow.r +8%$.
]
#ans[$+8%$]
]

#ex(27, tier: 2, asked: "LINE MAN · pattern")[In March, 25% of a platform's orders came from Zone A and the rest from Zone B. In April, Zone A orders rose 40% and Zone B orders fell 8%. Find the percent change in total orders.
#sol[
Take March total $= 100$ orders.
Zone A $= 25$. Zone B $= 100 - 25 = 75$.
April Zone A $= 25 times 1.40 = 35$.
April Zone B $= 75 times 0.92$.
$75 times 0.92 = 75 - 75 times 0.08 = 75 - 6 = 69$.
April total $= 35 + 69 = 104$.
Change $= 104 - 100 = 4$ out of 100, so $+4%$.
]
#ans[$+4%$]
]

#ex(28, tier: 2, asked: "Sea · pattern")[A marketplace deducts a 15% commission from the list price, then a 5% payment fee on whatever is left. A seller received THB~8,075. Find the list price.
#sol[
Let the list price be $L$.
After commission: $L times 0.85$.
After the payment fee on that amount: $L times 0.85 times 0.95$.
$0.85 times 0.95 = 0.85 - 0.85 times 0.05 = 0.85 - 0.0425 = 0.8075$.
So $0.8075 L = 8075$.
$L = 8075/0.8075 = 80750000/8075 = 10000$.
Check: $10000 times 0.85 = 8500$; $8500 times 0.95 = 8075$. Correct.
]
#ans[THB~10,000]
]

#trap[
A 15% cut then a 5% cut is not a 20% cut. The 5% is charged on the reduced amount, so the true total cut is $100 - 80.75 = 19.25%$. Reading "20%" here gives a list price of THB~10,093.75, which is wrong.
]

#ex(29, tier: 2, asked: "Razer · pattern")[A checkout system should apply a single 15% discount on an order of S\$240. By mistake it applies the 15% discount twice, one after the other. By how many dollars, and by what percent, is the charged amount below the correct amount?
#sol[
Correct amount $= 240 times 0.85$.
$240 times 0.85 = 240 - 240 times 0.15 = 240 - 36 = 204$.
Charged amount $= 204 times 0.85 = 204 - 204 times 0.15 = 204 - 30.60 = 173.40$.
Shortfall $= 204 - 173.40 = 30.60$.
Percent below the correct amount, base $= 204$:
$(30.60/204) times 100 = 15$.
That is expected: the extra step *is* one more 15% cut.
]
#ans[S\$30.60 short, which is 15% below the correct amount]
]

#practice(tier: 2, time: "100 s/Q")[
+ A price rises 8% and then rises 8% again. Find the net percent rise.
+ S\$500 falls by 12% and then rises by 12%. Find the final amount and the net percent change.
+ A portfolio is 70% bonds returning $+3%$ and 30% equity returning $-10%$. Find the overall percent return.
+ An online seller receives THB~6,460 after a 15% commission is taken off the list price. Find the list price.
+ A shop's revenue rose 25% while the number of units sold fell 10%. Find the percent change in the price per unit.
+ A hotel moved from 85% occupancy at S\$120 per night to 78% occupancy at S\$135 per night. Find the percent change in revenue per available room.
+ A value in baht rose 15%, and the US dollar value of one baht fell 5%. Find the percent change in the US dollar value.
+ A company has 45% of its staff in Singapore and the rest in Bangkok. Singapore headcount grows 20% and Bangkok headcount falls 10%. Find the percent change in total headcount.
+ After three successive cuts of 10% each, what percent of the original price remains?
+ A restaurant bill of S\$250 has a 9% service charge added, and then 8% tax is charged on the new total. Find the final amount.
+ Ads make up 40% of a firm's revenue. Ad revenue grows 30% while the rest stays flat. Find the percent change in total revenue.
]

#key[
+ *16.64%.* $1.08 times 1.08 = 1.1664$. Or $8 + 8 + (8 times 8)/100 = 16 + 0.64$.
+ *S\$492.80; a 1.44% fall.* $0.88 times 1.12 = 0.9856$, and $500 times 0.9856 = 492.80$. The $x^2/100$ rule gives $144/100 = 1.44%$.
+ *$-0.9%$.* $0.7 times 3 + 0.3 times (-10) = 2.1 - 3 = -0.9$.
+ *THB~7,600.* $0.85 L = 6460 arrow.r L = 6460/0.85 = 7600$.
+ *About $+38.89%$.* Price $=$ revenue $div$ units, so the multiplier is $1.25/0.90 = 1.3889$, a rise of 38.89%.
+ *About $+3.24%$.* Old $= 0.85 times 120 = 102$; new $= 0.78 times 135 = 105.30$; rise $= 3.30$, and $3.30/102 = 0.03235$.
+ *$+9.25%$.* $1.15 times 0.95 = 1.0925$.
+ *$+3.5%$.* $0.45 times 1.20 + 0.55 times 0.90 = 0.54 + 0.495 = 1.035$.
+ *72.9% remains, a fall of 27.1%.* $0.9^3 = 0.729$. Adding $10 + 10 + 10 = 30%$ is wrong.
+ *S\$294.30.* $250 times 1.09 = 272.50$; $272.50 times 1.08 = 294.30$.
+ *$+12%$.* $0.40 times 1.30 + 0.60 times 1 = 0.52 + 0.60 = 1.12$.
]

#section[Tier 3 — Product companies]
#tier-header(3)

#ex(30, tier: 3, asked: "Google · pattern")[A shop raises a price by $x%$ and later lowers the new price by the same $x%$. The final price is 9% below the original, and the drop in rupees is Rs.~270. Find $x$ and the original price.
#sol[
*Insight: an up-then-down move by the same percent is $(1+x\/100)(1-x\/100)$, which is the difference of two squares. The net loss is always $x^2\/100$ percent, and it never depends on the price.*

Net multiplier $= (1 + x/100)(1 - x/100) = 1 - x^2/10000$.

So the loss as a fraction is $x^2/10000$, that is $x^2/100$ percent.

Set that equal to 9:
$x^2/100 = 9$
$x^2 = 900$
$x = 30$ (a percent change is taken positive here).

Now the original price $P$. The fall is 9% of $P$:
$0.09 P = 270$
$P = 270/0.09 = 27000/9 = 3000$.

Check: $3000 times 1.30 = 3900$; $3900 times 0.70 = 2730$; drop $= 3000 - 2730 = 270$. Correct.
]
#ans[$x = 30$; original price Rs.~3,000]
]

#ex(31, tier: 3, asked: "Amazon · pattern")[Revenue grew 10% in year 1 and fell $x%$ in year 2, finishing 1% below where it started. Find $x$. Then find the single constant yearly rate that would produce the same two-year result.
#sol[
*Insight: a chain of percent changes is a product of multipliers. Any question about a chain becomes one equation in multipliers.*

Part 1.
$1.10 times (1 - x/100) = 0.99$
$1 - x/100 = 0.99/1.10 = 0.90$
$x/100 = 1 - 0.90 = 0.10$
$x = 10$.
Check: $100 times 1.10 = 110$; $110 times 0.90 = 99$. That is 1% below 100. Correct.

Part 2. Let the constant yearly multiplier be $1 + g$.
$(1+g)^2 = 0.99$
$1 + g = sqrt(0.99)$

First a quick estimate. For a small $g$, $(1+g)^2 approx 1 + 2g$, so $2g approx -0.01$ and $g approx -0.5%$.

Now refine. Try $1 + g = 0.995$: $0.995^2 = 0.990025$. Slightly too big.
Try $1 + g = 0.9949$: $0.9949^2 = 0.98982601$. Slightly too small.
The true value sits between, at $1 + g approx 0.994987$.
So $g approx -0.5013%$, about a 0.5% fall each year.
]
#ans[$x = 10$; a constant rate of about $-0.50%$ per year]
]

#ex(32, tier: 3, asked: "Goldman Sachs · pattern")[A fund has exactly two sleeves. One returned $+15%$, the other returned $-2%$, and the fund overall returned $+6%$. What fraction of the money was in the first sleeve?
#sol[
*Insight: the overall return is a weighted average of the two returns, so the weights split the gap between them in inverse ratio — this is the alligation rule.*

Let the fraction in the first sleeve be $w$. Then $1 - w$ sits in the second.
$15 w + (-2)(1 - w) = 6$
$15 w - 2 + 2 w = 6$
$17 w = 8$
$w = 8/17$.

As a decimal: $8/17 = 0.4706$, so about 47.06%.

Alligation check. Distances from the overall 6:
first sleeve: $15 - 6 = 9$
second sleeve: $6 - (-2) = 8$
The weights are in the *inverse* ratio $8 : 9$, so the first sleeve holds $8/(8+9) = 8/17$. Matches.

Verify: $8/17 times 15 = 120/17$ and $9/17 times (-2) = -18/17$. Sum $= 102/17 = 6$. Correct.
]
#ans[$8/17$, about 47.06%]
]

#ex(33, tier: 3, asked: "D. E. Shaw · pattern")[A stock moves only in two ways: it rises 10% on an up-day and falls 10% on a down-day. Over 10 trading days there are exactly 5 up-days and 5 down-days, in some unknown order. Find the net percent change.
#sol[
*Insight: multiplication does not care about order. So the unknown order is a red herring — the answer is fixed.*

Net multiplier $= 1.1^5 times 0.9^5 = (1.1 times 0.9)^5 = 0.99^5$.

Compute step by step.
$0.99^2 = 0.9801$
$0.99^4 = 0.9801^2$
$0.9801^2 = 0.9801 times 0.9801 = 0.9801 - 0.9801 times 0.0199 = 0.9801 - 0.01950399 = 0.96059601$
$0.99^5 = 0.96059601 times 0.99 = 0.96059601 - 0.0096059601 = 0.9509900499$

Net change $= 0.9509900499 - 1 = -0.04900995$.
As a percent: about $-4.90%$.

Sanity check with the pair rule: each up-down pair is a loss of $10^2/100 = 1%$. Five pairs give $0.99^5$, which is a little less than a 5% loss because the losses compound on a shrinking base. $4.90% < 5%$, as expected.
]
#ans[About a 4.90% fall]
]

#ex(34, tier: 3, asked: "Microsoft · pattern")[In a survey of 1,000 people, 62% like tea, 47% like coffee and 15% like neither. What percent like both? If the "neither" figure were unknown, what is the largest and smallest the "both" figure could be?
#sol[
*Insight: percentages of the same total behave exactly like counts, so the two-set formula applies directly.*

Part 1.
Like at least one $= 100% - 15% = 85%$.
Two-set rule: $n("tea or coffee") = n("tea") + n("coffee") - n("both")$
$85 = 62 + 47 - n("both")$
$85 = 109 - n("both")$
$n("both") = 109 - 85 = 24$.
So 24%, that is $0.24 times 1000 = 240$ people.

Part 2 — the range, with "neither" unknown.
*Largest.* "Both" can never exceed the smaller group, so $n("both") <= 47%$. That happens when every coffee drinker also drinks tea. Then "at least one" $= 62%$ and "neither" $= 38%$. Legal.
*Smallest.* "At least one" can never exceed 100%, so
$62 + 47 - n("both") <= 100$
$109 - n("both") <= 100$
$n("both") >= 9$.
At $n("both") = 9%$, "at least one" $= 100%$ and "neither" $= 0%$. Legal.
]
#ans[24% like both; in general "both" lies between 9% and 47%]
]

#ex(35, tier: 3, asked: "Uber · pattern")[A driver's take-home pay equals (trips $times$ fare per trip) minus the platform commission. Over one quarter, trips fell 12%, the fare per trip rose 20%, and the commission rose from 20% of gross to 25% of gross. Find the percent change in take-home pay.
#sol[
*Insight: split the pay into two independent multipliers — one for gross earnings, one for the share the driver keeps. Then multiply.*

Step 1 — gross earnings $=$ trips $times$ fare.
Trips multiplier $= 0.88$.
Fare multiplier $= 1.20$.
Gross multiplier $= 0.88 times 1.20$.
$0.88 times 1.20 = 0.88 + 0.88 times 0.20 = 0.88 + 0.176 = 1.056$.

Step 2 — the share the driver keeps.
Before: commission 20%, so the driver keeps $100% - 20% = 80%$.
After: commission 25%, so the driver keeps $100% - 25% = 75%$.
Share multiplier $= 0.75/0.80 = 0.9375$.

Step 3 — combine.
Take-home multiplier $= 1.056 times 0.9375$.
$1.056 times 0.9375 = 1.056 - 1.056 times 0.0625 = 1.056 - 0.066 = 0.99$.

Change $= 0.99 - 1 = -0.01 arrow.r -1%$.

Number check. Start with 100 trips at S\$10, gross $= 1000$, driver keeps 80% $= 800$.
Now 88 trips at S\$12, gross $= 1056$, driver keeps 75% $= 792$.
$792$ against $800$ is a fall of $8/800 = 1%$. Correct.
]
#ans[Take-home pay falls by 1%]
]

#ex(36, tier: 3, asked: "Adobe · pattern")[The side of a square is measured 3% too long. Find the percentage error in the computed area. Then find the percentage error in the computed volume if the same 3% error is made on the edge of a cube. Why is the answer not exactly 6% and 9%?
#sol[
*Insight: errors multiply, they do not add. Doubling or tripling the error is only the first term of the expansion; the leftover terms are what make the answer slightly larger.*

Area. Side multiplier $= 1.03$, and area $=$ $"side"^2$.
Area multiplier $= 1.03^2$.
$1.03^2 = 1.03 times 1.03 = 1.03 + 1.03 times 0.03 = 1.03 + 0.0309 = 1.0609$.
Error $= 1.0609 - 1 = 0.0609 arrow.r 6.09%$ too large.

Volume. Edge multiplier $= 1.03$, and volume $=$ $"edge"^3$.
Volume multiplier $= 1.03^3 = 1.0609 times 1.03$.
$1.0609 times 1.03 = 1.0609 + 1.0609 times 0.03 = 1.0609 + 0.031827 = 1.092727$.
Error $= 1.092727 - 1 = 0.092727 arrow.r 9.2727%$ too large.

Why not exactly 6% and 9%?
Expand: $(1 + x)^2 = 1 + 2x + x^2$. The $2x$ part gives the 6%. The extra $x^2 = 0.0009$ gives the extra 0.09%.
Expand: $(1 + x)^3 = 1 + 3x + 3x^2 + x^3$. The $3x$ gives 9%; the $3x^2 = 0.0027$ and $x^3 = 0.000027$ give the extra 0.2727%.
For small errors the rough rule "$n$ times the error" is close, but it always understates a positive error.
]
#ans[Area 6.09% too large; volume 9.2727% too large]
]

#practice(tier: 3, time: "4 min/Q")[
+ A price rises $x%$ and then falls $x%$, finishing 6.25% below the original. Find $x$.
+ A stock rises 20% on day 1. By what percent must it fall on day 2 to finish 4% below where it started?
+ In a class, 70% passed Maths and 60% passed Physics, and 45% passed both. What percent failed both?
+ Two sleeves of a fund returned $+18%$ and $-6%$, and the fund overall returned $+4%$. Find the fraction held in the first sleeve.
+ The radius of a circle is measured 4% too small. Find the percentage error in the computed area.
+ A driver's trips rise 15%, the fare per trip falls 10%, and the platform commission falls from 25% of gross to 20% of gross. Find the percent change in take-home pay.
+ A shopkeeper raises the price by 30% and then gives two successive discounts of 10% each. Find the net percent change in price.
]

#key[
+ *$x = 25$.* Up then down by the same $x%$ always loses $x^2\/100$ percent, so $x^2\/100 = 6.25$, giving $x^2 = 625$ and $x = 25$. Check: $1.25 times 0.75 = 0.9375$, a 6.25% fall.
+ *20%.* Let the day-2 fall be $f$. Then $1.20 (1 - f) = 0.96$, so $1 - f = 0.96/1.20 = 0.80$ and $f = 0.20$. Note the answer is *not* 24%, even though the stock must give back more than it gained.
+ *15%.* Passed at least one $= 70 + 60 - 45 = 85%$, so failed both $= 100 - 85 = 15%$.
+ *$5/12$.* With weight $w$ in the first sleeve, $18 w - 6(1 - w) = 4$, so $24 w = 10$ and $w = 10/24 = 5/12$. Alligation check: the distances are $18 - 4 = 14$ and $4 - (-6) = 10$, and the inverse ratio $10 : 14 = 5 : 7$ gives $5/12$.
+ *7.84% too small.* Area multiplier $= 0.96^2 = 0.9216$, so the error is $1 - 0.9216 = 0.0784$. The rough rule "twice the error" would say 8%, which overstates a negative error.
+ *$+10.4%$.* Gross multiplier $= 1.15 times 0.90 = 1.035$. The driver's share goes from 75% to 80%, a multiplier of $0.80/0.75 = 16/15$. Combined: $1.035 times 16/15 = 16.56/15 = 1.104$.
+ *$+5.3%$.* $1.30 times 0.90 times 0.90 = 1.30 times 0.81 = 1.053$. Adding $30 - 10 - 10 = 10%$ is the common error.
]

#section[Mixed set — exam conditions]

#practice(tier: 1, time: "90 s/Q · 18 questions in 27 minutes")[
+ Find 12.5% of 4,800.
+ If 25% of $x$ equals 40% of 150, find $x$.
+ A number decreased by 30% becomes 560. Find the original number.
+ A quantity rises 50% and then rises 20%. Find the net percent rise.
+ A salary of Rs.~45,000 is raised by 8%. Find the new salary.
+ The price of an item rises 60%. By what percent must consumption be cut so that spending is unchanged?
+ A town's population grew from 8,000 to 9,680 in two years at a constant yearly rate. Find the rate.
+ Write $9/16$ as a percent.
+ A man saves 15% of his income of Rs.~64,000. Find his savings and his expenditure.
+ In an election between two candidates, the winner won by a margin equal to 15% of the total votes. The margin was 4,500 votes. Find the total number of votes.
+ A machine costing Rs.~1,25,000 depreciates 20% each year. Find its value after 3 years.
+ In a college, 60% of the students are boys. 30% of the boys and 50% of the girls take the bus. What percent of all students take the bus?
+ A shop marks up its cost by 40% and then gives a 25% discount. Find the net percent change from cost.
+ A student multiplied a number by $4/5$ instead of $5/4$. Find the percentage error.
+ If A is 20% of B, and B is 30% of C, then A is what percent of C?
+ A town's population rose 10% in year 1 and 5% in year 2. Find the net percent rise over the two years.
+ A man's expenditure is 75% of his income. His income rises 20% and his expenditure rises 12%. Find the percent rise in savings.
+ Find 0.5% of 8,000.
]

#key[
+ *600.* $12.5% = 1/8$, and $4800/8 = 600$.
+ *240.* $0.25 x = 0.40 times 150 = 60$, so $x = 60/0.25 = 240$.
+ *800.* $0.70 N = 560 arrow.r N = 560/0.70 = 800$.
+ *80%.* $1.50 times 1.20 = 1.80$.
+ *Rs.~48,600.* $45000 times 1.08 = 45000 + 3600 = 48600$.
+ *37.5%.* $(100 times 60)/(100 + 60) = 6000/160 = 37.5$.
+ *10%.* $9680/8000 = 1.21 = (1 + r)^2$, so $1 + r = 1.1$ and $r = 10%$.
+ *56.25%.* $9/16 times 100 = 900/16 = 56.25$.
+ *Savings Rs.~9,600; expenditure Rs.~54,400.* $0.15 times 64000 = 9600$, and $64000 - 9600 = 54400$.
+ *30,000.* $0.15 times "total" = 4500 arrow.r$ total $= 4500/0.15 = 30000$.
+ *Rs.~64,000.* $125000 times 0.8^3 = 125000 times 0.512 = 64000$.
+ *38%.* $0.60 times 0.30 + 0.40 times 0.50 = 0.18 + 0.20 = 0.38$.
+ *$+5%$.* $1.40 times 0.75 = 1.05$. Adding $40 - 25 = 15%$ is the trap.
+ *36%.* Take the number as 20: correct $= 25$, wrong $= 16$, error $= 9$, and $9/25 = 0.36$.
+ *6%.* $A = 0.20 B$ and $B = 0.30 C$, so $A = 0.20 times 0.30 C = 0.06 C$.
+ *15.5%.* $1.10 times 1.05 = 1.155$. Adding $10 + 5 = 15%$ misses the $0.5%$ cross term.
+ *44%.* Income 100, expenditure 75, savings 25. New income 120, new expenditure $75 times 1.12 = 84$, new savings 36. Rise $= 11/25 = 0.44$.
+ *40.* $0.5% = 0.005$, and $8000 times 0.005 = 40$.
]

#revision[

*Core.* $x%$ of $N = (x N)/100$ · $A$ as a percent of $B = (A/B) times 100$ · change $=$ (new $-$ old) $div$ old $times 100$.

*Multipliers — the whole chapter in one line.* Up $x% arrow.r times (1 + x/100)$. Down $x% arrow.r times (1 - x/100)$. Chain them by multiplying. Order never matters.
Two changes: net $= a + b + (a b)/100$.

*Fraction table.* $1/2 = 50$ · $1/3 = 33 1/3$ · $1/4 = 25$ · $1/5 = 20$ · $1/6 = 16 2/3$ · $1/7 = 14 2/7$ · $1/8 = 12.5$ · $1/9 = 11 1/9$ · $1/10 = 10$ · $1/11 = 9 1/11$ · $1/12 = 8 1/3$ · $1/15 = 6 2/3$ · $1/16 = 6.25$ · $1/20 = 5$ · $1/25 = 4$ · $1/40 = 2.5$ (all in percent).

*Reverse rules.* $A$ is $x%$ more than $B$ $arrow.r$ $B$ is $(100x)/(100+x)%$ less than $A$.
$A$ is $x%$ less than $B$ $arrow.r$ $B$ is $(100x)/(100-x)%$ more than $A$.

*Product constancy.* Price up $x% arrow.r$ consumption down $(100x)/(100+x)%$ to hold spending fixed.
Quick fraction form: price up $1/n arrow.r$ consumption down $1/(n+1)$. (Up 25% $= 1/4 arrow.r$ down $1/5 = 20%$.)

*Up $x%$ then down $x%$.* Always a fall of $x^2/100$ percent. $10 arrow.r 1%$ · $20 arrow.r 4%$ · $25 arrow.r 6.25%$ · $30 arrow.r 9%$ · $50 arrow.r 25%$.

*Growth / depreciation.* $P(1 plus.minus r/100)^n$. Mixed rates: multiply the separate multipliers.

*Error.* $"% error" = ("wrong" - "correct")/"correct" times 100$. Side off by $x% arrow.r$ area off by $(1+x/100)^2 - 1$; volume off by $(1+x/100)^3 - 1$.

*Income.* Always set income $= 100$. Savings $=$ income $-$ expenditure. Percent rise in savings uses the *old savings* as base.

*Weighted percent.* Whole change $= w a + (1-w) b$. To find the weight from the result, use alligation: weights are in the inverse ratio of the distances from the overall figure.

*Top 5 traps.*
+ Never add successive percent changes. $+8%$ then $-5%$ is $+2.6%$ net ($1.08 times 0.95 = 1.026$), not $+3%$.
+ The base flips when the comparison flips. $x%$ more one way is *not* $x%$ less the other way.
+ Up $x%$ then down $x%$ never returns to the start. It always loses $x^2/100$ percent.
+ Percentage error divides by the *correct* value, never by the wrong one.
+ "Fails by $m$ marks" means score $+ m =$ pass mark. Read the sentence, then write the equation.
]

]
