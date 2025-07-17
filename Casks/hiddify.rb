cask "hiddify" do
  version "2.0.5"
  sha256 "71d4314ef0ce9d3bffb423a438ebeb9bae9ec8decfe0e17f5e6327201849e138"

  url "https://github.com/hiddify/hiddify-app/releases/download/v#{version}/Hiddify-MacOS.dmg",
      verified: "github.com/hiddify/"
  name "hiddify"
  desc "Multi-platform auto-proxy client"
  homepage "https://hiddify.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "hiddify.app"

  zap trash: [
    "~/Library/Application Support/app.hiddify.com/",
    "~/Library/Caches/SentryCrash/Hiddify/",
    "~/Library/Preferences/app.hiddify.com.plist",
    "~/Library/Saved Application State/app.hiddify.com.savedState/",
  ]
end
