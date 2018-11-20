user='plex'
group='dms'
base_dir='/usr/local/media'
home_dir=$base_dir/plex

groupadd \
        -g 1602 \
	-G dms \
        $user

useradd \
        -m \
        -d $home_dir \
        -u 1602 \
        -g 1602 \
        -c 'Plex Role Account' \
       	$user

docker pull linuxserver/plex


docker create \
	--name=$user \
	--restart=always \
	-p 32400:32400 \
	-p 32400:32400/udp \
	-p 32469:32469 \
	-p 32469:32469/udp \
	-p 5353:5353/udp \
	-p 1900:1900/udp \
	-e VERSION=latest \
	-e PUID=1602 -e PGID=1602 \
	-e TZ=America/Chicago \
	-v $home_dir/config:/config \
	-v $home_dir/tvseries>:/data/tvshows \
	-v $home_dir/movies:/data/movies \
	-v $home_dir/transcode:/transcode \
	linuxserver/plex

chown -R $user:$user $home_dir
chmod -R 775 $home_dir

## docker container start plex
