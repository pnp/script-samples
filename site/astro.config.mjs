import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";
import { BASE_PATH, SITE_ORIGIN } from "./src/lib/routes.ts";

export default defineConfig({
  site: SITE_ORIGIN,
  base: BASE_PATH,
  output: "static",
  integrations: [sitemap({ filter: (page) => !page.endsWith(".html") })],
  build: { inlineStylesheets: "never" },
  vite: { build: { assetsInlineLimit: 0 } }
});
