cask "converge" do
  version "1.0.0"
  sha256 ""

  url "https://github.com/rckbrcls/converge/releases/download/v#{version}/Converge-macos-universal-v#{version}.zip"
  name "Converge"
  desc "Pomodoro Timer for macOS"
  homepage "https://github.com/rckbrcls/converge"

  app "Converge.app"

  zap trash: [
    "~/Library/Application Support/polterware.converge",
    "~/Library/Preferences/polterware.converge.plist",
  ]
end
