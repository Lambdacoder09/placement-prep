# Chapter 16 — Seating Arrangement & Puzzles

*Fix the certain seats first, then squeeze*

## What you need to know

**QUICK REFERENCE**

**1. Always draw the same picture.**
For a **row**, draw the seats left to right on the page and number them 1, 2, 3, ... from the **West** end. For a **circle**, draw 1 at the top and number **clockwise**. Keep this habit and every clue reads the same way every time.

**2. Left and right in a row**

#table(columns: (auto, auto, auto),
  [**Everyone faces**], [**A person's LEFT is**], [**A person's RIGHT is**],
  [North], [West side — towards seat 1], [East side — towards seat $n$],
  [South], [East side — towards seat $n$], [West side — towards seat 1],
)

**3. Left and right in a circle**

#table(columns: (auto, auto, auto),
  [**Person faces**], [**LEFT means move**], [**RIGHT means move**],
  [the centre], [clockwise], [anticlockwise],
  [outward], [anticlockwise], [clockwise],
)

Why: stand at the top of the circle facing the centre. You are looking **down** the page, so your left hand points to the **right** of the page — and that is the clockwise side.

**4. Opposite seats.** In a circle of $n$ seats with $n$ even, the person opposite seat $k$ is at seat $k + n/2$ (wrap around by subtracting $n$ if you go past $n$). If $n$ is odd, **nobody** is exactly opposite anybody.

**5. Square and rectangular tables.** Number the seats clockwise as usual. With 8 people at a square table — 4 at the corners and 4 at the middles of the sides — the seats alternate: corner, middle, corner, middle, ... So if the corners are seats 1, 3, 5, 7 then the middles are 2, 4, 6, 8. Corner people and middle people are often told to face opposite ways, so check each person's own facing before you use left or right.

**6. Floors, stacks and boxes.** Number floor 1 at the **bottom**. "Above" means a larger number, "below" a smaller one. A stack of boxes works exactly like a building: bottom $=$ 1, top $= n$.

**7. Phrase dictionary — learn it exactly**

#table(columns: (auto, auto),
  [$A$ is **immediately** to the left of $B$], [$A$ is exactly 1 step to $B$'s left],
  [$A$ is **second** to the left of $B$], [$A$ is exactly 2 steps to $B$'s left],
  [$A$ is **to the left of** $B$], [somewhere to the left — position not fixed],
  [Exactly $x$ people **between** $A$ and $B$], [their seat numbers differ by $x + 1$],
  [$A$ and $B$ are **neighbours** / **adjacent**], [seat numbers differ by 1],
  [$A$ sits at an **end** / **extreme**], [seat 1 or seat $n$],
  [$A$ sits **exactly in the middle** of $n$ seats], [seat $(n+1) slash 2$, only if $n$ is odd],
)

**8. Double rows.** The two rows look at each other, so one row faces South and the other faces North. **Read the facing the question gives you — it is not always Row 1 that faces South.** Draw both rows with West on the left. Then **seat $k$ of Row 1 faces seat $k$ of Row 2.** Remember that left and right are **flipped** between the two rows.

**9. Scheduling grids (days, months, cities, prices).** Draw a table: one row per slot (Monday to Friday, or January to December in the order given), one column per attribute. Fill only what is certain. "Immediately after" means the very next slot in the list.

**10. The order to use the clues**
+ First: clues that fix one seat with certainty — ends, exact middle, a named floor, "opposite".
+ Second: clues that chain off a fixed seat — "immediately left of", "second to the right of".
+ Third: clues with two possible cases — branch, and test each branch.
+ Last: negative clues ("not adjacent to", "does not sit at an end"). These kill wrong branches instead of building the answer.

## Warm-up

### Warm-up

**Example 1**

Five friends A, B, C, D, E sit in a row facing North. C is at the extreme left end. B is at the extreme right end. D sits immediately to the right of C. A sits immediately to the left of B. Who sits in the middle?

**Solution**

Number the seats 1 to 5 from the left. \
C $=$ 1, B $=$ 5. \
All face North, so "right" means a larger seat number. D $=$ 1 + 1 $=$ 2. \
"Left" means a smaller seat number. A $=$ 5 − 1 $=$ 4. \
The only seat left is 3, so E sits there.

**➜ Answer: E**

**Example 2**

Six people sit around a circular table facing the centre. P sits third to the left of Q. How many people sit between Q and P when you count clockwise from Q?

**Solution**

Facing the centre, "left" means clockwise. \
So from Q, move 3 seats clockwise to reach P. \
The seats passed on the way are 2 seats, holding 2 people.

**➜ Answer: 2 people**

**Example 3**

In a 6-floor building (floor 1 at the bottom), Riya lives on floor 4 and Sam lives 2 floors above Riya. Which floor is Sam on?

**Solution**

"Above" means add. $4 + 2 = 6$.

**➜ Answer: Floor 6**

**Example 4**

Eight people sit around a circular table facing the centre. The seats are numbered 1 to 8 clockwise. Who sits exactly opposite the person at seat 3?

**Solution**

$n = 8$, so opposite means add $8 slash 2 = 4$. \
$3 + 4 = 7$.

**➜ Answer: Seat 7**

**Example 5**

Five boxes P, Q, R, S, T are stacked one above another. P is at the bottom, Q is immediately above P, R is at the top and S is immediately below R. Which box is in the middle?

**Solution**

Number the positions 1 (bottom) to 5 (top). \
P $=$ 1, Q $=$ 2, R $=$ 5, S $=$ 4. \
The only position left is 3, so T is there — and 3 is the middle of 5.

**➜ Answer: T**

**Example 6**

Four people sit in a row facing South. The row is drawn with West on the left. M sits immediately to the right of N. Who sits further West?

**Solution**

Facing South, a person's right hand points West. \
So M is one seat to the West of N.

**➜ Answer: M**

**Example 7**

Seven people sit in a row facing North, with West on the left. X sits 4th from the West end. How many people sit to X's right?

**Solution**

Facing North, right means the East side. \
X is at seat 4, so seats 5, 6 and 7 are to his right. \
That is $7 - 4 = 3$ people.

**➜ Answer: 3 people**

**Example 8**

Five meetings are held from Monday to Friday, one each day. The audit is on Wednesday. The demo is two days after the audit. Which day is the demo?

**Solution**

Wednesday $+$ 2 days $=$ Friday.

**➜ Answer: Friday**

## Tier 1 — Service companies

### Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini

**Example 9** `TCS NQT pattern`

Seven friends A, B, C, D, E, F, G sit in a row facing North.
- A sits at the extreme left end.
- B sits at the extreme right end.
- D sits exactly in the middle.
- F sits immediately to the left of D.
- C sits fourth to the right of A.
- E does not sit next to A.

Who sits between C and B?

**Solution**

Number the seats 1 to 7 from the left. All face North, so left $=$ smaller number, right $=$ larger number. \
A $=$ 1 and B $=$ 7. \
Exact middle of 7 seats is seat $(7 + 1) slash 2 = 4$, so D $=$ 4. \
F is immediately to the left of D: F $= 4 - 1 = 3$. \
C is fourth to the right of A: C $= 1 + 4 = 5$. \
Seats still empty: 2 and 6, for E and G. \
E must not sit next to A. A is at seat 1, and seat 2 is next to it, so E is not at 2. \
Therefore E $=$ 6 and G $=$ 2. \
Final row: A(1), G(2), F(3), D(4), C(5), E(6), B(7). \
C is at 5 and B is at 7, so seat 6 lies between them.

**➜ Answer: E**

---
💡 **SHORTCUT**

Use the clues in this order: ends first, then the exact middle, then "immediately next to" chains, and **only at the end** the negative clue. Starting from "E does not sit next to A" rules out **nothing**, because A's seat is not known yet. Once A is pinned to seat 1, the same clue kills exactly one seat in one second.

**Example 10** `Infosys pattern`

Six people P, Q, R, S, T, U sit around a circular table facing the centre.
- S sits immediately to the left of Q.
- P sits second to the left of Q.
- R sits immediately to the right of Q.
- T sits exactly opposite S.

(a) Who sits between P and T? (b) Who sits exactly opposite P?

**Solution**

Number the seats 1 to 6 clockwise and put Q at seat 1 (a circle has no fixed start, so we may choose). \
Everyone faces the centre, so left $=$ clockwise and right $=$ anticlockwise. \
S is immediately to Q's left: $1 + 1 = 2$. S $=$ 2. \
P is second to Q's left: $1 + 2 = 3$. P $=$ 3. \
R is immediately to Q's right: $1 - 1 = 0$, which wraps to seat 6. R $=$ 6. \
T is opposite S: $2 + 6 slash 2 = 2 + 3 = 5$. T $=$ 5. \
The only seat left is 4, so U $=$ 4. \
Final clockwise: Q(1), S(2), P(3), U(4), T(5), R(6). \
**(a)** P is at 3 and T is at 5, so seat 4 lies between them. \
**(b)** Opposite P $= 3 + 3 = 6$.

**➜ Answer: (a) U  (b) R**

**Example 11** `Accenture pattern`

Six people — Nisha, Omar, Priya, Rakesh, Sunil and Tara — live on six floors of a building. Floor 1 is the bottom and floor 6 is the top. One person per floor.
- Priya lives on the topmost floor.
- Rakesh lives immediately below Priya.
- Sunil lives on floor 1.
- Nisha lives on an even-numbered floor.
- Omar lives above Nisha, and exactly one person lives between them.

Who lives on floor 3?

**Solution**

Priya $=$ 6 and Rakesh $=$ 5 (immediately below 6). \
Sunil $=$ 1. \
Floors still free: 2, 3, 4. \
Nisha is on an even floor, so Nisha $=$ 2 or Nisha $=$ 4. \
"Exactly one person between them" and "Omar above Nisha" give Omar $=$ Nisha $+ 2$. \
If Nisha $=$ 4 then Omar $=$ 6, but floor 6 is Priya's. Rejected. \
If Nisha $=$ 2 then Omar $=$ 4, which is free. Accepted. \
The only floor left is 3, so Tara lives there. \
Final: Sunil(1), Nisha(2), Tara(3), Omar(4), Rakesh(5), Priya(6).

**➜ Answer: Tara**

---
⚠️ **TRAP**

"Exactly one person lives between them" means the floors differ by **2**, not by 1. Reading it as 1 gives Nisha $=$ 2 and Omar $=$ 3, so you would answer "Omar" for floor 3 instead of "Tara". The danger is that the wrong reading still fills every floor without a clash, so nothing warns you. Always convert a "between" clue into a floor **gap** of $x + 1$ before you place anybody.

**Example 12** `Wipro pattern`

Eight people sit in two rows of four, facing each other. \
Row 1 — A, B, C, D — all face South. \
Row 2 — P, Q, R, S — all face North. \
Both rows are drawn with West on the left, and seat $k$ of Row 1 faces seat $k$ of Row 2.
- B sits at an end of Row 1 and faces Q.
- C sits second to the right of B.
- P faces C.
- A sits at an end of Row 1.
- S sits immediately to the right of P.

Who faces D?

**Solution**

Row 1 faces South, so **right** means a smaller seat number and **left** a larger one. \
Row 2 faces North, so **right** means a larger seat number. \
B is at an end, so B $=$ 1 or B $=$ 4. \
C is second to B's right $=$ B $- 2$. If B $=$ 1 this is seat $-1$, which does not exist. \
So B $=$ 4, and C $= 4 - 2 = 2$. \
A is at an end of Row 1; seat 4 is taken, so A $=$ 1. \
The last Row-1 seat is 3, so D $=$ 3. \
Row 1: A(1), C(2), D(3), B(4). \
B faces Q and B is at seat 4, so Q $=$ 4. \
P faces C and C is at seat 2, so P $=$ 2. \
S is immediately to P's right $= 2 + 1 = 3$. S $=$ 3. \
The last Row-2 seat is 1, so R $=$ 1. \
Row 2: R(1), P(2), S(3), Q(4). \
D is at seat 3, so D faces the Row-2 person at seat 3.

**➜ Answer: S**

---
⚠️ **TRAP**

The meaning of left and right **flips** between the two rows. In Row 1 (facing South) "second to the right" subtracts 2; in Row 2 (facing North) the same words add 2. Students who use one rule for both rows get half the puzzle wrong and still feel confident.

**Example 13** `Capgemini pattern`

Five students — Tanvi, Ujjwal, Vikas, Wendy and Xu — visit a library on five different days, Monday to Friday.
- Tanvi visits on Thursday.
- Wendy visits on Friday.
- Ujjwal visits on the day immediately after Vikas.
- Vikas does not visit on Monday.

Who visits on Monday?

**Solution**

Thursday $=$ Tanvi, Friday $=$ Wendy. \
Days still free: Monday, Tuesday, Wednesday, for Ujjwal, Vikas and Xu. \
Ujjwal is on the day right after Vikas, so we need two free days in a row: \
Monday–Tuesday works, Tuesday–Wednesday works, Wednesday–Thursday fails (Thursday is taken). \
Vikas is not on Monday, so Monday–Tuesday is out. \
So Vikas $=$ Tuesday and Ujjwal $=$ Wednesday. \
The only day left is Monday, for Xu.

**➜ Answer: Xu**

**Example 14** `Cognizant pattern`

Five boxes — black, blue, green, red and white — are stacked one above another.
- The black box is at the bottom.
- Exactly two boxes lie between the black box and the blue box.
- The green box is immediately above the red box.
- The white box lies somewhere above the blue box.

How many boxes lie between the green box and the white box?

**Solution**

Number the positions 1 (bottom) to 5 (top). \
Black $=$ 1. \
Two boxes between black and blue means the positions differ by $2 + 1 = 3$, so blue $= 1 + 3 = 4$. \
Free positions: 2, 3, 5. \
Green is immediately above red, so red and green take two positions in a row. \
From 2, 3, 5 the only pair in a row is 2 and 3. So red $=$ 2 and green $=$ 3. \
White takes the last free position, 5. Check: 5 is above blue at 4. #sym.checkmark \
Final: black(1), red(2), green(3), blue(4), white(5). \
Green is at 3 and white is at 5, so position 4 lies between them — that is 1 box.

**➜ Answer: 1 box (the blue box)**

**Example 15** `TCS NQT pattern`

Five people A, B, C, D, E sit around a circular table facing **outward**.
- A sits second to the right of B.
- C sits immediately to the left of A.
- D is not an immediate neighbour of B.

Who sits immediately to the right of E?

**Solution**

Number the seats 1 to 5 clockwise and put B at seat 1. \
They face **outward**, so left $=$ anticlockwise and right $=$ clockwise. \
A is second to B's right: $1 + 2 = 3$. A $=$ 3. \
C is immediately to A's left: $3 - 1 = 2$. C $=$ 2. \
Free seats: 4 and 5, for D and E. \
B is at seat 1; its neighbours are seats 2 and 5. \
D is not a neighbour of B, so D is not at 5. Therefore D $=$ 4 and E $=$ 5. \
Final clockwise: B(1), C(2), A(3), D(4), E(5). \
E faces outward, so E's right is clockwise: $5 + 1 = 6$, which wraps to seat 1.

**➜ Answer: B**

---
💡 **SHORTCUT**

For a circle, always fix one named person at seat 1 before you do anything else. A circle has no real starting point, so this costs nothing and turns every clue into simple addition and subtraction.

**Example 16** `Infosys pattern`

Six people L, M, N, O, P, Q sit in a row facing North.
- N sits third from the left.
- M sits at one of the two ends.
- Exactly three people sit between M and O.
- L sits immediately to the right of N.
- O sits to the right of L.
- Q does not sit at either end.

Where does P sit?

**Solution**

Number the seats 1 to 6 from the left. Facing North, right $=$ larger number. \
N $=$ 3. \
L is immediately to N's right: L $= 3 + 1 = 4$. \
Three people between M and O means their seat numbers differ by $3 + 1 = 4$. \
M is at an end, so M $=$ 1 or M $=$ 6. \
If M $=$ 1 then O $=$ 5. If M $=$ 6 then O $=$ 2. \
But O must be to the right of L, and L is at seat 4, so O $> 4$. \
That kills O $=$ 2. So M $=$ 1 and O $=$ 5. \
Free seats: 2 and 6, for P and Q. \
Q is not at an end, so Q is not at 6. Therefore Q $=$ 2 and P $=$ 6. \
Final: M(1), Q(2), N(3), L(4), O(5), P(6).

**➜ Answer: P sits at seat 6, the extreme right end**

**Example 17** `Wipro pattern`

Five people — Aarti, Bibek, Chandan, Dipa and Elias — have birthdays in five different months: January, March, May, August and November (listed in calendar order).
- Aarti's birthday is in January.
- Exactly two of them have birthdays after Bibek.
- Chandan's birthday is in the month immediately after Bibek's in this list.
- Dipa's birthday is not in November.

Whose birthday is in March?

**Solution**

Number the months in order: January(1), March(2), May(3), August(4), November(5). \
Aarti $=$ January $=$ 1. \
Exactly two people come after Bibek, so Bibek has 2 months of the list after him: Bibek $= 5 - 2 = 3 =$ May. \
Chandan is in the month right after Bibek: $3 + 1 = 4 =$ August. \
Free months: March(2) and November(5), for Dipa and Elias. \
Dipa is not in November, so Dipa $=$ March and Elias $=$ November. \
Final: Aarti–January, Dipa–March, Bibek–May, Chandan–August, Elias–November.

**➜ Answer: Dipa**

**Example 18** `Accenture pattern`

Four people W, X, Y, Z sit at the four corners of a square table, all facing the centre.
- W sits diagonally opposite Y.
- X sits immediately to the left of W.

Who sits immediately to the right of Y?

**Solution**

Number the four corners 1, 2, 3, 4 clockwise and put W at corner 1. \
Diagonally opposite in a 4-seat ring means add $4 slash 2 = 2$: Y $= 1 + 2 = 3$. \
All face the centre, so left $=$ clockwise. X $= 1 + 1 = 2$. \
The last corner, 4, goes to Z. \
Y is at corner 3 and faces the centre, so Y's right is anticlockwise: $3 - 1 = 2$.

**➜ Answer: X**

**Example 19** `TCS NQT pattern`

Five students stand in a line in order of height.
- Deepa is taller than Farah but shorter than Gita.
- Harsh is taller than Gita.
- Imran is the shortest.

Who is the second tallest?

**Solution**

Write each clue as a chain, tallest on the left. \
"Deepa taller than Farah, shorter than Gita" gives Gita $>$ Deepa $>$ Farah. \
"Harsh taller than Gita" puts Harsh on the far left: Harsh $>$ Gita $>$ Deepa $>$ Farah. \
Imran is the shortest, so Imran goes at the far right: \
Harsh $>$ Gita $>$ Deepa $>$ Farah $>$ Imran. \
All five are now in one chain, so the order is fixed. The second name is Gita.

**➜ Answer: Gita**

#### Practice — Tier 1 — Service *(target: 60 s/Q)*

**Questions 1 to 3.** Six friends — Ajay, Bina, Chetan, Divya, Esha and Farhan — sit in a row facing North, drawn with West on the left. Chetan sits at the extreme right end. Ajay sits third from the left. Bina sits immediately to the left of Ajay. Divya sits at the extreme left end. Esha does not sit next to Chetan.

1. Who sits immediately to the right of Esha?
2. How many people sit between Bina and Farhan?
3. Who sits exactly between Divya and Ajay?

**Questions 4 to 6.** Eight people — Karan, Latika, Mohan, Nisha, Omar, Pooja, Qadir and Rita — sit around a circular table facing the centre. Mohan sits third to the left of Karan. Nisha sits exactly opposite Mohan. Omar sits immediately to the left of Karan. Pooja sits second to the right of Nisha. Latika sits immediately to the left of Mohan. Qadir sits immediately to the right of Mohan.

4. Who sits exactly opposite Karan?
5. Who sits second to the left of Pooja?
6. How many people sit between Qadir and Rita, counting clockwise from Qadir?

**Questions 7 to 9.** Five people — Tara, Umesh, Vani, Wasim and Yash — live on five floors of a building, floor 1 at the bottom. Vani lives on the top floor. Tara lives immediately below Vani. Umesh lives on floor 1. Wasim lives above Yash.

7. Who lives on floor 3?
8. How many people live between Umesh and Tara?
9. Who lives immediately above Yash?

10. Six people sit around a circular table facing **outward**. A sits second to the left of B, and C sits immediately to the right of B. How many people sit between C and A, counting clockwise from C?
11. Four boxes W, X, Y, Z are stacked. Z is at the bottom, X is immediately above Z, W is somewhere above X, and Y is not at the top. Which box is at the top?
12. Seven meetings are held from Monday to Sunday, one each day. The review is on Tuesday. The demo is three days after the review. The audit is on the day immediately before the demo. On which day is the audit?
13. Five students are ranked by height. Ravi is taller than Sunil but shorter than Tina. Uma is taller than Tina. Vikas is the shortest. Who is the second shortest?

<details>
<summary><b>Answer key</b></summary>

Seats for questions 1–3, from the left: Divya(1), Bina(2), Ajay(3), Esha(4), Farhan(5), Chetan(6). Esha cannot be at 5 because that seat is next to Chetan.
1. **Farhan.** Facing North, Esha's right is seat 5.
2. **2 people.** Bina is at 2 and Farhan at 5, so seats 3 and 4 lie between.
3. **Bina.** She is at seat 2, between seats 1 and 3.

Seats for questions 4–6, clockwise: Karan(1), Omar(2), Qadir(3), Mohan(4), Latika(5), Pooja(6), Rita(7), Nisha(8).
4. **Latika.** Opposite Karan $= 1 + 4 = 5$.
5. **Nisha.** Facing the centre, left is clockwise: $6 + 2 = 8$.
6. **3 people.** From seat 3 clockwise to seat 7 you pass seats 4, 5 and 6 — Mohan, Latika and Pooja.

Floors for questions 7–9: Umesh(1), Yash(2), Wasim(3), Tara(4), Vani(5).
7. **Wasim.** Vani is on 5 and Tara on 4, Umesh on 1, so Yash and Wasim take 2 and 3; Wasim is above Yash.
8. **2 people.** Floors 2 and 3 lie between floors 1 and 4.
9. **Wasim.** Yash is on floor 2, so floor 3 is immediately above.

10. **2 people.** Facing outward, left is anticlockwise and right is clockwise. Put B at seat 1: A $= 1 - 2 = -1$, which wraps round to seat $-1 + 6 = 5$; and C $= 1 + 1 = 2$. From seat 2 clockwise to seat 5 you pass seats 3 and 4.
11. **W.** Z(1), X(2); W is above X, and Y is not at the top, so Y $=$ 3 and W $=$ 4.
12. **Thursday.** Review Tuesday, demo Tuesday $+ 3 =$ Friday, audit the day before Friday.
13. **Sunil.** The chain is Uma $>$ Tina $>$ Ravi $>$ Sunil $>$ Vikas.

## Tier 2 — Singapore & Thailand

### Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB

**Example 20** `Grab · pattern`

Eight analysts A, B, C, D, E, F, G, H sit around a circular table facing the centre.
- C sits third to the left of A.
- B sits exactly opposite C.
- E sits second to the right of B.
- D sits immediately to the left of E.
- H sits immediately to the right of C.
- F is not an immediate neighbour of C.

(a) Who sits exactly opposite E? (b) Who sits between C and E, counting clockwise from C?

**Solution**

Number the seats 1 to 8 clockwise and put A at seat 1. \
All face the centre: left $=$ clockwise ($+$), right $=$ anticlockwise ($-$). \
C is third to A's left: $1 + 3 = 4$. C $=$ 4. \
B is opposite C: $4 + 8 slash 2 = 4 + 4 = 8$. B $=$ 8. \
E is second to B's right: $8 - 2 = 6$. E $=$ 6. \
D is immediately to E's left: $6 + 1 = 7$. D $=$ 7. \
H is immediately to C's right: $4 - 1 = 3$. H $=$ 3. \
Free seats: 2 and 5, for F and G. \
C is at seat 4, so C's neighbours are seats 3 and 5. F is not a neighbour of C, so F is not at 5. \
Therefore F $=$ 2 and G $=$ 5. \
Final clockwise: A(1), F(2), H(3), C(4), G(5), E(6), D(7), B(8). \
**(a)** Opposite E $= 6 + 4 = 10$, and $10 - 8 = 2$. \
**(b)** From seat 4 clockwise to seat 6 you pass seat 5 only.

**➜ Answer: (a) F  (b) G**

**Example 21** `Sea/Shopee · pattern`

Ten people sit in two rows of five, facing each other. \
Row 1 — Aisha, Ben, Chen, Dara, Eko — all face South. \
Row 2 — Fajar, Gita, Hanif, Intan, Joko — all face North. \
Both rows are drawn with West on the left, and seat $k$ of Row 1 faces seat $k$ of Row 2.
- Dara sits exactly in the middle of Row 1.
- Chen sits at the extreme West end of Row 1.
- Ben sits second to the left of Dara.
- Eko sits immediately to the left of Dara.
- Aisha faces Gita.
- Fajar sits at the extreme West end of Row 2.
- Hanif faces Eko.
- Joko sits at the extreme East end of Row 2.

(a) Who faces Chen? (b) Who sits second to the right of Ben?

**Solution**

Row 1 faces South, so **left** $=$ larger seat number and **right** $=$ smaller seat number. \
Row 2 faces North, so **left** $=$ smaller seat number and **right** $=$ larger seat number. \
**Row 1.** Exact middle of 5 seats is seat 3, so Dara $=$ 3. \
Chen is at the West end: Chen $=$ 1. \
Ben is second to Dara's left: $3 + 2 = 5$. Ben $=$ 5. \
Eko is immediately to Dara's left: $3 + 1 = 4$. Eko $=$ 4. \
The only Row-1 seat left is 2, so Aisha $=$ 2. \
Row 1: Chen(1), Aisha(2), Dara(3), Eko(4), Ben(5). \
**Row 2.** Fajar $=$ 1 and Joko $=$ 5. \
Hanif faces Eko, and Eko is at seat 4, so Hanif $=$ 4. \
Aisha faces Gita, and Aisha is at seat 2, so Gita $=$ 2. \
The only Row-2 seat left is 3, so Intan $=$ 3. \
Row 2: Fajar(1), Gita(2), Intan(3), Hanif(4), Joko(5). \
**(a)** Chen is at seat 1, so Chen faces the Row-2 person at seat 1. \
**(b)** Ben is at seat 5 and faces South, so his right is $5 - 2 = 3$.

**➜ Answer: (a) Fajar  (b) Dara**

**Example 22** `DBS · pattern`

Seven people — Farah, Gopal, Hui, Ivan, Jaya, Kamal and Lin — live on seven floors of a building, floor 1 at the bottom and floor 7 at the top. One person per floor.
- Farah lives on floor 6.
- Exactly three people live between Farah and Gopal.
- Hui lives immediately above Gopal.
- Jaya lives immediately below Farah.
- Ivan lives on an odd-numbered floor above Hui.
- Kamal does not live on floor 1.

(a) How many people live between Kamal and Ivan? (b) Who lives on floor 3?

**Solution**

Farah $=$ 6. \
Three people between Farah and Gopal means the floors differ by $3 + 1 = 4$. \
So Gopal $= 6 - 4 = 2$, or Gopal $= 6 + 4 = 10$ which does not exist. Gopal $=$ 2. \
Hui is immediately above Gopal: Hui $= 2 + 1 = 3$. \
Jaya is immediately below Farah: Jaya $= 6 - 1 = 5$. \
Ivan is on an odd floor above 3: the odd floors above 3 are 5 and 7. Floor 5 is Jaya's, so Ivan $=$ 7. \
Free floors: 1 and 4, for Kamal and Lin. \
Kamal is not on floor 1, so Kamal $=$ 4 and Lin $=$ 1. \
Final: Lin(1), Gopal(2), Hui(3), Kamal(4), Jaya(5), Farah(6), Ivan(7). \
**(a)** Kamal is on 4 and Ivan on 7, so floors 5 and 6 lie between: 2 people. \
**(b)** Floor 3 is Hui's.

**➜ Answer: (a) 2 people  (b) Hui**

**Example 23** `GIC · pattern`

Eight people sit at a square table. Four — A, B, C, D — sit at the corners and **face the centre**. Four — P, Q, R, S — sit at the middles of the sides and **face outward**. The eight seats are numbered 1 to 8 clockwise, and seats 1, 3, 5, 7 are the corners.
- A sits at seat 1.
- P sits immediately to the left of A.
- B sits exactly opposite A.
- Q sits second to the right of P.
- C sits immediately to the left of Q.
- R sits exactly opposite Q.

(a) Who sits second to the right of B? (b) Who sits exactly opposite S?

**Solution**

Two different rules are in use here, so check each person's facing before moving. \
Corner people face the centre: left $=$ clockwise ($+$), right $=$ anticlockwise ($-$). \
Middle people face outward: left $=$ anticlockwise ($-$), right $=$ clockwise ($+$). \
A $=$ 1 (a corner). \
P is immediately to A's left. A faces the centre, so $1 + 1 = 2$. P $=$ 2, which is a middle seat. #sym.checkmark \
B is opposite A: $1 + 4 = 5$, a corner. #sym.checkmark \
Q is second to P's right. P faces outward, so $2 + 2 = 4$, a middle seat. Q $=$ 4. #sym.checkmark \
C is immediately to Q's left. Q faces outward, so $4 - 1 = 3$, a corner. C $=$ 3. #sym.checkmark \
R is opposite Q: $4 + 4 = 8$, a middle seat. R $=$ 8. #sym.checkmark \
Seats left: 6 (a middle) and 7 (a corner). S is a middle person, so S $=$ 6; D is a corner person, so D $=$ 7. \
Final clockwise: A(1), P(2), C(3), Q(4), B(5), S(6), D(7), R(8). \
**(a)** B is at seat 5 and faces the centre, so B's right is anticlockwise: $5 - 2 = 3$. \
**(b)** Opposite S $= 6 + 4 = 10$, and $10 - 8 = 2$.

**➜ Answer: (a) C  (b) P**

---
⚠️ **TRAP**

At a mixed-facing table, "second to the right" has **two** meanings depending on who is speaking. Apply the rule of the person named in the clue, not the rule of the person you are trying to place.

**Example 24** `Agoda · pattern`

Five consultants — Anan, Bua, Chai, Dara and Ek — each fly to a different city (Bangkok, Hanoi, Jakarta, Manila, Seoul) on five different days, Monday to Friday.
- The Seoul trip is on Tuesday.
- Chai travels to Manila.
- Anan travels on the day immediately before Chai.
- Bua goes to Seoul.
- The Jakarta trip is on Friday.
- Dara travels on Monday, but not to Hanoi.

Who travels to Hanoi, and on which day?

**Solution**

Bua goes to Seoul and Seoul is on Tuesday, so Bua $=$ Tuesday. \
Dara $=$ Monday. \
Dara's city cannot be Seoul (that is Tuesday), cannot be Jakarta (that is Friday), and is not Hanoi. \
So Dara goes to Bangkok or Manila. Manila belongs to Chai, and Chai is not on Monday because Dara is. \
Therefore Dara goes to **Bangkok** on Monday. \
Days left: Wednesday, Thursday, Friday, for Anan, Chai and Ek. \
Anan is the day right before Chai, so the pairs to test are Wednesday–Thursday and Thursday–Friday. \
Friday is the Jakarta trip, but Chai's city is Manila, so Chai is not on Friday. \
That kills Thursday–Friday. So Anan $=$ Wednesday and Chai $=$ Thursday. \
Ek takes the last day, Friday, and therefore the Jakarta trip. \
The only city left is Hanoi, and the only person left is Anan, on Wednesday. \
Final: Dara–Bangkok–Monday, Bua–Seoul–Tuesday, Anan–Hanoi–Wednesday, Chai–Manila–Thursday, Ek–Jakarta–Friday.

**➜ Answer: Anan, on Wednesday**

---
💡 **SHORTCUT**

In a grid puzzle, write the **day** column first and the **city** column second. Days are usually pinned harder than attributes, and once the days are fixed each remaining city is forced by elimination in one pass.

**Example 25** `LINE MAN · pattern`

Eight riders A, B, C, D, E, F, G, H stand in a row facing North, drawn with West on the left. Each made a different number of deliveries today, from the set 10, 12, 15, 18, 20, 24, 28, 30.

**Positions.** D stands fourth from the left. Exactly three riders stand between D and G. B stands immediately to the left of G. A stands at the extreme left end. E stands immediately to the right of A. F stands immediately to the left of B. H stands between D and F.

**Deliveries.** The rider at the extreme left made 20. G made 30. D made exactly twice as many as E. The rider immediately to the right of D made 15. C made 10. B made more than F.

(a) Who made 18 deliveries? (b) How many deliveries did the rider standing third from the left make?

**Solution**

**Step 1 — the row.** Number the seats 1 to 8 from the left. Facing North: right $=$ larger, left $=$ smaller. \
D $=$ 4. \
Three riders between D and G means the seats differ by $3 + 1 = 4$, so G $= 4 + 4 = 8$ (seat 0 does not exist). \
B is immediately to G's left: B $= 8 - 1 = 7$. \
A $=$ 1, and E $= 1 + 1 = 2$. \
F is immediately to B's left: F $= 7 - 1 = 6$. \
H stands between D(4) and F(6), so H $=$ 5. \
The last seat, 3, goes to C. \
Row: A(1), E(2), C(3), D(4), H(5), F(6), B(7), G(8). \
**Step 2 — the deliveries.** \
A is at the extreme left, so A $=$ 20. \
G $=$ 30. \
C $=$ 10. \
The rider immediately to D's right is at seat 5, which is H, so H $=$ 15. \
D is twice E. Test every value of E in the set: \
E $=$ 10 gives D $=$ 20, already taken by A. Rejected. \
E $=$ 12 gives D $=$ 24, still free. Possible. \
E $=$ 15 gives D $=$ 30, taken by G. Rejected. \
No other value doubles into the set. So E $=$ 12 and D $=$ 24. \
Used so far: 20, 30, 10, 15, 12, 24. Left: 18 and 28, for F and B. \
B made more than F, so B $=$ 28 and F $=$ 18. \
**(a)** 18 belongs to F. \
**(b)** Third from the left is seat 3, which is C.

**➜ Answer: (a) F  (b) 10 deliveries**

**Example 26** `Razer · pattern`

Six boxes P, Q, R, S, T, U are stacked one above another. Each has a different weight from 5, 8, 12, 15, 20 and 25 kg.
- Exactly two boxes lie above Q.
- S lies immediately below Q.
- R is at the bottom.
- P is at the top.
- T lies above U.
- Q weighs 20 kg.
- The two boxes below S weigh 13 kg in total.
- U is heavier than R.
- S weighs 25 kg.
- T weighs more than P.

(a) How many boxes lie between U and T? (b) What does the topmost box weigh?

**Solution**

**Step 1 — the stack.** Number the positions 1 (bottom) to 6 (top). \
Two boxes lie above Q, so Q is third from the top: Q $= 6 - 2 = 4$. \
S is immediately below Q: S $= 4 - 1 = 3$. \
R $=$ 1 and P $=$ 6. \
Free positions: 2 and 5, for T and U. T is above U, so U $=$ 2 and T $=$ 5. \
Stack from the bottom: R(1), U(2), S(3), Q(4), T(5), P(6). \
**Step 2 — the weights.** \
Q $=$ 20 and S $=$ 25. Left to place: 5, 8, 12, 15. \
The boxes below S are at positions 1 and 2, that is R and U, and they total 13. \
From 5, 8, 12, 15 the pairs are $5 + 8 = 13$, $5 + 12 = 17$, $5 + 15 = 20$, $8 + 12 = 20$, $8 + 15 = 23$, $12 + 15 = 27$. \
Only $5 + 8 = 13$ works, so R and U are 5 and 8 in some order. \
U is heavier than R, so U $=$ 8 and R $=$ 5. \
Left: 12 and 15, for T and P. T is heavier than P, so T $=$ 15 and P $=$ 12. \
Final: R 5 kg, U 8 kg, S 25 kg, Q 20 kg, T 15 kg, P 12 kg. \
**(a)** U is at 2 and T is at 5, so positions 3 and 4 lie between: 2 boxes. \
**(b)** The top box is P.

**➜ Answer: (a) 2 boxes  (b) 12 kg**

**Example 27** `Agoda · pattern`

Six colleagues — Nadia, Omar, Priya, Rafi, Sita and Tan — each took leave in a different month of the same year: January, March, April, July, September and November (listed in calendar order). Each took a different number of days off: 3, 5, 7, 10, 12 and 15.
- Exactly two of them took leave in months earlier than Nadia's.
- Omar took leave in the month immediately after Nadia's in this list.
- Tan took leave in the last of these months.
- Sita took leave in the month immediately before Tan's in this list.
- Priya took leave before Rafi.
- Nadia took 12 days.
- The person who took leave in January took 5 days.
- Rafi took 3 days.
- Tan took more days than Sita, and Sita took more days than Omar.

(a) Who took leave in March, and for how many days? (b) How many days did the person who took leave in September take?

**Solution**

**Step 1 — the months.** Number them: January(1), March(2), April(3), July(4), September(5), November(6). \
Two people are earlier than Nadia, so Nadia is third in the list: Nadia $= 3 =$ April. \
Omar is the month right after: Omar $= 4 =$ July. \
Tan is last: Tan $= 6 =$ November. \
Sita is right before Tan: Sita $= 5 =$ September. \
Months left: January(1) and March(2), for Priya and Rafi. Priya is before Rafi, so Priya $=$ January and Rafi $=$ March. \
**Step 2 — the days.** \
Nadia $=$ 12. \
The January person is Priya, so Priya $=$ 5. \
Rafi $=$ 3. \
Left: 7, 10, 15, for Omar, Sita and Tan. \
The chain Tan $>$ Sita $>$ Omar forces the largest to Tan, the middle to Sita and the smallest to Omar: \
Tan $=$ 15, Sita $=$ 10, Omar $=$ 7. \
Final: Priya–January–5, Rafi–March–3, Nadia–April–12, Omar–July–7, Sita–September–10, Tan–November–15. \
**(a)** March belongs to Rafi, with 3 days. \
**(b)** September belongs to Sita.

**➜ Answer: (a) Rafi, 3 days  (b) 10 days**

**Example 28** `Grab · pattern`

Six people sit around a circular table. A, C and E face the centre. B, D and F face outward.
- C sits third to the left of A.
- B sits immediately to the right of C.
- D sits second to the right of B.
- F sits immediately to the left of A.

(a) Who sits second to the right of E? (b) How many people sit between F and D, counting clockwise from F?

**Solution**

Number the seats 1 to 6 clockwise and put A at seat 1. \
Facing the centre: left $= +$, right $= -$. Facing outward: left $= -$, right $= +$. \
C is third to A's left. A faces the centre, so $1 + 3 = 4$. C $=$ 4. \
B is immediately to C's right. C faces the centre, so $4 - 1 = 3$. B $=$ 3. \
D is second to B's right. B faces **outward**, so $3 + 2 = 5$. D $=$ 5. \
F is immediately to A's left. A faces the centre, so $1 + 1 = 2$. F $=$ 2. \
The last seat, 6, goes to E. \
Final clockwise: A(1), F(2), B(3), C(4), D(5), E(6). \
**(a)** E faces the centre, so E's right is anticlockwise: $6 - 2 = 4$. \
**(b)** From seat 2 clockwise to seat 5 you pass seats 3 and 4 — B and C.

**➜ Answer: (a) C  (b) 2 people**

#### Practice — Tier 2 — Singapore & Thailand *(target: 100 s/Q)*

**Questions 1 to 4.** Ten people sit in two rows of five, facing each other. Row 1 — Nita, Omar, Pavi, Quan, Ratna — all face North. Row 2 — Surya, Tavi, Udin, Vina, Wati — all face South. Both rows are drawn with West on the left, and seat $k$ of Row 1 faces seat $k$ of Row 2. Quan sits exactly in the middle of Row 1. Omar sits at the extreme East end of Row 1. Nita sits immediately to the left of Quan. Pavi sits at the extreme West end of Row 1. Surya faces Quan. Tavi sits immediately to the left of Surya. Vina sits at the extreme East end of Row 2. Udin faces Nita.

1. Who faces Ratna?
2. Who sits second to the right of Nita?
3. How many people sit between Wati and Tavi?
4. Who faces the person sitting immediately to the right of Udin?

**Questions 5 to 8.** Seven people — Arun, Bella, Cheng, Divya, Ethan, Farah and Gopal — live on seven floors of a building, floor 1 at the bottom. Cheng lives on floor 5. Exactly two people live between Cheng and Arun. Bella lives immediately above Arun. Divya lives on the topmost floor. Ethan lives immediately below Divya. Farah does not live on floor 1.

5. Who lives on floor 4?
6. How many people live between Bella and Ethan?
7. Who lives immediately below Cheng?
8. If Gopal and Divya swap floors, who then lives on floor 1?

9. Eight people sit around a circular table. A, B, C and D face the centre; P, Q, R and S face outward. B sits third to the left of A. P sits immediately to the right of B. C sits second to the right of P. Q sits exactly opposite P. R sits immediately to the left of A. S sits exactly opposite R. Who sits exactly opposite A?
10. Six boxes L, M, N, O, P, Q are stacked, with different weights of 4, 7, 9, 11, 14 and 18 kg. N is at the bottom. Exactly three boxes lie between N and M. O lies immediately above M. L lies immediately above N. P lies below Q. The bottom box weighs 9 kg. M weighs twice as much as L. O weighs 4 kg. Q is heavier than P. What is the total weight of the boxes immediately above and immediately below Q?
11. Six people took a course in six different months: February, April, May, August, October and December. Exactly three of them took it after Reza. Sofia took it in the month immediately before Reza's. Tan took it in the last of these months. Umi took it in February. Wira took it before Yusuf. Who took the course in October?

<details>
<summary><b>Answer key</b></summary>

Questions 1–4. Row 1 from the West: Pavi(1), Nita(2), Quan(3), Ratna(4), Omar(5). Row 2 from the West: Wati(1), Udin(2), Surya(3), Tavi(4), Vina(5). Row 1 faces North, so its "left" is a smaller seat number; Row 2 faces South, so its "left" is a larger one.
1. **Tavi.** Ratna is at seat 4, so she faces Row 2 seat 4.
2. **Ratna.** Nita is at 2 and faces North, so her right is $2 + 2 = 4$.
3. **2 people.** Wati is at 1 and Tavi at 4, so seats 2 and 3 lie between.
4. **Pavi.** Udin is at 2 and faces South, so his right is seat $2 - 1 = 1$, which is Wati; Wati faces Row 1 seat 1.

Questions 5–8. Floors: Gopal(1), Arun(2), Bella(3), Farah(4), Cheng(5), Ethan(6), Divya(7). Two people between Cheng(5) and Arun means the floors differ by 3, so Arun is on 2 (floor 8 does not exist).
5. **Farah.** Floors 1 and 4 are the last two free, and Farah cannot be on floor 1.
6. **2 people.** Floors 4 and 5 lie between floors 3 and 6.
7. **Farah.** Floor 4 is immediately below floor 5.
8. **Divya.** The swap puts her on floor 1 and Gopal on floor 7.

9. **C.** Put A at seat 1. B $= 1 + 3 = 4$. P $= 4 - 1 = 3$ (B faces the centre). C $= 3 + 2 = 5$ (P faces outward). Q $= 3 + 4 = 7$. R $= 1 + 1 = 2$. S $= 2 + 4 = 6$, so D takes seat 8. Opposite A $= 1 + 4 = 5$.
10. **25 kg.** Stack from the bottom: N(1), L(2), P(3), Q(4), M(5), O(6). N $=$ 9 kg and O $=$ 4 kg. For M $= 2 L$ the only pair left in the set is L $=$ 7 and M $=$ 14 (the pair 9 and 18 is blocked because 9 is already N's). The remaining 11 and 18 go to P and Q with Q heavier, so Q $=$ 18 and P $=$ 11. Immediately above Q is M (14 kg) and immediately below is P (11 kg): $14 + 11 = 25$.
11. **Yusuf.** Three people come after Reza, so Reza is third: May. Sofia is April. Tan is December, Umi is February. The months left are August and October for Wira and Yusuf, and Wira is earlier, so Wira is August.

## Tier 3 — Product companies

### Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe

**Example 29** `Google · pattern`

Five friends sit in a row of five chairs. Two of them, Ravi and Sneha, refuse to sit next to each other. In how many different orders can the five of them sit?

**Solution**

**Insight: counting "not together" directly means many cases. Count everything, then subtract the arrangements where they ARE together.** \
**Step 1 — all arrangements.** Five people in five chairs: \
$5! = 5 \times 4 \times 3 \times 2 \times 1 = 120$. \
**Step 2 — arrangements with Ravi and Sneha together.** Glue them into one block. \
The block plus the other 3 people make 4 objects, arranged in $4! = 24$ ways. \
Inside the block, Ravi and Sneha can swap: 2 ways. \
Together $= 24 \times 2 = 48$. \
**Step 3 — subtract.** \
$120 - 48 = 72$.

**➜ Answer: 72 arrangements**

**Example 30** `Amazon · pattern`

Six people sit around a round table. Two seatings count as the same if one is a rotation of the other. In how many ways can they sit if two particular people, X and Y, must sit exactly opposite each other?

**Solution**

**Insight: "rotations are the same" is handled by nailing one person to one seat. After that the table behaves like a plain list of seats.** \
Number the seats 1 to 6 clockwise. \
Fix X at seat 1. Every rotation of a seating now has exactly one version with X at seat 1, so no seating is counted twice. \
Y must sit opposite X: $1 + 6 slash 2 = 1 + 3 = 4$. That is exactly **1** choice for Y. \
The remaining 4 people go into the remaining 4 seats (2, 3, 5, 6) in \
$4! = 4 \times 3 \times 2 \times 1 = 24$ ways. \
Total $= 1 \times 24 = 24$. \
**Check:** without the opposite rule the answer would be $(6 - 1)! = 120$. Of the 5 seats Y could take, exactly 1 is opposite X, so $120 \times 1/5 = 24$. #sym.checkmark

**➜ Answer: 24 ways**

---
💡 **SHORTCUT**

For any round-table count with "rotations are the same", fix one named person first. The count then drops from $n!$ to $(n-1)!$ automatically and you never divide at the end.

**Example 31** `Microsoft · pattern`

Seven people P, Q, R, S, T, U, V stand in a row of seven places, numbered 1 to 7 from the left.
- P stands to the left of Q, with exactly one person between them.
- R stands three places to the right of Q.
- S stands at one of the two ends.

In how many different ways can the seven of them stand?

**Solution**

**Insight: P, Q and R are locked into a rigid chain. Slide the whole chain along the row and see how few places it actually fits.** \
One person between P and Q means the places differ by $1 + 1 = 2$, and P is on the left, so
$ Q = P + 2 $
R is three places to Q's right, so
$ R = Q + 3 = P + 5 $
P must be at least 1 and R at most 7, so $P + 5 \\le 7$, giving $P \\le 2$. \
So $P = 1$ or $P = 2$. Only two cases. \
**Case $P = 1$:** Q $=$ 3, R $=$ 6. Places left: 2, 4, 5, 7. \
S must be at an end. Place 1 is taken by P, so S $=$ 7. \
The other three people, T, U and V, fill places 2, 4, 5 in $3! = 6$ ways. \
**Case $P = 2$:** Q $=$ 4, R $=$ 7. Places left: 1, 3, 5, 6. \
S must be at an end. Place 7 is taken by R, so S $=$ 1. \
T, U and V fill places 3, 5, 6 in $3! = 6$ ways. \
Total $= 6 + 6 = 12$.

**➜ Answer: 12 ways**

**Example 32** `Goldman Sachs · pattern`

Ten people sit around a circular table facing the centre. Each of them is either a Knight, who always tells the truth, or a Knave, who always lies. Every single person says the same sentence: **"The person immediately to my left is a Knave."** How many Knights are at the table?

**Solution**

**Insight: each sentence links a person to exactly ONE neighbour, so the types must alternate around the whole circle.** \
Take any person X. \
If X is a Knight, the sentence is true, so X's left neighbour is a Knave. \
If X is a Knave, the sentence is false, so X's left neighbour is **not** a Knave — the left neighbour is a Knight. \
Either way: **X and X's left neighbour are always of opposite types.** \
Now walk around the table in the "left" direction. The type flips at every single step: \
Knight, Knave, Knight, Knave, ... \
After 10 steps you are back at the person you started from. \
Ten flips bring you back to the type you started with, so the pattern is consistent. #sym.checkmark \
Because the types strictly alternate around 10 seats, exactly half the seats are Knights: \
$10 \div 2 = 5$.

**➜ Answer: 5 Knights**

The same walk with 11 people would need 11 flips to return to the start, which changes the type — a contradiction. So this table is **impossible** with any odd number of people.

**Example 33** `D. E. Shaw · pattern`

A row has 15 chairs, all empty. Some people sit down. What is the smallest number of people who must be seated so that **every** empty chair has at least one occupied chair next to it — that is, nobody arriving later can sit without sitting beside somebody?

**Solution**

**Insight: each seated person can "cover" at most two empty chairs — the one on each side. That gives a hard lower bound before you try any pattern.** \
**Step 1 — the bound.** Let $m$ people be seated. \
Empty chairs $= 15 - m$. \
Each seated person has at most 2 neighbouring chairs, so the $m$ people together touch at most $2m$ chairs. \
Every empty chair must be touched, so
$ 15 - m \\le 2m $
$ 15 \\le 3m $
$ m \\ge 5 $
So 4 people can never be enough. \
**Step 2 — show that 5 is enough.** Seat people at chairs 2, 5, 8, 11 and 14. \
Chair 1 and chair 3 touch the person at 2. #sym.checkmark \
Chairs 4 and 6 touch the person at 5. #sym.checkmark \
Chairs 7 and 9 touch the person at 8. #sym.checkmark \
Chairs 10 and 12 touch the person at 11. #sym.checkmark \
Chairs 13 and 15 touch the person at 14. #sym.checkmark \
That is all 10 empty chairs covered, using 5 people. \
The bound says at least 5, and the pattern reaches 5.

**➜ Answer: 5 people**

---
💡 **SHORTCUT**

The pattern "empty, person, empty, empty, person, empty, ..." — a person every third chair, starting at chair 2 — is the general answer. For $n$ chairs the minimum is the smallest whole number that is at least $n slash 3$.

**Example 34** `Uber · pattern`

Four married couples — eight people — sit around a round table with eight seats. Each husband must sit exactly opposite his own wife. Two seatings count as the same if one is a rotation of the other. In how many ways can they be seated?

**Solution**

**Insight: "opposite" ties the 8 seats into 4 fixed seat-pairs. Choose which couple gets which pair, then who in the couple sits where.** \
Number the seats 1 to 8 clockwise. The opposite pairs are $(1,5)$, $(2,6)$, $(3,7)$ and $(4,8)$. \
**Step 1 — kill the rotations.** Fix the first husband at seat 1. Now every seating is counted exactly once. \
His wife is then forced into seat 5. That is 1 way. \
**Step 2 — the other three couples.** Three seat-pairs are still free: $(2,6)$, $(3,7)$, $(4,8)$. \
Choose which of the three remaining couples goes to which pair: \
$3! = 3 \times 2 \times 1 = 6$ ways. \
**Step 3 — inside each pair.** For each couple, the husband may take either of the two seats in their pair, and the wife takes the other: 2 ways per couple. \
For three couples: $2 \times 2 \times 2 = 2^3 = 8$ ways. \
**Total** $= 6 \times 8 = 48$.

**➜ Answer: 48 ways**

**Example 35** `Google · pattern`

Six teams play a round robin: every pair of teams plays exactly once and no match is drawn. Team A wins all of its matches. Teams B, C and D each win exactly 3 matches. Team E wins exactly 1 match. How many matches does team F win?

**Solution**

**Insight: every match produces exactly one win, so the total number of wins equals the total number of matches. That single invariant answers the question.** \
**Step 1 — count the matches.** With 6 teams, each pair plays once:
$ binom(6,2) = (6 \times 5)/2 = 15 $
So there are 15 matches, and therefore 15 wins in total. \
**Step 2 — add the known wins.** \
A: 5 (it plays 5 matches and wins them all). \
B, C, D: $3 + 3 + 3 = 9$. \
E: 1. \
Known total $= 5 + 9 + 1 = 15$. \
**Step 3 — F's wins.** \
$ F = 15 - 15 = 0 $
**Step 4 — check that this is actually possible.** \
F loses all 5 of its matches, and A wins all 5 of its own. \
Each of B, C, D has lost to A and beaten F, giving 1 win each so far; each needs 2 more. \
E has beaten F — that is already E's single win — so E must lose to B, C and D. Those three games give B, C, D one more win each: now 2 each. \
The last three matches are B–C, C–D and D–B. Let B beat C, C beat D and D beat B. Each of B, C, D picks up exactly 1 more win, reaching 3 each. #sym.checkmark \
Everything matches the story, so the answer stands.

**➜ Answer: 0 matches**

#### Practice — Tier 3 — Product *(target: 4 min/Q)*

1. Six people sit in a row of six chairs. Two of them, Meera and Nikhil, must not sit next to each other. In how many different orders can the six sit?
2. Eight people sit around a round table, where two seatings are the same if one is a rotation of the other. In how many ways can they sit if two particular people must sit next to each other?
3. Five people P, Q, R, S, T sit in a row of five chairs. Exactly one person sits between P and Q. In how many different ways can the five sit?
4. A row has 21 chairs, all empty. What is the smallest number of people who must be seated so that every empty chair has at least one occupied chair next to it?
5. Twelve people sit around a circular table. Each one says: **"The person immediately to my right is a liar."** Truth-tellers always tell the truth and liars always lie. How many truth-tellers are at the table?
6. Five teams play a round robin — every pair plays once, no draws. Team X wins all 4 of its matches. Teams Y and Z each win exactly 2. Team W wins exactly 1. How many matches does team V win?
7. Seven people sit in a row of seven chairs. Three of them — A, B and C — must appear in that order from left to right, though not necessarily next to each other. In how many ways can the seven sit?

<details>
<summary><b>Answer key</b></summary>

1. **480 orders.** All orders $= 6! = 720$. Together: glue the pair into a block, giving $5! = 120$ arrangements of 5 objects, times 2 for the swap inside the block $= 240$. Then $720 - 240 = 480$.
2. **1440 ways.** Glue the pair into one block. Seven objects around a round table give $(7 - 1)! = 720$ seatings, and the pair can swap inside the block in 2 ways: $720 \times 2 = 1440$.
3. **36 ways.** Chairs for the pair must differ by 2: $(1,3)$, $(2,4)$, $(3,5)$ — 3 chair-pairs, and P and Q can swap in each, so $3 \times 2 = 6$ placements. The other three people fill the rest in $3! = 6$ ways: $6 \times 6 = 36$.
4. **7 people.** With $m$ seated, $21 - m \\le 2m$ gives $m \\ge 7$. Chairs 2, 5, 8, 11, 14, 17 and 20 cover every empty chair, so 7 is enough.
5. **6 truth-tellers.** A truth-teller's right neighbour is a liar; a liar's statement is false, so a liar's right neighbour is a truth-teller. Types therefore alternate all the way round, and 12 is even, so exactly half — 6 — are truth-tellers.
6. **1 match.** Total matches $= binom(5,2) = 10$, so total wins $= 10$. Known wins $= 4 + 2 + 2 + 1 = 9$, leaving $10 - 9 = 1$ for V. It is possible: X beats everyone; Y beats Z and W; Z beats V and W; V beats Y; W beats V.
7. **840 ways.** Choose the 3 chairs for A, B, C and the 4 chairs for the others: every arrangement of all 7 people can be paired with the $3! = 6$ orders of A, B, C, and exactly one of those six is the required order. So the answer is $7! slash 3! = 5040 slash 6 = 840$.

## Mixed set — exam conditions

#### Practice — Tier 1 — Service *(target: 20 questions in 26 min)*

**Questions 1 to 4.** Eight students — A, B, C, D, E, F, G, H — sit in a row facing North, drawn with West on the left. D sits fourth from the right end. A sits at the extreme left end. Exactly two students sit between A and B. C sits immediately to the right of D. G sits at the extreme right end. F sits immediately to the left of B. E does not sit next to A.

1. Who sits exactly between F and D?
2. How many students sit between C and G?
3. Who sits third to the left of E?
4. If A and G swap seats, who then sits at the extreme left end?

**Questions 5 to 8.** Six people — Ila, Jay, Kim, Lee, Mira and Noor — sit around a circular table facing the centre. Jay sits second to the left of Ila. Kim sits exactly opposite Jay. Lee sits immediately to the left of Jay. Mira sits immediately to the right of Kim.

5. Who sits exactly opposite Ila?
6. Who sits immediately to the right of Noor?
7. How many people sit between Lee and Kim, counting clockwise from Lee?
8. Who sits third to the right of Mira?

9. Five boxes — black, blue, green, red and white — are stacked one above another. The red box is at the top, the blue box is immediately below the red box, and the green box is at the bottom. Exactly one box lies between the green box and the white box. Which box is in the middle of the stack?
10. In a 7-floor building, Amit lives on floor 3, Bhavna lives 3 floors above Amit, and Chetan lives immediately below Bhavna. Which floor does Chetan live on?
11. Seven people sit in a row facing South, drawn with West on the left. Rani sits third from the West end. How many people sit to her right?
12. Five people sit around a circular table facing outward. X sits second to the right of Y. Who sits second to the left of X?
13. Six meetings are held from Monday to Saturday, one each day. The review is on Monday and the demo is on Thursday. The audit is on the day immediately after the review. On which day is the audit?
14. Four friends sit at the four corners of a square table facing the centre. Priya sits diagonally opposite Sanjay, and Tarun sits immediately to the left of Priya. Who sits immediately to the right of Sanjay?
15. Nine people sit in a row of nine chairs facing North. Mohan sits 4th from the left and Nita sits 3rd from the right. How many chairs lie between them?
16. Six students are ranked by marks, with no ties. Priya scored more than Qadir but less than Rohit. Sana scored more than Rohit. Tarun scored less than Qadir. Umi scored the lowest. Who ranks third?
17. Eight people sit around a circular table facing the centre, in seats numbered 1 to 8 clockwise. How many people sit between the person at seat 2 and the person at seat 7, counting clockwise from seat 2?
18. Five boxes P, Q, R, S, T are stacked. Exactly two boxes lie above Q. S lies immediately below Q. T is at the top. P lies below S. Which box is at the bottom?
19. Seven people sit in a row of seven chairs. A sits at the extreme left end and exactly three people sit between A and B. What is B's position counted from the right end?
20. Six people sit around a circular table facing the centre. Deepa sits third to the left of Farhan. Who sits third to the right of Deepa?

<details>
<summary><b>Answer key</b></summary>

Questions 1–4. Seats from the left: A(1), H(2), F(3), B(4), D(5), C(6), E(7), G(8). D is fourth from the right of 8 seats, so D $= 8 - 4 + 1 = 5$; two students between A(1) and B means B $=$ 4; F $=$ 3; C $=$ 6; G $=$ 8; E cannot take seat 2 because that seat touches A, so E $=$ 7 and H $=$ 2.
1. **B.** F is at 3 and D at 5, so seat 4 lies between.
2. **1 student.** C is at 6 and G at 8, so only seat 7 lies between.
3. **B.** Facing North, left is a smaller number: $7 - 3 = 4$.
4. **G.** The swap puts G at seat 1.

Questions 5–8. Clockwise: Ila(1), Noor(2), Jay(3), Lee(4), Mira(5), Kim(6). Facing the centre, left is clockwise and right is anticlockwise.
5. **Lee.** Opposite Ila $= 1 + 3 = 4$.
6. **Ila.** Noor is at 2, so his right is $2 - 1 = 1$.
7. **1 person.** From seat 4 clockwise to seat 6 you pass seat 5 only.
8. **Noor.** Mira is at 5, so third to her right is $5 - 3 = 2$.

9. **The white box.** Positions from the bottom: green(1), black(2), white(3), blue(4), red(5). One box between green(1) and white puts white at 3, which is the middle of 5.
10. **Floor 5.** Bhavna is on $3 + 3 = 6$, so Chetan is on 5.
11. **2 people.** Facing South, right means the West side, so seats 1 and 2 are to her right.
12. **Y.** Facing outward, right is clockwise and left is anticlockwise. Put Y at seat 1; then X $= 1 + 2 = 3$, and second to X's left is $3 - 2 = 1$.
13. **Tuesday.** The review is on Monday, and "immediately after" is the very next day.
14. **Tarun.** Put Priya at corner 1; Sanjay $= 1 + 2 = 3$; facing the centre, left is clockwise so Tarun $= 2$; Sanjay's right is $3 - 1 = 2$.
15. **2 chairs.** Nita from the left $= 9 - 3 + 1 = 7$, and $7 - 4 - 1 = 2$.
16. **Priya.** The chain is Sana $>$ Rohit $>$ Priya $>$ Qadir $>$ Tarun $>$ Umi.
17. **4 people.** Seats 3, 4, 5 and 6 lie between.
18. **P.** Two boxes above Q puts Q at position 3; S $=$ 2; T $=$ 5; P is below S, so P $=$ 1 and R $=$ 4.
19. **3rd from the right.** A $=$ 1, and three people between gives B $= 1 + 4 = 5$; then $7 - 5 + 1 = 3$.
20. **Farhan.** Put Farhan at seat 1; Deepa $= 1 + 3 = 4$; third to Deepa's right is $4 - 3 = 1$. (In a circle of 6, "third to the left" and "third to the right" both land on the opposite seat.)

## 📋 One-page revision card

**Draw it the same way every time**
- Row: seats 1 to $n$, left to right, with West on the left.
- Circle: seat 1 at the top, numbered clockwise.
- Floors and stacks: 1 at the bottom, $n$ at the top.

**Left and right**
- Row, facing North: left $=$ smaller seat number, right $=$ larger.
- Row, facing South: left $=$ larger seat number, right $=$ smaller.
- Circle, facing the centre: left $=$ clockwise ($+$), right $=$ anticlockwise ($-$).
- Circle, facing outward: left $=$ anticlockwise ($-$), right $=$ clockwise ($+$).
- Double row: the two rows use opposite rules, and seat $k$ faces seat $k$.

**Key counts**
- Opposite in a circle of $n$ (even only): seat $k + n slash 2$, wrapping by $-n$.
- Exactly $x$ people between $A$ and $B$: seat numbers differ by $x + 1$.
- Exact middle of $n$ seats: seat $(n + 1) slash 2$, and only when $n$ is odd.
- Position from the right in a row of $n$: $n - ("position from the left") + 1$.
- Square table with 8 seats: corners and middles alternate, so corners are 1, 3, 5, 7.

**Shortcuts**
- Fix one named person at seat 1 of a circle before anything else — a circle has no real start.
- Use clues in this order: ends and exact middle, then "immediately next to" chains, then two-case clues, then negative clues last.
- In a grid puzzle, pin the day or floor column first; the attribute column then falls out by elimination.
- Counting arrangements with "must not sit together": count all, subtract the together case.
- Counting round-table arrangements with "rotations are the same": fix one person, and $n!$ becomes $(n-1)!$.
- Every match has exactly one winner, so total wins $=$ total matches $= binom(n,2)$.

**Top 5 traps**
+ Reading "two people between $A$ and $B$" as a gap of 2. The gap is 3.
+ Using one left/right rule for both rows of a double row. They are opposite.
+ Using the **reader's** left instead of the **seated person's** left in a circle.
+ Saying somebody is "opposite" in a circle with an odd number of seats. Nobody is.
+ Starting from a negative clue ("X does not sit next to Y"). It removes options; it never places anybody. Save it for last.

</details>

</details>

</details>

</details>
