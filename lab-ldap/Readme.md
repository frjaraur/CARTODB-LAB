

Some LDAP Tools added

Add LDAP users
/ldap_utils/addldapuser.sh

Delete LDAP users
/ldap_utils/delldapuser.sh

Change LDAP user password
/ldap_utils/passwdldapuser.sh

Recreate LDAP from scratch
/ldap_utils/recreateldap.sh

Change admin user password from default 'password' value
/ldap_utils/changeme.sh

All can be used from container while running with 
docker exec <container_name> <command>
Some are interactive so better use docker exec -ti <container_name> <command>
or just use bash as command and then launch the script "in".


