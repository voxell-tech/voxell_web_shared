// Submits any newsletter form (site/ui.typ's `newsletter-form`,
// used by both the landing page section and the popup) to Kit in place,
// instead of navigating away to Kit's hosted confirmation page. Kit's
// endpoint allows cross-origin POSTs. Delegated on `document`, like
// docs-nav.js, so it keeps working after Tola's SPA navigation swaps in
// a fresh copy of the form.
//
// On success it also remembers the visitor subscribed and fires
// `newsletter:subscribed`, so newsletter-popup.js never asks again.
export const SUBSCRIBED_KEY = "mgfx-newsletter-subscribed";

document.addEventListener("submit", async (event) => {
  const form = event.target.closest(".newsletter-form");
  if (!form) return;
  event.preventDefault();

  const status = form.parentElement.querySelector(".newsletter-status");
  const button = form.querySelector("button");
  button.disabled = true;
  // The popup hides this line on small screens to stay thin; a result
  // message still needs to show.
  status.classList.remove("max-sm:hidden");

  try {
    const response = await fetch(form.action, {
      method: "POST",
      body: new FormData(form),
      headers: { Accept: "application/json" },
    });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);

    form.style.display = "none";
    status.classList.remove("text-muted", "text-red");
    status.classList.add("text-accent");
    status.textContent = "Success! Now check your email to confirm your subscription.";

    try {
      localStorage.setItem(SUBSCRIBED_KEY, "1");
    } catch {}
    document.dispatchEvent(new CustomEvent("newsletter:subscribed"));
  } catch {
    button.disabled = false;
    status.classList.remove("text-muted");
    status.classList.add("text-red");
    status.textContent = "Something went wrong. Please try again.";
  }
});
