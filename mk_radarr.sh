user='radarr'
group='dms'
base_dir='/usr/local/media'
home_dir=$base_dir/home/$user

mkdir -p $home_dir

groupadd \
	-g 1600 \
	$user

useradd \
	-d $home_dir \
	-u 1600 \
	-g 1600 \
	-G dms \
	-c 'Radarr Role Account' \
	$user

docker pull linuxserver/$user

docker create \
	--name=$user \
	--restart=always \
	-v $home_dir/config:/config \
	-v $base_dir/downloads:/downloads \
	-v $base_dir/movies:/movies \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ=America/Chicago \
	-e PGID=1600 -e PUID=1600  \
	-p 7878:7878 \
	-p 8787:8787 \
	linuxserver/$user

chown -R $user:$group $home_dir
chmod -R 775 $home_dir

## docker container start radarr
