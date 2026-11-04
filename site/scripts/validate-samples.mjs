import { loadSources } from "./source.mjs";

const trackersOnly = process.argv.includes("--trackers");
const records = await loadSources({ trackersOnly });
console.log(`[gallery] validated ${records.length} ${trackersOnly ? "README view trackers" : "sample records, assets, identities, dates, authors, taxonomy, and README trackers"}`);
