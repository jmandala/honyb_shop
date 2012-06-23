Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'honyb_theme'
  s.version     = '0.2.0'
  s.summary     = 'Honyb Theme, including embed mode and assorted ui tweak'

  s.author        = 'Joshua Jacobs'
  s.email         = 'josh@Mandala-designs.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'routing-filter'
  s.add_dependency 'spree_core', '>= 0.70.5'
  
  s.has_rdoc = false
  
end
