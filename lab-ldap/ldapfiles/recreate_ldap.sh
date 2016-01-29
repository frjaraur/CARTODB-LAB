#!/bin/sh

export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

apt-get purge -y slapd
rm -rf /etc/ldap/slapd/*
rm -rf /var/lib/ldap/*


echo "slapd slapd/root_password changeme password" |debconf-set-selections && \
echo "slapd slapd/root_password_again changeme password" |debconf-set-selections && \
echo "slapd slapd/internal/adminpw changeme password" |debconf-set-selections && \
echo "slapd slapd/internal/generated_adminpw changeme password" |debconf-set-selections && \
echo "slapd slapd/password2 changeme password" |debconf-set-selections && \
echo "slapd slapd/password1 changeme password" |debconf-set-selections && \
echo "slapd slapd/domain string cartodb.com" |debconf-set-selections && \
echo "slapd shared/organization string cartodb" |debconf-set-selections && \
echo "slapd slapd/backend string HDB" |debconf-set-selections && \
echo "slapd slapd/purge_database boolean true" |debconf-set-selections && \
echo "slapd slapd/move_old_database boolean true" |debconf-set-selections && \
echo "slapd slapd/allow_ldap_v2 boolean false" |debconf-set-selections && \
echo "slapd slapd/no_configuration boolean false" |debconf-set-selections
apt-get install -y slapd


service slapd restart

ldapadd -Y EXTERNAL -H ldapi:/// -f /ldap_utils/alcs.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /ldap_utils/sssvlv_load.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /ldap_utils/sssvlv_config.ldif
ldapadd -x -D cn=admin,dc=cartodb,dc=com -w changeme -c -f /ldap_utils/objects.ldif
