#! /usr/bin/env bash

default_directory="./"
directory_name=${1-$default_directory}

boot2=(".row-fluid")
boot3=(".row")

for i in "${!boot2[@]}"
do
    echo "before: ${boot2[$i]}"
    echo "after: ${boot3[$i]}"
    ~/projects/scripts/replace.sh "${boot2[$i]}" "${boot3[$i]}" "$directory_name"
done
