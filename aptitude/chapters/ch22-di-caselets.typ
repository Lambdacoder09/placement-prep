#import "../lib/style.typ": *

#chapter(num: 22, title: "Data Interpretation: Caselets, Mixed & Missing Data", tagline: "Turn the paragraph into a grid, then fill the blanks")[

#section[What you need to know]

#formulas[

*Caselet method — do this every time, before reading any question.*
+ Read the paragraph once and write down the *grand total*.
+ Draw a tree or a small table. One branch per split.
+ Fill every box in absolute numbers, not percentages.
+ Add a check line: the boxes must add back to the grand total.
+ Only now read the questions. They will all be one look-up each.

*Watch the base.* "30% of the rest", "half of those who failed", "two-thirds of the remainder" — each phrase takes a *new* base. Write down which box the percent sits on before you multiply.

*Two-set Venn.*
- $n(A union B) = n(A) + n(B) - n(A inter B)$
- neither $= "total" - n(A union B)$
- only $A = n(A) - n(A inter B)$
- exactly one $= n(A union B) - n(A inter B)$

*Three-set Venn.*
$ n(A union B union C) = n(A) + n(B) + n(C) - n(A inter B) - n(B inter C) - n(A inter C) + n(A inter B inter C) $
With $x = n(A inter B inter C)$:
- exactly two $= [n(A inter B) - x] + [n(B inter C) - x] + [n(A inter C) - x]$
- exactly one $= n(A union B union C) - ("exactly two") - x$
- only $A = n(A) - n(A inter B) - n(A inter C) + x$

*Venn bounds (when the overlap is not given).*
- largest possible $n(A inter B) = min(n(A), n(B))$
- smallest possible $n(A inter B) = n(A) + n(B) - "total"$ (or 0 if that is negative)
- smallest possible $n(A inter B inter C) = n(A) + n(B) + n(C) - 2 times "total"$ (or 0 if negative)

*Missing-value grid.*
- Every row adds to its row total. Every column adds to its column total. The row totals and the column totals both add to the same grand total.
- *Find a row or column with exactly one blank, and fill it.* Every fill creates a new such row or column. Repeat until done.
- Always cross-check the grand total both ways at the end.

*Averages hide totals.* "The average of $n$ items is $a$" means $"sum" = n a$. Convert every average into a sum before you do anything else.

*Radar chart.* One axis per attribute, all on the same scale. Read each axis as a separate number. The *total score* is the sum of the axis values. Never compare the visual area.

*Bubble chart.* $x$-axis, $y$-axis, and bubble *size* is a third variable. Three numbers per bubble. A big bubble far left is not a big $x$.

*Combining two groups' percent changes.*
$ "combined % change" = (w_1 g_1 + w_2 g_2)/(w_1 + w_2) $
where $w_1, w_2$ are the *old* sizes. Never the plain average of $g_1$ and $g_2$.

*Ratio splits.* To split $T$ in the ratio $a : b : c$, one part $= T/(a+b+c)$, then multiply.
]

#section[Warm-up]
#tier-header(0)

#note[Warm-ups 1--3 use this: in a class of 120, 60 play cricket, 45 play football, 20 play both.]

#ex(1, tier: 0)[How many play at least one game?
#sol[
$n(C union F) = 60 + 45 - 20$.
$60 + 45 = 105$.
$105 - 20 = 85$.
]
#ans[85]
]

#ex(2, tier: 0)[How many play neither game?
#sol[
$120 - 85 = 35$.
]
#ans[35]
]

#ex(3, tier: 0)[How many play only cricket?
#sol[
Only cricket $= 60 - 20 = 40$.
]
#ans[40]
]

#note[Warm-ups 4--5 use this grid. One entry per cell; the blanks are marked with a dash.]

#table(columns: 4,
  [], [*Mon*], [*Tue*], [*Total*],
  [*A*], [40], [—], [95],
  [*B*], [35], [50], [85],
  [*Total*], [75], [—], [180],
)

#ex(4, tier: 0)[Find A's Tuesday value.
#sol[
Row A: $40 + ? = 95$.
$? = 95 - 40 = 55$.
]
#ans[55]
]

#ex(5, tier: 0)[Find the Tuesday column total.
#sol[
Column Tue: $55 + 50 = 105$.
Check the grand total: $75 + 105 = 180$. Correct.
]
#ans[105]
]

#ex(6, tier: 0)[Given $n(A) = 30$, $n(B) = 25$, $n(C) = 20$, $n(A inter B) = 10$, $n(B inter C) = 8$, $n(A inter C) = 6$ and $n(A inter B inter C) = 3$, find $n(A union B union C)$.
#sol[
$30 + 25 + 20 = 75$.
$10 + 8 + 6 = 24$.
$75 - 24 = 51$.
$51 + 3 = 54$.
]
#ans[54]
]

#ex(7, tier: 0)[Split 720 in the ratio $5 : 4$.
#sol[
Total parts $= 5 + 4 = 9$.
One part $= 720 div 9 = 80$.
First share $= 5 times 80 = 400$.
Second share $= 4 times 80 = 320$.
Check: $400 + 320 = 720$.
]
#ans[400 and 320]
]

#ex(8, tier: 0)[A radar chart scores a phone out of 10 on five axes: Speed 8, Price 6, Design 7, Support 5, Battery 9. Find the total and the average score.
#sol[
$8 + 6 = 14$.
$14 + 7 = 21$.
$21 + 5 = 26$.
$26 + 9 = 35$.
Average $= 35 div 5 = 7$.
]
#ans[Total 35, average 7]
]

#section[Tier 1 — Service companies]
#tier-header(1)

#subsection[Caselet 1]

#note[A bookstore sold 1,800 books in a week. 40% of them were fiction. Of the fiction books, 25% were hardcover. Of the non-fiction books, 30% were hardcover.]

#ex(9, tier: 1, asked: "TCS NQT pattern")[How many non-fiction books were sold?
#sol[
Fiction $= 40%$ of $1800 = 0.40 times 1800 = 720$.
Non-fiction $= 1800 - 720 = 1080$.
]
#ans[1,080 books]
]

#trick[
Build the full grid *once*, then answer every question by looking it up.

#table(columns: 4,
  [], [*Hardcover*], [*Paperback*], [*Total*],
  [*Fiction*], [180], [540], [720],
  [*Non-fiction*], [324], [756], [1,080],
  [*Total*], [504], [1,296], [1,800],
)

Fiction hardcover $= 0.25 times 720 = 180$, so paperback $= 720 - 180 = 540$.
Non-fiction hardcover $= 0.30 times 1080 = 324$, so paperback $= 1080 - 324 = 756$.
Check: $180 + 324 = 504$, $540 + 756 = 1296$, and $504 + 1296 = 1800$. The grid is consistent.
]

#ex(10, tier: 1, asked: "Infosys pattern")[How many hardcover books were sold in all?
#sol[
Fiction hardcover $= 0.25 times 720$.
$720 div 4 = 180$.
Non-fiction hardcover $= 0.30 times 1080$.
$1080 times 0.3 = 324$.
Total $= 180 + 324 = 504$.
]
#ans[504 books]
]

#ex(11, tier: 1, asked: "Accenture pattern")[Hardcover books are what percent of all books sold?
#sol[
$(504/1800) times 100$.
$504/1800$: divide both by 18, giving $28/100$.
$28/100 = 0.28$, so $28%$.
]
#ans[28%]
]

#trap[
Do not average the two hardcover rates. $(25 + 30) div 2 = 27.5%$, which is *not* the answer. The two groups are different sizes: non-fiction is 1,080 books against fiction's 720, so the 30% rate carries more weight and pulls the answer up to 28%.
]

#ex(12, tier: 1, asked: "Wipro pattern")[Find the ratio of fiction paperbacks to non-fiction paperbacks.
#sol[
$540 : 756$.
Divide both by 4: $135 : 189$.
Divide both by 27: $135 div 27 = 5$ and $189 div 27 = 7$.
Check: $5 times 108 = 540$ and $7 times 108 = 756$. Correct.
]
#ans[$5 : 7$]
]

#subsection[Venn data set]

#note[In a survey of 500 commuters: 260 use the metro, 210 use a bus, 180 use a cab. 90 use both metro and bus, 70 use both bus and cab, 80 use both metro and cab, and 40 use all three.]

#ex(13, tier: 1, asked: "Capgemini pattern")[How many commuters use none of the three?
#sol[
$n(M union B union C) = 260 + 210 + 180 - 90 - 70 - 80 + 40$.
Add the singles: $260 + 210 = 470$; $470 + 180 = 650$.
Add the pairs: $90 + 70 = 160$; $160 + 80 = 240$.
$650 - 240 = 410$.
$410 + 40 = 450$.
None $= 500 - 450 = 50$.
]
#ans[50 commuters]
]

#ex(14, tier: 1, asked: "TCS NQT pattern")[How many use only the metro?
#sol[
Only metro $= n(M) - n(M inter B) - n(M inter C) + n(M inter B inter C)$.
$= 260 - 90 - 80 + 40$.
$260 - 90 = 170$.
$170 - 80 = 90$.
$90 + 40 = 130$.
]
#ans[130 commuters]
]

#trick[
*Fill the Venn from the centre outwards and you never need a formula again.*
Centre (all three) $= 40$.
Metro-and-bus only $= 90 - 40 = 50$. Bus-and-cab only $= 70 - 40 = 30$. Metro-and-cab only $= 80 - 40 = 40$.
Metro only $= 260 - 50 - 40 - 40 = 130$.
Bus only $= 210 - 50 - 30 - 40 = 90$.
Cab only $= 180 - 30 - 40 - 40 = 70$.
Now all seven regions are known: $130 + 90 + 70 + 50 + 30 + 40 + 40 = 450$, so 50 use none. Every question is a sum of regions.
]

#ex(15, tier: 1, asked: "Cognizant pattern")[How many use exactly two of the three modes?
#sol[
From the filled diagram, the three "exactly two" regions are
metro-and-bus only $= 90 - 40 = 50$,
bus-and-cab only $= 70 - 40 = 30$,
metro-and-cab only $= 80 - 40 = 40$.
$50 + 30 = 80$.
$80 + 40 = 120$.
]
#ans[120 commuters]
]

#trap[
"90 use both metro and bus" means 90 are in the overlap *including* the 40 who use all three. It does not mean 90 use exactly those two. Subtract the centre before you call a region "exactly two".
]

#subsection[Missing-value grid]

#note[Sales by branch and product, in Rs.~lakh. Dashes are missing.]

#table(columns: 5,
  [*Branch*], [*Product X*], [*Product Y*], [*Product Z*], [*Total*],
  [North], [120], [—], [90], [350],
  [South], [—], [160], [110], [420],
  [East], [100], [130], [—], [360],
  [*Total*], [370], [430], [—], [1,130],
)

#ex(16, tier: 1, asked: "Infosys pattern")[Find North's product Y sales and South's product X sales.
#sol[
Row North has exactly one blank.
$120 + ? + 90 = 350$
$210 + ? = 350$
$? = 350 - 210 = 140$.
Column X now has exactly one blank.
$120 + ? + 100 = 370$
$220 + ? = 370$
$? = 370 - 220 = 150$.
Check row South: $150 + 160 + 110 = 420$. Correct.
Check column Y: $140 + 160 + 130 = 430$. Correct.
]
#ans[North-Y $=$ 140, South-X $=$ 150]
]

#ex(17, tier: 1, asked: "Accenture pattern")[Find East's product Z sales and the product Z column total.
#sol[
Row East: $100 + 130 + ? = 360$.
$230 + ? = 360$, so $? = 130$.
Column Z: $90 + 110 + 130 = 330$.
Cross-check the grand total two ways.
By columns: $370 + 430 + 330 = 1130$.
By rows: $350 + 420 + 360 = 1130$.
Both agree.
]
#ans[East-Z $=$ 130; column Z total $=$ 330]
]

#trick[
Never solve a grid with algebra. Scan for the row or column that has *exactly one* dash and fill it by subtraction. Filling it always turns another line into a one-dash line. Three subtractions finish most grids.
]

#ex(18, tier: 1, asked: "Wipro pattern")[Product Y is what percent of total sales?
#sol[
$(430/1130) times 100$.
Anchor: $38%$ of $1130 = 1130 times 0.38 = 429.4$.
Gap $= 430 - 429.4 = 0.6$.
$0.6/1130 = 0.00053$, that is $0.053%$.
Share $= 38 + 0.053 = 38.053$.
]
#ans[About 38.05%]
]

#subsection[Radar and bubble charts]

#note[A radar chart scores two phones out of 10 on five axes.]

#table(columns: 6,
  [*Axis*], [Camera], [Battery], [Display], [Speed], [Price value],
  [*Phone A*], [8], [6], [9], [7], [5],
  [*Phone B*], [6], [9], [7], [8], [8],
)

#ex(19, tier: 1, asked: "Capgemini pattern")[Which phone has the higher total score, and by what percent?
#sol[
Phone A: $8 + 6 = 14$; $14 + 9 = 23$; $23 + 7 = 30$; $30 + 5 = 35$.
Phone B: $6 + 9 = 15$; $15 + 7 = 22$; $22 + 8 = 30$; $30 + 8 = 38$.
B is higher by $38 - 35 = 3$.
Base is A, which is 35.
$(3/35) times 100$.
$35 times 0.085 = 2.975$. Gap $= 3 - 2.975 = 0.025$, and $0.025/35 = 0.0007$.
So $3/35 = 0.08571$, that is $8.571%$.
]
#ans[Phone B, by about 8.57%]
]

#trap[
A radar chart looks like a shape, and a bigger shape looks like a better product. Do not judge by area. Phone A's shape is wider on camera and display, but B wins on the sum. Read every axis as a number and add.
]

#note[A bubble chart of four ad campaigns. The $x$-axis is spend, the $y$-axis is leads, and the bubble size is the number of conversions.]

#table(columns: 4,
  [*Campaign*], [*Spend (Rs.~lakh)*], [*Leads ('00)*], [*Conversions*],
  [C1], [20], [15], [300],
  [C2], [35], [21], [420],
  [C3], [50], [40], [600],
  [C4], [25], [20], [500],
)

#ex(20, tier: 1, asked: "Cognizant pattern")[Which campaign has the lowest cost per conversion?
#sol[
Cost per conversion $= "spend in rupees" div "conversions"$. One lakh $= 100{,}000$.
C1: $20{,}00{,}000 div 300 = 6666.67$.
C2: $35{,}00{,}000 div 420 = 8333.33$.
C3: $50{,}00{,}000 div 600 = 8333.33$.
C4: $25{,}00{,}000 div 500 = 5000$.
The smallest is C4.
]
#ans[C4, at Rs.~5,000 per conversion]
]

#practice(tier: 1, time: "60 s/Q")[
*Questions 1--4.* A factory made 4,800 units last month. 35% failed the first quality check. Of those that failed, 60% were repaired and then passed; the rest were scrapped.

+ How many units failed the first check?
+ How many units were scrapped?
+ How many good units did the factory end up with?
+ Scrapped units are what percent of production?

*Questions 5--8.* Of 300 students, 180 study Python, 150 study Java, and 60 study both.

+ How many study at least one language?
+ How many study neither?
+ How many study only Python?
+ How many study only Java?

*Questions 9--12.* Staff on duty, by shift and day.

#table(columns: 5,
  [*Shift*], [*Mon*], [*Tue*], [*Wed*], [*Total*],
  [Morning], [45], [50], [—], [150],
  [Evening], [—], [40], [60], [135],
  [*Total*], [80], [90], [—], [285],
)

+ Find the morning shift's Wednesday figure.
+ Find the evening shift's Monday figure.
+ Find the Wednesday column total.
+ The morning shift is what percent of the whole week's total?

*Questions 13--14.* A radar chart scores three cities out of 10.

#table(columns: 4,
  [*Axis*], [*Bangkok*], [*Manila*], [*Hanoi*],
  [Cost], [7], [8], [9],
  [Talent], [8], [6], [5],
  [Infrastructure], [6], [5], [6],
  [Market], [9], [7], [6],
)

+ Which city has the highest total score?
+ Bangkok's total exceeds Manila's by what percent?
]

#key[
+ *1,680.* $0.35 times 4800 = 1680$.
+ *672.* Repaired $= 0.60 times 1680 = 1008$; scrapped $= 1680 - 1008 = 672$.
+ *4,128.* Passed first time $= 4800 - 1680 = 3120$; add the 1,008 repaired: $3120 + 1008 = 4128$.
+ *14%.* $(672/4800) times 100 = 14$. Note $0.35 times 0.40 = 0.14$ directly — 40% of the 35% that failed.
+ *270.* $180 + 150 - 60 = 270$.
+ *30.* $300 - 270 = 30$.
+ *120.* $180 - 60$.
+ *90.* $150 - 60$.
+ *55.* Row morning: $150 - 45 - 50 = 55$.
+ *35.* Column Mon: $80 - 45 = 35$. Check evening row: $35 + 40 + 60 = 135$. Correct.
+ *115.* $55 + 60 = 115$. Check: $80 + 90 + 115 = 285$. Correct.
+ *About 52.63%.* $(150/285) times 100$: $52%$ of 285 is 148.2, the gap 1.8 is $0.63%$ of 285, so $52.63$.
+ *Bangkok, 30.* Bangkok $= 7 + 8 + 6 + 9 = 30$; Manila $= 8 + 6 + 5 + 7 = 26$; Hanoi $= 9 + 5 + 6 + 6 = 26$.
+ *About 15.38%.* $(30 - 26)/26 = 4/26 = 0.1538$.
]

#section[Tier 2 — Singapore & Thailand]
#tier-header(2)

#subsection[Arithmetic-heavy caselet]

#note[A Bangkok cloud kitchen runs three brands. Last month it took 24,000 orders. Thai-Bowl took $3/8$ of them, Grill took $5/12$, and the rest went to Sweet. The average order values are THB~180, THB~220 and THB~150 in that order.]

#ex(21, tier: 2, asked: "LINE MAN · pattern")[Find each brand's revenue and the total revenue.
#sol[
Orders first.
Thai-Bowl $= 24000 times 3/8 = (24000 div 8) times 3 = 3000 times 3 = 9000$.
Grill $= 24000 times 5/12 = (24000 div 12) times 5 = 2000 times 5 = 10000$.
Sweet $= 24000 - 9000 - 10000 = 5000$.
Check: $9000 + 10000 + 5000 = 24000$. Correct.

Revenue next.
Thai-Bowl $= 9000 times 180 = 9 times 180 times 1000 = 1620 times 1000 = 1{,}620{,}000$.
Grill $= 10000 times 220 = 2{,}200{,}000$.
Sweet $= 5000 times 150 = 750{,}000$.
Total $= 1620000 + 2200000 = 3820000$; $3820000 + 750000 = 4570000$.
]
#ans[THB~1.62 million, THB~2.20 million and THB~0.75 million; total THB~4.57 million]
]

#ex(22, tier: 2, asked: "Grab · pattern")[Find the overall average order value.
#sol[
An average rate is total value $div$ total quantity.
$4{,}570{,}000 div 24{,}000$.
$24000 times 190 = 45{,}60{,}000$.
Remainder $= 4570000 - 4560000 = 10000$.
$10000/24000 = 0.4167$.
So the average is $190 + 0.4167 = 190.4167$.
]
#ans[About THB~190.42]
]

#trap[
The plain average of 180, 220 and 150 is $550 div 3 = 183.33$. That is wrong. Grill, the most expensive brand, also has the most orders, so it carries the most weight and drags the true average up to 190.42. Weight by order count, always.
]

#ex(23, tier: 2, asked: "Sea/Shopee · pattern")[Grill's revenue is what percent of the total?
#sol[
$(2{,}200{,}000 / 4{,}570{,}000) times 100$.
Cancel the zeros: $220/457$.
Anchor: $48%$ of $457 = 219.36$.
Gap $= 220 - 219.36 = 0.64$.
$0.64/457 = 0.0014$, that is $0.14%$.
Share $= 48 + 0.14 = 48.14$.
]
#ans[About 48.14%]
]

#subsection[Venn with an unknown centre]

#note[In a survey of 1,500 Singapore shoppers: 720 use GrabPay, 660 use PayNow, 480 use a credit card. 300 use GrabPay and PayNow, 180 use PayNow and card, 240 use GrabPay and card, and 270 use none of the three.]

#ex(24, tier: 2, asked: "DBS · pattern")[How many use all three?
#sol[
At least one $= 1500 - 270 = 1230$.
Let $x$ be the number using all three.
$1230 = 720 + 660 + 480 - 300 - 180 - 240 + x$.
Singles: $720 + 660 = 1380$; $1380 + 480 = 1860$.
Pairs: $300 + 180 = 480$; $480 + 240 = 720$.
$1860 - 720 = 1140$.
$1230 = 1140 + x$
$x = 1230 - 1140 = 90$.
]
#ans[90 shoppers]
]

#ex(25, tier: 2, asked: "Razer · pattern")[How many use exactly one of the three?
#sol[
Fill the diagram from the centre.
Centre $= 90$.
GrabPay and PayNow only $= 300 - 90 = 210$.
PayNow and card only $= 180 - 90 = 90$.
GrabPay and card only $= 240 - 90 = 150$.
Exactly two $= 210 + 90 + 150 = 450$.
Exactly one $= 1230 - 450 - 90 = 690$.

Check each "only" region separately.
GrabPay only $= 720 - 210 - 150 - 90 = 270$.
PayNow only $= 660 - 210 - 90 - 90 = 270$.
Card only $= 480 - 90 - 150 - 90 = 150$.
$270 + 270 + 150 = 690$. Matches.
]
#ans[690 shoppers]
]

#subsection[Missing grid with outside conditions]

#note[Shipments in thousands, by region and month. You are also told that February's total was 25% more than January's, and that the West region's three-month total was 310.]

#table(columns: 5,
  [*Region*], [*Jan*], [*Feb*], [*Mar*], [*Total*],
  [North], [60], [—], [90], [230],
  [West], [80], [100], [—], [310],
  [East], [60], [—], [70], [—],
  [*Total*], [—], [—], [—], [—],
)

#ex(26, tier: 2, asked: "Agoda · pattern")[Fill in every missing value.
#sol[
*Step 1 — January total.* All three January cells are known.
$60 + 80 + 60 = 200$.

*Step 2 — February total.* It is 25% more than January.
$200 times 1.25 = 250$.

*Step 3 — North in February.* Row North now has one blank.
$60 + ? + 90 = 230$
$150 + ? = 230$, so $? = 80$.

*Step 4 — East in February.* Column February now has one blank.
$80 + 100 + ? = 250$
$180 + ? = 250$, so $? = 70$.

*Step 5 — West in March.* Row West now has one blank.
$80 + 100 + ? = 310$
$180 + ? = 310$, so $? = 130$.

*Step 6 — East's row total.* $60 + 70 + 70 = 200$.

*Step 7 — March total.* $90 + 130 + 70 = 290$.

*Step 8 — grand total, both ways.*
By columns: $200 + 250 + 290 = 740$.
By rows: $230 + 310 + 200 = 740$. They agree, so the grid is right.

#table(columns: 5,
  [*Region*], [*Jan*], [*Feb*], [*Mar*], [*Total*],
  [North], [60], [*80*], [90], [230],
  [West], [80], [100], [*130*], [310],
  [East], [60], [*70*], [70], [*200*],
  [*Total*], [*200*], [*250*], [*290*], [*740*],
)
]
#ans[North-Feb 80, East-Feb 70, West-Mar 130; totals 200, 250, 290 and 740]
]

#ex(27, tier: 2, asked: "Shopee · pattern")[(a) Find the percent rise in total shipments from February to March. (b) Which region grew fastest from January to March?
#sol[
(a) Old $= 250$, new $= 290$.
Rise $= 290 - 250 = 40$.
$(40/250) times 100$.
$40/250 = 16/100 = 0.16$.
So $+16%$.

(b) Divide March by January for each region.
North: $90/60 = 1.5 arrow.r +50%$.
West: $130/80 = 1.625 arrow.r +62.5%$.
East: $70/60 = 1.1667 arrow.r +16.67%$.
]
#ans[(a) $+16%$ #h(8pt) (b) West, $+62.5%$]
]

#trick[
When a grid comes with a sentence outside it ("February was 25% more than January"), that sentence is usually the *first* thing you use. It converts one unknown total into a number, and that number unlocks a one-blank line.
]

#subsection[Bubble chart]

#note[Four rider-acquisition campaigns. $x$ is the spend, $y$ is new riders, and the bubble size is riders still active after 30 days.]

#table(columns: 4,
  [*Campaign*], [*Spend (S\$'000)*], [*New riders*], [*Retained*],
  [A], [40], [2,500], [750],
  [B], [60], [4,500], [1,350],
  [C], [75], [5,000], [1,250],
  [D], [50], [4,000], [1,600],
)

#ex(28, tier: 2, asked: "Grab · pattern")[Find each campaign's retention rate and its cost per retained rider. Which campaign is best?
#sol[
Retention rate $= "retained" div "new"$.
A: $750/2500 = 0.30 arrow.r 30%$.
B: $1350/4500 = 0.30 arrow.r 30%$.
C: $1250/5000 = 0.25 arrow.r 25%$.
D: $1600/4000 = 0.40 arrow.r 40%$.

Cost per retained rider $= "spend in S\$" div "retained"$.
A: $40000 div 750$. $750 times 53 = 39750$; remainder 250; $250/750 = 0.333$. So $53.33$.
B: $60000 div 1350$. $1350 times 44 = 59400$; remainder 600; $600/1350 = 0.444$. So $44.44$.
C: $75000 div 1250 = 60.00$ exactly, since $1250 times 60 = 75000$.
D: $50000 div 1600 = 31.25$ exactly, since $1600 times 31.25 = 50000$.
The lowest cost is D.
]
#ans[D is best: 40% retention at S\$31.25 per retained rider]
]

#trap[
C has the biggest $x$ (spend) and the biggest $y$ (new riders), so it sits top-right on the chart and looks like the winner. But its bubble is smaller than D's, and D spent S\$25,000 less. C has the worst retention of the four (25%) and the highest cost per retained rider (S\$60.00). The bubble is what pays. Always read all three numbers of a bubble before ranking.
]

#subsection[Comparing two data sources]

#note[A firm reports monthly active users two ways. A bar chart gives the total MAU in lakh: Jan 120, Feb 132, Mar 145.2. A table gives the Android share: Jan 75%, Feb 72%, Mar 70%.]

#ex(29, tier: 2, asked: "GIC · pattern")[Find the percent growth from January to March for (a) iOS users, (b) Android users.
#sol[
iOS share $= 100 - "Android share"$, so Jan 25%, Feb 28%, Mar 30%.

(a) iOS Jan $= 0.25 times 120 = 30$ lakh.
iOS Mar $= 0.30 times 145.2$.
$145.2 times 0.3 = 43.56$ lakh.
Rise $= 43.56 - 30 = 13.56$.
$(13.56/30) times 100 = 0.452 times 100 = 45.2$.
Link-rule check: $(30/25) times (145.2/120) = 1.2 times 1.21 = 1.452$. Matches.

(b) Android Jan $= 0.75 times 120 = 90$ lakh.
Android Mar $= 0.70 times 145.2 = 101.64$ lakh.
Rise $= 101.64 - 90 = 11.64$.
$(11.64/90) times 100$.
$11.64/90 = 0.129333$.
So $+12.93%$.
Link-rule check: $(70/75) times 1.21 = 0.93333 times 1.21 = 1.129333$. Matches.
]
#ans[(a) iOS $+45.2%$ #h(8pt) (b) Android about $+12.93%$]
]

#practice(tier: 2, time: "100 s/Q")[
*Questions 1--4.* A Singapore gym chain has 4,500 members. 40% are on the annual plan, 35% on the quarterly plan, and the rest on the monthly plan. Per month they pay S\$60, S\$75 and S\$95 respectively.

+ How many members are on the monthly plan?
+ Find the chain's total monthly revenue.
+ Find the average revenue per member per month.
+ The quarterly plan brings in what percent of revenue?

*Questions 5--8.* Of 800 trainees, 520 cleared the written test and 460 cleared the interview. 300 cleared both.

+ How many cleared at least one stage?
+ How many cleared neither?
+ How many cleared exactly one stage?
+ How many cleared only the interview?

*Questions 9--11.* Quarterly units sold by two stores.

#table(columns: 6,
  [*Store*], [*Q1*], [*Q2*], [*Q3*], [*Q4*], [*Total*],
  [A], [150], [—], [180], [200], [700],
  [B], [120], [140], [—], [190], [610],
  [*Total*], [270], [310], [340], [390], [1,310],
)

+ Find store A's Q2 figure.
+ Find store B's Q3 figure.
+ Find the percent rise in the combined total from Q1 to Q4.
]

#key[
+ *1,125.* Monthly plan share $= 100 - 40 - 35 = 25%$, and $0.25 times 4500 = 1125$.
+ *S\$333,000.* Annual $= 0.40 times 4500 = 1800$, quarterly $= 0.35 times 4500 = 1575$. Then $1800 times 60 = 108000$, $1575 times 75 = 118125$, $1125 times 95 = 106875$; sum $= 333000$.
+ *S\$74.* $333000 div 4500 = 74$, because $4500 times 74 = 333000$. The plain average of 60, 75 and 95 is $76.67$, which is wrong.
+ *About 35.47%.* $118125/333000$: 35% of 333,000 is 116,550; the gap 1,575 is $0.47%$ of 333,000.
+ *680.* $520 + 460 - 300 = 680$.
+ *120.* $800 - 680 = 120$.
+ *380.* $680 - 300 = 380$. Or $(520 - 300) + (460 - 300) = 220 + 160$.
+ *160.* $460 - 300 = 160$.
+ *170.* Column Q2: $310 - 140 = 170$. Check row A: $150 + 170 + 180 + 200 = 700$. Correct.
+ *160.* Column Q3: $340 - 180 = 160$. Check row B: $120 + 140 + 160 + 190 = 610$. Correct.
+ *About 44.44%.* $(390 - 270)/270 = 120/270 = 4/9 = 0.4444$.
]

#section[Tier 3 — Product companies]
#tier-header(3)

#ex(30, tier: 3, asked: "Google · pattern")[In a group of 200 people, 130 like tea and 110 like coffee. (a) Find the smallest and the largest possible number who like both. (b) If exactly 20 people like neither, find the number who like both.

#sol[
*Insight: the overlap is squeezed between two extremes — one set sitting entirely inside the other, and the two sets together just filling the group.*

(a) *Largest.* The overlap can never be bigger than the smaller set. Coffee has 110 people, so at most 110 like both. That happens when every coffee drinker also likes tea.
Check it is legal: then tea-only $= 130 - 110 = 20$ and coffee-only $= 0$, so the union is 130, which fits inside 200. Legal.

*Smallest.* Push the sets apart as far as the group allows.
$n(T union C) = 130 + 110 - n(T inter C) <= 200$
$240 - n(T inter C) <= 200$
$n(T inter C) >= 240 - 200 = 40$.
Check at 40: union $= 240 - 40 = 200$, exactly filling the group, so nobody likes neither. Legal.

(b) If 20 like neither, the union is fixed.
$n(T union C) = 200 - 20 = 180$.
$180 = 130 + 110 - n(T inter C)$
$180 = 240 - n(T inter C)$
$n(T inter C) = 240 - 180 = 60$.
The answer is now a single number, not a range, because knowing "neither" fixes the union.
]
#ans[(a) between 40 and 110 #h(8pt) (b) exactly 60]
]

#trick[
Read the pattern in part (a): $130 + 110 - 200 = 40$. *Sum of the sets minus the total* is the forced minimum overlap. If that number is negative, the minimum is simply 0.
]

#ex(31, tier: 3, asked: "Amazon · pattern")[Of 100 users, 80 use app A, 95 use app B and 90 use app C. Find the smallest possible number who use all three, and the largest.

#sol[
*Insight: count the people who are MISSING from each app. Somebody fails to use all three only if they are missing from at least one, so the misses are the budget.*

Missing from A $= 100 - 80 = 20$.
Missing from B $= 100 - 95 = 5$.
Missing from C $= 100 - 90 = 10$.
Total misses $= 20 + 5 + 10 = 35$.

Each person who does *not* use all three uses up at least one miss. So at most 35 people fail to use all three.
Users of all three $>= 100 - 35 = 65$.

Can 65 be reached? Only if no person is missing from two different apps, i.e. the three "missing" groups are disjoint. They need $20 + 5 + 10 = 35$ distinct people, and there are 100 people, so yes. Then exactly 35 people miss one app each, and $100 - 35 = 65$ use all three. So 65 is achievable.

*Largest.* All-three can never exceed the smallest set, which is A with 80.
Check 80 is legal: let every one of the 80 A-users use B and C too. Then B has 15 more users outside A and C has 10 more, all fine inside 100.
]
#ans[Smallest 65, largest 80]
]

#note[The same idea in formula form: minimum $n(A inter B inter C) = n(A) + n(B) + n(C) - 2 times "total"$, and here $80 + 95 + 90 - 200 = 65$. If it comes out negative, the minimum is 0.]

#ex(32, tier: 3, asked: "Goldman Sachs · pattern")[A revenue grid by region and product is almost blank. You are told: the grand total is Rs.~1,200 crore; the North region is 30% of the total; product P is 40% of the total; North's product-P revenue is one-third of North's total; South's product-Q revenue is Rs.~150 crore; and the East region's total is twice the South region's total.

Find every cell, and then find East's product-P revenue as a percent of all product-P revenue.

#sol[
*Insight: every sentence is one equation. Convert all of them to numbers first, put them into the grid, and only then start subtracting — the grid does the algebra for you.*

*Step 1 — the margins.*
North $= 0.30 times 1200 = 360$.
Product P total $= 0.40 times 1200 = 480$.
Product Q total $= 1200 - 480 = 720$.

*Step 2 — South and East.*
South $+$ East $= 1200 - 360 = 840$.
East $= 2 times$ South, so South $+ 2 times$ South $= 840$.
$3 times$ South $= 840$, so South $= 280$ and East $= 560$.

*Step 3 — North's row.*
North-P $= 360 div 3 = 120$.
North-Q $= 360 - 120 = 240$.

*Step 4 — South's row.*
South-Q $= 150$ (given).
South-P $= 280 - 150 = 130$.

*Step 5 — East's row, from the P column.*
$120 + 130 + "East-P" = 480$
$250 + "East-P" = 480$, so East-P $= 230$.
East-Q $= 560 - 230 = 330$.

*Step 6 — check the Q column.*
$240 + 150 + 330 = 720$. Correct.

#table(columns: 4,
  [*Region*], [*P*], [*Q*], [*Total*],
  [North], [120], [240], [360],
  [South], [130], [150], [280],
  [East], [230], [330], [560],
  [*Total*], [480], [720], [1,200],
)

*Step 7 — the percent asked.*
$(230/480) times 100$.
$480 times 0.47 = 225.6$. Gap $= 230 - 225.6 = 4.4$.
$4.4/480 = 0.00917$, that is $0.917%$.
Share $= 47 + 0.917 = 47.917$.
]
#ans[Grid as shown; East's P revenue is about 47.92% of all product-P revenue]
]

#ex(33, tier: 3, asked: "D. E. Shaw · pattern")[A fund reports that 60% of its assets returned 12% for the year, and the other 40% is split half in bonds and half in property. The fund's overall return was 9.6%, and the bonds returned 5%. Find the property return.

#sol[
*Insight: an overall return is a weighted average, and a weighted average can be peeled one layer at a time. Solve the outer layer first, then use its answer as the total for the inner layer.*

*Outer layer.* Let $r$ be the return on the whole 40% block.
$0.60 times 12 + 0.40 times r = 9.6$
$7.2 + 0.40 r = 9.6$
$0.40 r = 9.6 - 7.2 = 2.4$
$r = 2.4/0.40 = 6$.
So the 40% block returned 6%.

*Inner layer.* That block is half bonds (5%) and half property ($c$).
$0.5 times 5 + 0.5 times c = 6$
$2.5 + 0.5 c = 6$
$0.5 c = 3.5$
$c = 7$.

*Check from the top.* The three pieces are 60% at 12%, 20% at 5%, 20% at 7%.
$0.60 times 12 = 7.2$.
$0.20 times 5 = 1.0$.
$0.20 times 7 = 1.4$.
$7.2 + 1.0 + 1.4 = 9.6$. Correct.
]
#ans[Property returned 7%]
]

#ex(34, tier: 3, asked: "Microsoft · pattern")[A report says: "Our Bangkok store's sales rose 15% and our Chiang Mai store's sales rose 20%, so together we grew 17.5%." Last year Bangkok sold THB~30 million and Chiang Mai THB~10 million.

(a) Is the claim right? (b) What is the true combined growth? (c) For what split of last year's sales would 17.5% have been correct?

#sol[
*Insight: a combined percent change is a weighted average of the two changes, and the weights are LAST YEAR's sizes. A plain average is only right when the two sizes are equal.*

(a) and (b). Compute the real numbers.
Bangkok this year $= 30 times 1.15 = 30 + 4.5 = 34.5$.
Chiang Mai this year $= 10 times 1.20 = 12$.
Total last year $= 30 + 10 = 40$.
Total this year $= 34.5 + 12 = 46.5$.
Rise $= 46.5 - 40 = 6.5$.
$(6.5/40) times 100 = 0.1625 times 100 = 16.25$.
So the claim of 17.5% is too high. The truth is 16.25%.

Weighted-average check: $(30 times 15 + 10 times 20)/40 = (450 + 200)/40 = 650/40 = 16.25$. Matches.

(c) Let a fraction $w$ of last year's sales sit in Bangkok.
$15 w + 20(1 - w) = 17.5$
$15 w + 20 - 20 w = 17.5$
$-5 w = -2.5$
$w = 0.5$.
So 17.5% would be correct only if the two stores had been exactly equal in size last year. The report averaged the two rates as if that were true.
]
#ans[(a) No #h(8pt) (b) $+16.25%$ #h(8pt) (c) only a 50--50 split]
]

#trap[
This is the single most common error in mixed DI: averaging growth rates, margins, or pass percentages across groups of different sizes. Ask "different sizes?" before you ever average a percentage. If the sizes differ, weight by size.
]

#ex(35, tier: 3, asked: "Uber · pattern")[A bubble chart shows five city-launch options. The $x$-axis is the one-off setup cost and the bubble size is the expected monthly profit, both in thousands of S\$.

#table(columns: 6,
  [*City*], [V], [W], [X], [Y], [Z],
  [*Setup cost*], [40], [60], [50], [30], [70],
  [*Monthly profit*], [9], [15], [11], [6], [16],
)

The budget is S\$150,000 and you may launch any set of cities. Which set maximises the monthly profit?

#sol[
*Insight: the obvious move — rank by profit per S\$ of cost and take the best ones — is wrong here, because the budget must be spent as fully as possible. You have to check the subsets.*

First see why the greedy rule fails. Profit per unit cost:
V: $9/40 = 0.225$. W: $15/60 = 0.250$. X: $11/50 = 0.220$. Y: $6/30 = 0.200$. Z: $16/70 = 0.2286$.
Greedy takes W (0.250), then Z (0.2286): cost $60 + 70 = 130$, profit $15 + 16 = 31$. Only S\$20,000 is left and nothing costs that little. Greedy stops at 31.

Can four cities fit? The four cheapest cost $30 + 40 + 50 + 60 = 180 > 150$. No. So at most three cities.

List every three-city set with cost at most 150.
V W X: $40 + 60 + 50 = 150$; profit $9 + 15 + 11 = 35$.
V W Y: $40 + 60 + 30 = 130$; profit $9 + 15 + 6 = 30$.
V X Y: $40 + 50 + 30 = 120$; profit $9 + 11 + 6 = 26$.
V Y Z: $40 + 30 + 70 = 140$; profit $9 + 6 + 16 = 31$.
W X Y: $60 + 50 + 30 = 140$; profit $15 + 11 + 6 = 32$.
X Y Z: $50 + 30 + 70 = 150$; profit $11 + 6 + 16 = 33$.
Over budget and therefore dropped: V W Z (170), V X Z (160), W X Z (180), W Y Z (160).

The best is V, W, X at exactly S\$150,000 for S\$35,000 a month.
Two-city sets can only do worse: the best two are W and Z at 31.
]
#ans[Launch V, W and X: cost S\$150,000, profit S\$35,000 per month]
]

#trick[
Whenever a budget question has few items, do not reason — enumerate. With five items there are only ten three-item sets, and writing them out takes 60 seconds and cannot be wrong. Save cleverness for problems with no small list.
]

#ex(36, tier: 3, asked: "Adobe · pattern")[A table of monthly downloads, in thousands, has three smudged entries.

#table(columns: 7,
  [*Month*], [Jan], [Feb], [Mar], [Apr], [May], [Jun],
  [*Downloads*], [80], [—], [120], [—], [150], [—],
)

You are told the six-month average was 125, that February was 25% more than January, and that June was twice April. Find the three missing values, and the percent rise from May to June.

#sol[
*Insight: an average is a total wearing a disguise. Turn it into a sum on the first line, and the puzzle becomes ordinary arithmetic.*

*Step 1 — the sum.*
Average $times$ count $=$ sum.
$125 times 6 = 750$.

*Step 2 — February.*
$80 times 1.25 = 80 + 20 = 100$.

*Step 3 — what is left for April and June.*
Known so far: $80 + 100 + 120 + 150$.
$80 + 100 = 180$; $180 + 120 = 300$; $300 + 150 = 450$.
April $+$ June $= 750 - 450 = 300$.

*Step 4 — use the June condition.*
June $= 2 times$ April, so April $+ 2 times$ April $= 300$.
$3 times$ April $= 300$
April $= 100$, and June $= 200$.

*Step 5 — check.*
$80 + 100 + 120 + 100 + 150 + 200$.
$80 + 100 = 180$; $+120 = 300$; $+100 = 400$; $+150 = 550$; $+200 = 750$.
$750 div 6 = 125$. Correct.

*Step 6 — May to June.*
Rise $= 200 - 150 = 50$.
$(50/150) times 100 = (1/3) times 100 = 33.33$.
]
#ans[Feb 100, Apr 100, Jun 200 (thousand); May to June is $+33 1/3 %$]
]

#practice(tier: 3, time: "4 min/Q")[
+ In a group of 150 people, 95 own a bike and 80 own a car. Find the least and the greatest possible number who own both.
+ Of 120 employees, 100 know Excel, 95 know SQL and 90 know Python. Find the smallest possible number who know all three.
+ A revenue grid has two regions and two products and totals Rs.~900 crore. North is 40% of the total, product A is 55% of the total, and North's product-A revenue is Rs.~240 crore. Find South's product-B revenue.
+ Division P's costs rose 8% and division Q's rose 18%. A manager reports a 13% rise overall. Last year P spent Rs.~60 crore and Q spent Rs.~40 crore. Find the true rise and say what the manager did wrong.
+ Five weeks of sales average 620 units. Week 1 was 500, week 2 was 680, week 4 was 660, and week 5 was twice week 3. Find week 3 and week 5.
+ Four projects cost Rs.~25, 30, 40 and 45 lakh and return profits of Rs.~11, 13, 17 and 20 lakh respectively. With a budget of Rs.~70 lakh, which set gives the highest profit?
+ In a survey of 400 people, 55% read the Times, 45% read the Post and 20% read both. How many read neither?
]

#key[
+ *Least 25, greatest 80.* Least $= 95 + 80 - 150 = 25$; at 25 the union is exactly 150, filling the group. Greatest $= min(95, 80) = 80$; then every car owner also owns a bike, and the union is 95, which fits inside 150.
+ *45.* Misses are $120 - 100 = 20$, $120 - 95 = 25$, $120 - 90 = 30$, and $20 + 25 + 30 = 75$. At most 75 people can fail to know all three, so at least $120 - 75 = 45$ know all three. It is achievable because the 75 "missing" slots fit inside 120 people without overlapping.
+ *Rs.~285 crore.* North $= 0.40 times 900 = 360$, so South $= 540$. Product A $= 0.55 times 900 = 495$, so product B $= 405$. North-A $= 240$, so North-B $= 360 - 240 = 120$. South-B $= 405 - 120 = 285$. Check South-A $= 495 - 240 = 255$, and $255 + 285 = 540$. Correct.
+ *The true rise is 12%; the manager averaged the two rates.* Weighted: $(60 times 8 + 40 times 18)/100 = (480 + 720)/100 = 12$. Values: $60 times 1.08 = 64.8$ and $40 times 1.18 = 47.2$, so $112$ against $100$. The plain average $(8 + 18) div 2 = 13$ would be right only if the two divisions had spent equally.
+ *Week 3 $=$ 420, week 5 $=$ 840.* Sum $= 620 times 5 = 3100$. Known $= 500 + 680 + 660 = 1840$. So week 3 $+$ week 5 $= 1260$, and since week 5 $= 2 times$ week 3, $3 times$ week 3 $= 1260$. Check: $500 + 680 + 420 + 660 + 840 = 3100$.
+ *Take the Rs.~25 lakh and Rs.~45 lakh projects, for Rs.~31 lakh profit.* Sets within budget: $(25, 45)$ costs 70 and yields $11 + 20 = 31$; $(30, 40)$ costs 70 and yields $13 + 17 = 30$; $(25, 40)$ costs 65 and yields 28; $(25, 30)$ costs 55 and yields 24; no three projects fit, since the cheapest three cost $25 + 30 + 40 = 95$. So 31 is the best.
+ *80 people.* At least one $= 55 + 45 - 20 = 80%$, so neither $= 20%$, and $0.20 times 400 = 80$. Working in percentages first and converting once at the end saves three multiplications.
]

#section[Mixed set — exam conditions]

#practice(tier: 1, time: "90 s/Q · 18 questions in 27 minutes")[
*Questions 1--4.* A hospital saw 3,600 patients in a month. 45% went to the OPD, 30% to emergency, and the rest were admitted. Of the admitted patients, 25% needed surgery.

+ How many patients were admitted?
+ How many needed surgery?
+ Surgery patients are what percent of all patients?
+ Find the ratio of OPD patients to emergency patients.

*Questions 5--8.* Of 500 job applicants, 280 passed the written test and 220 passed the interview. 150 passed both.

+ How many passed at least one stage?
+ How many passed neither?
+ How many passed only the interview?
+ How many passed exactly one stage?

*Questions 9--12.* Tickets handled by two teams.

#table(columns: 5,
  [*Team*], [*Jan*], [*Feb*], [*Mar*], [*Total*],
  [Red], [90], [—], [120], [320],
  [Blue], [—], [100], [130], [330],
  [*Total*], [190], [210], [250], [650],
)

+ Find Red's February figure.
+ Find Blue's January figure.
+ Find the percent rise in the combined total from January to March.
+ Red's tickets are what percent of the grand total?

*Questions 13--14.* A radar chart scores three laptops out of 10.

#table(columns: 4,
  [*Axis*], [*L1*], [*L2*], [*L3*],
  [Speed], [8], [9], [7],
  [Battery], [7], [5], [9],
  [Weight], [6], [7], [8],
  [Price value], [9], [6], [7],
)

+ Which laptop has the highest total score?
+ L3's total exceeds L2's by what percent?

*Questions 15--18.*

+ In a class of 60, 40 passed Maths and 35 passed Science. Find the least possible number who passed both.
+ Store A's sales rose 10% from Rs.~50 lakh and store B's rose 25% from Rs.~30 lakh. Find the combined percent rise.
+ Four months of sales average 450 units. Three of them are 400, 500 and 380. Find the fourth.
+ In a group of 90 people, 50 play chess, 45 play carrom and 40 play badminton; 20 play chess and carrom, 18 play carrom and badminton, 22 play chess and badminton, and 10 play all three. How many play at least one game?
]

#key[
+ *900.* Admitted share $= 100 - 45 - 30 = 25%$, and $0.25 times 3600 = 900$.
+ *225.* $0.25 times 900 = 225$.
+ *6.25%.* $(225/3600) times 100 = 6.25$. Or $0.25 times 0.25 = 0.0625$ directly.
+ *$3 : 2$.* OPD $= 0.45 times 3600 = 1620$ and emergency $= 0.30 times 3600 = 1080$; $1620 : 1080$, divide both by 540. Or just compare the shares, $45 : 30$.
+ *350.* $280 + 220 - 150 = 350$.
+ *150.* $500 - 350 = 150$.
+ *70.* $220 - 150 = 70$.
+ *200.* $350 - 150 = 200$. Or $(280 - 150) + (220 - 150) = 130 + 70$.
+ *110.* Column Feb: $210 - 100 = 110$. Check row Red: $90 + 110 + 120 = 320$. Correct.
+ *100.* Column Jan: $190 - 90 = 100$. Check row Blue: $100 + 100 + 130 = 330$. Correct.
+ *About 31.58%.* $(250 - 190)/190 = 60/190 = 0.3158$.
+ *About 49.23%.* $(320/650) times 100$: 49% of 650 is 318.5, the gap 1.5 is $0.23%$ of 650.
+ *L3, with 31.* L1 $= 8 + 7 + 6 + 9 = 30$; L2 $= 9 + 5 + 7 + 6 = 27$; L3 $= 7 + 9 + 8 + 7 = 31$.
+ *About 14.81%.* $(31 - 27)/27 = 4/27 = 0.1481$.
+ *15.* Least overlap $= n(M) + n(S) - "total" = 40 + 35 - 60 = 15$. The two pass lists name 75 passes between them, but there are only 60 students, so at least $75 - 60 = 15$ students must be named on both lists.
+ *$+15.625%$.* Weighted: $(50 times 10 + 30 times 25)/80 = (500 + 750)/80 = 1250/80 = 15.625$. Check: $55 + 37.5 = 92.5$ against 80, a rise of 12.5 on 80. The plain average $(10 + 25) div 2 = 17.5$ is the trap.
+ *520.* Sum $= 450 times 4 = 1800$; known $= 400 + 500 + 380 = 1280$; $1800 - 1280 = 520$.
+ *85.* $50 + 45 + 40 = 135$; $20 + 18 + 22 = 60$; $135 - 60 = 75$; $75 + 10 = 85$. So 5 people play none.
]

#revision[

*Caselet routine.* Grand total $arrow.r$ draw the grid or tree $arrow.r$ fill in absolute numbers $arrow.r$ check that the boxes re-add to the total $arrow.r$ then read the questions. Never answer a caselet question straight from the paragraph.

*Base discipline.* "60% of those who failed" sits on the failed box, not the total. Write the base beside every percentage before multiplying.

*Two-set Venn.*
$n(A union B) = n(A) + n(B) - n(A inter B)$ · neither $= "total" - n(A union B)$ · only $A = n(A) - n(A inter B)$ · exactly one $= n(A union B) - n(A inter B)$.

*Three-set Venn.*
$n(A union B union C) = "singles" - "pairs" + "centre"$.
Fill from the centre out: centre, then each pair minus the centre, then each single minus the three pieces already placed. Seven regions, every question is a sum of them.

*Venn bounds.*
max $n(A inter B) = min(n(A), n(B))$ · min $n(A inter B) = n(A) + n(B) - "total"$ (0 if negative).
min $n(A inter B inter C) = n(A) + n(B) + n(C) - 2 times "total"$ (0 if negative). Equivalent method: add up the people *missing* from each set; that sum is the most who can fail to be in all three.

*Missing grid.* Find the row or column with exactly one dash. Fill it. Repeat. Finish by adding the grand total both by rows and by columns — they must agree. A sentence printed outside the grid usually unlocks the first blank.

*Averages.* Average $times$ count $=$ sum. Convert every average to a sum on line one.

*Average rate.* $"total value" div "total quantity"$, never the plain average of the rates.

*Combining groups.* Combined percent change $= (w_1 g_1 + w_2 g_2)/(w_1 + w_2)$, with $w$ the *old* sizes. Equal sizes is the only case where a plain average is right.

*Radar.* Sum the axes; ignore the shape. *Bubble.* Three numbers per point: $x$, $y$, and size. The size is usually what the question is really about.

*Top 5 traps.*
+ *Shifting base.* "Of the rest", "of those who failed", "of the remainder" — each phrase restarts the percentage on a new, smaller number.
+ *Only A is not A.* $n(A)$ includes everyone in the overlaps. Subtract them before calling a region "only" or "exactly".
+ *Pairwise counts include the centre.* "80 use both metro and cab" already contains the 40 who use all three.
+ *Averaging percentages of unequal groups.* Pass rates, growth rates, margins, order values — weight by size or the answer is wrong.
+ *Grid not cross-checked.* Always add the grand total by rows and by columns. If they disagree, one subtraction was wrong, and you will find it in seconds.
]

]
