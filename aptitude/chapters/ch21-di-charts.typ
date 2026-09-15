#import "../lib/style.typ": *

#chapter(num: 21, title: "Data Interpretation: Tables, Bar, Line, Pie", tagline: "Read the chart, pick the base, divide once")[

#section[What you need to know]

#formulas[

*The only four operations in DI.* Add a row or column. Take a percent. Take a ratio. Compare two numbers. Everything else is dressing.

*Percent change.*
$ "% change" = ("new" - "old")/"old" times 100 $
The *old* value is always the base. A rise of $x%$ means multiply by $(1 + x/100)$.

*Share of total.*
$ "share of A" = A/"total" times 100 quad "(read as a percent)" $

*Pie chart.*
- $"value of a sector" = "percent"/100 times "total"$
- $"central angle" = "percent" times 3.6 "degrees"$
- $"percent" = "angle"/3.6$
- Full circle $= 360 degree = 100%$

*Bar chart.* Each bar is one number. A grouped bar chart is a table drawn sideways. Read the axis scale once, then treat it as a table.

*Line chart.* Two different things get drawn as lines, and you must know which one you have:
- a line of *values* (revenue, users) — the value falls when the line falls;
- a line of *growth rates* (percent over previous year) — the value still *rises* while the line stays above zero.

*Linking two charts.* If the total grows by multiplier $M$ and a part's share goes from $s_1$ to $s_2$, then
$ "part multiplier" = s_2/s_1 times M $
So the part can grow even when its share falls.

*Weighted growth.* If parts with shares $w_1, w_2, dots$ (written as fractions that add to 1) grow by $g_1, g_2, dots$ percent, the total grows by
$ w_1 g_1 + w_2 g_2 + dots "percent" $

*Average from a table.* Average $=$ (sum of entries) $div$ (number of entries). But an *average rate* (price per unit, fare per trip) is
$ "total value"/"total quantity" $
never the plain average of the rates.

*Index numbers.* If a base year is set to 100, then any two index values divide like the real values do. Index $138 arrow.r 120.75$ is a change of $(120.75 - 138)/138 = -12.5%$, whatever the real numbers are.

*Approximation discipline.*
- Round to 2 significant figures *only* when the options are far apart.
- $1/3 approx 33%$, $1/6 approx 16.7%$, $1/7 approx 14.3%$, $1/8 = 12.5%$, $1/9 approx 11.1%$, $1/11 approx 9.1%$, $1/12 approx 8.3%$.
- To find $A$ as a percent of $B$: first find $10%$ of $B$, then scale.
- Never round a base before dividing. Round the answer, not the input.

*Ratio comparison without dividing.* To compare $a/b$ and $c/d$, cross-multiply: $a d$ versus $c b$. The bigger product sits over the bigger fraction.
]

#section[Warm-up]
#tier-header(0)

#note[Warm-ups 1--5 use this small table. Units sold, in thousands.]

#table(columns: 3,
  [*Store*], [*2022*], [*2023*],
  [A], [40], [50],
  [B], [60], [54],
  [C], [25], [30],
  [D], [75], [90],
)

#ex(1, tier: 0)[Find the total for 2022.
#sol[
$40 + 60 = 100$.
$100 + 25 = 125$.
$125 + 75 = 200$.
]
#ans[200 thousand units]
]

#ex(2, tier: 0)[Find the percent change for store A.
#sol[
Rise $= 50 - 40 = 10$.
Base is the old value, 40.
$(10/40) times 100 = 0.25 times 100 = 25$.
]
#ans[$+25%$]
]

#ex(3, tier: 0)[Find the percent change for store B.
#sol[
Fall $= 60 - 54 = 6$.
Base is 60.
$(6/60) times 100 = 10$. The value went down.
]
#ans[$-10%$]
]

#ex(4, tier: 0)[Find the ratio of C to D in 2023.
#sol[
$30 : 90$.
Divide both by 30: $1 : 3$.
]
#ans[$1 : 3$]
]

#ex(5, tier: 0)[Find the average of the four 2023 values.
#sol[
$50 + 54 = 104$.
$104 + 30 = 134$.
$134 + 90 = 224$.
$224 div 4 = 56$.
]
#ans[56 thousand units]
]

#ex(6, tier: 0)[A pie chart shows exports of Rs.~7,200 crore. Electronics is 25%. Find the value of the electronics sector.
#sol[
$25% = 25/100 = 1/4$.
$7200 div 4 = 1800$.
]
#ans[Rs.~1,800 crore]
]

#ex(7, tier: 0)[A pie chart of a total of 6,000 has a sector of $54 degree$. Find its value.
#sol[
Fraction of the circle $= 54/360$.
$54/360 = 27/180 = 3/20$.
$6000 times 3/20 = (6000 div 20) times 3 = 300 times 3 = 900$.
]
#ans[900]
]

#ex(8, tier: 0)[A sector is 18% of a pie chart. Find its central angle.
#sol[
Angle $= "percent" times 3.6$.
$18 times 3.6 = 18 times 3 + 18 times 0.6 = 54 + 10.8 = 64.8$.
]
#ans[$64.8 degree$]
]

#section[Tier 1 — Service companies]
#tier-header(1)

#subsection[Data set 1 — table]

#note[Laptops sold by five stores, in units.]

#table(columns: 4,
  [*Store*], [*2021*], [*2022*], [*2023*],
  [Ahmedabad], [1,200], [1,500], [1,800],
  [Bengaluru], [2,400], [2,200], [2,640],
  [Chennai], [1,600], [2,000], [2,200],
  [Delhi], [3,000], [3,300], [3,960],
  [Pune], [1,800], [2,000], [2,400],
)

#ex(9, tier: 1, asked: "TCS NQT pattern")[Find the total number of laptops sold by all five stores in 2022.
#sol[
Add the 2022 column.
$1500 + 2200 = 3700$.
$3700 + 2000 = 5700$.
$5700 + 3300 = 9000$.
$9000 + 2000 = 11000$.
]
#ans[11,000 units]
]

#note[Two totals you will reuse: 2021 total $= 1200 + 2400 + 1600 + 3000 + 1800 = 10{,}000$, and 2023 total $= 1800 + 2640 + 2200 + 3960 + 2400 = 13{,}000$.]

#ex(10, tier: 1, asked: "Infosys pattern")[Find the percent rise in Delhi's sales from 2021 to 2023.
#sol[
Old $= 3000$. New $= 3960$.
Rise $= 3960 - 3000 = 960$.
$(960/3000) times 100$.
$960/3000 = 96/300 = 32/100 = 0.32$.
$0.32 times 100 = 32$.
]
#ans[$+32%$]
]

#ex(11, tier: 1, asked: "Accenture pattern")[Which store had the highest percent growth from 2021 to 2023?
#sol[
Do all five. Each time, divide the new value by the old value.
Ahmedabad: $1800/1200 = 1.5 arrow.r +50%$.
Bengaluru: $2640/2400 = 1.1 arrow.r +10%$.
Chennai: $2200/1600 = 1.375 arrow.r +37.5%$.
Delhi: $3960/3000 = 1.32 arrow.r +32%$.
Pune: $2400/1800 = 4/3 = 1.3333 arrow.r +33.33%$.
The largest multiplier is 1.5.
]
#ans[Ahmedabad, $+50%$]
]

#trick[
Do not compute "rise, then divide by old". Compute *new $div$ old* in one step and read the growth straight off the multiplier. $1.32$ means $+32%$. $0.88$ means $-12%$. One division instead of a subtraction plus a division.
]

#trap[
Delhi rose by 960 units and Ahmedabad rose by only 600 units, yet Ahmedabad grew faster in percent. A bigger *absolute* rise is not a bigger *percent* rise. Read the question and see which one it asks for.
]

#ex(12, tier: 1, asked: "Wipro pattern")[In 2023, Chennai's sales are what percent of the five-store total?
#sol[
Chennai 2023 $= 2200$. Total 2023 $= 13000$.
$(2200/13000) times 100$.
Cancel 100 from top and bottom: $2200/13000 = 22/130 = 11/65$.
$11 div 65$: $65 times 0.16 = 10.4$. Remainder $11 - 10.4 = 0.6$.
$0.6/65 = 0.00923$.
So $11/65 = 0.16923$.
$0.16923 times 100 = 16.923$.
]
#ans[About 16.92%]
]

#ex(13, tier: 1, asked: "TCS NQT pattern")[Find the ratio of Bengaluru's 2023 sales to Pune's 2023 sales.
#sol[
$2640 : 2400$.
Divide both by 10: $264 : 240$.
Divide both by 24: $264 div 24 = 11$ and $240 div 24 = 10$.
]
#ans[$11 : 10$]
]

#subsection[Data set 2 — grouped bar chart]

#note[Revenue of a food-delivery app, in Rs.~crore. Two bars per quarter.]

#table(columns: 3,
  [*Quarter*], [*2022*], [*2023*],
  [Q1], [240], [300],
  [Q2], [280], [322],
  [Q3], [320], [416],
  [Q4], [360], [450],
)

#ex(14, tier: 1, asked: "Capgemini pattern")[Find the total 2023 revenue and the percent growth over 2022.
#sol[
2023 total: $300 + 322 = 622$.
$622 + 416 = 1038$.
$1038 + 450 = 1488$.
2022 total: $240 + 280 = 520$; $520 + 320 = 840$; $840 + 360 = 1200$.
Rise $= 1488 - 1200 = 288$.
$(288/1200) times 100$.
$288/1200 = 24/100 = 0.24$.
$0.24 times 100 = 24$.
]
#ans[Rs.~1,488 crore; $+24%$]
]

#ex(15, tier: 1, asked: "Cognizant pattern")[Which quarter had the highest percent growth from 2022 to 2023?
#sol[
Q1: $300/240 = 1.25 arrow.r +25%$.
Q2: $322/280 = 1.15 arrow.r +15%$.
Q3: $416/320 = 1.30 arrow.r +30%$.
Q4: $450/360 = 1.25 arrow.r +25%$.
The largest is Q3.
]
#ans[Q3, $+30%$]
]

#ex(16, tier: 1, asked: "Accenture pattern")[Q4 of 2023 is what percent of the 2023 yearly revenue?
#sol[
Q4 $= 450$. Year $= 1488$.
$(450/1488) times 100$.
First take 30% of 1488: $1488 times 0.30 = 446.4$.
$450 - 446.4 = 3.6$ is left over.
$3.6/1488 = 0.00242$, which is $0.242%$.
So the share is $30 + 0.242 = 30.242$.
]
#ans[About 30.24%]
]

#trick[
For "A is what percent of B", anchor on an easy percent of $B$ first. Here 30% of 1488 was 446.4, already very close to 450. The remaining gap is tiny, so you only fine-tune. This beats long division every time.
]

#subsection[Data set 3 — pie chart]

#note[A company of 7,200 employees, split by department.]

#table(columns: 7,
  [*Dept*], [Engineering], [Sales], [Support], [Operations], [Finance], [HR],
  [*Share*], [35%], [20%], [15%], [18%], [7%], [5%],
)

#ex(17, tier: 1, asked: "TCS NQT pattern")[How many employees work in Operations?
#sol[
$18%$ of 7,200.
$1%$ of $7200 = 72$.
$18 times 72 = 18 times 70 + 18 times 2 = 1260 + 36 = 1296$.
]
#ans[1,296 employees]
]

#ex(18, tier: 1, asked: "Infosys pattern")[Find the central angle of the Support sector.
#sol[
Angle $= "percent" times 3.6$.
$15 times 3.6 = 54$.
]
#ans[$54 degree$]
]

#trick[
Percent to degrees: multiply by $3.6$. Degrees to percent: divide by $3.6$. Memorise four anchors: $10% = 36 degree$, $25% = 90 degree$, $50% = 180 degree$, $1% = 3.6 degree$.
]

#ex(19, tier: 1, asked: "Wipro pattern")[Engineering has how many percent more employees than Sales?
#sol[
Both sectors come from the same total, so you may compare the *percents* directly and never compute the headcounts.
Difference $= 35 - 20 = 15$ percentage points.
Base is Sales, which is 20.
$(15/20) times 100 = 0.75 times 100 = 75$.
Check with real numbers: Engineering $= 0.35 times 7200 = 2520$, Sales $= 0.20 times 7200 = 1440$.
$(2520 - 1440)/1440 = 1080/1440 = 0.75$. Same answer.
]
#ans[75% more]
]

#trap[
This shortcut works *only* when both sectors come from the same pie. If the two sectors sit in two different pies with different totals, you must convert to real values first. Two pies never share a base.
]

#subsection[Data set 4 — line chart]

#note[Average daily active users of an app, in lakh.]

#table(columns: 7,
  [*Month*], [Jan], [Feb], [Mar], [Apr], [May], [Jun],
  [*Users*], [12], [15], [18], [16.2], [21.6], [27],
)

#ex(20, tier: 1, asked: "Capgemini pattern")[(a) Find the percent change from March to April. (b) Find the percent change from January to June.
#sol[
(a) Old $= 18$, new $= 16.2$.
Fall $= 18 - 16.2 = 1.8$.
$(1.8/18) times 100 = 0.1 times 100 = 10$. The line fell, so this is a drop.
(b) Old $= 12$, new $= 27$.
$27/12 = 9/4 = 2.25$.
A multiplier of 2.25 means $2.25 - 1 = 1.25$, that is $125%$ growth.
]
#ans[(a) $-10%$ #h(10pt) (b) $+125%$]
]

#practice(tier: 1, time: "60 s/Q")[
*Questions 1--6.* Units sold, in hundreds, by four dealers.

#table(columns: 3,
  [*Dealer*], [*2022*], [*2023*],
  [K], [250], [325],
  [L], [400], [360],
  [M], [320], [400],
  [N], [280], [336],
)

+ Find the total units sold in 2023 (in hundreds).
+ Find the percent change for dealer L.
+ Which dealer had the largest percent growth?
+ Which dealer had the largest rise in absolute units?
+ Find the ratio of M to L in 2023.
+ M's 2023 sales are what percent of the 2023 total?

*Questions 7--10.* A household budget of Rs.~60,000 a month.

#table(columns: 7,
  [*Head*], [Rent], [Food], [Transport], [School fees], [Utilities], [Savings],
  [*Share*], [30%], [22%], [12%], [18%], [8%], [10%],
)

+ Find the amount spent on food.
+ Find the central angle of the school-fees sector.
+ Rent is how many percent more than school fees?
+ Rent and food together take what amount?

*Questions 11--14.* A startup's headcount at each year end.

#table(columns: 6,
  [*Year*], [2019], [2020], [2021], [2022], [2023],
  [*Staff*], [40], [60], [90], [81], [108],
)

+ Find the percent rise from 2019 to 2021.
+ In which year did headcount fall, and by what percent?
+ Find the percent rise from 2022 to 2023.
+ Find the average headcount over the five years.
]

#key[
+ *1,421 hundred, i.e. 1,42,100 units.* $325 + 360 = 685$; $685 + 400 = 1085$; $1085 + 336 = 1421$.
+ *$-10%$.* $360/400 = 0.90$, so a fall of 10%.
+ *K.* $325/250 = 1.30$ ($+30%$); $400/320 = 1.25$ ($+25%$); $336/280 = 1.20$ ($+20%$); L fell.
+ *M.* Rises are K $+75$, L $-40$, M $+80$, N $+56$. M wins on units but K wins on percent — the two questions have different answers on purpose.
+ *$10 : 9$.* $400 : 360$; divide both by 40.
+ *About 28.15%.* $(400/1421) times 100$. $28%$ of $1421 = 397.88$; the gap $2.12$ is $0.15%$ of 1421; so $28 + 0.15 = 28.15$.
+ *Rs.~13,200.* $1%$ of $60000 = 600$, so $22 times 600 = 13200$.
+ *$64.8 degree$.* $18 times 3.6 = 64.8$.
+ *$66 2/3 %$.* Same pie, so compare shares: $(30 - 18)/18 = 12/18 = 2/3$.
+ *Rs.~31,200.* $30 + 22 = 52%$, and $52 times 600 = 31200$.
+ *$+125%$.* $90/40 = 2.25$, so a rise of 1.25 times the original.
+ *2022, a fall of 10%.* $81/90 = 0.90$.
+ *$+33 1/3 %$.* $108/81 = 4/3$.
+ *75.8.* $40 + 60 + 90 + 81 + 108 = 379$, and $379 div 5 = 75.8$.
]

#section[Tier 2 — Singapore & Thailand]
#tier-header(2)

#subsection[Data set 5 — table with two columns that must be multiplied]

#note[A ride-hailing firm. Trips are in thousands; the fare is an average per trip.]

#table(columns: 3,
  [*City*], [*Trips ('000)*], [*Average fare (S\$)*],
  [Singapore], [480], [12.50],
  [Bangkok], [900], [5.00],
  [Jakarta], [1,500], [3.20],
  [Manila], [1,200], [3.75],
  [Hanoi], [600], [2.80],
)

#ex(21, tier: 2, asked: "Grab · pattern")[Find each city's revenue and the total revenue.
#sol[
Revenue $=$ trips $times$ fare. Trips are in thousands, so each product is in thousands of S\$.
Singapore: $480 times 12.50 = 480 times 12 + 480 times 0.5 = 5760 + 240 = 6000$.
Bangkok: $900 times 5 = 4500$.
Jakarta: $1500 times 3.20 = 1500 times 3 + 1500 times 0.2 = 4500 + 300 = 4800$.
Manila: $1200 times 3.75 = 1200 times 3 + 1200 times 0.75 = 3600 + 900 = 4500$.
Hanoi: $600 times 2.80 = 600 times 2 + 600 times 0.8 = 1200 + 480 = 1680$.
Total: $6000 + 4500 = 10500$; $+4800 = 15300$; $+4500 = 19800$; $+1680 = 21480$.
]
#ans[Singapore S\$6.00 m, Bangkok S\$4.50 m, Jakarta S\$4.80 m, Manila S\$4.50 m, Hanoi S\$1.68 m; total S\$21.48 m]
]

#ex(22, tier: 2, asked: "Sea/Shopee · pattern")[Singapore's revenue is what percent of the total?
#sol[
$(6000/21480) times 100$.
Anchor: $28%$ of $21480 = 21480 times 0.28 = 6014.4$. That is slightly above 6000.
Gap $= 6014.4 - 6000 = 14.4$.
$14.4/21480 = 0.00067$, which is $0.067%$.
So the share is $28 - 0.067 = 27.933$.
]
#ans[About 27.93%]
]

#trap[
Singapore has only $480/4680 approx 10.3%$ of the trips but nearly 28% of the revenue. A share of one column is never a share of another column. Always ask: share *of what*?
]

#ex(23, tier: 2, asked: "Grab · pattern")[The firm keeps 20% of every fare as commission. Find the total commission, and the commission earned in Jakarta.
#sol[
Total commission $= 0.20 times 21480 = 4296$ (thousand S\$).
Jakarta commission $= 0.20 times 4800 = 960$ (thousand S\$).
]
#ans[S\$4.296 million in all; S\$0.96 million from Jakarta]
]

#subsection[Data set 6 — two pie charts, two different totals]

#note[A Bangkok logistics firm's cost split. Totals differ between the two years.]

#table(columns: 6,
  [*Head*], [Fuel], [Wages], [Vehicle lease], [Warehouse], [Admin],
  [*2022 (total THB~48 m)*], [30%], [25%], [20%], [15%], [10%],
  [*2023 (total THB~60 m)*], [24%], [28%], [20%], [16%], [12%],
)

#ex(24, tier: 2, asked: "LINE MAN · pattern")[Find the percent change in the fuel bill from 2022 to 2023.
#sol[
2022 fuel $= 0.30 times 48 = 14.4$ million THB.
2023 fuel $= 0.24 times 60 = 14.4$ million THB.
Change $= 14.4 - 14.4 = 0$.
]
#ans[No change, 0%]
]

#trap[
The fuel *share* dropped from 30% to 24%, a fall of 6 percentage points, and yet the fuel *bill* did not fall at all. A falling share only means the head grew slower than the total. It never by itself means the value fell.
]

#ex(25, tier: 2, asked: "SCB · pattern")[Find the percent change in wages.
#sol[
2022 wages $= 0.25 times 48 = 12$ million.
2023 wages $= 0.28 times 60$.
$0.28 times 60 = 16.8$ million.
Rise $= 16.8 - 12 = 4.8$.
$(4.8/12) times 100 = 0.4 times 100 = 40$.
]
#ans[$+40%$]
]

#ex(26, tier: 2, asked: "Agoda · pattern")[Which cost head grew the fastest in percent terms?
#sol[
Use the link rule. Total multiplier $M = 60/48 = 1.25$.
Part multiplier $= ("new share")/("old share") times M$.
Fuel: $(24/30) times 1.25 = 0.8 times 1.25 = 1.00 arrow.r 0%$.
Wages: $(28/25) times 1.25 = 1.12 times 1.25 = 1.40 arrow.r +40%$.
Lease: $(20/20) times 1.25 = 1 times 1.25 = 1.25 arrow.r +25%$.
Warehouse: $(16/15) times 1.25 = 1.0667 times 1.25 = 1.3333 arrow.r +33.33%$.
Admin: $(12/10) times 1.25 = 1.2 times 1.25 = 1.50 arrow.r +50%$.
Check one by hand: Admin 2022 $= 0.10 times 48 = 4.8$; 2023 $= 0.12 times 60 = 7.2$; $7.2/4.8 = 1.5$. Matches.
]
#ans[Admin, $+50%$]
]

#trick[
*The link rule is the whole of two-chart DI.*
$ "part multiplier" = ("new share")/("old share") times ("new total")/("old total") $
You never compute a single rupee value. Five growth rates in five one-line divisions.
]

#subsection[Data set 7 — bar chart with a line drawn over it]

#note[Bars: units shipped, in thousands. Line: cost per unit, in S\$.]

#table(columns: 3,
  [*Month*], [*Units ('000)*], [*Cost per unit (S\$)*],
  [Jul], [50], [8.00],
  [Aug], [60], [7.50],
  [Sep], [75], [7.20],
  [Oct], [80], [7.50],
)

#ex(27, tier: 2, asked: "Shopee · pattern")[Find the total cost each month. Which month cost the most, and what was the percent rise in total cost from July to October?
#sol[
Total cost $=$ units $times$ cost per unit, in thousands of S\$.
Jul: $50 times 8.00 = 400$.
Aug: $60 times 7.50 = 450$.
Sep: $75 times 7.20 = 75 times 7 + 75 times 0.2 = 525 + 15 = 540$.
Oct: $80 times 7.50 = 600$.
Highest is October at 600 thousand S\$.
Rise from July: $600 - 400 = 200$.
$(200/400) times 100 = 50$.
]
#ans[October, S\$600,000; a rise of 50% over July]
]

#ex(28, tier: 2, asked: "DBS · pattern")[Find the average cost per unit over the four months.
#sol[
An average *rate* is total value $div$ total quantity.
Total cost $= 400 + 450 = 850$; $850 + 540 = 1390$; $1390 + 600 = 1990$ (thousand S\$).
Total units $= 50 + 60 = 110$; $110 + 75 = 185$; $185 + 80 = 265$ (thousand).
Average $= 1990/265$.
$265 times 7 = 1855$. Remainder $1990 - 1855 = 135$.
$135/265 = 0.5094$.
So $1990/265 = 7.5094$.
]
#ans[About S\$7.51 per unit]
]

#trap[
The plain average of the four rates is $(8.00 + 7.50 + 7.20 + 7.50) div 4 = 30.20 div 4 = 7.55$. That is *wrong*. It treats July (50,000 units) as equally important as October (80,000 units). An average rate must always be total $div$ total.
]

#subsection[Data set 8 — a line chart of growth rates, not values]

#note[The line shows the percent growth of a fintech's revenue over the previous year. Revenue in 2019 was S\$40 million.]

#table(columns: 5,
  [*Year*], [2020], [2021], [2022], [2023],
  [*Growth over previous year*], [$+20%$], [$+25%$], [$-10%$], [$+30%$],
)

#ex(29, tier: 2, asked: "GIC · pattern")[(a) Find the revenue in each year. (b) In which year was revenue the highest before 2023? (c) Find the net percent change from 2019 to 2023.
#sol[
(a) Multiply the multipliers one year at a time.
2020: $40 times 1.20 = 48$.
2021: $48 times 1.25 = 48 + 48 times 0.25 = 48 + 12 = 60$.
2022: $60 times 0.90 = 54$.
2023: $54 times 1.30 = 54 + 54 times 0.30 = 54 + 16.2 = 70.2$.
(b) The values are 40, 48, 60, 54, 70.2. Before 2023 the highest is 60, in 2021.
(c) Net multiplier $= 70.2/40 = 1.755$.
$1.755 - 1 = 0.755 arrow.r +75.5%$.
Check by multiplying the rates: $1.20 times 1.25 = 1.50$; $1.50 times 0.90 = 1.35$; $1.35 times 1.30 = 1.755$. Matches.
]
#ans[(a) 48, 60, 54, 70.2 (S\$ million) #h(8pt) (b) 2021 #h(8pt) (c) $+75.5%$]
]

#trap[
The four plotted points are $+20$, $+25$, $-10$, $+30$. Read as a *value* line, 2022 looks like the worst year of the four and looks negative. Both readings are false. Revenue in 2022 was 54, which is above 2020's 48 and above 2019's 40. Revenue *rose* in 2020, 2021 and 2023 and fell only in 2022 — the one year the line dipped below zero. Check the axis label before you read a single point.
]

#practice(tier: 2, time: "100 s/Q")[
*Questions 1--5.* A logistics firm's markets.

#table(columns: 3,
  [*Market*], [*Orders ('000)*], [*Average order value (S\$)*],
  [Singapore], [120], [45],
  [Malaysia], [250], [28],
  [Thailand], [300], [22],
  [Vietnam], [180], [18],
  [Philippines], [200], [20],
)

+ Find the total value of goods sold across all five markets.
+ Which market produces the highest value, and how much?
+ Thailand's value is what percent of the total?
+ Find the overall average order value across all markets.
+ If Vietnam's orders grow 25% and its average order value rises to S\$20, find the percent rise in Vietnam's value.

*Questions 6--8.* A Thai retailer's revenue split.

#table(columns: 5,
  [*Division*], [Apparel], [Grocery], [Electronics], [Home],
  [*2022 (total THB~250 m)*], [36%], [28%], [20%], [16%],
  [*2023 (total THB~300 m)*], [30%], [30%], [24%], [16%],
)

+ Find the percent change in apparel revenue.
+ Find the percent change in electronics revenue.
+ Which division grew the fastest?

*Questions 9--11.* A bank's fee income grew as follows. Fee income in 2020 was S\$80 million.

#table(columns: 4,
  [*Year*], [2021], [2022], [2023],
  [*Growth over previous year*], [$+25%$], [$+20%$], [$-12.5%$],
)

+ Find the fee income in 2023.
+ Find the net percent change from 2020 to 2023.
+ In which year was fee income the highest?
]

#key[
+ *S\$26.24 million.* $120 times 45 = 5400$; $250 times 28 = 7000$; $300 times 22 = 6600$; $180 times 18 = 3240$; $200 times 20 = 4000$. Sum $= 26240$ thousand.
+ *Malaysia, S\$7.0 million.* Thailand has more orders but a lower value per order.
+ *About 25.15%.* $6600/26240$: 25% of 26240 is 6560; the extra 40 is $0.15%$ of 26240.
+ *About S\$24.99.* Total orders $= 120 + 250 + 300 + 180 + 200 = 1050$ thousand. $26240/1050$: $1050 times 25 = 26250$, which is 10 too high, and $10/1050 = 0.0095$, so $25 - 0.01 = 24.99$. The plain average of the five rates, $133 div 5 = 26.60$, is the wrong answer.
+ *About $+38.89%$.* Multiplier $= 1.25 times (20/18) = 1.25 times 1.1111 = 1.3889$. Values: $3240 arrow.r 225 times 20 = 4500$.
+ *0%.* $0.36 times 250 = 90$ and $0.30 times 300 = 90$. Link rule: $(30/36) times (300/250) = 0.8333 times 1.2 = 1.00$.
+ *$+44%$.* $(24/20) times 1.2 = 1.2 times 1.2 = 1.44$. Values: $50 arrow.r 72$.
+ *Electronics, $+44%$.* Grocery $(30/28) times 1.2 = 1.2857$ ($+28.57%$); Home $(16/16) times 1.2 = 1.2$ ($+20%$); Apparel 0%.
+ *S\$105 million.* $80 times 1.25 = 100$; $100 times 1.20 = 120$; $120 times 0.875 = 105$.
+ *$+31.25%$.* $105/80 = 1.3125$. Or $1.25 times 1.20 times 0.875 = 1.3125$.
+ *2022, at S\$120 million.* The growth line is still positive in 2022, so income kept rising that year; it fell only in 2023.
]

#section[Tier 3 — Product companies]
#tier-header(3)

#ex(30, tier: 3, asked: "Goldman Sachs · pattern")[Two firms report the regional split of their revenue.

#table(columns: 4,
  [*Firm*], [*Revenue*], [*Asia*], [*Europe*],
  [X], [S\$250 m], [30%], [26%],
  [Y], [S\$400 m], [20%], [35%],
)

(a) Whose Asia revenue is larger? (b) Taking the two firms together, what percent of combined revenue comes from Asia?

#sol[
*Insight: a percent is meaningless until you know what total it sits on. Convert to money first, then re-divide.*

(a) Firm X Asia $= 0.30 times 250 = 75$ million.
Firm Y Asia $= 0.20 times 400 = 80$ million.
So Y is larger, even though Y has the *smaller* Asia percentage.

(b) Combined Asia $= 75 + 80 = 155$ million.
Combined revenue $= 250 + 400 = 650$ million.
$(155/650) times 100$.
Anchor: $23%$ of $650 = 149.5$. Gap $= 155 - 149.5 = 5.5$.
$5.5/650 = 0.00846$, that is $0.846%$.
Share $= 23 + 0.846 = 23.846$.

Cross-check with the weighted-average form:
$(250 times 30 + 400 times 20)/650 = (7500 + 8000)/650 = 15500/650 = 23.846$. Matches.
]
#ans[(a) Firm Y, S\$80 m against S\$75 m #h(8pt) (b) About 23.85%]
]

#trap[
The plain average of 30% and 20% is 25%, and it is wrong. Percentages only average when the totals behind them are equal. Here Y is 1.6 times the size of X, so Y's 20% pulls the combined figure down towards 20, giving 23.85 rather than 25.
]

#ex(31, tier: 3, asked: "Google · pattern")[A region's share of a company's revenue fell from 25% to 22% in one year. For which total-growth rates $g$ did the region's own revenue still rise?

#sol[
*Insight: the part's multiplier is the share ratio times the total's multiplier. Ask when that product exceeds 1.*

Let last year's total be $T$ and this year's total be $T(1 + g/100)$.
Region last year $= 0.25 T$.
Region this year $= 0.22 times T(1 + g/100)$.
Region multiplier $m = (0.22 T (1 + g/100))/(0.25 T) = 0.88 (1 + g/100)$.
The region rose when $m > 1$:
$0.88 (1 + g/100) > 1$
$1 + g/100 > 1/0.88$
$1/0.88 = 100/88 = 25/22 = 1.136363...$
$g/100 > 0.136363...$
$g > 13.6363...$
As a fraction, $g > 13 7/11$ percent.
Check at $g = 20$: $m = 0.88 times 1.20 = 1.056$, a rise of $5.6%$. Yes.
Check at $g = 10$: $m = 0.88 times 1.10 = 0.968$, a fall of $3.2%$. Correct, no rise.
Check the boundary: at $1 + g/100 = 25/22$ we get $m = 0.88 times 25/22 = (22/25) times (25/22) = 1$ exactly, so the region is flat there. Just above it, the region grows.
]
#ans[$g > 13 7/11 %$, that is, above about 13.64%]
]

#trick[
Turn every share question into two multipliers and stop thinking about money.
$ "share ratio" times "total multiplier" = "part multiplier" $
The share ratio here is $22/25 = 0.88$. Any total growth that beats $1/0.88$ saves the region.
]

#ex(32, tier: 3, asked: "Amazon · pattern")[Three warehouses A, B and C shipped 84,000 parcels last month. This month A rose 20%, B fell 10%, C rose 25%, and the total rose to 95,600. Last month B shipped 4,000 more parcels than A. Find last month's figures for all three.

#sol[
*Insight: three unknowns, three facts. Write the total, the growth total and the link, then eliminate down to one letter.*

Let A, B, C be last month's parcels.
Fact 1: $A + B + C = 84000$.
Fact 2: $1.20 A + 0.90 B + 1.25 C = 95600$.
Fact 3: $B = A + 4000$.

Put Fact 3 into Fact 1:
$A + (A + 4000) + C = 84000$
$2A + C = 80000$
$C = 80000 - 2A$.

Put Fact 3 and this into Fact 2:
$1.20 A + 0.90(A + 4000) + 1.25(80000 - 2A) = 95600$
$1.20 A + 0.90 A + 3600 + 100000 - 2.50 A = 95600$
Collect the $A$ terms: $1.20 + 0.90 - 2.50 = -0.40$.
Collect the constants: $3600 + 100000 = 103600$.
$-0.40 A + 103600 = 95600$
$-0.40 A = -8000$
$A = 8000/0.40 = 20000$.
Then $B = 20000 + 4000 = 24000$.
Then $C = 80000 - 2 times 20000 = 40000$.

Check Fact 1: $20000 + 24000 + 40000 = 84000$. Correct.
Check Fact 2: $1.20 times 20000 = 24000$; $0.90 times 24000 = 21600$; $1.25 times 40000 = 50000$.
$24000 + 21600 = 45600$; $45600 + 50000 = 95600$. Correct.
]
#ans[A $=$ 20,000; B $=$ 24,000; C $=$ 40,000]
]

#ex(33, tier: 3, asked: "Microsoft · pattern")[A line chart gives an index of quarterly revenue with Q1 set to 100.

#table(columns: 5,
  [*Quarter*], [Q1], [Q2], [Q3], [Q4],
  [*Index*], [100], [115], [138], [120.75],
)

Actual Q3 revenue was Rs.~82.8 crore. Find (a) Q1 revenue, (b) the percent change from Q3 to Q4, (c) the total revenue for the year.

#sol[
*Insight: an index is the real series divided by a constant. So every ratio and every percent change can be read straight off the index, with no real numbers at all.*

(b) first, because it needs nothing else.
$(120.75 - 138)/138 = -17.25/138$.
$138 times 0.125 = 17.25$, so $17.25/138 = 0.125$.
Change $= -12.5%$.

(a) Index 138 corresponds to Rs.~82.8 crore, so 1 index point is $82.8/138$.
$138 times 0.6 = 82.8$, so $82.8/138 = 0.6$.
Q1 has index 100, so Q1 revenue $= 100 times 0.6 = 60$ crore.

(c) Multiply each index by 0.6.
Q2 $= 115 times 0.6 = 69$.
Q3 $= 138 times 0.6 = 82.8$. Matches the given value, so the scale is right.
Q4 $= 120.75 times 0.6 = 72.45$.
Total $= 60 + 69 = 129$; $129 + 82.8 = 211.8$; $211.8 + 72.45 = 284.25$.
]
#ans[(a) Rs.~60 crore #h(8pt) (b) $-12.5%$ #h(8pt) (c) Rs.~284.25 crore]
]

#ex(34, tier: 3, asked: "D. E. Shaw · pattern")[Five funds report their return and their fee for the year, both in thousands of S\$. Rank them by return per unit of fee, doing as little division as possible.

#table(columns: 6,
  [*Fund*], [P], [Q], [R], [S], [T],
  [*Return*], [840], [960], [1,150], [1,344], [725],
  [*Fee*], [210], [256], [250], [336], [145],
)

#sol[
*Insight: you do not need the value of a ratio to rank ratios. You only need to know which side of a round benchmark each one falls on.*

Try the benchmark 4.
P: $4 times 210 = 840$. Return is exactly 840, so P $= 4.0$.
Q: $4 times 256 = 1024$. Return is 960, which is less, so Q $< 4$.
Fine-tune Q: $3.75 times 256 = 960$ exactly, so Q $= 3.75$.
R: $4 times 250 = 1000$. Return is 1,150, which is more, so R $> 4$.
Fine-tune R: $4.6 times 250 = 1150$, so R $= 4.6$.
S: $4 times 336 = 1344$. Return is exactly 1,344, so S $= 4.0$.
T: $4 times 145 = 580$. Return is 725, much more, so T $> 4$.
Fine-tune T: $5 times 145 = 725$, so T $= 5.0$.

Ranking: T (5.0) $>$ R (4.6) $>$ P $=$ S (4.0) $>$ Q (3.75).
]
#ans[T is best, then R, then P and S tied, then Q]
]

#trick[
Never compute a ratio you only have to *compare*. Multiply the denominator by a round number and see which side the numerator falls. Two multiplications beat one long division, and they are exact.
]

#ex(35, tier: 3, asked: "Uber · pattern")[A bar chart groups a week's drivers by earnings band.

#table(columns: 6,
  [*Band (S\$)*], [0--200], [200--400], [400--600], [600--800], [800--1000],
  [*Drivers*], [120], [260], [340], [180], [100],
)

(a) How many drivers are there? (b) What is the largest the total weekly payout could be? (c) What is the smallest the average earning per driver could be? (d) Give the usual midpoint estimate of the average.

#sol[
*Insight: grouped data does not give you a number. It gives you an interval. Push every driver to the top of the band for the maximum, to the bottom for the minimum.*

(a) $120 + 260 = 380$; $380 + 340 = 720$; $720 + 180 = 900$; $900 + 100 = 1000$ drivers.

(b) Put every driver at the top of the band.
$120 times 200 = 24000$.
$260 times 400 = 104000$.
$340 times 600 = 204000$.
$180 times 800 = 144000$.
$100 times 1000 = 100000$.
Sum: $24000 + 104000 = 128000$; $+204000 = 332000$; $+144000 = 476000$; $+100000 = 576000$.

(c) Put every driver at the bottom of the band.
$120 times 0 = 0$.
$260 times 200 = 52000$.
$340 times 400 = 136000$.
$180 times 600 = 108000$.
$100 times 800 = 80000$.
Sum: $0 + 52000 = 52000$; $+136000 = 188000$; $+108000 = 296000$; $+80000 = 376000$.
Smallest possible average $= 376000/1000 = 376$.

(d) Midpoints are 100, 300, 500, 700, 900.
$120 times 100 = 12000$; $260 times 300 = 78000$; $340 times 500 = 170000$; $180 times 700 = 126000$; $100 times 900 = 90000$.
Sum: $12000 + 78000 = 90000$; $+170000 = 260000$; $+126000 = 386000$; $+90000 = 476000$.
Estimate $= 476000/1000 = 476$.
]
#ans[(a) 1,000 #h(6pt) (b) S\$576,000 #h(6pt) (c) S\$376 #h(6pt) (d) about S\$476]
]

#trap[
A grouped bar chart can never give an exact mean. Here the true average lies anywhere from S\$376 to S\$576. If a question asks for "the average" from grouped bands, it wants the midpoint estimate — and the honest answer is a range.
]

#ex(36, tier: 3, asked: "Adobe · pattern")[A media firm's 2023 revenue of Rs.~480 crore was split Subscriptions 45%, Ads 30%, Licensing 25%. In 2024 subscriptions grew 20%, ads fell 10%, and licensing grew 8%.

Find (a) the 2024 total, (b) the overall growth rate, (c) the 2024 share of each stream, (d) the change in the subscriptions share in percentage points.

#sol[
*Insight: the total's growth is the weighted average of the parts' growths, with last year's shares as the weights. Compute that first — it checks all the rest.*

(b) Weighted growth $= 0.45 times 20 + 0.30 times (-10) + 0.25 times 8$.
$0.45 times 20 = 9$.
$0.30 times (-10) = -3$.
$0.25 times 8 = 2$.
$9 - 3 + 2 = 8$. So the total grew 8%.

(a) 2024 total $= 480 times 1.08 = 480 + 480 times 0.08 = 480 + 38.4 = 518.4$ crore.

(c) 2023 values: Subscriptions $= 0.45 times 480 = 216$; Ads $= 0.30 times 480 = 144$; Licensing $= 0.25 times 480 = 120$. Check: $216 + 144 + 120 = 480$.
2024 values:
Subscriptions $= 216 times 1.20 = 216 + 43.2 = 259.2$.
Ads $= 144 times 0.90 = 129.6$.
Licensing $= 120 times 1.08 = 120 + 9.6 = 129.6$.
Check the total: $259.2 + 129.6 = 388.8$; $388.8 + 129.6 = 518.4$. Matches part (a).
Shares:
Subscriptions $= 259.2/518.4 = 0.50 arrow.r 50%$ (because $518.4 times 0.5 = 259.2$).
Ads $= 129.6/518.4 = 0.25 arrow.r 25%$ (because $518.4 times 0.25 = 129.6$).
Licensing $= 129.6/518.4 = 25%$.
Check: $50 + 25 + 25 = 100$.

(d) $50 - 45 = 5$, so the subscriptions share rose by 5 percentage points.
]
#ans[(a) Rs.~518.4 crore #h(6pt) (b) $+8%$ #h(6pt) (c) 50%, 25%, 25% #h(6pt) (d) up 5 percentage points]
]

#trap[
"Rose by 5 percentage points" and "rose by 5 percent" are different sentences. The share went from 45 to 50, which is 5 *percentage points* but $(5/45) times 100 = 11.1$ *percent*. Use the phrase the question uses.
]

#practice(tier: 3, time: "4 min/Q")[
+ A product's share of a firm's sales fell from 40% to 36%, while total sales rose 15%. Find the percent change in that product's sales.
+ Firm A earns Rs.~600 crore with 25% from exports. Firm B earns Rs.~900 crore with 40% from exports. Taking both firms together, what percent of revenue comes from exports?
+ A bar chart groups delivery riders by orders completed: 0--10: 30 riders; 10--20: 50 riders; 20--30: 80 riders; 30--40: 40 riders. Find the smallest and the largest possible mean number of orders per rider.
+ Two branches together sold 1,80,000 units last year. This year branch P rose 15%, branch Q fell 5%, and the combined total rose to 1,94,000. Find last year's figures for P and Q.
+ An index of monthly output has January $=$ 100 and April $=$ 132. February's index was 120 and February's output was 4,500 units. Find April's output and the percent rise from February to April.
+ Rank these four firms by revenue per employee: A, Rs.~96 crore with 1,200 staff; B, Rs.~105 crore with 1,400 staff; C, Rs.~130 crore with 1,300 staff; D, Rs.~84 crore with 1,050 staff.
+ A firm's 2023 revenue of Rs.~800 crore was 50% India, 30% SE Asia, 20% Europe. In 2024 India grew 12%, SE Asia grew 25%, Europe fell 5%. Find the overall growth rate and SE Asia's 2024 share.
]

#key[
+ *$+3.5%$.* Part multiplier $= ("new share")/("old share") times ("total multiplier") = (36/40) times 1.15 = 0.90 times 1.15 = 1.035$. The share fell by 4 percentage points and the product still grew, because 15% growth beats the $1/0.9 = 11.1%$ needed to stay level.
+ *34%.* Exports: $0.25 times 600 = 150$ and $0.40 times 900 = 360$, so $150 + 360 = 510$. Combined revenue $= 1500$. $510/1500 = 0.34$. Averaging 25 and 40 to get 32.5 is wrong, because B is the larger firm and pulls the answer up.
+ *Smallest 16.5, largest 26.5.* Total riders $= 30 + 50 + 80 + 40 = 200$. Bottom of each band: $0 + 500 + 1600 + 1200 = 3300$, and $3300/200 = 16.5$. Top of each band: $300 + 1000 + 2400 + 1600 = 5300$, and $5300/200 = 26.5$. Grouped data gives a range, never a single mean.
+ *P $=$ 1,15,000 and Q $=$ 65,000.* From $P + Q = 180000$ and $1.15 P + 0.95 Q = 194000$: substitute $Q = 180000 - P$ to get $1.15 P + 171000 - 0.95 P = 194000$, so $0.20 P = 23000$ and $P = 115000$. Check: $1.15 times 115000 = 132250$ and $0.95 times 65000 = 61750$; together 1,94,000.
+ *4,950 units; a rise of 10%.* One index point $= 4500/120 = 37.5$ units. April $= 132 times 37.5 = 4950$. Percent rise $= (132 - 120)/120 = 12/120 = 10%$. You never needed January's actual output.
+ *C $>$ A $=$ D $>$ B.* $96/1200 = 0.08$; $105/1400 = 0.075$; $130/1300 = 0.10$; $84/1050 = 0.08$ (all in crore per employee, i.e. 8, 7.5, 10 and 8 lakh). Benchmark test: is revenue more than $0.08 times$ staff? For C, $0.08 times 1300 = 104 < 130$, so C is above; for B, $0.08 times 1400 = 112 > 105$, so B is below.
+ *$+12.5%$ overall; SE Asia is $33 1/3 %$ of 2024 revenue.* Weighted growth $= 0.5 times 12 + 0.3 times 25 + 0.2 times (-5) = 6 + 7.5 - 1 = 12.5$. Values: India $400 arrow.r 448$, SE Asia $240 arrow.r 300$, Europe $160 arrow.r 152$, total $900$. Share $= 300/900 = 1/3$.
]

#section[Mixed set — exam conditions]

#practice(tier: 1, time: "90 s/Q · 18 questions in 27 minutes")[
*Questions 1--6.* Enrolment at four coaching centres.

#table(columns: 3,
  [*Centre*], [*2022*], [*2023*],
  [P], [600], [750],
  [Q], [900], [810],
  [R], [500], [600],
  [S], [700], [840],
)

+ Find the total 2023 enrolment.
+ Find the percent change for centre Q.
+ Which centre had the highest percent growth?
+ Find the ratio of S to R in 2023.
+ P's 2023 enrolment is what percent of the 2023 total?
+ Find the overall percent growth in total enrolment.

*Questions 7--11.* A city uses 7,500 MW of power, split as below.

#table(columns: 6,
  [*Sector*], [Industry], [Households], [Commercial], [Transport], [Others],
  [*Share*], [34%], [28%], [20%], [10%], [8%],
)

+ How many MW go to Commercial?
+ Find the central angle of the Households sector.
+ Industry uses how many percent more than Commercial?
+ Industry and Households together use how many MW?
+ Next year total use grows 20% to 9,000 MW and Transport's share rises to 12%. Find the percent rise in Transport's MW.

*Questions 12--15.* Quarterly revenue of a SaaS firm, in thousands of S\$.

#table(columns: 5,
  [*Quarter*], [Q1], [Q2], [Q3], [Q4],
  [*Revenue*], [400], [460], [552], [496.8],
)

+ Find the percent change from Q2 to Q3.
+ Find the percent change from Q1 to Q4.
+ Find the total revenue for the year.
+ Find the average quarterly revenue.

*Questions 16--18.*

+ A region's share of a firm's sales fell from 30% to 27% while total sales rose 25%. Find the percent change in that region's sales.
+ Firm X earns Rs.~500 crore with 20% from services. Firm Y earns Rs.~300 crore with 40% from services. Find the combined services share.
+ Express 4,853 as a percent of 19,720, to the nearest whole percent.
]

#key[
+ *3,000.* $750 + 810 = 1560$; $1560 + 600 = 2160$; $2160 + 840 = 3000$.
+ *$-10%$.* $810/900 = 0.90$.
+ *P, $+25%$.* $750/600 = 1.25$; $600/500 = 1.20$; $840/700 = 1.20$; Q fell.
+ *$7 : 5$.* $840 : 600$; divide both by 120.
+ *25%.* $750/3000 = 1/4$.
+ *$11 1/9 %$.* 2022 total $= 600 + 900 + 500 + 700 = 2700$. $3000/2700 = 10/9 = 1.1111$.
+ *1,500 MW.* $1%$ of $7500 = 75$, so $20 times 75 = 1500$.
+ *$100.8 degree$.* $28 times 3.6 = 100.8$.
+ *70%.* Same pie, so compare shares: $(34 - 20)/20 = 14/20 = 0.70$.
+ *4,650 MW.* $34 + 28 = 62%$, and $62 times 75 = 4650$.
+ *$+44%$.* Link rule: $(12/10) times 1.20 = 1.2 times 1.2 = 1.44$. Values: $750 arrow.r 1080$.
+ *$+20%$.* $552/460 = 1.20$.
+ *$+24.2%$.* $496.8/400 = 1.242$. Or chain the quarters: $1.15 times 1.20 times 0.90 = 1.242$.
+ *1,908.8 thousand S\$.* $400 + 460 = 860$; $860 + 552 = 1412$; $1412 + 496.8 = 1908.8$.
+ *477.2 thousand S\$.* $1908.8 div 4 = 477.2$.
+ *$+12.5%$.* $(27/30) times 1.25 = 0.90 times 1.25 = 1.125$. The share fell and the sales still rose.
+ *27.5%.* Services $= 0.20 times 500 + 0.40 times 300 = 100 + 120 = 220$; total $= 800$; $220/800 = 0.275$. Averaging 20 and 40 to get 30 is the trap.
+ *25%.* $19720 times 0.25 = 4930$; 4,853 is 77 short, and $77/19720 approx 0.39%$, so the true value is $24.61%$, which rounds to 25%. Note that rounding 19,720 up to 20,000 *before* dividing would give $4853/20000 = 24.3%$ — round the answer, never the base.
]

#revision[

*The four moves.* Add a row or column · take a percent · take a ratio · compare two numbers. Nothing else happens in DI.

*Percent change* $= ("new" - "old")/"old" times 100$. Faster: compute new $div$ old and read the multiplier. $1.32 arrow.r +32%$. $0.88 arrow.r -12%$.

*Share of total* $= "part"/"total" times 100$.

*Pie.* value $= ("percent"/100) times$ total · angle $= "percent" times 3.6$ · percent $= "angle" div 3.6$.
Anchors: $1% = 3.6 degree$ · $10% = 36 degree$ · $25% = 90 degree$ · $50% = 180 degree$.

*Two sectors of the SAME pie:* compare the percents directly, skip the values. Two sectors of *different* pies: you must convert to real values first.

*The link rule (two charts).*
$ "part multiplier" = ("new share")/("old share") times ("new total")/("old total") $
A share can fall while the value rises. Share $times 0.9$ needs total growth above $1/0.9 = 11.1%$ to break even.

*Weighted growth.* Total growth $= w_1 g_1 + w_2 g_2 + dots$, weights $=$ the *old* shares.
Combining two firms' percentages means weighting by their *sizes*, never a plain average.

*Average rate.* $"total value"/"total quantity"$. Never the plain average of the rates.

*Index numbers.* Any two index values divide exactly like the real values. Percent changes need no real number at all. One index point $= ("known value")/("its index")$.

*Grouped bars.* You get a range, not a mean. Bottom of every band gives the minimum; top of every band gives the maximum; midpoints give the usual estimate.

*Approximation.* Anchor on $10%$ of the base, then adjust. Round the *answer*, never the base. Compare ratios by cross-multiplying, not by dividing.

*Top 5 traps.*
+ *Wrong base.* Percent change always divides by the old value. "A is x% more than B" divides by B.
+ *Absolute versus percent.* The biggest rise in units is often not the biggest rise in percent. Two different questions.
+ *A falling share is not a falling value.* Check the total's growth before you say anything fell.
+ *Averaging percentages.* Only legal when the totals behind them are equal. Otherwise weight by size — this kills the "average of two firms' margins" question every time.
+ *Line-chart type.* A line of growth rates is not a line of values. Revenue keeps rising while a growth line falls, as long as the line stays above zero.
]

]
