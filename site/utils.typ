// Helpers the site kit uses, taken from the `utils/tola.typ` that
// `tola init` generates, trimmed to what the kit calls.

/// Join CSS classes, skipping `none` and empty strings and
/// normalizing spaces. Arrays are flattened.
///
/// ```typst
/// cls("text-2xl", "font-bold")        // => "text-2xl font-bold"
/// cls("base", if active { "active" }) // => "base active" or "base"
/// ```
#let cls(..args) = {
  let flatten(items) = {
    let result = ()
    for item in items {
      if type(item) == array { result += flatten(item) } else {
        result.push(item)
      }
    }
    result
  }
  let raw = flatten(args.pos())
    .filter(x => x != none and x != "")
    .map(x => str(x))
    .join(" ")
  raw.split(" ").filter(x => x != "").join(" ")
}

/// Content to plain text, recursing through its children.
#let to-string(it) = {
  if it == none { "" } else if type(it) == str { it } else if (
    type(it) != content
  ) { str(it) } else if it.has("text") {
    if type(it.text) == str { it.text } else { to-string(it.text) }
  } else if it.has("children") {
    it.children.map(to-string).join()
  } else if it.has("body") {
    to-string(it.body)
  } else if it == [ ] { " " } else { "" }
}

// One Open Graph or Twitter meta tag, or nothing when `content` is
// empty. Open Graph tags use `property`, which `html.meta` lacks.
#let _og-meta(prop, content) = {
  if content == none or content == "" { return none }
  let c = to-string(content)
  if prop.starts-with("og:") {
    html.elem("meta", attrs: (property: prop, content: c))
  } else {
    html.meta(name: prop, content: c)
  }
}

/// Open Graph and Twitter card tags for a page's link previews.
#let og-tags(
  title: none,
  description: none,
  url: none,
  image: none,
  type: "website",
  site-name: none,
  locale: none,
  twitter-card: "summary_large_image",
) = context {
  if target() != "html" { return }

  _og-meta("og:title", title)
  _og-meta("og:description", description)
  _og-meta("og:url", url)
  _og-meta("og:image", image)
  _og-meta("og:type", type)
  _og-meta("og:site_name", site-name)
  _og-meta("og:locale", locale)

  _og-meta("twitter:card", twitter-card)
  _og-meta("twitter:title", title)
  _og-meta("twitter:description", description)
  _og-meta("twitter:image", image)
}
