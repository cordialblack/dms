user='couchpotato'
group='dms'
mkdir $base_dir
home_dir=$base_dir/$user

groupadd \
	-g 1604 \
	$user

useradd \
	-m \
	-d $home_dir \
	-u 1604 \
	-g 1604 \
	-c 'Couchpotato Role Account' \
	$user

docker pull linuxserver/$user

docker create \
	--name=$user \
	--restart=always \
	-v $home_dir/config:/config \
	-v $home_dir/downloads:/downloads \
	-v $home_dir/movies:/movies \
	-e PGID=1604 -e PUID=1604 \
	-e TZ=America/Chicago \
	-p 5050:5050 \
	linuxserver/$user

chown -R $user:$user $home_dir
chmod -R 775 $home_dir

## docker container start couchpotato
