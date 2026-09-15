#import "../../shared/lib/style.typ": *

#chapter(num: 10, title: "Networks: TCP, UDP & HTTP",
  tagline: "Handshakes, windows, status codes — and the arithmetic behind all three")[

#section[What this round actually asks]

Chapter 9 got the packet to the right machine. This chapter is about what happens *inside*
that machine, and what the two programs at the ends say to each other.

#table(columns: 3, align: (left, left, left),
  [*Asked as*], [*Looks like*], [*What is really being tested*],
  [Definition], ["difference between TCP and UDP"], [can you list guarantees, not adjectives],
  [Sequence], ["explain the 3-way handshake"], [can you say the seq and ack numbers],
  [Arithmetic], ["window 64 KB, RTT 40 ms, how fast?"], [do you know throughput is window / RTT],
  [Debugging], ["why is the connection stuck in `TIME_WAIT`?"], [do you know the state machine],
  [Web], ["difference between 301 and 302"], [do you know what a client *caches*],
  [Depth], ["why is HTTP/3 on UDP?"], [head-of-line blocking, and where it lives],
)

#formulas(title: "Everything this chapter is built on")[

*TCP vs UDP, as guarantees.*
#table(columns: 3, align: (left, center, center),
  [*Guarantee*], [*TCP*], [*UDP*],
  [Connection set up before data], [yes (3-way handshake)], [no],
  [Every byte arrives], [yes (ACK + retransmit)], [no],
  [Arrives in order], [yes], [no],
  [No duplicates], [yes], [no],
  [Flow control (do not drown the receiver)], [yes], [no],
  [Congestion control (do not drown the network)], [yes], [no],
  [Message boundaries kept], [*no* --- it is a byte stream], [*yes* --- one datagram, one read],
  [Header size], [20 bytes minimum], [8 bytes, fixed],
)

*Connections are named by a 4-tuple.*
$ ("source IP", "source port", "destination IP", "destination port") $
Two connections differing in any one of the four are different connections.

*Throughput and the pipe.*
$ "bandwidth-delay product (bytes)" = ("link rate in bits/s" times "RTT in s") / 8 $
$ "throughput" approx "window size in bytes" / "RTT" $
$ "utilisation with a window of" N "frames" = min(1, (N times T_t) / (T_t + "RTT")) $
$ "window needed for 100%" = 1 + "RTT" / T_t $

*Congestion control (TCP Reno).*
- Slow start: `cwnd` *doubles* every RTT, until `cwnd` reaches `ssthresh`.
- Congestion avoidance: `cwnd` grows by *1* every RTT.
- 3 duplicate ACKs (mild loss): `ssthresh = cwnd/2`, `cwnd = ssthresh`. Keep going.
- Timeout (severe loss): `ssthresh = cwnd/2`, `cwnd = 1`. Back to slow start.
- Sender may send $min("cwnd", "receiver window")$ unacknowledged bytes.

*Retransmission timer (RFC 6298).* With $alpha = 1\/8$ and $beta = 1\/4$:
$ "RTTVAR" = (1-beta) times "RTTVAR" + beta times |"SRTT" - "sample"| $
$ "SRTT" = (1-alpha) times "SRTT" + alpha times "sample" $
$ "RTO" = "SRTT" + 4 times "RTTVAR" $

*HTTP status classes.* 1xx informational, 2xx success, 3xx redirect,
4xx *client* made a mistake, 5xx *server* broke.
]

#section[Part 1 — Ports, sockets and the 4-tuple]

An IP address finds the machine. A *port* finds the program on it.

#table(columns: 3, align: (right, left, left),
  [*Port*], [*Service*], [*Transport*],
  [20, 21], [FTP data, FTP control], [TCP],
  [22], [SSH], [TCP],
  [25], [SMTP (mail sending)], [TCP],
  [53], [DNS], [UDP, and TCP for big answers],
  [67, 68], [DHCP server, DHCP client], [UDP],
  [80], [HTTP], [TCP],
  [110], [POP3], [TCP],
  [143], [IMAP], [TCP],
  [443], [HTTPS, and HTTP/3 over QUIC], [TCP, and UDP for QUIC],
  [3306], [MySQL], [TCP],
  [5432], [PostgreSQL], [TCP],
  [6379], [Redis], [TCP],
)

#table(columns: 2, align: (left, left),
  [*0 -- 1023*], [well-known ports; on Unix only root may bind them],
  [*1024 -- 49151*], [registered ports (databases, application servers)],
  [*49152 -- 65535*], [ephemeral ports; the OS hands these to *client* sockets],
)

#tier-header(0)

#ex(1, tier: 0, asked: "warm-up")[
A server listens on port 443. Two browsers on the same laptop both connect to it. How does
the server tell the two connections apart?
]
#sol[
By the *4-tuple*. Both connections share three of the four values:

#table(columns: 5, align: (left, left, right, left, right),
  [*Connection*], [*Src IP*], [*Src port*], [*Dst IP*], [*Dst port*],
  [browser 1], [10.0.0.5], [52001], [203.0.113.9], [443],
  [browser 2], [10.0.0.5], [52002], [203.0.113.9], [443],
)

The OS gave each browser a different *ephemeral source port*. That one number makes the
tuples different, so the two connections are different sockets.
#ans[the source port differs, so the 4-tuples differ]
]

#trap[
"A server can handle only 65,535 connections because there are 65,535 ports." Wrong. The
server uses *one* port (443) for all of them. The limit is on the *number of distinct
4-tuples*, and the client's source port is what varies. A single server port can hold
millions of connections; the real limits are file descriptors and memory.
]

#section[Part 2 — UDP: the honest minimum]

The UDP header is 8 bytes. That is the entire protocol.

#table(columns: 3, align: (left, center, left),
  [*Field*], [*Size*], [*Purpose*],
  [Source port], [16 bits], [where to send the reply (may be 0 = no reply wanted)],
  [Destination port], [16 bits], [which program gets it],
  [Length], [16 bits], [header + data],
  [Checksum], [16 bits], [optional in IPv4, mandatory in IPv6],
)

#code(lang: "js", caption: "UDP keeps message boundaries (run with node)")[
```js
const dgram = require("dgram");

// UDP keeps message boundaries: 3 sends -> 3 receives, each whole.
const server = dgram.createSocket("udp4");
let seen = 0;
server.on("message", (msg, rinfo) => {
  console.log(`datagram ${++seen}: ${JSON.stringify(msg.toString())} ` +
              `(${msg.length} bytes) from port ${rinfo.port}`);
  if (seen === 3) { server.close(); client.close(); }
});

const client = dgram.createSocket("udp4");
server.bind(0, "127.0.0.1", () => {
  const port = server.address().port;
  for (const m of ["PING", "PONG", "DONE"]) client.send(m, port, "127.0.0.1");
});
```
]

#code(lang: "text", caption: "output — three sends, three separate reads")[
```text
datagram 1: "PING" (4 bytes) from port 44580
datagram 2: "PONG" (4 bytes) from port 44580
datagram 3: "DONE" (4 bytes) from port 44580
```
]

Hold on to that output. The very next section shows TCP doing the opposite.

#ex(2, tier: 0, asked: "warm-up")[
TCP or UDP, and one reason each: (a) downloading a PDF (b) a live video call (c) a DNS
lookup (d) sending an email (e) position updates in a shooting game.
]
#sol[
#table(columns: 3, align: (left, center, left),
  [*Task*], [*Choice*], [*Reason*],
  [Downloading a PDF], [TCP], [one missing byte ruins the file --- you need every byte, in order],
  [Live video call], [UDP], [a packet that arrives late is useless; skipping it looks better than freezing],
  [DNS lookup], [UDP], [one small question, one small answer --- a handshake costs more than a retry],
  [Sending an email], [TCP], [SMTP must deliver the message exactly, once],
  [Game position updates], [UDP], [the next update replaces the lost one within milliseconds],
)
#ans[TCP, UDP, UDP, TCP, UDP]
]

#table(columns: 2, align: (left, left),
  [*Use UDP when*], [*Because*],
  [DNS query], [one small question, one small answer; retry is cheaper than a handshake],
  [Voice and video calls], [a late packet is useless; better to skip it than wait],
  [Online game state], [the next update replaces the lost one anyway],
  [DHCP], [the client has no IP yet, so it cannot complete a handshake],
  [QUIC / HTTP/3], [the app wants to build its *own* reliability, better than TCP's],
)

#trap[
"UDP is faster than TCP." Sloppy. On an idle, lossless link they push bits at the same
speed. UDP feels faster because it skips the handshake, never waits for a retransmission,
and never backs off for congestion. On a congested link an unthrottled UDP flood can be
*slower overall*, because it makes the loss worse. Say "UDP has lower latency and no
delivery guarantee", not "UDP is faster".
]

#section[Part 3 — TCP is a byte stream]

#subsection[The thing students get wrong first]

#code(lang: "js", caption: "three writes, one read (run with node)")[
```js
const net = require("net");

// TCP is a BYTE STREAM. Three writes may arrive as one chunk, or split oddly.
const server = net.createServer((sock) => {
  sock.on("data", (buf) => console.log("server got chunk:", JSON.stringify(buf.toString())));
  sock.on("end", () => server.close());
});

server.listen(0, "127.0.0.1", () => {
  const port = server.address().port;
  const c = net.connect(port, "127.0.0.1", () => {
    c.write("PING");
    c.write("PONG");
    c.write("DONE");
    c.end();
  });
});
```
]

#code(lang: "text", caption: "output — the three messages have merged")[
```text
server got chunk: "PINGPONGDONE"
```
]

TCP promised that every byte arrives, in order. It never promised that your *messages* stay
separate. The application must add its own framing.

#code(lang: "js", caption: "length-prefix framing fixes it (run with node)")[
```js
const net = require("net");

// Fix: put a 4-byte length in front of every message, then re-assemble.
function onFramed(sock, handler) {
  let buf = Buffer.alloc(0);
  sock.on("data", (chunk) => {
    buf = Buffer.concat([buf, chunk]);
    while (buf.length >= 4) {
      const len = buf.readUInt32BE(0);
      if (buf.length < 4 + len) break;          // message not complete yet
      handler(buf.subarray(4, 4 + len).toString());
      buf = buf.subarray(4 + len);
    }
  });
}
const frame = (s) => {
  const body = Buffer.from(s);
  const head = Buffer.alloc(4);
  head.writeUInt32BE(body.length, 0);
  return Buffer.concat([head, body]);
};

const server = net.createServer((sock) => {
  onFramed(sock, (msg) => console.log("server got message:", msg));
  sock.on("end", () => server.close());
});
server.listen(0, "127.0.0.1", () => {
  const c = net.connect(server.address().port, "127.0.0.1", () => {
    c.write(frame("PING"));
    c.write(frame("PONG"));
    c.write(frame("DONE"));
    c.end();
  });
});
```
]

#code(lang: "text", caption: "output — boundaries restored by the application")[
```text
server got message: PING
server got message: PONG
server got message: DONE
```
]

#trick[
Every text protocol on TCP solves this same problem. HTTP/1.1 uses `Content-Length` or
chunked encoding. Redis uses a length prefix. Line-based protocols use `\n`. If an
interviewer asks "how would you design a protocol over TCP", the first sentence of your
answer is *framing*.
]

#subsection[The TCP header]

#table(columns: 3, align: (left, center, left),
  [*Field*], [*Size*], [*Why it exists*],
  [Source port / destination port], [16 + 16 bits], [half of the 4-tuple],
  [Sequence number], [32 bits], [byte offset of the first byte in this segment],
  [Acknowledgement number], [32 bits], [the next byte the sender of this ACK expects],
  [Data offset], [4 bits], [header length in 4-byte words (options make it longer)],
  [Flags], [SYN ACK FIN RST PSH URG], [see below],
  [Window], [16 bits], [free space in the receiver's buffer, in bytes],
  [Checksum], [16 bits], [covers header + data + a pseudo-header with the IPs],
  [Urgent pointer], [16 bits], [almost never used],
  [Options], [up to 40 bytes], [MSS, window scale, SACK permitted, timestamps],
)

#table(columns: 2, align: (left, left),
  [*SYN*], [start a connection and synchronise sequence numbers],
  [*ACK*], [the acknowledgement field is valid (set on every segment after the first)],
  [*FIN*], [I have no more data to send (but I will still receive)],
  [*RST*], [abort immediately --- no graceful close, no `TIME_WAIT`],
  [*PSH*], [deliver to the application now, do not sit in the buffer],
)

#ex(3, tier: 0, asked: "warm-up")[
Match each flag to its job: SYN, ACK, FIN, RST, PSH.
]
#sol[
#table(columns: 2, align: (left, left),
  [SYN], [open a connection and announce my starting sequence number],
  [ACK], [the acknowledgement field is valid --- set on every segment after the first],
  [FIN], [I have finished *sending*; I can still receive],
  [RST], [something is wrong --- kill this connection immediately],
  [PSH], [hand the data to the application now, do not wait for more],
)
The pair that gets confused is FIN and RST. FIN is a polite goodbye that starts the 4-way
close. RST is a slammed door: no close sequence, no `TIME_WAIT`, and the peer's next read
fails with "connection reset".
#ans[as tabled --- FIN is graceful, RST is not]
]

#trap[
The acknowledgement number is *the next byte expected*, not *the last byte received*. If a
receiver has bytes 1001 to 1200, it sends `ack = 1201`. Answering "1200" is the standard
error. And TCP ACKs are *cumulative*: `ack = 1201` means "everything below 1201 is safe",
not "I got exactly that one segment".
]

#section[Part 4 — The handshake, the data, the close]

#diagram(height: 9.9cm, caption: "one whole TCP connection: 3 segments to open, 4 to close, and the numbers in between")[
  #dnode(0.9cm,  0pt, 2.6cm, 0.6cm, "Client")
  #dnode(11.1cm, 0pt, 2.6cm, 0.6cm, "Server")
  #place(line(start: (2.2cm, 0.62cm), end: (2.2cm, 9.3cm),
    stroke: (paint: rgb("#6b6b6b"), thickness: 0.6pt, dash: "dashed")))
  #place(line(start: (12.4cm, 0.62cm), end: (12.4cm, 9.3cm),
    stroke: (paint: rgb("#6b6b6b"), thickness: 0.6pt, dash: "dashed")))

  #dnode(0pt, 1.15cm, 1.9cm, 1.6cm, "3-way\nhandshake", fill: rgb("#f0f4f8"))
  #dnode(0pt, 3.55cm, 1.9cm, 2.2cm, "data\ntransfer", fill: rgb("#f0f4f8"))
  #dnode(0pt, 6.6cm,  1.9cm, 2.2cm, "4-way\nclose", fill: rgb("#f0f4f8"))

  #place(dx: 2.5cm, dy: 1.02cm, text(size: 7.5pt)[SYN #h(6pt) seq = 1000])
  #darrow(2.2cm, 1.35cm, 12.4cm, 1.5cm)

  #place(dx: 2.5cm, dy: 1.92cm, text(size: 7.5pt)[SYN, ACK #h(6pt) seq = 5000, ack = 1001])
  #darrow(12.4cm, 2.25cm, 2.2cm, 2.4cm)

  #place(dx: 2.5cm, dy: 2.82cm, text(size: 7.5pt)[ACK #h(6pt) seq = 1001, ack = 5001 #h(8pt) — connection is now ESTABLISHED])
  #darrow(2.2cm, 3.15cm, 12.4cm, 3.3cm)

  #place(dx: 2.5cm, dy: 3.72cm, text(size: 7.5pt)[PSH, ACK #h(6pt) seq = 1001 #h(6pt) 200 bytes of request])
  #darrow(2.2cm, 4.05cm, 12.4cm, 4.2cm)

  #place(dx: 2.5cm, dy: 4.62cm, text(size: 7.5pt)[ACK #h(6pt) ack = 1201 #h(8pt) — "next byte I want is 1201"])
  #darrow(12.4cm, 4.95cm, 2.2cm, 5.1cm)

  #place(dx: 2.5cm, dy: 5.32cm, text(size: 7.5pt)[PSH, ACK #h(6pt) seq = 5001 #h(6pt) 500 bytes of response])
  #darrow(12.4cm, 5.65cm, 2.2cm, 5.8cm)

  #place(dx: 2.5cm, dy: 6.02cm, text(size: 7.5pt)[ACK #h(6pt) ack = 5501])
  #darrow(2.2cm, 6.35cm, 12.4cm, 6.5cm)

  #place(dx: 2.5cm, dy: 6.82cm, text(size: 7.5pt)[FIN, ACK #h(6pt) seq = 1201 #h(8pt) — client enters FIN-WAIT-1])
  #darrow(2.2cm, 7.15cm, 12.4cm, 7.3cm)

  #place(dx: 2.5cm, dy: 7.42cm, text(size: 7.5pt)[ACK #h(6pt) ack = 1202 #h(8pt) — server enters CLOSE-WAIT])
  #darrow(12.4cm, 7.75cm, 2.2cm, 7.9cm)

  #place(dx: 2.5cm, dy: 8.02cm, text(size: 7.5pt)[FIN, ACK #h(6pt) seq = 5501 #h(8pt) — server finished too, LAST-ACK])
  #darrow(12.4cm, 8.35cm, 2.2cm, 8.5cm)

  #place(dx: 2.5cm, dy: 8.62cm, text(size: 7.5pt)[ACK #h(6pt) ack = 5502 #h(8pt) — client now waits 2 × MSL in TIME-WAIT])
  #darrow(2.2cm, 8.95cm, 12.4cm, 9.1cm)
]

#tier-header(1)

#ex(4, tier: 1, asked: "TCS NQT · pattern")[
A client picks ISN 1000, a server picks ISN 5000. The client sends 200 bytes, the server
replies with 500. Write every seq and ack number, in order.
]
#sol[
Two rules do all the work:

1. *seq* = the byte number of the first byte in this segment.
2. *ack* = the next byte number I expect from you.
3. SYN and FIN each consume *one* sequence number, even though they carry no data.

#table(columns: 6, align: (left, left, right, right, right, left),
  [*Dir*], [*Flags*], [*seq*], [*ack*], [*len*], [*Why*],
  [C to S], [SYN],     [1000], [--],   [0],   [the SYN itself counts as 1 byte],
  [S to C], [SYN,ACK], [5000], [1001], [0],   [1000 is consumed, so next is 1001],
  [C to S], [ACK],     [1001], [5001], [0],   [handshake done],
  [C to S], [PSH,ACK], [1001], [5001], [200], [bytes 1001 to 1200],
  [S to C], [ACK],     [5001], [1201], [0],   [$1000 + 1 + 200 = 1201$],
  [S to C], [PSH,ACK], [5001], [1201], [500], [bytes 5001 to 5500],
  [C to S], [ACK],     [1201], [5501], [0],   [$5000 + 1 + 500 = 5501$],
  [C to S], [FIN,ACK], [1201], [5501], [0],   [FIN consumes 1],
  [S to C], [ACK],     [5501], [1202], [0],   [acknowledging the FIN],
  [S to C], [FIN,ACK], [5501], [1202], [0],   [server's own FIN],
  [C to S], [ACK],     [1202], [5502], [0],   [last ACK, then `TIME_WAIT`],
)
#ans[shown above --- the key arithmetic is $1000 + 1 + 200 = 1201$ and $5000 + 1 + 500 = 5501$]
]

#code(lang: "js", caption: "the same walk, computed instead of memorised (run with node)")[
```js
// Walk the sequence and acknowledgement numbers of one short TCP conversation.
let c = { isn: 1000 }, s = { isn: 5000 };
const rows = [];
const add = (dir, flags, seq, ack, len, note) =>
  rows.push({ dir, flags, seq, ack, len, note });

add("C->S", "SYN",     c.isn,     "-",       0, "SYN itself counts as 1 byte");
add("S->C", "SYN,ACK", s.isn,     c.isn + 1, 0, "acks the client's SYN");
add("C->S", "ACK",     c.isn + 1, s.isn + 1, 0, "handshake complete");
add("C->S", "PSH,ACK", c.isn + 1, s.isn + 1, 200, "request body, bytes 1001..1200");
add("S->C", "ACK",     s.isn + 1, c.isn + 201, 0, "next byte expected = 1201");
add("S->C", "PSH,ACK", s.isn + 1, c.isn + 201, 500, "response, bytes 5001..5500");
add("C->S", "ACK",     c.isn + 201, s.isn + 501, 0, "next byte expected = 5501");
add("C->S", "FIN,ACK", c.isn + 201, s.isn + 501, 0, "FIN also counts as 1 byte");
add("S->C", "ACK",     s.isn + 501, c.isn + 202, 0, "");
add("S->C", "FIN,ACK", s.isn + 501, c.isn + 202, 0, "");
add("C->S", "ACK",     c.isn + 202, s.isn + 502, 0, "then the client waits 2*MSL");

for (const r of rows)
  console.log(`${r.dir}  ${r.flags.padEnd(8)} seq=${String(r.seq).padEnd(5)} ` +
              `ack=${String(r.ack).padEnd(5)} len=${String(r.len).padEnd(4)} ${r.note}`);
```
]

#code(lang: "text", caption: "output")[
```text
C->S  SYN      seq=1000  ack=-     len=0    SYN itself counts as 1 byte
S->C  SYN,ACK  seq=5000  ack=1001  len=0    acks the client's SYN
C->S  ACK      seq=1001  ack=5001  len=0    handshake complete
C->S  PSH,ACK  seq=1001  ack=5001  len=200  request body, bytes 1001..1200
S->C  ACK      seq=5001  ack=1201  len=0    next byte expected = 1201
S->C  PSH,ACK  seq=5001  ack=1201  len=500  response, bytes 5001..5500
C->S  ACK      seq=1201  ack=5501  len=0    next byte expected = 5501
C->S  FIN,ACK  seq=1201  ack=5501  len=0    FIN also counts as 1 byte
S->C  ACK      seq=5501  ack=1202  len=0
S->C  FIN,ACK  seq=5501  ack=1202  len=0
C->S  ACK      seq=1202  ack=5502  len=0    then the client waits 2*MSL
```
]

#subsection[Why three, and not two or four]

#tier-header(2)

#ex(5, tier: 2, asked: "Grab · pattern")[
Why does opening need three messages but closing needs four?
]
#sol[
*Opening.* Each side must tell the other its starting sequence number, and each must be
sure the other heard it. That is 4 logical messages: C's SYN, S's ACK, S's SYN, C's ACK.
The server's ACK and SYN are *carried in the same segment*, so 4 collapses to 3.

*Closing.* A TCP connection is two independent one-way streams. The client's FIN means
"I have nothing more to *send*" --- it says nothing about what the client still wants to
*receive*. The server may still have data in flight. So the server ACKs the FIN
immediately, keeps sending, and only later sends its own FIN. Those two cannot be merged,
because there is real time between them. Hence 4.

If the server happens to have nothing left to send, its ACK and FIN *can* be combined and
the close does take 3 segments. That is a valid follow-up answer.
#ans[open: the server's ACK and SYN merge. Close: they cannot, because the server may still be sending.]
]

#subsection[The state machine, and `TIME_WAIT`]

#table(columns: 3, align: (left, left, left),
  [*State*], [*Who is in it*], [*Meaning*],
  [`LISTEN`], [server], [waiting for a SYN],
  [`SYN_SENT`], [client], [SYN sent, waiting for SYN-ACK],
  [`SYN_RECEIVED`], [server], [SYN-ACK sent, waiting for the final ACK],
  [`ESTABLISHED`], [both], [data may flow],
  [`FIN_WAIT_1`], [the side that closed first], [FIN sent, not yet acknowledged],
  [`FIN_WAIT_2`], [same side], [its FIN was acknowledged; waiting for the peer's FIN],
  [`CLOSE_WAIT`], [the other side], [peer's FIN received; the *application* has not closed yet],
  [`LAST_ACK`], [the other side], [its own FIN sent, waiting for the final ACK],
  [`TIME_WAIT`], [the side that closed first], [waiting 2 × MSL before the tuple can be reused],
  [`CLOSED`], [both], [gone],
)

#ex(6, tier: 2, asked: "Sea/Shopee · pattern")[
A load-test box shows tens of thousands of sockets in `TIME_WAIT`, and new outbound
connections start failing. Explain the state and give two fixes.
]
#sol[
*Why `TIME_WAIT` exists.* Two reasons.

1. *The last ACK might be lost.* If it is, the peer retransmits its FIN. The closing side
   must still be around to re-answer, otherwise the peer gets an RST and reports an error on
   a connection that actually finished cleanly.
2. *Stale duplicates.* An old, delayed segment from this connection could arrive after a
   *new* connection with the same 4-tuple has opened, and be accepted as valid data. Waiting
   2 × MSL (maximum segment lifetime, typically 30--120 s total) guarantees every old
   segment has died.

*Why the failures.* The box is the *client*, so it is the side closing first, so it
accumulates `TIME_WAIT`. Each one holds an ephemeral port for the tuple. With roughly 28,000
ephemeral ports, tens of thousands of `TIME_WAIT` entries exhaust them.

*Fix 1 --- reuse connections.* Keep-alive / connection pooling. If 10,000 requests share 50
connections, there are 50 closes instead of 10,000. This is the real fix, and it also
removes the handshake cost.

*Fix 2 --- let the server close first.* Then the *server* holds `TIME_WAIT`, and a server
closing from a fixed port does not consume the client's ephemeral range.

*Fix 3 (tuning, not a fix)* --- widen the ephemeral port range, or enable `tcp_tw_reuse` so
the kernel may reuse a `TIME_WAIT` tuple for a new outbound connection when timestamps prove
it is safe. Never disable `TIME_WAIT` outright; you are turning off a correctness guarantee
to hide a design problem.
#ans[it protects the final ACK and kills stale duplicates; fix by pooling connections, not by disabling it]
]

#trap[
`CLOSE_WAIT` and `TIME_WAIT` are different bugs.
*Many `TIME_WAIT`* = normal for a busy client; tune or pool.
*Many `CLOSE_WAIT`* = *your application code has a bug*. The peer closed, the kernel told
you, and your program never called `close()`. Sockets in `CLOSE_WAIT` never time out on
their own. If you see them piling up, look for a missing close in a error path.
]

#section[Part 5 — Reliability]

#table(columns: 2, align: (left, left),
  [*Mechanism*], [*What it catches*],
  [Checksum], [corrupted bits --- the segment is dropped, not repaired],
  [Sequence number], [reordering and duplicates],
  [Cumulative ACK], [tells the sender the highest contiguous byte received],
  [Retransmission timeout (RTO)], [a segment (or its ACK) vanished entirely],
  [Fast retransmit], [a single lost segment, detected by 3 duplicate ACKs, without waiting for the timer],
  [SACK (selective ACK)], [lets the receiver say "I have 1--1000 and 2001--3000", so only the hole is resent],
)

#subsection[Fast retransmit: why *three* duplicates]

If segment 2 of 1, 2, 3, 4, 5 is lost, the receiver still gets 3, 4 and 5. It cannot ACK
them --- ACKs are cumulative --- so it repeats "I still want 2" each time. The sender sees
duplicate ACKs.

One or two duplicate ACKs are ambiguous: they also appear when the network simply
*reordered* two segments. Three duplicates is the threshold chosen so that mild reordering
does not trigger a pointless retransmission, while real loss is caught in well under one RTO.

#tier-header(1)

#ex(7, tier: 1, asked: "Capgemini · pattern")[
A receiver has bytes 1 to 500, then bytes 501 to 1000 are lost, then bytes 1001 to 1500 and
1501 to 2000 arrive. What acknowledgement numbers does it send? What does SACK add?
]
#sol[
*Step 1 --- what a plain cumulative ACK can say.* An ACK names the next byte expected, and
everything below it must be contiguous. The receiver has a contiguous run only up to 500, so
the next byte it wants is *501*.

*Step 2 --- it repeats.* Bytes 1001--1500 arrive: the receiver still cannot move past 500,
so it sends `ack = 501` again. Bytes 1501--2000 arrive: `ack = 501` again.

#table(columns: 3, align: (left, left, left),
  [*Segment received*], [*ACK sent*], [*Kind*],
  [1 -- 500], [ack = 501], [normal],
  [1001 -- 1500], [ack = 501], [duplicate ACK 1],
  [1501 -- 2000], [ack = 501], [duplicate ACK 2],
)

*Step 3 --- what the sender learns.* Only "I am still missing byte 501". Without more
information a strict sender may resend *everything* from 501 onwards --- including the 1000
bytes the receiver already has.

*Step 4 --- what SACK adds.* With the SACK option the receiver appends
"I also have 1001--2000" to each duplicate ACK. Now the sender resends only the 500-byte
hole. On a path with several holes this is the difference between one retransmission and a
full window of them.

*Step 5 --- what happens next.* One more duplicate ACK (three in total) triggers fast
retransmit, so the hole is resent without waiting for the RTO to expire.
#ans[ack = 501 every time; SACK reports the out-of-order block so only the hole is resent]
]

#subsection[Computing the timeout]

#code(lang: "js", caption: "the RFC 6298 retransmission timer (run with node)")[
```js
// RFC 6298 retransmission timer
let srtt = null, rttvar = null;
const ALPHA = 1 / 8, BETA = 1 / 4, G = 0;   // G = clock granularity, 0 here for clarity

function onSample(m) {                       // m = measured RTT in ms
  if (srtt === null) { srtt = m; rttvar = m / 2; }
  else {
    rttvar = (1 - BETA) * rttvar + BETA * Math.abs(srtt - m);
    srtt   = (1 - ALPHA) * srtt   + ALPHA * m;
  }
  const rto = srtt + Math.max(G, 4 * rttvar);
  return { srtt, rttvar, rto: Math.max(1000, rto) };  // RFC floor is 1 second
}

for (const m of [100, 92, 110, 150, 98, 300, 105]) {
  const r = onSample(m);
  console.log(`sample=${String(m).padStart(4)}  SRTT=${r.srtt.toFixed(3).padStart(8)}` +
              `  RTTVAR=${r.rttvar.toFixed(3).padStart(7)}` +
              `  raw RTO=${(srtt + 4 * rttvar).toFixed(3).padStart(8)} ms`);
}
```
]

#code(lang: "text", caption: "output")[
```text
sample= 100  SRTT= 100.000  RTTVAR= 50.000  raw RTO= 300.000 ms
sample=  92  SRTT=  99.000  RTTVAR= 39.500  raw RTO= 257.000 ms
sample= 110  SRTT= 100.375  RTTVAR= 32.375  raw RTO= 229.875 ms
sample= 150  SRTT= 106.578  RTTVAR= 36.688  raw RTO= 253.328 ms
sample=  98  SRTT= 105.506  RTTVAR= 29.660  raw RTO= 224.146 ms
sample= 300  SRTT= 129.818  RTTVAR= 70.869  raw RTO= 413.292 ms
sample= 105  SRTT= 126.715  RTTVAR= 59.356  raw RTO= 364.139 ms
```
]

#tier-header(2)

#ex(8, tier: 2, asked: "DBS · pattern")[
Read the table above. One sample jumped from 98 ms to 300 ms. Why did the RTO nearly double
while SRTT moved only from 105.5 to 129.8?
]
#sol[
Two averages with different jobs.

*SRTT* uses $alpha = 1\/8$, so a new sample moves it by only one eighth of the gap:
$105.506 + (1\/8)(300 - 105.506) = 105.506 + 24.312 = 129.818$. It is deliberately slow, so
one odd measurement does not throw the estimate away.

*RTTVAR* uses $beta = 1\/4$ and measures *how surprising* the sample was:
$0.75 times 29.660 + 0.25 times |105.506 - 300| = 22.245 + 48.624 = 70.869$.

The RTO adds *four times* RTTVAR, so a surprise is amplified:
$129.818 + 4 times 70.869 = 413.292$ ms.

That is the design. When the network becomes unpredictable, TCP does not just raise its
estimate of the delay --- it raises its *margin*, so it does not retransmit segments that
were merely slow. Retransmitting a segment that was only late makes congestion worse.
#ans[SRTT smooths the mean slowly; RTTVAR tracks the variation and is multiplied by 4]
]

#trap[
*Karn's rule.* When a segment is retransmitted and an ACK arrives, you cannot tell whether
it acknowledges the original or the copy, so the RTT sample is ambiguous and must be
*discarded*. TCP instead doubles the RTO on every retransmission (exponential backoff)
until a clean, un-retransmitted sample arrives.
]

#section[Part 6 — Flow control vs congestion control]

Two different problems, two different windows. Confusing them is the classic mistake.

#table(columns: 3, align: (left, left, left),
  [], [*Flow control*], [*Congestion control*],
  [Protects], [the *receiver's* buffer], [the *network's* routers],
  [Signal], [the receiver advertises a window], [loss, duplicate ACKs, timeouts, delay],
  [Window], [rwnd --- sent in the header], [cwnd --- kept privately by the sender],
  [Set by], [the receiver], [the sender itself],
  [Failure looks like], [receiver overflows and drops], [routers queue, then drop; everyone slows],
)

The sender may have at most $min("cwnd", "rwnd")$ unacknowledged bytes in flight. Whichever
is smaller wins.

#subsection[Zero window, and the persist timer]

If the receiving application stops reading, its buffer fills and it advertises
`window = 0`. The sender must stop. But the ACK that later reopens the window is a pure
ACK, and pure ACKs are not retransmitted --- if it is lost, both sides wait forever. So the
sender runs a *persist timer* and sends a 1-byte *window probe* to ask "is the window still
zero?". That breaks the deadlock.

#subsection[Nagle and delayed ACK: the interaction question]

#table(columns: 2, align: (left, left),
  [*Nagle's algorithm*], [sender-side: if there is unacknowledged data in flight, buffer small writes and send them as one bigger segment. Stops 1-byte segments with 40 bytes of header.],
  [*Delayed ACK*], [receiver-side: wait up to about 200 ms before ACKing, hoping to piggyback the ACK on outgoing data or to ACK two segments at once.],
)

#tier-header(3)

#ex(9, tier: 3, asked: "Google · pattern")[
A request/response service sends its request as two `write()` calls: a small header, then a
small body. Latency is fine on the first request and then jumps to about 200 ms per request.
Explain, and give the fix.
]
#sol[
*The interaction.* Write 1 (header) goes out immediately --- nothing is in flight. Write 2
(body) is small *and* there is now unacknowledged data, so *Nagle holds it*. The server has
received only the header, which is an incomplete request, so it cannot reply --- and having
no data to piggyback on, *delayed ACK holds its ACK* for up to 200 ms. Nagle waits for the
ACK; the ACK waits for data. The deadlock breaks only when the delayed-ACK timer fires.

Every request then costs about 200 ms of pure waiting.

*Fix 1 --- one write.* Build header + body into a single buffer and write once. Nagle never
engages, because there is nothing to coalesce. This is the correct fix and it is free.

*Fix 2 --- disable Nagle* (`TCP_NODELAY`, which is what `socket.setNoDelay(true)` sets in
Node). Standard for latency-sensitive request/response and RPC traffic. The cost is more,
smaller segments.

*What not to do:* disabling delayed ACK. It is a receiver-side setting you usually do not
control, and it increases ACK traffic for everyone.

*The one-line answer:* "Nagle is waiting for an ACK, delayed ACK is waiting for data. Write
the whole message in one call, or set `TCP_NODELAY`."
#ans[Nagle + delayed ACK deadlock; fix with a single write, or TCP_NODELAY]
]

#section[Part 7 — Congestion control, with the numbers]

#subsection[The four phases]

#table(columns: 3, align: (left, left, left),
  [*Phase*], [*Rule*], [*Why*],
  [Slow start], [`cwnd` doubles each RTT], [find the capacity fast; "slow" refers to the tiny *start*, not the growth],
  [Congestion avoidance], [`cwnd` grows by 1 each RTT], [probe gently once near the limit (additive increase)],
  [Fast retransmit / recovery], [on 3 dup ACKs: halve and continue], [dup ACKs prove packets are still flowing, so the loss was mild],
  [Timeout], [`cwnd` back to 1, slow start again], [silence means something is badly wrong],
)

#diagram(height: 5.4cm, caption: "cwnd over 23 RTTs: ssthresh starts at 16, 3 dup ACKs at RTT 9, a timeout at RTT 16")[
  #place(line(start: (0.95cm, 4.3cm), end: (14.9cm, 4.3cm), stroke: 0.7pt + rgb("#6b6b6b")))
  #place(line(start: (0.95cm, 0.55cm), end: (0.95cm, 4.3cm), stroke: 0.7pt + rgb("#6b6b6b")))
  #place(dx: 0.20cm, dy: 3.315cm, text(size: 7pt, fill: rgb("#6b6b6b"))[5])
  #place(line(start: (0.82cm, 3.475cm), end: (0.95cm, 3.475cm), stroke: 0.7pt + rgb("#6b6b6b")))
  #place(dx: 0.20cm, dy: 2.490cm, text(size: 7pt, fill: rgb("#6b6b6b"))[10])
  #place(line(start: (0.82cm, 2.65cm), end: (0.95cm, 2.65cm), stroke: 0.7pt + rgb("#6b6b6b")))
  #place(dx: 0.20cm, dy: 1.665cm, text(size: 7pt, fill: rgb("#6b6b6b"))[15])
  #place(line(start: (0.82cm, 1.825cm), end: (0.95cm, 1.825cm), stroke: 0.7pt + rgb("#6b6b6b")))
  #place(dx: 0.20cm, dy: 0.840cm, text(size: 7pt, fill: rgb("#6b6b6b"))[20])
  #place(line(start: (0.82cm, 1.0cm), end: (0.95cm, 1.0cm), stroke: 0.7pt + rgb("#6b6b6b")))
  #place(dx: 1.080cm, dy: 4.36cm, text(size: 7pt, fill: rgb("#6b6b6b"))[1])
  #place(dx: 3.480cm, dy: 4.36cm, text(size: 7pt, fill: rgb("#6b6b6b"))[5])
  #place(dx: 5.880cm, dy: 4.36cm, text(size: 7pt, fill: rgb("#6b6b6b"))[9])
  #place(dx: 8.280cm, dy: 4.36cm, text(size: 7pt, fill: rgb("#6b6b6b"))[13])
  #place(dx: 10.680cm, dy: 4.36cm, text(size: 7pt, fill: rgb("#6b6b6b"))[17])
  #place(dx: 13.080cm, dy: 4.36cm, text(size: 7pt, fill: rgb("#6b6b6b"))[21])
  #place(dx: 14.280cm, dy: 4.36cm, text(size: 7pt, fill: rgb("#6b6b6b"))[23])
  #place(line(start: (1.2cm, 1.66cm), end: (6.0cm, 1.66cm), stroke: (paint: rgb("#9b2226"), thickness: 0.8pt, dash: "dashed")))
  #place(line(start: (6.6cm, 2.65cm), end: (10.2cm, 2.65cm), stroke: (paint: rgb("#9b2226"), thickness: 0.8pt, dash: "dashed")))
  #place(line(start: (10.8cm, 2.98cm), end: (14.4cm, 2.98cm), stroke: (paint: rgb("#9b2226"), thickness: 0.8pt, dash: "dashed")))
  #place(line(start: (1.2cm, 4.135cm), end: (1.8cm, 3.97cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (1.8cm, 3.97cm), end: (2.4cm, 3.64cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (2.4cm, 3.64cm), end: (3.0cm, 2.98cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (3.0cm, 2.98cm), end: (3.6cm, 1.66cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (3.6cm, 1.66cm), end: (4.2cm, 1.495cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (4.2cm, 1.495cm), end: (4.8cm, 1.33cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (4.8cm, 1.33cm), end: (5.4cm, 1.165cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (5.4cm, 1.165cm), end: (6.0cm, 1.0cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (6.0cm, 1.0cm), end: (6.6cm, 2.65cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (6.6cm, 2.65cm), end: (7.2cm, 2.485cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (7.2cm, 2.485cm), end: (7.8cm, 2.32cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (7.8cm, 2.32cm), end: (8.4cm, 2.155cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (8.4cm, 2.155cm), end: (9.0cm, 1.99cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (9.0cm, 1.99cm), end: (9.6cm, 1.825cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (9.6cm, 1.825cm), end: (10.2cm, 1.66cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (10.2cm, 1.66cm), end: (10.8cm, 4.135cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (10.8cm, 4.135cm), end: (11.4cm, 3.97cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (11.4cm, 3.97cm), end: (12.0cm, 3.64cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (12.0cm, 3.64cm), end: (12.6cm, 2.98cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (12.6cm, 2.98cm), end: (13.2cm, 2.815cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (13.2cm, 2.815cm), end: (13.8cm, 2.65cm), stroke: 1.2pt + rgb("#33556b")))
  #place(line(start: (13.8cm, 2.65cm), end: (14.4cm, 2.485cm), stroke: 1.2pt + rgb("#33556b")))
  #place(dx: 1.147cm, dy: 4.082cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 1.747cm, dy: 3.917cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 2.347cm, dy: 3.587cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 2.947cm, dy: 2.927cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 3.547cm, dy: 1.607cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 4.147cm, dy: 1.442cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 4.747cm, dy: 1.277cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 5.347cm, dy: 1.112cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 5.947cm, dy: 0.947cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 6.547cm, dy: 2.597cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 7.147cm, dy: 2.432cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 7.747cm, dy: 2.267cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 8.347cm, dy: 2.102cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 8.947cm, dy: 1.937cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 9.547cm, dy: 1.772cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 10.147cm, dy: 1.607cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 10.747cm, dy: 4.082cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 11.347cm, dy: 3.917cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 11.947cm, dy: 3.587cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 12.547cm, dy: 2.927cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 13.147cm, dy: 2.762cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 13.747cm, dy: 2.597cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 14.347cm, dy: 2.432cm, circle(radius: 1.5pt, fill: rgb("#33556b"), stroke: none))
  #place(dx: 0.05cm, dy: 0.05cm, text(size: 7.5pt, fill: rgb("#6b6b6b"))[cwnd])
  #place(dx: 14.3cm, dy: 4.62cm, text(size: 7.5pt, fill: rgb("#6b6b6b"))[RTT])
  #place(dx: 5.4cm, dy: 0.60cm, text(size: 7pt, fill: rgb("#9b2226"))[3 dup ACKs])
  #place(dx: 9.4cm, dy: 1.15cm, text(size: 7pt, fill: rgb("#9b2226"))[timeout])
  #place(dx: 1.35cm, dy: 4.72cm, text(size: 7pt, fill: rgb("#33556b"))[dashed red line = ssthresh])
]

#tier-header(2)

#ex(10, tier: 2, asked: "Agoda · pattern")[
`ssthresh` starts at 16 MSS and `cwnd` at 1. Three duplicate ACKs arrive at the end of RTT
9, and a timeout happens at the end of RTT 16. Give `cwnd` for RTTs 1 to 23.
]
#sol[
Apply the four rules, one RTT at a time.

*RTTs 1--4, slow start* ($"cwnd" < "ssthresh"$, so double):
$1 arrow.r 2 arrow.r 4 arrow.r 8 arrow.r 16$.

*RTT 5:* `cwnd` is now 16, which equals `ssthresh`. Switch to congestion avoidance: $+1$ per
RTT.

*RTTs 5--9:* 16, 17, 18, 19, 20.

*End of RTT 9 --- 3 dup ACKs.* $"ssthresh" = 20 \/ 2 = 10$, and $"cwnd" = 10$ (Reno's fast
recovery keeps the connection going rather than restarting).

*RTTs 10--16, congestion avoidance from 10:* 10, 11, 12, 13, 14, 15, 16.

*End of RTT 16 --- timeout.* $"ssthresh" = 16 \/ 2 = 8$, and $"cwnd" = 1$.

*RTTs 17--19, slow start again:* 1, 2, 4. At 8 it meets the new `ssthresh`.

*RTTs 20--23, congestion avoidance:* 8, 9, 10, 11.

#table(columns: 12, align: (center, center, center, center, center, center, center, center, center, center, center, center),
  [*RTT*], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11],
  [*cwnd*], [1], [2], [4], [8], [16], [17], [18], [19], [20], [10], [11],
)
#table(columns: 13, align: (center, center, center, center, center, center, center, center, center, center, center, center, center),
  [*RTT*], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23],
  [*cwnd*], [12], [13], [14], [15], [16], [1], [2], [4], [8], [9], [10], [11],
)
#ans[1 2 4 8 16 17 18 19 20 | 10 11 12 13 14 15 16 | 1 2 4 8 9 10 11]
]

#code(lang: "js", caption: "the same simulation (run with node)")[
```js
// Reno: slow start -> congestion avoidance; 3 dup ACKs halves, timeout resets to 1.
function simulate(rounds, ssthresh0, events) {
  let cwnd = 1, ssthresh = ssthresh0;
  const log = [];
  for (let r = 1; r <= rounds; r++) {
    const phase = cwnd < ssthresh ? "slow start" : "cong. avoid";
    const ev = events[r] ?? "";
    log.push({ rtt: r, cwnd, ssthresh, phase, ev });
    if (ev === "dup")          { ssthresh = Math.floor(cwnd / 2); cwnd = ssthresh; }
    else if (ev === "timeout") { ssthresh = Math.floor(cwnd / 2); cwnd = 1; }
    else if (cwnd < ssthresh)  { cwnd = Math.min(cwnd * 2, ssthresh); }
    else                       { cwnd += 1; }
  }
  return log;
}
const log = simulate(23, 16, { 9: "dup", 16: "timeout" });
for (const r of log)
  console.log(`RTT ${String(r.rtt).padStart(2)}  cwnd=${String(r.cwnd).padStart(3)}  ` +
              `ssthresh=${String(r.ssthresh).padStart(3)}  ${r.phase.padEnd(12)}${r.ev}`);
console.log("segments sent in 23 RTTs =", log.reduce((s, r) => s + r.cwnd, 0));
```
]

#code(lang: "text", caption: "output (middle rows trimmed for space)")[
```text
RTT  1  cwnd=  1  ssthresh= 16  slow start
RTT  2  cwnd=  2  ssthresh= 16  slow start
RTT  3  cwnd=  4  ssthresh= 16  slow start
RTT  4  cwnd=  8  ssthresh= 16  slow start
RTT  5  cwnd= 16  ssthresh= 16  cong. avoid
...
RTT  9  cwnd= 20  ssthresh= 16  cong. avoid dup
RTT 10  cwnd= 10  ssthresh= 10  cong. avoid
...
RTT 16  cwnd= 16  ssthresh= 10  cong. avoid timeout
RTT 17  cwnd=  1  ssthresh=  8  slow start
RTT 18  cwnd=  2  ssthresh=  8  slow start
RTT 19  cwnd=  4  ssthresh=  8  slow start
RTT 20  cwnd=  8  ssthresh=  8  cong. avoid
RTT 23  cwnd= 11  ssthresh=  8  cong. avoid
segments sent in 23 RTTs = 241
```
]

#trap[
"Slow start is slow." It is the *fastest* growth TCP ever uses --- exponential. The name
means it *starts* small (1 segment) instead of blasting a full window on a path it knows
nothing about. Say "slow start grows exponentially" and you have already separated yourself
from most candidates.
]

#table(columns: 3, align: (left, left, left),
  [*Algorithm*], [*Reacts to*], [*Character*],
  [Reno], [loss], [the classic sawtooth; poor on high bandwidth-delay links],
  [CUBIC], [loss], [Linux default; window grows as a cubic curve, recovers faster after loss],
  [BBR], [measured bandwidth and RTT], [models the pipe instead of waiting for loss; avoids filling router queues (bufferbloat)],
)

#section[Part 8 — Throughput arithmetic]

#tier-header(1)

#ex(11, tier: 1, asked: "Infosys · pattern")[
A 1000-byte frame is sent on a 10 Mbps link with an RTT of 20 ms.
(a) Utilisation with stop-and-wait?
(b) With a sender window of 7 frames?
(c) What window makes utilisation 100%?
]
#sol[
*Step 1 --- transmission time of one frame.*
$ T_t = (1000 times 8) / (10 times 10^6) = 8000 / (10^7) = 0.8 "ms" $

*Step 2 --- stop-and-wait.* Send one frame, then wait a whole RTT for its ACK. The sender is
busy for $T_t$ out of every $T_t + "RTT"$:
$ U = 0.8 / (0.8 + 20) = 0.8 / 20.8 = 0.0385 = 3.85% $

*Step 3 --- window of 7.* Seven frames go out back to back before the first ACK returns:
$ U = (7 times 0.8) / 20.8 = 5.6 / 20.8 = 0.2692 = 26.92% $

*Step 4 --- window for 100%.* Need $N times T_t >= T_t + "RTT"$:
$ N >= 1 + "RTT" / T_t = 1 + 20 / 0.8 = 1 + 25 = 26 $
#ans[(a) 3.85% (b) 26.92% (c) 26 frames]
]

#tier-header(2)

#ex(12, tier: 2, asked: "GIC · pattern")[
A 100 Mbps path has an RTT of 40 ms. The TCP window field is 16 bits.
(a) How many bytes fit "in the pipe"?
(b) What is the best throughput a 64 KiB window can give?
(c) What fixes it?
]
#sol[
*Step 1 --- bandwidth-delay product.* This is how many bytes are in flight when the pipe is
full:
$ "BDP" = (100 times 10^6 times 0.040) / 8 = (4 times 10^6) / 8 = 500{,}000 "bytes" $

*Step 2 --- what the window allows.* The 16-bit window field maxes out at 65,535 bytes. The
sender may have only that much unacknowledged, then it must stop and wait:
$ "throughput" = (65535 times 8) / 0.040 = 524280 / 0.040 = 13.107 "Mbps" $

So a 100 Mbps path delivers 13.1 Mbps. We are using 13% of the link, and the *only* reason
is the size of a header field.

*Step 3 --- how short are we?* $500000 \/ 65535 = 7.63$. We need about 7.6 windows in
flight, and TCP allows 1.

*Step 4 --- the fix.* The *window scale option*, negotiated in the SYN. It declares a shift
of up to 14, multiplying the advertised window by up to $2^14 = 16384$, giving a maximum
window of about 1 GB. With scaling on, a 500 KB window fits easily and the link fills.

This situation --- fast link, long RTT --- is called a *long fat network*, and window
scaling is the standard answer.
#ans[(a) 500,000 bytes (b) 13.107 Mbps (c) the window scale option]
]

#code(lang: "js", caption: "all of the throughput arithmetic, run (run with node)")[
```js
// 1. Bandwidth-delay product: how many bytes fit "in flight" on the link.
function bdp(bps, rttSeconds) { return (bps * rttSeconds) / 8; }
console.log("BDP 100 Mbps x 40 ms =", bdp(100e6, 0.04), "bytes");

// 2. What a 64 KiB window can actually push at that RTT.
const WIN = 65535;
const thr = (WIN * 8) / 0.04;
console.log("throughput with a 64 KiB window =", (thr / 1e6).toFixed(3), "Mbps");
console.log("windows needed to fill the pipe =", (bdp(100e6, 0.04) / WIN).toFixed(2));

// 3. Stop-and-wait vs sliding window utilisation.
function util(frameBytes, linkBps, rttSeconds, windowFrames) {
  const Tt = (frameBytes * 8) / linkBps;
  return { TtMs: Tt * 1000, u: Math.min(1, (windowFrames * Tt) / (Tt + rttSeconds)) };
}
const sw = util(1000, 10e6, 0.020, 1);
console.log("stop-and-wait: Tt =", sw.TtMs.toFixed(3), "ms, utilisation =",
            (sw.u * 100).toFixed(2), "%");
console.log("window of 7  : utilisation =",
            (util(1000, 10e6, 0.020, 7).u * 100).toFixed(2), "%");
console.log("window needed for 100% =", (1 + 0.020 / (sw.TtMs / 1000)).toFixed(0), "frames");

// 4. How long before a 32-bit sequence number wraps.
for (const bps of [100e6, 1e9]) {
  console.log(`seq space wraps in ${(2 ** 32 / (bps / 8)).toFixed(1)} s at ${bps / 1e6} Mbps`);
}
```
]

#code(lang: "text", caption: "output")[
```text
BDP 100 Mbps x 40 ms = 500000 bytes
throughput with a 64 KiB window = 13.107 Mbps
windows needed to fill the pipe = 7.63
stop-and-wait: Tt = 0.800 ms, utilisation = 3.85 %
window of 7  : utilisation = 26.92 %
window needed for 100% = 26 frames
seq space wraps in 343.6 s at 100 Mbps
seq space wraps in 34.4 s at 1000 Mbps
```
]

#note[
That last pair of lines is the reason TCP timestamps exist. At 1 Gbps the 32-bit sequence
space repeats every 34 seconds --- shorter than the maximum segment lifetime. An old segment
could then look like a valid new one. The timestamp option (PAWS, "protect against wrapped
sequence numbers") adds the extra bits needed to tell them apart.
]

#section[Part 9 — HTTP]

#subsection[A request is just bytes]

#code(lang: "js", caption: "the literal bytes on the wire (run with node)")[
```js
const http = require("http");
const net = require("net");

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "text/plain", "Content-Length": "5" });
  res.end("hello");
});

server.listen(0, "127.0.0.1", () => {
  const port = server.address().port;
  const c = net.connect(port, "127.0.0.1", () => {
    // These are the literal bytes an HTTP/1.1 request is made of.
    c.write("GET /hi HTTP/1.1\r\n");
    c.write("Host: example.test\r\n");
    c.write("Connection: close\r\n");
    c.write("\r\n");
  });
  let raw = "";
  c.on("data", (d) => (raw += d));
  c.on("end", () => {
    console.log(JSON.stringify(raw));       // escaped, so you can SEE the \r\n
    console.log("-----");
    console.log(raw);
    server.close();
  });
});
```
]

#code(lang: "text", caption: "output")[
```text
"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 5\r\n
Date: Tue, 15 Sep 2026 16:36:23 GMT\r\nConnection: close\r\n\r\nhello"
-----
HTTP/1.1 200 OK
Content-Type: text/plain
Content-Length: 5
Date: Tue, 15 Sep 2026 16:36:23 GMT
Connection: close

hello
```
]

Three rules and you can read any HTTP/1.1 message:
1. The first line is the *start line* (request line, or status line).
2. Then `Name: value` headers, one per line.
3. Then *one blank line*, then the body. The blank line is `\r\n\r\n`.

#code(lang: "js", caption: "parsing a request by hand (run with node)")[
```js
// Parse the literal bytes of an HTTP/1.1 request. This is all HTTP/1.1 is.
const raw =
  "POST /api/orders HTTP/1.1\r\n" +
  "Host: shop.example\r\n" +
  "Content-Type: application/json\r\n" +
  "Content-Length: 25\r\n" +
  "Cookie: sid=abc123; theme=dark\r\n" +
  "\r\n" +
  '{"item":"kettle","qty":2}\r\n';

const [head, body] = raw.split("\r\n\r\n");
const [startLine, ...headerLines] = head.split("\r\n");
const [method, path, version] = startLine.split(" ");

const headers = new Map(
  headerLines.map((l) => {
    const i = l.indexOf(":");
    return [l.slice(0, i).toLowerCase(), l.slice(i + 1).trim()];
  })
);

const cookies = Object.fromEntries(
  (headers.get("cookie") ?? "").split("; ").filter(Boolean).map((c) => c.split("="))
);

console.log({ method, path, version });
console.log("host          :", headers.get("host"));
console.log("content-length:", headers.get("content-length"));
console.log("cookies       :", cookies);
console.log("body          :", body.trim());
console.log("declared length matches?",
            Number(headers.get("content-length")) === body.trim().length);
```
]

#code(lang: "text", caption: "output")[
```text
{ method: 'POST', path: '/api/orders', version: 'HTTP/1.1' }
host          : shop.example
content-length: 25
cookies       : { sid: 'abc123', theme: 'dark' }
body          : {"item":"kettle","qty":2}
declared length matches? true
```
]

#note[
Headers are lower-cased on the way in because HTTP header names are *case-insensitive*.
`Content-Type`, `content-type` and `CONTENT-TYPE` are the same header. Header *values* are
not case-insensitive.
]

#subsection[Methods: safe, idempotent, cacheable]

#table(columns: 5, align: (left, center, center, center, left),
  [*Method*], [*Safe*], [*Idempotent*], [*Cacheable*], [*Meaning*],
  [GET], [yes], [yes], [yes], [read a resource],
  [HEAD], [yes], [yes], [yes], [GET without the body --- headers only],
  [OPTIONS], [yes], [yes], [no], [what may I do here (used by CORS preflight)],
  [PUT], [no], [*yes*], [no], [replace the resource with this exact content],
  [DELETE], [no], [*yes*], [no], [remove the resource],
  [POST], [no], [*no*], [rarely], [submit; the server decides what it means],
  [PATCH], [no], [usually no], [no], [partial update],
)

#table(columns: 2, align: (left, left),
  [*Safe*], [does not change server state --- a crawler may call it freely],
  [*Idempotent*], [doing it $n$ times leaves the same state as doing it once],
)

#tier-header(1)

#ex(13, tier: 1, asked: "Accenture · pattern")[
The same search form can be submitted with GET (`/search?q=kettle&page=2`) or with POST
(fields in the body). Give four practical differences.
]
#sol[
#table(columns: 3, align: (left, left, left),
  [*Difference*], [*GET*], [*POST*],
  [Where the data goes], [in the URL query string], [in the request body],
  [Bookmark and share], [yes --- the URL holds the state], [no --- the body is not in the URL],
  [Cacheable and pre-fetchable], [yes], [effectively no],
  [Shows up in logs, history, `Referer`], [yes --- never put a password or token here], [no],
  [Length], [limited in practice (often about 2000 characters)], [effectively unlimited],
  [Repeating it], [safe --- GET is idempotent], [may create a duplicate; browsers warn on refresh],
)

*The rule to say:* GET for reading, where the URL should describe what you are looking at.
POST for changing something, or when the input is large or must not appear in a URL.
#ans[URL vs body; bookmarkable; cacheable; visible in logs; length; safe to repeat]
]

#ex(14, tier: 1, asked: "Wipro · pattern")[
DELETE is idempotent, yet calling it twice gives 200 the first time and 404 the second. Is
that a contradiction?
]
#sol[
No. Idempotence is about the *state of the server*, not about the *response code*.

After the first DELETE the resource is gone. After the second DELETE the resource is still
gone. The state is identical, so DELETE is idempotent.

The 404 is just a truthful report about what the second call found.

Same logic for PUT: `PUT /user/7` with the same body twice leaves user 7 in exactly one
state. POST is *not* idempotent because `POST /orders` twice creates *two* orders --- that
is why refreshing a payment page can charge you twice, and why real systems add an
*idempotency key* header so the server can recognise a repeat.
#ans[no --- idempotence constrains the state, not the status code]
]

#subsection[Status codes]

#table(columns: 3, align: (center, left, left),
  [*Code*], [*Name*], [*When you use it*],
  [200], [OK], [normal success with a body],
  [201], [Created], [POST made something; send a `Location` header],
  [204], [No Content], [success, deliberately empty body (a DELETE, a save)],
  [301], [Moved Permanently], [the new URL is forever; browsers *cache* this, sometimes hard],
  [302], [Found], [temporary move; do not cache the new location],
  [304], [Not Modified], [your cached copy is still good; *no body is sent*],
  [307 / 308], [Temporary / Permanent Redirect], [like 302 / 301 but the method must not change],
  [400], [Bad Request], [the request itself is malformed],
  [401], [Unauthorized], [*not authenticated* --- who are you?],
  [403], [Forbidden], [authenticated, but *not allowed*],
  [404], [Not Found], [no such resource],
  [405], [Method Not Allowed], [the path exists, this verb does not],
  [409], [Conflict], [version clash, duplicate key],
  [415], [Unsupported Media Type], [wrong `Content-Type`],
  [429], [Too Many Requests], [rate limited; send `Retry-After`],
  [500], [Internal Server Error], [an unhandled exception on the server],
  [502], [Bad Gateway], [a proxy got garbage from the upstream server],
  [503], [Service Unavailable], [overloaded or in maintenance; usually temporary],
  [504], [Gateway Timeout], [a proxy waited for the upstream and gave up],
)

#trap[
*401 vs 403.* 401 means "I do not know who you are --- send credentials" (and the response
should carry `WWW-Authenticate`). 403 means "I know exactly who you are and you still may
not". Swapping these is the most-asked HTTP trick question after 301 vs 302.

*301 vs 302.* A browser may cache a 301 for a long time --- so a wrong 301 in production is
very hard to undo, because you cannot reach the clients that cached it. Use 302 (or 307)
unless you are certain the move is permanent.
]

#subsection[Caching and conditional requests]

#table(columns: 2, align: (left, left),
  [`Cache-Control: max-age=60`], [reuse for 60 seconds without asking],
  [`Cache-Control: no-cache`], [you may store it, but *revalidate* before every use],
  [`Cache-Control: no-store`], [never write it to disk or memory (use for private data)],
  [`Cache-Control: private`], [only the browser may cache it, not a shared CDN],
  [`ETag: "a1b2"`], [an opaque version tag for this exact content],
  [`If-None-Match: "a1b2"`], [client: "only send it if the version changed"],
  [`Last-Modified` / `If-Modified-Since`], [the same idea, using a date instead of a tag],
)

#code(lang: "js", caption: "ETag revalidation producing a 304 (run with node)")[
```js
const http = require("http");

const BODY = JSON.stringify({ price: 499 });
const ETAG = '"a1b2"';

const server = http.createServer((req, res) => {
  if (req.headers["if-none-match"] === ETAG) {
    res.writeHead(304, { ETag: ETAG });      // 304 has NO body
    return res.end();
  }
  res.writeHead(200, { ETag: ETAG, "Content-Type": "application/json" });
  res.end(BODY);
});

function ask(port, etag) {
  return new Promise((resolve) => {
    const headers = etag ? { "If-None-Match": etag } : {};
    http.get({ host: "127.0.0.1", port, path: "/price", headers }, (res) => {
      let b = "";
      res.on("data", (d) => (b += d));
      res.on("end", () =>
        resolve({ status: res.statusCode, etag: res.headers.etag, bytes: b.length }));
    });
  });
}

server.listen(0, "127.0.0.1", async () => {
  const port = server.address().port;
  const first = await ask(port, null);
  console.log("first request :", first);
  const second = await ask(port, first.etag);
  console.log("second request:", second);
  server.close();
});
```
]

#code(lang: "text", caption: "output — the second response carries zero body bytes")[
```text
first request : { status: 200, etag: '"a1b2"', bytes: 13 }
second request: { status: 304, etag: '"a1b2"', bytes: 0 }
```
]

#trap[
A 304 still costs a full round trip --- the client asked, the server answered. It only saves
*bandwidth*, not *latency*. `max-age` saves both, because the client does not send a request
at all. Interviewers like this distinction: "`ETag` saves bytes, `max-age` saves the
round trip."
]

#section[Part 10 — HTTP/1.1, 2 and 3]

#subsection[The problem each version solves]

#table(columns: 4, align: (left, left, left, left),
  [], [*HTTP/1.1*], [*HTTP/2*], [*HTTP/3*],
  [Year], [1997], [2015], [2022],
  [Transport], [TCP], [TCP], [*QUIC over UDP*],
  [Format], [plain text], [binary frames], [binary frames],
  [Requests per connection], [one at a time], [many, multiplexed], [many, multiplexed],
  [Header compression], [none], [HPACK], [QPACK],
  [Server push], [no], [yes (now deprecated)], [no],
  [Head-of-line blocking], [at the HTTP layer], [removed at HTTP, *remains at TCP*], [removed at both],
  [Connection setup], [TCP + TLS], [TCP + TLS], [QUIC folds transport and TLS into one],
)

#diagram(height: 5.6cm, caption: "three requests on one connection: serialised in HTTP/1.1, interleaved in HTTP/2")[
  #dnode(0pt, 0pt, 15.4cm, 0.55cm, "HTTP/1.1 — one connection carries one request at a time; a slow response blocks the queue")
  #dnode(0.2cm,  0.8cm, 1.3cm, 0.6cm, "req A", fill: rgb("#e2ecf3"))
  #dnode(1.6cm,  0.8cm, 5.4cm, 0.6cm, "response A  (slow: 300 ms)")
  #dnode(7.1cm,  0.8cm, 1.3cm, 0.6cm, "req B", fill: rgb("#e2ecf3"))
  #dnode(8.5cm,  0.8cm, 2.3cm, 0.6cm, "response B")
  #dnode(10.9cm, 0.8cm, 1.3cm, 0.6cm, "req C", fill: rgb("#e2ecf3"))
  #dnode(12.3cm, 0.8cm, 2.3cm, 0.6cm, "response C")
  #place(dx: 0.2cm, dy: 1.5cm, text(size: 7pt, fill: rgb("#9b2226"))[B and C were ready at t = 0 but had to wait for A])

  #dnode(0pt, 2.35cm, 15.4cm, 0.55cm, "HTTP/2 — one connection, three independent streams; frames are interleaved")
  #dnode(0.2cm, 3.15cm, 1.3cm, 0.6cm, "req A", fill: rgb("#e2ecf3"))
  #dnode(1.6cm, 3.15cm, 5.4cm, 0.6cm, "stream 1: response A  (still 300 ms)")
  #dnode(0.2cm, 3.85cm, 1.3cm, 0.6cm, "req B", fill: rgb("#e2ecf3"))
  #dnode(1.6cm, 3.85cm, 2.3cm, 0.6cm, "stream 3: resp B")
  #dnode(0.2cm, 4.55cm, 1.3cm, 0.6cm, "req C", fill: rgb("#e2ecf3"))
  #dnode(1.6cm, 4.55cm, 2.6cm, 0.6cm, "stream 5: resp C")
  #place(dx: 4.4cm, dy: 4.70cm, text(size: 7pt, fill: rgb("#2f6b3f"))[B and C finish early — they never queued behind A])
  #place(line(start: (1.55cm, 2.95cm), end: (1.55cm, 5.2cm),
    stroke: (paint: rgb("#6b6b6b"), thickness: 0.6pt, dash: "dashed")))
]

#tier-header(2)

#ex(15, tier: 2, asked: "Razer · pattern")[
A page needs 30 small assets. RTT is 100 ms and the assets themselves are tiny, so only
round trips matter. Compare HTTP/1.1 on 1 connection, HTTP/1.1 on 6 connections, and HTTP/2
on 1 connection.
]
#sol[
*HTTP/1.1, 1 connection.* One request at a time: 30 round trips.
$30 times 100 = 3000$ ms.

*HTTP/1.1, 6 connections.* Browsers open up to 6 per host. Six assets per round:
$ "rounds" = ceil(30 / 6) = 5, quad 5 times 100 = 500 "ms" $

*HTTP/2, 1 connection.* All 30 requests are sent as streams immediately; all 30 responses
come back together: *1 round trip = 100 ms*.

#table(columns: 3, align: (left, right, right),
  [*Setup*], [*Round trips*], [*Time*],
  [HTTP/1.1, 1 connection], [30], [3000 ms],
  [HTTP/1.1, 6 connections], [5], [500 ms],
  [HTTP/2, 1 connection], [1], [100 ms],
)

*The follow-up you should volunteer:* HTTP/2's win also removes the cost of 6 TCP+TLS
handshakes and 6 separate congestion windows that each have to slow-start from scratch. And
it makes the old workarounds --- sprite sheets, file concatenation, domain sharding ---
unnecessary or actively harmful.
#ans[3000 ms, 500 ms, 100 ms]
]

#code(lang: "js", caption: "the round-trip arithmetic, run (run with node)")[
```js
// Page load time when the only cost that matters is round trips.
const RTT = 100;          // ms
const ASSETS = 30;

function http11(parallelConns) {
  const rounds = Math.ceil(ASSETS / parallelConns);
  return { rounds, ms: rounds * RTT };
}
function http2() { return { rounds: 1, ms: RTT }; }   // all streams multiplexed

console.log("HTTP/1.1, 1 connection :", http11(1));
console.log("HTTP/1.1, 6 connections:", http11(6));
console.log("HTTP/2,  1 connection  :", http2());

// Time before the FIRST request byte can even be sent.
const setup = {
  "HTTP/1.1 over TCP, no TLS":     1,  // TCP handshake
  "HTTPS with TLS 1.2":            3,  // TCP 1 + TLS 1.2 two round trips
  "HTTPS with TLS 1.3":            2,  // TCP 1 + TLS 1.3 one round trip
  "HTTP/3 (QUIC, first visit)":    1,  // QUIC folds transport + crypto together
  "HTTP/3 (QUIC, 0-RTT resume)":   0,
};
for (const [name, rtts] of Object.entries(setup))
  console.log(`${name.padEnd(30)} ${rtts} RTT = ${rtts * RTT} ms before the request goes out`);
```
]

#code(lang: "text", caption: "output")[
```text
HTTP/1.1, 1 connection : { rounds: 30, ms: 3000 }
HTTP/1.1, 6 connections: { rounds: 5, ms: 500 }
HTTP/2,  1 connection  : { rounds: 1, ms: 100 }
HTTP/1.1 over TCP, no TLS      1 RTT = 100 ms before the request goes out
HTTPS with TLS 1.2             3 RTT = 300 ms before the request goes out
HTTPS with TLS 1.3             2 RTT = 200 ms before the request goes out
HTTP/3 (QUIC, first visit)     1 RTT = 100 ms before the request goes out
HTTP/3 (QUIC, 0-RTT resume)    0 RTT = 0 ms before the request goes out
```
]

#tier-header(3)

#ex(16, tier: 3, asked: "Google · pattern")[
HTTP/2 already fixed head-of-line blocking. So why did HTTP/3 move to UDP?
]
#sol[
*Where the blocking moved to.* HTTP/2 removed head-of-line blocking *at the HTTP layer*: ten
streams share one TCP connection and their frames interleave. But TCP itself still promises
*one ordered byte stream*. If a single TCP segment is lost, the kernel holds back every byte
that arrived after it --- including bytes belonging to the nine streams that were never
affected --- until the missing segment is retransmitted. So on a lossy network, HTTP/2 can
be *worse* than HTTP/1.1 with 6 connections, because 6 connections mean a loss stalls only
one sixth of the page.

*Why the fix could not be in TCP.* TCP lives in the kernel and in every middlebox (NAT,
firewall, load balancer) on the path. A new TCP option takes a decade to deploy, and boxes
that do not understand it often drop the traffic. This is *protocol ossification*.

*Why UDP.* QUIC is built *on top of* UDP in user space. To the network it is ordinary UDP
that middleboxes already pass. Inside, QUIC re-implements what TCP gave up:

#table(columns: 2, align: (left, left),
  [Per-stream ordering], [loss on stream 3 stalls only stream 3; streams 1 and 5 keep delivering],
  [Handshake merged with TLS 1.3], [1 RTT to first byte instead of 3, and 0-RTT on resumption],
  [Connection ID instead of the 4-tuple], [Wi-Fi to mobile switch keeps the connection alive],
  [Encrypted transport headers], [middleboxes cannot inspect or ossify them],
  [Updatable in user space], [ships with the browser, not with the kernel],
)

*The trade-off to name.* QUIC costs more CPU (encryption and packet handling happen in user
space, not in NIC offload), UDP is throttled or blocked on some corporate networks, and
tooling is younger. Deployments therefore keep HTTP/2 as a fallback via `Alt-Svc`.
#ans[the blocking that remained was TCP's, and TCP could not be changed — so QUIC rebuilt it over UDP]
]

#section[Part 11 — HTTPS and TLS]

#diagram(height: 5.6cm, caption: "TLS 1.3 handshake: one round trip after TCP, then everything is encrypted")[
  #dnode(0.6cm, 0pt,    14.8cm, 0.68cm, "0   TCP 3-way handshake completes   (1 RTT — TLS has not started yet)")
  #dnode(0.6cm, 0.78cm, 14.8cm, 0.68cm, "1   client → server   ClientHello:  TLS version, cipher list, a key share", fill: rgb("#e2ecf3"))
  #dnode(0.6cm, 1.56cm, 14.8cm, 0.68cm, "2   server → client   ServerHello:  chosen cipher, its own key share")
  #dnode(0.6cm, 2.34cm, 14.8cm, 0.68cm, "3   server → client   Certificate + signature   (now encrypted)", fill: rgb("#e2ecf3"))
  #dnode(0.6cm, 3.12cm, 14.8cm, 0.68cm, "4   both sides derive the same symmetric key from the two key shares")
  #dnode(0.6cm, 3.90cm, 14.8cm, 0.68cm, "5   client checks the certificate chain up to a trusted root CA", fill: rgb("#e2ecf3"))
  #dnode(0.6cm, 4.68cm, 14.8cm, 0.68cm, "6   client → server   Finished, then the HTTP request — all symmetric from here")
  #place(line(start: (0.2cm, 0.2cm), end: (0.2cm, 5.1cm),
    stroke: (paint: rgb("#6b6b6b"), thickness: 0.8pt)))
]

#table(columns: 3, align: (left, left, left),
  [], [*Asymmetric (public key)*], [*Symmetric*],
  [Keys], [a public and a private key], [one shared secret],
  [Speed], [slow], [fast],
  [Used in TLS for], [proving identity and agreeing on a secret], [encrypting all the actual data],
)

That split is the whole design of TLS: *use slow public-key maths once, to agree on a fast
shared key.*

#tier-header(2)

#ex(17, tier: 2, asked: "SCB · pattern")[
What does a certificate actually prove, and what stops an attacker from simply copying one?
]
#sol[
*What it contains.* The domain name, the server's *public key*, validity dates, the issuing
CA, and the CA's *signature over all of that*.

*What it proves.* That a certificate authority the client already trusts has vouched that
this public key belongs to this domain name. Nothing more --- it does not prove the site is
honest or the company is good.

*Why copying it is useless.* The certificate is public; anyone can download it. But the
matching *private key* never leaves the real server. During the handshake the server must
*sign* handshake data with that private key. An attacker with a copied certificate cannot
produce that signature, so the client rejects the connection.

*The chain.* Browsers ship with root CA public keys. A site certificate is signed by an
intermediate, the intermediate by a root. The client verifies each link. A self-signed
certificate fails only because no trusted root vouches for it --- the encryption itself is
identical.
#ans[it binds a domain name to a public key, signed by a trusted CA; the private key cannot be copied]
]

#trap[
"HTTPS encrypts everything." Not quite. The URL path, headers, cookies and body *are*
encrypted. But the *destination IP*, the *port*, the *size and timing* of packets, and ---
unless Encrypted Client Hello is in use --- the *server name* in the TLS SNI field are
visible to anyone on the path. DNS lookups too, unless DoH or DoT is used. So an observer
often knows *which site* you visited, just not *what you did* there.
]

#section[Part 12 — Cookies, sessions and CORS]

#table(columns: 3, align: (left, left, left),
  [*Attribute*], [*Effect*], [*Attack it blunts*],
  [`HttpOnly`], [JavaScript cannot read the cookie], [XSS stealing the session],
  [`Secure`], [sent only over HTTPS], [interception on plain HTTP],
  [`SameSite=Lax`], [not sent on cross-site POSTs; sent on top-level navigations], [CSRF],
  [`SameSite=Strict`], [never sent on any cross-site request], [CSRF, at the cost of usability],
  [`Max-Age` / `Expires`], [how long it lives], [stale long-lived sessions],
  [`Domain` / `Path`], [which requests carry it], [over-sharing across subdomains],
)

#table(columns: 4, align: (left, left, left, left),
  [], [*Server session + cookie*], [*JWT in a header*], [*JWT in a cookie*],
  [State lives], [on the server], [in the token], [in the token],
  [Revoke instantly], [easy --- delete the session], [hard --- needs a blocklist], [hard],
  [Scales across servers], [needs shared storage], [no shared storage needed], [no shared storage],
  [Sent automatically], [yes], [no --- the code must attach it], [yes],
  [CSRF exposure], [yes, needs `SameSite`], [low], [yes, needs `SameSite`],
)

#tier-header(1)

#ex(18, tier: 1, asked: "Cognizant · pattern")[
A login endpoint replies with `Set-Cookie: sid=abc123`. Name three attributes that should be
added and say what each one stops.
]
#sol[
#table(columns: 3, align: (left, left, left),
  [*Add*], [*Effect*], [*Attack it blunts*],
  [`HttpOnly`], [`document.cookie` cannot see it], [an XSS script stealing the session],
  [`Secure`], [the cookie is sent only over HTTPS], [reading it off a plain-HTTP request],
  [`SameSite=Lax`], [not attached to cross-site POSTs], [CSRF --- another site posting as the user],
)

Two more worth naming: `Max-Age` so an abandoned session expires, and a narrow `Path` or
`Domain` so the cookie is not broadcast to every subdomain.

The final header: `Set-Cookie: sid=abc123; HttpOnly; Secure; SameSite=Lax; Max-Age=3600;
Path=/`.
#ans[`HttpOnly` (XSS), `Secure` (plain HTTP), `SameSite` (CSRF)]
]

#tier-header(2)

#ex(19, tier: 2, asked: "LINE MAN · pattern")[
A browser app on `app.example.com` calls an API on `api.example.com` and the browser blocks
the response. The same call works from `curl`. Explain, and list what the server must send.
]
#sol[
*Why curl works.* CORS is enforced by *browsers*, not by servers or by the network. `curl`
has no same-origin policy, so it never checks.

*Why the browser blocks.* An origin is (scheme, host, port). `app.example.com` and
`api.example.com` are different hosts, so they are different origins. The browser sends the
request but refuses to hand the response to JavaScript unless the server opts in.

*The preflight.* For a non-simple request (a custom header such as `Authorization`, or
`Content-Type: application/json`) the browser first sends an `OPTIONS` request carrying
`Origin`, `Access-Control-Request-Method` and `Access-Control-Request-Headers`.

*What the server must answer.*
#table(columns: 2, align: (left, left),
  [`Access-Control-Allow-Origin: https://app.example.com`], [the exact origin (not `*` if credentials are used)],
  [`Access-Control-Allow-Methods: GET, POST, PUT`], [allowed verbs],
  [`Access-Control-Allow-Headers: Content-Type, Authorization`], [allowed request headers],
  [`Access-Control-Allow-Credentials: true`], [only if cookies must be sent],
  [`Access-Control-Max-Age: 600`], [cache the preflight for 10 minutes],
)

*The trap inside the trap.* `Access-Control-Allow-Origin: *` together with
`Access-Control-Allow-Credentials: true` is rejected by browsers, because it would let *any*
site read authenticated responses. With credentials you must echo one exact origin.
#ans[same-origin policy; the server must return the `Access-Control-Allow-` headers, and answer the OPTIONS preflight]
]

#subsection[Pushing data to a browser]

#table(columns: 4, align: (left, left, left, left),
  [], [*Polling*], [*Server-Sent Events*], [*WebSocket*],
  [Direction], [client asks], [server to client only], [both ways],
  [Transport], [ordinary HTTP], [one long-lived HTTP response], [HTTP upgrade, then its own framing],
  [Reconnect], [trivial], [built in], [you write it],
  [Good for], [rare updates], [feeds, notifications, progress], [chat, games, live collaboration],
  [Cost], [wasted requests], [cheap], [a held connection per client],
)

#section[Practice]

#practice(tier: 1, time: "18 minutes")[
1. List four guarantees TCP gives that UDP does not.
2. A client's ISN is 3000 and it sends 400 bytes after the handshake. What ack number does
   the server return?
3. Which is 401 and which is 403: "your token expired", "you are not an admin"?
4. A 500-byte frame on a 2 Mbps link with RTT 12 ms. Give $T_t$ and the stop-and-wait
   utilisation.
5. What is the difference between `Cache-Control: no-cache` and `no-store`?
6. Name the port and transport for DNS, HTTPS, SSH and DHCP.
7. Why does a 304 response have no body?
8. `ssthresh` is 8 and `cwnd` is 1. Give `cwnd` for the first 6 RTTs with no loss.
]

#key[
1. Ordered delivery, retransmission of lost data, duplicate removal, flow control (and
   congestion control --- any four).
2. Handshake consumes one number, so data occupies 3001 to 3400. The server acks the *next*
   byte expected: *3401*.
3. Expired token = *401* (not authenticated). Not an admin = *403* (authenticated, not
   allowed).
4. $T_t = (500 times 8)\/(2 times 10^6) = 4000\/2000000 = 2$ ms.
   $U = 2\/(2+12) = 2\/14 = 14.29%$.
5. `no-cache` = store it, but check with the server before each reuse (a conditional
   request). `no-store` = never write it down at all.
6. DNS 53 UDP (TCP for large answers), HTTPS 443 TCP (UDP for HTTP/3), SSH 22 TCP,
   DHCP 67/68 UDP.
7. Because the client already has the body. 304 means "your cached copy is current" --- the
   whole point is to save the bytes.
8. 1, 2, 4, 8 (slow start; at 8 it meets `ssthresh`), then congestion avoidance: 9, 10.
]

#practice(tier: 2, time: "22 minutes")[
1. A 1 Gbps link has RTT 100 ms. Give the BDP in bytes, and the window needed to fill it.
   Is a 16-bit window field enough?
2. `ssthresh` = 32, `cwnd` = 1, timeout at the end of RTT 8. Give `cwnd` for RTTs 1 to 12.
3. A monitoring dashboard opens a new HTTPS connection per metric, 40 metrics, once a
   second. RTT is 50 ms. Estimate the wasted time per second and name two fixes.
4. Explain why `POST` is not idempotent but `PUT` is, with a shopping-cart example.
5. A service sees thousands of sockets in `CLOSE_WAIT`. Where is the bug?
]

#key[
1. $"BDP" = (10^9 times 0.1)\/8 = 12{,}500{,}000$ bytes = 12.5 MB. A 16-bit field caps at
   65,535 bytes, which is *190 times too small* --- window scaling is mandatory here.
   Without it, throughput is $(65535 times 8)\/0.1 = 5.24$ Mbps on a 1 Gbps link.
2. Slow start 1, 2, 4, 8, 16, 32 for RTTs 1--6. At 32 it equals `ssthresh`, so congestion
   avoidance: RTT 7 = 33, RTT 8 = 34. Timeout at the end of RTT 8:
   $"ssthresh" = 34\/2 = 17$, $"cwnd" = 1$. RTTs 9--12: 1, 2, 4, 8.
3. Each new HTTPS connection costs TCP (1 RTT) + TLS 1.3 (1 RTT) = 2 RTT = 100 ms before any
   request goes out. 40 connections per second $arrow.r$ about 4 seconds of handshake work
   per second of wall clock (spread across parallel sockets, but it is real CPU and latency,
   and TLS handshakes are expensive). *Fix 1:* one keep-alive connection reused for all 40,
   or an HTTP/2 connection multiplexing them --- handshake cost goes to zero after the
   first. *Fix 2:* batch the 40 metrics into one request. Either fix also avoids 40
   congestion windows restarting from slow start every second.
4. `PUT /cart/item/7` with `{qty: 3}` sets the quantity to 3. Send it five times and the
   quantity is still 3 --- same final state, so idempotent. `POST /cart/items` with
   `{item: 7, qty: 3}` *appends* a line. Send it five times and the cart holds five lines.
   Different state each time, so not idempotent.
5. In the *application*, not the network. `CLOSE_WAIT` means the kernel received the peer's
   FIN and is waiting for the program to call `close()` on the socket. Thousands of them
   means a code path --- usually an error or timeout branch --- returns without closing the
   socket or releasing it back to the pool. These never expire on their own; the process
   will run out of file descriptors.
]

#practice(tier: 3, time: "25 minutes")[
1. An API behind a CDN serves a 200 with `Cache-Control: max-age=86400` and no `Vary`
   header. Users on mobile start receiving the desktop version. What went wrong and what
   are two fixes?
2. Two datacentres 200 ms apart copy a 10 GB file over one TCP connection and get 8 Mbps.
   The link is 1 Gbps. Diagnose it and give the numbers.
3. Why does TCP pick a *random* initial sequence number instead of always starting at 0?
4. An HTTP/2 page loads slower than the same page on HTTP/1.1 for users on a train. Explain.
]

#key[
1. *What went wrong.* The CDN caches one object per URL. The origin returned different
   content for the same URL depending on the `User-Agent`, but did not tell the cache that.
   The first request (a desktop user) filled the cache, and every mobile user for the next
   24 hours got that copy.
   *Fix 1:* send `Vary: User-Agent` so the cache keys on that header too. It works but
   fragments the cache badly, because there are thousands of user-agent strings.
   *Fix 2 (better):* stop varying the response by device. Serve one response and let the
   client adapt (responsive CSS, client-side logic), or use *different URLs* for genuinely
   different content. A cache key should be visible in the URL.
2. *Diagnosis.* Throughput is window / RTT, and 8 Mbps at 200 ms RTT implies a window of
   $ (8 times 10^6 times 0.2)\/8 = 200{,}000 $ bytes --- roughly a 200 KB window, far below
   what the path needs.
   *What the path needs:* $"BDP" = (10^9 times 0.2)\/8 = 25{,}000{,}000$ bytes = 25 MB.
   *The gap:* the window is 125 times too small, and the achieved 8 Mbps is 0.8% of the
   link. *Causes, in the order to check them:* window scaling disabled or clamped by a
   middlebox; a socket buffer limit capping the window; or loss forcing the congestion
   window down (at 200 ms RTT, Reno needs a very long time to reopen after each loss ---
   this is exactly what CUBIC and BBR were built for). *Fixes:* enable window scaling and
   raise the buffer limits, switch the congestion algorithm, or --- simplest for a bulk copy
   --- run several parallel TCP streams so the windows add up.
3. Two reasons.
   *Security.* If the ISN were predictable, an off-path attacker who knows the 4-tuple could
   guess valid sequence numbers and inject data or a forged RST into an existing connection.
   A random ISN makes that guess a 1-in-$2^32$ shot.
   *Correctness.* A delayed segment from a *previous* connection with the same 4-tuple could
   otherwise land inside the new one with a plausible sequence number and be accepted as
   real data. Random ISNs plus `TIME_WAIT` plus timestamps together make that essentially
   impossible.
4. A train means *packet loss and variable delay*, not just low bandwidth. HTTP/2 puts every
   stream on *one* TCP connection. TCP guarantees one ordered byte stream, so a single lost
   segment stalls the delivery of *all* streams until it is retransmitted --- one loss, the
   whole page waits. HTTP/1.1 with 6 connections spreads the risk: a loss stalls only the
   assets on that one connection, and the other five keep going. HTTP/3 over QUIC is the
   real fix, because QUIC tracks loss *per stream*, so only the affected stream waits.
]

#section[Rapid fire — one-line answers]

#table(columns: 2, align: (left, left),
  [*Question*], [*Answer*],
  [What identifies a TCP connection?], [the 4-tuple: src IP, src port, dst IP, dst port],
  [TCP vs UDP header size?], [20 bytes minimum (up to 60) vs 8 bytes, fixed],
  [Does UDP keep message boundaries?], [yes --- TCP does not; TCP is a byte stream],
  [Why 3 messages to open but 4 to close?], [the server's SYN and ACK merge; the two FINs cannot],
  [What does the ack number mean?], [the *next* byte expected, not the last byte received],
  [Do SYN and FIN consume a sequence number?], [yes, one each],
  [What is `TIME_WAIT` for?], [protect the final ACK and let stale duplicates die (2 × MSL)],
  [Many `CLOSE_WAIT` sockets means?], [an application bug --- `close()` was never called],
  [What is RST?], [abort the connection now; no graceful close, no `TIME_WAIT`],
  [Fast retransmit trigger, and why 3?], [3 duplicate ACKs; 1 or 2 also come from harmless reordering],
  [What does SACK add?], [the receiver names the blocks it holds, so only the holes are resent],
  [Flow control vs congestion control?], [protects the receiver's buffer vs protects the network],
  [How much may the sender have in flight?], [min(cwnd, rwnd) unacknowledged bytes],
  [Slow start vs congestion avoidance growth?], [cwnd doubles per RTT vs cwnd plus 1 per RTT],
  [Reaction to a timeout?], [ssthresh = cwnd/2, cwnd = 1, back to slow start],
  [Reaction to 3 duplicate ACKs?], [ssthresh = cwnd/2, cwnd = ssthresh, keep going],
  [Nagle plus delayed ACK causes?], [a stall of about 200 ms; fix with one write, or TCP_NODELAY],
  [How is a zero window escaped?], [the persist timer sends a 1-byte window probe],
  [BDP formula, and throughput from a window?], [rate × RTT ÷ 8 bytes; throughput $approx$ window ÷ RTT],
  [Why window scaling?], [the 16-bit window field caps at 65,535 bytes],
  [Karn's rule?], [never take an RTT sample from a retransmitted segment],
  [When is UDP the right choice?], [DNS, voice, video, gaming, DHCP, QUIC],
  [Safe vs idempotent methods?], [safe: GET, HEAD, OPTIONS. Idempotent: those plus PUT and DELETE. POST is neither.],
  [301 vs 302?], [301 permanent and cached hard; 302 temporary],
  [401 vs 403?], [401 = not authenticated; 403 = authenticated but not allowed],
  [304 means?], [your cached copy is still valid --- no body is sent],
  [`no-cache` vs `no-store`?], [revalidate before every use vs never write it down at all],
  [HTTP/2's gain, and what blocking remains?], [multiplexing plus HPACK; TCP-level head-of-line blocking remains],
  [HTTP/3 runs on what, and why?], [QUIC over UDP --- loss on one stream no longer stalls the others],
  [Who enforces CORS?], [the browser --- never the server, never curl],
)

#revision[
*TCP vs UDP.* TCP: connection, ordered, reliable, flow + congestion control, byte stream,
20-byte header. UDP: none of that, message boundaries kept, 8-byte header.

*4-tuple.* src IP, src port, dst IP, dst port. One server port holds millions of
connections because the client's source port varies.

*Handshake.* SYN (seq=x) $arrow.r$ SYN,ACK (seq=y, ack=x+1) $arrow.r$ ACK (seq=x+1,
ack=y+1). SYN and FIN each consume one sequence number. ack = *next byte expected*.

*Close.* FIN $arrow.r$ ACK $arrow.r$ FIN $arrow.r$ ACK. Closer waits 2 × MSL in
`TIME_WAIT`. `TIME_WAIT` piling up = pool your connections. `CLOSE_WAIT` piling up = your
code forgot `close()`.

*Congestion (Reno).* Slow start doubles until `ssthresh`; then +1 per RTT.
3 dup ACKs: halve and continue. Timeout: `ssthresh` = cwnd/2, `cwnd` = 1.

*Arithmetic.*
$T_t = L\/R$. $U_"stop-and-wait" = T_t\/(T_t + "RTT")$. $U_N = N T_t\/(T_t+"RTT")$.
$N_(100%) = 1 + "RTT"\/T_t$. $"BDP" = "rate" times "RTT" \/ 8$ bytes.
throughput $approx$ window / RTT. Window field is 16 bits $arrow.r$ 65,535 $arrow.r$ needs
window scaling on fast, long links.

*Nagle + delayed ACK* deadlock $arrow.r$ 200 ms stalls $arrow.r$ one write, or
`TCP_NODELAY`.

*HTTP methods.* Safe: GET, HEAD, OPTIONS. Idempotent: those plus PUT and DELETE. POST is
neither.

*Status codes.* 200 ok, 201 created, 204 empty, 301 permanent, 302 temporary, 304 use your
cache, 400 malformed, 401 who are you, 403 not allowed, 404 missing, 409 conflict,
429 slow down, 500 server bug, 502 bad upstream, 503 overloaded, 504 upstream timeout.

*Caching.* `max-age` saves the round trip. `ETag` + `If-None-Match` $arrow.r$ 304 saves only
the bytes. `Vary` adds to the cache key. `no-cache` = revalidate; `no-store` = never store.

*Versions.* HTTP/1.1 = text, one request at a time. HTTP/2 = binary, multiplexed on one TCP
connection, HPACK. HTTP/3 = same but over QUIC/UDP, so loss no longer stalls every stream.

*TLS.* Asymmetric once to agree a key, symmetric for the data. TLS 1.3 = 1 RTT.
A certificate binds a domain to a public key, signed by a CA.

*Two sentences that answer half the follow-ups.*
"TCP gives you an ordered byte stream, not messages --- framing is your job."
"Flow control protects the receiver; congestion control protects the network."
]

]
