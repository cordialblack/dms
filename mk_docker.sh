#!/bin/bash

## variables
base_dir=''
home_dir=''
group=''
app_list=''
app_data=''

## https://docs.docker.com/install/linux/docker-ce/debian/
. /etc/os-release

apt-get update

apt-get -y install \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg2 \
	software-properties-common

curl -fsSL https://download.docker.com/linux/$ID/gpg | sudo apt-key add -
sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/$ID \
	$(lsb_release -cs) \
	stable"

apt-get update

apt-get -y install docker-ce

group = dms
groupadd $group
mkdir /usr/local/media
mkdir /usr/local/media/downloads
mkdir /usr/local/media/tv
mkdir /usr/local/media/movies
chmod 775 /usr/local/media
chmod 775 /usr/local/media/downloads
chmod 775 /usr/local/media/tv
chmod 775 /usr/local/media/movies
chgrp $group /usr/local/media
chgrp $group /usr/local/media/downloads
chgrp $group /usr/local/media/tv
chgrp $group /usr/local/media/movies


### Install SAB


### Install Sonarr


### Install Radarr
