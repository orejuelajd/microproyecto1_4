#!/usr/bin/env bash

echo "Actualizaacion e instalando paquetes vma2"
#apt-get update && apt-get upgrade -y

echo "Instalacion lxd 4.0 vma2"
snap install lxd --channel=4.0/stable
newgrp lxd

echo "Creacion preseed vma2"
cat > /home/vagrant/preseed.yaml <<EOF
config:
  core.https_address: 192.168.100.132:8443
networks:
- config:
    bridge.mode: fan
    fan.underlay_subnet: 192.168.100.0/24
  description: ""
  managed: true
  name: lxdfan0
  type: bridge
profiles:
- config: {}
  description: ""
  devices: {}
  name: default
cluster:
  server_name: vma2
  enabled: true
  member_config: []
  cluster_address: 192.168.100.131:8443
  
  cluster_certificate: "-----BEGIN CERTIFICATE-----
  -----END CERTIFICATE-----"
  server_address: "192.168.100.132:8443"
  cluster_password: admin
EOF

echo "Obtencion certificado vma2"
sed '44r /home/vagrant/carpeta_sincronizada/claveCertificado.txt' /home/vagrant/preseed.yaml > /home/vagrant/preseedCertificado.yaml

echo "Envio de preseed vma2"
cat /home/vagrant/preseedCertificado.yaml | lxd init --preseed

echo "Creacion contenedor web1"
lxc launch ubuntu:20.04 web1 --target vma2
sleep 10

echo "Instalacion apache2 en web1"
lxc exec web1 -- apt update && apt upgrade -y
lxc exec web1 -- apt-get install apache2 -y
lxc exec web1 -- systemctl enable apache2

echo "Creacion index web1"
cat > /home/vagrant/index.html <<INDEX
<!DOCTYPE html>
<html>
	<body>
		web1
	</body>
</html>
INDEX

echo "Envio index al contenedor web1"
lxc file push /home/vagrant/index.html web1/var/www/html/index.html

echo "Inicio apache2 en web1"
lxc exec web1 -- systemctl start apache2
lxc exec web1 -- systemctl restart apache2

lxc storage create data dir

echo "Creacion contenedor web2backup"
lxc launch ubuntu:20.04 web2backup --target vma2
sleep 10

echo "Instalacion apache2 en web2backup"
lxc exec web2backup -- apt update && apt upgrade -y
lxc exec web2backup -- apt-get install apache2 -y
lxc exec web2backup -- systemctl enable apache2

echo "Creacion index web2backup"
cat > /home/vagrant/indexweb2backup.html <<INDEX
<!DOCTYPE html>
<html>
	<body>
		web2backup
	</body>
</html>
INDEX

echo "Envio index al contenedor web2backup"
lxc file push /home/vagrant/indexweb2backup.html web2backup/var/www/html/index.html

echo "Inicio apache2 en web2backup"
lxc exec web2backup -- systemctl start apache2
lxc exec web2backup -- systemctl restart apache2