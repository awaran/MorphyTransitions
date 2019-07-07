#
# Be sure to run `pod lib lint MorphyTransitions.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MorphyTransitions'
  s.version          = '0.1.2'
  s.summary          = 'For easy custom transitions for swift and autolayout'
  
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This cocoapod adds a custom transition and tools that help with animations in autolayout with minimal lines of code.  Please see readme or instructions on how to use it.

step1: use TransNavController instead of UINavigationController
step2 (in storyboard): use \"morph id\" on the starting viewcontroller to name views that will transition to the ending viewcontroller and the cocoapod will take it from there

step2 (in code): use \"morphIdentifier\" on the starting viewcontroller to name views that will transition to the ending viewcontroller and the cocoapod will take it from there

To to use any animations, use <UIView>.overlapViewWithReset, <UIView>.swapViewsWithReset or <UIView>.swapView for animations

                       DESC

  s.homepage         = 'https://github.com/awaran/MorphyTransitions'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Arjay Waran' => 'waran.arjay@gmail.com' }
  s.source           = { :git => 'https://github.com/awaran/MorphyTransitions.git', :tag => s.version.to_s }
  s.social_media_url = 'https://www.facebook.com/arjay.waran'
  s.social_media_url = 'https://twitter.com/ArjayWaran'
  s.homepage = 'http://arjaywaran.com'
  #s.swift_version = '5.0'
  s.swift_versions = ['4.2', '5.0']
  
  s.ios.deployment_target = '10.0'

  #s.source_files = 'MorphyTransitions/Classes/**/*'
  s.source_files = 'MorphyTransitions/Classes/**/*'

  # s.resource_bundles = {
  #   'MorphyTransitions' => ['MorphyTransitions/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
