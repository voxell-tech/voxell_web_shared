// Docs sidebar and previous/next links.
// Import: #import "/shared/site/docs-nav.typ": sidebar, page-nav
//
// Both take `chapters`, the project's sidebar groups in reading order
// (see `chapters` in the README), and `current`, the route of the page
// being rendered (e.g. "/docs/bevy/"), to mark the active chapter and
// find its neighbors.

// Strip a trailing slash from both sides before comparing, so an href
// written without one still matches its route.
#let norm(path) = if path != none and path != "/" and path.ends-with("/") {
  path.slice(0, -1)
} else {
  path
}

// The "Chapters" nav. A `<details>` disclosure: on mobile the toggle is
// a plain ghost icon sitting in normal flow (no fixed positioning, so
// it can never overlap the page title), opening a full-height drawer
// over a dimmed backdrop; on desktop the whole thing becomes a
// full-height rail pinned to the left edge, always expanded, toggle
// hidden. `.docs-nav` is scripts/docs-nav.js's hook: a closed
// `<details>`'s content isn't reliably force-open-able with CSS alone
// across engines, so keeping it open on desktop is a few lines of JS
// (setting `.open` directly) rather than a `display` override; the same
// script also closes the mobile drawer on backdrop/link/close clicks.
#let sidebar(chapters, current) = html.elem("details", attrs: (
  class: "docs-nav inline-block text-sm md:block md:fixed md:top-24 md:left-0 md:w-56 md:h-[calc(100vh-6rem)] md:overflow-y-auto md:px-4",
))[
  #html.elem("summary", attrs: (class: "docs-nav-toggle"))[
    #html.elem("svg", attrs: (
      width: "20",
      height: "20",
      viewBox: "0 0 16 16",
      fill: "currentColor",
    ))[
      #html.elem("rect", attrs: (
        x: "1",
        y: "3",
        width: "14",
        height: "2",
        rx: "1",
      ))[]
      #html.elem("rect", attrs: (
        x: "1",
        y: "7",
        width: "14",
        height: "2",
        rx: "1",
      ))[]
      #html.elem("rect", attrs: (
        x: "1",
        y: "11",
        width: "14",
        height: "2",
        rx: "1",
      ))[]
    ]
    #html.span(class: "sr-only")[Chapters]
  ]
  #html.elem("div", attrs: (class: "docs-nav-backdrop"))[]
  #html.div(class: "docs-nav-body")[
    #html.elem("button", attrs: (type: "button", class: "docs-nav-close"))[
      #html.elem("svg", attrs: (
        width: "14",
        height: "14",
        viewBox: "0 0 16 16",
        fill: "none",
        stroke: "currentColor",
        stroke-width: "2",
        stroke-linecap: "round",
      ))[
        #html.elem("line", attrs: (x1: "2", y1: "2", x2: "14", y2: "14"))[]
        #html.elem("line", attrs: (x1: "14", y1: "2", x2: "2", y2: "14"))[]
      ]
      Close
    ]
    #for group in chapters {
      html.div(class: "mb-6 last:mb-0")[
        #html.div(
          class: "font-semibold text-subtle uppercase tracking-wide text-xs mb-2",
        )[#group.title]
        #html.div(class: "flex flex-col gap-0.5")[
          #for item in group.items {
            let active = norm(current) == norm(item.href)
            let link-class = if active {
              "block px-3 py-2 rounded-lg bg-surface text-accent font-medium"
            } else {
              "block px-3 py-2 rounded-lg text-muted hover:text-accent hover:bg-surface/50 transition-colors"
            }
            html.a(class: link-class, href: item.href)[#item.title]
          }
        ]
      ]
    }
  ]
]

/// "Previous"/"Next" cards linking to whatever's adjacent to the current
/// page in `chapters`' reading order. Either side is omitted at the ends
/// (no Previous on the first page, no Next on the last), and the
/// remaining one still takes its own column so it doesn't stretch full
/// width alone. Called automatically by the docs view, so
/// individual pages don't hand-write their own "== Next" section.
#let page-nav(chapters, current) = {
  let flat-items = chapters.map(g => g.items).flatten()
  let idx = flat-items.position(item => (
    norm(item.href) == norm(current)
  ))
  if idx == none { return none }

  let prev = if idx > 0 { flat-items.at(idx - 1) } else { none }
  let next = if idx + 1 < flat-items.len() { flat-items.at(idx + 1) } else {
    none
  }
  if prev == none and next == none { return none }

  let card(label, item, href, align-end: false) = html.a(
    class: "flex-1 min-w-0 px-4 py-3 rounded-lg border border-text/10 hover:border-accent/40 hover:bg-surface/50 transition-colors no-underline group"
      + if align-end { " text-right" } else { "" },
    href: href,
  )[
    #html.div(class: "text-xs text-subtle uppercase tracking-wide mb-1")[#label]
    #html.div(class: "font-semibold group-hover:text-accent transition-colors")[
      #if align-end { [#item →] } else { [← #item] }
    ]
  ]

  html.div(class: "mt-10 flex gap-4 text-sm")[
    #if prev != none { card("Previous", prev.title, prev.href) }
    #if next != none { card("Next", next.title, next.href, align-end: true) }
  ]
}
