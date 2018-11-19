#!/bin/bash

groupadd \
        -g 1602 \
        plex

useradd \
        -m \
        -d '/home/plex' \
        -u 1602 \
        -g 1602 \
        -c 'Plex Role Account' \
       	plex 

docker pull linuxserver/plex


docker create \
	--name=plex \
	## --net=host \
	-p 32400:32400 \
	-p 32400:32400/udp \
	-p 32469:32469 \
	-p 32469:32469/udp \
	-p 5353:5353/udp \
	-p 1900:1900/udp \
	-e VERSION=latest \
	-e PUID=1602 -e PGID=1602 \
	-e TZ=America/Chicago \
	-v /home/plex/config:/config \
	-v /home/plex/tvseries>:/data/tvshows \
	-v /home/plex/movies:/data/movies \
	-v /home/plex/transcode:/transcode \
	linuxserver/plex

## docker container start plex
