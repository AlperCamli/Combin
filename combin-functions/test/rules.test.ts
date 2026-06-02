import {
  initializeTestEnvironment,
  RulesTestEnvironment,
  assertFails,
  assertSucceeds,
} from "@firebase/rules-unit-testing";
import { readFileSync } from "fs";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { ref, uploadBytes } from "firebase/storage";

// Run against the emulator via: `npm test`
// (which is `firebase emulators:exec --project demo-combin --only firestore,storage "mocha"`).

let testEnv: RulesTestEnvironment;

// A tiny but valid-looking JPEG header so contentType, not bytes, is what's tested.
const JPEG_BYTES = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46]);

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "demo-combin",
    firestore: {
      rules: readFileSync("firestore.rules", "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
    storage: {
      rules: readFileSync("storage.rules", "utf8"),
      host: "127.0.0.1",
      port: 9199,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe("Firestore rules", () => {
  it("allows a user to read their own document", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "users/alice/vibeChecks/v1"), {
        stage1Text: "Three textures, one mood.",
      });
    });
    const alice = testEnv.authenticatedContext("alice").firestore();
    await assertSucceeds(getDoc(doc(alice, "users/alice/vibeChecks/v1")));
  });

  it("denies reading another user's document", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "users/alice/vibeChecks/v1"), { stage1Text: "x" });
    });
    const bob = testEnv.authenticatedContext("bob").firestore();
    await assertFails(getDoc(doc(bob, "users/alice/vibeChecks/v1")));
  });

  it("denies an unauthenticated read", async () => {
    const anon = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(anon, "users/alice/vibeChecks/v1")));
  });

  it("denies writes outside the /users tree", async () => {
    const alice = testEnv.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(alice, "global/anything"), { x: 1 }));
  });
});

describe("Storage rules", () => {
  it("allows a valid own-user image upload", async () => {
    const alice = testEnv.authenticatedContext("alice").storage();
    const fileRef = ref(alice, "users/alice/photos/p1.jpg");
    await assertSucceeds(uploadBytes(fileRef, JPEG_BYTES, { contentType: "image/jpeg" }));
  });

  it("denies uploading a non-image file", async () => {
    const alice = testEnv.authenticatedContext("alice").storage();
    const fileRef = ref(alice, "users/alice/photos/p1.jpg");
    await assertFails(uploadBytes(fileRef, JPEG_BYTES, { contentType: "application/pdf" }));
  });

  it("denies uploading an oversized image (>5MB)", async () => {
    const alice = testEnv.authenticatedContext("alice").storage();
    const big = new Uint8Array(5 * 1024 * 1024 + 1);
    const fileRef = ref(alice, "users/alice/photos/big.jpg");
    await assertFails(uploadBytes(fileRef, big, { contentType: "image/jpeg" }));
  });

  it("denies uploading into another user's folder", async () => {
    const bob = testEnv.authenticatedContext("bob").storage();
    const fileRef = ref(bob, "users/alice/photos/p1.jpg");
    await assertFails(uploadBytes(fileRef, JPEG_BYTES, { contentType: "image/jpeg" }));
  });
});
