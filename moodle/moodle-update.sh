#!/bin/bash

# stop script if anything unexpected happens
set -e

# read config file
source ./moodle-update.cfg

# read Moodle download link from command line
moodle_download_link=$1


echo "The current config settings are:"
echo "Moodle download link: $moodle_download_link"
echo "Moodle root: $moodle_root"
echo "Moodle themes: $moodle_themes"
echo "Moodle blocks: $moodle_blocks"

read -r -p "Are you sure you would like to continue? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]
then
	:
else
	exit
fi

# Download new Moodle
cd $moodle_root
echo "Downloading new Moodle"
wget $moodle_download_link
echo "New Moodle downloaded"

saveIFS=$IFS
IFS="/"
var2=($moodle_download_link)
IFS=$saveIFS
downloaded_moodle_archive=${var2[@]: -1}
echo $downloaded_moodle_archive

# Remove old backup

if [ -d "$moodle_root/moodle.bak" ]; then
	echo "Removing old backup"
	rm -R $moodle_root/moodle.bak
	echo "Old backup removed"
fi


# Backup existing Moodle 
echo "Creating backup of current Moodle site"
cp -R $moodle_root/moodle/ $moodle_root/moodle.bak
echo "Backup completed"


# Remove old Moodle
echo "Extracting new Moodle"
rm -R $moodle_root/moodle

# Extract new Moodle
echo "Extracting new Moodle"
tar -xvf $moodle_root/$downloaded_moodle_archive
echo "Completed extracting new Moodle"

# Add back in config.php
echo "Restoring config.php"
cp $moodle_root/moodle.bak/config.php $moodle_root/moodle/config.php 

# Add back non-standard themes
themes=$(echo $moodle_themes | tr "," "\n")
for theme in $themes
do
	echo "Restoring $theme theme"
	cp -R $moodle_root/moodle.bak/theme/$theme/ $moodle_root/moodle/theme/$theme
done


# Add back non-standard blocks
blocks=$(echo $moodle_blocks | tr "," "\n")
for block in $blocks
do
    	echo "Restoring $block block"
	cp -R $moodle_root/moodle.bak/blocks/$block/ $moodle_root/moodle/blocks/$block
done

# Remove downloaded Moodle file
echo "Removing downloaded Moodle file"
rm $moodle_root/$downloaded_moodle_archive

# Update permissions - to www-data
echo "Updating permissions"
chown -R www-data:www-data $moodle_root/moodle/

# Complete
echo "Update finished - now go to you Moodle site to trigger any database updates needed"







