import { setGlobalOptions, logger } from "firebase-functions/v2";
import { onCall } from "firebase-functions/v2/https";

// Side-effect import: initializes the Admin SDK before any handler runs.
import "./admin";

// Functions run in a European region to sit close to the eur3 Firestore/Storage
// data. (Firestore's eur3 multi-region pairs with Functions in europe-west1.)
setGlobalOptions({ region: "europe-west1", maxInstances: 20 });

/**
 * Step 0.3 — pipeline smoke test. Confirms deploy + callable wiring works.
 */
export const helloWorld = onCall((request) => {
  logger.info("helloWorld called", { uid: request.auth?.uid ?? "anonymous" });
  return {
    message: "Combin functions are live.",
    uid: request.auth?.uid ?? null,
  };
});

export { extractGarments } from "./extractGarments";
export { checkRateLimit } from "./rateLimit";
