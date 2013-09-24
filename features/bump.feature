Feature: Bump
  As a user
  I want to be able to bump the version of a project's with a simple command
  So that I don't have to do it manually

  Scenario Outline: Bumping a version
    Given I have a <scm> project of version '<starting version>'
    And there is a version '9.9.9' on another branch
    When I run `bundle exec thor version:bump <bump type> <flags>` from the temp directory
    Then the version should be '<resulting version>'
    And the <scm> server version should be '<resulting version>'

    Examples:
      | scm | starting version | bump type         |     resulting version | flags           |
      | git |            1.0.0 | patch             |                 1.0.1 |                 |
      | git |            1.0.0 | minor             |                 1.1.0 |                 |
      | git |            1.0.0 | major             |                 2.0.0 |                 |
      | git |            1.1.5 | minor             |                 1.2.0 |                 |
      | git |            1.1.5 | major             |                 2.0.0 |                 |
      | git |            1.0.0 | prerelease        |         1.0.1-alpha.1 |                 |
      | git |            1.0.0 | prerelease someth |        1.0.1-someth.1 |                 |
      | git |    1.0.0-alpha.1 | prerelease        |         1.0.0-alpha.2 |                 |
      | git |    1.0.0-alpha.5 | prerelease beta   |          1.0.0-beta.1 |                 |
      | git |    1.0.0-alpha.5 | auto              |         1.0.0-alpha.6 | -d prerelease   |
      | git |            1.0.0 | build             |         1.0.0+build.2 |                 |
      | git |    1.0.0-alpha.3 | build             | 1.0.0-alpha.3+build.2 |                 |
      | git |            1.0.0 | auto              |                 1.0.1 | --default patch |
      | git |            1.0.0 | auto              |                 1.0.1 | -d patch        |
      | git |            1.0.0 | auto              |         1.0.0+build.2 |                 |
      | p4  |            1.0.0 | patch             |                 1.0.1 |                 |
      | p4  |            1.0.0 | minor             |                 1.1.0 |                 |
      | p4  |            1.0.0 | major             |                 2.0.0 |                 |
      | p4  |            1.1.5 | minor             |                 1.2.0 |                 |
      | p4  |            1.1.5 | major             |                 2.0.0 |                 |
 
  Scenario: Bumping a version where there is a nonversion tag
    Given I have a git project of version '1.0.0-alpha.6'
    And there is a tag 'notaversion'
    When I run `bundle exec thor version:bump patch` from the temp directory
    Then the git server version should be '1.0.1'

  Scenario: Bumping a version where the next version that would be bumped to is already tagged in the repository
    Given I have a git project of version '1.0.0'
    And there is a version '1.0.1' on another branch
    When I run `bundle exec thor version:bump patch` from the temp directory and expect a non-zero exit
    Then the git server version should be '1.0.0'

  Scenario: Bumping a patch version in Git when the server has an advanced version not yet fetched
    Given I have a git project of version '1.0.0'
    And the origin version is '1.0.10'
    When I run `bundle exec thor version:bump patch` from the temp directory
    Then the version should be '1.0.11'
    And the git server version should be '1.0.11'

   Scenario: Bumping a version in a git submodule
     Given I have a git project of version '1.2.3'
     And .git is a file pointing to the .git folder in a parent module
     When I run `bundle exec thor version:bump patch ` from the temp directory
     Then the version should be '1.2.4'
     And the git server version should be '1.2.4'
