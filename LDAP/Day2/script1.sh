sudo yum install -y openldap-clients
sudo yum install -y nss-pam-ldapd
sudo systemctl stop firewalld
sudo authconfig --enableldap --enableldapauth --ldapserver=${ldap_ip} --ldapbasedn="dc=devopsldab,dc=com" --enablemkhomedir --updateall
# ldap script for getting users pub key
sudo cat > /opt/ssh_ldap.sh <<EOF
#!/bin/bash
set -eou pipefail
IFS=$'\n\t'
result=\$(ldapsearch -x '(&(objectClass=posixAccount)(uid='"\$1"'))' 'sshPublicKey')
attrLine=\$(echo "\$result" | sed -n '/^ /{H;d};/sshPublicKey:/x;\$g;s/\n *//g;/sshPublicKey:/p')
if [[ "\$attrLine" == sshPublicKey::* ]]; then
  echo "\$attrLine" | sed 's/sshPublicKey:: //' | base64 -d
elif [[ "\$attrLine" == sshPublicKey:* ]]; then
  echo "\$attrLine" | sed 's/sshPublicKey: //'
else
  exit 1
fi
EOF

sudo chown root:root ​/opt/ssh_ldap.sh
sudo chmod 700 /opt/ssh_ldap.sh
# Preparing sshd to ldap
sudo sed -i '51c AuthorizedKeysCommand /opt/ssh_ldap.sh' /etc/ssh/sshd_config
sudo sed -i '52c AuthorizedKeysCommandUser root' /etc/ssh/sshd_config
sudo sed -i '65c PasswordAuthentication yes' /etc/ssh/sshd_config
sudo systemctl restart sshd


​
