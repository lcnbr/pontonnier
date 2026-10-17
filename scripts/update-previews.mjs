// Run after fetching the pinned media checkout. No originals are modified.
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {readFile, writeFile, mkdir} from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import sharp from 'sharp';

const root = fileURLToPath(new URL('../', import.meta.url));
process.chdir(root);
const readJSON = async file => JSON.parse(await readFile(file, 'utf8'));
const limits = await readJSON('preview/limits.json');
const manifest = await readJSON('assets/manifest.json');
const previous = await readJSON('preview/manifest.json');
const pinned = (await readFile('.media-revision', 'utf8')).trim();
const revision = execFileSync('git', ['-C', '.media', 'rev-parse', 'HEAD'], {encoding: 'utf8'}).trim();
if (revision !== pinned) throw new Error('Run bash scripts/fetch-media.sh before refreshing previews.');
const sources = JSON.parse(execFileSync(process.env.PYTHON || 'python3', ['scripts/check-preview.py', '--inventory'], {encoding: 'utf8'}));
const checksum = data => createHash('sha256').update(data).digest('hex');
const groups = new Map();
for (const source of sources) {
  const entry = manifest.find(item => item.path === source);
  if (!entry?.width || !entry?.height) throw new Error(`Missing image dimensions: ${source}`);
  if (!groups.has(entry.sha256)) groups.set(entry.sha256, []);
  groups.get(entry.sha256).push(entry);
}

const outputs = [];
const usedFiles = new Set();
for (const [hash, group] of groups) {
  const old = previous.find(item => group.some(source => item.sources.includes(source.path.slice('assets/'.length))));
  const source = group.find(item => item.path === old?.source) || group[0];
  const original = await readFile(path.join('.media', source.path));
  if (checksum(original) !== hash) throw new Error(`Media checksum mismatch: ${source.path}`);
  let width = limits.width, height = limits.height, quality = limits.jpeg_quality, result;
  for (;;) {
    result = await sharp(original, {animated: false}).rotate()
      .resize({width, height, fit: 'inside', withoutEnlargement: true})
      .flatten({background: '#ffffff'})
      .jpeg({quality, mozjpeg: true}).toBuffer({resolveWithObject: true});
    if (result.data.length <= limits.max_image_bytes) break;
    if (quality > 54) quality -= 8;
    else { width = Math.floor(width * .85); height = Math.floor(height * .85); }
    if (width < 160) throw new Error(`Unable to fit preview budget: ${source.path}`);
  }
  const stem = path.basename(source.path, path.extname(source.path)).replace(/[^a-zA-Z0-9_-]+/g, '-').slice(0, 60);
  const file = old && !usedFiles.has(old.file) ? old.file : `preview/${stem}-${hash.slice(0, 8)}.jpg`;
  if (usedFiles.has(file)) throw new Error(`Duplicate preview output: ${file}`);
  usedFiles.add(file);
  if (path.dirname(file) !== 'preview' || path.extname(file) !== '.jpg') throw new Error(`Invalid managed preview path: ${file}`);
  const aliases = manifest.filter(item => item.sha256 === hash).map(item => item.path.slice('assets/'.length));
  outputs.push({data: result.data, entry: {
    file, sources: aliases, width: result.info.width, height: result.info.height,
    bytes: result.data.length, sha256: checksum(result.data),
    source: source.path, source_sha256: hash
  }});
}
const total = outputs.reduce((sum, output) => sum + output.data.length, 0);
if (outputs.length > limits.max_images || total > limits.max_total_bytes) {
  throw new Error(`Preview budget exceeded: ${outputs.length} images, ${total} bytes`);
}
// Validate the complete new set before writing any generated file.
await mkdir('preview', {recursive: true});
for (const output of outputs) await writeFile(output.entry.file, output.data);
await writeFile('preview/manifest.json', JSON.stringify(outputs.map(output => output.entry), null, 2) + '\n');
console.log(`Updated ${outputs.length} previews covering ${sources.length} regular-page image paths (${total.toLocaleString()} bytes).`);
