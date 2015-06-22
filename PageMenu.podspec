Pod::Spec.new do |s|
  s.name         = "PageMenu"
  s.version      = "1.2.8"
  s.summary      = "A paging menu controller built from other view controllers allowing the user to switch between any kind of view controller."
  s.homepage     = "https://github.com/uacaps/PageMenu"
  s.license      = { :type => 'UA', :file => 'LICENSE' }
  s.author       = { "uacaps" => "care@cs.ua.edu" }
  s.source       = { :git => "https://github.com/uacaps/PageMenu.git", :tag => '1.2.8' }
  s.platform     = :ios, '8.0'
  s.source_files = 'Classes/*'
  s.requires_arc = true
end
