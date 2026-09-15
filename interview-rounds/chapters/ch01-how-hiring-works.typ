#import "../../shared/lib/style.typ": *

#chapter(num: 1, title: "How Hiring Actually Works",
  tagline: "Learn the machine before you argue with it")[

#section[Pattern in one page]

You are not being judged by one person who likes you or does not like you. You are moving
through a *machine*. The machine has stages. Each stage has a different owner, a different
score sheet, and a different reason to say no.

Most students prepare for one stage — the coding test — and then lose at a stage they never
studied. This chapter shows you every stage, who runs it, what it scores, and what a "no"
at that stage actually means.

#subsection[The funnel, drawn]

#diagram(height: 6.0cm, caption: "Each bar is a stage. Width is how many people are left.")[
  #dnode(0.5cm, 0cm,   13cm,  0.62cm, "1 · Applied — 20,000")
  #dnode(1.4cm, 0.8cm, 11.2cm, 0.62cm, "2 · Passed resume screen — 11,000")
  #dnode(2.3cm, 1.6cm, 9.4cm,  0.62cm, "3 · Passed aptitude + coding test — 3,600")
  #dnode(3.2cm, 2.4cm, 7.6cm,  0.62cm, "4 · Passed technical round 1 — 1,800")
  #dnode(4.1cm, 3.2cm, 5.8cm,  0.62cm, "5 · Passed technical round 2 — 1,100")
  #dnode(4.8cm, 4.0cm, 4.4cm,  0.62cm, "6 · Reached HR round — 1,000")
  #dnode(5.3cm, 4.8cm, 3.4cm,  0.62cm, "7 · Offered — 900")
]

Look at the last two bars. They are almost the same width. *If you reach the HR round, you
are very likely to get the offer.* That is why an HR round feels friendly. It is not a
formality though — the 10% who fail it fail for reasons you can control completely.

#formulas(title: "The seven stages, and who owns each")[

*Stage 1 — Apply.* You send a resume. Owner: a form or a portal. Cost of a no: zero
information. You are usually not told.

*Stage 2 — Screen.* Software matches keywords; then a human recruiter looks for about
seven seconds. Owner: recruiter. Scores: does this person look like the job post?

*Stage 3 — Test.* Aptitude, or coding, or both. Owner: software. Scores: a number.
This is the biggest single cut in the whole funnel.

*Stage 4 — Technical round.* One or two engineers. Scores: can you write code, explain it,
and be corrected without breaking?

*Stage 5 — Project / deep-dive round.* Scores: is the thing on your resume real, and do
you understand the choices inside it?

*Stage 6 — HR / behavioural / managerial.* Scores: will you accept, will you stay, will you
be a problem, can you work with people.

*Stage 7 — Offer and paperwork.* Salary, bond or service agreement, joining date,
notice period, background check.

*The one rule that explains everything:* each stage exists to make the next stage cheaper.
A test costs the company nothing. An engineer's hour costs a lot. So the cheap stages cut
hard and the expensive stages cut gently.
]

#subsection[The arithmetic, run]

These proportions are a typical *shape* for a large campus drive. They are not any one
company's real figures. Run the program and read the last column.

#code(lang: "js", caption: "funnel.js — survival at each stage")[
```js
// How many applicants survive each stage of a mass campus drive.
// Numbers are a TYPICAL SHAPE, not any one company's real data.

const stages = [
  ["Applied",            1.00],
  ["Resume / ATS pass",  0.55],
  ["Aptitude + coding",  0.18],
  ["Technical round 1",  0.09],
  ["Technical round 2",  0.055],
  ["HR round",           0.050],
  ["Offer",              0.045],
];

const applied = 20000;
let prev = applied;
console.log("stage                 reaching   % of applied   survived this stage");
for (const [name, keep] of stages) {
  const here = Math.round(applied * keep);
  const pass = prev === here ? "-" : (100 * here / prev).toFixed(0) + "%";
  console.log(
    name.padEnd(20) + String(here).padStart(9) +
    (100 * keep).toFixed(1).padStart(13) + "%" + pass.padStart(20));
  prev = here;
}
```
]

#code(lang: "text", caption: "Output")[
```text
stage                 reaching   % of applied   survived this stage
Applied                 20000        100.0%                   -
Resume / ATS pass       11000         55.0%                 55%
Aptitude + coding        3600         18.0%                 33%
Technical round 1        1800          9.0%                 50%
Technical round 2        1100          5.5%                 61%
HR round                 1000          5.0%                 91%
Offer                     900          4.5%                 90%
```
]

Read the right-hand column as *"if I get here, what is my chance of moving on?"*

- Resume screen: 55%. Almost half of all effort dies here, before any human talks to you.
- Test: 33%. Two out of three people who sit the test are removed by it.
- HR round: 91%. The friendliest number in the table.

#trick[
Where should a week of preparation go? Put it where the survival rate is worst *and* your
control is highest. That is the resume screen (Chapter 2) and the test. But do not put
*zero* time on the HR and behavioural rounds — a 9% failure rate at stage 6 means roughly
1 student in 11 who had already won the job talked their way out of it.
]

#section[What each round is actually scoring]

An interviewer does not write "nice guy" on a form. In most structured companies they fill
a *scorecard* with fixed lines. Your job is to hand them the words for each line.

#table(columns: (auto, 1.1fr, 1.2fr, 1.1fr),
  align: (left, left, left, left),
  [*Round*], [*Who runs it*], [*What the form asks*], [*What a "no" means*],
  [Resume screen], [Recruiter + keyword software],
    [Does this person match the must-have list? Is the resume readable in 7 seconds?],
    [You did not use the words the job post used.],
  [Aptitude test], [Software],
    [Score above the cut-off, section-wise.],
    [Speed or accuracy. Nothing personal.],
  [Coding test], [Software],
    [Test cases passed. Sometimes time and code quality.],
    [You could not finish under pressure.],
  [Technical 1], [Engineer, 1--3 years ahead of you],
    [Can they code? Do they explain while coding? Do they take a hint?],
    [Silence, or refusing the hint.],
  [Technical 2 / project], [Senior engineer],
    [Is the project real? Can they defend a design choice? Do they know the limits of what they built?],
    [The project sounded copied.],
  [Managerial], [The hiring manager],
    [Will this person be useful in 6 months? Will they need babysitting?],
    [No evidence of finishing anything alone.],
  [HR], [HR / talent team],
    [Will they accept? Will they stay? Any red flags in the story?],
    [Gaps you would not explain, or a story that changed.],
)

#subsection[A scorecard, filled in]

This is the shape of a structured behavioural scorecard. Learn it, because it tells you what
to say. Ratings are usually on a fixed scale and the interviewer must write *evidence*, not
opinion.

#table(columns: (1fr, auto, 1.7fr),
  align: (left, center, left),
  [*Line on the form*], [*Rating*], [*Evidence the interviewer wrote*],
  [Ownership], [Strong], [Found the slow query themselves, nobody asked them to.],
  [Dealing with ambiguity], [Mixed], [Waited two days for the mentor before trying anything.],
  [Communication], [Strong], [Explained the index choice in plain words, no jargon hiding.],
  [Technical depth], [Mixed], [Knew what an index does, could not say what it costs on writes.],
  [Learns from failure], [Strong], [Named their own bug and what they changed after it.],
  [Recommendation], [Hire], [Depth is normal for a fresher; ownership is above bar.],
)

#note[
Notice every "evidence" cell is a *fact with a subject and a verb*. "Good attitude" would
be rejected by a reviewer. So an answer that gives no facts gives the interviewer nothing
to write, and an empty form is a no.
]

#section[The resume screen, in detail]

Two filters sit here, in this order.

*Filter 1 — keyword matching software* (often called an ATS, applicant tracking system).
It does not understand your resume. It matches strings.

*Filter 2 — a human, for about seven seconds.* They look at: current/last title, company or
college, dates, and whether the page is readable.

Here is a small model of filter 1. It is not any company's real software. It shows the
*shape* of the decision so you stop guessing.

#code(lang: "js", caption: "ats.js — a keyword screen, modelled")[
```js
// A small model of how a keyword screen scores a resume against a job post.
// This is NOT the real software any company runs. It shows the SHAPE of the decision.

const normalise = (s) =>
  s.toLowerCase()
   .replace(/[^a-z0-9+#. ]/g, " ")            // keep + # . so c++, c#, node.js survive
   .split(/\s+/)
   .map((w) => w.replace(/^\.+|\.+$/g, ""))   // drop sentence dots, keep inner ones
   .filter(Boolean);

function score(resumeText, mustHave, niceToHave) {
  const words = new Set(normalise(resumeText));
  const hit = (k) => k.split(" ").every((w) => words.has(w));
  const must = mustHave.filter(hit);
  const nice = niceToHave.filter(hit);
  const missing = mustHave.filter((k) => !hit(k));
  const pct = Math.round((100 * (2 * must.length + nice.length)) /
                         (2 * mustHave.length + niceToHave.length));
  return { pct, must: must.length, nice: nice.length, missing };
}

const MUST = ["javascript", "node", "rest api", "sql", "git"];
const NICE = ["docker", "react", "aws", "testing", "mongodb"];

const weak = `
Hardworking and dedicated fresher seeking a challenging position in a reputed
organization where I can utilize my skills and grow along with the company.
Skills: C, programming, web technologies, database, good communication.
Project: Final year project on a web based system.
`;

const strong = `
B.Tech CSE 2026. Skills: JavaScript, Node.js, Express, REST API, SQL, MongoDB,
Git, Docker, unit testing.
Project: Bus seat booking service - Node.js + Express REST API, MySQL schema,
JWT auth, 38 Jest tests, shipped in Docker.
`;

const fixed = strong.replace("Node.js, Express", "Node.js (Node), Express");

for (const [name, text] of [["WEAK", weak], ["STRONG", strong], ["FIXED", fixed]]) {
  const r = score(text, MUST, NICE);
  console.log(`${name.padEnd(7)} score=${String(r.pct).padStart(3)}%   ` +
              `must ${r.must}/${MUST.length}   nice ${r.nice}/${NICE.length}   ` +
              `missing: ${r.missing.join(", ") || "none"}`);
}
```
]

#code(lang: "text", caption: "Output")[
```text
WEAK    score=  0%   must 0/5   nice 0/5   missing: javascript, node, rest api, sql, git
STRONG  score= 73%   must 4/5   nice 3/5   missing: node
FIXED   score= 87%   must 5/5   nice 3/5   missing: none
```
]

Three lessons, and the third one is the one nobody tells you.

+ The weak resume scores *zero*. Every word in it is about feelings. It contains no noun
  that a job post would contain. "Hardworking" is not a skill. "Web technologies" is not a
  technology.
+ The strong resume scores 73% with the same person, same project, better nouns.
+ The strong resume still *missed one must-have*: the post said `node`, the resume said
  `Node.js`. A string matcher does not know they are the same thing. Writing
  `Node.js (Node)` once fixed it and moved the score to 87%.

#trap[
*The abbreviation trap.* A screen looks for the exact token. Write both forms, once, the
first time you use it:

`Node.js (Node)` · `PostgreSQL (Postgres)` · `Amazon Web Services (AWS)` ·
`Continuous Integration (CI)` · `Object Oriented Programming (OOP)`

Do not spam the word twenty times. One honest pair of forms is enough, and a human reading
the same line must not feel you are gaming it.
]

#trap[
*Things that break the software filter, every time.* Skills in a text box inside an image.
Skills in the page header or footer. Two-column layouts where the parser reads across the
columns and glues unrelated words together. Fancy fonts where the letters do not extract.
A `.png` or a scanned `.pdf` instead of a text `.pdf`. Send a text-selectable PDF. Test it:
open the PDF, press select-all, copy, paste into a plain text editor. If what you paste is
scrambled or empty, the software sees the same scrambled or empty text.
]

#subsection[The seven-second human scan]

If the resume survives the software, a human opens it. Eye-tracking studies of recruiters
have been done for decades and they all find the same thing: the first pass is a *Z* across
the top third, then a stop wherever a number or a familiar word appears.

#diagram(height: 6.6cm, caption: "Where the recruiter's eyes actually go on page one.")[
  #dnode(0.4cm, 0cm, 8.6cm, 6.2cm, " ", fill: rgb("#fcfcfb"))
  #dnode(0.8cm, 0.3cm, 7.8cm, 0.8cm, "1 · Name, phone, mail, GitHub link")
  #dnode(0.8cm, 1.4cm, 7.8cm, 0.9cm, "2 · Education: degree, branch, year, CGPA")
  #dnode(0.8cm, 2.5cm, 7.8cm, 0.8cm, "3 · Skills line — the keyword row")
  #dnode(0.8cm, 3.5cm, 7.8cm, 1.1cm, "4 · Project 1 — title and first bullet")
  #dnode(0.8cm, 4.8cm, 7.8cm, 1.0cm, "5 · Everything below here is read only if 1–4 passed")
  #darrow(9.4cm, 0.7cm, 11.0cm, 0.7cm, label: "0.5 s")
  #darrow(9.4cm, 1.85cm, 11.0cm, 1.85cm, label: "1.5 s")
  #darrow(9.4cm, 2.9cm, 11.0cm, 2.9cm, label: "2 s")
  #darrow(9.4cm, 4.05cm, 11.0cm, 4.05cm, label: "3 s")
  #dnode(11.2cm, 0.2cm, 4.2cm, 5.0cm,
    "Decision after about 7 s: shortlist, maybe-pile, or reject. Nothing on page 2 is read before this decision.",
    fill: rgb("#f7f3ee"))
]

So the top third of page one carries the whole decision. Three consequences:

+ *Your best project goes first*, not in date order. Nobody is checking your chronology.
+ *The skills line goes above the projects*, because the recruiter is ticking a checklist.
+ *Never put anything important on page two.* For a fresher there should be no page two.

#table(columns: (auto, 1.4fr, 1fr),
  align: (left, left, left),
  [*Seconds*], [*What they are checking*], [*What kills you here*],
  [0--1], [Name, contact, links], [A dead GitHub link. A mail id like `coolboy_143`.],
  [1--3], [Degree, branch, year of passing], [Year of passing missing, so they cannot tell if you are eligible.],
  [3--5], [Skills row against the must-have list], [Skills written as "web technologies", "programming".],
  [5--7], [First project title and first bullet], [A title like "Final Year Project". Say what it *does*.],
)

#trap[
*The `coolboy_143` problem is real.* Your mail id appears next to your name at the top of
every application and on every calendar invite. Make one that is `firstname.lastname` plus
digits if needed. It costs five minutes and it removes a bad first impression you will never
be told about.
]

#trap[
*Dead links are worse than no links.* If your resume says GitHub and the profile has three
empty repositories from 2023, the recruiter now has evidence *against* you. Either fix the
profile before you send the resume, or remove the link. Same for a portfolio site that does
not load.
]

#section[Three hiring machines, not one]

The same word "interview" means three different machines. This book uses three tiers, and
in *this* book the tiers mean the following.

#table(columns: (auto, 1.2fr, 1.2fr, 1fr),
  align: (left, left, left, left),
  [*Tier*], [*What the round is*], [*Typical companies*], [*What wins*],
  [1], [Standard HR screen. Tell me about yourself, strengths, why us, relocation, bond.],
     [TCS, Accenture, Infosys, Wipro, Capgemini, Cognizant],
     [Clarity, calm, a clear yes on mobility and joining.],
  [2], [Cross-cultural and regional. Work pass reality, communication style, why this region.],
     [Grab, Sea/Shopee, GIC, DBS, Agoda, SCB, LINE MAN, Razer],
     [Specific, practical answers about moving and working across cultures.],
  [3], [Structured behavioural. Deep STAR probing, follow-ups, written scorecards.],
     [Google, Amazon, Microsoft, Goldman Sachs, D. E. Shaw, Adobe, Uber],
     [One real story, told in detail, that survives five follow-up questions.],
)

#subsection[What changes between the tiers]

#table(columns: (auto, auto, auto, auto),
  align: (left, left, left, left),
  [], [*Tier 1*], [*Tier 2*], [*Tier 3*],
  [Length of HR round], [10--20 min], [25--40 min], [45--60 min],
  [How many stories needed], [1--2], [3--4], [6--10],
  [Follow-up depth], [rarely], [2 levels], [4--6 levels],
  [Notes taken], [checklist], [notes], [written evidence + rating],
  [Decided by], [the interviewer], [panel], [panel + an independent reviewer],
  [Biggest risk to you], [sounding rehearsed], [being vague about relocation], [a story that falls apart under probing],
)

#trick[
The climb is real. A Tier-1 answer is a Tier-3 answer with the follow-ups removed. If you
build *one* honest story properly — with the numbers, the names, the thing that went wrong
— you can shorten it for Tier 1 and expand it for Tier 3. You do not need three sets of
material. You need one set, told at three depths.
]

#section[STAR — the four labels you will use all book]

Every behavioural answer in this book is written in four labelled parts. Learn the labels
now; Chapter 4 goes deep.

#formulas(title: "STAR")[
*S — Situation.* Where, when, who, and what was going on. Two sentences. No more.

*T — Task.* What *you personally* had to do. Not "we". The word "I" must appear here.

*A — Action.* What you actually did, step by step. This is the longest part — about
half the whole answer. Verbs, decisions, and why you chose each one.

*R — Result.* What changed. A number if one exists. Then what you learned or changed
about how you work.

*Rough shape:* S 15%, T 10%, A 55%, R 20%.
]

#trap[
*The number one STAR failure is the Action part collapsing into one sentence.*
"So I fixed it and it worked." You just deleted the only part the interviewer was scoring.
]

#section[Worked examples]

Every example below shows a *weak* answer and a *strong* answer for the same student, and
names exactly what changed. The strong answers here are *filled examples of a structure*.

#formulas(title: "Read this before every example in this book")[
*You must substitute your own real experience.* Do not memorise these words. If you say a
story that is not yours, the first follow-up question will end the interview, because the
follow-up asks for a detail only the real person would know. Use the *structure*. Put your
own project, your own numbers, your own mistake into it.

*This book will never teach you to invent experience.* Where you have a real weakness — a
backlog, a gap year, a low CGPA, a rejection — you will be taught to state it plainly and
then move to evidence of improvement. That works. Lying does not, and it is also how offers
get withdrawn after a background check.
]

#tier-header(1)

#ex(1, tier: 1, asked: "TCS NQT · pattern")[
"Walk me through what you understand about our hiring process, and where you think you are
strongest."
]

#sol[
This looks like small talk. It is a test of whether you researched anything. Structure:
*(a)* name the stages you have been through, *(b)* name the stage you are in, *(c)* name
your strongest stage with one piece of evidence, *(d)* name the stage you are still growing
in, honestly.

*Weak version first.*
]

#trap[
*WEAK:* "Sir, I have applied through the portal and given the test. I think I am strong in
everything. I am a quick learner and hardworking, so any process is fine for me."
]

#sol[
*STRONG:* "I have cleared the online test — the aptitude and the coding section — and this
is my HR round. I think my strongest part is the project round: I built the booking service
myself, so I can explain any line in it. The part I am still building is speed on
data-structure questions under a timer. I have been doing two timed problems a day since
January; I have gone from finishing about one problem in 45 minutes to two."

*What changed, exactly:*
- "Strong in everything" $->$ one named strength with one named piece of evidence.
- "Quick learner" $->$ a measurable rate of learning: 1 problem per 45 min $->$ 2.
- Added an honest weak area. This raises trust instead of lowering it.
- Named the actual stages, which proves you read something about the company.
]

#ex(2, tier: 1, asked: "Infosys · pattern")[
"We hire for many locations. Are you okay with relocation, and with a shift that may be at
night?"
]

#sol[
The company is not curious. It is protecting itself from an offer that gets rejected in
month two. It wants a *specific, informed yes* — or an honest constraint stated early.

*Structure:* (1) direct answer in the first sentence, (2) evidence that you have thought
about it practically, (3) any genuine constraint, stated once and without drama.
]

#trap[
*WEAK:* "Yes sir, anything is fine, I am very flexible, wherever you send me I will go."

Why this is weak: it is the same sentence every candidate says, so it carries no
information. Worse, recruiters have learned that maximum flexibility stated instantly often
becomes a decline letter later. It reads as "I have not thought about this."
]

#sol[
*STRONG:* "Yes to relocation. I have already looked at what it means: I would need about
three weeks after the offer letter to arrange a place and close things at home, and I have
family support for that. On night shifts — yes, I can do rotational nights. I did a
six-week stretch of 10 p.m. to 2 a.m. work during my internship because the deploys were at
night, so I know what it does to my sleep and how to manage it. The one thing I would ask
for is the rotation calendar in advance so I can plan."

*What changed, exactly:*
- Vague yes $->$ yes plus a concrete lead time (three weeks).
- Claim of flexibility $->$ evidence of having actually done nights before.
- Added one reasonable ask. Asking for a calendar is not a red flag. It reads as an adult.
]

#note[
If your honest answer is *no* — say a medical reason, or a family responsibility — say it in
the first sentence, say what you *can* do, and stop. "I cannot do permanent night shifts
because of a health condition I manage. Rotational days and evenings are fine, and I am
fully open on location." A clear constraint costs you some roles. A hidden constraint costs
you the job in month three, with a bad exit on your record.
]

#ex(3, tier: 1, asked: "Wipro · pattern")[
"Why did you apply to us? You have applied to six companies today."
]

#sol[
*Structure:* (1) one specific true thing about the company, (2) the link to something you
actually did, (3) what you want from the first two years. Never say "it is a reputed
company", because it is true of every company on the list and therefore says nothing.
]

#trap[
*WEAK:* "It is a very reputed company with a good work culture and a global presence. It
will be a good platform for my career growth and I can learn a lot here."

Why this is weak: swap in any company name and the sentence is unchanged. A sentence that
survives a name-swap is a sentence that carries no information.
]

#sol[
*STRONG:* "Two reasons. First, the role is a Node and SQL backend role, and that is exactly
the stack I built my booking project in — I am not switching stacks to take this job.
Second, you train freshers in a structured programme with a defined stream allocation, and I
want the first year to be structured rather than being dropped on a client alone. What I
want from two years here is to move from writing endpoints to owning a service, including
its on-call."

*What changed, exactly:*
- "Reputed" $->$ a reason that would be false for a company with a different stack.
- Added the link to their own work (the booking project).
- Added a concrete two-year goal, which answers the unasked question "will you leave in
  eight months?"
]

#ex(4, tier: 1, asked: "Capgemini · pattern")[
"Our offer includes a service agreement. Are you comfortable with that?"

This is the first hard-money question in the funnel. Chapter 6 goes deep. Here is the honest
version in short.
]

#sol[
*What a service agreement (often called a bond) usually is.* You agree to stay for a period
— commonly 12 to 24 months. If you leave earlier, you owe a stated amount, often framed as
recovery of training cost. Sometimes original certificates are asked for. Sometimes an
amount is held back from salary and returned at the end.

*What you must find out before you sign, in writing:*

+ The exact lock-in period, in months, and the date it starts — offer date, joining date,
  or end of training?
+ The exact amount, and whether it reduces month by month or stays flat until the last day.
+ Whether original degree certificates are retained. Ask for a written receipt if they are.
+ What counts as an exit — does termination by the company, or a medical exit, also trigger
  it?
+ Whether the amount is payable by you or by a future employer, and whether the company
  will give a relieving letter on payment.

*Structure for answering in the room:* (1) a calm yes or a conditional yes, (2) two factual
questions, (3) no negotiation attempt at the HR-round stage.
]

#trap[
*WEAK (aggressive):* "Bonds are not legally valid, everyone says so. I will sign but I can
leave anytime."

*WEAK (scared):* "Yes yes, no problem, whatever you say, I will sign anything."

The first ends the conversation and sometimes the offer. The second means you sign a
two-year lock-in without knowing the amount, and find out in month nine.
]

#sol[
*STRONG:* "Yes, I am comfortable with a service agreement in principle — I am looking for a
first job I stay in, not one I leave in six months. Two things I would want in the offer
letter so I can plan: the exact duration and from which date it counts, and the exact
recovery amount. If the company holds original certificates, I would want a written
acknowledgement. Once I see those, I do not expect any problem."

*What changed, exactly:*
- Argument or panic $->$ a yes with two factual, non-emotional questions.
- Moved the whole issue to *the written offer*, which is where it belongs.
- Said the thing HR wants to hear — "I intend to stay" — and it is true, so it is safe.

*Real strategy, plainly:* the time to negotiate a bond is *after* you hold the written offer
and *before* you sign it, with the recruiter, over email. Not in the HR round. In the HR
round your only job is to stay in the process and get the terms on paper.
]

#ex(5, tier: 1, asked: "Cognizant · pattern")[
"That is all from my side. Do you have any questions for us?"

This is the last question in almost every round, and most candidates throw it away.
]

#sol[
It is scored. Not heavily, but it is the last thing written on the form, and "asked no
questions" reads as "not really interested" or "did not prepare".

*Structure:* ask two questions, in this order — one about *the work*, one about *how you
will be judged*. Then thank them. Do not ask more than three; the interviewer has a next
candidate.
]

#trap[
*WEAK:* "No ma'am, you have explained everything very well. I have no questions."

*ALSO WEAK:* "What is the salary?" and "How many leaves do I get?" as the *first* question in
a technical or HR round. These are fair questions — ask them of the recruiter, in the offer
conversation, not of the engineer who just interviewed you.
]

#sol[
*STRONG:* "Two questions. First, for someone joining this team as a fresher, what does the
first ninety days look like — is there a training track, and do I get a defined area to own
after it? Second, six months in, what would make you say this hire went well? I would like to
know what I am being measured on before I start, not after."

*What changed, exactly:*
- Silence $->$ two questions that show you are thinking about *doing the job*.
- The second question is the strong one. It asks for the success criteria, which is exactly
  the thinking a manager wants to see, and it gives you real information.
- Neither question can be answered from the company website, so it proves you are listening
  rather than reciting.

*Three more you can keep in your pocket:*
- "What is the biggest thing that slows this team down right now?"
- "How does work reach me — a ticket, a mentor, a standup?"
- "What is the one thing a fresher usually gets wrong here in the first month?"
]

#ex(6, tier: 1, asked: "Accenture · pattern")[
"If another company gives you an offer with a higher package, will you leave us?"
]

#sol[
This is a *risk* question wearing a *loyalty* costume. The company is trying to predict a
decline. Answering with a promise of undying loyalty is not believed and is not needed.

*Structure:* (1) do not pretend money does not matter, (2) name the thing that actually
decides it for you, (3) give a concrete reason this role satisfies that thing, (4) stop.
]

#trap[
*WEAK (the over-promise):* "No sir, never. I will stay in your company for my whole life. Money
is not at all important to me, only learning matters."

Nobody believes this, and it is easy to disprove: if money truly did not matter, you would not
have asked about the package. An answer the interviewer does not believe is worse than a
careful one.
]

#trap[
*WEAK (the honest-but-blunt):* "Obviously I will take whichever offer pays more."

True for many people. Still a decline risk on a form, stated by you, in your own words, for
free.
]

#sol[
*STRONG:* "Money matters to me — I would not pretend otherwise. But at this stage the thing
that decides it for me is what I will be doing in the first year, because that is what sets
up the next five. This role is backend on Node and SQL, which is where I want to get deep,
and there is a defined training track. A higher number for a role where I do support tickets
for a year would not be a better deal for me. If I accept here, I am accepting to stay and
learn, and I do not treat an acceptance as something to shop around afterwards."

*What changed, exactly:*
- Denial of a real motive $->$ acknowledging it in one clause and moving on.
- "I will never leave" $->$ a *decision rule* they can believe: first-year work beats a
  short-term number.
- Added the specific thing about this role that satisfies the rule.
- Ended with the sentence HR actually needed: an acceptance here is not a bargaining chip.
  Only say this if it is true for you.
]

#note[
*If you genuinely are holding another offer,* do not hide it and do not brandish it. "I do
have another offer in hand with a deadline of the 14th. I would rather join here, and I am
telling you the date so we can be realistic about timelines." That is a fact, given early,
that helps both sides. Chapter 6 covers the full playbook for competing offers.
]

#tier-header(2)

#ex(7, tier: 2, asked: "Grab · pattern")[
"You are applying from India for a role in Singapore. Talk me through how you have thought
about the move."
]

#sol[
This is a *risk* question, not a *passion* question. A cross-border hire that falls through
costs the company months. Your answer must reduce three risks: the pass risk, the money
risk, and the will-they-actually-come risk.

*Structure:* (1) I know it needs an employment pass and that the company sponsors it,
(2) here is my realistic timeline, (3) here is what I have already done, (4) here is what I
would need from you.
]

#trap[
*WEAK:* "Singapore is a beautiful country and it is a hub for technology. I have always
dreamed of working abroad and I am very excited about this opportunity. I am ready to join
immediately."

Why this is weak: "always dreamed" is about you, not about the risk they carry. "Join
immediately" is not possible for a cross-border hire and shows you have not checked.
]

#sol[
*STRONG:* "I understand the role needs an employment pass and that the company files it, so
my part is documents and timing. Realistically I am looking at about two weeks to get my
degree and transcript attestations in order, then the filing time on your side, then two to
four weeks for flights and housing. So eight to ten weeks from an offer, and I would rather
give you a date I can keep than say immediately. I have kept my passport valid until 2032
and my transcripts are already digitised. What I would want from you is which month you need
me to start, so I work backwards from that, and whether there is relocation support for the
first month of housing."

*What changed, exactly:*
- Emotion about the country $->$ a timeline with named steps.
- "Immediately" $->$ a defensible 8--10 week estimate with the reasoning shown.
- Added proof of preparation: passport validity, digitised transcripts.
- Ended by asking for their constraint, which turns it into a planning conversation.
]

#note[
*Be honest about what you do not know.* Pass rules, salary thresholds and quotas change, and
they differ by country and by year. Never state a rule as fact in an interview. Say "my
understanding is X — is that still current?" You get the right answer and you look careful
instead of wrong.
]

#ex(8, tier: 2, asked: "Shopee · pattern")[
"Our team is spread across four countries and three time zones. How do you work with people
you never meet?"
]

#sol[
*Structure:* (1) name the specific problem of distance — it is not "communication", it is
*delay*, (2) one real example of how you handled delay, (3) the habit you built from it.
]

#trap[
*WEAK:* "I have very good communication skills and I am a good team player. I can adjust
with anyone and I am always available on call."

"Always available" across three time zones means "I have not thought about this". It also
promises something that burns people out in two months.
]

#sol[
*STRONG:* "The real problem is not language, it is that a question costs a whole day if the
other person is asleep when I ask it. In my final-year project my two teammates were on a
different schedule from me — they worked nights. We lost about three days in the first two
weeks to back-and-forth. So we changed two things: every question had to be written with
what I had already tried and what I would do if there was no reply by my evening, and we
kept one shared document with decisions and dates instead of deciding in chat. After that we
did not lose a full day to a blocked question again. The habit I kept is writing the
fall-back into the question itself."

*What changed, exactly:*
- "Good communicator" $->$ a named failure mode (a blocked question costs a day).
- Added a real cost: three days lost.
- Added two specific mechanisms, not adjectives.
- Ended with a portable habit, which is what the interviewer will write on the form.
]

#ex(9, tier: 2, asked: "DBS · pattern")[
"In your culture, is it acceptable to tell a senior person they are wrong? How would you do
it here?"
]

#sol[
This is genuinely asked, and it is not a trap about your country. The interviewer wants to
know whether a bad decision in a meeting will be *corrected* or *silently followed*.

*Structure:* (1) answer the direct question honestly, (2) separate *what* you would say from
*how and where*, (3) one real example, (4) what you would do if overruled.
]

#trap[
*WEAK:* "No sir, in our culture we always respect seniors, so I would accept whatever they
say and do it."

This is a straight fail. Read the scorecard line again: will a bad decision be corrected?
]

#sol[
*STRONG:* "I would say it, and I would be careful about where. In college I worked on a
project where the team lead wanted to store seat availability as a count only. I thought it
would double-book under two simultaneous bookings. I did not argue in the group meeting — I
messaged him with a four-line example showing two requests interleaving, and asked if I had
misunderstood. He had not seen that case, and we moved to a row lock per seat. Two things I
try to keep: disagree with an example rather than an opinion, and do it in the smallest room
possible first. If I am overruled after that and it is not a safety or data-loss issue, I
write down my concern once, then commit fully and help make it work."

*What changed, exactly:*
- "I would accept whatever they say" $->$ "I would say it, and here is how."
- Added a concrete technical example, which proves the story is real.
- Added the *disagree-then-commit* ending, which is exactly what the form is scoring.
- Separated the question of *whether* to speak from *where* to speak.
]

#ex(10, tier: 2, asked: "Agoda · pattern")[
"Our working language is English, and the team includes people whose first language is not
English either. How comfortable are you?"
]

#sol[
This is not a grammar test. The interviewer is checking whether you will *say you did not
understand* instead of nodding and getting it wrong.

*Structure:* (1) an honest statement of your level, (2) the habit you use when you do not
understand, (3) the habit you use when *they* may not have understood you.
]

#trap[
*WEAK:* "My English is excellent, I have no problem at all, I scored very well in English in
school."

School marks are not the measure. Also, a candidate who claims zero difficulty is exactly the
candidate who will nod through a misunderstood requirement.
]

#sol[
*STRONG:* "I am comfortable in English for technical work — I read documentation in it and I
wrote my project report in it. Two things I am honest about. When I lose a sentence, usually
because of speed or an accent I am new to, I say so and repeat back what I understood in my
own words rather than nodding. In my internship my mentor was from Kerala and spoke fast, and
for the first week I got two tasks slightly wrong before I started doing that. And when I
explain something, I write the key decision in a message afterwards, so there is a text
version that does not depend on anyone catching every word."

*What changed, exactly:*
- A claim about fluency $->$ a claim about *behaviour when communication fails*, which is the
  actual risk.
- Added a real cost (two tasks slightly wrong) and the correction.
- Added the written-summary habit, which is the single most valuable cross-border habit and
  the one the form will record.
]

#ex(11, tier: 2, asked: "Sea/Shopee · pattern")[
"Most people who move for a job go home after two or three years. Will you?"
]

#sol[
An expensive question for them: relocation, a pass, and onboarding cost real money, and they
lose it if you leave at month 30.

*Structure:* (1) do not promise forever, (2) give the *conditions* under which you would stay,
(3) show you have thought about the practical side of staying, (4) be truthful about family
obligations rather than hiding them.
]

#trap[
*WEAK:* "No no, I will never go back, I want to settle there permanently."

Said by almost everyone, believed by almost nobody, and it also hides a real constraint that
will surface later.
]

#sol[
*STRONG:* "I will not promise forever, because I do not think you would believe it and I do
not know what year ten looks like. What I can tell you is what would make me stay, and it is
the work: if I am still learning something I could not learn elsewhere, I stay. Practically, I
have looked at what a longer stay involves — the pass renewal cycle, and that my parents would
visit rather than move. My mother has a health condition that is stable, and my brother is in
the same city as them, so I am not the person who has to be physically present. I am planning
on a first commitment of at least three to four years, and I would rather say that number and
keep it."

*What changed, exactly:*
- An unbelievable "forever" $->$ a stated, keepable number with the conditions attached.
- Added evidence of practical thinking (renewal cycle, who covers family responsibility).
- Disclosed a real family constraint calmly, with the mitigation, instead of hiding it.
- Gave them the decision rule — "if I am still learning, I stay" — which is something a
  manager can actually act on.
]

#tier-header(3)

#ex(12, tier: 3, asked: "Amazon · pattern")[
"Tell me about a time you took ownership of something that was not your job."

Then expect these follow-ups: *"What exactly did you do first?"* $->$ *"Why that and not the
obvious thing?"* $->$ *"What did it cost?"* $->$ *"What did your teammate think?"* $->$
*"What would you do differently?"*
]

#sol[
This is the tier where your answer is written down as evidence. Structure is STAR, and then
the follow-ups eat the *Action* part, so the Action part must be deep enough to survive five
questions.

*Weak first, so you can see the difference in size.*
]

#trap[
*WEAK:* "In our final year project the website was very slow. So I took ownership and fixed
the database. After my changes the website became fast and my team was very happy. I learnt
that ownership is very important."

Count what an interviewer can write on the form from this: nothing. No number, no decision,
no cost, no alternative considered. It also dies on follow-up one — "what exactly did you do
first?" has no answer inside it.
]

#sol[
*STRONG, with the four parts labelled:*

*Situation.* "In my final year we built a bus seat booking service for the college transport
office — three of us, about ten weeks. Two weeks before the demo, the transport clerk told
us search felt slow, but nobody owned performance; we had split the work by feature, not by
concern."

*Task.* "It was not assigned to me — I was on the payments screen. I decided to own it
because I was the only one who had touched the database schema, and if it was still slow at
the demo the whole project would read as broken."

*Action.* "First I refused to guess. I wrote a small script that hit the search endpoint 200
times with the real route data and printed the median and the 95th percentile, because the
clerk's complaint was about the bad cases, not the average. The median was 0.4 seconds and
the p95 was 1.9 seconds, so it really was the tail.

Then I turned on the slow query log and found a single query joining bookings to seats and
filtering by route and date. It was scanning the whole bookings table — about 90,000 rows —
because the only index was on the primary key.

I considered three fixes. Caching the results: fastest to write, but the data changes on
every booking, so a stale cache would show a seat that was already sold — I ruled it out on
correctness. Denormalising a seats-available count onto the route row: fast, but it
introduces a write-conflict problem under simultaneous bookings, and we had no time to get
locking right. Adding a composite index on route and travel date: cheap, reversible, no
change to application code.

I took the index. I measured again with the same 200-request script: p95 went from 1.9
seconds to 0.31 seconds. I also measured the write side, because an index is not free —
booking insert went from about 6 ms to about 8 ms, which was fine for our volume, and I said
so in the report rather than hiding it.

Then I did the part that was actually uncomfortable: I told my teammate who wrote the search
feature, before I told the group. I showed him the log line, not my opinion. He added the
migration himself so it stayed his code."

*Result.* "p95 dropped from 1.9 s to 0.31 s, about 6 times faster on the bad cases. The demo
ran without anyone mentioning speed, and the transport office used it for two terms.

What I changed permanently about how I work: I now measure the 95th percentile, not the
average, because the average hid the exact thing the user was complaining about. And when I
find someone else's problem I take it to them first with data, not to the group."

*What changed between weak and strong, exactly:*
- "Very slow" $->$ measured p95 of 1.9 s. A complaint became a number.
- "Fixed the database" $->$ found the query, named the table size, named the missing index.
- Added *rejected alternatives with reasons*. This is the single biggest upgrade. It turns
  "I did a thing" into "I made a decision."
- Added the *cost* of the fix (writes 6 ms $->$ 8 ms). Admitting a trade-off raises your
  score; pretending there is none lowers it.
- Added the human action — telling the teammate privately, letting him own the commit.
- "I learnt ownership is important" $->$ two specific, portable habits.
]

#subsection[Surviving the follow-ups]

The strong answer above was built so that every follow-up already has an answer inside it.
Here is the probe, and the sentence in the answer that survives it.

#table(columns: (1.1fr, 1.4fr),
  align: (left, left),
  [*Follow-up probe*], [*What you say, drawn from the story you already told*],
  [What did you do first?], [Measured it. 200 requests, median and p95, before touching anything.],
  [Why p95 and not the average?], [The complaint was about bad cases. The average hid them: 0.4 s looked fine.],
  [Why not caching?], [Data changes on every booking; a stale cache can sell a sold seat. Correctness beat speed.],
  [What did the fix cost?], [Writes went 6 ms $->$ 8 ms, and one more index to maintain in migrations.],
  [What did your teammate think?], [I showed him the slow query log privately and he wrote the migration himself.],
  [What would you do differently?], [Measure in week two, not week eight. We had no performance owner at all.],
  [What if the index had not worked?], [Next step was the denormalised count with a row lock per seat; I had the design but not the time.],
)

#trick[
*Build one story, then attack it yourself.* Write your story, then ask yourself the seven
probes above. Any probe you cannot answer is a hole. Fill it with the truth — go and check
the real number if you still can. Do not fill it with an invention: at Tier 3 the
interviewer will ask a follow-up to your follow-up, and inventions do not survive two levels.
]

#ex(13, tier: 3, asked: "Google · pattern")[
"Tell me about a time you failed."
]

#sol[
*Structure:* (1) a real failure with a real cost, (2) your own contribution to it, in the
first person, (3) what you did *immediately after*, (4) the change that stuck, (5) evidence
that the change stuck.

The scoring line is *"learns from failure"*, and the evidence they need is step 5. Most
candidates give steps 1--4 and stop.
]

#trap[
*WEAK (the fake failure):* "My biggest failure is that I am a perfectionist, so I spend too
much time on details. Once I worked so hard on a project that I did not sleep."

This is the oldest non-answer there is, and it reads as "I will not tell you anything true".
The scorecard line gets a "no evidence", which is scored the same as a bad answer.
]

#trap[
*WEAK (the blame version):* "We failed because my teammate did not do his part and the
faculty guide kept changing the requirements."

Everything might be true. It still fails, because the form asks what *you* learnt, and the
answer contains no action by you.
]

#sol[
*STRONG, four parts labelled:*

*Situation.* "In my third year I ran the technical event for our department fest. 180
students registered online."

*Task.* "I owned registration and the day-of check-in, alone."

*Action.* "I built the registration form myself and stored entries in a spreadsheet. I never
tested it above about 20 entries. On the morning of the event, check-in used the same
spreadsheet over the college wifi, and with four volunteers editing at once it started
overwriting rows. About 25 students' entries were lost. I did not have a backup and I did not
have a paper list.

What I did in the moment: I stopped using the sheet entirely, put two volunteers on paper
registers split alphabetically, and re-entered everything that evening. The event started 35
minutes late.

What I did after: I found the 25 affected students from the payment records and mailed each
of them the same day with what happened and their confirmed slot. Nobody dropped out."

*Result.* "The failure was mine: I tested a system at 20 rows and ran it at 180, and I had no
fallback for a tool I did not control.

What changed and stuck: for the next event, six months later, I ran a dry run at full size —
I generated 200 fake entries and had four people hit check-in at once, which broke it again
in testing, where breaking is free. We moved to a simple database-backed form and kept a
printed list as a paper fallback. 240 students checked in with no data loss and we started on
time. I still do the two things I learned there: test at the size you will actually run at,
and always have one fallback that does not need the network."

*What changed, exactly:*
- Fake weakness $->$ a real failure with a real, countable cost (25 records, 35 minutes).
- No blame. The words are "I never tested", "I did not have a backup".
- Added what was done *in the moment*, which shows behaviour under stress.
- Added the *repair* — mailing the 25 students. Interviewers score this heavily.
- Added step 5, the evidence it stuck: the second event, at 240 people, with the measured
  result. Without step 5 this is a story. With step 5 it is a pattern.
]

#ex(14, tier: 3, asked: "Microsoft · pattern")[
"Give me an example of a decision you made with incomplete information."
]

#sol[
*Structure:* (1) what was missing and why you could not just go and get it, (2) the deadline
that forced a decision, (3) how you *reduced* the uncertainty cheaply, (4) the decision and
the reversibility of it, (5) what you would have done if it went wrong.

Point 4 is the one that separates the top answers: *did you choose a decision you could undo?*
]

#trap[
*WEAK:* "I did not have enough information but I trusted my gut and took the decision, and
luckily it worked out well."

"Luckily" hands the interviewer a rating for you, and it is not a good one.
]

#sol[
*STRONG, four parts labelled:*

*Situation.* "During my internship I was asked to add a CSV export to an internal report
page, three days before a monthly review."

*Task.* "Nobody could tell me how big the export would get. The person who owned the data had
left, and the report team was on leave until after the review."

*Action.* "I could not get the real answer, so I bought information cheaply instead. I ran a
count on the table for the last three months: about 40,000 rows a month, growing roughly 8%
a month. That gave me a range rather than a fact: somewhere between 40,000 and maybe 70,000
rows within a year.

Then I chose based on the range, not on the middle. Building the CSV fully in memory would
be 30 lines and would probably hold at 70,000 rows, but would fall over silently at some
unknown point beyond it. Streaming the rows out was about 60 lines and had no size limit.

I took the streaming version, because the failure mode of the in-memory one was a crash in
production on a day nobody was watching, and the extra cost was half a day of my time. I also
added a hard cap with a clear error message at 500,000 rows, so that if my growth guess was
badly wrong the system would say so instead of dying quietly."

*Result.* "The export shipped in time for the review. It was still running a year later; the
table had crossed 90,000 rows a month by then, which the in-memory version would not have
survived.

What I took from it: when I cannot get the number, I get the *range* and design for the bad
end of it, and I prefer the decision that fails loudly over the one that fails silently."

*What changed, exactly:*
- "Trusted my gut" $->$ bought cheap information (a row count and a growth rate).
- A single guess $->$ a range, with the decision made against the bad end.
- Added the *failure mode* comparison. Crash-in-production versus half a day of work is a
  real engineering trade-off and it is what a senior interviewer is listening for.
- Added the safety valve (the 500,000-row error), which shows you planned for being wrong.
- "Luckily it worked out" $->$ evidence a year later.
]

#ex(15, tier: 3, asked: "Goldman Sachs · pattern")[
"You have been rejected by us before. Why should this time be different?"

This is asked, it is uncomfortable, and it has a good answer.
]

#sol[
*Structure:* (1) accept it in one sentence, no defensiveness, (2) name the actual reason, as
specifically as you know it, (3) the work you did, with dates and volume, (4) evidence that
is *external* to your own opinion.

Never say "the interviewer did not understand my answer". Even when that is what happened.
]

#trap[
*WEAK:* "Last time I was unlucky, the questions were from a topic that was out of syllabus,
and the interviewer was in a hurry. This time I am more confident."

Confidence is not evidence. "Unlucky" tells the panel that a second rejection would also be
luck, so there is no reason to expect a different result.
]

#sol[
*STRONG:* "Yes — I was rejected in the second technical round in August last year. The
feedback I got was that I could not finish the coding question in time; I got a working
brute-force solution and did not reach the optimal one before the clock ran out. That was
accurate, and it was a speed problem, not a concept problem.

Since then I have done timed practice four days a week — 210 problems logged with the time
taken for each. In August my median time on a medium problem was about 41 minutes. Over the
last month it is 22. I also changed how I start: I now spend the first three minutes writing
the brute force in comments and its complexity before writing any code, which is what stops
me from rewriting halfway through.

The external evidence is that I cleared the online round this time with all test cases
passing in 38 of the 60 minutes, which I did not do last year."

*What changed, exactly:*
- "Unlucky" $->$ the real reason, stated in the company's own words from the feedback.
- Vague effort $->$ a logged volume (210 problems) and a measured before/after (41 $->$ 22
  minutes).
- Added a *method* change, not just more hours. Anyone can say they practised more.
- Ended on evidence from outside the candidate's own head: this year's test result.

*If you were given no feedback,* say so and then say what you diagnosed yourself: "I was not
given specific feedback. My own read was that I was weak on X, because that is where I froze.
So here is what I did about X."
]

#ex(16, tier: 3, asked: "Uber · pattern")[
"Tell me about a time you disagreed with someone and you turned out to be wrong."

Note the twist. Most candidates prepare the version where they were right.
]

#sol[
The scorecard line is usually something like *"seeks the truth over being right"*. The
evidence they want is: did you change your mind when the data changed, and how fast?

*Structure:* (1) the disagreement, stated fairly from both sides, (2) what evidence you
demanded, (3) the moment you were shown to be wrong, (4) what you did in the next hour,
(5) whether you changed how you form opinions.
]

#trap[
*WEAK:* "I disagreed about which framework to use. Later I realised my teammate was right and
I accepted it gracefully. I learnt that we should always listen to others."

No evidence, no cost, no moment. "Always listen to others" is a proverb, not a behaviour.
]

#sol[
*STRONG, four parts labelled:*

*Situation.* "In a four-person hackathon team we had to store about 300 MB of sensor readings
and query them by time range. I wanted a relational database. A teammate wanted flat CSV files
read with a script."

*Task.* "I was the loudest voice for the database, so if we went that way and it was wrong, the
lost time was on me."

*Action.* "I argued from principle: indexes, types, no parsing cost. He argued from the clock —
we had 26 hours. Rather than keep arguing I asked for a test we could both accept: load one
day of data both ways and time a range query. That took 40 minutes and it settled it.

The result was not what I expected. His version answered a one-day range query in about 0.9
seconds. Mine took 6 minutes to import before it answered anything, and we had to re-import
every time the sensor format changed, which it did twice that night. For a 26-hour project
where the data was written once and read a few times, his solution was correct and mine was
theory.

I said so out loud, in front of the team, in one sentence: 'The measurement says you are
right, we are doing it your way.' Then I spent the next hour writing the query script with him
rather than sulking about it. I did add one thing from my side that he agreed with — a check
that rejected malformed rows on load, because the format kept changing."

*Result.* "We finished with four hours to spare and the parsing check caught 1,100 bad rows
that would have been silent wrong answers.

What changed in how I argue: I now try to convert a disagreement into the cheapest experiment
that would settle it, and I try to say what evidence would change my mind *before* I see it.
If I cannot name that evidence, I am not arguing, I am just preferring."

*What changed, exactly:*
- "I realised he was right" $->$ a named experiment with a number that proved it.
- Added the cost of the experiment (40 minutes) — it shows judgement about how much to spend
  settling an argument.
- Added the *public* concession. Interviewers score changing your mind visibly.
- Added what you contributed *after* losing the argument, which shows you did not disengage.
- "Always listen" $->$ a concrete, portable rule: name the evidence that would change your
  mind, in advance.
]

#ex(17, tier: 3, asked: "Adobe · pattern")[
"Tell me about a time you had to say no, or push back on something you were asked to do."
]

#sol[
The line being scored is usually about *judgement and backbone* — will this person take on an
impossible amount of work and then quietly miss everything?

*Structure:* (1) what was asked and by whom, (2) why yes would have been the wrong answer, in
numbers, (3) what you offered *instead* — a no is only strong when it comes with an
alternative, (4) the outcome, (5) how the relationship survived.
]

#trap[
*WEAK (the pushover):* "I never say no. If my senior asks for something I always find a way to
do it, even if I have to work all night."

This reads as: cannot estimate, cannot prioritise, will silently fail and tell nobody.
]

#trap[
*WEAK (the refuser):* "I told him it was not my responsibility and that he should ask someone
else."

Correct boundary, zero judgement, no alternative offered. This scores badly too.
]

#sol[
*STRONG, four parts labelled:*

*Situation.* "Two days before our project review, our guide asked us to also add a mobile
version of the dashboard."

*Task.* "I was doing the dashboard, so the estimate and the answer were mine to give."

*Action.* "I did not answer immediately in the meeting; I asked for an hour. I listed what a
usable mobile version actually needed — the chart library we used did not resize, so it was a
replacement, not a tweak: roughly 9 to 11 hours of work plus re-testing. Against that I had 14
hours left, and 6 of them were already committed to the parts of the review that were
definitely being graded.

So I went back with a no and two alternatives instead of just a no. Option A: I make the
existing dashboard readable on a phone — larger fonts, single column, no chart resizing — in
about 2 hours, so it does not look broken if someone opens it on a phone in the review. Option
B: I do the full mobile version and drop the export feature, which he had asked for the
previous week. I said plainly that I would not attempt both and hit the deadline, and that if
I tried, the risk was not that mobile would be rough, it was that *nothing* would be finished.

He took option A."

*Result.* "The review went ahead with everything finished. He opened it on his phone during the
review, and it was readable, which was the actual thing he cared about — he had not been asking
for a full rebuild, he had been asking not to be embarrassed on a phone screen.

What I took from it: ask what the request is *for* before estimating it, and never deliver a
bare no. A no plus two costed options is a decision handed to the person who should be making
it, not a refusal."

*What changed, exactly:*
- "I always say yes" or "not my job" $->$ a costed estimate (9--11 hours against 14 available).
- Added the *named risk* of saying yes: not "it will be rough" but "nothing will be finished".
- Added two alternatives with prices. This is the whole answer, really.
- Added the discovery that the real requirement was smaller than the stated one, which is a
  senior-level observation and very well scored.
]

#section[After the last round: offer, money, paper]

Chapter 6 covers these in full. Here is the honest map so you know what is coming, and so a
recruiter's phone call does not catch you unprepared.

#subsection[The timeline]

#table(columns: (auto, auto, 1.4fr),
  align: (left, left, left),
  [*Step*], [*Typical wait*], [*What you should do in this window*],
  [Last round ends], [--], [Send a short thank-you mail the same day. Four lines.],
  [Verbal offer / call], [2 days -- 3 weeks], [Get the number, the location, the bond and the joining month *on this call*. Write them down.],
  [Written offer letter], [2 days -- 2 weeks after the call], [Read every clause. This is the only document that matters.],
  [Your acceptance], [they will push for same-day], [It is normal to ask for 2--3 working days. Ask in writing.],
  [Background check], [1--4 weeks], [Make sure every date and title on your resume matches your documents *exactly*.],
  [Joining], [1--6 months], [Keep in touch monthly. Offers do get deferred; a silent candidate is easier to defer.],
)

#subsection[Salary: the real strategy for a fresher]

#formulas(title: "What is actually negotiable, and when")[
*Mass campus hiring (Tier 1).* The number is fixed by the drive, printed in the notice, and
the recruiter genuinely cannot change it. Negotiating here wastes goodwill. What *can*
sometimes move: the location, the stream or technology allocation, and the joining date.
Ask for those instead.

*Off-campus and Tier 2 / Tier 3.* There is usually a band. The band moves for exactly two
reasons: (a) a competing written offer, (b) proven skills the role needs that other
candidates do not have. It does not move for need, effort, or marks.

*The single most useful habit:* do not say a number first if you can avoid it, and never say
a number you have not worked out.
]

#subsection[When they ask "what is your expected salary?"]

#trap[
*WEAK (the giveaway):* "Sir, as per company standards, anything you give is fine. I just want
to learn."

You have now capped yourself at the bottom of the band and told them you did not research.
]

#trap[
*WEAK (the wild number):* "35 lakhs per annum."

For a fresher role advertised at a fraction of that, this ends the conversation and marks you
as someone who has not checked reality. Note this is *not* about ambition. It is about having
no data.
]

#sol[
*STRONG (structure: deflect once, then give a researched range with a reason):*

"For a fresher backend role in Bengaluru, from what I have seen from seniors who joined last
year and from what is advertised, the range is roughly A to B. I would be looking in that
range, and I am more interested in the total package — including the bond terms and whether
there is a location allowance — than in one number. If you can share the band for this role I
can tell you straight away whether it works."

*Why this works:*
- Gives a range, not a point. A range is negotiable; a point is a target to push down.
- The range is *justified* by a source, so it does not sound invented.
- Moves the conversation to total package, which is where a fresher genuinely has room.
- Asks them for the band, which is the question you actually wanted answered.

*Getting A and B:* ask three seniors from your own college who joined the same kind of
company last year. This is the highest-quality data available to you and it costs three
messages. Adjust for city and for the year. Do not use figures from a website comment
section.
]

#subsection[Notice period, if you already have a job]

#formulas(title: "The three numbers you need")[
+ *Your contractual notice period.* Read your own appointment letter. 30, 60 and 90 days are
  all common.
+ *Whether buyout is allowed,* and who pays. Some employers permit you to pay for the
  unserved days. Some refuse regardless of payment.
+ *Your last working day, calculated from the date you would resign* — not a vague
  "two months".

*What to say:* "My notice period is 60 days from the date I resign. If I resign on the 1st,
my last working day is the 30th of the following month, so the earliest realistic joining
date is the 1st after that. Buyout of up to 30 days is allowed in my contract at my own cost,
so if you need me earlier I can try for that, but I cannot promise it because it needs my
manager's approval."

*Never* promise a joining date that requires your current employer to be generous. Promise
the date you can achieve without anyone's permission, and offer the earlier date as a
possibility.
]

#section[Reading a job post like an interviewer]

Everything above is easier if you read the post properly. A job post has four parts and they
are not equally important.

#table(columns: (auto, 1.5fr, auto),
  align: (left, left, left),
  [*Part of the post*], [*What it really is*], [*Use it for*],
  [Title + team], [The keyword the screen matches on], [Your resume headline],
  [Requirements / must-have], [The checklist the recruiter ticks], [Your skills line, in their words],
  [Nice to have], [Tie-breakers between shortlisted people], [Your project bullets],
  [Responsibilities], [What you will be asked about in rounds 4--6], [Choosing which stories to prepare],
  [Culture / values section], [The actual behavioural scorecard, published], [Mapping one story per value],
)

#trick[
The values section of a company's careers page is not marketing filler — at Tier 3 it is
often literally the list of lines on the scorecard. Print it. Write one honest story of your
own beside each line. If a line has no story, that is your gap, and you have weeks to go and
create a real experience that fills it: fix a bug in an open-source project, run an event,
take over a piece of a group project nobody wants. Creating the experience is legitimate.
Inventing it is not.
]

#section[A six-week plan that matches the funnel]

Put effort where the survival rate is worst. This is one honest allocation.

#table(columns: (auto, 1.3fr, auto),
  align: (left, left, left),
  [*Week*], [*Main work*], [*Time split*],
  [1], [Rewrite the resume against three real job posts (Chapter 2). Fix the PDF text test.], [70% resume, 30% coding],
  [2], [Aptitude drills, timed. Coding: two problems a day, timed.], [80% test prep],
  [3], [Same, plus write your *six core stories* in STAR (Chapter 4).], [60% test, 40% stories],
  [4], [Project deep-dive: be able to defend every choice you made (Chapter 5).], [50% project, 50% test],
  [5], [Hard questions: salary, bond, gaps, backlogs, rejections (Chapter 6).], [40% hard Qs, 60% mixed],
  [6], [Mock rounds out loud, with a timer and a recording. Fix the worst one.], [100% mocks],
)

#note[
*Out loud* is not optional. An answer that is perfect in your head is often 90 seconds too
long, or full of "basically" and "actually", when it leaves your mouth. Record one answer on
your phone and listen to it once. It is unpleasant and it is the fastest improvement
available to you.
]

#section[Online rounds: the part nobody prepares]

Most first rounds now happen over a video call or a proctored browser tab. Losing here is
avoidable and painful.

#formulas(title: "The 20-minute checklist, done the day before")[
+ *Test the actual platform*, not "my laptop works". Join a test call on the same site. Some
  proctored tools refuse a browser you have never used.
+ *A second device with mobile data*, charged, with the meeting link already open. Home wifi
  failing mid-round is the single most common technical disaster.
+ *Power cable plugged in.* Not "the battery was at 60%".
+ *Camera at eye level.* A laptop on a table points up your nose. Put it on some books.
+ *Light in front of you, not behind.* A window behind your head turns you into a silhouette.
+ *A plain wall or a tidy corner.* Not a virtual background — they glitch and eat your hands
  when you gesture.
+ *Headphones with a mic.* Laptop speakers cause echo, and echo makes an interviewer tired,
  and a tired interviewer writes shorter notes.
+ *Tell the house.* A door opening mid-answer costs you the thread.
+ *A pen and blank paper* in frame. Allowed almost everywhere, and thinking on paper is
  faster than thinking in a text box.
+ *Your resume printed or on a second screen*, because you will be asked "walk me through
  point three" and scrolling in the shared tab looks terrible.
]

#trap[
*Reading from a script on a second monitor is visible.* Your eyes track left-right in a
pattern that does not match conversation, and your pauses fall in the wrong places. It is
noticed more often than candidates think, and it is usually scored as dishonesty rather than
nervousness. Keep *bullet keywords* on paper — five words per story, not sentences.
]

#subsection[When something goes wrong mid-round]

#table(columns: (auto, 1.6fr),
  align: (left, left),
  [*What happens*], [*What to say and do, in order*],
  [Your internet drops], [Rejoin from the phone immediately, then say: "Sorry, my connection dropped, I am back on mobile data. I was at the part where..." Do not apologise three times.],
  [You did not hear the question], [Ask once, plainly: "Could you repeat the last part?" Never answer a question you did not hear.],
  [You do not know the answer], [Say so, then say what you *would* do: "I have not used that. My guess would be X because of Y — is that the right direction?"],
  [You gave a wrong answer 5 minutes ago], [Go back to it yourself: "Can I correct something I said earlier?" This *raises* your score. Interviewers notice self-correction.],
  [You go blank on your own project], [Say: "Give me ten seconds, I want to get the number right." Silence for ten seconds is fine. Waffling for ninety is not.],
  [Someone walks in], [Mute, deal with it in five seconds, unmute, one short apology, continue.],
)

#section[What a rejection actually means]

A rejection is a *stage number*, not a verdict on you. Knowing which stage you died at tells
you exactly what to fix. Ask the recruiter — politely, once, by mail — and many will tell you.

#table(columns: (auto, 1.3fr, 1.2fr),
  align: (left, left, left),
  [*Rejected at*], [*The most likely real reason*], [*What to fix, specifically*],
  [No reply at all], [The screen. Your resume did not match the post's words.], [Chapter 2. Rewrite against three real posts.],
  [Aptitude test], [A sectional cut-off, usually the one you find boring.], [Find which section. Drill that section only.],
  [Coding test], [Time, not concept. You had a working brute force at the buzzer.], [Timed practice. Log the minutes per problem.],
  [Technical round 1], [You went silent, or you refused a hint, or you could not explain your own code.], [Practise narrating out loud while you code.],
  [Project round], [The project sounded borrowed. You could not say why you made a choice.], [Chapter 5. Know one project to the bottom.],
  [Managerial / HR], [No evidence of finishing something alone; or a gap or constraint that surfaced late.], [Chapters 4 and 6. Prepare six real stories and the hard answers.],
  [After the offer], [Background check mismatch, or you went silent for two months.], [Match every date to your documents. Reply to every mail.],
)

#subsection[Asking for feedback without sounding bitter]

#trap[
*WEAK:* "Sir, I gave my best and still I was rejected. Please tell me what was the reason,
because I feel the evaluation was not fair. I request you to reconsider."

Two problems. It asks them to defend a decision, so the safe reply is silence. And
"reconsider" turns a feedback request into an appeal, which recruiters are trained to close.
]

#sol[
*STRONG (a four-line mail):*

"Thank you for letting me know, and for the time your team spent.

If it is possible, I would find it genuinely useful to know which round was weakest, even in
one line — I am preparing for the next cycle and I would rather work on the right thing.

Either way, I would like to apply again when there is a suitable opening.

Thanks again."

*What changed, exactly:*
- No appeal. Nothing to defend, so replying is cheap for them.
- Asks for *one line about a round*, which is a question they can actually answer, instead of
  "why did you reject me", which they cannot.
- States the intent to reapply, which is the sentence that gets you into the "keep warm" list.
]

#note[
*Reapplying is normal.* Many companies have a waiting period — commonly six months — before
you may apply again. Ask what it is. Then reapply *with something new on the resume*, and say
in one line what changed: "Since my last application I have shipped X and my timed-round
result improved from A to B." Reapplying with an identical resume gets an identical result.
]

#section[Eight things students believe that are not true]

#table(columns: (1.1fr, 1.4fr),
  align: (left, left),
  [*The belief*], [*What is actually true*],
  [A referral guarantees an interview.],
    [A referral gets your resume *looked at by a human*. It skips filter one, not filter two. A weak resume with a referral is still a weak resume.],
  [More pages means more experience.],
    [For a fresher, page two is usually not read at all. One page, dense, is stronger.],
  [You must never say "I do not know".],
    [Saying it, then giving your reasoning and a way to find out, scores *better* than a confident wrong answer, which scores worse than silence.],
  [HR rounds are just a formality.],
    [About 1 in 11 candidates who reach it are removed there, and it is the stage where you have the most control.],
  [You should always agree with the interviewer.],
    [At Tier 2 and 3 you are explicitly scored on whether you will correct a wrong decision. Agreeing with everything is a fail on that line.],
  [A low CGPA cannot be recovered.],
    [Many cut-offs are firm and some are not. Where a cut-off is firm, the route is off-campus roles that screen on skills. Where it is not, evidence of an upward trend plus shipped work is a real answer. See Chapter 6.],
  [Interviewers want to trick you.],
    [Interviewers want to stop interviewing and go back to their work. Make it easy to say yes: give facts they can write down.],
  [Talking more shows confidence.],
    [A 4-minute answer to a 40-second question is the most common cause of running out of time before your best story.],
)

#section[Top traps in this chapter]

#trap[
+ Preparing only for the coding test, then losing at the resume screen you never looked at.
+ Writing a resume in words you like instead of the words the job post used.
+ Sending a scanned or image-based PDF that the parser reads as empty.
+ Saying "I am flexible about everything" — it is the one answer that carries no information.
+ Giving a fake weakness ("I am a perfectionist"). It scores the same as no answer.
+ Telling a story with no number in it, and no cost, and no rejected alternative.
+ Blaming a teammate, a guide, or an interviewer for a past rejection.
+ Arguing about the legality of a bond in the interview room instead of reading the clause
  afterwards.
+ Naming a salary figure you have not worked out, in either direction.
+ Promising a joining date that depends on your current manager being kind.
+ Memorising an answer from a book — including this one — instead of substituting your own
  real experience.
]

#section[Practice]

#practice(tier: 1, time: "25 min, spoken out loud")[
+ Write the seven stages of the funnel from memory. Beside each one, write the single
  question that stage is really asking.
+ Take one job post you have actually seen. List its must-have keywords. Now check your
  current resume against that list, word by word, and count the misses.
+ Answer out loud, in under 60 seconds: "Are you comfortable with relocation?" Record it.
  Listen. Did you give a lead time and evidence, or an adjective?
+ Answer out loud: "Why our company?" Now swap in a competitor's name. If the answer still
  makes sense, rewrite it.
+ Write down, honestly, what you would ask about a service agreement before signing. Aim for
  five questions.
]

#key[
+ Apply, screen, test, technical 1, technical 2 / project, HR / managerial, offer. The
  questions: *does the form accept me · do I match the post · can I score above the cut-off ·
  can I code and be corrected · is my project real · will I accept and stay · will I sign.*
+ The count of misses is the only number that matters here. Every miss is a coin flip you
  lose at the screen.
+ A good answer has three parts: yes/no in sentence one, a lead time in sentence two,
  evidence in sentence three.
+ The name-swap test is the fastest quality check there is for a "why us" answer.
+ Duration and start date · exact amount and whether it reduces · certificates retained
  (get a receipt) · what events trigger it · relieving letter on payment.
]

#practice(tier: 2, time: "30 min")[
+ You are asked: "Why do you want to work in Singapore rather than in India?" Write a
  four-sentence answer containing (a) one thing about the *role*, (b) one thing about the
  *market or the product*, (c) your realistic timeline, (d) one question back to them.
  Nothing about weather or beauty.
+ Write a three-sentence answer to "how do you handle a teammate in another time zone?" that
  contains one number and one mechanism. Not one adjective.
+ A manager makes a decision you believe is wrong, in a meeting of eight people. Write
  exactly what you would do, in order, in four steps. Include what you do if you are
  overruled.
+ Estimate your own realistic weeks-from-offer-to-joining for a cross-border role, and list
  the three steps that make up most of it.
]

#key[
+ Good structure: role fit (the stack or the domain matches what I have built) $->$ market
  reason (scale or type of product I cannot get here) $->$ "eight to ten weeks from offer
  because of attestations and housing" $->$ "which month do you need me to start?"
+ Example shape: "We lost three days in two weeks to blocked questions. We fixed it by
  writing the fall-back plan into the question itself and keeping decisions in one dated
  document."
+ (1) Do not argue in the meeting of eight. (2) Check I have understood, in writing, with a
  concrete example. (3) Raise it in the smallest room possible. (4) If overruled and it is
  not a data-loss or safety issue, record the concern once and commit fully.
+ Attestation and documents, the filing window, and flights plus housing. Give the sum as a
  range and offer to work backwards from their date.
]

#practice(tier: 3, time: "45 min, written then spoken")[
+ Write one full STAR story from your own life, with the four parts labelled, where the
  *Action* part is at least half the words. It must contain: one measured number, one
  alternative you rejected and why, and one cost of your chosen fix.
+ Now attack it. Answer all seven follow-up probes from the table in this chapter. Mark every
  probe you cannot answer.
+ For each hole you marked, go and find the real answer if you still can. Write down what you
  will say for the ones where the information is genuinely gone. ("I did not measure the
  write cost at the time. If I did it again I would, and here is roughly what I would expect
  and why.")
+ Write a failure story that includes step 5 — the evidence the change stuck. If you have no
  step 5 yet, that is a signal: the change has not been tested, and you have time to test it.
+ Take the values or culture list from one real company's careers page. Write one honest
  story of your own beside each line. Circle the lines with no story.
]

#key[
+ Self-check: if you deleted your Situation and Task, would the Action still show a decision?
  If not, you described a task, not ownership.
+ A story with three or more unanswerable probes is not ready. It is not a bad story — it is
  an unfinished one.
+ "I do not know, and here is how I would find out" is an acceptable Tier-3 answer.
  "I think it was around..." when you are guessing is not — say you are estimating.
+ No step 5 is the most common reason a good failure story scores as average.
+ A circled line is your next six weeks. Go and do the thing, then you will have the story
  honestly.
]

#revision[
*The funnel.* Apply $->$ screen $->$ test $->$ technical 1 $->$ technical 2 / project $->$
HR / managerial $->$ offer. Cheap stages cut hard, expensive stages cut gently.

*Survival, typical shape.* Screen 55% · test 33% · tech 1 50% · tech 2 61% · HR 91% ·
offer 90%. The test is the biggest cut. The HR round is the friendliest — and still removes
about 1 in 11.

*What each round scores.* Screen: do you match the post. Test: a number. Technical: can you
code *and* be corrected. Project: is it real. HR: will you accept and stay.

*The screen is two filters.* String-matching software, then a human for 7 seconds. Write
both forms of every abbreviation once: `Node.js (Node)`. Send a text-selectable PDF and test
it with select-all, copy, paste.

*STAR.* Situation 15% · Task 10% · *Action 55%* · Result 20%. The Action part is what is
scored. Label the four parts in your own head every time.

*Three upgrades that turn any weak story strong.*
+ Put a measured number where an adjective was.
+ Name an alternative you rejected, and why.
+ Name the cost of the fix you chose.

*Tier depth.* Tier 1 = the story, short. Tier 2 = the story plus practical detail about
moving and working across distance. Tier 3 = the story plus five levels of follow-up. One
set of honest material, told at three depths.

*The three failure answers that score zero.* The fake weakness. The blamed teammate. The
story with no number.

*Money and paper, in one line each.*
- Campus salary is fixed; negotiate location, stream, joining date instead.
- Off-campus: give a *researched range* with a source, never a single number, never "anything
  is fine".
- Bond: get duration, start date, amount, certificate handling and exit triggers *in
  writing*, and negotiate after the written offer, not in the room.
- Notice period: promise only the date you can hit without anyone's permission.

*The rule for every answer in this book.* Use the structure. Substitute your own real
experience. Never invent one — at Tier 3 the follow-up to the follow-up will find it, and a
background check finds the rest.
]

]
