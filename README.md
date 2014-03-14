minicron [![Build Status](https://api.travis-ci.org/jamesrwhite/minicron.png)](http://travis-ci.org/jamesrwhite/minicron) [![Code Climate](https://codeclimate.com/github/jamesrwhite/minicron.png)](https://codeclimate.com/github/jamesrwhite/minicron) [![Dependency Status](https://gemnasium.com/jamesrwhite/minicron.png)](https://gemnasium.com/jamesrwhite/minicron) [![Inline docs](http://inch-pages.github.io/github/jamesrwhite/minicron.png)](http://inch-pages.github.io/github/jamesrwhite/minicron)
=======

minicron is a system I'm building as part of my university dissertation. It aims to complement ````cron```` by making it easier to manage and monitor cron jobs. minicron can largely be thought of as two components that interact together, the CLI and the Hub. The CLI is what is installed on your server(s) and executes your cron command and reports the status back to the Hub. The Hub is the central point where data from one or many instances of the CLI are is recieved and stored in a database. The Hub also providers a web interface to the data and makes it easy to manage your cron jobs.

Todo
------

- CLI
  - <del>Send data from CLI that runs commands to the 'hub'</del> &#10003;
  - <del>This will be via either WebSockets, a Message Queue or HTTP(s)</del> &#10003;
  - <del>Added configuration file/options to CLI, file most likely using [toml](https://github.com/mojombo/toml "toml")</del> &#10003;
  - Config to allow where job output is to be read from, currently assumed to be STDOUT/STDERR (could be log files)?
  - If connection retries fail give up and then persist the command output to disk for later resending

- Hub (Web UI / API)
  - <del>Collect data sent via CLI and store it in a db</del> &#10003;
  - <del>Display both realtime and historic data</del> &#10003;
  - CRUD functionality for cron jobs via SSH - in progress
  - Permissions support
  - Alerting (email, sms and push notifications support)

Installation
-------------

minicron is currently under heavy development and as such I have not released it to rubygems.org yet. If you wish to test the current version you can clone this repo ````bundle```` and ````rake install````. Set your database configuration options and you can then ````rake db:schema:load```` to setup the db structure.

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
- SQLite >= 3.6.16
- PostgreSQL - As yet untested

#### OS
- Should run on any linux/bsd based OS that the above ruby versions run on.
- No windows support due to the lack of pseudo terminal support.

Usage
-----

minicron is packaged as a gem and can be interacted with from the command line once you have installed it. The current commands are as follows:

#### Run a command

````
minicron run 'command --options'
````

You can alter the way in which the command alters it's output by passing the --mode option to the run argument with the value of either 'line' or 'char'. Most of the time you'll want to use the default value of line but for some commands e.g a script that outputs a progress bar minicron printing the output each character at a time can be useful.

````
minicron run --mode char 'python progress_bar.py'
````

The global ````--verbose```` option can also be passed to the ````run```` argument like so ````minicron run --verbose ls````, for further information see ````minicron help run````.

#### Get help

Running ````minicron```` with no arguments is an alias to running ````minicron help````, ````minicron -h```` or ````minicron --help````. You can also use the help argument to get information on any command as shown above in the run a command section or alternatively you can pass the ````-h```` or ````--help```` options like so ````minicron run -h````.

#### Version

Like many command line programs minicron will show it's version number when the global options ````-v```` or ````--version```` are passed.

#### Configuration

Many configuration options can be passed in manually but you can also pass a file path to the ````--config```` global option. The file is expected to be in the [toml](https://github.com/mojombo/toml "toml") format. The default options are specified in the [default.config.toml](https://github.com/jamesrwhite/minicron/blob/master/default.config.toml "default.config.toml") file and minicron will parse a config located in ````/etc/minicron.toml```` if it exists. Options specified via the command line will take precedence over those taken from a config file.

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

Code Style
----------

Where possible I'm trying to follow [Ruby Community Styleguide](https://github.com/bbatsov/ruby-style-guide "Ruby Community Styleguide")

License
--------

minicron is licensed under the GPL v3, [see here](https://github.com/jamesrwhite/minicron/blob/master/LICENSE "see here")
