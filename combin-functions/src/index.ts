import { setGlobalOptions, logger } from "firebase-functions/v2";
import { onCall } from "firebase-functions/v2/https";

// Side-effect import: initializes the Admin SDK before any handler runs.
import "./admin";

// Functions must run in the same region as Firestore and the default Storage
// bucket because extractGarments listens to object finalize events from that bucket.
setGlobalOptions({ region: "europe-west3", maxInstances: 20 });

const appCheckRequired = { enforceAppCheck: true };

/**
 * Step 0.3 — pipeline smoke test. Confirms deploy + callable wiring works.
 */
export const helloWorld = onCall(appCheckRequired, (request) => {
  logger.info("helloWorld called", { uid: request.auth?.uid ?? "anonymous" });
  return {
    message: "Combin functions are live.",
    uid: request.auth?.uid ?? null,
  };
});

export { extractGarments } from "./extractGarments";
export { checkRateLimit } from "./rateLimit";
