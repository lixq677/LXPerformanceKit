#
# Be sure to run `pod lib lint LXNetworkKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#


Pod::Spec.new do |s|
  s.name             = 'LXPerformanceKit'
  s.version          = '0.0.4'
  s.summary          = 'A short description of LXPerformanceKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/lixq677/LXPerformanceKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '李笑清' => 'xiaoqingmail@sina.cn' }
  s.source           = { :git => 'https://github.com/lixq677/LXPerformanceKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = "LXPerformanceKit/*.{h,m}"
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.requires_arc = true
  # s.resource_bundles = {
  #   'LXNetworkKit' => ['LXNetworkKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency  "YYModel"
   s.dependency  "libextobjc"
    
   s.subspec 'LXTools' do |aa|
        aa.source_files = "LXPerformanceKit/LXTools/*.{h,m}","LXPerformanceKit/LXTools/**/*.{h,m}"
        aa.dependency  "libextobjc"
   end
   s.subspec 'LXSystem' do |bb|
        bb.source_files = "LXPerformanceKit/LXSystem/*.{h,m}","LXPerformanceKit/LXSystem/**/*.{h,m}"
   end
   
    s.subspec 'LXCPUMonitor' do |cc|
        cc.source_files = "LXPerformanceKit/LXCPUMonitor/*.{h,m}","LXPerformanceKit/LXCPUMonitor/**/*.{h,m}"
        cc.dependency  "LXPerformanceKit/LXSystem"
        cc.dependency  "LXPerformanceKit/LXTools"
    end
    
    s.subspec 'LXLagMonitor' do |dd|
        dd.source_files = "LXPerformanceKit/LXLagMonitor/*.{h,m}","LXPerformanceKit/LXLagMonitor/**/*.{h,m}"
        dd.dependency  "LXPerformanceKit/LXSystem"
        dd.dependency  "LXPerformanceKit/LXTools"
        dd.dependency 'YYCache'
    end
        
    s.subspec 'LXCrashMonitor' do |ee|
        ee.source_files = "LXPerformanceKit/LXCrashMonitor/*.{h,m,mm,c}","LXPerformanceKit/LXCrashMonitor/**/*.{h,m,mm,c}"
        ee.dependency  "LXPerformanceKit/LXSystem"
        ee.dependency  "LXPerformanceKit/LXTools"
        ee.dependency 'YYCache'
    end
    
    s.subspec 'LXGPUMonitor' do |ff|
        ff.source_files = "LXPerformanceKit/LXGPUMonitor/*.{h,m,mm,c}","LXPerformanceKit/LXGPUMonitor/**/*.{h,m,mm,c}"
        ff.framework = 'IOKit'
    end
    
    s.subspec 'LXFPSMonitor' do |gg|
        gg.source_files = "LXPerformanceKit/LXFPSMonitor/*.{h,m,mm,c}","LXPerformanceKit/LXFPSMonitor/**/*.{h,m,mm,c}"
        gg.framework = 'UIKit'
    end
    s.subspec 'LXMEMMonitor' do |hh|
        hh.source_files = "LXPerformanceKit/LXMEMMonitor/*.{h,m,mm,c}","LXPerformanceKit/LXMEMMonitor/**/*.{h,m,mm,c}"
        hh.dependency  "LXPerformanceKit/LXSystem"
        hh.dependency  "LXPerformanceKit/LXTools"
    end
    s.subspec 'LXUIMonitor' do |jj|
        jj.source_files = "LXPerformanceKit/LXUIMonitor/*.{h,m,mm,c}","LXPerformanceKit/LXUIMonitor/**/*.{h,m,mm,c}"
        jj.resources = "LXPerformanceKit/LXUIMonitor/*.xcassets","LXPerformanceKit/LXUIMonitor/*.png"
        jj.dependency  "LXPerformanceKit/LXSystem"
        jj.dependency  "LXPerformanceKit/LXGPUMonitor"
        jj.dependency  "LXPerformanceKit/LXFPSMonitor"
        jj.dependency  "LXPerformanceKit/LXMEMMonitor"
        jj.dependency  "LXPerformanceKit/LXCPUMonitor"
        jj.dependency  "LXPerformanceKit/LXTools"
        jj.framework = 'UIKit'
        
    end

end
