// Daily Use screens — Camera default, Capture→Thinking→Result, Expanded read.

// 7) Camera default state — most-used screen.
function S7_Camera() {
  return (
    <Screen dark>
      <div style={{ position: 'absolute', inset: 0 }}>
        <Photo w="100%" h="100%" tone="char" radius={0} dark label="live viewport · front camera" />
        <FrameGuide />
      </div>
      <IOSStatusBar dark />
      {/* top row — back + context pill + wardrobe */}
      <div style={{ position: 'relative', padding: '8px 16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 10 }}>
        <div style={{
          width: 38, height: 38, borderRadius: 4,
          background: 'rgba(20,16,12,0.32)',
          backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: 'rgba(255,251,244,0.85)', flex: '0 0 auto',
        }}>
          <Sym name="chevron-l" size={20} stroke={1.6} color="rgba(255,251,244,0.92)" />
        </div>
        <div style={{
          fontFamily: F.sans, fontSize: 12.5, fontWeight: 400,
          color: 'rgba(255,251,244,0.78)',
          padding: '8px 14px', borderRadius: 4,
          background: 'rgba(20,16,12,0.32)',
          backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)',
          display: 'inline-flex', alignItems: 'center', gap: 8,
        }}>
          <span style={{ opacity: 0.65 }}>headed</span>
          <span>where?</span>
          <Sym name="chevron-d" size={11} stroke={1.6} color="rgba(255,251,244,0.78)" />
        </div>
        <div style={{
          width: 38, height: 38, borderRadius: 4,
          background: 'rgba(20,16,12,0.32)',
          backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: 'rgba(255,251,244,0.85)', flex: '0 0 auto',
        }}>
          <Sym name="hanger" size={20} stroke={1.5} />
        </div>
      </div>
      <div style={{ flex: 1 }} />
      {/* first-24h cue — sets the morning-mirror cadence without a notification ask */}
      <div style={{
        position: 'relative', padding: '0 28px 12px',
        fontFamily: F.serif, fontSize: 15, lineHeight: 1.35,
        color: 'rgba(255,251,244,0.78)', letterSpacing: -0.05,
        textAlign: 'center', textWrap: 'pretty',
      }}>
        Try it tomorrow morning, before you leave the house.
      </div>
      {/* bottom row — gallery + capture */}
      <div style={{ position: 'relative', padding: '0 28px 18px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{
          width: 44, height: 44, borderRadius: 4,
          background: 'rgba(20,16,12,0.32)',
          backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: 'rgba(255,251,244,0.85)',
        }}>
          <Sym name="gallery-sm" size={20} stroke={1.5} />
        </div>
        {/* capture — large, centered, terracotta core when armed */}
        <div style={{ position: 'relative', width: 78, height: 78 }}>
          <div style={{
            position: 'absolute', inset: 0, borderRadius: '50%',
            border: '2px solid rgba(255,251,244,0.92)',
          }} />
          <div style={{
            position: 'absolute', inset: 6, borderRadius: '50%',
            background: C.accent,
          }} />
        </div>
        {/* small lock — "your data" privacy affordance */}
        <div style={{
          width: 44, height: 44, borderRadius: 4,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: 'rgba(255,251,244,0.55)',
        }}>
          <Sym name="lock" size={16} stroke={1.5} />
        </div>
      </div>
    </Screen>
  );
}

// 7b) Context confirmation — after photo capture, before Looking…
// Two quick confirms: where you're headed (occasion) + the weather we auto-detected.
// Tap to change either. "Confirm" advances to Looking…
function S7b_Confirm() {
  const occasions = [
    { k: 'work',     icon: 'briefcase', label: 'Work' },
    { k: 'school',   icon: 'book',      label: 'School' },
    { k: 'dinner',   icon: 'glass',     label: 'Dinner' },
    { k: 'party',    icon: 'sparkle',   label: 'Party' },
    { k: 'casual',   icon: 'tree',      label: 'Casual' },
    { k: 'travel',   icon: 'plane',     label: 'Travel' },
    { k: 'date',     icon: 'heart',     label: 'Date' },
    { k: 'else',     icon: 'pencil',    label: 'Other' },
  ];
  const weather = [
    { k: 'sun',   icon: 'sun',   label: 'Clear' },
    { k: 'cloud', icon: 'cloud', label: 'Cloudy' },
    { k: 'rain',  icon: 'rain',  label: 'Rain' },
    { k: 'snow',  icon: 'snow',  label: 'Snow' },
    { k: 'wind',  icon: 'wind',  label: 'Windy' },
  ];
  return (
    <Screen>
      {/* dim, frozen capture sits behind the sheet — feels like a half-modal stage */}
      <div style={{ position: 'absolute', inset: 0 }}>
        <Photo w="100%" h="100%" tone="warm" radius={0} dark label="captured · frozen" />
        <div style={{ position: 'absolute', inset: 0, background: 'rgba(20,16,12,0.55)' }} />
      </div>
      <IOSStatusBar dark />
      {/* top — back + thumbnail of the just-captured photo */}
      <div style={{ position: 'relative', padding: '10px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{
          width: 38, height: 38, borderRadius: 4,
          background: 'rgba(20,16,12,0.45)',
          backdropFilter: 'blur(12px)', WebkitBackdropFilter: 'blur(12px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          color: 'rgba(255,251,244,0.92)',
        }}>
          <Sym name="chevron-l" size={20} stroke={1.6} color="rgba(255,251,244,0.92)" />
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: 'rgba(255,251,244,0.55)', letterSpacing: 1.3, textTransform: 'uppercase' }}>
          one quick thing
        </div>
        <div style={{ width: 38, height: 38 }} />
      </div>
      <div style={{ flex: 1 }} />
      {/* sheet */}
      <div style={{
        position: 'relative',
        background: C.paper, color: C.ink,
        borderTopLeftRadius: 14, borderTopRightRadius: 14,
        padding: '14px 0 24px',
      }}>
        <div style={{ width: 36, height: 4, borderRadius: 2, background: C.paperLine, margin: '0 auto 22px' }} />
        {/* heading */}
        <div style={{ padding: '0 28px 0' }}>
          <div style={{
            fontFamily: F.serif, fontSize: 26, lineHeight: 1.18,
            letterSpacing: -0.15, fontWeight: 400, textWrap: 'pretty',
          }}>
            Where are you headed?
          </div>
          <div style={{ fontFamily: F.sans, fontSize: 13, color: C.inkSoft, marginTop: 6 }}>
            Helps me read the room. Skip if you'd rather not say.
          </div>
        </div>
        {/* occasion grid — 4 cols, icon + label, no chrome until selected */}
        <div style={{
          padding: '20px 24px 0',
          display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8,
        }}>
          {occasions.map((o, i) => {
            const on = o.k === 'dinner';
            return (
              <div key={o.k} style={{
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
                padding: '14px 6px 12px',
                background: on ? C.ink : 'transparent',
                color: on ? C.paper : C.ink,
                borderRadius: 4,
                boxShadow: on ? 'none' : `inset 0 0 0 0.5px ${C.paperLine}`,
              }}>
                <Sym name={o.icon} size={20} stroke={on ? 1.7 : 1.4} color={on ? C.paper : C.ink} />
                <div style={{ fontFamily: F.sans, fontSize: 11, fontWeight: on ? 500 : 400, letterSpacing: 0.1 }}>
                  {o.label}
                </div>
              </div>
            );
          })}
        </div>
        {/* weather — pre-filled from location, tap any to override */}
        <div style={{ padding: '26px 28px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'baseline' }}>
          <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>
            weather · auto
          </div>
          <div style={{ fontFamily: F.sans, fontSize: 11.5, color: C.inkMute, display: 'inline-flex', alignItems: 'center', gap: 6 }}>
            <Sym name="pin" size={11} stroke={1.5} color={C.inkMute} />
            Brooklyn, NY
          </div>
        </div>
        <div style={{ padding: '12px 24px 0', display: 'flex', gap: 8 }}>
          {weather.map((w) => {
            const on = w.k === 'cloud';
            return (
              <div key={w.k} style={{
                flex: 1,
                display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
                padding: '12px 4px 10px',
                background: on ? C.ink : 'transparent',
                color: on ? C.paper : C.ink,
                borderRadius: 4,
                boxShadow: on ? 'none' : `inset 0 0 0 0.5px ${C.paperLine}`,
              }}>
                <Sym name={w.icon} size={20} stroke={on ? 1.7 : 1.4} color={on ? C.paper : C.ink} />
                <div style={{ fontFamily: F.sans, fontSize: 10.5, fontWeight: on ? 500 : 400 }}>
                  {w.label}
                </div>
              </div>
            );
          })}
        </div>
        {/* the auto-detected reading sits underneath as a quiet sentence,
            so tapping is presented as a correction, not a required choice */}
        <div style={{ padding: '12px 28px 0', fontFamily: F.sans, fontSize: 12, color: C.inkSoft, lineHeight: 1.5, textWrap: 'pretty' }}>
          Cloudy, 14° &middot; light wind from the east. Tap to change if that's not right.
        </div>
        {/* confirm */}
        <div style={{ padding: '22px 24px 0' }}>
          <Btn primary>Confirm &amp; read it</Btn>
        </div>
      </div>
    </Screen>
  );
}

// 8a) Thinking — bottom sheet with "Looking..." in serif.
function S8_Thinking() {
  return (
    <Screen dark>
      <div style={{ position: 'absolute', inset: 0 }}>
        {/* frozen photo with subtle scale-down hint */}
        <div style={{ position: 'absolute', inset: 0, transform: 'scale(0.98)' }}>
          <Photo w="100%" h="100%" tone="warm" radius={0} dark label="captured · frozen" />
        </div>
        <div style={{ position: 'absolute', inset: 0, background: 'rgba(20,16,12,0.35)' }} />
      </div>
      <IOSStatusBar dark />
      <div style={{ flex: 1 }} />
      {/* sheet */}
      <div style={{
        position: 'relative',
        background: C.paper, color: C.ink,
        borderTopLeftRadius: 14, borderTopRightRadius: 14,
        padding: '14px 28px 28px',
      }}>
        <div style={{
          width: 36, height: 4, borderRadius: 2,
          background: C.paperLine, margin: '0 auto 26px',
        }} />
        <div style={{
          fontFamily: F.serif, fontSize: 32, lineHeight: 1.1,
          letterSpacing: -0.3, fontWeight: 400,
          padding: '36px 0 36px',
          background: `linear-gradient(90deg, ${C.ink} 0%, ${C.ink} 40%, ${C.inkMute} 60%, ${C.ink} 80%)`,
          backgroundSize: '200% 100%',
          WebkitBackgroundClip: 'text', backgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
        }}>
          Looking…
        </div>
        <div style={{
          fontFamily: F.mono, fontSize: 9.5, letterSpacing: 1.4,
          textTransform: 'uppercase', color: C.inkMute,
        }}>
          a moment, not a spinner
        </div>
      </div>
    </Screen>
  );
}

// 9) Vibe-check result — photo + serif one-liner + tweak card + low-contrast actions.
function S9_Result() {
  return (
    <Screen>
      <IOSStatusBar />
      {/* top chrome — close + share. The result reached via the camera modal;
          share lives top-right; the privacy lock is implicit (no upload). */}
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', color: C.inkSoft }}>
          <Sym name="x" size={18} stroke={1.6} />
        </div>
        <div style={{ width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', color: C.inkSoft }}>
          <Sym name="share" size={18} stroke={1.5} />
        </div>
      </div>
      {/* contained photo */}
      <div style={{ padding: '8px 28px 0' }}>
        <Photo w="100%" h={228} tone="warm" label="user outfit · contained, editorial inset" radius={4} />
      </div>
      {/* the vibe-check one-liner — hero */}
      <div style={{ padding: '32px 28px 0' }}>
        <div style={{
          fontFamily: F.serif, fontSize: 26, lineHeight: 1.22,
          letterSpacing: -0.15, color: C.ink, fontWeight: 400,
          textWrap: 'pretty',
        }}>
          Three textures, one mood. That's the trick.
        </div>
      </div>
      {/* tweak card — quieter, smaller, sans, with thumbnail */}
      <div style={{ padding: '28px 28px 0' }}>
        <div style={{
          padding: '14px 14px 14px 12px',
          borderTop: `0.5px solid ${C.paperLine}`,
          borderBottom: `0.5px solid ${C.paperLine}`,
          display: 'flex', gap: 14, alignItems: 'center',
        }}>
          <div style={{ flex: '0 0 auto' }}>
            <Photo w={56} h={68} tone="olive" label="" radius={2} />
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 6 }}>
              one tweak
            </div>
            <div style={{ fontFamily: F.sans, fontSize: 13.5, color: C.ink, lineHeight: 1.45 }}>
              Swap the belt for the olive one — pulls the palette tighter without changing the silhouette.
            </div>
          </div>
        </div>
      </div>
      <div style={{ flex: 1 }} />
      {/* primary CTA — route back to the wardrobe to see the new look in context */}
      <div style={{ padding: '20px 24px 28px' }}>
        <Btn primary>Go to the wardrobe</Btn>
      </div>
    </Screen>
  );
}

// 6) First vibe-check result — same as standard, but with a tiny educational note.
function S6_FirstResult() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ width: 36, height: 36 }} />
        <div style={{ width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', color: C.inkMute }}>
          <Sym name="lock" size={14} stroke={1.5} />
        </div>
      </div>
      <div style={{ padding: '8px 28px 0' }}>
        <Photo w="100%" h={210} tone="ecru" label="first photo · editorial inset" radius={4} />
      </div>
      <div style={{ padding: '32px 28px 0' }}>
        <div style={{
          fontFamily: F.serif, fontSize: 26, lineHeight: 1.22,
          letterSpacing: -0.15, color: C.ink, fontWeight: 400,
          textWrap: 'pretty',
        }}>
          Quiet confidence — the kind people remember without knowing why.
        </div>
      </div>
      {/* tiny educational note — first-run only */}
      <div style={{ padding: '26px 28px 0' }}>
        <div style={{
          fontFamily: F.mono, fontSize: 9.5, color: C.accent,
          letterSpacing: 1.3, textTransform: 'uppercase', marginBottom: 8,
        }}>
          a small note
        </div>
        <div style={{
          fontFamily: F.sans, fontSize: 13.5, color: C.inkSoft,
          lineHeight: 1.55, paddingLeft: 12,
          borderLeft: `1px solid ${C.paperLine}`,
        }}>
          Linen reads softer than cotton in this light — the wrinkles you're worrying about are doing work for you.
        </div>
      </div>
      <div style={{ flex: 1 }} />
      {/* handoff line — routes to Wardrobe tab. The pivot moment of onboarding. */}
      <div style={{ padding: '20px 28px 0' }}>
        <div style={{
          fontFamily: F.serif, fontSize: 16, lineHeight: 1.35,
          color: C.ink, fontWeight: 400, letterSpacing: -0.05,
          textWrap: 'pretty',
        }}>
          I just learned a few pieces of your closet. <span style={{ color: C.accent }}>Want to see?</span>
        </div>
      </div>
      <div style={{ padding: '14px 24px 28px' }}>
        <Btn primary>Show me my closet</Btn>
      </div>
    </Screen>
  );
}

// 10) Expanded "tell me more" — scrollable editorial read.
function S10_Expanded() {
  return (
    <Screen>
      <IOSStatusBar />
      <div style={{ padding: '8px 20px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div style={{ width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', color: C.inkSoft }}>
          <Sym name="chevron-d" size={18} stroke={1.6} />
        </div>
        <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.3, textTransform: 'uppercase' }}>
          a longer read
        </div>
        <div style={{ width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', color: C.inkMute }}>
          <Sym name="dots" size={18} />
        </div>
      </div>
      <div style={{ padding: '24px 28px 0', overflowY: 'auto' }}>
        <div style={{
          fontFamily: F.serif, fontSize: 22, lineHeight: 1.25,
          letterSpacing: -0.1, fontWeight: 400, marginBottom: 18,
        }}>
          Three textures, one mood. That's the trick.
        </div>
        <p style={{ fontFamily: F.serif, fontSize: 16, lineHeight: 1.55, color: C.ink, margin: '0 0 14px', textWrap: 'pretty' }}>
          The wool of the trousers, the cotton of the shirt, the suede of the loafers — three surfaces that catch light differently, and the whole outfit reads richer because of it.
        </p>
        <p style={{ fontFamily: F.serif, fontSize: 16, lineHeight: 1.55, color: C.inkSoft, margin: '0 0 18px', textWrap: 'pretty' }}>
          You're working in a tight palette — sand, cream, brown — which is what makes the textures land. If everything were the same color in three identical fabrics, this would read flat. Instead it reads considered.
        </p>
        {/* inline wardrobe reference */}
        <div style={{
          display: 'flex', gap: 12, alignItems: 'center',
          padding: '12px 12px',
          background: C.paperDeep, borderRadius: 4, margin: '6px 0 18px',
        }}>
          <Photo w={48} h={58} tone="ecru" label="" radius={2} />
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: F.mono, fontSize: 9.5, color: C.inkMute, letterSpacing: 1.2, textTransform: 'uppercase' }}>from your wardrobe</div>
            <div style={{ fontFamily: F.sans, fontSize: 13, color: C.ink, marginTop: 3 }}>The cream camp-collar shirt — last seen Apr 22.</div>
          </div>
          <Sym name="chevron-r" size={16} color={C.inkSoft} stroke={1.6} />
        </div>
        <p style={{ fontFamily: F.serif, fontSize: 16, lineHeight: 1.55, color: C.ink, margin: '0 0 14px', textWrap: 'pretty' }}>
          For the weather you've got — 14°, light wind — this is well-judged. You could push it warmer with the olive jacket, but you'd lose the texture story you've built.
        </p>
        <div style={{
          fontFamily: F.mono, fontSize: 9.5, color: C.inkMute,
          letterSpacing: 1.3, textTransform: 'uppercase',
          padding: '14px 0 8px', borderTop: `0.5px solid ${C.paperLine}`,
          marginTop: 10,
        }}>
          one to try
        </div>
        <p style={{ fontFamily: F.serif, fontSize: 15.5, lineHeight: 1.55, color: C.inkSoft, margin: 0, textWrap: 'pretty' }}>
          Texture-mixing is one of the most reliable moves in menswear and one of the hardest to spot. Notice it in editorials and you'll start seeing it everywhere.
        </p>
        <div style={{ height: 40 }} />
      </div>
    </Screen>
  );
}

Object.assign(window, { S6_FirstResult, S7_Camera, S7b_Confirm, S8_Thinking, S9_Result, S10_Expanded });
