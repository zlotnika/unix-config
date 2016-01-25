#! /usr/bin/env bash
# http://stackoverflow.com/questions/6911301/rename-multiple-files-shell

default_directory="./"

replace=$1
with=$2
directory_name=${3-$default_directory}

for file in "$replace" ; do mv "$file" "${$with}" ; done

############ EXAMPLES #############
# convert linux_things.mp4 into things.mp4
# for file in linux_*.mp4 ; do mv "$file" "${file#linux_}" ; done
