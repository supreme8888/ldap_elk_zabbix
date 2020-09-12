sudo systemctl stop firewalld
sudo yum install -y wget
sudo yum install -y java-1.8.0
sudo yum install -y java-1.8.0-openjdk-devel
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo cat > /etc/yum.repos.d/logstash.repo << EOF
[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum install -y logstash
sudo cat > /etc/logstash/conf.d/basic.conf << EOF
input {
  file {
    path => "/opt/tomcat/logs/catalina.out"
    start_position => "beginning"
  }
}

output {
  elasticsearch {
    hosts => ["${elk_ip}:9200"]
  }
  stdout { codec => rubydebug }
}
EOF

sudo groupadd tomcat
sudo mkdir /opt/tomcat
sudo useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
sudo cd /opt/tomcat
sudo wget https://mirror.datacenter.by/pub/apache.org/tomcat/tomcat-8/v8.5.57/bin/apache-tomcat-8.5.57.tar.gz
sudo tar -zxvf apache-tomcat-8.5.57.tar.gz -C /opt/tomcat --strip-components=1
#sudo chgrp -R tomcat /opt/tomcat/conf
#sudo chmod g+rwx /opt/tomcat/conf
#sudo chmod g+r /opt/tomcat/conf/*
#sudo chown -R tomcat /opt/tomcat/logs/ /opt/tomcat/temp/ /opt/tomcat/webapps/ /opt/tomcat/work/
#sudo chgrp -R tomcat /opt/tomcat/bin
#sudo chgrp -R tomcat /opt/tomcat/lib
#sudo chmod g+rwx /opt/tomcat/bin
#sudo chmod g+r /opt/tomcat/bin/*
#sudo cat > /etc/systemd/system/tomcat.service  << EOF
#[Unit]
#Description=Apache Tomcat Web Application Container
#After=syslog.target network.target

#[Service]
#Type=forking

#Environment=JAVA_HOME=/usr/lib/jvm/jre
#Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
#Environment=CATALINA_HOME=/opt/tomcat
#Environment=CATALINA_BASE=/opt/tomcat
#Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
#Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

#ExecStart=/opt/tomcat/bin/startup.sh
#ExecStop=/bin/kill -15 $MAINPID

#User=tomcat
#Group=tomcat

#[Install]
#WantedBy=multi-user.target
#EOF

#sudo sed -i '37c  <role rolename="manager-gui"/> ' /opt/tomcat/conf/tomcat-users.xml
#sudo sed -i '40c <user username="tomcat" password="djghjc88" roles="manager-gui,admin-gui"/>' /opt/tomcat/conf/tomcat-users.xml
#sudo sed -i '43c   ' /opt/tomcat/conf/tomcat-users.xml
#sudo systemctl enable tomcat.service
#sudo systemctl start tomcat.service
sudo /opt/tomcat/bin/startup.sh
sudo sed -i '30c LS_USER=root' /etc/logstash/startup.options
sudo sed -i '31c LS_GROUP=root' /etc/logstash/startup.options
sudo /usr/share/logstash/bin/system-install
sudo systemctl enable logstash
sudo systemctl start logstash
sudo touch /opt/tomcat/webapp/test[a,b,c,d,].war
