groupadd \
	-g 1605 \
	sickrage

useradd \
	-m \
	-d '/home/sickrage' \
	-u 1605 \
	-g 1605 \
	-c 'Sickrage Role Account' \
	sickrage

docker pull linuxserver/sickrage

docker create --name=sickrage \
	--restart=always \
	-v /home/sickrage/config:/config \
	-v /home/sickrage/downloads:/downloads \
	-v /home/sickrage/tvshows:/tvshows \
	-e PGID=1605 -e PUID=1605 \
	-e TZ=America/Chicago \
	-p 8081:8081 \
	linuxserver/sickrage

## docker container start sickrage
