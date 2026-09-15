#import "../lib/style.typ": *

#chapter(num: 12, title: "Geometry & Mensuration", tagline: "Angles, shapes, areas, solids, coordinates, heights")[

#section[What you need to know]

#formulas[
*Lines and angles*
- Angles on a straight line add to $180 degree$. Angles round a point add to $360 degree$.
- Vertically opposite angles are equal.
- Parallel lines cut by a transversal: corresponding angles equal, alternate angles equal, co-interior (same-side) angles add to $180 degree$.

*Triangles*
- Angle sum $= 180 degree$. Exterior angle $=$ sum of the two opposite interior angles.
- Sides $a, b, c$ form a triangle only if $a + b > c$ for every pair.
- Pythagoras: $"hyp"^2 = "leg"_1^2 + "leg"_2^2$. Triples: $(3,4,5)$, $(5,12,13)$, $(8,15,17)$, $(7,24,25)$, $(9,40,41)$, $(20,21,29)$ and their multiples.
- Area $= 1/2 times "base" times "height"$.
- Heron: $s = (a+b+c)/2$, #h(4pt) Area $= sqrt(s(s-a)(s-b)(s-c))$.
- Equilateral side $a$: Area $= (sqrt(3))/4 a^2$, height $= (sqrt(3))/2 a$.
- Similar triangles: sides in ratio $k arrow.r$ perimeters in ratio $k$, areas in ratio $k^2$.
- Median splits a triangle into two equal areas. The three medians meet at the centroid, which divides each median $2:1$ and cuts the triangle into 6 equal areas.
- Midpoint triangle (joining the three midpoints) has $1/4$ of the area.
- In a right triangle: inradius $r = (a + b - c)/2$, circumradius $R = c/2$ ($c$ = hypotenuse).

*Circles* (radius $r$, diameter $d = 2r$)
- Circumference $= 2 pi r$; Area $= pi r^2$. Use $pi = 22/7$ when $r$ is a multiple of 7.
- Chord of length $L$ at distance $h$ from the centre: $r^2 = h^2 + (L/2)^2$.
- Sector of angle $theta$: arc $= theta/360 times 2 pi r$, area $= theta/360 times pi r^2$.
- Angle at the centre $= 2 times$ angle at the circumference on the same arc. Angle in a semicircle $= 90 degree$.
- Tangent is perpendicular to the radius at the point of contact. Two tangents from an outside point are equal.
- Centres $d$ apart, radii $r_1, r_2$: direct common tangent $= sqrt(d^2 - (r_1 - r_2)^2)$, transverse $= sqrt(d^2 - (r_1 + r_2)^2)$.

*Polygons* ($n$ sides, regular)
- Interior angle sum $= (n-2) times 180 degree$. Each interior angle $= ((n-2) times 180)/n$.
- Each exterior angle $= 360/n$; the exterior angles always total $360 degree$.
- Number of diagonals $= (n(n-3))/2$.

*2D areas*
- Square side $a$: area $a^2$, perimeter $4a$, diagonal $a sqrt(2)$.
- Rectangle $l times b$: area $l b$, perimeter $2(l+b)$, diagonal $sqrt(l^2+b^2)$.
- Parallelogram: base $times$ height. Rhombus: $1/2 d_1 d_2$.
- Trapezium: $1/2 times ("sum of parallel sides") times "height"$.

*3D solids*
#table(columns: 4,
 [*Solid*], [*Volume*], [*Curved / lateral SA*], [*Total SA*],
 [Cube, edge $a$], [$a^3$], [$4a^2$], [$6a^2$],
 [Cuboid $l,b,h$], [$l b h$], [$2h(l+b)$], [$2(l b + b h + h l)$],
 [Cylinder $r,h$], [$pi r^2 h$], [$2 pi r h$], [$2 pi r(r+h)$],
 [Cone $r,h,l$], [$1/3 pi r^2 h$], [$pi r l$], [$pi r(r+l)$],
 [Sphere $r$], [$4/3 pi r^3$], [--], [$4 pi r^2$],
 [Hemisphere $r$], [$2/3 pi r^3$], [$2 pi r^2$], [$3 pi r^2$],
)
- Cone slant: $l = sqrt(r^2 + h^2)$. Cuboid space diagonal $= sqrt(l^2+b^2+h^2)$.
- Frustum ($R, r, h$): $V = 1/3 pi h (R^2 + R r + r^2)$.
- Melting or recasting keeps the *volume* the same, never the surface area.

*Coordinate geometry*
- Distance $= sqrt((x_2-x_1)^2 + (y_2-y_1)^2)$. Midpoint $= ((x_1+x_2)/2, (y_1+y_2)/2)$.
- Section formula (ratio $m:n$): $((m x_2 + n x_1)/(m+n), (m y_2 + n y_1)/(m+n))$.
- Slope $= (y_2-y_1)/(x_2-x_1)$. Parallel: equal slopes. Perpendicular: $m_1 m_2 = -1$.
- Line: $y = m x + c$; intercept form $x/a + y/b = 1$.
- Area of triangle $= 1/2 |x_1(y_2-y_3) + x_2(y_3-y_1) + x_3(y_1-y_2)|$.
- Distance from $(x_0,y_0)$ to $a x + b y + c = 0$ is $abs(a x_0 + b y_0 + c) / sqrt(a^2+b^2)$.

*Trigonometry*
#table(columns: 6,
 [$theta$], [$0 degree$], [$30 degree$], [$45 degree$], [$60 degree$], [$90 degree$],
 [$sin theta$], [$0$], [$1/2$], [$1/sqrt(2)$], [$(sqrt(3))/2$], [$1$],
 [$cos theta$], [$1$], [$(sqrt(3))/2$], [$1/sqrt(2)$], [$1/2$], [$0$],
 [$tan theta$], [$0$], [$1/sqrt(3)$], [$1$], [$sqrt(3)$], [--],
)
- $sin^2 theta + cos^2 theta = 1$; #h(4pt) $tan theta = (sin theta)/(cos theta)$.
- Heights and distances: $tan("angle of elevation") = "height"/"horizontal distance"$.
- Angle of depression from a top point equals the angle of elevation from the bottom point.
- Useful decimals: $sqrt(2) = 1.414$, $sqrt(3) = 1.732$, $1/sqrt(3) = 0.577$.
]

#section[Warm-up]
#tier-header(0)

#ex(1, tier: 0)[Three angles on one side of a straight line are $3x$, $2x$ and $40 degree$. Find $x$.
#sol[
Angles on a straight line add to $180 degree$. \
$3x + 2x + 40 = 180$ \
$5x = 180 - 40 = 140$ \
$x = 140/5 = 28 degree$.
]
#ans[$x = 28 degree$]
]

#ex(2, tier: 0)[The angles of a triangle are in the ratio $2 : 3 : 4$. Find them.
#sol[
Let the angles be $2k$, $3k$, $4k$. \
$2k + 3k + 4k = 180 arrow.r 9k = 180 arrow.r k = 20$. \
Angles: $2 times 20 = 40 degree$, $3 times 20 = 60 degree$, $4 times 20 = 80 degree$. \
Check: $40 + 60 + 80 = 180$. Correct.
]
#ans[$40 degree, 60 degree, 80 degree$]
]

#ex(3, tier: 0)[A right triangle has legs 9 cm and 12 cm. Find the hypotenuse.
#sol[
$"hyp"^2 = 9^2 + 12^2 = 81 + 144 = 225$. \
$"hyp" = sqrt(225) = 15$ cm. \
(This is the $(3,4,5)$ triple times 3.)
]
#ans[15 cm]
]

#ex(4, tier: 0)[Find the area of a triangle of base 14 cm and height 9 cm.
#sol[
Area $= 1/2 times 14 times 9 = 7 times 9 = 63$ cm#super[2].
]
#ans[63 cm#super[2]]
]

#ex(5, tier: 0)[A circle has radius 7 cm. Find its area and circumference. Take $pi = 22/7$.
#sol[
Area $= pi r^2 = 22/7 times 7 times 7 = 22 times 7 = 154$ cm#super[2]. \
Circumference $= 2 pi r = 2 times 22/7 times 7 = 44$ cm.
]
#ans[Area 154 cm#super[2]\; circumference 44 cm]
]

#ex(6, tier: 0)[Find the volume and total surface area of a cuboid $12 times 8 times 5$ cm.
#sol[
Volume $= l b h = 12 times 8 times 5 = 480$ cm#super[3]. \
Surface $= 2(l b + b h + h l) = 2(12 times 8 + 8 times 5 + 5 times 12)$ \
$= 2(96 + 40 + 60) = 2 times 196 = 392$ cm#super[2].
]
#ans[480 cm#super[3]\; 392 cm#super[2]]
]

#ex(7, tier: 0)[Find the distance between $(2, 3)$ and $(7, 15)$.
#sol[
$d = sqrt((7-2)^2 + (15-3)^2) = sqrt(5^2 + 12^2) = sqrt(25 + 144) = sqrt(169) = 13$.
]
#ans[13 units]
]

#ex(8, tier: 0)[Evaluate $sin 60 degree cos 30 degree + sin 30 degree cos 60 degree$.
#sol[
$sin 60 degree = (sqrt(3))/2$, #h(4pt) $cos 30 degree = (sqrt(3))/2$, #h(4pt) $sin 30 degree = 1/2$, #h(4pt) $cos 60 degree = 1/2$. \
First part: $(sqrt(3))/2 times (sqrt(3))/2 = 3/4$. \
Second part: $1/2 times 1/2 = 1/4$. \
Total $= 3/4 + 1/4 = 1$.
]
#ans[$1$]
]

#section[Tier 1 — Service companies]
#tier-header(1)

#ex(9, tier: 1, asked: "TCS NQT pattern")[
Two parallel lines are cut by a transversal. A pair of co-interior angles measure $(3x + 10) degree$ and $(2x + 20) degree$. Find both angles.
#sol[
Co-interior angles (same side of the transversal, between the parallels) add to $180 degree$. \
$(3x + 10) + (2x + 20) = 180$ \
$5x + 30 = 180$ \
$5x = 150$ \
$x = 30$. \
First angle $= 3(30) + 10 = 90 + 10 = 100 degree$. \
Second angle $= 2(30) + 20 = 60 + 20 = 80 degree$. \
Check: $100 + 80 = 180$. Correct.
]
#ans[$100 degree$ and $80 degree$]
]

#ex(10, tier: 1, asked: "Infosys pattern")[
A man 1.8 m tall casts a shadow 2.4 m long. At the same moment a telecom tower casts a shadow 30 m long. Find the height of the tower.
#sol[
The sun's rays hit both at the same angle, so the two triangles are similar. \
$"height"/"shadow"$ is the same for both. \
$1.8/2.4 = h/30$ \
$h = 30 times 1.8/2.4$ \
$1.8/2.4 = 0.75$. \
$h = 30 times 0.75 = 22.5$ m.
]
#ans[22.5 m]
]

#trick[
In "same time, two shadows" problems you never need the angle. Just set $"height"/"shadow"$ equal for the two objects. Keep the ratio as a decimal ($1.8 div 2.4 = 0.75$) and one multiplication finishes it.
]

#ex(11, tier: 1, asked: "Accenture pattern")[
Find the area of a triangle with sides 13 cm, 14 cm and 15 cm.
#sol[
No height is given, so use Heron's formula. \
$s = (13 + 14 + 15)/2 = 42/2 = 21$. \
$s - a = 21 - 13 = 8$ \
$s - b = 21 - 14 = 7$ \
$s - c = 21 - 15 = 6$ \
Area $= sqrt(21 times 8 times 7 times 6)$. \
$21 times 8 = 168$; #h(4pt) $7 times 6 = 42$; #h(4pt) $168 times 42 = 7056$. \
$sqrt(7056) = 84$ (since $84^2 = 7056$). \
Area $= 84$ cm#super[2].
]
#ans[84 cm#super[2]]
]

#ex(12, tier: 1, asked: "Wipro pattern")[
A chord of a circle of radius 13 cm is 5 cm from the centre. Find the length of the chord.
#sol[
Drop a perpendicular from the centre to the chord. It bisects the chord. \
This makes a right triangle: radius is the hypotenuse, the 5 cm is one leg, half the chord is the other. \
$13^2 = 5^2 + ("half chord")^2$ \
$169 = 25 + ("half chord")^2$ \
$("half chord")^2 = 144$ \
half chord $= 12$. \
Chord $= 2 times 12 = 24$ cm.
]
#ans[24 cm]
]

#trap[
The distance from the centre is to the *chord*, and the perpendicular cuts the chord in half. Students often set $13^2 = 5^2 + "chord"^2$ and get $12$ as the whole chord. Always double at the end.
]

#ex(13, tier: 1, asked: "Capgemini pattern")[
A sector has radius 21 cm and angle $120 degree$. Find its arc length, area and perimeter. Take $pi = 22/7$.
#sol[
$120/360 = 1/3$, so the sector is one third of the circle. \
Full circumference $= 2 times 22/7 times 21 = 2 times 22 times 3 = 132$ cm. \
Arc $= 1/3 times 132 = 44$ cm. \
Full area $= 22/7 times 21 times 21 = 22 times 3 times 21 = 1386$ cm#super[2]. \
Sector area $= 1/3 times 1386 = 462$ cm#super[2]. \
Perimeter of a sector $=$ arc $+$ two radii $= 44 + 21 + 21 = 86$ cm.
]
#ans[Arc 44 cm; area 462 cm#super[2]\; perimeter 86 cm]
]

#trap[
The perimeter of a sector is not just the arc. It is arc $+ 2r$, because the two straight edges are part of the boundary. Forgetting the $2r$ costs 42 cm here.
]

#ex(14, tier: 1, asked: "Cognizant pattern")[
Each interior angle of a regular polygon is $162 degree$. Find the number of sides and the number of diagonals.
#sol[
Interior $+$ exterior $= 180 degree$, so each exterior angle $= 180 - 162 = 18 degree$. \
Exterior angles always total $360 degree$. \
$n = 360/18 = 20$ sides. \
Diagonals $= (n(n-3))/2 = (20 times 17)/2 = 340/2 = 170$.
]
#ans[20 sides; 170 diagonals]
]

#trick[
Always route interior-angle questions through the *exterior* angle. $n = 360 div "exterior"$ is one division. Working from $((n-2)180)/n = 162$ needs cross-multiplying and rearranging — three times the work, three times the risk.
]

#ex(15, tier: 1, asked: "TCS NQT pattern")[
A rectangular garden is 40 m by 25 m. A path 2.5 m wide runs all round it on the outside. Find the area of the path.
#sol[
Outer rectangle: the path adds 2.5 m on *both* sides of each dimension. \
Outer length $= 40 + 2 times 2.5 = 40 + 5 = 45$ m. \
Outer width $= 25 + 2 times 2.5 = 25 + 5 = 30$ m. \
Outer area $= 45 times 30 = 1350$ m#super[2]. \
Garden area $= 40 times 25 = 1000$ m#super[2]. \
Path area $= 1350 - 1000 = 350$ m#super[2].
]
#ans[350 m#super[2]]
]

#trap[
A path "all round" adds its width *twice* to each dimension, not once. Using $42.5 times 27.5$ instead of $45 times 30$ is the standard wrong answer here.
]

#ex(16, tier: 1, asked: "Infosys pattern")[
A cylinder has radius 7 cm and height 20 cm. Find its volume, curved surface area and total surface area. Take $pi = 22/7$.
#sol[
Volume $= pi r^2 h = 22/7 times 7 times 7 times 20 = 22 times 7 times 20 = 3080$ cm#super[3]. \
Curved SA $= 2 pi r h = 2 times 22/7 times 7 times 20 = 2 times 22 times 20 = 880$ cm#super[2]. \
Area of one circular end $= pi r^2 = 22/7 times 49 = 154$ cm#super[2]. \
Total SA $= 880 + 2 times 154 = 880 + 308 = 1188$ cm#super[2].
]
#ans[3080 cm#super[3]\; CSA 880 cm#super[2]\; TSA 1188 cm#super[2]]
]

#ex(17, tier: 1, asked: "Accenture pattern")[
A cone has radius 7 cm and height 24 cm. Find its slant height, curved surface area and volume. Take $pi = 22/7$.
#sol[
Slant: $l = sqrt(r^2 + h^2) = sqrt(49 + 576) = sqrt(625) = 25$ cm. \
Curved SA $= pi r l = 22/7 times 7 times 25 = 22 times 25 = 550$ cm#super[2]. \
Volume $= 1/3 pi r^2 h = 1/3 times 22/7 times 49 times 24$. \
$1/3 times 24 = 8$, so this is $22/7 times 49 times 8 = 22 times 7 times 8 = 1232$ cm#super[3].
]
#ans[$l = 25$ cm; CSA 550 cm#super[2]\; volume 1232 cm#super[3]]
]

#ex(18, tier: 1, asked: "Wipro pattern")[
A metal sphere of radius 9 cm is melted and recast into small spheres of radius 3 cm. How many small spheres are formed?
#sol[
Melting keeps the volume the same. \
Big sphere volume $= 4/3 pi (9)^3 = 4/3 pi times 729$. \
Small sphere volume $= 4/3 pi (3)^3 = 4/3 pi times 27$. \
Number $= (4/3 pi times 729)/(4/3 pi times 27) = 729/27 = 27$. \
The $4/3 pi$ cancels — only the cube of the radii matters.
]
#ans[27 spheres]
]

#trick[
For melting one solid into copies of another, cancel every common factor *before* multiplying. Here the whole answer is $(9/3)^3 = 3^3 = 27$. Never compute $4/3 pi times 729$ as a decimal.
]

#ex(19, tier: 1, asked: "Capgemini pattern")[
Find the area of the triangle with vertices $(1, 2)$, $(4, 8)$ and $(7, 3)$.
#sol[
Area $= 1/2 |x_1(y_2 - y_3) + x_2(y_3 - y_1) + x_3(y_1 - y_2)|$. \
$x_1 = 1, y_1 = 2$; #h(4pt) $x_2 = 4, y_2 = 8$; #h(4pt) $x_3 = 7, y_3 = 3$. \
$x_1(y_2 - y_3) = 1 times (8 - 3) = 5$ \
$x_2(y_3 - y_1) = 4 times (3 - 2) = 4$ \
$x_3(y_1 - y_2) = 7 times (2 - 8) = 7 times (-6) = -42$ \
Sum $= 5 + 4 - 42 = -33$. \
Area $= 1/2 times |-33| = 33/2 = 16.5$ square units.
]
#ans[16.5 square units]
]

#ex(20, tier: 1, asked: "TCS NQT pattern")[
From a point 60 m from the foot of a tower, the angle of elevation of its top is $30 degree$. Find the height of the tower. Take $sqrt(3) = 1.732$.
#sol[
$tan("elevation") = "height"/"distance"$. \
$tan 30 degree = h/60$ \
$1/sqrt(3) = h/60$ \
$h = 60/sqrt(3)$. \
Rationalise: $h = (60 sqrt(3))/3 = 20 sqrt(3)$. \
$h = 20 times 1.732 = 34.64$ m.
]
#ans[$20 sqrt(3) approx 34.64$ m]
]

#practice(tier: 1, time: "60 s/Q")[
+ Two angles on a straight line are $(2x + 15) degree$ and $(3x + 15) degree$. Find both angles.
+ The angles of a triangle are in the ratio $3 : 4 : 5$. Find the largest angle. #opts($75 degree$, $60 degree$, $90 degree$, $80 degree$)
+ A right triangle has legs 8 cm and 15 cm. Find the hypotenuse and the area.
+ A circle has circumference 88 cm. Find its radius and area ($pi = 22/7$).
+ A chord of length 16 cm lies in a circle of radius 17 cm. Find its distance from the centre. #opts([$15$ cm], [$8$ cm], [$9$ cm], [$sqrt(33)$ cm])
+ Each exterior angle of a regular polygon is $24 degree$. Find the number of sides and the interior angle sum.
+ A square has area 144 cm#super[2]. Find its perimeter and the length of its diagonal.
+ A trapezium has parallel sides 15 cm and 25 cm, and height 12 cm. Find its area.
+ A rhombus has diagonals 16 cm and 30 cm. Find its area and its side length.
+ A cube has edge 9 cm. Find its volume and total surface area.
+ A cylinder has radius 10.5 cm and height 8 cm. Find its volume ($pi = 22/7$).
+ A sphere has radius 21 cm. Find its surface area and volume ($pi = 22/7$).
+ Find the distance between $(-3, 4)$ and $(5, -2)$, and their midpoint.
+ A ladder leans against a wall at $45 degree$ and its foot is 5 m from the wall. How high up the wall does it reach?
+ The area of an equilateral triangle is $36 sqrt(3)$ cm#super[2]. Find its side.
]

#key[
*1.* $75 degree$ and $105 degree$. $5x + 30 = 180 arrow.r x = 30$. \
*2.* (a) $75 degree$. $3k+4k+5k = 180 arrow.r k = 15$; largest $= 5 times 15$. (b) is the middle angle, (c) assumes a right triangle, (d) comes from a $2:3:4$ split. \
*3.* Hypotenuse 17 cm (the $8,15,17$ triple); area $= 1/2 times 8 times 15 = 60$ cm#super[2]. \
*4.* $r = 14$ cm ($2 times 22/7 times r = 88$); area $= 22/7 times 196 = 616$ cm#super[2]. \
*5.* (a) $15$ cm. Half chord $= 8$; $17^2 - 8^2 = 289 - 64 = 225$, so the distance is 15. (b) reports the half chord itself, (c) is $17 - 8$ (subtracting instead of using Pythagoras), (d) is $sqrt(17^2 - 16^2)$ — forgetting to halve the chord. \
*6.* $n = 360/24 = 15$ sides; interior sum $= (15-2) times 180 = 2340 degree$. \
*7.* Side $= 12$ cm; perimeter $= 48$ cm; diagonal $= 12 sqrt(2) approx 16.97$ cm. \
*8.* $240$ cm#super[2]. $1/2 (15+25) times 12 = 20 times 12$. \
*9.* Area $= 1/2 times 16 times 30 = 240$ cm#super[2]\; side $= sqrt(8^2 + 15^2) = 17$ cm (half-diagonals are the legs). \
*10.* $729$ cm#super[3]\; $6 times 81 = 486$ cm#super[2]. \
*11.* $2772$ cm#super[3]. $22/7 times 110.25 = 346.5$; $346.5 times 8$. \
*12.* SA $= 4 times 22/7 times 441 = 5544$ cm#super[2]\; volume $= 4/3 times 22/7 times 9261 = 38808$ cm#super[3]. \
*13.* Distance $= sqrt(64 + 36) = 10$; midpoint $= (1, 1)$. \
*14.* $5$ m. At $45 degree$ the height equals the base distance, since $tan 45 degree = 1$. \
*15.* $12$ cm. $(sqrt(3))/4 a^2 = 36 sqrt(3) arrow.r a^2 = 144$.
]

#section[Tier 2 — Singapore & Thailand]
#tier-header(2)

#ex(21, tier: 2, asked: "Grab · pattern")[
A Bangkok hub floor measuring 15 m by 6.4 m must be tiled with tiles of 40 cm by 30 cm. Tiles cost THB~32 each and the contractor orders 4% extra for breakage. Find the number of tiles ordered and the total cost.
#sol[
Work in centimetres so the units match. \
Floor: $15$ m $= 1500$ cm, $6.4$ m $= 640$ cm. \
Floor area $= 1500 times 640 = 960000$ cm#super[2]. \
One tile $= 40 times 30 = 1200$ cm#super[2]. \
Tiles needed $= 960000/1200 = 800$. \
With 4% extra: $800 times 1.04 = 832$ tiles. \
Cost $= 832 times 32$. \
$832 times 32 = 832 times 30 + 832 times 2 = 24960 + 1664 = 26624$.
]
#ans[832 tiles; THB~26,624]
]

#trick[
Convert to one unit *before* you do anything else. Mixing metres and centimetres is the single biggest source of wrong tiling answers. An area ratio in cm#super[2] gives the tile count directly; no decimals appear anywhere.
]

#ex(22, tier: 2, asked: "SCB · pattern")[
Sand is heaped in a cone of base radius 10.5 m and height 3 m at a site in Bangkok. Sand costs THB~250 per cubic metre. Find the value of the heap. Take $pi = 22/7$.
#sol[
Volume of a cone $= 1/3 pi r^2 h$. \
$r^2 = 10.5 times 10.5 = 110.25$. \
$1/3 times 3 = 1$, so the height and the $1/3$ cancel. \
Volume $= 22/7 times 110.25 = 22 times 15.75 = 346.5$ m#super[3]. \
(Here $110.25 div 7 = 15.75$.) \
Value $= 346.5 times 250$. \
$346.5 times 250 = 346.5 times 1000 div 4 = 346500/4 = 86625$.
]
#ans[THB~86,625]
]

#ex(23, tier: 2, asked: "Agoda · pattern")[
A rectangular water tank is 2.4 m by 1.5 m by 1.2 m. It is filled by a pump delivering 300 litres per minute. How long does filling take? ($1$ m#super[3] $= 1000$ litres.)
#sol[
Volume $= 2.4 times 1.5 times 1.2$. \
$2.4 times 1.5 = 3.6$. \
$3.6 times 1.2 = 4.32$ m#super[3]. \
In litres: $4.32 times 1000 = 4320$ litres. \
Time $= 4320/300 = 14.4$ minutes. \
$0.4$ minute $= 0.4 times 60 = 24$ seconds.
]
#ans[14.4 minutes, i.e. 14 min 24 s]
]

#ex(24, tier: 2, asked: "LINE MAN · pattern")[
A road roller is a cylinder of diameter 84 cm and length 1 m. How much road area does it level in 500 complete revolutions? Take $pi = 22/7$.
#sol[
One revolution lays down a strip whose area equals the roller's curved surface area. \
Diameter 84 cm $arrow.r$ radius $= 42$ cm $= 0.42$ m. \
Curved SA $= 2 pi r h = 2 times 22/7 times 0.42 times 1$. \
$0.42 div 7 = 0.06$. \
$= 2 times 22 times 0.06 = 2.64$ m#super[2] per revolution. \
In 500 revolutions: $2.64 times 500 = 1320$ m#super[2].
]
#ans[1320 m#super[2]]
]

#note[This is why the *length* of the roller, not its area of cross-section, drives the answer. A roller only paints the curved band; its two flat ends never touch the road.]

#ex(25, tier: 2, asked: "Shopee · pattern")[
A packing wire is bent into a circle of radius 28 cm. The same wire is straightened and bent into a square. By how much does the enclosed area drop? Take $pi = 22/7$.
#sol[
The wire length stays the same, so circumference $=$ square perimeter. \
Circumference $= 2 times 22/7 times 28 = 2 times 22 times 4 = 176$ cm. \
Circle area $= 22/7 times 28 times 28 = 22 times 4 times 28 = 2464$ cm#super[2]. \
Square side $= 176/4 = 44$ cm. \
Square area $= 44 times 44 = 1936$ cm#super[2]. \
Drop $= 2464 - 1936 = 528$ cm#super[2].
]
#ans[The area drops by 528 cm#super[2]]
]

#trap[
Equal perimeters never mean equal areas. For a fixed perimeter the circle always encloses the most area, and among rectangles the square encloses the most. Expect the shape change to *lose* area whenever you move away from a circle.
]

#ex(26, tier: 2, asked: "DBS · pattern")[
A well of diameter 4 m is dug 14 m deep. The soil taken out is spread evenly to form a ring-shaped embankment 3 m wide around the well. Find the height of the embankment. Take $pi = 22/7$.
#sol[
Soil dug out $=$ volume of the cylindrical well. \
Radius of the well $= 4/2 = 2$ m. \
Volume $= pi r^2 h = 22/7 times 4 times 14 = 22 times 4 times 2 = 176$ m#super[3]. \
The embankment is a ring: inner radius 2 m, outer radius $2 + 3 = 5$ m. \
Ring area $= pi (R^2 - r^2) = 22/7 times (25 - 4) = 22/7 times 21 = 66$ m#super[2]. \
Height $= "volume"/"area" = 176/66 = 8/3 = 2.67$ m.
]
#ans[$8/3 approx 2.67$ m]
]

#ex(27, tier: 2, asked: "GIC · pattern")[
An office window is 15 m above the ground. From it, the angle of elevation of the top of a building opposite is $30 degree$ and the angle of depression of that building's base is $45 degree$. Find the height of the building. Take $sqrt(3) = 1.732$.
#sol[
Let the horizontal distance between the two buildings be $d$. \
*Below the window* (depression $45 degree$): \
$tan 45 degree = 15/d arrow.r 1 = 15/d arrow.r d = 15$ m. \
*Above the window* (elevation $30 degree$), call that extra height $x$: \
$tan 30 degree = x/d$ \
$1/sqrt(3) = x/15$ \
$x = 15/sqrt(3) = (15 sqrt(3))/3 = 5 sqrt(3) = 5 times 1.732 = 8.66$ m. \
Total height $= 15 + 8.66 = 23.66$ m.
]
#ans[$15 + 5 sqrt(3) approx 23.66$ m]
]

#trick[
Always solve the depression part first. It usually gives the horizontal distance in one step (and at $45 degree$ that distance simply equals the known height). Feed that distance into the elevation part.
]

#ex(28, tier: 2, asked: "Razer · pattern")[
A solid metal cylinder of radius 6 cm and height 15 cm is melted and cast into small cones of radius 3 cm and height 5 cm. How many cones are made?
#sol[
Volume is conserved. \
Cylinder $= pi r^2 h = pi times 36 times 15 = 540 pi$ cm#super[3]. \
One cone $= 1/3 pi r^2 h = 1/3 times pi times 9 times 5 = 15 pi$ cm#super[3]. \
Number $= (540 pi)/(15 pi) = 540/15 = 36$. \
The $pi$ cancels, so no decimals are needed anywhere.
]
#ans[36 cones]
]

#ex(29, tier: 2, asked: "Sea · pattern")[
A bucket is a frustum with top radius 15 cm, bottom radius 10 cm and height 24 cm. Find its capacity in litres. Take $pi = 22/7$ and $1$ litre $= 1000$ cm#super[3].
#sol[
Frustum volume $= 1/3 pi h (R^2 + R r + r^2)$. \
$R = 15$, $r = 10$, $h = 24$. \
$R^2 = 225$; #h(4pt) $R r = 150$; #h(4pt) $r^2 = 100$. \
Sum $= 225 + 150 + 100 = 475$. \
$1/3 times 24 = 8$. \
Volume $= 8 times 22/7 times 475 = (8 times 22 times 475)/7 = 83600/7 = 11942.86$ cm#super[3]. \
In litres: $11942.86 div 1000 = 11.94$ litres.
]
#ans[About 11.94 litres]
]

#ex(30, tier: 2, asked: "Grab · pattern")[
A cylindrical tub of radius 10 cm holds water. A solid metal ball is dropped in and fully sinks; the water level rises by 2.88 cm. Find the radius of the ball.
#sol[
The water pushed up equals the ball's volume. \
Water displaced $=$ cylinder of radius 10 and height 2.88 \
$= pi times 10^2 times 2.88 = 288 pi$ cm#super[3]. \
Ball volume $= 4/3 pi r^3$. \
$4/3 pi r^3 = 288 pi$ \
Cancel $pi$: $4/3 r^3 = 288$ \
$r^3 = 288 times 3/4 = 216$ \
$r = root(3, 216) = 6$ cm. \
Check: $4/3 pi times 216 = 288 pi$. Correct.
]
#ans[6 cm]
]

#practice(tier: 2, time: "100 s/Q")[
+ A room floor 12.5 m by 8 m is tiled with tiles of 50 cm by 40 cm costing Rs.~45 each. Find the number of tiles and the cost, with no wastage.
+ Two triangles are similar. Their areas are in the ratio $9 : 16$ and the smaller one has perimeter 45 cm. Find the larger perimeter.
+ A 400 m running track has two straight sides and two semicircular ends of diameter 70 m. Find the length of each straight side and the area enclosed ($pi = 22/7$).
+ A cylindrical tank of radius 1.4 m and height 2.5 m is filled at 7 litres per second. How long does it take ($pi = 22/7$)?
+ A circular park has area 1386 m#super[2]. Fencing costs Rs.~55 per metre. Find the total fencing cost ($pi = 22/7$).
+ A right triangle has vertices $(0,0)$, $(6,0)$ and $(0,8)$. Find its area, its hypotenuse, its inradius and its circumradius.
+ A cylindrical container of radius 6 cm and height 15 cm is filled with ice cream. It is shared into cones of radius 3 cm and height 12 cm, each topped with a hemisphere of radius 3 cm. How many portions are made?
+ A trapezoidal plot has parallel sides 48 m and 32 m, and the distance between them is 25 m. Land sells at Rs.~8,500 per m#super[2]. Find the value of the plot.
+ A cube of edge 12 cm is cut into cubes of edge 3 cm. Find how many small cubes there are, and the ratio of the original surface area to the total surface area of all the pieces.
+ A hemispherical bowl of internal radius 9 cm is emptied into cylindrical bottles of radius 3 cm and height 3 cm. How many bottles are filled?
+ A vertical pole casts a 9 m shadow when the sun's elevation is $60 degree$. Find the pole's height, and the shadow length when the elevation drops to $30 degree$. Take $sqrt(3) = 1.732$.
+ The line $3x + 4y = 24$ meets the axes at $A$ and $B$. Find the area of triangle $O A B$ and the perpendicular distance from the origin to the line.
]

#key[
*1.* $500$ tiles; Rs.~22,500. Floor $= 1250$ cm by $800$ cm; one tile $= 50 times 40 = 2000$ cm#super[2]\; tiles $= (1250 times 800)/2000 = 500$; cost $= 500 times 45$. \
*2.* $60$ cm. Area ratio $9:16 arrow.r$ side (and perimeter) ratio $3:4$; $45 times 4/3$. \
*3.* The two semicircles make one full circle: $22/7 times 70 = 220$ m. Straights $= 400 - 220 = 180$, so each is 90 m. Area $= 90 times 70 + 22/7 times 35^2 = 6300 + 3850 = 10150$ m#super[2]. \
*4.* $36$ min $40$ s. Volume $= 22/7 times 1.96 times 2.5 = 15.4$ m#super[3] $= 15400$ L; $15400/7 = 2200$ s $= 36$ min $40$ s. \
*5.* Rs.~7,260. $r^2 = 1386 times 7/22 = 441 arrow.r r = 21$; circumference $= 132$ m; $132 times 55$. \
*6.* Area $= 24$; hypotenuse $= 10$; inradius $= (6 + 8 - 10)/2 = 2$; circumradius $= 10/2 = 5$. \
*7.* $10$ portions. Cylinder $= 540 pi$; each portion $= 36 pi + 18 pi = 54 pi$; $540 div 54$. \
*8.* Rs.~85,00,000. Area $= 1/2 (48+32) times 25 = 1000$ m#super[2]\; $1000 times 8500$. \
*9.* $64$ cubes. Original SA $= 6 times 144 = 864$; total after $= 64 times 6 times 9 = 3456$; ratio $1:4$. \
*10.* $18$ bottles. Bowl $= 2/3 pi times 729 = 486 pi$; bottle $= pi times 9 times 3 = 27 pi$; $486 div 27 = 18$. The $pi$ cancels. \
*11.* Height $= 9 sqrt(3) = 15.59$ m. At $30 degree$: shadow $= h/tan 30 degree = 9 sqrt(3) times sqrt(3) = 27$ m. \
*12.* $A(8,0)$, $B(0,6)$; area $= 1/2 times 8 times 6 = 24$; distance $= abs(-24)/sqrt(9+16) = 24/5 = 4.8$.
]

#section[Tier 3 — Product companies]
#tier-header(3)

#ex(31, tier: 3, asked: "Google · pattern")[
Triangle $A B C$ has area 96 cm#super[2]. The midpoints of its sides are joined to form triangle $P Q R$. The midpoints of $P Q R$ are joined to form triangle $X Y Z$. Find the area of $X Y Z$.
#sol[
*Insight: joining midpoints makes a triangle similar to the original with every side exactly half as long — and halving the sides quarters the area.*

Why each side halves: $P Q$ joins the midpoints of two sides of $A B C$, so by the midpoint theorem $P Q$ is parallel to the third side and half its length. The same holds for the other two sides. \
So $P Q R$ is similar to $A B C$ with side ratio $k = 1/2$. \
Area ratio $= k^2 = 1/4$. \
Area of $P Q R = 96 times 1/4 = 24$ cm#super[2]. \
Repeat the same step on $P Q R$: \
Area of $X Y Z = 24 times 1/4 = 6$ cm#super[2]. \
General rule: after $n$ midpoint steps the area is $96/4^n$. Here $n = 2$, so $96/16 = 6$.
]
#ans[6 cm#super[2]]
]

#ex(32, tier: 3, asked: "Amazon · pattern")[
An ant walks on the surface of a closed box measuring $12 times 4 times 3$ cm, from one corner to the corner diagonally opposite. Find the shortest possible path length.
#sol[
*Insight: unfold the box flat. On a flat sheet the shortest path is a straight line, so the answer is the smallest straight-line distance across an unfolding — not the space diagonal, which cuts through the air.*

Each unfolding lays one edge alone against the *sum* of the other two. There are three such unfoldings, so test all three. \
Unfolding 1: a rectangle $12$ by $(4 + 3) = 7$. \
Length $= sqrt(12^2 + 7^2) = sqrt(144 + 49) = sqrt(193) = 13.89$ cm. \
Unfolding 2: a rectangle $(12 + 3) = 15$ by $4$. \
Length $= sqrt(15^2 + 4^2) = sqrt(225 + 16) = sqrt(241) = 15.52$ cm. \
Unfolding 3: a rectangle $(12 + 4) = 16$ by $3$. \
Length $= sqrt(16^2 + 3^2) = sqrt(256 + 9) = sqrt(265) = 16.28$ cm. \
The smallest is $sqrt(193) approx 13.89$ cm. \
Note the pattern: the best unfolding pairs the *largest* dimension alone against the sum of the other two.
]
#ans[$sqrt(193) approx 13.89$ cm]
]

#trap[
The space diagonal $sqrt(144 + 16 + 9) = sqrt(169) = 13$ cm is shorter, but the ant cannot fly. It must stay on the surface, so 13 cm is not available. Read the word "surface" before you reach for the 3D diagonal.
]

#ex(33, tier: 3, asked: "Microsoft · pattern")[
A sphere is packed snugly inside a cube of edge 12 cm. What fraction of the box is empty? Take $pi = 3.1416$.
#sol[
*Insight: the sphere touches all six faces, so its diameter equals the cube's edge. The wasted fraction is then independent of the size of the cube.*

Sphere diameter $= 12$, so radius $r = 6$ cm. \
Cube volume $= 12^3 = 1728$ cm#super[3]. \
Sphere volume $= 4/3 pi r^3 = 4/3 times 3.1416 times 216$. \
$4/3 times 216 = 288$. \
$= 288 times 3.1416 = 904.78$ cm#super[3]. \
Empty volume $= 1728 - 904.78 = 823.22$ cm#super[3]. \
Fraction empty $= 823.22/1728 = 0.4764$, i.e. about $47.6%$. \
*General form:* with edge $a$ and radius $a/2$, \
$"sphere"/"cube" = (4/3 pi (a/2)^3)/a^3 = (4 pi a^3)/(3 times 8 a^3) = pi/6 approx 0.5236$. \
So a sphere always fills $pi/6 approx 52.4%$ of its snug box, whatever the size, and $47.6%$ is always wasted.
]
#ans[About $47.6%$ empty (the sphere fills $pi/6 approx 52.4%$)]
]

#ex(34, tier: 3, asked: "Goldman Sachs · pattern")[
A delivery van must start at $A(1, 2)$, touch the $x$-axis at some point $P$, and end at $B(7, 4)$. Find the point $P$ that makes the total trip $A P + P B$ shortest, and that shortest length.
#sol[
*Insight: reflect one endpoint across the line. A path that bounces off a line has the same length as the straight path to the mirror image — and a straight line is the shortest route.*

Reflect $A(1, 2)$ in the $x$-axis to get $A'(1, -2)$. \
For any $P$ on the $x$-axis, $A P = A' P$ (mirror symmetry). \
So $A P + P B = A' P + P B$, which is smallest when $A'$, $P$, $B$ lie on one straight line. \
Line $A' B$: slope $= (4 - (-2))/(7 - 1) = 6/6 = 1$. \
Equation through $A'(1, -2)$: $y - (-2) = 1 (x - 1) arrow.r y + 2 = x - 1 arrow.r y = x - 3$. \
It meets the $x$-axis where $y = 0$: $0 = x - 3 arrow.r x = 3$. \
So $P = (3, 0)$. \
Shortest length $= A' B = sqrt((7-1)^2 + (4 - (-2))^2) = sqrt(36 + 36) = sqrt(72) = 6 sqrt(2) = 8.49$. \
Check directly: $A P = sqrt(4 + 4) = 2 sqrt(2)$ and $P B = sqrt(16 + 16) = 4 sqrt(2)$; total $= 6 sqrt(2)$. Correct.
]
#ans[$P = (3, 0)$; shortest distance $= 6 sqrt(2) approx 8.49$]
]

#trick[
Reflection solves every "touch the line and come back" problem: shortest walk to a river and home, light bouncing off a mirror, a ball off a cushion. Reflect *one* point, draw the straight line, read off where it crosses.
]

#ex(35, tier: 3, asked: "D. E. Shaw · pattern")[
Two circles of radii 9 cm and 4 cm touch each other externally. Find the length of their direct common tangent, and show it equals $2 sqrt(r_1 r_2)$.
#sol[
*Insight: drop the smaller radius onto the larger one. The tangent, the line of centres, and the difference of radii form a right triangle.*

Touching externally means the centres are $d = 9 + 4 = 13$ cm apart. \
Both radii are perpendicular to the tangent, so they are parallel to each other. \
Shift the short radius across: the right triangle has \
- hypotenuse $= d = 13$, \
- one leg $= r_1 - r_2 = 9 - 4 = 5$, \
- other leg $=$ the tangent length $t$. \
$t = sqrt(d^2 - (r_1 - r_2)^2) = sqrt(169 - 25) = sqrt(144) = 12$ cm. \
*Now the general form.* For externally touching circles $d = r_1 + r_2$, so \
$t^2 = (r_1 + r_2)^2 - (r_1 - r_2)^2$. \
Expand: $(r_1^2 + 2r_1 r_2 + r_2^2) - (r_1^2 - 2 r_1 r_2 + r_2^2) = 4 r_1 r_2$. \
$t = 2 sqrt(r_1 r_2)$. \
Check: $2 sqrt(9 times 4) = 2 times 6 = 12$. Matches.
]
#ans[$t = 12$ cm, and in general $t = 2 sqrt(r_1 r_2)$]
]

#ex(36, tier: 3, asked: "Adobe · pattern")[
A cone is cut by a plane parallel to its base, exactly halfway up. Find the ratio of the volume of the small top cone to the volume of the frustum below it.
#sol[
*Insight: the top piece is a scaled copy of the whole cone. Scale the lengths by $k$ and the volume scales by $k^3$ — so compute the whole and the top, then subtract.*

Let the full cone have radius $R$ and height $H$; volume $V = 1/3 pi R^2 H$. \
Cutting halfway up means the small cone has height $H/2$. \
By similar triangles its radius is $R/2$ (every length scales by $k = 1/2$). \
Small cone volume $v = 1/3 pi (R/2)^2 (H/2) = 1/3 pi (R^2/4)(H/2) = 1/8 times 1/3 pi R^2 H = V/8$. \
Frustum $= V - v = V - V/8 = (7V)/8$. \
Ratio (small cone : frustum) $= V/8 : (7V)/8 = 1 : 7$. \
*Extend it:* cutting at $1/3$ of the height from the apex gives $k = 1/3$, so the top cone is $V/27$ and the frustum is $(26 V)/27$ — ratio $1 : 26$.
]
#ans[$1 : 7$]
]

#ex(37, tier: 3, asked: "Uber · pattern")[
From a fixed point on level ground, the angle of elevation of a hovering drone is $30 degree$. The drone then rises 40 m straight up, and the elevation becomes $60 degree$. Find the drone's original height and its horizontal distance from the observer.
#sol[
*Insight: the horizontal distance $d$ never changes. Write the same $d$ from both angles and set them equal — one unknown drops out.*

Let the first height be $h$ and the horizontal distance be $d$. \
From the first sighting: $tan 30 degree = h/d arrow.r 1/sqrt(3) = h/d arrow.r d = h sqrt(3)$. \
From the second sighting: $tan 60 degree = (h + 40)/d arrow.r sqrt(3) = (h+40)/d arrow.r d = (h + 40)/sqrt(3)$. \
Both expressions are the same $d$: \
$ h sqrt(3) = (h + 40)/sqrt(3) $
Multiply both sides by $sqrt(3)$: \
$3h = h + 40$ \
$2h = 40$ \
$h = 20$ m. \
Then $d = h sqrt(3) = 20 sqrt(3) = 20 times 1.732 = 34.64$ m. \
Check: $tan 30 degree = 20/34.64 = 0.577 = 1/sqrt(3)$. Correct. \
And $tan 60 degree = 60/34.64 = 1.732 = sqrt(3)$. Correct.
]
#ans[Original height 20 m; horizontal distance $20 sqrt(3) approx 34.64$ m]
]

#ex(38, tier: 3, asked: "Google · pattern")[
How many triangles are there whose three sides are whole numbers and whose perimeter is exactly 20?
#sol[
*Insight: fix an order $a <= b <= c$ so each triangle is counted once, then use the triangle inequality to bound the largest side before listing.*

Let $a <= b <= c$ with $a + b + c = 20$. \
Triangle inequality: $a + b > c$. \
Since $a + b = 20 - c$, this says $20 - c > c arrow.r 20 > 2c arrow.r c < 10$. \
Also $c >= 20/3 = 6.67$, because $c$ is the largest of three numbers summing to 20. \
So $c in {7, 8, 9}$. Now list. \
*$c = 9$:* $a + b = 11$ with $a <= b <= 9$, so $b >= 5.5$, giving $b in {6,7,8,9}$: \
$(2,9,9), (3,8,9), (4,7,9), (5,6,9)$ — 4 triangles. \
*$c = 8$:* $a + b = 12$ with $a <= b <= 8$, so $b >= 6$, giving $b in {6,7,8}$: \
$(4,8,8), (5,7,8), (6,6,8)$ — 3 triangles. \
*$c = 7$:* $a + b = 13$ with $a <= b <= 7$, so $b >= 6.5$, giving $b = 7$ only: \
$(6,7,7)$ — 1 triangle. \
Total $= 4 + 3 + 1 = 8$.
]
#ans[8 triangles]
]

#practice(tier: 3, time: "4 min/Q")[
+ Triangle $A B C$ has area 192 cm#super[2]. Midpoints are joined three times in a row. Find the area of the third midpoint triangle.
+ An ant crawls on the surface of a box $8 times 6 times 5$ cm, from one corner to the opposite corner. Find the shortest surface path, and say why the space diagonal is not the answer.
+ A cylinder is packed snugly inside a cube of edge 10 cm (the cylinder stands upright and touches all four side walls, the floor and the lid). What fraction of the cube is empty? Take $pi = 3.1416$.
+ Find the point on the $y$-axis that is equidistant from $(2, 3)$ and $(-1, 5)$.
+ Two circles of radii 8 cm and 3 cm have centres 13 cm apart. Find both the direct and the transverse common tangent lengths.
+ A cone is cut by a plane parallel to the base at one third of the height, measured from the apex. Find the ratio of the small cone's volume to the frustum's volume, and the ratio of their curved surface areas.
+ From a point on level ground the elevation of a tower top is $30 degree$. Walking 40 m directly towards the tower, the elevation becomes $60 degree$. Find the tower's height.
+ How many triangles have whole-number sides and perimeter exactly 24?
]

#key[
*1.* $3$ cm#super[2]. Each midpoint step scales lengths by $1/2$, so area by $1/4$. Three steps give $192 div 4^3 = 192/64 = 3$. The rule $"area ratio" = ("side ratio")^2$ is what makes the halving compound so fast. \
*2.* $sqrt(185) approx 13.60$ cm. The three unfoldings give $sqrt(8^2 + (6+5)^2) = sqrt(185)$, $sqrt((8+5)^2 + 6^2) = sqrt(205)$, and $sqrt((8+6)^2 + 5^2) = sqrt(221)$. The smallest pairs the largest edge alone. The space diagonal $sqrt(64+36+25) = sqrt(125) approx 11.18$ is shorter but passes through the inside of the box, which the ant cannot do. \
*3.* About $21.5%$ empty. Cylinder radius 5, height 10: volume $= 3.1416 times 25 times 10 = 785.4$; cube $= 1000$; empty $= 214.6$, so $21.46%$. In general the ratio is $pi/4 approx 0.7854$, independent of the edge length. \
*4.* $(0, 13/4)$. Let $P(0,k)$. Then $2^2 + (k-3)^2 = 1^2 + (k-5)^2$, so $4 + k^2 - 6k + 9 = 1 + k^2 - 10k + 25$, giving $13 - 6k = 26 - 10k$, so $4k = 13$ and $k = 3.25$. Only the $y$-coordinate is unknown, which is why one equation is enough. \
*5.* Direct $= sqrt(13^2 - (8-3)^2) = sqrt(169 - 25) = 12$ cm. Transverse $= sqrt(13^2 - (8+3)^2) = sqrt(169 - 121) = sqrt(48) = 4 sqrt(3) approx 6.93$ cm. The transverse tangent is always shorter, because it must cross between the circles. \
*6.* Volumes $1 : 26$; curved surface areas $1 : 8$. Scale factor $k = 1/3$, so volume ratio to the whole is $1/27$ and the frustum takes the other $26/27$. Curved SA scales as $k^2 = 1/9$, so the small cone is $1/9$ of the whole and the frustum's slant band is $8/9$. Note volumes and areas scale by different powers — never reuse one ratio for both. \
*7.* $20 sqrt(3) approx 34.64$ m. Let the height be $h$ and the nearer distance be $d$. Then $tan 60 degree = h/d arrow.r d = h/sqrt(3)$, and $tan 30 degree = h/(d + 40) arrow.r d + 40 = h sqrt(3)$. Subtract: $h sqrt(3) - h/sqrt(3) = 40 arrow.r h(3-1)/sqrt(3) = 40 arrow.r h = (40 sqrt(3))/2 = 20 sqrt(3)$. \
*8.* $12$ triangles. With $a <= b <= c$ and $a+b+c=24$: $c < 12$ and $c >= 8$, so $c in {8,9,10,11}$. Listing gives $(8,8,8)$; $(7,8,9), (6,9,9)$; $(4,10,10), (5,9,10), (6,8,10), (7,7,10)$; $(2,11,11), (3,10,11), (4,9,11), (5,8,11), (6,7,11)$. Count: $1 + 2 + 4 + 5 = 12$.
]

#section[Mixed set — exam conditions]

#practice(tier: 1, time: "90 s/Q · 18 questions · 27 min")[
+ Two angles of a triangle are $52 degree$ and $61 degree$. Find the exterior angle at the third vertex.
+ A right triangle has hypotenuse 26 cm and one leg 10 cm. Find the other leg and the area.
+ A circle has area 616 cm#super[2]. Find its circumference ($pi = 22/7$).
+ A regular polygon has 18 sides. Find each interior angle and the number of diagonals.
+ Find the area of a rhombus whose diagonals are 24 cm and 10 cm, and its perimeter.
+ A cone and a cylinder have the same radius 7 cm and the same height 12 cm. Find the ratio of their volumes.
+ A cube has total surface area 600 cm#super[2]. Find its volume and its space diagonal.
+ Find the slope of the line through $(2, -3)$ and $(6, 5)$, and the slope of any line perpendicular to it.
+ A sector of a circle of radius 14 cm has an angle of $90 degree$. Find its area and perimeter ($pi = 22/7$).
+ A tower casts a 25 m shadow when the sun's elevation is $45 degree$. Find the tower's height.
+ Two similar triangles have corresponding sides 6 cm and 15 cm. If the smaller has area 48 cm#super[2], find the larger area.
+ A hemisphere has radius 10.5 cm. Find its volume and total surface area ($pi = 22/7$).
+ A rectangular sheet 22 cm by 14 cm is rolled up so that the 22 cm side becomes the circumference of an open cylinder. Find the radius, the height and the volume ($pi = 22/7$).
+ Find the perpendicular distance from $(3, 4)$ to the line $5x - 12y + 9 = 0$.
+ A wire of length 132 cm is bent into a circle. Find the area enclosed ($pi = 22/7$).
+ The angle of elevation of a cliff top from a boat is $60 degree$ and the boat is 50 m from the base. Find the cliff's height ($sqrt(3) = 1.732$).
+ A closed cuboid tank is $3 times 2 times 1.5$ m. Find the cost of painting its outside at Rs.~120 per m#super[2].
+ Triangle $P Q R$ has area 120 cm#super[2]. $S$ is the midpoint of $Q R$. Find the area of triangle $P Q S$.
]

#key[
*1.* $113 degree$. The exterior angle equals the sum of the two opposite interior angles: $52 + 61$. \
*2.* Other leg $= 24$ cm ($26^2 - 10^2 = 676 - 100 = 576$); area $= 1/2 times 10 times 24 = 120$ cm#super[2]. \
*3.* $88$ cm. $r^2 = 616 times 7/22 = 196 arrow.r r = 14$; $2 times 22/7 times 14 = 88$. \
*4.* Interior $= ((18-2)180)/18 = 160 degree$; diagonals $= (18 times 15)/2 = 135$. \
*5.* Area $= 1/2 times 24 times 10 = 120$ cm#super[2]\; side $= sqrt(12^2 + 5^2) = 13$, so perimeter $= 52$ cm. \
*6.* $1 : 3$. A cone is always one third of the cylinder on the same base and height. \
*7.* $6a^2 = 600 arrow.r a = 10$; volume $= 1000$ cm#super[3]\; diagonal $= 10 sqrt(3) approx 17.32$ cm. \
*8.* Slope $= (5 - (-3))/(6 - 2) = 8/4 = 2$; perpendicular slope $= -1/2$. \
*9.* Quarter circle. Area $= 1/4 times 22/7 times 196 = 154$ cm#super[2]\; perimeter $= 1/4 times 88 + 14 + 14 = 22 + 28 = 50$ cm. \
*10.* $25$ m. $tan 45 degree = 1$, so height $=$ shadow. \
*11.* $300$ cm#super[2]. Side ratio $6:15 = 2:5$, so area ratio $4:25$; $48 times 25/4$. \
*12.* Volume $= 2/3 times 22/7 times 1157.625 = 2425.5$ cm#super[3]\; total SA $= 3 pi r^2 = 3 times 22/7 times 110.25 = 1039.5$ cm#super[2]. \
*13.* $2 pi r = 22 arrow.r r = 3.5$ cm; height $= 14$ cm; volume $= 22/7 times 12.25 times 14 = 539$ cm#super[3]. \
*14.* $24/13 approx 1.85$. $abs(5(3) - 12(4) + 9)/sqrt(25+144) = abs(-24)/13 = 24/13$. \
*15.* $1386$ cm#super[2]. $2 times 22/7 times r = 132 arrow.r r = 21$; area $= 22/7 times 441$. \
*16.* $50 sqrt(3) approx 86.6$ m. $tan 60 degree = h/50$. \
*17.* Rs.~3,240. SA $= 2(3 times 2 + 2 times 1.5 + 1.5 times 3) = 2(6 + 3 + 4.5) = 27$ m#super[2]\; $27 times 120 = 3240$. \
*18.* $60$ cm#super[2]. A median always splits a triangle into two equal areas.
]

#revision[
*Angles* — straight line $180 degree$, point $360 degree$, triangle $180 degree$. Exterior angle $=$ sum of the two opposite interiors. Co-interior angles across parallels add to $180 degree$.

*Triangles* — Area $= 1/2 b h$; Heron $= sqrt(s(s-a)(s-b)(s-c))$ with $s = ("perimeter")/2$. Equilateral: $(sqrt(3))/4 a^2$. Right-triangle inradius $= (a+b-c)/2$, circumradius $= c/2$. Triples: $3,4,5$ · $5,12,13$ · $8,15,17$ · $7,24,25$ · $9,40,41$ · $20,21,29$.

*Similarity* — sides $k$ $arrow.r$ perimeters $k$, areas $k^2$, volumes $k^3$. Midpoint triangle: $1/4$ the area.

*Circles* — $C = 2 pi r$, $A = pi r^2$. Chord: $r^2 = h^2 + (L/2)^2$. Sector: arc $= theta/360 times 2 pi r$, area $= theta/360 times pi r^2$, perimeter $=$ arc $+ 2r$. Tangents: direct $= sqrt(d^2 - (r_1-r_2)^2)$, transverse $= sqrt(d^2 - (r_1+r_2)^2)$.

*Polygons* — interior sum $(n-2)180$; exterior $= 360/n$; diagonals $= (n(n-3))/2$.

*Solids* — Cylinder $pi r^2 h$, CSA $2 pi r h$. Cone $1/3 pi r^2 h$, CSA $pi r l$, $l = sqrt(r^2+h^2)$. Sphere $4/3 pi r^3$, SA $4 pi r^2$. Hemisphere $2/3 pi r^3$, TSA $3 pi r^2$. Frustum $1/3 pi h(R^2 + R r + r^2)$.

*Coordinates* — distance $sqrt((Delta x)^2 + (Delta y)^2)$; midpoint $=$ averages; slope $= (Delta y)/(Delta x)$; perpendicular slopes multiply to $-1$; triangle area $= 1/2|x_1(y_2-y_3)+x_2(y_3-y_1)+x_3(y_1-y_2)|$; point-to-line $= abs(a x_0 + b y_0 + c)/sqrt(a^2+b^2)$.

*Trig* — $tan 30 degree = 1/sqrt(3)$, $tan 45 degree = 1$, $tan 60 degree = sqrt(3)$. Elevation: $tan theta = "height"/"distance"$. At $45 degree$ height $=$ distance.

*Shortcuts worth memorising*
- Use $pi = 22/7$ whenever a radius is a multiple of 7 or of 3.5 — the fraction cancels and no decimals appear.
- Melting or recasting: set volumes equal and cancel $pi$ and any common factors *before* multiplying. The answer is usually a ratio of cubes.
- Interior-angle polygon questions: go via the exterior angle, $n = 360 div "exterior"$.
- "Touch a line and return" (shortest path): reflect one point, draw the straight line, read the crossing point.
- Ant on a box: unfold. Pair the *largest* edge alone against the sum of the other two.
- Two elevation angles from the same line: the horizontal distance is shared. Write it twice and equate.

*Top 5 traps*
+ The distance from the centre reaches the chord's *midpoint*: double the half-chord at the end.
+ A sector's perimeter is arc $+ 2r$, not just the arc.
+ A path "all round" a plot adds its width *twice* to each dimension.
+ Equal perimeters do not mean equal areas — a circle beats a square every time.
+ On a box's *surface*, the space diagonal is not available. Unfold instead.
]

]
