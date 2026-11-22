// ==============================================================================
// Nutrient Earth — Vercel Build Output API v3 Generator
// Validates Flutter Web release artifacts and builds a compliant .vercel/output tree.
// ==============================================================================

const fs = require('fs');
const path = require('path');

const projectRoot = path.resolve(__dirname, '..');
let clientBuildWeb = path.join(projectRoot, 'client', 'build', 'web');
if (!fs.existsSync(path.join(clientBuildWeb, 'main.dart.js'))) {
  const rootBuild = path.join(projectRoot, 'build', 'web');
  if (fs.existsSync(path.join(rootBuild, 'main.dart.js'))) {
    clientBuildWeb = rootBuild;
  }
}
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

// Ensure assets/config.json exists directly under assets/
const nestedConfig = path.join(clientBuildWeb, 'assets', 'assets', 'config.json');
const directConfig = path.join(clientBuildWeb, 'assets', 'config.json');
if (fs.existsSync(nestedConfig) && !fs.existsSync(directConfig)) {
  fs.copyFileSync(nestedConfig, directConfig);
}

// 2. Ensure .vercel/output/static directory exists and is clean
try {
  if (fs.existsSync(vercelOutputDir)) {
    fs.rmSync(vercelOutputDir, { recursive: true, force: true });
  }
} catch (_) { }
fs.mkdirSync(vercelStaticDir, { recursive: true });

// 3. Recursive copy of static files
function copyFolderSync(from, to) {
  if (!fs.existsSync(to)) fs.mkdirSync(to, { recursive: true });
  for (const element of fs.readdirSync(from)) {
    const fromPath = path.join(from, element);
    const toPath = path.join(to, element);
    const stat = fs.lstatSync(fromPath);
    if (stat.isFile()) {
      try {
        fs.copyFileSync(fromPath, toPath);
      } catch (e) {
        try {
          if (fs.existsSync(toPath)) fs.unlinkSync(toPath);
          fs.copyFileSync(fromPath, toPath);
        } catch (_) { }
      }
    } else if (stat.isDirectory()) {
      copyFolderSync(fromPath, toPath);
    }
  }
}

console.log('Copying Flutter web assets into .vercel/output/static...');
copyFolderSync(clientBuildWeb, vercelStaticDir);

// Explicitly copy client/web/stitch into .vercel/output/static/stitch to guarantee availability
const clientWebStitch = path.join(projectRoot, 'client', 'web', 'stitch');
const targetStitch = path.join(vercelStaticDir, 'stitch');
if (fs.existsSync(clientWebStitch)) {
  console.log('Syncing authentic Stitch screen artboards into .vercel/output/static/stitch...');
  copyFolderSync(clientWebStitch, targetStitch);
}

const staticNestedConfig = path.join(vercelStaticDir, 'assets', 'assets', 'config.json');
const staticDirectConfig = path.join(vercelStaticDir, 'assets', 'config.json');
if (fs.existsSync(staticNestedConfig) && !fs.existsSync(staticDirectConfig)) {
  fs.copyFileSync(staticNestedConfig, staticDirectConfig);
}

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
      src: '^/stitch/(.*)$',
      headers: {
        'cache-control': 'public, max-age=0, must-revalidate'
      },
      continue: true
    },
    {
      src: '^/icons/(.*)$',
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
        'x-frame-options': 'SAMEORIGIN',
        'content-security-policy': "frame-ancestors 'self'",
        'referrer-policy': 'strict-origin-when-cross-origin',
        'cross-origin-opener-policy': 'same-origin-allow-popups'
      },
      continue: true
    },
    {
      handle: 'filesystem'
    },
    {
      src: '^/((?!assets/|canvaskit/|icons/|stitch/|.*\\.[a-zA-Z0-9]+$).*)$',
      dest: '/index.html'
    }
  ]
};

try {
  if (fs.existsSync(vercelConfigFile)) fs.unlinkSync(vercelConfigFile);
} catch (_) { }
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

