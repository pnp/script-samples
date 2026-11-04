export {};

const root = document.documentElement;
const toggle = document.querySelector<HTMLButtonElement>("#theme-toggle");
const status = document.querySelector<HTMLElement>("#site-status");
const meta = document.querySelector<HTMLMetaElement>("#theme-color");

function applyTheme(theme: "light" | "dark", persist: boolean) {
  root.dataset.theme = theme;
  root.style.colorScheme = theme;
  const dark = theme === "dark";
  if (toggle) {
    toggle.setAttribute("aria-checked", String(dark));
    toggle.setAttribute("aria-label", `Switch to ${dark ? "light" : "dark"} mode`);
    toggle.title = toggle.getAttribute("aria-label") ?? "";
  }
  if (meta) meta.content = dark ? "#0c131b" : "#f2f4f5";
  if (persist) {
    try { localStorage.setItem("community-script-samples-theme", theme); }
    catch (error) {
      console.warn("Theme changed but the preference could not be saved.", error);
      if (status) status.textContent = "Theme changed. This browser could not save your preference.";
    }
  }
}
applyTheme(root.dataset.theme === "dark" ? "dark" : "light", false);
toggle?.addEventListener("click", () => applyTheme(root.dataset.theme === "dark" ? "light" : "dark", true));

document.querySelectorAll<HTMLImageElement>("[data-avatar]").forEach((image) => {
  image.addEventListener("error", () => {
    const name = image.dataset.avatar ?? "Contributor";
    const fallback = document.createElement("span");
    fallback.className = "avatar avatar-fallback";
    fallback.style.width = `${image.width}px`;
    fallback.style.height = `${image.height}px`;
    fallback.textContent = name.split(/\s+/).slice(0, 2).map((part) => part[0]).join("");
    fallback.setAttribute("aria-label", `Profile image unavailable for ${name}`);
    console.warn(`GitHub profile image unavailable for ${name}`);
    image.replaceWith(fallback);
  }, { once: true });
});

document.querySelectorAll<HTMLElement>("[data-tabs]").forEach((group) => {
  const buttons = [...group.querySelectorAll<HTMLButtonElement>('[role="tab"]')];
  const panels = [...group.querySelectorAll<HTMLElement>('[role="tabpanel"]')];
  function activate(index: number, focus = false, updateHash = false) {
    buttons.forEach((button, current) => {
      const selected = index === current;
      button.setAttribute("aria-selected", String(selected));
      button.tabIndex = selected ? 0 : -1;
      if (selected && focus) button.focus();
    });
    panels.forEach((panel, current) => { panel.hidden = index !== current; });
    if (updateHash) {
      const url = new URL(location.href);
      url.hash = `tab/${buttons[index].dataset.tabId}`;
      history.replaceState(null, "", url);
    }
  }
  buttons.forEach((button, index) => {
    button.addEventListener("click", () => activate(index, false, true));
    button.addEventListener("keydown", (event) => {
      let next: number | undefined;
      if (event.key === "ArrowRight") next = (index + 1) % buttons.length;
      if (event.key === "ArrowLeft") next = (index - 1 + buttons.length) % buttons.length;
      if (event.key === "Home") next = 0;
      if (event.key === "End") next = buttons.length - 1;
      if (next !== undefined) { event.preventDefault(); activate(next, true, true); }
    });
  });
  function activateHash() {
    const requested = location.hash.replace(/^#(?:tab\/)?/, "");
    const index = buttons.findIndex((button) => button.dataset.tabId === requested);
    if (index >= 0) activate(index);
  }
  activateHash();
  window.addEventListener("hashchange", activateHash);
});

document.querySelectorAll<HTMLButtonElement>("[data-copy-code]").forEach((button) => {
  button.addEventListener("click", async () => {
    const pre = document.getElementById(button.dataset.copyCode ?? "");
    const code = pre?.querySelector("code");
    if (!code) throw new Error(`Copy target is missing: ${button.dataset.copyCode}`);
    try {
      await navigator.clipboard.writeText(code.textContent ?? "");
      button.textContent = "Copied";
      if (status) status.textContent = "Complete code block copied to the clipboard.";
    } catch (error) {
      console.error("Could not copy the code block.", error);
      const range = document.createRange();
      range.selectNodeContents(code);
      const selection = window.getSelection();
      selection?.removeAllRanges();
      selection?.addRange(range);
      pre?.focus();
      button.textContent = "Code selected";
      if (status) status.textContent = "Clipboard unavailable. The code is selected; use your browser's copy command.";
    }
  });
});

const tracker = document.querySelector<HTMLImageElement>("[data-visitor-stats]");
if (tracker?.dataset.trackingEnabled === "true" && location.hostname === "pnp.github.io" && location.pathname.startsWith("/script-samples/")) {
  const source = tracker.dataset.trackerSrc;
  if (!source) throw new Error("Page view tracker identity is missing.");
  tracker.src = source;
}

document.querySelectorAll<HTMLDetailsElement>(".mobile-nav").forEach((menu) => {
  menu.querySelectorAll("a").forEach((link) => link.addEventListener("click", () => { menu.open = false; }));
});
