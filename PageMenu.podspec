Pod::Spec.new do |s|
  s.name         = "PageMenu"
  s.version      = "1.0.0"
  s.summary      = "A fully customizable and flexible paging menu controller built from other view controllers allowing the user to switch between any kind of view controller with an easy tap or swipe gesture."
  s.homepage     = "https://github.com/uacaps/PageMenu"
  s.license      = { :type => 'UA', :file => 'LICENSE' }
  s.author       = { "uacaps" => "care@cs.ua.edu" }
  s.source       = { :git => "https://github.com/uacaps/PageMenu.git", :tag => '1.0.0' }
  s.platform     = :ios, '7.0'
  s.source_files = 'PageMenu/*'
  s.requires_arc = true
end