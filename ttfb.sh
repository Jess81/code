#!/bin/bash
read -p "What's the URL you'd like to run this TTFB test on?: " SITE
read -p "Have you disabled Batcache on this site? (yes/no): " DISABLED_BATCACHE
if [ "$DISABLED_BATCACHE" != "yes" ]; then
    echo "Please disable Batcache before running this script. You can do this by adding `$batcache->max_age=0;` to the end of wp-config.php. Be sure to remove this afterward if running this script on a live site."
    exit 1
fi
read -p "Are you activating deactivated plugins, or are you deactivating active plugins? (activating deactivated/deactivating active): " ACT_OR_DE
if [ "$ACT_OR_DE" != "activating deactivated" ] && [ "$ACT_OR_DE" != "deactivating active"  ]; then
    echo "You must specify whether you're activating deactivated plugins for this test or if you are deactivating active plugins."
    exit 1
fi
if [ "$ACT_OR_DE" = "activating deactivated" ]; then
    STATUS="inactive"
    ACTION="activate"
else
    STATUS="active"
    ACTION="deactivate"
fi
read -p "Have you taken a backup of this database? If no, we'll do it now. (yes/no): " DB_BACKUP
if [ "$DB_BACKUP" != "yes" ] && [ "$DB_BACKUP" != "no"  ]; then
    echo "You must specify 'yes' or 'no'."
    exit 1
fi
if [ "$DB_BACKUP" = "no" ]; then
    wp-cli --skip-plugins --skip-themes db export /tmp/dbbackup.sql --path=/htdocs/__wp__
fi
read -p "Should any plugins be exempted from this?(separate by spaces, e.g. woocommerce jetpack, press enter if none.): " EXEMPTING
EXEMPTED=$(echo "$EXEMPTING" | tr " " "\n")
PLUGINS=$(wp-cli --skip-plugins --skip-themes plugin list --status="$STATUS" --field=name --path=/htdocs/__wp__)
curl -s -o /dev/null "$SITE"
curl -s -o /dev/null "$SITE"
curl -s -o /dev/null -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n" "$SITE"
for PLUGIN in $PLUGINS
	do
		for EXEMPT in $EXEMPTED
		   do
			if [ "$PLUGIN" = "$EXEMPT" ]; then
				echo "$PLUGIN" is exempted...
				SKIP="yes"
				break
			else
				SKIP="no"
			fi
		    done
		if [ "$SKIP" = "yes" ]; then
			continue
		fi
		wp-cli --skip-plugins --skip-themes plugin "$ACTION" "$PLUGIN" --path=/htdocs/__wp__
		wp-cli --skip-plugins --skip-themes cache flush --path=/htdocs/__wp__
		curl -s -o /dev/null "$SITE"
		curl -s -o /dev/null "$SITE"
		curl -s -o /dev/null -w "Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} \n" "$SITE"
	done