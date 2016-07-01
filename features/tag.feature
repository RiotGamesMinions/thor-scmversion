Feature: Tag
  As a user
  I want to be able to create a tag based on the contents of the VERSION file
  So that I don't have to do it manually

  Scenario Outline: Bumping a version
    Given I have a <scm> project with VERSION file of version '<starting version>'
    And there is a version '9.9.9' on another branch
    When I run `bundle exec thor version:tag` from the temp directory
    Then the version should be '<resulting version>'
    And the <scm> server version should be '<resulting version>'

    Examples:
      | scm | starting version       | resulting version     | 
      | git | 1.0.0                  | 1.0.0                 |
      | git | 1.1.0                  | 1.1.0                 |
      | git | 2.0.0                  | 2.0.0                 |
      | git | 1.2.0                  | 1.2.0                 |
      | git | 1.0.0-alpha.1          | 1.0.0-alpha.1         |
      | git | 1.0.0-beta.1           | 1.0.0-beta.1          |
      | git | 1.0.0+build.2          | 1.0.0+build.2         |
      | git | 1.0.0-alpha.3+build.2  | 1.0.0-alpha.3+build.2 |
      | git | 1.0.0+build.2          | 1.0.0+build.2         |
      | p4  | 1.0.1                  | 1.0.1                 |
      | p4  | 1.1.0                  | 1.1.0                 |
      | p4  | 1.2.0                  | 1.2.0                 |
      | p4  | 2.0.0                  | 2.0.0                 |
 
  Scenario: Bumping a version where there is a nonversion tag
    Given I have a git project with VERSION file of version '1.0.0-alpha.6'
    And there is a tag 'notaversion'
    When I run `bundle exec thor version:tag` from the temp directory
    Then the version should be '1.0.0-alpha.6'
    And the git server version should be '1.0.0-alpha.6'

  Scenario: Bumping a version where the next version that would be bumped to is already tagged in the repository
    Given I have a git project with VERSION file of version '0.0.9'
    And there is a tag of version '0.0.9' on the git server
    And there is a tag of version '1.0.0' on the git server
    When I run `bundle exec thor version:tag` from the temp directory and expect a non-zero exit
    Then the version should be '1.0.0'
    And the git server version should be '1.0.0'

  Scenario: Bumping a version in a git submodule
    Given I have a git project with VERSION file of version '1.2.3'
    And .git is a file pointing to the .git folder in a parent module
    When I run `bundle exec thor version:tag` from the temp directory
    Then the version should be '1.2.3'
    And the git server version should be '1.2.3'
