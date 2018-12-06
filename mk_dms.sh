#!/bin/bash

## variables #################

base_dir='/usr/local/media' ## full path to the mount point for persistent data

##############################

mkdir $base_dir
conf_dir="$base_dir/config"
mkdir $conf_dir

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

apt-get -y install git-crypt
apt-get -y install docker-ce

### Install user
useradd \
        -c 'DMS Role Account' \
        $user

user_id=`id -u $user`
group_id=`id -g $user`

all_directories=('downloads' 'incomplete-downloads' 'tv' 'movies')

for directory in ${all_directories[@]}; do

	mkdir $base_dir/$directory
	chown -R $user $base_dir/$directory
	
done

### Install services

all_services=('sabnzbd' 'sonarr' 'radarr' 'plex')

for service in ${all_services[@]}; do

	mkdir -p $conf_dir/$service
	chown $user $conf_dir/$service
	docker pull linuxserver/$service

	case $service in
		'sabnzbd')
			docker create \
			--name=$service \
			--restart=always \
			-v $conf_dir/$service:/config \
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
			-v $conf_dir/$service:/config \
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
			--name=$service\
			--restart=always \
			-v $conf_dir/$service:/config \
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
			-v $conf_dir/$service:/config \
			-v $base_dir/tv:/data/tvshows \
			-v $base_dir/kids_tv:/data/kids_tv\
			-v $base_dir/movies:/data/movies \
			-v $base_dir/kids_movies:/data/kids_movies \
			-v $base_dir/transcode:/transcode \
			linuxserver/$service
			;;
		*)
	esac

	docker start $service
	sleep 3
	docker stop $service

	case $service in 
		'sabnzbd')

			;;
		'sonarr')

			;;
		'radarr')

			;;
		'plex')

			;;
		*)
	esac
done

exit
