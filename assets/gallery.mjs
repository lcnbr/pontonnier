// Each band combines single photos with pairs stacked at equal width.
// Adding aspect ratios across, or their reciprocals down, makes every
// band rectangular without changing any photo's proportions.
export function mosaic(items, width) {
  if (!items.length || width <= 0) return {boxes: [], height: 0};
  const ratios = items.map(photo => photo.width / photo.height);
  const compact = width < 520;
  const gap = compact ? 6 : 8;
  const targetHeight = width * (compact ? 0.72 : 0.43);
  const maxColumns = compact ? 2 : 4;
  const best = Array(items.length + 1).fill(Infinity);
  const next = Array(items.length);
  best[items.length] = 0;
  for (let start = items.length - 1; start >= 0; start--) {
    function consider(end, columns) {
      if (columns.length) {
        const sum = columns.reduce((value, column) => value + column.ratio, 0);
        const stackGaps = columns.reduce((value, column) => value + (column.indices.length - 1) * gap * column.ratio, 0);
        const height = (width - (columns.length - 1) * gap + stackGaps) / sum;
        const sizes = columns.flatMap(column => column.indices.map(index => ({
          width: (height - (column.indices.length - 1) * gap) * column.ratio,
          height: (height - (column.indices.length - 1) * gap) * column.ratio / ratios[index]
        })));
        const smallest = Math.min(...sizes.map(size => Math.min(size.width, size.height)));
        const single = columns.some(column => column.indices.length === 1);
        const stacked = columns.some(column => column.indices.length === 2);
        const mixed = single && stacked;
        const balance = (height / targetHeight - 1) ** 2 * 3;
        const tooSmall = Math.max(0, (compact ? 78 : 105) / smallest - 1) ** 2 * 12;
        const lonely = end - start === 1 && items.length > 1 ? 3 : 0;
        const score = (balance + tooSmall + lonely + (mixed ? 0 : 0.35)) * (end - start) + best[end];
        if (score < best[start]) {
          best[start] = score;
          next[start] = {end, columns, height};
        }
      }
      if (columns.length === maxColumns) return;
      for (let count = 1; count <= 2 && end + count <= items.length; count++) {
        const indices = Array.from({length: count}, (_, i) => end + i);
        const ratio = 1 / indices.reduce((sum, index) => sum + 1 / ratios[index], 0);
        consider(end + count, columns.concat({indices, ratio}));
      }
    }
    consider(start, []);
  }
  const boxes = Array(items.length);
  let top = 0;
  for (let start = 0; start < items.length;) {
    const band = next[start];
    let left = 0;
    for (const column of band.columns) {
      const columnWidth = (band.height - (column.indices.length - 1) * gap) * column.ratio;
      let y = top;
      for (const index of column.indices) {
        const height = columnWidth / ratios[index];
        boxes[index] = {left, top: y, width: columnWidth, height};
        y += height + gap;
      }
      left += columnWidth + gap;
    }
    top += band.height + gap;
    start = band.end;
  }
  return {boxes, height: top - gap};
}

function initializeGallery(main) {
  const content = main.querySelector('.entry-content');
  const viewer = main.querySelector('.photo-viewer');
  const items = Array.from(content.querySelectorAll('.photo.gallery-photo')).map(figure => {
    const anchor = figure.querySelector('a');
    const image = anchor?.querySelector('img');
    const groupCaption = figure.closest('.gallery')?.nextElementSibling;
    return {
      figure, anchor, image,
      width: Number(image?.getAttribute('width')),
      height: Number(image?.getAttribute('height')),
      caption: figure.querySelector('figcaption') || (groupCaption?.matches('.gallery-caption') ? groupCaption : null)
    };
  }).filter(item => item.image && item.width > 0 && item.height > 0);
  if (!items.length && !content.querySelector('.album-events')) return;
  let sequence = items;
  const itemByFigure = new Map(items.map(item => [item.figure, item]));
  const layouts = new Map();
  for (const gallery of content.querySelectorAll('.gallery')) {
    const figures = Array.from(gallery.children).filter(child => child.matches('figure'));
    if (figures.length && figures.every(figure => itemByFigure.has(figure))) {
      layouts.set(gallery, {items: figures.map(figure => itemByFigure.get(figure)), width: 0});
    }
  }
  function layout(gallery) {
    const state = layouts.get(gallery);
    const width = gallery.clientWidth;
    if (!width || state.width === width) return;
    const plan = mosaic(state.items, width);
    gallery.classList.add('is-mosaic');
    gallery.style.height = plan.height + 'px';
    state.items.forEach((item, index) => {
      for (const key of ['left', 'top', 'width', 'height']) {
        item.figure.style[key] = plan.boxes[index][key] + 'px';
      }
    });
    state.width = width;
  }
  const resize = new ResizeObserver(entries => entries.forEach(entry => layout(entry.target)));
  for (const gallery of layouts.keys()) {
    layout(gallery);
    resize.observe(gallery);
  }

  const viewport = viewer.querySelector('.pg-image-viewport');
  const viewerImage = document.createElement('img');
  viewerImage.className = 'pg-viewer-image';
  viewerImage.draggable = false;
  viewport.append(viewerImage);
  const viewerCount = viewer.querySelector('.pg-viewer-count');
  const viewerCaption = viewer.querySelector('.pg-viewer-caption');
  const closeButton = viewer.querySelector('.pg-viewer-close');
  const zoomIn = viewer.querySelector('.pg-zoom-in');
  const zoomOut = viewer.querySelector('.pg-zoom-out');
  const zoomReset = viewer.querySelector('.pg-zoom-reset');
  let activePhoto = null;
  let opener = null;
  let originScroll = 0;
  let swipeStart = null;
  let zoom = 1;
  let offset = {x: 0, y: 0};
  let photoRatio = 1;
  const pointers = new Map();

  function paintZoom() {
    const width = viewport.clientWidth;
    const height = viewport.clientHeight;
    const fittedWidth = Math.min(width, height * photoRatio);
    const fittedHeight = fittedWidth / photoRatio;
    const maxX = Math.max(0, (fittedWidth * zoom - width) / 2);
    const maxY = Math.max(0, (fittedHeight * zoom - height) / 2);
    offset.x = Math.max(-maxX, Math.min(maxX, offset.x));
    offset.y = Math.max(-maxY, Math.min(maxY, offset.y));
    viewerImage.style.transform = `translate(${offset.x}px, ${offset.y}px) scale(${zoom})`;
    zoomReset.textContent = Math.round(zoom * 100) + "%";
    zoomOut.disabled = zoom <= 1;
    zoomIn.disabled = zoom >= 5;
    viewport.classList.toggle("is-zoomed", zoom > 1);
    viewport.classList.toggle("is-dragging", zoom > 1 && pointers.size > 0);
  }

  function resetZoom() {
    zoom = 1;
    offset = {x: 0, y: 0};
    pointers.clear();
    swipeStart = null;
    paintZoom();
  }

  function relativePoint(point) {
    const bounds = viewport.getBoundingClientRect();
    return {x: point.x - bounds.left - bounds.width / 2, y: point.y - bounds.top - bounds.height / 2};
  }

  function changeZoom(value, point = {x: 0, y: 0}, previousPoint = point) {
    const next = Math.max(1, Math.min(5, value));
    const factor = next / zoom;
    offset.x = point.x - (previousPoint.x - offset.x) * factor;
    offset.y = point.y - (previousPoint.y - offset.y) * factor;
    zoom = next;
    paintZoom();
  }

  zoomIn.addEventListener("click", () => changeZoom(zoom * 1.5));
  zoomOut.addEventListener("click", () => changeZoom(zoom / 1.5));
  zoomReset.addEventListener("click", resetZoom);
  viewport.addEventListener("wheel", event => {
    if (activePhoto === null) return;
    event.preventDefault();
    const unit = event.deltaMode === 1 ? 16 : event.deltaMode === 2 ? viewport.clientHeight : 1;
    const delta = Math.max(-200, Math.min(200, event.deltaY * unit));
    changeZoom(zoom * Math.exp(-delta * 0.003), relativePoint({x: event.clientX, y: event.clientY}));
  }, {passive: false});
  viewport.addEventListener("dblclick", event => {
    event.preventDefault();
    if (zoom > 1) resetZoom();
    else changeZoom(2.5, relativePoint({x: event.clientX, y: event.clientY}));
  });

  function pinchGeometry() {
    const [first, second] = Array.from(pointers.values());
    return {
      center: relativePoint({x: (first.x + second.x) / 2, y: (first.y + second.y) / 2}),
      distance: Math.hypot(first.x - second.x, first.y - second.y)
    };
  }

  viewport.addEventListener("pointerdown", event => {
    if (event.button !== 0 || activePhoto === null || pointers.size >= 2) return;
    event.preventDefault();
    zoomReset.focus({preventScroll: true});
    const point = {x: event.clientX, y: event.clientY};
    pointers.set(event.pointerId, point);
    viewport.setPointerCapture(event.pointerId);
    swipeStart = pointers.size === 1 && zoom === 1 && event.pointerType !== "mouse" ? point : null;
    paintZoom();
  });
  viewport.addEventListener("pointermove", event => {
    const previous = pointers.get(event.pointerId);
    if (!previous) return;
    const before = pointers.size === 2 ? pinchGeometry() : null;
    pointers.set(event.pointerId, {x: event.clientX, y: event.clientY});
    if (before) {
      const after = pinchGeometry();
      if (before.distance > 0) changeZoom(zoom * after.distance / before.distance, after.center, before.center);
    } else if (zoom > 1) {
      offset.x += event.clientX - previous.x;
      offset.y += event.clientY - previous.y;
      paintZoom();
    }
  });

  function endPointer(event) {
    if (!pointers.has(event.pointerId)) return;
    pointers.delete(event.pointerId);
    if (event.type === "pointerup" && swipeStart && zoom === 1 && pointers.size === 0) {
      const dx = event.clientX - swipeStart.x;
      const dy = event.clientY - swipeStart.y;
      if (Math.abs(dx) > 45 && Math.abs(dx) > Math.abs(dy) * 1.25) showPhoto(activePhoto + (dx < 0 ? 1 : -1));
    }
    swipeStart = null;
    paintZoom();
  }
  viewport.addEventListener("pointerup", endPointer);
  viewport.addEventListener("pointercancel", endPointer);
  viewport.addEventListener("lostpointercapture", endPointer);
  new ResizeObserver(() => { if (viewer.open) paintZoom(); }).observe(viewport);

  function showPhoto(index) {
    activePhoto = (index + sequence.length) % sequence.length;
    const item = sequence[activePhoto];
    viewerImage.src = item.anchor.href;
    viewerImage.alt = item.image.alt;
    photoRatio = item.width / item.height;
    if (!viewer.open) {
      document.documentElement.classList.add('photo-viewer-open');
      viewer.showModal();
    }
    resetZoom();
    viewerCount.textContent = (activePhoto + 1) + ' / ' + sequence.length;
    // Captions are authored content, never the automatically numbered alt text.
    viewerCaption.replaceChildren(...(item.caption ? Array.from(item.caption.childNodes, node => node.cloneNode(true)) : []));
    viewerCaption.hidden = !item.caption;
    for (const step of [-1, 1]) {
      const preload = new Image();
      preload.src = sequence[(activePhoto + step + sequence.length) % sequence.length].anchor.href;
    }
  }
  function closePhoto(restorePosition = true) {
    activePhoto = null;
    resetZoom();
    if (viewer.open) viewer.close();
    document.documentElement.classList.remove('photo-viewer-open');
    for (const gallery of layouts.keys()) layout(gallery);
    if (restorePosition) {
      opener?.focus({preventScroll: true});
      window.scrollTo({top: originScroll, behavior: 'instant'});
    }
  }
  items.forEach(item => item.anchor.addEventListener('click', event => {
    if (event.button !== 0 || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
    event.preventDefault();
    opener = item.anchor;
    originScroll = window.scrollY;
    sequence = items.filter(photo => !photo.figure.closest('.album-event')?.hidden);
    showPhoto(sequence.indexOf(item));
    closeButton.focus({preventScroll: true});
  }));
  closeButton.addEventListener('click', () => closePhoto());
  viewer.addEventListener('cancel', event => {
    event.preventDefault();
    closePhoto();
  });
  viewer.addEventListener('close', () => {
    if (activePhoto !== null && !viewer.open) closePhoto();
  });
  viewer.querySelector('.pg-photo-prev').addEventListener('click', () => showPhoto(activePhoto - 1));
  viewer.querySelector('.pg-photo-next').addEventListener('click', () => showPhoto(activePhoto + 1));
  main.addEventListener('keydown', event => {
    if (activePhoto === null || event.ctrlKey || event.metaKey || event.altKey) return;
    if (['+', '=', '-', '0', 'ArrowLeft', 'ArrowRight', 'Escape'].includes(event.key)) {
      event.preventDefault();
      if (event.key === 'Escape') closePhoto();
      else if (event.key === '0') resetZoom();
      else if (event.key.startsWith('Arrow')) showPhoto(activePhoto + (event.key === 'ArrowRight' ? 1 : -1));
      else changeZoom(zoom * (event.key === '-' ? 1 / 1.5 : 1.5));
    }
  });
  const events = Array.from(content.querySelectorAll('.album-event'));
  const eventContainer = content.querySelector('.album-events');
  const overview = content.querySelector('.album-overview');
  const title = main.querySelector('.entry-title');
  const albumTitle = title.textContent;
  const parent = main.querySelector('.album-parent');

  function displayAlbum(scroll = false) {
    if (!eventContainer) return;
    if (activePhoto !== null) closePhoto(false);
    let hash = '';
    try { hash = decodeURIComponent(location.hash.slice(1)); } catch { /* Invalid fragments show the album overview. */ }
    const target = document.getElementById(hash);
    const event = target?.closest('.album-event');
    const all = hash === 'all-photos' || events.length === 1;
    if (overview) overview.hidden = !!event || all;
    eventContainer.hidden = !event && !all;
    for (const section of events) {
      section.hidden = !all && section !== event;
      section.classList.toggle('is-selected', section === event || events.length === 1);
      if (section.hidden) for (const video of section.querySelectorAll('video')) video.pause();
    }
    if (event) title.replaceChildren(...Array.from(event.querySelector('.event-title').childNodes, node => node.cloneNode(true)));
    else title.textContent = albumTitle;
    if (parent) parent.hidden = (!event && !all) || events.length === 1;
    for (const gallery of layouts.keys()) layout(gallery);
    if (scroll) {
      (parent && !parent.hidden ? parent.querySelector('a') : main.querySelector('.album-breadcrumb a'))?.focus({preventScroll: true});
      main.scrollIntoView({block: 'start', behavior: 'instant'});
    }
  }
  window.addEventListener('hashchange', () => displayAlbum(true));
  displayAlbum();
}

if (typeof document !== 'undefined') {
  const menus = Array.from(document.querySelectorAll('.menu details'));
  for (const menu of menus) {
    menu.addEventListener('toggle', () => {
      if (menu.open) for (const other of menus) if (other !== menu) other.open = false;
    });
    menu.addEventListener('keydown', event => {
      if (event.key === 'Escape') {
        menu.open = false;
        menu.querySelector('summary').focus();
      }
    });
  }
  document.addEventListener('click', event => {
    for (const menu of menus) if (!menu.contains(event.target)) menu.open = false;
  });
  for (const main of document.querySelectorAll('.gallery-page')) initializeGallery(main);
}
