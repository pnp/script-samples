export function GET() {
  return new Response("User-agent: *\nAllow: /\nSitemap: https://pnp.github.io/script-samples/sitemap-index.xml\n", { headers: { "Content-Type": "text/plain" } });
}
