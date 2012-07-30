Feature: Guessing the level of a bump
  As a user
  I want a command that figures out a major, minor or patch bump based on commit logs
  So that I can control semver changes while still using a CI server

  Background:
    Given I have a git project of version '1.2.3'

  Scenario: changeset with no tags
    Given a commit message "This is an untagged commit"
    And a commit message "this is another commit"
    And a commit message "this is another change to the project"
    When I run `bundle exec thor version:bump auto` from the temp directory
    Then the version should be '1.2.4'
    And the origin version should be '1.2.4'

  Scenario: changeset with a [major] tag
    Given a commit message "This is an untagged commit"
    And a commit message "this is another commit"
    And a commit message "this is a big change to the project [major]"
    When I run `bundle exec thor version:bump auto` from the temp directory
    Then the version should be '2.0.0'
    And the origin version should be '2.0.0'

  Scenario: changeset with a [minor] tag
    Given a commit message "This is an untagged commit"
    And a commit message "this is another commit"
    And a commit message "this is a smallish change to the project [minor]"
    When I run `bundle exec thor version:bump auto` from the temp directory
    Then the version should be '1.3.0'
    And the origin version should be '1.3.0'

  Scenario: changeset with a [major] and [minor] tag
    Given a commit message "This is an untagged commit"
    And a commit message "this is another commit"
    And a commit message "this is a big change to the project [major]"
    And a commit message "this is a smallish change to the project [minor]"
    When I run `bundle exec thor version:bump auto` from the temp directory
    Then the version should be '2.0.0'
    And the origin version should be '2.0.0'

  Scenario: changeset with a #major tag
    Given a commit message "This is an untagged commit"
    And a commit message "this is another commit"
    And a commit message "this is a big change to the project #major"
    When I run `bundle exec thor version:bump auto` from the temp directory
    Then the version should be '2.0.0'
    And the origin version should be '2.0.0'

  Scenario: changeset with a #minor tag
    Given a commit message "This is an untagged commit"
    And a commit message "this is another commit"
    And a commit message "this is a smallish change to the project #minor"
    When I run `bundle exec thor version:bump auto` from the temp directory
    Then the version should be '1.3.0'
    And the origin version should be '1.3.0'

  Scenario: changeset with a #major and #minor tag
    Given a commit message "This is an untagged commit"
    And a commit message "this is another commit"
    And a commit message "this is a big change to the project #major"
    And a commit message "this is a smallish change to the project #minor"
    When I run `bundle exec thor version:bump auto` from the temp directory
    Then the version should be '2.0.0'
    And the origin version should be '2.0.0'

  Scenario: changeset with a [MAJOR] tag
    Given a commit message "This is an untagged commit"
    And a commit message "this is another commit"
    And a commit message "this is a big change to the project [MAJOR]"
    When I run `bundle exec thor version:bump auto` from the temp directory
    Then the version should be '2.0.0'
    And the origin version should be '2.0.0'
