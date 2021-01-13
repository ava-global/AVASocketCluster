#
# Be sure to run `pod lib lint AVASocketCluster.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AVASocketCluster'
  s.version          = '0.1.0'
  s.summary          = 'library for connect ios app with socket cluster'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'library for connect ios ipad app with socket cluster'

  s.homepage         = 'http://www.ava.fund/'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'daisyfoto' => 'daisyfoto.ai@gmail.com' }
  s.source           = { :git => 'https://bitbucket.org/avaglobal/avasocketcluster.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'
  s.source_files = 'AVASocketCluster/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AVASocketCluster' => ['AVASocketCluster/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit'
  s.dependency "Starscream", "~> 3.0.5"
  s.dependency "HandyJSON", "~> 5.0.0-beta.1"
  
end
