Feature: Guessing the level of a bump
  As a user
  I want a command that figures out a major, minor or patch bump based on commit logs
  So that I can control semver changes while still using a CI server

  Scenario Outline: changeset tags
    Given I have a git project of version '<starting version>'
    And a commit with the message "<message 1>" on the "master" branch
    And a commit with the message "<message 2>" on the "master" branch
    And a commit with the message "<message 3>" on the "master" branch
    When I run `bundle exec thor version:bump auto` from the temp directory
    Then the version should be '<resulting version>'
    And I run `git push origin master --tags` from the temp directory
    And the <scm> server version should be '<resulting version>'

  Examples:
    | starting version | scm | message 1 | message 2          | message 3               | resulting version |
    |            1.2.3 | git | untagged  | another commit     | another change          | 1.2.3+build.2     |
    |            1.2.3 | git | untagged  | another commit     | big change [major]      | 2.0.0             |
    |            1.2.3 | git | untagged  | another commit     | big change [MAJOR]      | 2.0.0             |
    |            1.2.3 | git | untagged  | another commit     | smallish change [minor] | 1.3.0             |
    |            1.2.3 | git | untagged  | big change [major] | smallish change [minor] | 2.0.0             |
    |            1.2.3 | git | untagged  | another commit     | pre [prerelease]        | 1.2.4-alpha.1     |
    |            1.2.3 | git | untagged  | another commit     | pre [prerelease beta]   | 1.2.4-beta.1      |
    |     1.2.3-beta.1 | git | untagged  | another commit     | pre [prerelease beta]   | 1.2.3-beta.2      |
    |     1.2.3-beta.1 | git | untagged  | another commit     | pre [prerelease someth] | 1.2.3-someth.1    |
    |     1.2.3-beta.1 | git | untagged  | another commit     | pre [prerelease]        | 1.2.3-beta.2      |
    |            1.2.3 | git | untagged  | another commit     | build [patch]           | 1.2.4             |
    |            1.2.3 | git | untagged  | another commit     | big change #major       | 2.0.0             |
    |            1.2.3 | git | untagged  | another commit     | smallish change #minor  | 1.3.0             |
    |            1.2.3 | git | untagged  | big change #major  | smallish change #minor  | 2.0.0             |
    |            1.2.3 | git | untagged  | another commit     | pre #prerelease         | 1.2.4-alpha.1     |
    |            1.2.3 | git | untagged  | another commit     | pre #prerelease-beta    | 1.2.4-beta.1      |
    |     1.2.3-beta.1 | git | untagged  | another commit     | pre #prerelease-beta    | 1.2.3-beta.2      |
    |     1.2.3-beta.1 | git | untagged  | another commit     | pre #prerelease-someth  | 1.2.3-someth.1    |
    |     1.2.3-beta.1 | git | untagged  | another commit     | pre #prerelease         | 1.2.3-beta.2      |
    |            1.2.3 | git | untagged  | another commit     | build #patch            | 1.2.4             |
