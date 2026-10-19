// Page building blocks shared by Voxell's project sites.
// Import: #import "/shared/site/ui.typ" as ui

#import "@preview/cetz:0.5.2": canvas, draw
#import "utils.typ": cls

/// The newsletter `<form>` itself, posting straight to the Kit form
/// whose ID is `form` (from the form's Kit embed URL). A plain form, not Kit's embed script: that script ships its
/// own light-only styling, and Tola's SPA navigation never re-runs
/// inserted `<script>`s anyway. Styled with the site's own tokens, so it
/// follows the theme toggle. scripts/newsletter.js upgrades every
/// `.newsletter-form` to submit in place; with no JS it still works, it
/// just lands on Kit's hosted confirmation page. `field-bg` is the
/// input's background, so it contrasts with whatever it sits on.
#let newsletter-form(form, layout: "flex flex-col sm:flex-row gap-2", field-bg: "bg-surface") = html.elem("form", attrs: (
  class: "newsletter-form " + layout,
  action: "https://app.kit.com/forms/" + form + "/subscriptions",
  method: "post",
))[
  #html.elem("input", attrs: (
    type: "email",
    name: "email_address",
    required: "",
    placeholder: "you@example.com",
    aria-label: "Email address",
    class: "flex-1 min-w-0 px-4 py-2.5 rounded-lg text-text border border-text/15 placeholder:text-muted focus:outline-none focus:border-accent " + field-bg,
  ))
  #html.elem("button", attrs: (
    type: "submit",
    class: "px-5 py-2.5 rounded-lg bg-accent text-bg font-semibold hover:opacity-90 transition-opacity cursor-pointer disabled:opacity-50",
  ))[Subscribe]
]

/// Newsletter signup section for the landing page.
/// `blurb` says what the list sends, e.g. [We'll email you when X has
/// something new.]
#let newsletter(form, blurb) = html.section(class: "py-12 px-4 sm:px-6")[
  #html.div(class: "max-w-xl mx-auto text-center")[
    #html.h2(class: "text-3xl font-bold mb-2")[Get Updates by Email]
    #html.p(class: "text-muted text-lg mb-6")[#blurb]
    #newsletter-form(form)
    #html.p(class: "newsletter-status text-sm text-muted mt-3")[
      No spam. Unsubscribe anytime.
    ]
  ]
]

/// The same signup as a small popup: a card centered along the bottom
/// edge from sm: up (inset-x-0 plus auto margins, not a translate, since
/// the slide-in animation already owns `translate`), a thin bar along
/// the bottom edge below that. Starts
/// hidden; scripts/newsletter-popup.js decides when (and whether) to
/// show it, once the visitor reaches the element marked with
/// `data-newsletter-trigger`. Not a modal: it never takes focus or
/// blocks the page. `teaser` is its one-line pitch.
#let newsletter-popup(form, teaser) = html.elem("aside", attrs: (
  class: "newsletter-popup fixed z-40 inset-x-0 bottom-0 sm:mx-auto sm:bottom-6 sm:w-[22rem] bg-surface border-t-2 sm:border-2 border-accent/60 sm:rounded-lg shadow-xl shadow-accent/10 p-3 sm:p-4 transition duration-300 translate-y-4 opacity-0 data-open:translate-y-0 data-open:opacity-100 motion-reduce:transition-none",
  aria-label: "Newsletter signup",
  hidden: "",
))[
  #html.div(class: "flex items-start justify-between gap-2 mb-3")[
    #html.div(class: "flex items-start gap-2.5")[
      // Mail icon, so it reads as a signup before anyone reads the words.
      #html.elem("svg", attrs: (
        class: "shrink-0 mt-0.5 text-accent",
        width: "20",
        height: "20",
        viewBox: "0 0 24 24",
        fill: "none",
        stroke: "currentColor",
        stroke-width: "2",
        stroke-linecap: "round",
        stroke-linejoin: "round",
        aria-hidden: "true",
      ))[
        #html.elem("rect", attrs: (x: "2", y: "4", width: "20", height: "16", rx: "2"))[]
        #html.elem("path", attrs: (d: "m22 7-10 6L2 7"))[]
      ]
      #html.div[
        #html.p(class: "text-base font-bold text-text leading-tight")[
          Get Updates by Email
        ]
        #html.p(class: "text-xs text-muted mt-0.5 max-sm:hidden")[
          #teaser
        ]
      ]
    ]
    #html.elem("button", attrs: (
      type: "button",
      class: "newsletter-popup-close shrink-0 text-muted hover:text-text transition-colors cursor-pointer bg-transparent border-0 p-0 leading-none",
      aria-label: "Close",
    ))[#html.elem("svg", attrs: (
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
    ]]
  ]
  #html.div[
    #newsletter-form(form, layout: "flex gap-2", field-bg: "bg-bg")
    #html.p(class: "newsletter-status text-xs text-muted mt-2 max-sm:hidden")[
      No spam. Unsubscribe anytime.
    ]
  ]
]

/// Card container
#let card(title: none, body) = html.div(class: "p-4 bg-surface rounded-lg")[
  #if title != none { html.h3(class: "font-semibold text-accent mb-2")[#title] }
  #body
]

/// Reads a Rust source file and pulls out the region between a
/// `// snippet:start` and a `// snippet:end` comment, dedented to that
/// region's own smallest indent. Used so a demo's code block is the
/// literal source that got compiled into the page's wasm, not a
/// hand-copied paraphrase of it that can quietly drift out of sync;
/// MotionGfx's site uses it for its wasm demos.
#let rust-snippet(path) = {
  let source = read(path)
  let start-marker = "// snippet:start"
  let end-marker = "// snippet:end"
  let start = source.position(start-marker)
  let end = source.position(end-marker)
  assert(
    start != none and end != none,
    message: "rust-snippet: couldn't find " + start-marker + "/" + end-marker + " in " + path,
  )

  let lines = source.slice(start + start-marker.len(), end).split("\n")
  if lines.len() > 0 and lines.first().trim() == "" { lines = lines.slice(1) }
  if lines.len() > 0 and lines.last().trim() == "" { lines = lines.slice(0, -1) }

  let leading-spaces(line) = {
    let n = 0
    for c in line.codepoints() {
      if c != " " { break }
      n += 1
    }
    n
  }

  let indents = lines.filter(l => l.trim() != "").map(leading-spaces)
  let min-indent = if indents.len() > 0 { calc.min(..indents) } else { 0 }
  let dedented = lines.map(l => if l.len() >= min-indent { l.slice(min-indent) } else { l })

  raw(dedented.join("\n"), lang: "rust", block: true)
}

/// Side-by-side showcase card: source code + rendered output. Two
/// columns from md: up (stacked below that, where there's no room to
/// put them side by side); pass `reverse: true` to swap which side the
/// preview lands on, e.g. alternating across a page's sections so they
/// don't all read the same direction.
#let showcase-demo(
  title: none,
  description: none,
  code: none,
  preview: none,
  code-label: "Typst Code",
  preview-label: "Rendered Output",
  reverse: false,
) = {
  assert(title != none, message: "showcase-demo: `title` is required")
  assert(code != none, message: "showcase-demo: `code` is required")
  assert(preview != none, message: "showcase-demo: `preview` is required")

  let code-order = if reverse { "md:order-2" } else { "md:order-1" }
  let preview-order = if reverse { "md:order-1" } else { "md:order-2" }

  html.section(
    class: "my-8 rounded-lg bg-gradient-to-br from-bg/80 via-bg/50 to-surface/20 p-4 sm:p-6",
  )[
    #html.div(class: "mb-4")[
      #html.h3(class: "text-3xl font-bold mb-2")[
        #title
      ]
      #if description != none {
        html.p(class: "mt-1 text-sm text-subtle")[
          #description
        ]
      }
    ]

    #html.div(class: "grid gap-4 md:grid-cols-2 md:items-stretch")[
      #html.div(
        class: "rounded-lg border border-text/10 bg-bg/70 overflow-hidden "
          + code-order,
      )[
        #html.div(
          class: "border-b border-text/10 px-3 py-2 text-xs uppercase tracking-wide text-muted",
        )[
          #code-label
        ]
        #html.div(class: "p-3 text-sm")[
          #code
        ]
      ]

      #html.div(
        class: "rounded-lg border border-accent/30 bg-surface/40 overflow-hidden "
          + preview-order,
      )[
        #html.div(
          class: "border-b border-accent/20 px-3 py-2 text-xs uppercase tracking-wide text-accent",
        )[
          #preview-label
        ]
        #html.div(class: "p-3 text-sm")[
          #preview
        ]
      ]
    ]
  ]
}

/// Horizontal rule between landing page sections.
#let hr = html.hr(class: "border-surface my-8")

/// Flex row container with configurable gap.
/// safelist: gap-1 gap-2 gap-3 gap-4 gap-5 gap-6 gap-7 gap-8
#let flex-row(gap: 4, ..items) = html.div(
  class: cls("flex flex-wrap items-center", "gap-" + str(gap)),
)[#for item in items.pos() { item }]

/// Flex column container with configurable gap.
/// safelist: gap-1 gap-2 gap-3 gap-4 gap-5 gap-6 gap-7 gap-8
#let flex-col(gap: 4, ..items) = html.div(
  class: cls("flex flex-col", "gap-" + str(gap)),
)[#for item in items.pos() { item }]

/// Grid container.
/// safelist: grid-cols-1 grid-cols-2 grid-cols-3 grid-cols-4
#let grid(cols: 2, gap: 4, ..items) = html.div(
  class: cls("grid", "grid-cols-" + str(cols), "gap-" + str(gap)),
)[#for item in items.pos() { item }]

// Opens in a new tab, for links that leave the site.
#let external-attrs(href) = if href.starts-with("http") {
  (target: "_blank", rel: ("noopener", "noreferrer"))
} else { (:) }

/// A link styled as a button. `primary` fills it with the accent;
/// otherwise it is outlined. `large` is for the hero and closing CTA.
#let button(href, primary: true, large: false, class: none, body) = {
  let look = if primary {
    "px-5 py-2.5 rounded-lg bg-accent text-bg font-semibold hover:opacity-90 transition-opacity"
  } else {
    "px-5 py-2.5 rounded-lg border border-text/15 text-text font-semibold hover:border-accent/50 hover:text-accent transition-colors"
  }
  html.a(
    class: cls(class, look, if large { "text-lg" }),
    href: href,
    ..external-attrs(href),
  )[#body]
}

/// The outlined "View on GitHub" button, with the GitHub mark.
#let github-button(href) = button(
  href,
  primary: false,
  large: true,
  class: "flex items-center gap-2",
)[
  #html.elem("span", attrs: (
    class: "social-icon",
    style: "--icon: url('/icons/github.svg'); background-color: currentColor;",
  ))
  View on GitHub ↗
]

/// A small rounded pill above the hero title, for news.
#let pill(href, body) = html.a(
  class: "inline-block mb-4 px-3 py-1 rounded-full border border-text/15 text-muted text-sm hover:border-accent/50 hover:text-accent transition-colors",
  href: href,
  ..external-attrs(href),
)[#body]

/// The landing page's opening: an optional `pill`, the wordmark, one
/// or two lines under it, and a row of buttons.
#let hero(
  title,
  tagline: none,
  subtitle: none,
  pill: none,
  actions: (),
) = html.div(class: "text-center py-20 px-5")[
  #pill
  #html.h1(class: "text-6xl sm:text-7xl font-bold mb-4 tracking-tight")[
    #title
  ]
  #if tagline != none {
    html.p(class: "text-muted text-xl mb-2 max-w-2xl mx-auto")[#tagline]
  }
  #if subtitle != none {
    html.p(class: "text-muted text-lg mb-8 max-w-2xl mx-auto")[#subtitle]
  }
  #html.div(class: "flex flex-wrap justify-center gap-3")[
    #for action in actions { action }
  ]
]

/// A landing page section: a heading, a paragraph, and an optional
/// button on one side, with `media` (an image, diagram, or code block)
/// on the other. Stacked below md:. `reverse` puts the media first,
/// for alternating sections. `id` makes it a link target, such as the
/// newsletter popup's `data-newsletter-trigger`.
#let feature(
  title,
  body,
  media: none,
  action: none,
  reverse: false,
  id: none,
  attrs: (:),
) = html.elem("section", attrs: (
  ..if id != none { (id: id) },
  class: "py-12 px-4 sm:px-6",
  ..attrs,
))[
  #html.div(class: cls(
    "flex flex-col items-center gap-8",
    if reverse { "md:flex-row-reverse" } else { "md:flex-row" },
  ))[
    #html.div(class: "flex-1 text-center md:text-left")[
      #html.h2(class: "text-3xl font-bold mb-2")[#title]
      #html.p(class: "text-muted text-lg")[#body]
      #action
    ]
    #if media != none {
      html.div(class: "flex-1 flex justify-center min-w-0 w-full")[#media]
    }
  ]
]

/// A feature section's button, spaced under its paragraph.
#let feature-button(href, primary: false, body) = button(
  href,
  primary: primary,
  class: "inline-block mt-4",
  body,
)

/// A centered heading and paragraph, for a section whose content is
/// too wide to sit beside its text (a screenshot, say).
#let section-heading(title, body, action: none) = html.div(
  class: "text-center max-w-2xl mx-auto mb-8",
)[
  #html.h2(class: "text-3xl font-bold mb-2")[#title]
  #html.p(class: "text-muted text-lg")[#body]
  #action
]

/// The closing call to action at the bottom of the landing page.
#let cta(title, action) = html.div(class: "text-center py-12")[
  #html.h2(class: "text-3xl font-bold mb-4")[#title]
  #action
]

/// A code block sized to sit in a `feature`'s media column: it takes
/// the column's width and scrolls sideways instead of overflowing.
#let code-panel(body) = html.div(
  class: "w-full min-w-0 text-left text-sm",
)[#body]

// One render of `backend-diagram`, in the site's dark or light tokens
// (shared/styles.css), since the SVG's colors bake in at build time.
#let _backend-canvas(core, backends, accent, dark) = {
  let accent = if dark { accent.dark } else { accent.light }
  let accent-fill = rgb(accent.to-hex() + if dark { "26" } else { "1a" })
  let muted = if dark { rgb("#939293") } else { rgb("#727072") }
  let dim = if dark { rgb("#5b5a5c") } else { rgb("#b5b3b5") }
  let muted-text = if dark { rgb("#fcfcfa") } else { rgb("#2d2a2e") }

  box(inset: 20pt)[
    #canvas(length: 1cm, {
      import draw: *

      let piece(label, dashed: false) = box(
        radius: 8pt,
        stroke: (
          paint: if dashed { dim } else { muted },
          thickness: 1.5pt,
          dash: if dashed { "dashed" } else { none },
        ),
        inset: (x: 12pt, y: 8pt),
      )[#text(fill: muted-text, size: 10pt)[#label]]

      content((0.0, 0.0), name: "core")[
        #box(
          radius: 8pt,
          fill: accent-fill,
          stroke: 1.5pt + accent,
          inset: (x: 14pt, y: 8pt),
        )[#text(fill: accent, weight: "bold", size: 13pt)[#core]]
      ]

      let first = -3.0 * (backends.len() - 1) / 2
      for (i, backend) in backends.enumerate() {
        let name = "backend-" + str(i)
        let dashed = not backend.at("ready", default: false)
        content(
          (first + 3.0 * i, -2.2),
          name: name,
        )[#piece(backend.label, dashed: dashed)]
        if dashed {
          line(
            "core.south",
            name + ".north",
            stroke: (paint: dim, thickness: 1.5pt, dash: "dashed"),
            mark: (end: ">", fill: dim),
          )
        } else {
          line(
            "core.south",
            name + ".north",
            stroke: 1.5pt + accent,
            mark: (end: ">", fill: accent),
          )
        }
      }
    })
  ]
}

/// "Backend agnostic" diagram: the project as the one core, with its
/// backends as interchangeable pieces under it. `backends` is an array
/// of `(label:, ready:)`; a `ready` one is drawn solid, the rest
/// dashed, as pluggable but not built yet. Both a dark and a light
/// render ship in the page, toggled by `.diagram-dark`/`.diagram-light`
/// in site.css the same way the nav's sun/moon icon is. `accent`
/// should match the site's `--color-accent` in each theme.
#let backend-diagram(
  core,
  backends,
  label: none,
  accent: (dark: rgb("#78dce8"), light: rgb("#0d7a8a")),
) = html.elem(
  "div",
  attrs: (role: "img", aria-label: label),
)[
  #html.span(class: "diagram-dark")[
    #html.frame(_backend-canvas(core, backends, accent, true))
  ]
  #html.span(class: "diagram-light")[
    #html.frame(_backend-canvas(core, backends, accent, false))
  ]
]
