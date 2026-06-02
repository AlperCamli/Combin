# combin-functions

Cloud Functions (TypeScript, Node 20, 2nd gen) + Firestore/Storage Security Rules for Combin.

## What's here

| File | Purpose | Plan step |
| --- | --- | --- |
| `src/index.ts` | `helloWorld` callable (pipeline smoke test) + exports | 0.3 |
| `firestore.rules` / `storage.rules` | Per-user scoping + default-deny | 0.5 |
| `firestore.indexes.json` | Composite index for `wardrobe` (status + createdAt) | 0.5 |
| `test/rules.test.ts` | Rules unit tests (Firestore + Storage) | 0.5 |
| `src/extractGarments.ts` | Storage trigger → fan garments into wardrobe | 1.9 |
| `src/rateLimit.ts` | `checkRateLimit` callable, limit from Remote Config | 1.10 |
| `src/prompts/*` | Canonical Stage 1 / Stage 2 / extraction prompts | 1.5 / 1.7 |

## Local verification (no cloud project needed)

Requires Node 20 and a JDK (the Firestore/Storage emulators need Java).

```bash
cd combin-functions
npm install
npm run build      # tsc — TypeScript compiles
npm run lint       # eslint — clean
npm test           # spins up Firestore + Storage emulators, runs the rules tests
```

`npm test` uses `firebase emulators:exec --project demo-combin …`, so it runs fully
offline against a fake `demo-` project — no credentials, no real Firebase project.

## Deploy (needs the real project + `firebase login`)

```bash
firebase use dev            # or: firebase use prod
npm run deploy              # functions + firestore:rules + storage rules
```

## Notes / decisions

- **Storage rules split read/write** on purpose: `request.resource` is null on reads,
  so the size/content-type checks guard writes only. See the comment in `storage.rules`.
- **`extractGarments` trigger**: fires on photo upload and polls for the matching
  vibe-check doc (the client writes garments after Stage 2). Alternative: switch to a
  Firestore `onDocumentCreated` trigger on `vibeChecks/{id}`. See the header comment.
- **Region**: functions are pinned to `europe-west1` to sit near the `eur3` data.
- **Rate limit**: lives in Remote Config (`daily_vibe_check_limit`), default 1000.
