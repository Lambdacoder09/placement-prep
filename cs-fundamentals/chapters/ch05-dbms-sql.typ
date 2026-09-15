#import "../../shared/lib/style.typ": *

#chapter(num: 5, title: "DBMS: Relational Model, Keys & SQL",
  tagline: "Tables, keys, joins, NULLs and window functions — the half of the technical round that is pure vocabulary plus one query.")[

The DBMS round has two halves.

The first half is *vocabulary*. What is a candidate key? What is referential integrity?
What is the difference between `DELETE` and `TRUNCATE`? These are 10-second answers. You
either know them or you do not. There is no thinking time.

The second half is *one query*. The interviewer writes two small tables on the board and
asks for the second-highest salary, or the departments with no employees, or the top earner
per department. You get five minutes.

This chapter gives you both. Every SQL query in this chapter was run against a real
database before it was printed, and the output you see is the real output.

#note[
*How to read this chapter.* Every worked example carries a coloured tier badge — grey for
warm-up mechanics, teal for Tier 1 (TCS NQT, Accenture, Infosys, Wipro, Capgemini), amber
for Tier 2 (Grab, Shopee, GIC, DBS, Agoda, SCB) and dark red for Tier 3 (Google, Amazon,
Microsoft, Goldman Sachs, D. E. Shaw, Adobe). The practice sets at the end climb the same
four steps in order, so do them in order.
]

#formulas(title: "What you need to know")[
*Relational vocabulary*
- *Relation* = table. *Tuple* = row. *Attribute* = column. *Domain* = the set of legal
  values for one attribute.
- *Degree* = number of attributes (columns). *Cardinality* = number of tuples (rows).
- *Schema* = the design (names and types). *Instance* = the rows sitting in it right now.

*Keys*
- *Super key*: any attribute set whose value is different in every row.
- *Candidate key*: a super key with no useless attribute inside it (minimal).
- *Primary key*: the one candidate key you choose. Never `NULL`, never repeated.
- *Alternate key*: every candidate key you did not choose.
- *Foreign key*: an attribute set that must match a primary key somewhere (or be `NULL`).
- If one attribute $A$ is known to be unique in a table of $n$ attributes, the number of
  super keys containing $A$ is $2^(n-1)$.

*Three-valued logic* — SQL has `TRUE`, `FALSE` and `UNKNOWN`.
- Any comparison with `NULL` gives `UNKNOWN`. `NULL = NULL` is `UNKNOWN`, not true.
- `WHERE` keeps only `TRUE`. It throws away `FALSE` *and* `UNKNOWN`.
- Test for null with `IS NULL` / `IS NOT NULL` only.

*Logical order of a `SELECT`* (not the written order):
`FROM`/`JOIN` $->$ `WHERE` $->$ `GROUP BY` $->$ `HAVING` $->$ `SELECT` $->$ `DISTINCT`
$->$ `ORDER BY` $->$ `LIMIT`.

*Relational algebra $->$ SQL*
#table(columns: (auto, auto, auto), inset: 4pt,
  [*Operator*], [*Name*], [*SQL*],
  [$sigma_(c)(R)$], [select (rows)], [`WHERE c`],
  [$pi_(a,b)(R)$], [project (columns)], [`SELECT DISTINCT a, b`],
  [$R times S$], [cartesian product], [`FROM R, S`],
  [$R bowtie.big_(c) S$], [theta join], [`FROM R JOIN S ON c`],
  [$R union S$], [union], [`UNION`],
  [$R inter S$], [intersection], [`INTERSECT`],
  [$R - S$], [difference], [`EXCEPT`],
  [$R div S$], [division], [double `NOT EXISTS`],
)
Relational algebra removes duplicates by definition. SQL does not, unless you say
`DISTINCT` or use `UNION` instead of `UNION ALL`.
]

#section[5.1 The relational model, in one picture]

A relation is a table with rules. The rules are what the interviewer is testing.

#diagram(height: 5.1cm, caption: "Anatomy of a relation. Degree counts columns, cardinality counts rows.")[
  #dnode(5.4cm, 0.4cm, 3.6cm, 0.55cm, "attribute (column)", fill: white)
  #darrow(7.2cm, 1.0cm, 7.2cm, 1.5cm)

  #dnode(3.2cm, 1.55cm, 2.8cm, 0.6cm, "emp_id", fill: rgb("#dbe6ee"))
  #dnode(6.0cm, 1.55cm, 2.8cm, 0.6cm, "emp_name", fill: rgb("#dbe6ee"))
  #dnode(8.8cm, 1.55cm, 2.8cm, 0.6cm, "dept_id", fill: rgb("#dbe6ee"))
  #dnode(11.6cm, 1.55cm, 2.8cm, 0.6cm, "salary", fill: rgb("#dbe6ee"))

  #dnode(3.2cm, 2.15cm, 2.8cm, 0.58cm, "1", fill: white)
  #dnode(6.0cm, 2.15cm, 2.8cm, 0.58cm, "Asha", fill: white)
  #dnode(8.8cm, 2.15cm, 2.8cm, 0.58cm, "10", fill: white)
  #dnode(11.6cm, 2.15cm, 2.8cm, 0.58cm, "90000", fill: white)

  #dnode(3.2cm, 2.73cm, 2.8cm, 0.58cm, "2", fill: rgb("#f5f8fa"))
  #dnode(6.0cm, 2.73cm, 2.8cm, 0.58cm, "Bhavin", fill: rgb("#f5f8fa"))
  #dnode(8.8cm, 2.73cm, 2.8cm, 0.58cm, "10", fill: rgb("#f5f8fa"))
  #dnode(11.6cm, 2.73cm, 2.8cm, 0.58cm, "62000", fill: rgb("#f5f8fa"))

  #dnode(3.2cm, 3.31cm, 2.8cm, 0.58cm, "8", fill: white)
  #dnode(6.0cm, 3.31cm, 2.8cm, 0.58cm, "Hiral", fill: white)
  #dnode(8.8cm, 3.31cm, 2.8cm, 0.58cm, "NULL", fill: white)
  #dnode(11.6cm, 3.31cm, 2.8cm, 0.58cm, "58000", fill: white)

  #dnode(0.1cm, 2.72cm, 2.4cm, 0.6cm, "tuple (row)", fill: white)
  #darrow(2.55cm, 3.02cm, 3.15cm, 3.02cm)

  #dnode(3.2cm, 4.2cm, 5.4cm, 0.65cm, "degree = 4  (four attributes)", fill: rgb("#eef3f7"))
  #dnode(9.0cm, 4.2cm, 5.4cm, 0.65cm, "cardinality = 3  (three tuples)", fill: rgb("#eef3f7"))
]

#subsection[The four rules of a relation]

+ *Every value is atomic.* One cell holds one value. No lists, no "Hindi, English" in a
  single cell. (This is 1NF — Chapter 6.)
+ *No two rows are identical.* A true relation is a *set* of tuples. Real SQL tables
  break this rule if you forget a primary key.
+ *Row order means nothing.* Without `ORDER BY`, the database may hand rows back in any
  order it likes.
+ *Column order means nothing* to the model. Always name your columns; never rely on
  `SELECT *` position.

#trap[
"A table and a relation are the same thing." Almost — but a SQL table *allows duplicate
rows* and *allows nulls*, and a mathematical relation allows neither. Say: "A relation is
a set of tuples; a SQL table is a multiset, so it can hold duplicates unless a key stops
it."
]

#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
A table `Book` has columns `isbn`, `title`, `author`, `price` and holds 500 rows.
State its degree and cardinality.
]
#sol[
Degree counts *columns*: `isbn`, `title`, `author`, `price` $=> 4$.
Cardinality counts *rows* $=> 500$.
#ans[degree 4, cardinality 500]
]

#ex(2, tier: 0, asked: "warm-up")[
`Student(roll, name, email)` has 0 rows. What is its degree and cardinality?
]
#sol[
Degree is a property of the *schema*, so it stays 3 even with no data.
Cardinality is a property of the *instance*, so it is 0.
#ans[degree 3, cardinality 0]
]

#note[
Memory hook: "degree" and "design" both start with *de* — degree comes from the schema.
"Cardinality" and "cards" both start with *card* — cardinality counts the cards (rows) in
the deck right now.
]

#section[5.2 Keys — the whole family]

This is the single most asked DBMS definition set. Learn it as a nesting, not as a list.

#diagram(height: 4.5cm, caption: "Every candidate key is a super key. The primary key is one candidate key you pick; the rest become alternate keys.")[
  #dnode(0.2cm, 0.15cm, 15.4cm, 4.5cm, "", fill: rgb("#f7f7f5"))
  #dnode(0.5cm, 0.35cm, 7.6cm, 0.55cm, "SUPER KEY — any column set that is unique per row", fill: white)

  #dnode(0.8cm, 1.1cm, 14.2cm, 3.35cm, "", fill: rgb("#eef3f7"))
  #dnode(1.1cm, 1.3cm, 7.8cm, 0.55cm, "CANDIDATE KEY — a super key with nothing spare inside", fill: white)

  #dnode(1.3cm, 2.1cm, 6.6cm, 1.0cm, [PRIMARY KEY \ exactly one, never NULL], fill: rgb("#dbe6ee"))
  #dnode(8.4cm, 2.1cm, 6.4cm, 1.0cm, [ALTERNATE KEYS \ all the others], fill: rgb("#dbe6ee"))

  #dnode(1.3cm, 3.3cm, 13.5cm, 0.95cm,
    [`Student(roll, email, aadhaar, name)` — candidates are `roll`, `email`, `aadhaar`. \ Pick `roll` as primary; `email` and `aadhaar` become alternate keys.], fill: white)
]

#subsection[Definitions you must be able to fire back in 10 seconds]

#table(columns: (auto, 1fr), inset: 5pt,
  [*Key*], [*Meaning*],
  [Super key], [Any set of attributes whose combined value never repeats. `{roll}` is one; so is `{roll, name}`; so is every column together.],
  [Candidate key], [A *minimal* super key. Drop any attribute and it stops being unique.],
  [Primary key], [The candidate key the designer chose. Unique + `NOT NULL`. One per table.],
  [Alternate key], [Every candidate key that was not chosen as primary.],
  [Composite key], [A key made of *two or more* attributes, e.g. `{emp_id, proj_id}`.],
  [Foreign key], [An attribute set in table A that must equal some primary key value in table B, or be entirely `NULL`.],
  [Surrogate key], [A meaningless number the system generates (`AUTO_INCREMENT` id). No business meaning, never changes.],
  [Natural key], [A key made of real business data (`email`, `aadhaar`, `isbn`). Meaningful, but can change.],
  [Unique key], [A uniqueness constraint that *does* allow `NULL` (usually many nulls).],
)

#trap[
Three classic mix-ups:
+ "Primary key is the same as unique key." No. Primary key forbids `NULL`; a unique
  constraint normally allows nulls — and in most engines it allows *many* nulls, because
  `NULL != NULL`.
+ "A candidate key must be a single column." No. `{emp_id, proj_id}` in an assignment
  table is a perfectly good candidate key.
+ "A foreign key must point to a different table." No. A self-referencing foreign key
  (`manager_id` $->$ `emp_id`) points at the same table.
]

#subsection[Counting super keys — the exam arithmetic]

If you know that attribute $A$ alone is unique, then *any* set that contains $A$ is also
unique. So count the ways to pick the other attributes.

#ex(3, tier: 1, asked: "TCS NQT · pattern")[
`R(A, B, C, D)` and `A` is a candidate key (the only one). How many super keys does `R`
have?
]
#sol[
Every super key must contain `A`. The remaining attributes are `B`, `C`, `D` — three of
them, and each is independently in or out.

Number of subsets of ${B, C, D}$ is $2^3 = 8$.

List them to be sure: `A`, `AB`, `AC`, `AD`, `ABC`, `ABD`, `ACD`, `ABCD` — 8 sets.
#ans[$2^3 = 8$]
]

#ex(4, tier: 1, asked: "Infosys · pattern")[
`R(P, Q, R, S, T)` has *two* candidate keys: `P` and `Q`. How many super keys?
]
#sol[
A super key is any set that contains `P` *or* contains `Q`. Use complement counting.

Total subsets of 5 attributes $= 2^5 = 32$.

Subsets that contain *neither* `P` nor `Q` = subsets of ${R, S, T}$ $= 2^3 = 8$.

Super keys $= 32 - 8 = 24$.

Check by inclusion–exclusion instead: sets containing `P` $= 2^4 = 16$; containing `Q`
$= 16$; containing both $= 2^3 = 8$. So $16 + 16 - 8 = 24$. Same answer.
#ans[24]
]

#trick[
Two candidate keys $K_1$, $K_2$ made of single attributes, $n$ attributes total:
$ "super keys" = 2^n - 2^(n - 2) $
because the only non-super-keys are the subsets that avoid both key attributes. For
$n=5$: $32 - 8 = 24$. ✓
]

#ex(5, tier: 2, asked: "Shopee · pattern")[
A table `Ride(ride_id, driver_id, rider_id, started_at, fare)` is used by a taxi app.
Business rules: a ride id is globally unique; and a driver cannot start two rides at the
same instant. List the candidate keys.
]
#sol[
*Rule 1* gives `{ride_id}` $->$ everything. `ride_id` is unique, so `{ride_id}` is a
candidate key. Is it minimal? It is one attribute, so yes.

*Rule 2* says `{driver_id, started_at}` never repeats. So it is a super key. Is it
minimal?
- Drop `started_at`: a driver has many rides, so `{driver_id}` is not unique. ✗
- Drop `driver_id`: two drivers can start at the same instant, so `{started_at}` is not
  unique. ✗

Neither half works alone, so `{driver_id, started_at}` is minimal — a candidate key.

`rider_id` and `fare` repeat freely, so they add nothing.
#ans[`{ride_id}` and `{driver_id, started_at}`. Pick `ride_id` as primary; the other is an alternate key.]
]

#note[
Notice how the answer came only from the *business rules*, never from the sample rows.
Sample data can only *disprove* a key ("look, this value repeats"); it can never prove
one. Say this in the interview — it is a mark of someone who has actually designed a
schema.
]

#section[5.3 Integrity constraints]

A constraint is a promise the database enforces for you, so that bad data cannot get in
even if the application has a bug.

#table(columns: (auto, 1fr), inset: 5pt,
  [*Constraint*], [*What it guarantees*],
  [Domain], [Each value belongs to the column's type and `CHECK` rule. `salary INTEGER CHECK (salary > 0)`.],
  [Entity integrity], [No part of a primary key is ever `NULL`. A row must be identifiable.],
  [Referential integrity], [A foreign key value either matches an existing primary key, or is fully `NULL`.],
  [Key], [No two rows share the same value of a `PRIMARY KEY` / `UNIQUE` column set.],
)

#code(lang: "sql", caption: "The schema used for the rest of this chapter — this exact DDL was run")[
```sql
CREATE TABLE department (
  dept_id   INTEGER PRIMARY KEY,
  dept_name TEXT NOT NULL UNIQUE,
  city      TEXT
);

CREATE TABLE employee (
  emp_id     INTEGER PRIMARY KEY,
  emp_name   TEXT NOT NULL,
  dept_id    INTEGER REFERENCES department(dept_id),
  manager_id INTEGER REFERENCES employee(emp_id),   -- self reference
  salary     INTEGER NOT NULL,
  joined_on  TEXT
);

CREATE TABLE project (
  proj_id   INTEGER PRIMARY KEY,
  proj_name TEXT NOT NULL,
  dept_id   INTEGER REFERENCES department(dept_id)
);

CREATE TABLE assignment (
  emp_id  INTEGER REFERENCES employee(emp_id),
  proj_id INTEGER REFERENCES project(proj_id),
  hours   INTEGER,
  PRIMARY KEY (emp_id, proj_id)      -- composite primary key
);
```
]

The rows, once and for all:

#table(columns: (auto, auto, auto, auto, auto, auto), inset: 4.5pt,
  [*emp_id*], [*emp_name*], [*dept_id*], [*manager_id*], [*salary*], [*joined_on*],
  [1], [Asha], [10], [`NULL`], [90000], [2019-03-01],
  [2], [Bhavin], [10], [1], [62000], [2020-07-15],
  [3], [Chetan], [10], [1], [62000], [2021-01-10],
  [4], [Divya], [20], [`NULL`], [78000], [2018-11-05],
  [5], [Eshan], [20], [4], [45000], [2022-02-20],
  [6], [Farida], [30], [4], [52000], [2021-09-01],
  [7], [Gopal], [30], [6], [41000], [2023-04-12],
  [8], [Hiral], [`NULL`], [`NULL`], [58000], [2023-06-01],
)

#table(columns: (auto, auto, auto), inset: 4.5pt,
  [*dept_id*], [*dept_name*], [*city*],
  [10], [Engineering], [Pune],
  [20], [Sales], [Mumbai],
  [30], [Support], [Pune],
  [40], [Research], [Bengaluru],
)

#table(columns: (auto, auto, auto), inset: 4.5pt,
  [*proj_id*], [*proj_name*], [*dept_id*],
  [100], [Atlas], [10],
  [101], [Beacon], [10],
  [102], [Comet], [20],
  [103], [Delta], [40],
)

`assignment(emp_id, proj_id, hours)` holds:
(1,100,120), (2,100,80), (3,101,150), (1,101,40), (4,102,200), (5,102,60), (6,100,30).

#note[
Three deliberate landmines in this data, because interviewers plant exactly these:
*Hiral* has no department (`dept_id` is `NULL`); *Research* (40) has no employees;
*Bhavin* and *Chetan* earn the same salary.
]

#subsection[What happens when a parent row is deleted]

You declare the behaviour on the foreign key:

#table(columns: (auto, 1fr), inset: 5pt,
  [`ON DELETE RESTRICT`], [Refuse the delete while children exist. (`NO ACTION` behaves the same in most engines.)],
  [`ON DELETE CASCADE`], [Delete the children too.],
  [`ON DELETE SET NULL`], [Keep the children, blank out their foreign key. The column must allow `NULL`.],
  [`ON DELETE SET DEFAULT`], [Keep the children, set the FK to the column default.],
)

#ex(6, tier: 1, asked: "Capgemini · pattern")[
Given the two tables below and `ON DELETE CASCADE`, what does `t_emp` hold after
`DELETE FROM t_dept WHERE id = 1;`?

`t_dept`: (1, A), (2, B). `t_emp`: (10, p, 1), (11, q, 1), (12, r, 2).
]
#sol[
`CASCADE` means "delete the children with the parent".

Rows 10 and 11 point at department 1, so both go. Row 12 points at department 2, which
is untouched.

Real output from running it:
#code(lang: "text", caption: "SELECT * FROM t_emp;")[
```text
id  nm  d
--  --  -
12  r   2
```
]
#ans[only `(12, r, 2)` survives]

If the rule had been `SET NULL`, the answer would be (10, p, `NULL`), (11, q, `NULL`),
(12, r, 2). If it had been `RESTRICT`, the `DELETE` itself would fail with a foreign key
error and *nothing* would change.
]

#trap[
*`DELETE` vs `TRUNCATE` vs `DROP`* — asked in almost every service-company round.

#table(columns: (auto, auto, auto, auto), inset: 5pt,
  [], [*DELETE*], [*TRUNCATE*], [*DROP*],
  [Language], [DML], [DDL], [DDL],
  [`WHERE` allowed], [yes], [no], [no],
  [Rolls back], [yes, inside a transaction], [usually no (auto-commits)], [usually no],
  [Fires row triggers], [yes], [no], [no],
  [Table stays], [yes, empty], [yes, empty], [*no — table is gone*],
  [Identity counter], [keeps counting], [usually resets to 1], [gone],
  [Speed on a big table], [slow, row by row + log], [fast, deallocates pages], [fast],
)
One-line answer: "`DELETE` removes rows and can be filtered and rolled back; `TRUNCATE`
empties the whole table fast as a DDL operation; `DROP` removes the table itself,
structure and all."
]

#section[5.4 Relational algebra in ten minutes]

Relational algebra is the maths behind SQL. Interviewers ask it because it proves you
understand *what* a query computes, separately from the syntax.

Every operator takes one or two relations and returns a relation. That is the whole idea
— the output of one operator is the input of the next, so you can chain them.

#subsection[The six basic operators]

#table(columns: (auto, auto, 1fr), inset: 5pt,
  [*Symbol*], [*Name*], [*What it does*],
  [$sigma_(c)(R)$], [selection], [keep the rows where condition $c$ is true. Horizontal cut.],
  [$pi_(a,b)(R)$], [projection], [keep only columns $a$ and $b$, and *remove duplicate rows*. Vertical cut.],
  [$R times S$], [cartesian product], [every row of $R$ paired with every row of $S$. Degree adds, cardinality multiplies.],
  [$R union S$], [union], [all rows of both, duplicates removed. $R$ and $S$ must be union-compatible.],
  [$R - S$], [set difference], [rows in $R$ that are not in $S$.],
  [$rho_(X)(R)$], [rename], [give $R$ (or its columns) a new name — needed for a self join.],
)

*Union-compatible* means: same number of attributes, and matching domains column by
column. `employee` and `department` are not union-compatible; `SELECT dept_id FROM
employee` and `SELECT dept_id FROM department` are.

#subsection[The derived operators]

#table(columns: (auto, auto, 1fr), inset: 5pt,
  [*Symbol*], [*Name*], [*Built from the basics as*],
  [$R inter S$], [intersection], [$R - (R - S)$],
  [$R bowtie.big_(c) S$], [theta join], [$sigma_(c)(R times S)$ — a product followed by a filter],
  [$R bowtie.big S$], [natural join], [join on all same-named columns, then drop the duplicate column],
  [$R arrow.l.tilde S$], [left outer join], [natural join, plus the unmatched $R$ rows padded with nulls],
  [$R div S$], [division], [the $R$ rows that pair with *every* row of $S$],
)

#note[
Degree and cardinality arithmetic, which is a favourite one-mark question:
- $sigma$: degree unchanged, cardinality $<=$ original.
- $pi$ on $k$ columns: degree $= k$, cardinality $<=$ original (duplicates collapse).
- $R times S$: degree $= "deg"(R) + "deg"(S)$, cardinality $= |R| times |S|$.
- $R bowtie.big S$ on one common column: degree $= "deg"(R) + "deg"(S) - 1$; cardinality
  anywhere from $0$ to $|R| times |S|$.
]

#tier-header(1)

#ex(7, tier: 1, asked: "Accenture · pattern")[
$R$ has 5 attributes and 300 rows. $S$ has 4 attributes and 200 rows. They share exactly
one attribute name. Give the degree and cardinality of (a) $R times S$, and (b) the
degree of the natural join $R bowtie.big S$.
]
#sol[
*(a)* A cartesian product pairs everything.
- Degree: $5 + 4 = 9$.
- Cardinality: $300 times 200 = 60000$.

*(b)* A natural join keeps the shared column only once.
- Degree: $5 + 4 - 1 = 8$.
- Cardinality cannot be computed from these numbers alone. It is between 0 (no value
  matches) and 60000 (every value matches everything). If the shared column were the
  primary key of $S$, each $R$ row would match at most one $S$ row, giving at most 300.
#ans[(a) degree 9, cardinality 60000. (b) degree 8, cardinality unknown — between 0 and 60000.]
]

#ex(8, tier: 1, asked: "Cognizant · pattern")[
Write in relational algebra: "the names of employees in Pune departments earning more
than 50000". Then write the SQL.
]
#sol[
Work outside-in, then write it inside-out.

Step 1 — join the two tables on `dept_id`:
$ "employee" bowtie.big "department" $

Step 2 — filter:
$ sigma_("city" = "'Pune'" and "salary" > 50000) ("employee" bowtie.big "department") $

Step 3 — project the one column asked for:
$ pi_("emp_name") ( sigma_("city" = "'Pune'" and "salary" > 50000) ("employee" bowtie.big "department") ) $

SQL:
```sql
SELECT DISTINCT e.emp_name
FROM employee e JOIN department d ON e.dept_id = d.dept_id
WHERE d.city = 'Pune' AND e.salary > 50000;
```
Pune departments are Engineering (10) and Support (30). Over 50000 there: Asha 90000,
Bhavin 62000, Chetan 62000, Farida 52000. Gopal earns 41000 so he is out.
#ans[Asha, Bhavin, Chetan, Farida]

The `DISTINCT` is there because *projection removes duplicates by definition*, while SQL
keeps them. If two employees shared a name, algebra would return one and SQL would
return two.
]

#trick[
Push the selection *inside* the join when you translate:
$sigma_c (R bowtie.big S)$ becomes $sigma_c (R) bowtie.big S$ whenever $c$ only mentions
$R$'s columns. Filtering 300 rows down to 10 before joining is far cheaper than joining
first. This rewrite is called *selection pushdown*, and every real query optimiser does
it. Saying the phrase out loud is worth a mark.
]

#section[5.5 The logical order of a SELECT]

You *write* `SELECT` first. The database *runs* it almost last. Every confusing SQL error
comes from this gap.

#diagram(height: 4.1cm, caption: "The order the database actually evaluates a query in. Follow the arrows, not the text you typed.")[
  #dnode(0.3cm, 0.5cm, 3.3cm, 1.0cm, [1. FROM / JOIN \ build the row pairs])
  #dnode(4.2cm, 0.5cm, 3.3cm, 1.0cm, [2. WHERE \ filter single rows])
  #dnode(8.1cm, 0.5cm, 3.3cm, 1.0cm, [3. GROUP BY \ fold into groups])
  #dnode(12.0cm, 0.5cm, 3.3cm, 1.0cm, [4. HAVING \ filter groups])
  #darrow(3.65cm, 1.0cm, 4.15cm, 1.0cm)
  #darrow(7.55cm, 1.0cm, 8.05cm, 1.0cm)
  #darrow(11.45cm, 1.0cm, 11.95cm, 1.0cm)
  #darrow(13.65cm, 1.55cm, 13.65cm, 2.4cm)

  #dnode(12.0cm, 2.45cm, 3.3cm, 1.0cm, [5. SELECT \ aliases born here], fill: rgb("#dbe6ee"))
  #dnode(8.1cm, 2.45cm, 3.3cm, 1.0cm, [6. DISTINCT \ drop duplicates], fill: rgb("#dbe6ee"))
  #dnode(4.2cm, 2.45cm, 3.3cm, 1.0cm, [7. ORDER BY \ aliases usable], fill: rgb("#dbe6ee"))
  #dnode(0.3cm, 2.45cm, 3.3cm, 1.0cm, [8. LIMIT / OFFSET \ cut the top slice], fill: rgb("#dbe6ee"))
  #darrow(11.95cm, 2.95cm, 11.45cm, 2.95cm)
  #darrow(8.05cm, 2.95cm, 7.55cm, 2.95cm)
  #darrow(4.15cm, 2.95cm, 3.65cm, 2.95cm)
]

Three consequences you can quote directly:

+ *A `SELECT` alias cannot be used in `WHERE`.* `WHERE` runs at step 2; the alias is not
  created until step 5.
+ *A `SELECT` alias CAN be used in `ORDER BY`.* `ORDER BY` runs at step 7, after the
  alias exists.
+ *`WHERE` filters rows, `HAVING` filters groups.* `WHERE` cannot see `COUNT(*)` because
  no group exists yet at step 2.

#ex(9, tier: 1, asked: "Wipro · pattern")[
Why does the first query fail and the second work?
```sql
-- (a)
SELECT salary * 12 AS annual FROM employee WHERE annual > 700000;
-- (b)
SELECT salary * 12 AS annual FROM employee ORDER BY annual DESC;
```
]
#sol[
*(a)* `WHERE` is step 2. At step 2 the only things that exist are the base columns
`emp_id`, `emp_name`, `dept_id`, `manager_id`, `salary`, `joined_on`. The name `annual`
does not exist yet $=>$ "no such column: annual".

Fix: repeat the expression, `WHERE salary * 12 > 700000`, or wrap the query:
```sql
SELECT annual FROM (SELECT salary * 12 AS annual FROM employee) WHERE annual > 700000;
```

*(b)* `ORDER BY` is step 7, which is *after* `SELECT` at step 5. By then `annual` is a
real column of the result, so it sorts fine. Verified output, top two rows:
```text
annual
-------
1080000
936000
```
#ans[(a) the alias does not exist yet at `WHERE` time; (b) it does exist by `ORDER BY` time]
]

#section[5.6 Joins]

A join answers: for each row on the left, which rows on the right go with it?

#diagram(height: 3.5cm, caption: "Which rows survive each join. 'L only' = a left row with no partner; 'R only' = a right row with no partner. Shaded = kept.")[
  #dnode(0.3cm, 0.1cm, 3.6cm, 0.5cm, "INNER JOIN", fill: white)
  #dnode(0.3cm, 0.75cm, 1.1cm, 0.9cm, "L only", fill: rgb("#f2f2f2"))
  #dnode(1.55cm, 0.75cm, 1.1cm, 0.9cm, "match", fill: rgb("#8fb4cc"))
  #dnode(2.8cm, 0.75cm, 1.1cm, 0.9cm, "R only", fill: rgb("#f2f2f2"))

  #dnode(4.3cm, 0.1cm, 3.6cm, 0.5cm, "LEFT JOIN", fill: white)
  #dnode(4.3cm, 0.75cm, 1.1cm, 0.9cm, "L only", fill: rgb("#8fb4cc"))
  #dnode(5.55cm, 0.75cm, 1.1cm, 0.9cm, "match", fill: rgb("#8fb4cc"))
  #dnode(6.8cm, 0.75cm, 1.1cm, 0.9cm, "R only", fill: rgb("#f2f2f2"))

  #dnode(8.3cm, 0.1cm, 3.6cm, 0.5cm, "RIGHT JOIN", fill: white)
  #dnode(8.3cm, 0.75cm, 1.1cm, 0.9cm, "L only", fill: rgb("#f2f2f2"))
  #dnode(9.55cm, 0.75cm, 1.1cm, 0.9cm, "match", fill: rgb("#8fb4cc"))
  #dnode(10.8cm, 0.75cm, 1.1cm, 0.9cm, "R only", fill: rgb("#8fb4cc"))

  #dnode(12.3cm, 0.1cm, 3.6cm, 0.5cm, "FULL OUTER JOIN", fill: white)
  #dnode(12.3cm, 0.75cm, 1.1cm, 0.9cm, "L only", fill: rgb("#8fb4cc"))
  #dnode(13.55cm, 0.75cm, 1.1cm, 0.9cm, "match", fill: rgb("#8fb4cc"))
  #dnode(14.8cm, 0.75cm, 1.1cm, 0.9cm, "R only", fill: rgb("#8fb4cc"))

  #dnode(0.3cm, 1.85cm, 7.6cm, 0.95cm,
    [Unmatched rows that are kept get `NULL` in every column of the missing side.], fill: rgb("#f7f7f5"))
  #dnode(8.3cm, 1.85cm, 7.6cm, 0.95cm,
    [`CROSS JOIN` keeps every pair: 8 employees × 4 departments = 32 rows.], fill: rgb("#f7f7f5"))
]

#subsection[Inner join — only matched rows]

#code(lang: "sql", caption: "Employees with their department name")[
```sql
SELECT e.emp_name, d.dept_name
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;
```
]

Real output — *7 rows, not 8*:
#code(lang: "text", caption: "result")[
```text
emp_name  dept_name
--------  -----------
Asha      Engineering
Bhavin    Engineering
Chetan    Engineering
Divya     Sales
Eshan     Sales
Farida    Support
Gopal     Support
```
]

Hiral is missing. Her `dept_id` is `NULL`, and `NULL = 10` is `UNKNOWN`, never true. So
she matched nothing. Research (40) is missing too — no employee points at it.

#subsection[Left join — keep every left row]

#code(lang: "sql", caption: "Same query, LEFT JOIN")[
```sql
SELECT e.emp_name, d.dept_name
FROM employee e
LEFT JOIN department d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;
```
]

Now 8 rows. The last one is:
#code(lang: "text", caption: "last row of the result")[
```text
Hiral     (blank = NULL)
```
]

#subsection[Anti-join — the "which ones have none?" pattern]

This is asked constantly: *find the departments with no employees.*

#code(lang: "sql", caption: "Anti-join with LEFT JOIN ... IS NULL")[
```sql
SELECT d.dept_name
FROM department d
LEFT JOIN employee e ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;
```
]
Output: `Research`. ✓

Read it slowly: the `LEFT JOIN` keeps every department. A department with no employee
gets `NULL` in all employee columns. `e.emp_id` is the employee primary key, so it can
*only* be `NULL` when the match failed. Filtering on it keeps exactly the unmatched
departments.

#trap[
Test `IS NULL` on a column that can never legitimately be null — a primary key or the
join key. If you write `WHERE e.dept_id IS NULL`, you may also catch real rows that
happen to store a null, and your answer becomes wrong.
]

#subsection[Self join — a table joined to itself]

#code(lang: "sql", caption: "Each employee with their manager's name")[
```sql
SELECT e.emp_name AS emp, m.emp_name AS mgr
FROM employee e
LEFT JOIN employee m ON e.manager_id = m.emp_id
ORDER BY e.emp_id;
```
]
Real output:
#code(lang: "text", caption: "result")[
```text
emp     mgr
------  ------
Asha
Bhavin  Asha
Chetan  Asha
Divya
Eshan   Divya
Farida  Divya
Gopal   Farida
Hiral
```
]
The `LEFT` matters: with a plain `JOIN`, Asha, Divya and Hiral (no manager) would vanish.

#subsection[The LEFT JOIN trap that decides the round]

#ex(10, tier: 2, asked: "Grab · pattern")[
Count employees earning more than 60000 in each department, *including departments where
the count is zero*. Explain the difference between putting the salary test in `ON` and
putting it in `WHERE`.
]
#sol[
*Version A — condition in `ON`:*
```sql
SELECT d.dept_name, COUNT(e.emp_id) AS n
FROM department d
LEFT JOIN employee e ON e.dept_id = d.dept_id AND e.salary > 60000
GROUP BY d.dept_id ORDER BY d.dept_id;
```
Output:
```text
dept_name    n
-----------  -
Engineering  3
Sales        1
Support      0
Research     0
```
(Engineering has three people over 60000: Asha 90000, Bhavin 62000, Chetan 62000.
Sales has one: Divya 78000.)

*Version B — condition in `WHERE`:*
```sql
SELECT d.dept_name, COUNT(e.emp_id) AS n
FROM department d
LEFT JOIN employee e ON e.dept_id = d.dept_id
WHERE e.salary > 60000
GROUP BY d.dept_id ORDER BY d.dept_id;
```
Output:
```text
Engineering  3
Sales        1
```

*Why.* `ON` runs during step 1 — it decides *which rows pair up*, and unmatched left rows
are still padded with `NULL` and kept. `WHERE` runs at step 2, *after* the padding. For
Support and Research the padded row has `e.salary = NULL`, and `NULL > 60000` is
`UNKNOWN`, so `WHERE` throws those rows away — and the zero rows disappear.
#ans[`ON` filters before padding and keeps the zeros; `WHERE` filters after padding and silently turns the `LEFT JOIN` back into an inner join]
]

#trap[
"A `WHERE` clause on the right-hand table of a `LEFT JOIN` cancels the `LEFT`." Learn
this sentence. The only safe `WHERE` test on the right table is `IS NULL` (the anti-join).
]

#subsection[Natural join — why professionals avoid it]

`NATURAL JOIN` joins on *every* column with the same name in both tables, automatically.

Here, `employee` and `department` share `dept_id`, so
`employee NATURAL JOIN department` behaves like the inner join above. But the moment
someone adds a `city` column to `employee`, the natural join silently starts matching on
`dept_id` *and* `city` and your results change with no code edit.

#ans[Say: "`NATURAL JOIN` is convenient but fragile — it depends on column names, so a
schema change can silently alter the result. I always write the `ON` clause."]

#section[5.7 NULL — three-valued logic]

`NULL` is not zero and not an empty string. It means *unknown*.

#table(columns: (auto, auto, auto, auto), inset: 5pt,
  [*Expression*], [*Value*], [*Expression*], [*Value*],
  [`5 = NULL`], [UNKNOWN], [`NULL = NULL`], [UNKNOWN],
  [`5 <> NULL`], [UNKNOWN], [`NULL IS NULL`], [TRUE],
  [`100 + NULL`], [`NULL`], [`'x' || NULL`], [`NULL` (most engines)],
  [`TRUE OR UNKNOWN`], [TRUE], [`FALSE AND UNKNOWN`], [FALSE],
  [`TRUE AND UNKNOWN`], [UNKNOWN], [`NOT UNKNOWN`], [UNKNOWN],
)

Verified: `SELECT 100 + NULL, NULL = NULL, NULL IS NULL, 'x' || NULL;` returns
blank, blank, `1`, blank — that is `NULL`, `NULL`, true, `NULL`.

#subsection[How aggregates treat NULL]

*Every aggregate except `COUNT(*)` ignores nulls.*

#code(lang: "sql", caption: "Run on our employee table")[
```sql
SELECT COUNT(*)              AS c_star,      -- 8
       COUNT(dept_id)        AS c_dept,      -- 7  (Hiral's NULL skipped)
       COUNT(DISTINCT dept_id) AS c_distinct -- 3  (10, 20, 30)
FROM employee;
```
]
Real output: `8  7  3`.

#code(lang: "sql", caption: "AVG divides by the non-null count")[
```sql
SELECT AVG(dept_id), SUM(dept_id), COUNT(*) FROM employee;
-- 18.5714285714286 | 130 | 8
```
]
Check the arithmetic: the 7 non-null values are 10,10,10,20,20,30,30 $=>$ sum $= 130$.
$130 / 7 = 18.571...$ — so `AVG` divided by *7*, not by 8. Confirmed.

#subsection[The `NOT IN` disaster]

#ex(11, tier: 3, asked: "Amazon · pattern")[
These two queries look equivalent. One returns three rows and one returns nothing. Which,
and why?
```sql
-- (a)
SELECT emp_name FROM employee
WHERE dept_id NOT IN (SELECT dept_id FROM employee WHERE manager_id IS NULL);

-- (b)
SELECT e.emp_name FROM employee e
WHERE NOT EXISTS (SELECT 1 FROM employee x
                  WHERE x.manager_id IS NULL AND x.dept_id = e.dept_id);
```
]
#sol[
First work out the subquery. Employees with `manager_id IS NULL` are Asha (dept 10),
Divya (dept 20) and *Hiral (dept `NULL`)*. So the inner list is `(10, 20, NULL)`.

*(a)* SQL expands `x NOT IN (10, 20, NULL)` into
`x <> 10 AND x <> 20 AND x <> NULL`.

Take Farida, `dept_id = 30`:
- `30 <> 10` $->$ TRUE
- `30 <> 20` $->$ TRUE
- `30 <> NULL` $->$ *UNKNOWN*
- `TRUE AND TRUE AND UNKNOWN` $->$ UNKNOWN

`WHERE` keeps only TRUE, so Farida is dropped. The same happens to every row. *(a)
returns zero rows.* Verified — the query printed nothing.

*(b)* `NOT EXISTS` asks a yes/no question: "does a matching row exist?" There is no
three-valued trap, because `EXISTS` is always TRUE or FALSE. Verified output:
```text
Farida
Gopal
Hiral
```
Farida and Gopal are in dept 30, which has no manager-less employee. Hiral has
`dept_id = NULL`, so `x.dept_id = e.dept_id` is never true for her $=>$ `NOT EXISTS` is
true.
#ans[(a) returns nothing because a single `NULL` in the `NOT IN` list makes every comparison UNKNOWN; (b) returns Farida, Gopal, Hiral]

*The fix for (a):* add `AND dept_id IS NOT NULL` inside the subquery, or just use
`NOT EXISTS`. Professionals default to `NOT EXISTS`.
]

#trap[
`IN` with nulls is safe-ish; `NOT IN` with nulls is a bug factory.
`x IN (1, 2, NULL)` is TRUE when `x` is 1 or 2 (because `TRUE OR UNKNOWN = TRUE`).
`x NOT IN (1, 2, NULL)` is *never* TRUE (because `TRUE AND UNKNOWN = UNKNOWN`).
]

#subsection[Useful null tools]

#table(columns: (auto, 1fr), inset: 5pt,
  [`COALESCE(a, b, c)`], [first non-null argument. `COALESCE(dept_id, -1)` gave `-1` for Hiral.],
  [`NULLIF(a, b)`], [`NULL` if `a = b`, else `a`. Guards divide-by-zero: `x / NULLIF(y, 0)`.],
  [`IS DISTINCT FROM`], [null-safe `<>`. `NULL IS DISTINCT FROM NULL` is FALSE. (MySQL: `<=>` is the null-safe `=`.)],
)

#section[5.8 Aggregates, GROUP BY and HAVING]

Rule: *every column in the `SELECT` list must either be inside an aggregate, or be listed
in `GROUP BY`.* A group has many rows; a non-grouped column has no single value to show.

#code(lang: "sql", caption: "Departments with 2 or more people, richest first")[
```sql
SELECT d.dept_name, COUNT(*) AS headcount, AVG(e.salary) AS avg_sal
FROM employee e
JOIN department d ON e.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING COUNT(*) >= 2
ORDER BY avg_sal DESC;
```
]
Real output:
#code(lang: "text", caption: "result")[
```text
dept_name    headcount  avg_sal
-----------  ---------  ----------------
Engineering  3          71333.3333333333
Sales        2          61500.0
Support      2          46500.0
```
]
Check Engineering by hand: $(90000 + 62000 + 62000)/3 = 214000/3 = 71333.33$. ✓
Sales: $(78000+45000)/2 = 61500$. ✓ Support: $(52000+41000)/2 = 46500$. ✓

#subsection[Conditional aggregation — pivot without a PIVOT keyword]

#ex(12, tier: 2, asked: "Agoda · pattern")[
For every department — including empty ones — show how many staff earn at least 60000
("senior") and how many earn less ("junior"), in one row per department.
]
#sol[
Put the `CASE` *inside* the aggregate. That is the whole trick.
```sql
SELECT d.dept_name,
  SUM(CASE WHEN e.salary >= 60000 THEN 1 ELSE 0 END) AS senior,
  SUM(CASE WHEN e.salary <  60000 THEN 1 ELSE 0 END) AS junior
FROM department d
LEFT JOIN employee e ON e.dept_id = d.dept_id
GROUP BY d.dept_id
ORDER BY d.dept_id;
```
Real output:
```text
dept_name    senior  junior
-----------  ------  ------
Engineering  3       0
Sales        1       1
Support      0       2
Research     0       0
```
Research shows 0 and 0 because `LEFT JOIN` kept it, and `SUM` over the single padded
`NULL` row evaluates `CASE WHEN NULL >= 60000` $->$ `UNKNOWN` $->$ `ELSE 0`.
#ans[one `SUM(CASE ...)` per bucket, over a `LEFT JOIN`]
]

#trick[
`COUNT(CASE WHEN c THEN 1 END)` (with *no* `ELSE`) works too — the non-matching rows
become `NULL`, and `COUNT` skips nulls. `SUM(CASE ... ELSE 0 END)` is safer to read aloud
in an interview.
]

#section[5.9 Subqueries]

#table(columns: (auto, 1fr), inset: 5pt,
  [*Kind*], [*Shape and use*],
  [Scalar], [Returns exactly one value. Can sit anywhere a value can: `WHERE salary > (SELECT AVG(salary) FROM employee)`.],
  [Row-list (`IN`)], [Returns one column, many rows. `WHERE dept_id IN (SELECT ...)`.],
  [`EXISTS`], [Returns a yes/no. The database can stop at the first hit.],
  [Correlated], [Mentions a column from the *outer* query, so it is conceptually re-run per outer row.],
  [Derived table], [A subquery in the `FROM` clause. Must be given an alias in most engines.],
  [CTE (`WITH`)], [A named derived table written before the main query. Easier to read, can be reused.],
)

#subsection[Correlated subquery, worked]

#code(lang: "sql", caption: "Employees paid above their OWN department's average")[
```sql
SELECT e.emp_name, e.salary
FROM employee e
WHERE e.salary > (SELECT AVG(x.salary)
                  FROM employee x
                  WHERE x.dept_id = e.dept_id);
```
]
Real output: `Asha 90000`, `Divya 78000`, `Farida 52000`.

Trace it row by row:
- Asha, dept 10: inner average $= 71333.33$. $90000 > 71333.33$ ✓
- Bhavin, dept 10: $62000 > 71333.33$ ✗
- Chetan, dept 10: same ✗
- Divya, dept 20: inner average $= 61500$. $78000 > 61500$ ✓
- Eshan, dept 20: $45000 > 61500$ ✗
- Farida, dept 30: inner average $= 46500$. $52000 > 46500$ ✓
- Gopal, dept 30: $41000 > 46500$ ✗
- Hiral, dept `NULL`: the inner query matches no row, so `AVG` over zero rows is `NULL`,
  and $58000 > "NULL"$ is UNKNOWN ✗

#note[
`e` is the *outer* alias and `x` the *inner* one. The subquery reads `e.dept_id` — that
is what makes it correlated, and that is why it cannot be run once and cached.
]

#subsection[IN vs EXISTS — the standard follow-up]

#table(columns: (auto, auto), inset: 5pt,
  [*`IN (subquery)`*], [*`EXISTS (subquery)`*],
  [Builds the whole inner list, then compares.], [Stops at the first matching row.],
  [Breaks on `NULL` when negated (`NOT IN`).], [Null-safe by construction.],
  [Reads better for a short, fixed list.], [Reads better when the inner query is correlated.],
  [Good when the inner result is small.], [Good when the inner result is large.],
)
Honest modern answer: "On any current optimiser they are usually rewritten to the same
semi-join plan, so performance is rarely the deciding factor. The real difference is
`NOT IN` versus `NOT EXISTS` with nulls — and there `NOT EXISTS` is correct."

#subsection[Division — "did X do ALL of Y?"]

#ex(13, tier: 3, asked: "Google · pattern")[
Find every employee who is assigned to *every* project belonging to department 10.
]
#sol[
Department 10 owns Atlas (100) and Beacon (101). Look at the assignments:
Asha has 100 and 101 ✓; Bhavin has only 100 ✗; Chetan has only 101 ✗; Farida has only
100 ✗.

*Method 1 — double `NOT EXISTS`.* Read it as: "there is no dept-10 project that this
employee is not on."
```sql
SELECT e.emp_name
FROM employee e
WHERE NOT EXISTS (
  SELECT 1 FROM project p
  WHERE p.dept_id = 10
    AND NOT EXISTS (SELECT 1 FROM assignment a
                    WHERE a.emp_id = e.emp_id AND a.proj_id = p.proj_id)
);
```

*Method 2 — count matching.* "This employee touches as many distinct dept-10 projects as
dept 10 has."
```sql
SELECT e.emp_name
FROM employee e
JOIN assignment a ON a.emp_id = e.emp_id
JOIN project p    ON p.proj_id = a.proj_id AND p.dept_id = 10
GROUP BY e.emp_id
HAVING COUNT(DISTINCT p.proj_id) = (SELECT COUNT(*) FROM project WHERE dept_id = 10);
```
Both were run. Both print exactly `Asha`. ✓
#ans[Asha]

Difference worth mentioning: method 1 would also return an employee if department 10 had
*zero* projects (the inner set is empty, so "no project is missing" is vacuously true).
Method 2 would return nobody in that case, because there would be no rows to group.
Say this out loud — it is the follow-up the interviewer is waiting for.
]

#section[5.10 Set operators]

#table(columns: (auto, 1fr), inset: 5pt,
  [`UNION`], [rows of both, *duplicates removed* (a sort or hash is needed — slower)],
  [`UNION ALL`], [rows of both, duplicates kept (fastest — prefer it when you know there are no duplicates)],
  [`INTERSECT`], [rows in both],
  [`EXCEPT` (`MINUS` in Oracle)], [rows in the first and not in the second],
)
Both sides must have the *same number of columns* with *compatible types*. Column names
come from the first `SELECT`.

Verified counts on our data:
#code(lang: "sql", caption: "UNION vs UNION ALL")[
```sql
SELECT COUNT(*) FROM (SELECT dept_id FROM employee UNION     SELECT dept_id FROM department); -- 5
SELECT COUNT(*) FROM (SELECT dept_id FROM employee UNION ALL SELECT dept_id FROM department); -- 12
```
]
`UNION ALL` is $8 + 4 = 12$. `UNION` collapses to the 5 distinct values
${"NULL", 10, 20, 30, 40}$ — note that set operators treat two `NULL`s as *the same*
value, unlike `=`.

#code(lang: "sql", caption: "Departments that exist but employ nobody, via EXCEPT")[
```sql
SELECT dept_id FROM department
EXCEPT
SELECT dept_id FROM employee;   -- 40
```
]
Same answer as the `LEFT JOIN ... IS NULL` anti-join earlier. ✓

#section[5.11 CTEs and recursive queries]

A *common table expression* (CTE) is a named subquery written before the main query with
`WITH`. It does not change what the query computes — it changes how readable it is.

#code(lang: "sql", caption: "The same 'above your department average' query, written with a CTE")[
```sql
WITH dept_avg AS (
  SELECT dept_id, AVG(salary) AS a
  FROM employee
  GROUP BY dept_id
)
SELECT e.emp_name, e.salary, ROUND(d.a, 2) AS dept_avg
FROM employee e
JOIN dept_avg d ON d.dept_id = e.dept_id
WHERE e.salary > d.a;
```
]
Real output:
#code(lang: "text", caption: "result")[
```text
emp_name  salary  dept_avg
--------  ------  --------
Asha      90000   71333.33
Divya     78000   61500.0
Farida    52000   46500.0
```
]
Same three people as the correlated subquery earlier — but now the average is computed
*once per department* instead of conceptually once per row, and a reader can see the
intermediate table.

#subsection[Recursive CTE — walking a hierarchy]

A self-referencing foreign key like `manager_id` builds a tree. A plain self join only
reaches *one* level. To reach the whole subtree you need recursion.

The shape is always the same:

#table(columns: (auto, 1fr), inset: 5pt,
  [*Anchor*], [The starting row (or rows). Runs once.],
  [`UNION ALL`], [Always `UNION ALL`, not `UNION` — see the trap below.],
  [*Recursive part*], [Joins the table back to the CTE's own name. Runs again and again on the rows produced last time.],
  [*Stop*], [Automatic: it stops when a round produces zero new rows.],
)

#code(lang: "sql", caption: "Everyone under Divya, at any depth")[
```sql
WITH RECURSIVE chain(emp_id, emp_name, lvl) AS (
    SELECT emp_id, emp_name, 0
    FROM employee
    WHERE emp_name = 'Divya'              -- anchor: the root
  UNION ALL
    SELECT e.emp_id, e.emp_name, c.lvl + 1
    FROM employee e
    JOIN chain c ON e.manager_id = c.emp_id   -- recursive step
)
SELECT lvl, emp_id, emp_name FROM chain ORDER BY lvl, emp_id;
```
]
Real output:
#code(lang: "text", caption: "result")[
```text
lvl  emp_id  emp_name
---  ------  --------
0    4       Divya
1    5       Eshan
1    6       Farida
2    7       Gopal
```
]

Trace the rounds:
- *Round 0 (anchor):* Divya, level 0.
- *Round 1:* who reports to emp_id 4? Eshan (5) and Farida (6). Level 1.
- *Round 2:* who reports to 5 or 6? Gopal reports to 6. Level 2.
- *Round 3:* who reports to 7? Nobody. Zero new rows $=>$ stop.

#trap[
Two recursive-CTE traps:
+ *`UNION` instead of `UNION ALL`.* `UNION` de-duplicates every round, which is slower and
  can hide a genuine cycle instead of exposing it.
+ *A cycle in the data* (A manages B, B manages A) makes the query run forever. Guard it
  by carrying the path and checking it, or by adding `WHERE lvl < 20`. Real engines
  usually have a recursion-depth setting; SQL Server's default limit is 100 levels.
]

#ex(14, tier: 2, asked: "Sea/Shopee · pattern")[
Generate the numbers 1 to 5 with no table at all, then explain one practical use.
]
#sol[
```sql
WITH RECURSIVE n(k) AS (
    SELECT 1
  UNION ALL
    SELECT k + 1 FROM n WHERE k < 5
)
SELECT group_concat(k) FROM n;
```
Real output: `1,2,3,4,5`.

*Practical use:* generating a complete calendar. Reports must show *every* day of a month,
including days with zero orders. A `GROUP BY order_date` can only show days that have
rows. So you generate the dates recursively and `LEFT JOIN` the orders onto them — the
zero days survive as `NULL`, and `COALESCE(SUM(amount), 0)` turns them into 0.
#ans[a recursive CTE with no `FROM` table is a number/date generator, used to fill gaps a `GROUP BY` cannot]
]

#note[
Handy aggregate for interviews: `GROUP_CONCAT` (SQLite/MySQL) or `STRING_AGG`
(PostgreSQL/SQL Server) glues a group's values into one string.
`SELECT d.dept_name, GROUP_CONCAT(e.emp_name, ', ') FROM department d LEFT JOIN employee
e ON e.dept_id = d.dept_id GROUP BY d.dept_id;` really prints
`Engineering | Asha, Bhavin, Chetan` and `Research | ` (empty).
]

#section[5.12 Window functions]

A `GROUP BY` *collapses* rows. A window function *keeps every row* and adds a computed
column that looked at a group of neighbours.

#diagram(height: 5.1cm, caption: "PARTITION BY splits the rows into independent windows; ORDER BY sets the order inside each one; the frame is the slice the function actually reads.")[
  #dnode(3.0cm, 0.15cm, 1.9cm, 0.55cm, "dept_id", fill: rgb("#dbe6ee"))
  #dnode(4.9cm, 0.15cm, 2.6cm, 0.55cm, "emp_name", fill: rgb("#dbe6ee"))
  #dnode(7.5cm, 0.15cm, 2.0cm, 0.55cm, "salary", fill: rgb("#dbe6ee"))
  #dnode(9.5cm, 0.15cm, 2.9cm, 0.55cm, "ROW_NUMBER()", fill: rgb("#dbe6ee"))
  #dnode(3.0cm, 0.8cm, 1.9cm, 0.55cm, "10", fill: white)
  #dnode(4.9cm, 0.8cm, 2.6cm, 0.55cm, "Asha", fill: white)
  #dnode(7.5cm, 0.8cm, 2.0cm, 0.55cm, "90000", fill: white)
  #dnode(9.5cm, 0.8cm, 2.9cm, 0.55cm, "1", fill: white)
  #dnode(3.0cm, 1.35cm, 1.9cm, 0.55cm, "10", fill: rgb("#f5f8fa"))
  #dnode(4.9cm, 1.35cm, 2.6cm, 0.55cm, "Bhavin", fill: rgb("#f5f8fa"))
  #dnode(7.5cm, 1.35cm, 2.0cm, 0.55cm, "62000", fill: rgb("#f5f8fa"))
  #dnode(9.5cm, 1.35cm, 2.9cm, 0.55cm, "2", fill: rgb("#f5f8fa"))
  #dnode(3.0cm, 1.9cm, 1.9cm, 0.55cm, "10", fill: white)
  #dnode(4.9cm, 1.9cm, 2.6cm, 0.55cm, "Chetan", fill: white)
  #dnode(7.5cm, 1.9cm, 2.0cm, 0.55cm, "62000", fill: white)
  #dnode(9.5cm, 1.9cm, 2.9cm, 0.55cm, "3", fill: white)
  #dnode(3.0cm, 2.55cm, 1.9cm, 0.55cm, "20", fill: white)
  #dnode(4.9cm, 2.55cm, 2.6cm, 0.55cm, "Divya", fill: white)
  #dnode(7.5cm, 2.55cm, 2.0cm, 0.55cm, "78000", fill: white)
  #dnode(9.5cm, 2.55cm, 2.9cm, 0.55cm, "1", fill: white)
  #dnode(3.0cm, 3.1cm, 1.9cm, 0.55cm, "20", fill: rgb("#f5f8fa"))
  #dnode(4.9cm, 3.1cm, 2.6cm, 0.55cm, "Eshan", fill: rgb("#f5f8fa"))
  #dnode(7.5cm, 3.1cm, 2.0cm, 0.55cm, "45000", fill: rgb("#f5f8fa"))
  #dnode(9.5cm, 3.1cm, 2.9cm, 0.55cm, "2", fill: rgb("#f5f8fa"))

  #dnode(0.2cm, 0.8cm, 2.6cm, 1.65cm, [PARTITION \ dept_id = 10], fill: rgb("#eef3f7"))
  #dnode(0.2cm, 2.55cm, 2.6cm, 1.1cm, [PARTITION \ dept_id = 20], fill: rgb("#eef3f7"))

  #dnode(12.85cm, 0.6cm, 3.0cm, 0.95cm, [frame of a running SUM: \ every row up to here], fill: white)
  #darrow(12.7cm, 1.65cm, 12.7cm, 2.4cm)

  #dnode(0.2cm, 4.0cm, 15.6cm, 0.9cm,
    [Counter restarts at 1 in every partition — the numbering never crosses a partition boundary.],
    fill: rgb("#f7f7f5"))
]

#subsection[The three ranking functions]

#code(lang: "sql", caption: "ROW_NUMBER vs RANK vs DENSE_RANK on the same data")[
```sql
SELECT emp_name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn,
       RANK()       OVER (ORDER BY salary DESC) AS rk,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS dr
FROM employee;
```
]
Real output:
#code(lang: "text", caption: "result")[
```text
emp_name  salary  rn  rk  dr
--------  ------  --  --  --
Asha      90000   1   1   1
Divya     78000   2   2   2
Bhavin    62000   3   3   3
Chetan    62000   4   3   3
Hiral     58000   5   5   4
Farida    52000   6   6   5
Eshan     45000   7   7   6
Gopal     41000   8   8   7
```
]
Watch the tie at 62000 and the row right after it:

#table(columns: (auto, 1fr), inset: 5pt,
  [`ROW_NUMBER`], [always 1, 2, 3, 4, ... — ties get *different* numbers, decided arbitrarily unless you add a tie-breaker to `ORDER BY`.],
  [`RANK`], [ties share a rank, then the next value *skips*: 3, 3, then *5*.],
  [`DENSE_RANK`], [ties share a rank, and the next value does *not* skip: 3, 3, then *4*.],
)

#trap[
"`ROW_NUMBER` is deterministic." It is not, when the `ORDER BY` has ties. Bhavin and
Chetan both earn 62000; which one gets `rn = 3` is up to the engine. Always add a unique
tie-breaker: `ORDER BY salary DESC, emp_id`.
]

#subsection[Top-N per group — the pattern you will be asked for]

#ex(15, tier: 2, asked: "DBS · pattern")[
Show the highest-paid employee in each department.
]
#sol[
Number the rows *inside* each department, then keep number 1.
```sql
SELECT dept_name, emp_name, salary
FROM (
  SELECT d.dept_name, e.emp_name, e.salary,
         ROW_NUMBER() OVER (PARTITION BY e.dept_id
                            ORDER BY e.salary DESC, e.emp_id) AS rn
  FROM employee e
  JOIN department d ON e.dept_id = d.dept_id
) t
WHERE rn = 1;
```
Real output:
```text
Engineering  Asha    90000
Sales        Divya   78000
Support      Farida  52000
```
#ans[`ROW_NUMBER() OVER (PARTITION BY group ORDER BY metric DESC)` then filter `= 1`]

Two follow-ups to have ready:
- *"What if two people tie for top?"* `ROW_NUMBER` picks one; switch to `RANK() = 1` or
  `DENSE_RANK() = 1` to return all of them.
- *"Why the subquery?"* Window functions are computed at step 5 (`SELECT`), which is
  after `WHERE` at step 2. So you cannot write `WHERE rn = 1` in the same block — you
  must wrap it in a derived table or a CTE.
]

#subsection[Running total and LAG]

#code(lang: "sql", caption: "Cumulative salary cost as people joined")[
```sql
SELECT emp_name, joined_on, salary,
       SUM(salary) OVER (ORDER BY joined_on
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running
FROM employee
ORDER BY joined_on;
```
]
Real output:
#code(lang: "text", caption: "result")[
```text
emp_name  joined_on   salary  running
--------  ----------  ------  -------
Divya     2018-11-05  78000   78000
Asha      2019-03-01  90000   168000
Bhavin    2020-07-15  62000   230000
Chetan    2021-01-10  62000   292000
Farida    2021-09-01  52000   344000
Eshan     2022-02-20  45000   389000
Gopal     2023-04-12  41000   430000
Hiral     2023-06-01  58000   488000
```
]
Verify two of them by hand: $78000 + 90000 = 168000$ ✓ and
$430000 + 58000 = 488000$ ✓. The last running value equals the total payroll.

`LAG(col)` reads the previous row, `LEAD(col)` the next one:
#code(lang: "sql", caption: "Gap to the next-lower salary")[
```sql
SELECT emp_name, salary,
       LAG(salary) OVER (ORDER BY salary) AS prev,
       salary - LAG(salary) OVER (ORDER BY salary) AS gap
FROM employee;
```
]
The first row's `prev` is `NULL` (no previous row), so its `gap` is `NULL` too. Chetan's
gap is `0` — he ties with Bhavin. Both verified in the real output.

#subsection[Nth highest salary — three correct answers]

#ex(16, tier: 1, asked: "TCS NQT · pattern")[
Return the 3rd highest *distinct* salary.
]
#sol[
The distinct salaries, sorted down: 90000, 78000, 62000, 58000, 52000, 45000, 41000.
The 3rd is *62000*.

*Method A — `LIMIT` / `OFFSET` (simplest):*
```sql
SELECT DISTINCT salary FROM employee ORDER BY salary DESC LIMIT 1 OFFSET 2;
```
For the $N$th, use `OFFSET N-1`. Here $N = 3$ so `OFFSET 2`.

*Method B — `DENSE_RANK` (works on any engine with windows, and reads best):*
```sql
SELECT salary FROM (
  SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS dr FROM employee
) WHERE dr = 3 LIMIT 1;
```
`DENSE_RANK`, not `RANK` — with `RANK` a tie would make rank 3 disappear.

*Method C — correlated count (no window functions, works on very old engines):*
```sql
SELECT e.salary FROM employee e
WHERE 3 = (SELECT COUNT(DISTINCT x.salary) FROM employee x WHERE x.salary >= e.salary)
LIMIT 1;
```
Read it: "exactly 3 distinct salaries are greater than or equal to mine."

All three were run. All three print `62000`. ✓
#ans[62000]

Follow-up to volunteer: "If fewer than $N$ distinct salaries exist, A and B return no
rows, which is usually what you want. If the interviewer wants `NULL` instead, wrap it:
`SELECT (SELECT ... ) AS nth;`"
]

#section[5.13 What a join actually does — in JavaScript]

The interviewer sometimes asks "how is a join implemented?" Here are the two answers,
written as runnable code so you can see them.

#code(lang: "js", caption: "join.js — run with: node join.js")[
```js
const employee = [
  { emp_id: 1, name: 'Asha',   dept_id: 10 },
  { emp_id: 2, name: 'Bhavin', dept_id: 10 },
  { emp_id: 4, name: 'Divya',  dept_id: 20 },
  { emp_id: 8, name: 'Hiral',  dept_id: null },
];
const department = [
  { dept_id: 10, dept_name: 'Engineering' },
  { dept_id: 20, dept_name: 'Sales' },
  { dept_id: 40, dept_name: 'Research' },
];

// 1. NESTED LOOP JOIN - compare every pair. Cost = |E| x |D|.
function nestedLoopInner(left, right) {
  const out = [];
  let comparisons = 0;
  for (const e of left) {
    for (const d of right) {
      comparisons++;
      if (e.dept_id === d.dept_id) out.push({ name: e.name, dept: d.dept_name });
    }
  }
  return { out, comparisons };
}

// 2. HASH JOIN - build a Map on the smaller side, then probe once per row.
function hashInner(left, right) {
  const bucket = new Map();
  for (const d of right) bucket.set(d.dept_id, d);
  const out = [];
  for (const e of left) {
    const d = bucket.get(e.dept_id);
    if (d) out.push({ name: e.name, dept: d.dept_name });
  }
  return { out, comparisons: right.length + left.length };
}

// 3. LEFT JOIN - keep the left row even with no match, pad with null.
function hashLeft(left, right) {
  const bucket = new Map();
  for (const d of right) bucket.set(d.dept_id, d);
  return left.map(e => ({ name: e.name, dept: bucket.get(e.dept_id)?.dept_name ?? null }));
}

console.log('nested loop:', nestedLoopInner(employee, department).comparisons, 'comparisons');
console.log('hash join  :', hashInner(employee, department).comparisons, 'comparisons');
console.log('left join  :', JSON.stringify(hashLeft(employee, department)));
```
]
Actual output from `node`:
#code(lang: "text", caption: "terminal")[
```text
nested loop: 12 comparisons
hash join  : 7 comparisons
left join  : [{"name":"Asha","dept":"Engineering"},{"name":"Bhavin","dept":"Engineering"},
              {"name":"Divya","dept":"Sales"},{"name":"Hiral","dept":null}]
```
]

#complexity(time: "nested loop O(n·m), hash join O(n+m) average", space: "nested loop O(1) extra, hash join O(m) for the hash table",
  note: "A third strategy, merge join, sorts both sides first: O(n log n + m log m), then one linear pass. The optimiser picks whichever is cheapest for the sizes and indexes it has.")

#trap[
JavaScript trap hiding in the code above: `bucket.get(null)` returns the department
object only if some department really had `dept_id === null`. Using a plain object
instead of a `Map` would stringify the key — `obj[null]` becomes `obj["null"]` and
`obj[10]` becomes `obj["10"]`, so the number 10 and the string `"10"` would collide.
`Map` keeps the key's type. This is exactly why the language policy says use `Map`.
]

#pagebreak()
#section[5.14 Practice]

#practice(tier: 0, time: "6 min")[
+ Give the degree and cardinality of `department` in this chapter.
+ Is `{emp_id, emp_name}` a super key of `employee`? Is it a candidate key?
+ How many rows does `SELECT * FROM employee, department;` return?
+ Write the query for all employees whose name starts with the letter B.
+ What does `SELECT COUNT(manager_id) FROM employee;` return, and why is it not 8?
+ Which is DDL and which is DML: `TRUNCATE`, `UPDATE`, `ALTER`, `INSERT`?
]

#key[
1. Degree 3, cardinality 4. — 2. Super key yes (it contains `emp_id`); candidate key no,
because `emp_name` is spare. — 3. $8 times 4 = 32$. —
4. `SELECT * FROM employee WHERE emp_name LIKE 'B%';` —
5. `5`. `COUNT(col)` skips nulls, and Asha, Divya and Hiral have `manager_id NULL`
($8 - 3 = 5$). — 6. DDL: `TRUNCATE`, `ALTER`. DML: `UPDATE`, `INSERT`.
]

#practice(tier: 1, time: "12 min")[
+ `R(A,B,C,D,E)` has exactly one candidate key, `{A,B}`. How many super keys?
+ Write a query listing every department name together with its headcount, showing 0 for
  empty departments.
+ Write a query for the employees who are nobody's manager.
+ What is printed by `SELECT 10 + NULL;` and by `SELECT COUNT(*) FROM employee WHERE dept_id <> 10;`?
+ Write a query for the second-lowest salary in the table.
+ A table `orders(order_id, customer_id, amount)` — write the query for customers whose
  total order amount is above 5000, highest total first.
]

#key[
1. Every super key must contain both `A` and `B`; the other three attributes are free, so
$2^3 = 8$.

2. `SELECT d.dept_name, COUNT(e.emp_id) FROM department d LEFT JOIN employee e ON e.dept_id = d.dept_id GROUP BY d.dept_id;`
Use `COUNT(e.emp_id)`, not `COUNT(*)` — `COUNT(*)` would count the padded row and print 1
for an empty department.

3. `SELECT emp_name FROM employee e WHERE NOT EXISTS (SELECT 1 FROM employee m WHERE m.manager_id = e.emp_id);`
That is Bhavin, Chetan, Eshan, Gopal, Hiral.

4. `NULL`. And `4` — the rows with `dept_id` 20, 20, 30, 30. Hiral's `NULL <> 10` is
UNKNOWN, so she is excluded even though "her department is not 10" feels true.

5. `SELECT DISTINCT salary FROM employee ORDER BY salary ASC LIMIT 1 OFFSET 1;` $=>$ 45000.

6. `SELECT customer_id, SUM(amount) AS total FROM orders GROUP BY customer_id HAVING SUM(amount) > 5000 ORDER BY total DESC;`
The filter must be `HAVING`, not `WHERE`, because it tests an aggregate.
]

#practice(tier: 2, time: "18 min")[
+ For each project, show the project name and the total hours booked on it, including
  projects with no assignments at all.
+ Using the `employee` table, show each employee's salary and the average salary of their
  department *side by side on the same row*, without a `GROUP BY`.
+ A food-delivery table `orders(order_id, city, placed_at, amount)` — write the query for
  the top 2 orders by amount in each city.
+ Explain in three lines what happens if you write
  `SELECT dept_id, emp_name, COUNT(*) FROM employee GROUP BY dept_id;`
+ Rewrite `WHERE dept_id NOT IN (SELECT dept_id FROM department WHERE city = 'Pune')` so
  that it is safe when `department.dept_id` can be `NULL`.
]

#key[
1. `SELECT p.proj_name, COALESCE(SUM(a.hours), 0) AS total FROM project p LEFT JOIN assignment a ON a.proj_id = p.proj_id GROUP BY p.proj_id;`
Delta gets 0 thanks to `COALESCE`; without it you would print `NULL`.
Atlas $= 120+80+30 = 230$, Beacon $= 150+40 = 190$, Comet $= 200+60 = 260$, Delta $= 0$.

2. A window aggregate: `SELECT emp_name, salary, AVG(salary) OVER (PARTITION BY dept_id) AS dept_avg FROM employee;`
This is the cleanest demonstration that a window function keeps all 8 rows while
`GROUP BY` would collapse them to 3.

3. ```sql
SELECT city, order_id, amount FROM (
  SELECT city, order_id, amount,
         ROW_NUMBER() OVER (PARTITION BY city ORDER BY amount DESC, order_id) AS rn
  FROM orders) t
WHERE rn <= 2;
```

4. `emp_name` is neither aggregated nor in the `GROUP BY`. Strict engines (PostgreSQL,
SQL Server, MySQL with `ONLY_FULL_GROUP_BY`) reject it. Lenient ones (SQLite, older
MySQL) return *some arbitrary* name from each group — which is worse, because the query
runs and quietly gives a different answer each time.

5. `WHERE NOT EXISTS (SELECT 1 FROM department d WHERE d.city = 'Pune' AND d.dept_id = employee.dept_id)`.
Or keep `NOT IN` but add `AND dept_id IS NOT NULL` inside the subquery.
]

#practice(tier: 3, time: "25 min")[
+ Write one query that returns, for each department, the name of the highest earner *and*
  the name of the lowest earner, on a single row. Empty departments should still appear.
+ `login(user_id, login_date)` records one row per login per day. Write a query for the
  users who logged in on at least 3 *consecutive* days.
+ Explain precisely why `SELECT COUNT(*) FROM a LEFT JOIN b ON a.k = b.k;` can be larger
  than `SELECT COUNT(*) FROM a;` even though a left join "keeps every row of a".
+ You are told a query returns the right rows but the interviewer asks you to remove the
  `DISTINCT`. What structural change to the query usually makes `DISTINCT` unnecessary?
]

#key[
1. ```sql
WITH ranked AS (
  SELECT e.dept_id, e.emp_name, e.salary,
         ROW_NUMBER() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC, e.emp_id) AS hi,
         ROW_NUMBER() OVER (PARTITION BY e.dept_id ORDER BY e.salary ASC,  e.emp_id) AS lo
  FROM employee e)
SELECT d.dept_name,
       MAX(CASE WHEN r.hi = 1 THEN r.emp_name END) AS top_earner,
       MAX(CASE WHEN r.lo = 1 THEN r.emp_name END) AS low_earner
FROM department d LEFT JOIN ranked r ON r.dept_id = d.dept_id
GROUP BY d.dept_id;
```
Two window functions over the same partition, then conditional aggregation to fold the
two marked rows into one. On our data: Engineering (Asha, Bhavin — Bhavin wins the tie on
`emp_id`), Sales (Divya, Eshan), Support (Farida, Gopal), Research (`NULL`, `NULL`).

2. The *gaps-and-islands* pattern. Subtract the row number from the date; inside a run of
consecutive days that difference is constant, so it becomes a group key.
```sql
WITH d AS (
  SELECT user_id, login_date,
         DATE(login_date, '-' || ROW_NUMBER() OVER (PARTITION BY user_id
                                                   ORDER BY login_date) || ' day') AS grp
  FROM (SELECT DISTINCT user_id, login_date FROM login))
SELECT user_id FROM d GROUP BY user_id, grp HAVING COUNT(*) >= 3;
```
The `DISTINCT` guards against two logins recorded on the same date. (The date arithmetic
above is SQLite syntax; PostgreSQL would use `login_date - rn * INTERVAL '1 day'`.)

3. "Keeps every row of `a`" means every row of `a` appears *at least* once, not exactly
once. If one `a` row matches three `b` rows, it appears three times. The count grows
whenever `b.k` is not unique. This is the single most common cause of an inflated `SUM`
after a join — and the reason people reach for `DISTINCT` instead of fixing the join.

4. Replace the join-that-only-tests-existence with `EXISTS`. A join to a non-unique table
multiplies rows and forces `DISTINCT`; `WHERE EXISTS (...)` tests membership without
duplicating anything, so the `DISTINCT` disappears and the plan usually gets cheaper too.
]

#pagebreak()
#section[5.15 Rapid fire — 28 one-line answers]

#table(columns: (1fr, 1.35fr), inset: 5pt,
  [*Question*], [*Answer*],
  [Degree vs cardinality?], [Degree = number of columns; cardinality = number of rows.],
  [Super key vs candidate key?], [Candidate key is a super key with no spare attribute — remove anything and uniqueness breaks.],
  [Can a primary key be `NULL`?], [No. Entity integrity forbids it, even in one column of a composite key.],
  [Can a unique key be `NULL`?], [Yes, and most engines allow many nulls, because `NULL != NULL`.],
  [What is referential integrity?], [Every foreign key value matches an existing primary key, or is entirely `NULL`.],
  [Foreign key to the same table?], [Allowed — e.g. `manager_id` referencing `emp_id`.],
  [Surrogate vs natural key?], [Surrogate = generated meaningless id, never changes. Natural = real business data, can change.],
  [`DELETE` vs `TRUNCATE`?], [`DELETE` is DML, filterable, rollback-able, fires triggers. `TRUNCATE` is DDL, all rows, fast, usually no rollback.],
  [`TRUNCATE` vs `DROP`?], [`TRUNCATE` empties the table; `DROP` removes the table itself.],
  [DDL / DML / DCL / TCL?], [DDL `CREATE ALTER DROP TRUNCATE`; DML `SELECT INSERT UPDATE DELETE`; DCL `GRANT REVOKE`; TCL `COMMIT ROLLBACK SAVEPOINT`.],
  [Logical order of a `SELECT`?], [`FROM`, `WHERE`, `GROUP BY`, `HAVING`, `SELECT`, `DISTINCT`, `ORDER BY`, `LIMIT`.],
  [Why can't an alias be used in `WHERE`?], [`WHERE` runs before `SELECT`, so the alias does not exist yet.],
  [`WHERE` vs `HAVING`?], [`WHERE` filters rows before grouping; `HAVING` filters groups after, and may use aggregates.],
  [`COUNT(*)` vs `COUNT(col)`?], [`COUNT(*)` counts rows; `COUNT(col)` skips nulls in that column.],
  [Result of `NULL = NULL`?], [`UNKNOWN`. Use `IS NULL`.],
  [Why does `NOT IN` break with nulls?], [It expands to a chain of `AND`s; one `UNKNOWN` makes the whole condition `UNKNOWN`, so no row passes.],
  [Safest replacement for `NOT IN`?], [`NOT EXISTS` — it returns only true or false.],
  [Inner vs left join?], [Inner keeps matched rows only; left keeps every left row, padding with `NULL`.],
  [Rows in a cross join?], [$m times n$ — every pair.],
  [Why avoid `NATURAL JOIN`?], [It matches on every same-named column, so adding a column silently changes the result.],
  [How do you find rows with no match?], [Anti-join: `LEFT JOIN` then `WHERE right_pk IS NULL`, or `NOT EXISTS`.],
  [What kills a `LEFT JOIN`?], [A `WHERE` condition on a right-table column — it drops the padded rows and turns it into an inner join.],
  [Correlated subquery?], [A subquery that references a column of the outer query, so it is evaluated per outer row.],
  [`UNION` vs `UNION ALL`?], [`UNION` removes duplicates (needs a sort or hash); `UNION ALL` keeps them and is faster.],
  [`RANK` vs `DENSE_RANK`?], [After a tie, `RANK` skips numbers (3,3,5); `DENSE_RANK` does not (3,3,4).],
  [`GROUP BY` vs a window function?], [`GROUP BY` collapses rows into one per group; a window function keeps all rows and adds a column.],
  [Why wrap `ROW_NUMBER` in a subquery?], [Window functions are computed after `WHERE`, so you cannot filter on them in the same block.],
  [Nth highest salary, one line?], [`SELECT DISTINCT salary FROM t ORDER BY salary DESC LIMIT 1 OFFSET N-1;`],
)

#revision[
*Keys.* Super key $supset.eq$ candidate key $supset.eq$ primary key. Candidate = minimal.
Primary = chosen + `NOT NULL`. Alternate = the rest. If one attribute is unique in an
$n$-column table, it sits in $2^(n-1)$ super keys. Two single-attribute keys give
$2^n - 2^(n-2)$.

*Constraints.* Domain (`CHECK`), entity (PK not null), referential (FK matches or is
null), key (uniqueness). FK delete rules: `RESTRICT` / `CASCADE` / `SET NULL` /
`SET DEFAULT`.

*`DELETE` / `TRUNCATE` / `DROP`.* Rows + filter + rollback / all rows fast, DDL / table
gone.

*Order.* `FROM` $->$ `WHERE` $->$ `GROUP BY` $->$ `HAVING` $->$ `SELECT` $->$ `DISTINCT`
$->$ `ORDER BY` $->$ `LIMIT`. Aliases are born at `SELECT`, so `WHERE` cannot see them and
`ORDER BY` can.

*NULL.* Unknown, not zero. Any comparison gives `UNKNOWN`; `WHERE` keeps only `TRUE`.
Aggregates except `COUNT(*)` skip nulls. `NOT IN` + `NULL` = zero rows. Use `NOT EXISTS`.

*Joins.* Inner = matches. Left = all of left + padding. Anti-join = `LEFT JOIN` +
`WHERE right_pk IS NULL`. A `WHERE` on the right table cancels the `LEFT`. Cross =
$m times n$. Self-join for hierarchies.

*Grouping.* Every selected column must be aggregated or grouped. `WHERE` before,
`HAVING` after. `SUM(CASE WHEN ... THEN 1 ELSE 0 END)` pivots without a `PIVOT` keyword.

*Windows.* `OVER (PARTITION BY g ORDER BY c)`. `ROW_NUMBER` = 1,2,3,4. `RANK` = 3,3,5.
`DENSE_RANK` = 3,3,4. Top-N per group = `ROW_NUMBER` inside a derived table, filter
outside. Running total = `SUM(...) OVER (ORDER BY ... ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW)`.

*Nth highest.* `LIMIT 1 OFFSET N-1` on `DISTINCT`, or `DENSE_RANK() = N`, or
`N = (SELECT COUNT(DISTINCT x.salary) FROM t x WHERE x.salary >= t.salary)`.

*Join execution.* Nested loop $O(n m)$; hash join $O(n + m)$ average, $O(m)$ memory;
merge join needs both sides sorted.
]

]
