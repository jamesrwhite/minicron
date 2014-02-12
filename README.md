minicron [![Build Status](https://secure.travis-ci.org/jamesrwhite/minicron.png)](http://travis-ci.org/jamesrwhite/minicron) [![Coverage Status](https://coveralls.io/repos/jamesrwhite/minicron/badge.png)](https://coveralls.io/r/jamesrwhite/minicron) [![Dependency Status](https://gemnasium.com/jamesrwhite/minicron.png)](https://gemnasium.com/jamesrwhite/minicron)
=======

minicron is a work in progress system to make it easier to more effectively manage and monitor cron jobs.

Installation
-------------

minicron is currently under heavy development and as such I have not released it to rubygems.org yet. If you wish to test the current version you can clone this repo and ````rake install````.

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
