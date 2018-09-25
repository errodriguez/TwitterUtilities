#! /usr/bin/env bash
#
# example02.sh
#
# PURPOSE:
# An output variant to example01.sh script.
#
# USAGE:
# $ ./example02.sh [PATH/]FILENAME ACCOUNTNAME
#
# Parameters:
#   FILENAME	An optional fully- or relative-qualified file name with
#               Twitter credential access.
#
#   ACCOUNTNAME	User ID (screen name, without "@") to query.
#
# Output:
# Same output as example01.sh script but as a JSON formated object.
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

if [[ $# < 2 ]]
then echo "Error: key file and Twitter account required."
       exit 1
fi


#+ API call and filtering.
$TwC/twttrac.sh -s -f $1 https://api.twitter.com/1.1/users/show.json screen_name $2 | jq -r 'if .errors then .|.message else {Followers:.followers_count, Following:.friends_count, Listed:.listed_count, Likes:.favourites_count, Tweets:.statuses_count} end'

exit $TwUStatus
###############################################################################
