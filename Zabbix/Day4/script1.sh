### Preparing system
sudo setenforce 0
sudo systemctl stop firewalld
sudo yum check-update

### Instalation Docker
sudo curl -fsSL https://get.docker.com/ | sh
sudo groupadd docker
sudo useradd -s /bin/nologin -g docker docker
sudo usermod -aG docker supreme888
sudo systemctl start docker
sudo systemctl enable docker
sudo yum install -y docker-compose


sudo cat > /home/supreme888/docker-compose.yml <<EOT
version: '3.2'
services:
    node-exporter:
        image: prom/node-exporter
        container_name: node_exporter
        volumes:
            - /proc:/host/proc:ro
            - /sys:/host/sys:ro
            - /:/rootfs:ro
        command:
            - --path.procfs=/host/proc
            - --path.sysfs=/host/sys
            - --collector.filesystem.ignored-mount-points
            - ^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)
        ports:
            - 9100:9100
        restart: always
EOT

### Unstalling apache to probe
sudo yum install -y httpd
sudo systemctl start httpd

sudo docker-compose  -f /home/supreme888/docker-compose.yml up -d
