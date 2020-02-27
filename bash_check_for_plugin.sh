#!/bin/bash
sites=$(<jess_sites)
for site in $sites
	do
		echo "$site"
		curl -Ls https://"$site".mystagingwebsite.com/wp-content/plugins/plugin-name/readme.txt | if grep --quiet "{{IDENTIFIER_IN_FILE}}"; then
				echo true
			else
				echo false
			fi
	done
