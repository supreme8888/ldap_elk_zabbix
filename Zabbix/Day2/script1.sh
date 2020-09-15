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

### Adding User parameters
sudo echo "UserParameter=homedirfiles,ls -al /home/supreme888 | wc | awk '{ print $1 }'" >> /etc/zabbix/zabbix_agentd.conf

### Starting and enabling zabbix-agent
sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent
