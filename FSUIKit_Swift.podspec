Pod::Spec.new do |s|
  s.name     = 'FSUIKit_Swift'
  s.version  = '1.0.1'
  s.summary  = 'A collection of iOS components written in Swift.'
  s.homepage = 'https://github.com/lifution/FSUIKit'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.author   = 'Sheng'
  s.source   = {
    :git => 'https://github.com/lifution/FSUIKit.git',
    :tag => s.version.to_s
  }
  
  s.requires_arc = true
  s.swift_version = '5'
  s.ios.deployment_target = '11.0'
  
  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'CoreText'
  s.source_files = 'Sources/Classes/**/*'
  
   s.resource_bundles = {
     'FSUIKit_Swift' => ['Sources/Assets/**/*']
   }
end
