#import "../../shared/lib/style.typ": *

#chapter(num: 6, title: "Hard & Awkward Questions",
  tagline: "Salary, bonds, backlogs, gaps, rejections — the questions nobody prepares for")[

#section[Pattern in one page]

Every question in this chapter is a *risk question*. The interviewer is not curious about
your life. They are checking one thing: *if we hire this person, what could go wrong, and
how badly?*

That reframing changes your whole answer. You are not defending yourself. You are
removing a risk from their mind.

#formulas(title: "What each hard question is really asking")[
#table(columns: 2,
  align: (left, left),
  [*They ask*], [*They mean*],
  [“What is your expected salary?”], [Can we afford you, and will you leave in six months for 5% more?],
  [“Are you willing to sign a two-year bond?”], [Will you accept our training cost, or run?],
  [“You have a backlog.”], [Will you fail to graduate, or repeat this pattern under pressure?],
  [“There is a one-year gap here.”], [Is there something you are hiding?],
  [“Your CGPA is 6.4.”], [Can you learn, or did you stop trying?],
  [“You were rejected here last year.”], [Did anything change, or is this the same candidate?],
  [“What is your notice period?”], [When can the seat actually be filled?],
  [“Do you have other offers?”], [How fast must we move, and are you being honest with us?],
  [“Why should we not hire you?”], [Do you have self-knowledge, or only rehearsed lines?],
)
]

#subsection[Three rules that apply to every question in this chapter]

#formulas(title: "The three rules")[
*Rule 1 — Never lie. Not once, not slightly.*
A lie about a backlog, a CGPA, a current salary or a notice period is checkable at the
offer stage. Offers are withdrawn for this, and in some companies the candidate is
blacklisted. A weakness told honestly costs you far less than a lie discovered later.

*Rule 2 — Do not over-explain.*
The most common failure is not the fact; it is the four extra minutes spent apologising
for it. Say it once, briefly, then move to evidence. Length signals shame, and shame
signals that the thing is worse than it is.

*Rule 3 — Never apologise twice.*
One acknowledgement is maturity. Three is a request for reassurance, and the interviewer
is not there to reassure you.
]

#note[
Nothing in this chapter is a script. Every filled answer uses an invented person so that
you can see the shape of the reply. *You must put your own true facts into these
structures.* A memorised answer about someone else's backlog will not survive the question
"which subject was it?"
]

#section[The four-move structure]

Every awkward question in this chapter uses the same four moves. Learn the moves once and
you can answer a question you have never seen.

#formulas(title: "A · F · E · F")[
+ *ACKNOWLEDGE* — one short sentence. No flinching, no drama. "Yes, I have one backlog."
+ *FACT* — the plain, specific truth. Subject, year, number, reason. Ten to twenty words.
+ *EVIDENCE* — proof that it is handled or handled-in-progress. A date, a score, a
  certificate, a project, a habit you changed. *This is the part that scores.*
+ *FORWARD* — hand the conversation back. A question, or a bridge to what you want them
  to ask next.

*Time budget: about 45 seconds total.* If you are past 90 seconds you are pleading.
]

#diagram(height: 4.2cm, caption: "Most candidates spend all their time in the first two boxes. The marks are in the third.")[
  #dnode(0cm, 0.9cm, 3.4cm, 1.1cm, "ACKNOWLEDGE ~5 s")
  #darrow(3.4cm, 1.45cm, 4.2cm, 1.45cm)
  #dnode(4.2cm, 0.9cm, 3.4cm, 1.1cm, "FACT ~10 s")
  #darrow(7.6cm, 1.45cm, 8.4cm, 1.45cm)
  #dnode(8.4cm, 0.9cm, 3.4cm, 1.1cm, "EVIDENCE ~25 s", fill: rgb("#e8f2e8"))
  #darrow(11.8cm, 1.45cm, 12.6cm, 1.45cm)
  #dnode(12.6cm, 0.9cm, 3.2cm, 1.1cm, "FORWARD ~5 s")
  #place(dx: 8.4cm, dy: 2.2cm)[#text(size: 7.5pt, fill: rgb("#2f6b3f"))[the marks live here]]
  #place(dx: 0cm, dy: 2.2cm)[#text(size: 7.5pt, fill: rgb("#9b2226"))[most candidates spend 3 minutes here]]
]

#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Practise the ACKNOWLEDGE move alone. Say each of these out loud, once, flatly, with no
extra words. Then stop and count to three in silence.
]
#sol[
- "Yes, I have two backlogs; one is cleared."
- "Yes, there is a fourteen-month gap after my degree."
- "My CGPA is 6.4."
- "My notice period is 60 days."
- "Yes, I applied here last year and was not selected."

The exercise is the *silence afterwards*. Most candidates cannot hold it and start
explaining before being asked. The silence is where the interviewer decides you are calm.
Practise it with a timer until three seconds feels normal.
]

#ex(2, tier: 0, asked: "warm-up")[
Which of these is the EVIDENCE move, and why are the others not?

(a) "I really regret that semester." \
(b) "I cleared it in the December supplementary exam with 71%." \
(c) "It was not fully my fault, the lab timing clashed." \
(d) "I promise it will not happen again."
]
#sol[
*(b)* is the evidence. It has a date and a number, and a third party could verify it.

(a) is emotion. Emotion is not evidence, and repeated emotion reads as instability.
(c) is an excuse. Even true excuses shift responsibility, and shifting responsibility is
the exact risk they are screening for.
(d) is a promise about the future. Anyone can promise. Nobody can promise evidence.

*Test for your own evidence:* could a stranger check it? A mark sheet, a certificate date,
a repository, a score, an attendance record, a manager's name. If nobody can check it, it
is not yet evidence — go and create some.
]

#ex(3, tier: 0, asked: "warm-up")[
Fix this answer to "your CGPA is low": \
"Sir, actually my CGPA is low but I am very hardworking and I have strong practical
knowledge and I will prove myself if given a chance."
]
#sol[
Three problems: no fact, no evidence, and a plea at the end.

*Rewritten with A·F·E·F:*

*A:* "Yes, my CGPA is 6.4."

*F:* "It is low because my second and third semesters were poor — 5.1 and 5.4 — while I
was figuring out how to study at this level."

*E:* "My last four semesters were 7.6, 7.9, 8.1 and 8.3, so the trend is the honest
picture. Outside class I have shipped two projects and solved a bit over 300 practice
problems, and my last internship review is in my folder if that is useful."

*F:* "Would it help if I walked through the backend project, since that is the closest to
this role?"

*The plea is gone.* Nothing in the strong version asks for a chance. It presents a trend
and offers the next topic.
]

#tier-header(1)

#section[Salary — the real strategy]

This is the question students handle worst, and it is the one with money attached. Read
this section twice.

#subsection[First: understand what you are being offered]

Indian offers are quoted as *CTC* — cost to company. CTC is not your salary. Parts of it
never reach your bank account.

#formulas(title: "The five layers of an offer")[
+ *CTC* — everything the company spends on you, including things you never see.
+ *Variable / bonus* — paid only if targets are met. Assume *zero* when comparing offers
  until you know the historical payout.
+ *Fixed pay* — CTC minus variable. This is the real base.
+ *Gross cash* — fixed pay minus employer PF, gratuity, insurance premium. Money that
  actually flows.
+ *In-hand* — gross cash minus your own PF share, minus income tax. *This is what you
  live on.*

*The one question that cuts through all of it:* "What is the monthly in-hand for a new
joiner at this level, after standard deductions?"
]

#code(lang: "js", caption: "Two offers, and why the bigger CTC is the smaller pay cheque")[
```js
function inHand({ ctc, employerPF, gratuity, variablePct, insurance, taxRatePct }) {
  const variable = ctc * variablePct / 100;
  const fixed    = ctc - variable;
  // money that never reaches your bank account each year:
  const notCash  = employerPF + gratuity + insurance;
  const grossCash = fixed - notCash;
  const employeePF = employerPF;             // your own 12% share is also deducted
  const taxable   = grossCash - employeePF;
  const tax       = taxable * taxRatePct / 100;
  const yearly    = grossCash - employeePF - tax;
  return { fixed, variable, grossCash, yearly, monthly: Math.round(yearly / 12) };
}

const offerA = inHand({ ctc: 600000, employerPF: 21600, gratuity: 11538,
                        variablePct: 10, insurance: 8000, taxRatePct: 3 });
const offerB = inHand({ ctc: 550000, employerPF: 21600, gratuity: 10577,
                        variablePct: 0,  insurance: 5000, taxRatePct: 2 });

for (const [name, o] of [["Offer A  6.0 LPA", offerA], ["Offer B  5.5 LPA", offerB]]) {
  console.log(name, "-> fixed", o.fixed, "| variable", o.variable,
              "| take-home/month ~", o.monthly);
}
console.log("A minus B per month:", offerA.monthly - offerB.monthly);
```
]

#code(lang: "text", caption: "Output of `node s4.js`")[
```text
Offer A  6.0 LPA -> fixed 540000 | variable 60000 | take-home/month ~ 38579
Offer B  5.5 LPA -> fixed 550000 | variable 0 | take-home/month ~ 40117
A minus B per month: -1538
```
]

#trick[
Read that output again. The *6.0 LPA offer pays about 1,538 rupees a month less* than the
5.5 LPA offer, because 10% of it is variable and the deductions differ. Students accept
the bigger headline number every year and are confused in month one.

The numbers above are illustrative, and tax slabs and PF rules change — run the script
with *your* offer's real components. The lesson is the method, not my figures.
]

#trap[
Never compare two offers on CTC. Compare on *fixed pay* first, and on *in-hand* second. A
company that will not tell you the fixed-versus-variable split before you sign is telling
you something about how it will behave later — ask directly and in writing.
]

#subsection[Who says a number first?]

The old advice is "never say a number first". That advice is written for experienced
hires in countries with different norms. For a fresher in India it is often impractical:
many companies have a fixed band and will simply ask.

#formulas(title: "Decide by situation")[
*Campus or mass-hiring drive (TCS, Infosys, Wipro, Accenture, Capgemini):* the package is
usually fixed and public. Do not negotiate the base. Answer briefly and truthfully, and
put your energy into the role and the location instead.

*Off-campus fresher role at a product or mid-size company:* give a *researched range*,
not a point. Anchor at the level you can justify with evidence.

*Experienced hire:* try to get their band first. "What range has been budgeted for this
role?" is a normal, professional question. If they insist, give a range with a reason.

*Never* give a number you have not researched. "Whatever you think is appropriate" is the
weakest possible answer — it reads as no market awareness and no self-worth.
]

#ex(4, tier: 1, asked: "Infosys · pattern")[
"What are your salary expectations?" — asked to a final-year student in a mass-hiring
process where the package is standard.
]
#trap[
*WEAK.* "Sir, salary is not important for me at all. I just want to learn and grow. You
can give me whatever is the company standard, I have no expectations."
]
#sol[
*STRONG.* "I understand this role has a standard package, and I am comfortable with the
band you publish for this profile.

What matters more to me at this stage is which unit I land in — I would like to be on a
backend or data team, because that is where my project work is.

Is there any flexibility on which account or technology I am allocated to?"
]

#table(columns: 3,
  align: (left, left, left),
  [*Move*], [*Weak*], [*Strong*],
  [Honesty], [“Salary is not important” — almost never true.], [Accepts the band without pretending money is irrelevant.],
  [Self-worth], [“Whatever you give.”], [Neutral acceptance, no self-lowering.],
  [Use of the turn], [Wasted.], [Redirected to a thing that is actually negotiable — the team.],
  [Ending], [Passive.], [A question that keeps you in the conversation.],
)

#trick[
In a fixed-package process, the negotiable items are almost never the money. They are:
*role/technology allocation, base location, joining date, and shift.* Ask about those.
That is where your leverage actually exists, and asking makes you look experienced.
]

#ex(5, tier: 1, asked: "off-campus · pattern")[
"What is your expected CTC?" — off-campus, a 120-person product company, you are a fresher
with one internship.
]
#sol[
*Structure — five beats:*
+ *Anchor on research, not on need.* Never mention rent, loans or family expenses. Those
  are your business and they weaken you.
+ *Give a range, not a point.* Roughly 15–20% wide.
+ *Justify with one piece of evidence.*
+ *State flexibility on the right thing.*
+ *Hand it back.*

*Filled (substitute your own researched numbers for your city, year and role):*

"Based on what I have seen for backend roles at this size of company in Pune for someone
with an internship and shipped projects, I am looking at somewhere between 6.5 and 8
lakhs fixed.

I am saying fixed rather than CTC because I would rather compare on the base.

I put myself toward the middle of that because of the six-month internship where I owned
the payments retry service, rather than at the top.

I am flexible on the structure — if the base is a little lower and there is a clear
review at six or twelve months, that works for me.

Is that in line with the band you have for this role?"
]

#trap[
*Never justify a number with your expenses.* "I need at least 50,000 because of my
education loan" invites the reply "that is unfortunate, but our band is 38,000". Your
price comes from the market and your evidence, never from your costs.
]

#ex(6, tier: 1, asked: "off-campus · pattern")[
They reply: "That is above our band. We can offer 5.5 lakhs fixed."
]
#sol[
Three honest paths. Pick one — do not stumble between them.

*Path A — accept, and buy something else.*
"5.5 is below where I started, but I am genuinely interested in the work here. If the base
is fixed, could we look at a written six-month review with a defined band, or a one-time
joining amount? Either of those would make it work for me."

*Path B — a single, evidence-backed counter.*
"Could we look at 6.2? The gap between us is about 12%, and the reason I would ask for it
is the internship — I came into that team on a service that was already in production and
I owned the retry logic end to end. If 6.2 is impossible, tell me and I will give you a
straight answer on 5.5."

*Path C — decline cleanly.*
"Thank you for being direct. 5.5 is below what I can accept right now, so I do not want to
waste your time. If the band changes later I would be glad to talk again."

*Rules for all three:*
- *One counter, not three.* A second counter after they move damages trust badly.
- *Never bluff a competing offer you do not have.* It is checkable more often than you
  think, and the cost is total.
- *Get the final number in writing* before you stop interviewing elsewhere.
]

#note[
*Joining bonus, relocation allowance, review date, notice period, laptop, shift
allowance.* When base pay is frozen by a band, these are the levers that often are not.
Ask for one, not five.
]

#ex(7, tier: 1, asked: "lateral · pattern")[
"What is your current CTC?" — you are a candidate with two years of experience.
]
#sol[
Answer honestly. In India this is routinely verified against your salary slips and Form 16
at the offer stage, and inflating it is a common reason offers are cancelled.

*Filled:* "My current fixed is 7.2 lakhs, with a variable component of about 8% that paid
out fully last year.

For a change I am looking at the 10 to 11 range, because the role you have described has
on-call responsibility and direct ownership of a service, which my current role does not.

What band have you budgeted for this position?"

*Why it works:* the truth is stated without embarrassment, the ask is tied to a *difference
in the work*, not to a percentage rule, and the turn ends with their number.
]

#trap[
Inflating current salary by "just a little" is the single most common self-inflicted wound
in lateral hiring. Offer letters ask for documents. A 15% inflation discovered at document
check does not become a 15% smaller offer — it usually becomes no offer.
]

#section[Bonds and service agreements]

Many Indian service companies and some product companies ask freshers to sign a *service
agreement* — commonly one to two years, with a penalty if you leave early.

#formulas(title: "The seven questions to ask before you sign")[
+ *Exact duration*, and the date it starts — joining date or training completion?
+ *Exact penalty amount*, and whether it reduces month by month.
+ *Is an original document being held?* Degree certificates should never be handed over.
  Ask this explicitly, and get the answer in writing.
+ *What counts as "leaving"* — does dismissal or a medical exit trigger the penalty?
+ *Is the penalty waived* if the company relocates you, changes your role, or does not
  confirm you?
+ *Can it be bought out*, and by a future employer?
+ *Is the amount mentioned in the offer letter itself*, or only in a separate document you
  will see on day one?
]

#trap[
The most important of these is question three. Handing over original educational certificates is a
practice you should refuse. Companies that require it are relying on the difficulty of
replacing those documents rather than on the agreement itself. A copy, notarised if they
insist, is normal and reasonable; the original is not.
]

#note[
*A note on enforceability, in plain words, not as legal advice.* In India, an employment
bond is generally treated as a contract, and a company can usually claim *reasonable
compensation for actual losses* — chiefly the money genuinely spent training you. Courts
have been reluctant to force a person to keep working for someone, and penalty amounts
that look punitive rather than compensatory have been reduced or refused. In practice,
though, companies commonly withhold the *experience letter and relieving letter*, and the
absence of those causes real trouble with your next employer's background check. Treat the
bond as a serious commitment. *If a specific bond matters to your decision, get the actual
document read by a qualified lawyer — a book cannot do that for you.*
]

#subsection[Do the arithmetic before the emotion]

#code(lang: "js", caption: "Is the bonded offer actually better over the bond period?")[
```js
function compare({ months, bondedMonthly, freeMonthly, bondPenalty, raisePctPerYear }) {
  let bonded = 0, free = 0;
  for (let m = 0; m < months; m++) {
    const year = Math.floor(m / 12);
    bonded += bondedMonthly;                                  // bonded pay is usually flat
    free   += freeMonthly * Math.pow(1 + raisePctPerYear/100, year);
  }
  return {
    bondedTotal: Math.round(bonded),
    freeTotal: Math.round(free),
    breakEarly: Math.round(bonded) - bondPenalty,
  };
}
const r = compare({ months: 24, bondedMonthly: 33000, freeMonthly: 31000,
                    bondPenalty: 200000, raisePctPerYear: 15 });
console.log(r);
console.log("bonded job better over 24 months?", r.bondedTotal > r.freeTotal);
console.log("cost of walking out on day 1:", 200000);
```
]

#code(lang: "text", caption: "Output of `node s5.js`")[
```text
{ bondedTotal: 792000, freeTotal: 799800, breakEarly: 592000 }
bonded job better over 24 months? false
cost of walking out on day 1: 200000
```
]

*Read the result.* The bonded job pays 2,000 rupees a month more *today*, and still loses
over two years, because the unbonded job's 15% yearly raise compounds while the bonded pay
stays flat. Run this with your own numbers before you decide anything. If you have no
other offer, the bonded job is obviously better than no job — but know what you are
choosing.

#ex(8, tier: 1, asked: "TCS · pattern")[
"We require a two-year service agreement. Are you comfortable with that?"
]
#trap[
*WEAK — version 1 (fake enthusiasm).* "Yes sir, absolutely no problem, two years is
nothing, I am ready to sign anything, I will stay for ten years."

*WEAK — version 2 (negotiating in the interview).* "Actually is the bond really necessary?
My friend said these are not legally valid anyway. Can it be reduced to one year?"
]
#sol[
*STRONG.* "Yes, I am comfortable with a two-year commitment — I am looking for a first
role where I can go deep rather than move quickly, so two years matches what I want
anyway.

I would like to read the agreement before I sign, and I have three specific questions:
the penalty amount and whether it reduces over time, whether any original certificates are
held, and whether the two years start from joining or from the end of training.

Those are the details, not objections. Who should I ask about the document?"
]

#table(columns: 2,
  align: (left, left),
  [*What changed*], [*Why it matters*],
  [Commits first, asks second], [Removes the flight-risk worry immediately.],
  [Gives a genuine reason to stay two years], [A reason is believable; enthusiasm alone is not.],
  [Asks three precise questions], [Reads as an adult who reads documents.],
  [Says “those are details, not objections”], [Stops the interviewer hearing it as resistance.],
  [Does not argue legality], [Arguing enforceability in an interview reads as planning to break it.],
)

#trap[
Never say "bonds are not legally enforceable anyway". Even where the legal position is
genuinely complicated, saying it out loud tells the interviewer exactly one thing: this
person is already thinking about how to leave. The interview is not the place for that
argument. Read the document, ask your questions, and decide *before* you sign.
]

#section[Notice period]

#ex(9, tier: 1, asked: "lateral · pattern")[
"What is your notice period? When can you join?"
]
#sol[
*Structure:* `official period → what I will genuinely attempt → what I will not promise → their constraint?`

*Filled:* "My notice period is 60 days as per my contract.

I will ask for early release and I think 45 days is realistic, because my current project
has a natural handover point in mid-April. Some companies here also allow a buyout of the
remaining days, and I am open to that if it matters to you.

What I do not want to do is promise you 30 days and then miss it — I would rather commit
to a date I can hold.

What is the date you are trying to fill this seat by?"
]

#trap[
*The 15-day promise.* Candidates panic and promise a joining date they cannot meet,
believing the offer depends on it. Then they miss it. Missing your first committed date to
a new employer is the worst possible first impression, and the previous employer's
relieving letter is not under your control. Quote the contract, state the realistic best
case, and never promise a date that depends on someone else's goodwill.
]

#formulas(title: "Notice-period facts worth knowing")[
- The *buyout* is usually the basic pay for the unserved days, and sometimes the full CTC
  equivalent — ask which. Some new employers reimburse it; ask, but ask after the offer,
  not during the first interview.
- *Leave balance* sometimes offsets notice days and sometimes does not. It is written in
  your contract. Read it before you resign, not after.
- The *relieving letter* is what background checks want. Leaving without serving notice
  can mean no relieving letter, which can block a future offer years later.
- If you are in a probation period the notice is usually much shorter. Check the clause.
]

#section[Backlogs, gaps, and a low CGPA]

Three different facts, one structure. A·F·E·F, with the weight on E.

#ex(10, tier: 1, asked: "Wipro · pattern")[
"I see you have an active backlog."
]
#trap[
*WEAK.* "Yes ma'am, actually that subject was very tough and the professor was very
strict, most of my class also failed in it. But I have applied for the supplementary exam
and I am confident I will clear it definitely. It will not affect my work at all, I assure
you, I am very good in programming."
]
#sol[
*STRONG.*

*A:* "Yes — one active backlog, in Digital Electronics."

*F:* "I failed it in the fourth semester. The honest reason is that I put my time into a
hackathon and a course project that semester and I under-prepared for that paper."

*E:* "I sat the supplementary in December and missed by four marks, so I am re-attempting
in the May window. I have been doing past papers twice a week since January with a
classmate who cleared it. My other 34 papers are clear, and my last two semesters were 7.9
and 8.1, so the pattern is one bad decision rather than a general problem."

*F:* "If it helps, I can tell you my exact exam date and send the result the day it is
out."
]

#table(columns: 2,
  align: (left, left),
  [*What changed*], [*Effect*],
  [“The professor was strict” → “I under-prepared”], [Ownership. This is the single biggest swing in the answer.],
  [“Most of my class failed” removed], [Comparing yourself to failing peers never helps you.],
  [“I am confident I will clear” → a date and a method], [Confidence is not evidence. A study routine is.],
  [Adds “34 papers clear, last two semesters 7.9 and 8.1”], [Puts the one failure in proportion with numbers.],
  [Offers to send the result], [Converts an open risk into a tracked item.],
)

#trap[
If your company's offer says "must have zero active backlogs at joining", that is a hard
rule and no interview answer changes it. Ask directly: "Is a cleared backlog before
joining acceptable, or is the requirement zero backlogs throughout?" Knowing this early
saves you months of false hope.
]

#ex(11, tier: 1, asked: "Capgemini · pattern")[
"There is a gap of fourteen months after your graduation. What were you doing?"
]
#sol[
Gaps are common and are not, by themselves, a problem. *Unexplained* gaps are the problem.
Name the reason plainly, then show the gap was not empty.

*Three honest shapes, pick the true one:*

*Shape 1 — preparation.* "I spent that year preparing for the banking exams. I sat two,
cleared the first stage of one, and did not get through the final. At the end of it I
decided software was the right direction for me, and since then I have completed a backend
course and built two projects. I do not regret the year, but I am clear now."

*Shape 2 — family or health.* "My father was ill and I was the person at home who could
manage it. I did not work for about a year. That is settled now, and there is no ongoing
constraint on my availability. During the second half of it I studied part-time and
finished a database course." — *You are not obliged to give medical details, yours or your
family's.* One sentence, the current status, and move to evidence.

*Shape 3 — I did not find a job.* "Honestly, I was job-hunting and not getting calls. My
resume was weak and my practice was unstructured. What I did about it: I rebuilt my resume
around two real projects, started solving problems daily — about 300 since June — and
began contributing small fixes to an open-source tool, which is on my GitHub."

*The universal ending:* "That is why my recent work matters more than the gap — would you
like to go through the most recent project?"
]

#trick[
For any gap, prepare *one artefact with a date in it*: a certificate, a repository with
commit dates, a course completion, a freelance invoice, a volunteering letter. An artefact
turns "I was studying" into "I was studying, here is the proof". Prepare it now, not on
the day.
]

#ex(12, tier: 1, asked: "Accenture · pattern")[
"Your CGPA is 6.4. Our usual cut-off is 7."
]
#sol[
When a hard cut-off is stated, there are only two useful moves: find out whether it is
truly hard, and give the strongest honest counter-evidence.

*Filled:*

*A:* "Yes, 6.4 is below your cut-off."

*F:* "The damage is in semesters two and three, 5.1 and 5.4. I moved cities for college
and I handled it badly for a year."

*E:* "From the fourth semester my scores are 7.6, 7.9, 8.1 and 8.3 — the last two years
average about 8. If there is any weight given to a trend rather than an average, that is
my case. I also placed second in the college hackathon, and my internship at a small
analytics firm was extended from two months to four."

*F:* "Is the 7.0 a hard filter in your process, or does the panel have discretion? If it
is hard, I would rather know now."

*The last question is not weakness.* It is the most valuable thing in the answer, because
it either saves you three weeks or tells you the door is open.
]

#trap[
Never say "CGPA does not measure ability" or "marks are not everything". It may be your
honest belief, and it still reads as an attack on the person's filter. Show the trend.
Let the numbers argue for you.
]

#practice(tier: 1, time: "write each in 6 lines, then say it in 45 s")[
For each, write *your own true* A·F·E·F answer. Mark the four parts in the margin.

+ Your expected salary, in a fixed-package campus process.
+ Your expected salary, off-campus, with a researched range and one piece of evidence.
+ "We need a two-year service agreement." — plus your three document questions.
+ Your notice period, or your earliest realistic joining date.
+ Your lowest semester, and the trend since.
+ Any backlog, gap or break you have — with one artefact you could show.
+ "Why should we not hire you?"
]

#key[
Grade each answer on five points, one mark each:
(1) the ACKNOWLEDGE is one sentence and contains the fact;
(2) no excuse, no third party blamed;
(3) the EVIDENCE contains at least one number or date a stranger could verify;
(4) total length under 60 seconds spoken;
(5) it ends by handing the turn back.
Below 4 out of 5, rewrite before you move on. Anything untrue scores zero for the whole
answer, regardless of the other points.
]

#tier-header(2)

Regional questions. The interviewer is hiring into Singapore, Thailand, Indonesia or
Vietnam. Two new risks appear: *will this person actually be able to work here*, and *will
they leave after one year because they were homesick or underpaid for the city*.

#ex(13, tier: 2, asked: "Grab · pattern")[
"What are your salary expectations for this role, in Singapore dollars?"
]
#sol[
The failure here is arithmetic, not confidence: candidates convert their Indian salary
into the local currency and quote a number that is far below the local floor, or far
above.

*Structure:*
+ *Quote in the local currency and the local unit* (monthly is the norm in Singapore,
  not annual lakhs).
+ *Anchor on the local market*, never on a conversion from home.
+ *Name the cost-of-living items* you have accounted for — this shows you did real
  research and will not be shocked in month two.
+ *Ask about the package's local components.*

*Filled (numbers are illustrative — research the current market for your role and level):*

"I have been looking at monthly figures rather than converting from home, because a
straight conversion is meaningless once rent is included.

For a backend engineer at this level I have seen a range I would place myself in, and I am
comfortable discussing where in that range I sit based on your assessment.

I have budgeted for rent in a shared unit, CPF treatment for foreigners, and the
difference in how the 13th-month component is handled, so I am not going to come back in
three months and say I miscalculated.

Could you tell me what the package structure looks like — fixed, bonus, and whether
relocation and the pass application are covered?"
]

#trap[
*Never quote a low number hoping it makes you attractive.* In regional hiring, a figure far
below the local band signals that you do not understand the market, and it makes the
company worry you will resign as soon as you learn what colleagues earn. Under-pricing
loses offers here; it does not win them.
]

#ex(14, tier: 2, asked: "Shopee · pattern")[
"Do you have the right to work here? Are you aware of the visa process?"
]
#sol[
Be plain and factual. Never guess at immigration rules, and never claim a status you do
not have.

*Filled:* "No — I do not currently have work rights in Singapore. I would need the company
to sponsor an Employment Pass.

What I do know: the application is made by the employer, there is a qualifying salary
level that varies by age and sector, and the timeline is typically a number of weeks
rather than days. I have my degree certificate, transcripts and passport ready to speed
that up.

What I deliberately have not done is form an opinion about whether I would qualify — that
is your team's and the ministry's call, not mine.

Two practical questions: does your process sponsor at this level, and is there a
relocation allowance or a temporary accommodation period?"
]

#trick[
The sentence *"I deliberately have not formed an opinion about whether I would qualify"* is
strong. Immigration rules change, and a candidate who confidently quotes a qualifying
salary figure that changed last quarter looks careless. Show preparation, not false
expertise.
]

#ex(15, tier: 2, asked: "Agoda · pattern")[
"You have never lived outside India. What makes you think you would stay?"
]
#sol[
This is a retention-risk question and it is asked seriously. Relocating a person is
expensive, and a person who returns home in six months is a large loss.

*Do not* answer with enthusiasm alone. Answer with *evidence that you have thought
concretely about the difficult parts.*

*Filled:*

*A:* "It is a fair question — I have not lived abroad, so I cannot give you experience as
proof."

*F:* "What I can give you is what I have actually checked. I have spoken to two seniors
from my college who moved to Singapore and Bangkok, and I asked them specifically what
they found hardest. Both said the first three months, and the cost of the first month
before the first pay cheque."

*E:* "So I have planned for those: I have savings for about three months, I have looked at
shared accommodation near the office rather than assuming I would live alone, and I have
been working with a distributed team on an open-source project for seven months, which is
the closest thing I have to working across time zones and written-first communication.
Also, I eat alone and cook — a small thing, but it is the thing my senior said broke
people."

*F:* "The real answer to your question is that I want to work on a product used across
several countries, and that work is here rather than there."
]

#table(columns: 2,
  align: (left, left),
  [*What changed vs the usual answer*], [*Effect*],
  [Admits the lack of experience first], [Stops the interviewer discounting everything after it.],
  [Cites two named-source conversations], [Research, not enthusiasm.],
  [Concrete plan: savings, housing, food], [Shows the hard parts were considered, not skipped.],
  [Distributed open-source work as evidence], [The nearest true proxy for the actual skill needed.],
  [Ends with a work reason, not a lifestyle reason], [“I want to travel” is the answer that loses this question.],
)

#ex(16, tier: 2, asked: "DBS · pattern")[
"Our team works in English but most of the office speaks Mandarin or Thai socially. Is
that a concern for you?"
]
#sol[
*Filled:* "For the work itself, no — my written English is my strongest communication
skill, and I have been in a code-review-based workflow where almost everything is written.

Socially, I expect to be outside some conversations at first, and I would rather say that
honestly than claim it will not happen. My plan is simple and small: learn enough of the
language for greetings, food and basic courtesy in the first two months, because that is
what shows I am trying, and ask directly when a meeting slides into a language I do not
follow rather than pretending I understood.

The one thing I would ask the team for is that decisions made in a corridor conversation
get written down somewhere I can read. That is a reasonable ask in any language."
]

#trick[
That last request — *"decisions get written down"* — is a genuine remote-and-cross-culture
working practice, and asking for it politely marks you as someone who has worked in a real
team. Do not demand it. Ask for it.
]

#ex(17, tier: 2, asked: "SCB · pattern")[
"Why are you applying to Southeast Asia rather than staying in India or trying the US?"
]
#sol[
The risk being screened: *are we your second choice, and will you leave the moment
something else opens?*

*Filled:* "Three reasons, and I will give them in the honest order.

First, the work: the products here are built for several countries at once, with different
payment methods and languages in one codebase. That is a harder and more interesting
problem than the single-market products I have worked on.

Second, timing and reality: the route into this region is open to me now and clearly
defined, and I would rather build a career on a real path than wait for a lottery.

Third, distance: it is a five-hour flight home, which matters to me and to my family, and
I would rather tell you that than pretend it is irrelevant.

I am not going to claim I never considered anywhere else. I am telling you this is the
choice I have actually made and why it holds."
]

#trap[
Do not say "India has too much competition" or "salaries are low in India". Complaints
about what you are leaving make a weak case for what you are joining. Make the positive
case for the work.
]

#practice(tier: 2, time: "6 min each, written")[
+ Give a salary expectation in the local currency and monthly unit for a country you would
  actually move to. Show the three cost items you researched.
+ State your work-authorisation position in four sentences, with no guessing.
+ "What makes you think you would stay?" — with three concrete pieces of preparation.
+ "Why this region and not somewhere else?" — three reasons, honest order, no complaints
  about home.
+ You are asked to join in six weeks but your notice is 60 days. Write the reply.
]

#key[
Full marks require: (1) local currency, local unit, and at least three named living-cost
items; (2) no claimed knowledge of immigration thresholds; (3) at least two items of
preparation that cost you something real (savings, a conversation, a habit); (4) zero
sentences complaining about your home market; (5) a date you can actually hold, plus one
alternative you can offer, such as a buyout.
]

#tier-header(3)

Structured behavioural probing on the uncomfortable material. Expect follow-ups, and
expect the interviewer to stay on the topic longer than feels pleasant. That is
deliberate. Staying calm is part of the answer.

#ex(18, tier: 3, asked: "Amazon · pattern")[
"Tell me about a time you failed."
]
#sol[
The trap is choosing a fake failure ("I worked too hard"), or a failure with no
consequence. Choose a real one where *something was actually lost* and where *you caused
part of it.*

STAR, four parts labelled. *This example is invented — substitute your own real failure.*

*S — Situation.* "In my internship I owned a small script that reconciled payment records
against the vendor's daily file. It ran every morning at 6 am."

*T — Task.* "My task was to add a new vendor to it. I had two days, and I had done a
similar change before."

*A — Action.* "I added the new format and tested it on a sample file the vendor had sent
in the first week. It passed, and I shipped it on Thursday evening. What I did not do was
check that the sample matched what the vendor was *currently* sending — they had changed a
date format three weeks earlier. On Friday morning the job failed, and because the failure
was inside a try/catch that logged and continued — code I did not write but did not read
either — nobody saw it. It was found on Monday when the finance team's numbers did not
match. Three days of reconciliation were missing."

*R — Result.* "Nothing was lost permanently: we re-ran the job over the three days and the
records matched, so it cost the team about half a day. I told my mentor on Monday morning
before finance escalated, which he told me later was the part that mattered to him.

Two things changed in how I work. First, I never test against a sample that I did not pull
from the real source that week. Second, before I touch code, I read the error path, not
just the happy path — the try/catch that swallowed the error was the real reason a
one-hour bug became a three-day bug. I raised that separately and we made it alert."

*Why this scores:* a real cost, a clearly owned cause, an escalation done correctly, and
two changed behaviours — one specific to the bug, one general.
]

#trap[
*Failures that do not work as answers:* "I am a perfectionist", "I took on too much
work", a failure caused entirely by someone else, or a failure with no outcome at all. At
Tier 3 the interviewer will keep asking until they get a real one. Prepare a real one and
save everyone the time.
]

#ex(19, tier: 3, asked: "Amazon · pattern")[
Follow-up probing on the same failure. Four probes, which is normal at this tier.
]
#sol[
*Probe 1 — "Why did you not check the current file format?"*
"Because I treated the sample as the specification. It was in the ticket, it was labelled
with the vendor's name, and it passed. The real reason underneath that is time pressure —
I had two days and checking the live file meant asking someone for access. I chose the
faster path, and that was the decision that failed."

*Probe 2 — "You said the try/catch was not your code. Are you blaming the previous
author?"*
"No. The code was in the file I was editing, so it was mine to read. Whoever wrote it made
a reasonable choice for a different situation — they wanted a single bad row not to kill a
whole run. The mistake was that it did not distinguish a bad row from a broken format. I
should have read it before I shipped on top of it."

*Probe 3 — "What would you have done if the records had not been recoverable?"*
"Then the honest answer is that my half-day mistake becomes a real financial problem and I
would not be telling this story so calmly. What I would do is the same first step — tell
my mentor immediately, with the exact window affected and what is known versus unknown —
and then propose a manual reconciliation from the vendor's copies. I would also expect to
be part of a change that makes that data recoverable, because 'we were lucky' is not a
control."

*Probe 4 — "Has this happened again since?"*
"Not this failure. I did have a related near-miss two months later — I almost deployed a
change tested against a stale fixture. I caught it because the habit I described made me
go and pull the current file first, and the format had indeed changed again. So the habit
has been tested once and held once. I would not claim more than that."
]

#trick[
Probe 4's answer is a model. *"The habit has been tested once and held once. I would not
claim more than that."* Precise, honest, unbluffable. Interviewers at this tier are trained
to look for over-claiming, and calibrated language is scored positively.
]

#ex(20, tier: 3, asked: "Microsoft · pattern")[
"You applied to us last year and were rejected. Why should this time be different?"
]
#trap[
*WEAK.* "Last time I was very nervous and I could not perform. I actually knew the answers
but I blanked out. I think the interviewer was also in a hurry. This time I am much more
confident."
]
#sol[
*STRONG.*

*A:* "Yes — I interviewed for a similar role in August last year and did not clear the
second round."

*F:* "I know roughly why. I could not get past a brute-force solution on a string problem,
and when the interviewer hinted at preprocessing, I did not take the hint because I did
not understand it. The gap was that I had memorised patterns rather than understood why
they worked."

*E:* "What I did after that: I stopped doing new problems for six weeks and re-did forty
old ones, writing out the invariant for each one before coding. Since then I have solved
around 400 problems, but the measurable change is different — I now finish the hint-driven
part. I also asked two seniors to run mock interviews with me and specifically to give me
a hint mid-problem and see whether I used it. In the first three I did not. In the last
six I did.

I also shipped a project with a real cache in it, which is exactly the preprocessing idea I
could not see last year."

*F:* "So the honest claim is not that I am a different person; it is that the specific gap
that failed me has been worked on and tested. You will find out in the next round whether
that is true."
]

#table(columns: 2,
  align: (left, left),
  [*What changed*], [*Effect*],
  [“I blanked out” → the exact technical gap], [Shows you can diagnose yourself.],
  [Blame on the interviewer removed], [Blaming the panel ends the interview mentally.],
  [“More confident” → a measured change in behaviour], [Confidence is unverifiable; “6 of my last 9 mocks” is not.],
  [Modest final claim], [“You will find out in the next round” is calm and true.],
)

#ex(21, tier: 3, asked: "Goldman Sachs · pattern")[
"Do you have other offers? Where else are you interviewing?"
]
#sol[
The honest, useful answer depends on your actual situation, and all three versions below
are true statements of some real situation. *Use the one that is true for you.*

*If you have an offer:* "Yes. I have one written offer from a mid-size product company,
and I need to respond by the 28th. I would rather be straight with you about the date than
create pressure later. Where is your process likely to be by then?"

*If you are interviewing but have nothing:* "I am in process with two other companies, one
at final round. No offers yet. I am not going to name them, if that is alright — I would
not want them to hear about yours from me either."

*If you have nothing at all:* "No, nothing right now. I started applying recently and this
is one of the first processes I am in."

*Three rules:*
+ *Never invent an offer.* It is the most common lie in interviewing, and experienced
  interviewers ask one follow-up — "who is it with, and what did they offer?" — and
  hesitating there costs you the round.
+ *Never name the amount* of a competing offer unless you have decided to negotiate with
  it and can produce it in writing.
+ *Do give a real deadline* if you have one. Deadlines move processes; bluffs do not.
]

#trap[
Having no offers is not a weakness to hide. "No, nothing yet" said calmly is completely
normal and costs you nothing. The damage comes from a nervous, over-long answer that makes
the interviewer wonder what you are covering.
]

#ex(22, tier: 3, asked: "Uber · pattern")[
"Your last role lasted seven months. Why did you leave so quickly?"
]
#sol[
Short stints are a genuine risk signal. Your job is to show it was a *specific* situation
rather than *your pattern.*

*Structure:* `state the fact → give the real reason in one sentence, without attacking anyone → show what you did before leaving → show what you now check before joining.`

*Filled:* "Seven months, yes. I joined for a backend role, and after the first month I was
moved onto a support rotation for a legacy product because the team that owned it lost two
people. That was a real business need and I do not think anyone acted in bad faith.

Before I left I asked twice about returning to the original team — once informally at
three months, once in my written review at five. My manager was honest with me that the
rotation would last at least another year.

What I do differently now: I ask in the interview what the team's on-call and support load
is, what I would be doing in month one versus month six, and whether the role I am hired
for is the role that exists. So — what would I be doing in my first month here?"
]

#trick[
Ending a job-hopping answer with *the question you now ask* is the strongest available
move. It proves the lesson is real, and it hands them the question as evidence rather than
as a claim.
]

#ex(23, tier: 3, asked: "lateral · pattern")[
"You were laid off. Tell me about that."
]
#sol[
Being laid off is not a performance failure and should not be presented as one. Be brief,
factual and unembarrassed.

*Filled:* "Yes. In March the company cut about 18% of engineering, and my whole team —
eight people including the manager — was part of it. It was a cost decision about a
product line, not individual performance; my last review was 'exceeds' and I can share it.

I had six weeks of notice, and I used them to hand over my two services properly, which
mattered to me. Since then I have been interviewing and I have kept a small open-source
contribution going so I am not writing nothing for three months.

My former manager is happy to be a reference and I can give you his contact."

*Three things that carry the answer:* the *scale* of the cut (it happened to a group, not
to you alone), a *verifiable* performance record, and a *reference from the same manager.*
If any of those are true for you, say them.
]

#note[
If you were *dismissed for performance or conduct*, that is a different and harder
conversation, and the rules do not change: do not lie, and do not volunteer more detail
than the question asks. State it plainly, state what you understood the reason to be, state
what you changed, and do not criticise the employer. If there is an ongoing legal matter,
say only that you are not able to discuss the details. A short, calm, non-defensive answer
is the best available outcome, and it is a genuinely achievable one.
]

#ex(24, tier: 3, asked: "panel · pattern")[
"Are you planning to get married soon? Do you plan to have children in the next two years?"
]
#sol[
Questions about marriage, family plans, pregnancy, caste, religion, or a partner's job are
*not* job-relevant, and in many places asking them is improper or unlawful. You still have
to survive the moment. You have three options, and all three are legitimate.

*Option 1 — Answer the underlying business concern, not the personal question.* This is
usually the best move in the room.
"I think what you are checking is whether I will be available and committed through the
project cycle. On that: I am not planning any break, I am fully able to travel, and my
plan for this role is a multi-year one. Is there a specific commitment period you need me
to confirm?"

*Option 2 — Decline politely and move on.*
"I would rather keep my personal plans out of it, if that is alright — but on availability
and commitment, ask me anything."

*Option 3 — Answer it, if you genuinely do not mind.* Some candidates do not mind, and
that is a valid choice. It is *your* choice and nobody else's.

*What not to do:* do not argue about the legality of the question in the room. You will
not win the job by winning that argument. Note it, handle it, and afterwards decide
whether you want to work there — that information about the culture is worth having.
]

#trap[
If this happens, *write down the question and the date afterwards*. If you later want to
raise it with the company's HR, a recruiter, or a campus placement cell, the specific
wording matters far more than a general complaint. And weigh it honestly in your own
decision: how a company screens is a preview of how it manages.
]

#ex(25, tier: 3, asked: "Google · pattern")[
"Why should we not hire you?"
]
#sol[
A self-awareness probe. The failure modes are the humble-brag ("I care too much") and
genuine self-destruction ("I am bad at coding").

*Structure:* `one real limitation that is true and survivable → the concrete cost it has had → what you do about it → the condition under which it would genuinely be a problem here.` That last clause is what separates a Tier-3 answer.

*Filled:* "If your team needs someone productive in a large existing codebase in week one,
I am the wrong hire. My experience is on small codebases I helped start, and the one time
I joined a big existing service I was slow for about three weeks — I kept reading whole
files instead of following one request path through.

What I do about it now: I start by tracing a single request end to end and writing the
path down, rather than reading broadly. That cut my ramp-up on the last project to about
four days.

So the honest condition is this: if this role needs independent output in a mature
codebase inside two weeks, weigh that. If the first month has any onboarding at all, it is
not a real risk."
]

#table(columns: 2,
  align: (left, left),
  [*What changed vs a normal “weakness” answer*], [*Effect*],
  [A limitation that could actually cost them], [Answers the question honestly instead of dodging it.],
  [A measured past cost: “slow for three weeks”], [Specific, so it reads as true.],
  [A method, plus a measured improvement], [Shows the weakness is being worked, not narrated.],
  [Names the exact condition where it matters], [Treats the interviewer as someone making a decision.],
)

#section[The other "will you leave us" questions]

Several questions look different but are the same worry underneath: *this person's real
plan is somewhere else.* The answer shape is always the same — do not deny the other
interest if it is real; show why *this* is the choice, and give it a horizon.

#tier-header(1)

#ex(26, tier: 1, asked: "TCS · pattern")[
"You studied Mechanical Engineering. Why are you applying for a software role?"
]
#trap[
*WEAK.* "Sir, actually there are no jobs in the core mechanical field nowadays and the
salary is also very less, so that is why I am shifting to IT. Anyway, coding can be learned
by anyone."
]
#sol[
*STRONG.*

*A:* "Yes, my degree is Mechanical and I am applying for software. It is a real switch and
I will not pretend otherwise."

*F:* "It started in my second year with a MATLAB assignment for a heat-transfer problem. I
found that I enjoyed the part where I was writing the solver far more than the part where I
was analysing the result, and that did not go away."

*E:* "So I did something about it over two years rather than at the last minute: a
data-structures course I finished in my third year, about 300 practice problems, a
final-year project where I wrote the entire sensor-logging backend while my teammates did
the mechanical design, and one internship at a small firm doing Python automation. My
mechanical background is not wasted either — the logging project needed me to understand
what the sensor data actually meant, and that is why the validation rules in it are right."

*F:* "The reason I am comfortable saying this is a real switch and not a fallback is that
it cost me two years of evenings. Would it help if I went through the logging project?"
]

#table(columns: 2,
  align: (left, left),
  [*What changed*], [*Effect*],
  [“No jobs in core” → a specific moment of interest], [Turns a push into a pull. Pulls are believable.],
  [Adds a two-year trail with dates], [The switch is demonstrated, not announced.],
  [Connects the old degree to the new work], [Makes the background an asset, not a scar.],
  [Removes “coding can be learned by anyone”], [That sentence insults the job you are asking for.],
)

#ex(27, tier: 1, asked: "Wipro · pattern")[
"Are you planning to do an MS, or prepare for GATE or a government exam?"
]
#sol[
There are only two honest answers, and both are survivable. The unsurvivable one is a lie,
because you will resign in eight months and everyone will remember.

*If you are not planning it:* "No. I considered GATE in my third year and decided against
it — I want to work on real systems now, and if I ever do a master's it would be much later
and part-time, because I would want a work problem to take into it. My plan for the next
few years is this kind of role."

*If you are genuinely considering it:* "I will be straight with you. I have thought about a
master's in two or three years, but I have not applied anywhere, I am not preparing for any
exam right now, and I am not going to make a decision about it before I have a couple of
years of real work. If I ever do decide, you will hear it from me with proper notice rather
than as a surprise."

*Why the second one does not sink you:* it is what a large share of engineers actually
think, the interviewer knows it, and the promise of notice is the thing they actually want.
What sinks candidates is a confident "never" followed by a resignation letter next spring.
]

#trap[
Some companies will genuinely reject a candidate who mentions future higher studies. That
is their right, and you cannot control it. What you can control is that you did not lie to
get a job you would leave in a year — which, apart from being the right thing, is also the
version where nobody's reference is burned.
]

#ex(28, tier: 1, asked: "Cognizant · pattern")[
"You have eleven certificates on your resume but no work experience. What does that tell
me?"
]
#sol[
This is a sharp question and it is fair. A long certificate list can read as collecting
rather than building.

*Filled:* "Fairly, it tells you I have spent more time consuming courses than shipping
things. That is a real criticism and it is why I stopped.

Of those eleven, three produced something: the backend course, where the final project is
the meal-counting app on my resume; the SQL one, which is where I learned the indexing that
took my report from 4.1 seconds to 0.2; and the Linux one, which is why I can debug on the
server instead of only on my laptop. The other eight are, honestly, watched-and-forgotten,
and I should probably cut them from the page.

Since January I have changed the ratio: no new courses, two projects and daily practice
instead. Would you like the three that produced something, or should I just walk through
the project?"

*The move that scores:* agreeing with the criticism, then separating the small real part
from the noise, and offering to trim your own resume in front of them. That is the opposite
of defensiveness and it is very hard to argue with.
]

#section[Location, shift and on-call]

#ex(29, tier: 1, asked: "Infosys · pattern")[
"Are you willing to relocate anywhere in India, and to work in night shifts?"
]
#sol[
*Answer truthfully.* A false yes gets discovered at allocation, and refusing an allocation
after joining is far more damaging than a qualified yes now.

*Structure:* `a clear yes to what you can truly do → the single genuine constraint, if any → the reason, stated once → what you can offer instead.`

*Filled, unconstrained:* "Yes to relocation — I have no constraint on the city, and I would
prefer Hyderabad or Pune if there is a choice, but I am not making it a condition. Night
shifts are fine; I have done a rotating schedule during my internship and I know what it
costs me, so I am not agreeing to it blind."

*Filled, with a real constraint:* "Relocation anywhere in India, yes. On night shifts I
want to be accurate: I can do a rotation, and I have done one. What I cannot commit to is a
permanent night shift for more than a few months, because I am the only person at home for
my mother's medical appointments. I would rather tell you now than accept and ask for a
change in month three. If the role needs permanent nights, tell me and I will step back
from it."

*Why the second version is strong:* the constraint is named once, the reason is given once
without a plea, and the candidate offers to withdraw. That last offer is what makes the
constraint read as honesty rather than as negotiation.
]

#note[
*On-call is worth asking about, in every role.* Ask: how often is the rotation, what is the
expected response time, how many pages came in last month, and is it compensated? These are
normal questions, the answers vary enormously, and a team with a healthy on-call will answer
them happily.
]

#tier-header(2)

#ex(30, tier: 2, asked: "Sea / Shopee · pattern")[
"We would hire you on a local contract, not on expatriate terms. There is no housing
allowance and no annual flight home. Is that acceptable?"
]
#sol[
This is a real and common situation for junior regional hires, and candidates often either
accept without understanding it or react with offence. Do neither.

*Structure:* `confirm you understand what a local contract means → state the two or three items you need to check → ask about the items that often do exist → give a clear conditional answer.`

*Filled:* "I understand — a local contract means local salary, local benefits and local tax
treatment, with no relocation package attached to it.

Two things I would want to check before answering properly: the one-time costs of the move,
which for me are the flight, the deposit on a room, and the first month before the first
pay cheque; and whether the pass application fee and any medical check are covered by the
company, since I believe those are usually the employer's cost.

I am not asking for housing or annual flights. I am asking whether there is any one-time
joining support, because that is the part I cannot spread over the year.

If the answer is no on all of it, the offer can still work for me — I have savings for
about three months — but I would want the base to reflect the fact that I am carrying the
move myself."
]

#table(columns: 2,
  align: (left, left),
  [*Move*], [*Why it works*],
  [Restates the terms accurately], [Shows you know what you are being offered.],
  [Asks about one-time costs, not ongoing perks], [A modest, specific, hard-to-refuse ask.],
  [Explicitly drops housing and flights], [Removes the impression that you expected expat terms.],
  [Gives a conditional yes with a reason], [Keeps the offer alive and still argues for the base.],
)

#trick[
"One-time costs" is the right frame for any relocation conversation at junior level.
Ongoing allowances belong to senior transfers and are rarely available to you. A joining
amount, a flight, or two weeks of temporary accommodation are small numbers for the company
and large ones for you — which is exactly what makes them the right things to ask for.
]

#tier-header(3)

#section[Stress tactics, and how to stay in the chair]

Some interviewers apply pressure deliberately. Some are simply blunt, or tired, or running
late. You cannot tell the difference from inside the room, and the correct response is the
same either way.

#formulas(title: "The four pressure moves and the reply to each")[
*1. The interruption.* You are cut off mid-sentence, repeatedly.
*Reply:* stop immediately, answer what was asked, and shorten every subsequent answer.
Being interrupted usually means you are too long, not that they are rude.

*2. "That is wrong."* Said flatly, with no explanation.
*Reply:* "Let me check my reasoning" — then re-derive out loud from the start. If you find
the error, say what it was. If you do not, say: "I still get the same thing. Where do you
see it going wrong?" Never simply flip your answer because they frowned.

*3. The long silence.* You finish, and they say nothing for eight seconds.
*Reply:* say nothing. This is the most common trap and the most common failure. Candidates
fill the silence by weakening a good answer or inventing an extra claim. Let it be quiet.

*4. The escalating "why".* Four or five "why"s on one thread.
*Reply:* keep going honestly until you reach the edge, then name the edge: "That is as far
as I have actually verified." The escalation is *supposed* to reach your limit. Finding it
is the point of the exercise, not a failure of it.
]

#ex(31, tier: 3, asked: "stress · pattern")[
Mid-answer, the interviewer says: "Honestly, that sounds like a very basic project. Do you
have anything harder?"
]
#trap[
*WEAK — version 1 (collapse).* "Sorry sir, yes it is basic, I know it is not a big project,
maybe I should have built something bigger, I am still learning…"

*WEAK — version 2 (defensive).* "It is not basic at all. It has authentication, a database,
deployment, cron jobs, a full REST API and a report module."
]
#sol[
*STRONG.* "It is a small project, yes — 78 users and four tables. I would not call it hard
in scope.

The part I found hard was narrower: two counts were wrong in week two, and the cause turned
out to be duplicate rows from a double tap rather than the caching problem I spent an
evening chasing. Fixing it properly meant understanding the difference between a unique
constraint and an idempotent write, and I got that wrong once before I got it right.

If you want something harder in scope, the honest answer is that I have not built anything
larger — my other work is practice problems, around 400 of them. If it is useful I can take
you through how I would extend this one to 40 hostels, which is where the modelling starts
to get interesting."
]

#table(columns: 2,
  align: (left, left),
  [*What changed*], [*Effect*],
  [Agrees with the true part of the criticism], [Removes the argument. You cannot be pushed off a position you already conceded.],
  [Redefines “hard” from scope to a specific problem], [Legitimate, and puts you back on your strong ground.],
  [Admits having nothing larger], [Truthful, and far safer than inflating.],
  [Offers the extension question], [Turns an attack into your best available topic.],
  [No apology anywhere], [Conceding a fact is not apologising for existing.],
)

#ex(32, tier: 3, asked: "Amazon · pattern")[
"Tell me about a time you disagreed with your manager — and lost."
]
#sol[
The "and lost" is the whole question. Stories where you were right and eventually won are
common and score little. STAR, four parts labelled. *Substitute your own real disagreement.*

*S — Situation.* "In my internship I wanted to add a database constraint to stop a
duplicate row class of bug that had already caused two incidents. My mentor wanted to fix it
in the application code instead, in that sprint, and add the constraint later."

*T — Task.* "I thought the constraint was the real fix and the code check was the weak one,
and I had to decide how hard to push and when to stop."

*A — Action.* "I made the case once, properly: I wrote a short note with the two incident
dates, what the code-level check would not catch — a second writer or a script — and how
long the migration would take. I asked for fifteen minutes to talk it through rather than
arguing in the pull request comments. He listened and then explained the thing I did not
know: the table was being written to by an older service outside our team, and adding a
constraint without coordinating with that team risked breaking their writes in production.
I had been thinking about correctness only, and he was thinking about a dependency I could
not see.

So I dropped it, and I implemented his version properly rather than half-heartedly — that
part mattered to me. I also wrote the constraint work up as a ticket with the coordination
step in it."

*R — Result.* "The code fix held for the rest of my internship. The ticket was picked up
about two months after I left and the constraint went in with the other team involved.

What I took from it: I had treated my disagreement as a technical argument when the missing
piece was context I did not have. Now, before I push on a decision a second time, I ask
'what do you know about this that I do not?' — which is a faster way to find the missing
piece than being right about the data model."
]

#trick[
The strongest element above is *"I implemented his version properly rather than
half-heartedly."* Interviewers at this tier are explicitly listening for whether you can
commit to a decision you argued against. It is a named expectation in several companies'
behavioural frameworks, and most candidates never say it.
]

#section[Background verification: what actually gets checked]

Every honest answer in this chapter is also the practical one, because most of it is
verified after the offer.

#formulas(title: "What a typical background check looks at")[
+ *Education:* degree, dates, and often the final result, checked with the university or a
  verification agency. Backlogs and year gaps appear here.
+ *Employment:* joining and leaving dates, designation, and sometimes salary, checked with
  the previous employer's HR. This is where an inflated current CTC is found.
+ *Relieving letter:* whether you left properly. Leaving without serving notice can show up
  as "not eligible for rehire".
+ *Identity and address*, and in some sectors a criminal record check.
+ *References:* usually a former manager, sometimes only confirming the basic facts.

*The two facts worth remembering:*
- Verification usually happens *after* you have resigned from your current job. A
  discrepancy found then is the worst possible timing, which is why people who inflate get
  hurt so badly.
- A disclosed problem is almost always survivable. An *undisclosed* one that surfaces in
  verification is usually not, because it is then a question of honesty rather than of a
  backlog or a date.
]

#trap[
Common small lies with large consequences: rounding a 6.4 CGPA to "about 7", moving a
leaving date by two months to hide a gap, describing a three-month internship as six, and
listing a certification you started but did not finish. Each of these is checkable, each is
found, and each converts a minor weakness into a disqualifying integrity finding. Fix the
resume instead.
]

#section[The offer-stage questions nobody teaches]

#formulas(title: "Ask these before you accept anything — politely, and by email")[
+ "Could I have the offer with the *fixed* and *variable* split written out?"
+ "What was the *actual* variable payout for this level last year?"
+ "Is there a service agreement, and can I see the document before I sign the offer?"
+ "Are any *original documents* required at joining?"
+ "What is the base *location*, and is it subject to change?"
+ "What is the shift, and is there *on-call*? Is it compensated?"
+ "Is the joining date firm? What has the recent gap between offer and joining been?"
+ "Who would I report to, and can I speak to someone on the team for fifteen minutes?"

*Send this as one short, polite email, not as eight separate messages.* Nobody minds a
candidate who reads carefully. Everybody minds a candidate who drips questions for a week.
]

#subsection[The uncomfortable one: reneging on an accepted offer]

You may end up with a better offer after accepting one. Here is the honest position, not a
comfortable one.

#formulas(title: "What is actually true about backing out")[
*It is not usually illegal* to decline a job you accepted before joining, but it is not
free either. Real costs: the company may blacklist you and, in campus hiring, your college
may bar you from further drives. Recruiters and hiring managers move between companies and
remember names.

*What reduces the damage:*
- *Decide fast.* Withdrawing in week one is a small problem. Withdrawing the night before
  joining is a large one.
- *Tell them by phone, then in writing.* Not by disappearing. Disappearing is what people
  remember.
- *Do not explain at length or invent a family emergency.* "I have accepted another role
  that is a better fit for my career, and I am sorry for the disruption" is enough.
- *If a service agreement was already signed and training was already given, expect a real
  claim* and read what you signed.

*The genuine way to avoid the situation:* do not accept an offer as insurance while you
keep interviewing. Ask instead for more time — "could I have until the 28th?" — which is a
normal request that is often granted. An honest deadline request costs you far less than a
retracted acceptance.
]

#practice(tier: 3, time: "with a partner, 40 min, they must ask 3 follow-ups each")[
+ A real failure of yours, in STAR with the four parts labelled, where something was
  actually lost. Then survive three probes on *your* share of the cause.
+ A rejection or a setback you had, and the *specific* gap, plus how you measured the fix.
+ "Do you have other offers?" — answer truthfully for your real situation right now.
+ A short stint, a gap or a break in your own history, ending with the question you now
  ask employers because of it.
+ "Why should we not hire you?" — one real limitation, its measured cost, your method, and
  the condition where it would genuinely matter.
+ An improper personal question, handled with Option 1 — redirect to the business concern.
+ You accepted an offer on Monday and a better one arrives on Friday. Say out loud exactly
  what you will do.
+ "That sounds like a very basic project. Do you have anything harder?" — concede the true
  part, redefine hard, and offer your strongest topic. No apology.
+ A disagreement with a senior where *you lost*, in STAR, ending with what you did after
  the decision went against you.
+ "Are you planning higher studies?" — answer with whichever of the two honest versions is
  true for you, and include the notice promise.
+ Have your partner interrupt you mid-answer twice and then stay silent for ten seconds
  after you finish. Your job: shorten, and do not fill the silence.
]

#key[
Score 0/1/2 per question as in Chapter 5. Additional failing conditions, which score zero
regardless of delivery:
any statement you are not certain is true; blaming a named person for a failure; an
invented competing offer; a promised joining date that depends on someone else's goodwill;
arguing with the interviewer about a question's fairness in the room.

Target before a Tier-3 interview: 15 out of 18, with no zeros on questions 1, 5 and 9 —
those three are the ones that are always asked.

*Question 11 has no marks, only a pass or fail:* you pass if you shortened your answers
after the interruptions and said nothing during the silence. Most people fail this the
first three times they try it. Keep doing it until you pass twice in a row.
]

#revision[
*Every hard question is a risk question.* Answer by removing the risk, not by defending
yourself.

*The three rules:* never lie, never over-explain, never apologise twice.

*A · F · E · F* — Acknowledge (5 s) · Fact (10 s) · Evidence (25 s) · Forward (5 s). Under
60 seconds total. The marks are in the evidence.

*Evidence test:* could a stranger verify it? A date, a score, a certificate, a repository,
a manager's name. Emotion, excuses and promises are not evidence.

*Salary:* CTC is not pay. Compare *fixed* first, *in-hand* second. Ask "what is the monthly
in-hand for a new joiner at this level?" A bigger CTC with a variable component can pay
less every month — run the numbers.

*Never justify a number with your expenses.* Justify it with the market and your evidence.
One counter, not three. Nothing is real until it is in writing.

*Fixed-band process?* The negotiable items are team, location, joining date and shift, not
money.

*Bonds:* ask duration, penalty and whether it reduces, original documents, what counts as
leaving, buyout, and whether it is in the offer letter. Never hand over original
certificates. Never argue enforceability in the room. Have a lawyer read anything that
matters.

*Notice period:* quote the contract, offer a realistic best case and a buyout, never
promise a date that depends on someone else.

*Backlog / gap / low CGPA:* own the cause in your own words, then show the trend with
numbers and one artefact that has a date in it. Never blame a professor, a paper, or your
class.

*Regional roles:* quote local currency in local units, research three living costs, never
guess immigration thresholds, never complain about your home market, and prove you have
thought about the hard first three months.

*Failure stories* need a real cost, your own share of the cause, correct escalation, and
two changed behaviours. Calibrated language — "tested once, held once" — beats confident
claims.

*Other offers:* tell the truth, give a real deadline if you have one, never invent one.

*Improper personal questions:* redirect to the business concern, or decline politely. Do
not argue in the room. Write it down afterwards and weigh it in your decision.

*Every filled answer in this chapter is invented to show the shape. Put your own true
facts in. A borrowed story dies on the first follow-up.*
]

]
