sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo cat > /etc/yum.repos.d/elasticsearch.repo << EOF
[elasticsearch]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=0
autorefresh=1
type=rpm-md
EOF
#sudo yum install logstash
sudo yum install -y --enablerepo=elasticsearch elasticsearch
sudo sed -i '23c node.name: node-1' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '55c network.host: ${elk_ip}' /etc/elasticsearch/elasticsearch.yml
sudo sed -i '72c cluster.initial_master_nodes: ["node-1"]' /etc/elasticsearch/elasticsearch.yml
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
sudo cat > /etc/yum.repos.d/kib.repo << EOF
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum install -y kibana
sudo sed -i '7c server.host: "0.0.0.0"' /etc/kibana/kibana.yml
sudo sed -i '28c elasticsearch.hosts: ["http://${elk_ip}:9200"]' /etc/kibana/kibana.yml
sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana
