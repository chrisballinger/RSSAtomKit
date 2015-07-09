Pod::Spec.new do |s|
  s.name             = "RSSAtomKit"
  s.version          = "0.1.1"
  s.summary          = "Customizable Obj-C RSS/Atom feed fetcher and parser."
  s.homepage         = "https://github.com/chrisballinger/RSSAtomKit"
  s.license          = 'MIT'
  s.author           = { "Chris Ballinger" => "chris@chatsecure.org" }
  s.source           = { :git => "https://github.com/chrisballinger/RSSAtomKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/chatsecure'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'RSSAtomKit/**/*.{h,m}'

  s.dependency 'Mantle', '~> 2.0'
  s.dependency 'Ono', '~> 1.2'

end
