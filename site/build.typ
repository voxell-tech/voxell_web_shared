// A project site's whole build, called from its site.typ:
//
//   #import "/shared/site/build.typ": build
//   #import "/project.typ": project
//   #build(project)
//
// It chooses which sources under content/ become pages, where each one
// is published, and which view renders it, then writes the sitemap.

#import "@tola/address:0.0.0": decode-url-path, join-route, output-of, route-of, slugify
#import "@tola/site:0.0.0": site
#import "@tola/source:0.0.0": all-sources, parse-sources
#import "@tola/web:0.0.0": sitemap
#import "layout.typ": emit
#import "schema.typ": page-schema
#import "views.typ": views as kit-views

// A page is published at the route its file path gives it
// (content/docs/bevy.typ -> /docs/bevy/), unless it sets `permalink`.
#let output-for(source) = output-of(if source.meta.permalink != none {
  decode-url-path(source.meta.permalink)
} else {
  join-route(source.route-segments.map(segment => slugify(segment)))
})

/// - project: the site's project.typ record.
/// - views: the site's own views on top of "page" and "docs", by the
///   name a page picks with `layout`.
#let build(project, views: (:)) = {
  set text(lang: site.language.lang)

  let views = kit-views + views
  let schema = page-schema(views.keys())
  let pages = parse-sources(all-sources(), schema).map(source => {
    let output = output-for(source)
    (source: source, output: output, route: route-of(output))
  })

  for page in pages {
    emit(project, page, views.at(page.source.meta.layout))
  }

  sitemap(targets: pages
    .filter(page => not page.source.meta.noindex)
    .map(page => page.output))
}
