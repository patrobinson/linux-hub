require 'yaml'
require 'octokit'
require 'linux-hub/github_team'
require 'linux-hub/github_user'
require 'linux-hub/github'
require 'linux-hub/linux_user'

module LinuxHub
  def self.invoke
    options = Trollop::options do
      opt :config_file, "The config file to read options from", type: :string, required: true
      opt :list, "List users in the Github Team", type: :boolean
      opt :create_users, "Create users in the Github Team", type: :boolean
    end

    config = load_config(options[:config_file])
    Github.instance.access_token = config["access_token"]

    if options[:list]
      list(config)
    elsif options[:create_users]
      create_users(config)
    end
  end

  def self.load_config(config_file)
    YAML.load_file(config_file)
  end

  def self.list(config)
    puts GithubTeam.new(
      organisation: config["organisation"],
      team: config["team"],
    ).users.collect(&:authorized_keys)
  end

  def self.create_users(config)
    GithubTeam.new(
      organisation: config["organisation"],
      team: config["team"]
    ).users.each do |user|
      LinuxUser.new(user.username, config["groups"])
    end
  end
end
