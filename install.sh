#!/bin/bash
set -e

VERSION="0.9.3"

echo "Installing mincron v$VERSION"

if [[ $(uname -s) == "Linux" ]]
then
    if [[ $(uname -m) == "x86_64" ]]
    then
        OS="linux-x86_64"
    else
        OS="linux-x86"
    fi
elif [[ $(uname -s) == "Darwin" ]]
then
    OS="osx"
else
  echo "Unknown OS"
  exit 1
fi

echo "OS detected as $OS"

echo "Checking user authorisation"
SUDO="sudo"
if [[ "$EUID" -eq "0" ]]; then #is root
    SUDO=""
elif ! hash sudo 2>/dev/null; then # no sudo
    echo "The install script either needs to be run as root or have permission to use sudo"
    exit
fi

DOWNLOAD_FILE="https://github.com/jamesrwhite/minicron/releases/download/v$VERSION/minicron-$VERSION-$OS.tar.gz"
# DOWNLOAD_FILE="http://localhost:8000/minicron-$VERSION-$OS.tar.gz"
TMP_TAR_LOCATION="/tmp/minicron-$VERSION-$OS.tar.gz"
TMP_DIR_LOCATION="/tmp/minicron-$VERSION-$OS"
LIB_LOCATION="/opt/minicron"
BIN_LOCATION="/usr/local/bin/minicron"

if [ "$USE_LOCAL_TAR" == "1" ]; then
  echo "Using local archive at ./minicron-$VERSION-$OS.tar.gz and moving to $TMP_TAR_LOCATION"
  cp minicron-$VERSION-$OS.tar.gz $TMP_TAR_LOCATION
else
  echo "Downloding minicron from $DOWNLOAD_FILE to $TMP_TAR_LOCATION"
  (cd /tmp; curl -sL $DOWNLOAD_FILE -o $TMP_TAR_LOCATION)
fi

echo "Removing $TMP_DIR_LOCATION and extracting minicron from $TMP_TAR_LOCATION to $TMP_DIR_LOCATION"
(cd /tmp; rm -rf $TMP_DIR_LOCATION; tar xf $TMP_TAR_LOCATION)

echo "Removing archive $TMP_TAR_LOCATION"
rm $TMP_TAR_LOCATION

echo "Removing $LIB_LOCATION and creating $LIB_LOCATION (may require password)"
$SUDO rm -rf $LIB_LOCATION && $SUDO mkdir -p $LIB_LOCATION

echo "Moving $TMP_DIR_LOCATION to $LIB_LOCATION (may require password)"
$SUDO mv $TMP_DIR_LOCATION/* $LIB_LOCATION

echo "Removing $TMP_DIR_LOCATION"
rm -rf $TMP_DIR_LOCATION

echo "Removing $BIN_LOCATION and linking $BIN_LOCATION to $LIB_LOCATION/minicron (may require password)"
$SUDO rm -f $BIN_LOCATION && $SUDO ln -s $LIB_LOCATION/minicron $BIN_LOCATION

echo
echo "done!"
