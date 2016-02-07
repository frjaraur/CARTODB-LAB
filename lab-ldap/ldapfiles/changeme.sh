#!/bin/bash
#
#
echo
echo "Change root domain password...."
echo
echo

/usr/bin/ldapsearch -H ldapi:// -LLL -Q -Y EXTERNAL -b "cn=config" "(olcRootDN=*)" dn olcRootDN olcRootPW > /tmp/.actualroot.ldif
/usr/sbin/slappasswd -h {SSHA} >/tmp/.newpasswd
NEWPASSWD="$(cat /tmp/.newpasswd)"


ROOTDN="$(awk '/olcRootDN/ { print $2 }' /tmp/.actualroot.ldif)"

echo
echo "New hashed password '${NEWPASSWD}'"
echo

cat <<EOF >/tmp/.changerootpasswd_step1.ldif
dn: olcDatabase={1}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: ${NEWPASSWD}
EOF

cat /tmp/.changerootpasswd_step1.ldif
/usr/bin/ldapmodify -H ldapi:// -Y EXTERNAL -f /tmp/.changerootpasswd_step1.ldif

service slapd restart && echo && echo "Service Rstarted..." && echo

cat <<EOF >/tmp/.changerootpasswd_step2.ldif
dn: ${ROOTDN}
changetype: modify
replace: userPassword
userPassword: ${NEWPASSWD}
EOF

cat /tmp/.changerootpasswd_step2.ldif
echo "ROOTDN ${ROOTDN}"
/usr/bin/ldapmodify -H ldap:// -x -D "${ROOTDN}" -W -f  /tmp/.changerootpasswd_step2.ldif

rm -f  /tmp/.changerootpasswd_step2.ldif  /tmp/.changerootpasswd_step1.ldif /tmp/.newpasswd /tmp/.actualroot.ldif
