groupadd \
	-g 1600 \
	radarr

useradd \
	-m \
	-d '/home/radarr' \
	-u 1600 \
	-g 1600 \
	-c 'Radarr Role Account' \
	radarr

docker pull linuxserver/radarr

docker create \
	--name=radarr \
	-v /home/radarr/config:/config \
	-v /home/radarr/downloads:/downloads \
	-v /home/radarr/movies:/movies \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ=America/Chicago \
	-e PGID=1600 -e PUID=1600  \
	-p 7878:7878 \
	linuxserver/radarr

## docker container start radarr
