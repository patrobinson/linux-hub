require 'yaml'
require 'octokit'
require 'linux-hub/github_team'
require 'linux-hub/github_user'
require 'linux-hub/github'

module LinuxHub
  def self.invoke
    options = Trollop::options do
      opt :config_file, "The config file to read options from", type: :string, required: true
      opt :list, "List users", type: :boolean
    end

    config = load_config(options[:config_file])
    Github.instance.access_token = config["access_token"]

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
    ).users.inspect
  end
end
