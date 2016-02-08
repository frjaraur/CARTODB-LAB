#!/bin/sh

Usage(){
	echo "Usage: $0 <USERNAME> <PASSWORD> "
	exit 0
}

[ "$1" = "-help" ] && Usage
[ $# -eq 1 ] && Usage

USERNAME=$1
PASSWORD=$2

SLAPPASSWORD="/usr/sbin/slappasswd"

PASSWORDHESHED="$($SLAPPASSWORD -h '{SSHA}' -s $PASSWORD)"

cat <<EOF >/tmp/${USER}.ldif
dn: cn=${USERNAME},dc=cartodb,dc=com
changetype: modify
replace: userPassword
userPassword: ${PASSWORDHESHED}
EOF

echo "Enter Admin password ('password' by default if not changed)."

/usr/bin/ldapmodify -x -D cn=admin,dc=cartodb,dc=com -W -f /tmp/${USER}.ldif
[ $? -ne 0 ] && echo "Error: Can not change password for ${USER}"

rm -f /tmp/${USER}.ldif
