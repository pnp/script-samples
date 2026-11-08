import { readFile, readdir, stat } from "node:fs/promises";
import path from "node:path";
import Ajv2020 from "ajv/dist/2020.js";
import addFormats from "ajv-formats";
import { marked } from "marked";
import { REPOSITORY_ROOT, productIds, TRACKER_BASE } from "./config.mjs";

export async function readText(filename) {
  const buffer = await readFile(filename);
  const encoding = buffer[0] === 0xff && buffer[1] === 0xfe ? "utf-16le"
    : buffer[0] === 0xfe && buffer[1] === 0xff ? "utf-16be" : "utf-8";
  return new TextDecoder(encoding, { fatal: true }).decode(buffer);
}

export function validateTracker(slug, markdown) {
  const expected = `${TRACKER_BASE}/scripts/${slug}`;
  const line = markdown.trimEnd().split(/\r?\n/).at(-1)?.trim();
  const match = /^<img\b[^>]*\bsrc=["']([^"']+)["'][^>]*\/?>$/.exec(line ?? "");
  if (match?.[1] !== expected) throw new Error(`scripts/${slug}/README.md: final line must be the tracking image with src="${expected}"`);
  const count = (markdown.match(/m365-visitor-stats\.azurewebsites\.net/g) ?? []).length;
  if (count !== 1) throw new Error(`scripts/${slug}/README.md: expected exactly one view tracker, found ${count}`);
}

export async function localThumbnail(slug, url, root = REPOSITORY_ROOT) {
  const parsed = new URL(url);
  if (parsed.hostname !== "raw.githubusercontent.com") throw new Error(`${slug}: preview must use the repository's raw.githubusercontent.com URL`);
  const prefix = `/pnp/script-samples/main/scripts/${slug}/`;
  const decoded = decodeURIComponent(parsed.pathname);
  if (!decoded.startsWith(prefix)) throw new Error(`${slug}: preview URL must refer to this sample, not another folder: ${url}`);
  const relative = decoded.slice(prefix.length);
  const directory = path.resolve(root, "scripts", slug);
  const resolved = path.resolve(directory, relative);
  if (!resolved.startsWith(`${directory}${path.sep}`)) throw new Error(`${slug}: unsafe preview path ${url}`);
  let current = directory;
  for (const segment of relative.split("/")) {
    if (!(await readdir(current)).includes(segment)) throw new Error(`${slug}: preview filename or casing does not match the repository: ${relative}`);
    current = path.join(current, segment);
  }
  if (!(await stat(resolved)).isFile()) throw new Error(`${slug}: preview is not a file: ${resolved}`);
  return resolved;
}

export async function loadSources({ root = REPOSITORY_ROOT, trackersOnly = false } = {}) {
  const schema = JSON.parse(await readText(path.join(root, ".github", "schemas", "sample.schema.json")));
  const ajv = new Ajv2020({ allErrors: true });
  addFormats(ajv);
  const validate = ajv.compile(schema);
  const entries = (await readdir(path.join(root, "scripts"), { withFileTypes: true }))
    .filter((entry) => entry.isDirectory() && !entry.name.startsWith("_")).sort((a, b) => a.name.localeCompare(b.name));
  const records = [];
  const errors = [];
  const identities = new Set();
  for (const entry of entries) {
    const slug = entry.name;
    const source = `scripts/${slug}/assets/sample.json`;
    try {
      const readme = await readText(path.join(root, "scripts", slug, "README.md"));
      validateTracker(slug, readme);
      if (trackersOnly) { records.push({ slug }); continue; }
      const parsed = JSON.parse(await readText(path.join(root, ...source.split("/"))));
      if (!validate(parsed)) throw new Error(`${source}: ${ajv.errorsText(validate.errors, { separator: "; " })}`);
      const metadata = parsed[0];
      if (metadata.name !== slug) throw new Error(`${source}: name must match folder "${slug}"`);
      if (identities.has(metadata.name.toLowerCase())) throw new Error(`${source}: duplicate sample identity`);
      identities.add(metadata.name.toLowerCase());
      if (metadata.updateDateTime < metadata.creationDateTime) throw new Error(`${source}: updateDateTime must not precede creationDateTime`);
      const expectedUrl = `https://pnp.github.io/script-samples/${slug}/README.html`;
      if (metadata.url !== expectedUrl) throw new Error(`${source}: url must retain the legacy sample URL ${expectedUrl}`);
      const products = productIds(metadata.products);
      const authorIds = metadata.authors.map((author) => author.gitHubAccount.toLowerCase());
      if (new Set(authorIds).size !== authorIds.length) throw new Error(`${source}: duplicate author account`);
      const keys = metadata.metadata.map((tool) => tool.key);
      if (new Set(keys).size !== keys.length) throw new Error(`${source}: duplicate tool metadata key`);
      const images = metadata.thumbnails.filter((thumbnail) => thumbnail.type === "image");
      for (const image of images) await localThumbnail(slug, image.url, root);
      const prose = marked.lexer(readme).filter((token) => token.type !== "code").map((token) => token.raw).join("");
      if (/<your script>|Lorem ipsum|plugin:\s*add-to-gallery-preparation/.test(prose)) throw new Error(`scripts/${slug}/README.md: unfinished submission placeholder`);
      records.push({ slug, metadata, readme, products });
    } catch (error) {
      errors.push(`${source}: ${error.message}`);
    }
  }
  if (errors.length) throw new Error(`Sample validation failed (${errors.length} files):\n${errors.join("\n")}`);
  return records;
}
