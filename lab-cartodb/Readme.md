host "ldap"
port 389
domain_bases_list [ 'dc=cartodb' ]
connection_user 'ldap_conn_user'
connection_password 'changeme'
email_field '.'
user_object_class '.'
group_object_class '.'
user_id_field 'user_id'
username_field 'username'
