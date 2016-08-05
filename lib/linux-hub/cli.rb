module LinuxHub
  class CLI
    def initialize(config)
      @organization = config["organisation"]
      @team = config["team"]
      @groups = config["groups"]

      Github.instance.access_token = config["access_token"]
    end

    def list
      puts users.collect(&:authorized_keys)
    end

    def create_users
      users.each do |user|
        LinuxUser.new(
          username: user.username,
          groups: @groups,
          ssh_keys: user.ssh_keys
        ).create
      end
    end

    private

    def users
      GithubTeam.new(
        organisation: @organization,
        team: @team,
      ).users
    end
  end
end
