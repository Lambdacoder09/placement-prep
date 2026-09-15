#import "../lib/style.typ": *

#chapter(num: 3, title: "Ratio, Proportion & Partnership", tagline: "Parts, not sizes. Then money split by parts.")[

#section[What you need to know]

#formulas(title: "Formula sheet")[
*Ratio.* $a : b$ means $a/b$. Multiply or divide both terms by the same non-zero number and the ratio does not change. $a$ is the *antecedent*, $b$ the *consequent*.

*Parts method.* If two things are in ratio $a : b$, write them as $a k$ and $b k$. One unknown, not two.

*Splitting a total.* Divide $N$ in the ratio $a : b : c$:
$ "share of first" = N times a/(a+b+c) , quad "one part" = N/(a+b+c) $

*Chaining ratios.* If $a:b = p:q$ and $b:c = r:s$, then
$ a : b : c = p r : q r : q s $

*Compounded ratio.* $(a:b)$ compounded with $(c:d)$ $=$ $a c : b d$.

*Powers of a ratio.*
#table(columns: 4,
 [*Name*], [*of $a:b$*], [*Name*], [*of $a:b$*],
 [duplicate], [$a^2 : b^2$], [sub-duplicate], [$sqrt(a) : sqrt(b)$],
 [triplicate], [$a^3 : b^3$], [sub-triplicate], [$root(3,a) : root(3,b)$],
)

*Proportion.* $a : b = c : d$ means $a d = b c$. Here $a, d$ are *extremes*, $b, c$ are *means*.
- Fourth proportional to $a, b, c$: $x = (b c)/a$.
- Third proportional to $a, b$: $x = b^2/a$ (from $a:b = b:x$).
- Mean proportional between $a$ and $b$: $x = sqrt(a b)$ (from $a:x = x:b$).
- Continued proportion $a:b = b:c$ gives $b^2 = a c$.
- If $a:b = b:c = c:d = k$, then $a/d = k^3$.

*Componendo–dividendo.* If $a/b = c/d$ then
$ (a+b)/(a-b) = (c+d)/(c-d) $

*Equal-ratio addition.* If $a/b = c/d = e/f = k$, then $(a+c+e)/(b+d+f) = k$.

*Variation.*
- Direct: $x prop y arrow.r x = k y arrow.r x_1/y_1 = x_2/y_2$.
- Inverse: $x prop 1/y arrow.r x y = k arrow.r x_1 y_1 = x_2 y_2$.
- Joint: $x prop (y z)/w arrow.r x = (k y z)/w$.

*Partnership.*
- Same time for everyone: $"profit ratio" = "capital ratio"$.
- Different times: $"profit ratio" = "capital" times "time"$ (call it *capital-months*).
- Capital changed mid-year: add the pieces. $C_1 t_1 + C_2 t_2$.
- Working partner: take out his salary or commission *first*, then split what is left by the capital ratio.
- Sleeping partner: capital only, no salary.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[Simplify the ratio $84 : 126$.
#sol[HCF of 84 and 126 is 42. $84 div 42 = 2$. $126 div 42 = 3$.]
#ans[$2 : 3$]]

#ex(2, tier: 0)[If $a:b = 3:4$ and $b:c = 6:7$, find $a:b:c$.
#sol[Make $b$ the same. LCM of 4 and 6 is 12. \
$a:b = 3:4 = 9:12$ (multiply by 3). $b:c = 6:7 = 12:14$ (multiply by 2).]
#ans[$9 : 12 : 14$]]

#ex(3, tier: 0)[Divide Rs.~960 in the ratio $5 : 7$.
#sol[Total parts $= 5 + 7 = 12$. One part $= 960 div 12 = 80$. \
First $= 5 times 80 = 400$. Second $= 7 times 80 = 560$. Check: $400 + 560 = 960$.]
#ans[Rs.~400 and Rs.~560]]

#ex(4, tier: 0)[Find the ratio compounded of $3:4$ and $8:9$.
#sol[Multiply across: $(3 times 8) : (4 times 9) = 24 : 36$. Divide both by 12: $2:3$.]
#ans[$2 : 3$]]

#ex(5, tier: 0)[Write (i) the duplicate ratio of $5:6$, (ii) the sub-duplicate ratio of $49:81$.
#sol[(i) Square both: $5^2 : 6^2 = 25 : 36$. \
(ii) Square-root both: $sqrt(49) : sqrt(81) = 7 : 9$.]
#ans[(i) $25:36$ #h(8pt) (ii) $7:9$]]

#ex(6, tier: 0)[Find the fourth proportional to 4, 6 and 14.
#sol[$4 : 6 = 14 : x arrow.r 4 x = 6 times 14 = 84 arrow.r x = 84/4 = 21$.]
#ans[21]]

#ex(7, tier: 0)[Find (i) the mean proportional between 8 and 32, (ii) the third proportional to 9 and 12.
#sol[(i) $x = sqrt(8 times 32) = sqrt(256) = 16$. \
(ii) $9 : 12 = 12 : x arrow.r 9 x = 144 arrow.r x = 16$.]
#ans[(i) 16 #h(8pt) (ii) 16]]

#ex(8, tier: 0)[$x$ varies inversely as $y$. $x = 12$ when $y = 5$. Find $x$ when $y = 15$.
#sol[Inverse means $x y = k$. So $k = 12 times 5 = 60$. \
When $y = 15$: $x = 60/15 = 4$.]
#ans[$x = 4$]]

#section[Tier 1 — Service companies]
#tier-header(1)

#ex(9, tier: 1, asked: "TCS NQT pattern")[Two numbers are in the ratio $5 : 8$. If 9 is added to each, the ratio becomes $8 : 11$. Find the numbers.
#sol[Let the numbers be $5x$ and $8x$.
$ (5x + 9)/(8x + 9) = 8/11 $
Cross-multiply: $11(5x + 9) = 8(8x + 9)$. \
Left: $55x + 99$. Right: $64x + 72$. \
$55x + 99 = 64x + 72$ \
$99 - 72 = 64x - 55x$ \
$27 = 9x arrow.r x = 3$. \
Numbers: $5 times 3 = 15$ and $8 times 3 = 24$. \
Check: $(15+9) : (24+9) = 24 : 33 = 8 : 11$. Correct.]
#ans[15 and 24]]

#trick[*Always use one letter, never two.* A ratio $5:8$ is $5x$ and $8x$ — that is one unknown. Students who write $a$ and $b$ and then $a/b = 5/8$ need two equations and lose 30 seconds.]

#ex(10, tier: 1, asked: "Infosys pattern")[Rs.~3,150 is divided among A, B and C so that $A : B = 2 : 3$ and $B : C = 4 : 5$. Find C's share.
#sol[Make B the same in both. LCM of 3 and 4 is 12. \
$A : B = 2 : 3 = 8 : 12$ (multiply by 4). \
$B : C = 4 : 5 = 12 : 15$ (multiply by 3). \
So $A : B : C = 8 : 12 : 15$. \
Total parts $= 8 + 12 + 15 = 35$. \
One part $= 3150 div 35 = 90$. \
C $= 15 times 90 = 1350$. \
Check: A $= 720$, B $= 1080$; $720 + 1080 + 1350 = 3150$. Correct.]
#ans[Rs.~1,350]]

#ex(11, tier: 1, asked: "Capgemini pattern")[The salaries of Arun and Bala are in the ratio $4 : 5$. Each gets an increment of Rs.~3,000 and the new ratio is $5 : 6$. Find Bala's new salary.
#sol[Salaries: $4x$ and $5x$.
$ (4x + 3000)/(5x + 3000) = 5/6 $
$6(4x + 3000) = 5(5x + 3000)$ \
$24x + 18000 = 25x + 15000$ \
$18000 - 15000 = 25x - 24x$ \
$3000 = x$. \
Bala's old salary $= 5 times 3000 = 15000$. \
Bala's new salary $= 15000 + 3000 = 18000$. \
Check: Arun new $= 12000 + 3000 = 15000$; $15000 : 18000 = 5 : 6$. Correct.]
#ans[Rs.~18,000]]

#ex(12, tier: 1, asked: "TCS NQT pattern")[Rs.~8,400 is divided among P, Q and R so that P gets twice what Q gets, and Q gets three times what R gets. Find Q's share.
#sol[Start from the smallest. Let R $= x$. \
Q gets three times R $arrow.r$ Q $= 3x$. \
P gets twice Q $arrow.r$ P $= 2 times 3x = 6x$. \
Total: $6x + 3x + x = 10x = 8400 arrow.r x = 840$. \
Q $= 3 times 840 = 2520$. \
Check: P $= 5040$, R $= 840$; $5040 + 2520 + 840 = 8400$. Correct.]
#ans[Rs.~2,520]]

#trap[*"P gets twice what Q gets" means $P = 2Q$, so $P : Q = 2 : 1$.* Many students write $1:2$. Read it as an equation first, then turn it into a ratio.]

#ex(13, tier: 1, asked: "Cognizant pattern")[A 21-litre mixture has milk and water in the ratio $5 : 2$. How much water must be added to make the ratio $5 : 3$?
#sol[Parts $= 5 + 2 = 7$. One part $= 21 div 7 = 3$ L. \
Milk $= 5 times 3 = 15$ L. Water $= 2 times 3 = 6$ L. \
Adding water does not change the milk. Milk stays 15 L. \
In the new ratio $5 : 3$, milk is 5 parts $= 15$ L, so one part $= 3$ L. \
New water $= 3 times 3 = 9$ L. \
Water to add $= 9 - 6 = 3$ L.]
#ans[3 litres]]

#ex(14, tier: 1, asked: "Infosys pattern")[A box has one-rupee, 50-paise and 25-paise coins. The *numbers* of the coins are in the ratio $5 : 6 : 8$. The total value is Rs.~30. How many 50-paise coins are there?
#sol[Let the counts be $5x$, $6x$, $8x$. \
Value of one-rupee coins $= 5x times 1 = 5x$ rupees. \
Value of 50-paise coins $= 6x times 0.50 = 3x$ rupees. \
Value of 25-paise coins $= 8x times 0.25 = 2x$ rupees. \
Total value $= 5x + 3x + 2x = 10x = 30 arrow.r x = 3$. \
Number of 50-paise coins $= 6 times 3 = 18$. \
Check: 15 coins of Re 1 $=$ Rs.~15; 18 coins of 50p $=$ Rs.~9; 24 coins of 25p $=$ Rs.~6. Total Rs.~30. Correct.]
#ans[18 coins]]

#trap[*Ratio of coin numbers is not the ratio of coin values.* Convert every count to money before you add. If the question had said "values are in the ratio $5:6:8$", the working would be completely different.]

#ex(15, tier: 1, asked: "TCS NQT pattern")[Find the ratio compounded of $2:3$, the duplicate ratio of $4:5$, the sub-duplicate ratio of $36:49$ and the triplicate ratio of $1:2$.
#sol[Write each ratio first. \
Duplicate of $4:5 = 16 : 25$. \
Sub-duplicate of $36:49 = 6 : 7$. \
Triplicate of $1:2 = 1 : 8$. \
Now compound (multiply all the first terms, multiply all the second terms). \
Numerator: $2 times 16 times 6 times 1 = 192$. \
Denominator: $3 times 25 times 7 times 8 = 4200$. \
$192 : 4200$. Divide both by 8: $24 : 525$. Divide both by 3: $8 : 175$.]
#ans[$8 : 175$]]

#ex(16, tier: 1, asked: "Wipro pattern")[$x$ varies directly as $y^2$ and inversely as $z$. When $y = 4$ and $z = 6$, $x = 12$. Find $x$ when $y = 6$ and $z = 9$.
#sol[$ x = (k y^2)/z $ \
Put in the known values: $12 = (k times 16)/6$. \
$12 times 6 = 16 k arrow.r 72 = 16 k arrow.r k = 72/16 = 4.5$. \
Now $y = 6$, $z = 9$: \
$x = (4.5 times 36)/9 = 4.5 times 4 = 18$.]
#ans[$x = 18$]]

#ex(17, tier: 1, asked: "Accenture pattern")[A, B and C invest Rs.~45,000, Rs.~60,000 and Rs.~75,000 in a business for one full year. The year's profit is Rs.~36,000. Find B's share.
#sol[Everyone invested for the same time, so profit splits in the capital ratio. \
$45000 : 60000 : 75000$. Divide all by 15,000: $3 : 4 : 5$. \
Total parts $= 12$. One part $= 36000 div 12 = 3000$. \
B $= 4 times 3000 = 12000$. \
Check: A $= 9000$, C $= 15000$; $9000 + 12000 + 15000 = 36000$. Correct.]
#ans[Rs.~12,000]]

#ex(18, tier: 1, asked: "TCS NQT pattern")[A starts a business with Rs.~30,000. After 4 months B joins with Rs.~45,000. After 6 months from the start, C joins with Rs.~60,000. At the end of one year the profit is Rs.~49,500. Find each partner's share.
#sol[Times invested, counting to the 12-month mark: \
A: 12 months. B: $12 - 4 = 8$ months. C: $12 - 6 = 6$ months. \
Capital-months (work in thousands to keep numbers small): \
A $= 30 times 12 = 360$. \
B $= 45 times 8 = 360$. \
C $= 60 times 6 = 360$. \
Ratio $= 360 : 360 : 360 = 1 : 1 : 1$. \
So the profit splits equally: $49500 div 3 = 16500$ each.]
#ans[Rs.~16,500 each]]

#trick[*Divide all capitals by a common factor before multiplying by time.* Rs.~30,000 becomes 30. You are only after a ratio, so any common scaling is free. This kills most of the arithmetic.]

#ex(19, tier: 1, asked: "Capgemini pattern")[A and B start a business with Rs.~24,000 and Rs.~36,000 for one year. A is the working partner and takes 15% of the profit for managing the business; the rest is divided in the capital ratio. If the profit is Rs.~24,000, what does A receive in total?
#sol[Step 1 — A's management share. \
$15%$ of $24000 = 0.15 times 24000 = 3600$. \
Step 2 — what is left. \
$24000 - 3600 = 20400$. \
Step 3 — capital ratio. \
$24000 : 36000 = 2 : 3$. Total parts $= 5$. One part $= 20400 div 5 = 4080$. \
A's capital share $= 2 times 4080 = 8160$. \
Step 4 — A's total. \
$3600 + 8160 = 11760$. \
Check: B gets $3 times 4080 = 12240$; $11760 + 12240 = 24000$. Correct.]
#ans[Rs.~11,760]]

#ex(20, tier: 1, asked: "Cognizant pattern")[If $(5x + 3y)/(5x - 3y) = 7/3$, find $x : y$.
#sol[Use componendo–dividendo. Add the two sides' parts and subtract them.
$ ((5x+3y)+(5x-3y))/((5x+3y)-(5x-3y)) = (7+3)/(7-3) $
Numerator on the left: $5x + 3y + 5x - 3y = 10x$. \
Denominator on the left: $5x + 3y - 5x + 3y = 6y$. \
So $(10x)/(6y) = 10/4$. \
$(10 x)/(6 y) = 10/4 arrow.r x/y = 10/4 times 6/10 = 6/4 = 3/2$. \
Check with $x = 3, y = 2$: $(15 + 6)/(15 - 6) = 21/9 = 7/3$. Correct.]
#ans[$x : y = 3 : 2$]]

#practice(tier: 1, time: "60 s/Q")[
+ Simplify $1.2 : 0.8 : 2.0$.
+ Divide Rs.~2,280 among A, B, C in the ratio $3 : 5 : 4$. Find B's share.
+ If $a : b = 2 : 5$ and $b : c = 3 : 4$, find $a : c$.
+ Two numbers are in the ratio $7 : 9$. If 12 is subtracted from each, the ratio becomes $5 : 7$. Find the larger number. #opts([54], [42], [63], [96])
+ Find the third proportional to 12 and 18.
+ Find the mean proportional between 12.5 and 2.
+ Find the ratio compounded of $5:6$ and the sub-duplicate ratio of $16:25$.
+ A sum is divided in the ratio $4 : 7$ and the two shares differ by Rs.~2,100. Find the total sum.
+ $x$ varies inversely as $sqrt(y)$. $x = 6$ when $y = 16$. Find $y$ when $x = 4$.
+ A and B invest Rs.~16,000 and Rs.~20,000. After 8 months A adds Rs.~8,000 more. The year's profit is Rs.~29,000. Find A's share.
+ Three partners invest capitals in the ratio $3 : 4 : 5$ for times in the ratio $4 : 3 : 2$. The profit is Rs.~34,000. Find the third partner's share.
+ A bag has Rs.~5, Rs.~2 and Re~1 coins whose numbers are in the ratio $3 : 4 : 5$. The total value is Rs.~336. How many Rs.~2 coins are there? #opts([48], [36], [60], [42])
+ In a college the ratio of students to teachers is $24 : 1$. If 40 more students join and no teacher is added, the ratio becomes $28 : 1$. How many teachers are there?
+ If $a : b = 3 : 4$ and $b : c = 8 : 9$, find $(a + b + c) : c$.
+ Rs.~2,700 is shared by A, B and C. A gets half of what B and C together get. B gets one-third of what A and C together get. Find C's share. #opts([Rs.~1,125], [Rs.~900], [Rs.~675], [Rs.~1,350])
]

#key[ \
*1.* $3 : 2 : 5$ — multiply every term by 5 to clear decimals, then divide by 2. \
*2.* Rs.~950 — 12 parts, one part $= 190$, B $= 5 times 190$. \
*3.* $3 : 10$ — make $b = 15$: $a:b = 6:15$, $b:c = 15:20$, so $a:c = 6:20$. \
*4.* (a) 54. $7(7x-12) = 5(9x-12) arrow.r 49x - 84 = 45x - 60 arrow.r 4x = 24 arrow.r x = 6$; numbers 42 and 54. (b) 42 is the *smaller* number. (c) 63 comes from the slip $84 - 60 = 28$, giving $x = 7$ and $9x = 63$. (d) 96 is the *sum* $42 + 54$, not the larger number. \
*5.* 27. $x = 18^2/12 = 324/12$. \
*6.* 5. $sqrt(12.5 times 2) = sqrt(25)$. \
*7.* $2 : 3$ — sub-duplicate of $16:25$ is $4:5$; $(5 times 4) : (6 times 5) = 20 : 30$. \
*8.* Rs.~7,700 — difference is $7 - 4 = 3$ parts $= 2100$, so one part $= 700$ and total $= 11 times 700$. \
*9.* $y = 36$. $x sqrt(y) = k = 6 times 4 = 24$; $sqrt(y) = 24/4 = 6$. \
*10.* Rs.~14,000 — A $= 16 times 8 + 24 times 4 = 128 + 96 = 224$; B $= 20 times 12 = 240$; ratio $224:240 = 14:15$, one part $= 29000/29 = 1000$. \
*11.* Rs.~10,000 — profit ratio $= 3 times 4 : 4 times 3 : 5 times 2 = 12:12:10 = 6:6:5$; one part $= 34000/17 = 2000$. \
*12.* (a) 48 — value $= 15x + 8x + 5x = 28x = 336 arrow.r x = 12$, so Rs.~2 coins $= 4x$. (b) 36 comes from using $x = 12$ with the Rs.~5 count. (c) 60 is the Re~1 count. (d) 42 comes from dividing 336 by 8 instead of 28. \
*13.* 10 — let teachers $= t$, students $= 24t$; $24t + 40 = 28t arrow.r 4t = 40$. \
*14.* $23 : 9$. $a:b:c = 6:8:9$, sum $= 23$. \
*15.* (a) Rs.~1,125 — A $= 1/3$ of total $= 900$, B $= 1/4$ of total $= 675$, C $= 2700 - 1575$. (b) 900 is A's share. (c) 675 is B's share. (d) 1,350 comes from treating "half of what B and C get" as "half the total". \
]

#section[Tier 2 — Singapore & Thailand]
#tier-header(2)

#ex(21, tier: 2, asked: "Grab · pattern")[On a ride-hailing app the fare of every trip is split between driver and platform in the ratio $4 : 1$. The driver also pays a booking levy of S\$0.40 per trip out of his own share. On Monday a driver completed 25 trips with total fare S\$625. Find his net earning.
#sol[Step 1 — driver's gross share. \
Total parts $= 4 + 1 = 5$. One part $= 625 div 5 = 125$. \
Driver $= 4 times 125 = 500$. \
Step 2 — levy. \
$25 times 0.40 = 10$. \
Step 3 — net. \
$500 - 10 = 490$.]
#ans[S\$490]]

#ex(22, tier: 2, asked: "Shopee · pattern")[Three sellers share a warehouse bill of S\$15,000 in proportion to (space used $times$ months stored). Seller A used 40 m#super[3] for 6 months, B used 30 m#super[3] for 7 months, C used 50 m#super[3] for 3 months. Find each seller's bill.
#sol[This is the partnership rule with space instead of money. \
A $= 40 times 6 = 240$. \
B $= 30 times 7 = 210$. \
C $= 50 times 3 = 150$. \
Total $= 240 + 210 + 150 = 600$. \
One unit $= 15000 div 600 = 25$. \
A $= 240 times 25 = 6000$. \
B $= 210 times 25 = 5250$. \
C $= 150 times 25 = 3750$. \
Check: $6000 + 5250 + 3750 = 15000$. Correct.]
#ans[A S\$6,000, B S\$5,250, C S\$3,750]]

#ex(23, tier: 2, asked: "Agoda · pattern")[A Bangkok hotel has deluxe and standard rooms in the ratio $3 : 7$. On one night 80% of the deluxe rooms and 60% of the standard rooms were occupied, giving 330 occupied rooms in all. How many rooms does the hotel have?
#sol[Let deluxe $= 3k$ and standard $= 7k$. \
Occupied deluxe $= 0.80 times 3k = 2.4k$. \
Occupied standard $= 0.60 times 7k = 4.2k$. \
Total occupied $= 2.4k + 4.2k = 6.6k$. \
$6.6 k = 330 arrow.r k = 330/6.6 = 50$. \
Total rooms $= 3k + 7k = 10k = 500$. \
Check: deluxe 150, occupied 120; standard 350, occupied 210; $120 + 210 = 330$. Correct.]
#ans[500 rooms]]

#ex(24, tier: 2, asked: "DBS · pattern")[A fund holds Singapore dollars and Thai baht. The *values* of the two holdings are in the ratio $5 : 3$. The exchange rate is 1 SGD $=$ 25 THB. The baht holding is THB~1,875,000. Find the SGD holding.
#sol[Step 1 — put both sides in the same currency. Convert the baht to SGD. \
$1875000 div 25 = 75000$ SGD. \
Step 2 — use the ratio. \
SGD holding : baht holding (in SGD) $= 5 : 3$. \
3 parts $= 75000 arrow.r$ one part $= 25000$. \
SGD holding $= 5 times 25000 = 125000$.]
#ans[S\$125,000]]

#trap[*Never form a ratio across two currencies without converting first.* $5 : 3$ compared "SGD value" with "SGD value". Writing $x : 1875000 = 5:3$ gives a nonsense answer of 3.1 million.]

#ex(25, tier: 2, asked: "Sea / Shopee · pattern")[Priya starts a shop with THB~240,000. After 5 months she withdraws THB~40,000. Wei joins 3 months after the start with THB~300,000 and 4 months later adds THB~60,000. At the end of 12 months the profit is THB~280,000. Split it.
#sol[Work in thousands of baht. \
*Priya.* 240 for the first 5 months, then $240 - 40 = 200$ for the remaining $12 - 5 = 7$ months. \
$240 times 5 = 1200$ \
$200 times 7 = 1400$ \
Total $= 1200 + 1400 = 2600$. \
*Wei.* He joins at the end of month 3, so he is in for $12 - 3 = 9$ months. For the first 4 of those he has 300; for the remaining $9 - 4 = 5$ he has $300 + 60 = 360$. \
$300 times 4 = 1200$ \
$360 times 5 = 1800$ \
Total $= 1200 + 1800 = 3000$. \
*Ratio.* $2600 : 3000 = 26 : 30 = 13 : 15$. \
Total parts $= 28$. One part $= 280000 div 28 = 10000$. \
Priya $= 13 times 10000 = 130000$. Wei $= 15 times 10000 = 150000$. \
Check: $130000 + 150000 = 280000$. Correct.]
#ans[Priya THB~130,000, Wei THB~150,000]]

#trick[*Capital-months as a bar chart.* Draw a 12-month line for each partner and mark where the capital changes. Each flat piece is one rectangle: height $times$ width. Add the rectangles. You will never lose a segment again.]

#ex(26, tier: 2, asked: "GIC · pattern")[The time to process a data batch varies directly as the number of records and inversely as the number of servers. 12 servers process 4.8 million records in 5 hours. How long will 18 servers take for 10.8 million records?
#sol[$ t = (k R)/S $ \
where $R$ is records in millions and $S$ is servers. \
Put in the known values: $5 = (k times 4.8)/12$. \
$5 times 12 = 4.8 k arrow.r 60 = 4.8 k arrow.r k = 60/4.8 = 12.5$. \
Now $R = 10.8$, $S = 18$: \
$t = (12.5 times 10.8)/18$. \
$12.5 times 10.8 = 135$. \
$t = 135/18 = 7.5$ hours.]
#ans[7.5 hours]]

#ex(27, tier: 2, asked: "SCB · pattern")[Branch A has a book of THB~96 million with loans : deposits $= 3 : 5$. Branch B has a book of THB~144 million with loans : deposits $= 5 : 7$. Find the combined loans : deposits ratio for the two branches together.
#sol[*Branch A.* Parts $= 3 + 5 = 8$. One part $= 96 div 8 = 12$. \
Loans $= 3 times 12 = 36$. Deposits $= 5 times 12 = 60$. \
*Branch B.* Parts $= 5 + 7 = 12$. One part $= 144 div 12 = 12$. \
Loans $= 5 times 12 = 60$. Deposits $= 7 times 12 = 84$. \
*Combined.* Loans $= 36 + 60 = 96$. Deposits $= 60 + 84 = 144$. \
$96 : 144$. Divide both by 48: $2 : 3$.]
#ans[$2 : 3$]]

#trap[*You cannot add ratios term by term.* $3:5$ and $5:7$ do not combine into $8:12$. Convert each ratio to real amounts, add the amounts, then re-form the ratio.]

#ex(28, tier: 2, asked: "LINE MAN · pattern")[A delivery fleet has bikes and cars in the ratio $9 : 4$. After 15 bikes are retired and 10 cars are added, the ratio becomes $3 : 2$. How many bikes were there at the start?
#sol[Let bikes $= 9k$ and cars $= 4k$.
$ (9k - 15)/(4k + 10) = 3/2 $
$2(9k - 15) = 3(4k + 10)$ \
$18k - 30 = 12k + 30$ \
$18k - 12k = 30 + 30$ \
$6k = 60 arrow.r k = 10$. \
Bikes at the start $= 9 times 10 = 90$. \
Check: bikes $90 - 15 = 75$; cars $40 + 10 = 50$; $75 : 50 = 3 : 2$. Correct.]
#ans[90 bikes]]

#ex(29, tier: 2, asked: "Razer · pattern")[The cost of a gaming headset splits into materials, labour and marketing in the ratio $7 : 4 : 9$. Next year materials cost rises 20%, labour rises 25% and marketing falls 10%. Find the new cost ratio and the percent change in total cost.
#sol[Take the three costs as 7, 4 and 9 units. Total $= 20$ units. \
Materials: $7 times 1.20 = 8.4$. \
Labour: $4 times 1.25 = 5.0$. \
Marketing: $9 times 0.90 = 8.1$. \
New ratio $= 8.4 : 5.0 : 8.1$. Multiply all by 10: $84 : 50 : 81$. \
New total $= 8.4 + 5.0 + 8.1 = 21.5$. \
Change $= 21.5 - 20 = 1.5$ units. \
Percent change $= 1.5/20 times 100 = 7.5%$ increase.]
#ans[$84 : 50 : 81$; total cost up 7.5%]]

#ex(30, tier: 2, asked: "Grab · pattern")[In zone X the ratio of orders to riders is $12 : 1$. In zone Y it is $9 : 1$. The two zones are merged and the combined ratio of orders to riders is $10 : 1$. Find the ratio of the number of riders in X to the number in Y.
#sol[Let X have $x$ riders and Y have $y$ riders. \
Orders in X $= 12x$. Orders in Y $= 9y$. \
Combined riders $= x + y$. Combined orders $= 12x + 9y$.
$ (12x + 9y)/(x + y) = 10/1 $
$12x + 9y = 10x + 10y$ \
$12x - 10x = 10y - 9y$ \
$2x = y$. \
So $x : y = 1 : 2$. \
Check: take $x = 1, y = 2$. Orders $= 12 + 18 = 30$; riders $= 3$; $30 : 3 = 10 : 1$. Correct.]
#ans[$1 : 2$]]

#note[Example 30 is the *alligation* idea in disguise: the combined ratio 10 sits between 9 and 12, and it lands closer to 9, so zone Y must carry more weight. Chapter 4 makes this a one-line rule.]

#practice(tier: 2, time: "100 s/Q")[
+ A courier fare is split driver : platform in the ratio $7 : 3$. A driver earns S\$420 in a day. Find the platform's revenue and the total fare collected.
+ A Bangkok café sells tea and coffee in the ratio $5 : 4$. Next month tea sales rise 20% and coffee sales fall 25%. Find the new ratio.
+ A fund splits assets bonds : equity : cash in the ratio $8 : 11 : 1$. Cash is S\$2.4 million. Find the total assets.
+ Meera invests Rs.~84,000 for 8 months and Raj invests Rs.~63,000 for 12 months. The profit is Rs.~1,02,000. Find each share.
+ $x$ varies inversely as the cube of $y$. $x = 5$ when $y = 2$. Find $x$ when $y = 4$.
+ A Phuket hotel has deluxe and suite rooms in the ratio $8 : 3$, charged at THB~3,500 and THB~9,000 per night. If every room is sold, find the ratio of deluxe revenue to suite revenue.
+ In a class the ratio of boys to girls is $5 : 3$. After 10 boys leave and 6 girls join, the ratio is $4 : 3$. Find the original class size.
+ Three partners invest capitals in the ratio $5 : 7 : 8$ for times in the ratio $6 : 4 : 3$. The profit is S\$82,000. Split it.
+ A logistics cost varies directly as distance and inversely as the load factor. The cost is THB~9,000 for 300 km at load factor 0.8. Find the cost for 450 km at load factor 0.9.
+ Branch A has staff : customers $= 1 : 40$; branch B has $1 : 30$. Together the ratio is $1 : 36$. Find the ratio of staff in A to staff in B.
+ If $(2x + 3y)/(2x - 3y) = 11/5$, find $x : y$.
+ A bonus pool of S\$2,40,000 is split in proportion to (headcount $times$ months active). Team A: 10 people for 9 months. Team B: 12 people for 5 months. Team C: 15 people for 10 months. Find each team's bonus.
]

#key[ \
*1.* Platform S\$180, total fare S\$600 — 7 parts $= 420$, one part $= 60$. \
*2.* $2 : 1$ — new tea $= 5 times 1.2 = 6$, new coffee $= 4 times 0.75 = 3$, so $6:3$. \
*3.* S\$48 million — cash is 1 part $= 2.4$, total $= 20$ parts. \
*4.* Meera Rs.~48,000, Raj Rs.~54,000 — capital-months $84 times 8 = 672$ and $63 times 12 = 756$; $672 : 756 = 8 : 9$; one part $= 102000/17 = 6000$. \
*5.* $x = 5/8 = 0.625$. $k = x y^3 = 5 times 8 = 40$; $x = 40/64$. \
*6.* $28 : 27$ — revenue $= 8 times 3500 = 28000$ and $3 times 9000 = 27000$ per 11 rooms. \
*7.* 144 students. $3(5k - 10) = 4(3k + 6) arrow.r 15k - 30 = 12k + 24 arrow.r k = 18$; boys 90, girls 54. \
*8.* S\$30,000 / S\$28,000 / S\$24,000 — profit ratio $= 30 : 28 : 24 = 15 : 14 : 12$; one part $= 82000/41 = 2000$. \
*9.* THB~12,000. $C = k d / L arrow.r 9000 = k times 300/0.8 = 375k arrow.r k = 24$; $C = 24 times 450/0.9 = 24 times 500$. \
*10.* $3 : 2$. $40a + 30b = 36(a + b) arrow.r 4a = 6b$. \
*11.* $x : y = 4 : 1$ — componendo–dividendo gives $(4x)/(6y) = 16/6$, so $x/y = 16/6 times 6/4 = 4$. \
*12.* A S\$72,000, B S\$48,000, C S\$1,20,000 — weights $90 : 60 : 150$, total 300, one unit $= 800$. \
]

#section[Tier 3 — Product companies]
#tier-header(3)

#ex(31, tier: 3, asked: "Goldman Sachs · pattern")[Four positive numbers satisfy $a/b = b/c = c/d$. If $a = 27$ and $d = 8$, find $b + c$.
#sol[*Insight: in a continued proportion the ratio of the two ends is the common ratio cubed.*

Let the common ratio be $k$, so $a = k b$, $b = k c$, $c = k d$. \
Then
$ a = k b = k(k c) = k^2 c = k^2 (k d) = k^3 d $
So $a/d = k^3$.
$ k^3 = 27/8 arrow.r k = root(3, 27/8) = 3/2 $
Now walk back from $d$: \
$c = k d = 3/2 times 8 = 12$. \
$b = k c = 3/2 times 12 = 18$. \
Check $a = k b = 3/2 times 18 = 27$. Correct. \
$b + c = 18 + 12 = 30$.]
#ans[$b + c = 30$]]

#ex(32, tier: 3, asked: "Amazon · pattern")[A rectangle has length : breadth $= 5 : 3$. The same positive number is added to both the length and the breadth, and the new ratio is $7 : 5$. By what percent does the area increase?
#sol[*Insight: adding the same amount to both terms of a ratio always pushes the ratio toward $1 : 1$. So $7:5$ is possible ($7/5 < 5/3$), and the amount added is forced.*

Let length $= 5k$, breadth $= 3k$, and let $x$ be added to each.
$ (5k + x)/(3k + x) = 7/5 $
$5(5k + x) = 7(3k + x)$ \
$25k + 5x = 21k + 7x$ \
$25k - 21k = 7x - 5x$ \
$4k = 2x arrow.r x = 2k$. \
New length $= 5k + 2k = 7k$. New breadth $= 3k + 2k = 5k$. (Ratio $7:5$. Correct.) \
Old area $= 5k times 3k = 15k^2$. \
New area $= 7k times 5k = 35k^2$. \
Increase $= 35k^2 - 15k^2 = 20k^2$. \
Percent increase $= (20k^2)/(15k^2) times 100 = 4/3 times 100 = 133 1/3 %$.]
#ans[$133 1/3 %$ (that is, $approx 133.33%$)]]

#ex(33, tier: 3, asked: "D. E. Shaw · pattern")[A team's wins to losses stand at $5 : 8$. The team then wins $k$ more games in a row and loses none, after which the ratio is $5 : 6$. Find the smallest possible number of games the team had played before this winning run.
#sol[*Insight: the ratio fixes $k$ only up to a fraction. The real constraint is that wins, losses and $k$ must all be whole numbers.*

Let wins $= 5m$ and losses $= 8m$, with $m$ a positive integer. \
Losses do not change. After the run:
$ (5m + k)/(8m) = 5/6 $
$6(5m + k) = 5 times 8m$ \
$30m + 6k = 40m$ \
$6k = 10m arrow.r k = (5m)/3$. \
For $k$ to be a whole number, $m$ must be a multiple of 3. The smallest is $m = 3$. \
Then wins $= 15$, losses $= 24$, and $k = 5$. \
Games played before the run $= 15 + 24 = 39$. \
Check: after 5 more wins, $20 : 24 = 5 : 6$. Correct.]
#ans[39 games (with $k = 5$)]]

#ex(34, tier: 3, asked: "Google · pattern")[Two ad channels are compared on click-through rate.

#table(columns: 5,
 [], [*Mobile*], [*CTR*], [*Desktop*], [*CTR*],
 [Channel P], [63 of 90], [70%], [2 of 10], [20%],
 [Channel Q], [8 of 10], [80%], [27 of 90], [30%],
)

Channel Q beats channel P on mobile and on desktop. Which channel has the better overall CTR?
#sol[*Insight: an overall rate is a weighted average of the sub-rates. The weights are the traffic sizes, and they can flip the comparison.*

Channel P overall: clicks $= 63 + 2 = 65$; impressions $= 90 + 10 = 100$. \
CTR $= 65/100 = 65%$. \
Channel Q overall: clicks $= 8 + 27 = 35$; impressions $= 10 + 90 = 100$. \
CTR $= 35/100 = 35%$. \
So P wins overall, 65% to 35%, even though it loses both sub-groups.

Why: P put 90 of its 100 impressions on mobile, where rates are high. Q put 90 of its 100 impressions on desktop, where rates are low. The overall number measures the traffic mix as much as the channel quality.]
#ans[Channel P, 65% against 35% — the sub-group winner is not the overall winner]]

#trap[*Never average two ratios by averaging their values.* $(70 + 20)/2 = 45%$ for P is wrong; the true answer is 65%. Always go back to totals: add the numerators, add the denominators, then divide.]

#ex(35, tier: 3, asked: "Adobe · pattern")[Three numbers are in the ratio $3 : 4 : 5$ and their LCM is 2400. Find the numbers and their HCF.
#sol[*Insight: if the ratio terms are in lowest form, the numbers are $3x$, $4x$, $5x$ with HCF $= x$, and the LCM is $x$ times the LCM of the ratio terms.*

Let the numbers be $3x$, $4x$, $5x$. \
Since $3, 4, 5$ have HCF 1, the HCF of the numbers is $x$. \
LCM of 3, 4, 5: \
$3 = 3$, $4 = 2^2$, $5 = 5$, so LCM $= 2^2 times 3 times 5 = 60$. \
Therefore LCM of the numbers $= 60 x$.
$ 60 x = 2400 arrow.r x = 40 $
Numbers: $3 times 40 = 120$, $4 times 40 = 160$, $5 times 40 = 200$. HCF $= 40$. \
Check: $120 = 2^3 times 3 times 5$, $160 = 2^5 times 5$, $200 = 2^3 times 5^2$. \
LCM $= 2^5 times 3 times 5^2 = 32 times 3 times 25 = 2400$. Correct. \
HCF $= 2^3 times 5 = 40$. Correct.]
#ans[120, 160, 200; HCF $= 40$]]

#ex(36, tier: 3, asked: "Uber · pattern")[A city platform keeps a service rule: riders : drivers must stay at or below $40 : 1$. Right now there are 42,000 riders and 1,200 drivers. Next month riders will grow 5% and 8% of the current drivers will quit. How many new drivers must be hired to keep the rule?
#sol[*Insight: do not compare the growth rates. Compute both sides next month and compare the needed count with the surviving count.*

Step 1 — riders next month. \
$42000 times 1.05 = 44100$. \
Step 2 — drivers still on the platform next month. \
$8%$ quit, so $92%$ remain: $1200 times 0.92 = 1104$. \
Step 3 — drivers *needed* next month. \
The rule is $"riders"/"drivers" <= 40$, so $"drivers" >= 44100/40 = 1102.5$. \
Drivers are whole people, so at least 1,103 are needed. \
Step 4 — compare. \
Surviving drivers $= 1104 >= 1103$. The rule already holds. \
Check: $44100 div 1104 = 39.95$, which is below 40. Correct.]
#ans[No hiring needed — 0 new drivers]]

#note[Riders grew 5% and drivers fell 8%, so the ratio did get worse. It just did not get worse *enough* to break the rule. Tier-3 questions reward finishing the arithmetic instead of guessing from the direction of change.]

#ex(37, tier: 3, asked: "Microsoft · pattern")[Prove that if $a/b = c/d$ then
$ (a^2 + c^2)/(b^2 + d^2) = (a c)/(b d) $
Then use it: if $(a^2 + c^2)/(b^2 + d^2) = 16/49$, $a/b = c/d$ and $a c = 48$, find $b d$.
#sol[*Insight: when two fractions are equal, name the common value $r$ and substitute. Every expression collapses to a power of $r$.*

Let $a/b = c/d = r$. Then $a = r b$ and $c = r d$. \
*Left side.* \
$a^2 + c^2 = r^2 b^2 + r^2 d^2 = r^2 (b^2 + d^2)$
$ (a^2 + c^2)/(b^2 + d^2) = (r^2 (b^2 + d^2))/(b^2 + d^2) = r^2 $
*Right side.* \
$a c = (r b)(r d) = r^2 b d$
$ (a c)/(b d) = (r^2 b d)/(b d) = r^2 $
Both sides equal $r^2$, so they are equal. Proved.

*Now the numbers.* \
$r^2 = 16/49$.
$ (a c)/(b d) = r^2 = 16/49 $
$ 48/(b d) = 16/49 arrow.r 16 times b d = 48 times 49 $
$b d = (48 times 49)/16 = 3 times 49 = 147$. \
Check with $r = 4/7$: take $b = 7, d = 21$, so $b d = 147$; then $a = 4, c = 12$ and $a c = 48$. Correct.]
#ans[$b d = 147$]]

#ex(38, tier: 3, asked: "Goldman Sachs · pattern")[A invests Rs.~50,000 for 12 months, B invests Rs.~75,000 for 8 months and C invests Rs.~1,00,000 for 12 months. They agree that C is *guaranteed* at least Rs.~46,000 of the profit, and any shortfall is paid by A and B in their own profit ratio. The year's profit is Rs.~80,000. Find each partner's final share.
#sol[*Insight: a guarantee is a second step, not a new ratio. Split normally first, then transfer.*

Step 1 — capital-months (in thousands). \
A $= 50 times 12 = 600$. \
B $= 75 times 8 = 600$. \
C $= 100 times 12 = 1200$. \
Ratio $= 600 : 600 : 1200 = 1 : 1 : 2$. \
Step 2 — normal split. \
Total parts $= 4$. One part $= 80000 div 4 = 20000$. \
A $= 20000$, B $= 20000$, C $= 40000$. \
Step 3 — the guarantee. \
C is promised 46,000 but the normal split gives 40,000. \
Shortfall $= 46000 - 40000 = 6000$. \
Step 4 — who pays. \
A and B pay in their own ratio, which is $1 : 1$. So each pays $6000 div 2 = 3000$. \
A $= 20000 - 3000 = 17000$. \
B $= 20000 - 3000 = 17000$. \
C $= 40000 + 6000 = 46000$. \
Check: $17000 + 17000 + 46000 = 80000$. Correct.]
#ans[A Rs.~17,000, B Rs.~17,000, C Rs.~46,000]]

#practice(tier: 3, time: "4 min/Q")[
+ Four positive numbers satisfy $a/b = b/c = c/d$. If $a = 81$ and $d = 24$, find $b + c$.
+ Two positive integers are in the ratio $4 : 9$. When 5 is added to both, the ratio becomes $9 : 14$. Find the two integers, and explain why the answer is forced.
+ Two teaching methods were tried on 100 students each. Method A: 45 of 50 passed in the strong section and 12 of 50 in the weak section. Method B: 19 of 20 passed in the strong section and 26 of 80 in the weak section. Method B has the higher pass rate in *both* sections. Which method has the higher overall pass rate, and why?
+ Three numbers are in the ratio $2 : 3 : 5$ and their HCF is 14. Find their LCM.
+ X and Y invest Rs.~1,20,000 and Rs.~80,000 for 12 months. Z joins as a working partner with no capital and is guaranteed one-fifth of the profit; the rest is split in the capital ratio. The profit is Rs.~1,50,000. Find Y's share.
+ A delivery platform has 900 couriers and 27,000 weekly orders. Its rule is orders : couriers $<= 32 : 1$. Next month orders grow 12% and 5% of couriers quit. How many couriers must be hired?
+ If $a/b = c/d$, $(a^2 + c^2)/(b^2 + d^2) = 9/25$ and $b d = 200$, find $a c$.
+ A batsman's runs to balls faced stand at $3 : 5$, and he has scored 60 runs. He then scores $n$ more runs off $n$ more balls, and the ratio becomes $5 : 7$. Find $n$, and say in one line why the ratio had to rise.
]

#key[ \
*1.* $b + c = 90$. The ratio of the ends is the common ratio cubed: $k^3 = a/d = 81/24 = 27/8$, so $k = 3/2$. Then $c = k d = 3/2 times 24 = 36$ and $b = k c = 3/2 times 36 = 54$. Check $a = 3/2 times 54 = 81$. Sum $= 54 + 36 = 90$.

*2.* The integers are 4 and 9. Write them as $4k$ and $9k$: $14(4k + 5) = 9(9k + 5) arrow.r 56k + 70 = 81k + 45 arrow.r 25 = 25k arrow.r k = 1$. The answer is forced because adding a *fixed* number, not a fixed proportion, ties the ratio change to the actual size of the numbers — so only one size works.

*3.* Method A, 57% against 45%. A passed $45 + 12 = 57$ of 100; B passed $19 + 26 = 45$ of 100. B won both sections but sent 80 of its 100 students into the weak section, where everyone does badly. The overall figure is a weighted average and the weights decided it.

*4.* LCM $= 420$. The numbers are $2 times 14 = 28$, $3 times 14 = 42$, $5 times 14 = 70$. LCM $= "HCF" times "LCM of " 2,3,5 = 14 times 30 = 420$. Check: $28 = 2^2 times 7$, $42 = 2 times 3 times 7$, $70 = 2 times 5 times 7$, so LCM $= 2^2 times 3 times 5 times 7 = 420$.

*5.* Y gets Rs.~48,000. Z first takes $1/5 times 150000 = 30000$. Remaining $= 120000$, split in $120000 : 80000 = 3 : 2$, so one part $= 24000$ and Y $= 2 times 24000 = 48000$ (X gets 72,000). Check: $72000 + 48000 + 30000 = 150000$.

*6.* Hire 90 couriers. Orders next month $= 27000 times 1.12 = 30240$. Couriers left $= 900 times 0.95 = 855$. Couriers needed $= 30240 div 32 = 945$. Hire $945 - 855 = 90$. Note the rule is on a *future* pair of numbers, so both sides must be projected before comparing.

*7.* $a c = 72$. With $a/b = c/d = r$, both $(a^2+c^2)/(b^2+d^2)$ and $(a c)/(b d)$ equal $r^2$. So $(a c)/200 = 9/25 arrow.r a c = 200 times 9/25 = 72$.

*8.* $n = 40$. Runs $= 3k = 60 arrow.r k = 20$, so balls $= 5k = 100$. Then $(60 + n)/(100 + n) = 5/7 arrow.r 420 + 7n = 500 + 5n arrow.r 2n = 80$. Check: $100/140 = 5/7$. The ratio had to rise because adding the *same* amount to a smaller top and a larger bottom always moves the fraction toward 1. \
]

#section[Mixed set — exam conditions]

#practice(tier: 1, time: "25 minutes for all 18")[
+ Simplify $0.75 : 1.25 : 2$.
+ Rs.~5,400 is divided in the ratio $2 : 3 : 4$. Find the middle share.
+ If $A : B = 5 : 6$ and $B : C = 8 : 9$, find $A : B : C$.
+ Find the mean proportional between 4.5 and 8.
+ If $x : y = 4 : 7$, find $(5x + 3y) : (2x - y)$.
+ Two partners invest Rs.~36,000 and Rs.~54,000 for a full year. The profit is Rs.~45,000. Find the second partner's share.
+ $A$ varies inversely as $B^2$. $A = 27$ when $B = 2$. Find $A$ when $B = 6$.
+ Two numbers are in the ratio $9 : 13$. Adding 6 to each makes the ratio $3 : 4$. Find the numbers.
+ A bag has Rs.~10, Rs.~5 and Rs.~2 coins whose numbers are in the ratio $2 : 3 : 5$. The total value is Rs.~900. How many Rs.~5 coins are there?
+ The incomes of Anil and Sunil are in the ratio $5 : 4$ and their expenditures are in the ratio $3 : 2$. Each saves Rs.~8,000. Find Anil's income.
+ Find the ratio compounded of $3:5$, the duplicate ratio of $2:3$ and the sub-triplicate ratio of $27:64$.
+ P invests Rs.~20,000 for 6 months, Q invests Rs.~15,000 for 8 months and R invests Rs.~12,000 for 5 months. The profit is Rs.~30,000. Find R's share.
+ The ages of a father and son are in the ratio $7 : 2$. After 10 years the ratio will be $9 : 4$. Find the father's present age.
+ Three numbers are in the ratio $4 : 5 : 6$ and the sum of their squares is 1,232. Find the largest number.
+ If $(7a - 3b)/(7a + 3b) = 1/5$, find $a : b$.
+ A pool of S\$90,000 is split in proportion to (headcount $times$ months): team 1 is 10 people for 6 months, team 2 is 8 people for 9 months, team 3 is 12 people for 4 months. Find the largest share.
+ In a school boys : girls $= 8 : 5$. After 60 more girls join, the ratio is $4 : 3$. How many boys are there?
+ A and B start with Rs.~90,000 and Rs.~60,000. After 4 months A withdraws Rs.~30,000 and B adds Rs.~30,000. The year's profit is Rs.~1,26,000. Find A's share.
]

#key[ \
*1.* $3 : 5 : 8$ — multiply all by 4. \
*2.* Rs.~1,800 — 9 parts, one part $= 600$, middle $= 3 times 600$. \
*3.* $20 : 24 : 27$ — make $B = 24$ (LCM of 6 and 8). \
*4.* 6. $sqrt(4.5 times 8) = sqrt(36)$. \
*5.* $41 : 1$ — put $x = 4$, $y = 7$: $(20 + 21) : (8 - 7)$. \
*6.* Rs.~27,000 — ratio $36 : 54 = 2 : 3$, one part $= 45000/5 = 9000$. \
*7.* $A = 3$. $k = A B^2 = 27 times 4 = 108$; $A = 108/36$. \
*8.* 18 and 26. $4(9k + 6) = 3(13k + 6) arrow.r 36k + 24 = 39k + 18 arrow.r k = 2$. \
*9.* 60 — value $= 20x + 15x + 10x = 45x = 900 arrow.r x = 20$; Rs.~5 coins $= 3x$. \
*10.* Rs.~20,000. $5x - 3y = 8000$ and $4x - 2y = 8000$; the second gives $y = 2x - 4000$; substituting, $5x - 6x + 12000 = 8000 arrow.r x = 4000$; income $= 5 times 4000$. \
*11.* $1 : 5$. $(3:5) times (4:9) times (3:4) = 36 : 180$. \
*12.* Rs.~6,000 — capital-months $120 : 120 : 60 = 2 : 2 : 1$; one part $= 30000/5 = 6000$. \
*13.* 35 years. $4(7k + 10) = 9(2k + 10) arrow.r 28k + 40 = 18k + 90 arrow.r k = 5$. \
*14.* 24. $(16 + 25 + 36)x^2 = 77x^2 = 1232 arrow.r x^2 = 16 arrow.r x = 4$; largest $= 6 times 4$. \
*15.* $9 : 14$ — componendo–dividendo: $(14a)/(-6b) = 6/(-4) arrow.r a/b = 6/4 times 6/14 = 9/14$. \
*16.* S\$36,000 — weights $60 : 72 : 48$, total 180, one unit $= 500$; largest $= 72 times 500$. \
*17.* 480 boys. $3 times 8k = 4(5k + 60) arrow.r 24k = 20k + 240 arrow.r k = 60$. \
*18.* Rs.~58,800 — A $= 90 times 4 + 60 times 8 = 360 + 480 = 840$; B $= 60 times 4 + 90 times 8 = 240 + 720 = 960$; ratio $7 : 8$; one part $= 126000/15 = 8400$; A $= 7 times 8400$. \
]

#revision[ \
*THE PARTS METHOD* \
$a : b arrow.r$ write $a k$ and $b k$. One unknown. Always. \
Splitting $N$ in $a : b : c$: one part $= N/(a+b+c)$. \
Difference of two shares $= (a - b)$ parts. Sum $= (a + b)$ parts.

*CHAINING AND COMPOUNDING* \
$a:b = p:q$, $b:c = r:s arrow.r a:b:c = p r : q r : q s$ (make $b$ match by LCM). \
Compounded: $(a:b)$ with $(c:d) = a c : b d$. \
Duplicate $a^2:b^2$ · triplicate $a^3:b^3$ · sub-duplicate $sqrt(a):sqrt(b)$ · sub-triplicate $root(3,a):root(3,b)$.

*PROPORTION* \
$a:b = c:d arrow.l.r a d = b c$. \
Fourth proportional to $a,b,c$: $(b c)/a$. Third proportional to $a,b$: $b^2/a$. Mean proportional: $sqrt(a b)$. \
Continued proportion $a/b = b/c = c/d = k arrow.r a/d = k^3$. \
Componendo–dividendo: $a/b = c/d arrow.r (a+b)/(a-b) = (c+d)/(c-d)$. \
If $a/b = c/d = e/f = k$ then $(a+c+e)/(b+d+f) = k$.

*VARIATION* \
Direct $x = k y$ · Inverse $x y = k$ · Joint $x = k y z \/ w$. \
Method: write the equation with $k$, plug in the first data set to get $k$, then plug in the second.

*PARTNERSHIP* \
Same time $arrow.r$ profit ratio $=$ capital ratio. \
Different times $arrow.r$ profit ratio $=$ capital $times$ time (capital-months). \
Capital changed mid-year $arrow.r$ add the rectangles: $C_1 t_1 + C_2 t_2$. \
Working partner $arrow.r$ salary or commission comes out *first*; split the remainder. \
Guarantee $arrow.r$ split normally, then transfer the shortfall from the others in *their* ratio.

*SHORTCUTS*
+ Scale capitals down (30,000 $arrow.r$ 30) before multiplying by time. Ratios do not care.
+ Adding the same number to both terms always moves a ratio toward $1:1$. Use it to sanity-check any answer.
+ "Difference of shares is $D$" $arrow.r$ one part $= D \/ ("bigger term" - "smaller term")$.
+ Componendo–dividendo turns $(m x + n y)/(m x - n y) = p/q$ into $x:y$ in one line.
+ For chained ratios, the LCM of the two middle terms is the fastest bridge.

*TOP 5 TRAPS*
+ A ratio has no size. $2:3$ does not mean the numbers are 2 and 3.
+ Ratios cannot be added term by term. Convert to real amounts, add, then re-form the ratio.
+ "A gets twice what B gets" is $A = 2B$, so $A : B = 2 : 1$ — not $1:2$.
+ Ratio of coin *counts* is not the ratio of coin *values*. Convert counts to money first.
+ In partnership, if the times differ you must use capital $times$ time. Capital alone is wrong.
+ Bonus trap: an overall rate is a weighted average of sub-rates. Never average two percentages unless the two group sizes are equal.
]

]
