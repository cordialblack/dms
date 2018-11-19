base_dir='/usr/local/media'
home_dir=$base_dir/sonarr

groupadd \
	-g 1601 \
	sonarr

useradd \
	-m \
	-d $home_dir \
	-u 1601 \
	-g 1601 \
	-c 'Sonarr Role Account' \
	sonarr

docker pull linuxserver/sonarr

docker create \
	--name=sonarr \
	-v $home_dir/config:/config \
	-v $home_dir/downloads:/downloads \
	-v $home_dir/tv:/tv \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ=America/Chicago \
	-e PGID=1601 -e PUID=1601  \
	-p 8989:8989 \
	linuxserver/sonarr

## docker container start sonarr
