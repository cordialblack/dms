user='sonarr'
group='dms'
base_dir='/usr/local/media'
home_dir=$base_dir/$user

groupadd \
	-g 1601 \
	$user

useradd \
	-m \
	-d $home_dir \
	-u 1601 \
	-g 1601 \
	-G dms \
	-c 'Sonarr Role Account' \
	$user

docker pull linuxserver/$user

docker create \
	--name=$user \
	--restart=always \
	-v $home_dir/config:/config \
	-v $base_dir/downloads:/downloads \
	-v $base_dir/tv:/tv \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ=America/Chicago \
	-e PGID=1601 -e PUID=1601  \
	-p 8989:8989 \
	-p 9898:9898 \
	linuxserver/$user

chown -R $user:$group $home_dir
chmod -R 775 $home_dir

## docker container start sonarr
