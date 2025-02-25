#!/bin/bash
# For each theme check if it fits our criterions (updated less than 6y ago, more that 1000 downloads

TIMELAPSE="6 years"
DOWNLOADS=1000

# Fallback theme when the current one is invalid
# Moved to a container environment variable
# DEFAULT_THEME=twentytwentyfive

# List of themes not to be deleted even if conditions are true
#LIST_THEMES_KEPT="" 	# list in format "name1 name2 name3"
# Should now be an environment variable, let here for the clarity

declare -a NOTHING_DELETED
NOTHING_DELETED=true

delete_theme() {
	echo "Warning ! Uninstalling theme $1"
	wp theme is-active $1
	act=$(echo $?)
	if [[ $act -eq 0 ]]; then
		echo "Current theme $1 is depreciated, changing for theme $DEFAULT_THEME"
		wp theme install $DEFAULT_THEME
		wp theme activate $DEFAULT_THEME
	fi
	wp theme delete "$1"
}

while read theme; do

	# Skip the part of the list we want to keep
	for val in $LIST_THEMES_KEPT; do
		if [ "${theme}x" = "${val}x" ]; then
			echo "Theme ${theme} in LIST_THEMES_KEPT, skipping."
			continue 2 # Next theme
		elif ["${theme}x" = "${DEFAULT_THEME}x"]; then
			echo "Theme ${theme} is the default theme, skipping."
	done

	resp=$(curl -s "https://api.wordpress.org/themes/info/1.2/?action=theme_information&slug=${theme}")

	if [ $? -ne 0 ]; then # curl command failed, keep the theme
		echo "Non-zero curl exit code when fetching info for theme ${theme}, skipping!"
		continue
	fi

	# Temporarily change the field separator (IFS) to split the API response into variables properly
	IFS='|' read slug downloads last_updated error <<<$(echo $resp | jq -r '[.slug, .dowloads, .last_updated, .error] | join("|")')

	if [[ ! $error == "" ]]; then
		if [ "$error" == "Theme not found." ]; then
			echo "Theme ${theme} not found."
			delete_theme $theme
			NOTHING_DELETED=false
			continue
		else
			echo "Unknown WP API error when fetching info for theme ${theme}: '$error'"
			continue
		fi
	fi

	d1=$(date --utc --date="$(date)" +"%Y-%m-%d %H:%M:%S")
	d2=$(date --utc --date="${last_updated}+$TIMELAPSE" +"%Y-%m-%d %H:%M:%S")

	if [[ "$d2" < "$d1" ]]; then # date criterion
		echo "Theme $theme hasn't received updates recently enough."
		delete_theme $theme
		NOTHING_DELETED=false
		continue
	elif [[ downloads -lt $DOWNLOADS ]]; then # downloads criterion
		echo "Theme $theme doesn't have enough downloads."
		delete_theme $theme
		NOTHING_DELETED=false
		continue
	else
		echo "Theme $theme ok!"
	fi
done <<<"$(wp theme list --field=name)"
[[ $? != 0 ]] && exit $?

# If nothing has been deleted then success
if $NOTHING_DELETED; then echo "\e[0m\e[32m OK : No theme was removed \e[0m"; fi
