import { cp, copyFile, mkdir, readFile, readdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { loadSources, readText } from "./source.mjs";
import { renderMarkdown } from "./markdown.mjs";
import { BASE_PATH, CATEGORIES, GUIDE_ROUTES, PRODUCTS, REPOSITORY_ROOT, REPOSITORY_URL, SITE_ORIGIN, SITE_ROOT, TOOLS, sitePath } from "./config.mjs";

const sources = await loadSources();
const output = path.join(SITE_ROOT, "src", "generated");
const publicRoot = path.join(SITE_ROOT, "public");
await Promise.all([mkdir(output, { recursive: true }), mkdir(path.join(publicRoot, "generated"), { recursive: true })]);
await cp(path.join(REPOSITORY_ROOT, "docs", "assets"), path.join(publicRoot, "assets"), { recursive: true });
await mkdir(path.join(publicRoot, "schemas"), { recursive: true });
await copyFile(path.join(REPOSITORY_ROOT, ".github", "schemas", "sample.schema.json"), path.join(publicRoot, "schemas", "sample.schema.json"));
const productRoot = path.join(publicRoot, "images");
for (const name of ["graph.svg", "aad.svg", "azure.svg", "office.svg", "todo.svg"]) {
  await copyFile(path.join(REPOSITORY_ROOT, "docs", "assets", "icons", "custom", name), path.join(productRoot, name));
}
const authors = new Map();
const samples = [];
const publishContent = (source) => !["node_modules", ".git"].includes(path.basename(source)) && !/^\.env(?:\.|$)/.test(path.basename(source));
const codeHelp = new Map();
for (const filename of ["powershell.help.json", "cli.help.json", "spoms.help.json", "other.help.json"]) {
  const entries = JSON.parse(await readText(path.join(REPOSITORY_ROOT, "docs", "assets", "help", filename)));
  if (!Array.isArray(entries)) throw new Error(`docs/assets/help/${filename}: expected command reference array`);
  for (const entry of entries) if (entry.cmd && entry.helpUrl) codeHelp.set(entry.cmd.toLowerCase(), entry.helpUrl);
}
for (const source of sources) {
  const { slug, metadata, readme, products } = source;
  const sourcePath = `scripts/${slug}/README.md`;
  let rendered;
  try { rendered = renderMarkdown(readme, sourcePath, { commandHelp: codeHelp }); }
  catch (error) { throw new Error(`${sourcePath}: ${error.message}`, { cause: error }); }
  const sampleAuthors = metadata.authors.map((author) => {
    const handle = author.gitHubAccount;
    const key = handle.toLowerCase();
    const existing = authors.get(key);
    if (existing) existing.count += 1;
    else authors.set(key, { handle, name: author.name, pictureUrl: `https://github.com/${encodeURIComponent(handle)}.png?size=144`, count: 1 });
    return { handle, name: author.name, pictureUrl: `https://github.com/${encodeURIComponent(handle)}.png?size=64` };
  });
  const searchProducts = products.flatMap((id) => {
    const product = PRODUCTS.find((candidate) => candidate.id === id);
    if (!product) throw new Error(`${slug}: product registry does not contain ${id}`);
    return [product.label, ...product.aliases, ...(product.searchAliases ?? [])];
  });
  const tools = metadata.metadata.map((tool) => ({ id: tool.key, label: TOOLS[tool.key], version: tool.value }));
  const sample = {
    slug,
    title: metadata.title,
    description: metadata.shortDescription,
    products,
    categories: metadata.categories,
    tags: metadata.tags,
    tools,
    created: metadata.creationDateTime,
    updated: metadata.updateDateTime,
    authors: sampleAuthors,
    references: metadata.references,
    sourceUrl: `${REPOSITORY_URL}/tree/main/scripts/${encodeURIComponent(slug)}`,
    url: `https://pnp.github.io${sitePath(`samples/${encodeURIComponent(slug)}/`)}`,
    legacyUrl: metadata.url,
    previews: metadata.thumbnails.filter((thumbnail) => thumbnail.type === "image").map((thumbnail) => ({
      src: sitePath(decodeURIComponent(new URL(thumbnail.url).pathname).slice("/pnp/script-samples/main/scripts/".length)),
      alt: thumbnail.alt
    })),
    commandReferences: metadata.tags.filter((tag) => codeHelp.has(tag.toLowerCase())).map((tag) => ({ name: tag, url: codeHelp.get(tag.toLowerCase()) })),
    search: [slug, metadata.title, metadata.shortDescription, ...metadata.tags, ...metadata.products, ...searchProducts, ...metadata.categories, ...tools.map((tool) => tool.label), ...sampleAuthors.flatMap((author) => [author.handle, author.name])].join(" ").toLowerCase(),
    readmeHtml: rendered.html,
    scriptTabCount: rendered.scriptTabCount,
    codeBlockCount: rendered.codeBlockCount
  };
  if (!sample.codeBlockCount) throw new Error(`${sourcePath}: sample must contain at least one fenced code block`);
  samples.push(sample);
  await cp(path.join(REPOSITORY_ROOT, "scripts", slug), path.join(publicRoot, slug), { recursive: true, filter: publishContent });
}
samples.sort((left, right) => right.updated.localeCompare(left.updated) || left.title.localeCompare(right.title));
const guides = [];
for (const [source, route] of Object.entries(GUIDE_ROUTES)) {
  if (!route) continue;
  const markdown = await readText(path.join(REPOSITORY_ROOT, ...source.split("/")));
  const title = /^#\s+(.+)$/m.exec(markdown)?.[1];
  if (!title) throw new Error(`${source}: guide needs an H1 title`);
  const rendered = renderMarkdown(markdown, source);
  guides.push({ source, route, title, html: rendered.html });
}
const products = PRODUCTS.map(({ aliases, ...product }) => ({
  ...product, featured: Boolean(product.featured), image: product.image ?? "", monogram: product.monogram ?? "",
  count: samples.filter((sample) => sample.products.includes(product.id)).length
})).filter((product) => product.count).sort((a, b) => b.count - a.count || a.label.localeCompare(b.label));
const tools = Object.entries(TOOLS).map(([id, label]) => ({ id, label, count: samples.filter((sample) => sample.tools.some((tool) => tool.id === id)).length }))
  .filter((tool) => tool.count).sort((a, b) => b.count - a.count || a.label.localeCompare(b.label));
const contributors = [...authors.values()].sort((a, b) => b.count - a.count || a.name.localeCompare(b.name));
const aliases = JSON.parse(await readFile(path.join(SITE_ROOT, "content", "legacy-aliases.json"), "utf8"));
const redirects = Object.fromEntries([
  ...samples.flatMap((sample) => [
    [`${sample.slug}/README.html`, sitePath(`samples/${encodeURIComponent(sample.slug)}/`)],
    [`${sample.slug}/index.html`, sitePath(`samples/${encodeURIComponent(sample.slug)}/`)]
  ]),
  ...Object.entries(aliases).map(([alias, slug]) => [`${alias}/README.html`, sitePath(`samples/${encodeURIComponent(slug)}/`)]),
  ...guides.map((guide) => [`${guide.route.replace(/\/$/, "")}.html`, sitePath(guide.route)]),
  ["by-product.html", `${sitePath("")}?browse=products`],
  ["by-tool.html", `${sitePath("")}?browse=tools`],
  ["compact-view.html", `${sitePath("")}?layout=list`],
  ...["matrix", "metadata", "cmdusage", "age"].map((report) => [`${report}.html`, `${sitePath("reports/")}#${report}`])
]);
for (const [legacy, target] of Object.entries(redirects)) {
  const file = path.join(publicRoot, ...legacy.split("/"));
  await mkdir(path.dirname(file), { recursive: true });
  const canonical = new URL(target, SITE_ORIGIN);
  const scriptTarget = JSON.stringify(target).replaceAll("<", "\\u003c");
  const escaped = target.replaceAll("&", "&amp;").replaceAll('"', "&quot;");
  await writeFile(file, `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex"><meta http-equiv="refresh" content="0;url=${escaped}"><link rel="canonical" href="${canonical.origin}${canonical.pathname}"><title>Sample moved | Community Script Samples</title></head><body data-legacy-redirect><p>This page has moved. <a href="${escaped}">Continue to the gallery</a>.</p><script>const next=new URL(${scriptTarget},location.origin);for(const [key,value] of new URLSearchParams(location.search)){if(!next.searchParams.has(key))next.searchParams.set(key,value)}if(location.hash&&!next.hash)next.hash=location.hash;location.replace(next.pathname+next.search+next.hash);</script></body></html>\n`);
}
const catalog = { version: 1, samples, products, tools, categories: CATEGORIES, contributors, guides, redirects };
await writeFile(path.join(output, "catalog.json"), `${JSON.stringify(catalog)}\n`);
const publicSamples = samples.map(({ readmeHtml: _html, search: _search, ...sample }) => sample);
await writeFile(path.join(publicRoot, "catalog.json"), `${JSON.stringify({ version: 1, samples: publicSamples, products, tools, contributors })}\n`);
const legacySamples = sources.map(({ slug, metadata }) => {
  const { source: _source, longDescription: _description, references: _references, ...record } = metadata;
  return {
    ...record,
    url: `${slug}/README.html`,
    thumbnails: metadata.thumbnails.map((thumbnail) => ({
      ...thumbnail,
      url: decodeURIComponent(new URL(thumbnail.url).pathname).slice("/pnp/script-samples/main/scripts/".length)
    }))
  };
});
await writeFile(path.join(publicRoot, "samples.json"), `${JSON.stringify(legacySamples)}\n`);
await writeFile(path.join(output, "routes.json"), `${JSON.stringify({ base: BASE_PATH, samples: samples.map((sample) => sample.slug), guides: guides.map((guide) => guide.route), redirects }, null, 2)}\n`);
console.log(`[gallery] validated and generated ${samples.length} complete samples, ${contributors.length} contributors, ${guides.length} guides, and ${Object.keys(redirects).length} redirects`);
console.log(`[gallery] rendered ${samples.reduce((count, sample) => count + sample.scriptTabCount, 0)} tool tabs and ${samples.reduce((count, sample) => count + sample.codeBlockCount, 0)} complete code blocks`);
