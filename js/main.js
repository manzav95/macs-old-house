(() => {
  const nav = document.querySelector("[data-nav]");
  const toggle = document.querySelector("[data-nav-toggle]");
  const links = document.querySelector("[data-nav-links]");
  const year = document.querySelector("[data-year]");
  const layers = [...document.querySelectorAll("[data-depth]")];
  const reduce = window.matchMedia("(prefers-reduced-motion: reduce)");
  const video = document.querySelector(".hero-video");

  if (year) year.textContent = String(new Date().getFullYear());

  const onScrollNav = () => {
    nav.classList.toggle("is-scrolled", window.scrollY > 24);
  };
  onScrollNav();
  window.addEventListener("scroll", onScrollNav, { passive: true });

  toggle?.addEventListener("click", () => {
    const open = links.classList.toggle("is-open");
    toggle.setAttribute("aria-expanded", String(open));
  });
  links?.querySelectorAll("a").forEach((a) => {
    a.addEventListener("click", () => {
      links.classList.remove("is-open");
      toggle.setAttribute("aria-expanded", "false");
    });
  });

  if (video) {
    const tryPlay = () => video.play().catch(() => {});
    tryPlay();
    document.addEventListener("visibilitychange", () => {
      if (!document.hidden) tryPlay();
    });
  }

  if (reduce.matches) return;

  let ticking = false;
  const update = () => {
    const vh = window.innerHeight;
    layers.forEach((el) => {
      const depth = Number(el.dataset.depth) || 0;
      const rect = el.getBoundingClientRect();
      const offset = rect.top + rect.height / 2 - vh / 2;
      const shift = offset * depth * -0.28;
      el.style.transform = `translate3d(0, ${shift.toFixed(2)}px, 0)`;
    });
    ticking = false;
  };

  const requestTick = () => {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(update);
  };

  update();
  window.addEventListener("scroll", requestTick, { passive: true });
  window.addEventListener("resize", requestTick, { passive: true });
})();
