#################################################

	Just a CartoDB LAB for Testing

#################################################

To build this lab just 
git clone https://github.com/frjaraur/CARTODB-LAB.git
docker build -t lab:ldap lab-ldap
docker build -t lab:cartodb lab-cartodb
docker run --name ldap -d lab:ldap daemon
docker run --name cartodb --link ldap:ldap lab:cartodb



Verify running ldap users:
docker exec cartodb ldapsearch -xLLL -h ldap -b "dc=cartodb,dc=com" "(objectClass=organizationalRole)"
or 
docker exec ldap ldapsearch -xLLL -h localhost -b "dc=cartodb,dc=com" "(objectClass=organizationalRole)"


################################

docker exec ldap /usr/sbin/slappasswd -h {SSHA} -s PASSWORD





################# ISSSUES

LDAP is up and can be verified
root@af1e3f5f5548:/CARTODB/cartodb# ping ldap
PING ldap (172.17.0.2) 56(84) bytes of data.
64 bytes from ldap (172.17.0.2): icmp_req=1 ttl=64 time=0.046 ms
64 bytes from ldap (172.17.0.2): icmp_req=2 ttl=64 time=0.037 ms
--- ldap ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 0.037/0.041/0.046/0.007 ms

root@af1e3f5f5548:/CARTODB/cartodb# ldapsearch -xLLL -h ldap -b "dc=cartodb,dc=com" "(objectClass=organizationalRole)" 
dn: cn=admin,dc=cartodb,dc=com
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: admin
description: LDAP administrator

dn: cn=ldap_conn_user,dc=cartodb,dc=com
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: ldap_conn_user
description: CartoDB LDAP conn_user


But LDAP test (test_ldap_connection) is not working ...

root@af1e3f5f5548:/CARTODB/cartodb# echo $HOST $PORT $CONNECTION_USER $CONNECTION_PASSWORD $DOMAIN_BASES $USER_ID_FIELD $USERNAME_FIELD
ldap 389 ldap_conn_user changeme cartodb.com user_id user_name

root@af1e3f5f5548:/CARTODB/cartodb# bundle exec rake cartodb:ldap:test_ldap_connection    
ERROR:
{:code=>34, :message=>"Invalid DN Syntax", :error_message=>nil, :matched_dn=>""}
root@af1e3f5f5548:/CARTODB/cartodb# bundle exec rake cartodb:ldap:test_ldap_connection                                     
root@af1e3f5f5548:/CARTODB/cartodb#

