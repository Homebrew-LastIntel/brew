# typed: strict
# frozen_string_literal: true

require "os"

RSpec.describe OS do
  it "detects nix-homebrew from its repository" do
    stub_const("HOMEBREW_REPOSITORY", HOMEBREW_PREFIX/"Library/.homebrew-is-managed-by-nix")

    expect(described_class.nix_managed_homebrew?).to be(true)
    expect(described_class.nix_managed_homebrew_issues_url)
      .to eq("https://github.com/zhaofengli/nix-homebrew/issues")
  end

  it "detects nix-homebrew from its prefix marker" do
    mktmpdir do |prefix|
      stub_const("HOMEBREW_PREFIX", prefix)
      stub_const("HOMEBREW_REPOSITORY", prefix/"Library/Homebrew")

      (prefix/".managed_by_nix_darwin").write("")

      expect(described_class.nix_managed_homebrew?).to be(true)
    end
  end

  it "detects nix-homebrew from update environment values" do
    old_update_before = ENV.fetch("HOMEBREW_UPDATE_BEFORE", nil)
    old_update_after = ENV.fetch("HOMEBREW_UPDATE_AFTER", nil)
    mktmpdir do |prefix|
      stub_const("HOMEBREW_PREFIX", prefix)
      stub_const("HOMEBREW_REPOSITORY", prefix/"Library/Homebrew")
      ENV["HOMEBREW_UPDATE_BEFORE"] = "nix"
      ENV["HOMEBREW_UPDATE_AFTER"] = "nix"

      expect(described_class.nix_managed_homebrew?).to be(true)
    end
  ensure
    ENV["HOMEBREW_UPDATE_BEFORE"] = old_update_before
    ENV["HOMEBREW_UPDATE_AFTER"] = old_update_after
  end

  describe ".default_prefix_issue_reports?", :needs_macos do
    before do
      # `global.rb` removes this from the environment before RSpec starts.
      stub_const("HOMEBREW_MACOS_ARM_DEFAULT_PREFIX", "/opt/homebrew")
      stub_const("HOMEBREW_DEFAULT_PREFIX", "/usr/local")
      allow(OS::Mac.version).to receive_messages(prerelease?: false, outdated_release?: false)
      stub_const("ARGV", [])
    end

    it "accepts current Intel Homebrew at /usr/local" do
      allow(Hardware::CPU).to receive_messages(arm?: false, intel?: true)
      stub_const("HOMEBREW_PREFIX", Pathname("/usr/local"))

      expect(described_class.default_prefix_issue_reports?).to be(true)
    end

    it "keeps the Apple Silicon /opt/homebrew clause" do
      allow(Hardware::CPU).to receive_messages(arm?: true, intel?: false)
      stub_const("HOMEBREW_PREFIX", Pathname("/opt/homebrew"))

      expect(described_class.default_prefix_issue_reports?).to be(true)
    end

    it "rejects Intel Homebrew outside /usr/local" do
      allow(Hardware::CPU).to receive_messages(arm?: false, intel?: true)
      stub_const("HOMEBREW_PREFIX", Pathname("/opt/homebrew"))

      expect(described_class.default_prefix_issue_reports?).to be(false)
    end

    it "rejects Apple Silicon Homebrew at /usr/local" do
      allow(Hardware::CPU).to receive_messages(arm?: true, intel?: false)
      stub_const("HOMEBREW_PREFIX", Pathname("/usr/local"))

      expect(described_class.default_prefix_issue_reports?).to be(false)
    end

    it "rejects prerelease, outdated and custom compiler builds" do
      allow(Hardware::CPU).to receive_messages(arm?: false, intel?: true)
      stub_const("HOMEBREW_PREFIX", Pathname("/usr/local"))

      allow(OS::Mac.version).to receive(:prerelease?).and_return(true)
      expect(described_class.default_prefix_issue_reports?).to be(false)

      allow(OS::Mac.version).to receive_messages(prerelease?: false, outdated_release?: true)
      expect(described_class.default_prefix_issue_reports?).to be(false)

      allow(OS::Mac.version).to receive_messages(prerelease?: false, outdated_release?: false)
      stub_const("ARGV", ["--cc=gcc"])
      expect(described_class.default_prefix_issue_reports?).to be(false)
    end
  end

  it "detects nix-darwin from a Nix store Brewfile" do
    mktmpdir do |prefix|
      stub_const("HOMEBREW_PREFIX", prefix)
      stub_const("HOMEBREW_REPOSITORY", prefix/"Library/Homebrew")
      stub_const("ARGV", ["bundle", "--file=/nix/store/example-Brewfile"])

      expect(described_class.nix_managed_homebrew?).to be(true)
      expect(described_class.nix_managed_homebrew_issues_url)
        .to eq("https://github.com/nix-darwin/nix-darwin/issues")
    end
  end
end
