const { MinHeap, DSU, Deque, lowerBound, upperBound } = require('./toolkit.js');
let pass = 0, fail = 0;
const eq = (got, want, name) => {
  const g = JSON.stringify(got), w = JSON.stringify(want);
  if (g === w) { pass++; } else { fail++; console.log(`FAIL ${name}: got ${g} want ${w}`); }
};
// MinHeap
const h = new MinHeap(); [5,3,8,1,9,2].forEach(v => h.push(v));
eq([h.pop(),h.pop(),h.pop(),h.pop(),h.pop(),h.pop()], [1,2,3,5,8,9], 'minheap order');
eq(h.size, 0, 'minheap empty');
const mx = new MinHeap((a,b) => b - a); [5,3,8].forEach(v => mx.push(v));
eq(mx.pop(), 8, 'maxheap via cmp');
const pq = new MinHeap((a,b) => a[1] - b[1]); pq.push(['a',3]); pq.push(['b',1]);
eq(pq.pop(), ['b',1], 'heap of pairs');
// DSU
const d = new DSU(6);
eq(d.union(0,1), true, 'dsu union new');
d.union(1,2); eq(d.union(0,2), false, 'dsu union existing');
eq(d.find(2) === d.find(0), true, 'dsu connected');
eq(d.find(3) === d.find(0), false, 'dsu separate');
// Deque
const q = new Deque(); q.push(1); q.push(2); q.push(3);
eq(q.shift(), 1, 'deque shift'); eq(q.back(), 3, 'deque back'); eq(q.size, 2, 'deque size');
// binary search
const a = [1,3,3,5,7];
eq(lowerBound(a,3), 1, 'lowerBound'); eq(upperBound(a,3), 3, 'upperBound');
eq(lowerBound(a,0), 0, 'lowerBound below'); eq(lowerBound(a,9), 5, 'lowerBound above');
console.log(`\ntoolkit tests: ${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
