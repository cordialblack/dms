base_dir='/usr/local/media'
home_dir=$base_dir/couchpotato

groupadd \
	-g 1604 \
	couchpotato

useradd \
	-m \
	-d $home_dir \
	-u 1604 \
	-g 1604 \
	-c 'Couchpotato Role Account' \
	couchpotato

docker pull linuxserver/couchpotato

docker create --name=couchpotato \
	--restart=always \
	-v $home_dir/config:/config \
	-v $home_dir/downloads:/downloads \
	-v $home_dir/movies:/movies \
	-e PGID=1604 -e PUID=1604 \
	-e TZ=America/Chicago \
	-p 5050:5050 \
	linuxserver/couchpotato

## docker container start couchpotato
