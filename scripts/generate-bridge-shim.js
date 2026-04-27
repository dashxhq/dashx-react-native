#!/usr/bin/env node
/* eslint-disable no-console */
//
// generate-bridge-shim.js — regenerate `ios/DashXReactNative.mm` from the
// Swift bridge's @objc declarations.
//
// Why this exists:
//
// React Native's iOS bridge needs each Swift method to be declared TWICE for
// dual-arch support — once in Swift (`@objc(selector:parts:) func name(...)`)
// and once in ObjC++ (`RCT_EXTERN_METHOD(selector:(Type)arg ...)` in the .mm).
// The two declarations must agree on selector and arg types — when they
// don't, the new-arch TurboModule runtime can't find the method and JS calls
// fail with "Objective-C method signature ... can not be found." We learned
// that the hard way when we widened `unsubscribe` to a Promise method,
// updated the Swift side, and forgot the .mm.
//
// This script makes the Swift file the single source of truth and emits the
// matching .mm. Run via `yarn sync-bridge-shim` after editing the Swift
// bridge; CI verifies the .mm is up to date by re-running the script and
// failing on a non-empty `git diff`.
//
// Conventions assumed about the Swift bridge file:
//   1. Each bridged method is preceded by `@objc` (zero-arg) or
//      `@objc(selector:parts:)` (multi-arg) on its own line.
//   2. The `@objc` line is immediately followed by `func name(...)`. Blank
//      lines between are tolerated.
//   3. Multi-arg methods always use the explicit `@objc(...)` form so the
//      selector parts are unambiguous (no auto-derivation).
//   4. Zero-arg methods use bare `@objc`. The selector is just the method
//      name.
//   5. The class itself is decorated with `@objc(DashXReactNative)` — this
//      script ignores any `@objc` decoration that's NOT followed by `func`.
//
// If the Swift file uses a parameter type the SWIFT_TO_OBJC table doesn't
// know, the script errors loudly with the offending type name. Adding new
// types is a one-line entry in the table — preferred to a silent fallback.

const fs = require('fs')
const path = require('path')

const REPO_ROOT = path.resolve(__dirname, '..')
const SWIFT_PATH = path.join(REPO_ROOT, 'ios', 'DashXReactNative.swift')
const MM_PATH = path.join(REPO_ROOT, 'ios', 'DashXReactNative.mm')

// Swift parameter type → ObjC declaration. The values are written verbatim
// into the .mm so they include pointers and `_Nullable` annotations where
// applicable. Add new entries when the bridge starts using a new type.
const SWIFT_TO_OBJC = {
  'String': 'NSString *',
  'String?': 'NSString * _Nullable',
  'NSString': 'NSString *',
  'NSString?': 'NSString * _Nullable',
  'NSDictionary': 'NSDictionary *',
  'NSDictionary?': 'NSDictionary * _Nullable',
  'Bool': 'BOOL',
  'Double': 'double',
  '@escaping RCTPromiseResolveBlock': 'RCTPromiseResolveBlock',
  '@escaping RCTPromiseRejectBlock': 'RCTPromiseRejectBlock',
}

const HEADER = `//
// AUTO-GENERATED FROM DashXReactNative.swift — DO NOT EDIT.
// Regenerate with \`yarn sync-bridge-shim\` after editing the Swift file.
//
// The Swift class's @objc method declarations are the source of truth.
// This file mirrors them so old-arch React Native consumers (which discover
// methods via RCT_EXTERN_METHOD) and new-arch consumers (which dispatch via
// the codegen-generated TurboModule spec) both find consistent signatures.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNDashXReactNativeSpec.h"
#endif

@interface RCT_EXTERN_MODULE(DashXReactNative, RCTEventEmitter)

`

const FOOTER = `
@end

#ifdef RCT_NEW_ARCH_ENABLED
@interface DashXReactNative () <NativeDashXReactNativeSpec>
@end

@implementation DashXReactNative (TurboModule)

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeDashXReactNativeSpecJSI>(params);
}

@end
#endif
`

function fail(message) {
  console.error(`generate-bridge-shim: ${message}`)
  process.exit(1)
}

function translateType(swiftType) {
  const trimmed = swiftType.trim()
  if (!(trimmed in SWIFT_TO_OBJC)) {
    fail(
      `unknown Swift parameter type "${trimmed}". Add a mapping to ` +
      `SWIFT_TO_OBJC in scripts/generate-bridge-shim.js if this is a ` +
      `legitimate new type the bridge needs.`
    )
  }
  return SWIFT_TO_OBJC[trimmed]
}

// Parse a Swift parameter list like "_ urn: String, options: NSDictionary?,
// resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock"
// into an array of { argName, type } pairs in declaration order. The Swift
// argument LABEL ("_" or the external label) is irrelevant for emitting the
// .mm — the selector parts already encode the labels.
function parseSwiftParams(paramsRaw) {
  if (paramsRaw.trim() === '') return []

  // Split on commas that are NOT inside angle brackets / parens. The bridge
  // doesn't currently use generics, so a plain split is enough.
  const parts = paramsRaw.split(',').map((p) => p.trim()).filter(Boolean)

  return parts.map((part) => {
    // Forms:
    //   "_ name: Type"
    //   "label name: Type"
    //   "name: Type"      (label = name)
    const m = part.match(/^(?:(\S+)\s+)?(\w+)\s*:\s*(.+)$/)
    if (!m) {
      fail(`could not parse parameter "${part}" in DashXReactNative.swift`)
    }
    const argName = m[2]
    const type = m[3]
    return { argName, type }
  })
}

// Read the Swift bridge and walk it for @objc-decorated funcs. Returns an
// array of { name, selectorOverride, params } in source order. Decorations
// without a following `func` (e.g. the class-level @objc(DashXReactNative))
// are skipped.
function extractMethods(source) {
  const lines = source.split('\n')
  const methods = []

  for (let i = 0; i < lines.length; i++) {
    const trimmed = lines[i].trim()
    const objc = trimmed.match(/^@objc(?:\(([^)]+)\))?\s*$/)
    if (!objc) continue
    const selectorOverride = objc[1] || null

    // Find the next non-blank line. If it's not a `func`, this @objc isn't
    // for us (could be a class declaration, a property, etc.).
    let j = i + 1
    while (j < lines.length && lines[j].trim() === '') j++
    if (j >= lines.length) continue

    let sig = lines[j]
    if (!/^\s*func\s/.test(sig)) continue

    // Multi-line param lists: keep accumulating until parens balance.
    let openParens = (sig.match(/\(/g) || []).length
    let closeParens = (sig.match(/\)/g) || []).length
    while (openParens > closeParens && j + 1 < lines.length) {
      j++
      sig += ' ' + lines[j].trim()
      openParens += (lines[j].match(/\(/g) || []).length
      closeParens += (lines[j].match(/\)/g) || []).length
    }

    const m = sig.match(/func\s+(\w+)\s*\(([^)]*)\)/)
    if (!m) {
      fail(
        `could not parse @objc'd function signature near line ${j + 1}: ` +
        `"${sig.trim()}"`
      )
    }
    const [, name, paramsRaw] = m

    methods.push({
      name,
      selectorOverride,
      params: parseSwiftParams(paramsRaw),
    })
  }

  return methods
}

// Build the RCT_EXTERN_METHOD line for one method. Selector parts come from
// the @objc(selector:parts:) override (or the bare method name for zero-arg
// methods). Types come from the parsed Swift params.
function emitDeclaration(method) {
  const { name, selectorOverride, params } = method

  if (params.length === 0) {
    // Zero-arg method — RCT_EXTERN_METHOD(name) with no parens.
    return `RCT_EXTERN_METHOD(${name})`
  }

  if (!selectorOverride) {
    fail(
      `multi-arg method "${name}" must use explicit @objc(selector:parts:) ` +
      `form so its selector is unambiguous.`
    )
  }

  // Selector parts: "fetchRecord:options:resolve:reject:" → ["fetchRecord",
  // "options", "resolve", "reject"]. The first part is the method name.
  // Expect (params.length) parts total — if the count differs, the @objc
  // override and the func signature have drifted.
  const labels = selectorOverride.split(':').filter(Boolean)
  if (labels.length !== params.length) {
    fail(
      `method "${name}" has ${labels.length} selector parts but ` +
      `${params.length} parameters — these must match. Update the ` +
      `@objc(...) override or the func signature in DashXReactNative.swift.`
    )
  }

  // Interleave: "label1:(Type1)argName1 label2:(Type2)argName2 ..."
  // The first label is the method name; subsequent labels precede their
  // typed arg.
  const pieces = labels.map((label, idx) => {
    const { argName, type } = params[idx]
    const objcType = translateType(type)
    return `${label}:(${objcType})${argName}`
  })

  return `RCT_EXTERN_METHOD(${pieces.join(' ')})`
}

function main() {
  const source = fs.readFileSync(SWIFT_PATH, 'utf8')
  const methods = extractMethods(source)

  if (methods.length === 0) {
    fail(`no @objc-decorated methods found in ${SWIFT_PATH}`)
  }

  const declarations = methods.map((m) => emitDeclaration(m) + ';').join('\n\n')
  const out = HEADER + declarations + '\n' + FOOTER

  fs.writeFileSync(MM_PATH, out)
  console.log(
    `generate-bridge-shim: wrote ${methods.length} RCT_EXTERN_METHOD ` +
    `declarations to ios/DashXReactNative.mm`
  )
}

main()
