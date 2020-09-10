
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
sudo cat > /home/supreme888/openssh-lpk.ldif << EOF
dn: cn=openssh-lpk,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: openssh-lpk
olcAttributeTypes: ( 1.3.6.1.4.1.24552.500.1.1.1.13 NAME 'sshPublicKey'
    DESC 'MANDATORY: OpenSSH Public key'
    EQUALITY octetStringMatch
    SYNTAX 1.3.6.1.4.1.1466.115.121.1.40 )
olcObjectClasses: ( 1.3.6.1.4.1.24552.500.1.1.2.0 NAME 'ldapPublicKey' SUP top AUXILIARY
    DESC 'MANDATORY: OpenSSH LPK objectclass'
    MAY ( sshPublicKey $ uid )
    )
EOF
sudo systemctl restart slapd

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f  /home/supreme888/openssh-lpk.ldif
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
dn: cn=test,ou=People,dc=devopsldab,dc=com
cn: test
gidnumber: 1005
givenname: test
homedirectory: /home/users/test
loginshell: /bin/bash
objectclass: inetOrgPerson
objectclass: posixAccount
objectclass: top
objectclass: ldapPublicKey
sn: test
sshpublickey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfoVH/LxCMOSSXye6LyP6WtDWzlBGcdPIfOtofNyL+XX25eNufseRr7a3qYrlr1On83sPsz80ENWhyWUyFoAh700S60piR/PGSRVm9A2LCv8KpNRe9z1nu6phiORsNdvj+prZ2FdO8q4UdOMFw/J8QiULjHYZ1VE9gqZHS7wCdRt/xXHi5cbQqSDqVVAC0I8qeYe39sgrSjDCnOmKuqhSt7KegTRbpJW2/WomagxcFQ9kH0RWauWRf6LOeHDCwc5vd0Hb6O7voD4o68HCyoblsstONcGlknM9VCYC1NQnsk5zpSfwlQ79uEkiQ2kajqCCSTOQ5YE4cnPpW+wLggewJ vvv@vvv-VirtualBox
uid:test
uidnumber: 1010
userpassword: test
EOF

#sudo cat > /home/supreme888/ldapuser.ldif << EOF
#dn: cn=my_user,ou=People,dc=devopsldab,dc=com
#objectClass: top
#objectClass: account
#objectClass: posixAccount
#objectClass: shadowAccount
#objectClass: ldapPublicKey
#cn: my_user
#uid: my_user
#uidNumber: 1005
#gidNumber: 1005
#homeDirectory: /home/my_user
#userPassword: $passwd
#loginShell: /bin/bash
#gecos: my_user
#shadowLastChange: 0
#shadowMax: 50000
#shadowWarning: 0
#sshPublicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfoVH/LxCMOSSXye6LyP6WtDWzlBGcdPIfOtofNyL+XX25eNufseRr7a3qYrlr1On83sPsz80ENWhyWUyFoAh700S60piR/PGSRVm9A2LCv8KpNRe9z1nu6phiORsNdvj+prZ2FdO8q4UdOMFw/J8QiULjHYZ1VE9gqZHS7wCdRt/xXHi5cbQqSDqVVAC0I8qeYe39sgrSjDCnOmKuqhSt7KegTRbpJW2/WomagxcFQ9kH0RWauWRf6LOeHDCwc5vd0Hb6O7voD4o68HCyoblsstONcGlknM9VCYC1NQnsk5zpSfwlQ79uEkiQ2kajqCCSTOQ5YE4cnPpW+wLggewJ vvv@vvv-VirtualBox
#EOF


sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /home/supreme888/ldapdomain.ldif
sudo ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w djghjc88 -f /home/supreme888/baseldapdomain.ldif
sudo sudo ldapadd -x -w djghjc88 -D "cn=Manager,dc=devopsldab,dc=com" -f /home/supreme888/ldapgroup.ldif
sudo ldapadd -x -D cn=Manager,dc=devopsldab,dc=com -w djghjc88 -f /home/supreme888/ldapuser.ldif
sudo yum --enablerepo=epel -y install phpldapadmin
sudo sed -i '398c// $servers->setValue(\x27'login\\x27',\x27'attr\\x27',\x27'uid\\x27');' /etc/phpldapadmin/config.php
sudo sed -i '12i\    Require all granted'  /etc/httpd/conf.d/phpldapadmin.conf
sudo systemctl restart httpd
sudo rm /home/supreme888/*.ldif
