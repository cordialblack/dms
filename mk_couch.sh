groupadd \
	-g 1604 \
	couchpotato

useradd \
	-m \
	-d '/home/couchpotato' \
	-u 1604 \
	-g 1604 \
	-c 'Couchpotato Role Account' \
	couchpotato

docker pull linuxserver/couchpotato

docker create --name=couchpotato \
	--restart=always \
	-v /home/couchpotato/config:/config \
	-v /home/couchpotato/downloads:/downloads \
	-v /home/couchpotato/movies:/movies \
	-e PGID=1604 -e PUID=1604 \
	-e TZ=America/Chicago \
	-p 5050:5050 \
	linuxserver/couchpotato

## docker container start couchpotato
