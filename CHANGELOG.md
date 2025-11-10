# Changelog

The noteworthy changes for each Redbird version are included here. For a
complete changelog, see the git history for each version via the version links.

**To see the dates a version was published see the [hex package page].**

[hex package page]: https://hex.pm/packages/redbird

## 1.0.0 (2025-11-10)


### Bug Fixes

* Failing tests and missing import ([f9d71bd](https://github.com/beam-community/redbird/commit/f9d71bdbe1e98bc3057a4274f7ee032cca77d873))

## [0.7.2](https://github.com/beam-community/redbird/compare/v0.7.1...v0.7.2) (2025-06-25)


### Bug Fixes

* Failing tests and missing import ([f9d71bd](https://github.com/beam-community/redbird/commit/f9d71bdbe1e98bc3057a4274f7ee032cca77d873))

## [0.7.1]

### Fixes

- Avoid resetting the session key with each call to put/4 ([#72]).
  - For a description of issue and fix, see commit [5dc6bc48].
- Fix the broken session expiration test ([#73]).

[#72]: https://github.com/thoughtbot/redbird/pull/72
[#73]: https://github.com/thoughtbot/redbird/pull/73
[5dc6bc48]: https://github.com/thoughtbot/redbird/commit/5dc6bc486096ffbf896c6ced6b9941bfc4c43ea0
[0.7.1]: https://github.com/thoughtbot/redbird/compare/v0.7.0...v0.7.1

## [0.7.0]

### Breaking

- Adds secure keys ([#67]). See commit [299906f].

[#67]: https://github.com/thoughtbot/redbird/pull/67
[299906f]: https://github.com/thoughtbot/redbird/commit/299906f531fca956bca2e6eb507029f6a699c9e7
[0.7.0]: https://github.com/thoughtbot/redbird/compare/v0.6.0...v0.7.0
