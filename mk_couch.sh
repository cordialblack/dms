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

docker pull linuxserver/couchpotaro

docker create --name=couchpotato \
	--restart=always \
	-v /home/couch/config:/config \
	-v /home/couch/downloads:/downloads \
	-v /home/couch/movies:/movies \
	-e PGID=1604 -e PUID=1604 \
	-e TZ=America/Chicago \
	-p 5050:5050 \
	linuxserver/couchpotato
