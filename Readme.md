#################################################

	Just a CartoDB LAB for Testing

#################################################

cd lab-ldap && docker build -t lab:ldap .

cd lab-cartodb && docker build -t lab:cartodb .

docker run --name ldap -d lab:ldap daemon

docker run --name cartodb --link ldap:ldap  lab:cartodb


Verify running ldap users:
docker exec cartodb ldapsearch -xLLL -h ldap -b "dc=cartodb,dc=com" "(objectClass=organizationalRole)"
or 
docker exec ldap ldapsearch -xLLL -h localhost -b "dc=cartodb,dc=com" "(objectClass=organizationalRole)"


################################

docker exec ldap /usr/sbin/slappasswd -h {SSHA} -s PASSWORD
