# Thor SCMVersion

Thor tasks to manage a VERSION file based on SCM tags, for use in continuous delivery
pipelines.

## Installation

Add this line to your application's Gemfile:

    gem 'thor-scmversion'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install thor-scmversion

## Usage

And then get a list of your thor tasks

    $ thor list

    version
    -------
    thor version:bump TYPE  # Bump version number

Type can be major, minor, or patch.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Contributors

* Michael Ivey <ivey@gweezlebur.com>
* Kyle Allan <kallan@riotgames.com>
* Josiah Kiehl <josiah@skirmisher.net>
* Based on code developed by Jamie Winsor <jamie@vialstudios.com>
* Originally derived from some Bundler internals by Yehuda Katz
