#import "../lib/style.typ": *

#chapter(num: 7, title: "Time, Speed & Distance", tagline: "One relation, ten disguises.")[

#section[What you need to know]

#formulas[
*The one relation*
$ "speed" = "distance"/"time" quad quad "distance" = "speed" times "time" quad quad "time" = "distance"/"speed" $

*Unit conversion*
$ 1 "km/h" = 5/18 "m/s" quad quad 1 "m/s" = 18/5 "km/h" $
Memorise: 18 km/h = 5 m/s, 36 = 10, 54 = 15, 72 = 20, 90 = 25, 108 = 30.

*Fixed distance*
Speed and time are inversely proportional.
If speeds are in ratio $a : b$, then times are in ratio $b : a$.

*Average speed*
$ "average speed" = "total distance"/"total time" $
Two equal distances at $u$ and $v$: $quad 2 u v \/(u+v)$ #h(6pt) (harmonic mean).
Three equal distances at $u, v, w$: $quad 3 u v w \/(u v + v w + w u)$.
Equal *times* at $u$ and $v$: $quad (u+v)\/2$.

*Late and early*
Same distance, speeds $s_1 < s_2$, time difference $Delta t$ (in hours):
$ d = (s_1 s_2)/(s_2 - s_1) times Delta t $

*Relative speed*
Opposite directions: $u + v$. #h(10pt) Same direction: $|u - v|$.

*Trains* (train length $L$, platform length $P$)
- Crossing a pole or a standing man: time $= L \/ s$
- Crossing a platform or bridge: time $= (L + P) \/ s$
- Crossing a moving person: use relative speed, distance $= L$
- Two trains crossing: distance $= L_1 + L_2$, use relative speed

*Boats and streams* (boat $b$, current $c$)
$ "downstream" = b + c quad quad "upstream" = b - c $
$ b = ("down" + "up")/2 quad quad c = ("down" - "up")/2 $

*Races*
"A beats B by $x$ m" $=>$ when A finishes the race, B has run (race $-x$) m.
"A beats B by $t$ s" $=>$ B needs $t$ more seconds to finish.
"A gives B a start of $x$ m" $=>$ A runs the full race, B runs (race $-x$) m.

*Circular tracks* (track length $C$, speeds $u > v$)
- First meeting, same direction: $C\/(u - v)$
- First meeting, opposite directions: $C\/(u + v)$
- Both back at the start together: LCM of the two lap times
- Distinct meeting points (speed ratio $a : b$ in lowest terms):
  $a + b$ if opposite, $a - b$ if same direction

*Meeting then continuing*
Two bodies start at the same time towards each other and meet.
If afterwards they need $t_1$ and $t_2$ more hours:
$ "time to meet" = sqrt(t_1 t_2) quad quad "speed"_1 : "speed"_2 = sqrt(t_2) : sqrt(t_1) $
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[Convert 72 km/h into m/s.]
#sol[$72 times 5/18 = (72 times 5)/18 = 360/18 = 20$ m/s.]
#ans[20 m/s]

#ex(2, tier: 0)[Convert 25 m/s into km/h.]
#sol[$25 times 18/5 = (25 times 18)/5 = 450/5 = 90$ km/h.]
#ans[90 km/h]

#ex(3, tier: 0)[A car covers 240 km in 4 hours. Find its speed.]
#sol[$"speed" = 240/4 = 60$ km/h.]
#ans[60 km/h]

#ex(4, tier: 0)[A bus runs at 45 km/h for 2.5 hours. How far does it go?]
#sol[$"distance" = 45 times 2.5 = 112.5$ km.]
#ans[112.5 km]

#ex(5, tier: 0)[How long does a scooter at 60 km/h take to cover 150 km?]
#sol[$"time" = 150/60 = 2.5$ hours $= 2$ hours 30 minutes.]
#ans[2 hours 30 minutes]

#ex(6, tier: 0)[A train 180 m long runs at 54 km/h. How long does it take to pass a pole?]
#sol[
Speed $= 54 times 5/18 = 15$ m/s. \
Distance to cover $=$ its own length $= 180$ m. \
Time $= 180/15 = 12$ s.
]
#ans[12 seconds]

#ex(7, tier: 0)[A boat rows at 12 km/h in still water. The stream flows at 3 km/h. Find the downstream and upstream speeds.]
#sol[
Downstream $= 12 + 3 = 15$ km/h. \
Upstream $= 12 - 3 = 9$ km/h.
]
#ans[15 km/h and 9 km/h]

#ex(8, tier: 0)[Two cyclists ride towards each other at 20 km/h and 30 km/h. What is their relative speed?]
#sol[Opposite directions, so add: $20 + 30 = 50$ km/h.]
#ans[50 km/h]

#section[Tier 1 — Service companies]
#tier-header(1)

#ex(9, tier: 1, asked: "TCS NQT pattern")[A train covers 480 km at a steady speed. If its speed had been 8 km/h more, the trip would have taken 3 hours less. Find the original speed.]
#sol[
Let the original speed be $s$ km/h. \
Original time $= 480\/s$. New time $= 480\/(s+8)$.

$ 480/s - 480/(s+8) = 3 $

Multiply both sides by $s(s+8)$:
$ 480(s+8) - 480 s = 3 s (s+8) $
$ 480 times 8 = 3 s^2 + 24 s $
$ 3840 = 3 s^2 + 24 s $

Divide by 3:
$ 1280 = s^2 + 8 s quad => quad s^2 + 8 s - 1280 = 0 $

$ s = (-8 + sqrt(64 + 5120))/2 = (-8 + sqrt(5184))/2 = (-8 + 72)/2 = 64/2 = 32 $

Check: $480\/32 = 15$ h and $480\/40 = 12$ h. Difference 3 h. Correct.
]
#ans[32 km/h]

#ex(10, tier: 1, asked: "Infosys pattern")[A man drives 60 km at 30 km/h and the next 60 km at 60 km/h. Find his average speed for the whole 120 km.]
#sol[
Time for first part $= 60/30 = 2$ h. \
Time for second part $= 60/60 = 1$ h. \
Total time $= 3$ h. Total distance $= 120$ km.
$ "average speed" = 120/3 = 40 " km/h" $
Harmonic-mean check: $(2 times 30 times 60)/(30+60) = 3600/90 = 40$ km/h.
]
#ans[40 km/h]

#trap[
Average speed for two equal distances is *not* $(30+60)\/2 = 45$ km/h.
The slower leg eats more time, so the average always sits closer to the slower speed.
Use $2 u v \/(u+v)$ only when the two *distances* are equal.
]

#ex(11, tier: 1, asked: "Wipro pattern")[Walking at $4\/5$ of his usual speed, a student reaches school 10 minutes late. Find his usual time.]
#sol[
Speed ratio (new : usual) $= 4 : 5$. \
For a fixed distance, time ratio is the flip: (new : usual) $= 5 : 4$.

Let usual time $= 4k$ minutes. Then new time $= 5k$ minutes. \
Extra time $= 5k - 4k = k = 10$ minutes.

Usual time $= 4k = 4 times 10 = 40$ minutes.
]
#ans[40 minutes]

#trick[
"Speed becomes $a\/b$ of usual" $=>$ "time becomes $b\/a$ of usual".
Extra time $=(b\/a - 1)$ of the usual time. Here $5\/4 - 1 = 1\/4$, and $1\/4$ of the usual time is 10 min, so usual time $= 40$ min. One line, no equations.
]

#ex(12, tier: 1, asked: "Capgemini pattern")[A train 240 m long passes a platform 360 m long in 30 seconds. Find its speed in km/h.]
#sol[
Distance covered $= 240 + 360 = 600$ m. \
Speed $= 600/30 = 20$ m/s. \
In km/h: $20 times 18/5 = 360/5 = 72$ km/h.
]
#ans[72 km/h]

#trap[
A train crossing a *pole* covers only its own length.
A train crossing a *platform* covers its length plus the platform's length.
Students lose easy marks by using the wrong one.
]

#ex(13, tier: 1, asked: "TCS NQT pattern")[Two trains, 150 m and 200 m long, run on parallel tracks in opposite directions at 60 km/h and 40 km/h. How long do they take to cross each other completely?]
#sol[
Opposite directions, so relative speed $= 60 + 40 = 100$ km/h. \
In m/s: $100 times 5/18 = 500/18 = 250/9$ m/s.

Distance to cover $= 150 + 200 = 350$ m.
$ "time" = 350/(250\/9) = 350 times 9/250 = 3150/250 = 12.6 " s" $
]
#ans[12.6 seconds]

#ex(14, tier: 1, asked: "Accenture pattern")[Train A is 180 m long and runs at 72 km/h. Train B is 120 m long and runs at 54 km/h on a parallel track in the same direction. How long does A take to overtake B completely?]
#sol[
Same direction, so relative speed $= 72 - 54 = 18$ km/h. \
In m/s: $18 times 5/18 = 5$ m/s.

Distance to cover $= 180 + 120 = 300$ m.
$ "time" = 300/5 = 60 " s" $
]
#ans[60 seconds]

#ex(15, tier: 1, asked: "Cognizant pattern")[A boat covers 36 km downstream in 2 hours and the same 36 km upstream in 3 hours. Find the speed of the boat in still water and the speed of the stream.]
#sol[
Downstream speed $= 36/2 = 18$ km/h. \
Upstream speed $= 36/3 = 12$ km/h.

$ b = (18 + 12)/2 = 30/2 = 15 " km/h" $
$ c = (18 - 12)/2 = 6/2 = 3 " km/h" $
]
#ans[Boat 15 km/h, stream 3 km/h]

#ex(16, tier: 1, asked: "Infosys pattern")[A boat's speed in still water is 10 km/h and the stream flows at 2 km/h. How long does the boat take to go 48 km downstream and come back?]
#sol[
Downstream speed $= 10 + 2 = 12$ km/h $=>$ time $= 48/12 = 4$ h. \
Upstream speed $= 10 - 2 = 8$ km/h $=>$ time $= 48/8 = 6$ h. \
Total $= 4 + 6 = 10$ h.
]
#ans[10 hours]

#ex(17, tier: 1, asked: "Wipro pattern")[In a 1000 m race A beats B by 100 m. In a 1000 m race B beats C by 50 m. By how much does A beat C in a 1000 m race?]
#sol[
When A runs 1000 m, B runs 900 m. \
When B runs 1000 m, C runs 950 m.

So when B runs 900 m, C runs
$ 900 times 950/1000 = 900 times 0.95 = 855 " m" $

A finishes 1000 m at the moment C has run 855 m. \
A beats C by $1000 - 855 = 145$ m.
]
#ans[145 m]

#ex(18, tier: 1, asked: "Accenture pattern")[In a 400 m race A beats B by 16 m or, equivalently, by 4 seconds. Find the time each runner takes for 400 m.]
#sol[
"Beats by 16 m or 4 s" means B needs 4 more seconds to cover the last 16 m.

B's speed $= 16/4 = 4$ m/s. \
B's time for 400 m $= 400/4 = 100$ s. \
A's time $= 100 - 4 = 96$ s.
]
#ans[A: 96 s, B: 100 s]

#trap[
"A beats B by 16 m" and "A beats B by 4 s" are two different measurements of the same gap.
Do not add them. Use them together to get B's speed: metres $div$ seconds.
]

#ex(19, tier: 1, asked: "TCS NQT pattern")[Two cities are 300 km apart. A car leaves city A at 60 km/h towards B. At the same moment another car leaves B at 40 km/h towards A. When do they meet and how far from A?]
#sol[
They approach each other, so the gap closes at $60 + 40 = 100$ km/h.
$ "time to meet" = 300/100 = 3 " hours" $
Distance from A $= 60 times 3 = 180$ km. \
Check: from B, $40 times 3 = 120$ km, and $180 + 120 = 300$ km. Correct.
]
#ans[After 3 hours, 180 km from A]

#ex(20, tier: 1, asked: "Capgemini pattern")[Two runners start together from the same point on a 400 m circular track. Their speeds are 5 m/s and 3 m/s. After how long do they first meet again if (a) they run in the same direction, (b) they run in opposite directions?]
#sol[
*(a) Same direction.* The faster must gain one full lap on the slower. \
Relative speed $= 5 - 3 = 2$ m/s.
$ "time" = 400/2 = 200 " s" $

*(b) Opposite directions.* Together they must cover one full lap. \
Relative speed $= 5 + 3 = 8$ m/s.
$ "time" = 400/8 = 50 " s" $
]
#ans[(a) 200 s #h(8pt) (b) 50 s]

#trick[
On a circular track the *first meeting* question is always "track length $div$ relative speed".
Same direction subtract, opposite direction add. That is the whole idea.
]

#practice(tier: 1, time: "60 s/Q")[
+ Convert 108 km/h into m/s.
+ A cyclist covers 90 km in 4 hours 30 minutes. Find his speed.
+ A car travels from P to Q at 40 km/h and returns at 60 km/h. Find the average speed for the round trip.
+ A train 150 m long runs at 90 km/h. How long does it take to cross a pole?
+ A train 200 m long crosses a bridge 400 m long in 24 seconds. Find its speed in km/h.
+ Two trains 120 m and 180 m long run in opposite directions at 42 km/h and 30 km/h. Find the time they take to cross each other.
+ A boat covers 24 km downstream in 2 hours and 24 km upstream in 3 hours. Find the still-water speed and the stream speed.
+ A man rows at 8 km/h in still water. The stream flows at 2 km/h. How long does he take to row 30 km downstream?
+ Walking at $3\/4$ of his usual speed, a man reaches office 15 minutes late. Find his usual time.
+ In a 400 m race A beats B by 40 m. Find the ratio of their speeds.
+ Two cars start at the same time from towns 420 km apart and move towards each other at 50 km/h and 70 km/h. After how long do they meet?
+ A train at 60 km/h crosses a man walking at 6 km/h in the same direction in 12 seconds. Find the length of the train.
+ A 90 km journey is covered with $1\/3$ of the distance at 30 km/h and the rest at 45 km/h. Find the total time.
+ A runner takes 5 minutes for one lap of a 1000 m track. Find his speed in km/h.
+ Two runners start together from one point of a 300 m circular track and run in opposite directions at 4 m/s and 6 m/s. When do they first meet?
]

#key[
+ *30 m/s* — $108 times 5\/18 = 30$.
+ *20 km/h* — 4 h 30 min $= 4.5$ h; $90 \/ 4.5 = 20$.
+ *48 km/h* — $2 times 40 times 60 \/ 100 = 4800\/100 = 48$. Not 50.
+ *6 s* — $90$ km/h $= 25$ m/s; $150\/25 = 6$.
+ *90 km/h* — $(200+400)\/24 = 25$ m/s $= 25 times 18\/5 = 90$.
+ *15 s* — relative $72$ km/h $= 20$ m/s; $(120+180)\/20 = 15$.
+ *Boat 10 km/h, stream 2 km/h* — down 12, up 8; $(12+8)\/2 = 10$, $(12-8)\/2 = 2$.
+ *3 hours* — downstream speed $8+2 = 10$; $30\/10 = 3$.
+ *45 minutes* — time ratio $4:3$ flipped; extra $1\/3$ of usual $= 15$ min, so usual $= 45$ min.
+ *10 : 9* — same time, so speeds are as distances: $400 : 360 = 10 : 9$.
+ *3.5 hours* — closing speed $120$ km/h; $420\/120 = 3.5$.
+ *180 m* — relative $54$ km/h $= 15$ m/s; $15 times 12 = 180$.
+ *2 hours 20 minutes* — $30\/30 = 1$ h and $60\/45 = 4\/3$ h; total $7\/3$ h.
+ *12 km/h* — $1000$ m in $300$ s $= 10\/3$ m/s $= (10\/3) times 18\/5 = 12$.
+ *30 s* — relative $4+6 = 10$ m/s; $300\/10 = 30$.
]

#section[Tier 2 — Singapore & Thailand]
#tier-header(2)

#ex(21, tier: 2, asked: "Grab · pattern")[A driver takes a 24 km fare. The first 8 km are in heavy traffic at 16 km/h. The remaining 16 km are on the expressway at 48 km/h. Find the average speed for the whole trip.]
#sol[
Time in traffic $= 8/16 = 0.5$ h. \
Time on expressway $= 16/48 = 1/3$ h.

Total time $= 1/2 + 1/3 = 3/6 + 2/6 = 5/6$ h.
$ "average speed" = 24/(5\/6) = 24 times 6/5 = 144/5 = 28.8 " km/h" $
]
#ans[28.8 km/h]

#ex(22, tier: 2, asked: "Shopee · pattern")[A rider leaves the hub at 09:00 and rides at 30 km/h along a fixed route. A second rider leaves the same hub at 09:30 along the same route at 45 km/h. At what time does the second rider catch the first, and how far from the hub?]
#sol[
Head start of the first rider in 30 minutes $= 30 times 0.5 = 15$ km. \
The gap closes at $45 - 30 = 15$ km/h.
$ "catch-up time" = 15/15 = 1 " hour after 09:30" = 10:30 $
Distance from hub $= 45 times 1 = 45$ km. \
Check: the first rider has ridden from 09:00 to 10:30, that is 1.5 h at 30 km/h $= 45$ km. Correct.
]
#ans[10:30, at 45 km from the hub]

#ex(23, tier: 2, asked: "GIC · pattern")[A train crosses a man standing on a platform in 9 seconds. It crosses the whole 240 m platform in 24 seconds. Find the length and the speed of the train.]
#sol[
Let the length be $L$ m and the speed be $s$ m/s.

Crossing the man: $L = 9 s$. \
Crossing the platform: $L + 240 = 24 s$.

Subtract the first from the second:
$ 240 = 24 s - 9 s = 15 s quad => quad s = 240/15 = 16 " m/s" $

Then $L = 9 times 16 = 144$ m. \
Speed in km/h $= 16 times 18/5 = 288/5 = 57.6$ km/h.
]
#ans[Length 144 m, speed 16 m/s = 57.6 km/h]

#trick[
Two crossing times, one train: *subtract the two equations*.
The train length cancels and you are left with
(platform length) $=$ (difference of times) $times$ speed.
]

#ex(24, tier: 2, asked: "Agoda · pattern")[Two express trains start at the same moment from two cities and travel towards each other. After they pass each other, the first needs 9 more hours to finish its trip and the second needs 4 more hours. The first train runs at 40 km/h. Find the second train's speed and the distance between the cities.]
#sol[
Let the speeds be $a = 40$ and $b$, and let $t$ be the time until they meet.

After meeting, train 1 must still cover the distance train 2 already covered, that is $b t$:
$ (b t)/a = 9 quad => quad b t = 9 a $

After meeting, train 2 must still cover $a t$:
$ (a t)/b = 4 quad => quad a t = 4 b $

Multiply the two original relations:
$ (b t)/a times (a t)/b = 9 times 4 quad => quad t^2 = 36 quad => quad t = 6 " h" $

From $a t = 4 b$: $quad 40 times 6 = 4 b quad => quad b = 240/4 = 60$ km/h.

Distance $= (a + b) times t = (40 + 60) times 6 = 600$ km.

Check: train 1 still has $60 times 6 = 360$ km, and $360\/40 = 9$ h. \
Train 2 still has $40 times 6 = 240$ km, and $240\/60 = 4$ h. Both correct.
]
#ans[Second train 60 km/h; cities 600 km apart]

#trick[
Meeting problems of this type collapse to two facts:
$ t = sqrt(t_1 t_2) quad quad "speed"_1 : "speed"_2 = sqrt(t_2) : sqrt(t_1) $
Here $t = sqrt(9 times 4) = 6$ h and $40 : b = sqrt(4) : sqrt(9) = 2 : 3$, so $b = 60$.
]

#ex(25, tier: 2, asked: "DBS · pattern")[A river ferry travels 45 km downstream and then 45 km back upstream, taking 8 hours in all. The current runs at 3 km/h. Find the ferry's speed in still water.]
#sol[
Let the still-water speed be $b$ km/h.
$ 45/(b+3) + 45/(b-3) = 8 $
Combine the left side over $(b+3)(b-3) = b^2 - 9$:
$ (45(b-3) + 45(b+3))/(b^2 - 9) = 8 $
$ (45 b - 135 + 45 b + 135)/(b^2 - 9) = 8 quad => quad (90 b)/(b^2-9) = 8 $
$ 90 b = 8 b^2 - 72 quad => quad 8 b^2 - 90 b - 72 = 0 $
Divide by 2:
$ 4 b^2 - 45 b - 36 = 0 $
$ b = (45 + sqrt(2025 + 576))/8 = (45 + sqrt(2601))/8 = (45 + 51)/8 = 96/8 = 12 $

Check: downstream $45\/15 = 3$ h, upstream $45\/9 = 5$ h, total 8 h. Correct.
]
#ans[12 km/h]

#ex(26, tier: 2, asked: "Sea Group · pattern")[A courier van leaves the depot at 07:30. It drives 200 km at 50 km/h, takes a 1 hour break, then drives another 120 km at 40 km/h. Find the arrival time and the average speed for the whole run, counting the break.]
#sol[
Leg 1 time $= 200/50 = 4$ h. \
Break $= 1$ h. \
Leg 2 time $= 120/40 = 3$ h.

Total elapsed time $= 4 + 1 + 3 = 8$ h. \
Arrival $= 07:30 + 8 "h" = 15:30$.

Total distance $= 200 + 120 = 320$ km.
$ "average speed" = 320/8 = 40 " km/h" $
]
#ans[Arrives 15:30; average 40 km/h]

#trap[
A rest break adds to *time* but not to *distance*.
If the question says "including stoppages", the break must go into the denominator.
Excluding the break here the average would be $320\/7 approx 45.7$ km/h, a different answer.
]

#ex(27, tier: 2, asked: "SCB · pattern")[A train 180 m long runs at 63 km/h. A jogger runs at 9 km/h on a path beside the track. How long does the train take to pass him if (a) he runs in the same direction, (b) he runs in the opposite direction?]
#sol[
The train must cover only its own length, 180 m, relative to the jogger.

*(a) Same direction.* Relative speed $= 63 - 9 = 54$ km/h $= 54 times 5/18 = 15$ m/s.
$ "time" = 180/15 = 12 " s" $

*(b) Opposite direction.* Relative speed $= 63 + 9 = 72$ km/h $= 72 times 5/18 = 20$ m/s.
$ "time" = 180/20 = 9 " s" $
]
#ans[(a) 12 s #h(8pt) (b) 9 s]

#ex(28, tier: 2, asked: "LINE MAN · pattern")[A cyclist rides up a hill road at 12 km/h and comes down the same road at 20 km/h. The whole ride takes 4 hours. Find the average speed and the one-way length of the road.]
#sol[
The two distances are equal, so use the harmonic mean:
$ "average speed" = (2 times 12 times 20)/(12 + 20) = 480/32 = 15 " km/h" $

Total distance $= "average speed" times "total time" = 15 times 4 = 60$ km. \
One-way length $= 60/2 = 30$ km.

Check: up $30\/12 = 2.5$ h, down $30\/20 = 1.5$ h, total 4 h. Correct.
]
#ans[15 km/h; road is 30 km one way]

#ex(29, tier: 2, asked: "Razer · pattern")[Two testers ride on a 600 m circular test track, starting together from the same point and going in the same direction at 8 m/s and 5 m/s.
(a) When do they first meet again?
(b) When are they next together at the starting point?
(c) How many distinct points of the track will they ever meet at?]
#sol[
*(a)* Relative speed $= 8 - 5 = 3$ m/s. The faster needs to gain one lap.
$ "time" = 600/3 = 200 " s" $

*(b)* Lap time of the faster $= 600/8 = 75$ s. Lap time of the slower $= 600/5 = 120$ s. \
$75 = 3 times 5^2$, $quad 120 = 2^3 times 3 times 5$. \
LCM $= 2^3 times 3 times 5^2 = 600$ s.

*(c)* Speeds in lowest terms are $8 : 5$. Same direction, so the number of distinct meeting points is $8 - 5 = 3$.

Check: meetings happen at $t = 200, 400, 600$ s. \
At 200 s the faster is at $8 times 200 = 1600$ m, and $1600 - 2 times 600 = 400$ m. \
At 400 s: $3200 - 5 times 600 = 200$ m. \
At 600 s: $4800 - 8 times 600 = 0$ m. \
The three points are the 400 m mark, the 200 m mark and the start.
]
#ans[(a) 200 s #h(8pt) (b) 600 s #h(8pt) (c) 3 points]

#ex(30, tier: 2, asked: "Grab · pattern")[A commuter leaves home at the same time every day. At 40 km/h she reaches the office 8 minutes late. At 50 km/h she reaches 4 minutes early. Find the distance to the office.]
#sol[
The two trips differ by $8 + 4 = 12$ minutes $= 12/60 = 1/5$ h.

Let the distance be $d$ km.
$ d/40 - d/50 = 1/5 $
LCM of 40 and 50 is 200:
$ (5 d)/200 - (4 d)/200 = 1/5 quad => quad d/200 = 1/5 $
$ d = 200/5 = 40 " km" $

Check: $40\/40 = 1$ h $= 60$ min; $40\/50 = 0.8$ h $= 48$ min. Difference 12 min. Correct.
]
#ans[40 km]

#trick[
Late-and-early questions always reduce to
$ d = (s_1 s_2)/(s_2 - s_1) times Delta t $
with $Delta t$ in hours. Here $d = (40 times 50)\/10 times 1\/5 = 200 times 1\/5 = 40$ km.
]

#practice(tier: 2, time: "100 s/Q")[
+ A driver covers 30 km at 45 km/h, waits 20 minutes, then covers 20 km at 40 km/h. Find the total time and the average speed for the 50 km including the wait.
+ A ferry takes 5 hours downstream and 7 hours upstream between two ports 210 km apart. Find the ferry's still-water speed and the current's speed.
+ Two trains leave two cities 350 km apart at 08:00 and travel towards each other at 80 km/h and 60 km/h. At what time do they meet, and how far from the first city?
+ A train crosses a standing man in 8 seconds and a 264 m platform in 20 seconds. Find its length and its speed in km/h.
+ A bus averages 36 km/h including stops and 45 km/h excluding stops. How many minutes per hour does it stop?
+ A cyclist rides out at 15 km/h and returns along the same road at 10 km/h. The whole ride takes 5 hours. Find the one-way distance.
+ Two riders start together on a 1.2 km circular track in the same direction at 18 km/h and 12 km/h. When do they first meet again, and how many laps has the faster rider done by then?
+ A van leaves a depot at 09:00 at 40 km/h. A motorbike leaves the same depot at 10:00 at 60 km/h on the same road. When and where does the bike catch the van?
+ In a 1200 m race A beats B by 120 m. In a 1200 m race B beats C by 100 m. By how much does A beat C over 1200 m?
+ A man rows at 9 km/h in still water. The river flows at 3 km/h. He rows to a point downstream and returns, taking 5 hours in all. How far is the point?
+ A train running at 54 km/h takes 60 seconds to pass a 150 m train moving at 36 km/h in the same direction. Find the length of the first train.
+ A car covers a certain distance at 60 km/h and returns at 40 km/h. The return trip takes 1 hour longer. Find the one-way distance.
]

#key[
+ *1.5 h; $33 1\/3$ km/h* — $40 + 20 + 30 = 90$ min; $50 \/ 1.5 = 100\/3$.
+ *36 km/h and 6 km/h* — down $210\/5 = 42$, up $210\/7 = 30$; half-sum 36, half-difference 6.
+ *10:30, 200 km* — closing speed 140; $350\/140 = 2.5$ h; $80 times 2.5 = 200$.
+ *176 m; 79.2 km/h* — $264 = (20-8)s => s = 22$ m/s; $L = 8 times 22 = 176$; $22 times 18\/5 = 79.2$.
+ *12 minutes* — in one hour it does 36 km, which needs $36\/45$ h $= 48$ min of motion.
+ *30 km* — average $= 2 times 15 times 10\/25 = 12$; total $12 times 5 = 60$; half is 30.
+ *12 minutes; 3 laps* — relative 6 km/h $= 5\/3$ m/s; $1200 \/ (5\/3) = 720$ s; faster covers $5 times 720 = 3600$ m $= 3$ laps.
+ *12:00, 120 km from the depot* — head start 40 km, closing 20 km/h, so 2 h after 10:00.
+ *210 m* — B runs 1080 when A runs 1200; C runs $1080 times 1100\/1200 = 990$; $1200-990 = 210$.
+ *20 km* — $d\/12 + d\/6 = 5 => 3d = 60$.
+ *150 m* — relative 18 km/h $= 5$ m/s; total length $5 times 60 = 300$; $300 - 150 = 150$.
+ *120 km* — $d\/40 - d\/60 = 1 => d\/120 = 1$.
]

#section[Tier 3 — Product companies]
#tier-header(3)

#ex(31, tier: 3, asked: "Google · pattern")[Two ships are 180 km apart and sail straight towards each other at 30 km/h and 15 km/h. A survey drone starts from the first ship at the same moment, flies at 60 km/h to the second ship, turns instantly, flies back to the first, and keeps shuttling until the ships meet. What total distance does the drone fly?]
#sol[
*Insight: do not chase the shuttle legs. The drone flies for exactly as long as the ships take to meet, so only the total time matters.*

The gap closes at $30 + 15 = 45$ km/h.
$ "time until the ships meet" = 180/45 = 4 " hours" $
The drone flies for the whole of those 4 hours without stopping.
$ "distance" = 60 times 4 = 240 " km" $
]
#ans[240 km]

#note[The individual legs form an infinite geometric series. Summing it gives the same 240 km, but the time argument gets there in one line.]

#ex(32, tier: 3, asked: "Amazon · pattern")[A delivery van must average 60 km/h over a 120 km route. It covers the first 60 km at 30 km/h. What speed must it hold over the remaining 60 km to hit the target average?]
#sol[
*Insight: an average speed is a constraint on total time, and the time budget can be spent before the trip is over.*

Time budget for the whole route:
$ 120/60 = 2 " hours" $

Time already spent on the first half:
$ 60/30 = 2 " hours" $

The full budget is gone and 60 km still remain. Even at infinite speed the second half takes more than zero time, so the total time is strictly greater than 2 hours.

Algebra says the same thing. Let the needed speed be $v$:
$ (2 times 30 times v)/(30 + v) = 60 quad => quad 60 v = 60(30 + v) quad => quad 60 v = 1800 + 60 v $
$ 0 = 1800 $
A false statement, so no such $v$ exists.
]
#ans[Impossible — the target cannot be reached]

#trap[
If the first half of a journey is done at half the required average speed, the trip is already lost.
More generally, with equal halves at $u$ and $v$, the average $2 u v \/(u+v)$ is always less than $2u$. So the average can never be doubled by the second half alone.
]

#ex(33, tier: 3, asked: "Goldman Sachs · pattern")[A rower is going upstream. As he passes under a bridge his sealed water bottle falls into the river and floats away. He keeps rowing upstream for 1 hour, then turns round and rows downstream at the same effort. He picks up the bottle 6 km downstream of the bridge. Find the speed of the current.]
#sol[
*Insight: measure everything relative to the water. Relative to the water the bottle never moves, and the rower's speed is the same both ways.*

Let the rower's speed relative to the water be $r$ and the current be $c$.

Relative to the water:
- Going up, he moves away from the bottle at $r$ for 1 hour.
- Coming back, he closes the same relative gap at $r$, so it also takes 1 hour.

Total time from the drop to the pick-up $= 1 + 1 = 2$ hours.

The bottle itself just drifts with the current. In those 2 hours it travelled 6 km.
$ c = 6/2 = 3 " km/h" $

Ground check with $r = 7$ km/h, $c = 3$ km/h. Upstream speed $= 4$ km/h, so in 1 h he is 4 km above the bridge and the bottle is 3 km below it: gap 7 km. Downstream he does 10 km/h, the bottle 3 km/h, so the gap closes at 7 km/h, taking 1 h. At that moment the bottle has drifted $3 times 2 = 6$ km. Correct, and $r$ never entered the answer.
]
#ans[3 km/h]

#ex(34, tier: 3, asked: "Microsoft · pattern")[Two athletes run round a circular track starting together from the same point. Their speeds are in the ratio $5 : 3$. How many distinct points of the track do they ever meet at, (a) running in opposite directions, (b) running in the same direction? Explain why.]
#sol[
*Insight: meetings are equally spaced in time, so the meeting points are equally spaced round the track. Count how many gaps fit into one lap.*

Let the track length be $C$ and the speeds be $5k$ and $3k$.

*(a) Opposite directions.* They meet every $C\/(5k + 3k) = C\/(8k)$ seconds. \
Between two meetings the faster athlete advances
$ 5k times C/(8k) = (5 C)/8 $
So each new meeting point sits $5C\/8$ further round the track than the previous one. \
The points are $0, 5C\/8, 10C\/8, 15C\/8, dots$, that is $0, 5\/8, 2\/8, 7\/8, 4\/8, 1\/8, 6\/8, 3\/8$ of a lap, then back to 0. \
Since $gcd(5, 8) = 1$, the multiples of $5\/8$ run through all 8 eighths before repeating.
*8 distinct points.*

*(b) Same direction.* They meet every $C\/(5k - 3k) = C\/(2k)$ seconds, and the faster advances
$ 5k times C/(2k) = (5 C)/2 = 2C + C/2 $
which is half a lap past the previous point. The points are $0, C\/2, 0, C\/2, dots$
*2 distinct points.*

General rule, with the speed ratio written in lowest terms as $a : b$: \
opposite directions give $a + b$ points, same direction gives $a - b$ points.
]
#ans[(a) 8 points #h(8pt) (b) 2 points]

#trick[
Always reduce the speed ratio first. Speeds $6 : 4$ behave like $3 : 2$, giving 5 meeting points in opposite directions and 1 in the same direction, not 10 and 2.
]

#ex(35, tier: 3, asked: "D. E. Shaw · pattern")[Two friends must travel 60 km together and arrive at the same time. They have one motorbike, which carries only one person, at 30 km/h. Walking speed is 6 km/h. The bike may be parked anywhere on the road and picked up later. What is the least time in which both can arrive?]
#sol[
*Insight: the bike must never sit idle any longer than necessary, and by symmetry the best plan gives each friend the same riding distance.*

Plan: A rides the first $x$ km, parks the bike and walks the rest. B walks the first $x$ km, finds the bike and rides the remaining $60 - x$ km.

A's time: $quad x/30 + (60 - x)/6$ \
B's time: $quad x/6 + (60 - x)/30$

They must arrive together, so set the two equal:
$ x/30 + (60-x)/6 = x/6 + (60-x)/30 $
Multiply everything by 30:
$ x + 5(60 - x) = 5 x + (60 - x) $
$ x + 300 - 5x = 5x + 60 - x $
$ 300 - 4x = 4x + 60 $
$ 240 = 8x quad => quad x = 30 " km" $

Common arrival time:
$ 30/30 + 30/6 = 1 + 5 = 6 " hours" $

Feasibility check: A parks the bike at the 30 km mark after 1 hour. B walks 30 km at 6 km/h and reaches that mark at hour 5, when the bike is waiting. B then rides 30 km in 1 hour and arrives at hour 6, together with A. Valid.

Compare: both walking the whole way would take $60\/6 = 10$ hours. The shared bike saves 4 hours.
]
#ans[6 hours]

#ex(36, tier: 3, asked: "Uber · pattern")[A man walks along a straight bus route. Buses run in both directions at the same constant speed and at equal time intervals. A bus overtakes him every 10 minutes, and a bus meets him head-on every 6 minutes. Find the interval between consecutive buses and the ratio of bus speed to walking speed.]
#sol[
*Insight: the distance between two consecutive buses is fixed. Each encounter means the man and one bus together closed exactly that fixed gap.*

Let the bus speed be $v$, the man's speed be $u$, and the interval between buses be $T$ minutes. \
Consecutive buses on the same side are a distance $v T$ apart.

Buses coming from behind close the gap at $v - u$:
$ (v - u) times 10 = v T $

Buses coming towards him close the gap at $v + u$:
$ (v + u) times 6 = v T $

The right sides are equal, so:
$ 10 v - 10 u = 6 v + 6 u $
$ 4 v = 16 u quad => quad v = 4 u $

Substitute into the first relation:
$ (4u - u) times 10 = 4 u T quad => quad 30 u = 4 u T quad => quad T = 30/4 = 7.5 " minutes" $

Check with $u = 5$ km/h, $v = 20$ km/h. Gap $= 20 times 7.5\/60 = 2.5$ km. \
Overtaking: $2.5 \/ 15$ h $= 10$ min. Head-on: $2.5 \/ 25$ h $= 6$ min. Both correct.
]
#ans[Interval 7.5 minutes; bus speed is 4 times walking speed]

#trick[
For this family, with overtaking gap $p$ and head-on gap $q$:
$ T = (2 p q)/(p + q) quad quad v/u = (p + q)/(p - q) $
Here $T = (2 times 10 times 6)\/16 = 120\/16 = 7.5$ min and $v\/u = 16\/4 = 4$.
]

#ex(37, tier: 3, asked: "Adobe · pattern")[An airport walkway is 120 m long. A traveller who walks along it while it moves takes 40 seconds end to end. Standing still on it takes 60 seconds. How long would the same traveller take to walk 120 m on the fixed floor beside it?]
#sol[
*Insight: speeds add, times do not. Convert every statement into a speed first.*

Walkway speed (standing still):
$ 120/60 = 2 " m/s" $

Walking while it moves (speeds add):
$ 120/40 = 3 " m/s" $

So the traveller's own walking speed is
$ 3 - 2 = 1 " m/s" $

On the fixed floor:
$ "time" = 120/1 = 120 " s" $
]
#ans[120 seconds]

#trap[
Do not subtract the times: $60 - 40 = 20$ s is wrong.
Time is not additive, speed is. Convert to m/s, subtract, convert back.
]

#ex(38, tier: 3, asked: "Google · pattern")[Three runners start together from the same point of a 600 m circular track and run in the same direction at 8 m/s, 5 m/s and 2 m/s.
(a) After how long are all three together again for the first time?
(b) After how long are all three back at the starting point together?]
#sol[
*Insight: three runners are together exactly when every pair is together. So find each pair's meeting period, then take the LCM. Being together anywhere is a weaker condition than being together at the start.*

*(a) Together anywhere.* For each pair, the meeting period is $600 div$ (speed difference).
$ (8, 5): quad 600/3 = 200 " s" quad (8, 2): quad 600/6 = 100 " s" quad (5, 2): quad 600/3 = 200 " s" $
All three coincide at the common multiples of 200, 100 and 200. \
$"LCM"(200, 100, 200) = 200$ s.

Check at $t = 200$ s: \
Runner 1: $8 times 200 = 1600$ m; $1600 - 2 times 600 = 400$ m. \
Runner 2: $5 times 200 = 1000$ m; $1000 - 600 = 400$ m. \
Runner 3: $2 times 200 = 400$ m. \
All three stand at the 400 m mark. Correct.

*(b) Together at the start.* Lap times are
$ 600/8 = 75 " s", quad 600/5 = 120 " s", quad 600/2 = 300 " s" $
$ 75 = 3 times 5^2, quad 120 = 2^3 times 3 times 5, quad 300 = 2^2 times 3 times 5^2 $
$ "LCM" = 2^3 times 3 times 5^2 = 600 " s" $
]
#ans[(a) 200 s #h(8pt) (b) 600 s]

#practice(tier: 3, time: "4 min/Q")[
+ Two trains start at the same time from A and B and move towards each other. After they cross, the first takes 16 hours to reach B and the second takes 25 hours to reach A. Find the ratio of their speeds.
+ A boat's still-water speed is 3 times the speed of the stream. Going 96 km upstream takes 8 hours longer than going 96 km downstream. Find the speed of the stream.
+ A man walks along a bus route. Buses overtake him every 12 minutes and meet him every 4 minutes. All buses have the same speed and run at equal intervals. Find the interval between buses and the ratio of bus speed to walking speed.
+ Two runners start together on a 480 m circular track in the same direction at 12 m/s and 8 m/s. (a) When do they first meet? (b) How many distinct meeting points are there? (c) When are they both back at the start together?
+ A walker and a cyclist start together from A towards B, 36 km away. The cyclist rides at 18 km/h, reaches B, turns round at once and rides back. The walker walks at 6 km/h. How far from A do they meet?
+ A driver covers the first 40 km of an 80 km route at 40 km/h. What speed must he hold over the remaining 40 km so that his average for the whole route is 80 km/h?
+ Three runners start together from the same point of a 360 m circular track and run in the same direction at 9 m/s, 6 m/s and 4 m/s. After how long are all three together again?
+ A train passes a 210 m platform in 25 seconds and a 330 m platform in 31 seconds. Find its speed and its length.
]

#key[
+ *5 : 4* — with $t_1 = 16$ and $t_2 = 25$, the ratio is $"speed"_1 : "speed"_2 = sqrt(t_2) : sqrt(t_1) = sqrt(25) : sqrt(16) = 5 : 4$. The train that needs *longer* after crossing is the slower one. Here the second train needs 25 h against 16 h, so the second train is the slower, and the first is faster in the ratio $5 : 4$.
+ *3 km/h* — let the stream be $c$, so the boat is $3c$, downstream $4c$, upstream $2c$. Then $96\/(2c) - 96\/(4c) = 8$, that is $48\/c - 24\/c = 8$, so $24\/c = 8$ and $c = 3$. Boat 9 km/h: upstream 16 h, downstream 8 h, difference 8 h.
+ *6 minutes; ratio 2 : 1* — $(v-u)12 = v T$ and $(v+u)4 = v T$ give $12v - 12u = 4v + 4u$, so $8v = 16u$ and $v = 2u$. Then $v T = (2u - u)12 = 12u$, so $T = 6$ min.
+ *(a) 120 s (b) 1 point (c) 120 s* — relative speed 4 m/s gives $480\/4 = 120$ s. Ratio $12 : 8 = 3 : 2$, and $3 - 2 = 1$, so they only ever meet at one point. Lap times 40 s and 60 s have LCM 120 s, the same instant, which confirms the single point is the start.
+ *18 km from A* — let the meeting be at time $t$. The walker is at $6t$ from A. The cyclist has ridden $36 + (36 - 6t) = 72 - 6t$. So $18t = 72 - 6t$, giving $24t = 72$ and $t = 3$ h. The walker is at $6 times 3 = 18$ km.
+ *Impossible* — the whole route at 80 km/h allows exactly 1 hour, and the first 40 km at 40 km/h already used 1 hour. No finite speed can fix a time budget that is already spent.
+ *360 s (6 minutes)* — pair periods are $360\/3 = 120$ s, $360\/5 = 72$ s and $360\/2 = 180$ s. $120 = 2^3 3 dot 5$, $72 = 2^3 3^2$, $180 = 2^2 3^2 5$, so the LCM is $2^3 3^2 5 = 360$ s. At 360 s all three have run a whole number of laps, so they meet at the start.
+ *20 m/s (72 km/h); 290 m* — subtracting the two crossing equations kills the length: $330 - 210 = (31 - 25)s$, so $120 = 6s$ and $s = 20$ m/s. Then $L + 210 = 25 times 20 = 500$, so $L = 290$ m. Check: $(290 + 330)\/20 = 31$ s.
]

#section[Mixed set — exam conditions]

#practice(tier: 1, time: "25 questions in 30 min pace · 20 questions here")[
+ A car covers 260 km in 4 hours. Find its speed.
+ Convert 12.5 m/s into km/h.
+ A train 210 m long crosses a pole in 14 seconds. Find its speed in km/h.
+ Walking at 5 km/h a man reaches 6 minutes late; at 6 km/h he reaches 4 minutes early. Find the distance.
+ A journey is split into three equal distances covered at 20, 30 and 60 km/h. Find the average speed.
+ A boat rows at 15 km/h in still water; the stream flows at 5 km/h. How long does 60 km downstream take?
+ Two trains 100 m and 150 m long run in the same direction at 54 km/h and 36 km/h. How long does the faster take to pass the slower?
+ In a 300 m race A beats B by 30 m. B runs at 4.5 m/s. Find A's speed.
+ A cyclist covers a distance in 3 hours at 24 km/h. At what speed must he ride to cover it in 2 hours?
+ Two men start from the same point in opposite directions at 4 km/h and 5 km/h. How far apart are they after 3 hours?
+ A train at 72 km/h crosses a 300 m platform in 30 seconds. Find the train's length.
+ A boat takes 4 hours for 24 km downstream and 6 hours for 24 km upstream. Find its still-water speed.
+ A runner runs at 10 km/h for 2 hours and then at 15 km/h for 1 hour. Find his average speed.
+ Two cars 480 km apart move towards each other at 65 km/h and 55 km/h. After how long do they meet?
+ A car's speed is increased by 25 percent. By what percent does the time for a fixed distance fall?
+ Two cyclists start together from one point of an 800 m circular track and ride in opposite directions at 20 m/s and 12 m/s. When do they first meet?
+ A train at 45 km/h crosses another train 200 m long coming the other way at 36 km/h in 20 seconds. Find the length of the first train.
+ A person travels from X to Y at 30 km/h and returns at 45 km/h, taking 5 hours in all. Find the distance XY.
+ A boat's downstream speed is 3 times its upstream speed. Find the ratio of the boat's still-water speed to the stream's speed.
+ A 240 km journey is done half at 40 km/h and half at 60 km/h. Find the total time.
]

#key[
+ *65 km/h* — $260 \/ 4$.
+ *45 km/h* — $12.5 times 18\/5$.
+ *54 km/h* — $210\/14 = 15$ m/s, then $times 18\/5$.
+ *5 km* — difference 10 min $= 1\/6$ h; $d\/5 - d\/6 = 1\/6 => d\/30 = 1\/6$.
+ *30 km/h* — $3 u v w \/(u v + v w + w u) = (3 times 36000)\/(600+1800+1200) = 108000\/3600$.
+ *3 hours* — downstream 20 km/h; $60\/20$.
+ *50 s* — relative 18 km/h $= 5$ m/s; $(100+150)\/5$.
+ *5 m/s* — B covers 270 m in $270\/4.5 = 60$ s; A does 300 m in the same 60 s.
+ *36 km/h* — distance $24 times 3 = 72$ km; $72\/2$.
+ *27 km* — separating at 9 km/h for 3 h.
+ *300 m* — $72$ km/h $= 20$ m/s; $20 times 30 = 600$; $600 - 300$.
+ *5 km/h* — down 6, up 4; $(6+4)\/2$.
+ *$35\/3 approx 11.67$ km/h* — 35 km in 3 hours. Not $(10+15)\/2$.
+ *4 hours* — $480\/120$.
+ *20 percent* — speed $times 5\/4$ means time $times 4\/5$, a fall of $1\/5$.
+ *25 s* — relative 32 m/s; $800\/32$.
+ *250 m* — relative 81 km/h $= 22.5$ m/s; $22.5 times 20 = 450$ m total; $450 - 200$.
+ *90 km* — average $= 2 times 30 times 45\/75 = 36$ km/h; total distance $36 times 5 = 180$ km; one way 90 km.
+ *2 : 1* — $b + c = 3(b - c) => 4c = 2b$.
+ *5 hours* — $120\/40 = 3$ h and $120\/60 = 2$ h.
]

#revision[
*The one relation*
$ "speed" = "distance"/"time" $
$1$ km/h $= 5\/18$ m/s. $quad$ $1$ m/s $= 18\/5$ km/h. $quad$ 18, 36, 54, 72, 90, 108 km/h $=$ 5, 10, 15, 20, 25, 30 m/s.

*Fixed distance* $=>$ speed ratio $a : b$ means time ratio $b : a$.
Speed $times k$ means time $times 1\/k$.

*Average speed* $= "total distance" \/ "total time"$, always.
Equal distances at $u, v$: $2 u v\/(u+v)$. $quad$ Three equal distances: $3 u v w\/(u v + v w + w u)$.
Equal times at $u, v$: $(u+v)\/2$.

*Late and early*: $d = (s_1 s_2)\/(s_2 - s_1) times Delta t$, with $Delta t$ in hours.

*Relative speed*: opposite $u + v$; same direction $|u - v|$.

*Trains*: pole $L\/s$; platform $(L+P)\/s$; two trains $(L_1+L_2)\/$relative speed.
Two crossing times, one train: subtract the equations, the length cancels.

*Boats*: down $= b + c$, up $= b - c$, and $b = ("down" + "up")\/2$, $c = ("down" - "up")\/2$.

*Races*: "beats by $x$ m" fixes distances at one instant; "beats by $t$ s" fixes times.
Chain them through the middle runner, never by adding gaps.

*Circular track*: first meeting $= C\/(u plus.minus v)$.
Back at start together $=$ LCM of lap times.
Distinct meeting points from ratio $a : b$ in lowest terms: $a + b$ opposite, $a - b$ same.

*Meet then continue*: $t = sqrt(t_1 t_2)$ and $s_1 : s_2 = sqrt(t_2) : sqrt(t_1)$.

*Bus interval problem*: overtake gap $p$, head-on gap $q$ $=>$ $T = 2 p q\/(p+q)$, $v\/u = (p+q)\/(p-q)$.

*Shuttling drone or bird*: only the meeting time matters. Distance $=$ its speed $times$ that time.

*Boat and floating object*: work relative to the water. Time away $=$ time back. The object's drift gives the current directly.

#v(4pt)
*Top five traps*
+ Averaging two speeds for equal distances. Use the harmonic mean, never $(u+v)\/2$.
+ Forgetting the train's own length when it crosses a platform, bridge or another train.
+ Mixing units: metres with km/h. Convert first, every time.
+ Treating "beats by 16 m" and "beats by 4 s" as two gaps to be added. They describe the same gap.
+ Counting rest stops as distance, or leaving them out of the total time when the question says "including stoppages".
]

]
