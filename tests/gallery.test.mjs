import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import test from 'node:test';
import {mosaic} from '../assets/gallery.mjs';

const manifest = JSON.parse(readFileSync(new URL('../assets/manifest.json', import.meta.url)));
const samples = [
  [],
  [{width: 750, height: 1000}],
  Array.from({length: 17}, () => ({width: 750, height: 1000})),
  Array.from({length: 12}, () => ({width: 1500, height: 1000})),
  manifest.filter(item => item.width && item.height).slice(0, 180),
];

for (const width of [288, 640, 940]) {
  test(`mosaic keeps every photo uncropped and separated at ${width}px`, () => {
    for (const items of samples) {
      const {boxes, height} = mosaic(items, width);
      const gap = width < 520 ? 6 : 8;
      assert.equal(boxes.length, items.length);
      if (!items.length) {
        assert.equal(height, 0);
        continue;
      }
      assert.ok(Math.abs(Math.max(...boxes.map(box => box.left + box.width)) - width) < 1e-8);
      assert.ok(Math.abs(Math.max(...boxes.map(box => box.top + box.height)) - height) < 1e-8);
      for (const [index, box] of boxes.entries()) {
        assert.ok(box.width > 0 && box.height > 0);
        assert.ok(Math.abs(box.width / box.height - items[index].width / items[index].height) < 1e-8);
        assert.ok(box.left >= 0 && box.top >= 0);
        assert.ok(box.left + box.width <= width + 1e-8);
        assert.ok(box.top + box.height <= height + 1e-8);
        for (const other of boxes.slice(index + 1)) {
          const dx = Math.max(other.left - box.left - box.width, box.left - other.left - other.width);
          const dy = Math.max(other.top - box.top - box.height, box.top - other.top - other.height);
          assert.ok(dx >= gap - 1e-8 || dy >= gap - 1e-8);
        }
      }
    }
  });
}
