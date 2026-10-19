// Loads each page's demo module (any `data-demo-src`) via dynamic
// import instead of a plain `<script type="module" src="...">` tag.
//
// Tola's SPA router morphs the page body in on navigation rather than
// doing a full reload, and per the HTML spec, a `<script>` element
// inserted that way (via innerHTML-style DOM patching, not a real
// parse) never executes: that's true of any script, module or not,
// regardless of whether its URL was already loaded on a previous page.
// So a demo whose only page never happened to be the one you hard-
// loaded would sit there with a bare canvas forever: no controls, no
// animation, because its module genuinely never ran.
//
// This script itself is a normal, always-present tag (see
// site/layout.typ), loaded once on first page load and never
// removed by the router, so it can safely listen for `tola:navigate`
// and do the loading itself. `import()` is a plain function call, not
// a DOM insertion, so it runs every time regardless of how the calling
// code was inserted; the browser's module cache still ensures each
// demo's own top-level code (its `mountDemo(...)` call) only ever runs
// once per URL. A demo (MotionGfx's `player.live-demo`, say) marks
// its shell with `data-demo-src` instead of emitting a `<script>` tag,
// precisely so this is the only thing responsible for loading it.
const loaded = new Set();

function loadDemos() {
  document.querySelectorAll("[data-demo-src]").forEach((el) => {
    const src = el.dataset.demoSrc;
    if (loaded.has(src)) return;
    loaded.add(src);
    import(src).catch((err) => {
      console.error("demo-bootstrap: failed to load", src, err);
    });
  });
}

loadDemos();
document.addEventListener("tola:navigate", loadDemos);
