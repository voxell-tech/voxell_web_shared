// The two page views every project site has. A view is
// `(project, page, body) => content`, wrapped by layout.typ's `base`.
// - "page": the landing page and other free-form pages.
// - "docs": the chapters sidebar beside a prose column, with
//   previous/next links under it.

#import "utils.typ": cls
#import "docs-nav.typ": page-nav, sidebar

#let colors = (
  accent: "text-accent",
  code: "text-purple",
  muted: "text-muted",
)

#let page-view(project, page, body) = {
  show heading.where(level: 1): it => html.h2(class: cls(
    "text-2xl font-bold mt-8 mb-4",
    colors.accent,
  ))[#it.body]
  show heading.where(level: 2): it => html.h3(
    class: "text-xl font-semibold mt-6 mb-3",
  )[#it.body]
  body
}

#let docs-view(project, page, body) = {
  show heading.where(level: 1): it => html.h2(class: cls(
    "text-2xl sm:text-3xl font-bold mt-8 mb-4",
    colors.accent,
  ))[#it.body]
  show heading.where(level: 2): it => html.h3(
    class: "text-lg sm:text-xl font-semibold mt-6 mb-3",
  )[#it.body]

  // The sidebar is fixed-positioned at every size (see docs-nav.typ),
  // so it never occupies flow space here; `md:ml-64` on the content
  // column just clears the desktop rail it becomes from md: up.
  sidebar(project.chapters, page.route)
  html.div(class: "max-w-3xl md:ml-64 text-base")[
    #body
    #page-nav(project.chapters, page.route)
  ]
}

#let views = (page: page-view, docs: docs-view)
