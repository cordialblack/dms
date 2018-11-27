#!/bin/bash

## https://docs.docker.com/install/linux/docker-ce/debian/
. /etc/os-release

apt-get update

apt-get -y install \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg2 \
	software-properties-common

curl -fsSL https://download.docker.com/linux/$ID/gpg | sudo apt-key add -
sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/$ID \
	$(lsb_release -cs) \
	stable"

apt-get update

apt-get -y install docker-ce

groupadd dms
mkdir /usr/local/media
