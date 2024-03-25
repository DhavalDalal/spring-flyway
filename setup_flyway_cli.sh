#!/usr/bin/env bash

if [ -z "$1" ]
  then
    echo "No Flyway zip file specified as argument to this script"
    echo "Syntax: ./setup_flyway_cli.sh <path/to/flyway-commandline.tar.gz>"
    exit 1
fi

FILE="./flyway"
if [ -f $FILE ]; then
   echo "*** SETUP DONE EARLIER, NOTHING REMAINS ***"
else
   echo "Flyway zip file location: $1..."
   pathToZipFile=$1
   FLYWAY_HOME="$PWD/flyway"
   # Make directory if it does not exist
   mkdir -pv $FLYWAY_HOME
   echo "Setting Flyway Home = $FLYWAY_HOME"
   cp -v $1 $FLYWAY_HOME

   zipFile=$(basename "$pathToZipFile")
   echo "Extracting Zip File = $zipFile in directory: $PWD"
   tar -C . -xzvf $FLYWAY_HOME/$zipFile
   # Get Latest created directory after untarring
   flywayExtractedDir=`ls -td -- */ | head -n 1 | cut -d'/' -f1`
   echo "Latest Extracted Directory = $flywayExtractedDir"
   # Remove the zip file
   echo "Removing...Zip File"
   rm -v $FLYWAY_HOME/$zipFile
   echo "Removing...Old Flyway Directory"
   rmdir -v $FLYWAY_HOME
   echo "Linking..."
   ln -sfv $flywayExtractedDir/flyway flyway
   echo "Running flyway..."
   ./flyway -v -X
fi