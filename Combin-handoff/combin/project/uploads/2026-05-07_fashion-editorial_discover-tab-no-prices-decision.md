---
agent: fashion-editorial
date: 2026-05-07
topic: discover-tab-no-prices-decision
type: decision
status: proposed
supersedes: discover-tab-as-catalog-review
references:
  - agent: product-strategist
    topic: ultimate-fashion-app-scope
  - agent: business-growth
    topic: click-out-and-sponsorship-model
  - agent: ux-designer
    topic: discover-tab-design
  - agent: privacy-legal
    topic: click-out-data-handling
  - agent: wellbeing-tone-steward
    topic: shopping-surface-pressure
tags: [discover, sponsorship, editorial-credibility, scope]
---

# Discover-tab as no-price fashion catalog with click-outs and (future) sponsored placements: editorially supportable, with conditions on sponsorship that still need locking in

## Editorial position

The clarified direction is editorially much stronger than the affiliate-catalog reading I flagged previously, and I support it with the conditions below.

The clarification, restated:

1. **Discover is a fashion catalog, not a marketplace.** It shows clothes, brands, designers, collections, references — for browsing, learning, taste-building. Not for buying.
2. **No prices anywhere in Discover.** Items are presented as objects of fashion interest, not as products on sale.
3. **Click-out to external retailers is allowed** when a user wants to find or buy an item — they leave the app and land on Amazon, Mr Porter, the brand's own site, etc.
4. **Future brand sponsorships are on the table** — sponsored prominence on the Discover tab, brand highlights, featured collections, etc.

Items 1 and 2 are excellent and I'm enthusiastic about them. Item 3 is fine with light guardrails. Item 4 is the one that still needs structure — sponsorship is the exact mechanism by which fashion magazines lose editorial credibility over time, and it deserves explicit terms before it's built rather than after.

## Reasoning — why no-prices is the right call

Removing prices from the catalog is a stronger decision than I'd have proposed myself. It does several things at once:

- **It changes what the user is doing in the tab.** With prices, browsing is shopping. Without prices, browsing is *looking at fashion* — appreciating, learning, building references. The user's mental state shifts from "what can I afford" to "what's interesting." That's the right state for a fashion app.
- **It removes the strongest hollowing-out mechanism.** Most editorial-vs-commerce decay starts with "should we surface the affordable version?" or "should we sort by price?" Without prices, those conversations don't happen. The catalog stays curated by editorial worth, not by margin.
- **It opens the door to actual coverage breadth.** A $4,000 Phoebe Philo coat and a $400 COS coat sit on the same page without an implicit hierarchy. Archive Margiela, sample sales, dead-stock pieces, museum-archived looks can all exist in the catalog because they don't need to resolve to "buy now $X." That's the version of "ultimate fashion app" that's actually distinctive.
- **It's defensible.** When users ask why no prices, the answer is plain: "We're a fashion app. We're not selling you anything. If you want to buy something, we'll point you to where it's sold." That answer is a brand asset.

This is the kind of structural decision that pays for itself for years. It deserves to be locked in early and held against the inevitable pressure to soften it.

## Reasoning — click-out is fine, with light guardrails

Pointing users to the brand site, Amazon, Mr Porter, etc. when they want to actually buy is a sensible service. It treats the user as an adult who can manage their own purchasing journey. It also keeps the *transaction* off Combin's surface, which protects the editorial frame — the buying happens in someone else's house.

Reasonable conditions on the click-out:

- **The click-out is a user-initiated action, not a default state.** A "Where to find" button or icon on a product page, not "BUY NOW" plastered across the catalog. The user is leaving the app to shop; that should feel like a deliberate step, not the default flow.
- **Multiple destinations where possible.** If a brand sells direct and through three retailers, surface the brand-direct option first (brands like that), the others below. Don't quietly default everyone to the highest-margin click-out.
- **No price displayed even at the click-out point.** The user clicks "Find this on Mr Porter," they leave the app, the price reveals itself on Mr Porter. The "find" action doesn't drag prices back into Combin.
- **No retargeting on click-out.** When the user clicks out, Combin doesn't track them onward, doesn't show them "you looked at X, here's more like X" later, doesn't send a "still thinking about that coat?" email. Click-out is one-way.
- **Click-out tracking is opt-in if it touches user data**. [[privacy-legal]] should weigh in on what's allowed and what's expected; the editorial position is "the less we track here, the more we can credibly say we're not a shop."

This is a low-cost, low-controversy version of the click-out that preserves the integrity of the rest. I support it.

The click-out can also be light revenue without compromising any of the above — clean affiliate links to Amazon and major retailers generate income from buyers who would have bought anyway, without distorting the catalog. That's the version of revenue that doesn't cost editorial credibility, and it's a reasonable bridge until the app is at the scale where sponsorship makes more sense.

## Reasoning — sponsorship is the part that needs real care

This is where I want to be most direct. **Brand sponsorships that grant prominence on the Discover tab are the exact lever that has hollowed out fashion media for thirty years.** Every fashion publication that started with strong editorial voice and ended up indistinguishable from the others did so via this mechanism. Vogue, Harper's Bazaar, GQ, the magazines you can name — they all sold their front-of-book to advertisers and watched their editorial decisions narrow until the magazine could not be distinguished from a brand catalog.

This is not theoretical. It's a documented industry arc. A fashion-aware user knows the pattern, and they know how to spot it.

The good news: this pattern is avoidable when sponsorship is structured carefully. The bad news: it requires deliberate constraints that have to be set *before* the revenue exists, because once the revenue exists, the pressure to relax the constraints is enormous.

I want the constraints written down now while the question is hypothetical, so the team has something to point to when a brand offers a check that requires bending them.

### Proposed sponsorship terms (worth locking in early)

These are my conditions, on the editorial side. [[business-growth]] should react and propose modifications, [[product-strategist]] tie-breaks if we disagree.

**1. Sponsored placements are visually and unambiguously labeled.**
- "Sponsored," "Brand partnership," or similar — readable, not hidden in 8pt grey at the bottom. Apple and the FTC require this anyway; we should treat it as a matter of pride rather than reluctant compliance.
- Sponsored items have a visible visual treatment — different background, an explicit chip, a badge. Users can tell at a glance.

**2. Sponsorship buys *placement*, not editorial endorsement.**
- A sponsored brand can be featured on a Discover-tab spotlight, can be highlighted in a homepage rail, can be the first brand a user sees in a category. They cannot buy "editor's pick" framing, "we love" copy, or anything that misrepresents editorial selection.
- The line: "this is from Brand X, here's what they make" is fine sponsored copy. "Brand X is one of our favorite designers" is not, unless an editor actually believes it independent of the deal.

**3. Sponsorship does not cross into Education.**
- No sponsored Daily Insights, Daily Puzzles, deep-dives, lessons, contextual education cards. Ever. The Education tab stays editorial-only forever — that is the asset the sponsorship value is built on, and contaminating it kills the value.
- A brand cannot sponsor "education about a designer" even if the designer is theirs. If we run a piece on Marc Jacobs, it's because we have something to say about Marc Jacobs.

**4. Sponsorship does not buy AI feedback or wardrobe-matching influence.**
- The morning mirror moment cannot be steered toward sponsored items. The wardrobe-matching logic cannot quietly weight sponsored brands. The AI is a stylist that gives honest feedback; it is not a salesperson.
- This is also a [[wellbeing-tone-steward]] concern: a user in a vulnerable mirror moment receiving sponsored "you should try this" content would be a serious trust break.

**5. Sponsorship does not narrow catalog coverage.**
- Non-sponsored brands stay in the catalog at full prominence. The catalog as a whole continues to be editorially curated — including the canonical set (major European houses, American sportswear lineage, Japanese/Belgian avant-garde, plus a real non-token presence of designers from Asia outside Japan, Africa, Latin America, the Middle East). Sponsorship can elevate, but cannot exclude.
- A quarterly editorial review confirms coverage breadth hasn't drifted toward sponsored brands.

**6. We can reject sponsorships.**
- Editorial keeps refusal rights. Brands whose practices conflict with the app's values (severe labor practices, repeated cultural appropriation, etc.) can be turned down. This needs to be a written policy so it's defensible when it's exercised.
- Refusal rights also apply to sponsorship *content*: if a brand wants to sponsor with copy or imagery that violates the editorial voice, we can require revisions or decline.

**7. Sponsorship volume cap.**
- A maximum percentage of the Discover surface (and any specific rail or feature within it) is sponsored at any time. I'd propose ~15-20% of visible items max — enough to support real revenue, low enough that the catalog feels editorial. The exact number is [[business-growth]]'s call, but the principle of "there is a cap" is editorial.
- This is the single most important guardrail. Magazines fell because the cap kept moving up. A written cap that requires explicit re-approval to raise is a structural defense.

### Why these terms specifically

The principle behind all seven: **sponsorship can exist in the Discover tab, but it cannot be allowed to bend the editorial decisions made anywhere else in the app.** Discover is the appropriate home for sponsored content because it's already a curated commercial-adjacent surface. Education, AI feedback, the mirror moment, and the catalog's overall coverage breadth are not commercial surfaces and have to stay that way.

These terms also protect the long-term value of sponsorship itself. A trusted editorial app with sponsored placements is a desirable advertising surface and can charge premium rates. An app that's been sponsored into mediocrity is a low-rate ad network. The constraints are the moat for the business model, not against it.

## What's now settled, what still needs decisions

### Settled (in my read of the user's clarification)

- Discover is fashion-first, not commerce-first. No prices.
- Click-out to external retailers is supported when users want to buy.
- Education and Discover are separate tabs.
- The Daily Puzzle (per [[fashion-editorial/daily-puzzle-format]]) lives in Education, not Discover.

### Still needs decisions (flagging for product-strategist and business-growth)

- The seven sponsorship terms above. I'd like written agreement before sponsorship is built, not after.
- Click-out structure: which retailers, in what order, with what (if any) revenue model. My position is plain affiliate links to user-initiated click-outs are fine; aggressive integrations with retailer APIs that pull in pricing/availability are not.
- Whether the catalog also shows *non-purchasable* items — archive pieces, museum looks, runway samples that aren't for sale. My position: yes, this is the differentiator of a no-prices catalog, and it should be intentional.
- Editorial layer inside Discover itself: brief, neutral brand notes ("Marni, founded 1994, Italy. Known for prints and craft. Current creative director: Francesco Risso since 2016.") are appropriate. Anything more critical or opinionated belongs in Education.

## What to avoid (carry-overs from the superseded note that still apply)

- **Hidden sponsored content** — items chosen for sponsorship dollars but not labeled. Users sense this within months and trust collapses.
- **Sponsored Daily Insights or Daily Puzzles** — hard editorial line. The Education tab is editorial-only forever.
- **Algorithm that personalizes Discover at the cost of breadth** — personalization yes, narrowing no.
- **Influencer "edits" or "shop my closet" features** — parasocial commerce, ages badly, not the brand we're building.
- **Lifestyle category creep** — fashion only. Resist beauty, home, travel, lifestyle expansions.
- **Fake urgency in click-outs** ("3 left!", "selling fast!") — even though prices live elsewhere, these dark patterns can leak into Discover via "limited collection" framing. Don't.

## Coverage / sourcing (what changes from the prior version)

The no-prices decision actually *expands* what the catalog can include:

- Archive pieces (out-of-production, vintage runway, archive collector items) that don't have a current retailer can be included. They're fashion references; their non-commercial nature is now a feature, not a problem.
- Couture and sample-only looks — pieces that were never sold — can be included as runway/editorial references.
- Museum holdings and historical pieces (where image rights allow) can be included as canonical references. This is the version of "ultimate fashion app" nobody else can build because every other catalog is structured around the buy.

For sponsored placements, when they exist:
- Sponsored brands must meet the same editorial worth bar as non-sponsored ones. We don't take sponsorship from a brand we wouldn't have covered editorially.
- Sponsored content (the copy, imagery, framing) is editorially reviewed before publication. Brands cannot ship copy directly into the app.
- Sponsorship deals have term limits and require renewal; perpetual sponsored placements drift into editorial assumption over time.

## Wellbeing check

[[wellbeing-tone-steward]] should still weigh in on:

- Catalog browsing as a coping behavior post-mirror-moment ("I look bad → I'll browse fashion to feel better"). The no-prices structure helps significantly here — there's no compulsive purchase loop available — but browsing intensity might still warrant a soft check-in pattern over long sessions.
- Sponsored "you'd look good in this" framing on Discover items: explicitly out of bounds in my terms, but worth their independent confirmation.
- Whether non-purchasable archive items are aspirational in a healthy way (taste-building) or unhealthy way (creating wants the user can't fulfill). My read is the former — looking at clothes you can't buy is what museums and books are for, and it's how taste develops — but it's their call.

## Dependencies

- [[product-strategist/sponsorship-policy]]: needs to ratify the seven terms above (or modify them and resolve any disagreement with [[business-growth]]).
- [[business-growth/click-out-and-sponsorship-model]]: needs to react to the click-out guardrails and sponsorship terms. The 15-20% volume cap especially — this is where the most revenue tension will live.
- [[ux-designer/discover-tab-design]]: designs a no-prices catalog. Distinct visual treatment for sponsored items. Click-out as a deliberate user action, not a default. Brief brand notes layout.
- [[ux-designer/click-out-flow]]: how the user leaves the app — confirmation? direct? — and whether destination retailer is selectable.
- [[privacy-legal/click-out-data-handling]]: data flows when users click out, FTC sponsored-content compliance, retargeting and tracking limits.
- [[wellbeing-tone-steward/shopping-surface-pressure]]: independent review of the no-prices catalog as compulsive-browse risk and the wellbeing implications of unattainable items.
- [[fashion-intelligence/catalog-coverage-canon]]: the canonical set the catalog must cover — designers, movements, archive references — regardless of sponsorship status. The list against which the quarterly coverage review is done.
- [[software-architect/catalog-data-model]]: the catalog must support purchasable, archive, and sample-only items as first-class entries, with sponsorship metadata, click-out destinations, and editorial copy fields.
