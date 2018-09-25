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
$TwC/twttrac.sh -s -f $1 https://api.twitter.com/1.1/users/show.json screen_name $2 | jq -r 'if .errors then .|.message else {Followers:.followers_count, Following:.friends_count, Listed:.listed_count, Likes:.favourites_count, Tweets:.statuses_count} end'

exit $TwUStatus
###############################################################################
