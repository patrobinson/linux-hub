require 'fileutils'
require 'etc'

module LinuxHub
  class LinuxUser
    # The default group is used to keep track of members
    # Members in this group not in the appropriate Github Team are purged
    DEFAULT_GROUP = 'linuxhub'

    def self.users_in_group
      return [] unless group_exists?
      group_info.mem.collect { |u| new(username: u) }
    end

    def self.create_default_group
      return if group_exists?
      %x(groupadd #{DEFAULT_GROUP})
    end

    def self.group_info
      begin
        @group_info ||= Etc::getgrnam(DEFAULT_GROUP)
      rescue ArgumentError
        nil
      end
    end

    def self.group_exists?
      !group_info.nil?
    end

    private_class_method :group_info, :group_exists?


    attr_reader :username

    def initialize(username:, groups: [], ssh_keys: [])
      @username = username
      @groups = (groups || []) + [DEFAULT_GROUP]
      @ssh_keys = ssh_keys
    end

    def create
      self.class.create_default_group
      create_user
      create_user_keys
    end

    def delete
      delete_home
      delete_user
    end

    private

    def create_user
      return if user_exists?
      # Create the user and assign them to some groups
      # Don't create a group for this user
      # Create the home directory for this user
      %x(useradd -G #{@groups.join(',')} -N -m #{@username})
    end

    def delete_user
      return unless user_exists?
      %x(userdel #{@username})
    end

    def delete_home
      FileUtils.rm_r(home_dir)
    end

    def create_user_keys
      ssh_dir = File.join(home_dir, ".ssh")
      Dir.mkdir(ssh_dir, 0700) unless Dir.exist? ssh_dir
      File.open(File.join(ssh_dir, "authorized_keys"), "w", 0600) do |f|
        @ssh_keys.each do |key|
          f.write "#{key}\n"
        end
      end
      FileUtils.chown_R(@username, nil, ssh_dir)
    end

    def home_dir
      fail "User not found!" unless user_exists?
      user_info.dir
    end

    def user_info
      begin
        @user_info ||= Etc::getpwnam(@username)
      rescue ArgumentError
        nil
      end
    end

    def user_exists?
      !user_info.nil?
    end
  end
end
