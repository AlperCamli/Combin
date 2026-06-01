// Journey 5 — Discover (no-prices catalog).

function S_DiscoverHome() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 24px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ fontFamily: F.serif, fontSize: 22, fontWeight: 400, letterSpacing: -0.2 }}>Discover</div>
        <Sym name="dots" size={18} color={C.inkSoft} />
      </div>
      <div style={{ overflowY: 'auto', flex: 1 }}>
        {/* first-visit framing — inline, no modal, no Got it button */}
        <div style={{ padding: '14px 24px 0' }}>
          <div style={{
            fontFamily: F.sans, fontSize: 13, lineHeight: 1.55,
            color: C.inkSoft, textWrap: 'pretty',
            paddingLeft: 12, borderLeft: `1px solid ${C.paperLine}`,
          }}>
            A catalogue of fashion we think is worth your attention. Tap <i>Where to find</i> on anything to leave the app and shop.
          </div>
        </div>
        {/* Hero */}
        <div style={{ padding: '14px 24px 0' }}>
          <div style={{ position: 'relative' }}>
            <Photo w="100%" h={260} tone="char" label="featured · this week" radius={4} />
            <div style={{
              position: 'absolute', bottom: 14, left: 14, right: 14,
              color: C.paper,
            }}>
              <div style={{ fontFamily: F.mono, fontSize: 9.5, letterSpacing: 1.3, textTransform: 'uppercase', opacity: 0.75 }}>
                this week
              </div>
              <div style={{ fontFamily: F.serif, fontSize: 22, lineHeight: 1.2, fontWeight: 400, marginTop: 4 }}>
                Marni · S/S 2026
              </div>
              <div style={{ fontFamily: F.sans, fontSize: 12, opacity: 0.85, marginTop: 4 }}>
                Risso's tightest collection in three years.
              </div>
            </div>
          </div>
        </div>
        {/* Rails */}
        <div style={{ padding: '32px 0 0' }}>
          <div style={{ padding: '0 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>brands in rotation</div>
            <div style={{ fontFamily: F.sans, fontSize: 11.5, color: C.inkSoft }}>See all</div>
          </div>
          <div style={{ padding: '12px 24px 0', display: 'flex', gap: 10, overflowX: 'auto' }}>
            {[
              { tone: 'ecru',  n: 'Lemaire',     loc: 'France' },
              { tone: 'olive', n: 'Engineered Garments', loc: 'NYC / Tokyo' },
              { tone: 'rust',  n: 'Bode',        loc: 'NYC' },
              { tone: 'char',  n: 'Margiela',    loc: 'Paris' },
            ].map((b, i) => (
              <div key={i} style={{ flex: '0 0 auto', width: 130 }}>
                <Photo w={130} h={160} tone={b.tone} label="" radius={4} />
                <div style={{ fontFamily: F.serif, fontSize: 14, marginTop: 8 }}>{b.n}</div>
                <div style={{ fontFamily: F.sans, fontSize: 11, color: C.inkMute, marginTop: 1 }}>{b.loc}</div>
              </div>
            ))}
          </div>
        </div>
        <div style={{ padding: '28px 0 0' }}>
          <div style={{ padding: '0 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
            <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>movements &amp; references</div>
            <div style={{ fontFamily: F.sans, fontSize: 11.5, color: C.inkSoft }}>See all</div>
          </div>
          <div style={{ padding: '12px 24px 0', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            {[
              { tone: 'cool',  l: 'Belgian avant-garde' },
              { tone: 'warm',  l: 'American sportswear lineage' },
              { tone: 'char',  l: '1990s minimalism' },
              { tone: 'olive', l: 'Lagos new-tailoring' },
            ].map((m, i) => (
              <div key={i}>
                <Photo w="100%" h={120} tone={m.tone} label="" radius={4} />
                <div style={{ fontFamily: F.serif, fontSize: 14, marginTop: 8, lineHeight: 1.2 }}>{m.l}</div>
              </div>
            ))}
          </div>
        </div>
        <div style={{ height: 24 }} />
      </div>
      <TabBar active="discover" />
    </Screen>
  );
}

function S_BrandPage() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ width: 36, height: 36, color: C.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="chevron-l" size={18} stroke={1.6} />
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>brand</div>
        <div style={{ width: 36, height: 36 }} />
      </div>
      <div style={{ overflowY: 'auto' }}>
        <div style={{ padding: '14px 24px 0' }}>
          <div style={{ fontFamily: F.serif, fontSize: 32, fontWeight: 400, letterSpacing: -0.4 }}>Marni</div>
          <div style={{ fontFamily: F.sans, fontSize: 12.5, color: C.inkSoft, marginTop: 4 }}>
            Founded 1994 · Italy · Print and craft.
          </div>
          <p style={{ fontFamily: F.serif, fontSize: 15.5, lineHeight: 1.55, color: C.ink, marginTop: 14, fontWeight: 400, textWrap: 'pretty' }}>
            Marni was founded by Consuelo Castiglioni in Milan and known for its prints, color, and surface texture. Since 2016, Francesco Risso has continued the house's relationship to craft while loosening its silhouette.
          </p>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            fontFamily: F.sans, fontSize: 12, color: C.accent,
            marginTop: 12,
          }}>
            Learn about Risso <Sym name="chevron-r" size={12} stroke={1.6} color={C.accent} />
          </div>
        </div>
        <div style={{ padding: '24px 0 0' }}>
          <div style={{ padding: '0 24px', fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 10 }}>S/S 2026 — items</div>
          <div style={{ padding: '0 24px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
            {[
              ['rust',  'Striped knit'],
              ['ecru',  'Camp-collar shirt'],
              ['cool',  'Floor-length skirt'],
              ['olive', 'Suede mule'],
              ['warm',  'Bouclé jacket'],
              ['char',  'Wool trouser'],
            ].map(([t, n], i) => (
              <div key={i}>
                <Photo w="100%" h={170} tone={t} label="" radius={4} />
                <div style={{ fontFamily: F.serif, fontSize: 13, marginTop: 6 }}>{n}</div>
              </div>
            ))}
          </div>
        </div>
        <div style={{ height: 24 }} />
      </div>
    </Screen>
  );
}

function S_ItemDetailDisco() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ width: 36, height: 36, color: C.inkSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Sym name="chevron-l" size={18} stroke={1.6} />
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>item</div>
        <Sym name="bookmark" size={16} stroke={1.5} color={C.inkSoft} />
      </div>
      <div style={{ overflowY: 'auto' }}>
        <div style={{ padding: '12px 24px 0' }}>
          <Photo w="100%" h={360} tone="rust" label="striped knit · marni" radius={4} />
        </div>
        <div style={{ padding: '20px 28px 0' }}>
          <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>Marni · S/S 2026</div>
          <div style={{ fontFamily: F.serif, fontSize: 22, fontWeight: 400, letterSpacing: -0.15, marginTop: 4 }}>Striped wool knit</div>
          <div style={{ fontFamily: F.sans, fontSize: 13, color: C.inkSoft, marginTop: 12, lineHeight: 1.6 }}>
            Hand-loomed in Italy. 100% merino. Boatneck, dropped shoulder. Designed by Francesco Risso.
          </div>
          {/* No price. Where to find. */}
          <div style={{
            marginTop: 22, padding: '14px 14px 14px 16px',
            background: C.paperDeep, borderRadius: 4,
            display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          }}>
            <div>
              <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.ink }}>Where to find</div>
              <div style={{ fontFamily: F.sans, fontSize: 11, color: C.inkMute, marginTop: 2 }}>
                Prices live on the retailer's site, not here.
              </div>
            </div>
            <Sym name="chevron-r" size={16} stroke={1.6} color={C.inkSoft} />
          </div>
          <div style={{
            marginTop: 18, paddingTop: 16, borderTop: `0.5px solid ${C.paperLine}`,
          }}>
            <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.accent, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 6 }}>read more</div>
            <div style={{ fontFamily: F.serif, fontSize: 15, color: C.ink, fontWeight: 400, lineHeight: 1.4 }}>The references in Risso's S/S 2026 collection.</div>
          </div>
        </div>
        <div style={{ height: 30 }} />
      </div>
    </Screen>
  );
}

function S_WhereToFind() {
  return (
    <Screen>
      <IOSStatusBar />
      {/* dimmed item behind */}
      <div style={{ position: 'absolute', inset: 0, opacity: 0.3 }}>
        <div style={{ padding: '40px 24px 0' }}>
          <Photo w="100%" h={300} tone="rust" label="" radius={4} />
        </div>
      </div>
      <div style={{ flex: 1 }} />
      <div style={{
        position: 'relative', background: C.paper,
        borderTopLeftRadius: 14, borderTopRightRadius: 14,
        padding: '14px 24px 30px',
      }}>
        <div style={{ width: 36, height: 4, borderRadius: 2, background: C.paperLine, margin: '0 auto 16px' }} />
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 6 }}>where to find</div>
        <div style={{ fontFamily: F.serif, fontSize: 19, lineHeight: 1.25, fontWeight: 400, textWrap: 'pretty' }}>
          Striped wool knit — Marni S/S 2026.
        </div>
        <div style={{ marginTop: 18, display: 'flex', flexDirection: 'column', gap: 0 }}>
          {[
            { t: 'Marni — brand direct', s: 'marni.com' },
            { t: 'Mr Porter',            s: 'mrporter.com' },
            { t: 'SSENSE',               s: 'ssense.com' },
            { t: 'Net-a-Porter',         s: 'net-a-porter.com' },
          ].map((d, i) => (
            <div key={i} style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              padding: '14px 4px', borderTop: `0.5px solid ${C.paperLine}`,
              borderBottom: i === 3 ? `0.5px solid ${C.paperLine}` : 'none',
            }}>
              <div>
                <div style={{ fontFamily: F.sans, fontSize: 14, color: C.ink }}>{d.t}</div>
                <div style={{ fontFamily: F.mono, fontSize: 11, color: C.inkMute, marginTop: 2 }}>{d.s}</div>
              </div>
              <Sym name="arrow-up" size={14} stroke={1.6} color={C.inkSoft} />
            </div>
          ))}
        </div>
        <div style={{ fontFamily: F.sans, fontSize: 11, color: C.inkMute, marginTop: 14, lineHeight: 1.5 }}>
          You'll leave Combin. Prices appear on the retailer's site. We don't follow you back.
        </div>
      </div>
    </Screen>
  );
}

Object.assign(window, { S_DiscoverHome, S_BrandPage, S_ItemDetailDisco, S_WhereToFind });
