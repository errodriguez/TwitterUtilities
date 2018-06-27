#! /usr/bin/env bash
#
# twttrac v1.0.0
#
# Twitter API Console
#
# A pure BASH console for the Twitter API.
#
#
# (c) Eduardo René Rodríguez Ávila:June 2018 
##############################################################################

#=============================================================================
# GLOBAL DECLARATIONS
#=============================================================================

#- Variables

#+ Path to this script.
TwUPath=$(dirname $0)

#+ Common variables to this and other scripts.
source $TwUPath/../../Config/envars.srcd

#+ Debugging functionality.
source $TwUDebug/debug.srcd

#=============================================================================
# LOCAL DECLARATIONS
#=============================================================================

#- Functions

# Usage.- Display information on script invocation and usage to the standard
# output.
function Usage {
  echo ""
  echo "Usage: "$0" [OPTIONS] RESOURCE-URL [ARGUMENTS ...]"
  echo ""
  echo "Options:"
  echo "    -h  This help screen."
  echo "    -v  Verbose mode."
  echo "    -s  Silent mode."
  echo "    -d  Debug mode."
  echo "    -m  HTTP method (GET by default)."
  echo "    -f  Credentials file."
  echo "    -K  Consumer Key (API Key)."
  echo "    -C  Consumer Secret (API Secret)."
  echo "    -T  Access Token."
  echo "    -S  Access Token Secret."
  echo ""
  echo "Arguments:"
  echo "    RESOURCE-URL Full-qualified API service URL."
  echo "    ARGUMENTS    Space separated key name and value pairs of API "
  echo "                 resource arguments."
  echo ""
  echo "Notes:"
  echo ""
  echo " Credentials file switch value could be prefixed with an absolute or "
  echo " relative path. This file should have 4 lines with the consumer key"
  echo " token and secret, and access token and secret (in that order and"
  echo " one per line). Additional records will be ignored, and less than 4"
  echo " records will lead to empty strings on the missing values."
  echo ""
  echo " -K, -C, -T and -S options will overwrite any value taken from a"
  echo " file if they appear after the -f switch, and conversely -f will"
  echo " overwrite any value previously set by -K, -C, -T and -S options."
  return 1
} 

# Message.- Displays informative, warnings and error messages to the standard 
# error output.
function Message {
  case "$1" in
       2) echo "A resource URL is needed."
          ;;
       3) echo "Keys file not found."
          ;;
       4) echo "Error generating OAuth string."
          ;;
       *) echo $1
          return 255
          ;;
  esac
  return $1
} >&2

#- Variables and flags to control this script.
TwUOptions="hvsdm:f:K:C:T:S:"
TwUStatus=0
TwUVerbose=""
TwUQuiet=""
TwUDebug=""
TwUMethod="GET"
TwUFile=""
#+ OAuth arguments.
TwUCKey=""
TwUCSec=""
TwUATok=""
TwUASec=""
TwUOAuth=""
TwUURL=""

#=============================================================================
# SCRIPT'S BODY
#=============================================================================

#- 1.- Script invocation validation.

#+ Parsing switches to set internal variables and flags.
while getopts $TwUOptions opt
do
      case "$opt" in
         h) Usage
            exit $?
            ;;
         v) TwUVerbose="-"$opt
            ;;
         s) TwUQuiet="-"$opt
            ;;
         d) TwUDebug=$opt
            ;;
         m) TwUMethod=$OPTARG
            ;;
         f) TwUFile=$OPTARG
            if ! [ -f $TwUFile ]
               then Message 3
                    exit 3
               else read TwUCKey TwUCSec TwUATok TwUASec <<< $( awk '
                             { printf("%s ", $0)}' $OPTARG )
            fi
            ;;
         K) TwUCKey=$OPTARG
            ;;
         C) TwUCSec=$OPTARG
            ;;
         T) TwUATok=$OPTARG
            ;;
         S) TwUASec=$OPTARG
            ;;
	 ?) exit $?
            ;;
      esac
done
shift $((OPTIND-1))

#+ At least a URL must be pass to the script.
if [[ $# < 1 ]] 
   then [ ! $TwUQuiet ] && Message 2  # No messages on quiet option.
        exit 2
fi 
TwUURL=$1
shift 1

#+ A OAuth string is generated for a consumer key and secret, access token
# and secret, HTTP method, resource URL and additional parameters.
TwUOAuth=$( $TwUSupport/oauth.sh $TwUCKey $TwUCSec $TwUATok $TwUASec \
                               $TwUMethod $TwUURL  $@ )
TwUStatus=$?

#* In case of troubles...
if [ $TwUStatus != 0 ]
   then Message 4
        if [ $TwUDebug ] 
           #* If debugging is enabled, whatever was returned by oauth.sh
           # script is shown on the screen (resulting OAuth strin or error
           # message.
           then Message "$TwUOAuth"
        fi
   else echo $TwUOAuth | xargs curl $TwUVerbose $TwUQuiet; TwUStatus=$?
fi

exit $TwUStatus
###############################################################################
