export const BASE_PATH = "/script-samples";
export const SITE_ORIGIN = "https://pnp.github.io";
export const TRACKER_BASE = "https://m365-visitor-stats.azurewebsites.net/script-samples";
export const sitePath = (value = ""): string => `${BASE_PATH}/${value.replace(/^\/+/, "")}`;
export function trackerUrl(route: string): string {
  const clean = route.replace(/^\/+|\/+$/g, "");
  if (!clean) return TRACKER_BASE;
  if (clean.startsWith("samples/")) return `${TRACKER_BASE}/scripts/${clean.slice("samples/".length)}`;
  if (clean === "contributing/how-can-i-contribute") return `${TRACKER_BASE}/how-can-i-contribute`;
  return `${TRACKER_BASE}/${clean}`;
}
