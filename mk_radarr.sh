user='radarr'
group='dms'
mkdir $base_dir
home_dir=$base_dir/$user


groupadd \
	-g 1600 \
	$user

useradd \
	-m \
	-d $home_dir \
	-u 1600 \
	-g 1600 \
	-c 'Radarr Role Account' \
	$user

docker pull linuxserver/$user

docker create \
	--name=$user \
	--restart=always \
	-v $home_dir/config:/config \
	-v $home_dir/downloads:/downloads \
	-v $home_dir/movies:/movies \
	-v /etc/localtime:/etc/localtime:ro \
	-e TZ=America/Chicago \
	-e PGID=1600 -e PUID=1600  \
	-p 7878:7878 \
	-p 8787:8787 \
	linuxserver/$user

chown -R $user:$user $home_dir
chmod -R 775 $home_dir

## docker container start radarr
