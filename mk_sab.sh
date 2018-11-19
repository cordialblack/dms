base_dir='/usr/local/media'
home_dir=$base_dir/sabnzbd

groupadd \
        -g 1603 \
        sabnzbd

useradd \
        -m \
        -d $home_dir
        -u 1603 \
        -g 1603 \
        -c 'Sabnzbd Role Account' \
        sabnzbd

docker pull linuxserver/sabnzbd

docker create --name=sabnzbd \
	-v $home_dir/config:/config \
	-v $home_dir/downloads:/downloads \
	-v $home_dir/incomplete-downloads:/incomplete-downloads \
	## -v /usr/local/media:/movies \
	-e PGID=1603 -e PUID=1603 \
	-e TZ=America/Chicago \
	-p 8080:8080 -p 9090:9090 \
	linuxserver/sabnzbd

## docker container start sabnzbd
