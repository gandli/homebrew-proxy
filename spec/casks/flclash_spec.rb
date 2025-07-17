require 'rspec'

describe 'FlClash Cask' do
  let(:cask_file_path) { 'Casks/flclash.rb' }
  let(:cask_content) { File.read(cask_file_path) }

  describe 'cask file structure' do
    it 'exists and is readable' do
      expect(File.exist?(cask_file_path)).to be true
      expect(File.readable?(cask_file_path)).to be true
    end

    it 'is a valid Ruby file' do
      expect { load cask_file_path }.not_to raise_error
    end

    it 'contains the cask declaration' do
      expect(cask_content).to include('cask "flclash"')
    end

    it 'defines version correctly' do
      expect(cask_content).to match(/version\s+"0\.8\.86"/)
    end

    it 'has architecture mapping' do
      expect(cask_content).to include('arch arm: "arm64", intel: "amd64"')
    end

    it 'has proper cask structure' do
      expect(cask_content).to include('cask "flclash" do')
      expect(cask_content).to include('end')
    end
  end

  describe 'version validation' do
    let(:version) { cask_content.match(/version\s+"([^"]+)"/)[1] }

    it 'has semantic version format' do
      expect(version).to match(/^\d+\.\d+\.\d+$/)
    end

    it 'version is not empty' do
      expect(version).not_to be_empty
    end

    it 'version contains only digits and dots' do
      expect(version).to match(/^[\d.]+$/)
    end

    it 'has three version components' do
      parts = version.split('.')
      expect(parts.length).to eq(3)
      parts.each { |part| expect(part).to match(/^\d+$/) }
    end

    it 'has expected version value' do
      expect(version).to eq('0.8.86')
    end
  end

  describe 'SHA256 checksums' do
    let(:arm_sha_match) { cask_content.match(/sha256\s+arm:\s+"([^"]+)"/) }
    let(:intel_sha_match) { cask_content.match(/intel:\s+"([^"]+)"/) }
    let(:arm_sha) { arm_sha_match[1] if arm_sha_match }
    let(:intel_sha) { intel_sha_match[1] if intel_sha_match }

    it 'has SHA256 checksums defined' do
      expect(cask_content).to include('sha256 arm:')
      expect(cask_content).to include('intel:')
    end

    it 'has valid SHA256 format for ARM' do
      expect(arm_sha).to match(/^[a-f0-9]{64}$/)
    end

    it 'has valid SHA256 format for Intel' do
      expect(intel_sha).to match(/^[a-f0-9]{64}$/)
    end

    it 'checksums are not empty' do
      expect(arm_sha).not_to be_empty
      expect(intel_sha).not_to be_empty
    end

    it 'checksums are not placeholder values' do
      expect(arm_sha).not_to eq('0' * 64)
      expect(intel_sha).not_to eq('0' * 64)
    end

    it 'checksums are valid hexadecimal strings' do
      expect(arm_sha).to match(/\A[0-9a-f]{64}\z/)
      expect(intel_sha).to match(/\A[0-9a-f]{64}\z/)
    end

    it 'both checksums have exactly 64 characters' do
      expect(arm_sha.length).to eq(64)
      expect(intel_sha.length).to eq(64)
    end

    it 'has expected ARM checksum' do
      expect(arm_sha).to eq('9921b38cf6bf9d2c22893bb748f792c6932339a7906d8db51f0c50bd9f61e8fa')
    end

    it 'has expected Intel checksum' do
      expect(intel_sha).to eq('9921b38cf6bf9d2c22893bb748f792c6932339a7906d8db51f0c50bd9f61e8fa')
    end
  end

  describe 'URL structure' do
    let(:url_match) { cask_content.match(/url\s+"([^"]+)"/) }
    let(:url_template) { url_match[1] if url_match }

    it 'has URL defined' do
      expect(cask_content).to include('url "')
    end

    it 'follows GitHub releases URL pattern' do
      expected_pattern = %r{https://github\.com/chen08209/FlClash/releases/download/v\#\{version\}/FlClash-\#\{version\}-macos-\#\{arch\}\.dmg}
      expect(url_template).to match(expected_pattern)
    end

    it 'uses HTTPS protocol' do
      expect(url_template).to start_with('https://')
    end

    it 'includes version interpolation' do
      expect(url_template).to include('#{version}')
    end

    it 'includes architecture interpolation' do
      expect(url_template).to include('#{arch}')
    end

    it 'has proper file extension' do
      expect(url_template).to end_with('.dmg')
    end

    it 'contains GitHub repository path' do
      expect(url_template).to include('chen08209/FlClash')
    end

    it 'has expected URL template' do
      expect(url_template).to eq('https://github.com/chen08209/FlClash/releases/download/v#{version}/FlClash-#{version}-macos-#{arch}.dmg')
    end
  end

  describe 'app installation' do
    let(:app_match) { cask_content.match(/app\s+"([^"]+)"/) }
    let(:app_name) { app_match[1] if app_match }

    it 'has app directive' do
      expect(cask_content).to include('app "')
    end

    it 'specifies correct app name' do
      expect(app_name).to end_with('.app')
    end

    it 'app name is lowercase' do
      expect(app_name).to eq('flclash.app')
    end

    it 'app name matches cask token' do
      expect(app_name).to start_with('flclash')
    end
  end

  describe 'metadata' do
    let(:name_match) { cask_content.match(/name\s+"([^"]+)"/) }
    let(:desc_match) { cask_content.match(/desc\s+"([^"]+)"/) }
    let(:homepage_match) { cask_content.match(/homepage\s+"([^"]+)"/) }
    let(:app_name) { name_match[1] if name_match }
    let(:description) { desc_match[1] if desc_match }
    let(:homepage) { homepage_match[1] if homepage_match }

    it 'has proper application name' do
      expect(app_name).to eq('FlClash')
      expect(app_name).not_to be_empty
    end

    it 'has descriptive description' do
      expect(description).to eq('Proxy client based on ClashMeta')
      expect(description).to include('Proxy')
      expect(description).to include('ClashMeta')
    end

    it 'has valid homepage URL' do
      expect(homepage).to eq('https://github.com/chen08209/FlClash')
      expect(homepage).to start_with('https://')
      expect(homepage).to include('github.com')
    end

    it 'homepage matches download URL domain' do
      expect(homepage).to include('chen08209/FlClash')
    end
  end

  describe 'livecheck configuration' do
    it 'has livecheck block' do
      expect(cask_content).to include('livecheck do')
    end

    it 'uses URL reference for livecheck' do
      expect(cask_content).to include('url :url')
    end

    it 'uses GitHub latest strategy' do
      expect(cask_content).to include('strategy :github_latest')
    end

    it 'has properly closed livecheck block' do
      livecheck_start = cask_content.index('livecheck do')
      livecheck_end = cask_content.index('end', livecheck_start)
      expect(livecheck_start).not_to be_nil
      expect(livecheck_end).not_to be_nil
    end
  end

  describe 'zap (uninstall) configuration' do
    let(:zap_section) { cask_content.match(/zap trash: \[(.*?)\]/m) }
    let(:zap_items) { zap_section[1].scan(/"([^"]+)"/).flatten if zap_section }

    it 'has zap configuration' do
      expect(cask_content).to include('zap trash: [')
    end

    it 'has correct number of trash items' do
      expect(zap_items.length).to eq(3)
    end

    it 'all trash paths start with home directory' do
      zap_items.each do |path|
        expect(path).to start_with('~/')
      end
    end

    it 'includes Application Support directory' do
      expect(zap_items).to include('~/Library/Application Support/com.follow.clash/')
    end

    it 'includes preferences file' do
      expect(zap_items).to include('~/Library/Preferences/com.follow.clash.plist')
    end

    it 'includes saved application state' do
      expect(zap_items).to include('~/Library/Saved Application State/com.follow.clash.savedState/')
    end

    it 'uses consistent bundle identifier' do
      bundle_id = 'com.follow.clash'
      zap_items.each do |path|
        expect(path).to include(bundle_id) if path.include?('com.')
      end
    end

    it 'follows macOS library path conventions' do
      zap_items.each do |path|
        expect(path).to include('~/Library/') if path.start_with('~/')
      end
    end

    it 'has proper trailing slashes for directories' do
      directory_paths = zap_items.select { |path| path.include?('Application Support') || path.include?('savedState') }
      directory_paths.each do |path|
        expect(path).to end_with('/')
      end
    end
  end

  describe 'architecture support' do
    let(:arch_match) { cask_content.match(/arch\s+arm:\s+"([^"]+)",\s+intel:\s+"([^"]+)"/) }
    let(:arm_arch) { arch_match[1] if arch_match }
    let(:intel_arch) { arch_match[2] if arch_match }

    it 'has architecture mapping' do
      expect(cask_content).to include('arch arm:')
      expect(cask_content).to include('intel:')
    end

    it 'supports ARM architecture' do
      expect(arm_arch).to eq('arm64')
    end

    it 'supports Intel architecture' do
      expect(intel_arch).to eq('amd64')
    end

    it 'uses correct architecture identifiers' do
      expect(arm_arch).to match(/^(arm64|amd64)$/)
      expect(intel_arch).to match(/^(arm64|amd64)$/)
    end
  end

  describe 'cask naming conventions' do
    let(:cask_token_match) { cask_content.match(/cask\s+"([^"]+)"/) }
    let(:cask_token) { cask_token_match[1] if cask_token_match }

    it 'follows Homebrew cask naming' do
      expect(cask_token).to match(/^[a-z0-9\-]+$/)
    end

    it 'token is lowercase' do
      expect(cask_token).to eq(cask_token.downcase)
    end

    it 'token matches expected value' do
      expect(cask_token).to eq('flclash')
    end
  end

  describe 'security validations' do
    let(:url_match) { cask_content.match(/url\s+"([^"]+)"/) }
    let(:homepage_match) { cask_content.match(/homepage\s+"([^"]+)"/) }
    let(:url_template) { url_match[1] if url_match }
    let(:homepage) { homepage_match[1] if homepage_match }

    it 'uses secure URLs' do
      expect(url_template).to start_with('https://')
      expect(homepage).to start_with('https://')
    end

    it 'has checksums for verification' do
      expect(cask_content).to include('sha256 arm:')
      expect(cask_content).to include('intel:')
    end

    it 'URL and homepage use same domain' do
      expect(url_template).to include('github.com')
      expect(homepage).to include('github.com')
    end
  end

  describe 'edge cases and error conditions' do
    it 'handles version interpolation correctly' do
      url_match = cask_content.match(/url\s+"([^"]+)"/)
      expect(url_match[1]).to include('#{version}')
    end

    it 'handles architecture interpolation correctly' do
      url_match = cask_content.match(/url\s+"([^"]+)"/)
      expect(url_match[1]).to include('#{arch}')
    end

    it 'has consistent indentation' do
      lines = cask_content.split("\n")
      indented_lines = lines.select { |line| line.start_with?('  ') }
      expect(indented_lines).not_to be_empty
    end

    it 'has proper Ruby syntax' do
      expect { eval(cask_content) }.not_to raise_error
    end

    it 'handles multi-line sha256 definition' do
      expect(cask_content).to match(/sha256\s+arm:.*intel:/m)
    end

    it 'handles trailing comma in zap array' do
      expect(cask_content).to include('savedState/",')
    end
  end

  describe 'integration tests' do
    it 'has all required cask elements' do
      required_elements = ['version', 'sha256', 'url', 'name', 'desc', 'homepage', 'app']
      required_elements.each do |element|
        expect(cask_content).to include(element)
      end
    end

    it 'livecheck configuration is valid' do
      expect(cask_content).to match(/livecheck do.*url :url.*strategy :github_latest.*end/m)
    end

    it 'zap configuration follows best practices' do
      locations = ['Application Support', 'Preferences', 'Saved Application State']
      locations.each do |location|
        expect(cask_content).to include(location)
      end
    end

    it 'has proper file structure' do
      expect(cask_content).to start_with('cask "flclash" do')
      expect(cask_content).to end_with("end\n")
    end
  end

  describe 'bundle identifier validation' do
    let(:bundle_id) { 'com.follow.clash' }

    it 'uses consistent bundle identifier format' do
      expect(bundle_id).to match(/^[a-z]+\.[a-z]+\.[a-z]+$/)
    end

    it 'bundle identifier appears in all zap paths' do
      zap_paths = cask_content.scan(/"(~\/Library\/[^"]+)"/).flatten
      bundle_paths = zap_paths.select { |path| path.include?('com.') }
      bundle_paths.each do |path|
        expect(path).to include(bundle_id)
      end
    end

    it 'follows reverse domain notation' do
      parts = bundle_id.split('.')
      expect(parts.length).to eq(3)
      expect(parts[0]).to eq('com')
    end
  end

  describe 'file format validation' do
    it 'uses proper Ruby string quoting' do
      expect(cask_content).to match(/cask "flclash"/)
      expect(cask_content).to match(/version "[^"]+"/)
      expect(cask_content).to match(/name "[^"]+"/)
    end

    it 'has proper line endings' do
      expect(cask_content).to end_with("\n")
    end

    it 'uses consistent spacing' do
      expect(cask_content).to include('arch arm: "arm64", intel: "amd64"')
      expect(cask_content).to include('sha256 arm:')
    end

    it 'has proper indentation throughout' do
      lines = cask_content.split("\n")
      content_lines = lines[1..-2] # Skip first and last lines
      content_lines.each do |line|
        next if line.strip.empty?
        expect(line).to start_with('  ')
      end
    end
  end

  describe 'version-specific validations' do
    it 'version matches expected pattern for this app' do
      version = cask_content.match(/version\s+"([^"]+)"/)[1]
      expect(version).to match(/^0\.\d+\.\d+$/) # Starts with 0.x.x pattern
    end

    it 'checksums are identical for both architectures' do
      arm_sha = cask_content.match(/sha256\s+arm:\s+"([^"]+)"/)[1]
      intel_sha = cask_content.match(/intel:\s+"([^"]+)"/)[1]
      expect(arm_sha).to eq(intel_sha)
    end
  end
end