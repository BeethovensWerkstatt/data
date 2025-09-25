/**
 * annotate-svg-bboxes.js
 *
 * Purpose:
 *   Annotates every <path> element in every SVG file in a folder (recursively) with a @data-bbox attribute containing its bounding box (x,y,w,h).
 *   This enables downstream MEI/XML enrichment or visualization workflows to access precomputed bounding boxes for notehead or other shapes.
 *
 * Runtime Requirements:
 *   - Node.js v16 or newer (recommended for ES modules and fs/promises support)
 *   - npm install jsdom (run `npm install jsdom` in the script directory)
 *
 * Usage:
 *   node annotate-svg-bboxes.js [svgRootFolder]
 *   - If no folder is provided, defaults to '../../data/sources' relative to this script.
 *   - Example: node annotate-svg-bboxes.js /absolute/path/to/svg/folder
 *
 * Output:
 *   Each SVG file is overwritten in-place, with every <path> element annotated with a data-bbox="x,y,w,h" attribute.
 *   Progress and errors are logged to the console.
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { JSDOM } from 'jsdom';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Usage: node annotate-svg-bboxes.js [svgRootFolder]
const svgRoot = process.argv[2] || path.resolve(__dirname, '../../data/sources');

function findAllSVGFiles(rootDir) {
  const files = [];
  const stack = [rootDir];
  while (stack.length) {
    const dir = stack.pop();
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (entry.isDirectory()) {
        stack.push(path.join(dir, entry.name));
      } else if (entry.isFile() && entry.name.endsWith('.svg')) {
        files.push(path.join(dir, entry.name));
      }
    }
  }
  return files;
}

function getPathBBox(d) {
  // Minimal SVG path bbox calculation (M/L/H/V/C/Q/S/T/Z)
  // Only supports absolute commands for simplicity
  let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
  let x = 0, y = 0;
  let lastCmd = '';
  const tokens = d.match(/[a-zA-Z]|-?\d*\.?\d+(?:e[-+]?\d+)?/g);
  if (!tokens) return null;
  let i = 0;
    while (i < tokens.length) {
    const token = tokens[i];
    if (/^[a-zA-Z]$/.test(token)) {
      lastCmd = token;
      i++;
      continue;
    }
    switch (lastCmd) {
      case 'M':
      case 'L':
      case 'T': {
        const nx = parseFloat(tokens[i]);
        const ny = parseFloat(tokens[i + 1]);
        x = nx; y = ny;
        minX = Math.min(minX, x);
        minY = Math.min(minY, y);
        maxX = Math.max(maxX, x);
        maxY = Math.max(maxY, y);
        i += 2;
        break;
      }
      case 'H': {
        x = parseFloat(tokens[i]);
        minX = Math.min(minX, x);
        maxX = Math.max(maxX, x);
        i++;
        break;
      }
      case 'V': {
        y = parseFloat(tokens[i]);
        minY = Math.min(minY, y);
        maxY = Math.max(maxY, y);
        i++;
        break;
      }
      case 'C': {
        for (let j = 0; j < 6; j += 2) {
          const nx = parseFloat(tokens[i + j]);
          const ny = parseFloat(tokens[i + j + 1]);
          minX = Math.min(minX, nx);
          minY = Math.min(minY, ny);
          maxX = Math.max(maxX, nx);
          maxY = Math.max(maxY, ny);
        }
        x = parseFloat(tokens[i + 4]);
        y = parseFloat(tokens[i + 5]);
        i += 6;
        break;
      }
      case 'Q':
      case 'S': {
        for (let j = 0; j < 4; j += 2) {
          const nx = parseFloat(tokens[i + j]);
          const ny = parseFloat(tokens[i + j + 1]);
          minX = Math.min(minX, nx);
          minY = Math.min(minY, ny);
          maxX = Math.max(maxX, nx);
          maxY = Math.max(maxY, ny);
        }
        x = parseFloat(tokens[i + 2]);
        y = parseFloat(tokens[i + 3]);
        i += 4;
        break;
      }
      case 'Z':
      case 'z': {
        i++;
        break;
      }
      default: {
        i++;
        break;
      }
    }
  }
  if (minX < Infinity && minY < Infinity && maxX > -Infinity && maxY > -Infinity) {
      return { 
        x: Math.round(minX * 10) / 10, 
        y: Math.round(minY * 10) / 10, 
        w: Math.round((maxX - minX) * 10) / 10, 
        h: Math.round((maxY - minY) * 10) / 10 
      };
  }
  return null;
}

async function annotateSVGFile(svgFile) {
  try {
    const svgXml = fs.readFileSync(svgFile, 'utf8');
    const dom = new JSDOM(svgXml, { contentType: 'image/svg+xml' });
    const doc = dom.window.document;
    const paths = Array.from(doc.querySelectorAll('path[d]'));
    let changed = false;
    for (const pathEl of paths) {
      const d = pathEl.getAttribute('d');
      if (!d) continue;
      const bbox = getPathBBox(d);
      if (bbox) {
        pathEl.setAttribute('data-bbox', `${bbox.x},${bbox.y},${bbox.w},${bbox.h}`);
        changed = true;
      }
    }
    if (changed) {
      const serializer = new dom.window.XMLSerializer();
      const updatedXml = serializer.serializeToString(doc);
      fs.writeFileSync(svgFile, updatedXml, 'utf8');
      console.log(`Annotated ${paths.length} paths in ${svgFile}`);
    }
  } catch (err) {
    console.error(`Error processing ${svgFile}: ${err.message}`);
  }
}

async function main() {
  const svgFiles = findAllSVGFiles(svgRoot);
  console.log(`Found ${svgFiles.length} SVG files in ${svgRoot}`);
  for (let i = 0; i < svgFiles.length; i++) {
    await annotateSVGFile(svgFiles[i]);
    if ((i + 1) % 10 === 0) {
      console.log(`Processed ${i + 1} SVG files...`);
    }
  }
  console.log('All SVG files processed.');
}

main();
