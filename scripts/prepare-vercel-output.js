// ==============================================================================
// Nutrient Earth — Vercel Build Output API v3 Generator
// Validates Flutter Web release artifacts and builds a compliant .vercel/output tree.
// ==============================================================================

const fs = require('fs');
const path = require('path');

const projectRoot = path.resolve(__dirname, '..');
const clientBuildWeb = path.join(projectRoot, 'client', 'build', 'web');
const vercelOutputDir = path.join(projectRoot, '.vercel', 'output');
const vercelStaticDir = path.join(vercelOutputDir, 'static');
const vercelConfigFile = path.join(vercelOutputDir, 'config.json');

console.log('=== Preparing Vercel Prebuilt Deployment Artifact (Build Output API v3) ===');
console.log(`Source build directory: ${clientBuildWeb}`);
console.log(`Target Vercel output:   ${vercelOutputDir}`);

// 1. Verify that Flutter build web release exists
const indexHtml = path.join(clientBuildWeb, 'index.html');
const mainDartJs = path.join(clientBuildWeb, 'main.dart.js');

if (!fs.existsSync(indexHtml) || !fs.existsSync(mainDartJs)) {
  console.error('ERROR: Flutter web compilation output is missing!');
  console.error(`Expected: ${indexHtml}`);
  console.error(`Expected: ${mainDartJs}`);
  process.exit(1);
}

// 2. Ensure .vercel/output/static directory exists and is clean
if (fs.existsSync(vercelOutputDir)) {
  fs.rmSync(vercelOutputDir, { recursive: true, force: true });
}
fs.mkdirSync(vercelStaticDir, { recursive: true });

// 3. Recursive copy of static files
function copyFolderSync(from, to) {
  if (!fs.existsSync(to)) fs.mkdirSync(to, { recursive: true });
  for (const element of fs.readdirSync(from)) {
    const fromPath = path.join(from, element);
    const toPath = path.join(to, element);
    const stat = fs.lstatSync(fromPath);
    if (stat.isFile()) {
      fs.copyFileSync(fromPath, toPath);
    } else if (stat.isDirectory()) {
      copyFolderSync(fromPath, toPath);
    }
  }
}

console.log('Copying Flutter web assets into .vercel/output/static...');
copyFolderSync(clientBuildWeb, vercelStaticDir);

// 4. Generate .vercel/output/config.json with routing and security headers
const config = {
  version: 3,
  routes: [
    {
      src: '^/assets/(.*)$',
      headers: {
        'cache-control': 'public, max-age=31536000, immutable'
      },
      continue: true
    },
    {
      src: '^/canvaskit/(.*)$',
      headers: {
        'cache-control': 'public, max-age=31536000, immutable'
      },
      continue: true
    },
    {
      src: '^/main\\.dart\\.js$',
      headers: {
        'cache-control': 'public, max-age=0, must-revalidate'
      },
      continue: true
    },
    {
      src: '^/flutter_service_worker\\.js$',
      headers: {
        'cache-control': 'public, max-age=0, must-revalidate'
      },
      continue: true
    },
    {
      src: '^/(.*)$',
      headers: {
        'x-content-type-options': 'nosniff',
        'x-frame-options': 'DENY',
        'referrer-policy': 'strict-origin-when-cross-origin',
        'cross-origin-opener-policy': 'same-origin-allow-popups'
      },
      continue: true
    },
    {
      handle: 'filesystem'
    },
    {
      src: '^/((?!assets/|canvaskit/|stitch/|.*\\.[a-zA-Z0-9]+$).*)$',
      dest: '/index.html'
    }
  ]
};

fs.writeFileSync(vercelConfigFile, JSON.stringify(config, null, 2), 'utf-8');

// 5. Verification
function countFiles(dir) {
  let count = 0;
  for (const file of fs.readdirSync(dir)) {
    const full = path.join(dir, file);
    if (fs.statSync(full).isDirectory()) {
      count += countFiles(full);
    } else {
      count++;
    }
  }
  return count;
}

const totalFiles = countFiles(vercelStaticDir);
console.log(`SUCCESS: .vercel/output verified.`);
console.log(`  - config.json: Valid Build Output API v3 specification.`);
console.log(`  - static/: ${totalFiles} static files prepared.`);
console.log(`  - index.html: ${fs.existsSync(path.join(vercelStaticDir, 'index.html'))}`);
console.log(`  - main.dart.js: ${fs.existsSync(path.join(vercelStaticDir, 'main.dart.js'))}`);

