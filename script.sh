#!/usr/bin/env bash

## AUTHOR:
### 	Ciro Mota
## DESCRIPTION:
###			This script will provision an MQTT instance,
### 		to communicate with the ESP32 project running under Wowki.
## LICENSE:
###		  GPLv3. <https://github.com/ciro-mota/SenaiDEST3-projetos/blob/main/LICENSE>
## CHANGELOG:
### 		Last Edition 23/08/2025. <https://github.com/ciro-mota/SenaiDEST3-projetos/commits/main/>

export DEBIAN_FRONTEND=noninteractive

configure_timezone() {

ln -fs /usr/share/zoneinfo/America/Bahia /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

}


install_docker_components() {

apt update -y && apt upgrade -y

curl -fsSL get.docker.com | bash 2>/dev/null

}

configure_timezone
install_docker_components
