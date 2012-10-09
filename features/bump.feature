Feature: Bump
  As a user
  I want to be able to bump the version of a project's with a simple command
  So that I don't have to do it manually

  Scenario Outline: Bumping a version
    Given I have a <scm> project of version '<starting version>'
    When I run `bundle exec thor version:bump <bump type>` from the temp directory
    Then the version should be '<resulting version>'
    And the <scm> server version should be '<resulting version>'

    Examples:
      | scm | starting version | bump type | resulting version |
      | git |            1.0.0 | patch     |             1.0.1 |
      | git |            1.0.0 | minor     |             1.1.0 |
      | git |            1.0.0 | major     |             2.0.0 |
      | git |            1.1.5 | minor     |             1.2.0 |
      | git |            1.1.5 | major     |             2.0.0 |
      | p4  |            1.0.0 | patch     |             1.0.1 |
      | p4  |            1.0.0 | minor     |             1.1.0 |
      | p4  |            1.0.0 | major     |             2.0.0 |
      | p4  |            1.1.5 | minor     |             1.2.0 |
      | p4  |            1.1.5 | major     |             2.0.0 |

  Scenario: Bumping a patch version in Git when the server has an advanced version not yet fetched
    Given I have a git project of version '1.0.0'
    And the origin version is '1.0.10'
    When I run `bundle exec thor version:bump patch` from the temp directory
    Then the version should be '1.0.11'
    And the git server version should be '1.0.11'
