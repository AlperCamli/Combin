import { onObjectFinalized } from "firebase-functions/v2/storage";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";
import { db } from "./admin";

// Matches the upload path PhotoUploadService writes: users/{uid}/photos/{photoId}.jpg
const PHOTO_PATH = /^users\/([^/]+)\/photos\/([^/]+)\.jpg$/;

interface Garment {
  category?: string;
  type?: string;
  color?: string;
  confidence?: number;
  attributes?: Record<string, unknown>;
}

/**
 * Step 1.9 — fan a vibe-check's extracted garments out into the wardrobe.
 *
 * Trigger: a photo lands in Cloud Storage. The client's Stage 2 call already did
 * the vision work and wrote a `garments` array onto the vibe-check document, so
 * this function does NOT call Gemini — it just copies each garment into
 * users/{uid}/wardrobe/{itemId}.
 *
 * Race note (deviation from the plan, flagged): the photo finalizes BEFORE the
 * vibe-check document exists (the client writes it ~3.5s later, after Stage 2). The
 * doc isn't keyed by photoId either, so we look it up by `photoStoragePath` with a
 * short bounded retry. If you'd rather avoid the wait entirely, switch the trigger
 * to Firestore `onDocumentCreated("users/{uid}/vibeChecks/{id}")`, which fires only
 * once the garments already exist.
 */
export const extractGarments = onObjectFinalized(
  { region: "europe-west1", memory: "256MiB" },
  async (event) => {
    const objectPath = event.data.name ?? "";
    const match = objectPath.match(PHOTO_PATH);
    if (!match) {
      // Not an outfit photo (thumbnails, other paths) — ignore quietly.
      return;
    }

    const [, uid, photoId] = match;
    const gsUri = `gs://${event.data.bucket}/${objectPath}`;

    const vibeCheck = await findVibeCheckByPhoto(uid, gsUri);
    if (!vibeCheck) {
      logger.warn("extractGarments: no vibe-check found for photo", { uid, photoId });
      return;
    }

    const garments = (vibeCheck.data.garments as Garment[] | undefined) ?? [];
    if (garments.length === 0) {
      logger.info("extractGarments: zero garments to fan out", {
        uid,
        vibeCheckId: vibeCheck.id,
      });
      return;
    }

    const batch = db.batch();
    const wardrobe = db.collection(`users/${uid}/wardrobe`);
    for (const g of garments) {
      const itemRef = wardrobe.doc();
      batch.set(itemRef, {
        sourceVibeCheckId: vibeCheck.id,
        sourcePhotoStoragePath: gsUri,
        category: g.category ?? null,
        type: g.type ?? null,
        color: g.color ?? null,
        attributes: g.attributes ?? {},
        status: "active",
        createdAt: FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    logger.info("extractGarments: wardrobe items written", {
      uid,
      vibeCheckId: vibeCheck.id,
      count: garments.length,
    });
  },
);

/**
 * Find the vibe-check document that references this photo, retrying a few times to
 * cover the window where the photo has finalized but the client hasn't written the
 * doc yet.
 */
async function findVibeCheckByPhoto(
  uid: string,
  gsUri: string,
  attempts = 6,
  delayMs = 1000,
): Promise<{ id: string; data: FirebaseFirestore.DocumentData } | null> {
  const col = db.collection(`users/${uid}/vibeChecks`);
  for (let i = 0; i < attempts; i++) {
    const snap = await col.where("photoStoragePath", "==", gsUri).limit(1).get();
    if (!snap.empty) {
      const doc = snap.docs[0];
      return { id: doc.id, data: doc.data() };
    }
    if (i < attempts - 1) {
      await sleep(delayMs);
    }
  }
  return null;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
