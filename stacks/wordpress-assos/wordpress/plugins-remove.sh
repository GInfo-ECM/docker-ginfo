#!/bin/bash
# For each plugin check if it fits our criterions (updated less than 4y ago, more that 300 active_installs

TIMELAPSE="4 years"
ACTIVEINSTALLS=300

# List of plugins not to be deleted even if conditions are true
#LIST_PLUGINS_KEPT="" 	# list in format "name1 name2 name3"
# Should now be an environment variable, let here for the clarity

declare -a NOTHING_DELETED
NOTHING_DELETED=true

delete_plugin() {
	echo "Warning ! Uninstalling plugin $1"
	wp plugin uninstall --deactivate "$1"
}

while read plug; do

	if [[ $plug == *".php" ]]; then
		echo "Didn't update plugin $plug because it is droppin"
		continue 2
	fi

	if [[ $plug == "" ]]; then
		echo "No plugin installed"
		continue 2
	fi

	# Skip the part of the list we want to keep
	for val in $LIST_PLUGINS_KEPT; do
		if [ "${plug}x" = "${val}x" ]; then
			echo "Plugin ${plug} in LIST_PLUGINS_KEPT, skipping."
			continue 2 # Next plugin
		fi
	done

	resp=$(curl -s "https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&slug=${plug}")

	if [ $? -ne 0 ]; then # curl command failed, keep the plugin
		echo "Non-zero curl exit code when fetching info for plugin ${plug}, skipping!"
		continue
	fi

	# Temporarily change the field separator (IFS) to split the API response into variables properly
	IFS='|' read slug active_installs last_updated error <<<$(echo $resp | jq -r '[.slug, .active_installs, .last_updated, .error] | join("|")')

	if [[ ! $error == "" ]]; then
		if [ "$error" == "Plugin not found." ]; then
			echo "Plugin ${plug} not found."
			delete_plugin $plug
			NOTHING_DELETED=false
			continue
		else
			echo "Unknown WP API error when fetching info for plugin ${plug}: '$error'"
			continue
		fi
	fi

	d1=$(date --utc --date="$(date)" +"%Y-%m-%d %H:%M:%S")
	d2=$(date --utc --date="${last_updated}+$TIMELAPSE" +"%Y-%m-%d %H:%M:%S")

	if [[ "$d2" < "$d1" ]]; then # date criterion
		echo "Plugin $plug hasn't received updates recently enough."
		delete_plugin $plug
		NOTHING_DELETED=false
		continue
	elif [[ $active_installs -lt $ACTIVEINSTALLS ]]; then # active installs criterion
		echo "Plugin $plug doesn't have enough active installs."
		delete_plugin $plug
		NOTHING_DELETED=false
		continue
	else
		echo "Plugin $plug ok!"
	fi
done <<<"$(wp plugin list --field=name)"
[[ $? != 0 ]] && exit $?

# If nothing has been deleted then success
if $NOTHING_DELETED; then echo "\e[0m\e[32m OK : No plugin was removed \e[0m"; fi
