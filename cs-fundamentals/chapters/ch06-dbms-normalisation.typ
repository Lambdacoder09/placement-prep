#import "../../shared/lib/style.typ": *

#chapter(num: 6, title: "DBMS: Normalisation & Schema Design",
  tagline: "Functional dependencies, attribute closure, 1NF to BCNF — with every decomposition worked line by line and checked by a program.")[

Normalisation is the most *mechanical* topic in the whole technical round. There is an
algorithm for every question. Once you can compute an attribute closure on paper, you can
answer almost anything the interviewer asks: find the candidate keys, name the highest
normal form, decompose the table, prove the decomposition is lossless.

The catch is that students learn the *definitions* and never learn the *procedure*. Then
they freeze when the board says `R(A,B,C,D,E)` with four dependencies.

This chapter is the procedure. Every closure, every key list and every decomposition test
in these pages was computed by a program that is printed in full in section 6.16 — so the
numbers are checked, not remembered.

#note[
*How to read this chapter.* Every worked example carries a coloured tier badge — grey for
warm-up mechanics, teal for Tier 1 (TCS NQT, Accenture, Infosys, Wipro, Capgemini), amber
for Tier 2 (Grab, Shopee, GIC, DBS, Agoda, SCB) and dark red for Tier 3 (Google, Amazon,
Microsoft, Goldman Sachs, D. E. Shaw, Adobe). The practice sets at the end climb the same
four steps in order, so do them in order.
]

#formulas(title: "What you need to know")[
*Functional dependency.* $X -> Y$ means: any two rows that agree on $X$ must agree on $Y$.
Read it as "$X$ determines $Y$", or "$X$ is a *determinant* of $Y$".
- *Trivial* if $Y subset.eq X$ (e.g. $"AB" -> "A"$). Always true, tells you nothing.
- *Full* dependency: $X -> Y$ and no proper subset of $X$ determines $Y$.
- *Partial* dependency: $X$ is a *proper subset of a candidate key* and $X -> Y$ where $Y$
  is non-prime.
- *Transitive* dependency: $X -> Y$, $Y -> Z$, with $Y$ not a super key and $Z$ non-prime.

*Armstrong's axioms* (sound and complete):
- *Reflexivity*: if $Y subset.eq X$ then $X -> Y$.
- *Augmentation*: if $X -> Y$ then $X Z -> Y Z$.
- *Transitivity*: if $X -> Y$ and $Y -> Z$ then $X -> Z$.

*Derived rules* (all provable from the three above):
- *Union*: $X -> Y$, $X -> Z$ $=>$ $X -> Y Z$.
- *Decomposition*: $X -> Y Z$ $=>$ $X -> Y$ and $X -> Z$.
- *Pseudo-transitivity*: $X -> Y$, $W Y -> Z$ $=>$ $W X -> Z$.

*Attribute closure* $X^+$: everything $X$ determines. Start with $X$; repeatedly, if some
$A -> B$ has $A subset.eq X^+$, add $B$. Stop when nothing changes.
- $X$ is a *super key* $<=>$ $X^+$ = all attributes.
- $X -> Y$ holds $<=>$ $Y subset.eq X^+$.

*Prime attribute*: appears in at least one candidate key. Otherwise *non-prime*.

*The normal forms*
#table(columns: (auto, 1fr), inset: 4pt,
  [1NF], [Every value is atomic. No repeating groups, no lists in a cell.],
  [2NF], [1NF + no non-prime attribute is partially dependent on a candidate key.],
  [3NF], [2NF + for every non-trivial $X -> A$: $X$ is a super key *or* $A$ is prime.],
  [BCNF], [For every non-trivial $X -> A$: $X$ is a super key. No exception for prime $A$.],
  [4NF], [BCNF + no non-trivial multivalued dependency unless the left side is a super key.],
)

*Decomposition tests.* Splitting $R$ into $R_1$ and $R_2$ is *lossless* if
$ (R_1 inter R_2) -> R_1 quad "or" quad (R_1 inter R_2) -> R_2 $
that is, the shared attributes form a key of at least one fragment.
It is *dependency preserving* if the union of the FDs visible inside each fragment still
implies every original FD.

*The guarantee.* 3NF can always be reached losslessly *and* dependency-preservingly.
BCNF can always be reached losslessly, but *may lose a dependency*.
]

#section[6.1 Why normalise — the three anomalies]

Here is a table a beginner would design for a college. One row per student per course.

#diagram(height: 4.4cm, caption: "One wide table, three kinds of trouble. The tinted cells are the evidence.")[
  #dnode(0.3cm, 0.15cm, 2.2cm, 0.55cm, "roll", fill: rgb("#dbe6ee"))
  #dnode(2.5cm, 0.15cm, 2.6cm, 0.55cm, "sname", fill: rgb("#dbe6ee"))
  #dnode(5.1cm, 0.15cm, 2.2cm, 0.55cm, "hostel", fill: rgb("#dbe6ee"))
  #dnode(7.3cm, 0.15cm, 2.4cm, 0.55cm, "course_id", fill: rgb("#dbe6ee"))
  #dnode(9.7cm, 0.15cm, 3.4cm, 0.55cm, "course_name", fill: rgb("#dbe6ee"))
  #dnode(13.1cm, 0.15cm, 2.6cm, 0.55cm, "grade", fill: rgb("#dbe6ee"))

  #dnode(0.3cm, 0.7cm, 2.2cm, 0.55cm, "101", fill: white)
  #dnode(2.5cm, 0.7cm, 2.6cm, 0.55cm, "Asha", fill: white)
  #dnode(5.1cm, 0.7cm, 2.2cm, 0.55cm, "H1", fill: rgb("#fbe0dd"))
  #dnode(7.3cm, 0.7cm, 2.4cm, 0.55cm, "CS01", fill: white)
  #dnode(9.7cm, 0.7cm, 3.4cm, 0.55cm, "Databases", fill: white)
  #dnode(13.1cm, 0.7cm, 2.6cm, 0.55cm, "A", fill: white)

  #dnode(0.3cm, 1.25cm, 2.2cm, 0.55cm, "101", fill: white)
  #dnode(2.5cm, 1.25cm, 2.6cm, 0.55cm, "Asha", fill: white)
  #dnode(5.1cm, 1.25cm, 2.2cm, 0.55cm, "H1", fill: rgb("#fbe0dd"))
  #dnode(7.3cm, 1.25cm, 2.4cm, 0.55cm, "CS02", fill: white)
  #dnode(9.7cm, 1.25cm, 3.4cm, 0.55cm, "Operating Systems", fill: white)
  #dnode(13.1cm, 1.25cm, 2.6cm, 0.55cm, "B", fill: white)

  #dnode(0.3cm, 1.8cm, 2.2cm, 0.55cm, "102", fill: white)
  #dnode(2.5cm, 1.8cm, 2.6cm, 0.55cm, "Bhavin", fill: white)
  #dnode(5.1cm, 1.8cm, 2.2cm, 0.55cm, "H2", fill: white)
  #dnode(7.3cm, 1.8cm, 2.4cm, 0.55cm, "CS01", fill: white)
  #dnode(9.7cm, 1.8cm, 3.4cm, 0.55cm, "Databases", fill: white)
  #dnode(13.1cm, 1.8cm, 2.6cm, 0.55cm, "A", fill: white)

  #dnode(0.3cm, 2.35cm, 2.2cm, 0.55cm, "103", fill: white)
  #dnode(2.5cm, 2.35cm, 2.6cm, 0.55cm, "Chetan", fill: white)
  #dnode(5.1cm, 2.35cm, 2.2cm, 0.55cm, "H1", fill: white)
  #dnode(7.3cm, 2.35cm, 2.4cm, 0.55cm, "CS03", fill: rgb("#e2efdd"))
  #dnode(9.7cm, 2.35cm, 3.4cm, 0.55cm, "Networks", fill: rgb("#e2efdd"))
  #dnode(13.1cm, 2.35cm, 2.6cm, 0.55cm, "C", fill: white)

  #dnode(0.3cm, 3.2cm, 7.5cm, 0.7cm, "pink = the same fact stored twice", fill: rgb("#fbe0dd"))
  #dnode(8.2cm, 3.2cm, 7.5cm, 0.7cm, "green = a fact that only one row is holding up", fill: rgb("#e2efdd"))
  #darrow(11.9cm, 3.15cm, 11.4cm, 2.95cm)
]

*UPDATE anomaly.* Asha's hostel is stored twice (pink). Move her to H3 and you must edit
every one of her rows. Miss one and the database now says two different things at once.

*DELETE anomaly.* Chetan is the only student in CS03 (green). Delete his registration and
the fact that "CS03 is called Networks" is gone forever — you lost a course by deleting a
registration.

*INSERT anomaly.* A new course that nobody has registered for yet cannot be stored at all,
because `roll` is part of the primary key and a primary key column cannot be `NULL`.

Every anomaly has the same root cause: *the table stores facts about more than one thing.*
It mixes a fact about a student (`roll` $->$ `hostel`) with a fact about a course
(`course_id` $->$ `course_name`) with a fact about a registration
(`roll, course_id` $->$ `grade`).

Normalisation is one rule applied over and over:

#trick[
*Every table should describe exactly one kind of thing, and every non-key column should be
a fact about the whole key and nothing but the key.*

The old exam mnemonic for 3NF: "the key, the whole key, and nothing but the key."
- *the key* $=>$ 1NF (rows are identifiable)
- *the whole key* $=>$ 2NF (no partial dependency)
- *nothing but the key* $=>$ 3NF (no transitive dependency)
]

#section[6.2 Functional dependencies]

$X -> Y$ says: *if two rows have the same $X$, they must have the same $Y$.*

It does *not* say $Y$ is unique, and it does *not* say anything about $Y -> X$.

#subsection[Reading an FD out of a business rule]

This is the step students skip. Practise it.

#table(columns: (1fr, auto), inset: 5pt,
  [*Business rule*], [*FD*],
  [Every student has one hostel.], [`roll` $->$ `hostel`],
  [Every course has one name and one instructor.], [`course_id` $->$ `course_name, instructor`],
  [A student gets one grade in a course.], [`roll, course_id` $->$ `grade`],
  [A teacher teaches only one subject.], [`tutor` $->$ `subject`],
  [Two students may share a hostel.], [nothing — this is *not* an FD],
  [Each PIN code lies in exactly one city.], [`pin` $->$ `city`],
  [A city can have many PIN codes.], [`city` $arrow.r.not$ `pin`],
)

#trap[
"The data shows no repeats, so it is an FD." Wrong direction. Sample data can only
*disprove* an FD — find two rows that agree on $X$ and disagree on $Y$, and $X -> Y$ is
dead. It can never *prove* one. FDs come from the rules of the business, not from today's
rows. Say this sentence in the interview.
]

#subsection[Armstrong's axioms, proved once]

You will be asked to *derive* an FD. Use the three axioms.

#ex(1, tier: 1, asked: "Infosys · pattern")[
Given $A -> B$ and $B C -> D$, prove $A C -> D$.
]
#sol[
+ $A -> B$ — given.
+ $A C -> B C$ — *augmentation* of line 1 with $C$.
+ $B C -> D$ — given.
+ $A C -> D$ — *transitivity* of lines 2 and 3. ∎

That combination is used so often it has its own name: *pseudo-transitivity*.
#ans[augment, then apply transitivity]
]

#ex(2, tier: 1, asked: "TCS NQT · pattern")[
Is $A -> B C$ equivalent to the pair ${A -> B, A -> C}$? Is $A B -> C$ equivalent to
${A -> C, B -> C}$?
]
#sol[
*First pair — yes, equivalent.*
- Forward: $A -> B C$ gives $A -> B$ and $A -> C$ by *decomposition*.
- Backward: $A -> B$ and $A -> C$ give $A -> B C$ by *union*.

*Second pair — no.* Decomposition splits the *right* side only, never the left.
- ${A -> C, B -> C}$ does imply $A B -> C$ (augment $A -> C$ with $B$).
- But $A B -> C$ does *not* imply $A -> C$. Counter-example: a table where
  `(1, x) -> 5` and `(1, y) -> 9`. Here `AB` fixes `C`, but `A` alone does not.
#ans[right sides split; left sides do not]
]

#trap[
The single most common mistake in this topic: splitting the left-hand side.
$A B -> C$ *never* gives you $A -> C$.
]

#section[6.3 Attribute closure — the one algorithm you must own]

$X^+$ is the set of every attribute that $X$ determines.

#subsection[The procedure]

+ Start: $X^+ = X$.
+ Scan every FD. If its left side is fully inside $X^+$, add its right side to $X^+$.
+ Repeat the scan until one full pass adds nothing new.

#diagram(height: 3.4cm, caption: "Computing (CD)+ for the FD set A→BC, CD→E, B→D, E→A. Each arrow is one FD firing.")[
  #dnode(0.3cm, 0.75cm, 2.2cm, 1.0cm, [start \ {C, D}], fill: rgb("#eef3f7"))
  #dnode(3.5cm, 0.75cm, 2.2cm, 1.0cm, [{C, D, E}], fill: white)
  #dnode(6.7cm, 0.75cm, 2.2cm, 1.0cm, [{A, C, D, E}], fill: white)
  #dnode(9.9cm, 0.75cm, 2.2cm, 1.0cm, [{A, B, C, \ D, E}], fill: white)
  #dnode(13.1cm, 0.75cm, 2.6cm, 1.0cm, [nothing new \ STOP], fill: rgb("#dbe6ee"))
  #darrow(2.55cm, 1.25cm, 3.45cm, 1.25cm, label: "CD→E")
  #darrow(5.75cm, 1.25cm, 6.65cm, 1.25cm, label: "E→A")
  #darrow(8.95cm, 1.25cm, 9.85cm, 1.25cm, label: "A→BC")
  #darrow(12.15cm, 1.25cm, 13.05cm, 1.25cm, label: "B→D")
  #dnode(0.3cm, 2.2cm, 15.4cm, 0.65cm,
    [Result: (CD)+ = ABCDE. `F` never appears on the right of any FD, so nothing can ever add it.],
    fill: rgb("#f7f7f5"))
]

#ex(3, tier: 1, asked: "Wipro · pattern")[
$R(A,B,C,D,E,F)$ with $F = {A -> B C, " " C D -> E, " " B -> D, " " E -> A}$.
Compute $A^+$, $B^+$ and $(A F)^+$.
]
#sol[
*$A^+$:*
- Start ${A}$.
- $A -> B C$ fires (A is in). Now ${A, B, C}$.
- $B -> D$ fires. Now ${A, B, C, D}$.
- $C D -> E$ fires (both C and D are in). Now ${A, B, C, D, E}$.
- $E -> A$ fires but A is already there. Nothing new. Stop.

$A^+ = A B C D E$. Note $F$ is missing.

*$B^+$:*
- Start ${B}$.
- $B -> D$ fires. Now ${B, D}$.
- $A -> B C$? `A` is not in the set. ✗
- $C D -> E$? `C` is not in the set. ✗
- $E -> A$? `E` is not in the set. ✗
- Nothing new. Stop.

$B^+ = B D$.

*$(A F)^+$:*
- Start ${A, F}$. Everything that fired for $A^+$ fires again, and $F$ just rides along.
- $(A F)^+ = A B C D E F$ = all six attributes.

#ans[$A^+ = "ABCDE"$, $B^+ = "BD"$, $(A F)^+ = "ABCDEF"$ — so $A F$ is a super key and $A$ alone is not]
]

#trick[
Three shortcuts that save real time:
+ *Any attribute that never appears on the right of any FD must be in every candidate
  key.* Nothing can derive it, so it has to be given. In the example above, `F` is never
  on a right side $=>$ every candidate key contains `F`.
+ *Any attribute that never appears on the left of any FD is never needed in a key.*
+ Once $X^+$ reaches all attributes, *stop scanning*. You are done.
]

#section[6.4 Finding all candidate keys]

The exam-safe procedure:

+ Split the attributes into three buckets: *only-left* (L), *only-right* (R), *both* (B),
  plus *neither* (N).
+ Every attribute in L and in N *must* be in every candidate key. Call this seed $S$.
+ Compute $S^+$. If it is everything, $S$ is the *only* candidate key — stop.
+ Otherwise try $S$ plus one attribute from B, then $S$ plus two, and so on. Test the
  smallest sets first; once a set is a key, never test a superset of it.

#ex(4, tier: 2, asked: "Grab · pattern")[
Find every candidate key of $R(A,B,C,D,E,F)$ with
$F = {A -> B C, " " C D -> E, " " B -> D, " " E -> A}$.
]
#sol[
*Step 1 — bucket the attributes.*
#table(columns: (auto, auto, auto), inset: 5pt,
  [*Attribute*], [*Appears on the left of*], [*Appears on the right of*],
  [A], [$A -> B C$], [$E -> A$],
  [B], [$B -> D$], [$A -> B C$],
  [C], [$C D -> E$], [$A -> B C$],
  [D], [$C D -> E$], [$B -> D$],
  [E], [$E -> A$], [$C D -> E$],
  [F], [—], [—],
)
`F` is in bucket N (neither side) $=>$ *`F` is in every candidate key.* Seed $S = {F}$.

*Step 2 — is the seed enough?* $F^+ = F$. Not everything, so we must add attributes.

*Step 3 — try one extra attribute at a time.*
#table(columns: (auto, auto, auto), inset: 5pt,
  [*Try*], [*Closure*], [*Key?*],
  [`AF`], [$A^+ = "ABCDE"$, plus F $=>$ ABCDEF], [*yes*],
  [`BF`], [$B^+ = "BD"$, plus F $=>$ BDF], [no],
  [`CF`], [$C^+ = C$, plus F $=>$ CF], [no],
  [`DF`], [$D^+ = D$, plus F $=>$ DF], [no],
  [`EF`], [$E^+$: E→A, A→BC, B→D, so ABCDE; plus F], [*yes*],
)

*Step 4 — try two extra attributes, skipping any set containing `AF` or `EF`.*
So only combinations of B, C, D are left: `BCF`, `BDF`, `CDF`.
#table(columns: (auto, auto, auto), inset: 5pt,
  [*Try*], [*Closure*], [*Key?*],
  [`BCF`], [B→D gives BCD; CD→E gives E; E→A gives A $=>$ ABCDEF], [*yes*],
  [`BDF`], [B→D adds nothing new. Stuck at BDF], [no],
  [`CDF`], [CD→E gives E; E→A gives A; A→BC adds B $=>$ ABCDEF], [*yes*],
)

*Step 5 — three extra attributes?* Every remaining 3-subset of {B,C,D} is `BCD`, which
contains `BC`, so `BCDF` is a superset of the key `BCF` — not minimal. Done.

#ans[`AF`, `EF`, `BCF`, `CDF` — four candidate keys]

*Prime attributes* = the union of all four = ${A, B, C, D, E, F}$. *Every* attribute is
prime here. That fact decides the normal form in section 6.9 — keep it.
]

#note[
The program in section 6.16 was run on this exact relation. It printed
`keys = AF|EF|BCF|CDF` and `prime = ABCDEF`. The hand work above matches.
]

#section[6.5 First normal form]

*1NF: every value in every cell is atomic, and there are no repeating groups.*

Bad:
#table(columns: (auto, auto, auto), inset: 5pt,
  [*roll*], [*sname*], [*phones*],
  [101], [Asha], [`9000011111, 9000022222`],
  [102], [Bhavin], [`9000033333`],
)

Also bad (a repeating group spread across columns):
#table(columns: (auto, auto, auto, auto), inset: 5pt,
  [*roll*], [*sname*], [*phone1*], [*phone2*],
  [101], [Asha], [`9000011111`], [`9000022222`],
  [102], [Bhavin], [`9000033333`], [`NULL`],
)

Why the second one is still wrong: "how many phone columns is enough?" There is no answer.
And `SELECT ... WHERE phone = '9000022222'` now has to search every phone column.

Good — one fact per row:
#table(columns: (auto, auto), inset: 5pt,
  [*roll*], [*sname*],
  [101], [Asha],
  [102], [Bhavin],
)
#table(columns: (auto, auto), inset: 5pt,
  [*roll*], [*phone*],
  [101], [`9000011111`],
  [101], [`9000022222`],
  [102], [`9000033333`],
)
Primary key of the second table: `{roll, phone}`.

#trap[
"A `JSON` column or an array column breaks 1NF, so modern databases are not relational."
Careful. The honest answer: "Strictly, a multi-valued column violates 1NF. In practice
PostgreSQL arrays and `JSONB` are used deliberately when the inner values are never
queried or joined on individually — it is a conscious trade of purity for speed. The
moment you need to filter or join on an element, you should normalise it into rows."
That answer scores far higher than a flat yes or no.
]

#section[6.6 Second normal form]

*2NF: 1NF, and no non-prime attribute depends on only PART of a candidate key.*

This can only go wrong when the candidate key is *composite*. If every candidate key is a
single attribute, a partial dependency is impossible and 2NF is automatic.

#ex(5, tier: 1, asked: "Capgemini · pattern")[
`REG(roll, course_id, sname, hostel, course_name, instructor, grade)` with
`roll` $->$ `sname, hostel`, `course_id` $->$ `course_name, instructor`,
`roll, course_id` $->$ `grade`.
Find the candidate key, name the highest normal form, and decompose to 2NF.
]
#sol[
*Candidate key.* `roll` is never on a right side; neither is `course_id`. Both are in
bucket L, so both are in every key. Seed = `{roll, course_id}`.

Closure of `{roll, course_id}`:
- start `{roll, course_id}`
- `roll` $->$ `sname, hostel` fires $=>$ add both
- `course_id` $->$ `course_name, instructor` fires $=>$ add both
- `roll, course_id` $->$ `grade` fires $=>$ add `grade`
- all 7 attributes. ✓

So `{roll, course_id}` is the only candidate key. Prime = `{roll, course_id}`.
Non-prime = `sname, hostel, course_name, instructor, grade`.

*Highest normal form.* Look for a partial dependency:
- `roll` $->$ `sname` — `roll` is a *proper subset* of the key, and `sname` is non-prime.
  *Partial dependency.* 2NF fails.
- `course_id` $->$ `course_name` — same problem.
- `roll, course_id` $->$ `grade` — full dependency, fine.

#ans[the relation is in 1NF only]

*Decomposition.* Give every determinant its own table.
#table(columns: (auto, auto, auto), inset: 5pt,
  [*Table*], [*Attributes*], [*Key*],
  [`STUDENT`], [`roll`, `sname`, `hostel`], [`roll`],
  [`COURSE`], [`course_id`, `course_name`, `instructor`], [`course_id`],
  [`REGISTRATION`], [`roll`, `course_id`, `grade`], [`{roll, course_id}`],
)

*Check it.* The program in 6.16 confirms: the decomposition is *lossless* and
*dependency preserving*, and each of the three fragments is in BCNF — so this one split
jumped the table from 1NF all the way to BCNF.

And notice all three anomalies from section 6.1 are gone:
- Asha's hostel now lives in *one* row of `STUDENT` — no update anomaly.
- Deleting Chetan's registration leaves `COURSE` untouched — no delete anomaly.
- A new course goes straight into `COURSE` with no student — no insert anomaly.
]

#trap[
A famous wrong split: `STUDENT(roll, sname, hostel)` + `REST(course_id, course_name,
instructor, grade)`. It *looks* tidier, but it is *lossy* — the fragments share no
attribute at all, so `grade` can never be reconnected to a student. The program reports
`lossless: false` for it. Always run the lossless test before you accept a split.
]

#section[6.7 Third normal form]

*3NF: 2NF, and for every non-trivial $X -> A$, either $X$ is a super key or $A$ is prime.*

The everyday phrasing: *no non-prime attribute depends on another non-prime attribute.*
That is a transitive dependency — key $->$ something $->$ something else.

#ex(6, tier: 1, asked: "Accenture · pattern")[
`EMP(emp_id, emp_name, dept_id, dept_name, dept_head)` with
`emp_id` $->$ `emp_name, dept_id` and `dept_id` $->$ `dept_name, dept_head`.
Name the highest normal form and fix it.
]
#sol[
*Candidate key.* `emp_id` is never on a right side $=>$ it is in every key.
$"emp_id"^+$: adds `emp_name`, `dept_id`, then `dept_id` fires and adds `dept_name`,
`dept_head` $=>$ all 5. So `{emp_id}` is the only candidate key.

Prime = `{emp_id}`. Non-prime = the other four.

*2NF?* The key is a single attribute, so no proper subset of it exists (other than the
empty set). No partial dependency is possible. *2NF holds.*

*3NF?* Check `dept_id` $->$ `dept_name`:
- Is `dept_id` a super key? $"dept_id"^+ = {"dept_id, dept_name, dept_head"}$ — no
  `emp_id`, so no.
- Is `dept_name` prime? No.

Both tests fail $=>$ *3NF fails*. The chain is
`emp_id` $->$ `dept_id` $->$ `dept_name`: a *transitive dependency*.
#ans[highest normal form is 2NF]

*Fix — split at the offending determinant.*
#table(columns: (auto, auto, auto), inset: 5pt,
  [*Table*], [*Attributes*], [*Key*],
  [`EMPLOYEE`], [`emp_id`, `emp_name`, `dept_id`], [`emp_id`],
  [`DEPARTMENT`], [`dept_id`, `dept_name`, `dept_head`], [`dept_id`],
)

*Lossless?* The shared attribute is `dept_id`, and $"dept_id"^+$ contains all of
`DEPARTMENT`. Shared attributes form a key of one fragment $=>$ *lossless*. ✓

*Dependency preserving?* `emp_id` $->$ `emp_name, dept_id` lives inside `EMPLOYEE`;
`dept_id` $->$ `dept_name, dept_head` lives inside `DEPARTMENT`. Nothing lost. ✓

Both fragments are in BCNF (each has a single-attribute key that determines everything
else). Verified by the program in 6.16.

*The anomaly this removed:* previously, if the last employee of a department left,
the department's name and head vanished with them.
]

#note[
*2NF failure vs 3NF failure, in one line each.*
- 2NF failure: a non-key column depends on *part of* the key. (Only possible with a
  composite key.)
- 3NF failure: a non-key column depends on *another non-key column*.
]

#section[6.8 Boyce–Codd normal form]

*BCNF: for every non-trivial $X -> A$, $X$ must be a super key.* Full stop.

BCNF is 3NF with the escape hatch removed. 3NF forgives a violation when the
right-hand attribute happens to be prime; BCNF does not.

#ex(7, tier: 2, asked: "Sea/Shopee · pattern")[
A tutoring centre records `COACH(student, subject, tutor)` under two rules:
+ Each tutor teaches exactly one subject.
+ For a given subject, a student is assigned exactly one tutor.

Find the candidate keys, the highest normal form, and decompose if needed.
]
#sol[
*FDs from the rules.*
- Rule 1: `tutor` $->$ `subject`.
- Rule 2: `{student, subject}` $->$ `tutor`.

*Candidate keys.*
- $"{student, subject}"^+$: add `tutor` by rule 2 $=>$ all three. *Key.* Minimal?
  `student` alone determines nothing; `subject` alone determines nothing. Yes, minimal.
- $"{student, tutor}"^+$: `tutor` $->$ `subject` adds `subject` $=>$ all three. *Key.*
  Minimal for the same reason.
- `{subject, tutor}`? Closure is `{subject, tutor}` — no `student`. Not a key.

Candidate keys: `{student, subject}` and `{student, tutor}`.

*Prime attributes* = `student`, `subject`, `tutor` — *all three*.

*3NF?* Check every FD:
- `{student, subject}` $->$ `tutor`: left side is a super key ✓
- `tutor` $->$ `subject`: `tutor` is not a super key ✗ — *but* `subject` is prime ✓

3NF's rule is "super key OR prime right side", and the second test passes.
*The relation is in 3NF.*

*BCNF?* `tutor` $->$ `subject` with `tutor` not a super key. No escape hatch.
*BCNF fails.*
#ans[3NF, not BCNF]

*Why it actually matters.* Store the row (Asha, Databases, Ravi). The fact "Ravi teaches
Databases" is repeated in every row where Ravi appears. If Ravi switches to Networks you
must edit them all — an update anomaly *surviving in a 3NF table*. That is exactly why
BCNF exists.

*Decomposition.* Split on the violating FD $X -> Y$ into $X^+$ and $X union (R - X^+)$:
$"tutor"^+ = {"tutor, subject"}$.
#table(columns: (auto, auto, auto), inset: 5pt,
  [*Table*], [*Attributes*], [*Key*],
  [`TEACHES`], [`tutor`, `subject`], [`tutor`],
  [`ASSIGNED`], [`student`, `tutor`], [`{student, tutor}`],
)

*Lossless?* Shared attribute is `tutor`, and $"tutor"^+$ = all of `TEACHES`. ✓ Verified.

*Dependency preserving?* `TEACHES` keeps `tutor` $->$ `subject`. But
`{student, subject}` $->$ `tutor` is now *split across two tables* — `student` is in one,
`subject` in the other — so no single table can enforce it. *The FD is lost.* Verified:
the program prints `dependency preserving: false`, and the projected FDs are
`TEACHES: tutor→subject` and `ASSIGNED: (none)`.

*The consequence to say out loud:* after this split, the database can no longer stop you
inserting (Asha, Ravi) and (Asha, Meera) when Ravi and Meera both teach Databases — which
rule 2 forbids. You have traded a redundancy problem for a constraint-checking problem.
This is the classic BCNF trade-off.
]

#diagram(height: 5.0cm, caption: "The normal forms nest. Each step removes one more kind of redundancy — and each step costs you more joins at read time.")[
  #dnode(1.0cm, 0.15cm, 14.6cm, 0.75cm, "1NF — every cell atomic, no repeating groups", fill: rgb("#f5f8fa"))
  #dnode(1.0cm, 1.0cm, 12.4cm, 0.75cm, "2NF — 1NF + no partial dependency on part of a key", fill: rgb("#eef3f7"))
  #dnode(1.0cm, 1.85cm, 10.2cm, 0.75cm, "3NF — 2NF + no transitive dependency", fill: rgb("#e2ebf2"))
  #dnode(1.0cm, 2.7cm, 8.0cm, 0.75cm, "BCNF — every determinant is a super key", fill: rgb("#d5e2ec"))
  #dnode(1.0cm, 3.55cm, 5.8cm, 0.75cm, "4NF — BCNF + no stray MVD", fill: rgb("#c8d9e6"))
  #darrow(0.6cm, 0.3cm, 0.6cm, 4.2cm)
  #dnode(9.4cm, 2.7cm, 6.2cm, 0.75cm, "may lose a dependency", fill: white)
  #dnode(7.2cm, 3.55cm, 8.4cm, 0.75cm, "3NF is always reachable losslessly AND preserving", fill: white)
]

#section[6.9 3NF versus BCNF — the case that decides the round]

#ex(8, tier: 3, asked: "Microsoft · pattern")[
$R(A,B,C,D,E,F)$ with $F = {A -> B C, " " C D -> E, " " B -> D, " " E -> A}$.
Name the highest normal form, with proof.
]
#sol[
From Example 4: candidate keys are `AF`, `EF`, `BCF`, `CDF`, and *every* attribute is
prime.

*Test each FD against the 3NF rule* ("$X$ is a super key OR every attribute on the right
is prime"):
#table(columns: (auto, auto, auto, auto), inset: 5pt,
  [*FD*], [*Is the left a super key?*], [*Is the right prime?*], [*3NF*],
  [$A -> B C$], [$A^+ = "ABCDE"$, no `F` $=>$ no], [B prime ✓, C prime ✓], [passes],
  [$C D -> E$], [$("CD")^+ = "ABCDE"$, no `F` $=>$ no], [E prime ✓], [passes],
  [$B -> D$], [$B^+ = "BD"$ $=>$ no], [D prime ✓], [passes],
  [$E -> A$], [$E^+ = "ABCDE"$, no `F` $=>$ no], [A prime ✓], [passes],
)
*Every FD passes 3NF.* And 3NF implies 2NF implies 1NF, so the relation is in 3NF.

*Now BCNF.* BCNF needs the left side to be a super key, with no prime-attribute excuse.
All four left sides fail. *BCNF fails on all four FDs.*
#ans[highest normal form is 3NF]

*The insight to state.* When every attribute is prime, a relation is *automatically* in
3NF — the "right side is prime" clause can never fail. So a question where all attributes
are prime is always a 3NF-not-BCNF question. Spotting this in ten seconds is the whole
trick.
]

#trick[
*Fast normal-form triage, in order:*
+ Compute the candidate keys. Mark prime and non-prime attributes.
+ For each FD $X -> Y$ (drop the trivial part): is $X$ a super key? If yes, this FD is
  fine at every level. Move on.
+ If not: is every attribute of $Y$ prime? If yes $=>$ 3NF survives, BCNF dies.
+ If some attribute of $Y$ is non-prime: is $X$ a *proper subset of a candidate key*?
  - Yes $=>$ 2NF dies (partial dependency). Highest form is 1NF.
  - No $=>$ 2NF survives, 3NF dies (transitive dependency). Highest form is 2NF.
+ The answer is the *worst* verdict across all FDs.
]

#section[6.10 Lossless join and dependency preservation]

Any table can be shredded into tiny pieces. The question is whether you can put it back.

#subsection[The lossless join test (two fragments)]

Splitting $R$ into $R_1$ and $R_2$ is lossless if and only if
$ (R_1 inter R_2) -> R_1 quad "or" quad (R_1 inter R_2) -> R_2 $
In words: *compute the closure of the shared attributes; if it swallows either fragment
completely, the split is safe.*

#ex(9, tier: 2, asked: "GIC · pattern")[
`EMP(emp_id, emp_name, dept_id, dept_name, dept_head)` with `emp_id` $->$
`emp_name, dept_id` and `dept_id` $->$ `dept_name, dept_head`. Test two splits:

*(a)* `(emp_id, emp_name, dept_id)` + `(dept_id, dept_name, dept_head)`

*(b)* `(emp_id, emp_name, dept_name)` + `(dept_id, dept_name, dept_head)`
]
#sol[
*(a)* Shared attributes $= {"dept_id"}$.
$"dept_id"^+ = {"dept_id, dept_name, dept_head"}$ — that is exactly fragment 2.
Shared $->$ $R_2$ ✓ $=>$ *lossless*.

*(b)* Shared attributes $= {"dept_name"}$.
$"dept_name"^+ = {"dept_name"}$ — `dept_name` is never on the left of any FD, so its
closure adds nothing. It does not cover either fragment. $=>$ *lossy*.

Verified by the program: `(a) {"ok":true,"common":"D","closure":"DHM"}` and
`(b) {"ok":false,"common":"M","closure":"M"}` (letters: E=emp_id, N=emp_name, D=dept_id,
M=dept_name, H=dept_head).
#ans[(a) lossless, (b) lossy]

*What "lossy" actually means.* Rejoin (b) on `dept_name` and you get *spurious tuples* —
rows that were never in the original table. If two departments happened to share a name,
every employee of one would appear to belong to the other as well. Lossy decomposition
does not lose rows; it *invents* them.
]

#trap[
"Lossy means rows disappear." No — a lossy natural join gives you *more* rows than you
started with, not fewer. The information that is lost is the ability to tell the real
rows from the invented ones.
]

#subsection[Dependency preservation]

A decomposition preserves dependencies if every original FD can still be checked *inside
a single fragment*, without a join.

Why it matters: a constraint you can only check with a join is a constraint the database
will not enforce for you cheaply. Every `INSERT` would need a join.

#table(columns: (auto, auto, auto), inset: 5pt,
  [*Target*], [*Lossless?*], [*Dependency preserving?*],
  [3NF], [always achievable], [always achievable],
  [BCNF], [always achievable], [*not always*],
)

That single row is the answer to "what is the difference between 3NF and BCNF in
practice?"

#section[6.11 Minimal cover — the three-step algorithm]

A *minimal cover* (or canonical cover) $F_c$ is the smallest FD set that means exactly the
same as $F$. You need it before 3NF synthesis, and it is asked on its own.

+ *Split right sides.* Rewrite every FD so it has exactly one attribute on the right.
  ($X -> Y Z$ becomes $X -> Y$ and $X -> Z$.)
+ *Trim left sides.* For each FD $X -> A$ with $|X| >= 2$, try removing each attribute
  $B$ from $X$. If $(X - B)^+$ (under the *current* FD set) still contains $A$, then $B$
  was extraneous — drop it.
+ *Drop whole FDs.* For each FD $X -> A$, remove it temporarily and compute $X^+$ under
  the *remaining* FDs. If $A$ is still there, the FD was redundant — delete it for good.

#ex(10, tier: 1, asked: "Cognizant · pattern")[
Find a minimal cover of
$F = {A -> B C, " " B -> C, " " A -> B, " " A B -> C, " " A C -> D}$ over $R(A,B,C,D)$.
]
#sol[
*Step 1 — split right sides.*
$A -> B$, $A -> C$, $B -> C$, $A -> B$ (duplicate, keep one), $A B -> C$, $A C -> D$.

Working set: ${A -> B, " " A -> C, " " B -> C, " " A B -> C, " " A C -> D}$.

*Step 2 — trim left sides.* Only $A B -> C$ and $A C -> D$ have two attributes.

$A B -> C$:
- Drop `A`, leaving $B -> C$. Is $C in B^+$? $B^+ = {B, C}$ using $B -> C$. *Yes* $=>$ `A`
  was extraneous. $A B -> C$ becomes $B -> C$ (a duplicate of one we already have).

$A C -> D$:
- Drop `C`, leaving $A -> D$. Is $D in A^+$? $A^+$: $A -> B$ gives B, $A -> C$ gives C,
  then $A C -> D$ fires and gives D. *Yes* $=>$ `C` was extraneous. $A C -> D$ becomes
  $A -> D$.

Working set: ${A -> B, " " A -> C, " " B -> C, " " B -> C, " " A -> D}$.

*Step 3 — drop redundant FDs.*
- $A -> B$: remove it. Remaining ${A -> C, B -> C, A -> D}$. $A^+ = {A, C, D}$ — no `B`.
  *Keep it.*
- $A -> C$: remove it. Remaining ${A -> B, B -> C, A -> D}$. $A^+$: A→B gives B, B→C
  gives C $=>$ `C` is there. *Redundant — delete.*
- The duplicate $B -> C$: one copy is obviously redundant. *Delete the copy.*
- $B -> C$ (the surviving copy): remove it. Remaining ${A -> B, A -> D}$.
  $B^+ = {B}$ — no `C`. *Keep it.*
- $A -> D$: remove it. Remaining ${A -> B, B -> C}$. $A^+ = {A, B, C}$ — no `D`.
  *Keep it.*

#ans[$F_c = {A -> B, " " B -> C, " " A -> D}$]

Program trace, printed exactly:
#code(lang: "text", caption: "node fd2.js")[
```text
after split : A->B, A->C, B->C, AB->C, AC->D
after LHS   : A->B, A->C, B->C, B->C, A->D
after drop  : A->B, B->C, A->D
MINIMAL COVER: A->B, B->C, A->D
keys of R(A,B,C,D): A
```
]

*Sanity check* — the cover must still derive everything the original did.
Original had $A -> C$. Under the cover: $A -> B$ and $B -> C$ give $A -> C$ by
transitivity. ✓ Original had $A C -> D$. Under the cover: $A -> D$, so augmenting gives
$A C -> D$. ✓
]

#trap[
Order matters in step 3, and that is *allowed*. A minimal cover is not unique — removing
FDs in a different order can give a different but equally valid cover. If the interviewer's
answer differs from yours, check that each one derives the other; do not assume you are
wrong.
]

#ex(11, tier: 2, asked: "SCB · pattern")[
Find a minimal cover of
$F = {P -> Q, " " P Q -> R, " " R -> S, " " R S -> T, " " T -> U, " " P U -> T}$
over $R(P,Q,R,S,T,U)$, and give the candidate key.
]
#sol[
*Step 1 — split.* Every right side is already a single attribute. Nothing to do.

*Step 2 — trim left sides.*
- $P Q -> R$: drop `Q`, leaving $P -> R$. Is $R in P^+$? $P^+$: $P -> Q$ gives Q, then
  $P Q -> R$ gives R. *Yes* $=>$ becomes $P -> R$.
- $R S -> T$: drop `S`, leaving $R -> T$. Is $T in R^+$? $R^+$: $R -> S$ gives S, then
  $R S -> T$ gives T. *Yes* $=>$ becomes $R -> T$.
- $P U -> T$: drop `U`, leaving $P -> T$. Is $T in P^+$? $P^+ = {P,Q,R,S,T,U}$ (P→Q, P→R,
  R→S, R→T, T→U). *Yes* $=>$ becomes $P -> T$.

Working set: ${P -> Q, " " P -> R, " " R -> S, " " R -> T, " " T -> U, " " P -> T}$.

*Step 3 — drop redundant FDs.*
- $P -> T$: remove it. Remaining set still gives $P -> R -> T$. *Redundant — delete.*
- The other five are each needed (remove any one and the closure of its left side loses
  that attribute).

#ans[$F_c = {P -> Q, " " P -> R, " " R -> S, " " R -> T, " " T -> U}$, candidate key `{P}`]

Program output, exactly:
#code(lang: "text", caption: "node fd3.js")[
```text
after split : P->Q, PQ->R, R->S, RS->T, T->U, PU->T
after LHS   : P->Q, P->R, R->S, R->T, T->U, P->T
after drop  : P->Q, P->R, R->S, R->T, T->U
keys: P
```
]
]

#section[6.12 The two decomposition algorithms]

#subsection[3NF synthesis — always lossless, always dependency preserving]

+ Compute a minimal cover $F_c$.
+ Group the FDs of $F_c$ by identical left side. Make one relation per group,
  containing the left side plus all its right sides.
+ If no fragment contains a whole candidate key, add one more relation that *is* a
  candidate key.
+ Delete any fragment whose attributes are a subset of another fragment's.

#ex(12, tier: 2, asked: "Agoda · pattern")[
Synthesise a 3NF schema for $R(P,Q,R,S,T,U)$ using the minimal cover from Example 11.
]
#sol[
*Step 1.* $F_c = {P -> Q, " " P -> R, " " R -> S, " " R -> T, " " T -> U}$.

*Step 2 — group by left side.*
#table(columns: (auto, auto, auto), inset: 5pt,
  [*Left side*], [*FDs in the group*], [*Fragment*],
  [`P`], [$P -> Q$, $P -> R$], [`R1(P, Q, R)`],
  [`R`], [$R -> S$, $R -> T$], [`R2(R, S, T)`],
  [`T`], [$T -> U$], [`R3(T, U)`],
)

*Step 3 — does some fragment hold a candidate key?* The candidate key is `{P}`, and
`R1(P,Q,R)` contains `P`. ✓ No extra relation needed.

*Step 4 — any fragment inside another?* `{P,Q,R}`, `{R,S,T}`, `{T,U}` — no subset
relationships. Nothing to delete.

#ans[`R1(P,Q,R)`, `R2(R,S,T)`, `R3(T,U)`]

Verified by the program:
#code(lang: "text", caption: "node fd4.js")[
```text
fragments        : PQR , RST , TU
candidate key(s) : P
lossless         : true
dep preserving   : true
frag PQR -> keys P    -> in BCNF
frag RST -> keys R    -> in BCNF
frag TU  -> keys T    -> in BCNF
```
]
Here 3NF synthesis happened to land in BCNF as well. That is common but not guaranteed.
]

#subsection[BCNF decomposition — always lossless, may lose a dependency]

Repeat until no violation remains:
+ Find a non-trivial FD $X -> Y$ inside a fragment where $X$ is not a super key *of that
  fragment*.
+ Replace the fragment with $X^+$ and $X union (R_i - X^+)$.

#diagram(height: 5.7cm, caption: "BCNF decomposition of R(A,B,C,D,E,F). Lossless at every step — but CD→E ends up split across two fragments and is lost.")[
  #dnode(5.6cm, 0.15cm, 4.8cm, 0.8cm, "R(A,B,C,D,E,F)", fill: rgb("#dbe6ee"))
  #dnode(2.0cm, 1.85cm, 4.6cm, 0.8cm, "R1(A,B,C,D,E)", fill: white)
  #dnode(10.0cm, 1.85cm, 4.6cm, 0.8cm, "R2(A,F)  BCNF ok", fill: rgb("#e2efdd"))
  #darrow(7.2cm, 0.98cm, 4.6cm, 1.8cm, label: "A+ = ABCDE")
  #darrow(8.8cm, 0.98cm, 12.0cm, 1.8cm)

  #dnode(0.3cm, 3.55cm, 3.8cm, 0.8cm, "R11(B,D)  BCNF ok", fill: rgb("#e2efdd"))
  #dnode(4.6cm, 3.55cm, 4.4cm, 0.8cm, "R12(A,B,C,E)  BCNF ok", fill: rgb("#e2efdd"))
  #darrow(3.6cm, 2.7cm, 2.2cm, 3.5cm, label: "B+ = BD")
  #darrow(5.0cm, 2.7cm, 6.6cm, 3.5cm)

  #dnode(0.3cm, 4.6cm, 15.4cm, 0.85cm,
    [Final: `{B,D}`, `{A,B,C,E}`, `{A,F}` — lossless (verified), but `CD→E` cannot be checked in any one fragment.],
    fill: rgb("#f7f7f5"))
]

#ex(13, tier: 3, asked: "D. E. Shaw · pattern")[
Decompose $R(A,B,C,D,E,F)$, $F = {A -> B C, " " C D -> E, " " B -> D, " " E -> A}$, into
BCNF. Then state whether dependencies are preserved.
]
#sol[
*Round 1.* Pick the violating FD $A -> B C$. $A^+ = A B C D E$ (Example 3), which is not
all of $R$, so `A` is not a super key $=>$ genuine violation.
- Fragment 1: $A^+ = R_1 (A,B,C,D,E)$
- Fragment 2: $A union (R - A^+) = {A} union {F} = R_2 (A, F)$

*Lossless?* Shared = `{A}`, and $A^+$ covers $R_1$ entirely. ✓

*Is $R_2 (A,F)$ in BCNF?* The only FDs visible inside it are trivial; its key is `{A,F}`.
BCNF ✓.

*Round 2 — inside $R_1 (A,B,C,D,E)$.* Its candidate keys are `A`, `E`, `BC`, `CD`
(drop the `F` from Example 4's answer). Check $B -> D$: $B^+ = B D$, not a super key of
$R_1$ $=>$ violation.
- Fragment: $B^+ = R_11 (B, D)$
- Fragment: $B union (R_1 - B^+) = {B} union {A, C, E} = R_12 (A, B, C, E)$

*Lossless?* Shared = `{B}`, and $B^+ = B D$ covers $R_11$. ✓

*Is $R_11 (B,D)$ in BCNF?* Key `B`, and $B -> D$ has a super-key left side. ✓

*Is $R_12 (A,B,C,E)$ in BCNF?* Project the FDs onto these four attributes:
$A -> B C E$ and $E -> A B C$. So the candidate keys are `A`, `E` and `BC`, and every
determinant is a super key. BCNF ✓. (The program prints
`keys ABCE : A | E | BC` and `verdict: in BCNF`.)

#ans[`{B,D}`, `{A,B,C,E}`, `{A,F}` — all three in BCNF, decomposition lossless]

*Dependencies preserved?* No. Look at $C D -> E$. After the split, `C` lives in
`{A,B,C,E}` and `D` lives in `{B,D}`. No single fragment holds both, so no fragment can
enforce the rule. Program output: `dep preserving: false`.

*The sentence that wins the follow-up:* "This is the guaranteed trade-off. BCNF is always
reachable losslessly, but not always with dependency preservation. If losing `CD→E`
matters to the business, I would stop at 3NF — where both properties are guaranteed — and
enforce the redundancy with a trigger or an application check."
]

#section[6.13 Beyond BCNF — MVDs, 4NF and 5NF]

#subsection[Multivalued dependency]

$X arrow.double Y$ ("$X$ multidetermines $Y$") means: for a fixed $X$, the set of $Y$
values is *independent* of the other columns.

Concrete case. A staff member can hold several skills *and* speak several languages, and
the two lists have nothing to do with each other.

#table(columns: (auto, auto, auto), inset: 5pt,
  [*emp_id*], [*skill*], [*language*],
  [E1], [Java], [Hindi],
  [E1], [Java], [Tamil],
  [E1], [SQL], [Hindi],
  [E1], [SQL], [Tamil],
)
Four rows to record *two* skills and *two* languages. Add one more language and you must
add *two* more rows. That is $2 times 2$ growth for facts that are unrelated.

Here `emp_id` $arrow.double$ `skill` and `emp_id` $arrow.double$ `language`. The table is
in BCNF — its only key is all three columns together, and there is no non-trivial FD at
all — yet the redundancy is obvious.

*4NF fix:* split into `EMP_SKILL(emp_id, skill)` and `EMP_LANG(emp_id, language)`.
Two rows and two rows instead of four. Adding a language now costs one row.

#note[
Every FD is also an MVD (if $X -> Y$ then $X arrow.double Y$), so 4NF implies BCNF.
The nesting is 1NF $supset$ 2NF $supset$ 3NF $supset$ BCNF $supset$ 4NF $supset$ 5NF.
]

#ex(14, tier: 3, asked: "Adobe · pattern")[
A college keeps `COURSE_INFO(course, instructor, book)`. Each course is taught by a set of
instructors and prescribes a set of textbooks, and the two sets have nothing to do with
each other — any instructor of the course may use any of its books.

Course `CS05` has instructors {Rao, Iyer} and books {Vol1, Vol2, Vol3}.

*(a)* How many rows does the table hold for `CS05`?
*(b)* Is the table in BCNF?
*(c)* What happens when a fourth book is prescribed?
*(d)* Decompose it and show the row count afterwards.
]
#sol[
*(a)* Because the two sets are independent, every instructor must be paired with every
book, or the table would falsely suggest that Rao does not use Vol3.
$2 times 3 = 6$ rows:

#table(columns: (auto, auto, auto), inset: 5pt,
  [*course*], [*instructor*], [*book*],
  [CS05], [Rao], [Vol1],
  [CS05], [Rao], [Vol2],
  [CS05], [Rao], [Vol3],
  [CS05], [Iyer], [Vol1],
  [CS05], [Iyer], [Vol2],
  [CS05], [Iyer], [Vol3],
)

*(b)* Look for a non-trivial FD.
- `course` $->$ `instructor`? No — CS05 has two instructors.
- `course` $->$ `book`? No — three books.
- `{course, instructor}` $->$ `book`? No — Rao appears with three books.
- `{course, book}` $->$ `instructor`? No — Vol1 appears with two instructors.

There is *no* non-trivial FD at all. So the only candidate key is all three columns
together, every attribute is prime, and every determinant is trivially a super key.
*The table is in BCNF.* It is even in 3NF, 2NF and 1NF. And yet it is obviously
redundant.

*(c)* Adding Vol4 forces you to insert *two* rows — one per instructor. Hiring a third
instructor would force *four* new rows. The cost of one fact is multiplied by the size of
an unrelated set. That is the signature of a multivalued dependency:
`course` $arrow.double$ `instructor` and `course` $arrow.double$ `book`.

*(d)* 4NF decomposition — one table per independent set.
#table(columns: (auto, auto, auto), inset: 5pt,
  [*course*], [*instructor*], [],
  [CS05], [Rao], [],
  [CS05], [Iyer], [],
)
#table(columns: (auto, auto, auto), inset: 5pt,
  [*course*], [*book*], [],
  [CS05], [Vol1], [],
  [CS05], [Vol2], [],
  [CS05], [Vol3], [],
)
$2 + 3 = 5$ rows instead of 6. That looks like a small win here — but the saving is
$m + n$ instead of $m times n$, so at 10 instructors and 40 books it is 50 rows instead of
400. Adding a book now costs exactly *one* row.
#ans[(a) 6 (b) yes, BCNF (c) two new rows for one new fact (d) split into (course, instructor) and (course, book): 5 rows]

*Lossless?* Yes — and this is the *definition* of the MVD. `course` $arrow.double$
`instructor` holds precisely when joining the two projections back on `course` reproduces
the original table exactly, with no spurious rows. If the sets were *not* independent (say
Rao only ever used Vol1), the MVD would not hold, the join would invent the row
(CS05, Rao, Vol2), and the split would be lossy.

*The trap in this question:* a candidate who only knows FDs will say "it is in BCNF, so it
is fully normalised" and stop. The redundancy is real and visible, and FD-based normal
forms cannot see it. That is the entire reason 4NF exists — say so.
]

#subsection[5NF in one paragraph]

5NF (project-join normal form) deals with a table that cannot be split into *two* pieces
losslessly, but *can* be split into three. It comes up when a three-way business rule is
genuinely three separate two-way rules — for example "supplier S stocks part P", "part P
is used in project J", "supplier S supplies project J", and a row exists only when all
three pairs hold. In practice you will almost never meet this. Know the name, know it is
about *join dependencies*, and move on.

#section[6.14 When to stop — denormalisation]

Normalisation removes redundancy. Redundancy is what makes reads fast. So there is a
price.

#table(columns: (auto, auto), inset: 5pt,
  [*Normalised*], [*Denormalised*],
  [No update anomalies], [Must update the same fact in several places],
  [Smaller tables, smaller writes], [Bigger rows, more disk],
  [More joins per query], [Fewer joins — sometimes none],
  [Constraints enforced by keys], [Constraints enforced by application code],
)

Legitimate reasons to denormalise *on purpose*:
- *Reporting and analytics.* A star schema keeps one big fact table plus wide dimension
  tables that are deliberately not in 3NF, because the workload is read-heavy and the data
  is loaded in batches.
- *A stored aggregate.* Keeping `order.total_amount` alongside the line items saves a
  `SUM` on every page view. The cost: a trigger or a job must keep it correct.
- *A frozen copy.* An invoice must store the price *as it was at purchase time*. That is
  not redundancy at all — the current product price is a different fact from the price
  paid. Getting this distinction right is a strong interview answer.

#trap[
"Always normalise to BCNF." Wrong as a blanket rule, and interviewers probe it. The real
answer: "Normalise to 3NF or BCNF by default, because correctness is the expensive thing
to fix later. Denormalise only from a measured read problem, and only where you can name
who keeps the duplicate in sync."
]

#section[6.15 Turning an ER design into tables]

#diagram(height: 3.7cm, caption: "A 1:N relationship needs no third table — the foreign key goes on the 'many' side.")[
  #dnode(0.3cm, 0.15cm, 15.4cm, 0.55cm, "1 : N  —  one department employs many employees", fill: rgb("#dbe6ee"))
  #dnode(0.3cm, 1.0cm, 4.4cm, 1.0cm, [DEPARTMENT \ dept_id (PK)], fill: white)
  #dnode(5.4cm, 1.0cm, 2.6cm, 1.0cm, [employs \ 1 : N], fill: rgb("#eef3f7"))
  #dnode(8.7cm, 1.0cm, 4.4cm, 1.0cm, [EMPLOYEE \ emp_id (PK)], fill: white)
  #darrow(4.8cm, 1.5cm, 5.3cm, 1.5cm)
  #darrow(8.1cm, 1.5cm, 8.6cm, 1.5cm)
  #darrow(10.9cm, 2.05cm, 10.9cm, 2.6cm)
  #dnode(5.2cm, 2.65cm, 10.5cm, 0.75cm,
    [`employee` gains a `dept_id` column referencing `department(dept_id)`], fill: rgb("#e2efdd"))
]

#table(columns: (auto, 1fr), inset: 5pt,
  [*ER construct*], [*Becomes*],
  [Strong entity], [One table. Its key attribute becomes the primary key.],
  [Multivalued attribute], [A *separate* table: the owner's key + the value, keyed on both. (This is the 1NF rule.)],
  [Composite attribute], [Its leaf parts become columns: `address` becomes `street`, `city`, `pin`.],
  [Derived attribute], [Usually *not* stored — computed on read, e.g. `age` from `dob`.],
  [1 : 1], [Put the foreign key on the side that must exist, and mark it `UNIQUE`. Or merge both entities into one table if they always appear together.],
  [1 : N], [Foreign key on the *N* side. *No third table.*],
  [M : N], [A *third table* holding both foreign keys. Its primary key is the pair. Relationship attributes (like `hours`) live here.],
  [Weak entity], [A table whose primary key is (owner's key + its own partial key), with `ON DELETE CASCADE` to the owner.],
  [Total participation], [`NOT NULL` on the foreign key.],
  [Ternary relationship], [One table with three foreign keys; the primary key depends on the cardinality rules.],
)

#ex(15, tier: 2, asked: "LINE MAN · pattern")[
Map this design to tables: a `RESTAURANT` has many `MENU_ITEM`s (an item belongs to
exactly one restaurant and is identified only by its name within that restaurant); a
`CUSTOMER` places many `ORDER`s; an `ORDER` contains many `MENU_ITEM`s with a quantity.
]
#sol[
Take the relationships one at a time.

*`RESTAURANT` — `MENU_ITEM` is 1 : N, and `MENU_ITEM` is a weak entity* (its name is only
unique inside its restaurant).
```sql
CREATE TABLE restaurant (
  rest_id   INTEGER PRIMARY KEY,
  rest_name TEXT NOT NULL,
  city      TEXT
);
CREATE TABLE menu_item (
  rest_id   INTEGER NOT NULL REFERENCES restaurant(rest_id) ON DELETE CASCADE,
  item_name TEXT NOT NULL,
  price     INTEGER NOT NULL CHECK (price > 0),
  PRIMARY KEY (rest_id, item_name)          -- weak entity: owner key + partial key
);
```

*`CUSTOMER` — `ORDER` is 1 : N,* so the foreign key goes on `order`.
```sql
CREATE TABLE customer (
  cust_id   INTEGER PRIMARY KEY,
  cust_name TEXT NOT NULL,
  phone     TEXT UNIQUE
);
CREATE TABLE cust_order (
  order_id    INTEGER PRIMARY KEY,
  cust_id     INTEGER NOT NULL REFERENCES customer(cust_id),   -- total participation
  placed_at   TEXT NOT NULL,
  total_paise INTEGER
);
```

*`ORDER` — `MENU_ITEM` is M : N with an attribute (`quantity`),* so it needs its own
table.
```sql
CREATE TABLE order_line (
  order_id  INTEGER NOT NULL REFERENCES cust_order(order_id) ON DELETE CASCADE,
  rest_id   INTEGER NOT NULL,
  item_name TEXT    NOT NULL,
  quantity  INTEGER NOT NULL CHECK (quantity > 0),
  unit_paise INTEGER NOT NULL,        -- frozen price, see below
  PRIMARY KEY (order_id, rest_id, item_name),
  FOREIGN KEY (rest_id, item_name) REFERENCES menu_item(rest_id, item_name)
);
```
#ans[5 tables: `restaurant`, `menu_item`, `customer`, `cust_order`, `order_line`]

Three points to volunteer, because they are what separate a good answer from a passing
one:
+ The M : N table's primary key is the *combination* of the two foreign keys. Adding a
  surrogate `line_id` is allowed, but you then still need a `UNIQUE` constraint on the
  pair, or you will get duplicate lines.
+ `unit_paise` is stored on the line even though `menu_item.price` exists. That is *not*
  a normalisation error — the price paid is a different fact from today's price, and it
  must not change when the restaurant raises its rates.
+ Money is stored as an integer count of paise, never as a float. `0.1 + 0.2` is not
  `0.3` in binary floating point — in `node`, `0.1 + 0.2` prints
  `0.30000000000000004`.
]

#section[6.16 Schema-design questions they actually ask]

Normalisation theory is only half of the design round. The other half is a set of
judgement questions with no single right answer — the interviewer wants your *reasoning*,
and a rehearsed trade-off sentence.

#subsection[Surrogate key or natural key?]

#table(columns: (auto, auto), inset: 5pt,
  [*Surrogate* (`order_id INTEGER`)], [*Natural* (`email`, `isbn`, `gst_no`)],
  [Never changes, so foreign keys never need updating.], [Can change — a person changes their email and every child row must follow.],
  [Narrow and uniform, so indexes and joins are cheap.], [Often wide text; every foreign key copy pays for that width.],
  [Carries no meaning, so it leaks nothing if exposed.], [Leaks business data in URLs and logs.],
  [Needs an extra `UNIQUE` constraint on the real business key, or duplicates creep in.], [Uniqueness is enforced for free.],
  [Two rows can be identical except for the id — a silent duplicate.], [Impossible to duplicate.],
)

The answer that scores: *"Surrogate primary key, plus a `UNIQUE` constraint on the natural
key."* You get stable foreign keys and you still cannot insert the same customer twice.

#trap[
"Auto-increment is always the right primary key." Two counter-examples to keep ready:
+ A *join table* for an M : N relationship. Its natural key is already the pair of foreign
  keys, and that pair must be `UNIQUE` anyway. An extra `id` adds a column and an index for
  no benefit.
+ A *distributed system*. Sequential ids need a central counter. A UUID or a time-ordered
  id (ULID / Snowflake style) can be generated anywhere — at the cost of a wider key and,
  for random UUIDs, a badly scattered index. Say "time-ordered id" and you sound like
  someone who has hit this.
]

#subsection[Should this column allow NULL?]

`NULL` means "unknown or not applicable". If a column is `NULL` for a *different reason*
each time, that is a design smell.

#ex(16, tier: 2, asked: "Razer · pattern")[
A `user` table has `phone TEXT NULL`. Product says some users sign up with email only.
Later, product says a phone can also be "pending verification". The team starts storing
`NULL` for both cases. What is wrong, and what would you do?
]
#sol[
*What is wrong:* one column is now encoding two different facts — "no phone given" and
"phone given but not verified". You cannot tell them apart, so you cannot count either,
and any query that says `WHERE phone IS NULL` answers the wrong question.

*Fix:* make the second fact its own column.
```sql
ALTER TABLE users ADD COLUMN phone_verified_at TEXT;   -- NULL = not verified yet
-- now: phone IS NULL           -> no phone on file
--      phone IS NOT NULL AND phone_verified_at IS NULL -> given, not verified
--      phone_verified_at IS NOT NULL                   -> verified
```
#ans[one column must carry one fact; split the second fact into its own column]

*The general rule to state:* "If I need a comment to explain what `NULL` means in a
column, the column is holding more than one fact."
]

#subsection[Hard delete or soft delete?]

A *soft delete* marks a row (`deleted_at TIMESTAMP`) instead of removing it.

#table(columns: (auto, 1fr), inset: 5pt,
  [*Why teams do it*], [Undo, audit trails, and foreign keys that would otherwise break.],
  [*What it costs*], [Every single query must remember `WHERE deleted_at IS NULL`. Forget once and deleted data reappears in a report.],
  [*The `UNIQUE` trap*], [`UNIQUE(email)` now blocks a new signup with an email that belongs to a *deleted* user. Fix with a partial index: `CREATE UNIQUE INDEX ... ON users(email) WHERE deleted_at IS NULL;`],
  [*The honest answer*], [Soft-delete only where the business genuinely needs recovery or audit; otherwise delete, and keep history in a separate archive table.],
)

#subsection[The four columns almost every table wants]

#table(columns: (auto, 1fr), inset: 5pt,
  [`id`], [Surrogate primary key.],
  [`created_at`], [Set once, never updated. Makes every table time-sliceable for free.],
  [`updated_at`], [Touched on every write, usually by a trigger so the application cannot forget.],
  [A *version* or *status*], [Either an optimistic-locking counter, or a small enumerated state column — never a free-text string.],
)

#note[
Two more one-line opinions worth having ready:
- *Money* is an integer count of the smallest unit (paise, cents) or a `DECIMAL`, never a
  float. In `node`, `0.1 + 0.2` prints `0.30000000000000004`.
- *Timestamps* are stored in UTC and rendered in the user's zone. Storing local time
  without a zone is unrecoverable once daylight saving moves.
]

#subsection[Star schema — normalisation on purpose broken]

A reporting warehouse deliberately stops short of 3NF:

#table(columns: (auto, 1fr), inset: 5pt,
  [*Fact table*], [Long and narrow. One row per event (`sale_id, date_key, product_key, store_key, qty, amount`). Billions of rows, mostly foreign keys and numbers.],
  [*Dimension tables*], [Short and wide, and *denormalised on purpose*: `product(product_key, name, category, sub_category, brand, supplier_name, supplier_city)`. `category` $->$ `supplier_city` would be a 3NF violation in an operational schema.],
  [*Why it is fine*], [Dimensions are loaded in controlled batches, not edited by users, so update anomalies cannot happen. Flattening removes a join from every single report.],
  [*Snowflake schema*], [The same design with the dimensions normalised back out. Fewer anomalies, more joins. Most teams choose star.],
)

The sentence: *"In OLTP I normalise for write correctness; in OLAP I denormalise for read
speed, and I can do that safely because the write path is a controlled batch load."*

#section[6.18 The whole chapter, as a program you can run]

Everything in this chapter — every closure, every key list, every verdict — came out of
this file. Run it yourself and change the inputs.

#code(lang: "js", caption: "nf.js — run with: node nf.js")[
```js
// Attributes are single capital letters. An FD is ['AB', 'C'] meaning AB -> C.

const set  = s => new Set([...s]);
const show = s => [...s].sort().join('');

// X+ : keep applying every FD whose left side is already inside the set.
function closure(X, fds) {
  const res = set(X);
  let grew = true;
  while (grew) {
    grew = false;
    for (const [lhs, rhs] of fds) {
      const fires = [...lhs].every(a => res.has(a));
      const adds  = [...rhs].some(a => !res.has(a));
      if (fires && adds) { for (const a of rhs) res.add(a); grew = true; }
    }
  }
  return res;
}

const isSuperkey = (X, R, fds) => show(closure(X, fds)) === show(set(R));

// every subset of R, shortest first, so the first super key found is minimal
function subsets(arr) {
  const out = [];
  for (let m = 1; m < (1 << arr.length); m++)
    out.push(arr.filter((_, i) => m & (1 << i)));
  return out.sort((a, b) => a.length - b.length);
}

function candidateKeys(R, fds) {
  const keys = [];
  for (const s of subsets([...set(R)])) {
    if (!isSuperkey(s, R, fds)) continue;
    if (keys.some(k => [...k].every(a => s.includes(a)))) continue;   // not minimal
    keys.push(show(s));
  }
  return keys;
}

function verdict(R, fds) {
  const keys  = candidateKeys(R, fds);
  const prime = new Set(keys.flatMap(k => [...k]));
  let worst = 'BCNF';
  for (const [lhs, rhs] of fds) {
    const extra = [...rhs].filter(a => !set(lhs).has(a));    // ignore the trivial part
    if (!extra.length || isSuperkey(lhs, R, fds)) continue;
    if (extra.every(a => prime.has(a))) { if (worst === 'BCNF') worst = '3NF'; continue; }
    const partial = keys.some(k => k !== show(set(lhs)) && [...lhs].every(a => k.includes(a)));
    worst = partial ? '1NF' : (worst === '1NF' ? '1NF' : '2NF');
  }
  return { keys, prime: show(prime), highestNormalForm: worst };
}

const cases = [
  ['course registration', 'RCNHTIG', [['R','NH'], ['C','TI'], ['RC','G']]],
  ['employee-department', 'ENDMH',   [['E','ND'], ['D','MH']]],
  ['tutoring',            'SJT',     [['SJ','T'], ['T','J']]],
  ['abstract R',          'ABCDEF',  [['A','BC'], ['CD','E'], ['B','D'], ['E','A']]],
];
for (const [name, R, fds] of cases) {
  const v = verdict(R, fds);
  console.log(name.padEnd(22), 'keys =', v.keys.join('|').padEnd(14),
              'prime =', v.prime.padEnd(7), 'highest NF =', v.highestNormalForm);
}
```
]

Actual output from `node nf.js`:
#code(lang: "text", caption: "terminal")[
```text
course registration    keys = CR             prime = CR      highest NF = 1NF
employee-department    keys = E              prime = E       highest NF = 2NF
tutoring               keys = JS|ST          prime = JST     highest NF = 3NF
abstract R             keys = AF|EF|BCF|CDF  prime = ABCDEF  highest NF = 3NF
```
]

Read the four lines against the chapter:
- *course registration* (Example 5) — key `{course_id, roll}`, 2NF fails on the partial
  dependencies. Highest form 1NF. ✓
- *employee-department* (Example 6) — key `{emp_id}`, 3NF fails on the transitive
  dependency. Highest form 2NF. ✓
- *tutoring* (Example 7) — two keys, every attribute prime, BCNF fails on
  `tutor → subject`. Highest form 3NF. ✓
- *abstract R* (Examples 4 and 8) — four keys, every attribute prime, BCNF fails
  everywhere. Highest form 3NF. ✓

#complexity(time: "O(2^n · |F| · n) for candidate keys", space: "O(n) per closure",
  note: "The subset scan is exponential in the number of attributes, which is fine for the 5-8 attributes an interview uses. A single closure is cheap: each pass is O(|F| · n) and at most n passes can add anything.")

#trap[
JavaScript detail that matters here: `new Set([...'ABC'])` spreads the *string* into
characters, giving `{'A','B','C'}`. That is why every attribute in this tool is a single
letter. For multi-letter attribute names you must pass arrays instead — `[['roll'],
['hostel']]` — or the spread will split `roll` into `r`, `o`, `l`, `l`.
]

#pagebreak()
#section[6.19 Practice]

#practice(tier: 0, time: "6 min")[
+ Is $A B -> A$ trivial or non-trivial?
+ Given $X -> Y$, does $Y -> X$ follow?
+ In `R(A,B,C)` with the single FD $A -> B$, what is $C^+$?
+ A relation's only candidate key is `{A}`. Can it fail 2NF?
+ Name the normal form that removes repeating groups.
+ Which attributes must be in *every* candidate key?
]

#key[
1. Trivial — the right side is inside the left side. — 2. No. FDs are one-directional.
`pin` $->$ `city` but a city has many PIN codes. — 3. $C^+ = {C}$. `C` appears on no left
side of any FD, so nothing can fire. — 4. No. A partial dependency needs a *proper subset*
of a composite key; a single-attribute key has none, so 2NF is automatic. — 5. 1NF. —
6. Every attribute that never appears on the right-hand side of any FD.
]

#practice(tier: 1, time: "15 min")[
+ `R(A,B,C,D)` with $A B -> C$, $C -> D$, $D -> A$. Compute $(A B)^+$, $C^+$ and $D^+$.
+ For the same relation, list all candidate keys.
+ For the same relation, name the highest normal form and justify each FD.
+ `SALES(invoice_no, line_no, product_id, product_name, qty)` with
  `{invoice_no, line_no}` $->$ `product_id, qty` and `product_id` $->$ `product_name`.
  Find the key, the highest normal form and the fix.
+ Prove from Armstrong's axioms that $X -> Y$ and $X -> Z$ give $X -> Y Z$.
]

#key[
1. $(A B)^+$: $A B -> C$ gives C; $C -> D$ gives D $=>$ ABCD, all of it.
$C^+$: $C -> D$ gives D; $D -> A$ gives A; now `AB`? only `A`, not `B`, so $A B -> C$
cannot fire $=>$ ACD.
$D^+$: $D -> A$ gives A $=>$ AD.

2. `B` is never on a right side $=>$ `B` is in every key. $B^+ = B$. Try pairs:
$(A B)^+ =$ ABCD ✓ key. $(B C)^+$: C→D, D→A gives A, then AB→C $=>$ ABCD ✓ key.
$(B D)^+$: D→A, then AB→C, C→D $=>$ ABCD ✓ key. Candidate keys: `AB`, `BC`, `BD`.

3. Prime = {A, B, C, D} — every attribute. So every 3NF test passes on the
"right side is prime" clause. *3NF holds.* BCNF: $C -> D$ has $C^+ = "ACD"$, not a super
key $=>$ *BCNF fails*. Highest normal form is *3NF*.

4. Key `{invoice_no, line_no}` (neither appears on a right side, and their closure is
everything). `product_id` $->$ `product_name` has a non-super-key left side and a
non-prime right side; `product_id` is *not* a subset of the key, so it is a *transitive*
dependency $=>$ 2NF holds, *3NF fails*. Highest form 2NF. Fix: split into
`SALES_LINE(invoice_no, line_no, product_id, qty)` and
`PRODUCT(product_id, product_name)`. Lossless (shared `product_id` is the key of
`PRODUCT`) and dependency preserving.

5. (i) $X -> Y$ given. (ii) $X X -> X Y$ by augmentation with $X$; and $X X = X$, so
$X -> X Y$. (iii) $X -> Z$ given. (iv) $X Y -> Y Z$ by augmenting (iii) with $Y$.
(v) $X -> Y Z$ by transitivity of (ii) and (iv). ∎
]

#practice(tier: 2, time: "22 min")[
+ `R(A,B,C,D,E)` with $A -> B$, $B C -> D$, $D -> E$, $E -> A$. Find all candidate keys.
+ For the same relation, find a minimal cover.
+ `BOOKING(hotel_id, room_no, guest_id, checkin, hotel_name, room_type)` with
  `hotel_id` $->$ `hotel_name`, `{hotel_id, room_no}` $->$ `room_type`, and
  `{hotel_id, room_no, checkin}` $->$ `guest_id`. Give the key, the highest normal form,
  and a 3NF decomposition. Check it is lossless.
+ A decomposition of `R(A,B,C)` into `(A,B)` and `(B,C)` is given, with the single FD
  $B -> C$. Is it lossless? Is it dependency preserving?
+ Explain in three lines why a table in 3NF with only one candidate key is automatically
  in BCNF when that key is a single attribute and every FD's left side is that key.
]

#key[
1. `C` is never on a right side $=>$ in every key. $C^+ = C$. Try `AC`: A→B gives B, BC→D
gives D, D→E gives E $=>$ ABCDE ✓. `BC`: BC→D, D→E, E→A $=>$ ABCDE ✓. `CD`: D→E, E→A,
A→B $=>$ ABCDE ✓. `CE`: E→A, A→B, BC→D $=>$ ABCDE ✓. Candidate keys: `AC`, `BC`, `CD`,
`CE`.

2. Split: already single-attribute right sides. Trim left sides: $B C -> D$ — drop `B`?
$C^+ = C$, no `D`. Drop `C`? $B^+ = B$, no `D`. Neither is extraneous. Drop whole FDs:
remove $A -> B$ and $A^+ = A$ — needed. Remove $B C -> D$ and $(B C)^+ = B C$ — needed.
Remove $D -> E$ and $D^+ = D$ — needed. Remove $E -> A$ and $E^+ = E$ — needed.
The set was already minimal: $F_c = {A -> B, " " B C -> D, " " D -> E, " " E -> A}$.

3. `checkin` and `room_no` and `hotel_id` — none is on a right side except through the
listed FDs; the key is `{hotel_id, room_no, checkin}` (its closure gives `guest_id`, then
`hotel_name` and `room_type`). Prime = those three. Now:
`hotel_id` $->$ `hotel_name` — `hotel_id` is a *proper subset* of the key and
`hotel_name` is non-prime $=>$ *partial dependency*. So is
`{hotel_id, room_no}` $->$ `room_type`, for the same reason. 2NF fails on both.
Highest form *1NF*.
Decompose: `HOTEL(hotel_id, hotel_name)`, `ROOM(hotel_id, room_no, room_type)`,
`STAY(hotel_id, room_no, checkin, guest_id)`. Lossless: `STAY` $inter$ `ROOM` =
`{hotel_id, room_no}`, which is the key of `ROOM`; then that result $inter$ `HOTEL` =
`{hotel_id}`, the key of `HOTEL`. ✓ Dependency preserving: each FD sits wholly inside one
fragment. ✓

4. Shared attribute = `{B}`, and $B^+ = {B, C}$, which is exactly `(B,C)`. *Lossless.* ✓
Dependency preserving: the only FD is $B -> C$ and it lives inside `(B,C)`. ✓ Both
properties hold.

5. If every FD's left side is the single candidate key, then every left side is a super
key by definition. BCNF's only requirement is "every determinant is a super key", so it
is satisfied automatically. There is nothing left that 3NF could forgive and BCNF could
not — the two forms coincide.
]

#practice(tier: 3, time: "30 min")[
+ Prove that if a relation has *no* composite candidate key (every candidate key is a
  single attribute), then 2NF holds automatically. Then give a relation with a single
  candidate key that is still not in 3NF.
+ Show a relation in 3NF that is not in BCNF *and* whose BCNF decomposition loses a
  dependency, and explain why no lossless BCNF decomposition of it can preserve that
  dependency.
+ You inherit a table in BCNF that still shows heavy redundancy. Name two distinct causes
  and how you would confirm each.
+ A senior engineer proposes storing `order.total_amount` even though it equals
  `SUM(order_line.qty * order_line.unit_price)`. Argue both sides, then say what you would
  actually do.
]

#key[
1. A 2NF violation requires a non-prime attribute that depends on a *proper subset* of a
candidate key. A single-attribute key `{A}` has exactly one proper subset: the empty set.
An FD $emptyset -> Y$ would mean $Y$ has the same value in every row — a degenerate case
excluded by the definition. So no partial dependency can exist and 2NF holds. ∎
A single-key relation that still fails 3NF: `EMP(emp_id, emp_name, dept_id, dept_name,
dept_head)` from Example 6. Key `{emp_id}`, so 2NF holds — but
`dept_id` $->$ `dept_name` is transitive and 3NF fails.

2. `COACH(student, subject, tutor)` from Example 7. Keys `{student, subject}` and
`{student, tutor}`; all attributes prime, so 3NF holds; `tutor` $->$ `subject` kills BCNF.
Any BCNF decomposition must separate `tutor` from at least one of `student`/`subject` —
because leaving all three together keeps the violation. The FD
`{student, subject}` $->$ `tutor` spans all three attributes, so once they are split
across fragments no single fragment can hold `student`, `subject` *and* `tutor` together
to check it. Hence the loss is structural, not a bad choice of split.

3. *(i) A multivalued dependency* — two independent lists in one table, as in section
6.13. Confirm it by checking whether the row count is the *product* of two independent
sets (2 skills × 3 languages = 6 rows). Fix: 4NF split.
*(ii) Repeated values that are genuinely one fact per row* — e.g. a `city` column on a
million-row table. That is not a normalisation failure at all; it is just a low-cardinality
column. Confirm it by testing whether any FD is violated. If none is, the fix is storage
(a lookup table, dictionary encoding), not normalisation.

4. *For:* the aggregate is read on every order page and on every dashboard; recomputing a
`SUM` per read costs a scan of the line items; the total is also the number the customer
was actually charged.
*Against:* it duplicates derivable data, so it can drift; every write path (add a line,
change a quantity, apply a discount, issue a refund) must remember to update it, and one
missed path corrupts it silently.
*What I would do:* store it, but treat it as a *frozen* fact rather than a cache — the
amount charged at checkout, written once when the order is placed, and never recomputed.
That removes the drift risk entirely, because after checkout the line items are immutable
too. If the lines *can* change, I would keep the total in a generated/computed column or
maintain it in a trigger, and add a nightly reconciliation job that reports mismatches.
]

#pagebreak()
#section[6.20 Rapid fire — 30 one-line answers]

#table(columns: (1fr, 1.35fr), inset: 5pt,
  [*Question*], [*Answer*],
  [What is a functional dependency?], [$X -> Y$: any two rows agreeing on $X$ must agree on $Y$.],
  [Trivial FD?], [One where the right side is a subset of the left. Always true.],
  [Armstrong's three axioms?], [Reflexivity, augmentation, transitivity.],
  [Can you split the left side of an FD?], [No. $A B -> C$ does not give $A -> C$. Only right sides split.],
  [What is $X^+$?], [The set of all attributes $X$ determines. Computed by firing FDs until nothing changes.],
  [How do you test if $X$ is a super key?], [$X^+$ equals all attributes.],
  [How do you test if $X -> Y$ holds?], [Check $Y subset.eq X^+$.],
  [Which attributes are in every candidate key?], [Those that never appear on any right side.],
  [Prime attribute?], [One that appears in at least one candidate key.],
  [1NF?], [Every cell atomic; no repeating groups, no lists.],
  [2NF?], [1NF + no non-prime attribute depends on part of a candidate key.],
  [When is 2NF automatic?], [When every candidate key is a single attribute.],
  [3NF?], [2NF + for every $X -> A$: $X$ is a super key or $A$ is prime.],
  [BCNF?], [Every determinant is a super key. No prime-attribute exception.],
  [3NF vs BCNF in one line?], [BCNF drops 3NF's "right side is prime" escape clause.],
  [When is 3NF automatically satisfied?], [When every attribute is prime.],
  [Partial dependency?], [A non-prime attribute determined by *part* of a composite key.],
  [Transitive dependency?], [key $->$ non-key $->$ another non-key.],
  [Lossless join test for a 2-way split?], [Closure of the shared attributes must cover at least one fragment.],
  [What does a lossy join actually produce?], [*Extra* spurious rows, not missing ones.],
  [Dependency preserving?], [Every original FD can be checked inside one fragment, no join needed.],
  [Which guarantees does 3NF give?], [Lossless *and* dependency preserving, always.],
  [Which guarantee does BCNF lose?], [Dependency preservation. Losslessness is still guaranteed.],
  [Minimal cover — the three steps?], [Split right sides, trim left sides, drop redundant FDs.],
  [Is a minimal cover unique?], [No. Different removal orders give different valid covers.],
  [3NF synthesis, in one line?], [Take the minimal cover, one relation per distinct left side, add a candidate key if none is covered.],
  [BCNF decomposition, in one line?], [For a violating $X -> Y$, replace $R$ with $X^+$ and $X union (R - X^+)$; repeat.],
  [MVD and 4NF?], [$X arrow.double Y$ = two independent lists in one table; 4NF splits them into separate tables.],
  [Why denormalise?], [Fewer joins on a read-heavy workload — paid for with update anomalies you must manage yourself.],
  [How is an M : N relationship mapped?], [A third table holding both foreign keys, keyed on the pair; relationship attributes live there.],
)

#revision[
*FD.* $X -> Y$ = same $X$ forces same $Y$. Comes from business rules, never from sample
rows. Right sides split; left sides never do.

*Armstrong.* Reflexivity, augmentation, transitivity. Derived: union, decomposition,
pseudo-transitivity.

*Closure.* Start with $X$; fire any FD whose left side is inside; repeat until stable.
Super key $<=>$ $X^+$ = everything. $X -> Y$ $<=>$ $Y subset.eq X^+$.

*Candidate keys.* Attributes never on a right side are in *every* key — that is the seed.
Grow the seed one attribute at a time, smallest first, never testing a superset of a key
you already found.

*The ladder.*
1NF atomic $->$ 2NF no partial $->$ 3NF no transitive $->$ BCNF every determinant is a
super key $->$ 4NF no stray MVD.

*Triage a relation in 60 seconds.* Find keys. Mark prime. For each FD: left side a super
key? fine. Else right side all prime? 3NF lives, BCNF dies. Else left side a proper subset
of a key? 2NF dies. Else 3NF dies. Take the worst verdict.

*Shortcuts.* Every attribute prime $=>$ automatically 3NF. Single-attribute key $=>$
automatically 2NF.

*Decomposition.* Lossless: closure of the shared attributes covers one fragment. Lossy
joins *invent* rows. 3NF synthesis: minimal cover, group by left side, add a key if
missing — lossless AND preserving. BCNF: split on $X^+$ and $X union (R - X^+)$ — lossless
but may lose an FD.

*Minimal cover.* Split right sides $->$ trim left sides $->$ drop redundant FDs. Not
unique.

*ER mapping.* 1:N $=>$ FK on the many side. M:N $=>$ third table keyed on the pair.
Multivalued attribute $=>$ its own table. Weak entity $=>$ owner key + partial key, with
`ON DELETE CASCADE`.

*Denormalise* only from a measured read problem, and name who keeps the copy in sync.
A frozen historical value (price at purchase) is not redundancy — it is a different fact.
]

]
