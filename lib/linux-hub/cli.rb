module LinuxHub
  class CLI
    def initialize(config)
      @organization = config["organisation"]
      @team = config["team"]
      @groups = config["groups"]
      @shell = config["shell"] || "/bin/bash"

      Github.instance.access_token = config["access_token"]
      Octokit.auto_paginate = true
    end

    def list
      puts github_users.collect(&:authorized_keys)
    end

    def sync_users
      linux_users = LinuxUser.users_in_group
      linux_usernames = linux_users.collect(&:username)
      github_usernames = github_users.collect(&:username)
      # Equivalent to github_users - linux_users
      users_to_add = github_users.reject { |u| linux_usernames.include? u.username }
      # Equivalent to linux_users - github_users
      users_to_delete = linux_users.reject { |u| github_usernames.include? u.username }
      add_users(users_to_add)
      delete_users(users_to_delete)
    end

    def create_users
      add_users(github_users)
    end

    private

    def add_users(users)
      users.each do |user|
        LinuxUser.new(
          username: user.username,
          groups: @groups,
          ssh_keys: user.ssh_keys,
          shell: @shell
        ).create
      end
    end

    def delete_users(users)
      users.each do |user|
        LinuxUser.new(
          username: user.username
        ).delete
      end
    end

    def github_users
      GithubTeam.new(
        organisation: @organization,
        team: @team,
      ).users
    end
  end
end
