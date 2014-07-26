minicron
=======

[![Gem Version](http://img.shields.io/gem/v/minicron.svg)](https://rubygems.org/gems/minicron)
[![Build Status](http://img.shields.io/travis/jamesrwhite/minicron.svg)](http://travis-ci.org/jamesrwhite/minicron)
[![Coverage Status](http://img.shields.io/coveralls/jamesrwhite/minicron.svg)](https://coveralls.io/r/jamesrwhite/minicron?branch=master)
[![Code Climate](http://img.shields.io/codeclimate/github/jamesrwhite/minicron.svg)](https://codeclimate.com/github/jamesrwhite/minicron)
[![Dependency Status](http://img.shields.io/gemnasium/jamesrwhite/minicron.svg)](https://gemnasium.com/jamesrwhite/minicron)
[![Inline docs](http://inch-ci.org/github/jamesrwhite/minicron.png)](http://inch-ci.org/github/jamesrwhite/minicron)

minicron aims to complement ````cron```` by making it easier to manage and monitor cron jobs, it can largely be
thought of as two components that interact together, the CLI and the Hub. The CLI is what is installed on your
server(s) and executes your cron command and reports the status back to the Hub. The Hub is the central point
where data from one or many instances of the CLI is received and stored in a database. The Hub also provides
a web interface to the data and makes it easy to manage your cron jobs.

- [Background](#background)
- [Features](#goals)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Security](#security)
- [Documentation](#documentation)
- [Versioning](#versioning)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Support](#support)
- [Credit](#credit)
- [License](#license)

Screenshots
------------

<img src="http://f.cl.ly/items/1k1h3n2A3Z3P3v2o0733/Image%202014-04-15%20at%2012.50.56%20am.png" height="175"/>
<img src="http://f.cl.ly/items/0c27341m2l1E230B0q1l/Image%202014-04-15%20at%2012.40.42%20am.png" height="175"/>
<img src="http://f.cl.ly/items/0Y2O0P0j012s3C3t3a3E/Image%202014-04-15%20at%2012.39.19%20am.png" height="175"/>
<img src="http://f.cl.ly/items/2R1f2m350W46423c220D/Image%202014-04-15%20at%2012.32.41%20am.png" height="175"/>

Background
-----------

I initially developed minicron as part of my dissertation at university. The inspiration for developing minicron comes largely from my experience and frustrations using cron,
in particular my time spent working at [Miniclip](http://www.miniclip.com) (which is where the name comes from, miniclip.. minicron, get it?)
where the management and monitoring of cron jobs at times proved to be tricky!

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
  - [PagerDuty](http://www.pagerduty.com) (SMS, Phone, Mobile Push Notifications and Email)

Lots more is planned for the future, see [open issues](https://github.com/jamesrwhite/minicron/issues?state=open) or if you don't see the feature you want there add it!

Requirements
-------------

#### Ruby
- **MRI**: 1.9.3 and above (tested on 1.9.3, 2.0.0, 2.1.0)
- <del>**Rubinius**: Travis builds are run on the latest release</del> See: [#76](https://github.com/jamesrwhite/minicron/issues/76)
- <del>**JRuby:**: Travis builds are run on the latest release</del> &nbsp;&nbsp;&nbsp;See: [#77](https://github.com/jamesrwhite/minicron/issues/77)

#### Database

**Default**

- SQLite >= 3.6.16
  (via the sqlite3 gem which may require libsqlite3-dev or sqlite-devel depending on your OS)

**Also Supported**

These databases are also supported but you will need to manaually install the gems for them

- MySQL via mysql2 (See [here](https://github.com/brianmario/mysql2#compatibility) for compatability info)
- Support for PostgreSQL is planned in the future

#### Web Server / Reverse Proxy

If you want to run minicron behind a web server or proxy it needs to support the web socket protocol.
nginx for example supports web sockets from version 1.3.13 and up. I've included an [example config](https://github.com/jamesrwhite/minicron/blob/master/config/nginx.conf) for nginx.
It should also be possible to run it behind Apache I just haven't had time to add an example config for it yet.

#### Browser

I have been testing the web interface in the latest versions of Chrome, Firefox and Safari.
I'm currently unsure of how it functions in the various of Internet Explorer but in theory it should support IE9+

#### OS

Should run on OSX and any Linux/BSD based OS that the above ruby versions run on.

Installation
-------------

minicron is currently under heavy development and as such I would not recommend that you use this in production yet
but I encourage you to give it a try in a non critical environment and help me to improve it and work towards the first stable release (1.0).

1. First check you meet the [requirements](#requirements)

2. On some distributions you may need to install the ````ruby-dev```` and ````build-essential```` packages

3. To install the latest release (currently 0.7.2) you can ````gem install minicron````, depending on your ruby setup
   you may need to run this with ````sudo````

4. Set your database configuration options in ````/etc/minicron.toml````, you can use the [minicron.toml](https://github.com/jamesrwhite/minicron/blob/master/config/minicron.toml) as a guide on what options are configurable

5. Make sure you have created an empty database with the name you set in ````/etc/minicron.toml````

  > **WARNING**
  >
  > the step below will drop any existing tables in the configured database and create new ones i.e:
  > ````sql
  > DROP TABLE IF EXISTS jobs; CREATE TABLE jobs ..
  > ````

6. You can then ````minicron db setup```` to create the database schema, alternatively you can use
   the [schema dump provided](https://github.com/jamesrwhite/minicron/blob/master/lib/minicron/hub/db/schema.sql) (MySQL)

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

by default it will bind to port 9292 on the host 0.0.0.0 but this can be configured by the command line
arguments ````--host```` ````--port```` and ````--path```` or in the config file.

By default the server will run as a daemon with its process id stored in ````/tmp/minicron.pid````
you can also use the ````stop````, ````restart```` and ````status```` commands to control the server.

To run the server in debug mode, i.e not as a daemon so you can see its output you can pass the ````--debug````
option.

See [nginx.conf](https://github.com/jamesrwhite/minicron/blob/master/config/nginx.conf) for an example of
how to run minicron behind a reverse proxy.

#### Connecting to a host via SSH

To be able to perform CRUD operations on the crontab minicron needs to connect via SSH to the host.
When you set up a host minicron automatically creates a public/private key pair for you and stores it
in ````~/.ssh```` on the host the minicron server is being run on using the naming schema ````minicron_host_*HOST_ID*_rsa(.pub)````.
To be able edit the crontab on a host minicron needs to have permission to edit ````/etc/crontab```` and write and
execute permissions on the ````/etc```` directory so it can move files there (the crontab). This will most
likely mean allowing minicron to connect to the host as the root user although you could alter your permissions
to allow for this not to be the case.

As an example, to setup minicron SSH for the root user on a host copy the public key to the hosts
authorized_keys file e.g ````/root/.ssh/authorized_keys```` on
most linux distributions or ````/var/root/.ssh/authorized_keys```` on OSX.

#### Version

Like many command line programs minicron will show its version number when the global options ````-v````
or ````--version```` are passed to the CLI.

#### Configuration

Some configuration options can be passed in manually but the recommend way to configure minicron is through the use
of a config file. You can specify the path to the file using the ````--config```` global option. The file is expected
to be in the [toml](https://github.com/mojombo/toml) format. The default options are specified in the
[minicron.toml](https://github.com/jamesrwhite/minicron/blob/master/config/minicron.toml)
file and minicron will parse a config located in ````/etc/minicron.toml```` if it exists. Options specified via
the command line will take precedence over those taken from a config file.

Security
---------

As mentioned previously minicron is still under development and as such is missing some essential features as far as
security is concerned. For example authentication still needs to be added to the Web UI, API and Faye (the websocket
server that jobs use to communicate their status updates).

  > **It is not recommended that you allow your minicron host to be accessible via the public internet!**

Obviously without authentication anyone who knew the address of your minicron host would be able to set up
a potentially malicious job on one of your servers! Future versions may be secure enough to expose publicly but personally I still would not recommend it, minicron is designed to be an internal tool and should be behind a
firewall that only allows connections from an internal network and/or a VPN.

Documentation
-------------

minicron uses [Yard](http://yardoc.org/) for its code documentation (currently the only *usage* documentation is what you're reading right now), you can either generate it and view
it locally using the following commands:

````bash
yard doc
yard server
````

or view the most up to date version online at [RubyDoc.info](http://rdoc.info/github/jamesrwhite/minicron/master/frames).

Versioning
-----------

All stable releases will follow the [semantic versioning](http://semver.org/) guidelines. Until 1.0 hits I will try
to document any breaking changes in the release descriptions but you should proceed with caution before relying
on anything etc etc

Releases will be numbered with the following format:

`<major>.<minor>.<patch>`

Based on the following guidelines:

* A new *major* release indicates a large change where backwards compatibility is broken.
* A new *minor* release indicates a normal change that maintains backwards compatibility.
* A new *patch* release indicates a bugfix or small change which does not affect compatibility.

Roadmap
--------

I'm going to work out a proper roadmap for the epic journey towards 1.0 in a few weeks when I have more time to focus on this but until then some rough thoughts in no real order..

- Full cron syntax support ([#25](https://github.com/jamesrwhite/minicron/issues/25) and
  [#30](https://github.com/jamesrwhite/minicron/issues/30))
- More robust handling of failure in various places/situations
- Better test coverage for core features
- Support for other Ruby runtimes
- Make it as easy as possible to install/deploy minicron
- More 3rd party alerting integrations
- Finalise and document the REST API that the frontend uses
- Revision control for changes and acitvity tracking
- Support for crontabs in differing locations
- Better experience on mobile/tablet
- Improved security through authentication and permissions
- Better configuration management
- Per job configs? Not sure exactly how this would work but it would be handy
  [#82](https://github.com/jamesrwhite/minicron/issues/82)
- Better performance when lots of data exists in the system (pagination, lazy loading etc)
- UI improvements, it's just tweaked bootstrap 3 at the moment
- Various other improvements that hopefully already have issues assigned for them..

Contributing
------------

Feedback and pull requests are welcome, please see [CONTRIBUTING.md](https://github.com/jamesrwhite/minicron/blob/master/CONTRIBUTING.md) for more info.

Areas that I would love some help with:

- Any of the unassigned [issues here](https://github.com/jamesrwhite/minicron/issues?state=open).
- General testing of the system, let me know what you think and create issues for any bugs you find!
- Tests!!
- Validation and error handling improvements
- Documentation improvements.
- Look for '[TODO:](https://github.com/jamesrwhite/minicron/search?q=TODO%3A)' notices littered around the code,
  I'm trying to convert them all to issues but there are a lot..
- Code refactoring, I had a deadline to meet for the initial versions so some parts are a tad rushed
- UI improvements

Support
--------

Where possible I will try and provide support for minicron, you can get in touch with me via:

- Twitter: [@jamesrwhite](https://twitter.com/jamesrwhite)
  or [@minicron_dev](https://twitter.com/minicron_dev)
- Email: [dev.jameswhite+minicron@gmail.com](mailto:dev.jameswhite+minicron@gmail.com)

Or feel free to open an issue and I'll do my best to help.

Credit
-------

minicron makes use of a *lot* of awesome open source projects that have saved me a lot of time in its development. I started out trying to list all of them but it was taking way too much time so check out
[minicron.gemspec](https://github.com/jamesrwhite/minicron/blob/master/minicron.gemspec#L25-L54) and
[app.rb](https://github.com/jamesrwhite/minicron/blob/master/lib/minicron/hub/app.rb#L35-L65).

License
--------

minicron is licensed under the GPL v3, [see here for the full license](https://github.com/jamesrwhite/minicron/blob/master/LICENSE)
