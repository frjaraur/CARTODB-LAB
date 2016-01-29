#################################################

	Just a CartoDB LAB for Testing

#################################################

cd lab-ldap && docker built -t lab:ldap .

cd lab-cartodb && docker built -t lab:ldap .

docker run --name ldap -d lab:ldap daemon

docker run --name cartodb --link ldap:ldap  lab:cartodb

docker exec cartodb ldapsearch -xLLL -h ldap -b "dc=cartodb,dc=com" "(objectClass=organizationalRole)"
