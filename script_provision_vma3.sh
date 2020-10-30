#!/usr/bin/env bash

echo "Actualizacion e instalando paquetes vma3"
#apt-get update && apt-get upgrade -y

echo "Instalacion lxd 4.0 vma3"
snap install lxd --channel=4.0/stable
newgrp lxd

echo "Creacion preseed vma3"
cat > /home/vagrant/preseed.yaml <<EOF
config:
  core.https_address: 192.168.100.133:8443
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
  server_name: vma3
  enabled: true
  member_config: []
  cluster_address: 192.168.100.131:8443
  
  cluster_certificate: "-----BEGIN CERTIFICATE-----
  -----END CERTIFICATE-----"
  server_address: "192.168.100.133:8443"
  cluster_password: admin
EOF

echo "Obtencion certificado vma3"
sed '44r /home/vagrant/carpeta_sincronizada/claveCertificado.txt' /home/vagrant/preseed.yaml > /home/vagrant/preseedCertificado.yaml

echo "Envio de preseed vma3"
cat /home/vagrant/preseedCertificado.yaml | lxd init --preseed

lxc storage create data dir

echo "Creacion contenedor web2"
lxc launch ubuntu:20.04 web2 --target vma3
sleep 10

echo "Instalacion apache2 en web2"
lxc exec web2 -- apt update && apt upgrade -y
lxc exec web2 -- apt-get install apache2 -y
lxc exec web2 -- systemctl enable apache2

echo "Creacion index web2"
cat > /home/vagrant/index.html <<INDEX
<!DOCTYPE html>
<html>
	<body>
		web2
	</body>
</html>
INDEX

echo "Envio index al contenedor web2"
lxc file push /home/vagrant/index.html web2/var/www/html/index.html

echo "Inicio apache2 en web2"
lxc exec web2 -- systemctl start apache2
lxc exec web2 -- systemctl restart apache2

echo "Creacion contenedor web1backup"
lxc launch ubuntu:20.04 web1backup --target vma3
sleep 10

echo "Instalacion apache2 en web1backup"
lxc exec web1backup -- apt update && apt upgrade -y
lxc exec web1backup -- apt-get install apache2 -y
lxc exec web1backup -- systemctl enable apache2

echo "Creacion index web1backup"
cat > /home/vagrant/indexweb1backup.html <<INDEX
<!DOCTYPE html>
<html>
	<body>
		web1backup
	</body>
</html>
INDEX

echo "Envio index al contenedor web1backup"
lxc file push /home/vagrant/indexweb1backup.html web1backup/var/www/html/index.html

echo "Inicio apache2 en web1backup"
lxc exec web1 -- systemctl start apache2
lxc exec web1 -- systemctl restart apache2