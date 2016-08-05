module LinuxHub
  class GithubUser
    attr_reader :username, :ssh_key, :ssh_key_type, :email

    def initialize(username)
      @username = username
    end
  end
end
