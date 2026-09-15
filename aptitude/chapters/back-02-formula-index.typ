#import "../lib/style.typ": *

#pagebreak(weak: true)
#toc-entry("Appendix B — Master Formula Index")

#block(width: 100%, inset: (bottom: 10pt))[
  #text(size: 9pt, fill: muted, weight: "bold", tracking: 1.5pt)[APPENDIX B]
  #v(-4pt)
  #text(size: 22pt, weight: "bold")[Master Formula Index]
  #v(-3pt)
  #text(size: 10pt, fill: muted, style: "italic")[Every formula in the book. The number on the left is the chapter.]
]
#line(length: 100%, stroke: 1.2pt + ink)
#v(4pt)

#note[
*How to revise from this page.* Cover the right column. Read the chapter title. Write out
every formula you remember. Uncover and compare. Whatever you missed is the chapter you
re-open tonight.
]

#let idx(num, title, items) = {
  v(6pt)
  block(breakable: true, width: 100%)[
    #block(fill: boxbg, inset: (x: 7pt, y: 3.5pt), radius: 2pt, width: 100%,
           stroke: (left: 2.5pt + ink, rest: none))[
      #text(size: 10.5pt, weight: "bold")[Chapter #num · #title]
    ]
    #v(2pt)
    #table(
      columns: (auto, 1fr),
      stroke: none,
      inset: (x: 4pt, y: 2.4pt),
      align: (right + top, left + top),
      ..items.enumerate().map(((i, it)) => (
        text(size: 8pt, fill: muted)[#(str(num) + "." + str(i + 1))],
        text(size: 9.5pt)[#it],
      )).flatten()
    )
  ]
}

// ============================================================
//  PART I — QUANTITATIVE APTITUDE
// ============================================================

#section[Part I · Quantitative Aptitude]

#idx(1, "Numbers & Number System", (
  [Divisibility by 4: last 2 digits; by 8: last 3 digits; by 25: last 2 digits],
  [Divisibility by 3 or 9: digit sum divisible by 3 or 9],
  [Divisibility by 11: (sum of odd-place digits) $-$ (sum of even-place digits) divisible by 11],
  [Divisibility by 7: drop the last digit, subtract twice it, repeat],
  [If $N = p^a q^b r^c$: number of factors $= (a+1)(b+1)(c+1)$],
  [Sum of factors $= ((p^(a+1)-1)/(p-1)) ((q^(b+1)-1)/(q-1)) ((r^(c+1)-1)/(r-1))$],
  [Product of all factors $= N^(d\/2)$, $d$ = number of factors],
  [Odd factors: drop the power of 2 first. Even factors $=$ total $-$ odd],
  [$"HCF" times "LCM" = a times b$ (two numbers only)],
  [$"HCF of fractions" = ("HCF of numerators")/("LCM of denominators")$; #h(4pt) $"LCM of fractions" = ("LCM of numerators")/("HCF of denominators")$],
  [Same remainder from $a, b, c$: $"HCF"(b-a, c-b, c-a)$],
  [Remainders $r_1, r_2$ from $a, b$: $"HCF"(a-r_1, b-r_2)$],
  [Smallest number leaving remainder $r$ with $a, b, c$: $"LCM"(a,b,c) + r$],
  [$(a times b) mod n = ((a mod n) times (b mod n)) mod n$],
  [Fermat: $p$ prime, $p divides.not a arrow.r a^(p-1) equiv 1 (mod p)$],
  [Euler: $a^phi(n) equiv 1 (mod n)$ when $"HCF"(a,n)=1$; $phi(n) = n product(1 - 1/p)$],
  [Unit digit: cycle length 4 for 2, 3, 7, 8; 2 for 4 and 9; 1 for 0, 1, 5, 6],
  [Unit digit rule: power $mod 4$; if the remainder is 0 use the 4th term of the cycle],
  [Last two digits: $76^k equiv 76 (mod 100)$; $2^20 equiv 76$; base ending in 1 $arrow.r$ tens digit $=$ (tens of base $times$ unit of power) mod 10],
  [Highest power of prime $p$ in $n!$ $= floor(n/p) + floor(n/p^2) + floor(n/p^3) + dots$],
  [Trailing zeros of $n!$ $= floor(n/5) + floor(n/25) + floor(n/125) + dots$],
  [Composite $m = p^alpha q^beta$ in $n!$: find each prime power, divide by its exponent, take the minimum],
  [Base $b$: $(d_k dots d_0)_b = d_k b^k + dots + d_0$; convert by repeated division, read remainders bottom-up],
  [Count of $1..N$ divisible by $a$ or $b$ $= floor(N/a) + floor(N/b) - floor(N\/"LCM"(a,b))$],
))

#idx(2, "Percentages", (
  [$x%$ of $N = (x\/100) N$; #h(4pt) $A$ as a percent of $B = (A\/B) times 100$],
  [Percentage change $= ("new" - "old")/"old" times 100$ --- the *old* value is always the base],
  [Increase $x%$ $arrow.r$ multiply by $(1 + x\/100)$; decrease $arrow.r (1 - x\/100)$],
  [Two changes in a row: multiply the multipliers. Net $= a + b + (a b)\/100$],
  [$A$ is $x%$ more than $B$ $arrow.r$ $B$ is $(100 x)/(100+x) %$ less than $A$],
  [$A$ is $x%$ less than $B$ $arrow.r$ $B$ is $(100 x)/(100-x) %$ more than $A$],
  [Product constancy: price up $x%$ $arrow.r$ quantity must fall $(100 x)/(100+x) %$],
  [Growth for $n$ years at $r%$: $P(1 + r\/100)^n$; depreciation: $P(1 - r\/100)^n$],
  [$"% error" = (|"wrong" - "correct"|)/"correct" times 100$],
  [Length $x%$ too large $arrow.r$ area $((1+x\/100)^2 - 1) times 100 %$ too large; volume uses the cube],
  [Savings $=$ Income $-$ Expenditure; set income $= 100$ to kill the fractions],
  [Weighted percent: fraction $w$ changes $a%$, rest changes $b%$ $arrow.r$ whole changes $w a + (1-w) b$],
  [$n(A "or" B) = n(A) + n(B) - n(A "and" B)$; neither $= 100% - n(A "or" B)$],
  [Key conversions: $1\/8 = 12.5%$, $1\/6 = 16 2\/3 %$, $1\/3 = 33 1\/3 %$, $3\/8 = 37.5%$, $5\/8 = 62.5%$, $2\/3 = 66 2\/3 %$],
))

#idx(3, "Ratio, Proportion & Partnership", (
  [Write $a : b$ as $a k$ and $b k$ --- one unknown, not two],
  [Split $N$ in $a : b : c$: one part $= N/(a+b+c)$, first share $= N a/(a+b+c)$],
  [Chain: $a:b = p:q$ and $b:c = r:s$ $arrow.r a:b:c = p r : q r : q s$],
  [Compounded ratio of $(a:b)$ and $(c:d)$ $= a c : b d$],
  [Duplicate $a^2 : b^2$; triplicate $a^3 : b^3$; sub-duplicate $sqrt(a):sqrt(b)$; sub-triplicate $root(3,a):root(3,b)$],
  [$a : b = c : d arrow.r a d = b c$ (product of extremes $=$ product of means)],
  [Fourth proportional to $a,b,c$: $x = (b c)\/a$],
  [Third proportional to $a,b$: $x = b^2\/a$; #h(4pt) mean proportional of $a,b$: $x = sqrt(a b)$],
  [Continued proportion $a:b = b:c arrow.r b^2 = a c$; if $a:b=b:c=c:d=k$ then $a\/d = k^3$],
  [Componendo--dividendo: $a/b = c/d arrow.r (a+b)/(a-b) = (c+d)/(c-d)$],
  [If $a/b = c/d = e/f = k$ then $(a+c+e)/(b+d+f) = k$],
  [Direct variation: $x_1\/y_1 = x_2\/y_2$. Inverse: $x_1 y_1 = x_2 y_2$. Joint: $x = k y z\/w$],
  [Partnership, same time: profit ratio $=$ capital ratio],
  [Partnership, different times: profit ratio $=$ capital $times$ time (capital-months)],
  [Capital changed mid-year: add the pieces, $C_1 t_1 + C_2 t_2$],
  [Working partner: remove the salary or commission *first*, then split the rest by capital],
))

#idx(4, "Averages, Mixtures & Alligation", (
  [$"Average" = "Sum"/"Count"$; #h(4pt) $"Sum" = "Average" times "Count"$ --- always convert to a sum first],
  [First $n$ naturals: $(n+1)\/2$. First $n$ odds: $n$. First $n$ evens: $n+1$],
  [Evenly spaced set: average $= ("first" + "last")\/2$],
  [Replace $a$ by $b$ among $n$ values: change in average $= (b-a)\/n$],
  [New member joins: new average $= (n A + x)/(n+1)$; if the average rises by $d$, then $x = A + (n+1)d$],
  [Weighted average $= (n_1 A_1 + n_2 A_2)/(n_1 + n_2)$],
  [Alligation: $"cheaper"/"dearer" = (D - M)/(M - C)$],
  [Repeated replacement, $n$ times: pure left $= x(1 - y\/x)^n$],
  [Average speed $= "total distance"/"total time"$; equal distances at $u, v$: $2 u v\/(u+v)$],
  [Three equal distances at $u, v, w$: $3\/(1\/u + 1\/v + 1\/w)$],
  [Median is not pulled by extreme values; the mean is],
))

#idx(5, "Profit, Loss & Discount", (
  [$"Profit" = "SP" - "CP"$; #h(4pt) $"Profit"% = "Profit"/"CP" times 100$ (always on CP)],
  [$"SP" = "CP" (100+p)/100$; #h(4pt) $"CP" = "SP" times 100/(100+p)$; use $-l$ for a loss],
  [$"Discount"% = ("MP" - "SP")/"MP" times 100$ (always on MP); $"SP" = "MP"(100-d)/100$],
  [Successive discounts: $"SP" = "MP"(1 - d_1\/100)(1 - d_2\/100) dots$; two equal to $d_1 + d_2 - d_1 d_2\/100$],
  [Mark up $m%$ then discount $d%$: $"Profit"% = m - d - (m d)\/100$],
  [$"MP"(100 - d) = "CP"(100 + p)$; #h(4pt) markup needed $= "MP"\/"CP" = (100+p)\/(100-d)$],
  [Same SP, one at $+x%$ and one at $-x%$: always a loss of $x^2\/100$ per cent],
  [Mark up $m%$ then discount $m%$: always a loss of $m^2\/100$ per cent],
  [CP of $a$ articles $=$ SP of $b$ articles $arrow.r$ $"Profit"% = (a-b)\/b times 100$],
  [False weight at cost price: $"Gain"% = ("true" - "given")/"given" times 100$],
  [False weight with markup: $"SP"\/"CP" = (100+m)/100 times "true"/"given"$],
  [Profit as a share of SP $= p/(100+p) times 100$ per cent],
  [Break-even units $= "fixed cost"\/c$, where $c = "SP per unit" - "variable cost per unit"$],
))

#idx(6, "Simple & Compound Interest", (
  [$"SI" = (P R T)\/100$; #h(4pt) $A = P(1 + R T\/100)$],
  [$P = (100 "SI")\/(R T)$, #h(4pt) $R = (100 "SI")\/(P T)$, #h(4pt) $T = (100 "SI")\/(P R)$],
  [$A = P(1 + R\/100)^n$; #h(4pt) $"CI" = P[(1 + R\/100)^n - 1]$],
  [Half-yearly: $P(1 + R\/200)^(2n)$; quarterly: $P(1 + R\/400)^(4n)$; monthly: $P(1 + R\/1200)^(12n)$],
  [$"EAR" = [(1 + R\/(100k))^k - 1] times 100$ per cent, $k$ compoundings a year],
  [CI $-$ SI over 2 years $= P(R\/100)^2$; over 3 years $= P R^2 (300 + R)\/10^6$],
  [2-year ratio $"CI"\/"SI" = 1 + R\/200$],
  [SI doubles when $R T = 100$; doubles in $T$ $arrow.r$ $m$ times in $(m-1)T$],
  [CI: $m$ times in $T$ $arrow.r m^2$ times in $2T$ $arrow.r m^3$ times in $3T$],
  [Rule of 72: doubling time at CI $approx 72\/R$ years],
  [Equal instalments at CI: $P = x\/v + x\/v^2 + dots + x\/v^n$ with $v = 1 + R\/100$],
  [$"EMI" = P i (1+i)^n \/ ((1+i)^n - 1)$, $i = R\/1200$, $n$ months],
  [Flat-rate loan: $"EMI" = (P + "total interest")\/"months"$; true rate $approx$ twice the flat rate],
  [Real return: divide, never subtract --- $(1 + R\/100)\/(1 + f\/100)$],
))

#idx(7, "Time, Speed & Distance", (
  [$"speed" = "distance"\/"time"$],
  [$1 "km/h" = 5\/18 "m/s"$; #h(4pt) $1 "m/s" = 18\/5 "km/h"$],
  [Fixed distance: speeds in ratio $a:b$ $arrow.r$ times in ratio $b:a$],
  [Average speed $= "total distance"\/"total time"$; equal distances at $u,v$: $2 u v\/(u+v)$],
  [Three equal distances: $3 u v w\/(u v + v w + w u)$; equal *times*: $(u+v)\/2$],
  [Late/early: $d = (s_1 s_2)/(s_2 - s_1) times Delta t$],
  [Relative speed: opposite $u + v$; same direction $|u - v|$],
  [Train past a pole: $L\/s$. Past a platform: $(L + P)\/s$. Two trains: $(L_1 + L_2)\/"rel. speed"$],
  [Boats: $"down" = b + c$, $"up" = b - c$, $b = ("down"+"up")\/2$, $c = ("down"-"up")\/2$],
  ["A beats B by $x$ m" $arrow.r$ when A finishes, B has run (race $- x$) m],
  [Circular track, same direction: first meeting after $C\/(u-v)$; opposite: $C\/(u+v)$],
  [Distinct meeting points, speed ratio $a:b$ in lowest terms: $a+b$ opposite, $a-b$ same direction],
  [Meet then continue for $t_1, t_2$ more hours: time to meet $= sqrt(t_1 t_2)$, speeds $= sqrt(t_2) : sqrt(t_1)$],
))

#idx(8, "Time & Work", (
  [Job in $a$ days $arrow.r$ one day's work $= 1\/a$. Add rates, never days],
  [Together: $(a b)/(a+b)$ days. Three: $(a b c)/(a b + b c + c a)$ days],
  [LCM method: total work $=$ LCM of the days, so every rate is a whole number],
  [Times in ratio $a:b$ $arrow.r$ efficiencies in ratio $b:a$],
  [A is $p%$ more efficient than B $arrow.r$ A's time $=$ B's time $div (1 + p\/100)$],
  [$(M_1 D_1 H_1)\/W_1 = (M_2 D_2 H_2)\/W_2$],
  [Wages split in the ratio of work actually done],
  [Pipes: net rate $= sum "filling" - sum "emptying"$; fill time $= 1 div$ net rate],
  [Leak: pipe alone $a$ h, with leak $b$ h $arrow.r$ leak empties alone in $(a b)/(b-a)$ hours],
  [Alternate days: compute one full 2-day block, count whole blocks, finish day by day],
  [Pairs $p, q, r$: $1\/p + 1\/q + 1\/r = 2 times ("rate of all three")$],
))

#idx(9, "Permutations & Combinations", (
  [AND $arrow.r$ multiply. OR $arrow.r$ add (cases must not overlap)],
  [$""^n P_r = n!\/(n-r)!$; #h(4pt) $""^n C_r = n!\/(r!(n-r)!) = ""^n P_r \/ r!$],
  [$""^n C_r = ""^n C_(n-r)$; #h(4pt) $""^n C_2 = n(n-1)\/2$; #h(4pt) $""^n C_3 = n(n-1)(n-2)\/6$],
  [Pascal: $""^n C_r + ""^n C_(r-1) = ""^(n+1) C_r$; #h(4pt) $sum_r ""^n C_r = 2^n$],
  [Subsets of an $n$-set $= 2^n$; at least one item $= 2^n - 1$],
  [Repetition allowed: $r$ slots, $n$ choices each $arrow.r n^r$],
  [Alike objects in a row: $n!\/(p! q! r! dots)$],
  [Circular: $(n-1)!$; necklace / garland: $(n-1)!\/2$],
  [Together $arrow.r$ glue the group, multiply by its internal arrangements],
  [No two together $arrow.r$ arrange the rest, then use the gaps; $r$ from $n$ in a row: $""^(n-r+1) C_r$],
  [$x_1 + dots + x_r = n$, each $>= 1$: $""^(n-1) C_(r-1)$; each $>= 0$: $""^(n+r-1) C_(r-1)$],
  [Distinct objects into distinct boxes: $r^n$; into exactly 3, none empty: $3^n - 3 dot 2^n + 3$],
  [$m n$ objects into $m$ groups of $n$: labelled $(m n)!\/(n!)^m$; unlabelled $(m n)!\/((n!)^m m!)$],
  [$D_n = n!(1 - 1\/1! + 1\/2! - dots)$; $D_2=1, D_3=2, D_4=9, D_5=44, D_6=265$],
  [Exactly $k$ in the right place: $""^n C_k dot D_(n-k)$],
  [From $n$ points (no 3 collinear): lines $""^n C_2$, triangles $""^n C_3$],
  [Diagonals of an $n$-gon $= n(n-3)\/2$],
  [Rectangles in an $a times b$ grid of cells $= ""^(a+1) C_2 times ""^(b+1) C_2$],
  [Grid paths, $m$ east and $n$ north: $(m+n)!\/(m! n!)$],
  [Sum of all $n$-digit numbers from $n$ distinct non-zero digits $= (n-1)! times ("digit sum") times underbrace(1 1 dots 1, n)$],
))

#idx(10, "Probability", (
  [$P(E) = "favourable"\/"total"$, and $0 <= P(E) <= 1$],
  [$P("not" E) = 1 - P(E)$ --- use this for every "at least one"],
  [Odds in favour $a:b arrow.r P = a\/(a+b)$; odds against $a:b arrow.r P = b\/(a+b)$],
  [$P(A union B) = P(A) + P(B) - P(A inter B)$],
  [$P(A inter B) = P(A) dot P(B bar A)$; independent $arrow.r P(A) dot P(B)$],
  [$P(A bar B) = P(A inter B)\/P(B)$],
  [Total probability: $P(E) = sum_i P(B_i) P(E bar B_i)$],
  [Bayes: $P(B_i bar E) = P(B_i)P(E bar B_i) \/ sum_j P(B_j)P(E bar B_j)$],
  [$E[X] = sum x_i p_i$; linearity $E[X+Y] = E[X] + E[Y]$ even when dependent],
  [Indicator trick: expected count $=$ sum of the individual probabilities],
  [Binomial: $P(r) = ""^n C_r p^r q^(n-r)$; mean $= n p$; variance $= n p q$],
  [Geometric: $P("first success on try" k) = q^(k-1) p$; $E["tries"] = 1\/p$; memoryless],
  [Two dice: 36 outcomes; ways to make sums 2..12 are $1,2,3,4,5,6,5,4,3,2,1$],
  [Deck: 52 cards, 26 red, 4 suits of 13, 4 aces, 12 face cards, 6 red face cards],
  [$n$ coins: $2^n$ outcomes; exactly $r$ heads in $""^n C_r$ ways],
  [$P(53$ of a given weekday$)$: ordinary year $1\/7$, leap year $2\/7$],
))

#idx(11, "Algebra Essentials", (
  [$(a plus.minus b)^2 = a^2 plus.minus 2a b + b^2$; #h(4pt) $a^2 - b^2 = (a-b)(a+b)$],
  [$a^3 plus.minus b^3 = (a plus.minus b)(a^2 minus.plus a b + b^2)$],
  [$a^3+b^3+c^3-3a b c = (a+b+c)(a^2+b^2+c^2-a b-b c-c a)$],
  [$x + 1\/x = k arrow.r x^2 + 1\/x^2 = k^2 - 2$, #h(4pt) $x^3 + 1\/x^3 = k^3 - 3k$],
  [$x - 1\/x = k arrow.r x^2 + 1\/x^2 = k^2 + 2$, #h(4pt) $x^3 - 1\/x^3 = k^3 + 3k$],
  [Two linear equations: unique if $a_1\/a_2 != b_1\/b_2$; none if $a_1\/a_2 = b_1\/b_2 != c_1\/c_2$],
  [$x = (-b plus.minus sqrt(b^2-4a c))\/(2a)$; $D = b^2 - 4a c$ decides the root type],
  [$alpha + beta = -b\/a$, #h(4pt) $alpha beta = c\/a$; equation: $x^2 - ("sum")x + ("product") = 0$],
  [$alpha^2 + beta^2 = (alpha+beta)^2 - 2 alpha beta$; #h(4pt) $|alpha - beta| = sqrt(D)\/|a|$],
  [Extremum of $a x^2 + b x + c$ at $x = -b\/(2a)$, value $c - b^2\/(4a)$],
  [AP: $t_n = a + (n-1)d$; #h(4pt) $S_n = n\/2[2a + (n-1)d] = n\/2 (a + l)$],
  [GP: $t_n = a r^(n-1)$; #h(4pt) $S_n = a(r^n - 1)\/(r-1)$; #h(4pt) $S_infinity = a\/(1-r)$ for $|r|<1$],
  [HP: the reciprocals form an AP],
  [$sum n = n(n+1)\/2$; #h(4pt) $sum n^2 = n(n+1)(2n+1)\/6$; #h(4pt) $sum n^3 = [n(n+1)\/2]^2$],
  [$"AM" = (a+b)\/2$, $"GM" = sqrt(a b)$, $"HM" = 2a b\/(a+b)$; $"GM"^2 = "AM" times "HM"$; $"AM" >= "GM" >= "HM"$],
  [$a^m a^n = a^(m+n)$, $(a^m)^n = a^(m n)$, $a^(-n) = 1\/a^n$, $a^(m\/n) = root(n, a^m)$],
  [Rationalise: $1\/(sqrt(a) - sqrt(b)) = (sqrt(a) + sqrt(b))\/(a - b)$],
  [$log(m n) = log m + log n$; $log(m\/n) = log m - log n$; $log(m^p) = p log m$],
  [$log_b a = (log_c a)\/(log_c b) = 1\/(log_a b)$; digits in $N$ $= floor(log_10 N) + 1$],
  [$log_10 2 = 0.3010$, $log_10 3 = 0.4771$, $log_10 7 = 0.8451$],
  [$|x| < a arrow.l.r -a < x < a$; #h(4pt) $|x| > a arrow.l.r x < -a$ or $x > a$],
  [For $x > 0$: $x + k\/x >= 2sqrt(k)$, equality at $x = sqrt(k)$],
  [$(f compose g)(x) = f(g(x))$; remainder of $f(x)$ by $(x-a)$ is $f(a)$],
))

#idx(12, "Geometry & Mensuration", (
  [Straight line $180 degree$, point $360 degree$; vertically opposite angles equal],
  [Triangle angle sum $180 degree$; exterior angle $=$ sum of the two opposite interior angles],
  [Triangle inequality: $a + b > c$ for every pair],
  [Pythagoras; triples $(3,4,5), (5,12,13), (8,15,17), (7,24,25), (9,40,41), (20,21,29)$],
  [Area $= 1\/2 times "base" times "height"$; Heron $= sqrt(s(s-a)(s-b)(s-c))$, $s = (a+b+c)\/2$],
  [Equilateral side $a$: area $= sqrt(3)\/4 a^2$, height $= sqrt(3)\/2 a$],
  [Similar triangles: sides $k$ $arrow.r$ perimeters $k$, areas $k^2$],
  [Centroid divides each median $2:1$ and makes 6 equal areas; midpoint triangle has $1\/4$ the area],
  [Right triangle: inradius $r = (a+b-c)\/2$, circumradius $R = c\/2$],
  [Circle: $C = 2 pi r$, $A = pi r^2$; chord: $r^2 = h^2 + (L\/2)^2$],
  [Sector $theta$: arc $= theta\/360 times 2 pi r$, area $= theta\/360 times pi r^2$],
  [Angle at centre $= 2 times$ angle at circumference; angle in a semicircle $= 90 degree$],
  [Tangent $perp$ radius; two tangents from an outside point are equal],
  [Common tangents: direct $= sqrt(d^2 - (r_1-r_2)^2)$, transverse $= sqrt(d^2 - (r_1+r_2)^2)$],
  [Regular $n$-gon: interior sum $(n-2)180 degree$, each exterior $360\/n$, diagonals $n(n-3)\/2$],
  [Square: $a^2$, diagonal $a sqrt(2)$. Rectangle: $l b$, diagonal $sqrt(l^2+b^2)$],
  [Rhombus $= 1\/2 d_1 d_2$; trapezium $= 1\/2 ("sum of parallel sides") times h$],
  [Cube $a^3$, TSA $6a^2$; cuboid $l b h$, TSA $2(l b + b h + h l)$],
  [Cylinder $pi r^2 h$, CSA $2 pi r h$, TSA $2 pi r (r+h)$],
  [Cone $1\/3 pi r^2 h$, CSA $pi r l$, TSA $pi r(r+l)$, $l = sqrt(r^2 + h^2)$],
  [Sphere $4\/3 pi r^3$, SA $4 pi r^2$; hemisphere $2\/3 pi r^3$, TSA $3 pi r^2$],
  [Frustum $V = 1\/3 pi h (R^2 + R r + r^2)$; recasting keeps the volume, never the surface],
  [Distance $= sqrt((x_2-x_1)^2 + (y_2-y_1)^2)$; midpoint $= ((x_1+x_2)\/2, (y_1+y_2)\/2)$],
  [Section formula $m:n$: $((m x_2 + n x_1)\/(m+n), (m y_2 + n y_1)\/(m+n))$],
  [Slope $= (y_2-y_1)\/(x_2-x_1)$; parallel $m_1 = m_2$; perpendicular $m_1 m_2 = -1$],
  [Triangle area $= 1\/2 |x_1(y_2-y_3) + x_2(y_3-y_1) + x_3(y_1-y_2)|$],
  [Point to line: $|a x_0 + b y_0 + c|\/sqrt(a^2+b^2)$],
  [$sin^2 theta + cos^2 theta = 1$; $tan theta = sin theta\/cos theta$],
  [$sin 30 = 1\/2$, $sin 45 = 1\/sqrt(2)$, $sin 60 = sqrt(3)\/2$; $tan 30 = 1\/sqrt(3)$, $tan 45 = 1$, $tan 60 = sqrt(3)$],
  [$tan("elevation") = "height"\/"horizontal distance"$; depression from the top $=$ elevation from the bottom],
))

// ============================================================
//  PART II — LOGICAL REASONING
// ============================================================

#section[Part II · Logical Reasoning]

#idx(13, "Series", (
  [Order of attack: differences $arrow.r$ second differences $arrow.r$ ratios $arrow.r$ $n^2, n^3, n!$ $arrow.r$ alternating or interleaved],
  [AP: $t_n = a + (n-1)d$, $S_n = n\/2[2a + (n-1)d]$],
  [GP: $t_n = a r^(n-1)$, $S_n = a(r^n-1)\/(r-1)$, $S_infinity = a\/(1-r)$ for $|r|<1$],
  [$sum n = n(n+1)\/2$; $sum n^2 = n(n+1)(2n+1)\/6$; $sum n^3 = [n(n+1)\/2]^2$],
  [Triangular $T_k = k(k+1)\/2$; $sum_(k=1)^n T_k = n(n+1)(n+2)\/6$],
  [$times k plus.minus c$ pattern: $5, 11, 23, 47$ is $times 2 + 1$],
  [Growing multiplier: $3, 6, 18, 72$ is $times 2, times 3, times 4$],
  [Squares $plus.minus c$: $2, 5, 10, 17, 26$ is $n^2 + 1$. Cubes $plus.minus c$: $2, 9, 28, 65$ is $n^3 + 1$],
  [Products $n(n+1)$: $2, 6, 12, 20, 30$. Factorials: $1, 2, 6, 24, 120$],
  [Fibonacci type: each term is the sum of the two before it],
  [Interleaved: split the odd positions from the even positions and solve each separately],
  [Letters: A$=1$ ... Z$=26$; EJOTY anchors E5, J10, O15, T20, Y25; wrap past Z back to A],
))

#idx(14, "Coding--Decoding & Cryptarithmetic", (
  [Position from the right $= 27 - ("position from the left")$],
  [Opposite letter of position $n$ is position $27 - n$ (A$arrow.l.r$Z, M$arrow.l.r$N)],
  [Shift with wrap: new position $= ((p + k - 1) mod 26) + 1$],
  [Six coding types: letter shift, word pattern, number coding, symbol coding, substitution, conditional],
  [Symbol coding: translate every symbol first, then apply BODMAS],
  [Substitution coding: match two sentences and take the code common to both for the common word],
  [Cryptarithmetic: one digit per letter, no leading zero, start at the units column],
  [Carry out of a 2-number column is 0 or 1; out of a 3-number column it is 0, 1 or 2],
  [$overline(A B) + overline(B A) = 11(A+B)$; #h(4pt) $overline(A B) - overline(B A) = 9(A-B)$],
  [$overline(A B A) + overline(B A B) = 111(A+B)$; #h(4pt) $overline(A B C) + overline(C B A) = 101(A+C) + 20B$],
  [$overline(A A) = 11A$, $overline(A A A) = 111A$, $overline(A A A A) = 1111A$],
  [$111 = 3 times 37$, #h(4pt) $1111 = 11 times 101$, #h(4pt) $11111 = 41 times 271$],
))

#idx(15, "Blood Relations, Directions & Ranking", (
  [Draw the tree: $+$ male, $-$ female, $=$ married, vertical line to children],
  [Same level $arrow.r$ siblings, cousins or spouses. Never parent and child],
  [Coded relations: solve one symbol at a time, left to right, writing each fact down],
  [Compass clockwise: N $arrow.r$ NE $arrow.r$ E $arrow.r$ SE $arrow.r$ S $arrow.r$ SW $arrow.r$ W $arrow.r$ NW],
  [Left turn $= 90 degree$ anticlockwise; right turn $= 90 degree$ clockwise; two same-side turns $=$ about turn],
  [Angles from North, clockwise: E $90 degree$, S $180 degree$, W $270 degree$, NE $45 degree$, SE $135 degree$, SW $225 degree$, NW $315 degree$],
  [Net displacement $= sqrt(h^2 + v^2)$, $v =$ North $-$ South, $h =$ East $-$ West],
  [If $|h| = |v|$ the distance is $h sqrt(2)$],
  [Shadows: just after sunrise they point West; just before sunset they point East],
  [Facing $D$: right hand points at $D$ turned $90 degree$ clockwise, left hand $90 degree$ anticlockwise],
  [$"Total" = ("rank from left") + ("rank from right") - 1$],
  [People strictly between $A$ and $B$ $=$ (B from left) $-$ (A from left) $- 1$],
  ["$x$ people between $A$ and $B$" $arrow.r$ their positions differ by $x + 1$],
))

#idx(16, "Seating Arrangement & Puzzles", (
  [Row: number seats 1 to $n$ from the West end. Circle: seat 1 at the top, number clockwise],
  [All facing North: left $=$ towards seat 1. All facing South: left $=$ towards seat $n$],
  [Facing the centre: left $=$ clockwise. Facing outward: left $=$ anticlockwise],
  [Circle of even $n$: opposite seat $k$ is $k + n\/2$ (wrap). Odd $n$: nobody is opposite anybody],
  [Square table of 8: corners and side-middles alternate, so corners are 1, 3, 5, 7],
  [Floors and stacks: number the bottom 1. "Above" means a larger number],
  ["Immediately left" $=$ 1 step. "Second to the left" $=$ 2 steps. "To the left of" $=$ position not fixed],
  ["Exactly $x$ between $A$ and $B$" $arrow.r$ seat numbers differ by $x + 1$],
  ["Exactly in the middle" of $n$ seats $arrow.r$ seat $(n+1)\/2$, and only when $n$ is odd],
  [Double rows face each other; seat $k$ of Row 1 faces seat $k$ of Row 2; left and right flip],
  [Clue order: fixed seats first, then chained clues, then two-case branches, then negative clues],
))

#idx(17, "Syllogisms & Logical Deduction", (
  [A conclusion follows only if it is true in *every* diagram that fits. One counter-diagram kills it],
  [Four types: A (All S are P), E (No S is P), I (Some S are P), O (Some S are not P)],
  [All S are P $arrow.r$ Some P are S. Never "All P are S"],
  [No S is P $arrow.r$ No P is S. Some S are P $arrow.r$ Some P are S. "Some S are not P" cannot be flipped],
  [All + All $arrow.r$ All. All + No $arrow.r$ No. Some + All $arrow.r$ Some. Some + No $arrow.r$ Some ... not],
  [No A is B + All B are C $arrow.r$ Some C are not A],
  [Nothing follows from: All + Some, Some + Some, No + No, or a first statement of the form "Some A are not B"],
  [Two negatives give nothing; one negative forces a negative conclusion],
  [Two "some" statements give nothing; one "some" forces a "some" conclusion],
  [Either--or: only when neither follows alone *and* the two form a complementary pair on the same terms],
  [Possibility: true unless the statements make it impossible --- find one legal diagram],
  ["Only a few A are B" and "Almost all A are B" both mean Some are and Some are not],
  ["Only A are B" means All B are A. "At least some A are B" means Some A are B],
))

#idx(18, "Critical Reasoning", (
  [Split every argument into evidence, conclusion and the unstated gap],
  [Conclusion markers: so, hence, therefore, thus, clearly, this shows, we must],
  [Assumption: negate it --- if the argument collapses, it is an assumption],
  [Conclusion: must come from the given words alone, with no outside knowledge],
  [Inference: probably true from the facts, without over-reaching beyond the data given],
  [Strong argument $=$ relevant $+$ substantial $+$ tied to the exact question asked],
  [Course of action: does it hit the cause, is it practical, is it in the actor's power?],
  [Reject a course of action that is extreme, disproportionately costly, or treats only a symptom],
  [Cause and effect: the event that came first and could stand alone is the cause],
  [Four labels: I causes II; II causes I; both from a common cause; both independent],
  [Strengthen $=$ close the gap or rule out a rival cause. Weaken $=$ supply a rival cause or a counter-case],
  [Assumption sits *before* the statement; inference comes *after* it],
  [Growth rate $times$ base $=$ actual increase --- a small rate on a big base can win],
  [An average can rise with nobody improving, if the low members left the group],
))

#idx(19, "Analogy, Classification & Non-Verbal", (
  [EJOTY anchors: E5, J10, O15, T20, Y25; A1, M13, N14, Z26],
  [Opposite letter: value $+$ opposite value $= 27$],
  [Analogy order of tests: fixed shift $arrow.r$ opposite letter $arrow.r$ reversal $arrow.r$ number patterns],
  [Number patterns to test: $n^2$, $n^3$, $n^2 plus.minus c$, $n^3 plus.minus c$, $n(n+1)$, $n(n-1)$, $n(n+1)\/2$],
  [Mirror image: reverse the order of the letters and flip each one left--right],
  [Letters unchanged by a vertical mirror: A H I M O T U V W X Y. Digits: 0 and 8],
  [Mirror time $= 11:60 - "actual time"$ (use $23:60$ if the hour reads 12)],
  [Water image: the order stays; each letter flips top--bottom. Unchanged: B C D E H I K O X. Digits: 0, 3, 8],
  [Fold $n$ times, punch $k$ holes clear of the folds $arrow.r k times 2^n$ holes],
  [A punch exactly on a fold line gives half as many holes],
  [Painted cube side $n$: 3 faces $8$; 2 faces $12(n-2)$; 1 face $6(n-2)^2$; 0 faces $(n-2)^3$],
  [Painted cuboid, $p=a-2, q=b-2, r=c-2$: 2 faces $4(p+q+r)$, 1 face $2(p q + q r + r p)$, 0 faces $p q r$],
  [Standard die: opposite faces add to 7],
  [Dice net: in a straight strip of four, the 1st and 3rd are opposite, and the 2nd and 4th],
  [Squares in an $n times n$ grid $= n(n+1)(2n+1)\/6$; for $n = 8$ it is 204],
  [Rectangles in an $m times n$ grid $= binom(m+1,2) binom(n+1,2)$],
  [Triangle cut into $n$ parts a side: totals $1, 5, 13, 27, 48, 78$ for $n = 1 dots 6$],
  [Triangle $A B C$ with $n$ points on $B C$ joined to $A$: $binom(n+2,2)$ triangles],
))

#idx(20, "Clocks, Calendars & Classic Puzzles", (
  [Minute hand $6 degree$/min; hour hand $0.5 degree$/min; relative $5.5 degree$/min],
  [Angle $theta = |30H - 5.5M|$; if $theta > 180 degree$ use $360 degree - theta$],
  [Angle exactly $theta$ between $H$ and $H+1$: $M = 2\/11 (30H plus.minus theta)$],
  [Hands together: $M = 60H\/11$; gap between coincidences $= 720\/11 = 65 5\/11$ minutes],
  [In 12 hours: coincide 11 times, opposite 11 times, right angles 22 times],
  [Mirror of a clock time $= 11:60 - "time"$ (use $23:60$ when the hour reads 12)],
  [A clock gaining $g$ min/hour shows $60 + g$ clock-minutes per 60 true minutes],
  [A clock drifting $d$ min/day is right again after $720 div d$ days],
  [Ordinary year $= 1$ odd day; leap year $= 2$ odd days],
  [Leap year: divisible by 4, but a century year must be divisible by 400],
  [100 yr $= 5$ odd days, 200 $= 3$, 300 $= 1$, 400 $= 0$; the calendar repeats every 400 years],
  [Day codes: 0 Sunday, 1 Monday, ... 6 Saturday],
  [Month running totals (ordinary year): 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365],
  [Day of a date $=$ (century odd days $+$ year odd days $+$ day-of-year) mod 7],
  [An ordinary year's calendar repeats after 6 or 11 years; a leap year's after 28],
  [$P(53$ Mondays$)$: ordinary $1\/7$, leap $2\/7$, a random year $71\/400$],
  [Ages: the difference of two ages never changes --- use it to check],
  [Weights on one pan: powers of 2 reach every whole number to $2^n - 1$],
  [Weights on both pans: powers of 3 reach every whole number to $(3^n - 1)\/2$],
  [Odd coin, direction known: $ceil(log_3 N)$ weighings. Unknown direction, 12 coins: 3 weighings],
  [Bridge and torch: move the two slowest together; cost $= min(f_1 + 2f_2 + b, #h(3pt) 2f_1 + a + b)$],
  [Two jugs $p, q$ measure $v$ iff $gcd(p,q)$ divides $v$ and $v <= max(p,q)$],
  [Matchsticks: a row of $n$ squares needs $3n+1$; an $n times n$ grid needs $2n(n+1)$],
))

// ============================================================
//  PART III — DATA INTERPRETATION & TEST CRAFT
// ============================================================

#section[Part III · Data Interpretation & Test Craft]

#idx(21, "DI: Tables, Bar, Line, Pie", (
  [Only four operations exist in DI: add a row, take a percent, take a ratio, compare two numbers],
  [$"% change" = ("new" - "old")\/"old" times 100$ --- the old value is always the base],
  [$"share of A" = A\/"total" times 100$],
  [Pie: value $= ("percent"\/100) times "total"$; central angle $= "percent" times 3.6$ degrees],
  [Pie: $"percent" = "angle"\/3.6$; the full circle is $360 degree = 100%$],
  [A line of *growth rates* still means the value is rising while the line sits above zero],
  [Linking charts: part multiplier $= (s_2\/s_1) times M$ --- a part can grow while its share falls],
  [Weighted growth: total growth $= w_1 g_1 + w_2 g_2 + dots$ with shares as fractions],
  [Average *rate* $= "total value"\/"total quantity"$, never the plain average of the rates],
  [Index numbers divide exactly like the real values do],
  [Compare $a\/b$ and $c\/d$ by cross-multiplying: $a d$ versus $c b$],
  [Approximation: round the answer, never the base, and only when the options are far apart],
))

#idx(22, "DI: Caselets, Mixed & Missing Data", (
  [Caselet method: grand total $arrow.r$ tree or table $arrow.r$ absolute numbers $arrow.r$ check line $arrow.r$ then read the questions],
  ["30% of the rest" takes a *new* base --- write down which box the percent sits on],
  [$n(A union B) = n(A) + n(B) - n(A inter B)$; neither $= "total" - n(A union B)$],
  [only $A = n(A) - n(A inter B)$; exactly one $= n(A union B) - n(A inter B)$],
  [$n(A union B union C) = sum n(A) - sum n(A inter B) + n(A inter B inter C)$],
  [exactly two $= sum [n(A inter B) - x]$ over the three pairs, with $x = n(A inter B inter C)$],
  [only $A = n(A) - n(A inter B) - n(A inter C) + x$],
  [Largest $n(A inter B) = min(n(A), n(B))$; smallest $= n(A) + n(B) - "total"$, or 0 if negative],
  [Smallest $n(A inter B inter C) = n(A)+n(B)+n(C) - 2 times "total"$, or 0 if negative],
  [Missing grid: find a row or column with exactly one blank, fill it, repeat. Cross-check both ways],
  ["Average of $n$ items is $a$" means $"sum" = n a$ --- convert every average to a sum first],
  [Radar: read each axis separately; the total is the sum of the axis values, never the area],
  [Bubble: three numbers per bubble --- $x$, $y$ and size. A big bubble is not a big $x$],
  [Combined percent change $= (w_1 g_1 + w_2 g_2)\/(w_1 + w_2)$ with $w$ the *old* sizes],
  [Split $T$ in $a:b:c$: one part $= T\/(a+b+c)$, then multiply],
))

#idx(23, "Data Sufficiency", (
  [The question is never "what is the answer" --- it is "is this enough for exactly one answer?"],
  [(a) I alone; (b) II alone; (c) both together, neither alone; (d) each alone; (e) not even together],
  [AD/BCE grid: test I alone. Works $arrow.r$ (a) or (d). Fails $arrow.r$ (b), (c) or (e)],
  [Combine the statements only after both have failed on their own],
  [A value question is settled only when the unknown is pinned to one number],
  [A yes/no question is settled by a definite *no* just as much as by a definite yes],
  [Two possible values $arrow.r$ not sufficient. $x^2 = 49$ gives $x = 7$ or $-7$],
  [$k$ unknowns need $k$ *independent* linear equations],
  [$2x + 3y = 12$ and $4x + 6y = 24$ are one equation, not two],
  [Non-linear pairs break the count: $x y = 12$ with $x + y = 7$ gives two answer pairs],
  [For a ratio, percentage or fraction answer, absolute values are usually not needed],
  [Both statements are always true and can never contradict each other],
  [Unless stated otherwise, a "number" may be negative, zero or a fraction],
))

#idx(24, "Full-Length Mock Papers", (
  [Seconds per question $=$ (minutes $times$ 60) $div$ questions],
  [Accuracy $=$ correct $div$ attempted. Score rate $=$ correct $div$ total],
  [Value of a guess $= p times 1 - (1-p) times m$ with $-m$ for a wrong answer],
  [A guess pays when $p > m\/(1+m)$: $m = 0.25$ needs $p > 0.2$; $m = 1\/3$ needs $p > 0.25$],
  [Blind guess: 4 options $p = 0.25$; 5 options $p = 0.20$],
  [Marks still needed $=$ target $-$ banked, divided by the marks per remaining question],
  [Three-pass rule: take the quick ones, return to the flagged ones, then guess what is left],
  [Guess freely with no negative marking; with negative marking only after eliminating two options],
))

#v(8pt)
#block(width: 100%, inset: 10pt, radius: 3pt, stroke: 1.2pt + ink, fill: boxbg)[
  #text(size: 10pt, weight: "bold", tracking: 1pt)[THE LAST WORD]
  #v(-3pt) #line(length: 100%, stroke: 0.5pt + rule) #v(4pt)
  #set text(size: 9.5pt)
  A formula you can quote but cannot use is worth nothing on test day. The ones that will
  actually earn you marks are the ones you have used in at least five solved problems.

  If a line on this page looks unfamiliar, do not memorise it. Go back to that chapter and
  work three examples that use it. Then come back. That is the whole method.
]
