module LinuxHub
  class GithubUser
    attr_reader :username, :email, :ssh_keys

    def initialize(username)
      @username = username
      fetch_user_details
    end

    def authorized_keys
      ssh_keys.map do |key|
        "#{key} #{email}"
      end
    end

    private

    def fetch_user_details
      @email = client.user(@username).email || "#{@username}@github"
      @ssh_keys = client.user_keys(@username).collect(&:key)
    end

    def client
      Github.instance.client
    end
  end
end
