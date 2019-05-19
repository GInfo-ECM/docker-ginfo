#!/bin/bash
# For each plugin check if it fits our criterions (updated less than 3y ago, more that 100 active_installs
# To test you can use plugin "smart-throttle"

TIMELAPSE="4 years"
ACTIVEINSTALLS=300

# List of plugins not to be deleted even if conditions are true
#LIST_PLUGINS_KEPT="" 	# list in format "name1 name2 name3"
# Should now be an environment variable, let here for the clarity

declare -a NOTHING_DELETED
NOTHING_DELETED=true

delete_plugin () {
    echo "Warning ! Uninstalling plugin $1"
    wp plugin uninstall --deactivate "$1"
}


while read plug; do 

	if [[ $plug == *".php" ]]; then
	    echo "Didn't update plugin $plug because it is droppin"
	    continue 2
    fi

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

	research=`wp plugin search $plug --fields=slug,last_updated,active_installs --format=json`

	retval=$?
	# Checking if error (if so wp already prints something so we just prevent the deletion)
	if [ $retval -eq 0 ]
	then 	
		while read i;
		do
			slug=$(echo `jq -r '.slug' <<< ${i}`)
			date=$(echo `jq -r '.last_updated' <<< ${i}`)
			active=$(echo `jq -r '.active_installs' <<< ${i}`)

			if [[ "$slug" == "$plug" ]]
			then
			    d1=$(date --utc --date="$(date)" +"%Y-%m-%d %H:%M:%S")
			    d2=$(date --utc --date="$date+$TIMELAPSE" +"%Y-%m-%d %H:%M:%S")

			    if [[ "$d2" < "$d1" ]] || [[ $active -lt $ACTIVEINSTALLS ]]  # date criterion
			    then
				delete_plugin $plug
				NOTHING_DELETED=false
			    fi

				isNotInDb=false
				#echo $i # Put here the conditions
			fi
		done <<< "$(jq -c '.[]' <<< $research )"

		# If the plugin is not in the wordpress db
		if [[ "$isNotInDb" = true ]]
		then
		    delete_plugin $plug
		    NOTHING_DELETED=false
		fi	
	elif [ $retval -eq 1 ]
	then 
		echo "Error : can't check for updates, probably due to connection"
		exit 1
	fi
done <<< "$(wp plugin list --field=name)"
[[ $? != 0 ]] && exit $?

# If nothing has been deleted then success
if $NOTHING_DELETED; then echo "\e[0m\e[32m OK : No plugin was removed \e[0m"; fi
