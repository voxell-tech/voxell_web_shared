// Everything in <head> that search engines and link previews read:
// title, description, canonical URL, Open Graph, and Twitter card tags,
// plus schema.org data on the home page. Called for every page by
// layout.typ's `emit`.
//
// Page metadata it reads (declared in schema.typ):
// - `title`: shown as "Title | <site title>" (just the site title if
//   none).
// - `summary`: the meta description; falls back to the site's.
// - `noindex`: keep the page out of search results (the 404 page).

#import "@tola/address:0.0.0": url-of
#import "@tola/site:0.0.0": site
#import "utils.typ": og-tags

// Who runs the site, for search engines (schema.org): what a site
// without a `repo`, such as voxell.dev itself, describes.
#let organization-ld(project) = html.elem(
  "script",
  attrs: (type: "application/ld+json"),
)[#json.encode(pretty: false, (
  "@context": "https://schema.org",
  "@type": "Organization",
  name: site.title,
  description: site.description,
  url: site.origin,
  logo: site.origin + "/icons/voxell.svg",
  sameAs: project.at("same-as", default: ()),
))]

// What the project is, where its source lives, and its license, for
// search engines (schema.org).
#let software-ld(project) = html.elem(
  "script",
  attrs: (type: "application/ld+json"),
)[#json.encode(pretty: false, (
  "@context": "https://schema.org",
  "@type": "SoftwareSourceCode",
  name: site.title,
  description: site.description,
  url: site.origin,
  codeRepository: project.repo,
  programmingLanguage: "Rust",
  license: "https://spdx.org/licenses/" + project.license + ".html",
  author: (
    "@type": "Organization",
    name: "Voxell",
    url: "https://voxell.dev",
  ),
))]

#let seo-head(project, page) = {
  let m = page.source.meta
  let full-title = if m.title != none {
    m.title + " | " + site.title
  } else { site.title }
  let description = if m.summary != none { m.summary } else {
    site.description
  }
  let url = url-of(page.output, origin: site.origin)

  html.elem("meta", attrs: (
    name: "viewport",
    content: "width=device-width, initial-scale=1",
  ))
  html.title(full-title)
  html.meta(name: "description", content: description)
  html.link(rel: "canonical", href: url)
  if m.noindex {
    html.meta(name: "robots", content: "noindex")
  }
  og-tags(
    title: full-title,
    description: description,
    url: url,
    image: site.origin + project.og-image,
    type: "website",
    site-name: site.title,
    locale: "en_US",
  )
  if page.route == "/" {
    if "repo" in project { software-ld(project) } else {
      organization-ld(project)
    }
  }
}
