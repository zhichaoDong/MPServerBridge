Pod::Spec.new do |s|
  s.name             = 'MPServiceBridge'
  s.version          = '0.0.5'
  s.summary          = 'iOS AppDelegate瘦身之利用 Protocol-Class方案实现一个 AppDelegate Category.'
  s.description      = <<-DESC
  TODO: iOS AppDelegate瘦身之利用 Protocol-Class方案实现一个 AppDelegate Category.
                       DESC
  s.homepage         = 'https://github.com/zhichaoDong/MPServerBridge'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhichaoDong' => 'dzc_xinlang@sina.com' }
  s.source           = { :git => 'https://github.com/zhichaoDong/MPServerBridge.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.public_header_files = 'MPServiceBridge/Classes/*.h'
  s.source_files = 'MPServiceBridge/Classes/*.{h,m}'
  s.frameworks = "UIKit"
end
