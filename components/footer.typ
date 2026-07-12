// Shared site footer: sectioned links (Community / Support / Contact).
// Import (from a site): #import "/shared/components/footer.typ": footer

#import "../links.typ": links
#import "social.typ": footer-social

#let footer-heading(label) = html.div(
  class: "text-xs font-semibold uppercase tracking-wide text-subtle mb-1",
)[#label]

#let footer() = {
  html.footer(class: "border-t border-text/10 mt-8")[
    #html.div(class: "max-w-3xl mx-auto px-4 py-10")[
      #html.a(
        class: "inline-block mb-8 opacity-75 hover:opacity-100 transition-opacity",
        href: links.website,
        target: "_blank",
        rel: ("noopener", "noreferrer"),
      )[
        #html.elem("img", attrs: (src: "/icons/voxell.svg", style: "height: 1.75rem; display: inline-block;"))
      ]
      #html.div(class: "grid grid-cols-2 sm:grid-cols-3 gap-8")[
        #html.div(class: "flex flex-col gap-3")[
          #footer-heading[Support]
          #footer-social(links.opencollective, "opencollective.svg", [Open Collective])
        ]
        #html.div(class: "flex flex-col gap-3")[
          #footer-heading[Community]
          #footer-social(links.github, "github.svg", [GitHub])
          #footer-social(links.discord, "discord.svg", [Discord])
          #footer-social(links.youtube, "youtube.svg", [YouTube])
          #footer-social(links.reddit, "reddit.svg", [Reddit])
          #footer-social(links.linkedin, "linkedin.svg", [LinkedIn])
          #footer-social(links.instagram, "instagram.svg", [Instagram])
        ]
        #html.div(class: "flex flex-col gap-3")[
          #footer-heading[Contact]
          #footer-social(links.email, "gmail.svg", [Email])
        ]
      ]
    ]
  ]
}
