import fs from "node:fs";
import path from "node:path";
import { marked } from "marked";
import sanitizeHtml from "sanitize-html";
import { createHighlighter } from "shiki";
import { BASE_PATH, GUIDE_ROUTES, REPOSITORY_ROOT, REPOSITORY_URL, encodePath, sitePath } from "./config.mjs";

const highlighter = await createHighlighter({
  themes: ["github-light", "github-dark-high-contrast"],
  langs: ["powershell", "bash", "json", "javascript", "typescript", "yaml", "python", "html", "css", "markdown", "csv", "xml", "sql", "csharp", "text"]
});
const directories = new Map();
const fileCache = new Map();
const escape = (value) => String(value).replace(/[&<>"']/g, (character) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[character]);
const languageAliases = { pwsh: "powershell", ps1: "powershell", ps: "powershell", sh: "bash", shell: "bash", js: "javascript", ts: "typescript", yml: "yaml", "c#": "csharp", plaintext: "text" };

export function canonicalFile(relative) {
  const clean = path.posix.normalize(relative.replaceAll("\\", "/"));
  if (clean.startsWith("../") || path.posix.isAbsolute(clean)) throw new Error(`Content path escapes the repository: ${relative}`);
  if (fileCache.has(clean)) return fileCache.get(clean);
  let directory = REPOSITORY_ROOT;
  const actual = [];
  for (const part of clean.split("/").filter((segment) => segment !== ".")) {
    if (!directories.has(directory)) directories.set(directory, fs.readdirSync(directory));
    const names = directories.get(directory);
    const name = names.includes(part) ? part : names.find((candidate) => candidate.toLowerCase() === part.toLowerCase());
    if (!name) throw new Error(`Missing local content: ${relative}`);
    actual.push(name);
    directory = path.join(directory, name);
  }
  const result = actual.join("/");
  fileCache.set(clean, result);
  return result;
}

export function contentTarget(source, target, image = false) {
  const value = target.trim().replaceAll("&amp;", "&");
  if (!value || value.startsWith("#")) return value;
  if (value.startsWith("//")) return contentTarget(source, `https:${value}`, image);
  if (/^(https?:|mailto:)/i.test(value)) {
    const url = new URL(value);
    if (url.hostname === "pnp.github.io" && url.pathname.startsWith(`${BASE_PATH}/`)) {
      const sample = /^\/script-samples\/([^/]+)\/README\.html$/i.exec(url.pathname);
      if (sample && fs.existsSync(path.join(REPOSITORY_ROOT, "scripts", decodeURIComponent(sample[1]), "README.md"))) {
        return `${sitePath(`samples/${sample[1]}/`)}${url.search}${url.hash}`;
      }
    }
    const rawPrefix = "/pnp/script-samples/main/";
    if (url.hostname !== "raw.githubusercontent.com" || !url.pathname.startsWith(rawPrefix)) return value;
    return contentTarget("README.md", `${decodeURIComponent(url.pathname.slice(rawPrefix.length))}${url.search}${url.hash}`, image);
  }
  if (/^[a-z][a-z0-9+.-]*:/i.test(value)) throw new Error(`${source}: unsupported link scheme: ${value}`);
  const match = /^([^?#]*)(\?[^#]*)?(#.*)?$/.exec(value);
  if (!match) throw new Error(`${source}: invalid content target ${value}`);
  const [, filename, query = "", fragment = ""] = match;
  const decoded = decodeURIComponent(filename).replaceAll("\\", "/");
  let relative = decoded.startsWith("/") ? decoded.replace(/^\/script-samples\/|^\//, "")
    : path.posix.normalize(path.posix.join(path.posix.dirname(source), decoded));
  relative = relative.replace(/^docfx\//, "docs/");
  if (GUIDE_ROUTES[relative] !== undefined) return `${sitePath(GUIDE_ROUTES[relative])}${query}${fragment}`;
  if (relative === "docs/by-product.md" || relative === "docs/by-tool.md") return `${sitePath("")}${query}${fragment}`;
  const actual = canonicalFile(relative);
  const sampleReadme = /^scripts\/([^/]+)\/README\.md$/.exec(actual);
  if (sampleReadme) return `${sitePath(`samples/${encodeURIComponent(sampleReadme[1])}/`)}${query}${fragment}`;
  if (actual.startsWith("docs/assets/")) return `${sitePath(`assets/${encodePath(actual.slice(12))}`)}${query}${fragment}`;
  if (actual.startsWith("scripts/") && !actual.endsWith(".md")) return `${sitePath(encodePath(actual.slice(8)))}${query}${fragment}`;
  if (image) throw new Error(`${source}: image is not in published content: ${actual}`);
  return `${REPOSITORY_URL}/blob/main/${encodePath(actual)}${fragment}`;
}

export function expandIncludes(markdown, source, chain = []) {
  let fence = "";
  const result = [];
  for (const line of markdown.split(/\r?\n/)) {
    const delimiter = /^\s*(`{3,}|~{3,})/.exec(line)?.[1];
    if (delimiter && !fence) fence = delimiter[0];
    else if (delimiter && fence === delimiter[0]) fence = "";
    if (fence || delimiter) { result.push(line); continue; }
    const include = /^\s*\[!INCLUDE\s*\[[^\]]*\]\(([^)]+)\)\]\s*$/i.exec(line);
    if (!include) {
      result.push(line.replace(/^\s*>\s*\[!Video\s+(https:\/\/[^\]]+)\]\s*$/i, "> [Watch this sample's video]($1)"));
      continue;
    }
    const relative = path.posix.normalize(path.posix.join(path.posix.dirname(source), include[1].replaceAll("\\", "/"))).replace(/^docfx\//, "docs/");
    if (!relative.startsWith("docs/includes/")) throw new Error(`${source}: shared include must be under docs/includes: ${include[1]}`);
    if (chain.includes(relative)) throw new Error(`${source}: circular Markdown include ${relative}`);
    const actual = canonicalFile(relative);
    const buffer = fs.readFileSync(path.join(REPOSITORY_ROOT, ...actual.split("/")));
    const text = new TextDecoder(buffer[0] === 255 && buffer[1] === 254 ? "utf-16le" : "utf-8").decode(buffer);
    result.push(expandIncludes(text, actual, [...chain, relative]));
  }
  return result.join("\n");
}

export function renderMarkdown(markdown, source, { removeTitle = true, commandHelp = new Map() } = {}) {
  const withoutTracker = marked.lexer(markdown).map((token) => token.type === "code" ? token.raw : token.raw
    .replace(/<img\b[^>]*m365-visitor-stats[^>]*>/gi, "")
    .replace(/^!\[[^\]]*\]\([^)]*m365-visitor-stats[^)]*\)\s*$/gm, "")).join("");
  const expanded = expandIncludes(withoutTracker, source);
  const tokens = marked.lexer(expanded, { gfm: true });
  if (removeTitle) {
    const first = tokens.findIndex((token) => token.type === "heading" && token.depth === 1);
    if (first >= 0) tokens.splice(first, 1);
  }
  const renderer = new marked.Renderer();
  const defaultTable = renderer.table;
  renderer.table = function (token) {
    return `<div class="table-wrap" tabindex="0" role="region" aria-label="Sample data table">${defaultTable.call(this, token)}</div>`;
  };
  let codeIndex = 0;
  const headingIds = new Map();
  renderer.code = ({ text, lang }) => {
    const requested = (lang?.trim() || "text").toLowerCase().split(/\s+/)[0];
    const language = languageAliases[requested] ?? requested;
    if (!highlighter.getLoadedLanguages().includes(language) && !["text", "plaintext"].includes(language)) {
      throw new Error(`${source}: unsupported code-fence language "${requested}"`);
    }
    const id = `code-${codeIndex++}`;
    const html = highlighter.codeToHtml(text, { lang: language, themes: { light: "github-light", dark: "github-dark-high-contrast" }, defaultColor: false })
      .replace(/(<span\b[^>]*>)([^<]+)(<\/span>)/g, (original, open, value, close) => {
        const url = commandHelp.get(value.toLowerCase());
        return url ? `${open}<a class="command-help" href="${escape(url)}" title="Command documentation">${value}</a>${close}` : original;
      })
      .replace("<pre ", `<pre id="${id}" role="region" tabindex="0" aria-label="${escape(language)} script" `);
    return `<div class="code-frame"><div class="code-toolbar"><span>${escape(language)}</span><button type="button" class="copy-code" data-copy-code="${id}" aria-label="Copy ${escape(language)} code">Copy code</button></div>${html}</div>`;
  };
  renderer.heading = function ({ tokens: inlineTokens, depth }) {
    const text = this.parser.parseInline(inlineTokens);
    const baseId = text.replace(/<[^>]+>/g, "").toLowerCase().replace(/&[^;]+;/g, "").replace(/[^\p{L}\p{N}]+/gu, "-").replace(/^-|-$/g, "") || "section";
    const count = headingIds.get(baseId) ?? 0;
    headingIds.set(baseId, count + 1);
    const level = Math.max(depth, 2);
    return `<h${level} id="${escape(baseId)}${count ? `-${count}` : ""}">${text}</h${level}>`;
  };
  renderer.blockquote = function (token) {
    const alert = /^\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*/i.exec(token.text);
    const div = /^\s*\[!div\b[^\]]*\]\s*/i.exec(token.text);
    if (!alert && !div) return `<blockquote>${this.parser.parse(token.tokens)}</blockquote>`;
    const type = alert?.[1].toLowerCase() ?? "note";
    const content = token.text.replace(/^\s*\[!(?:NOTE|TIP|IMPORTANT|WARNING|CAUTION|div\b[^\]]*)\]\s*/gim, "");
    return `<aside class="callout callout--${type}" aria-label="${type}">${marked.parse(content, { renderer, gfm: true })}</aside>`;
  };
  const options = { renderer, gfm: true };
  const output = [];
  const panes = [];
  let active;
  let groupIndex = 0;
  let scriptTabCount = 0;
  const render = (items) => marked.parser(items, options);
  function flush() {
    if (!panes.length) return;
    const prefix = `tools-${groupIndex++}`;
    const used = new Set();
    for (const pane of panes) {
      if (used.has(pane.id)) throw new Error(`${source}: duplicate tool tab #tab/${pane.id}`);
      used.add(pane.id);
    }
    output.push(`<div class="readme-tabs" data-tabs><div class="tool-tabs" role="tablist" aria-label="Script implementations">${panes.map((pane, index) =>
      `<button type="button" role="tab" id="${prefix}-${escape(pane.id)}" data-tab-id="${escape(pane.id)}" aria-controls="${prefix}-panel-${index}" aria-selected="${index === 0}" tabindex="${index ? -1 : 0}">${escape(pane.title)}</button>`).join("")}</div>${panes.map((pane, index) =>
      `<section role="tabpanel" id="${prefix}-panel-${index}" aria-labelledby="${prefix}-${escape(pane.id)}" tabindex="0"${index ? ' hidden="hidden"' : ""}>${render(pane.tokens)}</section>`).join("")}</div>`);
    scriptTabCount += panes.length;
    panes.length = 0;
    active = undefined;
  }
  let loose = [];
  function flushLoose() { if (loose.length) { output.push(render(loose)); loose = []; } }
  for (const token of tokens) {
    const tab = token.type === "heading" ? /^\[([^\]]+)\]\(#tab\/([^)]+)\)$/.exec(token.text) : undefined;
    if (tab) {
      flushLoose();
      active = { title: tab[1], id: tab[2], tokens: [] };
      panes.push(active);
      continue;
    }
    const sharedHeading = token.type === "heading" && (token.depth === 1 || /^(contributors?|authors?|source credit|references|disclaimer|acknowledg)/i.test(token.text));
    if (active && (token.type === "hr" || sharedHeading)) flush();
    if (active) active.tokens.push(token);
    else loose.push(token);
  }
  flush();
  flushLoose();
  const html = sanitizeHtml(output.join("\n"), {
    allowedTags: [...sanitizeHtml.defaults.allowedTags, "img", "button", "section", "aside", "details", "summary", "kbd", "del"],
    allowedAttributes: {
      "*": ["id", "class", "role", "aria-label", "aria-labelledby", "aria-controls", "aria-selected", "aria-hidden", "tabindex", "hidden"],
      a: ["href", "title", "target", "rel"],
      img: ["src", "alt", "title", "width", "height", "loading", "decoding"],
      button: ["type", "data-copy-code", "data-tab-id"],
      div: ["class", "data-tabs"],
      pre: ["id", "class", "style", "tabindex", "aria-label"],
      span: ["class", "style"],
      code: ["class", "style"]
    },
    allowedStyles: {
      "*": {
        color: [/^#[\da-f]{3,8}$/i, /^var\(--shiki-(light|dark)\)$/],
        "--shiki-light": [/^#[\da-f]{3,8}$/i],
        "--shiki-dark": [/^#[\da-f]{3,8}$/i],
        "--shiki-light-bg": [/^#[\da-f]{3,8}$/i],
        "--shiki-dark-bg": [/^#[\da-f]{3,8}$/i],
        "font-style": [/^italic$/],
        "font-weight": [/^bold$/],
        "text-decoration": [/^underline$/]
      }
    },
    allowedSchemes: ["http", "https", "mailto"],
    transformTags: {
      a: (_tag, attributes) => ({ tagName: "a", attribs: { ...attributes, href: contentTarget(source, attributes.href ?? ""), ...(attributes.target === "_blank" ? { rel: "noopener noreferrer" } : {}) } }),
      img: (_tag, attributes) => ({ tagName: "img", attribs: { ...attributes, src: contentTarget(source, attributes.src ?? "", true), alt: attributes.alt ?? "", loading: "lazy", decoding: "async" } })
    }
  });
  return { html, scriptTabCount, codeBlockCount: codeIndex };
}
