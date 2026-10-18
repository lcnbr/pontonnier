function initializeSite(site) {
  const header = site.querySelector('.site-header');
  const tools = header.querySelector('.nav-tools');
  const brand = tools.querySelector('.compact-brand');
  const inline = tools.querySelector('.inline-links');
  const overflow = tools.querySelector('.overflow-menu');
  const extra = overflow.querySelector('.overflow-links');
  const toggle = tools.querySelector('.theme-toggle');
  const logo = header.querySelector('.header-logo');
  const items = Array.from(inline.children);
  const measure = inline.cloneNode(true);
  measure.classList.add('nav-measure');
  measure.inert = true;
  measure.setAttribute('aria-hidden', 'true');
  tools.append(measure);
  site.classList.add('enhanced');
  let layoutKey = '';

  function layout() {
    if (window.scrollY <= 2) header.classList.remove('is-compact');
    else if (window.scrollY > 72) header.classList.add('is-compact');
    const bar = tools.getBoundingClientRect();
    const bounds = header.getBoundingClientRect();
    const style = getComputedStyle(tools);
    const gap = parseFloat(style.columnGap) || 0;
    const offset = Math.min(toggle.offsetWidth + 12, Math.max(0, bounds.right - bar.right - 8));
    const reserve = Math.max(0, toggle.offsetWidth + gap - offset);
    tools.style.setProperty('--theme-offset', offset + 'px');
    tools.style.setProperty('--theme-reserve', reserve + 'px');
    tools.style.setProperty('--menu-height', Math.max(0, innerHeight - bounds.height - 12) + 'px');
    logo.style.left = Math.max(1, bar.left - bounds.left - logo.offsetWidth - 12) + 'px';
    const width = tools.clientWidth - reserve;
    const brandWidth = brand.getBoundingClientRect().width;
    const menuWidth = parseFloat(style.getPropertyValue('--menu-width'));
    const widths = Array.from(measure.children, item => item.getBoundingClientRect().width);
    const key = [width, brandWidth, menuWidth, gap, ...widths].join(':');
    if (key === layoutKey) return;
    layoutKey = key;
    const fixedGaps = brandWidth > 0 ? 1 : 0;
    const allWidth = widths.reduce((sum, value) => sum + value, 0) + gap * (widths.length - 1);
    let count = items.length;
    if (allWidth > width - brandWidth - gap * fixedGaps) {
      const room = width - brandWidth - menuWidth - gap * (fixedGaps + 1);
      let used = 0;
      count = 0;
      // Keep the original prefix visible. Only the trailing links move into Menu.
      for (const itemWidth of widths) {
        const next = used + itemWidth + (count ? gap : 0);
        if (next > room) break;
        used = next;
        count++;
      }
    }
    for (const [parent, children] of [[inline, items.slice(0, count)], [extra, items.slice(count)]]) {
      children.forEach((item, index) => {
        if (parent.children[index] !== item) parent.insertBefore(item, parent.children[index] || null);
      });
    }
    inline.hidden = count === 0;
    overflow.hidden = count === items.length;
    if (overflow.hidden) overflow.open = false;
  }
  let pending = false;
  function scheduleLayout() {
    if (pending) return;
    pending = true;
    requestAnimationFrame(() => { pending = false; layout(); });
  }
  const resize = new ResizeObserver(scheduleLayout);
  resize.observe(header);
  resize.observe(tools);
  window.addEventListener('scroll', scheduleLayout, {passive: true});
  window.addEventListener('pageshow', scheduleLayout);
  document.fonts.ready.then(scheduleLayout);
  document.fonts.addEventListener('loadingdone', scheduleLayout);

  function labelTheme() {
    toggle.setAttribute('aria-label', document.documentElement.dataset.theme === 'dark'
      ? 'Activer le mode clair' : 'Activer le mode sombre');
  }
  toggle.addEventListener('click', () => {
    const theme = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
    document.documentElement.dataset.theme = theme;
    try { localStorage.setItem('pontonnier-theme', theme); } catch { /* Storage is optional. */ }
    labelTheme();
  });
  labelTheme();

  const menus = Array.from(header.querySelectorAll('details'));
  for (const menu of menus) {
    menu.addEventListener('toggle', () => {
      if (menu.open) for (const other of menus) {
        if (other !== menu && !other.contains(menu) && !menu.contains(other)) other.open = false;
      }
    });
    menu.addEventListener('keydown', event => {
      if (event.key === 'Escape') {
        event.stopPropagation();
        menu.open = false;
        menu.querySelector('summary').focus();
      }
    });
  }
  document.addEventListener('click', event => {
    for (const menu of menus) if (!menu.contains(event.target)) menu.open = false;
  });

  const backgrounds = JSON.parse(site.dataset.backgrounds);
  let background;
  try { background = sessionStorage.getItem('pontonnier-background'); } catch { /* Storage is optional. */ }
  if (!backgrounds.includes(background)) {
    background = backgrounds[Math.floor(Math.random() * backgrounds.length)];
    try { sessionStorage.setItem('pontonnier-background', background); } catch { /* Storage is optional. */ }
  }
  const mediaRoot = new URL('./', import.meta.url);
  site.querySelector('.river-backdrop').style.backgroundImage = `url(${JSON.stringify(new URL(background, mediaRoot).href)})`;

  // The live app reports its content height; source and origin must both match.
  const frame = site.querySelector('.live-rhonometre');
  if (frame) window.addEventListener('message', event => {
    if (event.source !== frame.contentWindow || event.origin !== new URL(frame.src).origin) return;
    if (event.data?.type !== 'rhonometre:resize') return;
    const height = event.data.height;
    if (Number.isFinite(height) && height >= 100 && height <= 2400) frame.style.height = Math.ceil(height) + 'px';
  });
  layout();
}

const site = document.querySelector('body.site');
if (site) initializeSite(site);
