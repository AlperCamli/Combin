# Combin — Core User Journeys (v2)

**Status:** Brief for design. Supersedes v1.
**Date:** 2026-05-07
**Incorporates decisions from:** fashion-editorial (no-prices Discover), fashion-editorial (Daily Puzzle format), business-growth (affiliate program shortlist), and locked product calls (vibe-check feedback, passive wardrobe, auto-context, photo flexibility).

---

## What's locked, before you read the journeys

The following product calls are settled and these journeys are written to honor them.

The mirror feedback is a **vibe-check one-liner** — the friend-text reaction. Warm, confident-boosting, humor as kindness when the outfit isn't strong. No numerical score, ever. The vibe-check is the app's signature element.

**Wardrobe is built passively.** Image processing extracts garments from every outfit photo and stores them. The AI stylist generates suggestions independently and the wardrobe DB acts as a filter — when a suggestion matches an item the user owns (or a close visual match), surface it as "you already have something like this." When it doesn't, the suggestion stays generic or drops. The AI is never forced to pull from the closet.

**Context inputs auto-fill where possible** — location and weather via device APIs. When unavailable, the user picks from multi-select chips (weather conditions, occasion).

**Photos are flexible.** Mirror selfies, gallery uploads, and someone-else-taken photos all work. The only requirement is outfit visibility. The app must communicate this clearly so users don't think the mirror selfie is mandatory.

**Wardrobe corrections happen contextually**, not as a chore. When the AI surfaces an item ("pair with your black jacket") and it's wrong, the user fixes it inline. The wardrobe browse screen also supports correction, but it's not the primary correction path.

**The app has two non-camera tabs:** Discover and Education. Discover is a no-prices fashion catalog with click-outs to external retailers. Education is the editorial home — Daily Insight, Daily Puzzle, deep-dives, contextual lessons. **No commerce surfaces in Education. Ever.**

The **outfit planner** has a separate "Suggested items" surface (powered by Skimlinks/Awin affiliate networks) where the user *can* see prices on items they don't own — this is a deliberate shopping moment, opt-in, hard-walled from the AI feedback layer and from Education content.

---

## ⚠ Boundary that needs product-strategist resolution before design starts

Two notes from the project agents establish related but not fully aligned positions, and a designer reading them could build something that violates one to honor the other. Naming this so it gets resolved before screens are drawn:

- **fashion-editorial / discover-tab-no-prices-decision** says: no prices anywhere in Discover. Click-outs are user-initiated. No retargeting.
- **business-growth / affiliate-program-shortlist-mvp** says: the planner has a "Suggested items" surface showing brand, **live-fetched price**, and "View on [Brand]" buttons via Skimlinks/Awin.

The reconciliation that *seems* intended: Discover (the catalog tab) shows no prices and lives by editorial rules. The outfit planner (a feature inside the planning flow) has a separate, opt-in shopping surface that does show prices, clearly demarcated. They are different surfaces with different rules.

This needs to be confirmed in writing by product-strategist before design assumes it. The rest of this document is written on that assumption — flagged here so it doesn't get buried.

---

## Cross-cutting requirements (apply to every journey)

These are constraints that should be written into the design brief, not discovered mid-design.

**Speed.** From app-open to vibe-check displayed: under 5 seconds total. From photo capture to one-liner: under 4 seconds. Two-stage response (one-liner appears first, optional tweak loads after) is acceptable.

**Vibe-check voice.** Warm, specific, friend-toned. Never uses "wrong," "bad," "should," "must." Humor lifts when the outfit isn't strong; never punches down. The voice is "fashion-literate friend who texted back fast," not "AI assistant" and not "stylist-magazine professional." This is a copywriting brief as much as a visual one — see "Tone guide for design" at the end.

**Body and identity neutrality.** All imagery — onboarding examples, empty states, illustrations, mannequin silhouettes — represents a real range of bodies, skin tones, gender presentations, ages, abilities, cultural styling. This is a system-level requirement, not a diversity pass at the end.

**Privacy surface.** Photos, location, and wardrobe data each need a visible "your data" affordance — a small, consistent visual treatment that signals "you control this" wherever it appears. Trust is built through repeated small signals, not a one-time privacy screen.

**Failure states are 30% of the early experience.** Empty wardrobe, low-light photo, no clear outfit visible, no recent items in Discover, low AI confidence, denied permissions, offline. Every screen needs its empty/error state designed with the same care as the happy path.

**No commerce in the AI feedback layer or in Education.** This is a hard rule. The mirror moment is sacred — no purchase prompts, no "you should try X," no sponsored items in vibe-check responses. Education tab content is editorial-only, no click-outs, no prices, no sponsored Daily Insights or Puzzles. Affiliate revenue lives in the planner's "Suggested items" surface and (by user-initiated click-out) in Discover. Nowhere else.

---

## Journey 1: First-Run Onboarding

**Trigger:** User has just downloaded the app and opened it for the first time.

**State of mind:** Curious but skeptical. About to be asked for camera access and personal photos. Will quit within 60 seconds if the app feels generic, judgmental, or invasive.

**Goals:** Establish trust. Communicate value in one sentence. Calibrate taste baseline. Capture or upload a first outfit. Deliver a first vibe-check that earns a return visit.

**Steps:**

1. **Welcome.** One screen, one sentence of value, one visual, one CTA. Not three swipeable intro slides. Example copy: "Your stylist in your pocket. Honest when you ask, kind every time." Tap continues.

2. **Trust and privacy.** What we do with photos, plainly. Stored on-device when possible, encrypted in transit, deletable any time, never sold or used for ads. Two CTAs — "Got it" and "Tell me more" (expands inline, doesn't navigate away). This screen carries more weight than any other in onboarding; if it feels legalistic, users bounce.

3. **Taste calibration.** 8–10 outfit cards, multi-select tap. "Which feel like you?" Cards span gender presentations, body types, formality levels, cultural contexts, climate-appropriate looks. The selection seeds the AI baseline and signals to the user that they're being heard before being asked to give. Skippable — defaults to broad recommendations.

4. **Permissions.** Location and weather, framed as functional, not surveillance. "So we can factor in if it's freezing or pouring." Skip is allowed; manual context fallback works in every flow.

5. **First outfit.** Two equally-prominent paths: take a photo or upload from gallery. The "someone else can take it" framing is communicated in microcopy on the camera screen. After capture or upload, a slightly extra-warm vibe-check — this is the moment that earns the second visit. Followed by one tiny educational note tied to the outfit, planting the seed that this app teaches as well as reads outfits.

**Success criteria:** Under 2 minutes total. Camera or gallery permission granted. First photo captured or uploaded. Vibe-check delivered. User reaches the home camera state with the option to explore Discover/Education tabs (but not pushed there).

**Failure modes:**
- Camera access denied → gallery-only path that still works.
- All permissions denied → flow continues with manual context selection.
- Taste calibration skipped → default to broad recommendations, AI quality improves with use.
- First photo unclear (face-only, pet, blurry, no outfit visible) → friendly retry: "I can't quite see the outfit — want to try another angle?" Never an error frame.

**Screens:** Welcome · Trust & Privacy · Taste Calibration · Permissions · First Photo (camera + gallery options) · First Vibe-Check · Soft tab introduction.

---

## Journey 2: Daily Mirror Check (the core loop)

**Trigger:** User is getting dressed, possibly rushed, opens the app for a quick read.

**State of mind:** 30–60 seconds of attention. Wants confirmation, maybe one tweak suggestion, then out the door. Will not read paragraphs. Will not tap through multi-screen flows.

**Goals:** Get from app-open to useful feedback in under 5 seconds. Deliver a vibe-check specific enough to feel real, warm enough to send the user out confident. Optionally surface one wardrobe-aware tweak when it's genuinely good.

**Steps:**

1. **App opens directly into camera view.** Not a home screen, not a feed. The most-used action gets the shortest path. Small affordances in the corners lead to other surfaces (wardrobe, Discover, Education, settings) but the default state is "ready to shoot."

2. **Capture options are visible without tapping into menus.** Take a photo, upload from gallery, or use a recent photo (last few minutes — common pattern: user takes a mirror photo, then opens the app). A soft frame guide signals "outfit visible here" without enforcing strict crop.

3. **Thinking state.** Feels intentional, not a generic spinner. Two-stage response: vibe-check one-liner appears within 1–2 seconds; optional tweak card loads below it within 3–4 seconds. (Sometimes there is no tweak — "you nailed it" stands alone.)

4. **Vibe-check result screen.** Hierarchy:
   - Hero: the one-liner. Big, central, the app's signature typographic moment.
   - Below (optional): one tweak card. "Try this with your olive jacket" (with tap-to-see the wardrobe photo where the jacket was extracted), or "consider rolling the sleeves," or "this would land harder with a different shoe." **Single suggestion, never a list.** Lists feel like critique; one suggestion feels like a friend's nudge.
   - Bottom: small action row — save, share, "tell me more" (expands a deeper read with reasoning, occasion fit, weather notes, optional micro-education).

5. **Most users exit here.** That's correct. The "tell me more" path is for the deliberate users; it should be present but not pushed.

**Success criteria:** App-open to vibe-check displayed in under 5 seconds. User reads the one-liner and exits with a clear feeling. Optional tweak is dismissable in one tap.

**Failure modes:**
- Outfit not visible → friendly retry, no error language.
- Bad lighting → vibe-check still works, with a soft caveat: "hard to see in this light, but here's what I caught."
- User dislikes the read → "second opinion" tap regenerates, capped at ~2 retries per photo so it doesn't become a slot machine.
- AI confidence low → honesty over false enthusiasm. "I'm 50/50 on this one — the silhouette works but the proportions are tricky."

**Wardrobe-aware tweaks (logic note for design):**
- The AI generates 3–4 generic suggestions for the outfit.
- The wardrobe DB checks if any user-owned item (or close visual match — same color, same garment type) satisfies a suggestion.
- If yes, the tweak is presented as "you already have something like this" with a tap-to-see-the-source-photo affordance.
- If no, the AI may still surface a generic tweak, or none at all. The AI is never forced to pull from the closet.
- This logic is invisible to the user but governs whether the tweak card feels personal or generic.

**Screens:** Camera (default) · Capture confirmation · Thinking state · Vibe-Check Result (with optional tweak) · Expanded Read (optional deeper screen with wardrobe item reference, full reasoning).

---

## Journey 3: Outfit Planning ("What should I wear tonight?")

**Trigger:** User has an event or just wants help dressing. Opens the app deliberately, not in a rush.

**State of mind:** 2–5 minutes of attention. Wants real help. Willing to provide context. This is where wardrobe memory becomes the magic feature, and where the planner's affiliate "Suggested items" surface lives.

**Goals:** Understand the context. Generate 2–3 outfit suggestions, drawing from the user's actual wardrobe where it fits, supplemented by suggested items from retail partners when relevant. End with a confident outfit decision.

**Steps:**

1. **Entry point.** "Plan an outfit" button on the camera screen, or via a tab. Lands on context capture.

2. **Context capture.** Multi-select chips for occasion (work, date, casual, formal, gym, travel, religious/cultural event, etc.). Weather (auto-filled, editable). Optional vibe selector (polished, relaxed, statement, quiet, etc.). Optional dress code if specified. The flow doesn't punish the user for skipping any of these — defaults are sensible.

3. **Suggestions.** 2–3 outfit cards generated. Each card shows:
   - A description of the look.
   - One sentence of reasoning ("the camel coat anchors a quiet palette, the boots add a third texture without disrupting the formality").
   - Wardrobe items the user owns, displayed as cropped images with a tap-to-see-source-photo affordance ("your olive scarf, from this look two weeks ago").
   - For pieces the user doesn't own, two paths:
     - **Default:** descriptive only ("a dark, leather-soled shoe — anything with structure"). No commerce.
     - **Opt-in shopping:** a "Suggested items" surface the user can expand, showing retail partner options with brand name, price, and "View on [Brand]" click-out (powered by Skimlinks/Awin). Clearly demarcated from the AI suggestion. FTC disclosure visible. **This is the only place in the app where prices appear.**

4. **Iteration.** The user can swipe through suggestions, tap one for a deeper view, request variations ("warmer," "more relaxed," "different color story"), or ask "tell me what's off" to teach the AI.

5. **Commit.** User picks an outfit, optionally saves it as "tonight's look," optionally sets a reminder to take a mirror photo before leaving — closing the loop back into Journey 2.

**Success criteria:** User commits to an outfit or saves a suggestion. The wardrobe-pull feels natural — at least one suggestion references something owned, when wardrobe data is sufficient. The shopping surface, when expanded, feels like a useful service rather than an interruption.

**Failure modes:**
- Wardrobe too sparse → flow still works with descriptive suggestions, with a gentle nudge: "as I learn your closet, I'll suggest more from what you already own."
- All suggestions rejected → easy regenerate, plus a "tell me what's off" feedback path.
- Niche occasion (cosplay event, religious ceremony, regional dress code) → admit limits gracefully, suggest principles rather than specifics. "I'm not the expert on this one — here's what I'd consider."
- Affiliate item out of stock or merchant pulled out → graceful degradation, item disappears within 24 hours, surface re-fills.

**Hard rules for the "Suggested items" surface:**
- Never injected into AI feedback or vibe-check responses. Only appears when the user expands the planner's shopping surface.
- FTC-compliant disclosure visible: "Combin earns a commission on purchases through these links. We pick what to show based on your style, not on commission."
- "View on [Brand]" is a deliberate user action, not a default state. No "BUY NOW" plastered across cards.
- No fake urgency ("3 left!", "selling fast!"). No dark patterns.
- No retargeting after click-out.

**Screens:** Plan Entry · Context Capture · Suggestions Carousel · Suggestion Detail (with wardrobe item references and optional Suggested Items expansion) · Variation Request · Saved Outfit Confirmation · Optional Mirror Reminder.

---

## Journey 4: Wardrobe Browsing & Correction

**Trigger:** User wants to see what the app knows about their closet, correct an error, or browse for inspiration.

**State of mind:** Curious or maintenance-minded. Not a daily flow. Should feel functional and trustworthy, not like data-entry homework.

**Goals:** Let users see their inventory, correct miscategorizations contextually or in-place, mark items as donated/lost, optionally browse "outfits I've worn this in" for any item.

**Steps:**

1. **Wardrobe entry.** From a tab or menu. Default view is a visual grid organized by category (tops, bottoms, outerwear, accessories, shoes). Each item shows a cropped image extracted from the original outfit photo, plus its detected attributes (color, type).

2. **Item detail.** Tap an item to see:
   - Full source photo (where the item was extracted from).
   - All outfits it has appeared in.
   - AI-detected attributes (color, type, pattern, formality) with edit affordance.
   - Actions: mark as donated, hide, delete.

3. **Inline correction.** Tap a wrong attribute, pick the right one from a short list. No forms, no save buttons. Inline only.

4. **Contextual correction (the more common path).** Outside this screen, in the daily flow or planning flow, when the AI says "pair with your black jacket" and the jacket is actually navy, the user taps to correct in place. Both pathways feed the same data.

5. **Browse mode.** Filter by attribute ("show me my green things," "what do I wear most?"). Inspiration use case, not primary. Power-user nice-to-have.

6. **Manual addition (post-MVP nice-to-have).** Add items the AI missed. Power-user path, not a primary flow.

**Success criteria:** User finds the item they're looking for in under 10 seconds. Corrections take fewer than 3 taps. Wardrobe feels accurate enough to trust, even if imperfect.

**Failure modes:**
- Extraction got the whole item wrong → "this isn't right" path that's faster than fixing 5 attributes.
- Item missing from wardrobe → manual-add path (post-MVP) or an "I'm wearing X today" affordance that the AI confirms.
- User wants to delete a specific item or all wardrobe data → obvious, two-step confirmation, irreversible-with-warning.
- User concerned about a photo → per-photo deletion that also removes the extracted items.

**Screens:** Wardrobe Grid · Item Detail · Inline Correction · Filter/Browse · Item Deletion Confirmation · (Post-MVP: Manual Add).

---

## Journey 5: Discover (the no-prices fashion catalog)

**Trigger:** User opens the Discover tab. Wants to browse fashion — brands, designers, collections, references — for taste-building, learning, inspiration.

**State of mind:** Leisure-mode, taste-curious. Not shopping. The user is *looking at fashion*, not deciding what to buy.

**Goals:** Surface a curated, opinionated catalog of brands, designers, collections, archive references, and runway references. Support click-out to external retailers when the user wants to find or buy. Never show prices in the catalog itself.

**Structure:**

1. **Tab home.** Hero piece, plus curated rails:
   - Editorially-chosen brands and designers in rotation.
   - Collections (current and archive).
   - Movements and references (e.g., "Belgian avant-garde," "American sportswear lineage," "1990s minimalism").
   - Featured pieces — not "shop these," just "these are interesting right now."

2. **Brand and designer pages.** Brief, neutral brand notes ("Marni, founded 1994, Italy. Known for prints and craft. Current creative director: Francesco Risso since 2016."). Items shown as objects of fashion interest. **No prices, ever, anywhere in Discover.**

3. **Item detail.** Image, brand, item name, materials, designer, collection. Optionally a link to a related Education piece ("learn about this designer," "the references in this collection"). One-way flow: Discover can link into Education; Education does not link to Discover.

4. **Click-out (user-initiated).** When the user wants to actually find or buy an item, a "Where to find" button reveals destinations — brand-direct first when available, then retailers (Mr Porter, Net-a-Porter, SSENSE, Farfetch, regional retailers). Tapping leaves the app. Price reveals on the destination site, not in Combin. No retargeting. No "still thinking about this?" follow-ups.

5. **Sponsored placements (when the business introduces them).** Visually labeled, capped at ~15–20% of visible items, never in Education, never influencing AI feedback or wardrobe matching. See the seven sponsorship terms in the fashion-editorial discover-tab-no-prices-decision note.

**Success criteria:** User browses without feeling sold to. Taste-building behavior, not shopping behavior. Click-outs happen when the user wants them, not when the app pushes them.

**Failure modes:**
- Catalog too thin in user's region → honest fallback ("we're growing our coverage in your region — here's what we have"). Worse than promising universal richness and failing.
- User looking for specific item not in catalog → search affordance, plus graceful "we don't have that yet" state.
- User wants prices → explainer copy ("we don't show prices in Discover. Tap 'Where to find' to see prices on the retailer's site"). Defensible, brand-consistent.
- Sponsored item indistinguishable from editorial pick → design failure, the labeling has to be unambiguous.

**Hard rules:**
- **No prices in Discover.** Including price filters, price ranges, "from $X" framing, or "affordable / luxury" sorting.
- **No retargeting.** Click-out is one-way.
- **Curated, not infinite-scroll.** "We picked these because they're worth your time," not "here's everything."
- **Coverage breadth is editorial.** Major European houses, American sportswear, Japanese/Belgian avant-garde, plus a real (non-token) presence of designers from Asia outside Japan, Africa, Latin America, the Middle East. This is the differentiator versus other catalogs.
- **Archive and non-purchasable items are first-class entries.** Out-of-production pieces, runway samples, museum holdings (rights permitting). The catalog isn't structured around the buy.

**Screens:** Discover Home · Brand/Designer Page · Collection Page · Item Detail · Click-Out Destinations · Search · Sponsored Item (visually distinct from editorial picks).

---

## Journey 6: Education (the editorial home)

**Trigger:** User opens the Education tab. Could be from a notification ("today's puzzle is ready"), a contextual link from a vibe-check ("learn about half-tucks"), or curiosity.

**State of mind:** Wants to learn or be challenged. Has a few minutes. This tab is what makes the app culturally weighty — the user is growing taste, not just being read.

**Goals:** Deliver the Daily Insight and Daily Puzzle as the daily anchors. Surface deep-dives, recommendations (articles, films, documentaries, designer profiles), contextual lessons. Be the one tab users open even when they're not getting dressed.

**Structure:**

1. **Tab home.** Today's content surfaced first:
   - **Today's Daily Insight.** A short editorial piece (~3–4 minutes to read), tied to fashion-literate observation. Could be about a designer, a movement, a styling principle, a piece of canon. Free for all users.
   - **Today's Daily Puzzle.** The "find the missing piece" game per the fashion-editorial daily-puzzle-format note. Editorial heart of the puzzle is the *condition* — "make this serious, like a meeting where you want to be remembered" — and the *response* — direction-language, never wrong-coded. Free for all users, daily, one per day.

2. **Below the daily anchors.** Curated feed of:
   - Weekly deep-dives (partially Plus-gated, when monetization comes online).
   - Recommended articles, films, documentaries, books, Instagram accounts to follow. Curated, not algorithmic feed.
   - Designer profiles.
   - Glossary / canon entries.
   - Contextual lessons surfaced when the user has been reading or wearing in a particular direction ("you've been reaching for earth tones — here's why that palette is having a moment").

3. **In-app reader for articles.** Saves and dismissals tune future picks. Films and documentaries link out (no in-app video).

**The Daily Puzzle (key feature, treat with editorial weight):**

- **Format:** A base outfit (4–6 garments) with one slot empty. A condition (≤15 words, evocative, fashion-literate). The user searches the in-app garments database to pick a piece that satisfies the condition.
- **Response:** Direction-language. "That pushes the outfit toward weekend casual — softer and more relaxed. For 'more serious,' look for something with more structure." Never "wrong" or "incorrect." Optional second sentence of education.
- **Unlock:** 2–3 example pieces that would have worked, each with a one-line "why." Different flavors of correct (conservative answer, interesting answer, riskier answer) — teaches that fashion has multiple corrects.
- **No score, no timer, no streak, no "lives."** Contemplative, not arcade.
- **No commerce.** No "shop this" links in unlock alternatives. No prices. No sponsored placements. Education is editorially-pure forever.

**Success criteria:** User opens the tab at least 3x per week. Daily Insight read or scrolled. Daily Puzzle attempted. At least one weekly deep-dive saved or read per fortnight. Education feels earned and personal, not generic.

**Failure modes:**
- User has no behavior data for personalization → fall back to broad-but-good editorial picks. Note that "recommendations sharpen as I learn what you like."
- Too highbrow or too basic for the user → lightweight "more like this / less like this" signal.
- Slow content week → no empty states screaming "nothing here." Recently-read or canonical pieces fill the gap gracefully.
- User finds a piece dated or thin → "more like this" / "less like this" tuning + signal to editorial team.

**Hard rules:**
- **No commerce in Education. Ever.** No shopping links, no prices, no sponsored Daily Insights or Puzzles, no "shop the look" buttons in deep-dives, no affiliate placements anywhere in this tab.
- **Education does not link to Discover.** Discover can link to Education ("learn about this designer"). Reverse flow only.
- **No sponsored content,** even labeled. Sponsored Daily Insight contaminates all the unsponsored ones.
- **Voice consistency.** Same editorial hand and voice rules across Daily Insight, Daily Puzzle, deep-dives, contextual lessons.

**Screens:** Education Home (Today rail + curated feed) · Daily Insight Reader · Daily Puzzle (base outfit, condition, garment search, response, unlock) · Deep-Dive Reader · Recommendations List · Designer Profile · Glossary / Canon Entry · Saved Items.

---

## Tone guide for design (vibe-check voice)

This is the most leveraged document for the team — every screen has copy, and the copy is the product as much as the visuals.

**The voice is:** a fashion-literate friend who texted back fast. Specific. Warm. Confident. Funny when the situation calls for it — humor as kindness, never as ridicule. Never preachy, never schoolmarmish, never AI-assistant flat.

**The voice is not:** a stylist magazine ("This season's must-have silhouette..."). An app assistant ("I have analyzed your outfit. Here are my findings."). A scoring engine ("6/10. Could improve with..."). A salesperson ("You'd look great in this. Tap to shop."). A hype machine ("AMAZING look queen!!").

**Words to avoid throughout:**
- "Wrong," "incorrect," "bad," "mistake," "error," "fail," "good try" → all import school-test framing into a domain that has no test. Use direction-language instead ("this pushes the outfit toward casual," "that softens the formality").
- "Should," "must," "need to" → command voice. Use "try," "consider," "what about" instead.
- "Beautiful," "stunning," "gorgeous" → empty enthusiasm; doesn't read as honest. Use specific observations.
- "Okay," "fine," "not bad" → damning faintness. If the outfit works, say what works. If it doesn't, name the direction.

**Vibe-check examples (good):**

When the outfit works:
- "Quiet confidence — the kind people remember without knowing why."
- "This is doing the work. You can leave."
- "Three textures, one mood. That's the trick."
- "The proportions are right. Everything else is bonus."

When the outfit needs a tweak:
- "Almost there — one more anchoring piece and this lands."
- "The colors are good friends. The shapes are still working it out."
- "This wants a third texture. Right now it's two notes when it could be three."

When the outfit isn't strong (humor as kindness):
- "Brave choice. Possibly too brave. Want a second opinion?"
- "I have notes. Mostly affectionate."
- "This is doing a lot. Some of it on purpose."

When the AI is uncertain:
- "I'm 50/50 on this — the silhouette works but the proportions are tricky. What's the occasion?"
- "Hard to read in this light, but here's what I caught."

**Daily Puzzle response examples (good):**

When the pick works:
- "Yes — the brogue brings a third texture and shifts the formality up half a step. The polish reads grown-up."

When the pick doesn't work:
- "Those soften the whole thing — the outfit suddenly reads weekend, not boardroom. The canvas pulls against the wool and undoes the formality the trousers are doing. For 'serious,' look for leather, darker, with a clean toe."

The voice is the same in both apps. Calibrated, specific, never punishing.

---

## What design needs to decide next

These journeys are scoped. Before screens get drawn, design and product need to lock:

- The product-strategist boundary call between Discover (no prices) and the planner's Suggested Items surface (prices visible).
- The visual treatment of the vibe-check one-liner — typography, weight, motion. This is the app's signature element and deserves treatment as a system primitive, not a text style.
- The "your data" privacy affordance — small, consistent, repeated across photos / location / wardrobe.
- The wardrobe item thumbnail strategy — extracted crops will vary in quality, the system needs a uniform container approach.
- The Daily Puzzle layout — base outfit display, empty slot indicator, garment search affordance, response sheet, unlock reveal.
- The sponsored item visual treatment in Discover (when sponsorship comes online).

When these are settled, the journeys above are ready to be turned into screen flows.
