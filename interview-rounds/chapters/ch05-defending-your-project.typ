#import "../../shared/lib/style.typ": *

#chapter(num: 5, title: "Defending Your Project",
  tagline: "They are not testing the project. They are testing whether you built it.")[

#section[Pattern in one page]

Your resume says you built something. The next twenty minutes decide whether the
interviewer believes you.

That is the whole round. Not "is this a good project". Not "is this a big project".
Only: *did this person actually build this, and do they understand what they built?*

#formulas(title: "The four things a project round scores")[

*1. Ownership.* Can you say what YOU did, in a group of four, without vague words like
"we worked on" and "I was involved in"?

*2. Depth.* When they push one level deeper than your prepared line, is there anything
there? Most candidates have one layer. Good candidates have four.

*3. Trade-off thinking.* Every choice you made had an alternative. Do you know what it
was, and why you did not pick it?

*4. Honesty.* Do you say "I do not know" cleanly, or do you bluff? Bluffing is the
fastest way to fail this round. An interviewer who catches one bluff stops believing
everything else you said.
]

#note[
Everything in this chapter is a *structure*, not a script. Every filled example uses a
made-up project so you can see the shape. *You must replace every fact with your own real
project.* If you memorise my example and say it in a room, the first follow-up question
will destroy you, because you cannot answer follow-ups about a project you did not build.
]

#subsection[Why candidates fail this round]

#table(columns: 2,
  align: (left, left),
  [*What the interviewer hears*], [*What they write down*],
  [“We used MongoDB because it is fast.”], [Repeating a tutorial. No real reason.],
  [“My friend did the backend, I did the frontend, but I know all of it.”],
  [Cannot separate own work from team work.],
  [“There were no major problems.”], [Either the project is trivial or he is hiding.],
  [“It can handle any number of users.”], [Never measured anything. Never load tested.],
  [A confident wrong answer about their own code.], [Bluffing. Stop trusting this candidate.],
  [“I would add more features.”], [No engineering reflection, only product wishes.],
)

#section[The Project Defence Sheet]

Before any interview, fill this sheet for *each* project on your resume. One page per
project. Written by hand is fine. You prepare this once and it serves every company.

#formulas(title: "The 12 lines you must be able to say without thinking")[

+ *Problem.* Who had a pain, and what was the pain? One sentence, no technology words.
+ *Users.* Real or imagined? How many? Be honest: "a demo with 30 test users from my
  class" is a perfectly good answer.
+ *What it does.* Three features, named. Not ten.
+ *Stack.* Every technology, and *one honest sentence of why* for each.
+ *My part.* What you personally wrote, by file or module or feature.
+ *Their part.* What your teammates wrote. Naming this makes your own claim believable.
+ *Data model.* The 4–6 main tables or collections and how they link.
+ *One request end-to-end.* A user taps a button. Trace it to the database and back.
+ *One number.* Anything you measured: rows, requests, milliseconds, file size, users,
  test count. One real number beats ten adjectives.
+ *What broke.* One real bug or failure, with the cause and the fix.
+ *A trade-off.* One choice with a named alternative you rejected, and why.
+ *What you would change.* Two things, engineering, not features.
]

#trick[
Line 9, the *one number*, is the highest-value line on the sheet. Candidates who have a
number sound like engineers. Candidates who have none sound like students describing a
poster. If you never measured anything, go measure something tonight — even
`console.time()` around your slowest page gives you a number you own.
]

#subsection[A filled sheet — the example project used in this chapter]

I will use one made-up project all chapter so you can watch it survive hard questions.
*Your project is different. Substitute yours everywhere.*

#table(columns: 2,
  align: (left, left),
  [*Line*], [*Filled*],
  [Problem], [Our hostel mess had a paper sign-up sheet for meals. Cooks over-ordered food and threw it away.],
  [Users], [78 students in one hostel block, 6 weeks of real use. Not a company, a real but small user base.],
  [What it does], [(1) A student marks meals in or out for tomorrow. (2) The cook sees a count per meal by 9 pm. (3) A weekly waste report.],
  [Stack], [Node + Express API, PostgreSQL, plain HTML/JS front end, deployed on one small cloud VM.],
  [My part], [The API, the database schema, the 9 pm cut-off job, and the report query.],
  [Their part], [Ravi wrote the front end. Meera did the deployment and the login screen.],
  [Data model], [`students`, `meals`, `opt_ins`, `daily_counts`.],
  [One request], [Student taps "skip dinner" → `POST /optin` → check cut-off time → upsert row in `opt_ins` → return new count.],
  [One number], [The report page took 4.1 s with 6 weeks of data; after one index it took 0.2 s.],
  [What broke], [Two taps on a slow phone created two rows and the count went wrong twice.],
  [Trade-off], [Chose Postgres over MongoDB because the weekly report is a join and a group-by.],
  [Would change], [(1) Make the opt-in endpoint idempotent properly. (2) Store counts in one place, not two.],
)

#section[The 90-second project pitch]

Almost every project round opens the same way: *"Tell me about this project."*
You get roughly 90 seconds before they interrupt with a real question. Those 90 seconds
decide which questions they ask.

#formulas(title: "Pitch structure — six beats, about 15 seconds each")[
+ *Pain.* Who suffered, and how.
+ *Fix.* What the thing does, in one line.
+ *Scope.* How big and how real. Honest size.
+ *Stack.* Named, with one reason.
+ *My part.* Your own words: "I wrote…"
+ *Result.* The one number, plus one honest limit.

Then *stop talking.* Silence invites them to choose the next question, and you have just
given them six safe places to choose from.
]

#ex(1, tier: 1, asked: "Infosys · pattern")[
"Tell me about the project at the top of your resume."
]

#trap[
*WEAK answer*

"So basically this is a full-stack web application which I have made using the MERN
stack. It has login, signup, user dashboard, admin dashboard, and CRUD operations. I have
used React for the frontend because React is very popular and fast, Node and Express for
backend, and MongoDB as database because it is a NoSQL database and it is scalable. We
worked on it as a team of three and it was a great learning experience. It is fully
responsive and can handle any number of users."
]

#sol[
*STRONG answer*

"Our hostel mess used a paper sheet for meal sign-ups, so the cooks guessed the count and
threw food away most nights.

We built a small web app where a student marks tomorrow's meals in or out, and the cook
sees the counts at 9 pm.

It ran for six weeks in one block, about 78 students, so it is small but the users were
real.

It is a Node and Express API with Postgres. We chose Postgres because the weekly waste
report is a join and a group-by, and I wanted SQL for that.

I wrote the API, the schema and the 9 pm cut-off job. Ravi wrote the front end and Meera
did deployment.

The report page originally took 4.1 seconds; adding one index on `opt_ins(meal_date)`
brought it to 0.2 seconds. The main weakness is that the opt-in endpoint is not properly
idempotent — I can talk about that if it is useful."
]

#subsection[Name exactly what changed]

#table(columns: 3,
  align: (left, left, left),
  [*Beat*], [*Weak version*], [*Strong version*],
  [Pain], [Missing. Starts from technology.], [One concrete human problem: food thrown away.],
  [Fix], [“CRUD operations, dashboards.”], [Two named features a person can picture.],
  [Scope], [“Can handle any number of users.”], [78 students, 6 weeks. Small and honest.],
  [Stack reason], [“React is popular”, “Mongo is scalable”.], [A reason tied to *this* app's query shape.],
  [My part], [“We worked on it as a team.”], [Named modules for self and for teammates.],
  [Result], [“Great learning experience.”], [4.1 s → 0.2 s, plus a named weakness.],
  [Ending], [Trails off into buzzwords.], [Stops, and offers one door to walk through.],
)

#trap[
*The buzzword trap.* "Scalable", "robust", "user-friendly", "optimised", "industry
standard" are worth zero marks each. They are adjectives with no evidence. Every one of
them invites the question "how do you know?" — and if you cannot answer that, the
adjective has cost you, not helped you.
]

#note[
Say the pitch out loud with a timer. If it runs past 100 seconds you will be interrupted
mid-sentence and lose the ending, which is where your number lives. Cut, do not speed up.
]

#section[Draw the architecture in 60 seconds]

Many interviewers will say "draw it". On paper, on a whiteboard, or by sharing a screen.
Practise this until it is automatic. Boxes and arrows only.

#formulas(title: "The drawing rules")[
- *Left to right:* user → client → server → data store. Nothing else on the first pass.
- *Label every arrow* with what travels on it, not just an arrowhead.
- *Draw only what exists.* Do not draw a load balancer you never deployed.
- *Mark the slow part* and the *failure point* yourself, before they ask. That single act
  moves you from "student who followed a tutorial" to "engineer who knows his system".
]

#diagram(height: 5.2cm, caption: "The whole system on one line, plus the two things you point at yourself.")[
  #dnode(0cm, 1.1cm, 2.7cm, 1.1cm, "Student phone (browser)")
  #darrow(2.7cm, 1.65cm, 4.7cm, 1.65cm, label: "POST /optin")
  #dnode(4.7cm, 1.1cm, 2.9cm, 1.1cm, "Express API on 1 VM")
  #darrow(7.6cm, 1.65cm, 9.1cm, 1.65cm, label: "SQL")
  #dnode(9.1cm, 1.1cm, 2.5cm, 1.1cm, "PostgreSQL")
  #darrow(11.6cm, 1.65cm, 13.3cm, 1.65cm, label: "counts")
  #dnode(13.3cm, 1.1cm, 2.6cm, 1.1cm, "Cook's screen (read only)")
  #dnode(4.7cm, 3.3cm, 2.9cm, 0.9cm, "9 pm cron job")
  #darrow(6.15cm, 3.3cm, 6.15cm, 2.25cm, label: "freeze")
  #place(dx: 9.1cm, dy: 2.45cm)[#text(size: 7.5pt, fill: rgb("#9b2226"))[slow: report query]]
  #place(dx: 4.7cm, dy: 0.4cm)[#text(size: 7.5pt, fill: rgb("#9b2226"))[single point of failure]]
]

#trick[
Point at your own weak spot while drawing: "this VM is a single point of failure — if it
dies, the cook has no counts, and our fallback was literally the old paper sheet."
Interviewers love this. You have taken their best question and answered it first.
]

#section[The hardest small question: "What did YOU do?"]

Group projects are normal. Pretending you did everything is not. The interviewer has
interviewed your classmates. Claiming all four parts is how you get caught.

#formulas(title: "The ownership structure — four moves")[
+ *Claim narrowly.* Name your modules, not the project.
+ *Credit clearly.* Name what teammates owned.
+ *Show the seam.* Explain one interface between your part and theirs — this proves you
  understood the whole, without claiming the whole.
+ *Offer depth.* "I can go deepest on the API and the schema."
]

#ex(2, tier: 1, asked: "Wipro · pattern")[
"There were three of you. What exactly was your contribution?"
]

#trap[
*WEAK.* "Basically I worked on all parts. Mainly backend but I also know the frontend
code, I helped in deployment also. Whenever anyone was stuck I used to help them, so I can
say I contributed in every module."
]

#sol[
*STRONG.* "I owned the API and the database. Concretely: the schema for the four tables,
the four endpoints under `/optin` and `/counts`, the 9 pm cut-off job, and the weekly
report query.

Ravi owned the front end, Meera owned login and deployment.

The seam between Ravi and me was the response shape from `POST /optin`. We argued about
it — he wanted the whole updated list back so his page could re-render, I wanted just the
new count so the response stayed small. We agreed on returning the count plus a version
number, and he refetched only when the version jumped.

I can go deepest on the API and the schema. I know the front end well enough to read it,
but I did not write it."
]

#table(columns: 2,
  align: (left, left),
  [*What changed*], [*Why it matters*],
  [“All parts” → four named pieces], [Checkable. A checkable claim reads as true.],
  [Teammates named], [Someone who credits others is usually telling the truth.],
  [Added the interface argument], [Proves system understanding without over-claiming.],
  [States the limit of own knowledge], [Sets the depth of follow-ups where you are strong.],
)

#trap[
Never say "I know all of it" about code you did not write. The next question will be
"good — how does the front end store the auth token?" and the silence that follows costs
you more than admitting the boundary would have.
]

#tier-header(0)

Warm-ups. One idea each. Answer in two sentences, out loud, from your own project.

#ex(3, tier: 0, asked: "warm-up")[
"In one sentence, what problem does your project solve?"
]
#sol[
*Structure:* `[who] could not [do what], so [thing] lets them [do it].`

*Filled:* "The mess cook could not know tomorrow's head count, so the app lets students
mark meals in or out before 9 pm."

*Check:* no technology word appears. If you cannot describe the problem without naming a
framework, you do not yet understand the problem.
]

#ex(4, tier: 0, asked: "warm-up")[
"How many users did it have?"
]
#sol[
Give the true number and the true nature of the users. Small and true beats big and vague.

*Filled:* "78 students in one hostel block, for six weeks. Real users, but one block only
— I have never run it above about 80 people."

Never say "it can handle any number of users". You have not tested that, and the next
question will be "what makes you say that?"
]

#ex(5, tier: 0, asked: "warm-up")[
"Why did you choose this database?"
]
#sol[
*Structure:* `[shape of my data / queries] → [the store that fits that shape] → [what I gave up].`

*Filled:* "My main read is a weekly report that joins opt-ins to meals and groups by day,
so I wanted SQL and a real GROUP BY. I gave up schema flexibility — every new field needs
a migration, and I wrote three migrations in six weeks."

The "what I gave up" clause is the part that scores. Every choice costs something. Saying
the cost proves you chose rather than copied.
]

#ex(6, tier: 0, asked: "warm-up")[
"How long did it take, and how did you split the work?"
]
#sol[
*Filled:* "Five weeks of evenings. Week 1 was schema and endpoints, weeks 2–3 were the
front end and the cut-off job in parallel, week 4 was the report, week 5 was fixing the
double-tap bug and the report speed. We split by layer: I had the API, Ravi the UI, Meera
deployment."

Dates and a split make the story checkable. Checkable stories are believed.
]

#tier-header(1)

Standard service-company project questions. Direct, factual, one level deep. Answer these
perfectly and you clear the round at this tier.

#ex(7, tier: 1, asked: "TCS NQT · pattern")[
"Explain the flow when a user does the main action in your app."
]
#sol[
This is the *end-to-end trace*. Walk it like a packet, not like a feature list. Name each
hop and what it checks.

*Structure:* `client event → request → auth → validation → business rule → data write → response → what the UI does next.`

*Filled:*

+ Student taps *Skip dinner* on the phone.
+ The page sends `POST /optin` with the meal id and the choice, plus the session cookie.
+ Express checks the cookie and loads the student id. No cookie, 401.
+ It validates that the meal id exists and belongs to tomorrow.
+ The business rule: if the server clock is past 21:00, reject with 409 and the message
  "counts are frozen for tomorrow".
+ It writes one row into `opt_ins` for `(student_id, meal_id)`.
+ It reads back the fresh count for that meal and returns it as JSON.
+ The page swaps the button label and shows the new count.

*Then volunteer the weak point:* "Step 6 is where our bug lived — I will come back to it
if you want."
]

#trick[
Numbered steps are far easier to follow out loud than a paragraph. Practise counting on
your fingers as you speak. It stops you from skipping a hop, and skipping a hop is what
makes an interviewer suspect you never wrote it.
]

#ex(8, tier: 1, asked: "Capgemini · pattern")[
"Show me your database design. Why these tables?"
]
#sol[
*Structure:* name the tables, name the keys, name the one relationship that carries the
product, then name the one thing you would normalise differently.

*Filled:*

#table(columns: 3,
  align: (left, left, left),
  [*Table*], [*Main columns*], [*Why it exists*],
  [`students`], [`id`, `roll_no`, `block`], [One row per person. `roll_no` is unique.],
  [`meals`], [`id`, `meal_date`, `slot`], [One row per meal. `(meal_date, slot)` unique.],
  [`opt_ins`], [`student_id`, `meal_id`, `choice`, `created_at`], [The join table. One row per decision.],
  [`daily_counts`], [`meal_id`, `count_in`, `frozen_at`], [The frozen 9 pm snapshot the cook reads.],
)

"`opt_ins` is the heart: it is many-to-many between students and meals, with the choice on
the link. The unique key is `(student_id, meal_id)` — that is what should have stopped our
double-row bug, and adding it is exactly how we fixed it.

What I would change: `daily_counts` stores a number I can already compute from `opt_ins`.
That is duplicated state, and duplicated state drifts. I would keep it only as a
deliberate frozen snapshot and rename it `meal_snapshots` so nobody treats it as live
truth."
]

#trap[
*The invented normal form.* Do not say "it is in 3NF" unless you can state what 3NF is and
point at the column that would violate it. A one-word claim you cannot unpack is worse
than no claim.
]

#ex(9, tier: 1, asked: "Accenture · pattern")[
"What was the most difficult part, technically?"
]
#sol[
Pick a *real* difficulty with a *cause you understood*. Difficulty means "I did not know
why it was happening", not "there was a lot of work".

*Structure:* `symptom → what I first believed → how I found the real cause → fix → proof.`

*Filled:*

- *Symptom:* twice in the first week, a meal count was one higher than the number of
  students who had actually opted in.
- *First belief:* I assumed the cook's screen was caching an old value, so I added a
  no-cache header. It happened again.
- *Finding the cause:* I printed every row in `opt_ins` for that meal and saw two rows for
  the same student, `created_at` 380 ms apart. That is a double tap on a slow phone, not a
  cache.
- *Fix:* a unique constraint on `(student_id, meal_id)`, and the insert became an upsert
  so the second tap updates instead of inserting.
- *Proof:* I wrote a small script that fires the same request twice in parallel; before
  the fix it produced two rows, after the fix one.

*Why this scores:* it contains a wrong first guess. Real debugging has wrong guesses.
Stories with no wrong guess sound rehearsed.
]

#ex(10, tier: 1, asked: "Cognizant · pattern")[
"How did you test it?"
]
#sol[
Be honest about the level you actually reached. Every level below is respectable if you
say what it covers and what it misses.

#table(columns: 3,
  align: (left, left, left),
  [*Level*], [*How to say it*], [*What it does not cover*],
  [Manual only],
  [“I tested by hand with a checklist of 11 cases that I kept in the repo.”],
  [Regressions. Nothing re-runs when you change code.],
  [A few unit tests],
  [“9 tests on the cut-off rule and the count query, run with `node --test`.”],
  [The HTTP layer and the database.],
  [API tests],
  [“6 tests that start the app and hit the real endpoints against a test database.”],
  [The browser and real concurrency.],
  [Load / concurrency],
  [“A script that fires 50 parallel opt-ins to check the unique constraint holds.”],
  [Sustained load, real network.],
)

*Filled:* "Honestly, mostly manual with a written checklist. After the double-row bug I
added 9 unit tests around the cut-off rule and a small parallel-request script, because
that was the bug that actually hurt us. I did not have browser tests."

*Never* say "we tested everything". Say the level, say the hole.
]

#ex(11, tier: 1, asked: "Infosys · pattern")[
"How is the application secured?"
]
#sol[
Answer only what you truly did, in layers, and name the gap.

*Filled:*

+ *Authentication:* session cookie, `HttpOnly` and `SameSite=Lax`, signed by the server.
  Passwords hashed with bcrypt, not stored in plain text.
+ *Authorisation:* a student can only write their own opt-in. The student id comes from
  the session, never from the request body — that was a deliberate decision, because if I
  had trusted the body, anyone could opt out for anyone.
+ *Input validation:* meal id must be an integer and must exist. All queries are
  parameterised, so no string concatenation into SQL.
+ *Transport:* HTTPS through the host's certificate.
+ *The gap:* no rate limiting. Someone could hammer the login endpoint. On a hostel app
  with 78 users nobody did, but on a public app that is a real hole and it is the first
  thing I would add.
]

#trick[
Point 2 — *"the id comes from the session, never from the body"* — is a genuine security
idea that most freshers have never thought about. If it is true of your project, say it.
If it is not true of your project, go fix your project tonight; it is usually a two-line
change.
]

#ex(12, tier: 1, asked: "TCS Digital · pattern")[
"Why Node and Express? Why not Java Spring or Django?"
]
#sol[
There is no "correct" answer. There is only a *reasoned* answer plus a *fair* description
of the alternative. Never insult the alternative.

*Structure:* `my constraint → why my pick fits it → what the alternative is genuinely better at → honest admission if the real reason was familiarity.`

*Filled:* "The honest first reason is team familiarity: all three of us already wrote
JavaScript for the front end, and with five weeks of evenings, one language across the
stack saved real time.

The technical reason that held up: our workload is many small, short requests that mostly
wait on the database, and Node's single event loop handles waiting work well without me
managing threads.

Spring would have been better if we needed strong typing, mature transaction management,
and a big team touching the same code — those are real advantages and on a bank-style
project I would expect to lose that argument. Django would have given us an admin panel
almost free, which we hand-built and which took Meera two evenings."
]

#table(columns: 2,
  align: (left, left),
  [*What changed vs the usual answer*], [*Effect*],
  [Admits familiarity as a real reason], [Sounds true, because it is the true reason for most student projects.],
  [Gives one workload-shaped technical reason], [Shows you know what the runtime actually does.],
  [Praises the alternative specifically], [Shows you can lose an argument gracefully — a teamwork signal.],
)

#practice(tier: 1, time: "say each out loud, 90 s each")[
Use *your own* project for every one of these. Write the answer in six lines, then say it
without reading.

+ Describe your project to a non-technical person in 60 seconds. No technology words.
+ Trace your main user action from tap to database and back, in numbered steps.
+ Draw your schema. State the primary key and one foreign key out loud.
+ Name the single slowest thing in your app and say how you know it is slowest.
+ What exactly did you write, and what did each teammate write?
+ How did you test it, and what does your testing *not* cover?
+ Name one thing in your app that is not secure, and how you would fix it.
+ Why that language and framework? Name one thing the alternative does better.
]

#key[
There is no fixed answer key here — the answers are yours. Grade yourself against this
checklist, one mark each, out of 8:
(1) no buzzword without evidence; (2) at least one real number; (3) at least one named
alternative you rejected; (4) at least one honest limitation stated by you before being
asked; (5) modules claimed narrowly; (6) no sentence longer than about 20 words;
(7) you stopped talking within 100 seconds; (8) nothing you said was untrue.
Below 6 out of 8, redo it before moving to Tier 2.
]

#tier-header(2)

Regional and business-flavoured questions. The interviewer is a working engineer or a
manager in Singapore, Bangkok or Jakarta. They care about scale, money and users, not
about definitions.

#ex(13, tier: 2, asked: "Grab · pattern")[
"Suppose this app went from 78 users to 78,000. What breaks first?"
]
#sol[
They are not asking you to design a distributed system. They are asking: *do you know
where your own system's limits are?* Answer in order of what breaks first, with a reason.

*Structure:* `find the biggest cost per user → multiply → name the first thing to hit a wall → say the cheapest fix → then the next wall.`

*Filled:*

+ *First wall: the report query.* It scans `opt_ins` for a date range. At 78 users and six
  weeks that is about 6{,}500 rows. At 78{,}000 users it is about 6.5 million rows per six
  weeks. Even indexed, that is a heavy scan on a 1 GB VM, and the cook's page would time
  out. *Cheapest fix:* keep a rolled-up daily count table written once at 9 pm, and have
  the report read the roll-up, not the raw rows.

+ *Second wall: the 9 pm spike.* Everyone opts in just before the cut-off, so traffic is
  not flat — it is a spike in the last ten minutes. With 78 users that is nothing; with
  78{,}000 it is maybe 300–800 writes per second for ten minutes, on one VM with one
  Postgres. *Fix:* more than one app process behind a load balancer, and move the cut-off
  to a per-hostel time so the spikes do not overlap.

+ *Third wall: the single VM.* One machine means one reboot equals a full outage. *Fix:*
  two app instances, and the database on its own managed instance with backups.

*What I would measure first:* I would not guess. I would load test the opt-in endpoint and
the report separately and find which one falls over at the lower number.
]

#trick[
The phrase *"what I would measure first"* is worth a lot at Tier 2 and Tier 3. Guessing
the bottleneck confidently is a junior habit. Naming the measurement is a senior habit,
and it costs you one sentence.
]

#ex(14, tier: 2, asked: "Shopee · pattern")[
"What was the business value? How would you know if it worked?"
]
#sol[
Engineers at this tier are asked to justify work in outcome terms. Practise the
translation from feature to money or time.

*Structure:* `who benefits → the metric that would move → the baseline → what we actually saw → what I could not prove.`

*Filled:* "The person who benefits is the cook, and the metric is food thrown away per
meal.

Baseline: before the app, the mess recorded leftovers roughly, about 12–15 plates a night
by the cook's own estimate.

What we saw in six weeks: the cook's estimate dropped to about 5 plates on the nights when
more than half the block used the app.

What I cannot prove: we had no proper measurement before and after, the cook's numbers
were eyeballed, and there was a holiday week in the middle. So I would call it a promising
signal, not a proven result. If I ran it again I would weigh the leftovers for two weeks
before launching anything."
]

#table(columns: 2,
  align: (left, left),
  [*Move*], [*Why it scores at Tier 2*],
  [Names one metric, not five], [Focus. Managers distrust five-metric answers.],
  [Gives a baseline], [Without a baseline a number means nothing.],
  [States what the evidence cannot prove], [Intellectual honesty is a hiring signal here.],
  [Says what you would measure next time], [Shows you learned the method, not just the result.],
)

#ex(15, tier: 2, asked: "Agoda · pattern")[
"What would this cost to run per month, and how would you reduce it?"
]
#sol[
Most freshers have never thought about cost. Thinking about it at all puts you ahead.

*Structure:* `list what you pay for → put a rough number on each → find the biggest → name one lever.`

*Filled:* "Today it is one small VM and a domain — roughly 8–10 US dollars a month, and
the database runs on the same VM, which is why it is cheap and also why it is fragile.

If I moved the database to a managed instance with backups, that alone would be the
biggest line, likely more than the app server.

The cheapest real lever is the report: it is the only heavy query, it is read by one
person once a day, and it is the reason I would otherwise need a bigger machine.
Pre-computing it at 9 pm turns a heavy query into a tiny read, and that keeps me on the
small instance. So the cost lever and the performance fix are the same change."
]

#note[
You are not expected to quote exact cloud prices. You are expected to know *what* costs
money — compute time, storage, data transfer, managed services — and which of your
components is the expensive one. Ranges are fine. Say "roughly" and mean it.
]

#ex(16, tier: 2, asked: "DBS · pattern")[
"Your report showed a wrong number to the cook for two days. Walk me through how you
handled it."
]
#sol[
This is a *behavioural* question wearing a project costume. Use STAR, and label the parts
in your head. Here they are labelled on the page so you can see the shape.

*S — Situation.* "In week two, two meal counts on the cook's screen were one higher than
the true number of opt-ins. The cook had already ordered food based on them."

*T — Task.* "I owned the API and the counts, so it was mine to find and fix. Two things
mattered: tell the cook before he trusted a third wrong number, and find the real cause
rather than patching the display."

*A — Action.* "First I told the cook the same evening and asked him to use the paper sheet
for one more night — that cost us credibility but it was the honest move. Then I dumped
the raw `opt_ins` rows for those meals and found duplicate rows for one student, 380 ms
apart, which pointed at a double tap and not a caching problem as I had first assumed. I
added a unique constraint on `(student_id, meal_id)`, changed the insert to an upsert, and
wrote a script that fires two parallel requests to prove the second one no longer creates
a row. Finally I recomputed the two bad days from the raw rows and showed the cook the
corrected figures."

*R — Result.* "No count mismatch in the remaining four weeks, and the parallel script is
still in the repo as a regression check. The lesson I actually carry: I spent an evening
on my first theory because it was convenient, not because I had evidence. Now I look at
the raw data before I form a theory."

*This is my example, from a project I invented for this book. Yours must be a real thing
that really went wrong in your project.* If nothing ever went wrong in your project, you
either did not use it with real people or you are not remembering hard enough.
]

#trap[
*The blameless-to-the-point-of-blame-shifting trap.* "The cook misread the screen" or "the
front end sent it twice" both move the fault away from you. Even when partly true, they
read as excuses. Own the part that was yours: the server accepted two rows it should have
rejected. Servers must not trust clients. That is your fault line, and saying so is
stronger than being right about the phone.
]

#practice(tier: 2, time: "5 min each, written")[
For *your own* project:

+ At 1000× your current users, what breaks first? Give the number you used to decide.
+ What is the business or human value, what is the baseline, and what can you *not* prove?
+ What does your project cost to run, and what is the single biggest lever?
+ Tell, in STAR form with the four parts labelled, one time your project produced a wrong
  result for a real user.
+ Which one component, if it died at 3 a.m., takes the whole app down?
]

#key[
Self-grade. Full marks need: (1) an actual arithmetic step, not just "it would be slow";
(2) one named metric with a baseline; (3) a cost driver named, not a price quoted;
(4) all four STAR parts present, with the R containing a lesson stated as a changed
behaviour; (5) a single named component, plus what the fallback was.
]

#tier-header(3)

Deep probing. At this tier the first answer is never the end. Expect three to five
follow-ups on one thread until you reach the edge of what you know. *Reaching that edge is
normal and expected.* How you behave at the edge is what is being scored.

#subsection[The follow-up ladder]

#diagram(height: 6.4cm, caption: "One answer, four levels of probe. Most candidates have material for level 1 only.")[
  #dnode(0cm, 0cm, 5.4cm, 0.85cm, "L0  \"Why Postgres?\"")
  #darrow(2.7cm, 0.85cm, 2.7cm, 1.45cm)
  #dnode(0cm, 1.45cm, 5.4cm, 0.85cm, "L1  \"Because the report needs a join\"")
  #darrow(5.4cm, 1.87cm, 6.6cm, 1.87cm)
  #dnode(6.6cm, 1.45cm, 6.0cm, 0.85cm, "L2  \"Which join? Show the query.\"")
  #darrow(9.6cm, 2.3cm, 9.6cm, 2.95cm)
  #dnode(6.6cm, 2.95cm, 6.0cm, 0.85cm, "L3  \"Why was it slow at 6 weeks?\"")
  #darrow(9.6cm, 3.8cm, 9.6cm, 4.45cm)
  #dnode(6.6cm, 4.45cm, 6.0cm, 0.85cm, "L4  \"Why did the index help?\"")
  #darrow(6.6cm, 4.87cm, 5.2cm, 4.87cm, label: "edge")
  #dnode(0cm, 4.45cm, 5.0cm, 0.85cm, "\"Here is what I know and do not know\"", fill: rgb("#fdf4f4"))
]

#ex(17, tier: 3, asked: "Amazon · pattern")[
The ladder, played out. Four probes on one choice.
]
#sol[
*Probe 1 — "Why Postgres and not MongoDB?"*

"My heaviest read is the weekly report: for each day, count opt-ins joined to meals and
grouped by slot. That is a relational shape. In Mongo I would either denormalise and keep
counts on the meal document, or use an aggregation pipeline — both are possible, but I
would be re-implementing a join by hand and I preferred to let the database do it. I also
wanted a unique constraint across two columns, which is exactly what stopped my duplicate
bug."

*Probe 2 — "Show me that query."*

"Roughly:

`SELECT m.meal_date, m.slot, COUNT(*) FROM opt_ins o JOIN meals m ON m.id = o.meal_id
WHERE m.meal_date BETWEEN $1 AND $2 AND o.choice = 'in' GROUP BY m.meal_date, m.slot;`

I am writing it from memory so the exact syntax may be off by a comma, but that is the
shape: filter by date range, join, group by day and slot."

*Probe 3 — "Why did it take 4.1 seconds at only six weeks of data?"*

"Because there was no index that matched the filter. The filter is on `meals.meal_date`,
so Postgres scanned `meals` fully and then, for each matching meal, scanned `opt_ins` to
find its rows. `opt_ins` had no index on `meal_id` at all — only the primary key. So the
work was roughly `rows_in_opt_ins × matching_meals`, not `matching rows`. Small tables,
bad plan."

*Probe 4 — "Why did adding the index fix it? What does the index actually do?"*

"A B-tree index on `opt_ins(meal_id)` keeps the meal ids in sorted order with pointers to
the rows. So instead of reading every row to find the ones for meal 412, the database
walks down the sorted structure — a few steps instead of a full pass — and then follows
the pointers. That turns the per-meal lookup from work proportional to the whole table
into work proportional to a logarithm of it, plus the rows actually returned.

*Here is the edge of what I verified:* I confirmed the improvement with `EXPLAIN ANALYZE`
before and after and saw the plan change from a sequential scan to an index scan. I have
not studied Postgres's planner cost model, so I could not tell you why it chose one join
strategy over another. That is on my list."
]

#trick[
Notice the two protective phrases used above, and steal both:
- *"I am writing it from memory so the syntax may be off"* — buys accuracy forgiveness
  without weakening the idea.
- *"Here is the edge of what I verified"* — turns "I don't know" into a boundary you drew
  deliberately, which reads as self-awareness rather than a gap.
]

#ex(18, tier: 3, asked: "Google · pattern")[
"What would you do differently if you rebuilt it today?"
]
#sol[
The common failure is answering with *features*. They asked an engineering question.

#table(columns: 2,
  align: (left, left),
  [*Weak kind of answer*], [*Strong kind of answer*],
  [“Add a mobile app.”], [“Make writes idempotent with a client-supplied key.”],
  [“Add payment integration.”], [“Remove the duplicated count and keep one source of truth.”],
  [“Improve the UI.”], [“Add structured logs so I can debug without SSH-ing into the VM.”],
  [“Use microservices.”], [“Write the load test first so I know the limit before users find it.”],
)

*Filled, three items, in priority order:*

+ *Idempotency done properly.* The unique constraint fixed duplicate rows, but the client
  still has no way to retry safely after a network timeout — it cannot tell "my request
  never arrived" from "it arrived and the reply was lost". I would have the client send a
  request key, store it server-side, and return the stored reply on a repeat. That is the
  general fix; the constraint was the specific patch.

+ *One source of truth for counts.* `daily_counts` duplicates what `opt_ins` already
  knows. Two places holding the same fact will eventually disagree. I would keep it only
  as an explicitly frozen snapshot with a `frozen_at` timestamp, and make every live read
  go to `opt_ins`.

+ *Observability before features.* When the count was wrong I had no logs, so I debugged
  by printing rows by hand. One structured log line per write, with the student id and the
  request key, would have shown me the duplicate in a minute instead of an evening.

*What I would not change:* the stack. It was right for the problem and the team.
]

#trap[
*The microservices trap.* "I would split it into microservices" on a project with 78 users
is an instant negative signal at Tier 3. It says you are repeating something you read. If
you do want to talk about splitting a system, you must first name the scaling pain that
justifies it — independent deployment, separate scaling needs, or team boundaries — and
your hostel app has none of those.
]

#ex(19, tier: 3, asked: "Microsoft · pattern")[
"You said the fix was a unique constraint. What happens to the user experience when that
constraint fires?"
]
#sol[
This probe checks whether your fix was reasoned or copied. A constraint that fires throws
a database error — what did you *do* with that error?

*Filled:* "Two cases, and they need different behaviour.

*Case A — the same choice twice* (the double tap). The second request should look
successful to the user, because their intent is already recorded. So I made the write an
upsert: `INSERT ... ON CONFLICT (student_id, meal_id) DO UPDATE SET choice = EXCLUDED.choice`.
The user sees success, and there is one row.

*Case B — a changed choice* (opted in at 6 pm, opts out at 7 pm). The same upsert handles
it: the row updates. That is correct and it is why I chose upsert over 'ignore the
conflict'.

*The case I got wrong at first:* I initially used `DO NOTHING`, which made Case A correct
and Case B silently broken — the student saw 'saved' and the choice had not changed. I
found it because Ravi tested exactly that path on the UI. So the honest version is that
the constraint alone was not the fix; the constraint plus the right conflict action was."
]

#trick[
An answer that contains *"the case I got wrong at first"* is nearly impossible to fake and
very strong to hear. Hunt through your project for these moments. Every real project has
them; students forget them because they only remember the final working state.
]

#ex(20, tier: 3, asked: "Amazon · pattern")[
"Tell me about a technical disagreement on this project and how it ended."
]
#sol[
STAR, four parts labelled. The scoring is on *how you handled disagreeing*, not on whether
you were right. Answers where you were right and everyone agreed score badly.

*S — Situation.* "Ravi, who owned the front end, wanted `POST /optin` to return the whole
updated list of meals so his page could re-render in one go. I wanted it to return only
the new count for the meal that changed."

*T — Task.* "We were two days from the demo and the endpoint was blocking his screen, so
this had to be settled that evening, and it had to be settled in a way he would actually
build on."

*A — Action.* "I asked him what problem the full list solved for him, and the real answer
was that his page drifted out of date when two devices belonged to the same student. That
is a genuine problem, and my small response did not solve it. So I stopped arguing about
payload size and proposed the thing that solved his problem cheaply: return the count plus
a version number for the day, and let him refetch the full list only when the version
jumped. I wrote the version column that night; he wired the refetch."

*R — Result.* "It shipped in time, his stale-screen bug disappeared, and the response
stayed around 40 bytes instead of a few kilobytes. What I took from it: I had been arguing
against his *solution* for two days without asking what his *problem* was. Now I ask that
first — it also saved an argument about the report format later."

*Substitute your own disagreement.* If you genuinely never disagreed with anyone, that is
itself worth examining: it usually means one person made all the decisions, and you should
be ready to say which one of you that was.
]

#ex(21, tier: 3, asked: "Goldman Sachs · pattern")[
"How do you know your data is correct? Convince me."
]
#sol[
A correctness question. The expected move is to name your *invariants* — statements that
must always be true — and say how each one is enforced.

*Filled:*

#table(columns: 3,
  align: (left, left, left),
  [*Invariant*], [*Enforced by*], [*Honest status*],
  [One opt-in row per student per meal], [Unique key `(student_id, meal_id)`], [Enforced by the database, not by code. Solid.],
  [No writes after 21:00 for tomorrow], [A time check in the handler], [*Weak.* Code-level only. A direct SQL write bypasses it.],
  [A frozen count never changes], [`frozen_at` set once by the cron job], [Weak — nothing stops an update. Should be a trigger or a read-only view.],
  [Every opt-in points to a real meal], [Foreign key `opt_ins.meal_id → meals.id`], [Enforced by the database. Solid.],
)

"So two of my four invariants are enforced where they cannot be bypassed, and two live in
application code, which means a second writer — a script, a future service, me at 2 a.m.
with `psql` open — could break them. If this handled money instead of dinner, all four
would need to be in the database."
]

#trick[
The sentence *"if this handled money instead of dinner"* shows you can scale your standard
of rigour to the stakes. That is exactly the judgement a bank or a payments team is
listening for.
]

#ex(22, tier: 3, asked: "Uber · pattern")[
"Your cron job runs at 9 pm. What happens if it does not run?"
]
#sol[
Failure-mode probing. Answer as a list of failure modes, each with detection and recovery.
This is the single most common Tier-3 project probe and most candidates have never thought
about it for one second.

*Filled:*

#table(columns: 4,
  align: (left, left, left, left),
  [*Failure*], [*Effect*], [*Detected by*], [*Recovery*],
  [VM was down at 21:00], [No snapshot. Cook's page empty.], [Nothing, in my version. That is the real answer.], [Run it by hand the next morning — the raw rows are still there.],
  [Job ran twice], [Snapshot written twice], [Nothing], [Harmless *only because* the write is an upsert keyed on `meal_id`. That was luck at first, then deliberate.],
  [Job ran but the query failed], [Stale snapshot from yesterday shown as today], [Nothing — worst case, because it looks correct], [Add `frozen_at` to the cook's screen so a stale date is visible.],
  [Clock/timezone wrong on the VM], [Cut-off fires at the wrong hour], [Students complain], [Store times in UTC, convert at the edge. We did not, and it bit us during a server move.],
)

"The honest summary: my design has no detection at all. The cheapest real improvement is a
*heartbeat* — the job writes a row with a timestamp when it completes, and the cook's page
shows a warning if the newest heartbeat is older than today. That is about ten lines and
it converts a silent failure into a visible one. Silent failures are the ones that cost
you."
]

#ex(23, tier: 3, asked: "Adobe · pattern")[
"If I gave you two weeks and one engineer, what would you build next — and why not the
other things?"
]
#sol[
A prioritisation probe. The structure is: *pick one, justify by cost and risk, and
explicitly reject the alternatives.* Rejecting alternatives out loud is the part that
scores.

*Filled:* "I would spend the two weeks on the idempotent write plus the heartbeat, in that
order.

*Why those:* both are silent-failure classes. A wrong count damages trust in the whole
system, and once the cook stops trusting it he goes back to paper and the project is dead
regardless of features. They are also small — I would estimate three days for idempotency
with tests, two for the heartbeat, leaving room for the load test.

*What I would not build, and why:*
- *A mobile app.* The web page already works on phones. It would consume the whole two
  weeks and change nothing about trust.
- *Multi-hostel support.* Real demand, but it needs the report roll-up first or it makes
  the slow query slower. Wrong order.
- *Notifications.* Cheap and tempting, but they would remind students to use a system that
  sometimes shows the wrong count. Fix truth before you increase traffic to it.

*What would change my mind:* if the cook told me the count was fine and the real problem
was that students forget to fill it in, then notifications become first and idempotency
waits. I would ask him before starting."
]

#trick[
End a prioritisation answer with *"what would change my mind"*. It proves your priority is
an argument from evidence, not a preference — and it is the single line that most often
turns a good Tier-3 answer into a strong one.
]

#section[Code you must be able to explain]

You do not need to recite your whole repository. You need to be able to reproduce, on
paper, the three or four *ideas* in your code. Here are the three that carry most student
projects. Run them, change them, break them.

#subsection[Idea 1 — the N+1 query]

This is the most common real performance bug in a student project, and one of the most
common "what would you change" answers.

#code(lang: "js", caption: "N+1 versus one batched fetch — counting database calls")[
```js
const orders = [
  { id: 1, userId: 10 }, { id: 2, userId: 11 },
  { id: 3, userId: 10 }, { id: 4, userId: 12 },
];
const userTable = new Map([[10, "Asha"], [11, "Bilal"], [12, "Chen"]]);

let dbCalls = 0;
function findUser(id) { dbCalls++; return userTable.get(id); }
function findUsersIn(ids) { dbCalls++; return new Map(ids.map(i => [i, userTable.get(i)])); }

// SLOW: one query for the list + one query per row
dbCalls = 1;                                  // the query that fetched orders
const slow = orders.map(o => ({ ...o, name: findUser(o.userId) }));
console.log("N+1 version  -> db calls:", dbCalls);

// FAST: one query for the list + ONE query for all users
dbCalls = 1;
const ids = [...new Set(orders.map(o => o.userId))];
const users = findUsersIn(ids);
const fast = orders.map(o => ({ ...o, name: users.get(o.userId) }));
console.log("batched version -> db calls:", dbCalls);
console.log("same result? ", JSON.stringify(slow) === JSON.stringify(fast));
```
]

#code(lang: "text", caption: "Output of `node s1.js`")[
```text
N+1 version  -> db calls: 5
batched version -> db calls: 2
same result?  true
```
]

*How to say it in the room:* "For a page showing 4 orders I made 5 database calls — one for
the list and one per row. With 200 orders it is 201 calls. I collected the ids first and
fetched all the users in one query, so it became 2 calls regardless of list length. Same
output, constant number of round trips."

#trap[
`[...new Set(ids)]` matters. Without the `Set`, user 10 is fetched twice. Interviewers do
notice the deduplication, and it is a free point.
]

#subsection[Idea 2 — why offset pagination is wrong]

If your project has a "load more" button or a paged list, expect this question.

#code(lang: "js", caption: "Offset pagination repeats a row when data arrives between requests")[
```js
let rows = ["r1","r2","r3","r4","r5","r6"];       // newest first
const page = (n, size) => rows.slice(n*size, n*size+size);

const shown0 = page(0, 2);
console.log("offset page 0:", shown0);
rows = ["NEW", ...rows];                          // a new row arrives
console.log("offset page 1:", page(1, 2), "<- r2 is shown TWICE");

// Cursor pagination: remember the last id you saw, not a page number.
let data = ["r1","r2","r3","r4","r5","r6"];
function after(cursor, size) {
  const i = cursor === null ? 0 : data.indexOf(cursor) + 1;
  return data.slice(i, i + size);
}
const p0 = after(null, 2);
console.log("cursor page 0:", p0);
data = ["NEW", ...data];
console.log("cursor page 1:", after(p0[p0.length-1], 2), "<- no repeat, no skip");
```
]

#code(lang: "text", caption: "Output of `node s2.js`")[
```text
offset page 0: [ 'r1', 'r2' ]
offset page 1: [ 'r2', 'r3' ] <- r2 is shown TWICE
cursor page 0: [ 'r1', 'r2' ]
cursor page 1: [ 'r3', 'r4' ] <- no repeat, no skip
```
]

*How to say it:* "`OFFSET 2` means 'skip two rows *as the table looks right now*'. If a row
was inserted at the top between page 0 and page 1, everything shifted down by one, so the
user sees `r2` twice. If a row was deleted, they miss one. A cursor says 'give me what
comes after the row I actually last saw', which does not move. The cost is that you can no
longer jump to page 7."

#note[
Also name the cost, every time. Cursor pagination cannot jump to an arbitrary page number,
and it needs a stable sort key. An answer that names only the benefit sounds like a
memorised line.
]

#subsection[Idea 3 — idempotency]

#code(lang: "js", caption: "The same request twice must not charge twice")[
```js
const charges = [];
const seen = new Map();                 // key -> the reply we already sent

function chargeNaive(userId, amount) {
  charges.push({ userId, amount });
  return { ok: true, total: charges.length };
}
function chargeIdempotent(key, userId, amount) {
  if (seen.has(key)) return seen.get(key);      // replay the old reply
  charges.push({ userId, amount });
  const reply = { ok: true, total: charges.length };
  seen.set(key, reply);
  return reply;
}

chargeNaive(7, 500); chargeNaive(7, 500);       // user tapped Pay twice
console.log("naive  -> charges stored:", charges.length);

charges.length = 0;
chargeIdempotent("req-abc", 7, 500);
chargeIdempotent("req-abc", 7, 500);
console.log("idempotent -> charges stored:", charges.length);
```
]

#code(lang: "text", caption: "Output of `node s3.js`")[
```text
naive  -> charges stored: 2
idempotent -> charges stored: 1
```
]

*How to say it:* "The client generates a key once per user intent and sends it with the
request. If the network times out, the client retries with the *same* key. The server
stores the key with the reply it sent, so a repeat returns the stored reply instead of
doing the work again. The key point is that the key comes from the client — the server
cannot tell a retry from a genuine second purchase on its own."

#trap[
In this teaching version `seen` is a `Map` in memory, so it is lost on restart and not
shared between two servers. Say that yourself before you are asked. In a real system the
key goes in the database or a shared cache with an expiry, and the check plus the write
must be in one transaction or one atomic operation — otherwise two parallel retries can
both pass the `has` check.
]

#section[The "I don't know" protocol]

You *will* be pushed past what you know. That is the design of the round. What matters is
the shape of your reply.

#formulas(title: "Four moves when you hit the edge")[
+ *Say it plainly.* "I do not know that." Two seconds. No apology tour.
+ *Give the nearest true thing.* "What I do know is…" — the adjacent fact you are sure of.
+ *Reason out loud, labelled as reasoning.* "If I had to guess, and this is a guess…"
+ *Close the loop.* "How would you approach it?" or "I will read about it tonight" — and
  if you say that, mean it.
]

#ex(24, tier: 3, asked: "Google · pattern")[
"How does Postgres decide between a hash join and a nested loop join here?"
]
#trap[
*WEAK.* "It depends on the optimiser. Basically the optimiser is very intelligent, it uses
statistics and cost-based optimisation, and it automatically chooses the best plan for
performance." — This is empty. It reuses the words in the question and adds nothing. The
interviewer now suspects every earlier answer.
]
#sol[
*STRONG.* "I do not know the planner's cost model, so I cannot tell you how it decides.

What I do know from my own project: I ran `EXPLAIN ANALYZE` before and after adding my
index, and the plan changed from a sequential scan to an index scan, and the measured time
went from 4.1 seconds to 0.2.

If I had to guess — and this is a guess — a nested loop makes sense when one side is tiny
and the other is indexed, because you look up a few rows; a hash join makes sense when
both sides are large and unindexed, because you pay once to build a hash table instead of
scanning repeatedly. I have not verified that.

Is the planner something you use day to day on your team?"
]

#table(columns: 2,
  align: (left, left),
  [*What changed*], [*Effect*],
  [Admits the gap in the first sentence], [Removes all suspicion of bluffing.],
  [Supplies an adjacent verified fact], [Proves the gap is a boundary, not emptiness.],
  [Labels the guess as a guess], [You may now reason freely without risk.],
  [Ends with a real question], [Turns a dead end into a conversation.],
)

#trap[
*Never* answer a question you did not understand. Ask for it again: "Do you mean how the
database chooses, or how I would choose?" Answering the wrong question confidently is
scored the same as bluffing.
]

#section[When your project feels too small]

Many students think "my project is just a CRUD app / a clone / a college mini project, so
I will lose". You will not lose for that. You lose for not knowing your own small project.

#formulas(title: "How to defend a small or tutorial-derived project — honestly")[
*Say what it is.* "I built this by following a tutorial series, and then I changed three
things." — This is fine, and it is true for most people's first project. Hiding it is what
hurts.

*Then earn the round on the changes.* The three changes are now your project. Know them at
four levels of depth: what, why, what broke, what you would do differently.

*Add one thing the tutorial did not have.* One index with a measured before and after. One
test file. One deliberate constraint. One rate limit. One log line. Any of these gives you
a number and a decision that are genuinely yours.

*Never inflate.* Do not turn a to-do app into "an enterprise task management platform". An
interviewer who has seen a thousand resumes will ask one question and the inflation will
collapse.
]

#ex(25, tier: 1, asked: "Accenture · pattern")[
"This looks like a standard to-do application. What is special about it?"
]
#trap[
*WEAK.* "Sir, it is not a normal to-do app, it is a complete task management system with
many advanced features like priority, categories, reminders, and it is fully scalable and
production ready."
]
#sol[
*STRONG.* "Honestly, the core is a standard to-do app — I built it from a tutorial to
learn Express. Nothing special there.

Two things in it are mine. First, I added recurring tasks, and that turned out to be
harder than I expected: I first stored 365 rows for a daily task, which made the list
query slow and made editing the series impossible. I changed it to store one rule row plus
an exceptions table and generate the occurrences on read.

Second, I added a soft delete, because a friend testing it deleted a list by accident. So
a delete sets `deleted_at`, and every query filters on it — which then caused a bug where
a deleted task still blocked a unique title, and I had to make the unique index partial.

So the app is ordinary. The recurrence model and the soft-delete interaction with the
unique index are the two things I actually learned from, and I can go as deep as you like
on either."
]

#table(columns: 2,
  align: (left, left),
  [*What changed*], [*Effect*],
  [Admits the tutorial origin first], [Removes the interviewer's main suspicion immediately.],
  [Narrows the claim to two changes], [Two defensible things beat six inflated ones.],
  [Each change has a failure and a redesign], [This is engineering, and it is not fakeable.],
  [Ends by inviting depth], [Signals confidence in the narrow claim.],
)

#section[Every resume line is a question]

Before an interview, take your own resume and write the question each line invites. If a
line invites a question you cannot answer, either learn the answer or delete the line.

#table(columns: 2,
  align: (left, left),
  [*Your resume line*], [*The question it guarantees*],
  [“Built a REST API using Node.js and Express”], [“What makes it REST? Which verb did you use for the update, and why?”],
  [“Implemented JWT authentication”], [“Where is the token stored, and what happens when it is stolen?”],
  [“Optimised database queries”], [“Which query, from what to what, measured how?”],
  [“Deployed on AWS”], [“Which service, and what happens when the instance restarts?”],
  [“Used Redis for caching”], [“What is the expiry, and what happens on a cache miss during a spike?”],
  [“Worked with a team of 4 using Agile”], [“What was your sprint length and what did you do in a stand-up?”],
  [“Integrated payment gateway”], [“What happens if the user's payment succeeds and your server crashes before saving?”],
  [“Improved performance by 40%”], [“40% of what, measured with what tool, on what data size?”],
  [“Machine learning model with 95% accuracy”], [“95% on what split? What was the class balance? What is the baseline?”],
)

#trap[
*The percentage with no origin.* "Improved performance by 40%" is the single most
questioned line on fresher resumes. If you did not measure it, remove it. If you did,
memorise the before number, the after number, the tool, and the input size. Three of those
four are usually missing and the interviewer notices instantly.
]

#ex(26, tier: 1, asked: "Infosys · pattern")[
"Your resume says you implemented JWT authentication. Walk me through it."
]
#sol[
*Structure:* `what the token contains → who signs it → where the client keeps it → how the server checks it → what breaks and what you did about it.`

*Filled:* "On login the server checks the password hash, then creates a token whose payload
has the user id, a role, and an expiry — 24 hours in my case. The server signs it with a
secret from an environment variable, so a client cannot forge one.

The browser stores it — and this is the part I got wrong first. I originally kept it in
`localStorage` because every tutorial does. That means any script on my page can read it,
so one cross-site scripting hole gives away the token. I moved it to an `HttpOnly` cookie
so JavaScript cannot read it, which meant I then had to think about cross-site request
forgery and set `SameSite`.

On each request, middleware verifies the signature and the expiry, and puts the user id on
the request object. The handlers never read the id from the body.

*The honest limitation:* my tokens cannot be revoked. If a token is stolen it is valid
until it expires, because I have no server-side list of valid or blocked tokens. The usual
fix is short-lived access tokens plus a refresh token you can revoke, and I have read about
it but not built it."
]

#trick[
Notice the pattern that runs through this whole chapter: *state the thing, state the thing
you got wrong, state the limitation that remains.* Three beats. It is the most convincing
structure available to a student, because nobody who copied a tutorial has the middle beat.
]

#section[Internship projects: the extra questions]

If your project was an internship, two new questions appear that never come up for a
college project.

#formulas(title: "What is different about defending internship work")[
*You must separate your work from the team's* even more carefully. In college nobody
checks. In industry the interviewer may know someone at that company.

*You must respect confidentiality without hiding behind it.* "I cannot discuss that" for
every question is useless. Describe the *shape* of the problem and your *technical
decisions* without naming customers, internal systems or numbers you were told to protect.

*You will be asked about process*, not just code: how work reached you, how it was
reviewed, how it was released.
]

#ex(27, tier: 1, asked: "Accenture · pattern")[
"What was your day-to-day work in the internship, and what did you actually ship?"
]
#trap[
*WEAK.* "I was in the backend team. I learned a lot about how industry projects work. I
did bug fixes and small tasks given by my mentor and attended daily stand-ups. It was a
great learning experience and I got exposure to real-world codebases."
]
#sol[
*STRONG.* "I was on a four-person team that owned a reporting service. My work came as
tickets from my mentor, and I shipped three things in five months.

The largest was a retry for a nightly export that failed when the downstream system was
slow. I added a bounded retry with a growing wait between attempts, and a dead-letter
table so a permanently failing job stopped being retried forever instead of looping.

The smallest was a one-line fix to a timezone bug that made one report a day late for one
region — that one taught me the most, because finding it took two days and the fix took
two minutes.

Process: everything went through a pull request with one required review. I could not
merge my own code. Releases were twice a week, and I watched two of them.

I cannot share the customer names or the volume figures, but the technical shape I have
just described is all mine."
]

#table(columns: 2,
  align: (left, left),
  [*What changed*], [*Effect*],
  [“Bug fixes and small tasks” → three named deliveries], [Countable work. Countable work is believable work.],
  [Adds the retry design in one sentence], [A real engineering decision, not a task list.],
  [Includes the trivial fix that took two days], [Honest, memorable, and shows debugging.],
  [Describes the review and release process], [Proves you worked in a team, not beside one.],
  [Confidentiality handled in one clause], [Respectful without hiding.],
)

#section[The extension question]

At Tier 2 and Tier 3 you will often be asked to *extend your own project live*. This is a
small system-design question with a huge advantage: you already know the system.

#formulas(title: "How to answer any extension question — five moves")[
+ *Clarify the requirement.* Two questions, maximum. Who uses it, and how often?
+ *State the data change first.* New table, new column, or new relationship.
+ *State the write path*, then the read path.
+ *Name the hard case.* Concurrency, failure, or an edge in the existing data.
+ *Give a smaller version* you could ship this week.

The fifth move is what most candidates skip, and it is the one that shows engineering
judgement rather than ambition.
]

#ex(28, tier: 2, asked: "Grab · pattern")[
"Add guest meals to your app: a student can bring up to two guests, and the cook needs the
guest count separately."
]
#sol[
*Clarify:* "Two questions. Does a guest need to be identified, or is a count enough? And
can a guest be added after the 9 pm cut-off?" — Assume: a count is enough, and the cut-off
applies equally.

*Data change:* "A column `guest_count` on `opt_ins`, default 0, with a check constraint
`guest_count BETWEEN 0 AND 2`. I would not create a `guests` table, because there is no
guest entity — there is no name, no identity, nothing to join to. A column on the existing
row is the honest model."

*Write path:* "`POST /optin` takes an optional `guests` field. The same cut-off check
applies. The upsert sets both `choice` and `guest_count`, so a second tap changing the
guest count updates rather than inserting — the existing unique key already handles this."

*Read path:* "The count query changes from `COUNT(*)` to
`COUNT(*) + COALESCE(SUM(guest_count), 0)` for the total plates, and I would return both
numbers, not one. The cook needs to know the guest share because guests often skip, and a
single merged number hides that."

*Hard case:* "The existing rows. Every row already in `opt_ins` has no guest count, so the
column needs a default of 0 and a backfill — otherwise `SUM` returns null for old dates and
my report shows null instead of a number. That is exactly the kind of quiet break that
would show up in the weekly report only."

*Smaller version I could ship this week:* "The column with the default, the API field, and
the two-number report. I would leave out any per-guest rules, and I would not add a guests
table unless someone later needs guest names for billing."
]

#trick[
"I would not create a table, because there is no entity" is a sentence worth owning. The
instinct to create a table for every noun in the requirement is the most common modelling
mistake. Ask: *does this thing have an identity and a life of its own?* A guest count does
not. A guest with a name, a phone number and a history does.
]

#ex(29, tier: 3, asked: "Amazon · pattern")[
"Now make it work for 40 hostels across the campus, each with its own cook and its own
cut-off time. What changes?"
]
#sol[
*Clarify:* "Do cooks ever need to see another hostel's numbers, and does a student ever eat
in a different hostel?" — Assume: cooks see only their own, and yes, students occasionally
eat elsewhere, which turns out to be the interesting part.

*Data change:*
- A `hostels` table with `id`, `name`, `cutoff_time`, `timezone`.
- `students.hostel_id` — their home hostel.
- `meals.hostel_id` — a meal now belongs to a hostel, so `(hostel_id, meal_date, slot)`
  becomes the unique key.
- `opt_ins` needs no new column, because the meal already carries the hostel. *That is the
  test of a good model: the new dimension enters in one place.*

*Write path:* "The cut-off check reads the cut-off from the *meal's* hostel, not the
student's, because the deadline belongs to the kitchen doing the cooking. That is the
subtle one — if I read the cut-off from the student, a visiting student gets the wrong
deadline."

*Read path:* "Every cook's query gains `WHERE hostel_id = :id`, and that column goes into
the index: `opt_ins(meal_id)` stays, but the meals index becomes
`meals(hostel_id, meal_date)`. Without the hostel in the index, every cook scans all 40
hostels' meals."

*Authorisation:* "New requirement. A cook must not see another hostel's data, so the hostel
id must come from the cook's session, never from a query parameter. Right now my app has
one cook and no such check, so this is genuinely new code, not a config change."

*Hard cases:*
+ *Visiting students.* A student opting into another hostel's meal is now allowed by the
  model. Should it be? I would ask, and if yes, the home cook's count must go down while the
  visited cook's goes up — which means the count is per-meal and correct automatically, but
  the *waste report per hostel* now needs care about who paid.
+ *Cut-off spread.* 40 cut-offs at different times is actually good news: the 9 pm spike I
  worried about earlier spreads out.
+ *Migration.* The existing 78 students and six weeks of rows need a hostel id. I would add
  the column as nullable, backfill it to hostel 1, then make it `NOT NULL` — three steps,
  because a single step locks the table and fails if any row is null.

*Smaller version:* "Ship hostels, the hostel column on meals, the per-hostel cut-off and
the session-based authorisation. Do *not* ship visiting students in version one — it is the
only part with a money question attached, and it needs someone to decide policy, not
engineering."
]

#table(columns: 2,
  align: (left, left),
  [*Move in the answer*], [*What it demonstrates*],
  [New dimension enters in exactly one table], [Data modelling judgement.],
  [Cut-off read from the meal, not the student], [You thought about whose rule it is.],
  [Index changed along with the query], [You know an index must match the filter.],
  [Hostel id from the session, not the URL], [Authorisation instinct.],
  [Three-step migration for `NOT NULL`], [Operational awareness — the thing freshers never mention.],
  [Deliberately cuts a feature from v1], [Prioritisation, and knowing which problems are not technical.],
)

#trick[
The migration point — *"nullable, backfill, then NOT NULL"* — is a small, true, practical
detail that almost no fresher says. Details like this are worth more than a fluent
paragraph, because they can only come from having actually changed a table that had data in
it.
]

#section[If your project is not really yours yet]

Some students reach the interview knowing, privately, that they cannot defend the project
on their resume. Perhaps a teammate wrote most of it. Perhaps it was bought or copied.
Here is the honest path, and it is not a comfortable one.

#formulas(title: "The three legitimate moves")[
*Move 1 — Rebuild the part you will be asked about.* You usually have days or weeks, not
hours. Take the single main feature and rewrite it yourself from an empty file. Not copied,
not pasted — typed. One feature you truly wrote beats four you cannot explain.

*Move 2 — Narrow the claim on the resume.* Change "Built a full-stack e-commerce platform"
to "Built the cart and checkout API for a team e-commerce project". A narrower true claim
is stronger than a broad false one, and it steers the questions to where you are strong.

*Move 3 — Remove it.* A resume with one project you own beats a resume with four you
cannot discuss. Removing a line costs you nothing at screening and saves you a collapse in
the room.

*The move that is not available:* claiming work you did not do. It is not a strategy with
a downside — it is a strategy that fails, because the follow-up questions in this chapter
cannot be survived by someone who did not build the thing.
]

#ex(30, tier: 1, asked: "any company · pattern")[
You are asked about a project module a teammate wrote, and you cannot explain it.
]
#sol[
*The recovery, in the room:* "I should be straight with you — that module was Priya's, and I
can describe what it does but I would be guessing about how it works inside.

What I can take you through properly is the part I wrote: the cart and the checkout
endpoints, including the double-submit problem we hit and how the unique key on the order
reference fixed it.

Would that be useful, or do you specifically need the recommendation module?"

*Why this survives:* it is one sentence of admission, then an immediate redirect to real
material, and it treats the interviewer as someone with a goal. Compare it to two minutes
of vague guessing, which ends the interview mentally even if it continues on the clock.

*And then fix it afterwards.* Narrow that line on your resume tonight.
]

#section[Red flags that end the round]

#table(columns: 2,
  align: (left, left),
  [*Red flag*], [*Say this instead*],
  [“It is fully scalable / production ready.”],
  [“It ran for six weeks with 78 users. I have not load tested past that.”],
  [“There were no bugs.”],
  [“The one that cost us most was the duplicate count. Here is what caused it.”],
  [Cannot name a single file or function.],
  [“The cut-off check lives in `optin.js`, in the handler, before the write.”],
  [Describes a diagram from the internet, not the code that exists.],
  [Draws only the boxes that were deployed, and says where the drawing ends.],
  [Blames teammates for everything broken.],
  [Names what was yours to own, first.],
  [Answers a question about the front end in detail, having not written it.],
  [“I did not write that part; here is what I know from reading it.”],
  [Uses “we” for every sentence.],
  [Uses “I” for your modules and names teammates for theirs.],
)

#practice(tier: 3, time: "45 min, with a partner if possible")[
Have a friend ask these about *your* project and refuse to accept the first answer — they
must ask "why?" or "how do you know?" three times per question.

+ Name every technology in your stack and, for each, one thing the alternative does better.
+ Which invariants in your data are enforced by the database and which only by your code?
+ What is the most likely silent failure in your system — a failure nobody would notice?
+ Your main write endpoint gets called twice with the same payload. Trace what happens now,
  and what should happen.
+ Give the arithmetic for what breaks first at 1000× users.
+ Your background job does not run tonight. Who notices, and how?
+ In STAR form, four parts labelled: a technical disagreement you had and how it ended.
+ You have two weeks and one engineer. What do you build, and what do you explicitly not
  build?
+ What is the edge of what you actually verified, as opposed to what you believe?
]

#key[
Score each answer 0, 1 or 2. *2* = you survived three "why"s with true, specific content.
*1* = you survived two and then went vague. *0* = you repeated the question back, used a
buzzword, or said something you are not sure is true.

Target: at least 14 out of 18 before a Tier-3 interview. Any *0* on questions 2, 4 or 9 is
the most urgent to fix — those three are where bluffing gets caught.
]

#section[The 20-minute self-drill]

You cannot practise this round by reading. You practise it by being asked. If you have no
partner, be your own interviewer with a timer and a voice recorder on your phone.

#formulas(title: "Run this the night before, for each project")[
*Minutes 0–2.* Say the 90-second pitch. Record it. Do not stop for mistakes.

*Minutes 2–5.* Play it back. Count three things: buzzwords with no evidence, sentences
over 20 words, and whether a number appeared. Write the counts down.

*Minutes 5–10.* Draw the architecture from memory on paper. Then open your repository and
check it. Every box you drew that does not exist, and every piece that exists but you
forgot, is a question you would have fumbled.

*Minutes 10–15.* Pick one line from your resume. Ask yourself "why?" four times in a row,
out loud, and answer each one. Note the level at which you ran out. That level is your
honest depth today.

*Minutes 15–18.* Answer these two, timed at 60 seconds each: "what broke?" and "what would
you change?" These are the two questions candidates most often have nothing prepared for.

*Minutes 18–20.* Write one sentence: the thing you would most hate to be asked. Then
prepare that one. It is almost always the one that gets asked.
]

#trick[
The recording is the part people skip and the part that works. You cannot hear your own
filler words, your own trailing sentences, or your own three-minute answers while you are
speaking. You can hear all of them on playback within ten seconds.
]

#subsection[Questions to ask them about the code]

At the end of a project round you are usually asked "do you have any questions?". Technical
questions about *their* system are far stronger than questions about perks, and they
continue the conversation on your strongest ground.

#table(columns: 2,
  align: (left, left),
  [*Ask*], [*What it signals*],
  [“What does a typical pull request look like on your team — size, and how many reviewers?”],
  [You have worked in a reviewed workflow and care about it.],
  [“What is the oldest part of the system that people are still afraid to change?”],
  [You know real systems have those, and you are not scared of legacy.],
  [“How do you find out something is broken in production — alerts, or a user telling you?”],
  [Observability awareness, which is rare in a fresher.],
  [“What would I be shipping in my first month?”],
  [Practical, and it gives you real information about the role.],
  [“What is the test and release process — how often do you deploy?”],
  [Process awareness, and it tells you a lot about the team's health.],
)

#note[
Ask two, not six. Then stop. The same discipline that ends your pitch at 90 seconds applies
here — a candidate who keeps asking questions past the interviewer's time is remembered for
that, not for the questions.
]

#revision[
*The round scores four things:* ownership, depth, trade-off thinking, honesty.

*Prepare the 12-line Defence Sheet per project.* Problem · users · what it does · stack
with reasons · my part · their part · data model · one request end-to-end · one number ·
what broke · one trade-off · what you would change.

*The 90-second pitch:* pain → fix → honest scope → stack with one reason → "I wrote…" →
one number plus one limit. Then stop.

*Ownership:* claim narrowly, credit teammates by name, explain one interface between your
part and theirs, state where your knowledge ends.

*Every choice needs an alternative.* "I chose X over Y because Z, and I gave up W."

*One real number beats ten adjectives.* Scalable, robust, optimised and user-friendly are
worth zero without evidence.

*Volunteer your weak spot.* Point at the single point of failure and the slow query before
they ask. It converts their best question into your best moment.

*Failure modes:* for any background job or external call — what happens if it does not
run, runs twice, or runs and silently fails? Name detection and recovery. Silent failures
cost the most.

*Invariants:* know which are enforced by the database and which only by code. Code-level
ones can be bypassed by a second writer.

*The "I don't know" protocol:* say it plainly → give the nearest true thing → label any
guess as a guess → ask a real question back.

*Small project?* Say it came from a tutorial, then defend the two or three things you
changed, at four levels of depth. Never inflate.

*Rebuild answers are engineering, not features:* idempotency, one source of truth, logging,
load tests — not "add a mobile app".

*Substitute your own project everywhere.* Every filled example in this chapter is invented
to show the shape. A memorised story dies on the first follow-up.
]

]
