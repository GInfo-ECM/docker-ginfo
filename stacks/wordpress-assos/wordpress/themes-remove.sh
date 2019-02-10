#!/usr/bin/env bash
# For each plugin check if it fits our criterions (updated less than 3y ago, more that 100 active_installs

# For testing, use theme "default"

TIMELAPSE="2 years"
ACTIVEINSTALLS=500
DEFAULTTHEME=twentynineteen

LIST_THEMES_KEPT=("hello")

delete_theme () {
    echo "Uninstalling theme $1"
    wp theme is-active $1
    act=$(echo $?)
    if [[ $act -eq 0 ]]
    then
        echo "Current theme $1 is depreciated, changing for theme $DEFAULTTHEME"
         wp theme install $DEFAULTTHEME
         wp theme activate $DEFAULTTHEME
    fi
    wp theme delete "$1"
}


wp theme list --field=name | while read theme
do
	
	# Skip the part of the list that we want to keep
	for val in $LIST_THEMES_KEPT
	do
		if [ "${theme}x" = "${val}x" ]
		then
		    continue 2 # Next path
		fi
	done

	declare -a isNotInDb
	isNotInDb=true

	while read i;
	do
	    slug=$(echo `jq -r '.slug' <<< ${i}`)
            date=$(echo `jq -r '.last_updated' <<< ${i}`)
            active=$(echo `jq -r '.active_installs' <<< ${i}`)

		if [[ "$slug" == "$theme" ]]
		then
		    d1=$(date --utc --date="$(date)" +"%Y-%m-%d %H:%M:%S")
		    d2=$(date --utc --date="$date+$TIMELAPSE" +"%Y-%m-%d %H:%M:%S")

		    if [[ "$d2" < "$d1" ]] && [[ $active -lt $ACTIVEINSTALLS ]] # date criterion
		    then
		        delete_theme $theme
		    fi

			isNotInDb=false
		fi
	done <<< "$(jq -c '.[]' <<< `wp theme search $theme --fields=slug,last_updated,active_installs --format=json`)"

	# If the plugin is not in the wordpress db
	if [[ "$isNotInDb" = true ]]
	then
	    delete_theme $theme
	fi
done
