#!/bin/bash

## variables #################

base_dir='/var/lib/showman' ## full path to the mount point for persistent data

##############################

if [ "$1" = 'install' ]; then
	printf "\nStarting DMS install...\n"
elif [ "$1" = 'update' ]; then
	printf "\nStarting update of $2...\n"
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

if [ "$1" = 'install' ]; then
	all_services=('organizr' 'deluge' 'sabnzbd' 'sonarr' 'radarr' 'plex')
elif [ "$1" = 'update' ]; then
	if [ "$2" = 'all' ]; then
		all_services=('organizr' 'deluge' 'sabnzbd' 'sonarr' 'radarr' 'plex')
	else
		all_services=("$2")
	fi
else
	printf "Syntax error. Please try again.\n"
	exit 1;
fi

for service in ${all_services[@]}; do

	printf "\nStarting work on $service\n\n"
	if [ "$1" = 'install' ]; then
		mkdir -p $conf_dir/$service
		chown $user $conf_dir/$service
	else
		printf "\nShutting down $service in docker...\n\n"
		docker stop $service
		printf "Removing existing container for $service\n\n"
		docker rm $service
	fi


	case $service in
		'sabnzbd')
			printf "Working on $service container\n\n"
			docker pull linuxserver/$service
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
			docker pull linuxserver/$service
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
			docker pull linuxserver/$service
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
			docker pull linuxserver/$service
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
		'deluge')
                        printf "Working on $service container\n\n"
                        docker pull linuxserver/$service
			docker create \
  			--name=$service \
			--net=host \
			-e PUID=$user_id \
			-e PGID=$group_id \
			-e TZ=America/Chicago \
			-v $conf_dir/$service:/config \
			-v $base_dir/downloads/:/downloads \
			--restart unless-stopped \
			linuxserver/$service
			;;
		'organizr')
			printf "Working on $service container\n\n"
			docker pull organizrtools/organizr-v2
			#docker pull lsiocommunity/organizr
			docker create  \
			--name=organizr \
			--restart=always \
			-v /var/lib/showman/config/organizr/:/config \
			-e PGID=$group_id -e PUID=$user_id  \
		        -p 80:80 -p 443:443 \
		        organizrtools/organizr-v2
		        #lsiocommunity/organizr
			;;
		*)
	esac

	printf "Starting up $service container\n\n"
	docker start $service

done

if [ "$1" = 'update' ]; then
	docker image prune
fi

exit 0
