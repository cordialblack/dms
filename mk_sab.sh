groupadd \
        -g 1603 \
        sabnzbd

useradd \
        -m \
        -d '/home/sabnzbd' \
        -u 1603 \
        -g 1603 \
        -c 'Sabnzbd Role Account' \
        sabnzbd

docker pull linuxserver/sabnzbd

docker create --name=sabnzbd \
	-v /home/sabnzbd/config:/config \
	-v /home/sabnzbd/downloads:/downloads \
	-v /home/sabnzbd/incomplete-downloads:/incomplete-downloads \
	## -v /usr/local/media:/movies \
	-e PGID=1603 -e PUID=1603 \
	-e TZ=America/Chicago \
	-p 8080:8080 -p 9090:9090 \
	linuxserver/sabnzbd

## docker container start sabnzbd
