Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'honyb_reports'
  s.version     = '0.1.1'
  s.summary     = 'Provides reporting and exporting'

  s.author        = 'Joshua Jacobs'
  s.email         = 'josh@Mandala-designs.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << %w[ruport ruport-util]
  
  s.add_dependency 'ruport'
  s.add_dependency 'ruport-util'
  s.add_dependency 'acts_as_reportable'

  s.has_rdoc = false
  
end
