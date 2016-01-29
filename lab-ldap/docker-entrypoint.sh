#!/bin/bash
set -e

ACTION=$1

[ "$ACTION" = "help" ] && echo "Run first with 'changeme' interactive for changing default password" && echo "Then just start as daemon" &&\
echo "Use recreatedb for recreate ldap configuration from the begining interactive" 


FirstRun(){
	echo "starting slapd"
	
	#/usr/sbin/slapd -h "ldap:///" -u openldap -g openldap -d 0
	
	service slapd restart
	
	echo "Load default ldap domain ... [cartodb.com] "
	echo
	echo "ACLs..........."
	echo
	ldapadd -Y EXTERNAL -H ldapi:/// -f /ldap_utils/acls.ldif
		
	echo
	echo "Frontend Objects ..........."
	echo
	ldapadd -x -D cn=admin,dc=cartodb,dc=com -w password -c -f /ldap_utils/objects.ldif
	pkill slapd

}


Setup(){
		/ldap_utils/changeme.sh
		touch $LDAPDATA/.changed
}


[ ! -f $LDAPDATA/.changed ] && echo "Remember to change admin initial password 'password' ... "


case $ACTION in 
	
	daemon)
		FirstRun
		/usr/sbin/slapd -h "ldap:///" -u openldap -g openldap -d 0
		
	;;
	setup)
		FirstRun
		/usr/sbin/slapd -h "ldap:///" -u openldap -g openldap -d 0
		Setup

	;;	
	
	recreatedb)
		/ldap_utils/recreate_ldap.sh
		[ -f $LDAPDATA/.changed ] && rm -f $LDAPDATA/.changed
		/ldap_utils/changeme.sh
		touch $LDAPDATA/.changed
		
	;;
	*)	
		exec "$@"
	;;
esac
