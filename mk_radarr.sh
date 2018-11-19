base_dir='/usr/local/media'
home_dir=$base_dir/radarr

groupadd \
	-g 1600 \
	radarr

useradd \
	-m \
	-d $home_dir \
	-u 1600 \
	-g 1600 \
	-c 'Radarr Role Account' \
	radarr

docker pull linuxserver/radarr

docker create \
	--name=radarr \
	-v $home_dir/config:/config \
	-v $home_dir/downloads:/downloads \
	-v $home_dir/movies:/movies \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ=America/Chicago \
	-e PGID=1600 -e PUID=1600  \
	-p 7878:7878 \
	linuxserver/radarr

## docker container start radarr
