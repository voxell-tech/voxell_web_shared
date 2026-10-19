// The page shell every project site shares: <head>, the nav, the
// footer, the show rules prose is styled with, and the scripts.
// Import: #import "/shared/site/layout.typ": emit

#import "@tola/address:0.0.0": url-of-asset
#import "@tola/site:0.0.0": site
#import "../components/footer.typ": footer
#import "../components/nav.typ": nav
#import "../links.typ": links
#import "seo.typ": seo-head
#import "utils.typ": cls
#import "views.typ": colors

// `current`: the route of the page being rendered (e.g. "/docs/bevy/"),
// which the nav uses to mark its active link.
#let base(project, current, body) = {
  show list: it => html.ul(class: "list-disc ml-6 my-4 space-y-1")[
    #for item in it.children { html.li[#item.body] }
  ]
  show enum: it => html.ol(class: "list-decimal ml-6 my-4 space-y-1")[
    #for item in it.children { html.li[#item.body] }
  ]

  show raw.where(block: false): it => html.code(class: cls(
    "font-semibold",
    colors.code,
  ))[#it.text]

  // Code blocks are highlighted at build time with Monokai Pro, so the
  // colors are in the HTML from the first paint (no client-side
  // highlighter to wait on). Light mode remaps the colors in CSS; see
  // the "Syntax highlighting" block in site.css.
  set raw(theme: "monokai-pro.tmTheme")

  // The block's own background comes from shared/styles.css's `pre`;
  // this wrapper is just for margin and the border.
  show raw.where(block: true): it => html.div(
    class: "my-2 border border-text/10 rounded-lg",
  )[#it]

  show quote: it => html.blockquote(class: cls(
    "border-l-4 border-accent pl-4 my-4 italic",
    colors.muted,
  ))[#it.body]
  show link: it => {
    let href = repr(it.dest).replace("\"", "")
    let external = href.starts-with("http")
    html.a(
      class: cls("underline underline-offset-4", "hover:" + colors.accent),
      href: href,
      ..if external { (target: "_blank", rel: ("noopener", "noreferrer")) },
    )[#it.body]
  }

  // Both badges match the page's own dark-mode bg (#19181a) instead of
  // shields.io's default color, so they blend into the nav instead of
  // showing a boxed background: shields.io has no true transparent
  // option (`color=transparent` and an 8-digit alpha hex both just fall
  // back to their default green), and it won't match in light mode
  // since there's no way to make a static badge image react to the
  // theme toggle. `flat-square` over `for-the-badge`: the latter bakes
  // generous internal padding into the SVG itself as part of its look,
  // which can't be stripped via CSS on an opaque <img>. `repo` is
  // `owner/name`.
  let github-badge(repo) = html.elem("img", attrs: (
    src: "https://img.shields.io/github/stars/"
      + repo
      + "?style=flat-square&logo=github&logoColor=white&label=&color=19181a",
    height: "20",
    alt: "GitHub stars",
    style: "display: inline-block; vertical-align: middle;",
  ))

  let discord-badge = html.elem("img", attrs: (
    src: "https://img.shields.io/discord/442334985471655946?style=flat-square&logo=discord&logoColor=white&label=&color=19181a",
    height: "20",
    alt: "Discord online",
    style: "display: inline-block; vertical-align: middle;",
  ))

  // A call to action rather than a stat like the two badges above, so it
  // gets its own pill instead of shields.io styling, with a text label
  // since there's no universally recognized "donate" glyph.
  let donate-button = html.span(
    class: "px-2.5 py-1 rounded-md border-2 border-red/40 bg-red text-white text-sm font-medium hover:opacity-90 transition-opacity",
  )[♥ Donate]

  // Mask-tinted icon, same technique the shared footer's social links use
  // (see components/social.typ and .social-icon in styles.css):
  // it recolors via `background-color` instead of baking in a fixed
  // color, so it inherits hover/theme changes the way text links do.
  let nav-icon(icon, label) = html.elem("span", attrs: (
    class: "social-icon",
    style: "--icon: url('/icons/" + icon + "')",
  ))[#html.span(class: "sr-only")[#label]]

  // The pieces above, for a site's own `nav` to reuse.
  let parts = (
    github-badge: github-badge,
    discord-badge: discord-badge,
    donate-button: donate-button,
    nav-icon: nav-icon,
  )

  // A project site's nav. A site that isn't a single project
  // (voxell.dev) passes `nav: parts => (..)` instead, and a `brand`;
  // `brand: none` is the Voxell logo.
  let project-links(project) = (
    (label: [Docs], href: "/docs/", match: "/docs"),
    (
      label: github-badge(
        project.repo.trim("https://github.com/", at: start),
      ),
      href: project.repo,
      external: true,
    ),
    (label: discord-badge, href: links.discord, external: true),
    // A project's own OpenCollective project when it has one, so
    // donations go to it rather than to Voxell as a whole.
    (
      label: donate-button,
      href: project.at("donate", default: links.opencollective),
      external: true,
    ),
    (
      label: nav-icon("voxell.svg", "Voxell"),
      href: links.website,
      external: true,
    ),
  )
  nav(
    brand: project.at(
      "brand",
      default: html.span(class: "font-semibold text-text")[Home],
    ),
    gap: "gap-3",
    current: current,
    links: if "nav" in project { (project.nav)(parts) } else {
      project-links(project)
    },
  )

  // Every page (docs and home alike) gets the same wide container; each
  // page's own content narrows individual reading columns where it
  // wants to (the docs view's prose column, the landing page's hero/
  // prose sections), rather than the page shell doing it for them.
  // `main-class` lets a site with full-bleed sections (a hero that
  // spans the window) drop the container and pad its own sections.
  html.main(
    class: project.at("main-class", default: "max-w-7xl mx-auto px-4 py-8"),
  )[#body]

  footer()

  for src in (
    "/scripts/demo-bootstrap.js",
    "/scripts/docs-nav.js",
    "/scripts/newsletter.js",
    "/scripts/newsletter-popup.js",
    ..project.at("scripts", default: ()),
  ) {
    html.elem("script", attrs: (type: "module", src: src))[]
  }
}

/// Write one page to its output file as a complete HTML document.
///
/// - project: the site's project.typ record.
/// - page: one `(source:, output:, route:)` record from build.typ.
/// - view: the page's view, `(project, page, body) => content`, such as
///   views.typ's `page-view`.
#let emit(project, page, view) = document(page.output, format: "html")[
  #html.html(lang: site.language.tag)[
    #html.head[
      #html.meta(charset: "utf-8")
      #html.link(
        rel: "icon",
        href: url-of-asset("/favicon.ico"),
        type: "image/x-icon",
      )
      #html.link(rel: "stylesheet", href: url-of-asset("/styles/tailwind.css"))
      #html.meta(name: "darkreader-lock", content: "")
      // Not deferred: it sets the theme before first paint.
      #html.script("", src: "/scripts/theme.js")
      #seo-head(project, page)
    ]
    #html.body[
      #show: base.with(project, page.route)
      #view(project, page, include page.source.file)
    ]
  ]
]
