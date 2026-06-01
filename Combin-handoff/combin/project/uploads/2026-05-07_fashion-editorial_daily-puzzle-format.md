---
agent: fashion-editorial
date: 2026-05-07
topic: daily-puzzle-format
type: decision
status: proposed
references:
  - agent: fashion-intelligence
    topic: puzzle-evaluation-rules
  - agent: ux-designer
    topic: daily-puzzle-flow
  - agent: wellbeing-tone-steward
    topic: puzzle-warning-copy
  - agent: business-growth
    topic: free-vs-paid-content
  - agent: product-strategist
    topic: education-tab-scope
tags: [education, gamification, puzzle, daily-content]
---

# Daily Puzzle: a "find the missing piece" game with conditional fit, taught through fashion-literate prompts and warm corrections

## Editorial position

Combin ships a Daily Puzzle as a core education-layer feature. The mechanic: the app shows an outfit with one garment missing (a slot represented as a silhouette gap or empty hanger), gives the user a *condition* — "make this more serious," "make this read more Saturday-night," "make this work for an afternoon gallery opening," "layer this for a colder day" — and the user searches the in-app garment database to pick a piece they think satisfies the condition. The user's pick is evaluated against the condition. If it doesn't fit, the app explains *what direction the pick pushed the outfit* rather than declaring it wrong.

The puzzle is, formally, the gamified entry point of the education layer. Editorially it is a *teaching exercise dressed as a puzzle*. The condition prompts and the corrective feedback are where the education actually happens, and they need to be written with the same care as the Daily Insight — same voice, same standards, same ban on generic content.

The puzzle is **free for all users, daily, one per day**. This is consistent with the existing position that the daily content layer is the daily reason to open the app. (Possible Plus extension: an archive of past puzzles, multi-puzzle days, or themed weeks. See "Free vs paid" below.)

## Reasoning

- **The mechanic teaches the right thing.** Fashion taste is, at its core, the ability to feel *what direction a piece pushes an outfit* — toward formality, drama, casualness, era, mood. That is the exact thing this puzzle drills, every day, in 60 seconds. It is not a trivia quiz about who designed what; it is a perception exercise. That is rare and good.
- **Conditional fit beats right/wrong.** The puzzle has no single correct answer — many pieces could satisfy "more serious." That removes the test-anxiety failure mode and respects fashion's actual nature, which is non-binary. The user is being *trained to see consequences*, not graded.
- **The warning copy is where credibility is built or lost.** "This piece makes the outfit more joyful" or "this layers the outfit but pushes it off-formality" is the actual content. If those lines read as either generic ("this is too casual!") or condescending ("nice try!"), the feature collapses. The voice has to be specific, observed, and warm — the same standards as Daily Insight.
- **Compatibility with wellbeing constraints.** This is gamification that operates entirely on *garments and outfits*, never on the user's body or appearance. The user's pick is evaluated; the user is not. The feedback is about the clothes' direction, not the person's failure. That keeps the feature on the right side of [[wellbeing-tone-steward]]'s line.
- **Habit without streaks.** Daily cadence creates a return reason without requiring a streak counter (which is correctly off the table). One new puzzle a day is enough — users who play yesterday's discover today's; users who skip a day return to a fresh one. No guilt mechanic; the content itself is the reward.
- **It uses the catalog the rest of the app already has.** If Combin maintains a garments catalog (whether the user's wardrobe or a broader product database), the puzzle reuses that asset. No new content surface to maintain at the same scale as a full editorial feed.

## Format / template

A single Daily Puzzle has six editorial components. I'm specifying the editorial shape; [[ux-designer]] decides screen layout, [[fashion-intelligence]] defines the evaluation rules, [[software-architect]] decides retrieval.

### 1. The base outfit
- 4-6 garments shown styled together, with one slot empty.
- A short caption (≤15 words) sets the implicit baseline, e.g. "A weekday workwear leaning on tonal beiges and structured denim."
- The base outfit is a real, defensible look, not a random assemblage. Preferably referenced from a real source (a runway, a stylist's pull, an editorial) — sourcing tracked in metadata, not displayed.

### 2. The empty slot
- One missing piece in a category (e.g., a top, an outer layer, a shoe, an accessory).
- The slot is shown explicitly — silhouette outline or empty-hanger icon — so the user knows what kind of piece they are choosing.

### 3. The condition (the editorial heart of the puzzle)
- A single sentence, ≤15 words, that names the direction the user should push the outfit.
- Specific, evocative, named where possible. Editorial bar: this should read like something a stylist would actually say, not a multiple-choice answer.
- See "Sample conditions" below.

### 4. The user's pick
- The user searches the in-app garment database (the same database used for outfit planning per the existing brief) and picks one piece.
- Evaluation engine ([[fashion-intelligence]]) returns: *direction(s) this pick pushes the outfit*, on a small set of axes (formality, mood, layering, era, color story, dress code, etc.). It also returns whether the pick *does or doesn't* satisfy the condition.

### 5. The response (warm, never wrong-coded)
- If the pick satisfies the condition: a one-sentence affirmation that names *why*. "Yes — the brogue brings a third texture and shifts the formality up half a step. The polish reads grown-up."
- If the pick doesn't satisfy: a one-sentence direction note that names what the pick *did* do. "That pushes the outfit toward weekend casual — softer and more relaxed. For 'more serious,' you want something with more structure."
- Optional second sentence: a tiny piece of education, where it earns its place. "This is what stylists call 'breaking up the formality reading' — a single soft piece can lower the register of a whole outfit."

### 6. The unlock
- After the user submits a pick (whether it satisfies or not), the app reveals 2-3 *example pieces* that would have worked, each with a one-line "why."
- This is the highest-density education in the puzzle: the user sees 2-3 alternatives and reads the direction-language for each. Over weeks, this builds vocabulary.

## Sample conditions (showing the voice)

Good — specific, evocative, fashion-literate:

- "Make this work for a 7pm gallery opening, not 9am at the desk."
- "Layer this for a damp, dark Tuesday in November."
- "Push this toward Margiela, not toward Brunello."
- "Bring a 90s reference into this without dating it."
- "Make this feel like a Saturday off, not a half-day off work."
- "Add the piece that makes a stranger ask where it's from."

Bad — generic, gamified, condescending:

- "Make this party mode!" — flat, register too app-like.
- "Make this fancy." — vague, no direction.
- "Pick the right shoe." — implies single right answer.
- "Style this for fall vibes." — content-marketing slop.
- "Find the missing item." — no condition at all, just a fetch quest.

The condition is the difference between *playing a game on a fashion app* and *getting taught fashion through a daily puzzle*. The voice has to be specific and adult or the puzzle becomes a children's matching game with clothes.

## Sample exchange (showing the corrective voice)

**Base:** A camel overcoat, a charcoal crewneck, mid-grey wool trousers, and a missing-shoe slot.

**Condition:** "Make this serious — like a meeting where you want to be remembered."

**User picks:** A pair of off-white canvas sneakers.

**Response:** "Those soften the whole thing — the outfit suddenly reads weekend, not boardroom. The canvas pulls against the wool and undoes the formality the trousers are doing. For 'serious,' look for leather, darker, with a clean toe."

**Unlock:** Three alternatives: a black derby ("the conservative answer — quiet and exact"), an oxblood loafer ("more interesting — a flash of color but still grown-up"), a polished black Chelsea ("dressy enough but with a slight rebel pull").

The voice in the response is the editorial work. It names what happened (specific), explains why (mechanism), and points the user toward the answer-shape rather than the exact answer. The unlock teaches three different *flavors* of correct, which is more useful than a single "right answer."

## What to avoid

- **"Wrong" framings.** Never "incorrect," "wrong choice," "try again," "good try!" — these import the language of school tests into a domain where there is no test. Use direction-language ("this pushes the outfit toward X").
- **Generic conditions.** "Make this casual" is not a condition; it's a category. The conditions earn their place by being specific and evocative.
- **Trivia disguised as puzzle.** "Which designer is this?" multiple-choice doesn't belong here. This is a perception exercise, not a quiz.
- **Score, time pressure, or "lives."** No timer, no streak, no point total. The puzzle is contemplative, not arcade-feeling.
- **Rewarding the same answer the AI would give.** If the puzzle's "right" answers always converge on a single safe pick, it trains conformity. The 2-3 alternatives in the unlock should genuinely differ in flavor — conservative answer, interesting answer, riskier answer — to teach that fashion has multiple corrects.
- **Body or identity in the prompt.** Conditions are about *the outfit*, never about the user. "Make this flatter your frame" is out — that's the failure mode the rest of the app is built to avoid, and it would seep in here without vigilance.
- **Sponsorship, click-outs, or shopping prompts inside the puzzle.** This is education. The unlock alternatives are not "find this on Mr Porter" links, are not sponsored placements, and do not display prices. The puzzle lives in the Education tab and obeys the Education-tab rule: editorial-only, no commerce. Per [[fashion-editorial/discover-tab-no-prices-decision]], commerce surfaces stay in Discover; Education is the asset that protects them.

## Coverage / sourcing

The Daily Puzzle needs ~365 puzzles a year. That is roughly the same content load as the Daily Insight, with significant production overlap (both pull from the same canon of designers, references, and styling principles).

- **Sourcing for base outfits**: a curated archive of real looks — runway photos with rights, editorial styling, lookbooks where licensed, plus internal stylist-built compositions. [[privacy-legal/content-licensing]] needs to confirm the rights model. We should NOT use user-submitted outfits in the puzzle — that's a privacy and consent minefield.
- **Sourcing for unlock alternatives**: pulled from the same garments catalog the puzzle uses for user picks. That keeps the system consistent — the user is choosing from the same pool the "ideal" answers come from.
- **Editorial cadence**: I propose puzzles are written in batches of ~30 (a month at a time), with at least 2-week lead so [[fashion-intelligence]] can review evaluation rules and [[wellbeing-tone-steward]] can review the corrective copy.
- **Voice consistency**: written by the same editorial hand as the Daily Insight, using the same voice rules from [[fashion-editorial/editorial-voice-guide]]. Generic or trend-chasing puzzles damage the brand more than skipping a day.

## Free vs paid

My position: the daily puzzle stays free, every day, no archive paywall in MVP.

Reasoning:
- It is the daily return reason. Putting it behind a paywall kills the habit loop.
- It is one of the few engagement levers we have that doesn't touch the user's body — protecting that asset matters.
- It pulls free users into the catalog, which is also the conversion surface for Plus features (wardrobe matching, full feedback).

A Plus extension worth considering (for [[business-growth]] to weigh in on): an *archive* of past puzzles, "puzzle streaks" for completionists (no daily-pressure, just a "you've done 47" view that respects the no-streaks rule), or themed multi-puzzle weeks during fashion weeks. These are nice-to-haves, not MVP.

## Dependencies

- [[fashion-intelligence/puzzle-evaluation-rules]]: the *core* dependency. Defines the axes (formality, mood, era, layering, color, dress-code) on which a pick is evaluated, and the rules that translate a garment's metadata into a direction reading. Without this, the puzzle's response copy has nothing to anchor on. This is the longest-pole work item.
- [[ux-designer/daily-puzzle-flow]]: needs to design the puzzle screen — base outfit display, empty slot indicator, garment search, response sheet, unlock reveal. The mechanic is novel enough that the layout deserves real thought; I suggest it lives in the Education tab as the "today's" piece.
- [[wellbeing-tone-steward/puzzle-warning-copy]]: review of the corrective response patterns. The line between "this pushes the outfit toward casual" (fine) and "you got it wrong" (not fine) is the wellbeing review I want from them. They should also confirm the no-body-language rule holds in conditions.
- [[product-strategist/education-tab-scope]]: confirming the Education tab exists as a separate surface (per the user's recent direction to split Discover and Education) and that the Daily Puzzle is the tab's anchor feature. Also: confirming free-tier inclusion.
- [[business-growth/puzzle-monetization]]: weighing whether puzzle archive / themed weeks / Plus-only puzzle features are worth pursuing post-MVP. My position: puzzle stays editorial-only, no sponsorship, no click-outs, no prices in the unlock alternatives — it lives in Education and obeys the Education-tab rule per [[fashion-editorial/discover-tab-no-prices-decision]].
- [[software-architect/garment-catalog-search]]: the puzzle requires fast, faceted search of the garments catalog (the same one used in outfit planning). Search latency under ~500ms during a puzzle picks is the UX threshold or the puzzle drags.
- [[privacy-legal/content-licensing]]: rights model for runway / editorial / lookbook images used as base outfits.
