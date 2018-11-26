user='plex'
group='dms'
base_dir='/usr/local/media'
home_dir=$base_dir/home/plex

groupadd \
        -g 1602 \
        $user

useradd \
        -m \
        -d $home_dir \
        -u 1602 \
        -g 1602 \
	-G dms \
        -c 'Plex Role Account' \
       	$user

docker pull linuxserver/plex


docker create \
	--name=$user \
	--restart=always \
	--net=host \
	-e VERSION=latest \
	-e PUID=1602 -e PGID=1602 \
	-e TZ=America/Chicago \
	-v $home_dir/config:/config \
	-v $base_dir/tv:/data/tvshows \
	-v $base_dir/kids_tv:/data/kids_tv\
	-v $base_dir/movies:/data/movies \
	-v $base_dir/kids_movies:/data/kids_movies \
	-v $base_dir/transcode:/transcode \
	linuxserver/plex

chown -R $user:$user $home_dir
chmod -R 775 $home_dir

## docker container start plex
	
	#-p 32400:32400 \
	#-p 32400:32400/udp \
	#-p 32469:32469 \
	#-p 32469:32469/udp \
	#-p 5353:5353/udp \
	#-p 1900:1900/udp \
