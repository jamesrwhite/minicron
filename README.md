# minicron

[![Build Status](http://img.shields.io/travis/jamesrwhite/minicron.svg)](http://travis-ci.org/jamesrwhite/minicron)
[![Code Climate](http://img.shields.io/codeclimate/github/jamesrwhite/minicron.svg)](https://codeclimate.com/github/jamesrwhite/minicron)
[![Dependency Status](http://img.shields.io/gemnasium/jamesrwhite/minicron.svg)](https://gemnasium.com/jamesrwhite/minicron)
[![Inline docs](http://inch-ci.org/github/jamesrwhite/minicron.png)](http://inch-ci.org/github/jamesrwhite/minicron)

minicron makes it simple to monitor your cron jobs and ensure they are running both correctly and on schedule.

### Status

> Latest stable release in
> [0.9.7](https://github.com/jamesrwhite/minicron/releases/tag/v0.9.7)) tag but
> `0.9.x` is not being actively developed/supported. This branch is under active
> development for `1.0.0`.

> After thinking about the future of minicron and it's long overdue 1.0
> release I've decided to focus it solely on the monitoring of cron jobs and doing
> that really well and leave the management side [to](https://www.chef.io)
> [other](https://puppet.com/) [tools](https://www.ansible.com/). As such all
> the SSH based management of jobs have been removed.


- [Overview](#overview)
- [Background](#background)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Versioning](#versioning)
- [Contributing](#contributing)
- [Support](#support)
- [Credit](#credit)
- [License](#license)

## Overview

minicron runs your jobs via it's easy to install client that lives on your server and relays the job data back to the
server (web ui) where you can view it and set up alerts to ensure the job is running correctly.

## Screenshots

```
TODO: generate new screenshots for 1.0
```

## Background

I initially developed minicron as part of my dissertation at university in 2014. The motivation for developing minicron comes
largely from my experience and frustrations using cron both in a personal and professional capacity.

## Features

- Web UI
  - GUI for cron schedule create/read/update
  - View output/status as jobs run
  - Historical data for all job executions
- Alerts when jobs executions are missed or fail via:
  - Email
  - SMS ([using Twilio](https://www.twilio.com))
  - [PagerDuty](http://www.pagerduty.com) (SMS, Phone, Mobile Push Notifications and Email)
  - [Amazon Simple Notification Service](https://aws.amazon.com/sns)
  - [Slack](https://slack.com)

## Requirements

#### OS

*Should* run on OSX and any Linux/BSD based OS.

#### Database

- SQLite
- MySQL
- PostgreSQL

#### Web Server / Reverse Proxy

#### Nginx
A simple [example config](config/nginx.conf) for nginx is provided.

#### Apache
If you're using apache as your reverse proxy you need to ensure you have the following modules installed:
- `libapache2-mod-proxy-html`
- `apache2-utils`

Run the following to enable them and then restart apache
```a2enmod proxy proxy_html proxy_http xml2enc```

A simple [example config](config/apache.conf) for apache is provided.

## Installation

```
TODO: update for 1.0
```

## Usage

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

To run the server in debug mode, so you can see its output and any errors you can pass the ````--debug````
option.

#### Version

Like many command line programs minicron will show its version number when the global options ````-v````
or ````--version```` are passed to the CLI.

#### Configuration

Some configuration options can be passed in manually but the recommend way to configure minicron is through the use
of a config file. You can specify the path to the file using the ````--config```` global option. The file is expected
to be in the [toml](https://github.com/mojombo/toml) format. The default options are specified in the
[minicron.toml](config/minicron.toml) file and minicron will parse a config located in ````/etc/minicron.toml```` if it
exists. Options specified via the command line will take precedence over those taken from a config file.

## Versioning

All stable releases will follow the [semantic versioning](http://semver.org/) guidelines.

Releases will be numbered with the following format:

`<major>.<minor>.<patch>`

Based on the following guidelines:

* A new *major* release indicates a large change where backwards compatibility is broken.
* A new *minor* release indicates a normal change that maintains backwards compatibility.
* A new *patch* release indicates a bugfix or small change which does not affect compatibility.

## Contributing

Feedback and pull requests are welcome, please see [CONTRIBUTING.md](CONTRIBUTING.md)
for more info.

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

## Support

Where possible I will try and provide support for minicron but I offer no gurantees .

Feel free to open an issue and I'll do my best to help.

## Credit

minicron makes use of a *lot* of awesome open source projects that have saved me a lot of time in its development.
I started out trying to list all of them but it was taking way too much time so check out the dependencies in
[minicron.gemspec](minicron.gemspec) and
[app.rb](lib/minicron/hub/app.rb).

## License

minicron is licensed under the GPL v3, [see here for the full license](LICENSE)
