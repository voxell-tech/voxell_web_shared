# Voxell Web Shared

Shared chrome for Voxell's [Tola](https://github.com/) sites: the top nav, the
site footer, the canonical link list, the brand/social icon set, and the
social-icon CSS. Embedded in each site as a git submodule at `shared/` so a
change lands everywhere with a single submodule bump.

## Contents

| Path | What |
|------|------|
| `links.typ` | Canonical URLs (`links.github`, `links.discord`, …). Single source of truth. |
| `components/nav.typ` | `nav(links: (...))`: parameterized top nav with theme toggle + active states. |
| `components/footer.typ` | `footer()`: sectioned footer (Community / Support / Contact). |
| `components/social.typ` | `footer-social(href, icon, label)` helper. |
| `icons/` | Shared SVGs (voxell, sun, moon, github, discord, youtube, linkedin, reddit, opencollective, mail). |
| `styles.css` | `.social-icon` mask-tint rules. |
| `site/` | Project site kit: landing page + docs for a Voxell project (Tola 0.8). See below. |
| `scripts/` | `theme.js`, plus the kit's `docs-nav.js`, `newsletter.js`, `newsletter-popup.js` and `demo-bootstrap.js`. |

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

## Project site kit

`site/` builds a whole project site (MotionGfx's, Fynix's): routing,
the page shell, SEO tags, the docs sidebar, and landing page pieces.
A site keeps only what is its own.

```
site.typ           #build(project)
project.typ        the project record, below
content/           index.typ, docs/**, 404.typ
assets/            styles/tailwind.css, images, favicon, robots.txt
tola.toml          [site] title, description and origin
```

`site.typ`:

```typ
#import "/shared/site/build.typ": build
#import "/project.typ": project
#build(project)
```

`project.typ`:

```typ
#let project = (
  repo: "https://github.com/voxell-tech/<project>",
  license: "MIT OR Apache-2.0", // SPDX, for schema.org.
  donate: "https://opencollective.com/voxell/projects/<project>",
  og-image: "/images/og.png?v=1",
  // The docs sidebar, in reading order.
  chapters: (
    (title: "Start", items: ((title: "Overview", href: "/docs/"),)),
  ),
  scripts: (), // Extra module scripts on every page.
)
```

`donate` falls back to `links.opencollective`, and `scripts` to none.
An optional `head` is content added to every page's `<head>`, such as
an import map.
`build(project, views: (name: view))` adds layouts beyond `"page"`
and `"docs"`; a view is `(project, page, body) => content`.

Pages pick a layout with `tola-meta((layout: "docs"))`. The landing
page uses `site/ui.typ`: `hero`, `button`, `github-button`, `pill`,
`feature`, `feature-button`, `section-heading`, `cta`, `code-panel`,
`backend-diagram`, `showcase-demo`, `rust-snippet`, `card`, `grid`,
`hr`, and `newsletter`/`newsletter-popup` (they take the Kit form ID;
the popup opens at the element marked `data-newsletter-trigger`).

`assets/styles/tailwind.css` imports the kit's CSS after the shared
styles:

```css
@import 'tailwindcss';
@source "../../shared";
@import "../../shared/styles.css";
@import "../../shared/site/site.css";
```

and `tola.toml` serves `shared/icons` at `/icons` and `shared/scripts`
at `/scripts`. A site changes its accent by redeclaring
`--color-accent` after the imports.

## Requirements

- Each site must define `--color-muted`, `--color-accent`, `--color-subtle`,
  `--color-text` in its `@theme`, and the `.icon-sun` / `.icon-moon` theme-toggle
  visibility rules + `theme.js`.

## Updating

Edit here, commit & push, then in each site: `git submodule update --remote shared`
and commit the new pointer.
