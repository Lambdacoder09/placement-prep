#import "../../shared/lib/style.typ": *

#chapter(num: 2, title: "Resume & Profile",
  tagline: "One page whose only job is to earn the next ten minutes")[

#section[Pattern in one page]

Your resume has exactly one job: *get you to the next stage.* It is not a biography. It is
not a certificate collection. It is not an honest full account of your life. It is an
argument, one page long, that says "talking to me for thirty minutes is worth your time."

In Chapter 1 you saw the two filters it must pass: string-matching software, then a human for
about seven seconds. This chapter builds a page that passes both, bullet by bullet.

#subsection[The page, drawn]

#diagram(height: 6.15cm, caption: "One page. The decision happens in the top third.")[
  #dnode(0.2cm, 0cm, 8.0cm, 5.75cm, " ", fill: rgb("#fcfcfb"))
  #dnode(0.5cm, 0.2cm, 7.4cm, 0.6cm, "HEADER · name · phone · mail · github · linkedin")
  #dnode(0.5cm, 0.9cm, 7.4cm, 0.65cm, "EDUCATION · degree, branch, year, CGPA")
  #dnode(0.5cm, 1.65cm, 7.4cm, 0.65cm, "SKILLS · the keyword row")
  #dnode(0.5cm, 2.4cm, 7.4cm, 1.1cm, "PROJECT 1 — your best, 4 bullets")
  #dnode(0.5cm, 3.6cm, 7.4cm, 0.95cm, "PROJECT 2 — 3 bullets")
  #dnode(0.5cm, 4.65cm, 7.4cm, 0.85cm, "INTERNSHIP · ACHIEVEMENTS · EXTRAS")
  #darrow(8.4cm, 0.5cm, 9.6cm, 0.5cm)
  #darrow(8.4cm, 1.95cm, 9.6cm, 1.95cm)
  #darrow(8.4cm, 4.0cm, 9.6cm, 4.0cm)
  #dnode(9.8cm, 0.0cm, 6.4cm, 1.0cm, "Seconds 0–3: right person, right year?", fill: rgb("#f7f3ee"))
  #dnode(9.8cm, 1.45cm, 6.4cm, 1.0cm, "Seconds 3–7: does the keyword row match the checklist?", fill: rgb("#f7f3ee"))
  #dnode(9.8cm, 3.5cm, 6.4cm, 1.0cm, "Read only if the first seven seconds passed.", fill: rgb("#f7f3ee"))
]

#formulas(title: "The seven blocks, in this order")[
+ *Header* — name, one phone, one mail, GitHub, LinkedIn. Three lines, no more.
+ *Education* — degree, branch, institute, year of passing, CGPA. One line each.
+ *Skills* — the keyword row, grouped, written in the job post's words.
+ *Projects* — your two or three best, *best first*, each with 3--4 bullets.
+ *Experience / Internships* — same bullet rules as projects.
+ *Achievements* — only things with a number or a name attached.
+ *Extras* — positions of responsibility, open source, certifications that actually mean
  something. Cut this block first when you run out of room.

*The order is not negotiable for a fresher.* Skills above projects, because the recruiter is
ticking a checklist. Projects above experience if your project is better than your internship
— and for most students it is.

*What is NOT on the page:* an objective paragraph, a photo, date of birth, marital status,
father's name, full address, a declaration line with your signature, "References available on
request", or a skills bar chart showing "JavaScript 80%".
]

#subsection[Will it fit? Count lines, not feelings]

Students write four pages and then shrink the font to 8pt. That fails both filters: a human
will not read it, and it looks desperate. Count instead.

#code(lang: "js", caption: "page.js — one-page line budget")[
```js
// Will your resume fit on ONE page? Count lines, not feelings.
// A4, 10.5pt, normal margins -> about 46 usable lines. 95 characters fit on a line.

const BUDGET = 46, CPL = 95;

const blocks = [
  ["Header (name, phone, mail, links)", 3, 0],
  ["Education",                         4, 0],
  ["Skills",                            3, 0],
  ["Project 1 title + bullets",         1, 4],
  ["Project 2 title + bullets",         1, 3],
  ["Internship title + bullets",        1, 3],
  ["Achievements",                      3, 0],
  ["Gaps between sections",             7, 0],
];

function fit(avgBulletChars) {
  const wrap = Math.ceil(avgBulletChars / CPL);
  let total = 0;
  for (const [, fixed, bullets] of blocks) total += fixed + bullets * wrap;
  const verdict = total <= BUDGET
    ? "fits on one page"
    : `OVER by ${total - BUDGET} lines -> drop ${Math.ceil((total - BUDGET) / wrap)} bullets, ` +
      `or trim every bullet under ${CPL} characters`;
  console.log(`avg bullet ${String(avgBulletChars).padStart(3)} chars ` +
              `-> ${wrap} line(s) each -> ${String(total).padStart(2)} lines total : ${verdict}`);
}

[80, 130, 170, 220].forEach(fit);
```
]

#code(lang: "text", caption: "Output")[
```text
avg bullet  80 chars -> 1 line(s) each -> 33 lines total : fits on one page
avg bullet 130 chars -> 2 line(s) each -> 43 lines total : fits on one page
avg bullet 170 chars -> 2 line(s) each -> 43 lines total : fits on one page
avg bullet 220 chars -> 3 line(s) each -> 53 lines total : OVER by 7 lines -> drop 3 bullets, or trim every bullet under 95 characters
```
]

Read the 130 and 170 rows together. Both cost two lines. So a 130-character bullet is
*wasting nothing* by growing to 170 — the line is already spent. But crossing to 220 costs a
third line on every bullet and pushes you off the page.

#trick[
*The line-wrap rule.* Bullets are cheapest at just under a whole number of lines. Write the
bullet, then look at the last line: if it holds only two or three words, delete three words
elsewhere and pull it up. You get a tighter bullet and a free line.
]

#section[The bullet formula]

Every bullet on your resume is built from the same four parts. Miss one and the bullet goes
weak.

#formulas(title: "VERB + WHAT + HOW + NUMBER")[
*VERB* — a past-tense action verb, first word, no "I". Built, shipped, cut, raised, wrote,
migrated, automated, indexed, measured, reduced, designed, tested, deployed, led.

*WHAT* — the thing you produced, named specifically. Not "a module". "A seat-booking REST
API." "A CSV export."

*HOW* — the technology or the method. This is where the keywords live. "with Node.js and
Express", "by adding a composite index", "as a stream".

*NUMBER* — the size, the speed, the count, the time saved, the users. Anything countable.

*A bullet with no number is a claim. A bullet with a number is evidence.*
]

#diagram(height: 3.6cm, caption: "The same sentence, taken apart.")[
  #dnode(0cm, 0cm, 2.4cm, 0.9cm, "VERB\nCut", fill: rgb("#e7eef4"))
  #dnode(2.6cm, 0cm, 4.6cm, 0.9cm, "WHAT\nsearch p95 latency", fill: rgb("#e7eef4"))
  #dnode(7.4cm, 0cm, 4.0cm, 0.9cm, "NUMBER\n1.9 s to 0.31 s", fill: rgb("#eef3e9"))
  #dnode(11.6cm, 0cm, 4.8cm, 0.9cm, "HOW\nby adding a composite index", fill: rgb("#e7eef4"))
  #dnode(0cm, 1.6cm, 16.4cm, 0.8cm, "Cut search p95 latency from 1.9 s to 0.31 s by adding a composite index on (route_id, travel_date).")
  #darrow(1.2cm, 0.95cm, 1.2cm, 1.55cm)
  #darrow(4.9cm, 0.95cm, 4.9cm, 1.55cm)
  #darrow(9.4cm, 0.95cm, 9.4cm, 1.55cm)
  #darrow(14.0cm, 0.95cm, 14.0cm, 1.55cm)
  #dnode(0cm, 2.7cm, 16.4cm, 0.7cm, "17 words · 1 number · 1 named technique · 0 adjectives", fill: rgb("#f7f3ee"))
]

#subsection[Check your bullets with a script]

Do not trust your own eyes on your own writing. Run this on your real bullets.

#code(lang: "js", caption: "bullet.js — four rules per bullet")[
```js
// Checks one resume bullet against four rules. Run it on YOUR OWN bullets.

const VERBS = ["built","shipped","cut","raised","wrote","added","fixed","migrated",
  "automated","designed","measured","reduced","led","tested","deployed","indexed"];
const WEAK  = ["responsible for","worked on","involved in","helped in","was part of",
  "good knowledge of","familiar with","hardworking","team player"];

function check(b) {
  const low = b.toLowerCase();
  const first = low.split(/\s+/)[0];
  const problems = [];
  if (!VERBS.includes(first))             problems.push("no strong verb in position 1");
  if (!/\d/.test(b))                      problems.push("no number anywhere");
  for (const w of WEAK) if (low.includes(w)) problems.push(`filler phrase: "${w}"`);
  const words = b.trim().split(/\s+/).length;
  if (words > 22)                         problems.push(`too long (${words} words, aim <= 22)`);
  return problems;
}

const bullets = [
  "Responsible for the backend module of the college project and worked on database.",
  "Built a Node.js REST API for bus seat booking; cut average search time from 1.9 s to 0.3 s by adding a composite MySQL index.",
  "Cut API p95 latency 1.9 s -> 0.3 s by adding a composite index on (route_id, travel_date).",
];

for (const b of bullets) {
  const p = check(b);
  console.log("-".repeat(60));
  console.log(b);
  console.log(p.length ? "  FAIL: " + p.join(" | ") : "  PASS");
}
```
]

#code(lang: "text", caption: "Output")[
```text
------------------------------------------------------------
Responsible for the backend module of the college project and worked on database.
  FAIL: no strong verb in position 1 | no number anywhere | filler phrase: "responsible for" | filler phrase: "worked on"
------------------------------------------------------------
Built a Node.js REST API for bus seat booking; cut average search time from 1.9 s to 0.3 s by adding a composite MySQL index.
  FAIL: too long (25 words, aim <= 22)
------------------------------------------------------------
Cut API p95 latency 1.9 s -> 0.3 s by adding a composite index on (route_id, travel_date).
  PASS
```
]

Notice bullet two. It is a *good* bullet that fails on length only. The fix is not to delete
information — it is to delete the words that carry none: "Built a", "cut average search time
from", "by adding a composite MySQL index" all shrink without losing a single fact.

The same check in Python, if that is what you have on your machine:

#code(lang: "py", caption: "bullet.py — the same four rules")[
```py
import re
VERBS = {"built","shipped","cut","raised","wrote","added","fixed","migrated",
         "automated","designed","measured","reduced","led","tested","deployed","indexed"}
WEAK  = ["responsible for","worked on","involved in","helped in","was part of",
         "good knowledge of","familiar with","hardworking","team player"]

def check(b):
    low, out = b.lower(), []
    if low.split()[0] not in VERBS: out.append("no strong verb in position 1")
    if not re.search(r"\d", b):     out.append("no number anywhere")
    out += [f'filler phrase: "{w}"' for w in WEAK if w in low]
    n = len(b.split())
    if n > 22: out.append(f"too long ({n} words, aim <= 22)")
    return out

for b in ["Responsible for the backend module of the college project and worked on database.",
          "Cut API p95 latency 1.9 s -> 0.3 s by adding a composite index on (route_id, travel_date)."]:
    print(b); print("  ", check(b) or "PASS")
```
]

#subsection[Audit the whole page at once]

#code(lang: "js", caption: "audit.js — resume-level checks")[
```js
// Audit a whole resume at once. Paste YOUR bullets into `mine` and run it.

const FILLER = ["responsible for","worked on","involved in","helped in","was part of",
  "good knowledge","familiar with","hardworking","team player","various","etc",
  "successfully","as per requirement","using latest technologies"];

function audit(bullets) {
  const withNum = bullets.filter((b) => /\d/.test(b)).length;
  const fillerHits = bullets.flatMap((b) =>
    FILLER.filter((f) => b.toLowerCase().includes(f)).map((f) => [b, f]));
  const lens = bullets.map((b) => b.split(/\s+/).length);
  const avg = (lens.reduce((a, c) => a + c, 0) / lens.length).toFixed(1);
  const longest = Math.max(...lens);
  const firstWords = new Set(bullets.map((b) => b.split(/\s+/)[0].toLowerCase()));

  console.log(`bullets                 : ${bullets.length}`);
  console.log(`with a number           : ${withNum}/${bullets.length}` +
              `  (${Math.round(100 * withNum / bullets.length)}%)   target >= 70%`);
  console.log(`filler phrases found    : ${fillerHits.length}   target 0`);
  fillerHits.forEach(([b, f]) => console.log(`   "${f}"  in: ${b.slice(0, 48)}...`));
  console.log(`avg words per bullet    : ${avg}   target 14-22`);
  console.log(`longest bullet          : ${longest} words`);
  console.log(`distinct opening verbs  : ${firstWords.size}/${bullets.length}` +
              `   target: all different`);
}

const mine = [
  "Responsible for the frontend of the college event portal using latest technologies.",
  "Worked on the database design and various queries for the admin panel.",
  "Built a Node.js REST API for seat booking; 12 endpoints, 38 Jest tests.",
  "Cut search p95 latency 1.9 s to 0.31 s by adding a composite index on route and date.",
  "Built the CSV export as a stream so it holds at 500,000 rows instead of 70,000.",
];

audit(mine);
```
]

#code(lang: "text", caption: "Output")[
```text
bullets                 : 5
with a number           : 3/5  (60%)   target >= 70%
filler phrases found    : 4   target 0
   "responsible for"  in: Responsible for the frontend of the college even...
   "using latest technologies"  in: Responsible for the frontend of the college even...
   "worked on"  in: Worked on the database design and various querie...
   "various"  in: Worked on the database design and various querie...
avg words per bullet    : 14.2   target 14-22
longest bullet          : 18 words
distinct opening verbs  : 4/5   target: all different
```
]

The last line is a check students never do. Two bullets in that list both start with "Built".
Four bullets that all start with "Developed" read as one grey block and the recruiter's eye
skips them. Vary the verb.

#subsection[The verb bank]

Pick the verb that matches what you actually did. Using a bigger verb than the work deserves
is the most common way a resume starts to sound false.

#table(columns: (auto, 1.5fr),
  align: (left, left),
  [*What you did*], [*Verbs that fit*],
  [Made a thing that did not exist], [Built · Wrote · Designed · Created · Shipped · Implemented],
  [Made an existing thing faster or smaller], [Cut · Reduced · Halved · Sped up · Trimmed · Optimised (only with a number)],
  [Made an existing thing bigger or better], [Extended · Raised · Increased · Improved (only with a number)],
  [Removed a defect], [Fixed · Debugged · Traced · Eliminated · Patched · Corrected],
  [Moved something from A to B], [Migrated · Ported · Converted · Replaced],
  [Removed human effort], [Automated · Scripted · Scheduled · Batched],
  [Made something measurable], [Measured · Instrumented · Load-tested · Profiled · Benchmarked],
  [Made something safer], [Validated · Locked · Secured · Rate-limited · Sandboxed],
  [Worked with people], [Led · Coordinated · Reviewed · Mentored · Onboarded · Ran],
  [Wrote things down], [Documented · Specified · Wrote up · Diagrammed],
)

#trap[
*Verbs that quietly erase you.* "Responsible for", "Worked on", "Involved in", "Helped in",
"Assisted with", "Was part of", "Participated in", "Gained exposure to", "Learnt about",
"Utilised", "Handled", "Managed" (when you managed nobody).

Every one of these describes a *position* rather than an *output*. Read a bullet that starts
with one of them and ask: what came out at the end? If nothing did, delete the bullet.
]

#trap[
*Verbs that are too big for fresher work.* "Architected", "Spearheaded", "Revolutionised",
"Pioneered", "Owned the end-to-end vision", "Engineered a paradigm shift". These do not read
as confidence, they read as a candidate who has not seen real architecture work yet. "Built"
is a completely respectable word. Use it.
]

#section[Where your numbers come from]

"But my project has no numbers." It does. You have not counted them yet. Every one of these
is countable *today*, from your own repository or your own memory, with no invention.

#table(columns: (auto, 1.5fr),
  align: (left, left),
  [*Kind of number*], [*How you get it, honestly*],
  [Size of the thing you built], [Count endpoints, screens, tables, components. `git ls-files` and a line count.],
  [Size of the data], [`SELECT COUNT(*)` on your own table. "Tested on 90,000 rows."],
  [Users], [How many people actually used it. 3 is a number. "Used by the 4 members of the transport office" is honest and specific.],
  [Speed], [Time it. Two lines of code around the call. Before and after.],
  [Tests], [Count them. "38 Jest tests, 81% line coverage" — the tool prints coverage for you.],
  [Time saved], [What the manual process took, times how often. "Replaced a 20-minute weekly export."],
  [Errors removed], [Count the rows the validation rejected. "Caught 1,100 malformed rows."],
  [Team and your share], ["3-person team; I owned the API and the schema." Honest scoping.],
  [Duration], ["10 weeks." It tells the reader the scale of the work.],
  [Scale you tested to], ["Load-tested at 200 concurrent requests." Even if real traffic was 3.],
)

#trap[
*Do not invent the number.* Two reasons, and the second is the one that matters. First, at the
project round you will be asked how you measured it, and a made-up number has no measuring
method behind it. Second, a made-up number is usually *too round and too big* — "improved
performance by 90%" — and experienced interviewers read round-and-big as invented. A real
number is odd-looking: 6.1 times, 0.31 seconds, 1,100 rows.
]

#trick[
*If you genuinely cannot measure it now, go and measure it this week.* The project is still in
your repository. Clone it, run it, time it, count the rows. An afternoon of measuring turns six
weak bullets into six strong ones, and it also prepares you for Chapter 5, where you have to
defend every one of them.
]

#section[Worked examples]

#formulas(title: "Read this before every example")[
*You must substitute your own real experience.* These are filled examples of a *structure*.
If you copy the words, you will be asked "what index, on which columns, and why that order?"
in the project round, and the answer will not be there.

*Nothing in this chapter asks you to lie.* Where you have a backlog, a gap, a low CGPA or a
weak year, you will be shown how to state it plainly on the page and put the evidence of
improvement right next to it. That is a strategy that works. Hiding it is not, because
almost every offer is followed by a document check.
]

#tier-header(1)

#ex(1, tier: 1, asked: "TCS NQT · pattern")[
Rewrite the top of a fresher resume. The current version starts with an objective paragraph.
]

#trap[
*WEAK:*

```text
                          RAHUL S.
        Age: 21 | DOB: 14-08-2004 | Male | Unmarried
   Father's Name: Suresh S. | Address: 4/221, Second Cross Street,
        Ambattur, Chennai - 600053 | rahul_cool143@mail.example

CAREER OBJECTIVE
To obtain a challenging position in a reputed organization where I can
utilize my technical skills and knowledge for the growth of the organization
as well as for my own career development, and to work in a dynamic
environment which gives me scope to enhance my knowledge and skills.
```

*What this costs, line by line:* six lines and about 20% of the page, spent before a single
fact about your ability. Nothing here helps the recruiter tick a box. The objective is true of
every candidate alive, so it carries zero information. The mail id is a liability. Age, DOB,
gender, marital status and father's name are not needed on the PDF you send, and in several
countries a recruiter is trained to not even look at them.
]

#sol[
*STRONG:*

```text
RAHUL S.                Chennai, India · open to relocation
+91-9xxxxxxxxx · rahul.s.dev@mail.example
github.com/rahul-s-dev · linkedin.com/in/rahul-s-dev

B.Tech Computer Science, 2026 · Backend (Node.js, SQL)
```

*What changed, exactly:*
- Six lines $->$ four, and the four lines all do work.
- Objective paragraph $->$ *one line saying what you are*: degree, year, and the kind of role.
  That line is also the keyword line the screen reads first.
- Personal details removed. Location kept, because a recruiter genuinely needs it, plus the
  relocation stance in three words.
- `rahul_cool143` $->$ `rahul.s.dev`. Free, and it removes an impression you would never be
  told about.
- Links are plain text URLs, so they survive copy-paste into a text box.

*The one-line replacement for the objective:*

```text
[Degree], [Year]  ·  [What kind of engineer you are]  ·  [2-4 technologies]
```

If you want a sentence instead, it must be a sentence that would be *false* for another
candidate: "Backend-focused fresher; built and deployed two Node.js services used by a college
office." That is a claim with evidence behind it.
]

#note[
*A real nuance about personal details in India.* Some companies' own application forms — and
many government and PSU forms — require DOB, category, father's name, or a signed declaration.
*Fill the form.* That is a different document with a different purpose. The one-page PDF you
attach or hand over does not need them, and removing them buys you back a fifth of your page.
]

#ex(2, tier: 1, asked: "Infosys · pattern")[
Write the Education block for a student with: CGPA 6.4, two cleared backlogs, and a semester
where marks dropped because of a family illness.
]

#sol[
*The rule: state it, do not explain it on the page, and put the trend beside it.* The page is
not where you tell the story — that is the interview (Chapter 6). The page's job is to be
accurate and to not look like it is hiding something.
]

#trap[
*WEAK (hiding):*

```text
EDUCATION
B.Tech Computer Science — XYZ Institute of Technology
Percentage: First Class
```

"First Class" with no number, and no year of passing. A recruiter reads this as concealment,
which is worse than 6.4. And without a year of passing, the screen cannot even check whether
you are eligible for the drive, so you may be filtered out mechanically.
]

#trap[
*WEAK (over-explaining):*

```text
EDUCATION
B.Tech CSE, XYZ Institute, 2026 — CGPA 6.4
(Note: my CGPA was affected in semester 4 due to my mother's serious
illness and hospitalisation during that period, which caused me to have
2 backlogs, both of which I have now cleared. I request you to kindly
consider my situation.)
```

Three lines of apology on a one-page document. It makes the 6.4 the loudest thing on the page,
and "kindly consider my situation" moves you from candidate to petitioner.
]

#sol[
*STRONG:*

```text
EDUCATION
B.Tech Computer Science · XYZ Institute of Technology · 2026 · CGPA 6.4/10
   Sem 5-7 CGPA 7.6 · no active backlogs
Class XII (CBSE) 2022 — 84%   ·   Class X (CBSE) 2020 — 88%
```

*What changed, exactly:*
- The number is stated plainly, with its scale (`/10`), so nobody has to guess.
- Year of passing is present, which is what the mechanical filter needs.
- *The trend is given its own sub-line.* 6.4 overall next to 7.6 in the recent semesters tells
  a story of recovery without one word of explanation. This is the whole technique.
- "No active backlogs" is stated as a fact, in three words. Many drives have a rule about
  active backlogs, and answering it on the page saves a rejection-by-uncertainty.
- Class X and XII on one line — they matter for Tier-1 cut-offs and nowhere else, so they get
  one line, not three.

*The spoken version belongs in the interview, and it is short:* "My CGPA is 6.4. It dropped in
my fourth semester when my mother was hospitalised and I was at home. I had two backlogs from
that period and cleared both. From the fifth semester my CGPA has been 7.6." State it, give
the number, stop. Chapter 6 works through the follow-ups.
]

#trap[
*Never round up, never convert dishonestly, never hide an active backlog.* Marks are verified
from your transcripts before joining, and a mismatch is treated as misrepresentation rather
than as a mistake — which means a withdrawn offer, not a conversation. If you have an active
backlog, say so, with the date of your next attempt.
]

#ex(3, tier: 1, asked: "Wipro · pattern")[
Rewrite a skills section.
]

#trap[
*WEAK:*

```text
TECHNICAL SKILLS
Languages       : C, C++, Java, Python, JavaScript, PHP, Kotlin, Go
Web             : HTML, CSS, Bootstrap, web technologies
Databases       : DBMS, SQL, Oracle
Tools           : MS Office, Windows, Internet
Soft Skills     : Hardworking, Quick learner, Team player, Leadership
```

*Four separate problems.*
+ Eight languages from a 21-year-old is not believed, and it invites a question in a language
  you last touched in semester three. Every item here is a *promise to be tested*.
+ "Web technologies", "DBMS", "Internet" are not skills. "MS Office" and "Windows" are not
  skills for a software role.
+ Soft skills as a list of adjectives is the single most ignored block on any resume. Nobody
  has ever been shortlisted for writing "Hardworking".
+ Nothing is grouped by how well you know it, so the reader must assume the weakest.
]

#sol[
*STRONG:*

```text
SKILLS
Strong        : JavaScript, Node.js (Node), Express, SQL (MySQL), REST API design, Git
Working       : Python, MongoDB, Docker, Jest, Linux shell
Familiar      : React, AWS (EC2, S3), Redis
Coursework    : Data Structures, DBMS, Operating Systems, Computer Networks
```

*What changed, exactly:*
- 20+ items $->$ 17, but *ranked into three honest bands*. This is the key move. It tells the
  interviewer where to aim, and it makes the top band believable.
- Both forms of every abbreviation written once — `Node.js (Node)`, `SQL (MySQL)` — so a string
  matcher finds either spelling (Chapter 1).
- Fake skills removed. Soft-skill adjectives removed entirely; they belong in your *bullets*,
  demonstrated, never claimed.
- Coursework kept as a separate line, so it does not pretend to be experience.

*The honesty ladder, stated plainly.*
- *Strong*: I have built something with it and I can be questioned on it for 20 minutes.
- *Working*: I have used it in a real project and can use it again with the docs open.
- *Familiar*: I have followed a tutorial or used it once. I will say so if asked.

Being asked about a *Familiar* item and answering "I have only used that once, on a tutorial
project — here is what I did with it" costs you nothing. Being caught overclaiming a *Strong*
item costs you the round.
]

#ex(4, tier: 1, asked: "Capgemini · pattern")[
Turn a typical college project into a project block.
]

#trap[
*WEAK:*

```text
PROJECTS
1. College Management System
   - It is a web based application for college management.
   - Front end is HTML CSS and back end is PHP MySQL.
   - Responsible for the admin module.
   - Successfully completed the project with my team members.

2. Final Year Project
   - Machine learning based system using Python.
```

*What is wrong:* the title says nothing about what it *does*. "It is a web based application"
restates the title. No number anywhere. "Responsible for" hides what you actually did.
"Successfully completed" is not an outcome. And project two is a placeholder, not a project.
]

#sol[
*STRONG:*

```text
PROJECTS
Bus Seat Booking Service — Node.js, Express, MySQL            github.com/…/seatbook
   Booking API for the college transport office; 3-person team, I owned the API and schema.
 · Built 12 REST endpoints with JWT auth; 38 Jest tests, 81% line coverage.
 · Cut search p95 latency 1.9 s -> 0.31 s by adding a composite index on
   (route_id, travel_date); measured over 200 requests on 90,000 rows.
 · Prevented double-booking with a row lock per seat after a load test at 50
   concurrent requests exposed 7 duplicate bookings.
 · In use by the transport office for 2 terms; ~400 bookings per week.

Attendance Defaulter Report — Python, pandas, PostgreSQL       github.com/…/attreport
 · Replaced a 20-minute manual weekly export with a 6-second script; used by 4 staff.
 · Validated input on load, rejecting 1,100 malformed rows that had been silently
   corrupting the old spreadsheet totals.
```

*What changed, exactly:*
- Title now says *what it does* and *what it is built with*, and carries a link.
- One italic context line gives team size and *your* scope — "I owned the API and schema".
  Honest scoping is a strength, not a weakness.
- Every bullet starts with a different verb: Built, Cut, Prevented, In use.
- Every bullet has a number, and the numbers are odd-looking because they are real.
- Bullet three is the best one on the page: it contains a *problem found by testing*, which is
  the thing interviewers most want to see and students most often delete.
- The dead second project is replaced by a small, finished, useful one. A small finished thing
  beats a large unfinished one on a resume, every time.
]

#trick[
*The link is worth a bullet.* A `github.com/...` link beside the project title converts the
recruiter's doubt into a two-second check. It only helps if the repository has a README that
explains what the project does in the first three lines. A link to an empty repo is worse than
no link at all — see the GitHub section later in this chapter.
]

#ex(5, tier: 1, asked: "Cognizant · pattern")[
Write the internship block for a student whose internship was mostly small tickets and
watching.
]

#sol[
Most fresher internships really are small tickets. That is fine. The mistake is either
inflating it into architecture work or dismissing it into nothing.

*Structure:* what the team did (one clause) $->$ what *you* shipped $->$ the number $->$ one
thing you learned that you can be questioned on.
]

#trap[
*WEAK (dismissing):*

```text
INTERNSHIP
ABC Softwares, Chennai — Intern (Jun 2025 - Aug 2025)
 · Learnt about the company's technology stack and software development life cycle.
 · Attended daily standup meetings and worked on small tasks given by my mentor.
 · Gained good exposure to a professional working environment.
```

Nothing here is a thing you produced. "Gained exposure" is what happened *to* you. After
reading this the recruiter knows only that you were physically present for eight weeks.
]

#trap[
*WEAK (inflating):*

```text
 · Designed and architected scalable microservices for a high-traffic production system
   serving millions of users.
```

You did not architect it. The first follow-up — "what were the service boundaries and who
decided them?" — ends this badly, and it makes your honest bullets look inflated too.
]

#sol[
*STRONG:*

```text
INTERNSHIP
ABC Softwares, Chennai — Backend Intern (Jun - Aug 2025, 8 weeks)
 · Shipped 14 tickets to production on an internal billing service (Java Spring, MySQL),
   reviewed by 2 engineers; 11 merged without changes requested.
 · Fixed a report that double-counted refunds for same-day cancellations; traced it to a
   date-boundary comparison, added 4 regression tests, corrected 3 months of reports.
 · Cut a nightly job from 22 min to 9 min by batching 1-row-at-a-time inserts into
   batches of 500. My mentor suggested batching; I measured, sized the batch and shipped it.
 · Took over the on-call runbook page for that job: rewrote it after I needed it at 2 a.m.
   and found it wrong.
```

*What changed, exactly:*
- "Small tasks" $->$ *14 tickets, 11 merged clean*. Counting your own tickets is honest, easy
  and specific. The merge-clean number is a quality signal you can actually produce.
- A named bug with a named cause. This is the bullet an interviewer will pick, and you can
  talk about date boundaries for ten minutes because you lived it.
- *Credit given where it is due*: "My mentor suggested batching; I measured, sized the batch
  and shipped it." Giving credit does not shrink your contribution — it makes the whole entry
  believable, and it is exactly the behaviour a team wants.
- The last bullet is small and unglamorous and interviewers love it: you found a document was
  wrong and you fixed it, unasked.
]

#ex(6, tier: 1, asked: "Accenture · pattern")[
What belongs in Achievements, and what quietly hurts you?
]

#sol[
*The rule: an achievement needs a number, a rank, or a name.* If it has none of those, it is
not an achievement, it is a participation record, and it is taking a line from a bullet that
would have worked harder.
]

#trap[
*WEAK:*

```text
ACHIEVEMENTS AND CERTIFICATIONS
 · Participated in various technical events and workshops at college level.
 · Certificate of participation in national level hackathon.
 · Completed online course on Python.
 · Member of the college coding club.
 · Certificate for attending a 2-day seminar on Artificial Intelligence.
```

*Why it hurts.* A reader scans this and finds no rank, no number, no selection, no output.
Worse, five lines of participation create an impression that you had nothing better to list —
which may not be true, and which those five lines are now preventing you from disproving.
]

#sol[
*STRONG:*

```text
ACHIEVEMENTS
 · Top 40 of 1,200 teams, [Name] national hackathon 2025 — built a 2-day offline-first
   attendance app; code linked above.
 · Solved 400+ problems on [platform]; peak rating 1,640 (top ~15% of the site).
 · Coding club: ran a 6-week beginner track, 40 attendees, materials open-sourced.
```

*What changed, exactly:*
- "Participated" $->$ *a rank out of a field size*. "Top 40 of 1,200" is an achievement.
  "Participated in a national hackathon" is a Tuesday.
- The online course disappears, and the *thing built while learning* takes its place. Nobody
  is hired for a certificate; people are hired for what the certificate was supposed to
  produce.
- "Member of the coding club" $->$ what you *did* in the club, with two numbers.
- Five weak lines $->$ three strong ones, freeing two lines for a project bullet.

*Certifications: the honest ranking.*
- *Worth a line:* a certification that is genuinely hard and externally invigilated — a cloud
  associate-level exam, a database vendor exam. It is a real filter and recruiters know it.
- *Worth a line only if you built something with it:* a course platform certificate. List the
  project, mention the course in four words, not the reverse.
- *Not worth a line:* attendance and participation certificates. Anyone who turned up has one.
]

#tier-header(2)

#ex(7, tier: 2, asked: "Grab · pattern")[
You are applying from India to a backend role in Singapore. What changes on the page?
]

#sol[
Three things change, and nothing else should. Do not rewrite your personality for another
country. Do remove the ambiguity that makes a cross-border recruiter hesitate.

*Change 1 — the header answers the work-authorisation question before it is asked.*
*Change 2 — the numbers get units and context a foreign reader can size.*
*Change 3 — the date format stops being ambiguous.*
]

#trap[
*WEAK header:*

```text
RAHUL S. · Ambattur, Chennai - 600053 · +9198xxxxxxx · rahul.s.dev@mail.example
Available from 05/06/2026
```

A recruiter in Singapore does not know Ambattur, cannot tell whether you need sponsorship, and
cannot tell whether `05/06/2026` is 5 June or 6 May. Each of those is a small hesitation, and
hesitation at the screen stage means the next resume.
]

#sol[
*STRONG header:*

```text
RAHUL S.   Chennai, India (IST, UTC+5:30) · willing to relocate to Singapore
+91 98xxx xxxxx (WhatsApp) · rahul.s.dev@mail.example
github.com/rahul-s-dev · linkedin.com/in/rahul-s-dev
Work authorisation: will require employment pass sponsorship · available from 5 June 2026
```

*What changed, exactly:*
- City plus *country*, plus the time zone. A distributed team reads the time zone immediately.
- The relocation intent is stated, not implied.
- The sponsorship need is stated *plainly and without apology*. Hiding it wastes everyone's
  time and it always comes out. Companies that sponsor are not scared of the sentence;
  companies that do not sponsor were never going to hire you anyway.
- A messaging app noted beside the phone number, because an international recruiter often
  cannot make an ordinary call to you.
- `05/06/2026` $->$ `5 June 2026`. Write the month as a word. This single habit removes a whole
  class of confusion across every date on the page.

*And in the bullets:* give numbers a unit and a comparison a stranger can size. "400 bookings
per week across 6 routes" is readable anywhere. "Handled the bookings of our college" is not.
]

#ex(8, tier: 2, asked: "Agoda · pattern")[
You have a 14-month gap between graduation and now. How does the page handle it?
]

#sol[
*The rule: a gap you name is a fact; a gap the reader discovers is a red flag.* An unexplained
hole between two dates makes a recruiter imagine the worst available explanation. Two lines
remove it.

*Structure on the page:* give the gap its own dated entry, with a neutral one-word reason and
*what you did in it*.
]

#trap[
*WEAK (leaving the hole):*

```text
B.Tech CSE, 2024
Intern, ABC Softwares — June 2025 to Aug 2025
```

The reader sees a hole from mid-2024 to mid-2025 and fills it in themselves. You are no longer
in control of the story.
]

#trap[
*WEAK (the vague cover-up):*

```text
2024 - 2025 : Self study and skill enhancement
```

Every gap in the world can be described this way, so it reads as a phrase chosen to avoid
saying something. It also has no evidence attached.
]

#sol[
*STRONG:*

```text
Aug 2024 - Sep 2025 · Family care responsibility, with part-time study
 · Cared for a family member after surgery; this was the reason I did not take a role.
 · Completed 3 courses (backend with Node.js, SQL, system design basics) and shipped
   2 projects in this period — both linked below, with commit history from that time.
 · Took freelance work for a local clinic: a 4-screen appointment tool, live since Mar 2025,
   about 60 bookings a month.
```

*What changed, exactly:*
- The gap has *dates and a name*. It is now an entry, not a hole.
- The reason is stated in one clause, without medical detail and without apology.
- *Evidence that survives checking*: shipped projects with commit history in that window. This
  is the part that converts a gap from a risk into a demonstration of self-direction.
- One paid piece of work, however small, with a live date and a usage number.

*Other honest gap reasons, written the same way:* "Preparing for competitive examinations
(cleared prelims, did not clear mains)". "Health — recovered, no ongoing restrictions".
"Startup attempt — built X, 40 users, shut down in Jan 2025; here is what I learned." Each is a
sentence, then evidence. None of them needs an apology, and none of them should be stretched
into a paragraph.
]

#note[
*Do not stretch a job's dates to cover a gap.* Dates are verified in the background check from
payslips, offer letters or your provident fund record. A stretched date is found, and it is
treated as falsification rather than as rounding. A named gap has never cost anyone an offer
the way a caught date change does.
]

#ex(9, tier: 2, asked: "DBS · pattern")[
Write a LinkedIn headline and About section for a cross-border application.
]

#sol[
LinkedIn is a *search surface*. Recruiters type keywords into a search box and read headlines
in a list. So the headline is a keyword line, not a slogan.

*Headline structure:* `[What you are] · [2-4 technologies] · [year / status] · [location or
mobility]`. About 15 words. Recruiters see roughly the first 10 on mobile, so front-load.
]

#trap[
*WEAK headline:* "Aspiring Software Engineer | Passionate about Technology | Seeking
Opportunities | Open to Work | Let's Connect!"

Zero searchable nouns. "Aspiring" is a word that means "not yet". The exclamation mark is
doing no work. A recruiter searching for `Node.js Singapore` will never find this profile.
]

#sol[
*STRONG headline:* "Backend engineer (fresher) · Node.js, Express, SQL, Docker · B.Tech 2026 ·
open to Singapore, pass sponsorship required"

*What changed, exactly:* every noun is now something a recruiter would actually type into the
search box; the year tells them if you are hireable now; the mobility and sponsorship line is
stated once, up front.
]

#trap[
*WEAK About:* "I am a hardworking and dedicated individual with a passion for coding. I am a
quick learner and a good team player, always eager to learn new technologies and take on new
challenges. Looking for an opportunity to grow."

Six adjectives, no facts. It could belong to anybody.
]

#sol[
*STRONG About (four short paragraphs, nothing longer):*

```text
Backend-focused CS final-year student. I build small services end to end and keep them
running: API design, the SQL schema underneath, tests, and deployment.

Most recent: a seat-booking service for my college transport office — Node.js, Express,
MySQL — in use for two terms, ~400 bookings a week. I cut search p95 latency from 1.9 s
to 0.31 s by fixing an index, and stopped double-booking with a row lock after a load
test found 7 duplicates.

Currently learning: system design fundamentals and PostgreSQL internals. Writing up what
I learn at github.com/rahul-s-dev.

Open to backend roles in Singapore from June 2026 (employment pass sponsorship needed).
Happy to talk — rahul.s.dev@mail.example.
```

*What changed, exactly:*
- Adjectives $->$ one sentence saying what you *do*, then evidence.
- A named recent project with real numbers, so the profile is checkable.
- A "currently learning" line, which honestly signals direction without claiming mastery.
- A clear, unembarrassed availability-and-sponsorship line and a direct way to contact you.
]

#ex(10, tier: 2, asked: "Shopee · pattern")[
You are from Mechanical / Civil / Electronics, not Computer Science, and you are applying for
a software role. What does the page do?
]

#sol[
*The rule: the branch is a fact, not an argument. Win the argument with the Skills and Projects
blocks instead, and do it above the fold.*

A non-CS student loses at the screen for one reason: the top third of the page says
"Mechanical" and nothing says "software" until halfway down. Fix the *order and the
positioning line*, not the truth.
]

#trap[
*WEAK:*

```text
RAHUL S.
CAREER OBJECTIVE: Though I am from a Mechanical background, I am very passionate
about software and I am willing to learn any technology. I request you to give me
a chance to prove myself in the IT field.

EDUCATION
B.E. Mechanical Engineering, 2026, CGPA 7.9
...
SKILLS
Python, SQL, basic web development
```

Two mistakes. It *apologises* for the branch in the first sentence, which makes the branch the
headline. And the software evidence is far below the decision zone.
]

#sol[
*STRONG:*

```text
RAHUL S.        Chennai, India · open to relocation · available Jun 2026
+91 98xxx xxxxx · rahul.s.dev@mail.example · github.com/rahul-s-dev

Backend engineer (fresher) · Python, SQL, REST APIs · B.E. Mechanical 2026
Two shipped services; 400+ commits over 18 months.

SKILLS
Strong   : Python, FastAPI, SQL (PostgreSQL), REST API design, Git
Working  : Docker, pytest, Linux shell, pandas
Familiar : JavaScript, React, AWS (EC2, S3)

PROJECTS
Machine Downtime Tracker — Python, FastAPI, PostgreSQL     github.com/…/downtime
 · Built for my department's workshop: logs machine stoppages, 9 endpoints, 62 pytest
   tests. In use by 2 lab technicians for 11 months; 3,800 entries logged.
 · Cut the weekly report from a 40-minute manual spreadsheet to a 5-second query.
 · Added CSV import that validates on load; rejected 210 malformed legacy rows that had
   been corrupting monthly totals.

Vibration Data Pipeline — Python, pandas, PostgreSQL       github.com/…/vibe
 · Processed 1.2 M sensor readings into 5-minute buckets; query time for a one-day range
   dropped from 41 s (raw scan) to 0.6 s after bucketing and a time index.

EDUCATION
B.E. Mechanical Engineering · XYZ Institute · 2026 · CGPA 7.9/10
Self-taught software: 400+ commits over 18 months, 2 services in real use.
```

*What changed, exactly:*
- The apology is deleted. Nobody needs to be told that Mechanical is not CSE; they can read.
- A *positioning line* names what you are in the first four lines, with the branch stated
  plainly in the same line — not hidden, not apologised for.
- *Skills and Projects moved above Education.* This is the one structural change that matters
  for a branch switcher, and it is legitimate: you are putting your strongest true evidence
  where the seven seconds are spent.
- The projects use the *domain you actually come from*. A machine-downtime tracker and a
  vibration pipeline are better than another to-do app, because they are real, they have real
  data, and nobody else has them.
- A volume-of-work line ("400+ commits over 18 months") answers the real doubt — is this
  serious or is this a weekend hobby? — with a checkable fact.

*In the interview, the question comes anyway, and the honest answer is short:* "Mechanical was
my entrance-exam result, not my choice. I started writing Python in my second year for my own
lab work because the spreadsheet process was painful, and I have shipped two things that are
still in use. I do have gaps — I have not done a formal compilers or OS course — and I have
been closing those from [source]. I would rather be judged on the two services than on the
branch." Chapter 6 works through the follow-ups.
]

#tier-header(3)

#ex(11, tier: 3, asked: "Amazon · pattern")[
Write a project block where every bullet survives five follow-up questions.
]

#sol[
At this tier the resume is *the question paper for your interview*. The interviewer picks a
bullet and drills. So write bullets you *want* to be drilled on.

*The test:* for each bullet, can you answer — how did you measure it? what did you try first?
what did it cost? what would you do differently? If not, either fix the bullet or fix your
knowledge of your own project.
]

#trap[
*WEAK (impressive-sounding, undefendable):*

```text
· Optimised the application and improved performance by 90%.
· Implemented a scalable microservices architecture using industry best practices.
· Utilised advanced machine learning algorithms to increase accuracy significantly.
```

Every one of these dies on the first follow-up. "90% of what, measured how?" "How many
services, and why was one not enough for 400 bookings a week?" "Which algorithm, and what was
your baseline?" These bullets are not a lie yet, but they are a trap you built for yourself,
and they will be read as inflation.
]

#sol[
*STRONG:*

```text
Bus Seat Booking Service — Node.js 20, Express, MySQL 8, Docker · 3-person team,
I owned the API, schema and deploy                          github.com/…/seatbook
 · Cut search p95 from 1.9 s to 0.31 s (6x) by adding a composite index on
   (route_id, travel_date); measured with 200 requests against 90,000 rows.
   Write path cost 6 ms -> 8 ms, accepted for this write volume.
 · Eliminated double-booking under concurrency: a load test at 50 parallel requests
   produced 7 duplicate seats; fixed with SELECT ... FOR UPDATE per seat row.
   Chose a row lock over a cached availability count because the count could go stale.
 · Made the CSV export a stream after estimating 12 months of growth (40k -> ~90k rows
   per month); the in-memory version would have failed silently past ~70k.
 · 38 Jest tests, 81% line coverage; CI runs them on every push.
```

*What changed, exactly:*
- "Improved by 90%" $->$ a before, an after, a multiplier, *and the method of measurement*.
- Added *the cost* of the fix on the write path. Naming a trade-off you accepted is the single
  strongest signal on a fresher resume. Nobody expects a free win; senior people expect you to
  know the price.
- Added *the rejected alternative and why* — cache versus row lock. This is a design decision
  written in 12 words, and it invites exactly the follow-up you can answer.
- Added how the bug was *found* (a load test), not just that it was fixed.
- Version numbers on the stack, so the reader knows you actually ran it rather than read about
  it.
]

#subsection[The five drills your bullets must survive]

#table(columns: (1fr, 1.5fr),
  align: (left, left),
  [*The drill*], [*Where the answer already is, in the strong block above*],
  [How did you measure it?], [200 requests against 90,000 rows; before and after.],
  [What did you try first?], [The obvious cache; rejected on staleness.],
  [What did it cost?], [Writes 6 ms $->$ 8 ms; one more index in migrations.],
  [How did you find the bug?], [A load test at 50 parallel requests produced 7 duplicates.],
  [What would you do differently?], [Measure in week 2, not week 8 — there was no performance owner.],
)

#trick[
Write the bullet *after* you can answer the five drills, not before. If a drill has no answer,
you have found a hole in your own understanding of your own project, and you still have time
to go and close it. That is worth far more than a nicer sentence.
]

#ex(12, tier: 3, asked: "Google · pattern")[
Your project was a 4-person team assignment. How do you write it without either stealing
credit or disappearing?
]

#sol[
*Structure:* one context line names the team size and *your* scope. Then every bullet is about
something *you* did. Where a result was collective, say so and name your contribution to it.
]

#trap[
*WEAK (stealing):*

```text
· Built a full-stack food delivery platform with real-time order tracking,
  payment integration and an admin dashboard.
```

Written in the first person singular by implication, for four people's work. It collapses on
the first question about the payment integration you never touched.
]

#trap[
*WEAK (disappearing):*

```text
· Worked in a team of 4 on a food delivery platform. Helped in the backend part.
```

Now nothing is attributable to you at all. "Helped in" is the most self-erasing phrase on any
resume. This scores lower than saying nothing.
]

#sol[
*STRONG:*

```text
Food Delivery Platform — 4-person team; I owned order state and the driver-assignment
service (Node.js, PostgreSQL, Redis)                        github.com/…/fooddrop
 · Designed the order state machine (6 states, 9 transitions) and made every transition
   idempotent, which removed a class of duplicate-status bugs seen in week 3.
 · Wrote the driver-assignment service: nearest-free-driver from a Redis geo set,
   median assignment 180 ms over 2,000 simulated orders.
 · Team result: platform demoed with 60 test users, end to end. My part was orders and
   assignment; payments and the admin UI were teammates'.
```

*What changed, exactly:*
- Ownership scoped in the title line, so everything under it is fairly read as yours.
- Verbs are personal and specific: Designed, Wrote.
- The collective result is labelled "Team result" and your share is named *explicitly*. Far
  from weakening the entry, this is the line that makes the rest of it believable.
- Nothing is claimed that you cannot be drilled on. You can talk about the state machine for
  twenty minutes and you will never be embarrassed about the payment gateway.
]

#ex(13, tier: 3, asked: "Microsoft · pattern")[
Your GitHub link is on the resume. What does the reviewer actually look at, and in what order?
]

#sol[
An engineer who opens your GitHub spends about a minute. They look at: your pinned
repositories, the README of the top one, the commit history shape, and whether the code runs.
They are not reading your code line by line. They are asking *is this person real?*
]

#trap[
*WEAK profile:* 27 repositories, 24 of which are forks of tutorials, all named things like
`project1`, `test`, `newfolder`. No pinned repositories. Every repo's last commit is a single
commit saying "final code" on one day.

*What the reviewer concludes:* the code arrived from somewhere else on the last day. That may
be unfair. It is also the only available reading of a one-commit history.
]

#sol[
*STRONG profile, in four moves that take one evening:*

+ *Pin three repositories* — your two best projects and one small, clean, useful thing. Pinning
  is one click and it controls everything the reviewer sees first.
+ *Write a README that answers four questions in the first screen:* what does it do, how do I
  run it in two commands, what is the architecture in five lines, what is not finished. That
  last one earns more trust than a feature list.
+ *Delete or archive the tutorial forks*, or at least un-pin them. A profile of 3 real things
  beats a profile of 27 things where 24 are noise.
+ *Let the commit history be honest.* Commits spread over the weeks you actually worked, with
  messages that say what changed, are themselves the evidence that the work is yours.

*A README opening that works:*

```text
# seatbook
Seat booking API for a college bus service. Node.js + Express + MySQL.
Used by our transport office for two terms (~400 bookings/week).

Run it:  docker compose up      then open http://localhost:3000/docs

How it works: 12 REST endpoints -> service layer -> MySQL. Seats are locked
per row (SELECT ... FOR UPDATE) during booking, which is what stops double
booking under concurrent requests. JWT for auth. 38 Jest tests.

Not done yet: no payment flow, no seat map UI, admin actions are API-only.
```

*Why this works:* the reviewer knows in ten seconds what it is, can run it in one command, is
told the one interesting design decision, and is told the limits by you rather than finding
them. "Not done yet" is the most persuasive section in the whole file.
]

#ex(14, tier: 3, asked: "Goldman Sachs · pattern")[
A role you want asks for things you do not have. What do you put on the page?
]

#sol[
*The rule: close the gap with real work, or state the nearest true thing. Never claim the
skill.*

Take the post's must-have list. For each item you are missing, you have exactly three honest
moves.
]

#table(columns: (auto, 1.5fr),
  align: (left, left),
  [*Move*], [*What it looks like on the page*],
  [Close it — build something small, this week],
    [A two-day project using the missing technology, listed honestly as small: "Kafka — 2-day exercise: order events producer/consumer, 3 partitions, at-least-once handling." A small labelled thing is credible; a big vague claim is not.],
  [Map it — name the nearest thing you *have* done],
    [Post asks for Kubernetes; you have Docker Compose. Write `Docker, docker compose` under Working and do not write Kubernetes at all. In the interview: "I have not run Kubernetes. I have containerised and orchestrated locally with Compose, so the concepts I know are images, networking and health checks; I have not done scheduling or rollouts."],
  [Drop it — say nothing],
    [If you have neither the skill nor the nearest thing, leave it off entirely. A silent gap is normal. A claimed gap is a failed round.],
)

#trap[
*WEAK (the keyword stuffing move):* adding `Kubernetes, Kafka, Spark, TensorFlow` to the skills
line because the post mentioned them.

This does two bad things at once. It may get you *through* the screen, which means you now sit
in a technical round being asked about Kafka partitions. And most interviewers can tell within
two questions, at which point everything else on your resume becomes suspect too — including
the parts that were true.
]

#sol[
*STRONG (the same candidate, honestly):*

```text
SKILLS
Strong   : JavaScript, Node.js (Node), Express, SQL (MySQL), REST API design, Git
Working  : Python, MongoDB, Docker & docker compose, Jest, Linux shell, CI (GitHub Actions)
Familiar : React, AWS (EC2, S3), Redis, message queues (RabbitMQ — one 2-day exercise)

PROJECTS
Order Events Exercise — RabbitMQ, Node.js                      github.com/…/order-events
 · 2-day exercise to learn message queues: producer/consumer for order events,
   at-least-once delivery, retry with a dead-letter queue after 3 failures.
 · Wrote up what surprised me (duplicate deliveries are normal, so consumers must be
   idempotent) in the README.
```

*What changed, exactly:*
- The missing skill is neither claimed nor hidden — it is present at its real size, labelled
  "one 2-day exercise", with a link.
- The write-up of *what surprised you* is the strongest part. It proves learning happened, and
  it gives the interviewer an easy, friendly question to ask you, which you can answer well.
- Everything else on the page stays trustworthy, which is the thing you are really protecting.
]

#ex(15, tier: 3, asked: "D. E. Shaw · pattern")[
Your resume will *generate* the questions you are asked. Design that on purpose.
]

#sol[
At Tier 3, the interviewer reads your resume for two minutes before the call and picks the
questions from it. That means you control the question paper — if you write deliberately.

*The technique: every bullet should be a door you want opened.* Put one *deliberate hook* in
each project: an interesting trade-off, a bug with a real cause, a measurement. Remove
anything you would rather not discuss.
]

#table(columns: (1.15fr, 1.35fr),
  align: (left, left),
  [*If your bullet says...*], [*...expect exactly this question*],
  [`composite index on (route_id, travel_date)`], [Why that column order? What happens if the query filters on date only?],
  [`SELECT ... FOR UPDATE per seat row`], [What is the deadlock risk? What is your lock ordering?],
  [`38 Jest tests, 81% line coverage`], [What is not covered by that 19%? Is coverage a good target?],
  [`streamed the CSV export`], [What happens if the client disconnects halfway?],
  [`Redis geo set for nearest driver`], [What does Redis do if it restarts? Is your data durable?],
  [`JWT auth`], [How do you revoke a token before it expires?],
  [`microservices`], [Why? What did splitting cost you that a single service would not have?],
  [`machine learning model, 94% accuracy`], [What was the class balance? What is your baseline? Precision or recall?],
)

#trap[
*WEAK (undefended hooks):* leaving `microservices`, `94% accuracy` and `blockchain` on the page
because they sound impressive, without being able to answer the question in the right-hand
column.

Each of these is a door you opened and then could not walk through. An interviewer who asks
about your own listed technology and gets a blank look will discount *everything* on the page,
including the parts you did well.
]

#sol[
*STRONG (hooks you want opened):*

```text
 · Chose a composite index on (route_id, travel_date) in that order because every query
   filters route first; a date-only query still does a scan, which was acceptable here.
 · Locked the seat row (SELECT ... FOR UPDATE) rather than caching an availability count,
   because the count could go stale between read and write.
 · 38 Jest tests, 81% line coverage — the uncovered part is the admin refund path, which
   is not automated yet.
```

*What changed, exactly:*
- Each bullet now contains *the answer to its own follow-up*, in a clause. The interviewer
  still asks, and you elaborate — but the resume already proved you knew.
- Bullet three names *what is not covered*. Volunteering a limit is the fastest way to be
  trusted about everything else.
- The word "microservices" is simply gone, because the honest answer was "the course template
  had three services." A word you cannot defend is a liability no matter how good it looks.

*The final self-test before you send any resume to a Tier-3 company:* read every line out loud
and ask "what question does this invite, and can I talk about it for five minutes?" Any line
where the answer is no gets rewritten or deleted. There is no third option.
]

#section[Formatting so both filters can read it]

#formulas(title: "The rules that matter, and why")[
+ *One column.* Two-column layouts can be read across the columns by a parser, gluing your
  phone number to your CGPA. If you use two columns, run the copy-paste test below.
+ *No text inside images.* A skills graphic is invisible to the screen.
+ *Nothing important in the header or footer* of the page. Many parsers skip them.
+ *No tables for layout* if you can avoid it; simple tables are usually fine, nested ones are
  not.
+ *Standard section names.* "Education", "Skills", "Projects", "Experience". Not "My Journey"
  or "What I Bring". The parser looks for the standard words.
+ *One common font*, 10--11pt body. No script fonts.
+ *Send PDF unless the post says otherwise.* If the post says `.doc` or `.docx`, send that.
  Follow the instruction — some portals genuinely only parse what they asked for.
+ *File name:* `Rahul_S_Backend_Resume.pdf`. Not `resume_final_v3_updated.pdf`, and never
  `Untitled.pdf`.
+ *Dates as `Mon YYYY`* — `Jun 2026`, not `06/2026`.
]

#subsection[The copy-paste test — do this every single time]

#formulas(title: "60 seconds, and it catches almost every parsing disaster")[
+ Open your final PDF.
+ Select all. Copy.
+ Paste into a *plain* text editor — not a word processor.
+ Read what appeared.

*Pass:* your name is on its own line, the skills are in a readable row, the bullets are
separate lines, and nothing is glued to anything else.

*Fail:* empty output (your PDF is an image), scrambled order, or words from two columns joined
into nonsense like `JavaScriptChennai Node.js600053`.

Whatever you see in that text editor is close to what the screening software sees. If it is
unreadable to you, it is unreadable to the filter, and no amount of good content fixes that.
]

#trick[
On a machine with `pdftotext` installed you can do the same check from the terminal:
`pdftotext -layout Rahul_S_Backend_Resume.pdf - | head -40`. Same idea, faster, and you can
run it every time you export.
]

#section[Three skeletons you can copy the shape of]

Copy the *shape*, never the words. Substitute your own real projects, your own real numbers,
your own real weak spots.

#subsection[Skeleton A — no internship, projects only]

```text
NAME                      City, Country · open to relocation · available Mon YYYY
+CC phone · first.last@mail.example · github.com/handle · linkedin.com/in/handle

Backend engineer (fresher) · Node.js, SQL, REST · B.Tech CSE 2026

SKILLS
Strong   : 5-6 items you can be drilled on for 20 minutes
Working  : 4-5 items you have used in a real project
Familiar : 3-4 items you have tried once (say so if asked)
Coursework: DSA, DBMS, OS, Networks

PROJECTS
Project 1 — what it does, stack                                      github link
   1 context line: team size and YOUR scope
 · Built [thing]: [size number], [test number].
 · Cut/Fixed [named problem] from [before] to [after] by [named method]; measured by [how].
 · [The trade-off you accepted and its price.]
 · In use by [who], [usage number].

Project 2 — what it does, stack                                      github link
 · [Output bullet with a number.]
 · [Bullet about a bug you found and how you found it.]

EDUCATION
B.Tech [Branch] · [Institute] · [Year] · CGPA x.x/10
   [trend line if it helps you] · no active backlogs
Class XII [Board] YYYY — xx%   ·   Class X [Board] YYYY — xx%

ACHIEVEMENTS
 · Rank out of field size, event, year — what you built.
 · Volume with a rating or percentile.
 · Something you ran, with an attendance number.
```

#subsection[Skeleton B — with an internship]

Same as A, with one change: the internship goes *above* projects only if it was genuinely
better than your best project. Judge it by one question — which one can you talk about for
twenty minutes?

```text
EXPERIENCE
[Company], [City] — [Role] (Mon - Mon YYYY, N weeks)
 · Shipped N tickets to production on [system] ([stack]); N merged without changes.
 · Fixed [named bug]: traced to [named cause], added N regression tests.
 · Cut [named job] from N to M by [method]. [Who suggested what — give credit.]
 · [The unglamorous ownership bullet: a runbook, a doc, a test suite nobody wanted.]

PROJECTS
... as in Skeleton A, two projects ...
```

#subsection[Skeleton C — a gap, a switch, or a weak year]

```text
NAME                      City, Country · open to relocation · available Mon YYYY
contacts · links

[What you are] · [3-4 technologies] · [degree and year]
[One evidence line: shipped things, commit volume, usage.]

SKILLS
... three honest bands ...

PROJECTS
... your two strongest, both with links and usage numbers ...

EXPERIENCE / OTHER ACTIVITY  (dated, nothing left as a hole)
Mon YYYY - Mon YYYY · [Neutral name for the period]
 · [One-clause reason, no apology, no medical detail.]
 · [Evidence with dates INSIDE this window: shipped X, N users, commit history.]
 · [Any paid work, however small, with a live date and a usage number.]

EDUCATION
[Degree] · [Institute] · [Year] · CGPA x.x/10
   [trend line] · [backlog status stated as a fact]
```

#note[
*Skeleton C is the one most students need and the one nobody shows them.* Look at what it
does: it never hides the weak part, it gives the weak part a name and a date, and it puts
checkable evidence directly underneath. The page is not asking for sympathy anywhere. That is
the whole technique, and it works because it is true.
]

#subsection[Keep one master file, export many]

Keep a *master* document with every bullet you have ever written — far longer than one page.
Never send it. For each application, copy it, delete down to one page against that job post,
rename, export, run the copy-paste test.

Two reasons this matters. You stop rewriting bullets from memory each time, which is where
errors and inflation creep in. And when an interviewer asks about something from a version you
sent four months ago, you still have that exact version. Keep the sent PDFs in a folder named
by company and date: `2026-03-14_GrabSG_backend.pdf`.

#trick[
Put the master file in a Git repository, even if it is just a plain text file. One commit per
edit. Then "what did I send them?" is a one-command question, and you get a free record of how
your resume improved — which is itself useful material for the "how have you grown?" question
in Chapter 4.
]

#section[Tailoring: 20 minutes per application]

One resume for every company is the reason most applications vanish. You do not write a new
resume each time. You change four things.

#table(columns: (auto, 1.4fr, auto),
  align: (left, left, left),
  [*Minutes*], [*What you change*], [*Why*],
  [0--5], [Copy the post's must-have list into a scratch file. Underline every noun.], [These are the exact strings both filters use.],
  [5--10], [Edit the *skills row* so every must-have you honestly have appears in the post's own words.], [This is where most of the screen score comes from.],
  [10--15], [Reorder projects so the most relevant one is first, and rewrite its *first bullet* to face the role.], [The recruiter reads one bullet of one project.],
  [15--18], [Fix the one-line headline under your name to match the role title.], [Title match is a heavy signal for both filters.],
  [18--20], [Rename the file, re-export, run the copy-paste test.], [Catches the disaster before it costs you the application.],
)

#note[
*Tailoring is not lying.* You are choosing which true things to put first. If a must-have is
something you do not have, it does not go on the page — see Example 14. The four edits above
change emphasis and vocabulary, never facts.
]

#subsection[The mail you send with it]

If you are mailing a resume to a person, the mail is read before the attachment.

#trap[
*WEAK:*

Subject: `Job`

"Respected Sir/Madam, I am writing this mail to apply for any suitable position in your
esteemed organisation. I have attached my resume herewith for your kind perusal. I am a
hardworking and dedicated fresher and I request you to kindly consider my application and give
me an opportunity to prove myself. Awaiting your positive response. Thanking you."
]

#sol[
*STRONG:*

Subject: `Backend Engineer (fresher) — Rahul S. — Node.js/SQL — resume attached`

```text
Hello [name],

I am applying for the Backend Engineer (fresher) role, ref BE-2026-14.

Closest thing I have done to this job: I built and shipped a Node.js + MySQL
booking API that my college transport office has used for two terms (~400
bookings a week). I fixed a search that took 1.9 s at p95 and got it to 0.31 s
with a composite index, and stopped double-booking with a per-row lock after a
load test found 7 duplicates.

Resume attached (1 page). Code: github.com/rahul-s-dev/seatbook

I am in Chennai, available from June 2026, open to relocation.

Thank you,
Rahul S. · +91 98xxx xxxxx
```

*What changed, exactly:*
- Subject line is now searchable and states the role and the reference number.
- "Any suitable position" $->$ one named role. Applying to "anything" reads as applying to
  nothing.
- The middle paragraph is the *whole mail*: one piece of evidence, with numbers, that maps to
  the job. Nobody needs your adjectives.
- "Kindly consider... prove myself" removed. It lowers your standing and adds no information.
- Ends with the three facts a recruiter needs to act: location, availability, phone.
- Under 120 words. It is read on a phone.
]

#section[Top traps in this chapter]

#trap[
+ An objective paragraph. It costs a fifth of the page and says nothing.
+ A resume longer than one page as a fresher. Page two is not read before the decision.
+ Shrinking the font to 8pt to fit. Cut bullets instead.
+ "Responsible for", "Worked on", "Involved in", "Helped in". Every one erases you.
+ A bullet with no number. It is a claim, not evidence.
+ A number that is round and huge — "improved by 90%" — with no measurement behind it.
+ Listing eight programming languages. Each one is a promise to be tested.
+ Soft skills as adjectives. Demonstrate them in bullets or leave them out.
+ Claiming a technology because the job post mentioned it. It gets you into a room you cannot
  survive, and it poisons the true parts of your resume.
+ Hiding a CGPA behind "First Class", or omitting the year of passing.
+ An unexplained date gap. Name it, date it, attach evidence.
+ Changing an employment date to cover a gap. This is found in the background check and
  treated as falsification.
+ A GitHub link to a profile of tutorial forks and one-commit repositories.
+ A photo, DOB, marital status or a signed declaration on the PDF you send.
+ Sending a scanned or image PDF. Run the copy-paste test every time.
+ Sending the same untailored resume to 40 companies and concluding the market is bad.
]

#section[Practice]

#practice(tier: 1, time: "45 min, with your real resume open")[
+ Print or open your current resume. Count: how many lines before the first *fact about your
  ability*? If it is more than four, delete until it is four.
+ Paste all your bullets into `audit.js` and run it. Write down three numbers: percentage of
  bullets with a number, count of filler phrases, count of distinct opening verbs.
+ Rewrite your three worst bullets using VERB + WHAT + HOW + NUMBER. For each, write beside it
  *where the number came from* — the table, the log, the count.
+ Rewrite your skills section into the three honest bands: Strong, Working, Familiar. Be
  strict. Anything you could not defend for 20 minutes is not Strong.
+ Run the copy-paste test on your PDF. Write down exactly what came out wrong.
]

#key[
+ Four lines maximum before Education. Name, contacts, links, one positioning line.
+ Targets: 70% or more of bullets carry a number · zero filler phrases · all opening verbs
  different.
+ If you cannot say where a number came from, you cannot use it — go and measure it, or drop
  it. Most numbers are one `COUNT(*)`, one `git log --oneline | wc -l`, or one timer away.
+ A common honest result is 4--6 Strong items, not 20. That is a good resume, not a thin one.
+ Typical failures: empty text (image PDF), columns glued together, icons turning into boxes,
  the header line missing entirely.
]

#practice(tier: 2, time: "40 min")[
+ Take one real job post from a company outside your country. List its must-have nouns. Mark
  each one: *have it* / *nearest thing* / *do not have*. Do not write anything from the third
  group onto your page.
+ Rewrite your header for that application: country, time zone, mobility, work authorisation,
  availability date in `5 June 2026` form.
+ Rewrite two of your bullets so a reader who has never heard of your college can size the
  numbers. Add units and a comparison.
+ Write your LinkedIn headline using the formula. Count the words. Check the first ten words
  alone still say what you are.
+ If you have a gap, write the three-line dated entry for it: dates, one-clause reason,
  evidence with links.
]

#key[
+ The "nearest thing" column is your interview script for that skill: name what you did do,
  name the boundary of it, and stop.
+ A header that answers work authorisation before it is asked removes the most common reason a
  cross-border resume is set aside.
+ "About 400 bookings a week across 6 routes" travels. "Handled our college's bookings" does not.
+ If the first ten words are "Aspiring · Passionate · Seeking", rewrite. They must be nouns a
  recruiter would type into a search box.
+ Evidence with a *date inside the gap window* is what turns the entry from a claim into a
  fact.
]

#practice(tier: 3, time: "60 min, written")[
+ Take your best project. For every bullet, answer the five drills in writing: how measured,
  what tried first, what it cost, how the bug was found, what you would do differently. Mark
  every bullet with an unanswerable drill.
+ For one marked bullet, go into the repository and *get the real answer* — run it, time it,
  count the rows. Then rewrite the bullet with the real number.
+ Rewrite one bullet to include a trade-off you accepted and its price. ("Writes 6 ms $->$
  8 ms, accepted at this volume.")
+ Rewrite one team project entry so that ownership is scoped in the title line and every bullet
  is personally attributable, with one line labelled "Team result".
+ Rewrite the README of your top repository to answer: what it does, how to run it in two
  commands, how it works in five lines, what is not finished.
+ Take a must-have from a real post that you do not have. Build the two-day version of it this
  week. Write the honest, size-labelled entry for it.
]

#key[
+ A bullet whose drills you cannot answer is not a strong bullet; it is an invitation to a bad
  five minutes. Fix the knowledge or cut the bullet.
+ Real numbers look irregular. If your rewritten number is "50%" exactly, check it again.
+ A named trade-off is the clearest fresher-level signal that you understand engineering rather
  than features.
+ "Team result: ... My part was X; Y and Z were teammates'." This sentence *increases* trust in
  everything above it.
+ The "Not done yet" section of a README is the most persuasive part of it.
+ A two-day exercise, labelled as a two-day exercise, is credible. The same work described as
  expertise is not.
]

#revision[
*What the page is for.* One job: earn the next ten minutes. It passes a string matcher, then a
human for seven seconds.

*Order of blocks.* Header $->$ Education $->$ Skills $->$ Projects (best first) $->$
Experience $->$ Achievements $->$ Extras. Skills above projects, because the recruiter is
ticking a checklist.

*Cut on sight.* Objective paragraph · photo · DOB · marital status · father's name · full
address · declaration and signature · "references available on request" · skill percentage
bars. (Company application *forms* are different — fill those as asked.)

*The bullet formula.* VERB + WHAT + HOW + NUMBER. 14--22 words. A different opening verb every
time. A bullet with no number is a claim; a bullet with a number is evidence.

*Numbers you already have.* endpoints · tables · rows · users · tests and coverage · before/after
milliseconds · time saved per week · rows rejected · team size and your scope · weeks · load
tested at N.

*Real numbers look irregular.* 6.1x, 0.31 s, 1,100 rows. Round and huge reads as invented.

*The three honest skill bands.* Strong = I can be drilled for 20 minutes. Working = I used it
in a real project. Familiar = I tried it once and will say so.

*Weakness on the page.* State the fact, put the trend beside it, and stop.
- CGPA 6.4/10 with `Sem 5-7 CGPA 7.6 · no active backlogs` underneath.
- A gap gets dates, a one-clause reason, and evidence with commits inside that window.
- A missing skill gets closed (a labelled two-day exercise), mapped (name the nearest true
  thing), or dropped. Never claimed.
- Never change a date, never round up a CGPA. Both are verified, and both are treated as
  falsification, not error.

*Team work.* Scope ownership in the title line. Personal verbs in every bullet. One line
labelled "Team result" with your share named.

*Formatting.* One column · no text in images · nothing in the page header/footer · standard
section names · PDF unless told otherwise · `Rahul_S_Backend_Resume.pdf` · dates as `Jun 2026`.

*The copy-paste test.* Open the PDF, select all, copy, paste into a plain text editor. What you
see is roughly what the filter sees. Run it on every export.

*Tailoring, 20 minutes.* Skills row into their words $->$ best-matching project first $->$
rewrite its first bullet $->$ headline matches the role title $->$ rename, re-export, retest.

*The application mail.* A searchable subject with the role and reference · one named role · one
paragraph of evidence with numbers · resume and code link · location, availability, phone.
Under 120 words.

*And the rule that outranks every technique in this chapter:* everything on the page must be
true and must be defendable by you, out loud, for twenty minutes. Substitute your own real
experience into every structure here. A resume you cannot defend is not an asset — it is the
question paper for a round you will fail.
]

]
