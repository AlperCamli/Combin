import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { getRemoteConfig } from "firebase-admin/remote-config";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "./admin";

// Effectively unlimited during development/testing. Tightened near launch via
// Remote Config — never by editing this constant.
const DEFAULT_DAILY_LIMIT = 1000;
const LIMIT_KEY = "daily_vibe_check_limit";
const appCheckRequired = { enforceAppCheck: true };

interface RateLimitResponse {
  allowed: boolean;
  limit: number;
  remaining?: number;
  reason?: string;
  // The subscription hook: a future free-tier user who hits the cap gets enough
  // here for the client to show an upgrade prompt — a UI-only change later.
  upgradeAvailable?: boolean;
}

/**
 * Step 1.10 — per-user daily cap. The lever exists now; the number stays high
 * (1000) until launch. The client calls this BEFORE Stage 1; a rejection returns a
 * structured reason rather than throwing.
 */
export const checkRateLimit = onCall(
  appCheckRequired,
  async (request): Promise<RateLimitResponse> => {
    const uid = request.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Sign-in required to use Combin.");
    }

    const limit = await dailyLimit();
    const date = utcDate();
    const ref = db.doc(`users/${uid}/usage/daily`);

    const decision = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const data = snap.data();
      const isToday = data?.date === date;
      const count = isToday ? (data?.vibeCheckCount ?? 0) : 0;

      if (count >= limit) {
        return { allowed: false, count };
      }

      tx.set(
        ref,
        {
          date,
          vibeCheckCount: isToday ? FieldValue.increment(1) : 1,
          lastVibeCheckAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return { allowed: true, count: count + 1 };
    });

    // Log EVERY decision (allowed + rejected), no user content, so we can analyze
    // real usage before choosing a launch limit.
    logger.info("rate_limit_decision", {
      uid,
      date,
      allowed: decision.allowed,
      count: decision.count,
      limit,
    });

    if (!decision.allowed) {
      return { allowed: false, reason: "daily_limit", limit, upgradeAvailable: true };
    }
    return { allowed: true, limit, remaining: Math.max(0, limit - decision.count) };
  },
);

/** Read the live limit from Remote Config, falling back to the dev default. */
async function dailyLimit(): Promise<number> {
  try {
    const template = await getRemoteConfig().getServerTemplate();
    const value = template.evaluate().getValue(LIMIT_KEY).asNumber();
    return value > 0 ? value : DEFAULT_DAILY_LIMIT;
  } catch (err) {
    logger.warn("Remote Config read failed; using default daily limit", {
      err: String(err),
      default: DEFAULT_DAILY_LIMIT,
    });
    return DEFAULT_DAILY_LIMIT;
  }
}

/** UTC YYYY-MM-DD. Matches the `date` field shape in the plan. */
function utcDate(): string {
  return new Date().toISOString().slice(0, 10);
}
