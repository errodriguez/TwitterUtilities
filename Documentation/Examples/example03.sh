#! /usr/bin/env bash
#
# example03.sh
#
# PURPOSE:
# To collect tweets from the public stream of Twitter by a generic streaming
# endpoint filtered for a delimited geographical area covering Mexico.
#
# USAGE:
# $ ./example03.sh [PATH/]FILENAME
#
# After launched, this script will remain connected and showing the stream of
# tweets in the screen. Press CTRL+C to stop it.
#
# Parameters:
#   FILENAME	An optional fully- or relative-qualified file name with
#               Twitter credential access.
#
#
# Output:
# A JSON-formatted stream of tweets.
# 
#
# (c) Eduardo René Rodríguez Ávila:September 2018 
##############################################################################

#+ Path to this script.
TwUPath=$(dirname $0)

#+ Common variables to this and other scripts.
source $TwUPath/../../Config/envars.srcd $TwUPath

#+ Path to utility to use.
TwC=$TwUPath/../../Utilities/Console/

#+ Simple validation of expected arguments.

if [[ $# < 1 ]]
then echo "Error: key file required."
       exit 1
fi


#+ API call.
$TwC/twttrac.sh -s -f $1 https://stream.twitter.com/1.1/statuses/filter.json locations -118.55,14.53,-96.94,36.61,-96.94,14.53,-91.72,22.22,-91.72,16.08,-86.54,22.22


exit $TwUStatus
###############################################################################
