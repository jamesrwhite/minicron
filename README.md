minicron
=======

[![Gem Version](http://img.shields.io/gem/v/minicron.svg)](https://rubygems.org/gems/minicron)
[![Build Status](http://img.shields.io/travis/jamesrwhite/minicron.svg)](http://travis-ci.org/jamesrwhite/minicron)
[![Coverage Status](http://img.shields.io/coveralls/jamesrwhite/minicron.svg)](https://coveralls.io/r/jamesrwhite/minicron?branch=master)
[![Code Climate](http://img.shields.io/codeclimate/github/jamesrwhite/minicron.svg)](https://codeclimate.com/github/jamesrwhite/minicron)
[![Dependency Status](http://img.shields.io/gemnasium/jamesrwhite/minicron.svg)](https://gemnasium.com/jamesrwhite/minicron)
[![Inline docs](http://inch-pages.github.io/github/jamesrwhite/minicron.png)](http://inch-pages.github.io/github/jamesrwhite/minicron)

minicron aims to complement ````cron```` by making it easier to manage and monitor cron jobs, it can largely be
thought of as two components that interact together, the CLI and the Hub. The CLI is what is installed on your
server(s) and executes your cron command and reports the status back to the Hub. The Hub is the central point
where data from one or many instances of the CLI are is recieved and stored in a database. The Hub also provides
a web interface to the data and makes it easy to manage your cron jobs.

- [Background](https://github.com/jamesrwhite/minicron/blob/master/README.md#background)
- [Features](https://github.com/jamesrwhite/minicron/blob/master/README.md#goals)
- [Requirements](https://github.com/jamesrwhite/minicron/blob/master/README.md#requirements)
- [Installation](https://github.com/jamesrwhite/minicron/blob/master/README.md#installation)
- [Usage](https://github.com/jamesrwhite/minicron/blob/master/README.md#usage)
- [Documentation](https://github.com/jamesrwhite/minicron/blob/master/README.md#documentation)
- [Versioning](https://github.com/jamesrwhite/minicron/blob/master/README.md#versioning)
- [Contributing](https://github.com/jamesrwhite/minicron/blob/master/README.md#contributing)
- [Support](https://github.com/jamesrwhite/minicron/blob/master/README.md#support)
- [License](https://github.com/jamesrwhite/minicron/blob/master/README.md#license)

Background
-----------

I'm developing minicron as part of my dissertation at university which is due in May but I plan to continue
development after that. My inspiration for developing minicron comes from time spent working at
[Miniclip](http://www.miniclip.com) where the management and monitoring of cron jobs at times proved to be tricky!

Features
---------

- Web UI
  - CRUD for cron jobs using ssh
  - GUI for cron schedule create/read/update
  - View realtime output/status as jobs run
  - Historical data for all job executions
- Alerts when jobs executions are missed or fail via:
  - Email
  - SMS ([using Twilio](https://www.twilio.com))
  - [PagerDuty](www.pagerduty.com)

Lots more is planned for the future, see issues tagged [feature](https://github.com/jamesrwhite/minicron/issues?labels=feature&milestone=&page=1&state=open).

Requirements
-------------

#### Ruby
- **MRI**: 1.9.3 and above (tested on 1.9.3, 2.0.0, 2.1.0)
- <del>**Rubinius**: Travis builds are run on the latest release</del> [*awaiting bug fix*](https://github.com/rubinius/rubinius/issues/2944)
- **JRuby:** currently untested but most likely needs some workn

#### Database

- MySQL
- Support for PostgreSQL and SQlite is planned in the future

#### Web Server / Reverse Proxy

If you want to run minicron behind a web server or proxy it needs to support the web socket protocol.
nginx for example supports web sockets from version 1.3.13 and up. I've included an [example config](https://github.com/jamesrwhite/minicron/blob/master/sample.nginx.conf) for nginx.

#### Browser

I have been testing the web interface in the latest versions of Chrome, Firefox and Safari.
I'm currently unsure of how it functions in the various of Internet Explorer but in theory it should support IE9+

#### OS

Should run on any linux/bsd based OS that the above ruby versions run on.

Installation
-------------

minicron is currently under heavy development and as such I would not recommend that you use this in production yet
but I encourage you to give it a try in a non critical environment and help me to improve it.

1. First check you meet the [requirements](https://github.com/jamesrwhite/minicron/blob/master/README.md#requirements)

2. On some distributions you may need to install the ````ruby-dev```` and ````build-essential```` packages

3. To install the latest release (currently 0.1.1) you can ````gem install minicron````, depending on your ruby setup
   you may need to run this with ````sudo````

4. Set your database configuration options in ````/etc/minicron.toml````, you can use the [default.config.toml](https://github.com/jamesrwhite/minicron/blob/master/default.config.toml) as a guide on what options are configurable

5. Make sure you have created an empty database with the name you set in ````/etc/minicron.toml````

  > **WARNING**
  >
  > the step below will drop any existing tables in the configured database and create new ones i.e:
  > ````sql
  > DROP TABLE IF EXISTS jobs; CREATE TABLE jobs ..
  > ````

6. You can then ````minicron db setup```` to create the database schema, alternatively you can use
   the [schema dump provided](https://github.com/jamesrwhite/minicron/blob/master/lib/minicron/hub/db/schema.sql)

7. Done! See the usage section below for more details on how to use minicron now you have it installed

Usage
-----

#### Run a command

````bash
minicron run 'mysqldump db > backup.sql'
````

The global ````--verbose```` option can also be passed to the ````run```` argument like so

````bash
minicron run --verbose ls
````

You can also run a command in 'dry run' mode to test if it works without sending the output to the server.

````bash
minicron run --dry-run 'zip -r backup.zip website'
````

for further information see ````minicron help run````.

#### Get help

Running ````minicron```` with no arguments is an alias to running ````minicron help````, ````minicron -h```` or ````minicron --help````.
You can also use the help argument to get information on any command as shown above in the run a command section
or alternatively you can pass the ````-h```` or ````--help```` options like so ````minicron run -h````.

#### Server

To launch the server (aka the Hub) run

````bash
minicron server start
````

by default it will bind to port 9292 on the host 127.0.0.1 but this can be configured by the command line
arguments ````--host```` ````--port```` and ````--path```` or in the config file.

By default the server will run as a daemon with its process id stored in ````/tmp/minicron.pid````
you can also use the ````stop```` ````restart```` and ````status```` commands to control the server.

To run the server in debug mode, i.e not as a daemon so you can see its output you can pass the ````--debug````
option.

See [sample.nginx.conf](https://github.com/jamesrwhite/minicron/blob/master/sample.nginx.conf) for an example of
how to run minicron behind a reverse proxy.

#### Connecting to a host via SSH

To be able to perform CRUD operations on the crontab minicron needs to connect via SSH to the host.
When you set up a host minicron automatically creates a public/private key pair for you and stores it
in ````~/.ssh```` on the host the minicron server is being run on using the naming schema ````minicron_host_*HOST_ID*_rsa(.pub)````.
To be able edit the crontab on a host minicron *needs* to connect to the host as the root user so you will
need to to copy the public key to the hosts authorized_keys file e.g ````/root/.ssh/authorized_keys```` on
most linux distributions or ````/var/root/.ssh/authorized_keys```` on OSX.

#### Version

Like many command line programs minicron will show it's version number when the global options ````-v````
or ````--version```` are passed to the CLI.

#### Configuration

Some configuration options can be passed in manually but the recommend way to configure minicron is through the use
of a config file. You can specify the path to the file using the ````--config```` global option. The file is expected
to be in the [toml](https://github.com/mojombo/toml "toml") format. The default options are specified in the
[default.config.toml](https://github.com/jamesrwhite/minicron/blob/master/default.config.toml "default.config.toml")
file and minicron will parse a config located in ````/etc/minicron.toml```` if it exists. Options specified via
the command line will take precedence over those taken from a config file.

Documentation
-------------

minicron uses [Yard](http://yardoc.org/ "Yard") for it's code documentation, you can either generate it and view
it locally using the following commands:

````bash
yard doc
yard server
````

or view the most up to date version online at [RubyDoc.info](http://rdoc.info/github/jamesrwhite/minicron/master/frames "RubyDoc.info").

Versioning
-----------

Where possible all releases will follow the [semantic versioning](http://semver.org/) guidelines.

Releases will be numbered with the following format:

`<major>.<minor>.<patch>`

Based on the following guidelines:

* A new *major* release indicates a large change where backwards compatibility is broken.
* A new *minor* release indicates a normal change that maintains backwards compatibility.
* A new *patch* release indicates a bugfix or small change which does not affect compatibility.

Contributing
------------

Feedback and pull requests are welcome, please see [CONTRIBUTING.md](https://github.com/jamesrwhite/minicron/blob/master/CONTRIBUTING.md "CONTRIBUTING.md") for more info.

Areas that I would love some help with:

- Any of the unassigned [issues here](https://github.com/jamesrwhite/minicron/issues?state=open).
- General testing of the system, let me know what you think and create issues for any bugs you find!
- Tests!!
- Validation and error handling improvements
- Documentation improvements. Find something confusing or unexpected, let me know and I'll add or improve
  documentation for it!
- Look for '[TODO:](https://github.com/jamesrwhite/minicron/search?q=TODO%3A)' notices littered around the code,
  I'm trying to convert them all to issues but there are a lot..
- Code refactoring, I had a reasonably tight deadline to have the main concept done by so some parts are a bit rushed
- UI improvements

Support
--------

Where possible I will try and provide support for minicron, you can get in touch with me via:

- Twitter [@jamesrwhite](https://twitter.com/jamesrwhite)
- Email [dev.jameswhite+minicron@gmail.com](mailto:dev.jameswhite+minicron@gmail.com)

Or feel free to open an issue and I'll do my best to help.

License
--------

minicron is licensed under the GPL v3, [see here for the full license](https://github.com/jamesrwhite/minicron/blob/master/LICENSE "see here")
