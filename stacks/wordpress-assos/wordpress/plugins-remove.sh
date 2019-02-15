#!/bin/bash
# For each plugin check if it fits our criterions (updated less than 3y ago, more that 100 active_installs

# To test you can use plugin "smart-throttle"

TIMELAPSE="2 years"
ACTIVEINSTALLS=300

# List of plugins not to be deleted even if conditions are true
LIST_PLUGINS_KEPT="" 	# list in format "name1 name2 name3"

delete_plugin () {
    echo "Uninstalling plugin $1"
    wp plugin uninstall --deactivate "$1"
}


wp plugin list --field=name | while read plug; do 
	
	# Skip the part of the list we want to keep
	for val in $LIST_PLUGINS_KEPT
	do
		if [ "${plug}x" = "${val}x" ]
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

		if [[ "$slug" == "$plug" ]]
		then
		    d1=$(date --utc --date="$(date)" +"%Y-%m-%d %H:%M:%S")
		    d2=$(date --utc --date="$date+$TIMELAPSE" +"%Y-%m-%d %H:%M:%S")

		    if [[ "$d2" < "$d1" ]] && [[ $active -lt $ACTIVEINSTALLS ]]  # date criterion
		    then
		        delete_plugin $plug
		    fi

			isNotInDb=false
			#echo $i # Put here the conditions
		fi
	done <<< "$(jq -c '.[]' <<< `wp plugin search $plug --fields=slug,last_updated,active_installs --format=json`)"
	
	# If the plugin is not in the wordpress db
	if [[ "$isNotInDb" = true ]]
	then
	    delete_plugin $plug
	fi
done
