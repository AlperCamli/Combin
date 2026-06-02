import { initializeApp, getApps } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

// Initialize the Admin SDK exactly once. Importing this module from any function
// guarantees the default app exists before `getFirestore()` is used. The Admin SDK
// bypasses Security Rules — that is expected for trusted server code.
if (getApps().length === 0) {
  initializeApp();
}

export const db = getFirestore();
