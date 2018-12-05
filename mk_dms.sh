#!/bin/bash

## variables #################

base_dir='/usr/local/media' ## full path to the mount point for persistent data

##############################

mkdir $base_dir
home_dir="$base_dir/home"
mkdir $home_dir
#git clone http://github.com/cordialblack/dms-cfg $home_dir/.
user='dms'
group='dms'

## figure out which .deb based distro we're running
. /etc/os-release

apt-get update

apt-get -y upgrade

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

mkdir $base_dir/downloads
mkdir $base_dir/incomplete-downloads
mkdir $base_dir/tv
mkdir $base_dir/movies

### Install user
useradd \
        -d $home_dir/$user \
        -c 'DMS Role Account' \
        $user

user_id=`id -u $user`
group_id=`id -g $user`

### Install services

all_services=('sabnzbd' 'sonarr' 'radarr' 'plex')

for service in ${all_services[@]}; do

	mkdir $homedir/$user/$service
	chown $user $homedir/$user/$service
	docker pull linuxserver/$service

	case $service in
		'sabnzbd')
			docker create \
			--name=$service \
			--restart=always \
			-v $home_dir/$user/$service:/config \
			-v $base_dir/downloads:/downloads \
			-v $base_dir/incomplete-downloads:/incomplete-downloads \
			-e PGID=$group_id -e PUID=$user_id \
			-e TZ=America/Chicago \
			-p 8080:8080 -p 9090:9090 \
			linuxserver/$service
			;;
		'sonarr')
			docker create \
			--name=$service \
			--restart=always \
			-v $home_dir/$user/$service:/config \
			-v $base_dir/downloads:/downloads \
			-v $base_dir/tv:/tv \
			-v /etc/localtime:/etc/localtime:ro \
			-e TZ=America/Chicago \
			-e PGID=$group_id -e PUID=$user_id  \
			-p 8989:8989 \
			-p 9898:9898 \
			linuxserver/$service
			;;
		'radarr')
			docker create \
			--name=$user \
			--restart=always \
			-v $home_dir/$user/$service:/config \
			-v $base_dir/downloads:/downloads \
			-v $base_dir/movies:/movies \
			-v /etc/localtime:/etc/localtime:ro \
			-e TZ=America/Chicago \
			-e PGID=$group_id -e PUID=$user_id  \
			-p 7878:7878 \
			-p 8787:8787 \
			linuxserver/$service
			;;
		'plex')
			docker create \
			--name=$service \
			--restart=always \
			--net=host \
			-e VERSION=latest \
			-e TZ=America/Chicago \
			-v $home_dir/$user/$service:/config \
			-v $base_dir/tv:/data/tvshows \
			-v $base_dir/kids_tv:/data/kids_tv\
			-v $base_dir/movies:/data/movies \
			-v $base_dir/kids_movies:/data/kids_movies \
			-v $base_dir/transcode:/transcode \
			linuxserver/$service
			;;
		*)
	esac
