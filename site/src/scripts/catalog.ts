export {};

type FilterKey = "q" | "product" | "tool" | "category" | "author";
type Sort = "updated" | "newest" | "name";
type Layout = "grid" | "list";
interface State { q: string; product: string; tool: string; category: string; author: string; sort: Sort; layout: Layout; limit: number }
interface Card { element: HTMLElement; slug: string; search: string; products: string[]; tools: string[]; categories: string[]; authors: string[]; title: string; updated: string; created: string }
function required<T extends Element>(selector: string): T {
  const element = document.querySelector<T>(selector);
  if (!element) throw new Error(`Catalog control is missing: ${selector}`);
  return element;
}
function data(element: HTMLElement, key: string): string {
  const value = element.dataset[key];
  if (value === undefined) throw new Error(`Catalog card is missing data-${key}`);
  return value;
}
const cards: Card[] = [...document.querySelectorAll<HTMLElement>("[data-sample-card]")].map((element) => ({
  element, slug: data(element, "slug"), search: data(element, "search"),
  products: data(element, "products").split("|"), tools: data(element, "tools").split("|"),
  categories: data(element, "categories").split("|"), authors: data(element, "authors").split("|"),
  title: data(element, "title"), updated: data(element, "updated"), created: data(element, "created")
}));
const grid = required<HTMLElement>("#sample-grid");
const form = required<HTMLFormElement>("#catalog-filters");
const search = required<HTMLInputElement>("#sample-search");
const tool = required<HTMLSelectElement>("#tool-filter");
const category = required<HTMLSelectElement>("#category-filter");
const author = required<HTMLSelectElement>("#author-filter");
const sort = required<HTMLSelectElement>("#sort-samples");
const count = required<HTMLElement>("#result-count");
const empty = required<HTMLElement>("#empty-state");
const loadMore = required<HTMLButtonElement>("#load-more");
const productGroup = required<HTMLElement>("#product-filters");
const more = required<HTMLDetailsElement>(".more-products");
const advanced = required<HTMLDetailsElement>("#advanced-filters");
const active = required<HTMLElement>("#active-filters");
const notice = required<HTMLElement>("#filter-notice");
const productButtons = [...productGroup.querySelectorAll<HTMLButtonElement>("[data-product]")];
const productNames = new Map(productButtons.map((button) => [data(button, "product"), data(button, "productLabel")]));
const state: State = { q: "", product: "", tool: "", category: "", author: "", sort: "updated", layout: "grid", limit: 12 };
const contextKey = "community-script-samples-gallery";
const media = matchMedia("(max-width: 700px)");
advanced.open = !media.matches;
media.addEventListener("change", () => { advanced.open = !media.matches; });

function selected(select: HTMLSelectElement, value: string): boolean {
  return [...select.options].some((option) => option.value === value);
}
function readQuery() {
  const query = new URLSearchParams(location.search);
  const invalid: string[] = [];
  state.q = query.get("q") ?? query.get("query") ?? "";
  const requestedProduct = query.get("product") ?? "";
  state.product = productNames.has(requestedProduct) ? requestedProduct : "";
  if (requestedProduct && !state.product) invalid.push("product");
  for (const [key, select] of [["tool", tool], ["category", category], ["author", author]] as const) {
    const requested = query.get(key) ?? "";
    state[key] = selected(select, requested) ? requested : "";
    if (requested && !state[key]) invalid.push(key);
  }
  const requestedSort = query.get("sort");
  state.sort = requestedSort === "newest" || requestedSort === "name" ? requestedSort : "updated";
  const requestedLayout = query.get("layout");
  state.layout = requestedLayout === "list" ? "list" : "grid";
  const requestedLimit = Number(query.get("limit") ?? 12);
  state.limit = Number.isInteger(requestedLimit) && requestedLimit >= 12 ? Math.min(requestedLimit, cards.length) : 12;
  notice.hidden = !invalid.length;
  notice.textContent = invalid.length ? `Some shared filters were not recognized (${invalid.join(", ")}). Those filters were cleared.` : "";
  if (state.tool || state.category || state.author || query.get("browse") === "tools") advanced.open = true;
}
function updateUrl() {
  const query = new URLSearchParams();
  for (const key of ["q", "product", "tool", "category", "author"] as const) if (state[key]) query.set(key, state[key]);
  if (state.sort !== "updated") query.set("sort", state.sort);
  if (state.layout !== "grid") query.set("layout", state.layout);
  if (state.limit > 12) query.set("limit", String(state.limit));
  history.replaceState(null, "", `${location.pathname}${query.size ? `?${query}` : ""}${location.hash}`);
}
function baseMatch(card: Card): boolean {
  return state.q.trim().toLowerCase().split(/\s+/).filter(Boolean).every((term) => card.search.includes(term)) &&
    (!state.tool || card.tools.includes(state.tool)) &&
    (!state.category || card.categories.includes(state.category)) &&
    (!state.author || card.authors.includes(state.author));
}
function chip(key: FilterKey, label: string) {
  const button = document.createElement("button");
  button.type = "button";
  button.className = "filter-chip";
  button.textContent = `${label} \u00d7`;
  button.setAttribute("aria-label", `Remove filter: ${label}`);
  button.addEventListener("click", () => { state[key] = ""; apply(true); search.focus(); });
  return button;
}
function apply(reset = false) {
  if (reset) state.limit = 12;
  const baseMatches = cards.filter(baseMatch);
  const matches = baseMatches.filter((card) => !state.product || card.products.includes(state.product));
  matches.sort((a, b) => state.sort === "name" ? a.title.localeCompare(b.title)
    : (state.sort === "newest" ? b.created.localeCompare(a.created) : b.updated.localeCompare(a.updated)) || a.title.localeCompare(b.title));
  cards.forEach((card) => { card.element.hidden = true; });
  matches.forEach((card, index) => { card.element.hidden = index >= state.limit; grid.append(card.element); });
  grid.classList.toggle("is-list", state.layout === "list");
  grid.dataset.ready = "true";
  search.value = state.q;
  tool.value = state.tool;
  category.value = state.category;
  author.value = state.author;
  sort.value = state.sort;
  count.textContent = matches.length === cards.length ? `Explore all ${cards.length} community samples` : `${matches.length} matching ${matches.length === 1 ? "sample" : "samples"} of ${cards.length}`;
  empty.hidden = matches.length > 0;
  loadMore.hidden = matches.length <= state.limit;
  required<HTMLElement>("#page-count").textContent = matches.length ? `Showing ${Math.min(state.limit, matches.length)} of ${matches.length} samples` : "";
  productButtons.forEach((button) => {
    const id = button.dataset.product ?? "";
    button.setAttribute("aria-pressed", String(id === state.product));
    const total = id ? baseMatches.filter((card) => card.products.includes(id)).length : baseMatches.length;
    const label = productNames.get(id) || "All samples";
    button.setAttribute("aria-label", `${label}: ${total} matching samples`);
    const span = button.querySelector<HTMLElement>("[data-product-count]");
    if (span) span.textContent = button.classList.contains("product-button") ? `${total} ${id ? "samples" : "scripts to explore"}` : String(total);
  });
  const featured = productButtons.some((button) => button.parentElement === productGroup && button.dataset.product === state.product);
  required<HTMLElement>("#more-product-label").textContent = state.product && !featured ? productNames.get(state.product) ?? "More products" : "More products";
  document.querySelectorAll<HTMLButtonElement>("[data-layout]").forEach((button) => button.setAttribute("aria-pressed", String(button.dataset.layout === state.layout)));
  active.replaceChildren();
  const labels: [FilterKey, string][] = [
    ["q", state.q ? `"${state.q}"` : ""], ["product", productNames.get(state.product) ?? ""],
    ["tool", state.tool ? tool.selectedOptions[0].textContent?.replace(/\s+\(\d+\)$/, "") ?? state.tool : ""],
    ["category", state.category], ["author", state.author ? author.selectedOptions[0].textContent ?? state.author : ""]
  ];
  for (const [key, label] of labels) if (state[key] && label) active.append(chip(key, label));
  const advancedCount = [state.tool, state.category, state.author].filter(Boolean).length;
  required<HTMLElement>("#advanced-filter-label").textContent = advancedCount ? `More filters (${advancedCount})` : "More filters";
  updateUrl();
}
form.addEventListener("submit", (event) => event.preventDefault());
search.addEventListener("input", () => { state.q = search.value; apply(true); });
tool.addEventListener("change", () => { state.tool = tool.value; apply(true); });
category.addEventListener("change", () => { state.category = category.value; apply(true); });
author.addEventListener("change", () => { state.author = author.value; apply(true); });
sort.addEventListener("change", () => { state.sort = sort.value === "newest" || sort.value === "name" ? sort.value : "updated"; apply(); });
productButtons.forEach((button) => button.addEventListener("click", () => { state.product = button.dataset.product ?? ""; more.open = false; apply(true); }));
document.querySelectorAll<HTMLButtonElement>("[data-layout]").forEach((button) => button.addEventListener("click", () => { state.layout = button.dataset.layout === "list" ? "list" : "grid"; apply(); }));
function clear() {
  Object.assign(state, { q: "", product: "", tool: "", category: "", author: "", sort: "updated", limit: 12 });
  notice.hidden = true;
  apply();
  search.focus();
}
required<HTMLButtonElement>("#clear-filters").addEventListener("click", clear);
required<HTMLButtonElement>("#empty-clear").addEventListener("click", clear);
loadMore.addEventListener("click", () => {
  const visible = cards.filter((card) => !card.element.hidden).length;
  state.limit += 12;
  apply();
  [...grid.querySelectorAll<HTMLElement>("[data-sample-card]")].filter((card) => !card.hidden)[visible]?.querySelector<HTMLAnchorElement>("h3 a")?.focus({ preventScroll: true });
});
document.addEventListener("keydown", (event) => {
  if (event.key === "/" && !event.ctrlKey && !event.metaKey && !event.altKey && !(document.activeElement instanceof HTMLInputElement) && !(document.activeElement instanceof HTMLTextAreaElement) && !(document.activeElement instanceof HTMLSelectElement)) {
    event.preventDefault(); search.focus();
  }
});
function saveContext() {
  try { sessionStorage.setItem(contextKey, JSON.stringify({ url: location.href, scroll: scrollY })); }
  catch (error) { console.warn("The gallery scroll position could not be saved.", error); }
}
function restoreContext() {
  try {
    const stored = sessionStorage.getItem(contextKey);
    if (!stored) return;
    const parsed: unknown = JSON.parse(stored);
    if (typeof parsed === "object" && parsed !== null && "url" in parsed && parsed.url === location.href && "scroll" in parsed && typeof parsed.scroll === "number") {
      const position = parsed.scroll;
      requestAnimationFrame(() => { window.scrollTo({ top: position, behavior: "instant" }); });
    }
  } catch (error) { console.warn("The saved gallery context could not be restored.", error); }
}
history.scrollRestoration = "manual";
grid.addEventListener("click", (event) => { if (event.target instanceof Element && event.target.closest("a")) saveContext(); });
window.addEventListener("pagehide", saveContext);
window.addEventListener("pageshow", (event) => { if (event.persisted) restoreContext(); });
window.addEventListener("popstate", () => { readQuery(); apply(); restoreContext(); });
readQuery();
apply();
restoreContext();
