require 'singleton'

module LinuxHub
  class Github
    include Singleton

    attr_writer :access_token

    def client
      @client ||= Octokit::Client.new(access_token: @access_token)
    end
  end
end
