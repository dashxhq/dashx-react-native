require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "DashXReactNative"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "13.0" }
  s.source       = { :git => "https://github.com/dashxhq/dashx-react-native.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.requires_arc = true

  # React Native >= 0.71 provides install_modules_dependencies.
  # Since our minimum supported RN version is 0.74, we can call it directly.
  install_modules_dependencies(s)

  # DashX iOS SDK — consumers must provide the source in their Podfile:
  #   pod 'DashX/SDK', :git => 'https://github.com/dashxhq/dashx-ios.git', :tag => '1.5.1'
  # For local development:
  #   pod 'DashX', :path => '../dashx-ios'
  #
  # Floor of 1.5.1 — earlier versions either fall back to silent-push on the
  # backend (pre-1.3.0, which iOS throttles aggressively) or omit the
  # `.timeSensitive` authorization option (pre-1.5.1, which causes
  # `interruption-level: time-sensitive` payloads to silently downgrade to
  # `active` on iOS 18 / 26 and stay subject to Focus / Summary filtering).
  s.dependency "DashX/SDK", ">= 1.5.1"

  # Hard dependency so that `canImport(FirebaseMessaging)`
  # evaluates at this pod's compile time, where consumer-Podfile pods aren't
  # visible — so an "optional" guard silently elides every Firebase code path.
  # Consumers should set `use_modular_headers!` (or `:modular_headers => true`
  # on FirebaseMessaging) in their Podfile so this Swift import resolves.
  s.dependency "FirebaseMessaging"
end
