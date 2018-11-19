docker create --name=couchpotato \
	--restart=always \
	-v /home/couch/config:/config \
	-v /home/couch/downloads:/downloads \
	-v /home/couch/movies:/movies \
	-e PGID=1500 -e PUID=1500 \
	-e TZ=America/Chicago \
	-p 5050:5050 \
	linuxserver/couchpotato
