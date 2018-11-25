user='sickrage'
group='dms'
base_dir='/usr/local/media'
home_dir=$base_dir/home/$user

groupadd \
	-g 1605 \
	sickrage

useradd \
	-m \
	-d '/home/sickrage' \
	-u 1605 \
	-g 1605 \
	-G dms \
	-c 'Sickrage Role Account' \
	sickrage

docker pull sickchill/sickchill

docker create \
	--name=sickrage \
	--restart=always \
	-v /home/sickrage/config:/config \
	-v /home/sickrage/downloads:/downloads \
	-v /home/sickrage/tvshows:/tvshows \
	-e PGID=1605 -e PUID=1605 \
	-e TZ=America/Chicago \
	-p 8081:8081 \
	linuxserver/sickrage

chown -R sickchill:sickchill $home_dir
## docker container start sickrage
