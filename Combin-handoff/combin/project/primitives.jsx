// Combin primitives — shared design tokens, type, and components.

const C = {
  // Light "warm paper"
  paper: 'oklch(0.965 0.008 70)',         // base bg, off-white warm
  paperDeep: 'oklch(0.945 0.012 70)',     // sheet / card divider
  paperLine: 'oklch(0.88 0.012 70)',      // hairlines
  ink: 'oklch(0.18 0.012 60)',            // primary text — never #000
  inkSoft: 'oklch(0.40 0.010 60)',        // secondary text
  inkMute: 'oklch(0.58 0.008 60)',        // tertiary / chrome
  accent: 'oklch(0.55 0.12 40)',          // terracotta-ink — single accent
  accentSoft: 'oklch(0.55 0.12 40 / 0.10)',

  // Warm-dim (dark)
  dpaper: 'oklch(0.18 0.010 60)',
  dpaperDeep: 'oklch(0.22 0.010 60)',
  dpaperLine: 'oklch(0.32 0.010 60)',
  dink: 'oklch(0.94 0.008 70)',
  dinkSoft: 'oklch(0.74 0.010 60)',
  dinkMute: 'oklch(0.56 0.008 60)',
  daccent: 'oklch(0.68 0.11 40)',
};

const F = {
  serif: '"Newsreader", "Source Serif Pro", Georgia, serif',
  sans: '"Geist", "Söhne", -apple-system, BlinkMacSystemFont, sans-serif',
  mono: '"Geist Mono", "JetBrains Mono", ui-monospace, monospace',
};

// Striped placeholder — represents photography we don't fake.
function Photo({ w = '100%', h = 220, label = 'photo', radius = 4, dark = false, tone = 'neutral' }) {
  const bg = dark ? 'oklch(0.32 0.010 60)' : 'oklch(0.86 0.014 70)';
  const stripe = dark ? 'oklch(0.28 0.010 60)' : 'oklch(0.82 0.014 70)';
  const fg = dark ? 'oklch(0.62 0.010 60)' : 'oklch(0.50 0.010 60)';
  const tones = {
    neutral: [bg, stripe],
    warm: [dark ? 'oklch(0.34 0.020 50)' : 'oklch(0.84 0.022 50)',
           dark ? 'oklch(0.30 0.020 50)' : 'oklch(0.80 0.022 50)'],
    cool: [dark ? 'oklch(0.32 0.018 230)' : 'oklch(0.85 0.018 230)',
           dark ? 'oklch(0.28 0.018 230)' : 'oklch(0.81 0.018 230)'],
    olive: [dark ? 'oklch(0.32 0.030 120)' : 'oklch(0.83 0.026 120)',
            dark ? 'oklch(0.28 0.030 120)' : 'oklch(0.79 0.026 120)'],
    rust: [dark ? 'oklch(0.34 0.040 40)' : 'oklch(0.82 0.034 40)',
           dark ? 'oklch(0.30 0.040 40)' : 'oklch(0.78 0.034 40)'],
    char: [dark ? 'oklch(0.22 0.006 60)' : 'oklch(0.45 0.008 60)',
           dark ? 'oklch(0.20 0.006 60)' : 'oklch(0.42 0.008 60)'],
    ecru: [dark ? 'oklch(0.36 0.014 80)' : 'oklch(0.88 0.018 80)',
           dark ? 'oklch(0.32 0.014 80)' : 'oklch(0.84 0.018 80)'],
  };
  const [a, b] = tones[tone] || tones.neutral;
  return (
    <div style={{
      width: w, height: h, borderRadius: radius, position: 'relative', overflow: 'hidden',
      background: `repeating-linear-gradient(135deg, ${a} 0 8px, ${b} 8px 16px)`,
    }}>
      <div style={{
        position: 'absolute', inset: 0, display: 'flex',
        alignItems: 'center', justifyContent: 'center',
        fontFamily: F.mono, fontSize: 9, letterSpacing: 0.4,
        color: fg, textTransform: 'lowercase',
      }}>{label}</div>
    </div>
  );
}

// SF Symbol-like glyphs, drawn as simple line svgs at consistent weight.
function Sym({ name, size = 20, color = 'currentColor', stroke = 1.6 }) {
  const props = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none',
    stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'lock':
      return <svg {...props}><rect x="5" y="11" width="14" height="9" rx="1.5"/><path d="M8 11V7.5a4 4 0 0 1 8 0V11"/></svg>;
    case 'shield':
      return <svg {...props}><path d="M12 3l8 3v6c0 4.5-3.5 8-8 9-4.5-1-8-4.5-8-9V6l8-3z"/></svg>;
    case 'eye-slash':
      return <svg {...props}><path d="M3 12s3-6 9-6c2 0 3.6.7 5 1.7M21 12s-3 6-9 6c-2 0-3.6-.7-5-1.7"/><path d="M4 4l16 16"/><circle cx="12" cy="12" r="2.5"/></svg>;
    case 'trash':
      return <svg {...props}><path d="M5 7h14M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2M7 7l1 12a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1l1-12"/></svg>;
    case 'no-ad':
      return <svg {...props}><circle cx="12" cy="12" r="9"/><path d="M5.5 5.5l13 13"/></svg>;
    case 'camera':
      return <svg {...props}><path d="M4 8h3l2-2.5h6L17 8h3v11H4z"/><circle cx="12" cy="13" r="3.5"/></svg>;
    case 'photo':
      return <svg {...props}><rect x="3" y="5" width="18" height="14" rx="1"/><path d="M3 16l5-5 4 4 3-3 6 6"/><circle cx="9" cy="10" r="1.5"/></svg>;
    case 'hanger':
      return <svg {...props}><path d="M12 7a2 2 0 1 0-2-2"/><path d="M12 7v3"/><path d="M3 17l9-7 9 7v2H3z"/></svg>;
    case 'compass':
      return <svg {...props}><circle cx="12" cy="12" r="9"/><path d="M15.5 8.5l-2 5-5 2 2-5z"/></svg>;
    case 'book':
      return <svg {...props}><path d="M4 4.5A1.5 1.5 0 0 1 5.5 3H11v17H5.5A1.5 1.5 0 0 1 4 18.5z"/><path d="M20 4.5A1.5 1.5 0 0 0 18.5 3H13v17h5.5a1.5 1.5 0 0 0 1.5-1.5z"/></svg>;
    case 'arrow-up':
      return <svg {...props}><path d="M12 19V5M5 12l7-7 7 7"/></svg>;
    case 'chevron-r':
      return <svg {...props}><path d="M9 6l6 6-6 6"/></svg>;
    case 'chevron-l':
      return <svg {...props}><path d="M15 6l-6 6 6 6"/></svg>;
    case 'chevron-d':
      return <svg {...props}><path d="M6 9l6 6 6-6"/></svg>;
    case 'x':
      return <svg {...props}><path d="M6 6l12 12M18 6L6 18"/></svg>;
    case 'check':
      return <svg {...props}><path d="M5 13l4 4 10-10"/></svg>;
    case 'bookmark':
      return <svg {...props}><path d="M6 4h12v17l-6-4-6 4z"/></svg>;
    case 'share':
      return <svg {...props}><path d="M12 4v12M8 8l4-4 4 4"/><path d="M5 14v5a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-5"/></svg>;
    case 'sun-cloud':
      return <svg {...props}><circle cx="9" cy="9" r="3.5"/><path d="M9 3.5v1M3.5 9h1M14 9h.5M5.5 5.5l.7.7M12.5 5.5l-.7.7"/><path d="M14 18a3 3 0 1 0 0-6h-.6a4 4 0 0 0-7.4 1.5A3 3 0 0 0 7 18z"/></svg>;
    case 'bell':
      return <svg {...props}><path d="M6 16V11a6 6 0 0 1 12 0v5l1.5 2h-15z"/><path d="M10 20a2 2 0 0 0 4 0"/></svg>;
    case 'flip':
      return <svg {...props}><path d="M4 8a8 8 0 0 1 14-3M20 16a8 8 0 0 1-14 3"/><path d="M16 5h2V3M8 19H6v2"/></svg>;
    case 'gallery-sm':
      return <svg {...props}><rect x="4" y="6" width="14" height="12" rx="1.5"/><path d="M4 14l4-3 3 2 4-4 3 3"/></svg>;
    case 'plus':
      return <svg {...props}><path d="M12 5v14M5 12h14"/></svg>;
    case 'dots':
      return <svg {...props} fill={color} stroke="none"><circle cx="6" cy="12" r="1.4"/><circle cx="12" cy="12" r="1.4"/><circle cx="18" cy="12" r="1.4"/></svg>;
    case 'queue':
      return <svg {...props}><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>;
    // occasion icons — line-weight matched to the rest
    case 'briefcase':
      return <svg {...props}><rect x="3" y="7" width="18" height="13" rx="1.5"/><path d="M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/><path d="M3 13h18"/></svg>;
    case 'glass':
      return <svg {...props}><path d="M6 4h12l-1 6a5 5 0 0 1-10 0z"/><path d="M12 16v4M9 20h6"/></svg>;
    case 'sparkle':
      return <svg {...props}><path d="M12 4v6M12 14v6M4 12h6M14 12h6"/></svg>;
    case 'tree':
      return <svg {...props}><path d="M12 4l-5 7h3l-4 6h12l-4-6h3z"/><path d="M12 17v4"/></svg>;
    case 'plane':
      return <svg {...props}><path d="M3 13l8-2 4-7 2 1-2 7 7 3-1 2-7-1-3 5h-2l1-5-5-1z"/></svg>;
    case 'heart':
      return <svg {...props}><path d="M12 19s-7-4.5-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 9c0 5.5-7 10-7 10z"/></svg>;
    // weather icons
    case 'sun':
      return <svg {...props}><circle cx="12" cy="12" r="4"/><path d="M12 3v2M12 19v2M3 12h2M19 12h2M5.5 5.5l1.4 1.4M17.1 17.1l1.4 1.4M5.5 18.5l1.4-1.4M17.1 6.9l1.4-1.4"/></svg>;
    case 'cloud':
      return <svg {...props}><path d="M16 17a4 4 0 1 0 0-8h-.6a5 5 0 0 0-9.4 2A4 4 0 0 0 7 17z"/></svg>;
    case 'rain':
      return <svg {...props}><path d="M16 14a4 4 0 1 0 0-8h-.6a5 5 0 0 0-9.4 2A4 4 0 0 0 7 14z"/><path d="M9 17l-1 3M13 17l-1 3M17 17l-1 3"/></svg>;
    case 'snow':
      return <svg {...props}><path d="M16 13a4 4 0 1 0 0-8h-.6a5 5 0 0 0-9.4 2A4 4 0 0 0 7 13z"/><path d="M9 17v3M12 16v4M15 17v3M8 18.5h2M11 18.5h2M14 18.5h2"/></svg>;
    case 'wind':
      return <svg {...props}><path d="M4 9h11a3 3 0 1 0-3-3M4 15h14a3 3 0 1 1-3 3M4 12h9"/></svg>;
    case 'pin':
      return <svg {...props}><path d="M12 21s-6-5.5-6-11a6 6 0 0 1 12 0c0 5.5-6 11-6 11z"/><circle cx="12" cy="10" r="2.2"/></svg>;
    case 'pencil':
      return <svg {...props}><path d="M4 20l1-4L16 5l3 3L8 19z"/><path d="M14 7l3 3"/></svg>;
    default:
      return <svg {...props}><circle cx="12" cy="12" r="8"/></svg>;
  }
}

// Frame wrapper — gives every screen the warm paper canvas + status bar context.
function Screen({ children, dark = false, bg }) {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: bg || (dark ? C.dpaper : C.paper),
      color: dark ? C.dink : C.ink,
      fontFamily: F.sans,
      position: 'relative', overflow: 'hidden',
      display: 'flex', flexDirection: 'column',
    }}>{children}</div>
  );
}

// Bottom tab bar — five items: Discover · Education · + (raised) · Planner · Wardrobe.
// Tap 3 launches the camera capture flow as a full-screen modal — it is never a
// persistent active state.
function TabBar({ active = 'wardrobe', dark = false }) {
  const items = [
    { k: 'discover', label: 'Discover',  icon: 'compass' },
    { k: 'edu',      label: 'Education', icon: 'book' },
    { k: 'plus',     label: '',          icon: 'plus', plus: true },
    { k: 'planner',  label: 'Planner',   icon: 'hanger' },
    { k: 'wardrobe', label: 'Wardrobe',  icon: 'photo' },
  ];
  const ink = dark ? C.dink : C.ink;
  const mute = dark ? C.dinkMute : C.inkMute;
  const accent = dark ? C.daccent : C.accent;
  const paper = dark ? C.dpaper : C.paper;
  return (
    <div style={{
      borderTop: `0.5px solid ${dark ? C.dpaperLine : C.paperLine}`,
      background: paper,
      paddingTop: 8, paddingBottom: 6,
      display: 'flex', justifyContent: 'space-around', alignItems: 'flex-end',
      position: 'relative',
    }}>
      {items.map((it) => {
        if (it.plus) {
          return (
            <div key={it.k} style={{
              width: 46, height: 46, borderRadius: 23,
              background: accent, color: paper,
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              marginTop: -14, boxShadow: '0 1px 0 rgba(0,0,0,0.04)',
            }}>
              <Sym name="plus" size={22} stroke={2} color={paper} />
            </div>
          );
        }
        const on = it.k === active;
        return (
          <div key={it.k} style={{
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
            color: on ? ink : mute, padding: '4px 6px', minWidth: 52,
          }}>
            <Sym name={it.icon} size={20} stroke={on ? 1.9 : 1.4} />
            <div style={{ fontSize: 9.5, letterSpacing: 0.2, fontFamily: F.sans, fontWeight: on ? 500 : 400 }}>{it.label}</div>
          </div>
        );
      })}
    </div>
  );
}

// Considered button — flat rectangle, low radius. Not iOS-pill.
function Btn({ children, primary = false, ghost = false, dark = false, full = true, style = {} }) {
  const ink = dark ? C.dink : C.ink;
  const paper = dark ? C.dpaper : C.paper;
  const base = {
    display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
    fontFamily: F.sans, fontSize: 15, fontWeight: 500,
    letterSpacing: 0.1, padding: '14px 20px', borderRadius: 4,
    width: full ? '100%' : 'auto', boxSizing: 'border-box',
    transition: 'opacity .2s', cursor: 'pointer',
  };
  let look;
  if (primary) look = { background: ink, color: paper };
  else if (ghost) look = { background: 'transparent', color: ink };
  else look = { background: 'transparent', color: ink, boxShadow: `inset 0 0 0 0.5px ${dark ? C.dpaperLine : C.paperLine}` };
  return <div style={{ ...base, ...look, ...style }}>{children}</div>;
}

Object.assign(window, { C, F, Photo, Sym, Screen, TabBar, Btn });
