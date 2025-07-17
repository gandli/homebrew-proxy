cask "flclash" do
  arch arm: "arm64", intel: "amd64"

  version "0.8.86"
  sha256 arm: "9921b38cf6bf9d2c22893bb748f792c6932339a7906d8db51f0c50bd9f61e8fa",
         intel: "cfd733d54b3520cc5f2a38ab02d6dc06185182fafd0861e334becbd568ea45c9"

  url "https://github.com/chen08209/FlClash/releases/download/v#{version}/FlClash-#{version}-macos-#{arch}.dmg"
  name "FlClash"
  desc "Proxy client based on ClashMeta"
  homepage "https://github.com/chen08209/FlClash"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "flclash.app"

  zap trash: [
    "~/Library/Application Support/com.follow.clash/",
    "~/Library/Preferences/com.follow.clash.plist",
    "~/Library/Saved Application State/com.follow.clash.savedState/",
  ]
end
