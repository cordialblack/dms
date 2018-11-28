#!/bin/bash

## variables #################

base_dir='' ## full path to the mount point for persistent data

##############################

mkdir $base_dir
cd $base_dir
git clone http://github.com/cordialblack/dms-conf .

home_dir="$base_dir/home"
group='dms'

## figure out which .deb based distro we're running
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

groupadd $group
mkdir $base_dir/downloads
mkdir $base_dir/tv
mkdir $base_dir/movies
chmod 775 $base_dir
chmod 775 $base_dir/downloads
chmod 775 $base_dir/tv
chmod 775 $base_dir/movies
chgrp $group $base_dir
chgrp $group $base_dir/downloads
chgrp $group $base_dir/tv
chgrp $group $base_dir/movies

### Install SAB
user='sabnzbd'
home_dir=$base_dir/home/$user

mkdir -p $home_dir

printf "Starting on user $user.\n"
useradd \
        -d $home_dir \
	-G dms \
        -c 'Sabnzbd Role Account' \
        $user

user_id=`id -u $user`
group_id=`id -g $user`

docker pull linuxserver/$user

docker create \
	--name=$user \
	--restart=always \
	-v $home_dir/config:/config \
	-v $base_dir/downloads:/downloads \
	-v $base_dir/incomplete-downloads:/incomplete-downloads \
	-e PGID=$group_id -e PUID=$user_id \
	-e TZ=America/Chicago \
	-p 8080:8080 \ 
	-p 9090:9090 \
	linuxserver/$user

chown -R $user:$group $home_dir
chmod -R 775 $home_dir

### Install Sonarr

user='sonarr'
home_dir=$base_dir/home/$user

mkdir -p $home_dir

printf "Starting on user $user.\n"
useradd \
	-d $home_dir \
	-G dms \
	-c 'Sonarr Role Account' \
	$user

user_id=`id -u $user`
group_id=`id -g $user`

docker pull linuxserver/$user

docker create \
	--name=$user \
	--restart=always \
	-v $home_dir/config:/config \
	-v $base_dir/downloads:/downloads \
	-v $base_dir/tv:/tv \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ=America/Chicago \
	-e PGID=$group_id -e PUID=$user_id  \
	-p 8989:8989 \
	-p 9898:9898 \
	linuxserver/$user

chown -R $user:$group $home_dir
chmod -R 775 $home_dir

### Install Radarr

user='radarr'
home_dir=$base_dir/home/$user

mkdir -p $home_dir

printf "Starting on user $user.\n"
useradd \
	-d $home_dir \
	-G dms \
	-c 'Radarr Role Account' \
	$user

user_id=`id -u $user`
group_id=`id -g $user`

docker pull linuxserver/$user

docker create \
	--name=$user \
	--restart=always \
	-v $home_dir/config:/config \
	-v $base_dir/downloads:/downloads \
	-v $base_dir/movies:/movies \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ=America/Chicago \
	-e PGID=$group_id -e PUID=$user_id  \
	-p 7878:7878 \
	-p 8787:8787 \
	linuxserver/$user

chown -R $user:$group $home_dir
chmod -R 775 $home_dir

## install plex container

user='plex'
home_dir=$base_dir/home/plex

mkdir -p $home_dir

printf "Starting on user $user.\n"
useradd \
        -d $home_dir \
	-G dms \
        -c 'Plex Role Account' \
       	$user

user_id=`id -u $user`
group_id=`id -g $user`

docker pull linuxserver/plex

docker create \
	--name=$user \
	--restart=always \
	--net=host \
	-e VERSION=latest \
	-e TZ=America/Chicago \
	-v $home_dir/config:/config \
	-v $base_dir/tv:/data/tvshows \
	-v $base_dir/kids_tv:/data/kids_tv\
	-v $base_dir/movies:/data/movies \
	-v $base_dir/kids_movies:/data/kids_movies \
	-v $base_dir/transcode:/transcode \
	linuxserver/plex

chown -R $user:$group $home_dir
chmod -R 775 $home_dir

## docker container start plex
	
	#-p 32400:32400 \
	#-p 32400:32400/udp \
	#-p 32469:32469 \
	#-p 32469:32469/udp \
	#-p 5353:5353/udp \
	#-p 1900:1900/udp \
