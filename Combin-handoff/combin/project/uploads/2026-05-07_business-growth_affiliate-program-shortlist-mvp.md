---
agent: business-growth
date: 2026-05-07
topic: affiliate-program-shortlist-mvp
type: recommendation
status: proposed
references:
  - agent: privacy-legal
    topic: outfit-planning-third-party-content
tags: [affiliate, content-licensing, monetization, mvp, us, eu, turkey]
---

# Affiliate program shortlist for MVP — content rails first, monetization second

## Position

For Combin's MVP outfit-planner, integrate **two affiliate networks at launch and one regional add-on**:

1. **Skimlinks** — the spine. Single contract, ~48,500 merchants, Product API with images/pricing, explicitly built for shopping-style apps and platforms.
2. **Awin** — the European backbone. Hosts Zalando Lounge (multi-country), Trendyol DE/EU, ASOS, Nike, Adidas, hundreds of mid-market fashion brands. Product Feed API + per-merchant approval.
3. **Trendyol via Awin (DE/EU programs) + direct Trendyol Influencer Program later** — Trendyol's most reliable B2B route into Combin is through Awin's Trendyol DE program (and other regional Awin Trendyol programs). The direct Trendyol Influencer Program is creator-focused with a 10K Instagram-follower requirement that doesn't apply cleanly to an app — defer until Combin has a brand presence to apply with.

**Skip in MVP:**
- **Amazon Associates / Creators API.** Three blockers: 10 qualifying sales / 30 days required for API access (chicken-and-egg for a launching app); the Mobile Associates SDK is deprecated for new developers; "apps focused primarily on shopping may not be approved" per the Mobile Associates FAQ — Combin probably qualifies as stylist-not-shopping, but it's a review-risk we don't need at launch. Also, PA-API deprecates 15 May 2026 in favor of the Creators API, which adds caching constraints (prices ≤1hr, images cannot be stored — must link directly with URLs expiring after 24hr) that are awkward for offline-tolerant mobile apps.
- **LTK / Collective Voice (formerly ShopStyle Collective).** Both are creator/influencer programs requiring social-following minimums and treating affiliates as individual content creators. Wrong shape for an app integration. Revisit if Combin builds a creator program later.
- **Direct brand programs (Nike, Adidas, etc.)** — not in MVP. Each requires a separate contract and integration. Awin gives us most of them in one place.

## Reasoning

### Why this is unusual versus the skill's standard guidance

The skill says: don't propose affiliate links in MVP — they compromise editorial credibility before the brand has earned it. That's the correct default for the **monetization** question (slapping shopping links into editorial content). But [[privacy-legal/outfit-planning-third-party-content]] established that affiliate is the **content-licensing** answer for legally displaying any third-party product imagery in the outfit planner. Without affiliate rails, the planner can only show user-photographed garments and AI-generated mockups — no real products, no shoppable looks. That's a feature gap that hurts the product more than the editorial-credibility risk hurts the brand. Different question, different answer.

The mitigation against the editorial-credibility risk is in *how* affiliate items appear: as part of the planner's "items you might add to your wardrobe" surface, not in the AI feedback layer or the editorial layer. Those stay clean. [[fashion-editorial]] needs a final say on the boundary.

### Why Skimlinks as the spine

- One integration, one contract, ~48,500 merchants spanning US and Europe.
- A real Product API (images, pricing, availability) — not just deeplinks. "Skimlinks aggregates data for millions of products across thousands of merchants and provides access via a RESTful Product API. It uses patent-pending technology to match identical products across multiple merchants" — exactly what a planner needs (one canonical "black tee" can be backed by multiple retailers).
- Targeted explicitly at shopping platforms / payment apps, not just bloggers. "Whether you're running a dynamic gifting engine, a real-time deal aggregator, or a curated shopping experience within a payment app, Skimlinks provides the automation and insight you need to drive revenue – reliably and at scale."
- Pricing model: revenue share on transactions, no upfront integration cost, plus a Skimlinks Pro monthly tier for full API access (negotiable).
- Caveat on terms: a merchant can vary commission rates with immediate effect, terminate involvement, or request removal of a specific link, brand, product, or trademark from any or all properties. Combin's content layer must handle merchant pull-outs gracefully (auto-unpublish removed items).

### Why Awin alongside Skimlinks (not instead of)

- Strong European fashion roster Skimlinks doesn't fully cover at the same depth — Zalando's various country programs, Trendyol DE, regional brands.
- Awin hosts over 25,000 advertisers and 270,000+ active publishers; was formed from the merger of Affiliate Window and Zanox; headquartered in Berlin — the EU center of gravity matters for Combin's European launch.
- Per-merchant approval (each Zalando country, each Trendyol region is a separate approval step) is more friction than Skimlinks but the EU-resident publisher relationship is worth it for GDPR-aligned compliance.
- API is rate-limited: "Awin has a throttling system in place that limits the number of API requests to 20 API calls per minute per user" — fine for Combin's expected traffic but worth knowing for product-feed sync architecture.
- Country restrictions on individual programs are real. The Lounge by Zalando programs explicitly reject "non-DK pages," "non-FR pages," etc., meaning we need country-targeted publisher accounts and country-aware item routing in the app. Not a blocker, just architecture to plan ([[software-architect]] needs this in scope).

### Why Trendyol — and why through Awin first

- **Trendyol DE on Awin (and other Trendyol regional programs on Awin)** are the cleanest B2B route. 30-day cookie duration. Standard Awin terms. Sit alongside the rest of the European publisher relationships in a single dashboard.
- **Why not the direct Trendyol Influencer Program in MVP?** It exists, but: "You need to have a minimum of 10k followers on Instagram. We'll also check your engagement rate and review your content." Combin is an app, not an Instagram account. Some agencies onboard apps but the program shape is creator-coded — payment is invoice-based, payment terms are 30 working days, and the program identity is built around content creators with audiences. Approachable post-launch once Combin has a public-facing brand and Instagram presence; not the MVP route.
- Coverage rationale: Trendyol skews Turkish + MENA + parts of EU (DE specifically). It's secondary to Skimlinks/Awin for global coverage but matters for users in Turkey (where you're based, where launch beachheads make sense), and adds non-Western fashion variety the other networks underrepresent.
- Commission: standard reported rates are 5–10% across categories, with cookie windows around 30 days. Variable by category and campaign.

### Numbers (rough, for unit-economics framing)

Per affiliate transaction in apparel, blended industry expectation:

- Average order value: $50–80 USD globally; lower in Turkey (~$25–40) and higher for premium European brands ($80–150).
- Commission rate on apparel: typically 4–10%. Combin can expect ~$3–6 per converted transaction in the global average.
- Click-through to purchase conversion in fashion: 1–4% from in-app discovery surfaces.
- Per active user with affiliate exposure: $0.30–1.50/month in MVP, growing with retention and personalization quality.

This is **content cost recovery**, not a primary revenue line in MVP. The role of affiliate is: (a) it makes the planner legally rich-content, (b) it offsets some Gemini inference cost, (c) at scale and with personalization it becomes a meaningful revenue stream that supplements subscription. The subscription model from [[business-growth/pricing-tiers-mvp]] still leads.

## Implementation

### Application sequence (4–6 weeks before public launch)

1. **Week 1: Skimlinks application.** Apply with the Combin landing page + a clear description of the integration (in-app product display via Product API, click-out to merchant for purchase, no rebranding of merchant content). Skimlinks Publisher Hub access required to negotiate Pro-tier API access. Expect 5–10 business days approval.
2. **Week 1–2: Awin publisher account.** Sign up as a publisher in Awin's UK and Germany regions (covers EU). Apply individually to: Zalando regional programs (DE, FR, NL, IT, SE, etc. — start with DE+FR+NL), Trendyol DE, ASOS UK, Nike EU, Adidas EU, Mango, About You, and 5–10 mid-market fashion brands relevant to Combin's editorial taste. Each per-merchant approval is 3–10 days.
3. **Week 1: Awin US account.** Separate region — covers US-side merchants on Awin (Etsy is the marquee one, plus a long tail of US fashion DTCs). Apply to top 10 fashion advertisers.
4. **Week 3–4: Direct Trendyol Influencer Program — defer.** Note in roadmap for v1.1 once Combin has Instagram presence and ~5K followers. Contact via the Takefluence agency route (the official onboarding path per Trendyol's recent announcements).
5. **Week 4–6: Integration build** ([[software-architect]] owns; outline only):
   - Skimlinks Product API integration → main content source.
   - Awin Product Feeds → daily sync per approved merchant; deeplink generation per click.
   - Click attribution: SubID-per-user-session for analytics + attribution clarity.
   - Country-aware item filtering: items only shown to users whose region matches the merchant's allowed publisher region.
   - Compliance scaffolding: required attribution strings, link-back to merchant on tap, disclosure label per FTC/UK CAP/EU rules.

### Content presentation rules (drives [[ux-designer]] specs)

- Affiliate items appear in a clearly demarcated planner surface — "Add from store" or "Suggested items" — not interleaved with the AI feedback or daily insight content.
- Every affiliate item card shows: image (from API, never re-hosted), brand name, price (live-fetched), and a "View on [Brand]" button that links out.
- Disclosure: a persistent in-context FTC-compliant label ("Combin earns a commission on purchases through these links") on the affiliate surface. Same-medium placement, not a buried footer.
- Removed-merchant graceful degradation: if Skimlinks/Awin signals an item or merchant is pulled, the item disappears within 24 hours; planner surfaces re-fill.

### What gets stored vs what is fetched live

- **Stored locally per user:** Combin's own item catalog references (canonical IDs, mapped categories, embeddings used for matching) — these are *our* metadata, not the merchants'.
- **Fetched live:** product images (always served from merchant CDN, never copied into Combin's storage), pricing, availability. This matters for compliance with affiliate ToS and Apple's content rules. (Amazon's Creators API is even stricter on this — another reason to deprioritize Amazon for now.)
- **Stored in encrypted form:** affiliate API credentials and per-merchant approval flags.

### Disclosure copy (drafts)

For the planner surface header:
> "Some items shown here are from retail partners. When you tap one, you'll go to that store's site to buy it. Combin earns a small commission on purchases — it helps keep the app running. We pick what to show based on your style, not on commission."

For the privacy policy addition:
> "Combin shows products from retail partners (Skimlinks, Awin, and their merchant networks). We don't share your photos or wardrobe data with these partners. When you tap a product, you go to the merchant's site, and from that point your visit is governed by their privacy policy. We may receive commission on purchases."

For App Store reviewer notes:
> "Combin uses Skimlinks and Awin affiliate networks to display licensed product imagery from retail partners within the outfit planner. All product images are served from the merchant's CDN per our affiliate agreements; no merchant content is rehosted by Combin. FTC-compliant disclosure is shown on every screen where affiliate content appears."

## Tradeoffs

- **Editorial credibility risk.** The skill's original concern. Mitigated by hard-walling affiliate from feedback/editorial surfaces, but [[fashion-editorial]] should review the line. If they say it's still too close, escalate to [[product-strategist]].
- **Build cost.** Two affiliate integrations + country-aware filtering + disclosure surfaces is ~3 weeks of engineering. Real, but cheaper than: (a) building licensed image library, (b) operating a stock photo subscription, (c) building direct brand contracts.
- **Geographic complexity.** Per-merchant per-country approvals on Awin mean Combin's content density varies by user region in MVP — a US user sees more US merchants, a German user sees more EU merchants. Need to plan for this honestly in onboarding rather than promising universal richness.
- **Merchant churn risk.** Affiliate networks reserve the right to pull merchants without notice. Combin's content can disappear underneath us. Mitigation: never depend on a single merchant for a category; the canonical-item-mapping in the architecture absorbs the loss.
- **Amazon left on the table.** Amazon has the broadest US apparel catalog and Combin is launching without it. Acceptable for MVP given the friction; revisit at v1.1 once we have qualifying-sales activity from other networks to potentially fund Amazon's gating.
- **Foreign-exchange and payment friction.** Awin pays in regional currency per region; combined with Skimlinks' separate payment cycle, Combin's affiliate revenue accrues across multiple accounts. Treasury overhead is small but real.

## Wellbeing check

The biggest wellbeing risk in any affiliate-driven feature is the engagement loop converting users into compulsive shoppers. [[wellbeing-tone-steward]] needs to weigh in on:

- Whether the planner shows shoppable items by default or only when the user explicitly invokes "shop this look."
- Whether the AI feedback can ever recommend purchasing as a solution. (Position: it should rarely if ever do this — the wardrobe matching feature is "use what you have," not "buy more.")
- Frequency caps on affiliate exposure per session.

My position: affiliate items appear when the user opts into a "shop / inspiration" surface, never injected into the AI feedback or daily insight. Disclosure is honest. No dark patterns to inflate clicks. Wellbeing-compliant by design.

## Metrics to watch

- **Approval rate by network.** If Skimlinks rejects, Awin becomes single-vendor risk — bad. Approval is the first signal.
- **Catalog density per user region.** Items available per user in their country. Target: ≥500 items per major category in the top 5 launch markets within first month.
- **Click-through rate from planner to merchant.** Indicates whether affiliate content is solving a real user need or just sitting there. Target: 3–6% of planner sessions resulting in a click-out.
- **Conversion rate (click-out → purchase).** Network-reported. Industry benchmark for fashion is 1–4%.
- **Revenue per active user per month from affiliate.** Tracking against subscription LTV; sanity-check that affiliate is supplementing, not warping incentives.
- **Removed-merchant incidents.** How often a merchant pulls out and how gracefully Combin handles it. Operations metric.
- **Wellbeing canary: shopping-action complaints in user feedback.** If users report Combin "feels like a shopping app," the line has been crossed and we tighten the wall.

## Dependencies

- [[privacy-legal/outfit-planning-third-party-content]]: this proposal is the implementation track for that recommendation. Privacy review: confirmation that Skimlinks/Awin merchant ToS support our claims about not sharing user data with merchants (we're not — but documenting it).
- [[software-architect/...]]: Skimlinks Product API + Awin Product Feed integration; country-aware item routing; canonical-item-mapping abstraction so merchants can churn underneath us; live-fetch architecture for images and prices.
- [[ux-designer/...]]: planner "Suggested items" surface design; mandatory FTC-compliant disclosure placement; "shop this look" opt-in moment; merchant card layout.
- [[fashion-editorial/...]]: hard wall confirmation — affiliate items never leak into Daily Insight, weekly editorial, or AI feedback layer. Also: editorial taste filter on which merchants we apply to (Combin shouldn't end up with a roster that looks like fast-fashion roulette unless that's a deliberate position).
- [[wellbeing-tone-steward/...]]: review of opt-in framing for the shopping surface; veto on any AI-feedback line that recommends purchasing as a solution.
- [[product-strategist/...]]: scope confirmation that the planner has a shopping surface in MVP; tie-break on the editorial-vs-content-license tradeoff if [[fashion-editorial]] pushes back.
