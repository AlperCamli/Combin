// Journey 4 — Wardrobe browsing & correction.

// First-visit Wardrobe: the photo grid (Looks) — the user's fashion history.
// Default view on every visit; Items lives behind a toggle. First-visit framing
// sits inline at the top + bottom of the page and disappears after first view.
function S_WardrobeGrid() {
  // Looks grid — 3-col. Mix of tones to read as varied wardrobe history.
  const looks = [
    'ecru', 'warm', 'olive',
    'char', 'rust', 'cool',
    'warm', 'ecru', 'char',
    'olive', 'cool', 'rust',
  ];
  return (
    <Screen>
      <IOSStatusBar />
      {/* top chrome — tab title only, low contrast */}
      <div style={{ padding: '12px 24px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ fontFamily: F.sans, fontSize: 13, color: C.inkSoft, fontWeight: 500 }}>Wardrobe</div>
        <div style={{ width: 32, height: 32, color: C.inkMute, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="dots" size={16} />
        </div>
      </div>
      <div style={{ overflowY: 'auto', flex: 1 }}>
        {/* first-visit framing — top */}
        <div style={{ padding: '24px 28px 8px' }}>
          <div style={{
            fontFamily: F.serif, fontSize: 22, lineHeight: 1.25,
            letterSpacing: -0.1, fontWeight: 400, color: C.ink, textWrap: 'pretty',
          }}>
            This is what I caught from your photo. Every vibe-check adds to it.
          </div>
        </div>
        {/* tiny header — the "always visible" version, descriptive not motivating */}
        <div style={{ padding: '20px 24px 14px', display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>
            your fashion history
          </div>
          <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute, letterSpacing: 0.6 }}>
            1 look · 4 items
          </div>
        </div>
        {/* Looks / Items toggle — custom pill, on-brand */}
        <div style={{ padding: '0 24px 14px', display: 'flex', gap: 0 }}>
          <div style={{ display: 'inline-flex', boxShadow: `inset 0 0 0 0.5px ${C.paperLine}`, borderRadius: 2 }}>
            {[['Looks', true], ['Items', false]].map(([t, on]) => (
              <div key={t} style={{
                padding: '7px 16px', fontFamily: F.sans, fontSize: 12.5,
                fontWeight: on ? 500 : 400,
                background: on ? C.ink : 'transparent',
                color: on ? C.paper : C.inkSoft,
                borderRadius: 2,
              }}>{t}</div>
            ))}
          </div>
        </div>
        {/* the grid — first cell is the just-captured outfit, framed to feel new */}
        <div style={{ padding: '0 14px', display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 2 }}>
          {looks.map((tone, i) => (
            <div key={i} style={{ position: 'relative' }}>
              <Photo w="100%" h={118} tone={tone} label={i === 0 ? "just now" : ""} radius={0} />
              {i === 0 && (
                <div style={{
                  position: 'absolute', top: 6, left: 6,
                  padding: '3px 6px', borderRadius: 2,
                  background: 'rgba(245,242,236,0.92)',
                  fontFamily: F.mono, fontSize: 9, letterSpacing: 0.8,
                  textTransform: 'uppercase', color: C.ink, fontWeight: 500,
                }}>just now</div>
              )}
              {/* faded cells past the first to suggest "fills in over time" */}
              {i > 0 && (
                <div style={{
                  position: 'absolute', inset: 0,
                  background: 'rgba(245,242,236,0.55)',
                }} />
              )}
            </div>
          ))}
        </div>
        {/* first-visit framing — bottom */}
        <div style={{ padding: '22px 28px 28px' }}>
          <div style={{
            fontFamily: F.sans, fontSize: 13, lineHeight: 1.55,
            color: C.inkSoft, textWrap: 'pretty',
            paddingLeft: 12, borderLeft: `1px solid ${C.paperLine}`,
          }}>
            Keep taking vibe-checks and this fills in. After a couple of weeks, I'll start spotting things you already own.
          </div>
        </div>
      </div>
      <TabBar active="wardrobe" />
    </Screen>
  );
}

// Wardrobe — Items mode. Categorized garments view (the previous default).
function S_WardrobeItems() {
  const cats = [
    { name: 'tops',     count: 14, items: [['ecru'], ['warm'], ['cool'], ['olive']] },
    { name: 'outerwear',count: 6,  items: [['warm'], ['char'], ['olive']] },
    { name: 'bottoms',  count: 9,  items: [['char'], ['rust'], ['ecru'], ['cool']] },
    { name: 'shoes',    count: 5,  items: [['rust'], ['char']] },
  ];
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '12px 24px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ fontFamily: F.sans, fontSize: 13, color: C.inkSoft, fontWeight: 500 }}>Wardrobe</div>
        <div style={{ width: 32, height: 32, color: C.inkMute, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="dots" size={16} />
        </div>
      </div>
      <div style={{ padding: '20px 24px 14px', display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
        <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>
          your fashion history
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute, letterSpacing: 0.6 }}>
          12 looks · 34 items
        </div>
      </div>
      <div style={{ padding: '0 24px 14px' }}>
        <div style={{ display: 'inline-flex', boxShadow: `inset 0 0 0 0.5px ${C.paperLine}`, borderRadius: 2 }}>
          {[['Looks', false], ['Items', true]].map(([t, on]) => (
            <div key={t} style={{
              padding: '7px 16px', fontFamily: F.sans, fontSize: 12.5,
              fontWeight: on ? 500 : 400,
              background: on ? C.ink : 'transparent',
              color: on ? C.paper : C.inkSoft,
              borderRadius: 2,
            }}>{t}</div>
          ))}
        </div>
      </div>
      <div style={{ overflowY: 'auto', padding: '6px 24px 16px', flex: 1 }}>
        {cats.map((cat) => (
          <div key={cat.name} style={{ marginBottom: 22 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 8 }}>
              <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>{cat.name}</div>
              <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute }}>{cat.count}</div>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 6 }}>
              {cat.items.map((it, i) => (
                <Photo key={i} w="100%" h={78} tone={it[0]} label="" radius={2} />
              ))}
            </div>
          </div>
        ))}
      </div>
      <TabBar active="wardrobe" />
    </Screen>
  );
}

function S_ItemDetail() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ width: 36, height: 36, color: C.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="chevron-l" size={18} stroke={1.6} />
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>your closet</div>
        <div style={{ width: 36, height: 36, color: C.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="dots" size={18} />
        </div>
      </div>
      <div style={{ overflowY: 'auto' }}>
        <div style={{ padding: '12px 28px 0' }}>
          <Photo w="100%" h={232} tone="warm" label="extracted source · the camel overcoat" radius={4} />
        </div>
        <div style={{ padding: '20px 28px 0' }}>
          <div style={{ fontFamily: F.serif, fontSize: 22, lineHeight: 1.2, fontWeight: 400, letterSpacing: -0.1 }}>
            Camel overcoat
          </div>
          <div style={{ fontFamily: F.sans, fontSize: 12.5, color: C.inkSoft, marginTop: 4 }}>Worn 4 times &middot; last seen Mar 10</div>
        </div>
        {/* attributes — inline edit */}
        <div style={{ padding: '20px 24px 0' }}>
          <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 8, paddingLeft: 4 }}>what i see</div>
          {[
            ['Color', 'Camel'],
            ['Type', 'Overcoat'],
            ['Material', 'Wool blend'],
            ['Formality', 'Smart'],
          ].map(([k, v], i) => (
            <div key={k} style={{
              display: 'flex', justifyContent: 'space-between', alignItems: 'center',
              padding: '12px 4px', borderTop: i === 0 ? `0.5px solid ${C.paperLine}` : 'none',
              borderBottom: `0.5px solid ${C.paperLine}`,
            }}>
              <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.ink }}>{k}</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.inkSoft }}>{v}</div>
                <div style={{ fontFamily: F.sans, fontSize: 11, color: C.accent, padding: '2px 8px', boxShadow: `inset 0 0 0 0.5px ${C.accent}`, borderRadius: 2 }}>Edit</div>
              </div>
            </div>
          ))}
        </div>
        {/* worn in */}
        <div style={{ padding: '24px 24px 0' }}>
          <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 8 }}>worn in 4 looks</div>
          <div style={{ display: 'flex', gap: 6, overflowX: 'auto' }}>
            {['warm', 'ecru', 'olive', 'cool'].map((t, i) => (
              <Photo key={i} w={86} h={108} tone={t} label="" radius={2} />
            ))}
          </div>
        </div>
        {/* destructive actions */}
        <div style={{ padding: '24px 24px 30px', display: 'flex', gap: 8 }}>
          <div style={{ flex: 1 }}><Btn>Mark as donated</Btn></div>
          <div style={{ flex: 1 }}><Btn>Hide</Btn></div>
        </div>
      </div>
    </Screen>
  );
}

function S_InlineCorrect() {
  // contextual correction — happens on the result/planner screen, not in wardrobe.
  return (
    <Screen>
      <IOSStatusBar />
      {/* dimmed result screen behind */}
      <div style={{ position: 'absolute', inset: 0, opacity: 0.35 }}>
        <div style={{ padding: '40px 28px 0' }}>
          <Photo w="100%" h={210} tone="warm" label="" radius={4} />
          <div style={{ fontFamily: F.serif, fontSize: 22, lineHeight: 1.2, marginTop: 24 }}>
            Try the black jacket from last week — pulls the palette tighter.
          </div>
        </div>
      </div>
      {/* sheet */}
      <div style={{ flex: 1 }} />
      <div style={{
        position: 'relative', background: C.paper,
        borderTopLeftRadius: 14, borderTopRightRadius: 14,
        padding: '14px 24px 28px',
      }}>
        <div style={{ width: 36, height: 4, borderRadius: 2, background: C.paperLine, margin: '0 auto 18px' }} />
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 10 }}>fix in place</div>
        <div style={{ fontFamily: F.serif, fontSize: 19, lineHeight: 1.25, fontWeight: 400, marginBottom: 14, textWrap: 'pretty' }}>
          The jacket is —
        </div>
        <div style={{ display: 'flex', gap: 10, marginBottom: 18 }}>
          <Photo w={64} h={78} tone="char" label="" radius={2} />
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 6 }}>
            {[
              ['Black', false],
              ['Navy', true],
              ['Charcoal', false],
              ['Something else', false],
            ].map(([t, on]) => (
              <div key={t} style={{
                padding: '10px 12px', borderRadius: 2,
                background: on ? C.ink : 'transparent',
                color: on ? C.paper : C.ink,
                boxShadow: on ? 'none' : `inset 0 0 0 0.5px ${C.paperLine}`,
                fontFamily: F.sans, fontSize: 13.5, fontWeight: on ? 500 : 400,
                display: 'flex', justifyContent: 'space-between', alignItems: 'center',
              }}>
                <span>{t}</span>
                {on && <Sym name="check" size={14} stroke={2} color={C.paper} />}
              </div>
            ))}
          </div>
        </div>
        <Btn primary>Got it — try again</Btn>
      </div>
    </Screen>
  );
}

Object.assign(window, { S_WardrobeGrid, S_WardrobeItems, S_ItemDetail, S_InlineCorrect });
