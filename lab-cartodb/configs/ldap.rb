FactoryGirl.define do

  factory :ldap_configuration, :class => Carto::Ldap::Configuration do
    host "ldap"
    port 389
    domain_bases_list [ 'dc=cartodb' ]
    connection_user 'ldap_conn_user'
    connection_password 'changeme'
    email_field '.'
    user_object_class '.'
    group_object_class '.'
    user_id_field 'userid'
    username_field 'username'
  end

end
