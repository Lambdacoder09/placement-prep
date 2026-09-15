#import "../lib/style.typ": *

#chapter(num: 14, title: "Coding–Decoding & Cryptarithmetic", tagline: "Letters hide numbers. Digits hide letters.")[

#section[What you need to know]

#formulas[
*The alphabet, both ways*

#table(columns: 14,
[Letter],[A],[B],[C],[D],[E],[F],[G],[H],[I],[J],[K],[L],[M],
[From left],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],
[From right],[26],[25],[24],[23],[22],[21],[20],[19],[18],[17],[16],[15],[14],
)
#table(columns: 14,
[Letter],[N],[O],[P],[Q],[R],[S],[T],[U],[V],[W],[X],[Y],[Z],
[From left],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25],[26],
[From right],[13],[12],[11],[10],[9],[8],[7],[6],[5],[4],[3],[2],[1],
)

- Memory hook *EJOTY*: E $= 5$, J $= 10$, O $= 15$, T $= 20$, Y $= 25$. Count a step or two from the nearest of these.
- *Position from the right* $= 27 - ("position from the left")$.
- *Opposite letter* (A↔Z, B↔Y, C↔X, …): position $27 - n$. So M↔N, and that is the only pair in the middle.
- *Shift with wrap*: new position $= ((p + k - 1) mod 26) + 1$. After Z comes A again.

*The six coding types you will meet*

#table(columns: 2,
[*1. Letter shift*], [Every letter moves the same number of steps. CAT → DBU is $+1$.],
[*2. Word pattern*], [The whole word is rearranged: reversed, halves swapped, letters paired.],
[*3. Number coding*], [A word becomes a number: sum of positions, positions listed, digit sums, position $times$ rank.],
[*4. Symbol / operator coding*], [Symbols are swapped for $+ - times div$. Translate, then apply BODMAS.],
[*5. Substitution (message) coding*], [Whole words get code words. Match sentences and take the common code for the common word.],
[*6. Conditional coding*], [A base table plus 2–3 "if …" rules that override it for the first or last item.],
)

*Cryptarithmetic --- the rules of the game*

- Each letter stands for exactly one digit, 0–9. Different letters, different digits (unless the question says otherwise).
- A *leading digit is never 0*.
- When you add two numbers, the carry out of any column is *0 or 1*. For three numbers it is 0, 1 or 2.
- Start at the *units column*. It is the only column with no carry coming in.

*Reversal identities --- memorise these, they solve half the puzzles*

$ overline(A B) + overline(B A) = 11(A + B) $
$ overline(A B) - overline(B A) = 9(A - B) $
$ overline(A B A) + overline(B A B) = 111(A + B) $
$ overline(A B C) + overline(C B A) = 101(A + C) + 20 B $
$ overline(A A) = 11 A, quad overline(A A A) = 111 A, quad overline(A A A A) = 1111 A $

- Useful factorisations: $111 = 3 times 37$, #h(4pt) $1111 = 11 times 101$, #h(4pt) $11111 = 41 times 271$.
- Units-digit facts: a number $times 4$ or $times 6$ is always even, so any digit it produces in the units place is even.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
If CAT is written as DBU, how is DOG written?
#sol[
C → D, A → B, T → U. Each letter moves 1 step forward. \
D → E, O → P, G → H.
]
#ans[EPH]
]

#ex(2, tier: 0)[
What is the position of R from the left, and which letter is the opposite of R?
#sol[
From EJOTY, O $= 15$, so P $= 16$, Q $= 17$, R $= 18$. \
Opposite letter position $= 27 - 18 = 9$. Letter 9 is I.
]
#ans[18; opposite is I]
]

#ex(3, tier: 0)[
If A $= 1$, B $= 2$, …, Z $= 26$, find the value of CAB.
#sol[
C $= 3$, A $= 1$, B $= 2$. \
$3 + 1 + 2 = 6$.
]
#ans[6]
]

#ex(4, tier: 0)[
Code SUN by moving each letter 2 steps back.
#sol[
S $= 19$; $19 - 2 = 17$ → Q. \
U $= 21$; $21 - 2 = 19$ → S. \
N $= 14$; $14 - 2 = 12$ → L.
]
#ans[QSL]
]

#ex(5, tier: 0)[
In a code the word is simply written backwards. Code LAMP.
#sol[
LAMP read from the end: P, M, A, L.
]
#ans[PMAL]
]

#ex(6, tier: 0)[
If FIVE is coded 6-9-22-5, code NINE.
#sol[
The rule is "replace each letter by its position". \
N $= 14$, I $= 9$, N $= 14$, E $= 5$.
]
#ans[14-9-14-5]
]

#ex(7, tier: 0)[
In an addition puzzle the units column reads $B + B$ and the answer shows 4 with a carry of 1. Find B.
#sol[
The column result is $14$, since the written digit is 4 and 1 is carried. \
$B + B = 14$, so $2B = 14$ and $B = 7$. \
Check: $7 + 7 = 14$ ✓ --- write 4, carry 1.
]
#ans[$B = 7$]
]

#ex(8, tier: 0)[
Code CAB by replacing each letter with its opposite letter.
#sol[
C $= 3$; $27 - 3 = 24$ → X. \
A $= 1$; $27 - 1 = 26$ → Z. \
B $= 2$; $27 - 2 = 25$ → Y.
]
#ans[XZY]
]

#section[Tier 1 --- Service companies]
#tier-header(1)

#ex(9, tier: 1, asked: "TCS NQT pattern")[
In a code TIGER is written as UJHFS. How is LION written?
#sol[
Compare letter by letter. \
T $= 20$ → U $= 21$: $+1$ \
I $= 9$ → J $= 10$: $+1$ \
G $= 7$ → H $= 8$: $+1$ \
E $= 5$ → F $= 6$: $+1$ \
R $= 18$ → S $= 19$: $+1$ \
The shift is $+1$ for all. Apply it to LION: \
L $= 12 → 13$ = M #h(8pt) I $= 9 → 10$ = J #h(8pt) O $= 15 → 16$ = P #h(8pt) N $= 14 → 15$ = O
]
#ans[MJPO]
]

#trick[
Never check all the letters. Check *one* letter to guess the shift, then check *one more* to confirm it. Two checks are enough, and they take four seconds.
]

#ex(10, tier: 1, asked: "Infosys pattern")[
If MOUSE is coded OQWUG, code PLANT.
#sol[
M $= 13$ → O $= 15$: $+2$. Confirm with E $= 5$ → G $= 7$: $+2$ ✓ \
Apply $+2$ to PLANT: \
P $= 16 → 18$ = R \
L $= 12 → 14$ = N \
A $= 1 → 3$ = C \
N $= 14 → 16$ = P \
T $= 20 → 22$ = V
]
#ans[RNCPV]
]

#ex(11, tier: 1, asked: "Wipro pattern")[
If BAT is coded YZG, how is CAP coded?
#sol[
B $= 2$ → Y $= 25$. Note $2 + 25 = 27$. \
A $= 1$ → Z $= 26$. And $1 + 26 = 27$ ✓ \
T $= 20$ → G $= 7$. And $20 + 7 = 27$ ✓ \
So the rule is the opposite letter: new position $= 27 - n$. \
C $= 3$: $27 - 3 = 24$ → X \
A $= 1$: $27 - 1 = 26$ → Z \
P $= 16$: $27 - 16 = 11$ → K
]
#ans[XZK]
]

#trap[
A shift and an opposite-letter code can look alike for a word full of early letters. Always test a letter from the *second half* of the alphabet (here T → G). A shift moves it a little; an opposite code throws it across.
]

#ex(12, tier: 1, asked: "Accenture pattern")[
In a code RAIN $= 42$. Using the same rule, what is SUN?
#sol[
Check the sum-of-positions rule for RAIN: \
R $= 18$, A $= 1$, I $= 9$, N $= 14$. \
$18 + 1 = 19$; #h(4pt) $19 + 9 = 28$; #h(4pt) $28 + 14 = 42$ ✓ \
Now SUN: S $= 19$, U $= 21$, N $= 14$. \
$19 + 21 = 40$; #h(4pt) $40 + 14 = 54$.
]
#ans[54]
]

#ex(13, tier: 1, asked: "Capgemini pattern")[
In a code DELHI is written as JIMFE. How is MUMBAI written?
#sol[
The code has the same length, so look at the *last* code letter first. \
Code letter E $= 5$; the first word letter is D $= 4$. That is $+1$. \
Code letter J $= 10$; the last word letter is I $= 9$. That is $+1$. \
So the rule is: shift every letter $+1$, then write the word backwards. \
Check fully: D→E, E→F, L→M, H→I, I→J gives EFMIJ; reversed it is JIMFE ✓

Now MUMBAI. \
Step 1 --- shift $+1$: \
M $= 13 → 14$ = N \
U $= 21 → 22$ = V \
M $= 13 → 14$ = N \
B $= 2 → 3$ = C \
A $= 1 → 2$ = B \
I $= 9 → 10$ = J \
That gives NVNCBJ. \
Step 2 --- reverse it: J, B, C, N, V, N.
]
#ans[JBCNVN]
]

#ex(14, tier: 1, asked: "TCS NQT pattern")[
In a certain language:
- "pit na so" means "you are good"
- "na re ma" means "they are smart"
- "so ma de" means "good smart boy"

What is the code for "smart"?
#sol[
Find which sentences share the word "smart": the 2nd and the 3rd. \
Codes in sentence 2: pit? no --- they are na, re, ma. \
Codes in sentence 3: so, ma, de. \
The only code appearing in both lists is *ma*. So "smart" $=$ ma.

Cross-check the rest: \
"are" is in sentences 1 and 2. Sentence 1 codes: pit, na, so. Sentence 2 codes: na, re, ma. Common: na. So "are" $=$ na. \
"good" is in sentences 1 and 3. Common code of {pit, na, so} and {so, ma, de} is so. So "good" $=$ so. \
Everything is consistent.
]
#ans[ma]
]

#trick[
For substitution puzzles, do not try to decode the whole language. Circle the *one word* the question asks about, find the *two sentences* that contain it, and take the code common to both. Thirty seconds, done.
]

#ex(15, tier: 1, asked: "Cognizant pattern")[
In a code $2 = $ C, $3 = $ F, $4 = $ I. What does 6 stand for?
#sol[
C is letter 3, F is letter 6, I is letter 9. \
So the number 2 gives position 3, 3 gives 6, 4 gives 9. \
Positions go 3, 6, 9 --- they rise by 3 as the number rises by 1. \
Rule: position $= 3 times ("number" - 1)$. \
Check: number 4 → $3 times 3 = 9$ ✓ (I). \
Number 6 → $3 times (6 - 1) = 3 times 5 = 15$. Letter 15 is O.
]
#ans[O]
]

#ex(16, tier: 1, asked: "TCS NQT pattern")[
If FLOWER is coded 6-12-15-23-5-18, decode 7-1-18-4-5-14.
#sol[
Check the rule: F $= 6$, L $= 12$, O $= 15$, W $= 23$, E $= 5$, R $= 18$ ✓ --- plain positions. \
Now read the numbers back as letters: \
$7$ → G #h(8pt) $1$ → A #h(8pt) $18$ → R #h(8pt) $4$ → D #h(8pt) $5$ → E #h(8pt) $14$ → N
]
#ans[GARDEN]
]

#ex(17, tier: 1, asked: "Accenture pattern")[
If CHAIR is coded FKDLU, code TABLE.
#sol[
C $= 3$ → F $= 6$: $+3$. Confirm with R $= 18$ → U $= 21$: $+3$ ✓ \
T $= 20 → 23$ = W \
A $= 1 → 4$ = D \
B $= 2 → 5$ = E \
L $= 12 → 15$ = O \
E $= 5 → 8$ = H
]
#ans[WDEOH]
]

#ex(18, tier: 1, asked: "Wipro pattern")[
In a code CAT is written DCW. Using the same rule, code BIRD.
#sol[
C $= 3$ → D $= 4$: moved $+1$. \
A $= 1$ → C $= 3$: moved $+2$. \
T $= 20$ → W $= 23$: moved $+3$. \
So each letter moves forward by *its own place in the word*: 1st letter $+1$, 2nd $+2$, 3rd $+3$, and so on.

BIRD: \
B $= 2$, place 1: $2 + 1 = 3$ → C \
I $= 9$, place 2: $9 + 2 = 11$ → K \
R $= 18$, place 3: $18 + 3 = 21$ → U \
D $= 4$, place 4: $4 + 4 = 8$ → H
]
#ans[CKUH]
]

#trap[
Wrap-around kills marks. If a shift pushes you past 26, subtract 26 --- do not stop at Z. Example: X $= 24$ with $+4$ gives $28 - 26 = 2$ → B, not "off the end".
]

#ex(19, tier: 1, asked: "Infosys pattern")[
If the sign $+$ means $times$, $-$ means $div$, $times$ means $-$, and $div$ means $+$, find the value of
$ 16 - 4 div 2 + 3 times 5 $
#sol[
Replace every sign by what it really means:
- $16 - 4$ becomes $16 div 4$
- $div 2$ becomes $+ 2$
- $+ 3$ becomes $times 3$
- $times 5$ becomes $- 5$

The real expression is
$ 16 div 4 + 2 times 3 - 5 $
Now BODMAS. Division and multiplication first: \
$16 div 4 = 4$ #h(8pt) and #h(8pt) $2 times 3 = 6$ \
The expression becomes $4 + 6 - 5$. \
$4 + 6 = 10$; #h(4pt) $10 - 5 = 5$.
]
#ans[5]
]

#ex(20, tier: 1, asked: "TCS NQT pattern")[
$overline(A B)$ is a two-digit number and $overline(B A)$ is the same digits reversed. If $overline(A B) + overline(B A) = 99$, find $A + B$.
#sol[
Write the numbers out in full. \
$overline(A B) = 10 A + B$ #h(8pt) and #h(8pt) $overline(B A) = 10 B + A$ \
Add them:
$ (10A + B) + (10B + A) = 11A + 11B = 11(A + B) $
So $11(A + B) = 99$, giving $A + B = 99 div 11 = 9$. \
Check with one example: $A = 5$, $B = 4$ gives $54 + 45 = 99$ ✓
]
#ans[9]
]

#practice(tier: 1, time: "60 s/Q")[
+ If FROG is coded GSPH, code BIRD.
+ If LAMP is coded MBNQ, decode TVO.
+ Code MOON using the opposite-letter rule (A↔Z, B↔Y, …).
+ If A $=1$, B $=2$, …, find the value of CODE.
+ If SKY is coded PHV, code SUN.
+ "kal bat ro" means "she is nice"; "bat ti la" means "is he there". What is the code for "is"?
+ If $5 = $ E, $10 = $ J, $15 = $ O, what does 20 stand for?
+ If the sign $+$ means $-$, $-$ means $times$, $times$ means $div$, and $div$ means $+$, find $18 times 3 + 6 - 2 div 4$.
+ In a code the word is first written backwards, then every letter is moved 1 step forward (so TEAM → NBFU). Code PLAY.
+ If $overline(A B) + overline(B A) = 143$, find $A + B$.
+ If RED is coded IVW, code BLUE.
+ In a code each letter moves forward by its place in the word (1st letter $+1$, 2nd $+2$, …). Code DEAL.
+ If MONDAY $= 72$ under the sum-of-positions rule, what is FRIDAY?
+ Decode 8-15-14-5-25.
+ In the addition $overline(A 8) + overline(3 B) = 105$, find $A$ and $B$.
]

#key[
+ *CJSE* --- the shift is $+1$ (F→G, R→S); B→C, I→J, R→S, D→E.
+ *SUN* --- the code shift is $+1$, so decoding is $-1$: T→S, V→U, O→N.
+ *NLLM* --- $27 - 13 = 14$ (N), $27 - 15 = 12$ (L), L again, $27 - 14 = 13$ (M).
+ *27* --- $3 + 15 + 4 + 5 = 27$.
+ *PRK* --- S $=19$→P $=16$ is $-3$; S→P, U $=21$→$18$ = R, N $=14$→$11$ = K.
+ *bat* --- "is" is the only word in both sentences; "bat" is the only code in both.
+ *T* --- the rule is simply the alphabet position; letter 20 is T.
+ *$-2$* --- the real sum is $18 div 3 - 6 times 2 + 4 = 6 - 12 + 4 = -2$.
+ *ZBMQ* --- reverse PLAY to get YALP, then $+1$: Y→Z, A→B, L→M, P→Q.
+ *13* --- $11(A+B) = 143$, so $A + B = 143 div 11 = 13$.
+ *YOFV* --- opposite letters: $27-2 = 25$ (Y), $27-12 = 15$ (O), $27-21 = 6$ (F), $27-5 = 22$ (V).
+ *EGDP* --- D$+1 =$ E, E$+2 =$ G, A$+3 =$ D, L$+4 =$ P.
+ *63* --- $6 + 18 + 9 + 4 + 1 + 25 = 63$.
+ *HONEY* --- letters 8, 15, 14, 5, 25.
+ *$A = 6$, $B = 7$* --- units: $8 + B$ must end in 5, so $B = 7$ (carry 1); tens: $A + 3 + 1 = 10$, so $A = 6$. Check $68 + 37 = 105$ ✓.
]

#section[Tier 2 --- Singapore & Thailand]
#tier-header(2)

#ex(21, tier: 2, asked: "Grab · pattern")[
A code moves every *vowel* 2 steps forward and every *consonant* 1 step back. Code MANGO.
#sol[
Split the word: vowels are A and O; consonants are M, N, G.

M $= 13$, consonant: $13 - 1 = 12$ → L \
A $= 1$, vowel: $1 + 2 = 3$ → C \
N $= 14$, consonant: $14 - 1 = 13$ → M \
G $= 7$, consonant: $7 - 1 = 6$ → F \
O $= 15$, vowel: $15 + 2 = 17$ → Q
]
#ans[LCMFQ]
]

#ex(22, tier: 2, asked: "Shopee · pattern")[
In a seller's private language:
- "ho ra mi" means "fast cheap delivery"
- "mi lo ka" means "delivery is late"
- "ra se lo" means "cheap and is"

Find the codes for "cheap" and for "delivery".
#sol[
*"cheap"* appears in sentences 1 and 3. \
Sentence 1 codes: {ho, ra, mi}. Sentence 3 codes: {ra, se, lo}. \
Codes in both lists: ra. So "cheap" $=$ ra.

*"delivery"* appears in sentences 1 and 2. \
Sentence 1 codes: {ho, ra, mi}. Sentence 2 codes: {mi, lo, ka}. \
Codes in both lists: mi. So "delivery" $=$ mi.

Cross-check with a third word. "is" appears in sentences 2 and 3. \
{mi, lo, ka} and {ra, se, lo} share lo. So "is" $=$ lo. \
Now sentence 1 has ho left over for "fast", sentence 2 has ka left for "late", sentence 3 has se left for "and". Nothing clashes, so the answers are safe.
]
#ans[cheap $=$ ra, delivery $=$ mi]
]

#ex(23, tier: 2, asked: "DBS · pattern")[
In a code, each letter is first replaced by its alphabet position, and then that number is replaced by the sum of its digits. So FARE becomes 6195. Code TRIP.
#sol[
First confirm the rule on FARE. \
F $= 6$ → single digit already → 6 \
A $= 1$ → 1 \
R $= 18$ → $1 + 8 = 9$ \
E $= 5$ → 5 \
Written together: 6, 1, 9, 5 → 6195 ✓

Now TRIP. \
T $= 20$ → $2 + 0 = 2$ \
R $= 18$ → $1 + 8 = 9$ \
I $= 9$ → 9 \
P $= 16$ → $1 + 6 = 7$ \
Written together: 2, 9, 9, 7.
]
#ans[2997]
]

#trap[
"Digit sum" means add the digits *once*, not until you reach a single digit, unless the question says so. Here T $= 20$ gives 2 in one step; do not keep going and turn 9 into 9, or 18 into 9 into 9. Follow the worked example the question gives you.
]

#ex(24, tier: 2, asked: "Agoda · pattern")[
A booking system codes words by these rules:
- If the word begins with a *consonant*: move every letter 2 steps forward.
- If the word begins with a *vowel*: write the word backwards first, then move every letter 1 step back.

Code ORANGE and PLANE.
#sol[
*ORANGE* begins with O, a vowel. Use rule 2. \
Step 1 --- write it backwards: E, G, N, A, R, O → EGNARO \
Step 2 --- move each letter 1 step back: \
E $= 5 → 4$ = D \
G $= 7 → 6$ = F \
N $= 14 → 13$ = M \
A $= 1 → 0$? Position 0 does not exist, so wrap: $1 - 1 + 26 = 26$ → Z \
R $= 18 → 17$ = Q \
O $= 15 → 14$ = N \
Result: DFMZQN

*PLANE* begins with P, a consonant. Use rule 1: move every letter 2 forward. \
P $= 16 → 18$ = R \
L $= 12 → 14$ = N \
A $= 1 → 3$ = C \
N $= 14 → 16$ = P \
E $= 5 → 7$ = G \
Result: RNCPG
]
#ans[ORANGE → DFMZQN, PLANE → RNCPG]
]

#ex(25, tier: 2, asked: "GIC · pattern")[
In the addition below, $A$, $B$, $C$ are digits and $overline(A B C)$ is a three-digit number.
$ overline(A B C) + overline(A B C) + overline(A B C) = overline(C C C) $
Find $A$, $B$ and $C$.
#sol[
*Write both sides as numbers.* \
Left side $= 3 times overline(A B C)$. \
Right side $= overline(C C C) = 111 times C$. \
So
$ 3 times overline(A B C) = 111 C arrow.r.double overline(A B C) = (111 C)/3 = 37 C $

*Now use the units digit.* The units digit of $overline(A B C)$ is $C$. The units digit of $37 C$ is the units digit of $7C$. So
$ 7C "and" C "must end in the same digit" arrow.r.double 7C - C = 6C "ends in" 0 $
$6C$ ends in 0 only when $C = 0$ or $C = 5$.
- $C = 0$ gives $overline(A B C) = 0$, not a three-digit number. Reject.
- $C = 5$ gives $overline(A B C) = 37 times 5 = 185$.

So $A = 1$, $B = 8$, $C = 5$. \
Check: $185 + 185 + 185 = 555$ ✓ and $555 = overline(C C C)$ with $C = 5$ ✓
]
#ans[$A = 1$, $B = 8$, $C = 5$]
]

#trick[
Repeated-digit numbers factor beautifully: $overline(C C) = 11C$, $overline(C C C) = 111C = 3 times 37 times C$, $overline(C C C C) = 1111C = 11 times 101 times C$. The moment you see one in a puzzle, replace it and the algebra collapses to one line.
]

#ex(26, tier: 2, asked: "SCB · pattern")[
$A$, $B$, $C$ are digits with $A != 0$ and $C != 0$. Given
$ overline(A B C) + overline(C B A) = 1049 $
find $B$, and count how many ordered pairs $(A, C)$ are possible.
#sol[
*Expand both numbers.* \
$overline(A B C) = 100A + 10B + C$ \
$overline(C B A) = 100C + 10B + A$ \
Add:
$ 101A + 20B + 101C = 101(A + C) + 20B = 1049 $

*Find $A+C$.* $A + C$ is a whole number at most 18, and $101(A+C) <= 1049$ gives $A + C <= 10.3$, so $A + C <= 10$. \
Try the largest values:
- $A + C = 10$: $1010 + 20B = 1049 arrow.r.double 20B = 39$. Not a whole number. Reject.
- $A + C = 9$: $909 + 20B = 1049 arrow.r.double 20B = 140 arrow.r.double B = 7$ ✓
- $A + C = 8$: $808 + 20B = 1049 arrow.r.double 20B = 241$. Reject.

Only $A + C = 9$ works, and then $B = 7$.

*Count the pairs.* Both $A$ and $C$ lead a three-digit number, so both are from 1 to 9. \
$(A, C) = (1,8), (2,7), (3,6), (4,5), (5,4), (6,3), (7,2), (8,1)$. \
$(9, 0)$ and $(0, 9)$ are not allowed because a leading digit cannot be 0. \
That is 8 ordered pairs.
]
#ans[$B = 7$; 8 ordered pairs]
]

#ex(27, tier: 2, asked: "LINE MAN · pattern")[
In a code, P means $+$, Q means $-$, R means $times$ and S means $div$. Find the value of
$ 36 " S " 6 " R " 5 " Q " 12 " P " 8 $
#sol[
Translate every letter:
$ 36 div 6 times 5 - 12 + 8 $
BODMAS: do $div$ and $times$ from left to right first. \
$36 div 6 = 6$ \
$6 times 5 = 30$ \
Now the expression is $30 - 12 + 8$. \
$30 - 12 = 18$; #h(4pt) $18 + 8 = 26$.
]
#ans[26]
]

#trap[
After translating, work *left to right* among $times$ and $div$. Doing $6 times 5$ before $36 div 6$ gives $36 div 30$, which is wrong. Same for $+$ and $-$: $30 - 12 + 8$ is 26, not $30 - 20 = 10$.
]

#ex(28, tier: 2, asked: "Razer · pattern")[
In a code, each letter is replaced by (its alphabet position) $times$ (its place in the word).  \
(a) Code GAME. #h(6pt) (b) Decode 2-18-33-20.
#sol[
*(a) GAME.* \
G $= 7$, place 1: $7 times 1 = 7$ \
A $= 1$, place 2: $1 times 2 = 2$ \
M $= 13$, place 3: $13 times 3 = 39$ \
E $= 5$, place 4: $5 times 4 = 20$ \
Code: 7-2-39-20

*(b) Decode 2-18-33-20.* To undo the rule, divide each number by its place. \
Place 1: $2 div 1 = 2$ → B \
Place 2: $18 div 2 = 9$ → I \
Place 3: $33 div 3 = 11$ → K \
Place 4: $20 div 4 = 5$ → E
]
#ans[(a) 7-2-39-20 #h(6pt) (b) BIKE]
]

#ex(29, tier: 2, asked: "Shopee · pattern")[
Digits are coded by this table:

#table(columns: 11,
[Digit],[1],[2],[3],[4],[5],[6],[7],[8],[9],[0],
[Code],[\$],[?],[\#],[\@],[!],[%],[\&],[\*],[=],[:],
)

Two extra rules override the table:
- (i) If the first digit is odd and the last digit is even, swap the codes of the first and last digits.
- (ii) If the first and last digits are both odd, code both of them as ©.

Code the numbers 58347 and 39482.
#sol[
*58347.* First digit 5 (odd), last digit 7 (odd). Both odd → rule (ii) applies. \
Plain codes: $5 →$ !, $8 →$ \*, $3 →$ \#, $4 →$ \@, $7 →$ \& \
Rule (ii) replaces the first and last codes with ©. \
Answer: © \* \# \@ ©

*39482.* First digit 3 (odd), last digit 2 (even). Rule (i) applies. \
Plain codes: $3 →$ \#, $9 →$ =, $4 →$ \@, $8 →$ \*, $2 →$ ? \
Swap the first and last codes: the \# and the ? change places. \
Answer: ? = \@ \* \#
]
#ans[58347 → © \* \# \@ © #h(6pt) 39482 → ? = \@ \* \#]
]

#ex(30, tier: 2, asked: "Grab · pattern")[
$overline(A B)$ is a two-digit number with $A > B$. When it is multiplied by 3 the answer is a three-digit number whose three digits are all the same, $overline(C C C)$. Find $overline(A B)$.
#sol[
*Set up.* $3 times overline(A B) = overline(C C C) = 111 C$. \
So
$ overline(A B) = (111 C)/3 = 37 C $

*$overline(A B)$ must have two digits*, so $10 <= 37C <= 99$.
$ 37 times 1 = 37 quad (2 "digits, ok") $
$ 37 times 2 = 74 quad (2 "digits, ok") $
$ 37 times 3 = 111 quad (3 "digits, too big") $
So $C = 1$ giving 37, or $C = 2$ giving 74.

*Use the condition $A > B$.*
- 37: $A = 3$, $B = 7$, so $A < B$. Reject.
- 74: $A = 7$, $B = 4$, so $A > B$ ✓

Check: $74 times 3 = 222$, and $222$ is $overline(C C C)$ with $C = 2$ ✓
]
#ans[$overline(A B) = 74$ (and $C = 2$)]
]

#practice(tier: 2, time: "100 s/Q")[
+ A code moves every vowel 1 step forward and every consonant 3 steps forward. Code TIGER.
+ "ma tu li" means "buy fresh fish"; "li po ka" means "fish and rice"; "tu ka ne" means "fresh rice today". What is the code for "rice"?
+ Using the "position, then digit sum" rule of Example 23, code MONK.
+ If $overline(A B C) + overline(C B A) = 1191$, find $B$.
+ If P means $div$, Q means $times$, R means $+$ and S means $-$, find the value of $48 " P " 8 " Q " 5 " R " 9 " S " 14$.
+ A code works like this: if the word starts with a consonant, write it backwards and then move each letter 1 step forward; if it starts with a vowel, just move each letter 2 steps forward. Code TABLE and EAGLE.
+ Using "position $times$ place in the word", code DUST.
+ Using the same rule, decode 3-16-27-64.
+ A two-digit number $overline(A B)$ with $A < B$ is multiplied by 6 and gives $overline(C C C)$. Find $overline(A B)$.
+ Using the digit table and the two rules of Example 29, plus a third rule --- (iii) if the first and last digits are both even, code both as § --- code the number 47296.
+ In a code every letter is replaced by its opposite letter (A↔Z, …) and then the whole word is written backwards. Code LAMP.
+ $overline(A A) + overline(B B) = 132$, where $A$ and $B$ are different non-zero digits. How many ordered pairs $(A, B)$ are possible?
]

#key[
+ *WJJFU* --- T$+3 =$ W, I (vowel) $+1 =$ J, G$+3 =$ J, E (vowel) $+1 =$ F, R$+3 =$ U.
+ *ka* --- "rice" is in sentences 2 and 3; the code common to {li, po, ka} and {tu, ka, ne} is ka.
+ *4652* --- M $=13 → 4$, O $=15 → 6$, N $=14 → 5$, K $=11 → 2$.
+ *$B = 4$* --- $101(A+C) + 20B = 1191$; $A + C = 11$ gives $1111 + 20B = 1191$, so $20B = 80$ and $B = 4$.
+ *25* --- the real sum is $48 div 8 times 5 + 9 - 14 = 6 times 5 + 9 - 14 = 30 + 9 - 14 = 25$.
+ *FMCBU and GCING* --- TABLE starts with a consonant: reverse to ELBAT, then $+1$ → FMCBU. EAGLE starts with a vowel: $+2$ → GCING.
+ *4-42-57-80* --- $4 times 1 = 4$, $21 times 2 = 42$, $19 times 3 = 57$, $20 times 4 = 80$.
+ *CHIP* --- $3 div 1 = 3$ (C), $16 div 2 = 8$ (H), $27 div 3 = 9$ (I), $64 div 4 = 16$ (P).
+ *37* --- $6 times overline(A B) = 111C$, so $overline(A B) = 18.5 C$; two-digit whole answers need $C = 2$ (37) or $C = 4$ (74). Only 37 has $A < B$. Check $37 times 6 = 222$ ✓.
+ *§ \& ? = §* --- 4 and 6 are both even, so rule (iii) fires. Plain codes were \@ \& ? = %; the first and last become §.
+ *KNZO* --- opposites give O, Z, N, K; reversed that is K, N, Z, O.
+ *6* --- $11A + 11B = 132$ so $A + B = 12$; the ordered pairs of different non-zero digits are $(3,9), (4,8), (5,7), (7,5), (8,4), (9,3)$. $(6,6)$ is barred because the digits must differ.
]

#section[Tier 3 --- Product companies]
#tier-header(3)

#ex(31, tier: 3, asked: "Google · pattern")[
Find the smallest six-digit number $overline(A B C D E F)$ such that
$ overline(A B C D E F) times 3 = overline(B C D E F A) $
That is, multiplying by 3 moves the first digit to the end.
#sol[
*Insight: do not think about six unknown digits. Name the leading digit $A$ and call everything after it a single block $X$. Moving a digit from front to back is just arithmetic on $A$ and $X$.*

Let $X = overline(B C D E F)$, the last five digits (it may start with 0). Then
$ overline(A B C D E F) = 100000 A + X $
$ overline(B C D E F A) = 10 X + A $
The condition says
$ 3(100000A + X) = 10X + A $
$ 300000A + 3X = 10X + A $
$ 300000A - A = 10X - 3X $
$ 299999 A = 7 X $
$ X = (299999 A)/7 $
Divide: $299999 div 7 = 42857$ exactly ($7 times 42857 = 299999$). So
$ X = 42857 A $

*Now bound $A$.* $X$ has at most five digits, so $X <= 99999$:
$ 42857 A <= 99999 arrow.r.double A <= 2.33 $
And $A >= 1$ (leading digit). So $A = 1$ or $A = 2$.

- $A = 1$: $X = 42857$, number $= 142857$.
#h(12pt) Check: $142857 times 3 = 428571$ ✓ (and 428571 is 42857 followed by 1 ✓)
- $A = 2$: $X = 85714$, number $= 285714$.
#h(12pt) Check: $285714 times 3 = 857142$ ✓

Both work. The smaller is 142857.
]
#ans[142857]
]

#trick[
Whenever a puzzle says "move the first digit to the end" or "move the last digit to the front", write the number as $10^k A + X$ or $10 X + d$. One equation replaces a whole page of digit-by-digit carrying.
]

#ex(32, tier: 3, asked: "Amazon · pattern")[
A four-letter word is called *self-coded* if replacing each letter by its opposite letter (A↔Z, B↔Y, …) gives exactly the word written backwards. Letters may repeat and the "word" need not be a real English word. How many self-coded four-letter words are there?
#sol[
*Insight: the condition links letter 1 with letter 4 and letter 2 with letter 3. Once you pick the first half, the second half is forced. So count the free choices.*

Write the word as $w_1 w_2 w_3 w_4$. Let $"opp"(w)$ be the opposite letter. \
The coded word is $"opp"(w_1) "opp"(w_2) "opp"(w_3) "opp"(w_4)$. \
The reversed word is $w_4 w_3 w_2 w_1$. \
Setting them equal, position by position:
$ "opp"(w_1) = w_4, quad "opp"(w_2) = w_3, quad "opp"(w_3) = w_2, quad "opp"(w_4) = w_1 $
The third condition is the same as the second (opp applied twice returns the original letter, since $27 - (27 - n) = n$). The fourth is the same as the first. \
So only two real conditions remain:
$ w_4 = "opp"(w_1) quad "and" quad w_3 = "opp"(w_2) $

*Count.* $w_1$ is free: 26 choices. $w_2$ is free: 26 choices. Then $w_3$ and $w_4$ are fixed.
$ 26 times 26 = 676 $
Example check: take $w_1 = $ C, $w_2 = $ B. Then $w_3 = "opp"(B) = $ Y and $w_4 = "opp"(C) = $ X, giving CBYX. \
Code it: C→X, B→Y, Y→B, X→C gives XYBC. Reverse CBYX: X, Y, B, C ✓ They match.
]
#ans[676]
]

#ex(33, tier: 3, asked: "Goldman Sachs · pattern")[
$A$, $B$, $C$ are three *different* non-zero digits and
$ overline(A B) + overline(B C) + overline(C A) = 209 $
How many different sets $\{A, B, C\}$ satisfy this?
#sol[
*Insight: the three numbers use each letter once in the tens place and once in the units place. That symmetry collapses the sum to a multiple of 11.*

Expand: \
$overline(A B) = 10A + B$ \
$overline(B C) = 10B + C$ \
$overline(C A) = 10C + A$ \
Add:
$ (10A + A) + (10B + B) + (10C + C) = 11A + 11B + 11C = 11(A + B + C) $
So
$ 11(A + B + C) = 209 arrow.r.double A + B + C = 209/11 = 19 $

*Now count.* We need sets of three different digits from 1 to 9 adding to 19. \
Organise by the largest digit.
- Largest $= 9$: the other two are different, below 9, adding to $19 - 9 = 10$: $(2,8), (3,7), (4,6)$. ($(5,5)$ repeats, $(1,9)$ reuses 9.) → 3 sets
- Largest $= 8$: other two below 8, adding to $19 - 8 = 11$: $(4,7), (5,6)$. ($(3,8)$ reuses 8.) → 2 sets
- Largest $= 7$: other two below 7, adding to $19 - 7 = 12$: the biggest possible is $5 + 6 = 11 < 12$. → 0 sets
- Largest $= 6$ or less: the biggest total is $4 + 5 + 6 = 15 < 19$. → 0 sets

The sets are $\{2,8,9\}$, $\{3,7,9\}$, $\{4,6,9\}$, $\{4,7,8\}$, $\{5,6,8\}$.
]
#ans[5 sets]
]

#ex(34, tier: 3, asked: "Microsoft · pattern")[
A coding rule replaces every letter by another letter, using a fixed one-to-one table (no two letters share a code). How many different code words can the word LEVEL produce?
#sol[
*Insight: the code depends only on the distinct letters. Repeated letters must always map to the same code letter, so they cost nothing extra.*

LEVEL uses which distinct letters? \
L (places 1 and 5), E (places 2 and 4), V (place 3). That is *3 distinct letters*.

The table is one-to-one, so the codes of L, E and V must be three *different* letters.
- Choose the code for L: 26 ways.
- Choose the code for E: it must differ from L's code: 25 ways.
- Choose the code for V: it must differ from both: 24 ways.

$ 26 times 25 times 24 $
$26 times 25 = 650$ \
$650 times 24 = 15600$

Note the shape of the code word is always $x y z y x$, so no two of these 15600 choices give the same code word --- every count is distinct.
]
#ans[15600]
]

#trap[
Under a one-to-one substitution the *pattern of repeats never changes*. LEVEL must code to something of the shape $x y z y x$. If an option shows five different letters, it is impossible, no matter how clever it looks.
]

#ex(35, tier: 3, asked: "D. E. Shaw · pattern")[
$A$ and $B$ are different non-zero digits and $C$ is a digit. In the addition
$ overline(A B A) + overline(B A B) = overline(C C C) $
how many ordered pairs $(A, B)$ are possible?
#sol[
*Insight: the palindrome shape makes both numbers a multiple of 101 and 10. Expand once and the whole puzzle becomes "$A + B$ is a single digit".*

$overline(A B A) = 100A + 10B + A = 101A + 10B$ \
$overline(B A B) = 100B + 10A + B = 101B + 10A$ \
Add:
$ 111A + 111B = 111(A + B) $
And $overline(C C C) = 111 C$. So
$ 111(A + B) = 111 C arrow.r.double A + B = C $

*Conditions.*
- $C$ is a single digit, so $A + B <= 9$.
- $A >= 1$ and $B >= 1$ (both lead a three-digit number, and the question says non-zero).
- $A != B$.
- $C != 0$ is automatic, since $A + B >= 1 + 2 = 3$.

*Count ordered pairs $(A, B)$ with $A, B >= 1$, $A != B$, $A + B <= 9$.* \
First count all ordered pairs with $A, B >= 1$ and $A + B = s$: there are $s - 1$ of them.
$s = 2$ gives 1 pair; #h(3pt) $s = 3$ gives 2; #h(3pt) $s = 4$ gives 3; #h(3pt) $s = 5$ gives 4. \
$s = 6$ gives 5; #h(3pt) $s = 7$ gives 6; #h(3pt) $s = 8$ gives 7; #h(3pt) $s = 9$ gives 8.
Total $= 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 = 36$.

Now remove the pairs with $A = B$: these are $(1,1), (2,2), (3,3), (4,4)$ --- only these four keep $A + B <= 9$. ($(5,5)$ gives 10, too big.)
$ 36 - 4 = 32 $
Spot check: $(1,2)$ gives $121 + 212 = 333$ ✓ with $C = 3$. $(6,3)$ gives $636 + 363 = 999$ ✓ with $C = 9$.
]
#ans[32 ordered pairs]
]

#ex(36, tier: 3, asked: "Adobe · pattern")[
Code $X$ moves every letter $k$ steps forward (with wrap-around). Code $Y$ replaces every letter by its opposite letter.  \
(a) With $k = 7$, is "$Y$ then $X$" ever the same as "$X$ then $Y$" for any letter?  \
(b) For which $k$ do the two orders agree for *every* letter?
#sol[
*Insight: write both codes as formulas on the position number, then compose them. Two codes agree exactly when their formulas agree modulo 26.*

Let a letter have position $p$. Work modulo 26 throughout (position 27 means 1, and so on). \
$X: p arrow.r p + k$ \
$Y: p arrow.r 27 - p$, and $27 equiv 1 space (mod 26)$, so $Y: p arrow.r 1 - p$.

*"$Y$ then $X$":* first $p arrow.r 1 - p$, then add $k$:
$ p arrow.r (1 - p) + k = 1 + k - p $

*"$X$ then $Y$":* first $p arrow.r p + k$, then apply $Y$:
$ p arrow.r 1 - (p + k) = 1 - k - p $

*(a) Put $k = 7$.* \
"$Y$ then $X$" gives $8 - p$. #h(6pt) "$X$ then $Y$" gives $-6 - p equiv 20 - p space (mod 26)$. \
These are equal only if $8 equiv 20 space (mod 26)$, i.e. $20 - 8 = 12$ is a multiple of 26. It is not. \
So the two orders *never* agree, for any letter.

*(b) General $k$.* Set the two formulas equal:
$ 1 + k - p equiv 1 - k - p space (mod 26) $
$ k equiv -k space (mod 26) $
$ 2k equiv 0 space (mod 26) $
$ k equiv 0 space (mod 13) $
Within one full turn ($0 <= k <= 25$) this gives $k = 0$ (no shift at all) or $k = 13$. \
So the only real answer is $k = 13$.

Check with $k = 13$ on the letter C ($p = 3$): \
"$Y$ then $X$": C → X ($27-3 = 24$), then $24 + 13 = 37$, $37 - 26 = 11$ → K. \
"$X$ then $Y$": C → $3 + 13 = 16$ → P, then $27 - 16 = 11$ → K ✓ Same.
]
#ans[(a) never #h(6pt) (b) $k = 13$]
]

#ex(37, tier: 3, asked: "Uber · pattern")[
A dispatch system codes each digit $d$ of a trip ID as $c = (3d + 7) mod 10$.  \
(a) Show the code can always be undone, and write the decoding rule.  \
(b) Would the rule $c = (4d + 3) mod 10$ also work? 
#sol[
*Insight: a rule $c = (m d + b) mod 10$ is reversible exactly when $m$ has an inverse modulo 10, which happens only when $m$ shares no factor with 10.*

*(a)* We need a number $m'$ with $3 m' equiv 1 space (mod 10)$. \
Try: $3 times 1 = 3$, $3 times 2 = 6$, $3 times 3 = 9$, $3 times 7 = 21 equiv 1$ ✓ \
So $m' = 7$. Now undo the rule:
$ c equiv 3d + 7 space (mod 10) $
$ c - 7 equiv 3d $
$ 7(c - 7) equiv 21 d equiv d space (mod 10) $
$ d equiv 7c - 49 equiv 7c + 1 space (mod 10) quad ("since" -49 + 50 = 1) $
*Decoding rule:* $d = (7c + 1) mod 10$.

Test it on every kind of digit: \
$d = 0 arrow.r c = 7$; decode $7(7) + 1 = 50 arrow.r 0$ ✓ \
$d = 4 arrow.r c = 19 mod 10 = 9$; decode $7(9) + 1 = 64 arrow.r 4$ ✓ \
$d = 9 arrow.r c = 34 mod 10 = 4$; decode $7(4) + 1 = 29 arrow.r 9$ ✓

*(b)* With $m = 4$, look at two different digits $d$ and $d + 5$:
$ 4(d + 5) + 3 = 4d + 20 + 3 equiv 4d + 3 space (mod 10) $
So $d$ and $d + 5$ always get the *same* code. For example $d = 1$ gives 7, and $d = 6$ gives $27 mod 10 = 7$ too. \
Two different digits sharing one code means the message cannot be decoded. The rule fails. \
The reason: 4 and 10 share the factor 2, so 4 has no inverse modulo 10.
]
#ans[(a) $d = (7c + 1) mod 10$ #h(6pt) (b) No --- $d$ and $d+5$ collide]
]

#ex(38, tier: 3, asked: "Goldman Sachs · pattern")[
Find the five-digit number $overline(A B C D E)$ such that
$ overline(A B C D E) times 4 = overline(E D C B A) $
#sol[
*Insight: squeeze the unknowns with size and parity before touching algebra. Multiplying by 4 must keep the answer at five digits, and the answer must be even --- those two facts alone pin down $A$ and $E$.*

*Step 1 --- find $A$.* The product still has five digits, so
$ overline(A B C D E) times 4 <= 99999 arrow.r.double overline(A B C D E) <= 24999 arrow.r.double A = 1 "or" 2 $
The product $overline(E D C B A)$ is $4 times ("something")$, so it is even. Its units digit is $A$, so $A$ is even. \
Therefore $A = 2$.

*Step 2 --- find $E$.* The first digit of the product is $E$. Since $overline(A B C D E) >= 20000$,
$ overline(E D C B A) >= 4 times 20000 = 80000 arrow.r.double E = 8 "or" 9 $
Size alone leaves both 8 and 9. So use the units column of the multiplication instead: $4 times E$ must end in $A = 2$. \
$4 times 8 = 32$ ends in 2 ✓ #h(8pt) $4 times 9 = 36$ ends in 6 ✗ \
So $E = 8$.

*Step 3 --- algebra for $B$, $C$, $D$.* The number is $2 B C D 8$ and the product is $8 D C B 2$.
$ overline(A B C D E) = 20000 + 1000B + 100C + 10D + 8 $
$ 4 times "that" = 80000 + 4000B + 400C + 40D + 32 $
$ overline(E D C B A) = 80000 + 1000D + 100C + 10B + 2 $
Set them equal and cancel the 80000:
$ 4000B + 400C + 40D + 32 = 1000D + 100C + 10B + 2 $
$ 4000B - 10B + 400C - 100C + 40D - 1000D + 32 - 2 = 0 $
$ 3990B + 300C - 960D + 30 = 0 $
Divide every term by 30:
$ 133B + 10C - 32D + 1 = 0 quad arrow.r.double quad 32D = 133B + 10C + 1 $

*Step 4 --- test $B$.* Since the number is at most 24999 and starts with 2, $B <= 4$. Also $D <= 9$, so $32D <= 288$.
- $B = 0$: $32D = 10C + 1$, which is odd. But $32D$ is even. Impossible.
- $B = 1$: $32D = 133 + 10C + 1 = 134 + 10C$. Since $10C >= 0$, we need $32D >= 134$, so $D >= 134 div 32 = 4.2$, i.e. $D >= 5$. Try each: $32 times 5 = 160 arrow.r 10C = 26$ ✗; $32 times 6 = 192 arrow.r 10C = 58$ ✗; $32 times 7 = 224 arrow.r 10C = 90 arrow.r C = 9$ ✓; $32 times 8 = 256 arrow.r 10C = 122$ ✗; $32 times 9 = 288 arrow.r 10C = 154$ ✗.
#h(12pt) So $B = 1$, $C = 9$, $D = 7$.
- $B = 2$: $32D = 266 + 10C + 1 = 267 + 10C$, which is odd. Impossible.
- $B = 3$: $32D = 399 + 10C + 1 = 400 + 10C >= 400 > 288$. Impossible.
- $B = 4$: even larger. Impossible.

*The number is 21978.* \
Check: $21978 times 4$. #h(4pt) $20000 times 4 = 80000$; #h(4pt) $1978 times 4 = 7912$; #h(4pt) $80000 + 7912 = 87912$. \
And 21978 written backwards is 87912 ✓
]
#ans[21978]
]

#practice(tier: 3, time: "4 min/Q")[
+ In Example 31 two six-digit numbers worked. Find the larger one.
+ Under a one-to-one letter substitution, how many different code words can SUCCESS produce?
+ In $overline(A B A) + overline(B A B) = overline(C C C)$ with $A$, $B$ different non-zero digits, how many ordered pairs $(A, B)$ give $C = 9$?
+ A code shifts every letter $k$ steps forward, $1 <= k <= 25$. For which $k$ does applying the code *twice* return every word to its original form?
+ A digit is coded as $c = (7d + 4) mod 10$. Write the decoding rule.
+ Find the four-digit number $overline(A B C D)$ with $overline(A B C D) times 9 = overline(D C B A)$.
+ A five-letter word is *self-coded* if replacing each letter by its opposite letter gives the word written backwards. How many such five-letter words are there?
+ $A$, $B$, $C$ are different non-zero digits with $overline(A B) + overline(B C) + overline(C A) = 176$. How many sets $\{A, B, C\}$ are possible?
]

#key[
+ *285714* --- from $X = 42857A$, the case $A = 2$ gives $X = 85714$ and the number 285714. Check: $285714 times 3 = 857142$, which is 85714 followed by 2 ✓.
+ *358800* --- SUCCESS uses the distinct letters S, U, C, E --- four of them. A one-to-one table gives $26 times 25 times 24 times 23 = 358800$. The repeated S's and C's add no freedom.
+ *8* --- the identity gives $A + B = C = 9$. Ordered pairs of different non-zero digits summing to 9: $(1,8), (2,7), (3,6), (4,5), (5,4), (6,3), (7,2), (8,1)$.
+ *$k = 13$* --- two shifts of $k$ give a shift of $2k$, and that must be a whole number of turns: $2k equiv 0 space (mod 26)$, so $k$ is a multiple of 13. In the range 1 to 25 only $k = 13$ works (ROT13).
+ *$d = (3c + 8) mod 10$* --- the inverse of 7 modulo 10 is 3, since $7 times 3 = 21 equiv 1$. From $c equiv 7d + 4$ we get $d equiv 3(c - 4) = 3c - 12 equiv 3c + 8$. Test $d = 5$: $c = 39 mod 10 = 9$, and $3(9) + 8 = 35 arrow.r 5$ ✓.
+ *1089* --- $9 times overline(A B C D)$ is still four digits, so $overline(A B C D) <= 1111$ and $A = 1$. The product is then at least 9000, so $D = 9$. Expanding $9(1000 + 100B + 10C + 9) = 9000 + 100C + 10B + 1$ gives $89B = C - 8$, so $B = 0$ and $C = 8$. Check $1089 times 9 = 9801$ ✓.
+ *0* --- the condition forces $"opp"(w_3) = w_3$ for the middle letter, i.e. $27 - p = p$, so $p = 13.5$. No letter has that position, so no such word exists.
+ *8* --- $11(A+B+C) = 176$ gives $A + B + C = 16$. By largest digit: 9 with $(1,6), (2,5), (3,4)$; 8 with $(1,7), (2,6), (3,5)$; 7 with $(3,6), (4,5)$; nothing below. Total $3 + 3 + 2 = 8$.
]

#section[Mixed set --- exam conditions]

#practice(tier: 1, time: "30 minutes for all 20")[
+ If PEN is coded QFO, code BOOK.
+ Code FLY using the opposite-letter rule.
+ If A $=1$, B $=2$, …, find the value of TEAM.
+ "ho pa ni" means "big red car"; "pa ti lo" means "red fast bike". What is the code for "red"?
+ If \@ means $+$, \# means $-$, \$ means $times$ and \& means $div$, find $24 " \& " 6 " \$ " 5 " \@ " 8 " \# " 3$.
+ If $overline(A B) + overline(B A) = 154$, find $A + B$.
+ In a code every letter moves forward by its place in the word. Code DESK.
+ Decode 3-1-18-4.
+ If $overline(A B C) + overline(A B C) + overline(A B C) = overline(C C C)$, find $A + B + C$.
+ A code moves every vowel 3 steps forward and every consonant 1 step forward. Code CHAIR.
+ In a code the word is first written backwards, then every letter moves 2 steps forward. Code FROG.
+ A code shifts every letter $k$ steps forward, $1 <= k <= 25$. For how many values of $k$ does the coded form of ZOO contain the letter A?
+ If $overline(A B A) + overline(B A B) = 777$ with $A$, $B$ different non-zero digits, how many ordered pairs $(A, B)$ are there?
+ Each digit $d$ is coded as $(3d + 1) mod 10$. Code the number 482.
+ Find the four-digit number $overline(A B C D)$ with $overline(A B C D) times 4 = overline(D C B A)$.
+ Under a one-to-one letter substitution, how many code words can DIGIT produce?
+ If MANGO is coded NBOHP, decode TVHBS.
+ In the addition $overline(A 7) + overline(5 B) = 132$, find $A + B$.
+ Using "position $times$ place in the word", code FAN.
+ Which letter is 8th from the right end of the alphabet?
]

#key[
+ *CPPL* --- the shift is $+1$; B→C, O→P, O→P, K→L.
+ *UOB* --- $27-6 = 21$ (U), $27-12 = 15$ (O), $27-25 = 2$ (B).
+ *39* --- $20 + 5 + 1 + 13 = 39$.
+ *pa* --- "red" is the only shared word; "pa" is the only shared code.
+ *25* --- the real sum is $24 div 6 times 5 + 8 - 3 = 4 times 5 + 8 - 3 = 20 + 8 - 3 = 25$.
+ *14* --- $11(A + B) = 154$, so $A + B = 14$.
+ *EGVO* --- D$+1 =$ E, E$+2 =$ G, S$+3 =$ V, K$+4 =$ O.
+ *CARD* --- letters 3, 1, 18, 4.
+ *14* --- $3 times overline(A B C) = 111C$ gives $overline(A B C) = 37C$; the units digit forces $C = 5$, so the number is 185 and $1 + 8 + 5 = 14$.
+ *DIDLS* --- C$+1 =$ D, H$+1 =$ I, A (vowel) $+3 =$ D, I (vowel) $+3 =$ L, R$+1 =$ S.
+ *IQTH* --- reverse FROG to GORF, then $+2$: G→I, O→Q, R→T, F→H.
+ *2* --- A appears if some letter lands on position 1. Z $=26$ needs $k = 1$; O $=15$ needs $15 + k equiv 1 space (mod 26)$, i.e. $k = 12$. So $k in \{1, 12\}$.
+ *6* --- $111(A + B) = 777$ gives $A + B = 7$; ordered pairs of different non-zero digits: $(1,6), (2,5), (3,4), (4,3), (5,2), (6,1)$.
+ *357* --- $4 arrow.r 13 mod 10 = 3$; $8 arrow.r 25 mod 10 = 5$; $2 arrow.r 7$.
+ *2178* --- the product stays four digits, so $overline(A B C D) <= 2499$ and $A = 1$ or 2; the product is even and ends in $A$, so $A = 2$. Then the number is at least 2000, so the product is at least 8000 and $D >= 8$; $4D$ must end in 2, so $D = 8$. Expanding $4(2000 + 100B + 10C + 8) = 8000 + 100C + 10B + 2$ gives $2C = 13B + 1$, so $B = 1$ and $C = 7$. Check $2178 times 4 = 8712$ ✓.
+ *358800* --- DIGIT has four distinct letters D, I, G, T; $26 times 25 times 24 times 23 = 358800$.
+ *SUGAR* --- the code shift is $+1$, so decode with $-1$: T→S, V→U, H→G, B→A, S→R.
+ *12* --- units: $7 + B$ ends in 2, so $B = 5$ with carry 1; tens: $A + 5 + 1 = 13$, so $A = 7$. Check $77 + 55 = 132$ ✓. $A + B = 7 + 5 = 12$.
+ *6-2-42* --- $6 times 1 = 6$, $1 times 2 = 2$, $14 times 3 = 42$.
+ *S* --- $27 - 8 = 19$, and letter 19 is S.
]

#revision[
*Alphabet facts*

- EJOTY: E $=5$, J $=10$, O $=15$, T $=20$, Y $=25$. Count from the nearest one.
- Position from the right $= 27 - $ position from the left.
- Opposite letter position $= 27 - n$. Middle pair: M ↔ N.
- Shift with wrap: new position $= ((p + k - 1) mod 26) + 1$. Past 26? Subtract 26.
- Applying the same shift twice $=$ a shift of $2k$. A shift of 13 is its own undo (ROT13).

*The six coding types*

+ *Letter shift* --- test one letter, confirm with a second, then apply.
+ *Word pattern* --- reversed or paired. Match the code's *last* letter to the word's *first*.
+ *Number coding* --- sum of positions; positions listed; digit sums; position $times$ place.
+ *Symbol / operator* --- translate every sign, then BODMAS, then left to right.
+ *Substitution message* --- the code shared by the two sentences containing the asked word.
+ *Conditional* --- plain codes first, then the "if" rules --- first and last item only.

*Cryptarithmetic toolkit*

$ overline(A B) + overline(B A) = 11(A+B) quad quad overline(A B) - overline(B A) = 9(A - B) $
$ overline(A B A) + overline(B A B) = 111(A + B) quad quad overline(A B C) + overline(C B A) = 101(A + C) + 20B $
$ overline(A A) = 11A quad overline(A A A) = 111A = 3 dot 37 dot A quad overline(A A A A) = 1111A = 11 dot 101 dot A $

- Leading digit is never 0. Carry from any column of a two-number addition is 0 or 1.
- Start at the units column --- nothing is carried into it.
- "Move the first digit to the end": write the number as $10^k A + X$, the result as $10X + A$.
- "Move the last digit to the front": write the number as $10X + d$, the result as $10^k d + X$.
- $times 4, times 6, times 9$ puzzles: size limit first ($4N$ must still fit), parity second (product is even).
- $c = (m d + b) mod 10$ reverses only when $m$ is 1, 3, 7 or 9; undo by multiplying by its partner ($3 arrow.l.r 7$, $9 arrow.l.r 9$).

*Counting under a one-to-one substitution*

- Count only the *distinct* letters, say $r$ of them: $26 times 25 times dots.c$ ($r$ factors).
- The pattern of repeated letters can never change.

*Top 5 traps*

+ Testing the shift on early letters only. Always test a letter past M.
+ Forgetting wrap-around. Past Z go back to A; before A go back to Z.
+ In operator coding, breaking BODMAS or working right to left. $30 - 12 + 8 = 26$, never 10.
+ Conditional coding: the "if" rules usually look only at the *first and last* item. Do not apply them to the middle.
+ Cryptarithmetic: assuming letters must be different when the question never said so --- and assuming they may repeat when it did say so. Read that line twice.
]

]
