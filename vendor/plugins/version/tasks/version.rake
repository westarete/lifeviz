require File.dirname(__FILE__) + '/../lib/version.rb'

namespace :version do

  desc 'Read the current version number from the VERSION file'
  task :read do
    @version = Version.new
    puts "Version is #{@version}"
  end
  
  namespace :bump do

    desc 'Increase the version by a major version number and release to origin'
    task :major => ['version:read', 'spec', 'cucumber'] do
      @version.bump_major
      puts "Version is now #{@version}"
    end

    desc 'Increase the version by a minor version number and release to origin'
    task :minor => ['version:read', 'spec', 'cucumber'] do
      @version.bump_minor
      puts "Version is now #{@version}"
    end

    desc 'Increase the version by a patch version number and release to origin'
    task :patch => ['version:read', 'spec', 'cucumber'] do
      @version.bump_patch
      puts "Version is now #{@version}"
    end

  end

end