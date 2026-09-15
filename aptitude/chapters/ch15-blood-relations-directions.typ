#import "../lib/style.typ": *

#chapter(num: 15, title: "Blood Relations, Directions & Ranking", tagline: "Draw the tree, draw the map, count the row")[

#section[What you need to know]

#formulas(title: "Quick reference")[

*1. Blood relations — the three symbols you draw*

- Write a *male* with a small `+` after the name, a *female* with a small `−`.
- Join a married couple with `=` on the same line (same generation).
- Drop a short vertical line from the couple to their children. Children sit on one horizontal line (they are siblings).
- *Same generation sits on the same level.* If two people are on the same level they are siblings, cousins or spouses — never parent and child.

*2. Relation dictionary (learn this cold)*

#table(columns: (auto, auto, auto, auto),
  [Father's / Mother's father], [Grandfather], [Husband's or wife's brother], [Brother-in-law],
  [Father's / Mother's mother], [Grandmother], [Husband's or wife's sister], [Sister-in-law],
  [Father's brother], [Paternal uncle], [Sister's husband], [Brother-in-law],
  [Father's sister], [Paternal aunt], [Brother's wife], [Sister-in-law],
  [Mother's brother], [Maternal uncle], [Son's wife], [Daughter-in-law],
  [Mother's sister], [Maternal aunt], [Daughter's husband], [Son-in-law],
  [Brother's / Sister's son], [Nephew], [Son's / Daughter's son], [Grandson],
  [Brother's / Sister's daughter], [Niece], [Son's / Daughter's daughter], [Granddaughter],
  [Uncle's / Aunt's child], [Cousin], [Wife's / Husband's parent], [Parent-in-law],
)

*3. Coded relations.* Solve one symbol at a time, left to right. Write each new fact on the tree before reading the next symbol. Never try to hold three symbols in your head.

*4. Directions — the compass wheel*

Clockwise order, $45degree$ apart each step:
$ "N" -> "NE" -> "E" -> "SE" -> "S" -> "SW" -> "W" -> "NW" -> "N" $

Turn table (memorise, do not re-derive):

#table(columns: (auto, auto, auto, auto),
  [*Facing*], [*Turn left*], [*Turn right*], [*About turn*],
  [North], [West], [East], [South],
  [East],  [North], [South], [West],
  [South], [East], [West], [North],
  [West],  [South], [North], [East],
)

- One left turn $= 90degree$ anticlockwise. One right turn $= 90degree$ clockwise.
- Two same-side turns $=$ about turn $= 180degree$.
- Angles: take North $= 0degree$ and count *clockwise*. E $= 90degree$, S $= 180degree$, W $= 270degree$, NE $= 45degree$, SE $= 135degree$, SW $= 225degree$, NW $= 315degree$. Add for clockwise, subtract for anticlockwise, then reduce modulo $360degree$.

*5. Net displacement.* Add all North legs, subtract all South legs $->$ vertical net $v$. Add all East legs, subtract all West legs $->$ horizontal net $h$.
$ "distance" = sqrt(h^2 + v^2) $
Useful triples: $(3,4,5)$, $(5,12,13)$, $(6,8,10)$, $(8,15,17)$, $(9,12,15)$, $(7,24,25)$, $(20,21,29)$, $(9,40,41)$.
If $|h| = |v|$ the answer is $h sqrt(2)$ and the point is on an exact $45degree$ corner line.
- *Naming the direction.* A corner name here means the *quarter*, not the exact $45degree$ line. "North-East of the start" only means North of it and East of it. So $v = 3$ North with $h = 4$ East is still reported as North-East, even though the exact corner line needs $|h| = |v|$.
- Read the two nets as a pair of words: $v$ positive $=$ North, $v$ negative $=$ South; $h$ positive $=$ East, $h$ negative $=$ West. If one net is 0, say "due North", "due South", "due East" or "due West".

*6. Shadows*

- Just after sunrise the sun is in the *East*, so every shadow points *West*.
- Just before sunset the sun is in the *West*, so every shadow points *East*.
- At about noon the shadow is too short to give a direction. Any question set "at 12 noon" has no usable direction.
- Left / right rule: a person facing direction $D$ has the *right* hand pointing at $D$ turned $90degree$ clockwise, and the *left* hand at $D$ turned $90degree$ anticlockwise.

*7. Ranking (a single row, no ties)*

$ "Total" = ("rank from left") + ("rank from right") - 1 $
$ "rank from right" = "Total" - ("rank from left") + 1 $
- People strictly between $A$ and $B$ (with $A$ left of $B$), both ranks counted from the left:
$ "between" = (B "from left") - (A "from left") - 1 $
- "There are $x$ people between $A$ and $B$" means their positions differ by $x + 1$.
- If $k$ people scored *above* you, your rank from the top is $k + 1$.
- If $k$ people scored *below* you, your rank from the bottom is $k + 1$.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
Pointing to a boy, Ravi said, "He is the son of my father's only son." How is the boy related to Ravi?
#sol[
Ravi's father's only son $=$ Ravi himself. \
So the boy is the son of Ravi.
]
#ans[Son]
]

#ex(2, tier: 0)[
A is the sister of B. C is the mother of B. D is the father of C. How is A related to D?
#sol[
C is the mother of B, and A is B's sister, so C is also A's mother. \
D is C's father, so D is A's grandfather. \
A is female, so A is D's granddaughter.
]
#ans[Granddaughter]
]

#ex(3, tier: 0)[
Meera faces North. She turns right, then turns right again. Which way does she face now?
#sol[
Facing North, turn right $->$ East. \
Facing East, turn right $->$ South.
]
#ans[South]
]

#ex(4, tier: 0)[
A man walks 6 km East, then 8 km North. How far is he from his starting point?
#sol[
$h = 6$ (East), $v = 8$ (North). \
$"distance" = sqrt(6^2 + 8^2) = sqrt(36 + 64) = sqrt(100) = 10$ km.
]
#ans[10 km]
]

#ex(5, tier: 0)[
In a row of 40 students, Arun is 12th from the left. What is his rank from the right?
#sol[
$"rank from right" = 40 - 12 + 1 = 29$.
]
#ans[29th from the right]
]

#ex(6, tier: 0)[
Nisha is 9th from the top and 14th from the bottom of a merit list. How many students are on the list?
#sol[
$"Total" = 9 + 14 - 1 = 22$.
]
#ans[22 students]
]

#ex(7, tier: 0)[
Somchai stands facing the rising sun. Which direction is his left hand pointing?
#sol[
The rising sun is in the East, so he faces East. \
Facing East, the left hand points to East turned $90degree$ anticlockwise $=$ North.
]
#ans[North]
]

#ex(8, tier: 0)[
'P & Q' means P is the mother of Q. 'P × Q' means P is the brother of Q. \
What does 'A & B × C' tell you about A and C?
#sol[
A & B: A is the mother of B. \
B × C: B is the brother of C, so B and C have the same mother. \
That mother is A.
]
#ans[A is the mother of C]
]

#section[Tier 1 — Service companies]
#tier-header(1)

#ex(9, tier: 1, asked: "TCS NQT pattern")[
Pointing to a lady, Ramesh said, "She is the daughter of the only son of my grandfather." How is the lady related to Ramesh?
#sol[
Grandfather's only son $=$ Ramesh's father. \
So the lady is the daughter of Ramesh's father. \
A daughter of Ramesh's father is Ramesh's sister.
]
#ans[Sister]
]

#trick[
Peel the sentence from the *inside out*, never from the start. Find the innermost phrase ("my grandfather"), replace it with a real person, then move one layer out. Write each layer on paper as a short chain:
grandfather $->$ his only son $=$ father $->$ his daughter $=$ sister.
]

#ex(10, tier: 1, asked: "Infosys pattern")[
In a code: \
'A % B' means A is the father of B. \
'A ÷ B' means A is the daughter of B. \
'A × B' means A is the brother of B. \
How is P related to S in 'P ÷ Q % R × S'?
#sol[
P ÷ Q: P is the daughter of Q. \
Q % R: Q is the father of R. \
R × S: R is the brother of S. \
So R and S have the same father. That father is Q. \
Therefore P, R and S are all children of Q. \
P is female, so P is the sister of S.
]
#ans[P is the sister of S]
]

#ex(11, tier: 1, asked: "Accenture pattern")[
Kavya leaves home, walks 3 km North, turns right and walks 4 km, then turns right and walks 6 km. How far is she from home, and in which direction?
#sol[
Leg 1: 3 km North. \
Facing North, turn right $->$ East. Leg 2: 4 km East. \
Facing East, turn right $->$ South. Leg 3: 6 km South. \
Vertical net $= 3 - 6 = -3$, i.e. 3 km South. \
Horizontal net $= 4$ km East. \
$"distance" = sqrt(3^2 + 4^2) = sqrt(9 + 16) = sqrt(25) = 5$ km. \
She is South and East of home, so the direction is South-East.
]
#ans[5 km, South-East of home]
]

#ex(12, tier: 1, asked: "Wipro pattern")[
In a row, Priya is 14th from the left and Rahul is 17th from the right. They swap seats. After the swap Priya is 21st from the left. How many people are in the row?
#sol[
After the swap Priya is sitting in Rahul's old seat. \
So Rahul's old seat is 21st from the left. \
That same seat is 17th from the right. \
$"Total" = 21 + 17 - 1 = 37$.
]
#ans[37 people]
#note[Priya's original 14th position is not needed. Extra data is normal in this pattern.]
]

#ex(13, tier: 1, asked: "Capgemini pattern")[
In a row of 45 children, Anil is 18th from the left and Bala is 21st from the right. How many children sit between them?
#sol[
Bring both ranks to the same side. \
Bala from the left $= 45 - 21 + 1 = 25$. \
Anil is at 18, Bala is at 25, and $25 > 18$. \
Between $= 25 - 18 - 1 = 6$.
]
#ans[6 children]
]

#trap[
Do *not* subtract the two given ranks when they are counted from *opposite* ends. Here $21 - 18 = 3$ is meaningless. Always convert both to "from the left" first.
]

#ex(14, tier: 1, asked: "Cognizant pattern")[
Introducing a man, a woman said, "His wife is the only daughter of my mother." How is the man related to the woman?
#sol[
The only daughter of the woman's mother must be the woman herself (she is her mother's only daughter). \
So the man's wife is the woman. \
Therefore the man is her husband.
]
#ans[Husband]
]

#trap[
"The only daughter of my mother" and "the only son of my father" very often point *back at the speaker*. Before you invent a new person, check whether the speaker fits the description. Here inventing a sister would give the wrong answer "brother-in-law".
]

#ex(15, tier: 1, asked: "TCS NQT pattern")[
One evening, just before sunset, Suresh and Tanvi stood facing each other. Tanvi's shadow fell exactly to the right of Suresh. Which direction was Suresh facing?
#sol[
Just before sunset the sun is in the West, so every shadow points East. \
So East is on Suresh's right. \
A person whose right hand points East is facing North (North turned $90degree$ clockwise is East).
]
#ans[North]
]

#ex(16, tier: 1, asked: "Infosys pattern")[
Meena is the mother of Karan. Karan is the brother of Deepa. Deepa is the daughter of Suresh. Gopal is the father of Suresh. How is Gopal related to Karan?
#sol[
Deepa is the daughter of Suresh, so Suresh is Deepa's father. \
Karan is Deepa's brother, so Suresh is also Karan's father. \
Gopal is Suresh's father, so Gopal is Karan's father's father.
]
#ans[Gopal is Karan's grandfather (paternal)]
]

#ex(17, tier: 1, asked: "Accenture pattern")[
In a class, Ravi's rank is 9th from the top. Sita's rank is 12th from the bottom. Exactly 5 students rank between them, and Ravi ranks above Sita. How many students are in the class?
#sol[
Ravi is 9th from the top. \
5 students sit between them, so Sita is $9 + 5 + 1 = 15$th from the top. \
Sita is also 12th from the bottom. \
$"Total" = 15 + 12 - 1 = 26$.
]
#ans[26 students]
]

#trap[
"5 students between them" is *not* "Sita is 5 places below Ravi". Positions differ by $5 + 1 = 6$, not by 5. Miscounting this by one is the single most common ranking error.
]

#ex(18, tier: 1, asked: "Wipro pattern")[
A delivery rider starts at the depot and rides 5 km South, then 12 km West, then 5 km North, then 6 km East. How far is he from the depot and in which direction?
#sol[
Vertical: $5$ South and $5$ North cancel, net $= 0$. \
Horizontal: $12$ West and $6$ East give net $= 12 - 6 = 6$ km West. \
$"distance" = sqrt(0^2 + 6^2) = 6$ km.
]
#ans[6 km, due West of the depot]
]

#trick[
Never draw the path leg by leg on a map. Make two running totals only: a *North–South* total and an *East–West* total. Five legs collapse into two numbers in about ten seconds.
]

#ex(19, tier: 1, asked: "Capgemini pattern")[
In a queue of 60 people, Nithya is 24th from the front. Vikram stands 5 places behind Nithya. What is Vikram's position from the back?
#sol[
Vikram from the front $= 24 + 5 = 29$. \
Vikram from the back $= 60 - 29 + 1 = 32$.
]
#ans[32nd from the back]
]

#practice(tier: 1, time: "60 s/Q")[
+ Pointing to a man, Leela said, "His mother is the only daughter of my mother." How is the man related to Leela?
+ A is the brother of B. B is the sister of C. C is the son of D. How is A related to D?
+ Aarav faces South. He turns left, then right, then right again. Which direction does he face?
+ A man walks 10 m North, 6 m East, then 10 m South. How far is he from the start and in which direction?
+ In a row of 32 children, Kavin is 11th from the right. What is his position from the left?
+ Mei is 7th from the top and 23rd from the bottom of a merit list. How many students are on the list?
+ In a queue, Deepak is 15th from the front and 19th from the back. How many people are in the queue?
+ Pointing to a boy, Farida said, "He is the son of my grandfather's only son." How is the boy related to Farida?
+ 'A ÷ B' means A is the son of B. 'A × B' means A is the sister of B. What does 'P ÷ Q × R' tell you about P and R?
+ Rekha walks 4 km West, turns right and walks 3 km, then turns right and walks 4 km. How far is she from the start and in which direction?
+ In a row of 50 people, Suri is 20th from the left and Tina is 20th from the right. How many people are between them?
+ Early in the morning, just after sunrise, Rohit stood facing a pole. The pole's shadow fell exactly to his left. Which direction was Rohit facing?
+ V is the daughter of W. W is the son of X. X is the mother of Y. Y is the brother of W. How is V related to Y?
+ A man walks 5 km South, turns left and walks 5 km, turns left and walks 5 km, then turns right and walks 3 km. How far is he from the start and in which direction?
+ In a class of 40, Anu's rank from the top is 16 and Bala's rank from the top is 25. How many students rank between them?
]

#key[
1. *Son.* The only daughter of Leela's mother is Leela, so Leela is his mother.
2. *A is the son of D.* C is D's son; B is C's sibling; A is B's brother; so all three are D's children and A is male.
3. *West.* South $->$ left $->$ East $->$ right $->$ South $->$ right $->$ West.
4. *6 m, due East.* North 10 and South 10 cancel; only the 6 m East survives.
5. *22nd from the left.* $32 - 11 + 1 = 22$.
6. *29 students.* $7 + 23 - 1 = 29$.
7. *33 people.* $15 + 19 - 1 = 33$.
8. *Brother.* Grandfather's only son is Farida's father; his son is Farida's brother.
9. *P is the nephew of R.* Q is R's sister, so R is P's uncle or aunt; P is a son, so P is male.
10. *3 km, due North.* West 4 then North 3 then East 4: the two 4s cancel.
11. *10 people.* Tina from left $= 50 - 20 + 1 = 31$; between $= 31 - 20 - 1 = 10$.
12. *North.* After sunrise shadows point West; West on his left means he faces North.
13. *V is the niece of Y.* W and Y are both children of X, so they are siblings; V is W's daughter.
14. *8 km, due East.* South 5, East 5, North 5, East 3: vertical cancels, horizontal $= 5 + 3 = 8$.
15. *8 students.* $25 - 16 - 1 = 8$.
]

#section[Tier 2 — Singapore & Thailand]
#tier-header(2)

#ex(20, tier: 2, asked: "Grab · pattern")[
A rider leaves the hub and rides 9 km North, 12 km East, 3 km South and 4 km West. \
(a) What is his straight-line distance from the hub? \
(b) What fraction of the distance he rode is that straight-line distance?
#sol[
*(a)* Vertical net $= 9 - 3 = 6$ km North. \
Horizontal net $= 12 - 4 = 8$ km East. \
$"distance" = sqrt(6^2 + 8^2) = sqrt(36 + 64) = sqrt(100) = 10$ km. \
*(b)* Distance ridden $= 9 + 12 + 3 + 4 = 28$ km. \
Fraction $= 10/28$. Divide top and bottom by 2: $10 div 2 = 5$ and $28 div 2 = 14$, so the fraction is $5/14$.
]
#ans[10 km (North-East of the hub); $5 slash 14$ of the distance ridden]
]

#ex(21, tier: 2, asked: "Sea/Shopee · pattern")[
Six people are in one family: Anong, Boon, Chai, Dara, Esha, Farid.
- Anong and Boon are a married couple, and Boon is the father in the family.
- Chai is the son of Anong.
- Dara is the sister of Chai.
- Esha is the daughter of Dara.
- Farid is the brother of Esha.

(a) How is Farid related to Anong? \
(b) How many grandchildren does Boon have?
#sol[
Chai is Anong's son and Dara is Chai's sister, so Dara is also a child of Anong and Boon. \
Generation 1: Anong $=$ Boon. \
Generation 2: Chai and Dara. \
Esha is Dara's daughter, and Farid is Esha's brother, so Farid is also Dara's child. \
Generation 3: Esha and Farid. \
*(a)* Farid is the son of Anong's daughter, so Farid is Anong's grandson. \
*(b)* The only third-generation people named are Esha and Farid. Nothing says Chai has children, so Boon has 2 grandchildren.
]
#ans[(a) Grandson  (b) 2 grandchildren]
]

#trap[
Count only the people the question actually names. Chai *may* have children in real life, but the puzzle never says so, so he contributes zero grandchildren. Reasoning "he is grown up, so he must have kids" loses the mark.
]

#ex(22, tier: 2, asked: "DBS · pattern")[
In a batch of 250 trainees, 36 percent of the trainees scored above Meera. No two scores are equal. How many trainees scored below her?
#sol[
Trainees above Meera $= 36/100 times 250 = (36 times 250)/100 = 9000/100 = 90$. \
So Meera's rank from the top $= 90 + 1 = 91$. \
Trainees below her $= 250 - 91 = 159$.
]
#ans[159 trainees]
]

#trap[
$36%$ of 250 is 90 *people above her*, not her rank. Her rank is 91. Answering 160 (that is, $250 - 90$) forgets to exclude Meera herself.
]

#ex(23, tier: 2, asked: "GIC · pattern")[
Kishore faces North. He turns $135degree$ clockwise, then $180degree$ anticlockwise, then $90degree$ clockwise. Which direction does he face?
#sol[
Use bearings: North $= 0degree$, measured clockwise. \
Start: $0degree$. \
After $135degree$ clockwise: $0 + 135 = 135degree$. \
After $180degree$ anticlockwise: $135 - 180 = -45degree$. Add $360degree$: $315degree$. \
After $90degree$ clockwise: $315 + 90 = 405degree$. Subtract $360degree$: $45degree$. \
$45degree$ is North-East.
]
#ans[North-East]
]

#trick[
Turn every turn into a bearing sum. Clockwise is $+$, anticlockwise is $-$, then reduce modulo $360$. Three turns become one addition. Chasing the compass step by step is where mistakes happen.
]

#ex(24, tier: 2, asked: "Agoda · pattern")[
Pim and Wichai start from the same point. Pim walks 8 km East, then 6 km North. Wichai walks 4 km West, then 6 km South, then 12 km East. How far apart are they now, and where is Pim relative to Wichai?
#sol[
Put the start at $(0, 0)$, with East as $+x$ and North as $+y$. \
Pim: East 8 gives $(8, 0)$; North 6 gives $(8, 6)$. \
Wichai: West 4 gives $(-4, 0)$; South 6 gives $(-4, -6)$; East 12 gives $(-4 + 12, -6) = (8, -6)$. \
Both have $x = 8$, so they are on the same North–South line. \
Gap $= 6 - (-6) = 12$ km. \
Pim's $y$ is larger, so Pim is to the North.
]
#ans[12 km apart; Pim is due North of Wichai]
]

#ex(25, tier: 2, asked: "SCB · pattern")[
In a code: \
'A + B' means A is the father of B. \
'A − B' means A is the mother of B. \
'A × B' means A is the brother of B. \
'A ÷ B' means A is the sister of B. \
Which expression shows that D is the *paternal aunt* of E?
#opts([D ÷ F + E], [D ÷ F − E], [D × F + E], [F + E ÷ D])
#sol[
Paternal aunt $=$ father's sister. \
So we need two links: D is the *sister* of someone, and that someone is the *father* of E. \
"D is the sister of F" is written D ÷ F. \
"F is the father of E" is written F + E. \
Joining them: D ÷ F + E.
]
#ans[(a) D ÷ F + E]
#note[
(b) D ÷ F − E makes F the *mother* of E, so D would be a maternal aunt. \
(c) D × F + E makes D a brother, so D would be a paternal uncle. \
(d) F + E ÷ D says E is D's sister, which is the wrong generation.
]
]

#ex(26, tier: 2, asked: "LINE MAN · pattern")[
In a queue of riders, Anucha is 16th from the front and 22nd from the back. Boonmee then joins the queue standing immediately behind Anucha, and everybody behind shifts back by one. What is Boonmee's position from the back?
#sol[
Original total $= 16 + 22 - 1 = 37$ riders. \
After Boonmee joins, total $= 37 + 1 = 38$. \
Anucha is still 16th from the front (nobody ahead of him changed). \
Boonmee is immediately behind Anucha, so Boonmee is 17th from the front. \
Boonmee from the back $= 38 - 17 + 1 = 22$.
]
#ans[22nd from the back]
]

#ex(27, tier: 2, asked: "Razer · pattern")[
A drone starts at base. It flies North at 12 km/h for 40 minutes, then East at 16 km/h for 45 minutes, then South at 9 km/h for 20 minutes. How far is it from base, and in which direction?
#sol[
Convert each leg to a distance. \
North: $12 times 40/60 = 12 times 2/3 = 8$ km. \
East: $16 times 45/60 = 16 times 3/4 = 12$ km. \
South: $9 times 20/60 = 9 times 1/3 = 3$ km. \
Vertical net $= 8 - 3 = 5$ km North. \
Horizontal net $= 12$ km East. \
$"distance" = sqrt(5^2 + 12^2) = sqrt(25 + 144) = sqrt(169) = 13$ km. \
North and East, so the direction is North-East.
]
#ans[13 km, North-East of base]
]

#ex(28, tier: 2, asked: "Grab · pattern")[
Six people: Gita, Hari, Ivan, Jaya, Kiran, Lalit.
- Gita is the grandmother of Kiran.
- Hari is the only son of Gita.
- Jaya is the daughter of Gita.
- Ivan is the husband of Jaya.
- Lalit is the son of Hari.
- Kiran is a boy and is not the child of Hari.

(a) How is Ivan related to Lalit? \
(b) How is Kiran related to Hari?
#sol[
Gita's children: Hari (her only son) and Jaya. \
Jaya is married to Ivan. \
Lalit is Hari's son, so Lalit is Gita's grandchild. \
Kiran is Gita's grandchild but not Hari's child, so Kiran must be a child of Jaya and Ivan. \
*(a)* Lalit's father is Hari. Hari's sister is Jaya. Jaya's husband is Ivan. \
So Ivan is the husband of Lalit's paternal aunt, that is, Lalit's uncle. \
*(b)* Kiran's mother is Jaya. Jaya's brother is Hari. \
So Hari is Kiran's maternal uncle, and Kiran (a boy) is Hari's nephew.
]
#ans[(a) Ivan is Lalit's uncle  (b) Kiran is Hari's nephew]
]

#practice(tier: 2, time: "100 s/Q")[
+ A courier leaves the warehouse and rides 20 km North, 15 km East, 8 km South and 3 km West. How far is he from the warehouse, and in which direction?
+ In a Bangkok office of 180 staff, 45 percent of the staff scored below Pim in an internal test. No scores tie. What is Pim's rank from the top?
+ A drone flies East at 24 km/h for 25 minutes, then North at 18 km/h for 80 minutes. How far is it from the launch point?
+ In a code, 'A © B' means A is the brother of B, 'A @ B' means A is the mother of B, 'A £ B' means A is the daughter of B, and 'A ¥ B' means A is the wife of B. Which expression means "P is the maternal uncle of Q"? #opts([P © R @ Q], [P © R £ Q], [P £ R @ Q], [R @ Q © P])
+ In a row of riders, Boonmee is 18th from the left and Chai is 27th from the right. Exactly 5 riders stand between them, and Boonmee is to the left of Chai. How many riders are in the row?
+ Ken is the son of Lily. Lily is the only daughter of Mano. Nina is the wife of Mano. Oscar is the brother of Lily. Priya is the daughter of Oscar. How is Priya related to Ken?
+ Two cyclists start from the same point. One rides 30 km North then 40 km East. The other rides 40 km South then 30 km West. How far apart are they? (Leave the answer in surd form and also to the nearest km.)
+ Anong faces North-East. She turns $135degree$ anticlockwise, then $90degree$ clockwise. Which direction does she face?
+ In a test of 400 candidates with no ties, Arjun's rank from the top is 3 less than three times his rank from the bottom. What is his rank from the top?
+ A man starts walking towards the setting sun. After 8 km he turns left and walks 6 km, then turns left and walks 14 km. How far is he from the start, and in which direction?
+ Tarun is the brother of Uma. Vidya is the mother of Uma. Wasim is the father of Tarun. Xu is the mother of Wasim. How is Xu related to Uma?
]

#key[
1. *$12 sqrt(2) approx 17.0$ km, North-East.* Vertical $= 20 - 8 = 12$ N, horizontal $= 15 - 3 = 12$ E, so $sqrt(144 + 144) = 12 sqrt(2)$.
2. *99th from the top.* Below her $= 0.45 times 180 = 81$, so her rank from the bottom is 82, and $180 - 82 + 1 = 99$.
3. *26 km.* East $= 24 times 25/60 = 10$ km; North $= 18 times 80/60 = 24$ km; $sqrt(100 + 576) = sqrt(676) = 26$.
4. *(a) P © R @ Q.* Maternal uncle $=$ mother's brother: P is the brother of R, and R is the mother of Q. In (b) R is Q's daughter, in (c) P is female, in (d) the links point the wrong way.
5. *50 riders.* Chai from the left $= 18 + 5 + 1 = 24$; total $= 24 + 27 - 1 = 50$.
6. *Priya is Ken's cousin.* Lily and Oscar are both children of Mano and Nina; Ken is Lily's son and Priya is Oscar's daughter.
7. *$70 sqrt(2) approx 99$ km.* First is at $(40, 30)$, second at $(-30, -40)$; gaps are 70 and 70, so $sqrt(4900 + 4900) = 70 sqrt(2) approx 98.99$.
8. *North.* NE $= 45degree$; $45 - 135 = -90 -> 270degree$ (West); $270 + 90 = 360 -> 0degree$ (North).
9. *300th from the top.* Let the rank from the bottom be $b$; then $(3b - 3) + b = 401$, so $4b = 404$, $b = 101$ and the rank from the top is $3(101) - 3 = 300$.
10. *$6 sqrt(2) approx 8.49$ km, South-East.* West 8, then South 6, then East 14: horizontal $= -8 + 14 = 6$ E, vertical $= 6$ S.
11. *Grandmother (paternal).* Wasim fathers Tarun, and Uma is Tarun's sister, so Wasim is Uma's father too; Xu is Wasim's mother.
]

#section[Tier 3 — Product companies]
#tier-header(3)

#ex(29, tier: 3, asked: "Google · pattern")[
In a class of 35 students with no tied scores, exactly 12 students scored more than Ria, and exactly 18 students scored less than Sam. How many students rank strictly between Sam and Ria?
#sol[
*Insight: turn every clue into a single number — the rank from the top. Then the counting is one subtraction.* \
12 scored above Ria, so Ria's rank from the top $= 12 + 1 = 13$. \
18 scored below Sam, so Sam's rank from the bottom $= 18 + 1 = 19$. \
Convert Sam to a rank from the top: $35 - 19 + 1 = 17$. \
Ria is 13th, Sam is 17th, and $17 > 13$. \
Students strictly between $= 17 - 13 - 1 = 3$.
]
#ans[3 students]
]

#ex(30, tier: 3, asked: "Amazon · pattern")[
A robot starts at the origin facing North. On move $k$ it drives forward exactly $k$ metres, then turns $90degree$ to its right. After 100 moves, how far is it from the origin, in which direction, and which way is it facing?
#sol[
*Insight: the robot repeats its heading every 4 moves, so group the moves in blocks of 4 and add the blocks.* \
Headings cycle: move 1 North, move 2 East, move 3 South, move 4 West, move 5 North again, and so on. \
Take East as $+x$ and North as $+y$. \
Block 1 (moves 1 to 4): \
$y: +1$ then $-3$, so $y$ changes by $1 - 3 = -2$. \
$x: +2$ then $-4$, so $x$ changes by $2 - 4 = -2$. \
Block 2 (moves 5 to 8): \
$y: +5 - 7 = -2$. $x: +6 - 8 = -2$. \
Every block of 4 changes the position by exactly $(-2, -2)$, because the two lengths in each direction always differ by 2. \
Number of blocks $= 100 div 4 = 25$. \
Final position $= (25 times (-2), " " 25 times (-2)) = (-50, -50)$. \
$"distance" = sqrt(50^2 + 50^2) = sqrt(2500 + 2500) = sqrt(5000) = 50 sqrt(2) approx 70.7$ m. \
$x$ negative is West and $y$ negative is South, so the direction is South-West. \
Facing: 100 is a multiple of 4, so the heading has come back to the start.
]
#ans[$50 sqrt(2) approx 70.7$ m South-West of the origin, facing North]
]

#trick[
Any "turn the same way every step" walk closes its heading after 4 steps. So never simulate 100 moves. Simulate 4, read off the block shift, and multiply.
]

#ex(31, tier: 3, asked: "Goldman Sachs · pattern")[
Thirty children stand in a row. Arjun stands somewhere to the left of Bhavna, with at least 5 children between them. Arjun is not in the first 4 positions from the left. What is the largest possible rank of Bhavna counted from the right?
#sol[
*Insight: "rank from the right" gets bigger as a person moves left. So push Bhavna as far left as the rules allow.* \
Number the positions 1 to 30 from the left. \
Arjun is not in positions 1 to 4, so Arjun's position $a >= 5$. \
At least 5 children between them means $b - a - 1 >= 5$, so $b >= a + 6$. \
The smallest possible $b$ comes from the smallest possible $a$: \
$a = 5$ gives $b >= 5 + 6 = 11$. \
So Bhavna's leftmost possible position is 11. \
Bhavna's rank from the right $= 30 - 11 + 1 = 20$. \
Check: Arjun at 5, Bhavna at 11, children in positions 6, 7, 8, 9, 10 lie between them — that is exactly 5. Valid.
]
#ans[20th from the right]
]

#ex(32, tier: 3, asked: "D. E. Shaw · pattern")[
A hiker walks 10 km due North. She then walks 10 km in a straight line and finds that she is now exactly North-East of her starting point. In which direction did she walk the second leg, and how far is she from the start?
#sol[
*Insight: "exactly North-East" is not vague — it is the precise condition $x = y$ with both positive.* \
Put the start at $(0, 0)$, East as $+x$, North as $+y$. \
After the first leg she is at $(0, 10)$. \
Let the end point be $(x, y)$. North-East of the start means $x = y$ and $x > 0$. \
The second leg has length 10, so
$ x^2 + (y - 10)^2 = 100 $
Substitute $y = x$:
$ x^2 + (x - 10)^2 = 100 $
$ x^2 + x^2 - 20x + 100 = 100 $
$ 2x^2 - 20x = 0 $
$ 2x(x - 10) = 0 $
So $x = 0$ or $x = 10$. $x = 0$ is rejected because then she is due North, not North-East. \
So $x = 10$ and $y = 10$; the end point is $(10, 10)$. \
The second leg went from $(0, 10)$ to $(10, 10)$: the $y$ value did not change and $x$ increased, so she walked *due East*. \
$"distance from start" = sqrt(10^2 + 10^2) = sqrt(200) = 10 sqrt(2) approx 14.14$ km.
]
#ans[She walked due East; she is $10 sqrt(2) approx 14.14$ km from the start]
]

#ex(33, tier: 3, asked: "Adobe · pattern")[
At a family dinner the guests included: 1 grandfather, 1 grandmother, 2 fathers, 2 mothers, 4 children, 3 grandchildren, 1 brother, 2 sisters, 2 sons, 2 daughters, 1 father-in-law, 1 mother-in-law and 1 daughter-in-law. What is the smallest number of people who could have been at the dinner?
#sol[
*Insight: the counts are roles, not people. One person can fill many roles at once, so build the smallest family tree that covers every role.* \
Try three generations along one line. \
Generation 1: a grandfather (G) and a grandmother (H), married. \
Generation 2: their son S, and S's wife W. \
Generation 3: three children of S and W — one boy B and two girls C and D. \
That is $2 + 2 + 3 = 7$ people. Now check every role. \
- grandfather: G. Count 1. #sym.checkmark
- grandmother: H. Count 1. #sym.checkmark
- fathers: G (father of S) and S (father of B, C, D). Count 2. #sym.checkmark
- mothers: H and W. Count 2. #sym.checkmark
- children (people who are somebody's child at the table): S, B, C, D. Count 4. #sym.checkmark (W's parents are not present, so W is not counted.)
- grandchildren: B, C, D. Count 3. #sym.checkmark
- brother: B is the brother of C and D. S is an only child, so he is nobody's brother. Count 1. #sym.checkmark
- sisters: C and D. Count 2. #sym.checkmark
- sons: S and B. Count 2. #sym.checkmark
- daughters: C and D. Count 2. #sym.checkmark (W is not anybody's daughter at this table.)
- father-in-law: G, to W. Count 1. #sym.checkmark
- mother-in-law: H, to W. Count 1. #sym.checkmark
- daughter-in-law: W. Count 1. #sym.checkmark

Every role matches exactly. And 7 cannot be beaten: the list needs 3 distinct grandchildren, plus at least one parent of them, plus that parent's spouse, plus a grandfather and a grandmother, which is already $3 + 2 + 2 = 7$.
]
#ans[7 people]
]

#ex(34, tier: 3, asked: "Uber · pattern")[
Two riders leave the same junction at the same moment. Rider A goes due North at 30 km/h. Rider B goes due East at 40 km/h. \
(a) After how long are they exactly 25 km apart? \
(b) At that moment, in which direction is B from A?
#sol[
*Insight: two perpendicular constant velocities separate at a constant speed, namely the resultant. So the gap grows linearly and you never need to solve a quadratic.* \
*(a)* Separation speed $= sqrt(30^2 + 40^2) = sqrt(900 + 1600) = sqrt(2500) = 50$ km/h. \
Time $= 25/50 = 0.5$ h $= 30$ minutes. \
Check directly: in $0.5$ h, A covers $30 times 0.5 = 15$ km North; B covers $40 times 0.5 = 20$ km East. \
Gap $= sqrt(15^2 + 20^2) = sqrt(225 + 400) = sqrt(625) = 25$ km. #sym.checkmark \
*(b)* With East as $+x$ and North as $+y$: A is at $(0, 15)$, B is at $(20, 0)$. \
From A to B the change is $x: 0 -> 20$ (East) and $y: 15 -> 0$ (South). \
Both changes are 20 and 15, both non-zero, so B lies South and East of A.
]
#ans[(a) 30 minutes  (b) B is South-East of A]
]

#ex(35, tier: 3, asked: "Google · pattern")[
Forty students sit in a single row. Every student is given a different score. Call a student a *peak* if their score is higher than the score of every student sitting next to them (a student at either end has only one neighbour). What is the largest possible number of peaks?
#sol[
*Insight: two peaks can never sit next to each other, so the peaks form a set of seats with no two adjacent. That upper bound is the whole problem.* \
*Step 1 — the bound.* Suppose seats $i$ and $i+1$ were both peaks. Then the student at $i$ must score higher than the student at $i+1$, and the student at $i+1$ must score higher than the student at $i$. That is impossible. So no two peaks are adjacent. \
In a row of 40 seats, the largest set of seats with no two adjacent has size 20 — pair the seats as $(1,2), (3,4), ..., (39,40)$; that is 20 pairs and each pair can contribute at most one peak. \
So the number of peaks is at most 20. \
*Step 2 — reach the bound.* Give the 20 odd seats $1, 3, 5, ..., 39$ the twenty highest scores (21 to 40) and give the 20 even seats the twenty lowest scores (1 to 20). \
Every odd seat then holds a score of at least 21, and each of its neighbours (even seats) holds a score of at most 20. \
So every one of the 20 odd seats is a peak. \
The bound 20 is reached, so the maximum is exactly 20.
]
#ans[20 peaks]
]

#practice(tier: 3, time: "4 min/Q")[
+ A robot starts at the origin facing East. On move $k$ it drives forward $k$ metres and then turns $90degree$ to its left. After 200 moves, how far is it from the origin, in which direction, and which way is it facing?
+ Twenty-five students sit in a row, all with different scores. Call a student a *valley* if their score is lower than every neighbour's score (an end student has one neighbour). What is the largest possible number of valleys?
+ In a class of 30 with no tied scores, exactly 8 students scored above Mei and exactly 14 scored below Nat. How many students rank strictly between Nat and Mei?
+ Aarti and Bilal start from the same point at the same time. Aarti cycles due North at 5 km/h and Bilal cycles due East at 12 km/h. After how many minutes are they exactly 39 km apart?
+ At a family lunch the guests included 1 grandfather, 1 grandmother, 2 fathers, 2 mothers, 3 children, 2 grandchildren, 1 brother, 1 sister, 2 sons, 1 daughter, 1 father-in-law, 1 mother-in-law and 1 daughter-in-law. What is the smallest number of people who could have been there?
+ Eight runners finish a race with no ties. Exactly 3 finish before Hari. Exactly 2 runners finish between Hari and Ikram. Jia finishes immediately after Ikram, and Jia is not 2nd. In what position did Jia finish?
+ Seven people P, Q, R, S, T, U, V stand in a row of seven places. Exactly two people stand between P and Q, with Q to the right of P. R stands exactly three places to the right of Q. In how many different ways can the seven of them stand?
]

#key[
1. *$100 sqrt(2) approx 141.4$ m South-West of the origin, facing East.* Headings cycle E, N, W, S. In moves 1 to 4 the $x$ change is $+1 - 3 = -2$ and the $y$ change is $+2 - 4 = -2$, and every later block of 4 repeats this. With $200 div 4 = 50$ blocks the position is $(-100, -100)$, and 200 is a multiple of 4 so the heading returns to East.
2. *13 valleys.* If seats $i$ and $i+1$ were both valleys, each score would have to be lower than the other, which is impossible; so no two valleys are adjacent and at most 13 of the 25 seats qualify (seats $1, 3, ..., 25$). Giving the 13 odd seats the 13 lowest scores and the 12 even seats the 12 highest makes all 13 valleys real.
3. *6 students.* Mei's rank from the top $= 8 + 1 = 9$. Nat's rank from the bottom $= 14 + 1 = 15$, so Nat's rank from the top $= 30 - 15 + 1 = 16$. Between $= 16 - 9 - 1 = 6$.
4. *180 minutes.* The velocities are perpendicular, so the gap grows at $sqrt(5^2 + 12^2) = 13$ km/h. Time $= 39/13 = 3$ h $= 180$ min.
5. *6 people.* Grandfather, grandmother, their son, his wife, and the son's two children (one boy, one girl). Fathers: grandfather and son. Mothers: grandmother and wife. Children at the table: son, boy, girl — that is 3. Daughter: only the granddaughter, since the wife's parents are absent. Every role in the list is matched exactly.
6. *8th (last).* 3 finish before Hari, so Hari is 4th. Two runners between Hari and Ikram puts Ikram at $4 + 3 = 7$ or $4 - 3 = 1$. If Ikram were 1st then Jia would be 2nd, which is ruled out. So Ikram is 7th and Jia is 8th.
7. *24 ways.* Two people between P and Q gives $Q = P + 3$; R is three places right of Q gives $R = Q + 3 = P + 6$. With 7 places, $P >= 1$ and $R <= 7$ force $P = 1$, $Q = 4$, $R = 7$. The remaining four people fill places 2, 3, 5, 6 in $4! = 24$ ways.
]

#section[Mixed set — exam conditions]

#practice(tier: 1, time: "25 questions in 30 min — here, 20 in 24 min")[
+ Pointing to a photograph, Sunita said, "She is the mother of my son's only sister." How is the woman in the photograph related to Sunita?
+ In a row of 36 students, Hema is 14th from the left and Ismail is 9th from the right. How many students sit between them?
+ Vikram faces West. He turns $90degree$ clockwise, then $180degree$, then $90degree$ anticlockwise. Which direction does he face?
+ A man walks 4 km North, 3 km East, 8 km South and 3 km West. How far is he from the start, and in which direction?
+ 'A @ B' means A is the father of B. 'A © B' means A is the sister of B. What does 'P @ Q © R' tell you about P and R?
+ In a class, Rani is 12th from the top. Three times as many students rank below her as above her. How many students are in the class?
+ Just after sunrise, Hiro walks towards the sun for 2 km, turns right and walks 3 km, then turns right and walks 2 km. How far is he from the start, and in which direction?
+ Q is the son of P. R is the sister of Q. S is the mother of R. T is the father of S. How is T related to Q?
+ In a queue of 45 people, Ganesh is 19th from the front. Two people standing ahead of him leave the queue. What is his new position from the back?
+ A car travels 15 km South, then 20 km West, then 15 km North. How far is it from the start, and in which direction?
+ Introducing a boy, Ahmed said, "He is the only son of the only brother of my mother." How is the boy related to Ahmed?
+ A rank list has 60 names. Lin is 22nd from the top and Mala is 34th from the bottom. How many names lie between them?
+ A drone flies 9 km East, then 40 km North. What is its straight-line distance from the launch point?
+ Six runners finish with no ties. Exactly 2 finish before Nina and exactly 2 finish after Ravi. How many runners finish between Nina and Ravi?
+ A boy walks 10 m North, turns left and walks 10 m, turns left and walks 10 m, then turns right and walks 10 m. How far is he from the start, and in which direction?
+ 'P − Q' means P is the mother of Q. 'P ÷ Q' means P is the father of Q. 'P × Q' means P is the brother of Q. Which expression shows that A is the paternal grandfather of D? #opts([A ÷ B ÷ D], [A ÷ B − D], [A − B ÷ D], [A × B ÷ D])
+ In a merit list, Sara is 15th from the top and Tariq is 15th from the bottom. Exactly 4 students rank between them, and Sara ranks above Tariq. How many students are on the list?
+ One evening, just before sunset, Nok stood facing a tower whose shadow fell exactly behind her. Which direction was Nok facing?
+ A man is 8th from the left and 12th from the right in a row. Three more people then join at the right end. What is his new position from the right?
+ Rahul is the brother of Priya. Sonal is the mother of Rahul. Tarun is the son of Priya. Umesh is the husband of Sonal. How is Tarun related to Umesh?
]

#key[
1. *She is Sunita herself.* Sunita's son's only sister is Sunita's daughter, and that daughter's mother is Sunita.
2. *13 students.* Ismail from the left $= 36 - 9 + 1 = 28$; between $= 28 - 14 - 1 = 13$.
3. *East.* West $= 270degree$; $270 + 90 = 360 -> 0degree$; $0 + 180 = 180degree$; $180 - 90 = 90degree =$ East.
4. *4 km, due South.* Vertical $= 4 - 8 = -4$; horizontal $= 3 - 3 = 0$.
5. *P is the father of R.* Q is R's sister, so they share a father, and that father is P.
6. *45 students.* Above her $= 11$; below her $= 3 times 11 = 33$; total $= 11 + 1 + 33 = 45$.
7. *3 km, due South.* East 2, then South 3, then West 2: the two 2s cancel.
8. *Maternal grandfather.* S mothers R, and Q is R's brother, so S is Q's mother; T is S's father.
9. *27th from the back.* New total $= 43$; his position from the front $= 19 - 2 = 17$; $43 - 17 + 1 = 27$.
10. *20 km, due West.* South 15 and North 15 cancel.
11. *Cousin.* His mother's only brother is Ahmed's maternal uncle; that uncle's son is Ahmed's cousin.
12. *4 names.* Mala from the top $= 60 - 34 + 1 = 27$; between $= 27 - 22 - 1 = 4$.
13. *41 km.* $sqrt(9^2 + 40^2) = sqrt(81 + 1600) = sqrt(1681) = 41$.
14. *None — they finish next to each other.* Nina is 3rd; Ravi is $6 - 2 = 4$th; $4 - 3 - 1 = 0$.
15. *20 m, due West.* North 10, West 10, South 10, West 10: vertical cancels, horizontal $= 20$ W.
16. *(a) A ÷ B ÷ D.* Father of the father is the paternal grandfather. In (b) B is D's mother, which gives a maternal grandfather; in (c) A is female; in (d) A is an uncle.
17. *34 students.* Tariq from the top $= 15 + 4 + 1 = 20$; total $= 20 + 15 - 1 = 34$.
18. *West.* Before sunset shadows point East; the shadow was behind her, so East was behind her and she faced West.
19. *15th from the right.* Original total $= 8 + 12 - 1 = 19$; new total $= 22$; his place from the left is still 8, so $22 - 8 + 1 = 15$.
20. *Grandson.* Umesh and Sonal are the parents of Rahul and Priya; Tarun is Priya's son.
]

#revision[

*Blood relations*
- Draw the tree. Same generation on the same line, children hanging below.
- Peel a long sentence from the innermost phrase outward: grandfather $->$ his only son $=$ father $->$ his daughter $=$ sister.
- Resolve coded relations one symbol at a time and write each fact down before reading the next symbol.
- Key words: paternal $=$ father's side, maternal $=$ mother's side; nephew/niece $=$ sibling's child; cousin $=$ uncle's or aunt's child.

*Directions*
- Clockwise: N, NE, E, SE, S, SW, W, NW.
- Facing N: left $=$ W, right $=$ E. Facing E: left $=$ N, right $=$ S. Facing S: left $=$ E, right $=$ W. Facing W: left $=$ S, right $=$ N.
- Bearings: N $= 0degree$ and count clockwise. Clockwise turns add, anticlockwise turns subtract, then reduce modulo $360degree$.
- $"displacement" = sqrt(h^2 + v^2)$, with $h =$ East minus West and $v =$ North minus South.
- Triples to recognise on sight: $(3,4,5)$, $(5,12,13)$, $(6,8,10)$, $(8,15,17)$, $(7,24,25)$, $(9,40,41)$, $(20,21,29)$.
- $|h| = |v|$ gives $h sqrt(2)$ and a corner direction.
- Sunrise $->$ shadows point West. Sunset $->$ shadows point East. Noon gives no direction.

*Ranking*
- $"Total" = "left rank" + "right rank" - 1$.
- $"right rank" = "Total" - "left rank" + 1$.
- Both ranks from the same end first, then $"between" = "larger" - "smaller" - 1$.
- "$x$ people between" means the positions differ by $x + 1$.
- $k$ people above you $->$ your rank from the top is $k + 1$.

*Shortcuts*
- Collapse a multi-leg walk into two running totals, not a drawing.
- Sum all turns as one bearing instead of stepping around the compass.
- A "turn the same way every step" walk repeats its heading every 4 steps; simulate 4 and multiply.
- Perpendicular velocities separate at the resultant speed, so the gap is linear in time.
- For a maximum count of peaks or valleys in a row, use "no two can be adjacent", then build the alternating example.

*Top 5 traps*
+ Subtracting two ranks that are counted from *opposite* ends. Convert to one end first.
+ Reading "$x$ people between" as a gap of $x$. The gap is $x + 1$.
+ Forgetting that "the only daughter of my mother" is usually the *speaker*.
+ Turning $p%$ of a class into a rank. If $p%$ scored above you, your rank is that count *plus one*.
+ Flipping left and right. A person *facing you* has their left on your right — but a shadow or a compass direction never flips.
]

]
