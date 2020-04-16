#!/bin/bash

LENGTH=25
if [ ! -z "$1" ] && [ $1 -gt 1 ]; then
  LENGTH=$1
fi
NUMBYTES=`echo $LENGTH | awk '{print int($1*1.16)+1}'`

openssl rand -base64 $NUMBYTES | tr -d "=+/" | cut -c1-$LENGTH
