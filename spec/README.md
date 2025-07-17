# FlClash Cask Tests

This directory contains comprehensive unit tests for the FlClash Homebrew cask.

## Testing Framework

The tests are written using **RSpec 3.x**, which is the standard testing framework for Ruby applications.

## Running Tests

To run the tests:

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rake spec

# Run tests with detailed output
bundle exec rspec spec/casks/flclash_spec.rb --format documentation

# Run specific test group
bundle exec rspec spec/casks/flclash_spec.rb --example "version validation"
```

## Test Coverage

The test suite covers:

- **Cask file structure validation**: Ensures the cask file exists, is readable, and has proper Ruby syntax
- **Version validation**: Validates semantic versioning format and consistency
- **SHA256 checksum validation**: Verifies checksums are properly formatted and not placeholder values
- **URL structure validation**: Ensures URLs follow GitHub releases pattern with proper interpolation
- **App installation validation**: Verifies app directive and naming conventions
- **Metadata validation**: Checks name, description, and homepage fields
- **Livecheck configuration**: Validates automatic update checking setup
- **Zap configuration**: Ensures proper uninstall cleanup paths
- **Architecture support**: Validates ARM and Intel architecture mappings
- **Security validations**: Ensures HTTPS usage and checksum presence
- **Edge cases and error conditions**: Tests various failure scenarios
- **Integration tests**: Validates overall cask structure and compliance
- **Bundle identifier validation**: Ensures consistent macOS bundle identifiers
- **File format validation**: Checks Ruby syntax and formatting conventions

## Test Structure

Tests are organized into logical groups:
- File structure and syntax
- Version and checksum validation
- URL and download validation
- Installation and metadata
- Configuration validation
- Security and compliance
- Edge cases and error handling