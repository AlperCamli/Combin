// Spec sheets — type/color, vibe-check treatment, capture interaction notes.

// Type & color spec sheet — system primitives.
function SpecSheet() {
  const Row = ({ label, children }) => (
    <div style={{ display: 'grid', gridTemplateColumns: '110px 1fr', gap: 20, alignItems: 'baseline', padding: '12px 0', borderTop: `0.5px solid ${C.paperLine}` }}>
      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.2, color: C.inkMute, textTransform: 'uppercase' }}>{label}</div>
      <div>{children}</div>
    </div>
  );

  const swatches = [
    { name: 'paper',    val: C.paper,    note: 'background · warm off-white, magazine paper' },
    { name: 'paperDeep', val: C.paperDeep, note: 'sheet, divider, secondary surface' },
    { name: 'paperLine', val: C.paperLine, note: 'hairline · 0.5px' },
    { name: 'ink',      val: C.ink,      note: 'primary text · never #000' },
    { name: 'inkSoft',  val: C.inkSoft,  note: 'secondary text · body, captions' },
    { name: 'inkMute',  val: C.inkMute,  note: 'tertiary · timestamps, mono labels' },
    { name: 'accent',   val: C.accent,   note: 'terracotta-ink · capture armed, puzzle progress · ≤2 uses/screen' },
  ];

  const dswatches = [
    { name: 'dpaper',   val: C.dpaper,   note: 'warm-dim background — a different room' },
    { name: 'dpaperDeep', val: C.dpaperDeep, note: 'sheet on dim' },
    { name: 'dink',     val: C.dink,     note: 'primary text on dim' },
    { name: 'dinkSoft', val: C.dinkSoft, note: 'secondary on dim' },
    { name: 'daccent',  val: C.daccent,  note: 'terracotta · brightened for dim' },
  ];

  return (
    <div style={{ width: '100%', height: '100%', background: C.paper, color: C.ink, fontFamily: F.sans, padding: '40px 36px', overflow: 'auto', boxSizing: 'border-box' }}>
      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.4, color: C.inkMute, textTransform: 'uppercase' }}>Combin · system primitives</div>
      <div style={{ fontFamily: F.serif, fontSize: 30, lineHeight: 1.1, marginTop: 8, marginBottom: 28, letterSpacing: -0.3 }}>
        Type &amp; color spec.
      </div>

      {/* Type */}
      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.4, color: C.inkMute, textTransform: 'uppercase', marginTop: 12, marginBottom: 8 }}>typography</div>
      <Row label="Serif">
        <div style={{ fontFamily: F.serif, fontSize: 28, lineHeight: 1.15, color: C.ink, fontWeight: 400 }}>
          Newsreader — the editorial voice.
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute, marginTop: 6, letterSpacing: 0.4 }}>
          400 only · used for: vibe-check, daily insight, brand notes, expanded reads.
        </div>
      </Row>
      <Row label="Sans">
        <div style={{ fontFamily: F.sans, fontSize: 18, fontWeight: 400, color: C.ink }}>
          Geist — UI, microcopy, body. 400 / 500 only.
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute, marginTop: 6, letterSpacing: 0.4 }}>
          no italics in chrome · no weights heavier than 500.
        </div>
      </Row>
      <Row label="Mono">
        <div style={{ fontFamily: F.mono, fontSize: 12, letterSpacing: 1.3, textTransform: 'uppercase', color: C.inkMute }}>
          02 / 04 — section markers · uppercase only · 9.5–11px
        </div>
      </Row>
      <Row label="Scale">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div style={{ fontFamily: F.serif, fontSize: 36, lineHeight: 1, fontWeight: 400 }}>36 / display · welcome</div>
          <div style={{ fontFamily: F.serif, fontSize: 26, lineHeight: 1.18, fontWeight: 400 }}>26 / vibe-check · hero one-liner</div>
          <div style={{ fontFamily: F.serif, fontSize: 22, lineHeight: 1.25, fontWeight: 400 }}>22 / editorial title</div>
          <div style={{ fontFamily: F.serif, fontSize: 16, lineHeight: 1.55, fontWeight: 400 }}>16 / editorial body</div>
          <div style={{ fontFamily: F.sans, fontSize: 15.5, lineHeight: 1.45 }}>15.5 / sans body</div>
          <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.inkSoft }}>13.5 / sans secondary</div>
          <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.3, color: C.inkMute, textTransform: 'uppercase' }}>10 / mono · marker</div>
        </div>
      </Row>

      {/* Color */}
      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.4, color: C.inkMute, textTransform: 'uppercase', marginTop: 28, marginBottom: 8 }}>color · light</div>
      {swatches.map(s => (
        <Row key={s.name} label={s.name}>
          <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
            <div style={{ width: 34, height: 34, borderRadius: 2, background: s.val, boxShadow: `inset 0 0 0 0.5px ${C.paperLine}` }} />
            <div>
              <div style={{ fontFamily: F.mono, fontSize: 11, color: C.inkSoft }}>{s.val}</div>
              <div style={{ fontFamily: F.sans, fontSize: 12, color: C.inkSoft, marginTop: 2 }}>{s.note}</div>
            </div>
          </div>
        </Row>
      ))}

      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.4, color: C.inkMute, textTransform: 'uppercase', marginTop: 28, marginBottom: 8 }}>color · warm-dim</div>
      <div style={{ background: C.dpaper, borderRadius: 4, padding: '4px 16px' }}>
        {dswatches.map(s => (
          <div key={s.name} style={{ display: 'grid', gridTemplateColumns: '110px 1fr', gap: 20, alignItems: 'baseline', padding: '12px 0', borderTop: `0.5px solid ${C.dpaperLine}` }}>
            <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.2, color: C.dinkMute, textTransform: 'uppercase' }}>{s.name}</div>
            <div style={{ display: 'flex', gap: 14, alignItems: 'center' }}>
              <div style={{ width: 34, height: 34, borderRadius: 2, background: s.val, boxShadow: `inset 0 0 0 0.5px ${C.dpaperLine}` }} />
              <div>
                <div style={{ fontFamily: F.mono, fontSize: 11, color: C.dinkSoft }}>{s.val}</div>
                <div style={{ fontFamily: F.sans, fontSize: 12, color: C.dinkSoft, marginTop: 2 }}>{s.note}</div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Shapes */}
      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.4, color: C.inkMute, textTransform: 'uppercase', marginTop: 28, marginBottom: 8 }}>shape · radius</div>
      <Row label="Inputs">
        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <div style={{ width: 64, height: 36, background: C.paperDeep, borderRadius: 2, boxShadow: `inset 0 0 0 0.5px ${C.paperLine}` }} />
          <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute }}>2px · text fields, chips</div>
        </div>
      </Row>
      <Row label="Cards">
        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <div style={{ width: 64, height: 36, background: C.paperDeep, borderRadius: 4, boxShadow: `inset 0 0 0 0.5px ${C.paperLine}` }} />
          <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute }}>4px · photo containers, CTA, sheets-internal</div>
        </div>
      </Row>
      <Row label="Sheet">
        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <div style={{ width: 64, height: 36, background: C.paperDeep, borderTopLeftRadius: 14, borderTopRightRadius: 14, boxShadow: `inset 0 0 0 0.5px ${C.paperLine}` }} />
          <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute }}>14px · only on bottom-sheet top edge</div>
        </div>
      </Row>
      <Row label="Capture">
        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <div style={{ width: 36, height: 36, background: C.accent, borderRadius: '50%' }} />
          <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute }}>only fully-round element in the system</div>
        </div>
      </Row>

      {/* Don'ts */}
      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.4, color: C.inkMute, textTransform: 'uppercase', marginTop: 28, marginBottom: 8 }}>not allowed</div>
      <ul style={{ fontFamily: F.sans, fontSize: 13, color: C.inkSoft, lineHeight: 1.7, paddingLeft: 18, margin: 0 }}>
        <li>Pure #000 · pure #FFF · purple→blue gradients · any gradient on UI</li>
        <li>iOS-default 12px corner-radius pills as primary CTAs</li>
        <li>Sparkle / wand / star icons near AI features · emoji in UI chrome</li>
        <li>Loading spinners · progress bars during AI thinking</li>
        <li>Three-bullet feedback · score cards · star ratings · % confidence</li>
      </ul>
    </div>
  );
}

// Vibe-check treatment guide — sizing, leading, motion.
function VibeCheckGuide() {
  return (
    <div style={{ width: '100%', height: '100%', background: C.paper, color: C.ink, fontFamily: F.sans, padding: '40px 36px', overflow: 'auto', boxSizing: 'border-box' }}>
      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.4, color: C.inkMute, textTransform: 'uppercase' }}>Combin · signature element</div>
      <div style={{ fontFamily: F.serif, fontSize: 30, lineHeight: 1.1, marginTop: 8, marginBottom: 8, letterSpacing: -0.3 }}>
        The vibe-check.
      </div>
      <div style={{ fontFamily: F.sans, fontSize: 14, color: C.inkSoft, marginBottom: 28, maxWidth: 540, lineHeight: 1.5 }}>
        Treat it like a magazine pull-quote. The line <em>arrives</em>; it doesn't pop. Action chrome stays at the bottom edge, low-contrast, present but not pulling focus.
      </div>

      {/* large preview */}
      <div style={{ background: C.paperDeep, borderRadius: 4, padding: '36px 32px 32px', marginBottom: 28 }}>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, letterSpacing: 1.4, textTransform: 'uppercase', color: C.inkMute, marginBottom: 18 }}>
          ⟶ hero treatment, at rest
        </div>
        <div style={{ fontFamily: F.serif, fontSize: 26, lineHeight: 1.22, letterSpacing: -0.15, color: C.ink, fontWeight: 400, maxWidth: 520, textWrap: 'pretty' }}>
          Three textures, one mood. That's the trick.
        </div>
        <div style={{ height: 28 }} />
        <div style={{
          padding: '14px 14px 14px 12px',
          borderTop: `0.5px solid ${C.paperLine}`,
          borderBottom: `0.5px solid ${C.paperLine}`,
          display: 'flex', gap: 14, alignItems: 'center', maxWidth: 520,
        }}>
          <Photo w={50} h={60} tone="olive" label="" radius={2} />
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 6 }}>one tweak</div>
            <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.ink, lineHeight: 1.45 }}>Swap the belt for the olive one — pulls the palette tighter.</div>
          </div>
        </div>
      </div>

      {/* spec rows */}
      {[
        ['family', 'Newsreader · 400'],
        ['size', '26 / 28pt at iPhone 15 Pro · scales with Dynamic Type'],
        ['leading', '1.22 — generous, lets the line breathe'],
        ['tracking', '-0.15 to -0.20 · slightly tightened'],
        ['measure', '~28ch · never wider than ~520px'],
        ['color', 'C.ink · never the accent'],
        ['margin', '32px above · 28px below · 28px gutter sides'],
        ['motion in', '420ms · 8px translateY · ease-out · 80ms after photo settles'],
        ['motion out', 'crossfade with the next state · 280ms'],
        ['tweak card', 'enters 600–800ms after one-liner · separate composition · sans 13.5'],
        ['haptic', 'no haptic on result · soft on capture · soft on save'],
      ].map(([k, v]) => (
        <div key={k} style={{ display: 'grid', gridTemplateColumns: '110px 1fr', gap: 20, padding: '10px 0', borderTop: `0.5px solid ${C.paperLine}` }}>
          <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.2, color: C.inkMute, textTransform: 'uppercase' }}>{k}</div>
          <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.ink }}>{v}</div>
        </div>
      ))}

      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.4, color: C.inkMute, textTransform: 'uppercase', marginTop: 28, marginBottom: 12 }}>tone · examples</div>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 18, maxWidth: 700 }}>
        {[
          ['works', 'Quiet confidence — the kind people remember without knowing why.'],
          ['works', "Three textures, one mood. That's the trick."],
          ['needs a tweak', 'Almost there — one more anchoring piece and this lands.'],
          ['humor as kindness', 'Brave choice. Possibly too brave. Want a second opinion?'],
          ['humor', 'I have notes. Mostly affectionate.'],
          ['uncertain', "I'm 50/50 on this — the silhouette works but the proportions are tricky."],
        ].map(([k, q], i) => (
          <div key={i} style={{ borderTop: `0.5px solid ${C.paperLine}`, paddingTop: 12 }}>
            <div style={{ fontFamily: F.mono, fontSize: 9.5, letterSpacing: 1.2, color: C.accent, textTransform: 'uppercase', marginBottom: 8 }}>
              {k}
            </div>
            <div style={{ fontFamily: F.serif, fontSize: 16.5, lineHeight: 1.35, color: C.ink, textWrap: 'pretty' }}>
              {q}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// Capture → thinking → result interaction notes.
function InteractionNotes() {
  const beats = [
    { t: '0.00s', label: 'tap', body: 'Capture button compresses 4%, releases. Soft haptic (light impact).' },
    { t: '0.00–0.15s', label: 'freeze', body: 'Live preview swaps to the still. Whole frame scales 1.00→0.98 over 150ms, ease-out. No flash.' },
    { t: '0.15–0.45s', label: 'sheet', body: 'Bottom sheet rises from below. Snap, not bounce. 280ms, ease-out-quad. Sheet has 14px top corners; everything inside is 4px.' },
    { t: '0.45–~1.5s', label: 'looking', body: '"Looking…" in the serif appears. A very subtle ink-shimmer — gradient sweeps across the text every 1.6s, low contrast. No spinner. No bar.' },
    { t: '~1.5s', label: 'one-liner', body: '"Looking…" crossfades out, vibe-check fades up 8px from below. 420ms ease-out. The line arrives.' },
    { t: '+600–800ms', label: 'tweak', body: 'If a tweak exists, the card fades in below — separate composition. If no tweak, the line stands alone (correct).' },
    { t: '+1.6s', label: 'actions', body: 'Save · Share · Tell me more reveal at the bottom edge, low-contrast. 200ms fade. They\'re present, not pushing.' },
  ];

  return (
    <div style={{ width: '100%', height: '100%', background: C.paper, color: C.ink, fontFamily: F.sans, padding: '40px 36px', overflow: 'auto', boxSizing: 'border-box' }}>
      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.4, color: C.inkMute, textTransform: 'uppercase' }}>Combin · interaction</div>
      <div style={{ fontFamily: F.serif, fontSize: 30, lineHeight: 1.1, marginTop: 8, marginBottom: 8, letterSpacing: -0.3 }}>
        Capture → looking → read.
      </div>
      <div style={{ fontFamily: F.sans, fontSize: 14, color: C.inkSoft, marginBottom: 28, maxWidth: 560, lineHeight: 1.5 }}>
        The whole sequence is ~2 seconds. The job of the motion is to hide AI latency behind a feeling of intentionality.
      </div>

      {/* timeline */}
      <div style={{ position: 'relative', paddingLeft: 100 }}>
        <div style={{ position: 'absolute', left: 88, top: 4, bottom: 4, width: 1, background: C.paperLine }} />
        {beats.map((b, i) => (
          <div key={i} style={{ position: 'relative', paddingBottom: 22 }}>
            <div style={{
              position: 'absolute', left: -100, top: 4, width: 78,
              fontFamily: F.mono, fontSize: 10, letterSpacing: 0.6, color: C.inkMute, textAlign: 'right',
            }}>{b.t}</div>
            <div style={{
              position: 'absolute', left: -16, top: 7, width: 9, height: 9, borderRadius: '50%',
              background: C.paper, boxShadow: `inset 0 0 0 1.5px ${C.ink}`,
            }} />
            <div style={{ fontFamily: F.serif, fontSize: 18, lineHeight: 1.2, color: C.ink, marginBottom: 4 }}>{b.label}</div>
            <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.inkSoft, lineHeight: 1.55, maxWidth: 540 }}>{b.body}</div>
          </div>
        ))}
      </div>

      <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.4, color: C.inkMute, textTransform: 'uppercase', marginTop: 12, marginBottom: 10 }}>guardrails</div>
      <ul style={{ fontFamily: F.sans, fontSize: 13.5, color: C.inkSoft, lineHeight: 1.7, paddingLeft: 18, margin: 0, maxWidth: 580 }}>
        <li>If the API returns in &lt;600ms, hold on "Looking…" until 1.2s — never feel instant. Instant feels cheap.</li>
        <li>If it takes &gt;3s, "Looking…" subtly shifts to "Still looking — almost there." in the same serif.</li>
        <li>No haptic on result delivery. The reward is the line itself.</li>
        <li>If retry is needed, do not bounce back to camera. Stay in the sheet, replace one-liner with the warm fallback ("I can't quite see the outfit — want to try another angle?")</li>
      </ul>
    </div>
  );
}

Object.assign(window, { SpecSheet, VibeCheckGuide, InteractionNotes });
