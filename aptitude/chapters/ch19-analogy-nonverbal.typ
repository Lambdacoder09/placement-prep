#import "../lib/style.typ": *

#chapter(num: 19, title: "Analogy, Classification & Non-Verbal Reasoning", tagline: "Name the rule, then apply it to the new pair.")[

#section[What you need to know]

#formulas[
*Letter positions — learn these five anchors (EJOTY)*

#table(columns: 10,
[*Letter*],[E],[J],[O],[T],[Y],[A],[M],[N],[Z],
[*Position*],[5],[10],[15],[20],[25],[1],[13],[14],[26],
)

- To find any letter fast: jump to the nearest anchor, then step. R = T − 2 = 20 − 2 = 18.
- *Opposite-letter rule:* letter value + opposite value $= 27$. A#sym.arrow.l.r Z, B#sym.arrow.l.r Y, C#sym.arrow.l.r X, M#sym.arrow.l.r N. To get the opposite of a letter with value $v$, compute $27 - v$.

*Analogy — the 4 questions to ask, in this order*

+ Is the second term the first *shifted by a fixed number* of letters? ($+1, +2, +3, -1$ …)
+ Is it the *opposite letter* ($27 - v$)?
+ Is it the first term *reversed*, or the letters *re-ordered*?
+ For numbers: test $n^2$, $n^3$, $n^2 plus.minus c$, $n^3 plus.minus c$, $n(n+1)$, $n(n-1)$, $(n(n+1))/2$, digit operations.

*Classification (odd one out) — the 4 tests*

+ Same *number family*? (all squares, all cubes, all primes, all multiples of $k$)
+ Same *gap pattern* inside each group? (BD, FH, JL all have gap 2)
+ Same *category*? (metals vs alloy, cities vs river, tools vs product)
+ Same *shape property*? (sides, symmetry, closed vs open)

*Mirror image (a vertical mirror, placed to the right of the word)*

- The whole word is *read in reverse order*, and each letter is flipped left#sym.arrow.l.r right.
- Block capitals unchanged by a vertical flip: *A H I M O T U V W X Y*.
- Digits unchanged by a vertical flip: *0* and *8*.
- A word looks *exactly the same* in a mirror only if (i) every letter is in the list above, and (ii) the word is a palindrome. Example: MUM, TOOT, MOM, WOW.
- Mirror image of a clock time: $"mirror time" = 11:60 - "actual time"$ (use $23:60$ if the hour reads 12).

*Water image (a horizontal mirror, placed below the word)*

- The *order of letters does not change*. Each letter is flipped top#sym.arrow.l.r bottom.
- Block capitals unchanged by a horizontal flip: *B C D E H I K O X*.
- Digits unchanged by a horizontal flip: *0, 3, 8*.

*Paper folding and punching*

- Fold a sheet $n$ times, then punch $k$ holes clear of every fold line: holes on unfolding $= k times 2^n$.
- A punch that sits *exactly on a fold line* gives only *half* as many holes (the two mirrored holes merge into one).
- A cut at the folded corner that was the *centre* of the sheet opens into *one* shape at the centre, not four.

*Painted cube: side $n$, cut into $n^3$ unit cubes*

#table(columns: 2,
[Painted faces], [Number of unit cubes],
[exactly 3 (corners)], [$8$],
[exactly 2 (edges)], [$12(n-2)$],
[exactly 1 (faces)], [$6(n-2)^2$],
[exactly 0 (inside)], [$(n-2)^3$],
[at least 1], [$n^3 - (n-2)^3$],
)

Check: $8 + 12(n-2) + 6(n-2)^2 + (n-2)^3 = n^3$.

*Painted cuboid $a times b times c$, cut into unit cubes.* Write $p = a-2$, $q = b-2$, $r = c-2$.

- 3 faces: $8$ #h(10pt) 2 faces: $4(p + q + r)$
- 1 face: $2(p q + q r + r p)$ #h(10pt) 0 faces: $p q r$

*Dice*

- Standard die: opposite faces add to *7*. So $1$#sym.arrow.l.r$6$, $2$#sym.arrow.l.r$5$, $3$#sym.arrow.l.r$4$.
- If a face is seen next to *four different* numbers across the views, the *fifth* unseen number is opposite it.
- Two views with the *same face in the same slot*: the die was turned about that axis. The face that moves into the right-hand slot is the face that was at the *back*, i.e. the opposite of the old front.
- Net rule: in a *straight strip of four faces*, every second face is opposite (1st#sym.arrow.l.r 3rd, 2nd#sym.arrow.l.r 4th). Flaps hanging above and below the strip are opposite each other.

*Counting figures*

- Squares of all sizes in an $m times n$ grid of unit squares: $sum_(k=1)^(min(m,n)) (m-k+1)(n-k+1)$.
- Squares in an $n times n$ grid $= (n(n+1)(2n+1))/6$. For $n = 8$: $204$.
- Rectangles in an $m times n$ grid $= binom(m+1,2) times binom(n+1,2)$.
- Triangle with every side cut into $n$ parts and lines drawn parallel to all three sides:
  - upward triangles of size $k$: $(n-k+1)(n-k+2) div 2$
  - downward triangles of size $k$: $(n-2k+1)(n-2k+2) div 2$ (only while $n >= 2k$)
  - totals: $n = 1 arrow.r 1$, $2 arrow.r 5$, $3 arrow.r 13$, $4 arrow.r 27$, $5 arrow.r 48$, $6 arrow.r 78$
- Squares (including tilted ones) with corners on an $m times m$ grid of *dots*: $sum_(k=1)^(m-1) k(m-k)^2$. For $m = 5$: $50$.
- Triangle $A B C$ with $n$ points marked on $B C$ and all joined to $A$: number of triangles $= binom(n+2, 2)$.

*Symmetry of block capitals (used for figure odd-one-out)*

- Vertical axis only: A M T U V W Y
- Horizontal axis only: B C D E K
- Both axes: H I O X
- Neither: F G J L N P Q R S Z
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
What is the position number of Q? Which letter sits at position 12?
#sol[
Anchor O = 15. Q is 2 letters after O, so Q $= 15 + 2 = 17$.

Anchor J = 10. Position 12 is 2 letters after J: K = 11, L = 12.
]
#ans[Q = 17; position 12 = L]
]

#ex(2, tier: 0)[
Find the opposite letter of F.
#sol[
F $= 6$. Opposite value $= 27 - 6 = 21$. Anchor T = 20, so 21 = U.
]
#ans[U]
]

#ex(3, tier: 0)[
BD : FH :: JL : ?
#sol[
Inside each pair the gap is $+2$: B(2) D(4), F(6) H(8), J(10) L(12).

Across the pairs the first letters go B(2) #sym.arrow F(6) #sym.arrow J(10), a jump of $+4$.

Next first letter $= 10 + 4 = 14 = $ N. Second letter $= 14 + 2 = 16 = $ P.
]
#ans[NP]
]

#ex(4, tier: 0)[
6 : 42 :: 9 : ?
#sol[
Test $n(n+1)$: $6 times 7 = 42$. The rule fits.

So for 9: $9 times 10 = 90$.
]
#ans[90]
]

#ex(5, tier: 0)[
Odd one out: 25, 36, 48, 64.
#sol[
$25 = 5^2$, $36 = 6^2$, $64 = 8^2$. And $48$: $6^2 = 36$, $7^2 = 49$, so 48 is not a perfect square.
]
#ans[48]
]

#ex(6, tier: 0)[
Mirror image of MAT written in block capitals.
#sol[
Step 1 — reverse the order: T A M.

Step 2 — flip each letter left#sym.arrow.l.r right. T, A and M are all in the vertical-symmetry list, so each one looks unchanged.

The image reads TAM.
]
#ans[TAM]
]

#ex(7, tier: 0)[
Water image of CODE written in block capitals.
#sol[
A water image does *not* reverse the order. It flips each letter top#sym.arrow.l.r bottom.

C, O, D and E are all in the horizontal-symmetry list, so every letter looks unchanged.
]
#ans[CODE (it looks the same)]
]

#ex(8, tier: 0)[
A square sheet is folded in half 3 times, then one hole is punched clear of every fold. How many holes are there when the sheet is opened?
#sol[
Each fold doubles the number of layers: $1 arrow.r 2 arrow.r 4 arrow.r 8$ layers.

The punch goes through all 8 layers, so $1 times 2^3 = 8$ holes.
]
#ans[8 holes]
]


#section[Tier 1 — Service companies]
#tier-header(1)

#ex(9, tier: 1, asked: "TCS NQT pattern")[
MASK : NBTL :: FIRE : ?
#opts([GJSF], [GJSE], [GKSF], [FJSG])
#sol[
Compare the letters one by one.

M(13) #sym.arrow N(14): $+1$. #h(6pt) A(1) #sym.arrow B(2): $+1$. #h(6pt) S(19) #sym.arrow T(20): $+1$. #h(6pt) K(11) #sym.arrow L(12): $+1$.

The rule is $+1$ on every letter. Apply it to FIRE.

F(6) $arrow.r 7 = $ G. #h(6pt) I(9) $arrow.r 10 = $ J. #h(6pt) R(18) $arrow.r 19 = $ S. #h(6pt) E(5) $arrow.r 6 = $ F.
]
#ans[(a) GJSF]
#note[Why the others are wrong: (b) GJSE forgets to shift the last letter. (c) GKSF uses $+2$ on the second letter. (d) FJSG shifts the wrong letters.]
]

#ex(10, tier: 1, asked: "Infosys pattern")[
CAT : XZG :: DOG : ?
#sol[
Test the opposite-letter rule ($27 - v$).

C $= 3$, $27 - 3 = 24 = $ X. #sym.checkmark

A $= 1$, $27 - 1 = 26 = $ Z. #sym.checkmark

T $= 20$, $27 - 20 = 7 = $ G. #sym.checkmark

The rule holds. Now DOG:

D $= 4$, $27 - 4 = 23 = $ W.

O $= 15$, $27 - 15 = 12 = $ L.

G $= 7$, $27 - 7 = 20 = $ T.
]
#ans[WLT]
]

#trick[
*Opposite letters in one second.* Learn the five pairs A#sym.arrow.l.r Z, E#sym.arrow.l.r V, I#sym.arrow.l.r R, O#sym.arrow.l.r L, U#sym.arrow.l.r F (the vowels). Any other letter is only a step or two away from one of these. Check: E $= 5$, $27 - 5 = 22 = $ V. #sym.checkmark I $= 9$, $27 - 9 = 18 = $ R. #sym.checkmark
]

#ex(11, tier: 1, asked: "Accenture pattern")[
4 : 63 :: 6 : ?
#sol[
Test the cube family first. $4^3 = 64$, and $64 - 1 = 63$. So the rule is $n^3 - 1$.

For $n = 6$: $6^3 = 216$, so $216 - 1 = 215$.
]
#ans[215]
]

#ex(12, tier: 1, asked: "Wipro pattern")[
12 : 78 :: 16 : ?
#sol[
$12^2 = 144$, too big. $12 times 6 = 72$, close but not a clean rule.

Test the triangular-number rule $(n(n+1))/2$: $ (12 times 13)/2 = 156/2 = 78. $ It fits.

For $n = 16$: $ (16 times 17)/2 = 272/2 = 136. $
]
#ans[136]
]

#ex(13, tier: 1, asked: "TCS NQT pattern")[
Odd one out: 27, 64, 125, 196, 343.
#sol[
Test cubes: $3^3 = 27$, $4^3 = 64$, $5^3 = 125$, $7^3 = 343$. Four of the five are perfect cubes.

$196$: $5^3 = 125$ and $6^3 = 216$, so 196 is not a cube. (It is $14^2$, a square — that is the bait.)
]
#ans[196]
]

#trap[
*64 belongs to two families.* $64 = 8^2$ and $64 = 4^3$. In a list of cubes it is a cube; in a list of squares it is a square. Never mark 64 as the odd one out until you have tested every other number.
]

#ex(14, tier: 1, asked: "Capgemini pattern")[
Odd one out: ACE, BDF, CEG, DGI.
#sol[
Write the gaps inside each group.

ACE: A(1) C(3) E(5) #sym.arrow gaps $2, 2$.

BDF: B(2) D(4) F(6) #sym.arrow gaps $2, 2$.

CEG: C(3) E(5) G(7) #sym.arrow gaps $2, 2$.

DGI: D(4) G(7) I(9) #sym.arrow gaps $3, 2$.

DGI breaks the pattern.
]
#ans[DGI]
]

#ex(15, tier: 1, asked: "Cognizant pattern")[
Doctor : Hospital :: Pilot : ?
#opts([Airport], [Aeroplane], [Runway], [Passenger])
#sol[
Name the relation in one sentence: *a doctor does his job inside a hospital.*

Now test each option with the same sentence.

- Airport — a pilot does not do his job inside the airport; he passes through it.
- Aeroplane — a pilot does his job inside the aeroplane. #sym.checkmark
- Runway — that is where the plane moves, not where the pilot works.
- Passenger — that is a person, not a workplace.
]
#ans[(b) Aeroplane]
]

#trick[
*Say the relation out loud in a full sentence before you look at the options.* If your sentence works for exactly one option, that option is the answer. If it works for two, your sentence was too loose — make it tighter ("works inside", not "is connected with").
]

#ex(16, tier: 1, asked: "Accenture pattern")[
Which word, in block capitals, looks *exactly the same* in a vertical mirror?
#opts([MOTOR], [TOOT], [HOUSE], [WATER])
#sol[
Two conditions must both hold: every letter must be vertically symmetric, and the word must read the same backwards.

MOTOR — R is not vertically symmetric. Fails test 1.

TOOT — T, O, O, T are all in the list A H I M O T U V W X Y. #sym.checkmark Reversed, TOOT reads TOOT. #sym.checkmark

HOUSE — S and E are not vertically symmetric. Fails test 1.

WATER — R and E are not vertically symmetric. Fails test 1.
]
#ans[(b) TOOT]
]

#ex(17, tier: 1, asked: "Infosys pattern")[
Which word, in block capitals, is unchanged in its water image?
#opts([BOOK], [CHAIR], [DEEP], [HOUSE])
#sol[
A water image keeps the order of the letters. So we only need every letter to be horizontally symmetric. The list is B C D E H I K O X.

BOOK — B #sym.checkmark, O #sym.checkmark, O #sym.checkmark, K #sym.checkmark. All in the list.

CHAIR — A and R are not in the list.

DEEP — P is not in the list.

HOUSE — U and S are not in the list.
]
#ans[(a) BOOK]
]

#trap[
*Mirror reverses the order; water does not.* Students lose easy marks by reversing the letters for a water image. Vertical mirror #sym.arrow read backwards. Water #sym.arrow same order, letters flipped top to bottom.
]

#ex(18, tier: 1, asked: "TCS NQT pattern")[
A square sheet is folded in half twice (left over right, then top over bottom). Two holes are punched, both clear of every fold line. How many holes appear when the sheet is opened?
#sol[
Layers after fold 1: $2$. Layers after fold 2: $2 times 2 = 4$.

Each punch pierces all 4 layers, so each punch gives 4 holes.

Two punches give $2 times 4 = 8$ holes.

Using the formula: $k times 2^n = 2 times 2^2 = 2 times 4 = 8$.
]
#ans[8 holes]
]

#ex(19, tier: 1, asked: "Wipro pattern")[
A die is shown in two positions. In position 1 the top is 1, the front is 2 and the right is 3. In position 2 the top is 1, the front is 3 and the right is 4. Which number is opposite 2?
#sol[
The top face is 1 in both positions, so the die was only spun about the vertical axis.

In position 2 the front face is 3 — and 3 was the *right* face in position 1. So the die was turned a quarter turn, bringing the right face round to the front.

With that same quarter turn, the face that moves into the right-hand slot is the face that was at the *back*.

The back face in position 1 is the face opposite the front face, which was 2.

In position 2 the right face is 4. So the back face in position 1 was 4.

Therefore 4 is opposite 2.
]
#ans[4]
]

#ex(20, tier: 1, asked: "Cognizant pattern")[
How many squares of all sizes are there in a $4 times 4$ grid of unit squares?
#sol[
Count size by size.

Size $1 times 1$: $4 times 4 = 16$.

Size $2 times 2$: the top-left corner can sit in 3 columns and 3 rows, so $3 times 3 = 9$.

Size $3 times 3$: $2 times 2 = 4$.

Size $4 times 4$: $1 times 1 = 1$.

Total $= 16 + 9 + 4 + 1 = 30$.
]
#ans[30 squares]
]

#trick[
*Squares in an $n times n$ grid are just $1^2 + 2^2 + dots.c + n^2$, read backwards.* So a $5 times 5$ grid has $25 + 16 + 9 + 4 + 1 = 55$, and an $8 times 8$ chessboard has $204$. Learn 30, 55, 91, 140, 204 for $n = 4, 5, 6, 7, 8$.
]

#practice(tier: 1, time: "60 s/Q")[
+ RT : SU :: LN : ?
+ 9 : 90 :: 12 : ?
+ Odd one out: 49, 81, 100, 128.
+ What is the opposite letter of M?
+ Which word, in block capitals, looks exactly the same in a vertical mirror? (a) MUM (b) NOON (c) DOOR (d) LOOP
+ Write the water image of CHOICE (block capitals).
+ A sheet is folded in half 4 times and one hole is punched clear of every fold. How many holes on unfolding?
+ A standard die shows 4 on top. What is on the bottom face?
+ How many squares of all sizes are there in a $3 times 3$ grid of unit squares?
+ How many rectangles of all sizes are there in a $2 times 3$ grid of unit squares?
+ AZ : BY :: CX : ?
+ 7 : 48 :: 10 : ?
+ Odd one out: BD, DF, FH, HK.
+ How many rectangles of all sizes are there in a $3 times 3$ grid of unit squares?
+ A clock reads 3:40. What time does its mirror image show?
]

#key[
+ *MO.* R(18)T(20) $arrow.r$ S(19)U(21) is $+1$ on each letter; L(12)N(14) $arrow.r$ M(13)O(15).
+ *156.* Rule $n(n+1)$: $9 times 10 = 90$, so $12 times 13 = 156$.
+ *128.* $49 = 7^2$, $81 = 9^2$, $100 = 10^2$; $11^2 = 121$ and $12^2 = 144$, so 128 is not a square.
+ *N.* M $= 13$; $27 - 13 = 14 = $ N.
+ *(a) MUM.* M and U are vertically symmetric and MUM is a palindrome. NOON fails because N is not symmetric; DOOR and LOOP fail on R and P and are not palindromes.
+ *CHOICE.* Every letter (C, H, O, I, C, E) is horizontally symmetric, and the order does not change.
+ *16 holes.* $1 times 2^4 = 16$.
+ *3.* Opposite faces of a standard die add to 7, and $7 - 4 = 3$.
+ *14.* $9 + 4 + 1 = 14$.
+ *18.* $binom(3,2) times binom(4,2) = 3 times 6 = 18$.
+ *DW.* A(1)Z(26) $arrow.r$ B(2)Y(25): first letter $+1$, second letter $-1$. C(3)X(24) $arrow.r$ D(4)W(23).
+ *99.* Rule $n^2 - 1$: $7^2 - 1 = 48$, so $10^2 - 1 = 99$.
+ *HK.* The gaps are BD $= 2$, DF $= 2$, FH $= 2$, but HK $= 3$ (H is 8, K is 11).
+ *36.* $binom(4,2) times binom(4,2) = 6 times 6 = 36$.
+ *8:20.* Mirror time $= 11:60 - 3:40 = 8:20$.
]

#section[Tier 2 — Singapore & Thailand]
#tier-header(2)

#ex(21, tier: 2, asked: "Grab · pattern")[
A cube of side 5 cm is painted red on all six faces and then cut into 125 cubes of side 1 cm. How many of the small cubes have exactly 3, exactly 2, exactly 1, and no painted faces?
#sol[
Here $n = 5$, so $n - 2 = 3$.

*3 painted faces* — only the corners of the big cube: $8$.

*2 painted faces* — the cubes along the edges but not at the corners. Each edge has $n - 2 = 3$ such cubes, and there are 12 edges: $12 times 3 = 36$.

*1 painted face* — the cubes in the middle of each face. Each face has a $(n-2) times (n-2) = 3 times 3 = 9$ block of them, and there are 6 faces: $6 times 9 = 54$.

*0 painted faces* — the solid block hidden inside: $(n-2)^3 = 3^3 = 27$.

Check the total: $8 + 36 + 54 + 27 = 125$. #sym.checkmark
]
#ans[3 faces: 8; 2 faces: 36; 1 face: 54; 0 faces: 27]
]

#ex(22, tier: 2, asked: "Shopee · pattern")[
A wooden block measuring $6 times 4 times 3$ units is painted on every outside face and cut into 72 unit cubes. How many unit cubes have exactly 2 painted faces, and how many have none?
#sol[
Write $p = 6 - 2 = 4$, $q = 4 - 2 = 2$, $r = 3 - 2 = 1$.

*Exactly 2 faces* (edge cubes that are not corners): $ 4(p + q + r) = 4(4 + 2 + 1) = 4 times 7 = 28. $

*No paint* (the inner block): $ p q r = 4 times 2 times 1 = 8. $

Check with the other two counts. One face: $2(p q + q r + r p) = 2(8 + 2 + 4) = 2 times 14 = 28$. Three faces: $8$.

Total: $8 + 28 + 28 + 8 = 72$. #sym.checkmark
]
#ans[28 cubes with exactly 2 faces; 8 cubes with no paint]
]

#trap[
*A "$2$" in a dimension kills the inner block.* If any side of a cuboid is 1 or 2 units, then $p$, $q$ or $r$ is $0$ or negative, and the number of unpainted cubes is *zero*. Always compute $p q r$ before you answer, never assume it is positive.
]

#ex(23, tier: 2, asked: "Agoda · pattern")[
A cube of side 4 cm stands on a table. Every face *except the bottom* is painted. The cube is cut into 64 unit cubes. How many have no paint at all, and how many have exactly one painted face?
#sol[
Give each unit cube coordinates $(x, y, z)$ with $x, y, z in {1, 2, 3, 4}$ and $z = 1$ at the table.

The painted outer surfaces are $x = 1$, $x = 4$, $y = 1$, $y = 4$ and $z = 4$ (the top). The bottom $z = 1$ is *not* painted.

*No paint.* The cube must avoid all five painted surfaces. So $x in {2, 3}$, $y in {2, 3}$, and $z in {1, 2, 3}$ (any layer except the top). $ 2 times 2 times 3 = 12. $

*Exactly one painted face.* Count the two kinds separately.

Kind A — on one side wall only. Take $x = 1$. To avoid the other walls and the top: $y in {2, 3}$ (2 ways) and $z in {1, 2, 3}$ (3 ways), giving $2 times 3 = 6$. There are 4 side walls, so $4 times 6 = 24$.

Kind B — on the top only. $z = 4$, with $x in {2, 3}$ and $y in {2, 3}$: $2 times 2 = 4$.

Total with exactly one painted face $= 24 + 4 = 28$.
]
#ans[12 with no paint; 28 with exactly one painted face]
#note[For completeness: exactly 2 faces $= 20$ and exactly 3 faces $= 4$ (the four *top* corners only — the four bottom corners touch just two painted walls). Check: $12 + 28 + 20 + 4 = 64$. #sym.checkmark]
]

#ex(24, tier: 2, asked: "DBS · pattern")[
A die is shown in two positions. Position 1: top 5, front 1, right 2. Position 2: top 3, front 1, right 5. Which number is opposite 2?
#sol[
The *front* face is 1 in both positions. So the die was rolled about the front-to-back axis, like a wheel seen face-on.

In position 2, the face 5 sits on the right — and 5 was on the *top* in position 1. So the die rolled a quarter turn clockwise as seen from the front (top #sym.arrow right).

Under that same quarter turn, the face that moves into the *top* slot is the face that was on the *left*.

The left face in position 1 is the face opposite the right face, which was 2.

In position 2 the top is 3. So the left face in position 1 was 3.

Therefore 3 is opposite 2.
]
#ans[3]
]

#trick[
*One common face, two positions — use the "carousel" rule.* Fix the repeated face. The three remaining visible slots rotate in a ring. Whichever face steps into a slot came from the slot *before* it in the ring; the face that steps in from the hidden side is the *opposite* of the face that just left the ring.
]

#ex(25, tier: 2, asked: "Sea · pattern")[
In a $4 times 5$ grid of unit squares, how many rectangles of all sizes are there that are *not* squares?
#sol[
*Step 1 — all rectangles.* A rectangle is fixed by choosing 2 of the 5 horizontal lines and 2 of the 6 vertical lines. $ binom(5,2) times binom(6,2) = 10 times 15 = 150. $

*Step 2 — the squares.* Count size by size ($4$ rows, $5$ columns).

Size 1: $4 times 5 = 20$. #h(8pt) Size 2: $3 times 4 = 12$. #h(8pt) Size 3: $2 times 3 = 6$. #h(8pt) Size 4: $1 times 2 = 2$.

Squares $= 20 + 12 + 6 + 2 = 40$.

*Step 3 — subtract.* $150 - 40 = 110$.
]
#ans[110]
]

#ex(26, tier: 2, asked: "GIC · pattern")[
$(4, 9, 25) : (2, 3, 5) :: (36, 64, 121) : ?$
#sol[
Look at the first triple against the second.

$4 arrow.r 2$, $9 arrow.r 3$, $25 arrow.r 5$. Each output is the *square root* of the input.

Apply the same rule.

$sqrt(36) = 6$, #h(6pt) $sqrt(64) = 8$, #h(6pt) $sqrt(121) = 11$.
]
#ans[(6, 8, 11)]
]

#ex(27, tier: 2, asked: "SCB · pattern")[
The value of a word is the sum of the position numbers of its letters. Given MATH : 42 :: FACE : ?, find the missing value. Then say which of CAB, BAD, ACE — if any — has the same value as FACE.
#sol[
*Check the given pair.* M $= 13$, A $= 1$, T $= 20$, H $= 8$. $ 13 + 1 + 20 + 8 = 42. #sym.checkmark $

*Apply to FACE.* F $= 6$, A $= 1$, C $= 3$, E $= 5$. $ 6 + 1 + 3 + 5 = 15. $

*Now the three test words.*

CAB $= 3 + 1 + 2 = 6$.

BAD $= 2 + 1 + 4 = 7$.

ACE $= 1 + 3 + 5 = 9$.

None equals 15. The closest, ACE, is short by 6.
]
#ans[FACE $= 15$; none of CAB (6), BAD (7), ACE (9) matches it]
]

#ex(28, tier: 2, asked: "LINE MAN · pattern")[
A square sheet is folded left over right, then top over bottom. A small square notch is cut from the corner of the folded packet that was the *centre* of the original sheet. What is seen when the sheet is opened?
#sol[
After the two folds the packet is one quarter of the sheet. Its four corners come from four different places:

- one corner is the *centre* of the original sheet,
- two corners are *midpoints* of the sheet's edges,
- one corner is a *corner* of the sheet.

The notch is cut at the centre corner. All 4 layers are cut at once, and all 4 of those quarter-notches meet at the same point — the centre.

So the four quarter-holes join into *one* hole, sitting exactly at the centre of the sheet. Its side is twice the side of the notch that was cut.
]
#ans[A single square hole at the centre of the sheet, of side twice the cut notch]
]

#trap[
*A cut at the centre corner does not give four holes.* Cuts at that corner *merge*. Cuts at the far corner (a real corner of the sheet) give four separate holes, one in each corner. Always ask: does this corner of the packet sit on a fold line?
]

#ex(29, tier: 2, asked: "Razer · pattern")[
In a figure series, figure 1 is a triangle containing 1 dot, with an arrow pointing north. In each next figure the polygon gains one side, the number of dots increases by 2, and the arrow turns $90°$ clockwise. Describe figure 5.
#sol[
Treat each attribute as its own little series, and use $n = 5$, so there are $5 - 1 = 4$ steps from figure 1.

*Sides:* start 3, add 1 each step. $3 + 4 times 1 = 7$ #sym.arrow a heptagon.

*Dots:* start 1, add 2 each step. $1 + 4 times 2 = 1 + 8 = 9$ dots.

*Arrow:* start north, turn $90°$ clockwise each step. Total turn $= 4 times 90° = 360°$, which is one full turn. The arrow points north again.
]
#ans[A heptagon (7 sides) with 9 dots inside, arrow pointing north]
]

#trick[
*Split a figure series into separate columns, one per attribute.* Shape, count of elements, shading, rotation, position. Solve each column on its own like a number series. Never try to read the whole picture at once.
]

#ex(30, tier: 2, asked: "Grab · pattern")[
An equilateral triangle has each side divided into 3 equal parts, and lines are drawn parallel to all three sides. How many triangles of all sizes are there?
#sol[
Count upward triangles and downward triangles separately. Here $n = 3$.

*Upward, size 1:* the small triangles sit in 3 rows. Row 1 holds 1, row 2 holds 2, row 3 holds 3. Total $1 + 2 + 3 = 6$.

*Upward, size 2:* such a triangle needs 2 rows of room, so its apex can only sit in the top $3 - 2 + 1 = 2$ rows. Row 1 holds 1 apex, row 2 holds 2. Total $1 + 2 = 3$.

*Upward, size 3:* the whole triangle: $1$.

Upward total $= 6 + 3 + 1 = 10$.

*Downward, size 1:* the inverted unit triangles fill the gaps between the upward ones. Row 2 holds 1, row 3 holds 2. Total $1 + 2 = 3$.

*Downward, size 2:* such a triangle needs $2 times 2 = 4$ rows, but there are only 3. So none.

Downward total $= 3$.

Grand total $= 10 + 3 = 13$.
]
#ans[13 triangles]
#note[Same answer straight from the formulas. Upward, $k = 1, 2, 3$: $(3 times 4)/2 + (2 times 3)/2 + (1 times 2)/2 = 6 + 3 + 1 = 10$. Downward, $k = 1$: $((3-2+1)(3-2+2))/2 = (2 times 3)/2 = 3$. Total $= 13$.]
]

#practice(tier: 2, time: "100 s/Q")[
+ A cube of side 5 is painted on all faces and cut into 125 unit cubes. How many have exactly one painted face?
+ A block $4 times 3 times 2$ is painted on all faces and cut into 24 unit cubes. How many have exactly two painted faces?
+ A die is shown twice. Position 1: top 2, front 4, right 5. Position 2: top 2, front 5, right 3. Which number is opposite 4?
+ How many squares of all sizes are in a $6 times 6$ grid of unit squares?
+ In a $4 times 4$ grid of unit squares, how many rectangles are not squares?
+ GATE : HBUF :: MOCK : ?
+ 1234 : 2468 :: 3102 : ?
+ A square sheet is folded left over right, then top over bottom. A small square is cut at the corner of the packet that was the centre of the sheet. Describe what is seen on unfolding.
+ A clock reads 9:45. What time does its mirror image show?
+ Odd one out among block capitals by symmetry: A, M, T, H.
+ A triangle has each side divided into 4 equal parts, with lines parallel to all three sides. How many triangles of all sizes?
+ Figure 1 is a square with 2 dots and an arrow pointing north. Each next figure adds 3 dots and turns the arrow $45°$ clockwise. Describe figure 6.
]

#key[
+ *54.* $6(n-2)^2 = 6 times 3^2 = 54$.
+ *12.* $p = 2$, $q = 1$, $r = 0$; $4(p+q+r) = 4 times 3 = 12$. (Note $p q r = 0$, so *no* cube is unpainted.)
+ *3.* The top stays 2, so the die spun about the vertical axis; the new front (5) was the old right, so the new right (3) was the old back, which is the opposite of the old front 4.
+ *91.* $36 + 25 + 16 + 9 + 4 + 1 = 91$.
+ *70.* Rectangles $= binom(5,2)^2 = 100$; squares $= 16+9+4+1 = 30$; $100 - 30 = 70$.
+ *NPDL.* Every letter shifts $+1$: M#sym.arrow N, O#sym.arrow P, C#sym.arrow D, K#sym.arrow L.
+ *6204.* Each digit is doubled: $3 arrow.r 6$, $1 arrow.r 2$, $0 arrow.r 0$, $2 arrow.r 4$.
+ *One square hole at the centre*, of side twice the cut. The four quarter-cuts meet at the centre and merge.
+ *2:15.* $11:60 - 9:45 = 2:15$.
+ *H.* A, M and T have a vertical axis of symmetry only; H has both a vertical and a horizontal axis.
+ *27.* Upward: $10 + 6 + 3 + 1 = 20$; downward: $6 + 1 = 7$; total 27.
+ *A square with 17 dots, arrow pointing south-west.* Dots $= 2 + 5 times 3 = 17$; turn $= 5 times 45° = 225°$ clockwise from north, which points south-west. (The shape does not change — only two attributes were given a rule.)
]

#section[Tier 3 — Product companies]
#tier-header(3)

#ex(31, tier: 3, asked: "Google · pattern")[
A cube of side $n$ (an integer, $n > 2$) is painted on all six faces and cut into $n^3$ unit cubes. For which $n$ is the number of unit cubes with exactly *one* painted face equal to the number with *no* painted face?
#sol[
*Insight: both counts are powers of the same quantity $n - 2$, so the equation collapses to a single power.*

One painted face: $6(n-2)^2$.

No painted face: $(n-2)^3$.

Set them equal: $ 6(n-2)^2 = (n-2)^3. $

Since $n > 2$, $(n-2)^2 != 0$, so divide both sides by $(n-2)^2$: $ 6 = n - 2 arrow.r.double n = 8. $

*Check with $n = 8$.*

One face: $6(8-2)^2 = 6 times 36 = 216$.

No face: $(8-2)^3 = 6^3 = 216$. #sym.checkmark
]
#ans[$n = 8$]
]

#ex(32, tier: 3, asked: "Amazon · pattern")[
A cube of side $n$ is painted on all six faces and cut into $n^3$ unit cubes. One unit cube is picked at random. What is the expected number of painted faces on it? Evaluate for $n = 5$.
#sol[
*Insight: do not classify the cubes at all. Count painted unit-squares on the whole surface, then divide.*

The big cube has 6 faces. Each face is an $n times n$ square, so it carries $n^2$ painted unit-squares.

Total painted unit-squares $= 6 n^2$.

Every one of those unit-squares sits on exactly one unit cube, so the *sum* of painted faces over all $n^3$ unit cubes is $6 n^2$.

Expected value $= "total" / "number of cubes" = (6 n^2)/n^3 = 6/n$.

For $n = 5$: $6/5 = 1.2$.
]
#ans[$6/n$; for $n = 5$ it is $1.2$ painted faces]
#note[Sanity check for $n = 3$: $6/3 = 2$. By direct count: $8 times 3 + 12 times 2 + 6 times 1 + 1 times 0 = 24 + 24 + 6 = 54$, and $54 div 27 = 2$. #sym.checkmark]
]

#trick[
*Counting the surface beats classifying the pieces.* Any question of the form "total painted faces" or "average painted faces" is answered by $6n^2$ in one line. Only questions that ask for a *specific class* (exactly 2, exactly 0) need the four formulas.
]

#ex(33, tier: 3, asked: "Goldman Sachs · pattern")[
On a standard $8 times 8$ chessboard, how many rectangles can be drawn along the grid lines, and how many of them are *not* squares?
#sol[
*Insight: a rectangle is not a shape you hunt for — it is a choice of 2 horizontal lines and 2 vertical lines.*

The board has $8 + 1 = 9$ horizontal lines and 9 vertical lines.

*All rectangles.* $ binom(9,2) times binom(9,2) = 36 times 36 = 1296. $

(Check $binom(9,2) = (9 times 8)/2 = 36$.)

*Squares.* A $k times k$ square has its top-left corner in $(9-k)$ positions across and $(9-k)$ down, so there are $(9-k)^2$ of them.

$k = 1: 64$, $k = 2: 49$, $k = 3: 36$, $k = 4: 25$, $k = 5: 16$, $k = 6: 9$, $k = 7: 4$, $k = 8: 1$.

Sum $= 64 + 49 = 113$; $113 + 36 = 149$; $149 + 25 = 174$; $174 + 16 = 190$; $190 + 9 = 199$; $199 + 4 = 203$; $203 + 1 = 204$.

*Non-squares.* $1296 - 204 = 1092$.
]
#ans[1296 rectangles in all; 1092 of them are not squares]
]

#ex(34, tier: 3, asked: "Microsoft · pattern")[
An equilateral triangle has each side divided into 6 equal parts, and lines are drawn parallel to all three sides. How many triangles of all sizes are there?
#sol[
*Insight: upward triangles and downward triangles obey two different counting laws. Count them apart, then add.*

*Upward triangles of size $k$.* Their apexes form a triangular block with $n - k + 1$ rows, so the count is $((n-k+1)(n-k+2))/2$ with $n = 6$.

$k = 1: (6 times 7)/2 = 21$

$k = 2: (5 times 6)/2 = 15$

$k = 3: (4 times 5)/2 = 10$

$k = 4: (3 times 4)/2 = 6$

$k = 5: (2 times 3)/2 = 3$

$k = 6: (1 times 2)/2 = 1$

Upward total $= 21 + 15 + 10 + 6 + 3 + 1 = 56$.

*Downward triangles of size $k$.* A downward triangle of size $k$ needs $2k$ rows of room, so the count is $((n-2k+1)(n-2k+2))/2$, and only while $n >= 2k$.

$k = 1: (5 times 6)/2 = 15$

$k = 2: (3 times 4)/2 = 6$

$k = 3: (1 times 2)/2 = 1$

Downward total $= 15 + 6 + 1 = 22$.

*Grand total* $= 56 + 22 = 78$.
]
#ans[78 triangles]
]

#trap[
*Downward triangles are the ones everybody forgets.* For $n = 6$ they are 22 out of 78 — more than a quarter of the answer. Write two separate columns on your rough sheet before you count anything.
]

#ex(35, tier: 3, asked: "Adobe · pattern")[
A square sheet is folded in half 4 times. Three holes are then punched. Two of them are clear of every fold line; the third sits exactly on the last fold line. How many holes appear when the sheet is opened?
#sol[
*Insight: a punch on a fold line pierces the same number of layers, but the unfolded holes come in touching pairs that merge into one.*

After 4 folds the packet has $2^4 = 16$ layers.

*Punch A (clear of folds):* pierces 16 layers, and the 16 holes land at 16 separate points. $arrow.r 16$ holes.

*Punch B (clear of folds):* the same. $arrow.r 16$ holes.

*Punch C (on a fold line):* it still pierces 16 layers. But the fold line is a mirror line, so the holes come out in 8 mirror-pairs, and each pair sits astride the crease, touching. Each pair opens as a *single* hole. $arrow.r 8$ holes.

Total $= 16 + 16 + 8 = 40$.
]
#ans[40 holes]
]

#ex(36, tier: 3, asked: "Uber · pattern")[
A cube net is laid flat as a straight strip of four faces A, B, C, D (in that order). Face E is attached above C, and face F is attached below A. List the three pairs of opposite faces, and name every face that touches face B.
#sol[
*Insight: folding a straight strip of four faces wraps a belt around the cube, so faces two apart in the strip end up back to back.*

*The belt.* A, B, C, D fold into a ring around the cube. Going round the ring, A sits next to B and D; C also sits next to B and D. A face is opposite whatever it does *not* sit next to, so: $ A "opposite" C, quad B "opposite" D. $

*The flaps.* The belt leaves exactly two faces open — the top and the bottom. E and F are the only faces left, so they must fill those two. Therefore $ E "opposite" F. $

(It does not matter that E hangs off C and F hangs off A. Once the belt is wrapped, any flap on the strip folds onto the top or the bottom, and the two flaps cannot land on the same one.)

*Faces touching B.* Every face of a cube touches all four faces except its own opposite. B's opposite is D. So B touches A, C, E and F.
]
#ans[Opposite pairs: A–C, B–D, E–F. Face B touches A, C, E and F.]
]

#ex(37, tier: 3, asked: "D. E. Shaw · pattern")[
A cube of side $n$ is painted and cut into $n^3$ unit cubes. What is the smallest $n$ for which *more than half* of the unit cubes have no paint at all?
#sol[
*Insight: the unpainted fraction is $(1 - 2/n)^3$, so the question is about one cube root, not about $n$ itself.*

Unpainted fraction $= (n-2)^3 / n^3 = (1 - 2/n)^3$.

We need $ (1 - 2/n)^3 > 1/2. $

Take cube roots. $root(3, 1/2) approx 0.7937$.

So we need $1 - 2/n > 0.7937$, that is $2/n < 0.2063$, that is $n > 2 / 0.2063 approx 9.69$.

The smallest integer is $n = 10$.

*Check $n = 10$:* unpainted $= 8^3 = 512$ out of $1000$. $512/1000 = 0.512 > 0.5$. #sym.checkmark

*Check $n = 9$:* unpainted $= 7^3 = 343$ out of $729$. $343/729 approx 0.470 < 0.5$. (too small)
]
#ans[$n = 10$]
]

#ex(38, tier: 3, asked: "Google · pattern")[
Dots are arranged in a $5 times 5$ square grid. How many squares can be formed with all four corners on grid dots, counting *tilted* squares as well?
#sol[
*Insight: every tilted square sits snugly inside exactly one axis-aligned square whose corners are also grid dots. So group the squares by that bounding box.*

Take a bounding box of side $k$ (measured in grid steps). Inside it you can draw:

- the box itself (1 square), and
- a tilted square for each way of sliding the corner along the box's side: the corner can sit at distance $1, 2, dots, k-1$ from the box's own corner.

So each $k times k$ bounding box holds exactly $k$ squares.

*How many $k times k$ bounding boxes are there?* On a $5 times 5$ dot grid, the top-left dot of a $k times k$ box has $(5-k)$ choices across and $(5-k)$ down, so $(5-k)^2$ boxes.

Now total up: $ sum_(k=1)^(4) k (5-k)^2 . $

$k = 1: 1 times 4^2 = 1 times 16 = 16$

$k = 2: 2 times 3^2 = 2 times 9 = 18$

$k = 3: 3 times 2^2 = 3 times 4 = 12$

$k = 4: 4 times 1^2 = 4 times 1 = 4$

Total $= 16 + 18 + 12 + 4 = 50$.

Of these, the axis-aligned ones are $16 + 9 + 4 + 1 = 30$, so 20 squares are tilted.
]
#ans[50 squares (30 straight, 20 tilted)]
]

#trick[
*"Squares on a dot grid" versus "squares in a grid of cells".* If the question shows *dots*, tilted squares count and the answer uses $sum k(m-k)^2$. If it shows a *grid of little boxes*, only straight squares count and the answer uses $sum (m-k+1)(n-k+1)$. Read which one is drawn before you start.
]

#practice(tier: 3, time: "4 min/Q")[
+ A cube of side $n$ is painted and cut into $n^3$ unit cubes. For which $n$ is the number with no paint exactly 3 times the number with exactly 2 painted faces?
+ A cube of side 6 is painted and cut into 216 unit cubes. One is picked at random. What is the expected number of painted faces on it?
+ In a $6 times 6$ grid of unit squares, how many rectangles are not squares?
+ A triangle has each side divided into 5 equal parts, with lines parallel to all three sides. How many triangles of all sizes?
+ A square sheet is folded in half 3 times. Two holes are punched: one clear of every fold, one exactly on the last fold line. How many holes on unfolding?
+ Odd one out: 1, 5, 14, 30, 55, 90.
+ Dots are arranged in a $4 times 4$ square grid. How many squares (including tilted ones) have all four corners on grid dots?
+ A cube is painted with 3 colours, each colour covering one pair of opposite faces. It is cut into 64 unit cubes. How many unit cubes show 3 different colours?
]

#key[
+ *$n = 8$.* We need $(n-2)^3 = 3 times 12(n-2) = 36(n-2)$. Divide by $(n-2)$ (non-zero since $n > 2$): $(n-2)^2 = 36$, so $n - 2 = 6$ and $n = 8$. Check: no paint $= 6^3 = 216$; exactly 2 faces $= 12 times 6 = 72$; $3 times 72 = 216$. #sym.checkmark
+ *1.* Total painted unit-squares $= 6 times 6^2 = 216$. Divide by 216 unit cubes: $216/216 = 1$. (Same as $6/n = 6/6 = 1$.)
+ *350.* All rectangles $= binom(7,2)^2 = 21^2 = 441$. Squares $= 36+25+16+9+4+1 = 91$. $441 - 91 = 350$.
+ *48.* Upward: $15 + 10 + 6 + 3 + 1 = 35$. Downward ($n = 5$): $k=1: (4 times 5)/2 = 10$; $k=2: (2 times 3)/2 = 3$. Downward $= 13$. Total $35 + 13 = 48$.
+ *12.* Three folds give $2^3 = 8$ layers. The free punch gives 8 holes; the punch on the fold gives 8 pierced layers whose holes merge in mirror-pairs, giving 4 holes. $8 + 4 = 12$.
+ *90.* The list is the count of squares in a $k times k$ grid: $1, 5, 14, 30, 55, 91$. The sixth term should be 91, not 90.
+ *20.* $sum_(k=1)^3 k(4-k)^2 = 1 times 9 + 2 times 4 + 3 times 1 = 9 + 8 + 3 = 20$. (Straight: 14; tilted: 6.)
+ *8.* Only the 8 corner cubes have 3 painted faces. The three faces meeting at a corner are mutually adjacent, so they belong to three *different* opposite-pairs and therefore carry three different colours. No other unit cube has 3 painted faces at all.
]

#section[Mixed set — exam conditions]

#practice(tier: 1, time: "30 min for all 18")[
+ CAT : XZG :: BAT : ?
+ A cube of side 3 is painted on all faces and cut into 27 unit cubes. How many have no paint?
+ Odd one out: 121, 144, 169, 180.
+ How many squares of all sizes are in a $5 times 5$ grid of unit squares?
+ Write the mirror image of MOM (block capitals).
+ A sheet is folded in half 5 times and one hole is punched clear of every fold. How many holes on unfolding?
+ 6 : 216 :: 9 : ?
+ How many rectangles of all sizes are in a $3 times 4$ grid of unit squares?
+ A die is shown twice. Position 1: top 6, front 1, right 2. Position 2: top 6, front 2, right 4. Which number is opposite 1?
+ Write the water image of BIKE (block capitals).
+ PRIME : QSJNF :: SOLID : ?
+ A block $5 times 4 times 3$ is painted on all faces and cut into 60 unit cubes. How many have no paint?
+ Odd one out: ACE, EGI, IKM, MOR.
+ A triangle has each side divided into 2 equal parts, with lines parallel to all three sides. How many triangles of all sizes?
+ A clock reads 7:15. What time does its mirror image show?
+ Dots form a $4 times 4$ square grid. How many squares, including tilted ones, have all four corners on dots?
+ A cube of side $n$ is painted and cut into $n^3$ unit cubes. For which $n$ are the "exactly 2 faces" and "exactly 1 face" counts equal?
+ 15 : 240 :: 18 : ?
]

#key[
+ *YZG.* Opposite-letter rule: B(2) $arrow.r 27-2 = 25 = $ Y; A $arrow.r$ Z; T(20) $arrow.r 7 = $ G.
+ *1.* $(3-2)^3 = 1^3 = 1$.
+ *180.* $121 = 11^2$, $144 = 12^2$, $169 = 13^2$; $13^2 = 169$ and $14^2 = 196$, so 180 is not a square.
+ *55.* $25 + 16 + 9 + 4 + 1 = 55$.
+ *MOM.* M and O are vertically symmetric and MOM is a palindrome, so the image is identical.
+ *32.* $1 times 2^5 = 32$.
+ *729.* Rule $n^3$: $6^3 = 216$, so $9^3 = 729$.
+ *60.* $binom(4,2) times binom(5,2) = 6 times 10 = 60$.
+ *4.* Top stays 6, so the die spun about the vertical axis. The new front (2) was the old right, so the new right (4) was the old back — the opposite of the old front 1.
+ *BIKE.* B, I, K and E are all horizontally symmetric, and a water image keeps the order.
+ *TPMJE.* Every letter shifts $+1$: S#sym.arrow T, O#sym.arrow P, L#sym.arrow M, I#sym.arrow J, D#sym.arrow E.
+ *6.* $p = 3$, $q = 2$, $r = 1$; $p q r = 3 times 2 times 1 = 6$.
+ *MOR.* Gaps are $2, 2$ in ACE, EGI and IKM; MOR has M(13) O(15) R(18), gaps $2, 3$.
+ *5.* Upward: $3 + 1 = 4$; downward: $1$. Total 5.
+ *4:45.* $11:60 - 7:15 = 4:45$.
+ *20.* $sum_(k=1)^3 k(4-k)^2 = 9 + 8 + 3 = 20$.
+ *$n = 4$.* $12(n-2) = 6(n-2)^2 arrow.r 2 = n-2 arrow.r n = 4$. Check: $12 times 2 = 24$ and $6 times 2^2 = 24$. #sym.checkmark
+ *342.* Rule $n(n+1)$: $15 times 16 = 240$, so $18 times 19 = 342$.
]

#revision[
*Letters.* EJOTY: E 5, J 10, O 15, T 20, Y 25. Opposite letter: $27 - v$. Vowel pairs A#sym.arrow.l.r Z, E#sym.arrow.l.r V, I#sym.arrow.l.r R, O#sym.arrow.l.r L, U#sym.arrow.l.r F.

*Analogy order of tests.* fixed shift #sym.arrow opposite letter #sym.arrow reversal / re-order #sym.arrow number family ($n^2$, $n^3$, $n^2 plus.minus c$, $n^3 plus.minus c$, $n(n+1)$, $(n(n+1))/2$) #sym.arrow digit operation.

*Classification tests.* number family / gap pattern / category / shape property.

*Mirror (vertical).* Reverse the order, flip each letter side to side. Unchanged letters A H I M O T U V W X Y; digits 0, 8. Clock: $11:60 - "time"$.

*Water (horizontal).* Keep the order, flip each letter top to bottom. Unchanged letters B C D E H I K O X; digits 0, 3, 8.

*Symmetry of capitals.* Vertical only: A M T U V W Y. Horizontal only: B C D E K. Both: H I O X.

*Paper folding.* $n$ folds, $k$ free punches $arrow.r k times 2^n$ holes. A punch on a fold line gives half as many. A cut at the packet corner that was the *centre* opens as one shape at the centre.

*Painted cube, side $n$.* 3 faces $= 8$; 2 faces $= 12(n-2)$; 1 face $= 6(n-2)^2$; 0 faces $= (n-2)^3$; at least one $= n^3 - (n-2)^3$. Expected painted faces $= 6/n$.

*Painted cuboid,* $p = a-2$, $q = b-2$, $r = c-2$: 3 faces $= 8$; 2 faces $= 4(p+q+r)$; 1 face $= 2(p q + q r + r p)$; 0 faces $= p q r$.

*Dice.* Standard die: opposite faces sum to 7. Seen next to four different numbers $arrow.r$ the fifth is opposite. Two views sharing a slot: the face entering the right-hand slot came from the back, i.e. opposite the old front. Straight strip of four in a net: 1st#sym.arrow.l.r 3rd, 2nd#sym.arrow.l.r 4th; the two flaps are opposite each other.

*Counting figures.*
- Squares in $m times n$ cells $= sum_k (m-k+1)(n-k+1)$; for $n times n$ this is $(n(n+1)(2n+1))/6$ #sym.arrow 5, 14, 30, 55, 91, 140, 204.
- Rectangles in $m times n$ cells $= binom(m+1,2) binom(n+1,2)$.
- Triangle cut into $n$ parts per side: totals $1, 5, 13, 27, 48, 78$ for $n = 1 dots 6$. Upward size $k$: $(n-k+1)(n-k+2) div 2$. Downward size $k$: $(n-2k+1)(n-2k+2) div 2$ while $n >= 2k$.
- Squares on an $m times m$ *dot* grid, tilted included $= sum_(k=1)^(m-1) k(m-k)^2$ #sym.arrow 1, 6, 20, 50 for $m = 2, 3, 4, 5$.

*The top 5 traps*

+ *Water image does not reverse the letters.* Only the mirror image does.
+ *64 is both a square and a cube* — decide the family from the other numbers first.
+ *Downward triangles.* Forgetting them costs you a quarter of the answer.
+ *A zero in $p q r$.* If a cuboid has a side of 1 or 2, no cube is unpainted.
+ *Folded-corner cuts merge.* A cut at the centre corner gives one hole, not four; a punch on a fold gives half the expected number.
]

]
