#!/usr/bin/env bash

## AUTHOR:
### 	Ciro Mota
## DESCRIPTION:
###			This script will provision an MQTT instance,
### 		to communicate with the ESP32 project running under Wowki.
## LICENSE:
###		  GPLv3. <https://github.com/ciro-mota/SenaiDEST3-projetos/blob/main/LICENSE>
## CHANGELOG:
### 		Last Edition 05/09/2025. <https://github.com/ciro-mota/SenaiDEST3-projetos/commits/main/>

export DEBIAN_FRONTEND=noninteractive

configure_timezone() {

ln -fs /usr/share/zoneinfo/America/Bahia /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

}


install_components() {

apt update -y && apt upgrade -y

apt install git fail2ban -y

curl -fsSL get.docker.com | bash 2>/dev/null

}

fail2ban_configure() {

sudo tee /etc/fail2ban/jail.d/sshd.local << 'EOF'
[sshd]
enabled   = true
port      = ssh
filter    = sshd
logpath   = /var/log/auth.log
backend   = systemd
maxretry  = 2
findtime  = 600
bantime   = 86400
ignoreip  = 127.0.0.1 192.168.0.10
EOF

}

deploy_ambient() {

#shellcheck disable=SC2164
git clone https://github.com/ciro-mota/SenaiDEST3-projetos && cd "$(basename "$_" .git)"

docker compose -f files/docker-compose.yml up --build -d

}

configure_timezone
install_components
fail2ban_configure
deploy_ambient