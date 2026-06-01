---
agent: ux-designer
date: 2026-05-08
topic: onboarding-handoff-and-tab-navigation
type: decision
status: proposed
references:
  - agent: product-strategist
    topic: tab-structure
  - agent: wellbeing-tone-steward
    topic: handoff-copy
  - agent: fashion-intelligence
    topic: first-extraction-confidence
  - agent: software-architect
    topic: tab-state-and-extraction-pipeline
tags: [onboarding, navigation, wardrobe, handoff, tab-bar]
---

# Onboarding handoff to main app, plus the five-tab navigation system

## User context

Two distinct moments are addressed in this note.

**The handoff moment**: the user has just finished onboarding. Their first vibe-check has been delivered (slightly extra-warm, plus one tiny educational note). They are emotionally engaged — the AI just read their outfit out loud in a way that felt specific and warm. The risk is that the next moment is *"now what?"* — a cognitive cliff that undoes the engagement.

**The steady-state navigation**: the user is moving through the app on day three, day thirty. They need to get to the right surface fast, without thinking about navigation.

Both moments need to be designed together because the handoff's job is to introduce the navigation in a way that doesn't feel like a tour.

---

## The design

### Part 1 — Handoff from onboarding to the main app

After the first vibe-check appears and settles (one-liner enters, tiny educational note plays below), one quiet line appears at the bottom of the result screen:

> *"I just learned a few pieces of your closet. Want to see?"*

Tap → routes to the **Wardrobe tab**. Dismiss (swipe down, or tap the result chrome to collapse) → camera default state on the home tab, no penalty.

This line is the bridge. It works because:
- It frames the AI as *actively building memory*, not analyzing in a one-shot way.
- "A few pieces of your closet" is concrete — not "I analyzed your outfit."
- "Want to see?" is permission-seeking. Friend voice, not product voice.
- It rewards curiosity, not compliance. The user opts in.

### Part 2 — First-visit wardrobe (the proof-of-mechanism moment)

The user lands on the **standard Wardrobe tab**. This is critical: not a special onboarding wardrobe screen, but the real screen with first-visit framing layered on top.

**Layout on first visit:**

```
┌─────────────────────────────────────┐
│  Wardrobe                            │  ← tab title, low contrast
│                                      │
│  ───── First-visit only ─────        │
│                                      │
│  "This is what I caught              │  ← serif, generous space
│   from your photo. Every             │
│   vibe-check adds to it."            │
│                                      │
│  ───── Standard from here ─────      │
│                                      │
│  ┌──────┐  ┌──────┐                 │
│  │photo │  │ jacket│                 │  ← The first vibe-check photo
│  │ from │  │ crop  │                 │     as the "feed entry," plus
│  │vibe-1│  │       │                 │     extracted garments below
│  └──────┘  └──────┘                 │
│            ┌──────┐  ┌──────┐       │
│            │ pant │  │ shoe │       │
│            │ crop │  │ crop │       │
│            └──────┘  └──────┘       │
│                                      │
│  "Keep taking vibe-checks and this  │  ← low-contrast bottom line
│   fills in. After a couple of       │     first-visit only
│   weeks, I'll start spotting things │
│   you already own."                  │
│                                      │
│  [Tab bar: Discover · Education ·   │
│   + · Outfit Planner · Wardrobe(●)] │
└─────────────────────────────────────┘
```

No "Got it" button. No coachmarks. The framing is part of the page on first visit; on subsequent visits it disappears or collapses to a compact "X looks · Y items" header.

The user can either:
- Tap an item to see detail (existing Journey 4 behavior).
- Tap the camera + tab to take another vibe-check.
- Tap another tab — and trigger that tab's first-visit explanation (see Part 4).
- Close the app. They will have understood the loop.

### Part 3 — When the user does land on the home / camera screen

If the user dismisses the handoff line, or after they've exited the Wardrobe and tapped the + tab, they reach the camera-capture screen. For the first 24 hours only, a single low-contrast line sits above the capture button:

> *"Try it tomorrow morning, before you leave the house."*

Same serif. Disappears after the user's second capture, or after 24 hours, whichever comes first. This sets the *cadence* expectation — the daily use case is the morning mirror — without a notification ask.

### Part 4 — First-visit explanations on every tab

Whenever the user enters a tab for the first time, a short explanation appears at the top of the tab. Two characteristics, non-negotiable:

- **Two sentences maximum.** Friend voice. Not a paragraph.
- **Lives as part of the page on first visit.** No modal overlay. No "Got it" button. On second visit, it's gone, or collapsed into a small `(i)` icon at the top edge that re-expands the text on tap.

**Drafts:**

**Discover (Catalogue) — first visit:**
> *"A catalogue of fashion we think is worth your attention. Brands, designers, references — no prices. Tap 'Where to find' on anything to leave the app and shop."*

**Education — first visit:**
> *"Things to read about fashion, plus a daily puzzle. Built to teach, not to sell. New piece every morning."*

**Outfit Planner — first visit:**
> *"Tell me where you're going and I'll put together two or three ideas, leaning on what's already in your closet."*

**Wardrobe — first visit (if reached via tab tap, not via the onboarding handoff):**
> *"Everything I've seen you wear lives here. Each photo is a vibe-check; tap one to see what I noticed."*

Same restraint everywhere. No celebratory animations, no SF Symbol decorations, no "✨ AI ✨" disclosures, no "Welcome to [tab name]!" greeting.

### Part 5 — The notification permission ask (deferred)

Don't ask for notifications anywhere in the onboarding-to-main flow.

Ask after the **third successful vibe-check**. The moment: the user has just received their third result. As the result screen settles, a small inline prompt appears below the action row:

> *"Want a small nudge tomorrow morning, before you leave?"*
> [Yes, just one] [Not now]

If "Yes, just one" — the OS system prompt fires. If "Not now" — gone for 7 days, then asks again. After two declines, never asked through this surface again (settings still allows it).

This is a deliberate departure from the "ask for everything early" pattern. The cost: some users would have said yes earlier. The benefit: users who say yes after three sessions are actually in the habit loop, and the notification supports an existing behavior instead of trying to manufacture one.

---

## The five-tab navigation system

### Tab structure (locked)

Bottom tab bar, five items, left to right:

1. **Discover** — the no-prices fashion catalogue (Journey 5).
2. **Education** — Daily Insight, Daily Puzzle, deep-dives, recommendations (Journey 6).
3. **+ (New Vibe Check)** — visually distinct center action button. Bigger, accent-colored, slightly raised. Tapping it launches the camera capture flow as a full-screen modal (Journey 2). Long-press optionally opens to gallery picker.
4. **Outfit Planner** — context-driven outfit suggestions (Journey 3).
5. **Wardrobe** — Instagram-style profile grid of vibe-check photos, with a secondary "items" view (Journey 4).

### Visual treatment of the tab bar

- **Tabs 1, 2, 4, 5**: SF Symbol icon (line weight aligned), short label below in the sans, low-contrast when inactive, full-contrast + filled icon when active.
- **Tab 3 (the +)**: visually distinct — circular or rounded-square shape, slightly larger, the one accent color from the palette as its background, white or paper-toned plus glyph. It is not labeled (it doesn't need a label — the shape is the signal). It sits on the tab bar's center but is *raised* a few points above the other tabs, the way Instagram's create button does. This signals "primary action," not "fifth tab."
- **Tab bar background**: the same off-white / warm paper background as the app's base, with a near-invisible top border (1px hairline at low alpha) separating it from content above. No drop shadow. No blur effect (no `UIBlurEffect` chrome — too iOS-default, too productivity-app).
- **Active tab indicator**: the icon switches from outline to filled, and the label gains weight. No underline bar, no animated pill behind the active tab. Restraint.

### Tab transition behavior

Tapping a tab is instant — no animation between tabs. Each tab preserves its own scroll position and navigation stack. Coming back to the Wardrobe tab returns the user to where they were, not the top.

The center + button is different: tapping it pushes a full-screen modal (the camera capture flow). The tab bar slides down off-screen during the modal. Dismissing the modal (either by capturing and finishing, or by swiping down) returns the user to whichever tab they were on. The camera is *invoked from* the user's current location; it doesn't replace their location.

### Wardrobe-as-profile: the structure within the tab

The Wardrobe tab opens to a **photo grid** (the Instagram-like view), not the garments grid Journey 4 originally described.

**Default mode — "Looks":**
- A grid of vibe-check photos, most recent first.
- 3-column on iPhone, denser than Instagram's 3-column because the photos are full-body outfit photos with less detail loss at smaller sizes.
- No likes, no comments, no follower count. This is *the user's* page; nobody else sees it.
- Tap any photo → outfit detail: the original photo full-screen, the vibe-check one-liner the user got that day, the extracted items shown as a small row below, weather/occasion metadata if captured.

**Secondary mode — "Items":**
- A toggle at the top of the Wardrobe tab switches between Looks and Items.
- Items view is the garments-by-category grid Journey 4 originally described — tops, bottoms, outerwear, etc. — useful for power users and for the wardrobe-correction flow.

**Default landing on the Wardrobe tab is "Looks."** That's the emotional view. Items mode is functional and lives behind a toggle.

A small profile-like header sits above the grid (low-key, not a giant avatar/cover-photo banner):
- A small line: *"Your fashion history"* or similar.
- A count: *"12 looks · 47 items"* once enough exists. (Pre-populated counts respect the "no gamification" rule by being descriptive, not motivating — "12 looks" not "Look 12 of 50!")

No bio. No following/followers. No share-profile-publicly affordance — this is a private space.

---

## Tab bar visibility rules (where the navigator shows and hides)

The tab bar is visible by default on every top-level tab screen, with the following exceptions:

### Hidden — full-screen immersive moments
- **Camera capture flow** (after tapping +). The tab bar slides down off-screen the moment the capture modal opens, and stays hidden through capture, thinking state, and the vibe-check result screen. The result screen has its own bottom action row; we don't want competing chrome.
- **Expanded "tell me more" read** from a vibe-check result. Same logic — the user is reading, not navigating.
- **Daily Insight reader** (full article view, opened from Education tab). Tab bar hides on scroll-down past the first viewport, reappears on scroll-up. Same pattern Safari and many news apps use.
- **Daily Puzzle full flow**. The puzzle is contemplative — the tab bar would break the spell. Tab bar hides when the puzzle opens, reappears after the user dismisses the unlock screen.
- **Onboarding flow** (welcome through first vibe-check, including the wardrobe handoff first-visit). No tab bar visible until the user explicitly lands on a tab post-onboarding. Onboarding is its own surface; mixing it with steady-state chrome muddies the experience.

### Hidden — sheet-based modals
- **Camera capture modal** (as above).
- **Item detail sheets in Wardrobe and Discover**. When a detail sheet is presented (either as a half-sheet bottom-up or a full-screen push), the tab bar hides behind it. Dismissing the sheet returns the tab bar.

### Visible — but with scroll-aware behavior
- **Discover home, Education home, Wardrobe home, Outfit Planner home**: tab bar visible on first viewport. On scroll-down (user is reading content), tab bar fades out after ~300ms of continuous downward scroll. On scroll-up of any amount, tab bar fades in immediately. This is the Safari-style behavior — content gets more screen when the user is reading; nav returns the moment they signal they're done.
- **Tab bar always visible at the top of any scroll** (i.e., when the user is at the top of any tab's content, no scroll has happened yet).

### Always visible — never hidden
- **The result screen of a vibe-check, when shown in non-modal context** — actually, this case doesn't exist in the current journeys. The vibe-check result is always reached via the camera modal, so the tab bar is hidden during it. Noting this so it's not a question later.

### Special case — the + tab
The + tab is *always visible alongside the other tabs* on every screen where the tab bar shows. It is never the "active" tab in the navigation sense — tapping it doesn't *navigate to a tab*, it *launches a modal*. So no visual active-state ever applies to it. It's always the same accent-filled circular shape.

---

## Reasoning

**Why the wardrobe (not Education) as the onboarding handoff destination.**
The wardrobe is the proof-of-mechanism for what the user just did. The first vibe-check is a deposit; the wardrobe is the account growing. Routing them there says *"the thing you just did is already paying off."* Education is a separate value proposition that runs in parallel and is better discovered later, on its own terms. (Earlier draft had Education as the handoff; this is a deliberate revision.)

**Why the wardrobe-as-profile, not wardrobe-as-database.**
Journey 4 worried that the wardrobe felt like data-entry homework — that's true if the default view is garments-by-category. Reframing the default as a photo grid (the user's fashion history) makes the wardrobe a *place users want to visit*, not a maintenance screen. The garments view doesn't go away; it lives behind a toggle for users who need it (and for the wardrobe-correction flow).

**Why the five-tab structure with center + button.**
This is a real tradeoff. A camera-default app (Snapchat-style) optimizes the morning mirror flow at the cost of treating the rest of the app as secondary. A five-tab structure treats the app as a *place to spend time* and the mirror moment as one (very important) flow within it. Given that Discover, Education, Outfit Planner, and the Wardrobe-as-profile are all substantive destinations, five-tab is right. The cost is one extra tap to reach the camera, which is acceptable because the + button is large, distinct, and always visible.

**Why deferred notification permission.**
Asking for notifications during onboarding is the industry default and the wrong call for this app. The brand voice is *"I'll be here when you want me,"* and a push permission prompt on day one says the opposite. Asking after three vibe-checks means asking the users who've already proven the habit — much higher say-yes rate, and much more honest framing ("a nudge for the thing you're already doing").

**Why first-visit explanations live on the page, not as overlays.**
Coachmark tours violate the brand voice — they treat the user as a student who needs the interface explained. Inline explanations sit in the same typographic system as the rest of the app and disappear on second visit; the interface trusts the user to read once and remember. Two sentences max, written in the same voice as the vibe-checks.

**Why scroll-aware tab bar hiding for Discover, Education, Wardrobe.**
These are content-consumption surfaces. When the user is reading or scrolling through content, the tab bar takes ~6% of vertical space for nothing. Hiding it on scroll-down (and restoring on scroll-up) is a well-established pattern that gives content more room without losing navigation access.

**Why the tab bar hides entirely on the camera flow and reader views.**
Those are intentional, immersive moments. The vibe-check result, the Daily Insight, the Daily Puzzle — each is a *moment of focus*. Tab bar visible during these would invite users to bounce out instead of finishing the read. Hide it; let the moment be the moment.

---

## Edge cases

- **The AI extracts zero items from the first photo.** Bad photo, weird crop, low confidence. The wardrobe handoff is meaningless because there's nothing to show. Fallback: skip the wardrobe handoff line. Replace with: *"This one was a little tricky to read — your closet starts filling out as you take more vibe-checks. Try one tomorrow morning."* Then route to the camera tab default. The user has gracefully understood that the wardrobe builds *over time* without seeing an empty wardrobe screen on day one.

- **The AI extracts items but most are visibly wrong.** More dangerous than zero items — undermines trust at the proof-of-mechanism moment. Mitigation lives upstream: [[fashion-intelligence]] should be conservative on first-extraction confidence (better to extract 2 confident items than 5 wobbly ones). If wrong items do surface, the standard wardrobe inline-correction is the user's path; the first-visit framing copy already says *"this is what I caught"* — humble enough to absorb the error.

- **User taps the Wardrobe tab before the onboarding handoff line fires** (e.g., they swipe the result chrome away and immediately tap Wardrobe in the tab bar). They land on the wardrobe with the first-visit framing intact. No double-explanation, no confused state. The path was just shorter.

- **User taps + (New Vibe Check) immediately after onboarding, before ever visiting a non-camera tab.** Their second capture happens before any other tab is opened. That's fine — the first-visit explanations sit dormant on each tab and trigger when (if ever) the user enters them.

- **User completes onboarding and immediately backgrounds the app.** When they reopen, where do they land? Behavior: app reopens to the last tab the user was on, but if the last "tab" was the post-onboarding handoff line (which isn't technically a tab state), the app opens to the Wardrobe tab with the first-visit framing intact. The handoff is not skippable by backgrounding; it lives in app state until consumed.

- **Tab bar in landscape orientation on larger iPhones.** Combin is portrait-locked for MVP per [[software-architect]]. Note for future: if landscape is ever supported, the tab bar logic translates cleanly to a side rail.

---

## Microcopy summary (every line of copy in this flow, for reference)

| Surface | Copy |
|---|---|
| First vibe-check handoff line | *"I just learned a few pieces of your closet. Want to see?"* |
| Wardrobe first-visit top framing | *"This is what I caught from your photo. Every vibe-check adds to it."* |
| Wardrobe first-visit bottom framing | *"Keep taking vibe-checks and this fills in. After a couple of weeks, I'll start spotting things you already own."* |
| Camera default, first 24h | *"Try it tomorrow morning, before you leave the house."* |
| Discover first-visit | *"A catalogue of fashion we think is worth your attention. Brands, designers, references — no prices. Tap 'Where to find' on anything to leave the app and shop."* |
| Education first-visit | *"Things to read about fashion, plus a daily puzzle. Built to teach, not to sell. New piece every morning."* |
| Outfit Planner first-visit | *"Tell me where you're going and I'll put together two or three ideas, leaning on what's already in your closet."* |
| Wardrobe first-visit (if via tab, not onboarding) | *"Everything I've seen you wear lives here. Each photo is a vibe-check; tap one to see what I noticed."* |
| Wardrobe header line (always) | *"Your fashion history"* |
| Wardrobe header counts (after enough exists) | *"12 looks · 47 items"* |
| Notification ask, after 3rd vibe-check | *"Want a small nudge tomorrow morning, before you leave?"* [Yes, just one] [Not now] |
| Zero-extraction fallback | *"This one was a little tricky to read — your closet starts filling out as you take more vibe-checks. Try one tomorrow morning."* |

---

## Dependencies

- [[wellbeing-tone-steward/handoff-copy]]: review of every line above, especially the handoff line and the zero-extraction fallback. The handoff is *the* pivot moment of onboarding; the copy needs explicit sign-off.
- [[fashion-intelligence/first-extraction-confidence]]: conservative confidence threshold for the very first vibe-check's garment extraction. Better 2 confident items than 5 uncertain. Wrong items on day one is more damaging than no items on day one.
- [[software-architect/tab-state-and-extraction-pipeline]]: the first-visit flag per tab, the 24-hour camera-line state, the deferred-until-3rd-capture notification logic, and the wardrobe extraction pipeline running synchronously enough that the wardrobe has items in it by the time the handoff line fires.
- [[product-strategist/tab-structure]]: ratification that the five-tab structure (Discover · Education · + · Planner · Wardrobe) is locked. This note assumes it. If product-strategist wants four tabs or a different layout, redesign.
- [[fashion-editorial/first-visit-copy-voice]]: editorial review of the four first-visit tab explanations. They are the user's first taste of each surface's voice; they need to be on-brand.
- [[privacy-legal/deferred-notification-ask]]: confirm there's no regulatory reason notifications must be asked-for earlier (App Store rules, regional law). My read is no, but flagging.

## Open questions

- **The handoff line specifically.** *"I just learned a few pieces of your closet. Want to see?"* is one draft. Worth testing against: *"Started your closet. Want a look?"* / *"Built something for you — tap to see."* / *"Your closet, in progress. Want a look?"* The voice is right; the exact wording deserves scrutiny because this is the most leveraged single line in onboarding.
- **The + button shape.** Circular vs rounded-square. I'm leaning circular (Instagram-style) because it reads as more "primary action" and less "tab." But a rounded-square + sits more comfortably alongside the other tab icons typographically. Prototype both.
- **Tab labels — text or icon-only.** I've specified icon + label. Icon-only would be cleaner visually but harder for first-time users to parse. Test post-MVP.
- **Wardrobe "Looks" vs "Items" toggle placement.** Inside the tab as a segmented control at the top, or as a slider/pill near the header. Segmented control is the iOS-default; a custom pill is more on-brand. Worth prototyping both.
- **Profile-style header on the Wardrobe tab.** Should there be any visual element (small avatar, monogram, color block) above the grid, or is just the "Your fashion history" line + count enough? Lean toward just the line — adding an avatar risks turning a private page into a social-feeling one, which is the wrong direction for this app.
