#
# Be sure to run `pod lib lint CalendarRangeView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CalendarRangeView'
  s.version          = '1.3'
  s.summary          = 'Easily allow user to select range of dates in calendar.'
  s.description      = "Looking for simple Swift library to select ranmge of dates? This one is for you:)"
  s.swift_version    = '5.0'
  s.homepage         = 'https://github.com/kunass2/CalendarRangeView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kunass2' => 'bartekss2@icloud.com' }
  s.source           = { :git => 'https://github.com/kunass2/CalendarRangeView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'CalendarRangeView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MaskedTextField' => ['MaskedTextField/Assets/*.png']
  # }

  s.dependency 'SnapKit'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
end
