// Shiki themes and a dual light/dark CSS helper, shared across Voxell
// sites that syntax-highlight code with Shiki. The dark theme was
// originally written for the roadmap markdown renderer (see
// voxell_website's assets/js/syntax.js); the light theme below uses the
// same light-mode hues already defined for the rest of the UI in
// styles.css, darkened just enough to clear 4.5:1 on the light surface,
// rather than switching to an unrelated palette.
export const monokaiPro = {
  name: "monokai-pro",
  type: "dark",
  colors: { "editor.background": "#2d2a2e", "editor.foreground": "#fcfcfa" },
  tokenColors: [
    { scope: ["comment", "punctuation.definition.comment"], settings: { foreground: "#939293", fontStyle: "italic" } },
    { scope: ["string", "string.quoted", "string.template"], settings: { foreground: "#ffd866" } },
    { scope: ["constant.numeric", "constant.language"], settings: { foreground: "#ab9df2" } },
    { scope: ["keyword", "storage.type", "storage.modifier"], settings: { foreground: "#ff6188" } },
    { scope: ["entity.name.function", "support.function"], settings: { foreground: "#a9dc76" } },
    {
      scope: ["entity.name.type", "entity.name.class", "support.class", "entity.other.inherited-class"],
      settings: { foreground: "#78dce8" },
    },
    { scope: ["variable", "variable.other"], settings: { foreground: "#fcfcfa" } },
    { scope: ["keyword.operator", "entity.name.tag"], settings: { foreground: "#ff6188" } },
    { scope: ["support.type", "support.other.namespace"], settings: { foreground: "#78dce8" } },
    { scope: ["constant.other.color", "support.constant"], settings: { foreground: "#ab9df2" } },
    { scope: "invalid", settings: { foreground: "#ff6188", fontStyle: "underline" } },
  ],
};

export const monokaiProLight = {
  name: "monokai-pro-light",
  type: "light",
  colors: { "editor.background": "#f0eeef", "editor.foreground": "#2d2a2e" },
  tokenColors: [
    { scope: ["comment", "punctuation.definition.comment"], settings: { foreground: "#656565", fontStyle: "italic" } },
    { scope: ["string", "string.quoted", "string.template"], settings: { foreground: "#8a6400" } },
    { scope: ["constant.numeric", "constant.language"], settings: { foreground: "#6248c8" } },
    { scope: ["keyword", "storage.type", "storage.modifier"], settings: { foreground: "#c4224f" } },
    { scope: ["entity.name.function", "support.function"], settings: { foreground: "#4a761e" } },
    {
      scope: ["entity.name.type", "entity.name.class", "support.class", "entity.other.inherited-class"],
      settings: { foreground: "#0c7685" },
    },
    { scope: ["variable", "variable.other"], settings: { foreground: "#2d2a2e" } },
    { scope: ["keyword.operator", "entity.name.tag"], settings: { foreground: "#c4224f" } },
    { scope: ["support.type", "support.other.namespace"], settings: { foreground: "#0c7685" } },
    { scope: ["constant.other.color", "support.constant"], settings: { foreground: "#6248c8" } },
    { scope: "invalid", settings: { foreground: "#c4224f", fontStyle: "underline" } },
  ],
};

// Installs the CSS that switches Shiki's dual-theme output between the
// `--shiki-dark`/`--shiki-light` custom properties it emits, keyed on the
// site's `[data-theme]` toggle. Call once. `codeToHtml` still needs
// `themes: { dark: "monokai-pro", light: "github-light" }, defaultColor: false`.
export function installShikiDualTheme() {
  const style = document.createElement("style");
  style.textContent = `
    .shiki { overflow-x: auto; }
    .shiki span { color: var(--shiki-dark); }
    .shiki { background: var(--shiki-dark-bg) !important; }
    [data-theme="light"] .shiki span { color: var(--shiki-light); }
    [data-theme="light"] .shiki { background: var(--shiki-light-bg) !important; }
  `;
  document.head.appendChild(style);
}
