export function sse(event: string, payload: unknown): string {
  return `event: ${event}\ndata: ${JSON.stringify(payload)}\n\n`;
}

export function sendSSE(
  controller: ReadableStreamDefaultController<Uint8Array>,
  event: string,
  payload: unknown,
) {
  controller.enqueue(new TextEncoder().encode(sse(event, payload)));
}
