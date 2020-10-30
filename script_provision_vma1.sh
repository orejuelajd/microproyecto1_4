#!/usr/bin/env bash
echo "Actualizacion de vma1"
#apt-get update && apt-get upgrade -y

echo "Instalacion de lxd"
snap install lxd --channel=4.0/stable
newgrp lxd

echo "Generacion de archivo yaml para lxd init"
cat > /home/vagrant/preseed.yaml <<EOF
config:
  core.https_address: 192.168.100.131:8443
  core.trust_password: admin
networks:
- config:
    bridge.mode: fan
    fan.underlay_subnet: 192.168.100.0/24
  description: ""
  managed: false
  name: lxdfan0
  type: ""
storage_pools:
- config: {}
  description: ""
  name: local
  driver: dir
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      nictype: bridged
      parent: lxdfan0
      type: nic
    root:
      path: /
      pool: local
      type: disk
  name: default
cluster:
  server_name: vma1
  enabled: true
  member_config: []
  cluster_address: ""
  cluster_certificate: ""
  server_address: ""
  cluster_password: ""
EOF

echo "Uso de archivo yaml en el comando lxd init"
cat /home/vagrant/preseed.yaml | lxd init --preseed

echo "Extraccion en formato especifico la llave en un archivo txt"
sudo -i sed ':a;N;$!ba;s/\n/\n\n/g' /var/snap/lxd/common/lxd/server.crt > /home/vagrant/carpeta_sincronizada/certificado.txt

echo "Extraccion de la llave omitiendo begin y end certificate"
sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/{/-----BEGIN CERTIFICATE-----\|-----END CERTIFICATE-----/!p;}' /home/vagrant/carpeta_sincronizada/certificado.txt > /home/vagrant/carpeta_sincronizada/claveCertificado.txt

echo "Creacion contenedor haproxy"
lxc launch ubuntu:20.04 haproxy
sleep 10

echo "Instacion haproxy"
lxc exec haproxy -- apt update && apt upgrade
lxc exec haproxy -- apt-get install haproxy -y
lxc exec haproxy -- systemctl enable haproxy

echo "Configuracion haproxy.cfg"
cat > /home/vagrant/backfront <<A

backend web-backend
        balance roundrobin
        stats enable
        stats auth haproxy:admin
        stats uri /haproxy?stats
		
        server web1 web1.lxd:80 check
        server web2 web2.lxd:80 check
        server web1backup web1backup.lxd:80 check backup
        server web2backup web2backup.lxd:80 check backup
frontend http
        bind *:80
        default_backend web-backend
A

lxc exec haproxy -- cat /etc/haproxy/haproxy.cfg > haproxyInicial.cfg
cat haproxyInicial.cfg backfront > haproxyConfigurado.cfg
lxc file push /home/vagrant/haproxyConfigurado.cfg haproxy/etc/haproxy/haproxy.cfg


echo "Modificacion pagina de error 503"
cat > /home/vagrant/503.http <<A
HTTP/1.0 503 Service Unavailable
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html><body><h1>Servidores no disponibles</h1>
No hay servidores disponibles para atender su solicitud.
</body></html>
A

lxc file push /home/vagrant/503.http haproxy/etc/haproxy/errors/503.http

lxc stop web1
lxc stop web2
lxc stop web1backup
lxc stop web2backup

lxc restart haproxy

lxc start web1
lxc start web2
lxc start web1backup
lxc start web2backup

lxc config device add haproxy puertohaproxy5085 proxy listen=tcp:192.168.100.131:5085 connect=tcp:127.0.0.1:80