# A class that represents and manipulates the release version for this
# application.
class Version
  
  # Return a pathname object that points to the version file.
  def self.path
    Rails.root.join('VERSION')
  end
  
  # Create a new version object that has read its version number from the 
  # version file. If no version file is found, it sets the version to 0.0.0.
  def initialize
    if File.exist?(Version.path)
      read_version_from_file
    else
      @major = 0
      @minor = 0
      @patch = 0
    end
  end
  
  # The version number, without the leading "v". See also #to_s.
  def number
    "#{@major}.#{@minor}.#{@patch}"
  end
  
  # The string representation of the version number, e.g. "v1.2.3". It will 
  # always consist of a starting "v" followed immediately by three integers,
  # separated by dots.
  def to_s
    "v#{number}"
  end

  # Increase the major number of the version.
  def bump_major
    @major += 1
    @minor = 0
    @patch = 0
    self.save
  end

  # Increase the minor number of the version.
  def bump_minor
    @minor += 1
    @patch = 0
    self.save
  end
  
  # Increase the patch number of the version.
  def bump_patch
    @patch += 1
    self.save
  end
  
  # Save the version back to file, overwriting the previous value, if any.
  def save
    require 'git'
    git = Git.open('.', :log => Logger.new($stdout))
    git.pull # origin master
    write_version_to_file
    git.add(Version.path)
    git.commit("Bump version to #{self}.")
    git.add_tag(self.to_s)
    git.push('origin', 'master', true)  # including tags
    notify_campfire(git)
  rescue LoadError
    raise LoadError, "You must have the git gem installed to make a release."
  end
  
  protected
  
  def read_version_from_file
    if File.size(Version.path) > 32
      raise "the version file is too large to be valid"
    end
    File.open(Version.path) do |f|
      if f.read =~ /^(\d+)\.(\d+)\.(\d+)\s*$/
        @major = $1.to_i
        @minor = $2.to_i
        @patch = $3.to_i
      else
        raise "couldn't parse version file"
      end
    end
  end
  
  def write_version_to_file
    File.open(Version.path, 'w') do |f|
      f.write(self.number)
    end
  end
  
  def notify_campfire(git)
    require 'tinder'
    require 'yaml'
    
    git_config = git.config
    
    username = git_config['user.name']
    if username.nil?
      puts "\nCouldn't determine the current username from the git config. Skipping campfire notification.\n\n"
      return
    end
    
    git_config['remote.origin.url'] =~ /\/([^\/]+)\.git$/
    application = $1
    if application.nil?
      puts "\nCouldn't determine the application name from the git config. Skipping campfire notification.\n\n"
      return
    end
    
    config = YAML::load_file('config/campfire.yml')
    campfire = Tinder::Campfire.new(config['account'])
    campfire.login(config['email'], config['password'])
    room = campfire.find_room_by_name(config['room'])
    room.speak("#{username} just released version #{self} of #{application}")
    room.leave
  rescue Errno::ENOENT
    puts "\nCouldn't open config/campfire.yml. Skipping campfire notification.\n\n"
  rescue LoadError    
    puts "\nThe tinder gem is not installed. Skipping campfire notification.\n\n"
  end
  
end