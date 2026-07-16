cask "latch" do
  version "0.2.3"
  sha256 "6a4e86474d6e15d87d4fee7d7d09604245b6f78f40ca1a42ed2691993e9892df"

  url "https://github.com/MiladNalbandi/latch/releases/download/v#{version}/Latch-#{version}.dmg"
  name "Latch"
  desc "Friendly, private clipboard manager"
  homepage "https://github.com/MiladNalbandi/latch"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates false
  depends_on macos: :ventura

  app "Latch.app"

  postflight do
    # Latch is ad-hoc signed, not notarized, so Gatekeeper quarantines it after
    # download. Clear the flag so `brew install --cask latch` "just works".
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Latch.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Application Support/Latch",
    "~/Library/Caches/com.latch.app",
    "~/Library/Preferences/com.latch.app.plist",
    "~/Library/Saved Application State/com.latch.app.savedState",
  ]
end
