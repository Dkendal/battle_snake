export const ready = new Promise((resolve) => {
  document.addEventListener("DOMContentLoaded", () => resolve());
})
