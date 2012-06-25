Feature: Bump
  As a user
  I want to be able to bump the version of a project's with a simple command
  So that I don't have to do it manually

  Scenario: Bumping a patch version in Git
    Given I have a git project of version '1.0.0'
    When I run `bundle exec thor version:bump patch` from the temp directory
    Then the version should be '1.0.1'
    And the origin version should be '1.0.1'

   Scenario: Bumping a minor version in Git
     Given I have a git project of version '1.0.0'
     When I run `bundle exec thor version:bump minor` from the temp directory
     Then the version should be '1.1.0'
     And the origin version should be '1.1.0'

   Scenario: Bumping a major version in Git
     Given I have a git project of version '1.0.0'
     When I run `bundle exec thor version:bump major` from the temp directory
     Then the version should be '2.0.0'
     And the origin version should be '2.0.0'

   Scenario: Bumping a minor version in Git should reset the patch version
     Given I have a git project of version '1.1.5'
     When I run `bundle exec thor version:bump minor` from the temp directory
     Then the version should be '1.2.0'
     And the origin version should be '1.2.0'

   Scenario: Bumping a major version in Git should reset the patch and minor versions
     Given I have a git project of version '1.1.5'
     When I run `bundle exec thor version:bump major` from the temp directory
     Then the version should be '2.0.0'
     And the origin version should be '2.0.0'

   @p4 @wip
   Scenario: Bumping a patch version in Perforce
     Given I have a Perforce project of version '1.0.0'
     When I run `bundle exec thor version:bump patch` from the Perforce project directory
     Then the version should be '1.0.1' in the Perforce project directory
     And the p4 server version should be '1.0.1'
  
   @p4
   Scenario: Bumping a minor version in Perforce
     Given I have a Perforce project of version '1.0.0'
     When I run `bundle exec thor version:bump minor` from the Perforce project directory
     Then the version should be '1.1.0' in the Perforce project directory
     And the p4 server version should be '1.1.0'
  
   @p4
   Scenario: Bumping a major version in Perforce
     Given I have a Perforce project of version '1.0.0'
     When I run `bundle exec thor version:bump major` from the Perforce project directory
     Then the version should be '2.0.0' in the Perforce project directory
     And the p4 server version should be '2.0.0'
  
   @p4
   Scenario: Bumping a minor version in Perforce should reset the patch version
     Given I have a Perforce project of version '1.1.5'
     When I run `bundle exec thor version:bump minor` from the Perforce project directory
     Then the version should be '1.2.0' in the Perforce project directory
     And the p4 server version should be '1.2.0'

   @p4
   Scenario: Bumping a major version in Perforce should reset the patch and minor versions
     Given I have a Perforce project of version '1.1.5'
     When I run `bundle exec thor version:bump major` from the Perforce project directory
     Then the version should be '2.0.0' in the Perforce project directory
     And the p4 server version should be '2.0.0'
