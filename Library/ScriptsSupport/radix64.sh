#! /usr/bin/env bash
#
# radix64.sh v1.0.0
#
# Translate a string into a radix-64 representation using encoding/decoding
# Unix utility base64(1).
#
# (c) Eduardo René Rodríguez Ávila:June 2018 
##############################################################################

#- This script is intended to be used with an piped input, but
#  if there is an argument present, it will be take it instead.
if (( $# == 0 ))
   then set -- $(< /dev/stdin)
fi
case $(uname) in
     Darwin) echo -n $1 | base64
             exit 0
             ;;
          *) echo -n $1 | base64 -w0
             exit 1
             ;;
esac
##############################################################################
