#!/bin/bash -x
set -e

ERRORS=0

ACTION=$1

ENVIRONMENT=$2

INTERACTIVE=$3

DEFAULT_ENVIRONMENT="development"

[ "${ENVIRONMENT}" = "" ] && ENVIRONMENT=${DEFAULT_ENVIRONMENT}

export RAILS_ENV=${ENVIRONMENT}

FIRST_RUN_FILE_FLAG=${CARTODB}/CartoDB_setup_finished

DATABASE_INITIALIZED_FILE_FLAG=${PGDATA}/PostgreSQL_database_initialized

Help(){
	echo
	echo "###########################"
	echo "## CartoDB Docker Server ##"
	echo "###########################"
	echo 
	echo "Usage:"
	echo "Start this docker container with this options"
	echo
	echo " --> 'start_all' <ENVIRONMENT>"
	echo " --> 'start_postgresql'"
	echo " --> -------------------------------"	

	exit 0
}


Start_Redis(){
	echo "Starting REDIS Server" 
	/usr/bin/redis-server ${REDIS}/redis.conf
}

Start_Postgresql(){

	if [ ! -f ${DATABASE_INITIALIZED_FILE_FLAG} ]
	then
		echo "Opening database Locally for some work ..."
			
		gosu postgres pg_ctl -D "${PGDATA}" -o "-c listen_addresses=''" -w start
		
		
		
		POSTGIS_SQL_PATH=`pg_config --sharedir`/contrib/postgis-2.2
		#createdb -E UTF8 template_postgis
		#createlang -d template_postgis plpgsql
		#psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis'"


		
			
		gosu postgres createuser publicuser --no-createrole --no-createdb --no-superuser -U postgres
			
		gosu postgres createuser tileuser --no-createrole --no-createdb --no-superuser -U postgres
			
		gosu postgres createdb -T template0 -O postgres -U postgres -E UTF8 template_postgis
		#gosu postgres createdb -O postgres -U postgres -E UTF8 template_postgis
		gosu postgres psql -U postgres template_postgis -c 'CREATE EXTENSION postgis;'
		gosu postgres psql -U postgres template_postgis -c 'CREATE EXTENSION postgis_topology;'
		
		gosu postgres psql -U postgres template_postgis -c 'CREATE OR REPLACE LANGUAGE plpgsql;'
		gosu postgres psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis';"
		
		gosu postgres psql -d template_postgis -f $POSTGIS_SQL_PATH/postgis.sql
		gosu postgres psql -d template_postgis -f $POSTGIS_SQL_PATH/spatial_ref_sys.sql
		gosu postgres psql -d template_postgis -f $POSTGIS_SQL_PATH/legacy.sql
		gosu postgres psql -d template_postgis -f $POSTGIS_SQL_PATH/rtpostgis.sql
		gosu postgres psql -d template_postgis -f $POSTGIS_SQL_PATH/topology.sql
		gosu postgres psql -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
		gosu postgres psql -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"
			
		#gosu postgres psql -U postgres template_postgis -c 'CREATE EXTENSION postgis;CREATE EXTENSION postgis_topology;'
			
		echo "Stopping Database For a Complete Start ... "
			
		gosu postgres pg_ctl -D "${PGDATA}" -m fast -w stop
			
		touch ${DATABASE_INITIALIZED_FILE_FLAG}
	else
		
		echo
		echo "PostgreSQL Database Initialized..."
		echo
		
			
	fi	
			
			
			echo
			echo "Starting PostgreSQL..."
			echo
			echo PGDATA $PGDATA
  			gosu postgres pg_ctl -D "${PGDATA}" -o "-c listen_addresses='*'" -w start
  			#/usr/sbin/service postgresql start
  			
  			#exec start-stop-daemon --start --chuid ${PG_USER}:${PG_USER} --exec ${PG_BINDIR}/postgres -- -D ${PGDATA} 

}

Start_CartoDB(){
	cd ${CARTODBMAIN}
	echo "Starting CARTODB ...."			
	bundle exec thin start --threaded -p 3000 --threadpool-size 5
	echo 
}


Start_SQLAPI(){		
	
	#if [ ! -f ${SQLAPI}/config/environments/${ENVIRONMENT}.js ]
	#then 
		#cat ${SQLAPI}/config/environments/${ENVIRONMENT}.js.example |sed -e"s/127\.0\.0\.1/${ENVIRONMENT}\.localhost\.lan/g" > ${SQLAPI}/config/environments/${ENVIRONMENT}.js
	#fi
	
	
	echo "Starting SQL API ...."
	/usr/bin/node ${SQLAPI}/app.js ${ENVIRONMENT} &
	echo
}

Start_MAPSAPI(){	
	#if [ ! -f ${MAPAPI}/config/environments/${ENVIRONMENT}.js ]
	#then 
		#cat ${MAPAPI}/config/environments/${ENVIRONMENT}.js.example |sed -e"s/127\.0\.0\.1/${ENVIRONMENT}\.localhost\.lan/g" > ${MAPAPI}/config/environments/${ENVIRONMENT}.js
	#fi
	echo "Starting MAPS API ...."
	/usr/bin/node ${MAPAPI}/app.js ${ENVIRONMENT} &
	echo 
}

Setup_CartoDB(){

	cd ${CARTODBMAIN}
	echo "First RUN ...."
	
	#cat config/app_config.yml.sample |sed -e"s/127\.0\.0\.1/${ENVIRONMENT}/g" > config/app_config.yml
	
	#cat config/database.yml.sample |sed -e"s/127\.0\.0\.1/${ENVIRONMENT}/g" > config/database.yml
		
	export PASSWORD="changeme"
	export ADMIN_PASSWORD="changeme"
	export EMAIL="dummy@dummy.me"
	export USER="dummy"
	export SUBDOMAIN=$ENVIRONMENT

		
	echo "PASSWORD: $PASSWORD"
	echo "ADMIN_PASSWORD: ${ADMIN_PASSWORD}"
	echo "EMAIL: $EMAIL"
		
    # Add entries to /etc/hosts needed in development
	[ $(grep -c "${SUBDOMAIN}" /etc/hosts ) -eq 0 ] && echo "127.0.0.1 ${SUBDOMAIN}.localhost.lan" | tee -a /etc/hosts
		
	   
	echo "Creating Development User ...."
	
	bundle exec rake rake:db:create
	sleep 10
	bundle exec rake rake:db:migrate
	sleep 10
	bundle exec rake cartodb:db:create_publicuser
	sleep 10
	bundle exec rake cartodb:db:create_dev_user SUBDOMAIN="${SUBDOMAIN}" \
	PASSWORD="${PASSWORD}" ADMIN_PASSWORD="${ADMIN_PASSWORD}" \
	EMAIL="${EMAIL}"
	sleep 10
	bundle exec rake cartodb:db:create_importer_schema
	sleep 10
	bundle exec rake cartodb:db:load_functions
	sleep 10
	
	[ "$ORGANIZATION_ID" = "" ] && ORGANIZATION_ID=$(echo cartodb | md5sum|awk '{ print $1 }') && export ORGANIZATION_ID
	bundle exec rake cartodb:ldap:create_ldap_configuration
	sleep 10
	
}

Start_RubyOnRailsServer(){	
	echo "Staring Ruby On Rails Server ...."
	bundle exec rails server -d
	echo
}

Start_Resque(){	
	echo "Starting resque ...."
	nohup bundle exec script/resque > /tmp/resque.out 2>&1&
	echo
}



case ${ACTION} in 

	help)
	
		Help
	;;

	start_all)
	
		Start_Postgresql
		sleep 5
		
		Start_Redis
		sleep 5
		
		Setup_CartoDB
		
		Start_Resque
				
		Start_SQLAPI
		
		Start_MAPSAPI
		
		Start_CartoDB
		
	;;
	
	start_postgresql)
	
		Start_Postgresql
	;;

	start_setup)
	
		[ -f ${FIRST_RUN_FILE_FLAG} ] && rm -f ${FIRST_RUN_FILE_FLAG}

		[ -f ${DATABASE_INITIALIZED_FILE_FLAG} ] &&  rm -f ${FIRST_RUN_FILE_FLAG}
	;;
	
	*)
	
		exec "$@"
	;;
esac




exec "$INTERACTIVE"

	
