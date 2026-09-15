#import "../../shared/lib/style.typ": *

#chapter(num: 3, title: "The Core HR Questions",
  tagline: "Ten questions decide most HR rounds. Build an answer for each one, from your own life.")[

#section[Pattern in one page]

The HR round is short. It is often 15 to 25 minutes. In that time the interviewer is trying to
answer five private questions. Every question they ask out loud is a way of getting at one of
those five.

#formulas(title: "What the HR round is really scoring")[

*1. Can this person speak clearly?* Can they answer in 60 to 90 seconds without wandering?

*2. Is the resume true?* If the resume says "built a REST API", can the person describe it
without help?

*3. Will they actually join?* Companies lose money when an offer is rejected. They look for
signs: did you research us, do you have a reason to be here, is the location workable?

*4. Will they stay one or two years?* Not forever. Just long enough to be worth training.

*5. Are they easy to work with?* Do they blame others? Do they listen? Do they interrupt?

Nothing else is being scored. Not your vocabulary. Not big words. Not a fancy accent.
]

#note[Read that list again before you prepare any answer. If an answer of yours does not move
at least one of those five, it is decoration. Cut it.]

#diagram(height: 4.6cm, caption: "The same five scores, hiding behind different questions")[
  #dnode(0cm, 0cm, 3.4cm, 0.85cm, "Tell me about yourself")
  #dnode(0cm, 1.1cm, 3.4cm, 0.85cm, "Why our company?")
  #dnode(0cm, 2.2cm, 3.4cm, 0.85cm, "Your weakness?")
  #dnode(0cm, 3.3cm, 3.4cm, 0.85cm, "Where in 5 years?")
  #darrow(3.4cm, 0.42cm, 6.2cm, 1.3cm)
  #darrow(3.4cm, 1.52cm, 6.2cm, 1.6cm)
  #darrow(3.4cm, 2.62cm, 6.2cm, 2.4cm)
  #darrow(3.4cm, 3.72cm, 6.2cm, 2.7cm)
  #dnode(6.2cm, 1.0cm, 3.6cm, 2.0cm, "The five private questions", fill: rgb("#e6eef4"))
  #darrow(9.8cm, 2.0cm, 12.0cm, 2.0cm, label: "score")
  #dnode(12.0cm, 1.35cm, 3.6cm, 1.3cm, "Hire / hold / reject", fill: rgb("#f3f0e6"))
]

#section[The rule that beats every script]

You will find "sample answers" everywhere. Most students memorise one and repeat it. It fails,
and it fails in a predictable way: the first 30 seconds sound polished, then the interviewer
asks one follow-up and the whole thing collapses, because there was nothing underneath.

#formulas(title: "The substitution rule — the most important line in this chapter")[
Every answer in this book is a *STRUCTURE plus a filled example*. The structure is yours to
keep. The filled example is *not*. It is filled with a made-up student's life so you can see
the shape. *You must replace every fact in it with your own real experience.*

If you cannot fill a slot with something true, the answer is not ready. Go and do something
real, however small, and then fill the slot. Do not invent it.
]

#trap[
*Never claim work you did not do.* Not an internship you did not have. Not a team size you did
not lead. Not a number you did not measure. Interviewers ask follow-ups for a living. The
moment a claim breaks under one "how did you measure that?", the whole interview is over, and
at many companies the rejection is recorded against your name for future openings too.

There is always a truthful version of your answer that is strong enough. This chapter shows you
how to find it.
]

#subsection[How long should an answer be?]

Calm English speech is roughly 130 words per minute. That gives you a simple budget.

#code(lang: "js", caption: "Check any answer against its time budget")[
```js
// Calm interview speech in English: about 130 words per minute.
const WPM = 130;

const speakSeconds = (text) => {
  const words = text.trim().split(/\s+/).filter(Boolean).length;
  return { words, seconds: Math.round((words / WPM) * 60) };
};

const check = (label, budgetSec, text) => {
  const { words, seconds } = speakSeconds(text);
  const verdict = seconds > budgetSec * 1.15 ? "TOO LONG - cut"
                : seconds < budgetSec * 0.5  ? "TOO SHORT - add proof"
                : "fits";
  console.log(`${label.padEnd(14)} words=${String(words).padStart(3)}` +
              `  ~${String(seconds).padStart(3)}s  budget=${budgetSec}s  -> ${verdict}`);
};
```
]

Running it on three versions of the same introduction:

#code(lang: "text", caption: "Measured output")[
```text
60s intro      words=105  ~ 48s  budget=60s  -> fits
too short      words= 19  ~  9s  budget=60s  -> TOO SHORT - add proof
rambling       words=210  ~ 97s  budget=60s  -> TOO LONG - cut
```
]

#formulas(title: "Time budgets to memorise")[
#table(columns: 3, align: (left, right, right),
  [*Question*], [*Seconds*], [*Words*],
  [Tell me about yourself], [60--90], [130--190],
  [Strength / weakness], [45--60], [95--130],
  [Why this company], [45--60], [95--130],
  [Where in 5 years], [40--50], [85--110],
  [A behavioural story (Chapter 4)], [90--120], [190--260],
  [Do you have questions for us], [ask 2--3], [--],
)
]

#trick[
Practise with a clock, not with a feeling. Record yourself on your phone. Play it back once at
normal speed. You will hear your own filler words in the first 20 seconds, and you will never
un-hear them. That single recording is worth ten hours of reading.
]

// ==================================================================
#section[Question 1 — "Tell me about yourself"]

This is asked in almost every HR round. It is also the question students prepare worst, because
it feels easy. It is not a biography request. It is a request for a *pitch*.

#formulas(title: "Structure: NOW - PATH - PROOF - POINT")[
*NOW* (1 sentence). Who you are today. Name, year, branch, college city.

*PATH* (1--2 sentences). The one line of your story that led here. Pick one thread only.

*PROOF* (2--3 sentences). The strongest concrete thing you built or did, with a number if you
honestly have one. This is the part everyone skips and it is the part that gets you hired.

*POINT* (1 sentence). Why that path points at *this* job at *this* company.

Total: 5 to 7 sentences. 60 to 90 seconds. Then stop talking.
]

#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Write the NOW sentence only. 20 words or fewer. Say your name, your year, your branch, your
city, and one skill area.
]
#sol[
Filled example, to be replaced with your own facts:

"I am Meera Raghavan, a final-year Information Technology student in Pune, and my strongest area
is backend work in Node."

That is 22 words. Count yours. If it is over 25, drop the adjectives first.
]

#ex(2, tier: 0, asked: "warm-up")[
Write the PROOF sentence only, for one thing you have actually built. It must contain a noun
(what), a verb (what you did), and a measurement (how much) if you have one.
]
#sol[
Filled example:

"I built a canteen pre-order site that about 200 students used during our college fest, and I
cut the order page from about four seconds to under one second."

Notice the hedge words: "about 200", "about four seconds". Hedging is honest and it is *safe*.
If you did not count exactly, say "about". Never state a precise number you did not measure.
]

#tier-header(1)

#ex(3, tier: 1, asked: "TCS NQT · pattern")[
"Tell me something about yourself."
]

#trap[
*Weak answer.*

"Good morning sir. Myself Meera Raghavan. I am from Pune. I did my schooling from a CBSE school
and I got 89 percent in 12th. Then I took admission in IT branch. My father is a bank employee
and my mother is a housewife. I have one younger brother who is studying in 10th standard. My
hobbies are listening to music and reading books. I am a hard-working person, punctual and a
quick learner. I want to work in a reputed company like yours where I can grow my career and
utilise my skills for the growth of the organisation. Thank you."
]

Now the same student, same facts, nothing invented:

#sol[
*Strong answer.*

"I am Meera Raghavan, a final-year IT student in Pune. *(NOW)*

I moved toward backend work in my second year, after I realised I enjoyed the database side of a
project much more than the screens. *(PATH)*

The clearest example is a canteen pre-order site I built for our college fest. About 200 students
used it over three days. The order page was taking about four seconds to load because I was
fetching the full menu on every click. I cached the menu and added an index on the item table,
and it came down to under a second. I also learned the hard way to handle two people ordering the
last item at the same time. *(PROOF)*

I am applying here because your service teams do a lot of backend and data work for clients, and
that is the part of a project I already choose on my own. *(POINT)*"
]

#subsection[Name exactly what changed]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak version*], [*Strong version*],
  [Opening], [Ritual words: "Myself...", "reputed company"], [Plain sentence: name, year, city, area],
  [Family and school], [Four sentences, zero signal], [Removed. Nobody is scored on a brother in 10th],
  [Adjectives], [hard-working, punctual, quick learner -- all unproven], [Replaced with one story that *shows* it],
  [Evidence], [None], [200 users, 4s to under 1s, a concurrency bug],
  [Closing], ["grow my career, utilise my skills"], [A named link between her work and their work],
  [Follow-up safety], [Nothing to ask about -- interview stalls], [Five easy follow-ups invited, all answerable],
)

#note[Look at the last row. A strong introduction *hands the interviewer their next question*.
That is deliberate. You want them asking about the index, or the double-order bug, because you
can talk about those for five minutes with real detail.]

#trap[
*"Myself Meera Raghavan" is not English.* It is a very common habit in Indian interviews. Say
"I am Meera Raghavan" or "My name is Meera Raghavan". Similarly, drop "I am having 8.1 CGPA"
(say "I have"), and drop "kindly do the needful" from your emails forever.
]

#subsection[What if I have no internship and no big project?]

Then you say so, plainly, and you show the small real thing instead. Small and true beats big
and vague.

#ex(4, tier: 1, asked: "Wipro · pattern")[
Same question, but the student has no internship, one college project, and a 7.1 CGPA.
]
#sol[
"I am Arun Kale, final-year Computer Engineering in Nagpur. *(NOW)*

I have not done an industry internship. What I have instead is a habit of finishing small things.
*(PATH, honest)*

Last year our class had trouble tracking lab submissions, so I wrote a small attendance and
submission tracker in Node with a SQLite file. It is not a big system. It is about 600 lines. But
three faculty members used it for a full semester, and I had to fix two real bugs after release:
one where a date was stored in local time and shifted by a day, and one where two teachers
editing the same record overwrote each other. Fixing those taught me more than the building did.
*(PROOF)*

My CGPA is 7.1. It was 6.4 after my second year, and it has gone up every semester since. *(honest
weakness, with the direction of travel)*

I am applying for your development track because the work I have enjoyed most is exactly this:
small tools that somebody actually uses. *(POINT)*"
]

#trick[
*The direction of travel beats the absolute number.* "7.1, and it was 6.4 two years ago" is a
story about someone who fixes things. "7.1" alone is just a number. Use this move for CGPA,
backlogs, and any weak patch. Chapter 6 goes deeper into it.
]

#tier-header(2)

#ex(5, tier: 2, asked: "Shopee · pattern")[
"Walk me through your background." Role is a graduate backend engineer in Singapore, and the
student is applying from India.
]
#sol[
Regional rounds add one thing to NOW-PATH-PROOF-POINT: a *location reason* that is not "salary"
and not "abroad life".

"I am Meera Raghavan, a final-year IT student in Pune. *(NOW)*

For the last two years my work has been on the backend and database side. *(PATH)*

The project I would point to is a canteen pre-order site used by about 200 students over three
days. The interesting part was not building it, it was the two failures: the order page took
about four seconds because I refetched the whole menu each click, and two people could buy the
same last item. I fixed the first with caching and an index and got it under a second. For the
second I moved the stock check into the same transaction as the order insert. *(PROOF)*

On why Singapore specifically: the products I use and read about that run at real regional scale
are built here, across several countries and currencies at once. I want the problem where the
same feature has to work in four markets, because that changes the design, not just the copy. I
have also checked the practical side -- I understand this role would be on an Employment Pass
sponsored by the company, and I am ready for the timeline that involves. *(POINT, with location)*"
]

#note[The last sentence does real work. Regional recruiters screen hard for candidates who have
not thought about visas and will drop out halfway. One calm sentence showing you know the pass
exists moves you ahead of most applicants. Do not overclaim: say what you know, not what you
guess. Never state a pass or visa status you do not have.]

#tier-header(3)

#ex(6, tier: 3, asked: "Amazon · pattern")[
"Tell me about yourself." Product company, 45-minute behavioural round, and the interviewer will
drill into whatever you say.
]
#sol[
At Tier 3 the structure is the same, but the PROOF must be *drillable to three levels*. Before
you speak a sentence, ask yourself: if they say "why?" three times, do I still have an answer?

"I am Meera Raghavan, final-year IT in Pune, and I work mostly on backends. *(NOW)*

The thread through the last two years is that I keep ending up as the person who measures things.
*(PATH -- a claim about character, which the PROOF must now earn)*

Concretely: a canteen pre-order site for our fest, about 200 users over three days. The order
page took about four seconds. My first guess was that the server was slow. I put timers around
three sections and found the server call itself was about 80 milliseconds, and the rest was the
browser re-rendering a 120-item menu on every click. So I had been about to fix the wrong thing.
I cached the menu client-side and rendered only the changed row, and it dropped to under a second.
*(PROOF -- and it contains a wrong first guess, on purpose)*

I am here because the thing I liked most in that project was being forced to measure before
changing, and that is the default way of working I read about on your engineering blog. *(POINT)*"

*Why the wrong guess is in there deliberately:* it gives the interviewer a place to dig, and the
digging makes you look better, not worse. "What made you check instead of just optimising the
server?" is a question you *want*.
]

#trap[
At Tier 3 do not open with "I am passionate about technology". It is the single most common
opening line and it carries zero information. Passion is shown by what you did on a Sunday, not
by the word "passionate".
]

// ==================================================================
#section[Question 2 — Strengths]

#formulas(title: "Structure: NAME - PROOF - USE")[
*NAME* one strength. One. Not three.

*PROOF*: one short situation where it changed an outcome.

*USE*: one sentence on how it would help in this role.

Pick a strength that is *relevant to the job*, *provable*, and *not a personality adjective*.
"Punctual" is not a strength for a developer. "I debug by measuring before changing" is.
]

#ex(7, tier: 1, asked: "Infosys · pattern")[
"What are your strengths?"
]

#trap[
*Weak answer.* "My strengths are that I am a hard worker, a quick learner, I am punctual, I have
good communication skills, and I am a good team player."

Five adjectives, zero evidence, and every other candidate said the same five. The interviewer
writes nothing down.
]

#sol[
*Strong answer.*

"I will pick one: I am stubborn about finding the real cause instead of patching the symptom.
*(NAME)*

In my canteen project the order page was slow and I assumed the server was the problem. Before
changing anything I put timers on three parts. The server was 80 milliseconds. The browser
re-render was the rest. If I had trusted my guess I would have spent a week making a fast thing
faster. *(PROOF)*

In a support or maintenance role that habit matters, because most of the cost of a bug is in
finding it, not in fixing it. *(USE)*"
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Count], [Five strengths], [One strength, defended],
  [Type], [Personality adjectives], [A working habit],
  [Evidence], [None], [A situation with numbers],
  [Self-criticism], [None], [Admits a wrong first guess -- reads as honest],
  [Relevance], [Generic], [Tied to what this role actually does],
)

#trick[
*Test any strength with this sentence:* "Could a person who is bad at this job also claim it?"
If yes, it is a weak choice. Anyone can claim "hard-working". Almost nobody can claim "I timed it
before I changed it" and back it up.
]

#subsection[A menu of strengths that survive follow-ups]

Choose from real behaviour, not from a list of adjectives. Each of these needs your own story.

#table(columns: 2, align: (left, left),
  [*Strength you can prove*], [*The proof it needs*],
  [I measure before I change], [A time your measurement contradicted your guess],
  [I write things down so others can pick them up], [A doc or README somebody else actually used],
  [I ask early instead of being stuck silently], [A time asking on day 1 saved a week],
  [I finish the boring last 10 percent], [A project you actually deployed, not just demoed],
  [I test the ugly inputs], [A bug you caught with an empty string or a duplicate],
  [I can read somebody else's code], [A codebase you did not write and still changed safely],
)

// ==================================================================
#section[Question 3 — Weaknesses]

This question is not a trap, but students turn it into one. The interviewer wants to know two
things: can you see yourself honestly, and are you doing anything about it.

#formulas(title: "Structure: REAL - COST - FIX - EVIDENCE")[
*REAL*: a genuine weakness that is not fatal for this job.

*COST*: one concrete time it actually cost something. This is what makes it believable.

*FIX*: the specific mechanism you now use. A mechanism, not a wish.

*EVIDENCE*: one sign the mechanism is working.

The shape is: "Here is a true flaw. Here is the damage it did once. Here is the system I built so
it does less damage. Here is proof the system runs."
]

#ex(8, tier: 1, asked: "Capgemini · pattern")[
"What is your biggest weakness?"
]

#trap[
*Weak answer A (the fake weakness).* "My weakness is that I am a perfectionist and I work too
hard, sometimes I trust people too much."

Every interviewer has heard this hundreds of times. It reads as "I will not tell you anything
true", which is worse than any real flaw.
]

#trap[
*Weak answer B (the fatal one).* "I get bored easily and I lose interest in a project after a
few weeks."

True, perhaps, but it answers the interviewer's private question number 4 -- will they stay --
with a loud no. Honesty does not mean handing them a reason to reject you. Pick a *true* weakness
that is *survivable*.
]

#sol[
*Strong answer.*

"I under-communicate when I am stuck. My instinct is to keep digging quietly. *(REAL)*

In our sixth-semester group project I lost about two days on a login bug before telling anyone.
When I finally said it out loud in the group chat, a classmate recognised it in ten minutes --
our session cookie was not being set because we were testing on two different ports. Those two
days came out of the team's buffer, not mine. *(COST)*

Since then I use a rule rather than good intentions: if I am stuck for 45 minutes, I write down
what I tried and post it, even if it is embarrassing. I keep a timer visible. *(FIX)*

In my last two projects I have raised three things that way, and the longest one was solved in
under an hour by somebody else. *(EVIDENCE)*"
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Truth], [A disguised brag], [An actual flaw with a name],
  [Damage], [Claimed to have none], [Two lost days, and whose buffer paid],
  [Fix], [Absent, or "I am working on it"], [A 45-minute rule with a visible timer],
  [Proof], [None], [Three real uses since],
  [Risk], [Answer B threatens retention], [The flaw is real but survivable],
)

#subsection[Weaknesses that are safe to tell the truth about]

Safe means: real, common, fixable with a mechanism, and not a direct threat to doing the job.

#table(columns: 2, align: (left, left),
  [*Safe and true*], [*Do NOT use*],
  [I stay stuck too long before asking], [I get bored and leave things],
  [I over-explain and my updates are too long], [I am bad with deadlines],
  [I used to skip writing tests when rushed], [I do not like being told what to do],
  [Public speaking makes me nervous], [I lose my temper with people],
  [I say yes to too many tasks and then run late], [I am not good at learning new things],
  [I focus on code and forget to update the team], [Anything about honesty or attendance],
)

#note[If your true weakness is on the right-hand list, that is a real problem to work on in your
life -- but an interview is not a confession booth. Choose a different true weakness from the
left-hand list. Choosing which truth to tell is not lying. Inventing a truth is.]

// ==================================================================
#section[Question 4 — "Why do you want to join us?"]

This is the retention question in disguise. A weak answer here is the most common silent reason
for rejection, because it reads as "I applied everywhere".

#formulas(title: "Structure: FACT - FIT - FUTURE")[
*FACT*: one specific, checkable thing about the company that you found yourself. Not "reputed",
not "market leader", not "great work culture".

*FIT*: the honest link between that fact and something you have actually done or want to do.

*FUTURE*: what you would want to be doing there in year one or two.

You need 20 minutes of research per company. That is the whole cost. Most candidates spend zero,
so 20 minutes puts you near the top.
]

#subsection[Where to find the FACT in 20 minutes]

+ The company careers page: read the actual job description, twice. Write down three verbs from
  it ("maintain", "migrate", "support").
+ The engineering blog, if they have one. One post, the most recent.
+ The last two quarters of company news. What did they launch, buy, or enter?
+ The tech stack listed in three of their open roles. Compare it to yours honestly.
+ One person's public profile in the team you applied to, to learn what the work looks like.

#ex(9, tier: 1, asked: "TCS · pattern")[
"Why do you want to join our company?"
]

#trap[
*Weak answer.* "Your company is a reputed multinational company with a very good work culture and
a great brand value in the market. I want to work here so that I can enhance my skills and grow
along with the organisation. Also it is one of the top IT companies in India."

Nothing here is specific to them. Swap in any other company name and the sentence still works.
That is the test, and it fails it.
]

#sol[
*Strong answer.*

"Two reasons, one about the work and one about me.

The job description for this role lists application support and migration work on existing client
systems, and it mentions SQL tuning specifically. *(FACT -- taken straight from their own JD)*

That matches what I have actually enjoyed. My project work was mostly reading and fixing code I
did not write -- our college attendance tool was handed to me half-finished, and the parts I
liked were finding out why it broke and making the queries fast. Greenfield building was less
interesting to me than that. *(FIT -- honest, and it explains a preference most freshers cannot
articulate)*

In the first year I would want to get properly good at one client's system -- good enough that
people ask me before they change something. *(FUTURE)*"
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Specificity], [Works for any company], [Quotes their own job description],
  [Direction], [What the company gives *her*], [What she brings *them*, then what she learns],
  [Honesty], [Flattery], [Admits she prefers maintenance to greenfield],
  [Retention signal], [None], [A concrete year-one goal inside *their* work],
)

#trick[
*The swap test.* Read your "why us" answer out loud with a competitor's name substituted. If it
still makes sense, it is not an answer yet. Go find one checkable fact.
]

#tier-header(2)

#ex(10, tier: 2, asked: "Grab · pattern")[
"Why do you want to work here, and why in this region rather than in India?"
]
#sol[
Answer both halves. Students answer only the first and lose the round on the second.

"On the company: your business runs several different services on one account and one wallet, in
countries with different rules and payment methods. That means almost every feature is a
multi-country problem, not a single-market problem. *(FACT)*

On the work fit: the parts of my own project I found hardest were exactly the boring
compatibility ones -- currency rounding, time zones, one item being ordered twice at once. I
would rather work on that class of problem than on one clean market. *(FIT)*

On the region: I want to be in the place where the product is actually designed and run, not in
a team that receives specifications. I also want to work in a mixed team -- most of my life I
have worked with people who share my assumptions, and I think that has limits I cannot see yet.
*(FUTURE, honest)*

On the practical side: I have looked at what this role involves for an Indian graduate -- company
sponsorship, and a salary floor the pass requires. I am not expecting the company to bend
anything, and I would rather discuss it early than late."
]

#note[Notice what is *not* said: nothing about salary being higher, nothing about "abroad
exposure", nothing about settling permanently. Those may be true motivations, but as a stated
reason they predict that you will leave when a better-paying country calls. Say the true reason
that is also durable.]

#tier-header(3)

#ex(11, tier: 3, asked: "Google · pattern")[
"Why us? And be specific -- what do you actually know about what this team does?"
]
#sol[
"I will answer the second part first, because I think it is the real question.

This team's job listing says you own the internal tooling that other engineering teams use to
ship. Two things stood out. The first is that your users are engineers, which means your users
will tell you exactly what is wrong, loudly, and you cannot hide behind averages. The second is
that the listing mentions reducing build feedback time, which is a latency problem with a very
clear success metric. *(FACT -- read carefully, and interpreted, not just repeated)*

Why that fits me: the work I have enjoyed most was internal. I built a submission tracker that
three faculty members used, and the useful part was that they complained directly and I could
fix it the same week. The feedback loop was one day, not one semester. *(FIT)*

Where I am honest about the gap: my experience is at 200 users, not at your scale. What I think
transfers is the measuring habit, not the solutions. I expect most of what I believe about
performance to be wrong at your scale, and I would want to find that out quickly rather than
defend it. *(FUTURE, plus a calibrated admission)*"
]

#trick[
*Name your own gap before they find it.* At Tier 3 the interviewer already knows a final-year
student has not run anything at scale. Saying it yourself costs you nothing and buys a lot of
credibility. Never do this with a *core* requirement of the job, only with a gap that is normal
for your stage.
]

// ==================================================================
#section[Question 5 — "Where do you see yourself in five years?"]

The interviewer is asking: will you still be here, and do you have any direction at all.

#formulas(title: "Structure: DIRECTION - NEXT STEP - ANCHOR")[
*DIRECTION*: the kind of work you want to be doing, not a job title.

*NEXT STEP*: what you want to be trusted with in year one or two. Concrete and small.

*ANCHOR*: one line tying it to this company's actual path.

Avoid two failures: the fantasy ("I want to be a manager in three years") and the emptiness
("I want to grow with the organisation").
]

#ex(12, tier: 1, asked: "Accenture · pattern")[
"Where do you see yourself in five years?"
]

#trap[
*Weak answer.* "In five years I see myself in a managerial position in your esteemed
organisation, leading a team and contributing to the growth of the company."

Problems: a fresher who wants to manage in five years often means "I want to stop coding", which
is not what a delivery team is hiring for. It also names a promotion the company cannot promise.
]

#trap[
*Weak answer B.* "Sir, in five years I want to prepare for higher studies abroad and then maybe
do my own startup."

This may well be true. But you have just told the retention question its answer is "no". If it
*is* your firm plan, apply to companies where that is fine, and be honest -- do not take an offer
you know you will break. If it is one vague option among many, do not present it as a plan.
]

#sol[
*Strong answer.*

"I want to be the person a team relies on for one system end to end -- the one who knows why it
was built that way and what breaks it. *(DIRECTION -- a kind of work, not a title)*

Getting there, in the first two years I want to move from 'fixes tickets in a module' to 'owns
that module', including being the person on call for it. *(NEXT STEP)*

I know your delivery teams rotate people across client systems, so I would expect two or three
domains in five years rather than one. That suits me -- I would rather have depth in one and
working knowledge of a few than a title. *(ANCHOR -- and it shows she knows how they operate)*"
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Unit of ambition], [A title ("manager")], [A capability ("owns a system")],
  [Realism], [Ignores how promotions work], [Uses their real rotation model],
  [Retention], [Neutral or negative], [Positive and specific],
  [Checkability], [Cannot be discussed further], [Invites "which system would you want?"],
)

// ==================================================================
#section[Question 6 — "Why should we hire you?"]

This one feels aggressive. It is not. It is a request for a summary, and it is your chance to
repeat your best evidence one more time.

#formulas(title: "Structure: MATCH - EDGE - RISK")[
*MATCH*: the two or three requirements from their JD that you genuinely meet.

*EDGE*: the one thing about you that most other applicants at your level do not have.

*RISK*: what they would be taking on, and why it is manageable. Optional at Tier 1, strong at
Tier 3.
]

#ex(13, tier: 1, asked: "Cognizant · pattern")[
"Why should we hire you over the other candidates?"
]

#trap[
*Weak answer.* "Because I am a fresher, I am a fast learner, and I will work hard for your
company. Whatever training you give me, I will learn it quickly and give my best."

It promises effort, which is free. Everyone promises effort. It gives no reason to choose *this*
person.
]

#sol[
*Strong answer.*

"Three things from your job description match what I have actually done: SQL work, supporting
code somebody else wrote, and a rotating on-site shift. I have done the first two in college
projects and I have already checked that the shift works for me. *(MATCH)*

The thing I would claim over most freshers is that I have maintained code I did not write. Our
attendance tool was handed to me half-built, with no documentation and one comment in the whole
file. I spent two weeks just reading it and writing down what each screen touched, before I
changed anything. Most people my level have only built from scratch. *(EDGE)*

What you would be taking on: I have never worked to a client SLA and I do not know your process
yet. The part of that I can control is speed of picking it up, and my evidence for that is the
attendance tool. *(RISK)*"
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Currency], [Effort, which everyone offers], [Evidence, which few have],
  [Source], [Self-description], [Their own requirement list],
  [Differentiation], [None], [One rare skill for a fresher, named exactly],
  [Maturity], [--], [Names its own risk and limits it],
)

// ==================================================================
#section[Question 7 — The branch and choice questions]

Common in Indian HR rounds, especially for students from non-CS branches.

#formulas(title: "The three variants and the one structure")[
"Why did you choose this branch?" · "You are from Mechanical -- why IT?" · "Why not higher
studies?"

*Structure: TRUE START - TURNING POINT - PROOF OF COMMITMENT*

The interviewer is checking that this is not a panic decision that will reverse in a year. So the
answer must contain *costly evidence* -- something you spent time on that a casual person would
not have.
]

#ex(14, tier: 1, asked: "Infosys · pattern")[
"You have a Mechanical Engineering degree. Why are you applying for a software role?"
]

#trap[
*Weak answer.* "Sir, actually there is no scope in core mechanical these days, there are no jobs
in the market, and IT has more opportunities and better packages, so I shifted to software."

Honest, but it says: the moment core jobs return, or another field pays more, I leave. It also
says nothing about ability.
]

#sol[
*Strong answer.*

"I chose Mechanical at 17 because I liked machines and I did not really know what software work
was. That part was not a mistake -- I still use the habit of thinking about tolerance and
failure. *(TRUE START -- no apology, no fake passion)*

The turn came in my third semester. Our lab had to log vibration readings by hand into a
register. I wrote a small script to read the sensor output file and chart it, mostly to avoid the
boredom. It saved my lab partner and me about an hour a week, and I realised I had spent a whole
weekend on it happily. *(TURNING POINT -- a real, small, checkable moment)*

Since then: I have finished a full backend course and written about 4,000 lines of Node across
three projects, and I sat the same coding test as the CS students in my college and cleared it.
My CS fundamentals are self-taught, which means my theory has gaps -- I have had to go back and
learn operating systems properly on my own, and I am still working on databases. *(PROOF OF
COMMITMENT, plus an honest limit)*

So it is not that mechanical had no jobs. It is that I found out which of the two I would keep
doing on a Sunday."
]

#trick[
*Costly evidence is the whole answer.* Anyone can say they are interested. Only an interested
person has a Sunday spent on it, a course finished, a repository with commits over months. Bring
the cost, not the claim.
]

#ex(15, tier: 1, asked: "Wipro · pattern")[
"Why are you not going for higher studies, like an MTech or a masters abroad?"
]
#sol[
"I considered it and I decided against it for now, for one reason. When I look at the things I
learned fastest, all of them came from something being used and breaking -- the attendance tool
had three faculty using it and two real bugs, and I learned more from those two bugs than from
the whole course that year.

I want a few years of that kind of learning before I decide whether a masters would add
something. If I do go later, I would want to go knowing which specific area I want, rather than
going because I did not know what else to do.

I am not ruling it out, and I would not want to say otherwise. What I can say is that I am not
applying anywhere for it this year, and my plan for the next two years is work."
]

#note[This is the honest version. Do not promise "I will never do a masters" if that is untrue.
Promise what you can actually keep: your plan for the next two years. Interviewers respect a
bounded promise far more than an unbounded one they do not believe.]

// ==================================================================
#section[Question 8 — Family, hobbies, and the small talk]

Indian HR rounds often open with family background or hobbies. Foreign interviewers rarely ask
about family, and in some countries it is not allowed. Prepare a short, calm answer and move on.

#formulas(title: "Rules for small talk answers")[
*Family:* two sentences maximum. Who they are and one line about what you take from them. Never a
list of every relative. Never income or caste details.

*Hobbies:* name hobbies you can actually discuss for two minutes. If you say "reading", be ready
to name the last book you finished and say one true thing about it. If you cannot, do not say
"reading".

*Never* claim a hobby to sound impressive. "Chess" invites "what opening do you play?" from an
interviewer who plays.
]

#ex(16, tier: 1, asked: "TCS · pattern")[
"Tell me about your family background." Then: "What are your hobbies?"
]

#trap[
*Weak.* "My father is a bank employee, my mother is a housewife, I have one younger brother
studying in 10th standard, we are originally from Nashik but we shifted to Pune in 2011, my
uncle is also in the same field..." -- and 90 seconds are gone with nothing scored.

*Weak hobbies.* "Reading books, listening to music, and playing cricket." Then: "Which book did
you read last?" and a long silence.
]

#sol[
*Strong.*

"My father works in a bank and my mother runs a small tailoring business from home. The thing I
picked up from her is that she does her accounts every single evening, however small the day
was -- that is where my habit of writing things down comes from." *(Two sentences, then stop.)*

*Hobbies.* "I play badminton twice a week at the college court, and I have been slowly reading
through a book on how databases work -- I am about halfway, at the chapter on indexes, which is
what made me try adding one in my project. I am not a fast reader, so one technical book takes me
a few months."

That last answer is safe under follow-up, because every claim in it is small and true, and one of
them links straight back to her project.
]

#trick[
*Link one hobby to one project.* It makes the small talk earn its time and it gives the
interviewer a clean bridge into technical questions on your terms.
]

// ==================================================================
#section[Question 9 — Location, shift, travel and the "are you flexible" questions]

These are pure retention questions. The company has been burned by people who said yes and then
refused to move.

#formulas(title: "The honest-flexibility structure")[
*Answer the question directly first (yes / yes with a condition / no).* Then give the reason.
Then, if there is a real constraint, state it once, plainly.

*Do not say yes to something you will refuse later.* A withdrawn acceptance costs you the offer
*and* your college's relationship with that recruiter, which affects your juniors.
]

#ex(17, tier: 1, asked: "Accenture · pattern")[
"Are you willing to relocate anywhere in India? And are you comfortable with rotational night
shifts?"
]

#trap[
*Weak answer A.* "Yes sir, anything is fine, I am fully flexible, no problem at all." -- said by a
student who has already decided he will ask for Pune later. This is the answer that ends with a
rejected offer letter and a blacklisted college.

*Weak answer B.* "Actually I would prefer Pune because my family is here, and night shift is a
little difficult for me because of health reasons, and also I cannot travel much..." -- three
conditions, no yes anywhere, and the interviewer stops listening at the second one.
]

#sol[
*Strong answer (a genuine yes).*

"Yes to relocation, anywhere in India. I have thought about it concretely -- I have already
checked what a shared flat costs in Chennai and Hyderabad, and I have lived away from home for
two years in my hostel, so I know I can do it.

On night shifts: yes, for a rotation. I have done overnight work during our fest and I know I
function on it, though I am slower the next morning, so I would want to know the rotation
schedule in advance to plan around it. Is the rotation weekly or monthly here?"
]

#sol[
*Strong answer (a genuine constraint -- said properly).*

"Relocation: yes, anywhere in India.

On night shifts I will be straight with you rather than say yes and renegotiate later. I have a
medical condition that my doctor has asked me not to do rotating nights with. Fixed evening
shifts are fine, and I have done those. If this role is night-rotation only, I would rather know
now, and I would still be interested in other openings on your team."
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Order], [Conditions first, answer buried], [Direct answer first, then the reason],
  [Count], [Three vague constraints], [One real constraint, stated once],
  [Evidence], [None], [Hostel years, rent checked, a doctor's instruction],
  [Effect], [Reads as "will renegotiate later"], [Reads as "means what he says"],
  [Extra], [--], [Ends with a question -- turns it into a conversation],
)

#note[Saying no to one condition does not automatically end the process, especially if you say it
early and calmly. Saying yes falsely almost always ends it later, and it ends it worse.]

#tier-header(2)

#ex(18, tier: 2, asked: "DBS · pattern")[
"This role is based in Singapore. Do you have the right to work here, and what is your timeline?"
]
#sol[
Answer in three facts and nothing more. This is not a place for enthusiasm.

"I do not hold a work pass. I would need the company to sponsor an Employment Pass, and I
understand that means the role has to meet the qualifying salary and that the application takes
some weeks after an offer.

On timeline: my final semester ends in May and my degree certificate is usually issued in July.
I can start any time after May with a provisional certificate if that is acceptable, or after
July if the pass application needs the final one.

I have a valid passport with about eight years left, and no travel restrictions."
]

#trap[
*Never guess or overstate your immigration status.* Do not say "I think I am eligible" about a
pass you have not checked. Do not imply you hold a status you do not hold. This is one of the few
places where a wrong statement can void an offer after you have joined, and in some countries it
is a legal issue and not just an HR one. Say what you know. For anything else say: "I have not
confirmed that -- I would need to check the official source."
]

#subsection[What to actually know before a regional interview]

You are not expected to be an immigration expert. You are expected to have looked once.

#table(columns: 2, align: (left, left),
  [*Know this*], [*Why they ask*],
  [Whether the role sponsors, or requires existing status], [Half of applicants never checked],
  [Roughly how long sponsorship takes after an offer], [It decides your start date],
  [Your passport validity and any renewal needed], [A common silent blocker],
  [Your earliest honest start date, with reasons], [They are staffing a specific quarter],
  [Whether you need the final degree certificate or a provisional one works], [Onboarding rule],
  [That you will not ask them to bend a rule], [They cannot, and asking ends it],
)

// ==================================================================
#section[Question 10 — "Do you have any questions for us?"]

Saying "no sir, you have explained everything" is a small, real loss. Ask two or three. Write
them down beforehand -- it is fine to read from a notebook, and it looks prepared, not weak.

#formulas(title: "Ask about the work, the measurement, and the first year")[
*Good questions* are ones the interviewer can answer from their own experience, and that a
candidate who intends to do the job well would want to know.

*Bad questions* are ones you could have answered by reading their website, or that are really
about leaving (leave policy, work from home on day one) rather than about working.

Hold salary, notice period and bond details for the HR or offer stage, not the first technical
round. Chapter 6 covers exactly how and when to raise those.
]

#table(columns: 2, align: (left, left),
  [*Ask these*], [*Why it lands*],
  [What does the first three months look like for someone in this role?], [Shows you are planning to do the work],
  [How is someone in this role judged at the end of year one?], [Shows you want to be measured],
  [What is the thing new joiners here find hardest?], [Invites an honest answer and you learn a lot],
  [Who would I be asking when I am stuck in week two?], [Tests whether support exists],
  [What did the last person in this role move on to do?], [Reveals the real growth path],
  [Is this role on an existing system or a new one?], [Changes what you should prepare],
)

#trap[
*Do not ask, in a first round:* "What is the salary?", "How many leaves do I get?", "Can I work
from home?", "Is there a bond?", "How soon will I be promoted?", "What does your company do?"
The last one is fatal. The others are fair questions asked at the wrong time.
]

#ex(19, tier: 3, asked: "Microsoft · pattern")[
"Any questions for me?" -- last five minutes of a behavioural round.
]
#sol[
Two questions, and one follow-up on the answer. That last part is what separates a real question
from a prepared one.

"Two things.

First: when something goes wrong in production on your team, what does the next day look like?
I am asking because I want to know whether the focus is on the cause or on who did it."

*(They answer.)*

"That is useful -- you said you write a document afterwards. Who reads it? Is it only the team,
or does it go wider?"

"Second: if I joined, what would you want me to be able to do on my own by month six that I
cannot do now?"
]

#trick[
*Always follow up on their answer once.* Anyone can read a prepared question off a page. Reacting
to the answer proves you were listening, and listening is one of the five things being scored.]

// ==================================================================
#section[Question 11 — Money, bond and notice period: the short version]

Chapter 6 covers these in full. But they can appear in a first HR round, so you need a safe,
honest answer ready now. The rule is the same for all three: *do not improvise on money.*

#formulas(title: "Salary: the two-stage answer")[
*Stage 1 — deflect once, politely, and ask for their range.*
"I would like to understand the role a little more first. Do you have a band in mind for this
position?" Most companies do, and most will say it. Then you are negotiating against a real
number instead of a guess.

*Stage 2 — if they push, give a RANGE with a REASON, not a single number.*
The bottom of your range must be a number you would actually accept, because that is the number
you will get.

*How to build the range.* Two sources: (a) what your own college's placement record shows for
this company and role this year and last, (b) what public salary sites show for the same title
and city, taking the middle, not the top. Say the source out loud -- it turns a demand into a
fact.

*For a campus or mass-hiring offer the number is usually fixed.* There is no negotiation on a
standard fresher package, and pushing hard looks naive. Ask instead about what *is* variable:
the location, the project, the training track, the joining date.
]

#ex(20, tier: 1, asked: "Accenture · pattern")[
"What are your salary expectations?"
]

#trap[
*Weak answer A.* "Sir, as per company norms, whatever the company gives I am fine with it."
This hands away the entire negotiation. It also sounds like you have not valued your own work.

*Weak answer B.* "I am expecting 12 lakhs." -- said by a fresher with no reference point, for a
role whose band is 4.5 to 6. The number is not the problem. The absence of a reason is. It reads
as "he has no idea what this job is worth", which is itself a data point about judgement.
]

#sol[
*Strong answer (first round, no number yet).*

"I do not want to give a number before I understand the role properly -- the shift pattern and
the location both change what makes sense. Do you have a band for this position? I am happy to
tell you whether that works for me."
]

#sol[
*Strong answer (they insist).*

"For a fresher backend role in Pune, from my college's placement data for this role last year and
this year, and from public listings for the same title, the range I have been working with is
about 5 to 6.5 lakhs fixed. I would be comfortable inside that. If the role includes a night
rotation I would look at the upper half of it, because that is what the listings I saw reflect.

If the number for this batch is fixed, that is completely fine -- please tell me and I will not
push. I would then want to talk about the location and the project instead."
]

#table(columns: 3, align: (left, left, left),
  [*What*], [*Weak*], [*Strong*],
  [Anchor], [Given away, or invented], [A range with two named sources],
  [Floor], [Unstated -- so it becomes the lowest offer], [The bottom of the range is a real acceptance],
  [Tone], [Submissive or entitled], [Factual, and it names a reason for the upper half],
  [Exit], [None], [Explicitly accepts a fixed band without resentment],
)

#formulas(title: "Bond and service agreement: what to actually ask")[
Many Indian service companies attach a *service agreement* -- you agree to stay a fixed period
(often one to two years) or pay an amount if you leave early. It is a normal, legal commercial
term. It is not a trick. But you must know four things *before you sign*, and it is entirely
proper to ask them in the interview.

+ *How long* is the period, and when does it start -- the joining date, or the end of training?
+ *How much* is the amount, and is it a flat figure or does it reduce month by month?
+ *What triggers it* -- only resignation, or also being released, or failing training?
+ *Are original documents held?* A company asking to keep your original degree certificate is
  something to think very carefully about. A cheque or a signed undertaking is common; holding
  originals is a different matter.

*Ask all four in one calm question.* "Could you tell me about the service agreement -- the
duration, the amount, when the clock starts, and whether any original documents are held?"

*Then get it in writing.* Whatever you are told verbally, read the actual clause in the offer
letter. If the letter and the conversation differ, the letter wins. Ask for a copy before you
sign, and read the whole page. If you do not understand a clause, ask your placement officer --
that is literally their job.
]

#note[Signing a service agreement you intend to break is not a strategy, it is a debt. If the
amount is more than you could pay, treat it as a real constraint on your choice, not as a
formality. Decide before you sign, not after.]

#ex(21, tier: 1, asked: "Infosys · pattern")[
"Are you comfortable signing a two-year service agreement?"
]

#trap[
*Weak.* "Yes sir, no problem, I will sign anything." -- from someone who has not read it and who
will panic in month seven when a better offer arrives.
]

#sol[
*Strong.*

"In principle yes, and I would want to confirm three things before signing: the exact duration,
whether the clock starts at joining or after training, and the amount if it is broken.

I am asking because I would rather commit knowing the terms than sign and find out later. Two
years matches what I said earlier about wanting to own one system properly, so the period itself
is not the concern."
]

#formulas(title: "Notice period: the honest arithmetic")[
As a fresher your "notice" is usually your *joining date*, and that is decided by your exam and
result timeline. Be exact, not optimistic.

Write down and be ready to say, in one breath:
- Last exam date.
- Expected result date.
- Provisional certificate date, and degree certificate date.
- Whether you can join with a provisional certificate.
- Any period you are *not* available (a pre-booked family event).

If you are already working, the honest form is: "My notice period is 30 days as per my contract.
I can ask about a shorter release, but I cannot promise it, and I will not leave without serving
what I owe." An employer hearing that knows exactly how you will treat *them* on your way out.
]

#trap[
*Do not promise an impossible joining date to win the offer.* A missed joining date is a
cancelled offer at many companies, and your college's placement cell finds out. Say the real
date. If the real date is a problem for them, you want to know that now.
]

// ==================================================================
#section[Question 12 — The rapid-fire set]

These come fast, often at the end. Each needs a short answer, 20 to 40 seconds. Long answers here
hurt you.

#subsection[12a. "What do you know about our company?"]

#trap[*Weak.* "Your company is a leading IT services company founded in India with offices all
over the world and lakhs of employees." -- a Wikipedia first line, and it proves nothing.]

#sol[*Strong.* "Three things, and one of them is a question. You are primarily a services
business, so most engineers work inside a client's system rather than on your own product. Your
last annual report put the largest revenue share in banking and financial services. And the role
I applied for sits in application support, which is the maintenance side rather than new build.

What I could not find out from outside is how a fresher gets assigned to a domain -- is it
allocated, or is there any choice?"]

#note[Three facts and one honest gap. The gap makes it a conversation. It also proves the facts
were researched rather than recited, because a reciter would not know where the information
stopped.]

#subsection[12b. "Rate yourself out of 10 in your best skill."]

#trap[*Weak.* "9 out of 10 in Java." Followed by one question you cannot answer, and now the
number is the story instead of the skill. Equally weak: "5 or 6, sir" said about your own main
skill, which invites "then why did you apply?"]

#sol[*Strong.* "In Node and Express, 6. I can build and debug a REST API with a database, handle
async properly, and read someone else's code in it. What a higher number would need, and I do not
have yet, is production experience -- running it under load, and knowing what breaks at scale.
Where I have been weakest is testing, and that is what I have been fixing this semester."]

#trick[Give the number, then define the number. "6, and here is what 6 means and what 8 would
need." A defined 6 is far stronger than an undefended 9, because it proves you know the shape of
the skill above you.]

#subsection[12c. "What if you get a better offer after joining us?"]

#trap[*Weak.* "No sir, I will never leave your company, I will stay for my whole career." Nobody
believes this, and an unbelievable promise makes your other statements cheaper.]

#sol[*Strong.* "I am not going to say I will never move -- you would not believe me and it would
not be true. What I can commit to is this: I will not accept this offer and then not turn up, and
I will not leave inside my agreed period. Beyond that, I would want to be here as long as I am
learning at the rate I want, and I would tell my manager before I started looking rather than
after."]

#subsection[12d. "How do you handle pressure or a tight deadline?"]

#sol[*Strong.* "By cutting scope early rather than working faster at the end. In our fest project
we were two days from the event with the payment part unfinished. I proposed we ship with cash
only and a simple order list, and keep payments for after. It was less impressive, but it worked
for three days and 200 orders. I would rather deliver a smaller working thing on the date than a
bigger broken one."]

#note[This is a behavioural answer inside an HR question. Chapter 4 shows how to build these
properly with STAR. The point here: even a rapid-fire answer is better with one concrete example
than with three adjectives.]

#subsection[12e. "Are you comfortable working in any technology we assign?"]

#sol[*Strong.* "Yes, and I will tell you honestly what that costs. I am strongest in Node and SQL.
If you put me on a Java or a mainframe project I would be slow for the first two months and I
would need to be told that is expected. What I can show you is that I have picked up an unfamiliar
codebase before -- the attendance tool I inherited was in code I had not written, and it took me
two weeks of reading before I changed anything. So: yes to any technology, with the caveat that I
will ask a lot of questions in month one."]

#subsection[12f. "Do you have any other offers?"]

#formulas(title: "The rule: true, brief, no leverage games")[
If you have none: "No, this is my first process this season." That is fine. Freshers with no
offers are hired every day.

If you have one: say so simply, without naming a number and without threatening. "Yes, I have one
offer from another company in this same process. I have not accepted it. I am here because this
role is closer to backend work than that one is."

Never invent an offer to create pressure. Recruiters in the same city talk to each other, and
campus processes share information. If the bluff is checked, the offer is withdrawn.
]

#subsection[12g. "Can you join immediately?"]

#sol[*Strong.* "My last exam is on 28 May and results usually come in early July. I can join any
time after 1 June if a provisional certificate is acceptable for onboarding, and from mid-July if
you need the final degree certificate. If you need someone before June, I should say now that I
cannot do that."]

#subsection[12h. "Why have you applied for a non-technical role with a technical degree?" (or the
reverse)]

#sol[*Strong.* Same structure as the branch question: TRUE START, TURNING POINT, PROOF OF
COMMITMENT. "I took the degree because I was good at maths and it was the sensible option at 17.
The turn was in my third year when I ran registrations for our tech fest -- 400 people, and the
part I enjoyed was the coordination, not the website. Since then I have done two more organising
roles and a business communication course. My technical background is not wasted in this role
because I can talk to engineers without a translator."]

#trap[
*The rapid-fire trap: length.* Every answer in this section is 20 to 40 seconds. If you take 90
seconds on "rate yourself out of 10", the interviewer learns that you cannot judge what a
question is worth -- and that is a real mark against you, separate from the content.
]

// ==================================================================
#section[Delivery — the part nobody practises]

Content is most of the score, but delivery is the part that is visible in the first ten seconds.

#formulas(title: "Six fixable delivery habits")[
*1. Filler words.* "basically", "actually", "like", "you know", "so yeah". Fix: record 60
seconds, count them, then deliberately pause in silence instead. A silent pause sounds
thoughtful. "Basically" does not.

*2. Rising tone.* Ending every sentence as if it were a question makes true statements sound
uncertain. Fix: drop your pitch on the last two words of a sentence.

*3. The run-on.* Joining five sentences with "and". Fix: full stop, breathe, next sentence.

*4. Speed.* Nervous students speak at 180 words a minute. Fix: aim for 130. It will feel slow to
you and normal to them.

*5. Apologising.* "Sorry, I am not sure, maybe I am wrong, but..." said before a correct answer.
Fix: say the answer, then state the uncertainty once if it is real.

*6. Not stopping.* The worst habit. You finish a good answer, feel the silence, and start again --
and the second half undoes the first. Fix: finish, then stop. Let them talk.
]

#trap[
*The silence trap.* Some interviewers stay silent for a few seconds after you answer. Many
candidates panic and fill the gap, usually by weakening the answer they just gave. The silence is
often just the interviewer typing notes. Let it sit. If it goes past about five seconds, ask
"Would you like me to go deeper on any part of that?"
]

#subsection[On video calls]

#table(columns: 2, align: (left, left),
  [*Item*], [*What to do*],
  [Camera], [At eye level. Look at the lens when making your main point, not at your own face],
  [Light], [A window or lamp in front of you, never behind you],
  [Sound], [Wired earphones beat a laptop mic. Test with a recording, not with a friend],
  [Network], [Have your phone hotspot ready. Say so at the start: "If I drop, I will rejoin in a minute"],
  [Notes], [One page, on the wall behind the camera, big letters. Not a scrolling document],
  [Background], [Plain. Tell your family the time in advance],
  [Name], [Set your display name to your real full name, not a nickname],
)

// ==================================================================
#section[A full HR round, annotated]

Here is a short round end to end, with the interviewer's private note after each answer. The
student is the fresher from Example 4 -- no internship, 7.1 CGPA, one small project.

#formulas(title: "Transcript")[
*I:* "Hi Arun, tell me about yourself."

*A:* Gives the NOW-PATH-PROOF-POINT answer from Example 4. 70 seconds. Mentions the two bugs he
had to fix after release.
#h(1em) #text(fill: muted)[Note: speaks in paragraphs, not lists. Has shipped something. Says his
CGPA before I ask. Flag: no internship -- probe how he spends time.]

*I:* "You said a date shifted by a day. What exactly happened?"

*A:* "I stored the submission time as a local-time string. When a teacher marked something at
11:40 pm, the report grouped it into the next day. I changed the column to store UTC and
converted only when displaying. I also added one test with a 11:59 pm time, because that was the
case I kept getting wrong by hand."
#h(1em) #text(fill: muted)[Note: the project is real. He can describe a bug at the level of the
column. The test he added is the mature part.]

*I:* "Your CGPA is 7.1. What happened in second year?"

*A:* "Second year I did badly -- 6.4 overall, and I failed one paper in the fourth semester,
Discrete Mathematics, which I cleared on the next attempt. The honest reason is that I was not
attending and I had no study method. What changed was small: I started doing the previous year
papers four weeks before the exam instead of two days. Fifth semester was 7.6, sixth was 8.0."
#h(1em) #text(fill: muted)[Note: does not blame the college or a teacher. Names the failed paper
without being asked twice. Upward trend is real. Comfortable.]

*I:* "Why our company?"

*A:* Gives the FACT-FIT-FUTURE answer, quoting the JD's mention of application support.
#h(1em) #text(fill: muted)[Note: read the JD. Rare.]

*I:* "Any location preference?"

*A:* "No preference -- anywhere in India. I have been in a hostel for three years."
#h(1em) #text(fill: muted)[Note: direct answer, no negotiation. Good.]

*I:* "Questions for me?"

*A:* "Two. What does the first three months look like here for a fresher? And when someone breaks
something in their first month, what actually happens?"
#h(1em) #text(fill: muted)[Note: asked about the work and about failure, not about leave. Recommend
proceed.]
]

#note[Count what won that round. One shipped project. Two bugs he could describe precisely. An
honest CGPA story with numbers going up. Twenty minutes of reading their job description. None of
that required an internship, a top college, or perfect English.]

// ==================================================================
#section[Practice]

Do these with a recording. Writing them is 30 percent of the benefit; saying them out loud is the
other 70.

#practice(tier: 1, time: "90 minutes, spread over a week")[
+ Write your NOW sentence. 25 words maximum. Rewrite it three times, cutting one word each time.

+ List every project, course, job, volunteer role and college activity you have done. For each,
  write one sentence containing a number you can actually defend. Mark the ones where you had to
  guess -- those need the word "about".

+ Write your full NOW-PATH-PROOF-POINT introduction. Run the word count. Target 130--190 words.

+ Record it. Play it back. Count your filler words. Write the number down.

+ Record it again, with silence instead of fillers. Compare.

+ Write a strength using NAME-PROOF-USE. Then apply the test: "could someone bad at this job also
  claim it?" If yes, choose again.

+ Write a weakness using REAL-COST-FIX-EVIDENCE. The COST must be a real event with a real cost.
  If you cannot name one, the weakness you picked is not real.

+ Take one company you will actually apply to. Spend exactly 20 minutes on research. Write down
  three checkable facts. Then write FACT-FIT-FUTURE.

+ Apply the swap test: replace the company name with a competitor's. Does the answer still work?
  Fix it until it does not.

+ Write your five-year answer using DIRECTION-NEXT STEP-ANCHOR, with no job title in it.

+ Write your three questions to ask them. For each, write what a good answer and a bad answer
  from them would sound like.

+ Write the truthful answer to relocation and shift. If it is a yes, write the evidence. If it is
  a no, write the single-sentence version.

+ Build your salary range. Write the two sources you used and the bottom number. Then ask
  yourself in writing: "would I sign for the bottom number?" If no, the bottom is wrong.

+ Write the four bond questions as one sentence you can say calmly.

+ Write your joining-date paragraph with real dates: last exam, result, provisional certificate,
  degree certificate, earliest join.

+ Answer all eight rapid-fire questions in writing, each in 40 words or fewer.
]

#key[
1. Cut adjectives first, then any word that does not change meaning. "Highly motivated final-year
student" loses two words and no information.
2. Any project touched by a real user beats any project that was only demoed. Say how many users,
even if it is four.
3. Under 130 words means you have no PROOF yet. Over 190 means you have two PROOFs -- keep the
stronger one.
4. Most students find between 6 and 15 fillers per minute on the first recording. That is normal.
Three recordings usually halve it.
5. The second recording almost always sounds slower to you and better to a listener. Trust the
listener.
6. Good strengths are behaviours. Bad ones are adjectives. If it fits on a certificate, it is
probably an adjective.
7. If no cost comes to mind, you have chosen a fake weakness. Real ones hurt somewhere, and you
remember where.
8. Checkable facts come from: the job description, the engineering blog, recent news, the stack
in other open roles.
9. If the answer survives the swap test, it is about a company, not about *the* company. Add
something only they have.
10. Titles are promises the interviewer cannot make. Capabilities are things you can start
earning in week one.
11. A question whose answer you cannot evaluate is a question you do not really want answered.
12. The single-sentence "no" is stronger than a three-sentence one. State it once, then stop.
13. Whatever range you say, expect the bottom of it. If the bottom makes you unhappy, you have
written a wish, not a range.
14. "Could you tell me about the service agreement -- the duration, the amount, when the clock
starts, and whether any original documents are held?"
15. Use real dates, not "around June". "Around" is how joining dates get missed.
16. If any rapid-fire answer runs past 40 words, cut the second sentence first -- it is usually
the one repeating the first.
]

#practice(tier: 2, time: "60 minutes")[
+ Write a location reason for one regional market that does not mention salary, "abroad
  exposure", or settling. It must survive the question "why not the same work in India?"

+ Find the actual work-pass or visa page for that country, from the government site, not a blog.
  Write down three facts: who applies, roughly how long it takes, and what the company must do.

+ Write your three-fact availability answer: status, earliest start date, passport validity.

+ Rewrite your PROOF paragraph so that it names one cross-border or multi-market complication --
  a currency, a time zone, a language, or two people doing the same thing at once. Only if it is
  true for your project. If it is not, write instead one sentence on what you would expect to be
  hard, and label it clearly as an expectation.

+ Write two questions specific to working in a mixed-nationality team that are about the work,
  not about relocation benefits.
]

#key[
1. Durable reasons: the problem is here, the scale is here, the decisions are made here, I want a
team that does not share my assumptions. Fragile reasons: money, weather, permanent residence.
2. If a blog and the government page disagree, the government page is the fact. Quote the fact,
not the blog.
3. Three facts, said flatly, in under 30 seconds. No apology, no enthusiasm, no guessing.
4. If your project had none of these complications, saying so and describing what you *expect* is
honest and still earns credit. Inventing a multi-currency feature does not.
5. Examples: "When your team disagrees across three offices, how is it settled -- the call or the
document?" and "Which parts of the product change per country and which stay the same?"
]

#practice(tier: 3, time: "2 hours")[
+ Take your PROOF paragraph. Write the three "why?" questions an interviewer could ask about it.
  Answer all three in writing. If any answer is "I do not know", that is your study list.

+ Add to your PROOF one place where your first guess was wrong. It must be true. Write what
  changed your mind.

+ Write your "why us" for one product company using only facts you can cite -- a job
  description line, a blog post, a launch. Name your source for each.

+ Write your calibrated gap: one thing normal-for-your-stage that you have not done, in one
  sentence, with what you think transfers anyway.

+ Write a five-year answer that would still be true if this company's plans changed.

+ Do a 20-minute mock with a friend where their only job is to ask "why?" after every answer, five
  times. Note where you run out.
]

#key[
1. Three levels is the normal probing depth. Level one: what did you do. Level two: why that and
not the alternative. Level three: how did you know it worked.
2. Wrong first guesses make a story credible. A story where everything went right sounds
rehearsed, and it usually is.
3. If you cannot cite a source, it is not a fact, it is a vibe. Vibes fail the swap test.
4. Good: "I have never worked on a system with real users beyond a few hundred, so I expect my
instincts about performance to be wrong at scale -- what should transfer is the habit of
measuring first." Bad: admitting you cannot do the core job.
5. If your answer depends on their current roadmap, it breaks when the roadmap does. Anchor to
the kind of work instead.
6. Most people run out at level three. That is the level worth preparing.
]

// ==================================================================
#revision[
*The five private scores.* Can you speak clearly · is the resume true · will you join · will you
stay · are you easy to work with. Nothing else.

*The substitution rule.* Keep the structure. Replace every fact with your own real experience. If
a slot cannot be filled truthfully, the answer is not ready.

*Structures.*
#table(columns: 2, align: (left, left),
  [*Question*], [*Structure*],
  [Tell me about yourself], [NOW -- PATH -- PROOF -- POINT],
  [Strength], [NAME -- PROOF -- USE],
  [Weakness], [REAL -- COST -- FIX -- EVIDENCE],
  [Why us], [FACT -- FIT -- FUTURE],
  [Five years], [DIRECTION -- NEXT STEP -- ANCHOR],
  [Why hire you], [MATCH -- EDGE -- RISK],
  [Branch change], [TRUE START -- TURNING POINT -- PROOF OF COMMITMENT],
  [Relocation / shift], [Direct answer first, then one reason, then one constraint at most],
)

*Time budget.* 130 words per minute. Intro 60--90s. Strength or weakness 45--60s. Why us 45--60s.
Five years 40--50s. Behavioural story 90--120s.

*Three tests.*
- *Swap test* -- replace the company name. If it still works, it is not an answer.
- *Adjective test* -- could someone bad at this job claim your strength? Then choose again.
- *Cost test* -- does your weakness have a real event with a real cost? If not, it is fake.

*Money, bond, notice -- the safe defaults.*
- *Salary.* Deflect once and ask for their band. If pushed, give a range with two named sources.
  The bottom of your range is the number you will get.
- *Bond.* Ask four things: duration, when the clock starts, the amount, and whether originals are
  held. Then read the actual clause in the offer letter before signing.
- *Notice / joining.* Real dates only: last exam, result, provisional, degree, earliest join.
  Never promise a date you cannot keep.

*Always.* Hedge numbers you did not measure ("about 200"). Name your CGPA trend before they ask.
Read the job description before you write "why us". Ask two questions and follow up on one answer.

*Never.* Claim work you did not do. Say yes to a location or shift you will renegotiate. Guess
about a visa status. Fill a silence by weakening your own answer. Say "myself Meera".
]

]
