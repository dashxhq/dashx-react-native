#!/usr/bin/env node
/* eslint-disable no-console */
// Fails if the npm tarball would ship anything outside the SDK sources.

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
