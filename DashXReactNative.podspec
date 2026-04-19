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
  #   pod 'DashX/SDK', :git => 'https://github.com/dashxhq/dashx-ios.git', :tag => '1.3.1'
  # For local development:
  #   pod 'DashX', :path => '../dashx-ios'
  s.dependency "DashX/SDK"

  # Hard dependency so that `canImport(FirebaseMessaging)`
  # evaluates at this pod's compile time, where consumer-Podfile pods aren't
  # visible — so an "optional" guard silently elides every Firebase code path.
  # Consumers should set `use_modular_headers!` (or `:modular_headers => true`
  # on FirebaseMessaging) in their Podfile so this Swift import resolves.
  s.dependency "FirebaseMessaging"
end
