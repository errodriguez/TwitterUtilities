#! /usr/bin/env bash
#
# oauth.sh v1.0.0
#
# OAuth
#
# This scripts implements an OAuth signed authentication wrapper.
#
# (c) Eduardo René Rodríguez Ávila:June 2018 
################################################################################

#===========================================================================
# LOCAL DECLARATIONS
#===========================================================================

#- Functions

# RFC3986.- Percent encoding function. This function covers the URL encoding
# process described in RFC 3986, section 2.1.
function RFC3986 {
  for ((i=0;i<${#1};i++))
  do
     c="${1:i:1}"
     [[ $c =~ [._~A-Za-z0-9-] ]] && echo -n "$c" || printf "%%%02X" "'$c"
  done
}

# Radix64.- Represent binary data in an ASCII string format by translating it
# into a radix-64 representation scheme.
function Radix64 {
if (( $# == 0 ))
   then set -- $(< /dev/stdin)
fi
  case $(uname) in
       Darwin) echo -n $1 | base64
               return $?
               ;;
            *) echo -n $1 | base64 -w0
               return $?
               ;;
  esac
}

#- Variables

# OAUTH key names.
OACK="oauth_consumer_key"
OANE="oauth_nonce"
OASE="oauth_signature"
OASM="oauth_signature_method"
OATP="oauth_timestamp"
OATN="oauth_token"
OAVN="oauth_version"

# KEYS.- Array of key names.
declare -a KEYS
OAUTH=( $OACK $OANE $OASE $OASM $OATP $OATN $OAVN )

for (( i=0;i<${#OAUTH[@]};i++ ))
do
  KEYS[i]=${OAUTH[i]}
done

# VALUES.- Array of key values.
declare -A VALUES

# TIME.- Timestamp invocation.
TIME=""

# OSTR.- Ordered parameters string.
OSTR=""

# SSTR.- Signature base string required by OAuth process.
SSTR=""

# SKEY.-  Encoded consumer and access secrets, signing key.
SKEY=""

# HSTR.- HTTP protocol headers string.
HSTR=""

#===========================================================================
# SCRIPT'S BODY
#===========================================================================

#- 1.- Script invocation validation. 

#+ First six arguments are mandatory: consumer key, consumer secret, access
#  token, access secret, HTTP method and resource
#  URL.
#   
#+ Remaining seven thru last arguments should be key-value pairs of API
#  resource's formal parameters (space-separated pairs).
if (( $# > 6 ))
   then if (($# % 2))    #* When arguments number is odd.
           then echo "Inconsistent number of name and value pairs."
                exit 1
        fi
fi 

#- API resource's arguments are referenced through variable indirection on
#  positional values. Keys and values are stored in proper arrays.

     # n-th key       , n-th value     , array index    
for (( i=$((OPTIND+6)), j=$((OPTIND+7)), k=$((${#OAUTH[@]}));
       i<=$#; 
       i+=2           , j+=2           , k++
    ))
do
    KEYS[k]=${!i}
    VALUES[${!i}]=${!j}
done

#- 2.- Creating a signature
#
#+ In this part, the OAuth 1.0a HMAC-SHA1 signature for the HTTP request
#  is created.
#
#+ Collecting the request method and base URL.
#   To produce a signature, start by determining the HTTP method and URL of
#   the request. The base URL is the URL to which the request is directed,
#   minus any query string or hash parameters.
#
#+ 2.1.- Collecting parameters
#  To start producing the signature, consumer key, access token, signature
#  method and OAuth version are identified or set.

VALUES[$OACK]=$1
VALUES[$OATN]=$3
VALUES[$OASM]="HMAC-SHA1"
VALUES[$OAVN]="1.0"

#* A timestamp is calculated for signing purposes. A random unique string must
# be used in each request and encoded. The "nonce" allows the Service Provider
# to verify that the request has never been made before and helps prevent 
# attacks over non-secure channels.
TIME=$(date +%s)
VALUES[$OANE]=$(Radix64 $TIME)
VALUES[$OATP]=$TIME

#* Values already collected need to be encoded into a single string which will
# be used later on. The process to build the string is very specific:
  
#* a. Percent encode every value that will be signed.
for i in ${!VALUES[@]}
do
    VALUES[$i]=$(RFC3986 ${VALUES[$i]})
done

#* b. Sort the list of parameters alphabetically by encoded key.
IFS=$'\n' KEYS=($(sort <<<"${KEYS[*]}"))

#* c. Define an output string.
OSTR=""

#* d. For each key/value pair:
#* d.1  Append the encoded key to the output string.
#* d.2  Append the ‘=’ character to the output string.
#* d.3  Append the encoded value to the output string.
#* d.4  If there are more key/value pairs remaining, append a ‘&’ character
#*      to the output string.
for (( i=0;i<${#KEYS[@]};i++ ))              #* For all keys...
do
    if ! [[ ${VALUES[${KEYS[i]}]} == "" ]]   #* ...if it has a value...
       then if ! [[ $OSTR == "" ]]           #* ...and its not the first...
               then OSTR=$OSTR"&"
            fi
            OSTR=$OSTR$(RFC3986 ${KEYS[i]})"="${VALUES[${KEYS[i]}]}
    fi
done

#- 3.- Create the signature base string.
#  The values collected so far must be joined with the method and resource URL
#  to make a single string, from which the signature will be generated. This
#  is called the signature base string by the OAuth specification.
SSTR="$5&"
SSTR=$SSTR$(RFC3986 $6)"&"
SSTR=$SSTR$(RFC3986 $OSTR)

#- 4.- Getting a signing key
#  The value which identifies the application to Twitter is called the
#  consumer secret. The value which identifies the account your application is
#  acting on behalf of is called the oauth token secret. Both of these values
#  need to be combined to form a signing key which will be used to generate the
#  signature. The signing key is simply the percent encoded consumer secret,
#  followed by an ampersand character ‘&’, followed by the percent encoded
#  token secret. 
SKEY=$(RFC3986 $2)"&"$(RFC3986 $4)

#- 5.- Calculating the signature
#  Signature string is encrypted and percent encoded.
VALUES[$OASE]=$(echo -n $SSTR|openssl dgst -binary -sha1 -hmac $SKEY|Radix64)
VALUES[$OASE]=$(RFC3986 ${VALUES[$OASE]})

#- 6.- Authorizing the request
#  https://dev.twitter.com/oauth/overview/authorizing-requests
# 
#  To allow applications to provide which application is making the request,
#  which user the request is posting on behalf of, whether the user has granted
#  the application authorization to post on the user's behalf, and whether the 
#  request has been tampered by a third party while in transit, Twitter's API
#  requires that requests needing authorization contain and aditional HTTP
#  Authorization header with enough information to answer those questions.
# 
#  Authorization header contains 7 key/value pairs of key begining with the
#  string "oauth_": oauth_consumer_key, oauth_nonce, oauth_signature,
#  oauth_signature_method, oauth_timestamp, oauth_token, oauth_version.
# 
#  To build the header string:
#  a. Set the string to “OAuth ”.
#  b. For each key/value pair of the 7 parameters listed above:
#  b.1 Percent encode the key and append it.
#  b.2 Append the equals character ‘=’.
#  b.3 Append a double quote ‘”’.
#  b.4 Percent encode the value and append it.
#  b.5 Append a double quote ‘”’.
#  b.6 If there are key/value pairs remaining, append a comma ‘,’ and a space.

HSTR=""
OSTR=""
for (( i=0; i<${#KEYS[@]}; i++ ))
do
   if [[ ${KEYS[i]} =~ ^oauth_ ]]
      then if ! [[ $HSTR == "" ]]
              then HSTR=$HSTR", " 
           fi
           HSTR=$HSTR$(RFC3986 ${KEYS[i]})"=\""${VALUES[${KEYS[i]}]}"\""
      else if ! [[ ${VALUES[${KEYS[i]}]} == "" ]]
              then if ! [[ $OSTR == "" ]]
                      then OSTR=$OSTR"&"
                   fi
                   OSTR=$OSTR${KEYS[i]}"="${VALUES[${KEYS[i]}]}
           fi
   fi
done
HSTR="OAuth "$HSTR

#- 7.- Finally, return the OAuth string.

echo "$6?$OSTR  --$5 --header 'Authorization: $HSTR'"

exit $? 
###############################################################################
