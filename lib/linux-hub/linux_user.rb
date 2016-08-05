module LinuxHub
  class LinuxUser
    def initialize(username:, groups: [], ssh_keys: [])
      @username = username
      @groups = (groups || []) + [default_group]
      @ssh_keys = ssh_keys
    end

    def create
      create_default_group
      create_user
      create_user_keys
    end

    # The default group is used to keep track of members
    # Members in this group not in the appropriate Github Team are purged
    def default_group
      'linuxhub'
    end

    private

    def create_default_group
      return if group_exists?
      %x(groupadd #{default_group})
    end

    def group_exists?
      thing_exists? "/etc/group", default_group
    end

    def create_user
      return if user_exists?
      # Create the user and assign them to some groups
      # Don't create a group for this user
      # Create the home directory for this user
      %x(useradd -G #{@groups.join(',')} -N -m #{@username} )
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
