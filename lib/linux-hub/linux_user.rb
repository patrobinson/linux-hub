module LinuxHub
  class LinuxUser
    def initialize(username, groups)
      @username = username
      @groups = (groups || []) + [default_group]
      create_default_group
      create_user
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
