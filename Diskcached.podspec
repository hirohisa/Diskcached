Pod::Spec.new do |s|

  s.platform     = :ios
  s.name         = "Diskcached"
  s.version      = "0.1.1"
  s.summary      = "Diskcached."
  s.description  = "simple disk cache"
  s.homepage     = "https://github.com/hirohisa/Diskcached"
  s.license      =  {
                      :type => 'MIT',
                      :file => 'LICENSE'
                    }
  s.author       =  {
                      "Hirohisa Kawasaki" => "hirohisa.kawasaki@gmail.com"
                    }
  s.source       =  {
                      :git => "https://github.com/hirohisa/Diskcached.git",
                      :tag => s.version
                    }
  s.source_files = 'Diskcached/*.{h,m}'
  s.requires_arc = true
  s.frameworks    = 'UIKit’, ‘Foundation’

end
