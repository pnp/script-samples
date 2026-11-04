import { createReadStream } from "node:fs";
import { stat } from "node:fs/promises";
import { createServer } from "node:http";
import path from "node:path";
import { BASE_PATH, SITE_ROOT } from "./config.mjs";

const dist = path.join(SITE_ROOT, "dist");
const types = new Map([
  [".html", "text/html; charset=utf-8"], [".css", "text/css"], [".js", "text/javascript"],
  [".json", "application/json"], [".png", "image/png"], [".jpg", "image/jpeg"],
  [".jpeg", "image/jpeg"], [".gif", "image/gif"], [".webp", "image/webp"],
  [".svg", "image/svg+xml"], [".woff2", "font/woff2"], [".xml", "application/xml"],
  [".txt", "text/plain"], [".md", "text/plain"], [".ps1", "text/plain"]
]);
const server = createServer(async (request, response) => {
  try {
    const url = new URL(request.url ?? "/", "http://127.0.0.1");
    const pathname = decodeURIComponent(url.pathname);
    if (pathname !== BASE_PATH && !pathname.startsWith(`${BASE_PATH}/`)) { response.writeHead(404).end("Not found"); return; }
    const file = path.resolve(dist, pathname.slice(BASE_PATH.length).replace(/^\//, "") || "index.html");
    if (!file.startsWith(`${dist}${path.sep}`)) { response.writeHead(400).end("Invalid path"); return; }
    let target = file;
    let status = 200;
    try {
      const details = await stat(target);
      if (details.isDirectory()) {
        if (!pathname.endsWith("/")) { response.writeHead(301, { Location: `${pathname}/${url.search}` }).end(); return; }
        target = path.join(target, "index.html");
      }
      await stat(target);
    } catch (error) {
      if (error.code !== "ENOENT") throw error;
      target = path.join(dist, "404.html");
      status = 404;
    }
    response.writeHead(status, { "Content-Type": types.get(path.extname(target).toLowerCase()) ?? "application/octet-stream" });
    const stream = createReadStream(target);
    stream.on("error", (error) => { console.error(error); response.destroy(error); });
    stream.pipe(response);
  } catch (error) {
    console.error("Test server request failed:", error);
    response.writeHead(500).end("Request failed");
  }
});
server.listen(4327, "127.0.0.1", () => console.log(`Gallery ready: http://127.0.0.1:4327${BASE_PATH}/`));
for (const signal of ["SIGINT", "SIGTERM"]) process.on(signal, () => server.close());
