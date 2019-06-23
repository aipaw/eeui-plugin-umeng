

Pod::Spec.new do |s|



  s.name         = "umeng"
  s.version      = "0.0.1"
  s.summary      = "eeui plugin."
  s.description  = <<-DESC
                    eeui plugin.
                   DESC

  s.homepage     = "http://eeui.cc"
  s.license      = "MIT"
  s.author             = { "veryitman" => "aipaw@live.cn" }
  s.source =  { :path => '.' }
  s.source_files  = "umeng", "**/**/*.{h,m,mm,c}"
  s.exclude_files = "Source/Exclude"
  s.platform     = :ios, "8.0"
  s.requires_arc = true

  s.dependency 'WeexSDK'
  s.dependency 'eeui'
  s.dependency 'WeexPluginLoader', '~> 0.0.1.9.1'
  s.dependency 'UMCCommon'
  s.dependency 'UMCSecurityPlugins'
  s.dependency 'UMCAnalytics'
  s.dependency 'UMCPush'
  s.dependency 'UMCCommonLog'

end
