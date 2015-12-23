#!/bin/bash
set -e

VERSION="0.8.4"
if [[ $(uname -s) == "Linux" ]]
then
        if [[ $(uname -m) == "x86_64" ]]
        then
                OS=linux-x86_64
        else
                OS=linux-x86
        fi
else
        echo "Unknown os"
        exit 1
fi

echo "Installing mincron v$VERSION"
echo "OS input as $OS"

DOWNLOAD_FILE="https://github.com/jamesrwhite/minicron/releases/download/v$VERSION/minicron-$VERSION-$OS.zip"
# DOWNLOAD_FILE="http://localhost:8000/minicron-$VERSION-$OS.zip"
TMP_ZIP_LOCATION="/tmp/minicron-$VERSION-$OS.zip"
TMP_DIR_LOCATION="/tmp/minicron-$VERSION-$OS"
LIB_LOCATION="/opt/minicron"
BIN_LOCATION="/usr/local/bin/minicron"

echo "Downloding minicron to $TMP_ZIP_LOCATION"
(cd /tmp; curl -sL $DOWNLOAD_FILE -o $TMP_ZIP_LOCATION)

echo "Removing $TMP_DIR_LOCATION and extracting minicron from $TMP_ZIP_LOCATION to $TMP_DIR_LOCATION"
(cd /tmp; rm -rf $TMP_DIR_LOCATION; unzip -q $TMP_ZIP_LOCATION)

echo "Removing archive $TMP_ZIP_LOCATION"
rm $TMP_ZIP_LOCATION

echo "Removing $LIB_LOCATION and creating $LIB_LOCATION (may require password)"
sudo rm -rf $LIB_LOCATION && sudo mkdir -p /opt/minicron

echo "Moving $TMP_DIR_LOCATION to $LIB_LOCATION (may require password)"
sudo mv $TMP_DIR_LOCATION/* $LIB_LOCATION

echo "Removing $TMP_DIR_LOCATION"
rm -rf $TMP_DIR_LOCATION

echo "Removing $BIN_LOCATION and linking $BIN_LOCATION to $LIB_LOCATION/minicron (may require password)"
sudo rm -f $BIN_LOCATION && sudo ln -s $LIB_LOCATION/minicron $BIN_LOCATION

echo
echo "done!"
