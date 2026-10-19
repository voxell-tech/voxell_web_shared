// The metadata a content page may declare with `tola-meta`. Unknown
// fields are errors, so add new ones here first.

#import "@tola/schema:0.0.0": literal, nullable, optional, schema, union

// `layouts`: the names of the views a page may pick, the keys of the
// `views` that build.typ's `build` ends up with.
#let page-schema(layouts) = schema((
  // Shown as "Title | <site title>" in the browser tab; `none` on the
  // home page, which is just the site title.
  title: optional(nullable(str), default: none),
  // The meta description; falls back to the site's.
  summary: optional(nullable(str), default: none),
  // Which view renders the page: "page", "docs", or one of the site's
  // own.
  layout: optional(
    union(..layouts.map(literal)),
    default: "page",
  ),
  // Keeps the page out of search results and the sitemap.
  noindex: optional(bool, default: false),
  // Overrides the route the file's path gives the page: "/about/" is a
  // directory, "/404.html" is a file.
  permalink: optional(nullable(str), default: none),
))
