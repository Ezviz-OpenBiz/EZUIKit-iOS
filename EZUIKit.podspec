Pod::Spec.new do |s|
  s.name     = 'EZUIKit'
  s.version  = '1.1.1'
  s.license  = 'MIT'
  s.summary  = 'A UI show video'
  s.homepage = 'https://github.com/Hikvision-Ezviz/EZUIKit-iOS'
  s.authors  = {'ezviz-LinYong' => 'linyong3@hikvision.com'}
  s.source   = {:git => 'https://github.com/Hikvision-Ezviz/EZUIKit-iOS.git',:tag => s.version,:submodules => true}
  s.requires_arc = true
  s.platform = :ios,'8.0'
  s.source_files = 'dist/EZUIKit/include/*.h'
  s.vendored_libraries = 'dist/EZUIKit/*.a'
  s.default_subspec = 'EZOpenSDK'

s.subspec 'EZOpenSDK' do |ss|
  ss.ios.deployment_target = '8.0'
  ss.vendored_frameworks = 'dist/EZOpenSDK/dynamicSDK/*.framework'
end

end