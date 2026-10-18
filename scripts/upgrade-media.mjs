// Refresh archived originals and WebP mosaic images without putting binaries in this repo.
// Usage: node scripts/upgrade-media.mjs MEDIA_CHECKOUT [CACHED_WORDPRESS_CATALOG]
import {createHash} from 'node:crypto';
import {readFile, writeFile, mkdir, rename} from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import sharp from 'sharp';

const root = fileURLToPath(new URL('../', import.meta.url));
const mediaRoot = process.argv[2] && path.resolve(process.argv[2]);
if (!mediaRoot) throw new Error('Pass a separate pontonnier-media checkout.');
const cache = path.join(os.tmpdir(), 'pontonnier-originals-cache');
await mkdir(cache, {recursive: true});
const checksum = data => createHash('sha256').update(data).digest('hex');
const canonical = value => decodeURIComponent(new URL(value).pathname).normalize('NFC');
const readJSON = async file => JSON.parse(await readFile(file, 'utf8'));
const manifestFile = path.join(root, 'assets/manifest.json');
const previous = await readJSON(manifestFile);
const previousThumbnails = new Map(previous.filter(item => item.derived_from).map(item => [item.path, item]));
const manifest = previous.filter(item => !item.derived_from);
const readImage = async data => {
  const info = await sharp(data, {animated: false}).metadata();
  const rotated = [5, 6, 7, 8].includes(info.orientation);
  return {width: rotated ? (info.pageHeight || info.height) : info.width,
    height: rotated ? info.width : (info.pageHeight || info.height), format: info.format};
};

async function request(url) {
  for (let attempt = 0; ; attempt++) {
    try {
      const response = await fetch(url, {signal: AbortSignal.timeout(60000)});
      if (!response.ok) throw Object.assign(new Error(`HTTP ${response.status}: ${url}`), {status: response.status});
      return response;
    } catch (error) {
      if ([404, 410].includes(error.status) || attempt === 2) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (attempt + 1)));
    }
  }
}

async function catalog() {
  if (process.argv[3]) return readJSON(process.argv[3]);
  const endpoint = 'https://www.pontonniers-geneve.ch/wp-json/wp/v2/media?per_page=100&_fields=id,source_url,media_details,mime_type';
  const first = await request(endpoint);
  const pages = Number(first.headers.get('x-wp-totalpages'));
  const rows = await first.json();
  for (let page = 2; page <= pages; page++) rows.push(...await (await request(endpoint + '&page=' + page)).json());
  return rows;
}
const lookup = new Map();
const sourceNames = new Map();
for (const item of await catalog()) {
  if (!item.mime_type?.startsWith('image/')) continue;
  sourceNames.set(canonical(item.source_url).toLowerCase(), item.source_url);
  for (const url of [item.source_url, ...Object.values(item.media_details?.sizes || {}).map(size => size.source_url)]) {
    if (!url) continue;
    const key = canonical(url);
    if (!lookup.has(key)) lookup.set(key, new Set());
    lookup.get(key).add(item);
  }
}

const downloads = new Map();
async function download(url) {
  if (!downloads.has(url)) downloads.set(url, (async () => {
    const file = path.join(cache, checksum(url) + '.image');
    let data;
    try { data = await readFile(file); } catch (error) { if (error.code !== 'ENOENT') throw error; }
    if (!data) {
      data = Buffer.from(await (await request(url)).arrayBuffer());
      await readImage(data);
      await writeFile(file + '.part', data);
      await rename(file + '.part', file);
    }
    return file;
  })());
  const data = await readFile(await downloads.get(url));
  return {data, source: url, ...await readImage(data)};
}

function candidates(entry) {
  const urls = new Map();
  function add(url, pixels = Infinity, priority = 2) {
    if (!url) return;
    const old = urls.get(url);
    if (!old || priority < old.priority) urls.set(url, {url, pixels, priority});
  }
  for (const item of lookup.get(canonical(entry.source)) || []) {
    const details = item.media_details || {};
    if (details.original_image) add(new URL(details.original_image, item.source_url).href, Infinity, 0);
    add(item.source_url, details.width * details.height || Infinity, 1);
    // WordPress can retain the pre-edit upload without listing original_image.
    const unedited = item.source_url.replace(/-e\d{10,}(?=\.[^.?#]+(?:\?|$))/, '');
    if (unedited !== item.source_url) add(unedited, Infinity, 0);
    const camera = unedited.replace(/-(?:scaled|rotated)(?=\.[^.?#]+(?:\?|$))/, '');
    if (camera !== item.source_url) add(camera, Infinity, 0);
    const uncropped = camera.replace(/\/(?:cropped-)+(?=[^/]+$)/, '/');
    if (uncropped !== camera) add(sourceNames.get(canonical(uncropped).toLowerCase()) || uncropped, Infinity, 0);
    for (const size of Object.values(details.sizes || {})) add(size.source_url, size.width * size.height);
  }
  // Metadata covers the archived WordPress files. Also check unsuffixed names for legacy renditions.
  const full = entry.source.replace(/-\d+x\d+(?=\.[^.?#]+(?:\?|$))/, '');
  if (full !== entry.source) add(full, Infinity, 1);
  const unscaled = full.replace(/-scaled(?=\.[^.?#]+(?:\?|$))/, '');
  if (unscaled !== full) add(unscaled, Infinity, 0);
  return Array.from(urls.values()).sort((a, b) => a.priority - b.priority || b.pixels - a.pixels);
}

const thumbnailJobs = new Map();
function thumbnail(original) {
  const hash = checksum(original.data);
  if (!thumbnailJobs.has(hash)) thumbnailJobs.set(hash, (async () => {
    const file = `assets/thumbnails/${hash.slice(0, 32)}.webp`;
    let existing;
    try { existing = await readFile(path.join(mediaRoot, file)); }
    catch (error) { if (error.code !== 'ENOENT') throw error; }
    if (existing) {
      const info = await readImage(existing);
      const hash = checksum(existing);
      const known = previousThumbnails.get(file);
      if (known && known.sha256 !== hash) throw new Error(`Thumbnail was modified: ${file}`);
      if (existing.length > 128 * 1024 || Math.max(info.width, info.height) > 960) {
        throw new Error(`Thumbnail exceeds the mosaic budget: ${file}`);
      }
      return {path: file, bytes: existing.length, sha256: hash,
        width: info.width, height: info.height, source: original.source,
        ...(known?.decode_warning ? {decode_warning: known.decode_warning} : {})};
    }
    let edge = 960, quality = 82, result, truncated = false;
    for (;;) {
      try {
        result = await sharp(original.data, {animated: false, failOn: truncated ? 'none' : 'warning'}).rotate()
          .resize({width: edge, height: edge, fit: 'inside', withoutEnlargement: true})
          .webp({quality, effort: 4}).toBuffer({resolveWithObject: true});
      } catch (error) {
        // Some legacy progressive JPEGs lack their final scan. Browsers still display them.
        // Keep its source bytes intact; only the small rendition uses tolerant decoding.
        if (!truncated && original.format === 'jpeg' && /premature end of JPEG/.test(error.message)) {
          truncated = true;
          continue;
        }
        throw error;
      }
      if (result.data.length <= 128 * 1024) break;
      if (quality > 58) quality -= 6;
      else edge = Math.floor(edge * .85);
    }
    await mkdir(path.dirname(path.join(mediaRoot, file)), {recursive: true});
    await writeFile(path.join(mediaRoot, file), result.data);
    return {path: file, bytes: result.data.length, sha256: checksum(result.data),
      width: result.info.width, height: result.info.height, source: original.source,
      ...(truncated ? {decode_warning: 'Legacy source JPEG has an incomplete final scan; original bytes are preserved.'} : {})};
  })());
  return thumbnailJobs.get(hash);
}

let next = 0, complete = 0, upgraded = 0;
const images = manifest.filter(entry => entry.width && entry.height);
const audit = Array(images.length);
const derivatives = new Map();
const unresolved = [];
async function worker() {
  while (next < images.length) {
    const index = next++, entry = images[index];
    const localFile = path.join(mediaRoot, entry.path);
    const data = await readFile(localFile);
    if (checksum(data) !== entry.sha256) throw new Error(`Existing media checksum differs: ${entry.path}`);
    const actual = await readImage(data);
    entry.width = actual.width;
    entry.height = actual.height;
    const options = candidates(entry);
    let best = {data, source: entry.source, ...actual,
      priority: options.find(item => item.url === entry.source)?.priority ?? 3};
    // Never downgrade an original already archived if the source site later removes it.
    if (entry.original) {
      const archived = await readFile(path.join(mediaRoot, entry.original.path));
      if (checksum(archived) !== entry.original.sha256) throw new Error(`Original checksum differs: ${entry.original.path}`);
      const info = await readImage(archived);
      if (info.width * info.height >= best.width * best.height) {
        best = {data: archived, source: entry.original.source, ...info,
          priority: options.find(item => item.url === entry.original.source)?.priority ?? 0};
      }
    }
    const unavailable = [];
    for (const candidate of options) {
      const bestPixels = best.width * best.height;
      if (candidate.pixels < bestPixels
        || (candidate.pixels === bestPixels && candidate.priority >= best.priority)) continue;
      try {
        const image = await download(candidate.url);
        const pixels = image.width * image.height;
        if (pixels > bestPixels || (pixels === bestPixels && candidate.priority < best.priority)) best = {...image, priority: candidate.priority};
      } catch (error) {
        unavailable.push({url: candidate.url, status: error.status || String(error.message)});
        if (![404, 410].includes(error.status)) unresolved.push({file: entry.path, source: candidate.url, error: String(error.message)});
      }
    }
    const hash = checksum(best.data);
    let originalPath = entry.path;
    if (hash !== entry.sha256) {
      const extension = {jpeg: 'jpg', png: 'png', gif: 'gif', webp: 'webp', avif: 'avif'}[best.format];
      if (!extension) throw new Error(`Unsupported original format ${best.format}: ${best.source}`);
      if (best.data.length >= 100 * 1024 ** 2) throw new Error(`Original exceeds Git's per-file limit: ${best.source}`);
      originalPath = `originals/${hash}.${extension}`;
      await mkdir(path.join(mediaRoot, 'originals'), {recursive: true});
      await writeFile(path.join(mediaRoot, originalPath), best.data);
      entry.original = {path: originalPath, source: best.source, bytes: best.data.length,
        sha256: hash, width: best.width, height: best.height};
      upgraded++;
    } else delete entry.original;
    let small;
    try { small = await thumbnail(best); }
    catch (error) { throw new Error(`Cannot render ${entry.path} from ${best.source}: ${error.message}`); }
    entry.thumbnail = small.path;
    if (!derivatives.has(small.path) || entry.path < derivatives.get(small.path).derived_from) {
      derivatives.set(small.path, {...small, source: best.source, derived_from: entry.path});
    }
    audit[index] = {file: entry.path, source: best.source, path: originalPath, sha256: hash,
      width: best.width, height: best.height, bytes: best.data.length,
      previousWidth: actual.width, previousHeight: actual.height, unavailable,
      ...(small.decode_warning ? {decode_warning: small.decode_warning} : {})};
    complete++;
    if (complete % 25 === 0 || complete === images.length) console.log(`${complete}/${images.length} images; ${upgraded} upgraded originals; ${derivatives.size} thumbnails`);
  }
}
await Promise.all(Array.from({length: 3}, worker));
await mkdir(path.join(mediaRoot, 'originals'), {recursive: true});
await writeFile(path.join(mediaRoot, 'originals/manifest.json'), JSON.stringify(audit, null, 2) + '\n');
await writeFile(path.join(cache, 'unresolved.json'), JSON.stringify(unresolved, null, 2) + '\n');
if (unresolved.length) throw new Error(`${unresolved.length} requests need retry; see ${path.join(cache, 'unresolved.json')}. Source manifest has not been updated.`);
await writeFile(manifestFile, JSON.stringify([...manifest, ...Array.from(derivatives.values()).sort((a, b) => a.path.localeCompare(b.path))], null, 2) + '\n');
const unique = new Map(audit.map(item => [item.path, item.bytes]));
console.log(JSON.stringify({images: images.length, upgraded, originalBytes: Array.from(unique.values()).reduce((a, b) => a + b, 0),
  thumbnails: derivatives.size, thumbnailBytes: Array.from(derivatives.values()).reduce((sum, item) => sum + item.bytes, 0),
  unavailableCandidates: audit.reduce((sum, item) => sum + item.unavailable.length, 0)}, null, 2));
