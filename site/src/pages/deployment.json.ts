import { catalog } from "../lib/catalog";
export function GET() {
  return new Response(JSON.stringify({
    commit: import.meta.env.PUBLIC_COMMIT_SHA || "local",
    sampleCount: catalog.samples.length,
    contributorCount: catalog.contributors.length
  }), { headers: { "Content-Type": "application/json" } });
}
