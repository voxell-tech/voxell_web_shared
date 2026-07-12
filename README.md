# Voxell Web Shared

Shared chrome for Voxell's [Tola](https://github.com/) sites — the top nav, the
site footer, the canonical link list, the brand/social icon set, and the
social-icon CSS. Embedded in each site as a git submodule at `shared/` so a
change lands everywhere with a single submodule bump.

## Contents

| Path | What |
|------|------|
| `links.typ` | Canonical URLs (`links.github`, `links.discord`, …). Single source of truth. |
| `components/nav.typ` | `nav(links: (...))` — parameterized top nav with theme toggle + active states. |
| `components/footer.typ` | `footer()` — sectioned footer (Community / Support / Contact). |
| `components/social.typ` | `footer-social(href, icon, label)` helper. |
| `icons/` | Shared SVGs (voxell, sun, moon, github, discord, youtube, linkedin, reddit, opencollective, mail). |
| `styles.css` | `.social-icon` mask-tint rules. |

## Using it in a site

1. Add the submodule:
   ```sh
   git submodule add git@github.com:voxell-tech/voxell_web_shared.git shared
   ```
2. `tola.toml`:
   ```toml
   [build]
   deps = ["templates", "utils", "components", "shared"]
   [build.assets]
   nested = ["assets/icons", "assets/styles", "assets/fonts", "assets/js", "shared/icons"]
   ```
   `shared/icons` is served at `/icons` (the top path component is stripped), so
   references stay `/icons/<name>.svg`.
3. `assets/styles/tailwind.css`:
   ```css
   @source "../../shared";           /* let Tailwind scan the submodule's .typ */
   @import "../../shared/styles.css"; /* social-icon rules */
   ```
4. In `templates/base.typ`:
   ```typ
   #import "/shared/components/nav.typ": nav
   #import "/shared/components/footer.typ": footer
   #import "/shared/links.typ": links
   ```
   Call `nav(links: (...))` and `footer()` in the layout.

## Requirements

- Each site must define `--color-muted`, `--color-accent`, `--color-subtle`,
  `--color-text` in its `@theme`, and the `.icon-sun` / `.icon-moon` theme-toggle
  visibility rules + `theme.js`.

## Updating

Edit here, commit & push, then in each site: `git submodule update --remote shared`
and commit the new pointer.
