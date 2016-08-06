require 'yaml'
require 'octokit'
require 'linux-hub/github_team'
require 'linux-hub/github_user'
require 'linux-hub/github'
require 'linux-hub/linux_user'
require 'linux-hub/cli'

module LinuxHub
  ACTIONS = [:list, :create_users, :sync_users]

  def self.invoke
    options = Trollop::options do
      opt :config_file, "The config file to read options from", type: :string, required: true
      opt :list, "List users in the Github Team", type: :boolean
      opt :create_users, "Create users in the Github Team", type: :boolean
      opt :sync_users, "Manage all users in the Github Team", type: :boolean
    end

    config = load_config(options[:config_file])
    if config["access_token"].nil?
      puts "You need an access token with 'read:org' permissions for the organisation"
      exit 1
    elsif config["organisation"].nil? || config["team"].nil?
      puts "Please provide the team and organisation in the relevant config file"
    end

    action = options.select { |k,v| ACTIONS.include?(k) && v == true }

    unless action.length == 1
      puts "Please specify one of the following action commands\n#{ACTIONS}"
      exit 1
    end

    cli = CLI.new(config)
    cli.send(action.keys.first)
  end

  def self.load_config(config_file)
    YAML.load_file(config_file)
  end
end
