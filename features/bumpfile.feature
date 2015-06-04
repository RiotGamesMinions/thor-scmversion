Feature: Bumpfile
  As a user
  I want to be able to bump the version of a project's with a simple command
  And write it to a local file named VERSION
  So that I don't have to do it manually

  Scenario Outline: Bumping a version
    Given I have a <scm> project with VERSION file of version '<starting version>'
    When I run `bundle exec thor version:bumpfile <bump type> <flags>` from the temp directory
    Then the VERSION file should be '<resulting version>'

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
