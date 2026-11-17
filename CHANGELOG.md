# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2026-11-18

### Added
- Support for OmniAuth 2.0 series (`omniauth ~> 2.0`, `omniauth-oauth2 ~> 1.7, >= 1.7.1`). (#32, #34)
- Support for fetching verified user email (`info[:email]`) via LINE's `/oauth2/v2.1/verify` endpoint when `id_token` is present (e.g., with `scope: 'profile openid email'`). (#25, #31)
- Include `raw_info` in `extra` auth hash (`extra['raw_info']`).
- GitHub Actions CI workflow for Ruby 3.1, 3.2, 3.3, and 3.4, plus automated RubyGems Trusted Publishing workflow and Dependabot configuration. (#28, #39)
- Documentation for OmniAuth 2.0 `POST /auth/line` login button, `email` scope, and `bot_prompt` option. (#30, #36)
- Added `.gitignore` and `LICENSE`. (#15)

### Fixed
- Fixed duplicated `script_name` in `callback_url` under OmniAuth 2.0. (#32, #34)
- Fixed `options[:client_options][:site]` remaining `'https://api.line.me'` on subsequent login requests after a callback phase. (#8)
- Replaced `JSON.load` with `JSON.parse` for safer parsing of API responses.

## [0.1.0] - 2021-02-11

### Fixed
- Override `callback_url` to fix `redirect_uri` mismatch with `omniauth-oauth2` >= 1.4.0. (#26)

## [0.0.5] - 2020-09-09

### Changed
- Updated `json` dependency (`>= 2.3.0`), `bundler` (`~> 2.0`), and loosened `omniauth-oauth2` (`~> 1.3`). (#21)
- Updated for LINE Login v2.1 (OpenID Connect). (#7)
