module LinuxHub
  class LinuxUser
    # The default group is used to keep track of members
    # Members in this group not in the appropriate Github Team are purged
    DEFAULT_GROUP = 'linuxhub'

    def self.users_in_group
      File.open("/etc/group") do |f|
        f.each_line do |line|
          user = line.split(":")
          if user.first == DEFAULT_GROUP
            return user[3].chomp.split(',').collect { |u| new(username: u) }
          end
        end
      end
      []
    end

    attr_reader :username

    def initialize(username:, groups: [], ssh_keys: [])
      @username = username
      @groups = (groups || []) + [DEFAULT_GROUP]
      @ssh_keys = ssh_keys
    end

    def create
      create_default_group
      create_user
      create_user_keys
    end

    def delete
      delete_home
      delete_user
    end

    private

    def create_default_group
      return if group_exists?
      %x(groupadd #{DEFAULT_GROUP})
    end

    def group_exists?
      thing_exists? "/etc/group", DEFAULT_GROUP
    end

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
      File.open("/etc/passwd") do |f|
        f.each_line do |line|
          user = line.split(":")
          if user.first == @username
            return user[5]
          end
        end
      end
      fail "User not found!"
    end

    def user_exists?
      thing_exists? "/etc/passwd", @username
    end

    def thing_exists?(file, value)
      File.open(file) do |f|
        f.each_line do |line|
          user = line.split(":")
          if user.first == value
            f.close
            return true
          end
        end
      end
      false
    end
  end
end
