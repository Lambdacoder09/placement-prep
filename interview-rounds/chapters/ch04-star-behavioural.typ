#import "../../shared/lib/style.typ": *

#chapter(num: 4, title: "STAR & Behavioural Depth",
  tagline: "Twelve stories from your own life, told in one shape, that survive three levels of \"why?\"")[

#section[Pattern in one page]

A behavioural question starts with "Tell me about a time when...". It is not a test of your
opinion. It is a test of *evidence*. The interviewer believes that what you did before is the
best available guess at what you will do next.

So an answer that says what you *would* do is worth almost nothing. An answer that says what you
*did* is worth everything.

#formulas(title: "What a behavioural round is scoring")[
*1. Is there a real event?* With a date, a place, other people, and a consequence.

*2. What did YOU do?* Not the team. You. The interviewer is hiring you, not your group.

*3. Did you decide anything?* A story with no decision in it is a diary entry.

*4. How do you know it worked?* A result, measured or observed.

*5. Does it hold up under "why?"* Asked three times, in a row, about the same thing.

*6. Would you do it again, and what would you change?* Reflection is scored separately from
the event itself, and many candidates never offer it.
]

#trap[
*The hypothetical trap.* Question: "Tell me about a time you disagreed with a teammate."
Answer: "If I disagreed with a teammate, I would first listen to their point of view, then I
would explain mine calmly, and we would find a middle ground."

That is a *policy*, not a *story*. It scores zero on all six lines above. The fix is one word at
the start: "In February, in our database project, ..." -- a specific time and place forces a real
event out of your memory.
]

// ==================================================================
#section[STAR — the four parts, labelled]

#formulas(title: "S - T - A - R")[
*S — Situation.* Where and when, in one or two sentences. Enough context that the rest makes
sense. Nothing more. This is the part every student overgrows.

*T — Task.* What *you* were responsible for, and what "done" meant. One or two sentences. This is
the part every student skips, and skipping it is why the story feels aimless.

*A — Action.* What *you* did, step by step, in order, with the decisions visible. This is 60
percent of the answer. If you are not saying "I", you are not in the Action.

*R — Result.* What changed, with a number or an observed outcome, plus one sentence of what you
learned or would do differently.

*Say the labels out loud if it helps you at first.* "The situation was..." "My task was..."
"So what I did was..." "The result was..." Interviewers do not mind. It makes you easy to score,
and easy to score is good for you.
]

#diagram(height: 3.6cm, caption: "Where your words should go. Action is the story; the rest is framing.")[
  #dnode(0cm, 0.4cm, 2.3cm, 1.1cm, "S · 15%", fill: rgb("#eef3f7"))
  #dnode(2.4cm, 0.4cm, 1.6cm, 1.1cm, "T · 10%", fill: rgb("#eef3f7"))
  #dnode(4.1cm, 0.4cm, 9.2cm, 1.1cm, "A · 60% — what YOU did, step by step, with the decisions", fill: rgb("#e2eee6"))
  #dnode(13.4cm, 0.4cm, 2.3cm, 1.1cm, "R · 15%", fill: rgb("#eef3f7"))
  #darrow(0cm, 2.0cm, 15.7cm, 2.0cm, label: "90 to 120 seconds")
  #dnode(0cm, 2.4cm, 7.6cm, 0.85cm, "Most students: S = 60%, A = 15%", fill: rgb("#fdf4f4"))
  #dnode(8.1cm, 2.4cm, 7.6cm, 0.85cm, "That inversion is the single most common failure", fill: rgb("#fdf4f4"))
]

#subsection[Check your own split with a script]

You can measure this instead of guessing. Split your story into four strings and run it.

#code(lang: "py", caption: "star.py — is your story spending its words in the right place?")[
```python
TARGET = {"S": 0.15, "T": 0.10, "A": 0.60, "R": 0.15}

def report(name, parts):
    counts = {k: len(v.split()) for k, v in parts.items()}
    total = sum(counts.values())
    print(f"--- {name}  ({total} words, ~{round(total/130*60)}s spoken)")
    for k in "STAR":
        share = counts[k] / total
        flag = "ok"
        if share < TARGET[k] - 0.07: flag = "too thin"
        if share > TARGET[k] + 0.10: flag = "too fat"
        print(f"  {k}: {counts[k]:3d} words  {share:5.0%}  target {TARGET[k]:.0%}  {flag}")
```
]

Run on a weak story and a strong one:

#code(lang: "text", caption: "Measured output")[
```text
--- weak  (70 words, ~32s spoken)
  S:  47 words    67%  target 15%  too fat
  T:   5 words     7%  target 10%  ok
  A:   9 words    13%  target 60%  too thin
  R:   9 words    13%  target 15%  ok
--- strong  (156 words, ~72s spoken)
  S:  17 words    11%  target 15%  ok
  T:  15 words    10%  target 10%  ok
  A:  95 words    61%  target 60%  ok
  R:  29 words    19%  target 15%  ok
```
]

#note[The weak story is not weak because it is short. It is weak because two-thirds of it is
scene-setting. Nine words of Action is nothing to score. Fix the *split* first, then the length.]

#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Here are the two stories the script measured. Read the weak one and name the four faults before
reading the strong one.
]

#trap[
*Weak.*

*(S)* "In my sixth semester we had a group project for the database subject and there were four
of us in the team and the college gave us six weeks and my friends were also busy with placement
preparation so everybody had a lot going on that month."

*(T)* "We had to build something."

*(A)* "So I did my part and we finished it."

*(R)* "It went fine and sir gave us good marks."
]

#sol[
*Strong. Same project. Same student. Nothing invented.*

*(S)* "In my sixth semester our four-person team had six weeks to build a library database
project."

*(T)* "I owned the search feature, and the team needed a working demo by week five."

*(A)* "I listed the three queries the demo needed and timed them on a copy of the data. Title
search took about two seconds on nine thousand rows, because it scanned the whole table. I added
an index on the title column and rewrote the query to filter before joining. I then asked two
classmates to try breaking it, and they found that an empty search string returned every row, so
I added a minimum of two characters. I wrote each timing into a shared sheet so the team could
see what changed and why."

*(R)* "Search dropped from about two seconds to under a tenth of a second, the demo ran on time,
and I reused the same index check in my next project."
]

#subsection[Name exactly what changed]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Situation], [47 words of excuses (busy friends, placements)], [17 words: who, how many, how long, what],
  [Task], ["build something"], [A named feature she owned, and a deadline],
  [Voice], ["we", "my friends", "everybody"], ["I" in every action sentence],
  [Decisions], [None visible], [Timed first · indexed · rewrote join · asked for testers · wrote it down],
  [Numbers], [None], [9,000 rows · 2s · under 0.1s · 2-character minimum],
  [Result], ["good marks" -- the teacher's opinion], [A measured change plus a reused method],
  [Follow-ups invited], [Nothing to ask], [Why an index? Which join? What did the testers break?],
)

#trick[
*The excuse detector.* If your Situation contains why things were hard for you -- busy, no time,
bad teammates, weak internet -- delete those words. They feel like context to you. They read as
excuse-building to the interviewer, before anything has even gone wrong.
]

// ==================================================================
#section[The "I" rule]

#formulas(title: "We built it. I did what?")[
Interviewers count pronouns. It is the fastest way to tell a participant from a contributor.

*Use "we"* for the Situation and for genuinely shared context. "We had six weeks."

*Use "I"* for every sentence in the Action. "I timed the queries." "I added the index." "I asked
two classmates to test it."

*If a sentence in your Action cannot honestly start with "I", it does not belong in your Action.*
Move it to the Situation, or cut it.

*And do not steal.* If a teammate wrote the code, say so: "Rohit wrote the parser; my part was
the schema and the queries." Naming a teammate's contribution makes your own claims more
believable, not less.
]

#ex(2, tier: 1, asked: "Infosys · pattern")[
Rewrite this Action so every sentence is honest and starts with "I".

"We decided to change the database, so we moved everything to Postgres, and then we tested it and
it worked."
]
#sol[
The honest rewrite depends on what you actually did. Two possible true versions:

*If you led it:* "I compared our query times on SQLite and Postgres with a copy of the data and
found the concurrent writes were the problem, not the read speed. I proposed the move in our
Tuesday meeting with those two numbers. I wrote the migration script and ran it on a copy first.
Rohit updated the application code to the new client."

*If you did not lead it:* "Rohit proposed moving to Postgres. My job was to check it would not
break the reports, so I ran our six report queries against both and found one that used a SQLite
date function with no direct equivalent. I rewrote that one query and wrote down the difference
so nobody else would hit it."

Both are strong. The second one is a smaller role, honestly told, and it still shows a decision,
a method and a result. *A small true role beats a large false one every single time.*
]

// ==================================================================
#section[Build your story bank before you prepare any answer]

You cannot invent a story in an interview. You can only retrieve one. So the work is done in
advance: collect 8 to 10 real events from your own life, then map each one to several themes.

#formulas(title: "The eight themes that cover most behavioural questions")[
#table(columns: 2, align: (left, left),
  [*Theme*], [*Question it answers*],
  [Conflict], [Disagreement with a teammate; a difficult person],
  [Failure], [A mistake you made; something that went wrong],
  [Deadline], [Working under pressure; missing or saving a date],
  [Leadership], [Leading without a title; taking charge],
  [Learning fast], [Unfamiliar technology; steep learning curve],
  [Helping someone], [Mentoring; supporting a struggling teammate],
  [Data decision], [Using evidence; changing your mind with numbers],
  [Pushed back], [Disagreeing with someone senior; saying no],
)

*One event can serve three or four themes.* The library project above serves deadline, data
decision, and (with a different emphasis) learning fast. You need *events*, not answers.
]

#code(lang: "js", caption: "bank.js — which themes are still empty?")[
```js
const THEMES = [
  "conflict", "failure", "deadline", "leadership",
  "learning-fast", "helped-someone", "data-decision", "pushed-back",
];

// Replace every line below with your own real story.
const myStories = [
  { title: "Canteen site: menu cache",      themes: ["deadline", "data-decision"] },
  { title: "Group project: teammate quit",  themes: ["conflict", "leadership"] },
  { title: "Attendance tool: wrong schema", themes: ["failure", "learning-fast"] },
  { title: "Taught juniors Git",            themes: ["helped-someone", "leadership"] },
];

const covered = new Map(THEMES.map((t) => [t, []]));
for (const s of myStories) {
  for (const t of s.themes) {
    if (!covered.has(t)) { console.log(`unknown theme: ${t}`); continue; }
    covered.get(t).push(s.title);
  }
}

let gaps = 0;
for (const t of THEMES) {
  const list = covered.get(t);
  if (list.length === 0) { gaps++; console.log(`${t.padEnd(16)} EMPTY  <- write one`); }
  else console.log(`${t.padEnd(16)} ${list.length}  (${list.join("; ")})`);
}
console.log(`\nstories: ${myStories.length}   themes covered: ${THEMES.length - gaps}/${THEMES.length}`);
```
]

#code(lang: "text", caption: "Output")[
```text
conflict         1  (Group project: teammate quit)
failure          1  (Attendance tool: wrong schema)
deadline         1  (Canteen site: menu cache)
leadership       2  (Group project: teammate quit; Taught juniors Git)
learning-fast    1  (Attendance tool: wrong schema)
helped-someone   1  (Taught juniors Git)
data-decision    1  (Canteen site: menu cache)
pushed-back      EMPTY  <- write one

stories: 4   themes covered: 7/8
```
]

#note[Four real events covered seven of eight themes. That is the point of the bank: you are not
writing 20 answers, you are collecting 8 events and learning to angle each one. The empty theme is
your homework, and the honest way to fill it is to go and *do* something that fits.]

#subsection["But nothing has ever happened to me"]

It has. You are looking in the wrong place. Behavioural stories do not require an internship or a
job. They require a moment where you decided something and it mattered to somebody.

#table(columns: 2, align: (left, left),
  [*Look here*], [*What it can prove*],
  [A group project where someone did not deliver], [Conflict, leadership, deadline],
  [A bug that took you days], [Failure, persistence, learning],
  [A college fest, sports team, or club role], [Leadership, priorities, working with strangers],
  [Teaching a junior or a classmate], [Helping someone, communication],
  [A family responsibility you carried], [Priorities, reliability under pressure],
  [A part-time job or tuition you took], [Customer handling, deadlines, ownership],
  [An open-source issue or a bug report you filed], [Initiative, working with strangers' code],
  [A competition you entered and lost], [Failure, reflection, second attempt],
  [Something you organised for 20 people], [Planning, dealing with people who change their minds],
)

#trap[
*Do not upgrade the story.* A four-person college project does not become "I led a team of ten".
A class assignment does not become "a client deliverable". The interviewer does not expect a
fresher to have run a company. They *do* expect the story to be true, and they will find the
seam -- usually by asking a boring logistical question like "how often did the team meet?"
]

// ==================================================================
#section[The twelve stories]

Each one below is a *theme*, a *structure*, and a *filled example*. Say it once more to yourself:
the filled example is a made-up student's life, shown so you can see the shape. *You must
substitute your own real experience into every slot.* An answer copied from this page will break
on the first follow-up, because none of it happened to you.

#tier-header(1)

#subsection[Story 1 — Conflict with a teammate]

#ex(3, tier: 1, asked: "TCS · pattern")[
"Tell me about a time you had a disagreement with someone on your team. How did you handle it?"
]

#trap[
*Weak.*

*(S)* "In our final year project one of my team members was very lazy and never did his work."
*(T)* "I had to manage everything."
*(A)* "I told him many times but he did not listen, so finally I did his part also and completed
the project."
*(R)* "We submitted on time. Some people are just like that."

Faults: the other person is a villain, there is no attempt to understand why, the "solution" is
doing their work silently, and the closing line says this student will quietly resent a colleague
for months rather than raise anything. Every one of those is a hiring risk.
]

#sol[
*Strong.*

*(S)* "In our final-year project, four of us, I owned the backend and a teammate owned the report
screens. In week three his screens had not started."

*(T)* "My job was the backend, but the demo needed both halves, and I was the one who had noticed
first."

*(A)* "I did not raise it in the group chat, because I did not want him to defend himself in
public. I asked him to sit for ten minutes and I asked one question: what is blocking you? It
turned out he had never used the chart library and had been stuck on it for a week without saying
so, and he thought asking would look bad. So we split it: I spent one evening getting one chart
working end to end as an example, and he did the remaining four from that pattern. I also
proposed to the group that we each post a two-line update every Monday, so this would surface in
a week rather than in three."

*(R)* "He finished the four screens in five days, and the Monday updates caught a second problem
later that month -- our data export was pointing at the old schema. What I learned is that 'not
doing the work' usually has a reason underneath, and the reason is often that asking felt
expensive."
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [The other person], [A villain with a fixed character], [A person with a specific, findable blocker],
  [First move], [Public complaining, then silence], [A private question: "what is blocking you?"],
  [Solution], [Did his work for him], [Unblocked him with one worked example],
  [System change], [None], [A weekly two-line update -- and it caught a second issue],
  [Result], ["we submitted"], [Five days, plus a second problem found by the new process],
  [What it says about you], [Will resent colleagues quietly], [Will surface problems early and fix causes],
)

#trick[
*The best conflict stories end with a mechanism, not a truce.* "We talked and understood each
other" is fine. "We talked, and then we changed how we work so it does not recur" is a level
above, and it is the answer a team lead wants to hear.
]

#subsection[Story 2 — A failure you owned]

#ex(4, tier: 1, asked: "Wipro · pattern")[
"Tell me about a time you failed, or made a mistake."
]

#formulas(title: "The failure structure: OWN - COST - FIX - PREVENT")[
*OWN*: say what you did wrong, in the first sentence, without softening it.
*COST*: who was affected and how much. Be exact.
*FIX*: what you did immediately.
*PREVENT*: the change that stops it recurring. This is the part that is actually scored.

*Choose a real failure with a real cost.* "I once worked too hard and burned out" is the fake
weakness in story clothing. Interviewers can spot it instantly.
]

#trap[
*Weak.* "Honestly I cannot think of a big failure. In one project the requirements were changed
by our guide at the last minute and we could not finish, but that was not really our mistake."

Two faults: refusing the question, and then blaming someone else inside the refusal. If you say
you have never failed, the interviewer concludes either that you have never tried anything hard,
or that you do not notice when you break things. Both are worse than any failure you could
describe.
]

#sol[
*Strong.*

*(S / OWN)* "I deleted a week of real data from our college attendance tool. It was my mistake --
I ran a cleanup query on the live SQLite file instead of the copy, because both terminals looked
the same and I did not check which directory I was in."

*(T / COST)* "Three faculty members had entered about 200 attendance records that week. There was
no backup, because I had never set one up."

*(A / FIX)* "I told the faculty member the same afternoon, before anyone noticed, and I said
plainly that it was my error and that the records were gone. Then I found that the tool wrote a
plain-text log line for every entry, which I had added months earlier for debugging. I wrote a
script to parse the log and rebuild about 180 of the 200 rows. For the remaining 20 the log lines
were incomplete, so I listed exactly which sessions were missing and asked the two teachers to
re-enter those from their own registers."

*(R / PREVENT)* "About 90 percent recovered, 20 re-entered by hand, roughly two hours of other
people's time lost. I then did three things: a nightly copy of the database file, a confirmation
prompt on any delete in that script, and I changed my terminal prompt to show the directory in
colour. Nothing like it has happened since, but the real change was the backup -- the mistake will
happen again to someone, and the backup is what makes it survivable."
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Ownership], [Deflected to the guide], [First sentence names her own error],
  [Cost], [Unstated], [200 records, 3 people, 2 hours of others' time],
  [Honesty], [Hid behind "requirements changed"], [Told the affected person the same day],
  [Recovery], [None], [Rebuilt 90 percent from a debug log],
  [Prevention], [None], [Backups, a confirm prompt, a visible directory],
  [Maturity], [--], ["The mistake will happen again -- the backup is the fix"],
)

#note[Notice the strongest single line in that answer: she designed for the *next* person's
mistake, not just her own. That is the sentence a senior engineer remembers.]

#subsection[Story 3 — A hard deadline]

#ex(5, tier: 1, asked: "Capgemini · pattern")[
"Tell me about a time you had to work under a tight deadline."
]

#trap[
*Weak.* "Our project deadline was very near and we had a lot of work left, so we all sat the
whole night and finished it somehow. We submitted at 9 am and it was accepted."

"Somehow" is the problem. The story proves stamina, not judgement. Every fresher can stay up. The
scored skill is *what you decided to drop*.
]

#sol[
*Strong.*

*(S)* "Two days before our college fest, the canteen pre-order site I was building still had no
payment integration."

*(T)* "My task was a working ordering system for three days of the fest, not a complete product.
I had about 14 usable hours left."

*(A)* "I wrote down the three things left -- online payment, an admin dashboard, and order
history -- and asked which of them would actually stop the fest working. Only ordering itself
would. So I proposed to the canteen manager that we go cash-on-pickup for the fest: the site
takes the order and prints a token, and money is handled at the counter as it always was. He
agreed, because that was already how his counter worked. I spent the 14 hours on the token
screen, the counter's order list, and testing two people ordering the last item at the same time.
I left payment and the dashboard undone and I told the team in writing that they were undone, so
nobody assumed otherwise on the day."

*(R)* "The site handled about 200 orders over three days with no manual intervention. The missing
payment feature was never even noticed by students, because they were paying at the counter
anyway. What I took from it is that cutting scope early is a decision, and cutting it at 4 am is
just damage."
]

#trick[
*Deadline stories are scope stories.* The interviewer is not asking "can you suffer?". They are
asking "when the date cannot move, do you know what to drop, and do you tell people?" Make the
cut visible, make it early, and make it communicated.
]

#subsection[Story 4 — Leading without a title]

#ex(6, tier: 1, asked: "Accenture · pattern")[
"Give me an example of when you showed leadership."
]

#formulas(title: "Leadership without authority: NOTICED - PROPOSED - MADE IT EASY - FOLLOWED UP")[
A student has no authority. Nobody has to listen. So the story cannot be "I told them". It must
be *noticed* a problem, *proposed* something small, *made it easy* for others to say yes, and
*followed up* so it did not die in week two.
]

#sol[
*Strong.*

*(S)* "In our fourth semester, six of us were preparing for the same subject and everyone was
re-deriving the same past-paper solutions separately."

*(T)* "Nobody asked me to fix this. I noticed we were duplicating about four hours a week each.
*(NOTICED)*"

*(A)* "I proposed something deliberately small, because a big plan would have been ignored: one
shared document, one person per unit, solutions written out fully rather than just answers.
*(PROPOSED)* To make saying yes easy, I did the first unit myself, completely, before asking
anyone -- so they could see the format and the effort rather than imagining it. *(MADE IT EASY)*
Two people did not deliver in the first week. I did not push it in the group; I asked each one
privately whether they wanted a different unit, and one swapped to a shorter one and then
finished. *(FOLLOWED UP)* I also set the rule that if a solution was wrong, whoever spotted it
fixed it rather than complaining, and I fixed two of my own that way."

*(R)* "All six units were done in nine days, and eleven people outside our group used the
document by exam week. Four of us scored above our own previous semester average in that subject.
What I learned is that the way to lead people who do not report to you is to do the first unit
yourself."
]

#table(columns: 2, align: (left, left),
  [*The weak version of this story says*], [*Why it fails*],
  ["I was the team leader so I assigned work"], [A title, not a behaviour],
  ["I motivated everyone to work hard"], [Unverifiable and unmeasurable],
  ["I did most of the work myself"], [That is not leadership, that is absorption],
  ["I told them to finish on time"], [No mechanism, no follow-up, no easy yes],
)

#subsection[Story 5 — Learning something fast]

#ex(7, tier: 1, asked: "Cognizant · pattern")[
"Tell me about a time you had to learn something new quickly."
]

#sol[
*Strong.*

*(S)* "I inherited a half-finished attendance tool written by a senior who had graduated. It used
a query builder library I had never seen, and there was one comment in 1,800 lines."

*(T)* "I had to add a report screen in two weeks without breaking what already worked."

*(A)* "I gave myself two days of not writing any code. I drew the six screens on paper and traced
which tables each one touched, by reading the code and writing it down. That produced a one-page
map, which I later put in the README. Then instead of reading the whole library documentation, I
took the three queries the tool already used and rewrote each one as plain SQL to check I
understood what the library was generating. Two of them I got wrong on the first try, which told
me exactly which part of the library I had misunderstood -- it was doing an implicit join I had
not noticed. Only then did I start on the report screen, and I built it by copying the shape of
the closest existing screen rather than inventing one."

*(R)* "The report shipped in nine days, and the one-page map is still the first thing in that
README. The method I keep using is: translate the unfamiliar thing into something I already know,
and be happy when I get it wrong, because that is where the gap is."
]

#trick[
*Learning stories should contain a moment of being wrong.* "I read the documentation and then I
built it" is not a learning story, it is a reading story. The interviewer wants to see your
*method for discovering you were wrong*, because that is what you will be doing on their codebase
in month one.
]

#subsection[Story 6 — Helping someone else]

#ex(8, tier: 1, asked: "Infosys · pattern")[
"Tell me about a time you helped a teammate who was struggling."
]

#sol[
*Strong.*

*(S)* "Two juniors in my department kept losing work because they were emailing zip files to each
other instead of using version control, and one of them lost two days of work that way."

*(T)* "Nobody asked me to teach them. I had used Git for a year and I could see this repeating."

*(A)* "I did not run a workshop, because I had sat through those and nobody remembers them. I sat
with them for 40 minutes on their *own* project, not a sample one, and we used exactly four
commands: status, add, commit, push. I refused to explain branching that day, even when they
asked, because I wanted the four commands to become automatic first. Then I wrote a half-page
card with those four commands and the two error messages they had already hit, with the fix for
each. Two weeks later I checked their repository and saw they had 30 commits but all on one
branch, so we did a second 30-minute session on branches, which now had a reason to exist."

*(R)* "Both of them used Git for their final year project, and one of them taught it to his own
group. The thing I would repeat is teaching four commands properly rather than twenty badly, on
their real work rather than a toy."
]

#note[This story has no technology difficulty in it at all. It is scored on judgement: teaching
less on purpose, using their real project, and going back two weeks later to check. Helping
stories are about *whether the help stuck*, not about what you knew.]

#tier-header(2)

#subsection[Story 7 — Deciding with data]

#ex(9, tier: 2, asked: "Agoda · pattern")[
"Tell me about a decision you made based on data. What did the data say that you did not expect?"
]

#trap[
*The weak version:* "We analysed the data and decided to optimise the database, and performance
improved a lot." No number, no alternative considered, no surprise -- and the last clause,
"improved a lot", is an opinion wearing a number's clothes.
]

#sol[
*Strong.*

*(S)* "Our canteen order page took about four seconds to load, and users were complaining during
a trial run before the fest."

*(T)* "I had one evening to make it usable, and I had to choose where to spend it."

*(A)* "My assumption was that the server was slow, and I was about to add caching on the server.
Before doing that I put timers around three sections: the network call, the JSON parse, and the
render. On my phone the numbers were roughly 80 milliseconds for the server call, 15 for the
parse, and about three seconds in the render. So my assumption was wrong by a wide margin -- the
server was not the problem at all. The render was slow because I redrew all 120 menu items
whenever any quantity changed. I changed it to update only the row that changed, and I cached the
menu in memory so it was fetched once per session instead of per click. I re-measured on the same
phone, in the same place, because our campus wifi varies by building and I did not want to fool
myself."

*(R)* "It went from about four seconds to about 0.7. The lesson I actually use now is not about
rendering -- it is that I should measure before I optimise, because my instinct was confidently
wrong and would have cost me the whole evening."
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Data], ["we analysed"], [Three timings, named, with the device],
  [Surprise], [None], [Her assumption was wrong -- the server was fine],
  [Alternative], [Not considered], [Server caching, explicitly rejected by evidence],
  [Rigour], [--], [Re-measured in the same place to avoid fooling herself],
  [Result], ["improved a lot"], [4s to about 0.7s],
  [Lesson], [About the fix], [About the method -- which transfers to any job],
)

#subsection[Story 8 — Disagreeing with someone senior]

#ex(10, tier: 2, asked: "Grab · pattern")[
"Tell me about a time you disagreed with your manager, your professor, or a senior. What did you
do?"
]

#formulas(title: "The push-back structure: UNDERSTAND - EVIDENCE - PROPOSE - DEFER")[
*UNDERSTAND*: state their position fairly, in their words, first.
*EVIDENCE*: bring something, not just an opinion. A measurement, an example, a cost.
*PROPOSE*: offer a concrete alternative, ideally a cheap test rather than a full reversal.
*DEFER*: say what you did after the decision -- including when it went against you.

That last part is what is actually being scored. Anyone can disagree. The question is whether you
commit afterwards, or sulk.
]

#sol[
*Strong.*

*(S)* "Our project guide wanted us to build a mobile app for the attendance tool. I thought a
mobile-friendly web page would serve the same users for a fraction of the work."

*(T)* "I had one meeting to make the case, and it was five weeks before submission."

*(A)* "First I made sure I understood his reason rather than assuming -- he wanted offline entry,
because the labs have poor signal. That was a real requirement I had not known about. So my
disagreement got smaller: it was not app versus web, it was how much of the app we needed. I went
away and measured two things: how long it took me to get a basic offline-capable web page storing
entries locally, which was about six hours, and how many of the three teachers actually had
phones we could install a test app on -- it turned out one of them had a phone the toolchain we
knew did not support well. I brought both facts to him and proposed a two-week test: web version
first, and if offline entry failed in the lab we would still have three weeks for the app."

*(R)* "He agreed to the test. The web version worked offline in the lab, so we kept it and never
built the app. But the important part for me is what I did when he pushed back a second time on
the report format -- I disagreed once, he explained, and I dropped it and did it his way that
same day, because that one was his call and not mine. I try to separate 'I have evidence' from
'I have a preference'."
]

#trick[
*Shrink the disagreement before you argue it.* Most disagreements are smaller than they look --
you are often arguing about a requirement you did not know existed. Asking "what is this for?"
first either dissolves the disagreement or makes it precise. Either is better than arguing.
]

#subsection[Story 9 — Ambiguity: nobody told you what to build]

#ex(11, tier: 2, asked: "Sea · pattern")[
"Tell me about a time you had to work with unclear requirements."
]

#sol[
*Strong.*

*(S)* "The canteen manager's entire brief was 'students should be able to order in advance'. No
screens, no rules, no idea what happened when the kitchen ran out."

*(T)* "I had to turn that into something buildable in three weeks, on my own."

*(A)* "I did not start with code and I did not ask him to write a specification, because he would
not have. I spent 30 minutes behind his counter at lunch watching what actually happens. Three
things showed up that nobody would have told me: he refuses orders after 1:30 pm because the
kitchen stops, some items sell out and he shouts it across the counter, and students pay after
collecting, not before. Then I wrote eight sentences describing the flow in his words, and read
them back to him. He corrected two -- he wanted to close ordering at 1:00, not 1:30, to give the
kitchen slack. I built the smallest version of those eight sentences and showed it to him after
four days, on his phone, at the counter, rather than waiting until it was finished."

*(R)* "The eight sentences became my requirements document, and two of the eight never got built
because he told me after seeing the demo that they did not matter. Watching for 30 minutes was
worth more than any meeting -- people describe what they think they do, but they show you what
they actually do."
]

#note[Ambiguity stories are about *how you reduce uncertainty*, not about coping with it. Named
techniques: observe the real work, write it back in their words, demo early on their device,
build the smallest version first. Use whichever ones you truly did.]

#tier-header(3)

#subsection[Story 10 — Going past what was asked]

#ex(12, tier: 3, asked: "Amazon · pattern")[
"Tell me about a time you did more than your role required. Why did you do it?"
]

#trap[
*Weak.* "I always take extra responsibility and I never say no to extra work." A claim about
character, with no event, and it accidentally says "I have poor judgement about priorities".
]

#sol[
*Strong.*

*(S)* "My part of the library project was the search feature. During testing I noticed that the
issue-return screen, which was a teammate's, allowed a book to be returned twice, which
double-counted the stock."

*(T)* "Strictly it was not my code and we were four days from the demo."

*(A)* "I did not silently rewrite his code, because that would have wasted the four days and
insulted him. I wrote the smallest possible reproduction -- return the same book twice, watch the
count go from 3 to 5 -- and sent him those four lines with the two screenshots. I also checked
whether my own search code had the same class of bug, since it was really a missing
idempotency check, and found that my 'recently searched' list had a similar double-count. He
fixed his in an hour. I offered to write the test for the return screen since I had already
written the reproduction, and he took that.

The reason I did it: our demo would have been graded as one system, and a wrong stock count on
stage would have been the only thing anyone remembered."

*(R)* "Both bugs were fixed before the demo. Afterwards we added one rule -- before any demo, each
of us tests somebody else's screen for 15 minutes -- and that caught two more issues in the next
project. What I would not do is fix a teammate's code without telling him. Finding it is helpful;
taking it over is not."
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Event], [None -- a character claim], [A specific bug, on someone else's screen, 4 days out],
  [Method], [Implied heroics], [Minimal reproduction, handed over, not taken over],
  [Self-check], [None], [Looked for the same bug class in her own code],
  [Motive], ["I like responsibility"], [A concrete consequence: the demo is graded as one system],
  [Boundary], [None], [Explicitly says what she would NOT do],
  [Durability], [--], [A 15-minute cross-test rule that caught two more],
)

#subsection[Story 11 — A difficult user or customer]

#ex(13, tier: 3, asked: "Microsoft · pattern")[
"Tell me about a time a user was unhappy with something you built."
]

#sol[
*Strong.*

*(S)* "A senior faculty member told me, in front of two colleagues, that my attendance tool was
'useless' and that she was going back to paper."

*(T)* "She was one of only three users. If she left, the tool was effectively dead."

*(A)* "My first instinct was to defend it, and I did start to -- I said the feature she wanted was
there. That was a mistake and it made it worse. So I stopped and asked if I could watch her do
one class's entry. It took her four and a half minutes. The reason was that she taught two
sections of the same subject and my screen made her re-select the subject and the date for each
one, because I had built it for a teacher entering one class a day, which is how the other two
worked. She was not wrong at all; my mental model of the user was wrong. I added a 'same subject,
next section' button, which was about 20 lines, and I sat with her again while she used it.
Entry went to about 50 seconds."

*(R)* "She kept using it, and she reported two more issues over the next month, which is the
actual win -- an unhappy user who keeps talking to you is worth more than a silent one. What I
changed in myself is that I now watch someone use the thing before I explain the thing."
]

#trick[
*Include the moment you got it wrong in the room.* Here it is "I started to defend it, and that
made it worse." Interviewers trust a story more when it contains a small, unflattering, specific
detail -- because invented stories almost never have one.
]

#subsection[Story 12 — Competing priorities]

#ex(14, tier: 3, asked: "Goldman Sachs · pattern")[
"Tell me about a time you had more work than you could finish. How did you choose?"
]

#sol[
*Strong.*

*(S)* "In the same fortnight I had final-year project submission, two course assignments, and I
had committed to running registrations for our department's tech fest."

*(T)* "All four had the same week. I could not do all four properly and I knew it by the
Wednesday before."

*(A)* "I wrote down what actually happened if each one slipped, which took about ten minutes and
changed everything. The project could not slip -- it was graded and there was no resit. One
assignment allowed a three-day late submission at a 10 percent penalty, which I checked in the
handbook rather than assuming. The fest registrations could not slip, but they could be *handed
over*, which is different. So: I told the fest coordinator on the Wednesday, not the Saturday,
that I could do the setup but not the desk on the day, and I trained two juniors on the
registration sheet in one evening. I took the 10 percent penalty on the assignment deliberately,
and I told that professor before the deadline rather than after. I put the rest into the project."

*(R)* "Project submitted on time, one assignment three days late with the penalty I had chosen,
the fest desk ran without me, and the two juniors ran registrations again the following year. The
part I would repeat is deciding on Wednesday instead of Saturday -- the same decision on Saturday
would have been an apology instead of a plan."
]

#note[The scored skill is not "worked hard". It is: *decided early, checked the real cost of each
option, communicated before the deadline rather than after, and delegated one thing properly.*
Any student with a busy week has a version of this story. Yours will have different items.]

// ==================================================================
#section[Follow-up probing — where most answers die]

Tier 3 interviewers do not accept the first answer. They dig. Usually three levels, sometimes
five, and always on the part you were vaguest about.

#diagram(height: 6.4cm, caption: "The probe tree. Each level tests a different thing.")[
  #dnode(0cm, 0cm, 5.2cm, 0.9cm, "Your STAR answer", fill: rgb("#e2eee6"))
  #darrow(2.6cm, 0.9cm, 2.6cm, 1.5cm)
  #dnode(0cm, 1.5cm, 5.2cm, 1.0cm, "L1  \"What exactly did YOU do?\"")
  #darrow(5.2cm, 2.0cm, 6.4cm, 2.0cm)
  #dnode(6.4cm, 1.5cm, 9.2cm, 1.0cm, "Tests: were you a participant or a contributor?")
  #darrow(2.6cm, 2.5cm, 2.6cm, 3.1cm)
  #dnode(0cm, 3.1cm, 5.2cm, 1.0cm, "L2  \"Why that, and not X?\"")
  #darrow(5.2cm, 3.6cm, 6.4cm, 3.6cm)
  #dnode(6.4cm, 3.1cm, 9.2cm, 1.0cm, "Tests: did you decide, or did it just happen?")
  #darrow(2.6cm, 4.1cm, 2.6cm, 4.7cm)
  #dnode(0cm, 4.7cm, 5.2cm, 1.0cm, "L3  \"How did you know it worked?\"")
  #darrow(5.2cm, 5.2cm, 6.4cm, 5.2cm)
  #dnode(6.4cm, 4.7cm, 9.2cm, 1.0cm, "Tests: do you check, or do you assume?")
]

#formulas(title: "Prepare every story to level three")[
For each story, write the answers to:
+ *L1.* What exactly did you do, personally, in that step?
+ *L2.* Why that choice and not the obvious alternative? What did you give up?
+ *L3.* How did you know it worked? What did you measure or observe?
+ *L4 (bonus).* What would you do differently now?
+ *L5 (bonus).* What is the one thing about that story you are least proud of?

If any answer is "I do not remember", say exactly that. *"I do not remember the number, but it was
roughly a quarter of the page"* is a completely acceptable answer. *Inventing* the number is not,
and a follow-up will usually expose it, because invented numbers do not stay consistent.
]

#ex(15, tier: 3, asked: "Amazon · pattern")[
Here is Story 7 (the four-second page) taken down five levels. Read the probes, not just the
answers -- you are going to run this drill on your own stories.
]
#sol[
*I:* "You said you put timers in. Where exactly, and how?" *(L1 -- is this real?)*

*A:* "Three `performance.now()` calls in the click handler: before the fetch, after the response
was parsed, and after the DOM update, and I logged the three differences to the console. It was
about six lines and I deleted them afterwards, which in hindsight I should not have done."

*I:* "Why not just add server caching, which is what you had planned?" *(L2 -- was it a decision?)*

*A:* "Because the plan was based on a guess and it would have cost me the evening. Measuring cost
me about 15 minutes. The general rule I was using is that when a fix is expensive and the
diagnosis is cheap, do the diagnosis first."

*I:* "How did you know the fix actually worked, and not that the wifi was just better?" *(L3 --
do you check?)*

*A:* "That was a real risk on our campus. I measured on the same phone, in the same room, within
the same half hour, five clicks before and five after, and I used the median rather than the
best. The before numbers were about 3.9 to 4.3 seconds and the after were 0.6 to 0.9."

*I:* "What would you do differently?" *(L4)*

*A:* "Two things. I would not have deleted the timing code -- I would have put it behind a flag so
the next person can turn it on. And I would have checked on a slower phone, because mine was
fairly new and the render cost is exactly what varies by device."

*I:* "What part of it are you least proud of?" *(L5)*

*A:* "That I was one command away from spending an evening optimising something that took 80
milliseconds. The measuring habit was not mine yet at that point -- I only did it because a
classmate asked me how I knew the server was slow, and I did not have an answer."
]

#trick[
*The L5 answer is the one that is remembered.* Notice it gives credit to the classmate. Giving
credit costs you nothing and it is one of the strongest honesty signals available, because people
who invent stories always star in them alone.
]

#subsection[What to say when you genuinely do not know]

#table(columns: 2, align: (left, left),
  [*Say this*], [*Not this*],
  ["I do not remember the exact number. It was roughly a third."], [A precise invented number],
  ["I did not measure that. What I observed was that nobody complained again."], ["It improved by 40 percent"],
  ["That part was my teammate's -- I can tell you what I saw from outside."], [Claiming it],
  ["I did not consider that alternative at the time. Thinking about it now..."], ["Yes we considered it" (you did not)],
  ["I got that wrong. What I should have done is..."], [Defending a decision you now think was bad],
)

#note[Every line on the left makes you *more* hireable, not less. Interviewers are testing
calibration -- whether you know the difference between what you measured, what you observed, and
what you assume. Most candidates do not, and that is a much bigger problem than a missing number.]

// ==================================================================
#section[Principle-driven behavioural rounds]

Some large product companies publish a written list of leadership principles or values, and their
interviewers are trained to score your stories against specific items on that list. Amazon is the
best-known example; several others run a similar system under different names.

#formulas(title: "How to prepare for one, in four steps")[
*1. Read their actual published list.* It is on their careers site, in their own words. Do not
rely on a summary, and do not rely on this book -- lists get revised.

*2. Group the items into the themes you already have.* Most published lists reduce to a familiar
set: ownership, customer focus, high standards, acting without perfect information, digging into
detail, disagreeing and then committing, frugality or doing more with less, and developing
others.

*3. Map two stories to each group.* Two, not one. Interviewers in these loops compare notes, and
telling the same story in three rounds looks thin.

*4. Prepare each story to L5.* These loops probe harder than anything else you will face as a
fresher. One story, five levels, is worth more than five stories, one level.
]

#subsection[The vocabulary shift]

You do not need to quote their principle names. In fact, quoting them mechanically ("this shows
my customer obsession") sounds rehearsed. What you *should* do is make sure the behaviour is
visible in the story.

#table(columns: 2, align: (left, left),
  [*If the principle is about...*], [*Your story must contain...*],
  [Ownership], [You acted on something that was not assigned to you, and you stayed with it to the end],
  [Customer focus], [A real user, their actual words, and a change you made because of them],
  [High standards], [A time you were not satisfied with something that had already passed],
  [Acting fast with incomplete data], [A decision made without full information, and what risk you accepted],
  [Digging into detail], [A number, a log line, a query plan -- something at the level of the actual thing],
  [Disagree then commit], [A disagreement you lost, and what you did the next day],
  [Doing more with less], [A constraint -- no budget, no server, no time -- and a smaller solution],
  [Developing others], [Someone who can now do something they could not, and how you know],
)

#ex(16, tier: 3, asked: "Amazon · pattern")[
"Tell me about a time you had to make a decision without all the information you wanted."
]
#sol[
*(S)* "Two days before the fest, I had to decide whether the pre-order site could handle the
lunch rush. I had never load-tested anything and I had no way to get 200 real students to click
at once."

*(T)* "The decision was binary: tell the canteen manager to use it for lunch, or tell him to keep
paper for the busiest hour. Getting it wrong in the direction of over-confidence meant a queue
and a bad first impression the site would never recover from."

*(A)* "I could not get certainty, so I tried to bound the risk instead. I wrote a 20-line script
that fired 50 concurrent orders against my laptop server and I ran it three times; nothing broke
and the slowest response was about 400 milliseconds. That is not proof for 200 real users on
campus wifi, and I said so explicitly rather than pretending the test was more than it was. So I
proposed a fallback rather than a decision: use the site for lunch, but keep the paper token pad
at the counter, and agree in advance on the trigger for switching -- if the counter sees any
order not appearing within a minute, he stops using the site and we go back to paper for that
day. I also made sure the order list page worked without JavaScript, so a slow phone would still
show him the queue."

*(R)* "We used it, it held, and the paper pad was never opened. What I would keep is the agreed
trigger. The decision I actually made was not 'the system will work' -- it was 'I know how we find
out cheaply and what we do if I am wrong'."
]

#trick[
*Acting-without-information stories should contain a reversal plan.* The scored behaviour is not
recklessness, it is moving forward while keeping the cost of being wrong small. "Here is how we
would have found out within a minute, and here is what we would have done" is the whole answer.
]

// ==================================================================
#section[One event, four questions]

You do not need 12 events. You need 8, and the skill of *angling* one event at whatever was
asked. Here is a single event -- the library search feature from Example 1 -- answering four
different questions. The facts never change. The emphasis does.

#formulas(title: "How to angle a story in ten seconds")[
+ Hear the question. Name the *theme* it is really asking about.
+ Pick the event that has the strongest evidence for *that* theme.
+ Move the matching moment to the front of your Action, and shrink everything else.
+ End the Result with a lesson that answers *their* question, not the story's most obvious one.

The thing you are changing is *which two sentences get the detail*.
]

#ex(17, tier: 1, asked: "TCS · pattern")[
Question A: "Tell me about a time you improved something."
]
#sol[
*(A, emphasis on the improvement)* "...I timed the three queries the demo needed. Title search
took about two seconds on 9,000 rows because it scanned the whole table. I added an index on the
title column and rewrote the query to filter before joining. It went to under a tenth of a
second."

*(R)* "Search went from about 2 seconds to under 0.1, and I have used the same 'time it first'
check on every project since."
]

#ex(18, tier: 2, asked: "Shopee · pattern")[
Question B: "Tell me about a time you found a problem nobody else had noticed."
]
#sol[
*(A, emphasis on the discovery)* "...Nobody had reported the search being slow, because with our
test data of 50 books everything felt instant. I loaded a copy of the real catalogue -- about
9,000 rows -- before the demo, mostly out of caution, and that is when the two seconds appeared.
So the problem only existed at real size, and our test data was hiding it. I then checked the
other two queries at real size as well, and one of them was fine, which told me it was not a
general database problem."

*(R)* "We found it a week before the demo instead of during it. The habit I kept is loading
realistic data early -- toy data hides exactly the class of bug that matters."
]

#ex(19, tier: 1, asked: "Wipro · pattern")[
Question C: "Tell me about a time you worked with feedback from others."
]
#sol[
*(A, emphasis on the feedback loop)* "...Once it was fast I asked two classmates to try to break
it, before I told anyone it was done. They found something I would never have tried: an empty
search returned all 9,000 rows and froze the page. I had only ever typed real words into it. I
added a two-character minimum and a clear message instead of an empty list, and I asked them to
try again rather than assuming my fix matched what they meant."

*(R)* "The empty-search bug would have appeared in the demo in front of the class. What I do now
is hand the thing to someone else before I call it finished, because I only test the inputs I
already imagined."
]

#ex(20, tier: 3, asked: "Adobe · pattern")[
Question D: "Tell me about a time you had to explain something technical to someone who did not
have your background."
]
#sol[
*(A, emphasis on the communication)* "...My teammates could see the search was faster but not why,
and one of them wanted to add the same index to every column 'to be safe'. So instead of talking
about B-trees I used the back of the book: I asked him how he would find a title in a 9,000-page
book with no index, then with one, then asked what it would cost to keep an index for every word
on every page updated. He worked out the trade-off himself in about a minute. I then wrote the
three timings into our shared sheet so the reasoning was visible without me."

*(R)* "He dropped the every-column idea and indexed one more column that genuinely needed it. The
lesson I keep is to explain with something the person already has in their hands, and to write the
numbers down so the explanation outlives the conversation."
]

#note[Four questions, one event, zero invention. Every fact appears in the original story. This
is why the story *bank* matters more than a set of prepared answers: prepared answers only fit
the questions you predicted.]

// ==================================================================
#section[Depth control: the 30-second and the 2-minute version]

Not every behavioural question deserves two minutes. Some are asked in a 15-minute HR round as
filler; some are the whole point of a 45-minute loop. Prepare both lengths for your top stories.

#formulas(title: "Two lengths, one story")[
*The 30-second version.* One sentence of Situation and Task combined, two sentences of Action
with only the decisive step, one sentence of Result with the number. Then *offer the depth*:
"I can go into how I found it, if that is useful."

*The 2-minute version.* Full STAR, with the decisions visible and one moment where you were
wrong.

*How to choose.* Short round, rapid questions, or a question asked in passing -- go short and
offer. Dedicated behavioural round, or the interviewer leans in and says "walk me through it" --
go long.
]

#ex(21, tier: 1, asked: "Capgemini · pattern")[
Compress Story 3 (the fest deadline) to 30 seconds without losing the decision.
]
#sol[
*30-second version.*

"Two days before our college fest, the ordering site still had no payment feature and I had about
14 hours. I listed what was actually blocking the fest, and only ordering itself was -- so I
proposed cash at the counter, which is how they already worked, and spent the time on the order
flow instead. It handled about 200 orders over three days, and nobody missed the payment feature.
I can go into how I chose what to cut, if that is useful."

That is 78 words, about 36 seconds. The *decision* survives the compression, which is the test.
If your short version loses the decision, you have compressed the wrong sentences.
]

#trap[
*Do not compress by speaking faster.* A two-minute answer delivered in 75 seconds is not a short
answer, it is an unintelligible one. Compress by *removing sentences*, and keep your speed at
about 130 words per minute.
]

// ==================================================================
#section[Behavioural questions in disguise]

Some questions do not begin with "tell me about a time", but they are still scored on evidence.
The fix is the same: answer with a specific event.

#subsection[a. "How do you handle criticism?"]

#trap[
*Weak.* "I take criticism positively and I see it as an opportunity to improve myself." A policy
statement. Everyone says it. Nothing is scored.
]

#sol[
*Strong.* "I will give you an example rather than a claim. A faculty member told me in front of
her colleagues that my attendance tool was useless. My first reaction was to defend it, and I did
start to, which made it worse. What worked was asking to watch her use it -- she was doing an
entry that took four and a half minutes because she taught two sections and my screen made her
re-select everything. The criticism was accurate and my model of the user was wrong. I added one
button, about 20 lines, and entry dropped to about 50 seconds.

What I changed in myself: I now ask to see the problem before I explain my design. The defending
instinct has not gone away; I just do not act on it in the first minute."
]

#trick[
*"The instinct has not gone away, I just do not act on it" is a strong sentence*, because it is
honest about a habit rather than claiming a cure. Claims of complete self-transformation are not
believed by anyone who has managed people.
]

#subsection[b. "How would you describe your working style?"]

#sol[
*Strong.* "Three things, each with an example.

I write things down -- the one-page map of which screen touches which table is still in that
project's README, and I wrote it for myself before anyone asked.

I measure before I change -- I have been wrong about the cause often enough that I do not trust
my first guess any more.

And I am slower than most to ask for help, which is the part I am actively working on with a
45-minute rule. That is a genuine cost, not a hidden strength."
]

#note[Ending a "working style" answer on a real limitation makes the first two claims credible.
An answer with only good parts is a sales pitch, and it is heard as one.]

#subsection[c. "What motivates you?"]

#trap[*Weak.* "I am motivated by challenges and by learning new things." True of everyone,
evidence for nothing.]

#sol[
*Strong.* "Somebody using the thing. The clearest signal I have is that I worked much harder on
the attendance tool, which three teachers actually used, than on a bigger project that was only
graded. With the tool I got messages when it broke, and that was oddly motivating -- it meant it
mattered to someone.

The honest opposite is also true: I lose energy on work that nobody will use, and I have to
manage that deliberately rather than pretend it is not the case."
]

#subsection[d. "Tell me about a time you received feedback you disagreed with."]

#sol[
*Strong. Structure: HEARD - CHECKED - ACTED.*

"My project guide told me my report was too long and that I should cut the background section by
half. I disagreed -- I thought the background was what made the design choices make sense.

*(HEARD)* Rather than argue from my opinion, I asked what specifically was not working, and he
said he could not find the actual contribution. That was a different complaint from 'too long'.

*(CHECKED)* I gave the report to two classmates with one question: after reading it, what did I
build? Both of them described the background rather than my part. So he was right about the
problem, even though I still think 'cut it in half' was the wrong prescription.

*(ACTED)* I kept the background at about the same length but moved it after my contribution and
added a one-paragraph summary at the top. He accepted it. What I take from that is to separate
the observation from the prescription -- people are usually accurate about what is wrong and less
reliable about the fix."
]

#tier-header(2)

#section[Cross-cultural behavioural questions]

Regional rounds add a specific worry: this person has only worked with people exactly like
themselves, in one language, in one office. The questions test whether you can adapt.

#ex(22, tier: 2, asked: "Grab · pattern")[
"You would be working with people in three countries who do not share your first language or your
working hours. Tell me about a time you had to adjust how you communicate."
]

#trap[
*Weak.* "I am very adaptable and I can adjust with any kind of people. I have good communication
skills and I believe respect is the most important thing." Three claims, no event, and it would
be said identically by someone who has never worked with anyone.
]

#sol[
*Strong.*

*(S)* "Our fest team included students from two states and a group whose classes ran in the
evening, so we were rarely in the same room, and our shared language was English, which was the
second or third language for most of us."

*(T)* "I was coordinating registrations and I kept getting things done wrong -- not through
unwillingness, but because my instructions in a group chat were being read differently by
different people."

*(A)* "I changed three specific things. First, I stopped giving instructions verbally in the
corridor and started writing them, because a written message can be re-read by someone who did
not catch it the first time. Second, I stopped asking 'is that clear?', which always gets a yes,
and started asking the person to tell me back what they were going to do -- twice this revealed a
completely different plan. Third, for the evening group I wrote a short end-of-day summary with
what was decided and what was open, so they did not have to reconstruct it from 60 chat messages.
I also started writing dates as '12 March' rather than in numbers, after two people read the same
date in different orders."

*(R)* "Registration errors dropped to almost none in the last two weeks, and the end-of-day
summary was kept for the next year's team. What transfers to a multi-country team is the
repeat-back habit -- it is the only cheap way I know to find out that 'yes' meant 'I did not
follow'."
]

#table(columns: 2, align: (left, left),
  [*Behaviour*], [*Why it travels across cultures and time zones*],
  [Write it, do not say it], [Re-readable by a non-native speaker, and by someone who was asleep],
  [Ask for a repeat-back, not "is it clear?"], [In many cultures "yes" is politeness, not agreement],
  [Written end-of-day summary], [The only handover a different time zone actually gets],
  [Unambiguous dates and numbers], [Date order and decimal marks differ by country],
  [Name the decision and the owner], [Prevents "everyone thought someone else had it"],
  [Ask, do not assume, about how disagreement is shown], [Directness is normal in some places, rude in others],
)

#ex(23, tier: 2, asked: "DBS · pattern")[
"Tell me about a time you worked with someone whose way of working was very different from
yours."
]
#sol[
*(S)* "In my final-year team, one teammate planned everything on paper before writing a line, and
I prefer to build a rough version and fix it. We annoyed each other for about two weeks."

*(T)* "We shared the backend, so our two styles were colliding in the same files."

*(A)* "I stopped treating it as a personality clash and tried to find where each style was
actually better. His planning was clearly better for the database schema, because changing a
schema after data exists is expensive -- I had already caused one painful migration by guessing.
My way was better for the screens, where the fastest way to find out what was wrong was to show
somebody something. So we split it that way explicitly, and I said out loud that the schema
decision was his to make. I also asked him to keep his plan to one page, because his first
version was six and nobody would have read it."

*(R)* "We stopped colliding, the schema only changed once after that, and the screens went through
four quick rounds with our guide. What I took from it is that a working-style difference is
usually a disagreement about where the expensive mistakes are, and those are different in
different parts of a system."
]

#trick[
*Never resolve a style difference by declaring one style correct.* The answer that scores is the
one that finds where each is cheaper. It shows you can work with people you disagree with,
which is the actual thing being tested.
]

// ==================================================================
#section[A behavioural round, annotated]

Twenty minutes, three questions, with the interviewer's notes.

#formulas(title: "Transcript")[
*I:* "Tell me about a time you disagreed with someone and lost the argument."

*A:* Gives Story 8 -- the app-versus-web disagreement -- and ends on the *second* disagreement,
the report format, which he lost and then implemented the same day.
#h(1em) #text(fill: muted)[Note: answered the question as asked, including the losing part, which
half of candidates skip. Committed the same day. Distinguishes evidence from preference.]

*I:* "You said you measured six hours to build the offline web version. How did you know it was
six and not three days?"
#h(1em) #text(fill: muted)[L3 probe on the one number in the story.]

*A:* "I did not estimate it -- I built it. I spent one evening, about six hours, getting a page
that stored entries in local storage and pushed them when the signal returned. It was ugly and it
only handled one field. But I brought a working thing to the meeting rather than an estimate,
because my estimates at that point were not worth much."
#h(1em) #text(fill: muted)[Strong. The number was measured, not guessed, and he knows the
difference. Prototyped instead of arguing.]

*I:* "What is a mistake you made in that project?"

*A:* Gives the deleted-data story. Owns it in the first sentence. 200 records, 3 people, recovered
about 180 from a debug log, then backups, a confirm prompt and a coloured prompt.
#h(1em) #text(fill: muted)[Told the faculty member the same afternoon before it was discovered.
The prevention is systemic, not a promise to be careful. Would hire on this answer alone.]

*I:* "Last one -- what would you have done if the log file had not existed?"
#h(1em) #text(fill: muted)[Testing whether the recovery was luck or method.]

*A:* "Then about 200 records were simply gone and my only honest option was the same one I took
for the last 20 -- go to each teacher, tell them exactly which sessions were affected, and ask
them to re-enter from their registers. It would have been about ten times the apology and roughly
a day of their time. The log made the recovery possible, but the log was an accident -- I had added
it months earlier for a different reason. That is exactly why I set up the nightly copy: I do not
want the next recovery to depend on luck."
#h(1em) #text(fill: muted)[Does not pretend the log was foresight. Separates luck from method.
Recommend hire.]
]

// ==================================================================
#section[The anti-pattern list]

#trap[
*Twelve ways a behavioural answer fails.*

+ *Hypothetical.* "I would..." instead of "I did...".
+ *All Situation.* Two-thirds scene-setting, nine words of action.
+ *The "we" fog.* No sentence in the Action starts with "I".
+ *No decision.* Things happened; nobody chose anything.
+ *No result.* The story just stops.
+ *Fake numbers.* Precise figures for things you never measured.
+ *Villains.* A lazy teammate, an unreasonable professor, a stupid user.
+ *The refused failure.* "I cannot think of a failure."
+ *Upgrading.* A four-person project becomes "a team of ten".
+ *Same story three times.* A round has three interviewers and they compare notes.
+ *No reflection.* Nothing learned, nothing you would change.
+ *Endless.* Four minutes with no structure. If you cannot see the end, stop and ask: "Is that
  the level of detail you wanted, or should I go deeper on one part?"
]

#trick[
*The rescue line.* If you are two minutes in and lost, do not push on. Say: "Let me get to the
point -- what I actually did was..." and give your Action and Result. Interviewers respect a
self-correction far more than a slow collapse, and every one of them has seen candidates never
recover from a rambling start.
]

// ==================================================================
#section[The one-page story sheet]

Write one of these for each of your 8 to 10 events. Handwriting is fine. Keep them in one file
and reread them the night before an interview -- not to memorise the words, but to reload the
facts.

#formulas(title: "Story sheet template — copy this eight times")[
*Event name* (for you only): #h(1fr) #line(length: 60%, stroke: 0.4pt + rule)

*When and where:* #h(1fr) #line(length: 65%, stroke: 0.4pt + rule)

*Themes it can serve:* #h(1fr) #line(length: 60%, stroke: 0.4pt + rule)

*S* (max 2 sentences, no excuses): #h(1fr) #line(length: 100%, stroke: 0.4pt + rule)
#line(length: 100%, stroke: 0.4pt + rule)

*T* (what I owned, what "done" meant): #h(1fr) #line(length: 100%, stroke: 0.4pt + rule)
#line(length: 100%, stroke: 0.4pt + rule)

*A* (every sentence starts with "I"; mark each decision with a star):
#line(length: 100%, stroke: 0.4pt + rule) #line(length: 100%, stroke: 0.4pt + rule)
#line(length: 100%, stroke: 0.4pt + rule) #line(length: 100%, stroke: 0.4pt + rule)

*R* (number, plus what I would change): #h(1fr) #line(length: 100%, stroke: 0.4pt + rule)
#line(length: 100%, stroke: 0.4pt + rule)

*Numbers, marked M / O / G:* #h(1fr) #line(length: 60%, stroke: 0.4pt + rule)

*What teammates did (credit them by name):* #h(1fr) #line(length: 55%, stroke: 0.4pt + rule)

*L1 — exactly what I did:* #line(length: 100%, stroke: 0.4pt + rule)

*L2 — why that, not the alternative:* #line(length: 100%, stroke: 0.4pt + rule)

*L3 — how I knew it worked:* #line(length: 100%, stroke: 0.4pt + rule)

*L4 — what I would do differently:* #line(length: 100%, stroke: 0.4pt + rule)

*L5 — least proud of:* #line(length: 100%, stroke: 0.4pt + rule)

*30-second version (about 70 words):* #line(length: 100%, stroke: 0.4pt + rule)
#line(length: 100%, stroke: 0.4pt + rule)
]

#note[The sheet is a fact store, not a script. On the day you will say it differently, and that is
correct. What must not change between tellings are the facts and the numbers -- inconsistency
across two interviewers in the same loop is one of the few things that reliably fails a
candidate.]

// ==================================================================
#section[Practice]

#practice(tier: 1, time: "3 hours, spread over a week")[
+ List 10 real events from your life: projects, group work, a fest, teaching, a job, a family
  responsibility, a competition. One line each. No judging yet.

+ Fill in the `myStories` array of `bank.js` with your own events and themes. Run it. Write down
  which themes come back EMPTY.

+ For the empty themes, either find a forgotten event, or accept the gap and plan something real
  in the next month to fill it. Do not invent one.

+ Take your strongest event and write it out in full STAR, with the four labels written in.

+ Split it into four strings and run `star.py`. Fix the split until every part says "ok".

+ Rewrite your Action so every sentence starts with "I", and cut any sentence that cannot honestly
  do so.

+ Find every number in your story. For each, mark it M (measured), O (observed) or G (guessed).
  Rewrite every G with "about", or remove it.

+ Delete every excuse from your Situation: busy, no time, bad teammates, poor internet.

+ Record yourself telling it. Target 90 to 120 seconds.

+ Repeat for a failure story, using OWN-COST-FIX-PREVENT. Choose a failure with a real cost.

+ Fill one complete story sheet, including the 30-second version, for your strongest event.

+ Take that one event and angle it at four different questions: improved something, found a
  problem, used feedback, explained something. Change only which sentences get the detail.
]

#key[
1. Ten events is plenty. Most students stop at three because they only look at "projects".
2. Two or three empty themes is normal on the first run. Empty is information, not failure.
3. The honest fill is: take a club role, teach a junior, file a real bug report, help on an
open-source issue. A month is enough for a true small story.
4. If you cannot write the T line, you did not own anything in that event -- pick a different one.
5. Almost every first draft comes back "S too fat, A too thin". Cut the Situation to two
sentences first; that alone usually fixes both.
6. Sentences that resist "I" are usually background. They belong in S, or nowhere.
7. Interviewers do not punish "about". They punish precision you cannot defend.
8. Excuses in the Situation predict excuses on the job. That is exactly how they are read.
9. Under 60 seconds means no Action detail. Over 150 means you are telling two stories.
10. If your failure has no cost, it is not a failure, it is a humblebrag in disguise.
11. The 30-second version is right when the decision survives. If only the outcome survives, you
cut the wrong sentences.
12. If angling requires you to add a fact that is not in the original event, stop -- you have
started inventing. Pick a different event for that question.
]

#practice(tier: 2, time: "2 hours")[
+ Write a story where you decided something using evidence, and the evidence *surprised* you.
  The surprise is the point.

+ Write a disagreement story using UNDERSTAND-EVIDENCE-PROPOSE-DEFER where *you lost*. Say what
  you did the next day.

+ Write an ambiguity story. Name the specific technique you used to reduce the uncertainty --
  watching the real work, writing it back in their words, demoing early, building the smallest
  version.

+ Take one story and rewrite the Result so it contains a measured number, an observed outcome,
  and a lesson that is about your *method*, not about the specific fix.

+ Write a story involving someone whose assumptions were different from yours -- a different
  department, a different year, a non-technical user, a different language. What did you change in
  how you communicated?
]

#key[
1. No surprise means you probably did not use the data, you just decorated a decision you had
already made.
2. The "I lost and committed anyway" story is rarer and more valuable than the one where you were
right. Most people only prepare the second.
3. Vague coping ("I just figured it out") scores nothing. A named technique scores, because it
can be repeated on their team.
4. Measured: "0.6 to 0.9 seconds, median of five." Observed: "she stopped asking for the paper
form." Method lesson: "measure before optimising."
5. Good answers change something concrete: shorter sentences, a written summary after the call,
a diagram instead of a paragraph, confirming understanding by repeating it back.
]

#practice(tier: 3, time: "4 hours, and one mock")[
+ Take your three strongest stories. For each, write the L1, L2, L3, L4 and L5 answers in full.

+ Mark every number in those answers M, O or G again. Any G that survives to L3 will break you.

+ For each story write the sentence you would say if you did not remember a detail. Practise
  saying it without apologising.

+ Find the published values or principles list of one company you are applying to, from their own
  site. Group the items into themes. Map two of your stories to each group. Note where you have
  nothing -- that is your gap, and it is better to know it now.

+ Write one story that contains a decision made without enough information, including the
  reversal plan and the trigger for using it.

+ Do a 30-minute mock where a friend asks one behavioural question and then only asks "why?" or
  "how did you know?" until you run out. Write down the level at which you ran out.

+ For your weakest story, write the answer to "what are you least proud of in that?"
]

#key[
1. Most candidates are solid at L1, thin at L2, and empty at L3. Preparing L3 is the single
highest-value hour in this chapter.
2. Guessed numbers drift between tellings. A second interviewer in the same loop will notice.
3. "I do not remember the exact figure -- it was roughly a third" said calmly, once, with no
apology, reads as confidence, not weakness.
4. Two stories per group. If three groups have nothing, you do not have a story problem, you have
an experience problem -- and the fix is real work in the world, not better writing.
5. The reversal plan is the answer. Speed without a way back is recklessness, and it is scored as
such.
6. Running out at L2 means you are describing events, not decisions. Running out at L4 is normal
and fine.
7. If nothing comes to mind, you are probably still defending the story. Every real story has a
part you would rather not mention; that part is the most credible thing you own.
]

// ==================================================================
#revision[
*STAR, and the word budget.* S 15% · T 10% · A *60%* · R 15%. Ninety to 120 seconds.
Say the labels out loud if it helps. Most students invert S and A -- that is the top failure.

*The "I" rule.* "We" in the Situation. "I" in every Action sentence. If a sentence cannot honestly
start with "I", it is background -- move it or cut it. Name what teammates did; it makes your own
claims believable.

*The four sub-structures.*
#table(columns: 2, align: (left, left),
  [*Story type*], [*Structure*],
  [Failure], [OWN -- COST -- FIX -- PREVENT],
  [Leadership without a title], [NOTICED -- PROPOSED -- MADE IT EASY -- FOLLOWED UP],
  [Disagreement], [UNDERSTAND -- EVIDENCE -- PROPOSE -- DEFER],
  [Deadline], [It is a *scope* story: what did you drop, how early, and who did you tell],
)

*The eight themes.* conflict · failure · deadline · leadership · learning fast · helping someone ·
data decision · pushed back. Eight to ten real events cover all of them. Collect *events*, not
answers.

*The probe ladder.* L1 what did YOU do · L2 why that and not X · L3 how did you know it worked ·
L4 what would you change · L5 what are you least proud of. Prepare your top three stories to L5.

*Calibration beats precision.* M (measured) / O (observed) / G (guessed). Say "about" for
anything guessed. "I do not remember the exact number" is a strong answer. An invented number is
a failed interview.

*The substitution rule, one last time.* Every filled example in this chapter belongs to an
invented student. Keep the structures. Replace every fact with your own real experience. If a
slot cannot be filled truthfully, the answer is not ready -- go and do something real, however
small, and then fill it.

*Never.* Hypotheticals. Villains. Upgraded team sizes. Invented numbers. "I have never failed."
The same story in three rounds. A four-minute answer with no end in sight.
]

]
