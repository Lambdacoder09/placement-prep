#!/usr/bin/env python3
"""Convert the book's .typ chapters to readable Markdown. Bracket-aware."""
import re, glob, os, pathlib

def match_block(s, i):
    """s[i] == '['. Return (inner, index_after_closing)."""
    d, j = 0, i
    while j < len(s):
        c = s[j]
        if c == '\\': j += 2; continue
        if c == '[': d += 1
        elif c == ']':
            d -= 1
            if d == 0: return s[i+1:j], j+1
        j += 1
    return s[i+1:], len(s)


LAYOUT = ('align','text','block','box','pad','stack','place','hide','par','set','show','grid')
def unwrap(s):
    """Strip typst comments and unwrap pure-layout #fn(...)[body] -> body."""
    s = re.sub(r'^\s*//.*$', '', s, flags=re.M)
    s = re.sub(r'/\*.*?\*/', '', s, flags=re.S)
    changed = True
    while changed:
        changed = False
        for fn in LAYOUT:
            m = re.search(r'#' + fn + r'\b', s)
            while m:
                j = m.end()
                if j < len(s) and s[j] == '(':
                    d,k = 0,j
                    while k < len(s):
                        if s[k]=='(': d+=1
                        elif s[k]==')':
                            d-=1
                            if d==0: break
                        k+=1
                    j = k+1
                if j < len(s) and s[j] == '[':
                    inner, end = match_block(s, j)
                    s = s[:m.start()] + inner + s[end:]
                    changed = True
                else:
                    s = s[:m.start()] + s[j:]
                    changed = True
                m = re.search(r'#' + fn + r'\b', s)
    s = re.sub(r'^\s*\]\s*$', '', s, flags=re.M)
    s = re.sub(r'#(pagebreak|line|colbreak)\([^)]*\)', '', s)
    return s

TIERS = {'0': 'Warm-up',
         '1': 'Tier 1 — Service · TCS NQT, Accenture, Infosys, Wipro, Capgemini',
         '2': 'Tier 2 — Singapore & Thailand · Grab, Shopee, GIC, DBS, Agoda, SCB',
         '3': 'Tier 3 — Product · Google, Amazon, Microsoft, Goldman Sachs, D.E. Shaw, Adobe'}

def quote(t, marker=''):
    label = marker.replace('>','').strip()
    body = t.strip()
    return (label + '\n\n' if label else '') + body + '\n'


MATHOPS = [('times',r'\\times'),('div',r'\\div'),('quad',r'\\quad'),('approx',r'\\approx'),
           ('Delta',r'\\Delta'),('therefore',r'\\therefore'),('dots',r'\\dots'),
           ('cdot',r'\\cdot'),('bar',r'\\mid'),('=>',r'\\Rightarrow'),
           ('<=',r'\\le'),('>=',r'\\ge'),('!=',r'\\ne')]
def mathfix(t):
    def fix(m):
        inner = m.group(1)
        for a,b in MATHOPS:
            if a[0].isalpha():
                inner = re.sub(r'\b'+a+r'\b', b, inner)
            else:
                inner = inner.replace(a,b)
        return '$'+inner+'$'
    return re.sub(r'\$([^$]*)\$', fix, t)

def inline(t):
    t = t.replace('\\/', '/').replace('\\$', '$').replace('\\%', '%')
    t = re.sub(r'#h\(\s*[\d.]+\w*\s*\)', ' ', t)
    t = re.sub(r'#v\(\s*[-\d.]+\w*\s*\)', '', t)
    t = re.sub(r'#linebreak\(\)', '  \n', t)
    # Typst emphasis *x* -> **x**  (avoid touching existing **)
    t = re.sub(r'(?<![*\w])\*([^*\n]+?)\*(?![*\w])', r'**\1**', t)
    t = re.sub(r'(?<![_\w])_([^_\n]+?)_(?![_\w])', r'*\1*', t)
    return mathfix(t)

def convert(s):
    s = re.sub(r'#import\s+"[^"]+"\s*:\s*\*\s*\n?', '', s)
    out = []
    i = 0
    while i < len(s):
        m = re.compile(
            r'#(chapter|section|subsection|formulas|tier-header|ex|sol|ans|trick|trap|note|practice|key|revision|opts)'
        ).search(s, i)
        if not m:
            out.append(inline(s[i:])); break
        out.append(inline(s[i:m.start()]))
        name = m.group(1)
        j = m.end()
        # parse optional (...) args
        args = ''
        if j < len(s) and s[j] == '(':
            d, k = 0, j
            while k < len(s):
                if s[k] == '(': d += 1
                elif s[k] == ')':
                    d -= 1
                    if d == 0: break
                k += 1
            args = s[j+1:k]; j = k + 1
        body = ''
        if j < len(s) and s[j] == '[':
            body, j = match_block(s, j)
        i = j

        def a(key, default=''):
            mm = re.search(key + r'\s*:\s*"([^"]*)"', args)
            return mm.group(1) if mm else default

        if name == 'chapter':
            n = re.search(r'num:\s*(\d+)', args)
            out.append(f"# Chapter {n.group(1) if n else ''} — {a('title')}\n\n*{a('tagline')}*\n")
            out.append(convert(body))
        elif name == 'section':      out.append(f"\n## {inline(body).strip()}\n")
        elif name == 'subsection':   out.append(f"\n### {inline(body).strip()}\n")
        elif name == 'tier-header':
            t = re.search(r'(\d)', args)
            out.append(f"\n### {TIERS.get(t.group(1) if t else '1','')}\n")
        elif name == 'formulas':
            out.append(f"\n**{a('title','What you need to know').upper()}**\n\n{convert(body)}\n")
        elif name == 'ex':
            n  = re.search(r'^\s*(\d+)', args)
            tg = a('asked')
            out.append(f"\n**Example {n.group(1) if n else ''}**"
                       + (f" `{tg}`" if tg else "") + "\n\n" + convert(body).strip() + "\n")
        elif name == 'sol':          out.append('\n' + quote(convert(body), '**Solution**'))
        elif name == 'ans':          out.append(f"\n**➜ Answer: {inline(body).strip()}**\n")
        elif name == 'trick':        out.append('\n' + quote(convert(body), '---\n💡 **SHORTCUT**'))
        elif name == 'trap':         out.append('\n' + quote(convert(body), '---\n⚠️ **TRAP**'))
        elif name == 'note':         out.append('\n' + quote(convert(body)))
        elif name == 'practice':
            t = re.search(r'tier:\s*(\d)', args)
            tt = TIERS.get(t.group(1) if t else '1','').split(' · ')[0]
            tm = a('time')
            out.append(f"\n#### Practice — {tt}" + (f" *(target: {tm})*" if tm else "") + "\n\n"
                       + convert(body) + "\n")
        elif name == 'key':
            out.append("\n<details>\n<summary><b>Answer key</b></summary>\n\n"
                       + convert(body) + "\n</details>\n")
        elif name == 'revision':
            out.append("\n## 📋 One-page revision card\n\n" + convert(body) + "\n")
        elif name == 'opts':
            vals = [v.strip() for v in re.split(r',(?![^(]*\))', args)]
            out.append('\n' + '  '.join(f'**({chr(97+k)})** {inline(v)}' for k, v in enumerate(vals)) + '\n')
    t = ''.join(out)
    t = re.sub(r'\n{3,}', '\n\n', t)
    return t

os.makedirs('markdown', exist_ok=True)
files = sorted(glob.glob('chapters/front-*.typ')) + sorted(glob.glob('chapters/ch*.typ')) + \
        sorted(glob.glob('chapters/back-*.typ'))
parts = []
for f in files:
    md = convert(unwrap(open(f).read())).strip() + '\n'
    open('markdown/' + pathlib.Path(f).stem + '.md', 'w').write(md)
    parts.append(md)
open('markdown/BOOK.md', 'w').write('\n\n---\n\n'.join(parts))
print(f"wrote {len(files)} files")
# integrity
whole = open('markdown/BOOK.md').read()
print("stray '#macro' leftovers:", len(re.findall(r'#(ex|sol|ans|trick|trap|practice|key|revision)\(?\[', whole)))
print("orphan ']' lines       :", len(re.findall(r'^\s*\]\s*$', whole, re.M)))
