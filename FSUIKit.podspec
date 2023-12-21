Pod::Spec.new do |s|
  s.name     = 'FSUIKit'
  s.version  = '1.0.0'
  s.summary  = 'A collection of iOS components written in Swift.'
  s.homepage = 'https://github.com/lifution/FSUIKit'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.author   = 'Sheng'
  s.source   = {
    :git => 'https://github.com/lifution/FSUIKit.git',
    :tag => s.version.to_s
  }
  
  s.ios.deployment_target = '11.0'
  
  s.source_files = 'Sources/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FSUIKit' => ['Sources/Assets/*.png']
  # }
end
