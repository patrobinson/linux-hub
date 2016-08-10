lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'linux-hub/version'

Gem::Specification.new do |s|
  s.name        = 'linux-hub'
  s.version     = LinuxHub::VERSION
  s.summary     = "Linux users from Github"
  s.description = "Import linux users from Github Organisations and Teams"
  s.authors     = ["Patrick Robinson"]
  s.email       = 'therealpatrobinson@gmail.com'
  s.files       = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
  s.homepage    = 'https://github.com/patrobinson/linux-hub'
  s.license     = 'MIT'

  s.add_dependency 'octokit'
  s.add_dependency 'trollop'
end
