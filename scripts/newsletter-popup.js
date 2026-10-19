// Shows the newsletter popup (site/ui.typ's `newsletter-popup`) once
// the visitor scrolls to the element marked `data-newsletter-trigger`. It stays away for 30 days after being
// closed, and for good once the visitor subscribes (from the popup or
// the form further down the page). Runs on every page but only acts
// where the popup exists; re-arms after Tola's SPA navigation.
import { SUBSCRIBED_KEY } from "/scripts/newsletter.js";

// Named for MotionGfx's site, where these began; kept so its visitors'
// choices carry over. Each site has its own storage anyway.
const DISMISSED_KEY = "mgfx-newsletter-dismissed-at";
const SNOOZE_MS = 30 * 24 * 60 * 60 * 1000;

function read(key) {
  try {
    return localStorage.getItem(key);
  } catch {
    return null;
  }
}

function write(key, value) {
  try {
    localStorage.setItem(key, value);
  } catch {}
}

function shouldShow() {
  if (read(SUBSCRIBED_KEY)) return false;
  const dismissedAt = Number(read(DISMISSED_KEY));
  return !dismissedAt || Date.now() - dismissedAt > SNOOZE_MS;
}

function open(popup) {
  popup.hidden = false;
  // Next frame, so the slide-in transition runs from the hidden state.
  requestAnimationFrame(() => {
    requestAnimationFrame(() => popup.setAttribute("data-open", ""));
  });
}

function close(popup) {
  popup.removeAttribute("data-open");
  popup.hidden = true;
}

function arm() {
  const popup = document.querySelector(".newsletter-popup");
  const trigger = document.querySelector("[data-newsletter-trigger]");
  if (!popup || !trigger || popup.dataset.armed) return;
  popup.dataset.armed = "true";
  if (!shouldShow()) return;

  const observer = new IntersectionObserver((entries) => {
    if (!entries.some((entry) => entry.isIntersecting)) return;
    observer.disconnect();
    if (shouldShow()) open(popup);
  });
  observer.observe(trigger);
}

document.addEventListener("click", (event) => {
  const button = event.target.closest(".newsletter-popup-close");
  if (!button) return;
  write(DISMISSED_KEY, String(Date.now()));
  close(button.closest(".newsletter-popup"));
});

document.addEventListener("keydown", (event) => {
  if (event.key !== "Escape") return;
  const popup = document.querySelector(".newsletter-popup[data-open]");
  if (!popup) return;
  write(DISMISSED_KEY, String(Date.now()));
  close(popup);
});

// Subscribed via either form: leave the popup's success message up
// briefly if that's where it happened, then get out of the way.
document.addEventListener("newsletter:subscribed", () => {
  const popup = document.querySelector(".newsletter-popup[data-open]");
  if (popup) setTimeout(() => close(popup), 4000);
});

arm();
document.addEventListener("tola:navigate", arm);
