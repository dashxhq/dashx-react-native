require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "DashXReactNative"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  @dashx/react-native
                   DESC
  s.homepage     = "https://github.com/github_account/@dashx/react-native"
  # brief license entry:
  s.license      = "MIT"
  s.authors      = { "DashXDev" => "dev@dashx.com" }
  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/dashxhq/dashx-react-native.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "DashX", "1.0.0"
  s.dependency "React"
end
