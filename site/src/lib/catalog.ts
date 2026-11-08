import catalogData from "../generated/catalog.json";
import type { Catalog } from "./types";
import { BASE_PATH } from "./routes";
export { sitePath, trackerUrl } from "./routes";
import { sitePath } from "./routes";

export const catalog: Catalog = catalogData;
export const basePath = BASE_PATH;
export const samplePath = (slug: string): string => sitePath(`samples/${encodeURIComponent(slug)}/`);
export const formatDate = (value: string): string => new Intl.DateTimeFormat("en-US", {
  year: "numeric", month: "short", day: "numeric", timeZone: "UTC"
}).format(new Date(`${value}T00:00:00Z`));
export const productById = new Map(catalog.products.map((product) => [product.id, product]));
export const requireProduct = (id: string) => {
  const product = productById.get(id);
  if (!product) throw new Error(`Unknown catalog product: ${id}`);
  return product;
};
