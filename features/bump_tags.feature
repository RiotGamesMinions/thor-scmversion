Feature: Guessing the level of a bump
  As a user
  I want a command that figures out a major, minor or patch bump based on commit logs
  So that I can control semver changes while still using a CI server

  Background:
    Given I have a git project of version '1.2.3'

  Scenario Outline: changeset tags
    Given a commit message "<message 1>"
    And a commit message "<message 2>"
    And a commit message "<message 3>"
    When I run `bundle exec thor version:bump auto` from the temp directory
    Then the version should be '<resulting version>'
    And the <scm> server version should be '<resulting version>'

  Examples:
    | scm | message 1 | message 2          | message 3               | resulting version |
    | git | untagged  | another commit     | another change          |             1.2.4 |
    | git | untagged  | another commit     | big change [major]      |             2.0.0 |
    | git | untagged  | another commit     | big change [MAJOR]      |             2.0.0 |
    | git | untagged  | another commit     | smallish change [minor] |             1.3.0 |
    | git | untagged  | big change [major] | smallish change [minor] |             2.0.0 |
    | git | untagged  | another commit     | big change #major       |             2.0.0 |
    | git | untagged  | another commit     | smallish change #minor  |             1.3.0 |
    | git | untagged  | big change #major  | smallish change #minor  |             2.0.0 |
