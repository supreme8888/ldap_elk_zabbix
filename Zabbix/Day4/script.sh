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

### Installation of components
#sudo docker pull prom/prometheus:latest
#sudo docker pull grafana/grafana
#sudo docker run -d --name=grafana -p 3000:3000 grafana/grafana
# sudo docker pull prom/node-exporter
#sudo docker run -d --name=prometheus -p 9100:9100 prom/node-exporter:latest



sudo cat > /home/supreme888/docker-compose.yml <<EOT
version: '3.2'
services:
    prometheus:
        image: prom/prometheus:latest
        container_name: prometheus
        volumes:
            - ./prometheus:/etc/prometheus/
        command:
            - --config.file=/etc/prometheus/prometheus.yml
        ports:
            - 9090:9090
        links:
            - cadvisor:cadvisor
            - node-exporter:node-exporter
        depends_on:
            - cadvisor
        restart: always
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

    alertmanager:
        image: prom/alertmanager
        container_name: alert_manager
        ports:
            - 9093:9093
        volumes:
            - ./alertmanager/:/etc/alertmanager/
        restart: always
        command:
            - --config.file=/etc/alertmanager/config.yml
            - --storage.path=/alertmanager
    cadvisor:
        image: google/cadvisor
        container_name: cadvisor
        volumes:
            - /:/rootfs:ro
            - /var/run:/var/run:rw
            - /sys:/sys:ro
            - /var/lib/docker/:/var/lib/docker:ro
        ports:
            - 8081:8080
        restart: always
    grafana:
        image: grafana/grafana
        container_name: grafana
        user: "1001"
        depends_on:
            - prometheus
        ports:
            - 3000:3000
        volumes:
            - ./grafana:/var/lib/grafana
            - ./grafana/provisioning/:/etc/grafana/provisioning/
        restart: always
    blackbox_exporter:
       image: prom/blackbox-exporter
       container_name: blackbox
       ports:
           - 9115:9115
       volumes:
           - ./blackbox:/etc/blackbox_exporter
       command:
           - --config.file=/etc/blackbox_exporter/config.yml
       restart: always
EOT


### Preparing volumes for containers
sudo mkdir /home/supreme888/prometheus
sudo mkdir /home/supreme888/grafana
sudo chown supreme888:supreme888 /home/supreme888/grafana
sudo chmod 777 /home/supreme888/grafana
sudo mkdir /home/supreme888/alertmanager
sudo chown supreme888:supreme888 /home/supreme888/alertmanager
sudo mkdir /home/supreme888/blackbox
sudo chown supreme888:supreme888 /home/supreme888/blackbox

### Configs for containers
sudo cat > /home/supreme888/prometheus/prometheus.yml <<EOF
# my global config
rule_files:
    - './con.yml'

scrape_configs:
    - job_name: 'prometheus'
      scrape_interval: 120s
      static_configs:
      - targets: ['localhost:9090','cadvisor:8080','10.12.1.2:9100', '10.12.1.3:9100']
    - job_name: 'blackbox'
      metrics_path: /probe
      params:
        module: [http_2xx]
      static_configs:
        - targets:
          - http://10.12.1.2
          - http://10.12.1.3
          - http://onliner.by
      relabel_configs:
        - source_labels: [__address__]
          target_label: __param_target
        - source_labels: [__param_target]
          target_label: instance
        - target_label: __address__
          replacement: blackbox-exporter:9115

alerting:
  alertmanagers:
  - static_configs:
      - targets: ['alert-manager:9093']
EOF

sudo cat > /home/supreme888/prometheus/con.yml <<EOT
groups:
- name: ExporterDown
  rules:
  - alert: NodeDown
    expr: up{job='Node'} == 0
    for: 1m
    labels:
      severity: Error
    annotations:
      summary: "Node Explorer instance ($instance) down"
      description: "NodeExporterDown"
EOT

sudo cat > /home/supreme888/alertmanager/config.yml <<EOF
route:
  group_wait: 20s
  group_interval: 20s
  repeat_interval: 60s
  group_by: ['alertname', 'cluster', 'service']
  receiver: alertmanager-bot

receivers:
- name: alertmanager-bot
  webhook_configs:
  - send_resolved: true
    url: 'http://35.112.64.29:8080'
EOF

sudo cat > /home/supreme888/blackbox/config.yml <<EOF
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      valid_status_codes: []
      method: GET
EOF

### Unstalling apache to probe
sudo yum install -y httpd
sudo systemctl start httpd
sudo docker-compose  -f /home/supreme888/docker-compose.yml up -d
