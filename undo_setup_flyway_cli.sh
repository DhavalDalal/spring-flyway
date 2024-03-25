#!/usr/bin/env bash

FILE="./flyway"
if [ -f $FILE ]; then
   echo "File $FILE exists."
   rm $FILE
   # list only directories with name beginning with name flyway
   flywayExtractedDir=`ls -d flyway*/ | head -n 1 | cut  -d '/' -f1`
   echo "Removing $flywayExtractedDir"
   rm -rv $flywayExtractedDir
   echo "*** UNDO COMPLETE ***"
else
   echo "*** NOTHING TO UNDO ***"
fi
