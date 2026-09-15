#import "../../shared/lib/style.typ": *

#pagebreak(weak: true)

#toc-entry("Appendix · Last-week quick reference")

#block(width: 100%, inset: (bottom: 10pt))[
  #text(size: 9pt, fill: muted, weight: "bold", tracking: 1.5pt)[APPENDIX]
  #v(-4pt)
  #text(size: 22pt, weight: "bold")[Last-week quick reference]
  #v(-3pt)
  #text(size: 10pt, fill: muted, style: "italic")[
    Every structure in this book on a few pages, plus the question bank and the checklist
    for the morning of.
  ]
]
#line(length: 100%, stroke: 1.2pt + ink)
#v(6pt)

This appendix teaches nothing new. It is the compressed form of Chapters 1--8, for the last
week, when there is no time to re-read anything.

Use it in three passes. *Seven days out:* read section 1 and fill the gaps from the chapters.
*The night before:* sections 2 and 3, out loud, on a timer. *The last hour:* section 5 only.

#formulas(title: "The six structures, in six lines")[
#set text(size: 9.5pt)
- *NOW · PATH · PROOF · POINT* --- "tell me about yourself". 5--7 sentences, 60--90 s. (Ch 3)
- *S · T · A · R* --- every behavioural story. Situation, Task, Action, Result. 90--120 s. (Ch 4)
- *The 12-line Project Defence Sheet* --- one per project on your resume. (Ch 5)
- *ACKNOWLEDGE · FACT · EVIDENCE · FORWARD* --- every awkward question. 45 s. (Ch 6)
- *P · A · U · S · E* --- every puzzle and guesstimate, said out loud. (Ch 7)
- *S · P · E · H* --- every group-discussion entry. 25--40 s. (Ch 8)
]

#section[1 · The question bank --- what each answer must contain]

Cover the right column. Say the answer. Uncover, and check that every listed part was
actually in what you said.

#subsection[A · The core HR questions (Chapter 3)]

#table(
  columns: (auto, 1fr, auto),
  inset: (x: 5pt, y: 3.5pt),
  align: (left, left, center),
  [*Question*], [*Structure your answer must contain*], [*Time*],

  [Tell me about yourself],
  [NOW (who you are today) → PATH (one thread only) → PROOF (strongest concrete thing, with a
  number) → POINT (why that points at this job). Then stop.],
  [60--90 s],

  [What are your strengths?],
  [Name *one* strength → one sentence defining what you mean by it → one story of 4--5
  sentences where it produced a measurable result → the limit of it.],
  [45--60 s],

  [What is your weakness?],
  [A real one that does not disqualify you → the cost it actually caused you once → the
  specific habit or tool you changed → the evidence it is working now. Never a disguised boast.],
  [45 s],

  [Why do you want to join us?],
  [Something specific and checkable about *them* (product, stack, team, public engineering
  writing) → the link to something you have actually done → what you want to learn there.
  No adjectives about how great they are.],
  [45--60 s],

  [Where do you see yourself in five years?],
  [A direction, not a job title → the skill you want to be good at → one sentence on what you
  would be contributing by then. Stay inside the company's own reality.],
  [30--45 s],

  [Why should we hire you?],
  [Three claims, each with one piece of evidence → one sentence on fit with *this* role.
  Evidence is a number, a shipped thing, or a named responsibility.],
  [45 s],

  [Why this branch / why this role?],
  [The honest origin (even "I was assigned it") → what you found in it that you now choose →
  one thing you built because of that choice.],
  [30 s],

  [Are you flexible on location / shift?],
  [Answer the actual question in the first sentence → your real constraint stated plainly, if
  you have one → what you can commit to without anyone else's permission. Never a fake yes.],
  [20--30 s],

  [Tell me about your family / hobbies],
  [Two sentences, warm, ordinary, true → connect one detail to a working habit if it is
  genuine. Do not perform.],
  [20--30 s],

  [Do you have any questions for us?],
  [Two questions minimum, about the work: what the first six months look like, how code gets
  reviewed, what the team is struggling with. Never "what is the salary" here.],
  [--],
)

#subsection[B · Behavioural stories --- the twelve you must own (Chapter 4)]

Every one in labelled STAR, with *I* not *we* in the Action, and a *measured* Result.

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  [*Story*], [*The one thing this story must prove*],
  [1 Conflict with a teammate], [You separated the person from the problem and reached a decision, without a villain.],
  [2 A failure you owned], [You state the cause in your own actions, and the fix you shipped after.],
  [3 A hard deadline], [What you *cut*, and who you told, and when. Not "I worked all night".],
  [4 Leading without a title], [You created a mechanism (a list, a rota, a standup) that outlived the moment.],
  [5 Learning something fast], [The method you used to learn, and the thing you shipped with it, with dates.],
  [6 Helping someone else], [Their result improved, and you can say by how much.],
  [7 Deciding with data], [The number you looked at, the decision it changed, the outcome.],
  [8 Disagreeing with someone senior], [You disagreed in private, with evidence, then committed to the decision either way.],
  [9 Ambiguity], [How you narrowed an unclear problem to one testable first version.],
  [10 Going past what was asked], [Nobody asked; you measured the gain; it stayed in use.],
  [11 A difficult user or customer], [You found what they actually needed underneath what they said.],
  [12 Competing priorities], [The rule you used to choose, and what you explicitly dropped.],
)

#trick[
One real event usually feeds three or four of these twelve. Do not hunt for twelve separate
dramas. Take your four biggest events and ask each of them all twelve questions.
]

#subsection[C · The follow-up probes (Tier 3) --- prepare these for every story]

#table(
  columns: (1fr, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  [*Probe*], [*What it is really testing*],
  ["What did *you* do, specifically?"], [Whether the story is yours or your team's.],
  ["Why did you choose that over the alternative?"], [Whether you knew there was an alternative.],
  ["What did the other person say?"], [Whether the conversation happened at all.],
  ["What would you do differently?"], [Self-awareness; a real answer, not "nothing".],
  ["How did you measure that?"], [Whether the number is real or decorative.],
  ["What happened after?"], [Whether the fix survived past the demo.],
)

#subsection[D · Defending your project (Chapter 5)]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  [*Question*], [*What must be in the answer*],
  [90-second pitch], [Problem → who used it and how many → three named features → stack in one line → your one number.],
  [Draw the architecture], [Boxes and arrows, 60 seconds, narrated: client → API → database, plus anything asynchronous.],
  [What did YOU do?], [Named files, modules or endpoints, plus an honest sentence naming what teammates wrote.],
  [Trace one request end to end], [Tap → route → validation → query → response → what the user sees. No gaps.],
  [Why this technology?], [One honest reason, the alternative you rejected, and the cost of your choice.],
  [What broke?], [One real bug: symptom, cause, fix, and how you would prevent the class of it.],
  [What would you change?], [Two engineering changes, not features.],
  [Scale it 100x], [Name the first thing that breaks, say how you would find out, then one fix.],
  [Something you do not know], [Say "I do not know" → the nearest true thing you *do* know → a guess labelled as a guess → a question back.],
)

#subsection[E · Hard and awkward questions (Chapter 6) --- all in A · F · E · F]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  [*Question*], [*Acknowledge → Fact → Evidence → Forward*],
  [Salary expectation],
  [Ask about the range first if you can. If pushed: give a *researched range* with the source
  named, say you are flexible on the whole package, and ask what band the role sits in. Never
  a single number, never "anything is fine".],
  [Bond / service agreement],
  [Ask, politely and early: duration, start date, amount, who holds the certificates, and the
  exit triggers --- *in writing*. Negotiate only after the written offer.],
  [Notice period],
  [State the real date. Promise only a date you can hit without anyone else's permission.],
  [Backlog],
  [Number and subject, plainly → cleared or the exact attempt date → what changed in how you
  study → forward.],
  [Gap in study or work],
  [The length and the reason in one flat sentence → what you did in that time that you can
  show → forward. No apology tour.],
  [Low CGPA],
  [The number, said first → one sentence of honest cause → the upward trend or the evidence
  outside marks → forward.],
  [Rejected here before],
  [Yes, in which round → what you were missing then → the specific thing you built since → forward.],
  [Other offers],
  [Truth, without numbers or names → your honest ordering criterion → their timeline question.],
  [Will you leave for higher studies?],
  [Answer the plan you actually have. A vague answer reads as a yes you are hiding.],
  [Stress or pressure tactics],
  [Slow down, do not fill silence, ask for the question again if it was unclear, keep the same
  tone. The tactic is the test.],
)

#subsection[F · Puzzles and guesstimates (Chapter 7)]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  [*Say out loud*], [*The words*],
  [P --- play it back], ["So we have N items, one is different, and I do not know if it is heavier. Correct?"],
  [A --- ask, then assume], [At most two questions. Then: "I will assume …" and continue.],
  [U --- use a smaller case], ["Let me do it for 3 first." This step is what separates a pass from a fail.],
  [S --- solve and state], [Say every number as you write it. No silence longer than a few seconds.],
  [E --- examine], ["Is that the right order of magnitude? Does the extreme case still hold?"],
)

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  [*Guesstimate funnel*], [*What you say*],
  [1 Define], [What you are counting, in what unit, over what period.],
  [2 Anchor], [One number you genuinely know --- usually a population.],
  [3 Filter], [Three to five multiplications, each one a stated assumption.],
  [4 Compute], [Round hard, say the running total after every step.],
  [5 Sanity-check], [A second route, or a per-person feel test.],
)

#note[
The only things you memorise for this round are the anchor numbers in Chapter 7 (populations,
household size, working days, device lifetimes). Everything else is derived out loud.
]

#subsection[G · Group discussion and closing (Chapter 8)]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  [*Moment*], [*What to do*],
  [Every GD entry], [SPEH: Signpost → Point (one sentence) → Evidence (number, mechanism or example) → Handover (name someone).],
  [Entering a loud GD], [Signpost loudly and briefly at a breath-gap: "Can I add one thing on cost?" Then be short.],
  [Being interrupted], [Let them finish, then: "I will finish my point in one line, then come to yours."],
  [The summary], [The highest-value 30 seconds: the two positions in the room, the point of agreement, the open question. Take it if nobody else does.],
  [Questions to ask them], [Two, about the work and the first six months. Never salary at this point.],
  [CTC vs in-hand], [Know the difference and do the arithmetic before you react to any number.],
  [Follow-up email], [Within 24 hours. Three short paragraphs: thanks, one specific thing from the conversation, one line of availability.],
  [After silence], [Follow up twice over three weeks, politely. Then stop.],
)

#pagebreak(weak: true)

#section[2 · The thirty-second self-test]

If you cannot fill this table from memory the night before, you are not ready --- and every
missing cell tells you exactly which chapter to reopen.

#table(
  columns: (1fr, auto, auto),
  inset: (x: 5pt, y: 4pt),
  align: (left, center, center),
  [*Can you say, right now …*], [*Chapter*], [*Yes / No*],
  [Your NOW sentence, under 25 words], [3], [],
  [One number from your best project, and how it was measured], [2, 5], [],
  [Three STAR stories with a measured result in each], [4], [],
  [What you personally wrote in your project, by module], [5], [],
  [One request traced end to end], [5], [],
  [One trade-off you made and the alternative you rejected], [5], [],
  [Your salary range, with the source you got it from], [6, 8], [],
  [Your real notice period or joining date], [6, 8], [],
  [Your backlog / gap / CGPA sentence, flat, in under 15 words], [6], [],
  [Two questions to ask the interviewer], [3, 8], [],
  [The five PAUSE steps], [7], [],
  [Four anchor numbers], [7], [],
)

#section[3 · Timing --- the numbers that get people cut]

#table(
  columns: (1fr, auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  align: (left, center, left),
  [*Answer*], [*Target*], [*What going over sounds like*],
  [Tell me about yourself], [60--90 s], [A biography. The interviewer stops listening at 2 minutes.],
  [A STAR story], [90--120 s], [You are re-living it instead of reporting it.],
  [An awkward question], [45 s], [Past 90 seconds you are pleading, not answering.],
  [Project pitch], [90 s], [You listed ten features instead of three.],
  [A GD entry], [25--40 s], [You are dominating; the team-behaviour row drops.],
  [Silence after a hard question], [3 s], [Filling it yourself is how candidates volunteer their own weaknesses.],
)

#section[4 · The last-week schedule]

#table(
  columns: (auto, 1fr),
  inset: (x: 5pt, y: 3.5pt),
  [*Day 7*], [Read this appendix, section 1. Mark every cell you cannot answer; reopen only those chapters.],
  [*Day 6*], [Record answers to the ten core HR questions. Play back at 1x. Cut every answer that ran long.],
  [*Day 5*], [Three STAR stories, probed three levels deep by a friend who has the probe table above.],
  [*Day 4*], [Project Defence Sheet, out loud, plus the architecture drawn in 60 seconds.],
  [*Day 3*], [The awkward questions in A--F--E--F, 45 seconds each, flat voice, three seconds of silence after.],
  [*Day 2*], [Four puzzles and two guesstimates out loud. Re-read the anchor numbers.],
  [*Day 1*], [Company research: 20 minutes on their product, their stack, their public engineering writing. Write the "why us" answer from it. Sleep.],
  [*The morning of*], [Section 5 below. Nothing else. Do not learn anything new today.],
)

#section[5 · Pre-interview checklist]

#formulas(title: "The night before")[
#set text(size: 9.5pt)
- Printed resume, 2 copies. Read your own resume top to bottom --- *every line on it is a
  question you have invited*.
- Project Defence Sheet for each project on that resume, filled, in front of you.
- Your salary range and its source, written down. Your real notice period or joining date.
- Your two questions to ask them, written down.
- Company research done and reduced to three sentences.
- The route and the arrival time, or the meeting link tested end to end.
- Documents: ID, marksheets, offer letters, experience letters --- in one folder.
- Clothes out. Phone charged. Sleep before midnight; being sharp beats one more revision.
]

#formulas(title: "Thirty minutes before")[
#set text(size: 9.5pt)
- Read *only* section 1 of this appendix and your own story sheet. Nothing new.
- Say your NOW sentence and one full STAR story out loud, once, to warm up your voice.
- Water. Bathroom. Silence the phone --- fully, not on vibrate.
- Online: camera at eye level, light in front of you not behind, headphones in, a second
  connection ready (a phone hotspot), background tidy, notifications off, name displayed
  correctly.
- In person: arrive 15 minutes early, not 45. Be polite to everyone in the building ---
  reception often gets asked.
]

#formulas(title: "In the room --- the six behaviours")[
#set text(size: 9.5pt)
+ *Answer the actual question first*, in the first sentence. Then support it.
+ *Say "I" for what you did* and "we" only for what the team did.
+ *Put one number in every answer that can hold one.*
+ *When you do not know:* say so, give the nearest true thing, label a guess as a guess, ask
  a question back.
+ *Let silence exist.* Three seconds is normal. Filling it is how people talk themselves down.
+ *Take the last question seriously* --- "do you have questions for us" is scored.
]

#formulas(title: "Within 24 hours after")[
#set text(size: 9.5pt)
- Write down every question you were asked, while you still remember it. This is the most
  valuable study material you will ever have, and it evaporates within a day.
- Send the thank-you note: thanks, one specific thing from the conversation, one line of
  availability. Three short paragraphs.
- Note the two answers you were least happy with, and fix those two structures this week ---
  whatever the outcome of this interview.
]

#trap[
Two things to *not* do on the morning of: learning a new structure, and reading someone
else's sample answers. Both crowd out the one thing that actually helps --- your own
material, recalled calmly.
]

#revision[
#set text(size: 9.5pt)
*The whole book in ten lines.*

+ The rounds are a machine with stages; each stage scores a different thing. (Ch 1)
+ Every resume bullet: VERB + WHAT + HOW + NUMBER. A bullet with no number is a claim. (Ch 2)
+ "Tell me about yourself" is a pitch, not a biography: NOW → PATH → PROOF → POINT. (Ch 3)
+ Every behavioural answer is labelled STAR, and the Action is *I*, not *we*. (Ch 4)
+ Build the story bank from real events first; map them to questions second. (Ch 4)
+ Your project is defended from a 12-line sheet, and line 9 --- the one number --- carries
  the most weight. (Ch 5)
+ Awkward questions get 45 seconds of ACKNOWLEDGE → FACT → EVIDENCE → FORWARD, and the
  marks live in EVIDENCE. (Ch 6)
+ Puzzles are scored on thinking out loud: PAUSE, always, including the small case. (Ch 7)
+ In a group discussion, the handover and the summary score highest. (Ch 8)
+ Every structure in this book is a container. *You* supply the contents, and they must be
  true --- an invented story dies at the third follow-up, and this book will not help you
  build one.
]
