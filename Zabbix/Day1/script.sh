### Preparing system
sudo setenforce 0
sudo systemctl stop firewalld

### installing and configuring DB for zabbix
sudo yum install -y mariadb mariadb-server
sudo /usr/bin/mysql_install_db --user=mysql
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo /usr/bin/mysqladmin -u root password mariadbroot

### Installing zabbix server and client
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
sudo yum clean all
sudo yum install -y zabbix-server-mysql zabbix-agent
sudo yum install -y centos-release-scl
sudo sed -i '11c enabled=1' /etc/yum.repos.d/zabbix.repo
sudo yum install -y zabbix-web-mysql-scl zabbix-apache-conf-scl

### customisation db for zabbix
sudo mysql -uroot -pmariadbroot -e "create database zabbix character set utf8 collate utf8_bin"
sudo mysql -uroot -pmariadbroot -e "create user 'zabbix'@'localhost' identified by 'zabbixroot'"
sudo mysql -uroot -pmariadbroot -e "grant all privileges on zabbix.* to 'zabbix'@'localhost'"
sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix --password=zabbixroot

### configuring zabbix server
sudo sed -i '124c DBPassword=zabbixroot' /etc/zabbix/zabbix_server.conf
sudo sed -i '91c DBHost=localhost' /etc/zabbix/zabbix_server.conf
sudo sed -i '24c php_value[date.timezone] = Europe/Minsk' /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf
sudo cat > /etc/zabbix/web/zabbix.conf.php << EOF
<?php
// Zabbix GUI configuration file.

\$DB['TYPE']				= 'MYSQL';
\$DB['SERVER']			= 'localhost';
\$DB['PORT']				= '0';
\$DB['DATABASE']			= 'zabbix';
\$DB['USER']				= 'zabbix';
\$DB['PASSWORD']			= 'zabbixroot';

// Schema name. Used for PostgreSQL.
\$DB['SCHEMA']			= '';

// Used for TLS connection.
\$DB['ENCRYPTION']		= false;
\$DB['KEY_FILE']			= '';
\$DB['CERT_FILE']		= '';
\$DB['CA_FILE']			= '';
\$DB['VERIFY_HOST']		= false;
\$DB['CIPHER_LIST']		= '';

\$DB['DOUBLE_IEEE754']	= true;

\$ZBX_SERVER				= 'localhost';
\$ZBX_SERVER_PORT		= '10051';
\$ZBX_SERVER_NAME		= 'zabbix-test';

\$IMAGE_FORMAT_DEFAULT	= IMAGE_FORMAT_PNG;
EOF

### starting zabbix
sudo systemctl restart zabbix-server zabbix-agent httpd rh-php72-php-fpm
sudo systemctl enable zabbix-server zabbix-agent httpd rh-php72-php-fpm
