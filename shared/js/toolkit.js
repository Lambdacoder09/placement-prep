// ============================================================
//  JS TOOLKIT — what JavaScript does not give you but interviews assume.
//  Every implementation here is tested. Used across the DSA book.
// ============================================================

// ---- MinHeap / priority queue (JS has none built in) ----
class MinHeap {
  constructor(cmp = (a, b) => a - b) { this.a = []; this.cmp = cmp; }
  get size() { return this.a.length; }
  peek() { return this.a[0]; }
  push(v) {
    this.a.push(v);
    let i = this.a.length - 1;
    while (i > 0) {
      const p = (i - 1) >> 1;
      if (this.cmp(this.a[i], this.a[p]) >= 0) break;
      [this.a[i], this.a[p]] = [this.a[p], this.a[i]]; i = p;
    }
  }
  pop() {
    const top = this.a[0], last = this.a.pop();
    if (this.a.length) {
      this.a[0] = last;
      let i = 0;
      for (;;) {
        const l = 2*i+1, r = l+1; let m = i;
        if (l < this.a.length && this.cmp(this.a[l], this.a[m]) < 0) m = l;
        if (r < this.a.length && this.cmp(this.a[r], this.a[m]) < 0) m = r;
        if (m === i) break;
        [this.a[i], this.a[m]] = [this.a[m], this.a[i]]; i = m;
      }
    }
    return top;
  }
}

// ---- Disjoint Set Union ----
class DSU {
  constructor(n) { this.p = Array.from({length: n}, (_, i) => i); this.r = new Array(n).fill(0); }
  find(x) { while (this.p[x] !== x) { this.p[x] = this.p[this.p[x]]; x = this.p[x]; } return x; }
  union(a, b) {
    a = this.find(a); b = this.find(b);
    if (a === b) return false;
    if (this.r[a] < this.r[b]) [a, b] = [b, a];
    this.p[b] = a; if (this.r[a] === this.r[b]) this.r[a]++;
    return true;
  }
}

// ---- Deque backed by a plain array with head index (O(1) amortised shift) ----
class Deque {
  constructor() { this.a = []; this.h = 0; }
  get size() { return this.a.length - this.h; }
  push(v) { this.a.push(v); }
  pop() { return this.a.pop(); }
  shift() { const v = this.a[this.h++]; if (this.h * 2 > this.a.length) { this.a = this.a.slice(this.h); this.h = 0; } return v; }
  front() { return this.a[this.h]; }
  back() { return this.a[this.a.length - 1]; }
}

// ---- binary search helpers (JS has no lower_bound) ----
const lowerBound = (a, x) => { let lo = 0, hi = a.length; while (lo < hi) { const m = (lo+hi)>>1; a[m] < x ? lo = m+1 : hi = m; } return lo; };
const upperBound = (a, x) => { let lo = 0, hi = a.length; while (lo < hi) { const m = (lo+hi)>>1; a[m] <= x ? lo = m+1 : hi = m; } return lo; };

module.exports = { MinHeap, DSU, Deque, lowerBound, upperBound };
