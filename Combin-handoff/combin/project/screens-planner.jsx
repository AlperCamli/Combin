// Journey 3 — Outfit planner.

function S_PlanEntry() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '12px 24px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ fontFamily: F.serif, fontSize: 22, fontWeight: 400, letterSpacing: -0.2 }}>Planner</div>
        <Sym name="dots" size={18} color={C.inkSoft} />
      </div>
      {/* first-visit framing */}
      <div style={{ padding: '14px 24px 0' }}>
        <div style={{
          fontFamily: F.sans, fontSize: 13, lineHeight: 1.55,
          color: C.inkSoft, textWrap: 'pretty',
          paddingLeft: 12, borderLeft: `1px solid ${C.paperLine}`,
        }}>
          Tell me where you're going and I'll put together two or three ideas, leaning on what's already in your closet.
        </div>
      </div>
      <div style={{ padding: '26px 28px 0' }}>
        <div style={{ fontFamily: F.serif, fontSize: 28, lineHeight: 1.15, letterSpacing: -0.25, fontWeight: 400 }}>
          What are you<br/>getting dressed for?
        </div>
        <div style={{ fontFamily: F.sans, fontSize: 13, color: C.inkSoft, marginTop: 8, lineHeight: 1.5 }}>
          Skip whatever you don't feel like answering. Defaults are sensible.
        </div>
      </div>
      <div style={{ padding: '24px 24px 0' }}>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 12 }}>quick start</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
          {[
            { tone: 'char',  label: 'work · Tue 9am' },
            { tone: 'rust',  label: 'dinner · 7pm' },
            { tone: 'olive', label: 'casual · this weekend' },
            { tone: 'ecru',  label: 'something else' },
          ].map((c, i) => (
            <div key={i} style={{ position: 'relative' }}>
              <Photo w="100%" h={92} tone={c.tone} radius={4} label={c.label} />
            </div>
          ))}
        </div>
      </div>
      <div style={{ flex: 1 }} />
      <div style={{ padding: '0 24px 16px' }}>
        <Btn>Build something from scratch</Btn>
      </div>
      <TabBar active="planner" />
    </Screen>
  );
}

function S_Context() {
  const Chip = ({ children, on }) => (
    <div style={{
      padding: '8px 13px', fontFamily: F.sans, fontSize: 13, fontWeight: on ? 500 : 400,
      borderRadius: 2, background: on ? C.ink : 'transparent',
      color: on ? C.paper : C.ink,
      boxShadow: on ? 'none' : `inset 0 0 0 0.5px ${C.paperLine}`,
      whiteSpace: 'nowrap',
    }}>{children}</div>
  );
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', color: C.inkSoft }}>
          <Sym name="chevron-l" size={18} stroke={1.6} />
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>context</div>
        <div style={{ fontFamily: F.sans, fontSize: 13, color: C.inkSoft }}>Skip</div>
      </div>
      <div style={{ padding: '20px 24px 0', overflowY: 'auto' }}>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 10 }}>occasion</div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
          {['Work', 'Date', 'Dinner', 'Casual', 'Formal', 'Travel', 'Gym', 'Event'].map((t, i) => <Chip key={t} on={i === 2}>{t}</Chip>)}
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginTop: 22, marginBottom: 10 }}>weather · auto</div>
        <div style={{
          display: 'flex', alignItems: 'center', gap: 12,
          padding: '14px 14px', borderRadius: 4,
          background: C.paperDeep,
        }}>
          <Sym name="sun-cloud" size={22} />
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: F.sans, fontSize: 14, color: C.ink }}>14° &middot; partly cloudy &middot; light wind</div>
            <div style={{ fontFamily: F.sans, fontSize: 12, color: C.inkMute, marginTop: 2 }}>Brooklyn, NY &middot; tonight</div>
          </div>
          <div style={{ fontFamily: F.sans, fontSize: 12, color: C.inkSoft }}>Edit</div>
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginTop: 22, marginBottom: 10 }}>vibe · optional</div>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
          {['Polished', 'Relaxed', 'Statement', 'Quiet', 'Romantic', 'Sharp'].map((t, i) => <Chip key={t} on={i === 3}>{t}</Chip>)}
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginTop: 22, marginBottom: 10 }}>dress code · optional</div>
        <div style={{
          padding: '12px 14px', borderRadius: 2,
          boxShadow: `inset 0 0 0 0.5px ${C.paperLine}`,
          fontFamily: F.sans, fontSize: 13, color: C.inkMute,
        }}>e.g. "smart casual, no jeans"</div>
      </div>
      <div style={{ flex: 1 }} />
      <div style={{ padding: '14px 24px 28px' }}>
        <Btn primary>Suggest 3 outfits</Btn>
      </div>
    </Screen>
  );
}

function S_Suggestions() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ width: 36, height: 36, color: C.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="chevron-l" size={18} stroke={1.6} />
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>dinner · 7pm · quiet</div>
        <div style={{ width: 36, height: 36, color: C.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="dots" size={18} />
        </div>
      </div>
      <div style={{ padding: '20px 24px 0' }}>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 6 }}>look 1 of 3</div>
        <div style={{ fontFamily: F.serif, fontSize: 22, lineHeight: 1.22, fontWeight: 400, letterSpacing: -0.1, textWrap: 'pretty' }}>
          The camel coat anchors a quiet palette, the boots add a third texture without disrupting the formality.
        </div>
      </div>
      <div style={{ padding: '18px 24px 0' }}>
        <Photo w="100%" h={224} tone="ecru" label="suggested look · 4 garments composed" radius={4} />
      </div>
      <div style={{ padding: '14px 24px 0', display: 'flex', gap: 8, overflowX: 'auto' }}>
        {[
          { tone: 'ecru',  l: 'cream wool · YOURS' },
          { tone: 'warm',  l: 'camel coat · YOURS' },
          { tone: 'char',  l: 'wool trouser' },
          { tone: 'rust',  l: 'leather boot' },
        ].map((g, i) => (
          <div key={i} style={{ flex: '0 0 auto', position: 'relative' }}>
            <Photo w={64} h={78} tone={g.tone} label={g.l} radius={2} />
            {g.l.includes('YOURS') && (
              <div style={{
                position: 'absolute', bottom: 4, left: 4, right: 4,
                fontFamily: F.mono, fontSize: 8, color: C.paper,
                background: 'rgba(20,16,12,0.7)', padding: '2px 4px', borderRadius: 1,
                letterSpacing: 0.5, textAlign: 'center', textTransform: 'uppercase',
              }}>yours</div>
            )}
          </div>
        ))}
      </div>
      <div style={{ flex: 1 }} />
      <div style={{ padding: '14px 24px 16px', display: 'flex', gap: 8 }}>
        <div style={{ flex: 1 }}><Btn>Make it warmer</Btn></div>
        <div style={{ flex: 1 }}><Btn primary>See full look</Btn></div>
      </div>
      {/* dot indicator */}
      <div style={{ padding: '0 0 22px', display: 'flex', gap: 6, justifyContent: 'center' }}>
        {[0,1,2].map(i => <div key={i} style={{ width: i === 0 ? 16 : 5, height: 5, borderRadius: 3, background: i === 0 ? C.ink : C.paperLine, transition: 'all .2s' }} />)}
      </div>
    </Screen>
  );
}

function S_SuggestionDetail() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ width: 36, height: 36, color: C.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="chevron-l" size={18} stroke={1.6} />
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>look 1 · detail</div>
        <div style={{ width: 36, height: 36, color: C.inkMute, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="bookmark" size={16} stroke={1.5} />
        </div>
      </div>
      <div style={{ overflowY: 'auto', padding: '12px 24px 0' }}>
        <Photo w="100%" h={196} tone="ecru" label="composed look" radius={4} />
        <div style={{ fontFamily: F.serif, fontSize: 19, lineHeight: 1.3, fontWeight: 400, marginTop: 18, textWrap: 'pretty' }}>
          The camel coat anchors a quiet palette, the boots add a third texture without disrupting the formality.
        </div>
        {/* Yours */}
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginTop: 22, marginBottom: 8 }}>from your closet</div>
        {[
          { tone: 'ecru', n: 'Cream wool turtleneck', s: 'Last seen Apr 22' },
          { tone: 'warm', n: 'Camel overcoat',        s: 'Last seen Mar 10' },
        ].map((it, i) => (
          <div key={i} style={{
            display: 'flex', gap: 12, alignItems: 'center',
            padding: '10px 0', borderTop: i === 0 ? `0.5px solid ${C.paperLine}` : 'none',
            borderBottom: `0.5px solid ${C.paperLine}`,
          }}>
            <Photo w={44} h={54} tone={it.tone} label="" radius={2} />
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.ink }}>{it.n}</div>
              <div style={{ fontFamily: F.sans, fontSize: 11, color: C.inkMute, marginTop: 2 }}>{it.s}</div>
            </div>
            <Sym name="chevron-r" size={14} color={C.inkSoft} stroke={1.6} />
          </div>
        ))}
        {/* Descriptive only */}
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginTop: 20, marginBottom: 8 }}>and a piece you don't have</div>
        <div style={{ padding: '12px 12px', background: C.paperDeep, borderRadius: 4 }}>
          <div style={{ fontFamily: F.serif, fontSize: 15, lineHeight: 1.4, color: C.ink, fontWeight: 400, textWrap: 'pretty' }}>
            A dark, leather-soled boot — anything with structure. Think clean toe, low shaft.
          </div>
          {/* opt-in shopping surface */}
          <div style={{
            marginTop: 12, paddingTop: 10, borderTop: `0.5px solid ${C.paperLine}`,
            display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          }}>
            <div style={{ fontFamily: F.sans, fontSize: 12, color: C.inkSoft }}>Shop suggestions</div>
            <Sym name="chevron-d" size={14} color={C.inkSoft} stroke={1.6} />
          </div>
        </div>
        <div style={{ height: 18 }} />
      </div>
      <div style={{ padding: '12px 24px 24px' }}>
        <Btn primary>Save as tonight's look</Btn>
      </div>
    </Screen>
  );
}

function S_ShopSurface() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ width: 36, height: 36, color: C.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="chevron-d" size={18} stroke={1.6} />
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>suggested items</div>
        <div style={{ width: 36, height: 36 }} />
      </div>
      <div style={{ padding: '20px 24px 0' }}>
        <div style={{ fontFamily: F.serif, fontSize: 22, lineHeight: 1.22, fontWeight: 400, letterSpacing: -0.1, textWrap: 'pretty' }}>
          Boots with structure.
        </div>
        <div style={{
          fontFamily: F.sans, fontSize: 11.5, color: C.inkSoft,
          lineHeight: 1.5, marginTop: 12, padding: '10px 12px',
          background: C.paperDeep, borderRadius: 2,
        }}>
          Combin earns a commission on purchases through these links. We pick what to show based on your style, not on commission.
        </div>
      </div>
      <div style={{ padding: '14px 24px 0', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {[
          { tone: 'char', brand: 'Margiela',     name: 'Tabi leather Chelsea',  price: '$890',  ret: 'SSENSE' },
          { tone: 'rust', brand: 'Grenson',      name: 'Fred II derby boot',    price: '$425',  ret: 'Mr Porter' },
          { tone: 'warm', brand: 'Common Projects', name: 'Achilles boot',      price: '$615',  ret: 'Brand direct' },
        ].map((p, i) => (
          <div key={i} style={{ display: 'flex', gap: 12 }}>
            <Photo w={88} h={104} tone={p.tone} label="" radius={4} />
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
              <div>
                <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.2, textTransform: 'uppercase' }}>{p.brand}</div>
                <div style={{ fontFamily: F.serif, fontSize: 16, lineHeight: 1.25, color: C.ink, marginTop: 2 }}>{p.name}</div>
                <div style={{ fontFamily: F.sans, fontSize: 13, color: C.ink, marginTop: 6 }}>{p.price}</div>
              </div>
              <div style={{
                display: 'inline-flex', alignSelf: 'flex-start', alignItems: 'center', gap: 6,
                fontFamily: F.sans, fontSize: 12, color: C.ink,
                padding: '6px 10px', borderRadius: 2,
                boxShadow: `inset 0 0 0 0.5px ${C.paperLine}`,
              }}>
                View on {p.ret} <Sym name="arrow-up" size={11} stroke={1.6} color={C.ink} />
              </div>
            </div>
          </div>
        ))}
      </div>
    </Screen>
  );
}

Object.assign(window, { S_PlanEntry, S_Context, S_Suggestions, S_SuggestionDetail, S_ShopSurface });
