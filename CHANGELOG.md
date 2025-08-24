# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-01-XX

### Added
- **Dependency Injection Support**: Complete DI implementation using get_it
  - Service locator pattern for dependency management
  - Interface-based design (IReferralService) for better testability
  - Singleton management and lifecycle handling
  - Configuration management for API keys

- **App Links Deep Link Handling**: Replaced uni_links with app_links
  - Full parameter extraction from deep links
  - Support for both custom schemes and Universal Links
  - Initial link detection for app launch
  - Comprehensive error handling and logging
  - Flexible routing based on paths and parameters

- **Enhanced Referral Service**:
  - New methods: `startLinkListenerWithParameters()`, `getInitialLink()`, `getInitialToken()`
  - Backward compatibility with existing token-based methods
  - Improved error handling and response parsing
  - Updated backend URL to short-refer.me

- **Comprehensive Documentation**:
  - Dependency Injection Guide (DEPENDENCY_INJECTION_GUIDE.md)
  - App Links Guide (APP_LINKS_GUIDE.md)
  - Implementation Summary (IMPLEMENTATION_SUMMARY.md)
  - App Links Implementation Summary (APP_LINKS_IMPLEMENTATION_SUMMARY.md)
  - Updated main README with modern design and comprehensive examples

- **Advanced Examples**:
  - Complete dependency injection examples
  - App links deep link handling examples
  - Advanced routing and parameter handling
  - Testing utilities and mock services
  - Widget integration examples

- **Testing Support**:
  - Unit tests for dependency injection
  - Mock service implementations
  - Testing utilities and helpers
  - Comprehensive test coverage

### Changed
- **Package Name**: Updated from referral_client to refer_me
- **Dependencies**: 
  - Added `get_it: ^7.6.7` for dependency injection
  - Replaced `uni_links2` with `app_links: ^3.4.5`
  - Updated all dependencies to latest compatible versions
- **Backend URL**: Changed to https://short-refer.me
- **API Response Handling**: Updated to handle new response format with success/data structure

### Removed
- **uni_links2**: Replaced with app_links for better deep link handling
- **install_referrer**: Removed due to Android compatibility issues

### Fixed
- **Deep Link Handling**: Resolved issues with parameter extraction
- **Error Handling**: Improved error handling and logging
- **Platform Compatibility**: Enhanced cross-platform support
- **Documentation**: Updated all documentation to reflect current implementation

## [0.0.1] - 2024-01-XX

### Added
- Initial project setup
- Basic referral client functionality
- Android Install Referrer support
- iOS Universal Links support
- Basic documentation and examples
