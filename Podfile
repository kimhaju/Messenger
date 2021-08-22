# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Messenger' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Messenger

# 파이어 베이스
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'

# 페이스북 로그인
pod 'FBSDKLoginKit'
# 구글 로그인
pod 'GoogleSignIn','~>5.0.2'

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end

end
