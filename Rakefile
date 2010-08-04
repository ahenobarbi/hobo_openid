require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "hobo_openid"
    gem.summary = %Q{OpenID login for Hobo}
    gem.description = %Q{Adds ability to login with OpenID to Hobo-based applications. See README to start using it.}
    gem.email = "jbartosik@gmail.com"
    gem.homepage = "http://github.com/ahenobarbi/hobo_openid"
    gem.authors = ["Joachim Filip Ignacy Bartosik"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    #gem.add_dependency "hobo", ">=1.0.0"
    gem.add_dependency "rails", ">=2.3.5"
    gem.require_paths = ['lib']
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "hobo_openid #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
