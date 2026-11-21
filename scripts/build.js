// ==============================================================================
// Nutrient Earth — Production Build Script (Cross-Platform Node.js)
// Prepares and verifies the Flutter Web release in build/web for Vercel deployment.
// ==============================================================================

const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const clientDir = path.join(rootDir, 'client');
const buildWebDir = path.join(rootDir, 'build', 'web');
const clientBuildWebDir = path.join(clientDir, 'build', 'web');

console.log('=== Nutrient Earth Production Build ===');
console.log(`Root Directory:   ${rootDir}`);
console.log(`Output Directory: ${buildWebDir}`);

// Helper: recursive copy
function copyDirectorySync(src, dest) {
  if (!fs.existsSync(dest)) {
    fs.mkdirSync(dest, { recursive: true });
  }
  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDirectorySync(srcPath, destPath);
    } else {
      try {
        fs.copyFileSync(srcPath, destPath);
      } catch (err) {
        try {
          if (fs.existsSync(destPath)) fs.unlinkSync(destPath);
          fs.copyFileSync(srcPath, destPath);
        } catch (_) {}
      }
    }
  }
}

// Helper: recursive file count
function countFiles(dir) {
  if (!fs.existsSync(dir)) return 0;
  let count = 0;
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      count += countFiles(fullPath);
    } else {
      count++;
    }
  }
  return count;
}

// 1. Ensure build/web directory exists
if (!fs.existsSync(buildWebDir)) {
  fs.mkdirSync(buildWebDir, { recursive: true });
}

// 2. If client/build/web exists, mirror it into build/web
if (fs.existsSync(clientBuildWebDir) && fs.existsSync(path.join(clientBuildWebDir, 'index.html'))) {
  console.log('Syncing client/build/web into root build/web...');
  copyDirectorySync(clientBuildWebDir, buildWebDir);
}

// 3. Sync authentic Stitch screens (including Screen 18) into build/web/stitch
const clientStitchDir = path.join(clientDir, 'web', 'stitch');
const buildStitchDir = path.join(buildWebDir, 'stitch');
if (fs.existsSync(clientStitchDir)) {
  console.log('Syncing Stitch artboards into build/web/stitch...');
  copyDirectorySync(clientStitchDir, buildStitchDir);
}

// 4. Ensure assets/config.json exists in build/web/assets/
const clientConfigFile = path.join(clientDir, 'assets', 'config.json');
const buildWebAssetsDir = path.join(buildWebDir, 'assets');
const buildWebConfigFile = path.join(buildWebAssetsDir, 'config.json');
if (!fs.existsSync(buildWebAssetsDir)) {
  fs.mkdirSync(buildWebAssetsDir, { recursive: true });
}
if (fs.existsSync(clientConfigFile) && !fs.existsSync(buildWebConfigFile)) {
  fs.copyFileSync(clientConfigFile, buildWebConfigFile);
}

// Also handle nested config
const nestedConfig = path.join(buildWebAssetsDir, 'assets', 'config.json');
if (fs.existsSync(nestedConfig) && !fs.existsSync(buildWebConfigFile)) {
  fs.copyFileSync(nestedConfig, buildWebConfigFile);
}

// 5. Validate critical production assets
const indexHtml = path.join(buildWebDir, 'index.html');
const mainDartJs = path.join(buildWebDir, 'main.dart.js');
const screen18Index = path.join(buildStitchDir, 'screen_18', 'index.html');

if (!fs.existsSync(indexHtml)) {
  console.error(`ERROR: Critical file missing: ${indexHtml}`);
  process.exit(1);
}
if (!fs.existsSync(mainDartJs)) {
  console.error(`ERROR: Critical file missing: ${mainDartJs}`);
  process.exit(1);
}
if (!fs.existsSync(screen18Index)) {
  console.error(`ERROR: Screen 18 HTML missing: ${screen18Index}`);
  process.exit(1);
}

const buildWebCount = countFiles(buildWebDir);
console.log(`Verified build/web: ${buildWebCount} files ready.`);
console.log(`  - index.html: exists (${fs.statSync(indexHtml).size} bytes)`);
console.log(`  - main.dart.js: exists (${fs.statSync(mainDartJs).size} bytes)`);
console.log(`  - screen_18/index.html: exists (${fs.statSync(screen18Index).size} bytes)`);
console.log('=== Nutrient Earth Build Succeeded Successfully ===');
process.exit(0);
