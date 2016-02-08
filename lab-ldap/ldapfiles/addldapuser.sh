#!/bin/sh

Usage(){
	echo "Usage: $0 <USERNAME> <PASSWORD> <EMAIL>"
	exit 0
}

QuickEmailValidate(){
	[ $(echo $1|grep -c "@" ) -ne 1 ] && return 1
	[ $(echo $1|grep -c "." ) -lt 1 ] && return 1
	[ "$(echo $1|grep '^[a-zA-Z0-9._%+-]')" = "" ] && return 1
	return 0

}

[ "$1" = "-help" ] && Usage
[ $# -ne 3 ] && Usage

USERNAME=$1
PASSWORD=$2
EMAIL=$3
QuickEmailValidate ${EMAIL}
[ $? -ne 0 ] && echo "ERROR: Invalid email address" && Usage

SLAPPASSWORD="/usr/sbin/slappasswd"

PASSWORDHESHED="$($SLAPPASSWORD -h '{SSHA}' -s ${PASSWORD})"

cat <<EOF >/tmp/${USER}.ldif
dn: cn=${USERNAME},dc=cartodb,dc=com
objectClass: simpleSecurityObject
objectClass: organizationalRole
cn: ${USERNAME}
user_id: ${USERNAME}
user_name: ${USERNAME}
description: CartoDB LDAP user ${USERNAME}
user_password: ${PASSWORDHESHED}
email: ${EMAIL}
EOF

echo "Enter Admin password ('password' by default if not changed)."
/usr/bin/ldapadd -x -D cn=admin,dc=cartodb,dc=com -W -c -f /tmp/${USER}.ldif
[ $? -ne 0 ] && echo "Error: Can not create user account ${USER}"

rm -f /tmp/${USER}.ldif
