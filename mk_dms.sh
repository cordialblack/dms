#!/bin/bash

## variables #################

base_dir='/var/lib/showman' ## full path to the mount point for persistent data

##############################

if [ "$1" = 'install' ]; then
	printf "\nStarting DMS install...\n"
elif [ "$1" = 'update' ]; then
	printf "\nStarting update of DMS...\n"
else
	printf "\nYou must specify 'install' or 'update'\n\n"
	exit 1
fi

user='dms'
group='dms'
conf_dir="$base_dir/config"

if [ "$1" = 'install' ]; then

	mkdir $base_dir
	mkdir $conf_dir

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

	all_directories=('downloads' 'incomplete-downloads' 'tv' 'movies' 'kids_movies')

	for directory in ${all_directories[@]}; do
		if [ ! -d $base_dir/$directory ]; then
			mkdir $base_dir/$directory
			chown -R $user $base_dir/$directory
		fi	
	done
fi

user_id=`id -u $user`
group_id=`id -g $user`

### Install services

all_services=('sabnzbd' 'sonarr' 'radarr' 'plex')

for service in ${all_services[@]}; do

	printf "\nStarting work on $service\n\n"
	if [ "$1" = 'install' ]; then
		mkdir -p $conf_dir/$service
		chown $user $conf_dir/$service
	else
		printf "\nShutting down $service in docker...\n\n"
		docker stop $service
	fi

	docker pull linuxserver/$service

	case $service in
		'sabnzbd')
			printf "Working on $service container\n\n"
			if [ "$1" = 'update' ]; then
				printf "Removing existing container for $service\n\n"
				docker rm $service
			fi
			printf "Creating new container for $service\n\n"
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
			printf "Working on $service container\n\n"
			if [ "$1" = 'update' ]; then
				docker rm $service
			fi
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
			printf "Working on $service container\n\n"
			if [ "$1" = 'update' ]; then
				docker rm $service
			fi
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
			printf "Working on $service container\n\n"
			if [ "$1" = 'update' ]; then
				docker rm $service
			fi
			docker create \
			--name=$service \
			--restart=always \
			--net=host \
			-e VERSION=latest \
			-e TZ=America/Chicago \
			-e PGID=$group_id -e PUID=$user_id  \
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

	printf "Starting up $service container"
	docker start $service

done

exit 0
