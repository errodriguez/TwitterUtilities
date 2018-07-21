#! /usr/bin/env bash
#
# example01.sh
#
# Extract main statistical values of a Twitter account: followers, friends,
# listed, favourites and statuses counts.
#
# (c) Eduardo René Rodríguez Ávila:July 2018 
##############################################################################

#+ Path to this script.
TwUPath=$(dirname $0)

#+ Common variables to this and other scripts.
source $TwUPath/../../Config/envars.srcd $TwUPath

#+ Path to utility to use.
TwC=$TwUPath/../../Utilities/Console/

#+ Simple validation of expected arguments.

if [[ $# < 2 ]]
  then echo "Error: qualified path to key file and Twitter account required."
       exit 1
fi


#+ API call and filtering.
$TwC/twttrac.sh -s -f $1 https://api.twitter.com/1.1/users/show.json screen_name $2 | jq -r 'if .errors then .|.message else [.followers_count, .friends_count, .listed_count, .favourites_count, .statuses_count]|@tsv end'

exit $TwUStatus
###############################################################################
