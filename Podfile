# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

pod 'FBSDKCoreKit', :inhibit_warnings => true


target 'passive-hangout' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for passive-hangout
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'FacebookCore'
  pod 'FacebookLogin'
  pod 'FacebookShare'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'SwiftKeychainWrapper'
  pod 'Kingfisher'

  target 'passive-hangoutTests' do
    inherit! :search_paths
    pod 'Firebase'
    pod 'FacebookCore'
    # Pods for testing
  end

  target 'passive-hangoutUITests' do
    inherit! :search_paths
    pod 'Firebase'
    pod 'FacebookCore'
    # Pods for testing
  end

end
