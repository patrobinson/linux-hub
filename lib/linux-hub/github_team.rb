require 'octokit'

module LinuxHub
  class GithubTeam
    def initialize(organisation:, team:, access_token:)
      @org = organisation
      @team = team
      @access_token = access_token
    end

    def users
      @users ||= fetch_users
    end

    def team_id
      @team_id ||= fetch_team_id
    end

    private

    def fetch_users
      client.team_members(team_id).collect do |member|
        GithubUser.new(member.login)
      end
    end

    def fetch_team_id
      client.auto_paginate = true
      team = client.organization_teams(@org).find { |t| t[:name] == @team }
      client.auto_paginate = false
      team.id
    end

    def client
      Octokit::Client.new(access_token: @access_token)
    end
  end
end
