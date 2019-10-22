# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'PolluxUI' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PolluxUI
  pod 'Parse', '1.17.1'
  pod 'ParseLiveQuery'

end

pre_install do |installer|
  installer.analysis_result.specifications.each do |s|
    s.swift_version = '4.0' unless s.swift_version
  end
end
