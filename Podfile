# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# Uncomment the next line to silence all warnings from pods in your project
inhibit_all_warnings!

# Use use whole module optimization for Swift files when compiling in release mode.
plugin 'cocoapods-wholemodule'

target 'Venice High' do
  # Pods for Venice High
  pod 'Alamofire'
  pod 'Alamofire-Synchronous'
  pod 'FSCalendar'
  pod 'JGProgressHUD'
  pod 'MarqueeLabel'
  pod 'MWFeedParser'
  pod 'PermissionScope'
  pod 'ReachabilitySwift'
  pod 'RFAboutView-Swift'
  pod 'Spruce'
  pod 'SwiftWebVC'
  pod 'SwipeCellKit'
  pod 'SwiftMapVC', :git => 'https://github.com/steets250/SwiftMapVC.git'
end

target 'Bell Schedule' do
  # Pods for Bell Schedule
  pod 'ObjectMapper'
end

# Workaround Cocoapods to mix Swift 3.2 and 4
# Manually add to swift4Targets, otherwise assume target uses Swift 3.2
swift4Targets = ['ReachabilitySwift', 'SwipeCellKit']
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if swift4Targets.include? target.name
                config.build_settings['SWIFT_VERSION'] = '4'
            else
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end
