#import "../../shared/lib/style.typ": *

#chapter(num: 4, title: "OS: File Systems, I/O & Storage", tagline: "Turning a spinning platter into a name you can type")[

#section[The one idea]

#formulas(title: "The whole chapter in one box")[
A disk is a very long numbered array of fixed-size *blocks*. It has no idea what a file is,
what a folder is, or what a name is. Everything you think of as a file system is software
that maintains three mappings on top of that array:

+ *name* $arrow.r$ *inode number* — this is what a *directory* is. A directory is just a
  file whose contents are `(name, inode number)` pairs.
+ *inode number* $arrow.r$ *inode* — a fixed-size record holding the file's metadata and
  the addresses of its data blocks.
+ *inode* $arrow.r$ *list of block numbers* — the actual bytes.

Vocabulary you must be able to say instantly:

- *Block (cluster)* — the smallest unit the file system allocates. Typically 4 KB.
- *Sector* — the smallest unit the *hardware* reads or writes. 512 B or 4096 B.
- *Inode* — the metadata record: size, owner, permissions, timestamps, link count, and
  block pointers. *The file name is NOT in the inode.*
- *Directory entry (dentry)* — a `(name, inode number)` pair inside a directory file.
- *Superblock* — the record describing the whole file system: block size, counts, where
  the inode table starts.
- *Mount* — grafting one file system's root onto a directory of another.

The single most-asked fact in this chapter: *the file name lives in the directory, not in
the inode.* Every question about hard links, renames and permissions falls out of that.
]

#trick[
Whenever a file-system question confuses you, ask: "which of the three mappings is this
question about — name to inode, inode to metadata, or inode to blocks?" Almost every
question is about exactly one of them.
]

#diagram(height: 5.1cm, caption: "The three mappings. Follow the arrows to open /home/asha/notes.txt. Notice that the NAME appears only on the left; the inode never learns it.")[
  #dnode(0pt, 0.15cm, 4.6cm, 0.6cm, "DIRECTORY /home/asha", fill: white)
  #dnode(0pt, 0.85cm, 2.9cm, 0.6cm, "notes.txt", fill: rgb("#f7efe4"))
  #dnode(2.9cm, 0.85cm, 1.7cm, 0.6cm, "1204", fill: rgb("#eef3f7"))
  #dnode(0pt, 1.55cm, 2.9cm, 0.6cm, "photo.jpg", fill: rgb("#f7efe4"))
  #dnode(2.9cm, 1.55cm, 1.7cm, 0.6cm, "988", fill: rgb("#eef3f7"))
  #dnode(0pt, 2.25cm, 2.9cm, 0.6cm, "backup.txt", fill: rgb("#f7efe4"))
  #dnode(2.9cm, 2.25cm, 1.7cm, 0.6cm, "1204", fill: rgb("#eef3f7"))
  #dnode(0pt, 3.0cm, 4.6cm, 0.9cm, "a directory is just a FILE\nfull of (name, inode no.) pairs", fill: rgb("#fafbfc"))

  #darrow(4.65cm, 1.15cm, 6.35cm, 2.0cm, label: "1204")
  #darrow(4.65cm, 2.55cm, 6.35cm, 2.3cm, label: "1204")

  #dnode(6.4cm, 0.85cm, 4.0cm, 0.6cm, "INODE TABLE", fill: white)
  #dnode(6.4cm, 1.55cm, 4.0cm, 2.2cm, "inode 1204\nmode rw-r--r--\nsize 8192\nLINK COUNT = 2\nmtime, ctime\nblock ptrs ->", fill: rgb("#dce9f2"))
  #dnode(6.4cm, 3.95cm, 4.0cm, 0.9cm, "no name here —\nthat is the whole trick", fill: rgb("#fdf4f4"))

  #darrow(10.45cm, 2.6cm, 11.95cm, 1.9cm)
  #darrow(10.45cm, 2.6cm, 11.95cm, 2.7cm)
  #darrow(10.45cm, 2.6cm, 11.95cm, 3.5cm)
  #dnode(12.0cm, 0.85cm, 4.3cm, 0.6cm, "DATA BLOCKS", fill: white)
  #dnode(12.0cm, 1.55cm, 4.3cm, 0.7cm, "block 90311", fill: rgb("#f7efe4"))
  #dnode(12.0cm, 2.35cm, 4.3cm, 0.7cm, "block 90312", fill: rgb("#f7efe4"))
  #dnode(12.0cm, 3.15cm, 4.3cm, 0.7cm, "block 90790", fill: rgb("#f7efe4"))
  #dnode(12.0cm, 4.0cm, 4.3cm, 0.85cm, "the actual bytes\nof the file", fill: rgb("#fafbfc"))
]

#note[
Two names, `notes.txt` and `backup.txt`, point at inode 1204. That is a *hard link*, and
it is why the inode carries a *link count* of 2. Delete either name and the count drops to
1; the bytes survive. Delete both and the count reaches 0 and the blocks are freed.
]

#section[A file, and what the OS keeps about it]

#subsection[File attributes (what is in an inode)]

#table(columns: (auto, auto),
  [*Attribute*], [*Note*],
  [Type], [regular file, directory, symlink, device, pipe, socket],
  [Size in bytes], [Not the same as blocks used — see sparse files below],
  [Owner UID, group GID], [Used by the permission check],
  [Permission bits], [`rwx` for user, group, other],
  [Link count], [How many directory entries point here. Reaches 0 -> the file is really deleted],
  [Timestamps], [`atime` (accessed), `mtime` (contents modified), `ctime` (inode changed)],
  [Block pointers], [Direct, single, double and triple indirect — the heart of it],
)

#trap[
"`ctime` is the creation time." *No.* On Unix `ctime` is *inode change time* — it moves when
you `chmod` a file, even though the contents did not change. Classic Unix has no creation
time at all; modern file systems add `btime`/`crtime` as an extra.
]

#subsection[The open-file tables]

When a process calls `open()`, three tables come into play. Interviewers ask this because
it explains why `fork()` makes a child share the parent's file *position*.

#table(columns: (auto, auto, auto),
  [*Table*], [*One per*], [*Holds*],
  [File descriptor table], [process], [fd number -> pointer into the open-file table],
  [Open-file table (system-wide)], [`open()` call], [current *offset*, access mode, pointer to the inode],
  [In-memory inode table], [file], [one cached copy of the inode, with a reference count],
)

#note[
Two independent `open()` calls on the same file get *two* open-file entries, so they have
*two separate offsets* but *one* inode. A `fork()` or `dup()` copies the *descriptor*, so
parent and child point at the *same* open-file entry and therefore *share one offset* —
when the child reads 10 bytes, the parent's next read starts 10 bytes later. That surprise
is the whole reason the middle table exists.
]

#section[Directories and path resolution]

A directory is a file. Its contents are entries. Resolving `/home/asha/notes.txt` is a
loop, and you should be able to narrate it.

#ex(1, tier: 1, asked: "Infosys · pattern")[
Walk through exactly what the kernel does to open `/home/asha/notes.txt`. How many disk
reads at minimum, assuming nothing is cached?
]
#sol[
Step 1 — start at the root inode. Its number is fixed (2 on ext-family file systems), so
no lookup is needed. *Read the root inode.* (1)

Step 2 — read the root directory's data block. Search it for the name `home`. Get an inode
number, say 431. (2)

Step 3 — read inode 431. Check it is a directory and that you have execute (`x`) permission
on it. (3)

Step 4 — read inode 431's data block. Search for `asha`. Get inode number 902. (4)

Step 5 — read inode 902, check permission, read its data block, search for `notes.txt`.
(5, 6)

Step 6 — read the inode of `notes.txt`. Check read permission. (7)

Now, and only now, can data blocks be read.
#ans[7 disk reads before a single byte of the file is touched — one inode read plus one directory-block read per path component. This is why the *dentry cache* exists, and why deep paths cost more than shallow ones.]

The permission rule worth stating: you need *execute* permission on every directory in the
path (that is what `x` means on a directory — "may traverse"), and then the appropriate
permission on the file itself.
]

#subsection[Directory structures, oldest to newest]

#table(columns: (auto, auto),
  [*Structure*], [*Problem it has, or fixes*],
  [Single level — one flat namespace], [Two users cannot both have `notes.txt`.],
  [Two level — one directory per user], [Fixes name clashes; no grouping within a user.],
  [Tree], [What everyone uses. One parent per file; a path is unique.],
  [Acyclic graph (hard links)], [A file can have several names. Deletion needs a *link count*.],
  [General graph (allows cycles)], [Needs garbage collection to find unreachable loops. Avoided; this is why Unix forbids hard links to directories.],
)

#section[Hard links and soft links]

#formulas(title: "The difference in one line each")[
- A *hard link* is another directory entry pointing at the *same inode*. It increments the
  inode's link count. All hard links are equal — there is no "original".
- A *soft link* (symbolic link) is a tiny *separate file* whose contents are a *path
  string*. It has its own inode. It does not affect the target's link count.

Consequences that get asked:
- Delete the "original": hard link still works (link count only dropped from 2 to 1). Soft
  link *breaks* (dangling).
- Hard links cannot cross file systems (inode numbers are only meaningful within one file
  system). Soft links can, because they store a path.
- Hard links to directories are forbidden (they would create cycles). Soft links to
  directories are fine.
- `ls -i` shows the inode number: two hard links show the *same* number.
]

#ex(2, tier: 1, asked: "TCS NQT · pattern")[
Run this and predict the output before you read it:

```
echo "hello" > original.txt
ln    original.txt hard.txt      # hard link
ln -s original.txt soft.txt      # soft link
ls -li
rm original.txt
ls -li
cat hard.txt
cat soft.txt
```
]
#sol[
Real output from a Linux shell:

```
8132533 -rw-rw-r-- 2 zayed zayed  6 hard.txt
8132533 -rw-rw-r-- 2 zayed zayed  6 original.txt
8132535 lrwxrwxrwx 1 zayed zayed 12 soft.txt -> original.txt
```
Read the columns. `hard.txt` and `original.txt` share inode *8132533* and both show a link
count of *2*. `soft.txt` has its own inode *8132535*, link count 1, and a size of *12
bytes* — which is exactly the length of the string `original.txt`. That is all a symlink
contains.

After `rm original.txt`:

```
8132533 -rw-rw-r-- 1 zayed zayed  6 hard.txt
8132535 lrwxrwxrwx 1 zayed zayed 12 soft.txt -> original.txt
```
The link count on inode 8132533 fell from 2 to 1. The inode and its data blocks are still
alive.

```
$ cat hard.txt
hello
$ cat soft.txt
cat: soft.txt: No such file or directory
```
#ans[The hard link still reads "hello"; the soft link is now dangling and fails. `rm` does not delete a file — it deletes a *name* and decrements the link count. The file dies only when the count reaches 0 *and* no process still has it open.]
]

#trap[
"`rm` frees the disk space." Only if the link count hits 0 *and* no process has the file
open. A running server whose log file you deleted keeps the blocks alive until it closes
the file — which is why `df` can show a full disk while `du` shows very little. The fix is
to restart the process or truncate the file, not to delete harder.
]

#section[How a file's blocks are found]

This is the core of the chapter. Three schemes, and you must be able to compare them on
four axes: sequential speed, random access speed, space overhead, and external
fragmentation.

#subsection[1. Contiguous allocation]

Store the file in consecutive blocks. The directory entry holds `(start block, length)`.

#table(columns: (auto, auto),
  [*Good*], [*Bad*],
  [Best possible sequential read — one seek, then stream.], [External fragmentation; needs compaction.],
  [$O(1)$ random access: block $k$ is at $"start" + k$.], [You must know the final size at creation, or the file cannot grow.],
  [Tiny metadata: two numbers.], [Deleting files leaves holes of awkward sizes.],
)

#subsection[2. Linked allocation]

Each block stores a pointer to the next block. The directory entry holds the first (and
often the last) block number.

#table(columns: (auto, auto),
  [*Good*], [*Bad*],
  [No external fragmentation; any free block works.], [Random access is $O(k)$ — to read block 500 you must read 500 blocks.],
  [Files grow freely.], [The pointer eats space *inside* every data block, so block size is no longer a power of two for data.],
  [], [One corrupted pointer loses the rest of the file.],
)

#ex(3, tier: 1, asked: "Wipro · pattern")[
Block size is 4 KB. A pointer is 4 bytes. A file is exactly 2 MB. How many blocks does it
need under (a) contiguous, (b) linked allocation?
]
#sol[
*(a) Contiguous.* Every byte of a block is data.
$ 2 "MB" = 2 times 1024 times 1024 = 2,097,152 "bytes" $
$ 2097152 \/ 4096 = 512 "blocks" $

*(b) Linked.* Each block gives up 4 bytes to the "next" pointer:
$ "usable per block" = 4096 - 4 = 4092 "bytes" $
$ 2097152 \/ 4092 = 512.5 arrow.r "round up" arrow.r 513 "blocks" $
#ans[(a) 512 blocks (b) 513 blocks — one extra, purely to carry pointers.]

One extra block sounds harmless. The real cost is not space, it is *time*: to read byte
2,000,000 under linked allocation you must first read 488 earlier blocks. Under contiguous
allocation you compute the block number and seek there once.
]

#subsection[3. FAT — linked allocation with the links pulled out]

Keep all the "next block" pointers in one table at the front of the disk, indexed by block
number. Following a chain now walks the table in memory, not the disk.

#ex(4, tier: 1, asked: "Capgemini · pattern")[
A FAT looks like this (`EOF` marks the end of a chain, `0` marks a free block):

#table(columns: (auto,auto,auto,auto,auto,auto,auto,auto,auto),
  [*block*], [5],[9],[12],[17],[23],[30],[31],[44],
  [*next*],  [44],[23],[0],[9],[5],[0],[EOF],[31],
)

A directory entry says `report.doc` starts at block 17. List its blocks. Then say how big
the FAT is for a 500 GB disk with 4 KB blocks and 4-byte entries, and why that is a
problem.
]
#sol[
*Chain:* start at 17.
$ 17 arrow.r 9 arrow.r 23 arrow.r 5 arrow.r 44 arrow.r 31 arrow.r "EOF" $
So the file occupies blocks *17, 9, 23, 5, 44, 31* — six blocks. Blocks 12 and 30 have
`next = 0`, meaning free.

*FAT size:*
$ "blocks on disk" = (500 times 1024^3) / 4096 = 131,072,000 "blocks" $
$ "FAT size" = 131072000 times 4 "bytes" = 524,288,000 "bytes" = 500 "MB" $
#ans[Blocks 17, 9, 23, 5, 44, 31. The FAT itself would be 500 MB — and to be useful for random access it must be held in RAM, which is why FAT does not scale to large disks.]

Note the pattern: FAT size grows linearly with disk size, and it is a *whole-disk*
structure. An inode, by contrast, is *per file* — you only load the inodes of files you
actually open. That is the structural reason inodes won.
]

#subsection[4. Indexed allocation — the inode]

Each file gets an *index block* holding pointers to its data blocks. Random access is one
extra read, and there is no external fragmentation. The only question is what to do when a
file is bigger than one index block can describe — and the answer is *indirection*.

#diagram(height: 8.6cm, caption: "A Unix inode. 12 direct pointers reach the first 48 KB; three levels of indirection reach 4 TB. Small files cost one read; huge files cost four.")[
  #dnode(0pt, 0.2cm, 4.2cm, 3.3cm, "INODE\n\nmode, uid, gid\nsize, link count\natime, mtime, ctime", fill: rgb("#dce9f2"))

  #dnode(0pt, 3.6cm, 4.2cm, 0.6cm, "direct[0..11]  (12 ptrs)", fill: rgb("#f7efe4"))
  #dnode(0pt, 4.3cm, 4.2cm, 0.6cm, "single indirect", fill: rgb("#eef3f7"))
  #dnode(0pt, 5.0cm, 4.2cm, 0.6cm, "double indirect", fill: rgb("#eef3f7"))
  #dnode(0pt, 5.7cm, 4.2cm, 0.6cm, "triple indirect", fill: rgb("#eef3f7"))

  #darrow(4.25cm, 3.9cm, 5.75cm, 3.9cm)
  #dnode(5.8cm, 3.6cm, 2.6cm, 0.6cm, "12 data blocks", fill: rgb("#f7efe4"))
  #dnode(8.6cm, 3.6cm, 4.0cm, 0.6cm, "= 48 KB", fill: white)

  #darrow(4.25cm, 4.6cm, 5.75cm, 4.6cm)
  #dnode(5.8cm, 4.3cm, 2.6cm, 0.6cm, "1024 ptrs", fill: rgb("#eef3f7"))
  #darrow(8.45cm, 4.6cm, 9.55cm, 4.6cm)
  #dnode(9.6cm, 4.3cm, 2.6cm, 0.6cm, "1024 blocks", fill: rgb("#f7efe4"))
  #dnode(12.4cm, 4.3cm, 3.9cm, 0.6cm, "+ 4 MB", fill: white)

  #darrow(4.25cm, 5.3cm, 5.75cm, 5.3cm)
  #dnode(5.8cm, 5.0cm, 2.6cm, 0.6cm, "1024 ptrs", fill: rgb("#eef3f7"))
  #darrow(8.45cm, 5.3cm, 9.55cm, 5.3cm)
  #dnode(9.6cm, 5.0cm, 2.6cm, 0.6cm, "1024 x 1024", fill: rgb("#f7efe4"))
  #dnode(12.4cm, 5.0cm, 3.9cm, 0.6cm, "+ 4 GB", fill: white)

  #darrow(4.25cm, 6.0cm, 5.75cm, 6.0cm)
  #dnode(5.8cm, 5.7cm, 2.6cm, 0.6cm, "1024 ptrs", fill: rgb("#eef3f7"))
  #darrow(8.45cm, 6.0cm, 9.55cm, 6.0cm)
  #dnode(9.6cm, 5.7cm, 2.6cm, 0.6cm, "1024 cubed", fill: rgb("#f7efe4"))
  #dnode(12.4cm, 5.7cm, 3.9cm, 0.6cm, "+ 4 TB", fill: white)

  #dnode(0pt, 6.7cm, 16.2cm, 1.5cm, "Reads needed to reach one byte (inode already cached): direct = 1  ·  single = 2  ·  double = 3  ·  triple = 4.\nSmall files are cheap ON PURPOSE. Nearly every file on a real machine fits in the 12 direct pointers.", fill: rgb("#fafbfc"))
]

#ex(5, tier: 2, asked: "Grab · pattern")[
Block size 4 KB, pointer size 4 bytes, 12 direct pointers, one single, one double and one
triple indirect pointer. (a) What is the largest file? (b) How many disk reads to fetch the
byte at offset 100,000,000, assuming the inode is cached?
]
#sol[
*Step 1 — pointers per block.*
$ 4096 "bytes" / 4 "bytes per pointer" = 1024 "pointers" $

*Step 2 — blocks reachable at each level.*
#table(columns: (auto, auto, auto),
  [*Level*], [*Blocks reached*], [*Bytes added*],
  [12 direct], [12], [$12 times 4"KB" = 48$ KB],
  [single indirect], [1024], [$1024 times 4"KB" = 4$ MB],
  [double indirect], [$1024^2 = 1,048,576$], [$approx 4$ GB],
  [triple indirect], [$1024^3 = 1,073,741,824$], [$approx 4$ TB],
)

*Step 3 — total.*
$ 12 + 1024 + 1048576 + 1073741824 = 1,074,791,436 "blocks" $
$ times 4096 "bytes" = 4,402,345,721,856 "bytes" approx 4.0039 "TiB" $

*(b) Where does offset 100,000,000 live?*
$ "block number" = floor(100000000 / 4096) = 24414 $
Is 24414 $< 12$? No. Subtract: $24414 - 12 = 24402$.
Is 24402 $< 1024$? No. Subtract: $24402 - 1024 = 23378$.
Is 23378 $< 1024^2 = 1048576$? *Yes* — so it is under the *double* indirect pointer.

Reads: double-indirect block (1), then the inner index block (2), then the data block (3).
#ans[(a) about 4 TiB — exactly 4,402,345,721,856 bytes. (b) 3 reads: double index, inner index, data.]
]

#code(lang: "js", caption: "inode.js — compute the reach of any inode layout")[
```js
function inodeReach(blockSize, ptrSize, direct = 12) {
  const ppb = blockSize / ptrSize;                 // pointers per block
  const blocks = direct + ppb + ppb ** 2 + ppb ** 3;
  return { ppb, blocks, maxBytes: blocks * blockSize };
}
for (const [bs, ps] of [[1024, 4], [4096, 4], [8192, 8]]) {
  const r = inodeReach(bs, ps);
  console.log(`block=${bs}B ptr=${ps}B  ppb=${r.ppb}  maxBytes=${r.maxBytes}  ` +
              `= ${(r.maxBytes / 1024 ** 4).toFixed(4)} TiB`);
}

// which pointer level holds byte `off`, and how many block reads it costs
function locate(off, blockSize = 4096, ptrSize = 4, direct = 12) {
  const ppb = blockSize / ptrSize;
  let b = Math.floor(off / blockSize);
  if (b < direct)      return { level: 'direct', reads: 1 };
  b -= direct;
  if (b < ppb)         return { level: 'single', reads: 2 };
  b -= ppb;
  if (b < ppb * ppb)   return { level: 'double', reads: 3 };
  b -= ppb * ppb;
  if (b < ppb ** 3)    return { level: 'triple', reads: 4 };
  return { level: 'too big', reads: -1 };
}
for (const off of [100, 50_000, 5_000_000, 100_000_000, 40_000_000_000])
  console.log(off, locate(off));
```
]

#note[
Real output from `node inode.js`:
```
block=1024B ptr=4B  ppb=256  maxBytes=17247252480  = 0.0157 TiB
block=4096B ptr=4B  ppb=1024  maxBytes=4402345721856  = 4.0039 TiB
block=8192B ptr=8B  ppb=1024  maxBytes=8804691443712  = 8.0078 TiB
100 { level: 'direct', reads: 1 }
50000 { level: 'single', reads: 2 }
5000000 { level: 'double', reads: 3 }
100000000 { level: 'double', reads: 3 }
40000000000 { level: 'triple', reads: 4 }
```
Look at the middle row versus the last: *doubling the block size to 8 KB and the pointer to
8 bytes doubles the maximum file size*, because pointers per block stayed at 1024 while
each block got twice as big.
]

#trap[
"Bigger blocks are always better." Bigger blocks give faster sequential I/O and reach
bigger files — but internal fragmentation grows with them. With 4 KB blocks a 100-byte file
wastes 3996 bytes; with 64 KB blocks it wastes 65,436 bytes. On a disk with a million tiny
files that is 60 GB of pure waste. State both halves.
]

#subsection[The four schemes, side by side]

#table(columns: (auto, auto, auto, auto, auto),
  [], [*Contiguous*], [*Linked*], [*FAT*], [*Indexed (inode)*],
  [Sequential read], [Best], [Good], [Good], [Good],
  [Random access to block $k$], [$O(1)$], [$O(k)$ disk reads], [$O(k)$ in-RAM steps], [1 to 4 reads],
  [External fragmentation], [Yes], [No], [No], [No],
  [Can the file grow?], [Hard], [Freely], [Freely], [Freely],
  [Metadata cost], [2 numbers], [4 B per block, inside the data], [One table for the whole disk], [One inode per file],
  [Where you see it], [CD-ROM, some real-time systems], [Teaching only], [FAT32, SD cards, USB sticks], [ext4, XFS, APFS, NTFS (variant)],
)

#section[Free space management]

The file system must also know which blocks are free.

#table(columns: (auto, auto, auto),
  [*Method*], [*How*], [*Verdict*],
  [*Bit vector (bitmap)*], [One bit per block: 1 = free, 0 = used.], [Simple; finding a *run* of consecutive free blocks is just a scan for consecutive 1 bits, which hardware does fast. Must be kept in RAM to be quick.],
  [*Linked list of free blocks*], [Each free block points to the next free block.], [Zero extra space, but finding $n$ contiguous blocks is impossible without walking the chain.],
  [*Grouping*], [The first free block holds the addresses of the next $n$ free blocks.], [Finds many free blocks in one read.],
  [*Counting*], [Store `(first free block, run length)` pairs.], [Very compact when free space is clustered — which it usually is.],
)

#ex(6, tier: 1, asked: "Accenture · pattern")[
A 500 GB disk uses 4 KB blocks. How large is the free-space bitmap? Would you keep it in
RAM?
]
#sol[
Step 1 — number of blocks (using $1 "GB" = 1024^3$ bytes):
$ (500 times 1024^3) / 4096 = 131,072,000 "blocks" $

Step 2 — one bit per block:
$ 131072000 "bits" / 8 = 16,384,000 "bytes" $

Step 3 — in MB:
$ 16384000 / 1024^2 = 15.625 "MB" $
#ans[About 15.6 MB. Yes, keep it in RAM — 15 MB is nothing on a modern machine, and a bitmap is useless if every free-block query needs a disk read.]

Compare with the FAT for the same disk: 500 MB. The bitmap is 32 times smaller because it
stores 1 bit per block instead of a 4-byte pointer.
]

#section[Crash consistency and journaling]

#formulas(title: "Why a crash is dangerous")[
Appending one block to a file needs *three* separate writes:
+ mark the block as used in the free bitmap,
+ write the data into the block,
+ update the inode (new block pointer, new size).

A crash between any two of them leaves the disk inconsistent. The two bad outcomes:
- *Lost block* — bitmap says used, no inode points at it. Wasted space; harmless.
- *Double allocation or garbage in a file* — inode points at a block the bitmap still calls
  free, so it may be handed to another file. *Data corruption.* This one is serious.

*Journaling* fixes it: before touching the real structures, write a description of the
whole change to a sequential log, then a *commit* record. Only then apply the change to the
real locations. After a crash, replay committed transactions and discard uncommitted ones.
Recovery becomes reading a small log instead of scanning the entire disk (`fsck`).
]

#table(columns: (auto, auto, auto),
  [*Journal mode*], [*What is logged*], [*Trade-off*],
  [*Writeback*], [Metadata only; data may be written any time.], [Fastest. After a crash, the metadata is consistent but a file may contain stale garbage.],
  [*Ordered* (the usual default)], [Metadata only, but data is forced to disk *before* the metadata that points at it commits.], [Good balance: you never see another file's old bytes.],
  [*Journal (full)*], [Metadata *and* data.], [Safest and slowest — every byte is written twice.],
)

#ex(7, tier: 3, asked: "Amazon · pattern")[
Full journaling writes every byte twice, so you would expect it to halve write throughput.
On a real system it often costs much less than half. Explain why, then explain the one
workload where it really does cost about half.
]
#sol[
*Why it costs less than half.* The journal is written *sequentially* to one contiguous
region. The real update is *random* — inode here, bitmap there, data block somewhere else.
On a spinning disk, a sequential write costs roughly a transfer, while a random write costs
a seek plus a rotation plus a transfer. From our disk model that is about 0.04 ms versus
about 9.2 ms. So the "extra" write is nearly free compared with the one it protects.

There is a second effect: journal entries are batched. Many small updates commit together
in one sequential burst, and the real writes can then be applied lazily and re-ordered into
a better seek order. The journal effectively acts as a write-combining buffer.

*Where it really does cost half.* Large *sequential* writes of bulk data — streaming a
10 GB video file. Here the real write was already sequential, so the journal copy is the
same cost as the real one, and you genuinely pay 2x bandwidth. This is exactly why
`data=ordered` (metadata journaling only) is the default: it protects the structures
without doubling bulk data.
#ans[The journal is sequential and batched, so its cost is tiny next to the random writes it protects — except for bulk sequential writes, where it truly doubles the I/O.]
]

#section[I/O: how bytes actually move]

#diagram(height: 7.6cm, caption: "The path of one read(). The page cache is why the second read of the same file costs nothing, and DMA is why a 4 KB transfer costs one interrupt instead of thousands.")[
  #dnode(0pt, 0.1cm, 3.6cm, 0.8cm, "user program\nread(fd, buf, 4096)", fill: white)
  #darrow(1.8cm, 0.95cm, 1.8cm, 1.45cm, label: "syscall")
  #dnode(0pt, 1.5cm, 3.6cm, 0.8cm, "VFS layer\n(generic file API)", fill: rgb("#eef3f7"))
  #darrow(1.8cm, 2.35cm, 1.8cm, 2.85cm)
  #dnode(0pt, 2.9cm, 3.6cm, 1.0cm, "PAGE CACHE\nis the block here?", fill: rgb("#dce9f2"))
  #darrow(1.8cm, 3.95cm, 1.8cm, 4.45cm, label: "HIT")
  #dnode(0pt, 4.5cm, 3.6cm, 0.8cm, "copy to user buffer\nDONE — no disk", fill: rgb("#f3f8f4"))

  #darrow(3.65cm, 3.4cm, 5.15cm, 3.4cm, label: "MISS")
  #dnode(5.2cm, 2.9cm, 3.4cm, 1.0cm, "file system\ninode -> block number", fill: rgb("#eef3f7"))
  #darrow(8.65cm, 3.4cm, 10.15cm, 3.4cm)
  #dnode(10.2cm, 2.9cm, 3.4cm, 1.0cm, "block layer\nqueue + SCHEDULER", fill: rgb("#f7efe4"))
  #darrow(11.9cm, 3.95cm, 11.9cm, 4.65cm, label: "reorder")
  #dnode(10.2cm, 4.7cm, 3.4cm, 0.9cm, "device driver", fill: rgb("#eef3f7"))
  #darrow(11.9cm, 5.65cm, 11.9cm, 6.35cm)
  #dnode(10.2cm, 6.4cm, 3.4cm, 0.9cm, "DISK", fill: rgb("#f2dcdc"))

  #dnode(5.2cm, 5.2cm, 4.4cm, 2.1cm, "DMA controller moves\nthe bytes into RAM\nWITHOUT the CPU.\n\nOne interrupt at the END,\nnot one per byte.", fill: rgb("#fbf6ee"))
  #darrow(10.15cm, 6.85cm, 9.65cm, 6.85cm)
  #darrow(5.15cm, 6.0cm, 3.0cm, 4.0cm, label: "fills cache")

  #dnode(14.0cm, 0.1cm, 2.3cm, 3.0cm, "every arrow\ncrossed here\nis a potential\nCOPY —\nzero-copy I/O\nexists to\ndelete them", fill: rgb("#fafbfc"))
]

#subsection[Three ways to talk to a device]

#table(columns: (auto, auto, auto),
  [*Technique*], [*How*], [*Cost for a 4 KB transfer*],
  [*Programmed I/O (polling)*], [CPU loops reading a status register until the device is ready, then moves one word itself.], [CPU is 100% busy the whole time. Simple, and genuinely best for *very* fast devices where an interrupt would cost more than the wait.],
  [*Interrupt-driven*], [CPU issues the request and does something else; the device interrupts when a word is ready.], [One interrupt per word — up to 4096 interrupts. Each interrupt costs a context save/restore.],
  [*DMA*], [CPU tells a DMA controller "move 4096 bytes from device to address X" and forgets about it.], [*One* interrupt, at the end. The CPU is free for the whole transfer. This is what every real disk and NIC uses.],
)

#ex(8, tier: 2, asked: "Sea/Shopee · pattern")[
A device delivers one byte at a time. Handling one interrupt costs 2 microseconds of CPU
time. Compare the CPU cost of transferring 4 KB with interrupt-driven I/O versus DMA (DMA
setup 5 microseconds, one completion interrupt).
]
#sol[
*Interrupt-driven:*
$ 4096 "bytes" times 1 "interrupt each" = 4096 "interrupts" $
$ 4096 times 2 "us" = 8192 "us" = 8.192 "ms of pure CPU time" $

*DMA:*
$ 5 "us (setup)" + 2 "us (one completion interrupt)" = 7 "us" $

Ratio:
$ 8192 / 7 approx 1170 $
#ans[8.192 ms of CPU versus 7 microseconds — DMA uses about 1170 times less CPU. And that is for a single 4 KB read.]

Say the follow-up before you are asked: DMA does not make the *disk* faster. The transfer
still takes the same milliseconds. DMA frees the *CPU* during those milliseconds, which is
what raises whole-system throughput.
]

#subsection[Buffering, caching, spooling — three different words]

#table(columns: (auto, auto),
  [*Buffering*], [Holding data in memory *while* a transfer is in progress — to smooth speed mismatches, to allow a different transfer size, and to keep a stable copy while I/O runs.],
  [*Caching*], [Keeping a *copy* of data you already fetched, in the hope of reusing it. The page cache is the big one.],
  [*Spooling*], [Queueing whole jobs for a device that cannot interleave them — a printer. Jobs go to disk first and are fed one at a time.],
)

#section[Disk geometry and the time it really takes]

#diagram(height: 6.4cm, caption: "Disk geometry. A cylinder is the same track number on every platter — reachable with no extra seek, which is why file systems try to keep an inode and its blocks in one cylinder group.")[
  #place(dx: 3.6cm, dy: 0.5cm, circle(radius: 2.4cm, fill: rgb("#eef3f7"), stroke: 0.8pt + rgb("#33556b")))
  #place(dx: 4.8cm, dy: 1.7cm, circle(radius: 1.6cm, fill: white, stroke: (paint: rgb("#33556b"), thickness: 0.6pt, dash: "dashed")))
  #place(dx: 5.5cm, dy: 2.4cm, circle(radius: 0.9cm, fill: rgb("#f7efe4"), stroke: 0.6pt + rgb("#33556b")))
  #place(dx: 5.95cm, dy: 2.85cm, circle(radius: 0.45cm, fill: rgb("#33556b")))

  #dnode(0pt, 0.2cm, 3.2cm, 0.6cm, "outer TRACK", fill: white)
  #darrow(3.2cm, 0.5cm, 4.2cm, 1.0cm)
  #dnode(0pt, 2.6cm, 3.2cm, 0.6cm, "inner track", fill: white)
  #darrow(3.2cm, 2.9cm, 5.4cm, 2.9cm)

  #dnode(0pt, 4.4cm, 3.2cm, 0.7cm, "SECTOR = one\npie slice of a track", fill: rgb("#f7efe4"))
  #darrow(3.2cm, 4.7cm, 4.6cm, 4.2cm)

  #darrow(9.0cm, 2.9cm, 6.6cm, 2.9cm, label: "seek")
  #dnode(9.1cm, 2.55cm, 2.6cm, 0.7cm, "head arm", fill: rgb("#f2dcdc"))

  #dnode(9.1cm, 0.2cm, 7.0cm, 2.1cm, "TIME FOR ONE READ\n\nseek time: move the arm to the right track\n+ rotational latency: wait for the sector\n+ transfer time: stream the bytes", fill: rgb("#fbf6ee"))
  #dnode(9.1cm, 3.5cm, 7.0cm, 1.7cm, "CYLINDER = track k on\nevery platter at once.\nSame arm position, so NO\nextra seek between them.", fill: rgb("#f3f8f4"))
  #dnode(9.1cm, 5.35cm, 7.0cm, 0.7cm, "Seek is mechanical, so it dominates: milliseconds, not nanoseconds.", fill: rgb("#fdf4f4"))
]

#formulas(title: "Disk access time")[
$ T = T_"seek" + T_"rotation" + T_"transfer" $

- $T_"seek"$ — move the arm. Quoted as an *average*; 4 to 10 ms on a hard disk.
- $T_"rotation"$ — wait for the sector to come under the head. On average *half a
  revolution*:
  $ T_"rotation" = 1/2 times 60/"RPM" "seconds" = (30000)/"RPM" "milliseconds" $
- $T_"transfer"$ — bytes divided by the transfer rate.

Memorise two: 7200 RPM -> one revolution is 8.33 ms, so average latency *4.17 ms*.
15,000 RPM -> one revolution is 4 ms, so average latency *2 ms*.
]

#ex(9, tier: 1, asked: "TCS NQT · pattern")[
A disk spins at 7200 RPM, has an average seek of 5 ms, and transfers at 100 MB/s. Find the
time for one random 4 KB read, and the IOPS (random reads per second).
]
#sol[
*Step 1 — rotational latency.* One revolution:
$ 60 / 7200 = 0.008333 "s" = 8.333 "ms" $
Average latency is half of that:
$ 8.333 / 2 = 4.167 "ms" $

*Step 2 — transfer time for 4096 bytes at 100 MB/s:*
$ 4096 / (100 times 10^6) = 0.00004096 "s" = 0.041 "ms" $

*Step 3 — add them up:*
$ T = 5 + 4.167 + 0.041 = 9.208 "ms" $

*Step 4 — IOPS:*
$ 1000 / 9.208 = 108.6 $
#ans[About 9.21 ms per random 4 KB read, so roughly 109 IOPS.]

Now look at where the time went: 5 ms seek, 4.17 ms rotation, 0.04 ms of actual data
transfer. *Over 99.5% of the time was spent waiting, not reading.* That single ratio is the
justification for every disk-scheduling algorithm in the next section, and for why
databases obsess about sequential access.
]

#ex(10, tier: 2, asked: "Agoda · pattern")[
Same disk. Compare the *effective* throughput when reading 1000 separate 4 KB blocks
scattered randomly, versus reading one contiguous 4 MB file.
]
#sol[
*Random — 1000 separate reads:*
$ 1000 times 9.208 "ms" = 9208 "ms" = 9.21 "seconds" $
Data moved: $1000 times 4 "KB" = 4 "MB"$.
$ "throughput" = 4 "MB" / 9.21 "s" = 0.43 "MB/s" $

*Sequential — one 4 MB read:* one seek, one rotation, then stream.
$ "transfer" = (4 times 1048576) / (100 times 10^6) = 0.04194 "s" = 41.94 "ms" $
$ T = 5 + 4.167 + 41.94 = 51.11 "ms" $
$ "throughput" = 4 "MB" / 0.05111 "s" = 78.3 "MB/s" $

Ratio:
$ 78.3 / 0.43 approx 182 $
#ans[0.43 MB/s random versus 78.3 MB/s sequential — the same disk, the same 4 MB, 182 times slower. Same bytes, different order.]

This is *the* number to quote when an interviewer asks why a database adds an index, why
logs are append-only, or why a full table scan can beat an index on a large range query.
]

#section[Disk scheduling]

Requests pile up in a queue. Reordering them to reduce arm movement is nearly free and pays
enormously, because seek time dominates.

We will use one problem for all six algorithms so they can be compared fairly.

#formulas(title: "The six algorithms")[
- *FCFS* — serve in arrival order. Fair, no starvation, terrible seek totals.
- *SSTF* (shortest seek time first) — always go to the nearest pending request. Good
  totals, but *can starve* a request at the far end of the disk.
- *SCAN* (elevator) — sweep in one direction servicing everything, *go all the way to the
  end of the disk*, reverse, sweep back.
- *C-SCAN* — sweep up servicing everything, go to the end, then *jump straight back to
  block 0* without servicing, and sweep up again. Gives more uniform waiting times.
- *LOOK* — like SCAN, but *turn around at the last request*, not at the edge of the disk.
- *C-LOOK* — like C-SCAN, but jump back to the *lowest request*, not to block 0.

The jump in C-SCAN and C-LOOK *is counted* as head movement unless the question says
otherwise. State your assumption in the answer.
]

#ex(11, tier: 1, asked: "TCS Digital · pattern")[
Disk cylinders are numbered 0 to 199. The head is at *95*. The pending queue, in arrival
order, is:

$ 86, 147, 22, 91, 177, 40, 128 $

The head is currently moving *towards higher* cylinder numbers. Compute the total head
movement for FCFS, SSTF, SCAN, C-SCAN, LOOK and C-LOOK.
]
#sol[
First, sort the queue once — every algorithm except FCFS needs it:
$ 22, 40, 86, 91, 128, 147, 177 $
Requests *above* 95: 128, 147, 177. Requests *below* 95: 22, 40, 86, 91.

*FCFS* — arrival order, no thinking:

#table(columns: (auto, auto, auto, auto, auto, auto, auto, auto),
  [from], [95], [86], [147], [22], [91], [177], [40],
  [to],   [86], [147], [22], [91], [177], [40], [128],
  [move], [9], [61], [125], [69], [86], [137], [88],
)
$ 9 + 61 + 125 + 69 + 86 + 137 + 88 = 575 $

*SSTF* — always the nearest pending request:
$ 95 arrow.r 91 (4) arrow.r 86 (5) arrow.r 128 (42) arrow.r 147 (19) arrow.r 177 (30) arrow.r 40 (137) arrow.r 22 (18) $
$ 4 + 5 + 42 + 19 + 30 + 137 + 18 = 255 $

Notice the 137 jump near the end. SSTF picked off everything nearby and left 40 and 22
stranded — with a steady stream of new requests near 90, those two could wait forever.
That is *starvation*.

*SCAN* — go up to 199 first, then come back down:
$ 95 arrow.r 128 (33) arrow.r 147 (19) arrow.r 177 (30) arrow.r 199 (22) arrow.r 91 (108) arrow.r 86 (5) arrow.r 40 (46) arrow.r 22 (18) $
$ 33 + 19 + 30 + 22 + 108 + 5 + 46 + 18 = 281 $

*C-SCAN* — up to 199, jump to 0, then up again:
$ 95 arrow.r 128 (33) arrow.r 147 (19) arrow.r 177 (30) arrow.r 199 (22) arrow.r 0 (199) arrow.r 22 (22) arrow.r 40 (18) arrow.r 86 (46) arrow.r 91 (5) $
$ 33 + 19 + 30 + 22 + 199 + 22 + 18 + 46 + 5 = 394 $

*LOOK* — SCAN without touching 199:
$ 95 arrow.r 128 (33) arrow.r 147 (19) arrow.r 177 (30) arrow.r 91 (86) arrow.r 86 (5) arrow.r 40 (46) arrow.r 22 (18) $
$ 33 + 19 + 30 + 86 + 5 + 46 + 18 = 237 $

*C-LOOK* — C-SCAN without touching 199 or 0:
$ 95 arrow.r 128 (33) arrow.r 147 (19) arrow.r 177 (30) arrow.r 22 (155) arrow.r 40 (18) arrow.r 86 (46) arrow.r 91 (5) $
$ 33 + 19 + 30 + 155 + 18 + 46 + 5 = 306 $

Summary:

#table(columns: (auto, auto, auto),
  [*Algorithm*], [*Total movement*], [*Comment*],
  [LOOK], [*237*], [Best here. No wasted travel to the disk edges.],
  [SSTF], [255], [Close behind, but it can starve far-away requests.],
  [SCAN], [281], [Pays 22 cylinders to reach 199 for nothing.],
  [C-LOOK], [306], [Pays the jump, buys fair waiting times.],
  [C-SCAN], [394], [Pays the jump *and* both edges.],
  [FCFS], [575], [Worst, by a factor of 2.4 over LOOK.],
)
#ans[FCFS 575 · SSTF 255 · SCAN 281 · C-SCAN 394 · LOOK 237 · C-LOOK 306 cylinders.]
]

#code(lang: "js", caption: "diskscan.js — all six, so you can check any question")[
```js
const head = 95, MIN = 0, MAX = 199;
const queue = [86, 147, 22, 91, 177, 40, 128];

const travel = (path) =>
  path.slice(1).reduce((sum, x, i) => sum + Math.abs(x - path[i]), 0);

const sorted = [...queue].sort((a, b) => a - b);      // numeric sort, NOT plain sort()
const up   = sorted.filter(x => x >= head);
const down = sorted.filter(x => x <  head);

const paths = {
  FCFS:     [head, ...queue],
  SSTF:     (() => {
              const left = [...queue]; let cur = head; const out = [head];
              while (left.length) {
                let bi = 0;
                for (let i = 1; i < left.length; i++)
                  if (Math.abs(left[i] - cur) < Math.abs(left[bi] - cur)) bi = i;
                cur = left[bi]; out.push(cur); left.splice(bi, 1);
              }
              return out;
            })(),
  SCAN:     [head, ...up, MAX, ...[...down].reverse()],
  'C-SCAN': [head, ...up, MAX, MIN, ...down],
  LOOK:     [head, ...up, ...[...down].reverse()],
  'C-LOOK': [head, ...up, ...down],
};
for (const [name, p] of Object.entries(paths))
  console.log(name.padEnd(7), travel(p).toString().padStart(4), p.join(' -> '));
```
]

#note[
Real output from `node diskscan.js`:
```
FCFS     575 95 -> 86 -> 147 -> 22 -> 91 -> 177 -> 40 -> 128
SSTF     255 95 -> 91 -> 86 -> 128 -> 147 -> 177 -> 40 -> 22
SCAN     281 95 -> 128 -> 147 -> 177 -> 199 -> 91 -> 86 -> 40 -> 22
C-SCAN   394 95 -> 128 -> 147 -> 177 -> 199 -> 0 -> 22 -> 40 -> 86 -> 91
LOOK     237 95 -> 128 -> 147 -> 177 -> 91 -> 86 -> 40 -> 22
C-LOOK   306 95 -> 128 -> 147 -> 177 -> 22 -> 40 -> 86 -> 91
```
]

#trap[
`[...queue].sort()` without a comparator sorts *lexicographically*: `[86,147,22]` becomes
`[147, 22, 86]`, because "147" $<$ "22" as strings. In a disk-scheduling question that
silently produces a wrong answer. Always write `.sort((a, b) => a - b)`.
]

#trap[
"C-SCAN is better than SCAN because it moves less." It usually moves *more* — it pays for
the return jump. What C-SCAN buys is *fairness*: in SCAN, a cylinder just behind the head
waits for a full sweep out and back, while the edges get served twice per cycle. C-SCAN
gives every cylinder the same wait. Say "uniform waiting time", not "less movement".
]

#ex(12, tier: 3, asked: "Google · pattern")[
Your fleet moves from hard disks to SSDs. The storage team wants to keep the same LOOK
scheduler because "it was the best one". What do you tell them, and what would you use
instead?
]
#sol[
*What changed.* LOOK exists to minimise *arm movement*. An SSD has no arm. Its access time
to logical block 5 and logical block 5,000,000 is essentially identical — there is no seek,
no rotation, just a flash-page read of roughly 0.1 ms. So the entire objective function
that LOOK optimises has become a constant.

*What LOOK now costs you.* It still *reorders* requests, so it adds latency and CPU work,
and it can delay a request that was already ready. Worse, it destroys the request order
that the SSD's own internal parallelism would exploit — a good SSD wants *many requests in
flight at once* spread across its independent flash channels, and a sorting scheduler
serialises them into a neat sequence that uses one channel at a time.

*What to use instead.*
- `none` / `noop` — a simple FIFO queue. Correct default for fast NVMe devices; the device
  does its own scheduling far better than the OS can.
- `mq-deadline` — FIFO plus a deadline per request, so nothing starves, and reads are
  prioritised over writes. Use when you need latency guarantees.
- Raise the *queue depth* so the device can work on many requests in parallel. This matters
  far more than the ordering.

*The number that settles it.* Our hard disk did about 109 random 4 KB IOPS. A consumer NVMe
SSD does hundreds of thousands. When a single request costs 0.1 ms instead of 9.2 ms, a
scheduler that spends even 0.05 ms deciding has eaten half your latency.
#ans[Disk scheduling optimises seek time, and SSDs have no seek. Switch to `none` for NVMe or `mq-deadline` where fairness matters, and increase queue depth so the device's internal parallelism is used.]
]

#section[SSDs — a different set of rules]

#formulas(title: "What flash forces on you")[
+ *Read and write in pages* (e.g. 4 KB), but *erase in blocks* (e.g. 256 pages together).
+ A page cannot be overwritten in place. To change one page you must erase the whole block
  it is in — so the controller instead writes the new version *somewhere else* and marks the
  old page invalid.
+ Each block tolerates a limited number of erase cycles.

Three consequences you must be able to name:
- *FTL (flash translation layer)* — the controller's own map from logical block address to
  physical page. An SSD is running its own little file system inside itself.
- *Wear levelling* — spread erases evenly so no block dies early.
- *Write amplification* — writing 4 KB can cause far more than 4 KB of physical writes,
  because valid pages must be copied out before a block is erased.
- *TRIM* — the file system telling the SSD "these blocks hold deleted data". Without TRIM
  the SSD faithfully copies dead data around during garbage collection forever.
]

#table(columns: (auto, auto, auto),
  [], [*Hard disk (7200 RPM)*], [*NVMe SSD*],
  [Random 4 KB read], [$approx 9.2$ ms], [$approx 0.1$ ms],
  [Random 4 KB IOPS], [$approx 109$], [100,000+],
  [Sequential throughput], [$approx 80$ MB/s], [2000+ MB/s],
  [Random vs sequential gap], [$approx 180 times$], [small, but not zero],
  [Wears out from], [mechanical failure], [erase cycles],
  [Best OS scheduler], [LOOK / C-LOOK], [`none` or `mq-deadline`],
)

#section[RAID]

#formulas(title: "RAID in one box")[
Combine $n$ disks so they look like one, for *speed*, *redundancy*, or both.

- *RAID 0 — striping.* Data split across all disks. Capacity $n times c$. Speed: great.
  Redundancy: *none* — one failure loses everything. (Strictly, not redundant at all; the
  "R" is a lie here.)
- *RAID 1 — mirroring.* Every disk has a twin. Capacity $n c \/ 2$. Reads can be served by
  either twin; writes go to both. Survives one failure per mirror pair.
- *RAID 5 — striping with distributed parity.* One disk's worth of capacity goes to parity,
  spread across all disks. Capacity $(n-1) c$. Survives *one* failure.
- *RAID 6 — two parity blocks.* Capacity $(n-2) c$. Survives *two* failures. Used because
  rebuilding a big RAID 5 array takes so long that a second failure during the rebuild is
  a real risk.
- *RAID 10 — mirror, then stripe.* Capacity $n c \/ 2$. Fast, safe, expensive. The usual
  choice for databases.

*Parity is XOR.* $P = D_0 xor D_1 xor D_2$. If $D_1$ dies,
$D_1 = D_0 xor D_2 xor P$. That is the whole mathematics of RAID 5.
]

#diagram(height: 5.4cm, caption: "RAID 5 with 4 disks. Parity rotates so no single disk becomes a write bottleneck. Any one column can be deleted and rebuilt from the other three.")[
  #dnode(0pt, 0.15cm, 2.0cm, 0.6cm, "", fill: white)
  #dnode(2.1cm, 0.15cm, 2.6cm, 0.6cm, "Disk 0", fill: white)
  #dnode(4.8cm, 0.15cm, 2.6cm, 0.6cm, "Disk 1", fill: white)
  #dnode(7.5cm, 0.15cm, 2.6cm, 0.6cm, "Disk 2", fill: white)
  #dnode(10.2cm, 0.15cm, 2.6cm, 0.6cm, "Disk 3", fill: white)

  #dnode(0pt, 0.85cm, 2.0cm, 0.7cm, "stripe 0", fill: white)
  #dnode(2.1cm, 0.85cm, 2.6cm, 0.7cm, "A0", fill: rgb("#eef3f7"))
  #dnode(4.8cm, 0.85cm, 2.6cm, 0.7cm, "A1", fill: rgb("#eef3f7"))
  #dnode(7.5cm, 0.85cm, 2.6cm, 0.7cm, "A2", fill: rgb("#eef3f7"))
  #dnode(10.2cm, 0.85cm, 2.6cm, 0.7cm, "P(A)", fill: rgb("#f7efe4"))

  #dnode(0pt, 1.65cm, 2.0cm, 0.7cm, "stripe 1", fill: white)
  #dnode(2.1cm, 1.65cm, 2.6cm, 0.7cm, "B0", fill: rgb("#eef3f7"))
  #dnode(4.8cm, 1.65cm, 2.6cm, 0.7cm, "B1", fill: rgb("#eef3f7"))
  #dnode(7.5cm, 1.65cm, 2.6cm, 0.7cm, "P(B)", fill: rgb("#f7efe4"))
  #dnode(10.2cm, 1.65cm, 2.6cm, 0.7cm, "B2", fill: rgb("#eef3f7"))

  #dnode(0pt, 2.45cm, 2.0cm, 0.7cm, "stripe 2", fill: white)
  #dnode(2.1cm, 2.45cm, 2.6cm, 0.7cm, "C0", fill: rgb("#eef3f7"))
  #dnode(4.8cm, 2.45cm, 2.6cm, 0.7cm, "P(C)", fill: rgb("#f7efe4"))
  #dnode(7.5cm, 2.45cm, 2.6cm, 0.7cm, "C1", fill: rgb("#eef3f7"))
  #dnode(10.2cm, 2.45cm, 2.6cm, 0.7cm, "C2", fill: rgb("#eef3f7"))

  #dnode(0pt, 3.25cm, 2.0cm, 0.7cm, "stripe 3", fill: white)
  #dnode(2.1cm, 3.25cm, 2.6cm, 0.7cm, "P(D)", fill: rgb("#f7efe4"))
  #dnode(4.8cm, 3.25cm, 2.6cm, 0.7cm, "D0", fill: rgb("#eef3f7"))
  #dnode(7.5cm, 3.25cm, 2.6cm, 0.7cm, "D1", fill: rgb("#eef3f7"))
  #dnode(10.2cm, 3.25cm, 2.6cm, 0.7cm, "D2", fill: rgb("#eef3f7"))

  #dnode(13.0cm, 0.85cm, 3.3cm, 1.5cm, "P(A) = A0 xor A1 xor A2\n\nLose disk 1?\nA1 = A0 xor A2 xor P(A)", fill: rgb("#f3f8f4"))
  #dnode(13.0cm, 2.45cm, 3.3cm, 1.5cm, "SMALL WRITE = 4 I/Os\nread old data,\nread old parity,\nwrite data, write parity", fill: rgb("#fdf4f4"))
  #dnode(0pt, 4.15cm, 12.8cm, 0.8cm, "Capacity with 4 disks of size c: RAID 0 = 4c (no safety)  ·  RAID 5 = 3c (survives 1)  ·  RAID 6 = 2c (survives 2)  ·  RAID 10 = 2c (fast + safe)", fill: rgb("#fafbfc"))
]

#code(lang: "js", caption: "raid.js — parity really is just XOR")[
```js
const D0 = 0b1011, D1 = 0b0110, D2 = 0b1100;
const P = D0 ^ D1 ^ D2;
const bin = n => n.toString(2).padStart(4, '0');
console.log('D0', bin(D0), 'D1', bin(D1), 'D2', bin(D2), '=> P', bin(P));

// disk 1 dies. Rebuild D1 from everything that survived.
const rebuilt = D0 ^ D2 ^ P;
console.log('rebuilt D1 =', bin(rebuilt), '| matches:', rebuilt === D1);

// and the whole stripe still XORs to zero
console.log('D0^D1^D2^P =', bin(D0 ^ D1 ^ D2 ^ P));
```
]

#note[
Real output from `node raid.js`:
```
D0 1011 D1 0110 D2 1100 => P 0001
rebuilt D1 = 0110 | matches: true
D0^D1^D2^P = 0000
```
The third line is the invariant a RAID controller checks: *data XOR parity is always zero*.
]

#ex(13, tier: 2, asked: "DBS · pattern")[
Eight disks of 4 TB each. Give the usable capacity and the number of simultaneous disk
failures survived for RAID 0, 1, 5, 6 and 10. Then say which you would choose for a
write-heavy transactional database, and why.
]
#sol[
#table(columns: (auto, auto, auto, auto),
  [*Level*], [*Usable capacity*], [*Survives*], [*Small-write cost*],
  [RAID 0], [$8 times 4 = 32$ TB], [0 failures], [1 write],
  [RAID 1 (4 mirrored pairs)], [$8 times 4 \/ 2 = 16$ TB], [1 per pair], [2 writes],
  [RAID 5], [$(8-1) times 4 = 28$ TB], [1 failure], [*4 I/Os*],
  [RAID 6], [$(8-2) times 4 = 24$ TB], [2 failures], [*6 I/Os*],
  [RAID 10], [$8 times 4 \/ 2 = 16$ TB], [1 per mirror (up to 4 if lucky)], [2 writes],
)

*Why RAID 5's small write costs 4 I/Os.* To change one data block you must:
+ read the *old* data block,
+ read the *old* parity block,
+ compute $P_"new" = P_"old" xor D_"old" xor D_"new"$,
+ write the new data block,
+ write the new parity block.

That is 2 reads + 2 writes for one logical write. This is the *RAID 5 write penalty*.
RAID 6 has two parity blocks, so it is 3 reads + 3 writes = 6 I/Os.

*Choice for a write-heavy transactional database: RAID 10.* You give up half your raw
capacity, but a small write costs 2 writes with no read-modify-write cycle, and a rebuild
copies one disk instead of recomputing parity across seven. On this array that is 16 TB
usable instead of 28 TB — you are paying 12 TB for latency.
#ans[RAID 0: 32 TB / 0 · RAID 1: 16 TB / 1 per pair · RAID 5: 28 TB / 1 · RAID 6: 24 TB / 2 · RAID 10: 16 TB / 1 per mirror. Pick RAID 10 for write-heavy OLTP because it avoids the 4-I/O parity write penalty.]
]

#trap[
"RAID is a backup." *No.* RAID protects against a *disk* dying. It does not protect against
`DROP TABLE`, ransomware, a bad deployment, fire, or theft — every mirror faithfully copies
your mistake instantly. Backups are separate, offline, and tested.
]

#section[Access methods, directories and permissions]

#subsection[How a program reads a file]

#table(columns: (auto, auto, auto),
  [*Method*], [*How it works*], [*Where you see it*],
  [*Sequential*], [Read or write from the current position; the position advances. `rewind` to start again.], [Almost everything: text files, logs, streams, compilers.],
  [*Direct (random)*], [Treat the file as numbered records; jump to record $n$ with `seek`.], [Databases, index files, anything with fixed-size records.],
  [*Indexed sequential*], [A separate index file maps a key to a record position; look up the index, then jump.], [Old ISAM systems; the idea survives as the database index.],
)

#subsection[How a directory is searched]

A directory search happens on *every* path component of *every* `open()`, so its cost
matters enormously in a directory with many files.

#ex(14, tier: 2, asked: "LINE MAN · pattern")[
A directory holds 10,000 files. Each entry averages 40 bytes. Block size is 4 KB. Compare
the disk reads for a name lookup under (a) an unsorted linear list, (b) a hashed directory,
(c) a B-tree (H-tree) directory.
]
#sol[
Step 1 — how many blocks does the directory occupy?
$ 10000 times 40 = 400,000 "bytes" $
$ 400000 / 4096 = 97.66 arrow.r 98 "blocks" $

*(a) Linear list.* You must scan entries until you find the name.
- Average (name present): half the blocks $= 49$ reads.
- Worst case, and *every* failed lookup: all *98* reads.

Note that a failed lookup is the *expensive* case, and failed lookups happen on every file
*creation* (the OS must check the name is not taken). Creating 10,000 files in one directory
therefore costs on the order of $10000 times 49 approx 490,000$ block reads in total. This
is exactly why "too many files in one directory" is slow on old file systems.

*(b) Hashed directory.* Hash the name to a bucket; read that bucket.
- 1 read, plus one more if the bucket overflowed. Call it *1 to 2 reads*.
- Cost: the hash function fixes the number of buckets, so growing the directory means
  rehashing everything.

*(c) B-tree / H-tree.* One index block at the top, leaf blocks below.
- With 98 leaf blocks, one index block can hold pointers to all of them.
- 1 read for the index + 1 read for the leaf = *2 reads*.
- And unlike hashing, it stays balanced as the directory grows, and it keeps entries in
  sorted order.
#ans[Linear: 49 reads average, 98 for any miss. Hashed: 1-2. B-tree: 2, and it scales. Modern file systems (ext4's H-tree, XFS, NTFS) all use the tree.]
]

#subsection[Permissions, umask and the three special bits]

#formulas(title: "The octal permission model")[
Nine bits, three groups of three: *user*, *group*, *other*; each group is *read (4)*,
*write (2)*, *execute (1)*.

$ 7 = "rwx" quad 6 = "rw-" quad 5 = "r-x" quad 4 = "r--" quad 0 = "---" $

On a *directory* the letters mean something different:
- `r` — you may *list* the names inside.
- `w` — you may *create or delete* entries inside.
- `x` — you may *traverse* it (use it in a path). Without `x` you cannot reach anything
  below, even if you know the exact name.

*umask* is a mask of bits to *remove*:
$ "final mode" = "base mode" and not "umask" $
Base is 666 for a new file (never executable) and 777 for a new directory.
]

#ex(15, tier: 1, asked: "Cognizant · pattern")[
(a) What does mode 754 allow? (b) With `umask 022`, what mode does a newly created file get,
and a newly created directory? (c) A directory is mode 711. Can another user read a file
inside it called `secret.txt` if that file is mode 644?
]
#sol[
*(a)* Split 754 into three digits: 7, 5, 4.
- user $= 7 = 4+2+1 = $ `rwx`
- group $= 5 = 4+0+1 = $ `r-x`
- other $= 4 = 4+0+0 = $ `r--`

So `rwxr-xr--`: the owner can do everything, the group can read and execute but not modify,
everyone else can only read.

*(b)* umask 022 removes write permission for group and other.
- File: $666 "AND NOT" 022$. Digit by digit: $6 - 0 = 6$, $6 - 2 = 4$, $6 - 2 = 4$.
  Result *644* (`rw-r--r--`).
- Directory: $777 "AND NOT" 022 = 7, 5, 5$. Result *755* (`rwxr-xr-x`).

*(c)* Directory mode 711 is `rwx--x--x`. Other users have `x` but not `r`.
- No `r` means they *cannot list* the directory — `ls` fails.
- But `x` means they *can traverse* it. If they already know the exact name, they can open
  `secret.txt`, and 644 lets them read it.
#ans[(a) `rwxr-xr--` (b) files 644, directories 755 (c) *Yes* — they cannot list the directory but they can still open a file whose name they know. Mode 711 hides names, not contents.]
]

#table(columns: (auto, auto, auto),
  [*Special bit*], [*On a file*], [*On a directory*],
  [*setuid* (4000)], [The program runs with the *file owner's* privileges, not the caller's. This is how `passwd` can edit a root-owned file.], [No effect on Linux.],
  [*setgid* (2000)], [Runs with the file's group.], [New files inside inherit the *directory's* group — used for shared project folders.],
  [*sticky bit* (1000)], [Historical (keep the program in swap); now ignored.], [*Only the owner of a file may delete it*, even if everyone can write to the directory. This is what makes `/tmp` (mode 1777) safe.],
)

#trap[
"`/tmp` is world-writable, so anyone can delete my file there." Not with the sticky bit set
(`drwxrwxrwt` — note the final `t`). Everyone may *create* files, but only the file's owner
may *remove* theirs. Without the sticky bit, a world-writable directory lets any user delete
any other user's files, because deletion is a *directory* write, not a *file* write.
]

#section[Sparse files: size is not space]

A file's `size` field says where the last byte is. It does not say how many blocks were
allocated. Skip forward with `seek` and write, and the skipped region becomes a *hole*: no
blocks are allocated, and reads of the hole return zeros.

#ex(16, tier: 2, asked: "Sea/Shopee · pattern")[
Run this, then explain the two different numbers:

```
dd if=/dev/zero of=sparse.dat bs=1 count=1 seek=1073741824
ls -l sparse.dat
du --block-size=1 sparse.dat
stat -c '%n size=%s blocks=%b blocksize=%B' sparse.dat
```
]
#sol[
Real output from a Linux shell:

```
-rw-rw-r-- 1 zayed zayed 1073741825 Sep 15 22:22 sparse.dat
4096    sparse.dat
sparse.dat size=1073741825 blocks=8 blocksize=512
```

Read the three lines carefully.

- `ls -l` reports *1,073,741,825* bytes — that is 1 GiB plus the one byte we wrote. This is
  the *size* field in the inode: the offset of the last byte, plus one.
- `du` reports *4096* bytes — the actual disk space used. One 4 KB block.
- `stat` explains it: `blocks=8` in units of `blocksize=512`, and $8 times 512 = 4096$.

So the file *claims* 1 GiB and *occupies* 4 KB. The gigabyte in between is a hole: the
inode simply has no pointer for those blocks, and a read there returns zeros without any
disk access at all.
#ans[Size 1,073,741,825 bytes, space used 4096 bytes. Size is where the last byte sits; space is how many blocks the inode actually points at.]

Two practical consequences to mention:
+ `cp` a sparse file carelessly and you get a *dense* 1 GiB copy — the zeros get written out
  for real. Use `cp --sparse=always`.
+ Virtual-machine disk images and database files are usually sparse. That is why `df` and
  `du` often disagree with what an application reports.
]

#section[The page cache, and what `fsync` really costs]

#formulas(title: "Write-back, read-ahead, and durability")[
Every read and write goes through the *page cache* — RAM holding recently used file blocks.

- *Read hit* — no disk access at all.
- *Read-ahead* — on detecting sequential reads, the kernel fetches the *next* blocks before
  you ask. This is why sequential reading is so much faster than the disk numbers suggest.
- *Write-back* (the default) — a `write()` only marks a page dirty in RAM and returns
  immediately. The kernel flushes it later. Fast, but a crash loses the data.
- *Write-through* — every write goes to disk before returning. Safe, slow.
- *`fsync(fd)`* — force this file's dirty pages *and* its metadata to durable storage, and
  do not return until the device confirms. This is the only way an application gets a real
  durability guarantee.
]

#ex(17, tier: 3, asked: "Goldman Sachs · pattern")[
A service appends a 4 KB record to a log file and calls `fsync()` after each one. On a
7200 RPM disk with 4 ms average seek it manages about 100 records per second. Explain that
number from first principles, and then explain why removing `fsync()` gives roughly 50,000
records per second — and what is lost.
]
#sol[
*Where 100/second comes from.* Each `fsync()` forces a real trip to the platter, and there
are *two* structures to update: the journal commit record, and the file's data plus inode.

One durable write costs, at minimum:
$ T = T_"seek" + T_"rotation" + T_"transfer" $
$ = 4 + 30000/7200 + 4096/(100 times 10^6) times 1000 $
$ = 4 + 4.167 + 0.041 = 8.21 "ms" $

With the journal commit needing its own rotation, roughly 9-10 ms per record:
$ 1000 "ms" / 10 "ms" = 100 "records per second" $
The number is not about bandwidth at all — the disk moved 4 KB in 0.04 ms. It is about
*waiting for the platter to come round*, twice.

*Why removing `fsync()` gives ~50,000/second.* Without it, `write()` copies 4 KB into the
page cache and returns. That is a memory copy of a few microseconds. The kernel later
flushes thousands of accumulated pages in a handful of large sequential writes, so the per
record disk cost collapses.

*What is lost.* Durability. The application has been told "written" for records that exist
only in RAM. A power cut or kernel panic loses up to 30 seconds of "successful" writes.
Note carefully: a *process* crash loses nothing (the page cache belongs to the kernel), but
a *machine* crash does. Interviewers like that distinction.

*The engineering answer* is neither extreme: *group commit*. Collect records for a few
milliseconds, then `fsync()` once for the whole batch.
$ "throughput" approx 100 "fsyncs/second" times "batch size" $
With a batch of 200 records you get about 20,000 durable records per second, and the worst
case latency for any single record is only the batching window plus 10 ms.
#ans[100/s is two rotational waits per record (~10 ms), not a bandwidth limit. Dropping `fsync()` buys 500x by giving up durability on machine crash. Group commit gets most of the speed while keeping durability, at the cost of a few milliseconds of latency.]
]

#trick[
Any time an interview question says "slow, but the data is small", stop thinking about
bandwidth and start counting *round trips*: seeks, rotations, `fsync` calls, network
round trips. Small-and-slow is always a latency problem, never a throughput one.
]

#section[Mounting and the VFS]

#formulas(title: "How several file systems become one tree")[
*Mounting* attaches the root of one file system onto a directory (the *mount point*) of
another. After `mount /dev/sdb1 /data`, a path starting `/data/...` is resolved by the
*second* file system's code, using *its* inode numbers and *its* superblock.

Anything that was previously inside `/data` is *hidden*, not deleted — it reappears when
you unmount.

The *VFS (virtual file system)* is the kernel layer that makes this possible: it defines a
common interface (`open`, `read`, `write`, `lookup`, ...) that every file system implements.
`ext4`, `XFS`, `NTFS`, a network file system, and even `/proc` (which has no disk at all)
all plug into the same interface. That is why one `read()` call works on all of them.
]

#table(columns: (auto, auto),
  [*Layer*], [*What it decides*],
  [Application], [Which file, which bytes.],
  [System call / VFS], [Which file system owns this path; permission checks; the page cache.],
  [File system (ext4, XFS, ...)], [Inode to block-number translation; allocation; journaling.],
  [Block layer], [Queueing, merging adjacent requests, the I/O scheduler.],
  [Device driver], [Turning a block request into device commands; DMA setup.],
  [Hardware], [The actual read.],
)

#note[
Say this when asked "what happens when I run `cat file.txt`": name the layers from the top
down and say one sentence for each. Six sentences, in order, is a complete answer — and far
better than a long story about one layer.
]

#section[Practice]

#practice(tier: 0, time: "6 min")[
+ Where is a file's name stored — in the inode or in the directory?
+ A disk spins at 6000 RPM. What is the average rotational latency?
+ Which allocation method gives $O(1)$ random access but suffers external fragmentation?
+ You delete a file that is still open by a running process. Is the space freed?
+ Which RAID level gives no redundancy at all?
]

#key[
+ In the *directory*, as a `(name, inode number)` entry. The inode holds everything else.
+ One revolution $= 60\/6000 = 10$ ms. Average latency is half: *5 ms*.
+ *Contiguous* allocation.
+ *No.* The link count reached 0, but the open-file reference has not. Space is freed when the process closes it or exits.
+ *RAID 0* — pure striping.
]

#practice(tier: 1, time: "15 min")[
+ Block size 8 KB, pointer size 4 bytes, 10 direct pointers, plus one single and one double indirect. Largest file?
+ A 2 TB disk with 4 KB blocks. Size of the free-space bitmap?
+ Head at 60, queue $25, 140, 78, 12, 190, 95$, cylinders 0-199, moving upward. Total movement for FCFS and for SSTF.
+ A disk has 10 ms average seek, 5400 RPM, 80 MB/s transfer. Time for one random 8 KB read?
+ Explain in two lines why a hard link cannot cross a file system boundary.
]

#key[
+ Pointers per block $= 8192\/4 = 2048$. Blocks $= 10 + 2048 + 2048^2 = 10 + 2048 + 4194304 = 4196362$. Bytes $= 4196362 times 8192 = 34376277504$, which is about *32 GiB*.
+ Blocks $= 2 times 1024^4 \/ 4096 = 536870912$. Bits to bytes: $\/8 = 67108864$ bytes, so *64 MB*.
+ *FCFS:* $60 arrow.r 25 (35) arrow.r 140 (115) arrow.r 78 (62) arrow.r 12 (66) arrow.r 190 (178) arrow.r 95 (95)$; total $= 35+115+62+66+178+95 = 551$ — *551*. *SSTF:* $60 arrow.r 78 (18) arrow.r 95 (17) arrow.r 140 (45) arrow.r 190 (50) arrow.r 25 (165) arrow.r 12 (13)$; total $= 18+17+45+50+165+13 = 308$ — *308*.
+ Rotation: $60\/5400 = 11.11$ ms, half $= 5.56$ ms. Transfer: $8192\/(80 times 10^6) = 0.000102$ s $= 0.10$ ms. Total $= 10 + 5.56 + 0.10 = 15.66$ ms — *15.66 ms*.
+ A hard link is an inode *number*, and inode numbers are only unique *within one file system*. Inode 431 on the root file system and inode 431 on a mounted USB stick are different files, so the link would be ambiguous. A soft link stores a *path* string, which the kernel re-resolves from the root, so it crosses boundaries fine.
]

#practice(tier: 2, time: "20 min")[
+ A file system uses 4 KB blocks. Compare the space wasted by 1,000,000 files averaging 3 KB each under 4 KB blocks and under 64 KB blocks.
+ A disk does 7200 RPM, 4 ms average seek, 150 MB/s. A query reads 200 rows scattered across 200 different blocks of 8 KB. How long? How long if the same 200 blocks were contiguous?
+ Head at 110, queue $34, 118, 21, 165, 92, 180, 55$, cylinders 0-199, moving upward. Compute LOOK and C-LOOK.
+ Explain why `data=ordered` journaling never shows you another file's old bytes, while `data=writeback` can.
]

#key[
+ *4 KB blocks:* each 3 KB file takes 1 block, wasting $4096 - 3072 = 1024$ B. Total $= 10^6 times 1024 = 1.024 times 10^9$ B, about *0.95 GiB*. *64 KB blocks:* each file takes 1 block of 65,536 B, wasting $65536 - 3072 = 62464$ B. Total $= 6.2464 times 10^10$ B, about *58.2 GiB*. Sixty-one times more waste, for the same files.
+ Rotation $= 30000\/7200 = 4.167$ ms. Transfer of 8 KB $= 8192\/(150 times 10^6) = 0.0546$ ms. Per random read $= 4 + 4.167 + 0.055 = 8.222$ ms; $times 200 = 1644$ ms, about *1.64 s*. Contiguous: one seek + one rotation + transfer of $200 times 8192 = 1638400$ B $= 10.92$ ms; total $= 4 + 4.167 + 10.92 = 19.09$ ms — *19.09 ms*. Ratio: about *86 times*.
+ Sorted: 21, 34, 55, 92, 118, 165, 180. Above 110: 118, 165, 180. Below: 92, 55, 34, 21. *LOOK:* $110 arrow.r 118 (8) arrow.r 165 (47) arrow.r 180 (15) arrow.r 92 (88) arrow.r 55 (37) arrow.r 34 (21) arrow.r 21 (13)$; total $= 8+47+15+88+37+21+13 = 229$ — *229*. *C-LOOK:* $110 arrow.r 118 (8) arrow.r 165 (47) arrow.r 180 (15) arrow.r 21 (159) arrow.r 34 (13) arrow.r 55 (21) arrow.r 92 (37)$; total $= 8+47+15+159+13+21+37 = 300$ — *300*.
+ In `ordered` mode the file system *forces the data blocks to disk before* committing the metadata that points at them. So if a crash happens, either the metadata is not there (the block is still free — you see nothing) or it is there and the data is already correct. In `writeback` mode only metadata is ordered: the inode can commit, saying "block 5000 belongs to this file, size 4 KB", while block 5000 still contains whatever the *previous* owner left there. After recovery you read that old content — possibly another user's deleted data. That is a security issue, not just a correctness one.
]

#practice(tier: 3, time: "25 min")[
+ A log-structured file system writes *everything* — data and metadata — as one continuous append-only stream. Give two reasons this is fast, and the one problem it creates. How is that problem solved?
+ A 12-disk RAID 5 array of 8 TB disks is rebuilding after one failure. Estimate the rebuild time if the array can sustain 150 MB/s of rebuild traffic, and explain why this number is the main argument for RAID 6.
+ Your service writes a 4 KB record and calls `fsync()` after every write. Throughput is 100 writes/second on a hard disk. Explain the number, then give three different ways to make it faster and what each one risks.
+ Design the metadata layout for a file system that must store 100 million files averaging 2 KB. Say what you choose for block size and inode strategy, and justify both with numbers.
]

#key[
+ *Fast because:* (1) every write is sequential, so seek and rotation are paid once per segment instead of once per update — from our numbers that is 9.2 ms down to about 0.04 ms per 4 KB. (2) Many small updates are batched into one large segment write, so a burst of tiny random writes becomes one big sequential one. *Problem:* old versions of blocks are scattered through the log as dead space, and the disk fills with garbage. *Solution:* a *cleaner* (garbage collector) reads old segments, copies out the still-live blocks, and frees the segment — which costs read and write bandwidth, and is why log-structured designs struggle when the disk is nearly full.
+ Rebuild must read all 11 surviving disks and write one full 8 TB disk. At 150 MB/s the write alone is $8 times 10^12 \/ (150 times 10^6) = 53333$ s $approx 14.8$ *hours*, and in practice longer because production traffic competes. For nearly 15 hours the array has *no* redundancy, and it is doing a full read of 11 aging disks — exactly the stress that triggers a second failure. RAID 6 survives that second failure, which is why large arrays stopped using RAID 5.
+ `fsync()` forces the data to durable media, so the write cannot be absorbed by the page cache. Each one costs at least a seek + rotation + transfer, plus a second write for the journal: about 9-10 ms, giving roughly *100 per second*. Three fixes: (1) *Batch* — group many records into one `fsync()`; risk: you lose the whole batch on a crash, and latency for the first record in a batch rises. (2) *Move the log to an SSD or a battery-backed write cache*; risk: cost, and a non-battery-backed cache that lies about durability will lose data silently. (3) *Relax durability* — `fdatasync()` instead of `fsync()` (skips the metadata flush) or accept "committed to OS, not to disk"; risk: a power failure loses acknowledged writes. Only (1) and (2) are safe; (3) is a deliberate trade.
+ *Block size:* 100 M files of 2 KB. With 4 KB blocks each file wastes about 2 KB, so $100 times 10^6 times 2048 = 2.05 times 10^11$ B $approx 190$ GiB wasted; useful data is only 190 GiB, so *half the disk is waste*. Choose *1 KB blocks*: a 2 KB file uses 2 blocks with near-zero waste, at the cost of more pointers and slower sequential I/O — acceptable, because these files are tiny and never read sequentially in bulk. Better still, *inline small files inside the inode itself* (ext4 and NTFS both do this): a 2 KB file that fits in the inode costs *zero* data blocks and *one* read instead of two. *Inode strategy:* pre-allocate at least 100 M inodes — at 256 B each that is 25.6 GB of inode table, so it must be spread across cylinder groups so an inode sits near its data. Direct pointers matter here and indirect ones do not: with 1 KB blocks, 12 direct pointers already reach 12 KB, which covers essentially every file in this workload.
]

#section[Rapid fire: one-line answers]

#formulas(title: "Say these in one breath")[
+ *Where is a file's name stored?* In the directory entry, not the inode.
+ *What is an inode?* A fixed-size metadata record: type, size, owner, permissions, timestamps, link count and block pointers.
+ *Block vs sector?* Sector is the hardware's smallest unit (512 B or 4 KB); block is the file system's allocation unit (usually 4 KB).
+ *Hard link vs soft link?* Hard link is another name for the same inode; soft link is a small file containing a path.
+ *Can a hard link cross file systems?* No — inode numbers are only unique within one file system. A soft link can.
+ *Why no hard links to directories?* They would create cycles, and the tree would need garbage collection.
+ *What does `rm` actually do?* Removes a directory entry and decrements the link count. The file dies at count 0 with no open handles.
+ *Contiguous allocation — one strength, one weakness?* $O(1)$ random access; external fragmentation and no growth.
+ *Linked allocation — one strength, one weakness?* No external fragmentation; random access to block $k$ costs $k$ reads.
+ *What is FAT?* Linked allocation with all "next" pointers moved into one table at the front of the disk.
+ *Why 12 direct pointers?* Almost every real file is small; direct pointers make small files cost one read.
+ *Reads to reach a byte through double indirect?* Three: double index, inner index, data block.
+ *Max file size formula?* $("direct" + "ppb" + "ppb"^2 + "ppb"^3) times "block size"$, where ppb = block size / pointer size.
+ *Bitmap vs linked free list?* Bitmap makes finding contiguous runs easy and is small; a free list finds one block easily but not a run.
+ *What is journaling for?* Crash consistency — write the intent to a sequential log and commit, so recovery replays a log instead of scanning the disk.
+ *What is a sparse file?* A file with unwritten holes; the size is large but no blocks are allocated for the holes.
+ *Disk access time formula?* Seek + rotational latency + transfer.
+ *Average rotational latency?* Half a revolution: 30000/RPM milliseconds.
+ *Why is sequential I/O so much faster?* One seek and one rotation are amortised over a large transfer instead of paid per block.
+ *SSTF's weakness?* Starvation of requests far from the head.
+ *SCAN vs LOOK?* SCAN travels to the disk edge; LOOK turns around at the last request.
+ *Why C-SCAN, if it moves more?* Uniform waiting time — every cylinder is served once per sweep, in one direction.
+ *Best scheduler for an SSD?* `none` (FIFO) or `mq-deadline` — there is no seek to optimise.
+ *Polling vs interrupt vs DMA?* Polling burns the CPU waiting; interrupts cost one per word; DMA moves the whole block and interrupts once.
+ *Buffering vs caching vs spooling?* Buffering smooths a transfer in progress; caching keeps a reusable copy; spooling queues whole jobs for a serial device.
+ *RAID 0 / 1 / 5 / 6 / 10 in one word each?* Striping / mirroring / single parity / double parity / mirrored stripes.
+ *RAID 5 write penalty?* Four I/Os per small write: read old data, read old parity, write data, write parity.
+ *Is RAID a backup?* No. It survives disk failure, not deletion, corruption or fire.
+ *What is write amplification on an SSD?* Writing a little causes a lot of physical writes, because erase happens in large blocks and valid pages must be relocated first.
+ *What does TRIM do?* Tells the SSD which blocks hold deleted data so garbage collection stops copying them.
]

#revision[
*The three mappings.* name $arrow.r$ inode number (the directory) $arrow.r$ inode (the
metadata) $arrow.r$ block numbers (the data). Every question is about one of them.

*The inode formula.* pointers per block $=$ block size $\/$ pointer size. Max file $=$
$("direct" + "ppb" + "ppb"^2 + "ppb"^3) times "block size"$. With 4 KB blocks and 4-byte
pointers: 1024 ppb, and about *4 TiB*. Reads to a byte: direct 1, single 2, double 3,
triple 4.

*Links.* Hard link = same inode, bumps link count, one file system only. Soft link = its
own inode holding a path string, breaks if the target goes, crosses file systems.

*Disk time.* $T = T_"seek" + 30000\/"RPM" + "bytes"\/"rate"$. Memorise: 7200 RPM
$arrow.r$ 4.17 ms average latency; a random 4 KB read on such a disk is about *9.2 ms*, so
about *109 IOPS*.

*The sequential-versus-random number.* Same disk, same 4 MB: *0.43 MB/s scattered versus
78 MB/s contiguous — about 180 times*. Quote this whenever indexes, logs or batching come
up.

*Disk scheduling, on head 95 with queue 86, 147, 22, 91, 177, 40, 128:*
LOOK 237 $<$ SSTF 255 $<$ SCAN 281 $<$ C-LOOK 306 $<$ C-SCAN 394 $<$ FCFS 575.
SSTF starves; C-SCAN and C-LOOK buy fairness, not distance.

*RAID.* 0 = speed, no safety. 1 = mirror. 5 = $(n-1)c$, survives 1, *4 I/Os per small
write*. 6 = $(n-2)c$, survives 2. 10 = $n c\/2$, fast and safe. RAID is not a backup.

*Three sentences that win marks.*
+ "The file name is in the directory entry; the inode has everything except the name."
+ "Over 99% of a random disk read is seek and rotation, which is why scheduling and
  sequential layout matter so much."
+ "Disk scheduling optimises arm movement, so on an SSD it optimises nothing — use FIFO or
  a deadline scheduler and raise the queue depth."
]

]
