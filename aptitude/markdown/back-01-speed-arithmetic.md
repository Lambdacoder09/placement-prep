#toc-entry("Appendix A — Speed Arithmetic")

  APPENDIX A
  
  Speed Arithmetic
  
  Know these cold. There is no calculator on test day.

## A.1 · Multiplication tables, 2 to 25

#table(
  columns: 13,
  inset: 3.4pt,
  align: center,
  fill: (x, y) => if x == 0 or y == 0 { boxbg },
  [$\times$],
  ..range(1, 13).map(i => strong[#i]),
  ..range(2, 26).map(n => (strong[#n],) + range(1, 13).map(i => [#(n * i)])).flatten()
)

## A.2 · Squares, 1 to 40

#table(
  columns: 11,
  inset: 3.4pt,
  align: center,
  fill: (x, y) => if x == 0 or calc.even(y) { boxbg },
  ..range(0, 4).map(b => (
    (strong[$n$],)
    + range(1, 11).map(i => strong[#(b * 10 + i)])
    + (strong[$n^2$],)
    + range(1, 11).map(i => [#((b ** 10 + i) ** (b * 10 + i))])
  )).flatten()
)

Squares ending in 5 are instant: $35^2 = (3 \times 4) | 25 = 1225$.  
$85^2 = (8 \times 9) | 25 = 7225$.   $115^2 = (11 \times 12) | 25 = 13225$.

## A.3 · Cubes, 1 to 20

#table(
  columns: 11,
  inset: 3.4pt,
  align: center,
  fill: (x, y) => if x == 0 or calc.even(y) { boxbg },
  ..range(0, 2).map(b => (
    (strong[$n$],)
    + range(1, 11).map(i => strong[#(b * 10 + i)])
    + (strong[$n^3$],)
    + range(1, 11).map(i => [#((b ** 10 + i) ** (b ** 10 + i) ** (b * 10 + i))])
  )).flatten()
)

Unit digit of a cube gives back the unit digit of the number for $0, 1, 4, 5, 6, 9$, and
swaps $2 arrow.l.r 8$, $3 arrow.l.r 7$. So a cube ending in 3 came from a number ending in 7.

## A.4 · Powers of 2, up to $2^16$

#table(
  columns: 10,
  inset: 3.4pt,
  align: center,
  fill: (x, y) => if x == 0 or y == 0 { boxbg },
  ..((strong[$n$],) + range(0, 9).map(k => strong[#k])
    + (strong[$2^n$],) + range(0, 9).map(k => [#calc.pow(2, k)]))
)

#table(
  columns: 9,
  inset: 3.4pt,
  align: center,
  fill: (x, y) => if x == 0 or y == 0 { boxbg },
  ..((strong[$n$],) + range(9, 17).map(k => strong[#k])
    + (strong[$2^n$],) + range(9, 17).map(k => [#calc.pow(2, k)]))
)

Also worth holding: $2^20 = 1 " " 048 " " 576 \approx 10^6$,   $2^30 \approx 10^9$,  
$3^5 = 243$,   $3^6 = 729$,   $5^5 = 3125$,   $7^4 = 2401$,   $11^3 = 1331$.

## A.5 · Fraction, percentage and decimal

#table(
  columns: (auto, auto, auto, auto, auto, auto, 1fr),
  inset: (x: 5pt, y: 3.4pt),
  align: (center, center, center, center, center, center, left),
  fill: (x, y) => if y == 0 { boxbg },
  [**Fraction**], [**Percent**], [**Decimal**], [**Fraction**], [**Percent**], [**Decimal**], [**Useful relatives**],

  [$1/2$],  [50%],            [0.5],      [$1/12$], [$8 1/3 %$],   [0.0833],  [$5/12 = 41 2/3 %$,   $7/12 = 58 1/3 %$],
  [$1/3$],  [$33 1/3 %$],    [0.3333],   [$1/13$], [$7 9/13 %$],  [0.0769],  [$2/13 = 15.38%$],
  [$1/4$],  [25%],            [0.25],     [$1/14$], [$7 1/7 %$],   [0.0714],  [$3/14 = 21.43%$],
  [$1/5$],  [20%],            [0.2],      [$1/15$], [$6 2/3 %$],   [0.0667],  [$4/15 = 26 2/3 %$],
  [$1/6$],  [$16 2/3 %$],    [0.1667],   [$1/16$], [6.25%],        [0.0625],  [$3/16 = 18.75%$,   $5/16 = 31.25%$],
  [$1/7$],  [$14 2/7 %$],    [0.1429],   [$1/17$], [$5 15/17 %$], [0.0588],  [$2/17 = 11.76%$],
  [$1/8$],  [12.5%],          [0.125],    [$1/18$], [$5 5/9 %$],   [0.0556],  [$5/18 = 27 7/9 %$],
  [$1/9$],  [$11 1/9 %$],    [0.1111],   [$1/19$], [$5 5/19 %$],  [0.0526],  [$3/19 = 15.79%$],
  [$1/10$], [10%],            [0.1],      [$1/20$], [5%],           [0.05],    [$3/20 = 15%$,   $7/20 = 35%$],
  [$1/11$], [$9 1/11 %$],    [0.0909],   [$1/24$], [$4 1/6 %$],   [0.0417],  [$1/25 = 4%$,   $1/40 = 2.5%$,   $1/50 = 2%$],
)

The ones that pay for themselves every single test: $2/3 = 66 2/3 %$,  
$3/4 = 75%$,   $2/5 = 40%$,   $3/5 = 60%$,   $4/5 = 80%$,  
$3/8 = 37.5%$,   $5/8 = 62.5%$,   $7/8 = 87.5%$,   $5/6 = 83 1/3 %$.

## A.6 · Square roots, 1 to 30

#table(
  columns: 11,
  inset: 3.4pt,
  align: center,
  fill: (x, y) => if x == 0 or calc.even(y) { boxbg },
  ..range(0, 3).map(b => (
    (strong[$n$],)
    + range(1, 11).map(i => strong[#(b * 10 + i)])
    + (strong[$sqrt(n)$],)
    + range(1, 11).map(i => [#calc.round(calc.sqrt(b * 10 + i), digits: 3)])
  )).flatten()
)

The four you will actually use: $sqrt(2) = 1.414$,   $sqrt(3) = 1.732$,  
$sqrt(5) = 2.236$,   $sqrt(10) = 3.162$.   And $1/sqrt(2) = 0.707$,  
$1/sqrt(3) = 0.577$,   $pi = 3.1416$,   $22/7 = 3.1429$.

## A.7 · HCF and LCM shortcuts

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 4pt),
  fill: (x, y) => if x == 0 { boxbg },

  [**Product rule**], [For two numbers only: $"HCF" \times "LCM" = a \times b$. Find one, divide to get the other.],
  [**Euclid**], [$"HCF"(a, b) = "HCF"(b,   a mod b)$. Keep replacing the bigger by the remainder until the remainder is 0. $"HCF"(84, 36) -> "HCF"(36, 12) -> "HCF"(12, 0) = 12$.],
  [**Coprime pairs**], [Two consecutive numbers are always coprime, so $"LCM"(n, n+1) = n(n+1)$ and $"HCF" = 1$. Same for two consecutive odd numbers.],
  [**Fractions**], [$"HCF" = ("HCF of numerators")/("LCM of denominators")$,   $"LCM" = ("LCM of numerators")/("HCF of denominators")$.],
  [**Same remainder**], [Largest number that divides $a, b, c$ leaving the **same** remainder $= "HCF"(b-a,   c-b,   c-a)$.],
  [**Given remainders**], [Largest number dividing $a$ and $b$ leaving $r_1, r_2$ $= "HCF"(a - r_1,   b - r_2)$.],
  [**Common remainder $r$**], [Smallest number leaving remainder $r$ with each of $a, b, c$ $= "LCM"(a, b, c) + r$.],
  [**Short of a multiple**], [Leaves $a - k$, $b - k$, $c - k$ (same shortfall $k$) $= "LCM"(a, b, c) - k$.],
  [**Ratio form**], [If $"HCF" = h$, write the numbers as $h x$ and $h y$ with $x, y$ coprime. Then $"LCM" = h x y$.],
)

### LCMs worth memorising

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.4pt),
  fill: (x, y) => if x == 0 { boxbg },
  [First $n$ numbers], [$"LCM"(1..5) = 60$,   $"LCM"(1..6) = 60$,   $"LCM"(1..8) = 840$,   $"LCM"(1..10) = 2520$,   $"LCM"(1..12) = 27720$],
  [Clock / time sets], [$"LCM"(2,3,4,6) = 12$,   $"LCM"(4,6,8,12) = 24$,   $"LCM"(6,8,9,12) = 72$,   $"LCM"(9,12,15) = 180$],
  [Common pairs], [$"LCM"(12,18) = 36$,   $(15,20) = 60$,   $(14,21) = 42$,   $(16,24) = 48$,   $(25,30) = 150$,   $(35,49) = 245$],
)

## A.8 · Mental-math techniques --- shown, not explained

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 4pt),
  fill: (x, y) => if x == 0 { boxbg },

  [**$\times 5$**], [$68 \times 5 = 68/2 \times 10 = 34 \times 10 = 340$],
  [**$\times 25$**], [$68 \times 25 = 68/4 \times 100 = 17 \times 100 = 1700$],
  [**$\times 50$**], [$46 \times 50 = 46/2 \times 100 = 2300$],
  [**$\times 125$**], [$48 \times 125 = 48/8 \times 1000 = 6 \times 1000 = 6000$],
  [**$\div 5$**], [$340 \div 5 = 340 \times 2 \div 10 = 680 \div 10 = 68$],
  [**$\div 25$**], [$1700 \div 25 = 1700 \times 4 \div 100 = 6800 \div 100 = 68$],
  [**$\times 9$**], [$47 \times 9 = 470 - 47 = 423$],
  [**$\times 99$**], [$47 \times 99 = 4700 - 47 = 4653$],
  [**$\times 11$**], [$47 \times 11$: write $4 space (4+7) space 7 = 4 space 11 space 7 -> 517$ (carry the 1)],
  [ ], [$36 \times 11 = 3 space (3+6) space 6 = 396$],
  [**$\times 12$**], [$43 \times 12 = 430 + 86 = 516$   (ten times it, plus twice it)],
  [**$\times 15$**], [$28 \times 15 = 280 + 140 = 420$   (ten times it, plus half of that)],
  [**Squares of 5-enders**], [$65^2 = (6 \times 7) | 25 = 4225$],
  [**Near 50**], [$53^2 = (25 + 3) | 3^2 = 2809$.   $47^2 = (25 - 3) | 3^2 = 2209$.],
  [**Near 100**], [$96 \times 93$: $96 - 7 = 89$,   $4 \times 7 = 28$ $arrow.r 8928$],
  [ ], [$108 \times 104$: $108 + 4 = 112$,   $8 \times 4 = 32$ $arrow.r 11232$],
  [**Difference of squares**], [$48 \times 52 = 50^2 - 2^2 = 2500 - 4 = 2496$],
  [ ], [$37 \times 43 = 40^2 - 3^2 = 1600 - 9 = 1591$],
  [**Add by rounding**], [$297 + 458 = 300 + 458 - 3 = 755$],
  [**Subtract by rounding**], [$724 - 298 = 724 - 300 + 2 = 426$],
  [**Percent swap**], [$8%$ of $25 = 25%$ of $8 = 2$.   $16%$ of $75 = 75%$ of $16 = 12$.],
  [**Build a percent**], [$15%$ of $840$: $10% = 84$, half of that $= 42$, total $126$.],
  [ ], [$35%$ of $60$: $10% = 6$, so $30% = 18$, $5% = 3$, total $21$.],
  [**Percent of a percent**], [$20%$ of $30%$ of $500 = 0.2 \times 0.3 \times 500 = 30$],
  [**Divide by 8**], [$1432 \div 8$: halve three times $-> 716 -> 358 -> 179$],
  [**Fraction first**], [$(3/8) \times 216 = 216 \div 8 \times 3 = 27 \times 3 = 81$ (never $216 \times 3$ first)],
  [**Check: digit sum**], [$427 \times 13 = 5551$? Digit sums: $4 \times 4 = 16 -> 7$; answer $5+5+5+1 = 16 -> 7$. Passes.],
  [**Check: last digit**], [$37 \times 48$ must end in $7 \times 8 = 56 -> 6$. Any option not ending in 6 is dead.],
  [**Check: size**], [$37 \times 48 \approx 40 \times 50 = 2000$. The true value 1776 is near it. An option of 776 or 17760 is dead.],
)

---
💡 **SHORTCUT**

**The two-second option killer.** Before you compute anything, look at the options. Use the
**last digit** and the **rough size**. On a service-company paper this alone answers roughly one
question in six with no working at all.
