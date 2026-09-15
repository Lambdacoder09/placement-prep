#import "../../shared/lib/style.typ": *

#chapter(num: 9, title: "Networks: Layers, IP & Routing",
  tagline: "Where the packet is, who rewrites it, and how to do subnet arithmetic in your head")[

#section[What this round actually asks]

Networking in a technical round is two things glued together.

#table(columns: 3,
  align: (left, left, left),
  [*Half*], [*What it is*], [*How it is scored*],
  [Vocabulary], [layers, PDU names, device per layer, protocol per layer, DNS, NAT, ARP],
    [instant. You know it or you do not. 10--20 seconds per question.],
  [Arithmetic], [subnet mask, network address, broadcast, usable hosts, VLSM, route lookup],
    [you must show the steps. A wrong last octet is a zero.],
)

Service companies (TCS, Infosys, Wipro, Capgemini, Cognizant) ask the vocabulary half
rapid-fire and *always* give you one subnetting sum. Product companies ask fewer facts and
then push: "why does the router rewrite the MAC but not the IP?", "what breaks if two
networks both use 192.168.1.0/24 and you VPN them together?"

This chapter builds the arithmetic until it is automatic, then the vocabulary hangs off it.

#formulas(title: "Everything this chapter is built on")[

*The two models.* OSI has 7 layers and is the exam model. TCP/IP has 4 layers and is the
real one.

#table(columns: 5,
  align: (center, left, left, left, left),
  [*\#*], [*OSI layer*], [*PDU*], [*Address it uses*], [*Lives where*],
  [7], [Application], [data], [URL / name], [HTTP, DNS, SMTP, FTP, DHCP],
  [6], [Presentation], [data], [--], [TLS, encoding, compression],
  [5], [Session], [data], [--], [session setup / teardown],
  [4], [Transport], [segment (TCP) / datagram (UDP)], [port number], [TCP, UDP],
  [3], [Network], [packet], [IP address], [IP, ICMP, routers],
  [2], [Data link], [frame], [MAC address], [Ethernet, ARP, switches],
  [1], [Physical], [bit], [--], [cable, radio, voltage],
)

*Subnetting laws.* For a prefix $p$ written as `/p`:

$ "addresses in the block" = 2^(32-p) $
$ "usable hosts" = 2^(32-p) - 2 quad (p <= 30) $
$ "subnets made by borrowing" b "bits" = 2^b $
$ "block size in the interesting octet" = 256 - "that octet of the mask" $

*Network address* = the IP with all host bits set to 0. \
*Broadcast address* = the IP with all host bits set to 1. \
*Usable range* = network+1 up to broadcast$-$1.

*Delay on one link.*
$ "transmission" T_t = L / R quad "(L bits, R bits per second)" $
$ "propagation" T_p = d / s quad "(d metres, s about " 2 times 10^8 " m/s in fibre)" $
$ "total one-way" = T_t + T_p + "queuing" + "processing" $

*Longest prefix match.* A router picks the matching route with the *largest* prefix length.
`0.0.0.0/0` matches everything and always loses to anything else.
]

#section[Part 1 — The layer stack]

#subsection[The picture you must be able to draw]

Data goes *down* the stack at the sender. Each layer sticks its own header on the front.
At the receiver it goes *up* and each layer peels its own header off. Adding a header is
*encapsulation*. Removing it is *decapsulation*.

#diagram(height: 5.6cm, caption: "encapsulation: each layer wraps what the layer above gave it")[
  #dnode(5.0cm, 0pt,    4.0cm, 0.7cm, "user data")
  #dnode(11.0cm, 0pt,   4.6cm, 0.7cm, "L7 application: data")

  #dnode(3.6cm, 1.1cm,  1.4cm, 0.7cm, "TCP", fill: rgb("#e6eef5"))
  #dnode(5.0cm, 1.1cm,  4.0cm, 0.7cm, "user data")
  #dnode(11.0cm, 1.1cm, 4.6cm, 0.7cm, "L4 transport: segment")

  #dnode(2.2cm, 2.2cm,  1.4cm, 0.7cm, "IP", fill: rgb("#e6eef5"))
  #dnode(3.6cm, 2.2cm,  1.4cm, 0.7cm, "TCP", fill: rgb("#e6eef5"))
  #dnode(5.0cm, 2.2cm,  4.0cm, 0.7cm, "user data")
  #dnode(11.0cm, 2.2cm, 4.6cm, 0.7cm, "L3 network: packet")

  #dnode(0.8cm, 3.3cm,  1.4cm, 0.7cm, "ETH", fill: rgb("#e6eef5"))
  #dnode(2.2cm, 3.3cm,  1.4cm, 0.7cm, "IP", fill: rgb("#e6eef5"))
  #dnode(3.6cm, 3.3cm,  1.4cm, 0.7cm, "TCP", fill: rgb("#e6eef5"))
  #dnode(5.0cm, 3.3cm,  4.0cm, 0.7cm, "user data")
  #dnode(9.0cm, 3.3cm,  1.2cm, 0.7cm, "FCS", fill: rgb("#e6eef5"))
  #dnode(11.0cm, 3.3cm, 4.6cm, 0.7cm, "L2 data link: frame")

  #dnode(0.8cm, 4.4cm,  9.4cm, 0.7cm, "1 0 1 1 0 0 1 0 1 1 0 1 ...")
  #dnode(11.0cm, 4.4cm, 4.6cm, 0.7cm, "L1 physical: bits")

  #darrow(0.4cm, 0.5cm, 0.4cm, 4.4cm)
]

#trick[
Memorise the stack bottom-up with a sentence you make yourself. One that works:
#strong[P]lease #strong[D]o #strong[N]ot #strong[T]hrow #strong[S]ausage #strong[P]izza #strong[A]way \
\= Physical, Data link, Network, Transport, Session, Presentation, Application.
Layer 1 is Physical. Layer 7 is Application. If you are asked "what is layer 4", count up.
]

#subsection[TCP/IP: the model that actually runs]

#table(columns: 3,
  align: (left, left, left),
  [*TCP/IP layer*], [*Swallows which OSI layers*], [*Protocols*],
  [Application], [7 + 6 + 5], [HTTP, DNS, SMTP, FTP, SSH, DHCP],
  [Transport], [4], [TCP, UDP],
  [Internet], [3], [IP, ICMP, ARP#footnote[ARP sits awkwardly. It carries IP addresses but is delivered in a raw Ethernet frame, so different books put it at layer 2 or layer 3. Say: "between 2 and 3 --- it maps a layer-3 address to a layer-2 address." That answer is never marked wrong.]],
  [Network access], [2 + 1], [Ethernet, Wi-Fi, PPP],
)

#trap[
"OSI is used on the internet." *No.* OSI is a teaching and reference model. The internet
runs the TCP/IP model. OSI's session and presentation layers do not exist as separate
pieces in a real stack --- TLS and content encoding live inside the application.
]

#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
Name the PDU at layers 4, 3, 2 and 1.
]
#sol[
Layer 4 = segment (TCP) or datagram (UDP). Layer 3 = packet. Layer 2 = frame.
Layer 1 = bit.
#ans[segment, packet, frame, bit]
]

#ex(2, tier: 0, asked: "warm-up")[
Which layer does each device work at: hub, switch, router, NIC?
]
#sol[
#table(columns: 3, align: (left, center, left),
  [*Device*], [*Layer*], [*What it looks at*],
  [Hub / repeater], [1], [nothing --- copies bits to every other port],
  [Switch / bridge], [2], [destination MAC address],
  [Router], [3], [destination IP address],
  [NIC (network card)], [1 + 2], [puts bits on the wire, owns the MAC],
)
#ans[hub 1, switch 2, router 3, NIC 1--2]
]

#ex(3, tier: 0, asked: "warm-up")[
A switch has 8 ports, all in one VLAN. How many collision domains and how many broadcast
domains? Now answer the same for an 8-port hub.
]
#sol[
*Switch.* Every port is its own collision domain, because a switch buffers and forwards
instead of repeating. So *8 collision domains*. A switch floods broadcasts out of every
port, so all 8 ports share *1 broadcast domain*.

*Hub.* A hub repeats every bit to every port. All 8 ports are one shared wire, so
*1 collision domain* and *1 broadcast domain*.

A *router* port is the boundary: a router does not forward broadcasts, so each router
interface starts a new broadcast domain.
#ans[switch: 8 collision, 1 broadcast. Hub: 1 collision, 1 broadcast.]
]

#tier-header(1)

#ex(4, tier: 1, asked: "Infosys · pattern")[
A file of 1500 bytes is sent over one 10 Mbps link that is 2000 km long. Signal speed in the
fibre is $2 times 10^8$ m/s. Ignore queuing and processing. How long until the last bit
arrives?
]
#sol[
*Step 1 --- length in bits.* $L = 1500 times 8 = 12000$ bits.

*Step 2 --- transmission delay* (time to push the bits out of the card):
$ T_t = L / R = 12000 / (10 times 10^6) = 1.2 times 10^(-3) "s" = 1.2 "ms" $

*Step 3 --- propagation delay* (time for a bit to fly down the fibre):
$ T_p = d / s = (2 times 10^6) / (2 times 10^8) = 10^(-2) "s" = 10 "ms" $

*Step 4 --- add them.* $1.2 + 10 = 11.2$ ms.
#ans[11.2 ms]
]
#trick[
Transmission delay depends on *how big the file is* and *how fast the link is*. Propagation
delay depends on *how far it is* and nothing else. Making the link faster does not shrink
propagation delay at all --- that is why a ping to another continent never drops below
about 100 ms no matter what you pay.
]

#ex(5, tier: 1, asked: "TCS NQT · pattern")[
The same 1000-byte packet now crosses *3* links of 2 Mbps each, through 2 store-and-forward
routers. Propagation is negligible. Total time?
]
#sol[
Store-and-forward means a router must receive the *whole* packet before it starts sending it
on. So the packet is transmitted 3 times, once per link.

$ T_t "per link" = (1000 times 8) / (2 times 10^6) = 8000 / (2 times 10^6) = 4 "ms" $

Three links: $3 times 4 = 12$ ms.
#ans[12 ms]
]
#trap[
Students divide by 3 "because there are 3 links sharing the work". Wrong direction. Each
extra store-and-forward hop *adds* one full transmission time. With $n$ links the answer is
$n times T_t$, not $T_t \/ n$.
]

#section[Part 2 — IPv4 addresses]

#subsection[Dotted decimal is just 32 bits in a costume]

An IPv4 address is 32 bits. We print it as 4 decimal numbers ("octets"), each 0--255,
separated by dots. Nothing more.

#table(columns: 2, align: (left, left),
  [*Dotted decimal*], [*The same 32 bits*],
  [192.168.10.77], [11000000 . 10101000 . 00001010 . 01001101],
  [10.0.0.1], [00001010 . 00000000 . 00000000 . 00000001],
  [255.255.255.192], [11111111 . 11111111 . 11111111 . 11000000],
)

#trick[
*Octet to binary in 5 seconds.* Write the place values once: 128 64 32 16 8 4 2 1.
Then greedily subtract.

77: is 128 $<=$ 77? no $arrow.r$ 0. 64 $<=$ 77? yes $arrow.r$ 1, left 13.
32? no $arrow.r$ 0. 16? no $arrow.r$ 0. 8 $<=$ 13? yes $arrow.r$ 1, left 5.
4 $<=$ 5? yes $arrow.r$ 1, left 1. 2? no $arrow.r$ 0. 1? yes $arrow.r$ 1, left 0.
Result *01001101*. Check: $64+8+4+1 = 77$. Correct.
]

#code(lang: "js", caption: "IPv4 address <-> plain integer (run with node)")[
```js
// IPv4 <-> 32-bit unsigned integer
const toInt = (ip) =>
  ip.split(".").reduce((acc, oct) => acc * 256 + Number(oct), 0);

const toIp = (n) =>
  [24, 16, 8, 0].map((s) => Math.floor(n / 2 ** s) % 256).join(".");

console.log(toInt("192.168.10.77"));
console.log(toIp(3232238157));
console.log(toIp(toInt("10.20.30.40")));
console.log(toInt("255.255.255.255"), toIp(0));
```
]

#code(lang: "text", caption: "output")[
```text
3232238157
192.168.10.77
10.20.30.40
4294967295 0.0.0.0
```
]

#note[
Why `2 ** s` and `Math.floor` instead of the bit operators `>>>` and `&`? Because JavaScript
bit operators convert to a *signed* 32-bit integer. `toInt("255.255.255.255") | 0` gives
$-1$, not 4294967295. Doing the arithmetic with `*` and `/` keeps every value a safe
positive double. This is JS trap number 4 from the language notes: numbers are doubles.
]

#subsection[The old classes, and the special addresses]

Classes are obsolete in practice (CIDR replaced them in 1993) but they are asked constantly.

#table(columns: 5,
  align: (center, left, center, left, left),
  [*Class*], [*First octet*], [*Default prefix*], [*Networks*], [*Hosts per network*],
  [A], [1 -- 126], [/8], [126], [16,777,214],
  [B], [128 -- 191], [/16], [16,384], [65,534],
  [C], [192 -- 223], [/24], [2,097,152], [254],
  [D], [224 -- 239], [--], [multicast], [--],
  [E], [240 -- 255], [--], [reserved / experimental], [--],
)

#trick[
Read the first octet, top bits first: starts with `0` $arrow.r$ A, `10` $arrow.r$ B,
`110` $arrow.r$ C, `1110` $arrow.r$ D, `1111` $arrow.r$ E.
Fast decimal check: under 128 = A, under 192 = B, under 224 = C, under 240 = D, rest = E.
]

#table(columns: 3,
  align: (left, left, left),
  [*Range*], [*Name*], [*Meaning*],
  [10.0.0.0/8], [private (class A)], [never routed on the public internet],
  [172.16.0.0/12], [private (class B)], [covers 172.16.x.x to 172.31.x.x],
  [192.168.0.0/16], [private (class C)], [the home-router range],
  [127.0.0.0/8], [loopback], [127.0.0.1 = this machine],
  [169.254.0.0/16], [link-local / APIPA], [self-assigned when DHCP fails],
  [100.64.0.0/10], [carrier-grade NAT], [used inside ISP networks],
  [224.0.0.0/4], [multicast], [one sender, a group of receivers],
  [0.0.0.0], [unspecified], [as a route it means "everywhere"],
  [255.255.255.255], [limited broadcast], [this link only, never forwarded],
)

#trap[
172.16.0.0/12 is *not* 172.16.0.0 to 172.16.255.255. The /12 means 4 bits of the second
octet are fixed, so the range is *172.16.0.0 to 172.31.255.255*. 172.32.5.1 is a public
address. Candidates lose this one constantly.
]

#tier-header(1)

#ex(6, tier: 1, asked: "Capgemini · pattern")[
Classify each address and say whether it is public or private:
(a) 172.19.4.8 (b) 172.35.4.8 (c) 192.168.200.1 (d) 127.0.0.5 (e) 169.254.9.9
]
#sol[
#table(columns: 4, align: (left, center, left, left),
  [*Address*], [*Class*], [*Public / private*], [*Why*],
  [172.19.4.8], [B], [private], [inside 172.16--172.31],
  [172.35.4.8], [B], [public], [35 is above 31],
  [192.168.200.1], [C], [private], [inside 192.168.0.0/16],
  [127.0.0.5], [A (reserved)], [neither], [loopback, never leaves the host],
  [169.254.9.9], [B range], [neither], [APIPA --- DHCP failed],
)
#ans[(a) private B (b) public B (c) private C (d) loopback (e) APIPA / link-local]
]
#trick[
Seeing 169.254.x.x on a machine is a diagnosis, not a configuration. It means
*the DHCP server never answered*. Check the cable, the Wi-Fi association, or the DHCP
service --- not the IP settings.
]

#section[Part 3 — Subnetting, the method]

This is the one calculation you are guaranteed to be given. Learn it as a fixed drill.

#subsection[The one table to memorise]

#table(columns: 5,
  align: (center, left, right, right, left),
  [*Prefix*], [*Mask*], [*Block size*], [*Usable hosts*], [*Nickname*],
  [/8],  [255.0.0.0],       [16,777,216], [16,777,214], [class A],
  [/16], [255.255.0.0],     [65,536],     [65,534],     [class B],
  [/20], [255.255.240.0],   [4,096],      [4,094],      [],
  [/22], [255.255.252.0],   [1,024],      [1,022],      [],
  [/23], [255.255.254.0],   [512],        [510],        [],
  [/24], [255.255.255.0],   [256],        [254],        [class C],
  [/25], [255.255.255.128], [128],        [126],        [half a C],
  [/26], [255.255.255.192], [64],         [62],         [quarter],
  [/27], [255.255.255.224], [32],         [30],         [],
  [/28], [255.255.255.240], [16],         [14],         [],
  [/29], [255.255.255.248], [8],          [6],          [],
  [/30], [255.255.255.252], [4],          [2],          [router link],
  [/31], [255.255.255.254], [2],          [2 (special)], [point-to-point, RFC 3021],
  [/32], [255.255.255.255], [1],          [1 (host route)], [one exact host],
)

#trick[
You only need to remember the right-hand column of mask values:
*128, 192, 224, 240, 248, 252, 254, 255*.
Each is the previous one plus the next power of two going down: $128, +64, +32, +16, +8, +4,
+2, +1$. Block size is always $256 -$ that value: $128 arrow.r 128$, $192 arrow.r 64$,
$224 arrow.r 32$, $240 arrow.r 16$, $248 arrow.r 8$, $252 arrow.r 4$.
]

#subsection[The four-step drill]

Given any `IP/prefix`:

#table(columns: 2, align: (left, left),
  [*Step 1*], [Find the *interesting octet*: /1--/8 is octet 1, /9--/16 is octet 2, /17--/24 is octet 3, /25--/32 is octet 4.],
  [*Step 2*], [Block size $= 256 -$ (mask value in that octet). Equivalently $2^(8 - (p mod 8))$ when $p$ is not a multiple of 8.],
  [*Step 3*], [Network address: round that octet *down* to the nearest multiple of the block size. Zero every octet after it.],
  [*Step 4*], [Broadcast = network + block size $- 1$ in that octet, 255 in every octet after it. Usable range is network+1 to broadcast$-$1.],
)

#tier-header(0)

#ex(7, tier: 0, asked: "warm-up")[
For 192.168.10.77/26 find the mask, network, broadcast, first host, last host and host
count.
]
#sol[
*Step 1.* /26 is between 25 and 32, so the interesting octet is the *4th* (77).

*Step 2.* $26 = 24 + 2$, so 2 bits are borrowed in octet 4. Mask octet $= 256 - 2^(8-2)
= 256 - 64 = 192$. Mask = *255.255.255.192*. Block size = *64*.

*Step 3.* Multiples of 64: 0, 64, 128, 192. Round 77 down $arrow.r$ *64*.
Network = *192.168.10.64*.

*Step 4.* Broadcast $= 64 + 64 - 1 = 127$ $arrow.r$ *192.168.10.127*.
First host *192.168.10.65*, last host *192.168.10.126*.
Hosts $= 2^(32-26) - 2 = 64 - 2 = 62$.
#ans[mask 255.255.255.192 · net .64 · bcast .127 · range .65--.126 · 62 hosts]
]

#diagram(height: 4.6cm, caption: "192.168.10.0/24 cut into four /26 blocks of 64 addresses each")[
  #dnode(0pt, 0pt, 15.4cm, 0.7cm, "192.168.10.0/24    —    256 addresses, .0 to .255")
  #darrow(7.7cm, 0.7cm, 7.7cm, 1.25cm)

  #dnode(0pt,    1.35cm, 3.7cm, 0.75cm, ".0 – .63\n/26  block 0")
  #dnode(3.9cm,  1.35cm, 3.7cm, 0.75cm, ".64 – .127\n/26  block 1", fill: rgb("#e2ecf3"))
  #dnode(7.8cm,  1.35cm, 3.7cm, 0.75cm, ".128 – .191\n/26  block 2")
  #dnode(11.7cm, 1.35cm, 3.7cm, 0.75cm, ".192 – .255\n/26  block 3")

  #dnode(0pt,    2.3cm, 3.7cm, 1.35cm, "net .0\nhosts .1 – .62\nbcast .63")
  #dnode(3.9cm,  2.3cm, 3.7cm, 1.35cm, "net .64\nhosts .65 – .126\nbcast .127", fill: rgb("#e2ecf3"))
  #dnode(7.8cm,  2.3cm, 3.7cm, 1.35cm, "net .128\nhosts .129 – .190\nbcast .191")
  #dnode(11.7cm, 2.3cm, 3.7cm, 1.35cm, "net .192\nhosts .193 – .254\nbcast .255")
]

The shaded block is where .77 lands. Every subnetting question is "which block, and what are
its three edges".

#ex(8, tier: 0, asked: "warm-up")[
How many /28 subnets fit inside one /24? How many usable hosts does each have?
]
#sol[
Bits borrowed $= 28 - 24 = 4$, so subnets $= 2^4 = 16$.
Hosts each $= 2^(32-28) - 2 = 16 - 2 = 14$.
Sanity check: $16 times 16 = 256$ addresses, which is exactly one /24.
#ans[16 subnets, 14 usable hosts each]
]

#tier-header(1)

#ex(9, tier: 1, asked: "TCS NQT · pattern")[
Host 172.16.35.200 has mask 255.255.240.0. Find network, broadcast, usable range and host
count.
]
#sol[
*Step 1.* Mask 255.255.240.0 is /20 ($8+8+4$). Interesting octet is the *3rd* (35).

*Step 2.* Block size $= 256 - 240 = 16$.

*Step 3.* Multiples of 16: 0, 16, *32*, 48, ... Round 35 down $arrow.r$ 32.
Network = *172.16.32.0*.

*Step 4.* Broadcast third octet $= 32 + 16 - 1 = 47$, last octet 255
$arrow.r$ *172.16.47.255*.
Range *172.16.32.1 -- 172.16.47.254*.
Hosts $= 2^(32-20) - 2 = 4096 - 2 = 4094$.
#ans[net 172.16.32.0 · bcast 172.16.47.255 · 4094 hosts]
]
#trap[
When the interesting octet is the 3rd, the 4th octet is *not* part of the rounding. It goes
to 0 in the network address and 255 in the broadcast. A common wrong answer here is
"172.16.47.0" for the broadcast.
]

#ex(10, tier: 1, asked: "Wipro · pattern")[
Which of these are valid *host* addresses inside 203.0.113.64/27?
(a) 203.0.113.64 (b) 203.0.113.65 (c) 203.0.113.94 (d) 203.0.113.95 (e) 203.0.113.96
]
#sol[
/27 $arrow.r$ block size $256 - 224 = 32$. The block starting at 64 runs 64 to 95.

#table(columns: 3, align: (left, left, left),
  [*Address*], [*Role*], [*Usable as a host?*],
  [.64], [network address (all host bits 0)], [no],
  [.65], [first host], [yes],
  [.94], [last host], [yes],
  [.95], [broadcast (all host bits 1)], [no],
  [.96], [network address of the *next* /27], [no --- different subnet],
)
#ans[(b) and (c) only]
]

#ex(11, tier: 1, asked: "Cognizant · pattern")[
You own 192.168.5.0/24. You need 6 subnets, each holding at least 25 hosts. What prefix do
you use, and list the subnets?
]
#sol[
*Step 1 --- solve for hosts.* Need $2^h - 2 >= 25$, so $2^h >= 27$, so $h = 5$
($2^5 - 2 = 30$, and $h=4$ gives only 14). Host bits $h = 5$ $arrow.r$ prefix $= 32 - 5
= $ #strong[/27].

*Step 2 --- check the subnet count.* Borrowed bits $= 27 - 24 = 3$ $arrow.r$ $2^3 = 8$
subnets. We need 6, so 8 is enough (2 spare).

*Step 3 --- block size* $= 256 - 224 = 32$. Walk in steps of 32:

#table(columns: 4, align: (left, left, left, left),
  [*\#*], [*Network*], [*Usable range*], [*Broadcast*],
  [1], [192.168.5.0/27],   [.1 -- .30],    [.31],
  [2], [192.168.5.32/27],  [.33 -- .62],   [.63],
  [3], [192.168.5.64/27],  [.65 -- .94],   [.95],
  [4], [192.168.5.96/27],  [.97 -- .126],  [.127],
  [5], [192.168.5.128/27], [.129 -- .158], [.159],
  [6], [192.168.5.160/27], [.161 -- .190], [.191],
  [7], [192.168.5.192/27], [.193 -- .222], [.223],
  [8], [192.168.5.224/27], [.225 -- .254], [.255],
)
#ans[/27, mask 255.255.255.224, 8 subnets of 30 hosts; use the first 6]
]
#trick[
Two different questions, two different formulas. "How many *hosts*" $arrow.r$ count the
*host* bits: $2^h - 2$. "How many *subnets*" $arrow.r$ count the *borrowed* bits: $2^b$.
Decide which one is being asked before you touch the arithmetic.
]

#ex(12, tier: 1, asked: "Accenture · pattern")[
A company needs a block big enough for 500 hosts. Which prefix is the smallest that works,
and how much space is wasted?
]
#sol[
$2^h - 2 >= 500 arrow.r 2^h >= 502 arrow.r h = 9$ (since $2^8 - 2 = 254$ is too small and
$2^9 - 2 = 510$ fits).
Prefix $= 32 - 9 = $ #strong[/23], mask 255.255.254.0.
Usable $= 510$. Waste $= 510 - 500 = 10$ usable addresses, plus the 2 reserved ones.
#ans[/23 (255.255.254.0), 510 usable, 10 spare]
]

#subsection[Doing it with code]

#code(lang: "js", caption: "a complete subnet calculator (run with node)")[
```js
const toInt = (ip) => ip.split(".").reduce((a, o) => a * 256 + Number(o), 0);
const toIp  = (n) => [24, 16, 8, 0].map((s) => Math.floor(n / 2 ** s) % 256).join(".");

function subnet(cidr) {
  const [ip, pStr] = cidr.split("/");
  const p = Number(pStr);
  const size = 2 ** (32 - p);            // addresses in the block
  const maskInt = 2 ** 32 - size;        // mask as an integer
  const ipInt = toInt(ip);
  const network = Math.floor(ipInt / size) * size;   // snap down to a block edge
  const broadcast = network + size - 1;
  return {
    mask: toIp(maskInt),
    wildcard: toIp(size - 1),
    network: toIp(network),
    broadcast: toIp(broadcast),
    firstHost: toIp(network + 1),
    lastHost: toIp(broadcast - 1),
    usableHosts: size - 2,
  };
}

for (const c of ["192.168.10.77/26", "172.16.35.200/20", "203.0.113.77/27"]) {
  console.log(c, subnet(c));
}
```
]

#code(lang: "text", caption: "output — the same numbers we computed by hand")[
```text
192.168.10.77/26 {
  mask: '255.255.255.192',  wildcard: '0.0.0.63',
  network: '192.168.10.64', broadcast: '192.168.10.127',
  firstHost: '192.168.10.65', lastHost: '192.168.10.126', usableHosts: 62
}
172.16.35.200/20 {
  mask: '255.255.240.0',   wildcard: '0.0.15.255',
  network: '172.16.32.0',  broadcast: '172.16.47.255',
  firstHost: '172.16.32.1', lastHost: '172.16.47.254', usableHosts: 4094
}
203.0.113.77/27 {
  mask: '255.255.255.224', wildcard: '0.0.0.31',
  network: '203.0.113.64', broadcast: '203.0.113.95',
  firstHost: '203.0.113.65', lastHost: '203.0.113.94', usableHosts: 30
}
```
]

The line `Math.floor(ipInt / size) * size` is the whole idea of a subnet mask in one
expression: *throw away the host part*. A router does the same thing with a bitwise AND.

#note[
The *wildcard mask* is the mask with every bit flipped: for /26 it is 0.0.0.63. Access
control lists and OSPF configuration use wildcards instead of masks. Block size minus one
gives it to you for free.
]

#subsection[VLSM — different sizes from one block]

Fixed-size subnetting wastes addresses when departments differ in size. VLSM (Variable
Length Subnet Masking) cuts blocks of different sizes out of one parent.

#trick[
*The VLSM rule: always allocate the biggest requirement first.* If you place a small block
first you will straddle a boundary and the next big block will not fit anywhere clean.
]

#tier-header(2)

#ex(13, tier: 2, asked: "Grab · pattern")[
You have 192.168.1.0/24 for one office floor. Requirements:

#table(columns: 2, align: (left, right),
  [*Segment*], [*Hosts needed*],
  [Engineering], [60],
  [Sales], [28],
  [Operations], [12],
  [Router-to-router link], [2],
)

Allocate with VLSM. Give network, range and broadcast for each.
]
#sol[
*Step 1 --- turn each requirement into a prefix.*

#table(columns: 4, align: (left, right, center, right),
  [*Segment*], [*Need*], [*Smallest $2^h - 2$ that fits*], [*Prefix*],
  [Engineering], [60], [$2^6 - 2 = 62$], [/26],
  [Sales],       [28], [$2^5 - 2 = 30$], [/27],
  [Operations],  [12], [$2^4 - 2 = 14$], [/28],
  [Link],        [2],  [$2^3 - 2 = 6$],  [/29],
)

*Step 2 --- sort biggest first* (already sorted) and lay them down from .0.

Engineering /26, block 64 $arrow.r$ starts at 0, ends at 63.
Next free address is 64. Sales /27, block 32 $arrow.r$ 64 is a multiple of 32, so start at
64, end at 95.
Next free is 96. Operations /28, block 16 $arrow.r$ 96 is a multiple of 16, start 96, end
111.
Next free is 112. Link /29, block 8 $arrow.r$ 112 is a multiple of 8, start 112, end 119.

*Step 3 --- write the table.*

#table(columns: 5, align: (left, left, left, left, right),
  [*Segment*], [*Network*], [*First -- last host*], [*Broadcast*], [*Usable*],
  [Engineering], [192.168.1.0/26],   [.1 -- .62],     [.63],  [62],
  [Sales],       [192.168.1.64/27],  [.65 -- .94],    [.95],  [30],
  [Operations],  [192.168.1.96/28],  [.97 -- .110],   [.111], [14],
  [Link],        [192.168.1.112/29], [.113 -- .118],  [.119], [6],
)

*Step 4 --- what is left.* Used 0 to 119. Free: .120 to .255, which is 136 addresses. That
free space can still be cut as 192.168.1.120/29, 192.168.1.128/25, and so on.
#ans[/26, /27, /28, /29 laid down at .0, .64, .96, .112]
]
#trap[
A very common VLSM error is starting Sales at .63 ("the next address after Engineering's
broadcast"). .63 *is* Engineering's broadcast. The next usable start is .64. And it must
also be a multiple of the new block size --- .65 would be illegal for a /27.
]

#subsection[Supernetting — gluing blocks together]

Route aggregation is VLSM in reverse: many small blocks advertised as one big one, so the
routing table stays small.

#ex(14, tier: 2, asked: "Shopee · pattern")[
A router learns 200.10.4.0/24, 200.10.5.0/24, 200.10.6.0/24 and 200.10.7.0/24. Advertise
them as a single route.
]
#sol[
*Step 1 --- write the varying octet in binary.*

#table(columns: 2, align: (left, left),
  [4], [00000#strong[100]],
  [5], [00000#strong[101]],
  [6], [00000#strong[110]],
  [7], [00000#strong[111]],
)

*Step 2 --- count the leading bits that are the same.* All four start `000001`. That is 6
matching bits in the third octet. The first two octets (16 bits) match fully.
Total matching $= 16 + 6 = 22$.

*Step 3 --- the aggregate is the lowest network with that prefix:* *200.10.4.0/22*.

*Step 4 --- verify.* /22 block size in the third octet $= 256 - 252 = 4$. Starting at 4 it
covers 4, 5, 6, 7. Exactly the four inputs, no extras.
#ans[200.10.4.0/22, mask 255.255.252.0]
]
#trap[
Aggregation is only safe when the blocks are *contiguous* and start on a correct boundary.
200.10.5.0/24 + 200.10.6.0/24 cannot become a /23: a /23 starting at 5 is illegal because 5
is not a multiple of 2 in that octet. You would have to advertise 200.10.4.0/22, which
also claims 4 and 7 --- addresses you do not own. That is a black hole.
]

#tier-header(3)

#ex(15, tier: 3, asked: "Amazon · pattern")[
A VPC is 10.42.0.0/16. Your platform team wants:
3 availability zones, each with one public subnet for 60 hosts and one private subnet for
1000 hosts, and one shared /28 for a NAT/management segment. Design the allocation so that
*each zone's whole allocation can be advertised as one route*, and say how much of the /16
is still free.
]
#sol[
*Step 1 --- size each zone.* Per zone: public needs 60 $arrow.r$ /26 (62 hosts). Private
needs 1000 $arrow.r$ $2^10 - 2 = 1022$, so /22.

*Step 2 --- the "one route per zone" constraint.* A zone contains a /22 and a /26. To
aggregate them into a single prefix, the whole zone must sit inside one block that is a
power of two and aligned. The /22 dominates the size. A /22 plus a /26 does not fit in a
/22, so the zone block must be the next size up: #strong[/21] (2048 addresses). Then the /22 and
the /26 both sit inside it and the zone is advertised as a single /21.

*Step 3 --- lay out three /21 zones from 10.42.0.0.* /21 block size in the third octet
$= 256 - 248 = 8$.

#table(columns: 4, align: (left, left, left, left),
  [*Zone*], [*Zone block (one route)*], [*Private /22*], [*Public /26*],
  [AZ-a], [10.42.0.0/21],  [10.42.0.0/22], [10.42.4.0/26],
  [AZ-b], [10.42.8.0/21],  [10.42.8.0/22], [10.42.12.0/26],
  [AZ-c], [10.42.16.0/21], [10.42.16.0/22], [10.42.20.0/26],
)

*Step 4 --- the shared /28.* Put it well clear of the zones so it never blocks a future
zone. Take it from the top: *10.42.255.240/28* (block size 16, last block of the /16).

*Step 5 --- free space.* Zones consume 10.42.0.0 through 10.42.23.255 = $3 times 2048 =
6144$ addresses. The /28 consumes 16. Total in the /16 is 65,536.
Free $= 65536 - 6144 - 16 = 59{,}376$ addresses --- enough for 28 more /21 zones.

*The trade-off to say out loud.* Rounding each zone to /21 wastes 962 addresses per zone
(2048 used, 1086 needed). You buy back a routing table that has 3 entries instead of 7. In a
VPC with route-table entry limits and peering, that trade is worth it. If address space were
scarce instead, you would pack tightly and accept the bigger table.
#ans[three /21 zones at .0, .8, .16; shared 10.42.255.240/28; 59,376 addresses free]
]

#section[Part 4 — How a packet actually leaves your machine]

#subsection[The same-subnet test]

Before sending anything, a host asks one question: *is the destination in my own subnet?*
It ANDs its own IP with its mask, ANDs the destination with the same mask, and compares.

#code(lang: "js", caption: "the decision every host makes before it sends (run with node)")[
```js
const toInt = (ip) => ip.split(".").reduce((a, o) => a * 256 + Number(o), 0);

// The exact test a host does before sending: same subnet -> ARP for the peer,
// different subnet -> ARP for the default gateway.
function sameSubnet(a, b, prefix) {
  const size = 2 ** (32 - prefix);
  return Math.floor(toInt(a) / size) === Math.floor(toInt(b) / size);
}

const cases = [
  ["192.168.1.10", "192.168.1.200", 24],
  ["192.168.1.10", "192.168.1.200", 25],
  ["10.1.4.9",     "10.1.5.9",      23],
  ["10.1.4.9",     "10.1.5.9",      24],
  ["172.16.31.1",  "172.16.32.1",   20],
];
for (const [a, b, p] of cases)
  console.log(`${a} and ${b} with /${p} -> ${sameSubnet(a, b, p)
    ? "SAME subnet (ARP for peer)" : "DIFFERENT subnet (send to gateway)"}`);
```
]

#code(lang: "text", caption: "output")[
```text
192.168.1.10 and 192.168.1.200 with /24 -> SAME subnet (ARP for peer)
192.168.1.10 and 192.168.1.200 with /25 -> DIFFERENT subnet (send to gateway)
10.1.4.9 and 10.1.5.9 with /23 -> SAME subnet (ARP for peer)
10.1.4.9 and 10.1.5.9 with /24 -> DIFFERENT subnet (send to gateway)
172.16.31.1 and 172.16.32.1 with /20 -> DIFFERENT subnet (send to gateway)
```
]

Look at rows 1 and 2. *The same two addresses* are neighbours under /24 and strangers under
/25. Nothing about the addresses changed. Only the mask did. That is why "wrong subnet mask"
breaks networks in ways that look like magic.

#subsection[ARP: finding the MAC]

ARP turns an IP address into a MAC address on the local link.

#table(columns: 2, align: (left, left),
  [*Step*], [*What happens*],
  [1], [Host needs the MAC for 192.168.1.1.],
  [2], [It broadcasts an ARP request to MAC ff\:ff\:ff\:ff\:ff\:ff: "who has 192.168.1.1?"],
  [3], [Every machine on the link sees it. Only the owner replies, *unicast*, with its MAC.],
  [4], [The pair is cached in the ARP table for a few minutes.],
)

#trap[
"ARP finds the MAC of the destination server." Only if the server is on your own subnet. If
it is not, ARP finds the MAC of your *default gateway*. The destination IP stays the server;
the destination MAC is the router. Mixing these up is the single most common layer-2/3
mistake.
]

#subsection[What changes at each hop]

#diagram(height: 4.6cm, caption: "one packet, four hops: the IP pair never changes, the MAC pair changes every hop")[
  #dnode(0pt,     1.2cm, 2.5cm, 1.0cm, "PC A\n10.0.1.5\nMAC aa")
  #dnode(3.4cm,   1.2cm, 2.2cm, 1.0cm, "Switch\n(layer 2)")
  #dnode(6.5cm,   1.2cm, 2.4cm, 1.0cm, "Router R1\nMAC r1")
  #dnode(9.8cm,   1.2cm, 2.4cm, 1.0cm, "Router R2\nMAC r2")
  #dnode(13.1cm,  1.2cm, 2.5cm, 1.0cm, "Server B\n203.0.113.9\nMAC bb")

  #darrow(2.5cm,  1.7cm, 3.4cm, 1.7cm)
  #darrow(5.6cm,  1.7cm, 6.5cm, 1.7cm)
  #darrow(8.9cm,  1.7cm, 9.8cm, 1.7cm)
  #darrow(12.2cm, 1.7cm, 13.1cm, 1.7cm)

  #dnode(0pt,    2.6cm, 6.5cm, 0.85cm, "hop 1 frame:  src MAC aa -> dst MAC r1\nsrc IP 10.0.1.5 -> dst IP 203.0.113.9", fill: rgb("#f3f6f8"))
  #dnode(6.9cm,  2.6cm, 4.2cm, 0.85cm, "hop 2 frame:  r1 -> r2\nIP pair unchanged", fill: rgb("#f3f6f8"))
  #dnode(11.4cm, 2.6cm, 4.2cm, 0.85cm, "hop 3 frame:  r2 -> bb\nIP pair unchanged", fill: rgb("#f3f6f8"))

  #dnode(0pt, 0pt, 15.6cm, 0.8cm, "TTL: 64 leaving A   ->   63 after R1   ->   62 after R2   (each router decrements by 1)")
]

#ex(16, tier: 2, asked: "Agoda · pattern")[
A packet goes from PC A to Server B through 2 routers, as drawn above. Say exactly which of
these change per hop and which do not: source IP, destination IP, source MAC, destination
MAC, TTL, IP header checksum. Assume no NAT.
]
#sol[
#table(columns: 3, align: (left, center, left),
  [*Field*], [*Changes?*], [*Why*],
  [Source IP], [no], [identifies the original sender end to end],
  [Destination IP], [no], [identifies the final receiver end to end],
  [Source MAC], [yes, every hop], [the sending *interface* on this link],
  [Destination MAC], [yes, every hop], [the next hop on this link],
  [TTL], [yes, $-1$ per router], [loop protection],
  [IP header checksum], [yes], [it must be recomputed because TTL changed],
)

The one-line version to say in an interview: *layer 3 addresses are end-to-end, layer 2
addresses are hop-to-hop.*

If NAT were involved, the source IP *would* change --- but only at the NAT box, not at every
router.
#ans[MACs, TTL and header checksum change per hop; the IP pair does not (unless NAT)]
]

#subsection[NAT and PAT]

NAT lets many private hosts share one public IP. What real routers do is *PAT* (Port Address
Translation), also called NAT overload: the port number is rewritten too, and the port is
what makes each flow unique.

#ex(17, tier: 1, asked: "Infosys · pattern")[
Two laptops behind one home router both open a connection to 203.0.113.9 port 443. The
router's public IP is 49.36.7.2. Show the translation table.
]
#sol[
#table(columns: 4, align: (left, left, left, left),
  [*Inside (private)*], [*Outside (public) after NAT*], [*Destination*], [*Chosen by*],
  [192.168.1.10\:51000], [49.36.7.2\:61001], [203.0.113.9\:443], [router],
  [192.168.1.11\:51000], [49.36.7.2\:61002], [203.0.113.9\:443], [router],
)

Both laptops happened to pick the same source port 51000. The router gives each a
*different* public port, so the reply "to 49.36.7.2:61002" can only mean laptop .11. The
public port number is the whole trick.

Why NAT exists: IPv4 has only $2^32 approx 4.3$ billion addresses. NAT lets one address
serve a whole household.

What NAT breaks: an outside host cannot start a connection inwards, because there is no
table entry yet. That is why peer-to-peer apps need port forwarding, UPnP or STUN/TURN
hole-punching.
#ans[same inside port, different outside port; the mapping is keyed on the port]
]

#trap[
"NAT is a firewall." It is not, but it accidentally behaves like one for *unsolicited
inbound* traffic. Say: "NAT is address conservation; the inbound blocking is a side effect,
not a security policy." Do not rely on NAT for security.
]

#subsection[DHCP: DORA]

A host with no address gets one in four messages.

#table(columns: 4, align: (center, left, left, left),
  [*\#*], [*Message*], [*From $arrow.r$ to*], [*Contents*],
  [1], [DISCOVER], [client (0.0.0.0) $arrow.r$ broadcast], [is there a DHCP server?],
  [2], [OFFER], [server $arrow.r$ client], [here is an address you may have],
  [3], [REQUEST], [client $arrow.r$ broadcast], [I accept that one (broadcast so other servers withdraw their offers)],
  [4], [ACK], [server $arrow.r$ client], [confirmed, plus mask, gateway, DNS and lease time],
)

DHCP rides on UDP, server port 67, client port 68. The client has no IP yet, so it sends
from 0.0.0.0 to 255.255.255.255.

#trap[
DHCP is a broadcast protocol and routers do not forward broadcasts. So a DHCP server in
another subnet is unreachable *unless* the router runs a *DHCP relay agent* (`ip helper-address`),
which converts the broadcast into a unicast to the server. This is a favourite follow-up.
]

#subsection[ICMP, ping and traceroute]

ICMP is the control and error protocol of layer 3. It carries no user data.

#table(columns: 3, align: (left, left, left),
  [*ICMP message*], [*When*], [*Tool that uses it*],
  [Echo request / reply], [you asked "are you alive"], [`ping`],
  [Time exceeded], [TTL hit 0 at a router], [`traceroute`],
  [Destination unreachable], [no route, or port closed], [error reporting],
  [Fragmentation needed], [packet too big, DF bit set], [path MTU discovery],
  [Redirect], [you used the wrong gateway], [route correction],
)

*How traceroute works.* Send a packet with TTL = 1. The first router decrements it to 0,
drops it, and sends back "time exceeded" --- which reveals that router's address. Then TTL =
2 to reveal the second. Keep going until the destination replies. Each row of traceroute
output is one more TTL value.

#ex(18, tier: 2, asked: "Sea/Shopee · pattern")[
`ping` to a server fails but the website loads in the browser. Give two different
explanations.
]
#sol[
*Explanation 1 --- ICMP is filtered.* Many firewalls and cloud security groups drop ICMP
echo while allowing TCP 443. Ping tests a different protocol from HTTP. "No ping" is not
"no server".

*Explanation 2 --- you are not talking to the same machine.* The browser resolves the name
through DNS, which may return a CDN or load-balancer address, while your ping used a stale
cached IP, a different DNS answer, or the origin address directly.

A third, seen in practice: ping uses the A record but the browser used IPv6 (AAAA) and the
two paths are configured differently.
#ans[ICMP blocked by policy, or the name resolves to a different address than you pinged]
]

#subsection[MTU and fragmentation]

Ethernet's standard MTU is 1500 bytes --- the biggest IP packet that fits in one frame. A
larger packet must be split.

#ex(19, tier: 2, asked: "DBS · pattern")[
A 4000-byte IP datagram (20-byte header, 3980 bytes of data) must cross a link with MTU
1500. Show every fragment with its size, its offset field and its MF flag.
]
#sol[
*Step 1 --- how much data fits per fragment.* $1500 - 20 = 1480$ bytes of payload. The
offset field counts in units of *8 bytes*, so each fragment's data (except the last) must be
a multiple of 8. $1480 \/ 8 = 185$ exactly, so 1480 is legal.

*Step 2 --- split 3980 bytes into pieces of at most 1480.*
$3980 = 1480 + 1480 + 1020$.

*Step 3 --- offsets.* Offset field = (byte position of this fragment's data) $\/ 8$.

#table(columns: 6, align: (center, right, right, right, center, left),
  [*Frag*], [*Data bytes*], [*Total size*], [*Byte range*], [*Offset field*], [*MF flag*],
  [1], [1480], [1500], [0 -- 1479],    [0],   [1 (more coming)],
  [2], [1480], [1500], [1480 -- 2959], [185], [1 (more coming)],
  [3], [1020], [1040], [2960 -- 3979], [370], [0 (last one)],
)

Check: $0 \/ 8 = 0$, $1480 \/ 8 = 185$, $2960 \/ 8 = 370$. All whole numbers, as required.
Check total: $1480+1480+1020 = 3980$. Correct.

*Step 4 --- who reassembles?* Only the *final destination*, never an intermediate router.
Every fragment carries the same Identification field so the destination can group them.
#ans[1500 / 1500 / 1040 bytes; offsets 0, 185, 370; MF = 1, 1, 0]
]
#trap[
The offset field is in 8-byte units, not bytes. Writing "offset 1480" instead of 185 is the
standard wrong answer. Also: losing *one* fragment destroys the *whole* datagram, because
IP has no per-fragment retransmission. That is why modern stacks avoid fragmentation with
Path MTU Discovery (set the DF bit, let ICMP tell you the limit) and why TCP picks an MSS
that fits.
]

#subsection[The IPv4 header]

#table(columns: 3, align: (left, center, left),
  [*Field*], [*Size*], [*Why it exists*],
  [Version], [4 bits], [4 or 6],
  [IHL], [4 bits], [header length in 4-byte words; 5 means the usual 20 bytes],
  [DSCP / ECN], [8 bits], [quality of service, congestion signalling],
  [Total length], [16 bits], [header + data, so max 65,535 bytes],
  [Identification], [16 bits], [groups fragments of one datagram],
  [Flags], [3 bits], [DF (do not fragment), MF (more fragments)],
  [Fragment offset], [13 bits], [position of this fragment, in 8-byte units],
  [TTL], [8 bits], [hop limit; prevents loops],
  [Protocol], [8 bits], [6 = TCP, 17 = UDP, 1 = ICMP],
  [Header checksum], [16 bits], [covers the *header only*, recomputed at every hop],
  [Source IP], [32 bits], [sender],
  [Destination IP], [32 bits], [receiver],
)

#code(lang: "js", caption: "the IPv4 header checksum, both directions (run with node)")[
```js
// IPv4 header checksum: 16-bit one's complement of the one's complement sum
function checksum16(words) {
  let sum = 0;
  for (const w of words) sum += w;
  while (sum > 0xffff) sum = (sum & 0xffff) + (sum >>> 16); // fold the carry back in
  return (~sum) & 0xffff;
}

// A 20-byte header with the checksum field set to 0000
const header = [0x4500, 0x003c, 0x1c46, 0x4000, 0x4006,
                0x0000, 0xac10, 0x0a63, 0xac10, 0x0a0c];

const ck = checksum16(header);
console.log("checksum =", ck.toString(16));

// Receiver side: put it back and the sum must come out 0xffff
header[5] = ck;
let s = 0;
for (const w of header) s += w;
while (s > 0xffff) s = (s & 0xffff) + (s >>> 16);
console.log("receiver sum =", s.toString(16), s === 0xffff ? "OK" : "CORRUPT");
```
]

#code(lang: "text", caption: "output")[
```text
checksum = b1e6
receiver sum = ffff OK
```
]

The receiver never has to "compare" anything. It sums *everything including the checksum*.
If the result is all ones, the header is intact. That is the whole design.

#section[Part 5 — DNS]

#subsection[The record types you must know]

#table(columns: 3, align: (left, left, left),
  [*Record*], [*Maps*], [*Example use*],
  [A], [name $arrow.r$ IPv4], [`shop.example` $arrow.r$ 203.0.113.9],
  [AAAA], [name $arrow.r$ IPv6], [`shop.example` $arrow.r$ 2001\:db8\:\:9],
  [CNAME], [name $arrow.r$ another name], [`www` $arrow.r$ `shop.example`],
  [MX], [domain $arrow.r$ mail server + priority], [mail routing],
  [NS], [zone $arrow.r$ authoritative name servers], [delegation],
  [PTR], [IP $arrow.r$ name], [reverse lookup, spam checks],
  [TXT], [name $arrow.r$ free text], [SPF, domain ownership proofs],
  [SOA], [zone $arrow.r$ its authority record], [serial number, refresh timers],
)

#subsection[A full resolution, step by step]

#diagram(height: 6.4cm, caption: "resolving shop.example.com for the first time — 8 messages, then it is cached")[
  #dnode(0.6cm, 0pt,    14.8cm, 0.68cm, "1   browser  →  recursive resolver:   “where is shop.example.com?”   (recursive query)")
  #dnode(0.6cm, 0.76cm, 14.8cm, 0.68cm, "2   resolver  →  root server (.):   “who handles .com?”", fill: rgb("#e2ecf3"))
  #dnode(0.6cm, 1.52cm, 14.8cm, 0.68cm, "3   root  →  resolver:   “I do not know the answer — ask the .com TLD servers”   (referral)")
  #dnode(0.6cm, 2.28cm, 14.8cm, 0.68cm, "4   resolver  →  .com TLD server:   “who handles example.com?”", fill: rgb("#e2ecf3"))
  #dnode(0.6cm, 3.04cm, 14.8cm, 0.68cm, "5   TLD  →  resolver:   “ask ns1.example.com”   (referral)")
  #dnode(0.6cm, 3.80cm, 14.8cm, 0.68cm, "6   resolver  →  ns1.example.com:   “what is shop.example.com?”", fill: rgb("#e2ecf3"))
  #dnode(0.6cm, 4.56cm, 14.8cm, 0.68cm, "7   authoritative  →  resolver:   “A = 203.0.113.9”   (the real answer, carries a TTL)")
  #dnode(0.6cm, 5.32cm, 14.8cm, 0.68cm, "8   resolver  →  browser:   203.0.113.9   —  and the resolver caches it until the TTL expires")
  #darrow(0.2cm, 0.2cm, 0.2cm, 5.7cm)
]

#table(columns: 2, align: (left, left),
  [*Recursive query*], [client asks the resolver: "give me the final answer, do the work"],
  [*Iterative query*], [resolver asks a server: "answer, or tell me who to ask next"],
)

*Order of caches consulted before any of this happens:* browser cache $arrow.r$ OS cache
$arrow.r$ `hosts` file $arrow.r$ recursive resolver cache $arrow.r$ the walk above.

#ex(20, tier: 2, asked: "Grab · pattern")[
A team lowers a record's TTL from 3600 to 60 one day before moving a service to a new IP.
Explain why, and name the cost.
]
#sol[
*Why.* A cached record is used until its TTL expires. With TTL 3600 (1 hour), resolvers all
over the world may keep sending users to the *old* IP for up to an hour after the change.
Dropping the TTL to 60 first means that within a few minutes of the switch every cache has
re-queried.

The pre-change lowering must happen at least one *old* TTL before the move, so that the
long-TTL copies expire and get replaced with short-TTL copies.

*The cost.* Ten times more DNS queries per hour hitting the authoritative servers, higher
lookup latency for users on a cache miss, and a bigger blast radius if the authoritative
server is slow or down. So you lower TTL before the change and raise it again after the
change is confirmed.
#ans[short TTL = fast cutover; cost is query volume, latency and reduced cache protection]
]

#trap[
"DNS uses UDP." Mostly, but not only. DNS uses UDP port 53 for normal queries because one
packet each way is cheapest. It switches to *TCP* port 53 when the response is too large
(the truncated bit is set) and for *zone transfers*. Modern deployments also use DNS over
TLS (853) and DNS over HTTPS (443).
]

#section[Part 6 — Routing]

#subsection[What a routing table is]

A routing table is a list of `prefix -> next hop`. For each packet the router finds every
row whose prefix contains the destination, and uses the row with the *longest* prefix.

#ex(21, tier: 1, asked: "TCS NQT · pattern")[
Given this table, where does each destination go?

#table(columns: 2, align: (left, left),
  [*Prefix*], [*Next hop*],
  [0.0.0.0/0], [R1 (default)],
  [10.0.0.0/8], [R2],
  [10.20.0.0/16], [R3],
  [10.20.30.0/24], [R4],
  [10.20.30.128/25], [R5],
  [192.168.0.0/16], [R6],
)

Destinations: 10.20.30.200, 10.20.30.10, 10.20.99.4, 10.5.5.5, 192.168.7.7, 8.8.8.8
]
#sol[
Work one destination at a time. List every row that matches, then keep the longest prefix.

*10.20.30.200.* Matches /0, /8, /16, /24 and /25 (because .200 $>=$ .128). Longest = /25
$arrow.r$ *R5*.

*10.20.30.10.* Matches /0, /8, /16, /24. Does *not* match /25 --- the /25 block starts at
.128 and .10 is below it. Longest = /24 $arrow.r$ *R4*.

*10.20.99.4.* Matches /0, /8, /16. Not /24 (third octet is 99, not 30). Longest = /16
$arrow.r$ *R3*.

*10.5.5.5.* Matches /0 and /8 only. $arrow.r$ *R2*.

*192.168.7.7.* Matches /0 and 192.168.0.0/16. $arrow.r$ *R6*.

*8.8.8.8.* Matches only the default. $arrow.r$ *R1*.

#table(columns: 3, align: (left, left, left),
  [*Destination*], [*Winning route*], [*Next hop*],
  [10.20.30.200], [10.20.30.128/25], [R5],
  [10.20.30.10],  [10.20.30.0/24],   [R4],
  [10.20.99.4],   [10.20.0.0/16],    [R3],
  [10.5.5.5],     [10.0.0.0/8],      [R2],
  [192.168.7.7],  [192.168.0.0/16],  [R6],
  [8.8.8.8],      [0.0.0.0/0],       [R1],
)
#ans[R5, R4, R3, R2, R6, R1]
]

#code(lang: "js", caption: "longest prefix match in 20 lines (run with node)")[
```js
const toInt = (ip) => ip.split(".").reduce((a, o) => a * 256 + Number(o), 0);

const table = [
  { cidr: "0.0.0.0/0",       via: "R1 (default)" },
  { cidr: "10.0.0.0/8",      via: "R2" },
  { cidr: "10.20.0.0/16",    via: "R3" },
  { cidr: "10.20.30.0/24",   via: "R4" },
  { cidr: "10.20.30.128/25", via: "R5" },
  { cidr: "192.168.0.0/16",  via: "R6" },
];

function lookup(dest) {
  const d = toInt(dest);
  let best = null;
  for (const row of table) {
    const [net, pStr] = row.cidr.split("/");
    const p = Number(pStr);
    const size = 2 ** (32 - p);
    if (Math.floor(d / size) * size === toInt(net)) {   // dest is inside the block
      if (best === null || p > best.p) best = { p, ...row };
    }
  }
  return best;
}

for (const d of ["10.20.30.200", "10.20.30.10", "10.20.99.4",
                 "10.5.5.5", "192.168.7.7", "8.8.8.8"]) {
  const r = lookup(d);
  console.log(d.padEnd(14), "->", r.cidr.padEnd(16), "via", r.via);
}
```
]

#code(lang: "text", caption: "output — matches the hand-worked table above")[
```text
10.20.30.200   -> 10.20.30.128/25  via R5
10.20.30.10    -> 10.20.30.0/24    via R4
10.20.99.4     -> 10.20.0.0/16     via R3
10.5.5.5       -> 10.0.0.0/8       via R2
192.168.7.7    -> 192.168.0.0/16   via R6
8.8.8.8        -> 0.0.0.0/0        via R1 (default)
```
]

#note[
Real routers do not loop over rows; they use a *trie* (a prefix tree) or TCAM hardware so a
lookup is $O("prefix length")$ regardless of table size. The internet's default-free routing
table is close to a million prefixes.
]

#subsection[Distance vector vs link state]

#table(columns: 3, align: (left, left, left),
  [], [*Distance vector*], [*Link state*],
  [Idea], [tell your neighbours your whole table], [tell everyone about your own links],
  [What each router knows], [distance and direction only], [the full map],
  [Algorithm], [Bellman--Ford], [Dijkstra],
  [Examples], [RIP, EIGRP (hybrid)], [OSPF, IS-IS],
  [Convergence], [slow; loops possible], [fast; loop-free once flooded],
  [Memory / CPU], [small], [larger],
  [Classic failure], [count to infinity], [flooding cost in big areas, fixed by splitting into areas],
)

#ex(22, tier: 2, asked: "Razer · pattern")[
Four routers in a line: A--B--C--D, every link cost 1. Each router starts knowing only its
direct neighbours. Show the distance tables after each exchange round until convergence.
]
#sol[
Write $infinity$ as 99. At the start each router knows itself (0) and its direct links (1).

*Round 0 (start)*
#table(columns: 5, align: (left, right, right, right, right),
  [], [*to A*], [*to B*], [*to C*], [*to D*],
  [A], [0], [1], [99], [99],
  [B], [1], [0], [1], [99],
  [C], [99], [1], [0], [1],
  [D], [99], [99], [1], [0],
)

*Round 1.* Every router takes $min("own", "cost to neighbour" + "neighbour's distance")$.
A learns C through B: $1 + 1 = 2$. D learns B through C: $1 + 1 = 2$.
#table(columns: 5, align: (left, right, right, right, right),
  [], [*to A*], [*to B*], [*to C*], [*to D*],
  [A], [0], [1], [*2*], [99],
  [B], [1], [0], [1], [*2*],
  [C], [*2*], [1], [0], [1],
  [D], [99], [*2*], [1], [0],
)

*Round 2.* A learns D through B: B now says 2, so A gets $1+2 = 3$. D learns A the same way.
#table(columns: 5, align: (left, right, right, right, right),
  [], [*to A*], [*to B*], [*to C*], [*to D*],
  [A], [0], [1], [2], [*3*],
  [B], [1], [0], [1], [2],
  [C], [2], [1], [0], [1],
  [D], [*3*], [2], [1], [0],
)

*Round 3.* Nothing changes. Converged.

The pattern: a distance-vector network with a diameter of $n$ hops needs about $n$ rounds.
That is why RIP, which exchanges every 30 seconds, can take minutes to settle.
#ans[3 rounds; final distances A--D = 3]
]

#subsection[Count to infinity, and the fixes]

If link C--D breaks, C sets its distance to D as $infinity$. But B still advertises "I can
reach D at cost 2". C believes it, and now thinks D is at cost 3 *through B* --- even though
B's path went through C. The two routers bounce the number upwards, one step per round,
forever. RIP caps this by defining 16 as infinity, so the nonsense stops after a few rounds.

#table(columns: 2, align: (left, left),
  [*Fix*], [*What it does*],
  [Split horizon], [never advertise a route back out of the interface you learned it on],
  [Poison reverse], [advertise it back with cost $infinity$, which is louder than silence],
  [Hold-down timer], [after hearing a route died, ignore better news about it for a while],
  [Triggered updates], [send the bad news immediately instead of waiting 30 seconds],
  [Max hop count 15], [RIP's definition of infinity, so the loop is bounded],
)

#subsection[Link state: Dijkstra by hand]

#diagram(height: 4.4cm, caption: "a 5-router area; the number on each link is its OSPF cost")[
  #dnode(0.5cm,  1.6cm, 1.5cm, 0.8cm, "A")
  #dnode(4.5cm,  0.2cm, 1.5cm, 0.8cm, "B")
  #dnode(4.5cm,  3.0cm, 1.5cm, 0.8cm, "C")
  #dnode(8.5cm,  1.6cm, 1.5cm, 0.8cm, "D")
  #dnode(12.5cm, 2.6cm, 1.5cm, 0.8cm, "E")

  #darrow(2.0cm, 1.8cm, 4.5cm, 0.7cm, label: "2")
  #darrow(2.0cm, 2.2cm, 4.5cm, 3.3cm, label: "5")
  #darrow(5.2cm, 1.0cm, 5.2cm, 3.0cm, label: "2")
  #darrow(6.0cm, 0.7cm, 8.5cm, 1.8cm, label: "4")
  #darrow(6.0cm, 3.3cm, 8.5cm, 2.2cm, label: "1")
  #darrow(6.0cm, 3.5cm, 12.5cm, 3.1cm, label: "6")
  #darrow(10.0cm, 2.1cm, 12.5cm, 2.8cm, label: "2")
]

#ex(23, tier: 2, asked: "GIC · pattern")[
Using the costs drawn above, run Dijkstra from A. Give the shortest cost and path to every
router, and the resulting forwarding table at A.
]
#sol[
Links: A--B 2, A--C 5, B--C 2, B--D 4, C--D 1, C--E 6, D--E 2.

Keep a table of "best known cost" and settle one router per step, always the cheapest
unsettled one.

*Start.* A = 0. Others $infinity$.

*Step 1 --- settle A (0).* Relax A's links: B $= 2$ (via A), C $= 5$ (via A).
Best known: B 2, C 5, D $infinity$, E $infinity$.

*Step 2 --- cheapest unsettled is B (2). Settle B.* Relax B's links:
C: $2 + 2 = 4 < 5$, so C improves to *4 via B*.
D: $2 + 4 = 6$, so D becomes 6 via B.
Best known: C 4, D 6, E $infinity$.

*Step 3 --- cheapest unsettled is C (4). Settle C.* Relax C's links:
D: $4 + 1 = 5 < 6$, so D improves to *5 via C*.
E: $4 + 6 = 10$, so E becomes 10 via C.
Best known: D 5, E 10.

*Step 4 --- cheapest unsettled is D (5). Settle D.* Relax D's links:
E: $5 + 2 = 7 < 10$, so E improves to *7 via D*.

*Step 5 --- settle E (7).* Done.

#table(columns: 4, align: (left, right, left, left),
  [*Destination*], [*Cost*], [*Path*], [*First hop from A*],
  [B], [2], [A -- B],               [B],
  [C], [4], [A -- B -- C],          [B],
  [D], [5], [A -- B -- C -- D],     [B],
  [E], [7], [A -- B -- C -- D -- E], [B],
)

*Forwarding table at A:* every destination goes out of the interface towards *B*. The direct
A--C link at cost 5 is never used, because going the long way round through B costs only 4.
#ans[B 2, C 4, D 5, E 7 --- all via B]
]
#trick[
In Dijkstra you never revisit a settled node. The moment a node is settled its cost is
final, because all link costs are non-negative and you always settle the cheapest remaining.
If an interviewer asks "what if a link had negative cost", the answer is: Dijkstra breaks,
use Bellman--Ford.
]

#subsection[The three routing protocols by name]

#table(columns: 5, align: (left, left, left, left, left),
  [*Protocol*], [*Type*], [*Metric*], [*Scope*], [*Notes*],
  [RIP], [distance vector], [hop count, max 15], [inside one organisation (IGP)], [simple, slow, obsolete],
  [OSPF], [link state], [cost, from bandwidth], [IGP, split into areas], [fast, standard in enterprises],
  [IS-IS], [link state], [cost], [IGP], [common inside ISPs],
  [BGP], [path vector], [AS path + policy], [between organisations (EGP)], [runs the internet],
)

#ex(24, tier: 3, asked: "Google · pattern")[
Why does the internet use BGP between networks instead of just running OSPF everywhere?
]
#sol[
*Reason 1 --- scale.* OSPF floods the full link-state map and every router runs Dijkstra
over it. With a million prefixes and hundreds of thousands of networks, that map cannot be
flooded or recomputed. BGP advertises reachability, not topology.

*Reason 2 --- policy, not shortest path.* Between companies the best route is a *business*
decision. A transit provider costs money; a peering link is free; a customer's traffic is
revenue. OSPF has only one notion of "best" (lowest cost) and no way to express "never send
my customer's traffic through my competitor". BGP attributes (local preference, AS path
length, MED, communities) exist to encode exactly those rules.

*Reason 3 --- trust boundaries.* OSPF assumes every router in the area is honest and shares
a full map. Different companies are not in the same trust domain. BGP deliberately hides
internal topology: a network advertises only what it wants others to see.

*Reason 4 --- loop prevention across administrations.* BGP carries the full AS path. A
router that sees its own AS number in a path drops the advertisement. This works without any
shared map at all.

*The trade-off to name.* BGP converges slowly and trusts what it is told, which is why route
leaks and hijacks happen; RPKI and route filtering are the mitigations.
#ans[scale, policy expressiveness, trust boundaries, and AS-path loop detection]
]

#section[Part 7 — IPv6 in one page]

#table(columns: 3, align: (left, left, left),
  [], [*IPv4*], [*IPv6*],
  [Size], [32 bits], [128 bits],
  [Total addresses], [$approx 4.3 times 10^9$], [$approx 3.4 times 10^38$],
  [Written as], [dotted decimal], [8 groups of 4 hex digits, colon separated],
  [Header], [variable, 20+ bytes, has a checksum], [fixed 40 bytes, *no* checksum],
  [Fragmentation], [routers may fragment], [only the *sender* may; routers never do],
  [Address resolution], [ARP (broadcast)], [NDP (multicast)],
  [Broadcast], [yes], [*none* --- multicast and anycast only],
  [Auto-configuration], [DHCP], [SLAAC, or DHCPv6],
  [NAT], [everywhere], [rarely needed],
)

*Compression rules.* Drop leading zeros in each group. Replace *one* run of all-zero groups
with `::`.

#ex(25, tier: 1, asked: "Capgemini · pattern")[
Compress `2001:0db8:0000:0000:0000:ff00:0042:8329`. Then expand `fe80::1`.
]
#sol[
*Compressing.*
Step 1 --- drop leading zeros in each group:
`2001:db8:0:0:0:ff00:42:8329`.
Step 2 --- replace the longest run of zero groups (three of them) with `::`:
*`2001:db8::ff00:42:8329`*.

*Expanding `fe80::1`.* There are 8 groups in total. We are given `fe80` and `1`, so the
`::` stands for $8 - 2 = 6$ zero groups:
*`fe80:0000:0000:0000:0000:0000:0000:0001`*.
#ans[`2001:db8::ff00:42:8329` and `fe80:0000:0000:0000:0000:0000:0000:0001`]
]
#trap[
`::` may appear *only once* in an address. `2001::25de::cade` is invalid, because you could
not tell how many zero groups belong to each `::`.
]

#section[Practice]

#practice(tier: 1, time: "18 minutes")[
1. Convert 10.1.130.7 and 255.255.255.240 to binary.
2. For 192.168.20.130/26: network, broadcast, first host, last host, usable count.
3. How many /30 subnets are inside a /24? How many usable hosts in each?
4. Give the class and the private/public verdict for 172.20.0.5, 172.40.0.5, 192.169.1.1.
5. You need 4 subnets of at least 50 hosts each from 172.16.9.0/24. Give the prefix and the
   four network addresses.
6. A 2000-byte datagram (20-byte header) crosses an MTU-576 link. How many fragments?
7. Which is the broadcast address of 10.8.0.0/13?
8. A host is 192.168.4.100/22. Is 192.168.7.250 on the same subnet?
]

#key[
1. 10.1.130.7 = 00001010.00000001.10000010.00000111.
   255.255.255.240 = 11111111.11111111.11111111.11110000.
   (130 = 128+2; 240 = 128+64+32+16.)
2. /26 block 64. Multiples: 0, 64, *128*, 192. Network *192.168.20.128*,
   broadcast *192.168.20.191*, hosts *.129 -- .190*, usable *62*.
3. $2^(30-24) = 64$ subnets, each $2^2 - 2 = 2$ usable hosts.
4. 172.20.0.5 class B *private* (16--31). 172.40.0.5 class B *public*.
   192.169.1.1 class C *public* --- only 192.168 is private.
5. $2^h - 2 >= 50 arrow.r h = 6 arrow.r$ #strong[/26] (62 hosts), and $2^2 = 4$ subnets. Networks:
   172.16.9.0, 172.16.9.64, 172.16.9.128, 172.16.9.192.
6. Data = 1980. Payload per fragment = $(576-20) = 556$, rounded down to a multiple of 8 =
   *552*. $1980 = 552 + 552 + 552 + 324$ $arrow.r$ *4 fragments*. Offsets 0, 69, 138, 207.
7. /13 $arrow.r$ block size in octet 2 is $256-248 = 8$. Block starting at 8 covers 8--15.
   Broadcast = *10.15.255.255*.
8. /22 block size in octet 3 is 4. 100 is in octet 4, so look at octet 3: multiples of 4 are
   0, *4*, 8. The host's block is 192.168.4.0 -- 192.168.7.255. 192.168.7.250 is inside.
   *Yes, same subnet.*
]

#practice(tier: 2, time: "22 minutes")[
1. Aggregate 10.6.8.0/24, 10.6.9.0/24, 10.6.10.0/24, 10.6.11.0/24 into one prefix. Prove it
   covers nothing extra.
2. VLSM 172.16.40.0/24 for 100, 50, 20, 10 and 2 hosts. Show the layout and the leftover.
3. A routing table has 0.0.0.0/0 via R1, 172.16.0.0/16 via R2, 172.16.40.0/21 via R3 and
   172.16.40.0/24 via R4. Where do 172.16.40.9, 172.16.44.9 and 172.16.90.9 go?
4. Five routers in a ring, all link costs 1: A--B--C--D--E--A. Run Dijkstra from A.
5. Two offices both use 192.168.1.0/24 and you must join them with a VPN. Name the problem
   and two fixes.
]

#key[
1. Third octet 8, 9, 10, 11 = 000010#strong[00], 000010#strong[01], 000010#strong[10], 000010#strong[11]. Six bits match
   $arrow.r$ $16 + 6 = 22$. Aggregate *10.6.8.0/22*. Its block size in octet 3 is 4, so it
   spans 8, 9, 10, 11 and stops. No extra space is claimed.
2. 100 $arrow.r$ /25 (126), 50 $arrow.r$ /26 (62), 20 $arrow.r$ /27 (30), 10 $arrow.r$ /28
   (14), 2 $arrow.r$ /30 (2). Biggest first:
   .0/25 (0--127), .128/26 (128--191), .192/27 (192--223), .224/28 (224--239),
   .240/30 (240--243). Leftover: .244 -- .255 = 12 addresses.
3. 172.16.40.9 matches /0, /16, /21 and /24 $arrow.r$ longest is /24 $arrow.r$ *R4*.
   172.16.44.9: the /21 starting at 40 covers 40--47, so it matches /0, /16, /21, not the
   /24 $arrow.r$ *R3*. 172.16.90.9 matches /0 and /16 only $arrow.r$ *R2*.
4. Ring of 5. From A: B = 1 (direct), E = 1 (direct), C = 2 (A--B--C), D = 2 (A--E--D).
   Every node is at most 2 hops away. Forwarding: B and C via B; D and E via E.
5. *Problem:* overlapping address space. A host at 192.168.1.10 in office 1 cannot tell
   whether 192.168.1.20 means its own neighbour or the remote office --- the same-subnet
   test picks local every time, so remote traffic never reaches the tunnel.
   *Fix 1:* renumber one office (for example to 192.168.20.0/24). Cleanest, most disruptive.
   *Fix 2:* NAT the tunnel --- each side translates the other's range to a spare block
   (office 2 appears as 10.99.1.0/24 to office 1). No renumbering, but harder to debug and
   it breaks protocols that embed IP addresses in their payload.
]

#practice(tier: 3, time: "25 minutes")[
1. Design addressing for a 4-region service: each region needs 2 subnets of 500 hosts and 4
   subnets of 60 hosts, out of 10.80.0.0/16, with one summarisable route per region. State
   the waste.
2. A router has both a /24 static route and a /24 learned by OSPF for the same prefix, with
   different next hops. Which wins, and what mechanism decides?
3. Explain why lowering a DNS TTL does not guarantee a fast cutover. Name two things outside
   your control.
4. Traceroute shows `* * *` for hops 4 to 7 and then normal output at hop 8. Is the path
   broken? Explain.
]

#key[
1. Per region: 500 hosts $arrow.r$ /23 (510), two of them = 2 $times$ 512 = 1024. 60 hosts
   $arrow.r$ /26 (62), four of them = 4 $times$ 64 = 256. Total needed 1280, so the region
   block rounds up to *2048 = /21*.
   Regions: 10.80.0.0/21, 10.80.8.0/21, 10.80.16.0/21, 10.80.24.0/21.
   Inside region 1: /23s at 10.80.0.0 and 10.80.2.0; /26s at 10.80.4.0, .4.64, .4.128,
   .4.192. Waste per region $= 2048 - 1280 = 768$ addresses; total waste 3072, which is
   4.7% of the /16. Bought: 4 routes instead of 24.
2. The *static* route wins. The mechanism is *administrative distance* --- a
   trustworthiness ranking applied before the metric is even looked at. Typical values:
   connected 0, static 1, OSPF 110, RIP 120. Only if two routes have the same
   administrative distance does the protocol's own metric decide. And prefix length still
   beats both: a /25 from RIP beats a /24 static, because longest prefix match happens
   first.
3. Lowering the TTL only controls what *well-behaved* caches do from the moment they fetch
   the new record. Outside your control: (a) resolvers that ignore or floor the TTL --- some
   ISP resolvers pin a minimum of several minutes to cut their own load; (b) application and
   OS caching --- a JVM with the wrong `networkaddress.cache.ttl` can cache a DNS answer for
   the life of the process, and long-lived HTTP connection pools keep using the *old* socket
   even after DNS changes. That last one is why cutovers are done at the load balancer, not
   in DNS, whenever it is possible.
4. Not necessarily broken --- the final hop answered, so packets are getting through. Those
   routers are simply *not replying with ICMP time-exceeded*, or their replies are being
   rate-limited or filtered. ICMP generation is a low-priority, often disabled, control-plane
   task. Traceroute measures the willingness of routers to answer, not the health of the
   forwarding path. If hop 8 onwards is fine, the path is fine.
]

#section[Rapid fire — one-line answers]

#table(columns: 2, align: (left, left),
  [*Question*], [*Answer*],
  [Layer of a switch?], [2 (data link) --- forwards on MAC],
  [Layer of a router?], [3 (network) --- forwards on IP],
  [PDU at layers 4, 3, 2, 1?], [segment, packet, frame, bit],
  [ARP maps what to what?], [IP $arrow.r$ MAC on the local link; request broadcast, reply unicast],
  [What is 169.254.x.x?], [APIPA --- DHCP failed, self-assigned link-local],
  [DHCP's four messages and ports?], [Discover, Offer, Request, Ack; UDP 67 server, 68 client],
  [The three private ranges?], [10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16],
  [Loopback range?], [127.0.0.0/8, usually 127.0.0.1],
  [Usable hosts in a /29?], [6],
  [Mask for /27?], [255.255.255.224],
  [Block size of /26?], [64 addresses],
  [Why subtract 2 for usable hosts?], [the network address and the broadcast address are reserved],
  [When is a /31 used?], [point-to-point router links, where 2 reserved addresses are wasteful],
  [Wildcard mask of /24?], [0.0.0.255],
  [Does the source IP change per hop?], [no (unless NAT); both MAC addresses change every hop],
  [What decrements TTL, and what happens at 0?], [every forwarding router; the packet is dropped and ICMP time-exceeded is sent],
  [Who reassembles IP fragments?], [only the final destination, never a router],
  [Fragment offset unit?], [8 bytes],
  [Default Ethernet MTU, and IPv4 header size?], [1500 bytes; 20 bytes minimum],
  [Protocol number for TCP / UDP / ICMP?], [6 / 17 / 1],
  [IPv4 checksum covers what?], [the header only, and it is recomputed at every hop],
  [NAT solves what, and how does PAT differ?], [IPv4 address exhaustion; PAT also rewrites the port],
  [DNS default transport and port?], [UDP 53; TCP 53 for big answers and zone transfers],
  [A vs AAAA vs CNAME?], [IPv4 address, IPv6 address, alias to another name],
  [Recursive vs iterative query?], ["get me the answer" vs "answer or refer me to the next server"],
  [What is longest prefix match?], [the most specific matching route wins],
  [What is 0.0.0.0/0?], [the default route --- matches everything, always the last resort],
  [RIP vs OSPF vs BGP?], [distance vector / link state with Dijkstra / path vector by policy],
  [Administrative distance decides what?], [which *protocol* to believe when two offer the same prefix],
  [IPv6 length, and does it broadcast?], [128 bits; no broadcast --- multicast and anycast only],
)

#revision[
*The stack.* Physical 1, Data link 2 (frame, MAC, switch), Network 3 (packet, IP, router),
Transport 4 (segment, port), Session 5, Presentation 6, Application 7.
TCP/IP squashes this to Application / Transport / Internet / Network-access.

*Subnet drill.*
1. Interesting octet from the prefix (/25--/32 $arrow.r$ octet 4, /17--/24 $arrow.r$ octet 3).
2. Block size $= 256 -$ mask value in that octet.
3. Network = round that octet down to a multiple of the block size; zero the rest.
4. Broadcast = network + block $- 1$ in that octet, 255 after it.
5. Hosts $= 2^(32-p) - 2$. Subnets from borrowing $b$ bits $= 2^b$.

*Mask values to memorise.* 128 192 224 240 248 252 254 255.
*Block sizes.* 128 64 32 16 8 4 2 1.

*Reserved.* 10/8, 172.16/12, 192.168/16 private. 127/8 loopback. 169.254/16 APIPA.
224/4 multicast.

*VLSM.* Biggest block first. Each block must start on a multiple of its own size.
*Aggregation.* Count the matching leading bits; that count is the new prefix.

*Per hop.* Source and destination IP stay. Source and destination MAC change. TTL $-1$.
Header checksum recomputed.

*ARP* finds the MAC of the peer if it is on your subnet, otherwise the MAC of the gateway.

*Fragmentation.* Payload per fragment is a multiple of 8. Offset counts in 8-byte units.
Only the destination reassembles.

*DNS.* Browser cache $arrow.r$ OS cache $arrow.r$ hosts file $arrow.r$ recursive resolver
$arrow.r$ root $arrow.r$ TLD $arrow.r$ authoritative. TTL controls how long an answer is
reused.

*Routing.* Longest prefix match, then administrative distance, then metric.
RIP = distance vector, Bellman--Ford, hop count, max 15.
OSPF = link state, Dijkstra, cost, areas.
BGP = path vector, policy, between organisations.

*The two sentences that answer half the follow-ups.*
"Layer 3 addressing is end-to-end; layer 2 addressing is hop-to-hop."
"A mask does not change the address --- it changes who counts as a neighbour."
]

]
