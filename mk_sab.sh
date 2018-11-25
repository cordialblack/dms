user='sabnzbd'
group='dms'
base_dir='/usr/local/media'
home_dir=$base_dir/home/$user

groupadd \
        -g 1603 \
        $user

useradd \
        -m \
        -d $home_dir \
        -u 1603 \
        -g 1603 \
	-G dms \
        -c 'Sabnzbd Role Account' \
        $user

docker pull linuxserver/$user

docker create \
	--name=$user \
	--restart=always \
	-v $home_dir/config:/config \
	-v $base_dir/downloads:/downloads \
	-v $base_dir/incomplete-downloads:/incomplete-downloads \
	-e PGID=1603 -e PUID=1603 \
	-e TZ=America/Chicago \
	-p 8080:8080 -p 9090:9090 \
	linuxserver/$user

chown -R $user:$user $home_dir
chmod -R 775 $home_dir

## docker container start sabnzbd
