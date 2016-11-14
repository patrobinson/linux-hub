require 'spec_helper'

describe LinuxHub::CLI do
  let(:organisation) { "beer_drinkers" }
  let(:team) { "bombers" }
  let(:groups) { ["admins"] }
  let(:access_token) { "sup3rs3kret" }
  let(:shell) { "/bin/bash" }
  let(:config) do
    {
      "organisation" => organisation,
      "team" => team,
      "groups" => groups,
      "access_token" => access_token,
      "shell" => shell,
    }
  end
  let(:ssh_keys) { ['abc123'] }
  let(:linux_user) { instance_double(LinuxHub::LinuxUser) }
  let(:github_team) { instance_double(LinuxHub::GithubTeam) }
  let(:github_user) { double(email: "barry@pub.aus") }
  let(:github_client) { double(LinuxHub::Github) }
  let(:github_interface) { double(client: github_client, access_token: nil) }

  before do
    allow(LinuxHub::GithubTeam).to receive(:new).and_return(github_team)
    allow(LinuxHub::LinuxUser).to receive(:new).and_return(linux_user)
    allow(github_team).to receive(:users).and_return(current_github_users)
    allow(LinuxHub::LinuxUser).to receive(:users_in_group).and_return(current_linux_users)
  end

  subject { described_class.new(config) }

  describe "#sync_users" do
    context "users exist in github that don't exist in linux" do
      let(:current_github_users) { [double(username: "barry", email: "barry@rspec.org", ssh_keys: ssh_keys)] }
      let(:current_linux_users) { [] }
      let(:barrys_key) { double(key: ssh_keys.first) }

      before do
        allow(github_client).to receive(:user_keys).with("barry").and_return([barrys_key])
      end

      it "creates the users in the default group" do
        expect(LinuxHub::LinuxUser).to receive(:new).with(username: "barry",
          groups: groups,
          ssh_keys: ssh_keys,
          shell: shell)
        expect(linux_user).to receive(:create)
        subject.sync_users
      end
    end

    context "users exist in the default group that don't exist in github" do
      let(:current_github_users) { [] }
      let(:current_linux_users) { [double(username: "sharon")] }

      it "deletes the user" do
        expect(LinuxHub::LinuxUser).to receive(:new).with(username: "sharon")
        expect(linux_user).to receive(:delete)
        subject.sync_users
      end
    end

    context "all users in github exist in linux" do
      let(:current_github_users) do
        [
          double(username: "barry", email: "barry@rspec.org", ssh_keys: ssh_keys),
          double(username: "dave", email: "dave@rspec.org", ssh_keys: ssh_keys)
        ]
      end
      let(:current_linux_users) { [double(username: "barry"), double(username: "dave")] }

      it "does not create or delete any users" do
        expect(linux_user).to_not receive(:delete)
        expect(linux_user).to_not receive(:create)
        subject.sync_users
      end
    end
  end
end