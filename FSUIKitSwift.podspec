Pod::Spec.new do |s|
  s.name     = 'FSUIKitSwift'
  s.version  = '1.0.5'
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
  s.ios.deployment_target = '13.0'
  
  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'CoreText', 'WebKit', 'CoreTelephony', 'SystemConfiguration'
  s.source_files = 'Source/Classes/**/*'
  
  s.resource_bundles = {
    'FSUIKitSwift' => ['Source/Assets/**/*']
  }
end
