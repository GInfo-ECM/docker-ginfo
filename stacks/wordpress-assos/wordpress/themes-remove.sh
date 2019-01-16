#!/usr/bin/env bash
# For each plugin check if it fits our criterions (updated less than 3y ago, more that 100 active_installs

# For testing, use theme "default"

TIMELAPSE="2 years"
ACTIVEINSTALLS=500
DEFAULTTHEME=twentynineteen


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
			#echo $i # Put here the conditions
		fi
	done <<< "$(jq -c '.[]' <<< `wp theme search $theme --fields=slug,last_updated,active_installs --format=json`)"

	# If the plugin is not in the wordpress db
	if [ "$isNotInDb" = true ]
	then
	    delete_theme $theme
	fi
done
