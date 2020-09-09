
sudo yum install -y openldap openldap-servers openldap-clients
sudo systemctl start slapd
sudo systemctl enable slapd
sudo echo "dn: olcDatabase={0}config,cn=config" > /home/supreme888/ldaprootpasswd.ldif
sudo echo "changetype: modify" >>  /home/supreme888/ldaprootpasswd.ldif
sudo echo "add: olcRootPW" >>  /home/supreme888/ldaprootpasswd.ldif
passwd=`slappasswd -s djghjc88`
sudo echo "olcRootPW: "$passwd  >> /home/supreme888/ldaprootpasswd.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /home/supreme888/ldaprootpasswd.ldif
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown ldap:ldap  /var/lib/ldap/DB_CONFIG
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
sudo systemctl restart slapd
sudo cat > /home/supreme888/ldapdomain.ldif << EOF
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" read by dn.base="cn=Manager,dc=devopsldab,dc=com" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=devopsldab,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=devopsldab,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $passwd

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
dn="cn=Manager,dc=devopsldab,dc=com" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=devopsldab,dc=com" write by * read
EOF

sudo cat > /home/supreme888/baseldapdomain.ldif << EOF
dn: dc=devopsldab,dc=com
objectClass: top
objectClass: dcObject
objectclass: organization
o: devopsldab com
dc: devopsldab

dn: cn=Manager,dc=devopsldab,dc=com
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=devopsldab,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=devopsldab,dc=com
objectClass: organizationalUnit
ou: Group
EOF

sudo cat > /home/supreme888/ldapgroup.ldif << EOF
dn: cn=Manager,ou=Group,dc=devopsldab,dc=com
objectClass: top
objectClass: posixGroup
gidNumber: 1005
EOF

sudo cat > /home/supreme888/ldapuser.ldif << EOF
dn: uid=my_user,ou=People,dc=devopsldab,dc=com
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: my_user
uid: my_user
uidNumber: 1005
gidNumber: 1005
homeDirectory: /home/my_user
userPassword: $passwd
loginShell: /bin/bash
gecos: my_user
shadowLastChange: 0
shadowMax: -1
shadowWarning: 0
EOF

sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /home/supreme888/ldapdomain.ldif
sudo ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w djghjc88 -f /home/supreme888/baseldapdomain.ldif
sudo sudo ldapadd -x -w djghjc88 -D "cn=Manager,dc=devopsldab,dc=com" -f /home/supreme888/ldapgroup.ldif
sudo ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w djghjc88 -f /home/supreme888/ldapuser.ldif
sudo yum --enablerepo=epel -y install phpldapadmin
sudo sed -i '398c// $servers->setValue(\x27'login\\x27',\x27'attr\\x27',\x27'uid\\x27');' /etc/phpldapadmin/config.php
sudo sed -i '12i\    Require all granted'  /etc/httpd/conf.d/phpldapadmin.conf
sudo systemctl restart httpd
sudo rm /home/supreme888/*.ldif
