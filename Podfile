# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'HMAIS' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HMAIS
  pod 'Realm', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', :submodules => true
  
  pod 'RealmSwift', git: 'https://github.com/realm/realm-cocoa.git', branch: 'master', :submodules => true

  pod 'SwiftDate'
  pod 'SwiftyTimer'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxRealm'
  pod 'KeychainAccess'
  pod 'IHKeyboardAvoiding'
  pod 'AssistantKit'
  pod 'Toast-Swift', '~> 3.0.1'

  target 'HMAISTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'HMAISUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = ‘3.0’ # or '3.0'
    end
  end
end
