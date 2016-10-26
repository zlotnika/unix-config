#! /usr/bin/env bash
# http://stackoverflow.com/questions/6758963/find-and-replace-with-sed-in-directory-and-sub-directories

default_directory="./"
default_restrict="*"

replace=$1
with=$2
directory_name=${3-$default_directory}
restrict=${4-$default_restrict}

find $directory_name -type f -exec sed -i "" "s#$replace#$with#g" {} \;


##### EXAMPLES #####

# ~/projects/scripts/replace.sh "div{'ng-include' => \"'\" + asset_path('templates/nav/_breadcrumbs.html') + \"'\"}" 'breadcrumbs' app/assets/angular/templates/

# ~/scripts/replace.sh 'toggled=\([^ ]*\)' 'toggled=(readonly "\1")' app/templates/

# replace ' \([a-z_A-Z0-9/]*\#[a-z_A-Z0-9/]*\) \([a-z_/0-9]* \)*' '\
' thing5.txt
