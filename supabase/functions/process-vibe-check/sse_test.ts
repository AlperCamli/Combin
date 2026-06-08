import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { sse } from "./sse.ts";

Deno.test("sse formats event stream frames", () => {
  assertEquals(
    sse("stage1", { text: "hi", confidence: 0.9 }),
    'event: stage1\ndata: {"text":"hi","confidence":0.9}\n\n',
  );
});
