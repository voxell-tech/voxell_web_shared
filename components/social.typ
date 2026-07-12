// Shared social-link helper.
// A block-wrapped anchor with a mask-tinted icon span (see ../styles.css).
// The icon file is served at /icons/<icon> in each site.

#let footer-social(href, icon, label) = html.div[#html.a(
  class: "social-link flex items-center gap-2 text-sm text-muted hover:text-accent transition-colors",
  href: href,
  target: "_blank",
  rel: ("noopener", "noreferrer"),
)[#html.elem("span", attrs: (class: "social-icon", style: "--icon: url('/icons/" + icon + "')"))#label]]
