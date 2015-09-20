#!/bin/bash
set -e

# Figure out where this script is located.
DIR="`dirname \"$0\"`"
DIR="`cd \"$DIR\" && pwd`"

# Override the directory location if required
if [ "test$OVERRIDE_DIR" == "test$OVERRIDE_DIR" ]; then
    DIR=$OVERRIDE_DIR
fi

# Tell Bundler where the Gemfile and gems are.
export BUNDLE_GEMFILE="$DIR/lib/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

# Run the actual app using the bundled Ruby interpreter, with Bundler activated.
exec "$DIR/lib/ruby/bin/ruby" -rbundler/setup $DIR/lib/vendor/ruby/2.2.0/bin/minicron $@
