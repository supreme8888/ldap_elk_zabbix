### Preparing system
sudo setenforce 0
sudo systemctl stop firewalld
DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${key1} DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

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

### Install apache
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd

### Configuring datalog-agent
sudo sed -i '550c logs_enabled: true' /etc/datadog-agent/datadog.yaml
sudo systemctl restart datadog-agent
sudo mkdir /etc/datadog-agent/conf.d/httpd.d
sudo chown dd-agent:dd-agent /etc/datadog-agent/conf.d/httpd.d
sudo chmod 745 /var/log
sudo chmod 705 /var/log/httpd
sudo chmod 745 /var/log/httpd/access_log
sudo cat > /etc/datadog-agent/conf.d/httpd.d/conf.yaml <<EOF
logs:

  - type: file
    path: /var/log/httpd/access_log
    service: httpd
    source: httpd
EOF
sudo systemctl restart datadog-agent
sudo cat > /etc/datadog-agent/conf.d/http_check.d/conf.yaml <<EOT
instances:

    ## @param name - string - required
    ## Name of your Http check instance.
    #
  - name: tomcat

    ## @param url - string - required
    ## Url to check
    ## Non-standard ports are supported using http://hostname:port syntax
    #
    url: http://localhost:8080
EOT
sudo systemctl restart datadog-agent
