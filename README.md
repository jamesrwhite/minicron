minicron [![Build Status](https://api.travis-ci.org/jamesrwhite/minicron.png)](http://travis-ci.org/jamesrwhite/minicron) [![Code Climate](https://codeclimate.com/github/jamesrwhite/minicron.png)](https://codeclimate.com/github/jamesrwhite/minicron) [![Dependency Status](https://gemnasium.com/jamesrwhite/minicron.png)](https://gemnasium.com/jamesrwhite/minicron) [![Inline docs](http://inch-pages.github.io/github/jamesrwhite/minicron.png)](http://inch-pages.github.io/github/jamesrwhite/minicron)
=======

minicron aims to complement ````cron```` by making it easier to manage and monitor cron jobs, it can largely be thought of as two components that interact together, the CLI and the Hub. The CLI is what is installed on your server(s) and executes your cron command and reports the status back to the Hub. The Hub is the central point where data from one or many instances of the CLI are is recieved and stored in a database. The Hub also provides a web interface to the data and makes it easy to manage your cron jobs.

Installation
-------------

minicron is currently under heavy development, I plan to release version 0.1 to rubygems shortly but I would not recommend relying on it yet. If you wish to test the current version you can clone this repo ````bundle install```` and ````rake install````. Set your database configuration options in ````/etc/minicron.toml```` and you can then ````minicron db load```` to setup the db structure or set it up manually using the [schema dump provided](https://github.com/jamesrwhite/minicron/blob/master/lib/minicron/hub/db/schema.sql).

Requirements
-------------

#### Ruby
- MRI
  - 1.9.3 and above (tested on 1.9.3, 2.0.0, 2.1.0)
- <del>Rubinius</del>
  - <del>Travis builds are run on the latest release</del> [*awaiting bug fix*](https://github.com/rubinius/rubinius/issues/2944)
- JRuby
  - As yet untested


#### Database
- MySQL
- Support for PostgreSQL and SQlite is planned in the future

#### Browser
- I have been testing the web interface in the latest versions of Chrome, Firefox and Safari. I'm currently unsure of how it functions in the various of Internet Explorer but in theory it should support IE9+

#### OS
- Should run on any linux/bsd based OS that the above ruby versions run on.
- No windows support.

Usage
-----

minicron is packaged as a gem and can be interacted with from the command line once you have installed it. The current commands are as follows:

#### Run a command

````
minicron run 'command --options'
````

You can alter the way in which the command alters it's output by passing the --mode option to the run argument with the value of either 'line' or 'char'. Most of the time you'll want to use the default value of line but for some commands e.g a script that outputs a progress bar minicron printing the output each character at a time can be useful.

````
minicron run 'mysqldump db > backup.sql'
````

The global ````--verbose```` option can also be passed to the ````run```` argument like so ````minicron run --verbose ls````, for further information see ````minicron help run````.

#### Get help

Running ````minicron```` with no arguments is an alias to running ````minicron help````, ````minicron -h```` or ````minicron --help````. You can also use the help argument to get information on any command as shown above in the run a command section or alternatively you can pass the ````-h```` or ````--help```` options like so ````minicron run -h````.

#### Server

To launch the server (aka the Hub) run ````minicron server```` - by default it will bind to port 9292 on the host 127.0.0.1. See [sample.nginx.conf](https://github.com/jamesrwhite/minicron/blob/master/sample.nginx.conf) for an example of how to run minicron behind a reverse proxy.

#### Version

Like many command line programs minicron will show it's version number when the global options ````-v```` or ````--version```` are passed to the CLI.

#### Configuration

Some configuration options can be passed in manually but the recommend way to configure minicron is through the use of a config file. You can specify the path to the file using the ````--config```` global option. The file is expected to be in the [toml](https://github.com/mojombo/toml "toml") format. The default options are specified in the [default.config.toml](https://github.com/jamesrwhite/minicron/blob/master/default.config.toml "default.config.toml") file and minicron will parse a config located in ````/etc/minicron.toml```` if it exists. Options specified via the command line will take precedence over those taken from a config file.

Documentation
-------------

minicron uses [Yard](http://yardoc.org/ "Yard") for it's documentation, you can either generate it and view it locally using the following commands:

````
yard doc
yard server
````

or view the most up to date version online at [RubyDoc.info](http://rdoc.info/github/jamesrwhite/minicron/master/frames "RubyDoc.info").

Contributing
------------

Feedback and pull requests are welcome, please see [CONTRIBUTING.md](https://github.com/jamesrwhite/minicron/blob/master/CONTRIBUTING.md "CONTRIBUTING.md") for more info.

Areas that I would love some help with:

- Any of the unassigned [issues here](https://github.com/jamesrwhite/minicron/issues?state=open).
- General testing of the system, let me know what you think and create issues for any issues you find!
- Tests!!
- Validation and error handling improvements
- Documentation improvements. Find something confusing or unexpected, let me know and I'll document it!
- Look for ````TODO:```` notices littered around the code, I'm trying to convert them all to issues but there are a lot.
- Code refactoring, I had to have 0.1 ready by a certain deadline so some parts are far from perfect.
- UI improvements

Code Style
----------

Where possible I'm trying to follow [Ruby Community Styleguide](https://github.com/bbatsov/ruby-style-guide "Ruby Community Styleguide")

Support
--------

Where possible I will try and provide support for minicron, you can get in touch with me via:

- Twitter [@jamesrwhite](https://twitter.com/jamesrwhite)
- Email [dev.jameswhite+minicron@gmail.com](mailto:dev.jameswhite+minicron@gmail.com)

Or feel free to open an issue and I'll do my best to help.

License
--------

minicron is licensed under the GPL v3, [see here for the full license](https://github.com/jamesrwhite/minicron/blob/master/LICENSE "see here")
