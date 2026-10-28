#!/usr/bin/env node
/* eslint-disable no-console */
//
// check-package.js — fail if the npm tarball would contain anything outside
// the SDK's own sources.
//
// Why this exists:
//
// `yarn publish` (Yarn 1) ignores the `!` negations in package.json `files`
// and matches entries like `ios` and `*.podspec` at any depth. Published from
// a checkout that has `.claude/worktrees/` or Gradle build output in it, 1.5.0
// shipped ~190 stray files that way. npm applies `files` correctly, so:
//
//   - As `prepublishOnly`, this refuses to run under `yarn publish`.
//   - Every run packs with npm (dry run) and checks each path against the
//     allowlist below. CI runs it too, so a bad `files` change fails the PR.
//
// Usage: `yarn check-package`

const { execFileSync } = require('child_process')
const path = require('path')

const REPO_ROOT = path.resolve(__dirname, '..')

const ALLOWED = [
  /^package\.json$/,
  /^README\.md$/,
  /^LICENSE$/,
  /^DashXReactNative\.podspec$/,
  /^index\.(js|d\.ts)$/,
  /^src\//,
  /^ios\//,
  /^android\/(build\.gradle|gradle\.properties|settings\.gradle)$/,
  /^android\/src\/(main|newarch|oldarch)\//,
]

// Never shipped, even under an allowed directory.
const FORBIDDEN = [/(^|\/)\./, /(^|\/)build\//, /(^|\/)node_modules\//]

function fail(message) {
  console.error(`check-package: ${message}`)
  process.exit(1)
}

const userAgent = process.env.npm_config_user_agent || ''
if (process.env.npm_lifecycle_event === 'prepublishOnly' && userAgent.startsWith('yarn/')) {
  fail(
    'publish with `npm publish`, not `yarn publish`. Yarn 1 ignores the `!` ' +
      'exclusions in package.json `files` and packs stray files. Bump the ' +
      'version with `yarn version` first if you have not.'
  )
}

const output = execFileSync('npm', ['pack', '--dry-run', '--json', '--ignore-scripts'], {
  cwd: REPO_ROOT,
  encoding: 'utf8',
  stdio: ['ignore', 'pipe', 'inherit'],
})
const [{ files }] = JSON.parse(output)
const paths = files.map((file) => file.path)

const unexpected = paths.filter(
  (p) => !ALLOWED.some((re) => re.test(p)) || FORBIDDEN.some((re) => re.test(p))
)
if (unexpected.length > 0) {
  fail(
    `the package would include ${unexpected.length} unexpected file(s):\n` +
      unexpected.map((p) => `  ${p}`).join('\n') +
      '\nFix package.json `files`, or extend ALLOWED in scripts/check-package.js.'
  )
}

console.log(`check-package: ${paths.length} files, all expected.`)
