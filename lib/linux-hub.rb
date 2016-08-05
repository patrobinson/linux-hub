require 'yaml'
require 'linux-hub/github_team'
require 'linux-hub/github_user'

module LinuxHub
  def self.invoke
    options = Trollop::options do
      opt :config_file, "The config file to read options from", type: :string, required: true
      opt :list, "List users", type: :boolean
    end

    config = load_config(options[:config_file])

    if options[:list]
      list(config)
    end
  end

  def self.load_config(config_file)
    YAML.load_file(config_file)
  end

  def self.list(config)
    puts GithubTeam.new(
      organisation: config["organisation"],
      team: config["team"],
      access_token: config["access_token"]
    ).users.inspect
  end
end
