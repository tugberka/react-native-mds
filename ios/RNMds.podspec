
Pod::Spec.new do |s|
  s.name         = "RNMds"
  s.version      = "1.0.0"
  s.summary      = "RNMds"
  s.description  = <<-DESC
                  RNMds
                   DESC
  s.homepage     = "https://github.com/tugberka/react-native-mds"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "11.0"

  s.source       = { :git => "https://github.com/tugberka/react-native-mds.git", :tag => "master" }
  s.source_files  = "*.{h,m}", "*.swift"
  s.requires_arc = true


  s.dependency "React"
  s.dependency "Movesense"
end
