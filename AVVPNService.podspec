#
# Be sure to run `pod lib lint AVVPNService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AVVPNService'
  s.version          = '0.1.4'
  s.summary          = 'AVVPNService simplifies the setup of the VPN (IPSec or IKEv2)'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  AVVPNService simplifies the setup of the VPN.
  Just initialize Credentials struct and call connect method.
  You can observe NEVPNStatus be setting the delegate or subscribing NEVPNStatusDidChange notification.
                       DESC

  s.homepage         = 'https://github.com/AndreVasilev/AVVPNService'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Andrey Vasilev' => 'ao.vasilev@gmail.com' }
  s.source           = { :git => 'https://github.com/AndreVasilev/AVVPNService.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.3'
  s.swift_version         = '5.0'

  s.source_files = 'Sources/AVVPNService/**/*'

end
