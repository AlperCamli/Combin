// Onboarding screens — Welcome, Trust, Taste calibration, Permissions, First capture.

// 1) Welcome — full-bleed image, single sentence, single CTA.
function S1_Welcome() {
  return (
    <Screen>
      {/* full-bleed photo */}
      <div style={{ position: 'absolute', inset: 0 }}>
        <Photo w="100%" h="100%" tone="rust" radius={0} label="art-directed editorial — real person, considered styling" />
        {/* gradient scrim, very subtle, only at bottom for legibility */}
        <div style={{
          position: 'absolute', inset: 0,
          background: 'linear-gradient(to bottom, transparent 50%, rgba(20,16,12,0.55) 100%)'
        }} />
      </div>
      <IOSStatusBar dark />
      <div style={{ flex: 1 }} />
      <div style={{ position: 'relative', padding: '0 28px 44px', color: C.paper }}>
        <div style={{
          fontFamily: F.serif, fontSize: 36, lineHeight: 1.08,
          letterSpacing: -0.3, fontWeight: 400, marginBottom: 12
        }}>
          Your stylist<br />in your pocket.
        </div>
        <div style={{ fontFamily: F.sans, fontSize: 14, color: 'rgba(255,251,244,0.78)', marginBottom: 32, fontWeight: 400 }}>
          Honest when you ask. Kind every time.
        </div>
        <div style={{
          display: 'inline-flex', alignItems: 'center', gap: 10,
          fontFamily: F.sans, fontSize: 15, fontWeight: 500,
          background: C.paper, color: C.ink,
          padding: '14px 22px', borderRadius: 4
        }}>
          Let's go
          <Sym name="arrow-up" size={14} stroke={1.8} color={C.ink} />
        </div>
      </div>
    </Screen>);

}

// 2) Trust & privacy — four plain-language statements.
function S2_Trust() {
  const items = [
  { icon: 'lock', t: 'Your photos stay on your device when possible.' },
  { icon: 'shield', t: 'What we send to the AI is encrypted.' },
  { icon: 'trash', t: 'Delete any photo, any time.' },
  { icon: 'no-ad', t: 'We never sell your data, and there are no ads.' }];

  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '32px 28px 0' }}>
        <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute, letterSpacing: 1.2, textTransform: 'uppercase', marginBottom: 14 }}>
          ⟶ One thing first
        </div>
        <div style={{ fontFamily: F.serif, fontSize: 28, lineHeight: 1.15, letterSpacing: -0.2 }}>
          A few words on<br />how this works.
        </div>
      </div>
      <div style={{ padding: '36px 28px 0', display: 'flex', flexDirection: 'column', gap: 22 }}>
        {items.map((it) =>
        <div key={it.t} style={{ display: 'flex', gap: 14, alignItems: 'flex-start' }}>
            <div style={{ marginTop: 2, color: C.ink }}>
              <Sym name={it.icon} size={20} stroke={1.5} />
            </div>
            <div style={{ flex: 1, fontFamily: F.sans, fontSize: 15.5, lineHeight: 1.45, color: C.ink, fontWeight: 400 }}>
              {it.t}
            </div>
          </div>
        )}
      </div>
      <div style={{ flex: 1 }} />
      <div style={{ padding: '0 28px 28px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        <Btn primary>Got it</Btn>
        <Btn ghost>Tell me more</Btn>
      </div>
    </Screen>);

}

// 3) Taste calibration grid — photographic outfit cards, multi-select.
function S3_Taste() {
  const cards = [
  { tone: 'warm', label: 'tailored · warm tones', selected: true },
  { tone: 'olive', label: 'workwear · olive · earthy', selected: false },
  { tone: 'char', label: 'monochrome · charcoal', selected: true },
  { tone: 'ecru', label: 'soft · linen · ecru', selected: false },
  { tone: 'cool', label: 'sport · technical · cool', selected: true },
  { tone: 'rust', label: 'evening · jewel · rust', selected: false }];

  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '24px 24px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute, letterSpacing: 1.2, textTransform: 'uppercase' }}>
          02 / 04
        </div>
        <div style={{ fontFamily: F.sans, fontSize: 13, color: C.inkSoft }}></div>
      </div>
      <div style={{ padding: '20px 24px 18px' }}>
        <div style={{ fontFamily: F.serif, fontSize: 26, lineHeight: 1.15, letterSpacing: -0.2 }}>
          Which feel like you?
        </div>
        <div style={{ fontFamily: F.sans, fontSize: 13, color: C.inkSoft, marginTop: 6 }}>
          Tap any that resonate. Pick none and we'll figure it out together.
        </div>
      </div>
      <div style={{ padding: '0 24px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        {cards.map((c, i) =>
        <div key={i} style={{ position: 'relative' }}>
            <Photo w="100%" h={170} tone={c.tone} label={c.label} radius={4} />
            {c.selected &&
          <>
                <div style={{
              position: 'absolute', inset: 0, borderRadius: 4,
              boxShadow: `inset 0 0 0 2px ${C.ink}`
            }} />
                <div style={{
              position: 'absolute', top: 8, right: 8,
              width: 22, height: 22, borderRadius: '50%',
              background: C.ink, color: C.paper,
              display: 'flex', alignItems: 'center', justifyContent: 'center'
            }}>
                  <Sym name="check" size={14} color={C.paper} stroke={2} />
                </div>
              </>
          }
          </div>
        )}
      </div>
      <div style={{ flex: 1 }} />
      <div style={{ padding: '20px 24px 28px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ fontFamily: F.mono, fontSize: 11, color: C.inkMute }}></div>
        <div style={{
          display: 'inline-flex', alignItems: 'center',
          fontFamily: F.sans, fontSize: 15, fontWeight: 500,
          background: C.ink, color: C.paper,
          padding: '12px 20px', borderRadius: 4, gap: "10px"
        }}>
          Continue <Sym name="chevron-r" size={14} color={C.paper} stroke={2} />
        </div>
      </div>
    </Screen>);

}

// 4) Permissions — two cards with plain-English reasons.
function S4_Permissions() {
  const cards = [
  { icon: 'sun-cloud', title: 'Location', reason: 'So we recommend based on the weather.' }];

  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '32px 28px 0' }}>
        <div style={{ fontFamily: F.mono, fontSize: 10, color: C.inkMute, letterSpacing: 1.2, textTransform: 'uppercase', marginBottom: 14 }}>
          03 / 04
        </div>
        <div style={{ fontFamily: F.serif, fontSize: 26, lineHeight: 1.15, letterSpacing: -0.2 }}>
          One small ask.
        </div>
        <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.inkSoft, marginTop: 8, lineHeight: 1.5 }}>
          Optional. The app works without it. We'll ask about notifications later, once you're in the habit.
        </div>
      </div>
      <div style={{ padding: '28px 24px 0', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {cards.map((c) =>
        <div key={c.title} style={{
          border: `0.5px solid ${C.paperLine}`, borderRadius: 4,
          padding: '18px 18px 16px',
          display: 'flex', flexDirection: 'column', gap: 12
        }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <Sym name={c.icon} size={18} />
                <div style={{ fontFamily: F.sans, fontSize: 15, fontWeight: 500 }}>{c.title}</div>
              </div>
              <div style={{
              fontFamily: F.sans, fontSize: 12, fontWeight: 500,
              color: C.ink,
              padding: '6px 12px', borderRadius: 4,
              boxShadow: `inset 0 0 0 0.5px ${C.paperLine}`
            }}>Allow</div>
            </div>
            <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.inkSoft, lineHeight: 1.45 }}>
              {c.reason}
            </div>
          </div>
        )}
      </div>
      <div style={{ flex: 1 }} />
      <div style={{ padding: '0 28px 28px' }}>
        <Btn ghost>Maybe later</Btn>
      </div>
    </Screen>);

}

// 5) First photo capture — two equal paths, viewport visible behind.
function S5_FirstCapture() {
  return (
    <Screen dark>
      {/* viewport */}
      <div style={{ position: 'absolute', inset: 0 }}>
        <Photo w="100%" h="100%" tone="char" radius={0} dark label="live camera viewport · front-facing" />
        <div style={{
          position: 'absolute', inset: 0,
          background: 'linear-gradient(to bottom, rgba(0,0,0,0.45) 0%, rgba(0,0,0,0.05) 30%, rgba(0,0,0,0.05) 60%, rgba(0,0,0,0.7) 100%)'
        }} />
        {/* outfit frame guide — soft brackets, not strict crop */}
        <FrameGuide />
      </div>
      <IOSStatusBar dark />
      <div style={{ position: 'relative', padding: '20px 28px 0', color: 'rgba(255,251,244,0.92)' }}>
        <div style={{ fontFamily: F.mono, fontSize: 10, letterSpacing: 1.2, textTransform: 'uppercase', color: 'rgba(255,251,244,0.55)', marginBottom: 10 }}>
          04 / 04 · First read
        </div>
        <div style={{ fontFamily: F.serif, fontSize: 24, lineHeight: 1.18, letterSpacing: -0.1, maxWidth: 280 }}>
          Check your fit
        </div>
        <div style={{ fontFamily: F.sans, fontSize: 13, color: 'rgba(255,251,244,0.65)', marginTop: 8 }}>
          The outfit just needs to be visible.
        </div>
      </div>
      <div style={{ flex: 1 }} />
      <div style={{ position: 'relative', padding: '0 24px 36px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        <div style={{
          background: C.paper, color: C.ink,
          fontFamily: F.sans, fontSize: 15, fontWeight: 500,
          padding: '14px 20px', borderRadius: 4, textAlign: 'center'
        }}>
          Take a photo
        </div>
        <div style={{
          background: 'transparent', color: C.paper,
          fontFamily: F.sans, fontSize: 15, fontWeight: 500,
          padding: '14px 20px', borderRadius: 4, textAlign: 'center',
          boxShadow: 'inset 0 0 0 0.5px rgba(255,251,244,0.45)'
        }}>
          Use a recent one
        </div>
      </div>
    </Screen>);

}

function FrameGuide() {
  const corner = (style) =>
  <div style={{
    position: 'absolute', width: 28, height: 28,
    ...style
  }} />;

  return (
    <div style={{ position: 'absolute', inset: '20% 12% 26% 12%', pointerEvents: 'none' }}>
      <div style={{ position: 'absolute', top: 0, left: 0, width: 22, height: 22,
        borderTop: '1px solid rgba(255,251,244,0.65)', borderLeft: '1px solid rgba(255,251,244,0.65)' }} />
      <div style={{ position: 'absolute', top: 0, right: 0, width: 22, height: 22,
        borderTop: '1px solid rgba(255,251,244,0.65)', borderRight: '1px solid rgba(255,251,244,0.65)' }} />
      <div style={{ position: 'absolute', bottom: 0, left: 0, width: 22, height: 22,
        borderBottom: '1px solid rgba(255,251,244,0.65)', borderLeft: '1px solid rgba(255,251,244,0.65)' }} />
      <div style={{ position: 'absolute', bottom: 0, right: 0, width: 22, height: 22,
        borderBottom: '1px solid rgba(255,251,244,0.65)', borderRight: '1px solid rgba(255,251,244,0.65)' }} />
    </div>);

}

Object.assign(window, { S1_Welcome, S2_Trust, S3_Taste, S4_Permissions, S5_FirstCapture, FrameGuide });