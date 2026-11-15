import path from "node:path";
export { BASE_PATH, SITE_ORIGIN, TRACKER_BASE, sitePath, trackerUrl as trackerIdentity } from "../src/lib/routes.ts";

export const SITE_ROOT = path.resolve(import.meta.dirname, "..");
export const REPOSITORY_ROOT = path.resolve(SITE_ROOT, "..");
export const REPOSITORY_URL = "https://github.com/pnp/script-samples";
export const encodePath = (value) => value.split("/").map(encodeURIComponent).join("/");

export const PRODUCTS = [
  { id: "sharepoint", label: "SharePoint", image: "SharePoint_512.png", featured: true, aliases: ["SharePoint", "SharePoint Online", "SharePoint Advanced Management(SAM)"] },
  { id: "graph", label: "Microsoft Graph", image: "graph.svg", featured: true, aliases: ["Graph", "Microsoft Graph"] },
  { id: "teams", label: "Teams", image: "Teams_512.png", featured: true, aliases: ["Teams", "Microsoft Teams"] },
  { id: "power-automate", label: "Power Automate", image: "powerautomate_256x256.png", featured: true, aliases: ["Power Automate"] },
  { id: "power-platform", label: "Power Platform", image: "powerplatform_256x256.png", featured: true, aliases: ["PowerApps", "Power Apps", "Power Platform"] },
  { id: "entra", label: "Microsoft Entra", image: "aad.svg", aliases: ["AzureAD", "Entra ID", "Entra", "Microsoft Entra", "Azure AD"] },
  { id: "azure", label: "Azure", image: "azure.svg", aliases: ["Azure", "Document Intelligence Studio"] },
  { id: "microsoft-365", label: "Microsoft 365", image: "office.svg", aliases: ["Office", "Microsoft 365", "Microsoft 365 Group", "M365 Group", "M365 Groups"] },
  { id: "copilot", label: "Microsoft Copilot", image: "copilot.png", aliases: ["Microsoft Copilot", "Copilot"], searchAliases: ["Microsoft 365 Copilot", "M365 Copilot"] },
  { id: "exchange", label: "Exchange", monogram: "Ex", aliases: ["Exchange", "Exchange Online"] },
  { id: "planner", label: "Planner", monogram: "P", aliases: ["Planner"] },
  { id: "todo", label: "Microsoft To Do", image: "todo.svg", aliases: ["Microsoft Todo", "Microsoft To Do"] },
  { id: "purview", label: "Microsoft Purview", monogram: "Pr", aliases: ["Microsoft Purview", "DLP"] },
  { id: "stream", label: "Stream", monogram: "St", aliases: ["Stream"] },
  { id: "whiteboard", label: "Whiteboard", monogram: "W", aliases: ["Whiteboard"] },
  { id: "openai", label: "OpenAI", monogram: "AI", aliases: ["OpenAI"] },
  { id: "github", label: "GitHub", monogram: "GH", aliases: ["Github", "GitHub"] },
  { id: "search", label: "Microsoft Search", monogram: "S", aliases: ["Microsoft Search"] }
];
export const TOOLS = {
  "PNP-POWERSHELL": "PnP PowerShell",
  "CLI-FOR-MICROSOFT365": "CLI for Microsoft 365",
  "GRAPH-POWERSHELL": "Microsoft Graph PowerShell",
  "SPO-MANAGEMENT-SHELL": "SPO Management Shell",
  POWERSHELL: "PowerShell",
  "AZURE-CLI": "Azure CLI",
  "POWERAPPS-POWERSHELL": "Power Apps PowerShell",
  "MICROSOFTTEAMS-POWERSHELL": "Teams PowerShell",
  MICROSOFTWHITEBOARDADMIN: "Whiteboard Admin",
  JAVASCRIPT: "JavaScript",
  BASH: "Bash",
  GITHUB: "GitHub",
  PYTHON: "Python"
};
export const CATEGORIES = ["Modernize", "Data", "Deploy", "Provision", "Configure", "Report", "Security", "AI", "Microsoft Copilot"];
export const PRODUCT_TOPICS = new Set([
  "Unified Settings", "PnP Modern Search", "Microsoft 365 cli", "Sites", "Channels",
  "Navigation", "Search", "Crawl Log", "Libraries", "Lists", "Sharing Links", "PowerShell",
  "SPFx", "Permissions", "Unique Permissions", "SharePoint Groups", "SharingLinks",
  "Sharing settings", "SiteId", "Termstores", "Branding", "Webhooks", "Security"
]);

export function productIds(values) {
  const ids = new Set();
  for (const value of values) {
    const product = PRODUCTS.find((candidate) => candidate.aliases.some((alias) => alias.toLowerCase() === value.toLowerCase()));
    if (!product) throw new Error(`Unknown product "${value}". Add a deliberate alias to site/scripts/config.mjs or correct the metadata.`);
    ids.add(product.id);
  }
  return [...ids];
}

export const GUIDE_ROUTES = {
  "docs/index.md": "",
  "docs/getting-started.md": "getting-started/",
  "docs/contributing/index.md": "contributing/",
  "docs/contributing/how-can-i-contribute.md": "contributing/how-can-i-contribute/",
  "docs/contributing/preparing-a-submission.md": "contributing/preparing-a-submission/",
  "docs/contributing/submitting-pull-requests.md": "contributing/submitting-pull-requests/",
  "docs/contributing/recognition.md": "contributing/recognition/",
  "docs/contributing/merging-existing-project.md": "contributing/merging-existing-project/",
  "docs/contributing/maintainers-guidance.md": "contributing/maintainers-guidance/"
};
