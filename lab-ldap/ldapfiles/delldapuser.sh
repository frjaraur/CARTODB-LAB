#!/bin/sh

Usage(){
	echo "Usage: $0 <USERNAME>"
	exit 0
}

[ "$1" = "-help" ] && Usage
[ $# -ne 1 ] && Usage

USERNAME=$1

echo "Enter Admin password ('password' by default if not changed)."
/usr/bin/ldapsearch -LLL -p 389 -x -D 'cn=${USER},cn=users,dc=cartodb,dc=com' -W -b 'cn=users,dc=cartodb,dc=com'
[ $? -ne 0 ] && echo "Error: User account ${USER} does not exist"

echo "Enter Admin password ('password' by default if not changed)."
/usr/bin/ldapdelete -x  -D 'cn=admin,dc=cartodb,dc=com' -W 'cn=${USER},dc=cartodb,dc=com'
[ $? -ne 0 ] && echo "Error: Can not delete user account ${USER}"

