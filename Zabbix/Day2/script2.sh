### Preparing
sudo setenforce 0
sudo systemctl stop firewalld

### Downloading and installing zabbix-agent
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum clean all
sudo yum install -y  zabbix-agent

### Configuring agent
sudo sed -i '117c Server=${zabbix_ip}' /etc/zabbix/zabbix_agentd.conf
sudo sed -i '158c ServerActive=${zabbix_ip}' /etc/zabbix/zabbix_agentd.conf
sudo sed -i '199c HostMetadataItem=system.uname' /etc/zabbix/zabbix_agentd.conf
sudo sed -i '169c Hostname=tomcat_ldap' /etc/zabbix/zabbix_agentd.conf

### Starting and enabling zabbix-agent
sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent


### Installing tomcat
sudo yum install -y wget
sudo yum install -y java-1.8.0
sudo yum install -y java-1.8.0-openjdk-devel
sudo groupadd tomcat
sudo mkdir /opt/tomcat
sudo useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
sudo cd /opt/tomcat
sudo wget https://mirror.datacenter.by/pub/apache.org/tomcat/tomcat-8/v8.5.57/bin/apache-tomcat-8.5.57.tar.gz
sudo tar -zxvf apache-tomcat-8.5.57.tar.gz -C /opt/tomcat --strip-components=1
sudo /opt/tomcat/bin/startup.sh
sudo wget https://updates.jenkins-ci.org/download/war/2.256/jenkins.war
sudo cp ./jenkins.war /opt/tomcat/webapps/


### simulation of deployment
sudo touch /opt/tomcat/webapp/test[a,b,c,d,].war
