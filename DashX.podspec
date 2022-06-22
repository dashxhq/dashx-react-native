require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "DashX"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  @dashx/react-native
                   DESC
  s.homepage     = "https://github.com/github_account/@dashx/react-native"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "DashxDev" => "dev@dashx.com" }
  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/github_account/@dashx/react-native.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "Apollo"
  s.dependency "FirebaseMessaging"
end
