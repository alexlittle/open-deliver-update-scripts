#!/bin/bash

# stop script if anything unexpected happens
set -e

# read config file
source ./phpmyadmin-update.cfg

# read Moodle download link from command line
phpmyadmin_download_link=$1

# https://files.phpmyadmin.net/phpMyAdmin/4.7.4/phpMyAdmin-4.7.4-all-languages.tar.gz

echo "The current config settings are:"
echo "phpmyadmin download link: $phpmyadmin_download_link"
echo "phpmyadmin root: $phpmyadmin_root"

read -r -p "Are you sure you would like to continue? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]
then
	:
else
	exit
fi

cd $phpmyadmin_root
echo "Downloading new phpMyAdmin"
wget $phpmyadmin_download_link
echo "New phpMyAdmin downloaded"

saveIFS=$IFS
IFS="/"
var2=($phpmyadmin_download_link)
IFS=$saveIFS
downloaded_phpmyadmin_archive=${var2[@]: -1}
echo $downloaded_phpmyadmin_archive

new_phpmyadmin_dir=${downloaded_phpmyadmin_archive/\.tar\.gz/}
echo $new_phpmyadmin_dir

echo "Extracting new phpMyAdmin"
tar -xvf $phpmyadmin_root/$downloaded_phpmyadmin_archive
echo "Completed extracting new phpMyAdmin"

rm $phpmyadmin_root/$downloaded_phpmyadmin_archive


cp -R $phpmyadmin_root/$new_phpmyadmin_dir/* $phpmyadmin_root/phpMyAdmin/

rm -R $phpmyadmin_root/$new_phpmyadmin_dir
