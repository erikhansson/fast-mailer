
spec = Gem::Specification.new do |s|
  
  s.name = 'fast-mailer'
  s.version = File.read(File.dirname(__FILE__) + "/VERSION").strip
  s.platform = Gem::Platform::RUBY
  s.authors = ['Erik Hansson']
  s.email = ['erik@bits2life.com']
  s.homepage = 'http://github.com/erikhansson/fast-mailer'
  s.summary = 'Help with sending emails.'
  s.description = 'Helps with sending emails fast, and with convenient configuration.'
  s.rubyforge_project = "nowarning"

  s.required_rubygems_version = ">= 1.3.6"
  
  s.add_dependency 'mail', '~> 2.2.5'
  s.add_dependency 'i18n'
  s.add_dependency 'hooks', '~> 0.1'

  s.add_development_dependency 'bundler', '~> 1.0.0'
  s.add_development_dependency 'rspec', '~> 2.0.0.beta.22'
  s.add_development_dependency 'rake', '~> 0.8.7'
  s.add_development_dependency 'autotest'
  
  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENCE VERSION README.md)
  s.executables = []
  s.require_path = 'lib'
  
end
