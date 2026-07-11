# Source of truth for the Shoirhi/homebrew-tap tap.
#
# The `url` and `sha256` lines are rewritten automatically by the release
# workflow (.github/workflows/release.yml) on every tagged release and pushed
# to Shoirhi/homebrew-tap as Formula/macos-website-blocker.rb. Edit the rest of
# the formula here, not in the tap.
class MacosWebsiteBlocker < Formula
  desc "Hosts-layer website blocker for macOS (Chrome, Safari, Firefox)"
  homepage "https://github.com/Shoirhi/macos-website-blocker"
  url "https://github.com/Shoirhi/macos-website-blocker/releases/download/v1.2.0/macos-website-blocker-1.2.0.tar.gz"
  sha256 "86c8044f7d2841e4b4358e65139a75bc01943107ca6f361b8e61526ba807da70"
  license "MIT"

  depends_on :macos

  def install
    # Homebrew runs unprivileged, but this tool must edit /etc/hosts and load a
    # root LaunchDaemon. So we only stage the payload here; the privileged setup
    # is performed by install.sh via sudo (see the caveats / `brew info`).
    libexec.install Dir["*"]
    (bin/"macos-website-blocker-setup").write <<~SH
      #!/bin/bash
      exec sudo "#{opt_libexec}/install.sh" "$@"
    SH
  end

  def caveats
    <<~EOS
      macos-website-blocker edits /etc/hosts and installs a root LaunchDaemon,
      which requires administrator privileges. Homebrew only staged the files.

      Finish the install (seeds DoH endpoints and starts the daemon):

        macos-website-blocker-setup --seed

      That is a thin wrapper around:

        sudo "#{opt_libexec}/install.sh" --seed

      After setup, the real commands live in /usr/local/bin:

        sudo macos-website-blocker-add x.com reddit.com
        macos-website-blocker-status
        sudo macos-website-blocker-lock

      The config profiles (close the DoH bypass, plus an optional Cloudflare
      for Families DNS filter) are staged under libexec, not your working
      directory. Reveal one in Finder, then double-click it to install:

        open -R "#{opt_libexec}/profiles/macos-website-blocker-doh.mobileconfig"

      Approve it in System Settings > General > Device Management.

      To remove everything:

        sudo "#{opt_libexec}/uninstall.sh"
    EOS
  end

  test do
    assert_path_exists libexec/"install.sh"
    assert_path_exists libexec/"bin/macos-website-blocker-sync"
  end
end
