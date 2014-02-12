minicron [![Build Status](https://secure.travis-ci.org/jamesrwhite/minicron.png)](http://travis-ci.org/jamesrwhite/minicron) [![Dependency Status](https://gemnasium.com/jamesrwhite/minicron.png)](https://gemnasium.com/jamesrwhite/minicron)
=======

minicron is a work in progress system to make it easier to more effectively manage and monitor cron jobs.

Installation
-------------

minicron is currently under heavy development and as such I have not released it to rubygems.org yet. If you wish to test the current version you can clone this repo and ````rake install````.

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

Documentation
-------------

minicron uses [Yard](http://yardoc.org/ "Yard") for it's documentation, you can either generate it and view it locally using the following commands:

````
yard doc
yard server
````

or view the most up to date version online at [RubyDoc.info](http://rdoc.info/github/jamesrwhite/minicron/master/frames "RubyDoc.info").

Requirements
-------------

#### Ruby
- MRI
  - 1.9.2 and above (tested on 1.9.2, 1.9.3, 2.0.0, 2.1.0 and HEAD)
- Rubinius
  - Travis builds are run on the latest release
- JRuby
  - As yet untested

#### OS
- Should run on any linux/bsd based OS that the above ruby versions run on.
- No windows support due to the lack of pseudo terminal support.

Contributing
------------

I'm building minicron as a part of my final year project at University and as such cannot currently accept pull requests. Once the project is finished however (June 2014) this will most likely change. Feel free to submit feature requests via issues though.

Code Style
----------

Where possible I'm trying to follow [GitHub's Ruby Styleguide](https://github.com/styleguide/ruby "GitHub's Ruby Styleguide")

License
--------

minicron is licensed under the GPL v3, [see here](https://github.com/jamesrwhite/minicron/blob/master/LICENSE "see here")
