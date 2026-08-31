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

  const apple = /iPhone|iPad|iPod|Macintosh/.test(navigator.userAgent);
  if (apple) {
    const appleMaps =
      "https://maps.apple.com/?daddr=3100+E+18th+St,+Antioch,+CA+94509&dirflg=d";
    document.querySelectorAll("[data-maps='directions']").forEach((a) => {
      a.href = appleMaps;
    });
  }

  const landHero = () => {
    document.querySelector(".hero")?.classList.add("is-landed");
  };

  const showEl = (el) => {
    if (!el || el.classList.contains("is-in")) return;
    el.classList.add("is-in");
  };

  const revealInView = () => {
    const line = window.innerHeight * 0.78;
    document.querySelectorAll("[data-reveal]:not(.is-in)").forEach((el) => {
      const r = el.getBoundingClientRect();
      if (r.top < line && r.bottom > 0) showEl(el);
    });
  };

  if (reduce.matches) {
    landHero();
    document.querySelectorAll("[data-reveal]").forEach(showEl);
    return;
  }

  requestAnimationFrame(() => requestAnimationFrame(landHero));

  const reveals = [...document.querySelectorAll("[data-reveal]")];

  if (reveals.length) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        showEl(entry.target);
        io.unobserve(entry.target);
      });
    }, { threshold: 0, rootMargin: "0px 0px -22% 0px" });
    reveals.forEach((el) => io.observe(el));
  }

  window.addEventListener("scroll", revealInView, { passive: true });
  window.addEventListener("resize", revealInView, { passive: true });
  requestAnimationFrame(revealInView);


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
