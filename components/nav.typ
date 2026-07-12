// Shared top navigation bar.
// Import (from a site): #import "/shared/components/nav.typ": nav
//
//   nav(links: (
//     (label: [Projects], href: "/projects", match: "/projects"),
//     (label: [Blog ↗], href: blog-url, external: true),
//   ))
//
// Each link is a dict: (label, href, external: false, match: none).
// `match`: when current-permalink starts with this prefix the link is shown as
// active (text-accent). `external` opens in a new tab.

#import "@tola/current:0.0.0": current-permalink

#let nav(brand-href: "/", links: ()) = {
  html.nav(class: "border-b border-text/10")[
    #html.div(class: "max-w-3xl mx-auto px-4 py-3 flex items-center justify-between")[
      #html.a(class: "opacity-75 hover:opacity-100 transition-opacity", href: brand-href)[
        #html.elem("img", attrs: (src: "/icons/voxell.svg", style: "height: 1.5rem; display: inline-block;"))
      ]
      #html.div(class: "flex items-center gap-6")[
        #for link in links {
          let match = link.at("match", default: none)
          let active = match != none and current-permalink != none and current-permalink.starts-with(match)
          let link-class = if active {
            "text-accent transition-colors"
          } else {
            "text-muted hover:text-accent transition-colors"
          }
          let external = link.at("external", default: false)
          html.div[#html.a(
            class: link-class,
            href: link.href,
            ..if external { (target: "_blank", rel: ("noopener", "noreferrer")) },
          )[#link.label]]
        }
        #html.elem("button", attrs: (
          id: "theme-toggle",
          class: "text-muted hover:text-accent transition-colors cursor-pointer bg-transparent border-0 p-0 leading-none",
        ))[
          #html.span(class: "icon-sun")[#html.elem("img", attrs: (src: "/icons/sun.svg", style: "height: 1.25rem; display: inline-block;"))]
          #html.span(class: "icon-moon")[#html.elem("img", attrs: (src: "/icons/moon.svg", style: "height: 1.25rem; display: inline-block;"))]
        ]
      ]
    ]
  ]
}
