#import "../lib/style.typ": *

#chapter(num: 17, title: "Syllogisms & Logical Deduction", tagline: "Draw the circles. Never argue from the words.")[

#section[What you need to know]

#formulas[
*Rule 0 — the only rule that matters.* A conclusion "follows" only if it is true in
*every* diagram that fits the statements. One diagram where it fails kills it.

*Rule 0b — the exam convention.* Treat every statement as true, even if it is silly in
real life. Treat every class named as non-empty (it has at least one member).

*The four statement types.*

#table(columns: (auto, 1fr, auto, auto),
  [*Code*],[*Form*],[*Covers all of the subject?*],[*Covers all of the predicate?*],
  [A], [All S are P],       [Yes], [No],
  [E], [No S is P],         [Yes], [Yes],
  [I], [Some S are P],      [No],  [No],
  [O], [Some S are not P],  [No],  [Yes],
)

*Conversion (flipping one statement).*
- All S are P $=>$ Some P are S. #h(4pt) (Never "All P are S".)
- No S is P $=>$ No P is S $=>$ Some S are not P, Some P are not S.
- Some S are P $=>$ Some P are S.
- Some S are not P $=>$ *nothing*. Cannot be flipped.

*The combination table.* Statement 1 links A to B, statement 2 links B to C.

#table(columns: (auto, auto, 1fr),
  [*Statement 1*], [*Statement 2*], [*Conclusion about A and C*],
  [All A are B],      [All B are C],  [All A are C],
  [All A are B],      [No B is C],    [No A is C],
  [Some A are B],     [All B are C],  [Some A are C],
  [Some A are B],     [No B is C],    [Some A are not C],
  [No A is B],        [All B are C],  [Some C are not A],
)
*Nothing at all follows from:* All + Some, Some + Some, No + No, or any pair whose first
statement is "Some A are not B".

*The five validity checks.*
+ The middle term (B) must cover a whole class in at least one statement.
+ Two negative statements give nothing.
+ One negative statement $=>$ the conclusion must be negative.
+ Two "some" statements give nothing.
+ One "some" statement $=>$ the conclusion must be a "some" statement.

*Either–or rule.* Write "Either I or II follows" only when *both* of these hold:
+ Neither I nor II follows on its own, and
+ I and II are a complementary pair on the *same two terms*:
  (All S are P / Some S are not P), (No S is P / Some S are P), or
  (Some S are P / Some S are not P).

*Possibility conclusions.* "X being Y is a possibility" is TRUE unless the statements
make it impossible. So look for *one* legal diagram, not for proof.

*New-pattern words.* "Only a few A are B" and "Almost all A are B" both mean
Some A are B *and* Some A are not B. "Only A are B" means All B are A.
"At least some A are B" means Some A are B.

*Reverse syllogism.* You are given the conclusions and must pick the statement set.
Test each set forward with the combination table. Keep the set that forces *all*
conclusions, not just one.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[
Statement: All pens are blue. Which follows — (a) All blue things are pens,
(b) Some blue things are pens?
#sol[
"All S are P" flips only to "Some P are S".
The pens sit inside the blue circle, so part of blue is pen.
]
#ans[(b) Some blue things are pens.]
]

#ex(2, tier: 0)[
Statement: No cat is a dog. Write two things that follow.
#sol[
"No S is P" flips fully: No dog is a cat.
It also weakens to a "some not": Some cats are not dogs.
]
#ans[No dog is a cat; Some cats are not dogs.]
]

#ex(3, tier: 0)[
Statement: Some mangoes are ripe. What follows?
#sol[
"Some S are P" flips to "Some P are S". The overlap belongs to both circles.
]
#ans[Some ripe things are mangoes.]
]

#ex(4, tier: 0)[
Statement: Some books are not heavy. What follows?
#sol[
The O type cannot be flipped. Knowing part of "books" sits outside "heavy" tells you
nothing about the inside of "heavy".
]
#ans[Nothing follows.]
]

#ex(5, tier: 0)[
Statements: All A are B. All B are C. Conclusion: All A are C.
#sol[
A sits inside B. B sits inside C. So A sits inside C.
]
#ans[It follows.]
]

#ex(6, tier: 0)[
Statements: Some A are B. Some B are C. Conclusion: Some A are C.
#sol[
The A-part of B and the C-part of B can be two different pieces of B.
Diagram: B has a left piece touching A and a right piece touching C, with no contact
between A and C. Both statements hold, the conclusion fails.
]
#ans[Does not follow (two "some" statements give nothing).]
]

#ex(7, tier: 0)[
Are these a complementary pair: "All X are Y" and "Some X are not Y"?
#sol[
Same subject X, same predicate Y. A-type against O-type.
If all X are Y is false, then at least one X sits outside Y, so some X are not Y.
Exactly one of them must be true.
]
#ans[Yes — A/O complementary pair.]
]

#ex(8, tier: 0)[
Statements: All fans are lights. No light is a switch. Conclusion: No fan is a switch.
#sol[
Fans sit inside lights. Lights and switches do not touch at all.
So fans cannot touch switches either.
]
#ans[It follows.]
]

#section[Tier 1 — Service companies]
#tier-header(1)

#ex(9, tier: 1, asked: "TCS NQT pattern")[
*Statements:* All pens are books. All books are papers. \
*Conclusions:* I. All pens are papers. #h(10pt) II. Some papers are pens.
#sol[
Pens $subset$ books $subset$ papers. So pens $subset$ papers. I follows.
"All pens are papers" flips to "Some papers are pens". II follows.
]
#ans[Both I and II follow.]
]

#ex(10, tier: 1, asked: "Accenture pattern")[
*Statements:* All roses are flowers. No flower is a stone. \
*Conclusions:* I. No rose is a stone. #h(10pt) II. Some stones are roses.
#sol[
Roses $subset$ flowers, and the flower circle never touches the stone circle.
So no rose touches stone. I follows.
II says roses and stones overlap. That directly contradicts I, which is forced.
So II is false.
]
#ans[Only I follows.]
]

#ex(11, tier: 1, asked: "Infosys pattern")[
*Statements:* Some doctors are singers. All singers are artists. \
*Conclusions:* I. Some doctors are artists. #h(10pt) II. All artists are doctors.
#sol[
Take one person who is both doctor and singer. Every singer is an artist,
so that person is an artist. That person is a doctor and an artist. I follows.
II asks the whole artist circle to sit inside doctors. Nothing forces that —
an artist may be neither singer nor doctor. II fails.
]
#ans[Only I follows.]
]

#ex(12, tier: 1, asked: "Wipro pattern")[
*Statements:* Some tables are chairs. No chair is a bed. \
*Conclusions:* I. Some tables are not beds. #h(10pt) II. No table is a bed.
#sol[
Some + No $=>$ "Some are not". The tables that are chairs cannot be beds,
because no chair is a bed. So some tables are not beds. I follows.
II claims the *whole* table circle avoids beds. The tables that are not chairs are
free to be beds. II fails.
]
#ans[Only I follows.]
]

#trap[
"Some A are not B" is a *weak* claim, and "No A is B" is a *strong* claim.
A "some" statement in the premises can never give you a "No" conclusion.
Rule 5: one particular premise $=>$ a particular conclusion.
]

#ex(13, tier: 1, asked: "Capgemini pattern")[
*Statements:* All apples are fruits. Some fruits are sweet. \
*Conclusions:* I. Some apples are sweet. #h(10pt) II. Some apples are not sweet.
#sol[
Check I alone. Draw the sweet circle overlapping the fruit circle *outside* the apple
part. All apples are fruits: true. Some fruits are sweet: true. Some apples are sweet:
false. So I does not follow.

Check II alone. Now draw apple = fruit = sweet, all three the same circle.
All apples are fruits: true. Some fruits are sweet: true.
Some apples are not sweet: false. So II does not follow.

Now the either–or test. I is "Some apples are sweet" (I type).
II is "Some apples are not sweet" (O type). Same subject, same predicate.
Apples exist, so at least one of the two must be true.
]
#ans[Either I or II follows.]
]

#trick[
*The either–or 5-second test.* Only try it when *both* conclusions already failed.
Then check just two things: same two terms? and one of the three pairs
(All / Some-not), (No / Some), (Some / Some-not)? If yes, write "Either I or II".
If the terms differ, stop — it is "Neither follows".
]

#ex(14, tier: 1, asked: "TCS NQT pattern")[
*Statements:* All fans are lights. No light is a switch. \
*Conclusions:* I. No fan is a switch. #h(10pt) II. Some switches are not lights.
#sol[
I: fans $subset$ lights, lights $inter$ switches $= nothing$. So fans $inter$ switches
$= nothing$. I follows.
II: "No light is a switch" flips to "No switch is a light".
Switches exist, so take one. It is a switch and it is not a light. II follows.
]
#ans[Both I and II follow.]
]

#ex(15, tier: 1, asked: "Cognizant pattern")[
*Statements:* All cars are vehicles. All vehicles are machines. Some machines are toys. \
*Conclusions:* I. Some cars are toys. #h(10pt) II. All cars are machines.
#sol[
II first, because it is a clean chain: cars $subset$ vehicles $subset$ machines.
So all cars are machines. II follows.

I: the toy overlap sits somewhere in the machine circle. Draw it in the part of
machines that is outside vehicles. All three statements still hold and no car is a toy.
I fails.
]
#ans[Only II follows.]
]

#ex(16, tier: 1, asked: "Infosys pattern")[
*Statements:* All apples are fruits. Some fruits are sweet. \
*Conclusions:* I. All apples being sweet is a possibility. #h(10pt) II. Some apples are sweet.
#sol[
II was killed in Example 13. It does not follow.

I is a *possibility* conclusion. I only need one legal diagram.
Put the whole apple circle inside the sweet region, and put the sweet region inside
fruits. Check: all apples are fruits — yes. Some fruits are sweet — yes, the apples are.
Nothing is broken, so the possibility is real.
]
#ans[Only I follows.]
]

#trick[
*Possibility questions are the easy ones.* A normal conclusion needs to survive every
diagram. A possibility conclusion needs only one diagram. So ask the opposite question:
"do the statements *forbid* this?" If not forbidden, it is possible.
]

#ex(17, tier: 1, asked: "Accenture pattern")[
*Statements:* No book is a pen. All pens are inks. \
*Conclusions:* I. Some inks are not books. #h(10pt) II. No ink is a book.
#sol[
Pens exist. Every pen is an ink. No pen is a book (flip of "No book is a pen").
So take a pen: it is an ink and it is not a book. I follows.

II: inks may also include things that are books. Draw the ink circle big enough to
swallow some books while keeping pens away from books. Both statements hold, II fails.
]
#ans[Only I follows.]
]

#ex(18, tier: 1, asked: "TCS NQT pattern")[
*Statements:* Some keys are locks. Some locks are doors. \
*Conclusions:* I. Some keys are doors. #h(10pt) II. No key is a door.
#sol[
Two "some" statements, so neither conclusion can be forced.
Diagram 1: keys touch the left of locks, doors touch the right of locks, keys and doors
apart. Then I is false.
Diagram 2: keys, locks and doors all overlap in one shared patch. Then II is false.

Either–or test: I is "Some keys are doors" (I type), II is "No key is a door" (E type),
same two terms. That is a complementary pair.
]
#ans[Either I or II follows.]
]

#ex(19, tier: 1, asked: "Wipro pattern")[
*Statements:* All singers are dancers. Some dancers are actors. No actor is a writer. \
*Conclusions:* I. Some dancers are not writers. #h(10pt) II. Some singers are writers.
#sol[
I: take a dancer who is an actor (exists, from statement 2).
No actor is a writer, so this dancer is not a writer.
So some dancers are not writers. I follows.

II: singers sit inside dancers, but nothing pushes them into writers.
Draw writers touching only the dancer region that has no singers.
All three statements hold and no singer is a writer. II fails.
]
#ans[Only I follows.]
]

#trap[
*The chain-break trap.* "All singers are dancers" plus "Some dancers are actors" is
All + Some. The combination table says: *no conclusion*. The "some" part of dancers
may miss the singers completely. Students who read left-to-right and say
"so some singers are actors" lose this mark every time.
]

#practice(tier: 1, time: "60 s/Q")[
In each question, take the statements as true even if they differ from real facts.
Decide which conclusion(s) follow.

+ *Statements:* All cups are mugs. All mugs are jars. \
  *Conclusions:* I. All cups are jars. II. Some jars are cups.

+ *Statements:* All dogs are pets. No pet is wild. \
  *Conclusions:* I. No dog is wild. II. Some wild things are pets.

+ *Statements:* Some pens are red. All red things are bright. \
  *Conclusions:* I. Some pens are bright. II. All pens are bright.

+ *Statements:* Some files are folders. No folder is a disk. \
  *Conclusions:* I. Some files are not disks. II. No file is a disk.

+ *Statements:* All trains are buses. Some buses are taxis. \
  *Conclusions:* I. Some trains are taxis. II. Some trains are not taxis.

+ *Statements:* No shirt is a shoe. All shoes are leather. \
  *Conclusions:* I. Some leather things are not shirts. II. No leather thing is a shirt.

+ *Statements:* All bricks are stones. All stones are hard. \
  *Conclusions:* I. All bricks are hard. II. Some hard things are bricks.

+ *Statements:* Some birds are crows. Some crows are black. \
  *Conclusions:* I. Some birds are black. II. No bird is black.

+ *Statements:* All keys are metals. Some metals are gold. \
  *Conclusions:* I. Some keys are gold. II. All keys being gold is a possibility.

+ *Statements:* All fruits are sweet. No sweet thing is sour. Some sour things are bitter. \
  *Conclusions:* I. No fruit is sour. II. Some bitter things are not sweet.

+ *Statements:* Some cards are paper. All paper is thin. \
  *Conclusions:* I. Some cards are thin. II. Some thin things are cards.

+ *Statements:* All lamps are bulbs. Some bulbs are LEDs. No LED is cheap. \
  *Conclusions:* I. Some bulbs are not cheap. II. Some lamps are not cheap.

+ *Statements:* Only a few phones are cameras. All cameras are lenses. \
  *Conclusions:* I. Some phones are lenses. II. Some phones are not cameras.

+ *Statements:* No river is a lake. Some lakes are ponds. \
  *Conclusions:* I. Some ponds are not rivers. II. All ponds being rivers is a possibility.

+ *Statements:* All servers are machines. All machines are assets. Some assets are leased. \
  *Conclusions:* I. Some servers are leased. II. All servers are assets.
]

#key[
+ *Both follow.* Chain cups $subset$ mugs $subset$ jars gives I; flip of I gives II.
+ *Only I.* Dogs sit inside pets, pets avoid wild, so dogs avoid wild. II contradicts the second statement.
+ *Only I.* Some + All = Some. II needs all pens inside red, which is not given.
+ *Only I.* Some + No = Some-not. Files outside folders may still be disks, so II fails.
+ *Either I or II.* All + Some gives nothing; I and II are the (Some / Some-not) pair on trains and taxis.
+ *Only I.* Shoes are leather and no shoe is a shirt, so some leather is not shirt. Leather may also contain shirts, so II fails.
+ *Both follow.* Chain gives I; flip of I gives II.
+ *Either I or II.* Two "some" statements force nothing; I and II are the (Some / No) pair on birds and black.
+ *Only II.* Keys need not touch gold, so I fails. Putting keys inside gold inside metals breaks nothing, so the possibility stands.
+ *Both follow.* Fruits inside sweet, sweet avoids sour, so I. The bitter-and-sour things are not sweet, so II.
+ *Both follow.* Some + All = Some cards are thin; flipping gives II.
+ *Only I.* The LED-bulbs are not cheap, so I. Lamps may sit in the non-LED part of bulbs, so II fails.
+ *Both follow.* "Only a few phones are cameras" = some are + some are not. Some phones are cameras, and all cameras are lenses, so I; the second half gives II.
+ *Only I.* Pond-lakes are not rivers, so I. Those same ponds can never be rivers, so "all ponds are rivers" is impossible and II fails.
+ *Only II.* Chain servers $subset$ machines $subset$ assets gives II. The leased part of assets may avoid servers, so I fails.
]

#section[Tier 2 — Singapore & Thailand]
#tier-header(2)

#ex(20, tier: 2, asked: "Grab · pattern")[
*Statements:* All drivers are partners. Some partners are owners. All owners are insured. \
*Conclusions:* I. Some partners are insured. #h(10pt) II. Some drivers are insured.
#sol[
Work on the pair that actually links up: "Some partners are owners" + "All owners are
insured" is Some + All = Some. So some partners are insured. I follows.

II needs drivers to reach insured. Drivers sit inside partners, but the owner-overlap
can sit in the partner region that has no drivers.
Legal diagram: partners is a big circle, drivers a small circle on the left,
owners a small circle on the right, insured wrapped around owners.
Every statement is true and no driver is insured. II fails.
]
#ans[Only I follows.]
]

#ex(21, tier: 2, asked: "Shopee · pattern")[
*Statements:* Some riders are students. All students are young. \
*Conclusions:* I. All riders being young is a possibility. #h(10pt) II. Some riders are young.
#sol[
II: Some + All = Some. The rider-students are young, so some riders are young. II follows.

I: possibility test. Draw the rider circle fully inside "young", with the student circle
also inside "young" and overlapping riders. Some riders are students — true.
All students are young — true. Nothing is broken, so the possibility holds. I follows.
]
#ans[Both I and II follow.]
]

#ex(22, tier: 2, asked: "DBS · pattern")[
*Statements:* No merchant is a courier. All couriers are staff. Some staff are managers. \
*Conclusions:* I. Some staff are not merchants. #h(10pt) II. Some managers are not merchants.
#h(10pt) III. All merchants being staff is a possibility.
#sol[
I: couriers exist, every courier is staff, and no courier is a merchant
(flip of statement 1). So take a courier: staff, not merchant. I follows.

II: managers are a slice of staff. Nothing stops that slice from lying fully inside
merchants — merchants only have to avoid couriers, and merchants are allowed to be staff.
Diagram: staff contains couriers on the left and a merchant-manager block on the right.
Every statement holds, and every manager is a merchant. II fails.

III: the same diagram already puts all merchants inside staff. So it is possible. III follows.
]
#ans[I and III follow.]
]

#trick[
*Reuse one diagram for several conclusions.* If a single legal diagram kills a
"must-follow" conclusion, that very diagram usually *proves* the matching possibility
conclusion. In Example 22 the picture that broke II is the picture that confirmed III.
One drawing, two answers.
]

#ex(23, tier: 2, asked: "Agoda · pattern")[
*Statements:* All apps are tools. No tool is free. Some free items are useful. \
*Conclusions:* I. No app is free. #h(10pt) II. Some useful things are not tools.
#sol[
I: All + No = No. Apps sit inside tools, tools avoid free, so apps avoid free. I follows.

II: "No tool is free" flips to "No free item is a tool".
Statement 3 gives an item that is free and useful.
That item is free, so it is not a tool.
So it is useful and not a tool. II follows.
]
#ans[Both I and II follow.]
]

#ex(24, tier: 2, asked: "Sea · pattern")[
*Statements:* Some sellers are vendors. All vendors are verified. No verified account is banned. \
*Conclusions:* I. Some sellers are not banned. #h(10pt) II. All sellers being verified is a
possibility. #h(10pt) III. Some verified accounts are sellers.
#sol[
Follow one element through the chain. There is a seller who is a vendor (statement 1).
Every vendor is verified, so that seller is verified.
No verified account is banned, so that seller is not banned.

I: that seller is a seller and not banned. I follows.
III: that seller is verified and is a seller. So some verified accounts are sellers. III follows.
II: possibility. Push the whole seller circle inside verified.
Statement 1 still holds (the vendor-sellers are still there),
statement 2 untouched, statement 3 untouched. Possible. II follows.
]
#ans[I, II and III all follow.]
]

#ex(25, tier: 2, asked: "SCB · pattern")[
*Statements:* All buses are trains. Some trains are cars. All cars are jeeps. \
*Conclusions:* I. Some buses are jeeps. #h(10pt) II. No bus is a jeep.
#sol[
I alone: put the car-overlap in the part of trains with no buses, and put jeeps around
cars only. Then no bus is a jeep, so I fails.

II alone: now let some buses also be cars. Buses are still inside trains — fine.
Some trains are cars — fine. All cars are jeeps — fine.
Those buses are jeeps, so II fails.

Both failed. Either–or test: I is "Some buses are jeeps", II is "No bus is a jeep".
Same two terms, and they are the (Some / No) pair.
]
#ans[Either I or II follows.]
]

#ex(26, tier: 2, asked: "GIC · pattern")[
*Reverse syllogism.* Which pair of statements makes *both* conclusions definitely true? \
*Conclusions:* I. Some pilots are not cadets. #h(10pt) II. Some cadets are officers. \
(a) All pilots are cadets. All cadets are officers. \
(b) All cadets are officers. No pilot is an officer. \
(c) Some pilots are cadets. No cadet is an officer. \
(d) All officers are cadets. Some pilots are officers.
#sol[
Test (a): all pilots are cadets, so "some pilots are not cadets" is false. Reject.

Test (b): "All cadets are officers" flips to "Some officers are cadets",
which is the same as "Some cadets are officers". II holds.
For I: no pilot is an officer, and every cadet is an officer.
So a pilot can never be a cadet, i.e. no pilot is a cadet.
Pilots exist, so some pilots are not cadets. I holds. Keep (b).

Test (c): no cadet is an officer, so II is false. Reject.

Test (d): all officers are cadets gives II. But some pilots are officers, and officers
are cadets, so those pilots *are* cadets; nothing forces any pilot to sit outside
cadets. I is not guaranteed. Reject.
]
#ans[(b) All cadets are officers. No pilot is an officer.]
]

#ex(27, tier: 2, asked: "LINE MAN · pattern")[
*Statements:* Only a few engineers are managers. All managers are leaders. \
*Conclusions:* I. Some engineers are not managers. #h(10pt) II. Some engineers are
leaders. #h(10pt) III. All engineers being leaders is a possibility.
#sol[
First translate. "Only a few engineers are managers" means two things at once:
Some engineers are managers, *and* Some engineers are not managers.

I is the second half, given directly. I follows.
II: some engineers are managers, all managers are leaders. Some + All = Some. II follows.
III: possibility. The engineers who are not managers are free to be leaders anyway.
Draw the whole engineer circle inside leaders, with the manager circle also inside
leaders and cutting engineers partly. Both statements survive. III follows.
]
#ans[I, II and III all follow.]
]

#trap[
*"Only a few" is not "a few".* It carries a hidden negative half.
"Only a few X are Y" = Some X are Y AND Some X are not Y.
Students who use only the positive half lose the free "Some X are not Y" mark.
And "Only X are Y" is different again — it means *All Y are X*.
]

#ex(28, tier: 2, asked: "Razer · pattern")[
*Statements:* Some contracts are leases. All leases are documents. No document is verbal. \
*Conclusions:* I. Some contracts are not verbal. #h(10pt) II. No contract is verbal.
#h(10pt) III. Some documents are contracts.
#sol[
Chain one element. A contract that is a lease exists. It is a document (statement 2).
It is not verbal (statement 3).

I: that contract is not verbal. I follows.
III: that same thing is a document and a contract. III follows.
II: the contracts that are *not* leases have no restriction on them.
Draw half of the contract circle inside "verbal", far from documents.
All three statements hold and II is false. II fails.
]
#ans[I and III follow.]
]

#practice(tier: 2, time: "100 s/Q")[
No options. Write which conclusions follow, and for possibility conclusions say
possible or impossible.

+ *Statements:* All riders are partners. Some partners are drivers. All drivers are insured. \
  *Conclusions:* I. Some partners are insured. II. Some riders are insured.
  III. All riders being insured is a possibility.

+ *Statements:* Some orders are refunds. No refund is a coupon. All coupons are discounts. \
  *Conclusions:* I. Some orders are not coupons. II. Some discounts are not refunds.
  III. No order is a coupon.

+ *Statements:* Only a few merchants are exporters. All exporters are licensed. \
  *Conclusions:* I. Some merchants are licensed. II. Some merchants are not exporters.
  III. All merchants being licensed is a possibility.

+ *Statements:* All wallets are accounts. Some accounts are frozen. No frozen account is active. \
  *Conclusions:* I. Some accounts are not active. II. Some wallets are not active.
  III. Some accounts are not frozen.

+ *Statements:* No courier is a manager. All managers are staff. Some staff are trainees. \
  *Conclusions:* I. Some staff are not couriers. II. All couriers being staff is a possibility.
  III. Some trainees are not couriers.

+ *Statements:* All apps are tools. Some tools are paid. All paid items are licensed. \
  *Conclusions:* I. Some tools are licensed. II. Some apps are licensed. III. No app is licensed.

+ *Statements:* All flights are journeys. No journey is free. Some free things are useful. \
  *Conclusions:* I. No flight is free. II. Some useful things are not journeys.
  III. Some journeys are useful.

+ *Statements:* Some hotels are resorts. All resorts are properties. Some properties are rented. \
  *Conclusions:* I. Some hotels are properties. II. Some hotels are rented.
  III. Some properties are hotels.

+ *Statements:* All bookings are records. Some records are cancelled. \
  *Conclusions:* I. Some bookings are cancelled. II. No booking is cancelled.
  III. All records being bookings is a possibility.

+ *Statements:* No vendor is a buyer. Some buyers are agents. All agents are members. \
  *Conclusions:* I. Some members are not vendors. II. Some agents are not vendors.
  III. All vendors being members is a possibility.

+ *Statements:* Only a few cards are credit cards. No credit card is free. \
  *Conclusions:* I. Some cards are not free. II. Some cards are not credit cards.
  III. All cards being free is a possibility.
]

#key[
+ *I and III.* Some partners are drivers and all drivers are insured, so I. Riders may sit in the driver-free part of partners, so II fails; but pushing riders inside insured breaks nothing, so III is possible.
+ *I and II.* The order-refunds are not coupons, so I. Coupons are discounts and are not refunds, so II. Non-refund orders may be coupons, so III fails.
+ *All three.* "Only a few" gives II directly; its positive half plus "all exporters are licensed" gives I; the non-exporter merchants may also be licensed, so III is possible.
+ *Only I.* Frozen accounts are not active, so I. Wallets may avoid the frozen slice, so II fails. Every account, wallets included, may be frozen, so III is not forced.
+ *I and II.* Managers are staff, and no manager is a courier, so some staff are not couriers, giving I. Couriers are barred only from being managers, so every courier may still sit inside staff, which makes II possible. Trainees are staff, and nothing stops all of them being couriers, so III fails.
+ *I follows, and either II or III follows.* Paid tools are licensed, so I. Apps may or may not touch the licensed region, so neither II nor III is forced; they are the (Some / No) pair on apps and licensed.
+ *I and II.* Flights sit inside journeys and journeys avoid free, so I. Free things are not journeys, and some free things are useful, so II. Journeys and useful things need not meet, so III fails.
+ *I and III.* The hotel-resorts are properties, so I, and flipping gives III. The rented slice of properties may avoid hotels, so II fails.
+ *III follows, and either I or II follows.* All + Some forces nothing about bookings and cancelled, and I, II are the (Some / No) pair. Setting records = bookings keeps both statements true, so III is possible.
+ *All three.* The buyer-agents are not vendors, so II; they are members too, so I. Vendors are only barred from being buyers, so they may all be members, giving III.
+ *I and II.* "Only a few" gives II; its positive half plus "no credit card is free" gives I. Those same credit cards can never be free, so III is impossible.
]

#section[Tier 3 — Product companies]
#tier-header(3)

#ex(29, tier: 3, asked: "Google · pattern")[
*Statements:* All P are Q. Some Q are not R. \
*Question:* Does "Some P are not R" follow? Prove your answer.
#sol[
*Insight: the "some Q" in statement 2 need not be any of the P's. The two statements
touch Q in possibly disjoint places.*

Build a counterexample with real sets.
Let $P = {1}$, $Q = {1, 2}$, $R = {1}$.

Check statement 1: is every member of P in Q? $1 in Q$. Yes.
Check statement 2: is some member of Q outside R? $2 in Q$ and $2 in.not R$. Yes.
Check the conclusion: is some member of P outside R? P has only 1, and $1 in R$. No.

Both statements are true and the conclusion is false, so it cannot follow.

Note also what rule 1 says: the middle term is Q. Statement 1 "All P are Q" covers all
of P but not all of Q. Statement 2 "Some Q are not R" covers all of R but not all of Q.
Q is never covered fully, so no valid conclusion exists at all.
]
#ans[It does not follow.]
]

#ex(30, tier: 3, asked: "Amazon · pattern")[
*Statements:* No P is Q. All Q are R. \
*Question:* List every valid conclusion that links P and R.
#sol[
*Insight: the Q block is a wedge that lives inside R and is banned from P.
Only R can "see" that wedge, so only R-first conclusions can survive.*

Q is non-empty, so pick $q in Q$.
$q in R$ (statement 2). $q in.not P$ (flip of statement 1: no Q is P).
So $q$ is an R that is not a P. *"Some R are not P" is valid.*

Now test the other candidates one by one.

"No P is R": counterexample — put P inside R but outside Q.
No P is Q: true. All Q are R: true. But every P is R. Fails.

"Some P are not R": same diagram, P sits fully inside R. Fails.

"All R are P": Q is inside R and Q avoids P, so R has members outside P. Fails.

"Some P are R": counterexample — put P completely outside R.
No P is Q: true (Q is inside R). All Q are R: true. No P is R. Fails.

So only one conclusion survives, plus the things it is equivalent to.
]
#ans["Some R are not P" — and nothing else. (It does not flip into a P-first form.)]
]

#ex(31, tier: 3, asked: "Microsoft · pattern")[
*Statements:* All X are Y. Some Y are Z. \
*Question:* Which of these are possible? \
(a) All Z are X #h(10pt) (b) No Z is X #h(10pt) (c) All Y are Z #h(10pt) (d) Some X are not Y
#sol[
*Insight: for a possibility, you do not argue — you construct. Build the most extreme
legal picture you can and see if the statements survive.*

(a) All Z are X. Construct: let $Z subset.eq X subset.eq Y$, with Z non-empty.
All X are Y: true. Some Y are Z: the Z members are in X, hence in Y. True.
Survives. *Possible.*

(b) No Z is X. Construct: Y is a big circle. X sits on the left of Y.
Z sits on the right, half inside Y, half outside, never touching X.
All X are Y: true. Some Y are Z: true (the inside half). No Z is X: true.
Survives. *Possible.*

(c) All Y are Z. Construct: let $X subset.eq Y = Z$.
All X are Y: true. Some Y are Z: true (all of them).
Survives. *Possible.*

(d) Some X are not Y. This directly contradicts statement 1, which says every X is in Y.
A statement given as true cannot be contradicted. *Impossible.*
]
#ans[(a), (b) and (c) are possible; (d) is impossible.]
]

#trick[
*The possibility killer list.* A possibility conclusion is impossible in exactly two
situations, and no others:
+ it contradicts a given statement outright ("Some X are not Y" against "All X are Y"), or
+ it contradicts a conclusion that *definitely* follows ("All ponds are rivers" when
  some ponds have already been proved not to be rivers).
Everything else is possible. Do not hunt for more.
]

#ex(32, tier: 3, asked: "Goldman Sachs · pattern")[
*Reverse syllogism, both directions.* Which single pair of statements forces *both*
"Some A are not C" and "Some C are not A"? \
(a) Some A are B; No B is C #h(10pt) (b) All A are B; No B is C \
(c) All B are A; No B is C #h(10pt) (d) Some A are B; All B are C
#sol[
*Insight: a "some-not" in both directions needs the two circles to be fully separated.
Only a pair that forces "No A is C" can deliver that.*

(a) Some A are B, No B is C. The A-part of B avoids C, so *some A are not C* — good.
But the rest of A is free to sit inside C, and C may be fully inside A's remainder,
so "Some C are not A" is not forced. Reject.

(b) All A are B, No B is C. All + No = *No A is C*.
From "No A is C": A is non-empty, so some A are not C. First conclusion holds.
Flip it: No C is A. C is non-empty, so some C are not A. Second conclusion holds. Keep.

(c) All B are A, No B is C. B is inside A and avoids C, so some A are not C — good.
But C may sit entirely inside A (just outside B), so "Some C are not A" fails. Reject.

(d) Some A are B, All B are C. This gives "Some A are C", a positive conclusion.
Nothing negative is forced. Reject.
]
#ans[(b) All A are B; No B is C.]
]

#ex(33, tier: 3, asked: "Adobe · pattern")[
*Statements:* Some singers are dancers. Some dancers are actors. Some actors are writers. \
*Question:* How many of these four must be true? \
I. Some singers are actors #h(8pt) II. Some dancers are writers #h(8pt)
III. Some singers are writers #h(8pt) IV. Some actors are dancers
#sol[
*Insight: every statement here is an "I" type. Rule 4 says two particular statements
give nothing. So the only true conclusions are flips of the statements themselves,
not new links.*

Build one single diagram that breaks as much as possible.
Place four circles in a row: singers — dancers — actors — writers.
Let singers overlap dancers only on the far left of dancers.
Let dancers overlap actors only on the far right of dancers.
Let actors overlap writers only on the far right of actors.
Give the overlaps no shared members at all.

Check the statements in this diagram: some singers are dancers — yes.
Some dancers are actors — yes. Some actors are writers — yes. Diagram is legal.

I: singers touch only dancers here, never actors. I is false in this diagram. Not forced.
II: dancers touch actors, but the actor-writer overlap is elsewhere. False here. Not forced.
III: singers are three steps from writers. False here. Not forced.
IV: this is just "Some dancers are actors" flipped. An I-type statement always flips.
Always true.
]
#ans[Exactly one — only IV.]
]

#ex(34, tier: 3, asked: "Uber · pattern")[
*Chain problem.* Statements: All $A_1$ are $A_2$. All $A_2$ are $A_3$. $dots$
All $A_9$ are $A_10$. Also: No $A_10$ is B. \
*Which follow?* I. No $A_3$ is B #h(8pt) II. Some $A_10$ are $A_2$ #h(8pt)
III. No B is $A_1$ #h(8pt) IV. Some $A_1$ are not $A_5$
#sol[
*Insight: nine "All" statements nest into one another, so the whole tower collapses to
$A_1 subset.eq A_2 subset.eq dots subset.eq A_10$. After that, one negative statement
at the top wipes out B for every level.*

I: $A_3 subset.eq A_4 subset.eq dots subset.eq A_10$, so every $A_3$ is an $A_10$.
No $A_10$ is B, so no $A_3$ is B. *Follows.*

II: $A_2 subset.eq A_10$, and $A_2$ is non-empty. Take $a in A_2$.
Then $a in A_10$ and $a in A_2$. So some $A_10$ are $A_2$. *Follows.*

III: "No $A_10$ is B" flips to "No B is $A_10$".
$A_1 subset.eq A_10$, so anything in $A_1$ is in $A_10$, and B avoids all of $A_10$.
So no B is $A_1$. *Follows.*

IV: $A_1 subset.eq A_5$ by the chain, so *every* $A_1$ is an $A_5$.
"Some $A_1$ are not $A_5$" is therefore false, not merely unproved. *Fails.*
]
#ans[I, II and III follow. IV does not.]
]

#ex(35, tier: 3, asked: "D. E. Shaw · pattern")[
*Statements:* Some A are B. All B are C. Some C are D. No D is A. \
*Conclusions:* I. Some C are not D #h(8pt) II. Some B are not D #h(8pt)
III. Some C are A #h(8pt) IV. No B is D
#sol[
*Insight: pick the one element that all four statements can talk about — a thing that is
both A and B. Statement 4 protects it from D, statement 2 pushes it into C.
Everything true here is true because of that single element.*

Statement 1 gives an element $x$ with $x in A$ and $x in B$.
Statement 2: $x in B subset.eq C$, so $x in C$.
Statement 4: No D is A, and $x in A$, so $x in.not D$.

So $x$ is at once: A, B, C, and not D.

I: $x in C$ and $x in.not D$. So some C are not D. *Follows.*
II: $x in B$ and $x in.not D$. So some B are not D. *Follows.*
III: $x in C$ and $x in A$. So some C are A. *Follows.*
IV: this claims *no* B is D. Only the A-part of B is protected.
Counter-diagram: let $B = {x, y}$ where $y$ is in B and in D but not in A.
Some A are B: true ($x$). All B are C: put both $x, y$ inside C — true.
Some C are D: true ($y$). No D is A: true ($y$ is not in A).
Yet $y$ is a B that is a D. *Fails.*
]
#ans[I, II and III follow. IV does not.]
]

#trap[
*"Some are not" versus "No".* In Example 35, conclusions II and IV look like the same
idea in different words. They are not. II needs *one* safe element; IV needs *every*
element to be safe. Almost every hard syllogism hides this gap. When a conclusion starts
with "No", ask: have I protected the *whole* circle, or only the part I traced?
]

#practice(tier: 3, time: "4 min/Q")[
+ Statements: All A are B. Some B are not C. Does "Some A are not C" follow?
  Give a counterexample with real sets, or a proof.

+ Statements: No P is Q. All Q are R. Write down every conclusion that links P and R,
  and show why each rejected candidate fails.

+ Statements: Some X are Y. All Y are Z. No Z is W. Which are possible?
  (a) All X are W (b) Some X are W (c) All Z are Y (d) No X is Z

+ Which single pair forces both "Some A are not C" and "Some C are not A"?
  (a) All B are A; No B is C (b) Some A are B; No B is C
  (c) No A is B; All B are C (d) All A are B; No B is C

+ Statements: Some singers are dancers. Some dancers are actors. Some actors are writers.
  How many of the following must be true? I. Some writers are actors.
  II. Some dancers are singers. III. Some singers are writers. IV. Some actors are singers.

+ Statements: All $B_1$ are $B_2$, All $B_2$ are $B_3$, $dots$, All $B_7$ are $B_8$,
  and Some $B_8$ are K. Which follow? I. Some $B_1$ are K. II. All $B_1$ are $B_8$.
  III. Some $B_8$ are $B_4$. IV. All $B_8$ being K is a possibility.

+ Statements: All P are Q. Some Q are R. No R is S. All S are T. Which follow?
  I. Some Q are not S. II. Some T are not R. III. All P being R is a possibility.
  IV. Some P are not S.
]

#key[
+ *Does not follow.* Take $A = {1}$, $B = {1,2}$, $C = {1}$. All A are B holds; 2 is a B that is not a C, so statement 2 holds; but the only A, namely 1, is a C. The middle term B is never fully covered, so by rule 1 no conclusion is possible at all.

+ *Only "Some R are not P".* Q is non-empty; each Q is an R (statement 2) and no Q is a P (flip of statement 1), so that Q is an R outside P. "No P is R" and "Some P are not R" both die to the diagram with P inside R but outside Q. "Some P are R" dies to the diagram with P wholly outside R. "All R are P" dies because the Q-wedge is R but not P.

+ *(b) and (c) only.* (a) is impossible: some X are Y, all Y are Z, and no Z is W, so those X are not W — "all X are W" is blocked. (b) is possible: the X's outside Y may be W. (c) is possible: set $Z = Y$; both remaining statements still hold. (d) is impossible: the X's that are Y are Z, so X and Z must touch.

+ *(d) All A are B; No B is C.* It forces "No A is C", and a full separation gives a "some-not" in both directions. (a) gives "Some A are not C" but lets C sit entirely inside A. (b) also gives "Some A are not C" only, since C may sit entirely inside the non-B part of A. (c) gives "Some C are not A" but not the reverse, since all of A may lie inside C.

+ *Exactly two — I and II.* Both are simple flips of given "some" statements, and an I-type statement always flips. III and IV need a link across two steps, and two particular statements give nothing; the row-of-circles diagram with disjoint overlaps kills them.

+ *II, III and IV.* The chain gives $B_1 subset.eq B_2 subset.eq dots subset.eq B_8$, so II holds; $B_4 subset.eq B_8$ and $B_4$ is non-empty, so some $B_8$ are $B_4$, giving III. I fails because the K-overlap may sit in the part of $B_8$ outside $B_1$. IV is possible: putting all of $B_8$ inside K breaks nothing.

+ *I, II and III.* I: some Q are R and no R is S, so those Q are not S. II: S is non-empty, every S is T, and no S is R (flip of statement 3), so some T are not R. III: put P inside the $Q inter R$ overlap — all four statements survive, so it is possible. IV fails: put P inside S inside Q, with R a separate slice of Q; then every P is an S.
]

#section[Mixed set — exam conditions]

#practice(tier: 1, time: "25 min for 18 questions")[
Take the statements as true. State which conclusion(s) follow.

+ *Statements:* All chairs are wooden. All wooden things are heavy. \
  *Conclusions:* I. All chairs are heavy. II. Some heavy things are chairs.

+ *Statements:* Some cats are dogs. No dog is a rat. \
  *Conclusions:* I. Some cats are not rats. II. No cat is a rat.

+ *Statements:* All gold is metal. Some metal is costly. \
  *Conclusions:* I. Some gold is costly. II. No gold is costly.

+ *Statements:* No pen is a pencil. All pencils are erasers. \
  *Conclusions:* I. Some erasers are not pens. II. All pens being erasers is a possibility.

+ *Statements:* Some laptops are tablets. All tablets are devices. \
  *Conclusions:* I. Some laptops are devices. II. All laptops are devices.

+ *Statements:* All coders are testers. Some testers are leads. No lead is an intern. \
  *Conclusions:* I. Some testers are not interns. II. Some coders are not interns.

+ *Statements:* Only a few papers are journals. All journals are indexed. \
  *Conclusions:* I. Some papers are indexed. II. All papers are indexed.

+ *Statements:* All A are B. No B is C. \
  *Conclusions:* I. No A is C. II. No C is A. III. Some C are not A.

+ *Statements:* Some roads are lanes. Some lanes are streets. \
  *Conclusions:* I. Some roads are streets. II. No road is a street.

+ *Statements:* All shops are stores. Some stores are malls. All malls are big. \
  *Conclusions:* I. Some stores are big. II. Some shops are big.

+ *Statements:* No fan is a cooler. Some coolers are air conditioners. \
  *Conclusions:* I. Some air conditioners are not fans. II. All air conditioners being fans
  is a possibility.

+ *Statements:* All X are Y. All Y are Z. Some Z are W. \
  *Conclusions:* I. Some X are W. II. All X are Z. III. All Z being X is a possibility.

+ *Statements:* Some pens are inks. All inks are fluids. No fluid is solid. \
  *Conclusions:* I. Some pens are not solids. II. Some fluids are pens.

+ *Statements:* All P are Q. Some Q are not R. \
  *Conclusions:* I. Some P are not R. II. All P are R.

+ *Statements:* Some books are novels. All novels are stories. Some stories are long. \
  *Conclusions:* I. Some books are stories. II. Some books are long.

+ *Statements:* All buses are heavy. No heavy thing is cheap. Some cheap things are useful. \
  *Conclusions:* I. No bus is cheap. II. Some useful things are not heavy.

+ *Statements:* Only a few staff are interns. No intern is permanent. \
  *Conclusions:* I. Some staff are not permanent. II. All staff being permanent is a possibility.

+ *Statements:* All A are B. Some B are C. No C is D. \
  *Conclusions:* I. Some B are not D. II. Some A are not D. III. All A being C is a possibility.
]

#key[
+ *Both.* Chain gives I; flipping I gives II.
+ *Only I.* The cat-dogs are not rats. Cats outside dogs may be rats, so II fails.
+ *Either I or II.* All + Some forces nothing; I and II are the (Some / No) pair on gold and costly.
+ *Both.* Pencils are erasers and are not pens, so I. Pens are only barred from being pencils, so they may all be erasers, giving II.
+ *Only I.* Some + All = Some. The laptops outside tablets need not be devices, so II fails.
+ *Only I.* The tester-leads are not interns, so I. Coders may sit in the lead-free part of testers, so II fails.
+ *Only I.* "Only a few" gives some papers are journals, hence indexed. Its negative half says some papers are not journals, so "all papers are indexed" is not forced.
+ *All three.* All + No = No A is C, giving I; flipping gives II; C is non-empty so III follows from II.
+ *Either I or II.* Two "some" statements force nothing, and the two conclusions are the (Some / No) pair on roads and streets.
+ *Only I.* The mall-stores are big, so I. Shops may avoid the mall slice, so II fails.
+ *Only I.* The cooler-ACs are not fans, so I. Those same ACs can never be fans, so II is impossible.
+ *II and III.* Chain X inside Y inside Z gives II. The W overlap may miss X, so I fails. Setting $X = Y = Z$ keeps every statement true, so III is possible.
+ *Both.* The pen-inks are fluids, hence not solids, giving I; those same things are fluids and pens, giving II.
+ *Either I or II.* Neither is forced (put the non-R part of Q outside P for II to fail, and put P inside R for I to fail), and they are the (All / Some-not) pair on P and R.
+ *Only I.* The book-novels are stories, so I. The "long" slice of stories may miss the books, so II fails.
+ *Both.* Buses sit inside heavy and heavy avoids cheap, so I. The cheap-and-useful things are not heavy, so II.
+ *Only I.* Some staff are interns and no intern is permanent, so I. Those same staff can never be permanent, so II is impossible.
+ *I and III.* The B's that are C are not D, giving I. A may avoid that slice, so II fails. Pushing all of A into the $B inter C$ overlap breaks nothing, so III is possible.
]

#revision[
*THE FOUR TYPES*
#table(columns: (auto, 1fr, 1fr),
  [*Code*], [*Form*], [*Flips to*],
  [A], [All S are P],      [Some P are S],
  [E], [No S is P],        [No P is S; Some S are not P; Some P are not S],
  [I], [Some S are P],     [Some P are S],
  [O], [Some S are not P], [nothing],
)

*COMBINATION TABLE (A links to B, B links to C)*
#table(columns: (auto, auto, 1fr),
  [All A are B],  [All B are C],  [All A are C],
  [All A are B],  [No B is C],    [No A is C],
  [Some A are B], [All B are C],  [Some A are C],
  [Some A are B], [No B is C],    [Some A are not C],
  [No A is B],    [All B are C],  [Some C are not A],
  [All A are B],  [Some B are C], [nothing],
  [Some A are B], [Some B are C], [nothing],
)

*THE FIVE CHECKS* — middle term must be fully covered once; two negatives give nothing;
one negative $=>$ negative conclusion; two "some" give nothing;
one "some" $=>$ "some" conclusion.

*EITHER–OR* — allowed only when both conclusions fail alone AND they form
(All / Some-not), (No / Some) or (Some / Some-not) on the *same two terms*.

*POSSIBILITY* — true unless it contradicts a statement or contradicts a conclusion that
definitely follows. Construct one legal diagram, do not argue.

*NEW-PATTERN WORDS* — "Only a few A are B" = Some are + Some are not.
"Only A are B" = All B are A. "At least some" = Some.

*SHORTCUTS*
+ Trace one element through the chain instead of drawing the whole picture.
+ One counter-diagram kills a "must-follow" conclusion — and usually proves the
  matching possibility conclusion. Reuse the drawing.
+ For reverse syllogism, run each option *forward* through the combination table.
+ "No" conclusions need the whole circle protected, not just the traced element.

*TOP 5 TRAPS*
+ Flipping "All A are B" into "All B are A". Only "Some B are A" is allowed.
+ Trying to flip "Some A are not B". It flips to nothing.
+ All + Some (in that order) — students force a conclusion where there is none.
+ Writing "Either I or II" when the two conclusions use different terms.
+ Marking a possibility conclusion false just because it is not proved. Possibility only
  needs to be *not forbidden*.
]

]
