Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'honyb_affiliate'
  s.version     = '0.2.1'
  s.summary     = 'Provides Affiliate order tracking'

  s.author        = 'Joshua Jacobs'
  s.email         = 'josh@Mandala-designs.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'routing-filter'
  
  s.has_rdoc = false
  
end
