#
# Be sure to run `pod lib lint ZYChartViews.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZYChartViews'
  s.version          = '0.0.1'
  s.summary          = '自定义图表使用.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  常见图表的使用,如柱状图,雷达图等.
                       DESC

  s.homepage         = 'https://github.com/AELight'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AELight' => 'zhuyiae@163.com' }
  s.source           = { :git => 'https://github.com/AELight/ZYChartViews.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZYChartViews/Classes/*.{h,m}'
  
  # s.resource_bundles = {
  #   'ZYChartViews' => ['ZYChartViews/Assets/*.png']
  # }

  s.public_header_files = 'ZYChartViews/Classes/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
