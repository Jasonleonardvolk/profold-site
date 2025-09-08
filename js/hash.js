// hash.js
export async function sha256Bytes(uint8) {
  if (crypto?.subtle?.digest) {
    const d = await crypto.subtle.digest('SHA-256', uint8.buffer);
    return hex(new Uint8Array(d));
  }
  // Tiny fallback (very small impl or import) - for brevity we assume WebCrypto.
  throw new Error('No WebCrypto; please use a modern browser');
}
function hex(arr){return [...arr].map(b=>b.toString(16).padStart(2,'0')).join('');}