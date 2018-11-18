Pod::Spec.new do |s|
  s.platform              = :ios
  s.ios.deployment_target = '10.0'
  s.name                  = "Valley"
  s.version               = "0.0.1"
  s.summary               = "An async download library with extra care for image."
  s.requires_arc          = true
  s.description           = <<-DESC
                            Valley is an iOS library that download asynchronously with caching capability. Valley is very simple
                            to use for image downloading and caching.
                            DESC
  s.homepage              = "https://github.com/mjhassan/Valley"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "Jahid Hassan" => "jahid.hassan.ce@gmail.com" }
  s.source                = { :git => "https://github.com/mjhassan/Valley.git", :tag => "#{s.version}" }
  s.source_files          = "Valley/**/*.{swift}"
  s.framework             = "UIKit"
end
