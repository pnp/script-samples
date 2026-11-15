import test from "node:test";
import assert from "node:assert/strict";
import { expandIncludes, renderMarkdown, contentTarget } from "../scripts/markdown.mjs";
import { readText } from "../scripts/source.mjs";
import { REPOSITORY_ROOT } from "../scripts/config.mjs";
import path from "node:path";

test("renders complete implementations rather than clipped preview excerpts", () => {
  const lines = Array.from({ length: 160 }, (_, index) => `Write-Output "Line ${index}"`).join("\n");
  const { html, codeBlockCount } = renderMarkdown(`# Example\n\n\`\`\`powershell\n${lines}\n\`\`\``, "README.md");
  assert.equal(codeBlockCount, 1);
  assert.match(html, /Line 159/);
  assert.equal((html.match(/data-copy-code=/g) ?? []).length, 1);
  assert.match(html, /tabindex="0"/);
});
test("turns DocFX tool headings into accessible keyboard-ready tabs", () => {
  const { html, scriptTabCount } = renderMarkdown("# Example\n\n# [PowerShell](#tab/ps)\n\n```powershell\nGet-Date\n```\n\n# [Bash](#tab/sh)\n\n```bash\necho hello\n```\n\n***\n\n## Contributors\n\nA person", "README.md");
  assert.equal(scriptTabCount, 2);
  assert.equal((html.match(/role="tab"/g) ?? []).length, 2);
  assert.equal((html.match(/role="tabpanel"/g) ?? []).length, 2);
  assert.match(html, /aria-selected="true"/);
  assert.match(html, /aria-controls="tools-0-panel-1"/);
  assert.match(html, /hidden="hidden"/);
  assert.ok(html.indexOf("Contributors") > html.lastIndexOf('role="tabpanel"'));
});
test("keeps literal tracker examples inside code while removing actual tracker images", () => {
  const image = '<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/example" />';
  const { html } = renderMarkdown(`# Example\n\n\`\`\`html\n${image}\n\`\`\`\n\n${image}`, "README.md");
  assert.match(html, /m365-visitor-stats/);
  assert.ok(!/<img\b[^>]*m365-visitor-stats/.test(html));
});
test("expands shared guidance, preserves example includes inside code, and strips duplicate trackers", () => {
  const markdown = "# Sample\n\n[!INCLUDE [Disclaimer](../../docs/includes/DISCLAIMER.md)]\n\n```markdown\n[!INCLUDE [Example](../../docs/includes/DOES-NOT-EXIST.md)]\n```\n\n<img src=\"https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/example\" />";
  const { html } = renderMarkdown(markdown, "scripts/example/README.md");
  assert.match(html, /WITHOUT WARRANTY/);
  assert.ok(!html.includes("m365-visitor-stats"));
  assert.match(html, /DOES-NOT-EXIST/);
  assert.throws(() => expandIncludes("[!INCLUDE [Bad](../../README.md)]", "scripts/example/README.md"), /shared include/);
});
test("renders warnings and sanitized HTML without changing code samples", () => {
  const { html } = renderMarkdown('# Sample\n\n> [!WARNING]\n> This removes data.\n\n<script>window.bad = true</script><img src="https://example.com/image.png" onerror="bad()">\n\n```html\n<script>example()</script>\n```', "README.md");
  assert.match(html, /callout--warning/);
  assert.match(html, /This removes data/);
  assert.ok(!html.includes("<script>"));
  assert.ok(!html.includes('onerror="'));
  assert.match(html, /example/);
});
test("resolves legacy content, documentation, assets, and safe external links", () => {
  assert.equal(contentTarget("scripts/aad-add-app-permission/README.md", "assets/example.png", true), "/script-samples/aad-add-app-permission/assets/example.png");
  assert.equal(contentTarget("scripts/aad-add-app-permission/README.md", "../../docs/contributing/index.md"), "/script-samples/contributing/");
  assert.equal(contentTarget("README.md", "https://pnp.github.io/script-samples/aad-add-app-permission/README.html"), "/script-samples/samples/aad-add-app-permission/");
  assert.throws(() => contentTarget("README.md", "../../../outside.txt"), /escapes/);
  assert.throws(() => contentTarget("README.md", "javascript:alert(1)"), /unsupported link scheme/);
});
test("the representative multi-tool sample renders its complete Graph and CLI code", async () => {
  const readme = await readText(path.join(REPOSITORY_ROOT, "scripts", "aad-add-app-permission", "README.md"));
  const { html, scriptTabCount, codeBlockCount } = renderMarkdown(readme, "scripts/aad-add-app-permission/README.md");
  assert.equal(scriptTabCount, 2);
  assert.equal(codeBlockCount, 2);
  assert.match(html, /requiredResourceAccess/);
  assert.match(html, /Invoke-MgGraphRequest/);
  assert.ok(!html.includes("[!INCLUDE"));
});
