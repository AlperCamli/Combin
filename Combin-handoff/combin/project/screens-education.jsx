// Journey 6 — Education (Daily Insight, Daily Puzzle, deep-dives).

function S_EduHome() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 24px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ fontFamily: F.serif, fontSize: 22, fontWeight: 400, letterSpacing: -0.2 }}>Education</div>
        <Sym name="dots" size={18} color={C.inkSoft} />
      </div>
      <div style={{ overflowY: 'auto', flex: 1 }}>
        {/* first-visit framing */}
        <div style={{ padding: '14px 24px 0' }}>
          <div style={{
            fontFamily: F.sans, fontSize: 13, lineHeight: 1.55,
            color: C.inkSoft, textWrap: 'pretty',
            paddingLeft: 12, borderLeft: `1px solid ${C.paperLine}`,
          }}>
            Things to read about fashion, plus a daily puzzle. Built to teach, not to sell.
          </div>
        </div>
        {/* Today */}
        <div style={{ padding: '20px 24px 0' }}>
          <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 14 }}>today · Wed 7 May</div>
          {/* Daily Insight */}
          <div style={{ marginBottom: 18 }}>
            <Photo w="100%" h={170} tone="ecru" label="daily insight · hero image" radius={4} />
            <div style={{ marginTop: 14 }}>
              <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.accent, letterSpacing: 1.3, textTransform: 'uppercase' }}>daily insight</div>
              <div style={{ fontFamily: F.serif, fontSize: 22, lineHeight: 1.2, fontWeight: 400, letterSpacing: -0.15, marginTop: 6, textWrap: 'pretty' }}>
                Why the half-tuck reads as confidence.
              </div>
              <div style={{ fontFamily: F.sans, fontSize: 13, color: C.inkSoft, marginTop: 6 }}>3 min read</div>
            </div>
          </div>
          {/* Daily Puzzle — second signature element */}
          <div style={{
            marginTop: 6, marginBottom: 22, padding: '20px 18px 18px',
            background: C.paperDeep, borderRadius: 4, position: 'relative',
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
              <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.accent, letterSpacing: 1.3, textTransform: 'uppercase' }}>daily puzzle</div>
              <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.2 }}>day 47</div>
            </div>
            <div style={{ fontFamily: F.serif, fontSize: 19, lineHeight: 1.3, fontWeight: 400, marginTop: 10, textWrap: 'pretty' }}>
              Find the missing piece — make this serious, like a meeting where you want to be remembered.
            </div>
            {/* mini outfit row */}
            <div style={{ display: 'flex', gap: 6, marginTop: 14 }}>
              {['ecru', 'char', '_slot_', 'rust'].map((t, i) =>
                t === '_slot_'
                  ? <div key={i} style={{ flex: 1, height: 78, borderRadius: 2, boxShadow: `inset 0 0 0 1px ${C.accent}`, display: 'flex', alignItems: 'center', justifyContent: 'center', color: C.accent }}>
                      <Sym name="plus" size={18} color={C.accent} stroke={1.6} />
                    </div>
                  : <div key={i} style={{ flex: 1 }}><Photo w="100%" h={78} tone={t} label="" radius={2} /></div>
              )}
            </div>
            <div style={{ marginTop: 14, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ fontFamily: F.sans, fontSize: 12, color: C.inkSoft }}>One per day. No timer.</div>
              <div style={{
                fontFamily: F.sans, fontSize: 13, fontWeight: 500, color: C.paper,
                background: C.ink, padding: '8px 14px', borderRadius: 2,
              }}>Play</div>
            </div>
          </div>
        </div>
        {/* Curated feed */}
        <div style={{ padding: '6px 24px 0' }}>
          <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 14 }}>this week</div>
          {[
            { tone: 'olive', kind: 'deep dive',     title: 'The Antwerp Six, in two collections.' },
            { tone: 'cool',  kind: 'film',          title: 'Bill Cunningham New York — streaming.' },
            { tone: 'rust',  kind: 'designer',      title: 'Grace Wales Bonner: an introduction.' },
            { tone: 'char',  kind: 'glossary',      title: 'What we mean when we say "drape."' },
          ].map((it, i) => (
            <div key={i} style={{
              display: 'flex', gap: 14, padding: '14px 0',
              borderTop: `0.5px solid ${C.paperLine}`,
              borderBottom: i === 3 ? `0.5px solid ${C.paperLine}` : 'none',
            }}>
              <Photo w={86} h={110} tone={it.tone} label="" radius={2} />
              <div style={{ flex: 1 }}>
                <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>{it.kind}</div>
                <div style={{ fontFamily: F.serif, fontSize: 15.5, lineHeight: 1.3, fontWeight: 400, marginTop: 4, textWrap: 'pretty' }}>{it.title}</div>
              </div>
            </div>
          ))}
        </div>
        <div style={{ height: 24 }} />
      </div>
      <TabBar active="edu" />
    </Screen>
  );
}

function S_DailyInsight() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Sym name="chevron-d" size={18} stroke={1.6} color={C.inkSoft} />
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>daily insight</div>
        <Sym name="dots" size={18} color={C.inkSoft} />
      </div>
      <div style={{ overflowY: 'auto', padding: '8px 0 0' }}>
        <div style={{ padding: '0 24px' }}>
          <Photo w="100%" h={220} tone="ecru" label="hero · half-tuck reference" radius={4} />
        </div>
        <div style={{ padding: '24px 28px 0' }}>
          <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>styling principle · 3 min</div>
          <div style={{ fontFamily: F.serif, fontSize: 28, lineHeight: 1.15, fontWeight: 400, letterSpacing: -0.3, marginTop: 8, textWrap: 'pretty' }}>
            Why the half-tuck reads as confidence.
          </div>
        </div>
        <div style={{ padding: '20px 28px 0' }}>
          <p style={{ fontFamily: F.serif, fontSize: 16.5, lineHeight: 1.55, fontWeight: 400, color: C.ink, margin: 0, textWrap: 'pretty' }}>
            <span style={{ fontFamily: F.serif, fontSize: 28, float: 'left', lineHeight: 0.85, marginRight: 6, marginTop: 4 }}>T</span>here are very few moves in dressing that come with so little risk and so much return. The half-tuck is one of them.
          </p>
          <p style={{ fontFamily: F.serif, fontSize: 16.5, lineHeight: 1.55, fontWeight: 400, color: C.ink, marginTop: 14, textWrap: 'pretty' }}>
            What it does, mechanically, is reveal the waistband — and with it, the line of the trouser. The eye reads structure where it would otherwise read drape. It's a small act of organization in an outfit that might otherwise look unfinished.
          </p>
          <p style={{ fontFamily: F.serif, fontSize: 16.5, lineHeight: 1.55, fontWeight: 400, color: C.inkSoft, marginTop: 14, textWrap: 'pretty' }}>
            What it doesn't do is read as care. It reads as someone who got dressed quickly, and well. That's the whole trick.
          </p>
        </div>
        <div style={{ height: 28 }} />
      </div>
    </Screen>
  );
}

function S_PuzzlePlay() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Sym name="x" size={18} stroke={1.6} color={C.inkSoft} />
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>daily puzzle · day 47</div>
        <div style={{ width: 18 }} />
      </div>
      <div style={{ padding: '24px 28px 0' }}>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.accent, letterSpacing: 1.3, textTransform: 'uppercase' }}>the condition</div>
        <div style={{ fontFamily: F.serif, fontSize: 24, lineHeight: 1.2, fontWeight: 400, letterSpacing: -0.2, marginTop: 8, textWrap: 'pretty' }}>
          Make this serious, like a meeting where you want to be remembered.
        </div>
      </div>
      {/* base outfit */}
      <div style={{ padding: '28px 24px 0' }}>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 10 }}>the base · find what's missing</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          {[
            { tone: 'ecru',  l: 'cream camp shirt' },
            { tone: 'char',  l: 'wool trouser' },
            { tone: '_slot_', l: 'something for the feet' },
            { tone: 'warm',  l: 'gold chain · simple' },
          ].map((g, i) => (
            g.tone === '_slot_'
              ? <div key={i} style={{
                  height: 130, borderRadius: 2,
                  boxShadow: `inset 0 0 0 1.5px ${C.accent}`,
                  display: 'flex', flexDirection: 'column',
                  alignItems: 'center', justifyContent: 'center',
                  color: C.accent, gap: 6,
                }}>
                  <Sym name="plus" size={20} color={C.accent} stroke={1.6} />
                  <div style={{ fontFamily: F.mono, fontSize: 9, letterSpacing: 1, textTransform: 'uppercase' }}>{g.l}</div>
                </div>
              : <div key={i} style={{ position: 'relative' }}>
                  <Photo w="100%" h={130} tone={g.tone} label="" radius={2} />
                  <div style={{
                    position: 'absolute', bottom: 6, left: 6, right: 6,
                    fontFamily: F.mono, fontSize: 9, color: C.paper,
                    background: 'rgba(20,16,12,0.62)', padding: '3px 6px', borderRadius: 1,
                    letterSpacing: 0.4,
                  }}>{g.l}</div>
                </div>
          ))}
        </div>
      </div>
      <div style={{ flex: 1 }} />
      {/* search affordance */}
      <div style={{ padding: '0 24px 28px' }}>
        <div style={{
          padding: '14px 16px', borderRadius: 2,
          boxShadow: `inset 0 0 0 0.5px ${C.paperLine}`,
          display: 'flex', alignItems: 'center', gap: 10,
        }}>
          <div style={{ fontFamily: F.sans, fontSize: 13, color: C.inkMute }}>Search the closet · type or browse</div>
        </div>
      </div>
    </Screen>
  );
}

function S_PuzzleResponse() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Sym name="chevron-l" size={18} stroke={1.6} color={C.inkSoft} />
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>daily puzzle</div>
        <div style={{ width: 18 }} />
      </div>
      {/* user's pick at top */}
      <div style={{ padding: '20px 24px 0' }}>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 8 }}>you picked</div>
        <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
          <Photo w={84} h={104} tone="ecru" label="" radius={2} />
          <div>
            <div style={{ fontFamily: F.serif, fontSize: 16, lineHeight: 1.25 }}>White canvas sneaker</div>
            <div style={{ fontFamily: F.sans, fontSize: 12, color: C.inkSoft, marginTop: 4 }}>Found in: Common Projects archive</div>
          </div>
        </div>
      </div>
      {/* response — direction language, never "wrong" */}
      <div style={{ padding: '28px 28px 0' }}>
        <div style={{ fontFamily: F.serif, fontSize: 22, lineHeight: 1.3, fontWeight: 400, letterSpacing: -0.15, color: C.ink, textWrap: 'pretty' }}>
          Those soften the whole thing — the outfit suddenly reads weekend, not boardroom.
        </div>
        <div style={{ fontFamily: F.serif, fontSize: 16, lineHeight: 1.55, color: C.inkSoft, marginTop: 16, textWrap: 'pretty' }}>
          The canvas pulls against the wool and undoes the formality the trousers are doing. For "serious," look for leather, darker, with a clean toe.
        </div>
      </div>
      <div style={{ flex: 1 }} />
      {/* unlock — different flavors of correct */}
      <div style={{ padding: '20px 24px 0', borderTop: `0.5px solid ${C.paperLine}` }}>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 12, paddingTop: 16 }}>three that would have worked</div>
        <div style={{ display: 'flex', gap: 8, overflowX: 'auto' }}>
          {[
            { tone: 'char', l: 'CONSERVATIVE',  s: 'Black oxford. Polished. Reads serious without trying.' },
            { tone: 'rust', l: 'INTERESTING',   s: 'Brown brogue. Brings a third texture, lifts the formality.' },
            { tone: 'olive', l: 'RISKIER',      s: 'Suede loafer. Quiet, but the right kind of quiet.' },
          ].map((it, i) => (
            <div key={i} style={{ flex: '0 0 220px' }}>
              <Photo w="100%" h={140} tone={it.tone} label="" radius={2} />
              <div style={{ fontFamily: F.mono, fontSize: 9, color: C.accent, letterSpacing: 1.4, marginTop: 8 }}>{it.l}</div>
              <div style={{ fontFamily: F.serif, fontSize: 13, lineHeight: 1.4, marginTop: 4, color: C.ink, textWrap: 'pretty' }}>{it.s}</div>
            </div>
          ))}
        </div>
      </div>
      <div style={{ padding: '20px 24px 26px' }}>
        <Btn primary>Tomorrow's puzzle drops at 7am</Btn>
      </div>
    </Screen>
  );
}

Object.assign(window, { S_EduHome, S_DailyInsight, S_PuzzlePlay, S_PuzzleResponse });
