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
  #   pod 'DashX', :git => 'https://github.com/dashxhq/dashx-ios.git', :tag => '1.1.9'
  # For local development:
  #   pod 'DashX', :path => '../dashx-ios'
  s.dependency "DashX", "~> 1.1.9"
end
